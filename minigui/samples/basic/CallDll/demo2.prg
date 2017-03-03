/*
* MiniGUI DLL Demo
*/

#include "hmg.ch"
#include "hbdyn.ch"
request HB_CODEPAGE_UTF8EX
request HB_CODEPAGE_ELWIN
PROCEDURE Main

   // hb_cdpSelect( "UTF8EX")
   // hb_CdpSelect( "ELWIN" )

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON RELEASE HMG_UnloadAllDll()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Set new title' ACTION ChangeWinTitle() 
            MENUITEM 'Move Window' ACTION MoveTheWindow()
            SEPARATOR
            MENUITEM 'DownLoad file' ACTION DownLoadFile()
            SEPARATOR				
            MENUITEM "Exit" ACTION ThisWindow.Release
			END POPUP
		END MENU

	END WINDOW

   CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return

PROCEDURE ChangeWinTitle()
   STATIC newTitle := "Hello friend!"
   LOCAL cTitle := Space(1024)
   LOCAL nLen := Len( cTitle )

   // nLen := CallDll32( "USER32.DLL" , HB_DYN_CTYPE_INT, "GetWindowText", GetFormHandle( 'Win_1' ), @cTitle , nLen )
   
   nLen := CallDll32( "GetWindowTextA" , "USER32.DLL", GetFormHandle( 'Win_1' ), @cTitle , nLen )

   // IF CallDll32( "USER32.DLL" , HB_DYN_CTYPE_BOOL, "SetWindowText" , GetFormHandle ( 'Win_1' ), newTitle  )
   IF CallDll32( "SetWindowTextA" , "USER32.DLL", GetFormHandle ( 'Win_1' ), newTitle  ) > 0
   
      MsgInfo( "title changed!" + hb_EoL() + "New Title: " + newTitle )
      
   ELSE
   
      MsgInfo("title change failed!")
      
   ENDIF

   newTitle := Trim( cTitle )
 
   RETURN
   
PROCEDURE MoveTheWindow()
STATIC  lMoved := .T.
LOCAL x := Iif( lMoved, hb_RandomInt( 300, 400 ), hb_RandomInt( 100, 500 ) )
LOCAL y := Iif( lMoved, hb_RandomInt( 300, 400 ), hb_RandomInt( 100, 500 ) )

   IF CallDll32( "SetWindowPos" , "USER32.DLL", GetFormHandle ( 'Win_1' ), 0, x, y, 400, 400, 32 ) > 0
      lMoved := ! lMoved
      IF lMoved
         // CENTER WINDOW Win_1
      ENDIF
         
   ELSE
      msgInfo( "can't move")
   ENDIF
   
   RETURN

PROCEDURE DownLoadFile()

	LOCAL xRet
	
   MGM_WaitWindow( "Downloading, please wait...", .T. )
            
   xRet := CallDll32( "URLDownloadToFileA" , ;   // function name. ending 'A' stands for Ansi. use 'W' for unicode
                      "Urlmon.dll", ;            // dll
                       0, ;                      // start of URLDownloadToFile() parameters
                      "https://github.com/Petewg/MgM/archive/master.zip", ;
                      "X:\mgm.zip", 0, 0 )
   
   MGM_WaitWindow()
	
	MSGINFO( xRet )
	// URLDownloadToFile 0, "http://www.vb-helper.com/vbhelper_425_64.gif", "C:\vbhelper_425_64.gif", 0, 0
