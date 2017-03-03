/* 
  demo.prg - some aspect of using of TaskDialog
 */ 
 
#include "minigui.ch" 
#include "hbclass.ch" 
#include "TaskDlgs.ch" 

#define APP_TITLE 'TaskDialog with expandable text & footer with hyperlink'

PROCEDURE main() 

   LOCAL oDialog := CreateCustomDialog()

   WITH OBJECT oDialog

      :CallBackBlock := {|o,n,w,l| __cb_Dialog( o,n,w,l )}

      IF :ShowDialog() ; ShowResult( oDialog )
      ELSE
         IF :nResult == E_NOTIMPL // Not yet implemented
            MsgInfo( "Your's OS is " + OS() + CRLF + "TaskDialog() works only on Vista (or later version of M$ Windows)" )
         ELSEIF :nResult == E_INVALIDARG
            MsgInfo( "Epic fail..",,, .F. )
         ENDIF
      ENDIF

   ENDWITH 
 
   RETURN 

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateCustomDialog()

   LOCAL oDialog := TaskDialog() 

   WITH OBJECT oDialog

      :Title             := APP_TITLE
      :Instruction       := 'What do you think about of the Windows Vista TaskDialog?' 
      :Content           := 'The new TaskDialog provides a standard & enhanced way for interacting with the user' 
      :Footer            := 'Optional footer text with an icon and even <A HREF="http://hmgextended.com/">hyperlink</A> can be included' 
      :MainIcon          := TD_QUESTION 
      :FooterIcon        := TD_WARNING_ICON 
      :ExpandedInfo      := "Any expanded content text for the task dialog is shown " + ; 
                            "here and the text will automatically wrap as needed." 
      :CollapsedCtrlText := "Click to see more" 
      :ExpandedCtrlText  := "Hide Expanded Text" 

      :CommonButtons := hb_bitOr( TDCBF_YES_BUTTON, TDCBF_NO_BUTTON )

      :AllowDialogCancellation := .T.
      :EnableHyperlinks := .T.

   ENDWITH 

   RETURN oDialog

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION __cb_Dialog( oSender, nNotification, wParam, lParam ) 
   /* 
   To prevent the task dialog from closing, the application must return FALSE, 
   otherwise the task dialog is closed  
   */ 
   LOCAL lResult := .F.
   LOCAL nPos
   LOCAL hResp := { 3=>"ABORT", 4=>"RETRY", 5=>"IGNORE", 6=>"YES", 7=>"NO", 8=>"CLOSE" } 

   SWITCH nNotification 
   CASE TDN_BUTTON_CLICKED 
      // wParam - an int that specifies the ID of the button or comand link that was selected 
      IF ( nPos := hb_HPos( hResp, wParam ) ) != 0 
         oSender:Cargo := hb_HValueAt( hResp, nPos )
         IF wParam == 6
            lResult := .T.
         ENDIF
      ENDIF
      EXIT
 
   CASE TDN_HYPERLINK_CLICKED 
      ShellExecute( oSender:DialogHandle(), "open", lParam, , , SW_SHOW ) 
   END SWITCH 
 
   RETURN lResult

///////////////////////////////////////////////////////////////////////////////
STATIC PROCEDURE ShowResult( obj ) 

   LOCAL  msg

   WITH OBJECT obj
      msg := "Dialog cancelation was%1$s allowed;" + CRLF
      msg += "Hyperlinks in footer was %2$s;" + CRLF 
      msg += "Verification Flag was%3$s displayed and %4$schecked;" + CRLF
      msg += "etc.." + CRLF
      msg += "Button with ID %5$d was pressed on exit; %6$s" + CRLF
      msg += "TaskDialog:lError == %7$s and TaskDialog:nResult == %8$s."

      MsgInfo( hb_strFormat( ;
            msg, ;
            If( :AllowDialogCancellation(), "", " not" ), ;
            If( :EnableHyperlinks(), "enabled", "disabled" ), ;
            If( HB_ISNIL( :VerificationText() ), " not", "" ), ; 
            If( :VerificationChecked(), "", "un" ), ;
            :SelectedButton(), ;
            If( ! Empty( :Cargo ), :Cargo + " was pressed also", "" ), ;
            If( :lError, ".T.", ".F." ), ;
            If( :nResult == S_OK, "S_OK", hb_nToS( :nResult ) ) ;
      ), , , .F. )
   ENDWITH

   RETURN
