#include <mgdefs.h>
#include "hbgdiplus.h"

//////////////////////////////////////////////////////////////////////////////
extern GpStatus GpExtLoadGraphics( void );
extern GpStatus GpExtLoadPen( void );

//////////////////////////////////////////////////////////////////////////////
HB_FUNC( GDIPLUSINITEXT )
{
   UINT ufLoad = ( UINT ) hb_parns( 1 );
   GpStatus status = InvalidParameter;

   if( 0 != ( ufLoad & _GDI_GRAPHICS ) )
      status = GpExtLoadGraphics();

   if( Ok == status )
      GpExtLoadPen();

   hb_retni( status );
}

BOOL Array2ARGB( PHB_ITEM pARGB, ARGB * argb )
{
   if( pARGB && ( 4 == hb_arrayLen( pARGB ) ) )
   {
      BYTE a, r, g, b;

      a = ( USHORT ) HB_arrayGetNL( pARGB, 1 );
      r = ( USHORT ) HB_arrayGetNL( pARGB, 2 );
      g = ( USHORT ) HB_arrayGetNL( pARGB, 3 );
      b = ( USHORT ) HB_arrayGetNL( pARGB, 4 );

      *argb = MakeARGB( a, r, g, b );

      return TRUE;
   }
   return FALSE;
}

HB_FUNC( MAKEARGB )
{
   ARGB argb;

   if( Array2ARGB( hb_param( 1, HB_IT_ARRAY ), &argb ) )
      hb_retnint( ( HB_MAXINT ) argb );
   else
   {
      if( 4 == hb_pcount() )
         hb_retnint(
            ( HB_MAXINT ) MakeARGB(
               ( USHORT ) hb_parnldef( 1, 255 ),
               ( USHORT ) hb_parnldef( 2, 0xFF ),
               ( USHORT ) hb_parnldef( 3, 0xFF ),
               ( USHORT ) hb_parnldef( 4, 0xFF ) ) );
      else
         hb_retnint( ( HB_MAXINT ) CLR_INVALID );
   }
}
