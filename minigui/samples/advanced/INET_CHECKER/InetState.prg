/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2015 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'InterNet State Checker'
#define COPYRIGHT ' Grigory Filatov, 2002-2015'
#define TIMER_INFO ': Timer is '

Static lTimer := .T.

*--------------------------------------------------------*
PROCEDURE Main
*--------------------------------------------------------*

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		ON INIT UpdateNotify() ;
		NOTIFYICON 'ICON_1' ;
		NOTIFYTOOLTIP PROGRAM + TIMER_INFO + iif( lTimer, "On", "Off" ) ;
		ON NOTIFYCLICK ShellAbout( "About " + PROGRAM + "#", PROGRAM + ' version 2.0' + CRLF + Chr(169) + COPYRIGHT, ;
					LoadTrayIcon(GetInstance(), "ICON_1", 32, 32) )

		DEFINE NOTIFY MENU
			ITEM 'Stop/Start Timer'	ACTION UpdateTimer() NAME Timer CHECKED
			ITEM 'OnLine Check'	ACTION UpdateNotify()
			SEPARATOR	
			ITEM 'About...'		ACTION MsgInfo(PROGRAM + ' version 2.0' + CRLF + Chr(169) + COPYRIGHT, ;
								'Built with Harbour and MiniGUI')
			ITEM 'Exit'		ACTION Form_1.Release
		END MENU

		DEFINE TIMER Timer_1 ;
			INTERVAL 10000 ;
			ACTION UpdateNotify()

	END WINDOW

	ACTIVATE WINDOW Form_1

RETURN

// Flags for InternetGetConnectedState and Ex

#define INTERNET_CONNECTION_MODEM       1
#define INTERNET_CONNECTION_LAN         2
#define INTERNET_CONNECTION_PROXY       4
#define INTERNET_CONNECTION_MODEM_BUSY  8 /* no longer used */
#define INTERNET_RAS_INSTALLED         16
#define INTERNET_CONNECTION_OFFLINE    32
#define INTERNET_CONNECTION_CONFIGURED 64

// Flag for InternetCheckConnection

#define FLAG_ICC_FORCE_CONNECTION       1

*--------------------------------------------------------*
FUNCTION IsConnected()
*--------------------------------------------------------*
	LOCAL nFlags := 0, lRet := .F.

	IF InternetGetConnectedState( @nFlags, 0 )
/*
		if nFlags == INTERNET_CONNECTION_CONFIGURED + INTERNET_RAS_INSTALLED + INTERNET_CONNECTION_PROXY + INTERNET_CONNECTION_LAN
			MsgInfo( "Internet Connection via LAN" )
		endif
*/
		IF InternetCheckConnection( "https://harbour.github.io", FLAG_ICC_FORCE_CONNECTION, 0 )

			lRet := .T.
		ENDIF

	ENDIF
  
RETURN lRet

*--------------------------------------------------------*
PROCEDURE UpdateNotify()
*--------------------------------------------------------*

	Form_1.NotifyIcon := 'ICON_1'
	INKEYGUI( 100 )
	Form_1.NotifyIcon := iif( IsConnected(), "ICON_GREEN", "ICON_RED" )

RETURN

*--------------------------------------------------------*
PROCEDURE UpdateTimer()
*--------------------------------------------------------*

	lTimer := !lTimer

	Form_1.Timer.Checked := lTimer
	Form_1.Timer_1.Enabled := lTimer

	Form_1.NotifyTooltip := PROGRAM + TIMER_INFO + iif( lTimer, "On", "Off" )

RETURN


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

/*****************************************************************************************
*   MACRO DEFINITION FOR CALL DLL FUNCTION
******************************************************************************************/

#define HMG_DEFINE_DLL_FUNC(\
                             _FUNC_NAME,             \
                             _DLL_LIBNAME,           \
                             _DLL_FUNC_RET,          \
                             _DLL_FUNC_TYPE,         \
                             _DLL_FUNC_NAMESTRINGAW, \
                             _DLL_FUNC_PARAM,        \
                             _DLL_FUNC_CALLPARAM,    \
                             _DLL_FUNC_RETFAILCALL   \
                            )\
\
_DLL_FUNC_RET _DLL_FUNC_TYPE _FUNC_NAME _DLL_FUNC_PARAM \
{\
   typedef _DLL_FUNC_RET (_DLL_FUNC_TYPE *PFUNC) _DLL_FUNC_PARAM;\
   static PFUNC pfunc = NULL;\
   if( pfunc == NULL )\
   {\
      HMODULE hLib = LoadLibrary( _DLL_LIBNAME );\
      pfunc = (PFUNC) GetProcAddress( hLib, _DLL_FUNC_NAMESTRINGAW );\
   }\
   if( pfunc == NULL )\
      return( (_DLL_FUNC_RET) _DLL_FUNC_RETFAILCALL );\
   else\
      return pfunc _DLL_FUNC_CALLPARAM;\
}

HMG_DEFINE_DLL_FUNC( win_InternetGetConnectedState,                      // user function name
                     "Wininet.dll",                                      // dll name
                     BOOL,                                               // function return type
                     WINAPI,                                             // function type
                     "InternetGetConnectedState",                        // dll function name
                     (LPDWORD lpdwFlags, DWORD dwReserved),              // dll function parameters (types and names)
                     (lpdwFlags, dwReserved),                            // function parameters (only names)
                     FALSE                                               // return value if fail call function of dll
                   )

HMG_DEFINE_DLL_FUNC( win_InternetCheckConnection,                        // user function name
                     "Wininet.dll",                                      // dll name
                     BOOL,                                               // function return type
                     WINAPI,                                             // function type
                     "InternetCheckConnectionA",                         // dll function name
                     (LPCSTR lpszUrl, DWORD dwFlags, DWORD dwReserved),  // dll function parameters (types and names)
                     (lpszUrl, dwFlags, dwReserved),                     // function parameters (only names)
                     FALSE                                               // return value if fail call function of dll
                   )

HB_FUNC ( INTERNETGETCONNECTEDSTATE )
{
   DWORD dwFlags    = 0;
   DWORD dwReserved = hb_parnl( 2 );

   hb_retl( ( BOOL ) win_InternetGetConnectedState( &dwFlags, dwReserved ) );
   if( HB_ISBYREF( 1 ) )
       hb_stornl( dwFlags, 1 );
}

HB_FUNC ( INTERNETCHECKCONNECTION )
{
   char * lpszUrl   = ( char * ) hb_parc( 1 );
   DWORD dwFlags    = hb_parnl( 2 );
   DWORD dwReserved = hb_parnl( 3 );

   hb_retl( ( BOOL ) win_InternetCheckConnection( lpszUrl, dwFlags, dwReserved ) );
}

#pragma ENDDUMP
