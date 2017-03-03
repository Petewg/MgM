#include "i_winuser.ch"

*------------------------------------------------------------------------------*
Init Procedure _InitMySysLink
*------------------------------------------------------------------------------*

	InstallEventHandler ( 'MySysLinkEventHandler' )
	InstallMethodHandler ( 'SetFocus' , 'MySysLinkSetFocus' )
	InstallMethodHandler ( 'Enable' , 'MySysLinkEnable' )
	InstallMethodHandler ( 'Disable' , 'MySysLinkDisable' )
	InstallPropertyHandler ( 'Handle' , 'SetMySysLinkHandle' , 'GetMySysLinkHandle' )
	InstallPropertyHandler ( 'Caption' , 'SetMySysLinkCaption' , 'GetMySysLinkCaption' )

Return

*------------------------------------------------------------------------------*
Procedure _DefineMySysLink ( cName , nRow , nCol , cCaption , bAction , cParent )
*------------------------------------------------------------------------------*
Local hControlHandle, nId, hParentFormHandle, k, cMacroVar

	If .Not. _IsWindowDefined (cParent)
		MsgMiniGuiError("Window: "+ cParent + " is not defined.")
	Endif

	If _IsControlDefined (cName,cParent)
		MsgMiniGuiError ("Control: " + cName + " Of " + cParent + " Already defined.")
	Endif

	cMacroVar := '_' + cParent + '_' + cName
	k			:= _GetControlFree()
	nId			:= _GetId() 
	hParentFormHandle	:= GetFormHandle (cParent)
	hControlHandle		:= InitMySysLink ( ;
							hParentFormHandle , ;
							nRow , ;
							nCol , ;
							cCaption , ;
							nId ;
						)

	Public &cMacroVar. := k

	_HMG_aControlType [k] := 'MYSYSLINK'
	_HMG_aControlNames  [k] :=  cName
	_HMG_aControlHandles  [k] := hControlHandle
	_HMG_aControlParenthandles [k] := hParentFormHandle
	_HMG_aControlIds  [k] :=  0 
	_HMG_aControlProcedures  [k] := bAction
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
	_HMG_aControlRow   [k] := 0
	_HMG_aControlCol   [k] := 0 
	_HMG_aControlWidth   [k] := 0 
	_HMG_aControlHeight   [k] := 0 
	_HMG_aControlSpacing   [k] := 0 
	_HMG_aControlContainerRow  [k] :=  -1 
	_HMG_aControlContainerCol  [k] :=  -1 
	_HMG_aControlPicture  [k] :=  "" 
	_HMG_aControlContainerHandle [k] :=   0 
	_HMG_aControlFontName  [k] :=  Nil
	_HMG_aControlFontSize  [k] :=  Nil
	_HMG_aControlFontAttributes  [k] :=  {} 
	_HMG_aControlToolTip   [k] :=  '' 
	_HMG_aControlRangeMin  [k] :=   0  
	_HMG_aControlRangeMax  [k] :=   0  
	_HMG_aControlCaption  [k] :=   ''
	_HMG_aControlVisible  [k] :=   .t. 
	_HMG_aControlHelpId  [k] :=   0 
	_HMG_aControlFontHandle  [k] :=   Nil
	_HMG_aControlBrushHandle  [k] :=   0 
	_HMG_aControlEnabled  [k] :=   .T. 
	_HMG_aControlMiscData1 [k] := 0
	_HMG_aControlMiscData2 [k] := ''

Return

*------------------------------------------------------------------------------*
Function MySysLinkEventhandler ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
Local i
Local RetVal := Nil
hWnd := Nil // Unused variable

	if nMsg == WM_NOTIFY

		i := Ascan ( _HMG_aControlHandles , GetHwndFrom (lParam) )

		If i > 0

			IF GetNotifyCode ( lParam ) == NM_CLICK .Or. GetNotifyCode ( lParam ) == NM_RETURN
				RetVal := 0
				_DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
			Endif

		Endif

	endif

Return RetVal

*------------------------------------------------------------------------------*
Procedure MySysLinkSetFocus ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYSYSLINK'

		SetFocus ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Procedure MySysLinkEnable ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYSYSLINK'

		EnableWindow ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Procedure MySysLinkDisable ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYSYSLINK'

		DisableWindow ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Function SetMySysLinkHandle ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYSYSLINK'

		MsgExclamation ( 'This Property is Read Only!' , 'Warning' )

	endif

	_HMG_UserComponentProcess := .F.

Return Nil

*------------------------------------------------------------------------------*
Function GetMySysLinkHandle ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'MYSYSLINK'

		_HMG_UserComponentProcess := .T.
		RetVal := GetControlHandle ( cControl , cWindow )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
Function SetMySysLinkCaption ( cWindow , cControl , cProperty , cValue )
*------------------------------------------------------------------------------*
cProperty := Nil // Unused variable

	If GetControlType ( cControl , cWindow ) == 'MYSYSLINK'

		_HMG_UserComponentProcess := .T.

		SetWindowText ( GetControlHandle ( cControl , cWindow ) , cValue )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return Nil

*------------------------------------------------------------------------------*
Function GetMySysLinkCaption ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'MYSYSLINK'

		_HMG_UserComponentProcess := .T.

		RetVal := GetWindowText ( GetControlHandle ( cControl , cWindow ) )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#define UNICODE
#define WC_LINK         L"SysLink"

#define _WIN32_WINNT 0x501

#if (_WIN32_WINNT >= 0x501)
#define ICC_LINK_CLASS         0x00008000
#endif

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( INITMYSYSLINK )
{
	HWND hwnd = (HWND) hb_parnl (1);
	HWND hSysLink;

	INITCOMMONCONTROLSEX icex;
	icex.dwSize = sizeof(INITCOMMONCONTROLSEX);
	icex.dwICC  = ICC_LINK_CLASS;
	InitCommonControlsEx(&icex);

	hSysLink = CreateWindowEx ( WS_EX_TOPMOST,
                           WC_LINK,
                           L"For more information, <A HREF=\"http://www.microsoft.com\">click here</A> " \
                           L"or <A ID=\"idInfo\">here</A>.", 
                           WS_TABSTOP|WS_VISIBLE|WS_CHILD,
                           hb_parni(3) ,
                           hb_parni(2) ,
                           160 ,
                           100 ,
                           hwnd ,
                           (HMENU)hb_parni(5) ,
                           GetModuleHandle(NULL) ,
                           NULL );

	hb_retnl ( (LONG) hSysLink );

}

#pragma ENDDUMP
