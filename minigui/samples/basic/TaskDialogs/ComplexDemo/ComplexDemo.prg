/*
   ComplexDemo.prg - Using of TaskDialogIndirect0() with progress bar, radiobuttons, commands links, hyperlink, 
                                                         main and footer icons, etc. and the callback function

*/

#define _HMG_OUTLOG

#include "minigui.ch"
#include "TaskDlgs.ch"

#define IDI_MAIN 101

PROCEDURE main()

   LOCAL nResult
   LOCAL nButton, nRadioButton := 2
   LOCAL lVerificationFlagChecked := .F.

   LOCAL aCustButton  := { ;
                          { 1100, "Custom Button 1" }, ;
                          { 1101, "Custom Button 2" } ;
                         }
   LOCAL aRadioButton := { ;
                          { 1000, "Radio 1" }, ;
                          { 1001, "Radio 2" } ;
                         }
   LOCAL aConfig := Array( TDC_CONFIG )

   ERASE "_debug.txt" 
   SET LOGFILE TO "_debug.txt" 

   aConfig[ TDC_TASKDIALOG_FLAGS ]     := hb_bitOr( TDF_ALLOW_DIALOG_CANCELLATION, TDF_USE_COMMAND_LINKS, TDF_ENABLE_HYPERLINKS, ;
                                                    TDF_SHOW_PROGRESS_BAR, TDF_EXPAND_FOOTER_AREA )

   aConfig[ TDC_HINSTANCE ]            := GetInstance()
   aConfig[ TDC_COMMON_BUTTON_FLAGS ]  := TDCBF_OK_BUTTON
  
   aConfig[ TDC_BUTTON ]               := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ]    := aCustButton

   aConfig[ TDC_RADIOBUTTON ]            := Len( aRadioButton )
   aConfig[ TDC_TASKDIALOG_RADIOBUTTON ] := aRadioButton

   aConfig[ TDC_MAINICON ]             := IDI_MAIN      
   aConfig[ TDC_FOOTERICON ]           := TD_SHIELD_ICON

   aConfig[ TDC_WINDOWTITLE ]          := "Task Dialog Title"
   aConfig[ TDC_MAININSTRUCTION ]      := "Main Instruction"
   aConfig[ TDC_CONTENT ]              := "Content"
   aConfig[ TDC_VERIFICATIONTEXT ]     := "Verification Text"
   aConfig[ TDC_EXPANDEDINFORMATION ]  := "Expanded information in footer." + hb_eol() + "This can also go in the top part of the dialog." 
   aConfig[ TDC_EXPANDEDCONTROLTEXT ]  := "Expanded Control Text" + hb_eol() + "on two lines"
   aConfig[ TDC_COLLAPSEDCONTROLTEXT ] := "Collapsed Control Text"
   aConfig[ TDC_FOOTER ]               := 'Footer with <A HREF="executablestring">hyperlink</A>'

   aConfig[ TDC_CALLBACK ]             := {|h,n,w,l| callback( h,n,w,l )} 

   nResult := win_TaskDialogIndirect0( aConfig, @nButton, @nRadioButton, @lVerificationFlagChecked )

   IF nResult == 0           // no error occurs
      SWITCH nButton
      CASE IDOK
         ? "Button IDOK is pressed"
         EXIT 
      OTHERWISE
         ? hb_strFormat( "Button with ID %1$d is pressed", nButton ) 
         EXIT 
      END SWITCH
      ? "Verification Flag is", If( lVerificationFlagChecked, "Checked", "UnChecked" )
   ELSE
      ? hb_strFormat( "win_TaskDialogIndirect0() returns %1$d", nResult )
   END IF

   ShellExecute( 0, "open", "_debug.txt", , , SW_SHOW ) 

   RETURN


STATIC FUNCTION callback( hWnd, nNotification, wParam, lParam )
   /*
   To prevent the task dialog from closing, the application must return FALSE,
   otherwise the task dialog is closed 
   */

   LOCAL lResult := .F.

   SWITCH nNotification
   CASE TDN_CREATED
      ? "Notification: TDN_CREATED"
      _SetProgressBarPos( hWnd, 50 )
      EXIT

   CASE TDN_DESTROYED
      ? "Notification: TDN_DESTROYED"
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      ? "Notification: TDN_BUTTON_CLICKED. ID of the button:", wParam
      IF wParam == IDOK 
         lResult := .T.
      ELSEIF wParam == IDCANCEL
         lResult := .T.
      ELSE
         _ClickRadioButton( hWnd, wParam - 100 )  
      ENDIF
      EXIT

   CASE TDN_RADIO_BUTTON_CLICKED
      // wParam - an int that specifies the ID corresponding to the radio button that was clicked
      ? "Notification: TDN_RADIOBUTTON_CLICKED. ID of the button:", wParam
      EXIT

   CASE TDN_EXPANDO_BUTTON_CLICKED 
      // the user clicks on the dialog's expando button: wParam is 1 if the dialog is expanded, or 0 if not
      ? "Notification: TDN_EXPANDO_BUTTON_CLICKED. Dialog is", If( wParam == 1, "expanded", "colapsed" )
      EXIT

   CASE TDN_HELP
      // the user presses F1 on the keyboard while the dialog has focus
      ? "Notification: TDN_HELP"
      EXIT

   CASE TDN_VERIFICATION_CLICKED
      // the user clicks the task dialog verification check box: wParam is the status of the checkbox.
      // It is 1 if the verification checkbox is checked, or 0 if it is unchecked.
      ? "Notification: TDN_VERIFICATION_CLICKED. Verification checkbox is", If( wParam == 1, "checked", "unchecked" )
      EXIT

   CASE TDN_HYPERLINK_CLICKED
      // Indicates that a hyperlink has been selected. A pointer to the link text is specified by lParam.
      ? "Notification: TDN_HYPERLINK_CLICKED. Link text is: '" + lParam + "'"
      MsgInfo( "Link text is: '" + lParam + "'", "Click!" )
      EXIT

   END SWITCH   

   RETURN lResult
