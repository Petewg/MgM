/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2014 Andrey Verchenko <verchenkoag@gmail.com>. Dmitrov, Russia
 *
*/

#include "minigui.ch"
#include "TSBrowse.ch"

// store config file to current folder
#define INI_FILE_WIN_CFG  ChangeFileExt( Application.ExeName, ".config" ) 
// OR store config file to temporary folder
//#define INI_FILE_WIN_CFG  GetTempFolder() + "\" + cFileNoPath( ChangeFileExt( Application.ExeName, ".config" ) )

/////////////////////////////////////////////////////////////////////
// Function: Recover all values TBROWSE from ini file
Function IniGetTbrowse(oBrw)
   Local cSection, cPathFileConfig
   Local FormName := _HMG_ThisFormName
   Local cProgName := GetProperty(FormName, "Title")
   Local nI, cVal, nVal, aDim, aColor, aColSize, aFonts, hFont 

   cPathFileConfig := INI_FILE_WIN_CFG 
   cSection := FormName
   
   IF FILE( cPathFileConfig )
   
      IF IsINISection(cPathFileConfig, cSection) // there is a section [] 

         ////////////////// download color of the ini-file  ///////////////////
         aColor := {}
         FOR nI := 1 TO 20
             cVal := "TbrColor_" + HB_NToS(nI)
             IF IsVarINISection(cPathFileConfig, cSection, cVal)
               // load into an array
                aDim := CTOA( GetIni( cSection , cVal , '{}', cPathFileConfig ) ) 
                IF LEN(aDim) > 0
                   AADD( aColor, aDim[2] )
                ENDIF
             ENDIF
         NEXT

         ////////////////// Download Size column widths of the ini-file ///////////////////
         aColSize := {}
         FOR nI := 1 TO 100
            cVal := "ColSize_" + HB_NToS(nI)
            nVal := VAL( GetIni( cSection , cVal , "0", cPathFileConfig ) )
            IF nVal == 0
               EXIT
            ELSE
               AADD( aColSize, nVal )
            ENDIF
          NEXT
       
         ////////////////// Download fonts Tbrowsa from ini-file ///////////////////
         aFonts := {}
         FOR nI := 1 TO 5
            cVal := "Font_" + HB_NToS(nI)
            IF IsVarINISection(cPathFileConfig, cSection, cVal)
               // load into an array 
               aDim := &( GetIni( cSection , cVal , '{}', cPathFileConfig ) )
               AADD( aFonts, aDim )
            ENDIF
         NEXT
     
         ////////////////// Restore fonts tbrowse  ///////////////////
         IF LEN(aFonts) == 5
            TbrUpFonts(oBrw,aFonts)           
         ENDIF
         ////////////////// Restore color in tbrowse  ///////////////////
         IF LEN(aColor) == 20
            TbrUpColor(oBrw,aColor)
         ENDIF

         ////////////////// Restore the column widths in sizes tbrowse  ///////////////////
         IF Len( oBrw:aColumns ) == LEN( aColSize )
            FOR nI := 1 TO Len( oBrw:aColumns )
               nVal := aColSize[nI]
               oBrw:SetColSize( nI, nVal )
             NEXT
         ENDIF

      ENDIF  // IsINISection(cPathFileConfig, cSection)

   ENDIF // FILE( cPathFileConfig )

   // ---- Remember font editing window for memo fields -> Form_memo.prg ----
   hFont := oBrw:aColumns[ 1 ]:hFontEdit   // 5-edition font
   M->aFontEdit := GetFontParam(hFont)
   
Return Nil

/////////////////////////////////////////////////////////////////////
// Function: Save all values TBROWSE in the ini-file
Function IniSetTbrowse(oBrw)
   Local FormName := _HMG_ThisFormName
   Local cProgName := GetProperty(FormName, "Title")
   Local cSection, cText, cPathFileConfig, aDim, nWidth 
   Local nI, nCol, oCol, aColor, cVal, aVar := {}
   Local aFont

   cPathFileConfig := INI_FILE_WIN_CFG 
   cSection := FormName

   IF ! File( cPathFileConfig )
      cText := "[Information]" + CRLF
      cText += "Program = " + Application.ExeName + CRLF
      cText += "Free Open Source Software = " + Version() + CRLF
      cText += "Free Compiler = " + hb_compiler() + CRLF
      cText += "Free Library  = " + MiniGUIVersion() + CRLF
      cText += "Copyright     = " + MsgAboutDim(1) + CRLF
      cText += "Assistants_1  = " + MsgAboutDim(2) + CRLF
      cText += "Assistants_2  = " + MsgAboutDim(3) + CRLF
      cText += "Assistants_3  = " + MsgAboutDim(4) + CRLF
      cText += CRLF + CRLF
      HB_MemoWrit( cPathFileConfig, cText )
   ENDIF

   WriteIni( cSection, "TitleWin" , cProgName       , cPathFileConfig )

   ////////////////// create an array of color names tbrowse  ///////////////////
   AADD( aVar, "Color of text in the table cells"                                   )
   AADD( aVar, "Background color in table cells"                                    )
   AADD( aVar, "Color of text the column header of the table"                       )
   AADD( aVar, "Background color of the column header of the table"                 )
   AADD( aVar, "Color of the text cursor, text in the cells with a focus"           )
   AADD( aVar, "Background color of the cursor/marker"                              )
   AADD( aVar, "Color of text edit field"                                           )
   AADD( aVar, "Background color of editable fields"                                )
   AADD( aVar, "Color of text of the basement"                                      )
   AADD( aVar, "Background color of of the basement"                                )
   AADD( aVar, "Color text of cursor inactive (selected cell no focused)"           )
   AADD( aVar, "Background color of the inactive cursor (selected cell no focused)" )
   AADD( aVar, "Color of text of the column header of the selected index"           )
   AADD( aVar, "Background color of of the column header of the selected index"     )
   AADD( aVar, "Color lines between table cells"                                    )
   AADD( aVar, "Color of background for super header"                               )
   AADD( aVar, "Color of text for super header"                                     )
   AADD( aVar, "Color of background for special header"                             )
   AADD( aVar, "Color of text for special header"                                   )
   AADD( aVar, "Color of active special header"                                     )


   ///////////////////// save the current color in the array TBROWSE ////////////////
   nCol := 1  // Any column with color
   oCol := oBrw:aColumns[ nCol ]
   oCol:SaveColor()
   aColor := oCol:aColorsBack
   // ------- Remember the colors are not included in the function SaveColor() ----
   aColor[15] := oBrw:nClrLine            // Color lines between table cells
   aColor[16] := oBrw:aSuperHead[nCol,5]  // Background color for super header
   aColor[17] := oBrw:aSuperHead[nCol,4]  // Color of text for super header
   // ------ considered previously stored TWO colors ------------------
   aColor[1] := M->nTbrwColorText ; aColor[2] := M->nTbrwColorPane 

   ///////////////////////// write color TBROWSE in ini-file  //////////////////////
   FOR nI := 1 TO LEN(aVar)
      cVal := "TbrColor_" + HB_NToS(nI)
      aDim := { aVar[nI] , aColor[nI] }
      // write array to a string in the ini file
      WriteIni( cSection, cVal , ATOC(aDim), cPathFileConfig )
    NEXT

   //////// write dimensions of the width of the columns in TBROWSE ini-file //////
   FOR nI := 1 TO Len( oBrw:aColumns )
      cVal := "ColSize_" + HB_NToS(nI)
      nWidth  := oBrw:GetColSizes()[nI]
      // write line in the ini file
      WriteIni( cSection, cVal , HB_NToS(nWidth), cPathFileConfig )
    NEXT
 
   ////////////////// Read and write fonts TBROWSE in ini file  //////////////////
   aFont := LoadTbrwFonts(oBrw)
   FOR nI := 1 TO Len( aFont )
      cVal := "Font_" + HB_NToS(nI)
      aDim  := aFont[nI]
      // write line in the ini file
      WriteIni( cSection, cVal , hb_Valtoexp(aDim), cPathFileConfig )
    NEXT

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
STATIC  Function IsVarINISection(cIniFile, cSecName, cName) 
Return ( aScan( _GetSection(cSecName, cIniFile), {|x| UPPER(x[1]) == UPPER(cName)} ) > 0 ) 
 