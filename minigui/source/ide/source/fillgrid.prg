#include "minigui.ch"
#include "ide.ch"

declare window ObjectInspector
//DECLARE WINDOW LOGFORM

*------------------------------------------------------------*
PROCEDURE xPreencheGrid()                       // Fill grid                //? What would a better name for this procedure
*------------------------------------------------------------*
  LOCAL xControl_1  AS USUAL    //? VarType
  LOCAL h           AS NUMERIC
  LOCAL BaseRow     AS NUMERIC
  LOCAL BaseCol     AS NUMERIC
  LOCAL BaseWidth   AS NUMERIC
  LOCAL BaseHeight  AS NUMERIC

  IF Len( AllTrim( ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value ) ) ) > 0

     IF ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value ) == "Form"

        h              := GetFormHandle( DesignForm )
        BaseRow        := GetWindowRow( h )
        BaseCol        := GetWindowCol( h )
        BaseWidth      := GetWindowWidth( h )
        BaseHeight     := GetWindowHeight( h )

        LoadFormProps()

     ELSEIF ! Chk_Prj( .F. )
        xControl_1     := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
        nPosControl     := xControle( xControl_1 )

        IF nPosControl > 0
           CurrentControlName:= xArray[ nPosControl , 1 ]
          //  MsgBox( "nome = " + CurrentControlName )
        ENDIF
 
        // MsgBox( "current= "    + Str( CurrentControl ) )
        // MsgBox( "cType= "      + cTypeOfControl( CurrentControl ) )
        // MsgBox( "nPosControl= " + Str( nPosControl ) + ' value = ' + xArray[ nPosControl , 1 ])

        IF nPosControl                       == 0                  .OR.  ;
           cTypeOfControl( CurrentControl ) == CurrentControlName .OR.  ;
           CurrentControl                   == 1          &&        .OR. ;
        &&   aScan( aUciControls, xArray[ nPosControl , 1 ] ) # 0

         //   MsgBox( "normal control" )
           ObjInsFillGrid()
        ELSE
         //   MsgBox( "uci control" )
           UciFillGrid( xControl_1 )
        ENDIF
     ENDIF
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE cpreencheGrid( Frame AS STRING )
*------------------------------------------------------------*
   LOCAL i          AS NUMERIC
   LOCAL x          AS NUMERIC
   LOCAL x1         AS STRING
   LOCAL aColor     AS ARRAY
   LOCAL xControl_1 AS STRING
   LOCAL nPos       AS NUMERIC
   LOCAL GF         AS USUAL    := GetFocus() //? VarType

   IF InDelete .OR. ! lUpdate
      //LOGFORM.LIST_1.AddItem( "lUpdate= .F." )
      RETURN
   ENDIF

   IF Frame = NIL
      // LOGFORM.LIST_1.AddItem("FRAME= "+FRAME )
      i := aScan( _HMG_aControlHandles, GF )  //Add by Pier 08/09/2006 23.17

      IF i > 0

         xControl_1 := _HMG_aControlNames[ i ]

         IF _HMG_aControlType[ i ] # "TAB"
            _DisableMenuItem( "PtaB", "Form_1" )
         ELSE
            _EnableMenuItem( "PtaB", "Form_1" )
         ENDIF

         IF _HMG_aControlType[ i ] == "TAB"
            aColor := _HMG_aControlBkColor[ i ]
            IF isArray( aColor )
               DeleteObject( _HMG_aControlBrushHandle[ i ] )

               _HMG_aControlBrushHandle[ i ] := CreateSolidBrush( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )

               SetWindowBrush( _HMG_aControlHandles[ i ], _HMG_aControlBrushHandle[ i ] )

               RedrawWindow( _HMG_aControlHandles[ i ] )
            ENDIF
         ENDIF
      ELSE
         RETURN
      ENDIF                                     //Add by Pier Stop

   ELSE
      // LOGFORM.LIST_1.AddItem("FRAME= "+FRAME )
      IF Frame == "RADIOGROUP"
         nPos       := FindRadioName( gf )
         xControl_1 := _HMG_aControlNames[ nPos ]
         // MsgBox( "CONTROL= " + xControl_1, "RADIOGROUP" )
      ELSE
         xControl_1 := AllTrim( Frame )
         // LOGFORM.LIST_1.AddItem("FRAME= "+FRAME+ " "+ " XCONTROL_1= "+XCONTROL_1)
      ENDIF
   ENDIF

   nPosControl := xControle( xControl_1 )

   // LOGFORM.LIST_1.AddItem(" nPosControl = "+STR( nPosControl ) )
   // ctitle := GetProperty("form_1","title") + " "+xArray[ nPosControl ,1]
   // SetProperty("form_1","title" ,ctitle )
   CurrentControlName := xArray[ nPosControl , 1 ]

   FOR X := 1 TO ObjectInspector.xCombo_1.ItemCount

       X1 := AllTrim( ObjectInspector.xCombo_1.Item( x ) )

       IF X1 == xControl_1
          ObjectInspector.xCombo_1.Value := x
          x                              := ObjectInspector.xCombo_1.ItemCount
       ENDIF

   NEXT x

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ObjInsFillGrid()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   f_pontos() // add by Pier 2006.8.10

RETURN


*------------------------------------------------------------*
FUNCTION FindRadioName( gf AS USUAL )                          //? VarType
*------------------------------------------------------------*
  LOCAL i     AS NUMERIC
  LOCAL j     AS NUMERIC
  LOCAL nPos  AS NUMERIC

   FOR i := 1 TO Len( _HMG_aControlHandles )
       IF _HMG_aControlParentHandles[ i ] == GetFormHandle( "Form_1" ) .AND. _HMG_aControlType[ i ] == "RADIOGROUP"
           // MsgBox( "Control= " + _HMG_aControlNames[ i ] )
           j := aScan( _HMG_aControlHandles[ i ], GF )
           IF j > 0
               nPos := i
           ENDIF
       ENDIF
   NEXT i

RETURN( nPos )


*------------------------------------------------------------*
PROCEDURE ObjInsFillGrid()
*------------------------------------------------------------*
   //OPT: Why reload array all the time should be static for each control
   //     The only need is to reload data for that control which should
   //     be quite fast.


   LOCAL txControl0      AS ARRAY
   LOCAL txControl       AS ARRAY
   LOCAL txControlEvent  AS ARRAY
   LOCAL Methods         AS ARRAY   := {}
   LOCAL cAlignment      AS STRING
   LOCAL xVal            AS USUAL
   LOCAL cDataType       AS STRING
   LOCAL cCaseConvert    AS STRING
   LOCAL cValue          AS STRING
   LOCAL x               AS NUMERIC
   LOCAL cOrientation    AS STRING
   LOCAL cTickMarks      AS STRING


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check if we should update Grid
   IF ! lUpdate
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    *MsgBox( "Control nr=" + Str( CurrentControl ) + CRLF + "nome=" + CurrentControlName )
   *****************
    *ccc := ""    
    *FOR x := 1 to 512  
    *if  xArray[ nPosControl , x ] # NIL
    *   ccc += Str(x) + " " + xArray[ nPosControl , x ] + Space( 15 )
    *ENDIF   
    *next x
    *MsgBox( ccc )
   ***************

   DO CASE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 2  .OR. CurrentControlName == "BUTTON"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] },;
                           {"Caption"      , xArray[ nPosControl , 13 ] } } &&,;
                           
                           
      txControl        := {{"FontName"     , xArray[ nPosControl , 17 ] },;
                           {"FontSize"     , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 21 ] },;
                           {"FontBold"     , xArray[ nPosControl , 23 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 25 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 27 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 29 ] },;
                           {"HelpId"       , xArray[ nPosControl , 35 ] },;
                           {"Flat"         , xArray[ nPosControl , 37 ] },;
                           {"TabStop"      , xArray[ nPosControl , 39 ] },;
                           {"Visible"      , xArray[ nPosControl , 41 ] },;
                           {"Transparent"  , xArray[ nPosControl , 43 ] },;
                           {"Picture"      , xArray[ nPosControl , 45 ] },;
                           {"Default"      , xArray[ nPosControl , 47 ] },;
                           {"Icon"         , xArray[ nPosControl , 49 ] },;
                           {"Multiline"    , xArray[ nPosControl , 51 ] },;
                           {"NoXPStyle"    , xArray[ nPosControl , 53 ] } ;
                         }

      txControlEvent  := { {"Action"       , xArray[ nPosControl , 15 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 31 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 33 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, {"SaveAs" } }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 3 .OR. CurrentControlName == "CHECKBOX"
      txControl0      := { {"Name"          , xArray[ nPosControl ,  3 ] },;
                           {"Row"           , xArray[ nPosControl ,  5 ] },;
                           {"Col"           , xArray[ nPosControl ,  7 ] },;
                           {"Width"         , xArray[ nPosControl ,  9 ] },;
                           {"Height"        , xArray[ nPosControl , 11 ] }}  &&,;
                           
       txControl       := {{"Caption"       , xArray[ nPosControl , 13 ] },;
                           {"Value"         , xArray[ nPosControl , 15 ] },;
                           {"FontName"      , xArray[ nPosControl , 17 ] },;
                           {"FontSize"      , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"       , xArray[ nPosControl , 21 ] },;
                           {"FontBold"      , xArray[ nPosControl , 29 ] },;
                           {"FontItalic"    , xArray[ nPosControl , 31 ] },;
                           {"FontUnderLine" , xArray[ nPosControl , 33 ] },;
                           {"FontStrikeOut" , xArray[ nPosControl , 35 ] },;
                           {"Field"         , xArray[ nPosControl , 37 ] },;
                           {"BackColor"     , xArray[ nPosControl , 39 ] },;
                           {"FontColor"     , xArray[ nPosControl , 41 ] },;
                           {"HelpId"        , xArray[ nPosControl , 43 ] },;
                           {"TabStop"       , xArray[ nPosControl , 45 ] },;
                           {"Visible"       , xArray[ nPosControl , 47 ] },;
                           {"Transparent"   , xArray[ nPosControl , 49 ] },;
                           {"LeftJustify"   , xArray[ nPosControl , 51 ] },;
                           {"ThreEstate"    , xArray[ nPosControl , 53 ] },;
                           {"Autosize"      , xArray[ nPosControl , 55 ] } ;
                         }

      txControlEvent  := { {"OnChange"      , xArray[ nPosControl , 23 ] },;
                           {"OnGotFocus"    , xArray[ nPosControl , 25 ] },;
                           {"OnLostFocus"   , xArray[ nPosControl , 27 ] },;
                           {"OnEnter"       , xArray[ nPosControl , 57 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, {"Refresh"}, {"Save"}, {"SaveAs"} }


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 4 .OR. CurrentControlName == "LISTBOX"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl       := {{"Items"        , xArray[ nPosControl , 13 ] },;
                           {"Value"        , xArray[ nPosControl , 15 ] },;
                           {"FontName"     , xArray[ nPosControl , 17 ] },;
                           {"FontSize"     , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 21 ] },;
                           {"FontBold"     , xArray[ nPosControl , 29 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 31 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 33 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 35 ] },;
                           {"BackColor"    , xArray[ nPosControl , 37 ] },;
                           {"FontColor"    , xArray[ nPosControl , 39 ] },;
                           {"HelpId"       , xArray[ nPosControl , 43 ] },;
                           {"TabStop"      , xArray[ nPosControl , 45 ] },;
                           {"Visible"      , xArray[ nPosControl , 47 ] },;
                           {"Sort"         , xArray[ nPosControl , 49 ] },;
                           {"MultiSelect"  , xArray[ nPosControl , 51 ] },;
                           {"DragItems"    , xArray[ nPosControl , 53 ] },;
                           {"MultiTab"     , xArray[ nPosControl , 55 ] },;
                           {"MultiColumn"  , xArray[ nPosControl , 57 ] } ;                                                      
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 23 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 25 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 27 ] },;
                           {"OnDblClick"   , xArray[ nPosControl , 41 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"AddItem"}, {"DeleteItem"}, {"DeleteAllItems"}, {"SetFocus"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 5 .OR. CurrentControlName == "COMBOBOX"
   
    IF xArray[ nPosControl , 69 ] = ".T."
         cCaseConvert := "UPPER"
      ELSEIF xArray[ nPosControl , 71 ] = ".T."
         cCaseConvert := "LOWER"
      ELSE
         cCaseConvert := "NONE"
      ENDIF
   
   
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] }} && ,;
                           
       txControl       := {{"Items"        , xArray[ nPosControl , 13 ] },;
                           {"Value"        , xArray[ nPosControl , 15 ] },;
                           {"FontName"     , xArray[ nPosControl , 17 ] },;
                           {"FontSize"     , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 21 ] },;
                           {"FontBold"     , xArray[ nPosControl , 29 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 31 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 33 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 35 ] },;
                           {"HelpId"       , xArray[ nPosControl , 37 ] },;
                           {"TabStop"      , xArray[ nPosControl , 39 ] },;
                           {"Visible"      , xArray[ nPosControl , 41 ] },;
                           {"Sort"         , xArray[ nPosControl , 43 ] },;
                           {"DisplayEdit"  , xArray[ nPosControl , 49 ] },;
                           {"ItemSource"   , xArray[ nPosControl , 51 ] },;
                           {"ValueSource"  , xArray[ nPosControl , 53 ] },;
                           {"ListWidth"    , xArray[ nPosControl , 55 ] },;
                           {"GripperText"  , xArray[ nPosControl , 61 ] },;
                           {"Break"        , xArray[ nPosControl , 63 ] },;
                           {"BackColor"    , xArray[ nPosControl , 65 ] },;
                           {"FontColor"    , xArray[ nPosControl , 67 ] },;
                           {"CaseConvert"  , cCaseConvert               } ;
                         }

      txControlEvent  := { {"OnChange"       , xArray[ nPosControl , 23] },;
                           {"OnGotFocus"     , xArray[ nPosControl , 25] },;
                           {"OnLostFocus"    , xArray[ nPosControl , 27] },;
                           {"OnEnter"        , xArray[ nPosControl , 45] },;
                           {"OnDisplayChange", xArray[ nPosControl , 47] },;
                           {"OnListDisplay"  , xArray[ nPosControl , 57] },;
                           {"OnListClose"    , xArray[ nPosControl , 59] } ;
                         }

      Methods         := { {"Show"},{"Hide"},{"AddItem"},{"DeleteItem"},{"DeleteAllItems"},{"SetFocus"},{"Release"},{"EnableUpdate"},{"DisableUpdate"},{"SaveAs"}}


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 6 .OR. CurrentControlName == "CHECKBUTTON"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
        txControl      :={ {"Caption"      , xArray[ nPosControl , 13 ] },;
                           {"Value"        , xArray[ nPosControl , 15 ] },;
                           {"FontName"     , xArray[ nPosControl , 17 ] },;
                           {"FontSize"     , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 21 ] },;
                           {"FontBold"     , xArray[ nPosControl , 29 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 31 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 33 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 35 ] },;
                           {"HelpId"       , xArray[ nPosControl , 37 ] },;
                           {"TabStop"      , xArray[ nPosControl , 39 ] },;
                           {"Visible"      , xArray[ nPosControl , 41 ] },;
                           {"Picture"      , xArray[ nPosControl , 43 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 23 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 25 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 27 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 7 .OR. CurrentControlName == "GRID"
      txControl0      := { {"Name"             , xArray[ nPosControl ,  3 ] },;
                           {"Row"              , xArray[ nPosControl ,  5 ] },;
                           {"Col"              , xArray[ nPosControl ,  7 ] },;
                           {"Width"            , xArray[ nPosControl ,  9 ] },;
                           {"Height"           , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl      := { {"Headers"          , xArray[ nPosControl , 13 ] },;
                           {"Widths"           , xArray[ nPosControl , 15 ] },;
                           {"Items"            , xArray[ nPosControl , 17 ] },;                                                       
                           {"Value"            , xArray[ nPosControl , 19 ] },;                                                 
                           {"FontName"         , xArray[ nPosControl , 21 ] },;
                           {"FontSize"         , xArray[ nPosControl , 23 ] },;                         
                           {"FontBold"         , xArray[ nPosControl , 25 ] },;
                           {"FontItalic"       , xArray[ nPosControl , 27 ] },;
                           {"FontUnderLine"    , xArray[ nPosControl , 29 ] },;
                           {"FontStrikeOut"    , xArray[ nPosControl , 31 ] },;
                           {"ToolTip"          , xArray[ nPosControl , 33 ] },;
                           {"BackColor"        , xArray[ nPosControl , 35 ] },;
                           {"FontColor"        , xArray[ nPosControl , 37 ] },;
                           {"DynamicBackColor" , xArray[ nPosControl , 39 ] },;
                           {"DynamicForeColor" , xArray[ nPosControl , 41 ] },;
                           {"AllowEdit"        , xArray[ nPosControl , 51 ] },;
                           {"InPlaceEdit"      , xArray[ nPosControl , 57 ] },;
                           {"CellNavigation"   , xArray[ nPosControl , 59 ] },;
                           {"ColumnControls"   , xArray[ nPosControl , 61 ] },;
                           {"ColumnValid"      , xArray[ nPosControl , 63 ] },;
                           {"ColumnWhen"       , xArray[ nPosControl , 65 ] },;
                           {"ValidMessages"    , xArray[ nPosControl , 67 ] },;
                           {"Virtual"          , xArray[ nPosControl , 69 ] },;
                           {"ItemCount"        , xArray[ nPosControl , 71 ] },;                         
                           {"MultiSelect"      , xArray[ nPosControl , 75 ] },;                                                    
                           {"NoLines"          , xArray[ nPosControl , 77 ] },;
                           {"ShowHeaders"      , xArray[ nPosControl , 79 ] },;
                           {"NoSortHeaders"    , xArray[ nPosControl , 81 ] },;
                           {"Image"            , xArray[ nPosControl , 83 ] },;
                           {"Justify"          , xArray[ nPosControl , 85 ] },;                          
                           {"HelpId"           , xArray[ nPosControl , 87 ] },;
                           {"Break"            , xArray[ nPosControl , 89 ] },;                         
                           {"HeaderImage"      , xArray[ nPosControl , 91 ] },;
                           {"NoTabStop"        , xArray[ nPosControl , 93 ] },;
                           {"CheckBoxes"       , xArray[ nPosControl , 95 ] },;                                                     
                           {"LockColumns"      , xArray[ nPosControl , 97 ] },;
                           {"PaintDoubleBuffer", xArray[ nPosControl , 99 ] } ;                           
                          }

                         
      txControlEvent  := { {"OnGotFocus"       , xArray[ nPosControl , 43 ] },;
                           {"OnChange"         , xArray[ nPosControl , 45 ] },;                           
                           {"OnLostFocus"      , xArray[ nPosControl , 47 ] },;
                           {"OnDblClick"       , xArray[ nPosControl , 49 ] },;
                           {"OnHeadClick"      , xArray[ nPosControl , 53 ] },;
                           {"OnCheckboxClicked", xArray[ nPosControl , 55 ] },;    
                           {"OnQueryData"      , xArray[ nPosControl , 73 ] } ;                                                
                         }

      Methods         := { {"Show"},{"Hide"},{"SetFocus"},{"Release"},{"AddItem"},{"DeleteItem"},;
                           {"DeleteAllItems"},{"SetFocus"},{"AddColumn"},{"DeleteColumn"}       ,;
                           {"ColumnAutoFit"},{"ColumnAutoFitH"},{"ColumnsAutoFit"}              ,;
                           {"ColumnsAutoFitH"},{"EnableUpdate"},{"DisableUpdate"}               ,;
                           {"SaveAs"}                                                            ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 8 .OR. CurrentControlName == "SLIDER"

      IF xArray[ nPosControl , 33 ] = "1"
         cOrientation := "HORIZONTAL"

         DO CASE
            CASE xArray[ nPosControl , 35 ] = "1" ; cTickMarks := "BOTH"
          //CASE xArray[ nPosControl , 35 ] = "2" ; cTickMarks := "BOTTOM"
            CASE xArray[ nPosControl , 35 ] = "3" ; cTickMarks := "NONE"
            CASE xArray[ nPosControl , 35 ] = "4" ; cTickMarks := "TOP"
            OTHERWISE                           ; cTickMarks := "BOTTOM"
         ENDCASE

      ENDIF

      IF xArray[ nPosControl ,33] = "2"
         cOrientation := "VERTICAL"

         DO CASE
            CASE xArray[ nPosControl , 35 ] = "1" ; cTickMarks := "BOTH"
            CASE xArray[ nPosControl , 35 ] = "2" ; cTickMarks := "LEFT"
            CASE xArray[ nPosControl , 35 ] = "3" ; cTickMarks := "NONE"
          //CASE xArray[ nPosControl , 35 ] = "4" ; cTickMarks := "RIGHT"
            OTHERWISE                           ; cTickMarks := "RIGHT"
         ENDCASE

      ENDIF

      txControl0      := { {"Name"       , xArray[ nPosControl ,  3 ] },;
                           {"Row"        , xArray[ nPosControl ,  5 ] },;
                           {"Col"        , xArray[ nPosControl ,  7 ] },;
                           {"Width"      , xArray[ nPosControl ,  9 ] },;
                           {"Height"     , xArray[ nPosControl , 11 ] } } &&,;
                           
        txControl      := {{"RangeMin"   , xArray[ nPosControl , 13 ] },;
                           {"RangeMax"   , xArray[ nPosControl , 15 ] },;
                           {"Value"      , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"    , xArray[ nPosControl , 19 ] },;
                           {"HelpId"     , xArray[ nPosControl , 23 ] },;
                           {"TabStop"    , xArray[ nPosControl , 25 ] },;
                           {"Visible"    , xArray[ nPosControl , 27 ] },;
                           {"BackColor"  , xArray[ nPosControl , 31 ] },;
                           {"Orientation", cOrientation             },;
                           {"TickMarks"  , cTickMarks               } ;
                         }

      txControlEvent  := { {"OnChange"   , xArray[ nPosControl , 21 ] },;
                           {"OnScroll"   , xArray[ nPosControl , 53 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 9 .OR. CurrentControlName == "SPINNER"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
        txControl      := {{"RangeMin"     , xArray[ nPosControl , 13 ] },;
                           {"RangeMax"     , xArray[ nPosControl , 15 ] },;
                           {"Value"        , xArray[ nPosControl , 17 ] },;
                           {"FontName"     , xArray[ nPosControl , 19 ] },;
                           {"FontSize"     , xArray[ nPosControl , 21 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 23 ] },;
                           {"FontBold"     , xArray[ nPosControl , 31 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 33 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 35 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 37 ] },;
                           {"HelpId"       , xArray[ nPosControl , 39 ] },;
                           {"TabStop"      , xArray[ nPosControl , 41 ] },;
                           {"Visible"      , xArray[ nPosControl , 43 ] },;
                           {"Wrap"         , xArray[ nPosControl , 45 ] },;
                           {"ReadOnly"     , xArray[ nPosControl , 47 ] },;
                           {"Increment"    , xArray[ nPosControl , 49 ] },;
                           {"BackColor"    , xArray[ nPosControl , 51 ] },;
                           {"FontColor"    , xArray[ nPosControl , 53 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 25 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 27 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 29 ] } ;
                         }

      Methods         := { {"Show"},{"Hide"},{"SetFocus"},{"Release"},{"SaveAs"}}

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 10 .OR. CurrentControlName == "IMAGE"
      txControl0      := { {"Name"           , xArray[ nPosControl ,  3 ] },;
                           {"Row"            , xArray[ nPosControl ,  5 ] },;
                           {"Col"            , xArray[ nPosControl ,  7 ] },;
                           {"Width"          , xArray[ nPosControl ,  9 ] },;
                           {"Height"         , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl       := {{"Picture"        , xArray[ nPosControl , 13 ] },;
                           {"HelpId"         , xArray[ nPosControl , 15 ] },;
                           {"Visible"        , xArray[ nPosControl , 17 ] },;
                           {"Stretch"        , xArray[ nPosControl , 19 ] },;
                           {"WhiteBackground", xArray[ nPosControl , 23 ] },;
                           {"Transparent"    , xArray[ nPosControl , 29 ] },;
                           {"BackgroundColor", xArray[ nPosControl , 31 ] },;
                           {"AdjustImage"    , xArray[ nPosControl , 33 ] },;
                           {"Tooltip"        , xArray[ nPosControl , 35 ] } ;                                                                                 
                         }
                         
      txControlEvent  := { {"Action"         , xArray[ nPosControl , 21 ] },;
                           {"OnMouseHover"   , xArray[ nPosControl , 25 ] },;
                           {"OnMouseLeave"   , xArray[ nPosControl , 27 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"Refresh"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 11 .OR. CurrentControlName == "TREE"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] }} &&,;
                           
         txControl     := {{"Value"        , xArray[ nPosControl , 13 ] },;
                           {"Font"         , xArray[ nPosControl , 15 ] },;
                           {"Size"         , xArray[ nPosControl , 17 ] },;
                           {"Tooltip"      , xArray[ nPosControl , 19 ] },;
                           {"NodeImages"   , xArray[ nPosControl , 29 ] },;
                           {"ItemImages"   , xArray[ nPosControl , 31 ] },;
                           {"NoRootButton" , xArray[ nPosControl , 33 ] },;
                           {"HelpId"       , xArray[ nPosControl , 35 ] },;
                           {"BackColor"    , xArray[ nPosControl , 37 ] },;
                           {"FontColor"    , xArray[ nPosControl , 39 ] },;
                           {"LineColor"    , xArray[ nPosControl , 41 ] },;
                           {"Indent"       , xArray[ nPosControl , 43 ] },;
                           {"ItemHeight"   , xArray[ nPosControl , 45 ] },;
                           {"FontBold"     , xArray[ nPosControl , 47 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 49 ] },;
                           {"FontUnderline", xArray[ nPosControl , 51 ] },;
                           {"FontStrikeout", xArray[ nPosControl , 53 ] },;
                           {"Break"        , xArray[ nPosControl , 55 ] },;
                           {"ItemIds"      , xArray[ nPosControl , 57 ] } ;
                        }

      txControlEvent  := { {"OnGotFocus"   , xArray[ nPosControl , 21 ] },;
                           {"OnChange"     , xArray[ nPosControl , 23 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 25 ] },;
                           {"OnDblClick"   , xArray[ nPosControl , 27 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"AddItem"}, {"DeleteItem"},             ;
                           {"DeleteAllItems"}, {"Expand"}, {"Colapse"}, {"SetFocus"},   ;
                           {"Release"}, {"EnableUpdate"}, {"DisableUpdate"}, {"SaveAs"} ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 12 .OR. CurrentControlName == "DATEPICKER"
      txControl0      := { {"Name"          , xArray[ nPosControl ,  3 ] },;
                           {"Row"           , xArray[ nPosControl ,  5 ] },;
                           {"Col"           , xArray[ nPosControl ,  7 ] },;
                           {"Width"         , xArray[ nPosControl ,  9 ] },;
                           {"Height"        , xArray[ nPosControl , 11 ] } } &&,;
                           
      txControl       := { {"Value"         , xArray[ nPosControl , 13 ] },;
                           {"FontName"      , xArray[ nPosControl , 15 ] },;
                           {"FontSize"      , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"       , xArray[ nPosControl , 19 ] },;
                           {"FontBold"      , xArray[ nPosControl , 27 ] },;
                           {"FontItalic"    , xArray[ nPosControl , 29 ] },;
                           {"FontUnderLine" , xArray[ nPosControl , 31 ] },;
                           {"FontStrikeOut" , xArray[ nPosControl , 33 ] },;
                           {"HelpId"        , xArray[ nPosControl , 37 ] },;
                           {"TabStop"       , xArray[ nPosControl , 39 ] },;
                           {"Visible"       , xArray[ nPosControl , 41 ] },;
                           {"ShowNone"      , xArray[ nPosControl , 43 ] },;
                           {"UpDown"        , xArray[ nPosControl , 45 ] },;
                           {"RightAlign"    , xArray[ nPosControl , 47 ] },;
                           {"Field"         , xArray[ nPosControl , 49 ] },;
                           {"BackColor"     , xArray[ nPosControl , 51 ] },;
                           {"FontColor"     , xArray[ nPosControl , 53 ] },;
                           {"DateFormat"    , xArray[ nPosControl , 55 ] },;
                           {"TitleBackColor", xArray[ nPosControl , 57 ] },;
                           {"TitleFontColor", xArray[ nPosControl , 59 ] } ;
                         }

      txControlEvent  := { {"OnChange"      , xArray[ nPosControl , 21 ] },;
                           {"OnGotFocus"    , xArray[ nPosControl , 23 ] },;
                           {"OnLostFocus"   , xArray[ nPosControl , 25 ] },;
                           {"OnEnter"       , xArray[ nPosControl , 35 ] } ;
                         }

       Methods        := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, {"Refresh"},;
                           {"Save"}, {"SaveAs"}                                       ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 13 .OR. CurrentControlName == "TEXTBOX"
      *****test
      *   ccc := ""
      *   for x = 2 to 75 STEP 2
      *    ccc += str(x)+" "+xArray[ nPosControl ,x]+" "+xArray[ nPosControl ,x+1]+CRLF
      *   next x
      *   MsgBox(ccc)
      *************
      IF xArray[ nPosControl , 45 ] = ".T."
         cCaseConvert := "LOWER"
      ELSEIF xArray[ nPosControl , 47 ] = ".T."
         cCaseConvert := "UPPER"
      ELSE
         cCaseConvert := "NONE"
      ENDIF

      IF xArray[ nPosControl , 51 ] = ".T."
         cDataType := "PASSWORD"
      ELSEIF xArray[ nPosControl , 65 ] = ".T."
         cDataType := "DATE"
      ELSEIF xArray[ nPosControl , 67 ] = ".T."
         cDataType := "NUMERIC"
      ELSE
         cDataType := "CHARACTER"
      ENDIF
      xArray[ nPosControl, 75 ] := cDataType

      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] }} &&,;
                           
       txControl       := {{"FontName"     , xArray[ nPosControl , 13 ] },;
                           {"FontSize"     , xArray[ nPosControl , 15 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 17 ] },;
                           {"FontBold"     , xArray[ nPosControl , 25 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 27 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 29 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 31 ] },;
                           {"HelpId"       , xArray[ nPosControl , 35 ] },;
                           {"TabStop"      , xArray[ nPosControl , 37 ] },;
                           {"Visible"      , xArray[ nPosControl , 39 ] },;
                           {"ReadOnly"     , xArray[ nPosControl , 41 ] },;
                           {"RightAlign"   , xArray[ nPosControl , 43 ] },;
                           {"PassWord"     , xArray[ nPosControl , 51 ] },;
                           {"MaxLength"    , xArray[ nPosControl , 53 ] },;
                           {"BackColor"    , xArray[ nPosControl , 55 ] },;
                           {"FontColor"    , xArray[ nPosControl , 57 ] },;
                           {"Field"        , xArray[ nPosControl , 59 ] },;
                           {"InputMask"    , xArray[ nPosControl , 61 ] },;
                           {"Format"       , xArray[ nPosControl , 63 ] },;
                           {"DataType"     , cDataType                  },;
                           {"Value"        , xArray[ nPosControl , 71 ] },;
                           {"CaseConvert"  , cCaseConvert               },;
                           {"Border"       , xArray[ nPosControl , 77 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 19 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 21 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 23 ] },;
                           {"OnEnter"      , xArray[ nPosControl , 33 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, ;
                           {"Refresh"}, {"Save"}, {"SaveAs"}              ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 14 .OR. CurrentControlName == "EDITBOX"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl       := {{"Value"        , xArray[ nPosControl , 13 ] },;
                           {"FontName"     , xArray[ nPosControl , 15 ] },;
                           {"FontSize"     , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 19 ] },;
                           {"FontBold"     , xArray[ nPosControl , 27 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 29 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 31 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 33 ] },;
                           {"HelpId"       , xArray[ nPosControl , 35 ] },;
                           {"TabStop"      , xArray[ nPosControl , 37 ] },;
                           {"Visible"      , xArray[ nPosControl , 39 ] },;
                           {"ReadOnly"     , xArray[ nPosControl , 41 ] },;
                           {"BackColor"    , xArray[ nPosControl , 43 ] },;
                           {"FontColor"    , xArray[ nPosControl , 45 ] },;
                           {"MaxLength"    , xArray[ nPosControl , 47 ] },;
                           {"Field"        , xArray[ nPosControl , 49 ] },;
                           {"HScrollBar"   , xArray[ nPosControl , 51 ] },;
                           {"VScrollBar"   , xArray[ nPosControl , 53 ] },;
                           {"Break"        , xArray[ nPosControl , 55 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 21 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 23 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 25 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, ;
                           {"Refresh"}, {"Save"}, {"SaveAs"}              ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 15 .OR. CurrentControlName == "LABEL"
      IF xArray[ nPosControl , 43 ] = "2"
         cAlignment := "RIGHT"
      ELSEIF xArray[ nPosControl , 43 ] = "3"
         cAlignment := "CENTER"
      ELSE
         cAlignment := "LEFT"
      ENDIF

      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl       := {{"Value"        , xArray[ nPosControl , 13 ] },;
                           {"FontName"     , xArray[ nPosControl , 15 ] },;
                           {"FontSize"     , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 19 ] },;
                           {"FontBold"     , xArray[ nPosControl , 21 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 23 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 25 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 27 ] },;
                           {"HelpId"       , xArray[ nPosControl , 29 ] },;
                           {"Visible"      , xArray[ nPosControl , 31 ] },;
                           {"Transparent"  , xArray[ nPosControl , 33 ] },;
                           {"AutoSize"     , xArray[ nPosControl , 37 ] },;
                           {"BackColor"    , xArray[ nPosControl , 39 ] },;
                           {"FontColor"    , xArray[ nPosControl , 41 ] },;
                           {"Alignment"    , cAlignment               },;
                           {"Border"       , xArray[ nPosControl , 51 ] },;
                           {"ClientEdge"   , xArray[ nPosControl , 53 ] },;
                           {"HScroll"      , xArray[ nPosControl , 55 ] },;
                           {"VScroll"      , xArray[ nPosControl , 57 ] },;
                           {"Blink"        , xArray[ nPosControl , 59 ] } ;
                         }

      txControlEvent  := { {"Action"       , xArray[ nPosControl , 35 ] },;
                           {"OnMouseHover" , xArray[ nPosControl , 61 ] },;
                           {"OnMouseLeave" , xArray[ nPosControl , 63 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"Refresh"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 16 .OR. CurrentControlName == "BROWSE"
      txControl0      := { {"Name"             , xArray[ nPosControl ,  3 ] },;
                           {"Row"              , xArray[ nPosControl ,  5 ] },;
                           {"Col"              , xArray[ nPosControl ,  7 ] },;
                           {"Width"            , xArray[ nPosControl ,  9 ] },;
                           {"Height"           , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl      := { {"Headers"          , xArray[ nPosControl , 13 ] },;
                           {"Widths"           , xArray[ nPosControl , 15 ] },;
                           {"Fields"           , xArray[ nPosControl , 17 ] },;
                           {"Value"            , xArray[ nPosControl , 19 ] },;                                                    
                           {"WorkArea"         , xArray[ nPosControl , 21 ] },;                                             
                           {"FontName"         , xArray[ nPosControl , 23 ] },;
                           {"FontSize"         , xArray[ nPosControl , 25 ] },;
                           {"FontBold"         , xArray[ nPosControl , 27 ] },;
                           {"FontItalic"       , xArray[ nPosControl , 29 ] },;
                           {"FontUnderLine"    , xArray[ nPosControl , 31 ] },;
                           {"FontStrikeOut"    , xArray[ nPosControl , 33 ] },;
                           {"ToolTip"          , xArray[ nPosControl , 35 ] },;
                           {"BackColor"        , xArray[ nPosControl , 37 ] },;
                           {"DynamicBackColor" , xArray[ nPosControl , 39 ] },;
                           {"DynamicForeColor" , xArray[ nPosControl , 41 ] },;                          
                           {"FontColor"        , xArray[ nPosControl , 43 ] },;                           
                           {"AllowEdit"        , xArray[ nPosControl , 53 ] },;
                           {"InPlaceEdit"      , xArray[ nPosControl , 55 ] },;
                           {"AllowAppend"      , xArray[ nPosControl , 57 ] },;
                           {"InputItems"       , xArray[ nPosControl , 59 ] },;
                           {"DisplayItems"     , xArray[ nPosControl , 61 ] },;                           
                           {"When"             , xArray[ nPosControl , 65 ] },;                           
                           {"Valid"            , xArray[ nPosControl , 67 ] },;
                           {"ValidMessages"    , xArray[ nPosControl , 69 ] },;
                           {"PaintDoubleBuffer", xArray[ nPosControl , 71 ] },;
                           {"ReadOnlyFields"   , xArray[ nPosControl , 73 ] },;
                           {"Lock"             , xArray[ nPosControl , 75 ] },;                             
                           {"AllowDelete"      , xArray[ nPosControl , 77 ] },;
                           {"NoLines"          , xArray[ nPosControl , 79 ] },;
                           {"Image"            , xArray[ nPosControl , 81 ] },;
                           {"Justify"          , xArray[ nPosControl , 83 ] },;
                           {"VScrollBar"       , xArray[ nPosControl , 85 ] },;
                           {"HelpId"           , xArray[ nPosControl , 87 ] },;
                           {"Break"            , xArray[ nPosControl , 89 ] },;
                           {"HeaderImage"      , xArray[ nPosControl , 91 ] },;
                           {"NoTabStop"        , xArray[ nPosControl , 93 ] },;
                           {"DatabaseName"     , xArray[ nPosControl , 95 ] },;     
                           {"DatabasePath"     , xArray[ nPosControl , 97 ] } ;
                          }
                                                      
                        *   {"InputMask"       , xArray[ nPosControl , 99 ] },;
                        *   {"Format"          , xArray[ nPosControl , 101 ] },;
                                                                              
                         
                                                                                                                                                 

      txControlEvent  := { {"OnGotFocus"      , xArray[ nPosControl , 45 ] },;
                           {"OnChange"        , xArray[ nPosControl , 47 ] },;                          
                           {"OnLostFocus"     , xArray[ nPosControl , 49 ] },;
                           {"OnDblClick"      , xArray[ nPosControl , 51 ] },;
                           {"OnHeadClick"     , xArray[ nPosControl , 63 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Refresh"},;
                           {"Release"}, {"ColumnAutoFit"},{"ColumnAutoFitH"},;
                           {"ColumnsAutoFit"}, {"ColumnsAutoFitH"},{"EnableUpdate"},;
                           {"DisableUpdate"}, {"SaveAs"} ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 17 .OR. CurrentControlName == "RADIOGROUP"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl       := {{"Options"      , xArray[ nPosControl , 13 ] },;
                           {"Value"        , xArray[ nPosControl , 15 ] },;
                           {"FontName"     , xArray[ nPosControl , 17 ] },;
                           {"FontSize"     , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 21 ] },;
                           {"FontBold"     , xArray[ nPosControl , 25 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 27 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 29 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 31 ] },;
                           {"HelpId"       , xArray[ nPosControl , 33 ] },;
                           {"TabStop"      , xArray[ nPosControl , 35 ] },;
                           {"Visible"      , xArray[ nPosControl , 37 ] },;
                           {"Transparent"  , xArray[ nPosControl , 39 ] },;
                           {"Spacing"      , xArray[ nPosControl , 41 ] },;
                           {"BackColor"    , xArray[ nPosControl , 43 ] },;
                           {"FontColor"    , xArray[ nPosControl , 45 ] },;
                           {"LeftJustify"  , xArray[ nPosControl , 47 ] },;
                           {"Horizontal"   , xArray[ nPosControl , 49 ] },;
                           {"ReadOnly"     , xArray[ nPosControl , 51 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 23 ] } }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"SaveAS"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASe CurrentControl == 18 .OR. CurrentControlName == "FRAME"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
     txControl       := {  {"FontName"     , xArray[ nPosControl , 13 ] },;
                           {"FontSize"     , xArray[ nPosControl , 15 ] },;
                           {"FontBold"     , xArray[ nPosControl , 17 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 19 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 21 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 23 ] },;
                           {"Caption"      , xArray[ nPosControl , 25 ] },;
                           {"BackColor"    , xArray[ nPosControl , 27 ] },;
                           {"FontColor"    , xArray[ nPosControl , 29 ] },;
                           {"Opaque"       , xArray[ nPosControl , 31 ] },;
                           {"Invisible"    , xArray[ nPosControl , 33 ] },;
                           {"Transparent"  , xArray[ nPosControl , 35 ] } ;
                         }

      txControlEvent  := {}

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 19 .OR. CurrentControlName == "TAB"
      txControl0      := { {"Name"           , xArray[ nPosControl ,  3 ] },;
                           {"Row"            , xArray[ nPosControl ,  5 ] },;
                           {"Col"            , xArray[ nPosControl ,  7 ] },;
                           {"Width"          , xArray[ nPosControl ,  9 ] },;
                           {"Height"         , xArray[ nPosControl , 11 ] } } &&,;
                           
        txControl      := {{"Value"          , xArray[ nPosControl , 13 ] },;
                           {"FontName"       , xArray[ nPosControl , 15 ] },;
                           {"FontSize"       , xArray[ nPosControl , 17 ] },;
                           {"FontBold"       , xArray[ nPosControl , 19 ] },;
                           {"FontItalic"     , xArray[ nPosControl , 21 ] },;
                           {"FontUnderline"  , xArray[ nPosControl , 23 ] },;
                           {"FontStrikeout"  , xArray[ nPosControl , 25 ] },;
                           {"ToolTip"        , xArray[ nPosControl , 27 ] },;
                           {"Buttons"        , xArray[ nPosControl , 29 ] },;
                           {"Flat"           , xArray[ nPosControl , 31 ] },;
                           {"HotTrack"       , xArray[ nPosControl , 33 ] },;
                           {"Vertical"       , xArray[ nPosControl , 35 ] },;
                           {"Bottom"         , xArray[ nPosControl , 39 ] },;
                           {"NoTabStop"      , xArray[ nPosControl , 41 ] },;
                           {"MultiLine"      , xArray[ nPosControl , 43 ] },;
                           {"BackColor"      , xArray[ nPosControl , 45 ] },;
                           {"PageCount"      , xArray[ nPosControl , 47 ] },;
                           {"PageImages"     , xArray[ nPosControl , 49 ] },;
                           {"PageCaptions"   , xArray[ nPosControl , 51 ] },;
                           {"PageToolTips"   , xArray[ nPosControl , 53 ] } ;
                         }

      txControlEvent  := { {"OnChange"       , xArray[ nPosControl , 37 ] } }

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"AddPage"},;
                           {"DeletePage"}, {"AddControl"}, {"SaveAS"};
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 20 .OR. CurrentControlName == "ANIMATEBOX"
      txControl0      := { {"Name"       , xArray[ nPosControl ,  3 ] },;
                           {"Row"        , xArray[ nPosControl ,  5 ] },;
                           {"Col"        , xArray[ nPosControl ,  7 ] },;
                           {"Width"      , xArray[ nPosControl ,  9 ] },;
                           {"Height"     , xArray[ nPosControl , 11 ] } } && ,;
                           
       txControl     := {  {"File"       , xArray[ nPosControl , 13 ] },;
                           {"HelpId"     , xArray[ nPosControl , 15 ] },;
                           {"Transparent", xArray[ nPosControl , 17 ] },;
                           {"AutoPlay"   , xArray[ nPosControl , 19 ] },;
                           {"Center"     , xArray[ nPosControl , 21 ] },;
                           {"Border"     , xArray[ nPosControl , 23 ] } ;
                         }

      txControlEvent  := {}

      Methods         := { {"Show"}, {"Hide"}, {"Open"}, {"Play"}, {"Seek"},;
                           {"Stop"}, {"Close"}, {"Release"}, {"SaveAS"}     ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 21 .OR. CurrentControlName == "HYPERLINK"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl      := { {"Value"        , xArray[ nPosControl , 13 ] },;
                           {"Address"      , xArray[ nPosControl , 15 ] },;
                           {"FontName"     , xArray[ nPosControl , 17 ] },;
                           {"FontSize"     , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 21 ] },;
                           {"FontBold"     , xArray[ nPosControl , 23 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 25 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 27 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 29 ] },;
                           {"AutoSize"     , xArray[ nPosControl , 31 ] },;
                           {"HelpId"       , xArray[ nPosControl , 33 ] },;
                           {"Visible"      , xArray[ nPosControl , 35 ] },;
                           {"HandCursor"   , xArray[ nPosControl , 37 ] },;
                           {"BackColor"    , xArray[ nPosControl , 39 ] },;
                           {"FontColor"    , xArray[ nPosControl , 41 ] },;
                           {"RightAlign"   , xArray[ nPosControl , 43 ] },;
                           {"CenterAlign"  , xArray[ nPosControl , 45 ] } ;
                         }

      txControlEvent  := {}

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 22 .OR. CurrentControlName == "MONTHCALENDAR"
      txControl0      := { {"Name"             , xArray[ nPosControl ,  3 ] },;
                           {"Row"              , xArray[ nPosControl ,  5 ] },;
                           {"Col"              , xArray[ nPosControl ,  7 ] },;
                           {"Width"            , xArray[ nPosControl ,  9 ] },;
                           {"Height"           , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl      := { {"Value"            , xArray[ nPosControl , 13 ] },;
                           {"FontName"         , xArray[ nPosControl , 15 ] },;
                           {"FontSize"         , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"          , xArray[ nPosControl , 19 ] },;
                           {"FontBold"         , xArray[ nPosControl , 23 ] },;
                           {"FontItalic"       , xArray[ nPosControl , 25 ] },;
                           {"FontUnderLine"    , xArray[ nPosControl , 27 ] },;
                           {"FontStrikeOut"    , xArray[ nPosControl , 29 ] },;
                           {"HelpId"           , xArray[ nPosControl , 31 ] },;
                           {"Tabstop"          , xArray[ nPosControl , 33 ] },;
                           {"Visible"          , xArray[ nPosControl , 35 ] },;
                           {"NoToday"          , xArray[ nPosControl , 37 ] },;
                           {"NoTodayCircle"    , xArray[ nPosControl , 39 ] },;
                           {"WeekNumbers"      , xArray[ nPosControl , 41 ] },;
                           {"BackColor"        , xArray[ nPosControl , 43 ] },;
                           {"FontColor"        , xArray[ nPosControl , 45 ] },;
                           {"TitleBackColor"   , xArray[ nPosControl , 47 ] },;
                           {"TitleFontColor"   , xArray[ nPosControl , 49 ] },;
                           {"BackGroundColor"  , xArray[ nPosControl , 55 ] },;
                           {"TrailingFontColor", xArray[ nPosControl , 53 ] } ;
                         }

      txControlEvent  := { {"OnChange"         , xArray[ nPosControl , 21 ] } }

       Methods        := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, {"Refresh"}, {"Save"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 23 .OR. CurrentControlName == "RICHEDITBOX"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] }} &&,;
                           
      txControl      := {  {"Value"        , xArray[ nPosControl , 13 ] },;
                           {"FontName"     , xArray[ nPosControl , 15 ] },;
                           {"FontSize"     , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 19 ] },;
                           {"FontBold"     , xArray[ nPosControl , 27 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 29 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 31 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 33 ] },;
                           {"HelpId"       , xArray[ nPosControl , 35 ] },;
                           {"TabStop"      , xArray[ nPosControl , 37 ] },;
                           {"Visible"      , xArray[ nPosControl , 39 ] },;
                           {"ReadOnly"     , xArray[ nPosControl , 41 ] },;
                           {"BackColor"    , xArray[ nPosControl , 43 ] },;
                           {"Field"        , xArray[ nPosControl , 45 ] },;
                           {"MaxLength"    , xArray[ nPosControl , 47 ] },;
                           {"File"         , xArray[ nPosControl , 49 ] },;
                           {"PlainText"    , xArray[ nPosControl , 53 ] },;
                           {"HScrollBar"   , xArray[ nPosControl , 55 ] },;
                           {"VScrollBar"   , xArray[ nPosControl , 57 ] },;
                           {"FontColor"    , xArray[ nPosControl , 59 ] },;
                           {"Break"        , xArray[ nPosControl , 61 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 21 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 23 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 25 ] },;
                           {"OnSelect"     , xArray[ nPosControl , 51 ] },;
                           {"OnVScroll"    , xArray[ nPosControl , 63 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"},;
                           {"Refresh"}, {"Save"}, {"SaveAS"} ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 24 .OR. CurrentControlName == "PROGRESSBAR"

      cOrientation    := iif( xArray[ nPosControl , 33 ] = "1", "HORIZONTAL", "VERTICAL" )

      txControl0      := { {"Name"       , xArray[ nPosControl ,  3 ] },;
                           {"Row"        , xArray[ nPosControl ,  5 ] },;
                           {"Col"        , xArray[ nPosControl ,  7 ] },;
                           {"Width"      , xArray[ nPosControl ,  9 ] },;
                           {"Height"     , xArray[ nPosControl , 11 ] } } &&,;
                           
         txControl     := {{"RangeMin"   , xArray[ nPosControl , 13 ] },;
                           {"RangeMax"   , xArray[ nPosControl , 15 ] },;
                           {"Value"      , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"    , xArray[ nPosControl , 19 ] },;
                           {"HelpId"     , xArray[ nPosControl , 21 ] },;
                           {"Visible"    , xArray[ nPosControl , 23 ] },;
                           {"Smooth"     , xArray[ nPosControl , 25 ] },;
                           {"Orientation", cOrientation               },;
                           {"BackColor"  , xArray[ nPosControl , 29 ] },;
                           {"ForeColor"  , xArray[ nPosControl , 31 ] },;
                           {"Marquee"    , xArray[ nPosControl , 35 ] },;
                           {"Velocity"   , xArray[ nPosControl , 37 ] } ;                           
                         }

      txControlEvent  := {}

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 25 .OR. CurrentControlName == "PLAYER"
      txControl0      := { {"Name"            , xArray[ nPosControl ,  3 ] },;
                           {"Row"             , xArray[ nPosControl ,  5 ] },;
                           {"Col"             , xArray[ nPosControl ,  7 ] },;
                           {"Width"           , xArray[ nPosControl ,  9 ] },;
                           {"Height"          , xArray[ nPosControl , 11 ] } } &&,;
                           
      txControl       := { {"File"            , xArray[ nPosControl , 13 ] },;
                           {"HelpId"          , xArray[ nPosControl , 15 ] },;
                           {"NoAutoSizeWindow", xArray[ nPosControl , 17 ] },;
                           {"NoAutoSizeMovie" , xArray[ nPosControl , 19 ] },;
                           {"NoErrorDlg"      , xArray[ nPosControl , 21 ] },;
                           {"NoMenu"          , xArray[ nPosControl , 23 ] },;
                           {"NoOpen"          , xArray[ nPosControl , 25 ] },;
                           {"NoPlayBar"       , xArray[ nPosControl , 27 ] },;
                           {"ShowAll"         , xArray[ nPosControl , 29 ] },;
                           {"ShowMode"        , xArray[ nPosControl , 31 ] },;
                           {"ShowName"        , xArray[ nPosControl , 33 ] },;
                           {"ShowPosition"    , xArray[ nPosControl , 35 ] } ;
                         }

      txControlEvent  := {}

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Open"}, {"Play"},;
                           {"PlayReverse"}, {"Stop"}, {"Pause"}, {"Close"}     ,;
                           {"Release"}, {"Eject"}, {"OpenDialog"}, {"Resume"}  ,;
                           {"SaveAs"}                                           ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 26 .OR. CurrentControlName == "IPADDRESS"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] }} && ,;
                           
       txControl      := { {"Value"        , xArray[ nPosControl , 13 ] },;
                           {"FontName"     , xArray[ nPosControl , 15 ] },;
                           {"FontSize"     , xArray[ nPosControl , 17 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 19 ] },;
                           {"FontBold"     , xArray[ nPosControl , 27 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 29 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 31 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 33 ] },;
                           {"HelpId"       , xArray[ nPosControl , 35 ] },;
                           {"TabStop"      , xArray[ nPosControl , 37 ] },;
                           {"Visible"      , xArray[ nPosControl , 39 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 21 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 23 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 25 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 27 .OR. CurrentControlName == "TIMER"
     
      txControl0      := { {"Name"    , xArray[ nPosControl , 3 ] },;
                           {"Interval", xArray[ nPosControl , 5 ] } ;
                         }
      txControl        := {}                  

      txControlEvent  := { {"Action"  , xArray[ nPosControl , 7 ] } }

      Methods         := { {"Release"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 28 .OR. CurrentControlName == "BUTTONEX"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl      := { {"Caption"      , xArray[ nPosControl , 13 ] },;
                           {"Picture"      , xArray[ nPosControl , 15 ] },;
                           {"Icon"         , xArray[ nPosControl , 17 ] },;
                           {"FontName"     , xArray[ nPosControl , 21 ] },;
                           {"FontSize"     , xArray[ nPosControl , 23 ] },;
                           {"FontBold"     , xArray[ nPosControl , 25 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 27 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 29 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 31 ] },;
                           {"FontColor"    , xArray[ nPosControl , 33 ] },;
                           {"Vertical"     , xArray[ nPosControl , 35 ] },;
                           {"LeftText"     , xArray[ nPosControl , 37 ] },;
                           {"UpperText"    , xArray[ nPosControl , 39 ] },;
                           {"Adjust"       , xArray[ nPosControl , 41 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 43 ] },;
                           {"BackColor"    , xArray[ nPosControl , 45 ] },;
                           {"NoHotLight"   , xArray[ nPosControl , 47 ] },;
                           {"Flat"         , xArray[ nPosControl , 49 ] },;
                           {"NoTransparent", xArray[ nPosControl , 51 ] },;
                           {"NoXPStyle"    , xArray[ nPosControl , 53 ] },;
                           {"TabStop"      , xArray[ nPosControl , 59 ] },;
                           {"HelpId"       , xArray[ nPosControl , 61 ] },;
                           {"Visible"      , xArray[ nPosControl , 63 ] },;
                           {"Default"      , xArray[ nPosControl , 65 ] },;
                           {"HandCursor"   , xArray[ nPosControl , 67 ] } ;
                         }

      txControlEvent  := { {"Action"       , xArray[ nPosControl , 19 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 55 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 57 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 29 .OR. CurrentControlName == "COMBOBOXEX"    
      
      txControl0      := { {"Name"           , xArray[ nPosControl ,  3 ] },;
                           {"Row"            , xArray[ nPosControl ,  5 ] },;
                           {"Col"            , xArray[ nPosControl ,  7 ] },;
                           {"Width"          , xArray[ nPosControl ,  9 ] },;
                           {"Height"         , xArray[ nPosControl , 11 ] }} &&,;
                           
        txControl     := { {"Items"          , xArray[ nPosControl , 13 ] },;
                           {"ItemSource"     , xArray[ nPosControl , 15 ] },;
                           {"Value"          , xArray[ nPosControl , 17 ] },;
                           {"ValueSource"    , xArray[ nPosControl , 19 ] },;
                           {"DisplayEdit"    , xArray[ nPosControl , 21 ] },;
                           {"ListWidth"      , xArray[ nPosControl , 23 ] },;
                           {"FontName"       , xArray[ nPosControl , 25 ] },;
                           {"FontSize"       , xArray[ nPosControl , 27 ] },;
                           {"FontBold"       , xArray[ nPosControl , 29 ] },;
                           {"FontItalic"     , xArray[ nPosControl , 31 ] },;
                           {"FontUnderLine"  , xArray[ nPosControl , 33 ] },;
                           {"FontStrikeOut"  , xArray[ nPosControl , 35 ] },;
                           {"ToolTip"        , xArray[ nPosControl , 37 ] },;
                           {"TabStop"        , xArray[ nPosControl , 53 ] },;
                           {"HelpId"         , xArray[ nPosControl , 55 ] },;
                           {"GripperText"    , xArray[ nPosControl , 57 ] },;
                           {"Break"          , xArray[ nPosControl , 59 ] },;
                           {"Visible"        , xArray[ nPosControl , 61 ] },;
                           {"Image"          , xArray[ nPosControl , 63 ] },;
                           {"BackColor"      , xArray[ nPosControl , 65 ] },;
                           {"FontColor"      , xArray[ nPosControl , 67 ] },;
                           {"ImageList"      , xArray[ nPosControl , 69 ] };                         
                         }

      txControlEvent  := { {"OnGotFocus"     , xArray[ nPosControl , 39 ] },;
                           {"OnChange"       , xArray[ nPosControl , 41 ] },;
                           {"OnLostFocus"    , xArray[ nPosControl , 43 ] },;
                           {"OnEnter"        , xArray[ nPosControl , 45 ] },;
                           {"OnDisplayChange", xArray[ nPosControl , 47 ] },;
                           {"OnListDisplay"  , xArray[ nPosControl , 49 ] },;
                           {"OnListClose"    , xArray[ nPosControl , 51 ] } ;
                         }

       Methods        := { {"Show"}, {"Hide"}, {"AddItem"}, {"DeleteItem"},;
                           {"DeleteAllItems"}, {"SetFocus"}, {"Release"}  ,;
                           {"SaveAs"}                                      ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 30 .OR. CurrentControlName == "BTNTEXTBOX"

      IF xArray[ nPosControl , 35 ] = ".T."
         cDataType := "NUMERIC"
      ELSEIF xArray[ nPosControl , 37 ] = ".T."
         cDataType := "PASSWORD"
      ELSE
         cDataType := "CHARACTER"
      ENDIF

      IF xArray[ nPosControl , 47 ] = ".T."
         cCaseConvert := "UPPER"
      ELSEIF xArray[ nPosControl , 49 ] = ".T."
         cCaseConvert := "LOWER"
      ELSE
         cCaseConvert := "NONE"
      ENDIF

      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
        txControl     := { {"Field"        , xArray[ nPosControl , 13 ] },;
                           {"Value"        , xArray[ nPosControl , 15 ] },;
                           {"Picture"      , xArray[ nPosControl , 19 ] },;
                           {"ButtonWidth"  , xArray[ nPosControl , 21 ] },;
                           {"FontName"     , xArray[ nPosControl , 23 ] },;
                           {"FontSize"     , xArray[ nPosControl , 25 ] },;
                           {"FontBold"     , xArray[ nPosControl , 27 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 29 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 31 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 33 ] },;
                           {"DataType"     , cDataType                },;
                           {"ToolTip"      , xArray[ nPosControl , 39 ] },;
                           {"BackColor"    , xArray[ nPosControl , 41 ] },;
                           {"FontColor"    , xArray[ nPosControl , 43 ] },;
                           {"MaxLength"    , xArray[ nPosControl , 45 ] },;
                           {"CaseConvert"  , cCaseConvert             },;
                           {"RightAlign"   , xArray[ nPosControl , 59 ] },;
                           {"Visible"      , xArray[ nPosControl , 61 ] },;
                           {"TabStop"      , xArray[ nPosControl , 63 ] },;
                           {"HelpId"       , xArray[ nPosControl , 65 ] },;
                           {"DisableEdit"  , xArray[ nPosControl , 67 ] },;
                           {"CueBanner"    , xArray[ nPosControl , 75 ] } ;
                         }

      txControlEvent  := { {"Action"       , xArray[ nPosControl , 17 ] },;
                           {"OnChange"     , xArray[ nPosControl , 53 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 51 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 55 ] },;
                           {"OnEnter"      , xArray[ nPosControl , 57 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"},;
                           {"Refresh"}, {"Save"}, {"SaveAS"}             ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 31 .OR. CurrentControlName == "HOTKEYBOX"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
     txControl      := {   {"Value"        , xArray[ nPosControl , 13 ] },;
                           {"FontName"     , xArray[ nPosControl , 15 ] },;
                           {"FontSize"     , xArray[ nPosControl , 17 ] },;
                           {"FontBold"     , xArray[ nPosControl , 19 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 21 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 23 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 25 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 27 ] },;
                           {"HelpId"       , xArray[ nPosControl , 31 ] },;
                           {"Visible"      , xArray[ nPosControl , 33 ] },;
                           {"TabStop"      , xArray[ nPosControl , 35 ] } ;
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 29 ] } }

       Methods        := { {"Show"}, {"Hide"}, {"Release"}, {"SaveAs"} }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 32 .OR. CurrentControlName == "GETBOX"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
      
      
                          
        txControl     := { {"Field"        , xArray[ nPosControl , 13 ] },;
                           {"Value"        , xArray[ nPosControl , 15 ] },;
                           {"Picture"      , xArray[ nPosControl , 17 ] },;
                           {"Valid"        , xArray[ nPosControl , 19 ] },;
                           {"Range"        , xArray[ nPosControl , 21 ] },;
                           {"ValidMessage" , xArray[ nPosControl , 23 ] },;
                           {"Message"      , xArray[ nPosControl , 25 ] },;
                           {"When"         , xArray[ nPosControl , 27 ] },;
                           {"ReadOnly"     , xArray[ nPosControl , 29 ] },;
                           {"FontName"     , xArray[ nPosControl , 31 ] },;
                           {"FontSize"     , xArray[ nPosControl , 33 ] },;
                           {"FontBold"     , xArray[ nPosControl , 35 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 37 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 39 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 41 ] },;
                           {"PassWord"     , xArray[ nPosControl , 43 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 45 ] },;
                           {"BackColor"    , xArray[ nPosControl , 47 ] },;
                           {"FontColor"    , xArray[ nPosControl , 49 ] },;
                           {"RightAlign"   , xArray[ nPosControl , 57 ] },;
                           {"Visible"      , xArray[ nPosControl , 59 ] },;
                           {"TabStop"      , xArray[ nPosControl , 61 ] },;
                           {"HelpId"       , xArray[ nPosControl , 63 ] },;
                           {"Image"        , xArray[ nPosControl , 69 ] },;
                           {"ButtonWidth"  , xArray[ nPosControl , 71 ] },;
                           {"Border"       , xArray[ nPosControl , 73 ] },;
                           {"Nominus"      , xArray[ nPosControl , 75 ] } ;                                                      
                         }
                         
                         
                         


      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 51 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 53 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 55 ] },;
                           {"Action"       , xArray[ nPosControl , 65 ] },;
                           {"Action2"      , xArray[ nPosControl , 67 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"},;
                           {"Refresh"}, {"Save"}, {"SaveAs"}             ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 33 .OR. CurrentControlName == "TIMEPICKER"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] } } &&,;
                           
       txControl      := { {"Value"        , xArray[ nPosControl , 11 ] },;
                           {"Field"        , xArray[ nPosControl , 13 ] },;
                           {"FontName"     , xArray[ nPosControl , 15 ] },;
                           {"FontSize"     , xArray[ nPosControl , 17 ] },;
                           {"FontBold"     , xArray[ nPosControl , 19 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 21 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 23 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 25 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 27 ] },;
                           {"ShowNone"     , xArray[ nPosControl , 29 ] },;
                           {"UpDown"       , xArray[ nPosControl , 31 ] },;
                           {"TimeFormat"   , xArray[ nPosControl , 33 ] },;
                           {"HelpId"       , xArray[ nPosControl , 43 ] },;
                           {"Visible"      , xArray[ nPosControl , 45 ] },;
                           {"TabStop"      , xArray[ nPosControl , 47 ] } ;
                         }

      txControlEvent  := { {"OnGotFocus"   , xArray[ nPosControl , 35 ] },;
                           {"OnChange"     , xArray[ nPosControl , 37 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 39 ] },;
                           {"OnEnter"      , xArray[ nPosControl , 41 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"SetFocus"}, {"Release"},;
                           {"Refresh"}, {"Save"}, {"SaveAS"}             ;
                         }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 34 .OR. CurrentControlName == "QHTM"
      txControl0      := { {"Name"    , xArray[ nPosControl ,  3 ] },;
                           {"Row"     , xArray[ nPosControl ,  5 ] },;
                           {"Col"     , xArray[ nPosControl ,  7 ] },;
                           {"Width"   , xArray[ nPosControl ,  9 ] },;
                           {"Height"  , xArray[ nPosControl , 11 ] } } &&,;
                           
        txControl     := { {"Value"   , xArray[ nPosControl , 13 ] },;
                           {"File"    , xArray[ nPosControl , 15 ] },;
                           {"Resource", xArray[ nPosControl , 17 ] },;
                           {"Border"  , xArray[ nPosControl , 21 ] },;
                           {"CWidth"  , xArray[ nPosControl , 23 ] },;
                           {"CHeight" , xArray[ nPosControl , 25 ] } ;
                         }

      txControlEvent  := { {"OnChange", xArray[ nPosControl , 19 ] } }

      Methods         := {}

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 35 .OR. CurrentControlName == "TBROWSE"
      txControl0      := { {"Name"           , xArray[ nPosControl ,  3 ] },;
                           {"Row"            , xArray[ nPosControl ,  5 ] },;
                           {"Col"            , xArray[ nPosControl ,  7 ] },;
                           {"Width"          , xArray[ nPosControl ,  9 ] },;
                           {"Height"         , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl      := { {"Headers"        , xArray[ nPosControl , 13 ] },;
                           {"ColSizes"       , xArray[ nPosControl , 15 ] },;
                           {"WorkArea"       , xArray[ nPosControl , 17 ] },;
                           {"Fields"         , xArray[ nPosControl , 19 ] },;
                           {"SelectFilter"   , xArray[ nPosControl , 21 ] },;
                           {"SelectFilterFor", xArray[ nPosControl , 23 ] },;
                           {"SelectFilterTo" , xArray[ nPosControl , 25 ] },;
                           {"Value"          , xArray[ nPosControl , 27 ] },;
                           {"FontName"       , xArray[ nPosControl , 29 ] },;
                           {"FontSize"       , xArray[ nPosControl , 31 ] },;
                           {"FontBold"       , xArray[ nPosControl , 33 ] },;
                           {"FontItalic"     , xArray[ nPosControl , 35 ] },;
                           {"FontUnderLine"  , xArray[ nPosControl , 37 ] },;
                           {"FontStrikeOut"  , xArray[ nPosControl , 39 ] },;
                           {"ToolTip"        , xArray[ nPosControl , 41 ] },;
                           {"BackColor"      , xArray[ nPosControl , 43 ] },;
                           {"FontColor"      , xArray[ nPosControl , 45 ] },;
                           {"Colors"         , xArray[ nPosControl , 47 ] },;
                           {"Edit"           , xArray[ nPosControl , 57 ] },;
                           {"Grid"           , xArray[ nPosControl , 59 ] },;
                           {"Append"         , xArray[ nPosControl , 61 ] },;
                           {"When"           , xArray[ nPosControl , 65 ] },;
                           {"Valid"          , xArray[ nPosControl , 67 ] },;
                           {"ValidMessages"  , xArray[ nPosControl , 69 ] },;
                           {"Message"        , xArray[ nPosControl , 71 ] },;
                           {"ReadOnly"       , xArray[ nPosControl , 73 ] },;
                           {"Lock"           , xArray[ nPosControl , 75 ] },;
                           {"Delete"         , xArray[ nPosControl , 77 ] },;
                           {"NoLines"        , xArray[ nPosControl , 79 ] },;
                           {"Image"          , xArray[ nPosControl , 81 ] },;
                           {"Justify"        , xArray[ nPosControl , 83 ] },;
                           {"HelpId"         , xArray[ nPosControl , 85 ] },;
                           {"Break"          , xArray[ nPosControl , 87 ] } ;
                         }

      txControlEvent  := { {"OnGotFocus"     , xArray[ nPosControl , 49 ] },;
                           {"OnChange"       , xArray[ nPosControl , 51 ] },;
                           {"OnLostFocus"    , xArray[ nPosControl , 53 ] },;
                           {"OnDblClick"     , xArray[ nPosControl , 55 ] },;
                           {"OnHeadClick"    , xArray[ nPosControl , 63 ] } ;
                         }

      Methods         := {}

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 36 .OR. CurrentControlName == "ACTIVEX"
      txControl0      := { {"Name"  , xArray[ nPosControl ,  3 ] },;
                           {"Row"   , xArray[ nPosControl ,  5 ] },;
                           {"Col"   , xArray[ nPosControl ,  7 ] },;
                           {"Width" , xArray[ nPosControl ,  9 ] },;
                           {"Height", xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl      := { {"ProgID", xArray[ nPosControl , 13 ] } ;
                         }

       txControlEvent := { { "", "" } }

       Methods        := {}

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 37 .OR. CurrentControlName == "PANEL"
      txControl0      := { {"Name"  , xArray[ nPosControl ,  3 ] },;
                           {"Row"   , xArray[ nPosControl ,  5 ] },;
                           {"Col"   , xArray[ nPosControl ,  7 ] },;
                           {"Width" , xArray[ nPosControl ,  9 ] },;
                           {"Height", xArray[ nPosControl , 11 ] } ;
                         }
         txControl      := {}                
                         

      txControlEvent  := { { "", "" } }

      Methods         := {}
      
      
    CASE CurrentControl == 38 .OR. CurrentControlName == "CHECKLABEL"
      IF xArray[ nPosControl , 59 ] =  "2"
         cAlignment := "RIGHT"
      ELSEIF xArray[ nPosControl , 59 ] = "3"
         cAlignment := "CENTER"
      ELSE
         cAlignment := "LEFT"
      ENDIF

      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
        txControl     := { {"Value"        , xArray[ nPosControl , 13 ] },;
                           {"AutoSize"     , xArray[ nPosControl , 21 ] },;
                           {"FontName"     , xArray[ nPosControl , 23 ] },;
                           {"FontSize"     , xArray[ nPosControl , 25 ] },;
                           {"FontBold"     , xArray[ nPosControl , 27 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 29 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 31 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 33 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 35 ] },;
                           {"BackColor"    , xArray[ nPosControl , 37 ] },;
                           {"FontColor"    , xArray[ nPosControl , 39 ] },;
                           {"Image"        , xArray[ nPosControl , 41 ] },;
                           {"HelpId"       , xArray[ nPosControl , 43 ] },;
                           {"Visible"      , xArray[ nPosControl , 45 ] },;
                           {"Border"       , xArray[ nPosControl , 47 ] },;
                           {"ClientEdge"   , xArray[ nPosControl , 49 ] },;
                           {"HScroll"      , xArray[ nPosControl , 51 ] },;
                           {"VScroll"      , xArray[ nPosControl , 53 ] },;
                           {"Transparent"  , xArray[ nPosControl , 55 ] },;
                           {"Blink"        , xArray[ nPosControl , 57 ] },;
                           {"Alignment"    , cAlignment                 },;                                                                                                                                                                                                                                         
                           {"LeftCheck"    , xArray[ nPosControl , 67 ] },;
                           {"Checked"      , xArray[ nPosControl , 69 ] } ;
                         }

      txControlEvent  := { {"Action"       , xArray[ nPosControl , 15 ] },;
                           {"OnMouseHover" , xArray[ nPosControl , 17 ] },;
                           {"OnMouseLeave" , xArray[ nPosControl , 19 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"Release"}, {"Refresh"}, {"SaveAs"} }  
      
      
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE CurrentControl == 39 .OR. CurrentControlName == "CHECKLISTBOX"
      txControl0      := { {"Name"         , xArray[ nPosControl ,  3 ] },;
                           {"Row"          , xArray[ nPosControl ,  5 ] },;
                           {"Col"          , xArray[ nPosControl ,  7 ] },;
                           {"Width"        , xArray[ nPosControl ,  9 ] },;
                           {"Height"       , xArray[ nPosControl , 11 ] } } &&,;
                           
       txControl       := {{"Items"        , xArray[ nPosControl , 13 ] },;
                           {"Value"        , xArray[ nPosControl , 15 ] },;
                           {"FontName"     , xArray[ nPosControl , 17 ] },;
                           {"FontSize"     , xArray[ nPosControl , 19 ] },;
                           {"ToolTip"      , xArray[ nPosControl , 21 ] },;
                           {"FontBold"     , xArray[ nPosControl , 29 ] },;
                           {"FontItalic"   , xArray[ nPosControl , 31 ] },;
                           {"FontUnderLine", xArray[ nPosControl , 33 ] },;
                           {"FontStrikeOut", xArray[ nPosControl , 35 ] },;
                           {"BackColor"    , xArray[ nPosControl , 37 ] },;
                           {"FontColor"    , xArray[ nPosControl , 39 ] },;
                           {"HelpId"       , xArray[ nPosControl , 43 ] },;
                           {"TabStop"      , xArray[ nPosControl , 45 ] },;
                           {"Visible"      , xArray[ nPosControl , 47 ] },;
                           {"Sort"         , xArray[ nPosControl , 49 ] },;
                           {"MultiSelect"  , xArray[ nPosControl , 51 ] },;
                           {"CheckboxItem" , xArray[ nPosControl , 53 ] },;
                           {"ItemHeight"   , xArray[ nPosControl , 55 ] } ;                                                                              
                         }

      txControlEvent  := { {"OnChange"     , xArray[ nPosControl , 23 ] },;
                           {"OnGotFocus"   , xArray[ nPosControl , 25 ] },;
                           {"OnLostFocus"  , xArray[ nPosControl , 27 ] },;
                           {"OnDblClick"   , xArray[ nPosControl , 41 ] } ;
                         }

      Methods         := { {"Show"}, {"Hide"}, {"AddItem"}, {"DeleteItem"}, {"DeleteAllItems"}, {"SetFocus"}, {"Release"}, {"SaveAs"} }
 
      
      

   ENDCASE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check if have Event or Property that we set
   IF txControlEvent = NIL .OR. txControl = NIL
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Load all Event to Grid #2 (Tab 2-Events)
   xVal := ObjectInspector.xGrid_2.Value

   ObjectInspector.xGrid_2.DeleteAllitems

   aSort( txControlEvent,,, { | x, y | x[ 1 ] < y[ 1 ] } )

   IF Len( txControlEvent ) > 0
      aEval( txControlEvent, { | x | ObjectInspector.xGrid_2.AddItem( x ) } )
   ENDIF

   ObjectInspector.xGrid_2.Value := xVal
   xVal                          := ObjectInspector.xGrid_1.Value
   cValue                        := GetColValue( "XGRID_1", "ObjectInspector", 1 )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Load all Property to Grid #1 (Tab 1-Properties)
   ObjectInspector.xGrid_1.DeleteAllitems

   aSort( txControl,,, { | x, y | x[ 1 ] < y[ 1 ] } )
   
   *******
   *IF CurrentControlName == "BUTTON"
      aEval( txControl0,{ |x| ObjectInspector.xGrid_1.AddItem( RetQuota( x ) ) } )
   *ENDIF
   ******   
   aEval( txControl,{ |x| ObjectInspector.xGrid_1.AddItem( RetQuota( x ) ) } )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Load all Method to Grid #3 (Tab 3-Methods)
   ObjectInspector.xGrid_3.DeleteAllitems

   IF Len( Methods ) > 0
      aEval( Methods, { | x | ObjectInspector.xGrid_3.AddItem( x ) } )
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //?
   ObjectInspector.xGrid_1.Value := xVal

   FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

       ObjectInspector.xGrid_1.Value := x

       IF GetColValue( "XGRID_1", "ObjectInspector", 1 ) = cValue
          x := ObjectInspector.xGrid_1.ItemCount
       ENDIF

   NEXT x

RETURN


*------------------------------------------------------------*
FUNCTION RetQuota( x AS ARRAY )
*------------------------------------------------------------*
   LOCAL aTemp AS ARRAY := {}

   // MsgBox( "VALTYPE X= "+ValType(X)+ " LEN= "+STR(Len(X)) )
   // MsgBox( "X1= "+X[1]+ "X2= "+X[2] )
   // MsgBox( "val1= "+RIGHT(X[2],1)+ " val2= "+LEFT(X[2],1) )

   IF Right( x[ 2 ], 1 ) = '"' .AND. Left( x[ 2 ], 1 ) = '"'
      aAdd( aTemp, x[ 1 ] )
      aAdd( aTemp, SubStr( x[ 2 ], 2, Len( x[ 2 ] )- 2 ) )

   ELSEIF Right( x[ 2 ], 1 ) = "'" .AND. Left( x[ 2 ], 1 ) = "'"
      aAdd( aTemp, x[ 1 ])
      aAdd( aTemp, SubStr( x[ 2 ], 2, Len( x[ 2 ]) - 2 ) )

   ELSE
      aAdd( aTemp, x[ 1 ] )
      aAdd( aTemp, x[ 2 ] )
   ENDIF

   // MsgBox( "aTemp1= "+aTemp[1] + " aTemp2= " + aTemp[2] )
   // MsgBox( "ValType aTemp= " + ValType( aTemp )+ " LEN= " + Str( Len( aTemp ) ) )

RETURN( aTemp )


*------------------------------------------------------------*
FUNCTION cTypeOfControl( nPos AS NUMERIC )
*------------------------------------------------------------*
LOCAL aControls AS ARRAY := { "NIL"                ,; //  1
                              "BUTTON"             ,; //  2
                              "CHECKBOX"           ,; //  3
                              "LISTBOX"            ,; //  4
                              "COMBOBOX"           ,; //  5
                              "CHECKBUTTON"        ,; //  6
                              "GRID"               ,; //  7
                              "SLIDER"             ,; //  8
                              "SPINNER"            ,; //  9
                              "IMAGE"              ,; // 10
                              "TREE"               ,; // 11
                              "DATEPICKER"         ,; // 12
                              "TEXTBOX"            ,; // 13
                              "EDITBOX"            ,; // 14
                              "LABEL"              ,; // 15
                              "BROWSE"             ,; // 16
                              "RADIOGROUP"         ,; // 17
                              "FRAME"              ,; // 18
                              "TAB"                ,; // 19
                              "ANIMATEBOX"         ,; // 20
                              "HYPERLINK"          ,; // 21
                              "MONTHCALENDAR"      ,; // 22
                              "RICHEDITBOX"        ,; // 23
                              "PROGRESSBAR"        ,; // 24
                              "PLAYER"             ,; // 25
                              "IPADDRESS"          ,; // 26
                              "TIMER"              ,; // 27
                              "BUTTONEX"           ,; // 28
                              "COMBOBOXEX"         ,; // 29
                              "BTNTEXTBOX"         ,; // 30
                              "HOTKEYBOX"          ,; // 31
                              "GETBOX"             ,; // 32
                              "TIMEPICKER"         ,; // 33
                              "QHTM"               ,; // 34
                              "TBROWSE"            ,; // 35
                              "ACTIVEX"            ,; // 36
                              "PANEL"              ,; // 37
                              "CHECKLABEL"         ,; // 38
                              "CHECKLISTBOX"       ,; // 39
                              "NIL"                 ; // 40
                             }

   // out of array range
   IF nPos < 1 .OR. nPos > Len( aControls )
      nPos := 1
   ENDIF

RETURN( aControls[ nPos ] )


*------------------------------------------------------------*
FUNCTION UciFillGrid( ControlName AS STRING )
*------------------------------------------------------------*
   LOCAL x              AS NUMERIC
   LOCAL x1             AS STRING
   LOCAL cType          AS STRING
   LOCAL nValue         AS NUMERIC
   LOCAL nPos           AS NUMERIC
   LOCAL xVal           AS USUAL            //? VarType
   LOCAL txControl      AS ARRAY   := {}
   LOCAL txControlEvent AS ARRAY   := {}

   lUpdate        := .T.
   cType          := xTypeControl( ControlName )
   nValue         := aScan( aUciControls, cType )
   nPosControl     := xControle( ControlName )

    //MsgBox( "ControlName=" + ControlName )
    //MsgBox( "cType= " + cType )

   FOR x := 1 TO ObjectInspector.xCombo_1.ItemCount

       X1 := AllTrim( ObjectInspector.xCombo_1.Item( x ) )

       IF X1 == ControlName
          ObjectInspector.xCombo_1.Value := x
          x                              := ObjectInspector.xCombo_1.ItemCount
       ENDIF

   NEXT x

   aAdd( txControl, { "Name"  , xArray[ nPosControl ,  3 ] } )
   aAdd( txControl, { "Row"   , xArray[ nPosControl ,  5 ] } )
   aAdd( txControl, { "Col"   , xArray[ nPosControl ,  7 ] } )
   aAdd( txControl, { "Width" , xArray[ nPosControl ,  9 ] } )
   aAdd( txControl, { "Height", xArray[ nPosControl , 11 ] } )

    //MsgBox( "len= " + Str( Len( txControl ) ) )
   nPos := 10
   FOR x := 1 TO Len( aUciProps[ nValue ] )
       nPos := nPos + 2
       aAdd( txControl, { xArray[ nPosControl , nPos ], xArray[ nPosControl , nPos + 1 ] } )
   NEXT x

   // MsgBox("len= " + Str( Len( txControl ) ) )
   FOR x := 1 TO Len( aUciEvents[ nValue ] )
       nPos := nPos + 2
       aAdd( txControlEvent, { xArray[ nPosControl , nPos ], xArray[ nPosControl , nPos + 1 ] } )
   NEXT x

   xVal := ObjectInspector.xGrid_1.Value

   ObjectInspector.xGrid_1.DeleteAllitems

   //aSort( txControl,,,{|x,y| x[1] < y[1]})

   aEval( txControl, { |x| ObjectInspector.xGrid_1.AddItem( x ) } )

   ObjectInspector.xGrid_1.Value := xVal
   xVal                          := ObjectInspector.xGrid_2.Value

   ObjectInspector.xGrid_2.DeleteAllitems

   // aSort( txControlEvent,,, { | x, y | x[ 1 ] < y[ 1 ] } )

   IF Len( txControlEvent ) > 0
      aEval( txControlEvent, { | x | ObjectInspector.xGrid_2.AddItem( x ) } )
   ENDIF

   ObjectInspector.xGrid_2.Value := xVal

RETURN( NIL )
