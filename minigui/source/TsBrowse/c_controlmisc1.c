
#define _WIN32_IE     0x0500
#define _WIN32_WINNT  0x0400

#include <mgdefs.h>
#include <commctrl.h>

#include "item.api"

#if defined( __BORLANDC__ ) && ! defined( HB_ARCH_64BIT )
   #undef MAKELONG
   #define MAKELONG( a, b )   ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )
#endif

extern HBITMAP HMG_LoadPicture( const char * FileName, int New_Width, int New_Height, HWND hWnd, int ScaleStretch, int Transparent, long BackgroundColor, int AdjustImage,
                                HB_BOOL bAlphaFormat, int iAlpfaConstant );

BOOL Array2Rect( PHB_ITEM aRect, RECT * rc );
PHB_ITEM             Rect2Array( RECT * rc );

static far BYTE StopXor[] = {
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x01, 0xF8, 0x00, 0x00, 0x06, 0x06, 0x00, 0x00, 0x08, 0x01, 0x00, 0x00, 0x11, 0xF8, 0x80,
   0x00, 0x26, 0x08, 0x40, 0x00, 0x24, 0x12, 0x40, 0x00, 0x48, 0x25, 0x20, 0x00, 0x48, 0x49, 0x20,
   0x00, 0x48, 0x91, 0x20, 0x00, 0x49, 0x21, 0x20, 0x00, 0x4A, 0x41, 0x20, 0x00, 0x24, 0x82, 0x40,
   0x00, 0x21, 0x06, 0x40, 0x00, 0x11, 0xF8, 0x80, 0x00, 0x08, 0x01, 0x00, 0x00, 0x06, 0x06, 0x00,
   0x00, 0x01, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static far BYTE StopAnd[] = {
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFE, 0x07, 0xFF, 0xFF, 0xF8, 0x01, 0xFF, 0xFF, 0xF0, 0x00, 0xFF, 0xFF, 0xE0, 0x00, 0x7F,
   0xFF, 0xC1, 0xF0, 0x3F, 0xFF, 0xC3, 0xE0, 0x3F, 0xFF, 0x87, 0xC2, 0x1F, 0xFF, 0x87, 0x86, 0x1F,
   0xFF, 0x87, 0x0E, 0x1F, 0xFF, 0x86, 0x1E, 0x1F, 0xFF, 0x84, 0x3E, 0x1F, 0xFF, 0xC0, 0x7C, 0x3F,
   0xFF, 0xC0, 0xF8, 0x3F, 0xFF, 0xE0, 0x00, 0x7F, 0xFF, 0xF0, 0x00, 0xFF, 0xFF, 0xF8, 0x01, 0xFF,
   0xFF, 0xFE, 0x07, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
   0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
};

static far HCURSOR hStop = 0;


HB_FUNC( NOR )
{
   int p = hb_pcount();
   int n, ret = 0;

   for( n = 1; n <= p; n++ )
   {
      ret = ret | hb_parni( n );
   }

   hb_retni( ret );
}

HB_FUNC( CREATEPEN )
{
   HPEN     hpen;
   int      fnPenStyle = hb_parni( 1 );   // pen style
   int      nWidth     = hb_parni( 2 );   // pen width
   COLORREF crColor    = hb_parni( 3 );   // pen color

   hpen = CreatePen( fnPenStyle, nWidth, crColor );

   HB_RETNL( ( LONG_PTR ) hpen );
}

HB_FUNC( MOVETO )
{
   POINT pt;

   MoveToEx( ( HDC ) HB_PARNL( 1 ), ( INT ) hb_parni( 2 ), ( INT ) hb_parni( 3 ), &pt );
}

HB_FUNC( LINETO )
{
   LineTo( ( HDC ) HB_PARNL( 1 ), ( INT ) hb_parni( 2 ), ( INT ) hb_parni( 3 ) );
}

HB_FUNC( DRAWICON )
{
   hb_retl( DrawIcon( ( HDC ) HB_PARNL( 1 ), hb_parni( 2 ), hb_parni( 3 ), ( HICON ) HB_PARNL( 4 ) ) );
}

HB_FUNC( CURSORWE )
{
   HB_RETNL( ( LONG_PTR ) SetCursor( LoadCursor( 0, IDC_SIZEWE ) ) );
}

HB_FUNC( CURSORSIZE )
{
   HB_RETNL( ( LONG_PTR ) SetCursor( LoadCursor( 0, IDC_SIZEALL ) ) );
}

HB_FUNC( RELEASECAPTURE )
{
   hb_retl( ReleaseCapture() );
}

HB_FUNC( INVERTRECT )
{
   RECT rc;

   if( HB_ISARRAY( 2 ) )
   {
      Array2Rect( hb_param( 2, HB_IT_ARRAY ), &rc );
      InvertRect( ( HDC ) HB_PARNL( 1 ), &rc );
   }
}

HB_FUNC( GETCLASSINFO )
{
   WNDCLASS WndClass;

   if( GetClassInfo( HB_ISNIL( 1 ) ? NULL : ( HINSTANCE ) HB_PARNL( 1 ), ( LPCSTR ) hb_parc( 2 ), &WndClass ) )
   {
      hb_retclen( ( char * ) &WndClass, sizeof( WNDCLASS ) );
   }
}

HB_FUNC( _GETCLIENTRECT )
{
   RECT     rc;
   PHB_ITEM aMetr;

   GetClientRect( ( HWND ) HB_PARNL( 1 ), &rc );

   aMetr = Rect2Array( &rc );

   _itemReturn( aMetr );
   _itemRelease( aMetr );
}

HB_FUNC( ISICONIC )
{
   hb_retl( IsIconic( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( SETCAPTURE )
{
   HB_RETNL( ( LONG_PTR ) SetCapture( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC( SETWINDOWLONG )
{
   #ifndef _WIN64
      hb_retnl( SetWindowLong( ( HWND ) hb_parnl( 1 ), hb_parni( 2 ), hb_parnl( 3 ) ) );
   #else      
      HB_RETNL( SetWindowLongPtr( ( HWND ) HB_PARNL( 1 ), hb_parnl( 2 ), hb_parnl( 3 ) ) );
   #endif   
}

HB_FUNC( GETTEXTCOLOR )
{
   hb_retnl( ( ULONG ) GetTextColor( ( HDC ) HB_PARNL( 1 ) ) );
}

HB_FUNC( GETBKCOLOR )
{
   hb_retnl( ( ULONG ) GetBkColor( ( HDC ) HB_PARNL( 1 ) ) );
}

HB_FUNC( LOADIMAGE )
{
   HWND hwnd = HB_ISNIL( 2 ) ? GetActiveWindow() : ( HWND ) HB_PARNL( 2 );
   HWND himage;

   himage = ( HWND ) HMG_LoadPicture( hb_parc( 1 ), -1, -1, hwnd, 1, 1, -1, 0, HB_FALSE, 255 );

   HB_RETNL( ( LONG_PTR ) himage );
}

HB_FUNC( MOVEFILE )
{
   hb_retl( ( BOOL ) MoveFile( hb_parc( 1 ), hb_parc( 2 ) ) );
}

HB_FUNC( GETACP )
{
   hb_retni( ( UINT ) GetACP() );
}

HB_FUNC( CURSORSTOP )
{
   if( ! hStop )
   {
      hStop = CreateCursor( GetModuleHandle( NULL ), 6, 0, 32, 32, StopAnd, StopXor );
   }

   SetCursor( hStop );
}

HB_FUNC( DESTROYCURSOR )
{
   hb_retl( ( BOOL ) DestroyCursor( ( HCURSOR ) HB_PARNL( 1 ) ) );
}
