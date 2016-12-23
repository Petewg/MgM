#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW ObjectInspector

*-----------------------------------------------------------------------------*
Procedure SizeControl()
*-----------------------------------------------------------------------------*
   LOCAL i             AS NUMERIC
   LOCAL iRow          AS NUMERIC
   LOCAL iCol          AS NUMERIC
   LOCAL iWidth        AS NUMERIC
   LOCAL iHeight       AS NUMERIC
   LOCAL eHeight       AS NUMERIC
   LOCAL eWidth        AS NUMERIC
   LOCAL j             AS NUMERIC
   LOCAL k             AS NUMERIC
   LOCAL z             AS NUMERIC
   LOCAL x             AS NUMERIC
   LOCAL y             AS USUAL
   LOCAL nPos          AS NUMERIC
   LOCAL xx            AS NUMERIC
   LOCAL ControlHandle AS USUAL
   LOCAL AbortSize     AS LOGICAL := .F.
   LOCAL ControlIndex  AS NUMERIC
   LOCAL h             AS USUAL   := GetFormHandle( DesignForm )                                  // Form Handle
   LOCAL l             AS NUMERIC := Len( _HMG_aControlHandles )
   LOCAL BaseRow       AS NUMERIC := GetWindowRow( h )
   LOCAL BaseCol       AS NUMERIC := GetWindowCol( h )
   LOCAL BaseWidth     AS NUMERIC := GetWindowWidth( h )
   LOCAL BaseHeight    AS NUMERIC := GetWindowHeight( h )
   LOCAL TitleHeight   AS NUMERIC := GetTitleHeight()
   LOCAL BorderWidth   AS NUMERIC := GetBorderWidth()
   LOCAL BorderHeight  AS NUMERIC := GetBorderHeight()
   LOCAL gf            AS USUAL     //? VarType
   LOCAL IsInTab       AS LOGICAL
   LOCAL TabRow        AS NUMERIC
   LOCAL TabCol        AS NUMERIC
   LOCAL TabWidth      AS NUMERIC
   LOCAL TabHeight     AS NUMERIC
   LOCAL isComboBoxEx  AS LOGICAL := .F.
   LOCAL xTypeCombo    AS LOGICAL := .F.
   LOCAL xHeight       AS NUMERIC

   ProcessFrameOk := .F.
   lUpdate        := .F.

   SizeFrame()

   IF ProcessFrameOk
      RETURN
   ENDIF

   gf := GetFocus()

   IF gf != h

      i := aScan( _HMG_aControlHandles, gf )
      // MsgBox( "i="+str(i) )
      // MsgBox( "lastcontrol=" + _HMG_aControlNames[l] + "handle= " + Str( _HMG_aControlHandles[ l ] ) )

      IF i = 0
         FOR xx := 1 TO Len( _HMG_aControlHandles )
             IF _HMG_aControlParentHandles[ xx ] = h
                IF ValType( _HMG_aControlRangeMax[ xx ] ) = "N"
                   IF _hmg_aControlRangeMax[ xx ] = GetFocus()
                      i            := xx
                      isComboBoxEx := .T.
                      EXIT
                   ENDIF
                ENDIF
             ENDIF
         NEXT xx
      ENDIF

      y := ObjectInspector.xGrid_1.Value

      IF i > 0
         x := i   // add by Pier 2006.5.21
         IF _HMG_aControlNames[ i ] = "Statusbar" .OR. ;
            _HMG_aControlNames[ i ] = "Timer"  .OR. ;
            _HMG_aControlNames[ i ] = "Toolbar"

            RETURN
         ENDIF

         ControlIndex := i

         IF _HMG_aControlType [i] == "TAB"

            iRow    := _HMG_aControlRow[ i ]
            iCol    := _HMG_aControlCol[ i ]
            iWidth  := _HMG_aControlWidth[ i ]
            iHeight := _HMG_aControlheight[ i ]

            InteractiveSize()

            cHideControl( _HMG_aControlhandles[ i ] )
            cShowControl( _HMG_aControlhandles[ i ] )

            eHeight := GetWindowHeight( _HMG_aControlhandles[ i ] )
            eWidth  := GetWindowWidth( _HMG_aControlhandles[ i ] )

            FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

                FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )

                   IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"
                      ControlHandle := _HMG_aControlPageMap[ i, j, k ]
                   ELSE
                      ControlHandle := _HMG_aControlPageMap[ i, j, k, 1 ]
                   ENDIF

                   z := aScan( _HMG_aControlHandles, ControlHandle )

                   IF z == 0
                      z := FindRadioName( ControlHandle )
                   ENDIF

                   IF z > 0
                      IF _HMG_aControlRow[ z ] + _HMG_aControlHeight[ z ] > iRow + eHeight
                         AbortSize := .T.
                         EXIT
                      ENDIF

                      IF _HMG_aControlCol[ z ] + _HMG_aControlWidth[ z ] > iCol + eWidth
                         AbortSize := .T.
                         EXIT
                      ENDIF

                   ENDIF

                NEXT k

               IF AbortSize
                  PlayHand()

                  _SetControlSizePos( _HMG_aControlnames[ i ], "Form_1", iRow, iCol, iWidth, iHeight )

                  cHideControl( _HMG_aControlhandles[ i ] )
                  cShowControl( _HMG_aControlhandles[ i ] )

                  EXIT
               ENDIF
            NEXT j

            IF AbortSize == .F.
               _HMG_aControlWidth[ ControlIndex ]  := eWidth
               _HMG_aControlHeight[ ControlIndex ] := eHeight
            ENDIF

         ELSE

            iRow    := _HMG_aControlRow[ ControlIndex ]
            iCol    := _HMG_aControlCol[ ControlIndex ]
            iWidth  := _HMG_aControlWidth[ ControlIndex ]
            iHeight := _HMG_aControlheight[ ControlIndex ]
            IsInTab := .F.

            FOR i := 1 TO Len( _HMG_aControlHandles )

                IF _HMG_aControlType[ i ] == "TAB"

                   FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

                       FOR k := 1 TO Len( _HMG_aControlPageMap[ i, j ] )

                           IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"

                              ControlHandle := _HMG_aControlPageMap[ i, j, k ]

                              IF ControlHandle == GetFocus()
                                 IsInTab   := .T.
                                 TabRow    := _HMG_aControlRow[ i ]
                                 TabCol    := _HMG_aControlCol[ i ]
                                 TabWidth  := _HMG_aControlWidth[ i ]
                                 TabHeight := _HMG_aControlHeight[ i ]
                                 EXIT
                              ENDIF
                           ENDIF

                      NEXT k

                      IF IsInTab
                         EXIT
                      ENDIF
                   NEXT j
                ENDIF

                IF IsInTab
                   EXIT
                ENDIF

            NEXT i

            IF xTypeControl( _HMG_aControlNames[ ControlIndex ] ) = "COMBOBOXEX" .OR. ;
               xTypeControl( _HMG_aControlNames[ ControlIndex ] ) = "COMBOBOX"

               xHeight    := _HMG_aControlHeight[ ControlIndex ]

               InteractiveSizeHandle( _HMG_aControlHandles[ ControlIndex ] )

               xTypeCombo := .T.
            ELSE
               InteractiveSize()
            ENDIF

            h := GetFocus()
            // MsgBox( "Control Handle = "+ Str( h ) )

            IF xTypeCombo
               eHeight := _HMG_MouseRow - _HMG_aControlRow[ ControlIndex ]
               // MsgBox( "eHeight= " + Str( eHeight ) + " _HMG_MouseRow= " + Str( _HMG_MouseRow )+ " GetWindowHeight( h )= " + Str( GetWindowHeight( h ) ) + " _HMG_aControlRow[ ControlIndex]= " +str( _HMG_aControlRow [ControlIndex ] ) )

               eHeight := iif( eHeight < 20, xHeight, eHeight ) // workaround
            ELSE
               eHeight := GetWindowHeight( h )
              // MsgBox( "_HMG_MouseRow= " + Str( _HMG_MouseRow ) + " GetWindowHeight( h )= " + Str( GetWindowHeight( h ) ) )
            ENDIF

            eWidth                              := GetWindowWidth( h )
            _HMG_aControlWidth[ ControlIndex ]  := eWidth
            _HMG_aControlHeight[ ControlIndex ] := eHeight

            cHideControl( _HMG_aControlhandles[ ControlIndex ] )
            cShowControl( _HMG_aControlhandles[ ControlIndex ] )

            IF IsInTab

               IF ( iCol + eWidth  > TabCol + TabWidth  )  .OR. ;
                  ( iRow + eHeight > TabRow + TabHeight )

                  PlayHand()

                  _SetControlSizePos( _HMG_aControlnames[ ControlIndex ], "Form_1", iRow-tabrow, iCol-tabcol, iWidth, iHeight )

                  cHideControl( _HMG_aControlhandles[ ControlIndex ] )
                  cShowControl( _HMG_aControlhandles[ ControlIndex ] )

                  _HMG_aControlWidth[ControlIndex]  := iWidth
                  _HMG_aControlHeight[ControlIndex] := iHeight

               ENDIF

            ENDIF

         ENDIF

         SavePropControl( _HMG_aControlNames[ x ], ltrim( Str( eWidth  ) ), "Width"  )
         SavePropControl( _HMG_aControlNames[ x ], ltrim( Str( eHeight ) ), "Height" )

         cpreencheGrid(_HMG_aControlNames[x] )

         ObjectInspector.xGrid_1.Value := y
         // add by Pier 2006.5.21 Stop
      ENDIF
   ENDIF

   lChanges := .T.
   lUpdate  := .T.

   // SetProperty( "FORM_1", "TITLE", "LUPDATE = TRUE-2 " )
RETURN


*-----------------------------------------------------------------------------*
procedure SizeFrame()
*-----------------------------------------------------------------------------*
   LOCAL h            AS USUAL     := GetFormHandle( DesignForm )  // Form Handle
   LOCAL BaseRow      AS NUMERIC   := GetWindowRow( h )
   LOCAL BaseCol      AS NUMERIC   := GetWindowCol( h )
   LOCAL BaseWidth    AS NUMERIC   := GetWindowWidth( h )
   LOCAL BaseHeight   AS NUMERIC   := GetWindowHeight( h )
   LOCAL TitleHeight  AS NUMERIC   := GetTitleHeight()
   LOCAL BorderWidth  AS NUMERIC   := GetBorderWidth()
   LOCAL BorderHeight AS NUMERIC   := GetBorderHeight()
   LOCAL SupMin       AS NUMERIC   := 99999999
   LOCAL iMin         AS NUMERIC   := 0
   LOCAL i            AS NUMERIC
   LOCAL y            AS USUAL     //? VarType
   LOCAL eHeight      AS NUMERIC
   LOCAL eWidth       AS NUMERIC
   LOCAL ControlIndex AS NUMERIC
   LOCAL iRow         AS NUMERIC
   LOCAL iCol         AS NUMERIC

   _HMG_MouseRow := _HMG_MouseRow - BaseRow - TitleHeight - BorderHeight
   _HMG_MouseCol := _HMG_MouseCol - BaseCol - BorderWidth

   y             := ObjectInspector.xGrid_1.Value

   FOR i := 1 TO Len( _HMG_aControlHandles )

       *************
       //if ValType(_HMG_aControlHandles[i]) = "A"
       //   MsgBox("value== "+str( _HMG_aControlHandles[i][1])+"name= "+_HMG_aControlNames[i])
       //   MsgBox("row= "+str( _HMG_aControlRow [i] )+ " height= "+str(_HMG_aControlHeight [i] )+" col= "+str( _HMG_aControlCol [i] ) +" width= "+ str( _HMG_aControlWidth [i] ) )
       //   MsgBox(" mouse row= " +str( _HMG_MouseRow) +" mouse col = " +str(_HMG_MouseCol) )
       //ELSE
       //   MsgBox("value== "+str( _HMG_aControlHandles[i])+"name= "+_HMG_aControlNames[i])
       //ENDIF
       **********

       IF ValType( _HMG_aControlHandles[ i ] ) = "A"
       
           IF    _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )          .AND. ;
                             IsWIndowVisible( _HMG_aControlHandles[ i ][ 1 ] )             
                 IF ( _HMG_MouseRow >= _HMG_aControlRow[ i ] )                            .AND. ;
                    ( _HMG_MouseRow <= _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] ) .AND. ;
                    ( _HMG_MouseCol >= _HMG_aControlCol[ i ] )                            .AND. ;
                    ( _HMG_MouseCol <= _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] ) 

                  //  MsgBox("control="+_HMG_aControlNames[i])

                      IF SupMin > _HMG_aControlHeight[ i ]  * _HMG_aControlWidth[ i ]

                         SupMin := _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
                         iMin   := i
                      // MsgBox( "Control iMin=" + _HMG_aControlNames[ i ] )
                     ENDIF
                 ENDIF
           ENDIF       
       ELSE
          
          IF  _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )          .AND.  ;
                          IsWIndowVisible( _HMG_aControlHandles[ i ] )
             //msgbox('nr = ' + str(i) + ' name = ' +  _HMG_aControlNames[ i ] ) 
          	 IF ( _HMG_MouseRow >= _HMG_aControlRow[ i ] )                            .AND.  ;
                ( _HMG_MouseRow <= _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] ) .AND.  ;
                ( _HMG_MouseCol >= _HMG_aControlCol[ i ] )                            .AND.  ;
                ( _HMG_MouseCol <= _HMG_aControlCol[ i ] + _HMG_aControlWidth [ i ] ) 

              //  MsgBox( "Control=" + _HMG_aControlNames[ i ] )

                  IF SupMin > _HMG_aControlHeight[ i ]  * _HMG_aControlWidth[ i ]

                     SupMin := _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
                     iMin   := i
                  // MsgBox( "Control iMin=" + _HMG_aControlNames[ i ] )
                  ENDIF
             ENDIF
          ENDIF
          
       ENDIF

   NEXT i

   IF iMin != 0 .AND. _HMG_aControlType[ iMin ] == "FRAME"
      i := iMin

      InterActiveSizeHandle( _HMG_aControlHandles[ i ] )

      CHideControl( _HMG_aControlHandles[ i ] )
      CShowControl( _HMG_aControlHandles[ i ] )

      _HMG_aControlWidth[ i ]  := GetWindowWidth( _HMG_aControlhandles[ i ] )
      _HMG_aControlHeight[ i ] := GetWindowHeight( _HMG_aControlhandles[ i ] )

      SavePropControl( _HMG_aControlNames[i], Ltrim( Str( _HMG_aControlWidth[ i ] ) ), "Width" )
      SavePropControl( _HMG_aControlNames[i], Ltrim( Str( _HMG_aControlHeight[ i ] ) ), "Height" )

      lUpdate := .T.

      cpreencheGrid( _HMG_aControlNames[ i ] )

      ObjectInspector.xGrid_1.Value := y
      lChanges                      := .T.
      ProcessFrameOk                := .T.
   ENDIF

   IF iMin != 0 .AND. _HMG_aControlType [ iMin ] == "RADIOGROUP"

      i            := iMin
      ControlIndex := i
      iRow         := _HMG_aControlRow[ ControlIndex ]
      iCol         := _HMG_aControlCol[ ControlIndex ]

      InteractiveSize()

      h                                   := GetFocus()
      eHeight                             := GetWindowHeight( h )
      eWidth                              := GetWindowWidth( h )
      _HMG_aControlWidth[ ControlIndex ]  := eWidth
      _HMG_aControlHeight[ ControlIndex ] := eHeight

      _SetControlSizePos( _HMG_aControlNames[ ControlIndex ], "Form_1" , iRow - ( _HMG_aControlContainerRow[ ControlIndex ] ), iCol - ( _HMG_aControlContainerRow[ControlIndex] ), eWidth, eHeight )

      cHideControl( _HMG_aControlhandles[ ControlIndex, 1 ] )
      cShowControl( _HMG_aControlhandles[ ControlIndex, 1 ] )

      SavePropControl( _HMG_aControlNames[ i ], Ltrim( Str( eWidth  ) ), "Width" )
      SavePropControl( _HMG_aControlNames[ i ], Ltrim( Str( eHeight ) ), "Height" )

      lUpdate := .T.

      cpreencheGrid( _HMG_aControlNames[ i ] )

      ObjectInspector.xGrid_1.Value := y
      lChanges                      := .T.
      ProcessFrameOk                := .T.
   ENDIF

   lUpdate := .T.

   // SetProperty( "FORM_1", "TITLE", "LUPDATE = TRUE-3" )
RETURN
