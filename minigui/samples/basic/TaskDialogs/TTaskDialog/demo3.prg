/* 
   demo3.prg - Using of the inheritance for TaskDialog 
 */ 
 
#include "minigui.ch" 
#include "hbclass.ch" 
#include "TaskDlgs.ch" 

#define APP_TITLE          'TaskDialog with expandable text & footer with hyperlink'
#define BUTTON_CAPTION_RU  'ÎÊ' 
#define BUTTON_CAPTION_EN  'OK' 

#define COUNT_TIMES 20

///////////////////////////////////////////////////////////////////////////////
CREATE CLASS TTimedTaskDialog FUNCTION TimedTaskDialog FROM TaskDialog 
///////////////////////////////////////////////////////////////////////////////
   EXPORTED: 
   VAR lUserActivity INIT .F. READONLY

   METHOD UpdateButton( cCaption ) 

   METHOD Listener( hWnd, nNotification, nWParam, nLParam )
   METHOD OnHyperLinkClicked( hWnd, nNotification, nWParam, nLParam )
   METHOD OnTimer( hWnd, nNotification, nWParam, nLParam )

   PROTECTED:
   VAR hButton       INIT 0
   VAR cButtonTitle  INIT ""
   VAR cTimeCount    INIT ""
   VAR nTimeCount    INIT COUNT_TIMES

ENDCLASS 
///////////////////////////////////////////////////////////////////////////////

METHOD UpdateButton( cCaption ) CLASS TTimedTaskDialog

   hb_default( @cCaption, ::cButtonTitle )

   IF GetClassName( ::hButton, .T. ) == "Button"
     SetWindowText( ::hButton, If ( !Empty( ::cTimeCount ), cCaption + ::cTimeCount, cCaption ) )
   ENDIF

RETURN ""

METHOD Listener( hWnd, nNotification, nWParam, nLParam ) CLASS TTimedTaskDialog

   LOCAL aChilds := {}, nIndex

   HB_SYMBOL_UNUSED( nWParam )
   HB_SYMBOL_UNUSED( nLParam )

   SWITCH nNotification
   CASE TDN_RADIO_BUTTON_CLICKED
   CASE TDN_VERIFICATION_CLICKED 
   CASE TDN_HELP
   CASE TDN_EXPANDO_BUTTON_CLICKED
      ::lUserActivity := .T.
      EXIT

   CASE TDN_DIALOG_CONSTRUCTED
      EnumChildWindows( hWnd, {|hChild| AAdd( aChilds, { hChild, GetClassName( hChild ), GetWindowText( hChild ) } ), .T. } )

      nIndex := AScan( aChilds, {|e| e[2] == "Button" .AND. e[3] == BUTTON_CAPTION_RU } )
      IF nIndex > 0
         ::hButton      := aChilds[nIndex][1]
         ::cButtonTitle := aChilds[nIndex][3]

         ::UpdateButton()
      ENDIF
      EXIT

   CASE TDN_DESTROYED
      EXIT
   ENDSWITCH
   /* 
   To prevent the task dialog from closing, the application must return FALSE, 
   otherwise the task dialog is closed  
   */ 
   RETURN .F.

METHOD OnHyperLinkClicked( hWnd, nNotification, nWParam, nLParam ) CLASS TTimedTaskDialog

   HB_SYMBOL_UNUSED( nNotification )
   HB_SYMBOL_UNUSED( nWParam )

   ::lUserActivity := .T.

   ShellExecute( hWnd, "open", nLParam, , , SW_SHOW ) 

RETURN .T.

METHOD OnTimer( hWnd, nNotification, nWParam, nLParam ) CLASS TTimedTaskDialog

   LOCAL cOldVal := ::cTimeCount

   HB_SYMBOL_UNUSED( hWnd )
   HB_SYMBOL_UNUSED( nNotification )
   HB_SYMBOL_UNUSED( nLParam )
 
   IF ! ::TimedOut
      ::TimedOut := ::lUserActivity
      ::cTimeCount := hb_strFormat( " (%d)", ::nTimeCount - Int( nWParam/1000 ) )
   ELSE
     ::MainInstruction := 'What do you think about of the Windows Vista TaskDialog?' 
     ::cTimeCount := ""
   ENDIF

   IF ::cTimeCount != cOldVal         
      ::UpdateButton()
   ENDIF
  
RETURN ::TimedOut   // if .F. timer is reset

///////////////////////////////////////////////////////////////////////////////
PROCEDURE main() 
///////////////////////////////////////////////////////////////////////////////
   LOCAL cMsg
   LOCAL oDialog := CreateTimedDialog()

   WITH OBJECT oDialog
      :Instruction := "The Timed Dialog will be closed automatically after " + hb_NtoS( COUNT_TIMES ) + " secs!" 
      :timeoutMS   := COUNT_TIMES * 1000

      :ShowDialog() 

      cMsg := If( :TimedOut() .AND. ! :lUserActivity, "Time out!", "Selected button #" + hb_NtoS( :SelectedButton() ) )
   ENDWITH 

   MsgInfo( cMsg, "Info" )

RETURN 

///////////////////////////////////////////////////////////////////////////////
FUNCTION CreateTimedDialog()

   LOCAL oDialog := TimedTaskDialog() 

   WITH OBJECT oDialog

      :WindowTitle       := APP_TITLE
      :Content           := 'The new TaskDialog provides a standard & enhanced way for interacting with the user' 
      :Footer            := 'Optional footer text with an icon and even <A HREF="http://hmgextended.com/">hyperlink</A> can be included'
      :MainIcon          := TD_QUESTION 
      :FooterIcon        := TD_WARNING_ICON 
      :ExpandedInfo      := "Any expanded content text for the task dialog is shown " + ; 
                            "here and the text will automatically wrap as needed." 
      :CollapsedCtrlText := "Click to see more" 
      :ExpandedCtrlText  := "Hide Expanded Text" 

      :EnableHyperlinks  := .T.

   ENDWITH 

RETURN oDialog
///////////////////////////////////////////////////////////////////////////////

#pragma BEGINDUMP

#include <mgdefs.h>
#include "hbapiitm.h"

static BOOL CALLBACK EnumChildProc( HWND hWnd, LPARAM lParam );
///////////////////////////////////////////////////////////////////////////////
// based on http://forums.fivetechsupport.com/viewtopic.php?p=57503
HB_FUNC( ENUMCHILDWINDOWS )
{
   HWND hWnd = ( HWND ) HB_PARNL( 1 );
   PHB_ITEM pCodeBlock = hb_param( 2, HB_IT_BLOCK );

   if( IsWindow( hWnd ) && pCodeBlock )
   {
      hb_retl( EnumChildWindows( hWnd, EnumChildProc, ( LPARAM ) pCodeBlock ) ? HB_TRUE : HB_FALSE );
   }
}

static BOOL CALLBACK EnumChildProc( HWND hWnd, LPARAM lParam )
{
   PHB_ITEM pCodeBlock = ( PHB_ITEM ) lParam;
   PHB_ITEM pHWnd = hb_itemPutNInt( NULL, ( LONG_PTR ) hWnd );

   if( pCodeBlock )
   {
      hb_evalBlock1( pCodeBlock, pHWnd );
   }

   hb_itemRelease( pHWnd );

   return( ( BOOL ) hb_parl( -1 ) );
}

#pragma ENDDUMP
