/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Win32 Cleanup API
 * Copyright 2006 Marcel Lambert <mlambert@synaptex.biz>
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'Test Client for Win32 Cleanup API'
#define COPYRIGHT ' 2006 Grigory Filatov'

#define IDI_MAIN 101
*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 311 HEIGHT IF(IsThemed(), 334, 328) ;
		TITLE PROGRAM ;
		ICON IDI_MAIN ;
		MAIN NOMAXIMIZE NOMINIMIZE NOSIZE ;
		FONT "MS Sans serif" SIZE 8

		@268, 58 BUTTON Btn_1 CAPTION "About" WIDTH 74 HEIGHT 24 ACTION MsgAbout() DEFAULT

		@268,178 BUTTON Btn_2 CAPTION "Cancel" WIDTH 74 HEIGHT 24 ACTION Form_1.Release()

		@ 38,12 BUTTON BUTTON_CLEANUP_IE_CACHE CAPTION "IE Cache" WIDTH 282 HEIGHT 22 ACTION Delete_IECache(1, 0)

		@ 70,12 BUTTON BUTTON_CLEANUP_IE_COOKIES CAPTION "IE Cookies" WIDTH 282 HEIGHT 22 ACTION Delete_IECookies(1, 0)

		@102,12 BUTTON BUTTON_CLEANUP_IE_HISTORY CAPTION "IE History" WIDTH 282 HEIGHT 22 ACTION ( RunMessage(1), Delete_IEHistory(1, 0) )

		@134,12 BUTTON BUTTON_CLEANUP_IE_ADDRESS_BAR CAPTION "IE Address Bar History" WIDTH 282 HEIGHT 22 ACTION Delete_IEAddressBarHistory()

		@166,12 BUTTON BUTTON_CLEANUP_RUN_HISTORY CAPTION "Desktop Run History" WIDTH 282 HEIGHT 22 ACTION ( Delete_DesktopRunHistory(), RunMessage(2) )

		@198,12 BUTTON BUTTON_CLEANUP_RECENT_DOCS CAPTION "Desktop Recent Docs History" WIDTH 282 HEIGHT 22 ACTION Delete_DesktopRecentDocsHistory()

		@230,12 BUTTON BUTTON_CLEANUP_RECYCLE_BIN CAPTION "Recycle Bin" WIDTH 282 HEIGHT 22 ACTION Delete_DesktopRecycleBinContents()

		@ 12,12 LABEL Label_1 VALUE "Cleanup for:" WIDTH 282 HEIGHT 16 CENTERALIGN

		ON KEY ESCAPE ACTION Form_1.Btn_2.OnClick

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure RunMessage(nMsg)
*--------------------------------------------------------*
Local strMsg := ""

	IF nMsg == 1
		strMsg += "IE History is usually locked by Windows Explorer and IE. " + CRLF
		strMsg += "To test this function, please kill 'explorer' and 'iexplore' " + CRLF
		strMsg += "processes with Task Manager.   Note: you can easily " + CRLF
		strMsg += "restore shell by typing 'explorer' in File/New task ...  " + CRLF
		strMsg += "of Task Manager."
	ELSE
		strMsg += "Run History has been cleaned up. You can see the " + CRLF
		strMsg += "results after logoff/logon or after reboot."
	ENDIF

	MsgInfo( strMsg, , , .f. )

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*

Return MsgInfo( PROGRAM + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + ;
	Chr(169) + " Cleanup API by Marcel Lambert" + CRLF + CRLF + ;
	hb_compiler() + CRLF + ;
	version() + CRLF + ;
	SubStr(MiniGuiVersion(), 1, 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 40), "About", IDI_MAIN, .f. )

#define DLL_TYPE_HRESULT      -4 
*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_BOOL Delete_IECache( DLL_TYPE_BOOL bDeleteCache, DLL_TYPE_BOOL bDeleteCacheIndex ) ;
	IN CLEANUP.DLL

DECLARE DLL_TYPE_BOOL Delete_IECookies( DLL_TYPE_BOOL bDeleteCookies, DLL_TYPE_BOOL bDeleteCookiesIndex ) ;
	IN CLEANUP.DLL

DECLARE DLL_TYPE_HRESULT Delete_IEHistory( DLL_TYPE_BOOL bDeleteHistory, DLL_TYPE_BOOL bDeleteHistoryIndex ) ;
	IN CLEANUP.DLL
*-----------------------------------------------------------------------------*


#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#include "shlobj.h"   // SHAddToRecentDocs
#include "shellapi.h" // SHEmptyRecycleBin
#include "tchar.h"    // _T macro

HB_FUNC ( DELETE_IEADDRESSBARHISTORY )
{
	HKEY hKey;
	DWORD dwResult;
	TCHAR szValueName[10];
	int i = 1;

	// Open TypedURLs key.
	dwResult = RegOpenKey(HKEY_CURRENT_USER,
		            "Software\\Microsoft\\Internet Explorer\\TypedURLs", &hKey);

	if (hKey)
	{
		wsprintf(szValueName, "url%d", i); 

		while(RegDeleteValue(hKey, szValueName) == ERROR_SUCCESS) 
		{
			i++; wsprintf(szValueName, "url%d", i);
		}

		RegCloseKey(hKey); 
	}
	hb_retnl((DWORD) dwResult);
}

HB_FUNC ( DELETE_DESKTOPRECENTDOCSHISTORY )
{
    SHAddToRecentDocs(SHARD_PATH, NULL /* NULL clears history */);
}

// Note: actually, effect of running Delete_DesktopRunHistory is 
// visible after reboot. 

HB_FUNC ( DELETE_DESKTOPRUNHISTORY )
{
	HKEY hKey;
	DWORD dwResult;

	// Open RunMRU key.
	dwResult = RegOpenKey(HKEY_CURRENT_USER,
		        "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU", &hKey );

	if (hKey)
	{
		// Traverse all possible values and delete. This guarantees deletion
		// even if the sequence in broken.
		RegDeleteValue(hKey, "a");
		RegDeleteValue(hKey, "b");
		RegDeleteValue(hKey, "c");
		RegDeleteValue(hKey, "d");
		RegDeleteValue(hKey, "e");
		RegDeleteValue(hKey, "f");
		RegDeleteValue(hKey, "g");
		RegDeleteValue(hKey, "h");
		RegDeleteValue(hKey, "i");
		RegDeleteValue(hKey, "j");
		RegDeleteValue(hKey, "k");
		RegDeleteValue(hKey, "l");
		RegDeleteValue(hKey, "m");
		RegDeleteValue(hKey, "n");
		RegDeleteValue(hKey, "o");
		RegDeleteValue(hKey, "p");
		RegDeleteValue(hKey, "q");
		RegDeleteValue(hKey, "r");
		RegDeleteValue(hKey, "s");
		RegDeleteValue(hKey, "t");
		RegDeleteValue(hKey, "u");
		RegDeleteValue(hKey, "v");
		RegDeleteValue(hKey, "w");
		RegDeleteValue(hKey, "x");
		RegDeleteValue(hKey, "y");
		RegDeleteValue(hKey, "z");

		RegDeleteValue(hKey, _T("MRUList"));

		RegCloseKey(hKey); 
	}
	hb_retnl((DWORD) dwResult);
}

HB_FUNC ( DELETE_DESKTOPRECYCLEBINCONTENTS )
{
	SHEmptyRecycleBin(NULL, NULL, 
		SHERB_NOCONFIRMATION | SHERB_NOPROGRESSUI | SHERB_NOSOUND);
}

#pragma ENDDUMP
