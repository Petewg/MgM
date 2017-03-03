/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * MRU Demo
 * (c) 2003-2005 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"

Function Main
Local cIni := GetStartupFolder() + "\demo.ini"

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI MRU Demo (Based Upon a Contribution Of Janusz Pora)' ;
		ICON 'demo.ico' ;
		MAIN ;
		FONT 'Arial' SIZE 10 ;
		ON INTERACTIVECLOSE WinEnd_Click()

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour Power Ready!' 
		END STATUSBAR

		ON KEY CONTROL+O ACTION Get_File_Click()

		DEFINE MAIN MENU 
			POPUP '&File'
				ITEM '&Open'+chr(9)+'Ctrl+O'	ACTION Get_File_Click() IMAGE "Open.bmp"
				SEPARATOR 
				DEFINE POPUP 'Recent Files' 
				    MRU ' (Empty) '	   	INI (cIni) SECTION "Most Recent Files"
				END POPUP 
				ITEM '&Clear Recent Files'	ACTION ClearMRUList( )
				SEPARATOR 
				ITEM 'E&xit'		        ACTION WinEnd_Click()
			END POPUP
			POPUP '&Info'
				ITEM 'About'			ACTION  MsgInfo ("MiniGUI MRU Demo","A COOL Feature ;)") 
			END POPUP
		END MENU

		@ 45,10 EDITBOX Edit_1 ;
			WIDTH 610 ;
		 	HEIGHT 340 ;
			VALUE '' ;
			TOOLTIP 'EditBox'
		
	END WINDOW

	Form_1.Center

	ACTIVATE WINDOW Form_1

Return Nil


Function WinEnd_Click()
    SaveMRUFileList()
    Thiswindow.Release
Return .T.


Function Read_file(cFile)
       
   If ! File( cFile )
        MSGSTOP("File I/O error, cannot proceed")
	RETURN NIL
   ENDIF

   Form_1.Edit_1.Value := MemoRead (cFile)

   AddMRUItem( cfile , Nil )

Return NIL


Function Get_File_Click()
    LOCAL c_File := GetFile({{'Text File','*.txt'},{'All Files','*.*'}},'Get File')

    if !empty(c_File)
        Read_file(c_File)
    endif

Return NIL
