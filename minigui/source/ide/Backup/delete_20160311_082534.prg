#include "minigui.ch"
#include "ide.ch"

#define msgstop( c ) MsgStop( c, 'HMGS-IDE', , .F. )

#define MAX_CONTROL_COUNT 512

DECLARE WINDOW ObjectInspector

*------------------------------------------------------------*
PROCEDURE xDeleteControl()
*------------------------------------------------------------*
   LOCAL cName AS STRING := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

   //   MsgBox("XDELETE")
   IF ! isWindowActive(Form_1)
      MsgStop( "No Active Form!" )
      RETURN
   ENDIF

   IF cName = "Form"
      MsgStop( "No Control Selected!" )
      RETURN
   ENDIF

   DoMethod( "FORM_1", cName, "SETFOCUS" )

   DeleteControl()

RETURN


*------------------------------------------------------------*
PROCEDURE DeleteControl()
*------------------------------------------------------------*
   LOCAL i               AS NUMERIC
   LOCAL j               AS NUMERIC
   LOCAL k               AS NUMERIC
   LOCAL x               AS NUMERIC
   LOCAL z               AS NUMERIC
   LOCAL h               AS NUMERIC
   LOCAL l               AS NUMERIC
   LOCAL BaseRow         AS NUMERIC
   LOCAL BaseCol         AS NUMERIC
   LOCAL BaseWidth       AS NUMERIC
   LOCAL BaseHeight      AS NUMERIC
   LOCAL TitleHeight     AS NUMERIC
   LOCAL BorderWidth     AS NUMERIC
   LOCAL BorderHeight    AS NUMERIC
   LOCAL cName           AS STRING
   LOCAL xResp           AS LOGICAL   //? Invalid Hungarian
   LOCAL xObject         AS NUMERIC
   LOCAL nHandle         AS NUMERIC
   LOCAL gf              AS USUAL     //? VarType
   LOCAL nPos            AS NUMERIC
   LOCAL xx              AS NUMERIC
   LOCAL isComboBoxEx    AS LOGICAL := .F.
   LOCAL xPosBrw         AS NUMERIC

   ProcessFrameOk := .F.

   // MsgBox("DELETE")
   inDelete := .T.

   IF ! isWindowActive( Form_1 )
      INDELETE := .F.
      RETURN
   ENDIF

   h := GetFormHandle( DesignForm )
   l := Len( _HMG_aControlHandles )

   BaseRow        := GetWindowRow( h )
   BaseCol        := GetWindowCol( h )
   BaseWidth      := GetWindowWidth( h )
   BaseHeight     := GetWindowHeight( h )
   TitleHeight    := GetTitleHeight()
   BorderWidth    := GetBorderWidth()
   BorderHeight   := GetBorderHeight()

   DeleteFrame()

   IF ProcessFrameOk
      INDELETE := .F.
      RETURN
   ENDIF

   gf := GetFocus()

   IF gf != h
      i := aScan( _HMG_aControlHandles, gf )

      IF i = 0
         FOR xx := 1 TO Len(_HMG_aControlHandles )

             IF _HMG_aControlParentHandles[ xx ] = h

                IF ValType( _HMG_aControlRangeMax[ xx ] ) = "N"

                   IF _HMG_aControlRangeMax[ xx ] = GetFocus()
                      i            := xx
                      isComboBoxEx := .T.
                      // MsgBox( 'delete combo' )
                      EXIT
                   ENDIF

                ENDIF

             ENDIF

         NEXT xx

      ENDIF

      IF i > 0

         cName :=  _HMG_aControlNames[ i ]
         IF aData[ _DISABLEWARNINGS ] = ".F."
            xResp := MsgYesNo( 'Are You Sure?', 'Delete Control ' + cName )
         ELSE
            xResp := .T.
         ENDIF

         IF xResp = .F.
            INDELETE := .F.
            RETURN
         ENDIF

         IF xTypeControl( cName ) == "BROWSE"
            aAdd( aTempDeletedControls, cName )

           /* Start Code Arcangelo Molinaro 15/12/2007 */

            SavePath(    cName, "" )
            SaveAlias(   cName, "" )
            SaveDbfname( cName, "" )
            SaveStruct(  cName, "" )

          /* End Code Arcangelo Molinaro 15/12/2007 */

         ENDIF

         IF xTypeControl( cName ) == "TBROWSE"
            xPosBrw := aScan( aTbrowse[1], cName )

            aDel( aTbrowse[1], xPosBrw )
            aSize( aTbrowse[1],( Len( aTbrowse[ 1 ] ) - 1 ) )

            aDel( aOtbrowse[1], xPosBrw )
            aSize( aOtbrowse[1],( Len(aOtbrowse[ 1 ] ) - 1 ) )

         ENDIF

         xDelControl( cName )

         FOR xObject := 2 TO ObjectInspector.xCombo_1.ItemCount
             IF ObjectInspector.xCombo_1.Item( xObject ) = cName
                ObjectInspector.xCombo_1.DeleteItem( xObject )
             ENDIF
         NEXT

         ObjectInspector.xCombo_1.Value := 1
         xpreencheGrid()

         IF _HMG_aControlType[ i ] == 'TAB'
            // MsgBox("control to delete is tab")
            z := i
            DestroyWindow( _HMG_aControlHandles[ i ] )

            FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

               FOR k := 1 TO Len( _HMG_aControlPageMap[ i ,j ] )

                  IF ValType( _HMG_aControlPageMap[ i , j, k ] ) # 'A'
                     DestroyWindow( _HMG_aControlPageMap[ i, j, k ] )
                     x := aScan( _HMG_aControlHandles , _HMG_aControlPageMap[ i, j, k ] )
                  ELSE
                     FOR l := 1 TO Len( _HMG_aControlPageMap[ i, j, k ]    )
                         DestroyWindow( _HMG_aControlPageMap[ i, j, k, l ] )
                     next l
                     x := FindRadioName( _HMG_aControlPageMap[ i, j, k, 1 ] )
                  ENDIF

                  **************************************
                  cName := _HMG_aControlNames[ x ]

                  xDelControl( cName )

                  FOR xObject := 2 TO ObjectInspector.xCombo_1.ItemCount
                      IF ObjectInspector.xCombo_1.Item( xObject ) = cName
                         ObjectInspector.xCombo_1.DeleteItem( xObject )
                      ENDIF
                  NEXT xObject

                  ObjectInspector.xCombo_1.Value := 1
                  xpreencheGrid()

                  ***************************************
                  IF x > 0
                     _HMG_aControlDeleted           [x] := .T.
                     _HMG_aControlType              [x] := ""
                     _HMG_aControlNames             [x] := ""
                     _HMG_aControlHandles           [x] := 0
                     _HMG_aControlParentHandles     [x] := 0
                     _HMG_aControlIds               [x] := 0
                     _HMG_aControlProcedures        [x] := ""
                     _HMG_aControlPageMap           [x] := {}
                     _HMG_aControlValue             [x] := NIL
                     _HMG_aControlInputMask         [x] := ""
                     _HMG_aControlLostFocusProcedure[x] := ""
                     _HMG_aControlGotFocusProcedure [x] := ""
                     _HMG_aControlChangeProcedure   [x] := ""
                     _HMG_aControlBkColor           [x] := NIL
                     _HMG_aControlFontColor         [x] := NIL
                     _HMG_aControlDblClick          [x] := ""
                     _HMG_aControlHeadClick         [x] := {}
                     _HMG_aControlRow               [x] := 0
                     _HMG_aControlCol               [x] := 0
                     _HMG_aControlWidth             [x] := 0
                     _HMG_aControlHeight            [x] := 0
                  ENDIF

               NEXT k

            NEXT j

            _HMG_aControlDeleted           [z] := .T.
            _HMG_aControlType              [z] := ""
            _HMG_aControlNames             [z] := ""
            _HMG_aControlHandles           [z] := 0
            _HMG_aControlParentHandles     [z] := 0
            _HMG_aControlIds               [z] := 0
            _HMG_aControlProcedures        [z] := ""
            _HMG_aControlPageMap           [z] := {}
            _HMG_aControlValue             [z] := NIL
            _HMG_aControlInputMask         [z] := ""
            _HMG_aControlLostFocusProcedure[z] := ""
            _HMG_aControlGotFocusProcedure [z] := ""
            _HMG_aControlChangeProcedure   [z] := ""
            _HMG_aControlBkColor           [z] := NIL
            _HMG_aControlFontColor         [z] := NIL
            _HMG_aControlDblClick          [z] := ""
            _HMG_aControlHeadClick         [z] := {}
            _HMG_aControlRow               [z] := 0
            _HMG_aControlCol               [z] := 0
            _HMG_aControlWidth             [z] := 0
            _HMG_aControlHeight            [z] := 0

         ELSE
            // MsgBox( "control to delete is not tab" )
            FOR j := 1 To Len( _HMG_aControlhandles )

                IF _HMG_aControlType [j] == 'TAB'

                   FOR k := 1 TO Len( _HMG_aControlPageMap[ j ] )

                       FOR x := 1 TO Len( _HMG_aControlPageMap[ j, k ] )

                           IF ValType( _HMG_aControlPageMap[ j, k, x ] ) # "A"  // not radiogroup
                              IF _HMG_aControlPageMap[ j, k, x ] == gf
                                 // MsgBox("control inside tab")
                                 _HMG_aControlPageMap[ j, k, x ] := 0
                              ENDIF
                           ELSE                                             // radiogroup
                              IF _HMG_aControlPageMap[ j, k, x, 1 ] == gf
                                 // MsgBox("control radiogroup inside tab")
                                 _HMG_aControlPageMap[ j, k, x ] := 0
                              ENDIF
                           ENDIF

                       NEXT x

                   NEXT k

               ENDIF

            NEXT j

            IF isComboBoxEx //? Same thing in both case is this a bug ?
               DoMethod( "FORM_1", _HMG_aControlNames[ i ], "RELEASE" )
            ELSE
               // MsgBox("deleting control "+ _HMG_aControlNames[i])               
                  DoMethod( "FORM_1", _HMG_aControlNames[ i ], "RELEASE" )
            ENDIF

            _HMG_aControlDeleted           [i] := .T.
            _HMG_aControlType              [i] := ""
            _HMG_aControlNames             [i] := ""
            _HMG_aControlHandles           [i] := 0
            _HMG_aControlParentHandles     [i] := 0
            _HMG_aControlIds               [i] := 0
            _HMG_aControlProcedures        [i] := ""
            _HMG_aControlPageMap           [i] := {}
            _HMG_aControlValue             [i] := NIL
            _HMG_aControlInputMask         [i] := ""
            _HMG_aControlLostFocusProcedure[i] := ""
            _HMG_aControlGotFocusProcedure [i] := ""
            _HMG_aControlChangeProcedure   [i] := ""
            _HMG_aControlBkColor           [i] := NIL
            _HMG_aControlFontColor         [i] := NIL
            _HMG_aControlDblClick          [i] := ""
            _HMG_aControlHeadClick         [i] := {}
            _HMG_aControlRow               [i] := 0
            _HMG_aControlCol               [i] := 0
            _HMG_aControlWidth             [i] := 0
            _HMG_aControlHeight            [i] := 0

         ENDIF

      ENDIF

   ENDIF

   InDelete := .F.

RETURN


*------------------------------------------------------------*
PROCEDURE DeleteFrame()
*------------------------------------------------------------*
   LOCAL h              AS NUMERIC := GetFormHandle( DesignForm )
   LOCAL BaseRow        AS NUMERIC := GetWindowRow( h )
   LOCAL BaseCol        AS NUMERIC := GetWindowCol( h )
   LOCAL BaseWidth      AS NUMERIC := GetWindowWidth( h )
   LOCAL BaseHeight     AS NUMERIC := GetWindowHeight( h )
   LOCAL TitleHeight    AS NUMERIC := GetTitleHeight()
   LOCAL BorderWidth    AS NUMERIC := GetBorderWidth()
   LOCAL BorderHeight   AS NUMERIC := GetBorderHeight()
   LOCAL SupMin         AS NUMERIC := 99999999
   LOCAL iMin           AS NUMERIC := 0
   LOCAL i              AS NUMERIC
   LOCAL cName          AS STRING
   LOCAL xResp          AS LOGICAL                                   //? Invalid Hungarian
   LOCAL xObject        AS NUMERIC                                   //? Invalid Hungarian

   _HMG_MouseRow := _HMG_MouseRow - BaseRow - TitleHeight - BorderHeight
   _HMG_MouseCol := _HMG_MouseCol - BaseCol - BorderWidth

   FOR i := 1 TO Len( _HMG_aControlHandles )
       IF ValType( _HMG_aControlHandles[ i ] ) = "A"
           IF      _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )     .AND. ;
                    IsWIndowVisible( _HMG_aControlHandles[ i, 1 ] )

             IF ( _HMG_MouseRow >= _HMG_aControlRow[ i ] )                             .AND. ;
                ( _HMG_MouseRow <= _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] )  .AND. ;
                ( _HMG_MouseCol >= _HMG_aControlCol[ i ] )                             .AND. ;
                ( _HMG_MouseCol <= _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] )   
           
                IF SupMin > _HMG_aControlHeight [i] * _HMG_aControlWidth [i]
                   SupMin := _HMG_aControlHeight [i] * _HMG_aControlWidth [i]
                   iMin := i
                ENDIF
             ENDIF
           ENDIF   
       ELSE
          IF     _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )          .AND. ;
                  IsWIndowVisible( _HMG_aControlHandles[ i ] )
             IF ( _HMG_MouseRow >= _HMG_aControlRow[ i ] )                            .AND. ;
                ( _HMG_MouseRow <= _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] ) .AND. ;
                ( _HMG_MouseCol >= _HMG_aControlCol[ i ] )                            .AND. ;
                ( _HMG_MouseCol <= _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] )  
            
                IF SupMin > _HMG_aControlHeight[ i ]  * _HMG_aControlWidth[ i ]
                   SupMin := _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
                   iMin := i
                ENDIF
             ENDIF
          ENDIF    
       ENDIF
   NEXT i

   IF iMin != 0 .AND. ( _HMG_aControlType[ iMin ] == "FRAME" .OR. _HMG_aControlType[ iMin ] == "RADIOGROUP" )

      cName :=  _HMG_aControlNames[ iMin ]

      IF aData[ _DISABLEWARNINGS ] = ".F."
         xResp := MsgYesNo( "Are You Sure?", "Delete Control " + cName )
      ELSE
         xResp := .T.
      ENDIF

      ProcessFrameOk := .T.

      IF xResp = .F.
          INDELETE := .F.
          RETURN
      ENDIF

      i := iMin

      IF _HMG_aControlType[ iMin ] == "FRAME"
          InterActiveCloseHandle( _HMG_aControlHandles[ i ] )

      ELSEIF _HMG_aControlType[ iMin ] == "RADIOGROUP"
          InterActiveCloseHandle( _HMG_aControlHandles[ i, 1 ] )
      ENDIF

      ******************************************************
      FOR xObject := 2 TO ObjectInspector.xCombo_1.ItemCount
          IF ObjectInspector.xCombo_1.Item( xObject ) = cName
             ObjectInspector.xCombo_1.DeleteItem( xObject )
          ENDIF
      NEXT xObject

      xDelControl( cName )

      ObjectInspector.xCombo_1.Value := 1
      xpreencheGrid()

      IF _IsControlDefined( cName, "Form_1" )
         DoMethod( "Form_1", cName, "Release" )
      ENDIF

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE xDelControl( cName AS STRING )
*------------------------------------------------------------*
   LOCAL xValor AS NUMERIC
   LOCAL xPos   AS NUMERIC := xControle( AllTrim( cName ) )

   aDel( xArray, xPos )

   xArray[ MAX_CONTROL_COUNT ] := {}

   FOR xValor := 1 TO MAX_CONTROL_COUNT
       aAdd( xArray[ MAX_CONTROL_COUNT ], "" )
       ************
       * IF xArray[xvalor,3] # ""
       *      MsgBox(xArray[xvalor,3],str(xvalor))
       * ENDIF
       *********
   NEXT xValor

   nTotControl -= 1
   lChanges := .T.

RETURN
