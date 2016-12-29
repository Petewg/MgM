//  *****************************************************************
#define  _CONTROLPOS_   "v3.60"
//  **        Change on runtime positon and size of control        **
//  **        (and same properties) and save it to file            **
//  **                                                             **
//  **  (c) Adam Lubszczyk      adam_l at poczta.onet.pl           **
//  *****************************************************************
// TO USE:
//  Copy file "_ControlPos3_.prg" to Your program folder.
//  In Your main *.prg before function main() add line:
//     SET PROCEDURE TO _ControlPos3_.prg
//  before line with:
//     ACTIVATE WINDOW YourMainForm
//  add line:
//     ControlPosSTART()
//
//  Hot keys:
//    Shift + arrow_key     ->   move selected controls
//    Ctrl  + arrow_key     ->   resize selected controls
//    Shit+TAB , Ctrl+TAB   ->   next/previous controls
//
//  New v3.00 Mouse control -> ON/OFF by "Use Mouse" CheckButton
//    Right click - select control
//    Ctrl key   + Right click - multiselect controls
//    Left down on any selected - move controls
//    Left down on red corner 'first' control - resize controls (all selected)
//    Left down on border 'first' - move/resize only verical or horizontal
//  New v3.50 Select by drag mouse with RightButton down
//
//------------------------------------------------------------------------------
//    ChangeLog
// V3.60
//  + ControlPos can work with form with VIRTUAL WIDTH/HEIGHT and scrolled
//  * Name _ControlPosWndBox_()     -> _ControlPos_C_WndBox_()
//  * Name _ControlPosCSetStyle_()  -> _ControlPos_C_SetStyle_()
//  * Name _ControlPosGetBlockID_() -> _ControlPos_C_GetBlockID_()
// V3.50
//  + Select more controls by RightButtonDown and drag mouse
//    * Change in _ControlPos_FormProc_() , _ControlPos_DrawFocus_()
//    + New _ControlPos_RectSelect_(), _ControlPos_C_RectIn_()
// V3.42
//  * Properties font: BOLD, ITALIC, UNDERLINE and STRCKEOUT changed by
//    dialog MsgYesNoCancel()
//  * In "properties": 2 options like FONT BOLD ON/OFF -> 1 option Font BOLD
// V3.40
//  * Change procedure for modify source definitions (*.FMG *.PRG)
//    + new functions _ControlPos_ModFMG_() , _ControlPos_ModFMGCon_() ,
//      _ControlPos_ModFMGProp_() and delete _ControlPosSaveToFMG_()
//    + New procedure can add/del/modify changed properites
//    * New procedure work with all definition syntaxt (You can mix syntaxt)
//    + Check for AUTOSIZE propertie and do not add WIDTH and HEIGHT
//  * Save dialog show name selected form
// V3.30
//  * Back RETURN 0 in _ControlPos_FormProc_() and add in CALLBACK MyFormProc ()
//    capture WM_CONTEXTMENU with return non zero (see V3.21)
//  + Snap to Grid with mouse
//    + Spinner to set value of step grid (zero - no grid)
//    + New function _ControlPos_C_DrawGrid_(hForm,nGrid) - draw grid points
//    * change in _ControlPos_MoveControl_() and _ControlPos_DrawFocus_() to
//      work with snap to grid
//  - Error in save to *.pos in MGIDE sytaxt: I change "FONTCOLOR" to "COLOR"
//  * and same small change and clean code  :)
// V3.21
//  * In function _ControlPos_FormProc_() last RETURN 0 change to RETURN 1 ,
//    so if form have context menu it is not popup
// V3.20
//  + Dialog with options after SAVE button click
//  * To operation STACK H/V add dialog for input extra spaces
//  * Change backcolor in combos "properties" and "operations"
// V3.10
//  + Shift+Alt+RightMouseButton -> set Z-order to bottom of control
//    under mouse (sample You first define Frame_1 and next other controls
//    "on" this Frame_1, but function ChildWindowFromPoint() find only Frame_1;
//    if You RClick+Shift+Alt on Frame_1, Frame_1 set back and You may select
//    controls on Frame_1)
//  + LeftMouseButton over left border of "first" - move only HORIZONTAL
//  + LeftMouseButton over top border of "first" - move only VERTICAL
//  + Add operations "Center HORIZONTAL/VERTICAL on form"
// v3.00
//  + Mouse operation (ON/OFF by "Use Mouse" button)
//     RigtMouseButon - select "first"
//     Ctrl+RigtMouseButon  - select / deselect multiple controls
//     LeftMouseButton over one of selected controls - move selected controls
//     LeftMouseButton over right-bottom of "first" (red dot) - resize ALL selected contols
//     LeftMouseButton over bottom border "first" - resize HEIGHT
//     LeftMouseButton over right border "first" - resize WIDTH
//  * Change saved file *.POS (another arrange, write changed properties)
//  - still not save changed properties to sourec files *.FMG , *.PRG  :(
// v2.00
//  + Chage same properties same controls (begining, work, but not save to file)
//  + Add operation "EXTRA SAVE FOR UNDO" - save positon selected controls
// v1.08
//  + Add operation "UNDO LAST" - back positon/size controls
//  * Modify code operation spread and stack for if "first" is on right or bottom
// v1.07
// * change method drawing boxes from 4 x drawline() to my function _ControlPosDrawBox()
//   + function _ControlPosDrawBox_(cWindow,nTop,nLeft,nBottom,nRight,aColor)
//   + _ControlPosWndBox_ (function in C )
//
//------------------------------------------------------------------------------
// #define __SYSDATA__

#include <minigui.ch>
#include "ide.ch"

#define _CONTROLPOS_COLOR1_  {0,0,255}
#define _CONTROLPOS_COLOR2_  {255,0,255}

MEMVAR _ControlPosFirst_
MEMVAR _ControlPosProperty_
MEMVAR _ControlPosSizeRect_
MEMVAR _ControlPos_Save_Option_

*------------------------------------------------------------*
FUNCTION ControlPosSTART()
*------------------------------------------------------------*
  PUBLIC _ControlPosFirst_        := 0
  PUBLIC _ControlPosProperty_     := {}
  PUBLIC _ControlPosSizeRect_     := {-100,-100,0,0}
  PUBLIC _ControlPos_Save_Option_ := {1,.F.,.T.,.F.,.T.}

  IF IsWindowDefined(_ControlPos_)
     RETURN Nil
  ENDIF

  DEFINE WINDOW _ControlPos_ ;
       AT 0 , 0 ;
       WIDTH 194 ;
       HEIGHT 570+IF(IsXPThemeActive(),6,0) ;
       TITLE "Form's controls" ;
       TOPMOST ;
       NOMAXIMIZE NOSIZE ;
       ON INTERACTIVECLOSE _ControlPosClose()

     ON KEY SHIFT+Left    ACTION _ControlPosSet_ON_KEY_( "L"    )
     ON KEY SHIFT+Right   ACTION _ControlPosSet_ON_KEY_( "R"    )
     ON KEY SHIFT+Up      ACTION _ControlPosSet_ON_KEY_( "U"    )
     ON KEY SHIFT+Down    ACTION _ControlPosSet_ON_KEY_( "D"    )
     ON KEY CONTROL+Left  ACTION _ControlPosSet_ON_KEY_( "W-"   )
     ON KEY CONTROL+Right ACTION _ControlPosSet_ON_KEY_( "W+"   )
     ON KEY CONTROL+Up    ACTION _ControlPosSet_ON_KEY_( "H-"   )
     ON KEY CONTROL+Down  ACTION _ControlPosSet_ON_KEY_( "H+"   )
     ON KEY SHIFT+TAB     ACTION _ControlPosSet_ON_KEY_( "TAB"  )
     ON KEY CONTROL+TAB   ACTION _ControlPosSet_ON_KEY_( "TAB-" )

     DEFINE LABEL _ControlPosLabelForm_
         ROW    6
         COL    10
         WIDTH  70
         HEIGHT 16
         VALUE "Forms"
         FONTSIZE 12
     END LABEL

     DEFINE LISTBOX _ControlPosListForm_
         ROW    24
         COL    10
         WIDTH  170
         HEIGHT 37
         ITEMS {}
         VALUE 0
         ONCHANGE nil && _ControlPosListFormChange_()
     END LISTBOX

     DEFINE CHECKBUTTON _ControlPosUseMouseButton_
         ROW    64
         COL    10
         WIDTH  72
         HEIGHT 23
         CAPTION "Use mouse"
         TOOLTIP "RButton - select, Ctrl+RButton - mulitselect, LButton - move/size, Shift+Alt+RButton - Z-order to bottom"
         ON CHANGE _ControlPos_SetFormProc_(_ControlPos_._ControlPosUseMouseButton_.value)
     END CHECKBUTTON

     DEFINE LABEL _ControlPosLabelGrid_
         ROW    66
         COL    100
         WIDTH  30
         HEIGHT 17
         VALUE "Grid"
         FONTSIZE 12
     END LABEL

     DEFINE SPINNER _ControlPosGridSpinner_
         ROW    64
         COL    133
         WIDTH  47
         HEIGHT 20
         RANGEMIN 0
         RANGEMAX 50
         INCREMENT 5
         ONCHANGE _ControlPosListControlChange_()
     END SPINNER

     DEFINE LABEL _ControlPosLabelControl_
         ROW    94
         COL    10
         WIDTH  54
         HEIGHT 17
         VALUE "Controls"
         FONTSIZE 12
     END LABEL

     DEFINE COMBOBOX _ControlPosComboSort_
         ROW    87
         COL    90
         WIDTH  90
         HEIGHT 100
         ITEMS {'No SORT','SORT Horiz.','SORT Vert.'}
         VALUE 1
         ONCHANGE _ControlPosButtonGetClick_()
     END COMBOBOX

     DEFINE LISTBOX _ControlPosListControl_
         ROW    112
         COL    10
         WIDTH  170
         HEIGHT 330
         ITEMS {}
         VALUE 0
         MULTISELECT .T.
         ONCHANGE _ControlPosListControlChange_()
     END LISTBOX

     DEFINE COMBOBOX _ControlPosCProp_
         ROW    450
         COL    10
         WIDTH  170
         HEIGHT 500
         ITEMS {'** CHOICE PROPERTY **','Align LEFT','Align RIGHT','Align CENTER','VALUE/CAPTION','FONT COLOR/FORE COLOR','BACK COLOR','Font NAME','Font SIZE','Font BOLD','Font ITALIC','Font UNDERLINE','Font STRICKEOUTF' }
         VALUE 1
         BACKCOLOR {128,255,255}
         ONCHANGE _ControlPosCPropChange_()
     END COMBOBOX

     DEFINE COMBOBOX _ControlPosCombo_
         ROW    480
         COL    10
         WIDTH  170
         HEIGHT 500
         ITEMS {'** CHOICE OPERATION **','Align LEFT','Align RIGHT','Align TOP','Align BOTTOM','Center HORIZONTAL','Center VERTICAL','Stack HORIZONTAL','Stack VERTICAL','Spread HORIZONTAL','Spread VERTICAL','Make same HEIGHT','Make same WIDTH','Center VERTICAL on Form','Center HORIZONTAL on Form',' ** EXTRA SAVE FOR UNDO **','    *** UNDO LAST ***'}
         VALUE 1
         BACKCOLOR {255,255,128}
         ONCHANGE _ControlPosComboChange_()
     END COMBOBOX

     DEFINE BUTTON _ControlPosButtonGet_
         ROW    510
         COL    10
         WIDTH  80
         HEIGHT 25
         CAPTION "Undo"
         ACTION undo_changes() && _ControlPosButtonGetClick_()
         TOOLTIP "Undo changes"
     END BUTTON

     DEFINE BUTTON _ControlPosButtonSave_
         ROW    510
         COL    98
         WIDTH  84
         HEIGHT 25
         CAPTION "Save"
         ACTION _ControlPosButtonSaveClick_()
         TOOLTIP "Save changes"
     END BUTTON

  END WINDOW

  _ControlPos_.row := 168
  _ControlPos_.col := GetDesktopWidth() - 194
  _ControlPos_.Show()

  // _SetActivationFlag(GetFormIndex("_ControlPos_"))

  _ControlPosButtonGetClick_()

RETURN Nil


*------------------------------------------------------------*
FUNCTION _ControlPosCPropChange_
*------------------------------------------------------------*
   LOCAL typ := _ControlPos_._ControlPosCProp_.Value
   LOCAL cF
   LOCAL cK
   LOCAL x
   LOCAL cT
   LOCAL p
   LOCAL opt
   LOCAL v
   LOCAL fx
   LOCAL i
   LOCAL av
   LOCAL aProp := { ;
         /* {class name, map avaliable properties } */ ;
         /*                  123456789012   */         ;
                    {'BROWSE',      '000011111111'},;
                    {'BUTTON',      '000200111111'},;
                    {'BTNTEXT',     '000011111111'},;
                    {'BTNNUMTEXT',  '000011111111'},;
                    {'OBUTTON',     '000211111111'},;
                    {'CHECKBOX',    '220211111111'},;
                    {'CHECKBUTTON', '000200111111'},;
                    {'COMBO',       '000011111111'},;
                    {'DATEPICK',    '000011111111'},;
                    {'EDIT',        '000011111111'},;
                    {'FRAME',       '000211111111'},;
                    {'GETBOX',      '000011111111'},;
                    {'GRID',        '000011111111'},;
                    {'MULTIGRID',   '000011111111'},;
                    {'HOTKEYBOX',   '000000111111'},;
                    {'HYPERLINK',   '000111111100'},;
                    {'IPADDRESS',   '000000111111'},;
                    {'LABEL',       '111111111111'},;
                    {'LIST',        '000011111111'},;
                    {'MULTILIST',   '000011111111'},;
                    {'MONTHCAL',    '000011111111'},;
                    {'PROGRESSBAR', '000021000000'},;
                    {'RADIOGROUP',  '220011111111'},;
                    {'RICHEDIT',    '000111111111'},;
                    {'SLIDER',      '000001000000'},;
                    {'SPINNER',     '000011111111'},;
                    {'TAB',         '000000111111'},;
                    {'TEXT',        '000011111111'},;
                    {'NUMTEXT',     '000011111111'},;
                    {'TIMEPICK',    '000000111111'},;
                    {'TREE',        '000011111111'}   }

                    // ** PROPERTIES  **
                    // 1 - 'Align LEFT'      (1-style ES_  2-style BS_ )
                    // 2 - 'Align RIGHT'     (1-style ES_  2-style BS_ )
                    // 3 - 'Align CENTER'
                    // 4 - 'VALUE/CAPTION'   (1-VALUE, 2-CAPTION)
                    // 5 - 'FONT COLOR / FORE COLOR"  (1-Font 2-Fore)
                    // 6 - 'BACK COLOR'
                    // 7 - 'FONT NAME'
                    // 8 - 'FONT SIZE'
                    // 9 - 'font BOLD'
                    // 10 - 'font ITALIC'
                    // 11 - 'font UNDERLINE'
                    // 12 - 'font STRICKEOUT'


   IF typ == 1
      RETURN NIL
   ELSE
      typ--
   ENDIF

   _ControlPos_._ControlPosCProp_.Value := 1

   //cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
   cF := "Form_1"

   /*
   IF " !SPLITED!" $ cF
      RETURN nil
   ENDIF
   */

   cK := _ControlPos_._ControlPosListControl_.Item( _ControlPosFirst_ )
   x  := GetControlIndex( cK, cF )
   cT := _HMG_aControlType[ x ]

   IF ct == "CHECKBOX"             // !!! ALSO SAME IS IDENTICAL !!!
      IF ValType( _HMG_aControlPageMap[x] ) == "A"   //maybe it's correct ?
         ct := "CHECKBUTTON"
      ENDIF
   ENDIF

   IF ! (( p := AScan( aProp, { | aa | aa[ 1 ] == cT } ) ) == 0 )

     IF ! ( ( opt := SubStr( aProp[ p, 2 ], Typ, 1 ) ) == '0')
        DO CASE
           CASE typ == 4  .AND. opt=='1'  //value
                v := GetProperty(cF,cK,"Value")
                v := InputBox("Input value","ControlPos",v)
                IF _HMG_DialogCancelled
                   RETURN NIL
                ENDIF

           CASE Typ == 4  .AND. opt == "2"  //caption
                v := GetProperty( cF, cK, "Caption" )
                v := InputBox("Input caption","ControlPos",v)
                IF _HMG_DialogCancelled
                   RETURN NIL
                ENDIF

           CASE typ == 5  .AND. opt=='1'  //  FONT COLOR
                v := GetProperty( cF, cK, "FontColor" )
                v := GetColor( v )
                IF v[1] == NIL
                   RETURN NIL
                ENDIF

           CASE typ == 5  .AND. opt=="2" //  FORE COLOR
                v := GetProperty( cF, cK, "ForeColor" )
                v := GetColor( v )
                IF v[1] == NIL
                   RETURN NIL
                ENDIF

           CASE typ == 6                //  BACK COLOR
                v := GetProperty( cF, cK, "BackColor" )
                v := GetColor( v )
                IF v[1] == NIL
                   RETURN NIL
                ENDIF

           CASE typ == 7  //  FONT Name
                v := GetProperty( cF, cK, "FontName" )   //we won't only NAME !
                v := GetFont( v )
                IF v[1] == ""
                   RETURN nil
                ELSE
                   v := v[1]
                ENDIF

           CASE typ == 8  //  FONT Size
                v := AllTrim( Str( GetProperty( cF, cK, "FontSize" ) ) )
                v := InputBox( "Input font size", "ControlPos", v )
                IF _HMG_DialogCancelled .OR. (v:=Val(v))<=0
                   RETURN nil
                ENDIF

           CASE Typ >= 9 .AND. Typ <= 12
                v := "Change font " + { "BOLD", "ITALIC", "UNDERLINE", "STRICKEOUT" }[ typ - 8 ] + " state ?" + Chr(10) + Chr(10) + "YES -> set ON   ,  NO -> set OFF"
                v := MsgYesNoCancel( v, "ControlPos" )
                IF v < 0
                   RETURN NIL
                ELSE
                   v := ( v == 1 )
                ENDIF

        ENDCASE

       ENDIF

   ENDIF

   av := _ControlPos_._ControlPosListControl_.Value

   FOR i := 1 TO Len( av )

       cK := _ControlPos_._ControlPosListControl_.Item( av[i] )
       x  := GetControlIndex( cK, cF )
       cT := _HMG_aControlType[ x ]

       IF ct == "CHECKBOX"             // !!! ALSO SAME IS IDENTICAL !!!
          IF ValType( _HMG_aControlPageMap[x] ) == "A"   //maybe it's correct ?
             ct := "CHECKBUTTON"
          ENDIF
       ENDIF

       IF ( p := AScan( aProp,{ | aa | aa[ 1 ] == cT } ) ) == 0
          LOOP
       ENDIF

       IF ( opt := SubStr( aProp[ p, 2 ], Typ, 1 ) ) == '0'
          LOOP
       ENDIF

       DO CASE
          CASE typ == 1  // Align LEFT
               IF opt=='1'  // LABEL
                  _ControlPos_SetStyle_(cF,cK,0x0003,.F.)   // off ES_CENTER & ES_RIGHT
               ENDIF

               IF opt=='2'  // CHECKBOX
                  _ControlPos_SetStyle_(cF,cK,0x0020,.T.)   // on BS_LEFTTEXT
               ENDIF
               _ControlPosMemberProp_(cF,cK,"ALIGN","L")

          CASE typ == 2  // Align RIGHT
               IF opt=='1'  // for LABEL
                  _ControlPos_SetStyle_(cF,cK,0x0003,.F.)   //off ES_CENTER & ES_RIGHT
                  _ControlPos_SetStyle_(cF,cK,0x0002,.T.)   //on ES_RIGHT
               ENDIF

               IF opt=='2'  // for CHECKBOX
                  _ControlPos_SetStyle_(cF,cK,0x0020,.F.)   // off BS_LEFTTEXT
               ENDIF
               _ControlPosMemberProp_(cF,cK,"ALIGN","R")

          CASE typ == 3  // Align CENTER
               _ControlPos_SetStyle_(cF,cK,0x0003,.F.)   //off ES_CENTER & ES_RIGHT
               _ControlPos_SetStyle_(cF,cK,0x0001,.T.)   //on ES_CENTER
               _ControlPosMemberProp_(cF,cK,"ALIGN","C")

          CASE typ == 4  //  VALUE/CAPTION
               IF opt=='1' //Value
                  SetProperty(cF,cK,'VALUE',v)
                  _ControlPosMemberProp_(cF,cK,"VALUE",v)
               ENDIF

               IF opt=='2' //Caption
                  SetProperty(cF,cK,'CAPTION',v)
                  _ControlPosMemberProp_(cF,cK,"CAPTION",v)
               ENDIF

          CASE typ == 5  //  FONT COLOR
               SetProperty(cF,cK,'FontColor',v)
               _ControlPosMemberProp_(cF,cK,"FONTCOLOR",v)

          CASE typ == 6  //  BACK COLOR
               SetProperty(cF,cK,'BackColor',v)
               _ControlPosMemberProp_(cF,cK,"BACKCOLOR",v)

          CASE typ == 7  //  FONT Name
               SetProperty(cF,cK,'FontName',v)
               _ControlPosMemberProp_(cF,cK,"FONTNAME",v)

          CASE typ == 8  //  FONT Size
               SetProperty(cF,cK,'FontSize',v)
               _ControlPosMemberProp_(cF,cK,"FONTSIZE",v)

          CASE typ >= 9 .AND. typ <=12   // font BOLD,ITALIC,UNDERLINE,STRICKEOUT
               fx := {"FONTBOLD","FONTITALIC","FONTUNDERLINE","FONTSTRIKEOUT"}[typ-8]
               SetProperty(cF,cK,fx,v) //.T.)
               _ControlPosMemberProp_(cF,cK,fx,v) //.T.)

       ENDCASE

    NEXT

   _ControlPosListControlChange_()

RETURN nil


*------------------------------------------------------------*
FUNCTION _ControlPosClose()
*------------------------------------------------------------*
   local cF := "Form_1"

   // Desativating mouse operations
   IF _ControlPos_._ControlPosUseMouseButton_.Value

      _ControlPos_._ControlPosUseMouseButton_.Value := .F.
      _ControlPos_SetFormProc_( .F., .F. )
   ENDIF

   // need to restore form_1.Title
   IF _IsWindowDefined( cF )

      ERASE WINDOW &cF

      RedrawWindow( GetFormHandle( cF ) )

      IF MsgYesNo("Save changes?",'HMGS-IDE')
         _ControlPosButtonSaveClick_()
      ENDIF

   ENDIF

RETURN NIL


*------------------------------------------------------------*
FUNCTION _ControlPosMemberProp_(cF,cK,cProp,xVal)
*------------------------------------------------------------*
   STATIC aChange := {}
   LOCAL p

   IF cF == nil
      aChange := {}
      RETURN nil
   ENDIF

   IF cK==nil
      RETURN aChange
   ENDIF

   cF    := Upper( cF )
   cK    := Upper( cK )
   cProp := Upper( cProp )

   IF ( p := AScan( aChange, { | aa | aa[1] == cF .AND. aa[2] == cK .AND. aa[3] == cProp } ) ) == 0
      AAdd( aChange, { cF, cK, cProp, xVal } )
   ELSE
      aChange[ p, 4 ] := xVal
   ENDIF

RETURN nil


*------------------------------------------------------------*
FUNCTION _ControlPosButtonGetClick_()
*------------------------------------------------------------*
   LOCAL i
   LOCAL lMouse
   LOCAL nForm

   IF (lMouse := _ControlPos_._ControlPosUseMouseButton_.Value)
     _ControlPos_._ControlPosUseMouseButton_.Value := .F.
     _ControlPos_SetFormProc_(.F.,.F.)
   ENDIF

   //nForm:=_ControlPos_._ControlPosListForm_.Value
   nForm := 1

   _ControlPos_._ControlPosListForm_.DeleteAllitems()

   // FOR i:=1 TO Len(_HMG_aFormNames)
   ///  IF _HMG_aFormNames[i] != '_ControlPos_'
   //     IF _HMG_aFormReBarHandle[i] == 0
   //        _ControlPos_._ControlPosListForm_.AddItem( _HMG_aFormNames[i] )
   //     ELSE
   //        _ControlPos_._ControlPosListForm_.AddItem( _HMG_aFormNames[i]+" !SPLITED!" )
   //     ENDIF
   //   ENDIF
   //NEXT

   _ControlPos_._ControlPosListForm_.AddItem( "Form_1" )
   _ControlPos_._ControlPosListForm_.Value := iif( nForm > 0, nForm, 1 )

   _ControlPosListFormChange_()
   _ControlPos_._ControlPosListControl_.SetFocus()

   IF lMouse
     _ControlPos_._ControlPosUseMouseButton_.Value := .T.
     _ControlPos_SetFormProc_(.T.)
   ENDIF

RETURN Nil


*------------------------------------------------------------*
FUNCTION _ControlPosListFormChange_()
*------------------------------------------------------------*
   LOCAL i
   LOCAL h
   LOCAL p
   LOCAL ak     := {}
   LOCAL lMouse

   STATIC cForm := "Form_1"

   IF (lMouse:=_ControlPos_._ControlPosUseMouseButton_.value)
     _ControlPos_._ControlPosUseMouseButton_.value := .F.
     _ControlPos_SetFormProc_(.F.,.F.)
   ENDIF

   IF ! (cForm == "" .OR. " !SPLITED!" $ cForm)
      //  ERASE WINDOW &cForm
      _ControlPosAddDelGraph_( cForm, "D" )

      RedrawWindow(GetFormHandle( cForm ) )

      RELEASE KEY SHIFT+Left    OF &cForm
      RELEASE KEY SHIFT+Right   OF &cForm
      RELEASE KEY SHIFT+Up      OF &cForm
      RELEASE KEY SHIFT+Down    OF &cForm
      RELEASE KEY CONTROL+Left  OF &cForm
      RELEASE KEY CONTROL+Right OF &cForm
      RELEASE KEY CONTROL+Up    OF &cForm
      RELEASE KEY CONTROL+Down  OF &cForm
      RELEASE KEY SHIFT+Tab     OF &cForm
      RELEASE KEY CONTROL+Tab   OF &cForm
   ENDIF

   // h     := _ControlPos_._ControlPosListForm_.value
   // cForm := _ControlPos_._ControlPosListForm_.Item(h)
   _ControlPos_._ControlPosListControl_.DeleteAllitems()

   /*
   IF " !SPLITED!" $ cForm
     RETURN nil
   ENDIF
   */

   h := GetFormHandle( cForm ) //_HMG_aFormHandles[h]

   //IF _ControlPos_._ControlPosCheckSort_.Value
   IF _ControlPos_._ControlPosComboSort_.Value == 2
      FOR i := 1 TO Len( _HMG_aControlNames )
         IF _HMG_aControlParentHandles[i] == h
                //type control not to use "@type@"
            IF !("@"+Upper(_HMG_aControlType[i])+"@" $ "@HOTKEY@@MENU@@POPUP@@TOOLBAR@@TOOLBUTTON@@MESSAGEBAR@@ITEMMESSAGE@@TIMER@")
               p := Str(_HMG_aControlContainerRow[i]+1,4,0)
               p += Str(_HMG_aControlContainerCol[i]+1,4,0)
               // p += Str(PAGE_of_TAB)  I want include numer of PAGE in TAB , but I don't known how :(
               p += Str(Int(_HMG_aControlRow[i]/20), 4, 0 )
                                            //  ^^   round to 20 points lines
               p += Str(  _HMG_aControlCol[i], 4, 0 )
               AAdd( ak,{ _HMG_aControlNames[i], p } )
            ENDIF
         ENDIF
      NEXT

      ASort(ak,,,{|x,y|x[2]<y[2]})

      FOR i:= 1 TO Len(ak)
          _ControlPos_._ControlPosListControl_.AddItem( ak[i,1] )
      NEXT

   ELSEIF _ControlPos_._ControlPosComboSort_.Value == 3
     FOR i:=1 TO Len(_HMG_aControlNames)
        IF _HMG_aControlParentHandles[i] == h
               //type control not to use "@type@"
           IF !("@"+Upper(_HMG_aControlType[i])+"@" $ "@HOTKEY@@MENU@@POPUP@@TOOLBAR@@TOOLBUTTON@@MESSAGEBAR@@ITEMMESSAGE@@TIMER@")
              p := Str(_HMG_aControlContainerCol[i]+1,4,0)
              p += Str(_HMG_aControlContainerRow[i]+1,4,0)
     // p += Str(PAGE_of_TAB)  I want include numer of PAGE in TAB , but I don't known how :(
              p += Str(Int(_HMG_aControlCol[i]/20),4,0)
                                           //  ^^   round to 20 points lines
              p += Str(_HMG_aControlRow[i],4,0)
              AAdd(ak,{_HMG_aControlNames[i],p})
           ENDIF
        ENDIF
     NEXT
     ASort(ak,,,{|x,y|x[2]<y[2]})
     FOR i:= 1 TO Len(ak)
       _ControlPos_._ControlPosListControl_.AddItem( ak[i,1] )
     NEXT
   ELSEIF _ControlPos_._ControlPosComboSort_.Value == 1
     FOR i:=1 TO Len(_HMG_aControlNames)
        IF _HMG_aControlParentHandles[i] == h
               //type control not to use "@type@"
           IF !("@"+Upper(_HMG_aControlType[i])+"@" $ "@HOTKEY@@MENU@@POPUP@@TOOLBAR@@TOOLBUTTON@@MESSAGEBAR@@ITEMMESSAGE@@TIMER@")
              _ControlPos_._ControlPosListControl_.AddItem( _HMG_aControlNames[i] )
           ENDIF
        ENDIF
     NEXT
   ENDIF

   ON KEY SHIFT+Left    OF &cForm ACTION _ControlPosSet_ON_KEY_( "L" )
   ON KEY SHIFT+Right   OF &cForm ACTION _ControlPosSet_ON_KEY_( "R" )
   ON KEY SHIFT+Up      OF &cForm ACTION _ControlPosSet_ON_KEY_( "U" )
   ON KEY SHIFT+Down    OF &cForm ACTION _ControlPosSet_ON_KEY_( "D" )
   ON KEY CONTROL+Left  OF &cForm ACTION _ControlPosSet_ON_KEY_( "W-" )
   ON KEY CONTROL+Right OF &cForm ACTION _ControlPosSet_ON_KEY_( "W+" )
   ON KEY CONTROL+Up    OF &cForm ACTION _ControlPosSet_ON_KEY_( "H-" )
   ON KEY CONTROL+Down  OF &cForm ACTION _ControlPosSet_ON_KEY_( "H+" )
   ON KEY SHIFT+TAB     OF &cForm ACTION _ControlPosSet_ON_KEY_( "TAB" )
   ON KEY CONTROL+TAB   OF &cForm ACTION _ControlPosSet_ON_KEY_( "TAB-" )

   _ControlPos_._ControlPosListControl_.Value := { 1 }

   IF lMouse
      _ControlPos_._ControlPosUseMouseButton_.Value := .T.
      _ControlPos_SetFormProc_(.T.)
   ELSE
      _ControlPosListControlChange_()
   ENDIF

RETURN NIL


*------------------------------------------------------------*
FUNCTION _ControlPosListControlChange_()
*------------------------------------------------------------*
   LOCAL cF
   LOCAL cK
   LOCAL r
   LOCAL c
   LOCAL w
   LOCAL h
   LOCAL x
   LOCAL cr
   LOCAL cc
   LOCAL i
   LOCAL p
   LOCAL is_f  := .F.
   LOCAL nGrid := _ControlPos_._ControlPosGridSpinner_.Value
   LOCAL sx
   LOCAL sy

   //cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
   cF := "FORM_1"
   /*
   IF " !SPLITED!" $ cF
     RETURN nil
   ENDIF
   */

   _ControlPosAddDelGraph_( cF, "D" )

   RedrawWindow(GetFormHandle( cF ) )

   sx := GetProperty(cF,"HSCROLLBAR","VALUE")
   sy := GetProperty(cF,"VSCROLLBAR","VALUE")

   IF Len(_ControlPos_._ControlPosListControl_.value) == 1
     _ControlPosFirst_ := _ControlPos_._ControlPosListControl_.value[1]
   ENDIF

   FOR i := 1 TO  Len( _ControlPos_._ControlPosListControl_.Value )

      p  := _ControlPos_._ControlPosListControl_.Value[i]
      cK := _ControlPos_._ControlPosListControl_.Item( p )
      r  := GetProperty( cF, cK, "ROW")
      c  := GetProperty( cF, cK, "COL")
      w  := GetProperty( cF, cK, "WIDTH")
      h  := GetProperty( cF, cK, "HEIGHT")
      x  := GetControlIndex( cK, cF )
      cr := _HMG_aControlContainerRow[ x ]
      cc := _HMG_aControlContainerCol[ x ]

      IF  p == _ControlPosFirst_
          // SetProperty(cF,"Title"," r:"+Str(r,4)+"  c:"+Str(c,4)+"  w:"+Str(w,4)+"  h:"+Str(h,4) )

         is_f := .T.
         _ControlPosSizeRect_[3] := w
         _ControlPosSizeRect_[4] := h

         IF cr == -1
            _ControlPosSizeRect_[1] := c + w - sx
            _ControlPosSizeRect_[2] := r + h - sy
         ELSE
            _ControlPosSizeRect_[1] := c + w + cc - sx
            _ControlPosSizeRect_[2] := r + h + cr - sy
         ENDIF
      ENDIF

      IF cr == -1
         _ControlPosDrawBox_( cF, c-sx, r-sy, w, h, iif( _ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_ ) )
         _ControlPosAddDelGraph_( cF )

         IF _ControlPosFirst_== p .AND. _ControlPos_._ControlPosUseMouseButton_.Value
            // _ControlPosDrawBox_(cF,r+h-1,c+w-1,r+h+1,c+w+1,{255,0,0})
            DrawRect(cF,r+h-3-sy,c+w-3-sx,r+h+1-sy,c+w+1-sx,{255,0,0},2,{255,0,0})
            _ControlPosAddDelGraph_( cF )
         ENDIF

      ELSE  //on container like TAB
         _ControlPosDrawBox_( cF, c+cc-sx,r+cr-sy,w,h,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_))
         _ControlPosAddDelGraph_( cF )

         IF _ControlPosFirst_== p
            // _ControlPosDrawBox_(cF,r+h+cr-1,c+w+cc-1,r+h+cr+1,c+w+cc+1,{255,0,0})
            DrawRect( cF, r+h-3+cr-sy, c+w-3+cc-sx, r+h+1+cr-sy, c+w+1+cc-sx, {255,0,0}, 2, {255,0,0} )
            _ControlPosAddDelGraph_( cF )
         ENDIF

      ENDIF

   NEXT

   IF ! is_F
      _ControlPosSizeRect_[1]:=-100
      _ControlPosSizeRect_[2]:=-100
   ENDIF

   IF _ControlPos_._ControlPosUseMouseButton_.Value .AND. nGrid > 0
      _ControlPos_C_DrawGrid_( GetFormHandle( cF ), nGrid, sx, sy )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION _ControlPosSet_ON_KEY_( cTyp )
*------------------------------------------------------------*
   LOCAL cF
   LOCAL cK
   LOCAL r
   LOCAL c
   LOCAL w
   LOCAL h
   LOCAL fh
   LOCAL fw
   LOCAL x
   LOCAL cr
   LOCAL cc
   LOCAL i
   LOCAL p
   LOCAL sx
   LOCAL sy
   LOCAL hK
   LOCAL aRect := { 0, 0, 0, 0 }
   LOCAL fr
   LOCAL fc

   STATIC nPress := 0

   //cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
   cF := "Form_1"

   /*
   IF " !SPLITED!" $ cF
     RETURN nil
   ENDIF
   */



   DO CASE
      CASE cTyp == "TAB"
           r := _ControlPosFirst_

           IF r < _ControlPos_._ControlPosListControl_.ItemCount
              r++
           ELSE
              r := 1
           ENDIF

           _ControlPos_._ControlPosListControl_.Value := { r }
           _ControlPosListControlchange_()
           nPress := 0

           RETURN Nil

      CASE cTyp == "TAB-"
           r := _ControlPosFirst_
           IF r > 1
              r--
           ELSE
              r := _ControlPos_._ControlPosListControl_.ItemCount
           ENDIF
           _ControlPos_._ControlPosListControl_.Value := { r }
           _ControlPosListControlchange_()

           nPress := 0
           RETURN Nil

   ENDCASE

   sx := GetProperty( cF, "HSCROLLBAR", "VALUE" )   //virtual positons
   sy := GetProperty( cF, "VSCROLLBAR", "VALUE" )
   fr := GetProperty( cF, "ROW" ) + GetBorderHeight() + GetTitleHeight()

   IF GetMenu(GetFormHandle(cF)) != 0
     fr:=fr + GetMenuBarHeight()
   ENDIF

   fc := GetProperty(cF,"COL")+GetBorderWidth()

   IF nPress < 1
     _ControlPosAddDelGraph_( cF, "D" )
     RedrawWindow( GetFormHandle( cF ) )
  ENDIF

   nPress++

   FOR i := 1 TO Len(_ControlPos_._ControlPosListControl_.Value )
       p  := _ControlPos_._ControlPosListControl_.value[i]
       cK := _ControlPos_._ControlPosListControl_.Item( p )
       x  := GetControlIndex( cK, cF )
       r  := GetProperty( cF, cK, "ROW" )
       c  := GetProperty( cF, cK, "COL" )
       w  := GetProperty( cF, cK, "WIDTH" )
       h  := GetProperty( cF, cK, "HEIGHT" )
       fw := GetProperty( cF, "WIDTH" )
       fh := GetProperty( cF, "HEIGHT" )
       cr := _HMG_aControlContainerRow[ x ]
       cc := _HMG_aControlContainerCol[ x ]
       hK := _HMG_aControlHandles[ x ]

       DO CASE
          CASE cTyp == "U"
               IF r > 0
                  r--
               ENDIF

          CASE cTyp == "D"
               // IF r < fh - h
               r++
               // ENDIF

          CASE cTyp == "L"
              // IF c > 0
              c--
              // ENDIF

          CASE cTyp == "R"
               // IF c < fw - w
               c++
               // ENDIF

          CASE cTyp == "H-"
               IF h > 0
                  h--
               ENDIF

          CASE cTyp == "H+"
               // IF h < fh - r
               h++
               // ENDIF

         CASE cTyp == "W-"
              IF w > 0
                 w--
              ENDIF

         CASE cTyp == "W+"
              // IF w < fw - c
              w++
              // ENDIF
      ENDCASE

      _SetControlSizePos(cK, cF, r, c, w, h)

      IF ValType(hK)=="A"
         FOR p := 1 TO Len( hk )
             GetWindowRect( hK[ p ], aRect )
             MoveWindow(hK[p],aRect[1]-sx-fc,aRect[2]-sy-fr,aRect[3]-aRect[1],aRect[4]-aRect[2],.T.)
         NEXT
      ELSE
         MoveWindow( hK, c-sx, r-sy, w, h, .T. )
      ENDIF

   NEXT

   RedrawWindow( GetFormHandle( cF ) )

   DO EVENTS

   nPress--
   IF nPress < 1
     _ControlPosListControlchange_()
     nPress := 0
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION _ControlPosComboChange_()
*------------------------------------------------------------*
  LOCAL typ    := _ControlPos_._ControlPosCombo_.value
  LOCAL cF
  LOCAL cK
  LOCAL fr
  LOCAL fc
  LOCAL fw
  LOCAL fh
  LOCAL ak     :={}
  LOCAL r
  LOCAL c
  LOCAL w
  LOCAL h
  LOCAL i
  LOCAL av
  LOCAL m1     := 0
  LOCAL m2     := 0
  LOCAL sx
  LOCAL sy
  LOCAL hK
  LOCAL aRect  := { 0, 0, 0, 0 }
  LOCAL formr
  LOCAL formc

  STATIC aundo  :={}
  STATIC nSpace :=0

  IF typ == 1
     RETURN NIL
  ENDIF

//cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
cF := "Form_1"
/*
IF " !SPLITED!" $ cF
  RETURN nil
ENDIF
*/
av:=_ControlPos_._ControlPosListControl_.value

FOR i:=1 TO Len(av)
   cK := _ControlPos_._ControlPosListControl_.Item( av[i] )
   IF av[i] == _ControlPosFirst_
      fr :=  GetProperty(cF,cK,"ROW")
      fc :=  GetProperty(cF,cK,"COL")
      fw :=  GetProperty(cF,cK,"WIDTH")
      fh :=  GetProperty(cF,cK,"HEIGHT")
   ELSE
      r :=  GetProperty(cF,cK,"ROW")
      c :=  GetProperty(cF,cK,"COL")
      w :=  GetProperty(cF,cK,"WIDTH")
      h :=  GetProperty(cF,cK,"HEIGHT")
      AAdd(ak,{cK,r,c,w,h})
    ENDIF
NEXT

IF fr == NIL      //if unselected "FIRST"
  _ControlPos_._ControlPosCombo_.value := 1
  RETURN nil
ENDIF

IF Len(ak)==0 .AND. typ < 14
  _ControlPos_._ControlPosCombo_.value := 1
  RETURN Nil
ENDIF

sx:=GetProperty(cF,"HSCROLLBAR","VALUE")   //virtual positons
sy:=GetProperty(cF,"VSCROLLBAR","VALUE")
formr:=GetProperty(cF,"ROW") + GetBorderHeight() + GetTitleHeight()
IF GetMenu(GetFormHandle(cF)) != 0
  formr:=formr + GetMenuBarHeight()
ENDIF
formc:=GetProperty(cF,"COL")+GetBorderWidth()


IF typ == 16    //EXTRA SAVE TO UNDO
  aUndo:=AClone(ak)
  AAdd(aUndo,{_ControlPos_._ControlPosListControl_.Item( _ControlPosFirst_ ),fr,fc,fw,fh})
  _ControlPos_._ControlPosCombo_.value := 1
  RETURN nil
ENDIF

IF typ == 17    //UNDO LAST
  FOR i:= 1 TO Len(aUndo)
    _SetControlSizePos(aUndo[i,1], cF, aUndo[i,2],aUndo[i,3],aUndo[i,4],aUndo[i,5])
    hK:=GetControlHandle(aUndo[i,1],cF)
    IF ValType(hK)=="A"
      FOR m1:= 1 TO Len(hk)
           GetWindowRect(hK[m1],aRect)
           MoveWindow(hK[m1],aRect[1]-sx-formc,aRect[2]-sy-formr,aRect[3]-aRect[1],aRect[4]-aRect[2],.T.)
      NEXT
    ELSE
      MoveWindow(hK,aUndo[i,3]-sx,aUndo[i,2]-sy,aUndo[i,4],aUndo[i,5],.T.)
    ENDIF
  NEXT
  aUndo := {}
  _ControlPos_._ControlPosCombo_.value := 1
  _ControlPosListControlChange_()
  RETURN nil
ELSE
  aUndo := AClone(ak)
  AAdd(aUndo,{_ControlPos_._ControlPosListControl_.Item( _ControlPosFirst_ ),fr,fc,fw,fh})
ENDIF


DO CASE
  CASE typ == 2   //align left
     FOR i:= 1 TO Len(ak)
        ak[i,3] := fc
     NEXT

  CASE typ == 3   //align right
     FOR i:= 1 TO Len(ak)
        ak[i,3] := fc + fw - ak[i,4]
     NEXT

  CASE typ == 4   //align top
     FOR i:= 1 TO Len(ak)
        ak[i,2] := fr
     NEXT

  CASE typ == 5   //align bottom
     FOR i:= 1 TO Len(ak)
        ak[i,2] := fr + fh - ak[i,5]
     NEXT

  CASE typ == 6   //Center HORIZONTAL
     FOR i:= 1 TO Len(ak)
        ak[i,2] := Round(fr + (fh - ak[i,5])/2 , 0)
     NEXT

  CASE typ == 7   //Center VERICAL
     FOR i:= 1 TO Len(ak)
        ak[i,3] := Round(fc + (fw - ak[i,4])/2 , 0)
     NEXT

  CASE typ == 8   //Stack HORIZONTAL    (jeden za drugim)
     nSpace := InputBox("Input extra space","ControlPos",Str(nSpace))
     IF (nSpace:=INT(Val(nSpace)))<0 .OR. _HMG_DialogCancelled
        RETURN nil
     ENDIF
     nSpace:=INT(nSpace)
     ASort(ak,,,{|x,y|x[3] < y[3]})
     IF fc > ak[1,3]
        ASort(ak,,,{|x,y|x[3] > y[3]})
        FOR i:= 1 TO Len(ak)
           ak[i,3] := (fc:=fc - ak[i,4] - nSpace)
        NEXT
     ELSE
       fc := fc + fw +nSPace
       FOR i:= 1 TO Len(ak)
          ak[i,3] := fc
          fc := fc + ak[i,4] +nSpace
       NEXT
     ENDIF

  CASE typ == 9   //Stack VERTICAL
     nSpace := InputBox("Input extra space","ControlPos",Str(nSpace))
     IF (nSpace:=INT(Val(nSpace)))<0 .OR. _HMG_DialogCancelled
        RETURN nil
     ENDIF
     nSpace:=INT(nSpace)
     ASort(ak,,,{|x,y|x[2] < y[2]})
     IF fr > ak[1,2]
       ASort(ak,,,{|x,y|x[2] > y[2]})
       FOR i:=1 TO Len(ak)
          ak[i,2] := (fr:=fr - ak[i,5] - nSpace)
       NEXT
     ELSE
       fr := fr + fh +nSpace
       FOR i:= 1 TO Len(ak)
          ak[i,2] := fr
          fr := fr + ak[i,5] + nSpace
       NEXT
     ENDIF

  CASE typ == 10  //Spread HORIZONTAL    (równomiernie)
     ASort(ak,,,{|x,y|x[3] < y[3]})
     IF fc > ak[1,3]
        ASort(ak,,,{|x,y|x[3] > y[3]})
        fh := fc - ak[Len(ak),3] - ak[Len(ak),4]
        FOR i:=1 TO Len(ak)-1
           fh := fh - ak[i,4]
        NEXT
        fh := fh / Len(ak)
        fr := fc - ak[1,4] - fh
        FOR i:=1 TO Len(ak)-1
          ak[i,3] := Round(fr ,0)
          fr := fr - ak[i+1,4] - fh
        NEXT
     ELSE
        fh := ak[Len(ak),3] - fc - fw
        FOR i:= 1 TO Len(ak)-1
           fh := fh - ak[i,4]
        NEXT
        fh := fh / Len(ak)
        fr := fc + fw + fh
        FOR i:= 1 TO Len(ak)-1
           ak[i,3] := Round(fr , 0)
           fr := fr + ak[i,4] + fh
        NEXT
     ENDIF

  CASE typ == 11  // Spread VERTICAL
     ASort(ak,,,{|x,y|x[2] < y[2]})
     IF fr > ak[1,2]
       ASort(ak,,,{|x,y|x[2] > y[2]})
       fw := fr - ak[Len(ak),2] - ak[Len(ak),5]
       FOR i:= 1 TO Len(ak)-1
          fw := fw - ak[i,5]
       NEXT
       fw := fw / Len(ak)
       fc := fr - ak[1,5] - fw
       FOR i:= 1 TO Len(ak)-1
          ak[i,2] := Round(fc , 0)
          fc := fc - ak[i+1,5] - fw
       NEXT
     ELSE
       fw := ak[Len(ak),2] - fr - fh
       FOR i:= 1 TO Len(ak)-1
          fw := fw - ak[i,5]
       NEXT
       fw := fw / Len(ak)
       fc := fr + fh + fw
       FOR i:= 1 TO Len(ak)-1
          ak[i,2] := Round(fc , 0)
          fc := fc + ak[i,5] + fw
       NEXT
     ENDIF

  CASE typ == 12  //Make same HEIGHT
     FOR i:= 1 TO Len(ak)
        ak[i,5] := fh
     NEXT

  CASE typ == 13  //Make same WIDTH
     FOR i:= 1 TO Len(ak)
        ak[i,4] := fw
     NEXT

  CASE typ == 14  //Center VERTICAL on Form
     m1:=fr
     m2:=fr+fh
     FOR i:= 1 TO Len(ak)
        m1:=Min(m1,ak[i,2])
        m2:=Max(m2,ak[i,2]+ak[i,5])
     NEXT
     m2:=INT((GetProperty(cF,"HEIGHT") - m2 + m1)/2)
     m1:=m1-m2
     FOR i:= 1 TO Len(ak)
        ak[i,2]:=ak[i,2]-m1
     NEXT
     _SetControlSizePos(_ControlPos_._ControlPosListControl_.Item( _ControlPosFirst_ ), cF, fr-m1,fc,fw,fh)
     hK:=GetControlHandle(_ControlPos_._ControlPosListControl_.Item( _ControlPosFirst_ ),cF)
     IF ValType(hK)=="A"
       FOR m2:= 1 TO Len(hk)
            GetWindowRect(hK[m2],aRect)
            MoveWindow(hK[m1],aRect[1]-sx-formc,aRect[2]-sy-formr,aRect[3]-aRect[1],aRect[4]-aRect[2],.T.)
       NEXT
     ELSE
       MoveWindow(hK,fc-sx,fr-m1-sy,fw,fh,.T.)
     ENDIF

  CASE typ == 15  //Center HORIZONTAL on Form
     m1:=fc
     m2:=fc+fw
     FOR i:= 1 TO Len(ak)
        m1:=Min(m1,ak[i,3])
        m2:=Max(m2,ak[i,3]+ak[i,4])
     NEXT
     m2:=INT((GetProperty(cF,"WIDTH") - m2 + m1)/2)
     m1:=m1-m2
     FOR i:= 1 TO Len(ak)
        ak[i,3]:=ak[i,3]-m1
     NEXT
     _SetControlSizePos(_ControlPos_._ControlPosListControl_.Item( _ControlPosFirst_ ), cF, fr, fc-m1,fw,fh)
     hK:=GetControlHandle(_ControlPos_._ControlPosListControl_.Item( _ControlPosFirst_ ),cF)
     IF ValType(hK)=="A"
       FOR m2:= 1 TO Len(hk)
            GetWindowRect(hK[m2],aRect)
            MoveWindow(hK[m1],aRect[1]-sx-formc,aRect[2]-sy-formr,aRect[3]-aRect[1],aRect[4]-aRect[2],.T.)
       NEXT
     ELSE
       MoveWindow(hK,fc-m1-sx,fr-sy,fw,fh,.T.)
     ENDIF
END CASE

FOR i:= 1 TO Len(ak)
  _SetControlSizePos(ak[i,1], cF, ak[i,2],ak[i,3],ak[i,4],ak[i,5])
  hK:=GetControlHandle(ak[i,1],cF)
  IF ValType(hK)=="A"
    FOR m1:= 1 TO Len(hk)
         GetWindowRect(hK[m1],aRect)
         MoveWindow(hK[m1],aRect[1]-sx-formc,aRect[2]-sy-formr,aRect[3]-aRect[1],aRect[4]-aRect[2],.T.)
    NEXT
  ELSE
    MoveWindow(hK,ak[i,3]-sx,ak[i,2]-sy,ak[i,4],ak[i,5],.T.)
  ENDIF
NEXT

_ControlPos_._ControlPosCombo_.value := 1

_ControlPosListControlChange_()

RETURN NIL



*------------------------------------------------------------*
FUNCTION _ControlPosButtonSaveClick_()
*------------------------------------------------------------*
/*
LOCAL cF

cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )

IF " !SPLITED!" $ cF
  RETURN nil
ENDIF

DEFINE WINDOW _ControlPos_Save_ AT 250 , 371 WIDTH 390 HEIGHT 298 TITLE "SAVE ControlPos" MODAL NOSYSMENU

     DEFINE LABEL _ControlPos_Save_Label_1_
            ROW    3
            COL    21
            WIDTH  336
            HEIGHT 33
            VALUE "Form name"
            FONTNAME "Arial"
            FONTSIZE 20
            FONTITALIC .T.
            FONTBOLD .T.
            CENTERALIGN .T.
     END LABEL

     DEFINE RADIOGROUP _ControlPos_Save_Type_
            ROW    34
            COL    28
            WIDTH  135
            HEIGHT 50
            OPTIONS {'Save to *.POS','Modify *.FMG,*.PRG'}
            VALUE 1
     END RADIOGROUP

    DEFINE CHECKBOX _ControlPos_Save_OnlySel_
           ROW    92
           COL    48
           WIDTH  193
           HEIGHT 28
           CAPTION "Only selected controls"
           VALUE .T.
     END CHECKBOX

    DEFINE CHECKBOX _ControlPos_Save_ColWidth_
           ROW    120
           COL    48
           WIDTH  255
           HEIGHT 28
           CAPTION "Write columns width in GRID and BROWS"
           VALUE .T.
     END CHECKBOX

    DEFINE CHECKBOX _ControlPos_Save_FormPos_
           ROW    148
           COL    48
           WIDTH  193
           HEIGHT 28
           CAPTION "Form position"
           VALUE .F.
     END CHECKBOX

    DEFINE CHECKBOX _ControlPos_Save_FormSize_
           ROW    176
           COL    48
           WIDTH  193
           HEIGHT 28
           CAPTION "Form size"
           VALUE .T.
     END CHECKBOX

    DEFINE BUTTON _ControlPos_Save_BSave_
           ROW    233
           COL    64
           WIDTH  100
           HEIGHT 28
           CAPTION "Save"
           ACTION _ControlPos_Save_Action_(.T.)
     END BUTTON

    DEFINE BUTTON _ControlPos_Save_BCancel_
           ROW    233
           COL    225
           WIDTH  100
           HEIGHT 28
           CAPTION "Cancel"
           ACTION _ControlPos_Save_Action_(.F.)
     END BUTTON

     DEFINE FRAME _ControlPos_Save_Frame_1_
            ROW    52
            COL    20
            WIDTH  341
            HEIGHT 170
            CAPTION ""
     END FRAME

END WINDOW


_ControlPos_Save_._ControlPos_Save_Type_.Value      :=  Abs(_ControlPos_Save_Option_[1])
_ControlPos_Save_._ControlPos_Save_OnlySel_.Value   :=  _ControlPos_Save_Option_[2]
_ControlPos_Save_._ControlPos_Save_ColWidth_.Value  :=  _ControlPos_Save_Option_[3]
_ControlPos_Save_._ControlPos_Save_FormPos_.Value   :=  _ControlPos_Save_Option_[4]
_ControlPos_Save_._ControlPos_Save_FormSize_.Value  :=  _ControlPos_Save_Option_[5]
_ControlPos_Save_._ControlPos_Save_Label_1_.Value   := cF

CENTER WINDOW _ControlPos_Save_

ACTIVATE WINDOW _ControlPos_Save_

IF _ControlPos_Save_Option_[1] < 0
   RETURN nil
ELSEIF _ControlPos_Save_Option_[1] == 1
   _ControlPosSaveToMyFile_()
ELSE
   _ControlPos_ModFMG_()
ENDIF
*/

save_to_array()
lChanges := .t.

RETURN NIL


/*
*------------------------------------------------------------*
PROCEDURE _ControlPos_Save_Action_(lOk)
*------------------------------------------------------------*

IF lOK
  _ControlPos_Save_Option_[1] := _ControlPos_Save_._ControlPos_Save_Type_.Value
ELSE
  _ControlPos_Save_Option_[1] := - _ControlPos_Save_._ControlPos_Save_Type_.Value
ENDIF

_ControlPos_Save_Option_[2] := _ControlPos_Save_._ControlPos_Save_OnlySel_.Value
_ControlPos_Save_Option_[3] := _ControlPos_Save_._ControlPos_Save_ColWidth_.Value
_ControlPos_Save_Option_[4] := _ControlPos_Save_._ControlPos_Save_FormPos_.Value
_ControlPos_Save_Option_[5] := _ControlPos_Save_._ControlPos_Save_FormSize_.Value

RELEASE WINDOW _ControlPos_Save_
RETURN
*/


*------------------------------------------------------------*
FUNCTION _ControlPosSaveToMyFile_()
*------------------------------------------------------------*
   LOCAL i
   LOCAL j
   LOCAL ss
   LOCAL cr := Chr(13)+Chr(10)
   LOCAL crs := " ;" + cr
   LOCAL nF
   LOCAL cFile
   LOCAL cF
   LOCAL cK
   LOCAL x
   LOCAL rr
   LOCAL cc
   LOCAL ww
   LOCAL hh
   LOCAL wws
   LOCAL ct
   LOCAL p
   LOCAL aProp

   // change TYPE {internal, DEFINE }
   LOCAL At := {{"EDIT"        , "EDITBOX"      },;
                {"TEXT"        , "TEXTBOX"      },;
                {"NUMTEXT"     , "TEXTBOX"      },;
                {"MASKEDTEXT"  , "TEXTBOX"      },;
                {"CHARMASKTEXT", "TEXTBOX"      },;
                {"LIST"        , "LISTBOX"      },;
                {"MULTILIST"   , "LISTBOX"      },;
                {"COMBO"       , "COMBOBOX"     },;
                {"DATEPICK"    , "DATEPICKER"   },;
                {"RICHEDIT"    , "RICHEDITBOX"  },;
                {"MULTIGRID"   , "GRID"         },;
                {"MONTHCAL"    , "MONTHCALENDAR"},;
                {"OBUTTON"     , "BUTTONEX"     },;
                {"BTNTEXT"     , "BTNTEXTBOX"   },;
                {"BTNNUMTEXT"  , "BTNTEXTBOX"   },;
                {"TIMEPICK"    , "TIMEPICKER"   } }

   cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.Value )

   cFile := PutFile( { { "ControlPos File (*.pos)", "*.pos" } }, "Save control positon to file", GetCurrentFolder(), NIL, cF + ".pos" )

   IF Empty(cFile)
      RETURN nil
   ENDIF

   IF File(cFile)
     IF !MsgYesNo("   File exist:"+cr+cFile+cr+cr+"    Overwrite ?","File exist")
        RETURN nil
     ENDIF
   ENDIF

   aProp:=_ControlPosMemberProp_("")

   ss := "// File generated by tools CONTROLPOS   (c)AL" +cr
   ss += "// Position form controls: " + cr + cr
   ss += "// DEFINE WINDOW " + cF + " AT " + AllTrim( Str( GetProperty( cF, "ROW" ), 5, 0 ) ) + " , " + ;
                                             AllTrim( Str( GetProperty( cF, "COL" ), 5, 0 ) ) + ;
                                             " WIDTH "  + AllTrim( Str( GetProperty( cF, "WIDTH"  ), 5, 0 ) ) + ;
                                             " HEIGHT " + AllTrim( Str( GetProperty( cF, "HEIGHT" ), 5, 0 ) ) + cr + cr
   ss += "// *********   IDE syntax ************"+cr+cr
   FOR i:= 1 TO _ControlPos_._ControlPosListControl_.ItemCount
     cK := _ControlPos_._ControlPosListControl_.Item(i)
     x := GetControlIndex (cK,cF)
     rr := AllTrim(Str(GetProperty(cF,cK,"ROW"),5,0))
     cc := AllTrim(Str(GetProperty(cF,cK,"COL"),5,0))
     ww := AllTrim(Str(GetProperty(cF,cK,"WIDTH"),5,0))
     hh := AllTrim(Str(GetProperty(cF,cK,"HEIGHT"),5,0))
     ct := _HMG_aControlType[x]
     j  := AScan(at,{|aa|aa[1]==ct})    //change internal type to DEFINE type

     IF j>0                          // !!! WHY IT IS DIFFERENCE !!!
       ct := at[j,2]
     ENDIF

     IF ct == "CHECKBOX"             // !!! ALSO SAME IS IDENTICAL !!!
        IF ValType( _HMG_aControlPageMap[x] ) == "A"   //mayby it's correct ?
           ct := "CHECKBUTTON"
        ENDIF
     ENDIF

     IF ct == "COMBOBOX"
         IF _HMG_aControlMiscDatA1[x,1]==1
            ct := "COMBOBOXEX"
         ENDIF
     ENDIF

     IF "@" + ct + "@" $ "@TAB@TREE@"
        ss += "   DEFINE " + ct + " " + cK //+ crs
        ss += " AT " + rr + ", " + cc //+ crs
        ss += " WIDTH " + ww //+ crs
        ss += " HEIGHT " + hh + cr
     ELSE
        ss += "   DEFINE "    + ct + " " + cK + cr
        ss += "      ROW "    + rr + cr
        ss += "      COL "    + cc + cr
        ss += "      WIDTH "  + ww + cr
        ss += "      HEIGHT " + hh + cr

        IF "@"+ct+"@" $ "@BROWSE@GRID@"
           wws := "{"
           FOR j:= 1 TO   Len(_HMG_aControlPageMap[x])
               wws += AllTrim(Str(ListView_GetColumnWidth ( _HMG_aControlHandles[ x ] , j-1 ),5,0))
               IF j < Len(_HMG_aControlPageMap[ x ] )
                  wws += ","
               ENDIF
           NEXT
           wws += "}"
           ss += "      WIDTHS "+ wws +cr
        ENDIF

        p := 1
        DO WHILE ( p := AScan( aProp, { | aa | aa[ 1 ] == Upper( cF ) .AND. aa[ 2 ] == Upper( cK ) }, p ) ) > 0
           // MsgBox(Str(p))
           ss += _ControlPosWriteProp_( aProp[ p, 3 ], aProp[ p, 4 ], ct ) + cr
           p++
        ENDDO
     ENDIF
     ss += cr
   NEXT

   ss += cr + "//  *****   MGIDE syntax  **********" + cr + cr

   FOR i:= 1 TO _ControlPos_._ControlPosListControl_.ItemCount
     cK := _ControlPos_._ControlPosListControl_.Item(i)
     x  := GetControlIndex( cK, cF )
     rr := AllTrim( Str(GetProperty( cF, cK, "ROW"    ), 5, 0 ) )
     cc := AllTrim( Str(GetProperty( cF, cK, "COL"    ), 5, 0 ) )
     ww := AllTrim( Str(GetProperty( cF, cK, "WIDTH"  ), 5, 0 ) )
     hh := AllTrim( Str(GetProperty( cF, cK, "HEIGHT" ), 5, 0 ) )
     ct := _HMG_aControlType[ x ]
     j  := AScan( at,{ | aa | aa[ 1 ] == ct } )    //change internal type to DEFINE type

     IF j > 0
       ct := At[ j, 2 ]
     ENDIF

     IF ct == "CHECKBOX"
        IF ValType( _HMG_aControlPageMap[x] ) == "A"   //mayby it's correct ?
           ct := "CHECKBUTTON"
        ENDIF
     ENDIF

     IF ct == "COMBOBOX"
         IF _HMG_aControlMiscData1[ x, 1 ] == 1
            ct := "COMBOBOXEX"
         ENDIF
     ENDIF

     ss += "   @ " + rr + ", " + cc + " " + ct + " " + cK + crs
     ss += "      WIDTH " + ww + crs
     ss += "      HEIGHT " + hh

     IF "@"+ct+"@" $ "@BROWSE@GRID@"
           wws := "{"
           FOR j:= 1 TO   Len(_HMG_aControlPageMap[ x ] )
               wws += AllTrim( Str( ListView_GetColumnWidth( _HMG_aControlHandles[ x ], j-1 ), 5, 0 ) )
               IF j < Len(_HMG_aControlPageMap[ x ] )
                  wws += ","
               ENDIF
           NEXT
           wws += "}"
           ss  += crs + "      WIDTHS " + wws
     ENDIF
     DO WHILE ( p := AScan( aProp, { | aa | aa[ 1 ] == Upper( cF ) .AND. aa[ 2 ] == Upper( cK ) }, p ) ) > 0
        ss += crs + _ControlPosWriteProp_( aProp[ p, 3 ], aProp[ p, 4 ], ct, .T. )
        p++
     ENDDO
     ss += cr + cr
   NEXT

   ss += "//end file" + cr

   nF := FCreate( cFile, 0 )

   IF nF == -1
      MsgStop("Can't create file"+cr+cFile,"Error")
      RETURN nil
   ENDIF

   FWrite( nF, ss )
   FClose( nf )

RETURN NIL


*------------------------------------------------------------*
FUNCTION _ControlPosWriteProp_(cProp,xVal,cTyp,lMGIDE)
*------------------------------------------------------------*
   LOCAL i
   LOCAL ret

   IF lMGIDE==NIL
      lMGIDE := .F.
   ENDIF

   IF cProp=="ALIGN"
     IF xVal=="L" .AND. "@"+cTyp+"@" $ "@CHECKBOX@RADIOGROUP@"
        RETURN "      LEFTJUSTIFY" +IIF(!lMGIDE," .T.","")
     ELSEIF xVal=="R"
        RETURN "      RIGHTALIGN"  +IIF(!lMGIDE," .T.","")
     ELSEIF xVal=="C"
        RETURN "      CENTERALIGN" +IIF(!lMGIDE," .T.","")
     ELSE
        RETURN ""
     ENDIF
   ENDIF
   IF lMGIDE .AND. "FONT"$cProp
     IF cProp=="FONTNAME"
        cProp:="FONT"
     ELSEIF !(cProp=="FONTCOLOR")
        cProp:=SubStr(cProp,5)
     ENDIF
   ENDIF

   IF ValType(xVal)=="N"
      ret:=AllTrim(Str(xVal))
      DO WHILE "."$ret .AND. Right(ret,1)$"0."
          ret :=Left(ret,Len(ret)-1)
      ENDDO
   ELSEIF ValType(xVal)=="A"
      ret:= "{ "
      FOR i:= 1 TO LEN (xVal)
         ret += AllTrim(Str(xVal[i]))
         IF i < Len(xVal)
            ret += " , "
         ENDIF
      NEXT
      ret += " }"
   ELSEIF ValType(xVal)=="L"
      ret := IIF(lMGIDE,"",IIF(xVal,".T.",".F."))
   ELSE
      IF '"'$xVal
         ret := "'" + xVal + "'"
      ELSE
         ret := '"' + xVal + '"'
      ENDIF
   ENDIF

RETURN "      " + cProp + " " + ret


*------------------------------------------------------------*
FUNCTION _ControlPos_ModFMG_()
*------------------------------------------------------------*
   LOCAL nF
   LOCAL cFile
   LOCAL cFile2
   LOCAL nF2
   LOCAL buff     := Space(128)
   LOCAL l
   LOCAL ss       := ""
   LOCAL reg
   LOCAL aMatch
   LOCAL cF
   LOCAL cK
   LOCAL x
   LOCAL i
   LOCAL j
   LOCAL rr
   LOCAL cc
   LOCAL ww
   LOCAL hh
   LOCAL ct
   LOCAL cr       := Chr(13)+Chr(10)
   LOCAL as
   LOCAL lCR      := .T.
   LOCAL s1
   LOCAL s2
   LOCAL sF1
   LOCAL sK
   LOCAL sF2
   LOCAL DefType

   // change TYPE {internal, DEFINE}
   LOCAL at := {{"EDIT","EDITBOX"},;
                {"TEXT","TEXTBOX"},;
                {"NUMTEXT","TEXTBOX"},;
                {"MASKEDTEXT","TEXTBOX"},;
                {"CHARMASKTEXT","TEXTBOX"},;
                {"LIST","LISTBOX"},;
                {"MULTILIST","LISTBOX"},;
                {"COMBO","COMBOBOX"},;
                {"DATEPICK","DATEPICKER"},;
                {"RICHEDIT","RICHEDITBOX"},;
                {"MULTIGRID","GRID"},;
                {"MONTHCAL","MONTHCALENDAR"},;
                {"OBUTTON","BUTTONEX"},;
                {"BTNTEXT","BTNTEXTBOX"},;
                {"TIMEPICK","TIMEPICKER"}}

   cFile := GetFile({{"IDE FORM definition (*.fmg)","*.fmg"},{"Program source files (*.prg)","*.prg"}},"Open FORM definition for template",GetCurrentFolder())
   IF Empty(cFile)
     RETURN nil
   ENDIF
   // MsgBox( cFileNoExt( cFile ) + iif( Upper( Right( cFile, 3 ) ) == "PRG", ".prm", ".fmm" ) )
   cFile2 := PUTFILE({{"Modified source file (*.??m)","*.??m"}},"Save modified FORM to file",GetCurrentFolder(),nil,cFileNoExt(cFile)+IIf(Upper(Right(cFile,3))=="PRG",".prm",".fmm") )
   IF Empty(cFile2)
      RETURN nil
   ENDIF

   IF File(cFile2)
     IF !MsgYesNo("   File exist: "+cFile2+cr+"    Overwrite ?","File exist")
        RETURN nil
     ENDIF
   ENDIF

   IF (nF := FOpen(cFile)) == -1
     RETURN nil
   ENDIF

   DO WHILE (l:=FRead(nF,@buff,128)) > 0
     ss += Left(buff,l)
   ENDDO
   FClose(nF)


   // Change CR+LF -> LF
   IF At(cr,ss) > 0
     lCR:=.T.                    //member to back LF -> CR+LF
     ss:=StrTran(ss,cr,Chr(10))
   ENDIF
   // add LF before and after for easy search
   ss:=Chr(10)+ss+Chr(10)


   cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
   cK := _ControlPos_._ControlPosListControl_.Item(1)  //one of control

   // Get only DEFINE WINDOW Name|TEMPLATE ... OneOfControl ... END WINDOW
   reg := hb_regexComp("(?si)(.*[ \t\n])(DEFINE[ \t]+WINDOW[ \t]+)("+cF+"|TEMPLATE)([ ;\t]+.+?"+cK+".+?\n[ \t\]*END[ \t]+WINDOW)([ \t\n].*)")
   aMatch := hb_regex(reg,ss)

   IF ValType(aMatch) == "A"
      s1 := aMatch[2]                       //before
      ss := aMatch[3]+aMatch[4]+aMatch[5]   // only definition of window
      s2 := aMatch[6]                       //after
   ELSE
      IF !MsgYesNo("Can't find '... DEFINE WINDOW "+cF+ "/TEMPLATE ..."+cr+"Continue?")
   //   IF Alert("Can't find '... DEFINE WINDOW "+cF+ "/TEMPLATE ...;Continue?",{"YES","No"})!=1
         RETURN nil
      ENDIF
   ENDIF


   //modify form
   rr := AllTrim(Str(GetProperty(cF,"ROW"),5,0))
   cc := AllTrim(Str(GetProperty(cF,"COL"),5,0))
   ww := AllTrim(Str(GetProperty(cF,"WIDTH"),5,0))
   hh := AllTrim(Str(GetProperty(cF,"HEIGHT"),5,0))

   IF _ControlPos_Save_Option_[4]      //save Form position    ROW and COL
     reg := hb_regexComp("(?si)(.*?[ \t\n]AT[ \t]+)(\d[\d.+\-*/()]*)([ \t]*,[ \t]*)(\d[\d.+\-*/()]*)([ \t\n;].*)")
     aMatch := hb_regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+rr+aMatch[4]+cc+aMatch[6]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE WINDOW "+cF+"/TEMPLATE ...  AT ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
   ENDIF

   IF _ControlPos_Save_Option_[5]      //save Form size
      // WIDTH                   2                      3         4
      reg := hb_regexComp("(?si)(.*?[ \t\n]WIDTH[ \t]+)(\d[\d.+\-*/()]*)([ \t\n;].*)")
      aMatch := hb_regex(reg,ss)
      IF ValType(aMatch) == "A"
         ss := aMatch[2]+ww+aMatch[4]
      ELSE
         IF !MsgYesNo("Can't find '... DEFINE WINDOW "+cF+ "/TEMPLATE ... WIDTH ...'"+cr+"Continue ?")
            RETURN nil
         ENDIF
      ENDIF
      // HEIGHT
      reg := hb_regexComp("(?si)(.*?[ \t\n]HEIGHT[ \t]+)(\d[\d.+\-*/()]*)([ \t\n;].*)")
      aMatch := hb_regex(reg,ss)
      IF ValType(aMatch) == "A"
         ss := aMatch[2]+hh+aMatch[4]
      ELSE
         IF !MsgYesNo("Can't find '... DEFINE WINDOW "+cF+ "/TEMPLATE ... HEIGHT ...'"+cr+"Continue ?")
            RETURN nil
         ENDIF
      ENDIF
   ENDIF

   as := _ControlPos_._ControlPosListControl_.Value
   FOR i:= 1 TO _ControlPos_._ControlPosListControl_.ItemCount
     IF _ControlPos_Save_Option_[2]      //save only selected controls
       IF AScan(as,i) == 0      //not selected
          LOOP              //next
       ENDIF
     ENDIF
     cK := _ControlPos_._ControlPosListControl_.Item(i)
     x := GetControlIndex (cK,cF)
     cT := _HMG_aControlType[x]
     j:=AScan(at,{|aa|aa[1]==cT})    //change internal type to DEFINE type
     IF j>0
       cT := at[j,2]
     ENDIF
     IF cT == "CHECKBOX"    //CHECKBOX and CHECKBUTTON internal is CHECKBOX
        IF ValType( _HMG_aControlPageMap[x] ) == "A"   //mayby it's correct ?
           cT := "CHECKBUTTON"
        ENDIF
     ENDIF
     IF cT == "COMBOBOX"
         IF _HMG_aControlMiscDatA1[x,1]==1
            cT := "COMBOBOXEX"
         ENDIF
     ENDIF

     IF "@"+cT+"@" $ "@TAB@TREE@"
       //find control definition
       reg := hb_regexComp("(?si)(.*)(DEFINE[ \t]+"+cT+"[ \t]+"+cK+"[ \t;].*?[^;])([ \t]*\n.*)")
       aMatch := hb_regex(reg,ss)

       IF ValType(aMatch) == "A"
          sF1 := aMatch[2]
          sK := aMatch[3]
          sF2 := aMatch[4]
       ELSE
          IF !MsgYesNo("Can't find 'DEFINE "+cT+" "+cK+" ... AT ..."+cr+"Continue ?")
             RETURN nil
          ENDIF
          LOOP
       ENDIF
       sK :=_ControlPos_ModFMGCon_(cF,cK,cT,sK,3)
       ss := sF1 + sk + sF2

     ELSE  // not TAB or TREE
       //find control definition
       // first as syntaxt:  @ row,col TYPE NAME ... [;LF] ...
       reg := hb_regexComp("(?si)(.*)(@.+?,.+?[ \t]+"+cT+"[ \t]+"+cK+")([ \t]*\n|[ \t;].*?[^;])([ \t]*\n.*)")
       aMatch := hb_regex(reg,ss)

       IF ValType(aMatch) == "A"
          sF1 := aMatch[2]
          sK := aMatch[3]+aMatch[4]
          sF2 := aMatch[5]
          DefType:=2
       ELSE  //try find as syntaxt: DEFINE TYPE NAME {LF} ...{LF} ... END TYPE
          reg := hb_regexComp("(?si)(.*)(DEFINE[ \t]+"+cT+"[ \t]+"+cK+"\s.*?)(\n[ \t]*END[ \t]"+cT+".*)")
          aMatch := hb_regex(reg,ss)

          IF ValType(aMatch) == "A"
             sF1 := aMatch[2]
             sK := aMatch[3]
             sF2 := aMatch[4]
             DefType:=1
          ELSE
             IF !MsgYesNo( "Can't find '...@ | DEFINE " + cT + " " + cK + " ... " + CRLF + "Continue ?" )
            // IF Alert("Can't find '... @ | DEFINE "+cT+" "+cK+" ... ;Continue ?",{"YES","No"})!=1
                RETURN nil
             ENDIF
             LOOP
          ENDIF
       ENDIF
       sK :=_ControlPos_ModFMGCon_(cF,cK,cT,sK,DefType)  //modify control

       ss := sF1 + sk + sF2
     ENDIF   //ct == "TAB"
   NEXT

   ss := s1 + ss + s2            //join
   ss := SubStr(ss,2,Len(ss)-2)  //delete added Chr(10)
   IF lCR
     ss := StrTran( ss, Chr(10), cr )     //back LF -> CR+LF
   ENDIF

   nF2 := FCreate(cFile2,0)
   IF nF2 == -1
      MsgStop("Can't create file "+cFile2,"Error")
      RETURN nil
   ENDIF

   FWrite(nF2,ss)
   FClose(nF2)

RETURN nil


*------------------------------------------------------------*
// modify control
FUNCTION _ControlPos_ModFMGCon_( cF, cK, cT, sK, type )
*------------------------------------------------------------*
   LOCAL indent    AS STRING
   LOCAL reg       AS USUAL  //? VarType
   LOCAL aM        AS USUAL
   LOCAL i         AS NUMERIC
   LOCAL cP        AS ARRAY
   LOCAL aSize     AS ARRAY   := Array( 4 )
   LOCAL x         AS NUMERIC
   LOCAL wws       AS STRING
   LOCAL aProp     AS ARRAY   := _ControlPosMemberProp_( "" )
   LOCAL lAutoSize AS LOGICAL := .F.

   aSize[ 1 ] := AllTrim( Str( GetProperty( cF, cK, "ROW"   ), 5, 0 ) )
   aSize[ 2 ] := AllTrim( Str( GetProperty( cF, cK, "COL"   ), 5, 0 ) )
   aSize[ 3 ] := AllTrim( Str( GetProperty( cF, cK, "WIDTH" ), 5, 0 ) )
   aSize[ 4 ] := AllTrim( Str( GetProperty( cF, cK, "HEIGHT"), 5, 0 ) )
   x          := GetControlIndex( cK, cF )

   //get indent
   IF type == 1
      reg := hb_regexComp("(?si)(.+?\n)([ \t]*)(.*)")
      aM  := hb_regex( reg, sK )

      IF ValType( aM ) == "A"
        indent := Chr( 10 ) + aM[ 3 ]
      ELSE
        indent := Chr( 10 )
      ENDIF
   ELSE
      reg := hb_regexComp( "(?si)(.+?;[ \t]*)(\n[ \t]*)(.*)" )
      aM  := hb_regex( reg, sK )

      IF ValType(aM) == "A"
         indent := ";" + aM[3]
      ELSE
         indent := " "
      ENDIF
   ENDIF

   // Check for AUTOSIZE in LABEL or HYPERLINK
   IF "@" + cT + "@" $ "@LABEL@HYPERLINK@"
     IF Type == 1
        reg := hb_regexComp("(?si)(.+[ \t\n]AUTOSIZE[ \t]+)(\.T\.)(.*)")
     ELSE
        reg := hb_regexComp("(?si)(.+[ \t\n]AUTOSIZE[ \t;]+)(.*)")
     ENDIF
     aM := hb_regex( reg, sK )
     IF ValType( aM ) == "A"
        lAutosize := .T.
     ENDIF
   ENDIF

   // ROW, COL
   IF Type == 1
      FOR i := 1 TO 2

          cP  := { "ROW", "COL", "WIDTH", "HEIGHT" }[ i ]
          reg := hb_regexComp( "(?si)(.+[ \t\n]" + cP + "[ \t]+)(\d[\d.+\-*/()]*)(.*)" )
          aM  := hb_regex( reg, sK )

          IF ValType( aM ) == "A"
             sK := aM[ 2 ] + aSize[ i ] + aM[ 4 ]
          ELSE
             sK := sK + indent + cP + " " + aSize[ i ]
          ENDIF
      NEXT

   ELSEIF Type == 2
      reg := hb_regexComp( "(?si)(@[ \t]*)(\d[\d.+\-*/()]*)([ \t]*,[ \t]*)(\d[\d.+\-*/()]*)(.*)" ) //aa
      aM  := hb_regex( reg, sK )
      IF ValType( aM ) == "A"
         sK := aM[ 2 ] + aSize[ 1 ] + aM[ 4 ] + aSize[ 2 ] + aM[ 6 ]
      ELSE
         IF ! MsgYesNo( "Can't find '... @ ROW , COL " + ct + " " + ck + " ...'" + CRLF + "Continue ?" )
            RETURN sK
         ENDIF
      ENDIF
   ELSE  //type == 3
      reg := hb_regexComp( "(?si)(.*?[ \t\n]AT[ \t]+)(\d[\d.+\-*/()]*)([ \t]*,[ \t]*)(\d[\d.+\-*/()]*)(.*)" )
      aM  := hb_regex( reg, sK )
      IF ValType(aM) == "A"
         sK := aM[ 2 ] + aSize[ 1 ] + aM[ 4 ] + aSize[ 2 ] + aM[ 6 ]
      ELSE
         IF ! MsgYesNo( "Can't find  'DEFINE " + ct + " " + ck + " AT row,col ...'" + CRLF + "Continue ?" )
            RETURN sK
         ENDIF
      ENDIF
   ENDIF

   // WIDTH, HEIGHT
   IF ! lAutoSize
      FOR i := 3 TO 4

          cP  := { "ROW", "COL", "WIDTH", "HEIGHT" }[ i ]
          reg := hb_regexComp( "(?si)(.+[ \t\n]" + cP + "[ \t]+)(\d[\d.+\-*/()]*)(.*)" )
          aM  := hb_regex( reg, sK )

          IF ValType( aM ) == "A"
             sK := aM[ 2 ] + aSize[ i ] + aM[ 4 ]
          ELSE
             sK := sK + indent + cP + " " + aSize[ i ]
          ENDIF

      NEXT
   ENDIF

   //WIDTHS   for BROWSE or GRID
   IF "@" + cT + "@" $ "@BROWSE@@GRID@" .AND. _ControlPos_Save_Option_[ 3 ]
      wws := "{"
      FOR i := 1 TO Len(_HMG_aControlPageMap[ x ] )
          wws += AllTrim( Str( ListView_GetColumnWidth( _HMG_aControlHandles[ x ] , i-1 ), 5, 0 ) )
          IF i < Len( _HMG_aControlPageMap[ x ] )
             wws += ","
          ENDIF
      NEXT

      wws += "}"
      reg := hb_regexComp( "(?si)(.+[ \t\n]WIDTHS[ \t]+?)(\{.+?\})(.*)" )
      aM  := hb_regex( reg, sK )

      IF ValType( aM ) == "A"
         sK := aM[2] + wws + aM[ 4 ]
      ELSE
         sK := sK + indent + "WIDTHS " + wws
      ENDIF

   ENDIF

   // another modifed PROPERTIES
   i := 1
   DO WHILE ( i := AScan( aProp,{ |aa| aa[ 1 ] == Upper( cF ) .AND. aa[ 2 ] == Upper( cK ) }, i ) ) > 0
      sK := _ControlPos_ModFMGProp_( aProp[i,3], aProp[ i, 4 ], cT, sK, Type, indent )
      i++
   ENDDO

RETURN sK


*------------------------------------------------------------*
FUNCTION _ControlPos_ModFMGProp_( cProp, xVal, cTyp, sK, type, indent )
*------------------------------------------------------------*
   LOCAL i
   LOCAL cP,cV,cS
   LOCAL reg, aM

   // MsgBox( "@" + cProp + "@" + sK )
   cP:=cProp
   IF type!=1 .AND. "FONT"$cProp .AND.!(cProp=="FONTCOLOR")
     IF cProp=="FONTNAME"
        cP:="FONT"
     ELSE
        cP:=SubStr(cProp,5)
     ENDIF
   ENDIF

   IF type==1 .OR. !(cProp=="ALIGN")
      IF ValType(xVal)=="N"
         cV:=AllTrim(Str(xVal))
         DO WHILE "."$cV .AND. Right(cV,1)$"0."
             cV :=Left(cV,Len(cV)-1)
         ENDDO
         cS := "[+-]?\d[\d.]*"
      ELSEIF ValType(xVal)=="A"
         cV:= "{ "
         FOR i:= 1 TO LEN (xVal)
            cV += AllTrim(Str(xVal[i]))
            IF i < Len(xVal)
               cV += " , "
            ENDIF
         NEXT
         cV += " }"
         cS := "\{.+?\}"
      ELSEIF ValType(xVal)=="L"
         cV := IIF(type==1,IIF(xVal,".T.",".F."),"")
         cS := "\.[TF]\."
      ELSE
         IF '"'$xVal
            cV := "'" + xVal + "'"
         ELSE
            cV := '"' + xVal + '"'
         ENDIF
         cS := '"[^"]*"|'+"'[^']*'"
      ENDIF
   ENDIF

   IF type==1
      IF cProp=="ALIGN"
         IF "@"+cTyp+"@" $ "@CHECKBOX@RADIOGROUP@"
            IF xVal=="L"
               cP := "LEFTJUSTIFY"
               cS := "\.[TF]\."
               reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+"[ \t]+)(nil|"+cS+")(.*)")
               aM := hb_regex(reg,sK)
               IF ValType(aM) == "A"
                  sK := aM[2]+".T."+aM[4]
               ELSE
                  sK := sK + indent + cP +" .T."
               ENDIF
            ELSE  // "R"
               reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+"[ \t]+)(nil|"+cS+")(.*)")
               aM := hb_regex(reg,sK)
               IF ValType(aM) == "A"
                  sK := aM[2]+".F."+aM[4]
   //            ELSE
   //               sK := sK + Chr(10) + indent + cP +" .F."
               ENDIF
            ENDIF
         ELSE   // LABEL
            cP := "RIGHTALIGN"
            cS := "\.[TF]\."
            reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+"[ \t]+)(nil|"+cS+")(.*)")
            aM := hb_regex(reg,sK)
            IF ValType(aM) == "A"
               sK := aM[2]+IIF(xVal=="R",".T.",".F.")+aM[4]
            ELSE
               IF xVal=="R"
                  sK := sK + indent + cP +" .T."
               ENDIF
            ENDIF
            cP := "CENTERALIGN"
            cS := "\.[TF]\."
            reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+"[ \t]+)(nil|"+cS+")(.*)")
            aM := hb_regex(reg,sK)
            IF ValType(aM) == "A"
               sK := aM[2]+IIF(xVal=="C",".T.",".F.")+aM[4]
            ELSE
               IF xVal=="C"
                  sK := sK + indent + cP +" .T."
               ENDIF
            ENDIF
         ENDIF
      ELSE  // not ALIGN
        reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+"[ \t]+)(nil|"+cS+")(.*)")
        aM := hb_regex(reg,sK)
        IF ValType(aM) == "A"
           sK := aM[2]+cV+aM[4]
        ELSE
           sK := sK + indent + cP +" "+ cV
        ENDIF
      ENDIF
   ELSE // type 2 or 3
      IF cProp=="ALIGN"
         IF "@"+cTyp+"@" $ "@CHECKBOX@RADIOGROUP@"
            IF xVal=="L"
               cP := "LEFTJUSTIFY"
               reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF !(ValType(aM) == "A")
                  sK := sK + indent + cP
               ENDIF
            ELSE  // "R"                  2   3                       4       5        6
               reg := hb_regexComp("(?si)(.*)([ \t]+|;[ \t]*\n[ \t]*)("+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF ValType(aM) == "A"     //delete property
                  sK := aM[2]+aM[5]+aM[6]
               ENDIF
            ENDIF
         ELSE   // LABEL
            IF xVal=="L"
               cP := "RIGHTALIGN"        //to delete
               reg := hb_regexComp("(?si)(.*)([ \t]+|;[ \t]*\n[ \t]*)("+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF ValType(aM) == "A"
                  sK := aM[2]+aM[5]+aM[6]
               ENDIF
               cP := "CENTERALIGN"       //to delete
               reg := hb_regexComp("(?si)(.*)([ \t]+|;[ \t]*\n[ \t]*)("+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF ValType(aM) == "A"
                  sK := aM[2]+aM[5]+aM[6]
               ENDIF
            ELSEIF xVal == "R"
               cP := "RIGHTALIGN"        //to insert
               reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF !(ValType(aM) == "A")
                  sK := sK + indent + cP
               ENDIF
               cP := "CENTERALIGN"       //to delete
               reg := hb_regexComp("(?si)(.*)([ \t]+|;[ \t]*\n[ \t]*)("+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF ValType(aM) == "A"
                  sK := aM[2]+aM[5]+aM[6]
               ENDIF
            ELSE    // "C"
               cP := "RIGHTALIGN"        //to delete
               reg := hb_regexComp("(?si)(.*)([ \t]+|;[ \t]*\n[ \t]*)("+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF ValType(aM) == "A"
                  sK := aM[2]+aM[5]+aM[6]
               ENDIF
               cP := "CENTERALIGN"       //to insert
               reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+")([ \t;]|$)(.*)")
               aM := hb_regex(reg,sK)
               IF !(ValType(aM) == "A")
                  sK := sK + indent + cP
               ENDIF
            ENDIF
         ENDIF
      ELSEIF "FONT"$cProp .AND. !(cProp=="FONTNAME") .AND. !(cProp=="FONTCOLOR")
         // bold,italic,undeline,strikeout
         IF xVal   //insert property
            reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+")([ \t;]|$)(.*)")
            aM := hb_regex(reg,sK)
            IF !(ValType(aM) == "A")
               sK := sK + indent + cP
            ENDIF
         ELSE      //delete property
            reg := hb_regexComp("(?si)(.*)([ \t]+|;[ \t]*\n[ \t]*)("+cP+")([ \t;]|$)(.*)")
            aM := hb_regex(reg,sK)
            IF ValType(aM) == "A"
               sK := aM[2]+aM[5]+aM[6]
            ENDIF
         ENDIF
      ELSE  // property with value
        reg := hb_regexComp("(?si)(.+[ \t\n]"+cP+"[ \t]+)(nil|"+cS+")(.*)")
        aM := hb_regex(reg,sK)
        IF ValType(aM) == "A"
           sK := aM[2]+cV+aM[4]
        ELSE
           sK := sK + indent + cP +" "+ cV
        ENDIF
      ENDIF
   ENDIF

RETURN sK


*------------------------------------------------------------*
// Member my graph and delete only this
FUNCTION _ControlPosAddDelGraph_(window,cAction)
*------------------------------------------------------------*
  Local w := GetFormIndex ( window )
  Local nLast := Len( _HMG_aFormGraphTasks[w] )
  LOCAL i

  STATIC myGraph := {}

  IF cAction == NIL
     cAction := "A"
  ELSE
    cAction := Upper(Left(cAction,1))
  ENDIF


IF _HMG_aFormDeleted[w] == .F.

  IF cAction == "A"  //add position and identy my graph
    AAdd(myGraph ,{ nLast ,_ControlPos_C_GetBlockID_(_HMG_aFormGraphTasks[w,nLast]) })
    RETURN .T.
  ENDIF

  IF cAction == "R"  //redraw all graph
    FOR i := 1 TO Len(_HMG_aFormGraphTasks[w])
      Eval(_HMG_aFormGraphTasks[w , i] )
    NEXT
    RETURN .T.
  ENDIF

  IF cAction == "D"  //delete my graph from MiniGUI list
    ASort( myGraph,,,{|x,y| (x[1] > y[1]) })
    FOR i := 1 TO Len(myGraph)
     // user program may delete graph  ( ERASE WINDOW window )
     IF myGraph[i,1] <= Len(_HMG_aFormGraphTasks[w])
       // and draw new , so I test it is my graph
       IF _ControlPos_C_GetBlockID_(_HMG_aFormGraphTasks[w,myGraph[i,1]]) == myGraph[i,2]
          ADel(_HMG_aFormGraphTasks[ w ], myGraph[ i, 1 ] )
          nLast--
          ASize( _HMG_aFormGraphTasks[ w ], nLast )
       ENDIF
     ENDIF
    NEXT
    ASize( myGraph, 0 )
  ENDIF
  RETURN .T.
ENDIF

RETURN .F.


*------------------------------------------------------------*
FUNCTION _ControlPosDrawBox_( window, x, y, w, h , color)
*------------------------------------------------------------*
  LOCAL i := GetFormIndex ( Window )
  LOCAL FormHandle := _HMG_aFormHandles [i]
  LOCAL clr := color[1]+color[2]*256+color[3]*65536

  _ControlPos_C_WndBox_( FormHandle, x, y, x+w, y+h , clr)
   AAdd( _HMG_aFormGraphTasks [i] , { || _ControlPos_C_WndBox_( FormHandle, x, y, x+w, y+h , clr) } )

RETURN nil


*------------------------------------------------------------*
FUNCTION _ControlPos_SetStyle_(cF,cK,styl,lSet)
*------------------------------------------------------------*
   LOCAL h :=GetControlHandle(ck,cF)
   LOCAL i
   LOCAL as:={ {"ES_LEFT"         , 0x0000},;
               {"ES_CENTER"       , 0x0001},;
               {"ES_RIGHT"        , 0x0002},;
               {"ES_MULTILINE"    , 0x0004},;
               {"ES_UPPERCASE"    , 0x0008},;
               {"ES_LOWERCASE"    , 0x0010},;
               {"ES_PASSWORD"     , 0x0020},;
               {"ES_AUTOVSCROLL"  , 0x0040},;
               {"ES_AUTOHSCROLL"  , 0x0080},;
               {"ES_NOHIDESEL"    , 0x0100},;
               {"ES_OEMCONVERT"   , 0x0400},;
               {"ES_READONLY"     , 0x0800},;
               {"ES_WANTRETURN"   , 0x1000},;
               {"ES_NUMBER"       , 0x2000} ;
             }

   IF ValType( h ) == "N"
      IF h == 0
         RETURN nil
      ENDIF
   ENDIF

   IF styl==nil
      RETURN nil
   ENDIF

   IF lSet==Nil .OR. ValType(lSet)!="L"
      lSet := .T.
   ENDIF

   IF ValType(styl)=="C"
      styl:=Upper(AllTrim(styl))
      IF ( i := AScan( as, { | aa | aa[1] == styl } ) ) > 0
        styl := as[ i, 2 ]
      ELSE
        RETURN nil
      ENDIF

   ELSEIF ValType( styl ) != "N"
      RETURN nil
   ENDIF

   IF ValType(h)=="A"
      FOR i := 1 TO Len( h )
        _ControlPos_C_SetStyle_( h[i], styl, lSet )
      NEXT
   ELSE
     _ControlPos_C_SetStyle_(h,styl,lSet)
  ENDIF

RETURN nil


*------------------------------------------------------------*
PROCEDURE _ControlPos_SetFormProc_( lSet, lReDraw )
*------------------------------------------------------------*
   LOCAL  h

   STATIC cF := ""

   IF lSet == Nil
      lSet := .T.
   ENDIF

   IF lRedraw == Nil
     lReDraw := .T.
   ENDIF

   IF lSet
      //cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
      cF := "Form_1"
      /*
      IF " !SPLITED!" $ cF
        _ControlPos_._ControlPosUseMouseButton_.Value:=.F.
        cF:=""
        RETURN
      ENDIF
      */
   ENDIF

   IF !lSet .AND. cF==""
       RETURN
   ENDIF

   h:=GetFormHandle(cF)

   _ControlPos_C_SetFormProc_(h,lSet)
   IF lSet
     SetCapture(h)
   ELSE
     ReleaseCapture()
     cF:=""
   ENDIF

   IF lReDraw
     _ControlPosListControlChange_()
   ENDIF

RETURN


*------------------------------------------------------------*
FUNCTION _ControlPos_FormProc_( hWnd, nMsg, wParam, x, y )
*------------------------------------------------------------*
   #define WM_MOUSEMOVE                    0x0200
   #define WM_LBUTTONDOWN                  0x0201
   #define WM_LBUTTONUP                    0x0202
   //#define WM_LBUTTONDBLCLK                0x0203
   #define WM_RBUTTONDOWN                  0x0204
   #define WM_RBUTTONUP                    0x0205
   //#define WM_RBUTTONDBLCLK                0x0206
   //#define WM_CAPTURECHANGED               0x0215
   #define WM_NCMOUSEMOVE                  0x00A0
   #define MK_SHIFT                        0x0004
   #define MK_CONTROL                      0x0008

   //LOCAL cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
   LOCAL cF := "Form_1"
   LOCAL hSel:=0,i,pk,k:="",aSel
   LOCAL aRect:={0,0,0,0}

   STATIC lDown   :=.F.  // Left button down
   STATIC nAction := 0   // 0-move, 1-resize, 2-resize high, 3-resize width, 4-move only HORIZONTAL, 5-move only VERTICAL
   STATIC sX0     := 0   // x after left mouse down
   STATIC sY0     := 0   // y after left mouse down
   STATIC sX      := 0   // previous x WM_MOUSEMOVE
   STATIC sY      := 0   // previous y WM_MOUSEMOVE
   STATIC lRDown  := .F. //right button down

   IF nMsg == WM_NCMOUSEMOVE
      SetProperty( cF, "Title", " NC " + Str( x ) + Str( y ) )
      SetCapture( hWnd )
      RETURN 0
   ENDIF

   // check for releasecapture
   GetClientRect( GetFormHandle( cF ), aRect )

   i  := GetBorderWidth()
   pk := GetBorderHeight() + GetTitleHeight()

   IF GetMenu(GetFormHandle(cF)) != 0
     pk := pk + GetMenuBarHeight()
   ENDIF

   IF (x < - i) .OR. (y < - pk  ).OR. (x > aRect[3] + i) .OR. (y > aRect[4] + GetBorderHeight() ) //out of form
      SetProperty( cF, "Title", " OUT OF FORM" )
      ReleaseCapture()
      RETURN 0
   ENDIF

   aRect[1] := GetProperty("_ControlPos_","COL") - GetProperty(cF,"COL") - i
   aRect[2] := GetProperty("_ControlPos_","ROW") - GetProperty(cF,"ROW") - pk
   aRect[3] := aRect[1] + GetProperty("_ControlPos_","WIDTH")
   aRect[4] := aRect[2] + GetProperty("_ControlPos_","HEIGHT")

   IF (x >= aRect[1]) .AND. x <= aRect[3] .AND. y >= aRect[2] .AND. y <= aRect[4]  // Over ControlPos
      SetProperty( cF, "Title", " OVER ControlPos" )
      ReleaseCapture()
      RETURN 0
   ENDIF

   // Find control under mouse
   hSel := _ControlPos_C_ChildWindowFromPoint_( GetFormHandle( cF ), x, y )
   IF hSel > 0
      pk := AScan( _HMG_aControlHandles,{ | elem | iif( ValType( elem ) == "A",( AScan( elem, hSel ) > 0 ), elem == hSel ) } )
      IF pk > 0
         k := _HMG_aControlNames[ pk ]
      ENDIF
   ENDIF

   SetCapture( hWnd )       // capture all mouse events to form messages procedure

   DO CASE
      CASE nMsg == WM_MOUSEMOVE
         IF lRDown
            _ControlPos_DrawFocus_( 0, 0, 0, { sX0, sY0, sX-sX0, sY-sY0 } )
            sX := x
            sY := y
            _ControlPos_DrawFocus_( 0, 0, 1, { sX0, sY0, x-sX0, y-sY0 } )

         ELSEIF lDOwn
            _ControlPos_DrawFocus_( sX-sX0, sY-sY0, nAction )
            sX := x
            sY := y
            _ControlPos_DrawFocus_( x-sX0, y-sY0, nAction )
         ELSE

           DO CASE
              CASE x>=_ControlPosSizeRect_[1]-3 .AND. x<=_ControlPosSizeRect_[1]+1 .and. y>=_ControlPosSizeRect_[2]-3 .and. y<=_ControlPosSizeRect_[2]+1
                   CursorSizeNWSE()

              CASE x>=_ControlPosSizeRect_[1]-_ControlPosSizeRect_[3] .AND. x<=_ControlPosSizeRect_[1]-4 .and. y>=_ControlPosSizeRect_[2]-3 .and. y<=_ControlPosSizeRect_[2]+1
                   CursorSizeNS()

              CASE x>=_ControlPosSizeRect_[1]-3 .AND. x<=_ControlPosSizeRect_[1]+1 .and. y>=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4] .and. y<=_ControlPosSizeRect_[2]-4
                   CursorSizeWE()

              CASE x>=_ControlPosSizeRect_[1]-_ControlPosSizeRect_[3]-3 .AND. x<=_ControlPosSizeRect_[1]-_ControlPosSizeRect_[3]+1 .and. y>=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4] .and. y<=_ControlPosSizeRect_[2]
                   CursorSizeALL()

              CASE x>=_ControlPosSizeRect_[1]-_ControlPosSizeRect_[3] .AND. x<=_ControlPosSizeRect_[1] .and. y>=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4]-3 .and. y<=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4]+1
                   CursorSizeALL()

                OTHERWISE
                   CursorArrow()
           ENDCASE
         ENDIF

      CASE nMsg == WM_LBUTTONDOWN
         IF !lRDown
            DO CASE
              CASE x >= _ControlPosSizeRect_[1]-3 .AND. x<=_ControlPosSizeRect_[1]+1 .and. y>=_ControlPosSizeRect_[2]-3 .and. y<=_ControlPosSizeRect_[2]+1
                 nAction := 1       // resize
                 lDown   := .T.
                 sX0     := sX := x
                 sY0     := sY := y
                 _ControlPos_DrawFocus_( 0, 0, 1 )

              CASE x >= _ControlPosSizeRect_[1]-_ControlPosSizeRect_[3] .AND. x<=_ControlPosSizeRect_[1]-4 .and. y>=_ControlPosSizeRect_[2]-3 .and. y<=_ControlPosSizeRect_[2]+1
                 nAction := 2       // rezize HEIGHT
                 lDown   := .T.
                 sX0     := sX := x
                 sY0     := sY := y
                 _ControlPos_DrawFocus_( 0, 0, 2 )

              CASE x >= _ControlPosSizeRect_[1]-3 .AND. x<=_ControlPosSizeRect_[1]+1 .and. y>=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4] .and. y<=_ControlPosSizeRect_[2]-4
                 nAction := 3       // resize WIDTH
                 lDown   := .T.
                 sX0     := sX := x
                 sY0     := sY := y
                 _ControlPos_DrawFocus_( 0, 0, 3 )

              CASE x >= _ControlPosSizeRect_[1]-_ControlPosSizeRect_[3]-3 .AND. x<=_ControlPosSizeRect_[1]-_ControlPosSizeRect_[3]+1 .and. y>=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4] .and. y<=_ControlPosSizeRect_[2]
                 nAction := 4      // move only HORIZONTAL
                 lDown   := .T.
                 sX0     := sX := x
                 sY0     := sY := y
                 _ControlPos_DrawFocus_( 0, 0, 4 )

              CASE x >= _ControlPosSizeRect_[1]-_ControlPosSizeRect_[3] .AND. x<=_ControlPosSizeRect_[1] .and. y>=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4]-3 .and. y<=_ControlPosSizeRect_[2]-_ControlPosSizeRect_[4]+1
                 nAction := 5      // move only VERTICAL
                 lDown   := .T.
                 sX0     := sX := x
                 sY0     := sY := y
                 _ControlPos_DrawFocus_( 0, 0, 5 )

              CASE ! ( k == "" )
                FOR pk:=1 TO _ControlPos_._ControlPosListControl_.ItemCount
                   IF _ControlPos_._ControlPosListControl_.Item(pk)==k
                      IF ( i:=AScan(_ControlPos_._ControlPosListControl_.Value,pk)) > 0
                         lDown := .T.       //move
                         sX0   := sX := x
                         sY0   := sY := y
                         _ControlPos_DrawFocus_( 0, 0, 0 )
                         EXIT
                      ENDIF
                   ENDIF
                NEXT

            ENDCASE

         ENDIF

      CASE nMsg == WM_LBUTTONUP
         IF ! lRDown
            IF lDown
               lDown := .F.
               _ControlPos_DrawFocus_(  sX-sX0, sY-sY0, nAction )
               _ControlPos_MoveControl_( x-sX0, y-sY0 , nAction )
               nAction := 0
            ENDIF
         ENDIF

      CASE nMsg == WM_RBUTTONDOWN
          IF ! lDown
             lRDown := .T.
             sX0    := sX := x
             sY0    := sY := y
             _ControlPos_DrawFocus_( 0, 0, 0, { x, y, 0, 0 } )
          ENDIF

      CASE nMsg == WM_RBUTTONUP
          IF ! lDOwn
             IF lRDown
                lRDown := .F.
                _ControlPos_DrawFocus_(0,0,0,{sX0,sY0,sX-sX0,sY-sY0})
             ENDIF

             IF Abs( sX - sX0 ) < 10 .AND. Abs(sY-sY0)<10 .AND. !(k=="")
                IF wParam == MK_SHIFT .AND. GetALTState() < 0
                   _ControlPOs_C_SetWindowPosBottom_(hSel)  //change Z-order of control to bootom
                ELSE
                   FOR pk := 1 TO _ControlPos_._ControlPosListControl_.ItemCount
                       IF _ControlPos_._ControlPosListControl_.Item(pk)==k
                          IF wParam == MK_CONTROL
                             IF ( i := AScan((aSel:=_ControlPos_._ControlPosListControl_.Value), pk ) ) > 0
                                ADel( aSel, i )
                                ASize( aSel, Len( aSel ) - 1 )
                                _ControlPos_._ControlPosListControl_.Value := aSel
                             ELSE
                                AAdd(aSel,pk)
                                _ControlPos_._ControlPosListControl_.Value := aSel
                             ENDIF
                          ELSE
                             _ControlPos_._ControlPosListControl_.Value := { pk }
                          ENDIF
                          _ControlPosListControlChange_()
                          EXIT
                       ENDIF

                    NEXT pk

                ENDIF

             ENDIF

          ENDIF

   ENDCASE

   SetProperty(cF,"Title"," X="+Str(x,5)+'  Y='+Str(y,5)+'  CONTROL: '+ k)

Return 0


*------------------------------------------------------------*
PROCEDURE _ControlPos_MoveControl_( dX, dY, nAction )
*------------------------------------------------------------*
   //LOCAL cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
   LOCAL cF := "Form_1"
   LOCAL i
   LOCAL p
   LOCAL cK
   LOCAL x
   LOCAL r
   LOCAL c
   LOCAL w
   LOCAL h
   LOCAL cr
   LOCAL cc
   LOCAL nGrid :=_ControlPos_._ControlPosGridSpinner_.Value
   LOCAL gc
   LOCAL gr
   LOCAL gw
   LOCAL gh
   LOCAL sx
   LOCAL sy
   LOCAL hK
   LOCAL aRect := { 0, 0, 0, 0 }
   LOCAL fr
   LOCAL fc

   sx := GetProperty( cF, "HSCROLLBAR","VALUE")   //virtual form size
   sy := GetProperty( cF, "VSCROLLBAR","VALUE")
   fr := GetProperty( cF, "ROW" ) + GetBorderHeight() + GetTitleHeight()

   IF GetMenu(GetFormHandle(cF)) != 0
      fr := fr + GetMenuBarHeight()
   ENDIF

   fc := GetProperty( cF, "COL" ) + GetBorderWidth()

   FOR i := 1 TO Len( _ControlPos_._ControlPosListControl_.Value )

       p  := _ControlPos_._ControlPosListControl_.value[i]
       cK := _ControlPos_._ControlPosListControl_.Item( p )
       x  := GetControlIndex( cK, cF )
       r  := GetProperty( cF, cK, "ROW")
       c  := GetProperty( cF, cK, "COL")
       w  := GetProperty( cF, cK, "WIDTH")
       h  := GetProperty( cF, cK, "HEIGHT")
       cr := _HMG_aControlContainerRow[x]
       cc := _HMG_aControlContainerCol[x]
       hK := _HMG_aControlHandles[x]

       IF nGrid > 0
          IF cr == -1
             gc := INT((c+dX+(nGrid/2))/nGrid)*nGrid
             gr := INT((r+dY+(nGrid/2))/nGrid)*nGrid
             gw := INT((c+w+dX+(nGrid/2))/nGrid)*nGrid - c
             gh := INT((r+h+dY+(nGrid/2))/nGrid)*nGrid - r
          ELSE
             gc := INT((c+cc+dX+(nGrid/2))/nGrid)*nGrid - cc
             gr := INT((r+cr+dY+(nGrid/2))/nGrid)*nGrid - cr
             gw := INT((c+cc+w+dX+(nGrid/2))/nGrid)*nGrid - c - cc
             gh := INT((r+cr+h+dY+(nGrid/2))/nGrid)*nGrid - r - cr
          ENDIF
       ELSE
          gc := c + dX
          gr := r + dY
          gw := w + dX
          gh := h + dY
       ENDIF

       DO CASE
          CASE nAction==1  ; _SetControlSizePos(cK, cF, r, c, w:=gw, h:=gh)  //resize
          CASE nAction==2  ; _SetControlSizePos(cK, cF, r, c, w, h:=gh)      //resize HEIGHT
          CASE nAction==3  ; _SetControlSizePos(cK, cF, r, c, w:=gw, h)      //rezize WIDTH
          CASE nAction==4  ; _SetControlSizePos(cK, cF, r, c:=gc, w, h)      //move HORIZONTAL
          CASE nAction==5  ; _SetControlSizePos(cK, cF, r:=gr, c, w, h)      //move VERTICAL
          OTHERWISE        ; _SetControlSizePos(cK, cF, r:=gr, c:=gc, w, h)
       ENDCASE

       IF ValType( hK )=="A"
          FOR p := 1 TO Len( hk )
              GetWindowRect( hK[p], aRect )
              MoveWindow( hK[p], aRect[1] - sx - fc, aRect[2] - sy - fr, aRect[3] - aRect[1], aRect[4] - aRect[2], .T. )
          NEXT
       ELSE
          MoveWindow( hK, c - sx, r - sy, w, h, .T. )
       ENDIF
   NEXT

   _ControlPosListControlChange_()

RETURN


*------------------------------------------------------------*
PROCEDURE _ControlPos_DrawFocus_(dX,dY,nAction,aRect)
*------------------------------------------------------------*
//LOCAL cF := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
  LOCAL cF     := "Form_1"
  LOCAL hF     := GetFormHandle( cF )
  LOCAL i
  LOCAL p
  LOCAL cK
  LOCAL x
  LOCAL r
  LOCAL c
  LOCAL w
  LOCAL h
  LOCAL cr
  LOCAL cc
  LOCAL nGrid  := _ControlPos_._ControlPosGridSpinner_.Value
  LOCAL gc
  LOCAL gr
  LOCAL gw
  LOCAL gh
  LOCAL sx
  LOCAL sy

  //when is aRect[] - draw focus for drag mouse (and select controls)
  IF ! (aRect == nil)
    //swap when drag from bottom-right to left-top
    IF aRect[3] < 0
       aRect[1] := aRect[1] + aRect[3]
       aRect[3] := - aRect[3]
    ENDIF

    IF aRect[4] < 0
       aRect[2] := aRect[2] + arect[4]
       aRect[4] := - aRect[4]
    ENDIF

    IF nAction == 1     //draw focus and select/delelect control
       _ControlPos_RectSelect_(aRect[1],aRect[2],aRect[3],aRect[4])
       _ControlPosListControlChange_()
       _ControlPos_C_DrawFocusRect_(hF,aRect[1],aRect[2],aRect[3],aRect[4])
    ELSE                //only draw focus rect
       _ControlPos_C_DrawFocusRect_(hF,aRect[1],aRect[2],aRect[3],aRect[4])
    ENDIF

    RETURN    //back when is aRect[]

  ENDIF

  // when not aRect[] draw focus selected controls
  sx := GetProperty( cF, "HSCROLLBAR", "VALUE" )   //virtual positons
  sy := GetProperty( cF, "VSCROLLBAR", "VALUE" )


  FOR i := 1 TO Len( _ControlPos_._ControlPosListControl_.value )

     p  := _ControlPos_._ControlPosListControl_.value[i]
      cK := _ControlPos_._ControlPosListControl_.Item( p )
      x  := GetControlIndex (cK,cF )
      r  := GetProperty( cF, cK, "ROW"    )
      c  := GetProperty( cF, cK, "COL"    )
      w  := GetProperty( cF, cK, "WIDTH"  )
      h  := GetProperty( cF, cK, "HEIGHT" )
      cr := _HMG_aControlContainerRow[x]
      cc := _HMG_aControlContainerCol[x]

      IF cr == -1
        IF nGrid > 0
           gc := INT((c+dX+(nGrid/2))/nGrid)*nGrid   - sx
           gr := INT((r+dY+(nGrid/2))/nGrid)*nGrid   - sy
           gw := INT((c+w+dX+(nGrid/2))/nGrid)*nGrid - c
           gh := INT((r+h+dY+(nGrid/2))/nGrid)*nGrid - r
        ELSE
           gc := c + dX - sx
           gr := r + dY - sy
           gw := w + dX
           gh := h + dY
        ENDIF

        DO CASE
           CASE nAction==1 ; _ControlPos_C_DrawFocusRect_( hF, c,  r , gw, gh ) //rezize
           CASE nAction==2 ; _ControlPos_C_DrawFocusRect_( hF, c , r , w , gh ) //resize HEIGHT
           CASE nAction==3 ; _ControlPos_C_DrawFocusRect_( hF, c , r , gw, h  ) //rezize WIDTH
           CASE nAction==4 ; _ControlPos_C_DrawFocusRect_( hF, gc, r , w , h  ) //move HORIZONTAL
           CASE nAction==5 ; _ControlPos_C_DrawFocusRect_( hF, c , gr, w , h  ) //move VERTICAL
           OTHERWISE       ; _ControlPos_C_DrawFocusRect_( hF, gc, gr, w , h  ) //move
        ENDCASE

      ELSE
        IF nGrid > 0
           gc := INT( (c+cc+dX+(nGrid/2))/nGrid)*nGrid - sx
           gr := INT( (r+cr+dY+(nGrid/2))/nGrid)*nGrid - sy
           gw := INT( (c+cc+w+dX+(nGrid/2))/nGrid)*nGrid - c - cc
           gh := INT( (r+cr+h+dY+(nGrid/2))/nGrid)*nGrid - r - cr
        ELSE
           gc := c + cc + dX - sx
           gr := r + cr + dY - sy
           gw := w + dX
           gh := h + dY
        ENDIF

        DO CASE
           CASE nAction==1 ; _ControlPos_C_DrawFocusRect_( hF, c+cc, r+cr, gw, gh )
           CASE nAction==2 ; _ControlPos_C_DrawFocusRect_( hF, c+cc, r+cr, w , gh )
           CASE nAction==3 ; _ControlPos_C_DrawFocusRect_( hF, c+cc, r+cr, gw, h  )
           CASE nAction==4 ; _ControlPos_C_DrawFocusRect_( hF, gc  , r+cr, w , h  )
           CASE nAction==5 ; _ControlPos_C_DrawFocusRect_( hF, c+cc, gr  , w , h  )
           OTHERWISE       ; _ControlPos_C_DrawFocusRect_( hF, gc  , gr  , w , h  )
        ENDCASE
      ENDIF
  NEXT

RETURN


// Check controls to select by drag mouse with RButton
*------------------------------------------------------------*
FUNCTION _ControlPos_RectSelect_( rx, ry, rw, rh )
*------------------------------------------------------------*
   LOCAL cF    := _ControlPos_._ControlPosListForm_.Item( _ControlPos_._ControlPosListForm_.value )
   LOCAL i
   LOCAL cK
   LOCAL x
   LOCAL r
   LOCAL c
   LOCAL w
   LOCAL h
   LOCAL cr
   LOCAL cc
   LOCAL aSel  := {}
   LOCAL sx
   LOCAL sy

   IF rw < 10 .AND. rh < 10    //drag must by more 10 points
      RETURN nil
   ENDIF

   sx := GetProperty( cF, "HSCROLLBAR", "VALUE" )
   sy := GetProperty( cF, "VSCROLLBAR", "VALUE" )

   rx := rx + sx
   ry := ry + sy
   rw := rx + rw   //width -> right
   rh := ry + rh   //heigt -> bottom

   FOR i := 1 TO _ControlPos_._ControlPosListControl_.ItemCount

       cK := _ControlPos_._ControlPosListControl_.Item( i )
       x  := GetControlIndex (cK,cF)
       r  := GetProperty( cF, cK, "ROW")
       c  := GetProperty( cF, cK, "COL")
       w  := GetProperty( cF, cK, "WIDTH")
       h  := GetProperty( cF, cK, "HEIGHT")
       cr := _HMG_aControlContainerRow [x]
       cc := _HMG_aControlContainerCol [x]

       IF cr == -1
          w := w + c    // width  -> right
          h := h + r    // height -> bottom
       ELSE
          r := r + cr
          c := c + cc
          w := w + c    // width  -> right
          h := h + r    // height -> bottom
       ENDIF

       // check for rect drag over rect control
       IF _ControlPos_C_RectIn_( rx, ry, rw, rh, c, r, w, h )
          AAdd( aSel, i )
       ENDIF

   NEXT

   IF AScan( aSel, _ControlPosFirst_ ) == 0
      AAdd( aSel , _ControlPosFirst_ )        //We always select "First"
   ENDIF

   _ControlPos_._ControlPosListControl_.Value := aSel

RETURN nil


*------------------------------------------------------------*
PROCEDURE Undo_Changes()
*------------------------------------------------------------*
   Local nPos
   LOCAL iRow
   LOCAL iCol
   LOCAL iWidth
   LOCAL iHeight
   LOCAL cF      := "Form_1"
   LOCAL cK
   LOCAL i
   LOCAL p

   ERASE WINDOW &cF

   FOR i := 1 TO Len(_ControlPos_._ControlPosListControl_.Value )

       p       := _ControlPos_._ControlPosListControl_.value[i]
       cK      := _ControlPos_._ControlPosListControl_.Item( p )
       // MsgBox('control '+Str(i)+ '= ' +ck )
       nPos    := xcontrole( cK )
       iRow    := Val( xArray[ nPos, 5 ] )
       iCol    := Val( xArray[ nPos, 7 ] )
       iWidth  := Val( xArray[ nPos, 9 ] )
       // Msgbox('xvalue = ' +xarray[ nPos, 9 ] )
       iHeight := Val( xArray[ nPos, 11 ] )

       _SetControlSizePos(cK, "Form_1", iRow, iCol, iWidth, iHeight )

   NEXT i

   RedrawWindow( GetFormHandle( cF ) )

RETURN


*------------------------------------------------------------*
PROCEDURE Save_to_array()
*------------------------------------------------------------*
   LOCAL i
   LOCAL r
   LOCAL c
   LOCAL w
   LOCAL h
   LOCAL p
   LOCAL cK
   LOCAL cF := "Form_1"

   FOR i := 1 TO Len(_ControlPos_._ControlPosListControl_.Value )

       p  := _ControlPos_._ControlPosListControl_.value[i]
       cK := _ControlPos_._ControlPosListControl_.Item( p )
       // MsgBox( 'control ' + Str( i ) + '= ' + ck )
       r  := GetProperty( cF, cK, "ROW"    )
       c  := GetProperty( cF, cK, "COL"    )
       w  := GetProperty( cF, cK, "WIDTH"  )
       h  := GetProperty( cF, cK, "HEIGHT" )

       SavePropControl( cK, AllTrim(Str(r)), "ROW"    )
       SavePropControl( cK, AllTrim(Str(c)), "COL"    )
       SavePropControl( cK, AllTrim(Str(w)), "WIDTH"  )
       SavePropControl( cK, AllTrim(Str(h)), "HEIGHT" )

   NEXT i

RETURN

//------------------------------------------------------------------------------


//---------------------------------------------------------------------------

#pragma BEGINDUMP

#include <windows.h>
#include <commctrl.h>
#include <wingdi.h>
#include <winuser.h>

#include "hbapi.h"
#include "hbvm.h"


// return adress(?)/ID of codeblock (for identy it)   fun(bCodeBlock)
HB_FUNC ( _CONTROLPOS_C_GETBLOCKID_ )
{
 PHB_ITEM bl = hb_param( 1 , HB_IT_BLOCK ) ;
 ULONG nId ;
 if( bl )
 {
#ifdef __XHARBOUR__
     nId = (ULONG) bl->item.asBlock.value ;
#else
     nId = (ULONG) hb_codeblockId( bl ) ;
#endif
     hb_retnl( nId );
 }
 else
 {
     hb_retnl( 0 ) ;
 }

}

// Draw box (not filled, only border)    fun(hForm,left,top,right,bottom,color)
HB_FUNC ( _CONTROLPOS_C_WNDBOX_ )
{
  RECT rct;
  HWND hWnd =  ( HWND) hb_parnl( 1 ) ;
  HDC hDC = GetDC( hWnd  );
  HBRUSH hBr ;
  ULONG clr = hb_parni( 6 ) ;
  rct.left    = hb_parni( 2 ) - 1;    //   +1 -1 for around
  rct.top   = hb_parni( 3 ) - 1;
  rct.right = hb_parni( 4 ) + 1;
  rct.bottom  = hb_parni( 5 ) + 1;

  hBr = CreateSolidBrush( clr ) ;
  FrameRect( hDC , &rct , hBr ) ;
  DeleteObject( hBr );
  ReleaseDC( hWnd, hDC ) ;

}

// Set style for control       fun(hControl,nStyle,lSetBits)
HB_FUNC ( _CONTROLPOS_C_SETSTYLE_ )
{
  LONG Style = GetWindowLong( (HWND) hb_parnl(1), GWL_STYLE );
   if (hb_parl(3))
   {
    SetWindowLong( (HWND) hb_parnl(1), GWL_STYLE, Style | hb_parni(2) );
   }
   else    //reset bits
   {
    SetWindowLong( (HWND) hb_parnl(1), GWL_STYLE, Style & (~hb_parni(2)) );
   }

}

// My window procedure (for messages)
LRESULT CALLBACK MyFormProc (HWND hWin, UINT Msg, WPARAM wParam, LPARAM lParam)
{
        static PHB_SYMB pSymbol = NULL;
        long int r;
        WNDPROC OldWndProc;

        OldWndProc = (WNDPROC)GetProp( hWin, "oldformproc" );

        switch( Msg )
        {
                case WM_DESTROY:

                        SetWindowLong( hWin, GWL_WNDPROC, (DWORD)OldWndProc );
                        RemoveProp( hWin, "oldformproc" );
                        break;

                case WM_CONTEXTMENU:
                      return 1 ;

//                case WM_CAPTURECHANGED:
//                case WM_LBUTTONDBLCLK:
                case WM_LBUTTONDOWN:
                case WM_LBUTTONUP:
//                case WM_RBUTTONDBLCLK:
                case WM_RBUTTONDOWN:
                case WM_RBUTTONUP:
                case WM_MOUSEMOVE:
                case WM_NCMOUSEMOVE:
                {
                        if ( ! pSymbol)
                        {
                                pSymbol = hb_dynsymSymbol( hb_dynsymGet( "_CONTROLPOS_FORMPROC_" ));
                        }
                        if ( pSymbol )
                        {
                                hb_vmPushSymbol( pSymbol  );
                                hb_vmPushNil();
                                hb_vmPushLong( ( LONG ) hWin );
                                hb_vmPushLong( Msg );
                                hb_vmPushLong( wParam );
                                hb_vmPushLong( (SHORT) LOWORD(lParam) );
                                hb_vmPushLong( (SHORT) HIWORD(lParam) );
                                hb_vmDo( 5 );
                        }
                        r = hb_parnl( -1 );

                        if ( r != 0 )
                        {
                                return r ;
                        }
                        else
                        {
                                return( CallWindowProc( OldWndProc, hWin, Msg, wParam, lParam ) );
                        }
                }
        }

        return( CallWindowProc( OldWndProc, hWin, Msg, wParam, lParam ) );
}

//Set/reset "Window Procedure" (messages procedure)    fun(hForm,lSetProcedure)
HB_FUNC ( _CONTROLPOS_C_SETFORMPROC_ )
{
   WNDPROC OldWndProc;
   HWND hWin = (HWND) hb_parnl(1) ;

   if( hb_parl(2) )
   {
     SetProp(  hWin, "oldformproc", (HWND) GetWindowLong(  hWin, GWL_WNDPROC ) ) ;
     SetWindowLong( hWin, GWL_WNDPROC, (LONG)(WNDPROC)MyFormProc ) ;
   }
   else
   {
      OldWndProc = (WNDPROC)GetProp( hWin, "oldformproc" );
      SetWindowLong( hWin, GWL_WNDPROC, (DWORD)OldWndProc );
      RemoveProp( hWin, "oldformproc" );
   }

}

//find controls on form    fun(hForm,x,y)
HB_FUNC ( _CONTROLPOS_C_CHILDWINDOWFROMPOINT_ )
{
   POINT pt;
   HWND h  ;
   pt.x =  hb_parnl(2)  ;
   pt.y =  hb_parnl(3)  ;
   h = ChildWindowFromPoint((HWND) hb_parnl(1) , pt );
   hb_retnl( (LONG) h ) ;
}

// Draw focus box for mouse move/size  fun(hForm,x,y,width,height)
HB_FUNC ( _CONTROLPOS_C_DRAWFOCUSRECT_ )
{
  RECT rct;
  HWND hWnd =  ( HWND) hb_parnl( 1 ) ;
  HDC hDC = GetDC( hWnd  );

  rct.left   = hb_parni( 2 ) - 1 ;       //   +1 -1 for around
  rct.top    = hb_parni( 3 ) - 1 ;
  rct.right  = hb_parni( 2 ) + hb_parni( 4 ) + 1;
  rct.bottom = hb_parni( 3 ) + hb_parni( 5 ) + 1;
  DrawFocusRect( hDC , &rct ) ;
  ReleaseDC( hWnd, hDC ) ;

}

// Change Z-ordef of window (control) to bottom    fun(hWin)
HB_FUNC ( _CONTROLPOS_C_SETWINDOWPOSBOTTOM_ )
{
  HWND hWnd =  ( HWND) hb_parnl( 1 ) ;
  SetWindowPos( hWnd, HWND_BOTTOM , 0,0,0,0, SWP_NOMOVE | SWP_NOSIZE );
}

// Draw grid points                      fun(hWin,nStepGrid,HScroll,VScroll)
HB_FUNC ( _CONTROLPOS_C_DRAWGRID_ )
{
  int w ;
  int h ;
  int s ;
  int x ;
  int y ;
  int sx ;      //new v3.60
  int sy ;      //new v3.60
  HWND hWnd =  ( HWND) hb_parnl( 1 ) ;
  HDC hDC = GetDC( hWnd  );
  w = GetDeviceCaps(hDC , HORZRES ) ;
  h = GetDeviceCaps(hDC , VERTRES ) ;
  s = hb_parni( 2 ) ;
  sx =  hb_parni( 3 ) % s  ;
  if( sx )
     sx = s - sx ;
  sy = hb_parni( 4 ) % s  ;
  if( sy )
     sy = s - sy ;

  for( x=sx ; x < w ; x=x+s )
    {
    for( y=sy ; y < h ; y=y+s)
       {
       SetPixel( hDC, x , y , (COLORREF) 0 ) ;
       };
    };
  ReleaseDC( hWnd, hDC ) ;

}

// Check to rect2 over rect1  fun(left1,top1,right1,bottom1,left2,top2,right2,bottom2)
HB_FUNC ( _CONTROLPOS_C_RECTIN_ )
{
   HRGN hR ;
   RECT r  ;

   hR = CreateRectRgn(
          hb_parni( 1 ) ,
          hb_parni( 2 ) ,
          hb_parni( 3 ) ,
          hb_parni( 4 ) ) ;

   r.left = hb_parni( 5 ) ;
   r.top =  hb_parni( 6 ) ;
   r.right = hb_parni( 7 ) ;
   r.bottom = hb_parni( 8 ) ;

   if ( RectInRegion( hR , &r ) )
      hb_retl( TRUE ) ;
   else
      hb_retl( FALSE ) ;

   DeleteObject( hR ) ;

}

#pragma ENDDUMP
