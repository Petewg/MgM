*------------------------------------------------------------------------------*
Init Procedure _InitAnimateRes
*------------------------------------------------------------------------------*

	InstallMethodHandler ( 'Release' , 'ReleaseAnimateRes' )
	InstallPropertyHandler ( 'File' , 'SetAnimateResFile' , 'GetAnimateResFile' )
	InstallPropertyHandler ( 'ResId' , 'SetAnimateResId' , 'GetAnimateResId' )

Return

*-----------------------------------------------------------------------------*
Function _DefineAnimateRes ( ControlName, ParentForm, x, y, w, h, cFile, nRes, ;
                              tooltip, HelpId, invisible )
*-----------------------------------------------------------------------------*
Local i, cParentForm, mVar, ControlHandle, hAvi

	DEFAULT h         TO 50
	DEFAULT w         TO 200
	DEFAULT invisible TO FALSE

	if _HMG_BeginWindowActive
		ParentForm := _HMG_ActiveFormName
	endif

	if _HMG_FrameLevel > 0
		x 	:= x + _HMG_ActiveFrameCol [_HMG_FrameLevel]
		y 	:= y + _HMG_ActiveFrameRow [_HMG_FrameLevel]
		ParentForm := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
	EndIf

	If .Not. _IsWindowDefined (ParentForm)
		MsgMiniGuiError("Window: "+ ParentForm + " is not defined.")
	Endif

	If _IsControlDefined (ControlName,ParentForm)
		MsgMiniGuiError ("Control: " + ControlName + " Of " + ParentForm + " Already defined.")
	endif

	mVar := '_' + ParentForm + '_' + ControlName
	Public &mVar. := Len(_HMG_aControlNames) + 1

	cParentForm := ParentForm

	ParentForm := GetFormHandle (ParentForm)

	ControlHandle := InitAnimateRes ( ParentForm, @hAvi, x, y, w, h, cFile, nRes, invisible )

	If _HMG_BeginTabActive
		aAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
	EndIf

	if valtype(tooltip) != "U"
		SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
	endif

	aAdd ( _HMG_aControlType , "ANIMATE" )
	aAdd ( _HMG_aControlNames , ControlName )
	aAdd ( _HMG_aControlHandles , ControlHandle )
	aAdd ( _HMG_aControlParentHandles , ParentForm )
	aAdd ( _HMG_aControlIds , nRes )
	aAdd ( _HMG_aControlProcedures , "" )
	aAdd ( _HMG_aControlPageMap , {} )
	aAdd ( _HMG_aControlValue , cFile )
	aAdd ( _HMG_aControlInputMask , "" )
	aAdd ( _HMG_aControllostFocusProcedure , "" )
	aAdd ( _HMG_aControlGotFocusProcedure , "" )
	aAdd ( _HMG_aControlChangeProcedure , "" )
	aAdd ( _HMG_aControlDeleted , .F. )
	aAdd ( _HMG_aControlBkColor , {} )
	aAdd ( _HMG_aControlFontColor , {} )
	aAdd ( _HMG_aControlDblClick , "" )
	aAdd ( _HMG_aControlHeadClick , {} )
	aAdd ( _HMG_aControlRow , y )
	aAdd ( _HMG_aControlCol , x )
	aAdd ( _HMG_aControlWidth , w )
	aAdd ( _HMG_aControlHeight , h )
	aAdd ( _HMG_aControlSpacing , 0 )
	aAdd ( _HMG_aControlContainerRow , iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 ) )
	aAdd ( _HMG_aControlContainerCol , iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 ) )
	aAdd ( _HMG_aControlPicture , "" )
	aAdd ( _HMG_aControlContainerHandle , 0 )
	aAdd ( _HMG_aControlFontName , '' )
	aAdd ( _HMG_aControlFontSize , 0 )
	aAdd ( _HMG_aControlFontAttributes , {FALSE,FALSE,FALSE,FALSE} )
	aAdd ( _HMG_aControlToolTip  , tooltip  )
	aAdd ( _HMG_aControlRangeMin  , 0  )
	aAdd ( _HMG_aControlRangeMax  , 0  )
	aAdd ( _HMG_aControlCaption  , ''  )
	aAdd ( _HMG_aControlVisible  , if(invisible,FALSE,TRUE) )
	aAdd ( _HMG_aControlHelpId  , HelpId )
	aAdd ( _HMG_aControlFontHandle  , 0 )
	aAdd ( _HMG_aControlBrushHandle  , 0 )
	aAdd ( _HMG_aControlEnabled  , .T. )
	aAdd ( _HMG_aControlMiscData1  , hAvi )
	aAdd ( _HMG_aControlMiscData2  , '' )

Return Nil

*------------------------------------------------------------------------------*
Function SetAnimateResFile ( cWindow , cControl , cProperty , cValue )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'ANIMATE'

		_HMG_UserComponentProcess := .T.

		_HMG_aControlValue [ GetControlIndex ( cControl , cWindow ) ] :=  cValue

	else

		_HMG_UserComponentProcess := .F.

	endif

Return Nil

*------------------------------------------------------------------------------*
Function GetAnimateResFile ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'ANIMATE'

		_HMG_UserComponentProcess := .T.

		RetVal := _HMG_aControlValue [ GetControlIndex ( cControl , cWindow ) ]

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
Function SetAnimateResId ( cWindow , cControl , cProperty , cValue )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'ANIMATE'

		_HMG_UserComponentProcess := .T.

		_HMG_aControlIds [ GetControlIndex ( cControl , cWindow ) ] :=  cValue

	else

		_HMG_UserComponentProcess := .F.

	endif

Return Nil

*------------------------------------------------------------------------------*
Function GetAnimateResId ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'ANIMATE'

		_HMG_UserComponentProcess := .T.

		RetVal := _HMG_aControlIds [ GetControlIndex ( cControl , cWindow ) ]

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
Procedure ReleaseAnimateRes ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If _IsControlDefined ( cControl, cWindow ) .And. GetControlType ( cControl , cWindow ) == 'ANIMATE'

		UnloadAnimateLib( _GetAnimateResHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*-----------------------------------------------------------------------------*
Function _GetAnimateResHandle ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
Local mVar , i

	mVar := '_' + ParentForm + '_' + ControlName
	i := &mVar
	if i == 0
		Return ''
	EndIf

Return ( _HMG_aControlMiscData1 [ i ] )


#pragma BEGINDUMP

// #define _WIN32_IE      0x0500
// #define _WIN32_WINNT   0x0400

#include <windows.h>
#include <mmsystem.h>
#include <commctrl.h>

#include "hbapi.h"

HB_FUNC ( INITANIMATERES )
{
	HWND hwnd;
	HWND AnimationCtrl;
	HINSTANCE avi;

	int Style = WS_CHILD | WS_VISIBLE | ACS_TRANSPARENT | ACS_CENTER | ACS_AUTOPLAY ;

	INITCOMMONCONTROLSEX  i;
	i.dwSize = sizeof(INITCOMMONCONTROLSEX);
	i.dwICC = ICC_DATE_CLASSES;
	InitCommonControlsEx(&i);

	hwnd = (HWND) hb_parnl (1);

	if ( ! hb_parl (9) )
	{
		Style = Style | WS_VISIBLE ;
	}

	avi = LoadLibrary( hb_parc(7) ) ;

	AnimationCtrl = CreateWindowEx(0,	//Style
			ANIMATE_CLASS,		//Class Name
			NULL,			//Window name
			Style,			//Window Style
			hb_parni(3) ,		//Left
			hb_parni(4) ,		//Top
			hb_parni(5) ,		//Right
			hb_parni(6) ,		//Bottom
			hwnd,			//Handle of parent
			(HMENU)hb_parni(2),	//Menu
			avi,			//hInstance
			NULL ) ;		//User defined style

	Animate_OpenEx( (HWND) AnimationCtrl, avi, hb_parnl(8) ) ;

	hb_stornl ( (LONG) avi, 2 ) ;
	hb_retnl ( (LONG) AnimationCtrl ) ;
}

HB_FUNC( UNLOADANIMATELIB )
{
	HINSTANCE hLib = (HINSTANCE) hb_parnl (1);

	if( hLib )
	{
		FreeLibrary( hLib );
	}
}

#pragma ENDDUMP
