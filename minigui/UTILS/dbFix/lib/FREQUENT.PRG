/*

  FREQUENT.PRG    These functions get used everywhere!

  These functions are called so often (both by external programs and within
  RayLib) that they deserve their own uncluttered OBJ!

*/
#include "default.ch"

#define CRLF  chr(13)+chr(10)


Function FWriteLn(h, cText)
/*
  Writes a line of text to a file handle (h) followed by CRLF.
*/

  fwrite(h, cText + CRLF)

Return(NIL)



Function InsDel(cOrig, nStart, nDelete, cInsert)
/*
  InsDel() works exactly like Clipper's stuff() function, but for some
    reason stuff() seemed to be causing GPFs when used with FiveWin.
*/
Return(left(cOrig, nStart - 1) + cInsert + substr(cOrig, nStart + nDelete))



Function Nstr(n, nLen, nDec)
/*
  ltrim(str(n[, nLen, nDec]))
*/
  local c

  if nLen == NIL
    c := str(n)
  else
    default nDec := 0
    c := str(n, nLen, nDec)
  endif

Return(ltrim(c))



Function ReplaceStr(cString, cOld, cNew)
/*
  Equivalent to strtran(), without the nStart and nCount options.

  Replaces all occurrences of the cOld substring with cNew within the larger
  string cString.  Case matters.

  Example:  ReplaceStr("Peter Piper", "er", "ery")  -->  "Petery Pipery"

  (The function formerly known as Replace())
*/
  local o, n, x, i := 1
  local cWork := cString

  o := len(cOld)
  n := len(cNew)

  if len(cWork) == 0 .or. o == 0 // Can't replace null strings!
    Return(cWork)
  endif

  do while (x := at(cOld, substr(cWork, i))) > 0
    x += (i - 1)
    cWork := InsDel(cWork, x, o, cNew)
    // Move the index past the replacement string.  This avoids an endless
    // loop should cOld be a substring of cNew!
    i := x + n
  enddo

Return(cWork)



Function IReplaceStr(cString, cOld, cNew)
/*
  Like ReplaceStr(), but case-insensitive.
*/
  local o, n, x, i := 1
  local cWork := cString
  local cUpOld, cUpWork

  o := len(cOld)
  n := len(cNew)

  if len(cWork) == 0 .or. o == 0 // Can't replace null strings!
    Return(cWork)
  endif

  cUpOld := upper(cOld)
  cUpWork := upper(cWork)

  do while (x := at(cUpOld, substr(cUpWork, i))) > 0
    x += (i - 1)
    cWork := InsDel(cWork, x, o, cNew)
    // Move the index past the replacement string.  This avoids an endless
    // loop should cOld be a substring of cNew!
    i := x + n
    cUpWork := upper(cWork)
  enddo

Return(cWork)



Function SetCentury(lToggle)
/*
  Logical Set/Get function for the SET CENTURY setting.  It simply calls the
  function that SET CENTURY preprocesses to: __SetCentury(lToggle).
*/
Return(__SetCentury(lToggle))



Function StoD(cDTOS)
/*
  The functional inverse of dtos().
*/
  local dNew
  local cDF := set(_SET_DATEFORMAT, "YYYY/MM/DD")

  dNew := ctod(transform(cDTOS, "@R 9999/99/99"))

  set(_SET_DATEFORMAT, cDF)

Return(dNew)



Function XCommit(lExclusive)
/*
  Use in an aliased expression to issue the following oft-reapeated commands:

  DBCommit()
  DBUnlock()
  DBSkip(0)

  The DBUnlock() step will not be performed if lExclusive is true (defaults
  to false).
*/
  default lExclusive := .F.

  DBCommit()

  if !lExclusive
    DBUnlock()
  endif

  DBSkip(0)

Return(NIL)


// Stubs for common FiveWin function calls:

#ifdef DOS_ONLY

Function CursorArrow()
Return(NIL)

Function CursorWait()
Return(NIL)

Function cValToChar(u)
Return(XtoC(u))

Function MessageBeep(nBeep)
Return(tone(100, 3))

Function MsgAlert(cText, cCaption)
Return(alert(cText))

Function MsgInfo(cText, cCaption)
Return(alert(cText))

Function MsgMeter(bAction, cMsg, cTitle, lNoCancel, oParent)
Return(eval(bAction))

Function MsgRetryCancel(cText, cCaption)
Return(alert(cText, { "Retry", "Cancel" }) == 1)

Function MsgStop(cText, cCaption)
Return(alert(cText))

Function MsgYesNo(cText, cCaption)
Return(alert(cText, { "Yes", "No" }) == 1)

Function SysRefresh()
Return(NIL)

#endif
