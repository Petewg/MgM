/*
 * FillTriangle.prg
 *
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Revised by Grigory Filatov, 31/08/2012
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Function Main()

	DEFINE WINDOW Form_1 AT 0,0 ;
		WIDTH 261 ;
		HEIGHT 287 - IF(_HMG_IsXP .And. IsXPThemeActive(), 0, 7) ;
		TITLE 'Gradient Triangle Demo' ;
		MAIN ;
		NOMAXIMIZE NOSIZE NOSYSMENU ;
		ON RELEASE ExitGradientFunc() ;
		ON PAINT OnPaint() ;
                ON MOUSEMOVE ShowRGB()  

		ON KEY ESCAPE ACTION ThisWindow.Release
	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

/*
 PRG-level
*/
Function OnPaint()
LOCAL hDC, pps

	hDC := BeginPaint( _HMG_MainHandle, @pps )

	FillGradientEx( hDC )

	EndPaint( _HMG_MainHandle, pps )
	ReleaseDC( _HMG_MainHandle, hDC )

Return Nil

Function ShowRGB()
LOCAL hdc, x, y, aColor := {0,0,0}

	hdc := GetDC( _HMG_MainHandle )
	x := _HMG_MouseCol
	y := _HMG_MouseRow
	IF GetPixelColor( hdc, x, y, @aColor )
		Form_1.Title := "RGB (" ;
				+ " r:" + str(aColor[1], 3 ) ;
				+ " g:" + str(aColor[2], 3 ) ;
				+ " b:" + str(aColor[3], 3 ) ;
				+ " )"
	ELSE
		Form_1.Title := "RGB ( CLR_INVALID )"
	ENDIF
	ReleaseDC( _HMG_MainHandle, hdc )

Return Nil

/*
 C-level
*/
#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

#ifdef __XHARBOUR__
#define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

typedef UINT (CALLBACK* MSIMG32GradientFill)(HDC,CONST PTRIVERTEX,DWORD,CONST PVOID,DWORD,DWORD);

HB_FUNC( FILLGRADIENTEX )
{
   HINSTANCE m_hMsimg32;
   MSIMG32GradientFill m_dllGradientFillFunc;
   TRIVERTEX rcVertex[4];
   GRADIENT_TRIANGLE gTri[2];
   
   BOOL bPaintedGradient = FALSE;

   m_hMsimg32 = LoadLibrary( "msimg32.dll" );
   if ( m_hMsimg32 != NULL ) {
     m_dllGradientFillFunc = ( (MSIMG32GradientFill) GetProcAddress( m_hMsimg32, "GradientFill" ) );
     if ( m_dllGradientFillFunc != NULL ) {

       rcVertex[0].x = 0;
       rcVertex[0].y = 0;
       rcVertex[0].Red = (USHORT) (255 << 8);
       rcVertex[0].Green = 0;
       rcVertex[0].Blue = 0;
       rcVertex[0].Alpha = 0;

       rcVertex[1].x = 255;
       rcVertex[1].y = 0;
       rcVertex[1].Red = 0;
       rcVertex[1].Green = (USHORT) (255 << 8);
       rcVertex[1].Blue = 0;
       rcVertex[1].Alpha = 0;

       rcVertex[2].x = 255;
       rcVertex[2].y = 255;
       rcVertex[2].Red = 0;
       rcVertex[2].Green = 0;
       rcVertex[2].Blue = (USHORT) (255 << 8);
       rcVertex[2].Alpha = 0;

       rcVertex[3].x = 0;
       rcVertex[3].y = 255;
       rcVertex[3].Red = (USHORT) (255 << 8);
       rcVertex[3].Green = (USHORT)( 255 << 8);
       rcVertex[3].Blue = (USHORT) (255 << 8);
       rcVertex[3].Alpha = 0;

       gTri[0].Vertex1 = 0;  // first triangle
       gTri[0].Vertex2 = 1;
       gTri[0].Vertex3 = 2;

       gTri[1].Vertex1 = 0;  // second triangle
       gTri[1].Vertex2 = 2;
       gTri[1].Vertex3 = 3;

       bPaintedGradient = m_dllGradientFillFunc 
         ( (HDC) hb_parnl( 1 ), rcVertex, 4, &gTri, 2, 
         GRADIENT_FILL_TRIANGLE );
     }
     FreeLibrary( m_hMsimg32 );
   }
   hb_retl( bPaintedGradient );
}

HB_FUNC( GETPIXELCOLOR )
{
  COLORREF pixel, C1, C2, C3;
  BOOL result;

  pixel = GetPixel( (HDC) ( hb_parnl( 1 ) ), hb_parnl( 2 ), hb_parnl( 3 ) );
  result = ( pixel != CLR_INVALID ? TRUE : FALSE );
  if ( result )
  {  
    C1 = (USHORT) ( GetRValue( pixel ) ); 
    C2 = (USHORT) ( GetGValue( pixel ) );
    C3 = (USHORT) ( GetBValue( pixel ) );
    HB_STORNI( C1, 4, 1);
    HB_STORNI( C2, 4, 2);
    HB_STORNI( C3, 4, 3);
  }  
  hb_retl( result );  
}

#pragma ENDDUMP
