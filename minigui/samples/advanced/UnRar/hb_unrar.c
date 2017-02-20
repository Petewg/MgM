/*
 * Harbour Project source code:
 * UnRar library low level (client api) interface code
 *
 * Copyright 2007 P.Chornyj <myorg63@mail.ru>
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
 */

#include <windows.h>
#include "unrar.h"
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "hbapifs.h"
#include "hbver.h"

#if HB_VER_MAJOR < 1
#error Too old version [x]Harbour
#endif
#define RAR_ARCNAME     1
#define RAR_FILENAME    2
#define RAR_FLAGS       3
#define RAR_PACKSIZE    4
#define RAR_UNPSIZE     5
#define RAR_HOSTOS      6
#define RAR_FILECRC     7
#define RAR_FILETIME    8
#define RAR_UNPVER      9
#define RAR_METHOD      10
#define RAR_FILEATTR    11

#define RAR_ST_SUCCESS  0
#define RAR_ST_OPEN     1
#define RAR_ST_OUT      2
#define RAR_ST_OPEN_OUT 3
#define RAR_ST_HBROKEN  4

typedef UINT ( CALLBACK *RGetApiDllVersion ) ( void );

static void       OpenProcessFileError( int Error );
static void       OutProcessFileError( int Error, const char *Filename );
static void       ClearError( void );
static int        CALLBACK CallbackProc( UINT msg, LPARAM UserData, LPARAM P1, LPARAM P2 );
static PHB_ITEM   RGetDate( UINT FileTime );
static PHB_ITEM   RConvertFileTimeToString( UINT FileTime, BOOL includeTime, BOOL includeSeconds );

static UINT       s_CmtBufSize = 16384;
static int        s_iOpenError = 0;
static char       s_msgOpenError[64];
static int        s_iOutError = 0;
static char       s_msgOutError[64];
static char       s_FName[_MAX_PATH + 1];
static BOOL       s_bHeaderBroken = FALSE;
static PHB_SYMB   pSymbolCallback = 0;

/*
   Get Unrar.DLL API version
*/

HB_FUNC( HB_RARGETDLLVERSION )
{
   int               iResult = 0;
   HINSTANCE         m_hDLL;
   RGetApiDllVersion m_UnRarDllApiVersion;

   m_hDLL = LoadLibrary( "unrar64.dll" );

   if( m_hDLL != NULL )
   {
      m_UnRarDllApiVersion = ( (RGetApiDllVersion) GetProcAddress(m_hDLL, "RARGetDllVersion") );
      if( m_UnRarDllApiVersion != NULL )
      {
         iResult = m_UnRarDllApiVersion();
      }

      FreeLibrary( m_hDLL );
   }
   else
   {
      iResult = -1;
   }

   hb_retni( iResult );
}

/*
   Archive comments operations	
*/

HB_FUNC( HB_RARSETCMTBUFSIZE )
{
   BOOL  bResult = FALSE;
   int   iSize = hb_parni( 1 );

   if( iSize >= 64 && iSize <= 56535 )
   {
      s_CmtBufSize = hb_parni( 1 );

      bResult = TRUE;
   }
   else
   {
      s_CmtBufSize = 16384;
   }

   hb_retl( bResult );
}

HB_FUNC( HB_RARGETCMTBUFSIZE )
{
   hb_retni( s_CmtBufSize );
}

HB_FUNC( HB_RARGETCOMMENT )
{
   PHB_ITEM                      pCmtState = hb_param( 2, HB_IT_INTEGER );
   HANDLE                        hArcData;
   char                          *CmtBuf = ( char * ) hb_xgrab( s_CmtBufSize );
   struct RAROpenArchiveDataEx   OpenArchiveData;

   hb_xmemset( &OpenArchiveData, 0, sizeof(OpenArchiveData) );
   OpenArchiveData.ArcName = ( char * ) hb_parc( 1 );
   OpenArchiveData.CmtBuf = CmtBuf;
   OpenArchiveData.CmtBufSize = s_CmtBufSize;
   OpenArchiveData.OpenMode = RAR_OM_LIST;

   ClearError();

   hArcData = RAROpenArchiveEx( &OpenArchiveData );
   if( OpenArchiveData.OpenResult == 0 )
   {
      if( OpenArchiveData.CmtState == 1 )
      {
         char  *szTempR = ( char * ) hb_xgrab( OpenArchiveData.CmtSize + 1 );

         hb_xmemset( szTempR, 0, OpenArchiveData.CmtSize + 1 );
         hb_strncpy( szTempR, OpenArchiveData.CmtBuf, OpenArchiveData.CmtSize );

         hb_retclen_buffer( szTempR, OpenArchiveData.CmtSize );
      }
      else
      {
         hb_retc( "" );
      }

      if( pCmtState != NULL )
      {
         hb_storni( OpenArchiveData.CmtState, 2 );
      }
   }
   else
   {
      OpenProcessFileError( OpenArchiveData.OpenResult );

      hb_retc( "" );
   }

   RARCloseArchive( hArcData );

   hb_xfree( CmtBuf );
}

/*
   Get archive info 	
*/

HB_FUNC( HB_RARGETARCHIVEINFO )
{
   HANDLE                        hArcData;
   int                           iResult = 0;
   char                          *CmtBuf = ( char * ) hb_xgrab( s_CmtBufSize );
   struct RAROpenArchiveDataEx   OpenArchiveData;

   hb_xmemset( &OpenArchiveData, 0, sizeof(OpenArchiveData) );
   OpenArchiveData.ArcName = ( char * ) hb_parc( 1 );
   OpenArchiveData.CmtBuf = CmtBuf;
   OpenArchiveData.CmtBufSize = s_CmtBufSize;
   OpenArchiveData.OpenMode = RAR_OM_LIST;

   ClearError();

   hArcData = RAROpenArchiveEx( &OpenArchiveData );
   if( OpenArchiveData.OpenResult == 0 )
   {
      iResult = OpenArchiveData.Flags;
   }
   else
   {
      OpenProcessFileError( OpenArchiveData.OpenResult );
   }

   RARCloseArchive( hArcData );

   hb_xfree( CmtBuf );

   hb_retni( iResult );
}

/*
   Get Number Of Files in Archive 	
*/

HB_FUNC( HB_RARGETFILESCOUNT )
{
   HANDLE                        hArcData;
   int                           RHCode;
   struct RAROpenArchiveDataEx   OpenArchiveData;
   LONG                          lFileCount = 0;

   hb_xmemset( &OpenArchiveData, 0, sizeof(OpenArchiveData) );
   OpenArchiveData.ArcName = ( char * ) hb_parc( 1 );
   OpenArchiveData.CmtBuf = NULL;
   OpenArchiveData.OpenMode = RAR_OM_LIST;

   ClearError();

   hArcData = RAROpenArchiveEx( &OpenArchiveData );
   if( OpenArchiveData.OpenResult == 0 )
   {
      struct RARHeaderDataEx  HeaderData;
      int                     PFCode;
      PHB_ITEM                pPassword = hb_param( 2, HB_IT_STRING );
      BOOL                    bIncludeDirectory = hb_parl( 3 );

      if( pPassword != NULL )
      {
         RARSetPassword( hArcData, ( char * ) hb_itemGetCPtr(pPassword) );
      }

      //  RARSetCallback( hArcData, CallbackProc, 0 );

      HeaderData.CmtBuf = NULL;
      while( (RHCode = RARReadHeaderEx(hArcData, &HeaderData)) == 0 )
      {
         if( bIncludeDirectory )
         {
            lFileCount++;
         }
         else
         {
            if( !(HeaderData.FileAttr & HB_FA_DIRECTORY) )
            {
               lFileCount++;
            }
         }

         if( (PFCode = RARProcessFile(hArcData, RAR_SKIP, NULL, NULL)) != 0 )
         {
            OutProcessFileError( PFCode, HeaderData.FileName );
            break;
         }
      }

      if( RHCode == ERAR_BAD_DATA )
      {
         s_bHeaderBroken = TRUE;
      }
   }
   else
   {
      OpenProcessFileError( OpenArchiveData.OpenResult );
   }

   hb_retnl( lFileCount );

   RARCloseArchive( hArcData );
}

/*
   Get file list from archive
*/

HB_FUNC( HB_RGETFILESLIST )
{
   PHB_ITEM                      pFileList = hb_itemArrayNew( 0 );
   HANDLE                        hArcData;
   int                           RHCode;
   struct RAROpenArchiveDataEx   OpenArchiveData;

   hb_xmemset( &OpenArchiveData, 0, sizeof(OpenArchiveData) );
   OpenArchiveData.ArcName = ( char * ) hb_parc( 1 );
   OpenArchiveData.CmtBuf = NULL;
   OpenArchiveData.OpenMode = RAR_OM_LIST;

   ClearError();

   hArcData = RAROpenArchiveEx( &OpenArchiveData );
   if( OpenArchiveData.OpenResult == 0 )
   {
      struct RARHeaderDataEx  HeaderData;
      int                     PFCode;

      PHB_ITEM                pPassword = hb_param( 2, HB_IT_STRING );

      BOOL                    fFileTimeAsDate = hb_parl( 3 );
      BOOL                    fIncludeTime = hb_parl( 4 );
      BOOL                    fIncludeSeconds = hb_parl( 5 );

      PHB_ITEM                pArcName = hb_itemNew( NULL );
      PHB_ITEM                pFileName = hb_itemNew( NULL );
      PHB_ITEM                pFlags = hb_itemNew( NULL );
      PHB_ITEM                pUnpSize = hb_itemNew( NULL );
      PHB_ITEM                pPackSize = hb_itemNew( NULL );
      PHB_ITEM                pHostOS = hb_itemNew( NULL );
      PHB_ITEM                pFileCRC = hb_itemNew( NULL );
      PHB_ITEM                pUnpVer = hb_itemNew( NULL );
      PHB_ITEM                pMethod = hb_itemNew( NULL );
      PHB_ITEM                pFileAttr = hb_itemNew( NULL );

      if( pPassword != NULL )
      {
         RARSetPassword( hArcData, ( char * ) hb_itemGetCPtr(pPassword) );
      }

      RARSetCallback( hArcData, CallbackProc, 0 );

      HeaderData.CmtBuf = NULL;
      while( (RHCode = RARReadHeaderEx(hArcData, &HeaderData)) == 0 )
      {
         PHB_ITEM pSubarray = hb_itemArrayNew( 11 );
         __int64  PackSize = HeaderData.PackSize + ( ((__int64) HeaderData.PackSizeHigh) << 32 );
         __int64  UnpSize = HeaderData.UnpSize + ( ((__int64) HeaderData.UnpSizeHigh) << 32 );
         char     buff[32];

         hb_arraySet( pSubarray, RAR_ARCNAME, hb_itemPutC(pArcName, HeaderData.ArcName) );
         hb_arraySet( pSubarray, RAR_FILENAME, hb_itemPutC(pFileName, HeaderData.FileName) );
         hb_arraySet( pSubarray, RAR_FLAGS, hb_itemPutNI(pFlags, HeaderData.Flags) );
         hb_arraySet( pSubarray, RAR_PACKSIZE, hb_itemPutND(pPackSize, PackSize) );
         hb_arraySet( pSubarray, RAR_UNPSIZE, hb_itemPutND(pUnpSize, UnpSize) );
         hb_arraySet( pSubarray, RAR_HOSTOS, hb_itemPutNI(pHostOS, HeaderData.HostOS) );
         hb_arraySet( pSubarray, RAR_FILECRC, hb_itemPutNI(pFileCRC, HeaderData.FileCRC) );

         if( fFileTimeAsDate )
         {
            hb_arraySet( pSubarray, RAR_FILETIME, RGetDate(HeaderData.FileTime) );
         }
         else
         {
            hb_arraySet( pSubarray, RAR_FILETIME, RConvertFileTimeToString(HeaderData.FileTime, fIncludeTime, fIncludeSeconds) );
         }

         hb_arraySet( pSubarray, RAR_UNPVER, hb_itemPutNI(pUnpVer, HeaderData.UnpVer) );
         hb_arraySet( pSubarray, RAR_METHOD, hb_itemPutNI(pMethod, HeaderData.Method) );
         hb_arraySet( pSubarray, RAR_FILEATTR, hb_itemPutC(pFileAttr, hb_fsAttrDecode(HeaderData.FileAttr, buff)) );

         hb_arrayAdd( pFileList, pSubarray );
         hb_itemRelease( pSubarray );

         if( (PFCode = RARProcessFile(hArcData, RAR_SKIP, NULL, NULL)) != 0 )
         {
            OutProcessFileError( PFCode, HeaderData.FileName );
            break;
         }
      }

      hb_itemRelease( pArcName );
      hb_itemRelease( pFileName );
      hb_itemRelease( pFlags );
      hb_itemRelease( pUnpSize );
      hb_itemRelease( pPackSize );
      hb_itemRelease( pHostOS );
      hb_itemRelease( pFileCRC );
      hb_itemRelease( pUnpVer );
      hb_itemRelease( pMethod );
      hb_itemRelease( pFileAttr );

      if( RHCode == ERAR_BAD_DATA )
      {
         s_bHeaderBroken = TRUE;
      }
   }
   else
   {
      OpenProcessFileError( OpenArchiveData.OpenResult );
   }

   #ifdef __XHARBOUR__
   hb_itemRelease( hb_itemReturn(pFileList) );
   #else
   hb_itemReturnRelease( pFileList );
   #endif

   RARCloseArchive( hArcData );
}

HB_FUNC( HB_RGETFILENAMESLIST )
{
   PHB_ITEM                      pFileList = hb_itemArrayNew( 0 );
   HANDLE                        hArcData;
   int                           RHCode;
   struct RAROpenArchiveDataEx   OpenArchiveData;

   hb_xmemset( &OpenArchiveData, 0, sizeof(OpenArchiveData) );
   OpenArchiveData.ArcName = ( char * ) hb_parc( 1 );
   OpenArchiveData.CmtBuf = NULL;
   OpenArchiveData.OpenMode = RAR_OM_LIST;

   ClearError();
   hArcData = RAROpenArchiveEx( &OpenArchiveData );
   if( OpenArchiveData.OpenResult == 0 )
   {
      struct RARHeaderDataEx  HeaderData;
      int                     PFCode;
      PHB_ITEM                pPassword = hb_param( 2, HB_IT_STRING );
      PHB_ITEM                pFileName = hb_itemNew( NULL );

      if( pPassword != NULL )
      {
         RARSetPassword( hArcData, ( char * ) hb_itemGetCPtr(pPassword) );
      }

      RARSetCallback( hArcData, CallbackProc, 0 );

      HeaderData.CmtBuf = NULL;
      while( (RHCode = RARReadHeaderEx(hArcData, &HeaderData)) == 0 )
      {
         hb_arrayAdd( pFileList, hb_itemPutC(pFileName, HeaderData.FileName) );

         if( (PFCode = RARProcessFile(hArcData, RAR_SKIP, NULL, NULL)) != 0 )
         {
            OutProcessFileError( PFCode, HeaderData.FileName );
            break;
         }
      }

      hb_itemRelease( pFileName );

      if( RHCode == ERAR_BAD_DATA )
      {
         s_bHeaderBroken = TRUE;
      }
   }
   else
   {
      OpenProcessFileError( OpenArchiveData.OpenResult );
   }

   #ifdef __XHARBOUR__
   hb_itemRelease( hb_itemReturn(pFileList) );
   #else
   hb_itemReturnRelease( pFileList );
   #endif

   RARCloseArchive( hArcData );
}

/*
   Process Files
*/

HB_FUNC( HB_RPROCESSFILES )
{
   BOOL                          fResult = TRUE;
   HANDLE                        hArcData;
   int                           RHCode;
   struct RAROpenArchiveDataEx   OpenArchiveData;

   int                           Operation = hb_parni( 1 );
   PHB_ITEM                      pArray = hb_param( 5, HB_IT_ARRAY );

   hb_xmemset( &OpenArchiveData, 0, sizeof(OpenArchiveData) );
   OpenArchiveData.ArcName = ( char * ) hb_parc( 2 );
   OpenArchiveData.CmtBuf = NULL;
   OpenArchiveData.OpenMode = RAR_OM_EXTRACT;

   ClearError();

   hArcData = RAROpenArchiveEx( &OpenArchiveData );
   if( OpenArchiveData.OpenResult == 0 )
   {
      struct RARHeaderDataEx  HeaderData;
      int                     PFCode;

      PHB_ITEM                pPassword = hb_param( 3, HB_IT_STRING );
      PHB_ITEM                pPath = hb_param( 4, HB_IT_STRING );

      DWORD                   ulLen = hb_itemGetCLen( pPath );
      char                    *pszDst = ( char * ) hb_xgrab( ulLen + 1 );

      hb_xmemset( pszDst, 0, ulLen + 1 );

      // Convert path from ANSI to OEM. Is need ?

      CharToOemBuff( (LPCSTR) hb_itemGetCPtr(pPath), (LPSTR) pszDst, ulLen );

      if( pPassword != NULL )
      {
         RARSetPassword( hArcData, ( char * ) hb_itemGetCPtr(pPassword) );
      }

      RARSetCallback( hArcData, CallbackProc, Operation );

      HeaderData.CmtBuf = NULL;

      while( (RHCode = RARReadHeaderEx(hArcData, &HeaderData)) == 0 )
      {
         PHB_ITEM pValue = hb_itemNew( NULL );
         hb_itemPutC( pValue, HeaderData.FileName );

         if( pArray != NULL )
         {
            if( (PFCode = RARProcessFile(hArcData, (hb_arrayScan(pArray, pValue, NULL, NULL,
            #ifdef __XHARBOUR__
            FALSE,
            #endif
            FALSE) > 0) ? Operation : RAR_SKIP, pszDst, NULL)) != 0 )
            {
               OutProcessFileError( PFCode, HeaderData.FileName );
               fResult = FALSE;
               break;
            }
         }
         else
         {
            if( (PFCode = RARProcessFile(hArcData, Operation, pszDst, NULL)) != 0 )
            {
               OutProcessFileError( PFCode, HeaderData.FileName );
               fResult = FALSE;
               break;
            }
         }

         hb_itemRelease( pValue );
      }

      if( RHCode == ERAR_BAD_DATA )
      {
         fResult = FALSE;
         s_bHeaderBroken = TRUE;
      }

      hb_xfree( pszDst );
   }
   else
   {
      fResult = FALSE;
      OpenProcessFileError( OpenArchiveData.OpenResult );
   }

   RARCloseArchive( hArcData );

   hb_retl( fResult );
}

/*
   Error processing
*/

static void OutProcessFileError( int Error, const char *FileName )
{
   switch( Error )
   {
      case ERAR_UNKNOWN_FORMAT:     strcpy( s_msgOutError, "Unknown archive format" ); break;
      case ERAR_BAD_ARCHIVE:        strcpy( s_msgOutError, "Bad volume" ); break;
      case ERAR_ECREATE:            strcpy( s_msgOutError, "File create error" ); break;
      case ERAR_EOPEN:              strcpy( s_msgOutError, "Volume open error" ); break;
      case ERAR_ECLOSE:             strcpy( s_msgOutError, "File close error" ); break;
      case ERAR_EREAD:              strcpy( s_msgOutError, "Read error" ); break;
      case ERAR_EWRITE:             strcpy( s_msgOutError, "Write error" ); break;
      case ERAR_BAD_DATA:           strcpy( s_msgOutError, "CRC error" ); break;
      case ERAR_UNKNOWN:            strcpy( s_msgOutError, "Unknown error" ); break;
      case ERAR_MISSING_PASSWORD:   strcpy( s_msgOutError, "Password for encrypted file is not specified" ); break;
   }

   s_iOutError = Error;
   strcpy( s_FName, FileName );
}

static void OpenProcessFileError( int Error )
{
   switch( Error )
   {
      case ERAR_NO_MEMORY:       strcpy( s_msgOpenError, "Not enough memory to initialize data structures" ); break;
      case ERAR_BAD_DATA:        strcpy( s_msgOpenError, "Archive header broken" ); break;
      case ERAR_BAD_ARCHIVE:     strcpy( s_msgOpenError, "File is not valid RAR archive" ); break;
      case ERAR_UNKNOWN_FORMAT:  strcpy( s_msgOpenError, "Unknown encryption used for archive headers" ); break;
      case ERAR_EOPEN:           strcpy( s_msgOpenError, "File open error" ); break;
   }

   s_iOpenError = Error;
}

HB_FUNC( HB_RARGETPROCSTATUS )
{
   INT   iResult;

   if( (s_iOpenError == 0) && (s_iOutError == 0) )
   {
      iResult = RAR_ST_SUCCESS;
   }
   else if( (s_iOpenError != 0) && (s_iOutError != 0) )
   {
      iResult = RAR_ST_OPEN_OUT;
   }
   else if( s_iOpenError != 0 )
   {
      iResult = RAR_ST_OPEN;
   }
   else
   {
      iResult = RAR_ST_OUT;
   }

   if( iResult == RAR_ST_SUCCESS )
   {
      iResult = ( s_bHeaderBroken ) ? RAR_ST_HBROKEN : iResult;
   }

   hb_retni( iResult );
}

static void ClearError( void )
{
   s_iOpenError = 0;
   s_msgOpenError[0] = '\0';

   s_iOutError = 0;
   s_msgOutError[0] = '\0';
   s_FName[0] = '\0';

   s_bHeaderBroken = FALSE;
}

HB_FUNC( HB_RARGETERRORINFO )
{
   PHB_ITEM pResult = hb_itemArrayNew( 5 );
   PHB_ITEM tmp;

   tmp = hb_itemPutNI( NULL, s_iOpenError );
   hb_arraySet( pResult, 1, tmp );

   tmp = hb_itemPutC( NULL, s_msgOpenError );
   hb_arraySet( pResult, 2, tmp );

   tmp = hb_itemPutNI( NULL, s_iOutError );
   hb_arraySet( pResult, 3, tmp );

   tmp = hb_itemPutC( NULL, s_msgOutError );
   hb_arraySet( pResult, 4, tmp );

   tmp = hb_itemPutC( NULL, s_FName );
   hb_arraySet( pResult, 5, tmp );

   hb_itemRelease( tmp );

   ClearError();

   #ifdef __XHARBOUR__
   hb_itemRelease( hb_itemReturn(pResult) );
   #else
   hb_itemReturnRelease( pResult );
   #endif
}

/*
   Convert FileTime to date or string
*/

static PHB_ITEM RGetDate( UINT FileTime )
{
   FILETIME    ft;
   SYSTEMTIME  st;
   PHB_ITEM    pResult = hb_itemNew( NULL );

   DosDateTimeToFileTime( HIWORD(FileTime), LOWORD(FileTime), &ft );
   FileTimeToSystemTime( &ft, &st );

   return( hb_itemPutD(pResult, st.wYear, st.wMonth, st.wDay) );
}

static PHB_ITEM RConvertFileTimeToString( UINT FileTime, BOOL includeTime, BOOL includeSeconds )
{
   PHB_ITEM    pResult = hb_itemNew( NULL );
   FILETIME    ft;
   SYSTEMTIME  st;
   char        buff[20];
   ULONG       i;

   DosDateTimeToFileTime( HIWORD(FileTime), LOWORD(FileTime), &ft );
   FileTimeToSystemTime( &ft, &st );

   buff[0] = '\0';
   i = sprintf( buff, "%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay );

   if( includeTime )
   {
      i += sprintf( buff + i, " %02d:%02d", st.wHour, st.wMinute );
      if( includeSeconds )
      {
         i += sprintf( buff + i, ":%02d", st.wSecond );
      }
   }

   return( hb_itemPutCL(pResult, buff, i) );
}

/*
   CALLBACK
*/

static int CALLBACK CallbackProc( UINT msg, LPARAM UserData, LPARAM P1, LPARAM P2 )
{
   if( !pSymbolCallback )
   {
      pSymbolCallback = hb_dynsymSymbol( hb_dynsymGet("HB_RARCALLBACKFUNC") );
   }

   if( pSymbolCallback )
   {
      hb_vmPushSymbol( pSymbolCallback );
      hb_vmPushNil();
      hb_vmPushInteger( msg );
      hb_vmPushLong( UserData );

      switch( msg )
      {
         case UCM_CHANGEVOLUME:
            {
               ULONG ulLen;
               char  buffer[_MAX_PATH+1];

               buffer[0] = '\0';
               ulLen = sprintf( buffer, "%s", ( char * ) P1 );

               hb_vmPushString( ( const char * ) buffer, ulLen );
               hb_vmPushLong( P2 );

               hb_vmDo( 4 );
               if( P2 == RAR_VOL_NOTIFY )
               {
                  return( hb_parni(-1) );
               }
               else if( P2 == RAR_VOL_ASK )
               {
                  if( HB_IS_STRING(hb_param(-1, HB_IT_ANY)) )
                  {
                     hb_strncpy( ( char * ) P1, hb_parc(-1), _MAX_PATH );

                     return( 0 );
                  }
                  else
                  {
                     return( hb_parni(-1) );
                  }
               }
            }

         case UCM_NEEDPASSWORD:
            {
               hb_vmPushLong( P1 );
               hb_vmPushLong( P2 );

               hb_vmDo( 4 );

               hb_strncpy( ( char * ) P1, hb_parc(-1), P2 );

               return( 0 );
            }

         case UCM_PROCESSDATA:
            {
               /* TODO? */

               hb_vmPushPointer( ( void * ) &P1 );
               hb_vmPushLong( P2 );

               hb_vmDo( 4 );
            }
      }
   }

   return( 0 );
}
