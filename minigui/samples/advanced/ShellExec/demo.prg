/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * ShellExecuteEx() and TerminateProcess() for MiniGui
 *
 * Copyright 2014 Verchenko Andrey <verchenkoag@gmail.com>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

STATIC hProcessHandleShellExecuteEx := 0

PROCEDURE Main

DEFINE WINDOW Win_1 ;
	AT 0,0 WIDTH 450 HEIGHT 300 ;
	TITLE "ShellExecuteEx() Using Demo" ;
	MAIN ;
	TOPMOST ;
	FONT "Tahona" SIZE 14 ;
	NOMAXIMIZE NOSIZE

	@ 20,100 BUTTONEX Button_1 ;
		WIDTH 230 HEIGHT 60 ;
		CAPTION 'ShellExecuteEx()' ;
		ACTION RunFile()

	@ 100,100 BUTTONEX Button_3 ;
		WIDTH 230 HEIGHT 60 ;
		CAPTION 'TerminateProcess()';
		ACTION { || CloseProcess() }

	@ 180,100 BUTTONEX Button_2 ;
		WIDTH 230 HEIGHT 60 ;
		CAPTION 'Exit' ;
		ACTION { || ThisWindow.Release }

END WINDOW

CENTER WINDOW Win_1
ACTIVATE WINDOW Win_1

RETURN

////////////////////////////////////////////////////////////////////////////////
#define SW_SHOWNORMAL	1

FUNCTION RunFile()
LOCAL xVal, xVal2
LOCAL cPath := "c:\minigui"
LOCAL cFileRun := cPath + "\Doc\MiniGUI.chm"

IF FILE( cFileRun )

	IF Empty( hProcessHandleShellExecuteEx )
		hProcessHandleShellExecuteEx := ShellExecuteEx( , 'open', cFileRun, , , SW_SHOWNORMAL )
	ENDIF

ELSE
	MsgStop( "Can not found file " + cFileRun )
ENDIF

RETURN NIL


FUNCTION CloseProcess()

IF hProcessHandleShellExecuteEx > 0
	TerminateProcess( hProcessHandleShellExecuteEx )
	hProcessHandleShellExecuteEx := 0
ENDIF

RETURN NIL


#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>
#include <shlobj.h>

HB_FUNC( SHELLEXECUTEEX )
{
	SHELLEXECUTEINFO SHExecInfo;
	ZeroMemory(&SHExecInfo, sizeof(SHExecInfo));

	SHExecInfo.cbSize	= sizeof(SHExecInfo);
	SHExecInfo.fMask	= SEE_MASK_NOCLOSEPROCESS;
	SHExecInfo.hwnd		= HB_ISNIL( 1 ) ? GetActiveWindow() : (HWND) hb_parnl( 1 );
	SHExecInfo.lpVerb	= (LPCSTR) hb_parc( 2 );
	SHExecInfo.lpFile	= (LPCSTR) hb_parc( 3 );
	SHExecInfo.lpParameters	= (LPCSTR) hb_parc( 4 );
	SHExecInfo.lpDirectory	= (LPCSTR) hb_parc( 5 );
	SHExecInfo.nShow	= hb_parni( 6 );

	if( ShellExecuteEx(&SHExecInfo) )
		hb_retnl( (LONG) SHExecInfo.hProcess );
	else 
		hb_retnl( NULL );
}

HB_FUNC( TERMINATEPROCESS ) 
{
	hb_retl( (BOOL) TerminateProcess( (HANDLE) hb_parnl( 1 ), 0 ) );
}

#pragma ENDDUMP 
