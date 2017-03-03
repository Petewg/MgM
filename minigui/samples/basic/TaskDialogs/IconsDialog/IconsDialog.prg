/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialogIndirect0 with main/footer icons and radio buttons
 *
 * Copyright 2016, Petr Chornyj
*/

#define _HMG_OUTLOG

#include "minigui.ch"
#include "TaskDlgs.ch" 

PROCEDURE main()

   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL aRadioButton := { ;
                          { TD_NO_ICON, "None" }, ;
                          { TD_WARNING_ICON, "Warning" }, ;
                          { TD_ERROR_ICON, "Error" }, ;
                          { TD_INFORMATION_ICON, "Information" }, ;
                          { TD_SHIELD_ICON, "Shield" }, ;
                       /* { TD_SHIELD_WARNING_ICON, "ShieldWarning" }, ;
                          { TD_SHIELD_ERROR_ICON, "ShieldError" }, ;
                          { TD_SHIELD_SUCCESS_ICON, "ShieldSucces" }, ; */ ;
                          { 101, "Custom" } ;
                         }
   LOCAL aConfig := Array( TDC_CONFIG )

   aConfig[ TDC_HINSTANCE ]        := GetInstance()
   aConfig[ TDC_TASKDIALOG_FLAGS ] := TDF_ALLOW_DIALOG_CANCELLATION  /* [x] button in caption */

   aConfig[ TDC_WINDOWTITLE ]      := "Icons Sample"
   aConfig[ TDC_MAININSTRUCTION ]  := "MainInstruction"
   aConfig[ TDC_FOOTER ]           := "Footer"

   aConfig[ TDC_RADIOBUTTON ]            := Len( aRadioButton )
   aConfig[ TDC_TASKDIALOG_RADIOBUTTON ] := aRadioButton

   aConfig[ TDC_MAINICON ]   := TD_NO_ICON
   aConfig[ TDC_FOOTERICON ] := TD_NO_ICON

   aConfig[TDC_CALLBACK]     := {|h,n,w,l| cb_common( h,n,w,l )} 

   ERASE "_debug.txt" 
   SET LOGFILE TO "_debug.txt" 

   nResult := win_TaskDialogIndirect0( aConfig, @nButton, NIL, NIL )

   IF nResult == S_OK /* no error occurs */
      ? hb_strFormat( "Button with ID %1$d pressed", nButton ) 
   ELSE
      ? hb_strFormat( "win_TaskDialogIndirect0() returns %1$d", nResult )
   END IF

   ShellExecute( 0, "open", "_debug.txt", , , SW_SHOW ) 

   RETURN


STATIC FUNCTION cb_common( pWnd, nNotification, nWParam, nLParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL lResult := .F.

   HB_SYMBOL_UNUSED( nLParam )

   SWITCH nNotification
   CASE TDN_CREATED
      EXIT

   CASE TDN_DESTROYED
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      lResult := If( nWParam == IDOK .OR. nWParam == IDCANCEL, .T., .F. )
      EXIT

   CASE TDN_RADIO_BUTTON_CLICKED
      // wParam - an int that specifies the ID corresponding to the radio button that was clicked
      ? hb_StrFormat( "Notification: TDN_RADIO_BUTTON_CLICKED. ID of the button is %d.", nWParam )
      _UpdateMainIcon( pWnd, nWParam )
      _UpdateFooterIcon( pWnd, nWParam )

      EXIT

   END SWITCH   

   RETURN lResult
