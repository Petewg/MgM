/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
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
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - https://harbour.github.io

	"Harbour Project"
	Copyright 1999-2018, https://harbour.github.io/
---------------------------------------------------------------------------*/

#include "minigui.ch"
#define WS_BORDER           0x00800000
*-----------------------------------------------------------------------------*
Function _DefineQhtm ( ControlName, ParentForm, x, y, w, h, Value, fname, resname, Change, lBorder, nId )
*-----------------------------------------------------------------------------*
Local mVar, k := 0
Local ControlHandle, FontHandle

	if _HMG_BeginWindowActive = .T.
		ParentForm := _HMG_ActiveFormName
	endif

	If .Not. _IsWindowDefined (ParentForm)
		MsgMiniGuiError("Window: "+ ParentForm + " is not defined. Program terminated" )
	Endif

	If _IsControlDefined (ControlName,ParentForm)
		MsgMiniGuiError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated" )
	endif
	
	mVar := '_' + ParentForm + '_' + ControlName

	if valtype( nId ) != "N"
		nId := _GetId()
	endif

	ControlHandle := CreateQHTM( GetFormhandle(ParentForm), nId, IF(lBorder, WS_BORDER, 0), y, x, w, h )

        if valtype(Value) != "U"
		SetWindowText( ControlHandle, Value )
	elseif valtype(fname) != "U"
		QHTM_LoadFile( ControlHandle, fname )
	elseif valtype(resname) != "U"
		QHTM_LoadRes( ControlHandle, resname )
	ENDIF

	QHTM_FormCallBack( ControlHandle )

	k := _GetControlFree()

	Public &mVar. := k

	_HMG_aControlType [k] := "QHTM" 
	_HMG_aControlNames [k] :=  ControlName 
	_HMG_aControlHandles [k] :=  ControlHandle
	_HMG_aControlParenthandles [k] :=  GetFormhandle(ParentForm)
	_HMG_aControlIds [k] :=   nId 
	_HMG_aControlProcedures  [k] :=  ""
	_HMG_aControlPageMap  [k] :=  {} 
	_HMG_aControlValue  [k] :=  Value
	_HMG_aControlInputMask  [k] :=  "" 
	_HMG_aControllostFocusProcedure  [k] :=  "" 
	_HMG_aControlGotFocusProcedure  [k] :=  "" 
	_HMG_aControlChangeProcedure  [k] :=  Change
	_HMG_aControlDeleted  [k] :=  .F. 
	_HMG_aControlBkColor   [k] := Nil 
	_HMG_aControlFontColor   [k] := Nil 
	_HMG_aControlDblClick   [k] := "" 
	_HMG_aControlHeadClick   [k] := {} 
	_HMG_aControlRow  [k] :=  x
	_HMG_aControlCol  [k] :=  y 
	_HMG_aControlWidth   [k] := w
	_HMG_aControlHeight  [k] := h
	_HMG_aControlSpacing  [k] :=  0 
	_HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 ) 
	_HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 ) 
	_HMG_aControlPicture  [k] :=  "" 
	_HMG_aControlContainerHandle  [k] :=  0 
	_HMG_aControlFontName  [k] :=  '' 
	_HMG_aControlFontSize  [k] :=  0 
	_HMG_aControlFontAttributes  [k] :=  {.f.,.f.,.f.,.f.} 
	_HMG_aControlToolTip   [k] :=  '' 
	_HMG_aControlRangeMin  [k] :=   0  
	_HMG_aControlRangeMax  [k] :=   0  
	_HMG_aControlCaption  [k] :=   ''  
	_HMG_aControlVisible  [k] :=   .t. 
	_HMG_aControlHelpId  [k] :=   0 
	_HMG_aControlFontHandle  [k] :=   FontHandle 
	_HMG_aControlBrushHandle  [k] :=  0 
	_HMG_aControlEnabled  [k] :=  .T. 
	_HMG_aControlMiscData1 [k] := 0
	_HMG_aControlMiscData2 [k] := ''

Return Nil

procedure QHTM_LoadFromFile( ControlName, ParentForm, cFile )
   local nHandle

   nHandle := GetControlHandle( ControlName, ParentForm )
   if nHandle > 0
      QHTM_LoadFile( nHandle, cFile )
   endif
Return

procedure QHTM_LoadFromRes( ControlName, ParentForm, cResName )
   local nHandle

   nHandle := GetControlHandle( ControlName, ParentForm )
   if nHandle > 0
      QHTM_LoadRes( nHandle, cResName )
   endif
Return

function QHTM_GetLink( lParam )
   local cLink := QHTM_GetNotify( lParam )

   QHTM_SetReturnValue( lParam, .F. )
Return cLink
