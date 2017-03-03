/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialogIndirect0 with radio, custom buttons and callback function
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch"

PROCEDURE main()

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL aCustButton  := { ;
                          { 1100, "Enable" }, ;
                          { 1101, "Disable" } ;
                         }
   LOCAL aRadioButton := { { 1102, "Radio button" } }

   aConfig[ TDC_WINDOWTITLE ]         := "Enable/Disable Sample"
   aConfig[ TDC_TASKDIALOG_FLAGS ]    := TDF_ALLOW_DIALOG_CANCELLATION
   aConfig[ TDC_BUTTON ]              := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ]   := aCustButton
   aConfig[ TDC_RADIOBUTTON ]            := Len( aRadioButton )
   aConfig[ TDC_TASKDIALOG_RADIOBUTTON ] := aRadioButton

   aConfig[TDC_CALLBACK] := {|h,n,w,l| __cb_enable( h,n,w,l )} 

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

/*
*/
STATIC FUNCTION __cb_enable( hWnd, nNotification, wParam, lParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL lResult := .F.

   HB_SYMBOL_UNUSED( lParam )

   SWITCH nNotification
   CASE TDN_CREATED
      _EnableButton( hWnd, 1100, .F. )
      _EnableRadioButton( hWnd, 1102, .T. )
      EXIT

   CASE TDN_DESTROYED
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      IF wParam == 1100
         _EnableButton( hWnd, 1100, .F. )
         _EnableButton( hWnd, 1101, .T. )
         _EnableRadioButton( hWnd, 1102, .T. )
      ELSEIF wParam == 1101
         _EnableButton( hWnd, 1100, .T. )
         _EnableButton( hWnd, 1101, .F. )
         _EnableRadioButton( hWnd, 1102, .F. )
      ELSEIF wParam == 1102
      END IF
      lResult := If( wParam == IDCANCEL, .T., .F. )
      EXIT

   END SWITCH   

   RETURN lResult
