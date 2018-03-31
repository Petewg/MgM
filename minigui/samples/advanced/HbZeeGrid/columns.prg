
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

   LOCAL result := 0, i

   switch nMsg
   case WM_CREATE
      //
      zg_InitGrid( hWnd, @hG, ID_GRID, "ZeeGrid Columns",,,,, {|h| Grid_OnInit( h ) }  )
      exit

   case WM_COMMAND
      //
      switch HIWORD( wParam ) 
      //
      case ZGN_GOTFOCUS
         //
         if LOWORD( wParam ) == ID_GRID

            i := zgm_GetCursorIndex( hG )
            if i > 0
               zgm_gotoCell( hG, i )
            else
               zgm_gotoCell( hG, zgm_GetCellIndex( hG, 1, 10 ) )
            endif

         endif
         exit

      otherwise
         //
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
   // 10 - total columns, ALL ( 10 - 0 ) - visible, 0 - fixed
   zgm_DimGrid( h, 10, 0, 0 )

   // Create font hTitleFont
   DEFINE FONT hTitleFont FONTNAME "MS Sans Serif" SIZE 28 BOLD

   // Add hTitleFont to the font palette
   zgm_SetFont( h, 20, GetFontHandle( "hTitleFont" ) )
   // and set the zeegrid title font to hTitleFont
   zgm_SetCellFont( h, 0, 20 )

   zgm_SetColumnHeaderHeight( h, 35 )

   for i := 1 to zgm_GetCols( h )
      zgm_SetCellText( h, i, "Column" + CRLF + "#" + hb_NtoS( i ) ) // headers
      zgm_SetColWidth( h, i, 80 )
   next i

   for i := 1 to 100
      zgm_AppendRow( h )
   next i

   zgm_EnableColMove( h, .T. )
   zgm_SetCellText( h, ICEL( 1, 4 ), "Select column and use arrows to move column" )

   zgm_EnableColResizing( h, .F. )
   zgm_EnableColumnSelect( h, .T. )

   //zgm_Autosize_All_Columns( h )                            // call AFTER setCellText
   zgm_AutosizeColumn( h, 4 )                                 // call AFTER setCellText

   zgm_SetColumnOrder( h, { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 } ) // not work if visible cols != 0 (or total)?
   //zgm_SelectColumn( h, 4 )                                 // not work ?
   zgm_HighlightCursorRowInFixedColumns( h, .F. )             // not work ?

   zgm_HighlightCursorRow( h, .T. )

   RETURN
