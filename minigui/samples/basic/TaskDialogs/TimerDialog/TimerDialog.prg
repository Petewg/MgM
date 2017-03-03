/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialogIndirect0 with custom buttons, 
 * the callback function and timer
 *
 * Copyright 2016, Petr Chornyj
*/


#include "minigui.ch"
#include "TaskDlgs.ch"

MEMVAR lReset
      
PROCEDURE main()

   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL aCustButton := { { 1100, "Reset" } }

   PUBLIC lReset := .F.

   aConfig[ TDC_WINDOWTITLE ]       := "Timer Sample"
   aConfig[ TDC_TASKDIALOG_FLAGS ]  := hb_bitOr( TDF_CALLBACK_TIMER, TDF_ALLOW_DIALOG_CANCELLATION )
   aConfig[ TDC_MAININSTRUCTION ]   := "Time elapsed: 0 seconds"
   aConfig[ TDC_BUTTON ]            := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ] := aCustButton

   aConfig[TDC_CALLBACK] := {|h,n,w,l| __cb_timer( h,n,w,l )} 

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


STATIC FUNCTION __cb_timer( hWnd, nNotification, wParam, lParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL  lResult := .F.

   HB_SYMBOL_UNUSED( lParam )

   SWITCH nNotification
   CASE TDN_TIMER
      _UpdateMainInstruction( hWnd, hb_strFormat( "Time elapsed: %f seconds", wParam/1000 ) ) 
      lResult := !lReset
      lReset  := .F.
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      IF wParam == 1100
         lReset  := .T.
      ELSEIF wParam == IDCANCEL
         lResult := .T.
      END IF
      EXIT

   END SWITCH   

   RETURN lResult
