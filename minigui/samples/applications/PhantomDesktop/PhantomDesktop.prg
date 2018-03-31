*
* MINIGUI - HARBOUR - Win32
* 
* Based on a free source code for the Phantom Desktop Screen Saver
* Copyright (c) 1996-2005 by Gregory Braun. All rights reserved.
* 
*------------------------------------------------------------------*
* Translated for MiniGUI by Grigory Filatov <gfilatov@inbox.ru>

ANNOUNCE RDDSYS

#define __SCRSAVERDATA__
#include "minigui.ch"

#define PROGRAM			"Phantom Desktop Screen Saver"
#define VERSION			" v.1.01"
#define COPYRIGHT		" 2003-2006 Grigory Filatov"

#define ICON_1			1001

#define COLOR_DESKTOP		1
#define CLR_HGRAY		{192, 192, 192}

#define DISSOLVE_MIN		1
#define DISSOLVE_MAX		100
#define DISSOLVE_DEFAULT	75

#define FADE_COUNT		15
#define FADE_RATE		16

Static lInit := .T., lBusy := .F.

Memvar cIniFile
Memvar nWidth, nHeight
Memvar nCustom, nDisplay, nDissolve, nFade, ;
	cPicture, nSpeed
Memvar nBackground, ;
	cWallpaper, ;
	nStyle
*--------------------------------------------------------*
Procedure Main( cParameters )
*--------------------------------------------------------*
Local lTile := ( GetRegVar( , "Control Panel\Desktop", "TileWallpaper" ) == "1" )

	PUBLIC cIniFile := GetWindowsFolder() + "\control.ini"

	PRIVATE nWidth := GetDesktopWidth(), nHeight := GetDesktopHeight()
	PRIVATE nCustom := 0, nDisplay := 0, nDissolve := 1, nFade := 0, ;
		cPicture := "", nSpeed := DISSOLVE_DEFAULT
	PRIVATE nBackground := GetSysColor( COLOR_DESKTOP ), ;
		cWallpaper := GetRegVar( , "Control Panel\Desktop", "Wallpaper" ), ;
		nStyle := Val( GetRegVar( , "Control Panel\Desktop", "WallpaperStyle" ) )

	nStyle := IF( lTile, 1, nStyle )

	BEGIN INI FILE cIniFile

		GET nCustom SECTION "Screen Saver.Phantom Desktop" ENTRY "Custom" DEFAULT nCustom

		GET nDisplay SECTION "Screen Saver.Phantom Desktop" ENTRY "Display" DEFAULT nDisplay

		GET nDissolve SECTION "Screen Saver.Phantom Desktop" ENTRY "Dissolve" DEFAULT nDissolve

		GET nFade SECTION "Screen Saver.Phantom Desktop" ENTRY "Fade" DEFAULT nFade

		GET cPicture SECTION "Screen Saver.Phantom Desktop" ENTRY "Image" DEFAULT cPicture

		GET nSpeed SECTION "Screen Saver.Phantom Desktop" ENTRY "Speed" DEFAULT nSpeed

	END INI

	IF nSpeed < DISSOLVE_MIN .OR. nSpeed > DISSOLVE_MAX
		nSpeed := DISSOLVE_DEFAULT
	ENDIF

	IF cParameters # NIL .AND. ( LOWER(cParameters) $ "-p/p" .OR. ;
		LOWER(cParameters) = "/a" .OR. LOWER(cParameters) = "-a" .OR. ;
		LOWER(cParameters) = "/c" .OR. LOWER(cParameters) = "-c" )

		DEFINE SCREENSAVER ;
			WINDOW Form_SSaver ;
			MAIN ;
			NOSHOW
	ELSE

		DEFINE SCREENSAVER ;
			WINDOW Form_SSaver ;
			MAIN ;
			ON PAINT DoPhantom() ;
			INTERVAL .05 ;
			BACKCOLOR BLACK
	ENDIF

	INSTALL SCREENSAVER TO FILE PhantomDesktop.scr

	CONFIGURE SCREENSAVER ConfigureSaver()

	ACTIVATE SCREENSAVER ;
		WINDOW Form_SSaver ;
		PARAMETERS cParameters

Return

*--------------------------------------------------------*
Procedure DoPhantom()
*--------------------------------------------------------*
  local hDC, hOld, hbrush, aRect := {0, 0, 0, 0, _hmg_MainHandle}, i, x, y

  if lInit

	C_Seed()

	hdc	:= GetDC( _hmg_MainHandle )
	hbrush	:= CreateSolidBrush( GetRed(nBackground), GetGreen(nBackground), GetBlue(nBackground) )
	hold	:= SelectObject ( hdc, hbrush )

	C_GetClientRect( @aRect )

	C_FillRect( hdc, aRect, hbrush )

	SelectObject( hdc, hold )
	DeleteObject( hbrush )

	DrawPicture( hdc, IF(EMPTY( nCustom ), cWallpaper, cPicture), IF(EMPTY( nCustom ), nStyle, nDisplay) )

	ReleaseDC( _hmg_MainHandle, hdc )

	lInit := .F.

  endif

  if lBusy
	return
  endif

  IF !EMPTY(nDissolve)

	lBusy := .T.

	hdc := GetDC( _hmg_MainHandle )

	For i := 1 To IF(!EMPTY( nFade ), nSpeed * FADE_COUNT, nSpeed)

		x := C_Random( nWidth )
		y := C_Random( nHeight )

		if !EMPTY( nFade )
			Fade( hdc, x, y, FADE_RATE )
		else
			SetPixel( hdc, x, y, 0 )
		endif

	Next

	ReleaseDC( _hmg_MainHandle, hdc )

	lBusy := .F.

  ENDIF

Return

*--------------------------------------------------------*
static Procedure Fade( hdc, x, y, nrate )
*--------------------------------------------------------*
Local nColor := GetPixel( hdc, x, y )
Local nRed   := GetRed(nColor), ;
      nGreen := GetGreen(nColor), ;
      nBlue  := GetBlue(nColor)

    if EMPTY(nColor)
	return
    endif

    if (nred > nrate)
        nred -= nrate
    else
        nred := 0
    endif

    if (ngreen > nrate)
        ngreen -= nrate
    else
        ngreen := 0
    endif

    if (nblue > nrate)
        nblue -= nrate
    else
        nblue := 0
    endif

    nColor := RGB( nred, ngreen, nblue )

    SetPixel( hdc, x, y, nColor )

return

*--------------------------------------------------------*
Procedure ConfigureSaver()
*--------------------------------------------------------*
Local cFile := "", aDisplay := { "Center", "Tile", "Stretch" }

	DEFINE WINDOW Form_Config ; 
		AT 0,0 ; 
		WIDTH 486 ;
		HEIGHT 348 ;
		TITLE LEFT(PROGRAM, 15) ; 
		ICON ICON_1 ;
		CHILD ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT ShowCursor(.T.) ;
		BACKCOLOR CLR_HGRAY ;
		FONT 'MS Sans Serif' ; 
		SIZE 9

		@ 15,15 IMAGE Image_1 PICTURE "Wizard" ;
			WIDTH 153 ;
			HEIGHT 255

		@ 15,188 IMAGE Image_2 PICTURE "Display" ;
			WIDTH 32 ;
			HEIGHT 32

		@ 15,232 LABEL Label_1 ; 
			VALUE 'Use the settings provided below to specify the speed at which the desktop image will dissolve.' ; 
			WIDTH 230 ; 
			HEIGHT 28 ;
			BACKCOLOR CLR_HGRAY

		@ 46,236 CHECKBOX Check_1 ; 
			CAPTION 'Dissolve to a &Black Background' ; 
			WIDTH 180 ;
			HEIGHT 21 ;
			VALUE IF(EMPTY(nDissolve), .F., .T.) ;
			BACKCOLOR CLR_HGRAY ;
			ON CHANGE ( nDissolve := IF(Form_Config.Check_1.Value, 1, 0), ;
				Form_Config.Check_2.Enabled := !EMPTY(nDissolve), ;
				Form_Config.Label_3.Enabled := !EMPTY(nDissolve), ;
				Form_Config.Label_4.Enabled := !EMPTY(nDissolve), ;
				Form_Config.Slider_1.Enabled := !EMPTY(nDissolve) )

		@ 66,258 CHECKBOX Check_2 ; 
			CAPTION '&Fade to Black' ; 
			WIDTH 140 ;
			HEIGHT 21 ;
			VALUE IF(EMPTY(nFade), .F., .T.) ;
			BACKCOLOR CLR_HGRAY ;
			ON CHANGE ( nFade := IF(Form_Config.Check_2.Value, 1, 0) )

		@ 120,188 LABEL Label_2 VALUE '&Speed' AUTOSIZE ;
			BACKCOLOR CLR_HGRAY

		@ 90,239 LABEL Label_3 VALUE '1' AUTOSIZE ;
			BACKCOLOR CLR_HGRAY

		@ 90,408 LABEL Label_4 VALUE '100' AUTOSIZE ;
			BACKCOLOR CLR_HGRAY

		@ 108,240 IMAGE Image_3 PICTURE "Tick" ;
			WIDTH 181 ;
			HEIGHT 8

		@ 115,229 SLIDER Slider_1 ;
			RANGE DISSOLVE_MIN, DISSOLVE_MAX ;
			VALUE nSpeed ;
			WIDTH 204 ;
			HEIGHT 24 ;
			NOTICKS ;
			BACKCOLOR CLR_HGRAY ;
			ON CHANGE ( nSpeed := Form_Config.Slider_1.Value ) TOP

		@ 156,188 IMAGE Image_4 PICTURE "Bitmap" ;
			WIDTH 32 ;
			HEIGHT 32

		@ 156,232 LABEL Label_5 ; 
			VALUE 'Use the settings provided below to specify a custom wallpaper image to be used instead of the default Windows desktop wallpaper.' ; 
			WIDTH 230 ; 
			HEIGHT 42 ;
			BACKCOLOR CLR_HGRAY

		@ 205,188 LABEL Label_6 VALUE '&Wallpaper' AUTOSIZE ;
			BACKCOLOR CLR_HGRAY

		@ 220, 188 TEXTBOX Textbox_1 ;
			VALUE IF( EMPTY(nCustom), cWallpaper, cPicture ) ;
			WIDTH 250 ;
			HEIGHT 20 ;
			ON CHANGE IF( EMPTY(nCustom), , cPicture := Form_Config.Textbox_1.Value )

		@ 220, 444 BUTTON Button_Select ;
			CAPTION "..." ;
			ACTION ( cFile := Getfile( { {"Bitmap Images", "*.bmp"}, {"All Files", "*.*"} }, ;
				"Select a Bitmap Image", cFilePath(cPicture), .f., .t. ), IF( EMPTY(cFile), , Form_Config.Textbox_1.Value := cFile ) ) ;
			WIDTH 18 HEIGHT 20

		@ 249,188 CHECKBOX Check_3 ; 
			CAPTION '&Use Custom Wallpaper' ; 
			WIDTH 130 ;
			HEIGHT 21 ;
			VALUE IF( EMPTY(nCustom), .F., .T. ) ;
			BACKCOLOR CLR_HGRAY ;
			ON CHANGE ( nCustom := IF(Form_Config.Check_3.Value, 1, 0), ;
				Form_Config.Textbox_1.Value := IF(EMPTY(nCustom), cWallpaper, cPicture), ;
				Form_Config.Textbox_1.Enabled := !EMPTY(nCustom), ;
				Form_Config.Button_Select.Enabled := !EMPTY(nCustom), ;
				Form_Config.Combo_1.Value := IF(EMPTY(nCustom), nStyle, nDisplay) + 1, ;
				Form_Config.Combo_1.Enabled := !EMPTY(nCustom) )

		@ 253,332 LABEL Label_7 VALUE '&Display' AUTOSIZE ;
			BACKCOLOR CLR_HGRAY

		@ 250,374 COMBOBOX Combo_1 ;
			WIDTH 64 HEIGHT 120 ;
			ITEMS aDisplay VALUE IF( EMPTY(nCustom), nStyle, nDisplay ) + 1 ;
			ON CHANGE IF( EMPTY(nCustom), , nDisplay := Form_Config.Combo_1.Value - 1 )

		DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 94, 24 FLAT BOTTOM RIGHTTEXT

			BUTTON Button_dummy1  ;
				CAPTION ' ' ;
				PICTURE 'Dummy' ;
				ACTION _dummy()

			BUTTON Button_dummy2  ;
				CAPTION ' ' ;
				PICTURE 'Dummy' ;
				ACTION _dummy()

			BUTTON Button_1  ;
				CAPTION padl('A&bout', 10) ;
				PICTURE 'About' ;
				ACTION MsgAbout() SEPARATOR

			BUTTON Button_2 ;
				CAPTION padl('&Save', 10) ;
				PICTURE 'Save' ;
				ACTION IF( SaveConfig(), ReleaseAllWindows(), Form_Config.Textbox_1.SetFocus )

			BUTTON Button_3 ;
				CAPTION padl('C&ancel', 10) ;
				PICTURE 'Cancel' ;
				ACTION ReleaseAllWindows()

		END TOOLBAR

		Form_Config.Check_2.Enabled := !EMPTY(nDissolve)
		Form_Config.Label_3.Enabled := !EMPTY(nDissolve)
		Form_Config.Label_4.Enabled := !EMPTY(nDissolve)
		Form_Config.Slider_1.Enabled := !EMPTY(nDissolve)
		Form_Config.Textbox_1.Enabled := !EMPTY(nCustom)
		Form_Config.Button_Select.Enabled := !EMPTY(nCustom)
		Form_Config.Combo_1.Enabled := !EMPTY(nCustom)

	END WINDOW

	CENTER WINDOW Form_Config

	ACTIVATE WINDOW Form_Config, Form_SSaver

Return

*--------------------------------------------------------*
Function SaveConfig()
*--------------------------------------------------------*
Local lRet := .t.

  IF !EMPTY(nCustom)

    IF EMPTY(cPicture)

	MsgStop("A Wallpaper image file is required, but not defined." + CRLF + CRLF + ;
		"You have specified a custom wallpaper bitmap image." + CRLF + ;
		"Please specify the wallpaper bitmap image file to be used.", "Alert")

	lRet := .f.

    ENDIF

  ENDIF

  IF lRet

    BEGIN INI FILE cIniFile

	SET SECTION "Screen Saver.Phantom Desktop" ENTRY "Custom" TO nCustom

	SET SECTION "Screen Saver.Phantom Desktop" ENTRY "Display" TO nDisplay

	SET SECTION "Screen Saver.Phantom Desktop" ENTRY "Dissolve" TO nDissolve

	SET SECTION "Screen Saver.Phantom Desktop" ENTRY "Fade" TO nFade

	SET SECTION "Screen Saver.Phantom Desktop" ENTRY "Image" TO cPicture

	SET SECTION "Screen Saver.Phantom Desktop" ENTRY "Speed" TO nSpeed

    END INI

  ENDIF

Return lRet

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	padc("eMail: gfilatov@inbox.ru", 40) + CRLF + CRLF + ;
	padc("This Screen Saver is Freeware!", 34) + CRLF + ;
	padc("Copying is allowed!", 38), "About", ICON_1, .f. )

*--------------------------------------------------------*
Static Function GetRegVar(nKey, cRegKey, cSubKey, uValue)
*--------------------------------------------------------*
   LOCAL oReg, cValue

   DEFAULT nKey := HKEY_CURRENT_USER
   DEFAULT uValue := ""

   oReg := TReg32():Create(nKey, cRegKey)
   cValue := oReg:Get(cSubKey, uValue)
   oReg:Close()

RETURN cValue


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

#ifdef __XHARBOUR__
#define HB_PARNI( n, x ) hb_parni( n, x )
#define HB_PARNL( n, x ) hb_parnl( n, x )
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_PARNI( n, x ) hb_parvni( n, x )
#define HB_PARNL( n, x ) hb_parvnl( n, x )
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

extern int far Random (int limit)
{
    return (rand () % limit);
}

extern void far Seed (void)
{
    int  seed = HIWORD (GetTickCount ());

    srand (seed);

    return;
}

HB_FUNC ( C_RANDOM )
{
   hb_retnl( Random ( hb_parnl(1) ) ) ;
}

HB_FUNC ( C_SEED )
{
   Seed () ;
}

HB_FUNC ( C_GETCLIENTRECT )
{
   RECT rect;
   GetClientRect( (HWND) HB_PARNL(1, 5), &rect );
   HB_STORNI( rect.top, 1, 1 );
   HB_STORNI( rect.left, 1, 2 );
   HB_STORNI( rect.bottom, 1, 3 );
   HB_STORNI( rect.right, 1, 4 );
}

HB_FUNC ( C_FILLRECT )
{
  RECT rect;
  rect.top=HB_PARNI(2,1);
  rect.left=HB_PARNI(2,2);
  rect.bottom=HB_PARNI(2,3);
  rect.right=HB_PARNI(2,4);
  hb_retni( FillRect( (HDC) hb_parnl(1), &rect, (HBRUSH) hb_parnl(3) ) );
}

HB_FUNC( SETPIXEL )
{

  hb_retnl( (ULONG) SetPixel( (HDC) hb_parnl( 1 ),
                              hb_parni( 2 )      ,
                              hb_parni( 3 )      ,
                              (COLORREF) hb_parnl( 4 )
                            ) ) ;
}

HB_FUNC( GETPIXEL )
{
  hb_retnl( (ULONG) GetPixel( (HDC) hb_parnl( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) ) ;
} 

#define NIL                        (0)  // Nothing...
//  Drawing styles

#define CENTER                      0
#define TILE                        1
#define STRETCH                     2

HB_FUNC ( DRAWPICTURE )
{    
    HDC        dc = ( HDC ) hb_parnl( 1 );
    HANDLE     picture;
    BITMAP     bitmap;
    HDC        bits;
    HANDLE     old;
    
    POINT      size;
    POINT      origin = { NIL,NIL };

    RECT       box;
    int        row;
    int        col;

    int desktopx = GetSystemMetrics (SM_CXSCREEN);
    int desktopy = GetSystemMetrics (SM_CYSCREEN);

    if ((picture = LoadImage (NIL,hb_parc(2),IMAGE_BITMAP,NIL,NIL,LR_LOADFROMFILE)) == NULL) {
        hb_retl (FALSE);
        }

    if ((bits = CreateCompatibleDC (dc)) == NULL) {
        DeleteObject (picture);
        hb_retl (FALSE);
        }

    if ((old = SelectObject (bits,picture)) == NULL) {
        DeleteObject (picture);
        DeleteDC (bits);
        hb_retl (FALSE);
        }
    
    SetMapMode (bits,GetMapMode (dc));
    
    if (!GetObject (picture,sizeof (BITMAP), (LPSTR) &bitmap)) {
        SelectObject (bits,old);
        DeleteObject (picture);
        DeleteDC (bits);
        hb_retl (FALSE);
        }

    size.x = bitmap.bmWidth;
    size.y = bitmap.bmHeight;
    DPtoLP (dc,&size,1);
    
    origin.x = NIL;
    origin.y = NIL;
    DPtoLP (bits,&origin,1);

    switch (hb_parnl(3)) {

        case CENTER :

             box.left = (desktopx - size.x) / 2;
             box.top  = (desktopy - size.y) / 2;

             BitBlt (dc,
                     box.left,
                     box.top,
                     size.x,
                     size.y,
                     bits,
                     origin.x,
                     origin.y,
                     SRCCOPY);
             break;

        case TILE :

             for (row = NIL; row < ((desktopy / size.y) + 1); row++) {

                 for (col = NIL; col < ((desktopx / size.x) + 1); col++) {

                     box.left = col * size.x;
                     box.top = row * size.y;
    
                     BitBlt (dc,
                             box.left,
                             box.top,
                             size.x,
                             size.y,
                             bits,
                             origin.x,
                             origin.y,
                             SRCCOPY);
                     }
                 }
              break;

         case STRETCH :

              StretchBlt (dc,
                          NIL,
                          NIL,
                          desktopx,
                          desktopy,
                          bits,
                          origin.x,
                          origin.y,
                          size.x,
                          size.y,
                          SRCCOPY);
              break;
              }

    SelectObject (bits,old);    
    DeleteDC     (bits);
    DeleteObject (picture);

    hb_retl (TRUE);
}

#pragma ENDDUMP
