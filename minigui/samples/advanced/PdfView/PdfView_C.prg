#pragma BEGINDUMP

#include <mgdefs.h>
#include <windowsx.h>
#include <commctrl.h>

//        EnableWindowRedraw ( hWnd, lRedrawOnOff, lRedrawWindow )
HB_FUNC ( ENABLEWINDOWREDRAW )
{
   HWND hWnd          = (HWND) HB_PARNL (1);
   BOOL lRedrawOnOff  = (BOOL) hb_parl  (2);
   BOOL lRedrawWindow = (BOOL) hb_parl  (3);
   
   SendMessage ( hWnd, WM_SETREDRAW, (WPARAM) lRedrawOnOff, 0 );
   
   if ((lRedrawOnOff == TRUE) && (lRedrawWindow == TRUE))
       RedrawWindow (hWnd, NULL, NULL, RDW_ERASE | RDW_FRAME | RDW_INVALIDATE | RDW_ALLCHILDREN);
}

//        HMG_GetCursorPos ( [ hWnd ], @nRow, @nCol ) --> return { nRow, nCol }
HB_FUNC ( HMG_GETCURSORPOS )
{
   HWND  hWnd = (HWND) HB_PARNL (1);
   POINT Point;

   GetCursorPos (&Point);
   if ( IsWindow (hWnd) )
       ScreenToClient (hWnd, &Point);

   if (HB_ISBYREF(2))
       hb_stornl ((LONG) Point.y, 2);

   if (HB_ISBYREF(3))
       hb_stornl ((LONG) Point.x, 3);

   hb_reta (2);
   HB_STORVNL ((LONG) Point.y, -1, 1);
   HB_STORVNL ((LONG) Point.x, -1, 2);
}

//       HMG_StrCmp ( Text1 , Text2 , [ lCaseSensitive ] ) --> CmpValue
HB_FUNC (HMG_STRCMP)
{
   TCHAR *Text1 = (TCHAR *) hb_parc (1);
   TCHAR *Text2 = (TCHAR *) hb_parc (2);
   BOOL  lCaseSensitive = (BOOL) hb_parl (3);
   int CmpValue;
   
   if ( lCaseSensitive == FALSE )
      CmpValue = lstrcmpi (Text1, Text2);
   else
      CmpValue = lstrcmp  (Text1, Text2);
   
   hb_retni ((int) CmpValue);
}

        //GetRectArray(pRect, aRect)
HB_FUNC ( GETRECTARRAY )
{
  RECT *rc = (RECT *) HB_PARNL(1);

  hb_storvni(rc->left,   2, 1);
  hb_storvni(rc->top,    2, 2);
  hb_storvni(rc->right,  2, 3);
  hb_storvni(rc->bottom, 2, 4);
}

        //SetRectArray(pRect, aRect)
HB_FUNC ( SETRECTARRAY )
{
  RECT *rc = (RECT *) HB_PARNL(1);

  rc->left   = hb_parvni(2, 1);
  rc->top    = hb_parvni(2, 2);
  rc->right  = hb_parvni(2, 3);
  rc->bottom = hb_parvni(2, 4);
}

//        IsMaximized ( hWnd )
HB_FUNC ( ISMAXIMIZED )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   hb_retl ((BOOL) IsZoomed ( hWnd ) );
}

//       ScreenToClientCol (hWnd, Col) --> New_Col 
HB_FUNC (SCREENTOCLIENTCOL)
{
   HWND hWnd = (HWND) HB_PARNL (1);
   LONG x    = (LONG) hb_parnl (2);
   POINT Point;
   Point.x = x;
   Point.y = 0;
   ScreenToClient(hWnd, &Point);
   hb_retnl ((LONG) Point.x );
}

       //GetWindowNormalPos(hWnd)
HB_FUNC( GETWINDOWNORMALPOS )
{
  WINDOWPLACEMENT wp;
  wp.length = sizeof(WINDOWPLACEMENT);

  GetWindowPlacement((HWND) HB_PARNL(1), &wp);

  hb_reta(4);
  hb_storvni(wp.rcNormalPosition.left,   -1, 1);
  hb_storvni(wp.rcNormalPosition.top,    -1, 2);
  hb_storvni(wp.rcNormalPosition.right,  -1, 3);
  hb_storvni(wp.rcNormalPosition.bottom, -1, 4);
}

       //SetMinMaxTrackSize(lParam, nMinX, nMinY, nMaxX, nMaxY)
HB_FUNC( SETMINMAXTRACKSIZE )
{
  MINMAXINFO *MinMax = (MINMAXINFO *) HB_PARNL(1);

  if (hb_parni(2) > 0)
    MinMax->ptMinTrackSize.x = hb_parni(2);
  if (hb_parni(3) > 0)
    MinMax->ptMinTrackSize.y = hb_parni(3);
  if (hb_parni(4) > 0)
    MinMax->ptMaxTrackSize.x = hb_parni(4);
  if (hb_parni(5) > 0)
    MinMax->ptMaxTrackSize.y = hb_parni(5);
}

       //lParam form WM_LBUTTON*, WM_MBUTTON*, WM_RBUTTON* messages
       //Tab_HitTest(hWnd, lParam)
HB_FUNC( TAB_HITTEST )
{
  LPARAM lParam = HB_PARNL(2);
  TCHITTESTINFO tchti;

  tchti.pt.x = (LONG) GET_X_LPARAM(lParam);
  tchti.pt.y = (LONG) GET_Y_LPARAM(lParam);

  hb_retni(TabCtrl_HitTest((HWND) HB_PARNL(1), &tchti) + 1);
}

       //TrackPopupMenu2(nHMenu, nFlags, nRow, nCol, nHWnd)
HB_FUNC( TRACKPOPUPMENU2 )
{
  hb_retni(TrackPopupMenu((HMENU) HB_PARNL(1),
                          (UINT)  hb_parni (2),
                          (INT)   hb_parni (4),
                          (INT)   hb_parni (3),
                          0,
                          (HWND)  HB_PARNL(5),
                          NULL));
}

       //PaintSizeGrip(nHWnd)
HB_FUNC( PAINTSIZEGRIP )
{
  HWND        hWnd;
  PAINTSTRUCT ps;
  RECT        rc;
  HDC         hdc;

  hWnd = (HWND) HB_PARNL(1);
  hdc  = BeginPaint(hWnd, &ps);

  if (hdc)
  {
    GetClientRect(hWnd, &rc);

    rc.left = rc.right  - GetSystemMetrics(SM_CXVSCROLL);
    rc.top  = rc.bottom - GetSystemMetrics(SM_CYVSCROLL);

    DrawFrameControl(hdc, &rc, DFC_SCROLL, DFCS_SCROLLSIZEGRIP);
    EndPaint(hWnd, &ps);
  }
}

       //Send_WM_COPYDATA(nHWnd, nAction, cText)
HB_FUNC( SEND_WM_COPYDATA )
{
  LPTSTR         Text = (LPTSTR) hb_parc(3);
  COPYDATASTRUCT cds;

  cds.dwData = HB_PARNL(2);
  cds.cbData = hb_parclen(3) + 1;
  cds.lpData = Text;

  SendMessageTimeout((HWND) HB_PARNL(1), WM_COPYDATA, (WPARAM) NULL, (LPARAM) &cds, 0, 5000, NULL);
}

       //GetCopyDataAction(pCDS)
HB_FUNC( GETCOPYDATAACTION )
{
  PCOPYDATASTRUCT pCDS = (PCOPYDATASTRUCT) HB_PARNL(1);

  HB_RETNL(pCDS->dwData);
}

       //GetCopyDataString(pCDS, [lIsUTF8])
HB_FUNC( GETCOPYDATASTRING )
{
  PCOPYDATASTRUCT pCDS = (PCOPYDATASTRUCT) HB_PARNL(1);

  if (hb_parl(2))
    hb_retc(pCDS->lpData);
  else
    hb_retc(pCDS->lpData);
}

#pragma ENDDUMP
