/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
      AT 0, 0 WIDTH 458 HEIGHT 362 ;
      MAIN ;
      ICON "pressit" TITLE 'ButtonEx with color gradient background'

   DEFINE MAIN MENU
      POPUP "AllButtons"
        ITEM "Enable all buttons" ACTION EnableAllButtons()
        ITEM "Disable all buttons" ACTION DisableAllButtons()
      END POPUP

      POPUP "OwnerButton"
        ITEM "Set button text 6 to Globe" ACTION {|| Form_1.OButton_6.Caption := "Globe" }
        ITEM "Set button text 6 to an empty value" ACTION {|| Form_1.OButton_6.Caption := "" }
        SEPARATOR
        ITEM "Set OButton_6 button icon to arrow.ico" ACTION {|| Form_1.OButton_6.Icon := "res\arrow.ico" }
        ITEM "Get OButton_6 button icon  " ACTION {|| MsgBox( Form_1.OButton_6.Icon ) }
      END POPUP
   END MENU

   @ 10, 35 BUTTONEX OButton_1 ;
      CAPTION "&Down" ;
      ICON "res\arrow.ico" ;
      VERTICAL ;
      UPPERTEXT ;
      WIDTH 80  ;
      HEIGHT 80 ;
      FONT "MS Sans serif" ;
      SIZE 11 ;
      FONTCOLOR { 0, 128, 0 } ;
      BACKCOLOR { { 1, { 203, 225, 252 }, { 126, 166, 225 } } } ;
      GRADIENTFILL { { 1, RGB( 251, 230, 148 ), RGB( 239, 150, 21 ) } } ;
      BOLD ;
      ACTION Tone( 100 ) ;
      TOOLTIP "OButton_1 BUTTONEX with icon - vertical"

   @ 10, 130 BUTTONEX OButton_2 ;
      WIDTH 80 ;
      HEIGHT 80 ;
      CAPTION "Press"  ;
      ICON "pressit" ;
      LEFTTEXT ;
      FONTCOLOR RED ;
      BACKCOLOR { { 1, { 203, 225, 252 }, { 126, 166, 225 } } } ;
      GRADIENTFILL { { 1, RGB( 251, 230, 148 ), RGB( 239, 150, 21 ) } } ;
      FLAT ;
      FONT "MS Sans serif" ;
      SIZE 11 ;
      BOLD ;
      TOOLTIP "OButton_2 BUTTONEX with icon - horizontal - lefttext - flat" ;
      ACTION  {|| Tone( 500 ) }

   DEFINE BUTTONEX OButton_3
      ROW  160
      COL  35
      WIDTH  80
      HEIGHT 30
      CAPTION "OK"
      PICTURE "OK"
      FONTNAME "MS Sans serif"
      FONTSIZE 9
      FONTBOLD .T.
      LEFTTEXT .T.
      BACKCOLOR { 222, 227, 233 }
      GRADIENTFILL { { 0.5, RGB( 222, 227, 233 ), RGB( 209, 213, 222 ) }, ;
         { 0.5, RGB( 209, 213, 222 ), RGB( 222, 227, 233 ) } }
      TOOLTIP "OButton_3 BUTTONEX with Bitmap - horizontal - lefttext"
   END BUTTONEX

   @ 160, 130 BUTTONEX OButton_4 ;
      CAPTION "&Login"  ;
      ICON "res\keys.ico" ;
      FLAT WIDTH 80 HEIGHT 30 FONT "MS Sans serif" SIZE 9 ;
      FONTCOLOR BLUE ;
      BOLD ;
      BACKCOLOR { 222, 227, 233 } ;
      GRADIENTFILL { { 0.5, RGB( 222, 227, 233 ), RGB( 209, 213, 222 ) }, ;
         { 0.5, RGB( 209, 213, 222 ), RGB( 222, 227, 233 ) } } ;
      ACTION  {|| Tone( 800 ) } ;
      TOOLTIP "OButton_4 BUTTONEX with Bitmap - horizontal"

   DEFINE BUTTONEX  OButton_5
      ROW  10
      COL  225
      WIDTH  80
      HEIGHT 80
      CAPTION "Computer"
      VERTICAL .T.
      ICON "res\comp.ico"
      FLAT .F.
      FONTNAME  "MS Sans serif"
      FONTSIZE  9
      FONTCOLOR { 0, 128, 0 }
      FONTBOLD .T.
      BACKCOLOR { { 1, { 203, 225, 252 }, { 126, 166, 225 } } }
      GRADIENTFILL { { 1, RGB( 251, 230, 148 ), RGB( 239, 150, 21 ) } }
      UPPERTEXT .T.
      TOOLTIP "OButton_5 button with icon - vertical - uppertext - nohotlight"
      NOHOTLIGHT .F.
   END BUTTONEX

   @ 10, 320  BUTTONEX OButton_6 ;
      CAPTION "Sheep" ;
      ICON "sheep" ;
      VERTICAL ;
      FLAT ;
      WIDTH 80 ;
      HEIGHT 80 ;
      FONT "MS Sans serif" SIZE 9 ;
      FONTCOLOR { 128, 0, 0 } ;
      BOLD ;
      BACKCOLOR { { 1, { 203, 225, 252 }, { 126, 166, 225 } } } ;
      GRADIENTFILL { { 1, RGB( 251, 230, 148 ), RGB( 239, 150, 21 ) } } ;
      ACTION  {|| Tone( 600 ) } TOOLTIP "OButton_6 Image button (icon) - vertical - flat"

   @ 110, 225 BUTTONEX OButton_7 ;
      CAPTION "Snail" ;
      ICON "Snail" ;
      VERTICAL ;
      FLAT ;
      WIDTH 80 + iif( IsThemed(), 2, 0 ) ;
      HEIGHT 80 + iif( IsThemed(), 1, 0 ) ;
      FONT "MS Sans serif" SIZE 9 ;
      FONTCOLOR { 128, 0, 0 } ;
      BOLD ;
      ACTION  {|| Tone( 600 ) } TOOLTIP "OButton_7 Image button (icon) - vertical - flat"

   @ 110, 320 BUTTONEX OButton_8 ;
      CAPTION "Snail" ;
      ICON "Snail" ;
      VERTICAL ;
      FLAT ;
      WIDTH 80 ;
      HEIGHT 80 ;
      FONT "MS Sans serif" SIZE 9 ;
      FONTCOLOR { 128, 0, 0 } ;
      BACKCOLOR { { 0.58, { 229, 244, 252 }, { 196, 229, 246 } }, ;
         { 0.42, { 152, 209, 239 }, { 114, 185, 223 } } } ;
      GRADIENTFILL { { 0.5, { 242, 242, 242 }, { 235, 235, 235 } }, ;
         { 0.5, { 222, 222, 222 }, { 210, 210, 210 } } } ;
      BOLD ;
      ACTION  {|| Tone( 600 ) } TOOLTIP "OButton_8 Image button (icon) - vertical - flat"

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION DisableAllButtons()

   LOCAL i

   FOR i = 1 TO Len( _HMG_aControlType )
      IF At( "BUTTON", _HMG_aControlType[ i ] ) > 0
         _DisableControl ( _HMG_aControlNames[ i ], "Form_1" )
      ENDIF
   NEXT i

RETURN NIL

FUNCTION EnableAllButtons()

   LOCAL i

   FOR i = 1 TO Len( _HMG_aControlType )
      IF At( "BUTTON", _HMG_aControlType[ i ] ) > 0
         _EnableControl ( _HMG_aControlNames[ i ], "Form_1" )
      ENDIF
   NEXT i

RETURN NIL
