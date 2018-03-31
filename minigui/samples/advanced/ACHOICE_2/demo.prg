/*
   Here is my implementation of ACHOICE in HMG using grid control.
   The only problem is that it nearly look likes the ACHOICE of the old days.

   Caveats:
   1. Grid control height and width must be larger than the height of the window, frmAchoice in this regard so that the scroll bars is not visible.
   2. If you want the horizontal and/or vertical scroll bar, then adjust the dimension calculation.

   Dhanny del Pilar <dhaine_adp@hotmail.com>
*/


#include "minigui.ch"


**************
PROCEDURE Main

   SET DEFAULT ICON TO "ZZZ_A_WINDOW"
   SET CENTERWINDOW RELATIVE PARENT

   DEFINE WINDOW Win1;
      AT 0,0 WIDTH 300 HEIGHT 400;
      TITLE "HMG AChoice Test";
      MAIN;
      NOMAXIMIZE NOSIZE

      DEFINE MAINMENU
        DEFINE POPUP "&File"
          ITEM "Test ACHOICE" ACTION Test()
          SEPARATOR
          ITEM "Exit" ACTION ThisWindow.Release
        END POPUP
      END MENU

   END WINDOW

   Win1.Center
   Win1.Activate

   RETURN


************************************
FUNCTION Test()  // test stub module

   LOCAL aChoices_ := { { "Date"          },;
                        { "Date Before"   },;
                        { "Date After"    },;
                        { "Month to Date" },;
                        { "Year to Date"  },;
                        { "Date Range"    } }

   LOCAL nChoice
   
   nChoice := hmg_Achoice( NIL, aChoices_, "Select Report Type" )
   IF nChoice > 0
      MSGINFO( aChoices_[ nChoice, 1 ], "HMG AChoice: " + hb_ntos( nChoice ) )
   ENDIF

   RETURN NIL


*****************************************************************************
FUNCTION hmg_Achoice( cTitle, aSelection_, cHeading, cFont, nFontSize, lSort )

   LOCAL nRetVal := 0

   LOCAL nWidth
   LOCAL nHeight

   LOCAL ii
   LOCAL cLonger

   LOCAL nCellWidth

   DEFAULT cTitle TO "Please select"
   DEFAULT aSelection_ TO {}
   DEFAULT cHeading TO "Available Options"
   DEFAULT cFont TO _HMG_DefaultFontName
   DEFAULT nFontSize TO _HMG_DefaultFontSize + 2
   DEFAULT lSort TO .F.

   //--> terminate and return 0 if there are no selections specified
   IF LEN( aSelection_ ) < 1
      RETURN nRetVal
   ENDIF

   //--> check if the array is needed to be sorted out
   IF lSort
      aSelection_ := ASORT( aSelection_ )
   ENDIF

   //--> find the longgest array element, accounting the title and Heading as well
   cLonger := aSelection_[ 1, 1 ]
   FOR ii := 1 TO LEN( aSelection_ )
      IF LEN( cLonger  ) < LEN( aSelection_[ ii, 1 ] )
         cLonger := aSelection_[ ii, 1 ]
      ENDIF
   NEXT
   IF LEN( cLonger ) < LEN( cHeading )
      cLonger := cHeading
   ENDIF

   //--> calculate dimensions
   nWidth     := GETTXTWIDTH( cLonger, nFontSize, cFont )
   nCellWidth := nWidth
   nWidth     += GetBorderWidth()
   nHeight    := LEN( aSelection_ ) * nFontSize 
   nHeight    := INT( nHeight / 72 * 25.4 ) + 1
   nHeight    := nHeight * LEN( aSelection_ ) + GetTitleHeight() + GetBorderHeight() / 2

   DEFINE WINDOW frmAchoice;
      CLIENTAREA nWidth, nHeight;
      TITLE cTitle;
      MODAL NOSIZE;
      ON MOUSECLICK ThisWindow.Release

      ON KEY ESCAPE ACTION ThisWindow.Release
      ON KEY RETURN ACTION ( nRetVal := frmAchoice.grdChoice.Value, ThisWindow.Release )

      @  0, 0 GRID grdChoice;
         WIDTH frmAchoice.Width HEIGHT frmAchoice.Height - 3;
         HEADERS { cHeading } WIDTHS { nCellWidth };
         ITEMS aSelection_ VALUE 1;
         FONT cFont SIZE nFontSize;
         ON CHANGE ( nRetVal := This.CellRowIndex );
         ON DBLCLICK ( nRetVal := This.CellRowIndex, ThisWindow.Release );
         NOLINES;
         JUSTIFY { GRID_JTFY_CENTER }

   END WINDOW

   CENTER WINDOW frmAchoice
   ACTIVATE WINDOW frmAchoice

   RETURN nRetVal


***************************************************************************************
STATIC FUNCTION GetTxtWidth( cText, nFontSize, cFontName ) // get the width of the text

   LOCAL hFont
   LOCAL nWidth

   LOCAL cChr := 'W'

   IF VALTYPE( cText ) == 'N'
      cText := REPLICATE( cChr, cText )
   ENDIF

   DEFAULT cText := REPLICATE( cChr, 2 ), ;
      cFontName := _HMG_DefaultFontName, ;
      nFontSize := _HMG_DefaultFontSize

   hFont := InitFont( cFontName, nFontSize + 2 )
   nWidth := GetTextWidth( 0, cText, hFont )

   DeleteObject( hFont )

   RETURN nWidth
