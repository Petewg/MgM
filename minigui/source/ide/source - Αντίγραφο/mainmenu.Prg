#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW MenuBuilder

MEMVAR ACTION

*------------------------------------------------------------*
PROCEDURE InitMenuBuilder()
*------------------------------------------------------------*
   PUBLIC lAction AS LOGICAL := .F.

   MenuToMem()

   IF Len( ArrayMenu ) = 0
      aAdd( ArrayMenu, { "POPUP", 0, "INITMENU", "NIL", "NIL", "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" } )
   ENDIF

   MenuFillGrid()

   MenuBuilder.Grid_2.Value := 1
   MenuBuilder.Text_1.Value := ArrayMenu[ MenuBuilder.Grid_2.Value, 3 ]

   lAction := .T.

RETURN


*------------------------------------------------------------*
PROCEDURE MenuToMem()
*------------------------------------------------------------*
   LOCAL  Level      AS NUMERIC  := 0
   LOCAL  First      AS LOGICAL  := .F.
   LOCAL  xLin       AS NUMERIC
   LOCAL  lTrue      AS LOGICAL
   LOCAL  A1         AS STRING
   LOCAL  X4         AS NUMERIC
   LOCAL  Caption    AS STRING
   LOCAL  xName      AS NUMERIC  //? Invalid Hungarian
   LOCAL  cCaption   AS STRING
   LOCAL  cName      AS STRING
   LOCAL  aMenuItens AS ARRAY

   PUBLIC ArrayMenu  AS ARRAY   := {}


   FOR xLin := 1 TO Len( aMenu )
      lTrue := .T.
      DO WHILE lTrue
         xLin := xLin + 1
         A1   := aMenu[ xLin ]

         // MsgBox( "A1= " + A1 )
         ********************************************
         X4 := At( "DEFINE POPUP", Upper( A1 ) )

         IF X4 > 0

            Caption := SubStr( AllTrim( A1 ), 14, Len( A1 ) )
            xName   := At( "NAME", Caption )

            IF xName > 0
               cCaption := SubStr( Caption, 1, xName-1 )
               cName    := SubStr( Caption, xName+4, Len( Caption ) )
               cName    := AllTrim( cName )
               Caption  := AllTrim( cCaption )
               // MsgBox( 'CAPTION= ' + CAPTION + ' NAME= ' + cName )
            ELSE
               cName := "NIL"
            ENDIF

            Caption := SubStr( Caption, 2, Len( Caption ) - 2 )

            IF ! First
               * first := .T.
               aAdd( ArrayMenu, { "POPUP", level, Caption, "NIL", cName, "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" } )
               Level++
            ELSE
               level++
               aAdd( ArrayMenu, { "POPUP", level, Caption, "NIL", cName, "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" } )
            ENDIF

            LOOP

         ENDIF

         ********************************************
         X4 := At( "MENUITEM", Upper( A1 ) )

         IF X4 > 0
            aMenuItens := MenuItens( A1, x4, "item" )
            aAdd( ArrayMenu, { "ITEM", Level, aMenuItens[1], aMenuItens[2], aMenuItens[3], aMenuItens[4], ;
                  aMenuItens[5], aMenuItens[6], aMenuItens[7], aMenuItens[8], aMenuItens[9] } )
            LOOP
         ENDIF

         ********************************************
         X4 := At( "SEPARATOR", Upper( A1 ) )
         IF X4 > 0
            aAdd( ArrayMenu, { "SEPARATOR", Level, "SEPARATOR", "NIL", "NIL", "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" } )  // ou "-"
            LOOP
         ENDIF

         ********************************************
         X4 := At( "END POPUP", Upper( A1 ) )
         IF X4 > 0
            Level --
            IF Level = 0
               First := .F.
            ENDIF
            LOOP
         ENDIF

         ********************************************
         X4 := At( "END MENU", Upper( A1 ) )
         IF X4 > 0
            lTrue := .F.
            LOOP
         ENDIF

      ENDDO

   NEXT xLin

   /* TO DEBUG ONLY
   CTEXTO := ""
   FOR X = 1 TO Len( ArrayMenu )
      CTEXTO += ArrayMenu[X,1] + " " + Str( ArrayMenu[X,2] ) + " " + ArrayMenu[X,3] + " " + ArrayMenu[X,4] + " " + ArrayMenu[X,5] + " " + ;
         ArrayMenu[X,6] + " " + ArrayMenu[X,7] + " " + ArrayMenu[X,8] + " " + ArrayMenu[X,9] + " " + ArrayMenu[X,10] + " " + ArrayMenu[X,11] + CRLF
   NEXT X
   MsgBox( cTexto, "ITENS OF MENU" )
   */

RETURN


*------------------------------------------------------------*
PROCEDURE MenuFillGrid()
*------------------------------------------------------------*
   LOCAL x      AS NUMERIC
   LOCAL xValue AS STRING

   MenuBuilder.Grid_2.DeleteAllitems

   FOR x := 1 TO Len( ArrayMenu )
       // MsgBox('item= '+ str(x) + ' level= '+str( ArrayMenu[x,2] ) )

       IF ArrayMenu[ x, 2 ] > 0
          xValue := Replicate( "....", ArrayMenu[ x, 2 ] ) + ArrayMenu[ x, 3 ]
       ELSE
          xValue := ArrayMenu[ x, 3 ]
       ENDIF

       MenuBuilder.Grid_2.AddItem( { xValue, ArrayMenu[ x, 1 ], Str( ArrayMenu[ x, 2 ] ) } )

   NEXT x

RETURN


*------------------------------------------------------------*
FUNCTION XSpace( Y )
*------------------------------------------------------------*
   LOCAL cVal AS STRING

   IF ArrayMenu[ Y, 2 ] > 0
      cVal := Space( ( ArrayMenu[ Y, 2 ] * 5 ) + 10 )
   ELSE
      cVal := Space( 10 )
   ENDIF

RETURN( cVal )


*------------------------------------------------------------*
PROCEDURE CaptionChange()
*------------------------------------------------------------*
   LOCAL x       AS NUMERIC
   LOCAL xValue  AS STRING

   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   IF lAction
      // MsgBox( "CAPTION CHANGE" )

      MenuBuilder.Grid_2.Item( MenuBuilder.Grid_2.Value ) := { MenuBuilder.Text_1.Value }
      ArrayMenu[ MenuBuilder.Grid_2.Value,3 ]             := MenuBuilder.Text_1.Value
      x                                                   := MenuBuilder.Grid_2.Value

      IF ArrayMenu[ x, 2 ] > 0
         xValue := Replicate( "....", ArrayMenu[ x, 2 ] ) + ArrayMenu[ x, 3 ]
      ELSE
         xValue := ArrayMenu[ x, 3 ]
      ENDIF

      MenuBuilder.Grid_2.Item( MenuBuilder.Grid_2.Value ) := { xValue }
   ENDIF
RETURN


*------------------------------------------------------------*
PROCEDURE ActionChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   IF lAction
      // MsgBox( "ACTION CHANGE" )
      IF ArrayMenu[MenuBuilder.Grid_2.Value,1 ] = "ITEM"
         ArrayMenu[MenuBuilder.Grid_2.Value,4 ] := MenuBuilder.Text_2.Value
      ENDIF
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE NameChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   IF lAction
      IF ArrayMenu[MenuBuilder.Grid_2.Value,1] = "ITEM"
         ArrayMenu[MenuBuilder.Grid_2.Value,5] := MenuBuilder.Text_3.Value
      ENDIF
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ImageChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   IF lAction
      IF ArrayMenu[MenuBuilder.Grid_2.Value,1] = "ITEM"
         ArrayMenu[MenuBuilder.Grid_2.Value,6] := MenuBuilder.Text_4.Value
      ENDIF
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE CheckMarkChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   IF lAction
      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] = "ITEM"
         ArrayMenu[ MenuBuilder.Grid_2.Value, 7 ] := MenuBuilder.Text_5.Value
      ENDIF
   ENDIF
RETURN


*------------------------------------------------------------*
PROCEDURE FontChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
     RETURN
   ENDIF

   IF lAction
      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] = "ITEM"
         ArrayMenu[ MenuBuilder.Grid_2.Value, 8 ] := MenuBuilder.Text_6.Value
      ENDIF
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE CheckedChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
     RETURN
   ENDIF

   IF lAction
      IF ArrayMenu[ MenuBuilder.Grid_2.Value,1 ] = "ITEM"
         //IF MenuBuilder.Check_1.Value = .F.
         //   ArrayMenu[ MenuBuilder.Grid_2.Value, 9 ] := ".F."
         //ELSE
         //   ArrayMenu[ MenuBuilder.Grid_2.Value, 9 ] := ".T."
         //ENDIF
         ArrayMenu[ MenuBuilder.Grid_2.Value, 9 ] := xToc( MenuBuilder.Check_1.Value )
      ENDIF
   ENDIF
RETURN


*------------------------------------------------------------*
PROCEDURE DisabledChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   IF lAction
      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] = "ITEM"
         //IF MenuBuilder.CHECK_2.Value = .F.
         //   ArrayMenu[ MenuBuilder.Grid_2.Value, 10 ] := ".F."
         //ELSE
         //   ArrayMenu[ MenuBuilder.Grid_2.Value, 10 ] := ".T."
         //ENDIF
         ArrayMenu[ MenuBuilder.Grid_2.Value, 10 ] := xToc( MenuBuilder.CHECK_2.Value )
      ENDIF
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE MessageChange()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   IF lAction
      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] = "ITEM"
         ArrayMenu[ MenuBuilder.Grid_2.Value, 11 ] := MenuBuilder.Text_7.Value
      ENDIF
   ENDIF
RETURN

*------------------------------------------------------------*
PROCEDURE UpLevel()
*------------------------------------------------------------*
   LOCAL tValue

   IF MenuBuilder.Grid_2.Value > 1

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ] <= ArrayMenu[ (MenuBuilder.Grid_2.Value) - 1, 2 ]
         tValue := MenuBuilder.Grid_2.Value

         // MsgBox('anterior = '+ArrayMenu[(MenuBuilder.Grid_2.Value)-1,1]+ ' level = '+str(ArrayMenu[(MenuBuilder.Grid_2.Value)-1,2]))
         // MsgBox('atual = '+ArrayMenu[MenuBuilder.Grid_2.Value,1]+ ' level = '+str(ArrayMenu[MenuBuilder.Grid_2.Value,2]))
         // MsgBox('proximo= '+ArrayMenu[(MenuBuilder.Grid_2.Value)+1,1]+ ' level = '+str(ArrayMenu[(MenuBuilder.Grid_2.Value)+1,2]))

         ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ] := ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ] + 1
         ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] := 'POPUP'

         // MsgBox('anterior = '+ArrayMenu[(MenuBuilder.Grid_2.Value)-1,1]+ ' level = '+str(ArrayMenu[(MenuBuilder.Grid_2.Value)-1,2]))
         // MsgBox('atual = '+ArrayMenu[MenuBuilder.Grid_2.Value,1]+ ' level = '+str(ArrayMenu[MenuBuilder.Grid_2.Value,2]))
         // MsgBox('proximo= '+ArrayMenu[(MenuBuilder.Grid_2.Value)+1,1]+ ' level = '+str(ArrayMenu[(MenuBuilder.Grid_2.Value)+1,2]))

         MenuFillGrid()

         MenuBuilder.Grid_2.Value := tValue
      ENDIF
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE DownLevel()
*------------------------------------------------------------*
   LOCAL tValue AS USUAL  //? VarType

   IF MenuBuilder.Grid_2.Value = 0
     RETURN
   ENDIF

   tValue := MenuBuilder.Grid_2.Value

   IF ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ] > 0

      ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ] := ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ] - 1

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ] = 0
         ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] := 'POPUP'
      ENDIF

      MenuFillGrid()

      MenuBuilder.Grid_2.Value := tValue

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE GridChange()
*------------------------------------------------------------*
   * CHECKMENU()

   IF MenuBuilder.Grid_2.Value = 0
     RETURN
   ENDIF

   lAction := .F.

   CleanForm()

   MenuBuilder.Text_1.Value    :=  ArrayMenu[ MenuBuilder.Grid_2.Value, 3 ]     // CAPTION

   IF ArrayMenu[ MenuBuilder.Grid_2.Value, 5 ] # "NIL"
      MenuBuilder.Text_3.Value := ArrayMenu[ MenuBuilder.Grid_2.Value, 5 ]      // NAME
   ENDIF

   IF ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] = "ITEM"

      MenuBuilder.Text_2.Value := ArrayMenu[ MenuBuilder.Grid_2.Value, 4 ]      // ACTION

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 6 ] # "NIL"
         MenuBuilder.Text_4.Value := ArrayMenu[ MenuBuilder.Grid_2.Value, 6 ]   // IMAGE
      ENDIF

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 7 ] # "NIL"
         MenuBuilder.Text_5.Value := ArrayMenu[ MenuBuilder.Grid_2.Value, 7 ]   // CHECKMARK
      ENDIF

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 8 ] # "NIL"
         MenuBuilder.Text_6.Value := ArrayMenu[ MenuBuilder.Grid_2.Value, 8 ]   // FONT
      ENDIF

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 9 ] = ".T."                       // CHECKED
         MenuBuilder.Check_1.Value := .T.
      ENDIF

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 10 ] =  ".T."                     // DISABLED
         MenuBuilder.Check_2.Value := .T.
      ENDIF

      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 11 ] # "NIL"                      // MESSAGE
         MenuBuilder.Text_7.Value := ArrayMenu[ MenuBuilder.Grid_2.Value, 11 ]
      ENDIF

   ENDIF

   lAction := .T.

RETURN


*------------------------------------------------------------*
PROCEDURE CleanForm()
*------------------------------------------------------------*
   MenuBuilder.Text_1.Value  := ""
   MenuBuilder.Text_2.Value  := ""
   MenuBuilder.Text_3.Value  := ""
   MenuBuilder.Text_4.Value  := ""
   MenuBuilder.Text_5.Value  := ""
   MenuBuilder.Text_6.Value  := ""
   MenuBuilder.Text_7.Value  := ""
   MenuBuilder.Check_1.Value := .F.
   MenuBuilder.Check_2.Value := .F.
RETURN


*------------------------------------------------------------*
PROCEDURE MenuDelete()
*------------------------------------------------------------*
   LOCAL tValue AS NUMERIC

   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   * FIRST ITEM CAN'T BE DELETED
   IF MenuBuilder.Grid_2.Value = 1
      RETURN
   ENDIF

   * POPUP WITH ITEM CAN'T BE DELETED
   IF MenuBuilder.Grid_2.Value < Len( ArrayMenu )
      IF ArrayMenu[ MenuBuilder.Grid_2.Value, 1 ] = "POPUP" .AND. ArrayMenu[ ( MenuBuilder.Grid_2.Value ) + 1, 1 ] = "ITEM"
         RETURN
      ENDIF
   ENDIF

   aDel( ArrayMenu, MenuBuilder.Grid_2.Value )
   aSize( ArrayMenu, Len( ArrayMenu ) - 1 )

   tValue := MenuBuilder.Grid_2.Value

   MenuFillGrid()

   IF tValue > 1
      MenuBuilder.Grid_2.Value := tValue - 1
   ELSE
      MenuBuilder.Grid_2.Value := tValue
   ENDIF

   GridChange()

RETURN


*------------------------------------------------------------*
PROCEDURE UpMenu()
*------------------------------------------------------------*
   LOCAL tValue    AS NUMERIC
   LOCAL TempMenu  AS USUAL      //? VarType

   IF MenuBuilder.Grid_2.VALUE > 1

      tValue                                  := MenuBuilder.Grid_2.Value
      TempMenu                                := ArrayMenu[ MenuBuilder.Grid_2.Value     ]
      ArrayMenu[ MenuBuilder.Grid_2.Value ]   := ArrayMenu[ MenuBuilder.Grid_2.Value - 1 ]
      ArrayMenu[ MenuBuilder.Grid_2.Value-1 ] := TempMenu

      MenuFillGrid()

      MenuBuilder.Grid_2.Value := tValue - 1

      GridChange()

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE DownMenu()
*------------------------------------------------------------*
  LOCAL tValue   AS NUMERIC
  LOCAL TempMenu AS USUAL   //? VarType

  IF MenuBuilder.Grid_2.Value = 0
     RETURN
   ENDIF

   IF MenuBuilder.Grid_2.Value <  MenuBuilder.Grid_2.ItemCount

      TempMenu                                := ArrayMenu[ MenuBuilder.Grid_2.Value     ]
      ArrayMenu[ MenuBuilder.Grid_2.Value]    := ArrayMenu[ MenuBuilder.Grid_2.Value + 1 ]
      ArrayMenu[ MenuBuilder.Grid_2.Value+1 ] := TempMenu
      tValue                                  := MenuBuilder.Grid_2.Value

      MenuFillGrid()

      MenuBuilder.Grid_2.Value := tValue + 1

      GridChange()

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE MenuInsert()
*------------------------------------------------------------*
   LOCAL Level  AS NUMERIC
   LOCAL cItem  AS STRING
   LOCAL xValue AS ARRAY
   LOCAL tValue AS USUAL   //? VarType

   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   LEVEL  := ArrayMenu[ MenuBuilder.Grid_2.Value, 2 ]
   cItem  := iif( Level = 0, 'POPUP', 'ITEM' )
   xValue := { cItem, Level, "", "NIL", "NIL", "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" }

   aSize( ArrayMenu, Len( ArrayMenu ) + 1 )
   aIns( ArrayMenu, MenuBuilder.Grid_2.Value )

   ArrayMenu[ MenuBuilder.Grid_2.Value] := xValue

   tValue := MenuBuilder.Grid_2.Value

   MenuFillGrid()

   MenuBuilder.Grid_2.Value := tValue

   GridChange()

RETURN


*------------------------------------------------------------*
PROCEDURE NextMenu()
*------------------------------------------------------------*
   LOCAL cValue  AS STRING
   LOCAL X       AS NUMERIC
   LOCAL Level   AS NUMERIC
   LOCAL xValue  AS USUAL    //? VarType

   IF MenuBuilder.Grid_2.Value < MenuBuilder.Grid_2.ItemCount
      MenuBuilder.Grid_2.Value := MenuBuilder.Grid_2.Value + 1
   ELSE
      Level := ArrayMenu[ MenuBuilder.Grid_2.Value,2]

      IF Level = 0
         cValue := 'POPUP'
      ELSE
         cValue := 'ITEM'
      ENDIF

      xValue := { cValue, Level, "", "NIL", "NIL", "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" }
      aAdd( ArrayMenu, xValue )

      x      := Len( ArrayMenu )
      xValue := ArrayMenu[ x, 3 ]

      MenuBuilder.Grid_2.AddItem( { xValue, ArrayMenu[x,1], Str( ArrayMenu[x,2] ) } )
      MenuBuilder.Grid_2.Value := MenuBuilder.Grid_2.Value + 1
   ENDIF

   GridChange()

RETURN


*------------------------------------------------------------*
PROCEDURE PriorMenu()
*------------------------------------------------------------*
   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   MenuBuilder.Grid_2.Value := MenuBuilder.Grid_2.Value - 1

   GridChange()
RETURN


*------------------------------------------------------------*
PROCEDURE MenuChangeType()
*------------------------------------------------------------*
   LOCAL OldType AS STRING
   LOCAL nPos    AS NUMERIC

   IF MenuBuilder.Grid_2.Value = 0
      RETURN
   ENDIF

   nPos := MenuBuilder.Grid_2.Value

   IF nPos > 1

      OldType := ArrayMenu[ nPos, 1 ]

      IF OldType = 'ITEM'
         ArrayMenu[ nPos, 1 ] := 'POPUP'

      ELSEIF OldType = 'POPUP'
         ArrayMenu[ nPos, 1 ] := 'SEPARATOR'
         ArrayMenu[ nPos, 3 ] := 'SEPARATOR'

      ELSEIF OldType = 'SEPARATOR'
         ArrayMenu[ nPos,1 ] := 'ITEM'
         ArrayMenu[ nPos,3 ] := ""
      ENDIF

      IF nPos = 2
         IF ArrayMenu[ nPos, 1 ] = 'ITEM' .OR. ArrayMenu[ nPos, 1 ] = 'SEPARATOR'
            ArrayMenu[ nPos, 2 ] := 1
         ENDIF
      ENDIF

      MenuFillGrid()

      MenuBuilder.Grid_2.Value := nPos

      //MOSTRaMenu() //TO DEBUG
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE MOSTRaMenu()  // TO DEBUG
*------------------------------------------------------------*
   LOCAL A  AS STRING  := ""
   LOCAL x  AS NUMERIC

   FOR x := 1 TO Len( ArrayMenu )
       A += ArrayMenu[ x, 1 ] + " " + Str( ArrayMenu[ x, 2 ] ) + " " + ArrayMenu[ x, 3 ] + " " + ArrayMenu[ x, 4 ] + " " + CRLF
       // MsgBox( ArrayMenu[X,1], Str( x ) )
       // MsgBox( ArrayMenu[X,2], Str( x ) )
   NEXT X

   MsgBox( A )

RETURN


*------------------------------------------------------------*
PROCEDURE MenuBuilderOk()
*------------------------------------------------------------*
   xCreateMenu2()
   MenuBuilder.Release
RETURN


*------------------------------------------------------------*
PROCEDURE xCreateMenu2( PARAM )
*------------------------------------------------------------*
   LOCAL X           AS NUMERIC
   LOCAL NAME        AS USUAL   := NIL //? VarType
   LOCAL IMAGE       AS USUAL   := NIL //? VarType
   LOCAL CHECKED     AS USUAL   := NIL //? VarType
   LOCAL DISABLED    AS USUAL   := NIL //? VarType
   LOCAL CMESSAGES   AS USUAL   := NIL //? VarType
   LOCAL CHECKMARK   AS USUAL   := NIL //? VarType
   LOCAL FONT        AS USUAL   := NIL //? VarType
   LOCAL LEVEL       AS NUMERIC := 0
   LOCAL aPopOpen    AS ARRAY
   LOCAL MenuPopOpen AS NUMERIC := 0
   LOCAL Caption     AS STRING
   LOCAL TypeMenu    AS STRING
   LOCAL LevelMenu   AS NUMERIC
   LOCAL Saida       AS LOGICAL
   LOCAL Value       AS STRING

   PRIVATE ACTION

   aMenu := {}
   aAdd( aMenu, Space( 5 ) + "DEFINE MAIN MENU" )

   aPopOpen := Array( 256 )
   aFill( aPopOpen, 0 )

   _DefineMainMenu( "Form_1" )   // to change to FORM_1 in hmgs-ide

   // MsgBox( 'len of ArrayMenu  = ' + Str( Len( ArrayMenu ) ) )
   FOR x := 1 TO Len( ArrayMenu )

       // MsgBox('x= ' + Str( x ) + ' Len= ' + Str( Len( ArrayMenu ))+ ' value = '+ArrayMenu[ x, 3 ] + ' tipo= ' + ArrayMenu[ x, 1 ] )

       Caption   := ArrayMenu[ x, 3 ]
       TypeMenu  := ArrayMenu[ x, 1 ]
       LevelMenu := ArrayMenu[ x, 2 ]

       IF x = 1

          _DefineMenuPopup( Caption, Name )

          IF ArrayMenu[ x, 5 ] == "NIL"
             aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' )
          ELSE
             aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' + " NAME " + ArrayMenu[ x, 5 ] )
          ENDIF

          MenuPopOpen ++
          aPopOpen[ Level + 1 ] ++
       ELSE
          IF TypeMenu = "POPUP"

             IF LevelMenu = Level

                ***************
                IF aPopOpen[ Level+1 ] > 0

                   _EndMenuPopUp()

                   aAdd( aMenu, iif( Level > 0, Space(((level+1)*5)+5), Space(10)) + "END POPUP " )
                   MenuPopOpen--
                   aPopOpen[level+1] --
                ENDIF

                **********
                _DefineMenuPopUp( Caption, Name )

                IF ArrayMenu[ x, 5 ] = "NIL"
                   aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' )
                ELSE
                   aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' + " NAME "+ ArrayMenu[ x, 5 ] )
                ENDIF

                MenuPopOpen++
                aPopOpen[level+1]++

             ELSEIF LevelMenu > Level
                _DefineMenuPopUp( Caption, Name )

                IF ArrayMenu[ x, 5 ] = "NIL"
                   aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' )
                ELSE
                   aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' + " NAME "+ ArrayMenu[ x, 5 ] )
                ENDIF

                MenuPopOpen++
                Level++
                aPopOpen[level+1]++

             ELSEIF LevelMenu < Level
                SAIDA := .F.
                DO WHILE .T.
                   IF aPopOpen[ level+1 ] > 0
                      _ENDMENUPOPUP()
                      aAdd( aMenu, iif( level > 0, Space(((level+1)*5)+5), Space( 10 ) ) + "END POPUP " )
                      MenuPopOpen --
                      aPopOpen[ Level+1 ] --
                      IF aPopOpen[ Level+1 ] > 0
                         LOOP
                      ENDIF
                      IF SAIDA
                         EXIT
                      ENDIF
                   ELSE
                      IF SAIDA
                         EXIT
                      ENDIF
                      IF LevelMenu = Level
                         SAIDA := .T.
                         LOOP
                      ENDIF
                      LEVEL --
                   ENDIF
                ENDDO

                _DefineMenuPopUp( Caption, Name )

                IF ArrayMenu[ x, 5 ] = "NIL"
                   aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' )
                ELSE
                   aAdd( aMenu, XSpace( x ) + "DEFINE POPUP " + '"' + ArrayMenu[ x, 3 ] + '"' + " NAME " + ArrayMenu[ x, 5 ] )
                ENDIF

                MenuPopOpen++
                aPopOpen[ Level+1 ] ++
             ENDIF

          ENDIF

          IF TypeMenu = "ITEM"

             // MsgBox("ITEM pos= " + STR(X)+ " "+ ArrayMenu[X,3])
             // MsgBox("X " + ArrayMenu[X,1] +" X")

             Action    := "{|| MsgInfo('Action Clicked')}"
             Action    := &Action

             Name      := ArrayMenu[ x, 5 ]
             // MsgBox( NAME )

             Image     := ArrayMenu[ x, 6 ]
             // MsgBox( IMAGE )

             Checkmark := ArrayMenu[ x, 7 ]
             // MsgBox( CHECKMARK )

             Font      := ArrayMenu[ x, 8 ]
             // MsgBox( FONT )

             Checked   := AllTrim( ArrayMenu[ x,  9 ] ) == ".T."
             // MsgBox('value= '+ArrayMenu[X,9])
             // MsgBox( ValType( Checked ) )

             Disabled  := AllTrim( ArrayMenu[ x, 10 ] ) == ".T."
             // MsgBox( 'value= ' + ArrayMenu[ x, 10 ] )
             // MsgBox( ValType( Disabled ) )

             cMessages := ArrayMenu[ x, 11 ]
             // MsgBox( cMessages )

             *********************
             Value := "MENUITEM " + '"' + ArrayMenu[ x, 3 ] + '"'

             IF Len( AllTrim( ArrayMenu[ x, 4 ] ) ) > 0
                Value += " ACTION " +  AllTrim( ArrayMenu[ x, 4 ] )
             ENDIF

             IF Len( AllTrim( ArrayMenu[ x, 5 ] ) ) > 0 .AND. Upper( AllTrim( ArrayMenu[ x, 5 ] ) ) # "NIL"
                Value += " NAME " +  AllTrim( ArrayMenu[ x, 5 ] )
             ENDIF

             IF Len( AllTrim( ArrayMenu[ x, 6 ] ) ) > 0 .AND. Upper( AllTrim( ArrayMenu[ x, 6 ] ) ) # "NIL"
                Value += " IMAGE " + '"' + AllTrim( ArrayMenu[ x, 6 ] ) + '"'
             ENDIF

             IF Len( AllTrim( ArrayMenu[ x, 7 ] ) ) > 0 .AND. Upper( AllTrim( ArrayMenu[ x, 7 ] ) ) # "NIL"
                Value += " CHECKMARK " + '"' + AllTrim( ArrayMenu[ x, 7 ] ) + '"'
             ENDIF

             IF Len( AllTrim( ArrayMenu[ x, 8 ] ) ) > 0 .AND. Upper( AllTrim( ArrayMenu[ x, 8 ] ) ) # "NIL"
                Value += " FONT " + '"' + AllTrim( ArrayMenu[ x, 8 ] ) + '"'
             ENDIF

             IF ArrayMenu[ x, 9 ] == ".T."
                Value += " CHECKED"
             ENDIF

             IF ArrayMenu[ x, 10 ] == ".T."
                Value += " DISABLED"
             ENDIF

             IF Len( AllTrim( ArrayMenu[ x, 11 ] ) ) > 0 .AND. Upper( AllTrim( ArrayMenu[ x, 11 ] ) ) # "NIL"
                Value += " MESSAGE " + '"' + AllTrim( ArrayMenu[ x, 11 ] ) + '"'
             ENDIF

             *****************************************
             IF LevelMenu = Level
                IF ArrayMenu[ x-1, 1 ] = 'POPUP' .AND. ArrayMenu[ x-1, 2 ] = Level
                   aPopOpen[ Level+1 ] --

                   _EndMenuPopUp()

                   //aAdd( aMenu, XSpace( X ) + "END POPUP " )
                   aAdd( aMenu, iif( Level > 0, Space(((Level+1)*5)+5), Space( 10 ) ) + "END POPUP " )
                   MenuPopOpen --
                ENDIF

             ELSEIF  LevelMenu > Level
                level ++

             ELSEIF LevelMenu < Level
                SAIDA := .F.
                DO WHILE .T.
                   IF aPopOpen[ Level+1 ] > 0

                      _EndMenuPopUp()

                      aAdd( aMenu, iif( Level > 0, Space(((Level+1)*5)+5), Space( 10 ) ) + "END POPUP " )
                      MenuPopOpen --
                      aPopOpen[ Level+1 ] --

                      IF aPopOpen[ Level+1 ] > 0
                         LOOP
                      ENDIF

                      IF SAIDA
                         EXIT
                      ENDIF
                   ELSE
                      IF SAIDA
                         EXIT
                      ENDIF

                      IF Level = LevelMenu
                         SAIDA := .T.
                         LOOP
                      ENDIF
                      LEVEL --
                   ENDIF
                ENDDO
             ENDIF

             _DefineMenuItem( Caption, Action, Name, Image, Checked, Disabled, CMessages, Font, Checkmark )
             aAdd( aMenu, XSpace( X ) + VALUE )
          ENDIF

          IF TypeMenu = "SEPARATOR"
             _DefineSeparator()
             aAdd( aMenu, XSpace( x ) + "SEPARATOR " )
          ENDIF
       ENDIF

   NEXT X

   DO WHILE .T.
      IF MenuPopOpen > 0

         _ENDMENUPOPUP()

         IF MenuPopOpen > 1
            aAdd( aMenu, iif( Level > 0, Space(((Level+1)*5)+5), Space( 10 ) ) + "END POPUP " )
            LEVEL --
         ELSE
            aAdd( aMenu, Space(10) + "END POPUP " )
         ENDIF
         MenuPopOpen --
      ELSE
         EXIT
      ENDIF
   ENDDO

   _ENDMENU()

   aAdd( aMenu, Space( 5 ) + "END MENU" )

   /* TEST
   A := ""
   FOR Y = 1 TO Len( aMenu )
       A += aMenu[Y]+CRLF
   NEXT Y
   MsgBox(A,"menu-FINAL")
   */
   //MOSTRaMenu() //TO DEBUG

RETURN

/*
*------------------------------------------------------------*
PROCEDURE CheckMenu()
*------------------------------------------------------------*
   LOCAL X
   level := 0
   FOR X = 1 TO Len( ArrayMenu )
      // MsgBox( 'x= ' + str(x) + ' level = ' + str(level) +' value = '+str(ArrayMenu[X,2]) )
      IF X = 1
         ArrayMenu[X,1] := 'POPUP'
         ArrayMenu[X,2] := 0
         //level := 0
      ELSEIF X = 2
         IF ArrayMenu[X,2] = LEVEL
            // MsgBox(  ArrayMenu[X,1]+STR(X),'POPUP-1')
            ArrayMenu[X,1] := 'POPUP'
         ENDIF
         IF ArrayMenu[X,2] = LEVEL + 1
            // MsgBox(  ArrayMenu[X,1]+STR(X),'ITEM-2')
            ArrayMenu[X,1] := 'ITEM'
            LEVEL ++
         ENDIF
         IF Len( ArrayMenu ) - X > 0
            IF ArrayMenu[X+1,2] = ArrayMenu[X,2] + 1
               // MsgBox(  ArrayMenu[X,1]+STR(X),'POPUP-3')
               ArrayMenu[X,1] := 'POPUP'
            ENDIF
         ENDIF
      ELSE
         // MsgBox(STR(X),'VALOR-X')
         IF Len( ArrayMenu ) - X > 0  // IS NOT THE LAST ONE
            IF ArrayMenu[X,2] = LEVEL
               // MsgBox(  ArrayMenu[X,1]+STR(X),'ITEM-4')
               ArrayMenu[X,1] := 'ITEM'
               IF Upper( ArrayMenu[X,3] ) = 'SEPARATOR' .OR. SubStr( ArrayMenu[x,3], 1, 1 ) = "-"
                  // MsgBox(  ArrayMenu[X,1]+STR(X),'SEP-5')
                  ArrayMenu[X,1] := 'SEPARATOR'
               ENDIF
               IF  ArrayMenu[X+1,2] = LEVEL + 1
                  // MsgBox(  ArrayMenu[X,1]+STR(X),'POP-6')
                  ArrayMenu[X,1] := 'POPUP'
               ENDIF
               IF ArrayMenu[x,2] = 0
                  // MsgBox(  ArrayMenu[X,1]+STR(X),'POP-7')
                  ArrayMenu[X,1] := 'POPUP'
               ENDIF
            ENDIF
            IF ArrayMenu[X,2] = LEVEL + 1
               // MsgBox(  ArrayMenu[X,1]+STR(X),'IT-8')
               ArrayMenu[X,1] := 'ITEM'
               LEVEL ++
               IF ArrayMenu[X+1,2] = LEVEL + 1
                  // MsgBox(  ArrayMenu[X,1]+STR(X),'POP-9')
                  ArrayMenu[X,1] := 'POPUP'
               ENDIF
            ENDIF
            IF ArrayMenu[X,2] < LEVEL
               // MsgBox(  ArrayMenu[X,1]+STR(X),'POP-10')
               DO WHILE .T.
                  LEVEL --
                  IF ArrayMenu[X,2] = LEVEL
                     //IF ArrayMenu[X+1,2] = LEVEL +1
                     ArrayMenu[X,1] := 'POPUP'
                     * level := level + 1
                     //ELSE
                     // MsgBox(  ArrayMenu[X,1]+STR(X),'IT-11')
                     //   ArrayMenu[X,1] := 'ITEM'
                     //ENDIF
                     EXIT
                  ENDIF
               ENDDO
            ENDIF
         ENDIF

         IF Len( ArrayMenu ) - X = 0  // IS THE LAST ONE
            IF ArrayMenu[X,2] = 0
               // MsgBox(  ArrayMenu[X,1]+STR(X),'POP-11')
               ArrayMenu[X,1] := 'POPUP'
               LEVEL := ArrayMenu[X,2]
            ELSE
               // MsgBox(  ArrayMenu[X,1]+STR(X),'ITEM-12')
               ArrayMenu[X,1] := 'ITEM'
               IF ArrayMenu[X,3] = 'SEPARATOR' .OR. SubStr( ArrayMenu[x,3], 1, 1 ) = "-"
                  // MsgBox(  ArrayMenu[X,1]+STR(X),'SEP-13')
                  ArrayMenu[X,1] := 'SEPARATOR'
               ENDIF
            ENDIF
         ENDIF
      ENDIF

   NEXT X

RETURN
*/