/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Tsbrowse sample
 *
 * Copyright 2015, Verchenko Andrey <verchenkoag@gmail.com>
 * Many thanks for your help: SergKis - forum http://clipper.borda.ru
 *
*/
#include "MiniGUI.ch"
#include "TSBrowse.ch"

#define FILE_CONFIG  ChangeFileExt( Application.ExeName, ".config" ) 

MEMVAR aFont
STATIC nStatColor := 0, lStat_CRLF_test := .T., nStatRow := 0, nStatCol := 0
////////////////////////////////////////////////////////////////////////////
FUNCTION Main( lCRLF )
   LOCAL cFont := 'Tahoma', nFontSize := 16 

   lStat_CRLF_test := ! empty(lCRLF)   

   DEFINE FONT Font_CNF1  FONTNAME cFont SIZE nFontSize
   DEFINE FONT Font_CNF2  FONTNAME cFont SIZE nFontSize BOLD

   PUBLIC aFont := {}   // fonts for the entire program

   AAdd( aFont, GetFontHandle( "Font_CNF1" ) )
   AAdd( aFont, GetFontHandle( "Font_CNF2" ) )

   DEFINE WINDOW Form_Main ;
	AT 20 , 20 ;
	WIDTH 450 HEIGHT 280         ;
	TITLE "TsBrowse - function SetArrayTo()" ;
        ICON "1MAIN_ICO"             ;
        BACKCOLOR BROWN              ;
	MAIN                         ;
        NOMAXIMIZE NOSIZE            ;
        FONT cFont SIZE nFontSize    ;
        ON INIT {|| FormTbrTabField(), Form_Main.Release }    

        @ 120,20 BUTTONEX Button_1  WIDTH 250 HEIGHT 80  ;
            CAPTION "Test run"+ CRLF +"another window !" ;
            NOHOTLIGHT NOXPSTYLE HANDCURSOR              ;
            FONTCOLOR WHITE  BACKCOLOR ORANGE            ;
            ACTION FormTbrTabField()

        @ 120,300 BUTTONEX Button_2  WIDTH 120 HEIGHT 80 ;
            CAPTION 'Exit'                               ;
            NOHOTLIGHT NOXPSTYLE HANDCURSOR              ;
            FONTCOLOR WHITE  BACKCOLOR MAROON            ;
            ACTION { || Form_Main.Release }

   END WINDOW

   //CENTER WINDOW Form_Main
   ACTIVATE WINDOW Form_Main

RETURN NIL

////////////////////////////////////////////////////////////////////////////
FUNCTION FormTbrTabField(cTitle, aBColor, nTabNum, cTabName)
   LOCAL cIco  := "1MAIN_ICO" 
   LOCAL cFont := 'Tahoma', nFontSize := 16 
   LOCAL aBackColor := MyFormColor()  // ���� ���� ���� �����
   LOCAL aFButtColor1 := WHITE, aFButtColor2 := BLACK, nFButtSize := 12
   LOCAL nI, hWnd, nMaxHeight, nMaxWidth, cIco3x1, cIco3x2
   LOCAL nRow, nCol, nWButt, nHButt, cIco1x1, cIco1x2, cIco2x1, cIco2x2
   LOCAL aVar, cFormName, cButtCapt
   DEFAULT aBColor := SILVER , nTabNum := 1 , cTabName := "TEST"
   DEFAULT cTitle := "Setting the graph to display the table"

   aVar := {} 
   FOR nI := 1 TO 50 // test array for Tsbrowse with and without CRLF
      IF lStat_CRLF_test 
         AADD( aVar, { nI, "Field "+HB_NtoS(nI) + CRLF + SPACE(5) + "Example from CRLF", nI, .T. } )
      ELSE 
         AADD( aVar, { nI, "Field "+HB_NtoS(nI) + SPACE(3) + " - Example without CRLF", nI, .T. } )
      ENDIF 
   NEXT
   lStat_CRLF_test := IIF( lStat_CRLF_test, .F., .T.)

   cFormName  := "Form_SetFld" + HB_NtoS( _GetId() ) // a unique window name
   DEFINE WINDOW &cFormName         ;
      At nStatRow, nStatCol         ;
      WIDTH 790 HEIGHT 680          ;
      TITLE cTitle + " (" + cFormName + ")" ;
      ICON cIco                     ;
      CHILD                         ;
      NOSIZE                        ;
      FONT cFont SIZE nFontSize - 2 ;
      BACKCOLOR aBackColor          ;
      ON INIT { || DoMethod( cFormName, "Restore" ) }

      hWnd := GetFormHandle(cFormName) 
      nMaxWidth  := GetClientWidth(hWnd)   
      nMaxHeight := GetClientHeight(hWnd)

      /////////////////////// Building Browse  ////////////////////////////
      CreateBrowseCnfCard(aVar,aBColor,cTabName,20 + 10,20, ;
                         nMaxWidth-20*2,nMaxHeight - 74 - 10 - (20 + 40))

      //////////////////// The output buttons on the form ////////////////////
      nWButt := 210   ;  nHButt := 78
      nRow := nMaxHeight - nHButt - 20

      cButtCapt := "Upload" + CRLF + "order" + CRLF + "display"
      nCol := ( nMaxWidth  - nWButt*2 )/3 - 50
      cIco1x1 := "iLoad48x1"  ;  cIco1x2 := "iLoad48x2"
      @ nRow, nCol BUTTONEX BUTTON_Load  WIDTH nWButt HEIGHT nHButt  ;
         CAPTION cButtCapt      ;
         ICON cIco1x1           ; 
         FONTCOLOR aFButtColor1 ;
         BACKCOLOR PURPLE       ;
         SIZE nFButtSize BOLD   ;
         NOXPSTYLE HANDCURSOR   ;
         ON MOUSEHOVER ( SetProperty(ThisWindow.Name, This.Name, "ICON", cIco1x2 ) ,;
                         SetProperty(ThisWindow.Name, This.Name, "fontcolor", aFButtColor2 ) ) ;
         ON MOUSELEAVE ( SetProperty(ThisWindow.Name, This.Name, "ICON", cIco1x1 ) ,;
                         SetProperty(ThisWindow.Name, This.Name, "fontcolor", aFButtColor1 ) ) ;
         ACTION { || MyLoadDim(cFormName), BrwSetFocus(cFormName) } ;
         NOTABSTOP        // if the focus is on the button will not work ESC,
                          // set in oBrw52: bOnEscape, because disconnect
  			
      cButtCapt := "Save" + CRLF + "order" + CRLF + "display"
      nCol := ( nMaxWidth  - nWButt*2 )/3 + nWButt - 40
      cIco2x1 := "iSave48x1"  ;  cIco2x2 := "iSave48x2"
      @ nRow, nCol BUTTONEX BUTTON_Save  WIDTH nWButt HEIGHT nHButt  ;
         CAPTION cButtCapt      ;
         ICON cIco2x1           ; 
         FONTCOLOR aFButtColor1 ;
         BACKCOLOR LGREEN       ;
         SIZE nFButtSize BOLD   ;
         NOXPSTYLE HANDCURSOR   ;
         ON MOUSEHOVER ( SetProperty(ThisWindow.Name, This.Name, "ICON", cIco2x2 ) ,;
                         SetProperty(ThisWindow.Name, This.Name, "fontcolor", aFButtColor2 ) ) ;
         ON MOUSELEAVE ( SetProperty(ThisWindow.Name, This.Name, "ICON", cIco2x1 ) ,;
                         SetProperty(ThisWindow.Name, This.Name, "fontcolor", aFButtColor1 ) ) ;
         ACTION { || MySaveDim(cFormName), BrwSetFocus(cFormName) } ;
         NOTABSTOP        // ���� ����� ����� �� ������, �� ��������� ESC,
                          // ������������� � oBrw52:bOnEscape, ������ ���������
  			
      cButtCapt := "Exit without" + CRLF + "save"
      nCol := ( nMaxWidth  - nWButt*2 )/3 + nWButt*2 - 30
      cIco3x1 := "iExit48x1"  ;  cIco3x2 := "iExit48x2"
      @ nRow, nCol BUTTONEX BUTTON_Exit  WIDTH nWButt HEIGHT nHButt  ;
         CAPTION cButtCapt      ;
         ICON cIco3x1           ; 
         FONTCOLOR aFButtColor1 ;
         BACKCOLOR RED          ;
         SIZE nFButtSize BOLD   ;
         NOXPSTYLE HANDCURSOR   ;
         ON MOUSEHOVER ( SetProperty(ThisWindow.Name, This.Name, "ICON", cIco3x2 ) ,;
                         SetProperty(ThisWindow.Name, This.Name, "fontcolor", aFButtColor2 ) ) ;
         ON MOUSELEAVE ( SetProperty(ThisWindow.Name, This.Name, "ICON", cIco3x1 ) ,;
                         SetProperty(ThisWindow.Name, This.Name, "fontcolor", aFButtColor1 ) ) ;
         ACTION { || ThisWindow.Release } ;
         NOTABSTOP        // ���� ����� ����� �� ������, �� ��������� ESC,
                          // ������������� � oBrw52:bOnEscape, ������ ���������

   END WINDOW

   IF nStatRow == 0
      DoMethod( cFormName, "Center"   ) // CENTER WINDOW
      nStatRow := GetProperty( cFormName, "Row" )
      nStatCol := GetProperty( cFormName, "Col" )
   ELSE
      nStatRow := nStatRow + 20
      nStatCol := nStatCol + 20
      SetProperty( cFormName, "Row" , nStatRow )
      SetProperty( cFormName, "Col" , nStatCol )
   ENDIF
   DoMethod( cFormName, "Activate" ) // ACTIVATE WINDOW

RETURN NIL

/////////////////////////////////////////////////////////////////////////
STATIC FUNCTION CreateBrowseCnfCard(aDim,aBColor,cTabName,nTbrRow,nTbrCol,nTbrWidth,nTbrHeight)
    LOCAL aTbrBackColor := aBColor
    LOCAL nTbrHeadBack := MyRGB( { 183, 130, 122 } )   
    LOCAL cFont := 'Tahoma', nFontSize := 16, aFontHF, nAt
    LOCAL aArray, aHead, aFSize, aFoot, aPict, aAlign, aName, oCol
    LOCAL cTbrName, oBrw52, cForm  := ThisWindow.Name

    // ������������ ������� ��� ������ � TsBrowse 
    // forming array for display in TsBrowse
    aArray   := aDim
    aHead    := {"��", "Name" + CRLF + "card fields", "order" + CRLF + "display", "[v] show" + CRLF + "no show" }
    aFSize   := { 60 , 350, 160, 160 }
    aFoot    := { "" , "Recno: 0/0", "" , "" }
    aPict    := {           ,      , "@Z 999" ,       } 
    aAlign   := { DT_CENTER ,      , DT_CENTER,       }
    aName    := { "NN"      ,"NAME", "VIEW"   , "LSEE"}

    cTbrName := "Set_Columns"
DEFINE TBROWSE &cTbrName     ; 
     AT nTbrRow, nTbrCol     ; 
     WIDTH  nTbrWidth + 2    ;  // + 2 - ��� ��� �� �� ���������� ���.��������
     HEIGHT nTbrHeight       ;
     FONT cFont SIZE nFontSize - 2 ;
     BACKCOLOR aTbrBackColor ;
     GRID  ;                   // ��� oBrw:lCellBrw := TRUE
     EDIT                      // ��� ������� � lEdit := .T.

     aFontHF := aFont[2]       //  bold  Header, Footer

     oBrw52 := SetArrayTo( cTbrName, cForm, aArray, aFontHF, aHead, aFSize,;
                                     aFoot, aPict, aAlign, aName )

     oBrw52:AddSuperHead(1, 4, "Tab: " + cTabName) // ����������

     /////////////////////// ��������� TsBrowse ///////////////////////////////////
     oBrw52:nWheelLines  := 4   // ��� ����� (�� 1-5)
     oBrw52:nClrLine     := COLOR_GRID
     oBrw52:lNoChangeOrd := TRUE
     oBrw52:lCellBrw     := TRUE
     oBrw52:lNoVScroll   := TRUE
     oBrw52:lNoHScroll   := .T. // ����� ��������������� ���������

     oBrw52:nFreeze      := 2   // ���������� ������ 2 �������
     oBrw52:lLockFreeze  := .T. // �������� ���������� ������� �� ������������ ��������
     oBrw52:lNoGrayBar   := .T. // �� ���������� ���������� ������
     oBrw52:nAdjColumn   := 2   // ��������� ������� 2 �� ���������� ������� � ������ ������
     oBrw52:nHeightCell  += 12  // � ������ ����� �� ����������  �������� xx �������                                                          
     oBrw52:nHeightHead  += 12  // � ������ ������ ��������� �� ���������� �������� xx �������
     oBrw52:nHeightSuper := 34  // ������ ��������� ( ��������� )
     IF ! Empty( aFoot )
        oBrw52:nHeightFoot += 8
     ENDIF

     // ������� ��������� ��� �����. ������� ������� 
     oBrw52:bChange := { |oBrw| oBrwChange(oBrw) }  
     // ----------- ������ ����� �����������/������� ���� �������� ---------
     oBrw52:ResetVScroll()        // ����� ������������� ���������

     // --------- ��������� �������������� ������� (���� ����� � �� ������) ---------
     oBrw52:GetColumn("NN"):lEdit := .F.
     oBrw52:GetColumn("NAME"):lEdit := .F.
     // ������ ��� ������� 2 ������� DT_RIGHT 
     // oBrw52:aColumns[2]:nFAlign := DT_RIGHT ���
     oBrw52:GetColumn("NAME"):nFAlign := DT_RIGHT

     oBrw52:Setcolor( { 3}, { CLR_YELLOW   } )  // 3 , ������ ����� ������� 
     oBrw52:Setcolor( { 4}, { nTbrHeadBack } )  // 4 , ���� ����� �������   
     oBrw52:SetColor( { 9}, { CLR_YELLOW   } )  // 9 , ������ ������� �������                                
     oBrw52:SetColor( {10}, { nTbrHeadBack } )  // 10, ���� ������� �������                                  

     oBrw52:SetColor( {  5 }, { { ||   CLR_BLACK     } } ) // 5 , ������ �������, ����� � ������� � �������             
     oBrw52:SetColor( {  6 }, { { || { 4915199,255}  } } ) // 6 , ���� �������                                          
     oBrw52:SetColor( {  7 }, { { ||   CLR_RED       } } ) // 7 , ������ �������������� ����                            
     oBrw52:SetColor( {  8 }, { { ||   CLR_YELLOW    } } ) // 8 , ���� �������������� ����                              
     oBrw52:SetColor( { 16 }, { { || nTbrHeadBack    } } ) // 16, ���� ���������                                  
     oBrw52:SetColor( { 17 }, { { || CLR_WHITE       } } ) // 17, ������ ���������

     // �������������� 4-������� �� ������� � ������ ��������� � ����������� EDIT
     //oBrw52:aColumns[4]:bPrevEdit := { || TestNameFunc(oBrw52), oBrw52:Refresh(FALSE), FALSE } 
     // ��������� ����� �������������� 4-������� �� ������� 
     // ���� [4] ������� == F �� � [3] ������� ����� 0
     // ### 1-�������:  ��� �������� �� ������������ ��� ������� [4]   
     // oBrw52:aColumns[4]:bPrevEdit := { || oBrw52:aArray[oBrw52:nAt][3] := IF(oBrw52:aArray[oBrw52:nAt][4],;
     //                                        oBrw52:aArray[oBrw52:nAt][3], 0 ) }

     // ### 2-�������: ��� �������� ����� ������������ ��� ������� [4] - "VIEW"
     // valid �������� (���������� ������ ������ .T.\.F.)
     // ������ ������ � �������: nValue >= 0 .and. nValue <= Len(oBrw:aArray)
     oCol := oBrw52:GetColumn("VIEW")
     oCol:bValid    := { |nValue,oBrw| nValue >= 0 .and. nValue <= Len(oBrw:aArray) }
     // ����� edit ��� ���������� ����� � ������, ��� ���� Edit, ������� refresh
     oCol:bPostEdit := { |nValue, oBrw| nAt := oBrw:nAt, ;
          oBrw:aArray[nAt][4] := If( nValue == 0 .and. oBrw:aArray[nAt][4], ;
          .F., oBrw:aArray[nAt][4] ), Itog_VIEW(oBrw), oBrw:Refresh(.F.) }
     // ���� ������ � ������� 3 ����� 0, �� ������� 4 ���� ��������� � .F.             
              
     // nAt := oBrw:nAt - ��� ������ ��������� ����� ���������� � ���� ���� � ��
     // �������������, ����� � ��� ��� (���������� � |...,nAt| �������������)
     oCol := oBrw52:GetColumn("LSEE")
     oCol:bPostEdit := { |lValue, oBrw| nAt := oBrw:nAt, ;
         oBrw:aArray[nAt][3] := If( lValue, oBrw:aArray[nAt][1], 0 ), ;
         Itog_VIEW(oBrw), oBrw:Refresh(.F.) }
         
     oBrw52:GoPos(2, 3)      // ����������� ������ �� 2 ������ � 3 �������
  
     // ���� ���� ��� ������� ESC � TSB 
     oBrw52:bOnEscape := {|| DoMethod(oBrw52:cParentWnd, "Release") }

     Itog_VIEW(oBrw52)   // ���� �� ������� VIEW

END TBROWSE  

   SetNoHoles( oBrw52 ) // ������ ����� ����� ������� ����� ��������

   // �� ������ ������ ����� - ����������� ���� TBROWSE
   DEFINE CONTEXT MENU CONTROL &cTbrName
       MENUITEM "Display size" ACTION { || MsgInfo( HB_NtoS(GetDesktopWidth())+"x"+HB_NtoS(GetDesktopHeight()) ) }
       SEPARATOR
       MENUITEM "HeightHead="  ACTION { || MsgDebug("HeightHead=",oBrw52:nHeightHead) }
       MENUITEM "HeightCell="  ACTION { || MsgDebug("HeightCell=",oBrw52:nHeightCell) }
       MENUITEM "HeightFoot="  ACTION { || MsgDebug("HeightFoot=",oBrw52:nHeightFoot) }
       MENUITEM "nRowCount()=" ACTION { || MsgDebug("nRowCount()=",oBrw52:nRowCount()) }
   END MENU

   // ���������� Form_Tbrw52.&(cTbrName).SetFocus
   DoMethod(oBrw52:cParentWnd, oBrw52:cControlName, "SetFocus")

RETURN NIL

////////////////////////////////////////////////////////////////////
STATIC PROCEDURE Itog_VIEW( oBrw )           // ���� �� ������� VIEW
   LOCAL nCol := oBrw:nColumn("VIEW")
   LOCAL oCol := oBrw:GetColumn(nCol)
   LOCAL nItg := 0

   aEval(oBrw:aArray, { |aVal| nItg += If( Empty(aVal[ nCol ]), 0, 1 ) })

   oCol:cFooting := hb_ntos(nItg)

RETURN

////////////////////////////////////////////////////////////
STATIC FUNCTION gBrw52(cForm)     // get object oTsb

RETURN _HMG_aControlIds[ GetControlIndex('Set_Columns', cForm) ]

////////////////////////////////////////////////////////////
STATIC FUNCTION BrwSetFocus(cForm)  // ��������� ����� �� ������� 
   LOCAL oBrw := gBrw52(cForm)  

   DoMethod(oBrw:cParentWnd, oBrw:cControlName, "SetFocus")

RETURN NIL

//////////////////////////////////////////////////////////////////
STATIC FUNCTION oBrwChange( oBrw, cName ) 
   LOCAL cVal := HB_NToS( oBrw:nAt )  
   LOCAL cLen := HB_NToS( oBrw:nLen )
   DEFAULT cName := "NAME"

   oBrw:GetColumn(cName):cFooting := " Recno: " + cVal + "/" + cLen + " "
   oBrw:DrawFooters()   // ��������� ���������� �������

RETURN Nil 

////////////////////////////////////////////////////////////////////
// ������ ����� ����� ������� ����� ��������
FUNCTION SetNoHoles( oBrw )          
 LOCAL nI, nK, nHeight
 LOCAL nHole := oBrw:nHeight - oBrw:nHeightHead - oBrw:nHeightSuper - ; 
                oBrw:nHeightFoot - oBrw:nHeightSpecHd - ;
                If( ! oBrw:lNoHScroll, 16, 0 ) 

 nHole   -= ( Int( nHole / oBrw:nHeightCell ) * oBrw:nHeightCell )
 nHole   -= 1
 nHeight := nHole

 nI := If( oBrw:nHeightSuper  > 0, 1, 0 ) + ;
       If( oBrw:nHeightHead   > 0, 1, 0 ) + ;
       If( oBrw:nHeightSpecHd > 0, 1, 0 ) + ;
       If( oBrw:nHeightFoot   > 0, 1, 0 )
       
 If nI > 0                          // ���� ���������

    nK := int( nHole / nI )         // �� nI - ��������� �������� �����

    If oBrw:nHeightFoot   > 0
       oBrw:nHeightFoot   += nK
       nHole              -= nK
    EndIf
    If oBrw:nHeightSuper  > 0
       oBrw:nHeightSuper  += nK
       nHole              -= nK
    EndIf
    If oBrw:nHeightSpecHd > 0
       oBrw:nHeightSpecHd += nK
       nHole              -= nK
    EndIf
    If oBrw:nHeightHead   > 0
       oBrw:nHeightHead   += nHole
    EndIf

 Else             // ��� ����������, ����� ��������� ������ tsb �� ������ nHole

    SetProperty(oBrw:cParentWnd, oBrw:cControlName, "Height",         ;
    GetProperty(oBrw:cParentWnd, oBrw:cControlName, "Height") - nHole)

 EndIf

 oBrw:Display()

RETURN nHeight

////////////////////////////////////////////////////////////////////
// ������� ������ ������� ����� TBROWSE � ����-���������
STATIC FUNCTION MySaveDim(cForm)
   LOCAL oBrw := gBrw52(cForm)  
   LOCAL cStr, nI, nLenTbrArray := LEN(oBrw:aArray)

   cStr := ""
   FOR nI := 1 TO nLenTbrArray
       cStr += STR(oBrw:aArray[nI][1],2)+","
       cStr += STRTRAN(oBrw:aArray[nI][2],CRLF," ") +"," 
       cStr += STR(oBrw:aArray[nI][3],2)+","
       cStr += cValToChar(oBrw:aArray[nI][4]) + ";" 
   NEXT
   HB_MemoWrit( FILE_CONFIG, cStr )

   MsgInfo("The configuration file is successfully written !" + ;
             CRLF + CRLF + FILE_CONFIG)

   RETURN NIL

////////////////////////////////////////////////////////////////////
// ������� ������ �����-��������� � ������ ����� TBROWSE 
STATIC FUNCTION MyLoadDim(cForm)
   LOCAL oBrw := gBrw52(cForm)  
   LOCAL aDim, cStr, aStr, nI, nLenTbrArray := LEN(oBrw:aArray)

   IF FILE(FILE_CONFIG)
      cStr := HB_MemoRead(FILE_CONFIG)
      aStr := HB_aTokens(cStr, ";")
      aDim := {}
      AEval(aStr, {|cLine| aAdd(aDim, hb_aTokens(cLine, ",")) })
      FOR nI := 1 To Len(aDim) - 1  // ����� ���� �������� �������, �.�. ����.������ = NIL
          aDim[ nI ][1] := Val(aDim[ nI ][1])
          //aDim[ nI ][2] := Val(aDim[ nI ][2])
          aDim[ nI ][3] := Val(aDim[ nI ][3])
          aDim[ nI ][4] := aDim[ nI ][4] == "T"
      NEXT
      
      // ������ �������� �� ����� � ������ ����� TBROWSE 
      FOR nI := 1 TO nLenTbrArray
          oBrw:aArray[nI][3] := aDim[ nI ][3]
          oBrw:aArray[nI][4] := aDim[ nI ][4] 
      NEXT

      Itog_VIEW(oBrw)   // ���� �� ������� VIEW
      oBrw:Refresh(.T.) // ���������� ������ �� ������

      MsgInfo("The configuration file is successfully read !" + ;
                CRLF + CRLF + FILE_CONFIG)
   ELSE
      MsgStop("No configuration file !" + ;
                CRLF + CRLF + FILE_CONFIG)
   ENDIF

   RETURN NIL

////////////////////////////////////////////////////////////////////
// ������� �������������� �����
FUNCTION MyRGB(aDim)
   RETURN RGB(aDim[1],aDim[2],aDim[3])

////////////////////////////////////////////////////////////////////
// ������� ������ ����� �����
FUNCTION MyFormColor()
   LOCAL aColor := { TEAL, BROWN, AQUA, FUCHSIA, ORANGE, GREEN, PURPLE,;
         GRAY, BLUE, SILVER, MAROON, OLIVE, PINK, LGREEN, NAVY, YELLOW }

   nStatColor++
   nStatColor := IIF(nStatColor > LEN(aColor), 1, nStatColor)

   RETURN aColor[nStatColor]

///////////////////////////////////////////////////////////////////////////////////////////
// SergKis  http://clipper.borda.ru/?1-1-0-00000389-000-0-1-1408089634
// 
// GETCLIENTHEIGHT(0) - ������ ���������� (����������) ������� Desktop � ������ ������� ������ Start
// GETCLIENTWIDTH(0) - ������ ���������� (����������) ������� Desktop
// GETCLIENTHEIGHT(hWnd) - ������ ���������� (����������) ������� ���� (��� ��������)
// GETCLIENTWIDTH(hWnd) - ������ ���������� (����������) ������� ���� (��� ��������)
// �.�.:
// hWnd := GetFormHandle('Form_0')
// CreateBrowse( "oBrw_1", 'Form_0', 32, 2, GetClientWidth(hWnd), GetClientHeight(hWnd), 'LOG_DBF' )

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( GETCLIENTWIDTH )
{
   RECT rect;
   LONG hWnd=hb_parnl(1);

   if(hWnd==0) SystemParametersInfo( SPI_GETWORKAREA, 0, &rect, 0);
   else        GetClientRect( ( HWND ) hWnd, &rect );

   hb_retni( ( INT ) rect.right - rect.left );
}

HB_FUNC( GETCLIENTHEIGHT )
{
   RECT rect;
   LONG hWnd=hb_parnl(1);

   if(hWnd==0) SystemParametersInfo( SPI_GETWORKAREA, 0, &rect, 0);
   else        GetClientRect( ( HWND ) hWnd, &rect );

   hb_retni( ( INT ) rect.bottom - rect.top );
}

#pragma ENDDUMP
