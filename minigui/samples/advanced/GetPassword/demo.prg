/*
 * MiniGUI GetPassword Demo
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Memvar cTargetName

// CredUI flags
#define SHOW_SAVE_CHECK_BOX	hb_HexToNum( "40" )
#define EXPECT_CONFIRMATION	hb_HexToNum( "20000" )
#define GENERIC_CREDENTIALS	hb_HexToNum( "40000" )
#define KEEP_USERNAME		hb_HexToNum( "100000" )

Procedure Main
Local cUserName := GetUserName() + Chr(0)
Local cPassword := "mypassword"
Local lSave := .T.
Local nFlags := hb_bitOr( KEEP_USERNAME, GENERIC_CREDENTIALS )

Private cTargetName

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON INIT OnInit()
	
		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Get Password' ACTION GetPassword( NIL, "Please input your login data", "User Login", NIL, cTargetName, @cUserName, @cPassword, lSave, SHOW_SAVE_CHECK_BOX )
				MENUITEM 'Get Password with User Logo' ACTION GetPassword( 0, , , LoadBitmap("LOGO"), cTargetName, @cUserName, @cPassword, , nFlags )
			END POPUP
		END MENU

	END WINDOW

	ACTIVATE WINDOW Win_1

Return


PROCEDURE OnInit

	IF !IsWinNT()
		MsgStop( 'This Program Runs In Win2000/XP Only!', 'Stop' )
		ReleaseAllWindows()
	ENDIF

	cTargetName := GetDomainName() + Chr(0)

	// debug message
//	MsgInfo( cTargetName, "Domain" )

RETURN


#define NO_ERROR			0 

#define ERROR_CANCELLED			1223 
#define ERROR_INVALID_FLAGS		1004 
#define ERROR_NO_SUCH_LOGON_SESSION	1312 

Function GetPassword( hWnd, cMessage, cCaption, hBitmap, cTargetName, /* @ */cUserName, /* @ */cPassword, lSave, nFlags )
Local pCredUI_Info 
Local cMsg, nPos
Local nResult

	Default hWnd := GetActiveWindow(), hBitmap := 0, lSave := .F., nFlags := 0
	Default cMessage := "My Message", cCaption := "My Caption"

	if ( nPos := At( "\", cUserName ) ) > 0
		cUserName := SubStr( cUserName, nPos + 1 )
	endif

	pCredUI_Info := CredUI_Info( hWnd, cMessage, cCaption, hBitmap )

	nResult := CredUIPrompt( pCredUI_Info, cTargetName, 0, @cUserName, @cPassword, @lSave, nFlags ) 

	if nResult == NO_ERROR
		cMsg := "User : " + cUserName + CRLF + ;
			"Password : " + cPassword
	elseif nResult == ERROR_CANCELLED
		cMsg := "User selected 'Cancel'." 
	elseif nResult == ERROR_INVALID_FLAGS
		cMsg := "ERROR_INVALID_FLAGS - take a look for documentation"
	elseif nResult == ERROR_INVALID_PARAMETER 
		cMsg := "ERROR_INVALID_PARAMETER - take a look for documentation"
	elseif nResult == ERROR_NO_SUCH_LOGON_SESSION 
		cMsg := "ERROR_NO_SUCH_LOGON_SESSION - take a look for documentation"
	else //-1000 
		cMsg := "Cannot load credui.dll"
	endif

	// result message
	MsgInfo( cMsg, "Result" )

	// cleanup
	pCredUI_Info := Nil

Return nResult


#pragma BEGINDUMP

#include <windows.h> 
#include "hbapi.h" 

#ifndef __XHARBOUR__
   #define ISBYREF( n )          HB_ISBYREF( n )
#endif

#define CREDUI_MAX_CAPTION_LENGTH 128 
#define CREDUI_MAX_MESSAGE_LENGTH 32767 

#define CREDUI_MAX_PASSWORD_LENGTH 256 
#define CREDUI_MAX_USERNAME_LENGTH 513 

typedef struct _CREDUI_INFO 
{ 
	DWORD cbSize; 
	HWND hwndParent; 
	PCTSTR pszMessageText; 
	PCTSTR pszCaptionText; 
	HBITMAP hbmBanner; 
} CREDUI_INFO, *PCREDUI_INFO; 

typedef DWORD (CALLBACK* CredUIPromptForCredentials)(PCREDUI_INFO, PCTSTR, void*, DWORD, PCTSTR, ULONG, PCTSTR, ULONG, BOOL*, DWORD ); 
static PCREDUI_INFO hb_parCredUI_Info( int iParam ); 

HB_FUNC( CREDUIPROMPT ) 
{ 
	HINSTANCE hDLL = LoadLibrary( "credui.dll" ); 
	LONG lRes = -1000L; 

	if ( hDLL ) 
	{ 
		CredUIPromptForCredentials CredUIPrompt = (CredUIPromptForCredentials) GetProcAddress(hDLL, "CredUIPromptForCredentialsA"); 

		if ( CredUIPrompt != NULL ) 
		{ 
			PCREDUI_INFO pUiInfo = hb_parCredUI_Info( 1 ); 
			LPSTR pszTargetName = (char *) hb_parc( 2 );
			DWORD dwAuthError = hb_parni( 3 ); 
			LPSTR pszUserName = (char *) hb_parcx( 4 );
			LPSTR pszPassword = (char *) hb_parcx( 5 );
			BOOL pfSave = hb_parl( 6 ); 
			DWORD dwFlags = hb_parni( 7 ); 

			char* szUserName = hb_xgrab( CREDUI_MAX_USERNAME_LENGTH + 1 ); 
			char* szPassword = hb_xgrab( CREDUI_MAX_PASSWORD_LENGTH + 1 ); 

			strcpy( szUserName, pszUserName ); 
			strcpy( szPassword, pszPassword ); 

			lRes = CredUIPrompt( pUiInfo, pszTargetName, NULL, dwAuthError, szUserName, CREDUI_MAX_USERNAME_LENGTH, szPassword, CREDUI_MAX_PASSWORD_LENGTH, &pfSave, dwFlags ); 

			hb_storc( szUserName, 4 ); 
			hb_storc( szPassword, 5 ); 

			hb_xfree( szUserName ); 
			hb_xfree( szPassword ); 

			if ( ISBYREF(6) ) 
			{ 
				hb_storl( pfSave, 6 ); 
			} 
		} 

		FreeLibrary( hDLL ); 
	} 

	hb_retnl( lRes ); 
} 

/* 
	destructors, it's executed automatically 
*/ 

static HB_GARBAGE_FUNC( hb_CREDUI_INFO_Destructor ) 
{ 
	PCREDUI_INFO * ppCredUI_Info = (PCREDUI_INFO*) Cargo; 

	if( ppCredUI_Info && *ppCredUI_Info ) 
	{ 
		PCREDUI_INFO pInfo = ( PCREDUI_INFO ) ppCredUI_Info; 

		hb_xfree( (LPSTR) pInfo->pszMessageText ); 
		hb_xfree( (LPSTR) pInfo->pszCaptionText ); 

		if( pInfo->hbmBanner != NULL ) 
		{ 
			DeleteObject( pInfo->hbmBanner ); 
			pInfo->hbmBanner = NULL; 
		} 

		*ppCredUI_Info = NULL; 
	} 
} 

static const HB_GC_FUNCS s_gcCREDUI_INFOFuncs =
{
   hb_CREDUI_INFO_Destructor,
   hb_gcDummyMark
};

/* 
*/ 
static PCREDUI_INFO hb_parCredUI_Info( int iParam ) 
{ 
	PCREDUI_INFO pCredUI_Info = (PCREDUI_INFO) hb_parptrGC( &s_gcCREDUI_INFOFuncs, iParam ); 

	if( pCredUI_Info ) 
	{ 
		return pCredUI_Info; 
	} 
	else 
	{ 
		return NULL; 
	} 
} 

HB_FUNC( CREDUI_INFO ) 
{ 
	CREDUI_INFO CredUI_Info = { 0 }; 
	PCREDUI_INFO pCredUI_Info; 

	CredUI_Info.cbSize = sizeof( CREDUI_INFO ); 
	CredUI_Info.hwndParent = ( HWND ) hb_parnl( 1 ); 
	CredUI_Info.pszMessageText = hb_strndup( hb_parc(2), CREDUI_MAX_MESSAGE_LENGTH - 1); 
	CredUI_Info.pszCaptionText = hb_strndup( hb_parc(3), CREDUI_MAX_CAPTION_LENGTH - 1); 

	//Note: The bitmap size is limited to 320x60 pixels. 
	if( GetObjectType((HGDIOBJ) hb_parnl(4)) == OBJ_BITMAP ) 
	{ 
		CredUI_Info.hbmBanner = ( HBITMAP ) hb_parnl( 4 ); 
	} 

	pCredUI_Info = ( PCREDUI_INFO ) hb_gcAllocate( sizeof(CREDUI_INFO), &s_gcCREDUI_INFOFuncs ); 
	*pCredUI_Info = CredUI_Info; 

	hb_retptrGC( (void*) pCredUI_Info );
} 

#pragma ENDDUMP

#pragma BEGINDUMP

#ifndef UNICODE
#define UNICODE
#endif

#ifndef _BCC_LINK_LIB
#define _BCC_LINK_LIB  "C:\Borland\BCC55\Lib\PSDK\netapi32.lib"  // If necessary define adequate path in your application before include header files
#endif
#pragma comment (lib, _BCC_LINK_LIB)   // for Borland C Compiler

#include <windows.h> 
#include <lm.h>

#include "hbapi.h"

HB_FUNC( GETDOMAINNAME )
{
	DWORD dwLevel = 100;
	LPWKSTA_INFO_100 pBuf = NULL;
	NET_API_STATUS nStatus;
	LPWSTR pszServerName = NULL;
	char buffer[ 255 ];
	int nLen;

	// getting domain/workgroup name
	nStatus = NetWkstaGetInfo( pszServerName, dwLevel, (LPBYTE *)&pBuf );
	// If the call is successful, return the workstation data
	if( nStatus == NERR_Success )
	{
		nLen = WideCharToMultiByte( CP_ACP, 0, pBuf->wki100_langroup, -1, NULL, 0, NULL, NULL );
		WideCharToMultiByte( CP_ACP, 0, pBuf->wki100_langroup, -1, buffer, nLen, NULL, NULL );	// workgroup or domain name
		hb_retclen_buffer( buffer, nLen - 1 );
	}
	// show the error
	else
	{
		MessageBox( NULL, TEXT( "Error while getting domain name." ), TEXT( "Error" ), MB_OK | MB_ICONSTOP );
	}

	// Free the allocated memory
	if( pBuf != NULL )
		NetApiBufferFree(pBuf);
}

#pragma ENDDUMP
