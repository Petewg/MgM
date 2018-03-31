/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2014 Andrey Verchenko <verchenkoag@gmail.com>
 * Copyright 2014 Igor Nazarov <047545@mail.ru>
 *
*/

#include "MiniGUI.ch"
#include "TSBrowse.ch"

MEMVAR oBrw

FUNCTION Main()

   LOCAL aVar := {}, nI := 1
   PUBLIC oBrw

   /////////////////////// Building Array for Browse  ////////////////////////////
   AAdd( aVar, { nI++, "nClrText", "Color of text in a table cell", CLR_BLUE, 32768              } )
   AAdd( aVar, { nI++, "nClrPane", "Color of background in a table cell", CLR_HGRAY, 15773696           } )
   AAdd( aVar, { nI++, "nClrHeadFore", "Color of header text in a table", CLR_YELLOW, 16777215           } )
   AAdd( aVar, { nI++, "nClrHeadBack", "Color of header background in a table", CLR_BLACK, { 11048235, 6174208 } } )
   AAdd( aVar, { nI++, "nClrForeFocu", "Color of text in a focused cell", CLR_YELLOW, 16711680           } )
   AAdd( aVar, { nI++, "nClrFocuBack", "Color of cursor background", CLR_RED, { 4915199, 255 }      } )
   AAdd( aVar, { nI++, "nClrEditFore", "Color of text for editing field", CLR_BLACK, 0                  } )
   AAdd( aVar, { nI++, "nClrEditBack", "Color of background for editing field", CLR_WHITE, 16777215           } )
   AAdd( aVar, { nI++, "nClrFootFore", "Color of text for footer", CLR_BLUE, 0                  } )
   AAdd( aVar, { nI++, "nClrFootBack", "Color of background for footer", RGB( 255, 128, 64 ), { 11048235, 6174208 } } )
   AAdd( aVar, { nI++, "nClrSeleFore", "Color of text for selected cell no focused", CLR_GRAY, 12632256           } )
   AAdd( aVar, { nI++, "nClrSeleBack", "Color of background for selected cell no focused", CLR_HGRAY, { 8421504, 16448250 } } )
   AAdd( aVar, { nI++, "nClrOrdeFore", "Color of text for header of selected order", CLR_BLUE, 0                  } )
   AAdd( aVar, { nI++, "nClrOrdeBack", "Color of background for header of selected order", CLR_HGREEN, 15790320           } )
   AAdd( aVar, { nI++, "nClrLine", "Color of lines between a table cells", CLR_HRED, 10526880           } )
   AAdd( aVar, { nI++, "nClrSupHeadFore", "Color of text for super header", CLR_WHITE, 0                  } )
   AAdd( aVar, { nI++, "nClrSupHeadBack", "Color of background for super header", CLR_BLACK, 15773696           } )
   AAdd( aVar, { nI++, "nClrSpecHeadFore", "Color of text for special header", CLR_WHITE, 0                  } )
   AAdd( aVar, { nI++, "nClrSpecHeadBack", "Color of background for special header", CLR_BLACK, 16777215           } )
   AAdd( aVar, { nI,   "nClrSpecHeadActive", "Color of active special header", CLR_YELLOW, 255                } )

   SET FONT TO "Arial", 9

   DEFINE WINDOW Form_Colors AT 0, 0 WIDTH 727 HEIGHT 590 ;
      TITLE "TSBrowse Colors (discoloration and save a color entry in the file)" ;
      MAIN ;
      BACKCOLOR CLR_GRAY ;
      NOMAXIMIZE NOSIZE

   MyButtonsBottom( aVar )  // buttons at the bottom of the window

   DEFINE TBROWSE oBrw ;
      AT     20, 20 ;
      WIDTH  680 ;
      HEIGHT 480 ;
      ON CHANGE {|| CorrectionFirstLast( oBrw ) };
      CELL
   END TBROWSE

   oBrw:SetArray( aVar )

   ADD COLUMN TO TBROWSE oBrw DATA ARRAY ELEMENT 1;
      HEADER CRLF + "#";
      SIZE 40;
      COLORS { CLR_BLACK, WHITE } ;
      ALIGN DT_CENTER

   ADD COLUMN TO TBROWSE oBrw DATA ARRAY ELEMENT 2;
      HEADER CRLF + "Variable name";
      SIZE 170;
      COLORS { CLR_BLACK, WHITE } ;
      ALIGN DT_LEFT

   ADD COLUMN TO TBROWSE oBrw DATA ARRAY ELEMENT 3;
      HEADER CRLF + "Name in the table";
      SIZE 340;
      COLORS { CLR_BLACK, WHITE } ;
      ALIGN DT_LEFT

   ADD COLUMN TO TBROWSE oBrw DATA {|| '***' };
      HEADER "Color " + CRLF + " User" + CRLF + "(change!!!)";
      SIZE 80;
      ALIGN DT_CENTER;
      MOVE DT_MOVE_DOWN;
      EDITABLE

   ADD COLUMN TO TBROWSE oBrw DATA {|| '.' } ;
      HEADER CRLF + "Color by " + CRLF + " default";
      SIZE 80;
      ALIGN DT_CENTER

   ADD  SUPER  HEADER TO oBrw ;
      FROM  COLUMN  1         ;
      TO  COLUMN 3            ;
      HEADER "Basic description"

   ADD   HEADER TO oBrw ;
      FROM   4         ;
      TO   5            ;
      HEADER "Used Color"

   oBrw:SetColor( { 2 }, { {|| SetNewColor( oBrw, 4 ) } }, 4 )    // показ цвета из aVar[4]
   oBrw:aColumns[ 4 ]:bPrevEdit := {|| ColorPicker( oBrw ), FALSE }  // редактирование 4-колонки

   oBrw:SetColor( { 2 }, { {|| SetNewColor( oBrw, 5 ) } }, 5 )    // показ цвета из aVar[5]

   ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   //oBrw:lCellBrw := .F.   // маркер на всю таблицу / Marker on the entire table

   // take a look for description in the source h_tbrowse.prg
   oBrw:lNoGrayBar  := .T.  // не показывать неактивный курсор
   oBrw:nAdjColumn  := 2    // раст€нуть колонку 2 до заполнени€ пустоты в бровсе справа
   oBrw:nHeightCell += 6    // к высоте строк по умолчпанию  добавить 6 пиксела

   oBrw:nHeightSuper := 24  // высота заголовка ( сложного,  составного )

   oBrw:nHeightHead += 4    // к высоте строки заголовка по умолчпанию добавить 4 пиксела
   oBrw:lNoHScroll  := .F.  // показ горизонтального скролинга

   oBrw:lFooting := .T.     // использовать подвал
   oBrw:lDrawFooters := .T. // рисовать  подвалы
   oBrw:nHeightFoot := 20   // высота строки подвала
   oBrw:DrawFooters()       // выполнить прорисовку подвала

   oBrw:aColumns[ 3 ]:cFooting := "Footing of the column 3" // установить значение подвала колонки 3

   oBrw:ResetVScroll()      // показ вертикального скролинга

   //рамочный курсор в 4 и 5 колонке
   oBrw:SetColor( { 6 }, { -CLR_HRED }, 4 )
   oBrw:SetColor( { 6 }, { -CLR_HRED }, 5 )

   oBrw:Refresh( .T. )

   oBrw:nAt := 5     // передвинуть ћј– ≈– на 5 строку
   oBrw:nCell := 3   // передвинуть ћј– ≈– на 3 колонку
   // OR in one line
   //oBrw:GoPos( 5,3 )   // передвинуть ћј– ≈– на 5 строку и 3 колонку
   Form_Colors.oBrw.SetFocus

   CENTER WINDOW Form_Colors
   ACTIVATE WINDOW Form_Colors

RETURN NIL

//////////////////////////////////////////////////////////////////
PROCEDURE CorrectionFirstLast( oBrw )

   IF oBrw:nRowCount() == oBrw:nRowPos()
      oBrw:Refresh( .F. )
   ENDIF

   IF oBrw:nLogicPos() > 0 .AND. oBrw:nRowPos() == 1
      oBrw:Refresh( .F. )
   ENDIF

RETURN

//////////////////////////////////////////////////////////////////
FUNCTION ColorPicker( oBrw )

   LOCAL aColor

   aColor := n2RGB( oBrw:aArray[ oBrw:nAt ][ oBrw:nCell ] ) // получить цвет из текущей €чейки
   aColor := GetColor( aColor )            // стандартное меню цвета
   IF aColor[ 1 ] # NIL
      // поместить новый цвет в текущую €чейку
      oBrw:aArray[ oBrw:nAt ][ oBrw:nCell ] := RGB( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )
   ENDIF

RETURN NIL

///////////////////////////////////////////////////////////////////
FUNCTION SetNewColor( oBrw, nCol )

RETURN oBrw:aArray[ oBrw:nAt ][ nCol ]

///////////////////////////////////////////////////////////////////
FUNCTION n2RGB( nColor )

   LOCAL nR, nG, nB
   LOCAL cColor := NTOC( nColor, 16 )

   nR := CTON( SubStr( cColor, 5, 2 ), 16 )
   nG := CTON( SubStr( cColor, 3, 2 ), 16 )
   nB := CTON( SubStr( cColor, 1, 2 ), 16 )

RETURN { nR, nG, nB }

///////////////////////////////////////////////////////////////////
FUNCTION ViewColorTbrws( oBrw, nCol, aVar )

   LOCAL nI, nJ, nNew

   FOR nI := 1 TO Len(oBrw:aArray)   
     nNew := aVar[nI,1]

     FOR nJ := 1 to 3  // мен€ем цвет “ќЋ№ ќ по 3 колонкам
       IF !((nNew = 16 .OR. nNew = 17) .AND. nJ > Len( oBrw:aSuperHead))
	  oBrw:SetColor( { nNew }, { oBrw:aArray[nI][nCol] }, nJ )
       ENDIF
     NEXT
   NEXT

   oBrw:Refresh( .T. )

   DoMethod( "Form_Colors", "oBrw", "SetFocus" )  // back focus on the table

RETURN NIL

///////////////////////////////////////////////////////////////////
FUNCTION SaveFileColor( oBrw, nCol, cFile, aVar )

   LOCAL oCol, aColor, cFilePath := GetStartUpFolder() + "\" + cFile
   LOCAL nI, cStr := "[" + SubStr( cFile, 1, At( ".", cFile ) -1 ) + "]" + CRLF

   oCol := oBrw:aColumns[ nCol ]
   oCol:SaveColor()
   aColor := oCol:aColorsBack

   FOR nI := 1 TO 20
      cStr += "Line_" + LTrim( Str( nI ) ) + iif( nI < 10, "  = ", " = " )
      cStr += '{'
      //cStr += ' "'+ ALLTRIM(aVar[nI,2]) + '"' + SPACE(18-LEN(ALLTRIM(aVar[nI,2]))) + ' ,'
      cStr += ' "' + AllTrim( aVar[ nI, 3 ] ) + '"' + Space( 60 -Len( AllTrim( aVar[ nI, 3 ] ) ) ) + ' ,'
      IF ValType( aColor[ nI ] ) == "N"
         cStr += ' ' + PadR( hb_ntos( aColor[ nI ] ), 12 )
      ELSE
         cStr += ' ' + hb_ValToExp( aColor[ nI ] )
      ENDIF
      cStr += ' }' + CRLF
   NEXT

   hb_MemoWrit( cFilePath, cStr + CRLF )

   MsgInfo( "Colors are written successfully to the file " + CRLF + CRLF + ;
      cFilePath + CRLF + CRLF )

   DoMethod( "Form_Colors", "oBrw", "SetFocus" )  // back focus on the table

RETURN NIL

///////////////////////////////////////////////////////////////////
FUNCTION MyButtonsBottom( aVar )  // buttons at the bottom of the window

   @ 510, 20 BUTTONEX BUTTON_1 ;
      CAPTION "Show Colors column:" + CRLF + "Color User !" ;
      ACTION ViewColorTbrws( oBrw, 4, aVar ) ;
      WIDTH 150 HEIGHT 38

   @ 510, 190 BUTTONEX BUTTON_2 ;
      CAPTION "Record colors in" + CRLF + "ColorUser.txt" ;
      ACTION SaveFileColor( oBrw, 3, "ColorUser.txt", aVar ) ;
      WIDTH 100 HEIGHT 38

   @ 510, 320 BUTTONEX BUTTON_3 ;
      CAPTION "Show Colors column:" + CRLF + "Color by default !" ;
      ACTION ViewColorTbrws( oBrw, 5, aVar ) ;
      WIDTH 150 HEIGHT 38

   @ 510, 490 BUTTONEX BUTTON_4 ;
      CAPTION "Record colors in" + CRLF + "ColorDefault.txt" ;
      ACTION SaveFileColor( oBrw, 4, "ColorDefault.txt", aVar ) ;
      WIDTH 100 HEIGHT 38
   			
   @ 510, 620 BUTTONEX BUTTON_5 ;
      CAPTION "Exit" ;
      ACTION ReleaseAllWindows();
      WIDTH 80 HEIGHT 38

RETURN NIL
