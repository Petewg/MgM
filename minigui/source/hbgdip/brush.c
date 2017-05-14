#include <mgdefs.h>
#include "hbgdiplus.h"

//////////////////////////////////////////////////////////////////////////////
/* Brush functions */
#include "inc\brush.inc"
//////////////////////////////////////////////////////////////////////////////
HB_FUNC( GDIPDELETEBRUSH )
{
   if( NULL == fn_GdipDeleteBrush )
      ASSIGN_FUNCPTR( g_GpModule, GdipDeleteBrush );

   if( NULL != fn_GdipDeleteBrush )
      hb_retni( fn_GdipDeleteBrush( hb_parptr( 1 ) ) );
   else
      hb_retni( NotImplemented );
}

HB_FUNC( GDIPCLONEBRUSH )
{
   if( NULL == fn_GdipCloneBrush )
      ASSIGN_FUNCPTR( g_GpModule, GdipCloneBrush );

   if( NULL != fn_GdipCloneBrush )
   {
      GpStatus status;
      GpBrush * brush;

      status = fn_GdipCloneBrush( hb_parptr( 1 ), &brush );

      hb_storptr( ( ( status == Ok ) ? ( void *) brush : NULL ), 2 );
      hb_retni( status );
   }
   else
      hb_retni( NotImplemented );
}

HB_FUNC( GDIPGETBRUSHTYPE )
{
   if( NULL == fn_GdipGetBrushType )
      ASSIGN_FUNCPTR( g_GpModule, GdipGetBrushType );

   if( NULL != fn_GdipGetBrushType )
   {
      GpBrushType type;

      hb_retni( fn_GdipGetBrushType( hb_parptr( 1 ), &type ) );
      hb_storni( ( int ) type, 2 );
   }
   else
      hb_retni( ( int ) NotImplemented );
}

HB_FUNC( GDIPCREATESOLIDFILL )
{
   if( NULL == fn_GdipCreateSolidFill )
      ASSIGN_FUNCPTR( g_GpModule, GdipCreateSolidFill );

   if( NULL != fn_GdipCreateSolidFill )
   {
      ARGB argb       = ( ARGB ) hb_parnl( 1 );
      GpSolidFill * solid;
      GpStatus status = fn_GdipCreateSolidFill( argb, &solid );

      hb_storptr( ( ( status == Ok ) ? ( void *) solid : NULL ), 2 );
      hb_retni( status );
   }
   else
      hb_retni( NotImplemented );
}

HB_FUNC( GDIPSETSOLIDFILLCOLOR )
{
   if( NULL == fn_GdipSetSolidFillColor )
      ASSIGN_FUNCPTR( g_GpModule, GdipSetSolidFillColor );

   if( NULL != fn_GdipSetSolidFillColor )
   {
      GpSolidFill * solid = ( GpSolidFill * ) hb_parptr( 1 );
      ARGB argb = ( ARGB ) hb_parnl( 2 );

      hb_retni( fn_GdipSetSolidFillColor( solid, argb ) );
   }
   else
      hb_retni( NotImplemented );
}

HB_FUNC( GDIPGETSOLIDFILLCOLOR )
{
   if( NULL == fn_GdipGetSolidFillColor )
      ASSIGN_FUNCPTR( g_GpModule, GdipGetSolidFillColor );

   if( NULL != fn_GdipGetSolidFillColor )
   {
      GpSolidFill * solid = ( GpSolidFill * ) hb_parptr( 1 );
      ARGB argb;

      hb_retni( fn_GdipGetSolidFillColor( solid, &argb ) );

      hb_stornint( ( HB_MAXINT ) argb, 2 );
   }
   else
      hb_retni( NotImplemented );
}
