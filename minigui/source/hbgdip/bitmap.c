#include <mgdefs.h>
#include "hbgdiplus.h"

//////////////////////////////////////////////////////////////////////////////
/* Bitmap functions */
#include "inc\bitmap.inc"
//////////////////////////////////////////////////////////////////////////////
HB_FUNC( GDIPCLONEBITMAPAREA )
{
   if( NULL == fn_GdipCloneBitmapArea )
      ASSIGN_FUNCPTR( g_GpModule, GdipCloneBitmapArea );

   if( NULL != fn_GdipCloneBitmapArea )
   {
      REAL      x = HB_REAL( 1 );
      REAL      y = HB_REAL( 2 );
      REAL  width = HB_REAL( 3 );
      REAL height = HB_REAL( 4 );

      PixelFormat format = hb_parni( 5 );
      GpBitmap * srcBitmap = hb_parptr ( 6 );
      GpBitmap * dstBitmap = NULL;

      if( NULL != srcBitmap )
         hb_retni( fn_GdipCloneBitmapArea( x, y, width, height, format, srcBitmap, &dstBitmap ) );
      else
         hb_retni( InvalidParameter );

      hb_storptr( dstBitmap, 7 );
   }
   else
      hb_retni( NotImplemented );
}
