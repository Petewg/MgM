#include <mgdefs.h>
#include "hbgdiplus.h"

//////////////////////////////////////////////////////////////////////////////
/* Image functions */
#include "inc\image.inc"
//////////////////////////////////////////////////////////////////////////////
/* hbgdiplus.c
HB_FUNC( GDIPDISPOSEIMAGE ) 
{
   if( NULL == fn_GdipDisposeImage )
      ASSIGN_FUNCPTR( g_GpModule, GdipDisposeImage );

   if( NULL != fn_GdipDisposeImage )
      hb_retni( fn_GdipDisposeImage( hb_parptr( 1 ) ) );
   else
      hb_retni( NotImplemented );
}
 */

HB_FUNC( GDIPLOADIMAGEFROMFILE )
{
   GpImage * image = NULL;

   if( NULL == fn_GdipLoadImageFromFile )
      ASSIGN_FUNCPTR( g_GpModule, GdipLoadImageFromFile );

   if( NULL != fn_GdipLoadImageFromFile )
   {
      HB_WCHAR * lpFName = ( HB_WCHAR * ) ( ( hb_parclen( 1 ) == 0 ) ? NULL : hb_mbtowc( hb_parc( 1 ) ) );

      if( NULL != lpFName )
      {
         hb_retni( fn_GdipLoadImageFromFile( lpFName, &image ) );

         hb_xfree( lpFName );
      }
      else
         hb_retni( InvalidParameter );
   }
   else
      hb_retni( NotImplemented );

   hb_storptr( image, 2 );
}

HB_FUNC( GDIPGETIMAGEDIMENSION )
{
   if( NULL == fn_GdipGetImageDimension )
      ASSIGN_FUNCPTR( g_GpModule, GdipGetImageDimension );

   if( NULL != fn_GdipGetImageDimension )
   {
      GpImage * image = hb_parptr ( 1 );
      REAL      width = 0;
      REAL     height = 0;

      if( NULL != image )
         hb_retni( fn_GdipGetImageDimension( image, &width, &height ) );
      else
         hb_retni( InvalidParameter );

      hb_stornd( width, 2 );
      hb_stornd( height, 3 );
   }
   else
      hb_retni( NotImplemented );
}

HB_FUNC( GDIPGETIMAGEHEIGHT )
{
   if( NULL == fn_GdipGetImageHeight )
      ASSIGN_FUNCPTR( g_GpModule, GdipGetImageHeight );

   if( NULL != fn_GdipGetImageHeight )
   {
      GpImage * image = hb_parptr ( 1 );
      UINT     height = 0;

      if( NULL != image )
         hb_retni( fn_GdipGetImageHeight( image, &height ) );
      else
         hb_retni( InvalidParameter );

      hb_storni( height, 2 );
   }
   else
      hb_retni( NotImplemented );
}

HB_FUNC( GDIPGETIMAGEWIDTH )
{
   if( NULL == fn_GdipGetImageWidth )
      ASSIGN_FUNCPTR( g_GpModule, GdipGetImageWidth );

   if( NULL != fn_GdipGetImageWidth )
   {
      GpImage * image = hb_parptr ( 1 );
      UINT      width = 0;

      if( NULL != image )
         hb_retni( fn_GdipGetImageWidth( image, &width ) );
      else
         hb_retni( InvalidParameter );

      hb_storni( width, 2 );
   }
   else
      hb_retni( NotImplemented );
}
