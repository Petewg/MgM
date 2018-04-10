/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Try to change a column's width by dragging a divider in the Grid header
 * Demo was contributed to HMG forum by KDJ 13/Nov/2016
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include "hmg.ch"
#include "i_winuser.ch"

FUNCTION Main()

  DEFINE WINDOW Main_WA;
    MAIN;
    CLIENTAREA 440, 206;
    TITLE 'Grid Columns Width - see in StatusBar';
    MINWIDTH 456 - iif(IsThemed(), 0, 2*GetBorderWidth());
    MINHEIGHT 244 - iif(IsThemed(), 0, 2*GetBorderHeight())

    DEFINE GRID Users_GR
      ROW            10
      COL            10
      WIDTH          420
      HEIGHT         120
      WIDTHS         { 130, 140, 70 }
      ITEMS          { {'John', 'Brown', '37'}, {'Peter', 'Green', '29'}, {'Eric', 'Pink', '45'} }
      JUSTIFY        { GRID_JTFY_LEFT, GRID_JTFY_LEFT, GRID_JTFY_RIGHT }
      CELLNAVIGATION .F.
    END GRID

    DEFINE BUTTON SetText_BU
      ROW      140
      COL      160
      WIDTH    130
      HEIGHT    28
      CAPTION 'Change header text'
      ACTION   SetHeaderText()
    END BUTTON
  
    DEFINE STATUSBAR
      STATUSITEM ''
      STATUSITEM '' WIDTH 155
      STATUSITEM '' WIDTH 140
    END STATUSBAR
  END WINDOW

  UpdateStatus()
  Main_WA.Users_GR.VALUE := 1

  CREATE EVENT PROCNAME EventHandler()

  Main_WA.CENTER
  Main_WA.ACTIVATE

RETURN NIL


FUNCTION UpdateStatus()

  Main_WA.STATUSBAR.Item(1) := hb_ntos(Main_WA.Users_GR.ColumnWIDTH(1)) + '  (range 50 - 150)'
  Main_WA.STATUSBAR.Item(2) := hb_ntos(Main_WA.Users_GR.ColumnWIDTH(2)) + '  (range 90 - 200)'
  Main_WA.STATUSBAR.Item(3) := hb_ntos(Main_WA.Users_GR.ColumnWIDTH(3)) + '  (range 30 - 90)'

RETURN NIL


#define HDN_ITEMCHANGINGA       (HDN_FIRST-0)
#define HDN_ITEMCHANGEDA        (HDN_FIRST-1)

FUNCTION EventHandler(nHWnd, nMsg, nWParam, nLParam)
  LOCAL nNotiCode
  LOCAL nCX
  LOCAL nItem

  IF nMsg == WM_NOTIFY
    IF GetHWNDFrom( nLParam ) == ListView_GetHeader( Main_WA.Users_GR.HANDLE )
      nNotiCode := GetNotifyCode( nLParam )

      // https://thomasfreudenberg.com/archive/2004/03/14/hdn-track-and-hds-fulldrag
      // No HDN_TRACK is sent if HDS_FULLDRAG style is set
      // So we will check HDN_ITEMCHANGING and HDN_ITEMCHANGED
      IF nNotiCode == HDN_ITEMCHANGINGA
        nCX := GetHeaderItemCX( nLParam )

        IF nCX >= 0
          nItem := GetHeaderItem( nLParam ) + 1

          IF nItem == 1
            IF nCX < 50
              Main_WA.Users_GR.ColumnWIDTH(nItem) := 50
              RETURN 1
            ELSEIF nCX > 150
              Main_WA.Users_GR.ColumnWIDTH(nItem) := 150
              RETURN 1
            ENDIF
          ELSEIF nItem == 2
            IF nCX < 90
              Main_WA.Users_GR.ColumnWIDTH(nItem) := 90
              RETURN 1
            ELSEIF nCX > 200
              Main_WA.Users_GR.ColumnWIDTH(nItem) := 200
              RETURN 1
            ENDIF
          ELSEIF nItem == 3
            IF nCX < 30
              Main_WA.Users_GR.ColumnWIDTH(nItem) := 30
              RETURN 1
            ELSEIF nCX > 90
              Main_WA.Users_GR.ColumnWIDTH(nItem) := 90
              RETURN 1
            ENDIF
          ENDIF
        ENDIF
      ELSEIF nNotiCode == HDN_ITEMCHANGEDA
        UpdateStatus()
      ENDIF
    ENDIF

  ELSEIF nMsg == WM_COMMAND
    IF LoWord( nWParam ) == IDCANCEL
      Main_WA.RELEASE
    ENDIF
  ENDIF

RETURN NIL


FUNCTION SetHeaderText()
  STATIC nType := 0

  IF nType == 0
    Main_WA.Users_GR.Header(1) := 'First name'
    Main_WA.Users_GR.Header(2) := 'Last name'
    Main_WA.Users_GR.Header(3) := 'Age'
    nType := 1
  ELSE
    Main_WA.Users_GR.Header(1) := 'Column 1'
    Main_WA.Users_GR.Header(2) := 'Column 2'
    Main_WA.Users_GR.Header(3) := 'Column 3'
    nType := 0
  ENDIF

RETURN NIL


#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>

// ListView_GetHeader( hWnd )
HB_FUNC ( LISTVIEW_GETHEADER )
{
   HWND hGrid   = ( HWND ) HB_PARNL( 1 );
   HWND hHeader = ( HWND ) ListView_GetHeader( hGrid );

   HB_RETNL( ( LONG_PTR ) hHeader );
}

// GetHeaderItem( nLParam )
HB_FUNC ( GETHEADERITEM )
{
   LPNMHEADER lpnmheader = ( LPNMHEADER ) HB_PARNL( 1 );

   hb_retni( lpnmheader->iItem );
}

// GetHeaderItemCX( nLParam )
HB_FUNC ( GETHEADERITEMCX )
{
   LPNMHEADER lpnmheader = ( LPNMHEADER ) HB_PARNL( 1 );

   if( lpnmheader->pitem->mask == HDI_WIDTH )
      hb_retni( lpnmheader->pitem->cxy );
   else
      hb_retni( -1 );
}

#pragma ENDDUMP
