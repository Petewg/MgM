#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

#define GWL_WNDPROC        (-4)

#define LTGRAY_BRUSH       1
#define GRAY_BRUSH         2

#define GW_HWNDNEXT        2
#define GW_CHILD           5
#define CW_USEDEFAULT      32768

#define SC_NEXT        61504
#define SC_KEYMENU     61696   // 0xF100

#define DM_GETDEFID  WM_USER

#define CBN_SELCHANGE      1
#define CBN_CLOSEUP        8
#define CBN_KILLFOCUS      4
#define NM_KILLFOCUS       (-8)

MEMVAR _TSB_aControlhWnd, _TSB_aControlObjects, _TSB_aClientMDIhWnd

Static nId := 100

CLASS TControl

   DATA   bSetGet, bChange
   DATA   cCaption
   DATA   nLastRow, nLastCol
   DATA   nAlign AS NUMERIC  // New 1.9 Alignment
   DATA   nStatusItem INIT 1

   DATA   bLClicked                                  // TControl
   DATA   bLDblClick                                 // TControl
   DATA   bRClicked                                  // TControl
   DATA   bWhen                                      // TWindow
   DATA   cMsg                                       // TWindows

   DATA   bMoved, bLButtonUp, bKeyDown, bPainted
   DATA   bMButtonDown, bMButtonUp, bRButtonUp
   DATA   bResized, bValid, bKeyChar, bMMoved
   DATA   bGotFocus, bLostFocus, bDropFiles, bDdeInit, bDdeExecute

   DATA   lFocused      AS LOGICAL                   // TWindow
   DATA   lValidating   AS LOGICAL                   // TWindow
   DATA   lCaptured     AS LOGICAL                   // TControl
   DATA   lUpdate       AS LOGICAL                   // TControl
   DATA   lDesign       AS LOGICAL                   // TControl
   DATA   lVisible      AS LOGICAL                   // TControl
   DATA   lMouseDown    AS LOGICAL                   // TControl
   DATA   lKeepDefaultStatus AS LOGICAL INIT .F.     // TControl

   DATA   nTop                                       // TWindow
   DATA   nLeft                                      // TWindow
   DATA   nBottom                                    // TWindow
   DATA   nRight                                     // TWindow
   DATA   nStyle                                     // TWindow
   DATA   nId                                        // TWindow
   DATA   nClrText                                   // TWindow
   DATA   nClrPane                                   // TWindow
   DATA   nPaintCount                                // TWindow
   DATA   nLastKey                                   // TWindow
   DATA   nHelpId                                    // TWindow
   DATA   nChrHeight                                 // TWindow

   DATA   oWnd          AS OBJECT                    // TWindow
   DATA   oCursor                                    // TWindow
   DATA   hCursor                                    // JP
   DATA   oFont                                      // TWindow
   DATA   hFont                                      // New
   DATA   hBrush                                     // New
   DATA   hWnd , hCtlFocus /*, nOldProc*/            // TWindow
   DATA   cControlName                               // new
   DATA   cParentWnd                                 // new
   DATA   hDc                                        // TWindow
   DATA   cPS                                        // TWindow
   DATA   oVScroll                                   // TWindow
   DATA   oHScroll                                   // TWindow

   DATA   hWndParent                                 // New
   DATA   aControls  INIT {}                         // New
   DATA   oWndlAppendMode INIT .f.                   // New

   CLASSDATA aProperties INIT { "cTitle", "cVarName", "nClrText",;
                                "nClrPane", "nAlign", "nTop", "nLeft",;
                                "nWidth", "nHeight", "Cargo" }

   METHOD AddControl( hControl ) INLINE ;
                        If( ::aControls == nil, ::aControls := {},),;
                        AAdd( ::aControls, hControl ), ::lValidating := .f.

   METHOD AddVars(hControl)

   METHOD Change() VIRTUAL

   METHOD Click() INLINE ::oWnd:AEvalWhen()

   METHOD Init( hDlg )

   METHOD Colors( hDC )

   METHOD CoorsUpdate()                //TWindow

   METHOD Create( cClsName )           //TWindow

   METHOD Default()

   METHOD DelVars(hControl)

   METHOD Display()              VIRTUAL

   METHOD DrawItem( nPStruct )   VIRTUAL

   METHOD End()

   METHOD EraseBkGnd( hDC )

   METHOD FillMeasure()          VIRTUAL

   METHOD ForWhen()

   METHOD GetDlgCode( nLastKey )

   METHOD GetCliRect()                 //TWindow

   METHOD GetRect()

   METHOD GetNewId() INLINE ++nId

   METHOD GotFocus( hCtlLost )

   METHOD GoNextCtrl( hCtrl )

   METHOD GoPrevCtrl( hCtrl )

   METHOD LostFocus(hWndGetFocus)

   METHOD nWidth() INLINE GetWindowWidth( ::hWnd )

   METHOD nHeight() INLINE GetWindowHeight( ::hWnd )

   METHOD HandleEvent( nMsg, nWParam, nLParam )

   METHOD KeyChar( nKey, nFlags )

   METHOD KeyDown( nKey, nFlags )

   METHOD KeyUp( nKey, nFlags ) VIRTUAL

   METHOD KillFocus( hCtlFocus )

   METHOD VarPut( uVal ) INLINE  If( ValType( ::bSetGet ) == "B",;
                                 Eval( ::bSetGet, uVal ), )

   METHOD VarGet() INLINE If( ValType( ::bSetGet ) == "B", Eval( ::bSetGet ), )

   METHOD LButtonDown( nRow, nCol, nKeyFlags )

   METHOD LButtonUp( nRow, nCol, nKeyFlags )

   METHOD MouseMove( nRow, nCol, nKeyFlags )

   METHOD Paint() VIRTUAL

   METHOD SuperKeyDown( nKey, nFlags )

//   METHOD nWidth( nNewWidth ) INLINE GetWindowWidth( ::hWnd, nNewWidth )

   MESSAGE BeginPaint METHOD _BeginPaint()

   METHOD EndPaint() INLINE ::nPaintCount--,;
                     EndPaint( ::hWnd, ::cPS ), ::cPS := nil, ::hDC := nil

   METHOD Register( nClsStyle )            //TWindow

   MESSAGE SetFocus METHOD __SetFocus()   //TWindow

   METHOD RButtonUp( nRow, nCol, nKeyFlags )    //TWindow

   METHOD Capture() INLINE  SetCapture( ::hWnd ) //TWindow

   METHOD GetDC() INLINE ;
       If( ::hDC == nil, ::hDC := GetDC( ::hWnd ),),;
       If( ::nPaintCount == nil, ::nPaintCount := 1, ::nPaintCount++ ), ::hDC

   METHOD ReleaseDC() INLINE  ::nPaintCount--, If( ::nPaintCount == 0,;
                              If( ReleaseDC( ::hWnd, ::hDC ), ::hDC := nil,), )

   METHOD PostMsg( nMsg, nWParam, nLParam ) INLINE ;
               PostMessage( ::hWnd, nMsg, nWParam, nLParam )

   METHOD lValid() INLINE If( ::bValid != nil, Eval( ::bValid ), .t. )

   METHOD SetMsg( cText, lDefault )

   METHOD lWhen() INLINE  If( ::bWhen != nil, Eval( ::bWhen ), .t. )

   METHOD SetColor( nClrFore, nClrBack, hBrush )

   METHOD EndCtrl() BLOCK ;   // It has to be Block
      { | Self, lEnd | If( lEnd := ::lValid(), ::PostMsg( WM_CLOSE ),), lEnd }

   METHOD Hide() INLINE ShowWindow( ::hWnd, SW_HIDE )

   METHOD Show() INLINE  ShowWindow( ::hWnd, SW_SHOWNA )

   METHOD SendMsg( nMsg, nWParam, nLParam ) INLINE SendMessage( ::hWnd, nMsg, nWParam, nLParam )

   METHOD Move( nTop, nLeft, nWidth, nHeight, lRepaint )

   METHOD ReSize( nSizeType, nWidth, nHeight )

   METHOD Command( nWParam, nLParam )

   METHOD Notify( nWParam, nLParam )

   METHOD Refresh( lErase ) INLINE InvalidateRect( ::hWnd,;
                                   If( lErase == NIL .OR. !lErase, 0, 1 ) )

   METHOD nGetChrHeight() INLINE ::hDC := GetDC( ::hWnd ), ;
                          ::nChrHeight := _GetTextHeight( ::hWnd, ::hDC ) //Temp

   METHOD GetText() INLINE GetWindowText( ::hWnd )   //TWindow

   METHOD VScroll( nWParam, nLParam )                //TWindow

ENDCLASS

//----------------------------------------------------------------------------//

METHOD Init( hDlg ) CLASS TControl

   local oRect

   DEFAULT ::lActive := .t., ::lCaptured := .f.

   if( ( ::hWnd := GetDialogItemHandle( hDlg, ::nId ) ) != 0 )    //JP
      oRect     := ::GetRect()

      ::nTop    := iif (::nTop    == nil, oRect:nTop,   ::nTop    )
      ::nLeft   := iif (::nLeft   == nil, oRect:nLeft,  ::nLeft   )
      ::nBottom := iif (::nBottom == nil, oRect:nBottom,::nBottom )
      ::nRight  := iif (::nRight  == nil, oRect:nRight, ::nRight  )

      ::Move (::nTop,::nLeft,::nRight - ::nLeft, ::nBottom - ::nTop)

      If( ::lActive, ::Enable(), ::Disable() )

      ::Link()

      if ::oFont != nil
         ::SetFont( ::oFont )
      else
         ::GetFont()
      endif

   else
        MsgInfo("No Valid Control ID","Error")
   endif

return nil

//----------------------------------------------------------------------------//

METHOD AddVars( hControl ) CLASS TControl

   AADD( _TSB_aControlhWnd,    hControl )
   AADD( _TSB_aControlObjects, Self )
   AADD( _TSB_aClientMDIhWnd, IF( _HMG_BeginWindowMDIActive ,GetActiveMdiHandle(),0) )

Return Nil

//----------------------------------------------------------------------------//

METHOD DelVars( hControl ) CLASS TControl

   local nAt := If( ! Empty( _TSB_aControlhWnd ),;
              AScan( _TSB_aControlhWnd, { | hCtrl | hCtrl == Self:hWnd } ), 0 )

   HB_SYMBOL_UNUSED( hControl )

   if nAt != 0
      ADel(   _TSB_aControlhWnd, nAt )
      ASize(  _TSB_aControlhWnd, Len(  _TSB_aControlhWnd ) - 1 )
      ADel(   _TSB_aControlObjects, nAt )
      ASize(  _TSB_aControlObjects, Len(   _TSB_aControlObjects ) - 1 )
      ADel(   _TSB_aClientMDIhWnd, nAt )
      ASize(  _TSB_aClientMDIhWnd, Len(   _TSB_aClientMDIhWnd ) - 1 )
   endif

Return Nil

//----------------------------------------------------------------------------//

METHOD _BeginPaint() CLASS TControl

   local cPS

   if ::nPaintCount == nil
      ::nPaintCount := 1
   else
      ::nPaintCount++
   endif

   ::hDC = BeginPaint( ::hWnd, @cPS )
   ::cPS = cPS

return nil

//----------------------------------------------------------------------------//

METHOD Colors( hDC ) CLASS TControl

   DEFAULT ::nClrText := GetTextColor( hDC ),;
           ::nClrPane := GetBkColor( hDC ),;
           ::hBrush   := CreateSolidBrush( GetRed( ::nClrPane ), GetGreen( ::nClrPane ), GetBlue( ::nClrPane ) )

   SetTextColor( hDC, ::nClrText )
   SetBkColor( hDC, ::nClrPane )

return ::hBrush

//----------------------------------------------------------------------------//

METHOD CoorsUpdate() CLASS TControl

   local aRect := {0,0,0,0}

   GetWindowRect( ::hWnd, aRect )
/*
   ::nTop    = aRect[ 2 ]
   ::nLeft   = aRect[ 1 ]
   ::nBottom = aRect[ 4 ]
   ::nRight  = aRect[ 3 ]
*/
return nil

//----------------------------------------------------------------------------//

METHOD Create( cClsName )  CLASS TControl

   local xStyle := 0

   DEFAULT cClsName := ::ClassName(), ::cCaption := "",;
           ::nStyle := WS_OVERLAPPEDWINDOW,;
           ::nTop   := 0, ::nLeft := 0, ::nBottom := 10, ::nRight := 10,;
           ::nId    := 0

   if ::hWnd != nil
      ::nStyle := nOr( ::nStyle, WS_CHILD )
   endif

   if ::hBrush == nil
      ::hBrush := CreateSolidBrush( GetRed( ::nClrPane ), GetGreen( ::nClrPane ), GetBlue( ::nClrPane ) )
   endif

   if GetClassInfo( GetInstance(), cClsName ) == nil
       if _HMG_MainClientMDIHandle != 0
           ::lRegistered := Register_Class( cClsName, ::hBrush , _HMG_MainClientMDIHandle )
        else
           ::lRegistered := Register_Class( cClsName, ::hBrush )
        endif
   else
      ::lRegistered := .t.
   endif

   if ::nBottom != CW_USEDEFAULT

     ::hWnd := _CreateWindowEx( xStyle, cClsName, ::cCaption, ::nStyle, ::nLeft, ::nTop,;
                               ::nRight - ::nLeft + 1, ::nBottom - ::nTop + 1, ;
                               ::hWndParent, 0, GetInstance() , ::nId )

   else

     ::hWnd := _CreateWindowEx( xStyle, cClsName, ::cCaption, ::nStyle, ::nLeft, ::nTop,;
                               ::nRight , ::nBottom , ;
                               ::hWndParent, 0, GetInstance() , ::nId )
   endif

   if ::hWnd == 0
        MsgAlert( 'Window Create Error!', 'Alert' )
   else
      ::AddVars( ::hWnd )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Default() CLASS TControl

   ::lCaptured := .f.

return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TControl

   local ix
   local nAt := If( ! Empty( ::oWnd:aControls ),;
              AScan( ::oWnd:aControls, { | hCtrl | hCtrl == Self:hWnd } ), 0 )

   if nAt != 0
      ADel( ::oWnd:aControls, nAt )
      ASize( ::oWnd:aControls, Len( ::oWnd:aControls ) - 1 )
   endif

   ::DelVars( Self:hWnd )

   if "TGETBOX" $ Upper( Self:ClassName() )
      ix := GetControlIndex ( ::cControlName, ::oWnd:cParentWnd )
      if ix > 0
         ReleaseControl ( _HMG_aControlHandles [ix] )
         _HMG_aControlDeleted [ix] := .T.
      endif
   endif
   if "TBTNBOX" $ Upper( Self:ClassName() )
      if ::hWndChild != nil
        PostMessage( ::hWndChild, WM_CLOSE )
      endif
      ::PostMsg( WM_CLOSE )
      return .T.
   endif

return ::EndCtrl()

//----------------------------------------------------------------------------//
METHOD EraseBkGnd( hDC ) CLASS TControl

   Local aRect

   if IsIconic( ::hWnd )
      if ::hWnd != nil
         aRect := ::GetCliRect( ::hWnd )
         FillRect(hDC, aRect[1], aRect[2], aRect[3], aRect[4], ::hBrush )
         return 1
      endif
      return 0
   endif

   if ::hBrush != nil .and. ! Empty( ::hBrush )   //JP
        aRect := ::GetCliRect( ::hWnd )
        FillRect( hDC, aRect[1], aRect[2], aRect[3], aRect[4], ::hBrush )
      return 1
   endif

return 0   //nil JP

//----------------------------------------------------------------------------//

METHOD ForWhen() CLASS TControl

   ::oWnd:AEvalWhen()

   ::lCaptured := .f.

   // keyboard navigation
   if ::oWnd:nLastKey == VK_UP .or. ::oWnd:nLastKey == VK_DOWN ;
      .or. ::oWnd:nLastKey == VK_RETURN .or. ::oWnd:nLastKey == VK_TAB
      if _GetKeyState( VK_SHIFT )
         ::GoPrevCtrl( ::hWnd )
      else
         ::GoNextCtrl( ::hWnd )
      endif
   else
      if Empty( GetFocus() )
         SetFocus( ::hWnd )
      endif
   endif

   ::oWnd:nLastKey := 0

return nil

//----------------------------------------------------------------------------//

METHOD GetCliRect() CLASS TControl

   local aRect := _GetClientRect( ::hWnd )

return aRect

//----------------------------------------------------------------------------//

METHOD GetDlgCode( nLastKey ) CLASS TControl

   if .not. ::oWnd:lValidating
      if nLastKey == VK_RETURN .or. nLastKey == VK_TAB
         ::oWnd:nLastKey := nLastKey

      // don't do a else here with :nLastKey = 0
      // or WHEN does not work properly, as we pass here twice before
      // evaluating the WHEN
      endif
   endif

return DLGC_WANTALLKEYS // It is the only way to have 100% control using Folders

//----------------------------------------------------------------------------//

METHOD GetRect() CLASS TControl

   local aRect := {0,0,0,0}

    GetWindowRect( ::hWnd ,aRect )

return aRect

//----------------------------------------------------------------------------//

METHOD GotFocus( hCtlLost )

   HB_SYMBOL_UNUSED( hCtlLost )
   ::lFocused := .t.
   ::SetMsg( ::cMsg )

   if ::bGotFocus != nil
      return Eval( ::bGotFocus )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD GoNextCtrl( hCtrl ) CLASS TControl

   local hCtlNext
   hCtlNext := GetNextDlgTabITem ( GetActiveWindow() , GetFocus() , .f. )

   ::hCtlFocus = hCtlNext
   if hCtlNext != hCtrl
      SetFocus( hCtlNext )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD GoPrevCtrl( hCtrl ) CLASS TControl

   local hCtlPrev
   hCtlPrev := GetNextDlgTabITem ( GetActiveWindow() , GetFocus() , .t. )

   ::hCtlFocus = hCtlPrev
   if hCtlPrev != hCtrl
      SetFocus( hCtlPrev )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD KeyChar( nKey, nFlags ) CLASS TControl

   local bKeyAction := SetKey( nKey )

   do case
      case nKey == VK_TAB .and. _GetKeyState( VK_SHIFT )
           ::GoPrevCtrl( ::hWnd )
           return 0    // We don't want API default behavior

      case nKey == VK_TAB
           ::GoNextCtrl( ::hWnd )
           return 0    // We don't want API default behavior
   endcase

   if bKeyAction != nil     // Clipper SET KEYs !!!
      return Eval( bKeyAction, ProcName( 4 ), ProcLine( 4 ) )
   endif

   if ::bKeyChar != nil
      return Eval( ::bKeyChar, nKey, nFlags )
   endif

return 0

//----------------------------------------------------------------------------//

METHOD KeyDown( nKey, nFlags ) CLASS TControl

   local bKeyAction := SetKey( nKey )

   if nKey == VK_TAB .and. ::hWnd != nil
      ::GoNextCtrl( ::hWnd )
      return 0
   endif

  if bKeyAction != nil     // Clipper SET KEYs !!!
     Eval( bKeyAction, ProcName( 4 ), ProcLine( 4 ) )
     return 0
   endif

   if nKey == VK_F1
//JP      ::HelpTopic()
      return 0
   endif

   if ::bKeyDown != nil
      return Eval( ::bKeyDown, nKey, nFlags )
   endif

return 0

//----------------------------------------------------------------------------//

METHOD KillFocus( hCtlFocus ) CLASS TControl

   HB_SYMBOL_UNUSED( hCtlFocus )
return ::LostFocus()

//----------------------------------------------------------------------------//
METHOD LButtonDown( nRow, nCol, nKeyFlags ) CLASS TControl

   ::lMouseDown := .t.
   ::nLastRow   := nRow
   ::nLastCol   := nCol

   if ::bLClicked != nil
      return Eval( ::bLClicked, nRow, nCol, nKeyFlags )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD LButtonUp( nRow, nCol, nKeyFlags ) CLASS TControl

   if ::bLButtonUp != nil
      return Eval( ::bLButtonUp, nRow, nCol, nKeyFlags )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD LostFocus( hWndGetFocus ) CLASS TControl

   ::lFocused := .f.
   ::SetMsg()
   if ! Empty( ::bLostFocus )
      return Eval( ::bLostFocus, hWndGetFocus )
   endif

RETURN nil

//----------------------------------------------------------------------------//

METHOD MouseMove( nRow, nCol, nKeyFlags ) CLASS TControl

   if ::oCursor != nil
      SetResCursor( ::oCursor:hCursor )
   else
      CursorArrow()
   endif

   if ::lFocused
      ::SetMsg( ::cMsg, ::lKeepDefaultStatus )
   endif

   if ::bMMoved != nil
      return Eval( ::bMMoved, nRow, nCol, nKeyFlags )
   endif

return 0

//----------------------------------------------------------------------------//

METHOD Move( nTop, nLeft, nWidth, nHeight, lRepaint ) CLASS TControl

   MoveWindow( ::hWnd, nTop, nLeft, nWidth, nHeight, lRepaint )

   ::CoorsUpdate()

return nil

//----------------------------------------------------------------------------//

METHOD RButtonUp( nRow, nCol, nKeyFlags ) CLASS TControl

   if ::bRButtonUp != nil
      Eval( ::bRButtonUp, nRow, nCol, nKeyFlags )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Register( nClsStyle )  CLASS TControl

   local hUser, ClassName

   DEFAULT ::lRegistered := .f.

   if ::lRegistered
      return nil
   endif

   hUser := GetInstance()

   ClassName := ::cControlName

   DEFAULT nClsStyle  := nOr( CS_VREDRAW, CS_HREDRAW ),;
           ::nClrPane := GetSysColor( COLOR_WINDOW ),;
           ::hBrush   := CreateSolidBrush( GetRed( ::nClrPane ), GetGreen( ::nClrPane ), GetBlue( ::nClrPane ) )

   nClsStyle := nOr( nClsStyle, CS_GLOBALCLASS, CS_DBLCLKS )

   if GetClassInfo( hUser, ClassName ) == nil
      ::lRegistered := Register_Class( ClassName, nClsStyle, "", , hUser, 0, ::hBrush )
   else
      ::lRegistered := .t.
   endif

return ::hBrush

//----------------------------------------------------------------------------//

METHOD ReSize( nSizeType, nWidth, nHeight ) CLASS TControl

   ::CoorsUpdate()
   if ::bResized != nil
      Eval( ::bResized, nSizeType, nWidth, nHeight )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SetMsg( cText, lDefault ) CLASS TControl

    Local cOldText, cParentWnd

    If ::nStatusItem < 1 
       return Nil 
    EndIf 

    DEFAULT lDefault := .F. , cText := ""

    cParentWnd := iif( _HMG_MainClientMDIHandle == 0, ::cParentWnd, _HMG_MainClientMDIName )

    if _IsWindowActive ( cParentWnd )
      if _IsControlDefined ( "StatusBar" , cParentWnd )
         if !lDefault
            cOldText := GetItemBar( _HMG_ActiveStatusHandle , ::nStatusItem )
            if !(AllTrim(cOldText) == AllTrim(cText))
               SetProperty( cParentWnd, "StatusBar", "Item", ::nStatusItem, cText )
            endif
         elseif valtype ( _HMG_DefaultStatusBarMessage ) == "C"
            SetProperty( cParentWnd, "StatusBar", "Item", ::nStatusItem, _HMG_DefaultStatusBarMessage )
         endif
      endif
    endif

return nil

//----------------------------------------------------------------------------//

METHOD SetColor( nClrFore, nClrBack, hBrush ) CLASS TControl

   ::nClrText = nClrFore
   ::nClrPane = nClrBack

   If ::hBrush != nil
      DeleteObject( ::hBrush )  // Alen Uzelac 13.09.2012
   EndIf

   if hBrush != nil
      ::hBrush := hBrush
   else
      ::hBrush := CreateSolidBrush( GetRed( nClrBack ), GetGreen( nClrBack ), GetBlue( nClrBack ) )
   endif

return nil

//==========From TWindow ===============================

METHOD SuperKeyDown( nKey, nFlags ) CLASS TControl

  local bKeyAction := SetKey( nKey )

  if bKeyAction != nil     // Clipper SET KEYs !!!
     Eval( bKeyAction, ProcName( 4 ), ProcLine( 4 ) )
     return 0
   endif

   if nKey == VK_F1
//      ::HelpTopic()
      return 0
   endif

   if ::bKeyDown != nil
      return Eval( ::bKeyDown, nKey, nFlags )
   endif

return nil

METHOD __SetFocus() CLASS TControl

   if ::lWhen()
      SetFocus( ::hWnd )
      ::oWnd:hCtlFocus := ::hWnd
   endif

return nil

METHOD VScroll( nWParam, nLParam ) CLASS TControl

   local nScrHandle := HiWord( nLParam )

   if nScrHandle == 0                   // Window ScrollBar
      if ::oVScroll != nil
         do case
            case nWParam == SB_LINEUP
                 ::oVScroll:GoUp()

            case nWParam == SB_LINEDOWN
                 ::oVScroll:GoDown()

            case nWParam == SB_PAGEUP
                 ::oVScroll:PageUp()

            case nWParam == SB_PAGEDOWN
                 ::oVScroll:PageDown()

            case nWParam == SB_THUMBPOSITION
                 ::oVScroll:ThumbPos( LoWord( nLParam ) )

            case nWParam == SB_THUMBTRACK
                 ::oVScroll:ThumbTrack( LoWord( nLParam ) )

            case nWParam == SB_ENDSCROLL
                 return 0
         endcase
      endif
   else                                 // Control ScrollBar
      do case
         case nWParam == SB_LINEUP
              SendMessage( nScrHandle, FM_SCROLLUP )

         case nWParam == SB_LINEDOWN
              SendMessage( nScrHandle, FM_SCROLLDOWN )

         case nWParam == SB_PAGEUP
              SendMessage( nScrHandle, FM_SCROLLPGUP )

         case nWParam == SB_PAGEDOWN
              SendMessage( nScrHandle, FM_SCROLLPGDN )

         case nWParam == SB_THUMBPOSITION
              SendMessage( nScrHandle, FM_THUMBPOS, LoWord( nLParam ) )

         case nWParam == SB_THUMBTRACK
              SendMessage( nScrHandle, FM_THUMBTRACK, LoWord( nLParam ) )
      endcase
   endif

return 0

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TControl

   do case

   case nMsg == WM_CLOSE
            return 0

   case nMsg == WM_COMMAND
           return ::Command( nWParam, nLParam )

   case nMsg == WM_NOTIFY
           return ::Notify( nWParam, nLParam )

   case nMsg == WM_PAINT
           ::BeginPaint()
           ::Paint()
           ::EndPaint()
           SysRefresh()
      case nMsg == WM_DESTROY
           return ::Destroy()

      case nMsg == WM_DRAWITEM
           return ::DrawItem( nWParam, nLParam )

      case nMsg == WM_ERASEBKGND
           return ::EraseBkGnd( nWParam )

      case nMsg == WM_HSCROLL
           return ::HScroll( nWParam, nLParam )

      case nMsg == WM_KEYDOWN
           return ::KeyDown( nWParam, nLParam )

      case nMsg == WM_CHAR
           return ::KeyChar( nWParam, nLParam )

      CASE nMsg == WM_GETDLGCODE
            return ::GetDlgCode( nWParam )

      case nMsg == WM_KILLFOCUS
           return ::LostFocus( nWParam ) // LostFocus(), not KillFocus()!!!

      case nMsg == WM_LBUTTONDOWN
           return ::LButtonDown( HiWord( nLParam ), LoWord( nLParam ),;
                                 nWParam )
      case nMsg == WM_LBUTTONUP
           return ::LButtonUp( HiWord( nLParam ), LoWord( nLParam ),;
                               nWParam )
      case nMsg == WM_MOUSEMOVE
           return ::MouseMove( HiWord( nLParam ), LoWord( nLParam ),;
                               nWParam )

      case nMsg == WM_RBUTTONDOWN
           return ::RButtonDown( HiWord( nLParam ), LoWord( nLParam ),;
                                 nWParam )
      case nMsg == WM_RBUTTONUP
           return ::RButtonUp( HiWord( nLParam ), LoWord( nLParam ),;
                               nWParam )
      case nMsg == WM_SETFOCUS
           return ::GotFocus( nWParam )

      case nMsg == WM_VSCROLL
           return ::VScroll( nWParam, nLParam )

      case nMsg == WM_SIZE
           return ::ReSize( nWParam, LoWord( nLParam ), HiWord( nLParam ) )

      case nMsg == WM_TIMER
           return ::Timer( nWParam, nLParam )

      case nMsg == WM_ASYNCSELECT
           return ::AsyncSelect( nWParam, nLParam )

      endcase

RETURN 0

METHOD Command( nWParam, nLParam ) CLASS TControl

   local nNotifyCode, hWndCtl

   nNotifyCode := HiWord( nWParam )
//   nID         = LoWord( nWParam )
   hWndCtl     := nLParam

   do case
   case hWndCtl == 0

      * TGet Enter ......................................
      if HiWord(nWParam) == 0 .and. LoWord(nWParam) == 1
         ::KeyDown( VK_RETURN, 0 )
      EndIf
      * TGet Escape .....................................
      if HiWord(nwParam) == 0 .and. LoWord(nwParam) == 2
         ::KeyDown( VK_ESCAPE, 0 )
      endif

   case hWndCtl != 0

      do case
         case nNotifyCode == CBN_KILLFOCUS
           ::LostFocus()
         case nNotifyCode == NM_KILLFOCUS
           ::LostFocus()
         case nNotifyCode == EN_KILLFOCUS
           ::LostFocus()
//       case nNotifyCode == EN_UPDATE
//         ::KeyDown( VK_RETURN, 0 )
      endcase

   endcase

return nil

METHOD Notify( nWParam, nLParam ) CLASS TControl

   HB_SYMBOL_UNUSED( nWParam )

//   nNotifyCode := GetNotifyCode (nLParam )
//   hWndCtl     := GetHwndFrom ( nLParam)

   If GetNotifyCode( nLParam ) == NM_KILLFOCUS
      ::LostFocus()
   endif

return nil
