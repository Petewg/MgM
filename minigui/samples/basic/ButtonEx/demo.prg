/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * AllButtons Demo
 * (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
 * HMG 1.0 Experimental Build 9a
*/

#include "minigui.ch"


FUNCTION Main()

DEFINE WINDOW Form_1 ;
   AT 0, 0 ;
   WIDTH 458 ;
   HEIGHT 362 ;
   MAIN;
   ICON "pressit";
   TITLE 'ButtonEx Demo by Jacek Kubica <kubica@wssk.wroc.pl>'

// SET NAVIGATION EXTENDED // it works for BUTTONEX controls

DEFINE MAIN MENU

  POPUP "AllButtons"
    ITEM "Enable all buttons" ACTION EnableAllButtons()
    ITEM "Disable all buttons" ACTION DisableAllButtons()
  END POPUP

  POPUP 'Get/Set'
    ITEM 'Set new picture for button4' ACTION {|| ( Form_1.Button_4.Picture := 'clear' ) }
    ITEM 'Get picture for button4' ACTION MsgInfo( Form_1.Button_4.Picture )
    SEPARATOR
    ITEM 'Set new icon for button4i' ACTION {|| ( Form_1.Button_4i.Icon := 'res\globus.ico' ) }
    ITEM 'Get icon for button4i' ACTION MsgInfo( Form_1.Button_4i.Icon )
    SEPARATOR
    ITEM 'Set new picture for button4e' ACTION {|| ( Form_1.Button_4e.Picture := { 'clear', 'cleard' } ) }
    ITEM 'Get picture for button4e' ACTION MsgInfo( Form_1.Button_4e.Picture )
    SEPARATOR
    ITEM 'Hide OButton_3' ACTION Form_1.OButton_3.Hide
    ITEM 'Show OButton_3' ACTION Form_1.OButton_3.Show
  END POPUP

  POPUP "OwnerButton"
    ITEM "Set button text 6 to Globe" ACTION {|| ( Form_1.OButton_6.Caption := "Globe" ) }
    ITEM "Set button text 6 to an empty value" ACTION {|| ( Form_1.OButton_6.Caption := "" ) }
    SEPARATOR
    ITEM "Set OButton_6 button icon to arrow.ico" ACTION {|| ( Form_1.OButton_6.Icon := "res\arrow.ico" ) }
    ITEM "Get OButton_6 button icon  " ACTION {|| ( MsgBox( Form_1.OButton_6.Icon ) ) }
  END POPUP

END MENU


@ 190, 10 FRAME New_Buttons WIDTH 428 HEIGHT 115 CAPTION "Buttonex"

// horizontal buttonex with bitmaps (alt_syntax)

DEFINE BUTTONEX OButton_3
  ROW  135 + 35 + 40
  COL  5 + 30
  WIDTH  80
  HEIGHT 30
  CAPTION "OK"
  PICTURE "OK"
  FONTNAME "MS Sans serif"
  FONTSIZE 9
  FONTBOLD .T.
  LEFTTEXT .T.
  BACKCOLOR WHITE
END BUTTONEX

// horizontal buttonex with icon

@ 135 + 35 + 40, 5 + 82 + 30 BUTTONEX OButton_4 ;
   CAPTION "&Login"  ;
   ICON "res\keys.ico" ;
   FLAT WIDTH 80 HEIGHT 30 FONT "MS Sans serif" SIZE 9 ;
   FONTCOLOR BLUE ;
   BOLD  ;
   BACKCOLOR WHITE ;
   ACTION  {|| Tone( 800 ) }  TOOLTIP "BUTTONEX 4 with Bitmap - horizontal"


// vertical buttonex with icons

@ 135 + 40 + 35 + 35, 5 + 30 BUTTONEX OButton_1 ;
   CAPTION "&Down" ;
   ICON "res\arrow.ico" ;
   VERTICAL ;
   UPPERTEXT ;
   WIDTH 80  ;
   HEIGHT 50 ;
   FONT "MS Sans serif" ;
   SIZE 11  ;
   FONTCOLOR { 0, 128, 0 } ;
   BACKCOLOR { 240, 255, 240 } ;
   BOLD ;
   ACTION Tone( 100 ) ;
   TOOLTIP "OButton_1 BUTTONEX with icon - vertical"

// horizontal buttonex with icons

@ 135 + 40 + 35 + 35, 5 + 82 + 30 BUTTONEX OButton_2  ;
   WIDTH 80 ;
   HEIGHT 50 ;
   CAPTION "Press"  ;
   ICON "pressit" ;
   LEFTTEXT ;
   BACKCOLOR YELLOW ;
   FLAT ;
   FONT "MS Sans serif" ;
   SIZE 11  ;
   FONTCOLOR RED ;
   BOLD ;
   TOOLTIP "OButton_2 BUTTONEX with icon - horizontal - lefttext - flat" ;
   ACTION  {|| Tone( 500 ) }


// vertical buttonex ( alt_syntax )

DEFINE BUTTONEX  OButton_5
  ROW  135 + 35 + 40
  COL  5 + 82 + 82 + 10 + 30
  WIDTH  70
  HEIGHT 70
  CAPTION "Computer"
  VERTICAL .T.
  ICON   "res\comp.ico"
  FLAT .F.
  FONTNAME   "MS Sans serif"
  FONTSIZE   9
  FONTCOLOR { 0, 128, 0 }
  FONTBOLD .T.
  BACKCOLOR { 240, 255, 240 }
  UPPERTEXT .T.
  TOOLTIP "OButton_5 button with icon - vertical - uppertext - nohotlight - noxpstyle"
  NOHOTLIGHT .T.
  NOXPSTYLE .T.
END BUTTONEX

// vertical buttonex

@ 135 + 35 + 40, 5 + 82 + 82 + 72 + 10 + 30   BUTTONEX OButton_6 ;
   CAPTION "Sheep" ;
   ICON "sheep" ;
   VERTICAL ;
   FLAT ;
   WIDTH 70 ;
   HEIGHT 70 ;
   FONT "MS Sans serif" SIZE 9 ;
   FONTCOLOR { 128, 0, 0 } ;
   BOLD ;
   BACKCOLOR WHITE ;
   ACTION  {|| Tone( 600 ) } TOOLTIP "OButton_6 Image button (icon) - vertical - flat"

@ 135 + 35 + 40, 5 + 82 + 82 + 72 + 10 + 30 + 72   BUTTONEX OButton_7 ;
   CAPTION "Snail" ;
   ICON "Snail" ;
   VERTICAL ;
   WIDTH 70 ;
   HEIGHT 70 ;
   FONT "MS Sans serif" SIZE 9 ;
   FONTCOLOR { 128, 0, 0 } ;
   BOLD ;
   ACTION  {|| Tone( 600 ) } TOOLTIP "OButton_7 Image button (icon) - vertical "

@ 0, 110          Frame Frame_X  WIDTH 160 HEIGHT 190 Caption " Standard buttons "
@ 0 + 20, 135       LABEL Label1 Value "1" AUTOSIZE   TRANSPARENT
@ 0 + 20, 135 + 28    LABEL Label2 Value "2" AUTOSIZE   TRANSPARENT
@ 0 + 20, 135 + 2 * 28  LABEL Label3 Value "3" AUTOSIZE   TRANSPARENT
@ 0 + 20, 135 + 3 * 28  LABEL Label4 Value "4" AUTOSIZE   TRANSPARENT
@ 0 + 20, 135 + 4 * 28  LABEL Label5 Value "5" AUTOSIZE   TRANSPARENT




@ 0, 110 + 6 * 28          Frame Frame_X1  WIDTH 160 HEIGHT 190 Caption " ButtonEx equivalent "
@ 0 + 20, 135 + 6 * 28       LABEL Label1ex Value "1" AUTOSIZE  TRANSPARENT
@ 0 + 20, 135 + 6 * 28 + 28    LABEL Label2ex Value "2" AUTOSIZE  TRANSPARENT
@ 0 + 20, 135 + 6 * 28 + 2 * 28  LABEL Label3ex Value "3" AUTOSIZE  TRANSPARENT
@ 0 + 20, 135 + 6 * 28 + 3 * 28  LABEL Label4ex Value "4" AUTOSIZE  TRANSPARENT
@ 0 + 20, 135 + 6 * 28 + 4 * 28  LABEL Label5ex Value "5" AUTOSIZE  TRANSPARENT

// standard


@ 20 + 20, 10       LABEL Label_2 Value "Bitmaps (*.bmp) " AUTOSIZE   TRANSPARENT
@ 20 + 20, 125      BUTTON Button_1 PICTURE "strzal" WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 20 + 20, 125 + 28   BUTTON Button_2 PICTURE "close"  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 20 + 20, 125 + 2 * 28 BUTTON Button_3 PICTURE "clear"  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 20 + 20, 125 + 3 * 28 BUTTON Button_4 PICTURE "bold"   WIDTH 24 HEIGHT 20 ACTION Tone( 600 )

// altsyntax

DEFINE BUTTON ImageButton_1
  ROW   20 + 20
  COL   125 + 4 * 28
  PICTURE 'question'
  ACTION Tone( 600 )
  WIDTH 24
  HEIGHT 20
  TOOLTIP 'Alt Syntax Demo - BITMAP'
END BUTTON

// Buttonex test
@ 20 + 20, 125 + 6 * 28 BUTTONEX Button_4x1 PICTURE "strzal"   WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 20 + 20, 125 + 7 * 28 BUTTONEX Button_4x2 PICTURE "close"   WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 20 + 20, 125 + 8 * 28 BUTTONEX Button_4x3 PICTURE "clear"   WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 20 + 20, 125 + 9 * 28 BUTTONEX Button_4x4 PICTURE "bold"   WIDTH 24 HEIGHT 20 ACTION Tone( 600 )

// altsyntax

DEFINE BUTTONEX ImageButton_4x1ex
  ROW   20 + 20
  COL   125 + 10 * 28
  PICTURE 'question'
  ACTION Tone( 600 )
  WIDTH 24
  HEIGHT 20
  TOOLTIP 'Alt Syntax Demo - BITMAP'
END BUTTONEX



// icons

@ 60 + 10, 10 LABEL Label_3 Value "Icons (*.ico)" AUTOSIZE   TRANSPARENT
@ 60 + 10, 125      BUTTON Button_1i ICON "res\arrow.ico" WIDTH 24 HEIGHT 20 ACTION Tone( 600 ) TOOLTIP "Image button with icon from file arrow.ico" // from file
@ 60 + 10, 125 + 28   BUTTON Button_2i ICON "res\close.ico"  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )  TOOLTIP "Image button with icon from file close.ico"// from file
@ 60 + 10, 125 + 2 * 28 BUTTON Button_3i ICON "clearico" WIDTH 24 HEIGHT 20 ACTION Tone( 600 )  TOOLTIP "Image button with icon defined in *.rc file"     // from rc
@ 60 + 10, 125 + 3 * 28 BUTTON Button_4i ICON "boldico"  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )  TOOLTIP "Image button with icon defined in *.rc file"    // from rc

DEFINE BUTTON ImageButton_2
  ROW   60 + 10
  COL   125 + 4 * 28
  ICON 'res\arrow.ico'
  ACTION MsgInfo( 'Arrow Click!' )
  WIDTH 24
  HEIGHT 20
  TOOLTIP 'Alt Syntax Demo - ICON'
END BUTTON

// buttonex with icon w/o text

@ 60 + 10, 125 + 6 * 28 BUTTONEX Button_1ix ICON "res\arrow.ico"  WIDTH 24 HEIGHT 20 ACTION Tone( 600 ) TOOLTIP "Image button with icon from file arrow.ico" // from file
@ 60 + 10, 125 + 7 * 28 BUTTONEX Button_2ix ICON "res\close.ico"  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )  TOOLTIP "Image button with icon from file close.ico"// from file
@ 60 + 10, 125 + 8 * 28 BUTTONEX Button_3ix ICON "clearico"   WIDTH 24 HEIGHT 20 ACTION Tone( 600 )  TOOLTIP "Image button with icon defined in *.rc file"     // from rc
@ 60 + 10, 125 + 9 * 28 BUTTONEX Button_4ix ICON "boldico"    WIDTH 24 HEIGHT 20 ACTION Tone( 600 )  TOOLTIP "Image button with icon defined in *.rc file"    // from rc


DEFINE BUTTONEX ImageButton_5ix
  ROW   60 + 10
  COL   125 + 10 * 28
  ICON 'res\arrow.ico'
  ACTION MsgInfo( 'Arrow Click!' )
  WIDTH 24
  HEIGHT 20
  TOOLTIP 'Alt Syntax Demo - ICON'
END BUTTONEX


// masked bitmaps

@ 100, 10 LABEL    Label_1 Value "Masked bitmaps  " AUTOSIZE   TRANSPARENT
@ 100, 125      BUTTON Button_1e PICTURE { "strzal", "strzald" } WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 100, 125 + 28   BUTTON Button_2e PICTURE { "close", "closed" }  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 100, 125 + 2 * 28 BUTTON Button_3e PICTURE { "clear", "cleard" }  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )
@ 100, 125 + 3 * 28 BUTTON Button_4e PICTURE { "bold", "boldd" }  WIDTH 24 HEIGHT 20 ACTION Tone( 600 )

DEFINE BUTTON ImageButton_3
  ROW   100
  COL   125 + 4 * 28
  PICTURE { 'strzal', 'strzald' }
  ACTION MsgInfo( 'Arrow Click!' )
  WIDTH 24
  HEIGHT 20
  TOOLTIP 'Alt Syntax Demo - Masked Bitmap'
END BUTTON


@ 130, 10 LABEL  Label_1ST Value "Standard style  " AUTOSIZE   TRANSPARENT
@ 130, 125       BUTTON Button_3A CAPTION "OK" WIDTH 65 HEIGHT 23 FONT "MS Sans serif" SIZE 9 BOLD ACTION  {|| Tone( 600 ) } TOOLTIP "Standard button 3a"
@ 130, 125 + 65 + 5  BUTTON Button_4A CAPTION "Cancel"  WIDTH 65 HEIGHT 23 FONT "MS Sans serif" SIZE 9   ACTION  {|| Tone( 600 ) } TOOLTIP "Standard button 4a"

// standard buttons flat style

@ 160, 10 LABEL  Label_1FL Value "Flat style  " AUTOSIZE   TRANSPARENT
@ 160, 125       BUTTON Button_3AF CAPTION "OK" WIDTH 65 HEIGHT 23 FONT "MS Sans serif" SIZE 9 BOLD FLAT ACTION  {|| Tone( 600 ) } TOOLTIP "Standard button 3a"
@ 160, 125 + 65 + 5  BUTTON Button_4AF CAPTION "Cancel"  WIDTH 65 HEIGHT 23 FONT "MS Sans serif" SIZE 9  FLAT  ACTION  {|| Tone( 600 ) } TOOLTIP "Standard button 4a"

// standard-like buttonex

@ 130, 293 BUTTONEX OButton_3st CAPTION "OK"   WIDTH 65  HEIGHT 23 FONT "MS Sans serif" SIZE 9   BOLD ACTION  {|| Tone( 600 ) } TOOLTIP "OButton_3st BUTTONEX without picture"
@ 130, 293 + 65 + 5 BUTTONEX OButton_4st CAPTION "Cancel" WIDTH 65 HEIGHT 23 FONT "MS Sans serif" SIZE 9  ACTION  {|| Tone( 600 ) }  TOOLTIP "OButton_4st BUTTONEX without picture"

// standard-like buttonex flat style

@ 160,293      BUTTONEX OButton_3ofl CAPTION "OK"   WIDTH 65  HEIGHT 23 FONT "MS Sans serif" SIZE 9   BOLD  FLAT ACTION  {|| Tone( 600 ) } TOOLTIP "OButton_3st BUTTONEX without picture"
@ 160,293 + 65 + 5 BUTTONEX OButton_4ofl CAPTION "Cancel" WIDTH 65 HEIGHT 23 FONT "MS Sans serif" SIZE 9    ;
   FLAT ;
   TOOLTIP "OButton_4st BUTTONEX without picture" ;
   ACTION  {|| Tone( 100 ) }


END WINDOW

CENTER WINDOW Form_1

ACTIVATE WINDOW Form_1

RETURN NIL


FUNCTION DisableAllButtons()

LOCAL i

FOR i = 1 TO Len( _HMG_aControlType )
   IF At( "BUTTON", _HMG_aControlType[i ] ) > 0
      _DisableControl ( _HMG_aControlNames[ i ], "Form_1" )
   ENDIF
NEXT i

RETURN NIL


FUNCTION EnableAllButtons()

LOCAL i

FOR i = 1 TO Len( _HMG_aControlType )
   IF At( "BUTTON", _HMG_aControlType[i ] ) > 0
      _EnableControl ( _HMG_aControlNames[ i ], "Form_1" )
   ENDIF
NEXT i

RETURN NIL


FUNCTION test_butt()

LOCAL i

FOR i = 1 TO Len( _HMG_aControlType )
   IF At( "OBUTTON", _HMG_aControlType[i ] ) > 0
      IF ( _HMG_aControlSpacing[ i ] > 1 )
         MsgBox( Str( i ) + ": " + Str( _HMG_aControlSpacing[ i ] ) )
      ENDIF
   ENDIF
NEXT i

RETURN NIL
