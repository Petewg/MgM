
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

   LOCAL result := 0
   LOCAL aRect := { 0, 0, 0, 0 }
   LOCAL nCol, i

   switch nMsg
   case WM_CREATE
      //
      GetClientRect( hWnd, @aRect )
      aRect[4] *= 0.75
      zg_InitGrid( hWnd, @hG, ID_GRID, "ZeeGrid Combo", 0, 0, aRect[3], aRect[4], {|h| Grid_OnInit( h ) }  )
      exit

   case WM_COMMAND
      //
      switch HIWORD( wParam ) 
      //
      case ZGN_LOADCOMBO
         if LOWORD( wParam ) == ID_GRID
            //
            zgm_ComboClear( hG, .f. )
            nCol := zgm_GetColOfIndex( hG, zgm_GetEditedCell( hG ) )
            if nCol == 2
               for i := 0 TO 99
                  zgm_ComboAddString( hG, "Clipper #" + hb_NtoS( i ) )
               next i
            else
               for i := 0 TO 99
                  zgm_ComboAddString( hG, "Harbour #" + hb_NtoS( i ) )
               next i
            end
         endif
         exit

      case ZGN_GOTFOCUS
         if LOWORD( wParam ) == ID_GRID
            //
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
      GetClientRect( hWnd, @aRect )
      aRect[4] *= 0.75
      zg_Resize( hWnd, hG, aRect )
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

   // Create font hTitleFont
   DEFINE FONT hTitleFont FONTNAME "MS Sans Serif" SIZE 28 BOLD

   // Add hTitleFont to the font palette
   zgm_SetFont( h, 20, GetFontHandle( "hTitleFont" ) )
   // and set the zeegrid title font to hTitleFont
   zgm_SetCellFont( h, 0, 20 )

   // Set color to row
   zgm_SetRowBColor( h, 2, 6 ) // row #2 color yellow 
   zgm_SetRowFColor( h, 2, 5 ) // row #2 color magenta 

   // Add combo
   zgm_SetCellText( h, ICEL( 2, 2 ), "Clipper #1" )
   zgm_SetCellType( h, ICEL( 2, 2 ), 2 )     // type 2 - COMBO
   zgm_SetCellEdit( h, ICEL( 2, 2 ), 2 )     // type 2 - COMBO

   zgm_SetCellText( h, ICEL( 2, 4 ), "Harbour #1" )
   zgm_SetCellType( h, ICEL( 2, 4 ), 2 )     // type 2 - COMBO
   zgm_SetCellEdit( h, ICEL( 2, 4 ), 2 )     // type 2 - COMBO

   // Resize columns
   for i := 1 to zgm_GetCols( h )
      zgm_SetColWidth( h, i, 100 )
   next i

   // Disable columns resizing & moving
   zgm_EnableColResizing( h, .F. )
   zgm_EnableColMove( h, .F. )

   RETURN
