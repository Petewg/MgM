#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW ProjectBrowser
DECLARE WINDOW FORM_1

*------------------------------------------------------------*
PROCEDURE AddReport()
*------------------------------------------------------------*
   LOCAL ic        AS NUMERIC
   LOCAL xPosRpt   AS NUMERIC
   LOCAL x         AS NUMERIC
   LOCAL xPos      AS NUMERIC
   LOCAL cPath     AS STRING
   LOCAL cOpen     AS STRING := aData[ _REPORTPATH ]
   LOCAL AddReport AS STRING
   LOCAL xRptName  AS STRING

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   ic        := ProjectBrowser.xlist_4.ItemCount
   AddReport := GetFile( { { "*.rpt", "*.rpt" } } , "Add Report", cOpen )
   xPos      := Rat( "\", AddReport )

   IF xPos > 0
      xRptName := SubStr( AddReport, xPos + 1, Len( AddReport ) )
      cPath    := SubStr( AddReport, 1, xPos )
   ELSE
      xRptName := ""
      cPath    := ""
   ENDIF

   IF Empty( xRptName )
      RETURN
   ENDIF

   aData[ _REPORTPATH ] := GetCurrentFolder()

   SavePreferences()

   IF cPath == ProjectFolder + "\"
      cPath := "<ProjectFolder>\"
      // MsgBox("CHANGED")
   ENDIF

   IF ic > 0
      FOR x := 1 TO ic
          IF Upper( xRptName ) == Upper( ProjectBrowser.xlist_4.Item( x ) )
             MsgStop( "Report Already in Project" )
             RETURN
          ENDIF
      NEXT x

      IF ic = 1 .AND. Empty( ProjectBrowser.xlist_4.Item( 1 ) )
         ProjectBrowser.xlist_4.DeleteAllitems
      ENDIF
   ENDIF

   aAdd( aRptNames, { xRptName, cPath } )

   aSort2( aRptNames )

   ProjectBrowser.xlist_4.DeleteAllitems

   FOR x := 1 TO Len( aRptNames )
       ProjectBrowser.xlist_4.AddItem( aRptNames[ x, 1 ] )

       IF aRptNames[ x, 1 ] = xRptName
          xPosRpt := x
       ENDIF

   NEXT x

   ProjectBrowser.xlist_4.Value := xPosRpt

   SaveModules()

RETURN


*------------------------------------------------------------*
PROCEDURE RefreshReport()
*------------------------------------------------------------*
   LOCAL x AS NUMERIC

   ProjectBrowser.Xlist_4.DeleteAllitems

   FOR x := 1 TO Len( aRptNames )
       ProjectBrowser.Xlist_4.AddItem( aRptNames[ x ][ 1 ] )
   NEXT x

   ProjectBrowser.Xlist_4.Value := 1

RETURN


*------------------------------------------------------------*
PROCEDURE DeleteReport()
*------------------------------------------------------------*
   LOCAL x           AS NUMERIC
   LOCAL aTempReport AS ARRAY   := {}
   LOCAL A1          AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   A1 := ProjectBrowser.Xlist_4.Value

   ProjectBrowser.Xlist_4.DeleteItem( ProjectBrowser.Xlist_4.Value )

   IF ProjectBrowser.xlist_4.ItemCount = 0
      aRptNames := {}
   ELSE
      aRptNames[ A1, 1 ] := NIL

      aEval( aRptNames, { | x | iif( x[ 1 ] # NIL, aAdd( aTempReport, { x[ 1 ], x[ 2 ] } ), "" ) } )

      aRptNames := {}

      aEval( aTempReport, { | x | aAdd( aRptNames, { x[ 1 ], x[ 2 ] } ) } )

      aSort2( aRptNames )

      ProjectBrowser.xlist_4.DeleteAllitems

      FOR x := 1 TO Len( aRptNames )
          ProjectBrowser.xlist_4.AddItem( aRptNames[ x, 1 ] )
      NEXT x

   ENDIF

   SaveModules()

RETURN


*------------------------------------------------------------*
PROCEDURE LoadReport()
*------------------------------------------------------------*
   LOCAL cReport  AS STRING
   LOCAL x5       AS STRING
   LOCAL x6       AS NUMERIC
   LOCAL aItens   AS ARRAY
   LOCAL xLin     AS NUMERIC  //? Invalid Hungarian
   LOCAL Y        AS NUMERIC
   LOCAL x4       AS NUMERIC
   LOCAL A1       AS STRING
   LOCAL nPos     AS NUMERIC

   IF IsWindowDefined( Form_1 )
      IF IsWindowVisible( _hmg_aformhandles[ GetFormIndex ( "Form_1" ) ] )
         IF ! MsgYesNo( "Abandon the current Form?", Form_1.Title )
            RETURN
         ELSE
            Form_1.Release
         ENDIF
      ENDIF
   ENDIF

   IF IsWindowDefined( ReportEditor )
      IF IsWindowVisible( _hmg_aformhandles[ GetFormIndex ( "ReportEditor" ) ] )
         IF ! MsgYesNo( "Abandon the current report?" )
            RETURN
         ENDIF
      ENDIF
   ENDIF

   IF ProjectBrowser.xlist_4.Value # 0
      cReport := ProjectBrowser.xlist_4.Item( ProjectBrowser.xlist_4.Value )
      //X5 := MemoRead( cReport )
      nPos := ProjectBrowser.xlist_4.Value
      IF Len( AllTrim( aRptNames[ npos ][ 2 ] ) ) = 0
         aRptNames[ nPos, 2 ] := "<ProjectFolder>\"
      ENDIF

      IF aRptNames[ nPos, 2 ] =  "<ProjectFolder>\"
         x5 := MemoRead( ProjectFolder + "\" + aRptNames[ nPos, 1 ] )
         // MsgBox( "x5 a= " + x5 + " " + ProjectFolder + "\" + aRptNames[ nPos, 1 ] )
      ELSE
         x5 := MemoRead( aRptNames[ nPos, 2 ] + aRptNames[ nPos, 1 ] )
         // MsgBox( "x5 b= " + x5 + " " + aRptNames[ nPos, 2 ] + aRptNames[ nPos, 1 ] )
      ENDIF

      ZeroaReport()

      x6 := MlCount( x5, 1000 )

      IF Empty( x6 )
         RETURN
      ENDIF

      aItens := { "TITLE ", "HEADERS ", "FIELDS ", "WIDTHS ", "TOTALS ", "NFORMATS ", "WORKAREA ", ;
                  "LPP ", "CPL ", "MARGIN ", "GROUPED BY ", "HEADRGRP ", "PAPERSIZE " }

      FOR xLin := 1 TO x6
          A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
          FOR Y = 1 TO 13

              x4 := At( aItens[ Y ], A1 )
              IF x4 > 0
                 aReport[ Y ] := SubStr( A1, x4 + Len( aItens[ Y ] ), Len( A1 ) )
              ENDIF
          NEXT Y

      NEXT xLin

      aItens := { "IMAGE" }

      FOR xLin := 1 TO x6
          A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
          x4 := At( aItens[ 1 ], A1 )

          IF x4 > 0
             A1            := AllTrim( SubStr( A1, x4 + 8, Len( A1 ) ) )
             x4            := At( ",", A1 )
             aReport[ 14 ] := SubStr( A1, 1, x4 - 1 )    // IMAGE
             A1            := AllTrim( SubStr( A1, x4 + 1, Len( A1 ) ) )
             x4            := At( ",", A1 )
             aReport[ 15 ] := SubStr( A1, 1, x4 - 1 )
             A1            := AllTrim( SubStr( A1, x4 + 1, Len( A1 ) ) )
             x4            := At( ",", A1 )
             aReport[ 16 ] := SubStr( A1, 1, x4 - 1 )
             A1            := AllTrim( SubStr( A1, x4 + 1, Len( A1 ) ) )
             x4            := At( ",", A1 )
             aReport[ 17 ] := SubStr( A1, 1, x4 - 1 )
             A1            := AllTrim( SubStr( A1, x4 + 1, Len( A1 ) ) )
             x4            := At( "}", A1 )
             aReport[ 18 ] := SubStr( A1, 1, x4 - 1 )
          ENDIF
      NEXT xLin

      aItens := { "DOSMODE", "PREVIEW", "SELECT", "MULTIPLE", "LANDSCAPE", "NOFIXED" }
      FOR xLin := 1 TO x6
          A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
          FOR Y := 1 TO 6
              x4 := AT( aItens[ Y ], A1 )
              IF x4 > 0
                 aReport[ 18 + Y ] := .T.
             ENDIF
          NEXT Y
      NEXT Xlin

      preport( cReport )

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE Preport( cReport AS STRING )
*------------------------------------------------------------*
   LOCAL x AS NUMERIC

   IF ! IsWindowDefined( ReportEditor )
      LOAD WINDOW ReportEditor
   ENDIF

   IF File( "_" + cReport + ".rpt" )
      fErase( "_" + cReport + ".rpt" )
   ENDIF

   ReportEditor.title := "Report Editor [" + cReport + "]"

   FOR x := 1 TO 18
       _SetValue( "text_"  + ltrim( Str( x ) ), "ReportEditor", aReport[ x ] )
   NEXT

   FOR x := 1 TO 6
       _SetValue( "check_" + ltrim( Str( x ) ), "ReportEditor", aReport[ 18 + x ] )
   NEXT

   CENTER WINDOW ReportEditor

   IF ! isWindowActive( ReportEditor )
      ACTIVATE WINDOW ReportEditor
   ELSE
      SHOW WINDOW ReportEditor
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ReportOk( Preview AS LOGICAL )
*------------------------------------------------------------*
   LOCAL RptText  AS STRING  := "DEFINE REPORT TEMPLATE" + CRLF
   LOCAL x        AS NUMERIC
   LOCAL m        AS STRING  := ""
   LOCAL e        AS LOGICAL := .F.
   LOCAL d        AS LOGICAL := .F.
   LOCAL nValue   AS NUMERIC := ProjectBrowser.xlist_4.Value
   LOCAL cTable   AS STRING
   LOCAL cReport  AS STRING

   // preview := iif( preview == NIL, .F., preview )
   DEFAULT Preview TO .F.

   IF aRptNames[ nvalue ][ 2 ] = '<ProjectFolder>\' .OR. Empty( aRptNames[ nvalue ][ 2 ] )
      cReport := ProjectFolder + "\"      + iif( preview, "_", "" ) + SubStr( aRptNames[ nValue ][ 1 ], 1, ( At( ".", aRptNames[ nValue ][ 1 ] ) - 1 ) )
   ELSE
      cReport := aRptNames[ nvalue ][ 2 ] + iif( preview, "_", "" ) + SubStr( aRptNames[ nValue ][ 1 ], 1, ( At( ".", aRptNames[ nValue ][ 1 ] ) - 1 ) )
   ENDIF

   // MsgBox( "cReport= " + cReport )

   FOR x := 1 TO 18
       aReport[ x ] := _GetValue( "text_" + ltrim( Str( x ) ), "ReportEditor" )
   NEXT

   FOR x := 1 TO 6
       aReport[ 18 + x ] := _GetValue( "check_" + ltrim( Str( x ) ), "ReportEditor" )
   NEXT

   IF Empty( aReport[ 1 ] )
      m += "/ Title "
      e := .T.
   ENDIF

   IF Empty( aReport[ 2 ] )
      m += "/ Headers "
      d := e
      e := .T.
   ENDIF

   IF Empty( aReport[ 3 ] )
      m += "/ Fields "
      d := e
      e := .T.
   ENDIF

   IF Empty( aReport[ 4 ] )
      m += "/ Widths "
      d := e
      e := .T.
   ENDIF

   IF Empty( aReport[ 7 ] )
      m += "/ WorkArea "
      d := e
      e := .T.
   ENDIF

   IF e
      m += iif( ! d, "/ is", "/ are" ) + " missing!"
   ENDIF

   IF e
      MsgStop( m, "Error" )
      RETURN
   ENDIF

   *-----------------------------------------------------------------------------*
   * Evalutation of correct string into report
   *-----------------------------------------------------------------------------*
   IF ! Check_Name()                                          ; RETURN ; ENDIF
   IF ! Check_ALen( ReportEditor.Text_2.Value, "Header" )     ; RETURN ; ENDIF
   IF ! Check_ALen( ReportEditor.Text_4.Value, "Widths" )     ; RETURN ; ENDIF
   IF ! Check_ALen( ReportEditor.Text_5.Value, "Totals" )     ; RETURN ; ENDIF
   IF ! Check_ALen( ReportEditor.Text_6.Value, "N.Formats" )  ; RETURN ; ENDIF

   // reassign values to array
   FOR x := 1 TO 18
       aReport[ x ] := _GetValue( "text_" + ltrim( str( x ) ), "ReportEditor" )
   NEXT

   FOR x := 1 TO 6
       aReport[ 18 + x ] := _GetValue( "check_" + ltrim( str( x ) ), "ReportEditor" )
   NEXT

   // Add by Pier Stop

   RptText += Space( 4 ) + "TITLE " + aReport[ 1 ] + CRLF + Space( 4 ) + "HEADERS " + aReport[ 2 ] + CRLF + Space( 4 ) + "FIELDS " + aReport[ 3 ] + CRLF + Space( 4 ) + "WIDTHS " + aReport[ 4 ] + CRLF

   IF Len( AllTrim( aReport[ 5 ] ) ) > 0
      RptText += Space( 4 ) + "TOTALS " + aReport[ 5 ] + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 6 ] ) ) > 0
      RptText += Space( 4 ) + "NFORMATS " + aReport[ 6 ] + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 7 ] ) ) > 0
      RptText += Space( 4 ) + "WORKAREA " + aReport[ 7 ] + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 8 ] ) ) > 0
      RptText += Space( 4 ) + "LPP " + aReport[ 8 ] + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 9 ] ) ) > 0
      RptText += Space( 4 ) + "CPL " + aReport[ 9 ] + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 10 ] ) ) > 0
      RptText += Space( 4 ) + "MARGIN " + aReport[ 10 ] + CRLF
   ENDIF

   IF aReport[ 24 ]                        // Add By Pier 27/08/2006 18.19
      RptText += Space( 4 ) + "NOFIXED" + CRLF
   ENDIF                                      // Add By Pier Stop

   IF aReport[ 19 ]
      RptText += Space( 4 ) + "DOSMODE" + CRLF
   ENDIF

   IF aReport[ 20 ] .OR. preview    // Add By Pier 31/08/2006 21.32
      RptText += Space( 4 ) + "PREVIEW" + CRLF
   ENDIF                                      // Add By Pier Stop

   IF aReport[ 21 ]
      RptText += Space( 4 ) + "SELECT" + CRLF
   ENDIF

   IF aReport[ 22 ]
      RptText += Space( 4 ) + "MULTIPLE" + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 11 ] ) ) > 0
      RptText += Space( 4 ) + "GROUPED BY " + aReport[ 11 ] + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 12 ] ) ) > 0
      RptText += Space( 4 ) + "HEADRGRP " + aReport[ 12 ] + CRLF
   ENDIF

   IF aReport[ 23 ]
      RptText += Space( 4 ) + "LANDSCAPE" + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 13 ] ) ) > 0
      RptText += Space( 4 ) + "PAPERSIZE " + aReport[ 13 ] + CRLF
   ENDIF

   IF Len( AllTrim( aReport[ 14 ] ) ) > 0
      RptText += Space( 4 ) + "IMAGE { " + AllTrim( aReport[ 14 ] ) + " , " + AllTrim( aReport[ 15 ] ) + " , " + AllTrim( aReport[ 16 ] ) + " , " + AllTrim( aReport[ 17 ] ) + " , " + AllTrim( aReport[ 18 ] ) + " }" + CRLF
   ENDIF

   RptText += "END REPORT" + CRLF

   MemoWrit( cReport + ".rpt", RptText )

   IF preview
      IF aRptNames[ nValue, 2 ] = "<ProjectFolder>\" .OR. Empty( aRptNames[ nValue, 2 ] )
         cTable := ProjectFolder + "\" + AllTrim( ReportEditor.Text_7.Value )  //verify
      ELSE
         cTable := aRptNames[ nValue, 2 ] + AllTrim( ReportEditor.Text_7.Value )  //verify
      ENDIF

      d := select()
      USE ( cTable ) NEW

      DO REPORT FORM &cReport
      USE

      Select( d )

      fErase( cReport + ".rpt" )
   ELSE
      HIDE WINDOW ReportEditor
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ReportCancel()
*------------------------------------------------------------*
   LOCAL cReport AS STRING := ProjectBrowser.xlist_4.Item( ProjectBrowser.xlist_4.Value )

   IF ! File( cReport )
      DeleteReport()
   ENDIF

   HIDE WINDOW ReportEditor

RETURN


*------------------------------------------------------------*
PROCEDURE NewReport()
*------------------------------------------------------------*
   LOCAL xRptName  AS STRING
   LOCAL x         AS NUMERIC
   LOCAL xPos      AS NUMERIC
   LOCAL cPath     AS STRING
   LOCAL xPosRpt   AS NUMERIC

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check if there is an active project ?
   IF Chk_Prj()
      RETURN
   ENDIF

   ZeroaReport()

   xRptName := InputBox( "Enter Name:", "New Report", "" )
   xPos     := Rat( "\", xRptName )

   IF xPos > 0
      xRptName := SubStr( xRptName, xPos + 1, Len( xRptName ) )
      cPath    := SubStr( xRptName, 1, xPos )
   ELSE
      cPath    := ""
   ENDIF

   IF Empty( xRptName )
      RETURN
   ENDIF

   aData[ _REPORTPATH ] := GetCurrentFolder()

   SavePreferences()

   IF Empty( cPath ) .OR. cPath == ProjectFolder + "\"
      cPath := "<ProjectFolder>\"
   ENDIF

   IF Len( xRptName ) # 0
      IF ProjectBrowser.xlist_4.ItemCount = 0
         ProjectBrowser.xlist_4.AddItem( xRptName + ".rpt" )
         ProjectBrowser.xlist_4.Value := ProjectBrowser.xlist_4.ItemCount
         aAdd( aRptNames, { xRptName + ".rpt", cPath } )
      ELSE
         FOR x := 1 TO Len( aRptNames )
             IF Upper( xRptName ) + ".RPT" = Upper( aRptNames[ x, 1 ] )
                msgstop( "Report Already in Project" )
                RETURN
             ENDIF
         NEXT x

         aAdd( aRptNames, { xRptName + ".rpt", cPath } )

         aSort2( aRptNames )

         ProjectBrowser.xlist_4.DeleteAllitems

         FOR x := 1 TO Len( aRptNames )

             ProjectBrowser.xlist_4.AddItem( aRptNames[ x, 1 ] )

             IF aRptNames[ x, 1 ] = xRptName
                xPosRpt := x
             ENDIF

         NEXT x

         ProjectBrowser.xlist_4.Value := xPosRpt
      ENDIF

      SaveModules()

      IF File( xRptName + ".rpt" )
         LoadReport()
      ELSE
         preport( xRptName )
      ENDIF

   ENDIF

RETURN


*------------------------------------------------------------*
FUNCTION Op_HF( Arg1 AS STRING, Act AS LOGICAL, ta AS STRING )
*------------------------------------------------------------*
   * if act =.F. remove ELSE add Apex
   LOCAL acp AS ARRAY := { '"', "'", "[", "]", "{", "}" }


   Arg1 := AllTrim( Arg1 )
   act  := iif( act == NIL, .F., act )
   ta   := iif( ta  == NIL, '"', ta  )

   IF aScan( acp, Left( Arg1, 1 ) ) > 0          // Check For left
      Arg1 := SubStr( Arg1, 2 )                  // Remove Left
   ENDIF

   IF aScan( acp, Right( Arg1, 1 ) ) > 0         // Check For Right
      Arg1 := SubStr( Arg1, 1, Len( Arg1 ) - 1 ) // Remove Right
   ENDIF

   IF Act
      DO CASE
         CASE ta = "{"  ; Arg1 := ta + Arg1 + "}"
         CASE ta = "["  ; Arg1 := ta + Arg1 + "]"
         CASE ta = "("  ; Arg1 := ta + Arg1 + ")"
         OTHERWISE      ; Arg1 := ta + Arg1 + ta
      ENDCASE

   ENDIF
   // MsgBox(Arg1,"Arg1"+IF(act," ADD"," REMOVE"))

RETURN( Arg1 )
