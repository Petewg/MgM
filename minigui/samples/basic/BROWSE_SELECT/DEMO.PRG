// ------------------------------------------------------------ //
#include <hmg.ch>

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
      => ;
      _DefineHotKey ( <"parent">, 0, VK_SPACE, <{action}> )
// ------------------------------------------------------------ //
STATIC aRecs := {}

FUNCTION Main()

REQUEST DBFNSX

   SET BROWSESYNC ON

   dbUseArea( .T., "DBFNSX", "MUSIC", .F. )
   ordSetFocus( 1 )
   dbGoTop()

   DEFINE WINDOW wndMain;
      AT 0, 0;
      WIDTH 675;
      HEIGHT 403;
      TITLE "Selection of records Demo";
      ON RELEASE dbCloseArea();
      MAIN

   DEFINE MAIN MENU

      DEFINE POPUP 'Tests'
         MENUITEM 'Select\unselect the current record' ACTION ( SelectRecord( @aRecs, wndMain.brsDemo.Value ), wndMain.brsDemo.Refresh() )
         MENUITEM 'Show number of selected records' ACTION MsgInfo( hb_ntos( Len( aRecs ) ) + ' records selected' )
         MENUITEM 'Show record numbers of selected records' ACTION MsgDebug( aRecs )
         MENUITEM 'Unselect all records'  ACTION ( aRecs := {}, wndMain.brsDemo.Refresh() )
      END POPUP

   END MENU

   DEFINE STATUSBAR
      STATUSITEM "Double click on a checkbox or use <SpaceBar> key to select\unselect the current record"
   END STATUSBAR

   END WINDOW

   @ 5, 5 BROWSE brsDemo;
      OF wndMain;
      WIDTH 645;
      HEIGHT 315;
      HEADERS { "M", "Nummer", "Trk", "Artiest", "Titel" } ;
      WIDTHS { 23, 65, 35, 248, 249 };
      IMAGE { "bmpUnChecked", "bmpChecked" } ;
      WORKAREA MUSIC;
      FIELDS { "ChkSelectStatus()", "MUSIC->NR", "MUSIC->DTR", "MUSIC->ARTIEST", "MUSIC->TITEL" };
      JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT } ;
      ON DBLCLICK DblClickBrowseScreen()

   ON KEY SPACE OF wndMain ACTION ( SelectRecord( @aRecs, wndMain.brsDemo.Value ), _PushKey( VK_DOWN ), wndMain.brsDemo.Refresh() )

   wndMain.Center
   wndMain.Activate

RETURN NIL
// ------------------------------------------------------------ //
STATIC FUNCTION DblClickBrowseScreen

   IF This.CellColIndex == 1
      SelectRecord( @aRecs, This.Value )
      This.Refresh()
   ELSE
      MsgInfo( "Record number " + hb_ntos( This.Value ) + " was double clicked" )
   ENDIF

RETURN( NIL )
// ------------------------------------------------------------ //
FUNCTION SelectRecord( aRecs, nRecord )

   LOCAL nKey

   DEFAULT nRecord := RecNo()

   nKey := AScan( aRecs, nRecord )

   IF nKey == 0
      nKey := AScan( aRecs, NIL )
      IF nKey == 0
         AAdd( aRecs, nRecord )
      ELSE
         aRecs[ nKey ] := nRecord
      ENDIF
   ELSE
      ADel( aRecs, nKey, .T. )
   ENDIF

RETURN( NIL )
// ------------------------------------------------------------ //
FUNCTION ChkSelectStatus()
RETURN( AScan( aRecs, RecNo() ) <> 0 )
