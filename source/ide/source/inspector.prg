#include "minigui.ch"
#include "ide.ch"

DECLARE WINDOW ObjectInspector
//declare window logform


MEMVAR MVar    // Public and Macro Expansion
MEMVAR OldVar  // Public and Macro Expansion

*------------------------------------------------------------*
PROCEDURE xGridEventEdit()
*------------------------------------------------------------*
   LOCAL cnt_s  AS NUMERIC   := 0
   LOCAL aWrk   AS ARRAY     := {}
   LOCAL blskA1 AS CODEBLOCK := { |k| aEval( k, { | x, y | iif( Upper(x) == Upper( AllTrim( A1 ) ), cnt_s := y, "" ) } ) }

   IF ! IsWindowDefined( Form_1 )
      RETURN
   ENDIF

   A1 := GetColValue( "XGRID_2", "ObjectInspector", 1 )
   A2 := GetColValue( "XGRID_2", "ObjectInspector", 2 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

   aWrk := { "OnInit","OnRelease","OnInteractiveClose","OnMouseClick"        ,;
             "OnMouseDrag","OnMouseMove","OnDropFiles","OnSize"              ,;
             "OnMaximize","OnMinimize","OnPaint","OnNotifyClick"             ,;
             "OnGotFocus","OnLostFocus","OnScrollUp","OnScrollDown"          ,;
             "OnScrollLeft","OnScrollRight","OnHScrollBox","OnVScrollBox"    ,;
             "Action","OnChange","OnDisplayChange","OnSelect"                ,;
             "OnListDisplay","OnListClose","OnEnter","OnVScroll"             ,;
             "OnDblClick","OnRestore","OnMove","OnHeadClick"                 ,;
             "OnQueryData","Action2","OnScroll","OnMouseHover","OnMouseLeave",;
             "OnCheckBoxClicked"                                                ;
           }

   Eval( blskA1, aWrk )

   IF cnt_s > 0

      cnt_s    := 0
      aWrk     := {}
      lChanges := .T.

      DECLARE WINDOW xGridEvenTxt
      LOAD WINDOW xGridEvenTxt

      xGridEvenTxt.Edit_1.Value  := A2
      xGridEvenTxt.Label_1.Value := A1 + ":"

      xGridEvenTxt.Edit_1.SetFocus
      xGridEvenTxt.Center

      ACTIVATE WINDOW xGridEvenTxt

      RETURN
   ENDIF

   *******
   *******Uci events
   *******
   DECLARE WINDOW xGridEvenTxt
   LOAD WINDOW xGridEvenTxt

   xGridEvenTxt.Edit_1.Value  := A2
   xGridEvenTxt.Label_1.Value := A1 + ":"

   xGridEvenTxt.Edit_1.SetFocus
   xGridEvenTxt.Center
   ACTIVATE WINDOW xGridEvenTxt

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropEdit()
*------------------------------------------------------------*
   LOCAL Lfnt     AS USUAL     := GetFonts()   //? VarType
   LOCAL aWrk     AS ARRAY     := {}
   LOCAL cnt_s    AS NUMERIC   := 0
   LOCAL blskA1   AS CODEBLOCK
   LOCAL blskA3   AS CODEBLOCK
   LOCAL A2       AS STRING
   LOCAL xPosBrw  AS NUMERIC
   LOCAL Color    AS ARRAY
   LOCAL xColor   AS STRING
   LOCAL coBrw    AS USUAL                     //? VarType
   LOCAL xGetBox  AS ARRAY
   LOCAL x        AS NUMERIC
   LOCAL V1       AS STRING
   LOCAL V2       AS STRING

   IF ! IsWindowDefined( Form_1 )
      RETURN
   ENDIF
   


   A1       := GetColValue( "XGRID_1", "ObjectInspector", 1 )
   A2       := GetColValue( "XGRID_1", "ObjectInspector", 2 )
   A3       := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
   A4       := xTypeControl( A3 )
   lChanges := .T.

   blskA1   := { |k| aEval( k, { |x,y| iif( Upper( x ) == AllTrim( Upper( A1 ) ), cnt_s := y, "" ) } ) }
   blskA3   := { |k| aEval( k, { |x,y| iif( Upper( x ) == AllTrim( Upper( A3 ) ), cnt_s := y, "" ) } ) }

   ***********
   *********LOGICAL CONTROLS
   ***********
   aWrk := { "AutoRelease","Break","Focused" ,"HelpButton","MaxButton","MinButton","Sizable","SysMenu","TitleBar"       ,;
             "TopMost","Visible","Flat","FontBold","FontItalic","FontStrikeOut","FontUnderLine","TabStop","Transparent" ,;
             "Visible","Sort","MultiSelect","DisplayEdit","AllowEdit","Virtual","NoLines","Wrap","ReadOnly","Stretch"   ,;
             "ShowNone","UpDown","RightAlign","AutoSize","AllowAppend","AllowDelete","Lock","VScrollBar"                ,;
             "Opaque","Autoplay","Center","HandCursor" ,"NoToday","NoTodayCircel"                                       ,;
             "WeekNumbers","Smooth","Vertical","NoAutoSizeWindow","NoAutoSizeMovie"                                     ,;
             "ShowPosition","ShowName","ShowMode","ShowAll","NoPlayBar","NoOpen"                                        ,;
             "NoMenu","NoErrorDlg","NoRootButton" ,"PassWord","CenterAlign"                                             ,;
             "Buttons","HotTrack","WhiteBackground","LeftJustify","Horizontal"                                          ,;
             "PlainText","HScrollBar","VScrollBar","Wrap","NoTabStop","Default","LeftJustify","ThreeState"              ,;
             "ItemIds","NoHotLight","NoTransparent","NoXPStyle","UpperText","LeftText","Adjust","NoTodayCircle","Append",;
             "Delete","Edit","Grid","Border","ClientEdge","HScroll","VScroll","Blink"                                   ,;
             "ShowHeaders","MultiLine","Palette","Invisible","DragItems","DisableEdit","CellNavigation","CheckBoxes"    ,;
             "Marquee","Checked","LeftCheck","Nominus","AdjustImage","MultiTab","MultiColumn","NoSortHeaders","PaintDoubleBuffer";
            }

   Eval( blskA1, aWrk )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ( A1 = "ReadOnly"    .AND. xTypeControl( A3 ) = "TBROWSE"    )  .OR. ;
      ( A1 = "ReadOnly"    .AND. xTypeControl( A3 ) = "RADIOGROUP" )  .OR. ;
      ( A1 = "InPlaceEdit" .AND. xTypeControl( A3 ) = "BROWSE"     )

      cnt_s := 0
      aWrk  := {}
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cnt_s > 0 .OR. ( A1 = "Value" .AND. xTypeControl( A3 ) = "CHECKBOX")
      cnt_s := 0
      aWrk  := {}

      DECLARE WINDOW xGridPropEdit
      LOAD WINDOW xGridPropEdit

      xGridPropEdit.Combo_1.DeleteAllitems

      xGridPropEdit.Label_1.Value        := A1 + ":"
      xGridPropEdit.RadioGroup_1.Visible := .F.
      xGridPropEdit.Text_1.Visible       := .F.

      IF A2 = ".T."
         A4 := ".F."                               //? Was Assigned xTypeControl( A3 ) but now changes usage
         xGridPropEdit.Combo_1.AddItem( ".T." )
         xGridPropEdit.Combo_1.AddItem( ".F." )
      ELSE
         A4 := ".T."
         xGridPropEdit.Combo_1.AddItem( ".F." )
         xGridPropEdit.Combo_1.AddItem( ".T." )
      ENDIF
      xGridPropEdit.Combo_1.Value := 1
      xGridPropEdit.Center

      ACTIVATE WINDOW xGridPropEdit
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "CaseConvert"
      DECLARE WINDOW xGridPropCombo
      LOAD WINDOW xGridPropCombo

      xGridPropCombo.Combo_1.DeleteAllitems

      xGridPropCombo.Label_1.Value        := A1 + ":"
      xGridPropCombo.RadioGroup_1.Visible := .F.
      xGridPropCombo.Text_1.Visible       := .F.
      aWrk                                := { "LOWER", "NONE", "UPPER" }

      aEval( aWrk,{ |x| xGridPropCombo.Combo_1.AddItem( x ) } )
      xGridPropCombo.Combo_1.Value := aScan( aWrk, A2 )
      aWrk                         := {}
      xGridPropCombo.Center

      ACTIVATE WINDOW xGridPropCombo
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "DataType"
      DECLARE WINDOW xGridPropCombo
      LOAD WINDOW xGridPropCombo

      xGridPropCombo.Combo_1.DeleteAllitems

      xGridPropCombo.Label_1.Value        := A1 + ":"
      xGridPropCombo.RadioGroup_1.Visible := .F.
      xGridPropCombo.Text_1.Visible       := .F.

      IF xTypeControl( A3 ) == "TEXTBOX"
         aWrk := { "CHARACTER", "DATE", "NUMERIC", "PASSWORD" }
      ELSE
         aWrk := { "CHARACTER","PASSWORD","NUMERIC" }   //BTNTEXTBOX
      ENDIF

      aEval( aWrk, { | x | xGridPropCombo.Combo_1.AddItem( x ) } )

      xGridPropCombo.Combo_1.Value := aScan( aWrk, A2 )
      aWrk                         := {}
      xGridPropCombo.Center

      ACTIVATE WINDOW xGridPropCombo
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 == "FontName" .OR. A1 == "Font"                                // Add by Pier 24/05/2006

      DECLARE WINDOW xGridPropCombo
      LOAD WINDOW xGridPropCombo

      xGridPropCombo.Combo_1.DeleteAllitems

      xGridPropCombo.Label_1.Value := A1+":"

      aEval( lfnt, { | x | xGridPropCombo.Combo_1.AddItem( x ) } )

      xGridPropCombo.Combo_1.Value      := aScan( lfnt, A2 )
      xGridPropCombo.Label_2.Visible    := .T.
      xGridPropCombo.RadioGroup_1.Value := iif( isValueTxt( A3, A1 ) = .T., 1, 2 )
      xGridPropCombo.Text_1.Value       := A2

      xGridPropCombo.Center

      ACTIVATE WINDOW xGridPropCombo
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "BackColor"           .OR. ;
      A1 = "TitleBackColor"      .OR. ;
      A1 = "TitleFontColor"      .OR. ;
      A1 = "FontColor"           .OR. ;
      A1 = "LineColor"           .OR. ;
      A1 = "DynamicBackColor"    .OR. ;
      A1 = "DynamicForeColor"    .OR. ;
      A1 = "BackGroundColor"     .OR. ;
      A1 = "TrailingFontcolor"   .OR. ;
      A1 = "ForeColor"

      IF A1 = "DynamicBackColor" .OR. A1 = "DynamicForeColor"
         DECLARE WINDOW xGridPropTxt
         LOAD WINDOW    xGridPropTxt

         xGridPropTxt.Text_1.Value       := A2
         xGridPropTxt.Label_1.Value      := A1 + ":"
         xGridPropTxt.RadioGroup_1.Value := iif( isValueTxt( A3, A1 )= .T., 1, 2 )

         xGridPropTxt.Center
         ACTIVATE WINDOW xGridPropTxt
         RETURN
      ENDIF

      IF xTypeControl( A3 ) # "GETBOX" .AND. xTypeControl( A3 ) # "TEXTBOX"

         Color := GetColor( Str2Array( GetColValue("XGRID_1","ObjectInspector", 2 ) ) )

         IF Color[1] # Nil
            xColor := "{"+ AllTrim(Str(Color[1]))+","+ AllTrim(Str(Color[2]))+","+ AllTrim(Str(Color[3]))+"}"
            SetColValue("XGRID_1","ObjectInspector", 2, xColor )
            SavePropControl( A3, xcolor, A1 )
         ELSE
            IF MsgYesNo( "Restore defaults?", "HMGS-IDE" )
               SetColValue( "XGRID_1", "ObjectInspector", 2, "NIL" )
               SavePropControl( A3, "NIL", A1 )
            ENDIF
         ENDIF

         IF Upper( Left( A3, 4 ) ) # "FORM"

            IF xTypeControl( A3 ) # "TBROWSE"
               SetProperty( "Form_1", A3, A1, iif( Color[1] # Nil, color, NIL ) )
            ELSE

               IF A1 = "BackColor"
                  // MsgBox("A3= "+ A3+ " v1= "+atbrowse[ 1, 2 ]+ " v2= "+ atbrowse[ 1, 3 ] )
                  xPosBrw := aScan( aTbrowse[ 1 ], A3 )
                  // MsgBox("str(xposbrw) =" + str(xposbrw) )
                  // cObrw := atbrowse[ 1, xposbrw ]
                  // MsgBox("val= "+ cObrw+ " valtype = " + ValType(&cObrw) )
                  cObrw := aOtbrowse[ 1, xPosBrw ]
                  IF Color[ 1 ] # NIL
                     cObrw:SetColor( { 2 }, { RGB( Color[1], Color[2], Color[3] ) } )
                  ELSE
                     // PUT DEFAULT COLOR WHITE
                     cObrw:SetColor( { 2 }, { RGB( 255, 255, 255 ) } )
                  ENDIF
               ENDIF

               IF A1 = "FontColor"
                  // MsgBox( "A3= " + A3 + " v1= " + aTbrowse[ 1, 2 ]+ " v2= "+ aTbrowse[ 1, 3 ] )
                  xPosBrw := aScan( aTbrowse[ 1 ], A3 )
                  // MsgBox( "Str( xPosBrw ) =" + Str( xPosBrw ) )
                  // cObrw := aTbrowse[ 1, xPosBrw ]
                  // MsgBox( "Val= " + cObrw + " ValType = " + ValType( &cObrw ) )
                  cObrw := aOtbrowse[ 1, xPosBrw ]
                  IF Color[ 1 ] # NIL
                     cObrw:SetColor( { 1 }, { RGB( Color[1], Color[2], Color[3] ) } )
                  ELSE
                     // PUT DEFAULT COLOR BLACK
                     cObrw:SetColor( { 1 }, { RGB( 0, 0, 0 ) } )
                  ENDIF
               ENDIF
            ENDIF

            IF xTypeControl( A3 ) = "TAB"
               UpdateTab( GetControlIndex( A3, "FORM_1" ) )
            ENDIF
         ELSE
            HIDE WINDOW FORM_1

            //? fontcolor not work in control radiogroup ( need to change to all handles of control)
            SetProperty( "Form_1", Upper( A1 ), iif( Color[1] # Nil, Color, NIL ) )

            SHOW WINDOW FORM_1
         ENDIF
         RETURN
      ELSE
         DECLARE WINDOW xGridGetBox
         LOAD WINDOW xGridGetBox

         IF xTypeControl( A3 ) # "GETBOX"
            xGridGetBox.Title := "Choose colors of TextBox"
         ENDIF

         IF A1 =  "BackColor"
            xGridGetBox.Label_1.Value := "aBackColor"
            xGridGetBox.Label_2.Value := "aReadOnlyBackColor"
            xGridGetBox.Label_3.Value := "aActiveBackColor"
         ELSE
            xGridGetBox.Label_1.Value := "aFontColor"
            xGridGetBox.Label_2.Value := "aReadOnlyFontColor"
            xGridGetBox.Label_3.Value := "aActiveFontColor"
         ENDIF

         xGetBox := LoadGetBox( A2 )

         IF Len( xGetBox[ 1 ] ) > 0
            xGridGetBox.Text_1.Value := xGetBox[1]
         ENDIF

         IF Len( xGetBox[ 2 ] ) > 0 .OR. Len( xGetBox[ 3 ] ) > 0
            xGridGetBox.Text_2.Value  := xGetBox[ 2 ]
            xGridGetBox.Text_3.Value  := xGetBox[ 3 ]
            xGridGetBox.check_1.Value := .T.
         ELSE
            xGridGetBox.Text_2.Enabled   := .F.
            xGridGetBox.Text_3.Enabled   := .F.
            xGridGetBox.Button_5.Enabled := .F.
            xGridGetBox.Button_6.Enabled := .F.
         ENDIF

         ACTIVATE WINDOW xGridGetBox
         RETURN
      ENDIF
   ENDIF

***********
*********** Numeric Controls
***********

   aWrk := { "Col","Height","Row","Width","FontSize","Increment","Spacing","Interval","MaxLength"  ,;
             "VirtualHeight","VirtualWidth","PageCount","Size","Indent","ItemHeight","ButtonWidth" ,;
             "MinWidth","MinHeight","MaxWidth","MaxHeight","RangeMax","RangeMin","Velocity"         ;
           }

   Eval( blskA1, aWrk )

   IF cnt_s > 0
      cnt_s := 0
      aWrk  := {}

      DECLARE WINDOW xGridPropNum
      LOAD WINDOW xGridPropNum

      SetProperty( "xGridPropNum", "SPINNER_1", "RANGEMAX", 10000 )

      IF ! isVarNum( A2 )
         xGridPropNum.Text_1.Value       := A2
         xGridPropNum.RadioGroup_1.Value := 2
      ELSE
         xGridPropNum.Spinner_1.Value    := Val( A2 )
         xGridPropNum.RadioGroup_1.Value := 1
      ENDIF

      xGridPropNum.Label_1.Value := A1 + ":"
      xGridPropNum.Center
      aWrk := {}
      ACTIVATE WINDOW xGridPropNum
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "Value" .AND. xTypeControl( A3 ) == "BROWSE"      .OR. ;
      A1 = "Value" .AND. xTypeControl( A3 ) == "RADIOGROUP"  .OR. ;
      A1 = "Value" .AND. xTypeControl( A3 ) == "PROGRESSBAR" .OR. ;
      A1 = "Value" .AND. xTypeControl( A3 ) == "TREE"        .OR. ;
      A1 = "Value" .AND. xTypeControl( A3 ) == "HOTKEYBOX"   .OR. ;
      A1 = "Value" .AND. xTypeControl( A3 ) == "TBROWSE"

      DECLARE WINDOW xGridPropNum
      LOAD WINDOW xGridPropNum

      SetProperty( "xGridPropNum", "SPINNER_1", "RANGEMAX", 10000 )

      xGridPropNum.Spinner_1.Value := Val( A2 )
      xGridPropNum.Label_1.Value    := A1 + ":"

      xGridPropNum.Center
      xGridPropNum.Text_1.Enabled       := .F.
      xGridPropNum.RadioGroup_1.Enabled := .F.

      ACTIVATE WINDOW xGridPropNum
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   /* Added 28/01/2007 AM */
   IF A1 $ ( "Fields;Widths;Headers;DatabaseName;WorkArea;DatabasePath" )

      IF xTypeControl( A3 ) == "BROWSE"
         Pick_Fld_FW( A1, A2, A3, A4 )
         RETURN
      ENDIF
   ENDIF
   /* Revized 31/03/2007 AM */

*********
*********Text Controls
*********

   aWrk := {"Cursor","GripperText","Icon","NotifyIcon","NotifyTooltip","Title","Caption","HelpId","Name","Picture","ToolTip";
           ,"Items","Image","Justify","InputMask","Format","Valid","ValidMessages";
           ,"ReadOnlyFields","Options","Address","File","ItemSource","Field" ,"NodeImages","ItemImages";
           ,"ColumnWhen","ColumnValid" ,"Format","InputMask","ItemCount","ColumnControls";
           ,"When" ,"Icon","DateFormat","ValueSource","ListWidth","PageImages","Message","Range";
           ,"TimeFormat","PageCaptions","Value","ImageList","ColSizes","Colors","Fields","SelectFilter";
           ,"SelectFilterFor","SelectFilterTo","DatabasePath","WorkArea","HeaderImage","InputItems","DisplayItems","ProgId";
           ,"PageToolTips","CheckboxItem","LockColumns", "CueBanner" }

   Eval( blskA1, aWrk )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "InplaceEdit" .AND. xTypeControl( A3 ) = "GRID"
      cnt_s := 1
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cnt_s > 0
      cnt_s := 0
      aWrk  := {}

      DECLARE WINDOW xGridPropTxt
      LOAD WINDOW    xGridPropTxt

      xGridPropTxt.Text_1.Value       := A2
      xGridPropTxt.Label_1.Value      := A1 + ":"
      xGridPropTxt.RadioGroup_1.Value := iif( isValueTxt( A3, A1 )= .T., 1, 2 )

      IF A1 = "CueBanner" .AND. xTypeControl( A3 ) = "BTNTEXTBOX"
         xGridPropTxt.RadioGroup_1.Value := 1
      ENDIF
      
      IF A1 = "Options" .AND. xTypeControl( A3 ) = "RADIO"
         xGridPropTxt.RadioGroup_1.ReadOnly := { .T., .F. }
      ENDIF

      IF ( A1 == "Picture" .OR. A1 == "Icon" ) .AND. xTypeControl( A3 ) # "GETBOX"
         xGridPropTxt.Button_3.Visible := .T.
      ENDIF

      IF A1 == "Image" .AND. xTypeControl( A3 ) = "GETBOX"
         xGridPropTxt.Button_3.Visible := .T.
      ENDIF

      xGridPropTxt.Text_1.SetFocus
      xGridPropTxt.Center
      ACTIVATE WINDOW xGridPropTxt
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   aWrk := { "Widths", "Headers" }   // this is for control grid

   Eval( blskA1, aWrk )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF cnt_s > 0 .AND. xTypeControl( A3 ) # "BROWSE"
      cnt_s := 0
      aWrk  := {}

      DECLARE WINDOW xGridPropTxt
      LOAD WINDOW    xGridPropTxt

      xGridPropTxt.Text_1.Value       := A2
      xGridPropTxt.Label_1.Value      := A1 + ":"
      xGridPropTxt.RadioGroup_1.Value := iif( isValueTxt( A3, A1 ) = .T., 1, 2 )

      xGridPropTxt.Center
      ACTIVATE WINDOW xGridPropTxt
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ( A1 = "ReadOnly" .AND. xTypeControl( A3 ) == "TBROWSE"    ) .OR. ;
      ( A1 = "ReadOnly" .AND. xTypeControl( A3 ) == "RADIOGROUP" ) .OR. ;
      ( A1 = "WorkArea" .AND. xTypeControl( A3 ) == "TBROWSE"    )

      DECLARE WINDOW xGridPropTxt
      LOAD WINDOW   xGridPropTxt

      xGridPropTxt.Text_1.Value  := A2
      xGridPropTxt.Label_1.Value := A1 + ":"

      xGridPropTxt.Center
      ACTIVATE WINDOW xGridPropTxt
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   aWrk := { "Label", "Text", "Edit", "RicheditBox", "Hyperlink", "MonthCal", "IpAddress", "GetBox", "DatePicker", "TimePicker" }

   Eval( blskA3, aWrk )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "Value" .AND. cnt_s > 0

      cnt_s := 0
      aWrk  := {}

      DECLARE WINDOW xGridPropTxt
      LOAD WINDOW   xGridPropTxt

      xGridPropTxt.Text_1.Value  := A2
      xGridPropTxt.Label_1.Value := A1 + ":"

      xGridPropTxt.Center
      ACTIVATE WINDOW xGridPropTxt
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "WindowType"
      DECLARE WINDOW xGridPropWin
      LOAD WINDOW xGridPropWin

      xGridPropWin.Combo_1.Value := aScan({"CHILD","MAIN ","MODAL","SPLITCHILD","STANDARD","MDI ","MAINMDI","MDICHILD" }, A2 )
      xGridPropWin.Label_1.Value := A1 + ":"

      xGridPropWin.Center
      ACTIVATE WINDOW xGridPropWin
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "Orientation"
      DECLARE WINDOW xGridPropSli
      LOAD WINDOW   xGridPropSli

      xGridPropSli.Combo_1.Value := aScan( { "HORIZONTAL", "VERTICAL" }, A2 )
      xGridPropSli.Label_1.Value := A1 + ":"

      xGridPropSli.Center
      ACTIVATE WINDOW xGridPropSli
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "TickMarks"
      DECLARE WINDOW xGridPropSli2
      LOAD WINDOW   xGridPropSli2

      A3 := ObjectInspector.xGrid_1.Value

      FOR X := 1 TO ObjectInspector.xGrid_1.ItemCount
         ObjectInspector.xGrid_1.Value := x
         v1                            := GetColValue("XGRID_1","ObjectInspector",1)

         IF v1 = "Orientation"
            v2 := GetColValue( "XGRID_1", "ObjectInspector", 2 )
         ENDIF

      NEXT X

      ObjectInspector.xGrid_1.Value := A3

      IF v2 = "VERTICAL"
         xGridPropSli2.Combo_1.DeleteAllitems

         aWrk := {"RIGHT","BOTH","NONE","LEFT"}
         aEval( aWrk, { |x| xGridPropSli2.Combo_1.AddItem( x ) } )

         xGridPropSli2.Combo_1.Value := aScan( aWrk, A2 )
      ELSE

         xGridPropSli2.Combo_1.Value := aScan( {"BOTTOM","BOTH","NONE","TOP" }, A2 )
      ENDIF

      xGridPropSli2.Label_1.Value := A1 + ":"
      aWrk                        := {}

      xGridPropSli2.Center
      ACTIVATE WINDOW xGridPropSli2
      RETURN
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "Alignment"
      DECLARE WINDOW xGridPropSli3
      LOAD WINDOW   xGridPropSli3

      xGridPropSli3.Combo_1.Value := aScan( {"LEFT", "RIGHT", "CENTER"}, A2 )
      xGridPropSli3.Label_1.Value := A1 + ":"

      xGridPropSli3.Center
      ACTIVATE WINDOW xGridPropSli3
      RETURN
    ENDIF


    *********
    ********* UCI Controls (new properties)
    *********

    DECLARE WINDOW xGridPropTxt
    LOAD WINDOW   xGridPropTxt

    xGridPropTxt.Text_1.Value       := A2
    xGridPropTxt.Label_1.Value      := A1 + ":"
    xGridPropTxt.RadioGroup_1.Value := iif( isValueTxt( A3, A1 ) = .T., 1, 2 )

    xGridPropTxt.Center
    ACTIVATE WINDOW xGridPropTxt

RETURN


*------------------------------------------------------------*
FUNCTION isVarNum( Param AS STRING )
*------------------------------------------------------------*
  LOCAL lRetVal AS LOGICAL := .T.
  LOCAL x       AS NUMERIC

  FOR x := 1 TO Len( Param )
      IF ! isDigit( SubStr( Param, x, 1 ) )
         lRetVal := .F.
         EXIT
      ENDIF
  NEXT x

RETURN( lRetVal )


*------------------------------------------------------------*
FUNCTION isValueTxt( pcControlName AS STRING, PropName AS STRING )
*------------------------------------------------------------*
  LOCAL cValue AS STRING
  LOCAL lRet   AS LOGICAL := .F.

  IF pcControlName = "Form"
     cValue := GetFormValue( PropName )
  ELSE
     cValue := SavePropControl( pcControlName, "", Upper( PropName ), ".T." )
  ENDIF

  // MsgBox( "cvalue = " + cValue )
  // MsgBox( "control = "+ pcControlName + " prop= " + PropName )

  IF isChar( cValue )
     IF ( Left( cValue, 1 ) = '"' .AND. Right( cValue, 1 ) = '"' ) .OR. ;
        ( Left( cValue, 1 ) = "'" .AND. Right( cValue, 1 ) = "'" ) .OR. PropName == "FontName"

        lRet := .T.
     ENDIF
  ENDIF

RETURN( lRet )


*------------------------------------------------------------*
FUNCTION GetFormValue( Param AS STRING )
*------------------------------------------------------------*
  LOCAL cRetVal AS STRING := ""

  DO CASE
     CASE param = "Cursor"        ; cRetVal := xProp[  5 ]
     CASE param = "Icon"          ; cRetVal := xProp[ 10 ]
     CASe param = "NotifyIcon"    ; cRetVal := xProp[ 17 ]
     CASE param = "NotifyTooltip" ; cRetVal := xProp[ 18 ]
     CASE param = "Title"         ; cRetVal := xProp[ 23 ]
  ENDCASE

RETURN( cRetVal )


*-----------------------------------------------------------------------------*
PROCEDURE SeeFont()                             // Add By Pier 11/08/2006 16.13
*-----------------------------------------------------------------------------*
  IF xGridPropCombo.Label_2.Visible

     xGridPropCombo.Label_2.Fontname   := GetWindowText( GetControlHandle( "Combo_1","xGridPropCombo" ) )
     xGridPropCombo.Text_1.Value       := xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value )
     xGridPropCombo.RadioGroup_1.Value := 1

  ENDIF

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE Ld_base( Arg1 AS USUAL )              // Add By Pier 24/05/2006 13.51  //? VarType
*-----------------------------------------------------------------------------*
  ON KEY ESCAPE OF &arg1 ACTION thisWindow.Release
  ON KEY RETURN OF &arg1 ACTION Add_Ok( Arg1 )
RETURN


*-----------------------------------------------------------------------------*
PROCEDURE Add_ok( Arg1 AS USUAL )               // Add By Pier 24/05/2006 13.51 //? VarType
*-----------------------------------------------------------------------------*
  _pushkey( VK_TAB )

  release key RETURN OF &arg1

  _pushkey( VK_SPACE )

RETURN


*-----------------------------------------------------------------------------*
FUNCTION GetFonts()                          // Form DBFview By Grigory Filatov
*-----------------------------------------------------------------------------*
   LOCAL aTmp    AS ARRAY
   LOCAL aFonts  AS ARRAY   := {}
   LOCAL nHandle AS NUMERIC := GetDC( NIL )

   aTmp := GetFontNames( nHandle )

   ReleaseDC( NIL, nHandle )

   aEval( aTmp, {|e| iif( aScan( aFonts, e ) == 0       .AND. ;
                          ! "WST_"  $ e                 .AND. ;
                          ! "Chess" $ e                 .AND. ;
                          ! "Math"  $ e,                      ;
                          aAdd( aFonts, e),                   ;
                          NIL                                 ;
                        )                                     ;
                }                                             ;
        )

RETURN aSort( aFonts )


*------------------------------------------------------------*
FUNCTION LoadGetBox( Param AS STRING )
*------------------------------------------------------------*
   local xGetBox AS ARRAY   := Array( 3 )  //? Invalid Hungarian
   LOCAL x       AS NUMERIC
   LOCAL x2      AS STRING
   LOCAL x3      AS STRING  := ""
   LOCAL xItem   AS NUMERIC := 0
   LOCAL xValue  AS STRING  := Param

   aFill( xGetBox, "" )

   FOR x := 1 TO Len( xValue )
       x2 := SubStr( xValue, x, 1 )
       IF x2 == "," .AND. SubStr( xValue, x+1, 1 ) == ","
          xitem ++
          x ++
          x2 := SubStr( xValue, x, 1 )
       ENDIF

       IF x2 == "{" .AND. SubStr( xValue, x+1, 1 ) # "{"
          DO WHILE .T.
             x3 += x2
             IF x2 = "}"
                EXIT
             ENDIF
             x ++
             x2 := SubStr( xValue, x, 1 )
          ENDDO

          xitem ++
          xgetbox[xitem] := x3
          x3             := ""

       ENDIF

   NEXT x

RETURN( xGetBox )


*------------------------------------------------------------*
PROCEDURE xEnableGetBox()
*------------------------------------------------------------*
   IF xGridGetBox.Check_1.Value

       xGridGetBox.Text_2.Enabled   := .T.
       xGridGetBox.Text_3.Enabled   := .T.
       xGridGetBox.Button_5.Enabled := .T.
       xGridGetBox.Button_6.Enabled := .T.

   ELSE
       xGridGetBox.Text_2.Enabled   := .F.
       xGridGetBox.Text_3.Enabled   := .F.
       xGridGetBox.Button_5.Enabled := .F.
       xGridGetBox.Button_6.Enabled := .F.
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE xGetBoxChoose( Param AS STRING )
*------------------------------------------------------------*
  LOCAL Color  AS ARRAY  //? Confusing name
  LOCAL xColor AS STRING //? Invalid Hungarian

  IF Param = "text_1" .OR. Param = "text_2" .OR. Param = "text_3"

     Color := GetColor()

     IF Color[1] # Nil
        xColor := "{"+ AllTrim(Str(Color[1]))+","+ AllTrim(Str(Color[2]))+","+ AllTrim(Str(Color[3]))+"}"
        SetProperty( "xGridGetBox", Param, "VALUE", xColor )
     ELSE
        SetProperty( "xGridGetBox", Param, "VALUE", "" )
     ENDIF

  ENDIF

  IF Param = "save"
     IF Empty( xGridGetBox.Text_2.Value ) .AND. Empty( xGridGetBox.Text_3.Value )
        xGridGetBox.check_1.Value := .F.
     ENDIF

     IF xGridGetBox.check_1.Value
        xColor := "{"+ xGridGetBox.Text_1.Value + "," + xGridGetBox.Text_2.Value + "," + xGridGetBox.Text_3.Value + "}"
        SetColValue( "XGRID_1", "ObjectInspector", 2, xColor )
        SavePropControl( A3, xColor, A1 )
     ELSE
        xColor := xGridGetBox.Text_1.Value

        IF Len( xColor ) = 0
           xColor := "NIL"
        ENDIF

        SetColValue( "XGRID_1", "ObjectInspector", 2, xColor )
        SavePropControl( A3, xColor, A1 )
     ENDIF

     RELEASE WINDOW xGridGetBox

  ENDIF

  IF Param = "cancel"  //? or Cancel
     RELEASE WINDOW xGridGetBox
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropSliOk()
*------------------------------------------------------------*
   //LOCAL A1
   LOCAL A3 AS USUAL //? VarType
   LOCAL A4 AS USUAL //? VarType

   A1 := GetColValue( "XGRID_1", "ObjectInspector", 1 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
   A4 := ObjectInspector.xGrid_1.Value

   IF xGridPropSli.Combo_1.Value = 1

      IF GetColValue( "XGRID_1", "ObjectInspector", 2 ) # "HORIZONTAL"
         SetColValue( "XGRID_1", "ObjectInspector", 2, "HORIZONTAL" )
         SavePropControl( A3, "1", A1 )    //HORIZONTAL
         TesteSLI(.F.)
      ENDIF

   ELSEIF xGridPropSli.Combo_1.Value = 2

      IF GetColValue( "XGRID_1", "ObjectInspector", 2 ) # "VERTICAL"
         SetColValue( "XGRID_1", "ObjectInspector", 2, "VERTICAL" )
         SavePropControl( A3, "2", A1 )  //VERTICAL
         TesteSLI(.T.)
      ENDIF

   ENDIF

   ObjectInspector.xGrid_1.Value := A4

   RELEASE WINDOW xGridPropSLI

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropSliNO()
*------------------------------------------------------------*
   RELEASE WINDOW xGridPropSli
RETURN


*------------------------------------------------------------*
PROCEDURE TesteSLI( lVert AS LOGICAL )
*------------------------------------------------------------*
  LOCAL A3          AS USUAL      //? VarType
  LOCAL x           AS NUMERIC
  LOCAL v1          AS STRING
  LOCAL b0          AS USUAL      //? Change Type within procedure
  LOCAL c0          AS NUMERIC
  LOCAL b1          AS USUAL      //? Change Type within procedure
  LOCAL c1          AS NUMERIC
  LOCAL b2          AS USUAL      //? Change Type within procedure
  LOCAL c2          AS NUMERIC
  LOCAL z           AS NUMERIC
  LOCAL cTipo       AS STRING     //? Var Name not in english please translate
  LOCAL ControlName AS STRING
  LOCAL xRow        AS NUMERIC
  LOCAL xCol        AS NUMERIC
  LOCAL TabHandle   AS NUMERIC
  LOCAL nPosTab     AS NUMERIC
  LOCAL cTabName    AS STRING
  LOCAL nPageNr     AS NUMERIC

  A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

  FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

      ObjectInspector.xGrid_1.Value := x
      v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

      IF v1 = "Width"
         b0 := GetColValue( "XGRID_1", "ObjectInspector", 2 )
         c0 := x
      ENDIF

      IF v1 = "Height"
         b1 := GetColValue( "XGRID_1", "ObjectInspector", 2 )
         c1 := x
      ENDIF

      IF v1 = "TickMarks"
         b2 := GetColValue( "XGRID_1", "ObjectInspector", 2 )
         c2 := x
      ENDIF
  NEXT x

  ObjectInspector.xGrid_1.Value := c0
  SetColValue( "XGRID_1", "ObjectInspector", 2, b1 )
  SavePropControl( A3, b1, "Width" )

  *********************************************
  ObjectInspector.xGrid_1.Value := c1
  SetColValue( "XGRID_1", "ObjectInspector", 2, b0 )
  SavePropControl( A3, b0, "Height" )

  ***********************************************
  z := GetControlIndex( A3, "Form_1" )

  _SetControlSizePos( A3, "Form_1", _HMG_aControlRow[z], _HMG_aControlCol[z], Val(b1), Val(b0) )

  cHideControl( _HMG_aControlhandles[z] )
  cShowControl( _HMG_aControlhandles[z] )

  IF xTypeControl( A3 ) = "SLIDER"

     ObjectInspector.xGrid_1.Value := C2

     IF B2 = "BOTTOM"
        SetColValue( "XGRID_1", "ObjectInspector", 2, "RIGHT" )
        cTipo := "4"

     ELSEIF B2 = "TOP"
        SetColValue( "XGRID_1", "ObjectInspector", 2, "LEFT" )
        cTipo := "2"

     ELSEIF B2 = "RIGHT"
        SetColValue( "XGRID_1", "ObjectInspector", 2, "BOTTOM" ) // TOP ORIGINAL
        cTipo := "2"

     ELSEIF B2 = "LEFT"
        SetColValue( "XGRID_1", "ObjectInspector", 2, "TOP" )    // BOTTOM ORIGINAL
        cTipo := "4"

     ELSEIF B2 = "BOTH"
        SetColValue( "XGRID_1", "ObjectInspector", 2, "BOTH" )
        cTipo := "1"

     ELSEIF B2 = "NONE"
        SetColValue( "XGRID_1", "ObjectInspector", 2, "NONE" )
        cTipo := "3"
     ENDIF

     SavePropControl( A3, cTipo, "TickMarks" )

     ControlName  := A3
     b0           := _HMG_aControlValue[ z ]
     b1           := _HMG_aControlRow[ z ]
     b2           := _HMG_aControlCol[ z ]

     ***********************************
     z            := GetControlIndex( ControlName, "Form_1" )
     xRow         := _HMG_aControlContainerRow[ z ]
     xCol         := _HMG_aControlContainerCol[ z ]

     IF xRow # -1   // control is in tab
        TabHandle := FindTabHandle( ControlName )
        nPosTab   := aScan( _HMG_aControlHandles, TabHandle )
        cTabName  := _HMG_aControlNames[ nPosTab ]
        nPageNr   := _GetValue( cTabName, "Form_1" )
     ENDIF

     *****************************
     DoMethod( "Form_1", ControlName, "Release" )

     IF lVert
        IF cTipo = "1"
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL BOTH
        ELSEIF cTipo = "3"
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL NOTICKS
        ELSEIF cTipo = "2"
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL LEFT
        ELSE
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL
        ENDIF
     ELSE
        IF cTipo = "1"
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid() BOTH
        ELSEIF cTipo = "3"
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid() NOTICKS
        ELSEIF cTipo = "4"
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid() TOP
        ELSE
           @ b1, b2 SLIDER  &ControlName OF FORM_1 RANGE 1,10 VALUE b0 TOOLTIP ControlName  ON CHANGE cpreencheGrid()
        ENDIF
     ENDIF

     IF xRow # -1   // control is in tab
        z := GetControlIndex( ControlName, "Form_1" )

        _AddTabControl( cTabName, ControlName, "FORM_1", nPageNr, b1-xRow, b2-xCol )

        CHideControl( _HMG_aControlhandles[ z ] )
        CShowControl( _HMG_aControlhandles[ z ] )

     ENDIF

  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropSli2Ok()
*------------------------------------------------------------*
   LOCAL A3      AS USUAL  //? VarType
   LOCAL A4      AS USUAL  //? VarType
   LOCAL xValue  AS USUAL  //? VarType
   LOCAL aWrk    AS ARRAY  := { {"BOTH","1"}, {"BOTTOM","2"}, {"LEFT","2"}, {"NONE","3"}, {"TOP","4"}, {"RIGHT","4"} }

   A1 := GetColValue( "XGRID_1", "ObjectInspector", 1 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
   A4 := xGridPropSli2.Combo_1.Item(xGridPropSli2.Combo_1.Value )

   SetColValue( "XGRID_1", "ObjectInspector", 2, A4 )

   xValue := aWrk[ aScan( aWrk, { | e | e[ 1 ] == A4 } ), 2 ]

   SavePropControl( A3, xValue, A1 )

   RELEASE WINDOW xGridPropSli2
RETURN


*------------------------------------------------------------*
Procedure xGridPropSli2No()
*------------------------------------------------------------*
   release WINDOW xGridPropSli2
RETURN


*------------------------------------------------------------*
FUNCTION FindTabHandle( ControlName AS STRING )
*------------------------------------------------------------*
  LOCAL h         AS NUMERIC := GetFormHandle( DesignForm )
  LOCAL l         AS NUMERIC := Len( _HMG_aControlHandles )
  LOCAL hControl  AS NUMERIC := GetControlHandle( ControlName, DesignForm )
  LOCAL i         AS NUMERIC
  LOCAL j         AS NUMERIC
  LOCAL k         AS NUMERIC

  FOR i := 1 TO l

      IF _HMG_aControlParentHandles[ i ] == h .AND. _HMG_aControlType[ i ] == "TAB"

         FOR j := 1 TO Len( _HMG_aControlPageMap[ i ] )

             FOR k := 1 TO Len( _HMG_aControlPageMap[ i,  j ] )

                 IF ValType( _HMG_aControlPageMap[ i, j, k ] ) # "A"
                    IF _HMG_aControlPageMap[ i, j, k ] = hControl
                       RETURN( _HMG_aControlHandles[ i ] )
                    ENDIF
                 ENDIF

             NEXT k

         NEXT j

      ENDIF

  NEXT i

RETURN( 0 )


*------------------------------------------------------------*
PROCEDURE xGridPropSli3Ok()
*------------------------------------------------------------*
   LOCAL A3          AS USUAL   //? VarType
   LOCAL A4          AS USUAL   //? VarType
   LOCAL Cv          AS USUAL   //? VarType
   LOCAL aWrk        AS ARRAY   := { {"LEFT","1"}, {"RIGHT","2"}, {"CENTER","3"} }
   LOCAL z           AS NUMERIC
   LOCAL xRow        AS NUMERIC
   LOCAL TabHandle   AS NUMERIC
   LOCAL nPosTab     AS NUMERIC
   LOCAL cTabName    AS STRING
   LOCAL nPageNr     AS NUMERIC
   LOCAL cBackColor  AS STRING
   LOCAL ControlName AS STRING
   LOCAL nCtrl       AS NUMERIC

   A1 := GetColValue("XGRID_1","ObjectInspector", 1 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
   A4 := ObjectInspector.xGrid_1.Value
   Cv := xGridPropSli3.Combo_1.Value

   SetColValue( "XGRID_1", "ObjectInspector", 2, aWrk[ Cv, 1 ] )

   SavePropControl( A3, aWrk[ Cv, 2 ], A1 )

   ControlName := A3
   nCtrl       := xControle( ControlName )

   //msgbox('control= ' + a1 +  ' a3= ' + a3)
   //msgbox('ctype = ' + xTypeControl( ControlName ) )
   if  cTypeOfControl(nCtrl) == 'LABEL'
   ***********************************
   z           := GetControlIndex( ControlName, "Form_1" )
   xRow        := _HMG_aControlContainerRow[ z ]
   //xCol      := _HMG_aControlContainerCol[ z ]

   IF xRow # -1   // control is in tab
      tabHandle := FindTabHandle( ControlName )
      nPosTab   := aScan( _HMG_aControlHandles, TabHandle )
      cTabName  := _HMG_aControlNames[ nPosTab ]
      nPageNr   := _GetValue( cTabName, "Form_1" )
   ENDIF

   *****************************
   DoMethod( "Form_1", ControlName, "Release" )

   IF xArray[ nCtrl, 39 ] # "NIL"
      cBackColor := xArray[ nCtrl, 39 ]
   ELSE
      cBackColor := "{228,228,228}"
   ENDIF

    DEFINE LABEL           &ControlName
           PARENT          Form_1
           ROW             Val( xArray[ nCtrl,  5 ] )
           COL             Val( xArray[ nCtrl,  7 ] )
           WIDTH           Val( xArray[ nCtrl,  9 ] )
           HEIGHT          Val( xArray[ nCtrl, 11 ] )
           VALUE           NoQuota(xArray[ nCtrl, 13 ] )
           FONTNAME        xArray[ 15 ]
           FONTSIZE        Val( xArray[ nCtrl, 17 ] )
           ACTION          { || ControlFocus(), cpreencheGrid() }
           TOOLTIP         ControlName
           BACKCOLOR       Str2Array( cBackColor )
           FONTCOLOR       Str2Array( xArray[ nCtrl, 41 ] )
           FONTBOLD        &(xArray[ nCtrl, 21 ] )
           FONTITALIC      &(xArray[ nCtrl, 23 ] )
           FONTUNDERLINE   &(xArray[ nCtrl, 25 ] )
           FONTSTRIKEOUT   &(xArray[ nCtrl, 27 ] )
           TRANSPARENT     &(xArray[ nCtrl, 33 ] )
           BORDER          &(xArray[ nCtrl, 51 ] )
           AUTOSIZE        &(xArray[ nCtrl, 37 ] )
           IF aWrk[Cv,1] = "RIGHT"
              RIGHTALIGN .T.
           ELSEIF aWrk[Cv,1] = "CENTER"
              CENTERALIGN .T.
           ENDIF
         END LABEL

   IF xRow # -1   // control is in tab
      z := GetControlIndex( ControlName, "Form_1" )
      _AddTabControl( cTabName, ControlName, "FORM_1", nPageNr, Val( xArray[ nCtrl, 5 ] ), Val( xArray[ nCtrl, 7 ] ) )
    ENDIF

   CHideControl( _HMG_aControlhandles[ z ] )
   CShowControl( _HMG_aControlhandles[ z ] )
   
  ENDIF 

   ObjectInspector.xGrid_1.Value := A4

   RELEASE WINDOW xGridPropSli3

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropSli3No()
*------------------------------------------------------------*
   RELEASE WINDOW xGridPropSli3
RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropWinOK()
*------------------------------------------------------------*
   LOCAL aWrk AS ARRAY :={"CHILD","MAIN","MODAL","SPLITCHILD","STANDARD","MDI","MAINMDI","MDICHILD"}
   local A3   AS USUAL //? VarType

   A1 := GetColValue("XGRID_1","ObjectInspector",1)
   A3 := ObjectInspector.xCombo_1.Item(ObjectInspector.xCombo_1.Value)

   SetColValue( "XGRID_1", "ObjectInspector", 2, aWrk[ xGridPropWin.Combo_1.Value ] )

   SavePropControl( A3, aWrk[ xGridPropWin.Combo_1.Value ], A1 )

   LoadFormProps()

   RELEASE WINDOW xGridPropWin
RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropWinNO()
*------------------------------------------------------------*
   RELEASE WINDOW xGridPropWin
RETURN


*------------------------------------------------------------*
FUNCTION isNotValid( New_Name AS STRING )
*------------------------------------------------------------*
   LOCAL x      AS NUMERIC
   LOCAL RetVal AS LOGICAL := .F.

   FOR x := 1 TO Len( New_Name )
       IF SubStr( New_Name, x, 1 ) $ "'!@#$%¨&*()-+*/=`´[{^~}]?/:;>.<,|\ÃÂÁÀãâáàÉÈéèÓÒóòÇç" .OR. SubStr( New_Name, x, 1 ) $ '"'
          RetVal := .T.
       ENDIF
   NEXT x

RETURN( RetVal )


*------------------------------------------------------------*
PROCEDURE xGridPropTxtOK()
*------------------------------------------------------------*
   LOCAL A3           AS STRING
   LOCAL x1           AS USUAL   //? VarType
   LOCAL x2           AS USUAL   //? VarType
   LOCAL x3           AS USUAL   //? VarType
   LOCAL x4           AS USUAL   //? VarType
   LOCAL x5           AS USUAL   //? VarType
   LOCAL x6           AS USUAL   //? VarType
   LOCAL x            AS NUMERIC
   LOCAL h            AS NUMERIC := GetFormHandle( "Form_1" )
   LOCAL oldvalue     AS NUMERIC := GetColValue( "XGRID_1", "ObjectInspector", 2 )
   LOCAL aTempNames   AS ARRAY
   LOCAL acBackColor  AS ARRAY
   LOCAL lArray       AS LOGICAL
   LOCAL z            AS NUMERIC
   LOCAL j            AS NUMERIC
   LOCAL k            AS NUMERIC
   LOCAL cValue       AS STRING
   LOCAL p            AS NUMERIC
   LOCAL nPos         AS NUMERIC
   LOCAL i            AS NUMERIC
   LOCAL xArrayCombo  AS ARRAY
   LOCAL ControlName  AS STRING
   LOCAL B0           AS USUAL   //? VarType
   LOCAL B1           AS USUAL   //? VarType
   LOCAL B2           AS USUAL   //? VarType
   LOCAL B3           AS USUAL   //? VarType
   LOCAL B4           AS USUAL   //? VarType
   LOCAL acOptions    AS ARRAY
   LOCAL nSpacing     AS NUMERIC
   LOCAL cPictureName AS STRING
   LOCAL y            AS NUMERIC
   LOCAL cName        AS STRING
   LOCAL cCtrlType    AS STRING
   LOCAL TabHandle    AS NUMERIC
   LOCAL nPosTab      AS NUMERIC
   LOCAL cTabName     AS STRING

   SetColValue( "XGRID_1", "ObjectInspector", 2, xGridPropTxt.Text_1.Value )

   A1        := GetColValue( "XGRID_1", "ObjectInspector", 1 )
   A3        := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
   cCtrlType := xTypeControl( A3 )


   ***************
   IF A1 == "Name"
      lUpdate  := .F.
      New_Name := xGridPropTxt.Text_1.Value

      IF New_Name == oldvalue
         // LOGFORM.LIST_1.AddItem("name=oldvalue= ")
         SetColValue( "XGRID_1", "ObjectInspector", 2, OldValue )
         MsgBox( "name not modified same name ")
         RELEASE WINDOW xGridPropTxt
         RETURN
          ***************************in test

      ELSEIF At( " ", New_Name ) > 0
         // LOGFORM.LIST_1.AddItem( "name have space= " )
         PlayBeep()
         SetColValue( "XGRID_1", "ObjectInspector", 2, OldValue )
         RELEASE WINDOW xGridPropTxt
         RETURN

      ELSEIF isNotValid( new_name )
         // LOGFORM.LIST_1.AddItem("name have invalid value= ")
         PlayBeep()
         SetColValue( "XGRID_1", "ObjectInspector", 2, oldvalue )
         MsgBox( "name have invalid value " )
         RELEASE WINDOW xGridPropTxt
         RETURN
         **********************************
      ENDIF

      //LOGFORM.LIST_1.AddItem("name have be validated ")
      ****
      aTempNames := aClone( _HMG_aControlNames )

      FOR x := 1 TO Len( aTempNames )
          IF ValType( aTempnames[ x ] ) == "C"
             aTempNames[ x ] := Upper( aTempNames[ x ] )
             // MsgBox("pos= " + str(x) + " len= "+str(Len( atempnames))+ " nome= "+aTempnames[x])
          ENDIF
      NEXT x

      z := aScan( aTempNames ,{|x,i| x == Upper( New_Name ) .AND. _HMG_aControlParenthandles[ i ] == h } )

      IF z > 0
         MsgBox( "Invalid Name ->" + _HMG_aControlNames[ z ] )
         PlayBeep()
         SetColValue( "XGRID_1", "ObjectInspector", 2, oldvalue )
         RELEASE WINDOW xGridPropTxt
         RETURN
      ELSEIF New_Name == "Form"
         // MsgBox("Invalid Name ->"+ "Form")
         PlayBeep()
         SetColValue( "XGRID_1", "ObjectInspector", 2, oldvalue )
         RELEASE WINDOW xGridPropTxt
         RETURN
      ELSE

         z                     := GetControlIndex( A3, "Form_1" )
         cName                 := _HMG_aControlNames[ z ]          //? Is it used
         _HMG_aControlNames[z] := New_Name

         *****************************************
         IF _HMG_aControlType[ z ] = "TAB"
            FOR j := 1 To Len( _HMG_aControlPageMap[ z ] )
                FOR k := 1 TO Len( _HMG_aControlPageMap[ z, j ] )

                    IF ValType( _HMG_aControlPageMap[ z, j, k ] ) # "A"

                       cValue := _HMG_aControlPageMap[ z, j, k ]
                       p      := aScan( _HMG_aControlHandles, cValue )

                       IF _HMG_aControlType[ p ] = "FRAME"
                          _HMG_aControlRangeMin[ p ] := New_Name
                       ENDIF

                    ENDIF

                NEXT k
            NEXT j
         ENDIF

         ***********************************
         SetProperty( "FORM_1", A3, "TOOLTIP", New_Name )

         IF xTypeControl( A3 ) == "GETBOX" /*.OR. xTypeControl( A3 ) = "LABEL"*/ .OR. xTypeControl( A3 ) == "TEXTBOX"
            SetProperty( "FORM_1", A3, "VALUE", New_Name )
         ENDIF

         nPos                                                            := ObjectInspector.xCombo_1.Value
         ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value ) := New_Name
         ObjectInspector.xCombo_1.Value                                  := nPos
         ***********************************
         // mVar := "_" + _HMG_aFormNames [p] + "_" + _HMG_aControlNames [i]
         mVar := "_Form_1_" + A3
         IF Type( mVar ) != "U"
                                // MsgBox( "ok-defined-value -> " + mvar + "  = " + Str(&mVar.) )
            OldVar := &mVar.
            #ifdef _ZEROPUBLIC_
               __MVPUT( mVar , 0 )
               // MsgBox("ok-deleted-1-value"+str(&mVar.) )
            #ELSE
               __MVXRELEASE( mVar )
               // MsgBox("ok-deleted-2-value"+str(&mVar.) )
            #ENDIF
         ENDIF
         mVar          := "_" + "Form_1" + "_" + New_Name
         Public &mVar. := oldvar

         // MsgBox("ok-defined-value -> "+mvar+" = " +str(&mVar.) )

         *********************
         // SavePropControl( A3, xGridPropTxt.Text_1.Value, A1 )
         x1              := xControle( A3 )
         xArray[ x1, 3 ] := New_Name
         *************************
         // MsgBox("value= "+xArray[x1,1] +" "+xArray[x1,2]+" "+xArray[x1,3] )

         IF xTypeControl( New_Name ) == "COMBOBOX" .OR. xTypeControl( New_Name ) == "COMBOBOXEX"
            x1 := GetControlIndex( New_Name, "Form_1" )
            IF x1 > 0
               DoMethod( "FORM_1", New_Name, "SETFOCUS" )
            ENDIF
         ENDIF
         // MsgBox("newname= "+_HMG_aControlNames[x1]+ " nr= "+str(x1) )

         IF xTypeControl( New_Name ) == "RADIOGROUP"
            x1 := GetControlIndex( New_Name, "Form_1" )
            // LOGFORM.LIST_1.AddItem( "radionew= " + Str(x1) + " " + _HMG_aControlNames[x1] )
            FOR i := 1 TO Len(_HMG_aControlhandles[ x1 ] )
                SetToolTip( _HMG_aControlhandles[ x1, i ], New_Name , GetFormToolTipHandle( "FORM_1" ) )
            NEXT i
         ENDIF

         *********************************
         lUpdate := .T.
         RELEASE WINDOW xGridPropTxt
         RETURN
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A3 # "Form"

       IF xGridPropTxt.RadioGroup_1.Value = 1
          SavePropControl( A3, '"' + xGridPropTxt.Text_1.Value + '"', A1 )
       ELSE
          IF ! Empty( xGridPropTxt.Text_1.Value )
             SavePropControl( A3, xGridPropTxt.Text_1.Value, A1 )
          ENDIF
       ENDIF

       *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       IF A1 = "Address"
          IF Empty( xGridPropTxt.Text_1.Value ) .OR.( At( "@", xGridPropTxt.Text_1.Value ) = 0 .AND. At( "http", xGridPropTxt.Text_1.Value ) = 0 )
             MsgAlert( "Please revise an invalid e-mail or URL on Form", "Warning" )
             xGridPropTxt.Text_1.SetFocus
             RETURN
          ENDIF
       ENDIF

       *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       IF A1 # "ToolTip"      .AND. ;
          A1 # "Value"        .AND. ;
          A1 # "Picture"      .AND. ;
          A1 # "InputItems"   .AND. ;
          A1 # "DisplayItems"

          IF xTypeControl( A3 ) == "COMBOBOX" .AND. A1 == "Items"
              IF At( xGridPropTxt.Text_1.Value, "{" ) > 0
                 IF ValType(&(xGridPropTxt.Text_1.Value ) ) # "A"
                    RETURN
                 ENDIF
              ELSE
                 lArray := .F.
              ENDIF
          ENDIF

          IF ! ( ( xTypeControl( A3 ) = "RADIOGROUP" .AND. A1 = "ReadOnly" ) .OR. ;
                 ( xTypeControl( A3 ) = "TBROWSE"    .AND. A1 = "ReadOnly" )      ;
               )

            SetProperty( "Form_1", A3, A1, xGridPropTxt.Text_1.Value )
         ENDIF
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF A1 = "Value" .AND. xTypeControl( A3 ) = "LABEL"
         SetProperty( "Form_1", A3, A1, xGridPropTxt.Text_1.Value )
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF A1 == "Items"  .AND. ( xTypeControl( A3 ) == "COMBOBOX" .OR. xTypeControl( A3 ) == "LISTBOX" )
         DoMethod( "Form_1", A3, "DELETEALLITEMS" )

         IF lArray = nil
            xArrayCombo := &( xGridPropTxt.Text_1.Value )
            FOR x := 1 TO Len( xArrayCombo )
                cValue := xArrayCombo[ x ]

                DoMethod( "Form_1", A3, "ADDITEM", cValue )
            NEXT x
         ELSE
            DoMethod( "Form_1", A3, "ADDITEM", xGridPropTxt.Text_1.Value )
         ENDIF
         SetProperty( "Form_1", A3, "VALUE"  , 1 )
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF A1 = "Options" .AND. xTypeControl( A3 ) = "RADIO"

         z           := GetControlIndex( A3, "Form_1" )
         ControlName := A3
         // MsgBox( "ControlName= " + ControlName )

         b0 := _HMG_aControlRow[z]
         b1 := _HMG_aControlCol[z]
         b2 := _HMG_aControlWidth[z]
         X1 := xControle( ControlName )
         x5 := _HMG_aControlContainerRow[z]
         x6 := _HMG_aControlContainerCol[z]

         IF X5 # -1   // radio is in tab
            X2 := _HMG_aControlRangeMin [z]
            X3 := _HMG_aControlRangeMax [z]
            X4 := _GetValue( X2 , "Form_1" )
         ENDIF

         DoMethod( "Form_1", ControlName, "Release" )

         acOptions   := &( xGridPropTxt.Text_1.Value )
         nSpacing    := &( xArray[x1,41] )
         acBackColor := &( xArray[x1,43] )
         // MsgBox( "Spacing= " + Str( nSpacing ) )

         IF xArray[ x1, 49 ] = ".T."
             @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOPTIONS value 1 WIDTH b2  SPACING nspacing   BACKCOLOR acbackcolor ON CHANGE  cpreencheGrid("RADIOGROUP") TOOLTIP ControlName HORIZONTAL
         ELSE
             @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOPTIONS value 1 WIDTH b2  SPACING nspacing   BACKCOLOR acbackcolor ON CHANGE  cpreencheGrid("RADIOGROUP") TOOLTIP ControlName
         ENDIF

         // CONNECT TO TAB
         IF  X5 # -1   // radio is in tab
            // MsgBox( "ControlName= " + ControlName )
            z := GetControlIndex( ControlName, "Form_1" )
            _AddTabControl( X2, ControlName, "FORM_1", X4, b0-x5, b1-x6 )
            _HMG_aControlRangeMin[ z ] := X2
            _HMG_aControlRangeMax[ z ] := X3

            CHideControl(_HMG_aControlhandles[ z, 1 ] )  //? Why Hide/Show
            CShowControl(_HMG_aControlhandles[ z, 1 ] )

         ENDIF

      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF ( A1 = "Picture" .OR. A1 = "Icon" ) .AND. xTypeControl( A3 ) # "GETBOX"    .OR. ;
         ( A1 = "Caption"                    .AND. xTypeControl( A3 ) = "BUTTON" )

         z           := GetControlIndex( A3, "Form_1" )
         ControlName := A3
         // MsgBox( "ControlName= " + ControlName )
         b0          := _HMG_aControlRow[ z ]
         b1          := _HMG_aControlCol[ z ]
         b2          := _HMG_aControlWidth[ z ]
         b3          := _HMG_aControlHeight[ z ]
         b4          := _HMG_aControlCaption[ z ]
         X1          := xControle( ControlName )
         x5          := _HMG_aControlContainerRow[ z ]
         x6          := _HMG_aControlContainerCol[ z ]

         IF X5 # -1   // control is in tab

            IF _HMG_aControlType[ z ] == "FRAME"      .OR. ;
               _HMG_aControlType[ z ] == "CHECKBOX"   .OR. ;
               _HMG_aControlType[ z ] == "RADIOGROUP"

               X2 := _HMG_aControlRangeMin[ z ] // TABNAME
               X3 := _HMG_aControlRangeMax[ z ] // "FORM_1"
               X4 := _GetValue( X2, "Form_1" )  //page nr

            ELSEIF _HMG_aControlType[ z ] == "SLIDER"
               X2 := _HMG_aControlFontHandle[ z ] // TABNAME
               X3 := _HMG_aControlMiscDatA1[ z ]  // "FORM_1"
               X4 := _GetValue( X2, "Form_1" )    // Page nr

            ELSE
               X2 := _HMG_ActiveTabName
               X3 := "FORM_1"
               X4 := _GetValue( X2, "Form_1" )    // page nr
            ENDIF
            // MsgBox( "x2=tabname " + x2 )

         ENDIF

         DoMethod( "Form_1", ControlName, "Release" )

         // MsgBox( "value =BUTTON= " + xTypeControl( A3 ) )

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         IF xTypeControl( A3 ) == "BUTTON" .AND. xTypeControl( A3 ) # "BUTTONEX"

            ControlName := A3

            // MsgBox("A1= "+A1)
            IF A1 = "Picture"
               // MsgBox( "POSITION 1-BITMAP" )
               cPictureName := FindImageName( xGridPropTxt.Text_1.Value, "bmp" )

               IF ! File( cPictureName )
                  cPictureName := "NIL"
                  ChangeGridValue( "Picture", "NIL", A3 )
               ENDIF
               x2 := ObjectInspector.xGrid_1.Value

               @ b0, b1 BUTTON  &ControlName OF FORM_1 PICTURE cPictureName WIDTH b2 HEIGHT b3 ACTION cpreencheGrid() TOOLTIP ControlName

               ChangeGridValue( "Caption", ""   , A3 )
               ChangeGridValue( "Icon"   , "NIL", A3 )

            ELSEIF  A1 = "Icon"
               // MsgBox( "POSITION 2-ICON" )
               cPictureName := FindImageName( xGridPropTxt.Text_1.Value, "ico" )

               IF ! File( cPictureName )
                  cPictureName := "NIL"
                  ChangeGridValue( "Icon", "NIL", A3 )
               ENDIF
               x2 := ObjectInspector.xGrid_1.Value

               @ b0, b1 BUTTON  &ControlName OF FORM_1 ICON cPictureName    WIDTH b2 HEIGHT b3 ACTION cpreencheGrid() TOOLTIP ControlName

               ChangeGridValue( "Caption", ""   , A3 )
               ChangeGridValue( "Picture", "NIL", A3 )
            ELSE
               // MsgBox( "POSITION 3-NO IMAGE" )
               x2 := ObjectInspector.xGrid_1.Value
               @ b0, b1 BUTTON  &ControlName OF FORM_1 CAPTION B4           WIDTH b2 HEIGHT b3 ACTION cpreencheGrid() TOOLTIP ControlName
               ChangeGridValue( "Icon"   , "NIL", A3 )
               ChangeGridValue( "Picture", "NIL", A3 )
            ENDIF
            ObjectInspector.xGrid_1.Value := x2
         ENDIF

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         IF xTypeControl( A3 ) == "CHECKBUTTON"

            ControlName := A3

            IF A1 = "Picture"
               cPictureName := FindImageName( xGridPropTxt.Text_1.Value, "bmp" )
               IF ! File( cPictureName )
                  cPictureName := "NIL"
                  ChangeGridValue( "Picture", "NIL", A3 )
               ENDIF
               x2 := ObjectInspector.xGrid_1.Value

               @ B0, B1 CHECKBUTTON  &ControlName OF FORM_1 PICTURE cPictureName  WIDTH B2 HEIGHT B3 TOOLTIP ControlName ON CHANGE cpreencheGrid()

               ChangeGridValue( "Caption", "", A3 )
            ELSE
               x2 := ObjectInspector.xGrid_1.Value
               @ B0, B1 CHECKBUTTON  &ControlName OF FORM_1 CAPTION B4            WIDTH B2 HEIGHT B3 TOOLTIP ControlName ON CHANGE cpreencheGrid()
               ChangeGridValue( "Picture", "NIL", A3 )
            ENDIF
            ObjectInspector.xGrid_1.Value := x2
         ENDIF

         // Renaldo : Start
         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         IF xTypeControl( A3 ) == "BUTTONEX"

            ControlName  := A3

            cPictureName := iif( ! Empty( A1 ), FindImageName( xGridPropTxt.Text_1.Value, iif( A1 = "Picture", "bmp", "ico" ) ), "" )

            x2 := ObjectInspector.xGrid_1.Value
            IF A1 = "Picture"
               ChangeGridValue( "Icon", "NIL", A3 )
            ELSEIF A1 = "Icon"
               ChangeGridValue( "Picture", "NIL", A3 )
            ENDIF
            ObjectInspector.xGrid_1.Value := x2

            IF ! Empty( cPictureName ) .AND. ! Upper( cPictureName ) == "NIL" .AND. A1 = "Picture"
               @ b0, b1 BUTTONEX  &ControlName OF FORM_1 CAPTION  B4 PICTURE cPictureName  WIDTH b2 HEIGHT b3 ACTION cpreencheGrid() FONT "MS Sans serif" SIZE 9 BOLD   LEFTTEXT  TOOLTIP ControlName BACKCOLOR WHITE
            ELSEIF ! Empty( cPictureName ) .AND. ! Upper( cPictureName ) == "NIL" .AND. A1 = "Icon"
               @ b0, b1 BUTTONEX  &ControlName OF FORM_1 CAPTION  B4 ICON cPictureName     WIDTH b2 HEIGHT b3 ACTION cpreencheGrid() FONT "MS Sans serif" SIZE 9 BOLD   LEFTTEXT  TOOLTIP ControlName BACKCOLOR WHITE
            ELSE
               @ b0, b1 BUTTONEX  &ControlName OF FORM_1 CAPTION  B4 PICTURE "BITMAP51"    WIDTH b2 HEIGHT b3 ACTION cpreencheGrid() FONT "MS Sans serif" SIZE 9 BOLD   LEFTTEXT  TOOLTIP ControlName BACKCOLOR WHITE
            ENDIF
         ENDIF

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         IF xTypeControl( A3 ) == "BTNTEXTBOX"
            ControlName  := A3
            cPictureName := iif( ! Empty( A1 ), FindImageName( xGridPropTxt.Text_1.Value, iif( A1 = "Picture", "bmp", "ico" ) ), "" )

            @ b0 ,b1 BUTTONEX  &ControlName OF FORM_1 CAPTION  "."+Space(b2*10)+"." PICTURE "TextBtn"   WIDTH b2 HEIGHT b3  ACTION cpreencheGrid() LEFTTEXT FLAT NOHOTLIGHT NOXPSTYLE  TOOLTIP ControlName BACKCOLOR WHITE
         ENDIF

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         IF xTypeControl( A3 ) == "IMAGE"
            ControlName  := A3
            cPictureName := iif( ! Empty( A1 ), FindImageName( xGridPropTxt.Text_1.Value, iif( A1 = "Picture", "bmp", "ico" ) ), "" )

            IF Empty( cPictureName ) .OR. Upper( cPictureName ) == "NIL"
               cPictureName := "BITMAP48"
            ENDIF

            @ b0, b1 BUTTONEX  &ControlName OF FORM_1 CAPTION "" PICTURE cPictureName WIDTH b2 HEIGHT b3 VERTICAL ADJUST NOHOTLIGHT ACTION cpreencheGrid() TOOLTIP ControlName
         ENDIF

         // Renaldo : End

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//         IF xTypeControl( A3 ) == "GETBOX"  //? TODO (What is needed here ?
//            ControlName := A3

//         ENDIF

         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // CONNECT TO TAB
         IF X5 # -1   // Control is in tab
            // MsgBox( "ControlName= conect to tab " + ControlName )
            z := GetControlIndex( ControlName, "Form_1" )

            TabHandle := FindTabHandle( ControlName )
            nPosTab   := aScan( _HMG_aControlHandles, TabHandle )
            cTabName  := _HMG_aControlNames[ nPosTab ]
            IF ValType(X2) # "C" .OR. X2 # cTabName
               X2 := cTabName
            ENDIF

            _AddTabControl( X2, ControlName, "FORM_1", X4, b0-x5, b1-x6 )

            IF _HMG_aControlType[ z ] == "FRAME"      .OR. ;
               _HMG_aControlType[ z ] == "CHECKBOX"   .OR. ;
               _HMG_aControlType[ z ] == "RADIOGROUP"

               _HMG_aControlRangeMin[ z ]  := X2
               _HMG_aControlRangeMax[ z ]  := X3

            ELSEIF  _HMG_aControlType[ z ] == "SLIDER"
               _HMG_aControlFontHandle[ z ] := X2
               _HMG_aControlMiscDatA1[ z ]  := "FORM_1"
            ENDIF

            CHideControl(_HMG_aControlhandles[ z ] )
            CShowControl(_HMG_aControlhandles[ z ] )

         ENDIF

      ENDIF

   ELSE

      x1 := GetColValue( "XGRID_1", "ObjectInspector", 1 )
      x2 := GetColValue( "XGRID_1", "ObjectInspector", 2 )

      IF xGridPropTxt.RadioGroup_1.Value = 1
         x2 := '"' + GetColValue( "XGRID_1", "ObjectInspector", 2 ) + '"'
      ENDIF

      LoadProp( x1, x2 )

      IF xGridPropTxt.Label_1.Value = "Title:"
         SetProperty( "FORM_1", "TITLE", xGridPropTxt.Text_1.Value )
      ENDIF
   ENDIF

   RELEASE WINDOW xGridPropTxt

RETURN


*------------------------------------------------------------*
PROCEDURE xGridEvenTxtOK()
*------------------------------------------------------------*
   LOCAL A3 AS STRING
   LOCAL x1 AS USUAL
   LOCAL x2 AS USUAL

   SetColValue( "XGRID_2", "ObjectInspector", 2, xGridEvenTxt.Edit_1.Value )

   A1 := GetColValue( "XGRID_2", "ObjectInspector", 1 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

   IF A3 # "Form"
      SavePropControl( A3, xGridEvenTxt.Edit_1.Value, A1 )
      //A5 := XCONTROLE( A3 )
   ELSE
      x1 := GetColValue( "XGRID_2", "ObjectInspector", 1 )
      x2 := GetColValue( "XGRID_2", "ObjectInspector", 2 )

      LoadProp( x1, x2 )
   ENDIF

   RELEASE WINDOW xGridEvenTxt

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropNumOK()
*------------------------------------------------------------*
   local A3           AS STRING
   LOCAL A4           AS USUAL    //? VarType
   LOCAL Z            AS NUMERIC
   LOCAL B0           AS NUMERIC
   LOCAL B1           AS NUMERIC
   LOCAL B2           AS NUMERIC
   LOCAL X1           AS NUMERIC
   LOCAL X2           AS USUAL    //? VarType
   LOCAL X3           AS USUAL    //? VarType
   LOCAL X4           AS USUAL    //? VarType
   LOCAL x5           AS NUMERIC
   LOCAL x6           AS NUMERIC
   LOCAL ControlName  AS STRING
   LOCAL acOPTIONS    AS ARRAY
   LOCAL nSpacing     AS NUMERIC
   LOCAL oldvalue     AS STRING
   LOCAL i            AS NUMERIC
   LOCAL x            AS NUMERIC
   LOCAL DifTabRow    AS NUMERIC
   LOCAL DifTabCol    AS NUMERIC
   LOCAL nTabAddPages AS NUMERIC
   LOCAL y            AS NUMERIC

   OldValue := GetColValue( "XGRID_1", "ObjectInspector", 2 )

   SetColValue( "XGRID_1", "ObjectInspector", 2, AllTrim(STR(xGridPropNum.Spinner_1.Value ) ) )

   A1 := GetColValue( "XGRID_1", "ObjectInspector", 1 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )
   A4 := GetColValue( "XGRID_1", "ObjectInspector", 2 )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A3 # "Form"

      i := GetControlIndex( A3, "Form_1" )

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF xGridPropNum.Label_1.Value = "Col:"
         DifTabRow := iif( _HMG_aControlContainerRow[i] # -1, _HMG_aControlContainerRow[i], 0 )
         // MsgBox( "row= " + Str( _HMG_aControlRow[i] ) + " - " + Str( diftabrow ) + " - "+ str(difrow()) + " col= " + Str(xGridPropNum.Spinner_1.Value)+ " - " + Str(DIFCOL())  )
         _SetControlSizePos( A3, "Form_1" , _HMG_aControlRow[i]-diftabRow-DifRow(), xGridPropNum.Spinner_1.Value - DifCol(), _HMG_aControlWidth[i], _HMG_aControlHeight[i] ) //

      ELSEIF xGridPropNum.Label_1.Value = "Row:"
         DifTabCol := iif( _HMG_aControlContainerCol[i] # -1, _HMG_aControlContainerCol[i], 0 )

         _SetControlSizePos( A3, "Form_1", xGridPropNum.Spinner_1.Value - DifRow(), _HMG_aControlCol[ i ] - DifTabCol - DifCol(), _HMG_aControlWidth[i], _HMG_aControlHeight[i] ) //

      ELSEIF xGridPropNum.Label_1.Value = "Width:"
         SetProperty( "Form_1", A3, "WIDTH", xGridPropNum.Spinner_1.Value )

      ELSEIF xGridPropNum.Label_1.Value = "Height:"
         SetProperty( "Form_1", A3, "HEIGHT", xGridPropNum.Spinner_1.Value )

      ELSEIF xGridPropNum.Label_1.Value = "FontSize:" .AND. xGridPropNum.RadioGroup_1.Value = 1
         SetProperty( "Form_1", A3, "VISIBLE" , .F. )
         SetProperty( "Form_1", A3, "FONTSIZE", xGridPropNum.Spinner_1.Value )
         SetProperty( "Form_1", A3, "VISIBLE" , .T. )
         *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         aData[ _PROJECTFONTSIZE ] := xGridPropNum.Spinner_1.Value

         SavePreferences()

      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF xGridPropNum.Label_1.Value = "PageCount:"
         IF Val( GetColValue( "XGRID_1", "ObjectInspector", 2 ) ) = 0
            SetColValue( "XGRID_1", "ObjectInspector", 2, "1" )
         ENDIF

         IF Val( GetColValue( "XGRID_1", "ObjectInspector", 2 ) ) > Val( OLDVALUE )
            nTabAddPages := Val( GetColValue( "XGRID_1", "ObjectInspector", 2 ) ) - Val( OLDVALUE )
            // MsgBox( "nr = " + Str( nTabAddPages ) )
            FOR y := 1 TO nTabAddPages
                AddTabPage( i )
            NEXT y

         ELSEIF  Val( GetColValue( "XGRID_1", "ObjectInspector", 2 ) ) < Val( OLDVALUE )
            nTabAddPages := Abs( Val( GetColValue( "XGRID_1", "ObjectInspector", 2 ) ) - Val( OLDVALUE ) )
            // MsgBox( "totpages= " + Str( nTabAddPages ) + "control= " + Str( i ) + " " + _HMG_aControlType[ i ] + " " + _HMG_aControlNames[ i ] )
            FOR x := 1 TO nTabAddPages
                DeleteTabPage( i )
            NEXT x
         ENDIF

      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF xGridPropNum.Label_1.Value = "Spacing:" .AND. xTypeControl( A3 ) = "RADIO"
         z           := GetControlIndex( A3, "Form_1" )
         ControlName := A3
         // MsgBox( "ControlName= " + ControlName )
         b0          := _HMG_aControlRow[ z ]
         b1          := _HMG_aControlCol[ z ]
         b2          := _HMG_aControlWidth[ z ]
         X1          := xControle( ControlName )
         x5          := _HMG_aControlContainerRow[ z ]
         x6          := _HMG_aControlContainerCol[ z ]

         IF  X5 # -1   // radio is in tab
             X2 := _HMG_aControlRangeMin[ z ]  //:= TABNAME
             X3 := _HMG_aControlRangeMax[ z ]  //:= "FORM_1"
             X4 := _GetValue( X2, "Form_1" )
          ENDIF

          DoMethod( "Form_1", ControlName, "Release" )

          acOPTIONS := &( xArray[ X1, 13 ] )
          nSpacing  :=  xGridPropNum.Spinner_1.Value
          // MsgBox( "Spacing= " + Str( nSpacing ) )

          IF xArray[ x1, 49 ] = ".T."
             @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOPTIONS VALUE 1 WIDTH b2  SPACING nSpacing  ON CHANGE  cpreencheGrid( "RADIOGROUP" ) TOOLTIP ControlName  HORIZONTAL
          ELSE
             @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOPTIONS VALUE 1 WIDTH b2  SPACING nSpacing  ON CHANGE  cpreencheGrid( "RADIOGROUP" ) TOOLTIP ControlName
          ENDIF

          IF X5 # -1   // radio is in tab
             // MsgBox("ControlName= "+ControlName)
             z := GetControlIndex( ControlName, "Form_1" )

             _AddTabControl( X2, ControlName, "FORM_1", X4, b0-x5, b1-x6 )

             _HMG_aControlRangeMin[ z ] := X2
             _HMG_aControlRangeMax[ z ] := X3

             CHideControl( _HMG_aControlhandles[ z, 1 ] )
             CShowControl( _HMG_aControlhandles[ z, 1 ] )
          ENDIF

      ENDIF

      IF xGridPropNum.RadioGroup_1.Value = 1 .OR. xGridPropNum.Label_1.Value = "Value:"
         SavePropControl( A3, AllTrim( Str( xGridPropNum.Spinner_1.Value ) ), A1 )
      ELSE
         SavePropControl( A3, xGridPropNum.Text_1.Value                     , A1 )
      ENDIF

   ELSE

      DO CASE
         CASE xGridPropNum.Label_1.Value = "Col:"    ; SetProperty( "FORM_1", "COL"   , xGridPropNum.Spinner_1.Value )
         CASE xGridPropNum.Label_1.Value = "Row:"    ; SetProperty( "FORM_1", "ROW"   , xGridPropNum.Spinner_1.Value )
         CASE xGridPropNum.Label_1.Value = "Width:"  ; SetProperty( "FORM_1", "WIDTH" , xGridPropNum.Spinner_1.Value )
         CASE xGridPropNum.Label_1.Value = "Height:" ; SetProperty( "FORM_1", "HEIGHT", xGridPropNum.Spinner_1.Value )
      ENDCASE


      IF xGridPropNum.Label_1.Value = "VirtualWidth:"  .OR. ;
         xGridPropNum.Label_1.Value = "VirtualHeight:" .OR. ;
         xGridPropNum.Label_1.Value = "MinWidth:"      .OR. ;
         xGridPropNum.Label_1.Value = "MinHeight:"     .OR. ;
         xGridPropNum.Label_1.Value = "MaxWidth:"      .OR. ;
         xGridPropNum.Label_1.Value = "MaxHeight:"

         LoadProp( A1, A4 )
      ENDIF
   ENDIF

   RELEASE WINDOW xGridPropNum

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropOk()
*------------------------------------------------------------*
   //LOCAL A1
   //LOCAL A3
   //LOCAL A4
   LOCAL x1           AS NUMERIC
   LOCAL x2           AS USUAL     //? VarType
   LOCAL X3           AS USUAL     //? VarType
   LOCAL X4           AS USUAL     //? VarType
   LOCAL X5           AS NUMERIC
   LOCAL X6           AS NUMERIC
   LOCAL B0           AS NUMERIC
   LOCAL B1           AS NUMERIC
   LOCAL B2           AS NUMERIC
   LOCAL ControlName  AS STRING
   LOCAL Z            AS NUMERIC
   LOCAL xRow         AS NUMERIC
   LOCAL TabHandle    AS NUMERIC
   LOCAL nPosTab      AS NUMERIC
   LOCAL cTabName     AS STRING
   LOCAL nPageNr      AS NUMERIC
   LOCAL cBackColor   AS STRING
   LOCAL nCtrl        AS NUMERIC
   LOCAL acOptions    AS ARRAY
   LOCAL nSpacing     AS NUMERIC

   IF xGridPropEdit.Combo_1.Value = 2
      SetColValue( "XGRID_1", "ObjectInspector", 2, A4 )
   ENDIF

   A1 := GetColValue( "XGRID_1", "ObjectInspector", 1 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A3 # "Form"

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF A1 = "FontBold" .OR. A1 = "FontItalic" .OR. A1 = "FontStrikeOut" .OR. A1 = "FontUnderLine"
         SetProperty( "FORM_1", A3, "VISIBLE", .F. )
         SetProperty( "FORM_1", A3, A1, iif( A4 == ".T.", .T., .F. ) )
         SetProperty( "FORM_1", A3, "VISIBLE", .T. )
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF A1 = "Horizontal" .AND. xTypeControl( A3 ) = "RADIO"
         z           := GetControlIndex( A3, "Form_1" )
         ControlName := A3
         // MsgBox( "ControlName= " + ControlName )
         b0          := _HMG_aControlRow[ z ]
         b1          := _HMG_aControlCol[ z ]
         b2          := _HMG_aControlWidth[ z ]
         X1          := xControle( ControlName )
         x5          := _HMG_aControlContainerRow[ z ]
         x6          := _HMG_aControlContainerCol[ z ]
         nSpacing    :=  Val( xArray[ X1, 41 ] )

         IF A4 # xArray[ x1, 49 ]
            IF X5 # -1                           // radio is in tab
               X2 := _HMG_aControlRangeMin[ z ]  //:= TABNAME
               X3 := _HMG_aControlRangeMax[ z ]  //:= "FORM_1"
               X4 := _GetValue( X2, "Form_1" )
            ENDIF

            DoMethod( "Form_1", ControlName, "Release" )

            acOPTIONS := &(xArray[ X1, 13] )
            // MsgBox("spacing= "+str(nspacing) )                                       &
            IF A4 = ".F."
               @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOPTIONS value 1 WIDTH b2  SPACING nSpacing  ON CHANGE  cpreencheGrid( "RADIOGROUP" ) TOOLTIP ControlName
            ELSE
               @ b0, b1 RADIOGROUP  &ControlName OF FORM_1 OPTIONS acOPTIONS value 1 WIDTH b2  SPACING nSpacing  ON CHANGE  cpreencheGrid( "RADIOGROUP" ) TOOLTIP ControlName  HORIZONTAL
            ENDIF

            // CONECT TO TAB
            IF X5 # -1   // radio is in tab
               // MsgBox("ControlName= "+ControlName)
               z := GetControlIndex( ControlName, "Form_1" )

               _AddTabControl( X2, ControlName, "FORM_1", X4, b0-x5, b1-x6 )

               _HMG_aControlRangeMin[ z ] := X2
               _HMG_aControlRangeMax[ z ] := X3

               CHideControl(_HMG_aControlhandles[ z, 1 ] )
               CShowControl(_HMG_aControlhandles[ z, 1 ] )
            ENDIF
         ENDIF
      ENDIF

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      SavePropControl( A3, A4, A1 )

      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      IF A1 = "Border" .AND. xTypeControl( A3 ) = "LABEL"
         ControlName := A3
         nCtrl       := xControle( ControlName )
         ***********************************
         z           := GetControlIndex( ControlName, "Form_1" )
         xRow        := _HMG_aControlContainerRow[ z ]
         // xCol     := _HMG_aControlContainerCol[ z ]

         IF XRow # -1   // control is in tab
            TabHandle := FindTabHandle( ControlName )
            nPosTab   := aScan( _HMG_aControlHandles, TabHandle )
            cTabName  := _HMG_aControlNames[ nPosTab ]
            nPageNr   := _GetValue( cTabName, "Form_1" )
         ENDIF

         *****************************
         DoMethod( "Form_1", ControlName, "Release" )

         IF xArray[ nCtrl, 39 ] # "NIL"
            cBackColor := xArray[ nCtrl, 39 ]
         ELSE
            cBackColor := "{228,228,228}"
         ENDIF

         DEFINE LABEL      &ControlName
           PARENT          Form_1
           ROW             Val( xArray[ nCtrl,  5] )
           COL             Val( xArray[ nCtrl,  7] )
           WIDTH           Val( xArray[ nCtrl,  9] )
           HEIGHT          Val( xArray[ nCtrl, 11] )
           VALUE           NoQuota( xArray[ nCtrl, 13 ] )
           FONTNAME        xArray[15]
           FONTSIZE        Val(xArray[nCtrl,17] )
           ACTION          {|| ControlFocus(), cpreencheGrid()}
           TOOLTIP         ControlName
           BACKCOLOR       Str2Array(cBackColor)
           FONTCOLOR       Str2Array(xArray[ nCtrl, 41] )
           FONTBOLD        &(xArray[ nCtrl, 21] )
           FONTITALIC      &(xArray[ nCtrl, 23] )
           FONTUNDERLINE   &(xArray[ nCtrl, 25] )
           FONTSTRIKEOUT   &(xArray[ nCtrl, 27] )
           TRANSPARENT     &(xArray[ nCtrl, 33] )
           BORDER          iif( A4 = ".F.", .F., .T. )
           AUTOSIZE        &(xArray[ nCtrl, 37 ] )
           IF xArray[ nCtrl, 47 ] = ".T."
              RIGHTALIGN .T.
           ELSEIF xArray[ nCtrl, 49 ] = ".T."
              CENTERALIGN .T.
           ENDIF
         END LABEL

         IF xRow # -1   // control is in tab
            z := GetControlIndex( ControlName, "Form_1" )
           _AddTabControl( cTabName, ControlName, "FORM_1", nPageNr, Val( xArray[ nCtrl, 5 ] ), Val( xArray[ nCtrl, 7 ] ) )
         ENDIF

         CHideControl( _HMG_aControlhandles[ z ] )
         CShowControl( _HMG_aControlhandles[ z ] )

      ENDIF

   ELSE
      x1 := GetColValue( "XGRID_1", "ObjectInspector", 1 )
      x2 := GetColValue( "XGRID_1", "ObjectInspector", 2 )

      LoadProp( x1, x2 )
   ENDIF

   RELEASE WINDOW xGridPropEdit

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropCombOk()
*------------------------------------------------------------*
   LOCAL stp AS LOGICAL := .F.
   LOCAL A1  AS USUAL           //? VarType
   LOCAL A3  AS USUAL           //? VarType

   SetColValue( "XGRID_1", "ObjectInspector", 2, xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) )

   xGridPropCombo.Label_2.Visible := .F.

   A1 := GetColValue( "XGRID_1", "ObjectInspector", 1 )
   A3 := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value )

   // MsgBox("A3= "+A3+ " font= " +xGridPropCombo.Combo_1.Item(xGridPropCombo.Combo_1.Value)+ " A1= "+ A1)

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "FontName"
      Stp := .T.
      IF xGridPropCombo.RadioGroup_1.Value = 1
         SavePropControl( A3, '"' + xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) + '"', A1 )
      ELSE
         SavePropControl( A3, xGridPropCombo.Text_1.Value, A1 )
      ENDIF
      *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      aData[ _PROJECTFONTNAME ] := xGridPropCombo.Text_1.Value

      SavePreferences()
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "DataType"
      Stp := .T.

      IF xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) = "DATE"
          SavePropControl( A3, ".T.", "DATE"      )
          SavePropControl( A3, ".F.", "NUMERIC"   )
          SavePropControl( A3, ".F.", "CHARACTER" )
          SavePropControl( A3, ".F.", "PASSWORD"  )

          IF xTypeControl( A3 ) == "TEXTBOX"
             SavePropControl( A3, ".F.", "LOWER" )
             SavePropControl( A3, ".F.", "UPPER" )
             ObjInsFillGrid()
          ENDIF

      ELSEIF xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) = "NUMERIC"
         SavePropControl( A3, ".T.", "NUMERIC"   )
         SavePropControl( A3, ".F.", "CHARACTER" )
         SavePropControl( A3, ".F.", "PASSWORD"  )

         IF xTypeControl( A3 )=="TEXTBOX"
            SavePropControl( A3, ".F.", "DATE"  )
            SavePropControl( A3, "NIL", "VALUE" )
            SavePropControl( A3, ".F.", "LOWER" )
            SavePropControl( A3, ".F.", "UPPER" )
            ObjInsFillGrid()
         ENDIF

      ELSEIF xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) = "CHARACTER"
         SavePropControl( A3, ".F.", "NUMERIC"   )
         SavePropControl( A3, ".T.", "CHARACTER" )
         SavePropControl( A3, ".F.", "PASSWORD"  )

         IF xTypeControl( A3 )== "TEXTBOX"
            SavePropControl( A3, ".F.", "DATE"  )
            SavePropControl( A3, "''" , "VALUE" )
            ObjInsFillGrid()
         ENDIF

      ELSEIF xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) = "PASSWORD"
         iif( xTypeControl( A3 ) == "TEXTBOX", SavePropControl( A3, ".F.", "DATE" ), NIL )
         SavePropControl( A3, ".T.", "PASSWORD"  )
         SavePropControl( A3, ".F.", "NUMERIC"   )
         SavePropControl( A3, ".F.", "CHARACTER" )

         IF xTypeControl( A3 ) == "TEXTBOX"
            SavePropControl( A3, ".F.", "LOWER" )
            SavePropControl( A3, ".F.", "UPPER" )
            ObjInsFillGrid()
        ENDIF
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF A1 = "CaseConvert"
      stp := .T.
      IF xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) = "NONE"
         SavePropControl( A3, ".T.", "NONE"      )
         SavePropControl( A3, ".F.", "LOWERCASE" )
         SavePropControl( A3, ".F.", "UPPERCASE" )

      ELSEIF xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) = "UPPER"
         SavePropControl( A3, ".F.", "NONE"      )
         SavePropControl( A3, ".F.", "LOWERCASE" )
         SavePropControl( A3, ".T.", "UPPERCASE" )

      ELSEIF xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) = "LOWER"
         SavePropControl( A3, ".F.", "NONE"      )
         SavePropControl( A3, ".T.", "LOWERCASE" )
         SavePropControl( A3, ".F.", "UPPERCASE" )
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF stp = .F.
      SavePropControl( A3, xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ), A1 )
   endif
   IF ! stp .AND. A3 # "Form"
      SetProperty( "FORM_1", A3, "VISIBLE",.F.)
      SetProperty( "FORM_1", A3, A1, xGridPropCombo.Combo_1.Item( xGridPropCombo.Combo_1.Value ) )
      SetProperty( "FORM_1", A3, "VISIBLE",.T.)
   ENDIF

   RELEASE WINDOW xGridPropCombo

RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropCombNo()
*------------------------------------------------------------*
   RELEASE WINDOW xGridPropCombo
RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropTxtNo()
*------------------------------------------------------------*
   RELEASE WINDOW xGridPropTxt
RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropNumNo()
*------------------------------------------------------------*
   LOCAL A1 AS USUAL := GetColValue( "XGRID_1", "ObjectInspector", 1 )                  //? VarType
   LOCAL A3 AS USUAL := ObjectInspector.xCombo_1.Item( ObjectInspector.xCombo_1.Value ) //? VarType

   IF xGridPropNum.Label_1.Value = "MaxLength:"
      IF MsgYesNo( "Restore defaults?", "HMGS-IDE" )
         SetColValue( "XGRID_1", "ObjectInspector", 2, "NIL" )
         SavePropControl( A3, "NIL", A1 )
      ENDIF
   ENDIF

   RELEASE WINDOW xGridPropNum
RETURN


*------------------------------------------------------------*
PROCEDURE xGridPropNo()
*------------------------------------------------------------*
   RELEASE WINDOW xGridPropEdit
RETURN


*------------------------------------------------------------*
PROCEDURE xGridEvenNo()
*------------------------------------------------------------*
   RELEASE WINDOW xGridEvenTxt
RETURN


*------------------------------------------------------------*
FUNCTION SavePropControl(                          ; // Save Property Control
                          ControlName  AS STRING , ; // Name of Control
                          ValorControl AS USUAL  , ; //? ValorControl change to english name
                          PropName     AS STRING , ; // Property Name
                          RetValue     AS USUAL    ; //? VarType
                        )
*------------------------------------------------------------*
   LOCAL x1      AS USUAL
   LOCAL x2      AS NUMERIC
   LOCAL y       AS NUMERIC
   LOCAL xArray3 AS ARRAY
   LOCAL Value   AS USUAL   := NIL  //? VarType

   // MsgBox( "name= " + ControlName + CRLF + " value= " + ValorControl + CRLF + " PropName= " + PropName )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF ControlName = "Form"
      LoadProp( PropName, ValorControl, RetValue )
      RETURN( NIL )
   ENDIF

   x1 := xControle( ControlName )

   // MsgBox( "pos"+Str(x1)+" =x1" )
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,1]+" "+xArray[x1,2]+" "+xArray[x1,3]+" "+xArray[x1,4]+" "+xArray[x1,5]+" "+xArray[x1,6]+" "+xArray[x1,7] )
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,8]+" "+xArray[x1,9]+" "+xArray[x1,10]+" "+xArray[x1,11]+" "+xArray[x1,12]+" "+xArray[x1,13])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,14]+" "+xArray[x1,15]+" "+xArray[x1,16]+" "+xArray[x1,17]+" "+xArray[x1,18]+" "+xArray[x1,19])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,20]+" "+xArray[x1,21]+" "+xArray[x1,22]+" "+xArray[x1,23]+" "+xArray[x1,24]+" "+xArray[x1,25])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,26]+" "+xArray[x1,27]+" "+xArray[x1,28]+" "+xArray[x1,29]+" "+xArray[x1,30]+" "+xArray[x1,31])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,32]+" "+xArray[x1,33]+" "+xArray[x1,34]+" "+xArray[x1,35]+" "+xArray[x1,36]+" "+xArray[x1,37])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,38]+" "+xArray[x1,39]+" "+xArray[x1,40]+" "+xArray[x1,41]+" "+xArray[x1,42]+" "+xArray[x1,43])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,44]+" "+xArray[x1,45]+" "+xArray[x1,46]+" "+xArray[x1,47]+" "+xArray[x1,48]+" "+xArray[x1,49])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,50]+" "+xArray[x1,51]+" "+xArray[x1,52]+" "+xArray[x1,53]+" "+xArray[x1,54]+" "+xArray[x1,55])
   // MsgBox( "pos"+Str(x1)+" "+xArray[x1,56]+" "+xArray[x1,57]+" "+xArray[x1,58]+" "+xArray[x1,59]+" "+xArray[x1,60]+" "+xArray[x1,61] +" "+xArray[x1,62] +" "+xArray[x1,63]+" "+xArray[x1,64] +" "+xArray[x1,65])
   // MsgBox( "X" + xArray[x1,73]+"X"+"=backcolor")
   ******************
   // A := xArray[x1,1] + " " + xArray[x1,2] + " " + xArray[x1,3] + " " + CRLF
   // FOR X = 4 TO 71 STEP 2
   //     A:= A + xArray[x1,X] + " " + xArray[x1, X+1 ] + CRLF
   // NEXT X
   // MsgBox( "VALOR= " + A )
   
  *  MsgBox( "Control nr=" + Str( CurrentControl ) + CRLF + "nome=" + CurrentControlName )
   *****************
   /*
    ccc := ""
    nBreak :=  1
    FOR x := 1 to 512   
    if  xArray[ X1 , x ] # NIL
       ccc += Str(x) + PADL(xArray[ X1 , x ],25,"_")
       IF X = nBreak
         CCC += CRLF
         nBreak := nBreak +2
       ENDIF

    ENDIF
    next    
    IF !IsWIndowDefined ( "DEBUG_1")
    DEFINE WINDOW DEBUG_1  AT 35 , 564 WIDTH 850 HEIGHT 918 TITLE "Debug Log" CHILD TOPMOST NOMAXIMIZE NOSIZE ON INTERACTIVECLOSE EVAL({||  DEBUG_1.HIDE })
       DEFINE EDITBOX Edit_1
            ROW    30
            COL    30
            WIDTH  840
            HEIGHT 840
            VALUE ''
            FONTNAME 'Courier New' 
            FONTSIZE 10
            TOOLTIP ''
            MAXLENGTH  NIL
       END EDITBOX
   END WINDOW
   ENDIF
    DEBUG_1.EDIT_1.VALUE := CCC
    *MsgBox( ccc )
    if !IsWIndowActive ( "Debug_1")
        ACTIVATE WINDOW DEBUG_1
    endif
    IF IsWIndowDefined ( "DEBUG_1") 
        SHOW WINDOW DEBUG_1
    endif
    */
   *******************


   xArray3 := {}

   FOR y := 1 TO Len( xArray[x1] )
       IF ValType( xArray[ x1, y ] ) = "C"
          aAdd( xArray3, Upper( xArray[ x1, y ] ) )
       ENDIF
   NEXT y

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xTypeControl( ControlName ) == "TREE" .OR. xTypeControl( ControlName ) == "TBROWSE"
      IF Upper( PropName ) == "ROW"
         PropName := "AT"
      ELSEIF Upper( PropName ) == "COL"
         PropName := ","
      ENDIF
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xTypeControl( ControlName ) == "TAB"

      DO CASE
         CASE Upper( PropName ) == "ROW"           ; PropName := "AT"
         CASE Upper( PropName ) == "COL"           ; PropName := ","
         CASE Upper( PropName ) == "FONTNAME"      ; PropName := "FONT"
         CASE Upper( PropName ) == "FONTSIZE"      ; PropName := "SIZE"
         CASE Upper( PropName ) == "FONTBOLD"      ; PropName := "BOLD"
         CASE Upper( PropName ) == "FONTITALIC"    ; PropName := "ITALIC"
         CASE Upper( PropName ) == "FONTUNDERLINE" ; PropName := "UNDERLINE"
         CASE Upper( PropName ) == "FONTSTRIKEOUT" ; PropName := "STRIKEOUT"
         CASE Upper( PropName ) == "ONCHANGE"      ; PropName := "ON CHANGE"
      ENDCASE
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xTypeControl( ControlName ) == "TREE"
      DO CASE
         CASE Upper( PropName ) == "ONGOTFOCUS"    ; PropName := "ON GOTFOCUS"
         CASE Upper( PropName ) == "ONCHANGE"      ; PropName := "ON CHANGE"
         CASE Upper( PropName ) == "ONLOSTFOCUS"   ; PropName := "ON LOSTFOCUS"
         CASE Upper( PropName ) == "ONDBLCLICK"    ; PropName := "ON DBLCLICK"
      ENDCASE
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Upper( PropName ) == "SELECTFILTERFOR"
      PropName := "FOR"
   ELSEIF Upper( PropName ) ==  "SELECTFILTERTO"
      PropName := "TO"
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF PropName # "NAME"
      x2 := aScan( xArray3, Upper( PropName ), 4 )
   ELSE
      x2 := aScan( xArray3, Upper( PropName ) )
   ENDIF

    //MsgBox( "PropName= "       + PropName                        )
    //MsgBox( "position= "       + str(x2) + " in array"           )
    //MsgBox( xArray3[x2+1]      + " "     + " old value in temp"  )
    //MsgBox( xArray[ x1, x2+1 ] + " "     + " old value in final" )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF RetValue = NIL
      xArray3[x2+1]      := ValorControl
      xArray[ x1, x2+1 ] := xArray3[ x2+1 ]
   ELSE
      Value := xArray[ x1, x2+1 ]
   ENDIF

    //MsgBox( xArray3[ x2+1 ]    + " " + " new value in temp"  )
    //MsgBox( xArray[ x1, x2+1 ] + " " + " new value in final" )

RETURN( Value )


*------------------------------------------------------------*
FUNCTION xTypeControl( Param AS STRING )
*------------------------------------------------------------*
   LOCAL x1        AS NUMERIC
   LOCAL RetValue  AS STRING

   IF Param = "Form"
      RetValue := "FORM"
   ELSE
      x1 := xControle( Param )
      // MsgBox( Str( x1 ) + " =x1" + " param= " + param )
      RetValue := iif( x1 > 0, xArray[ x1, 1 ], "" )  // Renaldo
   ENDIF
   // MsgBox( "type of control= " + retvalue )

RETURN( RetValue )


*------------------------------------------------------------*
PROCEDURE ChangeGridValue(                         ;
                           cProp        AS STRING, ; // Property
                           cValue       AS STRING, ; // Value
                           cControlName AS STRING  ; // Control Name
                         )
*------------------------------------------------------------*
   LOCAL x AS NUMERIC

   SavePropControl( cControlName, cValue, cProp )

   FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

       ObjectInspector.xGrid_1.Value := x

       IF GetColValue( "xgrid_1", "ObjectInspector", 1 ) == cProp
          SetColValue( "xgrid_1", "ObjectInspector", 2, cValue )
          EXIT
       ENDIF

   NEXT x

RETURN
