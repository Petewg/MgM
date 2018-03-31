/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Demo was contributed to HMG forum by KDJ
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
*/

#include 'hmg.ch'

FUNCTION Main()

  SET FONT TO 'MS Shell Dlg', 8

  OpenDB()

  DEFINE WINDOW MainWA;
    MAIN;
    WIDTH  380;
    HEIGHT 290;
    TITLE  'Grid - Sort Header';
    NOMAXIMIZE;
    NOSIZE

    @ 10, 10 GRID CompGR;
      WIDTH          350;
      HEIGHT         180;
      HEADERS        {'RecNo', 'Name', 'Code', 'Price'};
      WIDTHS         {75, 110, 70, 70};
      ON HEADCLICK   {{ || SetOrder(1) }, { || SetOrder(2) }, { || SetOrder(3) }, { || SetOrder(4) }};
      ROWSOURCE      'Comp';
      COLUMNFIELDS   {'RecNo()', 'Name', 'Code', 'Price'};
      JUSTIFY        {GRID_JTFY_RIGHT, GRID_JTFY_LEFT, GRID_JTFY_CENTER, GRID_JTFY_RIGHT}

    DEFINE BUTTON ExitBU
      ROW     200
      COL     140
      WIDTH    80
      HEIGHT   25
      CAPTION 'E&xit'
      ACTION  MainWA.Release
    END BUTTON

    DEFINE MAINMENU
      DEFINE POPUP 'Set order'
        MENUITEM 'RecNo' ACTION SetOrder(1, .F.)
        SEPARATOR
        MENUITEM 'Name - ascending'  ACTION SetOrder(2, .F.)
        MENUITEM 'Name - descending' ACTION SetOrder(2, .T.)
        SEPARATOR
        MENUITEM 'Code - ascending'  ACTION SetOrder(3, .F.)
        MENUITEM 'Code - descending' ACTION SetOrder(3, .T.)
        SEPARATOR
        MENUITEM 'Price - ascending'  ACTION SetOrder(4, .F.)
        MENUITEM 'Price - descending' ACTION SetOrder(4, .T.)
      END POPUP
    END MENU

  END WINDOW

  MainWA.CompGR.Value := RecNo()

  SetOrder(2, .F.)

  MainWA.Center
  MainWA.Activate

RETURN NIL


FUNCTION SetOrder(nColumn, lDescend)
  LOCAL nOrder  := ordNumber(ordSetFocus())
  LOCAL nRecord := MainWA.CompGR.Value

  GridHeader_SetSort(MainWA.CompGR.Handle, nOrder + 1, 0)

  IF ValType(lDescend) != 'L'
    IF nColumn == 1
      lDescend := .F.
    ELSE
      lDescend := iif(nOrder == nColumn - 1, ! ordDescend(nOrder), .F.)
    ENDIF
  ENDIF

  nOrder := nColumn - 1

  GridHeader_SetSort(MainWA.CompGR.Handle, nColumn, iif(lDescend, -1, 1))

  ordSetFocus(nOrder)
  ordDescend(nOrder, NIL, lDescend)

  MainWA.CompGR.Value := nRecord
  MainWA.CompGR.Refresh

RETURN NIL


FUNCTION OpenDB()
  LOCAL cDbf   := 'Comp.dbf'
  LOCAL cNtx   := 'Comp.ntx'
  LOCAL lIsDbf := File(cDbf)

  IF lIsDbf
    dbUseArea(NIL, NIL, cDbf)
  ELSE
    dbCreate(cDbf, {{'Name', 'C', 30, 0}, {'Code', 'C', 3, 0}, {'Price', 'N', 6, 2}})
    dbUseArea(NIL, NIL, cDbf)

    dbAppend()
    Comp->Name  := 'Main board'
    Comp->Code  := '002'
    Comp->Price := 120.34
    dbAppend()
    Comp->Name  := 'Processor'
    Comp->Code  := '004'
    Comp->Price := 97.95
    dbAppend()
    Comp->Name  := 'RAM'
    Comp->Code  := '006'
    Comp->Price := 204.58
    dbAppend()
    Comp->Name  := 'HDD'
    Comp->Code  := '008'
    Comp->Price := 142.71
    dbAppend()
    Comp->Name  := 'SSD'
    Comp->Code  := '010'
    Comp->Price := 316.94
    dbAppend()
    Comp->Name  := 'Graphics card'
    Comp->Code  := '012'
    Comp->Price := 143.48
    dbAppend()
    Comp->Name  := 'Power supply'
    Comp->Code  := '014'
    Comp->Price := 54.29
    dbAppend()
    Comp->Name  := 'PC case'
    Comp->Code  := '013'
    Comp->Price := 72.85
    dbAppend()
    Comp->Name  := 'Pendrive'
    Comp->Code  := '011'
    Comp->Price := 12.78
    dbAppend()
    Comp->Name  := 'Monitor'
    Comp->Code  := '009'
    Comp->Price := 315.61
    dbAppend()
    Comp->Name  := 'Keyboard'
    Comp->Code  := '007'
    Comp->Price := 16.92
    dbAppend()
    Comp->Name  := 'Mouse'
    Comp->Code  := '005'
    Comp->Price := 9.84
    dbAppend()
    Comp->Name  := 'Modem'
    Comp->Code  := '003'
    Comp->Price := 31.45
    dbAppend()
    Comp->Name  := 'Speakers'
    Comp->Code  := '001'
    Comp->Price := 43.59
  ENDIF

  IF lIsDbf .and. File(cNtx)
    ordListAdd(cNtx)
  ELSE
    ordCreate(cNtx, 'Name',  'Name',  {|| Comp->Name},  .F. /*lUnique*/)
    ordCreate(cNtx, 'Code',  'Code',  {|| Comp->Code},  .F. /*lUnique*/)
    ordCreate(cNtx, 'Price', 'Price', {|| Comp->Price}, .F. /*lUnique*/)
  ENDIF

  dbGoTop()

RETURN NIL


#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>

#define HDF_SORTDOWN  0x0200
#define HDF_SORTUP    0x0400

//GridHeader_SetSort(nHWndLV, nColumn[, nType /*0==none, positive==UP arrow or negative==DOWN arrow*/]) -> nType (previous setting)
HB_FUNC ( GRIDHEADER_SETSORT )
{
   HWND   hWndHD = (HWND) SendMessage((HWND) HB_PARNL(1), LVM_GETHEADER, 0, 0);
   INT    nItem  = hb_parni(2) - 1;
   INT    nType;
   HDITEM hdItem;

   hdItem.mask = HDI_FORMAT;

   SendMessage(hWndHD, HDM_GETITEM, nItem, (LPARAM) &hdItem);

   if (hdItem.fmt & HDF_SORTUP)
      hb_retni(1);
   else if (hdItem.fmt & HDF_SORTDOWN)
      hb_retni(-1);
   else
      hb_retni(0);

   if ((hb_pcount() > 2) && HB_ISNUM(3))
   {
      nType = hb_parni(3);

      if (nType == 0)
        hdItem.fmt &= ~(HDF_SORTDOWN | HDF_SORTUP);
      else if (nType > 0)
        hdItem.fmt = (hdItem.fmt & ~HDF_SORTDOWN) | HDF_SORTUP;
      else
        hdItem.fmt = (hdItem.fmt & ~HDF_SORTUP) | HDF_SORTDOWN;

      SendMessage(hWndHD, HDM_SETITEM, nItem, (LPARAM) &hdItem);
   }
}

#pragma ENDDUMP
