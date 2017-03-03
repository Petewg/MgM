/* 
 * MINIGUI - Harbour Win32 GUI library Demo
 * An example of using of win_TaskDialog0() & SimpleTaskDialog() Class Function
 * an callback function
 *
 * Copyright 2016, Petr Chornyj
*/

#include "minigui.ch"
#include "TaskDlgs.ch"

#define ALL_COMMON_BUTTONS  TDCBF_OK_BUTTON, ;
                            TDCBF_CANCEL_BUTTON, ;
                            TDCBF_YES_BUTTON, ;
                            TDCBF_NO_BUTTON, ;
                            TDCBF_RETRY_BUTTON, ;
                            TDCBF_CLOSE_BUTTON

PROCEDURE main()

   LOCAL cTitle       := "The title of the TaskDialog Window"

   LOCAL cInstruction := "win_TaskDialog0() - Creates, displays, and operates a task dialog." + CRLF +;
                         "Icon ID: " + hb_NToS( TD_SHIELD_BLUE_ICON )

   LOCAL     cContent := "The task dialog contains application-defined message text and title," +;
                         "icons, and any combination of predefined push buttons." +;
                          CRLF +;
                          "This function does not support the registration of a callback function to receive notifications." + ;
                          CRLF +;
                          "Some kind of formatting, like newlines (EOLs), should optionally " +;
                          "be done by developer, in order to achieve a more satisfactory format of text. " +;
                          CRLF + CRLF +;
                          "Enjoy with Harbour MiniGUI Extended Edition Library!" +;
                          CRLF +; 
                          "Copyright (c) 2005-2016 MiniGUI Team. All rights reserved." +;
                          CRLF + CRLF + ;
                          "Important notice: TaskDialog is available on Vista or later Windows versions. "

   LOCAL nCommonButtons := hb_bitOr( ALL_COMMON_BUTTONS )
   LOCAL nResult
   LOCAL nButton := NIL

   /* standard Xbase procedural programming */

   IF IsVistaOrLater()
      nResult := win_TaskDialog0( , , cTitle, cInstruction, cContent, nCommonButtons, TD_SHIELD_BLUE_ICON, @nButton )

      IF nResult == S_OK // 0
         MsgInfo( hb_strFormat( "Button with ID %d was pressed on exit", nButton ), , , .F. )
      ELSEIF nResult == E_INVALIDARG
         // Wow! Again ?!
      ENDIF
   ELSE
      MsgInfo( "Your's OS is " + OS() + CRLF + "TaskDialog() works only on Vista (or later version of Windows)", , , .F. )
   ENDIF

   /* and now we can try it again with in OOP style */

   WITH OBJECT SimpleTaskDialog()
      ( :New( cTitle + " (OOP)", cInstruction, cContent, nCommonButtons, TD_SHIELD_BLUE_ICON ) )

      IF :Execute()
         MsgInfo( hb_strFormat( "Button with ID %d was pressed on exit.", :nButtonResult ), , , .F. )
      ELSE
         IF :nResult == E_NOTIMPL // Not implemented
            MsgInfo( "Your's OS is " + OS() + CRLF + "TaskDialog() works only on Vista (or later version of Windows)", , , .F. )
         ELSEIF :nResult == E_INVALIDARG
            // Wow! Again ?!
         ENDIF
      ENDIF
   ENDWITH
