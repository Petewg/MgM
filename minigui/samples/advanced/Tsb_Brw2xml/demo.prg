/*                                                         
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ������� ������� � Excel xls/xml
 * Export table to Excel xls/xml     
*/
                                     
ANNOUNCE RDDSYS

#define _HMG_OUTLOG

#include "hmg.ch"
#include "TSBrowse.ch"

#define  SHOW_WAIT_WINDOW_LINE    1000
#define  SUPERHEADER_ON           .T.
#define  MULTILINE_TSB            .F.

PROCEDURE MAIN( Line )
   LOCAL oBrw, aDatos 
   LOCAL hFont, nFont 
   LOCAL cFontName1 := "Comic Sans MS" 
   LOCAL cFontName2 := _HMG_DefaultFontName
   LOCAL cFontName3 := _HMG_DefaultFontName
   LOCAL cFontName4 := _HMG_DefaultFontName
   LOCAL cFontName5 := _HMG_DefaultFontName
   LOCAL cFontName6 := "Times New Roman"
   LOCAL cFontName7 := "Arial Black"
   LOCAL nFontSize  := 16 
   LOCAL nWwnd, nLine, nHcell, nHSpr, nHhead, nHfoot

   If ! empty(Line) .and. val(Line) > 4 .and. val(Line) < 17
      nLine := val(Line)
   EndIf

   SET DECIMALS TO 4
   SET DATE     TO GERMAN
   SET EPOCH    TO 2000
   SET CENTURY  ON
   SET EXACT    ON
   SET MULTIPLE OFF WARNING 

   SET FONT     TO cFontName1, nFontSize

   DEFINE FONT Font_1  FONTNAME cFontName1 SIZE nFontSize BOLD
   DEFINE FONT Font_2  FONTNAME cFontName2 SIZE nFontSize BOLD
   DEFINE FONT Font_3  FONTNAME cFontName3 SIZE nFontSize 
   DEFINE FONT Font_4  FONTNAME cFontName4 SIZE nFontSize 
   DEFINE FONT Font_5  FONTNAME cFontName5 SIZE nFontSize 
   DEFINE FONT Font_6  FONTNAME cFontName6 SIZE nFontSize 
   DEFINE FONT Font_7  FONTNAME cFontName7 SIZE nFontSize 

   TsbFont()                      // init ����� ������ ��� tsb

   aDatos := CreateDatos(nLine) // ������� ������ ��� ������ � �������

   AAdd( aDatos, GetFontHandle( "Font_7" ) )  // ������ ������ header, footer
   
   // ��������� ������ �������, �������� ���
   hFont := InitFont( cFontName1, nFontSize )    
   nFont := GetTextHeight( 0, "B", hFont ) + 1  // ������ ������ ��� �������
   DeleteObject( hFont )
   
   //nLine:= iif( empty(nLine), 15, nLine )  // ���-�� �����  � �������
   nHcell := nFont + 6                       // ������ ������ � �������

   nHhead := nHfoot := nHSpr := nHcell       // ������ �����, ������� � ����������� ������� ��� ����� ������� 
                                             // ����� ������ ������ ������ � �������, ���� ��� �������, �� * 2
   //nHrow:= nLine * nHcell + 1              // ������ ���� ����� � ������� 
                                             // + 1 ����������� ������ �� XX ������ 
   IF MULTILINE_TSB 
      nHcell := nFont * 3                    // ������ ������ � ������� ��� 3-� �����
      nHhead := nFont * 2                    // ������ ����� ������� ��� 2-� �����
      nHfoot := nFont * 2                    // ������ ������ ������� ��� 2-� �����
      nHSpr  := nFont * 2                    // ������ ����������� ������� ��� 2-� �����
   ENDIF

   IF ! SUPERHEADER_ON    // ��� ����������� ������� - ����� ������ 1 �������
      nHSpr := 1
   ENDIF

   //nHwnd:= nHhead + nHrow + nHfoot + nHSpr + 56 // �������� ������ �������
                                                  // 56=5+46+5 - ������ ������ ����
   nWwnd  := 300 // ������ ���� ����� ����������� � �������� � ������ ������� 

   DEFINE WINDOW test                          ;
      AT 0,0 WIDTH nWwnd HEIGHT 720            ;
      TITLE "SetArray Demo - Export XLS/XLM !" ;
      ICON  "1MAIN_ICO"                        ;
      MAIN  TOPMOST NOMAXIMIZE NOSIZE          ;
      BACKCOLOR { 93,114,148}                  ;
      ON INIT This.Topmost := .F.

      @ 5, 10 BUTTONEX BUTTON_Color WIDTH 150 HEIGHT 46                             ;
         CAPTION "Color" ICON "iColor32x1" FONTCOLOR BLACK                          ;
         SIZE 16 BOLD FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                           ;
         BACKCOLOR { { 0.5, CLR_GRAY, CLR_GREEN } , { 0.5, CLR_GREEN, CLR_GRAY } }  ;
         GRADIENTFILL ;
         { { 0.5, RGB(255,128,64), 16777215 }, { 0.5, 16777215, RGB(255,128,64) } } ; 
         ON MOUSEHOVER ( This.Backcolor := BLACK , This.Fontcolor := OLIVE , This.Icon := "iColor32x2" ) ; 
         ON MOUSELEAVE ( This.Backcolor := ORANGE, This.Fontcolor := BLACK , This.Icon := "iColor32x1" ) ; 
         ACTION TableColor(oBrw) 

      @ 5, 170 BUTTONEX BUTTON_Export WIDTH 150 HEIGHT 46                          ;
         CAPTION "Export" ICON "iXls32x1" FONTCOLOR BLACK                          ;
         SIZE 16 BOLD  FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                         ;
         BACKCOLOR { { 0.5, CLR_BLACK, CLR_GREEN } , { 0.5, CLR_GREEN, CLR_BLACK } } ;
         GRADIENTFILL ;
         { { 0.5, CLR_GREEN, 16777215 }, { 0.5, 16777215, CLR_GREEN } }            ; 
         ON MOUSEHOVER ( This.Backcolor := BLACK  , This.Fontcolor := OLIVE , This.Icon := "iXls32x2" ) ; 
         ON MOUSELEAVE ( This.Backcolor := LGREEN , This.Fontcolor := BLACK , This.Icon := "iXls32x1" ) ; 
         ACTION TableExport(oBrw)

      @ 5, 330 BUTTONEX BUTTON_Exit WIDTH 150 HEIGHT 46                          ;
         CAPTION "Exit" ICON "iExit32x1" FONTCOLOR BLACK                         ;
         SIZE 16 BOLD FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                        ;
         BACKCOLOR { { 0.5, 16761992, CLR_GREEN } , { 0.5, CLR_GREEN, 16761992 } } ;
         GRADIENTFILL ;   
         { { 0.5, CLR_HRED, 16777215 }, { 0.5, 16777215, CLR_HRED } }            ; 
         ON MOUSEHOVER ( This.Backcolor := BLACK  , This.Fontcolor := OLIVE, This.Icon := "iExit32x2" ) ; 
         ON MOUSELEAVE ( This.Backcolor := RED    , This.Fontcolor := BLACK , This.Icon := "iExit32x1" ) ; 
         ACTION ThisWindow.Release

      DEFINE TBROWSE oBrw AT 46+10, 0 ;
         WIDTH  ThisWindow.ClientWidth ;
         HEIGHT ThisWindow.ClientHeight - 46 -10 ;
         FONT  cFontName1  SIZE  nFontSize ;
         GRID

         // ������� ������� / �reate table
         TsbCreate(oBrw, aDatos, nHSpr, nHcell, nHhead, nHfoot)

      END TBROWSE

   END WINDOW

   CENTER   WINDOW test
   ACTIVATE WINDOW test
   
RETURN

* ======================================================================
STATIC FUNCTION TsbCreate( oBrw, aDatos, nHSpr, nHcell, nHhead, nHfoot )
   LOCAL aArray, aFontHF, aHead, aSize, aFoot, aPict, aAlign, aName
   LOCAL nI, nCol, oCol, nWwnd 

   aArray   := aDatos[ 1 ]        // ������ ��������
   aHead    := aDatos[ 2 ]        // ������ ����� �������
   aSize    := aDatos[ 3 ]        // ������ �������� ������� �������
   aFoot    := aDatos[ 4 ]        // ������ ������� �������
   aPict    := aDatos[ 5 ]        // ������ �������� ��� �������� �������
   aAlign   := aDatos[ 6 ]        // ������ ������������� ��������
   aName    := aDatos[ 7 ]        // ������ ���� ������� ��� ��������� ����� ���
   aFontHF  := aDatos[ 8 ]        // ������ ������ header, footer

   WITH OBJECT oBrw  // oBrw ������ ����������\���������������

      :Cargo := 5         // ����� ���� ����� �����/�������� �������

      // ������ ������� �� ��������
      :SetArrayTo(aArray, aFontHF, aHead, aSize, aFoot, aPict, aAlign, aName)

      // ������ ���������� � �������  
      If SUPERHEADER_ON

         nCol := :nColumn('Name_5')
         ADD SUPER HEADER TO oBrw FROM COLUMN    1     TO COLUMN nCol  ;
             COLOR CLR_WHITE, CLR_BLACK TITLE " SuperHider_1" + ;
             IIF(MULTILINE_TSB, CRLF + " line-2" , "") HORZ DT_LEFT  

         ADD SUPER HEADER TO oBrw FROM COLUMN nCol + 1 TO :nColCount()  ;
             COLOR CLR_WHITE, CLR_BLACK TITLE "SuperHider_2 " + ;
             IIF(MULTILINE_TSB, CRLF + "line-2 " , "") HORZ DT_RIGHT  

         :nHeightSuper := nHSpr  // ������ ��������� ( ���������� )

      EndIf

      :lNoHScroll   := .T.         // �� ���������� ������������� ���������
      :nWheelLines  := 1           // ��������� ������� ����
      :nClrLine     := COLOR_GRID  // ���� ����� ����� �������� �������
      :lNoChangeOrd := .T.         // ������ ���������� �� ���� � �������
      :nColOrder    := 0           // ������ ������ ���������� �� ����
      :lNoGrayBar   := .F.         // ���������� ���������� ������ � �������

      /*:nHeightSuper := nHSpr    // ������ ��������� ( ���������� ) */
      :nHeightCell  := nHcell   // ������ ������ � �������
      :nHeightHead  := nHhead   // ������ ����� ������� ��� ����� �������
      :nHeightFoot  := nHfoot   // ������ ������� ������� ��� ����� �������
      :lFooting     := .T.      // ������������ ������
      :lDrawFooters := .T.      // ��������  �������

      :nFreeze      := 1        // ���������� ������ �������
      :lLockFreeze  := .T.      // �������� ���������� ������� �� ������������ ��������

      :nLineStyle   := LINES_ALL   // LINES_NONE LINES_ALL LINES_VERT LINES_HORZ LINES_3D LINES_DOTTED
                                   // ����� ����� � �������

      For nI := 1 To :nColCount()
         oCol            := :aColumns[ nI ]
         // ��������� ������� �������
         oCol:nFAlign    := DT_CENTER
         If oCol:cName == 'Name_1'
            oCol:nAlign  := DT_CENTER  // ��������� ������� 'Name_1'
         EndIf
         // ����� ��� ����� �������
         oCol:hFont      := {|nr,nc,ob| TsbFont(nr, nc, ob)} 
      Next

      TsbColor( oBrw )  // ������� ������ �������

      // ��������� ������ ������� 
      nWwnd := :GetAllColsWidth() + GetBorderWidth()   // ������ ���� ������� �������

      If :nLen > :nRowCount()   //  ���-�� ����� ������� > ���-�� ����� ������� �� ������
         nWwnd += GetVScrollBarWidth()   // �������� � ������ ������� ���� ���� ������������ ��������
      EndIf

      ThisWindow.Width  := nWwnd             // ��������� ������� ������ ����
      This.oBrw.Width   := This.ClientWidth  // ��������� ������ ������� �� ���������� ������� ����

   END WITH  // oBrw ������ ����

   oBrw:SetNoHoles() // ������ ����� ����� ������� - � ������ ������ �� �����
   oBrw:GoPos( 5, oBrw:nFreeze + 2 ) // ���. ������ �� �� ������ � �� �������
   oBrw:SetFocus()

   RETURN Nil

* ======================================================================
STATIC FUNCTION TsbColor( oBrw, aHColor, aBColor, nHClr1, nHClr2 )
   DEFAULT aHColor := {255, 255, 255} , ;      // ���� ����� �������
           aBColor := {174, 174, 174} , ;      // ���� ����  �������
           nHClr1  := MyRGB( aHColor ), ;
           nHClr2  := MyRGB( { 51, 51, 51 } )

   WITH OBJECT oBrw  // oBrw ������ ����������\���������������
   
     :SetColor( { 1}, { { || CLR_BLACK                         } } ) // 1 , ������ � ������� �������                              
     :SetColor( { 2}, { { || MyRGB(aBColor)                    } } ) // 2 , ���� � ������� �������                                
     :Setcolor( { 3}, { CLR_BLACK                                } ) // 3 , ������ ����� ������� 
     :SetColor( { 4}, { { || { nHClr1, nHClr2                } } } ) // 4 , ���� ����� �������
     :SetColor( { 5}, { { ||   CLR_BLACK                       } } ) // 5 , ������ �������, ����� � ������� � �������             
     :SetColor( { 6}, { { || { 4915199,255}                    } } ) // 6 , ���� �������                                          
     :SetColor( { 7}, { { ||   CLR_RED                         } } ) // 7 , ������ �������������� ����                            
     :SetColor( { 8}, { { ||   CLR_YELLOW                      } } ) // 8 , ���� �������������� ����                              
     :SetColor( { 9}, { CLR_BLACK                                } ) // 9 , ������ ������� �������                                
     :SetColor( {10}, { { || { nHClr1, nHClr2                } } } ) // 10, ���� ������� �������                                  
     :SetColor( {11}, { { ||   CLR_GRAY                        } } ) // 11, ������ ����������� ������� (selected cell no focused)
     :SetColor( {12}, { { || { RGB(255,255,74), RGB(240,240,0)}} } ) // 12, ���� ����������� ������� (selected cell no focused)   
     :SetColor( {13}, { { ||   CLR_HRED                        } } ) // 13, ������ ����� ���������� �������
     :SetColor( {14}, { { || { nHClr1, nHClr2                } } } ) // 14, ���� ����� ���������� �������  
     :SetColor( {15}, { { ||   CLR_WHITE                       } } ) // 15, ����� ����� �������� ������� 
     :SetColor( {16}, { { || { CLR_BLACK, CLR_GRAY           } } } ) // 16, ���� ���������                                  
     :SetColor( {17}, { { || CLR_WHITE                         } } ) // 17, ������ ���������
     
     // ---- c����� ���� ���� �� ���� �������� ----( oCol:nClrBack = oBrw:SetColor( {2} ...) ----
     AEval(:aColumns, {|oCol| oCol:nClrBack := { |nr,nc,ob| TsbColorBack(nr,nc,ob) } } )
     AEval(:aColumns, {|oCol| oCol:nClrFore := { |nr,nc,ob| TsbColorFore(nr,nc,ob) } } )

   END WITH  // oBrw ������ ����

   RETURN Nil
   
* ======================================================================
FUNCTION TsbGet( oBrw, xCol )
RETURN Eval( oBrw:GetColumn(xCol):bData )
   
* ======================================================================
FUNCTION TsbPut( oBrw, xCol, xVal )
RETURN Eval( oBrw:GetColumn(xCol):bData, xVal )

* ======================================================================
STATIC FUNCTION TsbColorBack( nAt, nCol, oBrw )
   LOCAL nTsbColor := oBrw:Cargo  // current color from oBrw:Cargo
   // ������ ��� ��������� ������� �� ������� �����
   LOCAL nSumma := TsbGet(oBrw, 'Name_9' )
   LOCAL nClr3  := TsbGet(oBrw, 'Name_3' )
   LOCAL nColor

   // ��������� ��������� ��������
   IF VALTYPE(nSumma) != "N" 
      nColor := CLR_HRED  
      RETURN nColor
   ENDIF

   IF     nTsbColor == 1   // the default color of the table
         nColor := CLR_WHITE
   ELSEIF nTsbColor == 2   // color table gray
      nColor := CLR_HGRAY
   ELSEIF nTsbColor == 3   // color of the table "ruler"
      IF nAt % 2 == 0
         nColor := CLR_HGRAY
      ELSE
         nColor := CLR_WHITE
      ENDIF
   ELSEIF nTsbColor == 4    // the color of the table "columns"
      IF nCol % 2 == 0
         nColor := CLR_HGRAY
      ELSE
         nColor := CLR_WHITE
      ENDIF
   ELSEIF nTsbColor == 5    // the color of the table "chess"
      IF nAt % 2 == 0
         If nCol % 2 == 0; nColor := CLR_HGRAY
         Else            ; nColor := CLR_WHITE
         EndIf
      ELSE
         If nCol % 2 == 0; nColor := CLR_WHITE
         Else            ; nColor := CLR_HGRAY
         EndIf
      ENDIF
   ELSEIF nTsbColor == 6    // the color of the table "multicolor"
      IF     nClr3 == 1
         nColor := RGB(159,191,236)  // Office_2003 Blue
      ELSEIF nClr3 == 2
         nColor := RGB(234,240,207)  // Office_2003 GREEN 
      ELSEIF nClr3 == 3
         nColor := RGB(225,226,236)  // Office_2003 SILVER 
      ELSEIF nClr3 == 4
         nColor := RGB(251,230,148)  // Office_2003 ORANGE 
      ELSEIF nClr3 == 5
         nColor := RGB(255,153,255)  // Office_2003 PURPLE
      ELSEIF nClr3 == 6
         nColor := RGB(118,170,235)  // TWITER
      ELSEIF nClr3 == 7
         nColor := RGB(225,237,204)  // 
      ELSEIF nClr3 == 8
         nColor := RGB(229,220,229)  //  
      ELSEIF nClr3 == 9
         nColor := RGB(51,255,255)   //  
      ELSE
         nColor := CLR_WHITE
      ENDIF
   ENDIF
   // ���� �� ������� �����
   IF nSumma == 1500
      nColor := RGB(255,128,64) // ORANGE
   ENDIF

   RETURN nColor

* ======================================================================
STATIC FUNCTION TsbColorFore( nAt, nCol, oBrw )
   LOCAL nColor, nTsbColor := TsbGet(oBrw, 'Name_9')
   Default nAt := 0 , nCol := 0

   // ��������� ��������� ��������
   IF VALTYPE(nTsbColor) != "N" 
      nColor := CLR_HGRAY  
      RETURN nColor
   ENDIF

   IF nTsbColor <= -100    
      nColor := CLR_HRED
   ELSEIF nTsbColor < 0         
      nColor := CLR_RED
   ELSE 
      nColor := CLR_BLACK
   ENDIF

   RETURN nColor

* ======================================================================
STATIC FUNCTION MyRGB( aDim )
   RETURN RGB( aDim[1], aDim[2], aDim[3] )

* ======================================================================
STATIC FUNCTION TsbFont( nAt, nCol, oBrw )
   LOCAL hFont
   STATIC a_Font
   Default nAt := 0

   If a_Font == Nil .or. pCount() == 0
      a_Font := {}

      AAdd( a_Font, GetFontHandle( "Font_1" ) )
      AAdd( a_Font, GetFontHandle( "Font_2" ) )
      AAdd( a_Font, GetFontHandle( "Font_3" ) )
      AAdd( a_Font, GetFontHandle( "Font_4" ) )
      AAdd( a_Font, GetFontHandle( "Font_5" ) )
      AAdd( a_Font, GetFontHandle( "Font_6" ) )
      AAdd( a_Font, GetFontHandle( "Font_7" ) )

      RETURN a_Font
   EndIf

   If     nCol == 1             // ���� ������� 1 
       hFont := a_Font[7]
   ElseIf TsbGet(oBrw, 2)       // oBrw:aArray[ nAt ][2] // �������� ���� ������ ����� ������� 
       hFont := a_Font[1]       // �� ������� ��� ������� 2
   Else                        
       hFont := a_Font[6]
   EndIf
       
RETURN hFont

* ======================================================================
FUNCTION TableColor(oBrw)   
   LOCAL Font1, Font3, Font7, nY, nX
   LOCAL nTsbColor := oBrw:Cargo  // ������� ���� �� oBrw:Cargo
   LOCAL cForm   := oBrw:cParentWnd

   nY := GetProperty(ThisWindow.Name,This.Name,"Row") + GetProperty(ThisWindow.Name,This.Name,"Height")
   nX := GetProperty(ThisWindow.Name,This.Name,"Col")
   nY += GetProperty(cForm, "Row") + GetTitleHeight() + 2
   nX += GetProperty(cForm, "Col") + GetBorderWidth() - 4         
   
   Font1 := GetFontHandle( "Font_1" )
   Font3 := GetFontHandle( "Font_3" )                                     
   Font7 := GetFontHandle( "Font_7" )

   SET MENUSTYLE EXTENDED     // switch the menu style to advanced
   SetMenuBitmapHeight( 18 )  // set icon size 18x18

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  'color table white         '       ACTION nTsbColor := 1 FONT Font1
       MENUITEM  'color table gray          '       ACTION nTsbColor := 2 FONT Font1
       MENUITEM  'color of the table "ruler"'       ACTION nTsbColor := 3 FONT Font1
       MENUITEM  'color of the table "columns"'     ACTION nTsbColor := 4 FONT Font1
       MENUITEM  'color of the table "chess"'       ACTION nTsbColor := 5 FONT Font1
       MENUITEM  'color of the table "multicolor"'  ACTION nTsbColor := 6 FONT Font1
       SEPARATOR                             
       MENUITEM  "Export Color to file"          ACTION ToColorFile(oBrw) FONT Font3 
       SEPARATOR                             
       MENUITEM  "Exit"                          ACTION Nil               FONT Font7 
   END MENU

   _ShowContextMenu(cForm, nY, nX) // displaying the menu
   InkeyGui(10)

   DEFINE CONTEXT MENU OF &cForm  // deleting menu after exiting 
   END MENU

   SET MENUSTYLE STANDARD  // MANDATORY! Return to the standard menu style!

   IF nTsbColor # oBrw:Cargo          // ������� �� ���� � ���� 
      oBrw:Cargo := nTsbColor         // ��������� ����� ��������� ����� 
      oBrw:Display() 
      oBrw:Refresh(.T.)               // ������������ ������ � ������� 
   ENDIF 
 
   oBrw:SetFocus()
   DO EVENTS

   RETURN NIL

* ======================================================================
FUNCTION TableExport(oBrw)   
   LOCAL Font3, Font7, nY, nX
   LOCAL cForm := oBrw:cParentWnd

   nY := GetProperty(ThisWindow.Name,This.Name,"Row") + GetProperty(ThisWindow.Name,This.Name,"Height")
   nX := GetProperty(ThisWindow.Name,This.Name,"Col")
   nY += GetProperty(cForm, "Row") + GetTitleHeight() + 2
   nX += GetProperty(cForm, "Col") + GetBorderWidth() - 4         
   
   Font3 := GetFontHandle( "Font_3" )
   Font7 := GetFontHandle( "Font_7" )

   SET MENUSTYLE EXTENDED     // switch the menu style to advanced
   SetMenuBitmapHeight( 18 )  // set icon size 18x18

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  "Export to Excel (xls-files)"     ACTION ToExcel1(oBrw)  FONT Font3 
       SEPARATOR                             
       MENUITEM  "Export to Ole-Excel (xls-files)" ACTION ToExcel2(oBrw)  FONT Font3 
       SEPARATOR                             
       MENUITEM  "Export to Excel (xml-files)"     ACTION ToExcel3(oBrw)  FONT Font3 
       SEPARATOR                             
       MENUITEM  "Exit"                            ACTION Nil             FONT Font7 
   END MENU

   _ShowContextMenu(cForm, nY, nX, .F. ) // displaying the menu
   InkeyGui(10)

   DEFINE CONTEXT MENU OF &cForm  // deleting menu after exiting 
   END MENU

   SET MENUSTYLE STANDARD  // MANDATORY! Return to the standard menu style!

   oBrw:SetFocus()
   DO EVENTS

   RETURN NIL

* ======================================================================
FUNCTION _ShowContextMenu(ParentFormName, nRow, nCol, lCentered)
   LOCAL xContextMenuParentHandle
   LOCAL aRow := GetCursorPos()
   DEFAULT lCentered := nRow == NIL .and. nCol == NIL
   DEFAULT nRow := 0, nCol := 0, ParentFormName := ""

   If .Not. _IsWindowDefined (ParentFormName)
      xContextMenuParentHandle := _HMG_xContextMenuParentHandle
   else
      xContextMenuParentHandle := GetFormHandle ( ParentFormName )
   Endif
   if xContextMenuParentHandle == 0
      MsgMiniGuiError("Context Menu is not defined. Program terminated")
   endif
   IF lCentered
   ELSEIF nRow == 0 .and. nCol == 0
      nCol := aRow[2]
      nRow := aRow[1]
   ENDIF

   TrackPopupMenu ( _HMG_xContextMenuHandle , nCol , nRow , xContextMenuParentHandle )

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToExcel1(oBrw)  
   LOCAL hFont, aFont, cFontName, cTitle, aTitle, nCol
   LOCAL aOld1 := array(oBrw:nColCount()) 
   LOCAL aOld2 := array(oBrw:nColCount()) 
   LOCAL aOld3 := array(oBrw:nColCount()) 
   LOCAL nFSize

   // �������� ! ��������� ������ 65533 ����� � Excel ������ ! ����������� Excel.
   // Attention ! Upload more than 65533 rows in Excel is NOT possible ! Excel Restriction.

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // ������� ��� � ������� ������� �������
   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.  // ����������� ������� ������� (������ �� ������������)

   //hFont := oBrw:aColumns[ 1 ]:hFont        // ����� ���� ������� �����
   hFont := GetFontHandle( "Font_6" )         // ������� ���� ����
   aFont := GetFontParam( hFont )
   nFSize := 12                               // ������� ���� ������ ����� ��� Excel  
   cFontName := "Font_" + hb_ntos( _GetId() )  
   // ��������� ���� ��� �������� � Excel
   _DefineFont( cFontName, aFont[1], nFSize, aFont[3], aFont[4] )  
  
   FOR nCol := 1 TO LEN( oBrw:aColumns )
      // ��������� ���� ��� ��������������
      aOld1[ nCol ] := oBrw:aColumns[ nCol ]:hFont      
      aOld2[ nCol ] := oBrw:aColumns[ nCol ]:hFontHead 
      aOld3[ nCol ] := oBrw:aColumns[ nCol ]:hFontFoot
      // ���������� ����� ����
      oBrw:aColumns[ nCol ]:hFont     := GetFontHandle( cFontName )  
      oBrw:aColumns[ nCol ]:hFontHead := GetFontHandle( cFontName )
      oBrw:aColumns[ nCol ]:hFontFoot := GetFontHandle( cFontName )
   NEXT

   // --------------------- ����������� -----------------------------
   //oBrw:aColumns[ 6 ]:cDataType := 'N' // �� ������������ ������ ��� �������� �����,
   //oBrw:aColumns[ 6 ]:cPicture  := ''  // �.�. ��� �������� � Excel ���� ����� ������ !!!       

   cTitle := "_" + Space(50) + "Example of exporting a table (TITLE OF THE TABLE)"
   aTitle := { cTitle, hFont }  // ����� �� ����� ������
   oBrw:Excel2(nil, nil, nil, aTitle)

   _ReleaseFont( cFontName )  // ������� �������������� ����
  
   AEval(oBrw:aColumns, {|oc,nn| oc:hFont     := aOld1[ nn ] }) // ������������ ���� 
   AEval(oBrw:aColumns, {|oc,nn| oc:hFontHead := aOld2[ nn ] }) // ������������ ���� 
   AEval(oBrw:aColumns, {|oc,nn| oc:hFontFoot := aOld3[ nn ] }) // ������������ ���� 

   oBrw:lEnabled := .T.    // �������������� ������� ������� (������ ������������)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()            // close the wait window
   EndIf

   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToExcel2(oBrw)  
   LOCAL hFont, aFont, cFontName, cTitle, nCol
   LOCAL aOld1 := array(oBrw:nColCount()) 
   LOCAL aOld2 := array(oBrw:nColCount()) 
   LOCAL aOld3 := array(oBrw:nColCount()) 
   LOCAL nFSize, cXlsFile, lActivate, hProgress, lSave 
   LOCAL bExtern, aColSel, bPrintRow  

   // �������� ! ��������� ������ 65533 ����� � Excel ������ ! ����������� Excel.
   // Attention ! Upload more than 65533 rows in Excel is NOT possible ! Excel Restriction.

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // ������� ��� � ������� ������� �������
   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.  // ����������� ������� ������� (������ �� ������������)

   //hFont := oBrw:aColumns[ 1 ]:hFont        // ����� ���� ������� �����
   hFont := GetFontHandle( "Font_6" )         // ������� ���� ����
   aFont := GetFontParam( hFont )
   nFSize := 12                               // ������� ���� ������ ����� ��� Excel  
   cFontName := "Font_" + hb_ntos( _GetId() )  
   // ��������� ���� ��� �������� � Excel
   _DefineFont( cFontName, aFont[1], nFSize, aFont[3], aFont[4] )  
  
   FOR nCol := 1 TO LEN( oBrw:aColumns )
      // ��������� ���� ��� ��������������
      aOld1[ nCol ] := oBrw:aColumns[ nCol ]:hFont      
      aOld2[ nCol ] := oBrw:aColumns[ nCol ]:hFontHead 
      aOld3[ nCol ] := oBrw:aColumns[ nCol ]:hFontFoot
      // ���������� ����� ����
      oBrw:aColumns[ nCol ]:hFont     := GetFontHandle( cFontName )  
      oBrw:aColumns[ nCol ]:hFontHead := GetFontHandle( cFontName )
      oBrw:aColumns[ nCol ]:hFontFoot := GetFontHandle( cFontName )
   NEXT 

   cTitle := "_" + Space(20) + "Example of exporting a table (TITLE OF THE TABLE)"
   cXlsFile := "TestOle.xls"
   lActivate := .T.
   hProgress := nil 
   lSave := .F.
   bExtern := nil
   aColSel := nil
   bPrintRow  := nil

   oBrw:ExcelOle( cXlsFile, lActivate, hProgress, cTitle, hFont, lSave, bExtern, aColSel, bPrintRow )

   _ReleaseFont( cFontName )  // ������� �������������� ����
  
   AEval(oBrw:aColumns, {|oc,nn| oc:hFont     := aOld1[ nn ] }) // ������������ ���� 
   AEval(oBrw:aColumns, {|oc,nn| oc:hFontHead := aOld2[ nn ] }) // ������������ ���� 
   AEval(oBrw:aColumns, {|oc,nn| oc:hFontFoot := aOld3[ nn ] }) // ������������ ���� 

   oBrw:lEnabled := .T.    // �������������� ������� ������� (������ ������������)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()           // close the wait window
   EndIf

   oBrw:Display() 
   oBrw:Refresh(.T.)         // ������������ ������ � ������� 
   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToExcel3(oBrw)  
   LOCAL hFont, cTitle, aTitle

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // ������� ��� � ������� ������� �������
   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.  // ����������� ������� ������� (������ �� ������������)

   hFont := GetFontHandle( "Font_7" )         // ������� ���� ����
   cTitle := "_" + Space(50) + "Example of exporting a table (TITLE OF THE TABLE)"
   aTitle := { cTitle, hFont }  // ����� �� ����� ������

   XmlSetDefault( oBrw )                      // ��������� xml --> Tsb2xml.prg
   // ����� ������ ���� ������ - �������� �� ��������� ��������������
   oBrw:aColumns[6]:XML_Format := "00\:00\:00" 
   oBrw:aColumns[9]:XML_Format := "0.00_ ;[Red]\-0.00\ "   

   Brw2Xml(oBrw, "TEST.XML", .T.,, aTitle)    // Export to xml --> Tsb2xml.prg
   XmlReSetDefault( oBrw )                    // ������������ ���������  xml --> Tsb2xml.prg

   oBrw:lEnabled := .T.    // �������������� ������� ������� (������ ������������)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()            // close the wait window
   EndIf

   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
FUNCTION ToColorFile(oBrw)   
   LOCAL nLine, nCol, nBackColor, aBackCell, aClr
   LOCAL cFile := hb_defaultValue( _SetGetLogFile(), GetStartUpFolder() + "\_MsgLog.txt" )

   DELETEFILE(cFile)

   // ������ ������ ����� ���� ����� ��� ���� ������� � ���� �������
   aBackCell := {}

   ? "Cell background color for all columns and the entire table"
   For nLine := 1 TO oBrw:nLen
       aClr := {}
       ? "nLine=", nLine, "{"
       For nCol := 1 TO Len( oBrw:aColumns )
           nBackColor := oBrw:aColumns[ nCol ]:nClrBack  
           If Valtype( nBackColor ) == "B" 
              nBackColor := Eval( nBackColor, oBrw:nAt, nCol, oBrw ) 
           EndIf  
           ?? nBackColor
           AADD( aClr, nBackColor ) 
       Next
       AADD( aBackCell, aClr ) 
      ?? "}"
      oBrw:Skip(1)
   Next
   DO EVENTS

   ShellExecute( 0, "Open", cFile,,, 3 )

   oBrw:GoTop() 
   oBrw:Reset() 
   DO EVENTS 
   oBrw:Display()  
   oBrw:Refresh(.T.)               // ������������ ������ � �������  
   oBrw:SetFocus() 
   DO EVENTS 

   RETURN NIL

* ======================================================================
STATIC FUNCTION CreateDatos( nLine )
   LOCAL i, k := 100, aDatos, aHead, aSize := NIL, aFoot, aPict := NIL, aAlign := NIL, aName
   LOCAL hFont, n7Pict := 0, n7Len := 0, c7Str, nI := 1

   If HB_ISNUMERIC(nLine)
      k := nLine
   EndIf

   If k > SHOW_WAIT_WINDOW_LINE
      SET WINDOW MAIN OFF
      WaitWindow( 'Create an array for work ...', .T. )   // open the wait window
   EndIf

   aDatos := Array( k )
   FOR i := 1 TO k
      aDatos[ i ] := { ;
         hb_ntos(i)+'.', ;                            // 1
         i % 2 == 0, ;                                // 2 
         i, ;                                         // 3
         "Str"+ntoc( i ) + "_123", ;                  // 4
         Date() + i, ;                                // 5
         TIME(), ;                                    // 6
         PadR( "Test line - " + ntoc( i ), 20 ), ;    // 7
         Round( ( 10000 -i ) * i / 3, 2 ), ;          // 8
         100.00 * i }                                 // 9

      IF i % 10 == 0
         aDatos[i,9] :=  -1.00
      ELSEIF i % 11 == 0
         aDatos[i,9] :=  -100.00
      ELSEIF i % 15 == 0
         aDatos[i,9] :=  1500.00
      ENDIF

      aDatos[i,3] := nI
      IF i % 3 == 0
         nI++
         IF nI > 10
            nI := 1
         ENDIF
      ENDIF

      IF MULTILINE_TSB 
         aDatos[i,7] := aDatos[i,7] + CRLF + SPACE(5) + "string test - 2;0123456789" + CRLF + SPACE(5) + "string test - 3;0123456789"
      ENDIF
   NEXT
   // ������� ��� 7-�� �������
   IF MULTILINE_TSB 
      n7Len  := LEN( CRLF + SPACE(5) + "string test - 2;0123456789" )
      n7Pict := REPL("x",n7Len * 3 )
   ENDIF

   aHead  := AClone( aDatos[ 1 ] )
   AEval( aHead, {| x, n| x:=nil, aHead[ n ] := "Head_" + hb_ntos( n ) + IIF(MULTILINE_TSB, CRLF + "line-2" , "") } ) 
   aFoot  := Array( Len( aDatos[ 1 ] ) )
   AEval( aFoot, {| x, n| x:=nil, aFoot[ n ] := "Foot_" + hb_ntos( n ) + IIF(MULTILINE_TSB, CRLF + "line-2" , "") } )
   aName     := Array( Len( aDatos[ 1 ] ) )
   AEval( aName, {| x, n| x:=nil, aName[ n ] := "Name_" + hb_ntos( n ) } )

   // ������ ������ ��� 6 �������
   aPict := Array( Len( aDatos[ 1 ] ) )
   aPict[ 6 ] := "@R 99:99:99" 

   aSize := Array( Len( aDatos[ 1 ] ) )
   aFill( aSize,  NIL )
   // ������ ������ ��� 6 �������
   hFont := GetFontHandle( "Font_1" )
   aSize[ 6 ] := GetTextWidth(0, "99099099", hFont)

   IF MULTILINE_TSB 
      hFont := GetFontHandle( "Font_2" )
      // ������ ������ ��� 7 �������
      aPict[ 7 ] := n7Pict 
      // ������ ������ ��� 7 �������
      c7Str := REPL("a", n7Len)
      aSize[ 7 ] := GetTextWidth(0, c7Str, hFont)
   ENDIF

   If k > SHOW_WAIT_WINDOW_LINE
      WaitWindow()            // close the wait window
      SET WINDOW MAIN ON
   EndIf

RETURN { aDatos, aHead, aSize, aFoot, aPict, aAlign, aName }
