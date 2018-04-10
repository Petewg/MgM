/*                                                         
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * ������� � ������� �� ������� / ������� ������� / ����� ������� / ������� ������� � Excel
 * A table in a MiniGui from an array / table dimensions / table colors / export table to Excel
*/

ANNOUNCE RDDSYS

#define _HMG_OUTLOG

#include "hmg.ch"
#include "TSBrowse.ch"

#define  SHOW_WAIT_WINDOW_LINE    1000
#define  SUPERHEADER_ON           .T.

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
   LOCAL nWwnd, nLine, nHcell, nHrow, nHSpr, nHhead, nHfoot, nHwnd

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
   
   nLine  := iif( empty(nLine), 15, nLine )  // ���-�� �����  � �������
   nHcell := nFont + 6                       // ������ ������ � �������
   nHhead := nHfoot := nHSpr := nHcell       // ������ �����, ������� � ����������� ������� ��� ����� ������� 
                                             // ����� ������ ������ ������ � �������, ���� ��� �������, �� * 2
   nHrow  := nLine * nHcell + 1              // ������ ���� ����� � ������� 
                                             // + 1 ����������� ������ �� XX ������ 
   IF ! SUPERHEADER_ON                       // ��� SuperHeader
      nHSpr := 1
   ENDIF

   nHwnd  := nHhead + nHrow + nHfoot + nHSpr // �������� ������ �������
   nWwnd  := 300 // ������ ���� ����� ����������� � �������� � ������ ������� 

   DEFINE WINDOW test ;
      CLIENTAREA nWwnd, nHwnd ;
      TITLE "SetArray Demo - height and width of the table + menu + color !" + ;
            "  Click Left\Right mouse, press F2,F3,F4,F5,Enter." ;
      MAIN  TOPMOST NOMAXIMIZE NOSIZE   ;
      ON INIT This.Topmost := .F.

      DEFINE TBROWSE oBrw AT 0, 0 ;
         WIDTH  ThisWindow.ClientWidth ;
         HEIGHT ThisWindow.ClientHeight ;
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
             COLOR CLR_WHITE, CLR_BLACK TITLE "  SuperHider_1 - select menu" HORZ DT_LEFT  

         ADD SUPER HEADER TO oBrw FROM COLUMN nCol + 1 TO :nColCount()  ;
             COLOR CLR_WHITE, CLR_BLACK TITLE "SuperHider_2 - select menu  " HORZ DT_RIGHT  

         :nHeightSuper := nHSpr    // ������ ��������� ( ���������� )

      EndIf

      :lNoHScroll   := .T.         // �� ���������� ������������� ���������
      :nWheelLines  := 1           // ��������� ������� ����
      :nClrLine     := COLOR_GRID  // ���� ����� ����� �������� �������
      :lNoChangeOrd := .T.         // ������ ���������� �� ���� � �������
      :nColOrder    := 0           // ������ ������ ���������� �� ����
      :lNoGrayBar   := .F.         // ���������� ���������� ������ � �������

      :nHeightCell  := nHcell   // ������ ������ � �������
      :nHeightHead  := nHhead   // ������ ����� ������� ��� ����� �������
      :nHeightFoot  := nHfoot   // ������ ������� ������� ��� ����� �������
      :lFooting     := .T.      // ������������ ������
      :lDrawFooters := .T.      // ��������  �������

      :nFreeze      := 1        // ���������� ������ �������
      :lLockFreeze  := .T.      // �������� ���������� ������� �� ������������ ��������
      
      // ---------- ��������� �� ����� � ������ ��������� ������� ----------------
      For nI := 1 To :nColCount()
         // ����� � ������ ������ ����� ��� �����, ������� � ������� �������
         oCol            := :aColumns[ nI ]
         oCol:bHLClicked := {|nrp,ncp,nat,obr| HeadClick(1,obr,nrp,ncp,nat) }
         oCol:bHRClicked := {|nrp,ncp,nat,obr| HeadClick(2,obr,nrp,ncp,nat) }
         oCol:bFLClicked := {|nrp,ncp,nat,obr| FootClick(1,obr,nrp,ncp,nat) }
         oCol:bFRClicked := {|nrp,ncp,nat,obr| FootClick(2,obr,nrp,ncp,nat) }
         oCol:bLClicked  := {|nrp,ncp,nat,obr| CellClick(1,obr,nrp,ncp,nat) }
         oCol:bRClicked  := {|nrp,ncp,nat,obr| CellClick(2,obr,nrp,ncp,nat) }
         // ��������� ������� �������
         oCol:nFAlign    := DT_CENTER
         If oCol:cName == 'Name_1'
            oCol:nAlign  := DT_CENTER  // ��������� ������� 'Name_1'
         EndIf

         // ����� ��� ����� �������
         oCol:hFont      := {|nr,nc,ob| TsbFont(nr, nc, ob)} 

         // edit ������� Name_2,Name_3,Name_5,Name_7
         If ( oCol:lEdit := oCol:cName $ 'Name_2,Name_3,Name_5,Name_7' )
              oCol:lOnGotFocusSelect := .T.
         EndIf
      Next

      :nLineStyle   := LINES_ALL   // LINES_NONE LINES_ALL LINES_VERT LINES_HORZ LINES_3D LINES_DOTTED
                                   // ����� ����� � �������
      // --------- ���� ���� ��� ������� ESC � TSB  ------------------
      :bOnEscape := {|obr| _ReleaseWindow(obr:cParentWnd) }
//      :bOnEscape := {|obr| DoMethod(obr:cParentWnd, "Release") }  // ��� ����� ���

      :nFireKey  := VK_F4        // KeyDown default Edit 

      :UserKeys(VK_F2    , {|obr,nky,cky| MsgBox(obr:cParentWnd+'.'+obr:cControlName+ ;
                             '.'+hb_ntos(nky)+'.'+cky, 'VK_F2') })
      :UserKeys(VK_F3    , {|obr,nky,cky| MsgBox(obr:cParentWnd+'.'+obr:cControlName+ ;
                             '.'+hb_ntos(nky)+'.'+cky, 'VK_F3') })
      :UserKeys(VK_F5    , {|obr,nky,cky| MsgBox(obr:cParentWnd+'.'+obr:cControlName+ ;
                             '.'+hb_ntos(nky)+'.'+cky, 'VK_F5') })
      :UserKeys(VK_RETURN, {|obr,nky,cky| MsgBox(obr:cParentWnd+'.'+obr:cControlName+ ;
                             '.'+hb_ntos(nky)+'.'+cky, 'VK_RETURN'), .F. })
      // ������� .F. - �������� ��������� ����� ����������, � tsb �� ����������, � 
      // ������� .T. ��� Nil ���������� ��������� KeyDown � tsb

      TsbColor( oBrw )  // ������� ������ �������

      // ��������� ������ ������� 
      nWwnd := :GetAllColsWidth() + GetBorderWidth()   // ������ ���� ������� �������

      If :nLen > :nRowCount()   //  ���-�� ����� ������� > ���-�� ����� ������� �� ������
         nWwnd += GetVScrollBarWidth()   // �������� � ������ ������� ���� ���� ������������ ��������
      EndIf

      ThisWindow.Width := nWwnd             // ��������� ������� ������ ����
      This.oBrw.Width  := This.ClientWidth  // ��������� ������ ������� �� ���������� ������� ����

   END WITH

// oBrw:SetNoHoles() // ������ ����� ����� ������� - � ������ ������ �� �����
   oBrw:GoPos( 5, oBrw:nFreeze + 2 ) // ���. ������ �� �� ������ � �� �������
   oBrw:SetFocus()

   RETURN Nil

* ======================================================================
STATIC FUNCTION TsbColor( oBrw, aHColor, aBColor, nHClr1, nHClr2 )
   DEFAULT aHColor := {255, 255, 255} , ;      // ���� ����� �������
           aBColor := {174, 174, 174} , ;      // ���� ����  �������
           nHClr1  := MyRGB( aHColor ), ;
           nHClr2  := MyRGB( { 51, 51, 51 } )

   WITH OBJECT oBrw

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

   END WITH

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
   LOCAL nSumma := TsbGet(oBrw, 'Name_8')
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
   ENDIF
   // ���� �� ������� �����
   IF nSumma == 1500
      nColor := CLR_YELLOW
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
STATIC FUNCTION FootClick( nClick, oBrw, nRowPix, nColPix, nAt )  
   LOCAL nRow  := oBrw:GetTxtRow(nRowPix)       // ����� ������ ������� � �������
   LOCAL nCol  := Max(oBrw:nAtCol(nColPix), 1)  // ����� ������� ������� � ������� 
   LOCAL nCell := oBrw:nCell                     // ����� ������ � ������� 
   LOCAL cNam  := {'Left mouse', 'Right mouse'}[ nClick ]
   LOCAL cObj  := "Foot_" + HB_NtoS(nCol), cMs, cRW, cCV, xVal

   cMs := "Mouse y:x " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix) 

   cRW  := "Cell position row/column: " + hb_ntos(nAt) + '/' + hb_ntos(nCell) 
   xVal := oBrw:aArray[ nAt ][ nCell ]
   cCV  := "Get cell value: [" + cValToChar(xVal) + "]" 

   MyShowUsrMenu( oBrw, nClick, 0, {nRowPix,nColPix}, {nRow,nCol}, {cNam,cObj,cMs,cRW,cCV} )

   RETURN Nil

* ======================================================================
STATIC FUNCTION HeadClick( nClick, oBrw, nRowPix, nColPix, nAt )  
   LOCAL nRow := oBrw:GetTxtRow(nRowPix)        // ����� ������ ������� � ������� 
   LOCAL nCol := Max(oBrw:nAtCol(nColPix), 1)   // ����� ������� ������� � �������
   LOCAL nCell:= oBrw:nCell                     // ����� ������ � ������� 
   LOCAL cNam := {'Left mouse', 'Right mouse'}[ nClick ]
   LOCAL nIsHS := iif(nRowPix > oBrw:nHeightSuper, 1, 2)
   LOCAL cObj, nSH, cMs, cRW, cCV, xVal

   cObj := iif(nIsHS == 1, 'Header', 'SuperHider')
   IF nIsHS == 1  // 'Header'
      cObj += "_" + HB_NtoS(nCol)
   ELSE
      If nCol <= oBrw:nColumn('Name_5')
         cObj := "SuperHider_1"
         nSH  := 1
      ElseIf nCol > oBrw:nColumn('Name_5')
         cObj := "SuperHider_2"
         nSH  := 2
      EndIf 
   ENDIF

   cMs  := "Mouse y:x " + hb_ntos(nRowPix) + ":" + hb_ntos(nColPix) 

   cRW  := "Cell position row/column: " + hb_ntos(nAt) + '/' + hb_ntos(nCell) 
   xVal := oBrw:aArray[ nAt ][ nCell ]
   cCV  := "Get cell value: [" + cValToChar(xVal) + "]" 

   MyShowUsrMenu( oBrw, nClick, nSH, {nRowPix,nColPix}, {nRow,nCol}, {cNam,cObj,cMs,cRW,cCV} )

   RETURN Nil

* ======================================================================
STATIC FUNCTION CellClick( nClick, oBrw, nRowPix, nColPix )  
   LOCAL nRow := oBrw:GetTxtRow(nRowPix)        // ����� ������ ������� � ������� 
   LOCAL nCol := Max(oBrw:nAtCol(nColPix), 1)   // ����� ������� ������� � �������
   LOCAL nRow2 := oBrw:nAt                      // ����� ������ � ������� 
   LOCAL cNam := {'Left mouse', 'Right mouse'}[ nClick ]
   LOCAL cCel, cMs, cAdd, cType, xVal

   cMs := "Mouse y/x: " + hb_ntos(nRowPix) + "/" + hb_ntos(nColPix) 

   xVal  := oBrw:aArray[ nRow2 ][nCol]
   cType :=  ValType(Eval(oBrw:aColumns[ nCol ]:bData)) 
   cCel  := "Cell position row/column: " + hb_ntos(nRow2) + '/' + hb_ntos(nCol) + CRLF 
   cCel  += "Type Cell: " + cType + CRLF 
   cCel  += "Get Cell value: [" + cValToChar(xVal) + "]" + CRLF 
   IF cType == "N"  
      oBrw:aArray[ nRow ][nCol] := xVal + 1
      cCel += "Write Cell value: [" + cValToChar(xVal) + "] + 1" + CRLF
   ENDIF 

   // edit ������� Name_2,Name_3,Name_5,Name_7
   cAdd := "Only for column: Head_2, Head_3, Head_5, Head_7" + CRLF  
   cAdd += "F4 - edit column" + CRLF + CRLF  
   cAdd += "F2 - test" + CRLF  
   cAdd += "F3 - test" + CRLF  
   cAdd += "F5 - test" + CRLF  

   MsgBox( cNam + CRLF + cMs + CRLF + CRLF + ;
                     cCel + CRLF + cAdd + CRLF, ProcName())
   RETURN Nil

* ======================================================================
FUNCTION MyShowUsrMenu(oBrw, nClick, nSupHid, aMouse, aRowCol, aInfo)   
   LOCAL Font1, Font2, Font3, Font7, nLineStyle := -1, lRefresh := .F. 
   LOCAL cForm := oBrw:cParentWnd
   LOCAL nTsbColor := oBrw:Cargo  // ������� ���� �� oBrw:Cargo
   LOCAL nI, cMenu, cName, bAction, cImg, lChk, lDis, nY, nX

   If nClick == 1   // ���� ���������
   Endif
   If nSupHid == 1  // ���� ���������
   Endif
   
   nY := aMouse[1]
   nX := aMouse[2]
   nY += GetProperty(cForm, "Row") + GetTitleHeight() 
   nX += GetProperty(cForm, "Col") + GetBorderWidth()          
   
   Font1 := GetFontHandle( "Font_1" )
   Font2 := GetFontHandle( "Font_6" )
   Font3 := GetFontHandle( "Font_3" )
   Font7 := GetFontHandle( "Font_7" )

   SET MENUSTYLE EXTENDED     // switch the menu style to advanced
   SetMenuBitmapHeight( 18 )  // set icon size 18x18

   DEFINE CONTEXT MENU OF &cForm
       FOR nI := 1 TO LEN(aInfo)
          IF nI == 4
             SEPARATOR                             
          ENDIF
          cMenu   := aInfo[nI]
          cName   := StrZero(nI, 3) 
          bAction := hb_macroBlock( 'MsgBox(' + cMenu + HB_ValToExp(aRowCol) + ')' )
          cImg    := '' 
          lChk    := .F.                                
          lDis    := .T.   // ��������� DISABLED
          _DefineMenuItem( cMenu, bAction, cName, cImg, lChk, lDis, , Font2 , , .F., .F. )
       NEXT
       SEPARATOR                             
       MENUITEM  'color table white         '    ACTION nTsbColor := 1 FONT Font1
       MENUITEM  'color table gray          '    ACTION nTsbColor := 2 FONT Font1
       MENUITEM  'color of the table "ruler"'    ACTION nTsbColor := 3 FONT Font1
       MENUITEM  'color of the table "columns"'  ACTION nTsbColor := 4 FONT Font1
       MENUITEM  'color of the table "chess"'    ACTION nTsbColor := 5 FONT Font1
       SEPARATOR                             
       MENUITEM  'nLineStyle := LINES_ALL'       ACTION nLineStyle := LINES_ALL    FONT Font2
       MENUITEM  'nLineStyle := LINES_NONE'      ACTION nLineStyle := LINES_NONE   FONT Font2
       MENUITEM  'nLineStyle := LINES_VERT'      ACTION nLineStyle := LINES_VERT   FONT Font2
       MENUITEM  'nLineStyle := LINES_HORZ'      ACTION nLineStyle := LINES_HORZ   FONT Font2
       MENUITEM  'nLineStyle := LINES_3D'        ACTION nLineStyle := LINES_3D     FONT Font2
       MENUITEM  'nLineStyle := LINES_DOTTED'    ACTION nLineStyle := LINES_DOTTED FONT Font2
       SEPARATOR                             
       MENUITEM  "Export to Excel"               ACTION ToExcel(oBrw)  FONT Font3 
       SEPARATOR                             
       MENUITEM  "Exit"                          ACTION Nil            FONT Font7 
   END MENU

   _ShowContextMenu(cForm, nY, nX) // displaying the menu
   InkeyGui(10)

   DEFINE CONTEXT MENU OF &cForm  // deleting menu after exiting 
   END MENU

   SET MENUSTYLE STANDARD  // MANDATORY! Return to the standard menu style!

   IF nTsbColor # oBrw:Cargo          // ������� �� ���� � ���� 
      oBrw:Cargo := nTsbColor         // ��������� ����� ��������� ����� 
      lRefresh   := .T.               // �������� ����������� 
   ENDIF 
  
   IF nLineStyle # -1                 // ������� �� ����� ����� � ���� 
      oBrw:nLineStyle := nLineStyle 
      lRefresh        := .T.          // �������� ����������� 
   ENDIF 
  
   IF lRefresh 
      oBrw:Display() 
      oBrw:Refresh(.T.)               // ������������ ������ � ������� 
   ENDIF 

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
STATIC FUNCTION ToExcel(oBrw)  
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
STATIC FUNCTION CreateDatos( nLine )

   LOCAL i, k := 100, aDatos, aHead, aSize := NIL, aFoot, aPict := NIL, aAlign := NIL, aName

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
         PadR( "Test line - " + ntoc( i ), 20 ), ;    // 6
         Round( ( 10000 -i ) * i / 3, 2 ), ;          // 7
         100.00 * i   }                               // 8
   NEXT

   aHead  := AClone( aDatos[ 1 ] )
   AEval( aHead, {| x, n| x:=nil, aHead[ n ] := "Head_" + hb_ntos( n ) } ) 
   aFoot  := Array( Len( aDatos[ 1 ] ) )
   AEval( aFoot, {| x, n| x:=nil, aFoot[ n ] := "Foot_" + hb_ntos( n ) } )
   aName     := Array( Len( aDatos[ 1 ] ) )
   AEval( aName, {| x, n| x:=nil, aName[ n ] := "Name_" + hb_ntos( n ) } )

   If k > SHOW_WAIT_WINDOW_LINE
      WaitWindow()            // close the wait window
      SET WINDOW MAIN ON
   EndIf

RETURN { aDatos, aHead, aSize, aFoot, aPict, aAlign, aName }
