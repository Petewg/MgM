// Browsing an array with TSBrowse
#include "MiniGui.ch"
#include "TSBrowse.ch"
/*
#define CLR_PINK   RGB( 255, 128, 128)
#define CLR_NBLUE  RGB( 128, 128, 192)
*/
Function SBArray()

   Local oLbx, bData, bcolor, bAlign, bDelete, aBmp[ 2 ], Arr1, ;
         nTot2, nTot3, nGood, nBad, nPreVal

   IF !_IsControlDefined ("oBrw","Form_5")

      Arr1 := {}
      AADD( Arr1, {"Ena         ", 100, 200} )
      AADD( Arr1, {"Dyo         ", 125, 200} )
      AADD( Arr1, {"Tria        ", 130, 200} )
      AADD( Arr1, {"Tessera     ", 135, 200} )
      AADD( Arr1, {"Pente       ", 140, 200} )
      AADD( Arr1, {"Exi         ", 145, 200} )
      AADD( Arr1, {"Epta        ", 150, 200} )
      AADD( Arr1, {"Okto        ", 100, 200} )
      AADD( Arr1, {"Ennea       ", 100, 200} )
      AADD( Arr1, {"Deka        ", 100, 200} )
      AADD( Arr1, {"Enteka      ", 100, 200} )
      AADD( Arr1, {"Dodeka      ", 100, 200} )
      AADD( Arr1, {"Dekatria    ", 100, 200} )
      AADD( Arr1, {"Dekatessera ", 100, 200} )
      AADD( Arr1, {"Dekapente   ", 100, 200} )
      AADD( Arr1, {"Dekaexi     ", 100, 200} )
      AADD( Arr1, {"Dekaepta    ", 100, 300} )
      AADD( Arr1, {"Dekaokto    ", 100, 200} )

      nTot2 := nTot3 := nGood := nBad := nPreVal := 0

      // footers values at start
      AEval( Arr1, { | e | nTot2 += e[ 2 ], nTot3 += e[ 3 ], ;
                        If( ( e[ 2 ] + e[ 3 ] ) < 325, ++nGood, ++nBad ) } )

      aBmp:= { LoadImage( "Bitmaps\Level1.bmp" ), ;
               LoadImage( "Bitmaps\Level2.bmp" )}

      DEFINE WINDOW Form_3 ;
         AT 150,100 ;
         WIDTH 500 HEIGHT 400 ;
         TITLE "MiniGUI TsBrowse  ( Browsing an array ) " ;
         ICON "Demo.ico" ;
         FONT "MS Sans Serif" SIZE 8 ;
         CHILD

         DEFINE TBROWSE oLbx AT 10,15  ;
            OF Form_3 WIDTH 470 HEIGHT 290 CELLED;
            COLORS  {CLR_BLACK, CLR_NBLUE}

         oLbx:SetArray( Arr1 ) // this is necessary to work with arrays

      // let's define the block for background color
         bColor := { || If( oLbx:nAt % 2 == 0, CLR_PINK, CLR_NBLUE ) }

         ADD COLUMN TO TBROWSE oLbx DATA ARRAY ELEMENT 1;
            TITLE "Col 1" ;
            SIZE 120 EDITABLE;          // this column is editable
            COLORS CLR_BLACK, bColor;   // background color from a Code Block
            3DLOOK TRUE, TRUE, TRUE;    // cells, titles, footers
            MOVE DT_MOVE_NEXT;          // cursor goes to next editable column
            VALID { | uVar | ! Empty( uVar ) }; // don't want empty rows
            ALIGN DT_LEFT, DT_CENTER, DT_RIGHT; // cells, title, footer
            FOOTER "Totals->"

         ADD COLUMN TO TBROWSE oLbx DATA ARRAY ELEMENT 2;
            TITLE "Col 2"  ;
            ALIGN DT_RIGHT, DT_CENTER;  // let's align cells to right and center title
            SIZE 80 EDITABLE;           // this column is editable
            COLORS CLR_BLACK, bColor;   // background color from a Code Block
            3DLOOK TRUE, TRUE, TRUE;    // cells, titles, footers
            MOVE DT_MOVE_NEXT;          // cursor goes to next editable column
            FOOTER { || Transform( nTot2, "##,###" ) };  // must be a code block
            PREEDIT { | uVar | nPreVal := uVar }; // updating footer value
            POSTEDIT { | uVar | nTot2 += ( uVar - nPreval ), ;
                           If( Eval( oLbx:aColumns[ 4 ]:bData ) < 325, ;
                           If( oLbx:lChanged, ( ++nGood, --nBad ), Nil ), ;
                           If( oLbx:lChanged, ( ++nBad, --nGood ), Nil ) ), ;
                           oLbx:DrawFooters() }

         ADD COLUMN TO TBROWSE oLbx DATA ARRAY ELEMENT 3;
            TITLE "Col 3"  ;
            ALIGN DT_RIGHT, DT_CENTER;  // let's align cells to right and center title
            SIZE 80  EDITABLE;          // this column is editable
            COLORS CLR_BLACK, bColor;   // background color from a Code Block
            3DLOOK TRUE, TRUE, TRUE;    // cells, titles, footers
            MOVE DT_MOVE_NEXT;          // cursor goes to next editable column
            FOOTER { || Transform( nTot3, "##,###" ) };  // must be a code block
            PREEDIT { | uVar | nPreVal := uVar }; // updating footer value
            POSTEDIT { | uVar | nTot3 += ( uVar - nPreval ), ;
                           If( Eval( oLbx:aColumns[ 4 ]:bData ) < 325, ;
                           If( oLbx:lChanged, ( ++nGood, --nBad ), Nil ), ;
                           If( oLbx:lChanged, ( ++nBad, --nGood ), Nil ) ), ;
                           oLbx:DrawFooters() }

      // next column is not part of the array, then bData must be defined apart
         bData := { || If( ! oLbx:lAppendMode, ;
                     oLbx:aArray[ oLbx:nAt, 2 ] + ;
                     oLbx:aArray[ oLbx:nAt, 3 ], 0 ) }

      // dynamic setting of background color for next column depending on cell's value
         bColor := { || If( Eval( oLbx:aColumns[ 4 ]:bData ) < 325, CLR_RED, CLR_CYAN ) }

         ADD COLUMN TO TBROWSE oLbx DATA bData;
            TITLE "Col 4"  ;
            ALIGN DT_RIGHT, DT_CENTER;  // let's align cells to right and center title
            SIZE 80;                    // this column is NOT editable
            COLORS CLR_WHITE, bColor;   // background color from a Code Block
            3DLOOK TRUE, TRUE, TRUE;    // cells, titles, footers
            FOOTER { || Transform( nTot2 + nTot3, "##,###" ) }

      // with next column let's try BitMaps on cells with dynamic alignment
         bData := { || If( Eval( oLbx:aColumns[ 4 ]:bData ) < 325, ;
                     aBmp[ 1 ], aBmp[ 2 ] ) }

      // new V.7.0 merging data and bitmaps at specific cell position
      // a value greater than 4 in HiWord, means specific pixel location from column left
         bAlign := { || nMakeLong( DT_LEFT, ; // LoWord = data alignment
                  If( Eval( oLbx:aColumns[ 4 ]:bData ) < 325, ;
                      10, 50 ) ) }      // HiWord = bitmap alignment

         ADD COLUMN TO TBROWSE oLbx DATA bData ;
            BITMAP;                           // tells TSBrowse that data is a BitMap
            TITLE "Result" + CRLF + "Good      Bad"; // Multi-Line heading
            ALIGN bAlign, DT_CENTER, DT_CENTER; // cell, title, footer
            SIZE 71;                            // this column is NOT editable
            3DLOOK TRUE, TRUE, TRUE;            // cells, titles, footers
            FOOTER { || Str( nGood, 4 ) + " Good" + CRLF + ;
                Str( nBad, 4 ) + " Bad" }  // Multi-Line footer

      // activating Auto Append Mode
         oLbx:SetAppendMode( .T. )

      // activating Auto Delete Mode
      // I'll use bDelete code block to update footers
         bDelete := { | nAt, oBrw | nTot2 -= oBrw:aArray[ nAt, 2 ], ;
                              nTot3 -= oBrw:aArray[ nAt, 3 ], ;
                              If( ( oBrw:aArray[ nAt, 2 ] + ;
                                    oBrw:aArray[ nAt, 3 ] ) < 325, ;
                                    --nGood, --nBad ), oBrw:DrawFooters() }

         oLbx:SetDeleteMode( .T., .T., bDelete ) // ( lOnOff, lConfirm, bDelete )

      // Assigning default values to new elements created with Auto Append.
      // For last column (5), I'm using a code block to update footers without
      // assigning any value to that column, since code block returns Nil
         oLbx:aDefault := { Nil, 50, 50, Nil, ;
                      { || nTot2 += 50, nTot3 += 50, ++nGood, ;
                           oLbx:DrawFooters(), Nil } }

      // using Super Titles
         ADD SUPER HEADER TO oLbx FROM COLUMN 2 TO COLUMN 3 ;
            TITLE "Col2 and Col 3" 3DLOOK

      // increasing cell and super header height
         oLbx:nHeightCell += 2
         oLbx:nHeightSuper += 7
         END TBROWSE

      END WINDOW

      ACTIVATE WINDOW Form_3
   endif
Return Nil


FUNCTION TsGrid

   Local aRows [20] [8] , Grid1 , hFont
   Local aTab := {}

   aRows [1]   := {1,'Simpson','Homer','555-5555',113.12,date(),1 , .t. }
   aRows [2]   := {3,'Mulder','Fox','324-6432',123.12,date(),2 , .f. }
   aRows [3]   := {2,'Smart','Max','432-5892',133.12,date(),3 , .t. }
   aRows [4]   := {1,'Grillo','Pepe','894-2332',143.12,date(),4 , .f. }
   aRows [5]   := {2,'Kirk','James','346-9873',153.12,date(),5 , .t. }
   aRows [6]   := {1,'Barriga','Carlos','394-9654',163.12,date(),6 , .f. }
   aRows [7]   := {3,'Flanders','Ned','435-3211',173.12,date(),7 , .t. }
   aRows [8]   := {3,'Smith','John','123-1234',183.12,date(),8 , .f. }
   aRows [9]   := {2,'Pedemonti','Flavio','000-0000',193.12,date(),9 , .t. }
   aRows [10]  := {2,'Gomez','Juan','583-4832',113.12,date(),10, .f. }
   aRows [11]  := {3,'Fernandez','Raul','321-4332',123.12,date(),11, .t. }
   aRows [12]  := {1,'Borges','Javier','326-9430',133.12,date(),12, .f. }
   aRows [13]  := {2,'Alvarez','Alberto','543-7898',143.12,date(),13, .t. }
   aRows [14]  := {1,'Gonzalez','Ambo','437-8473',153.12,date(),14, .f. }
   aRows [15]  := {1,'Batistuta','Gol','485-2843',163.12,date(),15, .t. }
   aRows [16]  := {1,'Vinazzi','Amigo','394-5983',173.12,date(),16, .f. }
   aRows [17]  := {2,'Pedemonti','Flavio','534-7984',183.12,date(),17, .t. }
   aRows [18]  := {1,'Samarbide','Armando','854-7873',193.12,date(),18, .f. }
   aRows [19]  := {3,'Pradon','Alejandra','???-????',113.12,date(),19, .t. }
   aRows [20]  := {1,'Reyes','Monica','432-5836',123.12,date(),20, .f. }

   DEFINE FONT Font_1  FONTNAME "Arial" SIZE 12 UNDERLINE ITALIC
   hFont := GetFontHandle( "Font_1"  )

   DEFINE WINDOW Form_11 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 500 ;
      TITLE 'TsBrowse of form Grid Test' ;
      CHILD

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Set Item'   ACTION SetItem(Grid1)
            MENUITEM 'Get Item'   ACTION GetItem(Grid1)
         END POPUP
      END MENU
                                                                //    +Chr(13)+'Handy'
//      DEFINE TBROWSE Grid1 AT 10,10  ARRAY aTab;
      @ 10,10 TBROWSE Grid1 ARRAY aTab;
      WIDTH 620 ;
      HEIGHT 326 ;
      HEADERS ' ','Last~Name','First~Name','Phone','Value~Data Types','Date~Data Types','Num.~Data Types','Logic~Data Types' ;
      WIDTHS 18,100,100,100,100,80,40,35 ;
      PICTURE '','@K !xxxxxxxxxxxxxxxxx','@K !xxxxxxxxxxxxxxxxx','@K 999-9999','@K 999,999.99' ;
      IMAGE "br_em","br_ok","br_no";
      EDIT CELLED;
      JUSTIFY { DT_CENTER, DT_LEFT, DT_LEFT, DT_CENTER, DT_RIGHT, DT_CENTER, DT_RIGHT, DT_CENTER}

      Grid1:nLineStyle :=  LINES_VERT
      Grid1:nHeightCell += 1
      Grid1:nHeightHead += 10
      Grid1:nHeightSuper+= 15
      Grid1:Set3DText( .F., .F. )
      Grid1:ChangeFont( hFont, 4, 4 )   // 4 = SupeColumn  4 = Nivel SuperHeader

      Grid1:SetColor( { 1, 3, 5, 6, 13, 15 ,17}, ;
                      { CLR_BLACK,  CLR_YELLOW, CLR_WHITE, ;
                      { CLR_HBLUE, CLR_BLUE }, ; // degraded cursor background color
                        CLR_HGREEN, CLR_BLACK ,;
                        CLR_HRED } )  // text superheader
      Grid1:SetColor( { 2, 4, 14,16 }, ;
                      { { CLR_WHITE, CLR_HGRAY }, ;  // degraded cells background color
                      { CLR_WHITE, CLR_NBLUE }, ;  // degraded headers backgroud color
                      { CLR_HGREEN, CLR_BLACK }, ;  // degraded order column background color
                      { CLR_NBLUE, CLR_WHITE }  } ) // degraded superheaders backgroud color

      Grid1:SetColor( {17}, {CLR_HGREEN}, 4 )


      Grid1:SetDeleteMode( .T., .T.)   // Activate Key DEL and confirm
      Grid1:SetSelectMode( .t.)


//         END TBROWSE

      @ 360,50 BUTTON Btn_1 ;
            CAPTION "Load Array" ;
            ACTION LoadTabDan(Grid1,aRows);
            WIDTH 80 ;
            HEIGHT 28

      @ 360,150 BUTTON Btn_2 ;
            CAPTION "Delete Array" ;
            ACTION DeleteTabDan(Grid1);
            WIDTH 80 ;
            HEIGHT 28
      @ 360,250 BUTTON Btn_3 ;
            CAPTION "Delete Row" ;
            ACTION DeleteRow(Grid1);
            WIDTH 80 ;
            HEIGHT 28

      @ 360,350 BUTTON Btn_4 ;
            CAPTION "Add Row" ;
            ACTION AddNextRow(Grid1,aRows);
            WIDTH 80 ;
            HEIGHT 28

   END WINDOW

   CENTER WINDOW Form_11

   ACTIVATE WINDOW Form_11
   RELEASE FONT Font_1

Return nil

FUNCTION LoadTabDan(Grid1,aRow)
   LOCAL n

   DELETE ITEM ALL FROM Grid1 OF Form_11

   Grid1:SetAlign( 1, 1, DT_CENTER )  // ( nCol, nLevel, nAlign )
   Grid1:SetAlign( 4, 1, DT_CENTER )  // ( nCol, nLevel, nAlign )
   Grid1:SetAlign( 5, 1, DT_RIGHT )   // ( nCol, nLevel, nAlign )
   Grid1:SetAlign( 6, 1, DT_CENTER )  // ( nCol, nLevel, nAlign )
   Grid1:SetAlign( 7, 1, DT_RIGHT )   // ( nCol, nLevel, nAlign )
   Grid1:SetAlign( 8, 1, DT_CENTER )  // ( nCol, nLevel, nAlign )

   FOR n :=1 TO 10
//     Grid1:AddItem( aRow[n] )
      ADD ITEM aRow[n] TO Grid1 OF Form_11   // Standard HMG command for TsBrowse
   NEXT
   Grid1:aColumns[ 1 ]:lBitMap   := .t.
   Grid1:aColumns[ 1 ]:lEdit     := .f.
   Grid1:aColumns[ 1 ]:lIndexCol := .F.
   Grid1:aColumns[ 2]:bArraySort := {|x,y| x[2]+x[4] < y[2]+y[4] }
   Grid1:aColumns[ 4]:bArraySort := {|x,y| x[4]+Str(x[5],5,2) < y[4]+Str(x[5],5,2) }
   Grid1:aColumns[ 5]:bArraySort := {|x,y| Str(x[5],5,2)+x[4] < Str(x[5],5,2)+y[4] }

RETURN Nil

FUNCTION DeleteTabDan(Grid1)
    HB_SYMBOL_UNUSED( Grid1 )

//     Grid1:DeleteRow( .t. )  //
   DELETE ITEM ALL FROM Grid1 OF Form_11

RETURN Nil

FUNCTION DeleteRow(Grid1)
//     Grid1:DeleteRow( )   // Default selected row
   DELETE ITEM Grid1:nAt FROM Grid1 OF Form_11

RETURN Nil

FUNCTION AddNextRow(Grid1,aRows)
   LOCAL nAt := Min(Len(aRows),Grid1:nLen)
   //     Grid1:AddItem( aRows[nAt] )
      ADD ITEM aRows[nAt] TO Grid1 OF Form_11   // Standard HMG command for TsBrowse

RETURN Nil

PROCEDURE SETITEM(Grid1)

   Grid1:aArray[Grid1:nAt] := {1,'Gonzo','Alfred','???-????', 321.45 , date()-10 ,  101 , .T. }
   Grid1:Refresh( .F. )
//   Grid1:nHeightSuper += 10

RETURN

PROCEDURE GETITEM(Grid1)
local a

   a := Grid1:aArray[Grid1:nAt]
   aEval( a, {|x,i| msginfo ( xChar ( x ), ltrim( str ( i ) ), , .f. ) } )

RETURN
