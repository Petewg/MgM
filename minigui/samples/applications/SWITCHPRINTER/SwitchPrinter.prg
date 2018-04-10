/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2002-2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'Switch Printer'
#define VERSION ' version 1.2'
#define COPYRIGHT ' Grigory Filatov, 2002-2009'
#define NTRIM( n ) LTrim( Str( n ) )

Static aAllPrinters := {}, cDefaultPrinter := "", ;
	lShowWindow := .T., nTop := 0, nLeft := 0, cCfgFile := "SwitchPrinter.ini"

*--------------------------------------------------------*
Procedure Main( lStartUp )
*--------------------------------------------------------*
	Local lWinRun := .F.
	
	SET MULTIPLE OFF WARNING
	
	If !Empty(lStartUp) .AND. Upper(Substr(lStartUp, 2)) == "STARTUP" .OR. ;
		!Empty(GETREGVAR( NIL, "Software\Microsoft\Windows\CurrentVersion\Run", "Switch Printer" ))
		lWinRun := .T.
	EndIf

	cCfgFile := cFilePath(GetExeFileName()) + "\" + cCfgFile
	IF FILE(cCfgFile)
		BEGIN INI FILE cCfgFile
			GET lShowWindow SECTION "Position" ENTRY "ShowWindow" DEFAULT lShowWindow
			GET nTop SECTION "Position" ENTRY "Top" DEFAULT nTop
			GET nLeft SECTION "Position" ENTRY "Left" DEFAULT nLeft
		END INI
	ENDIF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		MAIN NOSHOW ;
		NOTIFYICON "MAINICON" ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK SwitchMenu() ;
		ON INIT IF(lShowWindow, SetFloatWin(), ) ;
		ON RELEASE SavePos(.f.)
		
	DEFINE NOTIFY MENU
		ITEM '&About...'		ACTION ShellAbout( "", ;
				PROGRAM + VERSION + CRLF + ;
				"Copyright " + Chr(169) + COPYRIGHT, LoadIconByName( "MAINICON", 32, 32 ) )
		SEPARATOR

		ITEM 'Auto&Run'		ACTION {|| lWinRun := !lWinRun, ;
				Form_1.Auto_Run.Checked := lWinRun, WinRun(lWinRun) } ;
				NAME Auto_Run
		SEPARATOR

		ITEM '&Show float window'	ACTION {|| lShowWindow := !lShowWindow, SetFloatWin() } ;
				NAME Float_Win

		SEPARATOR	

		ITEM 'E&xit'			ACTION Form_1.Release
	END MENU

	Form_1.Auto_Run.Checked := lWinRun
	Form_1.Float_Win.Checked := lShowWindow

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Procedure SwitchMenu()
*--------------------------------------------------------*
	Local nItem, cItem, cAction, cActCheck, nActCheck := 1, ;
		aPos, hMainWnd := GetFormHandle("Form_1")

	aAllPrinters := aAllPrinters()

	DEFINE CONTEXT MENU OF Form_1

		For nItem := 1 To Len(aAllPrinters)
			if aAllPrinters[nItem][3]
				nActCheck := nItem
			endif
			cAction := 'SetDefault(' + NTRIM(nItem) + ')'
			cItem := 'Item_' + NTRIM(nItem)
			ITEM "&"+aAllPrinters[nItem][1]	ACTION &cAction ;
				NAME &cItem
		Next

		IF Len(aAllPrinters) = 0
			ITEM '&Printers is NOT installed'	ACTION _dummy()
		ELSE
			SEPARATOR
			ITEM '&Close Menu'			ACTION _dummy()
		ENDIF

	END MENU

	IF Len(aAllPrinters) > 0
		cActCheck := 'Item_' + NTRIM(nActCheck)
		SetProperty("Form_1", cActCheck, "Checked", .T.)
		Form_1.NotifyTooltip := aAllPrinters[nActCheck][1]
	ENDIF

	aPos := GetCursorPos()

	TrackPopupMenu ( _hmg_aFormContextMenuHandle[Ascan( _hmg_aFormhandles, hMainWnd )], ;
			aPos[2], aPos[1], hMainWnd )

Return

*--------------------------------------------------------*
Procedure SetFloatWin()
*--------------------------------------------------------*
   Local n, btn, cAction, nCheck := 1, nCnt := 1

   IF !IsWindowDefined( Form_2 )

	IF Len( aAllPrinters := aAllPrinters() ) == 0
		MsgStop( 'Printers is NOT installed!' )
		Return
	ENDIF
	nCnt += Len(aAllPrinters)

	DEFINE WINDOW Form_2 			;
		AT nTop,nLeft 			;
		WIDTH 0 HEIGHT 42			;
		CHILD NOCAPTION NOMINIMIZE		;
		NOMAXIMIZE NOSIZE			;
		TOPMOST				;
		ON RELEASE ( nTop := GetWindowRow( GetFormHandle("Form_2") ), ;
				nLeft := GetWindowCol( GetFormHandle("Form_2") ), ;
				SavePos() )

		DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 38, 32 FLAT RIGHTTEXT

			BUTTON Button_0 ;
				CAPTION "Drag float window" ;
				PICTURE 'Logo' ;
				ACTION ( InterActiveMoveHandle( GetFormHandle("Form_2") ), ;
					Form_2.Button_0.Value := .F. ) ;
				CHECK SEPARATOR

		For n := 1 To Len(aAllPrinters)
			btn := 'Button_' + NTRIM( n )
			cAction := 'SetDefault(' + NTRIM(n) + ')'
			nCheck := IF(aAllPrinters[n][3], n, nCheck)
			BUTTON &btn ;
				CAPTION aAllPrinters[n][1] ;
				PICTURE if(aAllPrinters[n][3], 'Prn_On', 'Prn_Off') ;
				ACTION &cAction ;
				CHECK GROUP
		Next

		END TOOLBAR

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 ;
			ACTION IF( cDefaultPrinter # GetDefPrinter(), ( Form_2.Release, SetFloatWin() ), )
	
	END WINDOW

	cDefaultPrinter := aAllPrinters[nCheck][1]

	Form_2.Width := 38 * nCnt + 2 * nCnt + 8
	btn := 'Button_' + NTRIM( nCheck )
	SetProperty("Form_2", btn, "Value", aAllPrinters[nCheck][3])
	Form_1.Float_Win.Checked := .T.

	ACTIVATE WINDOW Form_2

   ELSE

	Form_2.Release
	Form_1.Float_Win.Checked := .F.

   ENDIF

Return

*--------------------------------------------------------*
Procedure SavePos( lPos )
*--------------------------------------------------------*
   DEFAULT lPos TO .T.

   BEGIN INI FILE cCfgFile
	IF lPos
		SET SECTION "Position" ENTRY "Top" TO nTop
		SET SECTION "Position" ENTRY "Left" TO nLeft
	ELSE
		SET SECTION "Position" ENTRY "ShowWindow" TO lShowWindow
	ENDIF
   END INI

Return

*--------------------------------------------------------*
Function SetDefault(nI)
*--------------------------------------------------------*
Return PrnSetDefault( aAllPrinters[nI][1], aAllPrinters[nI][2] )

#define HWND_BROADCAST (-1)
#define WM_WININICHANGE           26    // 0x001A
*--------------------------------------------------------*
Procedure PrnSetDefault( cName, cPort )
*--------------------------------------------------------*
    LOCAL cPrnStr := cName + "," + PrnGetDriver( cName ) + "," + cPort

    Form_1.NotifyTooltip := cName

    IF !IsWinNT()
	SETREGVAR( HKEY_CURRENT_CONFIG, ;
		"System\CurrentControlSet\Control\Print\Printers", "Default", cName )
    ENDIF

    IF WriteProfileString( "Windows", "Device", cPrnStr )
	SendMessage( HWND_BROADCAST, WM_WININICHANGE, 0, "Windows" )
    ENDIF

    IF IsWindowDefined( Form_2 )
	Form_2.Release
	SetFloatWin()
    ENDIF

Return

*--------------------------------------------------------*
Function PrnGetDriver( cPrnName )
*--------------------------------------------------------*
    LOCAL cDriver := GETREGVAR( HKEY_LOCAL_MACHINE, ;
      "System\CurrentControlSet\Control\Print\Environments\Windows 4.0\Drivers\" + cPrnName, ;
      "Driver" )

Return SubStr( cDriver, 1, At( ".", cDriver ) - 1 )

*--------------------------------------------------------*
Function aAllPrinters()
*--------------------------------------------------------*
    LOCAL aPrinters := {}, aPrn := Asort( GetAllPrinters() ), ;
	i, name, cDefPrn := GetDefPrinter()

    For i := 1 To Len(aPrn)
	name := Token(aPrn[i], ",", 1)
    	Aadd( aPrinters, { name, Token(aPrn[i], ",", 2), name == cDefPrn } )
    Next

Return( aPrinters )

*--------------------------------------------------------*
Function GetDefPrinter()
*--------------------------------------------------------*
Return IF( IsWinNT(), GetDefaultPrinter(), ;
	GETREGVAR( HKEY_CURRENT_CONFIG, ;
		"System\CurrentControlSet\Control\Print\Printers", "Default" ) )

#define WM_SYSCOMMAND	274
#define SC_CLOSE	61536
*-----------------------------------------------------------------------------*
Function _ReleaseWindow (FormName)
*-----------------------------------------------------------------------------*
Local FormCount , b , i , x

	b := _HMG_InteractiveClose
	_HMG_InteractiveClose := 1

	FormCount := len (_HMG_aFormHandles)

	If .Not. _IsWindowDefined (Formname)
		MsgMiniGuiError("Window: "+ FormName + " is not defined. Program terminated" )
	Endif

	If .Not. _IsWindowActive (Formname)
		MsgMiniGuiError("Window: "+ FormName + " is not active. Program terminated" )
	Endif

	If _HMG_ThisEventType == 'WINDOW_RELEASE' 
		If GetFormIndex (FormName) == _HMG_ThisIndex
			MsgMiniGuiError("Release a window in its own 'on release' procedure or release the main window in any 'on release' procedure is not allowed. Program terminated" )
		EndIf
	EndIf

	* If the window to release is the main application window, release all
	* windows command will be executed
	
	If GetWindowType (FormName) == 'A'

		If _HMG_ThisEventType == 'WINDOW_RELEASE' 
			MsgMiniGuiError("Release a window in its own 'on release' procedure or release the main window in any 'on release' procedure is not allowed. Program terminated" )
		Else
			ReleaseAllWindows()
		EndIf

	EndIf

	i := GetFormIndex ( Formname )

	* Release Window

	if	_hmg_aformtype [i] == 'M'	;
		.and.				;
		_hmg_activemodalhandle <> _hmg_aformhandles [i]

			EnableWindow ( _hmg_aformhandles [i] )
			SendMessage( _hmg_aformhandles [i] , WM_SYSCOMMAND, SC_CLOSE, 0 )

	Else

		For x := 1 To FormCount
			if _hmg_aFormParentHandle [x] == _hmg_aformhandles [i]
				_hmg_aFormParentHandle [x] := _hmg_MainHandle
			EndIf
		Next x
		     
		EnableWindow ( _hmg_aformhandles [i] )
		SendMessage( _hmg_aformhandles [i] , WM_SYSCOMMAND, SC_CLOSE, 0 )

	EndIf

	_HMG_InteractiveClose := b

Return Nil

*--------------------------------------------------------*
FUNCTION Token( cString, cDelimiter, nPointer )
*--------------------------------------------------------*
RETURN AllToken( cString, cDelimiter, nPointer, 1 )

*--------------------------------------------------------*
FUNCTION AllToken( cString, cDelimiter, nPointer, nAction )
*--------------------------------------------------------*
LOCAL nTokens := 0, nPos := 1, nLen := len( cString ), nStart, cRet
DEFAULT cDelimiter to chr(0)+chr(9)+chr(10)+chr(13)+chr(26)+chr(32)+chr(138)+chr(141)
DEFAULT nAction to 0

// nAction == 0 - numtoken
// nAction == 1 - token
// nAction == 2 - attoken

      while nPos <= nLen
            if .not. substr( cString, nPos, 1 ) $ cDelimiter
               nStart := nPos
               while nPos <= nLen .and. .not. substr( cString, nPos, 1 ) $ cDelimiter
                     ++nPos
               enddo
               ++nTokens
               IF nAction > 0
                  IF nPointer == nTokens
                     IF nAction == 1
                        cRet := substr( cString, nStart, nPos - nStart )
                     ELSE
                        cRet := nStart
                     ENDIF
                     exit
                  ENDIF
               ENDIF
            endif
            if substr( cString, nPos, 1 ) $ cDelimiter
               while nPos <= nLen .and. substr( cString, nPos, 1 ) $ cDelimiter
                     ++nPos
               enddo
            endif
            cRet := nTokens
      ENDDO

RETURN cRet

*--------------------------------------------------------*
Static Procedure WinRun(lMode)
*--------------------------------------------------------*
   Local cRunName := Upper( GetModuleFileName( GetInstance() ) ) + " /STARTUP", ;
         cRunKey  := "Software\Microsoft\Windows\CurrentVersion\Run", ;
         cRegKey  := GETREGVAR( NIL, cRunKey, "Switch Printer" )

   IF IsWinNT()
      EnablePermissions()
   ENDIF
   IF lMode
      IF Empty(cRegKey) .OR. cRegKey # cRunName
         SETREGVAR( NIL, cRunKey, "Switch Printer", cRunName )
      ENDIF
   ELSE
      DELREGVAR( NIL, cRunKey, "Switch Printer" )
   ENDIF

Return

*--------------------------------------------------------*
STATIC FUNCTION GETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

Return( cValue )

*--------------------------------------------------------*
STATIC FUNCTION SETREGVAR(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   uValue := IF(uValue == NIL, "", uValue)
   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Set(cSubKey, uValue)
   oReg:Close()

Return( cValue )

*--------------------------------------------------------*
STATIC FUNCTION DELREGVAR(nKey, cRegKey, cSubKey)
*--------------------------------------------------------*
   LOCAL oReg, nValue

   nKey := IF(nKey == NIL, HKEY_CURRENT_USER, nKey)
   oReg := TReg32():New(nKey, cRegKey)
   nValue := oReg:Delete(cSubKey)
   oReg:Close()

Return( nValue )


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#ifdef __XHARBOUR__
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#define ISCHAR( n )         HB_ISCHAR( n )
#endif

HB_FUNC( GETDEFAULTPRINTER )
{
	char PrinterDefault[128] ;
	OSVERSIONINFO osvi;
	DWORD Needed, Returned;
	DWORD BuffSize = 256;
	LPPRINTER_INFO_5 PrinterInfo;
	char* p;

	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
	GetVersionEx(&osvi);

	if (osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS)
	{
		EnumPrinters(PRINTER_ENUM_DEFAULT,NULL,5,NULL,0,&Needed,&Returned);
		PrinterInfo = (LPPRINTER_INFO_5) LocalAlloc(LPTR,Needed);
		EnumPrinters(PRINTER_ENUM_DEFAULT,NULL,5,(LPBYTE) PrinterInfo,Needed,&Needed,&Returned);
		strcpy(PrinterDefault,PrinterInfo->pPrinterName);
		LocalFree(PrinterInfo);
	}
	else if (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT)
	{
		if (osvi.dwMajorVersion >= 5) 
		{
			GetDefaultPrinter(PrinterDefault,&BuffSize);
		}
		else 
		{
			GetProfileString("windows","device","",PrinterDefault,BuffSize);
			p = PrinterDefault;
			while (*p != '0' && *p != ',')
				++p;
			*p = '0';
		}
	}

	hb_retc(PrinterDefault);
}

HB_FUNC( GETALLPRINTERS )
{
	OSVERSIONINFO osvi;
	DWORD dwSize = 0;
	DWORD dwPrinters = 0;
	DWORD i;
	LPBYTE pBuffer ;
	HGLOBAL cBuffer ;
	PRINTER_INFO_5* pInfo;
	DWORD flags;

	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
	GetVersionEx(&osvi);

	if (osvi.dwPlatformId == VER_PLATFORM_WIN32_NT)
		flags = PRINTER_ENUM_CONNECTIONS|PRINTER_ENUM_LOCAL;
	else
		flags = PRINTER_ENUM_LOCAL;

	EnumPrinters(flags, NULL, 5, NULL, 0, &dwSize, &dwPrinters);
	pBuffer = GlobalAlloc(GPTR, dwSize);
	if (pBuffer == NULL)
	{
		hb_reta(0);
		return;
	}

	EnumPrinters(flags, NULL, 5, pBuffer, dwSize, &dwSize, &dwPrinters);
	if (dwPrinters == 0)
	{
		hb_reta(0);
		return;
	}

	pInfo = (PRINTER_INFO_5*)pBuffer;

	hb_reta( dwPrinters );

	for ( i = 0; i < dwPrinters; i++, pInfo++)
	{
		cBuffer = ( char * ) GlobalAlloc(GPTR, 256);

		strcat(cBuffer,pInfo->pPrinterName);
		strcat(cBuffer,",");
		strcat(cBuffer,pInfo->pPortName);

		HB_STORC( cBuffer , -1 , i+1 ); 

		GlobalFree(cBuffer);
	}

	GlobalFree(pBuffer);
}

HB_FUNC( ENABLEPERMISSIONS )
{
	LUID tmpLuid;
	TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
	DWORD lBufferNeeded;
	HANDLE hdlTokenHandle;
	HANDLE hdlProcessHandle = GetCurrentProcess();

	OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

	LookupPrivilegeValue(NULL, "SeSystemEnvironmentPrivilege", &tmpLuid);

	tkp.PrivilegeCount            = 1;
	tkp.Privileges[0].Luid        = tmpLuid;
	tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

	AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC( WRITEPROFILESTRING )
{
	const char * lpSection = hb_parc( 1 );
	const char * lpEntry = ISCHAR(2) ? hb_parc( 2 ) : NULL ;
	const char * lpData = ISCHAR(3) ? hb_parc( 3 ) : NULL ;

	if ( WriteProfileString( lpSection, lpEntry, lpData) )
		hb_retl( TRUE );
	else
		hb_retl( FALSE );
}

HB_FUNC( INTERACTIVEMOVEHANDLE )
{
	keybd_event(
		VK_RIGHT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);
	keybd_event(
		VK_LEFT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	SendMessage( (HWND) hb_parnl(1), WM_SYSCOMMAND, SC_MOVE, 10 );
}

#pragma ENDDUMP
