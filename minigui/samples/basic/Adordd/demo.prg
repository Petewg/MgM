/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Based on ADORDD sample included in Harbour distribution
*/

#include "adordd.ch"
#include "minigui.ch"

Function Main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI AdoRDD Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTable() ;
		ON RELEASE CloseTable()

		@ 10,10 BROWSE Browse_1	;
			WIDTH 610	;
			HEIGHT 390	;
			HEADERS { 'First' , 'Last' , 'Birth' , 'Age' } ;
			WIDTHS { 150 , 150 , 100 , 100 } ;
			WORKAREA Table1 ;
			FIELDS { 'Table1->First' , 'Table1->Last' , 'Table1->Birth' , 'Table1->Age' } ;
			JUSTIFY { 0 , 0 , 2 , 1 }

		@ 410,10 BUTTON Button_1 ;
			CAPTION 'Append' ACTION AppendRec()

	END WINDOW

	CENTER WINDOW Form_1

	Form_1.Browse_1.SetFocus

	ACTIVATE WINDOW Form_1

Return nil


Procedure OpenTable
   Local cDatabase, cTable, cAlias

   IF !IsWinNT() .AND. !CheckODBC()
	MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
	ReleaseAllWindows()
   ENDIF

   cDatabase := "test2.mdb"
   cTable := "table1"
   cAlias := "table1"

   IF !ADOTableExists( cDatabase, cTable, cAlias )
	CreateTable()
   ENDIF

   USE (cDatabase) VIA "ADORDD" TABLE (cTable) ALIAS (cAlias)

   IF EMPTY( (cAlias)->( LastRec() ) )

	APPEND BLANK
	(cAlias)->First   := "Homer"
	(cAlias)->Last    := "Simpson"
	(cAlias)->Birth   := date() - 45 * 365
	(cAlias)->Age     := 45

	APPEND BLANK
	(cAlias)->First   := "Lara"
	(cAlias)->Last    := "Kroft"
	(cAlias)->Birth   := date() - 32 * 365
	(cAlias)->Age     := 32

   ENDIF

   GO TOP

Return


Procedure CloseTable

   USE

Return


Procedure CreateTable

   DbCreate( "test2.mdb;table1", { { "FIRST",   "C", 10, 0 },;
                                   { "LAST",    "C", 10, 0 },;
                                   { "BIRTH",   "D",  8, 0 },;
                                   { "AGE",     "N",  8, 0 } }, "ADORDD" )
Return


Procedure AppendRec()

   select( "table1" )

   Append Blank
   table1->First   := "Mulder"
   table1->Last    := "Fox"
   table1->Birth   := date() - 54 * 365
   table1->Age     := 54

   Form_1.Browse_1.Value := Recno()
   Form_1.Browse_1.Refresh

Return


Function ADOTableExists( cDatabase, cTable, cAlias )

   if !hb_FileExists( cDatabase )
      return .f.
   endif

   if select( cAlias ) > 0
      return .t.
   endif
   
   USE (cDatabase) VIA "ADORDD" TABLE (cTable) ALIAS (cAlias)
   if select( cAlias ) == 0
      return .f.
   endif
   USE

return .t.


Static Function CheckODBC()
   Local oReg, cKey := ""

   OPEN REGISTRY oReg KEY HKEY_LOCAL_MACHINE ;
	SECTION "Software\Microsoft\DataAccess"

   GET VALUE cKey NAME "Version" OF oReg

   CLOSE REGISTRY oReg

Return !Empty(cKey)
