/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2017, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#include 'minigui.ch'

*-----------------------------------------------------------------------------*
FUNCTION _DefineHotKey ( cParentForm , nMod , nKey , bAction )
*-----------------------------------------------------------------------------*
   LOCAL nParentForm , nId , k , lSuccess
// BK 22-Apr-2012
   IF _HMG_BeginWindowMDIActive .AND. Empty( _HMG_ActiveFormName )  //JP MDI HotKey
      nParentForm := GetActiveMdiHandle()
      IF nParentForm == 0
         cParentForm := _HMG_MainClientMDIName
      ELSE
         cParentForm := _GetWindowProperty ( nParentForm, "PROP_FORMNAME" )
      ENDIF                                                         //End JP
   ELSEIF _HMG_BeginWindowActive
      cParentForm := _HMG_ActiveFormName
   ENDIF

   IF ValType ( cParentForm ) == 'U'
      MsgMiniGuiError ( "ON KEY: Parent Window is Not specified." )
   ENDIF

// Check if the window/form is defined.
   IF .NOT. _IsWindowDefined( cParentForm )
      MsgMiniGuiError( "Window " + cParentForm + " is not defined." )
   ENDIF

   _ReleaseHotKey ( cParentForm, nMod , nKey )
// BK 22-Apr-2012
   IF _HMG_BeginWindowMDIActive .AND. Empty( _HMG_ActiveFormName )  //JP MDI HotKey
      nParentForm := GetActiveMdiHandle()
      IF nParentForm == 0
         nParentForm := GetFormHandle ( cParentForm )
      ENDIF                                                         //End JP
   ELSE
      nParentForm := GetFormHandle ( cParentForm )
   ENDIF

   nId := _GetId( 49151 )

   lSuccess := InitHotKey ( nParentForm , nMod , nKey , nId )

   k := _GetControlFree()

   _HMG_aControlType [k] :=  "HOTKEY"
   _HMG_aControlNames  [k] :=  ''
   _HMG_aControlHandles  [k] :=  0
   _HMG_aControlParentHandles  [k] :=  nParentForm
   _HMG_aControlIds  [k] :=  nId
   _HMG_aControlProcedures  [k] :=  bAction
   _HMG_aControlPageMap  [k] :=  nMod
   _HMG_aControlValue  [k] :=  nKey
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure   [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  Nil
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick   [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  0
   _HMG_aControlCol   [k] :=  0
   _HMG_aControlWidth  [k] :=  0
   _HMG_aControlHeight  [k] :=  0
   _HMG_aControlSpacing   [k] :=  0
   _HMG_aControlContainerRow  [k] :=  0
   _HMG_aControlContainerCol   [k] :=  0
   _HMG_aControlPicture   [k] :=  ""
   _HMG_aControlContainerHandle   [k] :=  0
   _HMG_aControlFontName   [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip   [k] :=  ''
   _HMG_aControlRangeMin   [k] :=  0
   _HMG_aControlRangeMax   [k] :=  0
   _HMG_aControlCaption   [k] :=  ''
   _HMG_aControlVisible   [k] :=  .T.
   _HMG_aControlHelpId  [k] :=  0
   _HMG_aControlFontHandle  [k] :=  0
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

RETURN lSuccess

#ifndef __XHARBOUR__
   /* FOR EACH hb_enumIndex() */
   #xtranslate hb_enumIndex( <!v!> ) => <v>:__enumIndex()
#endif
*-----------------------------------------------------------------------------*
PROCEDURE _ReleaseHotKey ( cParentForm, nMod , nKey )
*-----------------------------------------------------------------------------*
   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i , ControlType

   FOR EACH ControlType IN _HMG_aControlType
      i := hb_enumindex( ControlType )
      IF ControlType == 'HOTKEY' .AND. _HMG_aControlParentHandles [i] == nParentFormHandle .AND. _HMG_aControlPageMap [i] == nMod .AND. _HMG_aControlValue [i] == nKey
         _EraseControl( i, GetFormIndex ( cParentForm ) )
         EXIT
      ENDIF
   NEXT

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _GetHotKeyBlock ( cParentForm, nMod, nKey )
*-----------------------------------------------------------------------------*
   LOCAL bRetVal := Nil
   LOCAL nParentFormHandle := GetFormHandle ( cParentForm )
   LOCAL i , ControlType

   FOR EACH ControlType IN _HMG_aControlType
      i := hb_enumindex( ControlType )
      IF ControlType == 'HOTKEY' .AND. _HMG_aControlParentHandles [i] == nParentFormHandle .AND. _HMG_aControlPageMap [i] == nMod .AND. _HMG_aControlValue [i] == nKey
         bRetVal := _HMG_aControlProcedures [i]
         EXIT
      ENDIF
   NEXT

RETURN ( bRetVal )

*-----------------------------------------------------------------------------*
PROCEDURE _PushKey ( nKey )
*-----------------------------------------------------------------------------*

   Keybd_Event ( nKey, .F. )
   Keybd_Event ( nKey, .T. )

RETURN

#ifdef _HMG_COMPAT_  // HMG_PressKey( nVK1, nVK2, ... ) --> array { nVK1, nVK2, ... }
*-----------------------------------------------------------------------------*
FUNCTION HMG_PressKey( ... )  // by Dr. Claudio Soto, April 2016
*-----------------------------------------------------------------------------*
   LOCAL i, aVK := {}

   FOR i := 1 TO PCount()
      IF ValType( PValue( i ) ) == "N"
         AADD( aVK, PValue( i ) )
      ELSE
         LOOP
      ENDIF
      Keybd_Event( aVK[ i ], .F. )   // KeyDown
   NEXT

   FOR i := Len( aVK ) TO 1 STEP -1
      Keybd_Event( aVK[ i ], .T. )   // KeyUp
   NEXT

RETURN aVK

#endif
*-----------------------------------------------------------------------------*
FUNCTION _SetHotKeyByName ( cParentForm, cKey, bAction )
*-----------------------------------------------------------------------------*
   LOCAL aKey , lSuccess := .F.

   IF _HMG_BeginWindowActive
      cParentForm := _HMG_ActiveFormName
   ENDIF
   IF Empty ( cParentForm )
      MsgMiniGuiError ( "ON KEY: Parent Window is Not specified." )
   ENDIF

   IF !Empty ( cKey ) .AND. ISCHARACTER ( cKey )
      aKey := _DetermineKey ( cKey )
      IF aKey [1] != 0
         IF ValType ( _GetHotKeyBlock ( cParentForm, aKey [2], aKey [1] ) ) == "B"
            MsgMiniGuiError ( "Hotkey " + cKey + " Already defined." )
         ENDIF
         lSuccess := _DefineHotKey ( cParentForm, aKey [2], aKey [1], bAction )
      ELSE
         MsgMiniGuiError ( "Hotkey " + cKey + " is not valid." )
      ENDIF
   ENDIF

RETURN lSuccess

*-----------------------------------------------------------------------------*
FUNCTION _DetermineKey ( cKey )
*-----------------------------------------------------------------------------*
   LOCAL aKey, nAlt, nCtrl, nShift, nWin, nPos, cKey2, cText
   STATIC aKeyTables := { "LBUTTON", "RBUTTON", "CANCEL", "MBUTTON", "XBUTTON1", "XBUTTON2", ".7", "BACK", "TAB", ".10", ;
      ".11", "CLEAR", "RETURN", ".14", ".15", "SHIFT", "CONTROL", "MENU", "PAUSE", "CAPITAL", ;
      "KANA", ".22", "JUNJA", "FINAL", "HANJA", ".26", "ESCAPE", "CONVERT", "NONCONVERT", "ACCEPT", ;
      "MODECHANGE", "SPACE", "PRIOR", "NEXT", "END", "HOME", "LEFT", "UP", "RIGHT", "DOWN", ;
      "SELECT", "PRINT", "EXECUTE", "SNAPSHOT", "INSERT", "DELETE", "HELP", "0", "1", "2", ;
      "3", "4", "5", "6", "7", "8", "9", ".58", ".59", ".60", ;
      ".61", ".62", ".63", ".64", "A", "B", "C", "D", "E", "F", ;
      "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", ;
      "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", ;
      "LWIN", "RWIN", "APPS", ".94", "SLEEP", "NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", ;
      "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "MULTIPLY", "ADD", "SEPARATOR", "SUBTRACT", "DECIMAL", ;
      "DIVIDE", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", ;
      "F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19", ;
      "F20", "F21", "F22", "F23", "F24", ".136", ".137", ".138", ".139", ".140", ;
      ".141", ".142", ".143", "NUMLOCK", "SCROLL", ".146", ".147", ".148", ".149", ".150", ;
      ".151", ".152", ".153", ".154", ".155", ".156", ".157", ".158", ".159", "LSHIFT", ;
      "RSHIFT", "LCONTROL", "RCONTROL", "LMENU", "RMENU" } // 165
   aKey := { 0, 0 }
   nAlt := nCtrl := nShift := nWin := 0
   cKey2 := Upper ( cKey )
   DO WHILE !Empty ( cKey2 )
      nPos := At( "+", cKey2 )
      IF nPos == 0
         cKey2 := AllTrim ( cKey2 )
         nPos := AScan ( aKeyTables, { |c| cKey2 == c } )
         cKey2 := ""
         IF nPos != 0
            aKey := { nPos, nAlt + nCtrl + nShift + nWin }
         ENDIF
      ELSE
         cText := AllTrim ( Left( cKey2, nPos - 1 ) )
         cKey2 := SubStr ( cKey2, nPos + 1 )
         IF cText == "ALT"
            nAlt := MOD_ALT
         ELSEIF cText == "CTRL" .OR. cText == "CONTROL"
            nCtrl := MOD_CONTROL
         ELSEIF cText == "SHIFT" .OR. cText == "SHFT"
            nShift := MOD_SHIFT
         ELSEIF cText == "WIN"
            nWin := MOD_WIN
         ELSE
            cKey2 := ""  // Invalid keyword
         ENDIF
      ENDIF
   ENDDO

RETURN aKey
