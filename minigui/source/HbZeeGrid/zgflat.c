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
#include "zeegrid.h"

#define _GET_HWND( hwnd, i )     HWND hwnd = ( HWND ) ( LONG_PTR ) HB_PARNL( i )

HB_FUNC( ZGM_ADJUSTHEADERS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ADJUSTHEADERS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ALLOCATEROWS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ALLOCATEROWS, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ALTERNATEROWCOLORS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ALTERNATEROWCOLORS, ( WPARAM ) ( BOOL ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_APPENDROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_APPENDROW, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_AUTOHSCROLL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_AUTOHSCROLL, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_AUTOSIZE_ALL_COLUMNS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_AUTOSIZE_ALL_COLUMNS, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_AUTOSIZECOLONEDIT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_AUTOSIZECOLONEDIT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_AUTOSIZECOLUMN ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_AUTOSIZECOLUMN, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_AUTOVSCROLL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_AUTOVSCROLL, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_CLEARMARKONSELECT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_CLEARMARKONSELECT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_COMBOADDSTRING ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_COMBOADDSTRING, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) ); 
} 
 
HB_FUNC( ZGM_COMBOCLEAR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_COMBOCLEAR, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_COMPARETEXT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_COMPARETEXT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_COMPARETEXT2STRING ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_COMPARETEXT2STRING, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parc( 3 ) ); 
} 
 
HB_FUNC( ZGM_COPYCELL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_COPYCELL, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_CURSORFOLLOWMOUSE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_CURSORFOLLOWMOUSE, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_DELETEROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_DELETEROW, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_DIMGRID )
{ 
   _GET_HWND( hwnd, 1 ); 

   int   total_columns = hb_parnidef( 2, 1 );   //grid total columns
   int visible_columns = hb_parnidef( 3, 0 );   //grid visible columns
   int   fixed_columns = hb_parnidef( 4, 0 );   //grid fixed columns
   DWORD columns = MAKELONG( total_columns, visible_columns);
 
   SendMessage( hwnd, ZGM_DIMGRID, ( WPARAM ) columns, ( LPARAM ) fixed_columns ); 
} 
 
HB_FUNC( ZGM_EMPTYGRID ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_EMPTYGRID, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLECOLMOVE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLECOLMOVE, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLECOLRESIZING ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLECOLRESIZING, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLECOLUMNSELECT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLECOLUMNSELECT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLECOPY ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLECOPY, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLECUT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLECUT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLEICONINDENT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLEICONINDENT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( BOOL ) hb_parl ( 3 ) );
} 
 
HB_FUNC( ZGM_ENABLEPASTE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLEPASTE, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLEROWSIZING ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLEROWSIZING, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLESORT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLESORT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETBEDIT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETBEDIT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETBEXPORT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETBEXPORT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETBMERGEROWS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETBMERGEROWS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETBPRINT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETBPRINT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETBROWNUMBERS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETBROWNUMBERS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETBSEARCH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETBSEARCH, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETOOLBARTOGGLE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETOOLBARTOGGLE, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_ENABLETRANSPARENTHIGHLIGHTING ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_ENABLETRANSPARENTHIGHLIGHTING, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_EXPANDROWSONPASTE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_EXPANDROWSONPASTE, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_EXPORT )
{ 
   _GET_HWND( hwnd, 1 ); 
/*
   The LOWORD of this value can specify the delimiter
   The HIWORD of this value can specify special flags for the export operation.

   EF_FILENAMESUPPLIED  - Filename to export to is given in lParam
   EF_DELIMITERSUPPLIED - LOWORD of wParam is the character to use for the delimiter, otherwise use comma.
   EF_SILENT            - Export confirmation message is not displayed.
   EF_NOHEADER          - The data export begins with row 1 and does not export the column header row.
 */
   DWORD dwFlags = ( DWORD ) hb_parnint( 2 );

   SendMessage( hwnd, ZGM_EXPORT, ( WPARAM ) dwFlags, ( LPARAM ) hb_parc( 3 ) );
} 
 
HB_FUNC( ZGM_GETAUTOINCREASESIZE )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETAUTOINCREASESIZE, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 

HB_FUNC( ZGM_GETCELLADVANCE )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLADVANCE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLBCOLOR )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retnint( SendMessage( hwnd, ZGM_GETCELLBCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLDOUBLE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
   double dValue; 

   SendMessage( hwnd, ZGM_GETCELLDOUBLE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &dValue ); 

   hb_retnd( dValue );
} 
 
HB_FUNC( ZGM_GETCELLEDIT ) // [0..4]
{ 
   _GET_HWND( hwnd, 1 ); 
/*
   The  return  value  is  the edit attribute of the specified ZeeGrid cell. 

   A value of 0 means that the cell is not editable, or readonly. 
   A value of 1 means that the cell is editable with a text edit box.
   A value of 2 means that the cell is editable with a droplist combo box.
   A  value  of  3  means that the cell is  a boolean value and is editable by
   double-clicking the cell  to change the boolean state from TRUE to FALSE or
   vice versa.
   A  value  of  4  means  that the cell is editable by the date picker common
   control.
 */
   hb_retni( SendMessage( hwnd, ZGM_GETCELLEDIT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETCELLFCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retnint( SendMessage( hwnd, ZGM_GETCELLFCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLFONT )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLFORMAT ) // [0..4]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLFORMAT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLICON ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLICON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLINDEX ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLINDEX, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ) ); 
} 
 
HB_FUNC( ZGM_GETCELLINT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
   int iValue;

   SendMessage( hwnd, ZGM_GETCELLINT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &iValue ); 

   hb_retni( iValue );
} 
 
HB_FUNC( ZGM_GETCELLJUSTIFY ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLJUSTIFY, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETCELLMARK ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLMARK, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLRESTRICTION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLRESTRICTION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLSALLOCATED ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLSALLOCATED, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLTEXT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
   int iIndex, iLen;

   iIndex = hb_parni( 2 );
   iLen   = SendMessage( hwnd, ZGM_GETCELLTEXTLENGTH, ( WPARAM ) iIndex, ( LPARAM ) 0 );

   if( iLen )
   {
      char * lpszText = ( char * ) hb_xgrabz( iLen + 1 );

      if( lpszText )
      {
         SendMessage( hwnd, ZGM_GETCELLTEXT, ( WPARAM ) iIndex, ( LPARAM ) lpszText ); 
         
         hb_retclen_buffer( lpszText, iLen );
      }
   }
} 
 
HB_FUNC( ZGM_GETCELLTEXTLENGTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLTEXTLENGTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCELLTYPE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCELLTYPE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCOLOFINDEX ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCOLOFINDEX, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retnint( ( DWORD ) SendMessage( hwnd, ZGM_GETCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCOLS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCOLS, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETCOLUMNINDISPLAYPOSITION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCOLUMNINDISPLAYPOSITION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 

HB_FUNC( ZGM_GETCOLUMNORDER )
{ 
   _GET_HWND( hwnd, 1 ); 
   size_t iCols = ( size_t ) SendMessage( hwnd, ZGM_GETCOLS, ( WPARAM ) 0, ( LPARAM ) 0 ); 

   if( iCols )
   {
      int * iArray = ( int * ) hb_xgrabz( iCols * sizeof( int ) );
      size_t i;
      PHB_ITEM pArray = hb_itemArrayNew( ( HB_SIZE ) iCols );

      SendMessage( hwnd, ZGM_GETCOLUMNORDER, ( WPARAM ) iCols, ( LPARAM ) iArray ); 

      for( i = 0; i < iCols; i++ )
         hb_arraySetNI( pArray, ( HB_SIZE ) i, iArray[i] );

      hb_xfree( iArray );

      hb_itemReturnRelease( pArray );
   }
} 
 
HB_FUNC( ZGM_GETCOLWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCOLWIDTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETCRC )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retnint( SendMessage( hwnd, ZGM_GETCRC, ( WPARAM ) 0, ( LPARAM ) hb_parcx( 2 ) ) ); 
} 
 
HB_FUNC( ZGM_GETCURSORCOL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCURSORCOL, ( WPARAM ) 0, ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETCURSORINDEX ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCURSORINDEX, ( WPARAM ) 0, ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETCURSORROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETCURSORROW, ( WPARAM ) 0, ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETDISPLAYPOSITIONOFCOLUMN ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETDISPLAYPOSITIONOFCOLUMN, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETEDITEDCELL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETEDITEDCELL, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETEDITTEXT ) // TODO 
{ 
   _GET_HWND( hwnd, 1 ); 
   char * lpszText = ( char * ) hb_xgrabz( 255 + 1 );

   if( lpszText )
   {
      SendMessage( hwnd,  ZGM_GETEDITTEXT, ( WPARAM ) 255, ( LPARAM ) lpszText ); 
         
      hb_retclen_buffer( lpszText, 255 );
   }
} 

HB_FUNC( ZGM_GETFIXEDCOLUMNS )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETFIXEDCOLUMNS, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETFONT )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   HB_RETNL( ( LONG_PTR ) SendMessage( hwnd, ZGM_GETFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETGRIDWIDTH )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retnint( SendMessage( hwnd, ZGM_GETGRIDWIDTH, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETITEMDATA ) // !!
{ 
   _GET_HWND( hwnd, 1 ); 
   PHB_ITEM pItemData;
   
   pItemData = ( PHB_ITEM ) ( LONG_PTR ) SendMessage( hwnd, ZGM_GETITEMDATA, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 

   hb_itemReturn( pItemData );
} 
 
HB_FUNC( ZGM_GETLASTBUTTONPRESSED )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETLASTBUTTONPRESSED, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETMOUSECOL )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETMOUSECOL, ( WPARAM ) 0, ( LPARAM ) 0 ) );
} 
 
HB_FUNC( ZGM_GETMOUSEROW )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETMOUSEROW, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETRANGESUM )
{ 
   _GET_HWND( hwnd, 1 ); 
   double dValue;
    
   SendMessage( hwnd, ZGM_GETRANGESUM, ( WPARAM ) 0, ( LPARAM ) &dValue ); 

   hb_retnd( dValue );
} 

HB_FUNC( ZGM_GETROWHEIGHT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETROWHEIGHT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETROWNUMBERSWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETROWNUMBERSWIDTH, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETROWOFINDEX ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETROWOFINDEX, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETROWS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETROWS, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETROWSALLOCATED ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETROWSALLOCATED, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETROWSPERPAGE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETROWSPERPAGE, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETSELECTEDCOL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETSELECTEDCOL, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETSELECTEDROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETSELECTEDROW, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETSIZEOFCELL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETSIZEOFCELL, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETSIZEOFGRID ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETSIZEOFGRID, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_GETSORTCOLUMN ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETSORTCOLUMN, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 

HB_FUNC( ZGM_GETTOPROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_GETTOPROW, ( WPARAM ) 0, ( LPARAM ) 0 ) ); 
} 

HB_FUNC( ZGM_GOTOCELL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_GOTOCELL, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( BOOL ) hb_parl( 3 ) ); 
} 
 
HB_FUNC( ZGM_GOTOFIRSTONSEARCH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_GOTOFIRSTONSEARCH, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_GRAYBGONLOSTFOCUS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_GRAYBGONLOSTFOCUS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_HIGHLIGHTCURSORROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_HIGHLIGHTCURSORROW, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_HIGHLIGHTCURSORROWINFIXEDCOLUMNS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_HIGHLIGHTCURSORROWINFIXEDCOLUMNS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_INSERTROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_INSERTROW, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_INTERPRETBOOL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_INTERPRETBOOL, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_INTERPRETDATES ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_INTERPRETDATES, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_INTERPRETNUMERIC ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_INTERPRETNUMERIC, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 

HB_FUNC( ZGM_ISGRIDDIRTY ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retl( SendMessage( hwnd, ZGM_ISGRIDDIRTY, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ) ? HB_TRUE : HB_FALSE ); 
} 
 
HB_FUNC( ZGM_KEEP3DONLOSTFOCUS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_KEEP3DONLOSTFOCUS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_LOADGRID ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_LOADGRID, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) ); 
} 
 
HB_FUNC( ZGM_LOADICON ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_LOADICON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( LONG_PTR ) HB_PARNL( 3 ) ); 
} 
 
HB_FUNC( ZGM_MARKTEXT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_MARKTEXT, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) ); 
} 
 
HB_FUNC( ZGM_MERGEROWS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_MERGEROWS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_PRINT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_PRINT, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_QUERYBUILD ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   hb_retni( SendMessage( hwnd, ZGM_QUERYBUILD, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ) ); 
} 
 
HB_FUNC( ZGM_REFRESHGRID ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_REFRESHGRID, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SAVEGRID ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SAVEGRID, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) ); 
} 
 
HB_FUNC( ZGM_SCROLLDOWN ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SCROLLDOWN, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SCROLLLEFT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SCROLLLEFT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SCROLLRIGHT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SCROLLRIGHT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SCROLLUP ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SCROLLUP, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SEARCHEACHKEYSTROKE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SEARCHEACHKEYSTROKE, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SELECTCOLUMN ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SELECTCOLUMN, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SELECTROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SELECTROW, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETAUTOINCREASESIZE ) //
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETAUTOINCREASESIZE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETBACKGROUNDBITMAP )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETBACKGROUNDBITMAP, ( WPARAM ) 0, ( LPARAM ) ( LONG_PTR ) HB_PARNL( 2 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLADVANCE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLADVANCE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLBCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLBCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 

HB_FUNC( ZGM_SETCELLDOUBLE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
   double dValue =  hb_parnd( 3 );
 
   SendMessage( hwnd, ZGM_SETCELLDOUBLE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &dValue ); 
} 
 
HB_FUNC( ZGM_SETCELLEDIT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLEDIT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLFCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLFCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLFONT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLFORMAT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLFORMAT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLICON ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLICON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLINT ) 
{ 
   _GET_HWND( hwnd, 1 );
   int iValue =  hb_parni( 3 );

   SendMessage( hwnd, ZGM_SETCELLINT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) &iValue ); 
} 
 
HB_FUNC( ZGM_SETCELLJUSTIFY ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLJUSTIFY, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLMARK ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLMARK, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLNUMPRECISION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLNUMPRECISION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLNUMWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLNUMWIDTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLRESTRICTION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLRESTRICTION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLTEXT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLTEXT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parcx( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCELLTYPE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCELLTYPE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLADVANCE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLADVANCE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLBCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLBCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLEDIT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLEDIT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLFCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLFCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLFONT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLFORMAT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLFORMAT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLICON ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLICON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLJUSTIFY ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLJUSTIFY, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLMARK ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLMARK, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLNUMPRECISION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLNUMPRECISION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLNUMWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLNUMWIDTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( DWORD ) hb_parnint( 3 ) );
} 
 
HB_FUNC( ZGM_SETCOLRESTRICTION ) // [0..4]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLRESTRICTION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLTYPE ) // [0..5] 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLRESTRICTION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCOLUMNHEADERHEIGHT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLUMNHEADERHEIGHT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETCOLUMNORDER ) 
{ 
   _GET_HWND( hwnd, 1 ); 
   PHB_ITEM pOrder = hb_param( 2, HB_IT_ARRAY );

   if( NULL != pOrder )
   {
      int i, iLen = ( int ) hb_arrayLen( pOrder );
      int * iArray = ( int * ) hb_xgrab( iLen * sizeof( int ) );

      for( i = 0; i < iLen; i++ )
         iArray[i] = hb_parvni( 2, i + 1 );

      SendMessage( hwnd, ZGM_SETCOLUMNORDER, ( WPARAM ) iLen , ( LPARAM ) iArray ); 

      hb_xfree( iArray );
   }
}
 
HB_FUNC( ZGM_SETCOLWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCOLWIDTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETCURSORCELL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETCURSORCELL, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTADVANCE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTADVANCE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTBCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTBCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTEDIT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTEDIT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTFCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTFCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTFONT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTICON ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTICON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTJUSTIFY ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTJUSTIFY, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTMARK ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTMARK, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTNUMPRECISION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTNUMPRECISION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTNUMWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTNUMWIDTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTRESTRICTION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTRESTRICTION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETDEFAULTTYPE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETDEFAULTTYPE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETEDITTEXT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETEDITTEXT, ( WPARAM ) 0, ( LPARAM ) hb_parc( 2 ) );
} 
 
HB_FUNC( ZGM_SETFONT )
{ 
   _GET_HWND( hwnd, 1 ); 
   HFONT hfont = ( HFONT ) HB_PARNL( 3 );
 
   if( OBJ_FONT == GetObjectType( ( HGDIOBJ ) hfont ) )
      SendMessage( hwnd, ZGM_SETFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hfont );
} 
 
HB_FUNC( ZGM_SETGRIDBGCOLOR ) //[0..127]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETGRIDBGCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 );
} 
 
HB_FUNC( ZGM_SETGRIDLINECOLOR ) // [0..127]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETGRIDLINECOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETITEMDATA ) // !!
{ 
   _GET_HWND( hwnd, 1 ); 
   PHB_ITEM pItem = hb_param( 3, HB_IT_ANY );

   SendMessage( hwnd, ZGM_SETITEMDATA, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) ( LONG_PTR ) pItem ); 
} 
 
HB_FUNC( ZGM_SETLEFTINDENT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETLEFTINDENT, ( WPARAM ) ( DWORD ) hb_parnint( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETLOSTFOCUSHIGHLIGHTCOLOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETLOSTFOCUSHIGHLIGHTCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETMARKTEXT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETMARKTEXT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETPRINTPOINTSIZE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETPRINTPOINTSIZE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETRANGE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETRANGE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 

HB_FUNC( ZGM_SETRIGHTINDENT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETRIGHTINDENT, ( WPARAM ) ( DWORD ) hb_parnint( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETROWADVANCE )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWADVANCE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWBCOLOR ) // [0..127]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWBCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWEDIT ) // [0..4]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWEDIT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWFCOLOR ) // [0..127] 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWFCOLOR, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWFONT ) // [0..127]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWHEIGHT )
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWHEIGHT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWICON ) // [0..127]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWICON, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWJUSTIFY ) // [0..8]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWJUSTIFY, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWMARK ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWMARK, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWNUMBERFONT ) // [0..127]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWNUMBERFONT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETROWNUMBERSWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWNUMBERSWIDTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETROWNUMPRECISION ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWNUMPRECISION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWNUMWIDTH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWNUMWIDTH, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWRESTRICTION ) //[0..4]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWRESTRICTION, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SETROWTYPE ) // [0..5]
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETROWTYPE, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 

HB_FUNC( ZGM_SETTITLEHEIGHT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETTITLEHEIGHT, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SETTOPROW ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SETTOPROW, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWCOPYMENU ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWCOPYMENU, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWCURSOR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWCURSOR, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWCURSORONLOSTFOCUS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWCURSORONLOSTFOCUS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWEDIT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWEDIT, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWGRIDLINES ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWGRIDLINES, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWHSCROLL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWHSCROLL, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWROWNUMBERS ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWROWNUMBERS, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWSEARCH ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWSEARCH, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWTITLE ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWTITLE, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWTOOLBAR ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWTOOLBAR, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHOWVSCROLL ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHOWVSCROLL, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SHRINKTOFIT ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SHRINKTOFIT, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_SORTCOLUMNASC ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SORTCOLUMNASC, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 
HB_FUNC( ZGM_SORTCOLUMNDESC ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SORTCOLUMNDESC, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 

 
HB_FUNC( ZGM_SORTSECONDARY ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SORTSECONDARY, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
} 

/* 
HB_FUNC( ZGM_SPANCOLUMN ) // TODO 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_SPANCOLUMN, ( WPARAM ) 0, ( LPARAM ) 0 ); 
   SendMessage( hwnd, ZGM_SPANCOLUMN, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) 0 ); 
   SendMessage( hwnd, ZGM_SPANCOLUMN, ( WPARAM ) ( BOOL ) hb_parl ( 2 ), ( LPARAM ) 0 ); 
   SendMessage( hwnd, ZGM_SPANCOLUMN, ( WPARAM ) hb_parni( 2 ), ( LPARAM ) hb_parni( 3 ) ); 
} 
 */
 
HB_FUNC( ZGM_STOPWATCH_START ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_STOPWATCH_START, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_STOPWATCH_STOP ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_STOPWATCH_STOP, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
 
HB_FUNC( ZGM_UNLOCK ) 
{ 
   _GET_HWND( hwnd, 1 ); 
 
   SendMessage( hwnd, ZGM_UNLOCK, ( WPARAM ) 0, ( LPARAM ) 0 ); 
} 
