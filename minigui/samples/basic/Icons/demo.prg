/*
 * Author: P.Chornyj <myorg63@mail.ru>
 *
 * A Quick & Easy guide to Microsoft Windows Icon Size
 * https://www.creativefreedom.co.uk/icon-designers-blog/windows-7-icon-sizes/
 */

ANNOUNCE RDDSYS

#include "minigui.ch"
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
      clientarea w, h + GetMenuBarHeight() ;
      title 'Icons Demo' ;
      main ;
      nomaximize nosize ;
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

   draw icon in window Form_Main at 0, 0 hicon hIcon width w height h

   on key Escape of Form_Main action ThisWindow.Release

   Form_Main.Center()
   Form_Main.Activate()

return
