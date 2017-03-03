/* 
  TTaskDlg.prg  
 */ 
 
#include "minigui.ch" 
#include "hbclass.ch" 
#include "TaskDlgs.ch" 

PROCEDURE main() 

   LOCAL oDialog := TaskDialog()
   /*
   WITH OBJECT oDialog
      :Title   := 'Simple TaskDialog'
      :Content := 'A simple text only function of TaskDialog'

      :Execute()
   ENDWITH
   */

   WITH OBJECT oDialog
      :Flags             := hb_bitOr( TDF_ALLOW_DIALOG_CANCELLATION, TDF_ENABLE_HYPERLINKS )
      //:Title             := 'TaskDialog with expandable text & footer with hyperlink' 
      :Instruction       := 'What do you think about of the Windows Vista TaskDialog?' 
      :Content           := 'The new TaskDialog provides a standard & enhanced way for interacting with the user' 
      :Footer            := 'Optional footer text with an icon and even <A HREF="http://hmgextended.com/">hyperlink</A> can be included' 
      :MainIcon          := TD_QUESTION 
      :FooterIcon        := TD_WARNING_ICON 
      :ExpandedInfo      := "Any expanded content text for the task dialog is shown " + ; 
                            "here and the text will automatically wrap as needed." 
      :CollapsedCtrlText := "Click to see more" 
      :ExpandedCtrlText  := "Hide Expanded Text" 

      :CallBackBlock := {|o,n,w,l| __cb_Dialog( o,n,w,l )}
 
      IF :Execute()
         ShowDialogResult( oDialog )
      ELSE
         IF :nResult == E_NOTIMPL // Not implemented
            MsgInfo( "Your's OS is " + OS() + CRLF + "TaskDialog() works only on Vista (or later version of M$ Windows)", , , .F. )
         ELSEIF :nResult == E_INVALIDARG
            // Wow! Again ?!
         ENDIF
      ENDIF
   ENDWITH 
 
   RETURN 


STATIC FUNCTION __cb_Dialog( oSender, nNotification, wParam, lParam ) 
   /* 
   To prevent the task dialog from closing, the application must return FALSE, 
   otherwise the task dialog is closed  
   */ 
   LOCAL lResult := .F. 
   LOCAL nPos
   LOCAL hResp := { /*1*/ IDOK=>"OK", /*2*/ IDCANCEL=>"CANCEL", 3=>"ABORT", 4=>"RETRY", 5=>"IGNORE", 6=>"YES", 7=>"NO", 8=>"CLOSE" } 

   SWITCH nNotification 
   CASE TDN_CREATED
      //IF __objGetClsName( oSender ) == "TTASKDIALOG" .OR. __objDerivedFrom( oSender, "TTASKDIALOG" )
      IF HB_ISOBJECT( oSender ) .AND. oSender:ClassName() == "TTASKDIALOG"
         oSender:Title := 'TaskDialog with expandable text & footer with hyperlink'
      ENDIF
      EXIT

   CASE TDN_BUTTON_CLICKED 
      // wParam - an int that specifies the ID of the button or comand link that was selected 
      IF ( nPos := hb_HPos( hResp, wParam ) ) != 0 
         oSender:Cargo := hb_HValueAt( hResp, nPos )

         IF wParam == IDOK .OR. wParam == IDCANCEL
            lResult := .T. 
         ENDIF 
      ENDIF 
      EXIT 
 
   CASE TDN_HYPERLINK_CLICKED 
      ShellExecute( oSender:hWnd, "open", lParam, , , SW_SHOW ) 
   END SWITCH 
 
   RETURN lResult


STATIC PROCEDURE ShowDialogResult( obj ) 

   LOCAL  msg

   WITH OBJECT obj
      msg := "Hyperlinks in footer was %1$s;" + CRLF 
      msg += "Dialog cancelation was%2$s allowed;" + CRLF
      msg += "Verification Flag was%3$s displayed and %4$schecked;" + CRLF
      msg += "etc.." + CRLF
      msg += "Button with ID %5$d(%6$s) was pressed on exit;" + CRLF
      msg += "TaskDialog:lError == %7$s and TaskDialog:nResult == %8$s."

      MsgInfo( hb_strFormat( ;
            msg, ;
            If( hb_bitAnd( :Flags(), TDF_ENABLE_HYPERLINKS ) != 0, "enabled", "disabled" ), ;
            If( hb_bitAnd( :Flags(), TDF_ALLOW_DIALOG_CANCELLATION ) != 0, "", " not" ), ;
            If( HB_ISNIL( :VerificationText() ), " not", "" ), ; 
            If( :lVerifyResult, "", "un" ), ;
            :nButtonResult, ;
            :Cargo, ;
            If( :lError, ".T.", ".F." ), ;
            If( :nResult == S_OK, "S_OK", hb_nToS( :nResult ) ) ;
      ), , , .F. )
   ENDWITH

   RETURN
