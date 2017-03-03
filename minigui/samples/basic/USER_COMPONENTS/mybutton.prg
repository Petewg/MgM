*------------------------------------------------------------------------------*
Init Procedure _InitMyButton
*------------------------------------------------------------------------------*

	InstallEventHandler ( 'MyButtonEventHandler' )
	InstallMethodHandler ( 'SetFocus' , 'MyButtonSetFocus' )
	InstallMethodHandler ( 'Enable' , 'MyButtonEnable' )
	InstallMethodHandler ( 'Disable' , 'MyButtonDisable' )
	InstallPropertyHandler ( 'Handle' , 'SetMyButtonHandle' , 'GetMyButtonHandle' )
	InstallPropertyHandler ( 'Caption' , 'SetMyButtonCaption' , 'GetMyButtonCaption' )

Return

*------------------------------------------------------------------------------*
Procedure _DefineMyButton ( cName , nRow , nCol , cCaption , bAction , cParent )
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
	hControlHandle		:= InitMyButton ( ;
							hParentFormHandle , ;
							nRow , ;
							nCol , ;
							cCaption , ;
							nId ;
						)

	Public &cMacroVar. := k

	_HMG_aControlType [k] := 'MYBUTTON'
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

#define WM_COMMAND		0x0111
#define BN_CLICKED		0

*------------------------------------------------------------------------------*
Function MyButtonEventhandler ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
Local i
Local RetVal := Nil

hWnd := Nil // Unused variable

	if nMsg == WM_COMMAND

		i := Ascan ( _HMG_aControlHandles , lParam )

		If i > 0 .And. _HMG_aControlType [i] == 'MYBUTTON'

			IF HiWord (wParam) == BN_CLICKED
				RetVal := 0
				_DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
			Endif

		Endif

	endif

Return RetVal

*------------------------------------------------------------------------------*
Procedure MyButtonSetFocus ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYBUTTON'

		SetFocus ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Procedure MyButtonEnable ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYBUTTON'

		EnableWindow ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Procedure MyButtonDisable ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYBUTTON'

		DisableWindow ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Function SetMyButtonHandle ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'MYBUTTON'

		MsgExclamation ( 'This Property is Read Only!' , 'Warning' )

	endif

	_HMG_UserComponentProcess := .F.

Return Nil

*------------------------------------------------------------------------------*
Function GetMyButtonHandle ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'MYBUTTON'

		_HMG_UserComponentProcess := .T.
		RetVal := GetControlHandle ( cControl , cWindow )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
Function SetMyButtonCaption ( cWindow , cControl , cProperty , cValue )
*------------------------------------------------------------------------------*
cProperty := Nil // Unused variable

	If GetControlType ( cControl , cWindow ) == 'MYBUTTON'

		_HMG_UserComponentProcess := .T.

		SetWindowText ( GetControlHandle ( cControl , cWindow ) , cValue )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return Nil

*------------------------------------------------------------------------------*
Function GetMyButtonCaption ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'MYBUTTON'

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

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( INITMYBUTTON )
{

	HWND hwnd = (HWND) hb_parnl (1) ;
	HWND hbutton;

	hbutton = CreateWindow( "button" ,
                           hb_parc(4) ,
                           BS_NOTIFY | WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE,
                           hb_parni(3) ,
                           hb_parni(2) ,
                           120 ,
                           28 ,
                           hwnd ,
                           (HMENU)hb_parni(5) ,
                           GetModuleHandle(NULL) ,
                           NULL ) ;

	hb_retnl ( (LONG) hbutton );

}

#pragma ENDDUMP
