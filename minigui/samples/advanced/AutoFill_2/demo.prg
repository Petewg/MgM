/*
  MINIGUI - Harbour Win32 GUI library Demo

  Copyright 2002-10 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  Author: S.Rathinagiri <srgiri@dataone.in>

  Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include <minigui.ch>

FUNCTION Main

   LOCAL aCountries := hb_ATokens( MemoRead( "Countries.lst" ),   CRLF )

   SET NAVIGATION EXTENDED

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 300 HEIGHT 200 ;
      TITLE "ComboBox AutoComplete Demo" ;
      MAIN

      DEFINE COMBOBOX cmb_1
         ROW 60
         COL 10
         WIDTH 160
         HEIGHT 205
         ITEMS aCountries
         SORT .T.
         DISPLAYEDIT .T.
         AUTOCOMPLETE .T.
         SHOWDROPDOWN .T.
         ON LOSTFOCUS Win_1.txb_1.Value := Win_1.cmb_1.Item( Win_1.cmb_1.Value )
         ON ENTER Win_1.txb_1.Value := Win_1.cmb_1.DisplayValue
      END COMBOBOX

      DEFINE TEXTBOX txb_1
         ROW 10
         COL 10
         WIDTH 160
      END TEXTBOX

   END WINDOW

   Win_1.Center()
   Win_1.Activate()

RETURN NIL
