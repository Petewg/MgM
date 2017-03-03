/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of TaskDialogIndirect0() with button requires elevation
 * ( a button have a User Account Control (UAC) shield icon, action invoked by the button requires
 * elevation )       
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch"

#define ID_ADMIN_STUFF  777


PROCEDURE main()

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL aCustButton := { { ID_ADMIN_STUFF, "Admin stuff" } }

   aConfig[ TDC_WINDOWTITLE ]       := "Elevation Required Sample"
   aConfig[ TDC_TASKDIALOG_FLAGS ]  := TDF_ALLOW_DIALOG_CANCELLATION  /* [x] button in caption */
   aConfig[ TDC_BUTTON ]            := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ] := aCustButton

   aConfig[TDC_CALLBACK] := {|h,n,w,l| __cb_elevation( h,n,w,l )} 

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
STATIC FUNCTION __cb_elevation( hWnd, nNotification, wParam, lParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL lResult := .F.

   HB_SYMBOL_UNUSED( lParam )

   SWITCH nNotification
   CASE TDN_CREATED
      _SetButtonElevationRequired( hWnd, ID_ADMIN_STUFF, .T. )
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      lResult := If( wParam == ID_ADMIN_STUFF .OR. wParam == IDCANCEL, .T., .F. )
      EXIT

   END SWITCH   

   RETURN lResult
