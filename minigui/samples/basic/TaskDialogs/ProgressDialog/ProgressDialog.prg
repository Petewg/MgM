/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialogIndirect0 with custom buttons and progress bar
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch"

MEMVAR nMaxRange
MEMVAR lReset
      
PROCEDURE main()

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL aCustButton := { { 1100, "Reset" } }

   PUBLIC nMaxRange := 5000
   PUBLIC lReset    := .f.

   aConfig[ TDC_WINDOWTITLE ]       := "Progress Sample"
   aConfig[ TDC_TASKDIALOG_FLAGS ]  := hb_bitOr( TDF_SHOW_PROGRESS_BAR, TDF_CALLBACK_TIMER, TDF_ALLOW_DIALOG_CANCELLATION )
   aConfig[ TDC_BUTTON ]            := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ] := aCustButton
   aConfig[TDC_CALLBACK]            := {|h,n,w,l| __cb_progress( h,n,w,l )} 

   nResult := win_TaskDialogIndirect0( aConfig, @nButton, NIL, NIL )

   IF nResult == NOERROR 
      MsgInfo( hb_strFormat( "Button with ID %d was pressed", nButton ), , , .F. ) 
   ELSE
      IF nResult != E_OUTOFMEMORY
         MsgStop( hb_strFormat( "ERROR: TaskDialogIndirect() => %d", nResult ), , , .F. ) 
      ELSE
         // Do Something
         QUIT
      ENDIF
   ENDIF


STATIC FUNCTION __cb_progress( hWnd, nNotification, wParam, lParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL  lResult := .F.

   HB_SYMBOL_UNUSED( lParam )

   SWITCH nNotification
   CASE TDN_CREATED
      _SetProgressBarRange( hWnd, 0, nMaxRange )
      EXIT

   CASE TDN_TIMER
      IF ( nMaxRange >= wParam )
         _SetMainInstruction( hWnd, hb_strFormat( "%d%%", wParam / nMaxRange * 100 ) ) 
         _SetProgressBarPos( hWnd, wParam )
         lResult := !lReset
         lReset  := .F.
      ELSE 
         lReset := .T.
      END IF      
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      lResult := .T.
      EXIT
   END SWITCH   

   RETURN lResult
