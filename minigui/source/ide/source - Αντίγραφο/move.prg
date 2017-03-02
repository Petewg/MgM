#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW ObjectInspector

*------------------------------------------------------------*
PROCEDURE MoveControl()
*------------------------------------------------------------*
   LOCAL i              AS NUMERIC
   LOCAL iRow           AS NUMERIC
   LOCAL iCol           AS NUMERIC
   LOCAL iWidth         AS NUMERIC
   LOCAL iHeight        AS NUMERIC
   LOCAL j              AS NUMERIC
   LOCAL k              AS NUMERIC
   LOCAL l              AS NUMERIC
   LOCAL z              AS NUMERIC
   LOCAL x                                //? Not used
   LOCAL y              AS NUMERIC
   LOCAL u              AS NUMERIC
   LOCAL eRow           AS NUMERIC
   LOCAL eCol           AS NUMERIC
   LOCAL dRow           AS NUMERIC
   LOCAL dCol           AS NUMERIC
   LOCAL nPos           AS NUMERIC
   LOCAL xx             AS NUMERIC
   LOCAL h              AS NUMERIC := GetFormHandle( DesignForm )
   LOCAL BaseRow        AS NUMERIC := GetWindowRow( h )
   LOCAL BaseCol        AS NUMERIC := GetWindowCol( h )
   LOCAL BaseWidth      AS NUMERIC := GetWindowWidth( h )
   LOCAL BaseHeight     AS NUMERIC := GetWindowHeight( h )
   LOCAL TitleHeight    AS NUMERIC := GetTitleHeight()
   LOCAL BorderWidth    AS NUMERIC := GetBorderWidth()
   LOCAL BorderHeight   AS NUMERIC := GetBorderHeight()
   LOCAL MenuHeight     AS NUMERIC := iif( Len( amenu ) > 0, GetMenuBarHeight(), 0 )
   LOCAL CurrentPage    AS USUAL              //? VarType
   LOCAL IsInTab        AS LOGICAL
   LOCAL fo             AS USUAL              //? VarType
   LOCAL TabRow         AS NUMERIC
   LOCAL TabCol         AS NUMERIC
   LOCAL TabWidth       AS NUMERIC
   LOCAL TabHeight      AS NUMERIC
   LOCAL CurFocus       AS USUAL              //? VarType
   LOCAL ControlHandle  AS NUMERIC
   LOCAL OkToSave       AS LOGICAL := .F.
   LOCAL lRadio         AS LOGICAL := .F.
   LOCAL isComboBoxEx   AS LOGICAL := .F.
   LOCAL cResp          AS ARRAY              //? Invalid Hungarian
   LOCAL TabID          AS NUMERIC


  // MsgBox("MOVE")

   ProcessFrameOk  := .F.

   l               := Len( _HMG_aControlHandles )
   fo              := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
   i               := aScan( _HMG_aControlhandles , GetFocus() )

   IF i > 0
      IF _HMG_aControlNames[ i ] = "Statusbar" .OR. _HMG_aControlNames[ i ] = "Timer" .OR. _HMG_aControlNames[ i ] = "Toolbar"
         RETURN
      ENDIF
   ENDIF

   nPos := MoveFrame()

   IF ProcessFrameOk .AND. nPos = NIL
      // MsgBox("RETURN after move frame is ok" )
      RETURN
   ENDIF

   CurFocus := GetFocus()

   IF CurFocus != h
      lUpdate := .F.
      IF nPos # nil .AND. i # 0
         i := nPos
         // MsgBox('# NIL '+ Str( GetFocus() ) )
         DoMethod( "Form_1", _HMG_aControlNames[ i ], "SETFOCUS" )
         CurFocus := GetFocus()
      ELSE
         i := aScan( _HMG_aControlhandles , CurFocus )
      ENDIF

      y := ObjectInspector.xGrid_1.Value
      // MsgBox(str(i))
      // MsgBox("value0= " + Str( i ) ) //_HMG_aControlNames[ i ] )

      IF i = 0
         //a := ""
         FOR xx := 1 TO Len( _HMG_aControlhandles )
             IF _HMG_aControlParenthandles[ xx ] = h

                //a := a + str(xx) +" "+_HMG_aControlnames[xx]+ " "+str(_HMG_aControlhandles[xx])+" "+str( _HMG_aControlParenthandles[xx])+" "+str( _hmg_acontrolrangemax[xx])+CRLF
                // MsgBox(a)
                IF ValType( _HMG_aControlRangeMax[ xx ] ) = "N"
                   IF _HMG_aControlRangeMax[ xx ] = GetFocus()
                      i := xx
                      //InterActiveMoveHandle(_HMG_aControlhandles[xx])
                      isComboBoxEx := .T.
                      EXIT
                   ENDIF
                ENDIF
             ENDIF
         NEXT xx
      ENDIF

      IF i > 0
         x := i // add by Pier 2006.5.21

         lUpdate := .T.

         cpreencheGrid( _HMG_aControlNames[ i ] )

         // MsgBox( _HMG_aControlType[i] +" "+_HMG_aControlNames[i] )
         IF _HMG_aControlType[ i ] == "TAB"

            CurrentPage := _GetValue( _HMG_aControlNames[ i ], "Form_1" )

            iRow := _HMG_aControlRow[ i ]
            iCol := _HMG_aControlCol[ i ]

            InterActiveMove()
            cHideControl( _HMG_aControlHandles[ i ] )
            // cShowControl( _HMG_aControlhandles[i] )

            eRow := GetWindowRow( _HMG_aControlHandles[ i ] ) - BaseRow - TitleHeight - BorderHeight - MenuHeight
            eCol := GetWindowCol( _HMG_aControlHandles[ i ] ) - BaseCol - BorderWidth

            IF lsnap
               eRow := SnapMovedTabRow( i, eRow )  //
               eCol := SnapMovedTabCol( i, eCol )  //
            ENDIF

            _SetControlSizePos( _HMG_aControlNames[ i ], "Form_1", eRow, eCol, _HMG_aControlWidth[ i ] , _HMG_aControlHeight[ i ] ) //

            cShowControl( _HMG_aControlHandles[ i ] ) //

            _HMG_aControlRow[ i ] := eRow
            _HMG_aControlCol[ i ] := eCol

            dRow := eRow - iRow
            dCol := eCol - iCol
            //  MsgBox(_HMG_aControlNames[i] )
            //  MsgBox(ltrim(str( _HMG_aControlCol[i]))+"Col"+CRLF+ ltrim(str( _HMG_aControlRow[i]))+"Row")
            SavePropControl( _HMG_aControlNames[ i ], ltrim( Str( _HMG_aControlCol[ i ] ) ), "Col" )
            SavePropControl( _HMG_aControlNames[ i ], ltrim( Str( _HMG_aControlRow[ i ] ) ), "Row" )

            lUpdate := .T.

            cpreencheGrid( _HMG_aControlNames[ i ] )

            ObjectInspector.xGrid_1.Value := y

            FOR j := 1 To Len( _HMG_aControlPageMap[ i ] )

               FOR k := 1 To Len( _HMG_aControlPageMap[ i, j ] )

                  IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"
                     ControlHandle := _HMG_aControlPageMap[ i, j, k ]
                  ELSE
                     ControlHandle := _HMG_aControlPageMap[ i, j, k, 1 ]
                     lRadio        := .T.
                     //  MsgBox("is radio")
                  ENDIF
                  // MsgBox("controlhandle= " + Str( controlhandle ) )

                  IF ControlHandle <> 0

                     z := aScan( _HMG_aControlHandles, ControlHandle )
                     // MsgBox("z= "+str(z) )

                     IF z = 0
                        z := FindRadioName( ControlHandle )
                     ENDIF

                     IF z > 0
                        // MsgBox("z= "+str(z) )
                        u := z // add by Pier 2006.5.21
                        // MsgBox("acontrolrow= "+str( _HMG_aControlRow[z])+CRLF+"drow= "+str(drow)+CRLF+"HMGCONTAINERROW= "+STR( _HMG_aControlContainerRow[z])+CRLF+"erow= "+str(erow), _HMG_aControlnames[z] )
                        // MsgBox("acontrolCOL= "+str( _HMG_aControlCOL[z])+CRLF+"dCOL= "+str(dCOL)+CRLF+"HMGCONTAINERCOL= "+STR( _HMG_aControlContainerCOL[z])+CRLF+"ecol= "+str(ecol), _HMG_aControlnames[z] )
                        // changed by walter 2006-09-07
                        IF lSnap = .F.
                            // MsgBox("lsnap = .F.")
                           _SetControlSizePos( _HMG_aControlnames[ z ], "Form_1", _HMG_aControlRow[ z ] - eRow, _HMG_aControlCol[ z ] - eCol, _HMG_aControlWidth[ z ] , _HMG_aControlHeight[ z ] )
                        ELSE
                            // MsgBox("lsnap = .T.")
                           _SetControlSizePos( _HMG_aControlnames[ z ], "Form_1", _HMG_aControlRow[ z ] + dRow - eRow, _HMG_aControlCol[ z ] + dCol - eCol , _HMG_aControlWidth[ z ] , _HMG_aControlHeight[ z ] )
                        ENDIF

                        IF lRadio = .F.
                           _HMG_aControlRow[ z ] := GetWindowRow( _HMG_aControlhandles[ z ] ) - BaseRow - TitleHeight - BorderHeight - MenuHeight
                           _HMG_aControlCol[ z ] := GetWindowCol( _HMG_aControlhandles[ z ] ) - BaseCol - BorderWidth
                        ELSE
                           _HMG_aControlRow[ z ] := GetWindowRow( _HMG_aControlhandles[ z, 1 ] ) - BaseRow - TitleHeight - BorderHeight - MenuHeight
                           _HMG_aControlCol[ z ] := GetWindowCol( _HMG_aControlhandles[ z, 1 ] ) - BaseCol - BorderWidth
                        ENDIF

                        _HMG_aControlContainerRow[ z ] := eRow
                        _HMG_aControlContainerCol[ z ] := eCol

                        IF ! lRadio
                           cHideControl( _HMG_aControlhandles[ z ] )
                           cShowControl( _HMG_aControlhandles[ z ] )
                        ELSE
                           cHideControl( _HMG_aControlhandles[ z, 1 ] )
                           cShowControl( _HMG_aControlhandles[ z, 1 ] )
                           lRadio := .F.
                        ENDIF

                     ENDIF
                  ENDIF

               NEXT k

            NEXT j

            _SETVALUE( _HMG_aControlNames[ i ] , "Form_1" , CurrentPage )

            z := iif( ValType( u ) == "U", i, u )   // add by Pier 2006.5.21

         ELSE   // N0 TAB
            iRow    := _HMG_aControlRow[ i ]
            iCol    := _HMG_aControlCol[ i ]
            iWidth  := _HMG_aControlWidth[ i ]
            iHeight := _HMG_aControlHeight[ i ]

            *****************************************
            IsInTab  := .F.
            oktosave := .T.

            IF isComboBoxEx
               cResp := IsInTab( _HMG_aControlHandles[ xx ] )
            ELSE
               cResp := IsInTab( CurFocus )
            ENDIF

            IsInTab := cResp[ 1 ]
            TabId   := cResp[ 2 ]

            IF ! isComboBoxEx
               InterActiveMove()
               z := aScan( _HMG_aControlHandles, GetFocus() )
            ELSE
               InterActiveMoveHandle( _HMG_aControlhandles[ xx ] )
               z := xx
            ENDIF

            // MsgBox("control1= "+_HMG_aControlNames[z] )

            IF z > 0
               // MsgBox("windRow= "+str(GetWindowRow( _HMG_aControlhandles[z][1] ) )+"(-) ContRow = "+ str(_HMG_aControlContainerRow[z])+ "(-)BaseRow = "+str(baserow) +"(-)TitleHeight= "+str(TitleHeight) +"(-)Borderheight= "+str(borderheight) )
               // MsgBox("tot= "+str( _HMG_aControlRow[z] ) )

               _HMG_aControlRow[ z ] := GetWindowRow( _HMG_aControlHandles[ z ] ) - _HMG_aControlContainerRow[ z ] - BaseRow - TitleHeight - BorderHeight - MenuHeight
               _HMG_aControlCol[ z ] := GetWindowCol( _HMG_aControlHandles[ z ] ) - _HMG_aControlContainerCol[ z ] - BaseCol - BorderWidth

               // MsgBox(str(   _HMG_aControlRow[z])+"   _HMG_aControlRow[z][1] ","ZAPPA 1")
               // MsgBox(str(   _HMG_aControlCol[z])+"   _HMG_aControlCol[z][1] ","ZAPPA 2")
               // MsgBox("control= "+_HMG_aControlNames[z] )

               cHideControl( _HMG_aControlHandles[ z ] )

               SnapMoved( z )

               cShowControl( _HMG_aControlHandles[ z ] )
            ENDIF

            IF IsInTab

               TabRow := _HMG_aControlRow[ TabId ]
               TabCol := _HMG_aControlCol[ TabId ]

               /*
               MsgBox( Str( _HMG_aControlCol[z]   + _HMG_aControlWidth[z] )+" > "+ str(TabCol + TabWidth),"HKLM 1")
               MsgBox( Str( _HMG_aControlCol[z] ) +" < "+ str(TabCol) ,"HKLM 2")
               MsgBox( Str( _HMG_aControlRow[z]   + _HMG_aControlHeight[z])+" > "+ str(TabRow + TabHeight),"HKLM 3")
               MsgBox( Str( _HMG_aControlRow[z] ) +                         " < "+ str(TabRow + 30 ),"HKLM 4" )
               */

               IF IsMovedOutTab( z, TabId )

                  PlayHand()
                  // MsgBox('MOVED OUT '+str(irow)+" = irow"+crlf+str(icol)+" = icol")
                  _SetControlSizePos( _HMG_aControlnames[ z ], "Form_1", iRow - TabRow, iCol - TabCol, iWidth, iHeight )

                  IF isComboBoxEx
                     cHideControl( _HMG_aControlhandles[ xx ] )
                     cShowControl( _HMG_aControlhandles[ xx ] )
                  ELSE
                     cHideControl( _HMG_aControlhandles[ z ] )
                     cShowControl( _HMG_aControlhandles[ z ] )
                  ENDIF

                  _HMG_aControlRow[ z ] := iRow
                  _HMG_aControlCol[ z ] := iCol
                  oktosave := .F.
                  //ELSE
                  // MsgBox('no moved out')
               ENDIF

               UpdateTab( TabId )
            ELSE // IsInTab == .F.
               // MsgBox('is in tab  == .F. ' )
               FOR i := 1 To Len( _HMG_aControlHandles ) // removed  by Pier 2006.5.21

                  IF _HMG_aControlType[ i ] == "TAB" .AND. _HMG_aControlNames[ i ] # "XTab_1" .AND. _HMG_aControlNames[ i ] # "XTab_2" .AND. _HMG_aControlNames[ i ] # "XTab_3"

                     IF _HMG_aControlCol[ z ] >= _HMG_aControlCol[ i ] .AND. _HMG_aControlRow[ z ] >= _HMG_aControlRow[ i ] .AND. _HMG_aControlCol[ z ] < _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] .AND. _HMG_aControlRow[ z ] < _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ]
                        /*
                        MsgBox("_HMG_aControlCol[z]="+str(_HMG_aControlCol[z])+" >= _HMG_aControlCol[x]="+str(_HMG_aControlCol[x])+crlf+;
                               "_HMG_aControlRow[z]=" +str(_HMG_aControlRow[z])+" >= _HMG_aControlRow[x]="+str(_HMG_aControlRow[x])+CRLF+;
                               "_HMG_aControlCol[z] ="+str(_HMG_aControlCol[z])+" < _HMG_aControlCol[x] + _HMG_aControlWidth[x]="+str(_HMG_aControlCol[x] + _HMG_aControlWidth[x])+CRLF+;
                               "_HMG_aControlRow[Z] ="+str(_HMG_aControlRow[z])+" < _HMG_aControlRow[x] + _HMG_aControlHeight[x]="+str(_HMG_aControlRow[x] + _HMG_aControlHeight[x]),_HMG_aControlType[x])
                        */

                        PlayHand()

                        _SetControlSizePos( _HMG_aControlnames[ z ], "Form_1", iRow, iCol, iWidth, iHeight )

                        cHideControl( _HMG_aControlhandles[ z ] )
                        cShowControl( _HMG_aControlhandles[ z ] )

                        _HMG_aControlRow[ z ] := iRow
                        _HMG_aControlCol[ z ] := iCol

                        OkToSave := .F.

                     ENDIF
                  ENDIF
               NEXT i
            ENDIF

         ENDIF

         // add by Pier 2006.5.21  Start
         IF OkToSave .AND. x*z > 0

            // MsgBox("oktosave")
            SavePropControl( _HMG_aControlNames[ x ], ltrim( Str( _HMG_aControlCol[ z ] + DifCol() ) ), "Col" )
            SavePropControl( _HMG_aControlNames[ x ], ltrim( Str( _HMG_aControlRow[ z ] + DifRow() ) ), "Row" )

            lUpdate := .T.

            cpreencheGrid( _HMG_aControlNames[ x ] )

            ObjectInspector.xGrid_1.Value := y
         ENDIF
         // add by Pier 2006.5.21  Stop

      ENDIF
   ENDIF

   lChanges := .T.
   lUpdate  := .T.

RETURN


*-----------------------------------------------------------------------------*
FUNCTION MoveFrame()
*-----------------------------------------------------------------------------*
   LOCAL h             AS NUMERIC := GetFormHandle( DesignForm )
   LOCAL BaseRow       AS NUMERIC := GetWindowRow( h )
   LOCAL BaseCol       AS NUMERIC := GetWindowCol( h )
   LOCAL BaseWidth     AS NUMERIC := GetWindowWidth( h )
   LOCAL BaseHeight    AS NUMERIC := GetWindowHeight( h )
   LOCAL TitleHeight   AS NUMERIC := GetTitleHeight()
   LOCAL BorderWidth   AS NUMERIC := GetBorderWidth()
   LOCAL BorderHeight  AS NUMERIC := GetBorderHeight()
   LOCAL MenuHeight    AS NUMERIC := iif( Len( aMenu ) > 0, GetMenuBarHeight(), 0 )
   LOCAL SupMin        AS NUMERIC := 99999999
   LOCAL iMin          AS NUMERIC := 0
   LOCAL i             AS NUMERIC
   LOCAL y             AS NUMERIC := ObjectInspector.xGrid_1.Value
   LOCAL nPos          /*AS NUMERIC*/
   LOCAL OkToSave      AS LOGICAL
   LOCAL iRow          AS NUMERIC
   LOCAL iCol          AS NUMERIC
   LOCAL iHeight       AS NUMERIC
   LOCAL iWidth        AS NUMERIC
   LOCAL TabID         AS NUMERIC
   LOCAL TabRow        AS NUMERIC
   LOCAL TabCol        AS NUMERIC
   LOCAL IsInTab       AS LOGICAL
   LOCAL cResp         AS ARRAY        //? Invalid Hungarian should be aResp
   LOCAL CurFocus      AS USUAL        //? VarType

   _HMG_MouseRow := _HMG_MouseRow - BaseRow - TitleHeight - BorderHeight - MenuHeight
   _HMG_MouseCol := _HMG_MouseCol - BaseCol - BorderWidth

   FOR i := 1 To Len( _HMG_aControlHandles )
       IF ValType( _HMG_aControlHandles[ i ] ) = "A"

          IF ( _HMG_MouseRow >= _HMG_aControlRow[ i ] )                              .AND. ;
             ( _HMG_MouseRow <= _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] )   .AND. ;
             ( _HMG_MouseCol >= _HMG_aControlCol[ i ] )                              .AND. ;
             ( _HMG_MouseCol <= _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] )    .AND. ;
             _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )            .AND. ;
             IsWIndowVisible( _HMG_aControlHandles[ i, 1 ] )

             IF SupMin > _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
                SupMin := _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
                iMin := i
             ENDIF
          ENDIF
       ELSE
          IF ( _HMG_MouseRow >= _HMG_aControlRow[ i ] )                              .AND. ;
             ( _HMG_MouseRow <= _HMG_aControlRow[ i ] + _HMG_aControlHeight[ i ] )   .AND. ;
             ( _HMG_MouseCol >= _HMG_aControlCol[ i ] )                              .AND. ;
             ( _HMG_MouseCol <= _HMG_aControlCol[ i ] + _HMG_aControlWidth[ i ] )    .AND. ;
             _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" )            .AND. ;
             IsWIndowVisible( _HMG_aControlHandles[ i ] )

             IF SupMin > _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
                SupMin := _HMG_aControlHeight[ i ] * _HMG_aControlWidth[ i ]
                iMin := i
             ENDIF
          ENDIF
       ENDIF

   NEXT i

   IF iMin != 0 .AND. _HMG_aControlType[ iMin ] == "FRAME"
      i        := iMin
      lUpdate  := .T.

      cpreencheGrid( _HMG_aControlNames[ i ] )

      ****
      iRow     := _HMG_aControlRow[ i ]
      iCol     := _HMG_aControlCol[ i ]
      iWidth   := _HMG_aControlWidth[ i ]
      iHeight  := _HMG_aControlHeight[ i ]
      CurFocus := _HMG_aControlHandles[ i ]
      cResp    := IsInTab( Curfocus )
      IsInTab  := cResp[ 1 ]
      TabId    := cResp[ 2 ]
      ****

      InterActiveMoveHandle( _HMG_aControlHandles[ i ] )

      _HMG_aControlRow[ i ] := GetWindowRow( _HMG_aControlHandles[ i ] ) - _HMG_aControlContainerRow[ i ] - BaseRow - TitleHeight - BorderHeight
      _HMG_aControlCol[ i ] := GetWindowCol( _HMG_aControlHandles[ i ] ) - _HMG_aControlContainerCol[ i ] - BaseCol - BorderWidth

      CHideControl( _HMG_aControlHandles[ i ] )

      SnapMoved( i )

      ********************
      IF IsInTab
         TabRow := _HMG_aControlRow[ TabId ]
         TabCol := _HMG_aControlCol[ TabId ]

         IF IsMovedOutTab( i, TabId )

            PlayHand()

             // MsgBox(str(irow)+" = irow"+crlf+str(icol)+" = icol")
            _SetControlSizePos( _HMG_aControlNames[ i ], "Form_1", iRow - TabRow, iCol - TabCol, iWidth, iHeight )

            cHideControl( _HMG_aControlHandles[ i ] )
            cShowControl( _HMG_aControlHandles[ i ] )

            _HMG_aControlRow[ i ] := iRow
            _HMG_aControlCol[ i ] := iCol

            OkTosave := .F.
         ENDIF
      ENDIF
      ************************

      CShowControl( _HMG_aControlHandles[ i ] )

      SavePropControl( _HMG_aControlNames[ i ], ltrim( Str( _HMG_aControlCol[ i ] ) ), "Col" )
      SavePropControl( _HMG_aControlNames[ i ], ltrim( Str( _HMG_aControlRow[ i ] ) ), "Row" )

      lUpdate := .T.

      cpreencheGrid( _HMG_aControlNames[ i ] )

      ObjectInspector.xGrid_1.Value := y
      lChanges                      := .T.
      ProcessFrameOk                := .T.
   ENDIF

   IF iMin != 0   .AND. _HMG_aControlType[ iMin ] == "RADIOGROUP"
      i        := iMin
      ****
      iRow     := _HMG_aControlRow[ i ]
      iCol     := _HMG_aControlCol[ i ]
      iWidth   := _HMG_aControlWidth[ i ]
      iHeight  := _HMG_aControlHeight[ i ]
      CurFocus := _HMG_aControlHandles[ i, 1 ]
      cResp    := IsInTab( Curfocus )
      IsInTab  := cResp[ 1 ]
      TabId    := cResp[ 2 ]
      ****

      InterActiveMove()

      _HMG_aControlRow[ i ] := GetWindowRow( _HMG_aControlhandles[ i, 1 ] ) - _HMG_aControlContainerRow[ i ] - BaseRow - TitleHeight - BorderHeight
      _HMG_aControlCol[ i ] := GetWindowCol( _HMG_aControlhandles[ i, 1 ] ) - _HMG_aControlContainerCol[ i ] - BaseCol - BorderWidth

      cHideControl( _HMG_aControlhandles[ i, 1 ] )

      SnapMoved( i )

      ********************
      IF IsInTab
         TabRow    := _HMG_aControlRow[ TabId ]
         TabCol    := _HMG_aControlCol[ TabId ]
         IF IsMovedOutTab( i, TabId )

            PlayHand()

            // MsgBox(str(irow)+" = irow"+crlf+str(icol)+" = icol")
            _SetControlSizePos( _HMG_aControlNames[ i ], "Form_1" , iRow - TabRow, iCol - TabCol, iWidth, iHeight )

            cHideControl( _HMG_aControlHandles[ i, 1 ] )
            cShowControl( _HMG_aControlHandles[ i, 1 ] )

            _HMG_aControlRow[ i ] := iRow
            _HMG_aControlCol[ i ] := iCol

            OkToSave := .F.
         ENDIF
      ENDIF
      ************************

      cShowControl( _HMG_aControlhandles[ i, 1 ] )

      SavePropControl( _HMG_aControlNames[ i ], Ltrim( Str( _HMG_aControlCol[ i ] - _HMG_aControlContainerRow[ i ] ) ), "Col" )
      SavePropControl( _HMG_aControlNames[ i ], Ltrim( Str( _HMG_aControlRow[ i ] - _HMG_aControlContainerCol[ i ] ) ), "Row" )

      lUpdate := .T.

      cpreencheGrid( _HMG_aControlNames[ i ] )

      ObjectInspector.xGrid_1.Value := y
      lChanges                      := .T.
      ProcessFrameOk                := .T.
   ENDIF

   IF iMin != 0   .AND. _HMG_aControlType[ iMin ] # "RADIOGROUP"  .AND. _HMG_aControlType[ iMin ] # "FRAME"
      // MsgBox('name of control = '+ _HMG_aControlNames[iMin] + '  nr = '+ str(iMin) )
      nPos := iMin
   ENDIF

RETURN( nPos )


*-----------------------------------------------------------------------------*
PROCEDURE SnapMoved( i )
*-----------------------------------------------------------------------------*
   LOCAL xRow AS NUMERIC  //? Invalid Hungarian
   LOCAL xCol AS NUMERIC  //? Invalid Hungarian

   IF lSnap
      // MsgBox(str(_HMG_aControlRow[i])+CRLF+str(_HMG_aControlContainerRow[i] ),"SnapMoved1" )
      // MsgBox(str(_HMG_aControlCol[i])+CRLF+str(_HMG_aControlContainerCol[i] ),"SnapMoved2" )
      xRow := int( _HMG_aControlRow[ i ] / 10 ) * 10
      xCol := int( _HMG_aControlCol[ i ] / 10 ) * 10
   ELSE
      xRow := _HMG_aControlRow[ i ]
      xCol := _HMG_aControlCol[ i ]
   ENDIF
   // MsgBox( "xRow=" + Str( xRow ) + CRLF + "xCol=" + Str( xCol ), "SnapMoved3" )

   _SetControlSizePos( _HMG_aControlNames[ i ], "Form_1", xRow, xCol, _HMG_aControlWidth[ i ], _HMG_aControlHeight[ i ] )

RETURN


*-----------------------------------------------------------------------------*
FUNCTION SnapMovedTabRow( i, eRow )
*-----------------------------------------------------------------------------*
   LOCAL xRow AS NUMERIC //? Invalid Hungarian

   IF lSnap
      xRow                  := ( int( eRow / 10 ) ) * 10
      _HMG_aControlRow[ i ] := xRow
   ELSE
      xRow := eRow
   ENDIF

   // MsgBox( "snapmovedTabRow" + CRLF + _HMG_aControlnames[i], Str( xRow ) )
RETURN( xRow )


*-----------------------------------------------------------------------------*
FUNCTION SnapMovedTabCol( i, eCol )
*-----------------------------------------------------------------------------*
   LOCAL xCol AS NUMERIC //? Invalid Hungarian

   IF lSnap
      xCol                  := ( Int( eCol / 10 ) ) * 10
      _HMG_aControlCol[ i ] := xCol
   ELSE
      xCol := eCol
   ENDIF

   // MsgBox("snapmovedTabCol"+CRLF+_HMG_aControlnames[i], Str( xCol ) )

RETURN( xCol )


*-----------------------------------------------------------------------------*
FUNCTION IsInTab( CurFocus )
*-----------------------------------------------------------------------------*
   LOCAL IsInTab       AS LOGICAL := .F.
   LOCAL i             AS NUMERIC
   LOCAL j             AS NUMERIC
   LOCAL k             AS NUMERIC
   LOCAL TabId         AS NUMERIC := 0
   LOCAL aIsInTab      AS ARRAY   := {}
   LOCAL ControlHandle AS NUMERIC

   // oktosave := .T.
   FOR i := 1 To Len( _HMG_aControlHandles )

      IF _HMG_aControlType[ i ] == "TAB"

         FOR j := 1 To Len( _HMG_aControlPageMap[ i ] )

            FOR k := 1 To Len( _HMG_aControlPageMap[ i, j ] )

               IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"
                  ControlHandle := _HMG_aControlPageMap[ i, j, k ]
               ELSE
                  ControlHandle := _HMG_aControlPageMap[ i, j, k, 1 ]  // RADIOGROUP
               ENDIF

               // MsgBox( "controlhandle= " +Str( ControlHandle ) + " == " + "getfocus()= " + Str( getfocus() ) )
               // MsgBox( "curfocus= " + Str( curfocus ) )

               IF ControlHandle == CurFocus //GetFocus()
                  IsInTab    := .T.
                  //TabRow    := _HMG_aControlRow[i]
                  //TabCol    := _HMG_aControlCol[i]
                  //TabWidth  := _HMG_aControlWidth[i]
                  //TabHeight := _HMG_aControlHeight[i]
                  TabId := i
                  EXIT
               ENDIF

            Next k

            IF IsInTab
               EXIT
            ENDIF
         NEXT j

      ENDIF

      IF IsInTab
         EXIT
      ENDIF

   NEXT i

   aAdd( aIsInTab, IsInTab )
   aAdd( aIsInTab, TabId   )

RETURN( aIsInTab )


*-----------------------------------------------------------------------------*
FUNCTION IsMovedOutTab( z AS NUMERIC, TabId AS NUMERIC )
*-----------------------------------------------------------------------------*
   LOCAL TabRow    AS NUMERIC := _HMG_aControlRow[ TabId ]
   LOCAL TabCol    AS NUMERIC := _HMG_aControlCol[ TabId ]
   LOCAL TabWidth  AS NUMERIC := _HMG_aControlWidth[ TabId ]
   LOCAL TabHeight AS NUMERIC := _HMG_aControlHeight[ TabId ]
   LOCAL xResp     AS LOGICAL                                  //? Invalid Hungarian

   IF ( _HMG_aControlCol[ z ] + _HMG_aControlWidth[ z ] ) > ( TabCol + TabWidth )  .OR. ;
      ( _HMG_aControlCol[ z ] < TabCol )                                           .OR. ;
      ( _HMG_aControlRow[ z ] + _HMG_aControlHeight[ z ]  > TabRow + TabHeight )   .OR. ;
      ( _HMG_aControlRow[ z ] < TabRow + 30 )

      xResp := .T.
   ELSE
      xResp := .F.
   ENDIF

RETURN( xResp )
