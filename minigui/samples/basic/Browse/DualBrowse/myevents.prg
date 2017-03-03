*--------------------------------------------------------------------------------------------------------------------------------*
*  FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )
*    RETURN (0)
*--------------------------------------------------------------------------------------------------------------------------------*
*
*------------------------------------------------------------*
* JF Modified h_windows.prg using HMG experimental build 10e
* I made 14 functional changes in FUNCTION EVENTS:
*   added at the top                                                                    NO PROBLEM
*         memvar lIncremental
*   changed the name of the memvar NextControlHandle to nNextControlHandle, so that     NO PROBLEM
*     my indenting program would not interpret a line beginning with "Next" as part
*     of a FOR ... NEXT construction
*   expanded a single-line IF() statement for accurate indenting, after                 NO PROBLEM
*         CASE nMsg == WM_SetFocus
*   Browse click: changed RETURN 0 to RETU ClearSearch( 0 )                             NO PROBLEM
*   Leave the NEXT RETURN 0 alone (redraw vertical scrollbar)
*   Browse key handling: replace the Alt-A keytrap (first CASE statement after          NO PROBLEM
*        If GetNotifyCode ( lParam ) == LVN_KEYDOWN
*   Browse key handling: replace RETURN 1 statements ( 6 ) with RETU ClearSearch( 1 )   NO PROBLEM
*        Home, End, PgUp, PgDn, Up, Dn
*   Browse key handling: add a final CASE statement (CASE lIncremental)
*   Browse key handling: replace last RETURN 0 with RETU ClearSearch( 0 )               NO PROBLEM
*
*   Textbox gotfocus: added additional masking characters after the third instance of   NO PROBLEM
*         IF _HMG_aControlType[i] == 'CHARMASKTEXT'
*           FOR x := 1 TO LEN(_HMG_aControlInputMask[i])
*     * Note this change is NOT needed for implementation of the incremental search.
*     * It is just a change I made to enable the use of other character masks.
*
* I also reindented the code and broke up some long lines
* I replaced single = operators with := or ==, depending on the command in which they appeared
* I replaced IF() operators with IIF()
*
*------------------------------------------------------------*
#define NM_CUSTOMDRAW       ( -12 )
#define DC_BRUSH            18
#define WM_MOVE             3
#define WM_MOVING           534
#define LVN_BEGINDRAG       ( -109 )
#define WS_VISIBLE          0x10000000
#define WS_GROUP            0x20000
#define BS_AUTORADIOBUTTON  9
#define WS_CHILD            0x40000000
#define BS_NOTIFY           0x4000
#define GWL_STYLE           ( -16 )
#define CBN_EDITCHANGE      5
#define SIZE_MAXHIDE        4
#define SIZE_MAXIMIZED      2
#define SIZEFULLSCREEN      2
#define SIZE_MAXSHOW        3
#define SIZE_MINIMIZED      1
#define SIZEICONIC          1
#define SIZE_RESTORED       0
#define SIZENORMAL          0
#define TBN_FIRST           ( -700 )
#define TBN_DROPDOWN        ( TBN_FIRST -10 )
#define WM_CTLCOLORLISTBOX  308
#define WM_CTLCOLORBTN      309
#define COLOR_WINDOW        5
#define COLOR_3DFACE        15
#define COLOR_BTNFACE       15
#define OPAQUE              2
#define DKGRAY_BRUSH        3
#define LVN_GETDISPINFO     ( -150 )
#define WM_HOTKEY           786
#define WM_CTLCOLOREDIT     307
#define WM_MOUSEWHEEL       0x20A
#define WM_MOUSEHOVER       0x2a1
#define EN_MSGFILTER        1792
#define DLGC_WANTCHARS      128
#define DLGC_WANTMESSAGE    4
#define MCN_FIRST           ( -750 )
#define MCN_LAST            ( -759 )
#define MCN_SELCHANGE       ( MCN_FIRST +1 )
#define MCN_SELECT          ( MCN_FIRST +4 )

#define WM_HELP             83
#define STN_CLICKED         0
#define STN_DBLCLK          1
#define STN_ENABLE          2
#define STN_DISABLE         3

#define SB_HORZ             0
#define NM_CLICK            ( -2 )
#define BS_DEFPUSHBUTTON    1
#define BM_SETSTYLE         244
#define SB_CTL              2
#define SB_VERT             1
#define SB_LINEUP           0
#define SB_LINEDOWN         1
#define SB_LINELEFT         0
#define SB_LINERIGHT        1
#define SB_PAGEUP           2
#define SB_PAGEDOWN         3
#define SB_PAGELEFT         2
#define SB_PAGERIGHT        3
#define SB_THUMBPOSITION    4
#define SB_THUMBTRACK       5
#define SB_ENDSCROLL        8
#define SB_LEFT             6
#define SB_RIGHT            7
#define SB_BOTTOM           7
#define SB_TOP              6

#define WM_VSCROLL          0x0115

#define TVN_SELCHANGEDW     ( -451 )
#define TVN_SELCHANGED      TVN_SELCHANGEDA
#define TVN_SELCHANGEDA     ( -402 )

* New define FOR TaskBar
* #define WM_USER             0x0400
#define WM_TASKBAR          WM_USER +1043
#define ID_TASKBAR          0
#define WM_MOUSEMOVE        512                      // 0x0200
#define WM_LBUTTONDOWN      513                      // 0x0201
#define WM_LBUTTONUP        514                      // 0x0202
#define WM_LBUTTONDBLCLK    515                      // 0x203
#define WM_RBUTTONDOWN      516                      // 0x0204
#define WM_RBUTTONUP        517                      // 0x0205

#define WM_INITDIALOG       272
#define WM_ACTIVATEAPP      28
#define TB_AUTOSIZE         1057
#define WM_EXITSIZEMOVE     562
#define WM_ENTERSIZEMOVE    561
#define WM_NEXTDLGCTL       40
#define WM_GETDLGCODE       135
#define TRANSPARENT         1
#define GRAY_BRUSH          2
#define NULL_BRUSH          5
#define WM_CTLCOLORSTATIC   312
#define WM_CTLCOLORDLG      310
#define BN_CLICKED          0
#define WM_VKEYTOITEM       46
#define LBN_KILLFOCUS       5
#define LBN_SETFOCUS        4
#define CBN_KILLFOCUS       4
#define CBN_SETFOCUS        3
#define BN_KILLFOCUS        7
#define BN_SETFOCUS         6
#define NM_SETFOCUS         ( -7 )
#define NM_KILLFOCUS        ( -8 )
#define WM_SYSKEYDOWN       260
#define LVN_KEYDOWN         ( -155 )
#define LVN_COLUMNCLICK     ( -108 )
#define NM_DBLCLK           ( -3 )
#define LBN_DBLCLK          2
#define TCN_SELCHANGE       ( -551 )
#define TCN_SELCHANGING     ( -552 )
#define DTN_FIRST           ( -760 )
#define DTN_DATETIMECHANGE  ( DTN_FIRST +1 )
#define TB_ENDTRACK         8
#define WM_HSCROLL          276
#define CBN_SELCHANGE       1
#define LVN_ITEMCHANGED     ( -101 )
#define LBN_SELCHANGE       1
#define WM_PAINT            15
#define WM_ERASEBKGND       20
#define WM_DRAWITEM         43
#define WM_SHOWWINDOW       24
#define EN_SetFocus         256
#define EN_KILLFOCUS        512
#define WM_SetFocus         7
#define WM_KILLFOCUS        8
#define WM_UNDO             772
#define EM_SETMODIFY        185
#define WM_PASTE            770
#define WM_CHAR             258
#define EM_GETLINE          196
#define EM_SETSEL           177
#define WM_CLEAR            771
#define EM_GETSEL           176
#define EM_UNDO             199
#define EN_CHANGE           768
#define EN_UPDATE           1024
#define WM_ACTIVATE         6
#define WM_SIZING           532
#define MK_LBUTTON          1
#define WM_CONTEXTMENU      123
#define WM_TIMER            275
#define WM_SIZE             5
#define TBM_SETPOS          1029
#define TBM_GETPOS          1024
#define PBM_SETPOS          1026
#define WM_SYSCOMMAND       274
#define SC_CLOSE            61536
#define WM_KEYDOWN          256
#define WM_CLOSE            0x0010
#define WM_COMMAND          0x0111
#define WM_DESTROY          0x0002
#define WM_NOTIFY           78
#define WM_CREATE           1
#define WM_QUIT             18
#define WM_MENUSELECT       287
#define MF_HILITE           128
                                                     // JP 107a
#define TTN_FIRST           ( -520 )                 // tooltips
#ifdef UNICODE
#define TTN_NEEDTEXT      ( TTN_FIRST -10 )
#ELSE
#define TTN_NEEDTEXT      ( TTN_FIRST - 0 )
#ENDIF
#define EN_SELCHANGE        1794
#define EN_DRAGDROPDONE     1804
#define EN_VSCROLL          1538

#define RBN_FIRST           ( -831 )                 // chevron
#define RBN_CHEVRONPUSHED   ( RBN_FIRST -10 )

#ifdef __XHARBOUR__
  #define __SYSDATA__
#endif

#include "minigui.ch"
#include "error.ch"

*------------------------------------------------------------*
FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------*
LOCAL i, z, x, FormCount, lvc, k, aPos, ws, maskstart, xs, xd, ts, nr
LOCAL ControlCount, RecordCount, nSkipCount, BackRec, BackArea, BrowseArea, nNextControlHandle
LOCAL NewPos, NewHPos, NewVPos, _ThisQueryTemp, r
LOCAL hwm := .F., hws, mVar, DeltaSelect, TmpStr, Tmp, xRetVal, aCellData
LOCAL aTemp, aTemp2, a, dBc, dFc

* JF
MEMVAR lIncremental

DO CASE
***********************************************************************
CASE nMsg == WM_DRAWITEM
***********************************************************************
  RETURN (OwnButtonPaint( lParam ))

***********************************************************************
CASE nMsg == WM_CTLCOLORSTATIC
***********************************************************************

  i := ASCAN( _HMG_aControlHandles, lParam )
  IF i > 0

    IF _HMG_aControlType[i] == 'LABEL' .OR. _HMG_aControlType[i] == 'HYPERLINK' .OR. _HMG_aControlType[i] == 'CHECKBOX' ;
      .OR. _HMG_aControlType[i] == 'RADIOGROUP' .OR. _HMG_aControlType[i] == 'FRAME' ;
      .OR. _HMG_aControlType[i] == 'SLIDER' .OR. _HMG_aControlType[i] == 'COMBO'

      IF _HMG_aControlFontColor[i] != NIL
        SetTextColor( wParam, _HMG_aControlFontColor[i][1], _HMG_aControlFontColor[i][2], _HMG_aControlFontColor[i][3] )
      ENDIF

      IF VALTYPE( _HMG_aControlInputMask[i] ) == 'L'
        IF _HMG_aControlInputMask[i] == .T.
          SetBkMode( wParam, TRANSPARENT )
          RETURN (GetStockObject( NULL_BRUSH ))
        ENDIF
      ENDIF

      IF _HMG_aControlBkColor[i] != NIL

        SetBkColor( wParam, _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], _HMG_aControlBkColor[i][3] )
        DeleteObject ( _HMG_aControlBrushHandle[i] )
        _HMG_aControlBrushHandle[i] := CreateSolidBrush( _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], _HMG_aControlBkColor[i][3] )
        RETURN ( _HMG_aControlBrushHandle[i] )

      ELSE
        DeleteObject ( _HMG_aControlBrushHandle[i] )
        _HMG_aControlBrushHandle[i] := CreateSolidBrush( GetRed ( GetSysColor ( COLOR_3DFACE)), GetGreen ( GetSysColor ( COLOR_3DFACE)), ;
          GetBlue ( GetSysColor ( COLOR_3DFACE)))
        SetBkColor( wParam, GetRed ( GetSysColor ( COLOR_3DFACE)), GetGreen ( GetSysColor ( COLOR_3DFACE)), ;
          GetBlue ( GetSysColor ( COLOR_3DFACE)))
        RETURN ( _HMG_aControlBrushHandle[i] )
      ENDIF
    ENDIF
  ELSE
    FOR i := 1 TO LEN( _HMG_aControlhandles )
      IF VALTYPE( _HMG_aControlHandles[i] ) == 'A'

        IF _HMG_aControlType[i] == 'RADIOGROUP'
          FOR x := 1 TO LEN( _HMG_aControlHandles[i] )

            IF _HMG_aControlHandles[i][x] == lParam
              IF _HMG_aControlFontColor[i] != NIL
                SetTextColor( wParam, _HMG_aControlFontColor[i][1], _HMG_aControlFontColor[i][2], _HMG_aControlFontColor[i][3] )
              ENDIF

              IF VALTYPE( _HMG_aControlInputMask[i] ) == 'L'
                IF _HMG_aControlInputMask[i] == .T.
                  SetBkMode( wParam, TRANSPARENT )
                  RETURN (GetStockObject( NULL_BRUSH ))
                ENDIF
              ENDIF

              IF _HMG_aControlBkColor[i] != NIL
                SetBkColor( wParam, _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], _HMG_aControlBkColor[i][3] )
                IF x == 1
                  DeleteObject ( _HMG_aControlBrushHandle[i] )
                  _HMG_aControlBrushHandle[i] := CreateSolidBrush( _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], ;
                    _HMG_aControlBkColor[i][3] )
                ENDIF
                RETURN ( _HMG_aControlBrushHandle[i] )
              ELSE
                IF x == 1
                  DeleteObject ( _HMG_aControlBrushHandle[i] )
                  _HMG_aControlBrushHandle[i] := CreateSolidBrush( GetRed ( GetSysColor ( COLOR_3DFACE)), ;
                    GetGreen ( GetSysColor ( COLOR_3DFACE)), GetBlue ( GetSysColor ( COLOR_3DFACE)))
                ENDIF
                SetBkColor( wParam, GetRed ( GetSysColor ( COLOR_3DFACE)), GetGreen ( GetSysColor ( COLOR_3DFACE)), ;
                  GetBlue ( GetSysColor ( COLOR_3DFACE)))
                RETURN ( _HMG_aControlBrushHandle[i] )
              ENDIF
            ENDIF
          NEXT x
        ENDIF
      ENDIF
    NEXT i
  ENDIF

***********************************************************************
CASE nMsg == WM_CTLCOLOREDIT .OR. nMsg == WM_CTLCOLORLISTBOX
***********************************************************************

  i := ASCAN( _HMG_aControlHandles, lParam )

  IF i > 0

    IF _HMG_aControlType[i] == 'NUMTEXT' .OR. _HMG_aControlType[i] == 'TEXT' .OR. _HMG_aControlType[i] == 'MASKEDTEXT' ;
      .OR. _HMG_aControlType[i] == 'CHARMASKTEXT' .OR. _HMG_aControlType[i] == 'EDIT' ;
      .OR. _HMG_aControlType[i] == 'LIST' .OR. _HMG_aControlType[i] == 'MULTILIST' .OR. _HMG_aControlType[i] == 'COMBO'

      IF _HMG_aControlFontColor[i] != NIL
        SetTextColor( wParam, _HMG_aControlFontColor[i][1], _HMG_aControlFontColor[i][2], _HMG_aControlFontColor[i][3] )
      ENDIF

      IF _HMG_aControlBkColor[i] != NIL
        SetBkColor( wParam, _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], _HMG_aControlBkColor[i][3] )
        DeleteObject ( _HMG_aControlBrushHandle[i] )
        _HMG_aControlBrushHandle[i] := CreateSolidBrush( _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], ;
          _HMG_aControlBkColor[i][3] )
        RETURN ( _HMG_aControlBrushHandle[i] )
      ELSE
        DeleteObject ( _HMG_aControlBrushHandle[i] )
        _HMG_aControlBrushHandle[i] := CreateSolidBrush( GetRed ( GetSysColor ( COLOR_WINDOW)), GetGreen ( GetSysColor ( COLOR_WINDOW)), ;
          GetBlue ( GetSysColor ( COLOR_WINDOW)))
        SetBkColor( wParam, GetRed ( GetSysColor ( COLOR_WINDOW)), GetGreen ( GetSysColor ( COLOR_WINDOW)), ;
          GetBlue ( GetSysColor ( COLOR_WINDOW)))
        RETURN ( _HMG_aControlBrushHandle[i] )
      ENDIF
    ENDIF
  ELSE

    FOR i := 1 TO LEN( _HMG_aControlhandles )

      IF VALTYPE( _HMG_aControlHandles[i] ) == 'A'

        IF _HMG_aControlType[i] == 'SPINNER'

          IF _HMG_aControlHandles[i][1] == lParam

            IF _HMG_aControlFontColor[i] != NIL
              SetTextColor( wParam, _HMG_aControlFontColor[i][1], _HMG_aControlFontColor[i][2], _HMG_aControlFontColor[i][3] )
            ENDIF

            IF _HMG_aControlBkColor[i] != NIL
              SetBkColor( wParam, _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], _HMG_aControlBkColor[i][3] )
              DeleteObject ( _HMG_aControlBrushHandle[i] )
              _HMG_aControlBrushHandle[i] := CreateSolidBrush( _HMG_aControlBkColor[i][1], _HMG_aControlBkColor[i][2], ;
                _HMG_aControlBkColor[i][3] )
              RETURN ( _HMG_aControlBrushHandle[i] )
            ELSE
              DeleteObject ( _HMG_aControlBrushHandle[i] )
              _HMG_aControlBrushHandle[i] := CreateSolidBrush( GetRed ( GetSysColor ( COLOR_WINDOW)), ;
                GetGreen ( GetSysColor ( COLOR_WINDOW)), GetBlue ( GetSysColor ( COLOR_WINDOW)))
              SetBkColor( wParam, GetRed ( GetSysColor ( COLOR_WINDOW)), GetGreen ( GetSysColor ( COLOR_WINDOW)), ;
                GetBlue ( GetSysColor ( COLOR_WINDOW)))
              RETURN ( _HMG_aControlBrushHandle[i] )
            ENDIF
          ENDIF
        ENDIF
      ENDIF
    NEXT i
  ENDIF

***********************************************************************
CASE nMsg == WM_MENUSELECT
***********************************************************************

  IF NUMAND ( HiWord( wParam ), MF_HILITE ) <> 0

    i := ASCAN( _HMG_aControlIds, LoWord( wParam ))  // LoWord( wParam ) == menu id

    IF i > 0
      IF ( x := ASCAN( _HMG_aFormHandles, _HMG_aControlParentHandles[i] )) > 0
        IF _IsControlDefined ( "StatusBar", _HMG_aFormNames[x] )
          IF _HMG_aControlValue[i] # NIL
            * mostra a mensagem no STATUSBAR da janela
            SetProperty( _HMG_aFormNames[x], "StatusBar", "Item", 1, _HMG_aControlValue[i] )

          ELSEIF VALTYPE( _HMG_DefaultStatusBarMessage ) == "C"
            * apaga a mensagem
            SetProperty( _HMG_aFormNames[x], "StatusBar", "Item", 1, _HMG_DefaultStatusBarMessage )
          ENDIF
        ENDIF
      ENDIF
    ENDIF
    RETURN 0
  ENDIF

***********************************************************************
CASE nMsg == WM_HOTKEY
***********************************************************************
  * Process HotKeys
  i := ASCAN( _HMG_aControlIds, wParam )

  IF i > 0
    IF _HMG_aControlType[i] == 'HOTKEY' .AND. _HMG_aControlParentHandles[i] == GetActiveWindow()
      IF _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
        RETURN 0
      ENDIF
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_MOUSEWHEEL
***********************************************************************

  hwnd := 0

  i := ASCAN( _HMG_aFormHandles, GetFocus())

  IF i > 0
    IF _HMG_aFormVirtualHeight[i] > 0
      hwnd := _HMG_aFormHandles[i]
    ENDIF
  ELSE

    i := ASCAN( _HMG_aControlhandles, GetFocus())
    IF i > 0

      x := ASCAN( _HMG_aFormHandles, _HMG_aControlParentHandles[i] )
      IF x > 0
        IF _HMG_aFormVirtualHeight[x] > 0
          hwnd := _HMG_aFormHandles[x]
          i := x
        ENDIF
      ENDIF
    ELSE
      ControlCount := LEN( _HMG_aControlHandles )
      FOR i := 1 TO ControlCount
        IF _HMG_aControlType[i] == 'RADIOGROUP'
          x := ASCAN( _HMG_aControlHandles[i], GetFocus())
          IF x > 0
            z := ASCAN( _HMG_aFormHandles, _HMG_aControlParentHandles[i] )
            IF z > 0
              IF _HMG_aFormVirtualHeight[z] > 0
                hwnd := _HMG_aFormHandles[z]
                i := z
                EXIT
              ENDIF
            ENDIF
          ENDIF
        ENDIF
      NEXT i
    ENDIF
  ENDIF

  IF hwnd != 0
    IF HiWord( wParam ) == 120
      IF GetScrollPos( hwnd, SB_VERT ) < 20
        SetScrollPos ( hwnd, SB_VERT, 0, 1 )
      ELSE
        SendMessage ( hwnd, WM_VSCROLL, SB_PAGEUP, 0 )
      ENDIF
    ELSE
      IF GetScrollPos( hwnd, SB_VERT ) >= GetScrollRangeMax ( hwnd, SB_VERT ) - 10
        SetScrollPos ( hwnd, SB_VERT, GetScrollRangeMax ( hwnd, SB_VERT ), 1 )
      ELSE
        SendMessage ( hwnd, WM_VSCROLL, SB_PAGEDOWN, 0 )
      ENDIF
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_CREATE
***********************************************************************

  IF _HMG_BeginWindowMDIActive .AND. _HMG_MainClientMDIHandle == 0

    _HMG_MainClientMDIHandle := InitMDIClientWindow(hWnd)

  ENDIF

***********************************************************************
CASE nMsg == WM_ACTIVATE
***********************************************************************

  IF LoWord( wParam ) == 0
    i := ASCAN( _HMG_aFormhandles, hWnd )
    IF i > 0

      ControlCount := LEN( _HMG_aControlHandles )

      FOR x := 1 TO ControlCount
        IF _HMG_aControlType[x] == 'HOTKEY'
          ReleaseHotKey ( _HMG_aControlParentHandles[x], _HMG_aControlIds[x] )
        ENDIF
      NEXT x

      _HMG_aFormFocusedControl[i] := GetFocus()
      _DoWindowEventProcedure( _HMG_aFormLostFocusProcedure[i], i, 'WINDOW_LOSTFOCUS' )
    ENDIF
  ELSE
    i := ASCAN( _HMG_aFormhandles, hWnd )
    IF i > 0
      UpdateWindow ( hWnd )
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_SetFocus
***********************************************************************

  i := ASCAN( _HMG_aFormhandles, hWnd )

  IF i > 0

    IF _hmg_aFormActive[i] == .T. .AND. _hmg_aFormType[i] != 'X'
      _hmg_UserWindowHandle := hWnd
    ENDIF

    ControlCount := LEN( _HMG_aControlHandles )

    FOR x := 1 TO ControlCount
      IF _HMG_aControlType[x] == 'HOTKEY'
        ReleaseHotKey ( _HMG_aControlParentHandles[x], _HMG_aControlIds[x] )
      ENDIF
    NEXT x

    FOR x := 1 TO ControlCount
      IF _HMG_aControlType[x] == 'HOTKEY'
        IF _HMG_aControlParentHandles[x] == hWnd
          InitHotKey ( hWnd, _HMG_aControlPageMap[x], _HMG_aControlValue[x], _HMG_aControlIds[x] )
        ENDIF
      ENDIF
    NEXT x

    _DoWindowEventProcedure( _HMG_aFormGotFocusProcedure[i], i, 'WINDOW_GOTFOCUS' )

    *--------------------------------------------------------*
    * JF: I expanded the structure of this inline IF(), for accurate indenting
    * if ( _HMG_aFormFocusedControl[i] != 0, SetFocus (_HMG_aFormFocusedControl[i]), NIL )
    IF _HMG_aFormFocusedControl[i] != 0
      SetFocus (_HMG_aFormFocusedControl[i])
    ENDIF
    *--------------------------------------------------------*
  ENDIF

***********************************************************************
CASE nMsg == WM_HELP
***********************************************************************

  i := ASCAN( _HMG_aControlHandles, GetHelpData ( lParam ))

  IF i > 0
    WinHelp( hwnd, _HMG_ActiveHelpFile, 1, 2, _HMG_aControlHelpId[i] )
  ENDIF

***********************************************************************
CASE nMsg == WM_VSCROLL
***********************************************************************

  i := ASCAN( _HMG_aFormHandles, hWnd )

  IF i > 0
    * Vertical ScrollBar Processing
    IF _HMG_aFormVirtualHeight[i] > 0 .AND. lParam == 0

      IF _HMG_aFormRebarhandle[i] > 0
        MsgMiniGuiError( "SplitBox's Parent Window Can't Be a 'Virtual Dimensioned' Window (Use 'Virtual Dimensioned' SplitChild Instead)." ;
          + " Program terminated." )
      ENDIF

      z := GetScrollRangeMax ( hwnd, SB_VERT ) / 20

      IF LoWord( wParam ) == SB_LINEDOWN
        NewPos := GetScrollPos( hwnd, SB_VERT ) + z
        SetScrollPos ( hwnd, SB_VERT, NewPos, 1 )

      ELSEIF LoWord( wParam ) == SB_LINEUP
        NewPos := GetScrollPos( hwnd, SB_VERT ) - z
        SetScrollPos ( hwnd, SB_VERT, NewPos, 1 )

      ELSEIF LoWord( wParam ) == SB_PAGEUP
        NewPos := GetScrollPos( hwnd, SB_VERT ) - 20
        SetScrollPos ( hwnd, SB_VERT, NewPos, 1 )

      ELSEIF LoWord( wParam ) == SB_PAGEDOWN
        NewPos := GetScrollPos( hwnd, SB_VERT ) + 20
        SetScrollPos ( hwnd, SB_VERT, NewPos, 1 )

      ELSEIF LoWord( wParam ) == SB_THUMBPOSITION
        NewPos := HiWord( wParam )
        SetScrollPos ( hwnd, SB_VERT, NewPos, 1 )
      ENDIF

      IF _HMG_aFormVirtualWidth[i] > 0
        NewHPos := GetScrollPos ( hwnd, SB_HORZ )
      ELSE
        NewHPos := 0
      ENDIF

      * Control Repositioning
      IF LoWord( wParam ) == SB_THUMBPOSITION .OR. LoWord( wParam ) == SB_LINEDOWN .OR. LoWord( wParam ) == SB_LINEUP ;
          .OR. LoWord( wParam ) == SB_PAGEUP .OR. LoWord( wParam ) == SB_PAGEDOWN

        FOR x := 1 TO LEN( _HMG_aControlhandles )

          IF _HMG_aControlParentHandles[x] == hwnd

            IF _HMG_aControlType[x] == 'SPINNER'

              MoveWindow ( _HMG_aControlhandles[x][1], _HMG_aControlCol[x] - NewHPos, _HMG_aControlRow[x] - NewPos, ;
                _HMG_aControlWidth[x] - GetWindowWidth(_HMG_aControlhandles[x][2] )+1, _HMG_aControlHeight[x], .T. )
              MoveWindow ( _HMG_aControlhandles[x][2], ;
                _HMG_aControlCol[x] + _HMG_aControlWidth[x] - GetWindowWidth(_HMG_aControlhandles[x][2] ) - NewHPos, ;
                _HMG_aControlRow[x] - NewPos, GetWindowWidth(_HMG_aControlhandles[x][2] ), _HMG_aControlHeight[x], .T. )

            ELSEIF _HMG_aControlType[x] == 'BROWSE'

              MoveWindow ( _HMG_aControlhandles[x], _HMG_aControlCol[x] - NewHPos, _HMG_aControlRow[x] - NewPos, ;
                _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH(), _HMG_aControlHeight[x], .T. )
              MoveWindow ( _HMG_aControlIds[x], _HMG_aControlCol[x] + _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH() - NewHPos, ;
                _HMG_aControlRow[x] - NewPos, GETVSCROLLBARWIDTH(), GetWindowHeight(_HMG_aControlIds[x]), .T. )

              MoveWindow ( _HMG_aControlMiscData1[x][1], _HMG_aControlCol[x] + _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH() - NewHPos, ;
                _HMG_aControlRow[x] +_HMG_aControlHeight[x] - GetHScrollBarHeight () - NewPos, ;
                GetWindowWidth(_HMG_aControlMiscData1[x][1]), GetWindowHeight(_HMG_aControlMiscData1[x][1]), .T. )

              ReDrawWindow ( _HMG_aControlhandles[x] )

            ELSEIF _HMG_aControlType[x] == 'RADIOGROUP'

              FOR z := 1 TO LEN(_HMG_aControlhandles[x])
                MoveWindow ( _HMG_aControlhandles[x][z], _HMG_aControlCol[x] - NewHPos, ;
                  _HMG_aControlRow[x] - NewPos + ((z-1) * _HMG_aControlSpacing[x] ), _HMG_aControlWidth[x], ;
                  _HMG_aControlHeight[x] / LEN(_HMG_aControlhandles[x]), .T. )
              NEXT z

            ELSEIF _HMG_aControlType[x] == 'TOOLBAR'
              MsgMiniGuiError( "ToolBar's Parent Window Can't Be a 'Virtual Dimensioned' Window (Use 'Virtual Dimensioned' SplitChild Instead)." ;
                + " Program terminated." )
            ELSE
              MoveWindow ( _HMG_aControlhandles[x], _HMG_aControlCol[x] - NewHPos, _HMG_aControlRow[x] - NewPos, _HMG_aControlWidth[x], ;
                _HMG_aControlHeight[x], .T. )
            ENDIF
          ENDIF
        NEXT x

        ReDrawWindow ( hwnd )
      ENDIF
    ENDIF

    IF LoWord( wParam ) == SB_LINEDOWN
      _DoWindowEventProcedure( _HMG_aFormScrollDown[i], i, '' )
    ELSEIF LoWord( wParam ) == SB_LINEUP
      _DoWindowEventProcedure( _HMG_aFormScrollUp[i], i, '' )
    ELSEIF LoWord( wParam ) == SB_THUMBPOSITION ;
      .OR. LoWord( wParam ) == SB_PAGEUP ;
      .OR. LoWord( wParam ) == SB_PAGEDOWN

      _DoWindowEventProcedure( _HMG_aFormVScrollBox[i], i, '' )
    ENDIF
  ENDIF

  i := ASCAN( _HMG_aControlIds, lParam )

  IF i > 0
    IF _HMG_aControlType[i] == 'BROWSE'

      IF LoWord( wParam ) == SB_LINEDOWN
        SetFocus( _HMG_aControlHandles[i] )
        InsertDown()
      ENDIF

      IF LoWord( wParam ) == SB_LINEUP
        SetFocus( _HMG_aControlHandles[i] )
        InsertUp()
      ENDIF

      IF LoWord( wParam ) == SB_PAGEUP
        SetFocus( _HMG_aControlHandles[i] )
        InsertPrior()
      ENDIF

      IF LoWord( wParam ) == SB_PAGEDOWN
        SetFocus( _HMG_aControlHandles[i] )
        InsertNext()
      ENDIF

      IF LoWord( wParam ) == SB_THUMBPOSITION
        BackArea := Alias()
        BrowseArea := _HMG_aControlSpacing[i]

        IF Select (BrowseArea) != 0
          Select &BrowseArea
          BackRec := RecNo()

          IF OrdKeyCount() > 0
            RecordCount := OrdKeyCount()
          ELSE
            RecordCount := RecCount()
          ENDIF

          nSkipCount := Int ( HiWord( wParam ) * RecordCount / GetScrollRangeMax ( _HMG_aControlIds[ i ], 2 ))

          IF nSkipCount > ( RecordCount / 2 )
            Go Bottom
            Skip - ( RecordCount - nSkipCount )
          ELSE
            Go Top
            Skip nSkipCount
          ENDIF

          IF EOF()
            Skip -1
          ENDIF

          nr := RecNo()

          SetScrollPos ( _HMG_aControlIds[i], 2, HiWord( wParam ), 1 )

          Go BackRec

          IF Select (BackArea) != 0
            Select &BackArea
          ELSE
            Select 0
          ENDIF

          _BrowseSetValue ( '', '', nr, i )
        ENDIF
      ENDIF
    ENDIF
  ENDIF

  i := ASCAN( _HMG_aControlhandles, lParam )
  IF ( i > 0 )
    IF LoWord ( wParam ) == TB_ENDTRACK
      _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_TASKBAR
***********************************************************************

  IF wParam == ID_TASKBAR .AND. lParam # WM_MOUSEMOVE
    aPos := GETCURSORPOS()

    DO CASE
    CASE lParam == WM_LBUTTONDOWN
      i := ASCAN( _HMG_aFormhandles, hWnd )
      IF i > 0
        _DoWindowEventProcedure( _HMG_aFormNotifyIconLeftClick[i], i, '' )
      ENDIF

    CASE lParam == WM_RBUTTONDOWN
      IF _HMG_ShowContextMenus == .T.

        i := ASCAN( _HMG_aFormhandles, hWnd )
        IF i > 0
          IF _HMG_aFormNotifyMenuHandle[i] != 0
            TrackPopupMenu ( _HMG_aFormNotifyMenuHandle[i], aPos[2], aPos[1], hWnd )
          ENDIF
        ENDIF
      ENDIF
    ENDCASE
  ENDIF

***********************************************************************
CASE nMsg == WM_NEXTDLGCTL
***********************************************************************

  IF Wparam == 0

    nNextControlHandle := GetNextDlgTabITem ( GetActiveWindow(), GetFocus(), 0 )

    SetFocus( nNextControlHandle )

    i := ASCAN( _HMG_aControlHandles, nNextControlHandle )

    IF i > 0
      IF _HMG_aControlType[i] == 'BUTTON'
        SendMessage ( nNextControlHandle, BM_SETSTYLE, LOWORD ( BS_DEFPUSHBUTTON ), 1 )
      ENDIF
    ENDIF
  ELSE

    nNextControlHandle := GetNextDlgTabITem ( GetActiveWindow(), GetFocus(), 1 )

    SetFocus( nNextControlHandle )

    i := ASCAN( _HMG_aControlHandles, nNextControlHandle )

    IF i > 0
      IF _HMG_aControlType[i] == 'BUTTON'
        SendMessage ( nNextControlHandle, BM_SETSTYLE, LOWORD ( BS_DEFPUSHBUTTON ), 1 )
      ENDIF
    ENDIF
  ENDIF

  RETURN 0

***********************************************************************
CASE nMsg == WM_HSCROLL
***********************************************************************

  i := ASCAN( _HMG_aFormHandles, hWnd )

  IF i > 0

    * Horizontal ScrollBar Processing
    IF _HMG_aFormVirtualWidth[i] > 0 .AND. lParam == 0

      IF _HMG_aFormRebarhandle[i] > 0
        MsgMiniGuiError( "SplitBox's Parent Window Can't Be a 'Virtual Dimensioned' Window (Use 'Virtual Dimensioned' SplitChild Instead)." ;
          + "Program terminated." )
      ENDIF

      z := GetScrollRangeMax ( hwnd, SB_HORZ ) / 20

      IF LoWord( wParam ) == SB_LINERIGHT

        NewHPos := GetScrollPos(hwnd,SB_HORZ) + z
        SetScrollPos ( hwnd, SB_HORZ, NewHPos, 1 )

      ELSEIF LoWord( wParam ) == SB_LINELEFT

        NewHPos := GetScrollPos(hwnd,SB_HORZ) - z
        SetScrollPos ( hwnd, SB_HORZ, NewHPos, 1 )

      ELSEIF LoWord( wParam ) == SB_PAGELEFT

        NewHPos := GetScrollPos(hwnd,SB_HORZ) - 20
        SetScrollPos ( hwnd, SB_HORZ, NewHPos, 1 )

      ELSEIF LoWord( wParam ) == SB_PAGERIGHT

        NewHPos := GetScrollPos(hwnd,SB_HORZ) + 20
        SetScrollPos ( hwnd, SB_HORZ, NewHPos, 1 )

      ELSEIF LoWord( wParam ) == SB_THUMBPOSITION

        NewHPos := HiWord( wParam )
        SetScrollPos ( hwnd, SB_HORZ, NewHPos, 1 )

      ENDIF

      IF _HMG_aFormVirtualHeight[i] > 0
        NewVPos := GetScrollPos ( hwnd, SB_VERT )
      ELSE
        NewVPos := 0
      ENDIF

      * Control Repositioning
      IF LoWord( wParam ) == SB_THUMBPOSITION .OR. LoWord( wParam ) == SB_LINELEFT .OR. LoWord( wParam ) == SB_LINERIGHT ;
          .OR. LoWord( wParam ) == SB_PAGELEFT .OR. LoWord( wParam ) == SB_PAGERIGHT

        FOR x := 1 TO LEN( _HMG_aControlhandles )

          IF _HMG_aControlParentHandles[x] == hwnd
            IF _HMG_aControlType[x] == 'SPINNER'
              MoveWindow ( _HMG_aControlhandles[x][1], _HMG_aControlCol[x] - NewHPos, _HMG_aControlRow[x] - NewVPos, ;
                _HMG_aControlWidth[x] - GetWindowWidth(_HMG_aControlhandles[x][2] )+1, _HMG_aControlHeight[x], .T. )
              MoveWindow ( _HMG_aControlhandles[x][2], ;
                _HMG_aControlCol[x] + _HMG_aControlWidth[x] - GetWindowWidth(_HMG_aControlhandles[x][2] ) - NewHPos, ;
                _HMG_aControlRow[x] - NewVPos, GetWindowWidth(_HMG_aControlhandles[x][2] ), _HMG_aControlHeight[x], .T. )

            ELSEIF _HMG_aControlType[x] == 'BROWSE'
              MoveWindow ( _HMG_aControlhandles[x], _HMG_aControlCol[x] - NewHPos, _HMG_aControlRow[x] - NewVPos, ;
                _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH(), _HMG_aControlHeight[x], .T. )
              MoveWindow ( _HMG_aControlIds[x], _HMG_aControlCol[x] + _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH() - NewHPos, ;
                _HMG_aControlRow[x] - NewVPos, GetWindowWidth(_HMG_aControlIds[x]), GetWindowHeight(_HMG_aControlIds[x]), .T. )
              MoveWindow ( _HMG_aControlMiscData1[x][1], _HMG_aControlCol[x] + _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH() - NewHPos, ;
                _HMG_aControlRow[x] +_HMG_aControlHeight[x] - GethScrollBarHeight() - NewVPos, ;
                GetWindowWidth(_HMG_aControlMiscData1[x][1]), GetWindowHeight (_HMG_aControlMiscData1[x][1]), .T. )
              ReDrawWindow ( _HMG_aControlhandles[x] )

            ELSEIF _HMG_aControlType[x] == 'RADIOGROUP'
              FOR z := 1 TO LEN(_HMG_aControlhandles[x])
                MoveWindow ( _HMG_aControlhandles[x][z], _HMG_aControlCol[x] - NewHPos, ;
                  _HMG_aControlRow[x] - NewVPos + ((z-1) * _HMG_aControlSpacing[x] ), _HMG_aControlWidth[x], ;
                  _HMG_aControlHeight[x] / LEN(_HMG_aControlhandles[x]), .T. )
              NEXT z

            ELSEIF _HMG_aControlType[x] == 'TOOLBAR'
              MsgMiniGuiError( "ToolBar's Parent Window Can't Be a 'Virtual Dimensioned' Window (Use 'Virtual Dimensioned' SplitChild Instead)." ;
                + " Program terminated." )

            ELSE
              MoveWindow ( _HMG_aControlhandles[x], _HMG_aControlCol[x] - NewHPos, _HMG_aControlRow[x] - NewVPos, _HMG_aControlWidth[x], ;
                _HMG_aControlHeight[x], .T. )
            ENDIF
          ENDIF
        NEXT x

        RedrawWindow ( hwnd )
      ENDIF
    ENDIF

    IF LoWord( wParam ) == SB_LINERIGHT
      _DoWindowEventProcedure( _HMG_aFormScrollRight[i], i, '' )

    ELSEIF LoWord( wParam ) == SB_LINELEFT
      _DoWindowEventProcedure( _HMG_aFormScrollLeft[i], i, '' )

    ELSEIF LoWord( wParam ) == SB_THUMBPOSITION ;
      .OR. LoWord( wParam ) == SB_PAGELEFT ;
      .OR. LoWord( wParam ) == SB_PAGERIGHT

      _DoWindowEventProcedure( _HMG_aFormHScrollBox[i], i, '' )
    ENDIF
  ENDIF

  i := ASCAN( _HMG_aControlhandles, lParam )
  IF ( i > 0 )
    IF LoWord ( wParam ) == TB_ENDTRACK
      _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_PAINT
***********************************************************************

  FormCount := LEN( _HMG_aFormhandles )

  FOR z := 1 TO FormCount
    IF _HMG_aFormDeleted[z] == .F.
      IF _HMG_aFormType[z] == 'X'
        IF VALTYPE( _HMG_aFormGraphTasks[z] ) == 'A'
          IF LEN( _HMG_aFormGraphTasks[z] ) > 0
            FOR x := 1 TO LEN( _HMG_aFormGraphTasks[z] )
              Eval ( _HMG_aFormGraphTasks[z][x] )
            NEXT x
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  NEXT z

  i := ASCAN( _HMG_aFormhandles, hWnd )

  IF i > 0

    FOR x := 1 TO LEN( _HMG_aFormGraphTasks[i] )
      Eval ( _HMG_aFormGraphTasks[i][x] )
    NEXT x

    DefWindowProc( hWnd, nMsg, wParam, lParam )

    _DoWindowEventProcedure( _HMG_aFormPaintProcedure[i], i, '' )

    RETURN 1
  ENDIF

***********************************************************************
CASE nMsg == WM_LBUTTONDOWN
***********************************************************************

  _HMG_MouseRow := HiWord( lParam )
  _HMG_MouseCol := LoWord( lParam )

  i := ASCAN( _HMG_aFormhandles, hWnd )

  IF i > 0

    IF _hmg_aformvirtualheight[i] > 0
      _HMG_MouseRow := _HMG_MouseRow + GetScrollPos( hwnd, SB_VERT )
    ENDIF

    IF _hmg_aformvirtualwidth[i] > 0
      _HMG_MouseCol := _HMG_MouseCol + GetScrollPos(hwnd,SB_HORZ)
    ENDIF

    _DoWindowEventProcedure( _HMG_aFormClickProcedure[i], i, '' )
  ENDIF

***********************************************************************
CASE nMsg == WM_LBUTTONUP
***********************************************************************

***********************************************************************
CASE nMsg == WM_MOUSEMOVE
***********************************************************************

  _HMG_MouseRow := HiWord( lParam )
  _HMG_MouseCol := LoWord( lParam )

  i := ASCAN( _HMG_aFormhandles, hWnd )
  IF i > 0

    IF _hmg_aformvirtualheight[i] > 0
      _HMG_MouseRow := _HMG_MouseRow + GetScrollPos( hwnd, SB_VERT )
    ENDIF

    IF _hmg_aformvirtualwidth[i] > 0
      _HMG_MouseCol := _HMG_MouseCol + GetScrollPos(hwnd,SB_HORZ)
    ENDIF

    IF wParam == MK_LBUTTON
      _DoWindowEventProcedure( _HMG_aFormMouseDragProcedure[i], i, '' )
    ELSE
      _DoWindowEventProcedure( _HMG_aFormMouseMoveProcedure[i], i, '' )
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_CONTEXTMENU
***********************************************************************

  IF _HMG_ShowContextMenus == .T.

    _HMG_MouseRow := HiWord( lParam )
    _HMG_MouseCol := LoWord( lParam )

    SetFocus( wParam )

    i := ASCAN( _HMG_aFormhandles, hWnd )
    IF i > 0
      IF _HMG_aFormContextMenuHandle[i] != 0
        IF _hmg_aformvirtualheight[i] > 0
          _HMG_MouseRow := _HMG_MouseRow + GetScrollPos( hwnd, SB_VERT )
        ENDIF
        IF _hmg_aformvirtualwidth[i] > 0
          _HMG_MouseCol := _HMG_MouseCol + GetScrollPos(hwnd,SB_HORZ)
        ENDIF
        TrackPopupMenu ( _HMG_aFormContextMenuHandle[i], LoWord( lParam ), HiWord( lParam ), hWnd )
      ENDIF
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_TIMER
***********************************************************************

  i := ASCAN( _HMG_aControlIds, wParam )

  IF i > 0
    _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
  ENDIF

***********************************************************************
CASE nMsg == WM_SIZE
***********************************************************************

  ControlCount  := LEN(_HMG_aControlHandles)

  i := ASCAN( _HMG_aFormHandles, hWnd )

  IF i > 0
    hws := 0
    IF _HMG_aFormReBarHandle[i] > 0
      SizeRebar ( _HMG_aFormReBarHandle[i] )
      hws := RebarHeight ( _HMG_aFormReBarHandle[i] )
      RedrawWindow  ( _HMG_aFormReBarHandle[i] )
    ENDIF
    FOR x := 1 TO ControlCount
      IF _HMG_aControlParentHandles[x] == hWnd
        IF _HMG_aControlType[x] == 'MESSAGEBAR'
          MoveWindow( _HMG_aControlHandles[x], 0, 0, 0, 0, .T. )
          RefreshItemBar ( _HMG_aControlHandles[x], _GetStatusItemWidth( hWnd, 1 ) )
          EXIT
        ENDIF
      ENDIF
    NEXT i

    IF _HMG_MainClientMDIHandle != 0
      IF wParam != SIZE_MINIMIZED
        SizeClientWindow( hWnd, _HMG_ActiveStatusHandle, _HMG_MainClientMDIHandle, hws )
      ENDIF
    ENDIF

    IF _HMG_MainActive == .T.
      IF wParam == SIZE_MAXIMIZED
        _DoWindowEventProcedure( _HMG_aFormMaximizeProcedure[i], i, '' )

      ELSEIF wParam == SIZE_MINIMIZED
        _DoWindowEventProcedure( _HMG_aFormMinimizeProcedure[i], i, '' )

      ELSEIF wParam == SIZE_RESTORED .AND. !IsWindowSized( hWnd )
        _DoWindowEventProcedure( _HMG_aFormRestoreProcedure[i], i, '' )

      ELSE
        _DoWindowEventProcedure( _HMG_aFormSizeProcedure[i], i, '' )
      ENDIF
    ENDIF
  ENDIF

  FOR i := 1 TO ControlCount
    IF _HMG_aControlParentHandles[i] == hWnd
      IF _HMG_aControlType[i] == 'TOOLBAR'
        SendMessage( _HMG_aControlHandles[i], TB_AUTOSIZE, 0, 0 )
      ENDIF
    ENDIF
  NEXT i
  RETURN (1)

***********************************************************************
CASE nMsg == WM_COMMAND
***********************************************************************

  ControlCount := LEN(_HMG_aControlHandles)

  *...............................................
  * Search Control From Received Id LoWord( wParam )
  *...............................................
  i := ASCAN( _HMG_aControlIds, LoWord( wParam ))
  IF i > 0

    * Process Menus .......................................
    IF HiWord( wParam ) == 0 .AND. _HMG_aControlType[i] == 'MENU'
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      RETURN 0
    ENDIF

    * Process ToolBar Buttons ............................
    IF _HMG_aControlType[i] == 'TOOLBUTTON'
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      RETURN 0
    ENDIF
  ENDIF

  *..............................................
  * Search Control From Received Handle ( lParam )
  *..............................................
  i := ASCAN( _HMG_aControlhandles, lParam )

  * If handle Not Found, Look For Spinner
  IF i == 0
    FOR x := 1 TO ControlCount
      IF VALTYPE(_HMG_aControlHandles[x]) == 'A'
        IF _HMG_aControlHandles[x][1] == lParam .AND. _HMG_aControlType[x] == 'SPINNER'
          i := x
          EXIT
        ENDIF
      ENDIF
    NEXT x
  ENDIF

  *................................
  * Process Command (Handle based)
  *................................
  IF ( i > 0 )

    * Button Click ........................................
    IF HiWord( wParam ) == BN_CLICKED .AND. _HMG_aControlType[i] $ 'OBUTTON'
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      RETURN 0
    ENDIF

    * CheckBox Click ......................................
    IF HiWord( wParam ) == BN_CLICKED .AND. _HMG_aControlType[i] == 'CHECKBOX'
      _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
      RETURN 0
    ENDIF

    * Label / HyperLink / Image Click .....................
    IF HiWord ( wParam ) == STN_CLICKED .AND. ( _HMG_aControlType[i] == 'LABEL' .OR. _HMG_aControlType[i] == 'HYPERLINK' ;
        .OR. _HMG_aControlType[i] == 'IMAGE' )
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      RETURN 0
    ENDIF

    * TextBox Change ......................................
    IF HiWord ( wParam ) == EN_CHANGE
      IF _HMG_DateTextBoxActive == .T.
        _HMG_DateTextBoxActive := .F.
      ELSE
        IF LEN(_HMG_aControlInputMask[i] ) > 0

          IF _HMG_aControlType[i] == 'MASKEDTEXT'
            IF _HMG_aControlSpacing[i] == .T.
              ProcessCharmask ( i, .T. )
            ENDIF
            _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )

          ELSEIF _HMG_aControlType[i] == 'CHARMASKTEXT'
            ProcessCharMask (i)
            _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
          ENDIF
        ELSE
          IF _HMG_aControlType[i] == 'NUMTEXT'
            ProcessNumText ( i )
          ENDIF
          _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
        ENDIF
      ENDIF
      RETURN 0
    ENDIF

    * TextBox LostFocus ...................................
    IF HiWord( wParam ) == EN_KILLFOCUS
      IF _HMG_aControlType[i] == 'MASKEDTEXT'

        _HMG_aControlSpacing[i] := .F.

        IF "E" $ _HMG_aControlPageMap[i]
          Ts := GetWindowText ( _HMG_aControlHandles[i] )

          IF "." $ _HMG_aControlPageMap[i]
            DO CASE
            CASE AT( '.', Ts ) > AT( ',', Ts )
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlHandles[i] ), i ), ;
                _HMG_aControlPageMap[i] ))
            CASE AT( ',', Ts ) > AT( '.', Ts )
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromTextSp ( GetWindowText ( _HMG_aControlHandles[i] ), i ), ;
                _HMG_aControlPageMap[i] ))
            ENDCASE
          ELSE
            DO CASE
            CASE AT( '.', Ts ) != 0
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromTextSp ( GetWindowText ( _HMG_aControlHandles[i] ), i ), ;
                _HMG_aControlPageMap[i] ))
            CASE AT( ',', Ts )  != 0
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlHandles[i] ), i ), ;
                _HMG_aControlPageMap[i] ))
            OTHERWISE
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlHandles[i] ), i ), ;
                _HMG_aControlPageMap[i] ))
            ENDCASE
          ENDIF
        ELSE
          SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles[i] ), i ), ;
            _HMG_aControlPageMap[i] ))
        ENDIF
      ENDIF

      IF _HMG_aControlType[i] == 'CHARMASKTEXT'
        IF VALTYPE( _HMG_aControlHeadCLick[i] ) == 'L'
          IF _HMG_aControlHeadCLick[i] == .T.
            _HMG_DateTextBoxActive := .T.
            SetWindowText ( _HMG_aControlHandles[i], dtoc ( ctod ( GetWindowText ( _HMG_aControlhandles[i] ))))
          ENDIF
        ENDIF
      ENDIF

      IF _HMG_InteractiveCloseStarted != .T.
        _DoControlEventProcedure( _HMG_aControlLostFocusProcedure[i], i )
      ENDIF
      RETURN 0
    ENDIF

    * TextBox GotFocus ....................................
    IF HiWord( wParam ) == EN_SetFocus
      IF _HMG_aControlType[i] == 'MASKEDTEXT'

        IF "E" $ _HMG_aControlPageMap[i]

          Ts := GetWindowText ( _HMG_aControlHandles[i] )

          IF "." $ _HMG_aControlPageMap[i]
            DO CASE
            CASE AT( '.', Ts ) >  AT( ',', Ts )
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles[i] ), i ), ;
                _HMG_aControlInputMask[i] ))
            CASE AT( ',', Ts ) > AT( '.', Ts )
              TmpStr := Transform ( GetNumFromTextSP ( GetWindowText ( _HMG_aControlhandles[i] ), i ), _HMG_aControlInputMask[i] )
              IF Val ( TmpStr ) == 0
                TmpStr := StrTran ( TmpStr, '0.', ' .' )
              ENDIF
              SetWindowText ( _HMG_aControlhandles[i], TmpStr )
            ENDCASE
          ELSE
            DO CASE
            CASE AT( '.', Ts ) != 0
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromTextSP ( GetWindowText ( _HMG_aControlhandles[i] ), i ), ;
                _HMG_aControlInputMask[i] ))
            CASE AT( ',', Ts )  != 0
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles[i] ), i ), ;
                _HMG_aControlInputMask[i] ))
            OTHERWISE
              SetWindowText ( _HMG_aControlhandles[i], Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles[i] ), i ), ;
                _HMG_aControlInputMask[i] ))
            ENDCASE
          ENDIF
        ELSE
          TmpStr := Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles[i] ), i ), _HMG_aControlInputMask[i] )

          IF Val ( TmpStr ) == 0
            TmpStr := StrTran ( TmpStr, '0.', ' .' )
          ENDIF

          SetWindowText ( _HMG_aControlhandles[i], TmpStr )
        ENDIF

        SendMessage( _HMG_aControlhandles[i], EM_SETSEL, 0, -1 )
        _HMG_aControlSpacing[i] := .T.
      ENDIF

      IF _HMG_aControlType[i] == 'CHARMASKTEXT'

        FOR x := 1 TO LEN(_HMG_aControlInputMask[i])
          *--------------------------------------------------*
          * IF IsDigit(SubStr ( _HMG_aControlInputMask[i], x, 1 )) .OR. IsAlpha(SubStr ( _HMG_aControlInputMask[i], x, 1 )) ;
          *   .OR. SubStr ( _HMG_aControlInputMask[i], x, 1 ) == '!'
          * JF: This enables 4 additional masks
          * IF IsDigit(SubStr ( _HMG_aControlInputMask[i], x, 1 )) ;
          * .OR. IsAlpha(SubStr ( _HMG_aControlInputMask[i], x, 1 )) ;
          * .OR. SubStr ( _HMG_aControlInputMask[i], x, 1 ) == '!'
          IF IsDigit( SubStr ( _HMG_aControlInputMask[i], x, 1 )) ;
            .OR. IsAlpha( SubStr ( _HMG_aControlInputMask[i], x, 1 )) ;
            .OR. SubStr ( _HMG_aControlInputMask[i], x, 1 ) $ '!~#CD'
          *------------------------------------------------*
            MaskStart := x
            EXIT
          ENDIF
        NEXT x

        IF MaskStart == 1
          SendMessage( _HMG_aControlhandles[i], EM_SETSEL, 0, -1 )
        ELSE
          SendMessage( _HMG_aControlhandles[i], EM_SETSEL, MaskStart - 1, -1 )
        ENDIF
      ENDIF

      _DoControlEventProcedure( _HMG_aControlGotFocusProcedure[i], i )

      RETURN 0
    ENDIF

    * ListBox OnChange ....................................
    IF HiWord( wParam ) == LBN_SELCHANGE .AND. (_HMG_aControlType[i] == 'LIST' .OR. _HMG_aControlType[i] == 'MULTILIST' )
      _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
      RETURN 0
    ENDIF

    * ListBox Double Click ................................
    IF HiWord( wParam ) == LBN_DBLCLK
      _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
      RETURN 0
    ENDIF

    * ComboBox Change .....................................
    IF HiWord( wParam ) == CBN_SELCHANGE .AND. _HMG_aControlType[i] == 'COMBO'
      _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
      RETURN 0
    ENDIF

    * Button LostFocus ....................................
    IF HiWord( wParam ) == BN_KILLFOCUS .AND. _HMG_aControlType[i] != 'COMBO'
      _DoControlEventProcedure( _HMG_aControlLostFocusProcedure[i], i )
      RETURN 0
    ENDIF

    * Button GotFocus .....................................
    IF HiWord( wParam ) == BN_SETFOCUS
      _DoControlEventProcedure( _HMG_aControlGotFocusProcedure[i], i )
      RETURN 0
    ENDIF

    * ComboBox LostFocus ..................................
    IF HiWord( wParam ) == CBN_KILLFOCUS .AND. _HMG_aControlType[i] == 'COMBO'
      _DoControlEventProcedure( _HMG_aControlLostFocusProcedure[i], i )
      RETURN 0
    ENDIF

    * ComboBox GotFocus ...................................
    IF HiWord( wParam ) == CBN_SETFOCUS  .AND. _HMG_aControlType[i] == 'COMBO'
      _DoControlEventProcedure( _HMG_aControlGotFocusProcedure[i], i )
      RETURN 0
    ENDIF

    * ListBox LostFocus ...................................
    IF HiWord( wParam ) == LBN_KILLFOCUS .AND. ( _HMG_aControlType[i] == 'LIST' .OR. _HMG_aControlType[i] == 'MULTILIST')
      _DoControlEventProcedure( _HMG_aControlLostFocusProcedure[i], i )
      RETURN 0
    ENDIF

    * ListBox GotFocus ....................................
    IF HiWord( wParam ) == LBN_SETFOCUS .AND. ( _HMG_aControlType[i] == 'LIST' .OR. _HMG_aControlType[i] == 'MULTILIST')
      _DoControlEventProcedure( _HMG_aControlGotFocusProcedure[i], i )
      RETURN 0
    ENDIF

    * Process Combo Display Area Change ...................
    IF HiWord( wParam ) == CBN_EDITCHANGE .AND. _HMG_aControlType[i] == 'COMBO'
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      RETURN 0
    ENDIF

    * Process Richedit Area Change ........................
    IF HiWord( wParam ) == EN_VSCROLL  .AND. ( _HMG_aControlType[i] == 'RICHEDIT' )
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      RETURN 0
    ENDIF

    IF HiWord( wParam ) == EN_UPDATE  .AND. ( _HMG_aControlType[i] == 'RICHEDIT' )
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      RETURN 0
    ENDIF
  ELSE

    * Process RadioGrop ...................................
    IF HiWord( wParam ) == BN_CLICKED
      FOR i := 1 TO ControlCount
        IF VALTYPE(_HMG_aControlHandles[i] ) == "A" .AND._HMG_aControlParentHandles[i] == hWnd
          FOR x := 1 TO LEN( _HMG_aControlHandles[i] )
            IF _HMG_aControlhandles[i][x] == lParam
              _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
              IF _HMG_aControlPicture[i] == .F.      // No TabStop
                IF IsTabStop(_HMG_aControlhandles[i][x])
                  SetTabStop(_HMG_aControlhandles[i][x],.F.)
                ENDIF
              ENDIF
              RETURN 0
            ENDIF
          NEXT x
        ENDIF
      NEXT i
    ENDIF
  ENDIF

  *...................
  * Process Enter Key
  *...................
  i := ASCAN( _HMG_aControlhandles, GetFocus())

  IF i > 0

    * ButtonEx Enter ........................................
    IF _HMG_aControlType[i] == 'OBUTTON' .AND. HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      IF _HMG_ExtendedNavigation == .T.
        _SetNextFocus()
      ENDIF
      RETURN 0
    ENDIF

    * DatePicker or TimePicker Enter .........................
    IF (_HMG_aControlType[i] == 'DATEPICK' .OR. _HMG_aControlType[i] == 'TIMEPICK') .AND. ( HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1 )
      _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
      IF _HMG_ExtendedNavigation == .T.
        _SetNextFocus()
      ENDIF
      RETURN 0
    ENDIF

    * Browse Enter ..........................................
    IF _HMG_aControlType[i] == 'BROWSE' .AND. lparam == 0 .AND. wparam == 1

      IF _hmg_acontrolmiscdata1[i][6] == .T.
        IF _HMG_aControlFontColor[i] == .T.
          ProcessInPlaceKbdEdit(i)
        ELSE
          _BrowseEdit ( _hmg_acontrolhandles[i], _HMG_acontrolmiscdata1[i][4], _HMG_acontrolmiscdata1[i][5], _HMG_acontrolmiscdata1[i][3], ;
            _HMG_aControlInputMask[i], .F., _HMG_aControlFontColor[i] )
        ENDIF
      ELSE
        _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
      ENDIF

      RETURN 0
    ENDIF

    * Grid Enter ..........................................
    IF ( _HMG_aControlType[i] == 'GRID' .OR. _HMG_aControlType[i] == 'MULTIGRID') .AND. lparam == 0 .AND. wparam == 1
      IF _hmg_acontrolspacing[i] == .T.
        IF __MVGET ( '_HMG_' + ALLTRIM(STR(_HMG_aControlhandles[i])) + '_INPLACE' ) == .T.
          _GridInplaceKBDEdit ( i )
        ELSE
          _EditItem ( _hmg_acontrolhandles[i] )
        ENDIF
      ELSE
        _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
      ENDIF
      RETURN 0
    ENDIF

    * ComboBox Enter ......................................
    IF _HMG_aControlType[i] == 'COMBO' .AND. ( HiWord( wParam ) == 0  .AND. LoWord( wParam ) == 1 )
      _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
      IF _HMG_ExtendedNavigation == .T.
        _SetNextFocus()
      ENDIF
      RETURN 0
    ENDIF

    * ListBox Enter .......................................
    IF ( _HMG_aControlType[i] == 'LIST' .OR. _HMG_aControlType[i] == 'MULTILIST' ) .AND. ( HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1 )
      _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
      RETURN 0
    ENDIF

    * TextBox Enter .......................................
    IF ( _HMG_aControlType[i] == 'TEXT' .OR. _HMG_aControlType[i] == 'MASKEDTEXT' .OR. _HMG_aControlType[i] == 'CHARMASKTEXT' ;
        .OR. _HMG_aControlType[i] == 'NUMTEXT' ) .AND. HiWord( wParam ) == 0  .AND. LoWord( wParam ) == 1
      _HMG_SetFocusExecuted := .F.
      _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
      IF _HMG_SetFocusExecuted == .F.
        IF _HMG_ExtendedNavigation == .T.
          _SetNextFocus()
        ENDIF
      ELSE
        _HMG_SetFocusExecuted := .F.
      ENDIF
      RETURN 0
    ENDIF

    * Tree Enter ..........................................
    IF _HMG_aControlType[i] == "TREE" .AND. HiWord( wParam ) == 0  .AND. LoWord( wParam ) == 1
      _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
      RETURN 0
    ENDIF
  ELSE

    * ComboBox (DisplayEdit) ..............................
    FOR i := 1 TO ControlCount

      IF _HMG_aControlType[i] == 'COMBO' .AND. ( HiWord( wParam ) == 0  .AND. LoWord( wParam ) == 1 )
        IF _hmg_acontrolrangemin[i] == GetFocus() .OR. _hmg_acontrolrangemax[i] == GetFocus()
          _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
          IF _HMG_ExtendedNavigation == .T.
            _SetNextFocus()
          ENDIF
          EXIT
        ENDIF
      ENDIF
    NEXT i

    RETURN 0
  ENDIF

***********************************************************************
CASE nMsg == WM_NOTIFY
***********************************************************************

  * Process ToolBar ToolTip .....................................
  IF GetNotifyCode ( lParam ) == TTN_NEEDTEXT        // for tooltip TOOLBUTTON
    ws := GetNotifyId( lParam)
    x  := ASCAN( _HMG_aControlIds, ws )
    IF ( x > 0 ) .AND. _HMG_aControlType[x] == 'TOOLBUTTON'
      SetButtonTip ( lParam, _HMG_aControlToolTip[x] )
    ENDIF
  ENDIF

  IF GetNotifyCode ( lParam ) == RBN_CHEVRONPUSHED   // Notify for chevron button
    _CreatePopUpChevron ( hWnd, wParam, lParam )
  ENDIF

  i := ASCAN( _HMG_aControlHandles, GetHwndFrom ( lParam ))
  IF i > 0

    * Process Browse .....................................
    IF _HMG_aControlType[i] == 'BROWSE'

      dBc := _HMG_aControlMiscData1 [i] [10]
      dFc := _HMG_aControlMiscData1 [i] [ 9]

      IF GetNotifyCode ( lParam ) == NM_CUSTOMDRAW .AND. ( VALTYPE(dBc) == 'A' .OR. VALTYPE(dFc) == 'A' )
        IF ( r := GetDs ( lParam )) <> -1
          RETURN r
        ELSE
          a := GetRc ( lParam )

          IF a[1] >= 1 .AND. a[1] <= LEN( _HMG_aControlRangeMax[i] )  ;  // MaxBrowseRows
            .AND. a[2] >= 1 .AND. a[2] <= LEN( _HMG_aControlRangeMin[i] )  // MaxBrowseCols

            aTemp  := _HMG_aControlMiscData1 [i] [18]
            aTemp2 := _HMG_aControlMiscData1 [i] [17]

            IF VALTYPE( aTemp ) == 'A' .AND. VALTYPE( aTemp2 ) <> 'A'
              IF LEN( aTemp ) >= a[1]
                IF aTemp[a[1]][a[2]] <> -1
                  RETURN SetBcBc ( lParam, aTemp[a[1]][a[2]], RGB(0, 0, 0))
                ELSE
                  RETURN SETBRCCD( lParam )
                ENDIF
              ENDIF
            ELSEIF VALTYPE( aTemp ) <> 'A' .AND. VALTYPE( aTemp2 ) == 'A'
              IF LEN( aTemp2 ) >= a[1]
                IF aTemp2[a[1]][a[2]] <> -1
                  RETURN SetBcBc ( lParam, RGB(255, 255, 255), aTemp2[a[1]][a[2]] )
                ELSE
                  RETURN SETBRCCD( lParam )
                ENDIF
              ENDIF
            ELSEIF VALTYPE( aTemp ) == 'A' .AND. VALTYPE( aTemp2 ) == 'A'
              IF LEN( aTemp ) >= a[1] .AND. LEN( aTemp2 ) >= a[1]
                IF aTemp[a[1]][a[2]] <> -1
                  RETURN SetBcBc ( lParam, aTemp[a[1]][a[2]], aTemp2[a[1]][a[2]] )
                ELSE
                  RETURN SETBRCCD( lParam )
                ENDIF
              ENDIF
            ENDIF
          ELSE
            RETURN SETBRCCD( lParam )
          ENDIF
        ENDIF
      ENDIF

      * Browse Click ................................
      IF GetNotifyCode ( lParam ) == NM_CLICK .OR. GetNotifyCode ( lParam ) == LVN_BEGINDRAG

        IF LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles[i] ) > 0
          DeltaSelect := LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles[i] ) - ASCAN( _HMG_aControlRangeMax[i], _HMG_aControlValue[i] )
          _HMG_aControlValue[i] := _HMG_aControlRangeMax[i][ LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles[i] ) ]
          _BrowseVscrollFastUpdate ( i, DeltaSelect )
          _BrowseOnChange (i)
        ENDIF

        *----------------------------------------------------*
        * Changed JF 108e to enable incremental search
        * RETURN 0
        RETURN ClearSearch( 0 )                      // resets cSearchKey to ""
        *----------------------------------------------------*
      ENDIF

      * Browse Refresh On Column Size ..............
      IF GetNotifyCode ( lParam ) == -12
        hws := 0
        hwm := .F.
        FOR x := 1 TO LEN( _HMG_aControlProcedures[i] )
          hws := hws + ListView_GetColumnWidth ( _HMG_aControlHandles[i], x - 1 )
          IF _HMG_aControlProcedures[i][x] != ListView_GetColumnWidth ( _HMG_aControlHandles[i], x - 1 )
            hwm := .T.
            _HMG_aControlProcedures[i][x] := ListView_GetColumnWidth ( _HMG_aControlHandles[i], x - 1 )
            _BrowseRefresh( '', '', i )
          ENDIF
        NEXT x

        * Browse ReDraw Vertical ScrollBar if needed ...
        IF _HMG_aControlIds[i] != 0 .AND. hwm == .T.
          IF hws > _HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() - 4
            MoveWindow( _HMG_aControlIds[i], _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH(), ;
              _HMG_aControlRow[i], GETVSCROLLBARWIDTH(), _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT(), .T. )
            MoveWindow( _HMG_aControlMiscData1[i][1], _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH(), ;
              _HMG_aControlRow[i] + _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT(), GETVSCROLLBARWIDTH(), GETHSCROLLBARHEIGHT(), .T. )
          ELSE
            MoveWindow( _HMG_aControlIds[i], _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH(), ;
              _HMG_aControlRow[i], GETVSCROLLBARWIDTH(), _HMG_aControlHeight[i], .T. )
            MoveWindow( _HMG_aControlMiscData1[i][1], _HMG_aControlCol[i]+_HMG_aControlWidth[i] - GETVSCROLLBARWIDTH(), ;
              _HMG_aControlRow[i] + _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT(), 0, 0, .T. )
          ENDIF
        ENDIF

        RETURN 0
      ENDIF

      * Browse Key Handling .........................
      IF GetNotifyCode ( lParam ) == LVN_KEYDOWN
        DO CASE

        *--------------------------------------------------*
        * Changed JF 108e: I don't want to screen out all 'A' keypresses unless they are Alt-A
        * CASE GetGridvKey( lParam ) == 65 // A
        *   IF GetAltState() == -127 .OR. GetAltState() == -128 // ALT
        *     IF _HMG_acontrolmiscdata1[i][2] == .T.
        *       _BrowseEdit ( _hmg_acontrolhandles[i], _HMG_acontrolmiscdata1[i][4], _HMG_acontrolmiscdata1[i][5], ;
        *         _HMG_acontrolmiscdata1[i][3], _HMG_aControlInputMask[i], .T., _HMG_aControlFontColor[i] )
        *     ENDIF
        *   ENDIF
        CASE GetGridvKey( lParam ) == 65 ;           // A
          .AND. ( GetAltState() == -127 .OR. GetAltState() == -128 )  // ALT-A
          IF _HMG_acontrolmiscdata1[i][2] == .T.
            _BrowseEdit( _hmg_acontrolhandles[i], _HMG_acontrolmiscdata1[i][4], ;
              _HMG_acontrolmiscdata1[i][5], _HMG_acontrolmiscdata1[i][3], ;
              _HMG_aControlInputMask[i], .T., _HMG_aControlFontColor[i] )
          ENDIF
        *--------------------------------------------------*

        CASE GetGridvKey( lParam ) == 46               // DEL
          IF _HMG_aControlMiscData1[i][12] == .T.
            IF MsgYesNo (_HMG_BRWLangMessage[1], _HMG_BRWLangMessage[2] ) == .T.
              _BrowseDelete( '', '', i )
            ENDIF
          ENDIF

        CASE GetGridvKey( lParam ) == 36               // HOME
          _BrowseHome( '', '', i )
          *--------------------------------------------------*
          * Changed JF 108e to enable incremental search
          * RETURN 1
          RETURN ClearSearch( 1 )                    // resets cSearchKey to ""
          *--------------------------------------------------*

        CASE GetGridvKey( lParam ) == 35               // END
          _BrowseEnd( '', '', i )
          *--------------------------------------------------*
          * Changed JF 108e to enable incremental search
          * RETURN 1
          RETURN ClearSearch( 1 )                    // resets cSearchKey to ""
          *--------------------------------------------------*

        CASE GetGridvKey( lParam ) == 33               // PGUP
          _BrowsePrior( '', '', i )
          *--------------------------------------------------*
          * Changed JF 108e to enable incremental search
          * RETURN 1
          RETURN ClearSearch( 1 )                    // resets cSearchKey to ""
          *--------------------------------------------------*

        CASE GetGridvKey( lParam ) == 34               // PGDN
          _BrowseNext( '', '', i )
          *--------------------------------------------------*
          * Changed JF 108e to enable incremental search
          * RETURN 1
          RETURN ClearSearch( 1 )                    // resets cSearchKey to ""
          *--------------------------------------------------*

        CASE GetGridvKey( lParam ) == 38               // UP
          _BrowseUp( '', '', i )
          *--------------------------------------------------*
          * Changed JF 108e to enable incremental search
          * RETURN 1
          RETURN ClearSearch( 1 )                    // resets cSearchKey to ""
          *--------------------------------------------------*

        CASE GetGridvKey( lParam ) == 40               // DOWN
          _BrowseDown( '', '', i )
          *--------------------------------------------------*
          * Changed JF 108e to enable incremental search
          * RETURN 1
          RETURN ClearSearch( 1 )                    // resets cSearchKey to ""
          *--------------------------------------------------*

          *--------------------------------------------------*
        * Added JF 108e to enable incremental search
        CASE lIncremental == .T.
          RETURN IncrementalSearch( GetGridvKey( lParam ), i )
          *--------------------------------------------------*
        ENDCASE

        *----------------------------------------------------*
        * Changed JF 108e to enable incremental search
        * RETURN 0
        RETURN ClearSearch( 0 )                      // resets cSearchKey to ""
        *----------------------------------------------------*
      ENDIF

      * Browse Double Click .........................
      IF GetNotifyCode ( lParam ) == NM_DBLCLK

        _PushEventInfo()
        _HMG_ThisFormIndex := ASCAN( _HMG_aFormHandles, _HMG_aControlParentHandles[i] )
        _HMG_ThisType := 'C'
        _HMG_ThisIndex := i
        _HMG_ThisFormName := _HMG_aFormNames[ _HMG_ThisFormIndex ]
        _HMG_ThisControlName := _HMG_aControlNames[_HMG_THISIndex]

        r := ListView_HitTest ( _HMG_aControlHandles[i], GetCursorRow() - GetWindowRow ( _HMG_aControlHandles[i] ), ;
          GetCursorCol() - GetWindowCol ( _HMG_aControlHandles[i] ))
        IF r[2] == 1
          ListView_Scroll( _HMG_aControlHandles[i], -10000, 0 )
          r := ListView_HitTest ( _HMG_aControlHandles[i], GetCursorRow() - GetWindowRow ( _HMG_aControlHandles[i] ), ;
            GetCursorCol() - GetWindowCol ( _HMG_aControlHandles[i] ))
        ELSE
          r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles[i], r[1] - 1, r[2] - 1 )
          *                                                              CellCol              CellWidth
          xs := (( _HMG_aControlCol[i] + r[2] ) +( r[3] )) - ( _HMG_aControlCol[i] + _HMG_aControlWidth[i] )
          xd := 20
          IF xs > -xd
            ListView_Scroll( _HMG_aControlHandles[i], xs + xd, 0 )
          ELSE
            IF r[2] < 0
              ListView_Scroll( _HMG_aControlHandles[i], r[2], 0 )
            ENDIF
          ENDIF
          r := ListView_HitTest ( _HMG_aControlHandles[i], GetCursorRow() - GetWindowRow ( _HMG_aControlHandles[i] ), ;
            GetCursorCol() - GetWindowCol ( _HMG_aControlHandles[i] ))
        ENDIF

        _HMG_ThisItemRowIndex := r[1]
        _HMG_ThisItemColIndex := r[2]
        IF r[2] == 1
          r := LISTVIEW_GETITEMRECT ( _HMG_aControlHandles[i], r[1] - 1 )
        ELSE
          r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles[i], r[1] - 1, r[2] - 1 )
        ENDIF
        _HMG_ThisItemCellRow := _HMG_aControlRow[i] + r[1]
        _HMG_ThisItemCellCol := _HMG_aControlCol[i] + r[2]
        _HMG_ThisItemCellWidth := r[3]
        _HMG_ThisItemCellHeight := r[4]

        IF _hmg_acontrolmiscdata1[i][6] == .T.
          _BrowseEdit ( _hmg_acontrolhandles[i], _HMG_acontrolmiscdata1[i][4], _HMG_acontrolmiscdata1[i][5], ;
            _HMG_acontrolmiscdata1[i][3], _HMG_aControlInputMask[i], .F., _HMG_aControlFontColor[i] )
        ELSE
          IF VALTYPE( _HMG_aControlDblClick[i] ) == 'B'
            Eval( _HMG_aControlDblClick[i]  )
          ENDIF
        ENDIF

        _PopEventInfo()
        _HMG_ThisItemRowIndex := 0
        _HMG_ThisItemColIndex := 0
        _HMG_ThisItemCellRow := 0
        _HMG_ThisItemCellCol := 0
        _HMG_ThisItemCellWidth := 0
        _HMG_ThisItemCellHeight := 0
      ENDIF

      * Browse LostFocus ............................
      IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
        _DoControlEventProcedure( _HMG_aControlLostFocusProcedure[i], i )
        RETURN 0
      ENDIF

      * Browse GotFocus ..............................
      IF GetNotifyCode ( lParam ) == NM_SETFOCUS
        _DoControlEventProcedure( _HMG_aControlGotFocusProcedure[i], i )
        RETURN 0
      ENDIF

      * Browse Header Click .........................
      IF GetNotifyCode ( lParam ) == LVN_COLUMNCLICK
        IF VALTYPE( _HMG_aControlHeadClick[i] ) == 'A'
          lvc := GetGridColumn( lParam ) + 1
          IF LEN(_HMG_aControlHeadClick[i]) >= lvc
            _DoControlEventProcedure( _HMG_aControlHeadClick[i][lvc], i )
          ENDIF
        ENDIF
        RETURN 0
      ENDIF
    ENDIF

    * ToolBar DropDown Button Click .......................
    IF GetNotifyCode ( lParam ) == TBN_DROPDOWN

      DefWindowProc( hWnd, TBN_DROPDOWN, wParam, lParam )
      ws := GetButtonPos( lParam)
      x  := ASCAN( _HMG_aControlIds, ws )
      k  :=_HMG_aControlValue[x]
      IF ( x > 0 ) .AND. _HMG_aControlType[x] == 'TOOLBUTTON'
        aPos := {0,0,0,0}
        GetWindowRect(_HMG_aControlHandles[i], aPos)
        ws := GetButtonBarRect(_HMG_aControlHandles[i], k-1 )
        TrackPopupMenu ( _HMG_aControlRangeMax[x], aPos[1]+LoWord(ws), aPos[2]+HiWord(ws) + (aPos[4]-aPos[2]-HiWord(ws))/2+1, hWnd )
      ENDIF

      RETURN 0
    ENDIF

    * RichEdit Selection Change ......................
    IF _HMG_aControlType[i] == 'RICHEDIT'

      IF GetNotifyCode ( lParam ) == EN_MSGFILTER    // for typing text
        IF VALTYPE(_HMG_aControlChangeProcedure[i]  )=='B'
          _HMG_ThisType := 'C'
          _HMG_ThisIndex := i
          Eval( _HMG_aControlChangeProcedure[i]  )
          _HMG_ThisIndex := 0
          _HMG_ThisType := ''
        ENDIF
      ENDIF
      IF GetNotifyCode ( lParam ) == EN_DRAGDROPDONE  //For change text by drag
        IF VALTYPE( _HMG_aControlChangeProcedure[i] )=='B'
          _HMG_ThisType := 'C'
          _HMG_ThisIndex := i
          Eval( _HMG_aControlChangeProcedure[i]  )
          _HMG_ThisIndex := 0
          _HMG_ThisType := ''
        ENDIF
      ENDIF
      IF GetNotifyCode ( lParam ) == EN_SELCHANGE    //For change text
        IF VALTYPE(_HMG_aControlDblClick[i]  )=='B'
          _HMG_ThisType := 'C'
          _HMG_ThisIndex := i
          Eval( _HMG_aControlDblClick[i]  )
          _HMG_ThisIndex := 0
          _HMG_ThisType := ''
        ENDIF
      ENDIF
    ENDIF

    * MonthCalendar Selection Change ......................
    IF _HMG_aControlType[i] == 'MONTHCAL'
      IF GetNotifyCode ( lParam ) == MCN_SELECT
        _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
        RETURN 0
      ENDIF
    ENDIF

    * Grid Processing .....................................

      If _HMG_aControlType [i] $ "MULTIGRID"

         If _HMG_aControlFontColor [i] == .T.

		* Grid Key Handling .........................

		If GetNotifyCode ( lParam ) = LVN_KEYDOWN

			Switch GetGridvKey(lParam)
			Case 37 // LEFT
				IF _HMG_aControlMiscData1 [i] [ 17 ] > 1
					_HMG_aControlMiscData1 [i] [ 17 ] --

					nFrozenColumnCount := _HMG_aControlMiscData1 [i] [ 19 ]
					If nFrozenColumnCount > 0
						nDestinationColumn := _HMG_aControlMiscData1 [i] [ 17 ]
						If nDestinationColumn >= nFrozenColumnCount + 1
							aOriginalColumnWidths := _HMG_aControlMiscData1 [i] [ 2 ]
							* Set Destination Column Width To Original
							LISTVIEW_SETCOLUMNWIDTH ( _HMG_aControlHandles [i] , nDestinationColumn - 1 , aOriginalColumnWidths [ nDestinationColumn ] )
						EndIf
					EndIf

					_GRID_KBDSCROLL(i)

					LISTVIEW_REDRAWITEMS ( _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 , _HMG_aControlMiscData1 [i] [ 1 ] - 1 )
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
			Case 39 // RIGHT
				IF _HMG_aControlMiscData1 [i] [ 17 ] < Len ( _HMG_aControlCaption [i] )
					_HMG_aControlMiscData1 [i] [ 17 ] ++

					nFrozenColumnCount := _HMG_aControlMiscData1 [i] [ 19 ]
					If nFrozenColumnCount > 0
						nDestinationColumn := _HMG_aControlMiscData1 [i] [ 17 ]
						FOR k := nDestinationColumn TO LEN( _HMG_aControlCaption [ i ] ) - 1 
							IF LISTVIEW_GETCOLUMNWIDTH ( _HMG_aControlHandles [i] , k - 1 ) == 0
								_HMG_aControlMiscData1 [i] [ 17 ] ++
							ENDIF
						NEXT k

						If nDestinationColumn > nFrozenColumnCount + 1
							* Set Current Column Width To 0
							LISTVIEW_SETCOLUMNWIDTH ( _HMG_aControlHandles [i] , nDestinationColumn - 2 , 0 )
						EndIf
					EndIf

					_GRID_KBDSCROLL(i)

					LISTVIEW_REDRAWITEMS ( _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 , _HMG_aControlMiscData1 [i] [ 1 ] - 1 )
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
			Case 38 // UP
				IF _HMG_aControlMiscData1 [i] [ 17 ] == 0
					_HMG_aControlMiscData1 [i] [ 17 ] := 1
				ENDIF
                                IF _HMG_aControlMiscData1 [i] [ 1 ] > 1
					_HMG_aControlMiscData1 [i] [ 1 ] --
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
			Case 40 // DOWN
				IF _HMG_aControlMiscData1 [i] [ 17 ] == 0
					_HMG_aControlMiscData1 [i] [ 17 ] := 1
				ENDIF
                                IF _HMG_aControlMiscData1 [i] [ 1 ] < SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )
					_HMG_aControlMiscData1 [i] [ 1 ] ++
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
			Case 33 // PGUP
				nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]

				IF _HMG_aControlMiscData1 [i] [ 1 ] == SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + 1
					_HMG_aControlMiscData1 [i] [ 1 ] -= SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 ) - 1
				ELSE
					_HMG_aControlMiscData1 [i] [ 1 ] := SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + 1
				ENDIF

				IF _HMG_aControlMiscData1 [i] [ 1 ] < 1
					_HMG_aControlMiscData1 [i] [ 1 ] := 1
				ENDIF

				IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
			Case 34 // PGDOWN
				nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]
						
				IF _HMG_aControlMiscData1 [i] [ 1 ] == SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 ) 
					_HMG_aControlMiscData1 [i] [ 1 ] += SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 ) - 1
				ELSE
					_HMG_aControlMiscData1 [i] [ 1 ] := SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 ) 
				ENDIF

				IF _HMG_aControlMiscData1 [i] [ 1 ] > SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )
					_HMG_aControlMiscData1 [i] [ 1 ] := SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )
				ENDIF

				IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
			Case 35 // END
				nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]

				_HMG_aControlMiscData1 [i] [ 1 ] := SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )

				IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
			Case 36 // HOME
				nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]

				_HMG_aControlMiscData1 [i] [ 1 ] := 1

				IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
		        	       _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
				ENDIF
				Exit
#ifndef __XHARBOUR__
			otherwise
#else
			default
#endif
				Return 1
			EndSwitch

		EndIf

         EndIf

         If GetNotifyCode ( lParam ) = NM_CUSTOMDRAW

            if ( r := iif( _HMG_aControlFontColor [i] == .T., ;
                      GetDsx ( lParam , _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 ), ;
                      GetDs ( lParam ) ) ) <> -1
               Return r
            else
               a := GetRc (lParam)
               IF _HMG_aControlFontColor [i] == .T.
                  if a [1] == _HMG_aControlMiscData1 [i] [ 1 ] .and. a [2] == _HMG_aControlMiscData1 [i] [ 17 ]
                     Return SetBcBc ( lParam , RGB( _HMG_GridSelectedCellBackColor[1] , _HMG_GridSelectedCellBackColor[2] , _HMG_GridSelectedCellBackColor[3] ) , RGB( _HMG_GridSelectedCellForeColor[1] , _HMG_GridSelectedCellForeColor[2] , _HMG_GridSelectedCellForeColor[3] ) )
                  elseif a [1] == _HMG_aControlMiscData1 [i] [ 1 ] .and. a [2] <> _HMG_aControlMiscData1 [i] [ 17 ]
                     Return SetBcBc ( lParam , RGB( _HMG_GridSelectedRowBackColor[1] , _HMG_GridSelectedRowBackColor[2] , _HMG_GridSelectedRowBackColor[3] ) , RGB( _HMG_GridSelectedRowForeColor[1] , _HMG_GridSelectedRowForeColor[2] , _HMG_GridSelectedRowForeColor[3] ) )
                  else
                     Return _DoGridCustomDraw ( i , a , lParam )
                  endif
               ELSE
                  Return _DoGridCustomDraw ( i , a , lParam )
               ENDIF
            endif

         EndIf

         If GetNotifyCode ( lParam ) = -181
            ReDrawWindow ( _hmg_acontrolhandles [i] )
         endif

         * Grid OnQueryData ............................

         If GetNotifyCode ( lParam ) = LVN_GETDISPINFO

            If Valtype( _HMG_aControlProcedures [i] ) == 'B'

               _PushEventInfo()
               _HMG_ThisFormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
               _HMG_ThisType  := 'C'
               _HMG_ThisIndex := i
               _HMG_ThisFormName       := _HMG_aFormNames [ _HMG_ThisFormIndex ]
               _HMG_ThisControlName    := _HMG_aControlNames [ _HMG_THISIndex ]
               _ThisQueryTemp := GETGRIDDISPINFOINDEX ( lParam )
               _HMG_ThisQueryRowIndex  := _ThisQueryTemp [1]
               _HMG_ThisQueryColIndex  := _ThisQueryTemp [2]

               Eval( _HMG_aControlProcedures [i] )

               If Len ( _HMG_aControlBkColor [i] ) > 0 .And. _HMG_ThisQueryColIndex == 1
                  SetGridQueryImage ( lParam , _HMG_ThisQueryData )
               Else
                  SetGridQueryData ( lParam , HB_ValToStr( _HMG_ThisQueryData ) )
               EndIf
               _HMG_ThisQueryRowIndex  := 0
               _HMG_ThisQueryColIndex  := 0
               _HMG_ThisQueryData := ""
               _PopEventInfo()

            EndIf

         EndIf

         * Grid LostFocus ..............................

         If GetNotifyCode ( lParam ) == NM_KILLFOCUS
            _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
            Return 0
         EndIf

         * Grid GotFocus ...............................

         If GetNotifyCode ( lParam ) == NM_SETFOCUS
            VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
            _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
            Return 0
         EndIf

         * Grid Change .................................

         If GetNotifyCode ( lParam ) == LVN_ITEMCHANGED
            If GetGridOldState(lParam) == 0 .and. GetGridNewState(lParam) != 0
               IF _HMG_aControlFontColor [i] == .T.
                  _HMG_aControlMiscData1 [i] [ 1 ] := LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] )
               ELSE
                  _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
               ENDIF
               Return 0
            EndIf
         EndIf

         * Grid Header Click ..........................

         If GetNotifyCode ( lParam ) == LVN_COLUMNCLICK
            if ValType ( _HMG_aControlHeadClick [i] ) == 'A'
               lvc := GetGridColumn(lParam) + 1
               if len (_HMG_aControlHeadClick [i]) >= lvc
                  _DoControlEventProcedure ( _HMG_aControlHeadClick [i] [lvc] , i , , lvc )
                  Return 0
               EndIf
            EndIf
         EndIf

         * Grid Click ...........................

         If GetNotifyCode ( lParam ) == NM_CLICK  

            IF _HMG_aControlFontColor [i] == .T.
		aCellData := _GetGridCellData(i)
		IF aCellData [2] > 0
                   _HMG_aControlMiscData1 [i] [ 17 ] := aCellData [2]
                   IF _HMG_aControlMiscData1 [i] [ 1 ] == 0
                      _HMG_aControlMiscData1 [i] [ 1 ] := aCellData [1]
                   ENDIF
                   LISTVIEW_REDRAWITEMS ( _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 , _HMG_aControlMiscData1 [i] [ 1 ] - 1 )
                   _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
		ENDIF
            ENDIF

         EndIf

         * Grid Double Click ...........................

         If GetNotifyCode ( lParam ) == NM_DBLCLK

            If _hmg_acontrolspacing [i] == .T.
               If _HMG_aControlMiscData1 [i] [20] == .T.

                  _PushEventInfo()
                  _HMG_ThisFormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
                  _HMG_ThisType := 'C'
                  _HMG_ThisIndex := i
                  _HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ]
                  _HMG_ThisControlName :=  _HMG_aControlNames [_HMG_ThisIndex]
                  aCellData := _GetGridCellData(i)

                  _HMG_ThisItemRowIndex := aCellData [1]
                  _HMG_ThisItemColIndex := aCellData [2]
                  _HMG_ThisItemCellRow := aCellData [3]
                  _HMG_ThisItemCellCol := aCellData [4]
                  _HMG_ThisItemCellWidth := aCellData [5]
                  _HMG_ThisItemCellHeight := aCellData [6]

                  _GridInplaceEdit(i)

                  _PopEventInfo()
                  _HMG_ThisItemRowIndex := 0
                  _HMG_ThisItemColIndex := 0
                  _HMG_ThisItemCellRow := 0
                  _HMG_ThisItemCellCol := 0
                  _HMG_ThisItemCellWidth := 0
                  _HMG_ThisItemCellHeight := 0

               Else
                  _EditItem ( _hmg_acontrolhandles [i] )
               EndIf
            Else

               If valtype(_HMG_aControlDblClick [i]  ) == 'B'

                  _PushEventInfo()
                  _HMG_ThisFormIndex := ascan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
                  _HMG_ThisType := 'C'
                  _HMG_ThisIndex := i
                  _HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ]
                  _HMG_ThisControlName :=  _HMG_aControlNames [_HMG_ThisIndex]
                  aCellData := _GetGridCellData(i)

                  _HMG_ThisItemRowIndex := aCellData [1]
                  _HMG_ThisItemColIndex := aCellData [2]
                  _HMG_ThisItemCellRow := aCellData [3]
                  _HMG_ThisItemCellCol := aCellData [4]
                  _HMG_ThisItemCellWidth := aCellData [5]
                  _HMG_ThisItemCellHeight := aCellData [6]

                  Eval( _HMG_aControlDblClick [i]  )

                  _PopEventInfo()
                  _HMG_ThisItemRowIndex := 0
                  _HMG_ThisItemColIndex := 0
                  _HMG_ThisItemCellRow := 0
                  _HMG_ThisItemCellCol := 0
                  _HMG_ThisItemCellWidth := 0
                  _HMG_ThisItemCellHeight := 0

               EndIf

            EndIf

            Return 0

         EndIf

      EndIf

    * DatePicker Process ..................................
    IF _HMG_aControlType[i] == 'DATEPICK' .OR. _HMG_aControlType[i] == 'TIMEPICK'

      * DatePicker Change ............................
      IF GetNotifyCode ( lParam ) == DTN_DATETIMECHANGE
        _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
        RETURN 0
      ENDIF

      * DatePicker LostFocus ........................
      IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
        _DoControlEventProcedure( _HMG_aControlLostFocusProcedure[i], i )
        RETURN 0
      ENDIF

      * DatePicker GotFocus .........................
      IF GetNotifyCode ( lParam ) == NM_SETFOCUS
        _DoControlEventProcedure( _HMG_aControlGotFocusProcedure[i], i )
        RETURN 0
      ENDIF
    ENDIF

    * Tab Processing ......................................
    IF _HMG_aControlType[i] == 'TAB'

      * Tab Change ..................................
      IF GetNotifyCode ( lParam ) == TCN_SELCHANGE
        IF LEN(_HMG_aControlPageMap[i]) > 0
          UpdateTab (i)
        ENDIF
        _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
        RETURN 0
      ENDIF
    ENDIF

    * Tree Processing .....................................
    IF _HMG_aControlType[i] == 'TREE'

      * Tree LostFocus .............................
      IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
        _DoControlEventProcedure( _HMG_aControlLostFocusProcedure[i], i )
        RETURN 0
      ENDIF

      * Tree GotFocus ..............................
      IF GetNotifyCode ( lParam ) == NM_SETFOCUS
        _DoControlEventProcedure( _HMG_aControlGotFocusProcedure[i], i )
        RETURN 0
      ENDIF

      * Tree Change ................................
      IF GetNotifyCode ( lParam ) == TVN_SELCHANGED
        _DoControlEventProcedure( _HMG_aControlChangeProcedure[i], i )
        RETURN 0
      ENDIF

      * Tree Double Click .........................
      IF GetNotifyCode ( lParam ) == NM_DBLCLK
        _DoControlEventProcedure( _HMG_aControlDblClick[i], i )
        RETURN 0
      ENDIF
    ENDIF

    * StatusBar Process ...................................
    IF _HMG_aControlType[i] == 'MESSAGEBAR'

      * StatusBar Click
      IF GetNotifyCode ( lParam ) == NM_CLICK
        DefWindowProc( hWnd, NM_CLICK, wParam, lParam )
        x := GetItemPos( lParam)
        ControlCount := LEN(_HMG_aControlHandles)
        FOR i := 1 TO ControlCount
          IF _HMG_aControlType[i] == 'ITEMMESSAGE' .AND. _HMG_aControlParentHandles[i] == hWnd
            IF _HMG_aControlHandles[i]  == x+1
              IF _DoControlEventProcedure( _HMG_aControlProcedures[i], i )
                RETURN 0
              ENDIF
            ENDIF
          ENDIF
        NEXT i
      ENDIF
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_CLOSE
***********************************************************************

  IF GetEscapeState() < 0
    RETURN (1)
  ENDIF

  i := ASCAN( _HMG_aFormhandles, hWnd )

  IF i > 0

    * Process Interactive Close Event / Setting
    IF VALTYPE( _HMG_aFormInteractiveCloseProcedure[i] ) == 'B'
      xRetVal := _DoWindowEventProcedure( _HMG_aFormInteractiveCloseProcedure[i], i, 'WINDOW_ONINTERACTIVECLOSE' )
      IF VALTYPE(xRetVal) == 'L'
        IF !xRetVal
          RETURN (1)
        ENDIF
      ENDIF
    ENDIF

    DO CASE
    CASE _HMG_InteractiveClose == 0
      MsgStop ( _HMG_MESSAGE[3] )
      RETURN (1)
    CASE _HMG_InteractiveClose == 2
      IF ! MsgYesNo ( _HMG_MESSAGE[1], _HMG_MESSAGE[2] )
        RETURN (1)
      ENDIF
    CASE _HMG_InteractiveClose == 3
      IF _HMG_aFormType[i] == 'A'
        IF ! MsgYesNo ( _HMG_MESSAGE[1], _HMG_MESSAGE[2] )
          RETURN (1)
        ENDIF
      ENDIF
    ENDCASE

    * Process AutoRelease Property
    IF _HMG_aFormAutoRelease[i] == .F.
      _HideWindow ( _HMG_aFormNames[i] )
      RETURN (1)
    ENDIF

    * If Not AutoRelease Destroy Window
    IF _HMG_aFormType[i] == 'A'
      ReleaseAllWInDows()
    ELSE
      IF VALTYPE( _HMG_aFormReleaseProcedure[i] )=='B'
        _HMG_InteractiveCloseStarted := .T.
        _DoWindowEventProcedure( _HMG_aFormReleaseProcedure[i], i, 'WINDOW_RELEASE')
      ENDIF

      _hmg_OnHideFocusManagement(i)
    ENDIF
  ENDIF

***********************************************************************
CASE nMsg == WM_DESTROY
***********************************************************************

  ControlCount  := LEN(_HMG_aControlHandles)

  i := ASCAN( _HMG_aFormhandles, hWnd )
  IF i > 0

    * Remove Child Controls
    FOR x := 1 TO ControlCount
      IF _HMG_aControlParentHandles[x] == hWnd
        _EraseControl(x,i)
      ENDIF
    NEXT x

    * Delete Brush
    DeleteObject ( _HMG_aFormBrushHandle[i] )

    * Update Form Index Variable
    mVar := '_' + _HMG_aFormNames[i]
    IF type ( mVar ) != 'U'
      __MVPUT ( mVar, 0 )
    ENDIF

    * If Window Was Multi-Activated, Determine If It Is The Last One.
    * If Yes, Post Quit Message To Finish The Message Loop

    * Quit Message will be posted always for single activated windows.

    IF _HMG_aFormActivateId[i] > 0

      TmpStr := '_HMG_ACTIVATE_' + ALLTRIM(Str(_HMG_aFormActivateId[i]))

      IF __MVEXIST ( TmpStr )
        Tmp := __MVGET ( TmpStr )

        IF VALTYPE(Tmp) == 'N'
          __MVPUT ( TmpStr, Tmp - 1 )
          IF Tmp - 1 == 0
            PostQuitMessage(0)
            __MVXRELEASE(TmpStr)
          ENDIF
        ENDIF
      ENDIF
    ELSE
      PostQuitMessage(0)
    ENDIF

    _HMG_aFormDeleted[i] := .T.
    _HMG_aFormhandles[i] := 0
    _HMG_aFormNames[i] := ""
    _HMG_aFormActive[i] := .F.
    _HMG_aFormType[i] := ""
    _HMG_aFormParenthandle[i] := 0
    _HMG_aFormInitProcedure[i] := ""
    _HMG_aFormReleaseProcedure[i] := ""
    _HMG_aFormToolTipHandle[i] := 0
    _HMG_aFormContextMenuHandle[i] := 0
    _HMG_aFormMouseDragProcedure[i] := ""
    _HMG_aFormSizeProcedure[i] := ""
    _HMG_aFormClickProcedure[i] := ""
    _HMG_aFormMouseMoveProcedure[i] := ""
    _HMG_aFormBkColor[I] := NIL
    _HMG_aFormPaintProcedure[i] := ""
    _HMG_aFormNoShow[i] := .F.
    _HMG_aFormNotifyIconName[i] := ''
    _HMG_aFormNotifyIconToolTip[i] := ''
    _HMG_aFormNotifyIconLeftClick[i] := ''
    _HMG_aFormReBarHandle[i] := 0
    _HMG_aFormNotifyMenuHandle[I] := 0
    _HMG_aFormBrowseList[i] := {}
    _HMG_aFormSplitChildList[i] := {}
    _HMG_aFormVirtualHeight[i] := 0
    _HMG_aFormGotFocusProcedure[i] := ""
    _HMG_aFormLostFocusProcedure[i] := ""
    _HMG_aFormVirtualWidth[i] := 0
    _HMG_aFormFocused[i] := .F.
    _HMG_aFormScrollUp[i] := ""
    _HMG_aFormScrollDown[i] := ""
    _HMG_aFormScrollLeft[i] := ""
    _HMG_aFormScrollRight[i] := ""
    _HMG_aFormHScrollBox[i] := ""
    _HMG_aFormVScrollBox[i] := ""
    _HMG_aFormBrushHandle[i] := 0
    _HMG_aFormFocusedControl[i] := 0
    _HMG_aFormGraphTasks[i] := {}
    _HMG_aFormMaximizeProcedure[i] := NIL
    _HMG_aFormMinimizeProcedure[i] := NIL
    _HMG_aFormRestoreProcedure[i] := NIL
    _HMG_aFormAutoRelease[i] := .F.
    _HMG_aFormInteractiveCloseProcedure[i] := ""
    _HMG_aFormActivateId[i] := 0

    _HMG_InteractiveCloseStarted := .F.
  ENDIF
ENDCASE

RETURN (0)
*
*------------------------------------------------------------*
* EOF()
*------------------------------------------------------------*