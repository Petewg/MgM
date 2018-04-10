/*
* DESCRIPTION : MiniGUI sample program
*               ("playing" with controls)
* PURPOSE     : Harbour/MiniGUI
* DATE CREATED: 01/07/2004 11:19:24
* VERSION     : 0.01
* COMPILER    : Harbour Compiler at https://harbour.github.io/
* GUI LIB     : MiniGUI Library at http://harbourminigui.googlepages.com/
* EDITOR      : PSPad v.4.3.0(1971) http://www.pspad.com
* AUTHOR      : Pete Dionysopoulos - Greece
* COPYRIGHT   : (c) Pete Dionysopoulos
*               _GetArrayOfAllControlsForForm function
*               by Grigory Filatov of Ukraine. - Thanks, Grigory!
* LICENCE     : GPL - This program is free software
*               (no warranty - no obligation, do whatever you like with it
*               but at your own risk!)
*/

/*
* Revised by Grigory Filatov for HMG Extended Edition at 25/01/2008
*/

#include 'minigui.ch'

/******************************************************************************/
FUNCTION Main()
/******************************************************************************/
SET DATE FRENCH

LOAD WINDOW TestForm AS AppWin
CENTER WINDOW AppWin
ACTIVATE WINDOW AppWin

RETURN NIL

/******************************************************************************/
FUNCTION showControls( cForm )
/******************************************************************************/
LOCAL aCtrls := _GetArrayOfAllControlsForForm ( cForm )
LOCAL nI, xVal
LOCAL aEle
LOCAL CtrlName

LOAD WINDOW Ctrl_Form AS Ctrls
Ctrls.Grid_1.DeleteAllItems
FOR nI := 1 TO Len( aCtrls )
   aEle := {}
   CtrlName := aCTrls[ nI ]
   AAdd( aEle, CtrlName )
   xVal := GetProperty( "AppWin", CtrlName, "value" )
   AAdd( aEle, xChar( xVal ) )
   Ctrls.Grid_1.AddItem( aEle )
NEXT

CENTER WINDOW Ctrls
ACTIVATE WINDOW Ctrls

RETURN NIL

/******************************************************************************/
FUNCTION EnableDisableCtrls( cFormName )
/******************************************************************************/
LOCAL aCtrls := _GetArrayOfAllControlsForForm ( cFormName )
LOCAL nI, lOnOff, cCtrlName

lOnOff := ( GetProperty( cFormName, 'Button_3', "caption" ) == 'Enable controls' )
IF !lOnOff
   FOR nI := 1 TO Len( aCtrls )
      cCtrlName := aCTrls[ nI ]
      SetProperty( cFormName, cCtrlName, "enabled", .F. )
   NEXT
   SetProperty( cFormName, 'Button_3', "enabled", .T. )
   SetProperty( cFormName, 'Button_3', "caption", 'Enable controls' )
ELSE
   FOR nI := 1 TO Len( aCtrls )
      cCtrlName := aCTrls[ nI ]
      SetProperty( cFormName, cCtrlName, "enabled", .T. )
   NEXT
   SetProperty( cFormName, 'Button_3', "caption", 'Disable controls' )
ENDIF

RETURN NIL

/******************************************************************************/
FUNCTION _GetArrayOfAllControlsForForm ( cFormName )
/******************************************************************************/
LOCAL nFormHandle, i, nControlCount, aRetVal := {}, x

nFormHandle := GetFormHandle ( cFormName )
nControlCount := Len ( _HMG_aControlHandles )
FOR i := 1 TO nControlCount
   IF _HMG_aControlParentHandles[ i ] == nFormHandle
      IF ValType( _HMG_aControlHandles[ i ] ) == 'N'
         IF ! Empty( _HMG_aControlNames[ i ] )
            IF AScan( aRetVal, _HMG_aControlNames[ i ] ) == 0
               AAdd( aRetVal, _HMG_aControlNames[ i ] )
            ENDIF
         ENDIF
      ELSEIF ValType( _HMG_aControlHandles[i ] ) == 'A'
         FOR x := 1 TO Len ( _HMG_aControlHandles[ i ] )
            IF !Empty( _HMG_aControlNames[ i ] )
               IF AScan( aRetVal, _HMG_aControlNames[ i ] ) == 0
                  AAdd( aRetVal, _HMG_aControlNames[i ] )
               ENDIF
            ENDIF
         NEXT x
      ENDIF
   ENDIF
NEXT i

RETURN ASort( aRetVal )
