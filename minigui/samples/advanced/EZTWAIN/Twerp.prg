/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * eztw32.dll is a public domain from
 * http://www.dosadi.com/eztwain1.htm
 *
 * Twerp 2.0   27 Aril 2006 by Spike <spike@dosadi.com>
 *
 * Copyright 2005 Walter Formigoni <walter.formigoni@uol.com.br>
 *
 * Copyright 2005-2007 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#ifdef __XHARBOUR__
  #define __CALLDLL__
#endif

#include "minigui.ch"

#define TW_APP_ICO	1001
#define TW_APP_TITLE	"Twerp - EZTwain sample app by Spike"

#define TWAIN_BW	0x0001 // 1-bit per pixel, B&W  (== TWPT_BW)
#define TWAIN_GRAY	0x0002 // 1,4, or 8-bit grayscale (== TWPT_GRAY)
#define TWAIN_RGB	0x0004 // 24-bit RGB color  (== TWPT_RGB)
#define TWAIN_PALETTE	0x0008 // 1,4, or 8-bit palette (== TWPT_PALETTE)
#define TWAIN_ANYTYPE	0x0000 // any of the above

STATIC hWnd, hpal, hdib, wPixTypes := TWAIN_ANYTYPE, fHideUI := 0

PROCEDURE Main

   SET MULTIPLE OFF

   DEFINE WINDOW MainWnd ;
      AT 0, 0 ;
      WIDTH 500 ;
      HEIGHT 350 ;
      TITLE TW_APP_TITLE ;
      ICON TW_APP_ICO ;
      MAIN ;
      ON INIT hWnd := This.Handle ;
      ON RELEASE DiscardImage() ;
      ON PAINT OnPaint() ;
      BACKCOLOR GRAY

   DEFINE MAIN MENU
      DEFINE POPUP '&File'
         MENUITEM '&Select Source...' ACTION TWAIN_SelectImageSource( hWnd )
         MENUITEM '&Acquire...'  ACTION Acquire()
         MENUITEM 'Acquire to &File...'  ACTION AcquireToFilename()
         MENUITEM 'Acquire to &Clipboard...' ACTION AcquireToClipboard()
         MENUITEM 'Save As...' ACTION SaveAs() NAME TW_APP_SAVEAS
         MENUITEM '&Open...' ACTION OnOpen()
         SEPARATOR
         MENUITEM 'E&xit' ACTION ThisWindow.Release
      END POPUP
      DEFINE POPUP '&Options'
         MENUITEM "&All PixelTypes" ACTION SetTypes() NAME TW_APP_ANYPIX CHECKED
         MENUITEM "&B&&W" ACTION SetTypes() NAME TW_APP_BW
         MENUITEM "&Grayscale" ACTION SetTypes() NAME TW_APP_GRAYSCALE
         MENUITEM "&RGB Color" ACTION SetTypes() NAME TW_APP_RGB
         MENUITEM "&Palette Color" ACTION SetTypes() NAME TW_APP_PALETTE
         SEPARATOR
         MENUITEM "&Show Source UI" ACTION SetTypes() NAME TW_APP_SHOWUI CHECKED
         MENUITEM "&Hide Source UI" ACTION SetTypes() NAME TW_APP_HIDEUI
      END POPUP
      DEFINE POPUP '&Help'
         MENUITEM '&About Twerp...' ACTION ;
           MsgInfo ( "MiniGUI Sample Application for EZTwain" + CRLF + ;
                     "Based upon a contribution by Walter Formigoni" + CRLF + ;
                     "Written by Grigory Filatov (April, 2005)" + CRLF + CRLF + ;
                     "EZTwain Dll reports version " + LTrim( Str( TWAIN_EasyVersion() / 100 ) ) + CRLF + ;
                     "TWAIN Services: " + iif( Empty( TWAIN_IsAvailable() ), "Not Available", "Available" ), "About Twerp", TW_APP_ICO, .F. )
      END POPUP
   END MENU

   END WINDOW

   MainWnd.TW_APP_SAVEAS.Enabled := .F.

   CENTER WINDOW MainWnd

   ACTIVATE WINDOW MainWnd

RETURN


// ************************************
FUNCTION Acquire()

   // free up current image and palette if any
   DiscardImage()
   InvalidateRect( hWnd, 1 )

   TWAIN_SetHideUI( fHideUI )

   // if TWAIN_OpenDefaultSource() > 0
   hdib = TWAIN_AcquireNative( hWnd, wPixTypes )
   IF !Empty( hdib )
      // compute or guess a palette to use for display
      hpal = TWAIN_CreateDibPalette( hdib )

      // size the window to just contain the image
      ResizeWindow()
   ENDIF
   // else
   //  MsgStop( "Unable to open default Data Source.", "Error" )
   // endif

RETURN NIL
// *********

// ************************************
FUNCTION AcquireToFilename()

   LOCAL nResult := 1
   LOCAL cFilename := Putfile( { { 'Windows Bitmaps (*.bmp)', '*.bmp' }, { 'Jpg Files (*.jpg)', '*.jpg' } }, , ;
      GetStartUpFolder(), , , @nResult )

   IF !Empty( cFilename )
      cFilename := cFilePath( cFilename ) + "\" + cFileNoExt( cFilename ) + ".bmp"

      // free up current image and palette if any
      DiscardImage()
      InvalidateRect( hWnd, 1 )

      IF TWAIN_AcquireToFilename( hWnd, cFilename ) == 0
         hdib = TWAIN_LoadNativeFromFilename( cFilename )
         IF !Empty( hdib )
            // compute or guess a palette to use for display
            hpal = TWAIN_CreateDibPalette( hdib )

            // size the window to just contain the image
            ResizeWindow()

            IF nResult == 2
               Bmp2Jpg( cFilename, cFilePath( cFilename ) + "\" + cFileNoExt( cFilename ) + ".jpg" )
               FErase( cFilename )
            ENDIF
         ENDIF
      ELSE
         MsgStop( "No image was acquired or transfer to the file failed.", "Error", , .F. )
      ENDIF
   ENDIF

RETURN NIL
// *********

// *********************************
FUNCTION AcquireToClipboard()

   IF TWAIN_AcquireToClipboard( hWnd, TWAIN_ANYTYPE ) == 0
      MsgStop( "No image was acquired or transfer to the clipboard failed.", "Error", , .F. )
   ELSE
      MsgInfo( "The image was transfered to the clipboard.", "Twerp", , .F. )
   ENDIF

RETURN NIL
// *********

// ************************************
FUNCTION OnPaint()

   LOCAL x := GetDesktopRectWidth(), y := GetDesktopRectHeight()
   LOCAL pps, hDC, w, h

   // force repaint of window
   InvalidateRect( hWnd, 1 )

   hDC := BeginPaint( _HMG_MainHandle, @pps )

   IF ValType( hpal ) == 'N'
      SetPalette( hDC, hpal )
   ENDIF
   IF ValType( hdib ) == 'N'
      w := TWAIN_DibWidth( hdib )
      h := TWAIN_DibHeight( hdib )

      // wait cursor (hourglass)
      CursorWait()
      SetCursorPos( x / 2, y / 2 )

      TWAIN_DrawDibToDC( hDC, 0, 0, w, h, hdib, 0, 0 )

      // delay emulation for power PC
      InkeyGUI( 100 )
      CursorArrow()

      MainWnd.TW_APP_SAVEAS.Enabled := .T.
   ENDIF

   EndPaint( _HMG_MainHandle, pps )

RETURN NIL
// *********

// ************************************
FUNCTION OnOpen()

   // free up current image and palette if any
   DiscardImage()
   InvalidateRect( hWnd, 1 )

   hdib = TWAIN_LoadNativeFromFilename( 0 )
   IF !Empty( hdib )
      // compute or guess a palette to use for display
      hpal = TWAIN_CreateDibPalette( hdib )

      // size the window to just contain the image
      ResizeWindow()
   ENDIF

RETURN NIL
// *********

// ***************
FUNCTION SaveAs()

   LOCAL nResult := 1
   LOCAL cFilename := Putfile( { { 'Windows Bitmaps (*.bmp)', '*.bmp' }, { 'Jpg Files (*.jpg)', '*.jpg' } }, , ;
      GetStartUpFolder(), , , @nResult )

   IF !Empty( cFilename )
      IF nResult == 1
         nResult := TWAIN_WriteNativeToFilename( hdib, cFilename )
         // -1 user cancelled File Save dialog
         // -2 could not create or open file for writing
         // -3 (weird) unable to access DIB
         // -4 writing to .BMP failed, maybe output device is full?
         IF nResult < -1
            MsgStop( "Error writing DIB to file - is there room for the image?", "Error" )
         ENDIF
      ELSE
         Save2Jpg( hWnd, cFilename, TWAIN_DibWidth( hdib ), TWAIN_DibHeight( hdib ) )
      ENDIF
   ENDIF

RETURN NIL
// *********

// ***************
FUNCTION SetTypes()

   LOCAL cItem := This.name, cCurrentType

   IF !"UI" $ cItem
      DO CASE
      CASE wPixTypes = TWAIN_BW
         cCurrentType := "TW_APP_BW"
      CASE wPixTypes = TWAIN_GRAY
         cCurrentType := "TW_APP_GRAYSCALE"
      CASE wPixTypes = TWAIN_RGB
         cCurrentType := "TW_APP_RGB"
      CASE wPixTypes = TWAIN_PALETTE
         cCurrentType := "TW_APP_PALETTE"
      CASE wPixTypes = TWAIN_ANYTYPE
         cCurrentType := "TW_APP_ANYPIX"
      ENDCASE
      MainWnd.&cCurrentType..Checked := .F.
   ENDIF

   DO CASE
   CASE cItem == "TW_APP_BW"
      wPixTypes := TWAIN_BW
   CASE cItem == "TW_APP_GRAYSCALE"
      wPixTypes := TWAIN_GRAY
   CASE cItem == "TW_APP_RGB"
      wPixTypes := TWAIN_RGB
   CASE cItem == "TW_APP_PALETTE"
      wPixTypes := TWAIN_PALETTE
   CASE cItem == "TW_APP_ANYPIX"
      wPixTypes := TWAIN_ANYTYPE
   CASE cItem == "TW_APP_SHOWUI"
      fHideUI = 0
      MainWnd.TW_APP_HIDEUI.Checked := .F.
   CASE cItem == "TW_APP_HIDEUI"
      fHideUI = 1
      MainWnd.TW_APP_SHOWUI.Checked := .F.
   ENDCASE
   MainWnd.&cItem..Checked := .T.

RETURN NIL
// *********

// ***************
PROCEDURE ResizeWindow()

   LOCAL w := GetDesktopRectWidth(), h := GetDesktopRectHeight()

   MainWnd.Hide

   MainWnd.Width := Max( Min( w, TWAIN_DibWidth( hdib ) + 2 * GetBorderWidth() ), GetMinWidth( hWnd, TW_APP_TITLE + Space( 24 ) ) )
   MainWnd.Height := Min( h, TWAIN_DibHeight( hdib ) + GetTitleHeight() + 2 * GetBorderHeight() + GetMenuBarHeight() )

   IF GetProperty( "MainWnd", "Width" ) >= w .OR. GetProperty( "MainWnd", "Height" ) >= h
      MainWnd.Row := 0
      MainWnd.Col := 0
   ELSE
      MainWnd.Center
   ENDIF

   MainWnd.Show

RETURN
// *********

// ************************************
FUNCTION DiscardImage()
   // delete/free global palette, and dib, as necessary.
   IF hpal # NIL
      DeleteObject( hpal )
      hpal = NIL
   ENDIF
   IF hdib # NIL
      TWAIN_FreeNative( hdib )
      hdib = NIL
      MainWnd.TW_APP_SAVEAS.Enabled := .F.
   ENDIF

RETURN NIL
// *********


#ifdef __XHARBOUR__   // Declaration of DLLs using syntax in CallDll.Lib

// -----------------------------------------------------------------------------*
DECLARE SaveToJpgEx( hWnd, cFileName, nWidth, nHeight ) IN JPG.DLL ALIAS SAVE2JPG

DECLARE BmpToJpg( BmpFile, JpgFile ) IN JPG.DLL ALIAS BMP2JPG
// -----------------------------------------------------------------------------*

// -----------------------------------------------------------------------------*
// EZTwain wrappers for xHarbour
//
// Copyright 2005 Walter Formigoni <walter.formigoni@uol.com.br>
//
// Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
// -----------------------------------------------------------------------------*
DECLARE TWAIN_IsAvailable() IN EZTW32.DLL

DECLARE TWAIN_SelectImageSource( hWnd ) IN EZTW32.DLL

DECLARE TWAIN_AcquireToFilename( hWnd, lpString ) IN EZTW32.DLL

DECLARE TWAIN_AcquireToClipboard( hwndApp, DwPixTypes ) IN EZTW32.DLL

DECLARE TWAIN_EasyVersion() IN EZTW32.DLL

DECLARE TWAIN_AcquireNative( hWnd, wPixTypes ) IN EZTW32.DLL

DECLARE TWAIN_LoadNativeFromFilename( pszFile ) IN EZTW32.DLL
DECLARE TWAIN_FreeNative( hdib ) IN EZTW32.DLL

DECLARE TWAIN_WriteNativeToFilename( hdib, pszFile ) IN EZTW32.DLL

DECLARE TWAIN_CreateDibPalette( hdib ) IN EZTW32.DLL

DECLARE TWAIN_DibWidth( hdib ) IN EZTW32.DLL
DECLARE TWAIN_DibHeight( hdib ) IN EZTW32.DLL

DECLARE TWAIN_DrawDibToDC( hDC, dx, dy, w, h, hdib, sx, sy ) IN EZTW32.DLL

DECLARE TWAIN_SetHideUI( fHide ) IN EZTW32.DLL
// -----------------------------------------------------------------------------*

#else

// -----------------------------------------------------------------------------*
DECLARE DLL_TYPE_VOID SaveToJpgEx( DLL_TYPE_LONG hWnd, DLL_TYPE_LPCSTR cFileName, ;
      DLL_TYPE_INT nWidth, DLL_TYPE_INT nHeight ) IN JPG.DLL ALIAS SAVE2JPG

DECLARE DLL_TYPE_VOID BmpToJpg( DLL_TYPE_LPCSTR BmpFile, DLL_TYPE_LPCSTR JpgFile ) ;
      IN JPG.DLL ALIAS BMP2JPG
// -----------------------------------------------------------------------------*

// -----------------------------------------------------------------------------*
// EZTwain wrappers for Harbour
//
// Copyright 2005 Walter Formigoni <walter.formigoni@uol.com.br>
//
// Copyright 2005 Grigory Filatov <gfilatov@inbox.ru>
// -----------------------------------------------------------------------------*
DECLARE DLL_TYPE_INT TWAIN_IsAvailable() IN EZTW32.DLL

DECLARE DLL_TYPE_INT TWAIN_SelectImageSource( DLL_TYPE_HWND hWnd ) IN EZTW32.DLL

DECLARE DLL_TYPE_INT TWAIN_AcquireToFilename( DLL_TYPE_HWND hWnd, DLL_TYPE_LPCSTR lpString ) IN EZTW32.DLL

DECLARE DLL_TYPE_INT TWAIN_AcquireToClipboard( DLL_TYPE_HWND hwndApp, DLL_TYPE_LONG wPixTypes ) IN EZTW32.DLL

DECLARE DLL_TYPE_INT TWAIN_EasyVersion() IN EZTW32.DLL

// declare DLL_TYPE_INT TWAIN_OpenDefaultSource() in EZTW32.DLL

DECLARE DLL_TYPE_HANDLE TWAIN_AcquireNative( DLL_TYPE_HWND hWnd, DLL_TYPE_LONG wPixTypes ) IN EZTW32.DLL

DECLARE DLL_TYPE_HANDLE TWAIN_LoadNativeFromFilename( DLL_TYPE_LPCSTR pszFile ) IN EZTW32.DLL
DECLARE DLL_TYPE_VOID TWAIN_FreeNative( DLL_TYPE_HANDLE hdib ) IN EZTW32.DLL

DECLARE DLL_TYPE_INT TWAIN_WriteNativeToFilename( DLL_TYPE_HANDLE hdib, DLL_TYPE_LPCSTR pszFile ) IN EZTW32.DLL

DECLARE DLL_TYPE_HANDLE TWAIN_CreateDibPalette( DLL_TYPE_HANDLE hdib ) IN EZTW32.DLL

DECLARE DLL_TYPE_INT TWAIN_DibWidth( DLL_TYPE_HANDLE hdib ) IN EZTW32.DLL
DECLARE DLL_TYPE_INT TWAIN_DibHeight( DLL_TYPE_HANDLE hdib ) IN EZTW32.DLL

DECLARE DLL_TYPE_VOID TWAIN_DrawDibToDC( DLL_TYPE_HDC hDC, ;
      DLL_TYPE_INT dx, DLL_TYPE_INT dy, DLL_TYPE_INT w, DLL_TYPE_INT h, ;
      DLL_TYPE_HANDLE hdib, DLL_TYPE_INT sx, DLL_TYPE_INT sy ) IN EZTW32.DLL

DECLARE DLL_TYPE_VOID TWAIN_SetHideUI( DLL_TYPE_INT fHide ) IN EZTW32.DLL
// -----------------------------------------------------------------------------*

#endif


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( GETDESKTOPRECTWIDTH )
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 0, &rect, 0 );
   hb_retni(rect.right - rect.left);
}

HB_FUNC( GETDESKTOPRECTHEIGHT )
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 0, &rect, 0 );
   hb_retni(rect.bottom - rect.top);
}

HB_FUNC( SETPALETTE )
{
   HDC hDC = (HDC) hb_parnl(1);
   HPALETTE hPal = (HPALETTE) hb_parnl(2);

   SelectPalette (hDC, hPal, FALSE);
   RealizePalette (hDC);
}

HB_FUNC( GETMINWIDTH )
{
   HWND hwnd = (HWND) hb_parnl( 1 );
   HDC hDC = GetDC( hwnd );
   int xMin;

   if (hDC)
   {
     xMin = LOWORD( GetTabbedTextExtent( hDC, hb_parc( 2 ), hb_parclen( 2 ), 0, NULL ) );
     ReleaseDC( hwnd, hDC );
     hb_retni( xMin );
   }
}

#pragma ENDDUMP
