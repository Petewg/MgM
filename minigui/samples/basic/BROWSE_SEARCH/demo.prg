// ------------------------------------------------------------ //
#include "hmg.ch"
#include "i_winuser.ch"
// ------------------------------------------------------------ //
STATIC cSearchString := "", cWindowName, cBrowseName

FUNCTION Main()

REQUEST DBFNSX

SET BROWSESYNC ON

dbUseArea( .T., "DBFNSX", "MUSIC", .F. )
ordSetFocus( 1 )
dbGoTop()

DEFINE WINDOW wndMainForm;
      AT 0, 0;
      WIDTH 645;
      HEIGHT 403;
      TITLE "Browse Quick Search Demo";
      MAIN;
      ON INIT cWindowName := This.Name ;
      ON RELEASE dbCloseArea( "MUSIC" )

      DEFINE STATUSBAR
            STATUSITEM "Type to QuickSearch"
            KEYBOARD
      END STATUSBAR

      ON KEY ESCAPE ACTION ThisWindow.Release()
END WINDOW

@ 5, 5 BROWSE brsMainBrowse;
      OF wndMainForm;
      WIDTH 620;
      HEIGHT 332;
      HEADERS { "Nummer", "Trk", "Artiest", "Titel" };
      WIDTHS { 65, 35, 248, 249 };
      WORKAREA MUSIC;
      FIELDS { "MUSIC->NR", "MUSIC->DTR", "MUSIC->ARTIEST", "MUSIC->TITEL" };
      JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT };
      ON GOTFOCUS cBrowseName := This.Name

CREATE EVENT PROCNAME BrowseQuickIndexSearch()

wndMainForm.Center()
wndMainForm.Activate()

RETURN NIL
// ------------------------------------------------------------ //
FUNCTION BrowseQuickIndexSearch( hWnd, nMsg, wParam, lParam )

   LOCAL nKey, cKey

   HB_SYMBOL_UNUSED( hWnd )
   HB_SYMBOL_UNUSED( wParam )

   IF nMsg == WM_NOTIFY

      IF _IsControlDefined( cBrowseName, cWindowName ) .AND. GetHwndFrom ( lParam ) == GetProperty( cWindowName, cBrowseName, "Handle" )

         IF GetNotifyCode( lParam ) = LVN_KEYDOWN

            nKey := GetGridvKey( lParam )

            DO CASE

            CASE nKey == VK_UP
               _BrowseUp( cBrowseName, cWindowName )
               RETURN ClearSearch()

            CASE nKey == VK_DOWN
               _BrowseDown( cBrowseName, cWindowName )
               RETURN ClearSearch()

            CASE nKey == VK_HOME
               _BrowseHome( cBrowseName, cWindowName )
               RETURN ClearSearch()

            CASE nKey == VK_END
               _BrowseEnd( cBrowseName, cWindowName )
               RETURN ClearSearch()

            CASE nKey == VK_PRIOR
               _BrowsePrior( cBrowseName, cWindowName )
               RETURN ClearSearch()

            CASE nKey == VK_NEXT
               _BrowseNext( cBrowseName, cWindowName )
               RETURN ClearSearch()

            OTHERWISE
               cKey := Chr( nKey )
               IF IsAlpha( cKey ) .OR. IsDigit( cKey ) .OR. nKey == VK_BACK
                  RETURN IncrementalSearch( cKey, nKey )
               ENDIF

            ENDCASE

         ENDIF

      ENDIF

   ENDIF

RETURN NIL
// ------------------------------------------------------------ //
STATIC FUNCTION ClearSearch()

   cSearchString := ""
   SetProperty( cWindowName, "StatusBar", "Item", 1, "" )

RETURN 1
// ------------------------------------------------------------ //
STATIC FUNCTION IncrementalSearch( cKey, nKey )

   LOCAL nOldRec

   IF nKey == VK_BACK
      cSearchString := iif( Len( cSearchString ) > 1, Left( cSearchString, Len( cSearchString ) - 1 ), "" )
   ELSE
      cSearchString += cKey
   ENDIF

   nOldRec := RecNo()
   IF dbSeek( Upper( cSearchString ), .T. )
      SetProperty( cWindowName, cBrowseName, "Value", RecNo() )
   ELSE
      cSearchString := iif( Len( cSearchString ) > 1, Left( cSearchString, Len( cSearchString ) - 1 ), "" )
      SetProperty( cWindowName, cBrowseName, "Value", nOldRec )
   ENDIF

   SetProperty( cWindowName, "StatusBar", "Item", 1, "Quicksearch: " + iif( Empty( cSearchString ), "", cSearchString ) )
   DoMethod( cWindowName, cBrowseName, 'Setfocus' )

RETURN 1
