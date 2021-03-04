/*
 * dbInsert() function
 *
 * Copyright 2005 Pavel Tsarenko <tpe2@mail.ru>
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
 * along with this program; see the file LICENSE.txt.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA (or visit https://www.gnu.org/licenses/).
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

#include <windows.h>
#include "hbapi.h"
#include "hbapirdd.h"
#include "hbrdddbf.h"
#include "hbset.h"

HB_FUNC( DBINSERT )
{
   DBFAREAP pArea = ( DBFAREAP ) hb_rddGetCurrentWorkAreaPointer();
   BOOL     bOk   = TRUE;

   if( pArea && ! pArea->fReadonly && ! pArea->fShared )
   {
      ULONG ulRec, ulCount = HB_ISNUM( 2 ) ? hb_parnl( 2 ) : 1;
      HB_FHANDLE hFile = hb_fileHandle( pArea->pDataFile );

      if( HB_ISNUM( 1 ) )
         ulRec = hb_parnl( 1 );
      else
         SELF_RECNO( ( AREAP ) pArea, &ulRec );

      if( ulRec == 0 || ulRec > pArea->ulRecCount )
         bOk = FALSE;

      if( bOk && SELF_GOCOLD( ( AREAP ) pArea ) != HB_SUCCESS )
         bOk = FALSE;
      else
      {
         ULONG ulIndex;

         for( ulIndex = 0; ulIndex < ulCount; ulIndex++ )
         {
            if( bOk && SELF_APPEND( ( AREAP ) pArea, TRUE ) != HB_SUCCESS )
               bOk = FALSE;
         }

         if( hb_setGetHardCommit() ) 
            SELF_FLUSH( ( AREAP ) pArea );

         if( bOk )
         {
            ULONG  ulLen  = ( pArea->ulRecCount - ulRec ) * pArea->uiRecordLen;
            ULONG  ulLen1 = ulCount * pArea->uiRecordLen;
            char * pData  = hb_xgrab( ulLen + 1 );
            char * pZero  = hb_xgrab( ulLen1 + 1 );

            hb_fsSeekLarge( hFile, ( HB_FOFFSET ) pArea->uiHeaderLen +
                            ( HB_FOFFSET ) pArea->uiRecordLen *
                            ( HB_FOFFSET ) ( ulRec - 1 ), FS_SET );
            hb_fsReadLarge( hFile, pData, ulLen );

            hb_fsSeekLarge( hFile, ( HB_FOFFSET ) pArea->uiHeaderLen +
                            ( HB_FOFFSET ) pArea->uiRecordLen *
                            ( HB_FOFFSET ) ( pArea->ulRecCount - ulCount ), FS_SET );
            hb_fsReadLarge( hFile, pZero, ulLen1 );

            hb_fsSeekLarge( hFile, ( HB_FOFFSET ) pArea->uiHeaderLen +
                            ( HB_FOFFSET ) pArea->uiRecordLen *
                            ( HB_FOFFSET ) ( ulRec - 1 ), FS_SET );
            hb_fsWriteLarge( hFile, pZero, ulLen1 );

            hb_fsSeekLarge( hFile, ( HB_FOFFSET ) pArea->uiHeaderLen +
                            ( HB_FOFFSET ) pArea->uiRecordLen *
                            ( HB_FOFFSET ) ( ulRec + ulCount - 1 ), FS_SET );

            hb_fsWriteLarge( hFile, pData, ulLen );

            hb_xfree( pData );
            hb_xfree( pZero );
         }
      }

      if( bOk && SELF_GOTO( ( AREAP ) pArea, ulRec ) != HB_SUCCESS )
         bOk = FALSE;
   }

   hb_retl( bOk );
}
