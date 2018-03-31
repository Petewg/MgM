/*
 * Proyecto: PdfPrinter
 * Fichero: HaruFonts.prg
 * Descripción:
 * Autor:
 * Fecha: 26/08/2014
 */


STATIC aTtfFontList:= NIL
STATIC cFontDir


//------------------------------------------------------------------------------
FUNCTION SetHaruFontDir(cDir)
//------------------------------------------------------------------------------
   LOCAL cPrevValue:= cFontDir
   IF ValType( cDir ) == 'C' .AND. HB_DirExists( cDir )
      cFontDir:= cDir
   ENDIF
RETURN cPrevValue

//------------------------------------------------------------------------------
FUNCTION GetHaruFontDir()
//------------------------------------------------------------------------------

#define CSIDL_FONTS 0x0014

   IF cFontDir == NIL
      cFontDir:= HaruGetSpecialFolder( CSIDL_FONTS )
   ENDIF

RETURN cFontDir

//------------------------------------------------------------------------------
FUNCTION GetHaruFontList()
//------------------------------------------------------------------------------
   IF aTtfFontList == NIL
      InitTtfFontList()
   ENDIF
RETURN aTtfFontList

//------------------------------------------------------------------------------
STATIC FUNCTION InitTtfFontList()
   LOCAL aDfltList:= { { 'Arial', 'arial.ttf' } ;
                     , { 'Verdana', 'verdana.ttf' } ;
                     , { 'Courier New', 'cour.ttf' } ;
                     , { 'Calibri', 'calibri.ttf' } ;
                     , { 'Tahoma', 'tahoma.ttf' } ;
                     }

   aTtfFontList:= {}
   aEval( aDfltList, {|_x| HaruAddFont( _x[1], _x[2] ) } )

RETURN NIL

//------------------------------------------------------------------------------
FUNCTION HaruAddFont( cFontName, cTtfFile )
//------------------------------------------------------------------------------
   LOCAL aList := GetHaruFontList()
   IF !File( cTtfFile ) .AND. File( GetHaruFontDir() + '\' + cTtfFile )
      cTtfFile:= GetHaruFontDir() + '\' + cTtfFile
   ENDIF
   IF File( cTtfFile )
      aAdd( aList, { cFontName, cTtfFile } )
   ELSE
      hmg_Alert( 'Archivo inexistente '+cTtfFile )
   ENDIF

RETURN NIL





#pragma BEGINDUMP

/*
#define NOERROR = 0
#define CSIDL_DESKTOP = 0x0000
#define CSIDL_PROGRAMS = 0x0002
#define CSIDL_CONTROLS = 0x0003
#define CSIDL_PRINTERS = 0x0004
#define CSIDL_PERSONAL = 0x0005
#define CSIDL_FAVORITES = 0x0006
#define CSIDL_STARTUP = 0x0007
#define CSIDL_RECENT = 0x0008
#define CSIDL_SENDTO = 0x0009
#define CSIDL_BITBUCKET = 0x000A
#define CSIDL_STARTMENU = 0x000B
#define CSIDL_DESKTOPDIRECTORY = 0x0010
#define CSIDL_DRIVES = 0x0011
#define CSIDL_NETWORK = 0x0012
#define CSIDL_NETHOOD = 0x0013
#define CSIDL_FONTS = 0x0014
#define CSIDL_TEMPLATES = 0x0015
#define MAX_PATH = 260
*/


#include <windows.h>
#include <shlobj.h>
#include "hbapi.h"

HB_FUNC( HARUGETSPECIALFOLDER ) // ( CSIDL )
{
   char buffer[MAX_PATH];

   if( SHGetSpecialFolderPath( GetActiveWindow(), (LPSTR) &buffer, (WORD) hb_parni(1), FALSE ) )
   {
      hb_retc( &buffer[0] );
   }
   else
   {
      hb_retc( "" );
   }

   return;


};

HB_FUNC( HARUSHELLEXECUTEC )
{
	#ifndef _WIN64
	   hb_retnl( ( LONG ) ShellExecute( ( HWND ) hb_parnl( 1 ), hb_parc( 2 ), hb_parc( 3 ), hb_parc( 4 ), hb_parc( 5 ), hb_parnl( 6 ) ) );
	#else
	   hb_retnll( ( LONGLONG ) ShellExecute( ( HWND ) hb_parnll( 1 ), hb_parc( 2 ), hb_parc( 3 ), hb_parc( 4 ), hb_parc( 5 ), hb_parnl( 6 ) ) );
  #endif 	
}


#pragma ENDDUMP
