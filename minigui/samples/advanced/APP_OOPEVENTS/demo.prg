/* 
 * MINIGUI - Harbour Win32 GUI library Demo 
 * 
 */ 
  
#include "hmg.ch" 
#include "tsbrowse.ch"

ANNOUNCE RDDSYS

MEMVAR oMain, oBrw

*-----------------------------------
FUNCTION Main()
*-----------------------------------
   LOCAL cWnd := 'wMain'
   LOCAL nY, nX, nW, nH, aYX

   *--------------------------------
   SET OOP ON
   *--------------------------------
  
   SET CENTURY      ON 
   SET DATE         GERMAN 
   SET EPOCH TO     2000 

   SET NAVIGATION   EXTENDED 
   SET FONT         TO "Arial", 11 

   PUBLIC oMain, oBrw

	DEFINE WINDOW &cWnd AT 0,0 WIDTH 650 HEIGHT 500 ;
		TITLE 'MiniGUI Demo SET OOP ON and events'   ;
		ICON  'hmg_ico' ;
		MAIN  NOMAXIMIZE  NOSIZE ;
		ON INTERACTIVECLOSE (This.Object):Action // если активно окно :Action == .T.

		oMain := This.Object  // объект окна

		DEFINE MAIN MENU 
		POPUP 'MENU_1'                                    NAME 100                                         
			ITEM 'Item main menu 1.1'                      NAME 101 IMAGE 'n1' ;
 				ACTION (ThisWindow.Object):PostMsg(Val(This.Name), This.Index)
			ITEM 'Item main menu 1.2'                      NAME 102 IMAGE 'n2' ;
 				ACTION (ThisWindow.Object):PostMsg(Val(This.Name))
			ITEM 'Item main menu 1.3 ( This -> Button_2 )' NAME 103 IMAGE 'n3' ;
 				ACTION (ThisWindow.Object):PostMsg(Val(This.Name), This.Button_2.Index)
			SEPARATOR                                   
			ITEM 'Exit'                                    NAME 199            ;
 				ACTION (ThisWindow.Object):PostMsg(Val(This.Name))
		END POPUP                                      
		POPUP 'MENU_2'                                    NAME 200
			ITEM 'Item main menu 2.1'                      NAME 201 IMAGE 'n1' ;
				ACTION (ThisWindow.Object):PostMsg(201)
			ITEM 'Item main menu 2.2 ( This -> Lbl_1 )'    NAME 202 IMAGE 'n2' ;
				ACTION (ThisWindow.Object):PostMsg(202, This.Lbl_1.Handle)
			ITEM 'Item main menu 2.3 ( This -> Month )'    NAME 203 IMAGE 'n3' ;
				ACTION (ThisWindow.Object):PostMsg(203, This.Combo_Month.Handle)
			ITEM 'Item main menu 2.4 ( This -> Year )'     NAME 204 IMAGE 'n4' ;
				ACTION (ThisWindow.Object):PostMsg(204, This.Spinner_Year.Handle[1])
			ITEM 'Item main menu 2.5 ( This -> TSBrowse )' NAME 205 IMAGE 'n5' ;
				ACTION (ThisWindow.Object):PostMsg(205, This.oBrw.Handle)
		END POPUP
		END MENU

  		DEFINE STATUSBAR BOLD
			STATUSITEM ''           ACTION (ThisWindow.Object):PostMsg(91)
			STATUSITEM '' WIDTH  80 ACTION (ThisWindow.Object):PostMsg(92, This.Btn_Wait.Handle)
			STATUSITEM '' WIDTH 400 ACTION (ThisWindow.Object):PostMsg(93, This.Lbl_1.Handle)
		END STATUSBAR

      nY :=  0
      nX :=  0
      nH := 24
      nW := This.ClientWidth

      @ nY, nX LABEL Lbl_1 WIDTH nW HEIGHT nH * 1.5 ;
               VALUE OS() + '.  ' + VERSION() + '.  ' + hb_compiler() + '.' ;
               BACKCOLOR {  0,176,240} BORDER CENTERALIGN VCENTERALIGN

      nY += This.Lbl_1.Height + 20
      nX += 10
      
      @ nY, nX BUTTONEX Button_1  WIDTH 100  HEIGHT nH * 2 ;
               CAPTION "Button 1" FONTCOLOR {200,0,0}  BOLD ;
               ACTION  (ThisWindow.Object):PostMsg(101, This.Handle)

      nX += This.Button_1.Width + 20
      
      @ nY, nX BUTTONEX Button_2  WIDTH 100  HEIGHT nH * 2 ;
               CAPTION "Button 2" FONTCOLOR {200,0,0}  BOLD ;
               ACTION  (ThisWindow.Object):PostMsg(102, This.Handle)

      nX += This.Button_1.Width + 20 + 20
      
      @ nY, nX BUTTONEX Btn_Wait  WIDTH 100  HEIGHT nH * 2 ;
               CAPTION "W a i t"  FONTCOLOR {200,0,0}  BOLD ;
               ACTION  (ThisWindow.Object):PostMsg(99, This.Handle)

      nY += This.Btn_Wait.Height + 20 + 20
      nX := 10

      aYX := TsbCalendar(nY, nX)
      
      nX  := aYX[2] + 20

      @ nY, nX BUTTONEX Button_3  WIDTH 100  HEIGHT nH * 2 ;
               CAPTION "Button 3" FONTCOLOR {200,0,0}  BOLD ;
               ACTION  (ThisWindow.Object):PostMsg(75, This.oBrw.Handle) ;
               TOOLTIP ' This -> oBrw ( TsbCalendar ). Press F5 '

      nY  := aYX[1] + 20
      nX  := 10
      
      @ nY, nX BUTTONEX Button_4  WIDTH 100  HEIGHT nH * 2 ;
               CAPTION "Button 4" FONTCOLOR {200,0,0}  BOLD ;
               ACTION  (ThisWindow.Object):PostMsg(92, This.Handle)

      oBrw:UserKeys( VK_F5, {|ob| _WindowObj(ob:cParentWnd):PostMsg(75, ob:hWnd) } )

      WITH OBJECT This.Object                            // ---- Window events
      // TsBrowse calendar
      :Event(  75, {|ow,ky| MyInfo(ow, ky), oBrw:SetFocus() } )
      // StatusBar
      :Event(  91, {|ow,ky| MyInfo(ow, ky) } )
      :Event(  92, {|ow,ky| MyInfo(ow, ky), ;
                            MsgDebug('CONTROL TYPE:', ow:GetListType()), ;
                            oBrw:SetFocus() } )
      :Event(  93, {|ow,ky| MyInfo(ow, ky) } )
      :StatusBar:Say(MiniGUIVersion(), 3)
      // Button Wait
      :Event(  99, {|ow,ky| MyWait(ow, ky), oBrw:SetFocus() } )
      // Menu 1
      :Event( 101, {|ow,ky| MyInfo(ow, ky), oBrw:SetFocus() } )
      :Event( 102, {|ow,ky| MyInfo(ow, ky), oBrw:SetFocus() } )
      :Event( 103, {|ow,ky| MyInfo(ow, ky), oBrw:SetFocus() } )
      :Event( 199, {|ow   | ow:Release()   } )
      // Menu 2
      :Event( 201, {|ow,ky| MyInfo(ow, ky) } )
      :Event( 202, {|ow,ky| MyInfo(ow, ky) } )
      :Event( 203, {|ow,ky| MyInfo(ow, ky) } )
      :Event( 204, {|ow,ky| MyInfo(ow, ky) } )
      :Event( 205, {|ow,ky| MyInfo(ow, ky) } )
      END WITH                                           // ---- Window events

	END WINDOW

	CENTER   WINDOW &cWnd
	ACTIVATE WINDOW &cWnd

RETURN NIL


STATIC FUNC MyWait( oCnl, nKy )
   LOCAL i, n, oWnd := oCnl:Window

   If ! oWnd:Action
      RETURN NIL
   EndIf

   oWnd:Action   := .F.
   oBrw:lEnabled := .F.
   This.Combo_Month.Enabled  := .F.
   This.Spinner_Year.Enabled := .F.
   MenuItemEnable(.F., oWnd, 100)
   MenuItemEnable(.F., oWnd, 200)
   DO EVENTS

   MyInfo(oCnl, nKy)
   
   oWnd:StatusBar:Say('... W A I T ...')
   For i := 1 To 20
       oWnd:StatusBar:Say(hb_ntos( i ), 2)
       For n := 1 To 10
           wApi_Sleep(100)
           DO EVENTS
       Next
   Next
   This.Combo_Month.Enabled  := .T.
   This.Spinner_Year.Enabled := .T.
   oBrw:lEnabled             := .T.
   MenuItemEnable(.T., oWnd, 100)
   MenuItemEnable(.T., oWnd, 200)
   _PushKey(VK_MENU)
   _PushKey(VK_ESCAPE)
   DO EVENTS
   oWnd:StatusBar:Say('', 2)
   oWnd:StatusBar:Say('', 1)
   oWnd:Action := .T.
      
RETURN NIL


STATIC FUNC TsbCalendar( nRow, nCol )
   LOCAL i, nY, nX, aDay, cWnd := This.Name
   LOCAL nW := 95, nBoW := 1

   FT_DATECNFG( , nBoW )

   IF nBoW == 2
      aDay := { "M", "T", "W", "Th", "F", "S", "Sn" }
   ELSE
      aDay := { "Sn", "M", "T", "W", "Th", "F", "S" }
   ENDIF

   nY := nRow
   nX := nCol

   DEFINE COMBOBOX Combo_Month
     ROW      nY
     COL      nX
     WIDTH    nW
     HEIGHT   204
     ITEMS    aMonths()
     VALUE    Month( Date() )
     ONCHANGE LoadToCalendar( CToD( '01.' + PadL( This.Combo_Month.Value, 2, "0" ) + "." + NTOC( This.Spinner_Year.Value ) ) )
     FONTNAME 'Arial'
     FONTSIZE 10
     TABSTOP  .F.
   END COMBOBOX

   nX += This.Combo_Month.Width 

   DEFINE SPINNER Spinner_Year
     ROW      nY
     COL      nX 
     WIDTH    nW
     HEIGHT   24
     RANGEMIN 2000
     RANGEMAX 2100
     VALUE    Year( Date() )
     FONTNAME 'Arial'
     FONTSIZE 10
     ONCHANGE LoadToCalendar( CToD( '01.' + PadL( This.Combo_Month.Value, 2, "0" ) + "." + NTOC( This.Spinner_Year.Value ) ) )
     WRAP .T.
   END SPINNER

   nY += This.Spinner_Year.Height + 1
   nX := nCol

   DEFINE TBROWSE oBrw  AT nY, nX ; 
      WIDTH  This.Combo_Month.Width + This.Spinner_Year.Width ;
      HEIGHT 177 ;
      FONT   "Arial" ;
      SIZE   9 ;
      GRID

   END TBROWSE

   // Assign empty array to TBrowse object
   oBrw:SetArray( Array( 6, 7 ), TRUE )

   // Add user data to TBrowse object
   __objAddData( oBrw, 'aMark' )
   __objAddData( oBrw, 'aDate' )
   __objAddData( oBrw, 'dDate' )

   oBrw:aMark := Array( 6, 7 )
   oBrw:aDate := Array( 6, 7 )
   oBrw:dDate := Date()

   // Modify TBrowse settings
   oBrw:nHeightCell  := ( oBrw:nHeight / 7 )
   oBrw:nHeightHead  := ( oBrw:nHeight / 7 )
   oBrw:lNoHScroll   := .T.
   oBrw:nFreeze      := 7
   oBrw:lNoMoveCols  := TRUE
   oBrw:lLockFreeze  := FALSE
   oBrw:lNoChangeOrd := TRUE
   oBrw:nFireKey     := VK_SPACE

   // Define TBrowse colors
   oBrw:SetColor( { 3 }, { {|| RGB( 255, 242, 0 )  } },   )
   oBrw:SetColor( { 4 }, { {|| { RGB( 43, 189, 198 ), RGB( 3, 113, 160 ) } } },   )

   oBrw:SetColor( { 6 },  { -RGB( 220, 0, 0 ) },   )

   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 1 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 1 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 2 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 2 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 3 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 3 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 4 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 4 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 5 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 5 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 6 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 6 )
   oBrw:SetColor( { 2 }, { {|| IF( IsMark( 7 ), RGB( 100, 255, 100 ), RGB( 240, 255, 240 ) ) } }, 7 )

   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 1 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 1 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 2 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 2 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 3 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 3 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 4 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 4 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 5 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 5 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 6 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 6 )
   oBrw:SetColor( { 1 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 7 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 7 )

   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 1 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 1 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 2 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 2 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 3 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 3 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 4 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 4 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 5 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 5 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 6 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 6 )
   oBrw:SetColor( { 5 }, { {|| IF( Month( oBrw:aDate[ oBrw:nAt ][ 7 ] ) == Month( oBrw:dDate ), RGB( 0, 0, 0 ), RGB( 200, 200, 200 ) ) } }, 7 )

   // Define TBrowse columns header and data
   FOR i := 1 TO 7
      oBrw:aColumns[ i ]:cHeading := aDay[ i ]

      oBrw:SetColSize( i, ( oBrw:nWidth / 7 ) )
      oBrw:aColumns[ i ]:bData := hb_macroBlock( "GetDate(" + NTOC( i ) + ")" )
      oBrw:aColumns[ i ]:nAlign := DT_CENTER
      oBrw:aColumns[ i ]:lEdit := TRUE
      oBrw:aColumns[ i ]:bPrevEdit := {|| Mark(), .F. }
   NEXT

   LoadToCalendar( Date() )

RETURN { nRow + This.Spinner_Year.Height + 1 + This.oBrw.Height,  ;
         nCol + This.Spinner_Year.Width  + This.Combo_Month.Width }
         

STATIC FUNC MenuItemEnable( lEnable, oWnd, nKy )   
   LOCAL cWnd := oWnd:Name
   LOCAL cKy  := hb_ntos(nKy)
   
    If lEnable; ENABLE  MENUITEM &cKy OF &cWnd
    Else      ; DISABLE MENUITEM &cKy OF &cWnd
    EndIf

RETURN NIL


STATIC FUNC MyInfo( oWnd, nKy )
   LOCAL cTx := ""

   cTx += '---- _HMG_This...----	' +                                     + CRLF + CRLF
   cTx += '_HMG_ThisFormName    	' +          _HMG_ThisFormName          + CRLF
   cTx += '_HMG_ThisFormIndex   	' + hb_ntos( _HMG_ThisFormIndex )       + CRLF
   cTx += '_HMG_ThisType     		' +          _HMG_ThisType              + CRLF   
   cTx += '_HMG_ThisControlName 	' +          _HMG_ThisControlName       + CRLF
   cTx += '_HMG_ThisIndex 	 	' + hb_ntos( _HMG_ThisIndex )           + CRLF
If _HMG_ThisType == "C" .and. _HMG_ThisIndex > 0
   cTx += '_HMG_aControlType    	' + _HMG_aControlType[ _HMG_ThisIndex ] + CRLF 
EndIf
   cTx += '_HMG_ThisEventType   	' + _HMG_ThisEventType                     + CRLF + CRLF
   cTx += '------ object -------	' +         oWnd:ClassName                 + CRLF + CRLF
   cTx += 'Window or Control 	' + iif( oWnd:IsWindow, 'WINDOW', 'CONTROL' )      + CRLF
   cTx += 'Name                 	' +         oWnd:Name                      + CRLF
   cTx += 'Type                 	' +         oWnd:Type                      + CRLF
   cTx += 'Index                	' + hb_ntos(oWnd:Index)                    + CRLF
   cTx += 'VarName              	' +         oWnd:VarName                   + CRLF
   cTx += 'Event		'         + hb_ntos(nKy)                           + CRLF + CRLF
   cTx += '------ This. --------	' +                                        + CRLF + CRLF
   cTx += 'ThisWindow.Name 	'         +         ThisWindow.Name                + CRLF
   cTx += 'This.Name 	'                 +         This.Name                      + CRLF
   cTx += 'This.Index		'         + hb_ntos(This.Index)                    + CRLF
   cTx += 'This.Type 		'         +         This.Type                     
   
   MsgBox(cTx, ProcName())

RETURN NIL


FUNCTION GetDate( nCol )

RETURN Day( oBrw:aDate[ oBrw:nAt ][ nCol ] )


FUNCTION Mark()

   IF Month( oBrw:aDate[ oBrw:nAt ][ oBrw:nCell ] ) == Month( oBrw:dDate )
      oBrw:aMark[ oBrw:nAt ][ oBrw:nCell ] := .NOT. oBrw:aMark[ oBrw:nAt ][ oBrw:nCell ]
      oBrw:DrawSelect()
   ENDIF

RETURN NIL


FUNCTION IsMark( n )

RETURN oBrw:aMark[ oBrw:nAt ][ n ]


FUNCTION LoadToCalendar( dDate )
   LOCAL dFirst := FT_ACCTWEEK( BOM( dDate ) )[ 2 ]
   LOCAL i
   LOCAL j
   LOCAl n
   STATIC aPos := { , }

   IF __mvExist( "oBrw" )
      n := 0
      FOR i := 1 TO 6
         FOR j := 1 TO 7
            oBrw:aDate[ i ][ j ] := dFirst + n
            IF dDate == Date() .AND. Day( oBrw:aDate[ i ][ j ] ) == Day( dDate ) .AND. Month( oBrw:aDate[ i ][ j ] ) == Month( dDate )
               oBrw:aMark[ i ][ j ] := TRUE  // mark Today cell
               aPos[ 1 ] := i
               aPos[ 2 ] := j
            ELSE
               oBrw:aMark[ i ][ j ] := FALSE
            ENDIF
            n++
         NEXT
      NEXT

      oBrw:dDate := dDate

      oBrw:lInitGoTop := .F.
      oBrw:GoPos( aPos[ 1 ], aPos[ 2 ] )  // select Today cell

      oBrw:Refresh( TRUE )
      oBrw:SetFocus()
   ENDIF

RETURN NIL
