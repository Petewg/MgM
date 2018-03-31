/*---------------------------------------------------------------- NETUSE.PRG

  Network aware file opening & locking routines

*/
#include "error.ch"
#include "filepart.ch"
#include "winmisc.ch"

#ifdef DOS_ONLY
  #include "default.ch"
  #include "inkey.ch"
  #define CRLF  chr(13)+chr(10)
#else
  #include "fivewin.ch"
#endif

static cFATitle := "File Access"


//-------------------------------------------------------------------- NetUse


Function NetUse(cFile, lExclusive, cIndex, lAuto)
/*
  An error-tolerant use function that returns a logical pass/fail result.
  Adapted from the old Grumpfish Net_Use() function.

  New: Putting the text "Immediate" (case does not matter) somewhere in the
  cFile parameter will cause the function to return immediately without
  notifying the user should the file not be available as requested.

  Added a new parameter 3/25/99: lAuto.  This value will temporarily change
  the cmxAutoOpen() setting while opening the requested database.

  See also: SetTryOut()
*/
  local lSuccess := .F.
  local cDriver, cAlias, lReadOnly := .F.
  local lBomb := .F., lRetry := .F., lWait := .T.
  local bPrevErr, oUseErr
  local cTemp, n

  // Fix up the incoming parameters...
  default lExclusive := .F.
  cFile := upper(cFile)

  // Is ALIAS part of cFile?
  if ( n := at(" ALIAS ", cFile) ) > 0
    cAlias := alltrim(substr(cFile, n + 7))
    if ( n := at(" ", cAlias) ) > 0
      cAlias := substr(cAlias, 1, n - 1)
    endif
    cFile := ReplaceStr(cFile, " ALIAS " + cAlias, "")
  endif

  // Is VIA part of cFile?
  if ( n := at(" VIA ", cFile) ) > 0
    cDriver := alltrim(substr(cFile, n + 5))
    if ( n := at(" ", cDriver) ) > 0
      cDriver := substr(cDriver, 1, n - 1)
    endif
    cFile := ReplaceStr(cFile, " VIA " + cDriver, "")
  endif

  // Is IMMEDIATE part of cFile?
  if ( n := at(" IMMEDIATE", cFile) ) > 0
    lWait := .F.
    cFile := ReplaceStr(cFile, " IMMEDIATE", "")
  endif

  // Is READONLY part of cFile?
  if ( n := at(" READONLY", cFile) ) > 0
    lReadonly := .T.
    cFile := left(cFile, n - 1) // Last one so remove everything...
  endif

  cFile := alltrim(cFile)

  // See if the requested alias is already in use:
  cTemp := iif(empty(cAlias), FileParts(cFile, FP_NAMEONLY), cAlias)
  do while select(cTemp) > 0
    if !MsgRetryCancel('The alias "' + cTemp + '" is already in use.', cFATitle)
      Return(lSuccess)
    endif
    SysRefresh()
  enddo

  // Turn off cmxAutoOpen if requested:
  if valtype(lAuto) == "L"
    lAuto := sx_AutoOpen(lAuto)
  endif

  // Post custom error handler to take care of file handle problems, etc.
  bPrevErr := errorblock( {|e| NU_Error(e, bPrevErr, @lRetry) })

  // Try to open the database...
  lRetry := .T.
  do while !lBomb .and. lRetry
    lRetry := .F.
    begin sequence
      dbUseArea(.T., cDriver, cFile, cAlias, !lExclusive, lReadonly)
      SysRefresh()
    recover using oUseErr
      if (oUseErr:genCode <> EG_OPEN .or. oUseErr:osCode <> 32) .and. !lRetry
        lBomb := .T.
      endif
    end sequence
  enddo

  // If it didn't open (and didn't bomb), do the wait dialog...
  if !lBomb
    if neterr()
      if lWait
        lSuccess := MsgWait({|oT, oD, lEnd| Try2Open(oUseErr, cFile, cDriver, cAlias, lExclusive, lReadonly, @lEnd) }, ;
                            "Waiting for file to become available:" + CRLF + cFile, ;
                            cFATitle)
      endif
    else
      lSuccess := .T.   // Otherwise set lSuccess to true!
    endif
  endif

  // If opened, open the index (if requested).  If that fails, close the DBF.
  if lSuccess .and. !empty(cIndex)
    begin sequence
      set index to (cIndex)
    recover
      lSuccess := .F.
      DBCloseArea()
    end sequence
  endif

  // Replace the previous error handler:
  errorblock(bPrevErr)

  // Restore the previous auto-open setting:
  if valtype(lAuto) == "L"
    sx_AutoOpen(lAuto)
  endif

Return(lSuccess)



STATIC Function Try2Open(oUseErr, cFile, cDriver, cAlias, lExclusive, lReadonly, lEnd)
  local lSuccess := .F.
  local nTries := 0, nTryOut := SetTryOut() * 2

  do while !lEnd .and. !lSuccess

    begin sequence
      dbUseArea(.T., cDriver, cFile, cAlias, !lExclusive, lReadonly)
    recover using oUseErr
      if oUseErr:genCode <> EG_OPEN .or. oUseErr:osCode <> 32
        lEnd := .T.
        exit
      endif
    end sequence

    SysRefresh()

    if !neterr()
      MessageBeep(MB_ICONASTERISK)
      lSuccess := .T.
    endif

    if nTryOut > 0
      if ++nTries >= nTryOut
        exit
      endif
    endif

    WaitASec()

    #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
    #endif

  enddo

  if lEnd
    lSuccess := .F.
  endif

Return(lSuccess)



STATIC Function NU_Error(oUseErr, bPrevErr, lRetry)
  local cTitle := "File Error " + procname(4) + "(" + Nstr(procline(4)) + ")"

  local cMsg := "Cannot open " + oUseErr:filename + CRLF

  if oUseErr:genCode == EG_OPEN

    if oUseErr:osCode == 32 // A sharing violation?  Set neterr() & continue.
      neterr(.T.)
    else
      do case
        case oUseErr:osCode == 2
          cMsg += "File not found"
        case oUseErr:osCode == 3
          cMsg += "Path not found"
        case oUseErr:osCode == 4
          cMsg += "Out of file handles"
        case oUseErr:osCode == 5 .or. oUseErr:osCode == 65
          cMsg += "Access Denied"
        otherwise
          cMsg += "OS Code #" + Nstr(oUseErr:osCode)
      endcase
      lRetry := MsgRetryCancel(cMsg, cTitle)
    endif
    break oUseErr

  elseif oUseErr:genCode == EG_CORRUPTION

    MsgStop(cMsg + "Corruption detected", cTitle)
    // Don't break this error - if we do, the program dies anyway, but does
    // not generate an error.log!

  endif

Return eval(bPrevErr, oUseErr)


//-------------------------------------------------------------------- AddRec


Function AddRec(nTryOut)
/*
  Error-tolerant DBAppend() function that returns a logical pass/fail result.
  It tries to append a record until the user decides to cancel it.

  nTryOut is an optional parameter that will override the current setting of
  SetTryOut() if used.
*/
  local lAdded := .T.

  DBAppend()

  if neterr()
    lAdded := MsgWait({|oT, oD, lEnd| Try2Add(nTryOut, @lEnd) }, ;
                      "Waiting for record append:" + CRLF + ;
                      "Work area '" + alias() + "'", ;
                      cFATitle)
  endif

Return(lAdded)



STATIC Function Try2Add(nTryOut, lEnd)
  local lAdded := .F.
  local nTries := 0

  default nTryOut := SetTryOut()

  nTryOut *= 2  // Two attempts per second

  do while !lEnd .and. !lAdded

    WaitASec()

    DBAppend()

    if neterr()
      if nTryOut > 0
        if ++nTries >= nTryOut
          exit
        endif
      endif
    else
      MessageBeep(MB_ICONASTERISK)
      lAdded := .T.
    endif

    #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
    #endif

  enddo

Return(lAdded)


//------------------------------------------------------------------ FileLock


Function FileLock(nTryOut)
/*
  An error-tolerant file locking function that returns a logical pass/fail
  result.  It tries to get a lock until the user decides to cancel it.

  nTryOut is an optional parameter that will override the current setting of
  SetTryOut() if used.
*/
  local lLocked := .F.

  if !(lLocked := flock())
    lLocked := MsgWait({|oT, oD, lEnd| Try2Flock(nTryOut, @lEnd) }, ;
                        "Waiting for file lock:" + CRLF + ;
                        "Work area '" + alias() + "'", ;
                        cFATitle)
  endif

Return(lLocked)



STATIC Function Try2Flock(nTryOut, lEnd)
  local lLocked := .F.
  local nTries := 0

  default nTryOut := SetTryOut()

  nTryOut *= 2  // Two attempts per second

  do while !lEnd .and. !lLocked

    WaitASec()

    DBSkip(0) // Refresh the buffer in case someone else was in it!

    if (lLocked := flock())
      MessageBeep(MB_ICONASTERISK)
    elseif nTryOut > 0
      if ++nTries >= nTryOut
        exit
      endif
    endif

    #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
    #endif

  enddo

Return(lLocked)


//------------------------------------------------------------------- RecLock


Function RecLock(nTryOut)
/*
  Error tolerant record locking function that returns a logical pass/fail
  result.  It tries to get a lock until the user decides to cancel it.

  nTryOut is an optional parameter that will override the current setting of
  SetTryOut() if used.
*/
  local lLocked := .F.

  if !(lLocked := rlock())
    lLocked := MsgWait({|oT, oD, lEnd| Try2Rlock(nTryOut, @lEnd) }, ;
                        "Waiting for record lock:" + CRLF + "Record #" + ;
                        Nstr(recno()) + " in work area '" + alias() + "'", ;
                        cFATitle)
  endif

Return(lLocked)



STATIC Function Try2Rlock(nTryOut, lEnd)
  local lLocked := .F.
  local nTries := 0

  default nTryOut := SetTryOut()

  nTryOut *= 2  // Two attempts per second

  do while !lEnd .and. !lLocked

    WaitASec()

    DBSkip(0) // Refresh the buffer in case someone else was in it!

    if (lLocked := rlock())
      MessageBeep(MB_ICONASTERISK)
    elseif nTryOut > 0
      if ++nTries >= nTryOut
        exit
      endif
    endif

    #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
    #endif

  enddo

Return(lLocked)


//--------------------------------------------------------- Support Functions


Function SetTryOut(nNew)
/*
  Set/get the default length of time in seconds to continue retrying a failed
  lock or open instruction in one of the following functions:

  NetUse(), RecLock(), FileLock() and AddRec()

  The default value is zero (0), meaning to retry indefinitely.

  Normally, this would be used before starting an automated process where the
  user wouldn't be there to respond to a "Waiting for..." dialog.  This
  allows the open/lock to be retried for a while but will give up & allow the
  rest of the process to continue instead of halting the entire job.
*/
  static nTryOut := 0
  local nRet

  nRet := nTryOut

  if valtype(nNew) == "N"   // New value given?
    nTryOut := nNew
  endif

Return(nRet)



STATIC Function WaitASec()
  local nStop := seconds() + .5
  local x := 0

  // This function does nothing but delay for one-half second.

  if nStop >= 86398             // Don't get stuck at midnight!
    nStop := -1
  endif

  do while seconds() < nStop
    if x++ >= 50                // Don't SysRefresh() on every loop...
      x := 0
      SysRefresh()
    endif
  enddo

Return(NIL)


//---------------------------------------------------------------------- Misc


Function NewAlias(cBase)
/*
  Used to get a unique alias based on <cBase> (usually the filename).

  First, cBase is checked to see if it is a legal alias name.  If it contains
  any illegal characters, they are changed to underscores.  If it doesn't
  begin with a letter, one is prepended ("A" + cBase).

  If cBase is not already in use, it will be returned.  Otherwise, a number
  will be added to the end and incremented until an alias that is not in use
  is found.
*/
  local cAlias, cWork, x, nLen
  local cValid := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

  // Make sure cBase is a legal alias. Replace any illegal chars with "_":

  cWork := upper(alltrim(cBase))

  nLen := len(cWork)

  for x := 1 to nLen
    if .not. substr(cWork, x, 1) $ cValid
      cWork := left(cWork, x - 1) + "_" + substr(cWork, x + 1)
    endif
  next

  // Add a leading alpha character if needed:

  if !IsAlpha(cWork)
    cWork := "A" + cWork
  endif

  // Make sure it's not in use:

  cAlias := cWork
  x := 0

  do while select(cAlias) > 0
    cAlias := cWork + Nstr(++x)
  enddo

Return(cAlias)



Function SafeClose(cAlias)
/*
  The function will close the workarea identified by <cAlias> if it is open
  and return a logical indicating whether it was open or not.
*/
  local lWasOpen := .F.

  if !empty(cAlias)
    if select(cAlias) > 0
      lWasOpen := .T.
      (cAlias)->( DBCloseArea() )
    endif
  endif

Return(lWasOpen)



