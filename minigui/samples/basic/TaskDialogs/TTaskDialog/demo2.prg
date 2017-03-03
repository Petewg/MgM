/* 
   demo2.prg - some aspect of using of TaskDialog 
 */ 
 
#include "minigui.ch" 
#include "hbclass.ch" 
#include "TaskDlgs.ch" 

#define APP_TITLE   'TaskDialog with expandable text & footer with hyperlink'

#define COUNT_TIMES 20

PROCEDURE main() 

   LOCAL cMsg
   LOCAL oDialog := CreateCustomDialog()

   WITH OBJECT oDialog

      :Instruction := "The Timed Dialog will be closed automatically after " + hb_NtoS( COUNT_TIMES ) + " secs!" 
      :timeoutMS   := COUNT_TIMES * 1000

      :ShowDialog() 

      cMsg := If( :TimedOut(), "Time out!", "Selected button #" + hb_NtoS( :SelectedButton() ) )

   ENDWITH 

   MsgInfo( cMsg, "Info" )

   RETURN 

///////////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateCustomDialog()

   LOCAL oDialog := TaskDialog() 

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

      :CommonButtons := hb_bitOr( TDCBF_YES_BUTTON, TDCBF_NO_BUTTON )
      :EnableHyperlinks := .T.

   ENDWITH 

   RETURN oDialog
