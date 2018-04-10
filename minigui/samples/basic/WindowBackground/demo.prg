/*
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Make Your Project Look Great!
*/

#include "minigui.ch"

#define COLOR_WINDOW	5

PROCEDURE Main()

   DEFINE WINDOW Form_Main ;
      CLIENTAREA 640, 480 ;
      TITLE 'How to set a Window background' ;
      BKBRUSH iif(IsThemed(), nRGB2Arr( GetSysColor( COLOR_WINDOW ) ), ) ;
      MAIN

      DEFINE MAIN MENU

         DEFINE POPUP "&Create BKBrush"

            POPUP "&SOLID"
               ITEM '&RED' ACTION SetBKBrush( 1 )
               ITEM '&GREEN' ACTION SetBKBrush( 2 )
               ITEM '&BLUE' ACTION SetBKBrush( 3 )
               ITEM 'LightGoldenrod&3' ACTION SetBKBrush( 13 )
            END POPUP

            POPUP "&HATCHED"
               ITEM '&VERTICAL' ACTION SetBKBrush( 4 )
               ITEM '&HORIZONTAL' ACTION SetBKBrush( 5 )
               ITEM '&FDIAGONAL' ACTION SetBKBrush( 6 )
               ITEM '&BDIAGONAL' ACTION SetBKBrush( 7 )
               ITEM '&CROSS' ACTION SetBKBrush( 8 )
               ITEM '&DIAGCROS' ACTION SetBKBrush( 9 )
            END POPUP

            POPUP "&PATTERN"
               ITEM '&HEARTS' ACTION SetBKBrush( 10 )
               ITEM '&WALL' ACTION SetBKBrush( 11 )
               ITEM 'S&TEEL' ACTION SetBKBrush( 12 )
               ITEM '&SMILES' ACTION SetBKBrush( 14 )
            END POPUP

            SEPARATOR

            MENUITEM "&Exit" ACTION Form_Main.Release

         END POPUP

      END MENU

      ThisWindow.Height := ( ThisWindow.Height ) + GetMenuBarHeight()

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

RETURN


STATIC PROCEDURE SetBKBrush( nBrushStyle )

   LOCAL hBrush

   SWITCH nBrushStyle
   CASE  1 ; ADD BKBRUSH hBrush SOLID COLOR RED   TO FORM Form_Main 
      EXIT

   CASE  2 ; ADD BKBRUSH hBrush SOLID COLOR GREEN TO Form_Main
      EXIT

   CASE  3 ; ADD BKBRUSH hBrush SOLID COLOR BLUE TO Form_Main
      EXIT

   CASE 13 ; ADD BKBRUSH hBrush SOLID COLOR { 205, 190, 112 } TO Form_Main
      EXIT

   CASE  4 ; ADD BKBRUSH hBrush HATCHED HATCHSTYLE HS_VERTICAL COLOR { 0, 200, 0 } TO Form_Main
      EXIT

   CASE  5 ; ADD BKBRUSH hBrush HATCHED HS_HORIZONTAL TO Form_Main
      EXIT

   CASE  6 ; ADD BKBRUSH hBrush HATCHED HS_FDIAGONAL TO Form_Main
      EXIT

   CASE  7 ; ADD BKBRUSH hBrush HATCHED HS_BDIAGONAL TO Form_Main
      EXIT

   CASE  8 ; ADD BKBRUSH hBrush HATCHED HS_CROSS TO Form_Main
      EXIT

   CASE  9 ; ADD BKBRUSH hBrush HATCHED HS_DIAGCROSS TO Form_Main
      EXIT

   CASE 10 ; ADD BKBRUSH hBrush PATTERN PICTURE hearts.bmp TO Form_Main
      EXIT

   CASE 11 ; ADD BKBRUSH hBrush PATTERN PICTURE WALL TO Form_Main
      EXIT

   CASE 12 ; ADD BKBRUSH hBrush PATTERN PICTURE WALL2 TO Form_Main
      EXIT

   CASE 14 ; ADD BKBRUSH hBrush PATTERN PICTURE smiles.gif TO Form_Main

   END SWITCH

   ERASE WINDOW Form_Main

RETURN
