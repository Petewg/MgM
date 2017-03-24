/*
 * A simple example of some of the features of the MiniGUI library.
 *
 * Copyright 2017 (C) P.Chornyj <myorg63@mail.ru>
 */

ANNOUNCE RDDSYS

#include "minigui.ch"

MEMVAR hPng1, hPng2, hPng3, hPng4

//////////////////////////////////////////////////////////

PROCEDURE main()

   PRIVATE hPng1, hPng2, hPng3, hPng4

   hPng1 := c_GetResPicture( 'res\image1.png' )
   hPng2 := c_GetResPicture( 'res\image2.png' )
   hPng3 := c_GetResPicture( 'IMAGE2', 'PNG' )
   hPng4 := c_GetResPicture( 'IMAGE1', 'PNG' )

   DEFINE WINDOW Form_1 ;
      BACKCOLOR BLACK ;
      CLIENTAREA 400, 220 ;
      TITLE 'PNG with Alpha Channel sample' ;
      WINDOWTYPE MAIN ;
      NOMAXIMIZE ;
      NOSIZE ;
      ON PAINT App_OnPaint( This.Handle ) ;
      ON RELEASE ;
      ( ;
         DeleteObject( hPng1 ), DeleteObject( hPng2 ), ;
         DeleteObject( hPng3 ), DeleteObject( hPng4 ) ;
      ) ;

      ON KEY ESCAPE ACTION ThisWindow.Release

      DEFINE MAIN MENU
         POPUP 'BkColor'
            ITEM 'YELLOW'     Action ChangeBkClr( YELLOW )  
            ITEM 'PINK'       Action ChangeBkClr( PINK   )  
            ITEM 'RED'        Action ChangeBkClr( RED    )  
            ITEM 'FUCHSIA'    Action ChangeBkClr( FUCHSIA)  
            ITEM 'BROWN'      Action ChangeBkClr( BROWN  )  
            ITEM 'ORANGE'     Action ChangeBkClr( ORANGE )  
            ITEM 'LGREEN'     Action ChangeBkClr( LGREEN )  
            ITEM 'PURPLE'     Action ChangeBkClr( PURPLE )  
            ITEM 'BLACK'      Action ChangeBkClr( BLACK  )  
            ITEM 'WHITE'      Action ChangeBkClr( WHITE  )  
            ITEM 'GRAY'       Action ChangeBkClr( GRAY   )  
            ITEM 'BLUE'       Action ChangeBkClr( BLUE   )  
            ITEM 'Custom CLR' Action ChangeBkClr( { 127,255,127 } )  

            SEPARATOR                       
            ITEM 'Exit'       ACTION Form_1.Release
         END POPUP
      END MENU
  
   END WINDOW

   CENTER   WINDOW Form_1
   ACTIVATE WINDOW Form_1

   RETURN

//////////////////////////////////////////////////////////

FUNCTION App_OnPaint( hWnd )

   LOCAL hdc, pps
   LOCAL hdc_mem

   hdc     := BeginPaint( hWnd, @pps )
   hdc_mem := CreateCompatibleDC( hdc )

   SelectObject( hdc_mem, hPng1 )
   AlphaBlend( hdc, 0, 0       , 200, 100, hdc_mem, 0, 0, 200, 100, 255, 1 )

   SelectObject( hdc_mem, hPng2 )
   AlphaBlend( hdc, 0, 100 + 10, 200, 100, hdc_mem, 0, 0, 200, 100, 255, 1 )

   SelectObject( hdc_mem, hPng3 )
   AlphaBlend( hdc, 200, 0     , 200, 100, hdc_mem, 0, 0, 200, 100, 255, 1 )

   SelectObject( hdc_mem, hPng4 )
   AlphaBlend( hdc, 200, 100+10, 200, 100, hdc_mem, 0, 0, 200, 100, 255, 1 )

   DeleteDC( hdc_mem )
   EndPaint( hWnd, pps )

   RETURN 0

//////////////////////////////////////////////////////////

STATIC PROCEDURE ChangeBkClr( aBackColor )

   Form_1.BackColor := aBackColor

   InvalidateRect( Form_1.Handle, 1 )

   RETURN

//////////////////////////////////////////////////////////

#pragma BEGINDUMP

#include "mgdefs.h"

HB_FUNC( CREATECOMPATIBLEDC )
{
   HDC hdc = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );
   HDC hdc_mem;

   if( GetObjectType( hdc ) == OBJ_DC || GetObjectType( hdc ) == OBJ_MEMDC )
      hdc_mem = CreateCompatibleDC( hdc );
   else
      hdc_mem = CreateCompatibleDC( NULL );

   HB_RETNL( ( LONG_PTR ) hdc_mem );
}

HB_FUNC( DELETEDC )
{
   HDC hdc = ( HDC ) ( LONG_PTR ) HB_PARNL( 1 );

   HB_RETNL( ( LONG_PTR ) DeleteDC( hdc ) );
}

#pragma ENDDUMP
