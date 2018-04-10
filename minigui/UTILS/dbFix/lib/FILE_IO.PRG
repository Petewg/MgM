/*

  FILE_IO.PRG    Low-level file i/o functions

*/
#include "default.ch"
#include "error.ch"
#include "fileio.ch"


Function cFError(n)
/*
  Returns the text description of a numeric ferror() code.
*/
  local cText

  default n := ferror()

  do case
    case n == 0
      cText := "No error"
    case n == 2
      cText := "File not found"
    case n == 3
      cText := "Path not found"
    case n == 4
      cText := "Too many files open"
    case n == 5
      cText := "Access denied"
    case n == 6
      cText := "Invalid handle"
    case n == 8
      cText := "Insufficient memory"
    case n == 15
      cText := "Invalid drive specified"
    case n == 19
      cText := "Attempted to write to a write-protected disk"
    case n == 21
      cText := "Drive not ready"
    case n == 23
      cText := "Data CRC error"
    case n == 29
      cText := "Write fault"
    case n == 30
      cText := "Read fault"
    case n == 32
      cText := "Sharing violation"
    case n == 33
      cText := "Lock violation"
    otherwise
      cText := "Error #" + Nstr(n)
  endcase

Return(cText)



Function FCopy(cSource, cTarget, lMsgs)
/*
  A low-level file copy function that returns a logical indicating success.
  If an error occurs, the function will attempt to erase the target file and
  will show an error message unless lMsgs is false (default is true).

  If the source file does not exist, the function will return false but will
  not show an error message.
*/
  #define FC_CHUNK  8192

  local lOk := .T., cMsg := "", nErr := 0
  local hSource := F_ERROR, hTarget := F_ERROR
  local nBytes, cBuffer

  default lMsgs := .T.

  if !file(cSource)
    Return(.F.)
  endif

  do while lOk

    if (hSource := fopen(cSource, FO_READ + FO_DENYWRITE)) == F_ERROR
      lOk := .F.
      nErr := ferror()
      cMsg := " opening " + cSource
      exit
    endif

    if (hTarget := fcreate(cTarget, FC_NORMAL)) == F_ERROR
      lOk := .F.
      nErr := ferror()
      cMsg := " creating " + cTarget
      exit
    endif

    nBytes  := FC_CHUNK
    cBuffer := space(FC_CHUNK)

    do while nBytes == FC_CHUNK .and. lOk
      nBytes := fread(hSource, @cBuffer, FC_CHUNK)
      if nBytes > 0
        if fwrite(hTarget, cBuffer, nBytes) <> nBytes
          lOk := .F.
          nErr := ferror()
          cMsg := " writing to " + cTarget
        endif
      elseif nBytes < 0
        lOk := .F.
        nErr := ferror()
        cMsg := " reading " + cSource
      endif
    enddo

    exit

  enddo

  if hTarget <> F_ERROR
    if !fclose(hTarget) .and. lOk
      lOk := .F.
      nErr := ferror()
      cMsg := " closing " + cTarget
    endif
  endif

  if hSource <> F_ERROR
    if !fclose(hSource) .and. lOk
      lOk := .F.
      nErr := ferror()
      cMsg := " closing " + cSource
    endif
  endif

  if !lOk
    ferase(cTarget)
    if lMsgs
      MsgAlert("Error " + Nstr(nErr) + cMsg, ;
               procname(1) + "(" + Nstr(procline(1)) + ")")
    endif
  endif

Return(lOk)



Function FileCopy(cSource, cTarget)
/*
  Wraps an error trap around the standard "copy file" syntax.  Will display
  an error message and return false if an error occurs.

  Return value:  Logical indicating success.
*/
  local lOk := .F.
  local oErr, bErr := errorblock({|oErr| break(oErr) })

  begin sequence

    copy file (cSource) to (cTarget)
    lOk := .T.

  recover using oErr

    if oErr:genCode == EG_CREATE .or. oErr:genCode == EG_OPEN .or. ;
       oErr:genCode == EG_CLOSE  .or. oErr:genCode == EG_READ .or. ;
       oErr:genCode == EG_WRITE
      MsgAlert(cValToChar(oErr:description) + " " + ;
               Nstr(oErr:osCode) + ": " + ;
               cValToChar(oErr:filename), "Copy Error")
    else
      eval(bErr, oErr) // Unexpected - give it to the default error handler
    endif

  end sequence

  errorblock(bErr)

  if !lOk
    ferase(cTarget)
  endif

Return(lOk)



Function RenFile(cOld, cNew)
/*
  Error-checking, destructive file rename function - use it instead of
  frename().  If cNew exists, it will be deleted before renaming cOld,
  instead of just failing like frename() would - make sure you don't want it!

  Returns a logical indicating success.  If an error occurs during the
  rename, a MsgRetryCancel() showing the ferror() number & the calling
  procname() and procline() will be shown.

  If cOld does not exist, the function will return false but will not show an
  error message (but you should check that first anyway!).
*/
  local lOk := .F.

  if file(cOld)
    do while !lOk
      if file(cNew)
        ferase((cNew))
        SysRefresh()
      endif
      if frename(cOld, cNew) == F_ERROR
        if !MsgRetryCancel("Error " + Nstr(ferror()) + " renaming " + ;
                           cOld + " to " + cNew, ;
                           procname(1) + "(" + Nstr(procline(1)) + ")")
          exit
        endif
        SysRefresh()
      else
        lOk := .T.
      endif
    enddo
  endif

Return(lOk)



Function WriteLog(xMsg, cFile, lOverwrite)
/*
  Writes a character string (or array) <xMsg> to a text file <cFile>.
  lOverwrite defaults to false.
*/
  local hLog, lOpen := .F.

  default lOverwrite := .F.

  if file(cFile) .and. !lOverwrite
    hLog := fopen(cFile, FO_READWRITE)
    lOpen := .T.
  else
    hLog := fcreate(cFile, FC_NORMAL)
  endif

  if hLog == F_ERROR
    MsgAlert("Error " + Nstr(ferror()) + ;
             iif(lOpen, " opening ", " creating ") + cFile, ;
             procname(1) + "(" + Nstr(procline(1)) + ")")
    Return(.F.)
  endif

  // Seek to the end of the file (append):

  fseek(hLog, 0, FS_END)

  // If xMsg is an array, each element is a line of text.  If character, it
  // is a single line of text:

  if valtype(xMsg) == "A"
    aeval(xMsg, {|e| FWriteLn(hLog, e) })
  elseif valtype(xMsg) == "C"
    FWriteLn(hLog, xMsg)
  endif

  fclose(hLog)

Return(.T.)


