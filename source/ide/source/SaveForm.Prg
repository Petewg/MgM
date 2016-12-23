#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW ObjectInspector
DECLARE WINDOW ProjectBrowser

*------------------------------------------------------------*
PROCEDURE SaveForm()
*------------------------------------------------------------*
   LOCAL i             AS NUMERIC
   LOCAL h             AS NUMERIC
   LOCAL BaseRow       AS NUMERIC
   LOCAL BaseCol       AS NUMERIC
   LOCAL BaseWidth     AS NUMERIC
   LOCAL BaseHeight    AS NUMERIC
   LOCAL TitleHeight   AS NUMERIC
   LOCAL MenuBarHeight AS NUMERIC
   LOCAL BorderWidth   AS NUMERIC
   LOCAL BorderHeight  AS NUMERIC
   LOCAL aTempNames    AS ARRAY
   LOCAL Name          AS STRING
   LOCAL Row           AS NUMERIC
   LOCAL Col           AS NUMERIC
   LOCAL Width         AS NUMERIC
   LOCAL height        AS NUMERIC
   LOCAL nItem         AS NUMERIC
   LOCAL Output        AS STRING
   LOCAL x4            AS STRING
   LOCAL j             AS NUMERIC
   LOCAL p             AS NUMERIC
   LOCAL k             AS NUMERIC
   LOCAL l
   LOCAL iL            AS NUMERIC   := 1
   LOCAL noSplit       AS LOGICAL   := .F.
   LOCAL blOut         AS CODEBLOCK := {|k| aEval( k, { | x | Output += x + CRLF } ) }
   LOCAL y             AS NUMERIC
   LOCAL z             AS NUMERIC
   LOCAL cValue
   LOCAL ArrayTemp     AS ARRAY     := {}
   LOCAL cWorkArea     AS STRING    := ""
   LOCAL lSaveAll      AS LOGICAL   := iif( aData[ _SAVEOPTIONS ] = "2", .T., .F. )
   LOCAL V1            AS STRING
   LOCAL aImage
   LOCAL aCaption
   LOCAL aToolTip
   LOCAL nHandle

   IF ! IsWindowDefined( Form_1 )
     RETURN
   ENDIF

   aEval( aTempDeletedControls, { | nItem | SavePath(  nItem, "NIL" ) } )
   aEval( aTempDeletedControls, { | nItem | SaveAlias( nItem, "NIL" ) } )

   //?
   /* I think here we have to add some line of code */
   /* To delete other things in *.ini  file         */

   ObjectInspector.xGrid_1.DisableUpdate
   ObjectInspector.xGrid_2.DisableUpdate

   h             := GetFormHandle( DesignForm )
   l             := Len( _HMG_aControlHandles )
   BaseRow       := GetWindowRow( h )
   BaseCol       := GetWindowCol( h )
   BaseWidth     := GetWindowWidth( h )
   BaseHeight    := GetWindowHeight( h )
   TitleHeight   := GetTitleHeight()
   MenuBarHeight := GetMenuBarHeight()
   BorderWidth   := GetBorderWidth()
   BorderHeight  := GetBorderHeight()
   aTempNames    := aClone( _HMG_aControlNames )

   Output := "*HMGS-MINIGUI-IDE Two-Way Form Designer Generated Code"
   Output += CRLF
   Output += "*OPEN SOURCE PROJECT 2005-2016 Walter Formigoni http://sourceforge.net/projects/hmgs-minigui/"
   Output += CRLF
   Output += CRLF

   IF Len( cTextNotes ) > 0
      Output += cTextNotes + CRLF + CRLF
   ENDIF

   Output += "DEFINE WINDOW TEMPLATE "

   IF AllTrim( xProp[ 28 ] ) # "SPLITCHILD"
      noSplit := .T.
      Output  += "AT " + AllTrim( Str( BaseRow ) ) + " , " + AllTrim( Str( BaseCol ) )
   ENDIF

   Output += " WIDTH " + AllTrim( Str( BaseWidth ) ) + " HEIGHT " + AllTrim( Str( BaseHeight ) )

   ************************************************
   IF Val( AllTrim( xProp[ 29 ] ) ) > Val( AllTrim( Str( BaseWidth ) ) )
      v1     := AllTrim( xProp[ 29 ] )
      Output += " VIRTUAL WIDTH " + V1
   ELSEIF lSaveAll
      Output += " VIRTUAL WIDTH NIL"
   ENDIF

   IF Val( AllTrim( xProp[ 30 ] ) ) > Val( AllTrim( Str( BaseHeight ) ) )
      v1     := AllTrim( xProp[ 30 ] )
      Output += " VIRTUAL HEIGHT " + V1
   ELSEIF lSaveAll
      Output += " VIRTUAL HEIGHT NIL"
   ENDIF

   *************************************************
   IF Upper( AllTrim( xProp[ 13 ] ) ) # "NIL"
      v1     := AllTrim( xProp[ 13 ] )
      Output += " MINWIDTH " + V1
   ENDIF

   IF Upper( AllTrim( xProp[ 14 ] ) ) # "NIL"
      v1     := AllTrim( xProp[ 14 ] )
      Output += " MINHEIGHT " + V1
   ENDIF

   IF Upper( AllTrim( xProp[ 15 ] ) ) # "NIL"
      v1     := AllTrim( xProp[ 15 ] )
      Output += " MAXWIDTH " + V1
   ENDIF

   IF Upper( AllTrim( xProp[ 16 ] ) ) # "NIL"
      v1     := AllTrim( xProp[ 16 ] )
      Output += " MAXHEIGHT " + V1
   ENDIF

   *************************************************
   v1     := AllTrim(xProp[ 23 ] )
   Output += iif( V1 = '""' .OR. Empty( V1 ), iif( lSaveAll, " TITLE NIL", "" ), " TITLE " + V1 )

   IF nosplit
      v1     := AllTrim(xProp[10] )
      Output += iif( V1 = '""' .OR. Empty( V1 ), iif( lSaveAll, " ICON NIL", "" ), " ICON " + V1 )
   ENDIF

   v1 := AllTrim( xProp[ 28 ] )  // " MAIN", "CHILD" Etc.
   IF v1 # "STANDARD"
      IF v1 = "MAINMDI"
         Output += Space( 1 ) + "MAIN MDI "
      ELSE
         Output += Space( 1 )+ V1
      ENDIF
   ENDIF

   v1 := AllTrim( xProp[ 26 ] )
   IF V1 = ".F."
      Output += " NOSHOW"
   ENDIF

   v1 := xProp[ 25 ]
   IF V1 = ".T."
      Output += " TOPMOST"
   ENDIF

   v1 := xProp[ 19 ]
   IF V1 = ".T."
      Output += " PALETTE"
   ENDIF

   v1 := AllTrim( xProp[ 1 ] )
   IF V1 = ".F."
      Output += " NOAUTORELEASE"
   ENDIF

   v1 := AllTrim( xProp[ 12 ] )
   IF V1 = ".F." .AND. AllTrim( xProp[ 28 ] ) # "MODAL"
      Output += " NOMINIMIZE"
   ENDIF

   v1 := AllTrim( xProp[ 11 ] )
   IF V1 = ".F." .AND. AllTrim( xProp[ 28 ] ) # "MODAL"
      Output += " NOMAXIMIZE"
   ENDIF

   v1 := AllTrim( xProp[ 21 ] )
   IF V1 = ".F."
      Output += " NOSIZE"
   ENDIF

   v1 := AllTrim( xProp[ 22 ] )
   IF V1 = ".F."
      Output += " NOSYSMENU"
   ENDIF

   v1 := AllTrim( xProp[ 24 ] )
   IF V1 = ".F."
      Output += " NOCAPTION"
   ENDIF

   v1     := AllTrim( xProp[ 5 ] )
   Output += iif( V1= '""' .OR. Empty(V1), iif( lSaveAll, " CURSOR NIL", "" ), " CURSOR " + V1 )

   IF Nosplit = .F.
      v1     := AllTrim( xProp[ 7 ] )
      Output += iif( Empty(V1), iif( lSaveAll, " GRIPPERTEXT NIL", "" ), " GRIPPERTEXT " + V1)
   ELSE

      v1     := AllTrim( xEvent[ 3 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON INIT NIL", "" ), " ON INIT " + V1)

      v1     := AllTrim( xEvent[ 13 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON RELEASE NIL", "" ), " ON RELEASE " + V1 )

      v1     := AllTrim( xEvent[  4 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON INTERACTIVECLOSE NIL", "" ), " ON INTERACTIVECLOSE " + V1 )

      v1     := AllTrim( xEvent[  8 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON MOUSECLICK NIL", "" ), " ON MOUSECLICK " + V1)

      v1     := AllTrim( xEvent[  9 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON MOUSEDRAG NIL", "" ), " ON MOUSEDRAG " + V1)

      v1     := AllTrim( xEvent[ 10 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON MOUSEMOVE NIL", "" ), " ON MOUSEMOVE " + V1)

      v1     := AllTrim( xEvent[ 21 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON MOVE NIL", "" ), " ON MOVE " + V1 )

      v1     := AllTrim( xEvent[ 22 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON DROPFILES NIL", "" ), " ON DROPFILES " + V1 )

      v1 := AllTrim( xEvent[ 18 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON SIZE NIL", "" ), " ON SIZE " + V1 )

      IF AllTrim( xProp[ 28 ] ) # "MODAL"
         v1 := AllTrim( xEvent[ 6 ] )
         Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON MAXIMIZE NIL", "" ), " ON MAXIMIZE " + V1 )

         v1 := AllTrim( xEvent[ 7 ] )
         Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON MINIMIZE NIL", "" ), " ON MINIMIZE " + V1 )

         v1 := AllTrim( xEvent[ 20 ] )
         IF Upper( v1 ) # "NIL"
             Output += " ON RESTORE " + V1
         ENDIF       
         
      ENDIF

      v1     := AllTrim( xEvent[ 12 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON PAINT NIL", "" ), " ON PAINT " + V1 )

      v1     :=  AllTrim( xProp[ 2 ] )
      Output += iif( Upper(V1) = "NIL", iif( lSaveAll," BACKCOLOR NIL", "" ), " BACKCOLOR " + V1 )

      IF AllTrim( xProp[ 28 ] ) = "MAIN" .OR. AllTrim( xProp[28] ) = "STANDARD" .OR. AllTrim(xProp[28] ) = "MDI" .OR. AllTrim(xProp[28] ) = "CHILD"
         v1     := AllTrim( xProp[ 17 ] )
         Output += iif(V1= '""'.OR.Empty(V1), iif( lSaveAll, " NOTIFYICON NIL", "" ), " NOTIFYICON " + V1 )

         v1     := AllTrim( xProp[ 18 ] )
         Output += iif(V1= '""'.OR.Empty(V1), iif( lSaveAll, " NOTIFYTOOLTIP NIL", "" ), " NOTIFYTOOLTIP " + V1 )

         v1     := AllTrim( xEvent[ 11 ] )
         Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON NOTIFYCLICK NIL", "" ), " ON NOTIFYCLICK " + V1 )
         
         v1     := AllTrim( xEvent[ 23 ] )
         Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON NOTIFYBALLOONCLICK NIL", "" ), " ON NOTIFYBALLOONCLICK " + V1 )
      ENDIF

   ENDIF

   v1     := AllTrim( xEvent[ 1 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON GOTFOCUS NIL", "" ), " ON GOTFOCUS " + V1 )

   v1     := AllTrim( xEvent[ 5 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON LOSTFOCUS NIL", "" ), " ON LOSTFOCUS " + V1 )

   v1     := AllTrim( xEvent[ 17 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON SCROLLUP NIL", "" ), " ON SCROLLUP " + V1 )

   v1     := AllTrim( xEvent[ 14 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON SCROLLDOWN NIL", "" ), " ON SCROLLDOWN " + V1 )

   v1     := AllTrim( xEvent[ 15 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON SCROLLLEFT NIL", "" ), " ON SCROLLLEFT " + V1 )

   v1     := AllTrim( xEvent[ 16 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON SCROLLRIGHT NIL", "")," ON SCROLLRIGHT " + V1 )

   v1     := AllTrim( xEvent[ 2 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON HSCROLLBOX NIL", "" ), " ON HSCROLLBOX " + V1 )

   v1     := AllTrim( xEvent[ 19 ] )
   Output += iif( Upper(V1) = "NIL", iif( lSaveAll, " ON VSCROLLBOX NIL", "" ), " ON VSCROLLBOX " + V1 )

   v1     := AllTrim( xProp[ 9 ] )

   IF V1  = ".T."
      Output += " HELPBUTTON"
   ENDIF

   Output += CRLF
   Output += CRLF

   **************************************************************FIM DO DEFINE WINDOW

   ToolbarInit( ".F." )

   ToolbarOk( ".F." )

   StatusFmgToMem()

   IF Len(ArrayStatus) > 1 // 0
      StatusSaveAll()
   ENDIF

   LoadavlDropDown()

   BeautDrop()
   BeautContext()
   BeautNotify()

   //?
   ************************THIS IS PROVISORY
   IF Len( Eval( blOut, aMenu     ) ) > 0
      output += CRLF
   ENDIF

   IF Len( Eval( blOut, aToolbar  ) ) > 0
      output += CRLF
   ENDIF

   IF Len( Eval( blOut, aContext  ) ) > 0
      output += CRLF
   ENDIF

   IF Len( Eval( blOut, aStatus   ) ) > 0
      output += CRLF
   ENDIF

   IF Len( Eval( blOut, aNotify   ) ) > 0
      output += CRLF
   ENDIF

   IF Len( Eval( blOut, aDropDown ) ) > 0
      output += CRLF
   ENDIF

   ***************************************************************   // Renaldo
   FOR i := 1 TO l
       IF _HMG_aControlParentHandles[ i ] ==  h .AND. _HMG_aControlType[ i ] == "TAB"
          FOR j := 1 TO Len( _HMG_aControlPageMap [i] )
              FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )
                  IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"
                     cValue := _HMG_aControlPageMap[ i, j, k ]
                     p      := aScan( _HMG_aControlHandles, cValue )
                  ELSE
                     cValue := _HMG_aControlPageMap[ i, j, k, 1 ]  // RADIOGROUP
                     p      :=  FindRadioName( cValue )
                  ENDIF

                  IF p > 0
                     Name := _HMG_aControlNames[ p ]
                     // MsgBox("adding to arraytemp " + name)
                     aAdd( ArrayTemp, Name )
                  ENDIF
              NEXT k
          NEXT j
       ENDIF
   NEXT i

   ****************************************************************  // Renaldo
   *     aIds := {}
   *     for ncontrol = 1 to Len( xArray)
   *     xnome1 := xArray[ncontrol,3 ]
   *     i0 := aScan(_HMG_aControlNames)
   *     if i0 > 0
   *     aAdd(aIds,i0)
   *     ENDIF
   *     next ncontrol

   FOR y := 1 TO Len( xArray )

      IF Empty( xArray[ y, 3 ] )
         y := Len( xArray )
      ELSE

         //      MsgBox("y = "+str(y)+"controle= "+xArray[y,3 ] )
         i := aScan2( _hmg_aControlNames, xArray[ y, 3 ] )
              //IF Y > 178
              // MsgBox("i= "+str(i) +" "+ xArray[y,3 ]+ " = "+_hmg_acontrolnames[i] )
              // MsgBox("SAVING CONTROL= "+ xArray[y,3 ]+ " NR = "+STR(Y)+ " LEN= "+STR(Len( xArray)) )
              //ENDIF
         DO WHILE .T.
            // MsgBox("n1= " +_hmg_acontrolnames[i]+" n2= "+xArray[y,3 ] )
            IF i > 0
               IF _HMG_aControlParentHandles[ i ] # h .OR. Len( _HMG_aControlNames[ i ] ) # Len( xArray[y,3 ] )
                  i := aScan2( _HMG_aControlNames, xArray[ y, 3 ], i+1 )
                        // MsgBox("i2= "+str(i) )
                  LOOP
               ENDIF
            ENDIF
            // MsgBox("exiting i2= "+ str(i)+" "+ xArray[y,3 ]+ " = "+_hmg_acontrolnames[i] )
            EXIT
         ENDDO

         IF i > 0

            // MsgBox("i = "+str(i)+" max= "+str(Len(_HMG_aControlHandles)) )
            IF _HMG_aControlParentHandles[ i ] == h .AND. _HMG_aControlType[ i ] == "TAB"
               il ++
               Name        := _HMG_aControlNames[ i ]

               Row         := GetWindowRow( _HMG_aControlhandles[ i ] ) - BaseRow - TitleHeight - BorderHeight + DifRow()

               IF Len( aMenu )> 0  // (-19 if have menu in form)
                  Row := Row - MenuBarHeight
               ENDIF

               Col         := GetWindowCol( _HMG_aControlhandles[ i ] ) - BaseCol - BorderWidth + DifCol()
               Width       := GetWindowWidth( _HMG_aControlhandles[ i ] )
               Height      := GetWindowHeight( _HMG_aControlhandles[ i ] )
               nItem       := xControle( Name )

               Output += Space(il) + "DEFINE TAB " + Name + " AT " + AllTrim(Str(Row)) + ","+ AllTrim(Str(Col)) + " WIDTH "+ AllTrim(Str(Width))+" HEIGHT "+ AllTrim(Str(Height))
               Output += " VALUE " + xArray[ nItem, 13 ] + " FONT " + "" + xArray[ nItem,  15 ]
               Output += " SIZE "  + xArray[ nItem, 17 ]

               IF xArray[ nItem, 19 ] # ".F."
                  Output += " BOLD "
               ENDIF

               IF xArray[ nItem, 21 ] # ".F."
                  Output += " ITALIC "
               ENDIF

               IF xArray[ nItem, 23 ] # ".F."
                  Output += " UNDERLINE "
               ENDIF

               IF xArray[ nItem, 25 ] # ".F."
                  Output += " STRIKEOUT "
               ENDIF

               Output += " TOOLTIP " + "" + xArray[ nItem, 27 ]

               IF xArray[ nItem, 29 ] # ".F."
                  Output += " BUTTONS "
               ENDIF

               IF xArray[ nItem, 31 ] # ".F."
                  Output += " FLAT "
               ENDIF

               IF xArray[ nItem, 33 ] # ".F."
                  Output += " HOTTRACK "
               ENDIF

               IF xArray[ nItem, 35 ] # ".F."
                  Output += " VERTICAL "
               ENDIF

               Output += " ON CHANGE " + xArray[ nItem, 37 ]

               IF xArray[ nItem, 39 ] # ".F."
                  Output += " BOTTOM"
               ENDIF

               IF xArray[ nItem, 41 ] # ".F."
                  Output += " NOTABSTOP"
               ENDIF

               IF xArray[ nItem, 43 ] # ".F."
                  Output += " MULTILINE"
               ENDIF

               IF xArray[ nItem, 45 ] # "NIL"
                  Output += " BACKCOLOR " + xArray[ nItem, 45 ]
               ENDIF

               Output += CRLF + CRLF

               aImage   := &(NOQUOTA( xArray[ nItem, 49 ] ) )
               aCaption := &(NOQUOTA( xArray[ nItem, 51 ] ) )
               aToolTip := &(NOQUOTA( xArray[ nItem, 53 ] ) )

               FOR j := 1 TO Len( _HMG_aControlPageMap [i] )
                  Output += Space( il + 2 ) + "PAGE '" + aCaption[ j ] + "'"
                  IF ! Empty( aImage[ j ] )
                     Output += " IMAGE '" + aImage[ j ] + "'"
                  ENDIF

                  IF ! Empty( aToolTip[ j ] )
                     Output += " TOOLTIP '" + aToolTip[ j ] + "'"
                  ENDIF

                  Output += CRLF + CRLF

                  FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )
                     cValue := _HMG_aControlPageMap[ i, j, k ]
                     // VERIFY IF ValType(cValue) IS ARRAY, IF YES CVALUE := _HMG_aControlPageMap[ i, j, k, 1 ]
                     IF ValType( cValue ) = "A"
                        nHandle := _HMG_aControlPageMap[ i, j, k, 1 ]
                        p       := FindRadioName( nHandle )
                     ELSE
                        IF cValue # 0
                           p := aScan( _HMG_aControlhandles, cValue ) // SCAN IN _HMG_aControlhandles[I][1 ] OF RADIOGROUP
                        ELSE
                           p := -1
                        ENDIF
                     ENDIF

                     IF p > 0

                        Name  := _HMG_aControlNames [p]
                        Row   := GetWindowRow( _HMG_aControlhandles[p] ) - BaseRow - TitleHeight - BorderHeight + DifRow()

                        IF Len( aMenu ) > 0
                           Row := Row - MenuBarHeight
                        ENDIF

                        Col    := GetWindowCol ( _HMG_aControlhandles[p] ) - BaseCol - BorderWidth + DifCol()
                        Width  := GetWindowWidth ( _HMG_aControlhandles[p] )
                        Height := GetWindowHeight ( _HMG_aControlhandles[p] )
                        nItem  := xcontrole(name)
                        Row    := Row - _HMG_aControlContainerRow [p]
                        Col    := Col - _HMG_aControlContainerCol [p]

                        Output := SaveFormControls( output, row, col, width, height, nItem, il+1, lSaveAll )
                        // MsgBox("including control ->"+ _HMG_aControlNames [p] )
                     ENDIF

                  NEXT k

                  Output += Space( il+2 ) + "END PAGE " + CRLF + CRLF

               NEXT j

               Output += Space( il ) + "END TAB " + CRLF + CRLF
               il --
            ENDIF

            IF _HMG_aControlParentHandles[ i ] == h                .AND. ;
               _HMG_aControlType[ i ]          != "MESSAGEBAR"     .AND. ;
               _HMG_aControlType[ i ]          != "ITEMMESSAGE"    .AND. ;
               _HMG_aControlType[ i ]          != "MENU"           .AND. ;
               _HMG_aControlNames[ i ]         != "DummyMenuName"  .AND. ;
               Len( AllTrim( _HMG_aControlNames[ i ] ) ) > 0       .AND. ;
               _HMG_aControlContainerRow[ i ]  = -1

               Name  := _HMG_aControlNames [i]
                // MsgBox(name+" "+ValType( _HMG_aControlContainerHandle [i] ) )
               z     := aScan2( ArrayTemp, _HMG_aControlNames[ i ] )

               IF z > 0
                   // MsgBox("z= "+ str(z) +" "+ _HMG_aControlNames [i]+ " = "+arraytemp[z] )
                   IF _HMG_aControlNames[ i ] # arraytemp[ z ]
                      z:= aScan2( ArrayTemp, _HMG_aControlNames[ i ], z+1 )
                   ENDIF
               ENDIF

               IF z = 0 .AND. ! _HMG_aControlDeleted[ i ]
                   // MsgBox("difrow = "+str(difrow()) )
                  Row         := GetWindowRow ( _HMG_aControlhandles[ i ] ) - BaseRow - TitleHeight - BorderHeight +DifRow()

                  IF Len( aMenu ) > 0  // (-20 if have menu in form )
                     Row := Row - MenuBarHeight
                  ENDIF
                  // MsgBox("wrow= "+str(GetWindowRow ( _HMG_aControlhandles[i] ))+" brow= " +str(baserow)+ " title = "+str(titleheight) +" border= " +str(borderheight) )
                  // MsgBox("difcol = "+str(difcol()) )
                  Col    := GetWindowCol( _HMG_aControlhandles[ i ] ) - BaseCol - BorderWidth + DifCol()
                  Width  := GetWindowWidth( _HMG_aControlhandles[ i ] )
                  Height := GetWindowHeight( _HMG_aControlhandles[ i ] )
                  nItem  := xcontrole( name )

                  output := SaveFormControls( output, row, col, width, height, nItem,, lSaveAll )
               ENDIF

            ENDIF

         ENDIF

      ENDIF

   next y

   ObjectInspector.xGrid_1.EnableUpdate
   ObjectInspector.xGrid_2.EnableUpdate

   Output += "END WINDOW" + CRLF
   Output += CRLF

   _HMG_aControlNames := aClone( aTempNames )

   IF xParam # NIL
      X4 := xParam + ".FMG"
   ELSE
      IF aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] == "<ProjectFolder>\" .OR. Empty(aFmgNames[ProjectBrowser.xlist_2.Value, 2 ] )
         X4 := ProjectFolder+"\"+CurrentForm
         // MsgBox("x4= "+x4)
      ELSE
         // MsgBox("value = " +aFmgNames[ProjectBrowser.xlist_2.Value,2] )
         X4 := aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] + CurrentForm
      ENDIF
   ENDIF

   lChanges := .F.
   MemoWrit( X4, Output )
   aFormDir := Directory( x4 )

RETURN


*-----------------------------------------------------------------------------*
FUNCTION SaveFormControls( Output   AS STRING,  ; //
                           Row      AS NUMERIC, ; //
                           Col      AS NUMERIC, ; //
                           Width    AS NUMERIC, ; //
                           Height   AS NUMERIC, ; //
                           nItem    AS NUMERIC, ; //
                           Indent   AS NUMERIC, ; //
                           lSaveAll AS LOGICAL  ; //
                         ) //OPT (DO CASE)
*-----------------------------------------------------------------------------*
   LOCAL x         AS NUMERIC
   LOCAL nPos      AS NUMERIC
   LOCAL nValue    AS NUMERIC
   LOCAL aComma    AS ARRAY
   LOCAL cWorkArea AS STRING
   LOCAL cCtrlName AS STRING

   DEFAULT Indent TO 0

  // MsgBox("nItem= " + str(nItem) + " value = " + xArray[ nItem, 1 ] + " "+ xArray[ nItem, 3 ] ) 
   cCtrlName := xArray[ nItem, 1 ]
  //msgbox('controlname= ' + cCtrlName )
   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   DO CASE

      CASE cCtrlName == "BUTTON"     // 1

           Output += Space( Indent ) + "     DEFINE BUTTON "    + AllTrim( xArray[ nItem, 3 ] )              + CRLF
           Output += Space( Indent ) + "            ROW    "    + AllTrim( Str( Row ) )                      + CRLF
           Output += Space( Indent ) + "            COL    "    + AllTrim( Str( Col ) )                      + CRLF
           Output += Space( Indent ) + "            WIDTH  "    + AllTrim( Str( Width ) )                    + CRLF
           Output += Space( Indent ) + "            HEIGHT "    + AllTrim( Str( Height ) )                   + CRLF
           Output += iif( Upper( xArray[ nItem, 15 ] )          = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ACTION "       + xArray[ nItem, 15 ]            + CRLF, "" ), Space( Indent ) + "            ACTION "        + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( Len( AllTrim( xArray[ nItem, 13 ] ) ) = 0         , iif( lSaveAll, Space( Indent ) + "            CAPTION "      + AllTrim( xArray[ nItem, 13 ] ) + CRLF, "" ), Space( Indent ) + "            CAPTION "       + AllTrim( xArray[ nItem, 13 ] ) + CRLF )
           Output += iif( xArray[ nItem, 17 ]                   = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME  "    + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]                   = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "     + xArray[ nItem, 19 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]                   = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP  "     + AllTrim( xArray[ nItem,21 ] )  + CRLF, "" ), Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( xArray[ nItem, 23 ]                   = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "     + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]                   = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "   + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]                   = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE "+ xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]                   = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT "+ xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 31 ] )          = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "   + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 33 ] )          = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "  + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] )          = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "       + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "        + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]                   = ".F."     , iif( lSaveAll, Space( Indent ) + "            FLAT "         + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            FLAT "          + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]                   = ".T."     , iif( lSaveAll, Space( Indent ) + "            TABSTOP "      + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            TABSTOP "       + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]                   = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "      + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( xArray[ nItem, 43 ]                   = ".F."     , iif( lSaveAll, Space( Indent ) + "            TRANSPARENT "  + xArray[ nItem, 43 ]            + CRLF, "" ), Space( Indent ) + "            TRANSPARENT "   + xArray[ nItem, 43 ]            + CRLF )

           IF Upper( xArray[ nItem, 45 ] ) # "NIL" .AND. Upper( xArray[ nItem, 49 ] ) = "NIL"
              Output += Space( Indent ) + "           PICTURE " + AllTrim( xArray[ nItem, 45 ] ) + CRLF
           ENDIF

           IF xArray[ nItem, 47 ] = ".T."
              Output += Space( Indent )+"           DEFAULT "   + xArray[ nItem, 47 ]            + CRLF
           ENDIF

           IF Upper( xArray[ nItem, 49 ] ) # "NIL"  .AND. Upper( xArray[ nItem, 45 ] ) = "NIL"
              Output += Space( Indent ) + "           ICON  "   + AllTrim( xArray[ nItem, 49 ] ) + CRLF
           ENDIF

           Output += iif( xArray[ nItem, 51 ] = ".F.", iif( lSaveAll, Space( Indent ) + "           MULTILINE " + xArray[ nItem, 51 ] + CRLF, "" ), Space( Indent ) + "           MULTILINE "  +xArray[ nItem, 51 ] + CRLF )
           Output += iif( xArray[ nItem, 53 ] = ".F.", iif( lSaveAll, Space( Indent ) + "           NOXPSTYLE " + xArray[ nItem, 53 ] + CRLF, "" ), Space( Indent ) + "           NOXPSTYLE "  +xArray[ nItem, 53 ] + CRLF )
          
           Output += Space( Indent ) + "     END BUTTON  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "CHECKBOX"   // 2

           Output += Space( Indent ) + "     DEFINE CHECKBOX "  + AllTrim( xArray[ nItem, 3 ] )       + CRLF
           Output += Space( Indent ) + "            ROW    "    + AllTrim( Str( Row ) )               + CRLF
           Output += Space( Indent ) + "            COL    "    + AllTrim( Str( Col ) )               + CRLF
           Output += Space( Indent ) + "            WIDTH  "    + AllTrim( Str( Width ) )             + CRLF
           Output += Space( Indent ) + "            HEIGHT "    + AllTrim( Str( Height ) )            + CRLF
           Output += Space( Indent ) + "            CAPTION "   + AllTrim( xArray[ nItem, 13 ] )      + CRLF

           Output += iif( xArray[ nItem, 15 ]           = ".F."      , iif( lSaveAll, Space( Indent ) + "            VALUE "         + xArray[ nItem, 15 ]            + CRLF, "" ), Space( Indent ) + "            VALUE "         + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( xArray[ nItem, 17 ]           = '"Arial"'  , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]           = "9"        , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 19 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]           = [""]       , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] )  = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "      + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            ONCHANGE "      + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] )  = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] )  = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 57 ] )  = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONENTER "       + xArray[ nItem, 57 ]            + CRLF, "" ), Space( Indent ) + "            ONENTER "       + xArray[ nItem, 57 ]            + CRLF )
         
           Output += iif( xArray[ nItem, 29 ]           = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]           = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]           = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]           = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 35 ]            + CRLF )

           IF xArray[ nItem, 37 ] # "NIL"  .AND.  Len( xArray[ nItem, 37 ] ) # 0
              Output += Space( Indent ) + "            FIELD "  + xArray[ nItem, 37 ] + CRLF
           ENDIF

           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 39 ]       + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "   + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 41 ]       + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "   + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 43 ]       + CRLF, "" ), Space( Indent ) + "            HELPID "      + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( xArray[ nItem, 45 ]          = ".T."      , iif( lSaveAll, Space( Indent ) + "            TABSTOP "       + xArray[ nItem, 45 ]       + CRLF, "" ), Space( Indent ) + "            TABSTOP "     + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 47 ]          = ".T."      , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 47 ]       + CRLF, "" ), Space( Indent ) + "            VISIBLE "     + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( xArray[ nItem, 49 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            TRANSPARENT "   + xArray[ nItem, 49 ]       + CRLF, "" ), Space( Indent ) + "            TRANSPARENT " + xArray[ nItem, 49 ]            + CRLF )

           IF xArray[ nItem, 51 ] # ".F."
              Output += Space( Indent ) + "          LEFTJUSTIFY " + xArray[ nItem, 51 ] + CRLF
           ENDIF

           IF xArray[ nItem, 53 ] # ".F."
              Output += Space( Indent ) + "           THREESTATE " + xArray[ nItem, 53 ] + CRLF
           ENDIF
           Output += iif( Upper( xArray[ nItem, 55 ] ) = ".F."      , iif( lSaveAll, Space( Indent ) + "            AUTOSIZE "       + xArray[ nItem, 55 ]       + CRLF, "" ), Space( Indent ) + "            AUTOSIZE "   + xArray[ nItem, 55 ]            + CRLF )
        
           Output += Space( Indent ) + "     END CHECKBOX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "LISTBOX"  // 3

           Output += Space( Indent ) + "     DEFINE LISTBOX "  + AllTrim( xArray[ nItem, 3 ] )       + CRLF
           Output += Space( Indent ) + "            ROW    "   + AllTrim( Str( Row ) )               + CRLF
           Output += Space( Indent ) + "            COL    "   + AllTrim( Str( Col ) )               + CRLF
           Output += Space( Indent ) + "            WIDTH  "   + AllTrim( Str( Width ) )             + CRLF
           Output += Space( Indent ) + "            HEIGHT "   + AllTrim( Str( Height ) )            + CRLF
           Output += iif( xArray[ nItem, 13 ]          = "{''}"     , iif( lSaveAll, Space( Indent ) + "            ITEMS "         + xArray[ nItem, 13 ]            + CRLF, "" ), Space( indent ) + "            ITEMS "          + xArray[ nItem, 13 ]            + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = "0"        , iif( lSaveAll, Space( Indent ) + "            VALUE "         + xArray[ nItem, 15 ]            + CRLF, "" ), Space( indent ) + "            VALUE "          + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = '"Arial"'  , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = "9"        , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 19 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "       + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = [""]       , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "      + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "       + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "     + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS "    + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "       + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "     + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 33 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            BACKCOLOR "      + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            FONTCOLOR "      + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONDBLCLICK "    + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            ONDBLCLICK "     + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 43 ]            + CRLF, "" ), Space( indent ) + "            HELPID "         + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( xArray[ nItem, 45 ]          = ".T."      , iif( lSaveAll, Space( Indent ) + "            TABSTOP "       + xArray[ nItem, 45 ]            + CRLF, "" ), Space( indent ) + "            TABSTOP "        + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 47 ]          = ".T."      , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 47 ]            + CRLF, "" ), Space( indent ) + "            VISIBLE "        + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( xArray[ nItem, 49 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            SORT "          + xArray[ nItem, 49 ]            + CRLF, "" ), Space( indent ) + "            SORT "           + xArray[ nItem, 49 ]            + CRLF )
           Output += iif( xArray[ nItem, 51 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            MULTISELECT "   + xArray[ nItem, 51 ]            + CRLF, "" ), Space( indent ) + "            MULTISELECT "    + xArray[ nItem, 51 ]            + CRLF )
           
           Output += iif( xArray[ nItem, 55 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            MULTITAB"       + xArray[ nItem, 55 ]            + CRLF, "" ), Space( indent ) + "            MULTITAB "       + xArray[ nItem, 55 ]            + CRLF )
           Output += iif( xArray[ nItem, 57 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            MULTICOLUMN "   + xArray[ nItem, 57 ]            + CRLF, "" ), Space( indent ) + "            MULTICOLUMN "    + xArray[ nItem, 57 ]            + CRLF )
         
           Output += iif( xArray[ nItem, 53 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            DRAGITEMS "     + xArray[ nItem, 53 ]            + CRLF, "" ), Space( indent ) + "            DRAGITEMS "      + xArray[ nItem, 53 ]            + CRLF )
           Output += Space( Indent ) + "     END LISTBOX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "COMBOBOX"   // 4

           Output += Space( Indent ) + "     DEFINE COMBOBOX "      + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "        + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "        + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "        + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "        + xArray[ nItem, 11 ]            + CRLF
           Output += iif( xArray[ nItem, 13 ]          = "{''}"     , iif( lSaveAll, Space( indent ) + "            ITEMS "           + xArray[ nItem, 13 ]            + CRLF, "" ), Space( indent ) + "            ITEMS "             + xArray[ nItem, 13 ]            + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = "0"        , iif( lSaveAll, Space( indent ) + "            VALUE "           + xArray[ nItem, 15 ]            + CRLF, "" ), Space( indent ) + "            VALUE "             + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = '"Arial"'  , iif( lSaveAll, Space( indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "          + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = "9"        , iif( lSaveAll, Space( indent ) + "            FONTSIZE "        + xArray[ nItem, 19 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "          + xArray[ nItem, 19 ]            + CRLF )
            IF xArray[ nItem, 69 ] # ".F."
              Output += Space( Indent ) + "            UPPERCASE "   + xArray[ nItem, 69 ] + CRLF
           ENDIF

           IF xArray[ nItem, 71 ] # ".F."
              Output += Space( Indent ) + "            LOWERCASE "   + xArray[ nItem, 71 ] + CRLF
           ENDIF
           
           Output += iif( xArray[ nItem, 21 ]          = [""]       , iif( lSaveAll, Space( indent ) + "            TOOLTIP "         + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "           + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONCHANGE "        + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "          + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "        + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS "       + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTBOLD "        + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "          + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTITALIC "      + xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "        + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 33 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE "     + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT "     + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            HELPID "          + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            HELPID "            + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".T."      , iif( lSaveAll, Space( indent ) + "            TABSTOP "         + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            TABSTOP "           + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".T."      , iif( lSaveAll, Space( indent ) + "            VISIBLE "         + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            VISIBLE "           + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( xArray[ nItem, 43 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            SORT "            + xArray[ nItem, 43 ]            + CRLF, "" ), Space( indent ) + "            SORT "              + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 45 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONENTER "         + xArray[ nItem, 45 ]            + CRLF, "" ), Space( indent ) + "            ONENTER "           + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 47 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONDISPLAYCHANGE " + xArray[ nItem, 47 ]            + CRLF, "" ), Space( indent ) + "            ONDISPLAYCHANGE "   + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( xArray[ nItem, 49 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            DISPLAYEDIT "     + xArray[ nItem, 49 ]            + CRLF, "" ), Space( indent ) + "            DISPLAYEDIT "       + xArray[ nItem, 49 ]            + CRLF )

           IF xArray[ nItem, 51 ] # "NIL" .AND. Len( xArray[ nItem, 51 ] ) # 0
              Output += Space( indent ) + "            ITEMSOURCE "   + xArray[ nItem, 51 ] + CRLF
           ENDIF

           IF xArray[ nItem, 53 ] # "NIL" .AND. Len( xArray[ nItem, 53 ] )  # 0
              Output += Space( indent) + "            VALUESOURCE "   + xArray[ nItem, 53 ] + CRLF
           ENDIF

           IF xArray[ nItem, 55 ] # "NIL" .AND. Len( xArray[ nItem, 55 ] )  # 0
              Output += Space( indent) + "            LISTWIDTH "     + xArray[ nItem, 55 ] + CRLF
           ENDIF

           IF xArray[ nItem, 57 ] # "NIL"
              Output += Space( indent) + "            ONLISTDISPLAY " + xArray[ nItem, 57 ] + CRLF
           ENDIF

           IF xArray[ nItem, 59 ] # "NIL"
              Output += Space( indent) + "            ONLISTCLOSE "   + xArray[ nItem, 59 ] + CRLF
           ENDIF

           IF xArray[ nItem, 61 ] # "NIL"  .AND.  Len( xArray[ nItem, 61 ] )  # 0
              Output += Space( indent) + "            GRIPPERTEXT "   + xArray[ nItem, 61 ] + CRLF
           ENDIF

           IF xArray[ nItem, 63 ] # ".F."
              Output += Space( indent) + "            BREAK "         + xArray[ nItem, 63 ] + CRLF
           ENDIF

           IF xArray[ nItem, 65 ] # "NIL"
              Output += Space( indent)+"            BACKCOLOR "       + xArray[ nItem, 65 ] + CRLF
           ENDIF

           IF xArray[ nItem, 67 ] # "NIL"
              Output += Space( indent)+"            FONTCOLOR "       + xArray[ nItem, 67 ] + CRLF
           ENDIF

           Output += Space( indent ) + "     END COMBOBOX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "CHECKBUTTON"  // 5

           Output += Space( Indent ) + "     DEFINE CHECKBUTTON "   + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "        + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "        + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "        + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "        + AllTrim( Str( Height ) )       + CRLF
           Output += Space( Indent ) + "            CAPTION "       + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           Output += iif( xArray[ nItem, 15 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            VALUE "           + xArray[ nItem, 15 ]            + CRLF, "" ), Space( indent ) + "            VALUE "          + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = '"Arial"'  , iif( lSaveAll, Space( indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = "9"        , iif( lSaveAll, Space( indent ) + "            FONTSIZE "        + xArray[ nItem, 19 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "       + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = [""]       , iif( lSaveAll, Space( indent ) + "            TOOLTIP "         + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONCHANGE "        + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "       + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "     + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS "    + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTBOLD "        + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "       + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTITALIC "      + xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "     + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 33 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F."      , iif( lSaveAll, Space( indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            HELPID "          + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            HELPID "         + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".T."      , iif( lSaveAll, Space( indent ) + "            TABSTOP "         + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            TABSTOP "        + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".T."      , iif( lSaveAll, Space( indent ) + "            VISIBLE "         + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            VISIBLE "        + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"      , iif( lSaveAll, Space( indent ) + "            PICTURE NIL"                                       + CRLF, "" ), Space( indent ) + "            PICTURE "        + xArray[ nItem, 43 ]            + CRLF )
           Output += Space( indent ) + "     END CHECKBUTTON  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "GRID"     // 6

           Output += Space( Indent ) + "     DEFINE GRID "         + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + AllTrim( Str(Row))             + CRLF
           Output += Space( Indent ) + "            COL    "       + AllTrim( Str(Col))             + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + AllTrim( Str(Width))           + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + AllTrim( Str(Height))          + CRLF
           
           Output += Space( Indent ) + "            HEADERS "      + xArray[ nItem, 13 ]            + CRLF
           Output += Space( Indent ) + "            WIDTHS "       + xArray[ nItem, 15 ]            + CRLF
           Output += Space( Indent ) + "            ITEMS "        + xArray[ nItem, 17 ]            + CRLF
           
           Output += iif( xArray[ nItem, 15 ]          = "0"       , iif( lSaveAll, Space( Indent ) + "            VALUE "             + xArray[ nItem, 19 ]            + CRLF, "" ),          Space( Indent ) + "            VALUE "             + xArray[ nItem, 19 ]          + CRLF )
           
           Output += iif( xArray[ nItem, 21 ]          = '"Arial"' , iif( lSaveAll, Space( indent ) + "            FONTNAME "          + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "          + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( xArray[ nItem, 23 ]          = "9"       , iif( lSaveAll, Space( indent ) + "            FONTSIZE "          + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "          + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTBOLD "          + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "          + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTITALIC "        + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "        + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTUNDERLINE "     + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE "     + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTSTRIKEOUT "     + xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT "     + xArray[ nItem, 31 ]            + CRLF )
        
           Output += iif( xArray[ nItem, 33 ]          = [""]      , iif( lSaveAll, Space( indent ) + "            TOOLTIP "           + AllTrim( xArray[ nItem, 33 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "           + AllTrim( xArray[ nItem, 33 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            BACKCOLOR "         + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            BACKCOLOR "         + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            FONTCOLOR "         + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            FONTCOLOR "         + xArray[ nItem, 37 ]            + CRLF )

           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            DYNAMICBACKCOLOR "  + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            DYNAMICBACKCOLOR "  + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            DYNAMICFORECOLOR "  + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            DYNAMICFORECOLOR "  + xArray[ nItem, 41 ]            + CRLF )
           
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONGOTFOCUS "        + xArray[ nItem, 43 ]            + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "        + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 45 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONCHANGE "          + xArray[ nItem, 45 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "          + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 47 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONLOSTFOCUS "       + xArray[ nItem, 47 ]            + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS "       + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 49 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONDBLCLICK "        + xArray[ nItem, 49 ]            + CRLF, "" ), Space( indent ) + "            ONDBLCLICK "        + xArray[ nItem, 49 ]            + CRLF )
           
           Output += iif( xArray[ nItem, 51 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            ALLOWEDIT "         + xArray[ nItem, 51 ]            + CRLF, "" ), Space( indent ) + "            ALLOWEDIT "         + xArray[ nItem, 51 ]            + CRLF )
          
           Output += iif( Upper( xArray[ nItem, 53 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONHEADCLICK "       + xArray[ nItem, 53 ]            + CRLF, "" ), Space( indent ) + "            ONHEADCLICK "       + xArray[ nItem, 53 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 55 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONCHECKBOXCLICKED " + xArray[ nItem, 55 ]            + CRLF, "" ), Space( indent ) + "            ONCHECKBOXCLICKED " + xArray[ nItem, 55 ]            + CRLF )
         
           Output += iif( xArray[ nItem, 57 ]         = '""'       , iif( lSaveAll, Space( indent ) + "            INPLACEEDIT "    + AllTrim( xArray[ nItem, 57 ] )    + CRLF, "" ), Space( indent ) + "            INPLACEEDIT "       + AllTrim( xArray[ nItem, 57 ] ) + CRLF )
           Output += iif( xArray[ nItem, 59 ]         = ".F."      , iif( lSaveAll, Space( indent ) + "            CELLNAVIGATION " + AllTrim( xArray[ nItem, 59 ] )    + CRLF, "" ), Space( indent ) + "            CELLNAVIGATION "    + AllTrim( xArray[ nItem, 59 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 61 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            COLUMNCONTROLS "    + xArray[ nItem, 61 ]            + CRLF, "" ), Space( indent ) + "            COLUMNCONTROLS "    + xArray[ nItem, 61 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 63 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            COLUMNVALID "       + xArray[ nItem, 63 ]            + CRLF, "" ), Space( indent ) + "            COLUMNVALID "       + xArray[ nItem, 63 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 65 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            COLUMNWHEN "        + xArray[ nItem, 65 ]            + CRLF, "" ), Space( indent ) + "            COLUMNWHEN "        + xArray[ nItem, 65 ]            + CRLF )
          
           Output += iif( Upper( xArray[ nItem, 67 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            VALIDMESSAGES "     + xArray[ nItem, 67 ]            + CRLF, "" ), Space( indent ) + "            VALIDMESSAGES "     + xArray[ nItem, 67 ]            + CRLF )
           Output += iif( xArray[ nItem, 69 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            VIRTUAL "           + xArray[ nItem, 69 ]            + CRLF, "" ), Space( indent ) + "            VIRTUAL "           + xArray[ nItem, 69 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 71 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ITEMCOUNT "         + xArray[ nItem, 71 ]            + CRLF, "" ), Space( indent ) + "            ITEMCOUNT "         + xArray[ nItem, 71 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 73 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONQUERYDATA "       + xArray[ nItem, 73 ]            + CRLF, "" ), Space( indent ) + "            ONQUERYDATA "       + xArray[ nItem, 73 ]            + CRLF )
           Output += iif( xArray[ nItem, 75 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            MULTISELECT "       + xArray[ nItem, 75 ]            + CRLF, "" ), Space( indent ) + "            MULTISELECT "       + xArray[ nItem, 75 ]            + CRLF )
           Output += iif( xArray[ nItem, 77 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            NOLINES "           + xArray[ nItem, 77 ]            + CRLF, "" ), Space( indent ) + "            NOLINES "           + xArray[ nItem, 77 ]            + CRLF )
           Output += iif( xArray[ nItem, 79 ]          = ".T."     , iif( lSaveAll, Space( indent ) + "            SHOWHEADERS "       + xArray[ nItem, 79 ]            + CRLF, "" ), Space( indent ) + "            SHOWHEADERS "       + xArray[ nItem, 79 ]            + CRLF )
           Output += iif( xArray[ nItem, 81 ]          = ".T."     , iif( lSaveAll, Space( indent ) + "            NOSORTHEADERS "     + xArray[ nItem, 81 ]            + CRLF, "" ), Space( indent ) + "            NOSORTHEADERS "     + xArray[ nItem, 81 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 83 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            IMAGE "             + xArray[ nItem, 83 ]            + CRLF, "" ), Space( indent ) + "            IMAGE "             + xArray[ nItem, 83 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 85 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            JUSTIFY "           + xArray[ nItem, 85 ]            + CRLF, "" ), Space( indent ) + "            JUSTIFY "           + xArray[ nItem, 85 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 87 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            HELPID "            + xArray[ nItem, 87 ]            + CRLF, "" ), Space( indent ) + "            HELPID "            + xArray[ nItem, 87 ]            + CRLF )
           Output += iif( xArray[ nItem, 89 ]         = ".F."      , iif( lSaveAll, Space( indent ) + "            BREAK "             + xArray[ nItem, 89 ]            + CRLF, "" ), Space( indent ) + "            BREAK "             + xArray[ nItem, 89 ]            + CRLF )
         
           IF ! Empty( xArray[ nItem, 91 ] )
              Output += Space( Indent ) + "            HEADERIMAGE " + xArray[ nItem, 91 ] + CRLF
           ENDIF
           Output += iif( xArray[ nItem, 93 ]         = ".F."      , iif( lSaveAll, Space( indent ) + "            NOTABSTOP "         + xArray[ nItem, 93 ]            + CRLF, "" ), Space( indent ) + "            NOTABSTOP "         + xArray[ nItem, 93 ]            + CRLF )
           Output += iif( xArray[ nItem, 95 ]         = ".F."      , iif( lSaveAll, Space( indent ) + "            CHECKBOXES "        + AllTrim( xArray[ nItem, 95 ] ) + CRLF, "" ), Space( indent ) + "            CHECKBOXES "        + AllTrim( xArray[ nItem, 95 ] ) + CRLF )           
           Output += iif( Upper( xArray[ nItem, 97 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            LOCKCOLUMNS "       + xArray[ nItem, 97 ]            + CRLF, "" ), Space( indent ) + "            LOCKCOLUMNS "       + xArray[ nItem, 97 ]            + CRLF )         
           Output += iif( xArray[ nItem, 99 ]         = ".F."      , iif( lSaveAll, Space( indent ) + "            PAINTDOUBLEBUFFER " + xArray[ nItem, 99 ]            + CRLF, "" ), Space( indent ) + "            PAINTDOUBLEBUFFER " + xArray[ nItem, 99 ]            + CRLF )
          
           Output += Space( Indent ) + "     END GRID  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "IMAGE"    // 9

           Output += Space( indent ) + "     DEFINE IMAGE "        + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( indent ) + "            ROW    "       + AllTrim( Str( Row ) )          + CRLF
           Output += Space( indent ) + "            COL    "       + AllTrim( Str( Col ) )          + CRLF
           Output += Space( indent ) + "            WIDTH  "       + AllTrim( Str( Width ) )        + CRLF
           Output += Space( indent ) + "            HEIGHT "       + AllTrim( Str( Height ) )       + CRLF
           Output += Space( indent ) + "            PICTURE "      + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           Output += iif( Upper( xArray[ nItem, 15 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            HELPID "       + xArray[ nItem, 15 ] + CRLF, "" ), Space( indent ) + "            HELPID "       + xArray[ nItem, 15 ] + CRLF )
           Output += iif( xArray[ nItem, 17 ]        = ".T."       , iif( lSaveAll, Space( indent ) + "            VISIBLE "      + xArray[ nItem, 17 ] + CRLF, "" ), Space( indent ) + "            VISIBLE "      + xArray[ nItem, 17 ] + CRLF )
           Output += iif( xArray[ nItem, 19 ]        = ".F."       , iif( lSaveAll, Space( indent ) + "            STRETCH "      + xArray[ nItem, 19 ] + CRLF, "" ), Space( indent ) + "            STRETCH "      + xArray[ nItem, 19 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ACTION "       + xArray[ nItem, 21 ] + CRLF, "" ), Space( indent ) + "            ACTION "       + xArray[ nItem, 21 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONMOUSEHOVER " + xArray[ nItem, 22]  + CRLF, "" ), Space( indent ) + "            ONMOUSEHOVER " + xArray[ nItem, 25 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONMOUSELEAVE " + xArray[ nItem, 27 ] + CRLF, "" ), Space( indent ) + "            ONMOUSELEAVE " + xArray[ nItem, 27 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 29 ] ) = ".F."     , iif( lSaveAll, Space( indent ) + "            TRANSPARENT "  + xArray[ nItem, 29 ] + CRLF, "" ), Space( indent ) + "            TRANSPARENT "  + xArray[ nItem, 29 ] + CRLF )

           Output += iif( Upper( xArray[ nItem, 31 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            BACKGROUNDCOLOR " + xArray[ nItem, 31]  + CRLF, "" ), Space( indent ) + "            BACKGROUNDCOLOR " + xArray[ nItem, 31 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 33 ] ) = ".F."     , iif( lSaveAll, Space( indent ) + "            ADJUSTIMAGE "     + xArray[ nItem, 33 ] + CRLF, "" ), Space( indent ) + "            ADJUSTIMAGE "     + xArray[ nItem, 33 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] ) = '""'      , iif( lSaveAll, Space( indent ) + "            TOOLTIP "         + xArray[ nItem, 35 ] + CRLF, "" ), Space( indent ) + "            TOOLTIP "         + xArray[ nItem, 35 ] + CRLF )

           IF xArray[ nItem, 23 ] = ".T."
              Output += Space( Indent ) + "            WHITEBACKGROUND " + xArray[ nItem, 23 ] + CRLF
           ENDIF
           Output += Space( Indent ) + "     END IMAGE  " + CRLF
           Output += CRLF
           
       CASE cCtrlName == "CHECKLISTBOX"  // 33

           Output += Space( Indent ) + "     DEFINE CHECKLISTBOX "  + AllTrim( xArray[ nItem, 3 ] )       + CRLF
           Output += Space( Indent ) + "            ROW    "   + AllTrim( Str( Row ) )               + CRLF
           Output += Space( Indent ) + "            COL    "   + AllTrim( Str( Col ) )               + CRLF
           Output += Space( Indent ) + "            WIDTH  "   + AllTrim( Str( Width ) )             + CRLF
           Output += Space( Indent ) + "            HEIGHT "   + AllTrim( Str( Height ) )            + CRLF
           Output += iif( xArray[ nItem, 13 ]          = "{''}"     , iif( lSaveAll, Space( Indent ) + "            ITEMS "         + xArray[ nItem, 13 ]            + CRLF, "" ), Space( indent ) + "            ITEMS "          + xArray[ nItem, 13 ]            + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = "0"        , iif( lSaveAll, Space( Indent ) + "            VALUE "         + xArray[ nItem, 15 ]            + CRLF, "" ), Space( indent ) + "            VALUE "          + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = '"Arial"'  , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = "9"        , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 19 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "       + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = [""]       , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "      + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "       + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "     + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS "    + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "       + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "     + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 33 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            BACKCOLOR "      + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            FONTCOLOR "      + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            ONDBLCLICK "    + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            ONDBLCLICK "     + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 43 ]            + CRLF, "" ), Space( indent ) + "            HELPID "         + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( xArray[ nItem, 45 ]          = ".T."      , iif( lSaveAll, Space( Indent ) + "            TABSTOP "       + xArray[ nItem, 45 ]            + CRLF, "" ), Space( indent ) + "            TABSTOP "        + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 47 ]          = ".T."      , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 47 ]            + CRLF, "" ), Space( indent ) + "            VISIBLE "        + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( xArray[ nItem, 49 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            SORT "          + xArray[ nItem, 49 ]            + CRLF, "" ), Space( indent ) + "            SORT "           + xArray[ nItem, 49 ]            + CRLF )
           Output += iif( xArray[ nItem, 51 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            MULTISELECT "   + xArray[ nItem, 51 ]            + CRLF, "" ), Space( indent ) + "            MULTISELECT "    + xArray[ nItem, 51 ]            + CRLF )
           
           Output += iif( xArray[ nItem, 53 ]          = '""'       , iif( lSaveAll, Space( Indent ) + "            CHECKBOXITEM"   + xArray[ nItem, 53 ]            + CRLF, "" ), Space( indent ) + "            CHECKBOXITEM "   + xArray[ nItem, 53 ]            + CRLF )
           Output += iif( xArray[ nItem, 55 ]          = "0"        , iif( lSaveAll, Space( Indent ) + "            ITEMHEIGHT "    + xArray[ nItem, 55 ]            + CRLF, "" ), Space( indent ) + "            ITEMHEIGHT "     + xArray[ nItem, 55 ]            + CRLF )
         
           
           Output += Space( Indent ) + "     END CHECKLISTBOX  " + CRLF
           Output += CRLF       

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "TREE"   // 34
           Output += Space( indent ) + "     DEFINE TREE "        + AllTrim( xArray[ nItem, 3 ] )
           Output += Space( indent ) + " AT "                     + AllTrim( Str( Row )         )
           Output += Space( indent ) + " , "                      + AllTrim( Str( Col )         )
           Output += Space( indent ) + " WIDTH "                  + AllTrim( Str( Width )       )
           Output += Space( indent ) + " HEIGHT "                 + AllTrim( Str( Height )      )
           Output += iif( xArray[ nItem, 13 ]        = "0"        , iif( lSaveAll, Space( indent ) + " VALUE "        + xArray[ nItem, 13 ]           , "" ), Space( indent ) + " VALUE  "       + xArray[ nItem, 13 ]            )
           Output += iif( xArray[ nItem, 15 ]        = '"Arial"'  , iif( lSaveAll, Space( indent ) + " FONT "         + AllTrim( xArray[ nItem, 15 ] ), "" ), Space( indent ) + " FONT "         + AllTrim( xArray[ nItem, 15 ] ) )
           Output += iif( xArray[ nItem, 17 ]        = "9"        , iif( lSaveAll, Space( indent ) + " SIZE "         + xArray[ nItem, 17 ]           , "" ), Space( indent ) + " SIZE "         + xArray[ nItem, 17 ]            )
           Output += iif( xArray[ nItem, 19 ]        = [""]       , iif( lSaveAll, Space( indent ) + " TOOLTIP "      + AllTrim( xArray[ nItem, 19 ] ), "" ), Space( indent ) + " TOOLTIP "      + AllTrim( xArray[ nItem, 19 ] ) )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"    , iif( lSaveAll, Space( indent ) + " ON GOTFOCUS "  + xArray[ nItem, 21 ]           , "" ), Space( indent ) + " ON GOTFOCUS "  + xArray[ nItem, 21 ]            )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"    , iif( lSaveAll, Space( indent ) + " ON CHANGE "    + xArray[ nItem, 23 ]           , "" ), Space( indent ) + " ON CHANGE "    + xArray[ nItem, 23 ]            )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"    , iif( lSaveAll, Space( indent ) + " ON LOSTFOCUS " + xArray[ nItem, 25 ]           , "" ), Space( indent ) + " ON LOSTFOCUS " + xArray[ nItem, 25 ]            )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"    , iif( lSaveAll, Space( indent ) + " ON DBLCLICK "  + xArray[ nItem, 27 ]           , "" ), Space( indent ) + " ON DBLCLICK "  + xArray[ nItem, 27 ]            )
           Output += iif( Upper( xArray[ nItem, 29 ] ) = "NIL"    , iif( lSaveAll, Space( indent ) + " NODEIMAGES "   + xArray[ nItem, 29 ]           , "" ), Space( indent ) + " NODEIMAGES "   + xArray[ nItem, 29 ]            )
           Output += iif( Upper( xArray[ nItem, 31 ] ) = "NIL"    , iif( lSaveAll, Space( indent ) + " ITEMIMAGES "   + xArray[ nItem, 31 ]           , "" ), Space( indent ) + " ITEMIMAGES "   + xArray[ nItem, 31 ]            )

           IF xArray[ nItem, 33 ] = ".T."
              Output += Space( Indent ) + " NOROOTBUTTON "  // +xArray[ nItem, 33 ]
           ENDIF

           Output += iif( Upper( xArray[ nItem, 35 ] )= "NIL", iif( lSaveAll, Space( indent ) + " HELPID " + xArray[ nItem, 35 ],"" ), Space( indent ) + " HELPID " + xArray[ nItem, 35 ] )

           IF xArray[ nItem, 37 ] # "NIL"
              Output += Space( Indent ) + " BACKCOLOR " + xArray[ nItem, 37 ]
           ENDIF

           IF xArray[ nItem, 39 ] # "NIL"
              Output += Space( Indent ) + " FONTCOLOR " + xArray[ nItem, 39 ]
           ENDIF

           IF xArray[ nItem, 41 ] # "NIL"
              Output += Space( Indent ) + " LINECOLOR " + xArray[ nItem, 41 ]
           ENDIF

           IF xArray[ nItem, 43 ] # "17"
              Output += Space( Indent ) + " INDENT " + xArray[ nItem, 43 ]
           ENDIF

           IF xArray[ nItem, 45 ] # "18"
              Output += Space( Indent ) + " ITEMHEIGHT " + xArray[ nItem, 45 ]
           ENDIF

           IF xArray[ nItem, 47 ] # ".F."
              Output += Space( Indent ) + " BOLD " //  + xArray[ nItem, 47 ]
           ENDIF

           IF xArray[ nItem, 49 ] # ".F."
              Output += Space( Indent ) + " ITALIC " // + xArray[ nItem, 49 ]
           ENDIF

           IF xArray[ nItem, 51 ] # ".F."
              Output += Space( Indent ) + " UNDERLINE " // + xArray[ nItem, 51 ]
           ENDIF

           IF xArray[ nItem, 53 ] # ".F."
              Output += Space( Indent ) + " STRIKEOUT "  // + xArray[ nItem, 53 ]
           ENDIF

           IF xArray[ nItem, 55 ] # ".F."
              Output += Space( Indent ) + " BREAK " // + xArray[ nItem, 55 ]
           ENDIF

           IF xArray[ nItem, 57 ] # ".F."
              Output += Space( Indent ) + " ITEMIDS " // + xArray[ nItem, 57 ]
           ENDIF

           Output += CRLF
           Output += Space( Indent ) + "     END TREE  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "ANIMATEBOX"   // 17

           Output += Space( Indent ) + "     DEFINE ANIMATEBOX "    + AllTrim( xArray[ nItem, 3 ]   ) + CRLF
           Output += Space( Indent ) + "            ROW    "         + AllTrim(Str(Row)             ) + CRLF
           Output += Space( Indent ) + "            COL    "         + AllTrim(Str(Col)             ) + CRLF
           Output += Space( Indent ) + "            WIDTH  "         + AllTrim(Str(Width)           ) + CRLF
           Output += Space( Indent ) + "            HEIGHT "         + AllTrim(Str(Height)          ) + CRLF
           Output += iif( xArray[ nItem, 13 ]          = '""'        , iif( lSaveAll, Space( indent ) + "            FILE "        + AllTrim( xArray[ nItem, 13 ] ) + CRLF, "" ), Space( indent ) + "            FILE "         + AllTrim( xArray[ nItem, 13 ] )+ CRLF )
           Output += iif( Upper( xArray[ nItem, 15 ] ) = "NIL"       , iif( lSaveAll, Space( indent ) + "            HELPID "      + xArray[ nItem, 15 ]            + CRLF, "" ), Space( indent ) + "            HELPID "       + xArray[ nItem, 15 ]           + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            TRANSPARENT " + xArray[ nItem, 17 ]            + CRLF, "" ), Space( indent ) + "            TRANSPARENT "  + xArray[ nItem, 17 ]           + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            AUTOPLAY "    + xArray[ nItem, 19 ]            + CRLF, "" ), Space( indent ) + "            AUTOPLAY "     + xArray[ nItem, 19 ]           + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            CENTER "      + xArray[ nItem, 21 ]            + CRLF, "" ), Space( indent ) + "            CENTER "       + xArray[ nItem, 21 ]           + CRLF )
           Output += iif( xArray[ nItem, 23 ]          = ".T."       , iif( lSaveAll, Space( indent ) + "            BORDER "      + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            BORDER "       + xArray[ nItem, 23 ]           + CRLF )
           Output += Space( indent ) + "      END ANIMATEBOX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "DATEPICKER"   // 10

           Output += Space( Indent ) + "     DEFINE DATEPICKER "     + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "         + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "         + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "         + xArray[ nItem,  9 ]            + CRLF
           Output += Space( Indent ) + "            HEIGHT "         + xArray[ nItem, 11 ]            + CRLF
           Output += iif( xArray[ nItem, 13 ]          = "cTod('')"  , iif( lSaveAll, Space( indent ) + "            VALUE "        + xArray[ nItem, 13 ]            + CRLF, "" ), Space( indent ) + "            VALUE "         + xArray[ nItem, 13 ]            + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = '"Arial"'   , iif( lSaveAll, Space( indent ) + "            FONTNAME "     + AllTrim( xArray[ nItem, 15 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 15 ] ) + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = "9"         , iif( lSaveAll, Space( indent ) + "            FONTSIZE "     + xArray[ nItem, 17 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "      + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = [""]        , iif( lSaveAll, Space( indent ) + "            TOOLTIP "      + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"       , iif( lSaveAll, Space( indent ) + "            ONCHANGE "     + xArray[ nItem, 21 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "      + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"       , iif( lSaveAll, Space( indent ) + "            ONGOTFOCUS "   + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"       , iif( lSaveAll, Space( indent ) + "            ONLOSTFOCUS "  + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTBOLD "     + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "      + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTITALIC "   + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "    + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTUNDERLINE "+ xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE " + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTSTRIKEOUT "+ xArray[ nItem, 33 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] ) = "NIL"       , iif( lSaveAll, Space( indent ) + "            ONENTER "      + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            ONENTER "       + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"       , iif( lSaveAll, Space( indent ) + "            HELPID "       + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            HELPID "        + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".T."       , iif( lSaveAll, Space( indent ) + "            TABSTOP "      + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            TABSTOP "       + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".T."       , iif( lSaveAll, Space( indent ) + "            VISIBLE "      + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            VISIBLE "       + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( xArray[ nItem, 43 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            SHOWNONE "     + xArray[ nItem, 43 ]            + CRLF, "" ), Space( indent ) + "            SHOWNONE "      + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( xArray[ nItem, 45 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            UPDOWN "       + xArray[ nItem, 45 ]            + CRLF, "" ), Space( indent ) + "            UPDOWN "        + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 47 ]          = ".F."       , iif( lSaveAll, Space( indent ) + "            RIGHTALIGN "   + xArray[ nItem, 47 ]            + CRLF, "" ), Space( indent ) + "            RIGHTALIGN "    + xArray[ nItem, 47 ]            + CRLF )

           IF ! Empty( xArray[ nItem, 49 ] )
              Output += Space( Indent ) + "            FIELD "           + xArray[ nItem, 49 ]   + CRLF
           ENDIF

           IF xArray[ nItem, 51 ] # "NIL"
              Output += Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 51 ]   + CRLF
           ENDIF

           IF xArray[ nItem, 53 ] # "NIL"
              Output += Space( Indent ) + "            FONTCOLOR "       + xArray[ nItem, 53 ]   + CRLF
           ENDIF

           IF ! Empty( xArray[ nItem, 55 ] )
              Output += Space( Indent ) + "            DATEFORMAT "      + xArray[ nItem, 55 ]   + CRLF
           ENDIF

           IF xArray[ nItem, 57 ] # "NIL"
              Output += Space( Indent ) + "            TITLEBACKCOLOR "  + xArray[ nItem, 57 ]   + CRLF
           ENDIF

           IF xArray[ nItem, 59 ] # "NIL"
              Output += Space( Indent ) + "            TITLEFONTCOLOR "  + xArray[ nItem, 59 ]   + CRLF
           ENDIF

           Output += Space( Indent )    + "     END DATEPICKER " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "TEXTBOX"    // 11

           Output += Space( Indent ) + "     DEFINE TEXTBOX "      + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "       + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + AllTrim( Str( Height ) )       + CRLF
           Output += iif( xArray[ nItem, 13 ]          = '"Arial"' , iif( lSaveAll, Space( indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 13 ] ) + CRLF, "" ), Space(indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 13 ] ) + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = "9"       , iif( lSaveAll, Space( indent ) + "            FONTSIZE "       + xArray[ nItem, 15 ]            + CRLF, "" ), Space(indent ) + "            FONTSIZE "      + xArray[ nItem, 15 ]            + CRLF )
           IF xArray[ nItem, 17 ] # "''"
           Output += iif( xArray[ nItem, 17 ]          = [""]      , iif( lSaveAll, Space( indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space(indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           ENDIF
           Output += iif( Upper( xArray[ nItem, 19 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONCHANGE "       + xArray[ nItem, 19 ]            + CRLF, "" ), Space(indent ) + "            ONCHANGE "      + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONGOTFOCUS "     + xArray[ nItem, 21 ]            + CRLF, "" ), Space(indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONLOSTFOCUS "    + xArray[ nItem, 23 ]            + CRLF, "" ), Space(indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTBOLD "       + xArray[ nItem, 25 ]            + CRLF, "" ), Space(indent ) + "            FONTBOLD "      + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTITALIC "     + xArray[ nItem, 27 ]            + CRLF, "" ), Space(indent ) + "            FONTITALIC "    + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 29 ]            + CRLF, "" ), Space(indent ) + "            FONTUNDERLINE " + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 31 ]            + CRLF, "" ), Space(indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 33 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONENTER "        + xArray[ nItem, 33 ]            + CRLF, "" ), Space(indent ) + "            ONENTER "       + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            HELPID "         + xArray[ nItem, 35 ]            + CRLF, "" ), Space(indent ) + "            HELPID "        + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]          = ".T."     , iif( lSaveAll, Space( indent ) + "            TABSTOP "        + xArray[ nItem, 37 ]            + CRLF, "" ), Space(indent ) + "            TABSTOP "       + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".T."     , iif( lSaveAll, Space( indent ) + "            VISIBLE "        + xArray[ nItem, 39 ]            + CRLF, "" ), Space(indent ) + "            VISIBLE "       + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            READONLY "       + xArray[ nItem, 41 ]            + CRLF, "" ), Space(indent ) + "            READONLY "      + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( xArray[ nItem, 43 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            RIGHTALIGN "     + xArray[ nItem, 43 ]            + CRLF, "" ), Space(indent ) + "            RIGHTALIGN "    + xArray[ nItem, 43 ]            + CRLF )

           IF xArray[ nItem, 45 ] = ".T."
              Output += Space( Indent ) + "            LOWERCASE " + xArray[ nItem, 45 ] + CRLF
           ELSEIF xArray[ nItem, 47 ] = ".T."
              Output += Space( Indent ) + "            UPPERCASE " + xArray[ nItem, 47 ] + CRLF
           ENDIF

           IF xArray[ nItem, 51 ] = ".T."
              Output += Space( Indent ) + "            PASSWORD " + xArray[ nItem, 51 ]  + CRLF
           ENDIF

           IF xArray[ nItem, 75 ] = "CHARACTER" .OR. xArray[ nItem, 75 ] = "NUMERIC" .OR. xArray[ nItem, 51 ] = ".T."
              IF xArray[ nItem, 53 ] # "0"
                 Output += Space( Indent ) + "            MAXLENGTH " + xArray[ nItem, 53 ]  + CRLF
              ENDIF
           ENDIF

           Output += iif( Upper( xArray[ nItem, 55 ] ) = "NIL", iif( lSaveAll, Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 55 ] + CRLF, "" ), Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 55 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 57 ] ) = "NIL", iif( lSaveAll, Space( Indent ) + "            FONTCOLOR " + xArray[ nItem, 57 ] + CRLF, "" ), Space( Indent ) + "            FONTCOLOR " + xArray[ nItem, 57 ] + CRLF )

           IF ! Empty( xArray[ nItem, 59 ] ) .AND. Upper( xArray[ nItem, 59 ] ) # "NIL"
              Output += Space( Indent )+ "            FIELD " + xArray[ nItem, 59 ]  + CRLF
           ENDIF

           IF xArray[ nItem, 61 ] # "''"
              Output += iif( xArray[ nItem, 61 ]    = '""', iif( lSaveAll, Space( Indent ) + "            INPUTMASK NIL" + CRLF, "" ), Space( Indent ) + "            INPUTMASK " + AllTrim( xArray[ nItem, 61 ] ) + CRLF )
           ENDIF
           IF xArray[ nItem, 63 ] # "''"
              Output += iif( xArray[ nItem, 63 ]    = '""', iif( lSaveAll, Space( Indent ) + "            FORMAT NIL"    + CRLF, "" ), Space( Indent ) + "            FORMAT "    + AllTrim( xArray[ nItem, 63 ] ) + CRLF )
           ENDIF

           IF xArray[ nItem, 75 ] = "DATE"
              Output += Space( Indent )+"            DATE  "+xArray[ nItem, 65 ] + CRLF
              Output += iif( xArray[ nItem, 71 ] = '""', iif( lSaveAll, Space( Indent ) + "            VALUE NIL"  + CRLF, "" ), Space( Indent )+"            VALUE " + AllTrim( xArray[ nItem, 71 ] ) + CRLF )

           ELSEIF xArray[ nItem, 75 ] = "NUMERIC"
              Output += Space( Indent )+"            NUMERIC  "+xArray[ nItem, 67 ] + CRLF
              Output += iif( xArray[ nItem, 71 ] = '""', iif( lSaveAll, Space( Indent ) + "            VALUE NIL"  + CRLF, "" ), Space( Indent )+"            VALUE " + AllTrim( xArray[ nItem, 71 ] ) + CRLF )
           ELSE
              IF xArray[ nItem, 71 ] # "''"
                 Output += iif( xArray[ nItem, 71 ] = '""', iif( lSaveAll, Space( Indent ) + "            VALUE "     + AllTrim( xArray[ nItem, 71 ] ) + CRLF, "" ), Space( Indent ) + "            VALUE " + AllTrim( xArray[ nItem, 71 ] ) + CRLF )
              ENDIF
           ENDIF
             IF xArray[ nItem, 77 ] = ".F."
              Output += Space( Indent ) + "            BORDER " + xArray[ nItem, 77 ]  + CRLF
           ENDIF

           Output += Space( Indent )+"     END TEXTBOX " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "BTNTEXTBOX"    // 29

           Output += Space( Indent ) + "     DEFINE BTNTEXTBOX "  + AllTrim( xArray[ nItem, 3 ] ) + CRLF
           Output += Space( Indent ) + "            ROW    "      + AllTrim( Str( Row ) )         + CRLF
           Output += Space( Indent ) + "            COL    "      + AllTrim( Str( Col ) )         + CRLF
           Output += Space( Indent ) + "            WIDTH  "      + AllTrim( Str( Width ) )       + CRLF
           Output += Space( Indent ) + "            HEIGHT "      + AllTrim( Str( Height ) )      + CRLF

           IF xArray[ nItem, 13 ]# "NIL" .AND. Len(AllTrim( xArray[ nItem, 13 ] )) > 0
              Output += Space( Indent ) + "            FIELD " + AllTrim( xArray[ nItem, 13 ] )   + CRLF
           ENDIF

           Output += iif( xArray[ nItem, 15 ]          = '""'  , iif( lSaveAll, Space( Indent ) + "            VALUE "         + xArray[ nItem, 15 ] + CRLF, "" )           , Space( Indent ) + "            VALUE "   + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 17 ] ) = "NIL" , iif( lSaveAll, Space( Indent ) + "            ACTION "        + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( Indent ) + "            ACTION "  + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = '""'  , iif( lSaveAll, Space( Indent ) + "            PICTURE "       + xArray[ nItem, 19 ] + CRLF, "" )           , Space( Indent ) + "            PICTURE " + xArray[ nItem, 19 ]            + CRLF )

           IF xArray[ nItem, 21 ] # "0"
              Output += Space( Indent )+"            BUTTONWIDTH "+xArray[ nItem, 21 ] + CRLF
           ENDIF

           Output += iif( xArray[ nItem, 23 ] = '"Arial"'    , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + xArray[ nItem, 23 ] + CRLF, "" ), Space( Indent ) + "            FONTNAME "      + xArray[ nItem, 23 ] + CRLF )
           Output += iif( xArray[ nItem, 25 ] = "9"          , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 25 ] + CRLF, "" ), Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 25 ] + CRLF )
           Output += iif( xArray[ nItem, 27 ] = ".F."        , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 27 ] + CRLF, "" ), Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 27 ] + CRLF )
           Output += iif( xArray[ nItem, 29 ] = ".F."        , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 29 ] + CRLF, "" ), Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 29 ] + CRLF )
           Output += iif( xArray[ nItem, 31 ] = ".F."        , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 31 ] + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 31 ] + CRLF )
           Output += iif( xArray[ nItem, 33 ] = ".F."        , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 33 ] + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 33 ] + CRLF )

           IF xArray[ nItem, 35 ] = ".T."
              Output += Space( Indent ) + "            NUMERIC "  + xArray[ nItem, 35 ] + CRLF
           ELSEIF xArray[ nItem, 37 ] = ".T."
              Output += Space( Indent ) + "            PASSWORD " + xArray[ nItem, 37 ] + CRLF
           ENDIF

           Output += iif( xArray[ nItem, 39 ]          = '""' , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "   + xArray[ nItem, 39 ] + CRLF, "" ), Space( Indent ) + "            TOOLTIP "   + xArray[ nItem, 39 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL", iif( lSaveAll, Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 41 ] + CRLF, "" ), Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 41 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL", iif( lSaveAll, Space( Indent ) + "            FONTCOLOR " + xArray[ nItem, 43 ] + CRLF, "" ), Space( Indent ) + "            FONTCOLOR " + xArray[ nItem, 43 ] + CRLF )

           IF xArray[ nItem, 45 ] # "0"
              Output += Space( Indent ) + "            MAXLENGTH " + xArray[ nItem, 45 ] + CRLF
           ENDIF

           IF xArray[ nItem, 47 ] = ".T."
              Output += Space( Indent ) + "            UPPERCASE " + xArray[ nItem, 47 ] + CRLF
           ELSEIF xArray[ nItem, 49 ] = ".T."
              Output += Space( Indent ) + "            LOWERCASE " + xArray[ nItem, 49 ] + CRLF
           ENDIF

           Output += iif( Upper( xArray[ nItem, 51 ] ) = "NIL", iif( lSaveAll, Space( indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 51 ] + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "  + xArray[ nItem, 51 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 53 ] ) = "NIL", iif( lSaveAll, Space( indent ) + "            ONCHANGE "      + xArray[ nItem, 53 ] + CRLF, "" ), Space( indent ) + "            ONCHANGE "    + xArray[ nItem, 53 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 55 ] ) = "NIL", iif( lSaveAll, Space( indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 55 ] + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS " + xArray[ nItem, 55 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 57 ] ) = "NIL", iif( lSaveAll, Space( indent ) + "            ONENTER "       + xArray[ nItem, 57 ] + CRLF, "" ), Space( indent ) + "            ONENTER "     + xArray[ nItem, 57 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 59 ] ) = ".F.", iif( lSaveAll, Space( indent ) + "            RIGHTALIGN "    + xArray[ nItem, 59 ] + CRLF, "" ), Space( indent ) + "            RIGHTALIGN "  + xArray[ nItem, 59 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 61 ] ) = ".T.", iif( lSaveAll, Space( indent ) + "            VISIBLE "       + xArray[ nItem, 61 ] + CRLF, "" ), Space( indent ) + "            VISIBLE "     + xArray[ nItem, 61 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 63 ] ) = ".T.", iif( lSaveAll, Space( indent ) + "            TABSTOP "       + xArray[ nItem, 63 ] + CRLF, "" ), Space( indent ) + "            TABSTOP "     + xArray[ nItem, 63 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 65 ] ) = "NIL", iif( lSaveAll, Space( indent ) + "            HELPID "        + xArray[ nItem, 65 ] + CRLF, "" ), Space( indent ) + "            HELPID "      + xArray[ nItem, 65 ] + CRLF )
           Output += iif( Upper( xArray[ nItem, 67 ] ) = ".F.", iif( lSaveAll, Space( indent ) + "            DISABLEEDIT "   + xArray[ nItem, 67 ] + CRLF, "" ), Space( indent ) + "            DISABLEEDIT " + xArray[ nItem, 67 ] + CRLF )
// added 07/09/2016 p.d. 
           Output += iif( empty( xArray[ nItem, 75 ]), ;
                          iif( lSaveAll, Space( indent ) + "            CUEBANNER " + '""' + CRLF, ""),;
                          Space( indent ) + "            CUEBANNER " + xArray[ nItem, 75 ] + CRLF )
// end 07/09/2016
           
           Output += Space( Indent )+"     END BTNTEXTBOX " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "HOTKEYBOX"   // 30

           Output += Space( indent ) + "     DEFINE HOTKEYBOX "      + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( indent ) + "            ROW    "         + AllTrim( Str( Row ) )          + CRLF
           Output += Space( indent ) + "            COL    "         + AllTrim( Str( Col ) )          + CRLF
           Output += Space( indent ) + "            WIDTH  "         + AllTrim( Str( Width ) )        + CRLF
           Output += Space( indent ) + "            HEIGHT "         + AllTrim( Str( Height ) )       + CRLF
           Output += Space( indent ) + "            VALUE "          + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           Output += Space( indent ) + "            FONTNAME "       + xArray[ nItem, 15 ]            + CRLF     // Renaldo
           Output += Space( indent ) + "            FONTSIZE "       + xArray[ nItem, 17 ]            + CRLF
           Output += Space( indent ) + "            FONTBOLD "       + xArray[ nItem, 19 ]            + CRLF
           Output += Space( indent ) + "            FONTITALIC "     + xArray[ nItem, 21 ]            + CRLF
           Output += Space( indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 23 ]            + CRLF
           Output += Space( indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 25 ]            + CRLF
           Output += Space( indent ) + "            TOOLTIP "        + xArray[ nItem, 27 ]            + CRLF
           Output += Space( indent ) + "            ONCHANGE "       + xArray[ nItem, 29 ]            + CRLF
           Output += Space( indent ) + "            HELPID "         + xArray[ nItem, 31 ]            + CRLF
           Output += Space( indent ) + "            VISIBLE "        + xArray[ nItem, 33 ]            + CRLF
           Output += Space( indent ) + "            TABSTOP "        + xArray[ nItem, 35 ]            + CRLF
           Output += Space( indent ) + "     END HOTKEYBOX " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "EDITBOX"    // 12

           Output += Space( Indent ) + "     DEFINE EDITBOX "      + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "       + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + AllTrim( Str( Width  ))        + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + AllTrim( Str( Height ) )       + CRLF
           Output += iif( xArray[ nItem, 13 ]          = '""'      , iif( lSaveAll, Space( indent ) + "            VALUE "         + AllTrim( xArray[ nItem, 13 ] ) + CRLF, "" ), Space( indent ) + "            VALUE "             + AllTrim( xArray[ nItem, 13 ] )   + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = '"Arial"' , iif( lSaveAll, Space( indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 15 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "          + AllTrim( xArray[ nItem, 15 ] )   + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = "9"       , iif( lSaveAll, Space( indent ) + "            FONTSIZE "      + xArray[ nItem, 17 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "          + xArray[ nItem, 17 ]              + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = [""]      , iif( lSaveAll, Space( indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "           + AllTrim( xArray[ nItem, 19 ] )   + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONCHANGE "      + xArray[ nItem, 21 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "          + xArray[ nItem, 21 ]              + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            ONGOTFOCUS "        + xArray[ nItem, 23 ]              + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            ONLOSTFOCUS "       + xArray[ nItem, 25 ]              + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTBOLD "      + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "          + xArray[ nItem, 27 ]              + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTITALIC "    + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "        + xArray[ nItem, 29 ]              + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTUNDERLINE " + xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE "     + xArray[ nItem, 31 ]              + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 33 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT "     + xArray[ nItem, 33 ]              + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            HELPID "        + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            HELPID "            + xArray[ nItem, 35 ]              + CRLF )
           Output += iif( xArray[ nItem, 37 ]          = ".T."     , iif( lSaveAll, Space( indent ) + "            TABSTOP "       + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            TABSTOP "           + xArray[ nItem, 37 ]              + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".T."     , iif( lSaveAll, Space( indent ) + "            VISIBLE "       + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            VISIBLE "           + xArray[ nItem, 39 ]              + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".F."     , iif( lSaveAll, Space( indent ) + "            READONLY "      + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            READONLY "          + xArray[ nItem, 41 ]              + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            BACKCOLOR "     + xArray[ nItem, 43 ]            + CRLF, "" ), Space( indent ) + "            BACKCOLOR "         + xArray[ nItem, 43 ]              + CRLF )
           Output += iif( Upper( xArray[ nItem, 45 ] ) = "NIL"     , iif( lSaveAll, Space( indent ) + "            FONTCOLOR "     + xArray[ nItem, 45 ]            + CRLF, "" ), Space( indent ) + "            FONTCOLOR "         + xArray[ nItem, 45 ]              + CRLF )

           IF xArray[ nItem, 47 ] # "0"
              Output += Space( Indent )    + "            MAXLENGTH  "  + xArray[ nItem, 47 ] + CRLF
           ENDIF

           IF ! Empty( xArray[ nItem, 49 ] ) .AND.  Upper( xArray[ nItem, 49 ] ) # "NIL"
              IF At( ">", xArray[ nItem, 49 ] ) # 0
                 Output += Space( Indent ) + "            FIELD  "      + xArray[ nItem, 49 ] + CRLF
              ENDIF
           ENDIF

           IF xArray[ nItem, 51 ] # ".T." .OR. lSaveAll
              Output += Space( Indent )    + "            HSCROLLBAR  " + xArray[ nItem, 51 ] + CRLF
           ENDIF

           IF xArray[ nItem, 53 ] # ".T." .OR. lSaveAll
              Output += Space( Indent )    + "            VSCROLLBAR  " + xArray[ nItem, 53 ] + CRLF
           ENDIF

           IF xArray[ nItem, 55 ] # ".F."
              Output += Space( Indent )    + "            BREAK  "      + xArray[ nItem, 55 ] + CRLF
           ENDIF

           Output += Space( Indent ) + "     END EDITBOX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "LABEL"      // 13

           Output += Space( Indent ) + "     DEFINE LABEL "        + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "       + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + AllTrim( xArray[ nItem,  9 ] ) + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + AllTrim( xArray[ nItem, 11 ] ) + CRLF
           Output += Space( Indent ) + "            VALUE "        + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           Output += iif( xArray[ nItem, 15 ]          = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 15 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 15 ] ) + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( xArray[ nItem, 23 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 29 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "        + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            TRANSPARENT "   + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            TRANSPARENT "   + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ACTION "        + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            ACTION "        + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 61 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONMOUSEHOVER "  + xArray[ nItem, 61 ]            + CRLF, "" ), Space( Indent ) + "            ONMOUSEHOVER "  + xArray[ nItem, 61 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 63 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONMOUSELEAVE "  + xArray[ nItem, 63 ]            + CRLF, "" ), Space( Indent ) + "            ONMOUSELEAVE "  + xArray[ nItem, 63 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            AUTOSIZE "      + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            AUTOSIZE "      + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 41 ]            + CRLF )

           Output += iif( xArray[ nItem, 51 ]          = ".T."     ,                Space( Indent ) + "            BORDER "        + xArray[ nItem, 51 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 53 ]          = ".T."     ,                Space( Indent ) + "            CLIENTEDGE "    + xArray[ nItem, 53 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 55 ]          = ".T."     ,                Space( Indent ) + "            HSCROLL "       + xArray[ nItem, 55 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 57 ]          = ".T."     ,                Space( Indent ) + "            VSCROLL "       + xArray[ nItem, 57 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 59 ]          = ".T."     ,                Space( Indent ) + "            BLINK "         + xArray[ nItem, 59 ]            + CRLF, "" )

           IF xArray[ nItem, 43 ] = "2"
              Output += Space( Indent ) + "            RIGHTALIGN .T."   + CRLF
           ELSEIF xArray[ nItem, 43 ] = "3"
              Output += Space( Indent ) + "            CENTERALIGN .T."  + CRLF
           ENDIF

           Output += Space( Indent ) + "     END LABEL  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       CASE cCtrlName == "CHECKLABEL"      // 31

           Output += Space( Indent ) + "     DEFINE CHECKLABEL "        + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "       + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + AllTrim( xArray[ nItem,  9 ] ) + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + AllTrim( xArray[ nItem, 11 ] ) + CRLF
           Output += Space( Indent ) + "            VALUE "        + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           
           Output += iif( xArray[ nItem, 23 ]          = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 23 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 23 ] ) + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 35 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 35 ] ) + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 33 ]            + CRLF )           
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 63 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "        + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( xArray[ nItem, 45 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 65 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 55 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            TRANSPARENT "   + xArray[ nItem, 51 ]            + CRLF, "" ), Space( Indent ) + "            TRANSPARENT "   + xArray[ nItem, 55 ]            + CRLF )           
           Output += iif( Upper( xArray[ nItem, 15 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ACTION "        + xArray[ nItem, 15 ]            + CRLF, "" ), Space( Indent ) + "            ACTION "        + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 17 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONMOUSEHOVER "  + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            ONMOUSEHOVER "  + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 19 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONMOUSELEAVE "  + xArray[ nItem, 19 ]            + CRLF, "" ), Space( Indent ) + "            ONMOUSELEAVE "  + xArray[ nItem, 19 ]            + CRLF )           
           Output += iif( xArray[ nItem, 21 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            AUTOSIZE "      + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            AUTOSIZE "      + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 39 ]            + CRLF )

           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            IMAGE "         + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            IMAGE "     + xArray[ nItem, 41 ]            + CRLF )

           Output += iif( xArray[ nItem, 47 ]          = ".T."     ,                Space( Indent ) + "            BORDER "        + xArray[ nItem, 47 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 49 ]          = ".T."     ,                Space( Indent ) + "            CLIENTEDGE "    + xArray[ nItem, 49 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 51 ]          = ".T."     ,                Space( Indent ) + "            HSCROLL "       + xArray[ nItem, 51 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 53 ]          = ".T."     ,                Space( Indent ) + "            VSCROLL "       + xArray[ nItem, 53 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 57 ]          = ".T."     ,                Space( Indent ) + "            BLINK "         + xArray[ nItem, 57 ]            + CRLF, "" )

           IF xArray[ nItem, 59 ] =  "2"
              Output += Space( Indent ) + "            RIGHTALIGN .T."   + CRLF
           ELSEIF xArray[ nItem, 59 ] =  "3"
              Output += Space( Indent ) + "            CENTERALIGN .T."  + CRLF
           ENDIF
           Output += iif( xArray[ nItem, 67 ]          = ".T."     ,                Space( Indent ) + "            LEFTCHECK "     + xArray[ nItem, 59 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 69 ]          = ".T."     ,                Space( Indent ) + "            CHECKED "       + xArray[ nItem, 61 ]            + CRLF, "" )

           Output += Space( Indent ) + "     END CHECKLABEL  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName ==  "PLAYER"    // 22

           Output += Space( Indent ) + "     DEFINE PLAYER "   + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "   + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "   + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "   + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "   + AllTrim( Str( Height ) )       + CRLF
           Output += Space( Indent ) + "            FILE "     + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           Output += iif( Upper( xArray[ nItem, 15 ] ) = "NIL" , iif( lSaveAll, Space( Indent ) + "            HELPID "           + xArray[ nItem, 15 ] + CRLF, "" ), Space( Indent ) + "            HELPID "            + xArray[ nItem, 15 ] + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            NOAUTOSIZEWINDOW " + xArray[ nItem, 17 ] + CRLF, "" ), Space( Indent ) + "            NOAUTOSIZEWINDOW "  + xArray[ nItem, 17 ] + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            NOAUTOSIZEMOVIE "  + xArray[ nItem, 19 ] + CRLF, "" ), Space( Indent ) + "            NOAUTOSIZEMOVIE "   + xArray[ nItem, 19 ] + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            NOERRORDLG "       + xArray[ nItem, 21 ] + CRLF, "" ), Space( Indent ) + "            NOERRORDLG "        + xArray[ nItem, 21 ] + CRLF )
           Output += iif( xArray[ nItem, 23 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            NOMENU "           + xArray[ nItem, 23 ] + CRLF, "" ), Space( Indent ) + "            NOMENU "            + xArray[ nItem, 23 ] + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            NOOPEN "           + xArray[ nItem, 25 ] + CRLF, "" ), Space( Indent ) + "            NOOPEN "            + xArray[ nItem, 25 ] + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            NOPLAYBAR "        + xArray[ nItem, 27 ] + CRLF, "" ), Space( Indent ) + "            NOPLAYBAR "         + xArray[ nItem, 27 ] + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            SHOWALL "          + xArray[ nItem, 29 ] + CRLF, "" ), Space( Indent ) + "            SHOWALL "           + xArray[ nItem, 29 ] + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            SHOWMODE "         + xArray[ nItem, 31 ] + CRLF, "" ), Space( Indent ) + "            SHOWMODE "          + xArray[ nItem, 31 ] + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            SHOWNAME "         + xArray[ nItem, 33 ] + CRLF, "" ), Space( Indent ) + "            SHOWNAME "          + xArray[ nItem, 33 ] + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F." , iif( lSaveAll, Space( Indent ) + "            SHOWPOSITION "     + xArray[ nItem, 35 ] + CRLF, "" ), Space( Indent ) + "            SHOWPOSITION "      + xArray[ nItem, 35 ] + CRLF )
           Output += Space( Indent ) + "     END PLAYER  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "PROGRESSBAR"  // 21

           Output += Space( Indent ) + "     DEFINE PROGRESSBAR " + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "      + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "      + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "      + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "      + AllTrim( Str( Height ) )       + CRLF
           Output += Space( Indent ) + "            RANGEMIN "    + xArray[ nItem, 13 ]            + CRLF
           Output += Space( Indent ) + "            RANGEMAX "    + xArray[ nItem, 15 ]            + CRLF
           Output += iif( xArray[ nItem, 17 ]          = "0"      , iif( lSaveAll, Space( Indent ) + "            VALUE "   + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            VALUE "     + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = [""]     , iif( lSaveAll, Space( Indent ) + "            TOOLTIP " + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "   + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"    , iif( lSaveAll, Space( Indent ) + "            HELPID "  + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "    + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( xArray[ nItem, 23 ]          = ".T."    , iif( lSaveAll, Space( Indent ) + "            VISIBLE " + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "   + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = ".F."    , iif( lSaveAll, Space( Indent ) + "            SMOOTH "  + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            SMOOTH "    + xArray[ nItem, 25 ]            + CRLF )

           IF xArray[ nItem, 33 ] = "1"
              Output += iif( xArray[ nItem, 33 ]       = "1"        , iif( lSaveAll, Space( Indent ) + "            VERTICAL .F." + CRLF, "" ), Space( Indent ) + "            VERTICAL .F." + CRLF )
           ELSE
              Output += Space( Indent ) + "            VERTICAL .T." + CRLF
           ENDIF

           Output += iif( Upper( xArray[ nItem, 29 ] )  = "NIL"   , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 29 ]        + CRLF, "" ), Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 29 ]          + CRLF )
           Output += iif( Upper( xArray[ nItem, 31 ] )  = "NIL"   , iif( lSaveAll, Space( Indent ) + "            FORECOLOR " + xArray[ nItem, 31 ]        + CRLF, "" ), Space( Indent ) + "            FORECOLOR " + xArray[ nItem, 31 ]          + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] )  = ".F."   , iif( lSaveAll, Space( Indent ) + "            MARQUEE "   + xArray[ nItem, 35 ]        + CRLF, "" ), Space( Indent ) + "            MARQUEE "   + xArray[ nItem, 35 ]          + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] )  == "40"   , iif( lSaveAll, Space( Indent ) + "            VELOCITY "  + xArray[ nItem, 37 ]        + CRLF, "" ), Space( Indent ) + "            VELOCITY "  + xArray[ nItem, 37 ]          + CRLF )
           
           
           Output += Space( Indent )+"     END PROGRESSBAR  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "RADIOGROUP"   // 15

           Output += Space( Indent ) + "     DEFINE RADIOGROUP "   + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + xArray[ nItem, 5 ]             + CRLF
           Output += Space( Indent ) + "            COL    "       + xArray[ nItem, 7 ]             + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + xArray[ nItem, 9 ]             + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + xArray[ nItem, 11 ]            + CRLF
           Output += Space( Indent ) + "            OPTIONS "      + xArray[ nItem, 13 ]            + CRLF
           Output += iif( xArray[ nItem, 15 ]          = "0"       , iif( lSaveAll, Space( Indent ) + "            VALUE "         + xArray[ nItem, 15 ]          + CRLF, "" ), Space( Indent ) + "            VALUE "          + xArray[ nItem, 15 ]          + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 19 ]          + CRLF, "" ), Space( Indent ) + "            FONTSIZE "       + xArray[ nItem, 19 ]          + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "      + xArray[ nItem, 23 ]          + CRLF, "" ), Space( Indent ) + "            ONCHANGE "       + xArray[ nItem, 23 ]          + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 25 ]          + CRLF, "" ), Space( Indent ) + "            FONTBOLD "       + xArray[ nItem, 25 ]          + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 27 ]          + CRLF, "" ), Space( Indent ) + "            FONTITALIC "     + xArray[ nItem, 27 ]          + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 29 ]          + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 29 ]          + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 31 ]          + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 31 ]          + CRLF )
           Output += iif( Upper( xArray[ nItem, 33 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 33 ]          + CRLF, "" ), Space( Indent ) + "            HELPID "         + xArray[ nItem, 33 ]          + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            TABSTOP "       + xArray[ nItem, 35 ]          + CRLF, "" ), Space( Indent ) + "            TABSTOP "        + xArray[ nItem, 35 ]          + CRLF )
           Output += iif( xArray[ nItem, 37 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 37 ]          + CRLF, "" ), Space( Indent ) + "            VISIBLE "        + xArray[ nItem, 37 ]          + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            TRANSPARENT "   + xArray[ nItem, 39 ]          + CRLF, "" ), Space( Indent ) + "            TRANSPARENT "    + xArray[ nItem, 39 ]          + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = "25"      , iif( lSaveAll, Space( Indent ) + "            SPACING "       + xArray[ nItem, 41 ]          + CRLF, "" ), Space( Indent ) + "            SPACING "        + xArray[ nItem, 41 ]          + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 43 ]          + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "      + xArray[ nItem, 43 ]          + CRLF )
           Output += iif( Upper( xArray[ nItem, 45 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 45 ]          + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "      + xArray[ nItem, 45 ]          + CRLF )

           IF xArray[ nItem, 47 ] # ".F."
              Output += Space( Indent ) + "            LEFTJUSTIFY " + xArray[ nItem, 47 ] + CRLF
           ENDIF

           Output += iif(Len(AllTrim( xArray[ nItem, 51 ] )) = 0    , iif( lSaveAll, Space( Indent ) + "            READONLY NIL"                      + CRLF, "" ), Space( Indent ) + "            READONLY "   + xArray[ nItem, 51 ] + CRLF )
           Output += iif( xArray[ nItem, 49 ]                = ".F.", iif( lSaveAll, Space( Indent ) + "            HORIZONTAL " + xArray[ nItem, 49 ] + CRLF, "" ), Space( Indent ) + "            HORIZONTAL " + xArray[ nItem, 49 ] + CRLF )
           Output += Space( Indent )+"     END RADIOGROUP  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "SLIDER"     // 7

           Output += Space( Indent ) + "     DEFINE SLIDER "    + AllTrim( xArray[ nItem,  3 ] ) + CRLF
           Output += Space( Indent ) + "            ROW    "    + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "    + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "    + AllTrim( xArray[ nItem,  9 ] ) + CRLF
           Output += Space( Indent ) + "            HEIGHT "    + AllTrim( xArray[ nItem, 11 ] ) + CRLF
           Output += Space( Indent ) + "            RANGEMIN "  + xArray[ nItem, 13 ]            + CRLF
           Output += Space( Indent ) + "            RANGEMAX "  + xArray[ nItem, 15 ]            + CRLF
           Output += iif( xArray[ nItem, 17 ]          = "0"    , iif( lSaveAll, Space( Indent ) + "            VALUE "    + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            VALUE "    + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = [""]   , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "  + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "  + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"  , iif( lSaveAll, Space( Indent ) + "            ONCHANGE " + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            ONCHANGE " + xArray[ nItem, 21 ]            + CRLF )

           IF xArray[ nItem, 53 ] # "NIL"
              Output += Space( Indent ) + "            ONSCROLL " + xArray[ nItem, 53 ] + CRLF
           ENDIF

           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"    , iif( lSaveAll, Space( Indent ) + "            HELPID "   + xArray[ nItem, 23 ]          + CRLF, "" ), Space( Indent ) + "            HELPID "   + xArray[ nItem, 23 ]          + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = ".T."    , iif( lSaveAll, Space( Indent ) + "            TABSTOP "  + xArray[ nItem, 25 ]          + CRLF, "" ), Space( Indent ) + "            TABSTOP "  + xArray[ nItem, 25 ]          + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".T."    , iif( lSaveAll, Space( Indent ) + "            VISIBLE "  + xArray[ nItem, 27 ]          + CRLF, "" ), Space( Indent ) + "            VISIBLE "  + xArray[ nItem, 27 ]          + CRLF )

           IF xArray[ nItem, 33 ] = "2"
              IF xArray[ nItem, 35 ] = "1"
                 Output += Space( Indent ) + "            BOTH .T."     + CRLF
              ELSEIF xArray[ nItem, 35 ] = "2"
                 Output += Space( Indent ) + "            LEFT .T."     + CRLF
              ELSEIF xArray[ nItem, 35 ] = "3"
                 Output += Space( Indent ) + "            NOTICKS .T."  + CRLF
              ENDIF
              Output += Space( Indent )    + "            VERTICAL .T." + CRLF
           ENDIF

           IF xArray[ nItem, 33 ] = "1"
              IF xArray[ nItem, 35 ] = "1"
                 Output += Space( Indent ) + "            BOTH .T."     + CRLF
              ELSEIF xArray[ nItem, 35 ] = "4"
                 Output += Space( Indent ) + "            TOP .T."      + CRLF
              ELSEIF xArray[ nItem, 35 ] = "3"
                 Output += Space( Indent ) + "            NOTICKS .T."  + CRLF
              ENDIF
           ENDIF

           Output += iif( Upper( xArray[ nItem, 31 ] ) = "NIL", iif( lSaveAll, Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 31 ] + CRLF, "" ), Space( Indent ) + "            BACKCOLOR " + xArray[ nItem, 31 ] + CRLF )
           Output += Space( Indent ) + "     END SLIDER  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "SPINNER"     //  8

           Output += Space( Indent ) + "     DEFINE SPINNER "        + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "         + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "         + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "         + xArray[ nItem,  9 ]            + CRLF
           Output += Space( Indent ) + "            HEIGHT "         + xArray[ nItem, 11 ]            + CRLF
           Output += Space( Indent ) + "            RANGEMIN "       + xArray[ nItem, 13 ]            + CRLF
           Output += Space( Indent ) + "            RANGEMAX "       + xArray[ nItem, 15 ]            + CRLF
           Output += iif( xArray[ nItem, 17 ]          = "0"       , iif( lSaveAll, Space( Indent ) + "            VALUE "         + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            VALUE "           + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "        + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( xArray[ nItem, 23 ]          = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 23 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "         + AllTrim( xArray[ nItem, 23 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "      + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            ONCHANGE "        + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 29 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "        + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "      + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "          + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            TABSTOP "       + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            TABSTOP "         + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( xArray[ nItem, 43 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 43 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "         + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( xArray[ nItem, 45 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            WRAP "          + xArray[ nItem, 45 ]            + CRLF, "" ), Space( Indent ) + "            WRAP "            + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 47 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            READONLY "      + xArray[ nItem, 47 ]            + CRLF, "" ), Space( Indent ) + "            READONLY "        + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( xArray[ nItem, 49 ]          = "1"       , iif( lSaveAll, Space( Indent ) + "            INCREMENT "     + xArray[ nItem, 49 ]            + CRLF, "" ), Space( Indent ) + "            INCREMENT "       + xArray[ nItem, 49 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 51 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 51 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 51 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 53 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 53 ]            + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "       + xArray[ nItem, 53 ]            + CRLF )
           Output += Space( Indent ) + "     END SPINNER  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "FRAME"     // 16

           Output += Space( Indent ) + "     DEFINE FRAME "         + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "        + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "        + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "        + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "        + AllTrim( Str( Height ) )       + CRLF
           Output += iif( xArray[ nItem, 13 ]          = '"Arial"'  , iif( lSaveAll, Space( Indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 13 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "          + AllTrim( xArray[ nItem, 13 ] ) + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = "9"        , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "        + xArray[ nItem, 15 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "          + xArray[ nItem, 15 ]            + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "        + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "          + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "      + xArray[ nItem, 19 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "        + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "     + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( xArray[ nItem, 23 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "     + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = '""'       , iif( lSaveAll, Space( Indent ) + "            CAPTION NIL"                                       + CRLF, "" ), Space( Indent ) + "            CAPTION "           + AllTrim( xArray[ nItem, 25 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 27 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "         + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 29 ] ) = "NIL"      , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "       + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "         + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            OPAQUE "          + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            OPAQUE "            + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            TRANSPARENT "     + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            TRANSPARENT "       + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."      , iif( lSaveAll, Space( Indent ) + "            INVISIBLE "       + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            INVISIBLE "         + xArray[ nItem, 33 ]            + CRLF )

           Output += Space( Indent ) + "     END FRAME  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "BROWSE"  // 14

           /* Start Code - A.M. Revized 23/12/2007 */

           IF Empty( xArray[ nItem, 89 ] ) .OR. Upper( xArray[ nItem, 89 ] ) == "NIL"
              cWorkArea := xArray[ nItem, 19 ]
           ELSE
              cWorkArea := xArray[ nItem, 89 ]
           ENDIF
           xArray[ nItem, 89 ] := cWorkArea

           /* End Code - A.M. Revized 23/12/2007 */

           Output += Space( Indent ) + "     DEFINE BROWSE "       + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "       + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + AllTrim( Str( Height ) )       + CRLF
           
           Output += Space( Indent ) + "            HEADERS "      + xArray[ nItem, 13 ]            + CRLF
           Output += Space( Indent ) + "            WIDTHS "       + xArray[ nItem, 15 ]            + CRLF
           Output += Space( Indent ) + "            FIELDS "       + xArray[ nItem, 17 ]            + CRLF
           Output += iif( xArray[ nItem, 19 ]          = "0"       , iif( lSaveAll, Space( Indent ) + "            VALUE "            + xArray[ nItem, 13 ]            + CRLF, "" ), Space( Indent ) + "            VALUE "              + xArray[ nItem, 19 ]            + CRLF )
           Output += Space( Indent ) + "            WORKAREA "     + xArray[ nItem, 21 ]            + CRLF
           Output += iif( xArray[ nItem, 23 ]          = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "         + AllTrim( xArray[ nItem, 23 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "           + AllTrim( xArray[ nItem, 23 ] ) + CRLF )
           Output += iif( xArray[ nItem, 25 ]          = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "         + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "           + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "         + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "           + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "       + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "         + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE "    + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "      + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT "    + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "      + xArray[ nItem, 33 ]            + CRLF )         
           Output += iif( xArray[ nItem, 35 ]          = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "          + AllTrim( xArray[ nItem, 35 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "            + AllTrim( xArray[ nItem, 35 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 37 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "        + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "          + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 39 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            DYNAMICBACKCOLOR " + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            DYNAMICBACKCOLOR "   + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            DYNAMICFORECOLOR " + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            DYNAMICFORECOLOR "   + xArray[ nItem, 41 ]            + CRLF )          
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "        + xArray[ nItem, 43 ]            + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "          + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 45 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "       + xArray[ nItem, 45 ]            + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "         + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 47 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "         + xArray[ nItem, 47 ]            + CRLF, "" ), Space( Indent ) + "            ONCHANGE "           + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 49 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "      + xArray[ nItem, 49 ]            + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "        + xArray[ nItem, 49 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 51 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONDBLCLICK "       + xArray[ nItem, 51 ]            + CRLF, "" ), Space( Indent ) + "            ONDBLCLICK "         + xArray[ nItem, 51 ]            + CRLF )
           Output += iif( xArray[ nItem, 53 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            ALLOWEDIT "        + xArray[ nItem, 53 ]            + CRLF, "" ), Space( Indent ) + "            ALLOWEDIT "          + xArray[ nItem, 53 ]            + CRLF )
           Output += iif( xArray[ nItem, 55 ]          = ".T."     , Space( Indent )                + "            INPLACEEDIT "      + xArray[ nItem, 55 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 57 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            ALLOWAPPEND "      + xArray[ nItem, 57 ]            + CRLF, "" ), Space( Indent ) + "            ALLOWAPPEND "        + xArray[ nItem, 57 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 59 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            INPUTITEMS "       + xArray[ nItem, 59 ]            + CRLF, "" ), Space( Indent ) + "            IMPUTITEMS "         + xArray[ nItem, 59 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 61 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            DISPLAYITEMS "     + xArray[ nItem, 61 ]            + CRLF, "" ), Space( Indent ) + "            DISPLAYITEMS "       + xArray[ nItem, 61 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 63 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONHEADCLICK "      + xArray[ nItem, 63 ]            + CRLF, "" ), Space( Indent ) + "            ONHEADCLICK "        + xArray[ nItem, 63 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 65 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            WHEN "             + xArray[ nItem, 65 ]            + CRLF, "" ), Space( Indent ) + "            WHEN "               + xArray[ nItem, 65 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 67 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            VALID "            + xArray[ nItem, 67 ]            + CRLF, "" ), Space( Indent ) + "            VALID "              + xArray[ nItem, 67 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 69 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            VALIDMESSAGES "    + xArray[ nItem, 69 ]            + CRLF, "" ), Space( Indent ) + "            VALIDMESSAGES "      + xArray[ nItem, 69 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 71 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            PAINTDOUBLEBUFFER "+ xArray[ nItem, 71 ]            + CRLF, "" ), Space( Indent ) + "            PAINTDOUBLEBUFFER "  + xArray[ nItem, 71 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 73 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            READONLYFIELDS "   + xArray[ nItem, 73 ]            + CRLF, "" ), Space( Indent ) + "            READONLYFIELDS "     + xArray[ nItem, 73 ]            + CRLF )
           Output += iif( xArray[ nItem, 75 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            LOCK "             + xArray[ nItem, 75 ]            + CRLF, "" ), Space( Indent ) + "            LOCK "               + xArray[ nItem, 75 ]            + CRLF )
           Output += iif( xArray[ nItem, 77 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            ALLOWDELETE "      + xArray[ nItem, 77 ]            + CRLF, "" ), Space( Indent ) + "            ALLOWDELETE "        + xArray[ nItem, 77 ]            + CRLF )
           Output += iif( xArray[ nItem, 79 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            NOLINES "          + xArray[ nItem, 79 ]            + CRLF, "" ), Space( Indent ) + "            NOLINES "            + xArray[ nItem, 79 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 81 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            IMAGE "            + xArray[ nItem, 81 ]            + CRLF, "" ), Space( Indent ) + "            IMAGE "              + xArray[ nItem, 81 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 83 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            JUSTIFY "          + xArray[ nItem, 83 ]            + CRLF, "" ), Space( Indent ) + "            JUSTIFY "            + xArray[ nItem, 83 ]            + CRLF )
           Output += iif( xArray[ nItem, 85 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            VSCROLLBAR "       + xArray[ nItem, 85 ]            + CRLF, "" ), Space( Indent ) + "            VSCROLLBAR "         + xArray[ nItem, 85 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 87 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "           + xArray[ nItem, 87 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "             + xArray[ nItem, 87 ]            + CRLF )
           Output += iif( xArray[ nItem, 89 ]          = ".T."     ,                Space( Indent ) + "            BREAK "            + xArray[ nItem, 89 ]            + CRLF, "" )
                   
           Output += iif(!Empty( xArray[ nItem, 91 ] )             , Space( Indent )                + "            HEADERIMAGE "     + xArray[ nItem, 91 ]            + CRLF, "" )
           Output += iif( xArray[ nItem, 93 ]          = ".T."     , Space( Indent )                + "            NOTABSTOP "       + xArray[ nItem, 93 ]            + CRLF, "" )
           
         * Output += iif( Upper( xArray[ nItem, 95] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            INPUTMASK "       + xArray[ nItem, 95 ]            + CRLF, "" ), Space( Indent ) + "            INPUTMASK "          + xArray[ nItem, 95 ]            + CRLF )
         * Output += iif( Upper( xArray[ nItem, 97] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            FORMAT "          + xArray[ nItem, 97 ]            + CRLF, "" ), Space( Indent ) + "            FORMAT "             + xArray[ nItem, 97 ]            + CRLF )
      
           
           
           Output += Space( Indent )+"     END BROWSE  " + CRLF
           Output += CRLF

           /* Start Code - A.M. Revized 23/12/2007 */
           SavePath( AllTrim( xArray[ nItem, 3 ] ), xArray[ nItem, 87 ] )

           SaveDbfName( AllTrim( xArray[ nItem, 3 ] ), xArray[ nItem, 19 ] )

           IF AllTrim( xArray[ nItem, 19 ] ) == AllTrim( xArray[ nItem, 89 ] )
              SaveAlias( AllTrim( xArray[ nItem, 3 ] ), "" )
           ELSE
              SaveAlias( AllTrim( xArray[ nItem, 3 ] ), xArray[ nItem, 89 ] )
           ENDIF
           /* End Code - A.M. Revized 23/12/2007 */

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName ==  "HYPERLINK"  // 18

           Output += Space( Indent ) + "     DEFINE HYPERLINK "   + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "      + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "      + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "      + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "      + AllTrim( Str( Height ) )       + CRLF
           Output += iif( xArray[ nItem, 13 ]         = '""'      , iif( lSaveAll, Space( Indent ) + "            VALUE "         + AllTrim( xArray[ nItem, 13 ] ) + CRLF, "" ), Space( Indent ) + "            VALUE "          + AllTrim( xArray[ nItem, 13 ] ) + CRLF )
           Output += iif( xArray[ nItem, 15 ]         = '""'      , iif( lSaveAll, Space( Indent ) + "            ADDRESS "       + AllTrim( xArray[ nItem, 15 ] ) + CRLF, "" ), Space( Indent ) + "            ADDRESS "        + AllTrim( xArray[ nItem, 15 ] ) + CRLF )
           Output += iif( xArray[ nItem, 17 ]         = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 17 ] ) + CRLF )
           Output += iif( xArray[ nItem, 19 ]         = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 19 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "       + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]         = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( xArray[ nItem, 23 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "       + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "     + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            AUTOSIZE "      + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            AUTOSIZE "       + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 33 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "         + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]         = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "       + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "        + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 43 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            RIGHTALIGN "    + xArray[ nItem, 43 ]            + CRLF, "" ), Space( Indent ) + "            RIGHTALIGN "     + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( xArray[ nItem, 45 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            CENTERALIGN "   + xArray[ nItem, 45 ]            + CRLF, "" ), Space( Indent ) + "            CENTERALIGN "    + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            HANDCURSOR "    + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            HANDCURSOR "     + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 39 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "      + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 41 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "      + xArray[ nItem, 41 ]            + CRLF )
           Output += Space( Indent )+"     END HYPERLINK  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "MONTHCALENDAR"  // 19

           Output += Space( Indent ) + "     DEFINE MONTHCALENDAR " + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "        + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "        + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "        + AllTrim( Str( Width  ))        + CRLF
           Output += Space( Indent ) + "            HEIGHT "        + AllTrim( Str( Height ) )       + CRLF
           Output += iif( xArray[ nItem, 13 ]         = "CTOD('')"  , iif( lSaveAll, Space( indent ) + "            VALUE "          + xArray[ nItem, 13 ]            + CRLF, "" ), Space( indent ) + "            VALUE "          + xArray[ nItem, 13 ]            + CRLF )
           Output += iif( xArray[ nItem, 15 ]         = '"Arial"'   , iif( lSaveAll, Space( indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 15 ] ) + CRLF, "" ), Space( indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 15 ] ) + CRLF )
           Output += iif( xArray[ nItem, 17 ]         = "9"         , iif( lSaveAll, Space( indent ) + "            FONTSIZE "       + xArray[ nItem, 17 ]            + CRLF, "" ), Space( indent ) + "            FONTSIZE "       + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]         = [""]        , iif( lSaveAll, Space( indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] )= "NIL"       , iif( lSaveAll, Space( indent ) + "            ONCHANGE "       + xArray[ nItem, 21 ]            + CRLF, "" ), Space( indent ) + "            ONCHANGE "       + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( xArray[ nItem, 23 ]         = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTBOLD "       + xArray[ nItem, 23 ]            + CRLF, "" ), Space( indent ) + "            FONTBOLD "       + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]         = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTITALIC "     + xArray[ nItem, 25 ]            + CRLF, "" ), Space( indent ) + "            FONTITALIC "     + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]         = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 27 ]            + CRLF, "" ), Space( indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]         = ".F."       , iif( lSaveAll, Space( indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 29 ]            + CRLF, "" ), Space( indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 31 ] )= "NIL"       , iif( lSaveAll, Space( indent ) + "            HELPID "         + xArray[ nItem, 31 ]            + CRLF, "" ), Space( indent ) + "            HELPID "         + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]         = ".T."       , iif( lSaveAll, Space( indent ) + "            TABSTOP "        + xArray[ nItem, 33 ]            + CRLF, "" ), Space( indent ) + "            TABSTOP "        + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]         = ".T."       , iif( lSaveAll, Space( indent ) + "            VISIBLE "        + xArray[ nItem, 35 ]            + CRLF, "" ), Space( indent ) + "            VISIBLE "        + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]         = ".F."       , iif( lSaveAll, Space( indent ) + "            NOTODAY "        + xArray[ nItem, 37 ]            + CRLF, "" ), Space( indent ) + "            NOTODAY "        + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]         = ".F."       , iif( lSaveAll, Space( indent ) + "            NOTODAYCIRCLE "  + xArray[ nItem, 39 ]            + CRLF, "" ), Space( indent ) + "            NOTODAYCIRCLE "  + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]         = ".F."       , iif( lSaveAll, Space( indent ) + "            WEEKNUMBERS "    + xArray[ nItem, 41 ]            + CRLF, "" ), Space( indent ) + "            WEEKNUMBERS "    + xArray[ nItem, 41 ]            + CRLF )

           IF xArray[ nItem, 43 ] # "NIL"
              Output += Space( Indent ) + "            BACKCOLOR "          + xArray[ nItem, 43 ] + CRLF
           ENDIF

           IF xArray[ nItem, 45 ] # "NIL"
              Output += Space( Indent ) + "            FONTCOLOR "          + xArray[ nItem, 45 ] + CRLF
           ENDIF

           IF xArray[ nItem, 47 ] # "NIL"
              Output += Space( Indent ) + "            TITLEBACKCOLOR "     + xArray[ nItem, 47 ] + CRLF
           ENDIF

           IF xArray[ nItem, 49 ] # "NIL"
              Output += Space( Indent ) + "            TITLEFONTCOLOR "     + xArray[ nItem, 49 ] + CRLF
           ENDIF

           IF xArray[ nItem, 51 ] # "NIL"
              Output += Space( Indent ) + "            BKGNDCOLOR "         + xArray[ nItem, 51 ] + CRLF
           ENDIF

           IF xArray[ nItem, 53 ] # "NIL"
              Output += Space( Indent ) + "            TRAILINGFONTCOLOR "  + xArray[ nItem, 53 ] + CRLF
           ENDIF

           Output += Space( Indent )    + "     END MONTHCALENDAR  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "RICHEDITBOX"  // 20

           Output += Space( Indent ) + "     DEFINE RICHEDITBOX "  + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "       + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "       + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "       + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "       + AllTrim( Str( Height ) )       + CRLF
           Output += iif( xArray[ nItem, 13 ]          = '""'      , iif( lSaveAll, Space( Indent ) + "            VALUE "           + AllTrim( xArray[ nItem, 13 ] ) + CRLF, "" ), Space( Indent ) + "            VALUE "           + AllTrim( xArray[ nItem, 13 ] ) + CRLF )
           Output += iif( xArray[ nItem, 15 ]          = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 15 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 15 ] ) + CRLF )
           Output += iif( xArray[ nItem, 17 ]          = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "        + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "        + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]          = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "         + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "         + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "        + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            ONCHANGE "        + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "        + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "        + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "      + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "      + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "          + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "          + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            TABSTOP "         + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            TABSTOP "         + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "         + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "         + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            READONLY "        + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            READONLY "        + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 43 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 43 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 43 ]            + CRLF )

           IF Upper( xArray[ nItem, 59 ] ) # "NIL"
              Output += Space( Indent ) + "            FONTCOLOR "   + xArray[ nItem, 59 ]  + CRLF
           ENDIF

           IF ! Empty( xArray[ nItem, 45 ] ) .AND.  Upper( xArray[ nItem, 45 ] ) # "NIL"
              Output += Space( Indent ) + "            FIELD  "      + xArray[ nItem, 45 ]  + CRLF
           ELSEIF ! Empty( xArray[ nItem, 49 ] ) .AND.  Upper( xArray[ nItem, 49 ] ) # "NIL"
              Output += Space( Indent ) + "            FILE "        + AllTrim( xArray[ nItem, 49 ] ) + CRLF
           ENDIF

           IF xArray[ nItem, 47 ] # "0"
              Output += Space( Indent ) + "            MAXLENGTH  "  + xArray[ nItem, 47 ]  + CRLF
           ENDIF

           IF Upper( xArray[ nItem, 51 ] ) # "NIL"
              Output += Space( Indent ) + "            ONSELECT  "   + xArray[ nItem, 51 ]  + CRLF
           ENDIF

           IF Upper( xArray[ nItem, 53 ] ) # ".F."
              Output += Space( Indent ) + "            PLAINTEXT  "  + xArray[ nItem, 53 ]  + CRLF
           ENDIF

           IF Upper( xArray[ nItem, 55 ] ) # ".T." .OR. lSaveAll
              Output += Space( Indent ) + "            HSCROLLBAR  " + xArray[ nItem, 55 ]  + CRLF
           ENDIF

           IF Upper( xArray[ nItem, 57 ] ) # ".T." .OR. lSaveAll
              Output += Space( Indent ) + "            VSCROLLBAR  " + xArray[ nItem, 57 ]  + CRLF
           ENDIF

           IF Upper( xArray[ nItem, 61 ] ) # ".F."
              Output += Space( Indent ) + " BREAK  "                 + xArray[ nItem, 61 ]  + CRLF
           ENDIF

           IF Upper( xArray[ nItem, 63 ] ) # "NIL"
              Output += Space( Indent ) + "            ONVSCROLL "   + xArray[ nItem, 63 ]  + CRLF
           ENDIF

           Output += Space( Indent )    + "     END RICHEDITBOX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "IPADDRESS"   // 23

           Output += Space( Indent ) + "     DEFINE IPADDRESS "     + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "        + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "        + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "        + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "        + AllTrim( Str( Height ) )       + CRLF
           Output += iif( xArray[ nItem, 13 ]         = "{0,0,0,0}" , iif( lSaveAll, Space( Indent ) + "            VALUE "          + xArray[ nItem, 13 ]            + CRLF, "" ), Space( Indent ) + "            VALUE "          + xArray[ nItem, 13 ]            + CRLF )
           Output += iif( xArray[ nItem, 15 ]         = '"Arial"'   , iif( lSaveAll, Space( Indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 15 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 15 ] ) + CRLF )
           Output += iif( xArray[ nItem, 17 ]         = "9"         , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "       + xArray[ nItem, 17 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "       + xArray[ nItem, 17 ]            + CRLF )
           Output += iif( xArray[ nItem, 19 ]         = [""]        , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 19 ] ) + CRLF, "" ), Space( Indent ) + "            TOOLTIP "        + AllTrim( xArray[ nItem, 19 ] ) + CRLF )
           Output += iif( Upper( xArray[ nItem, 21 ] )= "NIL"       , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "       + xArray[ nItem, 21 ]            + CRLF, "" ), Space( Indent ) + "            ONCHANGE "       + xArray[ nItem, 21 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 23 ] )= "NIL"       , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "     + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "     + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 25 ] )= "NIL"       , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "    + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "    + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]         = ".F."       , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "       + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "       + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]         = ".F."       , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "     + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "     + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]         = ".F."       , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( xArray[ nItem, 33 ]         = ".F."       , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 35 ] )= "NIL"       , iif( lSaveAll, Space( Indent ) + "            HELPID "         + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "         + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]         = ".T."       , iif( lSaveAll, Space( Indent ) + "            TABSTOP "        + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            TABSTOP "        + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]         = ".T."       , iif( lSaveAll, Space( Indent ) + "            VISIBLE "        + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "        + xArray[ nItem, 39 ]            + CRLF )
           Output += Space( Indent ) + "     END IPADDRESS "  + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "TIMER"        //?

           Output += Space( Indent ) + "     DEFINE TIMER " + AllTrim( xArray[ nItem, 3 ] )
           Output += Space( Indent ) + " INTERVAL "         + xArray[ nItem, 5 ]
           Output += Space( Indent ) + " ACTION "           + xArray[ nItem, 7 ] + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "BUTTONEX"     // 24

           Output += Space( Indent ) + "     DEFINE BUTTONEX "    + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "      + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "      + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "      + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "      + AllTrim( Str( Height ) )       + CRLF
           IF ! Empty( xArray[ nItem, 13 ] )     .AND. xArray[ nItem, 13 ] # [""]
              Output += Space( Indent ) + "            CAPTION "     + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           ENDIF

           IF ! Empty( xArray[ nItem, 15 ] )     .AND. ! Upper( xArray[ nItem, 15 ] ) == "NIL"
              IF xArray[ nItem, 15 ] # [""]
              Output += Space( Indent ) + "            PICTURE "  + AllTrim( xArray[ nItem, 15 ] ) + CRLF
              Output += Space( Indent ) + "            ICON NIL"                                   + CRLF
              ENDIF

           ELSEIF ! Empty( xArray[ nItem, 17 ] ) .AND. ! Upper( xArray[ nItem, 17 ] ) == "NIL"
              Output += Space( Indent ) + "            PICTURE NIL"                                + CRLF
              Output += Space( Indent ) + "            ICON "     + AllTrim( xArray[ nItem, 17 ] ) + CRLF
           ENDIF

           Output += iif( Upper( xArray[ nItem, 19 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            ACTION "          + xArray[ nItem, 19 ]            + CRLF, "" ), Space( Indent ) + "            ACTION "          + xArray[ nItem, 19 ]            + CRLF )
           Output += iif( xArray[ nItem, 21 ]         = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 21 ] ) + CRLF, "" ), Space( Indent ) + "            FONTNAME "        + AllTrim( xArray[ nItem, 21 ] ) + CRLF )
           Output += iif( xArray[ nItem, 23 ]         = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "        + xArray[ nItem, 23 ]            + CRLF, "" ), Space( Indent ) + "            FONTSIZE "        + xArray[ nItem, 23 ]            + CRLF )
           Output += iif( xArray[ nItem, 25 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "        + xArray[ nItem, 25 ]            + CRLF, "" ), Space( Indent ) + "            FONTBOLD "        + xArray[ nItem, 25 ]            + CRLF )
           Output += iif( xArray[ nItem, 27 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "      + xArray[ nItem, 27 ]            + CRLF, "" ), Space( Indent ) + "            FONTITALIC "      + xArray[ nItem, 27 ]            + CRLF )
           Output += iif( xArray[ nItem, 29 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 29 ]            + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 29 ]            + CRLF )
           Output += iif( xArray[ nItem, 31 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 31 ]            + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 31 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 33 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "       + xArray[ nItem, 33 ]            + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "       + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            VERTICAL "        + xArray[ nItem, 35 ]            + CRLF, "" ), Space( Indent ) + "            VERTICAL "        + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            LEFTTEXT "        + xArray[ nItem, 37 ]            + CRLF, "" ), Space( Indent ) + "            LEFTTEXT "        + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            UPPERTEXT "       + xArray[ nItem, 39 ]            + CRLF, "" ), Space( Indent ) + "            UPPERTEXT "       + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            ADJUST "          + xArray[ nItem, 41 ]            + CRLF, "" ), Space( Indent ) + "            ADJUST "          + xArray[ nItem, 41 ]            + CRLF )
           Output += iif( xArray[ nItem, 43 ]         = [""]      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "         + xArray[ nItem, 43 ]            + CRLF, "" ), Space( Indent ) + "            TOOLTIP "         + xArray[ nItem, 43 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 45 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 45 ]            + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( xArray[ nItem, 47 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            NOHOTLIGHT "      + xArray[ nItem, 47 ]            + CRLF, "" ), Space( Indent ) + "            NOHOTLIGHT "      + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( xArray[ nItem, 49 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            FLAT "            + xArray[ nItem, 49 ]            + CRLF, "" ), Space( Indent ) + "            FLAT "            + xArray[ nItem, 49 ]            + CRLF )
           Output += iif( xArray[ nItem, 51 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            NOTRANSPARENT "   + xArray[ nItem, 51 ]            + CRLF, "" ), Space( Indent ) + "            NOTRANSPARENT "   + xArray[ nItem, 51 ]            + CRLF )
           Output += iif( xArray[ nItem, 53 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            NOXPSTYLE "       + xArray[ nItem, 53 ]            + CRLF, "" ), Space( Indent ) + "            NOXPSTYLE "       + xArray[ nItem, 53 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 55 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 55 ]            + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 55 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 57 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 57 ]            + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 57 ]            + CRLF )
           Output += iif( xArray[ nItem, 59 ]         = ".T."     , iif( lSaveAll, Space( Indent ) + "            TABSTOP "         + xArray[ nItem, 59 ]            + CRLF, "" ), Space( Indent ) + "            TABSTOP "         + xArray[ nItem, 59 ]            + CRLF )
           Output += iif( xArray[ nItem, 67 ]         = ".T."     , iif( lSaveAll, Space( Indent ) + "            HANDCURSOR "      + xArray[ nItem, 67 ]            + CRLF, "" ), Space( Indent ) + "            HANDCURSOR "      + xArray[ nItem, 67 ]            + CRLF )
        
           Output += iif( Upper( xArray[ nItem, 61 ] )= "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "          + xArray[ nItem, 61 ]            + CRLF, "" ), Space( Indent ) + "            HELPID "          + xArray[ nItem, 61 ]            + CRLF )
           Output += iif( xArray[ nItem, 63 ]         = ".T."     , iif( lSaveAll, Space( Indent ) + "            VISIBLE "         + xArray[ nItem, 63 ]            + CRLF, "" ), Space( Indent ) + "            VISIBLE "         + xArray[ nItem, 63 ]            + CRLF )
           Output += iif( xArray[ nItem, 65 ]         = ".F."     , iif( lSaveAll, Space( Indent ) + "            DEFAULT "         + xArray[ nItem, 65 ]            + CRLF, "" ), Space( Indent ) + "            DEFAULT "         + xArray[ nItem, 65 ]            + CRLF )
           Output += Space( Indent ) + "     END BUTTONEX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "COMBOBOXEX"  // 25

           Output += Space( Indent )+"     DEFINE COMBOBOXEX "  + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent )+"            ROW    "      + AllTrim( xArray[ nItem, 5 ] )  + CRLF
           Output += Space( Indent )+"            COL    "      + AllTrim( xArray[ nItem, 7 ] )  + CRLF
           Output += Space( Indent )+"            WIDTH  "      + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent )+"            HEIGHT "      + AllTrim( xArray[ nItem, 11 ] ) + CRLF
           Output += iif( Empty( xArray[ nItem, 13 ] ), "", Space( Indent ) + "            ITEMS " + AllTrim( xArray[ nItem, 13 ] ) + CRLF )

           IF Empty( xArray[ nItem, 13 ] ) .AND. !Empty( xArray[ nItem, 15 ] )
              Output += Space( Indent ) + "            ITEMSOURCE "      + xArray[ nItem, 15 ] + CRLF
           ENDIF

           Output += iif( xArray[ nItem, 17 ] = "0", iif( lSaveAll, Space( Indent ) + "            VALUE " + AllTrim( xArray[ nItem, 17 ] ) + CRLF, "" ), Space( Indent ) + "            VALUE " + AllTrim( xArray[ nItem, 17 ] ) + CRLF )

           IF !Empty( xArray[ nItem, 19 ] )
              Output += Space( Indent ) + "            VALUESOURCE "     + xArray[ nItem, 19 ] + CRLF
           ENDIF

           IF xArray[ nItem, 21 ] # ".F."
              Output += Space( Indent ) + "            DISPLAYEDIT "     + xArray[ nItem, 21 ] + CRLF
           ENDIF

           IF xArray[ nItem, 23 ] # "0"
              Output += Space( Indent ) + "            LISTWIDTH "       + xArray[ nItem, 23 ] + CRLF
           ENDIF

           IF xArray[ nItem, 25 ] # "Arial"
              Output += Space( Indent ) + "            FONTNAME "        + xArray[ nItem, 25 ] + CRLF
           ENDIF

           IF xArray[ nItem, 27 ] # "9"
              Output += Space( Indent ) + "            FONTSIZE "        + xArray[ nItem, 27 ] + CRLF
           ENDIF

           IF xArray[ nItem, 29 ] # ".F."
              Output += Space( Indent ) + "            FONTBOLD "        + xArray[ nItem, 29 ] + CRLF
           ENDIF

           IF xArray[ nItem, 31 ] # ".F."
              Output += Space( Indent ) + "            FONTITALIC "      + xArray[ nItem, 31 ] + CRLF
           ENDIF

           IF xArray[ nItem, 33 ] # ".F."
              Output += Space( Indent ) + "            FONTUNDERLINE "   + xArray[ nItem, 33 ] + CRLF
           ENDIF

           IF xArray[ nItem, 35 ] # ".F."
              Output += Space( Indent ) + "            FONTSTRIKEOUT "   + xArray[ nItem, 35 ] + CRLF
           ENDIF            

           IF xArray[ nItem, 37 ] # [""]
              Output += Space( Indent ) + "            TOOLTIP "         + xArray[ nItem, 37 ] + CRLF
           ENDIF

           IF xArray[ nItem, 65 ] # "NIL"
              Output += Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 65 ] + CRLF
           ENDIF

           IF xArray[ nItem, 67 ] # "NIL"
              Output += Space( Indent )  +"            FONTCOLOR "       + xArray[ nItem, 67 ] + CRLF
           ENDIF

           IF xArray[ nItem, 39 ] # "NIL"
              Output += Space( Indent ) + "            ONGOTFOCUS "      + xArray[ nItem, 39 ] + CRLF
           ENDIF

           IF xArray[ nItem, 41 ] # "NIL"
              Output += Space( Indent ) + "            ONCHANGE "        + xArray[ nItem, 41 ] + CRLF
           ENDIF

           IF xArray[ nItem, 43 ] # "NIL"
              Output += Space( Indent ) + "            ONLOSTFOCUS "     + xArray[ nItem, 43 ] + CRLF
           ENDIF

           IF xArray[ nItem, 45 ] # "NIL"
              Output += Space( Indent ) + "            ONENTER "         + xArray[ nItem, 45 ] + CRLF
           ENDIF

           IF xArray[ nItem, 47 ] # "NIL"
              Output += Space( Indent ) + "            ONDISPLAYCHANGE " + xArray[ nItem, 47 ] + CRLF
           ENDIF

           IF xArray[ nItem, 49 ] # "NIL"
              Output += Space( Indent ) + "            ONLISTDISPLAY "   + xArray[ nItem, 49 ] + CRLF
           ENDIF

           IF xArray[ nItem, 51 ] # "NIL"
              Output += Space( Indent ) + "            ONLISTCLOSE "     + xArray[ nItem, 51 ] + CRLF
           ENDIF

           IF xArray[ nItem, 53 ] # ".T."
              Output += Space( Indent ) + "            TABSTOP "         + xArray[ nItem, 53 ] + CRLF
           ENDIF

           IF xArray[ nItem, 55 ] # "NIL"
              Output += Space( Indent ) + "            HELPID "          + xArray[ nItem, 55 ] + CRLF
           ENDIF

           IF xArray[ nItem, 57 ] # '""'
              Output += Space( Indent ) + "            GRIPPERTEXT "     + xArray[ nItem, 57 ] + CRLF
           ENDIF

           IF xArray[ nItem, 59 ] # ".F."
              Output += Space( Indent ) + "            BREAK "           + xArray[ nItem, 59 ] + CRLF
           ENDIF

           IF xArray[ nItem, 61 ] # ".T."
              Output += Space( Indent ) + "            VISIBLE "         + xArray[ nItem, 61 ] + CRLF
           ENDIF

           Output += iif( Empty( xArray[ nItem, 63 ] ), "", Space( Indent ) + "            IMAGE " + xArray[ nItem, 63 ] + CRLF )

           IF Empty( xArray[ nItem, 63 ] ) .AND. ! Empty( xArray[ nItem, 69 ] )
              Output += Space( Indent ) + "            IMAGELIST "       + xArray[ nItem, 69 ] + CRLF
           ENDIF

           Output += Space( Indent ) + "     END COMBOBOXEX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "GETBOX"     // 28

           Output += Space( Indent ) + "     DEFINE GETBOX "  + AllTrim( xArray[ nItem, 3 ] ) + CRLF
           Output += Space( Indent ) + "            ROW    "  + AllTrim( Str( Row ) )         + CRLF
           Output += Space( Indent ) + "            COL    "  + AllTrim( Str( Col ) )         + CRLF
           Output += Space( Indent ) + "            WIDTH  "  + AllTrim( Str( Width ) )       + CRLF
           Output += Space( Indent ) + "            HEIGHT "  + AllTrim( Str( Height ) )      + CRLF

           IF xArray[ nItem, 13 ] # "NIL" .AND.  Len(AllTrim( xArray[ nItem, 13 ] )) > 0
              Output += Space( Indent ) + "            FIELD " + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           ENDIF

           IF xArray[ nItem, 15 ] # "NIL"
              Output += Space( Indent ) + "            VALUE "         + xArray[ nItem, 15 ] + CRLF
           ELSEIF  Len( AllTrim( xArray[ nItem, 13 ] ) ) = 0
              Output += Space( Indent ) + "            VALUE 0"                              + CRLF
           ENDIF

           IF xArray[ nItem, 65 ] # "NIL"
              Output += Space( Indent ) + "            ACTION "        + xArray[ nItem, 65 ] + CRLF
           ENDIF

           IF xArray[ nItem, 67 ] # "NIL"
              Output += Space( Indent ) + "            ACTION2 "       + xArray[ nItem, 67 ] + CRLF
           ENDIF

           IF xArray[ nItem, 69 ] # '""'
              Output += Space( Indent ) + "            IMAGE "         + xArray[ nItem, 69 ] + CRLF
           ENDIF

           IF xArray[ nItem, 71 ] # "0"
              Output += Space( Indent ) + "            BUTTONWIDTH "   + xArray[ nItem, 71 ] + CRLF
           ENDIF

           IF xArray[ nItem, 17 ] # '""'
              Output += Space( Indent ) + "            PICTURE "       + AllTrim( xArray[ nItem, 17 ] ) + CRLF
           ENDIF

           IF xArray[ nItem, 19 ] # "NIL"
              Output += Space( Indent ) + "            VALID "         + xArray[ nItem, 19 ] + CRLF
           ENDIF

           IF xArray[ nItem, 21 ] # "NIL"
              Output += Space( Indent ) + "            RANGE "         + xArray[ nItem, 21 ] + CRLF
           ENDIF

           IF xArray[ nItem, 23 ] # '""'
              Output += Space( Indent ) + "            VALIDMESSAGE "  + xArray[ nItem, 23 ] + CRLF
           ENDIF

           IF xArray[ nItem, 25 ] # '""'
              Output += Space( Indent ) + "            MESSAGE "       + xArray[ nItem, 25 ] + CRLF
           ENDIF

           IF xArray[ nItem, 27 ] # "NIL"
              Output += Space( Indent ) + "            WHEN "          + xArray[ nItem, 27 ] + CRLF
           ENDIF

           IF xArray[ nItem, 29 ] # ".F."
              Output += Space( Indent ) + "            READONLY "      + xArray[ nItem, 29 ] + CRLF
           ENDIF

           Output += iif( xArray[ nItem, 31 ]          = '"Arial"' , iif( lSaveAll, Space( Indent ) + "            FONTNAME "      + xArray[ nItem, 31 ] + CRLF, "" ), Space( Indent ) + "            FONTNAME "       + AllTrim( xArray[ nItem, 31 ] ) + CRLF )
           Output += iif( xArray[ nItem, 33 ]          = "9"       , iif( lSaveAll, Space( Indent ) + "            FONTSIZE "      + xArray[ nItem, 33 ] + CRLF, "" ), Space( Indent ) + "            FONTSIZE "       + xArray[ nItem, 33 ]            + CRLF )
           Output += iif( xArray[ nItem, 35 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTBOLD "      + xArray[ nItem, 35 ] + CRLF, "" ), Space( Indent ) + "            FONTBOLD "       + xArray[ nItem, 35 ]            + CRLF )
           Output += iif( xArray[ nItem, 37 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTITALIC "    + xArray[ nItem, 37 ] + CRLF, "" ), Space( Indent ) + "            FONTITALIC "     + xArray[ nItem, 37 ]            + CRLF )
           Output += iif( xArray[ nItem, 39 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTUNDERLINE " + xArray[ nItem, 39 ] + CRLF, "" ), Space( Indent ) + "            FONTUNDERLINE "  + xArray[ nItem, 39 ]            + CRLF )
           Output += iif( xArray[ nItem, 41 ]          = ".F."     , iif( lSaveAll, Space( Indent ) + "            FONTSTRIKEOUT " + xArray[ nItem, 41 ] + CRLF, "" ), Space( Indent ) + "            FONTSTRIKEOUT "  + xArray[ nItem, 41 ]            + CRLF )

           IF xArray[ nItem, 43 ]# ".F."
              Output += Space( Indent ) + "            PASSWORD "  + xArray[ nItem, 43 ] + CRLF
           ENDIF

           Output += iif( xArray[ nItem, 45 ]          = '""'      , iif( lSaveAll, Space( Indent ) + "            TOOLTIP "       + xArray[ nItem, 45 ] + CRLF, "" ), Space( Indent ) + "            TOOLTIP "        + xArray[ nItem, 45 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 47 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            BACKCOLOR "     + xArray[ nItem, 47 ] + CRLF, "" ), Space( Indent ) + "            BACKCOLOR "      + xArray[ nItem, 47 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 49 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            FONTCOLOR "     + xArray[ nItem, 49 ] + CRLF, "" ), Space( Indent ) + "            FONTCOLOR "      + xArray[ nItem, 49 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 51 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONCHANGE "      + xArray[ nItem, 51 ] + CRLF, "" ), Space( Indent ) + "            ONCHANGE "       + xArray[ nItem, 51 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 53 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONGOTFOCUS "    + xArray[ nItem, 53 ] + CRLF, "" ), Space( Indent ) + "            ONGOTFOCUS "     + xArray[ nItem, 53 ]            + CRLF )
           Output += iif( Upper( xArray[ nItem, 55 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            ONLOSTFOCUS "   + xArray[ nItem, 55 ] + CRLF, "" ), Space( Indent ) + "            ONLOSTFOCUS "    + xArray[ nItem, 55 ]            + CRLF )

           IF xArray[ nItem, 57 ] # ".F."
              Output += Space( Indent ) + "            RIGHTALIGN " + xArray[ nItem, 57 ] + CRLF
           ENDIF

           IF xArray[ nItem, 59 ] # ".T."
              Output += Space( Indent ) + "            VISIBLE "    + xArray[ nItem, 59 ] + CRLF
           ENDIF

           IF xArray[ nItem, 61 ] # ".T."
              Output += Space( Indent ) + "            TABSTOP "    + xArray[ nItem, 61 ] + CRLF
           ENDIF
           
           Output += IiF( Upper( xArray[ nItem, 73 ] ) = ".T."     , iif( lSaveAll, Space( Indent ) + "            BORDER "        + xArray[ nItem, 73 ] + CRLF, "" ), Space( Indent ) + "            BORDER "         + xArray[ nItem, 73 ]            + CRLF )
           Output += IiF( Upper( xArray[ nItem, 75 ] ) = ".F."     , iif( lSaveAll, Space( Indent ) + "            NOMINUS "       + xArray[ nItem, 75 ] + CRLF, "" ), Space( Indent ) + "            NOMINUS "        + xArray[ nItem, 75 ]            + CRLF )
                   

           Output += IiF( Upper( xArray[ nItem, 63 ] ) = "NIL"     , iif( lSaveAll, Space( Indent ) + "            HELPID "        + xArray[ nItem, 63 ] + CRLF, "" ), Space( Indent ) + "            HELPID "         + xArray[ nItem, 63 ]            + CRLF )
           
         
         
           Output += Space( Indent ) + "     END GETBOX  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "TIMEPICKER"     // 26

           Output += Space( Indent )    + "     DEFINE TIMEPICKER "     + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent )    + "            ROW    "         + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent )    + "            COL    "         + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent )    + "            WIDTH  "         + AllTrim( Str( Width ) )        + CRLF

           IF Len( AllTrim( xArray[ nItem, 11 ] ) ) > 0
              Output += Space( Indent ) + "            VALUE "          + xArray[ nItem, 11 ]            + CRLF
           ENDIF

           IF xArray[ nItem, 13 ] # "NIL" .AND.  Len( AllTrim( xArray[ nItem, 13 ] ) ) > 0
              Output += Space( Indent ) + "            FIELD "          + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           ENDIF

           Output += Space( Indent )    + "            FONTNAME "       + xArray[ nItem, 15 ] + CRLF
           Output += Space( Indent )    + "            FONTSIZE "       + xArray[ nItem, 17 ] + CRLF
           Output += Space( Indent )    + "            FONTBOLD "       + xArray[ nItem, 19 ] + CRLF
           Output += Space( Indent )    + "            FONTITALIC "     + xArray[ nItem, 21 ] + CRLF
           Output += Space( Indent )    + "            FONTUNDERLINE "  + xArray[ nItem, 23 ] + CRLF
           Output += Space( Indent )    + "            FONTSTRIKEOUT "  + xArray[ nItem, 25 ] + CRLF
           Output += Space( Indent )    + "            TOOLTIP "        + xArray[ nItem, 27 ] + CRLF

           IF xArray[ nItem, 29 ] # ".F."
              Output += Space( Indent ) + "            SHOWNONE "       + xArray[ nItem, 29 ] + CRLF
           ENDIF

           IF xArray[ nItem, 31 ] # ".F."
              Output += Space( Indent ) + "            UPDOWN "         + xArray[ nItem, 31 ] + CRLF
           ENDIF

           Output += Space( Indent )    + "            TIMEFORMAT "     + xArray[ nItem, 33 ] + CRLF
           Output += Space( Indent )    + "            ONGOTFOCUS "     + xArray[ nItem, 35 ] + CRLF
           Output += Space( Indent )    + "            ONCHANGE "       + xArray[ nItem, 37 ] + CRLF
           Output += Space( Indent )    + "            ONLOSTFOCUS "    + xArray[ nItem, 39 ] + CRLF
           Output += Space( Indent )    + "            ONENTER "        + xArray[ nItem, 41 ] + CRLF
           Output += Space( Indent )    + "            HELPID "         + xArray[ nItem, 43 ] + CRLF

           IF xArray[ nItem, 45 ] # ".T."
              Output += Space( Indent ) + "            VISIBLE "        + xArray[ nItem, 45 ] + CRLF
           ENDIF

           IF xArray[ nItem, 47 ] # ".T."
              Output += Space( Indent ) + "            TABSTOP "        + xArray[ nItem, 47 ] + CRLF
           ENDIF

           Output += Space( Indent ) + "     END TIMEPICKER  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "QHTM"      // ?

           Output += Space( Indent ) + "     DEFINE QHTM "      + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "    + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "    + AllTrim( Str( Col ) )          + CRLF

           IF Len( AllTrim( xArray[ nItem, 23 ] )) = 0
              Output += Space( Indent ) + "            WIDTH  " + AllTrim( Str( Width ) )        + CRLF
           ELSE
              Output += Space( Indent ) + "            WIDTH  " + AllTrim( xArray[ nItem, 23 ] ) + CRLF
           ENDIF

           IF Len( AllTrim( xArray[ nItem, 25 ] )) = 0
              Output += Space( Indent ) + "            HEIGHT " + AllTrim( Str( Width ) )        + CRLF
           ELSE
              Output += Space( Indent ) + "            HEIGHT " + AllTrim( xArray[ nItem, 25 ] ) + CRLF
           ENDIF

           IF Len( AllTrim( xArray[ nItem, 13 ] )) > 0
              Output += Space( Indent ) + "            VALUE  " + AllTrim( xArray[ nItem, 13 ] ) + CRLF
           ENDIF

           Output += Space( Indent ) + "            FILE   "    + xArray[ nItem, 15 ]            + CRLF
           Output += Space( Indent ) + "            RESOURCE  " + AllTrim( xArray[ nItem, 17 ] ) + CRLF
           Output += Space( Indent ) + "            ONCHANGE  " + xArray[ nItem, 19 ]            + CRLF

           IF xArray[ nItem, 21 ] # ".F."
              Output += Space( Indent ) + "            BORDER " + xArray[ nItem, 21 ]            + CRLF
           ENDIF

           Output += Space( Indent ) + "     END QHTM " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "TBROWSE"    // 40
           aComma := fillcomma(nItem)

           Output += Space( Indent ) + "     DEFINE TBROWSE "   + AllTrim( xArray[ nItem, 3 ] ) + aComma[ 3 ]                 + CRLF
           Output += Space( Indent ) + "            AT    "     + AllTrim( Str( Row )         ) + "," + AllTrim( Str( Col ) ) + " ; " + CRLF
           Output += Space( Indent ) + "            WIDTH  "    + AllTrim( Str( Width ) )       + " ; "                       + CRLF
           Output += Space( Indent ) + "            HEIGHT "    + AllTrim( Str( Height ) )      + " ; "                       + CRLF
           Output += Space( Indent ) + "            HEADERS "   + xArray[ nItem, 13 ]           + aComma[13 ]                 + CRLF
           Output += Space( Indent ) + "            COLSIZES "  + xArray[ nItem, 15 ]           + aComma[15 ]                 + CRLF
           Output += Space( Indent ) + "            WORKAREA "  + xArray[ nItem, 17 ]           + aComma[17 ]                 + CRLF
           Output += Space( Indent ) + "            FIELDS "    + xArray[ nItem, 19 ]           + aComma[19 ]                 + CRLF

           IF  ! Empty( xArray[ nItem, 21 ] )  .AND. ! Empty( xArray[ nItem, 23 ] )
               Output += Space( Indent ) + "            SELECTFILTER " + xArray[ nItem, 21 ] + " FOR " + xArray[ nItem, 23 ] + aComma[ 23 ]
               IF ! Empty( xArray[ nItem, 25 ] )
                  Output += " TO " + xArray[ nItem, 25 ] + aComma[ 25 ] + CRLF
               ELSE
                  Output += CRLF
               ENDIF
            ENDIF

           IF xArray[ nItem, 27 ] # "0"
              Output += Space( Indent ) + "            VALUE "           + xArray[ nItem, 27 ] + aComma[27 ] + CRLF
           ENDIF

           IF xArray[ nItem, 29 ] # "Arial"
              Output += Space( Indent ) + "            FONT "            + AllTrim( xArray[ nItem, 29 ] ) + aComma[29 ] + CRLF
           ENDIF

           IF xArray[ nItem, 31 ] # "9"
              Output += Space( Indent ) + "            SIZE "            + xArray[ nItem, 31 ] + aComma[31 ] + CRLF
           ENDIF

           IF xArray[ nItem, 33 ] = ".T."
              Output += Space( Indent ) + "            BOLD "            + aComma[33 ] + CRLF
           ENDIF

           IF xArray[ nItem, 35 ] = ".T."
              Output += Space( Indent ) + "            ITALIC "          + aComma[35 ] + CRLF
           ENDIF

           IF xArray[ nItem, 37 ] = ".T."
              Output += Space( Indent ) + "            UNDERLINE "       + aComma[37 ] + CRLF
           ENDIF

           IF xArray[ nItem, 39 ] = ".T."
              Output += Space( Indent ) + "            STRIKEOUT "       + aComma[39 ] + CRLF
           ENDIF

           IF Len( xArray[ nItem, 41 ] ) > 0
              Output += Space( Indent ) + "            TOOLTIP "         + xArray[ nItem, 41 ] + aComma[41 ] + CRLF
           ENDIF

           IF xArray[ nItem, 43 ] # "NIL"
              Output += Space( Indent ) + "            BACKCOLOR "       + xArray[ nItem, 43 ] + aComma[43 ] + CRLF
           ENDIF

           IF xArray[ nItem, 45 ] # "NIL"
              Output += Space( Indent ) + "            FONTCOLOR "       + xArray[ nItem, 45 ] + aComma[45 ] + CRLF
           ENDIF

           IF xArray[ nItem, 47 ] # "NIL"
              Output += Space( Indent ) + "            COLORS "          + xArray[ nItem, 47 ] + aComma[47 ] + CRLF
           ENDIF

           IF xArray[ nItem, 49 ] # "NIL"
              Output += Space( Indent ) + "            ON GOTFOCUS "     + xArray[ nItem, 49 ] + aComma[49 ] + CRLF
           ENDIF

           IF xArray[ nItem, 51 ] # "NIL"
              Output += Space( Indent ) + "            ON CHANGE "       + xArray[ nItem, 51 ] + aComma[51 ] + CRLF
           ENDIF

           IF  xArray[ nItem, 53 ] # "NIL"
              Output += Space( Indent ) + "            ON LOSTFOCUS "    + xArray[ nItem, 53 ] + aComma[53 ] + CRLF
           ENDIF

           IF xArray[ nItem, 55 ] # "NIL"
              Output += Space( Indent ) + "            ON DBLCLICK "     + xArray[ nItem, 55 ] + aComma[55 ] + CRLF
           ENDIF

           IF xArray[ nItem, 57 ] = ".T."
              Output += Space( Indent ) + "            EDIT "            + aComma[57 ] + CRLF
           ENDIF

           IF xArray[ nItem, 59 ] = ".T."
              Output += Space( Indent ) + "            GRID "            + aComma[59 ] + CRLF
           ENDIF

           IF xArray[ nItem, 61 ] = ".T."
              Output += Space( Indent ) + "            APPEND "          + aComma[61 ] + CRLF
           ENDIF

           IF xArray[ nItem, 63 ] # "NIL"
              Output += Space( Indent ) + "            ON HEADCLICK "    + xArray[ nItem, 63 ] + aComma[63 ] + CRLF
           ENDIF

           IF xArray[ nItem, 65 ] # "NIL"
              Output += Space( Indent ) + "            WHEN "            + xArray[ nItem, 65 ] + aComma[65 ] + CRLF
           ENDIF

           IF xArray[ nItem, 67 ] # "NIL"
              Output += Space( Indent ) + "            VALID "           + xArray[ nItem, 67 ] + aComma[67 ] + CRLF
           ENDIF

           IF xArray[ nItem, 69 ] # "NIL"
              Output += Space( Indent ) + "            VALIDMESSAGES "   + xArray[ nItem, 69 ] + aComma[69 ] + CRLF
           ENDIF

           IF Len( AllTrim( xArray[ nItem, 71 ] ) ) > 0
              Output += Space( Indent ) + "            MESSAGE "         + xArray[ nItem, 71 ] + aComma[71 ] + CRLF
           ENDIF

           IF xArray[ nItem, 73 ] # "NIL"
              Output += Space( Indent ) + "            READONLY "        + xArray[ nItem, 73 ] + aComma[73 ] + CRLF
           ENDIF

           IF xArray[ nItem, 75 ] = ".T."
              Output += Space( Indent ) + "            LOCK "            + aComma[75 ] + CRLF
           ENDIF

           IF xArray[ nItem, 77 ] = ".T."
              Output += Space( Indent ) + "            DELETE "          + aComma[77 ] + CRLF
           ENDIF

           IF xArray[ nItem, 79 ] = ".T."
              Output += Space( Indent ) + "            NOLINES "         + aComma[79 ] + CRLF
           ENDIF

           IF xArray[ nItem, 81 ] # "NIL"
              Output += Space( Indent ) + "            IMAGE "           + xArray[ nItem, 81 ] + aComma[81 ] + CRLF
           ENDIF

           IF xArray[ nItem, 83 ] # "NIL"
              Output += Space( Indent ) + "            JUSTIFY "         + xArray[ nItem, 83 ] + aComma[83 ] + CRLF
           ENDIF

           IF Len( AllTrim( xArray[ nItem, 85 ] ) ) > 0
              Output += Space( Indent ) + "            HELPID "          + xArray[ nItem, 85 ] + aComma[85 ] + CRLF
           ENDIF

           IF xArray[ nItem, 87 ] = ".T."
              Output += Space( Indent ) + "            BREAK "           + aComma[87 ] + CRLF
           ENDIF

           Output += Space( Indent ) + "     END TBROWSE  " + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "ACTIVEX"    // 27

           Output += Space( Indent ) + "     DEFINE ACTIVEX "  + AllTrim( xArray[ nItem, 3 ] )  + CRLF
           Output += Space( Indent ) + "            ROW    "   + AllTrim( Str( Row ) )          + CRLF
           Output += Space( Indent ) + "            COL    "   + AllTrim( Str( Col ) )          + CRLF
           Output += Space( Indent ) + "            WIDTH  "   + AllTrim( Str( Width ) )        + CRLF
           Output += Space( Indent ) + "            HEIGHT "   + AllTrim( Str( Height ) )       + CRLF
           Output += Space( Indent ) + "            PROGID "   + xArray[ nItem, 13 ]            + CRLF
           Output += Space( Indent ) + "     END ACTIVEX  "                                     + CRLF
           Output += CRLF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      CASE cCtrlName == "PANEL"      // ?
           Output += Space( Indent ) + "    LOAD WINDOW " + AllTrim( xArray[ nItem, 3 ] ) + " AT " + AllTrim( Str(Row) ) + " , " + AllTrim( Str(Col) ) + " WIDTH " + AllTrim( Str(Width) ) + " HEIGHT " + AllTrim( Str(Height) ) + CRLF
           Output += CRLF

   ENDCASE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // MsgBox( "VALUE = " + xArray[ nItem, 1 ] )
   nValue :=  aScan( aUciControls, xArray[ nItem, 1 ] )

   IF nValue > 0

      Output += Space( Indent ) + "    DEFINE " + xArray[ nItem, 1 ] + " " + AllTrim( xArray[ nItem, 3 ] ) + CRLF
      Output += Space( Indent ) + "           ROW    "     + AllTrim( Str( Row ) )                         + CRLF
      Output += Space( Indent ) + "           COL    "     + AllTrim( Str( Col ) )                         + CRLF
      Output += Space( Indent ) + "           WIDTH  "     + AllTrim( Str( Width ) )                       + CRLF
      Output += Space( Indent ) + "           HEIGHT "     + AllTrim( Str( Height ) )                      + CRLF
      nPos := 11

      // MsgBox("nvalue= " + Str( nvalue ) )

      IF Len( aUciProps[ nValue ] ) > 0
         // MsgBox("len-auci= " + Str( Len( aUciProps[nValue ] ) ) + " value1= " + aUciProps[ nValue, 1 ] )
         FOR x := 1 TO Len( aUciProps[ nValue ] )
             nPos += 2
             // MsgBox( "npos1= "   + Str( nPos ) )
             // MsgBox( "uciprop= " + aUciProps[ nValue, x ] )
             // MsgBox( "value= "   + xArray[ nItem, nPos ] )
             Output += Space( indent ) + "           " + Upper( aUciProps[ nValue, x ] ) + " " + xArray[ nItem, nPos ] + CRLF
         NEXT x
      ENDIF

      IF Len( aUciEvents[ nValue ] ) > 0
         FOR x := 1 TO Len( aUciEvents[ nValue ] )
             nPos   += 2
             // MsgBox( "npos2= " + Str( nPos ) )
             // MsgBox( "event= " + aUciEvents[ nValue, x ] )
             // MsgBox( "valu= "  + xArray[ nItem, nPos ] )
             Output += Space( Indent ) + "           " + Upper( aUciEvents[ nValue, x ] ) + " " + xArray[ nItem, nPos ] + CRLF
         NEXT x
      ENDIF

      Output += Space( Indent ) + "     END " + xArray[ nItem, 1 ] + "  " + CRLF

   ENDIF

   // MsgBox("x= " +  xArray[ nItem,  1 ] + " " + xArray[ nItem,  2 ] + " " + xArray[ nItem, 3 ] + " " )
   // MsgBox("x= " +  xArray[ nItem,  4 ] + " " + xArray[ nItem,  5 ] + " " + xArray[ nItem, 6 ] + " " )
   // MsgBox("x= " +  xArray[ nItem,  7 ] + " " + xArray[ nItem,  8 ] + " " + xArray[ nItem, 9 ] + " " )
   // MsgBox("x= " +  xArray[ nItem, 10 ] + " " + xArray[ nItem, 11 ] + " " )

RETURN( output )


*------------------------------------------------------------*
FUNCTION FillComma( Param AS NUMERIC )
*------------------------------------------------------------*
  LOCAL x      AS NUMERIC
  LOCAL aComma AS ARRAY   := Array( 87 )
  LOCAL nItem  AS NUMERIC := Param

  FOR x := 1 TO 87
      aComma[x] := " ; "
  NEXT x

  DO WHILE .T.
     IF xArray[ nItem, 87 ] = ".T."
        aComma[ 87 ] := ""
        EXIT
     ENDIF

     IF Len( AllTrim( xArray[ nItem, 85 ] ) ) > 0
        aComma[ 85 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 83 ] # "NIL"
        aComma[ 83 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 81 ] # "NIL"
        aComma[ 81 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 79 ] = ".T."
        aComma[ 79 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 77 ] = ".T."
        aComma[ 77 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 75 ] = ".T."
        aComma[ 75 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 73 ] # "NIL"
        aComma[ 73 ] := ""
        EXIT
     ENDIF

     IF Len( AllTrim( xArray[ nItem, 71 ] ) ) > 0
        aComma[ 71 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 69 ] # "NIL"
        aComma[ 69 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 67 ] # "NIL"
        aComma[ 67 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 65 ] # "NIL"
        aComma[ 65 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 63 ] # "NIL"
        aComma[ 63 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 61 ] = ".T."
        aComma[ 61 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 59 ] = ".T."
        aComma[ 59 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 57 ] = ".T."
        aComma[ 57 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 55 ] # "NIL"
        aComma[ 55 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 53 ] # "NIL"
        aComma[ 53 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 51 ] # "NIL"
        aComma[ 51 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 49 ] # "NIL"
        aComma[ 49 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 47 ] # "NIL"
        aComma[ 47 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 45 ] # "NIL"
        aComma[ 45 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 43 ] # "NIL"
        aComma[ 43 ] := ""
        EXIT
     ENDIF

     IF Len( xArray[ nItem, 41 ] ) > 0
        aComma[ 41 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 39 ] = ".T."
        aComma[ 39 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 37 ] = ".T."
        aComma[ 37 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 35 ] = ".T."
        aComma[ 35 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 33 ] = ".T."
        aComma[ 33 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 31 ] # "9"
        aComma[ 31 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 29 ] # "Arial"
        aComma[ 29 ] := ""
        EXIT
     ENDIF

     IF xArray[ nItem, 27 ] # "0"
        aComma[27 ] := ""
        EXIT
     ENDIF

     IF ! Empty( xArray[ nItem, 25 ] )
        aComma[ 23 ] := ""
        aComma[ 25 ] := ""
        EXIT
     ENDIF

     IF ! Empty( xArray[ nItem, 21 ] )  .AND. ! Empty( xArray[ nItem, 23 ] )
        aComma[ 23 ] := ""
        aComma[ 25 ] := ""
        EXIT
     ENDIF

     aComma[ 19 ] := ""
     EXIT

  ENDDO

  IF ! Empty( xArray[ nItem, 25 ] )
     aComma[ 23 ] := ""
     aComma[ 25 ] := ""
  ENDIF

  IF ! Empty( xArray[ nItem, 21 ] ) .AND. ! Empty( xArray[ nItem, 23 ] )
     aComma[ 23 ] := ""
     aComma[ 25 ] := ""
  ENDIF

RETURN( aComma )