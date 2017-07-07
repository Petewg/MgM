/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

FUNCTION MAIN
   LOCAL nCol

   DEFINE WINDOW FORM_1 ;
   AT 0,0 WIDTH 350 HEIGHT 235 ;
   MINWIDTH 350 MINHEIGHT 235 ;
   TITLE "Get Form Client Height" ;
   MAIN ;
   ON INIT { || Form_Resize(ThisWindow.Name) } ;
   ON SIZE { || Form_Resize(ThisWindow.Name) } ;
   ON MAXIMIZE { || Form_Resize(ThisWindow.Name) }

   DEFINE MAIN MENU
      POPUP "&File" NAME mnuFile
         MENUITEM "&Exit" NAME mnuFileExit ;
            ACTION { || ThisWindow.Release() }
      END POPUP
   END MENU

   DEFINE STATUSBAR
      STATUSITEM "Ready" RAISED
      DATE
      CLOCK
   END STATUSBAR

   @ 05,10 LABEL lblWindow    VALUE "WindowHeight = " AUTOSIZE
   @ 25,10 LABEL lblBorder    VALUE "BorderHeight = " AUTOSIZE
   @ 45,10 LABEL lblTitlebar  VALUE "TitleHeight = " AUTOSIZE
   @ 65,10 LABEL lblMenubar   VALUE "MenubarHeight = " AUTOSIZE
   @ 85,10 LABEL lblStatusbar VALUE "StatusbarHeight = " AUTOSIZE
   @105,10 LABEL lblClient    VALUE "ClientHeight = " AUTOSIZE
   @125,10 LABEL lblClientW   VALUE "ClientWidth = " AUTOSIZE
   @145,10 LABEL lblWorkArea  VALUE "WorkAreaHeight = " AUTOSIZE

   nCol := GetProperty("FORM_1", "lblStatusbar", "Width") + 10

   @ 05,nCol LABEL lblWindowHeight    VALUE "" WIDTH 70 HEIGHT 16 RIGHTALIGN
   @ 25,nCol LABEL lblBorderHeight    VALUE hb_ntos(GetBorderHeight()) WIDTH 70 RIGHTALIGN
   @ 45,nCol LABEL lblTitleHeight     VALUE hb_ntos(GetTitleHeight()) WIDTH 70 RIGHTALIGN
   @ 65,nCol LABEL lblMenubarHeight   VALUE hb_ntos(GetMenubarHeight()) WIDTH 70 RIGHTALIGN
   @ 85,nCol LABEL lblStatusbarHeight VALUE hb_ntos(GetProperty("FORM_1", "StatusBar", "Height")) WIDTH 70 RIGHTALIGN
   @105,nCol LABEL lblClientHeight    VALUE "" WIDTH 70 RIGHTALIGN
   @125,nCol LABEL lblClientWidth     VALUE "" WIDTH 70 RIGHTALIGN
   @145,nCol LABEL lblWorkAreaHeight  VALUE "" WIDTH 70 HEIGHT 16 RIGHTALIGN

   @ 0,nCol+100 EDITBOX edx WIDTH 100 HEIGHT 100 //NOHSCROLL

   END WINDOW

   CENTER WINDOW FORM_1
   ACTIVATE WINDOW FORM_1

RETURN NIL


STATIC PROCEDURE Form_Resize(cForm)
   LOCAL nWindowHeight, nClientHeight, nWorkAreaHeight

   nWindowHeight := GetProperty(cForm, "Height")
   nClientHeight := nWindowHeight - 2 * GetBorderHeight()
   nClientHeight -= GetTitleHeight() + GetMenubarHeight()
   nClientHeight -= GetProperty(cForm, "StatusBar", "Height")

   SetProperty(cForm, "lblWindowHeight", "Value", hb_ntos(nWindowHeight))
   SetProperty(cForm, "edx", "Height", nClientHeight)
   SetProperty(cForm, "edx", "Width", GetProperty(cForm, "Width") - GetProperty(cForm, "edx", "Col") - 2 * GetBorderWidth())
   SetProperty(cForm, "lblClientHeight", "Value", hb_ntos(This.edx.ClientHeight))
   SetProperty(cForm, "lblClientWidth", "Value", hb_ntos(This.edx.ClientWidth))

   nWorkAreaHeight := This.ClientHeight - GetProperty(cForm, "StatusBar", "Height")
   SetProperty(cForm, "lblWorkAreaHeight", "Value", hb_ntos(nWorkAreaHeight))

RETURN
