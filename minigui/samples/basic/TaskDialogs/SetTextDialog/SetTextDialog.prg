/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * Set/update MainInstruction, Content, ExpandedInformation, Footer from
 * an callback function
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
                          { 1100, "Update window title" }, ;
                          { 1101, "Update main instruction" }, ;
                          { 1102, "Update content" }, ;
                          { 1103, "Update footer" }, ;
                          { 1104, "Update expanded information" } ;
                         }

   aConfig[ TDC_WINDOWTITLE ]         := "Window Title"
   aConfig[ TDC_TASKDIALOG_FLAGS ]    := hb_bitOr( TDF_EXPANDED_BY_DEFAULT, TDF_ALLOW_DIALOG_CANCELLATION )
   aConfig[ TDC_FOOTER ]              := "Footer"
   aConfig[ TDC_EXPANDEDINFORMATION ] := "Expanded information"
   aConfig[ TDC_BUTTON ]              := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ]   := aCustButton

   aConfig[TDC_CALLBACK] := {|h,n,w,l| __cb_update( h,n,w,l )} 

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


STATIC FUNCTION __cb_update( pWnd, nNotification, wParam, lParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL lResult := .F.

   HB_SYMBOL_UNUSED( lParam )

   SWITCH nNotification
   CASE TDN_CREATED
      _SetMainInstruction( pWnd, "Main Instruction" )
      _SetContent( pWnd, "Content" )
      EXIT

   CASE TDN_DESTROYED
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      IF wParam == 1100
         _SetWindowTitle( pWnd, "Window Title (updated)" )
      ELSEIF wParam == 1101
         _UpdateMainInstruction( pWnd, "Main Instruction (updated)" )
      ELSEIF wParam == 1102
         _UpdateContent( pWnd, "Content (updated)" )
      ELSEIF wParam == 1103
         _UpdateFooter( pWnd, "Footer (updated)" )
      ELSEIF wParam == 1104
         _SetExpandedInformation( pWnd, "Expanded information (updated)" )
      ENDIF
      lResult := If( wParam == IDCANCEL, .T., .F. )
      EXIT
   END SWITCH   

   RETURN lResult
