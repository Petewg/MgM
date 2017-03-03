/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialogIndirect0 with common buttons and callback function
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch" 

#define ALL_COMMON_BUTTONS  TDCBF_OK_BUTTON, ;
                            TDCBF_CANCEL_BUTTON, ;
                            TDCBF_YES_BUTTON, ;
                            TDCBF_NO_BUTTON, ;
                            TDCBF_RETRY_BUTTON, ;
                            TDCBF_CLOSE_BUTTON

PROCEDURE main()

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL nCommonButtons := hb_bitOr( ALL_COMMON_BUTTONS )

   aConfig[ TDC_WINDOWTITLE ]         := "Dialog with ALL Common Buttons and the CallBack Function"
   aConfig[ TDC_TASKDIALOG_FLAGS ]    := TDF_ALLOW_DIALOG_CANCELLATION  /* [x] button in caption */
   aConfig[ TDC_COMMON_BUTTON_FLAGS ] := nCommonButtons

   aConfig[TDC_CALLBACK] := {|h,n,w,l| __cb_common( h,n,w,l )}

   IF ( nResult := win_TaskDialogIndirect0( aConfig, @nButton, NIL, NIL ) ) == NOERROR 
      MsgInfo( hb_strFormat( "Button with ID %d was pressed", nButton ), , , .F. ) 
   ELSE
      IF nResult != E_OUTOFMEMORY
         MsgStop( hb_strFormat( "ERROR: TaskDialogIndirect() => %d", nResult ), , , .F. ) 
      ELSE
         // Do Something
         QUIT
      ENDIF
   ENDIF

   RETURN


STATIC FUNCTION __cb_common( hWnd, nNotification, wParam, lParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL lResult := .F.
   LOCAL cMainInstruction

   HB_SYMBOL_UNUSED( lParam )

   SWITCH nNotification
   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      lResult := If( wParam == IDCANCEL, .T., .F. )
      IF ! lResult
         cMainInstruction := hb_StrFormat( "Notification: TDN_BUTTON_CLICKED. ID of the button is %d.", wParam ) 
         _SetMainInstruction( hWnd, cMainInstruction )
      ENDIF
      EXIT
   END SWITCH   

   RETURN lResult
