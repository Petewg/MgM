/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2014 Andrey Verchenko <verchenkoag@gmail.com>
 * Copyright 2014 Igor Nazarov <047545@mail.ru>
 *
*/
#include "MiniGUI.ch"
#include "TSBrowse.ch"

MEMVAR oBrwClr 

/////////////////////////////////////////////////////////////////////////////////
// Function: Change color TBROWSE
FUNCTION Form_color()
   LOCAL aVar := {},  nI:=1, aRetColor
   LOCAL aBackColor := {122,161,230}
   LOCAL nFBSize := 10, aFontColor := WHITE    // font size / color buttons
   LOCAL nLenButt := 160 , nHButt  := 55       // width/height button 
   PUBLIC oBrwClr 

   /////////////////////// Building Array for Browse  ////////////////////////////
   AADD( aVar, { nI++, "nClrText"           , "Color of text in the table cells"                                  , CLR_BLUE        , 0                  } )
   AADD( aVar, { nI++, "nClrPane"           , "Background color in table cells"                                   , CLR_HGRAY       , 15773696           } )
   AADD( aVar, { nI++, "nClrHeadFore"       , "Color of text the column header of the table"                      , CLR_YELLOW      , 16777215           } )
   AADD( aVar, { nI++, "nClrHeadBack"       , "Background color of the column header of the table"                , RGB(255,128,128), {11048235,6174208} } )
   AADD( aVar, { nI++, "nClrForeFocu"       , "Color of the text cursor, text in the cells with a focus"          , CLR_YELLOW      , 16711680           } )
   AADD( aVar, { nI++, "nClrFocuBack"       , "Background color of the cursor/marker"                             , CLR_RED         , {4915199,255}      } )
   AADD( aVar, { nI++, "nClrEditFore"       , "Color of text edit field"                                          , CLR_HRED        , CLR_HRED           } )
   AADD( aVar, { nI++, "nClrEditBack"       , "Background color of editable fields"                               , CLR_YELLOW      , CLR_YELLOW         } )
   AADD( aVar, { nI++, "nClrFootFore"       , "Color of text of the basement"                                     , CLR_BLUE        , 0                  } )
   AADD( aVar, { nI++, "nClrFootBack"       , "Background color of of the basement"                               , RGB(255,128,64) , {11048235,6174208} } )
   AADD( aVar, { nI++, "nClrSeleFore"       , "Color text of cursor inactive (selected cell no focused)"          , CLR_GRAY        , 12632256           } )
   AADD( aVar, { nI++, "nClrSeleBack"       , "Background color of the inactive cursor (selected cell no focused)", CLR_HGRAY       , {8421504,16448250} } )
   AADD( aVar, { nI++, "nClrOrdeFore"       , "Color of text of the column header of the selected index"          , CLR_BLUE        , 0                  } )
   AADD( aVar, { nI++, "nClrOrdeBack"       , "Background color of of the column header of the selected index"    , CLR_HGREEN      , 15790320           } )
   AADD( aVar, { nI++, "nClrLine"           , "Color of lines between table cells"                                , CLR_HRED        , 10526880           } )
   AADD( aVar, { nI++, "nClrSupHeadFore"    , "Color of background for super header"                              , RGB(255,236,120), { RGB( 128, 128, 192), CLR_WHITE }  } )
   AADD( aVar, { nI++, "nClrSupHeadBack"    , "Color of text for super header"                                    , CLR_BLACK       , CLR_BLUE           } )
   AADD( aVar, { nI++, "nClrSpecHeadFore"   , "Color of background for special header"                            , CLR_WHITE       , 0                  } )
   AADD( aVar, { nI++, "nClrSpecHeadBack"   , "Color of text for special header"                                  , CLR_BLACK       , 16777215           } )
   AADD( aVar, { nI++, "nClrSpecHeadActive" , "Color of active special header"                                    , CLR_YELLOW      , 255                } )

   SET FONT TO "Arial", 9   // Set the default font

   DEFINE WINDOW Form_Colors AT 0,0 WIDTH 727 HEIGHT 610 ;
     TITLE "Color change menu for TBROWSE" ;
     BACKCOLOR aBackColor       ;
     CHILD                      ;
     NOMAXIMIZE NOSIZE

     @ 510,20 BUTTONEX BUTTON_1  WIDTH nLenButt HEIGHT nHButt    ;
         CAPTION "Show Colors column:"+ CRLF +"Color User !" ;
         FONTCOLOR aFontColor             ;
         BACKCOLOR GRAY                   ;
         SIZE nFBSize BOLD                ;    
         NOHOTLIGHT NOXPSTYLE HANDCURSOR  ;
         ACTION ViewColorTbrws(oBrwClr,4,aVar) 

     @ 510,190 BUTTONEX BUTTON_2  WIDTH nLenButt HEIGHT nHButt  ;
         CAPTION "Show Colors column:"+ CRLF +"Color by default !" ;
         FONTCOLOR aFontColor             ;
         BACKCOLOR {0, 176, 240}          ;
         SIZE nFBSize BOLD                ;    
         NOHOTLIGHT NOXPSTYLE HANDCURSOR  ;
         ACTION ViewColorTbrws(oBrwClr,5,aVar) 

     @ 510,430 BUTTONEX BUTTON_3  WIDTH nLenButt HEIGHT nHButt  ;
         CAPTION "Transfer to TBROWSE"+ CRLF +"a current color" ;
         FONTCOLOR aFontColor             ;
         BACKCOLOR LGREEN                 ;
         SIZE nFBSize BOLD                ;    
         NOHOTLIGHT NOXPSTYLE HANDCURSOR  ;
         ACTION ( aRetColor := RetSaveColor(oBrwClr), ThisWindow.Release ) 
  			
     @ 510,600 BUTTONEX BUTTON_4  WIDTH nLenButt-58 HEIGHT nHButt ;
         CAPTION "Exit"                   ;
         FONTCOLOR aFontColor             ;
         BACKCOLOR MAROON                 ;
         SIZE nFBSize BOLD                ;    
         NOHOTLIGHT NOXPSTYLE HANDCURSOR  ;
         ACTION ( aRetColor := {} , ThisWindow.Release ) 
   
     DEFINE TBROWSE oBrwClr ; 
            AT     20,20 ; 
            WIDTH  680 ; 
            HEIGHT 480 ;
            ON CHANGE { || CorrectionFirstLast( oBrwClr ) };
            CELL         
     END TBROWSE  

     oBrwClr:SetArray( aVar )

     ADD COLUMN TO TBROWSE oBrwClr DATA ARRAY ELEMENT 1;  
       HEADER CRLF + "No";
       SIZE 40;
       COLORS {CLR_BLACK, WHITE} ;
       ALIGN DT_CENTER

     ADD COLUMN TO TBROWSE oBrwClr DATA ARRAY ELEMENT 2;
       HEADER CRLF + "Variable name";
       SIZE 170;
       COLORS {CLR_BLACK, WHITE} ;
       ALIGN DT_LEFT

     ADD COLUMN TO TBROWSE oBrwClr DATA ARRAY ELEMENT 3;
       HEADER CRLF + "Name in the table";
       SIZE 340;
       COLORS {CLR_BLACK, WHITE} ;
       ALIGN DT_LEFT

     ADD COLUMN TO TBROWSE oBrwClr DATA {|| '***' };  
       HEADER "Color "+ CRLF +" User"+ CRLF +"(change!!!)";
       SIZE 80;
       ALIGN DT_CENTER;
       MOVE DT_MOVE_DOWN;
       EDITABLE 

     ADD COLUMN TO TBROWSE oBrwClr DATA {|| '.' } ; 
       HEADER CRLF + "Color by "+ CRLF +" default";
       SIZE 80;
       ALIGN DT_CENTER

     ADD  SUPER  HEADER TO oBrwClr ;
        FROM  COLUMN  1         ;
        TO  COLUMN 3            ;
        HEADER "Basic description"

     ADD   HEADER TO oBrwClr ;
        FROM   4         ;
        TO   5            ;
        HEADER "Used Color"


       oBrwClr:Setcolor( { 2 }, { { || NewColor(oBrwClr,4) } } , 4 )       // display color of aVar [4] 
       oBrwClr:aColumns[4]:bPrevEdit := { || ColorPicker(oBrwClr), FALSE } // 4-column editing

       oBrwClr:Setcolor( { 2 }, { { || NewColor(oBrwClr, 5) } } , 5 )      // display color of aVar[5] 

     ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   //oBrwClr:lCellBrw := .F.   // Marker on the entire table

   // See description in the source: h_tbrowse.prg
    oBrwClr:lNoGrayBar  := .t.   // Skip the inactive cursor
    oBrwClr:nAdjColumn  := 2     // stretch column 2 to fill the voids in the right brovse
    oBrwClr:nHeightCell += 6     // to the row height on umolchpaniyu add 6 pixels

    oBrwClr:nHeightSuper := 24   // height of the header (the complex, composite)

    oBrwClr:nHeightHead  += 4    // to the height of the title bar on umolchpaniyu add 4 pixels
    oBrwClr:lNoHScroll   := .f.  // Display a horizontal scrolling

    oBrwClr:lFooting     := .T.  // Use the basement
    oBrwClr:lDrawFooters := .T.  // Draw cellars
    oBrwClr:nHeightFoot  := 20   // row height basement
    oBrwClr:DrawFooters()        // perform the drawing of the basement

    oBrwClr:aColumns[3]:cFooting := "Footing column 3" // set the value of the basement columns 3

    oBrwClr:ResetVScroll ()      // display vertical scrolling

    // frame pointer in column 4 and 5
   oBrwClr:Setcolor( { 6 }, { -CLR_HRED } , 4 ) 
   oBrwClr:Setcolor( { 6 }, { -CLR_HRED } , 5 ) 

   oBrwClr:Refresh(.T.)
   
   oBrwClr:nAt := 5         // move the marker on the 5 string
   oBrwClr:nCell := 3       // move the marker on the 3 column
   //oBrwClr:GoPos( 5,3 )   // move the marker on the 5 rows and 3 columns

   Form_Colors.oBrwClr.SetFocus

   CENTER WINDOW Form_Colors
   ACTIVATE WINDOW Form_Colors

RETURN aRetColor  // return an array of colors for TBROWSE

//////////////////////////////////////////////////////////////////
STATIC PROCEDURE CorrectionFirstLast( oBrwClr )

   IF oBrwClr:nRowCount() == oBrwClr:nRowPos()
      oBrwClr:Refresh( .F. )
   ENDIF

   IF oBrwClr:nLogicPos() > 0 .and. oBrwClr:nRowPos() == 1
      oBrwClr:Refresh( .F. )
   ENDIF

RETURN

//////////////////////////////////////////////////////////////////
FUNCTION ColorPicker(oBrwClr)
    LOCAL aColor := {}

    aColor := n2RGB(oBrwClr:aArray[oBrwClr:nAt][oBrwClr:nCell] ) // receive color from the current cell
    aColor := GetColor(aColor)   // standard menu Windows-color
    IF aColor[1] # NIL
       // put a new color in the current cell
       oBrwClr:aArray[oBrwClr:nAt][oBrwClr:nCell] := RGB(aColor[1], aColor[2], aColor[3] ) 
    ENDIF
RETURN NIL

///////////////////////////////////////////////////////////////////
FUNCTION NEWColor(oBrwClr, nCol)
RETURN oBrwClr:aArray[oBrwClr:nAt][nCol] 

///////////////////////////////////////////////////////////////////
FUNCTION n2RGB(nColor)
   LOCAL nR := 0, nG := 0, nB := 0, cColor := NTOC(nColor, 16)

   nR := CTON(SUBSTR( cColor, 5, 2 ), 16)
   nG := CTON(SUBSTR( cColor, 3, 2 ), 16)
   nB := CTON(SUBSTR( cColor, 1, 2 ), 16)
RETURN {nR, nG, nB }

///////////////////////////////////////////////////////////////////
FUNCTION ViewColorTbrws(oBrwClr, nCol, aVar)
   LOCAL nI, nJ, nNew

   FOR nI := 1 TO LEN(oBrwClr:aArray)   
     nNew := aVar[nI,1]

     FOR nJ := 1 to 3  // change the color only on the 3 columns
       IF !((nNew = 16 .OR. nNew = 17) .AND. nJ > Len( oBrwClr:aSuperHead))
           // 16 and 17 of the color array elements are not defined in the class Tbrowse
	  oBrwClr:Setcolor( { nNew }, {  oBrwClr:aArray[nI][nCol]  } , nJ )       
       ENDIF
     NEXT

     IF nI == 3   //  меняем цвет текста шапки таблицы по 4-5 колонке
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 4 ) 
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 5 ) 
  
     ELSEIF nI == 4  //  меняем цвет фона шапки таблицы по 4-5 колонке
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 4 ) 
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 5 ) 

     ELSEIF nI == 9  //  меняем цвет текста подвала таблицы по 4-5 колонке
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 4 ) 
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 5 ) 

     ELSEIF nI == 10 //  меняем цвет фона подвала таблицы по 4-5 колонке
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 4 ) 
       oBrwClr:Setcolor( { nI }, {  oBrwClr:aArray[nI][nCol]  } , 5 ) 
     ENDIF
   NEXT

   oBrwClr:Refresh(.T.)
   DoMethod( 'Form_Colors',"oBrwClr", "SetFocus" )  // focus in the table

RETURN NIL

///////////////////////////////////////////////////////////////////
// Function: save the current color in the array TBROWSE
FUNCTION RetSaveColor(oBrwClr)
   LOCAL oCol, aColor, nCol

   nCol := 1  // 2 or 3 column with color
   oCol := oBrwClr:aColumns[ nCol ]
   oCol:SaveColor()
   aColor := oCol:aColorsBack
   // ------- Remember the colors are not included in the function SaveColor() ----
   aColor[15] := oBrwClr:nClrLine            // Color lines between table cells
   aColor[16] := oBrwClr:aSuperHead[nCol,5]  // Background color of in super header
   aColor[17] := oBrwClr:aSuperHead[nCol,4]  // Color of text in super header

RETURN aColor

///////////////////////////////////////////////////////////////////
