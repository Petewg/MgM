/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Explore Windows Objects'
#define VERSION ' 1.0'
#define COPYRIGHT ' 2006 Grigory Filatov'

PROCEDURE Main

   // Define objects paths array
   LOCAL aCombo := {}, aCLSIDs := {}

   AAdd( aCombo, "My Computer" )
   AAdd( aCLSIDs, "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" )
   AAdd( aCombo, "Control Panel" )
   AAdd( aCLSIDs, aCLSIDs[ 1 ] + "\::{21EC2020-3AEA-1069-A2DD-08002B30309D}" )
   IF IsWinNT()
      AAdd( aCombo, "Printers and telecopiers" )
      AAdd( aCLSIDs, aCLSIDs[ 2 ] + "\::{2227A280-3AEA-1069-A2DE-08002B30309D}" )
      AAdd( aCombo, "Fonts" )
      AAdd( aCLSIDs, aCLSIDs[ 2 ] + "\::{D20EA4E1-3957-11d2-A40B-0C5020524152}" )
      AAdd( aCombo, "Scanners and cameras" )
      AAdd( aCLSIDs, aCLSIDs[ 2 ] + "\::{E211B736-43FD-11D1-9EFB-0000F8757FCD}" )
      AAdd( aCombo, "Networkhood" )
      AAdd( aCLSIDs, aCLSIDs[ 2 ] + "\::{7007ACC7-3202-11D1-AAD2-00805FC1270E}" )
      AAdd( aCombo, "Administration tools" )
      AAdd( aCLSIDs, aCLSIDs[ 2 ] + "\::{D20EA4E1-3957-11d2-A40B-0C5020524153}" )
      AAdd( aCombo, "Tasks Scheduler" )
      AAdd( aCLSIDs, aCLSIDs[ 2 ] + "\::{D6277990-4C6A-11CF-8D87-00AA0060F5BF}" )
   ENDIF
   AAdd( aCombo, "Web folders" )
   AAdd( aCLSIDs, aCLSIDs[ 1 ] + "\::{BDEADF00-C265-11D0-BCED-00A0C90AB50F}" )
   AAdd( aCombo, "My Documents" )
   AAdd( aCLSIDs, "{450D8FBA-AD25-11D0-98A8-0800361B1103}" )
   AAdd( aCombo, "Recycle Bin" )
   AAdd( aCLSIDs, "{645FF040-5081-101B-9F08-00AA002F954E}" )
   AAdd( aCombo, "Network favorites" )
   AAdd( aCLSIDs, "{208D2C60-3AEA-1069-A2D7-08002B30309D}" )
   AAdd( aCombo, "Default Navigator" )
   AAdd( aCLSIDs, "{871C5380-42A0-1069-A2EA-08002B30309D}" )
   IF IsWinNT()
      AAdd( aCombo, "Results of Computers research" )
      AAdd( aCLSIDs, "{1F4DE370-D627-11D1-BA4F-00A0C91EEDBA}" )
      AAdd( aCombo, "Results of files research" )
      AAdd( aCLSIDs, "{E17D4FC0-5564-11D1-83F2-00A0C90DC849}" )
   ENDIF

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 338 ;
      HEIGHT 153 - IF( IsXPThemeActive(), 0, 6 ) ;
      TITLE PROGRAM + VERSION ;
      ICON "MAIN" ;
      MAIN ;
      NOMAXIMIZE NOMINIMIZE NOSIZE ;
      ON PAINT ONPaint() ;
      FONT 'MS Sans Serif' SIZE 9

   @ 90, 223 BUTTON Button_1 ;
      CAPTION 'Quit' ;
      ACTION ThisWindow.Release ;
      WIDTH 98 ;
      HEIGHT 23 DEFAULT

   @ 12, 12 BUTTON Button_2 ;
      CAPTION 'GO TO --->' ;
      ACTION ExploreWinObjects( aCLSIDs[ Form_1.Combo_1.Value ], Form_1.Check_1.Value, Form_1.Check_2.Value ) ;
      WIDTH 98 ;
      HEIGHT 21

   @ 12, 118 COMBOBOX Combo_1 ;
      WIDTH 204 ;
      ITEMS aCombo ;
      VALUE 1 ;
      ON ENTER ExploreWinObjects( aCLSIDs[ Form_1.Combo_1.Value ], Form_1.Check_1.Value, Form_1.Check_2.Value )

   @ 39, 12 CHECKBOX Check_1 ;
      CAPTION "Don't show left Explorer pane" ;
      WIDTH 160 ;
      HEIGHT 21 ;
      VALUE .F.

   @ 60, 12 CHECKBOX Check_2 ;
      CAPTION "Start Exploring at the object root" ;
      WIDTH 170 ;
      HEIGHT 21 ;
      VALUE .F.

   @ 48, 289 LABEL Label_1 ;
      VALUE 'EXP' ;
      WIDTH 32 ;
      HEIGHT 28 ;
      FONT 'Tahoma' SIZE 12 BOLD ;
      FONTCOLOR GRAY TRANSPARENT RIGHTALIGN

   @ 92, 12 LABEL Label_2 ;
      VALUE 'Copyright ' + Chr( 169 ) + COPYRIGHT ;
      WIDTH 160 ;
      HEIGHT 21

   ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   Form_1.Label_2.Enabled := .F.

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN


STATIC PROCEDURE ExploreWinObjects( cObject, lDoNotShowLeftPane, lStartExplAtRoot )

   ShellExecute( _HMG_MainHandle, "open", GetWindowsFolder() + '\Explorer.exe', ;
      IF( lDoNotShowLeftPane, "/N", "/E" ) + "," + IF( lStartExplAtRoot, "/Root,", "" ) + ;
      "::" + cObject, , 1 )

RETURN


STATIC PROCEDURE OnPaint()

   DRAW LINE IN WINDOW Form_1 ;
      AT 85, 0 TO 85, 332 ;
      PENCOLOR WHITE

   DRAW LINE IN WINDOW Form_1 ;
      AT 84, 331 TO 84, 333 ;
      PENCOLOR WHITE

   DRAW LINE IN WINDOW Form_1 ;
      AT 84, 0 TO 84, 331 ;
      PENCOLOR GRAY

RETURN
