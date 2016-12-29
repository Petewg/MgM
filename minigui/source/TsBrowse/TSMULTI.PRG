#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

#define EM_GETSEL           176
#define EN_CHANGE           768    // 0x0300
#define EN_UPDATE           1024   // 0x0400

* ============================================================================
* CLASS TSMulti  Version 7.0 Jul/15/2004
* ============================================================================

CLASS TSMulti FROM TControl

   CLASSDATA lRegistered AS LOGICAL
   DATA  Atx, lAppend , lChanged
   DATA  nPos
   Method New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, hFont,;
      nClrFore, nClrBack, cControl, cWnd )

   METHOD Default( )
   METHOD HandleEvent( nMsg, nWParam, nLParam )
   METHOD GetDlgCode( nLastKey, nFlags )
   Method KeyChar( nKey, nFlags )
   Method KeyDown( nKey, nFlags )
   Method LostFocus( hCtlFocus )
   Method lValid()
   METHOD Command( nWParam, nLParam )

ENDCLASS

* ============================================================================
* METHOD TSMulti:New() Version 7.0 Jul/15/2004
* ============================================================================

METHOD New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, hFont,;
             nClrFore, nClrBack,  cControl, cWnd ) CLASS TSMulti

   DEFAULT nClrFore  := GetSysColor( COLOR_WINDOWTEXT ),;
           nClrBack  := GetSysColor( COLOR_WINDOW ),;
           nHeight   := 12

   ::nTop         := nRow
   ::nLeft        := nCol
   ::nBottom      := ::nTop + nHeight - 1
   ::nRight       := ::nLeft + nWidth - 1
   if oWnd == Nil
      oWnd        := Self
      oWnd:hWnd   := GetFormHandle (cWnd)
   endif
   ::oWnd         := oWnd
   IF _HMG_BeginWindowMDIActive
      cWnd := _GetWindowProperty ( GetActiveMdiHandle(), "PROP_FORMNAME" )
   endif

   ::nId          := ::GetNewId()
   ::nStyle       := nOR( ES_MULTILINE, ES_WANTRETURN , WS_CHILD, WS_BORDER,;
                         WS_THICKFRAME ,WS_VSCROLL , WS_HSCROLL)

   ::cControlName := cControl
   ::cParentWnd   := cWnd
   ::hWndParent   := oWnd:hWnd
   ::bSetGet      := bSetGet
   ::lCaptured    := .f.
   ::hFont        := hFont
   ::lFocused     := .F.
   ::lAppend      := .F.
   ::nLastKey     := 0
   ::lChanged     :=.f.

   ::SetColor( nClrFore, nClrBack )

   ::nTop     = nRow
   ::nLeft    = nCol
   ::nBottom  = ::nTop + nHeight - 1
   ::nRight   = ::nLeft + nWidth - 1
   ::Atx      = 0

   if ! Empty( ::oWnd:hWnd )

      ::Create( "EDIT" )
      ::AddVars( ::hWnd )
      ::Default()

      if hFont != nil
         ::hFont := hFont
      endif
      oWnd:AddControl( ::hWnd )
   endif

Return Self

* ============================================================================
* METHOD TSMulti:Default() Version 7.0 Jul/15/2004
* ============================================================================
METHOD Default() CLASS TSMulti

   LOCAL Value := Eval( ::bSetGet )

   If !Empty (Value)
      SetWindowText ( ::hWnd , Value )
   endif

Return NIL

* ============================================================================
* METHOD TSMulti:HandleEvent() Version 7.0 Jul/15/2004
* ============================================================================

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TSMulti

Return ::Super:HandleEvent( nMsg, nWParam, nLParam )

* ============================================================================
* METHOD TSMulti:GetDlgCode() Version 7.0 Jul/15/2004
* ============================================================================

METHOD GetDlgCode( nLastKey, nFlags ) CLASS TSMulti

   HB_SYMBOL_UNUSED( nFlags )
   ::nLastKey := nLastKey

RETURN DLGC_WANTALLKEYS + DLGC_WANTCHARS

* ============================================================================
* METHOD TSMulti:KeyChar() Version 7.0 Jul/15/2004
* ============================================================================

METHOD KeyChar( nKey, nFlags ) CLASS TSMulti

   HB_SYMBOL_UNUSED( nFlags )

   If _GetKeyState( VK_CONTROL )
      nKey := If( Upper( Chr( nKey ) ) == "W" .or. nKey == VK_RETURN, VK_TAB, nKey )
   EndIf

   If nKey == VK_TAB .or. nKey == VK_ESCAPE
      Return 0
   Endif

RETURN ::Super:KeyChar( nKey, nFlags )

* ============================================================================
* METHOD TSMulti:KeyDown() Version 7.0 Jul/15/2004
* ============================================================================

METHOD KeyDown( nKey, nFlags ) CLASS TSMulti

   If _GetKeyState( VK_CONTROL )
      nKey := If( Upper( Chr( nKey ) ) == "W" .or. nKey == VK_RETURN, VK_TAB, nKey )
   EndIf

   ::nLastKey := nKey

   If nKey == VK_TAB .or. nKey == VK_ESCAPE

      If ::lValid()

         If nKey != VK_ESCAPE
            If ::bSetGet != Nil
               Eval( ::bSetGet, GetWindowText( ::hWnd ) )
            EndIf
         EndIf

         ::bLostFocus := Nil
         Eval( ::bKeyDown, nKey, nFlags, .T. )

      EndIf

   Endif

RETURN 0

* ============================================================================
* METHOD TSMulti:lValid() Version 7.0 Jul/15/2004
* ============================================================================

METHOD lValid() CLASS TSMulti

   Local lRet := .T.

   If ValType( ::bValid ) == "B"
      lRet := Eval( ::bValid, ::GetText() )
   EndIf

Return lRet

* ============================================================================
* METHOD TSMulti:LostFocus() Version 7.0 Jul/15/2004
* ============================================================================

METHOD LostFocus( hCtlFocus ) CLASS TSMulti

   ::lFocused := .F.

   ::nPos := LoWord( ::SendMsg( EM_GETSEL ) )
   If ::bLostFocus != Nil
      Eval( ::bLostFocus, ::nLastKey, hCtlFocus )
   EndIf

Return 0

* ============================================================================
* METHOD TSMulti:Command() Version 7.0 Jul/15/2004
* ============================================================================

METHOD Command( nWParam, nLParam ) CLASS TSMulti

   local nNotifyCode, hWndCtl

   nNotifyCode := HiWord( nWParam )
//   nID         := LoWord( nWParam )
   hWndCtl     := nLParam

   do case
   case hWndCtl == 0

      * Enter ..........................................
      if HiWord(nWParam) == 0 .And. LoWord(nWParam) == 1
         ::KeyDown( VK_RETURN, 0 )
      EndIf

      * Escape .........................................
      if HiWord(nwParam) == 0 .And. LoWord(nwParam) == 2
         ::KeyDown( VK_ESCAPE, 0 )
      endif

   case hWndCtl != 0

      do case
         case nNotifyCode == EN_CHANGE
           ::lChanged := .T.
         case nNotifyCode == EN_KILLFOCUS
           ::LostFocus()
         case nNotifyCode == EN_UPDATE
           If _GetKeyState( VK_ESCAPE )
              ::KeyDown( VK_ESCAPE, 0 )
           Endif
           If _GetKeyState( VK_CONTROL )
              IF GetKeyState(VK_RETURN) == -127 .or._GetKeyState( VK_RETURN )
                 ::KeyDown( VK_RETURN, 0 )
              Endif
           endif
      endcase

   endcase

Return nil
