/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

#define IDD_DLG1 1000
#define IDC_EDT1 1001
#define IDC_EDT2 1002
#define IDC_EDT3 1003
#define IDC_EDT4 1004

#define msginfo( c ) MsgInfo( c, , , .f. )

Function Main

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 340 HEIGHT 280 ;
      TITLE 'Harbour MiniGUI Demo' ;
      MAIN

      @ 10,10 TEXTBOX Text_1 ;
         WIDTH 200;
         VALUE "123AB" ;
         FONT 'Arial' SIZE 10 ;
         TOOLTIP 'Standard TextBox' ;

      DEFINE BTNTEXTBOX Text_2
         ROW 40
         COL 10 
         WIDTH 200
         VALUE ''
         ACTION f_Btn(1)
         DEFAULT .T.
         ACTION2 f_Btn(3)
         FONTNAME 'Arial'
         FONTSIZE 10
         TOOLTIP {'Character TextBox Tooltip','Button 1 Tooltip','Button 2 Tooltip'}
         KEEPFOCUS .F.
      END BTNTEXTBOX

      @ 70,10 BTNTEXTBOX Text_3 ;
         WIDTH 200 ;
         VALUE 150 ;
         ACTION f_Btn(2);
         ON ENTER f_Btn(2);
         NUMERIC;
         RIGHTALIGN;
         MAXLENGTH 3;
         FONT 'Arial' SIZE 10 ;
         TOOLTIP {'Numeric TextBox Tooltip','Button Tooltip'}

      @ 110, 10 BTNTEXTBOX Text_4;
         WIDTH 200;
         VALUE '' ;
         ACTION Get_Fold_Click('Program Folder');
         DEFAULT;
         ACTION2 msginfo("Button Info pressed");
         PICTURE {"folder.bmp","info.bmp"};
         BUTTONWIDTH 24;
         FONT 'Arial' SIZE 10;
         DISABLEEDIT;
         TOOLTIP {'Button TextBox','Button 1 Tooltip','Button 2 Tooltip'}

      @ 140,10 BUTTON Btn_1;
         CAPTION "Dialog Test";
         ACTION fDialog();
         WIDTH 200

   END WINDOW

   Form_1.Center

   Form_1.Activate

Return Nil

FUNCTION f_btn(typ)
   DO CASE
      CASE typ == 1
         form_1.text_2.value := "Edit button pressed"
         Form_1.Text_2.DisableEdit := .t.
         msginfo(form_1.text_2.value+'!')
         Form_1.Text_3.Setfocus
      CASE typ == 2
         form_1.text_3.value := 545
         msginfo("Button insert value: "+Str(form_1.text_3.value,3))
         form_1.text_3.setfocus
      CASE typ == 3
         form_1.text_2.value := "Edit button2 pressed"
         if Form_1.Text_2.DisableEdit == .t.
            Form_1.Text_2.DisableEdit := .f.
         endif
         msginfo(form_1.text_2.value+'!')
         Form_1.Text_3.Setfocus
      CASE typ == 4
         form_1.text_3.value := 7777
         msginfo("Button2 insert value: "+Str(form_1.text_3.value,5))
      ENDCASE
RETURN Nil

Function Get_Fold_Click(NameWorkKat)
    LOCAL cDsk
    cDsk := GetFolder(NameWorkKat)
    if !empty(cDsk)
       form_1.text_4.value := cDsk
    endif
RETURN Nil

FUNCTION fDialog()

   DEFINE DIALOG f_dialog ;
      OF Form_1;
      RESOURCE IDD_DLG1 ;

      REDEFINE  TEXTBOX Text_1 ID IDC_EDT1 ;
         VALUE "123AB" ;
         FONT 'Arial' SIZE 10 ;
         TOOLTIP 'Standard TextBox' ;

      REDEFINE BTNTEXTBOX Text_2 ID IDC_EDT2 ;
         VALUE '' ;
         ACTION {|| f_BtnDlg(1)};
         FONT 'Arial' SIZE 10 ;
         TOOLTIP 'Button Character TextBox'

      REDEFINE  BTNTEXTBOX Text_3 ID IDC_EDT3;
         VALUE 150 ;
         ACTION f_BtnDlg(2);
         ACTION2 f_BtnDlg(4);
         NUMERIC;
         FONT 'Arial' SIZE 10 ;
         TOOLTIP 'Button Numeric TextBox'

     REDEFINE  BTNTEXTBOX Text_4 ID IDC_EDT4 ;
         VALUE '' ;
         ACTION Get_Fold_dlg('Progrmm Folder ');
         ACTION2 msginfo("Button Info pressed ");
         PICTURE {"folder.bmp","info.bmp"};
         BUTTONWIDTH 20;
         FONT 'Arial' SIZE 10 BOLD;
         TOOLTIP {'Button TextBox','Button 1 Tooltip','Button 2 Tooltip'}

     END DIALOG
RETURN Nil

FUNCTION f_BtnDlg(typ)
   DO CASE
      CASE typ ==1
         f_dialog.text_2.value := "Edit button pressed"
         msginfo(f_dialog.text_2.value+'!!!')
      CASE typ == 2
        f_dialog.text_3.value := 545
         msginfo("Button insert value: "+Str(f_dialog.text_3.value,3))
      CASE typ ==3
         f_dialog.text_2.value := "Edit button2 pressed"
         msginfo(f_dialog.text_2.value+'!!!')
      CASE typ == 4
         f_dialog.text_3.value := 7777
         msginfo("Button2 insert value: "+Str(f_dialog.text_3.value,5))
      ENDCASE
RETURN Nil

Function Get_Fold_Dlg(NameWorkKat)
    LOCAL cDsk
    cDsk := GetFolder(NameWorkKat)
    if !empty(cDsk)
       f_dialog.text_4.value := cDsk
    endif
RETURN Nil
