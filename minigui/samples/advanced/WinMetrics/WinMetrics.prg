/*
 * DESCRIPTION  : System Metrics ver. 00.01 * Spring 2010"
 * DATE CREATED : 19/03/2010
 * VERSION      : 00.01
 * Compatibility: HMG Extended / HMG (not tested)
 * Compiler     : Harbour (+ contrib library HBWin) 
 * AUTHOR       : Pete Dionysopoulos - Greece
 * LICENCE      : GPL - This applet is free (in every possible value of "free") software.
 * 
 * Revised by Alexey L. Gustow <gustow33 @ mail.ru> (GAL) 2010-May-20:
 * - added richeditbox under grid to see details of a current line immediately
*/


#include "minigui.ch"

#define WIN_SM_CXFULLSCREEN        16
#define WIN_SM_CYFULLSCREEN        17

***************
FUNCTION Main()
***************
LOCAL aMetrics := FilSysMet()
LOCAL nFullScreenWidth  := WAPI_GetSystemMetrics( WIN_SM_CXFULLSCREEN )
LOCAL nFullScreenHeight := WAPI_GetSystemMetrics( WIN_SM_CYFULLSCREEN )
LOCAL nGridWidth  := nFullScreenWidth  - 20
LOCAL nGridHeight := nFullScreenHeight - 230   // GAL

LOCAL bBColor := { || iif( This.CellRowIndex/2 == int(This.CellRowIndex/2) , {228,228,228 } , { 225,255,224 } ) }	
   
   DEFINE WINDOW MainWin ; 
	AT  0 , 0 ;
	WIDTH nFullScreenWidth ;
	HEIGHT nFullScreenHeight ; 
	TITLE "WinMetrics" ;
	MAIN ;
	BACKCOLOR {34,85,132} ;
	FONT "Lucida Console" SIZE 10

	DEFINE MAIN MENU OF MainWin
              POPUP "&File"
              	  ITEM "&Reload System metrics" ;
                     Action {|| aMetrics := FilSysMet(), GridMetricsHeadClick(1, aMetrics, .F.), ;
                                Rebox_Update(), NIL }   // GAL
		  SEPARATOR  
		  ITEM "&Exit" ACTION MainWin.Release
              END POPUP
              POPUP "&Help"
              	  ITEM "&Help" Action {|| About("Help") }
              	  SEPARATOR
              	  ITEM "&About" Action {|| About("ABOUT") }
              END POPUP
	END MENU

	// GAL edition
      	DEFINE GRID GridMetrics
		COL 10
		ROW 10
		WIDTH nGridWidth
		HEIGHT nGridHeight
		HEADERS {"#/#", "HEADER_DEF", "Current Value", "Description"}
		WIDTHS {50, 220, 120, 1100}
		ITEMS aMetrics
		VALUE 1
		OnChange {|| Rebox_Update() }
		ONDBLCLICK {|| GridMetricsDblClick(), Rebox_Update() }
		ONHEADCLICK { ;
			{|| GridMetricsHeadClick(1, aMetrics), Rebox_Update() }, ;
			{|| GridMetricsHeadClick(2, aMetrics), Rebox_Update() }, ;
			{|| GridMetricsHeadClick(3, aMetrics), Rebox_Update() }, ;
			{|| GridMetricsHeadClick(4, aMetrics), Rebox_Update() } } 
		DYNAMICBACKCOLOR { bBColor , bBColor , bBColor , bBColor }
		JUSTIFY { GRID_JTFY_CENTER, GRID_JTFY_LEFT, GRID_JTFY_CENTER, GRID_JTFY_LEFT }
	END GRID

	DEFINE RICHEDITBOX Rebox_Details
		COL 10
		ROW nGridHeight + 20
		WIDTH nGridWidth
		HEIGHT 130
		NOHSCROLLBAR .T.
		/* READONLY */
	END RICHEDITBOX

	DEFINE BUTTON Button_Reload
		COL 10
		ROW nGridHeight + 165   // GAL
		WIDTH 200
		HEIGHT 30
		CAPTION "Reload System metrics"
		ACTION  {|| aMetrics := FilSysMet(), GridMetricsHeadClick(1, aMetrics, .F.), NIL }
		FLAT .F.
	END BUTTON

	DEFINE BUTTON Button_Close
		COL 220
		ROW nGridHeight + 165   // GAL
		WIDTH 200
		HEIGHT 30
		CAPTION "Close"
		ACTION ThisWindow.Release()
		FLAT .F.
	END BUTTON

   END WINDOW

   Rebox_Update()   // GAL

   MAXIMIZE WINDOW MainWin
   ACTIVATE WINDOW MainWin

RETURN Nil

******************************
Static Function Rebox_Update() // GAL
******************************
LOCAL aRow := MainWin.GridMetrics.Item(MainWin.GridMetrics.Value)

   MainWin.Rebox_Details.Value := ;
     "WAPI_GetSystemMetrics( " + aRow[2]+" )" + REPL( CRLF, 2 ) + ;
     "Current value: " + alltrim( aRow[3] )   + REPL( CRLF, 2 ) + ;
     "Details : " + CRLF + aRow[4]

RETURN NIL

*************************************
Static Function GridMetricsDblClick()
*************************************
LOCAL aRow := MainWin.GridMetrics.Item(MainWin.GridMetrics.Value)

RETURN MsgInfo( "WAPI_GetSystemMetrics( " + aRow[2]+" )" + REPL( CRLF, 2 ) + ;
                "Current value: " + alltrim( aRow[3] )   + REPL( CRLF, 2 ) + ;
                "Details : " + CRLF + ;
                aRow[4], aRow[2] )

*********************************************************
Static Function GridMetricsHeadClick(nCol, aRows, lClick)
*********************************************************
LOCAL lWW := .T.
STATIC snColInd := 0

  DEFAULT lClick TO .T.

  IF ! lClick
	snColInd := 0
  ENDIF
  IF lWW // ( lWW := ( WAPI_GetSystemMetrics( WIN_SM_SLOWMACHINE ) <> 0 ) )
	ShowWaitWindow ( iif( lClick, "Sorting array...", "Reloading array..." ) )
  ENDIF
  MainWin.Rebox_Details.Hide
  MainWin.GridMetrics.Hide
  MainWin.GridMetrics.DisableUpdate()
  IF snColInd <> nCol /* no sorted or already descending sorted. do ascending..*/
	aRows := asort( aRows,,, { |x, y| x[nCol] < y[nCol] } )
	snColInd := nCol
  ELSE /* already ascending sorted. do descending.. */
	aRows := ASort( aRows,,, { |x, y| x[nCol] > y[nCol] } )
	snColInd := 0
  ENDIF
  AEval( aRows, {|e,i| MainWin.GridMetrics.Item( i ) := e } )
  MainWin.GridMetrics.EnableUpdate()
  MainWin.GridMetrics.Show
  MainWin.Rebox_Details.Show
  IF lWW
	ShowWaitWindow()
  ENDIF
  IF ! lClick
	MainWin.GridMetrics.Setfocus
  ENDIF

RETURN nil

****************************
Function ShowWaitWindow( cMess )
****************************
  IF ! IsWindowDefined( WaitWin )
	DEFINE WINDOW WaitWin ;
		AT 192 , 645 WIDTH 320 HEIGHT 100 TITLE "Info!" ; 
		TOPMOST NOMAXIMIZE NOMINIMIZE NOSIZE NOSYSMENU BACKCOLOR {0,74,168}
	   DEFINE LABEL WaitLabel
		ROW 10
		COL 10
		WIDTH  300
		HEIGHT 60
		VALUE "Processing.."
		FONTNAME "Lucida Console"
		FONTSIZE 14
		CENTERALIGN .T.
		TRANSPARENT .T.
		FONTCOLOR {255,255,0}
	   END LABEL
	END WINDOW
	CENTER WINDOW WaitWin
	ACTIVATE WINDOW WaitWin NOWAIT
  ENDIF
  IF ! Empty(cMess)
	WaitWin.WaitLabel.Value := cMess + CRLF + "Please wait!"
	SHOW WINDOW WaitWin
	DO EVENTS
  ELSE
	WaitWin.Hide
  ENDIF

RETURN NIL

***********************
Static Function About(cWhat)
**********************
LOCAL cLineFeed := HB_OSNewLine()
  IF UPPER(cWhat) == "ABOUT" 
	MSGInfo(;
	"System Metrics ver. 00.01 * Spring 2010"  + REPL( cLineFeed , 2 ) + ;
	"Simple applet, showing many system metrics regarding hardware and/or OS." + cLineFeed + ;
	"Created to demonstrate the WAPI_GetSystemMetrics Harbour function " + cLineFeed + ;
	"included into <HBWin> library."  + cLineFeed + ;
	"This function provides interesting informations, that might be useful" + cLineFeed + ;
	"to HMG (and not only) programmers and also could be used  as a " + cLineFeed + ;
	"'native' replacement of some Minigui functions like, for example: " + cLineFeed + ;
	"GetDesktopWidth(), GetDesktopHeigh() or other relevant UDFs perhaps." + cLineFeed + ;
	"(..on a second level some informations returned by WAPI_GetSystemMetrics," + cLineFeed + ;
	"could cure programmer's curiosity about users, since it can disclosure" + cLineFeed + ;
	"some (microsoft's taste) funny things about them, like: " + cLineFeed + ;
	'"do they use a mouse?" or "are they left-handed or not?")' + cLineFeed + ;
	"Enjoy!"  + cLineFeed + cLineFeed + ;
	"---"  + cLineFeed + ;
	"Pete - Greece" + cLineFeed + ;
	"(e-mail: pete_westg@yahoo.gr)", ;
	"About")
  ELSEIF UPPER(cWhat) == "HELP"
	MSGInfo(;
	"- DoubleClick on a row to display informations in a more readable form." + REPL( cLineFeed , 2 ) + ; 
	"- Click on column heads to sort respectively. (Click again for reverse sorting)" + REPL( cLineFeed , 2 ) + ;
	"- Hit Reload button (or select from menu) to refresh metrics.", ;         
	"Help")
  ENDIF

RETURN NIL

#include "WMFunc.prg"
