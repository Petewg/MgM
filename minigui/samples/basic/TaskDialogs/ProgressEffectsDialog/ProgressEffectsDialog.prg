/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialogIndirect0 with custom buttons and progress bar
 * with progress effects
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch"

#define PBST_NORMAL   1
#define PBST_ERROR    2
#define PBST_PAUSED   3

STATIC s_state   := PBST_NORMAL
STATIC s_marquee := .F.
      
PROCEDURE main()

   LOCAL aConfig := Array( TDC_CONFIG )
   LOCAL nResult
   LOCAL nButton := NIL
   LOCAL aCustButton := { { 1100, "Cycle State" }, { 1101, "Toggle Mode" } }

   aConfig[ TDC_WINDOWTITLE ]       := "Progress Effects"
   aConfig[ TDC_TASKDIALOG_FLAGS ]  := hb_bitOr( TDF_SHOW_PROGRESS_BAR, TDF_ALLOW_DIALOG_CANCELLATION )
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

   RETURN


STATIC FUNCTION __cb_progress( hWnd, nNotification, nWParam, nLParam )
   /*
      To prevent the task dialog from closing, the application must return FALSE,
      otherwise the task dialog is closed 
   */
   LOCAL  lResult := .F.

   HB_SYMBOL_UNUSED( nLParam )

   SWITCH nNotification
   CASE TDN_DIALOG_CONSTRUCTED
      _SetProgressBarPos( hWnd, 50 )
      UpdateInstruction( hWnd )
      EXIT

   CASE TDN_BUTTON_CLICKED
      // wParam - an int that specifies the ID of the button or comand link that was selected
      IF nWParam == 1100
         CycleState( hWnd )
      ELSEIF nWParam == 1101
         ToggleMode( hWnd )
      ELSEIF nWParam == 2 //IDCANCEL
         lResult := .T.
      ENDIF
      EXIT
   END SWITCH   

   RETURN lResult


STATIC PROCEDURE CycleState( hWnd )

   SWITCH s_state
   CASE PBST_NORMAL
      s_state := PBST_PAUSED
      EXIT
   CASE PBST_PAUSED
      s_state := PBST_ERROR
      EXIT
   CASE PBST_ERROR
      s_state := PBST_NORMAL
      EXIT
   ENDSWITCH

   _SetProgressBarState( hWnd, s_state )
   UpdateInstruction(  hWnd )

   RETURN


STATIC PROCEDURE ToggleMode( hWnd )

   s_marquee := ! s_marquee
   _SetMarqueeProgressBar( hWnd, s_marquee )

   IF s_marquee
      // Start marquee at top speed
      _SetProgressBarMarquee( hWnd, .T., 0 )
   ELSE
      _SetProgressBarPos( hWnd, 50 )
   ENDIF

   UpdateInstruction(  hWnd )

   RETURN


STATIC PROCEDURE UpdateInstruction( hWnd )

   LOCAL cMsg := ""

   SWITCH s_state
   CASE PBST_NORMAL
      cMsg += "State: Normal" + CRLF 
      EXIT
   CASE PBST_PAUSED
      cMsg += "State: Paused" + CRLF
      EXIT
   CASE PBST_ERROR
      cMsg += "State: Error" + CRLF
      EXIT
   ENDSWITCH
   cMsg += hb_StrFormat( "Marquee: %s", If( s_marquee, "True", "False" ) )

   _SetMainInstruction( hWnd, cMsg )

   RETURN
