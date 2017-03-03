#define BS_SPLITBUTTON     0x0000000C

#define BCM_SETNOTE        0x00001609
#define BCM_SETSHIELD      0x0000160C
*------------------------------------------------------------------------------*
Init Procedure _InitCLButton
*------------------------------------------------------------------------------*

	InstallEventHandler ( 'CLButtonEventHandler' )
	InstallMethodHandler ( 'Release', 'ReleaseCLButtonImageList' )
	InstallMethodHandler ( 'SetShield' , 'CLButton_SetShield' )
	InstallMethodHandler ( 'SetFocus' , 'CLButtonSetFocus' )
	InstallMethodHandler ( 'Enable' , 'CLButtonEnable' )
	InstallMethodHandler ( 'Disable' , 'CLButtonDisable' )
	InstallPropertyHandler ( 'Handle' , 'SetCLButtonHandle' , 'GetCLButtonHandle' )
	InstallPropertyHandler ( 'Caption' , 'SetCLButtonCaption' , 'GetCLButtonCaption' )
	InstallPropertyHandler ( 'NoteText' , 'SetCLButtonNoteText' , 'GetCLButtonNoteText' )
	InstallPropertyHandler ( 'Picture' , 'SetCLButtonPicture' , 'GetCLButtonPicture' )

Return

*------------------------------------------------------------------------------*
Procedure _DefineCLButton ( cName , nRow , nCol , cCaption , cNotes , bAction , cParent , lDefault , w , h )
*------------------------------------------------------------------------------*
Local hControlHandle, nId, hParentFormHandle, k, cMacroVar

	If .Not. _IsWindowDefined (cParent)
		MsgMiniGuiError("Window: "+ cParent + " is not defined.")
	Endif

	If _IsControlDefined (cName,cParent)
		MsgMiniGuiError ("Control: " + cName + " Of " + cParent + " Already defined.")
	Endif

	DEFAULT w  TO 180
	DEFAULT h  TO 60

	cMacroVar := '_' + cParent + '_' + cName
	k			:= _GetControlFree()
	nId			:= _GetId() 
	hParentFormHandle	:= GetFormHandle (cParent)
	hControlHandle		:= InitCLButton ( ;
							hParentFormHandle , ;
							nRow , ;
							nCol , ;
							cCaption , ;
							lDefault , ;
							w , h , ;
							nId ;
						)

	CLButton_SetNote( hControlHandle, cNotes )

	Public &cMacroVar. := k

	_HMG_aControlType [k] := 'CLBUTTON'
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
	_HMG_aControlPicture  [k] :=  "Arrow" 
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
PROCEDURE ReleaseCLButtonImageList ( cWindow, cControl )
*------------------------------------------------------------------------------*

	IF _IsControlDefined ( cControl, cWindow ) .AND. GetControlType ( cControl, cWindow ) == 'CLBUTTON'

		i := GetControlIndex ( cControl , cWindow )

		IF ! Empty( _HMG_aControlBrushHandle [i] )
			IMAGELIST_DESTROY ( _HMG_aControlBrushHandle [i] )
		ENDIF

		_HMG_UserComponentProcess := .T.

	ELSE

		_HMG_UserComponentProcess := .F.

	ENDIF

RETURN

#define WM_COMMAND		0x0111
#define BN_CLICKED		0
*------------------------------------------------------------------------------*
Function CLButtonEventhandler ( hWnd, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
Local i
Local RetVal := Nil
hWnd := Nil // Unused variable

	if nMsg == WM_COMMAND

		i := Ascan ( _HMG_aControlHandles , lParam )

		If i > 0 .And. _HMG_aControlType [i] == 'CLBUTTON'

			IF HiWord (wParam) == BN_CLICKED
				RetVal := 0
				_DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
			Endif

		Endif

	endif

Return RetVal

*------------------------------------------------------------------------------*
Procedure CLButton_SetShield ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local i

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		i := GetControlIndex ( cControl , cWindow )

		_HMG_aControlPicture [i] := "Shield"

		SendMessage ( GetControlHandle ( cControl , cWindow ), BCM_SETSHIELD, 0, 0xFFFFFFFF )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Procedure CLButtonSetFocus ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		SetFocus ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Procedure CLButtonEnable ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		EnableWindow ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Procedure CLButtonDisable ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		DisableWindow ( GetControlHandle ( cControl , cWindow ) )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Function SetCLButtonHandle ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		MsgExclamation ( 'This Property is Read Only!' , 'Warning' )

	endif

	_HMG_UserComponentProcess := .F.

Return Nil

*------------------------------------------------------------------------------*
Function GetCLButtonHandle ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		_HMG_UserComponentProcess := .T.
		RetVal := GetControlHandle ( cControl , cWindow )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
Function SetCLButtonCaption ( cWindow , cControl , cProperty , cValue )
*------------------------------------------------------------------------------*
cProperty := Nil // Unused variable

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		_HMG_UserComponentProcess := .T.

		SetWindowText ( GetControlHandle ( cControl , cWindow ) , cValue )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return Nil

*------------------------------------------------------------------------------*
Function GetCLButtonCaption ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		_HMG_UserComponentProcess := .T.

		RetVal := GetWindowText ( GetControlHandle ( cControl , cWindow ) )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
Procedure SetCLButtonNoteText ( cWindow , cControl , cProperty , cValue )
*------------------------------------------------------------------------------*
cProperty := Nil // Unused variable

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		CLButton_SetNote( GetControlHandle ( cControl , cWindow ), cValue )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Function GetCLButtonNoteText ( cWindow , cControl )
*------------------------------------------------------------------------------*

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		MsgExclamation ( 'This Property is Write Only!' , 'Warning' )

	endif

	_HMG_UserComponentProcess := .F.

Return Nil

*------------------------------------------------------------------------------*
Procedure SetCLButtonPicture ( cWindow , cControl , cProperty , cBitmap )
*------------------------------------------------------------------------------*
Local i
cProperty := Nil // Unused variable

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		i := GetControlIndex ( cControl , cWindow )

		_HMG_aControlPicture [i] := cBitmap

		IF ! Empty( _HMG_aControlBrushHandle [i] )
			IMAGELIST_DESTROY ( _HMG_aControlBrushHandle [i] )
		ENDIF

		_HMG_aControlBrushHandle [i] := CLButton_SetImage( GetControlHandle ( cControl , cWindow ) , cBitmap )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return

*------------------------------------------------------------------------------*
Function GetCLButtonPicture ( cWindow , cControl )
*------------------------------------------------------------------------------*
Local RetVal := Nil

	If GetControlType ( cControl , cWindow ) == 'CLBUTTON'

		_HMG_UserComponentProcess := .T.

		RetVal := _GetPicture ( cControl , cWindow )

	else

		_HMG_UserComponentProcess := .F.

	endif

Return RetVal

*------------------------------------------------------------------------------*
* Low Level C Routines
*------------------------------------------------------------------------------*

#pragma BEGINDUMP

#define BS_COMMANDLINK     0x0000000E
#define BS_DEFCOMMANDLINK  0x0000000F

#include <mgdefs.h>
#include <windows.h>
#include <commctrl.h>

#include "hbapi.h"

HB_FUNC( INITCLBUTTON )
{

	HWND hwnd = ( HWND ) HB_PARNL (1) ;
	HWND hbutton;
	int  Style;

	Style = BS_COMMANDLINK;

	if( hb_parl( 5 ) )
		Style = BS_DEFCOMMANDLINK;

	hbutton = CreateWindow( "button" ,
                           hb_parc(4) ,
                           Style | WS_CHILD | WS_CLIPCHILDREN | WS_CLIPSIBLINGS | BS_PUSHBUTTON | WS_VISIBLE,
                           hb_parni(3) ,
                           hb_parni(2) ,
                           hb_parni(6) ,
                           hb_parni(7) ,
                           hwnd ,
                           (HMENU)HB_PARNL(8) ,
                           GetModuleHandle(NULL) ,
                           NULL ) ;

	HB_RETNL ( ( LONG_PTR ) hbutton );

}

#define BCM_SETNOTE     0x00001609

HB_FUNC( CLBUTTON_SETNOTE )
{
   if( HB_ISCHAR( 2 ) )
   {
      LPSTR szText = ( LPSTR ) hb_parc( 2 );
      int nConvertedLen = MultiByteToWideChar( CP_ACP, MB_PRECOMPOSED, szText, -1, NULL, 0 );
      LPWSTR lpwText = ( LPWSTR ) hb_xgrab( nConvertedLen * 2 + 1 );

      MultiByteToWideChar( CP_ACP, MB_PRECOMPOSED, szText, -1, lpwText, nConvertedLen );

      SendMessage( ( HWND ) HB_PARNL( 1 ), BCM_SETNOTE, 0, (LPARAM) lpwText );
      hb_xfree( lpwText );
   }
}

#ifndef BCM_FIRST
#define BCM_FIRST         0x1600
#define BCM_SETIMAGELIST  ( BCM_FIRST + 0x0002 )
#endif

#if ( defined( __BORLANDC__ ) && __BORLANDC__ < 1410 ) || ( defined ( __MINGW32__ ) && defined ( __MINGW32_VERSION ) ) || defined ( __XCC__ )
typedef struct
{
   HIMAGELIST himl;
   RECT       margin;
   UINT       uAlign;
} BUTTON_IMAGELIST, * PBUTTON_IMAGELIST;
#endif

HB_FUNC( CLBUTTON_SETIMAGE )
{
   HIMAGELIST       himl;
   BUTTON_IMAGELIST bi;

   himl = ImageList_LoadImage
             (
         GetModuleHandle( NULL ),
         hb_parc( 2 ),
         0,
         6,
         CLR_DEFAULT,
         IMAGE_BITMAP,
         LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT
             );

   if( himl == NULL )
      himl = ImageList_LoadImage
             (
         GetModuleHandle( NULL ),
         hb_parc( 2 ),
         0,
         6,
         CLR_DEFAULT,
         IMAGE_BITMAP,
         LR_LOADFROMFILE | LR_CREATEDIBSECTION | LR_LOADMAP3DCOLORS | LR_LOADTRANSPARENT
             );

   bi.himl          = himl;
   bi.margin.left   = 10;
   bi.margin.top    = 10;
   bi.margin.bottom = 10;
   bi.margin.right  = 10;
   bi.uAlign        = 4;

   SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) BCM_SETIMAGELIST, ( WPARAM ) 0, ( LPARAM ) &bi );

   HB_RETNL( ( LONG_PTR ) himl );
}

#pragma ENDDUMP
