/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

Static aYValues := { "MINIGUI", "FW", "Xailer", "None", "HWGUI", "T-Gtk", "GTWVW", "Wvt" }

Function Main
/*
	MINIGUI	226	706
	FW	220	692
	Xailer	30	111
	NONE	29	71
	HWGUI	17	45
	T-Gtk	15	45
	GTWVW	12	27
	Wvt	6	16
*/
Local aSer:={ {226,220,30,29,17,15,12,6},;
              {706,692,111,71,45,45,27,16} }

	Define Window GraphTest ;
		At 0,0 ;
		Width 640 ;
		Height 480 ;
		Title "Graph" ;
		Main ;
		Icon "Main" ;
		nomaximize nosize ;
		On Init DrawBarGraph ( aSer )

		Define Button Button_1
			Row	405
			Col	50
			Caption	'Bars'
			Action DrawBarGraph ( aSer )
		End Button

		Define Button Button_2
			Row	405
			Col	250
			Caption	'Lines'
			Action DrawLinesGraph ( aSer )
		End Button

		Define Button Button_3
			Row	405
			Col	450
			Caption	'Points'
			Action DrawPointsGraph ( aSer )
		End Button

		On Key ESCAPE Action ThisWindow.Release

	End Window

	GraphTest.Center

	Activate Window GraphTest

Return Nil

Procedure DrawBarGraph ( aSer )

	ERASE WINDOW GraphTest

	DRAW GRAPH							;
		IN WINDOW GraphTest					;
		AT 20,20						;
		TO 400,620						;
		TITLE "XACC 2004 Results by GUI"			;
		TYPE BARS						;
		SERIES aSer						;
		YVALUES aYValues					;
		DEPTH 15						;
		BARWIDTH 15						;
		HVALUES 5						;
		SERIENAMES {"Votes","Rates"}				;
		COLORS { {128,128,255}, {255,102, 10} }			;
		3DVIEW    						;
		SHOWGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		SHOWLEGENDS 

Return

Procedure DrawLinesGraph ( aSer )

	ERASE WINDOW GraphTest

	DRAW GRAPH							;
		IN WINDOW GraphTest					;
		AT 20,20						;
		TO 400,620						;
		TITLE "XACC 2004 Results by GUI"			;
		TYPE LINES						;
		SERIES aSer						;
		YVALUES aYValues					;
		DEPTH 15						;
		BARWIDTH 15						;
		HVALUES 5						;
		SERIENAMES {"Votes","Rates"}				;
		COLORS { {128,128,255}, {255,102, 10} }			;
		3DVIEW    						;
		SHOWGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		SHOWLEGENDS 


Return

Procedure DrawPointsGraph ( aSer )

	ERASE WINDOW GraphTest

	DRAW GRAPH							;
		IN WINDOW GraphTest					;
		AT 20,20						;
		TO 400,620						;
		TITLE "XACC 2004 Results by GUI"			;
		TYPE POINTS						;
		SERIES aSer						;
		YVALUES aYValues					;
		DEPTH 15						;
		BARWIDTH 15						;
		HVALUES 5						;
		SERIENAMES {"Votes","Rates"}				;
		COLORS { {128,128,255}, {255,102, 10} }			;
		3DVIEW    						;
		SHOWGRID                        			;
		SHOWXVALUES                     			;
		SHOWYVALUES                     			;
		SHOWLEGENDS 

Return