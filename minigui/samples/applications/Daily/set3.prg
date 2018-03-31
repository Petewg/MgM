#include 'minigui.ch'

MEMVAR cNameApp
MEMVAR FileExe
MEMVAR cVer
MEMVAR cWWW
MEMVAR PathApp
MEMVAR PathDTop
MEMVAR PathStUp
MEMVAR DateCale

MEMVAR aRegInfo

MEMVAR aClr
MEMVAR aColorsDayly

MEMVAR aDay
MEMVAR aDayMess
MEMVAR aEve

MEMVAR ClrText
MEMVAR PictRG

//-------------------------------------------------------------\\

FUNCTION DaylyEvents()

   LOCAL bfrColor := {| vl| iif( Val( vl[ 5 ] ) = 1, RGB( 164, 64, 64 ), RGB( 0, 0, 0 ) ) }
   LOCAL GrW := 765

   IF _IsWindowDefined ( 'WinEvent' ) = .T.
      RETURN NIL
   ENDIF


   DEFINE WINDOW WinEvent AT 0, 0 WIDTH 800 HEIGHT 480 ;
      TITLE cNameApp ICON 'MAIN' ;
      CHILD ;
      NOSIZE NOMAXIMIZE NOMINIMIZE

   ON KEY ESCAPE ACTION ThisWindow.Release()

   @ 20, 80   LABEL LblY2 WIDTH GetProperty( 'WinEvent', 'Width' ) -140 HEIGHT 25  VALUE 'Events control' ;
      FONT 'Verdana' SIZE 10 BOLD FONTCOLOR BLACK TRANSPARENT CENTERALIGN ;

      DEFINE TAB Tab_1 AT 45, 10 WIDTH 778 HEIGHT WinEvent.Height - 110 VALUE 1 FONT "Arial" SIZE 9 ;
      ON CHANGE ChangePage( This.Value )


   PAGE 'Today ' IMAGE "TP1"
   @ 40, 20 LABEL lblToDay HEIGHT 20 WIDTH 200 VALUE 'Events on ' + DToC( Date() ) + ' year'
   @ 60, 5  LABEL lblGC1 HEIGHT 20 WIDTH GrW VALUE '' TRANSPARENT

   DEFINE GRID Grid1
      ROW  60
      COL 5
      WIDTH GrW
      HEIGHT WinEvent.Height - 180
      WIDTHS { 100, 0, 70, 575, 0, 0 }
      HEADERS { ' Type', '', 'Time', 'Message text', '', '' }
      VALUE 1
      JUSTIFY { 0, 2, 2 }
      FONTSIZE 9
      DYNAMICFORECOLOR { bfrColor, bfrColor, bfrColor, bfrColor, bfrColor, bfrColor }
   END GRID

   END PAGE


   PAGE 'On date      ' IMAGE "TP2"
   @ 40, 20 LABEL lblSelDate HEIGHT 20 WIDTH 200 VALUE 'Events on ' + DToC( DateCale ) + ' year'
   @ 60, 5  LABEL lblGC2 HEIGHT 20 WIDTH GrW VALUE '' TRANSPARENT

   DEFINE GRID Grid2
      ROW  60
      COL 5
      WIDTH GrW
      HEIGHT WinEvent.Height - 180
      WIDTHS { 100, 0, 70, 575, 0, 0 }
      HEADERS { ' Type', '', 'Time', 'Message text', '', '' }
      VALUE 1
      JUSTIFY { 0, 2, 2 }
      FONTSIZE 9
      DYNAMICFORECOLOR { bfrColor, bfrColor, bfrColor, bfrColor, bfrColor, bfrColor }
   END GRID
   END PAGE


   PAGE aEve[ 1 ] + ' ' IMAGE "TP3"
   @ 40, 20 LABEL lblYear HEIGHT 20 WIDTH 200 VALUE aEve[ 1 ] + ' events'
   @ 60, 5  LABEL lblGC3 HEIGHT 20 WIDTH GrW VALUE '' TRANSPARENT

   DEFINE GRID Grid3
      ROW  60
      COL 5
      WIDTH GrW
      HEIGHT WinEvent.Height - 180
      WIDTHS { 0, 100, 70, 575, 0, 0 }
      HEADERS { '', 'Day Month', 'Time', 'Message text', '', '' }
      VALUE 1
      JUSTIFY { 0, 2, 2 }
      FONTSIZE 9
      DYNAMICFORECOLOR { bfrColor, bfrColor, bfrColor, bfrColor, bfrColor, bfrColor }
   END GRID
   END PAGE


   PAGE aEve[ 2 ] + ' ' IMAGE "TP4"
   @ 40, 20 LABEL lblMonth HEIGHT 20 WIDTH 200 VALUE aEve[ 2 ] + ' events'
   @ 60, 5  LABEL lblGC4 HEIGHT 20 WIDTH GrW VALUE '' TRANSPARENT

   DEFINE GRID Grid4
      ROW  60
      COL 5
      WIDTH GrW
      HEIGHT WinEvent.Height - 180
      WIDTHS { 0, 70, 70, 600, 0, 0 }
      HEADERS { '', 'Day', 'Time', 'Message text', '', '' }
      VALUE 1
      JUSTIFY { 0, 2, 2 }
      FONTSIZE 9
      DYNAMICFORECOLOR { bfrColor, bfrColor, bfrColor, bfrColor, bfrColor, bfrColor }
   END GRID
   END PAGE


   PAGE aEve[ 3 ] + ' ' IMAGE "TP5"
   @ 40, 20 LABEL lblWeek HEIGHT 20 WIDTH 200 VALUE aEve[ 3 ] + ' events'
   @ 60, 5  LABEL lblGC5 HEIGHT 20 WIDTH GrW VALUE '' TRANSPARENT

   DEFINE GRID Grid5
      ROW  60
      COL 5
      WIDTH GrW
      HEIGHT WinEvent.Height - 180
      WIDTHS { 0, 100, 70, 575, 0, 0 }
      HEADERS { '', 'Day', 'Time', 'Message text', '', '' }
      VALUE 1
      JUSTIFY { 0, 2, 2 }
      FONTSIZE 9
      DYNAMICFORECOLOR { bfrColor, bfrColor, bfrColor, bfrColor, bfrColor, bfrColor }
   END GRID
   END PAGE


   PAGE aEve[ 4 ] + ' ' IMAGE "TP6"
   @ 40, 20 LABEL lblAlarm HEIGHT 20 WIDTH 200 VALUE aEve[ 4 ] + ' events'
   @ 60, 5  LABEL lblGC6 HEIGHT 20 WIDTH GrW VALUE '' TRANSPARENT

   DEFINE GRID Grid6
      ROW  60
      COL 5
      WIDTH GrW
      HEIGHT WinEvent.Height - 180
      WIDTHS { 0, 0, 70, 660, 0, 0 }
      HEADERS { '', '', 'Time', 'Message text', '', '' }
      VALUE 1
      JUSTIFY { 0, 2, 2 }
      FONTSIZE 9
      DYNAMICFORECOLOR { bfrColor, bfrColor, bfrColor, bfrColor, bfrColor, bfrColor }
   END GRID
   END PAGE


   PAGE aEve[ 5 ] + ' ' IMAGE "TP7"
   @ 40, 20 LABEL lblDate HEIGHT 20 WIDTH 200 VALUE aEve[ 5 ] + ' events'
   @ 60, 5  LABEL lblGC7 HEIGHT 20 WIDTH GrW VALUE '' TRANSPARENT

   DEFINE GRID Grid7
      ROW  60
      COL 5
      WIDTH GrW
      HEIGHT WinEvent.Height - 180
      WIDTHS { 0, 100, 70, 565, 0, 0 }
      HEADERS { '', 'Date', 'Time', 'Message text', '', '' }
      VALUE 1
      JUSTIFY { 0, 2, 2 }
      FONTSIZE 9
      DYNAMICFORECOLOR { bfrColor, bfrColor, bfrColor, bfrColor, bfrColor, bfrColor }
   END GRID
   END PAGE

   END TAB

   @ 420, 450  BUTTON btnAdd  CAPTION 'Add event'   ACTION EditMess( 0 ) WIDTH 100 HEIGHT 22  FONT "Arial" SIZE 9
   @ 420, 555  BUTTON btnEdit CAPTION 'Open event'  ACTION EditMess( 1 ) WIDTH 100 HEIGHT 22  FONT "Arial" SIZE 9
   @ 420, 660  BUTTON btnDel  CAPTION 'Erase event' ACTION DelMess( 0 )  WIDTH 100 HEIGHT 22  FONT "Arial" SIZE 9

   END WINDOW

   ChangePage( 1 )

   SET TOOLTIP TEXTCOLOR TO WHITE OF WinEvent
   SET TOOLTIP BACKCOLOR TO aClr[ 3 ] OF WinEvent

   CENTER WINDOW  WinEvent
   ACTIVATE WINDOW WinEvent

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION ChangePage( nPage )

   LOCAL aBrw := {}
   LOCAL GridName := 'Grid' + hb_ntos( nPage )
   LOCAL i

   DAYLY->( dbGoTop() )
   * aBrw Type, Date, Time, Mess, Blk, Id

   IF nPage > 2
      IF nPage = 5             //week
         DAYLY->( dbEval( {|| AAdd( aBrw, { hb_ntos( DAYLY->type_ ), aDay[ Val( DAYLY->date_ ) ],  AllTrim( DAYLY->time_ ), AllTrim( DAYLY->mess_ ), hb_ntos( DAYLY->blk_ ), DAYLY->id_ } ) }, {|| DAYLY->type_ = nPage - 2 } ) )
      ELSE
         DAYLY->( dbEval( {|| AAdd( aBrw, { hb_ntos( DAYLY->type_ ), AllTrim( DAYLY->date_ ),  AllTrim( DAYLY->time_ ), AllTrim( DAYLY->mess_ ), hb_ntos( DAYLY->blk_ ), DAYLY->id_ } ) }, {|| DAYLY->type_ = nPage - 2 } ) )
      ENDIF
      WinEvent .btnAdd. Enabled := .T.
      WinEvent .btnEdit. Enabled := .T.
      WinEvent .btnDel. Enabled := .T.
   ELSE
      IF nPage = 1
         aBrw := AClone( aDayMess )
      ELSEIF nPage = 2
         aBrw := DayToArray( DateCale )
      ENDIF
      WinEvent .btnAdd. Enabled := .F.
      WinEvent .btnEdit. Enabled := .F.
      WinEvent .btnDel. Enabled := .F.
   ENDIF

   ASort( aBrw,,, {|x, y| x[ 3 ] < y[ 3 ] } )

   AEval( aBrw, {| a| a[ 4 ] := StrTran( a[ 4 ], CRLF, ' ' ) } )

   DELETE ITEM ALL FROM &GridName OF WinEvent

   IF nPage > 2
      FOR i = 1 TO Len( aBrw )
         ADD ITEM aBrw[ i ] TO &GridName OF WinEvent
      NEXT
   ELSE
      FOR i = 1 TO Len( aBrw )
         ADD ITEM { aEve[ aBrw[ i, 1 ] ], aBrw[ i, 2 ], aBrw[ i, 3 ], aBrw[ i, 4 ], aBrw[ i, 5 ], aBrw[ i, 6 ] } TO &GridName OF WinEvent
      NEXT

   ENDIF

   SetProperty( 'WinEvent', GridName, 'VALUE', 1 )

RETURN NIL

//----------------------------------------\\

FUNCTION EditMess( nMod )
   * nMod 0 -New 1 -Edit
   LOCAL nPage := WinEvent .Tab_1. Value
   LOCAL GridName := 'Grid' + hb_ntos( nPage )
   LOCAL nRow := _GetValue( GridName, 'WinEvent' )
   LOCAL aRow := GetProperty( 'WinEvent', GridName, 'ITEM', nRow )
   LOCAL cDateForm := 'dd.MM.yy'
   LOCAL cLabel := ''
   LOCAL aS := { '', '', aEve[ 1 ] + ' event', aEve[ 2 ] + ' event', aEve[ 3 ] + ' event', aEve[ 4 ] + ' event', aEve[ 5 ] + ' event' }
   LOCAL aNoYes := { '   No', '   Yes' }

   LOCAL DateVal, TimeVal, MessVal, BlkVal

   IF nMod = 0
      IF nPage = 5
         DateVal := 1
      ELSE
         DateVal := DateCale
      ENDIF
      TimeVal := Time()
      MessVal := ''
      BlkVal := 1
   ELSE
      IF nPage = 5
         DateVal := AScan( aDay, aRow[ 2 ] )
      ELSE
         DateVal := CToD( aRow[ 2 ] )
      ENDIF
      TimeVal := aRow[ 3 ]
      MessVal := AllTrim( aRow[ 4 ] )
      BlkVal := Val( aRow[ 5 ] ) + 1
   ENDIF


   IF nPage < 3
      cLabel := 'Event date (day.month)'
   ELSEIF nPage = 3
      cDateForm := 'dd.MM'
      cLabel := 'Event date (day.month)'
   ELSEIF nPage = 4
      cDateForm := 'dd'
      cLabel := 'Event date (day)'
   ELSEIF nPage = 5
      cLabel := 'Event date (day of week)'
   ELSEIF nPage = 6
      cLabel := 'Valid to'
   ELSEIF nPage = 7
      cLabel := 'Event date (day.month.year)'
   ENDIF


   DEFINE WINDOW WinEdit AT 0, 0 WIDTH 400 HEIGHT 260 TITLE cNameApp ICON 'MAIN' MODAL  NOSIZE


   @ 25, 0  LABEL lblTit  WIDTH WinEdit.Width  VALUE aS[ nPage ] TRANSPARENT CENTERALIGN
   @ 55, 30  LABEL lblEd1  AUTOSIZE  VALUE cLabel TRANSPARENT

   IF nPage = 5
      @ 55, 250 COMBOBOX Ed1  WIDTH 120 HEIGHT 120  ITEMS aDay VALUE DateVal
   ELSE
      @ 55, 250 DATEPICKER Ed1  WIDTH 120 HEIGHT 25  VALUE DateVal BOLD UPDOWN DATEFORMAT cDateForm FONT "Arial" SIZE 10
   ENDIF

   @ 80, 30  LABEL lblEd2 AUTOSIZE  VALUE 'Event time (hour:min)'   TRANSPARENT
   @ 80, 250 TIMEPICKER Ed2 OF WinDayly WIDTH 120  TIMEFORMAT "HH:mm"  VALUE TimeVal FONT "Arial" SIZE 10

   @ 105, 30 LABEL LblEd3  AUTOSIZE VALUE 'Block the event'   TRANSPARENT
   @ 105, 250 COMBOBOX Ed3  WIDTH 120 HEIGHT 60  ITEMS aNoYes VALUE BlkVal

   @ 130, 30 LABEL LblEd4  AUTOSIZE VALUE 'Message text'  TRANSPARENT
   @ 150, 30  TEXTBOX Ed4  WIDTH 340 HEIGHT 25  VALUE MessVal

   @ 200, 180   BUTTON btnSave  CAPTION 'Save'   ACTION EditEnd( nMod ) WIDTH 100 HEIGHT 22  FONT "Arial" SIZE 9
   @ 200, 285   BUTTON btnCans  CAPTION 'Cancel' ACTION ThisWindow.Release() WIDTH 100 HEIGHT 22  FONT "Arial" SIZE 9


   END WINDOW

   SET TOOLTIP TEXTCOLOR TO WHITE OF WinEdit
   SET TOOLTIP BACKCOLOR TO  aClr[ 3 ] OF WinEdit

   CENTER WINDOW  WinEdit
   ACTIVATE WINDOW WinEdit

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION EditEnd( nMod )
   * aBrw => Type, Date, Time, Mess, Blk, Id

   LOCAL nPage := WinEvent .Tab_1. Value
   LOCAL GridName := 'Grid' + hb_ntos( nPage )
   LOCAL nRow := _GetValue( GridName, 'WinEvent' )
   LOCAL aRow := GetProperty( 'WinEvent', GridName, 'ITEM', nRow )

   LOCAL cId
   LOCAL DateVal, cDateVal
   LOCAL TimeVal := Left( WinEdit .Ed2. Value, 5 )
   LOCAL BlkVal := iif( WinEdit .Ed3. Value = 1, 0, 1 )

   LOCAL MessVal := StrTran( AllTrim( WinEdit .Ed4. Value ), CRLF, ' ' )
   LOCAL nType := nPage - 2

   IF nPage = 3
      DateVal := Left( DToC( WinEdit .Ed1. Value ), 5 )
   ELSEIF nPage = 4
      DateVal := Left( DToC( WinEdit .Ed1. Value ), 2 )
   ELSEIF nPage = 5
      DateVal := Str( WinEdit .Ed1. Value, 1 )
   ELSEIF nPage = 6
      DateVal := DToC( WinEdit .Ed1. Value )
   ELSEIF nPage = 7
      DateVal := DToC( WinEdit .Ed1. Value )
   ENDIF

   cDateVal := iif( nPage = 5, aDay[ WinEdit .Ed1. Value ], DateVal )

   IF nMod = 0
      cId := CreateID()
      DAYLY->( dbAppend() )
      aRow := { hb_ntos( nType ), cDateVal, TimeVal, MessVal, hb_ntos( BlkVal ), cId }
      ADD ITEM aRow TO &GridName OF WinEvent
   ELSE
      cId := aRow[ 6 ]
      DAYLY->( __dbLocate( {|| Dayly->id_ = cId } ) )
      aRow := { hb_ntos( nType ), cDateVal, TimeVal, MessVal, hb_ntos( BlkVal ), cId }
      MODIFY CONTROL &GridName OF WinEvent ITEM( nRow ) aRow
   ENDIF

   Dayly->id_ := cId
   Dayly->type_ := nType
   Dayly->date_ := DateVal
   Dayly->time_ := TimeVal
   Dayly->mess_ := MessVal
   Dayly->blk_ := BlkVal

   aDayMess := DayToArray( Date() )

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION DelMess()

   LOCAL GridName := 'Grid' + hb_ntos( WinEvent .Tab_1. Value )
   LOCAL nRow := _GetValue( GridName, 'WinEvent' )
   LOCAL aRow := GetProperty( 'WinEvent', GridName, 'ITEM', nRow )

   DAYLY->( __dbLocate( {|| Dayly->id_ = aRow[ 6 ] } ) )
   IF DAYLY->( Found() )
      DAYLY->( dbDelete() )
      DAYLY->( __dbPack() )
   ENDIF

   aDayMess := DayToArray( Date() )
   DoMethod( 'WinEvent', GridName, 'DeleteItem', nRow )

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION SetDayly()

   LOCAL i, cChk, cFld
   LOCAL nH := 25, nRow := 35

   LOCAL aIni := { 'Show calendar at startup of program', ;
      'Always place calendar on topmost', ;
      'Use sound at showing of message', ;
      'Place shortcut of program on desktop', ;
      'Start automatically at Windows Startup', ;
      'Show missed mesage at startup of program', ;
      'Inform about holidays', ;
      'Select calendar color style' }

   IF _IsWindowDefined ( 'WinSet' ) = .T.
      RETURN NIL
   ENDIF


   DEFINE WINDOW WinSet AT 0, 0 WIDTH 800 HEIGHT 340 TITLE cNameApp ICON 'MAIN' CHILD ;
      NOSIZE NOMAXIMIZE NOMINIMIZE FONT "Arial" SIZE 9


   LblBox( 'lblB1', 15, 10, 240, 390, 1, { WHITE, GRAY } )

   FOR i = 1 TO 7
      cChk := 'chk' + NToC( i )
      cFld := 'i_' + NToC( i )
      @ nRow, 30  CHECKBOX &cChk CAPTION aIni[ i ] WIDTH 330 HEIGHT 20 VALUE SETI->&cFld TRANSPARENT
      nRow += nH
   NEXT

   @ nRow, 30 LABEL LblClr WIDTH 13 HEIGHT 14  VALUE NToC( SETI->clr_ ) BACKCOLOR aColorsDayly[ SETI->clr_, 2 ] ;
      FONT "Times" SIZE 8 ;
      ON MOUSEHOVER ( This.FontColor := WHITE ) ;
      ON MOUSELEAVE ( This.FontColor := BLACK ) ;
      ACTION {|| ChangeClr() } ;
      CENTERALIGN BORDER

   @ nRow, 52  LABEL lblCl  WIDTH 200 HEIGHT 20  VALUE aIni[ 8 ] TRANSPARENT ;
      ON MOUSEHOVER ( WinSet.lblClr.FontColor := WHITE ) ;
      ON MOUSELEAVE ( WinSet.lblClr.FontColor := BLACK ) ;
      ACTION {|| ChangeClr() }


   LblBox( 'lblB3', 15, 400, 115, 780, 1, { WHITE, GRAY } )

   @ 35, 420  CHECKBOX chkSD1   CAPTION '  Shutdown the computer' WIDTH 200 HEIGHT 20 VALUE SETI->lsd_1 TRANSPARENT
   @ 40, 630  LABEL lblSD1  AUTOSIZE  VALUE 'time (h:m)' FONT "Arial" SIZE 8 TRANSPARENT
   @ 35, 690  TIMEPICKER timSD1 WIDTH 70 HEIGHT 22   TIMEFORMAT "HH:mm" VALUE SETI->tsd_1

   @ 60, 420  CHECKBOX chkSD2  CAPTION '  Reboot the computer' WIDTH 200 HEIGHT 20 VALUE SETI->lsd_2 TRANSPARENT
   @ 65, 630  LABEL lblRB1  AUTOSIZE  VALUE 'time (h:m)' FONT "Arial" SIZE 8 TRANSPARENT
   @ 60, 690 TIMEPICKER timSD2 WIDTH 70 HEIGHT 22  TIMEFORMAT "HH:mm" VALUE SETI->tsd_2

   @ 85, 420  CHECKBOX chkSD3  CAPTION '  LogOff the computer' WIDTH 200 HEIGHT 20 VALUE SETI->lsd_3 TRANSPARENT
   @ 90, 630  LABEL lblEN1  AUTOSIZE  VALUE 'time (h:m)' FONT "Arial" SIZE 8 TRANSPARENT
   @ 85, 690 TIMEPICKER timSD3 WIDTH 70 HEIGHT 22  TIMEFORMAT "HH:mm" VALUE SETI->tsd_3


   LblBox( 'lblB4', 120, 400, 290, 780, 1, { WHITE, GRAY } )


   @ 140, 420  CHECKBOX chkAr1  CAPTION '  Launch program 1' WIDTH 200 HEIGHT 18 VALUE SETI->lar_1 TRANSPARENT
   @ 140, 630  LABEL lblAp1  AUTOSIZE  VALUE 'time (h:m)' FONT "Arial" SIZE 8   TRANSPARENT
   @ 135, 690 TIMEPICKER timAr1 WIDTH 70 HEIGHT 22  TIMEFORMAT "HH:mm" VALUE SETI->tar_1
   @ 158, 420 BTNTEXTBOX txtAr1 WIDTH 340 HEIGHT 22   VALUE SETI->nar_1 PICTURE "FOLDER" BUTTONWIDTH 20 FONT "Arial" SIZE 8 ;
      ACTION ( This.Value := GetFile()  )

   @ 190, 420  CHECKBOX chkAr2  CAPTION '  Launch program 2' WIDTH 200 HEIGHT 18 VALUE SETI->lar_2 TRANSPARENT
   @ 190, 630  LABEL lblAp2  AUTOSIZE  VALUE 'time (h:m)' FONT "Arial" SIZE 8  TRANSPARENT
   @ 185, 690 TIMEPICKER timAr2 WIDTH 70 HEIGHT 22  TIMEFORMAT "HH:mm" VALUE SETI->tar_2
   @ 208, 420 BTNTEXTBOX txtAr2 WIDTH 340 HEIGHT 22   VALUE SETI->nar_2 PICTURE "FOLDER" BUTTONWIDTH 20  FONT "Arial" SIZE 8 ;
      ACTION ( This.Value := GetFile()  )

   @ 240, 420  CHECKBOX chkAr3  CAPTION '  Launch program 3' WIDTH 200 HEIGHT 18 VALUE SETI->lar_3 TRANSPARENT
   @ 240, 630  LABEL lblAp3  AUTOSIZE  VALUE 'time (h:m)' FONT "Arial" SIZE 8  TRANSPARENT
   @ 235, 690 TIMEPICKER timAr3 WIDTH 70 HEIGHT 22  TIMEFORMAT "HH:mm" VALUE SETI->tar_3
   @ 258, 420 BTNTEXTBOX txtAr3 WIDTH 340 HEIGHT 22   VALUE SETI->nar_3 PICTURE "FOLDER" BUTTONWIDTH 20  FONT "Arial" SIZE 8 ;
      ACTION ( This.Value := GetFile()  )


   @ 270, 70   BUTTON btnSave  CAPTION 'Save'   ACTION SaveIni() WIDTH 100 HEIGHT 22  FONT "Arial" SIZE 9
   @ 270, 175  BUTTON btnCans  CAPTION 'Cancel' ACTION ThisWindow.Release() WIDTH 100 HEIGHT 22  FONT "Arial" SIZE 9


   END WINDOW

   SET TOOLTIP TEXTCOLOR TO WHITE OF WinSet
   SET TOOLTIP BACKCOLOR TO aClr[ 3 ] OF WinSet

   CENTER WINDOW WinSet
   ACTIVATE WINDOW WinSet

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION ChangeClr()

   LOCAL iClr := Val( WinSet.lblClr.Value )

   iif( iClr = Len( aColorsDayly ), iClr := 1, iClr++ )
   WinSet.lblClr.BackColor := aColorsDayly[ iClr, 2 ]
   WinSet.lblClr.Value := NToC( iClr )

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION SaveIni()

   LOCAL i, cChk, cFld

   FOR i = 1 TO 7
      cChk := 'chk' + NToC( i )
      cFld := 'i_' + NToC( i )
      SETI->&cFld := GetProperty( 'WinSet', cChk, 'VALUE' )
   NEXT
   SETI->clr_ := Val( GetProperty( 'WinSet', 'LblClr', 'VALUE' )  )

   SETI->lsd_1 := GetProperty( 'WinSet', 'chksd1', 'VALUE' )
   SETI->tsd_1 := GetProperty( 'WinSet', 'timsd1', 'VALUE' )
   SETI->lsd_2 := GetProperty( 'WinSet', 'chksd2', 'VALUE' )
   SETI->tsd_2 := GetProperty( 'WinSet', 'timsd2', 'VALUE' )
   SETI->lsd_3 := GetProperty( 'WinSet', 'chksd3', 'VALUE' )
   SETI->tsd_3 := GetProperty( 'WinSet', 'timsd3', 'VALUE' )

   SETI->lar_1 := GetProperty( 'WinSet', 'chkar1', 'VALUE' )
   SETI->tar_1 := GetProperty( 'WinSet', 'timar1', 'VALUE' )
   SETI->nar_1 := GetProperty( 'WinSet', 'txtar1', 'VALUE' )
   SETI->lar_2 := GetProperty( 'WinSet', 'chkar2', 'VALUE' )
   SETI->tar_2 := GetProperty( 'WinSet', 'timar2', 'VALUE' )
   SETI->nar_2 := GetProperty( 'WinSet', 'txtar2', 'VALUE' )
   SETI->lar_3 := GetProperty( 'WinSet', 'chkar3', 'VALUE' )
   SETI->tar_3 := GetProperty( 'WinSet', 'timar3', 'VALUE' )
   SETI->nar_3 := GetProperty( 'WinSet', 'txtar3', 'VALUE' )

   iif( SETI->i_4, CreateLink( PathDTop + '\' + cNameApp + '.lnk', FileExe, '', FileExe, 'Events control' ), ;
      FErase( PathDTop + '\' + cNameApp + '.lnk' )  )
   iif( SETI->i_5, CreateLink( PathStUp + '\' + cNameApp + '.lnk', FileExe, '', FileExe, 'Events control' ), ;
      FErase( PathStUp + '\' + cNameApp + '.lnk' )  )

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION CreateID()

   LOCAL dDay := Date()
   LOCAL c1 := Right( Str( Year( dDay ), 4 ), 2 )
   LOCAL c2 := PadL( AllTrim( Str( Month( dDay ) ) ), 2, '0' )
   LOCAL c3 := PadL( AllTrim( Str( Day( dDay ) ) ), 2, '0' )
   LOCAL c4 := PadL( AllTrim( Str( Int( Seconds() ) ) ), 6, '0' )

RETURN( c1 + c2 + c3 + c4 )

//-------------------------------------------------------------\\

FUNCTION DaylyAbout()

   IF _IsWindowDefined ( 'WinAbout' ) = .T.
      RETURN NIL
   ENDIF

   DEFINE WINDOW WinAbout AT 0, 0 WIDTH 210 HEIGHT 240 ;
      TITLE cNameApp ICON 'MAIN' ;
      CHILD ;
      NOSIZE NOCAPTION ;
      BACKCOLOR aClr[ 2 ]

   @ 1, 1  IMAGE ImgRG PICTURE PictRG WIDTH 100 HEIGHT 100 ;
      ACTION MoveActiveWindow()

   @ 14, 9  LABEL LblName1 WIDTH  190 HEIGHT 25  VALUE '  ' + cNameApp + '  v' + cVer  TRANSPARENT CENTERALIGN ;
      FONT 'Times' SIZE 18 FONTCOLOR WHITE ;
      ACTION MoveActiveWindow()
   @ 15, 10  LABEL LblName2 WIDTH  190 HEIGHT 25  VALUE '  ' + cNameApp + '  v' + cVer  TRANSPARENT CENTERALIGN ;
      FONT 'Times' SIZE 18 FONTCOLOR ClrText ;
      ACTION MoveActiveWindow()


   @ 55, 20  LABEL LblLine1 WIDTH  170 HEIGHT 1  VALUE ' ' BACKCOLOR aClr[ 3 ]
   @ 56, 20  LABEL LblLine2 WIDTH  170 HEIGHT 1  VALUE ' ' BACKCOLOR aClr[ 1 ]

   @ 70, 10  LABEL LblName3 WIDTH  190 HEIGHT 20  VALUE 'Program for reminders' ;
      FONT 'Times' SIZE 11 FONTCOLOR BLACK TRANSPARENT CENTERALIGN

   @ 95, 5  LABEL LblName4 WIDTH  200 HEIGHT 28  VALUE 'Calendar and Alarm Clock' ;
      FONT 'Times' SIZE 13 BOLD FONTCOLOR aClr[ 3 ] TRANSPARENT CENTERALIGN VCENTERALIGN

   @ 130, 10  LABEL LblReg WIDTH  190 HEIGHT 30 VALUE "Registered to: " + aRegInfo[ 1 ] + CRLF + "Computer: " + aRegInfo[ 2 ] ;
      FONT "Arial" SIZE 9 TRANSPARENT CENTERALIGN

   @ 170, 5  LABEL LblCopy WIDTH  200 HEIGHT 20 VALUE "Copyright 2007-2012 Sergey Logoshny" ;
      FONT "Times" SIZE 9 FONTCOLOR BLACK TRANSPARENT CENTERALIGN

   @ 195, 20    LABEL lblWWW HEIGHT 16 WIDTH 170 VALUE cWWW  ;
      FONT 'Lucida Console' SIZE 8 FONTCOLOR GRAY UNDERLINE CENTERALIGN TRANSPARENT ;
      ACTION ShellExecute( 0, "open", 'http://minisoft.tora.ru', , , 1 );
      ON MOUSEHOVER {|| Rc_Cursor( "MINIGUI_FINGER" ), This.FontColor := BLACK } ;
      ON MOUSELEAVE ( This.FontColor := GRAY )

   @ 215, 40  BUTTONEX btnLY ACTION ThisWindow.Release() ;
      WIDTH 140 HEIGHT 18 CAPTION 'Ok' ;
      FONT "Arial" SIZE 9 ;
      BACKCOLOR { 255, 164, 44 } NOXPSTYLE  FLAT

   LblBox( 'lblW', 0, 0, WinAbout.Height - 1, WinAbout.Width - 1, 1, { aClr[ 3 ], aClr[ 3 ] } )

   END WINDOW

   CENTER WINDOW  WinAbout
   ACTIVATE WINDOW WinAbout

RETURN NIL

//-------------------------------------------------------------\\

FUNCTION CreateLink( LinkName, TargPath, HKey, IconLoc, Descr )

   LOCAL NShortcut
   LOCAL WshShell := TOleAuto():New( "WScript.Shell" )

   IF Ole2TxtError() != 'S_OK'
      RETURN .F.
   ENDIF

   NShortcut := WshShell:CreateShortcut( LinkName )
   //Set shortcut placement
   NShortcut:TargetPath := TargPath
   //Set standard style of window
   NShortcut:WindowStyle := 1
   //Set hotkey
   NShortcut:Hotkey := HKey
   //Path to icon
   NShortcut:IconLocation := IconLoc + ", 0"
   //Set tooltip
   NShortcut:Description := Descr
   //Set path to application as working directory
   NShortcut:WorkingDirectory := PathApp
   //Save settings and shortcut
   NShortcut:Save()

RETURN .T.
