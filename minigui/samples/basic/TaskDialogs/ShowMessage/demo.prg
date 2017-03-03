/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Quick Message functions
 *
 * (c) 2016 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"
#include "TaskDlgs.ch"


PROCEDURE main()
   LOCAL lIsVistaOrLater := IsVistaOrLater()
   LOCAL nButton

IF lIsVistaOrLater

   ShowMessage( , 'This uses the "ShowMessage" function', ;
      "Just use an additional parameter (optional) to add this extra text.", ;
      "And another parameter for yet more text. And another parameter for the footer.", ;
      'This is the footer with hyperlink <a href="www.hmgextended.com">MiniGUI Software Page</a>', , TD_INFORMATION_ICON )
ELSE

   MsgInfo( 'This uses the "ShowMessage" function' + CRLF + CRLF + ;
      "Just use an additional parameter (optional) to add this extra text.", , , .F. )

ENDIF

IF lIsVistaOrLater

   nButton := VerifyYesNo( "A Verify function", ;
      'You can use the "VerifyYesNo" function', ;
      "Would you use this one?" )

   ShowMessage( , 'You answered ' + iif( nButton == 6, '"Yes"', '"No"') )

ELSE

   IF MsgYesNo( 'You can use the "VerifyYesNo" function' + CRLF + CRLF + ;
      "Would you use this one?", "Confirm" )

      MsgInfo( 'You answered "Yes"', , , .F. )

   ELSE

      MsgInfo( 'You answered "No"', , , .F. )

   ENDIF

ENDIF

IF lIsVistaOrLater

   nButton := VerifyYesNoCancel( "Another Verify function", ;
      'Or you can use the "VerifyYesNoCancel" function', ;
      "Would you use this one?" )

   ShowMessage( , 'You clicked on ' + iif( nButton == 2, '"Cancel"', iif( nButton == 6, '"Yes"', '"No"') ) )

ELSE

   nButton := MsgYesNoCancel( 'Or you can use the "VerifyYesNoCancel" function' + CRLF + CRLF + ;
      "Would you use this one?" , "Confirm" )

   MsgInfo( 'You clicked on ' + iif( nButton == -1, '"Cancel"', iif( nButton == 1, '"Yes"', '"No"') ), , , .F. )

ENDIF

IF lIsVistaOrLater

   nButton := VerifySave( , "Do you want to save your work?", ;
      "If you wish to keep any changes you should save your work." )

   ShowMessage( , 'You clicked ' + iif( nButton == 2, '"Cancel"', iif( nButton == IDYES, '"Save"', ["Don't save"]) ) )

ELSE

   nButton := MsgYesNoCancel( 'Do you want to save your work?' + CRLF + CRLF + ;
      "If you wish to keep any changes you should save your work." , "Confirm" )

   MsgInfo( 'You clicked ' + iif( nButton == -1, '"Cancel"', iif( nButton == 1, '"Save"', ["Don't save"]) ), , , .F. )

ENDIF

IF lIsVistaOrLater

   ShowErrorMessage( , 'This uses the "ShowErrorMessage" function', 'With more text here.' )

   ShowWarningMessage( , 'This uses the "ShowWarningMessage" function' )

ELSE

   MsgStop( 'This uses the "ShowErrorMessage" function' + CRLF + CRLF + ;
      "With more text here.", "Error" )

   MsgExclamation( 'This uses the "ShowWarningMessage" function', "Warning" )

ENDIF

   RETURN


FUNCTION ShowMessage( cTitle, cMainMessage, cContent, cExpandedInfo, cFooter, nIcon, nFooterIcon )

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nButton, nRadioButton
   LOCAL lVerificationFlagChecked := .F.

   hb_default( @cTitle, "Vista TaskDialog" )
   hb_default( @cMainMessage, "" )
   hb_default( @cContent, "" )
   hb_default( @cExpandedInfo, "" )
   hb_default( @cFooter, "" )
   hb_default( @nIcon, TD_INFORMATION_ICON )
   hb_default( @nFooterIcon, 0 )

   aConfig[ TDC_TASKDIALOG_FLAGS ]        := TDF_ENABLE_HYPERLINKS
   aConfig[ TDC_COMMON_BUTTON_FLAGS ]     := TDCBF_OK_BUTTON

   aConfig[ TDC_HWND ]                    := GetActiveWindow()
   aConfig[ TDC_HINSTANCE ]               := GetInstance()
   aConfig[ TDC_MAINICON ]                := nIcon

   aConfig[ TDC_WINDOWTITLE ]             := cTitle
   aConfig[ TDC_MAININSTRUCTION ]         := cMainMessage
   IF !Empty( cContent )
      aConfig[ TDC_CONTENT ]              := cContent
   ENDIF
   IF !Empty( cExpandedInfo )
      aConfig[ TDC_EXPANDEDINFORMATION ]  := cExpandedInfo
      aConfig[ TDC_EXPANDEDCONTROLTEXT ]  := "Hide details"
      aConfig[ TDC_COLLAPSEDCONTROLTEXT ] := "Show details"
   ENDIF
   IF !Empty( cFooter )
      IF !Empty( nFooterIcon )
         aConfig[ TDC_FOOTERICON ]        := nFooterIcon
      ENDIF
      aConfig[ TDC_FOOTER ]               := cFooter
   ENDIF

   aConfig[ TDC_CALLBACK ]                := {|h,n,w,l| callback( h,n,w,l )} 

   RETURN win_TaskDialogIndirect0( aConfig, @nButton, @nRadioButton, @lVerificationFlagChecked )


FUNCTION ShowErrorMessage( cTitle, cMainMessage, cContent, cExpandedInfo, cFooter )

   RETURN ShowMessage( cTitle, cMainMessage, cContent, cExpandedInfo, cFooter, TD_ERROR_ICON )


FUNCTION ShowWarningMessage( cTitle, cMainMessage, cContent, cExpandedInfo, cFooter )

   RETURN ShowMessage( cTitle, cMainMessage, cContent, cExpandedInfo, cFooter, TD_WARNING_ICON )


FUNCTION VerifySave( cTitle, cMainMessage, cContent )

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nButton, nRadioButton, nResult
   LOCAL lVerificationFlagChecked := .F.

   LOCAL aButton := { { IDYES, "&Save" }, { IDNO, "&Don't save" }, { IDCANCEL, "&Cancel" } }

   aConfig[ TDC_BUTTON ]            := Len( aButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ] := aButton

   aConfig[ TDC_HWND ]              := GetActiveWindow()
   aConfig[ TDC_HINSTANCE ]         := 0
   aConfig[ TDC_MAINICON ]          := TD_QUESTION

   hb_default( @cTitle, "Vista TaskDialog" )
   hb_default( @cMainMessage, "" )
   hb_default( @cContent, "" )

   aConfig[ TDC_WINDOWTITLE ]       := cTitle
   aConfig[ TDC_MAININSTRUCTION ]   := cMainMessage
   IF !Empty( cContent )
      aConfig[ TDC_CONTENT ]        := cContent
   ENDIF

   aConfig[ TDC_CALLBACK ]             := {|h,n,w,l| callback( h,n,w,l )} 

   nResult := win_TaskDialogIndirect0( aConfig, @nButton, @nRadioButton, @lVerificationFlagChecked )

   IF nResult == 0           // no error occurs
      RETURN nButton
   ENDIF

   RETURN nResult


STATIC FUNCTION callback( hWnd, nNotification, wParam, lParam )
   LOCAL lResult := .F.
   /*
   To prevent the task dialog from closing, the application must return FALSE,
   otherwise the task dialog is closed 
   */
   LOCAL hResp := { 1=>"OK", 2=>"CANCEL", 3=>"ABORT", 4=>"RETRY", 5=>"IGNORE", 6=>"YES", 7=>"NO", 8=>"CLOSE" }

   SWITCH nNotification
   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      IF hb_HPos( hResp, wParam ) != 0
         lResult := .T.
      ENDIF
      EXIT

   CASE TDN_HYPERLINK_CLICKED
      ShellExecute( hWnd, "open", lParam, , , SW_SHOW )
   END SWITCH

   RETURN lResult


FUNCTION VerifyYesNo( cWindowTitle, cMainMessage, cContent )

   LOCAL dwCommonButtons
   LOCAL nButton := NIL

   hb_default( @cWindowTitle, "Vista TaskDialog" )
   hb_default( @cMainMessage, "" )
   hb_default( @cContent, "" )

   dwCommonButtons := hb_BitOr( TDCBF_YES_BUTTON, TDCBF_NO_BUTTON )

   win_TaskDialog0( ,, cWindowTitle, cMainMessage, cContent, dwCommonButtons, TD_QUESTION, @nButton )

   IF ! HB_ISNIL( nButton )
      RETURN nButton
   ENDIF

   RETURN -1


FUNCTION VerifyYesNoCancel( cWindowTitle, cMainMessage, cContent )

   LOCAL dwCommonButtons
   LOCAL nButton := NIL

   hb_default( @cWindowTitle, "Vista TaskDialog" )
   hb_default( @cMainMessage, "" )
   hb_default( @cContent, "" )

   dwCommonButtons := hb_BitOr( TDCBF_YES_BUTTON, TDCBF_NO_BUTTON, TDCBF_CANCEL_BUTTON )

   win_TaskDialog0( ,, cWindowTitle, cMainMessage, cContent, dwCommonButtons, TD_QUESTION, @nButton )

   IF ! HB_ISNIL( nButton )
      RETURN nButton
   ENDIF

   RETURN -1
