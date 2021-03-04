/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

SCREEN SAVER Source Code
Copyright 2003 Grigory Filatov <gfilatov@inbox.ru>

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. If not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
   visit the web site http://www.gnu.org/).

   As a special exception, you have permission for additional uses of the text
   contained in this release of Harbour Minigui.

   The exception is that, if you link the Harbour Minigui library with other
   files to produce an executable, this does not by itself cause the resulting
   executable to be covered by the GNU General Public License.
   Your use of that executable is in no way restricted on account of linking the
   Harbour-Minigui library code into it.

   Parts of this project are based upon:

   "Harbour GUI framework for Win32"
   Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
   Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2021, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

#define __SCRSAVERDATA__
#include "minigui.ch"

#define SC_SCREENSAVE           61760  // &HF140
#define SPI_SCREENSAVERRUNNING  97

*-----------------------------------------------------------------------------*
FUNCTION _BeginScrSaver( cSSaver, lNoShow, cInit, cRelease, cPaint, nTimer, aBackClr )
*-----------------------------------------------------------------------------*
   LOCAL a := {}, x := GetDesktopWidth(), y := GetDesktopHeight(), Dummy := ""

   PUBLIC _HMG_SCRSAVERDATA[ 5 ]

   _ActiveScrSaverName := cSSaver
   _ScrSaverInstall := .F.
   _ScrSaverFileName := 0
   _ScrSaverConfig := NIL

   DEFAULT nTimer TO 1

   SET INTERACTIVECLOSE OFF

   IF lNoShow

      DEFINE WINDOW &cSSaver AT 0, 0;
         WIDTH x HEIGHT y;
         MAIN NOSHOW;
         TOPMOST NOSIZE NOCAPTION;
         ON GOTFOCUS SetCursorPos( x / 2, y / 2 );
         ON INIT ( ShowCursor( .F. ), ;
            SystemParametersInfo( SPI_SCREENSAVERRUNNING, 1, @Dummy, 0 ) );
         ON RELEASE _ReleaseScrSaver( cRelease, cSSaver, cPaint );
         ON MOUSECLICK iif( _lValidScrSaver(), DoMethod ( cSSaver, 'Release' ), );
         ON MOUSEMOVE ( a := GetCursorPos(), iif( a[1] # y / 2 .AND. a[2] # x / 2,;
            iif( _lValidScrSaver(), DoMethod( cSSaver, 'Release' ) , ), ) );
         BACKCOLOR aBackClr
   ELSE

      DEFINE WINDOW &cSSaver AT 0, 0;
         WIDTH x HEIGHT y;
         MAIN;
         TOPMOST NOSIZE NOCAPTION;
         ON GOTFOCUS SetCursorPos( x / 2, y / 2 );
         ON INIT ( ShowCursor( .F. ), ;
            SystemParametersInfo( SPI_SCREENSAVERRUNNING, 1, @Dummy, 0 ) );
         ON RELEASE _ReleaseScrSaver( cRelease, cSSaver, cPaint );
         ON MOUSECLICK iif( _lValidScrSaver(), DoMethod ( cSSaver, 'Release' ), );
         ON MOUSEMOVE ( a := GetCursorPos(), iif( a[1] # y / 2 .AND. a[2] # x / 2,;
            iif( _lValidScrSaver(), DoMethod( cSSaver, 'Release' ) , ), ) );
         BACKCOLOR aBackClr
   ENDIF

   IF cPaint # NIL
      DEFINE TIMER Timer_SSaver;
         INTERVAL nTimer * 1000;
         ACTION Eval( cPaint )
   ENDIF

   END WINDOW

   IF cInit # NIL

      Eval( cInit )

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _ActivateScrSaver( aForm, cParam )
*-----------------------------------------------------------------------------*
   LOCAL cFileScr, cFileDes

   DEFAULT cParam TO iif( _ScrSaverInstall, "-i", "-s" )

   cParam := Lower( cParam )

   DO CASE
   CASE cParam == "/s" .OR. cParam == "-s"

      _ActivateWindow( aForm )

   CASE cParam == "/c" .OR. cParam == "-c"

      IF _ScrSaverConfig # NIL
         Eval( _ScrSaverConfig )
      ELSE
         MsgInfo( "This screen saver has no options that you configure.", "Information" )
      ENDIF

   CASE cParam == "/a" .OR. cParam == "-a"

      ChangePassword( GetActiveWindow() )

   CASE cParam == "/i" .OR. cParam == "-i"

      cFileScr := GetExeFileName()
      cFileDes := GetSystemFolder() + "\" + ;
         iif( ValType( _ScrSaverFileName ) == "C", _ScrSaverFileName, ;
         cFileNoExt( cFileScr ) + ".SCR" )

      IF File( cFileDes )
         FErase( cFileDes )
      ENDIF

      COPY FILE ( cFileScr ) TO ( cFileDes )

      IF File( cFileDes )

         IF _hmg_IsXp

            EXECUTE FILE "Rundll32.exe";
               PARAMETERS "desk.cpl,InstallScreenSaver " + ;
               GetSystemFolder() + "\" + cFileNoExt( cFileScr ) + ".SCR"

         ELSE

            BEGIN INI FILE GetWindowsFolder() + "\" + 'system.ini'
               SET SECTION "boot" ENTRY "SCRNSAVE.EXE" TO Upper( _GetShortPathName( cFileDes ) )
            END INI

         ENDIF

         MsgInfo( cFileNoPath( cFileDes ) + " installation successfully.", "Information" )

         IF _ScrSaverShow
            SendMessage( GetFormHandle( _ActiveScrSaverName ), WM_SYSCOMMAND, SC_SCREENSAVE )
         ENDIF

      ELSE

         MsgStop( cFileNoPath( cFileDes ) + " installation no successfully.", "Error" )

      ENDIF

   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _ReleaseScrSaver( cRelease, cSSaver, cPaint )
*-----------------------------------------------------------------------------*
   LOCAL Dummy := ""

   IF cRelease # NIL
      Eval( cRelease )
   ENDIF

   ShowCursor( .T. )

   IF cPaint # NIL
      SetProperty( cSSaver, "Timer_SSaver", "Enabled", .F. )
   ENDIF

   SystemParametersInfo( SPI_SCREENSAVERRUNNING, 0, @Dummy, 0 )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _lValidScrSaver()
*-----------------------------------------------------------------------------*
   LOCAL oReg, nValue := 1, lRet, ;
      cKey := "ScreenSave" + iif( _HMG_IsXPorLater, "rIsSecure", "UsePassword" )

   OPEN REGISTRY oReg KEY HKEY_CURRENT_USER SECTION "Control Panel\Desktop"

   GET VALUE nValue NAME cKey OF oReg

   CLOSE REGISTRY oReg

   IF nValue == 1
      lRet := VerifyPassword( GetActiveWindow() )
   ELSE
      lRet := .T.
   ENDIF

RETURN lRet
