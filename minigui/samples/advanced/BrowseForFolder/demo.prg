/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2008 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

/*
#define BIF_RETURNONLYFSDIRS   1      // For finding a folder to start document searching
#define BIF_STATUSTEXT         4      // Include a status area in the dialog box
#define BIF_EDITBOX            16     // Add an editbox to the dialog
#define BIF_VALIDATE           32     // insist on valid result (or CANCEL)

#define BIF_NEWDIALOGSTYLE     64     // New dialog style with context menu and resizability

#define BIF_BROWSEINCLUDEFILES 16384  // The browse dialog will display files as well as folders
*/

*-----------------------------------------------------------------------------*
Procedure Main()
*-----------------------------------------------------------------------------*
Local cCurDir := CurDrive() + ":\" + CurDir()
Local cMsg := "Please select a location to store data files"

	DEFINE WINDOW Form_1 ;
		AT 0,0 WIDTH 530 HEIGHT 150 ;
		MAIN ;
		TITLE "Custom Browse For Folder Function Demo" ;
		NOSIZE

		DEFINE MAIN MENU
			DEFINE POPUP 'Tests'
				MENUITEM 'BrowseForFolder()' ACTION MsgInfo(RunBrowseForFolder(NIL, ;
                                     BIF_RETURNONLYFSDIRS + BIF_STATUSTEXT, ;
                                     cMsg, Form_1.Textbox_1.Value, Form_1.Check_1.Value),"Result")
				MENUITEM 'BrowseForFolder() allow direct entry' ACTION MsgInfo(RunBrowseForFolder(NIL, ;
                                     BIF_STATUSTEXT + BIF_EDITBOX, ;
                                     cMsg, Form_1.Textbox_1.Value, Form_1.Check_1.Value),"Result")
				MENUITEM 'BrowseForFolder() allow and validate direct entry' ACTION MsgInfo(RunBrowseForFolder(NIL, ;
                                     BIF_STATUSTEXT + BIF_EDITBOX + BIF_VALIDATE, ;
                                     cMsg, Form_1.Textbox_1.Value, Form_1.Check_1.Value),"Result")
				MENUITEM 'BrowseForFolder() show files' ACTION MsgInfo(RunBrowseForFolder(NIL, ;
                                     BIF_STATUSTEXT + BIF_EDITBOX + BIF_VALIDATE + BIF_BROWSEINCLUDEFILES, ;
                                     cMsg, Form_1.Textbox_1.Value, Form_1.Check_1.Value),"Result")
				MENUITEM 'BrowseForFolder() use "New Style" dialog' ACTION MsgInfo(RunBrowseForFolder(NIL, ;
                                     BIF_EDITBOX + BIF_VALIDATE + BIF_NEWDIALOGSTYLE, ;
                                     cMsg, Form_1.Textbox_1.Value),"Result")
				SEPARATOR
				MENUITEM 'Exit' ACTION Form_1.Release
			END POPUP
		END MENU

		@ 25,460 BUTTON Button_1 PICTURE 'OPEN_BMP' WIDTH 39 HEIGHT 24 ;
		         ACTION  {|| Form_1.Textbox_1.Value := RunBrowseForFolder(NIL, BIF_STATUSTEXT, cMsg, Form_1.Textbox_1.Value, Form_1.Check_1.Value) }
		@ 26,95  TEXTBOX TextBox_1 VALUE cCurDir WIDTH 359 HEIGHT 21 FONT "MS Sans Serif"
		@ 27,20  LABEL Label_1 VALUE "Folder" WIDTH 73 HEIGHT 20 FONT "MS Sans serif" BOLD TRANSPARENT
		@ 0,2    FRAME Frame_1 CAPTION "" WIDTH 518 HEIGHT 70
		@ 75,20  CHECKBOX Check_1 CAPTION "Center dialog on screen" WIDTH 150 HEIGHT 21 FONT "MS Sans Serif" 

	END WINDOW

	Form_1.Center
	Form_1.Activate

Return

*-----------------------------------------------------------------------------*
Function RunBrowseForFolder( nfolder, nflag, cTitle, cInitPath, lCenter )
*-----------------------------------------------------------------------------*
Return hb_BrowseForFolder( NIL, cTitle, nflag, nfolder, cInitPath, lCenter )


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>

#include "hbapi.h"

#ifndef __XHARBOUR__
   #define ISCHAR( n )           HB_ISCHAR( n )
   #define ISNIL( n )            HB_ISNIL( n )
#endif

static BOOL s_bCntrDialog = FALSE;

void CenterDialog( HWND hwnd )
{
   RECT  rect;
   int   w, h, x, y;

   GetWindowRect( hwnd, &rect );
   w = rect.right - rect.left;
   h = rect.bottom - rect.top;
   x = GetSystemMetrics( SM_CXSCREEN );
   y = GetSystemMetrics( SM_CYSCREEN );
   MoveWindow( hwnd, (x - w) / 2, (y - h) / 2, w, h, TRUE );
}

int CALLBACK BrowseCallbackProc( HWND hWnd, UINT uMsg, LPARAM lParam, LPARAM lpData )
{
   TCHAR szPath[MAX_PATH];

   switch( uMsg )
   {
      case BFFM_INITIALIZED:  if( lpData ){ SendMessage( hWnd, BFFM_SETSELECTION, TRUE, lpData ); if( s_bCntrDialog ) CenterDialog( hWnd );} break;
      case BFFM_SELCHANGED:   SHGetPathFromIDList( (LPITEMIDLIST) lParam, szPath ); SendMessage( hWnd, BFFM_SETSTATUSTEXT, NULL, (LPARAM) szPath ); break;
      case BFFM_VALIDATEFAILED:  MessageBeep( MB_ICONHAND ); SendMessage( hWnd, BFFM_SETSTATUSTEXT, NULL, (LPARAM) "Bad Directory" ); return 1;
   }

   return 0;
}

HB_FUNC( HB_BROWSEFORFOLDER )  // Syntax: hb_BrowseForFolder([<hWnd>],[<cTitle>],<nFlags>,[<nFolderType>],[<cInitPath>],[<lCenter>])
{
   HWND           hWnd = ISNIL( 1 ) ? GetActiveWindow() : ( HWND ) hb_parnl( 1 );
   BROWSEINFO     BrowseInfo;
   char           *lpBuffer = ( char * ) hb_xgrab( MAX_PATH + 1 );
   LPITEMIDLIST   pidlBrowse;

   SHGetSpecialFolderLocation( hWnd, ISNIL(4) ? CSIDL_DRIVES : hb_parni(4), &pidlBrowse );

   BrowseInfo.hwndOwner = hWnd;
   BrowseInfo.pidlRoot = pidlBrowse;
   BrowseInfo.pszDisplayName = lpBuffer;
   BrowseInfo.lpszTitle = ISNIL( 2 ) ? "Select a Folder" : hb_parc( 2 );
   BrowseInfo.ulFlags = hb_parni( 3 );
   BrowseInfo.lpfn = BrowseCallbackProc;
   BrowseInfo.lParam = ISCHAR( 5 ) ? (LPARAM) (char *) hb_parc( 5 ) : 0;
   BrowseInfo.iImage = 0;

   s_bCntrDialog = ISNIL(6) ? FALSE : hb_parl( 6 );

   pidlBrowse = SHBrowseForFolder( &BrowseInfo );

   if( pidlBrowse )
   {
      SHGetPathFromIDList( pidlBrowse, lpBuffer );
      hb_retc( lpBuffer );
   }
   else
   {
      hb_retc( "" );
   }

   hb_xfree( lpBuffer );
}

#pragma ENDDUMP
