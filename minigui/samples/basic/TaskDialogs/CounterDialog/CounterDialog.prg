/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of TaskDialogIndirect0 with custom buttons and callback function
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch"

STATIC s_nCounter
      
PROCEDURE main()

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL aCustButton  := { ;
                          { 1100, "Increment" }, ;
                          { 1101, "Decrement" } ;
                         }

   aConfig[ TDC_WINDOWTITLE ]       := "Counter Sample"
   aConfig[ TDC_TASKDIALOG_FLAGS ]  := TDF_ALLOW_DIALOG_CANCELLATION  /* [x] button in caption */
   aConfig[ TDC_BUTTON ]            := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ] := aCustButton

   aConfig[TDC_CALLBACK] := {|h,n,w,l| __cb_counter( h,n,w,l )}

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


STATIC FUNCTION __cb_counter( hWnd, nNotification, wParam, lParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL lResult := .F.

   HB_SYMBOL_UNUSED( lParam )

   SWITCH nNotification
   CASE TDN_CREATED
      s_nCounter := 0

      _SetMainInstruction( hWnd, hb_strFormat( "%d", s_nCounter ) )
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      IF wParam == 1100;         s_nCounter += 1
      ELSEIF wParam == 1101;     s_nCounter -= 1
      ELSEIF wParam == IDCANCEL; lResult := .T.
      ENDIF

      IF ! lResult
         _UpdateMainInstruction( hWnd, hb_strFormat( If( s_nCounter > 0, "+%d", "%d" ), s_nCounter ) )
      ENDIF
      EXIT

   END SWITCH   

   RETURN lResult
