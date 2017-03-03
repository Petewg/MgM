/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2008 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"

Function Main

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 440 ;
		HEIGHT 400 ;
		TITLE 'Get Adapters Info' ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT ( Win_1.Text_1.Value := GetAdapters() )

		DEFINE EDITBOX Text_1
			ROW    10
			COL    10
			WIDTH  420 - 2 * GetBorderWidth()
			HEIGHT 380 - GetTitleHeight() - 2 * GetBorderHeight()
			FONTNAME "Courier New"
			FONTSIZE 9
			TABSTOP .T.
			READONLY .T.
        		VALUE ""
		END EDITBOX

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return Nil


Function GetAdapters()
   Local aAdapter, cValue := "", item
   Local aAdapters := GetAdaptersInfo()

   for item:=1 to len(aAdapters)
      aAdapter := aAdapters[item]
      if ISARRAY( aAdapter )
         cValue += aAdapter[1] + ' ' + aAdapter[2] + CRLF
         cValue += "MAC Address ...... : " + IFCHAR(aAdapter[3], aAdapter[3], "") + CRLF
         cValue += "Address     ...... : " + IFCHAR(aAdapter[4], aAdapter[4], "") + CRLF
         cValue += "Mask        ...... : " + IFCHAR(aAdapter[5], aAdapter[5], "") + CRLF
         cValue += "Gateway     ...... : " + IFCHAR(aAdapter[6], aAdapter[6], "") + CRLF
         cValue += CRLF
      endif
   next

Return cValue


#pragma BEGINDUMP

#include <windows.h>

#include <Iphlpapi.h> 
#include "hbapi.h" 
#include "hbapiitm.h" 
#include "hbapierr.h"

/*********************************************************************
* Author: Xavi <jarabal@gmail.com>
* CAPTURA INFORMACIÓN DE ADAPTADORES
* ----------------------------------
* aAdapters := GetAdaptersInfo()
* aAdapters : { {cTipo, cNameDes, cMAC, cAddress, cMask, cGateway} }
**********************************************************************/
HB_FUNC( GETADAPTERSINFO )
{
   DWORD dwRetVal;
   ULONG i, ulOutBufLen = sizeof(IP_ADAPTER_INFO);
   PIP_ADAPTER_INFO pAdapterInfo = (IP_ADAPTER_INFO *)hb_xgrab( sizeof(IP_ADAPTER_INFO) );
   PHB_ITEM pItmArray = hb_itemNew( NULL ); hb_arrayNew( pItmArray, 0 );

   if( (dwRetVal = GetAdaptersInfo( pAdapterInfo, &ulOutBufLen )) == ERROR_BUFFER_OVERFLOW ){
      hb_xfree( pAdapterInfo );
      pAdapterInfo = (PIP_ADAPTER_INFO)hb_xgrab( ulOutBufLen );
      dwRetVal = ERROR_SUCCESS;
   }
   if( dwRetVal == ERROR_SUCCESS &&
      (dwRetVal = GetAdaptersInfo( pAdapterInfo, &ulOutBufLen )) == NO_ERROR ){
      PIP_ADAPTER_INFO pAdapter = pAdapterInfo;
      char acFrt[4], *szFrtMAC;
      PHB_ITEM ItmSubarray;
      while( pAdapter ){
         hb_arrayNew( &ItmSubarray, 6 );
         switch( pAdapter->Type ){
         case MIB_IF_TYPE_OTHER:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "Other" );
            break;
         case MIB_IF_TYPE_ETHERNET:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "Ethernet" );
            break;
         case MIB_IF_TYPE_TOKENRING:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "Token Ring" );
            break;
         case MIB_IF_TYPE_FDDI:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "FDDI" );
            break;
         case MIB_IF_TYPE_PPP:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "PPP" );
            break;
         case MIB_IF_TYPE_LOOPBACK:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "Lookback" );
            break;
         case MIB_IF_TYPE_SLIP:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "Slip" );
            break;
         default:
            hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 1 ), "Unknown type" );
         }
         hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 2 ), pAdapter->Description );
         szFrtMAC = (char *)hb_xgrab( 3 * pAdapter->AddressLength + 1 );
         for( i = 0; i < pAdapter->AddressLength; i++ ){
            sprintf( acFrt, "%02X-", pAdapter->Address[i] );
            strcpy( szFrtMAC + (3 * i), acFrt );
         }
         hb_itemPutCL( hb_arrayGetItemPtr( &ItmSubarray, 3 ), szFrtMAC, 3 * pAdapter->AddressLength - 1 );
         hb_xfree( szFrtMAC );
         hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 4 ), pAdapter->IpAddressList.IpAddress.String );
         hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 5 ), pAdapter->IpAddressList.IpMask.String );
         hb_itemPutC( hb_arrayGetItemPtr( &ItmSubarray, 6 ), pAdapter->GatewayList.IpAddress.String );
         hb_arrayAddForward( pItmArray, &ItmSubarray );
         pAdapter = pAdapter->Next;
      }
   }
   hb_xfree( pAdapterInfo );
   hb_itemRelease( hb_itemReturnForward( pItmArray ) );
   if( dwRetVal != NO_ERROR &&
       dwRetVal != ERROR_NO_DATA ){
      char szErrorMsg[64];
      sprintf( szErrorMsg, "GetAdaptersInfo failed with error: %d", dwRetVal );
      hb_errRT_BASE_SubstR( EG_ARG, 0, szErrorMsg, NULL, 0 );
   }
}

#pragma ENDDUMP

