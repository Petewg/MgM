/*

  Owner buttons demonstration

*/

#include "minigui.ch"

#define IDC_BTN_1   1001
#define IDC_BTN_2   1002
#define IDC_BTN_3   1003
#define IDC_BTN_4   1004
#define IDC_BTN_5   1005
#define IDC_BTN_YES 1101
#define IDC_BTN_NO  1102

STATIC lSetColor := .T.

FUNCTION Main()

  SET CENTERWINDOW RELATIVE PARENT

  SET FONT TO "Arial", 9

  DEFINE WINDOW Form1;
    MAIN;
    WIDTH  380;
    HEIGHT 440;
    TITLE  "Owner buttons";
    NOSIZE;
    NOMAXIMIZE;
    NOMINIMIZE;
    ON INTERACTIVECLOSE MessageBoxQuit()

    DEFINE MAINMENU
      DEFINE POPUP "Button &1"
        MENUITEM "Move"           ACTION MoveButton("Form1", IDC_BTN_1)
        MENUITEM "Resize"         ACTION ResizeButton("Form1", IDC_BTN_1)
        SEPARATOR
        MENUITEM "Show"           ACTION ShowButton("Form1", IDC_BTN_1, .T.)
        MENUITEM "Hide"           ACTION ShowButton("Form1", IDC_BTN_1, .F.)
        SEPARATOR
        MENUITEM "Enable"         ACTION EnableButton("Form1", IDC_BTN_1, .T.)
        MENUITEM "Disable"        ACTION EnableButton("Form1", IDC_BTN_1, .F.)
        SEPARATOR
        MENUITEM "Change caption" ACTION ChangeButtonCaption("Form1", IDC_BTN_1)
        MENUITEM "Change font"    ACTION ChangeButtonFont("Form1", IDC_BTN_1)
        SEPARATOR
        MENUITEM "Set focus"      ACTION SetFocusToButton("Form1", IDC_BTN_1)
        MENUITEM "Release"        ACTION ReleaseButton("Form1", IDC_BTN_1)
      END POPUP
      DEFINE POPUP "Button &2"
        MENUITEM "Move"           ACTION MoveButton("Form1", IDC_BTN_2)
        MENUITEM "Resize"         ACTION ResizeButton("Form1", IDC_BTN_2)
        SEPARATOR
        MENUITEM "Show"           ACTION ShowButton("Form1", IDC_BTN_2, .T.)
        MENUITEM "Hide"           ACTION ShowButton("Form1", IDC_BTN_2, .F.)
        SEPARATOR
        MENUITEM "Enable"         ACTION EnableButton("Form1", IDC_BTN_2, .T.)
        MENUITEM "Disable"        ACTION EnableButton("Form1", IDC_BTN_2, .F.)
        SEPARATOR
        MENUITEM "Change caption" ACTION ChangeButtonCaption("Form1", IDC_BTN_2)
        MENUITEM "Change font"    ACTION ChangeButtonFont("Form1", IDC_BTN_2)
        SEPARATOR
        MENUITEM "Set focus"      ACTION SetFocusToButton("Form1", IDC_BTN_2)
        MENUITEM "Release"        ACTION ReleaseButton("Form1", IDC_BTN_2)
      END POPUP
      DEFINE POPUP "Button &3"
        MENUITEM "Move"           ACTION MoveButton("Form1", IDC_BTN_3)
        MENUITEM "Resize"         ACTION ResizeButton("Form1", IDC_BTN_3)
        SEPARATOR
        MENUITEM "Show"           ACTION ShowButton("Form1", IDC_BTN_3, .T.)
        MENUITEM "Hide"           ACTION ShowButton("Form1", IDC_BTN_3, .F.)
        SEPARATOR
        MENUITEM "Enable"         ACTION EnableButton("Form1", IDC_BTN_3, .T.)
        MENUITEM "Disable"        ACTION EnableButton("Form1", IDC_BTN_3, .F.)
        SEPARATOR
        MENUITEM "Change caption" ACTION ChangeButtonCaption("Form1", IDC_BTN_3)
        MENUITEM "Change font"    ACTION ChangeButtonFont("Form1", IDC_BTN_3)
        SEPARATOR
        MENUITEM "Set focus"      ACTION SetFocusToButton("Form1", IDC_BTN_3)
        MENUITEM "Release"        ACTION ReleaseButton("Form1", IDC_BTN_3)
      END POPUP
      DEFINE POPUP "Button &4"
        MENUITEM "Move"           ACTION MoveButton("Form1", IDC_BTN_4)
        MENUITEM "Resize"         ACTION ResizeButton("Form1", IDC_BTN_4)
        SEPARATOR
        MENUITEM "Show"           ACTION ShowButton("Form1", IDC_BTN_4, .T.)
        MENUITEM "Hide"           ACTION ShowButton("Form1", IDC_BTN_4, .F.)
        SEPARATOR
        MENUITEM "Enable"         ACTION EnableButton("Form1", IDC_BTN_4, .T.)
        MENUITEM "Disable"        ACTION EnableButton("Form1", IDC_BTN_4, .F.)
        SEPARATOR
        MENUITEM "Change caption" ACTION ChangeButtonCaption("Form1", IDC_BTN_4)
        MENUITEM "Change font"    ACTION ChangeButtonFont("Form1", IDC_BTN_4)
        SEPARATOR
        MENUITEM "Set focus"      ACTION SetFocusToButton("Form1", IDC_BTN_4)
        MENUITEM "Release"        ACTION ReleaseButton("Form1", IDC_BTN_4)
      END POPUP
      DEFINE POPUP "Button &5"
        MENUITEM "Move"           ACTION MoveButton("Form1", IDC_BTN_5)
        MENUITEM "Resize"         ACTION ResizeButton("Form1", IDC_BTN_5)
        SEPARATOR
        MENUITEM "Show"           ACTION ShowButton("Form1", IDC_BTN_5, .T.)
        MENUITEM "Hide"           ACTION ShowButton("Form1", IDC_BTN_5, .F.)
        SEPARATOR
        MENUITEM "Enable"         ACTION EnableButton("Form1", IDC_BTN_5, .T.)
        MENUITEM "Disable"        ACTION EnableButton("Form1", IDC_BTN_5, .F.)
        SEPARATOR
        MENUITEM "Change caption" ACTION ChangeButtonCaption("Form1", IDC_BTN_5)
        MENUITEM "Change font"    ACTION ChangeButtonFont("Form1", IDC_BTN_5)
        SEPARATOR
        MENUITEM "Set focus"      ACTION SetFocusToButton("Form1", IDC_BTN_5)
        MENUITEM "Release"        ACTION ReleaseButton("Form1", IDC_BTN_5)
      END POPUP
      DEFINE POPUP "&All buttons"
        MENUITEM "Change color"   ACTION ChangeButtonsColor("Form1")
      END POPUP
    END MENU

   @ 20, 20 BUTTONEX &("Button_" + hb_ntos(IDC_BTN_1)) ;
      CAPTION "button &1" ;
      WIDTH 120  ;
      HEIGHT 30 ;
      FONTCOLOR BLUE ;
      BACKCOLOR YELLOW ;
      GRADIENTFILL { { 1, { 255, 255, 0 }, { 200, 160, 0 } } } ;
      ACTION _dummy() ;
      TOOLTIP "Button_1" NOXPSTYLE

   @ 70, 20 BUTTONEX &("Button_" + hb_ntos(IDC_BTN_2)) ;
      CAPTION "button &2" ;
      WIDTH 120  ;
      HEIGHT 30 ;
      FONTCOLOR BLUE ;
      BACKCOLOR YELLOW ;
      GRADIENTFILL { { 1, { 255, 255, 0 }, { 200, 160, 0 } } } ;
      ACTION _dummy() ;
      TOOLTIP "Button_2" NOXPSTYLE

   @ 120, 20 BUTTONEX &("Button_" + hb_ntos(IDC_BTN_3)) ;
      CAPTION "button &3" ;
      WIDTH 120  ;
      HEIGHT 30 ;
      FONTCOLOR BLUE ;
      BACKCOLOR YELLOW ;
      GRADIENTFILL { { 1, { 255, 255, 0 }, { 200, 160, 0 } } } ;
      ACTION _dummy() ;
      TOOLTIP "Button_3" NOXPSTYLE

   @ 170, 20 BUTTONEX &("Button_" + hb_ntos(IDC_BTN_4)) ;
      CAPTION "button &4"+CRLF+"multiline" ;
      WIDTH 120  ;
      HEIGHT 50 ;
      FONTCOLOR BLUE ;
      BACKCOLOR YELLOW ;
      GRADIENTFILL { { 1, { 255, 255, 0 }, { 200, 160, 0 } } } ;
      ACTION _dummy() ;
      TOOLTIP "Button_4" NOXPSTYLE

   @ 240, 20 BUTTONEX &("Button_" + hb_ntos(IDC_BTN_5)) ;
      CAPTION "button &5"+CRLF+"<quit>" ;
      WIDTH 120  ;
      HEIGHT 50 ;
      FONTCOLOR BLUE ;
      BACKCOLOR YELLOW ;
      GRADIENTFILL { { 1, { 255, 255, 0 }, { 200, 160, 0 } } } ;
      ACTION MessageBoxQuit(.T.) ;
      TOOLTIP "Button_5" NOXPSTYLE

  END WINDOW

  Form1.CENTER
  Form1.ACTIVATE

RETURN NIL


FUNCTION MoveButton(cForm, nID)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)
  LOCAL nCol

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSE
    nCol := _GetControlCol(cBtnName, cForm)
    _SetControlCol(cBtnName, cForm, iif(nCol == 20, 210, 20))
  ENDIF

RETURN NIL


FUNCTION ResizeButton(cForm, nID)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)
  LOCAL nWidth

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSE
    nWidth := _GetControlWidth(cBtnName, cForm)
    _SetControlWidth(cBtnName, cForm, iif(nWidth == 120, 140, 120))
  ENDIF

RETURN NIL


FUNCTION ShowButton(cForm, nID, lShow)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSE
     IF lShow
        _ShowControl(cBtnName, cForm)
     ELSE
        _HideControl(cBtnName, cForm)
     ENDIF
  ENDIF

RETURN NIL


FUNCTION EnableButton(cForm, nID, lShow)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSE
     IF lShow
        _EnableControl(cBtnName, cForm)
     ELSE
        _DisableControl(cBtnName, cForm)
     ENDIF
  ENDIF

RETURN NIL


FUNCTION ChangeButtonCaption(cForm, nID)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)
  LOCAL cCaption

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSE
    cCaption := GetWindowText(GetControlHandle(cBtnName, cForm))
    _SetControlCaption(cBtnName, cForm, If(HMG_IsLower(cCaption), Upper(cCaption), Lower(cCaption)))
  ENDIF

RETURN NIL


FUNCTION ChangeButtonFont(cForm, nID)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)
  LOCAL nFontSize, lFontBold

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSE
    nFontSize := _GetFontSize(cBtnName, cForm)
    lFontBold := _GetFontBold(cBtnName, cForm)

    _SetFontSize(cBtnName, cForm, If(nFontSize == 9, 11, 9))
    _SetFontBold(cBtnName, cForm, !lFontBold)
  ENDIF

RETURN NIL


FUNCTION SetFocusToButton(cForm, nID)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSEIF ! _IsControlVisible(cBtnName, cForm)
    MsgBox("Button is hidden!")
  ELSEIF ! _IsControlEnabled(cBtnName, cForm)
    MsgBox("Button is disabled!")
  ELSE
    _SetFocus(cBtnName, cForm)
  ENDIF

RETURN NIL


FUNCTION ReleaseButton(cForm, nID)
  LOCAL cBtnName := "Button_" + hb_ntos(nID)

  IF _IsControlDefined(cBtnName, cForm) == .F.
    MsgBox("Button does not exist!")
  ELSE
    _ReleaseControl(cBtnName, cForm)
  ENDIF

RETURN NIL


FUNCTION ChangeButtonsColor(cForm)
  LOCAL nID, aColor
  LOCAL cBtnName

  FOR nID := IDC_BTN_1 TO IDC_BTN_5
    cBtnName := "Button_" + hb_ntos(nID)
    IF _IsControlDefined(cBtnName, cForm)
      aColor := _GetFontColor(cBtnName, cForm)

      IF lSetColor
        _SetFontColor(cBtnName, cForm, RED)
        _SetBackColor(cBtnName, cForm, AQUA)
        _SetGradColor(cBtnName, cForm, { { 1, { 64, 240, 255 }, { 64, 200, 255 } } })
      ELSE
        _SetFontColor(cBtnName, cForm, BLUE)
        _SetBackColor(cBtnName, cForm, YELLOW)
        _SetGradColor(cBtnName, cForm, { { 1, { 255, 255, 0 }, { 200, 160, 0 } } })
      ENDIF
      RedrawWindow ( GetControlHandle ( cBtnName, cForm ) )

    ENDIF
  NEXT

  lSetColor := ! lSetColor

  IF ValType(aColor) == "U"
    MsgBox("All buttons are released!")
  ELSE
    cBtnName := "Button_" + hb_ntos(nID-1)
    IF _IsControlDefined(cBtnName, cForm)
      _SetFocus(cBtnName, cForm)
    ENDIF
    cBtnName := "Button_" + hb_ntos(IDC_BTN_1)
    IF _IsControlDefined(cBtnName, cForm)
      _SetFocus(cBtnName, cForm)
    ENDIF
  ENDIF

RETURN NIL


FUNCTION MessageBoxQuit(lQuit)
  LOCAL lReturn := .T.

  DEFAULT lQuit := .F.

  DEFINE WINDOW Form2;
    WIDTH  200;
    HEIGHT 120;
    TITLE  "Owner buttons";
    MODAL;
    NOSIZE

    DEFINE LABEL Msg_LA
      ROW     15
      COL     15
      WIDTH  170
      HEIGHT  16
      VALUE  "Do you want to quit program?"
    END LABEL

   @ 50, 10 BUTTONEX &("Button_" + hb_ntos(IDC_BTN_YES)) ;
      CAPTION "Yes" ;
      WIDTH 80  ;
      HEIGHT 26 ;
      FLAT ;
      FONTCOLOR RED ;
      BACKCOLOR { { 0.58, { 229, 244, 252 }, { 196, 229, 246 } }, ;
         { 0.42, { 152, 209, 239 }, { 114, 185, 223 } } } ;
      GRADIENTFILL { { 0.5, { 242, 242, 242 }, { 235, 235, 235 } }, ;
         { 0.5, { 222, 222, 222 }, { 210, 210, 210 } } } ;
      ACTION IF(lQuit, Form1.Release, Form2.Release)

   @ 50, 100 BUTTONEX &("Button_" + hb_ntos(IDC_BTN_NO)) ;
      CAPTION "No" ;
      WIDTH 80  ;
      HEIGHT 26 ;
      FLAT ;
      FONTCOLOR NAVY ;
      BACKCOLOR { { 0.58, { 229, 244, 252 }, { 196, 229, 246 } }, ;
         { 0.42, { 152, 209, 239 }, { 114, 185, 223 } } } ;
      GRADIENTFILL { { 0.5, { 242, 242, 242 }, { 235, 235, 235 } }, ;
         { 0.5, { 222, 222, 222 }, { 210, 210, 210 } } } ;
      ACTION (lReturn := .F., ThisWindow.Release)

  END WINDOW

  CENTER WINDOW Form2
  Form2.ACTIVATE

RETURN lReturn


STATIC FUNCTION _GetFontColor( ControlName, ParentForm )

RETURN _HMG_aControlFontColor [GetControlIndex ( ControlName, ParentForm )]


STATIC FUNCTION _SetFontColor( ControlName, ParentForm, Value )

  _HMG_aControlFontColor [GetControlIndex ( ControlName, ParentForm )] := Value

RETURN Nil


STATIC FUNCTION _SetBackColor( ControlName, ParentForm, Value )

  _HMG_aControlBkColor [GetControlIndex ( ControlName, ParentForm )] := Value

RETURN Nil


STATIC FUNCTION _SetGradColor( ControlName, ParentForm, Value )

  _HMG_aControlValue [GetControlIndex ( ControlName, ParentForm )] := Value

RETURN Nil


#pragma BEGINDUMP

  #include <mgdefs.h>

  HB_FUNC (HMG_ISLOWER)
  {
     TCHAR *Text = (TCHAR*) hb_parc(1);
     hb_retl( (BOOL) IsCharLower (*Text) );
  }

#pragma ENDDUMP
