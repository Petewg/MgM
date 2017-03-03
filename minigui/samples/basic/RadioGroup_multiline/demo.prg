/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * RadioGroup multiline
 * Demo was contributed to HMG forum by KDJ 05/Feb/2017
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include "hmg.ch"

#define WS_TABSTOP            0x10000

FUNCTION Main()

  SET FONT TO 'MS Shell Dlg', 8

  DEFINE WINDOW MainWA;
    MAIN;
    ROW    100;
    COL    100;
    WIDTH  190;
    HEIGHT 200;
    TITLE  "RadioGroup multiline";
    NOSIZE;
    NOMAXIMIZE;
    NOMINIMIZE;
    ON INIT ChangeHeightRG()

    DEFINE FRAME RadioFR
      ROW      10
      COL      50
      WIDTH    85
      CAPTION "RadioGroup"
    END FRAME

    DEFINE RADIOGROUP RadioRG
      ROW      30
      COL      60
      WIDTH    65
      VALUE     2
      OPTIONS {"Radio 1", e"Radio 2\ntwo lines", e"Radio 3\nthree\nlines"}
    END RADIOGROUP

    DEFINE BUTTON HeightBU
      COL      40
      WIDTH   100
      HEIGHT   25
      CAPTION ""
      ACTION  ChangeHeightRG()
    END BUTTON

    ON KEY ESCAPE ACTION MainWA.RELEASE
  END WINDOW

  MainWA.CENTER
  MainWA.ACTIVATE

RETURN NIL


FUNCTION ChangeHeightRG()
  STATIC lFixedH := .T.
  LOCAL nHeight

  lFixedH := ! lFixedH
  nHeight := RadioGroup_Format("RadioRG", "MainWA", 7, lFixedH)

  MainWA.RadioFR.HEIGHT := nHeight + 30
  MainWA.HeightBU.ROW   := MainWA.RadioFR.HEIGHT + 25

  MainWA.HEIGHT := ((MainWA.HEIGHT) - MainWA.CLIENTHEIGHT) + MainWA.HeightBU.ROW + MainWA.HeightBU.HEIGHT + 10

  MainWA.HeightBU.CAPTION := iif(lFixedH, "&Set variable height", "&Set fixed height")

RETURN NIL


FUNCTION RadioGroup_Format(cControl, cForm, nGap, lFixedHeight)  // for vertical RadioGroup
  LOCAL nTotalH := 0
  LOCAL nFixedH := 0
  LOCAL nCount
  LOCAL aHandle
  LOCAL aHeight
  LOCAL cText
  LOCAL nLines
  LOCAL nRow, nCol, nWidth
  LOCAL nValue
  LOCAL n

  IF _IsControlDefined(cControl, cForm)

    IF ! hb_IsNumeric(nGap) .OR. nGap < 0
      nGap := 10
    ENDIF
    IF ! hb_IsLogical(lFixedHeight)
      lFixedHeight := .F.
    ENDIF

    nRow    := GetProperty(cForm, cControl, "ROW")
    nCol    := GetProperty(cForm, cControl, "COL")
    nWidth  := GetProperty(cForm, cControl, "WIDTH")
    nValue  := GetProperty(cForm, cControl, "VALUE")
    aHandle := GetControlHandle(cControl, cForm)
    nCount  := Len(aHandle)
    aHeight := Array(nCount)

    FOR n := 1 TO nCount
      cText      := GetWindowText(aHandle[n])
      nLines     := HB_TokenCount(cText, .T. /*lEOL*/)
      aHeight[n] := GetTextHeight(0, cText, GetWindowFont(aHandle[n])) * nLines
      nFixedH    := Max(nFixedH, aHeight[n])

      IF nLines > 1
        HMG_ChangeWindowStyle(aHandle[n], 0x2000 /*BS_MULTILINE*/, NIL, .F.)
      ENDIF

      IF nValue > 0
        IF nValue == n
          HMG_ChangeWindowStyle(aHandle[n], WS_TABSTOP, NIL, .F.)
        ELSE
          HMG_ChangeWindowStyle(aHandle[n], NIL, WS_TABSTOP, .F.)
        ENDIF
      ENDIF
    NEXT

    IF lFixedHeight

      FOR n := 1 TO nCount
        SetWindowPos(aHandle[n], 0, nCol, nRow, nWidth, nFixedH, 0x14 /*SWP_NOZORDER|SWP_NOACTIVATE*/)
        nRow += nGap + nFixedH
      NEXT

      nTotalH += nFixedH * nCount + nGap * (nCount - 1)

    ELSE

      FOR n := 1 TO nCount
        SetWindowPos(aHandle[n], 0, nCol, nRow, nWidth, aHeight[n], 0x14 /*SWP_NOZORDER|SWP_NOACTIVATE*/)
        nRow    += nGap + aHeight[n]
        nTotalH += aHeight[n]
      NEXT

      nTotalH += nGap * (nCount - 1)

    ENDIF

  ENDIF

RETURN nTotalH
