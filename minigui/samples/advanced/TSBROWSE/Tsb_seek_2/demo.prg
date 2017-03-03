/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Tsbrowse sample
 *
*/

#include "minigui.ch"
#include "tsbrowse.ch"

REQUEST DBFCDX

*-----------------------------------
PROCEDURE Main
*-----------------------------------
   LOCAL cB, nY, nX, nW, nH
   LOCAL cBrw := "MyBase"          // TBrowse control name
   LOCAL oBrw, cForm, lCell := .T.
   LOCAL nRow, nCol, cAlias

   SET EXACT    ON
   SET CENTURY  ON
   SET EPOCH    TO ( Year(Date()) - 50 )
   SET DATE     TO GERMAN

   RDDSETDEFAULT('DBFCDX')

   SET AUTOPEN   ON
   SET EXCLUSIVE ON
   SET SOFTSEEK  ON
   SET DELETED   ON

   SET TOOLTIP BALLOON ON

   Use EMPLOYEE Via "DBFCDX" Alias BASE Shared New

   if ! File('EMPLOYEE.cdx')
      INDEX ON Upper(FIELD->FIRST) TAG Name
   endif

   If OrdCount() > 0
      OrdSetFocus(1)
   EndIf

   cAlias := Alias()

   DEFINE WINDOW win_1 AT 0, 0 WIDTH 1200 HEIGHT 700 ;
      MAIN TITLE "TSBrowse Incremental Seek With Footer's GetBox Demo" NOMAXIMIZE NOSIZE

         cForm := This.Name
         nRow  := 5
         nCol  := 10
         
       //-------------------Define user toolbar buttons------------------------------//
         nY := nRow
         nX := nCol
         nW := 24
         nH := 24

         cB := "ttop"
       @ nY, nX  BUTTON &cB  PICTURE "First"     TOOLTIP "First record"     ;
                 ACTION ( oMyBase():GoTop(), oMyBase():SetFocus() ) ;
                 WIDTH  nW HEIGHT nH  NOTABSTOP
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "prev"
       @ nY, nX  BUTTON &cB  PICTURE "prior"     TOOLTIP "Prior record"  ;
                 ACTION ( oMyBase():GoUp(), oMyBase():SetFocus() ) ;
                 WIDTH  nW HEIGHT nH
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "nnext"
       @ nY, nX  BUTTON &cB  PICTURE "next"      TOOLTIP "Next record"  ;
                 ACTION ( oMyBase():GoDown(), oMyBase():SetFocus() ) ;
                 WIDTH  nW HEIGHT nH
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "bott"
       @ nY, nX  BUTTON &cB  PICTURE "Last"      TOOLTIP "Last record"  ;
                 ACTION ( oMyBase():GoBottom(), oMyBase():SetFocus() ) ;
                 WIDTH  nW HEIGHT nH
         nX += GetWindowWidth(GetControlHandle(cB, cForm)) + nCol * 3

         cB := "delRec"
       @ nY, nX  BUTTON &cB  PICTURE "Delete"    TOOLTIP "Delete a record. Hotkey F3"     ;
                 ACTION ( oMyBase():PostMsg(WM_KEYDOWN, VK_F3, 0) )      ;
                 WIDTH  nW HEIGHT nH
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "readRec"
       @ nY, nX  BUTTON &cB  PICTURE  "editNo"   TOOLTIP "Editing. Hotkey Enter" ;
                 ACTION ( oMyBase():PostMsg(WM_KEYDOWN, VK_RETURN, 0) )     ;
                 WIDTH  nW HEIGHT nH
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "BRUN"
       @ nY, nX  BUTTON &cB  PICTURE  "addrec"   TOOLTIP "Add a record. Hotkey F2"  ;
                 ACTION ( oMyBase():PostMsg(WM_KEYDOWN, VK_F2, 0) )   ;
                 WIDTH  nW HEIGHT nH
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "readRecN"
       @ nY, nX  BUTTON &cB  PICTURE  "edit"     TOOLTIP "Information about a pressed button"   ;
                 ACTION BtnMsg()                 WIDTH nW HEIGHT nH
         nY += GetWindowHeight(GetControlHandle(cB, cForm))
       //----------------------------------------------------------------------------//

       DEFINE STATUSBAR 
          STATUSITEM ' ' 
       END STATUSBAR

       //-------------------------Define TBrowse control-----------------------------//

         nY += nRow
         nX := 2
         nW := -( nX * 2 )
         nH := -( nRow + GetWindowHeight( GetControlHandle("StatusBar", cForm) ) )
 
         oBrw := TBrw_Create(cBrw, cForm, nY, nX, nW, nH, cAlias, lCell)  // DEFINE TBROWSE ...

         ADD COLUMN TO oBrw HEADER "Name" FOOTER ""  SIZE 600 ;
            DATA FieldWBlock( "FIRST", Select( "base" ) ) EDITABLE
        
         ADD COLUMN TO oBrw HEADER "SOCR" FOOTER ""  SIZE 350 ;
            DATA FieldWBlock( "LAST", Select( "base" ) ) EDITABLE

         ADD COLUMN TO oBrw HEADER "CODE" FOOTER ""  SIZE 210 ;
            DATA FieldWBlock( "STREET", Select( "base" ) ) EDITABLE

         If lCell
            oBrw:SetColor( { CLR_FOCUSB }, { { |nAt,nNr,oBr| nAt := Nil, ;
                          If( oBr:nCell == nNr, RGB(166, 202, 240), RGB(220, 220, 220) ) } } )
         EndIf

         AEval( oBrw:aColumns, {|oCol| oCol:lFixLite := .T. } )
            
         oBrw:nHeightCell  += 6
         oBrw:nHeightHead  += 14
         oBrw:nHeightFoot  := oBrw:nHeightCell
         oBrw:lDrawFooters := .T.

                      // lOnOff, lConfirm, bDelete, bPostDel)
         oBrw:SetDeleteMode(.T.,    .T.  ,        ,         )       // delete mode

         oBrw:bUserKeys := {|nKey,nFlg,oBrw| UserKeys(nKey, nFlg, oBrw) }
         
         TBrw_Show(oBrw)                                            // END TBROWSE

       //-------------------------Define GetBox for seeking--------------------------//

       @ 0, 0 GETBOX MyFind HEIGHT 10 WIDTH 10 VALUE ""  ;
              ON LOSTFOCUS ( win_1.MyFind.Hide, win_1.&(cBrw).SetFocus ) ;
              ON CHANGE    ( oMyBase():PostMsg(WM_KEYDOWN, VK_F20, 0) ) ;
              INVISIBLE
       //----------------------------------------------------------------------------//

         oBrw:SetFocus()
         
   END WINDOW

   CENTER   WINDOW &cForm
   ACTIVATE WINDOW &cForm

RETURN

*-----------------------------------
Static Function oMyBase( cForm )          // Get Tbrowse object
*-----------------------------------
Return TBrw_Obj("MyBase", cForm)

*-----------------------------------
Static Procedure BtnMsg()
*-----------------------------------
Local cEvent  := _HMG_ThisEventType       
Local cForm   := _HMG_ThisFormName   
Local nForm   := _HMG_ThisFormIndex  
Local cType   := _HMG_ThisType            // "W" - window, "C" - control
Local nIndex  := _HMG_ThisIndex      
Local cName   := _HMG_ThisControlName
Local oBrw    := oMyBase()
Local cTx     := ""

  cTx += '_HMG_ThisEventType   ' + _HMG_ThisEventType            + CRLF
  cTx += '_HMG_ThisFormName    ' + _HMG_ThisFormName             + CRLF
  cTx += '_HMG_ThisFormIndex   ' + hb_ntos( _HMG_ThisFormIndex ) + CRLF
  cTx += '_HMG_ThisType        ' + _HMG_ThisType                 + CRLF   
  cTx += '_HMG_ThisControlName ' + _HMG_ThisControlName          + CRLF
  cTx += '_HMG_ThisIndex       ' + hb_ntos( _HMG_ThisIndex )     + CRLF
  cTx += 'TBrowse Name         ' + oBrw:cControlName

  MsgBox(cTx, ProcName())

  oBrw:SetFocus()

Return

*-----------------------------------
STATIC FUNCTION UserKeys( nKey, nFlag, oBrw )
*-----------------------------------
Local nRec, oCell, cVal, nRow, uRet, cKey

  nFlag := Nil

  If     nKey == VK_F1
  ElseIf nKey == VK_F2

     (oBrw:cAlias)->( DbAppend(.T.) ) 

     If ! (oBrw:cAlias)->( NetErr() )
        nRec := (oBrw:cAlias)->( RecNo() )
        (oBrw:cAlias)->( Rlock() )
        (oBrw:cAlias)->( FieldPut( 1, ProcName()+": "+strzero(nRec, 7) ) ) 
        (oBrw:cAlias)->( FieldPut( 2, ProcName()+": "+str(ProcLine(), 7) ) ) 
        (oBrw:cAlias)->( FieldPut( 3, ProcName()+": "+str(ProcLine(), 7) ) ) 
        (oBrw:cAlias)->( DbUnlock() )
        oBrw:GoToRec( nRec ) 
     EndIf

     oBrw:SetFocus()
     uRet := .F.

  ElseIf nKey == VK_F3

     oBrw:DeleteRow()
     oBrw:SetFocus()
     uRet := .F.

  ElseIf nKey == VK_F4
  ElseIf nKey == VK_F5
  ElseIf nKey == VK_F6
  ElseIf nKey == VK_F7
  ElseIf nKey == VK_F8
  ElseIf nKey == VK_F9
  ElseIf nKey == VK_F11
  ElseIf nKey == VK_F12

  ElseIf nKey == VK_F20             // on change getbox MyFind

     cVal := win_1.MyFind.Value
     If ! empty(cVal)
        (oBrw:cAlias)->( dbSeek(Upper(Trim(cVal))) )
        oBrw:GotoRec( (oBrw:cAlias)->( RecNo()) )
     EndIf
     uRet := .F.

  ElseIf nKey >= 32 .and. nKey < 254

     cKey := KeyToChar(nKey)

     If ! Empty(cKey)

        oCell  := oBrw:GetCellInfo(1, 1)
        nRow   := oBrw:nHeight + oBrw:nTop - oBrw:nHeightFoot
        win_1.MyFind.Row    := nRow 
        win_1.MyFind.Col    := oCell:nCol
        win_1.MyFind.Width  := oCell:nWidth
        win_1.MyFind.Height := oBrw:nHeightFoot
        win_1.MyFind.Show()
        win_1.MyFind.SetFocus()
        win_1.MyFind.Value  := Space(10) 
   
        _PushKey(nKey)
   
        uRet := .F.       // key's proccesing finish (nil - continue tsb)

     EndIf

  EndIf

Return uRet

//----------------------------------------------------------------------------//

Function TBrw_Create( ControlName, ParentForm, nRow, nCol, nWidth, nHeight, uAlias, lCell, FontName, FontSize )
    Local oBrw, nHgt := 0, nWdt := 0, hWnd, aRect := {0,0,0,0}
    Local aImages, aHeaders, aWidths, bFields, Value := 1
    Local tooltip, change, bDblclick, aHeadClick, gotfocus, lostfocus
    Local Delete := .F., lNogrid := .F., aJust, HelpId
    Local bold := .F., italic := .F., underline := .F., strikeout := .F.
    Local break := .F., backcolor, fontcolor
    Local lock := .F., nStyle, appendable := .F., readonly
    Local valid, validmessages, aColors, uWhen, nId, aFlds, cMsg
    Local lRePaint := .T., lEnum := .F., lAutoSearch := .F., uUserSearch
    Local lAutoFilter := .F., uUserFilter, aPicture, lTransparent := .F.
    Local uSelector, lAutoCol := .F., aColSel, lEditable := .F.

    Default nRow       := 0,                    ;
            nCol       := 0,                    ;
            nWidth     := 0,                    ;
            nHeight    := 0,                    ;
            lCell      := .T.,                  ;
            ParentForm := _HMG_ThisFormName,    ;
            FontName   := _HMG_DefaultFontName, ;
            FontSize   := _HMG_DefaultFontSize

    hWnd := GetFormHandle(ParentForm)

    GetClientRect(hWnd, aRect)
    
    If nWidth  < 0                                         // ширина уменьшени€
       nWdt   := nWidth
       nWidth := 0
    EndIf
    
    If nWidth == 0                                         // расчитать ширину
       nWidth := aRect[3]
    EndIf
    
    If nHeight < 0                                         // высота уменьшени€
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

*-----------------------------------
Function TBrw_Show( oBrw, nDelta )   
*-----------------------------------

   _EndTBrowse()

   If hb_IsObject(oBrw)
      TBrw_NoHoles( oBrw, nDelta )
      oBrw:nHeightHead -= 1
   EndIf

Return Nil

*-----------------------------------
Function TBrw_Obj( cTbrw, cForm )          
*-----------------------------------
   Local oBrw, i

   Default cForm := _HMG_ThisFormName

   If ( i := GetControlIndex(cTBrw, cForm) ) > 0
      oBrw:= _HMG_aControlIds [ i ]
   EndIf

Return oBrw

*-----------------------------------
Function TBrw_NoHoles( oBrw, nDelta, lSet ) 
*-----------------------------------
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

//----------------------------------------------------------------------------//

*-----------------------------------
Function KeyToChar( nVirtKey )
*-----------------------------------
   LOCAL i, cRetChar := ""
   LOCAL nKeyboardMode := GetKeyboardMode()
   LOCAL lShift := CheckBit( GetKeyState( 16 ), 32768 )
   LOCAL aKeysNumPad := { 96,97,98,99,100,101,102,103,104,105,106,107,109,110,111 }
   LOCAL cKeysNumPad := "0123456789*+-./"
   LOCAL aKeys1 := { 192,189,187,219,221,220,186,222,188,190,191 }
   LOCAL cKeys1US := "`-=[]\;',./"
   LOCAL cKeys1ShiftUS := '~_+{}|:"<>?'
   LOCAL cKeys1RU := "®-=’Џ\∆ЁЅё."
   LOCAL cKeys1ShiftRU := "®_+’Џ/∆ЁЅё,"
   LOCAL cKeys2US := "1234567890QWERTYUIOPASDFGHJKLZXCVBNM "
   LOCAL cKeys2ShiftUS := "!@#$%^&*()QWERTYUIOPASDFGHJKLZXCVBNM "
   LOCAL cKeys2RU := "1234567890…÷” ≈Ќ√Ўў«‘џ¬јѕ–ќЋƒя„—ћ»“№ "
   LOCAL cKeys2ShiftRU := '!"є;%:?*()…÷” ≈Ќ√Ўў«‘џ¬јѕ–ќЋƒя„—ћ»“№ '

   i := ascan( aKeysNumPad, nVirtKey )
   if i > 0
      RETURN substr( cKeysNumPad, i, 1 )
   endif

   i := ascan( aKeys1, nVirtKey )
   if i > 0
      if nKeyboardMode == 1033 // US
         if lShift
            cRetChar := substr( cKeys1ShiftUS, i, 1 )
         else
            cRetChar := substr( cKeys1US, i, 1 )
         endif
      elseif nKeyboardMode == 1049 // RU
         if lShift
            cRetChar := substr( cKeys1ShiftRU, i, 1 )
         else
            cRetChar := substr( cKeys1RU, i, 1 )
         endif
      endif
      RETURN cRetChar
   endif

   i := at( chr( nVirtKey ), cKeys2US )
   if i > 0
      if nKeyboardMode == 1033 // US
         if lShift
            cRetChar := substr( cKeys2ShiftUS, i, 1 )
         else
            cRetChar := substr( cKeys2US, i, 1 )
         endif
      elseif nKeyboardMode == 1049 // RU
         if lShift
            cRetChar := substr( cKeys2ShiftRU, i, 1 )
         else
            cRetChar := substr( cKeys2RU, i, 1 )
         endif
      endif
   endif

RETURN cRetChar


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( GETKEYBOARDMODE )
{
	HKL kbl;
	HWND CurApp;
	DWORD idthd;
	int newmode;

	CurApp  = GetForegroundWindow();
	idthd   = GetWindowThreadProcessId(CurApp, NULL);
	kbl     = GetKeyboardLayout(idthd);
	newmode = (int) LOWORD(kbl);

	hb_retnl(newmode);
}

#pragma ENDDUMP
