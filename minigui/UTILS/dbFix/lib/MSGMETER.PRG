/*

  MSGMETER.PRG    Modified from the FiveWin original

*/

#ifdef DOS_ONLY

#include "default.ch"
#include "setcurs.ch"

Function MsgWait(bAction, cMsg, cTitle, lNoCancel, oParent)
/*
  Performs an action in a codeblock while showing the user a message on
  the screen.
*/
  local uRetVal
  local t, l, b, r, cScreen, nCursor

  default bAction   := {|| NIL }, ;
          cMsg      := "Processing...", ;
          cTitle    := "Please Wait", ;
          lNoCancel := .F.

  // Display the box:

  // Save cursor position, too...
  nCursor := setcursor(SC_NONE)
  t := 1
  l := 1 // Until I get around to this...
  b := 2
  r := 2
  cScreen := savescreen(t, l, b, r)

  // Call the codeblock:

  uRetVal := eval(bAction, nil, nil, .F.) // oTxt, oDlg, lEnd

  // Destroy the box:

  restscreen(t, l, b, r, cScreen)
  nCursor := setcursor(nCursor)

Return(uRetVal)

#else

#include "fivewin.ch"

Function MsgMeter(bAction, cMsg, cTitle, lNoCancel, oParent)
/*
  Modified 9/25/96 RWM: Return the value from evaluating bAction.
  Modified 11/6/96 RWM: Added lNoCancel to disable the Cancel button.
  Modified 4/27/97 RWM: Default the meter total to 100 (was 10).
  Modified 4/16/98 RWM: Added the optional oParent parameter.  This helps
    during long processes:  If the parent window is not specified and you
    bring up another application over the FiveWin app & then the meter dialog
    activates, the other app is trapped between the meter dialog and the
    FiveWin app as if the dialog is modal to the other application!
  Modified 4/27/98 RWM: Changed dialog style to exclude system menu so it
    can't be cancelled if you disable the cancel button.
*/
  local oDlg, oMeter, oText
  local lEnd := .F.
  local nVal := 0
  local uRetVal    // Return value from evaluating bAction

  default cMsg := "Please Wait...", ;  // Removed default of bAction (duh!)
          cTitle := "Processing",   ;
          lNoCancel := .F.

  define dialog oDlg from 5, 5 to 11, 45 title cTitle ;
    style nOr(DS_MODALFRAME, WS_POPUP, WS_CAPTION)

  @ 0.2, 0.5 say oText var cMsg size 150, 10 of oDlg

  @ 1.0, 0.5 meter oMeter var nVal total 100 size 150, 10 of oDlg

  @ 2.5, 9.5 button "Cancel" of oDlg size 32, 13 action lEnd := .T. ;
             when !lNoCancel ;
             cancel

  oDlg:oWnd := oParent
  oDlg:bStart := {|| uRetVal := eval(bAction, oMeter, oText, oDlg, @lEnd), ;
                     lEnd := .T., oDlg:End() }

  activate dialog oDlg centered ;
    valid lEnd

Return(uRetVal)


//----------------------------------------------------------------------------//


Function DblMeter(bAction, cMsg, cTitle, lNoCancel, oParent)
/*
  A double MsgMeter() function that works just like the original, except that
  your bAction will look like this: {|oMtr1, oMtr2, oTxt, oDlg, lEnd| ... }
*/
  local oDlg, oMtr1, oMtr2, oTxt
  local nVal1 := 0, nVal2 := 0
  local lEnd := .F., uRetVal

  default cMsg := "Please Wait...", ;
          cTitle := "Processing",   ;
          lNoCancel := .F.

  define dialog oDlg from 5, 5 to 13, 45 title cTitle ;
    style nOr(DS_MODALFRAME, WS_POPUP, WS_CAPTION)

  @ 0.2, 0.5 say oTxt var cMsg size 150, 10 of oDlg

  @ 1.0, 0.5 meter oMtr1 var nVal1 total 100 size 150, 10 of oDlg

  @ 2.0, 0.5 meter oMtr2 var nVal2 total 100 size 150, 10 of oDlg

  @ 3.7, 9.5 button "Cancel" of oDlg size 32, 13 action lEnd := .T. ;
             when !lNoCancel ;
             cancel

  oDlg:oWnd := oParent
  oDlg:bStart := {|| uRetVal := eval(bAction, oMtr1, oMtr2, oTxt, oDlg, @lEnd), ;
                     lEnd := .T., oDlg:End() }

  activate dialog oDlg centered ;
    valid lEnd

Return(uRetVal)


//----------------------------------------------------------------------------//


Function MsgWait(bAction, cMsg, cTitle, lNoCancel, oParent)
/*
  Works just like MsgMeter(), but with no meter.  The bAction block will look
  like so: {|oDlg, oTxt, lEnd| ... }
*/
  local oDlg, oTxt, oFont
  local lEnd := .F.
  local uRetVal

  default bAction   := {|| NIL }, ;
          cMsg      := "Processing...", ;
          cTitle    := "Please Wait", ;
          lNoCancel := .F.

  define font oFont name "MS Sans Serif" size 0, -8 bold

  define dialog oDlg from 1, 1 to 76, 340 title cTitle pixel font oFont ;
    style nOr(DS_MODALFRAME, WS_POPUP, WS_CAPTION)

  @  3,  3 say oTxt var cMsg centered size 165, 16 pixel of oDlg ;
            font oFont
  @ 22, 63 button "Cancel" size 43, 11 pixel of oDlg ;
            font oFont ;
            action lEnd := .T. ;
            when !lNoCancel

  oDlg:oWnd := oParent
  oDlg:bStart := {|| uRetVal := eval(bAction, oTxt, oDlg, @lEnd), ;
                     lEnd := .T., oDlg:End() }

  activate dialog oDlg centered ;
    valid lEnd

  oFont:End()
  SysRefresh()

Return(uRetVal)

#endif // not DOS_ONLY

