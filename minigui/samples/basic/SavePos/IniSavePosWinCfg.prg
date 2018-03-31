/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2012 Janusz Pora <januszpora@onet.eu>
 *
 * 2014: Modified by Andrey Verchenko <verchenkoag@gmail.com>. Dmitrov, Russia
 *
*/

#include "minigui.ch"

// store config file to current folder
#define INI_FILE_WIN_CFG  ChangeFileExt( Application.ExeName, ".cfg" ) 
// OR store config file to temporary folder
//#define INI_FILE_WIN_CFG  GetTempFolder() + "\" + cFileNoPath( ChangeFileExt( Application.ExeName, ".cfg" ) )


Procedure Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 ;
		HEIGHT 300 ;
		TITLE 'Example: saving and restoring of window position through the ini file' ;
	        BACKCOLOR {0,176,240} ;
              	MAIN ;
		ON INIT IniGetPosWindow() ;
		ON RELEASE IniSetPosWindow()

		@ 20, 20 LABEL Label_1 ;
                  VALUE 'Change the position of this window, exit the program and then restart' ;
                  WIDTH 400 HEIGHT 50 TRANSPARENT

		@ 100, 10 BUTTON Button_1 ;
		  CAPTION 'Exit' ACTION	ThisWindow.Release DEFAULT

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

/////////////////////////////////////////////////////////////////////
Function IniGetPosWindow( FormName, cProgName )
   Local cSection, actpos := {0,0,0,0}
   Local col , row , width , height
   Local cPathFileConfig

   Default FormName := _HMG_ThisFormName
   Default cProgName := GetProperty(FormName, "Title")

   cPathFileConfig := INI_FILE_WIN_CFG 

   GetWindowRect( GetFormHandle( FormName ), actpos )
   cSection := FormName

   IF FILE( cPathFileConfig )
      col    := VAL( GetIni( cSection , "col"    , "0", cPathFileConfig ) )
      row    := VAL( GetIni( cSection , "row"    , "0", cPathFileConfig ) )
      width  := VAL( GetIni( cSection , "width"  , "0", cPathFileConfig ) )
      height := VAL( GetIni( cSection , "height" , "0", cPathFileConfig ) )

      col    := IFNIL( col, actpos[1], col )
      row    := IFNIL( row, actpos[2], row )
      width  := IFNIL( width, actpos[3] - actpos[1], width )
      height := IFNIL( height, actpos[4] - actpos[2], height )
      // If there are no sections, ie Variables are 0
      IF width > 0 .AND. height > 0
         MoveWindow( GetFormHandle( FormName ) , col , row , width , height , .t. )
      ENDIF
   ENDIF 

Return Nil

/////////////////////////////////////////////////////////////////////
Function IniSetPosWindow( FormName, cProgName )
   Local cSection, actpos := {0,0,0,0}
   Local col , row , width , height
   Local cText, cPathFileConfig

   Default FormName := _HMG_ThisFormName
   Default cProgName := GetProperty(FormName, "Title")

   cPathFileConfig := INI_FILE_WIN_CFG 

   GetWindowRect( GetFormHandle( FormName ), actpos )
   cSection := FormName

   IF ! File( cPathFileConfig )
      cText := "[Information]" + CRLF
      cText += "Program = " + Application.ExeName + CRLF
      cText += "Free Open Source Software = " + Version() + CRLF
      cText += "Free Compiler = " + hb_compiler() + CRLF
      cText += "Free Library  = " + MiniGUIVersion() + CRLF
      cText += CRLF + CRLF
      HB_MemoWrit( cPathFileConfig, cText )
   ENDIF

   col    := actpos[1]
   row    := actpos[2]
   width  := actpos[3] - actpos[1]
   height := actpos[4] - actpos[2]

   WriteIni( cSection, "TitleWin" , cProgName       , cPathFileConfig )
   WriteIni( cSection, "col"      , HB_NToS(col)    , cPathFileConfig )
   WriteIni( cSection, "row"      , HB_NToS(row)    , cPathFileConfig )
   WriteIni( cSection, "width"    , HB_NToS(width)  , cPathFileConfig )
   WriteIni( cSection, "height"   , HB_NToS(height) , cPathFileConfig )

Return Nil

*--------------------------------------------------------*
STATIC Function GetIni( cSection, cEntry, cDefault, cFile )
RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFile )

*--------------------------------------------------------*
STATIC Function WriteIni( cSection, cEntry, cValue, cFile )
RETURN( WritePrivateProfileString( cSection, cEntry, cValue, cFile ) )
