#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW MENUBUILDER
DECLARE WINDOW STATUSBARBUILDER
DECLARE WINDOW DropDownMenuBuilder
DECLARE WINDOW ContextBuilder
 

*------------------------------------------------------------*
PROCEDURE MenuBuilder( TIPO AS STRING )
*------------------------------------------------------------*

   IF ! isWindowActive( Form_1 )
      RETURN
   ENDIF
  
   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF TIPO = "MAIN"
      IF ! _isWindowDefined( "MENUBUILDER" )
         LOAD WINDOW MENUBUILDER
      ENDIF

      IF _isWindowActive( "MENUBUILDER" )
         RELEASE WINDOW MENUBUILDER
      ENDIF

      MENUBUILDER.Title := "Main Menu Builder"
      CENTER WINDOW MENUBUILDER
      ACTIVATE WINDOW MENUBUILDER

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF TIPO = "CONTEXT"
      IF ! _isWindowDefined( "ContextBuilder" )
         LOAD WINDOW ContextBuilder
      ENDIF

      ContextBuilder.Title := "Context Menu Builder"
      CENTER WINDOW ContextBuilder
      ACTIVATE WINDOW ContextBuilder

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF TIPO = "NOTIFY"
      IF ! _isWindowDefined( "ContextBuilder" )
         LOAD WINDOW ContextBuilder
      ENDIF

      ContextBuilder.Title := "Notify Menu Builder"
      CENTER WINDOW ContextBuilder
      ACTIVATE WINDOW ContextBuilder

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF TIPO = "DROPDOWN"                       //SL: Replace DropDownMenuBuilder()
      IF isWindowActive( DropDownMenuBuilder )
         DropDownMenuBuilder.Setfocus
      ELSE
         IF ! _isWindowDefined( "DropDownMenuBuilder" )
            LOAD WINDOW DropDownMenuBuilder
         ENDIF

         DropDownMenuBuilder.Title := "Dropdown Menu Builder"
         CENTER WINDOW DropDownMenuBuilder
         ACTIVATE WINDOW DropDownMenuBuilder
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF TIPO = "STATUSBAR"                      //SL: Replace StatusbarBuilder()
      IF ! _isWindowDefined( "STATUSBARBUILDER" )
         LOAD WINDOW StatusbarBuilder
      ENDIF

      CENTER WINDOW StatusbarBuilder
      ACTIVATE WINDOW StatusbarBuilder

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ELSEIF TIPO = "TOOLBAR"                        //SL: Replace ToolBarBuilder()
      IF ! _isWindowDefined( "ToolbarBuilder" )
         LOAD WINDOW ToolbarBuilder
      ENDIF

      CENTER WINDOW ToolbarBuilder
      ACTIVATE WINDOW ToolbarBuilder

   ENDIF

RETURN

/*
*------------------------------------------------------------*
PROCEDURE StatusBarBuilder()    // Incorporated in MenuBuilder
*------------------------------------------------------------*
   IF ! isWindowActive( Form_1 )
      RETURN
   ENDIF

   LOAD WINDOW StatusbarBuilder
   CENTER WINDOW StatusbarBuilder
   ACTIVATE WINDOW StatusbarBuilder

RETURN


*------------------------------------------------------------*
PROCEDURE DropDownMenuBuilder() // Incorporated in MenuBuilder
*------------------------------------------------------------*
   IF ! isWindowActive( Form_1 )
      RETURN
   ENDIF

   LOAD WINDOW DropDownMenuBuilder
   CENTER WINDOW DropDownMenuBuilder
   ACTIVATE WINDOW DropDownMenuBuilder

RETURN
*/

*------------------------------------------------------------*
PROCEDURE ContextClose()
*------------------------------------------------------------*
  IF _isWindowDefined( "DropDownMenuBuilder" )
     DropDownMenuBuilder.SetFocus
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextInit()          //  MATRIZ ) //? Parameter neveu used
*------------------------------------------------------------*
  LOCAL vArray     AS ARRAY
  LOCAL xValue     AS ARRAY     //? Invalid hungarian
  LOCAL x          AS NUMERIC
  LOCAL A1         AS USUAL     //? VarType
  LOCAL x4         AS NUMERIC
  LOCAL aMenuItens AS ARRAY

  **load values from VARRAY and display in form
  ** and store to array

  *DEFINE CONTEXT MENU
  *  MENUITEM ACTION  NAME IMAGE  CHECKED DISABLED  MESSAGE
  *  SEPARATOR
  *
  *END MENU

  IF ContextBuilder.Title == "Context Menu Builder"
     vArray := aContext

  ELSEIF ContextBuilder.Title == "Notify Menu Builder"
     vArray := aNotify

  ELSEIF ContextBuilder.Title = "Dropdown Menu Builder"
     vArray := FillDropArray() // filldroparray() in dropdown.prg
  ENDIF

  //? Why here
  PUBLIC ArrayContext := {}

  IF Len( vArray ) > 0
     FOR x := 2 TO ( Len( vArray ) - 1 )

         // MsgBox( "x= " + Str(x) + " len-varray= " + Str( Len( vArray ) ) )
         A1 := vArray[ x ]

         // MsgBox( "A1 = " + A1 )
         X4 := At( "MENUITEM", A1 )

         IF X4 > 0
            aMenuItens := MenuItens( A1, X4, "MENUITEM" )
            aAdd( ArrayContext, { "MENUITEM", aMenuItens[1],;
                  aMenuItens[2], aMenuItens[3], aMenuItens[4],;
                  aMenuItens[7], aMenuItens[8], aMenuItens[9]} )
            // MsgBox( "A-ITEM " + Str(X-1) + " " + ArrayContext[X-1,2] )
         ELSE
            aAdd( ArrayContext, {"SEPARATOR","-","","","",".F.",".F.",""} )
            // MsgBox( "B-ITEM " + Str(X-1) + " " + ArrayContext[X-1,2] )
         ENDIF
     NEXT X

     IF ContextBuilder.Title = "Dropdown Menu Builder"
        DO WHILE DropDownMenuBuilder.Grid_1.ItemCount > Len( ArrayContext )
           aAdd(ArrayContext, { "MENUITEM", "", "", "", "", ".F.", ".F.", "" } )
        ENDDO
     ENDIF

     ContextFillGrid()

     ContextBuilder.Grid_1.Value := 1

     FillForm( ContextBuilder.Grid_1.Value )
  ELSE
     // MsgBox( "array zerado" )
     xValue := { "", "", "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" }
     aAdd( ArrayContext, xValue )
     // MsgBox( "len ArrayContext= " + Str( Len( ArrayContext ) ) )
     ContextBuilder.Grid_1.Value := 1
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE FillForm( nPos AS NUMERIC )
*------------------------------------------------------------*
   ContextBuilder.Text_1.Value  := ArrayContext[ npos, 2 ]
   ContextBuilder.Text_2.Value  := ArrayContext[ npos, 3 ]
   ContextBuilder.Text_3.Value  := ArrayContext[ npos, 4 ]
   ContextBuilder.Text_4.Value  := ArrayContext[ npos, 5 ]
   ContextBuilder.Check_1.Value := ArrayContext[ nPos, 6 ] == ".T."
   ContextBuilder.Check_2.Value := ArrayContext[ nPos, 7 ] == ".T."
   ContextBuilder.Text_5.Value  := ArrayContext[ nPos, 8 ]
RETURN


*------------------------------------------------------------*
PROCEDURE ContextOK()
*------------------------------------------------------------*
  LOCAL VARRAY  AS ARRAY   := {}
  LOCAL cTitle  AS STRING
  LOCAL N1      AS NUMERIC
  LOCAL N2      AS NUMERIC
  LOCAL x       AS NUMERIC
  LOCAL cText   AS STRING

  IF ContextBuilder.Title = "Context Menu Builder"
     aAdd( vArray, Space(5) + "DEFINE CONTEXT MENU" )

  ELSEIF ContextBuilder.Title = "Notify Menu Builder"
     aAdd( vArray, Space(5) + "DEFINE NOTIFY MENU ")

  ELSEIF ContextBuilder.Title = "Dropdown Menu Builder"
     N1     := At( "[", ContextBuilder.Title )
     N2     := At( "]", ContextBuilder.Title )
     cTitle := SubStr( ContextBuilder.Title, N1+1, N2-N1-1 )

     aAdd( vArray, Space(5) + "DEFINE DROPDOWN MENU BUTTON " + cTitle )
  ENDIF

  FOR X := 1 TO Len( ArrayContext )
      // MsgBox( "len->ArrayContext=" + Str( Len( ArrayContext ) ) )
      IF ArrayContext[ X, 1 ] = "MENUITEM"
         cText := Space(12) + "MENUITEM " + '"' + ArrayContext[ X, 2 ] + '"'
         // MsgBox( "ACTION= "   + ArrayContext[ X, 3 ] )
         // MsgBox( "NAME= "     + ArrayContext[ X, 4 ] )
         // MsgBox( "IMAGE= "    + ArrayContext[ X, 5 ] )
         // MsgBox( "CHECKED= "  + ArrayContext[ X, 6 ] )
         // MsgBox( "DISABLED= " + ArrayContext[ X, 7 ] )
         // MsgBox( "MESSAGE= "  + ArrayContext[ X, 8 ] )

         IF Len( AllTrim( ArrayContext[ X, 3 ] ) ) > 0
            cText += " ACTION " + ArrayContext[ X, 3 ]
         ENDIF

         IF Len( AllTrim( ArrayContext[ X, 4 ] ) ) > 0 .AND. AllTrim( ArrayContext[ X, 4 ] ) # "NIL"
            cText += " NAME " + ArrayContext[X,4]
         ENDIF

         IF Len( AllTrim (ArrayContext[ X, 5 ] ) ) > 0 .AND. AllTrim( ArrayContext[ X, 5 ] ) # "NIL"
            cText += " IMAGE " + '"' + ArrayContext[ X, 5 ] + '"'
         ENDIF

         IF ArrayContext[ X, 6 ] # ".F."
            cText += " CHECKED "
         ENDIF

         IF ArrayContext[ X, 7 ] # ".F."
            cText += " DISABLED "
         ENDIF

         IF Len( AllTrim( ArrayContext[ X, 8 ] ) ) > 0 .AND. AllTrim( ArrayContext[ X, 8 ] ) # "NIL"
            cText += " MESSAGE " + '"' + ArrayContext[ X, 8 ] + '"'
         ENDIF

         aAdd( vArray, cText )

      ELSEIF ArrayContext[ X, 1 ] = "SEPARATOR"
         cText := Space( 12 ) + "SEPARATOR"
         aAdd( vArray, cText )
      ENDIF
  NEXT X

  aAdd( vArray, Space(5) + "END MENU" )
  **************************************
  //  ATEXT := ""
  //     FOR X = 1 TO Len(VARRAY)
  //         ATEXT += STR(X)+" "+VARRAY[X]+crlf
  //     NEXT X
  //  MsgBox(ATEXT)
  **************************************
  IF ContextBuilder.Title = "Context Menu Builder"
     aContext     := vArray

  ELSEIF ContextBuilder.Title = "Notify Menu Builder"
     aNotify      := vArray

  ELSEIF ContextBuilder.Title = "Dropdown Menu Builder"
     aVLDropdown  := vArray
     aDropDown    := ChangeArray()  //changearray() in dropdown.prg
  ENDIF

  // MsgBox( "OK, TITLE= " + ContextBuilder.Title )

  lChanges := .T.

  ContextBuilder.Release

  IF _isWindowDefined( "DropDownMenuBuilder" )
     // DropDownMenuBuilder.Release
     DropDownMenuBuilder.SetFocus
     DropDownMenuBuilder.Show
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextCancel()
*------------------------------------------------------------*
   ContextBuilder.Release
RETURN


*------------------------------------------------------------*
PROCEDURE ContextCaptionChange()
*------------------------------------------------------------*
  // MsgBox( "value= "+str(ContextBuilder.Grid_1.Value ) )
  IF AllTrim( ContextBuilder.Text_1.Value ) = "-" .OR. Upper( AllTrim( ContextBuilder.Text_1.Value ) ) = "SEPARATOR"
     // MsgBox("SEPARATOR")
     ArrayContext[ ContextBuilder.Grid_1.Value, 1 ] :=  "SEPARATOR"
     ArrayContext[ ContextBuilder.Grid_1.Value, 2 ] :=  "-"
     ArrayContext[ ContextBuilder.Grid_1.Value, 3 ] :=  "NIL"
     ArrayContext[ ContextBuilder.Grid_1.Value, 4 ] :=  "NIL"
     ArrayContext[ ContextBuilder.Grid_1.Value, 5 ] :=  "NIL"
     ArrayContext[ ContextBuilder.Grid_1.Value, 6 ] :=  ".F."
     ArrayContext[ ContextBuilder.Grid_1.Value, 7 ] :=  ".F."
     ArrayContext[ ContextBuilder.Grid_1.Value, 8 ] :=  "NIL"
     ContextBuilder.Grid_1.Value := "-"
     // FillForm( nPos )
  ELSE
     // MsgBox( "NO SEPARATOR" )
     ArrayContext[ ContextBuilder.Grid_1.Value, 1 ]            := "MENUITEM"
     ContextBuilder.Grid_1.Item( ContextBuilder.Grid_1.Value ) := { ContextBuilder.Text_1.Value }
     ArrayContext[ ContextBuilder.Grid_1.Value, 2 ]            := ContextBuilder.Text_1.Value
  ENDIF
  // ContextFillGrid()
RETURN


*------------------------------------------------------------*
PROCEDURE ContextActionChange()
*------------------------------------------------------------*
  IF ArrayContext[ ContextBuilder.Grid_1.Value, 1 ] = "MENUITEM"
     ArrayContext[ ContextBuilder.Grid_1.Value, 3 ] := ContextBuilder.Text_2.Value
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextNameChange()
*------------------------------------------------------------*
  // MsgBox( "namechange" )
  IF ArrayContext[ ContextBuilder.Grid_1.Value, 1 ] = "MENUITEM"
     ArrayContext[ ContextBuilder.Grid_1.Value, 4 ] := ContextBuilder.Text_3.Value
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextImageChange()
*------------------------------------------------------------*
  // MsgBox( "imagechange" )
  IF ArrayContext[ ContextBuilder.Grid_1.Value, 1 ] = "MENUITEM"
     ArrayContext[ ContextBuilder.Grid_1.Value, 5 ] := ContextBuilder.Text_4.Value
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextCheckedChange()
*------------------------------------------------------------*
  IF ArrayContext[ ContextBuilder.Grid_1.Value, 1 ] = "MENUITEM"
     //IF ContextBuilder.Check_1.Value = .F.
     //   ArrayContext[ContextBuilder.Grid_1.Value, 6 ] := ".F."
     //ELSE
     //   ArrayContext[ContextBuilder.Grid_1.Value, 6 ] := ".T."
     //ENDIF

     ArrayContext[ ContextBuilder.Grid_1.Value, 6 ] := xToc( ContextBuilder.Check_1.Value )
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextDisabledChange()
*------------------------------------------------------------*
  IF ArrayContext[ ContextBuilder.Grid_1.Value,1] = "MENUITEM"
     //IF ContextBuilder.Check_2.Value = .F.
     //  ArrayContext[ ContextBuilder.Grid_1.Value, 7 ] := ".F."
     //ELSE
     //   ArrayContext[ ContextBuilder.Grid_1.Value, 7 ] := ".T."
     //ENDIF

     ArrayContext[ ContextBuilder.Grid_1.Value, 7 ] := xToc( ContextBuilder.Check_2.Value )

  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextMessageChange()
*------------------------------------------------------------*
  IF ArrayContext[ ContextBuilder.Grid_1.Value, 1 ] = "MENUITEM"
     ArrayContext[ ContextBuilder.Grid_1.Value, 8 ] := ContextBuilder.Text_5.Value
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextUp()
*------------------------------------------------------------*
  LOCAL tValue AS USUAL //? VarType
  LOCAL xTemp  AS USUAL //? VarType

  IF ContextBuilder.Grid_1.Value > 1
     tValue                     := ContextBuilder.Grid_1.Value
     xTemp                      := ArrayContext[ tValue     ]
     ArrayContext[ tValue     ] := ArrayContext[ tValue - 1 ]
     ArrayContext[ tValue - 1 ] := xTemp

     ContextFillGrid()

     ContextBuilder.Grid_1.Value := tValue - 1
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextDown()
*------------------------------------------------------------*
  LOCAL tValue AS USUAL //? VarType
  LOCAL xTemp  AS USUAL //? VarType

  IF ContextBuilder.Grid_1.Value < ContextBuilder.Grid_1.ItemCount

     tValue                    := ContextBuilder.Grid_1.Value
     xTemp                     := ArrayContext[ tValue     ]
     ArrayContext[tValue     ] := ArrayContext[ tValue + 1 ]
     ArrayContext[tValue + 1 ] := xTemp

     ContextFillGrid()

     ContextBuilder.Grid_1.Value := tValue + 1
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextNext()
*------------------------------------------------------------*
  LOCAL xValue AS ARRAY

  IF ContextBuilder.Grid_1.Value <  ContextBuilder.Grid_1.ItemCount
     ContextBuilder.Grid_1.Value := ContextBuilder.Grid_1.Value + 1

     ContextGridChange()
  ELSE
     IF Empty( aTail( ArrayContext )[2] )
        ContextDelete()
     ENDIF

     xValue := { "MENUITEM", "New Item", "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" }

     aAdd( ArrayContext, xValue )

     ContextBuilder.Grid_1.AddItem({ aTail( ArrayContext )[2] } )

     ContextBuilder.Grid_1.Value := ContextBuilder.Grid_1.ItemCount
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextPrior()
*------------------------------------------------------------*
  IF ContextBuilder.Grid_1.Value > 1
     ContextBuilder.Grid_1.Value := ContextBuilder.Grid_1.Value - 1
     ContextGridChange()
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextInsert()
*------------------------------------------------------------*
  LOCAL xValue AS ARRAY //?
  LOCAL tValue AS USUAL //? VarType

  IF ContextBuilder.Grid_1.Value > 0
     xValue := { "MENUITEM", "New Item", "NIL", "NIL", "NIL", ".F.", ".F.", "NIL" }
     // MsgBox( "len ArrayContext1= " + Str( Len( ArrayContext ) ) )

     aSize( ArrayContext, Len( ArrayContext ) + 1 )

     // MsgBox("len ArrayContext2= "+STR(Len(ArrayContext)))
     // MsgBox("LEN GRID= "+STR(ContextBuilder.Grid_1.Value))

     aIns( ArrayContext, ContextBuilder.Grid_1.Value )

     ArrayContext[ ContextBuilder.Grid_1.Value ] := xValue
     tValue                                      := ContextBuilder.Grid_1.Value

     ContextFillGrid()

     ContextBuilder.Grid_1.Value := tValue

     ContextGridChange()
  ELSE
     ContextNext()
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextDelete()
*------------------------------------------------------------*
  LOCAL tValue AS NUMERIC

  IF ContextBuilder.Grid_1.ItemCount > 1
     // MsgBox("len ArrayContext1= "+STR(Len(ArrayContext)))

     aDel( ArrayContext, ContextBuilder.Grid_1.Value )

     aSize( ArrayContext, Len( ArrayContext ) - 1 )
     // MsgBox("len ArrayContext2= "+STR(Len(ArrayContext)))

     tValue := ContextBuilder.Grid_1.Value

     ContextFillGrid()

     IF tValue > 1
        ContextBuilder.Grid_1.Value := tValue - 1
     ELSE
        ContextBuilder.Grid_1.Value := tValue
     ENDIF

     //IF Len( ArrayContext ) = 0
     //   ContextNext()
     //ENDIF
  ELSE
     // MsgBox( "len ArrayContext3= "+STR(Len(ArrayContext)) )
     ArrayContext[ 1 ] := { "","","","NIL","NIL",".F.",".F.","NIL" }

     ContextFillGrid()

     ContextBuilder.Grid_1.Value := 1

     ContextGridChange()
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextGridChange()
*------------------------------------------------------------*

  // MsgBox( "value= " + Str( ContextBuilder.Grid_1.Value ) )
  IF ContextBuilder.Grid_1.ItemCount > 0

     ContextBuilder.Text_1.Value := ArrayContext[ ContextBuilder.Grid_1.Value, 2 ]         // CAPTION

     IF ArrayContext[ContextBuilder.Grid_1.Value, 1 ] = "MENUITEM"
        ContextBuilder.Text_2.Value := ArrayContext[ ContextBuilder.Grid_1.Value, 3 ]      // ACTION

        IF ArrayContext[ ContextBuilder.Grid_1.Value, 4 ] # "NIL"
           ContextBuilder.Text_3.Value := ArrayContext[ ContextBuilder.Grid_1.Value, 4 ]   // NAME
        ELSE
           ContextBuilder.Text_3.Value := ""
        ENDIF

        IF ArrayContext[ ContextBuilder.Grid_1.Value, 5 ] # "NIL"
           ContextBuilder.Text_4.Value := ArrayContext[ ContextBuilder.Grid_1.Value, 5 ]   // IMAGE
        ELSE
           ContextBuilder.Text_4.Value := ""
        ENDIF

        //IF ArrayContext[ ContextBuilder.Grid_1.Value, 6 ] = ".F."                          // CHECKED
        //   ContextBuilder.Check_1.Value := .F.
        //ELSE
        //   ContextBuilder.Check_1.Value := .T.
        //ENDIF
        ContextBuilder.Check_1.Value := ArrayContext[ ContextBuilder.Grid_1.Value, 6 ] == ".T." // CHECKED

        //IF ArrayContext[ ContextBuilder.Grid_1.Value, 7 ] =  ".F."                         // DISABLED
        //   ContextBuilder.Check_2.Value := .F.
        //ELSE
        //   ContextBuilder.Check_2.Value := .T.
        //ENDIF
        ContextBuilder.Check_2.Value := ArrayContext[ ContextBuilder.Grid_1.Value, 7 ] ==  ".T." // DISABLED

        IF ArrayContext[ ContextBuilder.Grid_1.Value, 8 ] # "NIL"                          // MESSAGE
           ContextBuilder.Text_5.Value := ArrayContext[ ContextBuilder.Grid_1.Value, 8 ]
        ELSE
           ContextBuilder.Text_5.Value := ""
        ENDIF

     ELSE
        ContextBuilder.Text_2.Value  := ""
        ContextBuilder.Text_3.Value  := ""
        ContextBuilder.Text_4.Value  := ""
        ContextBuilder.Text_5.Value  := ""
        ContextBuilder.Check_1.Value := .F.
        ContextBuilder.Check_2.Value := .F.
     ENDIF

  ELSE
     ContextBuilder.Text_1.Value  := ""
     ContextBuilder.Text_2.Value  := ""
     ContextBuilder.Text_3.Value  := ""
     ContextBuilder.Text_4.Value  := ""
     ContextBuilder.Text_5.Value  := ""
     ContextBuilder.Check_1.Value := .F.
     ContextBuilder.Check_2.Value := .F.
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ContextFillGrid()
*------------------------------------------------------------*
  LOCAL xValue AS USUAL      //? VarType
  LOCAL x      AS NUMERIC

  ContextBuilder.Grid_1.DeleteAllitems

  FOR x := 1 TO Len( ArrayContext )
      // MsgBox("x= "+str(x)+" "+ArrayContext[x,2])
      xValue := ArrayContext[ x, 2 ]
      // IF ! Empty( xvalue )
      ContextBuilder.Grid_1.AddItem( { xValue } )
      // ENDIF
  NEXT x

RETURN


*------------------------------------------------------------*
FUNCTION MenuItens( A1, x4, A2 )                         //Opt
*------------------------------------------------------------*
  LOCAL xCaption    AS NUMERIC := At( "MENUITEM" , A1 )
  LOCAL xAction     AS NUMERIC := At( "ACTION"   , A1 )
  LOCAL xName       AS NUMERIC := At( "NAME"     , A1 )
  LOCAL xImage      AS NUMERIC := At( "IMAGE"    , A1 )
  LOCAL xChecked    AS NUMERIC := At( "CHECKED"  , A1 )
  LOCAL xDisabled   AS NUMERIC := At( "DISABLED" , A1 )
  LOCAL xMessage    AS NUMERIC := At( "MESSAGE"  , A1 )
  LOCAL xCheckmark  AS NUMERIC := At( "CHECKMARK", A1 )
  LOCAL xFont       AS NUMERIC := At( "FONT"     , A1 )
  LOCAL cTemp       AS STRING
  LOCAL aMenuItens  AS ARRAY   := Array( 9 )

  // Fill array with NIL value
  aFill( aMenuItens, NIL )

  IF A2 == NIL
     cTemp := AllTrim( SubStr( A1, xCaption+9, xAction-xCaption-1-9 ) )    // Caption
     // MsgBox( "CAPTION1= " + cTemp )
     aMenuItens[1] := SubStr( cTemp, 2, Len( cTemp )- 2 )
  ELSE
     cTemp := AllTrim( SubStr( A1, xCaption+9, xAction-xCaption-1-9 ) )
     // MsgBox( "CAPTION2= " + cTemp )
     aMenuItens[1] := SubStr( cTemp, 2, Len( cTemp ) - 2 )
  ENDIF

  IF xName > 0
     aMenuItens[2] := SubStr( A1, xAction+7, xName-1-xAction-7 )              // action

  ELSEIF xImage > 0
     aMenuItens[2] := SubStr( A1, xAction+7, xImage-1-xAction-7 )

  ELSEIF xCheckMark > 0
     aMenuItens[2] := SubStr( A1, xAction+7, xCheckMark-1-xAction-7 )

  ELSEIF xFont > 0
     aMenuItens[2] := SubStr( A1, xAction+7, xFont-1-xAction-7)

  ELSEIF xChecked > 0
     aMenuItens[2] := SubStr( A1, xAction+7, xChecked-1-xAction-7)

  ELSEIF xDisabled > 0
     aMenuItens[2] := SubStr( A1, xAction+7, xDisabled-1-xAction-7)

  ELSEIF xMessage > 0
     aMenuItens[2] := SubStr( A1, xAction+7, xMessage-1-xAction-7)

  ELSE
     aMenuItens[2] := SubStr( A1, xAction+7, Len(A1)-xAction-6)
  ENDIF

  IF xName > 0
     IF xImage > 0
        aMenuItens[3] := SubStr( A1, xName+5, xImage-1-xName-5)              // name

     ELSEIF xCheckMark > 0
        aMenuItens[3] := SubStr( A1, xName+5, xCheckmark-1-xName-5)

     ELSEIF xFont > 0
        aMenuItens[3] := SubStr( A1, xName+5, xFont-1-xName-5)

     ELSEIF xChecked > 0
        aMenuItens[3] := SubStr( A1, xName+5, xChecked-1-xName-5)

     ELSEIF xDisabled > 0
        aMenuItens[3] := SubStr( A1, xName+5, xDisabled-1-xName-5)

     ELSEIF xMessage > 0
        aMenuItens[3] := SubStr( A1, xName+5, xMessage-1-xName-5)

     ELSE
        aMenuItens[3] := SubStr( A1, xName+5, Len( A1 )-xName-4)
     ENDIF
  ELSE
     aMenuItens[3] := ""
  ENDIF

  IF xImage > 0
     IF xCheckmark > 0
        aMenuItens[4] := SubStr( A1, xImage+6, xCheckMark-1-xImage-6)        // image

     ELSEIF xFont > 0
        aMenuItens[4] := SubStr( A1, xImage+6, xFont-1-xImage-6)

     ELSEIF xChecked > 0
        aMenuItens[4] := SubStr( A1, xImage+6, xChecked-1-xImage-6)

     ELSEIF xDisabled > 0
        aMenuItens[4] := SubStr( A1, xImage+6, xDisabled-1-xImage-6)

     ELSEIF xMessage > 0
        aMenuItens[4] := SubStr( A1, xImage+6, xMessage-1-xImage-6)

     ELSE
        aMenuItens[4] := SubStr( A1, xImage+6, Len(A1)-xImage-5)
     ENDIF

     aMenuItens[4] := AllTrim( aMenuItens[4] )
     // MsgBox("IMAGE1= "+aMenuItens[4])
     aMenuItens[4] := SubStr( aMenuItens[4],2,Len( aMenuItens[4])-2)
  ELSE
     aMenuItens[4] := ""
  ENDIF

  IF xCheckMark > 0
     IF xFont > 0
        aMenuItens[5] := SubStr( A1, xCheckMark+11, xFont    -1-xCheckMark-11 )
     ELSEIF xChecked > 0
        aMenuItens[5] := SubStr( A1, xCheckMark+11, xChecked- 1-xCheckMark-11 )
     ELSEIF xDisabled > 0
        aMenuItens[5] := SubStr( A1, xCheckMark+11, xDisabled-1-xCheckMark-11 )
     ELSEIF xMessage > 0
        aMenuItens[5] := SubStr( A1, xCheckMark+11, xMessage -1-xCheckMark-11 )
     ELSE
        aMenuItens[5] := SubStr( A1, xCheckMark+11, Len(A1)    -xCheckMark-10 )
     ENDIF
  ELSE
     aMenuItens[5] := ""
  ENDIF

  IF xFont > 0
     IF xChecked > 0
        aMenuItens[6] := SubStr( A1, xFont+6, xChecked  - 1 - xFont - 6 )
     ELSEIF xDisabled > 0
        aMenuItens[6] := SubStr( A1, xFont+6, xDisabled - 1 - xFont - 6 )
     ELSEIF xMessage > 0
        aMenuItens[6] := SubStr( A1, xFont+6, xMessage  - 1 - xFont - 6 )
     ELSE
        aMenuItens[6] := SubStr( A1, xFont+6, Len( A1 )     - xFont - 5 )
     ENDIF
  ELSE
     aMenuItens[6] := ""
  ENDIF

  IF xChecked > 0
     aMenuItens[7] := ".T."   // checked
  ELSE
     aMenuItens[7] := ".F."
  ENDIF

  IF xDisabled > 0
     aMenuItens[8] := ".T."  // disabled
  ELSE
     aMenuItens[8] := ".F."
  ENDIF

  IF xMessage > 0
     aMenuItens[9] := AllTrim( SubStr( A1, xMessage + 8, Len( A1 ) ) )     // message
     // MsgBox( "MESSAGE= " + aMenuItens[9] )
     aMenuItens[9] := SubStr( aMenuItens[9],2,Len( aMenuItens[9])-2)
     // MsgBox( "MESSAGE= " + aMenuItens[9] )
  ELSE
     aMenuItens[9] := ""
  ENDIF

  aEval( aMenuItens, { | a, z | aMenuItens[ z ] := AllTrim( a ) } )

RETURN( aMenuItens )


*------------------------------------------------------------*
PROCEDURE BeautContext()
*------------------------------------------------------------*
  LOCAL aTemp AS ARRAY   := {}
  LOCAL x     AS NUMERIC

  IF Len(acontext) > 0
     aAdd( aTemp, Space( 5 ) + AllTrim( aContext[1] ) )

     FOR x := 2 TO Len( aContext )
         aContext[x] := AllTrim( aContext[x] )
         // MsgBox( "line= " + aContext[x] )

         IF At( "MENUITEM", aContext[x] ) = 1
            // MsgBox("added menuitem")
            aAdd( aTemp, Space( 12 ) + aContext[x] )
         ENDIF

         IF At( "SEPARATOR", aContext[x] ) = 1
            // MsgBox( "added SEPARATOR" )
            aAdd( aTemp, Space( 12 ) + aContext[x] )
         ENDIF

         IF At( "END MENU", aContext[x] ) = 1
            // MsgBox( "added end menu" )
            aAdd( aTemp, Space( 5 ) + aContext[x] )
         ENDIF

     NEXT x

  ENDIF

  aContext := aTemp

RETURN


*------------------------------------------------------------*
PROCEDURE Beautnotify()
*------------------------------------------------------------*
  LOCAL aTemp AS ARRAY   := {}
  LOCAL x     AS NUMERIC

  IF Len( aNotify ) > 0

     aAdd( aTemp, Space(5) + AllTrim( aNotify[1] ) )

     FOR x := 2 TO Len( aNotify )

         aNotify[x] := AllTrim( aNotify[x] )
         // MsgBox( "line= " + aNotify[x] )

         IF At( "MENUITEM", aNotify[x]) = 1
            // MsgBox( "added menuitem" )
            aAdd( aTemp, Space( 12 ) + aNotify[x] )
         ENDIF

         IF At( "SEPARATOR", aNotify[x] ) = 1
            // MsgBox( "added SEPARATOR" )
            aAdd( aTemp, Space( 12 ) + aNotify[x] )
         ENDIF

         IF At( "END MENU", aNotify[x] ) = 1
            // MsgBox("added end menu")
            aAdd( aTemp, Space( 5 ) + aNotify[x] )
         ENDIF

     NEXT x

  ENDIF

  aNotify := aTemp

RETURN
