/* 
 * MiniGUI Demonstration of icons from the library shell32.dll
 * 
 * Copyright 2013-2017 Grigory Filatov <gfilatov@inbox.ru>
*/ 

#include "minigui.ch" 
 
Procedure MAIN 
LOCAL cIconDll  := System.SystemFolder + "\shell32.dll" 
LOCAL cIconSave := System.TempFolder + '\temp.ico'
//LOCAL cIconSave := GetStartUpFolder() + '\temp.ico'
 
SET MULTIPLE OFF WARNING 
 
// icon with number 90 to write along the path 
IF !SaveIcon( cIconSave, cIconDll, 90 )
   MsgInfo( "Icon is NOT saved!", "Error" )
ENDIF 
 
SET DEFAULT ICON TO cIconSave 
 
DEFINE WINDOW Form_1 ; 
        AT 50,50                ;
        WIDTH 660 HEIGHT 450    ;
	TITLE "This is icon #90 from the file - " + cIconDll ;
	MAIN                    ;
        BACKCOLOR ORANGE        ;
	ON RELEASE Ferase( cIconSave )

END WINDOW 

Form_1.Activate()

Return

/////////////////////////////////////////////////////////////////////////////////
#include <saveicon.c>
