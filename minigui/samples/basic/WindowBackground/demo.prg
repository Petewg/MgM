/*
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * Make Your Project Look Great!
*/

#include "hmg.ch"

Function Main()

   DEFINE WINDOW Form_Main ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 ;
      TITLE 'Window Background Demo' ;
      MAIN 

      DEFINE MAIN MENU

         DEFINE POPUP "&Create Window Background Brush"

            POPUP "&SOLID"
               ITEM '&RED' ACTION SetBrush( 1 )
               ITEM '&GREEN' ACTION SetBrush( 2 )
               ITEM '&BLUE' ACTION SetBrush( 3 )
            END POPUP

            POPUP "&HATCHED"
               ITEM '&VERTICAL' ACTION SetBrush( 4 )
               ITEM '&HORIZONTAL' ACTION SetBrush( 5 )
               ITEM '&FDIAGONAL' ACTION SetBrush( 6 )
               ITEM '&BDIAGONAL' ACTION SetBrush( 7 )
               ITEM '&CROSS' ACTION SetBrush( 8 )
               ITEM '&DIAGCROS' ACTION SetBrush( 9 )
                           END POPUP

            POPUP "&PATTERN"
               ITEM '&HEARTS' ACTION SetBrush( 10 )
               ITEM '&WALL' ACTION SetBrush( 11 )
               ITEM 'S&TEEL' ACTION SetBrush( 12 )
               ITEM 'S&QUARE' ACTION SetBrush( 13 )
               ITEM '&SMILES' ACTION SetBrush( 14 )
            END POPUP

            SEPARATOR

            MENUITEM "&Exit" ACTION Form_Main.Release

         END POPUP

      END MENU

   END WINDOW

   CENTER WINDOW Form_Main

   ACTIVATE WINDOW Form_Main

Return Nil


/*
*/
Function SetBrush( style )
   Local newBrush 
   
   HB_SYMBOL_UNUSED( newBrush )

  SWITCH style
   CASE 1   
   DEFINE BKGBRUSH newBrush SOLID IN WINDOW Form_Main COLOR RED
   EXIT
      
   CASE 2
   DEFINE BKGBRUSH newBrush SOLID IN Form_Main COLOR GREEN
   EXIT
   
   CASE 3
   DEFINE BKGBRUSH newBrush SOLID IN Form_Main COLOR BLUE
   EXIT

   CASE 4
   DEFINE BKGBRUSH newBrush HATCHED IN WINDOW Form_Main ;
      HATCHSTYLE HS_VERTICAL COLOR {0,200,0}
   EXIT
      
   CASE 5
   DEFINE BKGBRUSH newBrush HATCHED IN Form_Main HS_HORIZONTAL 
   EXIT
      
   CASE 6
   DEFINE BKGBRUSH newBrush HATCHED IN Form_Main HS_FDIAGONAL
   EXIT

   CASE 7
   DEFINE BKGBRUSH newBrush HATCHED IN Form_Main HS_BDIAGONAL
   EXIT

   CASE 8
   DEFINE BKGBRUSH newBrush HATCHED IN Form_Main HS_CROSS
   EXIT

   CASE 9
   DEFINE BKGBRUSH newBrush HATCHED IN Form_Main HS_DIAGCROSS
   EXIT

   CASE 10
   DEFINE BKGBRUSH newBrush PATTERN IN WINDOW Form_Main BITMAP hearts.bmp
   EXIT

   CASE 11
   DEFINE BKGBRUSH newBrush PATTERN IN Form_Main BITMAP WALL
   EXIT

   CASE 12
   DEFINE BKGBRUSH newBrush PATTERN IN Form_Main BITMAP WALL2
   EXIT

   CASE 13
   DEFINE BKGBRUSH newBrush PATTERN IN Form_Main BITMAP WALL3
   EXIT

   CASE 14
   DEFINE BKGBRUSH newBrush PATTERN IN Form_Main PICTURE smiles.jpg

  END SWITCH

  ERASE WINDOW Form_Main
 
Return Nil
