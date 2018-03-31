/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

FUNCTION Main()
    
	DEFINE WINDOW Form_Main ;
		CLIENTAREA 320, 240 ;
		TITLE 'MiniGUI Label Alignment Demo' ;
		MAIN 

		DEFINE LABEL LABEL_1 
			ROW   40
			COL   10 
  			WIDTH 300 
			HEIGHT 40
			VALUE "Left Label"
			BACKCOLOR TEAL
			FONTNAME  "Arial" 
			FONTSIZE 24 
			FONTCOLOR WHITE            
		END LABEL

		DEFINE LABEL Label_2
			ROW   100
			COL   10
			WIDTH 300 
			HEIGHT 40
			VALUE "Left Label"            
			BACKCOLOR YELLOW
			FONTNAME "Arial"
			FONTSIZE 12
			FONTCOLOR BLACK
			VCENTERALIGN .T.
		END LABEL

		DEFINE BUTTON Button_1
			ROW 160
			COL 40
			CAPTION "Change Alignment"
			WIDTH 150 
			HEIGHT 40
			ACTION ChangeAlignment()
			DEFAULT .T.
		END BUTTON

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	Form_Main.Center
	Form_Main.Activate

RETURN( NIL )


PROCEDURE ChangeAlignment() 

    IF Form_Main.Label_1.Alignment == "LEFT"
       Form_Main.Label_1.Alignment := "CENTER"
       Form_Main.Label_1.Value := "Center Label"
    
       Form_Main.Label_2.Alignment := "RIGHT"
       Form_Main.Label_2.Value := "Right Label"  
       Form_Main.Button_1.Caption := "Click Again"
    ELSE
       Form_Main.Label_1.Alignment := "LEFT"
       Form_Main.Label_1.Value := "Left Label"
    
       Form_Main.Label_2.Alignment := "LEFT"
       Form_Main.Label_2.Value := "Left Label"    
       Form_Main.Button_1.Caption := "Change Alignment"
    ENDIF   
    
RETURN
