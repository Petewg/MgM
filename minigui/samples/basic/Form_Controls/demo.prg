/*
* DESCRIPTION : MiniGUI sample program 
*               ("playing" with controls)
* PURPOSE     : Harbour/MiniGUI Experiment(al)
* DATE CREATED: 01/07/2004 11:19:24
* VERSION     : 0.01
* COMPILER    : Harbour Compiler Alpha at http://harbour-project.org/
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
function main()
/******************************************************************************/
set date french
load window TestForm as AppWin
center window AppWin
activate window AppWin
return nil

/******************************************************************************/
function showControls( cForm )
/******************************************************************************/
local aCtrls := _GetArrayOfAllControlsForForm ( cForm )
local nI, xVal
local aEle :={}
local CtrlName

load window Ctrl_Form as Ctrls
Ctrls.Grid_1.DeleteAllItems 
for nI := 1 to len( aCtrls )
   aEle := {}
   CtrlName := aCTrls[nI]
   aadd(aEle, CtrlName)
   xVal := GetProperty( "AppWin", CtrlName, "value" )
   aadd(aEle, xChar( xVal ))
   Ctrls.Grid_1.AddItem( aEle )
next

center window Ctrls
activate window Ctrls
return nil

/******************************************************************************/
function EnableDisableCtrls( cFormName )
/******************************************************************************/
local aCtrls := _GetArrayOfAllControlsForForm ( cFormName )
local nI, lOnOff, cCtrlName

lOnOff := ( GetProperty( cFormName, 'Button_3', "caption" ) == 'Enable controls' )
if !lOnOff
   for nI := 1 to len( aCtrls )
      cCtrlName := aCTrls[nI]
      SetProperty( cFormName, cCtrlName, "enabled", .f. )
   next
   SetProperty( cFormName, 'Button_3', "enabled", .t. )
   SetProperty( cFormName, 'Button_3', "caption", 'Enable controls' )
else
   for nI := 1 to len( aCtrls )
      cCtrlName := aCTrls[nI]
      SetProperty( cFormName, cCtrlName, "enabled", .t. )
   next
   SetProperty( cFormName, 'Button_3', "caption", 'Disable controls' )
endif
return nil

/******************************************************************************/
Function _GetArrayOfAllControlsForForm ( cFormName )
/******************************************************************************/
Local nFormHandle , i , nControlCount , aRetVal := {} , x

nFormHandle := GetFormHandle ( cFormName )
nControlCount := Len ( _HMG_aControlHandles )
For i := 1 To nControlCount
   If _HMG_aControlParentHandles[i] == nFormHandle
      If ValType( _HMG_aControlHandles[i] ) == 'N'
         IF ! Empty( _HMG_aControlNames[i] )
            If Ascan( aRetVal, _HMG_aControlNames[i] ) == 0
               Aadd( aRetVal, _HMG_aControlNames[i] )
            EndIf
         ENDIF
      ElseIf ValType( _HMG_aControlHandles [i] ) == 'A'
         For x := 1 To Len ( _HMG_aControlHandles[i] )
            IF !Empty( _HMG_aControlNames[i] )
               If Ascan( aRetVal, _HMG_aControlNames[i] ) == 0
                  Aadd( aRetVal, _HMG_aControlNames [i] )
               EndIf
            ENDIF
         Next x
      EndIf
   EndIf
Next i
Return Asort( aRetVal )
