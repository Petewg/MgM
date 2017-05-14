#include <mgdefs.h>
#include "hbgdiplus.h"

//////////////////////////////////////////////////////////////////////////////
/* Image Attributes functions */
#include "inc\imageattr.inc"
//////////////////////////////////////////////////////////////////////////////
HB_FUNC( GDIPCREATEIMAGEATTRIBUTES ) 
{
   GpImageAttributes * imageattr = NULL;

   if( NULL == fn_GdipCreateImageAttributes )
      ASSIGN_FUNCPTR( g_GpModule, GdipCreateImageAttributes );

   if( NULL != fn_GdipCreateImageAttributes )
      hb_retni( fn_GdipCreateImageAttributes( &imageattr ) );
   else
      hb_retni( ( int ) NotImplemented );

   hb_storptr( imageattr, 2 );
}

HB_FUNC( GDIPDISPOSEIMAGEATTRIBUTES ) 
{
   if( NULL == fn_GdipDisposeImageAttributes )
      ASSIGN_FUNCPTR( g_GpModule, GdipDisposeImageAttributes );

   if( NULL != fn_GdipDisposeImageAttributes )
      hb_retni( fn_GdipDisposeImageAttributes( hb_parptr( 1 ) ) );
   else
      hb_retni( NotImplemented );
}
