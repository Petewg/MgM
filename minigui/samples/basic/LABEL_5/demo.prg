/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Demo was contributed to HMG forum by KDJ
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
*/

#include "hmg.ch"
#include "i_winuser.ch"

#define LABEL_NAME 1
#define LABEL_HWND 2

FUNCTION Main()
  LOCAL aLabel := {{"LABEL1", NIL}, ;
                   {"LABEL2", NIL}, ;
                   {"LABEL3", NIL}}
  LOCAL n

  SET DIALOGBOX CENTER OF PARENT

  DEFINE WINDOW MainForm;
    WIDTH  300;
    HEIGHT 260;
    TITLE  "Labels as buttons";
    MAIN;
    FONT "Arial" SIZE 9

    // these labels can get focus and process keyboard/mouse messages
    FOR n := 1 TO Len(aLabel)
      DEFINE LABEL &(aLabel[n][LABEL_NAME])
        ROW          10 + 55 * (n - 1)
        COL          10
        WIDTH        140
        HEIGHT       45
        VALUE        "This is " + aLabel[n][LABEL_NAME]
        ALIGNMENT    Center
        FONTCOLOR    BLACK
        ONMOUSEHOVER OnLblHover(aLabel, This.Name)
        ONMOUSELEAVE OnLblLeave(This.Name)
        ACTION       MsgBox(GetProperty(ThisWindow.Name, This.Name, "VALUE"))
      END LABEL

      aLabel[n][LABEL_HWND] := GetProperty("MainForm", aLabel[n][LABEL_NAME], "HANDLE")

      HMG_ChangeWindowStyle(aLabel[n][LABEL_HWND], 0x00010200 /*WS_TABSTOP|SS_CENTERIMAGE*/, NIL, .F., .F.)
      HMG_ChangeWindowStyle(aLabel[n][LABEL_HWND], WS_EX_STATICEDGE, NIL, .T., .T.)
    NEXT

    DEFINE LABEL LABEL4
      ROW      190
      COL      120
      AUTOSIZE .T.
      VALUE    "This is a standard LABEL"
    END LABEL

    DEFINE BUTTON CloseButton
      ROW        190
      COL        10
      WIDTH      80
      HEIGHT     23
      CAPTION    "Close"
      ACTION     MainForm.RELEASE
      ONGOTFOCUS LabelSetBorder(aLabel, 0)
    END BUTTON

  END WINDOW

  SetFocus(aLabel[1][LABEL_HWND])
  LabelSetBorder(aLabel, aLabel[1][LABEL_HWND])

  ON KEY TAB OF MainForm ACTION OnNextTabItem(aLabel, .F.)
  ON KEY SHIFT+TAB OF MainForm ACTION OnNextTabItem(aLabel, .T.)

  ON KEY DOWN OF MainForm ACTION OnNextTabItem(aLabel, .F.)
  ON KEY UP OF MainForm ACTION OnNextTabItem(aLabel, .T.)

  ON KEY RETURN OF MainForm ACTION OnEnter(aLabel)
  ON KEY SPACE OF MainForm ACTION OnEnter(aLabel)

  MainForm.CENTER
  MainForm.ACTIVATE

RETURN NIL


FUNCTION OnNextTabItem(aLabel, lPrev)
  LOCAL nPos

  nPos := aScan(aLabel, { |a1| HMG_IsWindowStyle(a1[LABEL_HWND], WS_BORDER) })
  IF lPrev .AND. nPos > 1 .OR. !lPrev .AND. nPos < Len(aLabel)
    LabelSetBorder(aLabel, GetNextDlgTabItem(MainForm.HANDLE, MainForm.&(MainForm.FocusedControl).HANDLE, lPrev))
  ENDIF

  nPos := aScan(aLabel, { |a1| HMG_IsWindowStyle(a1[LABEL_HWND], WS_BORDER) })
  IF nPos > 0
    SetFocus(aLabel[nPos][LABEL_HWND])
  ENDIF

RETURN NIL


FUNCTION OnEnter(aLabel)
  LOCAL nPos := aScan(aLabel, { |a1| HMG_IsWindowStyle(a1[LABEL_HWND], WS_BORDER) })

  IF nPos > 0
    MsgBox(GetProperty(ThisWindow.Name, aLabel[nPos][LABEL_NAME], "VALUE"))
  ELSE
    Eval(MainForm.CloseButton.ACTION)
  ENDIF

RETURN NIL


FUNCTION OnLblHover(aLabel, cControl)
  LOCAL nPos := aScan(aLabel, { |a1| cControl == a1[LABEL_NAME] })
  LOCAL cForm := ThisWindow.Name

  RC_CURSOR( "MINIGUI_FINGER" )

  SetFocus(aLabel[nPos][LABEL_HWND])
  LabelSetBorder(aLabel, aLabel[nPos][LABEL_HWND])

  SetProperty(cForm, cControl, "FONTCOLOR", RED)
  SetProperty(cForm, cControl, "FONTBOLD", .T.)

RETURN NIL


FUNCTION OnLblLeave(cControl)
  LOCAL cForm := ThisWindow.Name

  SetProperty(cForm, cControl, "FONTCOLOR", BLACK)
  SetProperty(cForm, cControl, "FONTBOLD", .F.)

RETURN NIL


FUNCTION LabelSetBorder(aLabel, nHWnd)
  LOCAL nPosDel := aScan(aLabel, { |a1| HMG_IsWindowStyle(a1[LABEL_HWND], WS_BORDER) })
  LOCAL nPosSet := aScan(aLabel, { |a1| nHWnd == a1[LABEL_HWND] })

  IF nPosDel != nPosSet
    IF nPosDel > 0
      HMG_ChangeWindowStyle(aLabel[nPosDel][LABEL_HWND], NIL, WS_BORDER, .F., .F.)
      HMG_ChangeWindowStyle(aLabel[nPosDel][LABEL_HWND], WS_EX_STATICEDGE, NIL, .T., .T.)
    ENDIF

    IF nPosSet > 0
      HMG_ChangeWindowStyle(aLabel[nPosSet][LABEL_HWND], WS_BORDER, NIL, .F., .F.)
      HMG_ChangeWindowStyle(aLabel[nPosSet][LABEL_HWND], NIL, WS_EX_STATICEDGE, .T., .T.)
    ENDIF
  ENDIF

RETURN NIL
