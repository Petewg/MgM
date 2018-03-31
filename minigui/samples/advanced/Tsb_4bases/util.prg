/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 SergKis - http://clipper.borda.ru
 * Design and color were made by Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "minigui.ch"
#include "tsbrowse.ch"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
Function TBrw_Create( ControlName, ParentForm, nRow, nCol, nWidth, nHeight, uAlias, lCell, FontName, FontSize, Backcolor )
   Local oBrw, nHgt := 0, nWdt := 0, hWnd, aRect := {0,0,0,0}
   Local aImages := NIL, aHeaders := NIL, aWidths := NIL, bFields := NIL, Value := 1
   Local tooltip := NIL, change := NIL, bDblclick := NIL, aHeadClick := NIL, gotfocus := NIL, lostfocus := NIL
   Local Delete := .F., lNogrid := .F., aJust := NIL, HelpId := NIL
   Local bold := .F., italic := .F., underline := .F., strikeout := .F.
   Local break := .F., fontcolor := NIL
   Local lock := .F., nStyle := NIL, appendable := .F., readonly := NIL
   Local valid := NIL, validmessages := NIL, aColors := NIL, uWhen := NIL, nId := NIL, aFlds := NIL, cMsg := NIL
   Local lRePaint := .T., lEnum := .F., lAutoSearch := .F., uUserSearch := NIL
   Local lAutoFilter := .F., uUserFilter := NIL, aPicture := NIL, lTransparent := .F.
   Local uSelector := NIL, lAutoCol := .F., aColSel := NIL, lEditable := .F.

    Default nRow       := 0,                    ;
            nCol       := 0,                    ;
            nWidth     := 0,                    ;
            nHeight    := 0,                    ;
            lCell      := .T.,                  ;
            backcolor  := NIL,                  ;
            ParentForm := _HMG_ThisFormName,    ;
            FontName   := _HMG_DefaultFontName, ;
            FontSize   := _HMG_DefaultFontSize  

    hWnd := GetFormHandle(ParentForm)

    GetClientRect(hWnd, aRect)
    
    If nWidth  < 0                                         // ширина уменьшения
       nWdt   := nWidth
       nWidth := 0
    EndIf
    
    If nWidth == 0                                         // расчитать ширину
       nWidth := aRect[3]
    EndIf
    
    If nHeight < 0                                         // высота уменьшения
       nHgt    := nHeight
       nHeight := 0
    EndIf
    
    If nHeight == 0                                        // расчитать высоту
       nHeight := aRect[4] - nRow
    EndIf
    
    If nHgt < 0; nHeight += nHgt                           // уменьшить высоту
    EndIf
    
    If nWdt < 0; nWidth  += nWdt                           // уменьшить ширину
    EndIf
    
    oBrw := _DefineTBrowse( ControlName,   ;
                            ParentForm,    ;
                            nCol,          ;
                            nRow,          ;
                            nWidth,        ;
                            nHeight,       ;
                            aHeaders,      ;
                            aWidths,       ;
                            bFields,       ;
                            value,         ;
                            fontname,      ;
                            fontsize,      ;
                            tooltip,       ;
                            change,        ;
                            bDblclick,     ;
                            aHeadClick,    ;
                            gotfocus,      ;
                            lostfocus,     ;
                            uAlias,        ;
                            Delete,        ;
                            lNogrid,       ;
                            aImages,       ;
                            aJust,         ;
                            HelpId,        ;
                            bold,          ;
                            italic,        ;
                            underline,     ;
                            strikeout,     ;
                            break,         ;
                            backcolor,     ;
                            fontcolor,     ;
                            lock,          ;
                            lCell,         ;
                            nStyle,        ;
                            appendable,    ;
                            readonly,      ;
                            valid,         ;
                            validmessages, ;
                            aColors,       ;
                            uWhen,         ;
                            nId,           ;
                            aFlds,         ;
                            cMsg,          ;
                            lRePaint,      ;
                            lEnum,         ;
                            lAutoSearch,   ;
                            uUserSearch,   ;
                            lAutoFilter,   ;
                            uUserFilter,   ;
                            aPicture,      ;
                            lTransparent,  ;
                            uSelector,     ;
                            lEditable,     ;
                            lAutoCol,      ;
                            aColSel )
    
    oBrw:nClrLine    := COLOR_GRID
    oBrw:nWheelLines := 1
    oBrw:lNoHScroll  := .T.
    oBrw:lNoMoveCols := .T.
    oBrw:lNoLiteBar  := .F.
    oBrw:lNoResetPos := .F.
    oBrw:lPickerMode := .F.              // usual date format
    oBrw:nFireKey    := VK_F4            // set key VK_F4, default is VK_F2

Return oBrw

////////////////////////////////////////////////////////////
Function TBrw_Show( oBrw, nDelta )   

   _EndTBrowse()

   If hb_IsObject(oBrw)
      TBrw_NoHoles( oBrw, nDelta )
      oBrw:nHeightHead -= 1
   EndIf

   Return Nil

////////////////////////////////////////////////////////////
Function TBrw_Obj( cTbrw, cForm )          
   Local oBrw, i

   Default cForm := _HMG_ThisFormName

   If ( i := GetControlIndex(cTBrw, cForm) ) > 0
      oBrw:= _HMG_aControlIds [ i ]
   EndIf

   Return oBrw

////////////////////////////////////////////////////////////
Function TBrw_NoHoles( oBrw, nDelta, lSet ) 
   Local nI, nK, nHeight, nHole

   DEFAULT nDelta := 1, lSet := .T.
    
   nHole := oBrw:nHeight - oBrw:nHeightHead - oBrw:nHeightSuper - ; 
            oBrw:nHeightFoot - oBrw:nHeightSpecHd - ;
            If( oBrw:lNoHScroll, 0, GetHScrollBarHeight() ) 

   nHole   -= ( Int( nHole / oBrw:nHeightCell ) * oBrw:nHeightCell )
   nHole   -= nDelta
   nHeight := nHole

   If lSet

       nI := If( oBrw:nHeightSuper  > 0, 1, 0 ) + ;
             If( oBrw:nHeightHead   > 0, 1, 0 ) + ;
             If( oBrw:nHeightSpecHd > 0, 1, 0 ) + ;
             If( oBrw:nHeightFoot   > 0, 1, 0 )
             
       If nI > 0                          // есть заголовки
      
          nK := int( nHole / nI )         // на nI - заголовки разделим дырку
      
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
      
       Else             // нет заголовков, можно уменьшить размер tsb на размер nHole
      
          SetProperty(oBrw:cParentWnd, oBrw:cControlName, "Height", ;
          GetProperty(oBrw:cParentWnd, oBrw:cControlName, "Height") - nHole)
      
       EndIf
      
       oBrw:Display()

   EndIf

   Return nHeight
