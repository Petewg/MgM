#include <mgdefs.h>
#include "hbgdiplus.h"

//////////////////////////////////////////////////////////////////////////////
/* Graphics functions */
#include "inc\graphics.inc"
//////////////////////////////////////////////////////////////////////////////
/* GDI+ Load local ext. */
GpStatus GpExtLoadGraphics( void )
{
   if( NULL == g_GpModule )
      return GdiplusNotInitialized;

   if( _EMPTY_PTR( g_GpModule, GdipFlush ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateFromHDC ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipCreateFromHWND ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipDeleteGraphics ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipDrawEllipse ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipDrawImage ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipDrawImageRectRect ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipTranslateWorldTransform ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipRotateWorldTransform ) )
      return NotImplemented;

   return Ok;
}

//////////////////////////////////////////////////////////////////////////////
HB_FUNC( GDIPCREATEFROMHDC )
{
   HDC hDC = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );
   GpGraphics * graphics = NULL;

   if( OBJ_DC == GetObjectType( hDC ) )
      hb_retni( fn_GdipCreateFromHDC( hDC, &graphics ) );
   else
      hb_retni( InvalidParameter );

   hb_storptr( graphics, 2 );
}

HB_FUNC( GDIPCREATEFROMHWND )
{
   HWND hWnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );
   GpGraphics * graphics = NULL;

   if( IsWindow( hWnd ) )
      hb_retni( fn_GdipCreateFromHWND( hWnd, &graphics ) );
   else
      hb_retni( InvalidParameter );

   hb_storptr( graphics, 2 );
}

HB_FUNC( GDIPDELETEGRAPHICS )
{
   GpGraphics * graphics = hb_parptr( 1 );

   if( NULL != graphics )
      hb_retni( fn_GdipDeleteGraphics( graphics ) );
   else
      hb_retni( InvalidParameter );
}

HB_FUNC( GDIPDRAWELLIPSE )
{
   GpGraphics * graphics = hb_parptr( 1 );
   GpPen * pen = hb_parptr( 2 );
   REAL fX1 = HB_REAL( 3 );
   REAL fY1 = HB_REAL( 4 );
   REAL fX2 = HB_REAL( 5 );
   REAL fY2 = HB_REAL( 6 );

   if( NULL != graphics && NULL != pen )
      hb_retni( fn_GdipDrawEllipse( graphics, pen, fX1, fY1, fX2, fY2 ) );
   else
      hb_retni( InvalidParameter );
}

HB_FUNC( GDIPDRAWIMAGE )
{
   GpGraphics * graphics = hb_parptr( 1 );
   GpImage * image = hb_parptr( 2 );
   REAL fX1 = HB_REAL( 3 );
   REAL fY1 = HB_REAL( 4 );

   if( NULL != graphics && NULL != image )
      hb_retni( fn_GdipDrawImage( graphics, image, fX1, fY1 ) );
   else
      hb_retni( InvalidParameter );
}

HB_FUNC( GDIPDRAWIMAGERECTRECT )
{
   GpGraphics * graphics = hb_parptr( 1 );
   GpImage * image = hb_parptr( 2 );
   REAL dstx      = HB_REAL( 3 );
   REAL dsty      = HB_REAL( 4 );
   REAL dstwidth  = HB_REAL( 5 );
   REAL dstheight = HB_REAL( 6 );
   REAL srcx      = HB_REAL( 7 );
   REAL srcy      = HB_REAL( 8 );
   REAL srcwidth  = HB_REAL( 9 );
   REAL srcheight = HB_REAL( 10 );

   if( NULL != graphics && NULL != image )
      hb_retni( fn_GdipDrawImageRectRect( graphics, image, 
         dstx, dsty, dstwidth, dstheight, 
         srcx, srcy, srcwidth, srcheight, 
         ( GpUnit ) hb_parns(11), (GDIPCONST GpImageAttributes *) hb_parptr(12) ,
         NULL, NULL ) );
   else
      hb_retni( InvalidParameter );
}

HB_FUNC( GDIPTRANSLATEWORLDTRANSFORM )
{
   GpGraphics * graphics = hb_parptr( 1 );
   REAL fX1 = HB_REAL( 2 );
   REAL fY1 = HB_REAL( 3 );

   if( NULL != graphics )
      hb_retni( fn_GdipTranslateWorldTransform( graphics, fX1, fY1, ( GpMatrixOrder ) hb_parns( 4 ) ) );
   else
      hb_retni( InvalidParameter );
}

HB_FUNC( GDIPROTATEWORLDTRANSFORM )
{
   GpGraphics * graphics = hb_parptr( 1 );
   REAL fAngle = HB_REAL( 2 );

   if( NULL != graphics )
      hb_retni( fn_GdipRotateWorldTransform( graphics, fAngle, ( GpMatrixOrder ) hb_parns( 3 ) ) );
   else
      hb_retni( InvalidParameter );
}
