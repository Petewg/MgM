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

#define _GET_HWND( hwnd, i )     HWND hwnd = ( HWND ) ( LONG_PTR ) HB_PARNL( i )

HB_FUNC( ZGM_ISDATEVALID )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = 0;                   //not used; must be 0
      lParam = (LPARAM) lpszString; //pointer to string representation of a date 

      Returns the julian date
    */
   hb_retni( SendMessage( hwnd, ZGM_ISDATEVALID, ( WPARAM ) 0, ( LPARAM ) hb_parc( 3 ) ) );
} 

HB_FUNC( ZGM_GETCDATE )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = (WPARAM) (int) iJulianDate; // julian date
      lParam = (LPARAM) lpszString;        // ptr to string to return converted julian date as text in 'YYYY/MM/DD' fmt.
    */ 
   char szDate[11]; 

   if( TRUE == ( BOOL ) SendMessage( hwnd, ZGM_GETCDATE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) szDate ) )
      hb_retc( szDate );
   else
      hb_retc_null(); 
} 

HB_FUNC( ZGM_GETJDATE )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = 0;                   // not used; must be 0
      lParam = (LPARAM) lpszString; // ptr to string representation of a date 

      Returns the julian date
    */
   hb_retni( SendMessage( hwnd, ZGM_GETJDATE, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) ) ); 
} 

HB_FUNC( ZGM_SETCELLCDATE )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = (WPARAM)(int) iCellIndex; // Cell index
      lParam = (LPARAM) lpszString;      // pointer to string representation of a date

      Returns the julian date
    */
   hb_retni( SendMessage( hwnd, ZGM_SETCELLCDATE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parc( 3 ) ) );
} 
 
HB_FUNC( ZGM_SETCELLJDATE )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = (WPARAM)(int) iCellIndex;  // Cell index
      lParam = (LPARAM)(int) iJulianDate; // julian date 

      If the julian date specified in lParam is a valid julian date, the message returns TRUE, otherwise FALSE.
    */
   hb_parl( ( BOOL ) SendMessage( hwnd, ZGM_SETCELLJDATE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ) ? HB_TRUE : HB_FALSE ); 
} 

HB_FUNC( ZGM_GETDOW )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = (WPARAM) (int) iJulianDate; // julian date
      lParam = 0;                          // not used; must be 0 
    */
   hb_retni( SendMessage( hwnd, ZGM_GETDOW, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETDOWLONG )
{ 
   _GET_HWND( hwnd, 1 ); 
   int iDayOfWeek = hb_parni( 2 );

   if( iDayOfWeek >= 0 && iDayOfWeek <= 6 )
   {
      char szDowLong[11];

      SendMessage( hwnd, ZGM_GETDOWLONG, ( WPARAM ) iDayOfWeek, ( LPARAM ) szDowLong ); 

      hb_retc( szDowLong );
   }
   else
      hb_retc_null(); 
} 
 
HB_FUNC( ZGM_GETDOWSHORT )
{ 
   _GET_HWND( hwnd, 1 ); 
   int iDayOfWeek = hb_parni( 2 );

   if( iDayOfWeek >= 0 && iDayOfWeek <= 6 )
   {
      char szDowShort[4];

      SendMessage( hwnd, ZGM_GETDOWSHORT, ( WPARAM ) iDayOfWeek, ( LPARAM ) szDowShort ); 

      hb_retc( szDowShort );
   }
   else
      hb_retc_null(); 
} 

HB_FUNC( ZGM_GETDOY )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = 0;                         // not used; must be 0
      lParam = (LPARAM)(int) iJulianDate; // julian date 
    */
   hb_retni( SendMessage( hwnd, ZGM_GETDOY, ( WPARAM ) 0, ( LPARAM ) hb_parni( 2 ) ) ); 
} 
 
HB_FUNC( ZGM_GETTODAY )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = 0;                      //not used; must be 0
      lParam = (LPARAM) lpszString;    //pointer to string to return today's date as text in 'YYYY/MM/DD' format 

      Returns the julian date of the current date.
    */
   char szToday[11];

   hb_retni( SendMessage( hwnd, ZGM_GETTODAY, ( WPARAM ) 0, ( LPARAM ) szToday ) ); 
   hb_storc( szToday, 2 );
} 

HB_FUNC( ZGM_GETWOY )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = 0;                         // not used; must be 0
      lParam = (LPARAM)(int) iJulianDate; // julian date 
    */
   hb_retni( SendMessage( hwnd, ZGM_GETWOY, ( WPARAM ) 0, ( LPARAM ) hb_parni( 2 ) ) ); 
} 

HB_FUNC( ZGM_GETREGDATEDAY )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETREGDATEDAY, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETREGDATEDOW )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETREGDATEDOW, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETREGDATEDOY )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETREGDATEDOY, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETREGDATEFORMATTED )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = (WPARAM) (int) iDateFormat; //date format number
      lParam = (LPARAM) lpszString;        //pointer to string to return the text representation of a date 
    */
   char szFormatted[19];

   if( TRUE == SendMessage( hwnd, ZGM_GETREGDATEFORMATTED, ( WPARAM ) 0, ( LPARAM ) szFormatted ) )
      hb_retc( szFormatted ); 
   else
      hb_retc_null(); 
} 
 
HB_FUNC( ZGM_GETREGDATEMONTH )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETREGDATEMONTH, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETREGDATEWOY )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETREGDATEWOY, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 

HB_FUNC( ZGM_GETREGDATEYEAR )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETREGDATEYEAR, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 

HB_FUNC( ZGM_SETREGCDATE )
{ 
   _GET_HWND( hwnd, 1 ); 
   /* 
      wParam = 0;                   // not used; must be 0
      lParam = (LPARAM) lpszString; // pointer to string representation of a date

      Returns the julian date
    */
   hb_retni( SendMessage( hwnd, ZGM_SETREGCDATE, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) ) ); 
} 
 
HB_FUNC( ZGM_SETREGJDATE )
{ 
   _GET_HWND( hwnd, 1 ); 
   /*
      wParam = 0;                         // not used; must be 0
      lParam = (LPARAM)(int) iJulianDate; // julian date 

      Returns the julian date
    */
   SendMessage( hwnd, ZGM_SETREGJDATE, ( WPARAM ) 0, ( LPARAM ) hb_parni( 2 ) ); 
} 
