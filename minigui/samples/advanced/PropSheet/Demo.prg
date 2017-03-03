ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_propsheet.ch"
#include "DemoRes.h"


#define IDOK                1
#define IDCANCEL            2
#define IDIGNORE            5

#define DLL_NATIVE  0x0000
#define DLL_BUILTIN 0x0001


MEMVAR _HMG_ActivePropSheetHandle, _HMG_ActivePropSheetModeless, _HMG_ActivePropSheetWizard
MEMVAR _HMG_InitPropSheetProcedure, _HMG_ApplyPropSheetProcedure, _HMG_CancelPropSheetProcedure
MEMVAR _HMG_ValidPropSheetProcedure, _HMG_PropSheetProcedure
MEMVAR _HMG_aPropSheetPagesTemp, _HMG_aPropSheetTemplate, _HMG_aPropSheetPages, _HMG_aPropSheetActivePages

MEMVAR aWinVersions, aDOSVersions, aWineLook, aWineDrivers, aDLLType
MEMVAR nWinVer, nDosVer, nWineLook, nSelOpt

*-------------------------------------------------------------
Function main()
*-------------------------------------------------------------
PUBLIC  _HMG_ActivePropSheetHandle     := 0
PUBLIC  _HMG_ActivePropSheetModeless   := .f.
PUBLIC  _HMG_ActivePropSheetWizard     := .f.
PUBLIC  _HMG_InitPropSheetProcedure    := ""
PUBLIC  _HMG_ApplyPropSheetProcedure   := ""
PUBLIC  _HMG_CancelPropSheetProcedure  := ""
PUBLIC  _HMG_ValidPropSheetProcedure   := ""
PUBLIC  _HMG_PropSheetProcedure        := ""
PUBLIC  _HMG_aPropSheetPagesTemp       := {}
PUBLIC  _HMG_aPropSheetTemplate        := {}
PUBLIC  _HMG_aPropSheetPages           := {}
PUBLIC  _HMG_aPropSheetActivePages     := {}


   PUBLIC aWinVersions := {{"win20", "Windows 2.0"},;
                         {"win30", "Windows 3.0"},;
                         {"win31", "Windows 3.1"},;
                         {"nt351", "Windows NT 3.5"},;
                         {"nt40",  "Windows NT 4.0"},;
                         {"win95", "Windows 95"},;
                         {"win98", "Windows 98"},;
                         {"winme", "Windows ME"},;
                         {"win2k", "Windows 2000"},;
                         {"winxp", "Windows XP"},;
                         {"", ""}}
   PUBLIC aDOSVersions := {{"6.22", "MS-DOS 6.22"},;
                         {"", ""}}
   PUBLIC aWineLook    := {{"win31", "Windows 3.1"},;
                         {"win95", "Windows 95"},;
                         {"win98", "Windows 98"},;
                         {"", ""}}
   PUBLIC aWineDrivers := {{"x11drv", "X11 Interface"},;
                         {"ttydrv", "TTY Interface"},;
                         {"", ""}}
   PUBLIC aDLLType     := {{"oleaut32", DLL_BUILTIN},;
                         {"ole32", DLL_BUILTIN},;
                         {"commdlg", DLL_BUILTIN},;
                         {"comdlg32", DLL_BUILTIN},;
                         {"shell", DLL_BUILTIN},;
                         {"shell32", DLL_BUILTIN},;
                         {"shfolder", DLL_BUILTIN},;
                         {"shlwapi", DLL_BUILTIN},;
                         {"shdocvw", DLL_BUILTIN},;
                         {"advapi32", DLL_BUILTIN},;
                         {"msvcrt", DLL_NATIVE},;
                         {"mciavi.drv", DLL_NATIVE},;
                         {"mcianim.drv", DLL_NATIVE},;
                         {"*", DLL_NATIVE},;
                         {"", -1}}
   PUBLIC nWinVer := 1 , nDosVer := 1, nWineLook := 1,nSelOpt := 0


   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 670 ;
      HEIGHT 500 ;
      TITLE 'Property Sheet Demo for MiniGui' ;
      ICON 'STAR.ICO' ;
      MAIN ;
      NOMAXIMIZE NOSIZE

      DEFINE MAIN MENU
         POPUP '&From Resource'
            MENUITEM "Modal Property Sheet"       ACTION ModalPropSheet()
            MENUITEM "Modeless Property Sheet"    ACTION ModelessPropSheet()
            SEPARATOR
            MENUITEM "Wizard"                     ACTION WizardPropSheet()
            MENUITEM "Wizard Lite"                ACTION WizardLitePropSheet()
            SEPARATOR
            ITEM 'Exit' ACTION thiswindow.release
         END POPUP
         POPUP '&InDirect'
            MENUITEM "Modal Property Sheet"       ACTION ModalPropSheetInDirect()
            MENUITEM "Modeless Property Sheet"    ACTION ModelessPropSheetInDirect()
            SEPARATOR
            MENUITEM "Modeless - without DialogProc"    ACTION ModelessPropSheetInDirectEnv()
            SEPARATOR
            MENUITEM "Wizard"                     ACTION WizardPropSheetInDirect()
         END POPUP
         POPUP '&Info'
            ITEM 'About' ACTION dlg_about()
         END POPUP

      END MENU


   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

*-------------------------------------------------------------
Procedure dlg_about()
*-------------------------------------------------------------

    DEFINE DIALOG f_dialog ;
       OF Form_1 ;
       RESOURCE IDD_ABOUT_DIALOG

    REDEFINE BUTTON Btn_1 ID 101 ;
       ACTION thiswindow.release

    REDEFINE IMAGE image_1 ID 200 ;
       PICTURE 'WINE.BMP' ;
       STRETCH

    END DIALOG

Return

*-------------------------------------------------------------
FUNCTION ModalPropSheet()
*-------------------------------------------------------------

   DEFINE PROPSHEET propSheet_1 OF Form_1 ;
      AT 150,150 ;
      WIDTH 300 ;
      HEIGHT 200 ;
      MODAL ;
      CAPTION "MODAL Property Sheet Demo - Wine Configuration" ;
      ICON "STAR.ICO" ;
      DIALOGPROC {|x,y,z,v| ModalPropSheetFun(x,y,z,v) } ;
      ON INIT { |hWndDlg, idDlg| InitModalFun(hWndDlg, idDlg) } ;
      ON CANCEL { |hWndDlg, idDlg| MsgInfo("Cancel for ID Page: "+Str(idDlg,4)), CancelModalFun( hWndDlg, IdDlg ) } ;
      ON APPLY  { |hWndDlg, idDlg, nPage| MsgInfo("OK for Page: "+Str(nPage,2)) }

         SHEETPAGE demo1 RESOURCE IDD_GENCFG TITLE "General"

         SHEETPAGE demo2 RESOURCE IDD_DLLCFG TITLE "Libraries"

         SHEETPAGE demo3 RESOURCE IDD_APPCFG TITLE "Applications"

         SHEETPAGE demo4 RESOURCE IDD_X11DRVCFG TITLE "X11 Driver"

   END PROPSHEET

RETURN Nil

*-------------------------------------------------------------
FUNCTION ModelessPropSheet()
*-------------------------------------------------------------

   DEFINE PROPSHEET propSheet_2 OF Form_1 ;
      AT 150,150 ;
      WIDTH 300 ;
      HEIGHT 200 ;
      CAPTION "MODAL Property Sheet Demo - Wine Configuration" ;
      ICON "STAR.ICO" ;
      DIALOGPROC {|x,y,z,v| ModalPropSheetFun(x,y,z,v) } ;
      ON INIT { |hWndDlg, idDlg| InitModalFun(hWndDlg, idDlg) } ;
      ON CANCEL { |hWndDlg, idDlg| MsgInfo("Cancel for ID Page: "+Str(idDlg,4)), CancelModalFun( hWndDlg, IdDlg ), FALSE } ;
      ON APPLY  { |hWndDlg, idDlg, nPage| MsgInfo("OK for Page: "+Str(nPage,2)) }

         SHEETPAGE demo21 RESOURCE IDD_GENCFG TITLE "General"

         SHEETPAGE demo22 RESOURCE IDD_DLLCFG TITLE "Libraries"

         SHEETPAGE demo23 RESOURCE IDD_APPCFG TITLE "Applications"

         SHEETPAGE demo24 RESOURCE IDD_X11DRVCFG TITLE "X11 Driver"

   END PROPSHEET

RETURN Nil

//====================================================================

#define CB_SETCURSEL                0x014E
#define CB_GETCURSEL                0x0147

FUNCTION InitModalFun(hWndDlg, idDlg)
   LOCAL hControl, i , aVer, DLLType
   DO CASE
   CASE idDlg == IDD_GENCFG
       REDEFINE IMAGE image_1 ID IDC_BMP ;
         PICTURE 'WINE.BMP' ;
         STRETCH

      IF (hControl := GetDialogItemHandle(hWndDlg,IDC_WINVER))> 0
         aVer := WinVersion()
         for i = 1 TO Len(aWinVersions)
            ComboAddString ( hControl, aWinVersions[i,2] )
            if AllTrim(aVer[1]) == aWinVersions[i,2]
               SendDlgItemMessage (hWndDlg, IDC_WINVER, CB_SETCURSEL, i-1, 0)
               nWinVer := i
            endif
         NEXT
     endif
     IF (hControl := GetDialogItemHandle(hWndDlg,IDC_DOSVER))> 0
         for i = 1 TO Len(aDOSVersions)
            ComboAddString ( hControl, aDOSVersions[i,2] )
            SendDlgItemMessage (hWndDlg, IDC_DOSVER, CB_SETCURSEL, 0, 0)
         NEXT
     endif
     IF (hControl := GetDialogItemHandle(hWndDlg,IDC_WINELOOK))> 0
         for i = 1 TO Len(aWineLook)
            ComboAddString ( hControl, aWineLook[i,2] )
            SendDlgItemMessage (hWndDlg, IDC_WINELOOK, CB_SETCURSEL, 0, 0)
         NEXT
      endif
   CASE idDlg == IDD_APPCFG
     IF (hControl := GetDialogItemHandle(hWndDlg,IDC_LIST_APPS))> 0
         for i = 1 TO Len(aWineDrivers)
            ListboxAddString(hControl, aWineDrivers[i,2])
         NEXT
      endif
   CASE idDlg == IDD_DLLCFG
      CheckRadioButton (hWndDlg, IDC_RAD_BUILTIN, IDC_RAD_NATIVE, IDC_RAD_BUILTIN)
      IF (hControl := GetDialogItemHandle(hWndDlg,IDC_LIST_DLLS))> 0
         for i = 1 TO Len(aDLLType)
            IF aDLLType[i,2] == DLL_BUILTIN
               ListboxAddString(hControl, aDLLType[i,1])
            endif
         NEXT
      endif
   CASE IdDlg == IDD_X11DRVCFG
      CheckDlgButton( IDC_XDGA, hWndDlg )
      DisableDialogItem (hWndDlg, IDC_DESKTOP_SIZE )
      DisableDialogItem (hWndDlg, IDC_DESKTOP_WIDTH)
      DisableDialogItem (hWndDlg, IDC_DESKTOP_BY )
      DisableDialogItem (hWndDlg, IDC_DESKTOP_HEIGHT)
   ENDCASE

RETURN nil

//====================================================================

Function ModalPropSheetFun( hWndDlg, nMsg , Id, Notify )
   LOCAL ret := FALSE, DLLType, hControl, i
   if Id != Nil
      do case
      case Id == IDC_WINVER
         ret := !(nWinVer -1 == SendDlgItemMessage (hWndDlg, IDC_WINVER, CB_GETCURSEL, 0, 0))
      case Id == IDC_DOSVER
         ret := !(nDosVer -1 == SendDlgItemMessage (hWndDlg, IDC_DOSVER, CB_GETCURSEL, 0, 0))
      case Id == IDC_WINELOOK
         ret := !(nWineLook -1 == SendDlgItemMessage (hWndDlg, IDC_WINELOOK, CB_GETCURSEL, 0, 0))
      case Id == IDC_RAD_BUILTIN .or. Id == IDC_RAD_NATIVE
         IF IsDlgButtonChecked ( hWndDlg, IDC_RAD_BUILTIN )
            DLLType := DLL_BUILTIN
         ELSE
            DLLType := DLL_NATIVE
         ENDIF
         IF (hControl := GetDialogItemHandle(hWndDlg,IDC_LIST_DLLS))> 0
            ListBoxReset ( hControl )
            for i = 1 TO Len(aDLLType)
               IF aDLLType[i,2] == DLLType
                  ListboxAddString(hControl, aDLLType[i,1])
               endif
            NEXT
            ret :=TRUE
         endif
      case Id == IDC_MANAGED
         IF IsDlgButtonChecked ( hWndDlg, IDC_MANAGED )
            EnableDialogItem (hWndDlg, IDC_DESKTOP_SIZE )
            EnableDialogItem (hWndDlg, IDC_DESKTOP_WIDTH)
            EnableDialogItem (hWndDlg, IDC_DESKTOP_BY )
            EnableDialogItem (hWndDlg, IDC_DESKTOP_HEIGHT)
         ELSE
            DisableDialogItem (hWndDlg, IDC_DESKTOP_SIZE )
            DisableDialogItem (hWndDlg, IDC_DESKTOP_WIDTH)
            DisableDialogItem (hWndDlg, IDC_DESKTOP_BY )
            DisableDialogItem (hWndDlg, IDC_DESKTOP_HEIGHT)
         endif
         ret :=TRUE
      case Id == IDC_PRIVATEMAP .or. Id == IDC_PERFECTGRAPH .or. Id == IDC_XDGA .or. Id == IDC_XSHM
         ret :=TRUE
      endcase
   endif
Return ret

//====================================================================

Function CancelModalFun( hWndDlg, IdDlg )
   LOCAL ret := FALSE, DLLType, hControl, i, aVer
   if IdDlg != Nil
      DO CASE
      CASE idDlg == IDD_GENCFG
         IF (hControl := GetDialogItemHandle(hWndDlg,IDC_WINVER)) > 0
            aVer := WinVersion()
            for i = 1 TO Len(aWinVersions)
               if AllTrim(aVer[1]) == aWinVersions[i,2]
                  SendDlgItemMessage (hWndDlg, IDC_WINVER, CB_SETCURSEL, i-1, 0)
                  nWinVer := i
               endif
            NEXT
         ENDIF
      CASE idDlg == IDD_DLLCFG
         CheckRadioButton (hWndDlg, IDC_RAD_BUILTIN, IDC_RAD_NATIVE, IDC_RAD_BUILTIN)
         IF (hControl := GetDialogItemHandle(hWndDlg,IDC_LIST_DLLS)) > 0
            ListBoxReset ( hControl )
            for i = 1 TO Len(aDLLType)
               IF aDLLType[i,2] == DLL_BUILTIN
                  ListboxAddString(hControl, aDLLType[i,1])
               endif
            NEXT
         ENDIF
      CASE IdDlg == IDD_X11DRVCFG
         UnCheckDlgButton (IDC_PRIVATEMAP,hWndDlg )
         UnCheckDlgButton (IDC_PERFECTGRAPH,hWndDlg )
         CheckDlgButton (IDC_XDGA,hWndDlg )
         UnCheckDlgButton (IDC_XSHM,hWndDlg )
         UnCheckDlgButton (IDC_MANAGED,hWndDlg )
         SetDialogItemText ( hWndDlg, IDC_DESKTOP_WIDTH, " " )
         SetDialogItemText ( hWndDlg, IDC_DESKTOP_HEIGHT, " " )

         DisableDialogItem (hWndDlg, IDC_DESKTOP_SIZE )
         DisableDialogItem (hWndDlg, IDC_DESKTOP_WIDTH)
         DisableDialogItem (hWndDlg, IDC_DESKTOP_BY )
         DisableDialogItem (hWndDlg, IDC_DESKTOP_HEIGHT)
      ENDCASE
   endif
Return ret

//====================================================================


*-------------------------------------------------------------
FUNCTION WizardPropSheet()
*-------------------------------------------------------------
    nSelOpt := 0

   DEFINE PROPSHEET propSheet_3 OF Form_1 ;
         AT 150,150 ;
         WIDTH 300 ;
         HEIGHT 200 ;
         WIZARD ;
         CAPTION "Wizard Property Sheet Demo" ;
         ICON IDI_STARICON ;
         FONT "Arial" SIZE 10 ;
         WATERMARK IDI_WIZARD ;
         HEADERBMP IDI_HEADER ;
         DIALOGPROC {|x,y,z,v| WizardDialogFun(x,y,z,v)} ;
         ON INIT { |hWndDlg,idDlg| InitWizardSheetFun(hWndDlg,idDlg) } ;
//       ON CANCEL MsgYesNo("Quit Question", "Quit Caption" )

         SHEETPAGE demo31 RESOURCE IDD_INIT TITLE "Demo Wizard" HIDEHEADER

         SHEETPAGE demo32 RESOURCE IDD_WIZ1 HEADER "Page 1" SUBHEADER "Subtitle 1 sample"

         SHEETPAGE demo33 RESOURCE IDD_WIZ2 HEADER "Page 2" SUBHEADER "Subtitle 2 sample"

     END PROPSHEET


RETURN Nil

*-------------------------------------------------------------
FUNCTION WizardLitePropSheet()
*-------------------------------------------------------------
    nSelOpt := 0

   DEFINE PROPSHEET propSheet_4 OF Form_1 ;
         AT 150,150 ;
         WIDTH 300 ;
         HEIGHT 200 ;
         WIZARD LITE;
         CAPTION "Wizard Lite Property Sheet Demo" ;
         ICON IDI_STARICON ;
         FONT "Arial" SIZE 10 ;
         DIALOGPROC {|x,y,z,v| WizardDialogFun(x,y,z,v)} ;
         ON INIT { |hWndDlg,idDlg| InitWizardSheetFun(hWndDlg,idDlg) } ;

         SHEETPAGE demo41 RESOURCE IDD_INIT TITLE "Demo Wizard" HIDEHEADER

         SHEETPAGE demo42 RESOURCE IDD_WIZ1 HEADER "Page 1" SUBHEADER "Subtitle 1 sample"

         SHEETPAGE demo43 RESOURCE IDD_WIZ2 HEADER "Page 2" SUBHEADER "Subtitle 2 sample"

     END PROPSHEET

RETURN Nil


FUNCTION InitWizardSheetFun(hWndDlg, idDlg )
   DO CASE
      CASE idDlg == IDD_INIT

            REDEFINE LABEL Lbl_1;
               ID IDC_STC1 ;
               OF Form_1;
               VALUE "Welcome to the Sample Wizard"  ;
               FONT "Tahoma" SIZE 12  BOLD

       CASE idDlg == IDD_WIZ2
          SetDialogItemText ( hWndDlg, IDC_EDIT1, " You did not select any option." )
   ENDCASE

RETURN Nil


Function WizardDialogFun(hWndDlg, nMsg , Id, Notify )
   LOCAL ret := 0
   if Id != Nil
        DO CASE
        CASE Id == IDC_RBN1
          nSelOpt := 1
        CASE Id == IDC_RBN2
          nSelOpt := 2
        CASE Id == IDC_RBN3
          nSelOpt := 3
       CASE Id == IDC_EDIT1  .and. Notify == 256
           DO CASE
           CASE nSelOpt == 1
             SetDialogItemText ( hWndDlg, IDC_EDIT1, "You selected  <Option A>" )
           CASE nSelOpt == 2
             SetDialogItemText ( hWndDlg, IDC_EDIT1, "You selected  <Option B>" )
           CASE nSelOpt == 3
             SetDialogItemText ( hWndDlg, IDC_EDIT1, "You selected  <Option C>" )
           ENDCASE
         ENDCASE
    endif
Return ret


*-------------------------------------------------------------
FUNCTION ModalPropSheetInDirect()
*-------------------------------------------------------------

   DEFINE PROPSHEET propSheet_5 OF Form_1 ;
      AT 150,150 ;
      WIDTH 530 ;
      HEIGHT 450 ;
      MODAL ;
      CAPTION "MODAL Property Sheet Demo - Wine Configuration" ;
      FONT "MS Sans Serif" SIZE 8;
      ICON "STAR.ICO" ;
      DIALOGPROC {|x,y,z,v| ModalPropSheetFun(x,y,z,v) } ;
      ON INIT { |hWndDlg, idDlg| InitModalFun(hWndDlg, idDlg) } ;
      ON CANCEL { |hWndDlg, idDlg, nPage| MsgInfo("Cancel for Page: "+Str(nPage,2)), CancelModalFun( hWndDlg, IdDlg ) } ;
      ON APPLY  { |hWndDlg, idDlg, nPage| MsgInfo("OK for Page: "+Str(nPage,2)) }

      DEFINE SHEETPAGE demo51 RESOURCE IDD_GENCFG TITLE "General"

         @ 8,16   FRAME Frame_1 CAPTION  "Default Behaviour" WIDTH 488 HEIGHT 212
         @ 34, 238 LABEL Lbl_1 VALUE "Wine Version:" WIDTH 90 HEIGHT 16
         @ 34, 338 LABEL Lbl_1 VALUE "CVS"  WIDTH 112 HEIGHT 16
         @ 30,34 IMAGE Img_1  ID IDC_BMP PICTURE "WINE.bmp" WIDTH 200 HEIGHT 180
         @ 62, 238 LABEL Lbl_1 VALUE  "http://www.winehq.com/" WIDTH 212 HEIGHT 16
         @ 88, 238 LABEL Lbl_1 VALUE  "This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.";
            WIDTH 248 HEIGHT 118
         @ 230,16 FRAME Frame_2 CAPTION  "Information" WIDTH 488 HEIGHT 194
         @ 256, 30 LABEL Lbl_1 VALUE "Wine provides the ability for Windows applications to mimic various Windows versions and styles";
           WIDTH 454 HEIGHT 40
         @ 310, 34 LABEL Lbl_1 VALUE  "Windows Version:" WIDTH 116 HEIGHT 16
         @ 346, 34 LABEL Lbl_1 VALUE "DOS Version:" WIDTH 114 HEIGHT 16
         @ 386, 34 LABEL Lbl_1 VALUE "Windows Look:" WIDTH 116 HEIGHT 16

         @ 306, 166 COMBOBOX Combo_1 ID IDC_WINVER ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1
         @ 344, 166 COMBOBOX Combo_1 ID IDC_DOSVER ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1
         @ 380, 166 COMBOBOX Combo_1 ID IDC_WINELOOK ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1
      END SHEETPAGE

      DEFINE SHEETPAGE demo52 RESOURCE IDD_DLLCFG TITLE "Libraries"

         @ 8,16 FRAME Frame_2 CAPTION  "Static" WIDTH 488 HEIGHT 314
         @ 34,30 LABEL Lbl_1 VALUE 'Libraries can be specified individually to be either builtin or native. A DLL entry specified"; as "*" pertains to all DLLs not specified explicitly.';
            WIDTH 456 HEIGHT 54
         @ 94, 30 LISTBOX Lbox_1 ID IDC_LIST_DLLS WIDTH 454 HEIGHT 180 ITEMS {}
         @ 290, 32 LABEL Lbl_1 VALUE "Load order:" WIDTH 74 HEIGHT 16
         @ 288 ,118 RADIOGROUP Radio_1 ID {IDC_RAD_BUILTIN,IDC_RAD_NATIVE};
            OPTIONS {"Builtin (Wine)","Native (Windows)"} VALUE 1 WIDTH 144 HORIZONTAL ;

      END SHEETPAGE

      DEFINE SHEETPAGE demo53 RESOURCE IDD_APPCFG TITLE "Applications"

         @ 8,16 FRAME Frame_2 CAPTION  "Application Specific Setting" WIDTH 488 HEIGHT 302
         @ 34,30 LABEL Lbl_1 VALUE "These settings allow you to overwrite Wine default settings (as specified in other configuration tabs) on a per-application basis.";
            WIDTH 456 HEIGHT 40
         @ 78, 32 LISTBOX Lbox_1 ID IDC_LIST_APPS WIDTH 452 HEIGHT 216 ITEMS {}

      END SHEETPAGE

      DEFINE SHEETPAGE demo54 RESOURCE IDD_X11DRVCFG TITLE "X11 Driver"

         @ 82 ,200 TEXTBOX tbox1 ID IDC_SYSCOLORS WIDTH 80 HEIGHT 28 VALUE "" NUMERIC
         @ 124 ,34 CHECKBOX chkbox_1 ID IDC_PRIVATEMAP CAPTION "Use a private color map" WIDTH 182 HEIGHT 20
         @ 152 ,34 CHECKBOX chkbox_1 ID IDC_PERFECTGRAPH CAPTION "Favor correctness over speed" WIDTH 234 HEIGHT 20
         @ 124 ,282 CHECKBOX chkbox_1 ID IDC_XDGA CAPTION "Use XFree DGA extention" WIDTH 194 HEIGHT 20
         @ 152 ,282 CHECKBOX chkbox_1 ID IDC_XSHM CAPTION "Use XFree Shm extention" WIDTH 192 HEIGHT 20
         @ 286 ,34 CHECKBOX chkbox_1 ID IDC_MANAGED CAPTION "Enable Wine desktop" WIDTH 168 HEIGHT 20
         @ 318 ,128 TEXTBOX tbox1 ID IDC_DESKTOP_WIDTH WIDTH 80 HEIGHT 28 NUMERIC  //DISABLED
         @ 318 ,234 TEXTBOX tbox1 ID IDC_DESKTOP_HEIGHT WIDTH 80 HEIGHT 28 VALUE "" NUMERIC  //DISABLED
         @ 8,16 FRAME Frame_2 CAPTION "Render Settings" WIDTH 488 HEIGHT 180
         @ 34,30 LABEL Lbl_1 VALUE "The driver color and render settings are used to optimise the way in which colors and applications are displayed.";
             WIDTH 456 HEIGHT 44
         @ 86,34 LABEL Lbl_1 VALUE "Allocated system colors:" WIDTH 152 HEIGHT 16
         @ 198,16 FRAME Frame_2 CAPTION "Wine Desktop" WIDTH 488 HEIGHT 166
         @ 224,30 LABEL Lbl_1 VALUE 'Wine can be setup to emulate a windows desktop, or can be run in "Managed" mode (default) where the default X11 windows manager/environment is resposible for placing the windows.';
             WIDTH 456 HEIGHT 56
         @ 322,34 LABEL Lbl_1 VALUE "Desktop size:"  ID IDC_DESKTOP_SIZE WIDTH 88 HEIGHT 16  //WS_DISABLED
         @ 322,216 LABEL Lbl_1 VALUE "X" ID IDC_DESKTOP_BY WIDTH 16 HEIGHT 16  //WS_DISABLED

      END SHEETPAGE

     END PROPSHEET

RETURN nil

*-------------------------------------------------------------
FUNCTION WizardPropSheetInDirect()
*-------------------------------------------------------------
    nSelOpt := 0

   DEFINE PROPSHEET propSheet_6 OF Form_1 ;
      AT 150,150 ;
      WIDTH 300 ;
      HEIGHT 300 ;
      WIZARD;
      CAPTION "Wizard Property Sheet Demo";
      FONT "Arial" SIZE 9;
      WATERMARK IDI_WIZARD ;
      HEADERBMP IDI_HEADER ;
      DIALOGPROC {|x,y,z,v| WizardDialogFun(x,y,z,v)} ;
      ON INIT { |hWndDlg,idDlg| InitWizardSheetFun(hWndDlg,idDlg)  }

      DEFINE SHEETPAGE demo61  TITLE "Demo Wizard"   HIDEHEADER
         @ 25,200  LABEL Lbl_1 ID 301 VALUE "Welcome to the Sample Wizard" WIDTH 250 HEIGHT 40 FONT "Tahoma" SIZE 12   BOLD
         @ 95,220  LABEL Lbl_2 ID 302 VALUE "Some explanatory text" WIDTH 250 HEIGHT 30
         @ 180,220 LABEL Lbl_2 ID 303 VALUE "Some warning text" WIDTH 230 HEIGHT 35
         @ 320,200 LABEL Lbl_4 ID 304 VALUE "To continue, click Next" WIDTH 250 HEIGHT 15 FONT "Tahoma" SIZE 10   BOLD ITALIC
      END SHEETPAGE

      DEFINE SHEETPAGE demo62 HEADER "Header Title" SUBHEADER "Subtitle for 1st page"
         @ 15,70  LABEL Lbl_1 VALUE "You must select an option before procceeding to the next page" WIDTH 300 HEIGHT 48
         @ 60,80  FRAME Frame1 CAPTION "Options" WIDTH 250 HEIGHT 150
         @ 100,150  RADIOGROUP Radio1 ID {IDC_RBN1,IDC_RBN2,IDC_RBN3} OPTIONS {"Option A","Option B","Option C"} WIDTH 150

      END SHEETPAGE

      DEFINE SHEETPAGE demo63 RESOURCE IDD_WIZ2 HEADER "Header Title" SUBHEADER "Subtitle for 2nd page"
         @ 15, 10 LABEL Lbl_2 ID IDC_STATIC ;
            VALUE  "These settings allow you to overwrite Wine default settings (as specified in other configuration tabs) on a per-application basis.";
            WIDTH 450 HEIGHT 48
         @ 60,60  FRAME Frame1 ID IDC_STATIC CAPTION "Application Specific Setting" WIDTH 300 HEIGHT 150
         @ 80,70  TEXTBOX Edit_1 ID IDC_EDIT1 VALUE "" WIDTH 280 HEIGHT 120
      END SHEETPAGE

   END PROPSHEET

RETURN Nil

*-------------------------------------------------------------
FUNCTION ModelessPropSheetInDirect()
*-------------------------------------------------------------

   DEFINE PROPSHEET propSheet_7 OF Form_1 ;
      AT 150,150 ;
      WIDTH 530 ;
      HEIGHT 450 ;
      CAPTION "MODELESS Property Sheet Demo - Wine Configuration" ;
      FONT "MS Sans Serif" SIZE 8;
      ICON "STAR.ICO" ;
      DIALOGPROC {|x,y,z,v| ModalPropSheetFun(x,y,z,v) } ;
      ON INIT { |hWndDlg, idDlg| InitModalFun(hWndDlg, idDlg) } ;
      ON CANCEL { |hWndDlg, idDlg| MsgInfo("Cancel for ID Page: "+Str(idDlg,4)), CancelModalFun( hWndDlg, IdDlg ),FALSE } ;
      ON APPLY  { |hWndDlg, idDlg, nPage| MsgInfo("OK for Page: "+Str(nPage,2)) }

      DEFINE SHEETPAGE demo71 RESOURCE IDD_GENCFG TITLE "General"

         @ 8,16   FRAME Frame_1 CAPTION  "Default Behaviour" WIDTH 488 HEIGHT 212
         @ 34, 238 LABEL Lbl_1 VALUE "Wine Version:" WIDTH 90 HEIGHT 16
         @ 34, 338 LABEL Lbl_1 VALUE "CVS"  WIDTH 112 HEIGHT 16
         @ 30,34 IMAGE Img_1  ID IDC_BMP PICTURE "WINE.bmp" WIDTH 150 HEIGHT 140  STRETCH
         @ 62, 238 LABEL Lbl_1 VALUE  "http://www.winehq.com/" WIDTH 212 HEIGHT 16
         @ 88, 238 LABEL Lbl_1 VALUE  "This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.";
            WIDTH 248 HEIGHT 118
         @ 230,16 FRAME Frame_2 CAPTION  "Information" WIDTH 488 HEIGHT 194
         @ 256, 30 LABEL Lbl_1 VALUE "Wine provides the ability for Windows applications to mimic various Windows versions and styles";
           WIDTH 454 HEIGHT 40
         @ 310, 34 LABEL Lbl_1 VALUE  "Windows Version:" WIDTH 116 HEIGHT 16
         @ 346, 34 LABEL Lbl_1 VALUE "DOS Version:" WIDTH 114 HEIGHT 16
         @ 386, 34 LABEL Lbl_1 VALUE "Windows Look:" WIDTH 116 HEIGHT 16

         @ 306, 166 COMBOBOX Combo_1 ID IDC_WINVER ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1
         @ 344, 166 COMBOBOX Combo_1 ID IDC_DOSVER ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1
         @ 380, 166 COMBOBOX Combo_1 ID IDC_WINELOOK ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1
      END SHEETPAGE

      DEFINE SHEETPAGE demo72 RESOURCE IDD_DLLCFG TITLE "Libraries"

         @ 8,16 FRAME Frame_2 CAPTION  "Static" WIDTH 488 HEIGHT 314
         @ 34,30 LABEL Lbl_1 VALUE 'Libraries can be specified individually to be either builtin or native. A DLL entry specified"; as "*" pertains to all DLLs not specified explicitly.';
            WIDTH 456 HEIGHT 54
         @ 94, 30 LISTBOX Lbox_1 ID IDC_LIST_DLLS WIDTH 454 HEIGHT 180 ITEMS {}
         @ 290, 32 LABEL Lbl_1 VALUE "Load order:" WIDTH 74 HEIGHT 16
         @ 288 ,118 RADIOGROUP Radio_1 ID {IDC_RAD_BUILTIN,IDC_RAD_NATIVE};
            OPTIONS {"Builtin (Wine)","Native (Windows)"} VALUE 1 WIDTH 144 HORIZONTAL ;

      END SHEETPAGE

      DEFINE SHEETPAGE demo73 RESOURCE IDD_APPCFG TITLE "Applications"

         @ 8,16 FRAME Frame_2 CAPTION  "Application Specific Setting" WIDTH 488 HEIGHT 302
         @ 34,30 LABEL Lbl_1 VALUE "These settings allow you to overwrite Wine default settings (as specified in other configuration tabs) on a per-application basis.";
            WIDTH 456 HEIGHT 40
         @ 78, 32 LISTBOX Lbox_1 ID IDC_LIST_APPS WIDTH 452 HEIGHT 216 ITEMS {}

      END SHEETPAGE

      DEFINE SHEETPAGE demo74 RESOURCE IDD_X11DRVCFG TITLE "X11 Driver"

         @ 82 ,200 TEXTBOX tbox1 ID IDC_SYSCOLORS WIDTH 80 HEIGHT 28 VALUE "" NUMERIC
         @ 124 ,34 CHECKBOX chkbox_1 ID IDC_PRIVATEMAP CAPTION "Use a private color map" WIDTH 182 HEIGHT 20
         @ 152 ,34 CHECKBOX chkbox_1 ID IDC_PERFECTGRAPH CAPTION "Favor correctness over speed" WIDTH 234 HEIGHT 20
         @ 124 ,282 CHECKBOX chkbox_1 ID IDC_XDGA CAPTION "Use XFree DGA extention" WIDTH 194 HEIGHT 20
         @ 152 ,282 CHECKBOX chkbox_1 ID IDC_XSHM CAPTION "Use XFree Shm extention" WIDTH 192 HEIGHT 20
         @ 286 ,34 CHECKBOX chkbox_1 ID IDC_MANAGED CAPTION "Enable Wine desktop" WIDTH 168 HEIGHT 20
         @ 318 ,128 TEXTBOX tbox1 ID IDC_DESKTOP_WIDTH WIDTH 80 HEIGHT 28 NUMERIC  //DISABLED
         @ 318 ,234 TEXTBOX tbox1 ID IDC_DESKTOP_HEIGHT WIDTH 80 HEIGHT 28 VALUE "" NUMERIC  //DISABLED
         @ 8,16 FRAME Frame_2 CAPTION "Render Settings" WIDTH 488 HEIGHT 180
         @ 34,30 LABEL Lbl_1 VALUE "The driver color and render settings are used to optimise the way in which colors and applications are displayed.";
             WIDTH 456 HEIGHT 44
         @ 86,34 LABEL Lbl_1 VALUE "Allocated system colors:" WIDTH 152 HEIGHT 16
         @ 198,16 FRAME Frame_2 CAPTION "Wine Desktop" WIDTH 488 HEIGHT 166
         @ 224,30 LABEL Lbl_1 VALUE 'Wine can be setup to emulate a windows desktop, or can be run in "Managed" mode (default) where the default X11 windows manager/environment is resposible for placing the windows.';
             WIDTH 456 HEIGHT 56
         @ 322,34 LABEL Lbl_1 VALUE "Desktop size:"  ID IDC_DESKTOP_SIZE WIDTH 88 HEIGHT 16  //WS_DISABLED
         @ 322,216 LABEL Lbl_1 VALUE "X" ID IDC_DESKTOP_BY WIDTH 16 HEIGHT 16  //WS_DISABLED

      END SHEETPAGE

     END PROPSHEET

RETURN nil

*-------------------------------------------------------------
FUNCTION ModelessPropSheetInDirectEnv()
*-------------------------------------------------------------
   DEFINE PROPSHEET propSheet_8 OF Form_1 ;
      AT 150,150 ;
      WIDTH 530 ;
      HEIGHT 450 ;
      CAPTION "MODELESS Property Sheet Demo - Wine Configuration" ;
      FONT "MS Sans Serif" SIZE 8;
      ICON "STAR.ICO" ;
      ON INIT { |hWndDlg, idDlg| InitModalFun(hWndDlg, idDlg) } ;
      ON CANCEL { |hWndDlg, idDlg| MsgInfo("Cancel for ID Page: "+Str(idDlg,4)), CancelModalFun( hWndDlg, IdDlg ),FALSE } ;
      ON APPLY  { |hWndDlg, idDlg, nPage| MsgInfo("OK for Page: "+Str(nPage,2)) }
//      DIALOGPROC {|x,y,z,v| ModalPropSheetFun(x,y,z,v) } ;

      DEFINE SHEETPAGE demo81 RESOURCE IDD_GENCFG TITLE "General"

         @ 8,16   FRAME Frame_1 CAPTION  "Default Behaviour" WIDTH 488 HEIGHT 212
         @ 34, 238 LABEL Lbl_1 VALUE "Wine Version:" WIDTH 90 HEIGHT 16
         @ 34, 338 LABEL Lbl_2 VALUE "CVS"  WIDTH 112 HEIGHT 16
         @ 30,34 IMAGE Img_1  ID IDC_BMP PICTURE "WINE.bmp" WIDTH 150 HEIGHT 150  STRETCH
         @ 62, 238 LABEL Lbl_3 VALUE  "http://www.winehq.com/" WIDTH 212 HEIGHT 16
         @ 88, 238 LABEL Lbl_4 VALUE  "This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.";
            WIDTH 248 HEIGHT 118
         @ 230,16 FRAME Frame_2 CAPTION  "Information" WIDTH 488 HEIGHT 194
         @ 256, 30 LABEL Lbl_4 VALUE "Wine provides the ability for Windows applications to mimic various Windows versions and styles";
           WIDTH 454 HEIGHT 40
         @ 310, 34 LABEL Lbl_5 VALUE  "Windows Version:" WIDTH 116 HEIGHT 16
         @ 346, 34 LABEL Lbl_6 VALUE "DOS Version:" WIDTH 114 HEIGHT 16
         @ 386, 34 LABEL Lbl_7 VALUE "Windows Look:" WIDTH 116 HEIGHT 16

         @ 306, 166 COMBOBOX Combo_1 ID IDC_WINVER ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1 ON CHANGE OnChangeCombo(IDC_WINVER)
         @ 344, 166 COMBOBOX Combo_2 ID IDC_DOSVER ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1 ON CHANGE OnChangeCombo(IDC_DOSVER)
         @ 380, 166 COMBOBOX Combo_3 ID IDC_WINELOOK ;
            WIDTH 316 HEIGHT 118; //,CBS_DROPDOWNLIST | WS_VSCROLL | WS_TABSTOP
            ITEMS {} VALUE 1  ON CHANGE OnChangeCombo(IDC_WINELOOK)
      END SHEETPAGE

      DEFINE SHEETPAGE demo82 RESOURCE IDD_DLLCFG TITLE "Libraries"

         @ 8,16 FRAME Frame_2 CAPTION  "Static" WIDTH 488 HEIGHT 314
         @ 34,30 LABEL Lbl_1 VALUE 'Libraries can be specified individually to be either builtin or native. A DLL entry specified"; as "*" pertains to all DLLs not specified explicitly.';
            WIDTH 456 HEIGHT 54
         @ 94, 30 LISTBOX Lbox_1 ID IDC_LIST_DLLS WIDTH 454 HEIGHT 180 ITEMS {}
         @ 290, 32 LABEL Lbl_1 VALUE "Load order:" WIDTH 74 HEIGHT 16
         @ 288 ,118 RADIOGROUP Radio_1 ID {IDC_RAD_BUILTIN,IDC_RAD_NATIVE};
            OPTIONS {"Builtin (Wine)","Native (Windows)"} VALUE 1 WIDTH 144 HORIZONTAL ;
            ON CHANGE OnChangeRadio()


      END SHEETPAGE

      DEFINE SHEETPAGE demo83 RESOURCE IDD_APPCFG TITLE "Applications"

         @ 8,16 FRAME Frame_2 CAPTION  "Application Specific Setting" WIDTH 488 HEIGHT 302
         @ 34,30 LABEL Lbl_1 VALUE "These settings allow you to overwrite Wine default settings (as specified in other configuration tabs) on a per-application basis.";
            WIDTH 456 HEIGHT 40
         @ 78, 32 LISTBOX Lbox_1 ID IDC_LIST_APPS WIDTH 452 HEIGHT 216 ITEMS {}

      END SHEETPAGE

      DEFINE SHEETPAGE demo84 RESOURCE IDD_X11DRVCFG TITLE "X11 Driver"

         @ 82 ,200  TEXTBOX  tbox1    ID IDC_SYSCOLORS WIDTH 80 HEIGHT 28 VALUE "" NUMERIC
         @ 124 ,34  CHECKBOX chkbox_1 ID IDC_PRIVATEMAP CAPTION "Use a private color map" WIDTH 182 HEIGHT 20;
            ON CHANGE  OnChangeCheck(0)
         @ 152 ,34  CHECKBOX chkbox_2 ID IDC_PERFECTGRAPH CAPTION "Favor correctness over speed" WIDTH 234 HEIGHT 20;
            ON CHANGE  OnChangeCheck(0)
         @ 124 ,282 CHECKBOX chkbox_3 ID IDC_XDGA CAPTION "Use XFree DGA extention" WIDTH 194 HEIGHT 20 ;
            ON CHANGE  OnChangeCheck(0)
         @ 152 ,282 CHECKBOX chkbox_4 ID IDC_XSHM CAPTION "Use XFree Shm extention" WIDTH 192 HEIGHT 20 ;
            ON CHANGE  OnChangeCheck(0)
         @ 286 ,34  CHECKBOX chkbox_5 ID IDC_MANAGED CAPTION "Enable Wine desktop" WIDTH 168 HEIGHT 20 ;
            ON CHANGE  OnChangeCheck(1)

         @ 318 ,128 TEXTBOX tbox2 ID IDC_DESKTOP_WIDTH WIDTH 80 HEIGHT 28 NUMERIC  //DISABLED
         @ 318 ,234 TEXTBOX tbox3 ID IDC_DESKTOP_HEIGHT WIDTH 80 HEIGHT 28 VALUE "" NUMERIC  //DISABLED
         @ 8   ,16  FRAME Frame_1 CAPTION "Render Settings" WIDTH 488 HEIGHT 180
         @ 34,30    LABEL Lbl_1 VALUE "The driver color and render settings are used to optimise the way in which colors and applications are displayed.";
             WIDTH 456 HEIGHT 44
         @ 86,34    LABEL Lbl_2 VALUE "Allocated system colors:" WIDTH 152 HEIGHT 16
         @ 198,16   FRAME Frame_2 CAPTION "Wine Desktop" WIDTH 488 HEIGHT 166
         @ 224,30   LABEL Lbl_3 VALUE 'Wine can be setup to emulate a windows desktop, or can be run in "Managed" mode (default) where the default X11 windows manager/environment is resposible for placing the windows.';
             WIDTH 456 HEIGHT 56
         @ 322,34   LABEL Lbl_4 VALUE "Desktop size:"  ID IDC_DESKTOP_SIZE WIDTH 88 HEIGHT 16  //WS_DISABLED
         @ 322,216  LABEL Lbl_5 VALUE "X" ID IDC_DESKTOP_BY WIDTH 16 HEIGHT 16  //WS_DISABLED

      END SHEETPAGE

     END PROPSHEET

     RETURN nil

FUNCTION OnChangeCombo(nId)
   LOCAL  nOldVer, lRet := FALSE
      do case
      case nId == IDC_WINVER
         nOldVer := nWinVer
         lRet := (nWinVer := GetProperty("Demo81","Combo_1","Value"))  != nOldVer
      case nId == IDC_DOSVER
         nOldVer := nDosVer
         lRet := (nDosVer := GetProperty("Demo81","Combo_2","Value"))  != nOldVer
      case nId == IDC_WINELOOK
         nOldVer := nWineLook
         lRet := (nWineLook := GetProperty("Demo81","Combo_3","Value"))  != nOldVer
      endcase
      IF lRet
         PropSheet_Chd( GetFormHandle ("PropSheet_8"),GetFormHandle ("Demo81"))
      endif
RETURN  nil

FUNCTION OnChangeCheck(nId)
   LOCAL lValue
   PropSheet_Chd( GetFormHandle ("PropSheet_8"),GetFormHandle ("Demo84"))
   IF IsControlDefined (chkbox_5,Demo84) .and. nId == 1
      lValue := GetProperty("Demo84","chkbox_5","Value")
      if lValue
         SetProperty("Demo84","tbox2","Enabled",.T.)
         SetProperty("Demo84","tbox3","Enabled",.T.)
         SetProperty("Demo84","Lbl_4","Enabled",.T.)
         SetProperty("Demo84","Lbl_5","Enabled",.T.)
      else
         SetProperty("Demo84","tbox2","Enabled",.F.)
         SetProperty("Demo84","tbox3","Enabled",.F.)
         SetProperty("Demo84","Lbl_4","Enabled",.F.)
         SetProperty("Demo84","Lbl_5","Enabled",.F.)
      ENDIF
    endif
RETURN nil

FUNCTION OnChangeRadio()
   LOCAL  DLLType, hControl, i, hForm, hParent
   IF IsControlDefined (Radio_1,Demo82)
      IF GetProperty("Demo82","Radio_1","Value") ==1
         DLLType := DLL_BUILTIN
      ELSE
         DLLType := DLL_NATIVE
      ENDIF
      hForm    := GetFormHandle ("Demo82")
      hParent  := GetFormHandle ("PropSheet_8")
      PropSheet_Chd( hParent,hForm)
      IF IsControlDefined (Lbox_1,Demo82)
         DELETE ITEM ALL FROM Lbox_1 OF Demo82
         for i = 1 TO Len(aDLLType)
            IF aDLLType[i,2] == DLLType
               ADD ITEM aDLLType[i,1] TO Lbox_1 OF Demo82
            endif
         NEXT
      ENDIF
   endif
return Nil


/*
Function ModalPropSheetFun( hWndDlg, nMsg , Id, Notify )
   LOCAL ret := FALSE, DLLType, hControl, i
   if Id != Nil
      do case
      case Id == IDC_WINVER
         ret := !(nWinVer -1 == SendDlgItemMessage (hWndDlg, IDC_WINVER, CB_GETCURSEL, 0, 0))
      case Id == IDC_DOSVER
         ret := !(nDosVer -1 == SendDlgItemMessage (hWndDlg, IDC_DOSVER, CB_GETCURSEL, 0, 0))
      case Id == IDC_WINELOOK
         ret := !(nWineLook -1 == SendDlgItemMessage (hWndDlg, IDC_WINELOOK, CB_GETCURSEL, 0, 0))
      case Id == IDC_RAD_BUILTIN .or. Id == IDC_RAD_NATIVE
         IF IsDlgButtonChecked ( hWndDlg, IDC_RAD_BUILTIN )
            DLLType := DLL_BUILTIN
         ELSE
            DLLType := DLL_NATIVE
         ENDIF
         IF (hControl := GetDialogItemHandle(hWndDlg,IDC_LIST_DLLS))> 0
            ListBoxReset ( hControl )
            for i = 1 TO Len(aDLLType)
               IF aDLLType[i,2] == DLLType
                  ListboxAddString(hControl, aDLLType[i,1])
               endif
            NEXT
            ret :=TRUE
         endif
      case Id == IDC_MANAGED
         IF IsDlgButtonChecked ( hWndDlg, IDC_MANAGED )
            EnableDialogItem (hWndDlg, IDC_DESKTOP_SIZE )
            EnableDialogItem (hWndDlg, IDC_DESKTOP_WIDTH)
            EnableDialogItem (hWndDlg, IDC_DESKTOP_BY )
            EnableDialogItem (hWndDlg, IDC_DESKTOP_HEIGHT)
         ELSE
            DisableDialogItem (hWndDlg, IDC_DESKTOP_SIZE )
            DisableDialogItem (hWndDlg, IDC_DESKTOP_WIDTH)
            DisableDialogItem (hWndDlg, IDC_DESKTOP_BY )
            DisableDialogItem (hWndDlg, IDC_DESKTOP_HEIGHT)
         endif
         ret :=TRUE
      case Id == IDC_PRIVATEMAP .or. Id == IDC_PERFECTGRAPH .or. Id == IDC_XDGA .or. Id == IDC_XSHM
         ret :=TRUE
      endcase
   endif
Return ret
*/
