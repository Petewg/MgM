/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialogIndirect0 with command links, hyperlinks and
 * callback function
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch"

#translate @P => @Print()

MEMVAR aCustButton

PROCEDURE main()

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nResult
   LOCAL nButton := Nil

   PUBLIC aCustButton := { ;
                          { 1101, "Common Buttons Sample", @P }, ;
                          { 1102, "Counter Sample", @P }, ;
                          { 1103, "Elevation Requied Sample", @P }, ;
                          { 1104, "Enable/Disable Sample", @P }, ;
                          { 1105, "Error Sample", @P }, ;
                          { 1106, "Icons Sample", @P }, ;
                          { 1107, "Progress Sample", @P }, ;
                          { 1108, "Progress Effects Sample", @P }, ;
                          { 1109, "Timer Sample", @P }, ;
                          { 1110, "Update Text Sample", @P } ;
                         }

   aConfig[ TDC_TASKDIALOG_FLAGS ]  := hb_bitOr( TDF_ALLOW_DIALOG_CANCELLATION, ;
                                                 TDF_CAN_BE_MINIMIZED, ;
                                                 TDF_USE_COMMAND_LINKS, ;
                                                 TDF_ENABLE_HYPERLINKS )

   aConfig[ TDC_BUTTON ]            := Len( aCustButton )
   aConfig[ TDC_TASKDIALOG_BUTTON ] := aCustButton

   aConfig[ TDC_WINDOWTITLE ]       := "TaskDialog Samples"
   aConfig[ TDC_MAININSTRUCTION ]   := "Pick a sample to try:"
   aConfig[ TDC_FOOTER ]            := 'Inspired by <A HREF="http://weblogs.asp.net/kennykerr/">Kenny Kerr</A>'

   aConfig[TDC_CALLBACK] := {|h,n,w,l| __cb_main( h,n,w,l )} 

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


STATIC PROCEDURE Print( cMsg )
   MsgInfo( cMsg + " selected", , , .F. )


STATIC FUNCTION __cb_main( hWnd, nNotification, wParam, lParam )
   /*
   To prevent the task dialog from closing, the application must return FALSE,
   otherwise the task dialog is closed 
   */
   LOCAL lResult := .F.
   LOCAL nIndex

   HB_SYMBOL_UNUSED( hWnd )

   SWITCH nNotification
   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      IF wParam == IDCANCEL
         lResult := .T.
      ELSE
         IF ( nIndex := AScan( aCustButton, {|a| Len( a ) >= 3 ;
               .AND. a[ 1 ] == wParam .AND. HB_ISSTRING( a[ 2 ] ) .AND. HB_ISSYMBOL( a[ 3 ] ) } ) ) > 0
            aCustButton[nIndex][3]:exec( aCustButton[nIndex][2] )
         ENDIF
      ENDIF
      EXIT

   CASE TDN_HYPERLINK_CLICKED
      // Indicates that a hyperlink has been selected. A pointer to the link text is specified by lParam.
      ShellExecute( hWnd, "open", lParam, , , SW_SHOW ) 

      EXIT

   END SWITCH

   RETURN lResult
