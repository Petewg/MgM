/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com
 *
 * Copyright 2005-2017 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'XMas Lights'
#define VERSION ' version 1.0.0.7'
#define COPYRIGHT ' 2005-2017 Grigory Filatov'

#define NTRIM( n )	hb_ntos( n )
#define BMP_SIZE	32

#ifdef __XHARBOUR__
   #define ENUMINDEX hb_EnumIndex()
#else
   #define ENUMINDEX enum:__EnumIndex
#endif

Static aHandles := {}, aLights := {}
Static nSwitch := 1, lBusy := .F.

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	// Left Height
	aAdd(aLights, {"B121", "B115"})
	aAdd(aLights, {"B120", "B114"})
	aAdd(aLights, {"B122", "B116"})
	aAdd(aLights, {"B115", "B121"})
	aAdd(aLights, {"B114", "B120"})
	aAdd(aLights, {"B116", "B122"})
	aAdd(aLights, {"B122", "B116"})
	aAdd(aLights, {"B115", "B121"})

	// Top Width
	aAdd(aLights, {"B109", "B107"})
	aAdd(aLights, {"B105", "B106"})
	aAdd(aLights, {"B110", "B108"})
	aAdd(aLights, {"B107", "B109"})
	aAdd(aLights, {"B106", "B105"})
	aAdd(aLights, {"B108", "B110"})
	aAdd(aLights, {"B106", "B105"})
	aAdd(aLights, {"B108", "B110"})
	aAdd(aLights, {"B109", "B107"})
	aAdd(aLights, {"B107", "B109"})
	aAdd(aLights, {"B106", "B105"})
	aAdd(aLights, {"B108", "B110"})

	// Right Height
	aAdd(aLights, {"B112", "B118"})
	aAdd(aLights, {"B117", "B111"})
	aAdd(aLights, {"B113", "B119"})
	aAdd(aLights, {"B118", "B112"})
	aAdd(aLights, {"B111", "B117"})
	aAdd(aLights, {"B119", "B113"})
	aAdd(aLights, {"B111", "B117"})
	aAdd(aLights, {"B119", "B113"})

	SET MULTIPLE OFF

	DEFINE WINDOW Form_0 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON 'MAIN' ;
		MAIN ;
		NOSHOW ;
		ON INIT CreateForms() ;
		ON RELEASE aEval(aHandles, {|e| DeleteObject( e )}) ;
		NOTIFYICON 'MAIN' ;
		NOTIFYTOOLTIP PROGRAM ;
		ON NOTIFYCLICK HideShow()

		DEFINE TIMER Timer_0 INTERVAL 250 ACTION SetRegions() ONCE

	END WINDOW

	ACTIVATE WINDOW Form_0

Return

*--------------------------------------------------------*
Static Procedure SetRegions()
*--------------------------------------------------------*
LOCAL cForm, cResName, RegionHandle
LOCAL enum

IF !lBusy

   lBusy := .T.

   FOR EACH enum IN aLights

	cForm := "Form_" + NTRIM(ENUMINDEX)
	cResName := enum[1]

	DoMethod(cForm, "Show")

	SET REGION OF &cForm BITMAP &cResName TRANSPARENT COLOR FUCHSIA TO RegionHandle

	aAdd(aHandles, RegionHandle) // collect the Region handles for deleting on exit

   NEXT

   r_menu()

ENDIF

Return

*--------------------------------------------------------*
Static Procedure CreateForms()
*--------------------------------------------------------*
Local aDesk := GetDesktopArea()
Local nDeskWidth := aDesk[3] - aDesk[1], nDeskHeight := aDesk[4] - aDesk[2]
Local n := Int(nDeskHeight / 9), n1 := Int(nDeskWidth / 13)
Local nTop := 0, nLeft := 0
Local aForms := {}
Local cForm, i, cImage

   CLEAN MEMORY

   // Left Height
   for i = 1 To 8

	cForm := "Form_"+str(i, 1)
	cImage := "Image_"+str(i, 1)
	nTop += n

	DEFINE WINDOW &cForm ;
		AT nTop, nLeft ;
		WIDTH BMP_SIZE HEIGHT BMP_SIZE ;
		CHILD ;
		TOPMOST ;
		NOSHOW ;
		NOCAPTION ;
		NOMINIMIZE NOMAXIMIZE NOSIZE

		@ 0,0 IMAGE &cImage ;
			PICTURE aLights[i][1] ;
			WIDTH BMP_SIZE HEIGHT BMP_SIZE

	END WINDOW

   next

   // Top Width
   nTop := 0
   nLeft := 0
   for i = 9 To 20

	cForm := "Form_" + NTRIM(i)
	cImage := "Image_" + NTRIM(i)
	nLeft += n1

	DEFINE WINDOW &cForm ;
		AT nTop, nLeft ;
		WIDTH BMP_SIZE HEIGHT BMP_SIZE ;
		CHILD ;
		TOPMOST ;
		NOSHOW ;
		NOCAPTION ;
		NOMINIMIZE NOMAXIMIZE NOSIZE

		@ 0,0 IMAGE &cImage ;
			PICTURE aLights[i][1] ;
			WIDTH BMP_SIZE HEIGHT BMP_SIZE

	END WINDOW

   next

   // Right Height
   nTop := 0
   nLeft := nDeskWidth - BMP_SIZE
   for i = 21 To 28

	cForm := "Form_" + str(i, 2)
	cImage := "Image_" + str(i, 2)
	nTop += n

	DEFINE WINDOW &cForm ;
		AT nTop, nLeft ;
		WIDTH BMP_SIZE HEIGHT BMP_SIZE ;
		CHILD ;
		TOPMOST ;
		NOSHOW ;
		NOCAPTION ;
		NOMINIMIZE NOMAXIMIZE NOSIZE

		@ 0,0 IMAGE &cImage ;
			PICTURE aLights[i][1] ;
			WIDTH BMP_SIZE HEIGHT BMP_SIZE

	END WINDOW

   next

   DEFINE TIMER Timer_1 OF Form_1 INTERVAL 500 ACTION SwitchLights()

   aEval( Array(28), { |x, i| aAdd(aForms, "Form_" + NTRIM(i)) } )

   _ActivateWindow ( aForms, .F. )

Return

*--------------------------------------------------------*
Static Procedure SwitchLights()
*--------------------------------------------------------*
LOCAL enum, cIdx

   nSwitch := IF(nSwitch == 1, 2, 1)

   IF lBusy

        FOR EACH enum IN aLights
		cIdx := NTRIM(ENUMINDEX)
		SetProperty( "Form_" + cIdx, "Image_" + cIdx, 'Picture', enum[nSwitch] )
	NEXT

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure HideShow()
*--------------------------------------------------------*
LOCAL enum

   IF IsWindowVisible( GetFormHandle( "Form_1" ) )
	lBusy := .F.

        FOR EACH enum IN aLights
		DoMethod( "Form_" + NTRIM(ENUMINDEX), "Hide" )
	NEXT

   ELSE
	lBusy := .T.

        FOR EACH enum IN aLights
		DoMethod( "Form_" + NTRIM(ENUMINDEX), "Show" )
	NEXT

   ENDIF

   r_menu()

Return

*--------------------------------------------------------*
Static Procedure r_menu()
*--------------------------------------------------------*

	DEFINE NOTIFY MENU OF Form_0
		ITEM IF( IsWindowVisible( GetFormHandle( "Form_1" ) ), '&Hide', '&Show' ) ;
			ACTION HideShow() NAME Show_Hide DEFAULT
		ITEM '&About...'	ACTION ShellAbout( "About " + PROGRAM + "#", PROGRAM + VERSION + CRLF + ;
			"Copyright " + Chr(169) + COPYRIGHT, LoadTrayIcon(GetInstance(), "MAIN", 32, 32) )
		SEPARATOR	
		ITEM '&Exit'		ACTION Form_0.Release
	END MENU

Return


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( INITIMAGE )
{
	HWND  h;
	HWND hwnd;
	int Style;

	hwnd = (HWND) HB_PARNL(1);

	Style = WS_CHILD | SS_BITMAP | SS_NOTIFY ;

	if ( ! hb_parl (8) )
	{
		Style = Style | WS_VISIBLE ;
	}

	h = CreateWindowEx( 0, "static", NULL, Style,
		hb_parni(3), hb_parni(4), 0, 0,
		hwnd, (HMENU) hb_parni(2), GetModuleHandle(NULL), NULL ) ;

	HB_RETNL( (LONG_PTR) h );
}

HB_FUNC( C_SETPICTURE )
{
	HBITMAP hBitmap;

	hBitmap = (HBITMAP) LoadImage( GetModuleHandle(NULL), hb_parc(2), IMAGE_BITMAP, hb_parni(3), hb_parni(4), LR_CREATEDIBSECTION );

	SendMessage( (HWND) HB_PARNL(1), (UINT) STM_SETIMAGE, (WPARAM) IMAGE_BITMAP, (LPARAM) hBitmap );

	HB_RETNL( (LONG_PTR) hBitmap );
}

#pragma ENDDUMP
