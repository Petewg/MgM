/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'RecycleNOW'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2005 Grigory Filatov'

#define MsgAlert( c ) MsgEXCLAMATION( c, "Error" )

*--------------------------------------------------------*
Procedure Main()
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 0 HEIGHT 0 ;
		TITLE PROGRAM ;
		ICON 'MAIN' ;
		MAIN NOSHOW ;
		ON INIT RecycleNOW()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure RecycleNOW()
*--------------------------------------------------------*
// Immediate removal of files in the Recycle Bin

	IF EMPTY( EmptyRecycleBin() )
		DO EVENTS
	ELSE
		MsgAlert( "Wrong Recycle Bin Operation!" )
	ENDIF

	Form_1.Release

Return

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"
#include <Shellapi.h>

HB_FUNC ( EMPTYRECYCLEBIN )
{
	hb_retnl( SHEmptyRecycleBin(NULL,NULL,SHERB_NOCONFIRMATION + SHERB_NOPROGRESSUI) );
}

#pragma ENDDUMP