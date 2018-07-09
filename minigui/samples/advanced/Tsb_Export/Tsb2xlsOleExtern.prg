/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
*/
#define _HMG_OUTLOG

#include "minigui.ch"
#include "tsbrowse.ch"

#define PBM_SETPOS       1026

* =======================================================================================
// Ќапример можно сделать так: bExtern := {|oSheet,oBrw| ExcelOleExtern(oSheet, oBrw) }
// —формировать Sheet и получил вызов в блок кода, можно пройтись по €чекам 
// Sheet и перебрать €чейки и строки oBrw и задать формулы, форматы, цвета, ...
// доступны все €чейки excel.
FUNCTION ExcelOleExtern( hProgress, lTsbFont, oSheet, oBrw )
   LOCAL nLine, nCol, nRow, aFColor, nBColor, nFColor, nStart, nVar
   LOCAL nCount, nTotal, nEvery, aFont, oCol, hFont, nI

   // nLine := 1  // титул таблицы 
   // nLine := 2  // пуста€ строка 
   // nLine := 3  // суперхидер таблицы, если есть 
   // nLine := 4  // шапка таблицы, если есть 
   // nLine := 5  // €чейки таблицы, перва€ €чейка (если есть суперхидер и шапка таблицы)
   // nLine := nLine + oBrw:nLen // подвал таблицы, если есть 

   // ÷вет шрифта титул таблицы
   aFColor := BLUE
   nLine := 1  
   oSheet:Cells( nLine, 1):Font:Color := RGB(aFColor[1],aFColor[2],aFColor[3])   

   nStart := 2

   // выводим цвета фона и текста суперхидера таблицы
   If oBrw:lDrawSuperHd //! Empty( oBrw:aSuperHead )

      nLine := 3  // суперхидер таблицы, если есть 

      For nCol := 1 To Len( oBrw:aSuperHead )

         nFColor := myColorN     ( oBrw:aSuperhead[ nCol, 4 ], oBrw, nCol ) // oBrw:nClrSpcHdFore
         nBColor := myColorN     ( oBrw:aSuperhead[ nCol, 5 ], oBrw, nCol ) // oBrw:nClrSpcHdBack
         aFont   := GetFontParam( oBrw:aSuperHead[ nCol, 7 ] )  // шрифт суперхидера

         For nI := oBrw:aSuperhead[ nCol, 1 ] To oBrw:aSuperhead[ nCol, 2 ]
             oCol := oBrw:aColumns[ nI ]
             nVar := If( oBrw:lSelector, 1, 0 )  // селектор слева - пока не использую
             oSheet:Cells( nLine, nI - nVar):Font:Color    := nFColor  // ÷вет шрифта шапки
             oSheet:Cells( nLine, nI - nVar):Interior:Color:= nBColor  // ÷вет фона шапки

             If lTsbFont 
                oSheet:Cells( nLine, nI - nVar):Font:Name := aFont[ 1 ]
                oSheet:Cells( nLine, nI - nVar):Font:Size := aFont[ 2 ]
                oSheet:Cells( nLine, nI - nVar):Font:Bold := aFont[ 3 ]
             Endif
         Next

      Next

      nLine++
      nStart := nLine
   EndIf

   // выводим цвета фона и текста шапки таблицы
   If oBrw:lDrawHeaders    

      nLine := nStart

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ]
          nFColor := myColorN( oCol:nClrHeadFore, oBrw, nCol ) 
          nBColor := myColorN( oCol:nClrHeadBack, oBrw, nCol ) 

          oSheet:Cells( nLine, nCol ):Font:Color     := nFColor   // ÷вет шрифта шапки
          oSheet:Cells( nLine, nCol ):Interior:Color := nBColor   // ÷вет фона шапки

          If lTsbFont 
             hFont := oCol:hFontHead              // шрифт шапки таблицы
             aFont := myFontParam( hFont, oBrw, nCol, 0 )
             oSheet:Cells( nLine, nCol ):Font:Name := aFont[ 1 ]
             oSheet:Cells( nLine, nCol ):Font:Size := aFont[ 2 ]
             oSheet:Cells( nLine, nCol ):Font:Bold := aFont[ 3 ]
          Endif
      Next

      nStart := nLine
   Endif

   If hProgress != Nil
      nTotal := oBrw:nLen 
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * 0.05 ) ) // refresh hProgress every 5 %
   EndIf

   Eval( oBrw:bGoTop )  // переход на начало таблицы
   nCount := 0

   // выводим цвета фона и текста €чеек всех колонок таблицы
   For nLine := 1 TO oBrw:nLen

      nRow := nStart + nLine

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ] 
          nFColor := myColorN( oCol:nClrFore, oBrw, nCol, oBrw:nAt ) 
          nBColor := myColorN( oCol:nClrBack, oBrw, nCol, oBrw:nAt ) 
 
          oSheet:Cells( nRow, nCol ):Font:Color     := nFColor   // ÷вет шрифта шапки
          oSheet:Cells( nRow, nCol ):Interior:Color := nBColor   // ÷вет фона шапки

         If lTsbFont 
            aFont := myFontParam( oCol:hFont, oBrw, nCol, oBrw:nAt )

            oSheet:Cells( nRow, nCol ):Font:Name := aFont[ 1 ]
            oSheet:Cells( nRow, nCol ):Font:Size := aFont[ 2 ]
            oSheet:Cells( nRow, nCol ):Font:Bold := aFont[ 3 ]
         Endif
      Next

      If hProgress != Nil

         If nCount % nEvery == 0
            SendMessage(hProgress, PBM_SETPOS,nCount,0)
         EndIf

         nCount ++
      EndIf

      oBrw:Skip(1)
   Next
 
   nStart := nRow + 1

 
   // выводим цвета фона и текста подвала таблицы
   If oBrw:lDrawFooters

      nLine := nStart

      For nCol := 1 TO Len( oBrw:aColumns )
          oCol    := oBrw:aColumns[ nCol ] 
          nFColor := myColorN( oCol:nClrFootFore, oBrw, nCol, oBrw:nAt ) 
          nBColor := myColorN( oCol:nClrFootBack, oBrw, nCol, oBrw:nAt ) 

          oSheet:Cells( nLine, nCol ):Font:Color     := nFColor   // ÷вет шрифта шапки
          oSheet:Cells( nLine, nCol ):Interior:Color := nBColor   // ÷вет фона шапки
   
          If lTsbFont 
             aFont := myFontParam( oCol:hFontFoot, oBrw, nCol, 0 )
   
             oSheet:Cells( nLine, nCol ):Font:Name := aFont[ 1 ]
             oSheet:Cells( nLine, nCol ):Font:Size := aFont[ 2 ]
             oSheet:Cells( nLine, nCol ):Font:Bold := aFont[ 3 ]
          Endif
      Next

      nLine++                          
      nStart := nLine
   Endif

   // ƒоп.надпись под таблицей
   nLine := nStart + 1
   aFColor := RED
   oSheet:Cells( nLine, 1):Font:Color := RGB(aFColor[1],aFColor[2],aFColor[3])   
   oSheet:Cells( nLine, 1):Value := "End table !" 

   RETURN Nil

* =======================================================================================
STATIC FUNCTION myColorN( nColor, oBrw, nCol, nAt )

   If Valtype( nColor ) == "B"
      If empty(nAt) 
         nColor := Eval( nColor, nCol, oBrw )
      Else
         nColor := Eval( nColor, nAt, nCol, oBrw )
      EndIf
   EndIf  

   If Valtype( nColor ) == "A"
      nColor := nColor[1]
   EndIf  

RETURN nColor

* =======================================================================================
STATIC FUNCTION myFontParam( hFont, oBrw, nCol, nAt )
   LOCAL aFont, oCol := oBrw:aColumns[ nCol ] 
   DEFAULT nAt := 0
   // шрифт €чеек таблицы
   hFont := If( hFont == Nil, oBrw:hFont, hFont )  
   hFont := If( ValType( hFont ) == "B", Eval( hFont, nAt, nCol, oBrw ), hFont )  

   If empty(hFont)
      aFont    := array(3) 
      aFont[1] := _HMG_DefaultFontName
      aFont[2] := _HMG_DefaultFontSize
      aFont[3] := .F.
   Else
      aFont := GetFontParam( hFont )
   EndIf

RETURN aFont

