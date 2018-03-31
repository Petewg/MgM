/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM "Countdown"
#define VERSION " version 1.0"
#define COPYRIGHT " Grigory Filatov, 2017"

STATIC nCountdown := 120, nStyle

*--------------------------------------------------------*
Procedure Main( param )
*--------------------------------------------------------*

	IF ValType( param ) == "C"

		IF Val( param ) > 0
			nCountdown := Val( param )
		ENDIF

	ENDIF

	Default nStyle To Random( 3 )

	DEFINE WINDOW Form_1 		;
		TITLE PROGRAM 		;
		MAIN NOSHOW 		;
		NOTIFYTOOLTIP PROGRAM	;
		ON INIT Start()		;
		ON RELEASE ShowNotifyIcon( This.Handle, .F., NIL, NIL )

		DEFINE TIMER Timer_1 ;
			INTERVAL 1000 ;
			ACTION ChangeTrayIcon()

	END WINDOW

	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
Static Procedure Start()
*--------------------------------------------------------*
Local i := GetFormIndex( This.Name )
Local hIcon := CreateIcon( This.Handle, nCountdown, nStyle )

	CLEAN MEMORY

	ShowNotifyIcon( This.Handle, .T., hIcon, _HMG_aFormNotifyIconToolTip [i] )

	DEFINE NOTIFY MENU OF Form_1

		ITEM 'About...'			ACTION ShellAbout( "About " + PROGRAM + "# ", ;
			PROGRAM + VERSION + CRLF + "Copyright " + Chr(169) + COPYRIGHT, hIcon )

		SEPARATOR	

		POPUP 'Icon Style'

			ITEM 'Stylized'	ACTION ( nStyle := 1, ;
				Form_1.Dig.Checked := .f., Form_1.Num.Checked := .t., Form_1.Bit.Checked := .f. ) NAME NUM

			ITEM 'Squares'	ACTION ( nStyle := 2, ;
				Form_1.Dig.Checked := .t., Form_1.Num.Checked := .f., Form_1.Bit.Checked := .f. ) NAME DIG

			ITEM 'Bits'	ACTION ( nStyle := 3, ;
				Form_1.Dig.Checked := .f., Form_1.Num.Checked := .f., Form_1.Bit.Checked := .t. ) NAME BIT

		END POPUP

		SEPARATOR	

		ITEM 'Exit'		ACTION Form_1.Release

	END MENU

	Form_1.Num.Checked := ( nStyle == 1 )
	Form_1.Dig.Checked := ( nStyle == 2 )
	Form_1.Bit.Checked := ( nStyle == 3 )

Return

*--------------------------------------------------------*
Static Procedure ChangeTrayIcon()
*--------------------------------------------------------*
Local i := GetFormIndex( ThisWindow.Name )
Local hIcon := CreateIcon( ThisWindow.Handle, --nCountdown, nStyle )

   IF nCountdown < 1

	Form_1.Timer_1.Release

	Form_1.NotifyTooltip := "It's time!"

	ChangeNotifyIcon( ThisWindow.Handle, hIcon, _HMG_aFormNotifyIconToolTip [i] )

	MsgInfo( "It's time!" )

   ELSE

	Form_1.NotifyTooltip := TimeAsString( nCountdown ) + " remaining"

	ChangeNotifyIcon( ThisWindow.Handle, hIcon, _HMG_aFormNotifyIconToolTip [i] )

   ENDIF

Return

*--------------------------------------------------------*
Function TimeAsString( nSeconds )
*--------------------------------------------------------*
Return StrZero(Int(Mod(nSeconds / 3600, 24)), 1, 0) + ":" + ;
	  StrZero(Int(Mod(nSeconds / 60, 60)), 2, 0) + ":" + ;
	  StrZero(Int(Mod(nSeconds, 60)), 2, 0)

/*
 * C-level code was borrowed from the OOHG sample Clocks
*/

#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>

void TrazaLinea( HDC hdc2, HDC hdc3, int x1, int y1, int x2, int y2 )
{
   StretchBlt( hdc2, x1, y1, x2 - x1 + 1, y2 - y1 + 1, hdc3, x1, y1, x2 - x1 + 1, y2 - y1 + 1, SRCCOPY );
}

void PintaFocos( HDC hdc2, HDC hdc3, int x, int n1, int n2, int n3, int n4, int n5, int n6, int n7 )
{
   int x1_a, y1_a, x2_a, y2_a, x1_b, y1_b, x2_b, y2_b;

   if( n1 )
   {
      x1_a = ( n2 ? 1 : 0 );
      x2_a = ( n3 ? 6 : 7 );
      y1_a = 0;
      y2_a = 0;
      x1_b = ( n2 ? 2 : 1 );
      x2_b = ( n3 ? 5 : 6 );
      y1_b = 1;
      y2_b = 1;
      TrazaLinea( hdc2, hdc3, x + x1_a, y1_a, x + x2_a, y2_a );
      TrazaLinea( hdc2, hdc3, x + x1_b, y1_b, x + x2_b, y2_b );
   }

   if( n2 )
   {
      x1_a = 0;
      x2_a = 0;
      y1_a = ( n1 ? 1 : 0 );
      y2_a = ( n5 ? ( n4 ? 5 : 6 ) : ( n4 ? 6 : 7 ) );
      x1_b = 1;
      x2_b = 1;
      y1_b = ( n1 ? 2 : 1 );
      y2_b = ( n5 ? ( n4 ? 6 : 5 ) : ( n4 ? 5 : 6 ) );
      TrazaLinea( hdc2, hdc3, x + x1_a, y1_a, x + x2_a, y2_a );
      TrazaLinea( hdc2, hdc3, x + x1_b, y1_b, x + x2_b, y2_b );
   }

   if( n3 )
   {
      x1_a = 6;
      x2_a = 6;
      y1_a = ( n1 ? 2 : 1 );
      y2_a = ( n6 ? ( n4 ? 6 : 5 ) : ( n4 ? 5 : 6 ) );
      x1_b = 7;
      x2_b = 7;
      y1_b = ( n1 ? 1 : 0 );
      y2_b = ( n6 ? ( n4 ? 5 : 6 ) : ( n4 ? 6 : 7 ) );
      TrazaLinea( hdc2, hdc3, x + x1_a, y1_a, x + x2_a, y2_a );
      TrazaLinea( hdc2, hdc3, x + x1_b, y1_b, x + x2_b, y2_b );
   }

   if( n4 )
   {
      x1_a = ( n2 ? ( n5 ? 1 : 2 ) : ( n5 ? 1 : 1 ) );
      x2_a = ( n3 ? ( n6 ? 6 : 5 ) : ( n6 ? 6 : 6 ) );
      y1_a = 6;
      y2_a = 6;
      x1_b = ( n2 ? ( n5 ? 1 : 1 ) : ( n5 ? 2 : 1 ) );
      x2_b = ( n3 ? ( n6 ? 6 : 6 ) : ( n6 ? 5 : 6 ) );
      y1_b = 7;
      y2_b = 7;
      TrazaLinea( hdc2, hdc3, x + x1_a, y1_a, x + x2_a, y2_a );
      TrazaLinea( hdc2, hdc3, x + x1_b, y1_b, x + x2_b, y2_b );
   }

   if( n5 )
   {
      x1_a = 0;
      x2_a = 0;
      y1_a = ( n2 ? ( n4 ? 8 : 7 ) : ( n4 ? 7 : 6 ) );
      y2_a = ( n7 ? 12 : 13 );
      x1_b = 1;
      x2_b = 1;
      y1_b = ( n2 ? ( n4 ? 7 : 8 ) : ( n4 ? 8 : 7 ) );
      y2_b = ( n7 ? 11 : 12 );
      TrazaLinea( hdc2, hdc3, x + x1_a, y1_a, x + x2_a, y2_a );
      TrazaLinea( hdc2, hdc3, x + x1_b, y1_b, x + x2_b, y2_b );
   }

   if( n6 )
   {
      x1_a = 6;
      x2_a = 6;
      y1_a = ( n3 ? ( n4 ? 7 : 8 ) : ( n4 ? 8 : 7 ) );
      y2_a = ( n7 ? 11 : 12 );
      x1_b = 7;
      x2_b = 7;
      y1_b = ( n3 ? ( n4 ? 8 : 7 ) : ( n4 ? 7 : 6 ) );
      y2_b = ( n7 ? 12 : 13 );
      TrazaLinea( hdc2, hdc3, x + x1_a, y1_a, x + x2_a, y2_a );
      TrazaLinea( hdc2, hdc3, x + x1_b, y1_b, x + x2_b, y2_b );
   }

   if( n7 )
   {
      x1_a = ( n5 ? 2 : 1 );
      x2_a = ( n6 ? 5 : 6 );
      y1_a = 12;
      y2_a = 12;
      x1_b = ( n5 ? 1 : 0 );
      x2_b = ( n6 ? 6 : 7 );
      y1_b = 13;
      y2_b = 13;
      TrazaLinea( hdc2, hdc3, x + x1_a, y1_a, x + x2_a, y2_a );
      TrazaLinea( hdc2, hdc3, x + x1_b, y1_b, x + x2_b, y2_b );
   }
}

void PintaFocos2( HDC hdc2, HDC hdc3, int x, int n1, int n2, int n3, int n4, int n5, int n6, int n7 )
{
   if( n1 )
   {
      TrazaLinea( hdc2, hdc3, x,  0, x + 7,  1 );
   }

   if( n2 )
   {
      TrazaLinea( hdc2, hdc3, x,  0, x + 1,  7 );
   }

   if( n3 )
   {
      TrazaLinea( hdc2, hdc3, x + 6,  0, x + 7,  7 );
   }

   if( n4 )
   {
      TrazaLinea( hdc2, hdc3, x,  6, x + 7,  6 );
      TrazaLinea( hdc2, hdc3, x,  7, x + 7,  7 );
   }

   if( n5 )
   {
      TrazaLinea( hdc2, hdc3, x,  6, x + 1, 13 );
   }

   if( n6 )
   {
      TrazaLinea( hdc2, hdc3, x + 6,  6, x + 7, 13 );
   }

   if( n7 )
   {
      TrazaLinea( hdc2, hdc3, x, 12, x + 7, 13 );
   }
}

void PintaBits( HDC hdc2, HDC hdc3, int x, int n1, int n2, int n3, int n4, int n5, int n6, int n7 )
{
   int y, lineas[ 7 ];

   lineas[ 0 ] = n1;
   lineas[ 1 ] = n2;
   lineas[ 2 ] = n3;
   lineas[ 3 ] = n4;
   lineas[ 4 ] = n5;
   lineas[ 5 ] = n6;
   lineas[ 6 ] = n7;

   for( y = 0; y <= 6; y++ )
   {
      if( lineas[ y ] & 8 )
      {
         TrazaLinea( hdc2, hdc3, x,     ( y * 2 ), x + 1, ( y * 2 ) + 1 );
      }
      if( lineas[ y ] & 4 )
      {
         TrazaLinea( hdc2, hdc3, x + 2, ( y * 2 ), x + 3, ( y * 2 ) + 1 );
      }
      if( lineas[ y ] & 2 )
      {
         TrazaLinea( hdc2, hdc3, x + 4, ( y * 2 ), x + 5, ( y * 2 ) + 1 );
      }
      if( lineas[ y ] & 1 )
      {
         TrazaLinea( hdc2, hdc3, x + 6, ( y * 2 ), x + 7, ( y * 2 ) + 1 );
      }
   }
}

void GeneraNumeros( HDC hdc2, HDC hdc3, int iNum )
{
   if( iNum == 1 )
   {
      ///// Números tipo LCD "estilizados"
      PintaFocos( hdc2, hdc3,  0, 1, 1, 1, 0, 1, 1, 1 );
      PintaFocos( hdc2, hdc3,  8, 0, 0, 1, 0, 0, 1, 0 );
      PintaFocos( hdc2, hdc3, 16, 1, 0, 1, 1, 1, 0, 1 );
      PintaFocos( hdc2, hdc3, 24, 1, 0, 1, 1, 0, 1, 1 );
      PintaFocos( hdc2, hdc3, 32, 0, 1, 1, 1, 0, 1, 0 );
      PintaFocos( hdc2, hdc3, 40, 1, 1, 0, 1, 0, 1, 1 );
      PintaFocos( hdc2, hdc3, 48, 1, 1, 0, 1, 1, 1, 1 );
      PintaFocos( hdc2, hdc3, 56, 1, 0, 1, 0, 0, 1, 0 );
      PintaFocos( hdc2, hdc3, 64, 1, 1, 1, 1, 1, 1, 1 );
      PintaFocos( hdc2, hdc3, 72, 1, 1, 1, 1, 0, 1, 1 );
   }
   else if( iNum == 2 )
   {
      ///// Números tipo LCD "cuadrados"
      PintaFocos2( hdc2, hdc3,  0, 1, 1, 1, 0, 1, 1, 1 );
      PintaFocos2( hdc2, hdc3,  8, 0, 0, 1, 0, 0, 1, 0 );
      PintaFocos2( hdc2, hdc3, 16, 1, 0, 1, 1, 1, 0, 1 );
      PintaFocos2( hdc2, hdc3, 24, 1, 0, 1, 1, 0, 1, 1 );
      PintaFocos2( hdc2, hdc3, 32, 0, 1, 1, 1, 0, 1, 0 );
      PintaFocos2( hdc2, hdc3, 40, 1, 1, 0, 1, 0, 1, 1 );
      PintaFocos2( hdc2, hdc3, 48, 1, 1, 0, 1, 1, 1, 1 );
      PintaFocos2( hdc2, hdc3, 56, 1, 0, 1, 0, 0, 1, 0 );
      PintaFocos2( hdc2, hdc3, 64, 1, 1, 1, 1, 1, 1, 1 );
      PintaFocos2( hdc2, hdc3, 72, 1, 1, 1, 1, 0, 1, 1 );
   }
   else
   {
      ///// Números tipo "bits"
      PintaBits( hdc2, hdc3,  0,  6,  9,  9,  9,  9,  9,  6 );
      PintaBits( hdc2, hdc3,  8,  2,  6,  2,  2,  2,  2,  7 );
      PintaBits( hdc2, hdc3, 16,  6,  9,  1,  2,  4,  8, 15 );
      PintaBits( hdc2, hdc3, 24,  6,  9,  1,  2,  1,  9,  6 );
      PintaBits( hdc2, hdc3, 32,  2,  6, 10, 15,  2,  2,  2 );
      PintaBits( hdc2, hdc3, 40, 15,  8, 14,  1,  1,  9,  6 );
      PintaBits( hdc2, hdc3, 48,  7,  8,  8, 14,  9,  9,  6 );
      PintaBits( hdc2, hdc3, 56, 15,  1,  2,  4,  4,  4,  4 );
      PintaBits( hdc2, hdc3, 64,  6,  9,  9,  6,  9,  9,  6 );
      PintaBits( hdc2, hdc3, 72,  6,  9,  9,  7,  1,  1, 14 );
   }
}

HBITMAP InicializaNumeros( HWND hWnd, int iColor1, int iColor2, int iNum )
{
   HBITMAP hBmp, hColor;
   HDC hdc1, hdc2, hdc3;
   HBRUSH hBrush;
   RECT rect;

   hdc1 = GetDC( hWnd );
   hdc2 = CreateCompatibleDC( hdc1 );
   hdc3 = CreateCompatibleDC( hdc1 );
   SetRect( &rect, 0, 0, 8 * 10, 14 );
   hBmp = CreateCompatibleBitmap( hdc1, rect.right, rect.bottom );
   SelectObject( hdc2, hBmp );
   hColor = CreateCompatibleBitmap( hdc1, rect.right, rect.bottom );
   SelectObject( hdc3, hColor );
   hBrush = CreateSolidBrush( iColor2 );
   FillRect( hdc2, &rect, hBrush );
   DeleteObject( hBrush );
   hBrush = CreateSolidBrush( iColor1 );
   FillRect( hdc3, &rect, hBrush );
   DeleteObject( hBrush );

   SetStretchBltMode( hdc2, HALFTONE );
   SetBrushOrgEx( hdc2, 0, 0, NULL );

   GeneraNumeros( hdc2, hdc3, iNum );

   DeleteDC( hdc1 );
   DeleteDC( hdc2 );
   DeleteDC( hdc3 );

   return hBmp;
}

HB_FUNC( CREATEICON )   // ( hWnd, nTiempo, nNumeros )
{
   HDC hdc1, hdc2, hdc3;
   HBITMAP hImage;
   HWND hWnd;
   HBRUSH hBrush;
   RECT rect;
   HIMAGELIST himl;
   HICON hIcon;
   HBITMAP hNumeros1;
   HBITMAP hNumeros2;
   int iNum;
   int iColor0 = 0x000000;   // Color de fondo
   int iColor1 = 0xc0c0c0;   // Minutos
   int iColor2 = 0x00ff00;   // Cantidad de bloques

   hWnd = ( HWND ) hb_parnl( 1 );

   iNum = hb_parni( 3 );
   hNumeros1 = InicializaNumeros( hWnd, iColor1, iColor0, iNum );
   hNumeros2 = InicializaNumeros( hWnd, iColor2, iColor0, iNum );

   hdc1 = GetDC( hWnd );
   hdc2 = CreateCompatibleDC( hdc1 );
   hdc3 = CreateCompatibleDC( hdc1 );
   hImage = CreateCompatibleBitmap( hdc1, 32, 32 );
   SelectObject( hdc2, hImage );
   hBrush = CreateSolidBrush( iColor0 );
   SetRect( &rect, 0, 0, 32, 32 );
   FillRect( hdc2, &rect, hBrush );
   DeleteObject( hBrush );

   SetStretchBltMode( hdc2, HALFTONE );
   SetBrushOrgEx( hdc2, 0, 0, NULL );

   iNum = hb_parni( 2 ) / 60;
   SelectObject( hdc3, hNumeros1 );
   StretchBlt( hdc2, 22,  1, 8, 14, hdc3, ( ( iNum % 10 ) * 8 ), 0, 8, 14, SRCCOPY );
   iNum = iNum / 10;
   StretchBlt( hdc2, 12,  1, 8, 14, hdc3, ( ( iNum % 10 ) * 8 ), 0, 8, 14, SRCCOPY );
   iNum = iNum / 10;
   StretchBlt( hdc2,  2,  1, 8, 14, hdc3, ( ( iNum % 10 ) * 8 ), 0, 8, 14, SRCCOPY );

   iNum = hb_parni( 2 ) % 60;
   SelectObject( hdc3, hNumeros2 );
   StretchBlt( hdc2, 16, 17, 8, 14, hdc3, ( ( iNum % 10 ) * 8 ), 0, 8, 14, SRCCOPY );
   iNum = iNum / 10;
   StretchBlt( hdc2,  6, 17, 8, 14, hdc3, ( ( iNum % 10 ) * 8 ), 0, 8, 14, SRCCOPY );

   DeleteDC( hdc1 );
   DeleteDC( hdc2 );
   DeleteDC( hdc3 );

   himl = ImageList_Create( 32, 32, ILC_COLOR, 1, 1 );
   ImageList_Add( himl, hImage, NULL );
   hIcon = ImageList_GetIcon( himl, 0, ILD_IMAGE );
   ImageList_Destroy( himl );

   DeleteObject( hImage );
   hb_retnl( ( int ) hIcon );
}

#pragma ENDDUMP
