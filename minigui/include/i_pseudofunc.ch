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
 	Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - https://harbour.github.io/

	"Harbour Project"
	Copyright 1999-2021, https://harbour.github.io/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

////////////////////////////
// MiniGUI pseudo-functions
////////////////////////////

#xtranslate MsgInfo ( <c>, <t> )	=> MsgInfo ( <c>, <t>, , .F. )
#xtranslate MsgStop ( <c>, <t> )	=> MsgStop ( <c>, <t>, , .F. )
#xtranslate MsgYesNo( <c>, <t> )	=> MsgYesNo(<c>, <t>, , , .F.)
#xtranslate MsgAlert( <c>, <t> )	=> MsgExclamation( <c>, <t>, , .F. )
#xtranslate MsgExclamation( <c>, <t> )	=> MsgExclamation( <c>, <t>, , .F. )
#xtranslate MsgYesNoCancel( <c>, <t> )	=> MsgYesNoCancel( <c>, <t>, , .F.)
#xtranslate MsgRetryCancel( <c>, <t> )	=> MsgRetryCancel( <c>, <t>, , .F. )
#xtranslate MsgOkCancel ( <c>, <t> )	=> MsgOkCancel( <c>, <t>, , .F. )

// ============================================================================

#xtranslate HideWindow ( <hWnd> ) ;
=> ;
ShowWindow( <hWnd>, SW_HIDE )

#xtranslate _Maximize ( <hWnd> ) ;
=> ;
ShowWindow( <hWnd>, SW_MAXIMIZE )

#xtranslate _MaximizeWindow ( <FormName> ) ;
=> ;
_Maximize( GetFormHandle( <FormName> ) )

#xtranslate _Minimize ( <hWnd> ) ;
=> ;
ShowWindow( <hWnd>, SW_MINIMIZE )

#xtranslate _MinimizeWindow ( <FormName> ) ;
=> ;
_Minimize( GetFormHandle( <FormName> ) )

#xtranslate _Restore ( <hWnd> ) ;
=> ;
ShowWindow( <hWnd>, SW_RESTORE )

#xtranslate _RestoreWindow ( <FormName> ) ;
=> ;
_Restore( GetFormHandle( <FormName> ) )

// ============================================================================

#xtranslate GetSpecialFolder ( <nCSIDL> ) ;
=> ;
C_GetSpecialFolder( <nCSIDL> )

#xtranslate GetWindowsFolder () ;
=> ;
GetWindowsDir()

#xtranslate GetSystemFolder () ;
=> ;
GetSystemDir()

#xtranslate GetTempFolder () ;
=> ;
cFilePath( GetTempDir() )

#xtranslate GetMyDocumentsFolder () ;
=> ;
GetSpecialFolder ( CSIDL_PERSONAL )

#xtranslate GetDesktopFolder () ;
=> ;
GetSpecialFolder ( CSIDL_DESKTOPDIRECTORY )

#xtranslate GetApplicationDataFolder () ;
=> ;
GetSpecialFolder( CSIDL_APPDATA )

#xtranslate GetUserProfileFolder () ;
=> ;
GetSpecialFolder( CSIDL_PROFILE )

#xtranslate GetUserTempFolder () ;
=> ;
iif( IsVistaOrLater(), GetUserProfileFolder() + "\AppData\Local\Temp", cFilePath( GetTempDir() ) )

//#define __WIN98__

#ifdef __WIN98__
#  xtranslate GetProgramFilesFolder () ;
   => ;
   C_GetDllSpecialFolder( CSIDL_PROGRAM_FILES )
#else
#  xtranslate GetProgramFilesFolder () ;
   => ;
   GetSpecialFolder( CSIDL_PROGRAM_FILES )
#endif
//#undef __WIN98__

#xtranslate GetStartUpFolder () ;
=> ;
cFilePath( GetExeFilename() )

#xtranslate GetProgramFilename () ;
=> ;
GetExeFilename()

#xtranslate GetModuleFilename ( <hInstance> ) ;
=> ;
GetExeFilename()

// ============================================================================

#xtranslate CShowControl ( <hWnd> ) ;
=> ;
ShowWindow ( <hWnd> )

#xtranslate IsTabStop ( <hWnd> ) ;
=> ;
IsWindowHasStyle ( <hWnd> , 0x00010000 )

#xtranslate SetTabStop ( <hWnd>, <ltab> ) ;
=> ;
SetWindowStyle ( <hWnd> , 0x00010000 , <ltab> )

#xtranslate IsWindowSized ( <hWnd> ) ;
=> ;
IsWindowHasStyle ( <hWnd> , 0x00040000 )

// ============================================================================

#xtranslate _GetKeyState( <VKey> ) ;
=> ;
CheckBit( GetKeyState( <VKey> ) , 32768 )

#xtranslate GetEscapeState () ;
=> ;
GetKeyState( VK_ESCAPE )

#xtranslate GetAltState () ;
=> ;
GetKeyState( VK_MENU )

#xtranslate IsInsertActive () ;
=> ;
( GetKeyState( VK_INSERT ) > 0 )

#xtranslate IsCapsLockActive () ;
=> ;
( GetKeyState( VK_CAPITAL ) > 0 )

#xtranslate IsNumLockActive () ;
=> ;
( GetKeyState( VK_NUMLOCK ) > 0 )

#xtranslate IsScrollLockActive () ;
=> ;
( GetKeyState( VK_SCROLL ) > 0 )

// ============================================================================

#translate IsWinNT () ;
=> ;
os_IsWinNT()

#translate IsWinXPorLater () ;
=> ;
os_IsWinXP_Or_Later()

#translate IsVista () ;
=> ;
os_IsWinVista()

#translate IsVistaOrLater () ;
=> ;
os_IsWinVista_Or_Later()

#translate IsSeven () ;
=> ;
os_IsWin7()

#translate IsWin64 () ;
=> ;
hb_osIs64Bit()

// ============================================================================

#translate GetProperty ( <FormName> , "ClientWidth" ) ;
=> ;
_GetClientRect ( GetFormHandle ( <FormName> ) ) \[3]

#translate GetProperty ( <FormName> , "ClientHeight" ) ;
=> ;
_GetClientRect ( GetFormHandle ( <FormName> ) ) \[4]

#translate GetProperty ( <FormName> , <ControlName> , "ClientWidth" ) ;
=> ;
_GetClientRect ( GetControlHandle ( <ControlName> , <FormName> ) ) \[3]

#translate GetProperty ( <FormName> , <ControlName> , "ClientHeight" ) ;
=> ;
_GetClientRect ( GetControlHandle ( <ControlName> , <FormName> ) ) \[4]

#translate GetProperty ( <FormName> , <ControlName> , "ImageWidth" ) ;
=> ;
_HMG_aControlHeadClick \[ GetControlIndex ( <ControlName>, <FormName> ) ] \[1]

#translate GetProperty ( <FormName> , <ControlName> , "ImageHeight" ) ;
=> ;
_HMG_aControlHeadClick \[ GetControlIndex ( <ControlName>, <FormName> ) ] \[2]

#translate SetProperty ( <FormName> , <ControlName> , "ImageWidth", <w> ) ;
=> ;
_HMG_aControlHeadClick \[ GetControlIndex ( <ControlName>, <FormName> ) ] \[1] := <w>

#translate SetProperty ( <FormName> , <ControlName> , "ImageHeight", <h> ) ;
=> ;
_HMG_aControlHeadClick \[ GetControlIndex ( <ControlName>, <FormName> ) ] \[2] := <h>

#translate DoMethod ( <FormName> , "Print" ) ;
=> ;
PrintWindow( <FormName> )

#translate DoMethod ( <FormName> , "SaveAs", <FileName> ) ;
=> ;
WndCopy( GetFormHandle( <FormName> ), .f., <FileName> )

#translate DoMethod ( <FormName> , <ControlName> , "SaveAs" , <FileName> ) ;
=> ;
WndCopy( GetControlHandle( <ControlName> , <FormName> ), .t., <FileName> )

#translate SetProperty ( <FormName> , <ControlName> , "Velocity" , <Value> ) ;
=> ;
SendMessage( GetControlHandle( <ControlName> , <FormName> ) , WM_USER+10 , iif(<Value> > 0, 1, 0) , <Value> )

// ============================================================================

#xtranslate PlayBeep () ;
=> ;
MessageBeep( 0xFFFFFFFF )

#xtranslate PlayAsterisk () ;
=> ;
MessageBeep( 64 )

#xtranslate PlayExclamation () ;
=> ;
MessageBeep( 48 )

#xtranslate PlayHand () ;
=> ;
MessageBeep( 16 )

#xtranslate PlayQuestion () ;
=> ;
MessageBeep( 32 )

#xtranslate PlayOk () ;
=> ;
MessageBeep( 0 )

// ============================================================================

#xtranslate PlayWaveFromResource( <wave> ) ;
=> ;
C_PlayWave( <wave>, .t., .f., .f., .f., .f. )

#xtranslate _PlayPlayer ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 1 )

#xtranslate _StopPlayer ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 2 )

#xtranslate _PausePlayer ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 3 )

#xtranslate _ClosePlayer ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 4 )

#xtranslate _DestroyPlayer ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 5 )

#xtranslate _EjectPlayer ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 6 )

#xtranslate _SetPlayerPositionEnd ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 7 )

#xtranslate _SetPlayerPositionHome ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 8 )

#xtranslate _OpenPlayer ( <ControlName> , <ParentFormName> , <file> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 9 , <file> )

#xtranslate _OpenPlayerDialog ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 10 )

#xtranslate _PlayPlayerReverse ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 11 )

#xtranslate _ResumePlayer ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 12 )

#xtranslate _SetPlayerRepeatOn ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 13 , .T. )

#xtranslate _SetPlayerRepeatOff ( <ControlName> , <ParentFormName> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 13 , .F. )

#xtranslate _SetPlayerSpeed ( <ControlName> , <ParentFormName> , <speed> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 14 , <speed> )

#xtranslate _SetPlayerVolume ( <ControlName> , <ParentFormName> , <volume> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 15 , <volume> )

#xtranslate _SetPlayerZoom ( <ControlName> , <ParentFormName> , <zoom> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 16 , <zoom> )

#xtranslate <x> := _GetPlayerLength ( <ControlName> , <ParentFormName> ) ;
=> ;
<x> := mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 17 )

#xtranslate <x> := _GetPlayerPosition ( <ControlName> , <ParentFormName> ) ;
=> ;
<x> := mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 18 )

#xtranslate <x> := _GetPlayerVolume ( <ControlName> , <ParentFormName> ) ;
=> ;
<x> := mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 19 )

#xtranslate _SetPlayerPosition ( <ControlName> , <ParentFormName> , <pos> ) ;
=> ;
mcifunc ( GetControlHandle( <ControlName> , <ParentFormName> ) , 20 , <pos> )

// ============================================================================

#xtranslate _OpenAnimateBox ( <ControlName> , <ParentFormName> , <FileName> ) ;
=> ;
openanimate ( GetControlHandle( <ControlName> , <ParentFormName> ) , <FileName> )

#xtranslate _PlayAnimateBox ( <ControlName> , <ParentFormName> ) ;
=> ;
playanimate ( GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _SeekAnimateBox ( <ControlName> , <ParentFormName> , <Frame> ) ;
=> ;
seekanimate ( GetControlHandle( <ControlName> , <ParentFormName> ) , <Frame> )

#xtranslate _StopAnimateBox ( <ControlName> , <ParentFormName> ) ;
=> ;
stopanimate ( GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _CloseAnimateBox ( <ControlName> , <ParentFormName> ) ;
=> ;
closeanimate ( GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _DestroyAnimateBox ( <ControlName> , <ParentFormName> ) ;
=> ;
destroywindow ( GetControlHandle( <ControlName> , <ParentFormName> ) )

// ============================================================================

#xtranslate _GetBrowseAllowAppend ( <ControlName> , <ParentFormName> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 2 )

#xtranslate _GetBrowseAllowEdit ( <ControlName> , <ParentFormName> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 6 )

#xtranslate _GetBrowseAllowDelete ( <ControlName> , <ParentFormName> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 12 )

#xtranslate _GetBrowseInputItems ( <ControlName> , <ParentFormName> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 13 )

#xtranslate _GetBrowseDisplayItems ( <ControlName> , <ParentFormName> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 14 )

#xtranslate _SetBrowseAllowAppend ( <ControlName> , <ParentFormName> , <Value> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 2 , <Value> )

#xtranslate _SetBrowseAllowEdit ( <ControlName> , <ParentFormName> , <Value> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 6 , <Value> )

#xtranslate _SetBrowseAllowDelete ( <ControlName> , <ParentFormName> , <Value> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 12 , <Value> )

#xtranslate _SetBrowseInputItems ( <ControlName> , <ParentFormName> , <Value> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 13 , <Value> )

#xtranslate _SetBrowseDisplayItems ( <ControlName> , <ParentFormName> , <Value> ) ;
=> ;
_SetGetBrowseProperty ( <ControlName> , <ParentFormName> , 14 , <Value> )

// ============================================================================

#translate IsControlDefined ( <ControlName> , <FormName> ) ;
=> ;
_IsControlDefined ( <(ControlName)> , <(FormName)> )

#translate IsWindowActive ( <FormName> ) ;
=> ;
_IsWindowActive ( <(FormName)> )

#translate IsWindowDefined ( <FormName> ) ;
=> ;
_IsWindowDefined ( <(FormName)> )

// ============================================================================

#xtranslate GetHotKeyName ( <ControlName> , <FormName> ) ;
=> ;
_GetHotKeyName ( <(ControlName)> , <(FormName)> )

#xtranslate GetHotKeyValue ( <ControlName> , <FormName> ) ;
=> ;
_GetHotKeyValue ( <(ControlName)> , <(FormName)> )

#xtranslate _GetHotKeyValue( <ControlName> , <FormName> ) ;
=> ;
C_GetHotKeyValue( GetControlHandle( <ControlName> , <FormName> ) )

// ============================================================================

#xtranslate IsErrorLogActive () ;
=> ;
_HMG_CreateErrorLog

#xtranslate _GetErrorlogFile () ;
=> ;
_HMG_ErrorLogFile

// ============================================================================

#xtranslate _GetNotifyIconName ( <FormName> ) ;
=> ;
_HMG_aFormNotifyIconName \[ GetFormIndex( <FormName> ) \]

#xtranslate _GetNotifyIconTooltip ( <FormName> ) ;
=> ;
_HMG_aFormNotifyIconTooltip \[ GetFormIndex( <FormName> ) \]

#xtranslate _GetRadioGroupReadOnly ( <ControlName> , <FormName> ) ;
=> ;
GetControlPageMap ( <ControlName> , <FormName> )

#xtranslate _GetAddress ( <ControlName> , <FormName> ) ;
=> ;
_GetValue ( <ControlName> , <FormName> )

#xtranslate RC_CURSOR ( <cCursor> ) ;
=> ;
SetResCursor ( LoadCursor( GetInstance(), <cCursor> ) )

#xtranslate GetCursorRow () ;
=> ;
GetCursorPos() \[1\]

#xtranslate GetCursorCol () ;
=> ;
GetCursorPos() \[2\]

#xtranslate LB_String2Array( <cData> [, <Sep> ] ) ;
=> ;
hb_ATokens( <cData>, iif( hb_IsString( <Sep> ) , <Sep> , Chr(9) ) )

// ============================================================================

#xtranslate _DestroyImageList ( <ControlName> , <ParentFormName> ) ;
=> ;
ImageList_Destroy ( GetControlHandle( <ControlName> , <ParentFormName> ) ) ;;
_ReleaseControl ( <ControlName> , <ParentFormName> )

#xtranslate IL_DESTROY ( <h> ) ;
=> ;
ImageList_Destroy ( <h> )

#xtranslate _DragEnterImage ( <ix>, <iy> ) ;
=> ;
IL_DragEnter ( _HMG_ActiveDragImageHandle, <ix>, <iy> )

#xtranslate _MoveImage ( <ix>, <iy> ) ;
=> ;
IL_DragMove ( <ix>, <iy> )

#xtranslate _EndDragImage () ;
=> ;
IL_EndDrag ( _HMG_ActiveDragImageHandle )

#xtranslate _GetImageCount ( <ControlName> , <ParentFormName> ) ;
=> ;
IL_GetImageCount ( GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _RemoveImageFromImageList ( <ControlName> , <ParentFormName>, <ImageIndex> ) ;
=> ;
IL_Remove( GetControlHandle( <ControlName> , <ParentFormName> ) , <ImageIndex> )

#xtranslate _DrawImageFromImageList ( <ControlName> , <ParentFormName>, <ImageIndex>, <cx>, <cy> ) ;
=> ;
IL_Draw( GetFormHandle ( <ParentFormName> ), GetControlHandle( <ControlName> , <ParentFormName> ), <ImageIndex>, <cx>, <cy> )

// ============================================================================

#xtranslate _AddChildToPager ( <ControlName> , <ParentFormName> ) ;
=> ;
AddToPager ( _HMG_ActivePagerForm, GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _Pager_ForwardMouse ( <ControlName> , <ParentFormName>, <lEnable> ) ;
=> ;
PagerForwardMouse ( GetControlHandle( <ControlName> , <ParentFormName> ), IFLOGICAL( <lEnable>, <lEnable>, .F. ) )

#xtranslate _Pager_GetButtonSize ( <ControlName> , <ParentFormName> ) ;
=> ;
PagerGetButtonSize ( GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _Pager_SetButtonSize ( <ControlName> , <ParentFormName>, <nSize> ) ;
=> ;
PagerSetButtonSize ( GetControlHandle( <ControlName> , <ParentFormName> ), <nSize> )

#xtranslate _Pager_GetBorder ( <ControlName> , <ParentFormName> ) ;
=> ;
PagerGetBorder ( GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _Pager_SetBorder ( <ControlName> , <ParentFormName>, <nSize> ) ;
=> ;
PagerSetBorder ( GetControlHandle( <ControlName> , <ParentFormName> ), <nSize> )

#xtranslate _Pager_GetPos ( <ControlName> , <ParentFormName> ) ;
=> ;
PagerGetPos ( GetControlHandle( <ControlName> , <ParentFormName> ) )

#xtranslate _Pager_SetPos ( <ControlName> , <ParentFormName>, <nPos> ) ;
=> ;
PagerSetPos ( GetControlHandle( <ControlName> , <ParentFormName> ), <nPos> )

// ============================================================================

#xtranslate _SetControlCol ( <ControlName>, <ParentForm>, <Value> ) ;
=> ;
_SetControlSizePos ( <ControlName> , <ParentForm> , _GetControlRow ( <ControlName>, <ParentForm> ) , <Value> , _GetControlWidth ( <ControlName>, <ParentForm> ) , _GetControlHeight ( <ControlName>, <ParentForm> ) )

#xtranslate _SetControlRow ( <ControlName>, <ParentForm>, <Value> ) ;
=> ;
_SetControlSizePos ( <ControlName> , <ParentForm> , <Value> , _GetControlCol ( <ControlName>, <ParentForm> ) , _GetControlWidth ( <ControlName>, <ParentForm> ) , _GetControlHeight ( <ControlName>, <ParentForm> ) )

#xtranslate _SetControlWidth ( <ControlName>, <ParentForm>, <Value> ) ;
=> ;
_SetControlSizePos ( <ControlName> , <ParentForm> , _GetControlRow ( <ControlName>, <ParentForm> ) , _GetControlCol ( <ControlName>, <ParentForm> ) , <Value> , _GetControlHeight ( <ControlName>, <ParentForm> ) )

#xtranslate _SetControlHeight ( <ControlName>, <ParentForm>, <Value> ) ;
=> ;
_SetControlSizePos ( <ControlName> , <ParentForm> , _GetControlRow ( <ControlName>, <ParentForm> ) , _GetControlCol ( <ControlName>, <ParentForm> ) , _GetControlWidth ( <ControlName>, <ParentForm> ) , <Value> )

// ============================================================================

#xtranslate GetDesktopWidth () ;
=> ;
GetSystemMetrics( SM_CXSCREEN )

#xtranslate GetDesktopHeight () ;
=> ;
GetSystemMetrics( SM_CYSCREEN )

#xtranslate GetVScrollBarWidth () ;
=> ;
GetSystemMetrics( SM_CXVSCROLL )

#xtranslate GetHScrollBarHeight () ;
=> ;
GetSystemMetrics( SM_CYHSCROLL )

#xtranslate GetTitleHeight () ;
=> ;
GetSystemMetrics( SM_CYCAPTION )

#xtranslate GetBorderHeight () ;
=> ;
GetSystemMetrics( SM_CYSIZEFRAME )

#xtranslate GetBorderWidth () ;
=> ;
GetSystemMetrics( SM_CXSIZEFRAME )

#xtranslate Get3DEdgeHeight () ;
=> ;
GetSystemMetrics( SM_CYEDGE )

#xtranslate Get3DEdgeWidth () ;
=> ;
GetSystemMetrics( SM_CXEDGE )

#xtranslate GetMenuBarHeight () ;
=> ;
GetSystemMetrics( SM_CYMENU )

// ============================================================================

#xtranslate GetWindowBorderSize () => GetNonClient() \[1\]

#xtranslate GetScrollBarSize ()    => GetNonClient() \[3\]

#xtranslate GetTitleBarWidth ()    => GetNonClient() \[4\]

#xtranslate GetTitleBarHeight ()   => GetNonClient() \[5\]

#xtranslate GetMenuBarSize ()      => GetNonClient() \[7\]

// ============================================================================

#xtranslate SendMessageWideString( <h> , <n> , <wp> , <lp> ) ;
=> ;
SendMessageStringW( <h> , <n> , <wp> , <lp> )

#xtranslate ProcessMessages() => DoEvents()

#translate And( <p1> , <p2> ) => hb_BitAnd( <p1> , <p2> )

#xtranslate Random( <nMax> )  => hb_RandomInt( IFNUMERIC( <nMax>, <nMax>, 65535 ) )

#translate _dummy()           => iif( .T.,, )

#xtranslate GetFontWidth( <FontName>, <nLen> ) ;
=> ;
GetFontParam( GetFontHandle( <FontName> ) )\[ 8 ] * <nLen>

#xtranslate GetFontHeight( <FontName> ) ;
=> ;
GetFontParam( GetFontHandle( <FontName> ) )\[ 9 ]

#xtranslate GetFontNameByHandle( <hFont> ) ;
=> ;
GetFontParam( <hFont> )\[ 10 ]

#xtranslate HMG_SysWait( [ <nSeconds> ] ) => hb_idleSleep( hb_defaultValue( <nSeconds>, 0.105 ) )

#translate HMG_RGB2n( <p1>, <p2>, <p3> )  => IFNUMERIC( <p1>, RGB( <p1>, <p2>, <p3> ), <p1> )

#translate HMG_RGB2n( <x> ) => IFARRAY( <x>, RGB( <x>\[ 1 ], <x>\[ 2 ], <x>\[ 3 ] ), <x> )

#translate HMG_n2RGB( <x> ) => { GetRed( <x> ), GetGreen( <x> ), GetBlue( <x> ) }

#translate HMG_TimeMS( <dTS1> [, <dTS2> ] ) ;
=> ;
LTrim( hb_TSToStr( ( hb_StrToTS( "" ) + ( hb_defaultValue( <dTS2>, hb_DateTime() ) - <dTS1> ) ), .T. ) )

////////////////////////////////////////////
// Variable type identifier pseudo-functions
////////////////////////////////////////////
#ifndef HB_COMMON_CH_
   /* Type checking macros */
#  translate ISNIL( <xValue> )       => ( <xValue> == NIL )
#  translate ISARRAY( <xValue> )     => hb_IsArray( <xValue> )
#  translate ISBLOCK( <xValue> )     => hb_IsBlock( <xValue> )
#  translate ISCHARACTER( <xValue> ) => hb_IsString( <xValue> )
#  translate ISDATE( <xValue> )      => hb_IsDate( <xValue> )
#  translate ISLOGICAL( <xValue> )   => hb_IsLogical( <xValue> )
#  translate ISMEMO( <xValue> )      => hb_IsMemo( <xValue> )
#  translate ISNUMBER( <xValue> )    => hb_IsNumeric( <xValue> )
#  translate ISOBJECT( <xValue> )    => hb_IsObject( <xValue> )
#endif

#translate ISCHAR( <xValue> )    => hb_IsString( <xValue> )
#translate ISSTRING( <xValue> )  => hb_IsString( <xValue> )
#translate ISNUMERIC( <xValue> ) => hb_IsNumeric( <xValue> )

#translate IFNIL( <v1>,<exp1>,<exp2> )       => iif( (<v1>) == NIL,<exp1>,<exp2> )
#translate IFARRAY( <v1>,<exp1>,<exp2> )     => iif( ISARRAY( <v1> ),<exp1>,<exp2> )
#translate IFBLOCK( <v1>,<exp1>,<exp2> )     => iif( ISBLOCK( <v1> ),<exp1>,<exp2> )
#translate IFCHARACTER( <v1>,<exp1>,<exp2> ) => iif( ISCHARACTER( <v1> ),<exp1>,<exp2> )
#translate IFCHAR( <v1>,<exp1>,<exp2> )      => iif( ISCHAR( <v1> ),<exp1>,<exp2> )
#translate IFSTRING( <v1>,<exp1>,<exp2> )    => iif( ISSTRING( <v1> ),<exp1>,<exp2> )
#translate IFDATE( <v1>,<exp1>,<exp2> )      => iif( ISDATE( <v1> ),<exp1>,<exp2> )
#translate IFLOGICAL( <v1>,<exp1>,<exp2> )   => iif( ISLOGICAL( <v1> ),<exp1>,<exp2> )
#translate IFNUMBER( <v1>,<exp1>,<exp2> )    => iif( ISNUMBER( <v1> ),<exp1>,<exp2> )
#translate IFNUMERIC( <v1>,<exp1>,<exp2> )   => iif( ISNUMERIC( <v1> ),<exp1>,<exp2> )
#translate IFOBJECT( <v1>,<exp1>,<exp2> )    => iif( ISOBJECT( <v1> ),<exp1>,<exp2> )
#translate IFEMPTY( <v1>,<exp1>,<exp2> )     => iif( EMPTY( <v1> ),<exp1>,<exp2> )

/////////////////////////////////////
// Abbreviated flow control modifiers
/////////////////////////////////////

#xcommand BREAKIF <log>  => IF ( <log> ) ; BREAK ; END
#xcommand EXITIF <log>   => IF ( <log> ) ; EXIT ; END
#xcommand LOOPIF <log>   => IF ( <log> ) ; LOOP ; END

// Extended commands
// ============================================================================

/* REPEAT ... UNTIL support */
#command  REPEAT         => DO WHILE .T.
#command  UNTIL <lCond>  => IF !<lCond> ; EXIT ; END ; ENDDO

#ifndef HB_COMMON_CH_
   /* Friendly logical aliases */
#  define TRUE	.T.
#  define FALSE	.F.
#  define YES	.T.
#  define NO	.F.

   /* DEFAULT and UPDATE commands */
#  xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ] => ;
				IF <v1> == NIL ; <v1> := <x1> ; END ;
				[; IF <vn> == NIL ; <vn> := <xn> ; END ]

#  command UPDATE <v1> IF <exp> TO <v2> ;
	=>				;
	IF <exp> ; <v1> := <v2> ; END
#endif

// ============================================================================

#define MAKELRESULT( lw, hw )          MAKELONG( lw, hw ) 

#ifndef HB_SYMBOL_UNUSED
   #define HB_SYMBOL_UNUSED( symbol )  ( ( symbol ) )
#endif

#xtranslate frac( <num> ) => ( <num> - int( <num> ) )

// ============================================================================

#xtranslate cFileName( <cPathMask> ) => hb_FNameNameExt( <cPathMask> )

#xtranslate ChangeFileExt( <cFile>, <cExt> ) ;
=> ;
cFilePath( <cFile> ) + "\" + cFileNoExt( <cFile> ) + <cExt>

#ifndef __XHARBOUR__
#  include "hbver.ch"
//#define __WIN98__

#ifndef __WIN98__
#  include "hbgtinfo.ch"
#  xtranslate gtSetClipboard( <x> )       => hb_gtInfo( HB_GTI_CLIPBOARDDATA, <x> )
#  xtranslate gtGetClipboard()            => hb_gtInfo( HB_GTI_CLIPBOARDDATA )

#  xtranslate RetrieveTextFromClipboard() => gtGetClipboard()
#  xtranslate CopyToClipboard ( <x> )     => gtSetClipboard( <x> )
#  xtranslate CopyToClipboard ()          => gtSetClipboard( "" )
#endif
//#undef __WIN98__

/* SWITCH ... ; CASE ... ; DEFAULT ; ... ; END */
#  xcommand DEFAULT                       => OTHERWISE

/* FOR EACH hb_enumIndex() */
#  xtranslate hb_enumIndex( <!v!> )       => <v>:__enumIndex()

/* TRY / CATCH / FINALLY / END */
#xcommand TRY                             => BEGIN SEQUENCE WITH __BreakBlock()
#xcommand CATCH [<!oErr!>]                => RECOVER [USING <oErr>] <-oErr->
#xcommand FINALLY                         => ALWAYS

#if ( __HARBOUR__ - 0 > 0x020000 )
#  xtranslate CurDrive()                  => hb_CurDrive()
#  xtranslate dbPack()                    => hb_dbPack()
#  xtranslate dbZap()                     => hb_dbZap()
#endif

#if ( __HARBOUR__ - 0 < 0x030200 )
#  xtranslate hb_IsFunction( <c> )        => ( Type( <c> + "()" ) == "UI" )
#  xtranslate hb_default( @<v>, <x> )     => iif( StrTran( ValType( <v> ), "M", "C" ) == StrTran( ValType( <x> ), "M", "C" ), Nil, <v> := <x> )
#  xtranslate hb_defaultValue( <v>, <x> ) => iif( StrTran( ValType( <v> ), "M", "C" ) == StrTran( ValType( <x> ), "M", "C" ), <v>, <x> )
#  xtranslate __defaultNIL( @<v>, <x> )   => ( <v> := iif( <v> == NIL, <x>, <v> ) )
#  xtranslate __MvGetDef( <x> , <v> )     => iif( __MvExist ( <x> ), __MvGet( <x> ), iif( ValType( <v> ) <> "U", <v>, NIL ) )
#  xtranslate __MvGetDef( <x> )           => iif( __MvExist ( <x> ), __MvGet( <x> ), NIL )
#  xtranslate hb_osIsWin10()              => '10' $ WindowsVersion() \[ 1 ]
#endif

#if ( __HARBOUR__ - 0 > 0x030200 )
#  xtranslate hb_oemtoansi( <x> )         => win_oemtoansi( <x> )
#  xtranslate __MvGetDef( <x> , <v> )     => iif( __MvExist ( <x> ), __MvGet( <x> ), iif( ValType( <v> ) <> "U", <v>, NIL ) )
#  xtranslate __MvGetDef( <x> )           => iif( __MvExist ( <x> ), __MvGet( <x> ), NIL )
#  xtranslate hb_osIsWin10()              => os_IsWin10()
#endif

#  xtranslate IsExe64()                   => ( hb_Version( HB_VERSION_BITWIDTH ) == 64 )
#  xtranslate IsDirectory( <c> )          => hb_DirExists( <c> )
#  xtranslate GetComputerName()           => NetName()
#  xtranslate GetUserName()               => hb_UserName()
#  xtranslate GetExeFilename()            => hb_ProgName()
#  xuntranslate AIns(                     =>
#  xuntranslate ADel(                     =>
#  xtranslate AIns( <a>, <n>, [<x,...>] ) => hb_AIns( <a>, <n>, <x> )
#  xtranslate ADel( <a>, <n>, <l> )       => hb_ADel( <a>, <n>, <l> )
#  xuntranslate AScan(                    =>
#  xuntranslate At(                       =>
#  xtranslate AScan(<a>,<b>,[<c>],[<d>],<e>) ;
                                          => hb_AScan( <a>, <b>, <c>, <d>, <e> )
#  xtranslate At( <a>, <b>, [<x,...>] )   => hb_At( <a>, <b>, <x> )
#else
#  xtranslate GetComputerName()           => NetName()
#  xtranslate GetUserName()               => NetName( 1 )
#  xtranslate GetExeFilename()            => ExeName()
#  xtranslate hb_ADel( [<x,...>] )        => ADel( <x> ) 
#  xtranslate hb_default( @<v>, <x> )     => iif( StrTran( ValType( <v> ), "M", "C" ) == StrTran( ValType( <x> ), "M", "C" ), Nil, <v> := <x> )
#  xtranslate hb_defaultValue( <v>, <x> ) => iif( StrTran( ValType( <v> ), "M", "C" ) == StrTran( ValType( <x> ), "M", "C" ), <v>, <x> )
#  xtranslate __defaultNIL( @<v>, <x> )   => ( <v> := iif( <v> == NIL, <x>, <v> ) )
#  xtranslate __MvGetDef( <x> , <v> )     => iif( __MvExist ( <x> ), __MvGet( <x> ), iif( ValType( <v> ) <> "U", <v>, NIL ) )
#  xtranslate __MvGetDef( <x> )           => iif( __MvExist ( <x> ), __MvGet( <x> ), NIL )
#  xtranslate hb_DirBase()                => Left( ExeName(), RAt( '\', ExeName() ) )
#  xtranslate hb_osIsWin10()              => '10' $ WindowsVersion() \[ 1 ]
#endif /* __XHARBOUR__ */

// ============================================================================
// Strongly Typed Variables			  (c) 1996-1997, Bryan Duchesne
// ============================================================================
/*
 * Adapted for MiniGUI Extended Edition by Grigory Filatov - 2010
*/

// This command replaces the traditional := assignment

#xcommand ASSIGN <cVar> := <cExp> ;
=> ;
<cVar> := _IsTyped( <cVar>, <cExp> )

// declare your variables as strongly typed
// ============================================================================

#xcommand LOCAL <cVar> AS <xtype:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY> ;
             [,<cVarn> AS <xtypen:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY>] ;
=> ;
LOCAL <cVar> := _SetType( <"xtype"> ) [, <cVarn> := _SetType( <"xtypen"> ) ]

#xcommand STATIC <cVar> AS <xtype:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY> ;
             [,<cVarn> AS <xtypen:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY>] ;
=> ;
STATIC <cVar> [, <cVarn> ] ;;
<cVar> := _SetType( <"xtype"> ) [, <cVarn> := _SetType( <"xtypen"> ) ]

#xcommand PUBLIC <cVar> AS <xtype:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY> ;
             [,<cVarn> AS <xtypen:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY>] ;
=> ;
PUBLIC <cVar> := _SetType( <"xtype"> ) [, <cVarn> := _SetType( <"xtypen"> ) ]

#xcommand PRIVATE <cVar> AS <xtype:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY> ;
             [,<cVarn> AS <xtypen:STRING,NUMERIC,LOGICAL,DATE,BLOCK,ARRAY>] ;
=> ;
PRIVATE <cVar> := _SetType( <"xtype"> ) [, <cVarn> := _SetType( <"xtypen"> ) ]
