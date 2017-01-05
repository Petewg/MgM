*------------------------------------------------------------------------------*
Init Procedure _InitActiveX
*------------------------------------------------------------------------------*

	InstallMethodHandler ( 'Release' , 'ReleaseActiveX' )
	InstallPropertyHandler ( 'Object' , 'SetActiveXObject' , 'GetActiveXObject' )

Return

*------------------------------------------------------------------------------*
Procedure _DefineActivex ( cControlName, cParentForm, nRow, nCol , nWidth , nHeight , cProgId )
*------------------------------------------------------------------------------*
Local mVar , nControlHandle , aControlHandles , k := 0 , nParentFormHandle , oOle
Local nAtlDllHandle , nInterfacePointer

	* If defined inside DEFINE WINDOW structure, determine cParentForm

	if _HMG_BeginWindowActive = TRUE .or. _HMG_BeginDialogActive = TRUE
		cParentForm := iif(_HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName)
	endif

	* If defined inside a Tab structure, adjust position and determine
	* cParentForm

	if _HMG_FrameLevel > 0
		nCol 		:= nCol + _HMG_ActiveFrameCol [_HMG_FrameLevel]
		nRow 		:= nRow + _HMG_ActiveFrameRow [_HMG_FrameLevel]
		cParentForm 	:= _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
	EndIf

	* Check for errors

	* Check Parent Window

	If .Not. _IsWindowDefined (cParentForm)
		MsgMiniGuiError("Window: "+ cParentForm + " is not defined. Program terminated" )
	Endif

	* Check Control

	If _IsControlDefined (cControlName,cParentForm)
		MsgMiniGuiError ("Control: " + cControlName + " Of " + cParentForm + " Already defined. Program Terminated" )
	Endif

	* Check cProgId

	If valType (cProgId) <> 'C'
		MsgMiniGuiError ("Control: " + cControlName + " Of " + cParentForm + " PROGID Property Invalid Type. Program Terminated" )
	EndIf

	If Empty (cProgId)
		MsgMiniGuiError ("Control: " + cControlName + " Of " + cParentForm + " PROGID Can't be empty. Program Terminated" )
	EndIf

	* Define public variable associated with control

	mVar := '_' + cParentForm + '_' + cControlName

	nParentFormHandle := GetFormHandle (cParentForm)

	* Init Activex

	aControlHandles := InitActivex( nParentFormHandle , cProgId , nCol , nRow , nWidth , nHeight )

	nControlHandle		:= aControlHandles [1]
	nInterfacePointer	:= aControlHandles [2]
	nAtlDllHandle		:= aControlHandles [3]

	If _HMG_BeginTabActive = .T.
	    aAdd ( _HMG_ActiveTabCurrentPageMap , nControlhandle )
	EndIf

	* Create OLE control

	oOle := CreateObject( nInterfacePointer )

	k := _GetControlFree()

	Public &mVar. := k

	_HMG_aControlType [k] := "ACTIVEX"
	_HMG_aControlNames  [k] :=  cControlName
	_HMG_aControlHandles  [k] := nControlHandle
	_HMG_aControlParenthandles [k] := nParentFormHandle
	_HMG_aControlIds  [k] :=  0 
	_HMG_aControlProcedures  [k] := ""
	_HMG_aControlPageMap  [k] :=  {} 
	_HMG_aControlValue  [k] :=  Nil 
	_HMG_aControlInputMask  [k] :=  "" 
	_HMG_aControllostFocusProcedure  [k] :=  "" 
	_HMG_aControlGotFocusProcedure  [k] :=  "" 
	_HMG_aControlChangeProcedure  [k] :=  "" 
	_HMG_aControlDeleted  [k] :=  .F. 
	_HMG_aControlBkColor [k] :=   Nil 
	_HMG_aControlFontColor  [k] :=  Nil 
	_HMG_aControlDblClick  [k] :=  "" 
	_HMG_aControlHeadClick  [k] :=  {} 
	_HMG_aControlRow   [k] := nRow
	_HMG_aControlCol   [k] := nCol
	_HMG_aControlWidth   [k] := nWidth
	_HMG_aControlHeight   [k] := nHeight
	_HMG_aControlSpacing   [k] := 0 
	_HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 ) 
	_HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 ) 
	_HMG_aControlPicture  [k] :=  "" 
	_HMG_aControlContainerHandle [k] :=  0 
	_HMG_aControlFontName  [k] :=  Nil
	_HMG_aControlFontSize  [k] :=  Nil
	_HMG_aControlFontAttributes  [k] :=  {} 
	_HMG_aControlToolTip   [k] :=  '' 
	_HMG_aControlRangeMin  [k] :=  0  
	_HMG_aControlRangeMax  [k] :=  0  
	_HMG_aControlCaption  [k] :=   ''
	_HMG_aControlVisible  [k] :=   .t. 
	_HMG_aControlHelpId  [k] :=   nAtlDllHandle
	_HMG_aControlFontHandle  [k] :=   Nil
	_HMG_aControlBrushHandle  [k] :=   0 
	_HMG_aControlEnabled  [k] :=  .T. 
	_HMG_aControlMiscData1 [k] := oOle
	_HMG_aControlMiscData2 [k] := ''

Return

*------------------------------------------------------------------------------*
Procedure ReleaseActiveX ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If _IsControlDefined ( cControl, cWindow ) .And. GetControlType ( cControl , cWindow ) == 'ACTIVEX'

		ExitActivex( GetControlHandle ( cControl , cWindow ), _HMG_aControlHelpId [ GetControlIndex ( cControl , cWindow ) ] )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Function SetActiveXObject ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'ACTIVEX'

		MsgExclamation ( 'This Property is Read Only!' , 'Warning' )

	endif

	_HMG_UserComponentProcess := .F.

Return Nil

*------------------------------------------------------------------------------*
Function GetActiveXObject ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'ACTIVEX'

		_HMG_UserComponentProcess := .T.
		RetVal := _GetControlObject ( cControl , cWindow )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*-----------------------------------------------------------------------------*
Function _GetControlObject ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
Local mVar , i

	mVar := '_' + ParentForm + '_' + ControlName
	i := &mVar
	if i == 0
		Return ''
	EndIf

Return ( _HMG_aControlMiscData1 [ &mVar ] )

*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#include <windows.h>
#include <commctrl.h>
#include <hbapi.h>
#include <hbvm.h>
#include <hbstack.h>

#ifdef __XHARBOUR__
#define HB_STORNL( n, x, y ) hb_stornl( n, x, y )
#else
#define HB_STORNL( n, x, y ) hb_storvnl( n, x, y )
#endif

typedef HRESULT(WINAPI *LPAtlAxGetControl)(HWND hwnd,IUnknown** unk);
typedef HRESULT(WINAPI *LPAtlAxWinInit)(void);

/*

	InitActivex() function.
	2008.07.15 - Roberto López <harbourminigui@gmail.com>
	http://harbourminigui.googlepages.com

	Inspired by the works of Oscar Joel Lira Lira <oskar78@users.sourceforge.net>
        for Freewin project
	http://www.sourceforge.net/projects/freewin

*/

HB_FUNC( INITACTIVEX ) 
{

	HMODULE hlibrary;
	HWND hchild;
	IUnknown *pUnk;
	IDispatch *pDisp;
	LPAtlAxWinInit    AtlAxWinInit;
	LPAtlAxGetControl AtlAxGetControl;

	hlibrary = LoadLibrary( "Atl.Dll" );
	AtlAxWinInit    = ( LPAtlAxWinInit )    GetProcAddress( hlibrary, "AtlAxWinInit" );
	AtlAxGetControl = ( LPAtlAxGetControl ) GetProcAddress( hlibrary, "AtlAxGetControl" );
	AtlAxWinInit();

	hchild = CreateWindowEx( 0, "AtlAxWin",hb_parc(2), WS_CHILD | WS_VISIBLE , hb_parni(3), hb_parni(4), hb_parni(5), hb_parni(6), (HWND)hb_parnl( 1 ) , 0 , 0 , 0 );

	AtlAxGetControl( (HWND) hchild , &pUnk );
	pUnk->lpVtbl->QueryInterface(pUnk,&IID_IDispatch,(void**)&pDisp);

	hb_reta( 3 );
	HB_STORNL( (LONG) hchild	, -1, 1 ); 
	HB_STORNL( (LONG) pDisp		, -1, 2 ); 
	HB_STORNL( (LONG) hlibrary	, -1, 3 ); 

}

HB_FUNC( EXITACTIVEX ) 
{

	DestroyWindow ( (HWND)hb_parnl( 1 ) );
	FreeLibrary ( (HMODULE)hb_parnl( 2 ) );

}

#pragma ENDDUMP
