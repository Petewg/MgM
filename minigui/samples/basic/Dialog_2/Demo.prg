/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * (C)2008 Janusz Pora <januszpora@onet.eu>
*/



#include "minigui.ch"



#define IDD_DLG1 1000
#define IDC_STC1 1001
#define IDC_STC  1002
#define IDC_STC3 1004
#define IDC_EDT1 1005
#define IDC_BTN1 1006
#define IDC_BTN2  1007
#define IDC_BTN3  1008
/*
#define IDOK                1
#define IDCANCEL            2
#define IDIGNORE            5
*/


Function main()
    LOCAL nAge := 35

    DEFINE WINDOW MainForm ;
       AT 0,0 ;
       WIDTH 460 ;
       HEIGHT 200 ;
       TITLE 'Demo for Dialogs with Event Procedure  -  By Janusz Pora' ;
        ICON 'Dialog.ico' ;
       MAIN

       ON KEY ALT+X ACTION THISWINDOW.RELEASE

        @ 10, 10 FRAME Frame_1;
            CAPTION 'Test Modalless Dialog' ;
            WIDTH 300 ;
            HEIGHT 55


        @ 35,20    LABEL Lbl_1 ;
            VALUE 'Dialogs Demo - Value:' AUTOSIZE ;
            FONT 'Arial' SIZE 10 ;
            BOLD  FONTCOLOR RED


        @ 32,200    LABEL Lbl_2 ;
            VALUE str(nAge,2) AUTOSIZE ;
            FONT 'Arial' SIZE 15 ;
            BOLD  FONTCOLOR BLUE

        @ 70, 10 FRAME Frame_2;
            CAPTION 'Dialog from memory' ;
            WIDTH 140 ;
            HEIGHT 60

        @ 90, 40 BUTTON Btn1 ID 105 CAPTION "&Test1"  WIDTH 60 HEIGHT 24 ;
            ACTION ( fExternal( MainForm.Lbl_2.Value ) ) ;
            DEFAULT

        @ 70, 160 FRAME Frame_3;
            CAPTION 'Dialog from RC' ;
            WIDTH 140 ;
            HEIGHT 60

        @ 90, 190 BUTTON Btn2  CAPTION "&Test2"  WIDTH 60 HEIGHT 24 ;
            ACTION ( fExternal1( MainForm.Lbl_2.Value ) ) ;


    END WINDOW

    CENTER WINDOW MainForm
    ACTIVATE WINDOW MainForm
Return Nil

Function fExternal( cAge )

   Local  oFont

   DEFINE FONT Font_1 FONTNAME "Arial" SIZE 10

   DEFINE DIALOG Dlg_1 OF MainForm  AT 30, 100 WIDTH 270 HEIGHT 150 FONT "Font_1" ;
         CAPTION "Modalless Data Edition "

      @ 10, 10 LABEL Lb2 VALUE "Old Value:" WIDTH 100 ID 101

      @ 10, 120 LABEL Lb2a VALUE cAge HEIGHT 24 WIDTH 50 ID 102

      @ 40, 10 LABEL Lb3 VALUE "New Value:" WIDTH 100 ID 103

      @ 40, 120 TEXTBOX tbox_2 VALUE Val(cAge) HEIGHT 24 WIDTH 40 ID 104 NUMERIC MAXLENGTH 2 ;
         ON CHANGE TextBoxChange()

      @ 80, 10 BUTTON Btn1 ID 105 CAPTION "&Accept"  WIDTH 70 HEIGHT 24 ;
         ACTION {|| MainForm.Lbl_2.Value:= str(Dlg_1.tbox_2.Value,2), _ReleaseDialog ( )} ;
         DEFAULT

      @ 80, 90 BUTTON Btn2 ID 106 CAPTION "&Cancel" WIDTH 70 HEIGHT 24 ;
         ACTION {||  Dlg_1.tbox_2.Value := "",_ReleaseDialog ( ) }

      @ 80, 170 BUTTON Btn3 ID 107 CAPTION "&Exit" WIDTH 70 HEIGHT 24 ;
         ACTION {|| _ReleaseDialog ( ) }

    END DIALOG

    Dlg_1.Btn1.Enabled := .f.
    Dlg_1.Btn2.Enabled := .f.

    RELEASE FONT Font_1

Return nil

FUNCTION TextBoxChange()
   LOCAL cValue
   cValue := Dlg_1.tbox_2.Value
   if !empty(cValue)
      Dlg_1.Btn1.Enabled := .t.
      Dlg_1.Btn2.Enabled := .t.
   else
      Dlg_1.Btn1.Enabled := .f.
      Dlg_1.Btn2.Enabled := .f.
   endif
RETURN Nil


Function fExternal1( cAge )
   Local oFont

   DEFINE FONT Font_1 FONTNAME "Arial" SIZE 10

   DEFINE DIALOG Dlg_2 OF MainForm  RESOURCE IDD_DLG1 FONT "Font_1" ;
         CAPTION "Modalless Data Edition "

      REDEFINE LABEL Lb2a ID IDC_STC3 VALUE cAge

      REDEFINE TEXTBOX tbox_2 ID IDC_EDT1 VALUE Val(cAge)  NUMERIC MAXLENGTH 2 ;
         ON CHANGE TextBoxChange1()

      REDEFINE  BUTTON Btn1 ID IDC_BTN1 CAPTION "&Accept"   ;
         ACTION {|| MainForm.Lbl_2.Value:= Str(Dlg_2.tbox_2.Value), _ReleaseDialog ( )} ;
            DEFAULT

      REDEFINE  BUTTON Btn2 ID IDC_BTN2 CAPTION "&Cancel"  ;
         ACTION {|| Dlg_2.tbox_2.Value := "",_ReleaseDialog ( ) }

      REDEFINE  BUTTON Btn3 ID IDC_BTN3 CAPTION "&Exit"  ;
         ACTION {|| _ReleaseDialog ( ) }

   END DIALOG

   Dlg_2.Btn1.Enabled := .f.
   Dlg_2.Btn2.Enabled := .f.

   RELEASE FONT Font_1

Return Nil

FUNCTION TextBoxChange1()
   LOCAL cValue
   IF IsControlDefined (Btn1,Dlg_2)
      cValue := Dlg_2.tbox_2.Value
      if !empty(cValue)
         Dlg_2.Btn1.Enabled := .t.
         Dlg_2.Btn2.Enabled := .t.
      else
         Dlg_2.Btn1.Enabled := .f.
         Dlg_2.Btn2.Enabled := .f.
      ENDIF
    endif
RETURN Nil

