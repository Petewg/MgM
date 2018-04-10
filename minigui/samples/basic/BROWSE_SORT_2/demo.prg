/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Sample was contributed to HMG forum by KDJ
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
*/

#include 'minigui.ch'


FUNCTION Main()
  LOCAL lInit := .F.

  SET FONT TO 'MS Shell Dlg', 8

  OpenDB()

  DEFINE WINDOW MainWA;
    MAIN;
    WIDTH  380;
    HEIGHT 290;
    TITLE  'Browse - Sort Columns With Header Click';
    NOMAXIMIZE;
    NOSIZE

    @ 10, 10 BROWSE CompGR;
      WIDTH          350;
      HEIGHT         180;
      HEADERS        {'Name', 'Code', 'Price'};
      WIDTHS         {75, 110, 70, 70};
      WORKAREA       COMP;
      FIELDS         {'Name', 'Code', 'Price'};
      ON GOTFOCUS    iif(lInit, , (HMG_SetOrder( 1, .F. ), lInit := .T.));
      JUSTIFY        {BROWSE_JTFY_LEFT, BROWSE_JTFY_CENTER, BROWSE_JTFY_RIGHT};
      COLUMNSORT     {/*.T., .F., .T.*/}

    DEFINE BUTTON ExitBU
      ROW         200
      COL         140
      WIDTH       80
      HEIGHT      25
      CAPTION     'E&xit'
      ACTION      MainWA.Release
    END BUTTON

    DEFINE MAINMENU
      DEFINE POPUP 'Set order'
        MENUITEM 'Name - ascending'  ACTION SetOrder(1, .F.)
        MENUITEM 'Name - descending' ACTION SetOrder(1, .T.)
        SEPARATOR
        MENUITEM 'Code - ascending'  ACTION SetOrder(2, .F.)
        MENUITEM 'Code - descending' ACTION SetOrder(2, .T.)
        SEPARATOR
        MENUITEM 'Price - ascending'  ACTION SetOrder(3, .F.)
        MENUITEM 'Price - descending' ACTION SetOrder(3, .T.)
      END POPUP
    END MENU

  END WINDOW

  MainWA.CompGR.Value := RecNo()

  MainWA.Center
  MainWA.Activate

RETURN NIL


FUNCTION SetOrder(nColumn, lDescend)
  LOCAL nOrder  := ordNumber(ordSetFocus())
  LOCAL nRecord := MainWA.CompGR.Value

  ListView_SetSortHeader(MainWA.CompGR.Handle, nOrder, 0, IsAppXPThemed())

  IF ValType(lDescend) != 'L'
     lDescend := iif(nOrder == nColumn, ! ordDescend(nOrder), .F.)
  ENDIF

  nOrder := nColumn

  ListView_SetSortHeader(MainWA.CompGR.Handle, nColumn, iif(lDescend, -1, 1), IsAppXPThemed())

  ordSetFocus(nOrder)
  ordDescend(nOrder, NIL, lDescend)

  MainWA.CompGR.Value := nRecord
  MainWA.CompGR.Refresh

RETURN NIL


FUNCTION OpenDB()
  LOCAL cDbf   := 'COMP.dbf'

  IF File(cDbf)
    dbUseArea(NIL, NIL, cDbf)
  ELSE
    dbCreate(cDbf, {{'Code', 'C', 3, 0}, {'Name', 'C', 30, 0}, {'Price', 'N', 6, 2}})
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

RETURN NIL
