#ifdef __XHARBOUR__
#define __SYSDATA__
#endif
#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

#define DTS_UPDOWN          0x0001 // use UPDOWN instead of MONTHCAL
#define DTS_SHOWNONE        0x0002 // allow a NONE selection
#define NM_KILLFOCUS   (-8)

* ============================================================================
* CLASS TDatePicker  Driver for DatePicker  TSBrowse 7.0
* ============================================================================

CLASS TDatePicker FROM TControl

   CLASSDATA lRegistered AS LOGICAL
   DATA Atx, lAppend

   METHOD New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, cPict, bValid,;
      nClrFore, nClrBack, hFont, cControl, oCursor, cWnd, cMsg,;
      lUpdate, bWhen, lCenter, lRight, bChanged,;
      lNoBorder, nHelpId, shownone )

   METHOD Default()
   METHOD HandleEvent( nMsg, nWParam, nLParam )
   METHOD KeyChar( nKey, nFlags )
   METHOD KeyDown( nKey, nFlags )
   METHOD LostFocus()
   METHOD lValid()
   METHOD VarGet()

ENDCLASS

* ============================================================================
* METHOD TDatePicker:New() Version 7.0
* ============================================================================

METHOD New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, cPict, bValid,;
            nClrFore, nClrBack, hFont, cControl, oCursor, cWnd, cMsg,;
            lUpdate, bWhen, lCenter, lRight, bChanged,;
            lNoBorder, nHelpId, shownone ) CLASS TDatePicker

   Local updown      := .T.
   Local invisible   := .F.
   Local rightalign  := .F.
   Local notabstop   := .F.

   DEFAULT nClrFore  := GetSysColor( COLOR_WINDOWTEXT ),;
           nClrBack  := GetSysColor( COLOR_WINDOW ),;
           nHeight   := 12 ,;
           lUpdate   := .F.,;
           lNoBorder := .F.,;
           shownone  := .F.

   HB_SYMBOL_UNUSED( cPict )
   HB_SYMBOL_UNUSED( lCenter )
   HB_SYMBOL_UNUSED( lRight )

   ::nTop         := nRow
   ::nLeft        := nCol
   ::nBottom      := ::nTop + nHeight - 1
   ::nRight       := ::nLeft + nWidth - 1
   if oWnd == Nil
       oWnd := Self
       oWnd:hWnd  := GetFormHandle( cWnd )            //JP
   endif
   ::oWnd         := oWnd

   ::nId          := ::GetNewId()

   ::cControlName := cControl
   ::cParentWnd   := cWnd
   ::nStyle       := nOR( WS_CHILD, WS_VISIBLE, WS_TABSTOP,;
            WS_VSCROLL, WS_BORDER, DTS_UPDOWN, DTS_SHOWNONE )

   ::bSetGet      := bSetGet
   ::bValid       := bValid
   ::lCaptured    := .f.
   ::hFont        := hFont
   ::oCursor      := oCursor
   ::cMsg         := cMsg
   ::lUpdate      := lUpdate
   ::bWhen        := bWhen
   ::bChange      := bChanged
   ::lFocused     := .f.
   ::nHelpId      := nHelpId
   ::cCaption     := "DateTime"
   ::nLastKey     := 0
   ::Atx          := 0
   ::SetColor( nClrFore, nClrBack )

   if oWnd == Nil
       oWnd := GetFormHandle( cWnd )                  //JP
   endif

   if ! Empty( ::oWnd:hWnd )

      ::hWnd := InitDatePick ( ::oWnd:hWnd, 0, nCol, nRow,nWidth, nHeight , '' , 0 , shownone , updown , rightalign, invisible, notabstop )

      ::AddVars( ::hWnd )
      ::Default()

      if GetObjectType( hFont ) == OBJ_FONT
         _SetFontHandle( ::hWnd, hFont )
         ::hFont := hFont
      endif

      oWnd:AddControl( ::hWnd )

   endif

return Self

* ============================================================================
* METHOD TDatePicker:Default()
* ============================================================================

METHOD Default() CLASS TDatePicker

   Local Value

   Value := Eval( ::bSetGet )
   If Empty (Value)
      SetDatePickNull( ::hWnd )
   Else
      SetDatePick( ::hWnd, year(value), month(value), day(value) )
   EndIf

Return NIL

* ============================================================================
* METHOD TDatePicker:HandleEvent()
* ============================================================================

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TDatePicker

   If nMsg == WM_NOTIFY
         IF HiWord( nWParam ) == NM_KILLFOCUS
           ::LostFocus()
         Endif
   EndIf

Return ::Super:HandleEvent( nMsg, nWParam, nLParam )

* ============================================================================
* METHOD TDatePicker:KeyChar() Version 7.0 Jul/15/2004
* ============================================================================

METHOD KeyChar( nKey, nFlags ) CLASS TDatePicker

   If _GetKeyState( VK_CONTROL )
      nKey := If( Upper( Chr( nKey ) ) == "W" .or. nKey == VK_RETURN, VK_TAB, nKey )
   EndIf

   If nKey == VK_TAB .or. nKey == VK_ESCAPE
      Return 0
   Endif

RETURN ::Super:KeyChar( nKey, nFlags )

* ============================================================================
* METHOD TDatePicker:KeyDown()
* ============================================================================

METHOD KeyDown( nKey, nFlags ) CLASS TDatePicker

   ::nLastKey := nKey

   If nKey == VK_TAB .or. nKey == VK_RETURN .or. nKey == VK_ESCAPE
      ::bLostFocus := Nil
      Eval( ::bKeyDown, nKey, nFlags, .T. )
   Endif

RETURN 0

* ============================================================================
* METHOD TDatePicker:lValid() Version 7.0 Jul/15/2004
* ============================================================================

METHOD lValid() CLASS TDatePicker

   Local lRet := .T.

   If ValType( ::bValid ) == "B"
      lRet := Eval( ::bValid, ::GetText() )
   EndIf

Return lRet

* ============================================================================
* METHOD TDatePicker:VarGet() Version 7.0 Jul/15/2004
* ============================================================================

METHOD VarGet() CLASS TDatePicker

RETURN hb_Date( GetDatePickYear( ::hWnd ), GetDatePickMonth( ::hWnd ), GetDatePickDay( ::hWnd ) )

* ============================================================================
* METHOD TDatePicker:LostFocus() Version 7.0 Jul/15/2004
* ============================================================================

METHOD LostFocus() CLASS TDatePicker

   Default ::lAppend := .F.

   If ::nLastKey == Nil .and. ::lAppend
      ::SetFocus()
      ::nLastKey := 0
      Return 0
   EndIf

   ::lFocused := .F.

   If ::bLostFocus != Nil
      Eval( ::bLostFocus, ::nLastKey )
   EndIf

Return 0
