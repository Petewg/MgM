/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2007-2011 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'SysInfoTray'
#define VERSION ' version 1.01'
#define COPYRIGHT ' Grigory Filatov, 2007-2011'

#define NTRIM( n ) LTrim( Str( n ) )

#define GFSR_SYSTEMRESOURCES	0
#define GFSR_GDIRESOURCES	1
#define GFSR_USERRESOURCES	2

#define ICON_1		1001
#define ICON_2		1002
#define ICON_3		1003
#define ICON_4		1004
#define ICON_5		1005
#define ICON_6		1006
#define ICON_7		1007
#define ICON_8		1008
#define ICON_9		1009
#define ICON_10		1010
#define ICON_11		1011
#define ICON_12		1012

Static oReg, nTotalMem, cCfgFile, nShow

DECLARE WINDOW Form_1

Function Main()
Local lWinNT := IsWinNT()

	SET MULTIPLE OFF

	SET MENUSTYLE EXTENDED

	SetMenuTheme()

	SET EVENTS FUNCTION TO MYEVENTS

	nTotalMem := MemoryStatus(1) + 1
	cCfgFile := GetStartUpFolder() + "\SysInfoTray.ini"
	nShow := IF( lWinNT, 4, 1 )
	oReg := InitCpu()

	IF .not. lWinNT .and. FILE(cCfgFile)
		BEGIN INI FILE cCfgFile
			GET nShow SECTION "Data" ENTRY "Show" DEFAULT nShow
		END INI
	ENDIF

	DEFINE WINDOW Form_1 						;
		AT 0,0 							;
		WIDTH 0 HEIGHT 0 					;
		TITLE PROGRAM 						;
		MAIN NOSHOW 						;
		ON INIT UpdateNotify() 					;
		ON RELEASE ( EndCpu(), IF( lWinNT, , SaveParam() ) ) 	;
		NOTIFYICON 'MAIN' 					;
		NOTIFYTOOLTIP PROGRAM 					;
		ON NOTIFYCLICK IF( lWinNT, , ShowFreeResources() )

		DEFINE NOTIFY MENU 
			ITEM 'GDI Resources'	 ACTION {|| nShow := 1, ;
				Form_1.Sys.Checked := .F., ;
				Form_1.User.Checked := .F., ;
				Form_1.CPU.Checked := .F., ;
				Form_1.GDI.Checked := .T., UpdateNotify() } ;
				NAME GDI CHECKMARK "CHECK"
			ITEM 'System Resources'	 ACTION {|| nShow := 2, ;
				Form_1.User.Checked := .F., ;
				Form_1.CPU.Checked := .F., ;
				Form_1.GDI.Checked := .F., ;
				Form_1.Sys.Checked := .T., UpdateNotify() } ;
				NAME Sys CHECKMARK "CHECK"
			ITEM 'User Resources'	 ACTION {|| nShow := 3, ;
				Form_1.GDI.Checked := .F., ;
				Form_1.CPU.Checked := .F., ;
				Form_1.Sys.Checked := .F., ;
				Form_1.User.Checked := .T., UpdateNotify() } ;
				NAME User CHECKMARK "CHECK"
			ITEM 'CPU Usage'	 ACTION {|| nShow := 4, ;
				Form_1.Sys.Checked := .F., ;
				Form_1.User.Checked := .F., ;
				Form_1.GDI.Checked := .F., ;
				Form_1.CPU.Checked := .T., UpdateNotify() } ;
				NAME CPU CHECKMARK "CHECK"
			SEPARATOR	
			ITEM 'About...'		ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + VERSION + CRLF + ;
				Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) ) IMAGE "INFO"
			SEPARATOR	
			ITEM 'Exit'		ACTION Form_1.Release IMAGE "EXIT"
		END MENU

		IF lWinNT == .T.
			Form_1.Sys.Enabled := .F.
			Form_1.User.Enabled := .F.
			Form_1.GDI.Enabled := .F.
		ENDIF
		IF nShow == 1
			Form_1.GDI.Checked := .T.
		ELSEIF nShow == 2
			Form_1.Sys.Checked := .T.
		ELSEIF nShow == 3
			Form_1.User.Checked := .T.
		ELSE
			Form_1.CPU.Checked := .T.
		ENDIF

		DEFINE TIMER Timer_1 ;
			INTERVAL IF(lWinNT, 1, 2) * 1000 ;
			ACTION UpdateNotify()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return Nil

*--------------------------------------------------------*
Static Procedure SaveParam()
*--------------------------------------------------------*
   BEGIN INI FILE cCfgFile
	SET SECTION "Data" ENTRY "Show" TO nShow
   END INI

Return

*--------------------------------------------------------*
Static Procedure UpdateNotify()
*--------------------------------------------------------*
Local nUsage := CpuUsage()
Local nFreeMem := MemoryStatus(2)
Local iSystem := GetFreeSystemResources(GFSR_SYSTEMRESOURCES)
Local iGDI := GetFreeSystemResources(GFSR_GDIRESOURCES)
Local iUser := GetFreeSystemResources(GFSR_USERRESOURCES)

	iSystem := IFNUMBER(iSystem, iSystem, 0)
	iGDI := IFNUMBER(iGDI, iGDI, 0)
	iUser := IFNUMBER(iUser, iUser, 0)

	Form_1.NotifyTooltip := MemoryTooltip( nUsage, ;
		( nTotalMem - nFreeMem ) / nTotalMem * 100, nFreeMem )

	nUsage := IF(nShow == 1, iGDI, IF(nShow == 2, iSystem, IF(nShow == 3, iUser, nUsage)))
	Form_1.NotifyIcon := IconMeter( nUsage )

Return

*--------------------------------------------------------*
Static Function IconMeter( nUsed )
*--------------------------------------------------------*

Return IF( nUsed > 96, ICON_12, ;
       IF( nUsed > 87, ICON_11, ;
       IF( nUsed > 78, ICON_10, ;
       IF( nUsed > 69, ICON_9, ;
       IF( nUsed > 60, ICON_8, ;
       IF( nUsed > 51, ICON_7, ;
       IF( nUsed > 42, ICON_6, ;
       IF( nUsed > 33, ICON_5, ;
       IF( nUsed > 24, ICON_4, ;
       IF( nUsed > 15, ICON_3, ;
       IF( nUsed > 6, ICON_2, ;
		ICON_1 ) ) ) ) ) ) ) ) ) ) )

*--------------------------------------------------------*
Static Function MemoryTooltip( nUsage, nLoad, nFree )
*--------------------------------------------------------*

Return 'CPU Usage=' + Ltrim(Transform(nUsage, "999")) + ;
       '% Memory load=' + Ltrim(Transform(nLoad, "999")) + ;
       '% (' + Ltrim(Transform(nFree, "9999")) + ' MB Free)'

*--------------------------------------------------------*
Static Procedure ShowFreeResources()
*--------------------------------------------------------*
Local iSystem := GetFreeSystemResources(GFSR_SYSTEMRESOURCES)
Local iGDI := GetFreeSystemResources(GFSR_GDIRESOURCES)
Local iUser := GetFreeSystemResources(GFSR_USERRESOURCES)

IF ISNUMBER(iSystem) .and. ISNUMBER(iGDI) .and. ISNUMBER(iUser)
	MsgInfo( "Free GDI Resources: " + Chr(9) + NTRIM(iGDI) + "%" + CRLF + CRLF + ;
		"Free System Resources: " + Chr(9) + NTRIM(iSystem) + "%" + CRLF + CRLF + ;
		"Free User Resources: " + Chr(9) + NTRIM(iUser) + "%", , , .f. )
ELSE
	MsgStop( "Can not detect the Free System Resources!", , , .f. )
ENDIF

Return

*--------------------------------------------------------*
Static Procedure SetMenuTheme()
*--------------------------------------------------------*
Local aColors := GetMenuColors()

	SET MENUCURSOR FULL

	SET MENUSEPARATOR SINGLE RIGHTALIGN

	SET MENUITEM BORDER 3DSTYLE

	aColors[ MNUCLR_MENUITEMTEXT ]        := RGB(   0,   0,   0 ) 
	aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= RGB(   0,   0,   0 )

	aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 248, 248, 248 )
	aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 248, 248, 248 )

	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB( 255, 240, 192 )
	aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB( 255, 240, 192 )

	aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 192, 216, 248 )
	aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 128, 168, 220 )

	aColors[ MNUCLR_SEPARATOR1 ] := RGB( 104, 140, 200 )

	SetMenuColors( aColors )

Return

#define WM_TASKBAR	WM_USER+1043
#define ID_TASKBAR	0
#define WM_MOUSEMOVE	512
#define WM_LBUTTONDOWN	513
#define WM_RBUTTONDOWN	516
*--------------------------------------------------------*
FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )
*--------------------------------------------------------*
LOCAL result := 0, aPos, i

	SWITCH nMsg
	CASE WM_TASKBAR

		If wParam == ID_TASKBAR .and. lParam # WM_MOUSEMOVE

			SWITCH lParam

			CASE WM_LBUTTONDOWN

				i := Ascan ( _HMG_aFormhandles , hWnd )
				If i > 0
					_DoWindowEventProcedure ( _HMG_aFormNotifyIconLeftClick [i] , i )
				Endif
				EXIT

			CASE WM_RBUTTONDOWN

				If _HMG_ShowContextMenus == .T.

					aPos := GetCursorPos()

					i := Ascan ( _HMG_aFormhandles , hWnd )
					If i > 0
						If _HMG_aFormNotifyMenuHandle [i] != 0
							Form_1.Timer_1.Enabled := .F.
							TrackPopupMenu ( _HMG_aFormNotifyMenuHandle [i] , aPos[2] , aPos[1] , hWnd )
							Form_1.Timer_1.Enabled := .T.
						Endif
					Endif

				EndIf

			END
		EndIf
		EXIT
#ifdef __XHARBOUR__
	DEFAULT
#else
	OTHERWISE
#endif
		result := Events( hWnd, nMsg, wParam, lParam )
	END

RETURN result

*--------------------------------------------------------*
Static Function InitCpu()
*--------------------------------------------------------*
Local oReg, uVar

   If !IsWinNT()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StartStat")
      uVar := oReg:Get("KERNEL\CPUUsage","")
      oReg:Close()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StatData")
   Endif

Return oReg

*--------------------------------------------------------*
Static Function EndCpu()
*--------------------------------------------------------*
Local uVar

   If !IsWinNT()
      oReg:Close()
      oReg := TReg32():New(HKEY_DYN_DATA,"PerfStats\StopStat")
      uVar := oReg:Get("KERNEL\CPUUsage","")
      oReg:Close()
   Endif

Return .T.

*--------------------------------------------------------*
Static Function CpuUsage()
*--------------------------------------------------------*
Local uVar := chr(0)
Local uuVar := chr(0)

   If _HMG_IsXPorLater
      uVar := GetCPUUsage()
      Return uVar
   ElseIf !IsWinNT()
      uVar := oReg:Get("KERNEL\CPUUsage","00")
   Else
      oReg := TReg32():New(HKEY_LOCAL_MACHINE,;
            "Software\Microsoft\Windows NT\CurrentVersion\Perflib\009")
      uuVar := oReg:Get("Counters","")
      uVar := Str(oReg:Get("% Processor Time",0))
      oReg:Close()
   Endif

Return Asc(uVar)

*--------------------------------------------------------*
DECLARE DLL_TYPE_INT ;
	_MyGetFreeSystemResources32@4( DLL_TYPE_INT ResType ) ;
	IN RSRC32.DLL ;
	ALIAS GetFreeSystemResources
*--------------------------------------------------------*

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#define INITIAL_BUFFER_SIZE			1024
#define INCREMENT_BUFFER_SIZE			1024

#define PROCESSOR_OBJECT_INDEX			238
#define PROCESSOR_TIME_COUNTER_INDEX		6
#define PROCESS_OBJECT_INDEX			230
#define PROCESS_ID_COUNTER_INDEX		784

const WCHAR	wcNameOfInstanceTotal[] = L"_Total";

typedef struct
{
	LARGE_INTEGER Value;
	LARGE_INTEGER Timer;
}_VALUE;

void GetCPUCounterValue(_VALUE* value)
{
	char*	pPerfBuffer;
	char	Key[16];
	DWORD	BufferSize = INITIAL_BUFFER_SIZE;
	PPERF_OBJECT_TYPE pObject;
	PPERF_INSTANCE_DEFINITION	pInstance;
	PPERF_COUNTER_BLOCK		pCounterBlock;
	WCHAR* wcInstanceName;
	PPERF_COUNTER_DEFINITION pCounter;
	LARGE_INTEGER liValue;
	UINT i;
	int ii;

	sprintf(Key,"%d",PROCESSOR_OBJECT_INDEX);

	pPerfBuffer = (char*)malloc(BufferSize);
	memset(pPerfBuffer, 0, BufferSize);
	
	while( RegQueryValueEx( HKEY_PERFORMANCE_DATA,
							Key,
							NULL,
							NULL,
							(LPBYTE)pPerfBuffer,
							&BufferSize ) == ERROR_MORE_DATA)
	{
		BufferSize += INCREMENT_BUFFER_SIZE;
		pPerfBuffer = (char*)realloc(pPerfBuffer, BufferSize);
		memset(pPerfBuffer, 0, BufferSize);
	}

	pObject = (PPERF_OBJECT_TYPE)(pPerfBuffer + ((PPERF_DATA_BLOCK)pPerfBuffer)->HeaderLength);
	for(i=0; i<(((PPERF_DATA_BLOCK)pPerfBuffer)->NumObjectTypes); i++)
	{
		if (pObject->ObjectNameTitleIndex == PROCESSOR_OBJECT_INDEX)
			break;
		pObject = (PPERF_OBJECT_TYPE)((char*)pObject + pObject->TotalByteLength);
	}

	pInstance = (PPERF_INSTANCE_DEFINITION)((char*)pObject + pObject->DefinitionLength);
	for(ii = 0; ii<pObject->NumInstances; ii++)
	{
		pCounterBlock = (PPERF_COUNTER_BLOCK)((char*)pInstance + pInstance->ByteLength);

		wcInstanceName = (wchar_t*)((char*)pInstance+pInstance->NameOffset);
		if(!wcscmp(wcInstanceName, wcNameOfInstanceTotal))
			break;

		pInstance = (PPERF_INSTANCE_DEFINITION)((char*)pCounterBlock + pCounterBlock->ByteLength);
	}
		
	pCounter = (PPERF_COUNTER_DEFINITION)((char*)pObject + pObject->HeaderLength);
	for(i = 0; i<pObject->NumCounters; i++)
	{
		if(pCounter->CounterNameTitleIndex == PROCESSOR_TIME_COUNTER_INDEX)
			break;
		pCounter = (PPERF_COUNTER_DEFINITION)((char*)pCounter + pCounter->ByteLength);
	}

	memcpy(&liValue, ((char*)pCounterBlock + pCounter->CounterOffset), sizeof(LARGE_INTEGER));

	value->Timer = ((PPERF_DATA_BLOCK)pPerfBuffer)->PerfTime100nSec;
	value->Value = liValue;
	
	free(pPerfBuffer);
}

HB_FUNC( GETCPUUSAGE )
{
	static _VALUE oldValue = {0,0};
	static _VALUE newValue = {0,0};

	double DeltaTimer;
	double DeltaValue;
	double Value;

	GetCPUCounterValue(&newValue);

	DeltaTimer = (double)newValue.Timer.QuadPart - (double)oldValue.Timer.QuadPart;
	DeltaValue = (double)newValue.Value.QuadPart - (double)oldValue.Value.QuadPart;

	oldValue = newValue;

	Value = (1.0 - DeltaValue/DeltaTimer)*100;
	if(Value<0)
		Value = 0;

	hb_retni( (int)(Value+0.5) );
}

#pragma ENDDUMP