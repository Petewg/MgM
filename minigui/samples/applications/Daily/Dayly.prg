#include 'minigui.ch'

ANNOUNCE RDDSYS
REQUEST DBFNTX

MEMVAR nScrWidth
MEMVAR DateCale

MEMVAR PathApp
MEMVAR PathDTop
MEMVAR PathStUp

MEMVAR nSec
MEMVAR lPowerOff
MEMVAR lForceMode
MEMVAR lTimeShdOk

MEMVAR UserName
MEMVAR CompName
MEMVAR cNameApp
MEMVAR FileExe
MEMVAR cVer
MEMVAR cWWW

MEMVAR aPrRF

MEMVAR aMS
MEMVAR aDay
MEMVAR aEve
MEMVAR aRegInfo
MEMVAR aColorsDayly

MEMVAR aClr
MEMVAR PictRG
MEMVAR aCLRCale
MEMVAR ClrText
MEMVAR aOBClr

MEMVAR aCale
MEMVAR aDayMess
MEMVAR aHDay
MEMVAR nTimerUpDate
MEMVAR nWidthWin
MEMVAR lTmrM
MEMVAR lPrzdShow

//-------------------------------------------------------------\\

FUNCTION MAIN

   LOCAL nRow1, nCol1
   LOCAL i, j, clbl, dStart

   SET MULTIPLE OFF WARNING

   SET DELETE ON
   SET DATE GERMAN
   SET EPOCH TO 2000

   SET TOOLTIP BALLOON ON
   SET TOOLTIP MAXWIDTH TO 500

   SET LOGERROR OFF
   SET MENUSTYLE EXTENDED

   PUBLIC nScrWidth := GetDesktopWidth()
   PUBLIC DateCale  := Date()

   PUBLIC PathApp    := GetStartupFolder()
   PUBLIC PathDTop   := GetDesktopFolder()
   PUBLIC PathStUp   := GetSpecialFolder( CSIDL_STARTUP )
   PUBLIC lTimeShdOk := .F.

   PUBLIC UserName   := AllTrim( GetUserName() )
   PUBLIC CompName   := AllTrim( GetComputerName() )
   PUBLIC cNameApp   := 'Dayly-SL'
   PUBLIC FileExe    := PathApp + '\Dayly.exe'
   PUBLIC cVer       := '2.0'
   PUBLIC cWWW       := "http://minisoft.tora.ru"

   PUBLIC aPrRF := {}

   PUBLIC aMS := {}
   FOR i = 1 TO 12
      AAdd( aMS, CMonth( CToD( '01.01.2013' ) + ( i - 1 ) * 32 ) )
   NEXT

   PUBLIC aDay := {}
   dStart := CToD( '20.10.2013' )
   FOR i = 1 TO 7
      AAdd( aDay, CDoW( dStart + i - 1 ) )
   NEXT

   PUBLIC aEve := { 'Yearly', 'Monthly', 'Weekly','Daily', 'Irregular' }
   PUBLIC aRegInfo := { UserName, CompName }

   PUBLIC aColorsDayly := { ;
      { { 220, 220, 220 }, { 158, 158, 158 }, { 96, 96, 96 } }, ;
      { { 255, 228, 196 }, { 255, 198,  44 }, { 252, 82,  44 } }, ;
      { { 210, 255, 220 }, { 160, 235, 170 }, { 85, 165, 94 } }, ;
      { { 196, 228, 255 }, { 44,  198, 255 }, {  44, 84, 255 } } }

   IF !File( 'dayly.set' )
      RETURN NIL
   ENDIF

   USE 'dayly.set' ALIAS SETI NEW

   aClr     := aColorsDayly[ SETI->clr_ ]
   PictRG   := 'RG' + hb_ntos( SETI->clr_ )
   aCLRCale := aClr[ 2 ]
   ClrText  := { 96, 96, 96 }

   PUBLIC aOBClr := { { 0, 4, aClr[ 2 ], aClr[ 1 ], aClr[ 2 ], WHITE, BLACK, BLACK, 1, aClr[ 2 ], aClr[ 1 ] } }

   aCale := CaleToArray( Date() )
   // MsgDebug( PrazdToArray( HB_NToS(Year( Date() )) ) )

   aDayMess     := {}
   nTimerUpDate := 15
   nWidthWin    := 209
   lTmrM        := .F.
   lPrzdShow    := .F.

   OpenTable()

   DEFINE WINDOW WinDayly AT 10, nScrWidth / 2 -nWidthWin / 2 ;
      WIDTH nWidthWin HEIGHT 240 ;
      TITLE cNameApp ICON 'MAIN' ;
      MAIN ;
      NOCAPTION NOSIZE NOMAXIMIZE ;
      NOSHOW ;
      NOTIFYICON 'TRAY' BACKCOLOR aClr[ 2 ] ;
      NOTIFYTOOLTIP 'Dayly is activated!' ;
      ON NOTIFYCLICK DoMethod( 'WinDayly', 'Show' )

   IF SETI->i_2 = .T.
      WinDayly.Topmost := .T.
   ENDIF

   ON KEY ALT + F4 ACTION ExitDayly()

   DEFINE NOTIFY MENU
      ITEM 'Show/Hide'           IMAGE 'M_WND' ACTION iif( IsWindowVisible( GetFormHandle( 'WinDayly' ) ), WinDayly.Hide(), WinDayly.Restore() )
      SEPARATOR
      ITEM 'Events control'      IMAGE 'M_DLG' ACTION DaylyEvents()
      ITEM 'Additional settings' IMAGE 'M_SET' ACTION SetDayly()
      SEPARATOR
      ITEM 'Help'                IMAGE 'M_HELP' ACTION _Execute ( GetActiveWindow(), "open", "dayly.chm",  ,  , 1 )
      ITEM 'About'               IMAGE 'M_INFO' ACTION DaylyAbout()
      SEPARATOR
      ITEM 'Exit'                IMAGE 'M_EXIT' ACTION ExitDayly()
   END MENU

   @ 01, 01  IMAGE ImgRG PICTURE PictRG WIDTH 100 HEIGHT 100
   @ 14, 14  LABEL LblName1 WIDTH  80 HEIGHT 20  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR WHITE ;
      ACTION MoveActiveWindow()
   @ 15, 15  LABEL LblName2 WIDTH  80 HEIGHT 20  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR ClrText ;
      ACTION MoveActiveWindow()


   @ 25, 100  LABEL Lblbb WIDTH 87 HEIGHT 28 BACKCOLOR aClr[ 3 ] ;
      ON MOUSEHOVER {|| Rc_Cursor( "MINIGUI_FINGER" ) } ;
      ON CLICK ShellExecute( 0, "open", 'control.exe', 'timedate.cpl', , 1 )
   @ 25, 105  LABEL LblTime WIDTH 60 HEIGHT 27  VALUE Left( Time(), 5 ) ;
      FONT 'Arial' SIZE 18 BOLD  FONTCOLOR aClr[ 1 ] TRANSPARENT
   @ 25, 167  LABEL LblSec WIDTH 20 HEIGHT 26 VALUE Right( Time(), 2 ) ;
      FONT 'Arial' SIZE 11 BOLD  FONTCOLOR aClr[ 1 ] TRANSPARENT

   @ 64, 15   LABEL LblMs  WIDTH 90 HEIGHT 16  VALUE CMonth( Date() ) ;
      FONT 'Times' SIZE 11   FONTCOLOR aClr[ 1 ] BACKCOLOR aClr[ 3 ] CENTERALIGN ;
      ON CLICK DateCale := ClickMonth( 'WinDayly', This.Value ) ;
      ON MOUSEHOVER {|| Rc_Cursor( "MINIGUI_FINGER" ), ( This.FontColor := WHITE ) } ;
      ON MOUSELEAVE {|| ( This.FontColor := aClr[ 1 ] ) }
   @ 64, 105  LABEL LblZ  WIDTH 30 HEIGHT 16  VALUE '' BACKCOLOR aClr[ 3 ]

   @ 64, 135  LABEL lblL2 VALUE Chr( 51 ) WIDTH 15 HEIGHT 16 FONT "WebDings" Size 10 FONTCOLOR aClr[ 1 ]  BACKCOLOR aClr[ 3 ] RIGHTALIGN ;
      ON CLICK DateCale := ClickYear( 'WinDayly', WinDayly.lblYe.Value, '-' ) ;
      ON MOUSEHOVER {|| Rc_Cursor( "MINIGUI_FINGER" ), ( This.FontColor := WHITE ) } ;
      ON MOUSELEAVE ( This.FontColor := aClr[ 1 ] )
   @ 64, 150  LABEL LblYe  WIDTH 30 HEIGHT 16  VALUE '2011' ;
      FONT 'Times' SIZE 11  FONTCOLOR aClr[ 1 ] BACKCOLOR aClr[ 3 ]  CENTERALIGN
   @ 64, 180  LABEL lblM2 VALUE Chr( 52 ) WIDTH 15 HEIGHT 16 FONT "WebDings" Size 10  FONTCOLOR aClr[ 1 ] BACKCOLOR aClr[ 3 ] ;
      ON CLICK DateCale := ClickYear( 'WinDayly', WinDayly.lblYe.Value, '+' ) ;
      ON MOUSEHOVER {|| Rc_Cursor( "MINIGUI_FINGER" ), ( This.FontColor := WHITE ) } ;
      ON MOUSELEAVE ( This.FontColor := aClr[ 1 ] )

   @ 80, 15   LABEL LblLine1  WIDTH 180 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 1 ]

   nRow1 := 85
   nCol1 := 15
   FOR i = 1 TO 7
      cLbl := 'LBLC_' + hb_ntos( i - 1 )
      @ nRow1, nCol1 LABEL &cLbl  VALUE ' ' + acale[ i, 1 ] WIDTH 30 HEIGHT 16 ;
         FONT 'Times' SIZE 11 FontColor iif( i > 5, RED, BLACK ) BACKCOLOR aCLRCale
      nRow1 += 16
   NEXT

   nRow1 := 85
   nCol1 := 45
   FOR i = 2 TO 7
      FOR j = 1 TO 7
         cLbl := 'LBL_' + hb_ntos( i ) + hb_ntos( j )
         @ nRow1, nCol1 LABEL &cLbl  VALUE acale[ j, i ] ACTION ClickDay( 'WinDayly' ) ;
            WIDTH 25 HEIGHT 16  FONT 'Times' SIZE 11  BACKCOLOR aCLRCale CENTERALIGN
         nRow1 += 16
      NEXT
      nRow1 := 85
      nCol1 += 25
   NEXT
   @ 200, 15   LABEL LblLine3  WIDTH 180 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 1 ]

   @ 201, 15   LABEL LblLine4  WIDTH 180 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 3 ]

   @ 215, 35  BUTTONEX btnLY WIDTH 140 HEIGHT 18 CAPTION 'Calendar' ;
      FONT "Arial" SIZE 9  ;
      BACKCOLOR { 255, 164, 44 } NOXPSTYLE FLAT ;
      ACTION ShowListY( DateCale )

   DEFINE TIMER Timer_1 INTERVAL 1000 ACTION TimerDayly()

   LblBox( 'lblW', 0, 0, WinDayly.Height - 1, WinDayly.Width - 1,1, { aClr[ 3 ], aClr[ 3 ] } )

   END WINDOW

   RefreshCale( 'WinDayly', aCale )

   IF SETI->i_1 = .T.
      WinDayly.Show
   ENDIF

   SET TOOLTIP TEXTCOLOR TO WHITE OF WinDayly
   SET TOOLTIP BACKCOLOR TO aClr[ 2 ] OF WinDayly

   ACTIVATE WINDOW WinDayly

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION OpenTable()

   LOCAL aBase := { { "ID_", "C", 10, 0 }, ;
      { "TYPE_","N", 1, 0 }, ;
      { "DATE_","C", 8, 0 }, ;
      { "TIME_","C", 8, 0 }, ;
      { "MESS_","C", 200, 0 }, ;
      { "BLK_","N", 1, 0 } }
   LOCAL i

   LOCAL aSave := { { 1, '01.01', '00:00', 'Happy New Year!' }, ;
      { 2, '1', '00:00', 'Begin of a new month' }, ;
      { 3, '6', '19:00', 'Go to a poker today.' }, ;
      { 4, '0', '10:00', 'Look at http://minisoft.tora.ru' }, ;
      { 5, DToC( Date() ), '00:00', 'Program was installed in this day!' } }

   IF File( PathApp + '\Dayly.dfn' ) = .F.
      dbCreate( PathApp + '\Dayly.dfn', aBase )
      USE DAYLY.DFN NEW
      FOR i = 1 TO Len( aSave )
         DAYLY->( dbAppend() )
         DAYLY->id_ := PadL( AllTrim( Str( i ) ), 10, '0' )
         DAYLY->type_ := aSave[ i, 1 ]
         DAYLY->date_ := aSave[ i, 2 ]
         DAYLY->time_ := aSave[ i, 3 ]
         DAYLY->mess_ := aSave[ i, 4 ]
      NEXT
   ELSE
      USE DAYLY.DFN NEW
   ENDIF

   aDayMess := DayToArray( Date() )

RETURN NIL

//-------------------------------------------------------------\\

STATIC FUNCTION PrazdToArray( cYear )

   LOCAL i, ni
   LOCAL cDM := ''
   LOCAL aPr
   LOCAL lD := .F.
   LOCAL lW := .F.

   IF !File( 'holidays.txt' )
      aPrRF := { { '01.01', [ New Year's Day]},;
         { '20.01', 'Inauguration Day' }, ;
         { '3-1-01', 'Birthday of Martin Luther King' }, ; //the third Monday in January
         { '14.02', [ Valentine's Day]},;
         { '3-1-02', [ Washington's Birthday]},; //the third Monday in February
         { '0-1-05', 'Memorial Day' }, ;         //the last Monday in May
         { '04.07', 'Independence Day' }, ;
         { '1-1-09', 'Labor Day' }, ;            //the first Monday in September
         { '2-1-10', 'Columbus Day' }, ;         //the second Monday in October
         { '11.11', 'Veterans Day' }, ;
         { '4-4-11', 'Thanksgiving Day' }, ;     //the fourth Thursday in November
         { '25.12', 'Christmas Day' } }

      FOR i = 1 TO Len( aPrRF )
         cDM := aPrRF[ i, 1 ]

         IF NUMAT( '.', cDM ) = 1
            lD := .T.
         ENDIF

         IF NUMAT( '-', cDM ) = 2
            cDM := Left( DToC( DayWeekInMonth( cDm, cYear ) ), 5 )
            lW := .T.
         ENDIF

         IF lD = .F. .AND. lW = .F.
            LOOP
         ENDIF

         IF Empty( cDM )
            LOOP
         ENDIF

         aPrRF[ i, 1 ] := cDM
      NEXT
   ELSE
      aPr := hb_ATokens( MemoRead( 'holidays.txt' ), CRLF, .T., .F. )

      aPrRF := {}
      FOR i = 1 TO Len( aPr )
         cDM := Token( aPr[ i ], '*', 1 )

         IF NUMAT( '.', cDM ) = 1
            lD := .T.
         ENDIF

         IF NUMAT( '-', cDM ) = 2
            cDM := Left( DToC( DayWeekInMonth( cDm, cYear ) ), 5 )
            lW := .T.
         ENDIF

         IF lD = .F. .AND. lW = .F.
            LOOP
         ENDIF

         IF Empty( cDM )
            LOOP
         ENDIF

         ni := AScan( aPrRF, {| a| a[ 1 ] = cDM } )
         IF ni = 0
            AAdd( aPrRF, { cDM, Token( aPr[ i ], '*', 2 ) } )
         ELSE
            aPrRF[ ni, 2 ] := aPrRF[ ni, 2 ] + CRLF + Token( aPr[ i ], '*', 2 )
         ENDIF
      NEXT
   ENDIF

RETURN aPrRF

//-------------------------------------------------------------\\

FUNCTION DayWeekInMonth( cP, cYear )  /// 3-5-03

   LOCAL OrdW := Val( Token( cP, '-', 1 ) )
   LOCAL NumW := Val( Token( cP, '-', 2 ) )
   LOCAL NumM := Val( Token( cP, '-', 3 ) )
   LOCAL aWeekDate := {}
   LOCAL ndM, DateR, i

   NumW := iif( NumW = 7, 1, NumW + 1 )

   ndM := LASTDAYOM( NumM )

   FOR i = 1 TO ndM
      DateR := CToD( NToC( i ) + '.' + NToC( NumM ) + '.' + cYear )
      IF  DoW( DateR ) = NumW
         AAdd( aWeekDate, DateR )
      ENDIF
   NEXT

RETURN iif( OrdW = 0, ATail( aWeekDate ), aWeekDate[ OrdW ] )

//-------------------------------------------------------------\\

FUNCTION DayToArray( dDay )

   LOCAL aToDay := {}
   LOCAL cDate := DToC( dDay )
   LOCAL cY := Left( cDate, 5 )
   LOCAL cM := Left( cDate, 2 )
   LOCAL cW := Str( DoW( dDay ), 1 )

   DAYLY->( dbGoTop() )
   * Type, Date, Time, Mess, Blk, Id, lShow
   DO WHILE DAYLY->( !Eof() )

      IF DAYLY->type_ = 1
         IF Left( DAYLY->date_, 5 ) = cY
            AAdd( aToDay, { DAYLY->type_, DAYLY->date_, AllTrim( DAYLY->time_ ), AllTrim( DAYLY->mess_ ), DAYLY->blk_, DAYLY->id_, 0 } )
         ENDIF
      ELSEIF DAYLY->type_ = 2
         IF Left( DAYLY->date_, 2 ) = cM
            AAdd( aToDay, { DAYLY->type_, DAYLY->date_, AllTrim( DAYLY->time_ ), AllTrim( DAYLY->mess_ ), DAYLY->blk_, DAYLY->id_, 0 } )
         ENDIF
      ELSEIF DAYLY->type_ = 3
         IF AllTrim( DAYLY->date_ ) = cW
            AAdd( aToDay, { DAYLY->type_, DAYLY->date_, AllTrim( DAYLY->time_ ), AllTrim( DAYLY->mess_ ), DAYLY->blk_, DAYLY->id_, 0 } )
         ENDIF
      ELSEIF DAYLY->type_ = 4
         IF CToD( AllTrim( DAYLY->date_ ) ) <= Date()
            AAdd( aToDay, { DAYLY->type_, DAYLY->date_, AllTrim( DAYLY->time_ ), AllTrim( DAYLY->mess_ ), DAYLY->blk_, DAYLY->id_, 0 } )
         ENDIF
      ELSEIF DAYLY->type_ = 5
         IF AllTrim( DAYLY->date_ ) = cDate
            AAdd( aToDay, { DAYLY->type_, DAYLY->date_, AllTrim( DAYLY->time_ ), AllTrim( DAYLY->mess_ ), DAYLY->blk_, DAYLY->id_, 0 } )
         ENDIF
      ENDIF
      DAYLY->( dbSkip() )
   ENDDO

RETURN  ASort( aToDay,,, {|x, y| x[ 3 ] < y[ 3 ] } )

//-------------------------------------------------------------\\

FUNCTION TimerDayly()

   LOCAL cTime := Left( Time(), 5 )

   IF nTimerUpDate = 15
      nTimerUpDate := 0
      ShutDn( cTime )
      ApplRun( cTime )
      ShowList( cTime )
   ENDIF

   nTimerUpDate++
   _SetValue( 'LblSec', 'WinDayly', Right( Time(), 2 ) )
   _SetValue( 'LblTime', 'WinDayly', cTime )

   DO EVENTS

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION ShowList( cTime )

   LOCAL cFileSound := FileSound()
   LOCAL nTime1 := Val( Left( cTime, 2 ) + SubStr( cTime, 4, 2 ) )
   LOCAL nTime2
   LOCAL lenD := Len( aDayMess )
   LOCAL nDay := DoW( Date() )
   LOCAL lMess := .F.
   LOCAL lPrzd := .F.
   LOCAL aMess := {}
   LOCAL nRowM := 145
   LOCAL i, clbl, iPr, cDM, nHLbl := 15, LenMess, nCrlf
   LOCAL lNewMess := iif( AScan( aDayMess, {|a| a[ 7 ] = 0 } ) > 0, .T., .F. )

   lTmrM := .F.
   IF LenD = 0
      RETURN NIL
   ENDIF

   IF _IsWindowDefined ( 'WinEdit' ) .OR. _IsWindowDefined ( 'WinSD' ) .OR. _IsWindowDefined ( 'WinExit' )
      RETURN NIL
   ENDIF

   IF SETI->i_7 = .T.                    // holidays
      IF lPrzdShow = .F.
         cDM := Left( DToC( Date() ), 5 )
         iPr := AScan( aPrRF, {| ax| ax[ 1 ] = cDM } )
         IF iPr > 0
            AAdd( aMess, { 'Holiday(s)',0 } )
            AAdd( aMess, { AllTrim( aPrRF[ iPr, 2 ] ),0 } )
            lPrzd := .T.
         ENDIF
         lPrzdShow = .T.
      ENDIF
   ENDIF

   FOR i = 1 TO lenD
      IF aDayMess[ i, 7 ] = 0
         aDayMess[ i, 7 ] := 1
      ENDIF

      IF aDayMess[ i, 5 ] = 0            // don't blocked
         nTime2 := Val( Left( aDayMess[ i, 3 ], 2 ) + SubStr( aDayMess[ i, 3 ], 4, 2 ) )
         IF SETI->i_6 = .T.      // missed event
            IF nTime2 < nTime1 .AND. aDayMess[ i, 7 ] < 2
               AAdd( aMess, { aDayMess[ i, 3 ] + ' ' + AllTrim( aEve[ aDayMess[ i, 1 ] ] ) + ' event  (Missed)',0 } )
               AAdd( aMess, { AllTrim( aDayMess[ i, 4 ] ),0 } )
               lMess := .T.
            ENDIF
         ENDIF

         IF nTime2 = nTime1 .AND. aDayMess[ i, 7 ] < 2
            AAdd( aMess, { aDayMess[ i, 3 ] + ' ' + AllTrim( aEve[ aDayMess[ i, 1 ] ] ) + ' event',0 } )
            AAdd( aMess, { AllTrim( aDayMess[ i, 4 ] ),0 } )
            lMess := .T.
         ENDIF
      ENDIF
   NEXT

   IF lMess = .F. .AND. lPrzd = .F.
      RETURN NIL
   ENDIF

   IF _IsWindowDefined ( 'WinList' )
      IF lNewMess = .F.
         RETURN NIL
      ELSE
         DoMethod( 'WinList', 'Release' )
         DO EVENTS
      ENDIF
   ENDIF


   DEFINE WINDOW WinList AT 10, 20 WIDTH 300 HEIGHT 240 TITLE '' CHILD  NOCAPTION NOSIZE  BACKCOLOR aClr[ 2 ]

   @ 1, 1  IMAGE ImgRG PICTURE PictRG WIDTH 100 HEIGHT 100
   @ 14, 14  LABEL LblName1 WIDTH  280 HEIGHT 20  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR WHITE ;
      ACTION MoveActiveWindow()
   @ 15, 15  LABEL LblName2 WIDTH  280 HEIGHT 20  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR ClrText ;
      ACTION MoveActiveWindow()

   @ 20, 100  LABEL LblDay2 WIDTH 185 HEIGHT 18  VALUE AllTrim( aDay[ nDay ] ) ;
      FONT 'Times' SIZE 12 BOLD FONTCOLOR aClr[ 3 ]  TRANSPARENT RIGHTALIGN ;
      ACTION MoveActiveWindow()
   @ 38, 100  LABEL LblDay1 WIDTH 185 HEIGHT 18  VALUE AllTrim( CMonth( Date() ) ) + ' ' + hb_ntos( Day( Date() ) ) + ', ' + hb_ntos( Year( Date() ) ) ;
      FONT 'Times' SIZE 12 BOLD  FONTCOLOR aClr[ 3 ]  TRANSPARENT RIGHTALIGN ;
      ACTION MoveActiveWindow()

   @ 60, 15   LABEL LblLine1  WIDTH 270 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 3 ]
   @ 61, 15   LABEL LblLine2  WIDTH 270 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 1 ]

   DEFINE WINDOW WinMess ;
      ROW 65 ;
      COL 25 ;
      WIDTH 270;
      HEIGHT 140;
      NOCAPTION ;
      WINDOWTYPE PANEL ;
      BACKCOLOR aClr[ 2 ]

   FOR i = 1 TO Len( aMess )
      clbl := 'm' + hb_ntos( i )
      LenMess := Len( aMess[ i, 1 ] )
      nCrlf := NUMAT( CRLF, aMess[ i, 1 ] )
      IF nCrlf > 0
         nHLbl += 15 * nCrlf
      ELSE
         IF LenMess > 50 .AND. LenMess < 100
            nHLbl := 30
         ELSEIF LenMess > 100
            nHLbl := 45
         ELSE
            nHLbl := 15
         ENDIF
      ENDIF

      IF Mod( i, 2 ) > 0
         @ nRowM, 0  LABEL &clbl WIDTH 270 HEIGHT nHLbl VALUE aMess[ i, 1 ] FONT 'Arial' SIZE 9 FONTCOLOR BLACK TRANSPARENT
         aMess[ i, 2 ] := nRowM
         nRowM += nHLbl
      ELSE
         @ nRowM, 0  LABEL &clbl WIDTH 270 HEIGHT nHLbl VALUE aMess[ i, 1 ] FONT 'Arial' SIZE 9 FONTCOLOR BLACK ITALIC TRANSPARENT
         aMess[ i, 2 ] := nRowM
         nRowM += nHLbl + 10
      ENDIF
   NEXT

   END WINDOW

   LblBox( 'lblBC', 65, 25, 204, 294, 1, { aClr[ 2 ], aClr[ 2 ] } )

   @ 209, 15   LABEL LblLine3  WIDTH 270 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 1 ]
   @ 210, 15   LABEL LblLine4  WIDTH 270 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 3 ]


   @ 215, 80  BUTTONEX btnOk WIDTH 140 HEIGHT 18 CAPTION 'Thank you';
      FONT "Arial" SIZE 9  ;
      BACKCOLOR { 255, 164, 44 } NOXPSTYLE  FLAT;
      ACTION {|| iif( lTmrM, NIL, ( WinList .tmrM. Enabled := .F., ThisWindow.Release() ) )    }

   @ 0, 0 PLAYER PlaySound WIDTH 1 HEIGHT 1 FILE cFileSound

   LblBox( 'lblW', 0, 0, GetProperty( 'WinList', 'HEIGHT' ) -1, GetProperty( 'WinList', 'WIDTH' ) -1,1, { aClr[ 3 ], aClr[ 3 ] } )

   DEFINE TIMER tmrM INTERVAL 150 ACTION TimerM( aMess )

   END WINDOW

   _PlayPlayer( 'PlaySound', 'WinList' )

   ACTIVATE WINDOW WinList

   AEval( aDayMess, {| a | iif( a[ 7 ] = 1, a[ 7 ] := 2, NIL ) } )

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION TimerM( aMess )

   LOCAL i, clbl, nRow
   LOCAL clblEnd := 'm' + hb_ntos( Len( aMess ) )

   ltmrM := .T.
   FOR i = 1 TO Len( aMess )
      clbl := 'm' + hb_ntos( i )

      IF GetProperty( 'WinMess', clblEND, 'ROW' ) <= -20
         SetProperty( 'WinMess', clbl, 'ROW', aMess[ i, 2 ] )
      ELSE
         nRow := GetProperty( 'WinMess', clbl, 'ROW' )
         SetProperty( 'WinMess', clbl, 'ROW', nRow - 2 )
      ENDIF
      DO EVENTS
   NEXT
   ltmrM := .F.

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION FileSound()

   LOCAL i
   LOCAL cFileSound
   LOCAL aTypeSound := { '.wav', '.mid', '.mp3' }

   IF SETI->i_3 = .T.
      FOR i = 1 TO Len( aTypeSound )
         cFileSound := 'Dayly' + aTypeSound[ i ]
         IF File( cFileSound )
            RETURN cFileSound
         ENDIF
      NEXT
      PlayOk()
   ENDIF

RETURN ''

//-------------------------------------------------------------\\

FUNCTION ShowListY( DateCale )

   LOCAL i, j, cWinY, nRow1, nCol1, nM, cLbl, cDM, cLb, iPrazd
   LOCAL nRow := 70
   LOCAL nCol := 20
   LOCAL aCaleY
   LOCAL cYear := hb_ntos( Year( DateCale ) )
   LOCAL aPrTT := PrazdToArray( cYear )

   aHDay := Array( 12 )
   AFill( aHDay, '' )

   aHDay[ 1 ] := '1,'
   IF !File( 'holidays.txt' )
      aHDay[ 1 ] += Left( DToC( DayWeekInMonth( '3-1-01', cYear ) ), 2 )
      aHDay[ 2 ] := Left( DToC( DayWeekInMonth( '3-1-02', cYear ) ), 2 )
      aHDay[ 5 ] := Left( DToC( DayWeekInMonth( '0-1-05', cYear ) ), 2 )
      aHDay[ 7 ] := '4'
      aHDay[ 9 ] := Left( DToC( DayWeekInMonth( '1-1-09', cYear ) ), 2 )
      aHDay[ 10 ] := Left( DToC( DayWeekInMonth( '2-1-10', cYear ) ), 2 )
      aHDay[ 11 ] := '11,' + Left( DToC( DayWeekInMonth( '4-4-11', cYear ) ), 2 )
   ENDIF
   aHDay[ 12 ] := '25'

   DO EVENTS
   FOR i = 1 TO 100
      cWinY := 'WinY' + hb_ntos( i )
      IF _IsWindowDefined ( cWinY ) = .F.
         EXIT
      ENDIF
   NEXT

   DEFINE WINDOW &cWinY AT i * 10, i * 10  WIDTH 762 HEIGHT 480  TITLE cNameApp ;
      CHILD NOCAPTION NOSIZE NOMAXIMIZE ICON 'dayly' BACKCOLOR aClr[ 2 ]


   @ 1, 1  IMAGE ImgFonT PICTURE PictRG WIDTH 100 HEIGHT 100

   @ 14, 14  LABEL LblName1 WIDTH  80 HEIGHT 20  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR WHITE ;
      ACTION MoveActiveWindow()

   @ 15, 15  LABEL LblName2 WIDTH  80 HEIGHT 20  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR ClrText ;
      ACTION MoveActiveWindow()

   @ 15, 95   LABEL LblY2 WIDTH GetProperty( cWinY, 'Width' ) -130 HEIGHT 25  VALUE 'Calendar for ' + cYear + ' Year' ;
      FONT 'Verdana' SIZE 14  FONTCOLOR aClr[ 3 ] BOLD TRANSPARENT CENTERALIGN ;
      ACTION MoveActiveWindow()

   @ 5, GetProperty( cWinY, 'Width' ) -25  LABEL btnCancel WIDTH 24 HEIGHT 25  VALUE Chr( 251 )  ;
      FONT 'Wingdings' SIZE 24 FONTCOLOR { 196, 0, 0 } BACKCOLOR aClr[ 2 ] ;
      ON MOUSEHOVER ( Rc_Cursor( "MINIGUI_FINGER" ), This.FontColor := { 255, 96, 96 } ) ;
      ON MOUSELEAVE ( This.FontColor := { 196, 0, 0 } ) ;
      ACTION ThisWindow.Release()

   @ 40, 110  LABEL LblLine1 WIDTH  630 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 3 ]
   @ 41, 110  LABEL LblLine2 WIDTH  630 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 1 ]


   FOR nM = 1 TO 12
      IF nM = 5
         nRow := 210
         nCol := 20
      ELSEIF nM = 9
         nRow := 350
         nCol := 20
      ENDIF
      nRow1 := nRow
      nCol1 := nCol
      aCaleY := CaleToArray( CToD( '01.' + hb_ntos( nM ) + '.' + cYear ) )
      cLB := 'M' + hb_ntos( nM )
      @ nRow1 - 20, nCol1 + 120 LABEL &cLb   VALUE aMS[ nM ] WIDTH 90 HEIGHT 20 ;
         FONT 'Times' SIZE 12   BACKCOLOR aClr[ 2 ] CENTERALIGN
      IF nM = 1 .OR. nM = 5 .OR. nM = 9
         FOR i = 2 TO 7
            cLbl := cLB + 'LBLC_' + hb_ntos( i )
            @ nRow1, nCol1 LABEL &cLbl   VALUE aDay[ i ] WIDTH 90 HEIGHT 15 ;
               FONT 'Times' SIZE 11 FontColor iif( i = 7, { 200, 0, 0 }, BLACK ) BACKCOLOR aClr[ 2 ]
            nRow1 += 16
         NEXT
         cLbl := cLB + 'LBLC_1'
         @ nRow1, nCol1 LABEL &cLbl   VALUE aDay[ 1 ] WIDTH 90 HEIGHT 15 ;
            FONT 'Times' SIZE 11  FontColor { 200, 0, 0 } BACKCOLOR aClr[ 2 ]
      ENDIF

      nRow1 := nRow
      nCol1 := nCol + 90
      FOR i = 2 TO 7
         FOR j = 1 TO 7
            cLbl := cLB + 'LBL_' + hb_ntos( i ) + hb_ntos( j )
            @ nRow1, nCol1 LABEL &cLbl  VALUE acaleY[ j, i ] WIDTH 24 HEIGHT 15 ;
               FONT 'Times' SIZE 10 FONTCOLOR iif( j > 5, RED, BLACK ) BACKCOLOR aClr[ 1 ] CENTERALIGN ;
               ON MOUSEHOVER ( This.BackColor := WHITE ) ;
               ON MOUSELEAVE ( This.BackColor := aClr[ 1 ] )
            IF ItsHDay( nM, acaleY[ j, i ] ) = .T.
               SetProperty( cWinY, cLbl, 'FONTCOLOR', RED )
            ENDIF

            cDM := PadL( AllTrim( acaleY[ j, i ] ), 2, '0' ) + '.' + PadL( NToC( nM ), 2, '0' )
            iPrazd := AScan( aPrTT, {| ax| ax[ 1 ] = cDM } )
            IF iPrazd > 0
               _SetToolTip( clbl, cWinY, cDM + '.' + cYear + CRLF + aPrRF[ iPrazd, 2 ] )
               SetProperty( cWinY, cLbl, 'FONTBOLD', .T. )
            ENDIF

            nRow1 += 16
         NEXT
         nRow1 := nRow
         nCol1 += 25
      NEXT
      nCol += 160
   NEXT

   LblBox( 'lblW', 0, 0, GetProperty( cWinY, 'HEIGHT' ) -1, GetProperty( cWinY, 'WIDTH' ) -1,1, { aClr[ 3 ], aClr[ 3 ] } )

   END WINDOW

   SET TOOLTIP TEXTCOLOR TO RED OF &cWinY
   SET TOOLTIP BACKCOLOR TO WHITE OF &cWinY

   ACTIVATE WINDOW &cWinY

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION ItsHDay( nM, nD )

   LOCAL nTok := NumToken( aHDay[ nM ], ',' )
   LOCAL iT

   FOR iT = 1 TO nTok
      IF Val( Token( aHDay[ nM ], ',', iT ) ) = Val( nD )
         RETURN .T.
      ENDIF
   NEXT

RETURN .F.

//-------------------------------------------------------------\\

FUNCTION CaleToArray( DateCale )

   LOCAL FirstDay := CToD( '01.' + Str( Month( DateCale ) ) + '.' + Str( Year( DateCale ) ) )
   LOCAL fd := iif( DoW( FirstDay ) = 1, 7, DoW( FirstDay ) -1 )
   LOCAL Ld := LastDayOM( FirstDay )   // quantity of days in month
   LOCAL nd := 1
   LOCAL lk := .F.
   LOCAL aCal := Array( 7, 7 )
   LOCAL i, j

   FOR i = 2 TO 7
      acal[ i - 1, 1 ] := Left( aDay[ i ], 2 )
   NEXT
   acal[ 7, 1 ] := Left( aDay[ 1 ], 2 )
   FOR i = 1 TO 7
      FOR j = 2 TO 7
         acal[ i, j ] = ' '
      NEXT
   NEXT
   FOR i = 2 TO 7
      FOR j = fd TO 7
         IF nd > LD
            lk := .T.
            EXIT
         ENDIF
         acal[ j, i ] := Str( nd, 2 )
         nd++
      NEXT
      fd := 1
      IF lk = .T.
         EXIT
      ENDIF
   NEXT

RETURN aCal

//-------------------------------------------------------------\\

FUNCTION RefreshCale( cWin, aCale )

   LOCAL nD, cLbl
   LOCAL i, j

   nD := Day( DateCale )
   FOR i = 2 TO 7
      FOR j = 1 TO 7
         cLbl := 'LBL_' + hb_ntos( i ) + hb_ntos( j )
         SetProperty( cWin, cLbl, 'VALUE', aCale[ j, i ] )
         SetProperty( cWin, cLbl, 'FONTSIZE', 9 )
         IF j > 5
            SetProperty( cWin, cLbl, 'FONTCOLOR', { 255, 0, 0 } )
         ELSE
            SetProperty( cWin, cLbl, 'FONTCOLOR', BLACK )
         ENDIF
         SetProperty( cWin, cLbl, 'BACKCOLOR', aCLRCale )
         SetProperty( cWin, cLbl, 'FONTBOLD', .F. )

         IF Val( acale[ j, i ] ) = nD
            SetProperty( cWin, cLbl, 'FONTSIZE', 10 )
            SetProperty( cWin, cLbl, 'FONTCOLOR', aClr[ 2 ] )
            SetProperty( cWin, cLbl, 'BACKCOLOR', aClr[ 3 ] )
            SetProperty( cWin, cLbl, 'FONTBOLD', .T. )
         ENDIF
      NEXT
   NEXT

   SetProperty( cWin, 'LblMs', 'VALUE', aMs[ Month( DateCale ) ] )
   SetProperty( cWin, 'LblYe', 'VALUE', Str( Year( DateCale ), 4 ) )

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION ClickDay( cWin )

   LOCAL nM := Month( DateCale )
   LOCAL nY := Year( DateCale )

   IF Empty( This.Value ) = .F.
      DateCale := CToD( This.Value + '.' + Str( nM ) + '.' + Str( nY ) )
      RefreshCale( cWin, aCale )
   ENDIF

RETURN DateCale

//-------------------------------------------------------------\\

FUNCTION ClickMonth( cWin, cMs )

   LOCAL nD := Day( DateCale )
   LOCAL nY := Year( DateCale )
   LOCAL NewM := AScan( aMs, cMs )
   LOCAL nLastDay

   NewM := iif( NewM >= 12, 1, NewM + 1 )
   nLastDay := LASTDAYOM( NewM )
   nD := iif( nD < nLastDay, nD, nLastDay )
   DateCale = CToD( Str( nD ) + '.' + Str( NewM ) + '.' + Str( nY ) )
   aCale := CaleToArray( DateCale )

   RefreshCale( cWin, aCale )

RETURN DateCale

//-------------------------------------------------------------\\

FUNCTION ClickYear( cWin, cYe, cMod )

   LOCAL nD := Day( DateCale )
   LOCAL nM := Month( DateCale )
   LOCAL NewYear := Val( cYe )

   IF cMod = "+"
      NewYear := NewYear + 1
   ELSEIF cMod = "-"
      NewYear := NewYear - 1
   ENDIF
   DateCale = CToD( Str( nD ) + '.' + Str( nM ) + '.' + Str( NewYear ) )

   aCale := CaleToArray( DateCale )
   RefreshCale( cWin, aCale )

RETURN DateCale

//-------------------------------------------------------------\\

FUNCTION ExitDayly()

   LOCAL lOk := .F.

   SetProperty( 'WinDayly', 'Timer_1', 'ENABLED', .F. )

   DEFINE WINDOW WinExit AT 0, 0 WIDTH 300 HEIGHT 110  MODAL  NOSIZE NOCAPTION  BACKCOLOR aClr[ 2 ]

   @ 1, 1  IMAGE ImgRG PICTURE PictRG WIDTH 100 HEIGHT 100

   @ 14, 14  LABEL LblName1 WIDTH WinExit.Width - 15 HEIGHT 22  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR WHITE ;
      ACTION MoveActiveWindow()
   @ 15, 15  LABEL LblName2 WIDTH WinExit.Width - 15 HEIGHT 22 VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR ClrText ;
      ACTION MoveActiveWindow()


   @ 40, 10  LABEL LblTit WIDTH 280 HEIGHT 25  VALUE 'Terminate the program execution' ;
      FONT 'Times' SIZE 12 BOLD FONTCOLOR BLACK  TRANSPARENT  CENTERALIGN

   @ 70, 15   LABEL LblLine3  WIDTH 270 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 1 ]

   @ 71, 15   LABEL LblLine4  WIDTH 270 HEIGHT 1  VALUE '' BACKCOLOR aClr[ 3 ]

   @ 85, 45  BUTTONEX btnOk WIDTH 100 HEIGHT 18 CAPTION 'Terminate' ;
      FONT "Arial" SIZE 9 ;
      BACKCOLOR { 255, 164, 44 } NOXPSTYLE FLAT ;
      ACTION ( lOk := .T., WinExit.Release() )

   @ 85, 155  BUTTONEX btnCans WIDTH 100 HEIGHT 18 CAPTION 'Cancel' ;
      FONT "Arial" SIZE 9 ;
      BACKCOLOR { 255, 164, 44 } NOXPSTYLE FLAT ;
      ACTION WinExit.Release()

   LblBox( 'lblW', 0, 0, WinExit.Height - 1, WinExit.Width - 1,1, { aClr[ 3 ], aClr[ 3 ] } )

   END WINDOW

   CENTER WINDOW WinExit
   ACTIVATE WINDOW WinExit

   IF lOk = .T.
      CLOSE ALL
      WinDayly.Release()
      RETURN NIL
   ENDIF

   SetProperty( 'WinDayly', 'Timer_1', 'ENABLED', .T. )

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION ApplRun( cTime )

   LOCAL nTime1 := Val( Left( cTime, 2 ) + SubStr( cTime, 4, 2 ) )
   LOCAL nTime2

   IF SETI->lar_1
      nTime2 := Val( Left( SETI->tar_1, 2 ) + SubStr( SETI->tar_1, 4, 2 ) )
      IF nTime2 = nTime1
         ShellExecute( 0, "open", AllTrim( SETI->nar_1 ), , , 1 )
         RETURN NIL
      ENDIF
   ENDIF

   IF SETI->lar_2
      nTime2  := Val( Left( SETI->tar_2, 2 ) + SubStr( SETI->tar_2, 4, 2 ) )
      IF nTime2 = nTime1
         ShellExecute( 0, "open", AllTrim( SETI->nar_2 ), , , 1 )
         RETURN NIL
      ENDIF
   ENDIF

   IF SETI->lar_3
      nTime2  := Val( Left( SETI->tar_3, 2 ) + SubStr( SETI->tar_3, 4, 2 ) )
      IF nTime2 = nTime1
         ShellExecute( 0, "open", AllTrim( SETI->nar_2 ), , , 1 )
         RETURN NIL
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------\\

#define EWX_LOGOFF 0   // отключение от сети
#define EWX_SHUTDOWN 1
#define EWX_REBOOT 2
#define EWX_FORCE 4
#define EWX_POWEROFF 8

//-------------------------------------------------------------\\

FUNCTION ShutDn( cTime )

   LOCAL aL := { 'Shutdown the computer in 30 seconds', 'Reboot your computer in 30 seconds', 'LogOff after 30 seconds' }
   LOCAL nTime1 := Val( Left( cTime, 2 ) + SubStr( cTime, 4, 2 ) )
   LOCAL nTime2

   IF SETI->lsd_3
      nTime2 := Val( Left( SETI->tsd_3, 2 ) + SubStr( SETI->tsd_3, 4, 2 ) )
      IF nTime2 = nTime1
         ShutDnShow( 0, aL[ 3 ] )
         RETURN NIL
      ENDIF
   ENDIF

   IF SETI->lsd_2
      nTime2 := Val( Left( SETI->tsd_2, 2 ) + SubStr( SETI->tsd_2, 4, 2 ) )
      IF nTime2 = nTime1
         ShutDnShow( 2, aL[ 2 ] )
         RETURN NIL
      ENDIF
   ENDIF

   IF SETI->lsd_1
      nTime2 := Val( Left( SETI->tsd_1, 2 ) + SubStr( SETI->tsd_1, 4, 2 ) )
      IF nTime2 = nTime1
         ShutDnShow( 1, aL[ 1 ] )
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION ShutDnShow( nFlag, Tit )

   nSec := 0
   lPowerOff := .T.
   lForceMode := .T.
   lTimeShdOk := .T.

   SetProperty( 'WinDayly', 'Timer_1', 'ENABLED', .F. )

   DEFINE WINDOW WinSD AT 0, 0 WIDTH 320 HEIGHT 150  MODAL  NOSIZE NOCAPTION  BACKCOLOR aClr[ 2 ]

   @ 1, 1  IMAGE ImgRG PICTURE PictRG WIDTH 100 HEIGHT 100 ;
      ACTION MoveActiveWindow()
   @ 14, 14  LABEL LblName1 WIDTH WinSD.Width - 15 HEIGHT 22  VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR WHITE ;
      ACTION MoveActiveWindow()
   @ 15, 15  LABEL LblName2 WIDTH WinSD.Width - 15 HEIGHT 22 VALUE cNameApp TRANSPARENT ;
      FONT 'Times' SIZE 14 FONTCOLOR ClrText ;
      ACTION MoveActiveWindow()

   @ 50, 10  LABEL LblTit WIDTH 300 HEIGHT 25  VALUE Tit ;
      FONT 'Times' SIZE 11  FONTCOLOR BLACK TRANSPARENT  CENTERALIGN

   @ 80, 40  LABEL LblL WIDTH 240 HEIGHT 22  VALUE '' BACKCOLOR aClr[ 1 ]
   @ 82, 42  LABEL LblL1 WIDTH 0 HEIGHT 18  VALUE '' BACKCOLOR { 255, 0, 0 }
   @ 82, 40  LABEL LblL2 WIDTH 240 HEIGHT 18  VALUE '30' ;
      FONT 'Arial' SIZE 12 BOLD  TRANSPARENT CENTERALIGN

   LblBox( 'lblW1', 80, 40, 101, 280, 1, { aClr[ 3 ], aClr[ 3 ] } )

   @ 120, 90  BUTTONEX btnLY WIDTH 140 HEIGHT 18 CAPTION 'Cancel' ;
      FONT "Arial" SIZE 9 ;
      BACKCOLOR { 255, 164, 44 } NOXPSTYLE  FLAT ;
      ACTION ( lTimeShdOk := .F., WinSD.Release() )

      DEFINE TIMER Timer_1 INTERVAL 1000 ACTION OnTimerShD()

   LblBox( 'lblW', 0, 0, WinSD.Height - 1, WinSD.Width - 1,1, { aClr[ 3 ], aClr[ 3 ] } )

   END WINDOW

   WinSd.lblTit.SetFocus()
   CENTER WINDOW WinSD
   ACTIVATE WINDOW WinSD

   SetProperty( 'WinDayly', 'Timer_1', 'ENABLED', .T. )
   IF lTimeShdOk = .T.
      WinExit( nFlag )
   ENDIF

RETURN NIL

//-------------------------------------------------------------\\

#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow( hWnd )
   DEFAULT hWnd := GetActiveWindow()
   PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )

RETURN

//-------------------------------------------------------------\\

FUNCTION LblBox( cLbl, nR1, nC1, nR2, nC2, nT, aClrB )
   * LblBox( 'lblb', 10, 10, 484, 755, 2, { { 128, 128, 126 }, { 128, 128, 128 } } )

   @ nR1, nC1  LABEL  &( cLbl + '1' )  WIDTH  nC2 - nC1 HEIGHT nT             VALUE ''  BACKCOLOR aClrB[ 1 ]
   @ nR1, nC1  LABEL  &( cLbl + '2' )  WIDTH  nT        HEIGHT nR2 - nR1      VALUE ''  BACKCOLOR aClrB[ 1 ]
   @ nR2, nC1  LABEL  &( cLbl + '3' )  WIDTH  nC2 - nC1 HEIGHT nT             VALUE ''  BACKCOLOR aClrB[ 2 ]
   @ nR1, nC2  LABEL  &( cLbl + '4' )  WIDTH  nT        HEIGHT nR2 - nR1 + nT VALUE ''  BACKCOLOR aClrB[ 2 ]

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION OnTimerShD()
   nSec++
   WinSd.lblL1.Width := WinSd.lblL1.Width + 8
   WinSd.lblL2.Value := AllTrim( Str( Val( WinSd.lblL2.Value ) -1 ) )
   IF nSec = 30
      WinSD.Release
   ENDIF

RETURN NIL

//-------------------------------------------------------------\\
PROCEDURE WinExit( nFlag )
//-------------------------------------------------------------\\

   IF IsWinNT()
      EnablePermissions()
   ENDIF
   DO CASE
   CASE nFlag = 1
      nFlag := EWX_SHUTDOWN
      IF lPowerOff
         nFlag += EWX_POWEROFF
      ENDIF
   CASE nFlag = 2
      nFlag := EWX_REBOOT
   CASE nFlag = 3
      nFlag := EWX_LOGOFF
   ENDCASE

   IF lForceMode
      nFlag += EWX_FORCE
   ENDIF

   IF !ExitWindowsEx( nFlag, 0 )
      // ShowError()
   ELSE
      ReleaseAllWindows()
   ENDIF

RETURN


#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

HB_FUNC( ENABLEPERMISSIONS )

{
   LUID tmpLuid;
   TOKEN_PRIVILEGES tkp, tkpNewButIgnored;
   DWORD lBufferNeeded;
   HANDLE hdlTokenHandle;
   HANDLE hdlProcessHandle = GetCurrentProcess();

   OpenProcessToken(hdlProcessHandle, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hdlTokenHandle);

   LookupPrivilegeValue(NULL, "SeShutdownPrivilege", &tmpLuid);

   tkp.PrivilegeCount            = 1;
   tkp.Privileges[0].Luid        = tmpLuid;
   tkp.Privileges[0].Attributes  = SE_PRIVILEGE_ENABLED;

   AdjustTokenPrivileges(hdlTokenHandle, FALSE, &tkp, sizeof(tkpNewButIgnored), &tkpNewButIgnored, &lBufferNeeded);
}

HB_FUNC( EXITWINDOWSEX )

{
   hb_retl( ExitWindowsEx( (UINT) hb_parni( 1 ), (DWORD) hb_parnl( 2 ) ) );
}

#pragma ENDDUMP
