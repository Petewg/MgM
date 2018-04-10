/*
 * A simple example of some of the features of the hbLpng/MiniGUI library.
 *
 * Copyright 2017 (C) P.Chornyj <myorg63@mail.ru>
 */

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"

MEMVAR hPng1, hPng2, hPng3, hPng4

//////////////////////////////////////////////////////////

PROCEDURE main()

   PRIVATE hPng1, hPng2, hPng3, hPng4

   SET EVENTS FUNCTION TO App_OnEvents

   hPng1 := hmg_LoadPng( 'res\image1.png' )
   hPng2 := hmg_LoadPng( 'res\image2.png' )
   hPng3 := hmg_LoadPng( 'IMAGE2', 'PNG' )
   hPng4 := hmg_LoadPng( 'IMAGE1', 'PNG' )

   DEFINE WINDOW Form_1 ;
      BACKCOLOR WHITE ;
      CLIENTAREA 400, 220 ;
      TITLE 'PNG with Alpha Channel sample (Lpng)' ;
      WINDOWTYPE MAIN ;
      NOMAXIMIZE ;
      NOSIZE ;
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

FUNCTION App_OnEvents( hWnd, nMsg, wParam, lParam )

   LOCAL result

   IF nMsg == WM_PAINT
      App_OnPaint( hWnd, hPng1, hPng2, hPng3, hPng4 )

      result := DefWindowProc( hWnd, nMsg, wParam, lParam )
   ELSE
      result := Events( hWnd, nMsg, wParam, lParam )
   ENDIF

   RETURN result

//////////////////////////////////////////////////////////

STATIC PROCEDURE ChangeBkClr( aBackColor )

   Form_1.BackColor := aBackColor

   InvalidateRect( Form_1.Handle, 1 )

   RETURN

//////////////////////////////////////////////////////////

STATIC FUNCTION hmg_LoadPng( resname, restype )

   RETURN c_GetResPicture( resname, iif( restype == NIl, NIL, restype ) )

//////////////////////////////////////////////////////////

#pragma BEGINDUMP

#include "mgdefs.h"

HB_FUNC( APP_ONPAINT )
{
   HWND hwnd = ( HWND ) ( LONG_PTR ) HB_PARNL( 1 );

   PAINTSTRUCT ps;
   HDC hdc;
   HDC hdc_mem;

   if( IsWindow( hwnd ) )
   {      
      hdc     = BeginPaint( hwnd, &ps );
      hdc_mem = CreateCompatibleDC( hdc );
      {
         HBITMAP png1 = ( HBITMAP ) ( LONG_PTR ) HB_PARNL( 2 );
         HBITMAP png2 = ( HBITMAP ) ( LONG_PTR ) HB_PARNL( 3 );
         HBITMAP png3 = ( HBITMAP ) ( LONG_PTR ) HB_PARNL( 4 );
         HBITMAP png4 = ( HBITMAP ) ( LONG_PTR ) HB_PARNL( 5 );

         BLENDFUNCTION bf = { AC_SRC_OVER, 0, 0xFF, AC_SRC_ALPHA };

         SelectObject( hdc_mem, png1 );
         AlphaBlend( hdc, 0, 0       , 200, 100, hdc_mem, 0, 0, 200, 100, bf );

         SelectObject( hdc_mem, png2 );
         AlphaBlend( hdc, 0, 100 + 10, 200, 100, hdc_mem, 0, 0, 200, 100, bf );

         SelectObject( hdc_mem, png3 );
         AlphaBlend( hdc, 200, 0     , 200, 100, hdc_mem, 0, 0, 200, 100, bf );

         SelectObject( hdc_mem, png4 );
         AlphaBlend( hdc, 200, 100+10, 200, 100, hdc_mem, 0, 0, 200, 100, bf );
      }
      DeleteDC( hdc_mem );
      EndPaint( hwnd, &ps );
   }
}

#pragma ENDDUMP
