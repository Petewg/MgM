/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * HMG HOTKEYBOX demo
 * (C) 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

STATIC nKey := 0, nModif := 0

// -----------------------------
PROCEDURE Main
// -----------------------------
   LOCAL Key := 0

   BEGIN INI FILE "demo.ini"
      GET Key SECTION "Save" ENTRY "HotKey"
   END INI

   DEFINE WINDOW Form_Main ;
      AT 0, 0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'HotKeyBox Demo (Contributed by Grigory Filatov)' ;
      MAIN ;
      ON RELEASE SaveHotKey()

   @ 20, 200 HOTKEYBOX HotKey_1 ;
      VALUE Key ;
      WIDTH 120 HEIGHT 21 ;
      FONT 'Tahoma' SIZE 9 ;
      TOOLTIP "HotkeyBox Control 1" ;
      ON CHANGE AddText( GetHotKeyName( HotKey_1, Form_Main ) )

   @ 20, 20 EDITBOX Editbox_1 VALUE "" WIDTH 150 HEIGHT 400

   @ 60, 200 BUTTON btn_1 CAPTION "Set HotKey" ACTION SetNewHotKey()

   @ 20, 330 BUTTON btn_2 CAPTION "Default" ;
      WIDTH 80 HEIGHT 22 ;
      ACTION ( Form_Main.HotKey_1.Value := 833, SetNewHotKey() )  // Ctrl+Shift+A

   @ 20, 420 BUTTON btn_3 CAPTION "Press Default key" ;
      WIDTH 120 HEIGHT 22 ;
      ACTION HMG_PressKey( VK_CONTROL, VK_SHIFT, VK_A )

   END WINDOW

   IF !Empty( Key )
      SetNewHotKey()
   ENDIF

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

RETURN

// -----------------------------
FUNCTION SaveHotKey()
// -----------------------------
   LOCAL Key := Form_Main .HotKey_1. Value

   BEGIN INI FILE "demo.ini"
      SET SECTION "Save" ENTRY "HotKey" TO Key
   END INI

RETURN NIL

// -----------------------------
FUNCTION AddText( t )
// -----------------------------
   LOCAL a := Form_Main .Editbox_1. Value

   a += t + CRLF
   Form_Main .Editbox_1. Value := a

RETURN NIL

// -----------------------------
FUNCTION SetNewHotKey()
// -----------------------------
   LOCAL cKeyName
   LOCAL aKey := GetHotKeyValue( HotKey_1, Form_Main )

   IF !Empty( nKey )
      _ReleaseHotKey( "Form_Main", nModif, nKey )
   ENDIF

   nKey := aKey[ 1 ]
   nModif := aKey[ 2 ]
   cKeyName := GetHotKeyName( HotKey_1, Form_Main )

   _DefineHotKey( "Form_Main", nModif, nKey, {|| MsgInfo( StrTran( cKeyName, " ", "" ) + " is pressed" ) } )

RETURN NIL
