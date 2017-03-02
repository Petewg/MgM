/*
 * FoxPro compatible functions BETWEEN(), INLIST()
 *
 * Copyright 2016 Przemyslaw Czerpak <druzus / at / priv.onet.pl>
 *
 */

#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC( BETWEEN )
{
   HB_BOOL fResult = HB_FALSE;
   if( hb_pcount() == 3 )
   {
      PHB_ITEM pItem = hb_param( 1, HB_IT_ANY );
      int iResult1, iResult2;

      if( hb_itemCompare( pItem, hb_param( 2, HB_IT_ANY ), HB_FALSE, &iResult1 ) &&
          hb_itemCompare( pItem, hb_param( 3, HB_IT_ANY ), HB_FALSE, &iResult2 ) )
         fResult = iResult1 >= 0 && iResult2 <= 0;
   }
   hb_retl( fResult );
}

HB_FUNC( INLIST )
{
   HB_BOOL fResult = HB_FALSE;
   int iPCount = hb_pcount();

   if( iPCount > 1 )
   {
      PHB_ITEM pValue = hb_param( 1, HB_IT_ANY );
      int iParam;

      for( iParam = 2; iParam < iPCount; ++iParam )
      {
         if( hb_itemEqual( pValue, hb_param( iParam, HB_IT_ANY ) ) )
         {
            fResult = HB_TRUE;
            break;
         }
      }
   }
   hb_retl( fResult );
}
