#include "hmg.ch"

STATIC aSeries, aSerieNames, aColors

FUNCTION Main

   /*
    * DATA PROVIDED BY NETMARKETSHARE.COM FOR NOVEMBER 2016
    */

   aSeries := { ;
      .47167043, ;
      .23717948, ;
      .08633704, ;
      .08010271, ;
      .02307131, ;
      .02214791, ;
      .02213533, ;
      .05735579;
      }

   AEval( aSeries, { | x, i | aSeries[i] := 100 * x } )

   aSerieNames := { ;
      "Windows 7", ;
      "Windows 10", ;
      "Windows XP", ;
      "Windows 8.1", ;
      "Linux", ;
      "Mac OS X 10.11", ;
      "Mac OS X 10.12", ;
      "Other: Windows 8, Vista, Mac OS < 10.11, WinNT";
      }

   aColors := { { 71, 114, 149 }, { 70, 164, 70 }, { 207, 26, 43 }, { 220, 167, 0 }, { 70, 121, 152 }, { 206, 86, 0 }, { 91, 107, 182 }, { 22, 64, 104 } }

   SET FONT TO GetDefaultFontName(), 10

   DEFINE WINDOW m ;
      AT 0, 0 ;
      WIDTH 720 HEIGHT 600 ;
      MAIN ;
      TITLE "Print Pie Graph" ;
      BACKCOLOR { 216, 208, 200 }

   DEFINE BUTTON d
      ROW 10
      COL 10
      CAPTION "Draw"
      ACTION showpie()
   END BUTTON

   DEFINE BUTTON p
      ROW 40
      COL 10
      CAPTION "Print"
      ACTION ( showpie(), printpie() )
   END BUTTON

   END WINDOW

   m.Center()
   m.Activate()

RETURN NIL


FUNCTION showpie

   ERASE WINDOW m

   Create_CONTEXT_Menu( ThisWindow.Name )

   IF Empty( _HMG_DefaultFontName )
      _HMG_DefaultFontName := GetDefaultFontName()
   ENDIF

   IF Empty( _HMG_DefaultFontSize )
      _HMG_DefaultFontSize := GetDefaultFontSize()
   ENDIF

   DEFINE PIE IN WINDOW m
      ROW 10
      COL 160
      BOTTOM 550
      RIGHT 560
      TITLE "Desktop Operating System Market Share"
      SERIES aSeries
      DEPTH 25
      SERIENAMES aSerieNames
      COLORS aColors
      3DVIEW .T.
      SHOWXVALUES .T.
      SHOWLEGENDS .T.
      DATAMASK "99.9999"
   END PIE

RETURN NIL


FUNCTION printpie

   PRINT GRAPH IN WINDOW m ;
      AT 10, 160 ;
      TO 550, 560 ;
      TITLE "Desktop Operating System Market Share" ;
      TYPE PIE ;
      SERIES aSeries ;
      DEPTH 25 ;
      SERIENAMES aSerieNames ;
      COLORS aColors ;
      3DVIEW ;
      SHOWXVALUES ;
      SHOWLEGENDS DATAMASK "99.9999"

RETURN NIL


PROCEDURE Create_CONTEXT_Menu ( cForm )

   IF IsContextMenuDefined () == .T.
      Release_CONTEXT_Menu ( cForm )
   ENDIF

   IsContextMenuDefined ( .T. )

   DEFINE CONTEXT MENU OF &cForm

      ITEM 'Change Graph Font Name' ACTION ;
         ( _HMG_DefaultFontName := GetFont ( _HMG_DefaultFontName, _HMG_DefaultFontSize, .F., .F., { 0, 0, 0 }, .F., .F., 0 ) [ 1 ], showpie() )

      ITEM 'Change Graph Font Size' ACTION ;
         ( _HMG_DefaultFontSize := GetFont ( _HMG_DefaultFontName, _HMG_DefaultFontSize, .F., .F., { 0, 0, 0 }, .F., .F., 0 ) [ 2 ], showpie() )

   END MENU

RETURN


PROCEDURE Release_CONTEXT_Menu ( cForm )

   IF IsContextMenuDefined () == .F.
      MsgInfo ( "Context Menu not defined" )
      RETURN
   ENDIF

   IsContextMenuDefined ( .F. )

   RELEASE CONTEXT MENU OF &cForm

RETURN


FUNCTION IsContextMenuDefined ( lNewValue )

   STATIC IsContextMenuDefined := .F.
   LOCAL lOldValue := IsContextMenuDefined

   IF ISLOGICAL( lNewValue )
      IsContextMenuDefined := lNewValue
   ENDIF

RETURN lOldValue
