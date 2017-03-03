/*
* MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

Function Main
Local cPath := iif(IsWinNT(), System.SystemFolder, System.WindowsFolder) + "\"
Local cFile1 := cPath + "notepad.exe"
Local cFile2 := cPath + "calc.exe"
Local cFile3 := cPath + iif(IsWinNT(), "mspaint.exe", "pbrush.exe")
Local cFile4 := "appwiz.cpl"
Local cFile5 := System.SystemFolder + "\shell32.dll"
Local cFile6 := cPath + IF(_HMG_IsXP, "xpsp2res.dll", "comres.dll")

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 300 ;
		TITLE 'System ToolBox' ;
                MAIN

                DEFINE BUTTON BTN01
                  ROW   10
                  COL   10
                  ICON  cFile1
                  EXTRACT 0
                  ACTION ExecTest( cFile1 )
                  WIDTH 100
                  HEIGHT 42
                  TOOLTIP 'Run Notepad'
                  DEFAULT .T.
                END BUTTON

                DEFINE BUTTONEX BTN02
                  ROW   60
                  COL   10
                  CAPTION  'Calc'
                  LEFTTEXT .T.
                  ICON  cFile2
                  ACTION ExecTest( cFile2 )
                  WIDTH 100
                  HEIGHT 42
                  TOOLTIP 'Run Calculator'
                  NOHOTLIGHT .T.
                  NOXPSTYLE .T.
                END BUTTONEX

		@ 110,10 BUTTON BTN03             ;
			ICON cFile3               ;
			EXTRACT 0                 ;
			ACTION ExecTest( cFile3 ) ;
			WIDTH 100 HEIGHT 42       ;
                        TOOLTIP 'Run Paint'
IF IsWinXPorLater()
		@ 160,10 BUTTON BTNCANCEL         ;
			ICON cFile5               ;
                        EXTRACT 219               ;
			ACTION ThisWindow.Release ;
			WIDTH 100 HEIGHT 42       ;
                        TOOLTIP 'Cancel the program'
Else
		@ 160,10 BUTTON BTNCANCEL         ;
			CAPTION "Cancel"          ;
			ACTION ThisWindow.Release ;
			WIDTH 100 HEIGHT 28       ;
                        TOOLTIP 'Cancel the program'
EndIf
		@ 10,130 BUTTON BTN04             ;
			ICON cFile4               ;
			EXTRACT 0                 ;
			ACTION IF(IsWinXPorLater(), ExecTest( cFile4 ), Control2( "shell32.dll,Control_RunDLL appwiz.cpl,,2" ) ) ;
			WIDTH 100 HEIGHT 42

		@ 60,130 BUTTON BTN05             ;
			ICON cFile5               ;
			EXTRACT iif(IsWinNT(), 21, 35) ;
			ACTION ExecTest( "control.exe" ) ;
			WIDTH 100 HEIGHT 42

		@ 110,130 BUTTON BTN06            ;
			ICON cFile6               ;
                        EXTRACT 1                 ;
			ACTION IF(IsWinXPorLater(), Control( "sysdm.cpl,,1" ), Control2( "shell32.dll,Control_RunDLL appwiz.cpl,,1" ) ) ;
			WIDTH 100 HEIGHT 42

		ON KEY ESCAPE ACTION ThisWindow.Release

        END WINDOW

        CENTER WINDOW Win_1
        ACTIVATE WINDOW Win_1

Return Nil

*--------------------------------------------------------*
Procedure ExecTest( cFile )
*--------------------------------------------------------*

	EXECUTE FILE (cFile)

Return

#define SW_SHOW		5

*--------------------------------------------------------*
Static Function Control( cString )
*--------------------------------------------------------*

Return ShellExecute( Application.Handle, nil,'control.exe', cString, nil, SW_SHOW )

*--------------------------------------------------------*
Static Function Control2( cString )
*--------------------------------------------------------*

Return ShellExecute( Application.Handle, nil,'rundll32.exe', cString, nil, SW_SHOW )
