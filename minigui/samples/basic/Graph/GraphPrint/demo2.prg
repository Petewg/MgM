/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

#define DGREEN         {  0, 128, 0}
#define DCYAN          {  0, 128, 128}
#define LGRAY          {192, 192, 192}
#define DBLUE          {  0,   0, 128}
#define CYAN           {  0, 255, 255}

Static aSer, aColors, aYvals, cTitle

Function Main

	cTitle:="Salesperson : Steve Von Denis"
	aSer:={ {72000, 55000, 118000, 92000, 70000, 19500, 115000, 99000, 94000, 72000, 32000, 6000} }
	aColors:={ BLUE, DGREEN, DCYAN, RED, PURPLE, BROWN, LGRAY, GRAY, DBLUE, GREEN, CYAN, FUCHSIA }

	aYvals := Array(12)
	aeval(aYvals, {|x,i| aYvals[i] := left(cmonth(stod(str(year(date()),4)+strzero(i,2)+"01")),3)})

	Define Window GraphTest ;
		At 0,0 ;
		Width 800 ;
		Height 620 ;
		Title "Printing bar" ;
		Main ;
		Icon "Main" ;
		Nomaximize Nosize ;
		Backcolor {216,208,200} ;
		On Init DrawBarGraph()

		@ 552,40 COMBOBOX Combo_1 ;
			ITEMS {'MiniPrint', 'HbPrinter'} ;
			VALUE 1

		Define Button Button_1
			Row	550
			Col	260
			Caption	'Print'
			Action  PrintGraph(GraphTest.Combo_1.Value)
		End Button

		Define Button Button_2
			Row	550
			Col	460
			Caption	'Exit'
			Action  GraphTest.Release
		End Button

	End Window

	Center Window GraphTest
	Activate Window GraphTest

Return Nil


Procedure DrawBarGraph

	ERASE WINDOW GraphTest

	DRAW GRAPH							;
		IN WINDOW GraphTest					;
		AT 10,10						;
		TO 545,785						;
		TITLE cTitle						;
		TYPE BARS						;
		SERIES aSer						;
		YVALUES aYvals						;
		DEPTH 15						;
		BARWIDTH 5						;
		HVALUES 12.5						;
		SERIENAMES {"Series 1"}					;
		COLORS aColors						;
		3DVIEW							;
		SHOWXGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		DATAMASK "999,999"

Return


Procedure PrintGraph( nlib )

if nlib == 1
	PRINT GRAPH							;
		IN WINDOW GraphTest					;
		AT 10,10						;
		TO 545,785						;
		TITLE cTitle						;
		TYPE BARS						;
		SERIES aSer						;
		YVALUES aYvals						;
		DEPTH 15						;
		BARWIDTH 5						;
		HVALUES 12.5						;
		SERIENAMES {"Series 1"}					;
		COLORS aColors						;
		3DVIEW							;
		SHOWXGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		DATAMASK "999,999"
else
	PRINT GRAPH							;
		IN WINDOW GraphTest					;
		AT 10,10						;
		TO 545,785						;
		TITLE cTitle						;
		TYPE BARS						;
		SERIES aSer						;
		YVALUES aYvals						;
		DEPTH 15						;
		BARWIDTH 5						;
		HVALUES 12.5						;
		SERIENAMES {"Series 1"}					;
		COLORS aColors						;
		3DVIEW							;
		SHOWXGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		DATAMASK "999,999" LIBRARY HBPRINT
endif

Return
