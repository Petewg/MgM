#include <mgdefs.h>
#include "hbgdiplus.h"

//////////////////////////////////////////////////////////////////////////////
/* Pen functions */

typedef GpStatus ( WINGDIPAPI * GdipCreatePen1_ptr ) ( ARGB, REAL, GpUnit, GpPen** );
typedef GpStatus ( WINGDIPAPI * GdipDeletePen_ptr ) ( GpPen* );

DECLARE_FUNCPTR( GdipCreatePen1 );
DECLARE_FUNCPTR( GdipDeletePen );
//////////////////////////////////////////////////////////////////////////////
/* GDI+ Load local ext. */
GpStatus GpExtLoadPen( void )
{
   if( NULL == g_GpModule )
      return GdiplusNotInitialized;

   if( _EMPTY_PTR( g_GpModule, GdipCreatePen1 ) )
      return NotImplemented;

   if( _EMPTY_PTR( g_GpModule, GdipDeletePen ) )
      return NotImplemented;

   return Ok;
}

//////////////////////////////////////////////////////////////////////////////
HB_FUNC( GDIPCREATEPEN1 )
{
   ARGB   argb   =  ( ARGB ) hb_parnl( 1 );
   REAL   fWidth = HB_REAL( 2 );
   GpUnit uiUnit = ( GpUnit ) hb_parnsdef( 3, UnitPixel );
   GpPen * pen = NULL;

   fn_GdipCreatePen1( argb, fWidth, uiUnit, &pen );

   hb_retptr( pen );
}

HB_FUNC( GDIPDELETEPEN )
{
   GpPen * pen = hb_parptr( 1 );

   if( NULL != pen )
      hb_retni( fn_GdipDeletePen( pen ) );
   else
      hb_retni( InvalidParameter );
}
