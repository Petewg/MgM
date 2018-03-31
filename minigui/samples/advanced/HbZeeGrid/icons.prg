/*
 * Harbour MiniGUI ZeeGrid Demo
 * (c) 2017, Petr Chornyj
 */

MEMVAR hG

#include "minigui.ch"
#include "i_winuser.ch"
#include "zeegrid.ch"

#define APP_ABOUT ( MiniGuiVersion() + CRLF + "ZeeGrid build " + hb_NtoS( zgm_QueryBuild( hG, .F. ) ) + " by David Hillard" )
#define ID_GRID   700

PROCEDURE Main()

   LOCAL hMod := zg_LoadDll()

   if Empty( hMod ) 
      QUIT
   endif

   PUBLIC hG

   SET EVENTS FUNCTION TO App_OnEvents

   DEFINE WINDOW Win_1 CLIENTAREA 600, 600 TITLE 'ZeeGrid demo' ;
      ICON "MAIN" ;
      WINDOWTYPE MAIN ;
      ON RELEASE FreeLibrary( hMod )

      DEFINE MAIN MENU
         POPUP 'Info'
            ITEM 'About ..'   ACTION MsgInfo( APP_ABOUT )

            SEPARATOR

            ITEM 'Exit'       ACTION Win_1.Release
         END POPUP
      END MENU
  
   END WINDOW

   CENTER   WINDOW Win_1
   ACTIVATE WINDOW Win_1

   RETURN


FUNCTION App_OnEvents( hWnd, nMsg, wParam, lParam )

   LOCAL result := 0, i

   switch nMsg
   case WM_CREATE
      //
      zg_InitGrid( hWnd, @hG, ID_GRID, "ZeeGrid Icons",,,,, {|h| Grid_OnInit( h ) } )
      exit

   case WM_COMMAND
      //
      switch HIWORD( wParam ) 
      //
      case ZGN_GOTFOCUS
         if LOWORD( wParam ) == ID_GRID

            i := zgm_GetCursorIndex( hG )
            if i > 0
               zgm_gotoCell( hG, i )
            else
               zgm_gotoCell( hG, zgm_GetCellIndex( hG, 1, 1 ) )
            endif

         endif
         exit

      otherwise
         result := Events( hWnd, nMsg, wParam, lParam )
      end
      exit

   case WM_SIZE
      //
      zg_Resize( hWnd, hG )
      exit

   otherwise
      //
      result := Events( hWnd, nMsg, wParam, lParam )
   end

   RETURN result


#translate ICELL( <row>, <col> ) => zgm_GetCellIndex( h, <row>, <col> )

PROCEDURE Grid_OnInit( h )

   LOCAL i

   // Append rows
   for i := 1 to 10
      zgm_AppendRow( h )
   next i

   // Resize columns
   for i := 1 to zgm_GetCols( h )
      zgm_SetColWidth( h, i, 80 )
   next i

   // Create font hTitleFont
   DEFINE FONT hTitleFont FONTNAME "MS Sans Serif" SIZE 28 BOLD
   // Add hTitleFont to the font palette
   zgm_SetFont( h, 20, GetFontHandle( "hTitleFont" ) )
   // and set the zeegrid title font to hTitleFont
   zgm_SetCellFont( h, 0, 20 )

   // Hide title
   // zgm_showTitle( h, .F. )

   // Add color to palette
   zgm_setColor( h, 21, RGB( 255, 192, 183 ) )
   zgm_setColor( h, 22, RGB(  72, 118, 255 ) )

   // Misc
   zgm_setRowHeight  ( h, 35 )
   zgm_showRowNumbers( h, .T. )
   zgm_showGridLines ( h, .F. )
   zgm_setGridLineColor( h, 22 ) 
   zgm_alternateRowColors( h, 1, 21 ) 
   //zgm_alternateRowColors ( h, 5, 21 ) 

   // Set column header titles
   zgm_setCellText( h, 1, e"First\nColumn" )
   zgm_setCellText( h, 2, e"Second\nColumn" )
   // and hide header
   // zgm_setColumnHeaderHeight ( h, 0 ) 

   // Write to cell some text and numbers
   i := zgm_getCellIndex( h, 4, 4 )

   zgm_setCellText  ( h, i++, "XX-XXX-XXX" )
   zgm_setCellInt   ( h, i++, 100 )
   zgm_setCellDouble( h, i++, 100.00 )
   zgm_setCellDouble( h, i,   100.00 * zgm_getCellDouble( h, i - 1 ) )

   i := zgm_getCellIndex( h,  5, 4 )
   zgm_setCellText  ( h, i++, "XX-XXX-XXX" )
   zgm_setCellInt   ( h, i++, 200 )
   zgm_setCellDouble( h, i++, 200.00 )
   zgm_setCellDouble( h, i,   200.00 * zgm_getCellDouble( h, i - 1 ) )
                             
   // Add icon to cell
   zg_LoadIcon2( h, 1, "GREEN" )
   zg_LoadIcon2( h, 2, "BLUE" )
   zg_LoadIcon2( h, 3, "RED" )

   zgm_SetCellIcon( h, 0, 1 )
   zgm_SetColIcon ( h, 2, 2 )
   zgm_SetRowIcon ( h, 2, 3 )
   zgm_SetColWidth( h, 2, 100 )

   RETURN
