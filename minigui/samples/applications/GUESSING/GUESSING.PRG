/*
   Characters Guessing Game (Brainstorming)
   
   Multi-Language supported, Simply add a new file named 'Lang-???.ini' for your language.
   
   (c) Bootwan  July 11, 2010.
   E-mail: bootwan@yahoo.com.tw 
*/

#include "minigui.ch"

STATIC cLngCode := "Eng"
STATIC cIniFile := ""
STATIC cLngFile := ""
STATIC cPattern := "0123456789"
STATIC nLength  := 4
STATIC cAnswer  := ""
STATIC nStartSecs := 0

PROCEDURE Main
LOCAL cForm, cGrid, cTitle, nLeft, nTop, nCol
LOCAL cExeFile, cFilePath, cFileBase
LOCAL cFontName, nFontSize, cValue
LOCAL cSection, cType, aHeaders, nWidth, n
LOCAL ni, aLanguages, cControl, cLngName

   cExeFile  := Application.ExeName
   cFilePath := FilePath(cExeFile)
   cFileBase := FileBase(cExeFile)
   cIniFile  := cFilePath + "\" + cFileBase + ".ini"
   cSection  := "Application"
   cLngCode  := FetchIni(cSection, "Language", "Eng", cIniFile)
   cLngFile  := cFilePath + "\Lang-" + cLngCode + ".ini"

   cPattern  := FetchIni(cSection, "Pattern", cPattern, cIniFile)
   cPattern  := ExamineCharacters(cPattern)
   nLength   := FetchIni(cSection, "Length",  nLength, cIniFile)
   nLength   := IIF(nLength > LEN(cPattern) .or. nLength < 3, 4, nLength)

   cTitle    := FetchIni(cSection, "Title", "Characters Guessing Game", cLngFile)
   nTop      := FetchIni(cSection, "Top",  0, cIniFile)
   nLeft     := FetchIni(cSection, "Left", 0, cIniFile)
   cFontName := FetchIni(cSection, "FontName", "Fixedsys", cIniFile)
   nFontSize := FetchIni(cSection, "FontSize", 12, cIniFile)

   /* SET MENUSTYLE STANDARD  // EXTENDED */

   cForm    := "frmGuessing"
   cGrid    := "grdAttempts"
   DEFINE WINDOW &cForm AT nTop, nLeft WIDTH 300 HEIGHT 360 ;
      TITLE cTitle MAIN NOSIZE NOMAXIMIZE  ;
      ON RELEASE { || Form_Release(ThisWindow.Name) }

      ON KEY ESCAPE ACTION { || ThisWindow.Release() }

      cValue := "Game begins with your first guess"
      cValue := GetLngText("Application", "Guess", cValue, cLngFile, "Label")
      @ 10,10 LABEL lblGuess VALUE cValue AUTOSIZE
      @ 40,10 TEXTBOX tbxGuess VALUE "" WIDTH 160 UPPERCASE ;
         FONT cFontName SIZE nFontSize ;
         ON ENTER { || Validation(cForm, cGrid) }
      nCol := GetProperty(cForm, "Width") - GetBorderWidth() - 112
      @ 38,nCol BUTTON btnGuess CAPTION GetLngText("Application", "Guess", "&Guess", cLngFile, "Button") WIDTH 100 ;
         ACTION { || Validation(cForm, cGrid) }

      aHeaders := GetGridHeaders()
      nWidth   := GetProperty(cForm, "Width") - GetBorderWidth() * 2 - 20
      @ 70,10 GRID &cGrid WIDTH nWidth HEIGHT 200 ;
         FONT cFontName SIZE nFontSize ;
         HEADERS aHeaders ;
         WIDTHS { 120, 76, 66 } ;
         JUSTIFY { GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_RIGHT }

      cType    := "MenuItem"
      cSection := "Application"
      DEFINE MAIN MENU
         POPUP GetLngText(cSection, "Game", "&Game", cLngFile, cType) NAME mnuGame
            MENUITEM GetLngText(cSection, "GameNew", "&New Game", cLngFile, cType) NAME mnuGameNew ;
               ACTION { || Game_New(cForm, cGrid) }
            SEPARATOR
            MENUITEM GetLngText(cSection, "GameQuit", "&Quit", cLngFile, cType) NAME mnuGameQuit ;
               ACTION { || ThisWindow.Release() }
         END POPUP
         POPUP GetLngText(cSection, "Option", "&Option", cLngFile, cType) NAME mnuOption
            MENUITEM GetLngText(cSection, "OptSetting", "&Setting", cLngFile, cType) NAME mnuOptSetting ;
               ACTION { || Game_Setting() }
            POPUP GetLngText(cSection, "OptLanguage", "&Language", cLngFile, cType) NAME mnuOptLanguage
               aLanguages := GetLanguages()   
               For ni = 1 to LEN(aLanguages)
                  cControl := "mnuLang_" + aLanguages[ni,1]
                  cLngName := aLanguages[ni,2]
                  MENUITEM cLngName NAME &cControl ACTION { || LanguageChanged(cForm, cGrid, This.Name) }
                  if cLngCode == aLanguages[ni,1]
                     SetProperty(cForm, cControl, "Checked", .T.)
                  Endif
               Next ni
            END POPUP   
         END POPUP
         POPUP GetLngText(cSection, "Help", "&Help", cLngFile, cType) NAME mnuHelp
            MENUITEM GetLngText(cSection, "HelpGuide", "&Guide", cLngFile, cType) NAME mnuHelpGuide ;
               ACTION { || Help_Guide() }
            MENUITEM GetLngText(cSection, "HelpAbout", "&About", cLngFile, cType) NAME mnuHelpAbout ;
               ACTION { || Help_About() }   
         END POPUP
      END MENU

      @ 280, 10 LABEL lblWasted VALUE GetLngText(cSection, "Wasted", "Seconds wasted:", cLngFile, "Label") AUTOSIZE
      @ 280,190 LABEL lblSeconds VALUE "0.00" WIDTH 92 RIGHTALIGN

      DEFINE TIMER tmrWaste INTERVAL 100 ACTION { || n := (SECONDS() - nStartSecs),    ;
         SetProperty(cForm, "lblSeconds", "Value", LTRIM(Str(n)))    }

   END WINDOW

   Game_New(cForm, cGrid) 
   if nTop <= 0 .and. nLeft <= 0
      CENTER WINDOW &cForm
   Endif

   ACTIVATE WINDOW &cForm   

RETURN


STATIC FUNCTION Form_Release(cForm)
LOCAL cSection

   SetProperty(cForm, "tmrWaste", "Enabled", .F.)
   cSection := "Application" 
   WriteIni(cSection, "Top", GetProperty(cForm, "Row"), cIniFile)
   WriteIni(cSection, "Left", GetProperty(cForm, "Col"), cIniFile)
   WriteIni(cSection, "Language", cLngCode, cIniFile)

RETURN NIL


STATIC FUNCTION Game_New (cForm, cGrid)
   cAnswer := GenerateNewAnswer()
   DoMethod(cForm, cGrid, "DeleteAllItems")
   SetProperty(cForm, "tmrWaste", "Enabled", .F.)
   SetProperty(cForm, "lblSeconds", "Value", "0.00")
   SetProperty(cForm, "tbxGuess", "Value", "")
   DoMethod(cForm, "tbxGuess", "SetFocus")   
RETURN NIL


STATIC PROCEDURE Game_Setting
LOCAL cForm, cTitle, cSection

   cForm    := "frmSetting"
   cTitle   := GetLngText(cForm, "Title", "Game Setting", cLngFile)
   cSection := "Application"
   DEFINE WINDOW &cForm AT 0,0 WIDTH 290 HEIGHT 180 ;
      TITLE cTitle MODAL NOSIZE 
      @ 10,10 LABEL lblPattern VALUE GetLngText(cForm, "Pattern", "Valid characters for guessing:", cLngFile, "Label") AUTOSIZE
      @ 30,10 TEXTBOX tbxPattern VALUE cPattern WIDTH 260 UPPERCASE
      @ 70,10 LABEL lblLength  VALUE GetLngText(cForm, "Length",  "Answer length:",  cLngFile, "Label") AUTOSIZE
      @ 70,200 TEXTBOX tbxLength VALUE LTRIM(Str(nLength)) WIDTH 70 RIGHTALIGN 
      @ 110,40 BUTTON btnOk CAPTION GetLngText(cForm, "Ok", "&Ok", cLngFile, "Button") ;
         ACTION { || cPattern := ExamineCharacters(GetProperty(cForm, "tbxPattern", "Value")), ;
            WriteIni(cSection, "Pattern", cPattern, cIniFile), ;
            nLength := VAL(GetProperty(cForm, "tbxLength", "Value")), ;
            nLength := IIF(nLength < 3 .or. nLength > LEN(cPattern), 4, nLength), ;
            WriteIni(cSection, "Length", nLength, cIniFile), ;
            ThisWindow.Release() }
      @ 110, 150 BUTTON btnCancel CAPTION GetLngText(cForm, "Cancel", "&Cancel", cLngFile, "Button") ;
         ACTION { || ThisWindow.Release() }
   END WINDOW
   CENTER WINDOW &cForm
   ACTIVATE WINDOW &cForm

RETURN 


STATIC FUNCTION GenerateNewAnswer
LOCAL cString, nPos, cValids

   cString := ""
   cValids := cPattern
   Do While LEN(cString) < nLength .and. LEN(cValids) > 0
      nPos    := RANDOM(LEN(cValids))
      cString += Substr(cValids, nPos, 1)
      cValids := STUFF(cValids, nPos, 1, "")
   Enddo 

RETURN(cString)


STATIC FUNCTION ExamineCharacters(cString)
LOCAL cValids, ni, cChar

   cValids := ""
   cString := UPPER(cString)
   for ni = 1 to LEN(cString)
      cChar := Substr(cString, ni, 1)
      if AT(cChar, cValids) == 0
         cValids += cChar
      Endif
   Next ni

RETURN(cValids)


STATIC FUNCTION Validation(cForm, cGrid)
LOCAL cValue, cChar, ni, na, nb, cResult, nCount, aValues
LOCAL nWasteSecs := VAL(GetProperty(cForm, "lblSeconds", "Value"))
LOCAL cPrompt, cTitle

   cValue := ExamineCharacters(GetProperty(cForm, "tbxGuess", "Value"))
   if LEN(cValue) <> nLength
      cTitle  := GetLngText("GuessInput", "Title", "Error Input", cLngFile)
      cPrompt := "The answer length is %1 unique characters.\n"
      cPrompt += "Availables: %2\n"
      cPrompt := GetLngText("GuessInput", "Prompt", cPrompt, cLngFile)
      aValues := { LTRIM(Str(nLength)), cPattern }
      cPrompt := ReplaceValues(cPrompt, aValues)
      MsgExclamation(cPrompt, cTitle)
   Else
      na     := 0
      nb     := 0
      For ni = 1 to LEN(cValue)
         cChar := Substr(cValue, ni, 1)
         if Substr(cAnswer, ni, 1) == cChar
            na += 1
         Elseif AT(cChar, cAnswer) > 0
            nb += 1
         Endif   
      Next ni      
      cResult := LTRIM(Str(na)) + "A" + LTRIM(Str(nb)) + "B"
      nCount  := GetProperty(cForm, cGrid, "ItemCount") + 1
      aValues := { cValue, cResult, LTRIM(Str(nCount)) }
      DoMethod(cForm, cGrid, "AddItem", aValues)
      SetProperty(cForm, cGrid, "Value", nCount)

      if na == nLength 
         SetProperty(cForm, "tmrWaste", "Enabled", .F.)
         cTitle  := GetLngText("Validation", "Title", "Congratulation", cLngFile)
         cPrompt := "The correct answer is %1\n%2 seconds wasted.\n"
         cPrompt += "Do you want to play again?"
         cPrompt := GetLngText("Validation", "Prompt", cPrompt, cLngFile)
         aValues := { cAnswer, LTRIM(Str(nWasteSecs)) }
         cPrompt := ReplaceValues(cPrompt, aValues)
         if MsgYesNo(cPrompt, cTitle)
            Game_New(cForm, cGrid)
         Else
            DoMethod(cForm, "Release")   
         Endif
      Else
         if nCount == 1
            nStartSecs := SECONDS()
            SetProperty(cForm, "tmrWaste", "Enabled", .T.)
         Endif
         SetProperty(cForm, "tbxGuess", "Value", "")
         DoMethod(cForm, "tbxGuess", "SetFocus")   
      Endif
   Endif   

RETURN NIL


STATIC PROCEDURE LanguageChanged(cForm, cGrid, cMenuItem)
LOCAL cCode, cFilePath, cSection, h, c, i, ct, cn, cValue
LOCAL aHeaders

   cCode := Substr(cMenuItem, 9)
   if cCode <> cLngCode
      cLngCode  := cCode
      cFilePath := FilePath(EXENAME())
      cLngFile  := cFilePath + "\Lang-" + cLngCode + ".ini"

      cSection  := "Application"

      cValue := GetLngText(cSection, "Title", "", cLngFile)
      if LEN(cValue) > 0
         SetProperty(cForm, "Title", cValue)
      Endif

      h := GetFormHandle(cForm)
      c := LEN( _HMG_aControlHandles )
      for i = 1 to c
         if _HMG_aControlParentHandles[i] ==  h
            if VALTYPE( _HMG_aControlHandles[i] ) == "N"
               ct := _HMG_aControlType[i]
               cn := _HMG_aControlNames[i]
               Do Case
               Case ct == "MENU" .or. ct == "POPUP"
                  if UPPER(LEFT(cn,8)) == UPPER("mnuLang_")
                     SetProperty(cForm, cn, "Checked", (cn == cMenuItem))
                  Else
                     cValue := GetLngText(cSection, Substr(cn,4), "", cLngFile, "MenuItem")
                     if LEN(cValue) > 0
                        /* For MiniGUI Extended and SET MENUSTYLE EXTENDED */
                        // _SetMenuItemCaption(cn, cForm, cValue)
                     Endif
                  Endif
               Case ct == "LABEL"
                  cValue := GetLngText(cSection, Substr(cn,4), "", cLngFile, "Label")
                  if LEN(cValue) > 0
                     SetProperty(cForm, cn, "Value", cValue)
                  Endif
               Case ct == "BUTTON"      
                  cValue := GetLngText(cSection, Substr(cn,4), "", cLngFile, "Button")
                  if LEN(cValue) > 0
                     SetProperty(cForm, cn, "Caption", cValue)
                  Endif
               EndCase
            Endif
         Endif
      Next i

      aHeaders := GetGridHeaders()
      For i = 1 to LEN(aHeaders)
         SetProperty(cForm, cGrid, "Header", i, aHeaders[i])
      Next i
   Endif   

RETURN 


STATIC FUNCTION GetLanguages()
LOCAL aLanguages := {}, aFiles, ni, cLngCode, cLngName
LOCAL cFilePath, cFileName, cFileBase

   cFilePath := FilePath(EXENAME())
   aFiles    := DIRECTORY(cFilePath + "\Lang-*.ini")
   for ni = 1 to LEN(aFiles)
      cFileName := aFiles[ni, 1]
      cFileBase := FileBase(cFileName)
      cLngCode  := Substr(cFileBase, 6)
      cLngName  := FetchIni("Language", "Name", cLngCode, cFilePath + "\" + cFileName)
      AADD(aLanguages, { cLngCode, cLngName } )
   Next ni
   ASORT(aLanguages,,, { | x, y | x[2] < y[2] })

RETURN(aLanguages)


STATIC FUNCTION GetGridHeaders()
LOCAL cType, cSection, aHeaders := {}

   cType    := "Column"   
   cSection := "Application"
   AADD(aHeaders, GetLngText(cSection, "Guessed", "Guessed", cLngFile, cType))
   AADD(aHeaders, GetLngText(cSection, "Conform", "Conform", cLngFile, cType))
   AADD(aHeaders, GetLngText(cSection, "Tries",   "Tries",   cLngFile, cType))

RETURN(aHeaders)


STATIC PROCEDURE Help_Guide()
LOCAL cTitle, cPrompt

   cTitle  := GetLngText("HelpGuide", "Title", "Rules of game", cLngFile)
   cPrompt := GetSectionText("HelpGuide", "Prompt", cLngFile)
   if LEN(cPrompt) = 0
      cPrompt := "You can set the characters allowed in Pattern (0-9 & A-Z), and the answer length." + HB_OSNewLine()
      cPrompt += "The answer is different combinations of characters of Pattern." + HB_OSNewLine()
      cPrompt += "A means the number of characters that locations are consistent with the answer." + HB_OSNewLine()
      cPrompt += "B means the number of characters that locations are incorrect with the answer."
   Endif
   MsgInfo(cPrompt, cTitle)

RETURN


STATIC PROCEDURE Help_About()
LOCAL cTitle, cPrompt

   cTitle  := GetLngText("HelpAbout", "Title", "About this game", cLngFile)
   cPrompt := GetSectionText("HelpAbout", "Prompt", cLngFile)
   if LEN(cPrompt) = 0
      cPrompt := "Author: bootwan" + HB_OSNewLine()
      cPrompt += "e-mail: bootwan@yahoo.com.tw"
   Endif
   MsgInfo(cPrompt, cTitle)

RETURN


STATIC FUNCTION FilePath( cFile )
LOCAL nPos, cFilePath

   cFilePath := ""
   if ( nPos := RAT( "\", cFile )) <> 0
      cFilePath := LEFT( cFile, nPos - 1)
   Endif

RETURN( cFilePath )


STATIC FUNCTION FileBase( cFile )
LOCAL nPos, cFileBase

   if (nPos := RAT("\", cFile)) > 0
      cFileBase := Substr(cFile, nPos + 1)
   Elseif (nPos := AT(":", cFile)) > 0   
      cFileBase := Substr(cFile, nPos + 1)
   Else
      cFileBase := cFile
   Endif      
   if ( nPos := AT(".", cFileBase)) > 0
      cFileBase := Substr( cFileBase, 1, nPos - 1 )
   Endif

RETURN( cFileBase )


STATIC FUNCTION GetLngText(cSection, cKey, cDefault, cFileName, cType)
LOCAL cText, cValue, cKeyId

   cType  := IIF(cType == NIL, "", cType)
   cKeyId := cType + IIF(LEN(cType) > 0, ".", "") + cKey
   cValue := GetPrivateProfileString(cSection, cKeyId, "", cFileName)  
   if LEN(cValue) == 0 
      if LEN(cType) > 0
         cSection := "Common." + cType
         cValue   := GetPrivateProfileString(cSection, cKey, "", cFileName)
      Endif
   Endif
   cText := IIF(LEN(cValue) > 0, cValue, cDefault)

RETURN(cText)


STATIC FUNCTION ReplaceValues(cString, aValues)
LOCAL ni, nPos, cTag, aTags := {}

   ni := 0
   Do While ni < LEN(aValues)
      ni   += 1
      cTag := "%" + LTRIM(Str(ni))
      nPos := AT(cTag, cString)
      if nPos > 0
         cString := STUFF(cString, nPos, LEN(cTag), aValues[ni])
      Endif
   Enddo   
   AADD(aTags, { "\n", HB_OsNewLine() })
   AADD(aTags, { "\t", Chr(9) } )
   ni := 0
   Do While ni < LEN(aTags)
      ni      += 1
      cString := STRTRAN(cString, aTags[ni,1], aTags[ni,2])
   Enddo   

RETURN(cString)


STATIC FUNCTION FetchIni(cSection, cKey, uValue, cFileName)
LOCAL cValue, vt

   vt     := VALTYPE(uValue)
   cValue := HB_VALTOSTR(uValue)
   cValue := GetPrivateProfileString(cSection, cKey, cValue, cFileName)
   Do Case
   Case vt == "N"
      uValue := VAL(cValue)
   Case vt == "D"
      uValue := CTOD(uValue)
   Otherwise
      uValue := cValue
   EndCase

RETURN(uValue)


STATIC PROCEDURE WriteIni(cSection, cKey, uValue, cFileName)
LOCAL cValue, vt

   vt := VALTYPE(uValue)
   Do Case
   Case vt == "N"
      cValue := LTRIM(Str(uValue))
   Case vt == "D"
      cValue := DTOC(uValue)
   Otherwise
      cValue := Chr(34) + uValue + Chr(34)
   EndCase
   WritePrivateProfileString(cSection, cKey, cValue, cFileName)

RETURN 


STATIC FUNCTION GetSectionText(cSection, cKey, cFileName)
LOCAL cString, cBuffer, nPos, ni, nj, cVar, cValue, cResult

   cResult := ""
   cBuffer := _GetPrivateProfileSection(cSection, cFileName)
   nPos    := AT(Chr(0), cBuffer)
   Do While nPos > 0 .and. LEN(cBuffer) > 0
      cString := LEFT(cBuffer, nPos - 1)
      ni      := AT("=", cString)
      if ni > 0
         cVar := TRIM(LEFT(cString, ni - 1))
         if UPPER(cVar) == UPPER(cKey)
            cValue := ALLTRIM(Substr(cString, ni + 1))
            if LEFT(cValue, 1) == Chr(34)
               nj     := AT(Chr(34), Substr(cValue, 2))
               cValue := IIF(nj > 0, Substr(cValue, 2, nj - 1), cValue)
            Endif   
            cResult += cValue + HB_OSNewLine()
         Endif
      Endif      
      cBuffer := Substr(cBuffer, nPos + 1)
      nPos    := AT(Chr(0), cBuffer)
   Enddo

RETURN(cResult)
