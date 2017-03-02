#include "minigui.ch"
#include "ide.ch"

#define msgstop( c ) MsgStop( c, 'HMGS-IDE', , .F. )

declare window controlorder
declare window ObjectInspector

MEMVAR h

STATIC ArrayOrderTemp  := {}
STATIC ArrayOrderTemp1 := {}
STATIC ArrayOrderTemp2 := {}

*------------------------------------------------------------*
PROCEDURE ControlOrder()
*------------------------------------------------------------*
   LOCAL l       AS NUMERIC
   LOCAL i       AS NUMERIC
   LOCAL j       AS NUMERIC
   LOCAL cPage   AS STRING
   LOCAL k       AS NUMERIC
   LOCAL p       AS NUMERIC
   LOCAL cValue  AS STRING
   LOCAL Name    AS STRING

   IF ! isWindowActive( Form_1 )
      MsgStop( "No Active Form!" )
      RETURN
   ENDIF

   
   IF ! IsWindowDefined( CONTROLORDER )
      LOAD WINDOW  CONTROLORDER
   ENDIF
   CENTER WINDOW  CONTROLORDER

   // Save values to array
   h := GetFormHandle( DesignForm )
   l := Len( _HMG_aControlHandles )

   FOR i := 1 TO l

       IF _HMG_aControlParentHandles[ i ] == h .AND. _HMG_aControlType[ i ] == 'TAB'

          FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

              cPage := "Page " + AllTrim( Str( j ) )

              FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )
                  IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"  // ADDED
                     cValue := _HMG_aControlPageMap[ i, j, k ]
                  ELSE                                                 // ADDED
                     cValue := _HMG_aControlPageMap[ i, j, k, 1 ]    // ADDED
                  ENDIF                                                // ADDED

                  p := aScan( _HMG_aControlhandles, cValue )           // VERIFY IF IS RADIOGROUP CVALUE = ARRAY SCAN CVALUE[1]

                  IF p = 0
                     p := FindRadioName( cValue )
                  ENDIF

                  IF p > 0
                     Name := _HMG_aControlNames[ p ]
                     aAdd( ArrayOrderTemp , Name                    )
                     aAdd( ArrayOrderTemp1, _HMG_aControlNames[ i ] )
                     aAdd( ArrayOrderTemp2, cPage                   )
                     // MsgBox( "control= " + name + CRLF + "in tab-> " + _HMG_aControlNames[i] + CRLF + "in page-> " + cPage )
                  ENDIF
              NEXT k
          NEXT j
       ENDIF
   NEXT i

   *********************************************
   IF ! isWindowActive( ControlOrder )
      FillTree()
      ControlOrder.Tree_1.expand( 1 )
      ACTIVATE WINDOW  ControlOrder
   ELSE
      SHOW WINDOW ControlOrder
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE cOrderChange()
*------------------------------------------------------------*
   ControlOrder.Tree_1.DeleteAllitems

   FillTree()
   ControlOrder.Tree_1.Expand( 1 )

RETURN

*------------------------------------------------------------*
PROCEDURE FillTree()
*------------------------------------------------------------*
   LOCAL y         AS NUMERIC
   LOCAL z         AS NUMERIC
   LOCAL i         AS NUMERIC
   LOCAL j         AS NUMERIC
   LOCAL k         AS NUMERIC
   LOCAL p         AS NUMERIC
   LOCAL Name      AS STRING
   LOCAL cValue    AS STRING
   LOCAL cControl  AS STRING
   LOCAL cPage     AS STRING
   LOCAL nPos      AS NUMERIC
   LOCAL nLen      AS NUMERIC
   LOCAL nPosPage  AS NUMERIC
   LOCAL nPosItem  AS NUMERIC

   ControlOrder.Tree_1.AddItem( "Form", 0 )                                            // add form

   FOR y := 1 TO Len( xArray )

      cValue := xArray[ y, 3 ]

      IF Empty( cValue )
         EXIT
      ELSE
         // MsgBox("controle= "+cvalue)
         z := aScan2( ArrayOrderTemp, cValue )

         IF z = 0  // not control of tab
            i := aScan2( _hmg_acontrolnames, cValue )

            IF _HMG_aControlParentHandles[ i ] == h .AND. _HMG_aControlType[ i ] == 'TAB'
               // MsgBox( "tab= " + cValue )
               // include tab
               ControlOrder.Tree_1.AddItem( cValue, 1 ) // tab in level 0             // add tab

               nLen     := ControlOrder.Tree_1.ItemCount // npospage
               // MsgBox("len= "+str(nlen) )
               nPosPage := nPosTree( cValue, nLen )

               // include control of tab pages
               FOR j := 1 To Len( _HMG_aControlPageMap[ i ] )

                  cPage := "Page " + AllTrim( Str( j ) )                     // page one level up
                  // MsgBox("page "+AllTrim(str(j))+"pos="+str(npospage) )

                  ControlOrder.Tree_1.AddItem( cPage, nPosPage )                    // add page

                  *****************************************
                  nLen     := ControlOrder.Tree_1.ItemCount
                  nPosItem := nPosTreeControl( nPosPage, nLen, cPage )

                  FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )

                     IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"         // Added
                        cControl := _HMG_aControlPageMap[ i, j, k ]
                     ELSE                                                        // Added
                        cControl := _HMG_aControlPageMap[ i, j, k, 1 ]           // Added
                     ENDIF                                                       // Added

                     p := aScan( _HMG_aControlhandles, cControl )

                     IF p = 0  // added
                        p := FindRadioName( cControl )  // added
                     ENDIF  // added

                     IF p > 0
                        Name := _HMG_aControlNames[ p ]
                        // MsgBox("control of tab= "+name+" pos= "+str(npositem)+ " "+ _HMG_aControlType[p] )
                        IF ControlOrder.check_1.Value = .F.
                           IF xTypeControl( Name ) # 'LABEL'                          // ADDED
                              ControlOrder.Tree_1.AddItem( Name, nPosItem )           // add controls
                           ENDIF                                                      // ADDED
                        ELSE
                           ControlOrder.Tree_1.AddItem( Name, nPosItem )
                        ENDIF
                     ENDIF
                  NEXT k
               NEXT j
               nPos := 0
            ELSE  // include control
               nPos := 1
               // MsgBox("control= "+cvalue+"npos = "+str(npos)+"TOT= "+STR(ControlOrder.Tree_1.ItemCount) )
               IF ControlOrder.check_1.Value = .F.
                  IF xArray[ y, 1 ] # 'LABEL'                      // ADDED
                     ControlOrder.Tree_1.AddItem( cValue, nPos )
                  ENDIF
               ELSE
                  ControlOrder.Tree_1.AddItem( cValue, nPos )
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   NEXT y

RETURN


*------------------------------------------------------------*
FUNCTION nPosTreeControl( xPosPage AS NUMERIC, xLen AS NUMERIC, xPage AS STRING )
*------------------------------------------------------------*
   LOCAL x         AS NUMERIC
   LOCAL RetValue  AS NUMERIC

   FOR x := xPosPage TO xLen
       IF ControlOrder.Tree_1.Item( x ) = xPage
          RetValue := x
          EXIT
       ENDIF
   NEXT x

RETURN( RetValue )


*------------------------------------------------------------*
FUNCTION nPosTree( xValue AS STRING, xLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL x        AS NUMERIC
   LOCAL retvalue AS NUMERIC

   FOR x := 1 TO xLen
       IF ControlOrder.Tree_1.Item( x ) = xValue
          RetValue := x
          EXIT
       ENDIF
   NEXT x

RETURN( RetValue )


*------------------------------------------------------------*
PROCEDURE UpOrder()
*------------------------------------------------------------*
   LOCAL x1         AS USUAL           //? VarType
   LOCAL x2         AS USUAL           //? VarType
   LOCAL nFound     AS NUMERIC
   LOCAL nFound1    AS NUMERIC
   LOCAL nPos1      AS NUMERIC
   LOCAL nPos       AS NUMERIC
   LOCAL cName      AS STRING
   LOCAL cName1     AS STRING
   LOCAL nPos2      AS NUMERIC
   LOCAL nPos3      AS NUMERIC
   LOCAL nValue     AS NUMERIC

   IF ControlOrder.Tree_1.Value > 2

      ControlOrder.Tree_1.DisableUpdate

      x1 :=  ControlOrder.Tree_1.Item( ControlOrder.Tree_1.Value )
      x2 :=  ControlOrder.Tree_1.Item( ( ControlOrder.Tree_1.Value ) - 1 )
      // MsgBox("x1= "+x1+" x2= "+x2)

      IF SubStr( x1, 1, 4 ) = "Page"
         // MsgBox('page found returning')
         ControlOrder.Tree_1.EnableUpdate
         RETURN
      ENDIF

      *****************verify if can move
      nFound := aScan2( ArrayOrderTemp, x1 )

      IF nFound > 0 // first is in tab

         IF SubStr( x2, 1, 4 ) = "Page"
            // MsgBox('page found returning')
            ControlOrder.Tree_1.EnableUpdate
            RETURN
         ENDIF

         nFound1 := aScan2( ArrayOrderTemp, x2 )

      ELSE   // first is out tab
         DO WHILE .T.
            nFound1 := aScan2( ArrayOrderTemp, x2 )

            IF nFound1 = 0 .AND. SubStr( x2, 1, 4 ) # "Page"
               // MsgBox('nfound1= '+ str(nfound1) )
               exit
            ELSE
               ControlOrder.Tree_1.Value := ControlOrder.Tree_1.Value - 1
               x2                        := ControlOrder.Tree_1.Item( ( ControlOrder.Tree_1.Value ) )

               // MsgBox('x2= '+x2+" "+ str(ControlOrder.Tree_1.Value) )
            ENDIF
         enddo
      ENDIF

      **************************************
      IF SubStr( x1, 1, 4 ) = "Tab_"  .OR.  SubStr( x2, 1, 4 ) = "Tab_"
         // MsgBox("x1 or x2 is tab")
         nValue := VerifyPos( x2 )

         AtualizaArray( x1, x2 )

         ControlOrder.Tree_1.DeleteAllitems

         FillTree()

         ControlOrder.Tree_1.Value := nValue

      ELSE
         ControlOrder.Tree_1.Item( ControlOrder.Tree_1.Value )         := x2
         ControlOrder.Tree_1.Item( ( ControlOrder.Tree_1.Value ) - 1 ) := x1
         ControlOrder.Tree_1.Value                                     := ( ControlOrder.Tree_1.Value - 1 )

         AtualizaArray( x1, x2 )

         IF nFound > 0 .AND. nFound1 > 0
            AtualizaOrderMap( x1, x2 )
         ENDIF
      ENDIF

      ControlOrder.Tree_1.EnableUpdate

   ENDIF

RETURN


*------------------------------------------------------------*
FUNCTION VerifyPos( x2 AS STRING )
*------------------------------------------------------------*
   LOCAL x      AS NUMERIC
   LOCAL cValue AS NUMERIC  //? Invalid Hungarian

   FOR x := 1 TO ControlOrder.Tree_1.ItemCount

       // MsgBox( ControlOrder.Tree_1.Item( x ) )
       IF ControlOrder.Tree_1.Item( x ) = x2
          cValue := x
          x      := ControlOrder.Tree_1.ItemCount
       ENDIF

   NEXT x

RETURN( cValue )


*------------------------------------------------------------*
PROCEDURE DownOrder()
*------------------------------------------------------------*
   local x1       AS USUAL
   LOCAL x2       AS USUAL
   LOCAL nPos1    AS NUMERIC
   LOCAL nPos     AS NUMERIC
   LOCAL nPos2    AS NUMERIC
   LOCAL cName1   AS STRING
   LOCAL nFound   AS NUMERIC
   LOCAL nFound1  AS NUMERIC
   LOCAL nValue   AS NUMERIC

   // MsgBox( 'value= ' + Str( ControlOrder.Tree_1.Value ) )
   IF ControlOrder.Tree_1.Value > 1 .AND. ControlOrder.Tree_1.Value < ControlOrder.Tree_1.ItemCount

      ControlOrder.Tree_1.DisableUpdate

      x1 := ControlOrder.Tree_1.Item( ControlOrder.Tree_1.Value )
      x2 := ControlOrder.Tree_1.Item( ( ControlOrder.Tree_1.Value ) + 1 )
      // MsgBox("x1= "+x1+" x2= "+x2)

      // to jump over page controls
      IF SubStr( x1, 1, 4 ) = "Tab_" .AND. SubStr( x2, 1, 4 ) = "Page"

         nPos1 := xControle( x1 ) + 1
         FOR nPos := nPos1 TO Len( xArray )

             IF Empty( xArray[ nPos, 3 ] )
                nPos := Len( xArray )
             ENDIF

             cName1 := xArray[ nPos, 3 ]
             // MsgBox("cname1= "+cname1 )

             nPos2 := aScan( ArrayOrderTemp, cName1 )

             IF nPos2 = 0

                x2   := cName1
                nPos := Len( xArray )

                // MsgBox( "x2 := " + x2 )

             ENDIF

         NEXT nPos

      ENDIF

      // MsgBox("x1= "+x1+" x2= "+x2)

      // Verify if can move
      IF SubStr( x1, 1, 4 ) = "Page" .OR. SubStr( x2, 1, 4 ) = "Page"
         ControlOrder.Tree_1.EnableUpdate
         RETURN
      ENDIF

      nFound  := aScan2( ArrayOrderTemp, x1 )
      nFound1 := aScan2( ArrayOrderTemp, x2 )

      IF nFound > 0 .AND. nFound1 = 0  .OR. nFound = 0 .AND. nFound1 > 0
         ControlOrder.Tree_1.EnableUpdate
         RETURN
      ENDIF

      **************************************
      IF SubStr( x1, 1, 4 ) = "Tab_" .OR. SubStr( x2, 1, 4 ) = "Tab_"         // x1 or x2  is tab
         AtualizaArray( x1, x2 )

         ControlOrder.Tree_1.DeleteAllitems

         FillTree()

         nValue                    := VerifyPos( x1 )
         ControlOrder.Tree_1.Value := nValue

      ELSE
         ControlOrder.Tree_1.Item( ControlOrder.Tree_1.Value )         := x2
         ControlOrder.Tree_1.Item( ( ControlOrder.Tree_1.Value ) + 1 ) := x1
         ControlOrder.Tree_1.Value                                     := ControlOrder.Tree_1.Value + 1

         AtualizaArray( x1, x2 )

         IF nFound > 0 .AND. nFound1 > 0
            AtualizaOrderMap( x1, x2 )
         ENDIF

      ENDIF

      ControlOrder.Tree_1.EnableUpdate

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE FinalOrder()
*------------------------------------------------------------*
   LOCAL x AS NUMERIC

   ObjectInspector.xCombo_1.DeleteAllitems
   ObjectInspector.xCombo_1.AddItem( "Form" )

   FOR x := 1 TO Len( xArray )
       IF ! Empty( xArray[ x, 3 ] )
          ObjectInspector.xCombo_1.AddItem( xArray[ x, 3 ] )
       ENDIF
   NEXT x

   ObjectInspector.xCombo_1.Value := 1

RETURN


*------------------------------------------------------------*
PROCEDURE AtualizaArray( x1 AS STRING, x2 AS STRING )
*------------------------------------------------------------*
   LOCAL xPos1  AS NUMERIC := xControle( x1 )
   LOCAL xPos2  AS NUMERIC := xControle( x2 )
   LOCAL aTemp1 AS ARRAY   := aClone( xArray[ xPos2 ] )
   LOCAL aTemp2 AS ARRAY   := aClone( xArray[ xPos1 ] )

   xArray[ xPos1 ] := aTemp1
   xArray[ xPos2 ] := aTemp2

   lChanges        := .T.

   // xTest()

RETURN

/*
PROCEDURE xtest()
   LOCAL cText AS STRING  := ""
   LOCAL x     AS NUMERIC

  FORr x := 1 TO Len( xArray )
       IF Empty( xArray[ x, 3 ] )
          x := Len( xArray )
       ELSE
          MsgBox( Str( x ) )
          MsgBox( xArray[ x, 3 ] )
          cText += "item " + Str( x ) + " " + xArray[ x, 3 ] + CRLF
       ENDIF
  NEXT x

  MsgBox( cText )

RETURN
*/

*------------------------------------------------------------*
PROCEDURE AtualizaOrderMap( x1 AS STRING, x2 AS STRING )
*------------------------------------------------------------*
   LOCAL nItemx1    AS NUMERIC
   LOCAL nItemx2    AS NUMERIC
   LOCAL cTab1      AS STRING
   LOCAL cTab2      AS STRING
   LOCAL hx1        AS USUAL
   LOCAL hx2        AS USUAL
   LOCAL nPosTab1   AS NUMERIC
   LOCAL nPosTab2   AS NUMERIC
   LOCAL i          AS NUMERIC
   LOCAL j          AS NUMERIC
   LOCAL k          AS NUMERIC
   LOCAL j1         AS NUMERIC
   LOCAL j2         AS NUMERIC
   LOCAL k1         AS NUMERIC
   LOCAL k2         AS NUMERIC
   LOCAL cValue     AS USUAL

   // MsgBox("savemap")
   nItemx1 := aScan( ArrayOrderTemp, x1 )
   nItemx2 := aScan( ArrayOrderTemp, x2 )  // same of nitemx1

   cTab1   := ArrayOrderTemp1[ nitemx1 ]
   cTab2   := ArrayOrderTemp1[ nitemx2 ]    // same of ctab1

   // MsgBox('ctab1->value= '+ctab1 + ' is = ctab2->value= '+ ctab2)
   hx1     := MyFindHandle( x1 )
   hx2     := MyFindHandle( x2 )

   nPosTab1 := aScan( _hmg_aControlNames, cTab1 )
   nPosTab2 := aScan( _hmg_aControlNames, cTab2 )  // same of npostab1

   // MsgBox("handle-x1= "+str(hx1)+" postab1= "+str(npostab1)+ ' controlname= ' + _hmg_acontrolnames[npostab1] )
   // MsgBox("handle-x2= "+str(hx2)+" postab2= "+str(npostab2)+ ' controlname= ' + _hmg_acontrolnames[npostab2] )

   i := nPosTab1

   FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

       FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )

           cValue := _HMG_aControlPageMap[ i, j, k ]

           IF ValType( cValue ) = 'N'
              // MsgBox(str(cvalue)+" = "+str(hx1) )
              IF ValType( hx1 ) = 'N' .AND. cValue = hx1
                 //  MsgBox( "saving "+ Str( cValue ) + " = " + Str(hx1) )
                 j1 := j
                 k1 := k
              ENDIF

           ELSEIF ValType( cValue ) = 'A' .AND. ValType( hx1 ) = 'A' .AND. cValue[ 1 ] = hx1[ 1 ]
              j1 := j
              k1 := k
         ENDIF

      NEXT k

   NEXT j

   i := nPosTab2   // same of npostab1

   FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

       FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )

           cValue := _HMG_aControlPageMap[ i, j, k ]

           IF ValType( cValue ) = 'N'
              // MsgBox(str(cvalue)+" = "+str(hx2) )
              IF ValType( hx2 ) = 'N' .AND. cValue = hx2
                 // MsgBox("saving "+str(cvalue)+" = "+str(hx2) )
                 j2 := j
                 k2 := k
              ENDIF

           ELSEIF ValType( cValue ) = 'A' .AND. ValType( hx2 ) = 'A' .AND. cValue[ 1 ] = hx2[ 1 ]
              j2 := j
              k2 := k
           ENDIF

       NEXT k

   NEXT j

   _HMG_aControlPageMap[ i, j1, k1 ] := hx2
   _HMG_aControlPageMap[ i, j2, k2 ] := hx1

RETURN


*------------------------------------------------------------*
STATIC FUNCTION MyFindHandle( cValue AS STRING )
*------------------------------------------------------------*
   LOCAL i        AS NUMERIC
   LOCAL RetValue AS NUMERIC := 0

   FOR i := 1 TO Len( _hmg_aControlNames )
       IF _hmg_aControlNames[ i ] == cValue .AND. _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )
          RetValue := _HMG_aControlHandles[ i ]
          EXIT
       ENDIF
   NEXT i

RETURN( RetValue )
