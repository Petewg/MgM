/*
 * Author: P.Chornyj <myorg63@mail.ru>
 */

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "i_winuser.ch"
///////////////////////////////////////////////////////////////////////////////
procedure main()

   local cIcon := 'IconVista.ico', hIcon
   local aInfo, w, h

   if IsVistaOrLater()
      hIcon := LoadIconByName( cIcon, 256, 256 )
   elseif IsWinXPorLater()
      hIcon := LoadIconByName( cIcon, 128, 128 )
   endif

   if Empty( hIcon )
      quit
   endif

   aInfo := GetIconSize( hIcon )
   w := aInfo[ 1 ]
   h := aInfo[ 2 ]

   define window Form_Main ;
      clientarea 3*w, 2*h + 2*GetMenuBarHeight() ;
      title 'Draw the bitmap or icon image using the Windows DrawState' ;
      main ;
      nomaximize nosize ;
      on paint Form_Main_OnPaint( Form_Main.Handle, hIcon, w, h );
      on release ;
      ( ;
         DestroyIcon( hIcon ) ;
      )

      define main menu
         define popup "&File" 
            menuitem "E&xit" action ThisWindow.Release
         end popup
      end menu
   end window

   on key Escape of Form_Main action ThisWindow.Release

   Form_Main.Center()
   Form_Main.Activate()

return

///////////////////////////////////////////////////////////////////////////////
function Form_Main_OnPaint( hWnd, hIcon, w, h )

   local y  := h + GetMenuBarHeight()
   local x1 := 0
   local x2 := w + 1
   local x3 := 2*w + 1
   local nColor

   DrawState( hWnd, Nil,    Nil, hIcon, Nil, x1, 0, w, h, hb_BitOr( DST_ICON, DSS_DISABLED ), .f. )
   //DrawIconEx( hWnd, x2, 0, hIcon, w, h, GetSysColor( COLOR_BTNFACE ), .f. )
   DrawState( hWnd, Nil,    Nil, hIcon, Nil, x2, 0, w, h, hb_BitOr( DST_ICON, DSS_NORMAL ), .f. )
   DrawState( hWnd, LGREEN, Nil, hIcon, Nil, x3, 0, w, h, hb_BitOr( DST_ICON, DSS_UNION ), .f. )

   DrawState( hWnd, RED,    Nil, hIcon, Nil, x1, y, w, h, hb_BitOr( DST_ICON, DSS_MONO ), .f. )
   DrawState( hWnd, GREEN,  Nil, hIcon, Nil, x2, y, w, h, hb_BitOr( DST_ICON, DSS_MONO ), .f. )
   DrawState( hWnd, BLUE,   Nil, hIcon, Nil, x3, y, w, h, hb_BitOr( DST_ICON, DSS_MONO ), .f. )

   nColor = SetBackColor( hWnd, RGB( 250, 0, 0 ) )
   // nColor = SetBackColor( hWnd, 250, 0, 0 )
   // nColor = SetBackColor( hWnd, { 250, 0, 0 } )

   if w > 128 
      DrawState( hWnd, Nil,    Nil, "der Achtungsapplaus", Nil, 0*w + w/4, h, 0, 0, hb_BitOr( DST_TEXT, DSS_DISABLED ), .f. )
      DrawState( hWnd, Nil,    Nil, "der Achtungsapplaus", Nil, 1*w + w/4, h, 0, 0, hb_BitOr( DST_TEXT, DSS_NORMAL ), .f. )
      DrawState( hWnd, LGREEN, Nil, "der Achtungsapplaus", Nil, 2*w + w/4, h, 0, 0, hb_BitOr( DST_TEXT, DSS_UNION ), .f. )
   endif

   SetBackColor( hWnd, nColor )
   // SetBackColor( hWnd, GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) )
   // SetBackColor( hWnd, { GetRed( nColor ), GetGreen( nColor ), GetBlue( nColor ) } )

return NIL
