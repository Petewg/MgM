/* 
    TTaskDialogEx.prg - Using of the inheritance for class function TaskDialog() 
 */ 
 
#include "minigui.ch" 
#include "hbclass.ch" 
#include "TaskDlgs.ch" 

CREATE CLASS TTaskDialogEx FUNCTION TaskDialogEx FROM TaskDialog 
 
   EXPORTED: 

   METHOD OnButtonClicked( hWnd, nNotification, nWParam, nLParam )
   METHOD OnCreated( hWnd, nNotification, nWParam, nLParam )
   METHOD OnDestroyed( hWnd, nNotification, nWParam, nLParam )
   // and etc..
ENDCLASS 


METHOD OnButtonClicked( hWnd, nNotification, nWParam, nLParam ) CLASS TTaskDialogEx
   /* 
   To prevent the task dialog from closing, the application must return FALSE, 
   otherwise the task dialog is closed  
   */ 
   LOCAL lResult := .F. 
 
   HB_SYMBOL_UNUSED( hWnd )
   HB_SYMBOL_UNUSED( nNotification )
   HB_SYMBOL_UNUSED( nLParam )

   IF nWParam == IDOK 
      MsgInfo( "Button OK was pressed", self:ClassName(),, .F. ) 
      lResult := .T. 
   ENDIF 

   RETURN lResult


METHOD OnCreated( hWnd, nNotification, nWParam, nLParam ) CLASS TTaskDialogEx
   // It is important!
   ::super:OnCreated( hWnd, nNotification, nWParam, nLParam )
   // Do Something
   MsgInfo( "OnCreated", self:ClassName(),, .F. ) 
   /* 
   To prevent the task dialog from closing, the application must return FALSE, 
   otherwise the task dialog is closed  
   */ 
   RETURN .F.


METHOD OnDestroyed( hWnd, nNotification, nWParam, nLParam ) CLASS TTaskDialogEx
   //It is important!
   ::super:OnDestroyed( hWnd, nNotification, nWParam, nLParam )
   // Do Something
   MsgInfo( "OnDestroyed", self:ClassName(),, .F. ) 
   /* 
   To prevent the task dialog from closing, the application must return FALSE, 
   otherwise the task dialog is closed  
   */ 
   RETURN .F.


/* 
*/ 
PROCEDURE main() 
 
   WITH OBJECT TaskDialogEx() 
 
      :Title             := 'TaskDialog with expandable text & footer with hyperlink' 
      :Instruction       := 'What do you think about of the Windows Vista TaskDialog?' 
      :Content           := 'The new TaskDialog provides a standard & enhanced way for interacting with the user' 
      :Footer            := "Optional footer text with an icon can be included" 
      :MainIcon          := TD_QUESTION 
      :FooterIcon        := TD_WARNING_ICON 
      :ExpandedInfo      := "Any expanded content text for the task dialog is shown " + ; 
                            "here and the text will automatically wrap as needed." 
      :CollapsedCtrlText := "Click to see more" 
      :ExpandedCtrlText  := "Hide Expanded Text" 

      :Execute() 
 
   ENDWITH 
 
   RETURN 

