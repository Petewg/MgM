#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW DropDownMenuBuilder
DECLARE WINDOW ContextBuilder

*------------------------------------------------------------*
FUNCTION ChangeArray()
*------------------------------------------------------------*
  LOCAL x      AS NUMERIC
  LOCAL y      AS NUMERIC
  LOCAL xArray AS ARRAY   := {}
  LOCAL A1     AS STRING
  LOCAL lJoin  AS LOGICAL := .F.

  FOR x := 1 TO Len( aDropDown )
      A1 := aDropDown[ x ]

      IF AllTrim( A1 ) # AllTrim( aVLDropDown[ 1 ] )
         // MsgBox( "A1= " + A1 + CRLF + "aVLDropDown= "+avlDropDown[1])
         aAdd( xArray, A1 )
      ELSE
         IF lJoin = .F.
            IF AllTrim( avlDropDown[ 2 ] ) # 'MENUITEM ""'
               FOR y := 1 TO Len( avlDropDown )
                   // MsgBox( "avlDropDown ["+str(y)+"]="+avlDropDown[y] )
                   aAdd( xArray, avlDropDown[ y ] )
               NEXT y
            ENDIF
            lJoin := .T.
         ENDIF

         DO WHILE .T.
            x  := x + 1
            A1 := AllTrim( aDropDown[ x ] )
            // MsgBox( "aDropDown [" + Str( x ) + "]=" + aDropDown[ x ] )
            // aAdd( xArray, A1 )
            IF A1 = "END MENU"
               EXIT
            ENDIF
         ENDDO
      ENDIF
  NEXT X

  IF lJoin = .F.
     IF AllTrim( avlDropDown[2]) # 'MENUITEM ""'
        FOR y := 1 TO Len( avlDropDown )
            // MsgBox("avldropdown ["+str(y)+"]="+avldropdown[y])
            aAdd(xArray,avldropdown[y])
        NEXT y
     ENDIF
     lJoin := .T.
  ENDIF

  /*
  A1 := ""
  FOR X := 1 TO Len( xArray )
      A1 += xArray[X] + CRLF
  NEXT X
  MsgBox( "xArray= " + A1 )
  */

RETURN( xArray )


*------------------------------------------------------------*
FUNCTION FillDropArray()
*------------------------------------------------------------*
  LOCAL aTempArray AS ARRAY   := {}
  LOCAL x          AS NUMERIC
  LOCAL A1         AS STRING
  LOCAL A2         AS NUMERIC
  LOCAL A3         AS NUMERIC
  LOCAL A4         AS STRING
  LOCAL A5         AS STRING
  LOCAL A6         AS NUMERIC
  LOCAL A7         AS NUMERIC


  A1 := ContextBuilder.Title
  A2 := At( "[", A1 )
  A3 := At( "]", A1 )
  A4 := SubStr( A1, A2+1, A3-A2-1 )

  FOR x := 1 TO Len( aDropDown )
      A5 := aDropDown[ x ]
      // MsgBox( "A5= " + A5 )

      A6 := At( "DEFINE DROPDOWN MENU BUTTON", A5 )
      IF A6 > 0
         // MsgBox( "A6 > 0" )
         A7 := At( A4, A5 )
         IF A7 > 0
            aAdd( aTempArray, A5 )
            DO WHILE .T.
               X  := X + 1
               A5 := aDropDown[ x ]

               IF At( "END MENU", A5 ) = 0
                  aAdd( aTempArray, A5 )
               ELSE
                  EXIT
               ENDIF
            ENDDO
         ENDIF
      ENDIF
  NEXT X

  IF Len( aTempArray ) > 0
     aAdd( aTempArray, "END MENU" )
  ENDIF

  ***************************
  // X1 := ""
  // FOR x = 1 TO Len( aTempArray )
  //    X1 += aTempArray[ x ] + CRLF
  // NEXT X
  // MsgBox( " aTempArray = " + X1 )
  *******************

RETURN( aTempArray )


*------------------------------------------------------------*
PROCEDURE DropDownGridClick()
*------------------------------------------------------------*
  LOCAL cItem AS STRING

  // citem := DropDownMenuBuilder.Grid_1.Item(DropDownMenuBuilder.Grid_1.Value)
  cItem := AllTrim( GetColValue( "GRID_1", "DropDownMenuBuilder", 1 ) )

  // MsgBox( "cItem= " + cItem )

  DropDownEdit( " [" + cItem + "]" )

RETURN


*------------------------------------------------------------*
PROCEDURE DropDownInit()
*------------------------------------------------------------*
  ToolbarInit( "DROPDOWN" )

  IF Len( aVLToolbarHash ) > 0  
     LoadavlDropDown()
     DropDownFillGrid()
     DropDownMenuBuilder.Grid_1.Value := 1
  ELSE
     MsgBox( "To make a dropdown menu, first you should to define a toolbar", "Warning" )
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE DropDownFillGrid()
*------------------------------------------------------------*
  LOCAL x      AS NUMERIC
  LOCAL cValue AS USUAL

  DropDownMenuBuilder.Grid_1.DeleteAllitems

  IF Len( aVLDropDown ) > 0

     cValue := "_none"

     FOR x := 1 TO Len( aVLdropdown )
         //  MsgBox( "x= " + Str( x ) + " " +aVLdropdown[ x, 1 ] + " #? " + cValue )
         IF aVLdropdown[ x, 1 ] # cValue
            // MsgBox( aVLdropdown[ x, 1 ] + " # " + cValue )
            DropDownMenuBuilder.Grid_1.AddItem( { aVLdropdown[ x, 1 ] } )
         ENDIF

         cValue := aVLDropDown[ x, 1 ]

      NEXT x

  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE LoadavlDropDown()
*------------------------------------------------------------*
  LOCAL x           AS NUMERIC
  LOCAL A1          AS USUAL     //? VarType
  LOCAL x4          AS NUMERIC
  LOCAL X5          AS NUMERIC
  LOCAL X6          AS NUMERIC
  LOCAL cName       AS STRING
  LOCAL cString     AS STRING
  LOCAL aMenuItens  AS ARRAY
  LOCAL x1          AS NUMERIC

  PUBLIC avlDropDown := {}

  IF Len( aDropDown ) > 0
     FOR x := 1 TO Len( aDropDown )
         // MsgBox("x= "+str(x) )

         A1 := aDropDown[ x ]
         // MsgBox( "A1 = " + A1 )

         CSTRING := 'DEFINE DROPDOWN MENU BUTTON'
         x1      := At( cString, A1 )

         IF X1 > 0
            cName := AllTrim( SubStr( A1, X1 + Len( cString), Len( A1 ) ) )
            // MsgBox("CNAME="+CNAME)

            DO WHILE .T.
               x  := x + 1
               A1 := aDropDown[ x ]
               X4 := At( 'MENUITEM' , A1 )
               X5 := At( 'SEPARATOR', A1 )
               X6 := At( 'END MENU' , A1 )

               IF X4 > 0
                  // MsgBox( "MENUITEM= " + A1 )
                  aMenuItens := MenuItens( A1, X4, "MENUITEM" )

                  aAdd( avlDropDown, { cName, "MENUITEM", aMenuItens[ 1 ],;
                                       aMenuItens[ 2 ], aMenuItens[ 3 ], aMenuItens[ 4 ],;
                                       aMenuItens[ 5 ], aMenuItens[ 6 ], aMenuItens[ 7 ] } )

               ELSEIF X5 > 0
                  // MsgBox( "SEPARATOR= " + A1 )
                  aAdd( avlDropDown, { cName, "SEPARATOR", "-", "", "", "", ".F.", ".F.", "" } )

               ELSEIF X6 > 0
                  // MsgBox( "END MENU= " + A1 )
                  EXIT
               ENDIF
            ENDDO
         ENDIF

     NEXT X

  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE DropDownNew()
*------------------------------------------------------------*
  LOCAL cValue AS STRING := InputBox( "Enter owner toolbar button name:", "New Dropdown Menu", ) //ok Cancel

  IF Len( cValue ) > 0
     DropDownMenuBuilder.Grid_1.AddItem( { cValue } )
     // aAdd( avlDropDown, { cValue, "MENUITEM","","","","",".F.",".F.","","" } )
     // aAdd( ARRAYMENU, { "MENUITEM","","","","",".F.",".F.","" } )
     DropDownMenuBuilder.Grid_1.Value := DropDownMenuBuilder.Grid_1.ItemCount

     lChanges                         := .T.
  ENDIF

  DropDownMenuBuilder.Center

  DropDownMenuBuilder.SetFocus

  *  ***obs change to load values into grid to choose.

RETURN


*------------------------------------------------------------*
PROCEDURE DropDownEdit( cItem AS STRING )
*------------------------------------------------------------*
   IF cItem = NIL
      cItem := " [" + AllTrim( GetColValue( "GRID_1", "DropDownMenuBuilder", 1 ) ) + "]"
   ENDIF

   IF ! _isWindowDefined( "ContextBuilder" )
      LOAD WINDOW ContextBuilder
   ENDIF

   ContextBuilder.Title := "Dropdown Menu Builder" + cItem
   CENTER WINDOW ContextBuilder
   ACTIVATE WINDOW ContextBuilder

RETURN


*------------------------------------------------------------*
PROCEDURE DropDownDelete()
*------------------------------------------------------------*
  LOCAL tValue       AS NUMERIC
  LOCAL TempDropDown AS ARRAY   := {}
  LOCAL lResp        AS LOGICAL
  LOCAL x            AS NUMERIC
  LOCAL cValue1      AS USUAL            //? VarType

  IF aData[ _DISABLEWARNINGS ] = ".F."
     lResp := MsgOkCancel( "Are you sure?" )
  ELSE
     lResp := .T.
  ENDIF

  IF lResp

     IF DropDownMenuBuilder.Grid_1.ItemCount > 0
        cValue1 := GetColValue( "GRID_1", "DropDownMenuBuilder", 1 )
        // MsgBox("LEN="+STR(Len(avldropdown)))

        FOR x := 1 TO Len( avlDropDown )
            // MsgBox( "X= " + Str(X)+ " AVLDROPDOWN= " + avlDropDown[x,1] + " cValue1= "+ cValue1 )

            IF avldropdown[x,1] = cValue1
               // MsgBox( "DELETE " + avlDropDown[x,1] + " " + avldropdown[x,2] + " " + avldropdown[x,3] )
               aDel( avlDropDown, x )
               aSize( avlDropDown, Len( avlDropDown ) - 1 )
               x := x - 1
            ENDIF

        NEXT x
        // MsgBox("LEN=" + Str( Len( avlDropDown ) ) )

        FOR x := 1 TO Len( aDropDown )
            IF aDropDown[x] #  "DEFINE DROPDOWN MENU BUTTON " + cValue1
               aAdd( TempDropDown, aDropDown[x] )
            ELSE
               DO WHILE .T.
                  x := x + 1
                  IF aDropDown[x] = "END MENU"
                     EXIT
                  ENDIF
               ENDDO
            ENDIF
        NEXT X

        lChanges := .T.
        tValue   := DropDownMenuBuilder.Grid_1.Value

        DropDownFillGrid()

        DropDownMenuBuilder.Grid_1.Value := tValue - iif( tValue > 1, 1, 0 )
     ENDIF
  ENDIF
RETURN


*------------------------------------------------------------*
PROCEDURE DropDownName()
*------------------------------------------------------------*
  LOCAL cValue   AS STRING
  LOCAL cValue1  AS STRING
  LOCAL x        AS NUMERIC

  ****dont be used
  cValue := InputBox( "Enter owner toolbar button name:", "Dropdown Menu Owner Toolbar Button Name", ) //ok Cancel

  IF ! Empty( cValue )

     cValue1 := GetColValue( "GRID_1", "DropDownMenuBuilder", 1 )

      SetColValue( "GRID_1", "DropDownMenuBuilder", 1, cValue )

      FOR x := 1 TO Len( avlDropDown )
          IF avldropdown[ x, 1 ] = cValue1
             avldropdown[ x, 1 ] := cValue
          ENDIF
      NEXT x

      FOR x := 1 TO Len( aDropDown )
          IF aDropDown[x] = "DEFINE DROPDOWN MENU BUTTON " + cValue1
             aDropDown[x] = "DEFINE DROPDOWN MENU BUTTON " + cValue
          ENDIF
      NEXT x

     lChanges := .T.

   ENDIF

   DropDownMenuBuilder.Center
   DropDownMenuBuilder.SetFocus

RETURN


*------------------------------------------------------------*
PROCEDURE DropDownClose()
*------------------------------------------------------------*
  RELEASE WINDOW DropDownMenuBuilder
RETURN


*------------------------------------------------------------*
PROCEDURE BeautDrop()
*------------------------------------------------------------*
  LOCAL aTemp AS ARRAY   := {}
  LOCAL x     AS NUMERIC

  IF Len( aDropDown ) > 0
     aAdd( aTemp, Space( 5 ) + AllTrim( aDropDown[ 1 ] ) )
     FOR x := 2 TO Len( aDropDown )
         aDropDown[ x ] := AllTrim( aDropdown[x] )
         // MsgBox( "line= " + aDropDown[x] )

         IF At( "DEFINE DROPDOWN", aDropDown[x] ) = 1
            //  MsgBox( "added line space+ define dropdown" )
            aAdd( aTemp, "" )
            aAdd( aTemp, Space( 5 ) + aDropDown[x] )
         ENDIF

         IF At( "MENUITEM", aDropDown[x] ) = 1
            // MsgBox( "added menuitem" )
            aAdd( aTemp, Space( 12 ) + aDropDown[x] )
         ENDIF

         IF At( "END MENU", aDropDown[x] ) = 1
            // MsgBox( "added end menu" )
            aAdd( aTemp, Space( 5 ) + aDropDown[x] )
         ENDIF
     NEXT x

  ENDIF

  aDropDown := aTemp

RETURN