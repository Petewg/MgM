
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

   SET DATE FORMAT     TO "dd.mm.yyyy"
   SET EVENTS FUNCTION TO App_OnEvents

   DEFINE WINDOW Win_1 CLIENTAREA 600, 600 TITLE 'ZeeGrid demo' ;
      ICON "MAIN.ICO" ;
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
      zg_InitGrid( hWnd, @hG, ID_GRID, "ZeeGrid Numbers",,,,, {|h| Grid_OnInit( h ) }  )
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

   // Create font hTitleFont
   DEFINE FONT hTitleFont FONTNAME "MS Sans Serif" SIZE 28 BOLD
   // Add hTitleFont to the font palette
   zgm_SetFont( h, 20, GetFontHandle( "hTitleFont" ) )
   // and set the zeegrid title font to hTitleFont
   zgm_SetCellFont( h, 0, 20 )

   // Append rows
   for i := 1 to 10
      zgm_AppendRow( h )
   next i

   // --- 
   zgm_SetColType( h, 1, 3 )   // numeric
   zgm_SetColType( h, 2, 3 )   // numeric
   zgm_SetColType( h, 3, 3 )   // numeric

   zgm_SetColFormat( h, 1, 0 ) // normal numeric fashion
   zgm_SetColFormat( h, 2, 0 ) // normal numeric fashion
   zgm_SetColFormat( h, 3, 1 ) // a percentage

   zgm_SetCellInt   ( h, ICEL( 2, 1 ), 100 )
   zgm_SetCellDouble( h, ICEL( 2, 2 ), 0.1536 )
   zgm_SetCellDouble( h, ICEL( 2, 3 ), 0.1536 )

   zgm_SetCellDouble( h, ICEL( 3, 2 ), 0.1536 )
   zgm_setCellNumPrecision( h, ICEL( 3, 2 ), 4 )

   zgm_SetCellDouble( h, ICEL( 3, 3 ), 0.1536 )
   zgm_setCellNumPrecision( h, ICEL( 3, 3 ), 4 )

   // Resize columns
   for i := 1 to zgm_GetCols( h )
      zgm_SetColWidth( h, i, 80 )
   next i

   // Disable columns resizing & moving
   zgm_EnableColResizing( h, .F. )
   zgm_EnableColMove( h, .F. )

   RETURN
