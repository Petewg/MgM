#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW menubuilder
DECLARE WINDOW statusbarbuilder
DECLARE WINDOW DropDownMenuBuilder

*------------------------------------------------------------*
PROCEDURE StatusFont()
*------------------------------------------------------------*
   LOCAL aFont AS ARRAY := GetFont( aStatusValues[2],        ;
                                    aStatusValues[3],        ;
                                    aStatusValues[4],        ;
                                    aStatusValues[5],        ;
                                    { 0, 0, 0 },             ;
                                    aStatusValues[6],        ;
                                    aStatusValues[7],        ;
                                    0                        ;
                                  )

   IF Len( aFont[ 1 ] ) > 0
      aStatusValues[ 2 ] := aFont[ 1 ]
      aStatusValues[ 3 ] := aFont[ 2 ]
      aStatusValues[ 4 ] := aFont[ 3 ]
      aStatusValues[ 5 ] := aFont[ 4 ]
      aStatusValues[ 6 ] := aFont[ 6 ]
      aStatusValues[ 7 ] := aFont[ 7 ]
   endif

RETURN


*------------------------------------------------------------*
PROCEDURE StatusInit()
*------------------------------------------------------------*
   StatusbarBuilder.Width := ( StatusbarBuilder.Width ) + GetBorderWidth()

   StatusFmgToMem()

   IF Len( ArrayStatus ) > 0

      StatusFillGrid()

      //? Why action On/Off to assign a value
      lAction                       := .F.
      StatusbarBuilder.Grid_1.Value := 1
      lAction                       := .T.

      StatusFillForm( StatusbarBuilder.Grid_1.Value )
   ELSE
      StatusbarBuilder.Grid_1.Value := 1
   ENDIF

RETURN


*------------------------------------------------------------*
/* load values from VARRAY and display in form
   and store to array */
PROCEDURE StatusFmgToMem()
*------------------------------------------------------------*
   LOCAL vArray      AS ARRAY
   LOCAL xValue      AS ARRAY
   LOCAL x           AS NUMERIC
   LOCAL cLine       AS STRING
   LOCAL x4          AS NUMERIC
   LOCAL X5          AS NUMERIC
   LOCAL X6          AS NUMERIC
   LOCAL X7          AS NUMERIC
   LOCAL X8          AS NUMERIC
   LOCAL X9          AS NUMERIC
   LOCAL X10         AS NUMERIC
   LOCAL X11         AS STRING
   LOCAL X12         AS STRING
   LOCAL cValue      AS STRING
   LOCAL aMenuItens  AS ARRAY

   * DEFINE STATUSBAR FONT "Arial" SIZE 9
   *        STATUSITEM "Item 1" ACTION MsgInfo( "Item 1" )
   *        STATUSITEM "Item 2" WIDTH 50
   *        CLOCK
   *        STATUSITEM "Item 3" WIDTH 100
   *    END STATUSBAR

   vArray               := aStatus
   

   PUBLIC ArrayStatus   := {}
   PUBLIC lAction       := .T.
   PUBLIC aStatusValues := { .F., "Arial Black", 12, .F., .F., .F., .F. }
   //////////
 // cVarray := ''
 // FOR X = 1 TO LEN(VARRAY)
 //  cVarray +=STR(X)+ ' ' + varray[x]+CRLF
 //  next x
 //  msgbox('varray= ' +CRLF+cVarray )
   /////////
   

   * KEYBOARD * 1 FONT * 2 SIZE * 3 BOLD * 4 ITALIC * 5 UNDERLINE * 6 STRIKEOUT * 7
   //   for x = 1 to Len(aStatusValues)
   //    MsgBox( "len = "+str(Len(aStatusValues))+" "+ValType(aStatusValues[x]))
   //    next x
   IF Len( vArray ) > 1 .AND. ValType( vArray[ 2 ] ) == "C"
      cLine := AllTrim( vArray[ 1 ] )
      cLine := SubStr( cLine, 18, Len( cLine ) )
      // MsgBox( "cLine= " + cLine )

      X4 := At( 'KEYBOARD', cLine )
      IF X4 > 0
         cLine :=  StrTran( cLine, "KEYBOARD", "" )
         // MsgBox( "X4= " + Str( X4 ) + " cLine= " + cLine )
         aStatusValues[1] := .T.
      ENDIF

      X5 :=  At( 'BOLD', cLine )
      IF X5 > 0
         cLine := StrTran( cLine, "BOLD", "" )
         // MsgBox( "X5= " + Str( X4 ) + " cLine= " + cLine )
         aStatusValues[4] := .T.
      ENDIF

      X6 :=  At( 'ITALIC', cLine )
      IF X6 > 0
         cLine := StrTran( cLine, "ITALIC", "" )
         // MsgBox( "X6= " + Str( X4 ) + " cLine= " + cLine )
         aStatusValues[5] := .T.
      ENDIF

      X7 :=  At( 'UNDERLINE', cLine )
      IF X7 > 0
         cLine := StrTran( cLine, "UNDERLINE", "" )
         // MsgBox( "X7= " + Str( X4 ) + " cLine= " + cLine )
         aStatusValues[6] := .T.
      ENDIF

      X8 :=  At( 'STRIKEOUT', cLine )
      IF X8 > 0
         cLine := StrTran( cLine, "STRIKEOUT", "" )
         // MsgBox( "X8= " + Str( X4 ) + " cLine= " + cLine )
         aStatusValues[7] := .T.
      ENDIF

      X9  := At( 'FONT', cLine )
      X10 := At( 'SIZE', cLine )
      X11 := SubStr( cLine, X9 + 5, X10 - ( X9 + 5 ) - 1 )
      // MsgBox(X11)
      X11 := SubStr( X11, 2, Len( X11 ) - 2 )
      // MsgBox(X11)
      X12 := SubStr( cLine, X10 + 5, Len( cLine ) )

      // MsgBox("FONT = "+X11)
      // MsgBox("SIZE= "+X12)
      aStatusValues[2] := X11
      aStatusValues[3] := Val( X12 )
      // for x = 1 to Len(aStatusValues)
      //     MsgBox( "len = "+str(Len(aStatusValues))+" "+ValType(aStatusValues[x]))
      // next x
      // MsgBox( aStatusValues[1] +CRLF+aStatusValues[2] +CRLF+aStatusValues[3] +CRLF+aStatusValues[4];
      //   +CRLF+  aStatusValues[5] +CRLF+aStatusValues[6] +CRLF+aStatusValues[7] )
      ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** *

      FOR x := 2 TO ( Len( vArray ) - 1 )
         //    MsgBox("x= "+str(x)+"len varray= "+str(Len(varray)) )
         cLine := vArray[ x ]

         X4 := At( 'STATUSITEM'   , cLine )  
         X5 := At( 'DATE'         , cLine )
         X6 := At( 'CLOCK'       , cLine )
         X7 := At( 'KEYBOARD'     , cLine )
         X8 := At( 'PROGRESSITEM' , cLine )

         IF X4 > 0
            cValue := "STATUSITEM"   
         ELSEIF X5 > 0
            cValue := "DATE"
         ELSEIF X6 > 0
            cValue := "CLOCK"
         ELSEIF X7 > 0
            cValue := "KEYBOARD"
         ELSEIF X8 > 0
            cValue := "PROGRESSITEM"  
         ELSE
            cValue := "STATUSITEM"
         ENDIF

          aMenuItens := StatusItens( cLine, cValue )

         aAdd( ArrayStatus, { cValue, aMenuItens[1], ;
               aMenuItens[2] , aMenuItens[3], aMenuItens[4] , ;
               aMenuItens[5] , aMenuItens[6], aMenuItens[7] , ;
               aMenuItens[8] , aMenuItens[9], aMenuItens[10], ;
               aMenuItens[11], aMenuItens[12] } )
      NEXT X
   ELSE
     //  MsgBox( "empty array " )
      xValue := { "", "", "NIL", "NIL", "NIL", "1", "NIL", "NIL", "NIL", "NIL", "NIL", "NIL", "NIL" }
               
      aAdd( ArrayStatus, xValue )
     //  MsgBox( "len ArrayStatus= " + Str( Len( ArrayStatus ) ) )
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusFillForm( nPos AS NUMERIC )
*------------------------------------------------------------*
   LOCAL Value AS NUMERIC

   lAction := .F.

   StatusbarBuilder.Text_1.Value := ArrayStatus[ nPos, 2 ]    //CAPTION

   IF ArrayStatus[ nPos, 6 ] = "1"
      Value := 1
   ELSEIF ArrayStatus[ nPos, 6 ] = "2"
      Value := 2
   ELSEIF ArrayStatus[ nPos, 6 ] = "3"
      Value := 3
   ELSE
      Value := 0
   ENDIF

   StatusbarBuilder.Combo_1.Value := Value

   IF ArrayStatus[ nPos, 8 ] = "1"
      StatusbarBuilder.Check_1.Value := .T.
   ELSEIF  ArrayStatus[ nPos, 8 ] = "0"
      StatusbarBuilder.Check_1.Value := .F.
   ENDIF

   IF ArrayStatus[ nPos, 9 ] = "1"
      StatusbarBuilder.Check_2.Value := .T.
   ELSEIF  ArrayStatus[ nPos, 9 ] = "0"
      StatusbarBuilder.Check_2.Value := .F.
   ENDIF

   IF ArrayStatus[ nPos, 1 ] $ "STATUSITEM,$CLOCK,$DATE,$KEYBOARD,$PROGRESSITEM"   
      IF ArrayStatus[ nPos, 4 ] # "NIL"                            //ACTION
         StatusbarBuilder.Text_2.Value := ArrayStatus[ nPos, 4 ]
      ENDIF

      IF ArrayStatus[ nPos, 3 ] # "NIL"                            //WIDTH  
         StatusbarBuilder.Text_3.Value := ArrayStatus[ nPos, 3 ]
      ENDIF

      IF ArrayStatus[ nPos, 5 ] # "NIL"                            //ICON
         StatusbarBuilder.Text_4.Value := ArrayStatus[ nPos, 5 ]
      ENDIF

      IF ArrayStatus[ nPos, 7 ]  # "NIL"                           //TOOLTIP
         StatusbarBuilder.Text_5.Value := ArrayStatus[ nPos, 7 ]
      ENDIF

      IF ArrayStatus[ nPos, 10 ] # "NIL"                           //RANGE
         StatusbarBuilder.Text_6.Value := ArrayStatus[ nPos, 10 ]
      ENDIF

      IF ArrayStatus[ nPos, 11 ]  # "NIL"                          //VALUE
         StatusbarBuilder.Text_7.Value := ""
      ENDIF

      IF ArrayStatus[ nPos, 12 ] # "NIL"                           //BACKCOLOR
         StatusbarBuilder.Text_8.Value := ArrayStatus[ nPos, 12 ]
      ENDIF

      IF ArrayStatus[ nPos, 13 ]  # "NIL"                          //FONTCOLOR
         StatusbarBuilder.Text_9.Value := ArrayStatus[ nPos, 13 ]
      ENDIF
   ENDIF

   lAction := .T.

RETURN


*------------------------------------------------------------*
PROCEDURE StatusOK()
*------------------------------------------------------------*
   IF !Empty( statusbarbuilder .Grid_1. cell( 1,1 ) ) // checking for empty statusitem
      statussaveall()
      lChanges := .T.
      IF IsControlDefined( StatusBar, Form_1 )
         DoMethod( "FORM_1", "STATUSBAR", "RELEASE" )
      ENDIF
      makestatus()
   ENDIF
   StatusbarBuilder.RELEASE

RETURN


*------------------------------------------------------------*
PROCEDURE StatusSaveAll()
*------------------------------------------------------------*
   LOCAL vArray AS ARRAY   := {}
   LOCAL cTitle AS STRING
   LOCAL cStat  AS STRING  := "DEFINE STATUSBAR"
   LOCAL cText  AS STRING
   LOCAL x      AS NUMERIC

   ** ** ** ** ** ** ** ** ** ** **
   * VALUES FROM STATUSBAR -> KEYBOARD FONT SIZE BOLD ITALIC UNDERLINE STRIKEOUT
   IF aStatusValues[ 1 ]
      cStat += " KEYBOARD"
   ENDIF

   cStat += " FONT " + '"' + aStatusValues[ 2 ] + '"'
   cStat += " SIZE " + AllTrim( Str( aStatusValues[ 3 ] ) )

   IF aStatusValues[ 4 ]
      cStat += " BOLD"
   ENDIF

   IF aStatusValues[ 5 ]
      cStat += " ITALIC"
   ENDIF

   IF aStatusValues[ 6 ]
      cStat += " UNDERLINE"
   ENDIF

   IF aStatusValues[ 7 ]
      cStat += " STRIKEOUT"
   ENDIF

   aAdd( vArray, Space( 5 ) + cStat )
   //cText2 := ""  // debug

   FOR x := 1 TO Len( ArrayStatus )
        // IF X = 1 
        //   MSGBOX(' VALUE = 1   ' +ArrayStatus[ x, 1 ] )
        // ENDIF  
  
       IF ArrayStatus[ x, 1 ] = "STATUSITEM"  .OR.  ArrayStatus[ x, 1 ] = "$STATUSITEM"
          cText := Space( 12 ) + "STATUSITEM " + '"' + ArrayStatus[ x, 2 ] + '"'

       ELSEIF ArrayStatus[ x, 1 ] = "$DATE" .OR.  ArrayStatus[ x, 1 ] = "DATE"
          cText := Space( 12 ) + "DATE"

       ELSEIF ArrayStatus[ x, 1 ] = "$CLOCK" .OR. ArrayStatus[ x, 1 ] = "CLOCK"
          cText := Space( 12 ) + "CLOCK"

       ELSEIF ArrayStatus[ x, 1 ] = "$KEYBOARD" .OR. ArrayStatus[ x, 1 ] = "KEYBOARD"
          cText := Space( 12 ) + "KEYBOARD"
          
       ELSEIF ArrayStatus[ x, 1 ] = "$PROGRESSITEM" .OR. ArrayStatus[ x, 1 ] = "PROGRESSITEM"
          cText := Space( 12 ) + "PROGRESSITEM"   
          
       ENDIF

       IF Len( AllTrim( ArrayStatus[ x, 3 ] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 3 ] ) # "NIL"
          cText += " WIDTH "  + AllTrim( ArrayStatus[ x, 3 ] )
       ENDIF
       IF Len( AllTrim( ArrayStatus[ x, 4 ] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 4 ] ) # "NIL"
          cText += " ACTION " + AllTrim( ArrayStatus[ x, 4 ] )
       ENDIF

       ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **
       IF Len( AllTrim( ArrayStatus[ x, 5 ] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 5 ] ) # "NIL"
          cText += " ICON " +      Op_HF( ArrayStatus[ x, 5 ], .T. )
       ENDIF

       IF ArrayStatus[ x, 6 ] = "2"
          cText += " FLAT "
       ELSEIF ArrayStatus[ x, 6 ] = "3"
          cText += " RAISED "
       ENDIF

       ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** *
       IF Len( AllTrim( ArrayStatus[ x, 7 ] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 7 ] ) # "NIL"
          cText += " TOOLTIP " +   Op_HF( ArrayStatus[ x, 7 ], .T. )
       ENDIF

       ** ** ** ** ** ** ** ** ** ** ** ** ** **
       IF ArrayStatus[ x, 8 ] = "1"
          cText += " DEFAULT "
       ENDIF

       IF ArrayStatus[ x, 9 ] = "1"
          cText += " AMPM "
       ENDIF
       
       IF Len( AllTrim( ArrayStatus[ x, 10 ] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 10 ] ) # "NIL"
          cText += " RANGE " +     Op_HF( ArrayStatus[ x, 10 ], .T. )
       ENDIF

       IF Len( AllTrim( ArrayStatus[ x, 11] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 11 ] ) # "NIL"         
          cText += " VALUE " +     Op_HF( ArrayStatus[ x, 11 ], .T. )
       ENDIF
       
       IF Len( AllTrim( ArrayStatus[ x, 12 ] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 12 ] ) # "NIL"       
          cText += " BACKCOLOR " + Op_HF( ArrayStatus[ x, 12 ], .T., "{" )
       ENDIF

       IF Len( AllTrim( ArrayStatus[ x, 13] ) ) > 0 .AND. AllTrim( ArrayStatus[ x, 13 ] ) # "NIL"         
          cText += " FONTCOLOR " + Op_HF( ArrayStatus[ x, 13 ], .T., "{" )
       ENDIF
            
              
       

       ** ** ** ** ** ** ** ** ** ** ** ** ** **
       aAdd( vArray, cText )
       //cText2 += cText // debug
   NEXT X

   aAdd( vArray, Space( 5 ) + "END STATUSBAR" )

   aStatus := vArray  // SAVE ALL VALUES TO aStatus
   
    //MSGBOX(SPACE(5)+CSTAT+CRLF+cText2+CRLF+SPACE(5)+ "END STATUSBAR" )// debug
RETURN


*------------------------------------------------------------*
PROCEDURE StatusCancel()
*------------------------------------------------------------*
   StatusbarBuilder.RELEASE
RETURN

*------------------------------------------------------------*
PROCEDURE StatusDefaultChange()  // Change Procedures
*------------------------------------------------------------*
   IF LACTION = .F.
      RETURN
   ENDIF
   IF statusbarbuilder .Text_1. VALUE # "$DATE" .AND.  statusbarbuilder .Text_1. VALUE # "$CLOCK" .AND.  statusbarbuilder .Text_1. VALUE # "$KEYBOARD" .AND. statusbarbuilder .Text_1. VALUE # "$PROGRESSITEM"
      ArrayStatus[StatusbarBuilder.Grid_1.Value,8] := iif( StatusbarBuilder.check_1.Value = .T. , "1", "0" )
      * MAYBE ONLY ONE ITEM HAS DEFAULT AND HAVE TO CHANGE ALL
   ELSE
      laction := .F.
      StatusbarBuilder.check_1.Value := .F.
      laction := .T.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusAmPmChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   IF StatusbarBuilder.Text_1.Value = "$CLOCK"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 9 ] := iif( StatusbarBuilder.Check_2.Value, "1", "0" )
   ELSE
      lAction                        := .F.
      StatusbarBuilder.Check_2.Value := .F.
      lAction                        := .T.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusCaptionChange()
*------------------------------------------------------------*
   LOCAL nPos    AS NUMERIC
   LOCAL nValue  AS NUMERIC

   // $DATE $CLOCK $KEYBOARD
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "captionchange" )
   // MsgBox( "VALUE= " + Str( StatusbarBuilder.Text_1.CARETPOS ) )
   nPos := StatusbarBuilder.Text_1.CaretPos

   IF StatusbarBuilder.Text_1.Value = "$DATE"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] := "$DATE"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 5 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ] := "1"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 8 ] := "0"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 9 ] := "0"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 12 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 13 ] := ""


   ELSEIF StatusbarBuilder.Text_1.Value = "$CLOCK"
   //MSGBOX('CLOCK')
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,1 ] := "$CLOCK"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,5 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,6 ] := "1"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,8 ] := "0"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,9 ] := "0"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ] := ""

   ELSEIF StatusbarBuilder.Text_1.Value = "$KEYBOARD"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,1 ] := "$KEYBOARD"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,5 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,6 ] := "1"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,8 ] := "0"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,9 ] := "0"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 12 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 13 ] := ""

      
    ELSEIF StatusbarBuilder.Text_1.Value = "$PROGRESSITEM"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,1 ] := "$PROGRESSITEM"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,5 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,6 ] := "1"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,8 ] := "0"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,9 ] := "0" 
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 12 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 13 ] := ""
  
      
   ELSE
      ArrayStatus[ StatusbarBuilder.Grid_1.Value,1 ] = "STATUSITEM"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ] := ""
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ] := ""
   ENDIF

   ArrayStatus[ StatusbarBuilder.Grid_1.Value, 2 ] := StatusbarBuilder.Text_1.Value  //Caption

   nValue := StatusbarBuilder.Grid_1.Value

   StatusFillGrid()

   StatusbarBuilder.Grid_1.Value := nValue
   // MsgBox( "VALUE= " + Str( StatusbarBuilder.Text_1.CARETPOS ) )

   StatusbarBuilder.Text_1.CaretPos := nPos

RETURN


*------------------------------------------------------------*
PROCEDURE StatusActionChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "actionchange" )

   ArrayStatus[ StatusbarBuilder.Grid_1.Value, 4 ] := StatusbarBuilder.Text_2.Value

RETURN


*------------------------------------------------------------*
PROCEDURE StatusWidthChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "widthchange" )

   ArrayStatus[ StatusbarBuilder.Grid_1.Value, 3 ] := StatusbarBuilder.Text_3.Value

RETURN


*------------------------------------------------------------*
PROCEDURE StatusIconChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "iconchange" )
   IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "STATUSITEM"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 5 ] := StatusbarBuilder.Text_4.Value
   ELSE
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 5 ] := ""

      lAction                       := .F.  //? Is it necessary to swith lAction Here ->YES
      StatusbarBuilder.Text_4.Value := ""
      lAction                       := .T.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusToolTipChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "tooltipchange" )

   ArrayStatus[ StatusbarBuilder.Grid_1.Value, 7 ] := StatusbarBuilder.Text_5.Value

RETURN


*------------------------------------------------------------*
PROCEDURE StatusStyleChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "stylechange" )

   IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "STATUSITEM"
      IF StatusbarBuilder.Combo_1.Value = 1
         ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ] := "1"

      ELSEIF StatusbarBuilder.Combo_1.Value = 2
         ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ] := "2"

      ELSEIF StatusbarBuilder.Combo_1.Value = 3
         ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ] := "3"
      ENDIF
   ELSE
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ]    := "0"

      lAction                          := .F.  //? Is it necessary to switch lAction Here ->YES
      StatusbarBuilder.Combo_1.Value   := 1
      lAction                          := .T.
   ENDIF

RETURN

*------------------------------------------------------------*
PROCEDURE StatusRangeChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "rangechange" )
   IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "$PROGRESSITEM"      
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ] := StatusbarBuilder.Text_6.Value
   ELSE
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ] := ""

      lAction                       := .F.  //? Is it necessary to swith lAction Here ->YES
      StatusbarBuilder.Text_6.Value := ""
      lAction                       := .T.
   ENDIF

RETURN

*------------------------------------------------------------*
PROCEDURE StatusValueChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "valuechange" )
   IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "$PROGRESSITEM"
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ] := StatusbarBuilder.Text_7.Value
   ELSE
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ] := ""

      lAction                       := .F.  //? Is it necessary to swith lAction Here ->YES
      StatusbarBuilder.Text_7.Value := ""
      lAction                       := .T.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusBackColorChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "backcolorchange" )
   IF (ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "STATUSITEM" .OR. ; // ICON EMPTY
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "$DATE"      .OR. ;
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "$CLOCK"  )  .AND. ;
      EMPTY(ArrayStatus[ StatusbarBuilder.Grid_1.Value, 5 ]) 
         
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 12 ] := StatusbarBuilder.Text_8.Value     
   ELSE
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 12 ] := ""

      lAction                       := .F.  //? Is it necessary to swith lAction Here ->YES
      StatusbarBuilder.Text_8.Value := ""
      lAction                       := .T.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusFontColorChange()
*------------------------------------------------------------*
   IF lAction = .F.
      RETURN
   ENDIF

   // MsgBox( "fontcolorchange" )
   IF (ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "STATUSITEM" .OR. ; // ICON EMPTY
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "$DATE"      .OR. ;
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ] = "$CLOCK" )   .AND. ;
      EMPTY(ArrayStatus[ StatusbarBuilder.Grid_1.Value, 5 ]) 
      
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 13 ] := StatusbarBuilder.Text_9.Value
   ELSE
      ArrayStatus[ StatusbarBuilder.Grid_1.Value, 13 ] := ""

      lAction                       := .F.  //? Is it necessary to swith lAction Here ->YES
      StatusbarBuilder.Text_9.Value := ""
      lAction                       := .T.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusUp()
*------------------------------------------------------------*
   LOCAL tValue AS NUMERIC
   LOCAL xTemp  AS NUMERIC

   IF StatusbarBuilder.Grid_1.Value > 1

      tValue                    := StatusbarBuilder.Grid_1.Value
      xTemp                     := ArrayStatus[ tValue     ]
      ArrayStatus[ tValue     ] := ArrayStatus[ tValue - 1 ]
      ArrayStatus[ tValue - 1 ] := xTemp

      StatusFillGrid()

      StatusbarBuilder.Grid_1.Value := tValue - 1

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusDown()
*------------------------------------------------------------*
   LOCAL tValue AS NUMERIC //? Invalid Hungarian
   LOCAL xTemp  AS NUMERIC //? Invalid Hungarian

   IF StatusbarBuilder.Grid_1.Value < StatusbarBuilder.Grid_1.ItemCount .AND. ;
      StatusbarBuilder.Grid_1.Value > 0

      tValue                    := Statusbarbuilder.Grid_1.Value
      xTemp                     := ArrayStatus[ tValue     ]
      ArrayStatus[ tValue     ] := ArrayStatus[ tValue + 1 ]
      ArrayStatus[ tValue + 1 ] := xTemp

      StatusFillGrid()

      StatusbarBuilder.Grid_1.Value := tValue + 1

   ENDIF


*------------------------------------------------------------*
PROCEDURE StatusNext()
*------------------------------------------------------------*
   LOCAL xValue AS ARRAY //? Invalid Hungarian

   IF StatusbarBuilder.Grid_1.Value < StatusbarBuilder.Grid_1.ItemCount
      StatusbarBuilder.Grid_1.Value := StatusbarBuilder.Grid_1.Value + 1
      StatusGridChange()
   ELSE
      IF Empty( aTail( ArrayStatus )[2] )
         StatusDelete()
      ENDIF
     xValue := { "STATUSITEM"   ,"New Item" ,"NIL"  ,"NIL"    ,"NIL" ,"1"    ,"NIL"    ,"NIL"    ,"NIL" ,"NIL"   ,"NIL"   ,"NIL"       ,"NIL"}
             //   1-TYPE        2-CAPTION   3-WIDTH  4-ACTION 5-ICON 6-STYLE 7-TOOLTIP 8-DEFAULT 9-AMPM 10 RANGE 11-VALUE 12-BACKCOLOR 13-FONTCOLOR
    
      aAdd( ArrayStatus, xValue )
      StatusbarBuilder.Grid_1.AddItem( { aTail( ArrayStatus )[2] } )

      StatusbarBuilder.Grid_1.Value := StatusbarBuilder.Grid_1.ItemCount
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusPrior()
*------------------------------------------------------------*
   IF StatusbarBuilder.Grid_1.Value > 1

      StatusbarBuilder.Grid_1.Value := StatusbarBuilder.Grid_1.Value - 1

      StatusGridChange()
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusInsert()
*------------------------------------------------------------*
   LOCAL xValue AS NUMERIC  //? Invalid Hungarian
   LOCAL tValue AS NUMERIC  //? Invalid Hungarian

   IF StatusbarBuilder.Grid_1.Value > 0
      xValue := { "STATUSITEM"   ,"New Item" ,"NIL"  ,"NIL"    ,"NIL" ,"1"    ,"NIL"    ,"NIL"    ,"NIL" ,"NIL"   ,"NIL"    ,"NIL"       ,"NIL" }
              //   1-TYPE        2-CAPTION   3-WIDTH  4-ACTION 5-ICON 6-STYLE 7-TOOLTIP 8-DEFAULT 9-AMPM 10 RANGE 11-VALUE  12-BACKCOLOR 13-FONTCOLOR
      // MsgBox( "len ArrayStatus1= " + Str( Len( ArrayStatus ) ) )

      aSize( ArrayStatus, Len( ArrayStatus ) + 1 )
      // MsgBox( "len ArrayStatus2= " + Str( Len( ArrayStatus ) ) )
      // MsgBox( "LEN GRID= " + Str( StatusbarBuilder.Grid_1.Value ) )

      aIns( ArrayStatus, StatusbarBuilder.Grid_1.Value )

      ArrayStatus[ StatusbarBuilder.Grid_1.Value ] := xValue
      tValue                                       := StatusbarBuilder.Grid_1.Value

      StatusFillGrid()

      StatusbarBuilder.Grid_1.Value := tValue
      StatusGridChange()

   ELSE
      // MsgBox( "execute StatusNext" )
      StatusNext()
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusDelete()
*------------------------------------------------------------*
   LOCAL tValue AS NUMERIC  //? Invalid Hungarian

   IF StatusbarBuilder.Grid_1.ItemCount > 1

      // MsgBox( "len ArrayStatus1= " + Str( Len( ArrayStatus ) ) )
      aDel( ArrayStatus, StatusbarBuilder.Grid_1.Value )
      aSize( ArrayStatus, Len( ArrayStatus ) - 1 )
      // MsgBox( "len ArrayStatus2= " + Str( Len( ArrayStatus ) ) )

      tValue := StatusbarBuilder.Grid_1.Value

      StatusFillGrid()

      IF tValue > 1
         StatusbarBuilder.Grid_1.Value := tValue - 1
      ELSE
         StatusbarBuilder.Grid_1.Value := tValue
      ENDIF
      //IF Len( ArrayStatus ) = 0
      //   StatusNext()
      //ENDIF
   ELSE
      //   MsgBox( "len ArrayStatus3= " + Str( Len( ArrayStatus ) ) )
      ArrayStatus[ 1 ] := { "", "", "", "NIL", "NIL", "1", "NIL", "NIL", "NIL", "NIL", "NIL", "NIL", "NIL" }

      StatusFillGrid()

      StatusbarBuilder.Grid_1.Value := 1

      StatusGridChange()

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE StatusGridChange()                             //OPT
*------------------------------------------------------------*
   LOCAL TMPSTR AS USUAL //? VarType

   IF lAction = .F.
      RETURN
   ENDIF

   lAction = .F.

   // MsgBox( "value= " + Str( StatusbarBuilder.Grid_1.Value ), "GRIDCHANGE" )
   IF StatusbarBuilder.Grid_1.ItemCount > 0

      StatusbarBuilder.Text_1.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 2 ]       //CAPTION

      TMPSTR := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 1 ]

      IF TMPSTR $ "STATUSITEM,$CLOCK,$DATE,$KEYBOARD,$PROGRESSITEM"                          //ACTION 
         StatusbarBuilder.Text_2.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 4 ]

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 3 ] # "NIL"                          //WIDTH  
            StatusbarBuilder.Text_3.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 3 ]
         ELSE
            Statusbarbuilder.Text_3.Value := ""
         ENDIF

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 5 ] # "NIL"                          //ICON
            StatusbarBuilder.Text_4.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 5 ]
         ELSE
            StatusbarBuilder.Text_4.Value := ""
         ENDIF

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 7 ]  # "NIL"                           //TOOLTIP
            StatusbarBuilder.Text_5.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 7 ]
         ELSE
            StatusbarBuilder.Text_5.Value := ""
         ENDIF

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ] = "1"                           //STYLE
            StatusbarBuilder.Combo_1.Value := 1

         ELSEIF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ] = "2"
            StatusbarBuilder.Combo_1.Value := 2

         ELSEIF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 6 ] = "3"
            StatusbarBuilder.Combo_1.Value := 3

         ELSE
            StatusbarBuilder.Combo_1.Value := 1
         ENDIF

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 8 ] = "1"
            StatusbarBuilder.Check_1.Value := .T.
         ELSE
            StatusbarBuilder.Check_1.Value := .F.
         ENDIF

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 9 ] = "1"
            StatusbarBuilder.CHECK_2.Value := .T.

         ELSEIF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 9 ] = "0"
            StatusbarBuilder.CHECK_2.Value := .F.
         ENDIF
         
         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ] # "NIL"                            //RANGE
            StatusbarBuilder.Text_6.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 10 ]
         ELSE
            StatusbarBuilder.Text_6.Value := ""
         ENDIF

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ]  # "NIL"                           //VALUE
            StatusbarBuilder.Text_7.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 11 ]
         ELSE
            StatusbarBuilder.Text_7.Value := ""
         ENDIF
         
         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 12 ] # "NIL"                            //BACKCOLOR
            StatusbarBuilder.Text_8.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 12 ]
         ELSE
            StatusbarBuilder.Text_8.Value := ""
         ENDIF

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 13 ]  # "NIL"                           //FONTCOLOR
            StatusbarBuilder.Text_9.Value := ArrayStatus[ StatusbarBuilder.Grid_1.Value, 13 ]
         ELSE
            StatusbarBuilder.Text_9.Value := ""
         ENDIF
         

      ELSE
         StatusbarBuilder.Text_2.Value  := ""
         StatusbarBuilder.Text_3.Value  := ""
         StatusbarBuilder.Text_4.Value  := ""
         StatusbarBuilder.Text_5.Value  := ""
         StatusbarBuilder.Text_6.Value  := ""
         StatusbarBuilder.Text_7.Value  := ""
         StatusbarBuilder.Text_8.Value  := ""
         StatusbarBuilder.Text_9.Value  := ""
         StatusbarBuilder.Combo_1.Value := 1

         IF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 9 ] =  "1"
            StatusbarBuilder.Check_2.Value := .T.

         ELSEIF ArrayStatus[ StatusbarBuilder.Grid_1.Value, 9 ] =  "0"
            StatusbarBuilder.Check_2.Value := .F.
         ENDIF
      ENDIF
   ELSE
      StatusbarBuilder.Text_1.Value  := ""
      StatusbarBuilder.Text_2.Value  := ""
      StatusbarBuilder.Text_3.Value  := ""
      StatusbarBuilder.Text_4.Value  := ""
      StatusbarBuilder.Text_5.Value  := ""
      StatusbarBuilder.Text_6.Value  := ""
      StatusbarBuilder.Text_7.Value  := ""
      StatusbarBuilder.Text_8.Value  := ""
      StatusbarBuilder.Text_9.Value  := ""
      StatusbarBuilder.Combo_1.Value := 0
      StatusbarBuilder.CHECK_1.Value := .F.
      StatusbarBuilder.CHECK_2.Value := .F.
   ENDIF

   lAction := .T.

RETURN


*------------------------------------------------------------*
PROCEDURE StatusFillGrid()
*------------------------------------------------------------*
   LOCAL xValue AS NUMERIC  //? Invalid Hungarian
   LOCAL x      AS NUMERIC

   lAction := .F.

   StatusbarBuilder.Grid_1.DeleteAllitems

   FOR x := 1 TO Len( ArrayStatus )
       xValue := ArrayStatus[ x, 2 ]
       // MsgBox( "x= " + Str( x ) + " " + xvalue)
       StatusbarBuilder.Grid_1.AddItem( { xValue } )
   NEXT x

   lAction := .T.

RETURN


*------------------------------------------------------------*
FUNCTION StatusItens( cLine AS STRING, cStatControl AS STRING )
*------------------------------------------------------------*
    LOCAL aStatusItens AS ARRAY   := { NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL , NIL, NIL  }
    LOCAL nCaption     AS NUMERIC := At( cStatControl, cLine ) 
    LOCAL nWidth       AS NUMERIC := At( "WIDTH"     , cLine ) 
    LOCAL nAction      AS NUMERIC := At( "ACTION"    , cLine ) 
    LOCAL nIcon        AS NUMERIC := At( "ICON"      , cLine ) 
    LOCAL nStyle1      AS NUMERIC := At( "FLAT"      , cLine ) 
    LOCAL nStyle2      AS NUMERIC := At( "RAISED"    , cLine ) 
    LOCAL nToolTip     AS NUMERIC := At( "TOOLTIP"   , cLine ) 
    LOCAL nDefault     AS NUMERIC := At( "DEFAULT"   , cLine ) 
    LOCAL nAmPm        AS NUMERIC := At( "AMPM"      , cLine ) 
    LOCAL nRange       AS NUMERIC := At( "RANGE"     , cLine ) 
    LOCAL nValue       AS NUMERIC := At( "VALUE"     , cLine ) 
    LOCAL nBackColor   AS NUMERIC := At( "BACKCOLOR" , cLine ) 
    LOCAL nFontColor   AS NUMERIC := At( "FONTCOLOR" , cLine ) 
   
   
 // MSGBOX('cLine= ' + cLine )
 //MSGBOX('len aStatusItens= ' + str(len(aStatusItens)) ) //=11
 //msgbox('nCaption = ' + str(nCaption) + ' cStatControl = ' + cStatControl )
   IF nCaption > 0 .AND. cStatControl = "STATUSITEM"
      IF nWidth > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nWidth   - nCaption - 11 )
      ELSEIF nAction > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nAction  - nCaption - 11 )
      ELSEIF nIcon > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nIcon    - nCaption - 11 )
      ELSEIF nStyle1 > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nStyle1  - nCaption - 11 )
      ELSEIF nStyle2 > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nStyle2  - nCaption - 11 )
      ELSEIF nToolTip > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nToolTip - nCaption - 11 )
      ELSEIF nDefault > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nDefault - nCaption - 11 )
      ELSEIF nBackColor > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nBackColor - nCaption - 11 )
      ELSEIF nFontColor > 0
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11, nFontColor - nCaption - 11 )
                        
      ELSE
          aStatusItens[ 1 ] := SubStr( cLine, nCaption + 11 ) + " "
      ENDIF
          aStatusItens[ 1 ] := SubStr( aStatusItens[ 1 ], 2, Len( aStatusItens[ 1 ] ) - 3 )

   ELSEIF nCaption > 0 .AND. cStatControl = "DATE"  
          aStatusItens[ 1 ] := "$DATE"

   ELSEIF nCaption > 0 .AND. cStatControl = "CLOCK"
          aStatusItens[ 1 ] := "$CLOCK"
          
   ELSEIF nCaption > 0 .AND. cStatControl = "KEYBOARD"
          aStatusItens[ 1 ] := "$KEYBOARD"
          
   ELSEIF nCaption > 0 .AND. cStatControl = "PROGRESSITEM"
          aStatusItens[ 1 ] := "$PROGRESSITEM" 
   ELSE
           aStatusItens[ 1 ] := cStatControl 
          // MSGBOX('aStatusItens[ 1 ] = ' + aStatusItens[ 1 ] ) // = STATUSITEM ??

   ENDIF

   IF nWidth > 0
      IF nAction > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nAction  - nWidth - 6 )

      ELSEIF nIcon > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nIcon    - nWidth - 6 )

      ELSEIF nStyle1 > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nStyle1  - nWidth - 6 )

      ELSEIF nStyle2 > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nStyle2  - nWidth - 6 )
 
      ELSEIF nToolTip > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nToolTip - nWidth - 6 )

      ELSEIF nDefault > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nDefault - nWidth - 6 )

      ELSEIF nAmPm > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nAmPm    - nWidth - 6 )
         
      ELSEIF nRange > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nRange   - nWidth - 6 )
         
      ELSEIF nValue > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nValue   - nWidth - 6 )
          
      ELSEIF nBackColor > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nBackColor  - nWidth - 6 )
         
      ELSEIF nFontColor > 0
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6, nFontColor  - nWidth - 6 )
              
                            
      ELSE
          aStatusItens[ 2 ] := SubStr( cLine, nWidth + 6 )
      ENDIF
   ELSE
          aStatusItens[ 2 ] := ""
   ENDIF

   IF nAction > 0
      IF nIcon > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nIcon    - nAction - 7 )

      ELSEIF nStyle1 > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nStyle1  - nAction - 7 )

      ELSEIF nStyle2 > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nStyle2  - nAction - 7 )

      ELSEIF nToolTip > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nToolTip - nAction - 7 )

      ELSEIF nDefault > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nDefault - nAction - 7 )

      ELSEIF nAmPm > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nAmPm    - nAction - 7 )
         
      ELSEIF nRange > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nRange    - nAction - 7 )
         
      ELSEIF nValue > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nValue    - nAction - 7 )   
          
      ELSEIF nBackColor > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nBackColor  - nAction - 7 )
         
      ELSEIF nFontColor > 0
          aStatusItens[ 3 ] := SubStr( cLine, nAction + 7, nFontColor  - nAction - 7 )   
    

      ELSE
         aStatusItens[ 3 ] := SubStr( cLine, nAction + 7 )
      ENDIF
   ELSE
         aStatusItens[ 3 ] := ""
   ENDIF

   IF nIcon > 0
      IF nStyle1 > 0
         aStatusItens[ 4 ] := SubStr( cLine, nIcon + 5, nStyle1  - nIcon - 5 )

      ELSEIF nStyle2 > 0
         aStatusItens[ 4 ] := SubStr( cLine, nIcon + 5, nStyle2  - nIcon - 5 )

      ELSEIF nToolTip > 0
         aStatusItens[ 4 ] := SubStr( cLine, nIcon + 5, nToolTip - nIcon - 5 )

      ELSEIF nDefault > 0
         aStatusItens[ 4 ] := SubStr( cLine, nIcon + 5, nDefault - nIcon - 5 )      

      ELSE
         aStatusItens[ 4 ] := SubStr( cLine, nIcon + 5 )
      ENDIF
   ELSE
         aStatusItens[ 4 ] := ""
   ENDIF

         aStatusItens[ 4 ] := Op_HF( aStatusItens[4] )

   IF nStyle1 > 0
         aStatusItens[ 5 ] := "2" //FLAT

   ELSEIF nStyle2 > 0
         aStatusItens[ 5 ] := "3" //RAISED
 
   ELSE
         aStatusItens[ 5 ] := "1" //NORMAL
   ENDIF

   IF nToolTip > 0
      IF nDefault > 0
         aStatusItens[ 6 ] := SubStr( cLine, nToolTip + 8, nDefault - nToolTip - 8 )
      ELSEIF nAmPm > 0
         aStatusItens[ 6 ] := SubStr( cLine, nToolTip + 8, nAmPm    - nToolTip - 8 )
      ELSEIF nRange > 0
         aStatusItens[ 6 ] := SubStr( cLine, nToolTip + 8, nRange   - nToolTip - 8 )
      ELSEIF nValue > 0
         aStatusItens[ 6 ] := SubStr( cLine, nToolTip + 8, nValue   - nToolTip - 8 )   
      ELSEIF nBackColor > 0
         aStatusItens[ 6 ] := SubStr( cLine, nToolTip + 8, nBackColor - nToolTip - 8 )
      ELSEIF nFontColor > 0
         aStatusItens[ 6 ] := SubStr( cLine, nToolTip + 8, nFontColor - nToolTip - 8 )              
         
      ELSE
         aStatusItens[ 6 ] := SubStr( cLine, nToolTip + 8 )
      ENDIF
   ELSE
         aStatusItens[ 6 ] := ""
   ENDIF

         aStatusItens[ 6 ] := Op_HF( aStatusItens[6] )

   IF nDefault > 0
         aStatusItens[ 7 ] := "1" // DEFAULT
   ELSE
         aStatusItens[ 7 ] := "0" // NO DEFAULT
   ENDIF

   IF nAmPm > 0
         aStatusItens[ 8 ] := "1" // AMPM
   ELSE
         aStatusItens[ 8 ] := "0" // NO AMPM
   ENDIF
   **************************FALTA TESTAR
   
   IF nRange > 0
      IF nValue > 0
         aStatusItens[ 9 ] := SubStr( cLine, nRange + 6, nValue - nRange - 6 )               
      ELSE  
         aStatusItens[ 9 ] := SubStr( cLine, nRange + 6 )
      ENDIF
   ELSE   
         aStatusItens[ 9 ] := ""               
   ENDIF

   IF nValue > 0
         aStatusItens[ 10 ] := SubStr( cLine, nValue + 6 )
   ELSE
         aStatusItens[ 10 ] := ""  
   ENDIF  
    
    
   IF nBackColor > 0
      IF nFontColor > 0
         aStatusItens[ 11 ] := SubStr( cLine, nBackColor + 10, nFontColor - nBackColor - 10 )               
      ELSE  
         aStatusItens[ 11 ] := SubStr( cLine, nBackColor + 10 )
      ENDIF
   ELSE   
         aStatusItens[ 11 ] := ""               
   ENDIF

   IF nFontColor > 0
         aStatusItens[ 12 ] := SubStr( cLine, nFontColor + 10 )
   ELSE
         aStatusItens[ 12 ] := ""  
   ENDIF  
   
   /*                            
   MsgBox( "as1-Caption= " + aStatusItens[ 1 ] + CRLF +;
           "as2-Width= " + aStatusItens[ 2 ] + CRLF +;
           "as3-Action= " + aStatusItens[ 3 ] + CRLF +;
           "as4-Icon= " + aStatusItens[ 4 ] + CRLF +;
           "as5-Style= " + aStatusItens[ 5 ] + CRLF +;
           "as6-Tooltip= " + aStatusItens[ 6 ] + CRLF +;
           "as7-Default= " + aStatusItens[ 7 ] + CRLF +;
           "as8-AMPM= " + aStatusItens[ 8 ] + CRLF +;
           "as9-Range= " + aStatusItens[ 9 ] + CRLF +;
           "as10-Value=" + aStatusItens[ 10 ] + CRLF +;
           "as11-BackColor=" + aStatusItens[ 11 ] + CRLF +;
           "as12-FontColor=" + aStatusItens[ 12 ] )                      
   */

RETURN( aStatusItens )
