/*
 * This file is a part of HbZeeGrid library.
 * Copyright 2017 (C) P.Chornyj <myorg63@mail.ru>
 *
 * Based on the Original Work by David Hillard
 *
 * //////////////////////////////////////////////////////
 * //////////////////////////////////////////////////////
 * //////                                        ////////
 * //////                                        ////////
 * //////     ZeeGrid Copyright(C) 2002-2015     ////////
 * //////                 by                     ////////
 * //////            David Hillard               ////////
 * //////                                        ////////
 * //////                                        ////////
 * //////        email: david@kycsepp.com        ////////
 * //////                                        ////////
 * //////////////////////////////////////////////////////
 * //////////////////////////////////////////////////////
 */

#include "mgdefs.h"
#include "hbapiitm.h"
#include "hbdate.h"
#include "zeegrid.h"

#define _DEFAULT_COLS  10
#define _DEFAULT_ROWS  10

#define _GET_HWND( hwnd, i )     HWND hwnd = ( HWND ) ( LONG_PTR ) HB_PARNL( i )

extern BOOL Array2Rect( PHB_ITEM aPoint, RECT * rect );

HINSTANCE GetInstance( void );
/* ////////////////////////////////////////////////////// */
HB_FUNC( ZG_SETCELLDATE )
{ 
   _GET_HWND( hwnd, 1 ); 

   if( HB_ISDATETIME( 3 ) )
   {
      char szDate[ 9 ];
      char szFormatted[ 11 ];

      hb_dateFormat( hb_pardsbuff( szDate, 3 ), szFormatted, "mm/dd/yyyy" );

      hb_retni( SendMessage( hwnd, ZGM_SETCELLCDATE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) szFormatted ) );
   }
} 

HB_FUNC( ZG_LOADICON2 )
{
   _GET_HWND( hwnd, 1 ); 
   HICON hicon = NULL;
 
   if( HB_ISNUM( 3 ) )
   {
      int ident = hb_parni( 3 );

      hicon = LoadIcon( GetInstance(), MAKEINTRESOURCE( ident ) );
      if( NULL == hicon )
         hicon = LoadIcon( NULL, MAKEINTRESOURCE( ident ) );
   }
   else if( HB_ISCHAR( 3 ) )
      hicon = LoadIcon( GetInstance(), hb_parc( 3 ) );

   if( NULL != hicon )
      SendMessage( hwnd, ZGM_LOADICON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hicon );
} 
/* ////////////////////////////////////////////////////// */
HB_FUNC( ZG_LOADDLL )
{
   HMODULE hGridMod = LoadLibrary( "zeegrid.dll" );
   
   if( ! hGridMod )
      MessageBox( NULL, "Unable to load ZeeGrid.DLL", "Error", MB_OK );

   HB_RETNL( ( LONG_PTR ) hGridMod );
}

HB_FUNC( ZG_INITGRID )
{
   _GET_HWND( hwndP, 1 ); 
   HB_BOOL bResult = HB_FALSE;
 
   if( IsWindow( hwndP ) )
   {
      HWND hGrid;      
      PHB_ITEM block = hb_param( 9, HB_IT_BLOCK );
      RECT rect;

      GetClientRect( hwndP, &rect );

      hGrid = CreateWindow( "ZeeGrid",
         hb_parcx( 4 ),         // title
         WS_CHILD | WS_VISIBLE | WS_TABSTOP,
         hb_parnidef( 5, 0 ),   // left
         hb_parnidef( 6, 0 ),   // top
         hb_parnidef( 7, rect.right ),
         hb_parnidef( 8, rect.bottom * 0.75 ),
         hwndP,                 // hwnd parent
         (HMENU) hb_parni( 3 ), // ID
         GetInstance(),
         NULL );

      if( hGrid )
      {
         bResult = HB_TRUE;

         if( block )
         {
            PHB_ITEM hwnd = hb_itemPutNInt( NULL, ( LONG_PTR ) hGrid );

            hb_evalBlock1( block, hwnd );
            hb_itemRelease( hwnd );
         }
         else
         {
            int j;

            SendMessage( hGrid, ZGM_DIMGRID, ( WPARAM ) MAKELONG( _DEFAULT_COLS, 0 ), ( LPARAM ) 0 );

            for( j = 1; j <= _DEFAULT_ROWS; j++ )
               SendMessage( hGrid, ZGM_APPENDROW, ( WPARAM ) 0, ( LPARAM ) 0 );
         }
         HB_STORNL( ( LONG_PTR ) hGrid, 2 );
      }
   }
   hb_retl( bResult );
}

HB_FUNC( ZG_RESIZE )
{
   _GET_HWND( hwndP, 1 );
   _GET_HWND( hGrid, 2 );

   if( IsWindow( hwndP ) )
   {
      RECT rect;
      PHB_ITEM pRect = hb_itemParam( 3 );

      if( ! Array2Rect( pRect, &rect ) )
      {
         GetClientRect( hwndP, &rect );
         rect.bottom *= 0.75;
      }
      hb_itemRelease( pRect );

      MoveWindow( hGrid, 0, 0, rect.right, rect.bottom, TRUE );
   }
}
