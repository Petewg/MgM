#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

* ============================================================================
* CLASS TGetBox  Driver for GetBox  TSBrowse 7.0
* ============================================================================

CLASS TGetBox FROM TControl

   DATA Atx, lAppend, oGet

   METHOD New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, cPict, bValid,;
               nClrFore, nClrBack, hFont, cControl, cWnd, cMsg,;
               lUpdate, bWhen, lCenter, lRight, bChanged,;
               lNoBorder, nHelpId, lSpinner, bUp, bDown, bMin, bMax )
   METHOD HandleEvent( nMsg, nWParam, nLParam )
   Method KeyChar( nKey, nFlags )
   Method KeyDown( nKey, nFlags )
   Method LostFocus( hCtlFocus )
   Method lValid()
   METHOD VarGet()

ENDCLASS

* ============================================================================
* METHOD TGetBox:New() Version 7.0
* ============================================================================

METHOD New( nRow, nCol, bSetGet, oWnd, nWidth, nHeight, cPict, bValid,;
            nClrFore, nClrBack, hFont, cControl, cWnd, cMsg,;
            lUpdate, bWhen, lCenter, lRight, bChanged,;
            lNoBorder, nHelpId, lSpinner, bUp, bDown, bMin, bMax, lNoMinus ) CLASS TGetBox

   local cText := Space( 50 ), uValue, ix
   local Fontname := _HMG_DefaultFontName
   local FontSize := _HMG_DefaultFontSize
   local ParentFormName
   local invisible := .f.
   local uLostFocus, uGotFocus, uChange:= "", Right := .f., ;
         bold :=.f., italic:= .f., underline := .f., strikeout:= .f., field , ;
         notabstop:=.f., nId, cvalidmessage := "", tooltip := ""
   local aFontColor, aBackColor
   local ReadOnly := .f., lPassword := .F.

   DEFAULT nClrFore  := GetSysColor( COLOR_WINDOWTEXT ),;
           nClrBack  := GetSysColor( COLOR_WINDOW ),;
           lUpdate   := .f.,;
           lCenter   := .f., lRight := .f.,;
           lSpinner  := .f.,;
           lNoBorder := .f.,;
           bSetGet   := bSETGET( cText )

   HB_SYMBOL_UNUSED( bUp )
   HB_SYMBOL_UNUSED( bDown )
   HB_SYMBOL_UNUSED( bMin )
   HB_SYMBOL_UNUSED( bMax )

   ::nTop          := nRow
   ::nLeft         := nCol
   ::nBottom       := ::nTop + nHeight - 1
   ::nRight        := ::nLeft + nWidth - 1
   if oWnd == Nil
       oWnd        := Self
       oWnd:hWnd   := GetFormHandle (cWnd)
   endif
   ::oWnd          := oWnd
   ::nId           := ::GetNewId()
   ::cControlName  := cControl
   ::cParentWnd    := cWnd
   ::bSetGet       := bSetGet
   ::bValid        := bValid
   ::lCaptured     := .f.
   ::hFont         := hFont
   ::cMsg          := cMsg
   ::lUpdate       := lUpdate
   ::bWhen         := bWhen
   ::bChange       := bChanged
   ::lFocused      := .f.
   ::nHelpId       := nHelpId

   ::SetColor( nClrFore, nClrBack )
   nId := ::nId
   if oWnd == Nil
       oWnd        := GetFormHandle (cWnd)     //JP
   endif
   ParentFormName  := oWnd:cParentWnd
   uValue          := Eval( bSetGet )
   aFontColor      := { GetRed ( nClrFore ) , GetGreen ( nClrFore ) , GetBlue ( nClrFore ) }
   aBackColor      := { GetRed ( nClrBack ) , GetGreen ( nClrBack ) , GetBlue ( nClrBack ) }
   uLostFocus      := ::LostFocus()
   uGotFocus       := ::GotFocus()
   if ValType( cPict ) == "B" 
      cPict := Eval( cPict ) 
   endif

   if ! Empty( ::oWnd:hWnd )

      _DefineGetBox ( cControl, ParentFormName, nCol, nRow, nWidth, nHeight, uValue, ;
         FontName, FontSize, ToolTip, lPassword, uLostFocus, uGotFocus, uChange, right, ;
         nHelpId, readonly, bold, italic, underline, strikeout, field, aBackColor, aFontColor, ;
         invisible, notabstop, nId, bvalid, cPict, cMsg, cvalidmessage, bWhen ,,,,, lNoMinus )

      ix := GetControlIndex ( cControl, ParentFormName )
      ::Atx  := ix
      ::hWnd :=_HMG_aControlHandles [ix]

      ::AddVars( ::hWnd )

      if GetObjectType( hFont ) == OBJ_FONT
         _SetFontHandle( ::hWnd, hFont )
         ::hFont := hFont
      endif

      oWnd:AddControl( ::hWnd )

   endif

return Self

* ============================================================================
* METHOD TGetBox:HandleEvent() Version 7.0 Jul/15/2004
* ============================================================================

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TGetBox

   // just used for some testings
   /* fDebug( "nMsg="+AllTrim(cValTochar(nMsg))+" nWParam="+;
           AllTrim(cValTochar(nWParam))+;
           " nLoWord="+AllTrim(cValTochar(nLoWord(nLParam)))+;
           " nHiWord="+AllTrim(cValTochar(nHiWord(nLParam)))+CRLF+;
           " ProcName="+ProcName(2)+Space(1)+LTrim(Str(ProcLine(2)))+space(1)+;
           ProcName(3)+Space(1)+LTrim(Str(Procline(3))) ) */

Return ::Super:HandleEvent( nMsg, nWParam, nLParam )

* ============================================================================
* METHOD TGetBox:KeyChar() Version 7.0 Jul/15/2004
* ============================================================================

METHOD KeyChar( nKey, nFlags ) CLASS TGetBox

   If _GetKeyState( VK_CONTROL )
      nKey := If( Upper( Chr( nKey ) ) == "W" .or. nKey == VK_RETURN, VK_TAB, nKey )
   EndIf

   If nKey == VK_TAB .or. nKey == VK_ESCAPE
      Return 0
   Endif

RETURN ::Super:KeyChar( nKey, nFlags )

* ============================================================================
* METHOD TGetBox:KeyDown() Version 7.0 Jul/15/2004
* ============================================================================

METHOD KeyDown( nKey, nFlags ) CLASS TGetBox

   ::nLastKey := nKey

   If nKey == VK_TAB .or. nKey == VK_RETURN .or. nKey == VK_ESCAPE
      ::bLostFocus := Nil
      Eval( ::bKeyDown, nKey, nFlags, .T. )
   Endif

RETURN 0

* ============================================================================
* METHOD TGetBox:lValid() Version 7.0 Jul/15/2004
* ============================================================================

METHOD lValid() CLASS TGetBox

   Local lRet := .t.

   If ValType( ::bValid ) == "B"
      lRet := Eval( ::bValid, ::GetText() )
   EndIf

Return lRet

* ============================================================================
* METHOD TGetBox:LostFocus() Version 7.0 Jul/15/2004
* ============================================================================

METHOD LostFocus( hCtlFocus ) CLASS TGetBox

   ::lFocused := .F.

   If ::bLostFocus != Nil
      Eval( ::bLostFocus, ::nLastKey, hCtlFocus )
   EndIf

Return 0

* ============================================================================
* METHOD TGetBox:VarGet() Version 7.0 Jul/15/2004
* ============================================================================

METHOD VarGet() CLASS TGetBox

RETURN _GetValue( ::cControlName, ::oWnd:cParentWnd )
