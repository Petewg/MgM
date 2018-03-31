/*
   HotKey Demo - HMG internal hotkeys processing
   Author: Pablo César Arrascaeta
   Date: March 28, 2017
   Version: 1.0
*/

#include "hmg.ch"

MEMVAR aOriginalKeys

FUNCTION Main()

   Load Window Demo

   ON KEY ALT+C OF Demo ACTION MsgInfo ( 'ALT+C' )
   ON KEY ALT+D OF Demo ACTION MsgInfo ( 'ALT+D' )

   PRIVATE aOriginalKeys := GetAllHotKeysActions()

   Demo.Center
   Demo.Activate

RETURN NIL


FUNCTION ShowAllActiveHotKeys( cParentForm )

   LOCAL i, n, nParentFormHandle, nControlCount, aRet := {}, cTemp := ""
   LOCAL aMods := { "Alt", "Control", "", "Shift", "", "", "", "Win" }
   LOCAL anKeys := {  8,  9, 13, 27, 35, 36, 37, 38, 39, 40, 45, 46, 33, 34, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, ;
      65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, ;
      89, 90, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123 }
   LOCAL acKeys := { "BACK", "TAB", "RETURN", "ESCAPE", "END", "HOME", "LEFT", "UP", "RIGHT", "DOWN", "INSERT", "DELETE", "PRIOR", "NEXT", ;
      "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", ;
      "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12" }

   nParentFormHandle := GetFormhandle ( cParentForm )
   nControlCount := Len ( _HMG_aControlHandles )

   FOR i := 1 TO nControlCount
      IF _HMG_aControlType[ i ] == 'HOTKEY' .AND. _HMG_aControlParentHandles[ i ] == nParentFormHandle
         cTemp := aMods[ _HMG_aControlPageMap[ i ] ]
         IF !Empty( cTemp )
            cTemp += "+"
         ENDIF
         n := AScan( anKeys, _HMG_aControlValue[ i ] )
         IF n = 0
            MsgStop( "Key number not found!", "Identify & add it" )
            LOOP
         ENDIF
         cTemp += acKeys[ n ]
         AAdd( aRet, cTemp )
      ENDIF
   NEXT i

RETURN aRet


FUNCTION ReleaseAllActiveHotKeys( cParentForm )

   LOCAL i, nParentFormHandle, nControlCount, z

   nParentFormHandle := GetFormhandle ( cParentForm )
   nControlCount := Len ( _HMG_aControlHandles )
   z := GetFormIndex ( cParentForm )

   FOR i := 1 TO nControlCount
      IF _HMG_aControlType[ i ] == 'HOTKEY' .AND. _HMG_aControlParentHandles[ i ] == nParentFormHandle
         _EraseControl( i, z )
      ENDIF
   NEXT i

RETURN NIL


FUNCTION GetAllHotKeysActions()

   LOCAL i, aRet := {}
   LOCAL nControlCount := Len ( _HMG_aControlHandles )

   FOR i := 1 TO nControlCount
      IF _HMG_aControlType[ i ] == 'HOTKEY'
         AAdd( aRet, { _HMG_aControlParentHandles[ i ], _HMG_aControlPageMap[ i ], _HMG_aControlValue[ i ], _HMG_aControlProcedures[ i ] } )
      ENDIF
   NEXT i

RETURN aRet


FUNCTION RestoreAllHotKeysActions()

   LOCAL i, cFName, nIndexForm
   LOCAL nLen := Len( aOriginalKeys )

   FOR i := 1 TO nLen
      nIndexForm := GetFormIndexByHandle( aOriginalKeys[ i, 1 ] )
      IF nIndexForm > 0
         cFName := GetFormNameByIndex( nIndexForm )
         IF _IsWindowDefined( cFName )
            // _DefineHotKey ( cParentForm , nMod , nKey , bAction )
            _DefineHotKey( cFName, aOriginalKeys[ i, 2 ], aOriginalKeys[ i, 3 ], aOriginalKeys[ i, 4 ] )
         ENDIF
      ENDIF
   NEXT i

RETURN NIL
