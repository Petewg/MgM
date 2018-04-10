/*
 * Harbour Project source code:
 * Socket C kernel
 *
 * Copyright 2001-2003 Matteo Baccan <baccan@infomedia.it>
 * www - https://harbour.github.io/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the Harbour Project gives permission for
 * additional uses of the text contained in its release of Harbour.
 *
 * The exception is that, if you link the Harbour libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the Harbour library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the Harbour
 * Project under the name Harbour.  If you copy code from other
 * Harbour Project or Free Software Foundation releases into a copy of
 * Harbour, as the General Public License permits, the exception does
 * not apply to the code that you add in this way.  To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for Harbour, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */

#include <winsock2.h>
#include <windows.h>

#include "global.h"
#include "md5.h"
#include "base64.h"
#include "hmac_md5.h"

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbapierr.h"

#ifdef __XHARBOUR__
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#endif

static int bInit = FALSE;

/* If startup fails no other functions are allowed */
HB_FUNC( SOCKETINIT )
{
   #define HB_MKWORD( l, h )  ( ( WORD ) ( ( ( BYTE ) ( l ) ) | ( ( ( WORD ) ( ( BYTE ) ( h ) ) ) << 8 ) ) )

   WSADATA WSAData;

   if( WSAStartup(HB_MKWORD(1, 1), &WSAData) == 0 )
      bInit = TRUE;
}

HB_FUNC( SOCKETEXIT )
{
   if( bInit )
      WSACleanup();
}

HB_FUNC( SOCKETVERSION )
{
   hb_retc( "1.08" );
}

HB_FUNC( SOCKETCONNECT )
{
   SOCKET m_hSocket = INVALID_SOCKET;

   if( bInit && HB_ISCHAR(2) && HB_ISNUM(3) )
   {
      int nPort;
      SOCKADDR_IN sockDestinationAddr;
      const char *lpszAsciiDestination;

      lpszAsciiDestination = hb_parc( 2 );
      nPort = hb_parni( 3 );

      m_hSocket = socket( AF_INET, SOCK_STREAM, 0 );
      if( m_hSocket != INVALID_SOCKET )
      {
         /* Determine if the address is in dotted notation */
         ZeroMemory( &sockDestinationAddr, sizeof( sockDestinationAddr ) );
         sockDestinationAddr.sin_family = AF_INET;
         sockDestinationAddr.sin_port = htons( ( u_short ) nPort );
         sockDestinationAddr.sin_addr.s_addr = inet_addr( lpszAsciiDestination );

         /* if the address is not dotted notation, then do a DNS lookup of it */
         if( sockDestinationAddr.sin_addr.s_addr == INADDR_NONE )
         {
            LPHOSTENT lphost;
            lphost = gethostbyname( lpszAsciiDestination );
            if( lphost != NULL )
               sockDestinationAddr.sin_addr.s_addr = ( ( LPIN_ADDR ) lphost->h_addr )->s_addr;
            else
            {
               hb_retl( FALSE );
               return;
            }
         }

         hb_retl( connect(m_hSocket, ( SOCKADDR * ) &sockDestinationAddr, sizeof( sockDestinationAddr ) ) != SOCKET_ERROR );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );

   /* Copy m_hSocket to caller method */
   strncpy( ( char * ) hb_parc(1), ( char * ) &m_hSocket, sizeof( m_hSocket ) );
}

HB_FUNC( SOCKETBIND )
{
   SOCKET m_hSocket = INVALID_SOCKET;

   if( bInit && HB_ISCHAR(2) && HB_ISNUM(3) )
   {
      int nPort;
      SOCKADDR_IN sockDestinationAddr;
      const char *lpszAsciiDestination;

      lpszAsciiDestination = hb_parc( 2 );
      nPort = hb_parni( 3 );

      m_hSocket = socket( AF_INET, SOCK_STREAM, 0 );
      if( m_hSocket != INVALID_SOCKET )
      {
         /* Determine if the address is in dotted notation */
         ZeroMemory( &sockDestinationAddr, sizeof( sockDestinationAddr ) );
         sockDestinationAddr.sin_family = AF_INET;
         sockDestinationAddr.sin_port = htons( ( u_short ) nPort );
         sockDestinationAddr.sin_addr.s_addr = inet_addr( lpszAsciiDestination );

         /* if the address is not dotted notation, then do a DNS lookup of it */
         if( sockDestinationAddr.sin_addr.s_addr == INADDR_NONE )
         {
            LPHOSTENT lphost;
            lphost = gethostbyname( lpszAsciiDestination );
            if( lphost != NULL )
               sockDestinationAddr.sin_addr.s_addr = ( ( LPIN_ADDR ) lphost->h_addr )->s_addr;
            else
            {
               hb_retl( FALSE );
               return;
            }
         }

         hb_retl( bind(m_hSocket, ( SOCKADDR * ) &sockDestinationAddr, sizeof( sockDestinationAddr ) ) != SOCKET_ERROR );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );

   /* Copy m_hSocket to caller method */
   strncpy( ( char * ) hb_parc(1), ( char * ) &m_hSocket, sizeof( m_hSocket ) );
}

HB_FUNC( SOCKETLISTEN )
{
   SOCKET m_hSocket = INVALID_SOCKET;
   SOCKET sClient = INVALID_SOCKET;
   SOCKADDR_IN remote_addr;

   /* Copy m_hSocket from caller method */
   strncpy( ( char * ) &m_hSocket, hb_parc(1), sizeof( m_hSocket ) );

   if( bInit )
   {
      if( m_hSocket != INVALID_SOCKET )
      {
         int nRet = listen( m_hSocket, hb_parni(2) );    // Backlog 10
         if( nRet != SOCKET_ERROR )
         {
            int iAddrLen = sizeof( remote_addr );
            sClient = accept( m_hSocket, ( struct sockaddr * ) &remote_addr, &iAddrLen );

            // Error?
            if( ( long int ) sClient != SOCKET_ERROR )
               hb_retl( TRUE );
            else
               hb_retl( FALSE );
         }
         else
            hb_retl( FALSE );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );

   /* Copy m_hSocket to caller method */
   strncpy( ( char * ) hb_parc(3), ( char * ) &sClient, sizeof( sClient ) );
}

HB_FUNC( SOCKETSEND )
{
   SOCKET m_hSocket = INVALID_SOCKET;

   /* Copy m_hSocket from caller method */
   strncpy( ( char * ) &m_hSocket, hb_parc(1), sizeof( m_hSocket ) );

   if( bInit && HB_ISCHAR(2) )
   {
      if( m_hSocket != INVALID_SOCKET )
      {
         const char *pszBuf = hb_parc( 2 );
         int nBuf = hb_parclen( 2 );
         if( HB_ISNUM(3) )
         {
            int sendtimeout = hb_parni( 3 );
            if( sendtimeout != -1 )
               setsockopt( m_hSocket, SOL_SOCKET, SO_SNDTIMEO, ( char * ) &sendtimeout, sizeof( sendtimeout ) );
         }

         hb_retl( send(m_hSocket, pszBuf, nBuf, 0) != SOCKET_ERROR );
      }
      else
         hb_retl( FALSE );
   }
   else
      hb_retl( FALSE );
}

HB_FUNC( SOCKETRECEIVE )
{
   SOCKET m_hSocket = INVALID_SOCKET;

   if( bInit && hb_parclen(1) == sizeof( m_hSocket ) && HB_ISCHAR(2) && HB_ISBYREF(2) )
   {
      /* Copy m_hSocket from caller method */
      strncpy( ( char * ) &m_hSocket, hb_parc(1), sizeof( m_hSocket ) );
      if( m_hSocket != INVALID_SOCKET )
      {
         int nLen = hb_parclen( 2 );
         if( nLen > 0 )
         {
            char *pRead = ( char * ) hb_xgrab( nLen + 1 );
            if( HB_ISNUM(3) )
            {
               int recvtimeout = hb_parni( 3 );
               if( recvtimeout != -1 )
                  setsockopt( m_hSocket, SOL_SOCKET, SO_RCVTIMEO, ( char * ) &recvtimeout, sizeof( recvtimeout ) );
            }

            nLen = recv( m_hSocket, pRead, nLen, 0 );
            if( nLen < 0 )
               nLen = 0;
            hb_storclen( pRead, nLen, 2 );
            hb_xfree( pRead );
            hb_retni( nLen );
         }
         else
            hb_retni( 0 );
      }
      else
         hb_retni( 0 );
   }
   else
      hb_retni( 0 );
}

HB_FUNC( SOCKETCLOSE )
{
   SOCKET m_hSocket = INVALID_SOCKET;

   /* Copy m_hSocket from caller method */
   strncpy( ( char * ) &m_hSocket, hb_parc(1), sizeof( m_hSocket ) );

   if( bInit && m_hSocket != INVALID_SOCKET )
      hb_retl( SOCKET_ERROR != closesocket(m_hSocket) );
   else
      hb_retl( FALSE );

   m_hSocket = INVALID_SOCKET;

   /* Copy m_hSocket to caller method */
   strncpy( ( char * ) hb_parc(1), ( char * ) &m_hSocket, sizeof( m_hSocket ) );
}

HB_FUNC( SOCKETLOCALNAME )
{
   char ac[ 80 ];

   if( bInit && gethostname(ac, sizeof( ac ) ) != SOCKET_ERROR )
      hb_retc( ac );
   else
      hb_retc( "" );
}

HB_FUNC( SOCKETLOCALADDRESS )
{
   char ac[ 80 ];

   if( bInit && gethostname(ac, sizeof( ac ) ) != SOCKET_ERROR )
   {
      struct hostent *phe = gethostbyname( ac );
      if( phe != 0 )
      {
         int i = 0;
         while( phe->h_addr_list[ i ] != 0 )
            i++;

         hb_reta( i );

         for( i = 0; phe->h_addr_list[ i ] != 0; ++i )
         {
            struct in_addr addr;
            memcpy( &addr, phe->h_addr_list[ i ], sizeof( struct in_addr ) );
            HB_STORC( inet_ntoa(addr), -1, i + 1 );
         }
      }
      else
         hb_reta( 0 );
   }
   else
      hb_reta( 0 );
}

HB_FUNC( SOCKETMD5 )
{
   if( HB_ISCHAR(1) )
   {
      unsigned char *string;
      MD5_CTX context;
      unsigned char digest[ 16 ];
      unsigned int len = hb_parclen( 1 );
      UINT j;
      char *pRet;

      string = ( unsigned char * ) hb_parc( 1 );

      MD5Init( &context );
      MD5Update( &context, ( unsigned char * ) string, len );
      MD5Final( digest, &context );

      pRet = ( char * ) hb_xgrab( sizeof digest * 2 + 1 );
      for( j = 0; j < sizeof digest; j++ )
         sprintf( pRet + ( j * 2 ), "%02x", digest[ j ] );

      hb_retclen( pRet, sizeof digest * 2 );
      hb_xfree( pRet );
   }
   else
      hb_retc( "" );
}

HB_FUNC( SOCKETENCODE64 )
{
   if( HB_ISCHAR(1) && hb_parclen(1) > 0 )
   {
      char *string;
      char *pRet;
      int nEncodeLen;
      int nSubLen = 0;
      int nAdd;

      if( HB_ISNUM(2) )
         nSubLen = hb_parni( 2 );

      string = ( char * ) hb_parc( 1 );

      nEncodeLen = 4 * ( ( hb_parclen(1) + 2 ) / 3 );
      if( nSubLen > 0 )
      {
         nAdd = hb_parclen( 1 ) / nSubLen;
         nEncodeLen = nEncodeLen + ( ( nAdd + 1 ) * 2 );
      }

      pRet = ( char * ) hb_xgrab( nEncodeLen + 1 );

      pRet[ nEncodeLen ] = 0;
      memset( pRet, '=', nEncodeLen );

      b64encodelen( string, pRet, hb_parclen(1), nSubLen );

      hb_retclen( pRet, nEncodeLen );
      hb_xfree( pRet );
   }
   else
      hb_retc( "" );
}

HB_FUNC( SOCKETDECODE64 )
{
   if( HB_ISCHAR(1) && hb_parclen(1) > 0 )
   {
      char *string;
      char *pRet;
      int nEncodeLen;

      string = ( char * ) hb_parc( 1 );

      nEncodeLen = 3 * ( ( hb_parclen(1) + 3 ) / 4 );
      pRet = ( char * ) hb_xgrab( nEncodeLen );
      memset( pRet, 0, nEncodeLen );

      b64decode( string, pRet );

      hb_retclen( pRet, nEncodeLen );
      hb_xfree( pRet );
   }
   else
      hb_retc( "" );
}

HB_FUNC( SOCKETHMAC_MD5 )
{
   if( HB_ISCHAR(1) && HB_ISCHAR(2) && HB_ISCHAR(3) )
   {
      unsigned char digasc[ 33 ];
      unsigned char digest[ 16 ];
      int i;
      static char hextab[] = "0123456789abcdef";
      signed char *decoded;

      char *username = ( char * ) hb_parc( 1 );
      char *password = ( char * ) hb_parc( 2 );
      char *challenge = ( char * ) hb_parc( 3 );

      hmac_md5( ( unsigned char * ) challenge, strlen(challenge), ( unsigned char * ) password, strlen(password), ( unsigned char * ) digest );

      digasc[ 32 ] = 0;
      for( i = 0; i < 16; i++ )
      {
         digasc[ 2 * i ] = hextab[ digest[ i ] >> 4 ];
         digasc[ 2 * i + 1 ] = hextab[ digest[ i ] & 0xf ];
      }

      decoded = hb_xgrab( strlen(username) + strlen( ( const char * ) digasc) + 2 );

      strcpy( ( char * ) decoded, ( char * ) username );
      strcat( ( char * ) decoded, " " );
      strcat( ( char * ) decoded, ( char * ) digasc );

      hb_retc( ( const char * ) decoded );

      hb_xfree( decoded );
   }
   else
      hb_retc( "" );
}
