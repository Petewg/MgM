/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Folder Demo
 * (c) 2009 Janusz Pora <januszpora@onet.eu>
*/

#include "minigui.ch"
#include "DemoRes.h"

#define IDOK                1
#define IDCANCEL            2
#define IDIGNORE            5


#DEFINE FLD_AFH         1           // _HMG_ActiveFolderHandle
#DEFINE FLD_MOD         2           // _HMG_ActiveFolderModal
#DEFINE FLD_INM         3           // _HMG_FolderInMemory
#DEFINE FLD_PGT         4           // _HMG_aFolderPagesTemp
#DEFINE FLD_FLT         5           // _HMG_aFolderTemplate
#DEFINE FLD_FPG         6           // _HMG_aFolderPages
#DEFINE FLD_FIT         7           // _HMG_aFolderItems
#DEFINE FLD_HFP         8           //  aHwndFolderPages

*-------------------------------------------------------------
Function main()
*-------------------------------------------------------------

//SET LANGUAGE TO POLISH

DEFINE WINDOW MainForm ;
       AT 0,0 ;
       WIDTH 450 ;
       HEIGHT 200 ;
       TITLE 'Demo of Folders   -   By Janusz Pora' ;
       ICON 'Star.ico' ;
       MAIN

       ON KEY ALT+X ACTION ThisWindow.Release

       DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM '&Exit'         ACTION MainForm.Release
         END POPUP
         DEFINE POPUP 'In Memory'
            DEFINE POPUP 'Modeless Folder'
               MENUITEM 'Folder without Buttons'                  ACTION FolderInMemory(0,.f.)
               MENUITEM 'Folder with OK Button'                   ACTION FolderInMemory(1,.f.)
               MENUITEM 'Folder with OK, Cancel Buttons'          ACTION FolderInMemory(2,.f.)
               MENUITEM 'Folder with OK, Apply, Cancel Buttons'   ACTION FolderInMemory(3,.f.)
            END POPUP
            DEFINE POPUP 'Modal Folder'
               MENUITEM 'Folder without Buttons'                  ACTION FolderInMemory(0,.t.)
               MENUITEM 'Folder with OK Button'                   ACTION FolderInMemory(1,.t.)
               MENUITEM 'Folder with OK, Cancel Buttons'          ACTION FolderInMemory(2,.t.)
               MENUITEM 'Folder with OK, Apply, Cancel Buttons'   ACTION FolderInMemory(3,.t.)
            END POPUP
         END POPUP
         DEFINE POPUP 'From RC'
            DEFINE POPUP 'Modeless Folder'
               MENUITEM 'Folder without Buttons'                  ACTION FolderRC(0,.f.)
               MENUITEM 'Folder with OK Button'                   ACTION FolderRC(1,.f.)
               MENUITEM 'Folder with OK, Cancel Buttons'          ACTION FolderRC(2,.f.)
               MENUITEM 'Folder with OK, Apply, Cancel Buttons'   ACTION FolderRC(3,.f.)
            END POPUP
            DEFINE POPUP 'Modal Folder'
               MENUITEM 'Folder without Buttons'                  ACTION FolderRC(0,.t.)
               MENUITEM 'Folder with OK Button'                   ACTION FolderRC(1,.t.)
               MENUITEM 'Folder with OK, Cancel Buttons'          ACTION FolderRC(2,.t.)
               MENUITEM 'Folder with OK, Apply, Cancel Buttons'   ACTION FolderRC(3,.t.)
            END POPUP
         END POPUP
         DEFINE POPUP 'Info'
            MENUITEM '&About..'         ACTION About()
         END POPUP
      END MENU

      @ 30,70 LABEL Lbl_1 ;
          VALUE 'Demo of Folders' AUTOSIZE ;
          FONT 'Arial' SIZE 24 ;
          BOLD ITALIC FONTCOLOR RED

    END WINDOW

    CENTER WINDOW MainForm
    ACTIVATE WINDOW MainForm
Return  Nil

Function FolderInMemory(nMet,lMod)
LOCAL cFld, cPg1, cPg2, cPg3
   cPg1:= "Page1"+Str(nMet,1)
   cPg2:= "Page2"+Str(nMet,1)
   cPg3:= "Page3"+Str(nMet,1)

   DEFINE FONT Font_1 FONTNAME "Arial" SIZE 10

   IF lMod
      cFld:= "Fld_1"+Str(nMet,1)
   ELSE
      cFld:= "Fld_2"+Str(nMet,1)
   endif
   IF !IsWIndowDefined ( &cFld)
      IF lMod
         DO CASE
         CASE nMet == 0
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory (MODAL)" MODAL;
               ON INIT SetInitfolder()
         CASE nMet == 1
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory (MODAL)" MODAL;
               ON FOLDERPROC   {||  ApplyFolderClick() };
               ON INIT SetInitfolder()
         CASE nMet == 2
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory (MODAL)" MODAL;
               ON FOLDERPROC   {||  ApplyFolderClick() } ;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON INIT SetInitfolder()
         CASE nMet == 3
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory (MODAL)" MODAL;
               ON FOLDERPROC   {||  ApplyFolderClick() } APPLYBTN;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON INIT SetInitfolder()
         endcase
      ELSE
         DO CASE
         CASE nMet == 0
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory" ;
               ON INIT SetInitfolder() BOTTOM
         CASE nMet == 1
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory " ;
               ON FOLDERPROC   {|| ApplyFolderClick() };
               ON INIT SetInitfolder()  BUTTONS
         CASE nMet == 2
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory " ;
               ON FOLDERPROC   {|| ApplyFolderClick() } ;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON INIT SetInitfolder()  BUTTONS FLAT
         CASE nMet == 3
            DEFINE FOLDER &cFld OF MainForm  ;
               AT 10,10 ;
               WIDTH 600  ;
               HEIGHT 350 ;
               FONT "Font_1" ;
               CAPTION "Folder InMemory " ;
               ON FOLDERPROC   {||  ApplyFolderClick() } APPLYBTN;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON INIT SetInitfolder()  BUTTONS VERTICAL BOTTOM
         endcase
      ENDIF


            DEFINE FOLDERPAGE &cPg1 RESOURCE DLG_FIRST   TITLE "Control 1" IMAGE "Check.bmp"

              @ 10,20 LABEL Lbl_1 ID 402 ;
                  VALUE 'New Label - Bold' BOLD ;
                  WIDTH 170   ;
                   HEIGHT 24  ;
                   TOOLTIP 'Tooltip for Label'

               @ 40,20  EDITBOX EdBox_1a ID 302 ;
                  WIDTH 200   ;
                   HEIGHT 70 ;
                   VALUE ' Sample Edit Text'   ;
                   TOOLTIP 'Defined EditBox in Memory'

               @ 120,20 COMBOBOX cBox_1a ID 308 ;
                 ITEMS {'Item 1','Item 2','Item 3'} ;
                 VALUE 1 ;
                  WIDTH 200   ;
                   HEIGHT 70 ;
                  TOOLTIP 'Defined ComboBox in Memory'


              @ 20,240 FRAME frame_1a ID 306;
                  CAPTION 'Frame ';
                  WIDTH 200   ;
                   HEIGHT 100

               @ 35,250  CHECKBOX chkbox_1A ID 303;
                 CAPTION 'Active CheckBox';
                  WIDTH 160   ;
                   HEIGHT 24  ;
                   TOOLTIP 'Defined CheckBox in Memory'

               @ 65,250 RADIOGROUP RadioGrp_1a ID  {304,305} ;
                    OPTIONS {'Radio 1','Radio 2' } ;
                VALUE 1   ;
                  WIDTH 140   ;
                   SPACING 25 ;
                 FONT 'System' ;
                SIZE 12   ;
                   TOOLTIP 'Defined RadioGroup'

               @ 140,240   LISTBOX lBox_1a ID 307;
                  WIDTH 200   ;
                   HEIGHT 100 ;
                  ITEMS {'Line 1','Line 2','Line 3'} ;
                  VALUE 2 ;
                  TOOLTIP 'Defined ListBox in Memory'

               @ 200,20 TEXTBOX TextBox_1 ID 323 ;
                   HEIGHT 24  ;
                   VALUE 'TextBox Value'  ;
                   WIDTH 200  ;
                   TOOLTIP 'TextBox Created In Memory'

               @ 250,20 IMAGE image_1a ID 310 ;
                   PICTURE 'DEMO.bmp' ;
                  WIDTH 50   ;
                   HEIGHT 50

               @ 250,120 BUTTON Btn_1x ID 391 ;
                   CAPTION 'Set Text'  ;
                   ACTION setEdText(cPg1, lMod, 323);
                   WIDTH 70   ;
                   HEIGHT 24  ;
                   TOOLTIP 'Set new value'

            END FOLDERPAGE

            DEFINE FOLDERPAGE &cPg2 RESOURCE DLG_SECOND   TITLE "Control 2"  // IMAGE "Check.bmp"

               @ 30 ,20  DATEPICKER DatePicker_1  ID 324 ;
                   VALUE date();
                   WIDTH 150;
                   TOOLTIP 'Defined DatePicker'


               @ 130,40 BUTTON Btn_2a ID 318;
                 PICTURE "PLAY.BMP" ;
                 ACTION {|| _PlayAnimateBox ( 'Ani_1a' , cPg2 )};
                  WIDTH 30   ;
                   HEIGHT 30 ;
                 TOOLTIP 'Defined Imagebutton'

             @ 130, 70 CHECKBUTTON CheckBtn_1a ID 319;
                 PICTURE 'info.bmp'  ;
                  WIDTH 30   ;
                   HEIGHT 30 ;
                 VALUE .F. ;
                 TOOLTIP 'Graphical CheckButton'

           @ 170,20 ANIMATEBOX Ani_1a ID 317 ;
                  WIDTH 240   ;
                   HEIGHT 50 ;
                FILE 'Sample.Avi'


               @ 250,20 SLIDER sld_1a ID 311 ;
                  RANGE 1,10 ;
                  VALUE 20 ;
                  WIDTH 300   ;
                   HEIGHT 30 ;
                  TOOLTIP 'Defined Slider in Memory'


               @ 290,20 PROGRESSBAR progrBar_1a ID 312 ;
                  RANGE 1 , 200      ;
                  VALUE 50      ;
                  WIDTH 300   ;
                   HEIGHT 30 ;
                  TOOLTIP 'Defined ProgressBar in Memory'


               @ 30 ,230 MONTHCALENDAR MonthCal_1 ID 125;
                   VALUE date();
                   TOOLTIP 'Defined MonthCalendar in Memory'

               DEFINE TREE tree_1a ID 315 ;
                   AT 30,430 ;
                  WIDTH 150   ;
                   HEIGHT 230 ;
                  VALUE 1 ;
                  TOOLTIP 'Defined Tree in Memory'

                NODE 'Item 1'
                   TREEITEM 'Item 1.1'
                   TREEITEM 'Item 1.2' ID 999
                   TREEITEM 'Item 1.3'
                END NODE

                NODE 'Item 2'

                   TREEITEM 'Item 2.1'

                   NODE 'Item 2.2'
                      TREEITEM 'Item 2.2.1'
                      TREEITEM 'Item 2.2.2'
                      TREEITEM 'Item 2.2.3'
                   END NODE

                   TREEITEM 'Item 2.3'

                END NODE

                NODE 'Item 3'
                   TREEITEM 'Item 3.1'
                   TREEITEM 'Item 3.2'

                   NODE 'Item 3.3'
                      TREEITEM 'Item 3.3.1'
                      TREEITEM 'Item 3.3.2'
                   END NODE

                END NODE

             END TREE

            END FOLDERPAGE

            DEFINE FOLDERPAGE &cPg3 RESOURCE DLG_THIRD   TITLE "Control 3"  IMAGE "Exit.bmp"

             DEFINE TAB Tab_1a ID 316 ;
                   AT 30,30 ;
                  WIDTH 300   ;
                   HEIGHT 120 ;
                VALUE 1 ;
                TOOLTIP 'Redefined Tab Control'

                DEFINE PAGE 'Page 1' IMAGE 'Exit.Bmp'

                       @ 50,20 LABEL Lbl_2a ID 321 ;
                          VALUE 'Label on Page 1' ;
                          WIDTH 170   ;
                          HEIGHT 24  ;
                          TOOLTIP 'Redefined Label on Page 1' TRANSPARENT

                END PAGE

                DEFINE PAGE 'Page &2' IMAGE 'Info.Bmp'

                       @ 50,120 LABEL Lbl_3a ID 322 ;
                          VALUE 'Label on Page 2' ;
                          WIDTH 170   ;
                          HEIGHT 24  ;
                          TOOLTIP 'Redefined Label on Page 2' TRANSPARENT

                END PAGE

                DEFINE PAGE 'Page 3' IMAGE 'Check.Bmp'

                END PAGE

             END TAB

               @ 200,30 GRID Grid_1a ID 314 ;
                  WIDTH 400   ;
                  HEIGHT 130 ;
                  HEADERS {'Key','Name','Data'}   ;
                  WIDTHS {60,200,100}      ;
                  ITEMS {{'10','Adrian','256'}} ;
                  TOOLTIP 'Defined Grid in Memory'

            END FOLDERPAGE

         END FOLDER

    endif
    RELEASE FONT Font_1

Return Nil

Function setEdText(cPage, lMod, nId)
   IF lMod
      SetDialogItemText( GetFormHandle (cPage), nId,"New Text from Modal" )
   else
      SetProperty (cPage,"TextBox_1","value","New Text" )
   endif
Return Nil

FUNCTION ApplyFolderClick()
   LOCAL hwndFolder := GetFolderHandle(DLG_HWND)
   LOCAL PageName:= GetFolderWindowName(DLG_HWND )
   LOCAL FolderName:= GetFolderWindowName(hwndFolder )
  //
  MsgInfo("Apply or OK button Click for:"+CRLF+FolderName + CRLF + PageName+ CRLF +"Nr ID: "+Str(DLG_ID))
RETURN Nil

Function FolderFun()
Local   ret := 0, cValue
    if DLG_ID != Nil
        do case
        case DLG_ID == IDOK .and. DLG_NOT ==0
            _ReleaseWindow ( 'Dlg_1')
        case DLG_ID == IDCANCEL .and. DLG_NOT ==0
            _ReleaseWindow ( 'Dlg_1')
        case DLG_ID == 104 .and. DLG_NOT ==1024
            cValue := GetEditText (DLG_HWND, 104 )
            if !empty(cValue)
                EnableDialogItem (DLG_HWND, 105)
            else
                DisableDialogItem (DLG_HWND, 105)
            endif
        case DLG_ID == 105 .and. DLG_NOT ==0
            ret := GetEditText (DLG_HWND, 104 )
            _ReleaseDialog ( )
        case DLG_ID == 106 .and. DLG_NOT ==0
             SetDialogItemText(DLG_HWND, 104,"  " )
             DisableDialogItem (DLG_HWND, 105)
        case DLG_ID == 107 .and. DLG_NOT ==0
            _ReleaseDialog ( )
        endcase
    endif
Return ret

Function SetInitfolder()
 //  LOCAL hwndFolder := GetFolderHandle(DLG_HWND)
 //  LOCAL FolderName:= GetFolderWindowName(DLG_HWND )
 //   InitDialogFolder - Initialized the Folder
Return Nil

Function FolderRC(nMet,lMod)
LOCAL cFld, cPg1, cPg2, cPg3

   cPg1:= "Page1"+Str(nMet,1)
   cPg2:= "Page2"+Str(nMet,1)
   cPg3:= "Page3"+Str(nMet,1)
   DEFINE FONT Font_1 FONTNAME "Arial" SIZE 10
   IF lMod
      cFld:= "Fld_3"+Str(nMet,1)
   ELSE
      cFld:= "Fld_4"+Str(nMet,1)
   endif
   IF !IsWIndowDefined ( &cFld)
      IF lMod
         DO CASE
         CASE nMet == 0
            DEFINE FOLDER &cFld OF MainForm  RESOURCE ;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data  (MODAL)" MODAL;
               ON INIT SetInitfolder() BOTTOM
         CASE nMet == 1
            DEFINE FOLDER &cFld OF MainForm  RESOURCE;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data  (MODAL)" MODAL;
               ON FOLDERPROC   {|| FolderFun() };
               ON INIT SetInitfolder()   BUTTONS
         CASE nMet == 2
            DEFINE FOLDER &cFld OF MainForm RESOURCE ;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data  (MODAL)" MODAL;
               ON FOLDERPROC   {|| FolderFun() } ;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON INIT SetInitfolder()     BUTTONS FLAT
         CASE nMet == 3
            DEFINE FOLDER &cFld OF MainForm RESOURCE ;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data  (MODAL)" MODAL;
               ON FOLDERPROC   {|| FolderFun() } APPLYBTN;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON INIT SetInitfolder()
         endcase
      ELSE
         DO CASE
         CASE nMet == 0
            DEFINE FOLDER &cFld OF MainForm RESOURCE ;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data" ;
               ON INIT SetInitfolder()
         CASE nMet == 1
            DEFINE FOLDER &cFld OF MainForm RESOURCE ;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data" ;
               ON FOLDERPROC   {|| FolderFun() };
               ON INIT SetInitfolder()
         CASE nMet == 2
            DEFINE FOLDER &cFld OF MainForm RESOURCE ;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data" ;
               ON FOLDERPROC   {|| FolderFun() } ;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON INIT SetInitfolder()
         CASE nMet == 3
            DEFINE FOLDER &cFld OF MainForm RESOURCE ;
               FONT "Font_1" ;
               CAPTION "Folder from RC Data" ;
               ON FOLDERPROC   {|| FolderFun() } APPLYBTN;
               ON CANCEL  {|| MsgInfo("Cancel Button") };
               ON HELP  {|| MsgInfo("Help Button") };
               ON INIT SetInitfolder()
         endcase
      ENDIF

         FOLDERPAGE &cPg1 RESOURCE DLG_FIRST  TITLE "PEOPLE"    IMAGE "Check.bmp"

         FOLDERPAGE &cPg2 RESOURCE DLG_SECOND TITLE "ANIMALS"   IMAGE "Check.bmp"

         FOLDERPAGE &cPg3 RESOURCE DLG_THIRD  TITLE "BUILDINGS" IMAGE "Exit.bmp"

      END FOLDER
   endif
   RELEASE FONT Font_1

Return Nil

Function FolderFun1(lOk, nNewAge)
Local   ret := 0, cValue
    if DLG_ID != Nil
        do case
        case DLG_ID == IDC_EDT1 .and. DLG_NOT ==1024
            cValue := GetEditText (DLG_HWND, IDC_EDT1 )
            if !empty(cValue)
                EnableDialogItem (DLG_HWND, IDC_BTN1)
            else
                DisableDialogItem (DLG_HWND, IDC_BTN1)
            endif
        case DLG_ID == IDC_BTN1 .and. DLG_NOT ==0
            ret := GetEditText (DLG_HWND, IDC_EDT1 )
            nNewAge := ret
            lOk := .t.
            _ReleaseDialog ( )
        case DLG_ID == IDC_BTN2 .and. DLG_NOT ==0
             SetDialogItemText(DLG_HWND, IDC_EDT1,"  " )
             DisableDialogItem (DLG_HWND, IDC_BTN1)
        case DLG_ID == IDC_BTN3 .and. DLG_NOT ==0
            _ReleaseDialog ( )
        endcase
    endif
Return ret


*-----------------------------------------------------------------------------*
Function  About()
*-----------------------------------------------------------------------------*
   IF !IsWIndowDefined ( Form_About )
      DEFINE WINDOW Form_About ;
         AT 0,0 ;
         WIDTH 250 HEIGHT 110 ;
         TITLE '';
         CHILD NOCAPTION

      @ 5 ,5 FRAME Frame_1;
          WIDTH 235  HEIGHT 90

      @ 15 ,15 IMAGE Icon_1;
          PICTURE "Star.ico" ;
          WIDTH 32 HEIGHT 32

      @ 10,70 LABEL Label_1 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE 'Demo of Folders'  ;
         FONT 'Arial' SIZE 11 BOLD //CENTERALIGN

      @ 35,70 LABEL Label_2 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE '(c) 2009 Janusz Pora' ;
         FONT 'Arial' SIZE 9 FONTCOLOR BLUE //CENTERALIGN

      @ 60,70 LABEL Label_3 ;
         WIDTH 180 HEIGHT 20 ;
         VALUE 'HMG Harbour MiniGui' ;
         FONT 'Arial' SIZE 9 //CENTERALIGN

      @ 65,15  BUTTON Btn_splash ;
         CAPTION 'OK' ;
         ACTION   Form_About.Release ;
         WIDTH 40 HEIGHT 20 ;
         FONT 'Arial' SIZE 9 Bold DEFAULT

      END WINDOW
      Form_About.Center
      ACTIVATE WINDOW Form_About
   endif
Return Nil


*-----------------------------------------------------------------------------*
Function GetFolderWindowName( hWnd )
*-----------------------------------------------------------------------------*
   Local i := Ascan ( _HMG_aFormHandles, hWnd )
Return IF( i > 0, _HMG_aFormNames[i], "" )
