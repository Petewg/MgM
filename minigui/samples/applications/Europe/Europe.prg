/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "Dbstruct.ch"

#define PROGRAM 'Europe'
#define VERSION ' 1.0'
#define COPYRIGHT ' 2005 Grigory Filatov'

MEMVAR cFileName
*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*
Local cExePath := GetExeFileName(), cItem, i

PRIVATE cFileName := cFilePath( cExePath ) + "\" + Lower( cFileNoExt( cExePath ) ) + ".dat"

	SET MULTIPLE OFF WARNING

	DEFINE WINDOW Form_1 							;
		AT 0,0 								;
		WIDTH 328 HEIGHT 292 + IF(IsXPThemeActive(), 6, 0)		;
		TITLE PROGRAM + VERSION						;
		ICON "MAIN"							;
		MAIN NOMAXIMIZE NOMINIMIZE NOSIZE				;
		ON INIT OpenTable()						;
		ON RELEASE CloseTable()						;
		BACKCOLOR { 255, 224, 192 }					;
		FONT "MS Sans Serif" SIZE 8

	For i := 1 To 10
		cItem := 'Btn_' + Ltrim(Str(i))

		@ 1, 1+32*(i-1) BUTTON &cItem		;
			ICON 'Z' + Ltrim(Str(i))	;
			ACTION BtnClick()		;
			WIDTH 32			;
			HEIGHT 24 FLAT
	Next i

	For i := 11 To 19
		cItem := 'Btn_' + Ltrim(Str(i))

		@ 25+24*(i-11), 1+32*9 BUTTON &cItem	;
			ICON 'Z' + Ltrim(Str(i))	;
			ACTION BtnClick()		;
			WIDTH 32			;
			HEIGHT 24 FLAT
	Next i

	For i := 20 To 29
		cItem := 'Btn_' + Ltrim(Str(i))

		@ 1+24*10, 1+32*9-32*(i-20) BUTTON &cItem	;
			ICON 'Z' + Ltrim(Str(i))	;
			ACTION BtnClick()		;
			WIDTH 32			;
			HEIGHT 24 FLAT
	Next i

	For i := 30 To 38
		cItem := 'Btn_' + Ltrim(Str(i))

		@ 1+24*9-24*(i-30), 1 BUTTON &cItem	;
			ICON 'Z' + Ltrim(Str(i))	;
			ACTION BtnClick()		;
			WIDTH 32			;
			HEIGHT 24 FLAT
	Next i

	@ 30, 40 LABEL Label_0 VALUE PROGRAM ;
		WIDTH 240 HEIGHT 24 CENTERALIGN ;
		FONT "Tahoma" SIZE 14 TRANSPARENT

	@ 62, 40 LABEL Label_1 VALUE "Square:" ;
		WIDTH 64 HEIGHT 18 RIGHTALIGN ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 94, 40 LABEL Label_2 VALUE "Populace:" ;
		WIDTH 64 HEIGHT 18 RIGHTALIGN ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 126, 40 LABEL Label_3 VALUE "Language:" ;
		WIDTH 64 HEIGHT 18 RIGHTALIGN ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 158, 40 LABEL Label_4 VALUE "Religion:" ;
		WIDTH 64 HEIGHT 18 RIGHTALIGN ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 190, 40 LABEL Label_5 VALUE "Currency:" ;
		WIDTH 64 HEIGHT 18 RIGHTALIGN ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 216, 114 HYPERLINK Label_6 ;
		VALUE 'gfilatov@inbox.ru' ;
		ADDRESS "mailto:gfilatov@inbox.ru?cc=&bcc=" + ;
			"&subject=Europe%20Feedback:" ;
		WIDTH 100 HEIGHT 14 ;
		TOOLTIP "E-mail me if you have any comments or suggestions" ;
		FONTCOLOR BLUE TRANSPARENT HANDCURSOR

	@ 62, 120 LABEL Label_11 VALUE "" ;
		WIDTH 160 HEIGHT 18 ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 94, 120 LABEL Label_21 VALUE "" ;
		WIDTH 160 HEIGHT 18 ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 126, 120 LABEL Label_31 VALUE "" ;
		WIDTH 160 HEIGHT 18 ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 158, 120 LABEL Label_41 VALUE "" ;
		WIDTH 160 HEIGHT 18 ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	@ 190, 120 LABEL Label_51 VALUE "" ;
		WIDTH 160 HEIGHT 18 ;
		FONT "Tahoma" SIZE 10 TRANSPARENT

	ON KEY ESCAPE ACTION Form_1.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure BtnClick()
*--------------------------------------------------------*
LOCAL cItem := This.Name

	cItem := Substr( cItem, At("_", cItem) + 1 )

	BASE->( dbseek( Val(cItem) ) )

	Form_1.Label_0.Value := Trim(BASE->Name)

	Form_1.Label_11.Value := StrTran(Ltrim(Transform(BASE->Square, "999,999.99")), ".00", "") + " sq km"
	Form_1.Label_21.Value := Ltrim(Transform(BASE->Populace, "99,999,999"))
	Form_1.Label_31.Value := BASE->Language
	Form_1.Label_41.Value := BASE->Religion
	Form_1.Label_51.Value := BASE->Currency

Return

*--------------------------------------------------------*
Procedure OpenTable()
*--------------------------------------------------------*
Local cItem

	IF !FILE(cFileName)
		CreateTable()
	ENDIF
	
	Use (cFileName) Alias BASE NEW
	Index On FIELD->Code To Base1
	Set Index To Base1

	GO TOP
	DO WHILE !EOF()
		cItem := 'Btn_' + Ltrim(Str(RecNo()))
		SetProperty('Form_1', cItem, 'Tooltip', Trim(BASE->Name))
		SKIP
	ENDDO

Return

*--------------------------------------------------------*
Procedure CloseTable()
*--------------------------------------------------------*

	BASE->( dbclosearea() )
	FileDelete( "*.ntx" )

Return

*--------------------------------------------------------*
Procedure FileDelete( cMask )
*--------------------------------------------------------*
	AEval( Directory( cMask ), { |file| Ferase( file[1] ) } )
Return

*--------------------------------------------------------*
Procedure CreateTable
*--------------------------------------------------------*
LOCAL aDbf[7][4], i, aName := {}, aSquare := {}, aPopulace := {}, ;
	aLanguage := {}, aReligion := {}, aCurrency := {}

	Aadd( aName, "Austria")
	Aadd( aName, "Albania")
	Aadd( aName, "Andorra")
	Aadd( aName, "Belgium")
	Aadd( aName, "Bosnia-Herzegovina")
	Aadd( aName, "Bulgaria")
	Aadd( aName, "Cyprus")
	Aadd( aName, "Chech")
	Aadd( aName, "Denmark")
	Aadd( aName, "Germany")
	Aadd( aName, "Finland")
	Aadd( aName, "France")
	Aadd( aName, "Greece")
	Aadd( aName, "Croatia")
	Aadd( aName, "Hungary")
	Aadd( aName, "Ireland")
	Aadd( aName, "Italy")
	Aadd( aName, "Iceland")
	Aadd( aName, "Liechtenstein")
	Aadd( aName, "Luxembourg")
	Aadd( aName, "Macedonia")
	Aadd( aName, "Malta")
	Aadd( aName, "Monaco")
	Aadd( aName, "Netherlands")
	Aadd( aName, "Norway")
	Aadd( aName, "Poland")
	Aadd( aName, "Portugal")
	Aadd( aName, "Romania")
	Aadd( aName, "San Marino")
	Aadd( aName, "Serbia and Montenegro")
	Aadd( aName, "Spain")
	Aadd( aName, "Sweden")
	Aadd( aName, "Switzerland")
	Aadd( aName, "Slovakia")
	Aadd( aName, "Slovenia")
	Aadd( aName, "Turkey")
	Aadd( aName, "Great Britain")
	Aadd( aName, "Vatican")

	Aadd( aSquare, 83855)
	Aadd( aPopulace, 7700000)
	Aadd( aLanguage, "german")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 28748)
	Aadd( aPopulace, 3300000)
	Aadd( aLanguage, "albanian")
	Aadd( aReligion, "islam/orthodoxy")
	Aadd( aCurrency, "lek")

	Aadd( aSquare, 467)
	Aadd( aPopulace, 50000)
	Aadd( aLanguage, "catalan/french")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 30519)
	Aadd( aPopulace, 9900000)
	Aadd( aLanguage, "flemish/french")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 51113)
	Aadd( aPopulace, 4360000)
	Aadd( aLanguage, "serbo-croatian")
	Aadd( aReligion, "orthodoxy/islam")
	Aadd( aCurrency, "dinar")

	Aadd( aSquare, 110912)
	Aadd( aPopulace, 9000000)
	Aadd( aLanguage, "bulgarian")
	Aadd( aReligion, "orthodoxy")
	Aadd( aCurrency, "lev")

	Aadd( aSquare, 9251)
	Aadd( aPopulace, 700000)
	Aadd( aLanguage, "greek/turkish")
	Aadd( aReligion, "orthodoxy/islam")
	Aadd( aCurrency, "pound")

	Aadd( aSquare, 78864)
	Aadd( aPopulace, 10400000)
	Aadd( aLanguage, "czech")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "krone")

	Aadd( aSquare, 43092)
	Aadd( aPopulace, 5100000)
	Aadd( aLanguage, "danish")
	Aadd( aReligion, "lutheran")
	Aadd( aCurrency, "krone")

	Aadd( aSquare, 357050)
	Aadd( aPopulace, 79500000)
	Aadd( aLanguage, "german")
	Aadd( aReligion, "lutheran")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 338145)
	Aadd( aPopulace, 5000000)
	Aadd( aLanguage, "finnish")
	Aadd( aReligion, "lutheran")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 543965)
	Aadd( aPopulace, 56700000)
	Aadd( aLanguage, "french")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 131957)
	Aadd( aPopulace, 10100000)
	Aadd( aLanguage, "greek")
	Aadd( aReligion, "orthodoxy")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 56526)
	Aadd( aPopulace, 4660000)
	Aadd( aLanguage, "serbo-croatian")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "dinar")

	Aadd( aSquare, 93036)
	Aadd( aPopulace, 10400000)
	Aadd( aLanguage, "hungarian")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "forint")

	Aadd( aSquare, 70282)
	Aadd( aPopulace, 3500000)
	Aadd( aLanguage, "irish/english")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 301277)
	Aadd( aPopulace, 57700000)
	Aadd( aLanguage, "italian")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 103001)
	Aadd( aPopulace, 300000)
	Aadd( aLanguage, "icelandic")
	Aadd( aReligion, "lutheran")
	Aadd( aCurrency, "krone")

	Aadd( aSquare, 160)
	Aadd( aPopulace, 30000)
	Aadd( aLanguage, "german")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 2586)
	Aadd( aPopulace, 400000)
	Aadd( aLanguage, "luxembourgian")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 25700)
	Aadd( aPopulace, 2060000)
	Aadd( aLanguage, "macedonian")
	Aadd( aReligion, "orthodoxy/islam")
	Aadd( aCurrency, "dinar")

	Aadd( aSquare, 316)
	Aadd( aPopulace, 400000)
	Aadd( aLanguage, "maltese/english")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "lira")

	Aadd( aSquare, 221)
	Aadd( aPopulace, 29000)
	Aadd( aLanguage, "french/monegasian")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "franc")

	Aadd( aSquare, 41785)
	Aadd( aPopulace, 15000000)
	Aadd( aLanguage, "netherlands")
	Aadd( aReligion, "romish/protestant")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 323878)
	Aadd( aPopulace, 4300000)
	Aadd( aLanguage, "norwegian")
	Aadd( aReligion, "lutheran")
	Aadd( aCurrency, "krone")

	Aadd( aSquare, 312683)
	Aadd( aPopulace, 38200000)
	Aadd( aLanguage, "polish")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "zloty")

	Aadd( aSquare, 92072)
	Aadd( aPopulace, 10400000)
	Aadd( aLanguage, "portuguese")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 237500)
	Aadd( aPopulace, 23400000)
	Aadd( aLanguage, "romanian")
	Aadd( aReligion, "orthodoxy")
	Aadd( aCurrency, "leya")

	Aadd( aSquare, 61)
	Aadd( aPopulace, 23000)
	Aadd( aLanguage, "italian")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 102200)
	Aadd( aPopulace, 10500000)
	Aadd( aLanguage, "serbo-croatian")
	Aadd( aReligion, "orthodoxy/romish")
	Aadd( aCurrency, "dinar")

	Aadd( aSquare, 504782)
	Aadd( aPopulace, 39000000)
	Aadd( aLanguage, "spanish/catalan")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

	Aadd( aSquare, 449964)
	Aadd( aPopulace, 8600000)
	Aadd( aLanguage, "swedish")
	Aadd( aReligion, "lutheran")
	Aadd( aCurrency, "krone")

	Aadd( aSquare, 41293)
	Aadd( aPopulace, 6800000)
	Aadd( aLanguage, "german/french")
	Aadd( aReligion, "romish/protestant")
	Aadd( aCurrency, "franc")

	Aadd( aSquare, 49035)
	Aadd( aPopulace, 5400000)
	Aadd( aLanguage, "slovak")
	Aadd( aReligion, "romish/protestant")
	Aadd( aCurrency, "krone")

	Aadd( aSquare, 20240)
	Aadd( aPopulace, 1930000)
	Aadd( aLanguage, "slovenian")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "dinar")

	Aadd( aSquare, 779452)
	Aadd( aPopulace, 58500000)
	Aadd( aLanguage, "turkish")
	Aadd( aReligion, "islam")
	Aadd( aCurrency, "lira")

	Aadd( aSquare, 244103)
	Aadd( aPopulace, 57500000)
	Aadd( aLanguage, "english")
	Aadd( aReligion, "anglican/romish")
	Aadd( aCurrency, "pound")

	Aadd( aSquare, 0.44)
	Aadd( aPopulace, 850)
	Aadd( aLanguage, "italian/latin")
	Aadd( aReligion, "romish")
	Aadd( aCurrency, "euro")

        aDbf[1][ DBS_NAME ] := "Code"
        aDbf[1][ DBS_TYPE ] := "Numeric"
        aDbf[1][ DBS_LEN ]  := 2
        aDbf[1][ DBS_DEC ]  := 0
        //
        aDbf[2][ DBS_NAME ] := "Name"
        aDbf[2][ DBS_TYPE ] := "Character"
        aDbf[2][ DBS_LEN ]  := 22
        aDbf[2][ DBS_DEC ]  := 0
        //
        aDbf[3][ DBS_NAME ] := "Square"
        aDbf[3][ DBS_TYPE ] := "Numeric"
        aDbf[3][ DBS_LEN ]  := 9
        aDbf[3][ DBS_DEC ]  := 2
        //
        aDbf[4][ DBS_NAME ] := "Populace"
        aDbf[4][ DBS_TYPE ] := "Numeric"
        aDbf[4][ DBS_LEN ]  := 8
        aDbf[4][ DBS_DEC ]  := 0
        //
        aDbf[5][ DBS_NAME ] := "Language"
        aDbf[5][ DBS_TYPE ] := "Character"
        aDbf[5][ DBS_LEN ]  := 25
        aDbf[5][ DBS_DEC ]  := 0
        //
        aDbf[6][ DBS_NAME ] := "Religion"
        aDbf[6][ DBS_TYPE ] := "Character"
        aDbf[6][ DBS_LEN ]  := 25
        aDbf[6][ DBS_DEC ]  := 0
        //
        aDbf[7][ DBS_NAME ] := "Currency"
        aDbf[7][ DBS_TYPE ] := "Character"
        aDbf[7][ DBS_LEN ]  := 10
        aDbf[7][ DBS_DEC ]  := 0

        DBCREATE(cFileName, aDbf)

	Use (cFileName)

	For i := 1 To Len(aName)
		append blank
		Replace CODE with i 
		Replace NAME With aName[i]
		Replace SQUARE With aSquare[i]
		Replace POPULACE With aPopulace[i]
		Replace LANGUAGE With aLanguage[i]
		Replace RELIGION With aReligion[i]
		Replace CURRENCY With aCurrency[i]
	Next i

	Use

Return
