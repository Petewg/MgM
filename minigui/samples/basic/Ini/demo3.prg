/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2014 Andrey Verchenko <verchenkoag@gmail.com>. Dmitrov, Russia
 *
*/

#include "minigui.ch"

// store config file to current folder
#define INI_FILE_WIN_CFG  ChangeFileExt( Application.ExeName, ".ini" ) 
// OR store config file to temporary folder
//#define INI_FILE_WIN_CFG  GetTempFolder() + "\" + cFileNoPath( ChangeFileExt( Application.ExeName, ".ini" ) )

Procedure Main
   PUBLIC nPubVal, cPubVal, dPubVal, lPubVal, aPubDim, aPubDim2

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 500 ;
		HEIGHT 320 ;
		TITLE 'Example: Working with ini files - 1.0' ;
              	MAIN                 ;
                NOMAXIMIZE NOSIZE    ;
                BACKCOLOR LGREEN     ;
		ON INIT ( IniSave(), IniRead() ) ;
		ON RELEASE IniSave()

		@ 30, 20 BUTTON Button_1    ;
		  CAPTION 'GetIni - all variables [Form_0]' ;
                  WIDTH 440 HEIGHT 30        ;
                  ACTION MsgDebug("List of variables section [Form_0]", ;
                     M->nPubVal, M->cPubVal, M->dPubVal, M->lPubVal, M->aPubDim, M->aPubDim2 ) 

		@ 80, 240 BUTTON Button_2    ;
		  CAPTION 'IsINI ["Form_0"]' ;
                  WIDTH 220 HEIGHT 30        ;
                  ACTION MsgDebug(IsINISection(INI_FILE_WIN_CFG, "Form_0")) 

		@ 120, 240 BUTTON Button_3    ;
		  CAPTION 'IsINI ["Form_04"]' ;
                  WIDTH 220 HEIGHT 30        ;
                  ACTION MsgDebug(IsINISection(INI_FILE_WIN_CFG, "Form_04")) 

		@ 160, 240 BUTTON Button_4  ;
		  CAPTION 'IsVarINI ["Form_04","Test_11"]' ;
                  WIDTH 220 HEIGHT 30 ;
                  ACTION MsgDebug( IsVarINISection(INI_FILE_WIN_CFG, "Form_04", "Test_11") ) 

		@ 200, 240 BUTTON Button_5  ;
		  CAPTION 'IsVarINI ["Form_04","Test_1"]' ;
                  WIDTH 220 HEIGHT 30 ;
                  ACTION MsgDebug( IsVarINISection(INI_FILE_WIN_CFG, "Form_04", "Test_1") ) 

		@ 230, 20 BUTTON Button_6 ;
		  CAPTION 'Exit' ACTION	ThisWindow.Release DEFAULT

	END WINDOW

	CENTER WINDOW Form_0

	ACTIVATE WINDOW Form_0

Return

/////////////////////////////////////////////////////////////////////
Function IniRead( FormName, cProgName )
   Local cSection, cFileIni, cStr
   Local nI, aDim
   Default FormName := ThisWindow.Name
   Default cProgName := GetProperty(FormName, "Title")

   cFileIni:= INI_FILE_WIN_CFG 
   cSection := FormName

   IF FILE( cFileIni)

      IF IsINISection(cFileIni, cSection) // there is a section
  
        M->nPubVal := VAL( GetIni( cSection , "Number"    , "0", cFileIni) )        // read a number 
        M->cPubVal := GetIni( cSection , "String"    , "", cFileIni )               // read a string
        M->dPubVal := CtoD( GetIni( cSection , "Date"    , "", cFileIni ) )         // read a date
        M->lPubVal := ( "Y" $ upper(GetIni( cSection,"Logical", "N" , cFileIni )) ) // read a logical

        //////////// the first option of reading through the array of special functions MiniGui //////////
        M->aPubDim := {}
        FOR nI := 1 TO 100
            cStr := "Array_" + HB_NToS(nI)
            IF IsVarINISection(cFileIni, cSection, cStr)
               // read a string to array
               aDim := CTOA( GetIni( cSection , cStr , '{}', cFileIni ) )
               IF LEN(aDim) > 0
                  AADD( M->aPubDim, aDim )
               ENDIF
            ENDIF
        NEXT

        ////////////////// second variant reading array /////////////////////////
        M->aPubDim2 := {}
        FOR nI := 1 TO 100
           cStr := "Dim_" + HB_NToS(nI)
           IF IsVarINISection(cFileIni, cSection, cStr)
              aDim := &( GetIni( cSection , cStr , '{}', cFileIni ) ) // read array 
              AADD( M->aPubDim2, aDim )
           ENDIF
        NEXT

      ELSE
         MsgStop("No such section ["+ cSection +"] in the file " + cFileIni )
      ENDIF

   ENDIF 


Return Nil

/////////////////////////////////////////////////////////////////////
Function IniSave( FormName, cProgName )
   Local cSection, cText, cStr, cFileIni
   Local nI, nVal, cVal, dVal, lVal, aDim
   Default FormName := ThisWindow.Name
   Default cProgName := GetProperty( FormName, "Title" )

   cFileIni:= INI_FILE_WIN_CFG 
   cSection := FormName

   IF !File( cFileIni)
      cText := "[Information]" + CRLF
      cText += "Program = " + Application.ExeName + CRLF
      cText += "Free Open Source Software = " + Version() + CRLF
      cText += "Free Compiler = " + hb_compiler() + CRLF
      cText += "Free Library  = " + MiniGUIVersion() + CRLF
      cText += CRLF + CRLF
      hb_MemoWrit( cFileIni, cText )
   ENDIF

   nVal := 12345678
   cVal := cProgName
   dVal := Date()
   lVal := .T.
   aDim := {}
   AADD( aDim, {"Number" , nVal } )
   AADD( aDim, {"String" , cVal } )
   AADD( aDim, {"Date"   , dVal } )
   AADD( aDim, {"Logical", lVal } )

   WriteIni( cSection, "Number" , HB_NToS(nVal)        , cFileIni )  // write numbers
   WriteIni( cSection, "String" , cVal                 , cFileIni )  // write string
   WriteIni( cSection, "Date"   , DtoC(dVal)           , cFileIni )  // write date
   WriteIni( cSection, "Logical", iif(lVal,"Yes","No") , cFileIni )  // write logical

   //////////// the first version of the recording array through MiniGui function ///////
   FOR nI := 1 TO LEN( aDim )
       cStr := "Array_" + HB_NToS(nI)
       WriteIni( cSection, cStr , ATOC(aDim[nI]), cFileIni ) // write array to a string
   NEXT

   ////////////////////////// second version of the recording array /////////////////////////
   FOR nI := 1 TO Len( aDim )
      cStr := "Dim_" + HB_NToS(nI)
      WriteIni( cSection, cStr , HB_ValtoExp(aDim[nI]), cFileIni ) // write array to a string
   NEXT

   ///////////////////////////// write to check the section and variables ///////////////
   WriteIni( "Form_04", "TitleWin" , "Test_section" , cFileIni )
   WriteIni( "Form_04", "Test_11"  , "Test_var_11"  , cFileIni )

Return Nil

*--------------------------------------------------------*
STATIC Function GetIni( cSection, cEntry, cDefault, cFile )
RETURN GetPrivateProfileString(cSection, cEntry, cDefault, cFile )
*--------------------------------------------------------*
STATIC Function WriteIni( cSection, cEntry, cValue, cFile )
RETURN( WritePrivateProfileString( cSection, cEntry, cValue, cFile ) )
*--------------------------------------------------------*
STATIC Function IsINISection(cIniFile, cName)
Return ( aScan( _GetSectionNames(cIniFile), {|x| UPPER(x) == UPPER(cName)} ) > 0 )
*--------------------------------------------------------*
STATIC Function IsVarINISection(cIniFile, cSecName, cName) 
Return ( aScan( _GetSection(cSecName, cIniFile), {|x| UPPER(x[1]) == UPPER(cName)} ) > 0 ) 
