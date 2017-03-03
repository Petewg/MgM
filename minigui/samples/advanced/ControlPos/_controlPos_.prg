//  *****************************************************************
//  ** CONTROLPOS   v1.00                                          **
//  **        Change on runtime positon and size of control        **
//  **        and save it to file                                  **
//  **                                                             **
//  **  (c) Adam Lubszczyk                                         **
//  *****************************************************************
// TO USE:
//  Copy file "_ControlPos_.prg" to Your program folder.
//  In Your main *.prg before function main() add line:
//     SET PROCEDURE TO _ControlPos_.prg
//  before line with:
//     ACTIVATE WINDOW YourMainForm
//  add line:
//     ControlPosSTART()
//
//   Hot keys:
//    Shift+arrow_key     ->   move selected controls
//    Ctrl+arrow_key      ->   resize selected controls
//    Shit+TAB , Ctrl+TAB ->   next/previous controls
//------------------------------------------------------------------------------
#define __SYSDATA__
#include "minigui.ch"

#define _CONTROLPOS_COLOR1_  {0,0,255}
#define _CONTROLPOS_COLOR2_  {255,0,255}

// If You don't want sorting controls in list uncomment next line
//#define _CONTROLPOS_NO_SORT_

FUNCTION ControlPosSTART

PUBLIC _ControlPosFirst_ := 0

DEFINE WINDOW _ControlPos_ AT 25 , 834 WIDTH 190 HEIGHT 570 TITLE "Form's controls" TOPMOST

   ON KEY SHIFT+Left  ACTION _ControlPosSet_ON_KEY_("L")
   ON KEY SHIFT+Right ACTION _ControlPosSet_ON_KEY_("R")
   ON KEY SHIFT+Up ACTION _ControlPosSet_ON_KEY_("U")
   ON KEY SHIFT+Down ACTION _ControlPosSet_ON_KEY_("D")
   ON KEY CONTROL+Left ACTION _ControlPosSet_ON_KEY_("W-")
   ON KEY CONTROL+Right ACTION _ControlPosSet_ON_KEY_("W+")
   ON KEY CONTROL+Up ACTION _ControlPosSet_ON_KEY_("H-")
   ON KEY CONTROL+Down ACTION _ControlPosSet_ON_KEY_("H+")
   ON KEY SHIFT+TAB ACTION _ControlPosSet_ON_KEY_("TAB")
   ON KEY CONTROL+TAB ACTION _ControlPosSet_ON_KEY_("TAB-")

    DEFINE LISTBOX _ControlPosListForm_
        ROW    24
        COL    10
        WIDTH  165
        HEIGHT 56
        ITEMS {}
        VALUE 0
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE _ControlPosListFormChange_()
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
        ONDBLCLICK Nil
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        SORT .F.
        MULTISELECT .F.
    END LISTBOX

    DEFINE LABEL _ControlPosLabelForm_
        ROW    5
        COL    10
        WIDTH  70
        HEIGHT 20
        VALUE "Forms"
        FONTNAME "Arial"
        FONTSIZE 12
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        VISIBLE .T.
        TRANSPARENT .F.
        ACTION Nil
        AUTOSIZE .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
    END LABEL

    DEFINE LABEL _ControlPosLabelControl_
        ROW    90
        COL    10
        WIDTH  71
        HEIGHT 20
        VALUE "Controls"
        FONTNAME "Arial"
        FONTSIZE 12
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        VISIBLE .T.
        TRANSPARENT .F.
        ACTION Nil
        AUTOSIZE .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
    END LABEL

    DEFINE LISTBOX _ControlPosListControl_
        ROW    112
        COL    10
        WIDTH  165
        HEIGHT 358
        ITEMS {}
        VALUE 0
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE _ControlPosListControlChange_()
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
        ONDBLCLICK Nil
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        SORT .F.
        MULTISELECT .T.
    END LISTBOX

    DEFINE BUTTON _ControlPosButtonGet_
        ROW    510
        COL    10
        WIDTH  80
        HEIGHT 25
        CAPTION "Get controls"
        ACTION _ControlPosButtonGetClick_()
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        HELPID Nil
        FLAT .F.
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .F.
        PICTURE Nil
    END BUTTON

    DEFINE BUTTON _ControlPosButtonSave_
        ROW    510
        COL    100
        WIDTH  80
        HEIGHT 25
        CAPTION "Save change"
        ACTION _ControlPosButtonSaveClick_()
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        HELPID Nil
        FLAT .F.
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .F.
        PICTURE Nil
    END BUTTON

    DEFINE COMBOBOX _ControlPosCombo_
        ROW    480
        COL    10
        WIDTH  170
        HEIGHT 500
        ITEMS {'** CHOICE OPERATION **','Align LEFT','Align RIGHT','Align TOP','Align BOTTOM','Center HORIZONTAL','Center VERICAL','Stack HORIZONTAL','Stack VERTICAL','Spread HORIZONTAL','Spread VERTICAL','Make same HEIGHT','Make same WIDTH'}
        VALUE 1
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE _ControlPosComboChange_()
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        SORT .F.
        ONENTER Nil
        ONDISPLAYCHANGE Nil
        DISPLAYEDIT .F.
    END COMBOBOX

END WINDOW

 _ControlPos_.col := GetDesktopWidth() - 190
 _ControlPos_.Show()
 _ControlPosButtonGetClick_()
 _ControlPosListControlChange_()

RETURN Nil

//------------------------------------------------------------------------------

FUNCTION _ControlPosButtonGetClick_
LOCAL i


_ControlPos_._ControlPosListForm_.DeleteAllItems()
 FOR i:=1 TO Len(_HMG_aFormNames)
   IF _HMG_aFormNames[i] != '_ControlPos_'
     IF _HMG_aFormReBarHandle[i] == 0
        _ControlPos_._ControlPosListForm_.AddItem( _HMG_aFormNames[i] )
     ELSE
        _ControlPos_._ControlPosListForm_.AddItem( _HMG_aFormNames[i]+" !SPLITED!" )
     ENDIF
   ENDIF
NEXT
_ControlPos_._ControlPosListForm_.Value := 1
_ControlPosListFormChange_()
_ControlPos_._ControlPosListControl_.SetFocus()


RETURN Nil

//------------------------------------------------------------------------------

FUNCTION _ControlPosListFormChange_
LOCAL i , h
LOCAL p,ak:={}
STATIC cForm := ""

IF !(cForm == "" .OR. " !SPLITED!" $ cForm)
  ERASE WINDOW &cForm
  RELEASE KEY SHIFT+Left OF &cForm
  RELEASE KEY SHIFT+Right OF &cForm
  RELEASE KEY SHIFT+Up OF &cForm
  RELEASE KEY SHIFT+Down OF &cForm
  RELEASE KEY CONTROL+Left OF &cForm
  RELEASE KEY CONTROL+Right OF &cForm
  RELEASE KEY CONTROL+Up OF &cForm
  RELEASE KEY CONTROL+Down OF &cForm
  RELEASE KEY SHIFT+Tab OF &cForm
  RELEASE KEY CONTROL+Tab OF &cForm
ENDIF

h := _ControlPos_._ControlPosListForm_.value
cForm := _ControlPos_._ControlPosListForm_.Item(h)
_ControlPos_._ControlPosListControl_.DeleteAllItems()

IF " !SPLITED!" $ cForm
  RETURN nil
ENDIF

h := GetFormHandle(cForm) //_HMG_aFormHandles[h]

FOR i:=1 TO Len(_HMG_aControlNames)
   IF _HMG_aControlParentHandles[i] == h
          //type control not to use "@type@"
      IF !("@"+Upper(_HMG_aControlType[i])+"@" $ "@HOTKEY@@MENU@@POPUP@@TOOLBAR@@TOOLBUTTON@@MESSAGEBAR@@ITEMMESSAGE@@TIMER@")
#ifdef _CONTROLPOS_NO_SORT_
         _ControlPos_._ControlPosListControl_.AddItem( _HMG_aControlNames[i] )
      ENDIF
   ENDIF
NEXT
#else
         p := Str(_HMG_aControlContainerRow[i]+1,4,0)
         p += Str(_HMG_aControlContainerCol[i]+1,4,0)
// p += str(PAGE_of_TAB)  I want include numer of PAGE in TAB , but I don't known how :(
         p += Str(Int(_HMG_aControlRow[i]/20),4,0)
                                      //  ^^   round to 20 points lines
         p += Str(_HMG_aControlCol[i],4,0)
         AAdd(ak,{_HMG_aControlNames[i],p})
      ENDIF
   ENDIF
NEXT
ASort(ak,,,{|x,y|x[2]<y[2]})
FOR i:= 1 TO Len(ak)
  _ControlPos_._ControlPosListControl_.AddItem( ak[i,1] )
NEXT
#endif

ON KEY SHIFT+Left OF &cForm ACTION _ControlPosSet_ON_KEY_("L")
ON KEY SHIFT+Right OF &cForm ACTION _ControlPosSet_ON_KEY_("R")
ON KEY SHIFT+Up OF &cForm ACTION _ControlPosSet_ON_KEY_("U")
ON KEY SHIFT+Down OF &cForm ACTION _ControlPosSet_ON_KEY_("D")
ON KEY CONTROL+Left OF &cForm ACTION _ControlPosSet_ON_KEY_("W-")
ON KEY CONTROL+Right OF &cForm ACTION _ControlPosSet_ON_KEY_("W+")
ON KEY CONTROL+Up OF &cForm ACTION _ControlPosSet_ON_KEY_("H-")
ON KEY CONTROL+Down OF &cForm ACTION _ControlPosSet_ON_KEY_("H+")
ON KEY SHIFT+TAB OF &cForm ACTION _ControlPosSet_ON_KEY_("TAB")
ON KEY CONTROL+TAB OF &cForm ACTION _ControlPosSet_ON_KEY_("TAB-")

_ControlPos_._ControlPosListControl_.Value := {1}
_ControlPosListControlChange_()
RETURN NIL

//------------------------------------------------------------------------------

FUNCTION _ControlPosListControlChange_
LOCAL cF ,cK ,r,c,w,h
LOCAL x,cr,cc
LOCAL i,p, is_f:=.F.

cF := _ControlPos_._ControlPosListForm_.item( _ControlPos_._ControlPosListForm_.value )

IF " !SPLITED!" $ cF
  RETURN nil
ENDIF

ERASE WINDOW &cF
IF Len(_ControlPos_._ControlPosListControl_.value) == 1
  _ControlPosFirst_ := _ControlPos_._ControlPosListControl_.value[1]
ENDIF
FOR i:= 1 TO  Len(_ControlPos_._ControlPosListControl_.value)

   p := _ControlPos_._ControlPosListControl_.value[i]
   cK := _ControlPos_._ControlPosListControl_.item( p )
   r :=  GetProperty(cF,cK,"ROW")
   c :=  GetProperty(cF,cK,"COL")
   w :=  GetProperty(cF,cK,"WIDTH")
   h :=  GetProperty(cF,cK,"HEIGHT")
   x := GetControlIndex (cK,cF)
   cr := _HMG_aControlContainerRow [x]
   cc := _HMG_aControlContainerCol [x]

   IF  p == _ControlPosFirst_
      SetProperty(cF,"Title"," r:"+Str(r,4)+"  c:"+Str(c,4)+"  w:"+Str(w,4)+"  h:"+Str(h,4) )
      is_f := .T.
   ENDIF

   //ERASE WINDOW &cF
   IF cr == -1
     drawline(cF,r,c,r+h,c,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r,c,r,c+w,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+h,c,r+h,c+w,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r,c+w,r+h,c+w,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
   ELSE  //on container like TAB
     drawline(cF,r+cr,c+cc,r+h+cr,c+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+cr,c+cc,r+cr,c+w+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+h+cr,c+cc,r+h+cr,c+w+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+cr,c+w+cc,r+h+cr,c+w+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
   ENDIF

NEXT

IF is_f .AND. Len(_ControlPos_._ControlPosListControl_.value) > 1
   _ControlPos_._ControlPosCombo_.enabled := .T.
ELSE
   _ControlPos_._ControlPosCombo_.enabled := .F.
ENDIF

RETURN( NIL )

//------------------------------------------------------------------------------

FUNCTION _ControlPosSet_ON_KEY_(cTyp)
LOCAL cF ,cK ,r,c,w,h,fh,fw
LOCAL x,cr,cc
LOCAL i,p
cF := _ControlPos_._ControlPosListForm_.item( _ControlPos_._ControlPosListForm_.value )
IF " !SPLITED!" $ cF
  RETURN nil
ENDIF

ERASE WINDOW &cF

FOR i:= 1 TO Len(_ControlPos_._ControlPosListControl_.value)
   p := _ControlPos_._ControlPosListControl_.value[i]
   cK := _ControlPos_._ControlPosListControl_.item( p )
   x := GetControlIndex (cK,cF)
   r :=  GetProperty(cF,cK,"ROW")
   c :=  GetProperty(cF,cK,"COL")
   w :=  GetProperty(cF,cK,"WIDTH")
   h :=  GetProperty(cF,cK,"HEIGHT")
   fw :=  GetProperty(cF,"WIDTH")
   fh :=  GetProperty(cF,"HEIGHT")
   cr := _HMG_aControlContainerRow [x]
   cc := _HMG_aControlContainerCol [x]

   DO CASE
     CASE cTyp == "U"
        IF r>0
           r--
        ENDIF
     CASE cTyp == "D"
        IF r<fh-h
           r++
        ENDIF
     CASE cTyp == "L"
        IF c>0
           c--
        ENDIF
     CASE cTyp == "R"
        IF c<fw-w
           c++
        ENDIF
     CASE cTyp == "H-"
        IF h>0
           h--
        ENDIF
     CASE cTyp == "H+"
        IF h<fh-r
           h++
        ENDIF
     CASE cTyp == "W-"
        IF w>0
           w--
        ENDIF
     CASE cTyp == "W+"
        IF w<fw-c
           w++
        ENDIF

     CASE cTyp == "TAB"
        r := _ControlPosFirst_
        IF r < _ControlPos_._ControlPosListControl_.ItemCount
           r++
        ELSE
           r:=1
        ENDIF
        _ControlPos_._ControlPosListControl_.Value := {r}
        _ControlPosListControlchange_()
        RETURN Nil
     CASE cTyp == "TAB-"
        r := _ControlPosFirst_
        IF r > 1
           r--
        ELSE
           r:= _ControlPos_._ControlPosListControl_.ItemCount
        ENDIF
        _ControlPos_._ControlPosListControl_.Value := {r}
        _ControlPosListControlchange_()
        RETURN Nil

   ENDCASE

   IF p == _ControlPosFirst_
      SetProperty(cF,"Title"," r:"+Str(r,4)+"  c:"+Str(c,4)+"  w:"+Str(w,4)+"  h:"+Str(h,4) )
   ENDIF
   _SetControlSizePos(cK, cF, r, c, w, h)
//   RedrawWindow(GetFormHandle(cF))
   IF cr == -1
     drawline(cF,r,c,r+h,c,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r,c,r,c+w,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+h,c,r+h,c+w,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r,c+w,r+h,c+w,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
   ELSE
     drawline(cF,r+cr,c+cc,r+h+cr,c+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+cr,c+cc,r+cr,c+w+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+h+cr,c+cc,r+h+cr,c+w+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
     drawline(cF,r+cr,c+w+cc,r+h+cr,c+w+cc,IIf(_ControlPosFirst_== p,_CONTROLPOS_COLOR1_,_CONTROLPOS_COLOR2_),1)
   ENDIF

NEXT


RETURN( NIL )


//------------------------------------------------------------------------------
FUNCTION _ControlPosComboChange_
LOCAL typ := _ControlPos_._ControlPosCombo_.value
LOCAL cF,cK
LOCAL fr,fc,fw,fh,ak:={},r,c,w,h
LOCAL i,av
IF typ == 1
   RETURN NIL
ENDIF

cF := _ControlPos_._ControlPosListForm_.item( _ControlPos_._ControlPosListForm_.value )
IF " !SPLITED!" $ cF
  RETURN nil
ENDIF

av:=_ControlPos_._ControlPosListControl_.value
FOR i:=1 TO Len(av)
   cK := _ControlPos_._ControlPosListControl_.item( av[i] )
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
     ASort(ak,,,{|x,y|x[3] < y[3]})
     fc := fc + fw
     FOR i:= 1 TO Len(ak)
        ak[i,3] := fc
        fc := fc + ak[i,4]
     NEXT

  CASE typ == 9   //Stack VERTICAL
     ASort(ak,,,{|x,y|x[2] < y[2]})
     fr := fr + fh
     FOR i:= 1 TO Len(ak)
        ak[i,2] := fr
        fr := fr + ak[i,5]
     NEXT

  CASE typ == 10  //Spread HORIZONTAL    (równomiernie)
     ASort(ak,,,{|x,y|x[3] < y[3]})
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

  CASE typ == 11  //Spread VERITCAL
     ASort(ak,,,{|x,y|x[2] < y[2]})
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

  CASE typ == 12  //Make same HEIGHT
     FOR i:= 1 TO Len(ak)
        ak[i,5] := fh
     NEXT

  CASE typ == 13  //Make same WIDTH
     FOR i:= 1 TO Len(ak)
        ak[i,4] := fw
     NEXT

END CASE

FOR i:= 1 TO Len(ak)
  _SetControlSizePos(ak[i,1], cF, ak[i,2],ak[i,3],ak[i,4],ak[i,5])
NEXT

_ControlPos_._ControlPosCombo_.value := 1

_ControlPosListControlChange_()

RETURN NIL


//------------------------------------------------------------------------------

FUNCTION _ControlPosButtonSaveClick_
LOCAL cF
cF := _ControlPos_._ControlPosListForm_.item( _ControlPos_._ControlPosListForm_.value )

IF " !SPLITED!" $ cF
  RETURN nil
ENDIF

#ifdef __XHARBOUR__
  _ControlPosSaveToFMG_()
#endif
  _ControlPosSaveToMyFile_()

RETURN NIL

//------------------------------------------------------------------------------

FUNCTION _ControlPosSaveToMyFile_
LOCAL i,j,ss,cr:=Chr(13)+Chr(10),crs :=" ;"+cr
LOCAL nF,cFile
LOCAL cF,cK,x
LOCAL rr,cc,ww,hh,wws,ct
// change TYPE {internal, DEFINE }
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
             {"MONTHCAL","MONTHCALENDAR"} }


cF := _ControlPos_._ControlPosListForm_.item( _ControlPos_._ControlPosListForm_.value )

cFile := C_PUTFILE2("ControlPos File (*.pos)"+Chr(0)+"*.pos"+Chr(0),"Save control positon to file",GetCurrentFolder(),nil,cF+".pos" )
IF Empty(cFile)
   RETURN nil
ENDIF
IF File(cFile)
  IF !MsgYesNo("   File exist:"+cr+cFile+cr+cr+"    Overwrite ?","File exist")
     RETURN nil
  ENDIF
ENDIF
ss:="// File generated by tools CONTROLPOS   (c)AL" +cr
ss += "// Position form controls: " + cr + cr
ss += "// DEFINE WINDOW " + cF + " AT " + ALLTRIM(Str(GetProperty(cF,"ROW")))+" , "+;
                                          ALLTRIM(Str(GetProperty(cF,"COL")))+;
                                          " WIDTH "+ALLTRIM(Str(GetProperty(cF,"WIDTH")))+;
                                          " HEIGHT "+ALLTRIM(Str(GetProperty(cF,"HEIGHT"))) +cr + cr
FOR i:= 1 TO _ControlPos_._ControlPosListControl_.ItemCount
  cK := _ControlPos_._ControlPosListControl_.item(i)
  x := GetControlIndex (cK,cF)
  rr := AllTrim(Str(GetProperty(cF,cK,"ROW")))   //        _HMG_aControlRow[x]))
  cc := AllTrim(Str(GetProperty(cF,cK,"COL")))   //        _HMG_aControlCol[x]))
  ww := AllTrim(Str(GetProperty(cF,cK,"WIDTH"))) //        _HMG_aControlWidth[x]))
  hh := AllTrim(Str(GetProperty(cF,cK,"HEIGHT"))) //        _HMG_aControlHeight[x]))
  ct := _HMG_aControlType[x]
  j:=ASCAN(at,{|aa|aa[1]==ct})    //change internal type to DEFINE type
  IF j>0
    ct := at[j,2]
  ENDIF
  IF ct == "CHECKBOX"
     IF ValType( _HMG_aControlPageMap[x] ) == "A"   //mayby it's correct ?
        ct := "CHECKBUTTON"
     ENDIF
  ENDIF
// IDE syntax
  IF ct == "TAB"
     ss += "   DEFINE " + ct + " " + cK + crs
     ss += "      AT " + rr + ", " + cc + crs
     ss += "      WIDTH " + ww + crs
     ss += "      HEIGHT " + hh + crs
  ELSE
     ss += "   DEFINE " + ct + " " + cK + cr
     ss += "      ROW " + rr + cr
     ss += "      COL " + cc + cr
     ss += "      WIDTH " + ww + cr
     ss += "      HEIGHT " + hh + cr
     IF "@"+ct+"@" $ "@BROWSE@GRID@"
        wws := "{"
        FOR j:= 1 TO   Len(_HMG_aControlPageMap[x])
            wws += AllTrim(Str(ListView_GetColumnWidth ( _HMG_aControlHandles [x] , j-1 )))
            IF j < Len(_HMG_aControlPageMap[x])
               wws += ","
            ENDIF
        NEXT
        wws += "}"
        ss += "      WIDTHS "+ wws +cr
     ENDIF
//MGIDE syntax
     ss += "*   @ " + rr + ", " + cc + " " + ct + " " + cK + crs
     ss += "*      WIDTH " + ww + crs
     ss += "*      HEIGHT " + hh + crs
     IF "@"+ct+"@" $ "@BROWSE@GRID@"
        ss += "*      WIDTHS " + wws + crs
     ENDIF
  ENDIF
//Run time change syntax
  ss += "//      " + cF+ "." + cK + ".row := " + rr + cr
  ss += "//      " + cF+ "." + cK + ".col := " + cc + cr
  ss += "//      " + cF+ "." + cK + ".width := " + ww + cr
  ss += "//      " + cF+ "." + cK + ".height := " + hh + cr
  IF "@"+ct+"@" $ "@BROWSE@GRID@"
     ss += "//      " + cF+ "." + cK + ".widths := " + wws + cr
  ENDIF
  ss += cr
NEXT
ss += "//end file" + cr

nF := FCreate(cFile,0)
IF nF == -1
   MsgStop("Can't create file"+cr+cFile,"Error")
   RETURN nil
ENDIF
FWrite(nF,ss)
FClose(nf)

RETURN( NIL )

//---------------------------------------------------------------------------
#ifdef __XHARBOUR__
FUNCTION _ControlPosSaveToFMG_
LOCAL nF,cFile,cFile2,nF2
LOCAL buff:=SPACE(128),l,ss:=""
LOCAL reg,aMatch
LOCAL cF,cK,x
LOCAL i,j
LOCAL rr,cc,ww,hh,wws,ct
LOCAL cr:=Chr(13)+Chr(10)

// chane TYPE {internal, DEFINE }
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
             {"MONTHCAL","MONTHCALENDAR"} }

cF := _ControlPos_._ControlPosListForm_.item( _ControlPos_._ControlPosListForm_.value )

cFile := GetFile({{"IDE FORM definition (*.fmg)","*.fmg"},{"Program source files (*.prg)","*.prg"}},"Open FORM definition for template",GetCurrentFolder())
IF EMPTY(cFile)
  RETURN nil
ENDIF
cFile2 := C_PUTFILE2("Modified source file (*.??m)"+Chr(0)+"*.??m"+Chr(0),"Save modified FORM to file",GetCurrentFolder(),nil,cFileNoExt(cFile)+IIf(Upper(Right(cFile,3))=="PRG",".prm",".fmm") )
IF Empty(cFile2)
   RETURN nil
ENDIF

IF File(cFile2)
  IF !MsgYesNo("   File exist: "+cFile2+cr+"    Overwrite ?","File exist")
     RETURN nil
  ENDIF
ENDIF



IF (nF := FOPEN(cFile)) == -1
  RETURN nil
ENDIF

DO WHILE (l:=FREAD(nF,@buff,128)) > 0
  ss += LEFT(buff,l)
ENDDO
FCLOSE(nF)


FOR i:= 1 TO _ControlPos_._ControlPosListControl_.ItemCount
  cK := _ControlPos_._ControlPosListControl_.item(i)
  x := GetControlIndex (cK,cF)
  rr := AllTrim(Str(GetProperty(cF,cK,"ROW")))   //        _HMG_aControlRow[x]))
  cc := AllTrim(Str(GetProperty(cF,cK,"COL")))   //        _HMG_aControlCol[x]))
  ww := AllTrim(Str(GetProperty(cF,cK,"WIDTH"))) //        _HMG_aControlWidth[x]))
  hh := AllTrim(Str(GetProperty(cF,cK,"HEIGHT"))) //        _HMG_aControlHeight[x]))
  ct := _HMG_aControlType[x]
  j:=ASCAN(at,{|aa|aa[1]==ct})    //change internal type to DEFINE type
  IF j>0
    ct := at[j,2]
  ENDIF
  IF ct == "CHECKBOX"    //CHECKBOX and CHECKBUTTON internal is CHECKBOX
     IF ValType( _HMG_aControlPageMap[x] ) == "A"   //mayby it's correct ?
        ct := "CHECKBUTTON"
     ENDIF
  ENDIF

  IF ct == "TAB"
  // ROW , COL
     reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?AT[ \t]+?)(\d+)([ \t]*?\,[ \t]*?)(\d+)(.*)")
     aMatch := HB_Regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+rr+aMAtch[4]+cc+aMatch[6]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" AT ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
  //WIDTH
     reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?AT[ \t]+?.*?\sWIDTH[ \t]+)(\d+)(.*)")
     aMatch := HB_Regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+ww+aMAtch[4]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" AT ... WIDTH ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
  //HEIGHT
     reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?AT[ \t]+?.*?\sHEIGHT[ \t]+)(\d+)(.*)")
     aMatch := HB_Regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+hh+aMAtch[4]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" AT ... HEIGHT ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
  ELSE  //ct == "TAB"
  // ROW
     reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?\sROW[ \t]+?)(\d+)(.*)")
     aMatch := HB_Regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+rr+aMatch[4]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" ... ROW ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
  //COL
     reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?\sCOL[ \t]+?)(\d+)(.*)")
     aMatch := HB_Regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+cc+aMatch[4]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" ... COL ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
  //WIDTH
     reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?\sWIDTH[ \t]+?)(\d+)(.*)")
     aMatch := HB_Regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+ww+aMatch[4]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" ... WIDTH ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
  //HEIGHT
     reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?\sHEIGHT[ \t]+?)(\d+)(.*)")
     aMatch := HB_Regex(reg,ss)
     IF ValType(aMatch) == "A"
        ss := aMatch[2]+hh+aMatch[4]
     ELSE
        IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" ... HEIGHT ...'"+cr+"Continue ?")
           RETURN nil
        ENDIF
     ENDIF
  //WIDTHS
     IF "@"+ct+"@" $ "@BROWSE@@GRID@"
        wws := "{"
        FOR j:= 1 TO   Len(_HMG_aControlPageMap[x])
            wws += AllTrim(Str(ListView_GetColumnWidth ( _HMG_aControlHandles [x] , j-1 )))
            IF j < Len(_HMG_aControlPageMap[x])
               wws += ","
            ENDIF
        NEXT
        wws += "}"
        reg := HB_RegexComp("(?si)(.*DEFINE[ \t]+"+ct+"[ \t]+"+ck+".+?\sWIDTHS[ \t]+?)(\{ *?[\d+\, ]+ *?\})(.*)")
        aMatch := HB_Regex(reg,ss)
        IF ValType(aMatch) == "A"
           ss := aMatch[2]+wws+aMatch[4]
        ELSE
           IF !MsgYesNo("Can't find '... DEFINE "+ct+" "+ck+" ... WIDHTS ...'"+cr+"Continue ?")
              RETURN nil
           ENDIF
        ENDIF
     ENDIF
  ENDIF   //ct == "TAB"
NEXT

nF2 := FCreate(cFile2,0)
IF nF2 == -1
   MsgStop("Can't create file "+cFile2,"Error")
   RETURN nil
ENDIF
FWrite(nF2,ss)
FClose(nF2)

RETURN nil
#endif
//---------------------------------------------------------------------------

#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"

// Like C_PUTFILE(aType,cTitle,cDefDir,lChaneDir,!NEW!cDefaultFileName)
HB_FUNC ( C_PUTFILE2 )
{

 OPENFILENAME ofn;
 char buffer[512];

 int flags = OFN_FILEMUSTEXIST | OFN_EXPLORER ;

 if ( hb_parl(4) )
 {
  flags = flags | OFN_NOCHANGEDIR ;
 }

 strcpy( buffer, hb_parc(5) );   //here is change "cDefaultFileName"

 memset( (void*) &ofn, 0, sizeof( OPENFILENAME ) );
 ofn.lStructSize = sizeof(ofn);
 ofn.hwndOwner = GetActiveWindow() ;
 ofn.lpstrFilter = hb_parc(1) ;
 ofn.lpstrFile = buffer;
 ofn.nMaxFile = 512;
 ofn.lpstrInitialDir = hb_parc(3);
 ofn.lpstrTitle = hb_parc(2) ;
 ofn.Flags = flags;

 if( GetSaveFileName( &ofn ) )
 {
  hb_retc( ofn.lpstrFile );
 }
 else
 {
  hb_retc( "" );
 }

}

#pragma ENDDUMP