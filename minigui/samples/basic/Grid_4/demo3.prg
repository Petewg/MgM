/*
 * MiniGUI Grid Achoice Demo
 *
 * Copyright 2014, Verchenko Andrey <verchenkoag@gmail.com>
 * Many thanks for your help: SergKis - forum http://clipper.borda.ru
 *
*/

#include "minigui.ch"

STATIC lNolines        := .T.  // Show / hide the dividing lines in the grid
STATIC lCellNavigation := .T.  // Set the cell navigation style in the grid
STATIC lShowHeaders    := .F.  // Show / hide table headers in the grid
STATIC aStColorWin, aStColorAch, aStColorAch1, aStColorAch2
STATIC aStColorAchFC, aStColorAchFB, aStColorMarker

///////////////////////////////////////////////////////////////////////////
Procedure Main
LOCAL aSelect, aItems, aLogic 

   aStColorWin   := TEAL    // the background color of all windows
   aStColorAch   := LGREEN  // background color Achoice()
   aStColorAchFB := GREEN   // background element of the array when aLocic[]=.F. - The choice is prohibited
   aStColorAchFC := MAROON  // color array element at aLocic[]=.F. - The choice is prohibited
   aStColorAch1  := YELLOW  // the first element of the array with color aLocic[]=.T. - The choice is allowed
   aStColorAch2  := WHITE   // the second color array element at aLocic[]=.T. - The choice is allowed
   aStColorMarker:= BLACK   // background cursor / selection marker in Achoice()

   SET MULTIPLE    OFF

   aItems := MyLoadArray(2)
   aLogic := MyLoadArray(3)

   DEFINE WINDOW wMain ;
      TITLE "Main Form" ;
      MAIN ;
      BACKCOLOR aStColorWin ;
      ON INIT {|| aSelect := Achoice( , , 700, 460, aItems, aLogic ), ;
                  MsgInfo({ "Selected menu: ", iif( aSelect[1] == 0, "Exit button", aItems[aSelect[1]][1]), ;
                  CRLF+" Key/button menu: ", aSelect[2] }, "Result" ), ;
                  ThisWindow.Release }
   END WINDOW

   ACTIVATE WINDOW wMain

Return 

///////////////////////////////////////////////////////////////////////////
FUNCTION ACHOICE( notused1, notused2, nWidth, nHeight, aItems, aLogic)
LOCAL cTitle := "Making of the Grid function Achoice()" 
LOCAL aHead := {'Selection menu'} // Showing at lShowHeaders := .T.
LOCAL aBtnColor := WHITE, nRet := 0, aRet := {nRet,"[x]"} // returned array

LOCAL aColor  := aStColorAch    // background color Achoice()
LOCAL aColor2 := aStColorAch1   // the first element of the array with color aLogic[]=.T. - The choice is allowed
LOCAL aColor3 := aStColorAch2   // the second color array element at aLogic[]=.T. - choice is allowed         
LOCAL aColorFB := aStColorAchFB // background element of the array when aLogic[]=.F. - choice is prohibited
LOCAL aColorFC := aStColorAchFC // color array element at aLogic[]=.F. - choice is prohibited              

LOCAL bColorFore := { | Val, nRow | iif( aLogic[nRow],                            ;
      iif( nRow / 2 == Int( nRow / 2 ), RGB( aColor2[1],aColor2[2],aColor2[3] ) , ;
                                        RGB( aColor3[1],aColor3[2],aColor3[3] )), ;
      RGB( aColorFC[1],aColorFC[2],aColorFC[3] )) }   // fontcolor

LOCAL bColorBack := { | Val, nRow | iif( aLogic[nRow],                         ;
      iif( nRow / 2 == Int( nRow / 2 ), RGB( aColor[1],aColor[2],aColor[3] ) , ;
                                        RGB( aColor[1],aColor[2],aColor[3] )), ;
      RGB( aColorFB[1],aColorFB[2],aColorFB[3] )) }  // backcolor

LOCAL cFontName := 'Tahoma', nFontSize := 14

	DEFINE WINDOW Form_2 ;
            AT 0,0 ;
            WIDTH nWidth ;
            HEIGHT nHeight ;
            TITLE cTitle ;
            MODAL ;
            NOSIZE  ;
            BACKCOLOR aStColorWin ;
            FONT cFontName  SIZE nFontSize

        DEFINE GRID Grid_2
            ROW  10
            COL  10
            WIDTH   nWidth - 10*2 -10
            HEIGHT  nHeight - 140 
            WIDTHS  { nWidth - 40 }    
            HEADERS aHead 
            ITEMS   aItems  
            VALUE   iif( Len(aItems) > 1, 2, 1 )    // for the OnChange -> 2
                                                    // when init grid
            ON DBLCLICK {|| nRet := MyGridChoice(1,aLogic), aRet := {nRet,"ENTER"}, ThisWindow.Release }
            NOLINES lNolines
            CELLNAVIGATION lCellNavigation
            SHOWHEADERS lShowHeaders
            FONTNAME cFontName
            FONTSIZE nFontsize
            FONTBOLD .T.
            FONTCOLOR BLUE
            BACKCOLOR aStColorAch
            DYNAMICFORECOLOR { bColorFore, bColorFore, bColorFore }
            DYNAMICBACKCOLOR { bColorBack, bColorBack, bColorBack }
            ON CHANGE mySkip(aLogic)

        END GRID
        
        @ 340,30 LABEL Label_1 VALUE "<F4>, <Enter> - choice" ;
            WIDTH 220 HEIGHT 28 SIZE 12 BOLD TRANSPARENT
        
        ON KEY F4 ACTION {|| nRet := MyGridChoice(2,aLogic), aRet := {nRet,"F4"}, ThisWindow.Release() }  

        @ 365, 300 BUTTONEX Button_1    ;
            WIDTH 170  HEIGHT 35        ;
            SIZE 11 BOLD                ;
            CAPTION '&Report selection' ;
            NOHOTLIGHT NOXPSTYLE        ;
            FONTCOLOR WHITE             ;
            BACKCOLOR BLUE              ;
            ACTION {|| nRet := MyGridChoice(3,aLogic), aRet := {nRet,"BUTTON1"}, ThisWindow.Release() }

        @ 365, 500 BUTTONEX Button_2    ;
            WIDTH 150  HEIGHT 35        ;
            SIZE 11 BOLD                ;
            CAPTION 'E&xit'             ;
            NOHOTLIGHT NOXPSTYLE        ;
            FONTCOLOR WHITE             ;
            BACKCOLOR RED               ;
            ACTION {|| nRet := 0, aRet := {nRet,"EXIT"}, ThisWindow.Release() }

         // 12 rows in the grid
         OnInitGrid(12, cFontName, nFontSize, aItems)   

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

Return aRet

///////////////////////////////////////////////////////////////////////////
Procedure OnInitGrid( nRows, cFontName, nFontSize, aItems )
LOCAL hGrid, nWidth := 0

   Default nRows To 10

   // consider max width in pixels of the line aItems[]
   AEval(aItems, {|a,n| nWidth := Max(nWidth, GetTxtWidth(a[1] + Replicate('W', 7), nFontSize, cFontName)) })

   _HMG_GridSelectedRowForeColor  := RED
   _HMG_GridSelectedRowBackColor  := aStColorMarker
   _HMG_GridSelectedCellForeColor := RED
   _HMG_GridSelectedCellBackColor := aStColorMarker

   hGrid                := Form_2.Grid_2.Handle
   Form_2.Grid_2.Height := GetHeght_ListView( hGrid, nRows )
   Form_2.Grid_2.Width  := nWidth + GetVScrollBarWidth() + 2

   _SetColumnsWidthAutoH('Grid_2', 'Form_2')
 
   Form_2.Grid_2.SetFocus
 
Return

///////////////////////////////////////////////////////////////////////////
Function MyLoadArray(nVal)
Local nI, nJ := 1, nG := 1, aIco := {}, aRows := {}, aLog := {}, aRet

   AAdd( aIco , "Folder.bmp" ) 
   AAdd( aRows, { PadC(" Group number: "+hb_ntos(nG)+" ", 70, "-") } )
   AAdd( aLog , .F. )

   FOR nI := 1 TO 25

      IF nI % 5 == 0  
         nG++
         aIco[nI]  := "Folder.bmp" 
         aRows[nI] := { PADC(" Group number: "+HB_NtoS(nG)+" ",70,"-") }
         aLog[nI] := .F. 
         nJ := 1
      ENDIF

      AAdd( aIco , "File.bmp" )
      AAdd( aRows, { SPACE(5)+"Example filename - "+HB_NtoS(nG)+HB_NtoS(nJ++)+".txt" } )
      AAdd( aLog , .T. )

   NEXT

   IF nVal == 1
      aRet := ACLONE(aIco)  
   ELSEIF nVal == 2 
      aRet := ACLONE(aRows)  
   ELSEIF nVal == 3 
      aRet := ACLONE(aLog)  
   ENDIF

Return aRet

///////////////////////////////////////////////////////////////////////////
FUNCTION MyGridChoice( nVal, aLogic )
Local aMenuNum := Form_2.Grid_2.Value
Local cMenuName, nRet := 0, cText

   cText := IIF(nVal==2,"You press key [F4]" + CRLF + CRLF,"")
   cText += IIF(nVal==3,"You press button [Report selection]" + CRLF + CRLF,"")

   cText += "Menu selection = {" + STR(aMenuNum[1],2)+","+STR(aMenuNum[2],2)+" }" + CRLF + CRLF
   cMenuName := Alltrim( GetProperty( "Form_2", "Grid_2", "Cell", aMenuNum[1], 1 ) )

   cText += "Menu selection = [" + cMenuName + "]" + CRLF + CRLF

   IF aLogic[ aMenuNum[1] ] == .T.
      nRet := aMenuNum[1]
   ENDIF

Return nRet

///////////////////////////////////////////////////////////////////////////
Procedure mySkip(aLogic)
Local nRow, lDn

STATIC nRowOld := 0

If IsControlDefined(Grid_2, Form_2)
   nRow := Form_2.Grid_2.Value [ 1 ]
   If aLogic[nRow] == .F.
      lDn     := nRow > nRowOld
      nRowOld := nRow
      IF lDn .OR. nRow == 1
         _PushKey( VK_DOWN )
      ELSE
         _PushKey( VK_UP )
      ENDIF
   EndIf
EndIf

Return

///////////////////////////////////////////////////////////////////////////////
FUNCTION GetTxtWidth( cText, nFontSize, cFontName )  // get the width of the text
LOCAL hFont, nWidth

 IF Valtype(cText) == 'N'
    cText := Replicate('A', cText)
 ENDIF

 DEFAULT cText     := Replicate('A', 2),     ;
         cFontName := _HMG_DefaultFontName,  ;
         nFontSize := _HMG_DefaultFontSize

 hFont  := InitFont(cFontName, nFontSize)
 nWidth := GetTextWidth(0, cText, hFont)
 
 DeleteObject (hFont)                    

RETURN nWidth

///////////////////////////////////////////////////////////////////////////
FUNCTION GetHeght_ListView( hBrw, nRows ) // height Grid \ Browse on the number of rows
LOCAL a

 a    := ListViewApproximateViewRect( hBrw, nRows - 1 )  // { Width, Height }
 a[1] += Round(GetBorderWidth ()/2, 0)                   // Width
 a[2] += Round(GetBorderHeight()/2, 0)                   // Height

RETURN a[2]

 
#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>

HB_FUNC( LISTVIEWAPPROXIMATEVIEWRECT )
{
  int iCount = hb_parni(2);
  DWORD Rc;

  Rc = ListView_ApproximateViewRect( ( HWND ) hb_parnl(1), -1, -1, iCount); 

  hb_reta( 2 );
  HB_STORNI( LOWORD(Rc), -1, 1 );
  HB_STORNI( HIWORD(Rc), -1, 2 );
}

#pragma ENDDUMP
