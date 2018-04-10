/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-06 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM "Link Executor"
#define VERSION ' version 1.1'
#define COPYRIGHT ' 2003-2006 Grigory Filatov'

#define IDI_1		1001

*--------------------------------------------------------*
Procedure Main
*--------------------------------------------------------*

	SET MULTIPLE OFF

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 354 ;
		HEIGHT IF(IsXPThemeActive(), 120, 115) ;
		TITLE PROGRAM ;
		ICON 'IDI_MAIN' ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT Form_1.CONTROL_4.SetFocus ;
		ON MOUSECLICK MsgAbout() ;
		FONT 'Tahoma' ; 
		SIZE 9

		@ 2,6 FRAME CONTROL_1 ; 
			CAPTION 'Create Link' ; 
			WIDTH 242 ; 
			HEIGHT 80

		@ 20,24 CHECKBOX CONTROL_2 ; 
			CAPTION 'On Desktop' ; 
			WIDTH 220 ; 
			HEIGHT 30 ; 
			VALUE FALSE

		@ 46,24 CHECKBOX CONTROL_3 ; 
			CAPTION 'In "Start/Programs" Menu' ; 
			WIDTH 220 ; 
			HEIGHT 30 ; 
			VALUE FALSE

		@ 10,262 BUTTON CONTROL_4 ; 
			CAPTION 'OK' ; 
			ACTION ( CreateLink(Form_1.CONTROL_2.Value, Form_1.CONTROL_3.Value), ;
				Form_1.Release ) ;
			WIDTH 74 ; 
			HEIGHT 22

		@ 40,262 BUTTON CONTROL_5 ; 
			CAPTION 'Cancel' ; 
			ACTION Form_1.Release ; 
			WIDTH 74 ; 
			HEIGHT 22

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure CreateLink( lDesk, lMenu )
*--------------------------------------------------------*
Local cFileName := Lower( ChangeFileExt( Application.ExeName, ".ini" ) )
Local cDesktop := GetDesktopFolder()
Local cMenuPrgs := GetSpecialFolder( CSIDL_PROGRAMS )
Local cLinkName := "Calculator"
Local cExeName := GetWindowsFolder() + "\Calc.exe"
Local cIco := ""

	IF !FILE(cFileName)
		BEGIN INI FILE cFileName
			SET SECTION "Options" ENTRY "LinkName" TO cLinkName
			SET SECTION "Options" ENTRY "FileName" TO cExeName
		END INI
	ENDIF

	BEGIN INI FILE cFileName
		GET cLinkName SECTION "Options" ENTRY "LinkName" DEFAULT cLinkName
		GET cExeName SECTION "Options" ENTRY "FileName" DEFAULT cExeName
	END INI

	cIco := cExeName

	if lDesk
		if CreateFileLink( cDesktop + "\" + cLinkName, cExeName, cFilePath(cExeName), cIco ) # 0
			MsgStop( "Create Link Error!", PROGRAM, , .f. )
		endif
	endif

	if lMenu
		if CreateFileLink( cMenuPrgs + "\" + cLinkName, cExeName, cFilePath(cExeName), cIco ) # 0
			MsgStop( "Create Link Error!", PROGRAM, , .f. )
		endif
	endif

Return

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
Return MsgInfo( padc(PROGRAM + VERSION, 40) + CRLF + ;
	padc("Copyright " + Chr(169) + COPYRIGHT, 40) + CRLF + CRLF + ;
	hb_compiler() + CRLF + version() + CRLF + ;
	Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
	padc("This program is Freeware!", 38) + CRLF + ;
	padc("Copying is allowed!", 42), "About", IDI_1, .f. )


#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

#include <ShlObj.h>

/***************************************************************************\
*                                                                           *
*  Autor: Jose F. Gimenez (JFG)                                             *
*         <jfgimenez@wanadoo.es> <tecnico.sireinsa@ctv.es>                  *
*                                                                           *
*  Fecha: 2000.10.02                                                        *
*                                                                           *
\***************************************************************************/

void ChangePIF(LPCSTR cPIF)
{
   char buffer[1024];
   HFILE h;
   long  filesize;

   strcpy(buffer, cPIF);
   strcat(buffer, ".pif");
   if ((h=_lopen(buffer, 2))>0)
      {
      filesize=_hread(h, &buffer, 1024);
      buffer[0x63]=0x10;     // Cerrar al salir
      buffer[0x1ad]=0x0a;    // Pantalla completa
      buffer[0x2d4]=0x01;
      buffer[0x2c5]=0x22;    // No Permitir protector de pantalla
      buffer[0x1ae]=0x11;    // Quitar ALT+ENTRAR
      buffer[0x2e0]=0x01;
      _llseek(h, 0, 0);
      _hwrite(h, buffer, filesize);
      _lclose(h);
      }
}

HRESULT WINAPI CreateLink(LPSTR lpszLink, LPSTR lpszPathObj, LPSTR lpszWorkPath, LPSTR lpszIco, int nIco)
{
    long hres;
    IShellLink * psl;

    hres = CoInitialize(NULL);
    if (SUCCEEDED(hres))
       {
       hres = CoCreateInstance(&CLSID_ShellLink, NULL,
           CLSCTX_INPROC_SERVER, &IID_IShellLink, ( LPVOID ) &psl);

       if (SUCCEEDED(hres))
       {

           IPersistFile * ppf;

           psl->lpVtbl->SetPath(psl, lpszPathObj);
           psl->lpVtbl->SetIconLocation(psl, lpszIco, nIco);
           psl->lpVtbl->SetWorkingDirectory(psl, lpszWorkPath);

           hres = psl->lpVtbl->QueryInterface(psl,
                                              &IID_IPersistFile,
                                              ( LPVOID ) &ppf);

           if (SUCCEEDED(hres))
           {
               WORD wsz[MAX_PATH];
               char cPath[MAX_PATH];

               strcpy(cPath, lpszLink);
               strcat(cPath, ".lnk");

               MultiByteToWideChar(CP_ACP, 0, cPath, -1, wsz, MAX_PATH);

               hres = ppf->lpVtbl->Save(ppf, wsz, TRUE);
               ppf->lpVtbl->Release(ppf);

               // modificar el PIF para los programas MS-DOS
               ChangePIF(lpszLink);

           }
           psl->lpVtbl->Release(psl);
       }
       CoUninitialize();
    }
    return hres;
}

/***************************************************************************/

HB_FUNC( CREATEFILELINK )
{
   hb_retnl( (LONG) CreateLink( (char *) hb_parc(1), (char *) hb_parc(2), (char *) hb_parc(3), (char *) hb_parc(4),
             (hb_pcount() > 4) ? hb_parni(5) : 0) );
}

#pragma ENDDUMP
