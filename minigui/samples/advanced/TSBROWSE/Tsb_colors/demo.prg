#include "MiniGUI.ch"
#include "TSBrowse.ch"

///////////////
FUNCTION Main()
///////////////
LOCAL oBrw, bColor
LOCAL nR1   := 204
LOCAL nG1   := 226
LOCAL nB1   := 204
LOCAL cClr1 := cClrString( nR1, nG1, nB1 )

LOCAL nR2   := 255
LOCAL nG2   := 255
LOCAL nB2   := 255
LOCAL cClr2 := cClrString( nR2, nG2, nB2 )

LOCAL aVar  := {}
LOCAL n

   // Building Array for Browse
   ////////////////////////////
   for n := 1 to 50
         aadd( aVar, { "Row Number " + str( n, 2, 0 ), str( n * 3.14, 6, 2 ) } )
   next

   SET FONT TO "Arial", 9

   DEFINE WINDOW Colors AT 0,0 WIDTH 727 HEIGHT 526 ;
     TITLE "TSBrowse ColorPick" ;
     MAIN ;
     NOMAXIMIZE NOSIZE

     DEFINE LABEL Label_1
            ROW    20
            COL    360
            WIDTH  200
            HEIGHT 21
            VALUE "Even Row Numbers"
     END LABEL  

     DEFINE FRAME Frame_1
            ROW    38
            COL    360
            WIDTH  330
            HEIGHT 195
     END FRAME  

     DEFINE LABEL Label_2
            ROW    250
            COL    360
            WIDTH  200
            HEIGHT 21
            VALUE "Odd Row Numbers"
     END LABEL  

     DEFINE FRAME Frame_2
            ROW    268
            COL    360
            WIDTH  330
            HEIGHT 195
     END FRAME  

     DEFINE TBROWSE oBrw ; 
            AT     20,20 ; 
            WIDTH  300 ; 
            HEIGHT 442 ;
            ON CHANGE { || CorrectionFirstLast( oBrw ) }

     oBrw:SetArray( aVar )

     bColor := { || if( oBrw:nAt % 2 == 0, RGB( nR1, nG1, nB1 ), RGB( nR2, nG2, nB2 ) ) }

     ADD COLUMN TO TBROWSE oBrw DATA ARRAY ELEMENT 1;
       HEADER "Column 1";
       SIZE 100;
       COLORS CLR_BLACK, bColor;
       ALIGN DT_LEFT

     ADD COLUMN TO TBROWSE oBrw DATA ARRAY ELEMENT 2;
       HEADER "Column 2";
       SIZE 200;
       COLORS CLR_BLACK, bColor;
       ALIGN DT_LEFT

       oBrw:lNoHScroll  := .t.
       oBrw:lNoGrayBar  := .t.
       oBrw:nAdjColumn  := 2
       oBrw:nHeightCell += 6
       oBrw:nHeightHead += 4

     END TBROWSE  

     // Color 1
     // --------------------------------------------------------------------------------------------------
     DEFINE LABEL Label_3
            ROW    72
            COL    380
            WIDTH  20
            HEIGHT 24
            VALUE "R"
     END LABEL  

     DEFINE TEXTBOX Text_1
            ROW    70
            COL    400
            WIDTH  40
            HEIGHT 24
            VALUE  nR1
            NUMERIC .T.
            READONLY .T.
     END TEXTBOX 

     DEFINE SLIDER Slider_1
            ROW    66
            COL    460
            WIDTH  210
            HEIGHT 30
            VALUE  nR1
            RANGEMIN 0
            RANGEMAX 255
            NOTICKS .T.
            ONCHANGE ( nR1 := Colors.Slider_1.Value, cClr1 := cClrString( nR1, nG1, nB1 ), Colors.Text_4.Value := cClr1, Colors.Text_1.Value := nR1, oBrw:Refresh() )
     END SLIDER  

     DEFINE LABEL Label_4
            ROW    112
            COL    380
            WIDTH  20
            HEIGHT 24
            VALUE "G"
     END LABEL  

     DEFINE TEXTBOX Text_2
            ROW    110
            COL    400
            WIDTH  40
            HEIGHT 24
            VALUE  nG1
            NUMERIC .T.
            READONLY .T.
     END TEXTBOX 

     DEFINE SLIDER Slider_2
            ROW    105
            COL    460
            WIDTH  210
            HEIGHT 30
            VALUE  nG1
            RANGEMIN 0
            RANGEMAX 255
            NOTICKS .T.
            ONCHANGE ( nG1 := Colors.Slider_2.Value, cClr1 := cClrString( nR1, nG1, nB1 ), Colors.Text_4.Value := cClr1, Colors.Text_2.Value := nG1, oBrw:Refresh() )
     END SLIDER  

     DEFINE LABEL Label_5
            ROW    152
            COL    380
            WIDTH  20
            HEIGHT 24
            VALUE "B"
     END LABEL  

     DEFINE TEXTBOX Text_3
            ROW    150
            COL    400
            WIDTH  40
            HEIGHT 24
            VALUE  nB1
            NUMERIC .T.
            READONLY .T.
     END TEXTBOX 

     DEFINE SLIDER Slider_3
            ROW    146
            COL    460
            WIDTH  210
            HEIGHT 30
            VALUE  nB1
            RANGEMIN 0
            RANGEMAX 255
            NOTICKS .T.
            ONCHANGE ( nB1 := Colors.Slider_3.Value, cClr1 := cClrString( nR1, nG1, nB1 ), Colors.Text_4.Value := cClr1, Colors.Text_3.Value := nB1, oBrw:Refresh() )
     END SLIDER  

     DEFINE TEXTBOX Text_4
            ROW    190
            COL    400
            WIDTH  140
            HEIGHT 24
            VALUE cClr1
     END TEXTBOX 

     DEFINE BUTTON Button_1
           ROW    190
           COL    550
           WIDTH  120
           HEIGHT 26
           CAPTION "< Copy To Clipboard"
           ACTION System.Clipboard := cClr1
     END BUTTON  

     // Color 2
     // --------------------------------------------------------------------------------------------------
     DEFINE LABEL Label_6
            ROW    302
            COL    380
            WIDTH  20
            HEIGHT 24
            VALUE "R"
     END LABEL  

     DEFINE TEXTBOX Text_5
            ROW    300
            COL    400
            WIDTH  40
            HEIGHT 24
            VALUE  nR2
            NUMERIC .T.
            READONLY .T.
     END TEXTBOX 

     DEFINE SLIDER Slider_4
            ROW    298
            COL    460
            WIDTH  210
            HEIGHT 30
            VALUE  nR2
            RANGEMIN 0
            RANGEMAX 255
            NOTICKS .T.
            ONCHANGE ( nR2 := Colors.Slider_4.Value, cClr2 := cClrString( nR2, nG2, nB2 ), Colors.Text_8.Value := cClr2, Colors.Text_5.Value := nR2, oBrw:Refresh() )
     END SLIDER  

     DEFINE LABEL Label_7
            ROW    342
            COL    380
            WIDTH  20
            HEIGHT 24
            VALUE "G"
     END LABEL  

     DEFINE TEXTBOX Text_6
            ROW    340
            COL    400
            WIDTH  40
            HEIGHT 24
            VALUE  nG2
            NUMERIC .T.
            READONLY .T.
     END TEXTBOX 

     DEFINE SLIDER Slider_5
            ROW    336
            COL    460
            WIDTH  210
            HEIGHT 30
            VALUE  nG2
            RANGEMIN 0
            RANGEMAX 255
            NOTICKS .T.
            ONCHANGE ( nG2 := Colors.Slider_5.Value, cClr2 := cClrString( nR2, nG2, nB2 ), Colors.Text_8.Value := cClr2, Colors.Text_6.Value := nG2, oBrw:Refresh() )
     END SLIDER  

     DEFINE LABEL Label_8
            ROW    382
            COL    380
            WIDTH  20
            HEIGHT 24
            VALUE "B"
     END LABEL  

     DEFINE TEXTBOX Text_7
            ROW    380
            COL    400
            WIDTH  40
            HEIGHT 24
            VALUE  nB2
            NUMERIC .T.
            READONLY .T.
     END TEXTBOX 

     DEFINE SLIDER Slider_6
            ROW    376
            COL    460
            WIDTH  210
            HEIGHT 30
            VALUE  nB2
            RANGEMIN 0
            RANGEMAX 255
            NOTICKS .T.
            ONCHANGE ( nB2 := Colors.Slider_6.Value, cClr2 := cClrString( nR2, nG2, nB2 ), Colors.Text_8.Value := cClr2, Colors.Text_7.Value := nB2, oBrw:Refresh() )
     END SLIDER  

     DEFINE TEXTBOX Text_8
            ROW    420
            COL    400
            WIDTH  140
            HEIGHT 24
            VALUE cClr2
     END TEXTBOX 

     DEFINE BUTTON Button_2
           ROW    420
           COL    550
           WIDTH  120
           HEIGHT 26
           CAPTION "< Copy To Clipboard"
           ACTION System.Clipboard := cClr2
     END BUTTON  

     ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Colors
   ACTIVATE WINDOW Colors

RETURN NIL

////////////////////////////////////////
PROCEDURE CorrectionFirstLast( oBrw )
////////////////////////////////////////

  IF oBrw:nRowCount() == oBrw:nRowPos()
    oBrw:Refresh( .F. )
  ENDIF

  IF oBrw:nLogicPos() > 0 .and. oBrw:nRowPos() == 1
    oBrw:Refresh( .F. )
  ENDIF

RETURN

////////////////////////////////////////
STATIC FUNCTION cClrString( nR, nG, nB )
////////////////////////////////////////

RETURN( "RGB( " + str( nR, 3, 0 ) + ", " + str( nG, 3, 0 ) + ", " + str( nB, 3, 0 ) + " )" )
