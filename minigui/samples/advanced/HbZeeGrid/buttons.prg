
/*
 * Harbour MiniGUI ZeeGrid Demo
 * (c) 2017, Petr Chornyj
 */

MEMVAR hG
MEMVAR nButton_One

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
   LOCAL aRect := { 0, 0, 0, 0 }

   switch nMsg
   case WM_CREATE
      //
      GetClientRect( hWnd, @aRect )
      aRect[4] *= 0.75
      zg_InitGrid( hWnd, @hG, ID_GRID, "ZeeGrid Buttons", 0, 0, aRect[3], aRect[4], {|h| Grid_OnInit( h ) }  )
      exit

   case WM_COMMAND
      //
      switch HIWORD( wParam ) 
      case ZGN_BUTTONPRESSED
         if LOWORD( wParam ) == ID_GRID
            if nButton_One == zgm_getLastButtonPressed( hG )
               MsgInfo( "Button #1 pressed" )
            else
               MsgInfo( zgm_GetCellText( hG, zgm_getLastButtonPressed( hG ) ) + " pressed" )
            endif
         endif
         exit

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
   LOCAL nButton_Two
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

   // Set background color to row
   zgm_SetRowBColor( h, 0, 4 ) // __ALL__ rows    
   zgm_SetRowBColor( h, 9, 5 ) // row #9  

   // Set font to row
   DEFINE FONT hButtonFont FONTNAME "MS Sans Serif" SIZE 12 BOLD

   zgm_SetFont( h, 21, GetFontHandle( "hButtonFont" ) )
   zgm_SetRowFont( h, 9, 21 )

   // Add buttons
   PUBLIC nButton_One := ICEL( 9, 2 )

   zgm_SetCellText   ( h, nButton_One, "Button #1" )   
   zgm_SetCellJustify( h, nButton_One, 4 )     // call AFTER setCellText?
   zgm_SetCellType   ( h, nButton_One, 5 )     // type 5 - BUTTON
   zgm_SetCellEdit   ( h, nButton_One, 0 )     // read-only

   nButton_Two := ICEL( 9, 4 )

   zgm_SetCellText   ( h, nButton_Two, "Button #2" )   
   zgm_SetCellJustify( h, nButton_Two, 4 )     // call AFTER setCellText?
   zgm_SetCellType   ( h, nButton_Two, 5 )     // type 5 - BUTTON
   zgm_SetCellEdit   ( h, nButton_Two, 0 )     // read-only

   // Resize columns
   for i := 1 to zgm_GetCols( h )
      zgm_SetColWidth( h, i, 80 )
   next i

   zgm_AutosizeColumn( h, 2 )
   zgm_AutosizeColumn( h, 4 )

   // Disable columns resizing & moving
   zgm_EnableColResizing( h, .F. )
   zgm_EnableColMove( h, .F. )

   RETURN
