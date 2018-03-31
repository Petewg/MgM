/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'SendTo'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2006 Grigory Filatov'

#define MsgAlert( c ) MsgEXCLAMATION( c, PROGRAM, , .f. )

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
		ON INIT OpenSendTo()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure OpenSendTo()
*--------------------------------------------------------*

	IF .NOT. OpenSendToFolder()
		MsgAlert( 'Error opening "Send To" folder!' )
	ENDIF

	RELEASE WINDOW MAIN

Return


#pragma BEGINDUMP

#include <windows.h>
#include <shlobj.h>
#include <shellapi.h>

#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( OPENSENDTOFOLDER )
{

  LPITEMIDLIST pidl;
  LPMALLOC     lpMalloc;
  char         sz[MAX_PATH];

  if ( NOERROR == SHGetSpecialFolderLocation( NULL, CSIDL_SENDTO, &pidl ) )
  {
    SHGetPathFromIDList( pidl, sz );

    if ( NOERROR == SHGetMalloc( &lpMalloc ) )
    {
      lpMalloc->lpVtbl->Free( lpMalloc, pidl );
      lpMalloc->lpVtbl->Release( lpMalloc );
    }

    if ( 32 >= (int) ShellExecute( NULL, "open", sz, NULL, NULL, SW_SHOWNORMAL ) )
      hb_retl( FALSE );
  }

  else
    hb_retl( FALSE );

  hb_retl( TRUE );

}

#pragma ENDDUMP