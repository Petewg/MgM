/*
 * MiniGUI Grid Color Demo
 *
 * The idea of 2013 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Implementation (c) 2013 Grigory Filatov <gfilatov@inbox.ru>
 *
 * For more information see \MiniGUI\SAMPLES\BASIC\Grid_Test
*/

#include "hmg.ch"

STATIC lNolines        := .T.  // Show / hide the dividing lines in the grid
STATIC lCellNavigation := .T.  // Set the cell navigation style in the grid
STATIC lNoheaders      := .T.  // Show / hide table headers in the grid

///////////////////////////////////////////////////////////////////////////
Procedure Main
LOCAL aColor  := { 105, 182, 34 }  // bright green
LOCAL aColor2 := YELLOW
LOCAL aColor3 := BLUE 
LOCAL aBtnColor := WHITE, aBackColor := aColor
LOCAL bColorFore  := { | Val, CellRowIndex | iif ( CellRowIndex / 2 == Int( CellRowIndex / 2 ) , ;
	RGB( aColor2[1],aColor2[2],aColor2[3] ) , RGB( aColor3[1],aColor3[2],aColor3[3] ) ) }
LOCAL bColorBack := { | Val, CellRowIndex | iif ( CellRowIndex / 2 == Int( CellRowIndex / 2 ) , ;
	RGB( aColor[1],aColor[2],aColor[3] ) , RGB( aColor[1],aColor[2],aColor[3] ) ) }

	SET MULTIPLE OFF
	SET AUTOADJUST ON

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 600 ;
		HEIGHT 460 ;
		TITLE 'Grid Colors Demo' ;
		MAIN ;
                BACKCOLOR aBackColor  ;
                FONT 'Tahoma' SIZE 12 ;
		ON INIT OnInitGrid()

		// Title grid {HEADERS} consists an only one line.
                // The second line is not visible! Limitation of grid.
		DEFINE GRID Grid_2
			ROW 	10
			COL	10
			WIDTH	570
			HEIGHT	300 
			WIDTHS	{ 550 - iif(IsXPThemeActive(), 2, 0) }
                        HEADERS {'No (1)','Menu (2)', 'File (3)' }
                        WIDTHS  { 100, 280, 150 }
                        ITEMS   LoadTestArray()
                        VALUE   1
			ON DBLCLICK Test_Choice(1)
                        ONHEADCLICK { {|| MsgInfo('Header 1 Clicked !')} , { || MsgInfo('Header 2 Clicked !')}, { || MsgInfo('Header 3 Clicked !')} }
			NOLINES lNolines
                        CELLNAVIGATION lCellNavigation
                        SHOWHEADERS lNoheaders
                        DYNAMICFORECOLOR { bColorFore , bColorFore, bColorFore }
                        DYNAMICBACKCOLOR { bColorBack, bColorBack, bColorBack }
                        FONTBOLD .T.
                        FONTCOLOR BLUE
                        BACKCOLOR aBackColor
		END GRID
        
                @ 320,30 LABEL label_1 VALUE "<F4>, <Enter> - choice" ;
                    WIDTH 220 HEIGHT 28 SIZE 12 BOLD TRANSPARENT
                
                ON KEY F4 ACTION Test_Choice(2)  

                @ 360, 200 BUTTONEX Button_1    ;
                    WIDTH 170  HEIGHT 35        ;
                    SIZE 11 BOLD                ;
                    CAPTION '&Report selection' ;
                    NOHOTLIGHT NOXPSTYLE        ;
                    FONTCOLOR WHITE             ;
                    BACKCOLOR BLUE              ;
                    ACTION Test_Choice(3) 

                @ 360, 400 BUTTONEX Button_2    ;
                    WIDTH 150  HEIGHT 35        ;
                    SIZE 11 BOLD                ;
                    CAPTION 'E&xit'             ;
                    NOHOTLIGHT NOXPSTYLE        ;
                    FONTCOLOR WHITE             ;
                    BACKCOLOR RED               ;
                    ACTION ThisWindow.Release()

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

Return

///////////////////////////////////////////////////////////////////////////
Procedure OnInitGrid()

   CellNavigationColor( _SELECTEDCELL_FORECOLOR, { 199 , 250 , 225 } )
   CellNavigationColor( _SELECTEDCELL_BACKCOLOR, { 7 , 71 , 41 } )

   CellNavigationColor( _SELECTEDROW_FORECOLOR, { 199 , 250 , 225 } )
   CellNavigationColor( _SELECTEDROW_BACKCOLOR, { 7 , 71 , 41 } )

   Form_2.Grid_2.SetFocus
 
Return

///////////////////////////////////////////////////////////////////////////
Function LoadTestArray()
Local nI, aRows := {}

   FOR nI := 1 TO 25
      AAdd( aRows, { STR(nI)+".", "Example menu ->"+STR(nI,3), "filename"+LTRIM(STR(nI))+".txt" } )
   NEXT

Return aRows

///////////////////////////////////////////////////////////////////////////
Procedure Test_Choice( nVal )
Local xMenuNum := Form_2.Grid_2.Value
Local cMenuName
Local cFileName
Local cText

   cText := IIF(nVal==2,"You press key [F4]" + CRLF + CRLF,"")
   cText += IIF(nVal==3,"You press button [Report selection]" + CRLF + CRLF,"")

   IF VALTYPE(xMenuNum) == "N"
      cMenuName := GetProperty( "Form_2", "Grid_2", "Cell", xMenuNum, 2 )
      cFileName := GetProperty( "Form_2", "Grid_2", "Cell", xMenuNum, 3 )
      cText += "Menu selection = " + STR(xMenuNum,2) + CRLF + CRLF
   ELSE  // celled grid
      cMenuName := GetProperty( "Form_2", "Grid_2", "Cell", xMenuNum[1], 2 )
      cFileName := GetProperty( "Form_2", "Grid_2", "Cell", xMenuNum[1], 3 )
      cText += "Menu selection = {" + STR(xMenuNum[1],2)+","+STR(xMenuNum[2],2)+" }" + CRLF + CRLF
   ENDIF

   cText += "Menu (2): ["+ cMenuName + "]" + CRLF + CRLF
   cText += "File (3): ["+ cFileName + "]"

   MsgInfo( cText )

Return
