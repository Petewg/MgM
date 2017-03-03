/*
 * MiniGUI GetBox Color Demo
*/

#include "minigui.ch"

FUNCTION Main

LOCAL i, get_name, txt_name, m_col

LOCAL c_lbl_color := {0, 255, 255}

SET GETBOX FOCUS BACKCOLOR   TO YELLOW

DEFINE WINDOW Form_1 ;
   AT 0,0 WIDTH 400 HEIGHT 400 ;
   TITLE 'Press UP or DOWN or ENTER' ;
   MAIN ;
   BACKCOLOR {0, 255, 255}

   ON KEY ESCAPE ACTION ThisWindow.Release

   FOR i=1 TO 10
      get_name := 'GETBOX_' + hb_ntos(i)
      txt_name := 'LABEL_' + hb_ntos(i)

      @ i*30 , 30 LABEL &txt_name value txt_name ;
			width 95 height 23 backcolor c_lbl_color ;
                        VCENTERALIGN

      m_col := form_1.&(txt_name).col + form_1.&(txt_name).width + 20

      @ i*30 , m_col GETBOX &get_name value get_name width 200 ;
			ON LOSTFOCUS OnGetMove(1) ;
			ON GOTFOCUS OnGetMove()
   NEXT

END WINDOW

Form_1.Center
Form_1.Activate

RETURN Nil

*............................................................................*

STATIC FUNCTION OnGetMove(...)

LOCAL var_text  := this.name
LOCAL var_label := 'LABEL_' + substr(var_text, 8)

IF PCount() # 0

   this.&(var_label).fontbold := .F.
   this.&(var_label).fontsize := 9

ELSE

   this.&(var_label).fontbold := .T.
   this.&(var_label).fontsize := 12

ENDIF

RETURN NIL
