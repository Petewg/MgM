/*******************************************************************************
    Filename        : quickb.prg
    URL             : \\ServerName\Minigui\UTILS\QBGen\quickb.prg

    Created         : 05 January 2018 (16:38:14)
    Created by      : Pierpaolo Martinello

    Last Updated    : 08 January 2018 (14:03:44)
    Updated by      : Pierpaolo

    Comments        : MAIN                       Line 46
*******************************************************************************/
/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Demo was contributed to HMG forum by Dragan Cizmarevic alias Dragancesu 14/Jan/2015
 *
 * Adapted and enhanced for MiniGUI Extended Edition by Pierpaolo Martinello and Grigory Filatov
 */

#include <hmg.ch>
#include "Directry.ch"
#include "dbstruct.ch"
#include "i_winuser.ch"

#define HTCAPTION      2
#define IDI_MAIN 1001
#define _DLLRES_

#define BDER      BROWSE_JTFY_RIGHT
#define BIZQ      BROWSE_JTFY_LEFT
#define BCEN      BROWSE_JTFY_CENTER

#define GDER      GRID_JTFY_RIGHT
#define GIZQ      GRID_JTFY_LEFT
#define GCEN      GRID_JTFY_CENTER

#define NTrim( n ) LTRIM( STR( n,20, IF( n == INT( n ), 0, set(_SET_DECIMALS) ) ))
#TRANSLATE ZAPS(<X>) => ALLTRIM(STR(<X>))
#define msgtest( c ) MSGSTOP( "Procedura: "+Procname()+CRLF+c, hb_ntos(procline()))

MEMVAR cShortAlias, cDbF, aFilesDBF, aControlsOrder, nTextBox, nWidth, nLabel
MEMVAR nDatePicker, nComboBox, nLong, nLongControl,lImage, nButton
MEMVAR Field_Name , Field_Type , Field_Len , Field_Dec , nFields, aJustify
MEMVAR _Nrow, _Ncol, _Nwidth, _Nheight, nCheckBox, nEditBox,nRadioGroup
MEMVAR aRadio1, aRadio2, aRadio3, aRadio4, aRadio5
MEMVAR aCombo1, aCombo2, aCombo3, aCombo4, aCombo5
MEMVAR aColorP, aColorF,_ColorB, aColorB, _colorF, aColorBackGrid, aColorFontGrid
MEMVAR _FONTSIZE, _FONTNAME, _FONTBOLD, _FONTITALIC, _FONTUNDERLINE, _ACT, aPlen
MEMVAR _FONTSTRIKEOUT, _TRANSPARENT, _VALUE, _TOOLTIP, _CAPTION ,_TITLE,_FLAT
MEMVAR _OPTIONS, _PICTURE ,_CASECONVER,_AITEMS, _AOPTIONS,_NSPACING,CFILE
MEMVAR _InputMask, _CaseConvert,_SPACING, NGROWGRID ,AWIDTHSCOL,CFIELDS
MEMVAR nLongDbf, nLongField,aControlsAct,nrowgrid,cpropiedad,acampospos

Set procedure to tReport.prg

FUNCTION MAIN()
    LOCAL aDirectory, cPDll:= cFilePath(GetExeFileName())+"\QbGen.Dll"

    PUBLIC aColorWinB, aColorWinF, aItems , aInputMask , aCaseConvert
    PUBLIC aControlList, aProperties , aControlsOrder, cNameControl
    PRIVATE aFilesDBF := {}
    M->aItems :={} ; m->aInputMask :={} ; m->aCaseConvert :={}; m->aControlList :={}
    m->aProperties := {}; m->aControlsOrder := {}
    m->aColorWinB := {0,255,255} ; m->aColorWinF := {0,0,0}

    If !File( cPDll )
      MsgStop("There is no resource file for the program!" + CRLF + cPDll )
      Quit
    Endif
    REQUEST HB_LANG_IT
    REQUEST HB_LANG_ES

    //hb_langSelect( "it" )
    // SET CODEPAGE TO SPANISH   // Put here your codepage
    SET RESOURCES TO ( cPDll )
    SET TOOLTIPSTYLE BALLOON
    SET DATE FORMAT "dd/mm/yyyy"

    aDirectory := DIRECTORY("*.DBF")
    AEVAL( aDirectory, {|aFile| AADD(aFilesDBF,SUBSTR(aFile[F_NAME],1,AT(".",aFile[F_NAME])-1))} )

    DEFINE WINDOW Form_1 AT 0,0 WIDTH 160 HEIGHT 180 TITLE 'Quick Browse Generator';
         MAIN ;
         ON MOUSECLICK nil ;
         ICON '1Register' ;
         ON INIT nil ;
         ON SIZE nil ;
         ON RELEASE dbCloseAll() ;
         NOMINIMIZE NOMAXIMIZE NOSIZE

        DEFINE COMBOBOX Combo_1
            ROW    20
            COL    10
            WIDTH  120
            HEIGHT 100
            ITEMS aFilesDBF
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE MyScreen(This.Value)
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
            IMAGE Nil
            DROPPEDWIDTH Nil
            ONDROPDOWN Nil
            ONCLOSEUP Nil
        END COMBOBOX

        DEFINE BUTTON Button_1
            ROW    80
            COL    10
            WIDTH  120
            HEIGHT 30
            ACTION CreatePRG()
            CAPTION "MAKE Prg"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            HELPID Nil
            FLAT .F.
            TABSTOP .T.
            VISIBLE .F.
            TRANSPARENT .F.
            MULTILINE .F.
            PICTURE Nil
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE COMBOBOX Combo_2
            ROW    180
            COL    10
            WIDTH  120
            HEIGHT 180
            ITEMS m->aControlList
            VALUE 0
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            ONCHANGE ConfigValores(This.Value)
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            TABSTOP .T.
            VISIBLE .T.
            SORT .F.
            ONENTER Nil
            ONDISPLAYCHANGE Nil
            DISPLAYEDIT .F.
            IMAGE Nil
            DROPPEDWIDTH Nil
            ONDROPDOWN Nil
            ONCLOSEUP Nil
        END COMBOBOX

        DEFINE LABEL Label_3
            ROW    220
            COL    10
            WIDTH  120
            HEIGHT 24
            VALUE "F5 = Move  -  F9 = Resize  -  F2 = About"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .T.
            ACTION Nil
            AUTOSIZE .T.
            BACKCOLOR Nil
            FONTCOLOR Nil
        END LABEL

        DEFINE CheckBox Check1
               ROW    277
               COL     85
               VALUE  .F.
               CAPTION 'Snap        Grid'
               WIDTH   90
               VALUE  .T.
        END CHECKBOX

        DEFINE SPINNER GridSpinner
            ROW    280 //218
            COL    180
            WIDTH  40
            HEIGHT 23
            RANGEMIN 0
            RANGEMAX 50
            INCREMENT 5
            ONCHANGE DrawGrid()
            VALUE 10
        END SPINNER

        DEFINE BUTTON Button_2
            ROW    179
            COL    135
            WIDTH  25
            HEIGHT 25
            ACTION KillControl()
            CAPTION ""
            TOOLTIP "Delete the selected control from the list"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .F.
            MULTILINE .F.
            PICTURE "TRASH"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_3
            ROW    245
            COL    45
            WIDTH  25
            HEIGHT 25
            ACTION AddLabel()
            CAPTION ""
            TOOLTIP "Create a Control Label"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .F.
            MULTILINE .F.
            PICTURE "label"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_4
            ROW    245
            COL    75
            WIDTH  25
            HEIGHT 25
            ACTION AddTextC()
            CAPTION ""
            TOOLTIP "Create a Control TextBox Type Character"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .F.
            MULTILINE .F.
            PICTURE "tc"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_5
            ROW    245
            COL    10
            WIDTH  25
            HEIGHT 25
            ACTION AddTextN()
            CAPTION ""
            TOOLTIP "Create a Control TextBox Type Numeric"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .F.
            MULTILINE .F.
            PICTURE "TN"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_6
            ROW    245
            COL    105
            WIDTH  25
            HEIGHT 25
            ACTION AddCombo()
            CAPTION ""
            TOOLTIP "Create a Control Combobox"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .F.
            MULTILINE .F.
            PICTURE "Combo"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_7
            ROW    245
            COL    135
            WIDTH  25
            HEIGHT 25
            ACTION AddRadio()
            CAPTION ""
            TOOLTIP "Create a Control RadioGroup"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .t.
            MULTILINE .F.
            PICTURE "Radio"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_8
            ROW    245
            COL    165
            WIDTH  25
            HEIGHT 25
            ACTION Addcheck()
            CAPTION ""
            TOOLTIP "Create a Control CheckBox"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .t.
            MULTILINE .F.
            PICTURE "checkbox"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_9
            ROW    245
            COL    195
            WIDTH  25
            HEIGHT 25
            ACTION AddDate()
            CAPTION ""
            TOOLTIP "Create a Control DatePicker"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .t.
            MULTILINE .F.
            PICTURE "datepicker"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE BUTTON Button_10
            ROW    279
            COL    10
            WIDTH  25
            HEIGHT 25
            ACTION AddBtn()
            CAPTION ""
            TOOLTIP "Create a Control Button"
            ONGOTFOCUS Nil
            ONLOSTFOCUS Nil
            FLAT .F.
            TABSTOP .F.
            VISIBLE .T.
            TRANSPARENT .F.
            MULTILINE .F.
            PICTURE "Button"
            PICTALIGNMENT TOP
        END BUTTON

        DEFINE GRID Grid_1
            ROW    330
            COL      7
            WIDTH  222
            HEIGHT 370
            HEADERS {'     Propierties','           Value'}
            WIDTHS {107,110}
            FONTCOLOR {0,0,0}
            FONTNAME 'Arial'
            FONTSIZE 9
            VALUE 1
            Tooltip ''
            BACKCOLOR {0,255,255}
            ITEMS m->aProperties
            ON DBLCLICK  AssignProperties()
        END GRID

        DEFINE LABEL Label_1
            ROW    155
            COL    10
            WIDTH  120
            HEIGHT 24
            VALUE "Controls"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR Nil
            FONTCOLOR Nil
        END LABEL

        DEFINE LABEL Label_2
            ROW    310
            COL    10
            WIDTH  120
            HEIGHT 20
            VALUE "Properties"
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .F.
            ACTION Nil
            AUTOSIZE .F.
            BACKCOLOR Nil
            FONTCOLOR Nil
        END LABEL

        DEFINE LABEL Label_D   // This label is used for diagnostic info
            ROW    130
            COL    10
            WIDTH  20
            HEIGHT 24
            VALUE ""
            FONTNAME "Arial"
            FONTSIZE 9
            TOOLTIP ""
            FONTBOLD .F.
            FONTITALIC .F.
            FONTUNDERLINE .F.
            FONTSTRIKEOUT .F.
            HELPID Nil
            VISIBLE .T.
            TRANSPARENT .T.
            ACTION Nil
            AUTOSIZE .T.
            BACKCOLOR Nil
            FONTCOLOR Nil
        END LABEL

        ON KEY ESCAPE ACTION ThisWindow.Release
        ON KEY F2 OF Form_1 ACTION m_about( )

    END WINDOW    //Form_1
    ACTIVATE WINDOW Form_1
Return NIL
/*
*/
*-----------------------------------------------------------------------------*
Function MyScreen(nOption)
*-----------------------------------------------------------------------------*
LOCAL aStruc,lstruct, n, i, nwF,  vtt := {} , vtl := {} , vtd := {}
PRIVATE cDBF, Field_Name , Field_Type , Field_Len , Field_Dec , nFields , aWidthsCol
PRIVATE aPLen := {}, aJustify := {} , aColorP := {0,255,255}
PRIVATE aColorBackGrid:= {0,255,255} , aColorFontGrid := {0,0,0}

     if nOption = 0
        return nil
     Endif

    IF IsWindowDefined("Win_1")
       Form_1.Combo_2.DeleteAllItems
       m->aControlList := {}
       DBCOMMITALL()
       Domethod( 'Win_1', 'Release')
    Endif

    dbCloseAll()

    set navigation extended
    set deleted on

    cDbF := aFilesDBF[nOption]

    USE &cDBF VIA "DBFCDX" NEW SHARED

    aStruc     := dbStruct()
    lstruct    := Len(aStruc)
    Field_Name := Array(lstruct)
    Field_Type := Array(lstruct)
    Field_Len  := Array(lstruct)
    Field_Dec  := Array(lstruct)
    aWidthsCol := Array(lstruct)

    nFields := &cDBF->(AFIELDS(Field_Name, Field_Type, Field_Len, Field_Dec))

    nwF := PickField(Field_name)

    if len( nwF ) < 1
       MessageBoxTimeout (padc('Action aborted by user!',50 ),"", MB_ICONSTOP, 2300 )
       return nil
    Endif

    nfields := len( nwf )
    FOR n = 1 to nfields
        i := ascan( field_name,nwf[n] )
        if i > 0
           aadd( vtt,Field_type[i] )
           aadd( vtl,Field_Len[i]  )
           aadd( vtd,Field_Dec[i]  )
           aadd(aPlen,Max(100,Min(160,Field_Len[i]*14)))
        Endif
    NEXT
    Field_name := aclone( nWf )
    Field_type := aclone( Vtt )
    Field_len  := aclone( Vtl )
    Field_Dec  := aclone( Vtd )

    FOR i = 1 TO nfields //&cDBF->( FCount() )
        aWidthsCol[i] := IIF(Field_Len[i]<=2 , Field_Len[i]* 30, Field_Len[i]* 10)
        IF Field_Type[i] = 'N'
            AAdd( aJustify , 'GDER' )
        ELSEIF Field_Type[i] = 'D' .OR. Field_Type[i] = 'L'
            AAdd( aJustify , 'GCEN' )
        ELSE
            AAdd( aJustify , 'GIZQ' )
        Endif
    NEXT i

    DEFINE WINDOW Win_1  ;
        AT 0,250  ;
        WIDTH 950  ;
        HEIGHT 750  ;
        TITLE m->cDbF ;
        WINDOWTYPE STANDARD ;
        NOMAXIMIZE ;
        FONT 'Arial' ;
        SIZE 9 ;
        BACKCOLOR m->aColorWinB ;
        ON MOUSECLICK SelectControl(This.Name) ;
        ON INIT (AddControls(),AddFields() ) ;
        ON RELEASE ( form_1.setfocus , Form_1.HEIGHT := 180 , Form_1.WIDTH := 180 ,(aControlsOrder := {}), Form_1.Button_1.Visible:= .F., CloseForm() );
        ON PAINT ReDrawgrid()

      DEFINE STATUSBAR FONT 'Arial' SIZE 12
         STATUSITEM 'Db '
         KEYBOARD WIDTH 80
         DATE WIDTH 100
         CLOCK WIDTH 100
      END STATUSBAR

      ON KEY F5 OF WIN_1 ACTION OnKeyPress( VK_F5 )
      ON KEY F9 OF WIN_1 ACTION OnKeyPress( VK_F9 )

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 60,40 FLAT BORDER

          BUTTON FIRST ;
             CAPTION '&First' ;
             PICTURE 'go_first' ;
             ACTION NIL

          BUTTON PREV ;
             CAPTION '&Prev' ;
             PICTURE 'go_prev' ;
             ACTION NIL AUTOSIZE

          BUTTON NEXT ;
             CAPTION '&Next' ;
             PICTURE 'go_next' ;
             ACTION NIL AUTOSIZE

          BUTTON LAST ;
             CAPTION '&Last' ;
             PICTURE 'go_last' ;
             ACTION NIL   SEPARATOR

          BUTTON NEW ;
             CAPTION '&New' ;
             PICTURE 'edit_new' ;
             ACTION NIL

          BUTTON EDIT ;
             CAPTION '&Edit' ;
             PICTURE 'edit_edit' ;
             ACTION NIL

          BUTTON SAVE ;
             CAPTION '&Save' ;
             PICTURE 'ok' ;
             ACTION NIL

          BUTTON CANCEL ;
             CAPTION '&Cancel' ;
             PICTURE 'cancel' ;
             ACTION NIL

          BUTTON DELETE ;
             CAPTION '&Delete' ;
             PICTURE 'edit_delete' ;
             ACTION  NIL  SEPARATOR

          BUTTON FIND ;
             CAPTION 'F&ind' ;
             PICTURE 'edit_find' ;
             ACTION NIL

          BUTTON QUERY  ;
             CAPTION '&Query' ;
             PICTURE 'edit_find' ;
             ACTION NIL

          BUTTON Print_1 ;
             CAPTION 'P&rint' ;
             PICTURE 'edit_print' ;
             ACTION PrintList(m->cDbf, Field_name, aPlen) SEPARATOR DROPDOWN

             DEFINE DROPDOWN MENU BUTTON Print_1
                    ITEM 'Register'    ACTION MsgBox('Print Register')
                    ITEM 'Catalog'     ACTION MsgBox('Print Catalog')
                    ITEM 'For selected fields' ACTION MsgBox('Print for selected fields')
             END MENU

          BUTTON Tools ;
             CAPTION '&Tools' ;
             PICTURE 'options' ;
             ACTION nil SEPARATOR AUTOSIZE DROPDOWN

             DEFINE DROPDOWN MENU BUTTON TOOLS
                    ITEM "Background color" Action Msgbox("Save_color()") image "Raimbow"
                    ITEM 'User Report Editor' ACTION PrintList(m->cDbf, Field_name, aPlen, .T.) IMAGE 'edit_print'
             END MENU

          BUTTON EXIT ;
             CAPTION 'E&xit' ;
             PICTURE 'edit_close' ;
             ACTION  Win_1.Release

      END TOOLBAR

     @ 430, 720 IMAGE Image_1 PICTURE 'Logo.jpg' ACTION SelectControl('Image_1') WIDTH 200 HEIGHT 200 STRETCH TRANSPARENT ToolTip 'Demo Image'
     AddMnC("Image_1")

        DEFINE GRID Grid_1
            ROW  75
            COL 10
            WIDTH 915
            HEIGHT 235
            HEADERS Field_Name
            WIDTHS aWidthsCol
            VALUE 1
            FONTNAME 'Arial'
            FONTSIZE 9
            Tooltip ''
            BACKCOLOR {0,255,255}
            FONTCOLOR {0,0,0}
            ON CHANGE SelectControl(this.name)
            ON GOTFOCUS SelectControl(This.Name)
            ON DBLCLICK nil
            JUSTIFY aJustify
            DYNAMICBACKCOLOR {{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()},{||GridBackColor()} }
        END GRID

    END WINDOW

    ACTIVATE WINDOW Win_1

Return Nil
/*
*/
*-----------------------------------------------------------------------------*
Procedure CloseForm()
*-----------------------------------------------------------------------------*
   If _Iswindowdefined("Form_2")
      domethod("Form_2","release")
   Endif
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure AddFields()
*-----------------------------------------------------------------------------*
   dbgotop()
   Win_1.grid_1.disableupdate
   Win_1.grid_1.deleteallitems
   While !Eof()
     Win_1.grid_1.additem(scatter())
     dbskip()
   End
   Win_1.grid_1.enableupdate
Return
/*
*/
*-----------------------------------------------------------------------------*
Static Function Scatter()
*-----------------------------------------------------------------------------*
   Local aRecord[len(m->field_name)],dummy
   aEval( m->field_name, {|x,n| aRecord[n] := Any2Strg( FIELDGet( n ) ),dummy := x } )
Return arecord
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Any2Strg( xAny )
*-----------------------------------------------------------------------------*
Local  cRVal  := '???', nType ;
       ,aCases := { { "A", { |  | "{...}" } },;
                    { "B", { |  | "{||}" } },;
                    { "C", { | x | x }},;
                    { "M", { | x | x   } },;
                    { "D", { | x | DTOC( x ) } },;
                    { "L", { | x | IF( x,"On","Off") } },;
                    { "N", { | x | NTrim( x )  } },;
                    { "O", { |  | ":Object:" } },;
                    { "U", { |  | "<NIL>" } } }

   IF (nType := ASCAN( aCases, { | a1 | VALTYPE( xAny ) == a1[ 1 ] } ) ) > 0
      cRVal := EVAL( aCases[ nType, 2 ], xAny )
   Endif

Return cRVal
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddControls()
*-----------------------------------------------------------------------------*
LOCAL cLabel,cText,cCheck,cDate,cEdit,nCol, n
LOCAL aRows := {330,360,390,420,450,480,510,540,570,600,630,330,360,390,420,450,480,510,540,570,600,630} , m := 1 , aVal
PUBLIC nLabel:= 0,nTextBox,nDatePicker,nCheckBox,nEditBox,nRadioGroup:=1,nComboBox:=1,nDatePicker,nComboBox,nRadioGroup,nButton
PUBLIC aControlsAct := {}

    Win_1.SetFocus
    nLabel := 1
*    nRow := 330
    nCol := 20
    FOR n := 1 TO nFields
        IF n <= 9 .AND. Field_Type[n] = 'M'
        ELSEIF n = 10 .AND. Field_Type[n] = 'M'
            m:= 12
            nCol := 500
        ELSEIF n = 11 .AND. Field_Type[n] = 'M'
            m:= 12
            nCol := 500
        ELSEIF n > 11
            nCol := 500
        Endif
        cLabel := "Label_"+ ZAPS(n)
        DEFINE LABEL &(cLabel)
               PARENT Win_1
               COL nCol
               ROW aRows[m]
               VALUE Field_Name[n]
               ACTION SelectControl(This.Name)
               FONTCOLOR WHITE
               BACKCOLOR BLUE
               FONTNAME 'Arial'
               FONTSIZE 9
               TOOLTIP ''
               VCENTERALIGN .T.
        END LABEL
        Win_1.&(cLabel).Refresh
        nLabel++
        AddMnC(cLabel)

        IF Field_Type[n] = 'M'
            m := m+3
        ELSE
            m := m+1
        Endif
    NEXT n
    nLabel := nLabel-1

    &cDBF->(DBGOTOP())

    nTextBox    := 1
    nDatePicker := 1
    nCheckBox   := 1
    nEditBox    := 1
    nButton     := 1

    nCol := 150
    m := 1
    FOR n := 1 TO nFields
        IF n <= 9 .AND. Field_Type[n] = 'M'
        ELSEIF n = 10 .AND. Field_Type[n] = 'M'
            m:= 12
            nCol := 630
        ELSEIF n = 11 .AND. Field_Type[n] = 'M'
            m:= 12
            nCol := 630
        ELSEIF n > 11
            nCol := 630
        Endif
        nWidth := Field_Len[n] * 10 + 20
        DO CASE
            CASE Field_Type[n] = 'C'
                cText := "TextBox_"+ ZAPS(nTextBox)
                @ aRows[m], nCol TEXTBOX &(cText) PARENT Win_1 WIDTH nWidth VALUE cText BACKCOLOR WHITE FONTCOLOR BLACK ON GOTFOCUS SelectControl(This.Name) FONT 'Arial' SIZE 9 ToolTip ''
                Win_1.&(cText).VALUE := &cDBF->&(Field_Name[n])
                AADD(m->aCaseConvert,{cText,"NONE"})
                nTextBox++
                AddMnC(cText)

            CASE Field_Type[n] = 'N'
                cText := "TextBox_"+ ZAPS(nTextBox)
                @ aRows[m], nCol TEXTBOX &(cText) PARENT Win_1 WIDTH nWidth VALUE 1 NUMERIC BACKCOLOR WHITE FONTCOLOR BLACK ON GOTFOCUS SelectControl(This.Name) FONT 'Arial' SIZE 9 ToolTip '' RIGHTALIGN
                Win_1.&(cText).VALUE := &cDBF->&(Field_Name[n])
                AADD(m->aInputMask,{cText,""})
                nTextBox++
                AddMnC(cText)

            CASE Field_Type[n] = 'D'
                cDate := "DatePicker_"+ ZAPS(nDatePicker)
                @ aRows[m], nCol DATEPICKER &(cDate) PARENT Win_1 VALUE Date() ON GOTFOCUS SelectControl(This.Name) FONT 'Arial' SIZE 9 ToolTip ''
                Win_1.&(cDate).VALUE := &cDBF->&(Field_Name[n])
                nDatePicker++
                AddMnC(cDate)

            CASE Field_Type[n] = 'L'
                cCheck := "CheckBox_"+ ZAPS(nCheckBox)
                @ aRows[m], nCol CHECKBOX &(cCheck) PARENT Win_1 CAPTION '' HEIGHT 24 BACKCOLOR aColorP FONTCOLOR BLACK ON GOTFOCUS SelectControl(This.Name) FONT 'Arial' SIZE 9 ToolTip '' TRANSPARENT
                Win_1.&(cCheck).VALUE := &cDBF->&(Field_Name[n])
                nCheckBox++
                AddMnC(cCheck)

            CASE Field_Type[n] = 'M'
                cEdit := "EditBox_"+ ZAPS(nEditBox)
                @ aRows[m], nCol EDITBOX &(cEdit) PARENT Win_1 WIDTH 300 HEIGHT 82 VALUE 'THIS IS ONLY FOR TEST' BACKCOLOR WHITE FONTCOLOR BLACK ON GOTFOCUS SelectControl(This.Name) FONT 'Arial' SIZE 9 ToolTip ''
                Win_1.&(cEdit).VALUE := &cDBF->&(Field_Name[n])
                nEditBox++
                AddMnC(cEdit)

        END CASE
        IF Field_Type[n] = 'M'
            m := m+3
        ELSE
            m := m+1
        Endif
    NEXT n
    nTextBox    := nTextBox - 1
    nDatePicker := nDatePicker - 1
    nCheckBox   := nCheckBox - 1
    nEditBox    := nEditBox - 1
    nButton     := nButton - 1

    Form_1.Combo_2.AddItem('Win_1')
    AAdd(m->aControlList,'Win_1')
    aVal := GetAllControlsByForm('Win_1')
    FOR n = 1 To Len(aVal)
        Form_1.Combo_2.AddItem(aVal[n])
        AAdd(m->aControlList,aVal[n])
    Next

    if Form_1.Combo_2.Item(4)= "Label_1"
       Form_1.Combo_2.value := 4
       Win_1.Label_1.setfocus
    Endif

    Form_1.Button_1.Visible:= .T.
    Form_1.HEIGHT := 745
    Form_1.WIDTH  := 245

Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddLabel()
*-----------------------------------------------------------------------------*
LOCAL cLabel := "Label_"+ ZAPS(nLabel+1)
    Win_1.SetFocus
    @ 600, 500 LABEL &(cLabel) PARENT Win_1 VALUE cLabel FONTCOLOR WHITE BACKCOLOR BLUE ACTION SelectControl(This.Name) FONT 'Arial' SIZE 9 TOOLTIP '' VCENTERALIGN
    AAdd(m->aControlList, cLabel)
    Form_1.Combo_2.AddItem(cLabel)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    AddMnC(cLabel)
    Win_1.&(cLabel).Refresh
    nLabel++
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddTextC()
*-----------------------------------------------------------------------------*
LOCAL cText := "TextBox_"+ ZAPS(nTextBox+1)
    @ 600, 500 TEXTBOX &(cText) PARENT Win_1 WIDTH 100 VALUE cText BACKCOLOR WHITE FONTCOLOR BLACK UPPERCASE ON GOTFOCUS SelectControl(This.Name) FONT 'Arial' SIZE 9 ToolTip ''
    AADD(m->aCaseConvert,{cText,"NONE"})
    AAdd(m->aControlList, cText)
    Form_1.Combo_2.AddItem(cText)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    nTextBox++
    AddMnC(cText)
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddTextN()
*-----------------------------------------------------------------------------*
LOCAL cText := "TextBox_"+ ZAPS(nTextBox+1)
    @ 600, 500 TEXTBOX &(cText) PARENT Win_1 WIDTH 100 VALUE 1 NUMERIC BACKCOLOR WHITE FONTCOLOR BLACK ON GOTFOCUS SelectControl(This.Name) FONT 'Arial' SIZE 9 ToolTip '' RIGHTALIGN
    AADD(m->aInputMask,{cText,""})
    AAdd(m->aControlList, cText)
    Form_1.Combo_2.AddItem(cText)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    nTextBox++
    AddMnC(cText)
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddRadio()
*-----------------------------------------------------------------------------*
    LOCAL cRadio, cVarRadio
    PUBLIC aRadio1 := aRadio2 := aRadio3 := aRadio4 := aRadio5 := {'Uno','Dos','Tres'}
    cRadio    := 'RadioGroup_'+ ZAPS(m->nRadioGroup)
    cVarRadio := 'aRadio'+ ZAPS(m->nRadioGroup)
    @600,500 RADIOGROUP &(cRadio) PARENT Win_1 OPTIONS &(cVarRadio) FONT 'Arial' Size 9 FONTCOLOR {0,0,0} BACKCOLOR {0,255,255} TOOLTIP 'RadioGroup' ON CHANGE SelectControl(This.Name) HORIZONTAL SPACING 60 TRANSPARENT
    AAdd(m->aControlList, cRadio)
    AADD(M->aItems,{cRadio,"{'Uno','Dos','Tres'}",'60',cVarRadio})
    Form_1.Combo_2.AddItem(cRadio)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    m->nRadioGroup ++
    AddMnC(cRadio)
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddCombo()
*-----------------------------------------------------------------------------*
    LOCAL cCombo, cVarCombo
    PUBLIC aCombo1 := aCombo2 := aCombo3 := aCombo4 := aCombo5 := {'A','B','C','D','E'}
    cCombo := 'ComboBox_'+ ZAPS(m->nComboBox)
    cVarCombo := 'aCombo'+ ZAPS(m->nComboBox)
    @ 600,500 COMBOBOX &(cCombo) PARENT Win_1 VALUE 1 WIDTH 100 ITEMS &(cVarCombo) ON ENTER MsgInfo ( Str(Form_1.Combo_1.value) ) ON GOTFOCUS SelectControl(This.Name) FONT 'Courier' SIZE 12
    AAdd(m->aControlList, cCombo)
    AADD(M->aItems,{cCombo,"{'A','B','C','D','E'}",,cVarCombo})
    Form_1.Combo_2.AddItem(cCombo)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    m->nComboBox++
    AddMnC(cCombo)
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddCheck()
*-----------------------------------------------------------------------------*
LOCAL cText := "CheckBox_"+ ZAPS(nCheckBox+1)
    @ 600, 500 Checkbox &(cText) PARENT Win_1 CAPTION " " WIDTH 24 HEIGHT 24 BACKCOLOR m->aColorWinB FONTCOLOR { 0,0,0 }  FONT "Arial" SIZE 9  ToolTip "" TRANSPARENT ON GOTFOCUS SelectControl(This.Name)
    AADD(m->aInputMask,{cText,""})
    AAdd(m->aControlList, cText)
    Form_1.Combo_2.AddItem(cText)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    nCheckBox++
    AddMnC(cText)
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddDate()
*-----------------------------------------------------------------------------*
LOCAL cText := "DatePicker_"+ ZAPS(nDatePicker+1)
    @ 600, 500 DatePicker &(cText) PARENT Win_1 WIDTH 124  BACKCOLOR m->aColorWinB FONTCOLOR { 0,0,0 }  FONT "Arial" SIZE 9  ToolTip "" ON GOTFOCUS SelectControl(This.Name)
    AADD(m->aInputMask,{cText,""})
    AAdd(m->aControlList, cText)
    Form_1.Combo_2.AddItem(cText)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    nDatepicker++
    AddMnC(cText)
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddBtn()
*-----------------------------------------------------------------------------*
LOCAL cText := "Button_"+ ZAPS(nButton+1)

    @ 590, 300 Button &(cText) PARENT Win_1 CAPTION cText ACTION msgbox("Action For "+cText) FONT 'Arial' SIZE 9 ON GOTFOCUS SelectControl(This.Name) TOOLTIP ""
    AAdd(m->aControlList, cText)
    Form_1.Combo_2.AddItem(cText)
    Form_1.Combo_2.VALUE := Form_1.Combo_2.ItemCount
    nButton++
    AddMnC(cText)
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AddMnc(cText)
*-----------------------------------------------------------------------------*
    DEFINE CONTEXT MENU CONTROL &(cText) of  Win_1
           MENUITEM "Move " ACTION OnKeyPress( VK_F5, .T. )
           MENUITEM "Size " ACTION OnKeyPress( VK_F9, .T. )
    END MENU
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE KillControl()
*-----------------------------------------------------------------------------*
    LOCAL cControl := m->aControlList[Form_1.Combo_2.VALUE]
    LOCAL nControl := ASCAN(m->aControlList, cControl)
    IF ascan({'Win_1','Grid_1'},cControl) > 0
       MessageBoxTimeout (padc(upper(cControl),50)+CRLF+CRLF;
              +"This control CANNOT be Erased !!","Error", MB_ICONSTOP, 1500 )
    ELSE
        Win_1.&(cControl).Release
        HB_ADel(m->aControlList,nControl,.T.)
        Form_1.Combo_2.DeleteItem ( nControl )
        DoMethod ( "Win_1" , 'Refresh')
        IF nControl <= Form_1.Combo_2.ItemCount
            Form_1.Combo_2.Value := nControl
        ELSE
            Form_1.Combo_2.Value := nControl-1
        Endif
    Endif
Return
#if 0
*----------------------------------------------------------------------------------------------------------------------------------
PROCEDURE VerControls()
*-----------------------------------------------------------------------------*
LOCAL aVal
    IF IsWindowDefined("Win_1")  // to prevent exit program whit f3 pressed and no form available
       aVal := GetAllControlsByForm('Win_1')
       MsgBox('Total controls: '+STR(Len(aVal)))
    Endif
Return
#endif
/*
*/
*-----------------------------------------------------------------------------*
Function GetAllControlsByForm ( cFormName )
*-----------------------------------------------------------------------------*
Local h , i , nControlCount , aRetVal := {}

    h := GetFormHandle ( cFormName )

    nControlCount := Len( _HMG_aControlNames )

    FOR i := 1 TO nControlCount
       IF _HMG_aControlParentHandles[i] == h
          IF !("@"+Upper(_HMG_aControlType[i])+"@" $ "@HOTKEY@@MENU@@POPUP@@TOOLBAR@@TOOLBUTTON@@MESSAGEBAR@@ITEMMESSAGE@@TIMER@")
             aAdd( aRetVal, _HMG_aControlNames[i] )
          Endif
       Endif
    NEXT

Return aRetVal
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE AssignProperties()
*-----------------------------------------------------------------------------*
LOCAL cProperty, cControl, aColor, nValor , cValor, aValor_IW
Local aCase := {'UPPER','LOWER','NONE'} ,caCombo , n, aVs
LOCAL nRowGrid

    nRowGrid  := Form_1.Grid_1.value
    cControl  := m->aControlList[Form_1.Combo_2.VALUE]
    cProperty := m->aProperties[ nRowGrid,1 ]

    IF cControl == 'Win_1'
        IF cProperty = 'BackColor'
            aColor := GetColor()
            IF ValType(aColor[1]) = 'U'
                Return
            ELSE
                m->aColorWinB := aColor
                ChangeBackGround('Win_1',aColor)
            Endif
        ELSEIF cProperty = 'Width' .OR. cProperty = 'Height' .OR. cProperty = 'Row' .OR. cProperty = 'Col'
            nValor:= GetProperty("Win_1",cProperty)
            aValor_IW := InputWindow ( 'Enter value for :', {cProperty+' :'}, {nValor}, {'9999'} )
            If aValor_IW [1] != Nil
               SetProperty ( "Win_1", cProperty , aValor_IW[1] )
            Endif
        ELSEIF cProperty = 'Title'
            cValor := GetProperty('Win_1',cProperty)
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {30} )
            If aValor_IW [1] != Nil
               SetProperty ( "Win_1", cProperty , aValor_IW[1] )
            Endif
        Endif
    ELSE
        Do Case
           CASE cProperty = 'FontColor' .OR. cProperty = 'BackColor'
            aColor := GetColor()
            IF ValType(aColor[1]) = 'U'
                Return
            Endif
            IF cControl = 'Grid_1' .AND. cProperty = 'BackColor'
                aColorBackGrid := aColor
                Win_1.Grid_1.Refresh
            ELSEIF cControl = 'Grid_1' .AND. cProperty = 'FontColor'
/*
                FOR n:= 1 TO nFields
                    aadd(dbcolor,acolor)
                    //Win_1.Grid_1.DYNAMICFORECOLOR (n) := {|| aColor}
                NEXT n
                //Win_1.Grid_1.DYNAMICFORECOLOR := {||dbcolor}
*/
            Endif
            SetProperty ( "Win_1", cControl , cProperty , aColor )

        CASE cProperty = 'Width' .OR. cProperty = 'Height' .OR. cProperty = 'Row' .OR. cProperty = 'Col' .OR. cProperty = 'FontSize'
             nValor:= GetProperty("Win_1",cControl,cProperty)
             aValor_IW := InputWindow ( 'Enter value for :', {cProperty+' :'}, {nValor}, {'9999'} )
             If aValor_IW [1] != Nil
                SetProperty ( "Win_1", cControl , cProperty , aValor_IW[1] )
             Endif

        CASE cProperty = 'FontName'
            cValor := GetProperty('Win_1',cControl,cProperty)
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {30} )
            If aValor_IW [1] != Nil
               SetProperty ( "Win_1", cControl , cProperty , aValor_IW[1] )
            Endif

        CASE cProperty = 'FontBold' .OR. cProperty = 'FontItalic' .OR. cProperty = 'FontUnderline' .OR. cProperty = 'FontStrikeOut' .OR. cProperty = 'Transparent'
            aValor_IW := InputWindow ( 'Enter value for :', {cProperty+' :'}, {0}, {{ Space(15)+'.T.' , Space(15)+'.F.'}} )
            If aValor_IW [1] != Nil
               IIF(aValor_IW[1] = 1 , aValor_IW := .T. , aValor_IW := .F.)
               SetProperty ( "Win_1", cControl , cProperty , aValor_IW )
            Endif

        CASE cProperty = 'ToolTip'
            cValor := GetProperty('Win_1',cControl,cProperty)
            IIF(cValor = Nil , cValor := "" , )
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {100} )
            If aValor_IW [1] != Nil
               SetProperty ( "Win_1", cControl , cProperty , aValor_IW[1] )
            Endif

        CASE cProperty = 'Value'
            IF cControl != 'Grid_1'
                cValor := GetProperty('Win_1',cControl,cProperty)

                IF GETCONTROLTYPE(cControl,'Win_1') = 'TEXT' //ValType(cValor) = 'C'
                    aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {30} )
                ELSEIF GETCONTROLTYPE(cControl,'Win_1') = 'EDIT'//ValType(cValor) = 'M'
                    aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor} , {500} )
                ELSEIF GETCONTROLTYPE(cControl,'Win_1') = 'NUMTEXT'//ValType(cValor) = 'N'
                    aValor_IW := InputWindow ( 'Enter value for :', {cProperty +' :'}, {cValor}, {'9999999999'} )
                ELSEIF GETCONTROLTYPE(cControl,'Win_1') = 'DATEPICK' //ValType(cValor) = 'D'
                    aValor_IW := InputWindow ( 'Enter value for :',  {cProperty +' :'}, {cValor},{} )
                ELSEIF GETCONTROLTYPE(cControl,'Win_1') = 'CHECKBOX'//ValType(cValor) = 'L'
                    aValor_IW := InputWindow ( 'Enter value for :', {cProperty +' :'}, {0}, {{ Space(15)+'.T.' , Space(15)+'.F.'}} )
                ELSEIF GETCONTROLTYPE(cControl,'Win_1') = 'COMBO'//ValType(cValor) = 'L'
                    aValor_IW := InputWindow ( 'Enter value for :', {cProperty +' :'}, {cValor}, {'9999'} )
                ELSE
                    aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {30} )
                Endif
                If aValor_IW [1] != Nil
                   IF ValType(cValor) = 'L'
                       IIF(aValor_IW[1] = 1 , aValor_IW := .T. , aValor_IW := .F.)
                       SetProperty ( "Win_1", cControl , cProperty , aValor_IW )
                   ELSE
                       SetProperty ( "Win_1", cControl , cProperty , aValor_IW[1] )
                   Endif
               Endif
            Endif

        CASE cProperty = 'Items' .OR. cProperty = 'Options'
            FOR n := 1 TO Len(M->aItems)
                IF M->aItems[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            cValor := M->aItems[n,2]
            IIF(cValor == Nil , cValor := "",)
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {100} )
            If aValor_IW [1] != Nil
               FOR n := 1 TO Len(M->aItems)
                   IF M->aItems[n,1] = cControl
                      EXIT
                   Endif
               NEXT n
               caCombo := M->aItems[n,2] := aValor_IW[1]
               IF cProperty = 'Items'
                  Win_1.&(cControl).DELETEALLITEMS
                  AEVAL(&(caCombo),{|x|Win_1.&(cControl).additem(x)})
               ELSE
                  aVs := ConfigValores()
                  Win_1.&(cControl).Release
                  DEFINE RADIOGROUP &(cControl)
                         PARENT Win_1
                         COL val(aVs[2])
                         ROW val(aVs[1])
                         OPTIONS &(caCombo)
                         VALUE val(aVs[5])
                         WIDTH val(aVs[3])
                         SPACING aValor_IW[1]
                         FONTNAME aVs[6]
                         FONTSIZE VAL(aVs[7])
                         FONTBOLD  ".T." $ aVs[8]
                         FONTITALIC  ".T." $ aVs[9]
                         FONTUNDERLINE ".T." $ aVs[10]
                         FONTSTRIKEOUT  ".T." $ aVs[11]
                         TOOLTIP aVs[14]
                         BACKCOLOR  &(aVs[13])
                         FONTCOLOR  &(aVs[12])
                         ONCHANGE SelectControl(This.Name)
                         HORIZONTAL  .T.
                  END RADIOGROUP
                  AddMnC(cControl)
               Endif
            Endif

        CASE cProperty = 'Spacing'
            FOR n := 1 TO Len(M->aItems)
                IF M->aItems[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            caCombo := M->aItems[n,2]
            nValor  := val(M->aItems[n,3])
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {nValor}, {'9999'} )
            If aValor_IW [1] != Nil
               M->aItems[n,3] := ZAPS(aValor_IW[1])
               aVs := ConfigValores()
               Win_1.&(cControl).Release
               DEFINE RADIOGROUP &(cControl)
                      PARENT Win_1
                      COL val(aVs[2])
                      ROW val(aVs[1])
                      OPTIONS &(caCombo)
                      VALUE val(aVs[5])
                      WIDTH val(aVs[3])
                      SPACING aValor_IW[1]
                      FONTNAME aVs[6]
                      FONTSIZE VAL(aVs[7])
                      FONTBOLD  ".T." $ aVs[8]
                      FONTITALIC  ".T." $ aVs[9]
                      FONTUNDERLINE ".T." $ aVs[10]
                      FONTSTRIKEOUT  ".T." $ aVs[11]
                      TOOLTIP    aVs[14]
                      BACKCOLOR  &(aVs[13])
                      FONTCOLOR  &(aVs[12])
                      ONCHANGE SelectControl(This.Name)
                      HORIZONTAL  .T.
               END RADIOGROUP
               AddMnC(cControl)
            Endif

        CASE cProperty = 'Caption'
            IF GETCONTROLTYPE(cControl,'Win_1') = 'CHECKBOX' .or.  GETCONTROLTYPE(cControl,'Win_1') = 'BUTTON'
                cValor := GetProperty('Win_1',cControl,cProperty)
                aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {30} )
                If aValor_IW [1] != Nil
                   SetProperty ( "Win_1", cControl , cProperty , aValor_IW[1] )
                Endif
            Endif

        CASE cProperty = 'InputMask'
            FOR n := 1 TO Len(m->aInputMask)
                IF m->aInputMask[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            cValor := m->aInputMask[n,2]
            IIF(cValor == Nil , cValor := "",)
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {30} )
            If aValor_IW [1] != Nil
               FOR n := 1 TO Len(m->aInputMask)
                   IF m->aInputMask[n,1] = cControl
                      EXIT
                   Endif
               NEXT n
               m->aInputMask[n,2] := aValor_IW[1]
            Endif

        CASE cProperty = 'CaseConvert'
            FOR n := 1 TO Len(m->aCaseConvert)
                IF m->aCaseConvert[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            cValor :=  ascan(aCase, m->aCaseConvert[n,2])
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor} , {{ Space(10)+'UPPER' , Space(10)+'LOWER' , Space(10)+'NONE' }} )
            If aValor_IW [1] != Nil
               FOR n := 1 TO Len(m->aCaseConvert)
                   IF m->aCaseConvert[n,1] = cControl
                      EXIT
                   Endif
               NEXT n
               m->aCaseConvert[n,2] := aCase[aValor_IW[1]]
            Endif

        CASE cProperty = 'Picture'
            cValor := GetProperty('Win_1',cControl,cProperty)
            aValor_IW := InputWindow ( 'Enter value for :' , {cProperty +' :'} , {cValor}, {30} )
            If aValor_IW [1] != Nil
               SetProperty ( "Win_1", cControl , cProperty , aValor_IW[1] )
            Endif

        CASE cProperty = 'Action'
                   MessageBoxTimeout (padc(upper(cproperty),40)+CRLF+CRLF;
              +"This property CANNOT be Edited !!","Error", MB_ICONSTOP, 2500 )
        EndCase
    Endif
    DoMethod ( "Win_1" , 'Refresh')
    ConfigValores()
Return
/*
*/
*-----------------------------------------------------------------------------*
Function ConfigValores()
*-----------------------------------------------------------------------------*
LOCAL cControl
LOCAL aVariables, n
PUBLIC _nRow           := ''
PUBLIC _nCol           := ''
PUBLIC _nwidth         := ''
PUBLIC _nheight        := ''
PUBLIC aColorB         := {}
PUBLIC aColorF         := {}
PUBLIC _ColorB         := ''
PUBLIC _ColorF         := ''
PUBLIC _FontSize       := ''
PUBLIC _FontName       := ''
PUBLIC _FontBold       := ''
PUBLIC _FontItalic     := ''
PUBLIC _FontUnderLine  := ''
PUBLIC _FontStrikeOut  := ''
PUBLIC _Transparent    := ''
PUBLIC _Value          := ''
PUBLIC _ToolTip        := ''
PUBLIC _Caption        := ''
PUBLIC _Act            := ''
PUBLIC _aItems         := ''
PUBLIC _Title          := ''
PUBLIC _InputMask      := ''
PUBLIC _CaseConvert    := ''
PUBLIC _Options        := ''
PUBLIC _Picture        := ''
PUBLIC nRowGrid        := Form_1.Grid_1.VALUE

    cControl  := m->aControlList[Form_1.Combo_2.VALUE]

    IF !IsWindowDefined("Win_1")
       return {}
    Endif

    Win_1.StatusBar.Item(1) := 'Db "'+DBF()+'" Selected Object:   >> '+cControl+' <<'

    IF cControl == 'Win_1'
        m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Title",""},{"BackColor",""}}
        * aVariables     := {_nRow,_nCol,_nWidth,_nHeight,_Title,_ColorB}
        Form_1.Grid_1.DeleteAllItems
        aeval(m->aProperties,{|x|Form_1.Grid_1.AddItem(x)})
//        Form_1.Grid_1.Refresh
        _nRow    := ZAPS(GetProperty ('Win_1' ,'Row'))
        _nCol    := ZAPS(GetProperty ('Win_1' ,'Col'))
        _nWidth  := ZAPS(GetProperty ('Win_1' ,'Width'))
        _nHeight := ZAPS(GetProperty ('Win_1' ,'Height'))
        _Title   := GetProperty ('Win_1' ,'Title')
        _ColorB  := '{'+ ZAPS(m->aColorWinB[1])+','+ ZAPS(m->aColorWinB[2])+','+ ZAPS(m->aColorWinB[3])+'}'
        Form_1.Grid_1.Cell(1,2) := _nRow
        Form_1.Grid_1.Cell(2,2) := _nCol
        Form_1.Grid_1.Cell(3,2) := _nWidth
        Form_1.Grid_1.Cell(4,2) := _nHeight
        Form_1.Grid_1.Cell(5,2) := _Title
        Form_1.Grid_1.Cell(6,2) := _ColorB
    ELSE
   // msginfo(GETCONTROLTYPE(cControl,'Win_1'),ccontrol+" 1258")
        SWITCH GETCONTROLTYPE(cControl,'Win_1')
        CASE 'LABEL'
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Value",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"FontColor",""},{"BackColor",""},{"ToolTip",""}}
            aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _Value         :=  GetProperty ('Win_1' ,cControl ,'Value')
            _FontName      :=  GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            _ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables     := {_nRow,_nCol,_nWidth,_nHeight,_Value,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ColorF,_ColorB,_ToolTip}
            EXIT

        CASE 'TEXT' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Value",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"FontColor",""},{"BackColor",""},{"ToolTip",""},{"CaseConvert",""}}
            aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _Value         := GetProperty ('Win_1' ,cControl ,'Value')
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            _ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            FOR n := 1 TO Len(m->aCaseConvert)
                IF m->aCaseConvert[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            _CaseConvert   := m->aCaseConvert[n,2]
            aVariables     := {_nRow,_nCol,_nWidth,_nHeight,_Value,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ColorF,_ColorB,_ToolTip,_CaseConvert}
            EXIT

        CASE 'NUMTEXT' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Value",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"FontColor",""},{"BackColor",""},{"ToolTip",""},{"InputMask",""}}
            aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _Value         := ZAPS(GetProperty ('Win_1' ,cControl ,'Value'))
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            _ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            FOR n := 1 TO Len(m->aInputMask)
                IF m->aInputMask[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            _InputMask     := m->aInputMask[n,2]
            aVariables  := {_nRow,_nCol,_nWidth,_nHeight,_Value,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ColorF,_ColorB,_ToolTip,_InputMask}
            EXIT

        CASE 'DATEPICK' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Value",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"ToolTip",""}}
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _Value         := DTOC(GetProperty ('Win_1' ,cControl ,'Value'))
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables  := {_nRow,_nCol,_nWidth,_nHeight,_Value,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ToolTip}
            EXIT

        CASE 'CHECKBOX' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Value",""},{"Caption",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"FontColor",""},{"BackColor",""},{"ToolTip",""}}
            aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _Value         := IIF(GetProperty ('Win_1' ,cControl ,'Value') , '.T.' , '.F.' )
            _Caption       := GetProperty ('Win_1' ,cControl ,'Caption')
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            _ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables  := {_nRow,_nCol,_nWidth,_nHeight,_Value,_Caption,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ColorF,_ColorB,_ToolTip}
            EXIT

        CASE 'EDIT' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Value",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"FontColor",""},{"BackColor",""},{"ToolTip",""}}
            aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _Value         := GetProperty ('Win_1' ,cControl ,'Value')
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            _ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables  := {_nRow,_nCol,_nWidth,_nHeight,_Value,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ColorF,_ColorB,_ToolTip}
            EXIT

        CASE 'COMBO' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Items",""},{"Value",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"ToolTip",""}}
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            FOR n := 1 TO Len(M->aItems)
                IF M->aItems[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            _aItems     := M->aItems[n,2]
            _Value         := ZAPS(GetProperty ('Win_1' ,cControl ,'Value'))
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables  := {_nRow,_nCol,_nWidth,_nHeight,_aItems,_Value,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ToolTip}
            EXIT

        CASE 'RADIOGROUP' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Options",""},{"Value",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"FontColor",""},{"BackColor",""},{"ToolTip",""},{"Spacing",""}}
            aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            FOR n := 1 TO Len(M->aItems)
                IF M->aItems[n,1] = cControl
                    EXIT
                Endif
            NEXT n
            _Options       := M->aItems[n,2]
            _Spacing       := M->aItems[n,3]
            _Value         := ZAPS(GetProperty ('Win_1' ,cControl ,'Value'))
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            _ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables  := {_nRow,_nCol,_nWidth,_Options,_Value,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ColorF,_ColorB,_ToolTip,_Spacing}
            EXIT

        CASE 'IMAGE' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"Picture",""},{"ToolTip",""}}
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _Picture       := GetProperty ('Win_1' ,cControl ,'Picture')
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables  := {_nRow,_nCol,_nWidth,_nHeight,_Picture,_ToolTip}
            EXIT

        CASE 'GRID' //
            m->aProperties :={{"Row",""},{"Col",""},{"Width",""},{"Height",""},{"FontName",""},{"FontSize",""},{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"FontColor",""},{"BackColor",""},{"ToolTip",""}}
            aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            _ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            _ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            aVariables  := {_nRow,_nCol,_nWidth,_nHeight,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ColorF,_ColorB,_ToolTip}
            EXIT

        CASE 'BUTTON' //

            m->aProperties :={{"Row",""},{"Col",""},{"Caption",""},{"Action",""},{"Width",""},{"Height",""},{"FontName",""},{"FontSize",""};
            ,{"FontBold",""},{"FontItalic",""},{"FontUnderline",""},{"FontStrikeOut",""},{"ToolTip",""} }

            Form_1.Grid_1.DeleteAllItems
            aeval(m->aProperties,{|x|Form_1.Grid_1.AddItem(x)})
//            Form_1.Grid_1.Refresh

            *aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
            *aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
            _nRow          := ZAPS(GetProperty ('Win_1', cControl ,'Row'))
            _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
            _Caption       := GetProperty ('Win_1' ,cControl ,'Caption')
            _nWidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
            _nHeight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
            _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
            _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
            _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , '.T.' , '.F.')
            _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , '.T.' , '.F.')
            _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , '.T.' , '.F.')
            _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , '.T.' , '.F.')
            *_ColorF        := '{'+ ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])+'}'
            *_ColorB        := '{'+ ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])+'}'
            _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
            _Act           := 'Msgbox ("Action For "+cControl+")"' //
           // _Act           :=  valtype(GetProperty ('Win_1' ,cControl ,'Action')  )
            aVariables  := {_nRow,_nCol,_Caption,_Act,_nWidth,_nHeight,_FontName,_FontSize,_FontBold,_FontItalic,_FontUnderLine,_FontStrikeOut,_ToolTip}

        EndSwitch

        Form_1.Grid_1.DeleteAllItems
        aeval(m->aProperties,{|x|Form_1.Grid_1.AddItem(x)} )
        Form_1.Grid_1.Refresh

        FOR n:= 1 TO LEN(m->aProperties)
            cPropiedad := '_' + m->aProperties[n,1]
            Form_1.Grid_1.Cell(n,2) := aVariables[n]
        NEXT n
    Endif

Return aVariables
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION ChangeBackGround(cWindow,aColor)
*-----------------------------------------------------------------------------*
Local hWnd, oldBrush, Brush
    hWnd := GetFormHandle (cWindow)
    IF IsWindowHandle( hWnd )
       Brush := CreateSolidBrush( aColor[1], aColor[2], aColor[3] )
       oldBrush := SetWindowBrush( hWnd, Brush )
       DeleteObject( oldBrush )
    Endif
    erasewindow(cWindow)
Return NIL
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE SelectControl(cControl)
*-----------------------------------------------------------------------------*
LOCAL nControl
    nControl := ASCAN(m->aControlList, cControl)
    Form_1.Combo_2.VALUE := nControl
    if cControl != "Win_1"
       m->cNameControl := cControl
       Win_1.StatusBar.Item(1) := 'Db "'+DBF()+'" Selected Object:   >> '+m->cNameControl+' <<'
    Endif
Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION GridBackColor()
*-----------------------------------------------------------------------------*
    LOCAL aColors := {{ aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid;
                      , aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid;
                      , aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid;
                      , aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid;
                      , aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid, aColorBackGrid;
                      , aColorBackGrid, aColorBackGrid, aColorBackGrid }}
Return aColors [1] [ This.CellColIndex ]
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE GetControlProperty(cControl)
*-----------------------------------------------------------------------------*
    PUBLIC  _nRow          := ''
    PUBLIC  _nCol          := ''
    PUBLIC  _nwidth        := ''
    PUBLIC  _nheight       := ''
    PUBLIC  aColorB        := {}
    PUBLIC  aColorF        := {}
    PUBLIC  _ColorB        := ''
    PUBLIC  _ColorF        := ''
    PUBLIC  _FontSize      := ''
    PUBLIC  _FontName      := ''
    PUBLIC  _FontBold      := ''
    PUBLIC  _FontItalic    := ''
    PUBLIC  _FontUnderLine := ''
    PUBLIC  _FontStrikeOut := ''
    PUBLIC  _Transparent   := ''
    PUBLIC  _Value         := ''
    PUBLIC  _ToolTip       := ''
    PUBLIC  _aItems        := ''
    PUBLIC  _aOptions      := ''
    PUBLIC  _nSpacing      := ''

    _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
    _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
    _nwidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
    _nheight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
    _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
    _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
    _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , ' BOLD ' , '')
    _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , ' ITALIC ' , '')
    _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , ' UNDERLINE ' , '')
    _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , ' STRIKEOUT ' , '')
    _Value         := GetProperty ('Win_1' ,cControl ,'Value')
    _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')

    aColorB := GetProperty ('Win_1' , cControl ,'BACKCOLOR')
    aColorF := GetProperty ('Win_1' ,cControl ,'FONTCOLOR')
    _ColorB := ZAPS(aColorB[1])+','+ ZAPS(aColorB[2])+','+ ZAPS(aColorB[3])
    _ColorF := ZAPS(aColorF[1])+','+ ZAPS(aColorF[2])+','+ ZAPS(aColorF[3])

Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE GetControlPropertyDate(cControl)
*-----------------------------------------------------------------------------*
    PUBLIC  _nRow   := ''
    PUBLIC  _nCol   := ''
    PUBLIC  _nwidth := ''
    PUBLIC  _nheight:= ''
    PUBLIC  _FontSize      := ''
    PUBLIC  _FontName      := ''
    PUBLIC  _FontBold      := ''
    PUBLIC  _FontItalic    := ''
    PUBLIC  _FontUnderLine := ''
    PUBLIC  _FontStrikeOut := ''
    PUBLIC  _Transparent   := ''
    PUBLIC  _Value         := ''
    PUBLIC  _ToolTip       := ''

    _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
    _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
    _nwidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
    _nheight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
    _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
    _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
    _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , ' BOLD ' , '')
    _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , ' ITALIC ' , '')
    _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , ' UNDERLINE ' , '')
    _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , ' STRIKEOUT ' , '')
    _Value         := GetProperty ('Win_1' ,cControl ,'Value') // CHECAR
    _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE GetControlPropertyImage(cControl)
*-----------------------------------------------------------------------------*
    _Picture  := GetProperty ('Win_1' ,cControl ,'Picture')
    _nRow     := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
    _nCol     := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
    _nWidth   := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
    _nHeight  := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
    _ToolTip  := GetProperty ('Win_1' ,cControl ,'ToolTip')
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE GetControlPropertyButt(cControl)
*-----------------------------------------------------------------------------*
    PUBLIC  _nRow   := ''
    PUBLIC  _nCol   := ''
    PUBLIC  _nwidth := ''
    PUBLIC  _nheight:= ''
    PUBLIC  _FontSize      := ''
    PUBLIC  _FontName      := ''
    PUBLIC  _FontBold      := ''
    PUBLIC  _FontItalic    := ''
    PUBLIC  _FontUnderLine := ''
    PUBLIC  _FontStrikeOut := ''
    PUBLIC  _Transparent   := ''
    PUBLIC  _Value         := ''
    PUBLIC  _ToolTip       := ''
    PUBLIC  _Caption       := ''
    PUBLIC  _Act           := ''

    _nRow          := ZAPS(GetProperty ('Win_1' ,cControl ,'Row'))
    _nCol          := ZAPS(GetProperty ('Win_1' ,cControl ,'Col'))
    _nwidth        := ZAPS(GetProperty ('Win_1' ,cControl ,'Width'))
    _nheight       := ZAPS(GetProperty ('Win_1' ,cControl ,'Height'))
    _FontSize      := ZAPS(GetProperty ('Win_1' ,cControl ,'FontSize'))
    _FontName      := GetProperty ('Win_1' ,cControl ,'FontName')
    _FontBold      := IIF( GetProperty ('Win_1' ,cControl ,'FontBold') , ' BOLD ' , '')
    _FontItalic    := IIF( GetProperty ('Win_1' ,cControl ,'FontItalic') , ' ITALIC ' , '')
    _FontUnderLine := IIF( GetProperty ('Win_1' ,cControl ,'FontUnderLine') , ' UNDERLINE ' , '')
    _FontStrikeOut := IIF( GetProperty ('Win_1' ,cControl ,'FontStrikeOut') , ' STRIKEOUT ' , '')
    _Value         := GetProperty ('Win_1' ,cControl ,'Value') // CHECAR
    _ToolTip       := GetProperty ('Win_1' ,cControl ,'ToolTip')
    _Caption       := GetProperty ('Win_1' ,cControl ,'Caption')
    _Act           := 'Msgbox ("Action For '+cControl+'","Demo")'

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure PrintList(cBase, aNomb, aLong, lEdit)
*-----------------------------------------------------------------------------*
   Local aHdr  := aClone(aNomb)
   Local aLen  := aClone(aLong)
   Local aHdr1 , aTot , aFmt, mlen := 0

   Default lEdit to .f.

   if !used()
      USE &cDBF VIA "DBFCDX" NEW SHARED
   Endif

   if lEdit
      URE(aHdr,alen)
      return
   Endif

   aHdr1 := array(len(aHdr))
   aTot := array(len(aHdr))
   aFmt := array(len(aHdr))
   afill(aHdr1, '')
   afill(aTot, .f.)
   afill(aFmt, '')

   aeval(aLen, {|e,i| aLen[i] := e/8})
   aeval(alen,{|x|mlen += x })

   ( cBase )->( dbgotop() )
   if mlen > 150       // Require sheet rotation
      DO REPORT ;
         TITLE  "Print List"      ;
         HEADERS  aHdr1, aHdr     ;
         FIELDS   aHdr            ;
         WIDTHS   aLen            ;
         TOTALS   aTot            ;
         NFORMATS aFmt            ;
         WORKAREA &cBase          ;
         LMARGIN  5               ;
         TMARGIN  3               ;
         PAPERSIZE DMPAPER_A4     ;
         PREVIEW  ;
         LANDSCAPE
   Else
      DO REPORT ;
         TITLE  "Print List"      ;
         HEADERS  aHdr1, aHdr     ;
         FIELDS   aHdr            ;
         WIDTHS   aLen            ;
         TOTALS   aTot            ;
         NFORMATS aFmt            ;
         WORKAREA &cBase          ;
         LMARGIN  5               ;
         TMARGIN  3               ;
         PAPERSIZE DMPAPER_A4     ;
         PREVIEW
   Endif
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE CreatePRG()
*-----------------------------------------------------------------------------*
    LOCAL cSep, cControl, n
    PUBLIC aControlsQ , cControlsQ , cHeadClick
    PUBLIC cAlias, cShortAlias, cFile
    PUBLIC cFields, cWidths, cJustify
    PUBLIC anCamposM, nDatePicker, acCamposM
    PUBLIC aCamposPos, aControlPos, aControlsPos // Para Form Posicion
    PRIVATE nLongDBF, nLongField, nLongControl, nLongControlQ, nLong:=0

    m->cAlias  := '' ; m->cShortAlias := '' ; m->cFile    := ''
    m->cFields := '' ; m->cWidths     := '' ; m->cJustify := ''
    m->anCamposM  :={} ; m->nDatePicker := 0 ; m->acCamposM := ''
    m->aCamposPos :={} ; m->aControlPos := {}; m->aControlsPos := {}

    IF Form_1.Combo_2.ItemCount = 0
       msgexclamation("Please select a dbf before...")
       Return
    Endif

    nLongDBF := Len(cDBF)
    nLongField := 0
    nLongControl := 0

    aCamposPos := {}
    FOR n:= 1 To Len(Field_Name)
        AAdd(aCamposPos,{Field_Name[n],Field_Type[n],Str(Field_Len[n],2,0),Str(Field_Dec[n],2,0)})
        IIF(Len(Field_Name[n])> nLongField , nLongField := Len(Field_Name[n]) ,)
    NEXT n

    aControlsOrder := m->aControlList
    HB_ADel(aControlsOrder,1,.T.)
    lImage := .F.
    FOR n := 1 TO Len(aControlsOrder)
        cControl := aControlsOrder[n]
        IF GETCONTROLTYPE(cControl,'Win_1') = 'GRID' .OR. GETCONTROLTYPE(cControl,'Win_1') = 'LABEL'
        ELSEIF GETCONTROLTYPE(cControl,'Win_1') = 'IMAGE'
            lImage := .T.
        ELSE
            AAdd(m->aControlPos,{aControlsOrder[n],GETCONTROLTYPE(cControl,'Win_1')})
        Endif
    NEXT n

*------------------------------------------------------------------------------*
    Load Window Posicion
    Posicion.Center
    Posicion.Activate
*------------------------------------------------------------------------------*

    m->cAlias := Upper(SubStr(cDBF,1,1)) + Alltrim(Lower(SubStr(cDBF,2)))
    cShortAlias := SubStr(m->cAlias,1,4)
    cFile := cFilePath(GetExeFileName())+ "\" + m->cAlias + '.prg'

    IF File(cFile)
        DELETE FILE &(cFile)
    Endif

    cSep := ', '
    FOR n = 1 TO nFields
        IIF(n = nFields , cSep := '', )
        cFields = cFields + '"' + Field_Name[n] + '"' + cSep
        m->cWidths = m->cWidths + ZAPS(Field_Len[n]*10+10) + cSep
        IF Field_Type[n] = 'N'
            m->cJustify := m->cJustify + 'BROWSE_JTFY_RIGHT' + cSep
        ELSEIF Field_Type[n] = 'D' .OR. Field_Type[n] = 'L'
            m->cJustify := m->cJustify + 'BROWSE_JTFY_CENTER' + cSep
        ELSE
            m->cJustify := m->cJustify + ' ' + cSep
        Endif
    NEXT n

    cSep := ', '
    m->aControles  := {}
    m->aControlsQ  := {}
    m->cControlsQ  := ""
    nTextBox    := 1
    nDatePicker := 1
    nCheckBox   := 1
    nEditBox    := 1
    m->nComboBox   := 1
    m->nRadioGroup := 1
    m->cHeadClick  := ""

    FOR n:=1 To nFields //Len(aControlsOrder)
        IIF(n = nFields , cSep := '', )
        SWITCH GETCONTROLTYPE(aControlsOrder[n],'Win_1')
        CASE 'TEXT'
            AADD(m->aControlsQ,aControlsOrder[n])
            m->cControlsQ := m->cControlsQ + "'"+ aControlsOrder[n] + "'" + cSep
            nTextBox++
            EXIT

        CASE 'NUMTEXT'
            AADD(m->aControlsQ,aControlsOrder[n])
            m->cControlsQ := m->cControlsQ + "'"+ aControlsOrder[n] + "'" + cSep
            nTextBox++
            EXIT

        CASE 'RADIOGROUP'
            cControl := 'TextRadio_' + ZAPS(m->nRadioGroup)
            AADD(m->aControlsQ,cControl)
            m->cControlsQ := m->cControlsQ + "'"+ cControl + "'" + cSep
            m->nRadioGroup++
            EXIT

        CASE 'COMBO'
            cControl := 'TextCombo_' + ZAPS(m->nComboBox)
            AADD(m->aControlsQ,cControl)
            m->cControlsQ := m->cControlsQ + "'"+ cControl + "'" + cSep
            m->nComboBox++
            EXIT

        CASE 'DATEPICK'
            cControl := 'TextDate_' + ZAPS(nDatePicker)
            AADD(m->aControlsQ,cControl)
            m->cControlsQ := m->cControlsQ + "'"+ cControl + "'" + cSep
            nDatePicker++
            EXIT

        CASE 'CHECKBOX'
            AADD(m->aControlsQ,aControlsOrder[n])
            m->cControlsQ := m->cControlsQ + "'"+ aControlsOrder[n] + "'" + cSep
            nCheckBox++
            EXIT

        CASE 'EDIT'
            AADD(m->aControlsQ,aControlsOrder[n])
            m->cControlsQ := m->cControlsQ + "'"+ aControlsOrder[n] + "'" + cSep
            AADD(m->anCamposM,n)
            IIF( nEditBox = 1 , m->acCamposM := m->acCamposM + ZAPS(n) , m->acCamposM := m->acCamposM + ", " + ZAPS(n) )
            nEditBox++
            EXIT

        EndSwitch
        m->cHeadClick := m->cHeadClick + "{|| Head_" + cShortAlias + "(" + ZAPS(n) + ")}" + cSep
    NEXT n

    nTextBox --
    nDatePicker --
    nCheckBox --
    nEditBox --
    m->nComboBox --
    m->nRadioGroup --
    m->nLongControlQ := 0

    FOR n:= 1 To Len(aControlsOrder)
        IIF(Len(aControlsOrder[n])> nLongControl , nLongControl := Len(aControlsOrder[n]) ,)
    NEXT
    FOR n:= 1 TO Len(m->aControlsQ)
        IIF(Len(m->aControlsQ[n])> m->nLongControlQ , m->nLongControlQ := Len(m->aControlsQ[n]) ,)
    NEXT

    BuildFile()

Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE GuardarCtrlPos()
*-----------------------------------------------------------------------------*
LOCAL n
    aControlsOrder := {}
    FOR n := 1 TO Posicion.Grid_2.ItemCount
        AADD(aControlsOrder,Posicion.Grid_2.Cell(n,1) )
    NEXT n
    Posicion.Release
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE BuildFile()
*-----------------------------------------------------------------------------*
    LOCAL nPos, nLargo
    LOCAL cControl, cControlSF, cSep ,aSrc := {}
    LOCAL m ,n ,i ,j ,k , _caCombo, _InputMask , _CaseConvert
    LOCAL aVal, aControlsWin_1 := {}, cFileBat, cFileRc
    LOCAL W_Name := '"Win_'+m->cShortAlias+'"'
    LOCAL cPos := cFilePath(GetExeFileName())+"\"

    IF Field_Type[1] = "N"
        cControlSF := aControlsOrder[2]
    ELSE
        cControlSF := aControlsOrder[1]
    Endif

    aVal := GetAllControlsByForm('Win_1')

    FOR i=1 To Len(aVal)
        AAdd(aControlsWin_1,aVal[i])
    Next

    cFileBat := cPos + "0C_"+m->cAlias + '.bat'

    IF File(cFileBat)
        DELETE FILE &(cFileBat)
    Endif

    aadd(aSrc,"call c:\Minigui\batch\compile.bat %1 " + m->cAlias +' /NL %2 %3 %4 %5 %6 %7 %8 %9')
    aadd(aSrc,"call c:\Minigui\batch\compile.bat %1 Hmg_Zebra  /NL %2 %3 %4 %5 %6 %7 %8 %9")
    aadd(aSrc,"call c:\Minigui\batch\compile.bat %1 " + m->cAlias+' /LO /B Hmg_Zebra /lg winreport /l calldll /l hbhpdf /l libhpdf /l png /l hbzlib /l hbzebra /l BosTaurus')
    aadd(aSrc,"call c:\Minigui\batch\compile.bat %1 " + m->cAlias +' /DO %2 %3 %4 %5 %6 %7 %8 %9')
    aadd(aSrc,"call c:\Minigui\batch\compile.bat %1 Hmg_Zebra  /DO %2 %3 %4 %5 %6 %7 %8 %9")

    WriteFile(cFileBat,aSrc )
    asize (asrc, 0)

    cFileRc := cPos + m->cAlias + '.Rc'

    IF File(cFileRc)
        DELETE FILE &(cFileRc)
    Endif

# ifndef _DLLRES_
    aadd(aSrc,'AAAAZZZZ    ICON    "Res\QbG.ico" ' )
    aadd(aSrc,'1Register   ICON    "Res\QbG.ico" ' )
    aadd(aSrc,'Tools       BITMAP  "Res\Tools.bmp" ' )
    aadd(aSrc,'OPTIONS     BITMAP  "Res\Options.bmp" ' )
    aadd(aSrc,'CANCEL      BITMAP  "Res\cancel.bmp" ' )
    aadd(aSrc,'EDIT_CLOSE  BITMAP  "Res\EDIT_CLOSE.bmp" ' )
    aadd(aSrc,'EDIT_DELETE BITMAP  "Res\EDIT_DELETE.bmp" ' )
    aadd(aSrc,'EDIT_EDIT   BITMAP  "Res\EDIT_EDIT.bmp" ' )
    aadd(aSrc,'EDIT_FIND   BITMAP  "Res\EDIT_FIND.bmp" ' )
    aadd(aSrc,'EDIT_NEW    BITMAP  "Res\EDIT_NEW.bmp" ' )
    aadd(aSrc,'EDIT_PRINT  BITMAP  "Res\EDIT_PRINT.bmp" ' )
    aadd(aSrc,'GO_FIRST    BITMAP  "Res\GO_FIRST.bmp" ' )
    aadd(aSrc,'GO_LAST     BITMAP  "Res\GO_LAST.bmp" ' )
    aadd(aSrc,'GO_NEXT     BITMAP  "Res\GO_NEXT.bmp" ' )
    aadd(aSrc,'GO_PREV     BITMAP  "Res\GO_PREV.bmp" ' )
    aadd(aSrc,'OK          BITMAP  "Res\OK.bmp" ' )
    aadd(aSrc,'RAImBOW     BITMAP  "RES\RAImBOW.bmp" ' )
    aadd(aSrc,'REINDEX     BITMAP  "Res\REINDEX.bmp" ' )
    aadd(aSrc,'TRASH       BITMAP  "Res\trash.bmp" ' )
    aadd(aSrc,'TN          BITMAP  "Res\tn.bmp" ' )
    aadd(aSrc,'TC          BITMAP  "Res\tc.bmp" ' )
    /*
    aadd(aSrc,'DATEPICKER  BITMAP  "Res\DATEPICKER.bmp" ' )
    aadd(aSrc,'CHECKBOX    BITMAP  "Res\CHECKBOX.bmp" ' )
    aadd(aSrc,'RADIO       BITMAP  "Res\RADIO.bmp" ' )
    aadd(aSrc,'COMBO       BITMAP  "Res\Combo.bmp" ' )
    aadd(aSrc,'LABEL       BITMAP  "Res\LABEL.bmp" ' )
    aadd(aSrc,'BUTTON      BITMAP  "Res\Button.bmp" ' )
    */
# EndIf
   aadd(aSrc,'')
   aadd(aSrc,'1 VERSIONINFO')
   aadd(aSrc,'FILEVERSION 1,6,0,0')
   aadd(aSrc,'PRODUCTVERSION 1,6,0,0')
   aadd(aSrc,'FILEOS 0x4')
   aadd(aSrc,'FILETYPE 0x1')
   aadd(aSrc,'{')
   aadd(aSrc,'BLOCK "StringFileInfo"')
   aadd(aSrc,'{')
   aadd(aSrc,'BLOCK "040904b0"')
   aadd(aSrc,'      {')
   aadd(aSrc,'       VALUE "FileDescription", "'+ m->cAlias +'\000"')
   aadd(aSrc,'       VALUE "FileVersion", "1.6.0.0"')
   aadd(aSrc,'       VALUE "InternalName", "+ m->cAlias +"')
   aadd(aSrc,'       VALUE "LegalCopyright", "Pierpaolo Martinello\000"')
   aadd(aSrc,'       VALUE "LegalTrademarks", "Harbour"')
   aadd(aSrc,'       VALUE "OriginalFilename", "'+ m->cAlias +'.Exe\000"')
   aadd(aSrc,'       VALUE "CompanyName", "\000"')
   aadd(aSrc,'       VALUE "ProductName", "MiniGUI Utility"')
   aadd(aSrc,'       VALUE "ProductVersion", "1.6.0.0"')
   aadd(aSrc,'       VALUE "Comments", "Created by Pierpaolo Martinello && Grigory Filatov \000" ')
   aadd(aSrc,'      }')
   aadd(aSrc,'}')
   aadd(aSrc,'')
   aadd(aSrc,'BLOCK "VarFileInfo"')
   aadd(aSrc,'{')
   aadd(aSrc,'      VALUE "Translation", 0x0409 0x04B0')
   aadd(aSrc,'}')
   aadd(aSrc,'}')
   WriteFile(cFileRc ,aSrc )

   asize (asrc, 0)

   aadd(aSrc,"#include <minigui.ch>" )
   aadd(aSrc,"")
   aadd(aSrc,"#define NTrim( n ) LTRIM( STR( n,20, IF( n == INT( n ), 0, set(_SET_DECIMALS) ) ))" )
   aadd(aSrc,"#TRANSLATE ZAPS(<X>) => ALLTRIM(STR(<X>))" )
   aadd(aSrc,"")
   aadd(aSrc,"MEMVAR New_rec, _qry_exp, amidb,id,data,ora,targa,ddt_desc,c_pos,sfondo " )
   aadd(aSrc,"MEMVAR  report,responsab, note,n ,cvalor, acontrolsq,acampos,ancamposm" )
   aadd(aSrc,"")
   aadd(aSrc,"Set procedure to tReport")
   aadd(aSrc,'/*' )
   aadd(aSrc,"*/" )
   aadd(aSrc,"*--------------------------------------------------------*" )
   aadd(aSrc,"PROCEDURE MAIN " )
   aadd(aSrc,"*--------------------------------------------------------*")
   aadd(aSrc,"   LOCAL nCamp, aEst, aNomb, aJust, aLong, aFtype, i" )
   aadd(aSrc,[   PRIVATE c_pos := cFilePath(GetExeFileName())+"\"] )
   aadd(aSrc,"   PRIVATE New_rec := .F. , _qry_exp := '' , anCamposM := {" + m->acCamposM + "}" )
   aadd(aSrc,"   PRIVATE aCampos := {" + cFields + "}" )
   aadd(aSrc,"   PRIVATE aControlsQ:={"+ m->cControlsQ +"}" )

   FOR m := 1 TO Len(M->aItems)
       aadd(aSrc,'   PRIVATE ' + M->aItems[m,4] + ' := ' + M->aItems[m,2] )
   NEXT m

   aadd(aSrc,"   PRIVATE aMiDB, sfondo := {0,255,255}" )
   aadd(aSrc,"" )

   aadd(aSrc,"   If !File( c_pos+'QbGen.Dll' )")
   aadd(aSrc,'      MsgStop("There is no resource file for the program!" + CRLF + c_pos+"QbGen.Dll"'+' )')
   aadd(aSrc,"      Quit")
   aadd(aSrc,"    Endif")
   aadd(aSrc,"")
   aadd(aSrc,"   SET NAVIGATION EXTENDED" )
   aadd(aSrc,"   SET CENTURY ON" )
//    aadd(aSrc,"   SET AUTOPEN OFF" )     && If you need it, take your comment to this line
   aadd(aSrc,"// SET CODEPAGE TO  (your choice)" )
   aadd(aSrc,"   SET RESOURCES TO ( c_pos+'QbGen.Dll' )")
   aadd(aSrc,"   SET DATE ITALIAN" )
   aadd(aSrc,"   SET DELETED ON" )
   aadd(aSrc,"   SET TOOLTIPSTYLE BALLOON" )
   aadd(aSrc,"   SET DATE FORMAT 'dd/mm/yyyy'" )
   aadd(aSrc,"" )
   aadd(aSrc,"   REQUEST DBFCDX" )
   aadd(aSrc,"   RDDSETDEFAULT('DBFCDX')" )
   aadd(aSrc,"")
   aadd(aSrc,[   SET PATH TO &C_Pos] )
   aadd(aSrc,"" )
   aadd(aSrc,"   OpenDB" + cShortAlias + "()")
   aadd(aSrc,"*--------------------------------------------------------*")
   aadd(aSrc,"/* Prepare the fields for the Print section) */")
   aadd(aSrc,"")
   aadd(aSrc,"   nCamp := Fcount()")
   aadd(aSrc,"   aEst  := DBstruct()")
   aadd(aSrc,"   aNomb := {'iif(deleted(),0,1)'} ; aJust := {0} ; aLong := {0} ; aFtype := {}" )
   aadd(aSrc,"   For i := 1 to nCamp")
   aadd(aSrc,"       aadd(aNomb,aEst[i,1])")
   aadd(aSrc,"       aadd(aFtype, aEst[i,2])")
   aadd(aSrc,"       aadd(aJust,LtoN(aEst[i,2]=='N'))")
   aadd(aSrc,"       aadd(aLong,Max(100,Min(160,aEst[i,3]*14)))" )
   aadd(aSrc,"   Next")
   aadd(aSrc,"" )
   aadd(aSrc,"   DBSELECTAREA('" + m->cAlias + "')" )
   aadd(aSrc,"   DBSETORDER(1)")
   aadd(aSrc,"" )
   aadd(aSrc,'   IF File (c_pos+"'+ m->cAlias+'.Ini")')
   aadd(aSrc,'      Begin ini file (c_pos+"'+ m->cAlias +'.Ini")')
   aadd(aSrc,'            Get Sfondo  Section "COLORS" ENTRY "Sfondo" default sfondo')
   aadd(aSrc,"      End Ini")
   aadd(aSrc,"   Endif")
   aadd(aSrc,"" )
   aadd(aSrc,"   DEFINE WINDOW Win_" + cShortAlias + " ;" )
   aadd(aSrc,"      AT 0,0 ;" )

   _nwidth := ZAPS(GetProperty ('Win_1' ,'WIDTH'))
   _nheight:= ZAPS(GetProperty ('Win_1' ,'HEIGHT'))
   _ColorB := ZAPS(m->aColorWinB[1])+','+ ZAPS(m->aColorWinB[2])+','+ ZAPS(m->aColorWinB[3])

   aadd(aSrc,"      WIDTH "+ _nwidth + " ;" )
   aadd(aSrc,"      HEIGHT "+ _nheight + " ;")
   aadd(aSrc,'      BACKCOLOR sfondo ; ')
   aadd(aSrc,"      TITLE 'Table " + m->cAlias + "' ;")
   aadd(aSrc,'      ICON  "lRegister" ;' +'  //'+ m->cAlias + '.ICO ;' )

   IF lImage
      GetControlPropertyImage('Image_1')
      aadd(aSrc, "      ON INIT ( Win_" + cShortAlias + ".Image_1.picture := '"+ _Picture +"' ,Esc_Quit(), Win_" + cShortAlias + ".Image_1.Refresh) ; " )
   ELSE
      aadd(aSrc, "      ON INIT Esc_Quit() ; ")
   Endif

   aadd(aSrc, "      MAIN ")
   aadd(aSrc, "      ON KEY ESCAPE ACTION Win_" + cShortAlias + ".Release")
   aadd(aSrc, "")
   aadd(aSrc, "      DEFINE STATUSBAR FONT 'Arial' SIZE 12")
   aadd(aSrc, "             STATUSITEM 'Table " + m->cAlias + "'")
   aadd(aSrc, "             KEYBOARD WIDTH 80")
   aadd(aSrc, "             DATE WIDTH 100")
   aadd(aSrc, "             CLOCK WIDTH 100")
   aadd(aSrc, "      END STATUSBAR")
   aadd(aSrc, "")
   aadd(aSrc, "      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 60,40 FLAT BORDER")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON FIRST ;")
   aadd(aSrc, "             CAPTION '&First' ;")
   aadd(aSrc, "             PICTURE 'go_first' ;")
   aadd(aSrc, "             ACTION( dbGotop(), Win_" + cShortAlias + ".Browse_1.Value := RecNo() )" )
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON PREV ;")
   aadd(aSrc, "             CAPTION '&Prev' ;")
   aadd(aSrc, "             PICTURE 'go_prev' ;")
   aadd(aSrc, "             ACTION( dbSkip( -1 ), Win_" + cShortAlias + ".Browse_1.Value := RecNo() ) AUTOSIZE" )
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON NEXT ;")
   aadd(aSrc, "             CAPTION '&Next' ;")
   aadd(aSrc, "             PICTURE 'go_next' ;")
   aadd(aSrc, "             ACTION( dbSkip(), if ( Eof(), dbGobottom(), NIL ), Win_" + cShortAlias + ".Browse_1.Value := RecNo() ) AUTOSIZE")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON LAST ;")
   aadd(aSrc, "             CAPTION '&Last' ;")
   aadd(aSrc, "             PICTURE 'go_last' ;")
   aadd(aSrc, "             ACTION( dbGoBottom(), Win_" + cShortAlias + ".Browse_1.Value := RecNo() )   SEPARATOR ")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON NEW ;")
   aadd(aSrc, "             CAPTION '&New' ;")
   aadd(aSrc, "             PICTURE 'edit_new' ;")
   aadd(aSrc, "             ACTION ( New_rec := .T., NewRecord_" + cShortAlias + "() )")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON EDIT ;")
   aadd(aSrc, "             CAPTION '&Edit' ;")
   aadd(aSrc, "             PICTURE 'edit_edit' ;")
   aadd(aSrc, "             ACTION IIF ( RecordStatus_" + cShortAlias + "(), EnableField_" + cShortAlias + "(), NIL )")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON SAVE ;")
   aadd(aSrc, "             CAPTION '&Save' ;")
   aadd(aSrc, "             PICTURE 'ok' ;")
   aadd(aSrc, "             ACTION SaveRecord_" + cShortAlias + "()")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON CANCEL ;")
   aadd(aSrc, "             CAPTION '&Cancel' ;")
   aadd(aSrc, "             PICTURE 'cancel' ;")
   aadd(aSrc, "             ACTION CancelEDIT_" + cShortAlias + "()")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON DELETE ;")
   aadd(aSrc, "             CAPTION '&Delete' ;")
   aadd(aSrc, "             PICTURE 'edit_delete' ;")
   aadd(aSrc, "             ACTION IIF ( RecordStatus_" + cShortAlias + "(), DeleteRecord_" + cShortAlias + "(), NIL ) SEPARATOR")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON FIND ;")
   aadd(aSrc, "             CAPTION 'F&ind' ;")
   aadd(aSrc, "             PICTURE 'edit_find' ;")
   aadd(aSrc, "             ACTION FIND_" + cShortAlias + "()")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON QUERY  ;")
   aadd(aSrc, "             CAPTION '&Query' ;")
   aadd(aSrc, "             PICTURE 'edit_find' ;")
   aadd(aSrc, "             ACTION QueryRecord_" + cShortAlias + "()")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON Print_1 ;")
   aadd(aSrc, "             CAPTION 'P&rint' ;")
   aadd(aSrc, "             PICTURE 'edit_print' ;")
   aadd(aSrc, "             ACTION PrintData_" + cShortAlias +  "(Alias(), aNomb, aLong) SEPARATOR DROPDOWN")
   aadd(aSrc, "")
   aadd(aSrc, "             DEFINE DROPDOWN MENU BUTTON Print_1")
   aadd(aSrc, "                    ITEM 'Register'    ACTION MsgBox('Print Register')")
   aadd(aSrc, "                    ITEM 'Catalog'     ACTION MsgBox('Print Catalog') " )
   aadd(aSrc, "                    ITEM 'For selected fields' ACTION MsgBox('Print for selected fields')")
   aadd(aSrc, "             END MENU")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON Tools ;")
   aadd(aSrc, "             CAPTION '&Tools' ;")
   aadd(aSrc, "             PICTURE 'Options' ;")
   aadd(aSrc, "             ACTION Nil AUTOSIZE SEPARATOR DROPDOWN")
   aadd(aSrc, "")
   aadd(aSrc, "             DEFINE DROPDOWN MENU BUTTON TOOLS ")
   aadd(aSrc, '                    ITEM "Background color" Action Save_color() image "Raimbow"')
   aadd(aSrc, '                    ITEM "User Report Editor" ACTION PrintList(Alias(), aNomb, aLong, .T.) Image "EDIT_PRINT" ' )
   aadd(aSrc, "             END MENU")
   aadd(aSrc, "")
   aadd(aSrc, "          BUTTON EXIT ;")
   aadd(aSrc, "             CAPTION 'E&xit' ;")
   aadd(aSrc, "             PICTURE 'edit_close' ;")
   aadd(aSrc, "             ACTION Win_" + cShortAlias + ".Release")
   aadd(aSrc, "      END TOOLBAR")
   aadd(aSrc, "")
   aadd(aSrc, "      PaintDisplay_" + cShortAlias + "()")
   aadd(aSrc,"" )
    IF lImage
       GetControlPropertyImage('Image_1')
       aadd(aSrc, "      @ " + _nRow + ","+ _nCol + " IMAGE Image_1 PICTURE '"+ _Picture + "'" + ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight + ' STRETCH TRANSPARENT' + " ToolTip '" + _ToolTip + "'")
   Endif
   aadd(aSrc,"" )
   GetControlProperty('Grid_1')
   aadd(aSrc, "      @ "+ _nRow + ","+ _nCol + " BROWSE Browse_1 ;")
   aadd(aSrc, "              WIDTH "+ _nwidth + " ;")
   aadd(aSrc, "              HEIGHT "+ _nheight + " ;")
   aadd(aSrc, "              FONT '" + _FontName + "' ; ")
   aadd(aSrc, "              SIZE " + _FontSize + _FontBold +  _FontItalic + _FontUnderLine + _FontStrikeOut + " ;")
   aadd(aSrc, '              TOOLTIP "' +_tooltip +'" ;' )
   aadd(aSrc, "              HEADERS { " + cFields + " } ;")

   cSep := ', '
   m->cWidths := ''
   For n:= 1 TO nFields
        IIF( n = nFields , cSep := '' , )
        m->cWidths := m->cWidths + ZAPS( Win_1.Grid_1.ColumnWIDTH(n) )+ cSep
    Next

   aadd(aSrc, "              WIDTHS { " + m->cWidths + "} ;")
   aadd(aSrc, '              BACKCOLOR Sfondo ; ')
   aadd(aSrc, '              FONTCOLOR { ' + _ColorF + ' } ; ')
   aadd(aSrc, "              WORKAREA " + m->cAlias + " ;")
   aadd(aSrc, "              FIELDS { " + cFields + "} ;")
   aadd(aSrc, "              JUSTIFY { " + m->cJustify + "  } ;")
   aadd(aSrc, "              ON CHANGE LoadData_" + cShortAlias + "() ;")
   aadd(aSrc, "              ON HEADCLICK { " + m->cHeadClick + "} ;")
   aadd(aSrc, "              ON DBLCLICK ( EnableField_" + cShortAlias + "(), IIF ( ! RecordStatus_" + cShortAlias + "(), DisableField_" + cShortAlias + "(), NIL ) ) ;")
   aadd(aSrc, "              PAINTDOUBLEBUFFER")
   aadd(aSrc, "")
   aadd(aSrc, "    END WINDOW")
   aadd(aSrc, "")
   aadd(aSrc, "   DisableField_" + cShortAlias + "()")

    FOR n:= 1 TO nDatePicker
        aadd(aSrc, "   Win_" + cShortAlias + ".TextDate_" + ZAPS(n)+ ".Hide")
    NEXT

    FOR n:= 1 TO m->nComboBox
        aadd(aSrc, "   Win_" + cShortAlias + ".TextCombo_" + ZAPS(n)+ ".Hide")
    NEXT

    FOR n:= 1 TO m->nRadioGroup
        aadd(aSrc, "   Win_" + cShortAlias + ".TextRadio_" + ZAPS(n)+ ".Hide")
    NEXT

   aadd(aSrc, "")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Value := " +m->cAlias+ "->( RecNo() )")
   aadd(aSrc, "   LoadData_" + cShortAlias + "()")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.SetFocus")
   aadd(aSrc, "")
   aadd(aSrc, "   CENTER WINDOW Win_" + cShortAlias + "")
   aadd(aSrc, "   ACTIVATE WINDOW Win_" + cShortAlias + "")
   aadd(aSrc, "")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE OpenDB" + cShortAlias + "()")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "LOCAL nArea := SELECT('" + m->cAlias + "')")

   aadd(aSrc, "        aMiDB := {;")

    cSep := ",;"
    FOR n:=1 To nFields
        IIF( n = nFields , cSep := "}",)
        aadd(aSrc, "                 " + "{'" + SpaceFix(Field_Name[n] + "',",12) + "'" +Field_Type[n]+ "' , " + StrZero(Field_Len[n],3) + " , "+StrZero(Field_Dec[n],1) + "}" + cSep)
    NEXT n

   aadd(aSrc, "")
   aadd(aSrc, "   IF nArea == 0")
   aadd(aSrc, "      IF ! FILE('" + m->cAlias + ".DBF' )")
   aadd(aSrc, "         DBCREATE('" + m->cAlias + ".DBF', aMiDB )")
   aadd(aSrc, "      Endif")
   aadd(aSrc, "   Endif")
   aadd(aSrc, "")
   aadd(aSrc, "   IF ! FILE( '" + m->cAlias + ".CDX' )")
   aadd(aSrc, "      USE " + m->cAlias + " ALIAS " + m->cAlias + " EXCLUSIVE")
    FOR n:=1 To nFields
        IF Field_Type[n] = "C"
            aadd(aSrc, "      INDEX ON " + SpaceFix( "_field->"+Field_Name[n],25) + "TAG I"+Field_Name[n])
        ELSEIF Field_Type[n] = "N"
            aadd(aSrc, "      INDEX ON " + SpaceFix( "STR(_field->"+Field_Name[n] + "," + StrZero(Field_Len[n],3)+")",25) + "TAG I"+Field_Name[n])
        ELSEIF Field_Type[n] = "D"
            aadd(aSrc, "      INDEX ON " + SpaceFix( "DTOC(_field->"+Field_Name[n]+")",25) + "TAG I"+Field_Name[n])
        ELSEIF Field_Type[n] = "L"
            aadd(aSrc, "      INDEX ON " + SpaceFix("field->"+Field_Name[n],25) + "TAG I"+Field_Name[n])
*        ELSEIF Field_Type[n] = "M"
*             nLine--
        Endif

    NEXT n
   aadd(aSrc, "      DBCLOSEAREA()")
   aadd(aSrc, "   Endif")
   aadd(aSrc, "")
   aadd(aSrc, "   USE " + m->cAlias + " ALIAS " + m->cAlias + " NEW SHARED")
   aadd(aSrc, "")

    FOR n:=1 To nFields
        IF Field_Type[n] = "M"
        ELSE
            aadd(aSrc, "   " + m->cAlias + "->(ORDSETFOCUS('I" + Field_Name[n] + "'))")
        Endif
    NEXT n

   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE DisableField_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Enabled     := .T.")
   aadd(aSrc, "")

    FOR n:=1 To nFields
        aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Enabled"),17+nLongControl+1) + ":= .F.")
    NEXT n
   aadd(aSrc, "")
   aadd(aSrc, "   EnableToolbar_" + cShortAlias + "()")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.SetFocus")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE EnableField_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   _DefineHotKey("+ W_name + ",0,27,{|| iif(GetProperty ( "+W_Name+', "Toolbar_1" , "SAVE" , "Enabled" ), Canceledit_'+cShortAlias+'(),NIL)} )')
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Enabled     := .F.")

    nLong := 17+nLongControl+1
    FOR n:=1 To nFields
        aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Enabled"),nLong) + ":= .T.")
    NEXT n

   aadd(aSrc, "")
   aadd(aSrc, "   Win_" + cShortAlias + ".SAVE.Enabled         := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".CANCEL.Enabled       := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".QUERY.Enabled        := .F.")

   aadd(aSrc, "   DisableToolbar_" + cShortAlias + "()")
   aadd(aSrc, "   Win_" + cShortAlias + "." + cControlSF + ".SetFocus")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE DisableToolbar_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.FIRST.Enabled  := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.PREV.Enabled   := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.NEXT.Enabled   := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.LAST.Enabled   := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.FIND.Enabled   := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.NEW.Enabled    := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.EDIT.Enabled   := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.DELETE.Enabled := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.Print_1.Enabled := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.TOOLS.Enabled   := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.EXIT.Enabled   := .F.")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE EnableToolbar_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.FIRST.Enabled  := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.PREV.Enabled   := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.NEXT.Enabled   := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.LAST.Enabled   := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.FIND.Enabled   := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.NEW.Enabled    := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.EDIT.Enabled   := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.DELETE.Enabled := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.Print_1.Enabled := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.TOOLS.Enabled  := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.EXIT.Enabled   := .T.")
   aadd(aSrc, "")

   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.SAVE.Enabled   := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.CANCEL.Enabled := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".Toolbar_1.QUERY.Enabled  := .F.")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "FUNCTION RecordStatus_" + cShortAlias + "()")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   LOCAL RetVal")
   aadd(aSrc, "   " +m->cAlias+ "->( dbGoTo ( Win_" + cShortAlias + ".Browse_1.Value ) )")
   aadd(aSrc, "   IF " +m->cAlias+ "->(RLock())")
   aadd(aSrc, "      RetVal := .T.")
   aadd(aSrc, "   ELSE")
   aadd(aSrc, "      MsgExclamation ('Record is LOCKED, try again later')")
   aadd(aSrc, "      RetVal := .F.")
   aadd(aSrc, "   Endif")
   aadd(aSrc, "   Win_"+cShortAlias+".StatusBar.Item(1) := 'Edit Table "+m->cAlias+".'")
   aadd(aSrc, "Return RetVal")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE LoadData_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   " +m->cAlias+ "->( dbGoTo ( Win_" + cShortAlias + ".Browse_1.Value ) )")
   aadd(aSrc, "")

   nLong := 15+nLongControl+1
   FOR n = 1 To nFields

        IF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'COMBO'
            IF Field_Type[n] = 'C'
                FOR m := 1 TO Len(M->aItems)
                    IF M->aItems[m,1] = aControlsOrder[n]
                        EXIT
                    Endif
                NEXT m
                _caCombo := M->aItems[m,4]
                aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),nLong) + ":= AScan(" + _caCombo + ','+m->cAlias+ "->" + Field_Name[n] + ')')
            ELSE
                aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),nLong) + ":= " +m->cAlias+ "->" + Field_Name[n])
            Endif
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'RADIOGROUP'
            IF Field_Type[n] = 'C'
                FOR m := 1 TO Len(M->aItems)
                    IF M->aItems[m,1] = aControlsOrder[n]
                        EXIT
                    Endif
                NEXT m
                _caCombo := M->aItems[m,4]
                aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),nLong) + ":= AScan("+ _caCombo + ','+m->cAlias+ "->" + Field_Name[n] + ')')
            ELSE
                aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),nLong) + ":= " +m->cAlias+ "->" + Field_Name[n])
            Endif
        ELSE
            aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),nLong) + ":= " +m->cAlias+ "->" + Field_Name[n])
        Endif
   NEXT n

   IF lImage
      aadd(aSrc, "   Foto" + cShortAlias + "()")
   Endif

   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE CancelEDIT_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")

    i := 1
    j := 1
    k := 1

    FOR n:=1 To nFields //Len(aControlsOrder)
        IF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'RADIOGROUP'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Show")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextRadio_" + ZAPS(i)+ ".Hide")
            i++
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'COMBO'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Show")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextCombo_" + ZAPS(j)+ ".Hide")
            j++
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'DATEPICK'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Show")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextDate_" + ZAPS(k)+ ".Hide")
            k++
        Endif
    NEXT n

   aadd(aSrc, "   DisableField_" + cShortAlias + "()")
   aadd(aSrc, "   LoadData_" + cShortAlias + "()")
   aadd(aSrc, "   Win_"+cShortAlias+".StatusBar.Item(1) := 'Table "+m->cAlias+".'")
   aadd(aSrc, "   UNLOCK")
   aadd(aSrc, "   New_rec := .F.")
   aadd(aSrc, "   esc_quit()")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE SaveRecord_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")

   aadd(aSrc, "   LOCAL NewRecNo")
   aadd(aSrc, "   DisableField_" + cShortAlias + "()")
   aadd(aSrc, "   IF New_rec == .T.")
   aadd(aSrc, "      " +m->cAlias+ "->( dbAppend() )")
   aadd(aSrc, "      New_rec := .F.")
   aadd(aSrc, "   ELSE")
   aadd(aSrc, "      " +m->cAlias+ "->( dbGoto ( Win_" + cShortAlias + ".Browse_1.Value ) )")
   aadd(aSrc, "   Endif")
   aadd(aSrc, "   NewRecNo := " +m->cAlias+ "->( RecNo() )")
   aadd(aSrc, "")

   nLong := nLongDBF+2+nLongField+1
   FOR n:=1 To nFields
        IF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'COMBO'
            IF Field_Type[n] = 'C'
                FOR m := 1 TO Len(M->aItems)
                    IF M->aItems[m,1] = aControlsOrder[n]
                        EXIT
                    Endif
                NEXT m
                _caCombo := M->aItems[m,4]
                aadd(aSrc, "   " + SpaceFix(m->cAlias + "->" + Field_Name[n],nLong) + ":= "+ _caCombo +"["+ "Win_" + cShortAlias + "."+ aControlsOrder[n] +".Value" + "]")
            ELSE
                aadd(aSrc, "   " + SpaceFix(m->cAlias + "->" + Field_Name[n],nLong) + ":= Win_" + cShortAlias + "."+ aControlsOrder[n] +".Value")
            Endif
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'RADIOGROUP'
            IF Field_Type[n] = 'C'
                FOR m := 1 TO Len(M->aItems)
                    IF M->aItems[m,1] = aControlsOrder[n]
                        EXIT
                    Endif
                NEXT m
                _caCombo := M->aItems[m,4]
                aadd(aSrc, "   " + SpaceFix(m->cAlias + "->" + Field_Name[n],nLong) + ":= "+ _caCombo +"["+ "Win_" + cShortAlias + "."+ aControlsOrder[n] +".Value" + "]")
            ELSE
                aadd(aSrc, "   " + SpaceFix(m->cAlias + "->" + Field_Name[n],nLong) + ":= Win_" + cShortAlias + "."+ aControlsOrder[n] +".Value")
            Endif
        ELSE
            aadd(aSrc, "   " + SpaceFix(m->cAlias + "->" + Field_Name[n],nLong) + ":= Win_" + cShortAlias + "."+ aControlsOrder[n] +".Value")
        Endif
   NEXT n

   aadd(aSrc, "")
   aadd(aSrc, "   dbCommit()")
   aadd(aSrc, "   UNLOCK")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Value := NewRecNo ")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Refresh")
   aadd(aSrc, "   Win_" + cShortAlias + ".StatusBar.Item(1) := 'Record Saved!' ")
   aadd(aSrc, '   _DefineHotKey("Win_'+ cShortAlias + '",0,27, {|| DoMethod ( "Win_'+ cShortAlias +'", "Release" )} )')
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE NewRecord_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   Win_" + cShortAlias + ".StatusBar.Item(1) := 'Editing new record.' ")
   aadd(aSrc, "   SET ORDER TO 1")
   aadd(aSrc, "   dbGoBottom()")
   aadd(aSrc, "")

   FOR n:=1 To nFields
        IF n = 1
            IF Field_Type[n] = "C"
                aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),15+nLongControl+1) + ":= '' ")
            ELSEIF Field_Type[n] = "N"
                aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),15+nLongControl+1) + ":= " + m->cAlias+ "->" +  Field_Name[n] + " + 1")
            Endif
        ELSE
            IF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'COMBO' .OR. GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'RADIOGROUP'
                aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),15+nLongControl+1) + ":= 1")
            ELSE
                DO CASE
                   CASE Field_Type[n] = "C" .OR. Field_Type[n] = "M"
                        aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),15+nLongControl+1) + ":= ''")

                   CASE Field_Type[n] = "N"
                        aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),15+nLongControl+1) + ":= 0")

                   CASE Field_Type[n] = "D"
                        aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),15+nLongControl+1) + ":= CTOD('00/00/00')")

                   CASE Field_Type[n] = "L"
                        aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + aControlsOrder[n] + ".Value"),15+nLongControl+1) + ":= .T.")
                EndCase
            Endif
        Endif
    NEXT n
   aadd(aSrc, "")
   aadd(aSrc, "   EnableField_" + cShortAlias + "()")
   aadd(aSrc, "   Win_" + cShortAlias + "." + cControlSF + ".SetFocus")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE DeleteRecord_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   IF MsgYesNo ( 'Are you sure you want to delete record?', 'Confirmation' )")
   aadd(aSrc, "      DELETE")
   aadd(aSrc, "      dbSkip()")
   aadd(aSrc, "      IF " +m->cAlias+ "->(Eof())")
   aadd(aSrc, "         dbGoBottom()")
   aadd(aSrc, "      Endif")
   aadd(aSrc, "      Win_" + cShortAlias + ".Browse_1.Value := RecNo()")
   aadd(aSrc, "      Win_" + cShortAlias + ".Browse_1.Refresh")
   aadd(aSrc, "   Endif")
   aadd(aSrc, "   UNLOCK")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE FIND_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   Win_" + cShortAlias + ".StatusBar.Item(1) := 'Query.' ")

    j := 1
    k := 1
    FOR n:=1 To nFields //LEN(aControlsOrder)
        IF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'RADIOGROUP'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Hide")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextRadio_" + ZAPS(i)+ ".Show")
            i++
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'COMBO'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Hide")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextCombo_" + ZAPS(j)+ ".Show")
            j++
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'DATEPICK'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Hide")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextDate_" + ZAPS(k)+ ".Show")
            k++
        Endif
    NEXT n

   aadd(aSrc, "")
   nLong := 15+m->nLongControlQ+1
   FOR n:=1 To nFields
        IF Field_Type[n] = "C" .OR. Field_Type[n] = "M"
           aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + m->aControlsQ[n] + ".Value"),nLong) + ":= ''")
        ELSEIF Field_Type[n] = "N"
           aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + m->aControlsQ[n] + ".Value"),nLong) + ":= 0")
        ELSEIF Field_Type[n] = "D"
           aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + m->aControlsQ[n] + ".Value"),nLong) + ":= CTOD('00/00/00')")
        ELSEIF Field_Type[n] = "L"
           aadd(aSrc, "   "+ SpaceFix(("Win_" + cShortAlias + "." + m->aControlsQ[n] + ".Value"),nLong) + ":= .F.")
        Endif
   NEXT n
   aadd(aSrc, "")
   aadd(aSrc, "   EnableField_" + cShortAlias + "()")
   aadd(aSrc, "   Win_" + cShortAlias + ".SAVE.Enabled  := .F.")
   aadd(aSrc, "   Win_" + cShortAlias + ".QUERY.Enabled := .T.")
   aadd(aSrc, "   Win_" + cShortAlias + "."+ aControlsOrder[1] +".SetFocus")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE PrintData_" + cShortAlias + "(cBase, aNomb, aLong)")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   if file('"+cShortalias+".RPT'"+')' )
   aadd(aSrc, "            DO REPORT FORM "+ cShortAlias )
   aadd(aSrc, "      Return")
   aadd(aSrc,"    Endif")
   aadd(aSrc, "   PrintList(cBase, aNomb, aLong)")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE PaintDisplay_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")

    FOR n := 1 TO Len(aControlsWin_1)
        IF GETCONTROLTYPE(aControlsWin_1[n],'Win_1') = 'LABEL'
            GetControlProperty(aControlsWin_1[n])
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol+ ' LABEL ' + aControlsWin_1[n] + ' VALUE ' + '"' + _Value + '"'+ ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } ' + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '" VCENTERALIGN ')
        Endif
    NEXT

    i := 1
    j := 1
    k := 1
    FOR n := 1 TO Len(aControlsOrder)

        SWITCH GETCONTROLTYPE(aControlsOrder[n],'Win_1')
            case 'TEXT'
            cControl := aControlsOrder[n]
            GetControlProperty(aControlsOrder[n])
            FOR m := 1 TO Len(m->aCaseConvert)
                IF m->aCaseConvert[m,1] = cControl
                    EXIT
                Endif
            NEXT m
            _CaseConvert         := m->aCaseConvert[m,2]
            IF Len(_CaseConvert) > 0
                IF _CaseConvert = 'NONE'
                    _CaseConvert:= ''
                ELSE
                    _CaseConvert :=  _CaseConvert + 'CASE'
                Endif
            Endif
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' TEXTBOX ' + aControlsOrder[n] + ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } '  + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '" ' + _CaseConvert)
            EXIT

        CASE 'NUMTEXT'
            cControl:= aControlsOrder[n]
            GetControlProperty(aControlsOrder[n])
            FOR m := 1 TO Len(m->aInputMask)
                IF m->aInputMask[m,1] = cControl
                   EXIT
                Endif
            NEXT m
            _InputMask     := m->aInputMask[m,2]
            IF Len(_InputMask) > 0
               _InputMask := 'INPUTMASK ' + _InputMask
            Endif
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' TEXTBOX ' + aControlsOrder[n] + ' WIDTH ' + _nWidth + ' HEIGHT ' + _nheight + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } ' + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '"' + ' NUMERIC ' + _InputMask + ' RIGHTALIGN')
            EXIT

        CASE 'RADIOGROUP'
            GetControlProperty(aControlsOrder[n])
            FOR m := 1 TO Len(M->aItems)
                IF M->aItems[m,1] = aControlsOrder[n]
                   EXIT
                Endif
            NEXT m
            _caCombo  := M->aItems[m,4]
            _nSpacing := M->aItems[m,3]
            aadd(aSrc, '   @ ' + _nRow + ',' + _nCol +' RADIOGROUP ' + aControlsOrder[n] + ' OPTIONS ' + _caCombo + ' WIDTH ' + _nwidth + ' SPACING ' + _nSpacing + ' BACKCOLOR sfondo '+ ' FONTCOLOR { ' + _ColorF + ' } ' + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '"' + ' TRANSPARENT HORIZONTAL ')
            IF n <= Len(Field_Len)
               nPos := AScan(aControlsOrder,aControlsOrder[n])
               *  MsgInfo(nPos)
               nLargo := Field_Len[nPos] * 10 + 10
               IF Field_Type[nPos] = "C"
                   aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' TEXTBOX TextRadio_' + ZAPS(j) + ' WIDTH ' + _nwidth + ' HEIGHT 24'  + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } '  + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut)
               ELSEIF Field_Type[nPos] = "N"
                   aadd(aSrc, '   @ ' + _nRow + ','+ _nCol  + ' TEXTBOX TextRadio_' + ZAPS(j) + ' WIDTH ' + ZAPS(nLargo) + ' HEIGHT 24' + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } ' + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + 'NUMERIC' + ' RIGHTALIGN')
               Endif
               j++
            Endif
            EXIT

        CASE 'COMBO'
            GetControlPropertyDate(aControlsOrder[n])
            FOR m := 1 TO Len(M->aItems)
                IF M->aItems[m,1] = aControlsOrder[n]
                    EXIT
                Endif
            NEXT m
            _caCombo := M->aItems[m,4]
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' COMBOBOX ' + aControlsOrder[n] + ' VALUE 1 ' + ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight +' ITEMS '+ _caCombo + ' FONT ' + '"' + _FontName  + '"' + ' SIZE ' + _FontSize)
            IF n <= Len(Field_Len)
                nPos := AScan(aControlsOrder,aControlsOrder[n])
                nLargo := Field_Len[nPos] * 10 + 10
                IF Field_Type[nPos] = "C"
                    aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' TEXTBOX TextCombo_' + ZAPS(i) + ' WIDTH ' + _nwidth + ' HEIGHT 24' + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } '  + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut)
                ELSEIF Field_Type[nPos] = "N"
                    aadd(aSrc, '   @ ' + _nRow + ','+ _nCol + ' TEXTBOX TextCombo_' + ZAPS(i) + ' WIDTH ' + ZAPS(nLargo) + ' HEIGHT 24' + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + 'NUMERIC' + ' RIGHTALIGN')
                Endif
                i++
            Endif
            EXIT

        CASE 'DATEPICK'
            GetControlPropertyDate(aControlsOrder[n])
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' DATEPICKER ' + aControlsOrder[n] + ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight  + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '" BACKCOLOR sfondo')
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' TEXTBOX TextDate_' + ZAPS(k) + ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight + ' BACKCOLOR sfondo '+ ' FONTCOLOR { ' + _ColorF + ' } ' + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '"' + ' DATE ')
            k++
            EXIT

        CASE 'CHECKBOX'
            GetControlProperty(aControlsOrder[n])
            _Caption       := GetProperty ('Win_1' ,aControlsOrder[n] ,'Caption')
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' CHECKBOX ' + aControlsOrder[n] + ' CAPTION '+'"'+  _Caption +'"'+ ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } '  + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '" ' + ' TRANSPARENT ')
            EXIT

        CASE 'EDIT'
            GetControlProperty(aControlsOrder[n])
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' EDITBOX ' + aControlsOrder[n] + ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight + ' BACKCOLOR { ' + _ColorB + ' } '+ ' FONTCOLOR { ' + _ColorF + ' } '  + ' FONT '  + '"' + _FontName  + '"' + ' SIZE ' + _FontSize + ' ' + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' +_ToolTip + '"')
            EXIT

        CASE 'BUTTON'
            GetControlPropertyButt(aControlsOrder[n])
            aadd(aSrc, '   @ ' + _nRow + ','+ _nCol +' BUTTON ' + aControlsOrder[n] +' CAPTION '+ '"'+ _Caption + '"' + ' ACTION ' + _Act + ' WIDTH ' + _nwidth + ' HEIGHT ' + _nheight  +  ' FONT ' +'"'+ _FontName  +'"'+ ' SIZE ' + _FontSize  + _FontBold + _FontItalic + _FontUnderLine + _FontStrikeOut + ' ToolTip ' + '"' + _ToolTip + '"')
            EXIT

        EndSwitch

    NEXT n

   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE Head_" + cShortAlias + "(nIndice)")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   LOCAL nPos := ASCAN(m->anCamposM,nIndice) , nMemos := 0")
   aadd(aSrc, "    IF nPos != 0")
   aadd(aSrc, "        PlayBeep()")
   aadd(aSrc, "        MsgBox('You can not index this field !')")
   aadd(aSrc, "    ELSE ")
   aadd(aSrc, "        FOR n := 1 TO nIndice ")
   aadd(aSrc, "           IF aMiDB[n,2] = 'M' ")
   aadd(aSrc, "              nMemos ++ ")
   aadd(aSrc, "           Endif ")
   aadd(aSrc, "        NEXT n ")
   aadd(aSrc, "        DBSELECTAREA('" +m->cAlias+ "')")
   aadd(aSrc, "        DBSETORDER(nIndice-nMemos)")
   aadd(aSrc, "        dbGotop()")
   aadd(aSrc, "        Win_" + cShortAlias + ".Browse_1.Value := RecNo()")
   aadd(aSrc, "        Win_" + cShortAlias + ".Browse_1.Refresh")
   aadd(aSrc, "        LoadData_" + cShortAlias + "()")
   aadd(aSrc, "    Endif ")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE QueryRecord_" + cShortAlias)
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   LOCAL found_rec ")
   aadd(aSrc, "   PreQUERY_" + cShortAlias + "()")
   aadd(aSrc, "   SET FILTER TO ")
   aadd(aSrc, "   dbGotop()")
   aadd(aSrc, "   IF ! EMPTY( _qry_exp )")
   aadd(aSrc, "      COUNT TO found_rec FOR &_qry_exp")
   aadd(aSrc, "      dbGotop()")
   aadd(aSrc, "")
   aadd(aSrc, "      IF found_rec = 0")
   aadd(aSrc, "         Win_" + cShortAlias + ".Statusbar.Item(1) := 'Not found!'")
   aadd(aSrc, "         dbGotop()")
   aadd(aSrc, "      ELSE")
   aadd(aSrc, "         SET FILTER TO &_qry_exp")
   aadd(aSrc, "         dbGotop()")
   aadd(aSrc, "         Win_" + cShortAlias + ".Statusbar.Item(1) := 'Found ' + ZAPS(found_rec) + ' record(s)!'")
   aadd(aSrc, "      Endif")
   aadd(aSrc, "   Endif")

    i := 1
    j := 1
    k := 1
    FOR n:=1 To nFields //Len(aControlsOrder)
        IF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'RADIOGROUP'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Show")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextRadio_" + ZAPS(i)+ ".Hide")
            i++
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'COMBO'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Show")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextCombo_" + ZAPS(j)+ ".Hide")
            j++
        ELSEIF GETCONTROLTYPE(aControlsOrder[n],'Win_1') = 'DATEPICK'
            aadd(aSrc, "   Win_" + cShortAlias + "." + aControlsOrder[n] + ".Show")
            aadd(aSrc, "   Win_" + cShortAlias + ".TextDate_" + ZAPS(k)+ ".Hide")
        Endif
    NEXT n

   aadd(aSrc, "   DisableField_" + cShortAlias + "()")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Value := RecNo()")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Refresh")
   aadd(aSrc, "   Win_" + cShortAlias + ".Browse_1.Enabled := .T.")
   aadd(aSrc, "   LoadData_" + cShortAlias + "()")
   aadd(aSrc, "   _DefineHotKey("+ W_name + ",0,27,{|| DoMethod ( "+W_Name+', "Release")} )')
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "PROCEDURE PreQUERY_" + cShortAlias + "")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   LOCAL _ima_filter , cControl , cField")
   aadd(aSrc, "    _qry_exp := ''")
   aadd(aSrc, "    _ima_filter := .F.")
   aadd(aSrc, "    FOR n:= 1 TO LEN(m->aControlsQ)")
   aadd(aSrc, "        cControl := m->aControlsQ[n]")
   aadd(aSrc, "        cField   := aCampos[n]")
   aadd(aSrc, "        IF ! EMPTY ( Win_" + cShortAlias + ".&(cControl).Value )  ")
   aadd(aSrc, "            IIF(_ima_filter,_qry_exp := _qry_exp + ' .AND. ',)")
   aadd(aSrc, "            IF ValType(Win_" + cShortAlias + ".&(cControl).Value) = 'C' ")
   aadd(aSrc, "                cValor := Win_" + cShortAlias + ".&(cControl).Value ")
   aadd(aSrc, "                 _qry_exp := _qry_exp + " + 'cField  + ' + '" = ' + "'"  + chr(34) + ' + cValor + ' + chr(34) + "'" + chr(34))
   aadd(aSrc, "                _ima_filter := .T. ")
   aadd(aSrc, "            ELSEIF ValType(Win_" + cShortAlias + ".&(cControl).Value) = 'N' ")
   aadd(aSrc, "                cValor := STR(Win_" + cShortAlias + ".&(cControl).Value) ")
   aadd(aSrc, "                _qry_exp = _qry_exp + " + 'cField  + ' + '" = ' + chr(34) + ' + cValor + ' + chr(34) + chr(34))
   aadd(aSrc, "                _ima_filter := .T. ")
   aadd(aSrc, "            ELSEIF ValType(Win_" + cShortAlias + ".&(cControl).Value) = 'D' ")
   aadd(aSrc, "                cValor := DTOC(Win_" + cShortAlias + ".&(cControl).Value) ")
   aadd(aSrc, "                 _qry_exp = _qry_exp + " + 'cField + ' + '" = CTOD(' +"'" +'" + ' + 'cValor' + ' + "' + "')" + '"')
   aadd(aSrc, "                _ima_filter := .T. ")
   aadd(aSrc, "            ELSEIF ValType(Win_" + cShortAlias + ".&(cControl).Value) = 'L'")
   aadd(aSrc, "                _qry_exp = _qry_exp + " + 'cField' + ' = ' +  " IIF(Win_" + cShortAlias + ".&(cControl).Value = .T. ,  ' .T. ' , ' .F. ' )")
   aadd(aSrc, "                _ima_filter := .T. ")
   aadd(aSrc, "            Endif")
   aadd(aSrc, "        Endif    ")
   aadd(aSrc, "    NEXT n")
   aadd(aSrc, "Return   ")
   IF lImage
      aadd(aSrc, '/*')
      aadd(aSrc, "*/")
      aadd(aSrc, "*--------------------------------------------------------*")
      aadd(aSrc, "PROCEDURE Foto" + cShortAlias + "() //  Use this function only for record related Image" )
      aadd(aSrc, "*--------------------------------------------------------*")
      aadd(aSrc, "    LOCAL MyImage:=''")
      aadd(aSrc, "    LOCAL Foto" + cShortAlias + "")
      aadd(aSrc, "    LOCAL iPos := GetCurrentFolder()+'\" +m->cAlias+ "\'")
      aadd(aSrc, "    MyImage:= '" + cShortAlias + "' + ALLTRIM("+ IIF(Field_Type[1] = 'N','STR','') + "(Win_" + cShortAlias + "." +  aControlsOrder[1] + ".Value))")
      aadd(aSrc, "    Foto" + cShortAlias + " := iPos + MyImage + '.jpg'")
      aadd(aSrc, "    IF !FILE(Foto" + cShortAlias + ")")
      aadd(aSrc, "       Foto" + cShortAlias + " := iPos + 'Logo.jpg'")
      aadd(aSrc, "    Endif")
      aadd(aSrc, "    Win_" + cShortAlias + ".Image_1.Picture := Foto" + cShortAlias + "")
      aadd(aSrc, "Return")
   Endif)
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "Procedure PrintList(cBase, aNomb, aLong, lEdit)")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   Local aHdr  := aClone(aNomb)")
   aadd(aSrc, "   Local aLen  := aClone(aLong)")
   aadd(aSrc, "   Local aHdr1 , aTot , aFmt ,mlen:=0")
   aadd(aSrc, "")
   aadd(aSrc, "   Default lEdit to .F. ")
   aadd(aSrc, "")
   aadd(aSrc, "   if !used() ")
   aadd(aSrc, "      USE &cDBF NEW SHARED" )
   aadd(aSrc, "   Endif ")
   aadd(aSrc, "")
   aadd(aSrc, "   if lEdit ")
   aadd(aSrc, "      URE(aHdr,alen) ")
   aadd(aSrc, "      return ")
   aadd(aSrc, "   Endif ")
   aadd(aSrc, "")
   aadd(aSrc, "   adel(aLen, 1)")
   aadd(aSrc, "   asize(aLen, len(aLen)-1)")
   aadd(aSrc, "   adel(aHdr, 1)")
   aadd(aSrc, "   asize(aHdr, len(aHdr)-1)")
   aadd(aSrc, "   aHdr1 := array(len(aHdr))")
   aadd(aSrc, "   aTot := array(len(aHdr))")
   aadd(aSrc, "   aFmt := array(len(aHdr))")
   aadd(aSrc, "   afill(aHdr1, '')")
   aadd(aSrc, "   afill(aTot, .f.)")
   aadd(aSrc, "   afill(aFmt, '')")
   aadd(aSrc, "")
   aadd(aSrc, "   aeval(aLen, {|e,i| aLen[i] := e/8})")
   aadd(aSrc, "")
   aadd(aSrc, " /* Put here your personalized colums  */")
   aadd(aSrc, "   aLen[1] := 10")
   aadd(aSrc, "   aLen[2] := 60")
   aadd(aSrc, "")
   aadd(aSrc, "   aeval(alen,{|x|mlen += x})")
   aadd(aSrc, "")
   aadd(aSrc, "   ( cBase )->( dbgotop() )")
   aadd(aSrc, "   if mlen > 150       // Require sheet rotation ")
   aadd(aSrc, "      DO REPORT ;")
   aadd(aSrc, [         TITLE  "Print List"      ;])
   aadd(aSrc, "         HEADERS  aHdr1, aHdr     ;")
   aadd(aSrc, "         FIELDS   aHdr            ;")
   aadd(aSrc, "         WIDTHS   aLen            ;")
   aadd(aSrc, "         TOTALS   aTot            ;")
   aadd(aSrc, "         NFORMATS aFmt            ;")
   aadd(aSrc, "         WORKAREA &cBase          ;")
   aadd(aSrc, "         LMARGIN  5               ;")
   aadd(aSrc, "         TMARGIN  3               ;")
   aadd(aSrc, "         PAPERSIZE DMPAPER_A4     ;")
   aadd(aSrc, "         PREVIEW  ;")
   aadd(aSrc, "         LANDSCAPE ")
   aadd(aSrc, "   Else")
   aadd(aSrc, "      DO REPORT ;")
   aadd(aSrc, [         TITLE  "Print List"      ;])
   aadd(aSrc, "         HEADERS  aHdr1, aHdr     ;")
   aadd(aSrc, "         FIELDS   aHdr            ;")
   aadd(aSrc, "         WIDTHS   aLen            ;")
   aadd(aSrc, "         TOTALS   aTot            ;")
   aadd(aSrc, "         NFORMATS aFmt            ;")
   aadd(aSrc, "         WORKAREA &cBase          ;")
   aadd(aSrc, "         LMARGIN  5               ;")
   aadd(aSrc, "         TMARGIN  3               ;")
   aadd(aSrc, "         PAPERSIZE DMPAPER_A4     ;")
   aadd(aSrc, "         PREVIEW ")
   aadd(aSrc, "   Endif")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "Procedure esc_quit()")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, " _DefineHotKey('win_"+ cShortAlias + "',0,27,{||ClosePrg()})")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "Procedure ClosePrg(forced,msg)")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "local Rtv := .F.")
   aadd(aSrc, 'Default forced := .f. ,msg  := "Quit the program?"')
   aadd(aSrc, "If !forced")
   aadd(aSrc, "    Rtv := MsgYESNO(msg,[End program.])")
   aadd(aSrc, "Endif")
   aadd(aSrc, "if Rtv .or. forced")
   aadd(aSrc, "   DBCOMMITALL()")
   aadd(aSrc, "   DBUNLOCKALL()")
   aadd(aSrc, "   DbCloseAll()")
   aadd(aSrc, "   If _Iswindowdefined('win_"+ cShortAlias + "')")
   aadd(aSrc, "      Win_"+ cShortAlias + ".Release")
   aadd(aSrc, "   Endif")
   aadd(aSrc, "   QUIT")
   aadd(aSrc, "Endif")
   aadd(aSrc, "Return")
   aadd(aSrc, '/*')
   aadd(aSrc, "*/")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "Procedure Save_color()")
   aadd(aSrc, "*--------------------------------------------------------*")
   aadd(aSrc, "   LOCAL cor_atual, m_cor")
   aadd(aSrc, '   cor_atual := GetProperty ( '+W_Name+', "BROWSE_1" , "backcolor" )')
   aadd(aSrc, "   m_cor := GetColor( cor_atual )")
   aadd(aSrc, "   if m_cor[1] != NIL")
   aadd(aSrc, '      BEGIN INI file (c_pos+"'+ m->cAlias+'.ini")')
   aadd(aSrc, '            SET SECTION "COLORS" ENTRY "Sfondo" To m_cor')
   aadd(aSrc, "      End INI")
   aadd(aSrc, "      sfondo := m_cor")
   aadd(aSrc, '      SetProperty ( '+W_Name+', "BROWSE_1" , "backcolor" ,sfondo)')
   aadd(aSrc, "")
   FOR each n in m->aControlList
       if "CheckBox" $ N
          aadd(aSrc, '      SetProperty ( '+W_Name+', "'+n+'" , "backcolor" ,sfondo)')
       elseif "RadioGroup" $ n
          aadd(aSrc, '      SetProperty ( '+W_Name+', "'+n+'" , "backcolor" ,sfondo)')
       Endif
   Next
   aadd(aSrc, '      SetProperty ( '+W_Name+', "BackColor" , Sfondo )')
   aadd(aSrc, '      DoMethod ( '+W_Name+', "Hide" )')
   aadd(aSrc, '      DoMethod ( '+W_Name+', "show" )')
   aadd(aSrc, "   Endif")
   aadd(aSrc, "Return")
   aadd(aSrc,"" )
   aadd(aSrc,"/*")
   aadd(aSrc,"*/")
   aadd(aSrc,"*------------------------------------------------------------------------------*")
   aadd(aSrc,"Procedure PutMouse( obj, form, rect )")
   aadd(aSrc,"*------------------------------------------------------------------------------*")
   aadd(aSrc,"   Local ocol, orow")
   aadd(aSrc,"")
   aadd(aSrc,'   DEFAULT form TO "Win_1", rect TO {20,40}')
   aadd(aSrc,"")
   aadd(aSrc,'   ocol  := GetProperty( Form, "col" ) + GetProperty( Form, obj, "Col" ) + rect [1]')
   aadd(aSrc,'   orow  := GetProperty( Form, "row" ) + GetProperty( Form, obj, "row" ) + rect [2]')
   aadd(aSrc,"")
   aadd(aSrc,"   _SETFOCUS( obj, FORM )")
   aadd(aSrc,"   SETCURSORPOS( ocol, orow )")
   aadd(aSrc,"")
   aadd(aSrc,"Return")

   aadd(aSrc, "* End of program *" )

   WriteFile(cfile,aSrc)

   dbCommitAll()
   dbCloseAll()

   EXECUTE FILE cFileBat WAIT MINIMIZE

   MessageBoxTimeout ('Working in progress !!', 'Please wait ...', MB_OK, 1500 )

   asize(m->aControlList,0)
   FOR n:=1 TO Form_1.Combo_2.ItemCount
       Aadd(m->aControlList,Form_1.Combo_2.Item(n))
   Next

   Ferase(cFileBat)

Return

/*
*/
*-----------------------------------------------------------------------------*
FUNCTION SpaceFix(cStr,n)
*-----------------------------------------------------------------------------*
LOCAL cSpace, nLong
      nLong  := Len(AllTrim(cStr))
      cSpace := cStr + Space(n-nLong)
Return cSpace
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE Arriba(lArriba)
*-----------------------------------------------------------------------------*
    LOCAL nRow    := Posicion.Grid_2.Value
    LOCAL n1Rows  := nRow
    LOCAL n2Rows, c2Type, c2Control
    LOCAL c1Control :=  Posicion.Grid_2.Cell(n1Rows,1)
    LOCAL c1Type    :=  Posicion.Grid_2.Cell(n1Rows,2)

    IF nRow == 0
       msgbox('There is no item selected !')
       Return
    Endif

    IF lArriba = .T.
       IF nRow == 1
          msgStop('CAN NOT MOVE MORE !')
          Return
       ELSE
          n2Rows   := n1Rows - 1
       Endif
    ELSE
       IF nRow == Posicion.Grid_2.ItemCount
          msgStop('CAN NOT MOVE MORE !')
          Posicion.Grid_2.SetFocus
          Return
       ELSE
          n2Rows   := n1Rows + 1
       Endif
    Endif

    c2Control := Posicion.Grid_2.Cell(n2Rows,1)
    c2Type    := Posicion.Grid_2.Cell(n2Rows,2)

    Posicion.Grid_2.Cell(n1Rows,1) := c2Control
    Posicion.Grid_2.Cell(n1Rows,2) := c2Type

    Posicion.Grid_2.Cell(n2Rows,1) := c1Control
    Posicion.Grid_2.Cell(n2Rows,2) := c1Type

    Posicion.Grid_1.VALUE := n2Rows
    Posicion.Grid_2.VALUE := n2Rows
    Posicion.Grid_2.SetFocus

Return
*-----------------------------------------------------------------------------*
****************************************************************
*   GENERAL FUNCTIONS for Move and Resize Control With Cursor  *
****************************************************************
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE OnKeyPress( nVKey,GF )
*-----------------------------------------------------------------------------*
   DEFAULT GF TO .F.

   do case
      case nVKey == VK_F3   // Info
           HMG_InfoControlWithCursor()

      case nVKey == VK_F5   // Move
           HMG_MoveControlWithCursor( GF )

      case nVKey == VK_F9   // Resize
           HMG_ResizeControlWithCursor( Gf )

   Endcase

RETURN
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE HMG_InfoControlWithCursor
*-----------------------------------------------------------------------------*
   LOCAL hWnd, aPos
   LOCAL cFormName, cControlName

   aPos := GetCursorPos ()
   msgStop(aPos)
   hWnd := WindowFromPoint ( { aPos[ 2 ], aPos[ 1 ] } )

   IF GetControlIndexByHandle ( hWnd ) > 0
      GetControlNameByHandle ( hWnd, @cControlName, @cFormName )
      MsgInfo ( { cFormName + "." + cControlName, hb_osNewLine(),hb_osNewLine(), ;
         "Row     : ",padl( GetProperty ( cFormName, cControlName, "Row" ),10),hb_osNewLine(), ;
         "Col       : ", padl(GetProperty ( cFormName, cControlName, "Col" ),10),hb_osNewLine(), ;
         "Width  : ", padl(GetProperty ( cFormName, cControlName, "Width" ),10),hb_osNewLine(), ;
         "Height : ", padl(GetProperty ( cFormName, cControlName, "Height" ),10) },"Control Info" )
   Endif

Return
/*
*/
#If 0
*-----------------------------------------------------------------------------*
PROCEDURE MyControl()
*-----------------------------------------------------------------------------*
LOCAL hWnd, nCol, nRow
LOCAL cFormName, cControlName
    GetCursorPos (@nCol, @nRow)
    hWnd := WindowFromPoint (nCol, nRow)
    GetControlNameByHandle (hWnd, @cControlName, @cFormName)
    SetProperty (  "Form_1", "Label_d", "VALUE", cControlName )
Return
#Endif
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE HMG_MoveControlWithCursor ( Gf )
*-----------------------------------------------------------------------------*
   LOCAL hWnd, aPos ,SnapR, SnapC
   LOCAL cFormName, cControlName
   LOCAL nGrid := Form_1.GridSpinner.Value
   LOCAL Snap  := Form_1.Check1.Value

   DEFAULT Gf TO .F.

   if gf
      PutMouse()   // Clear action when CONTEXT MENU is used
   Endif

   aPos := GetCursorPos ()
   hWnd := WindowFromPoint ( { aPos[ 2 ], aPos[ 1 ] } )
   IF GetControlIndexByHandle ( hWnd ) > 0
      GetControlNameByHandle ( hWnd, @cControlName, @cFormName )
      DoMethod( cFormName, cControlName, "SetFocus" )
      HMG_InterActiveMove  ( hWnd )
      aPos := ScreenToClient ( GetFormHandle( cFormName ), GetWindowCol (hWnd ), GetWindowRow ( hWnd ) )
      SetProperty ( cFormName, cControlName, "Col", aPos[ 1 ] )
      SetProperty ( cFormName, cControlName, "Row", aPos[ 2 ] )

      if nGrid > 0 .and. Snap
         SnapR := Round(_GetControlRow( cControlName, cFormName )/nGrid,0) * nGrid
         SnapC := Round(_GetControlCol( cControlName, cFormName )/nGrid,0) * nGrid

         _SetControlSizePos( cControlName, cFormName ;
                             , SnapR ; //, _GetControlRow( cControlName, cFormName ) ;
                             , SnapC ; //, _GetControlCol( cControlName, cFormName ) ;
                             , _GetControlWidth( cControlName, cFormName ) ;
                             , _GetControlHeight( cControlName, cFormName )  )
      Endif
   Endif
   ConfigValores()
RETURN
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE HMG_ResizeControlWithCursor ( Gf )
*-----------------------------------------------------------------------------*
   LOCAL hWnd, aPos ,snapW,snapH
   LOCAL nWidth, nHeight
   LOCAL cFormName, cControlName
   LOCAL nGrid := Form_1.GridSpinner.Value
   LOCAL Snap  := Form_1.Check1.Value

   DEFAULT Gf TO .F.

   if gf
      PutMouse()    // Clear action when CONTEXT MENU is used
   Endif

   aPos := GetCursorPos ()
   hWnd := WindowFromPoint ( { aPos[ 2 ], aPos[ 1 ] } )

   IF GetControlIndexByHandle ( hWnd ) > 0
      GetControlNameByHandle ( hWnd, @cControlName, @cFormName )
      DoMethod( cFormName, cControlName, "SetFocus" )
      HMG_InterActiveSize ( hWnd )
      nWidth   := GetWindowWidth  ( hWnd )
      nHeight  := GetWindowHeight ( hWnd )
      SetProperty ( cFormName, cControlName, "Width",  nWidth )
      SetProperty ( cFormName, cControlName, "Height", nHeight )

      if nGrid > 0  .and. Snap
         SnapW := Round(_GetControlWidth( cControlName, cFormName )/nGrid,0) * nGrid
         SnapH := Round(_GetControlHeight( cControlName, cFormName )/nGrid,0) * nGrid

         _SetControlSizePos( cControlName, cFormName ;
                             , _GetControlRow( cControlName, cFormName ) ;
                             , _GetControlCol( cControlName, cFormName ) ;
                             , SnapW ;
                             , SnapH  )
      Endif

   Endif
   ConfigValores()
RETURN
/*
*/
*------------------------------------------------------------------------------*
Procedure PutMouse( obj, form, rect )
*------------------------------------------------------------------------------*
   Local ocol, orow

   DEFAULT form TO "Win_1", rect TO {20,40}, obj to m->aControlList[Form_1.Combo_2.VALUE]

   if obj = "Win_1"
      obj := m->cNameControl
   endif

   ocol  := GetProperty( Form, "col" ) + GetProperty( Form, obj, "Col" ) + rect [1]
   orow  := GetProperty( Form, "row" ) + GetProperty( Form, obj, "row" ) + rect [2]

   _SETFOCUS( obj, FORM )
   SETCURSORPOS( ocol, orow )

Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE DrawGrid()
*-----------------------------------------------------------------------------*
   LOCAL hWnd2, nGrid

   IF !IsWindowDefined("Win_1")
      Return
   Endif
   hWnd2 := GetFormHandle("Win_1")
   nGrid := Form_1.GridSpinner.Value
   if nGrid > 0
      RedrawWindow( hWnd2 )
      _ControlPos_C_DrawGrid_( hWnd2, nGrid, 0, 0 )
   Else
      RedrawWindow( hWnd2 )
   Endif
RETURN
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE RedrawGrid ()
*-----------------------------------------------------------------------------*
LOCAL Width  := BT_ClientAreaWidth  ("Win_1")
LOCAL Height := BT_ClientAreaHeight ("Win_1")
LOCAL hDC, BTstruct, nPx := Form_1.GridSpinner.Value, i, j

if nPx < 1
   nPx := Width
Endif

   hDC := BT_CreateDC ("Win_1", BT_HDC_INVALIDCLIENTAREA, @BTstruct)
      FOR i := nPx TO Width STEP nPx
          FOR j := nPx TO Height STEP nPx
             BT_DrawSetPixel (hDC, j, i, BLACK)
          Next
      Next
   BT_DeleteDC (BTstruct)

RETURN
/*
*/
*-----------------------------------------------------------------------------*
Function GetControlNameByHandle (hWnd, cControlName, cFormParentName)
*-----------------------------------------------------------------------------*
   LOCAL nIndexControlParent, ControlParentHandle
   LOCAL nIndexControl := GetControlIndexByHandle (hWnd)
   cControlName := cFormParentName := ""
   IF nIndexControl > 0
      cControlName := GetControlNameByIndex (nIndexControl)
      ControlParentHandle := GetControlParentHandleByIndex (nIndexControl)
      IF ControlParentHandle <> 0
         nIndexControlParent := GetFormIndexByHandle (ControlParentHandle)
         cFormParentName     := GetFormNameByIndex (nIndexControlParent)
      Endif
   Endif
Return nIndexControl
/*
*/
*-----------------------------------------------------------------------------*
Function GetControlIndexByHandle ( hWnd, nControlSubIndex1, nControlSubIndex2)
*-----------------------------------------------------------------------------*
   LOCAL i, ControlHandle, nIndex := 0

   FOR i = 1 TO Len ( _HMG_aControlHandles )
      ControlHandle := _HMG_aControlHandles[i ]
      IF HMG_CompareHandle ( hWnd, ControlHandle, @nControlSubIndex1,@nControlSubIndex2 ) == .T.
         nIndex := i
         EXIT
      Endif
   NEXT

RETURN nIndex
/*
*/
*-----------------------------------------------------------------------------*
 FUNCTION HMG_LEN (x)
*-----------------------------------------------------------------------------*
    IF HB_ISSTRING(x) .OR. HB_ISCHAR(x) .OR. HB_ISMEMO(x)
       Return HB_ULEN (x)
    ELSE
       Return LEN (x)
    Endif
Return NIL
/*
*/
*-----------------------------------------------------------------------------*
Function HMG_CompareHandle (Handle1, Handle2, nSubIndex1, nSubIndex2)
*-----------------------------------------------------------------------------*
   LOCAL i,k
      nSubIndex1 := nSubIndex2 := 0

      IF ValType (Handle1) == "N" .AND. ValType (Handle2) == "N"
         IF Handle1 == Handle2
            Return .T.
         Endif

      ELSEIF ValType (Handle1) == "A" .AND. ValType (Handle2) == "N"
         FOR i = 1 TO HMG_LEN (Handle1)
            IF Handle1 [i] == Handle2
               nSubIndex1 := i
               Return .T.
            Endif
         NEXT

      ELSEIF ValType (Handle1) == "N" .AND. ValType (Handle2) == "A"
         FOR k = 1 TO HMG_LEN (Handle2)
            IF Handle1 == Handle2 [k]
               nSubIndex2 := k
               Return .T.
            Endif
         NEXT

      ELSEIF ValType (Handle1) == "A" .AND. ValType (Handle2) == "A"
         FOR i = 1 TO HMG_LEN (Handle1)
            FOR k = 1 TO HMG_LEN (Handle2)
               IF Handle1 [i] == Handle2 [k]
                  nSubIndex1 := i
                  nSubIndex2 := k
                  Return .T.
               Endif
            NEXT
         NEXT
      Endif
Return .F.
/*
*/
*-----------------------------------------------------------------------------*
STATIC FUNCTION m_about()
*-----------------------------------------------------------------------------*
Return MsgInfo(padc("Quick Browse Generator" + " - Freeware", 40) + CRLF + ;
   padc("Copyright (c) 2015 dragancesu",40) + CRLF + CRLF + ;
   "Improved by Pierpaolo Martinello 2017"+ CRLF + CRLF + ;
   hb_compiler() + CRLF + ;
   version() + CRLF + ;
   substr(MiniGuiVersion(), 1, 38), "About", IDI_MAIN, .f.)
/*
*/

#xcommand ON KEY SPACE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , 0 , VK_SPACE , <{action}> )

/*
*/
*-----------------------------------------------------------------------------*
Function PickField(aitems,AllF)
*-----------------------------------------------------------------------------*
   local aChk := {}, nChk := 0 , rtv := {}, ctitle
   Private clItem
   DEFAULT aItems TO {"Item 1","Item 2","Item 3","Item 4","Item 5"}
   DEFAULT allF TO .F.
   m->clItem := aclone(aitems)
   aeval( aItems ,{|| aadd(aChk, ++ nChk )} )
   asize(aChk,22)
   cTitle := "Field Wizard - Select fields to use"+ iif(allF =.T.,[.],[ ( Max 22 ).] )

   DEFINE WINDOW Form_PF AT 97,62 WIDTH 390 HEIGHT 300 ;
      TITLE ctitle ;
      WINDOWTYPE MODAL NOSIZE ON INIT PutMouse("BtnAddAll", "Form_PF") ON RELEASE rtv:= outVal()

      DEFINE STATUSBAR FONT 'Arial' SIZE 12
         STATUSITEM  '  No Field(s) selected.'
      END STATUSBAR

      @ 10,10 CHECKLISTBOX ListBox_1 ;
         WIDTH 150 HEIGHT 160 ;
         ITEMS aItems ;
         VALUE 1 ;
         CHECKBOXITEM aChk ;
         ON DBLCLICK clb_Check() ;
         ITEMHEIGHT 19 ;
         FONT 'Arial' SIZE 9

        DEFINE BUTTONEX BtnAdd
                        ROW     40
                        COL     167
                        WIDTH   25
                        HEIGHT  21
                        Caption ">"
                        FONTBOLD .T.
                        TOOLTIP 'Add Selected Field'
                        ONCLICK Fld_add()
                        Backcolor  {204,255,0}
                        NOXPSTYLE .T.
        END BUTTONEX

        DEFINE BUTTONEX BtnAddAll
                        ROW     80
                        COL     167
                        WIDTH   25
                        HEIGHT  21
                        Caption ">>"
                        FONTBOLD .T.
                        TOOLTIP 'Add all checked fields'
                        ONCLICK Fld_add(.T.)
        END BUTTONEX

      @ 10,200 Listbox ListBox_2 ;
         WIDTH 150 HEIGHT 160 ;
         ITEMS {} ;
         FONT 'Arial' SIZE 9 ;
         NOTABSTOP

        DEFINE BUTTONEX BtnErase
                        ROW     120
                        COL     167
                        WIDTH   25
                        HEIGHT  21
                        Caption "<"
                        FONTBOLD .T.
                        TOOLTIP 'Remove Selected Field'
                        ONCLICK  Fld_del()
                        Backcolor RED
                        NOXPSTYLE .T.
        END BUTTONEX

        DEFINE BUTTONEX BUpPrg2
                         ROW     20
                         COL     360
                         WIDTH   16
                         HEIGHT  21
                         PICTURE 'UP'
                         TOOLTIP 'Up Field in List'
                         ONCLICK  UpFld()
        END BUTTONEX

        DEFINE BUTTONEX BDownPrg
                        ROW     50
                        COL     360
                        WIDTH   16
                        HEIGHT  21
                        PICTURE 'DOWN'
                        TOOLTIP 'Down Field in List'
                        ONCLICK  DownFld()
        END BUTTONEX

      @ 190,35 buttonEx bt1 caption '&Unselect all' height 35 picture "EDIT_DELETE" action Clr_Fld()

      @ 190,225 buttonEx btm1 caption '&Accept' height 35 picture 'Ok' action domethod('Form_PF',"RELEASE")

      on key space action clb_Check()

   END WINDOW

   Form_PF.Center ; Form_PF.Activate

Return rtv
/*
*/
*-----------------------------------------------------------------------------*
function OutVal()
*-----------------------------------------------------------------------------*
   Local ni, retv := {}
   FOR ni = 1 to Form_PF.ListBox_2.ItemCount
       AADD ( retv, GetProperty( 'Form_PF', 'ListBox_2', 'Item' , ni )  )
   NEXT

Return retv
/*
*/
*-----------------------------------------------------------------------------*
Procedure  Fld_add(All)
*-----------------------------------------------------------------------------*
   local nn    := Form_PF.ListBox_2.ItemCount, ni, aCmp := {}
   local nList := Form_PF.ListBox_1.value, adFld := {}

   DEFAULT All TO .F.

   if all
      FOR ni = 1 to Form_PF.ListBox_1.ItemCount
          if clb_getCheck( ni )
             AADD ( adFld, GetProperty( 'Form_PF', 'ListBox_1', 'Item' , ni )  )
          Endif
      NEXT
   Else

   adFld := { cmlb_getItem( nList ) }

   Endif

   If nn > 21
      MessageBoxTimeout (padc("Too many Fields",50 )+CRLF+CRLF;
              +padc("This Field CANNOT be add !!",50),"Error Max 22 Fields !", MB_ICONSTOP, 2000 )
      Return
   Endif

   FOR ni = 1 to nn
       AADD (aCmp, Form_PF.ListBox_2.item(ni))
   next

   aeval( adfld,{|x| Fld_addVal ( nn, nlist, aCmp, x ) } )
   Form_PF.StatusBar.Item(1) := "  "+ZAPS(Form_PF.ListBox_2.ItemCount)+ " Field(s) selected."

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Fld_addVal( nn, nlist, aCmp, AdFld )
*-----------------------------------------------------------------------------*
Local no := ascan(m->clItem,Adfld)
   if ascan(aCmp,Adfld) < 1
      Form_PF.ListBox_2.AddItem( adFld )
      Form_PF.ListBox_2.value := nn + 1
      Form_PF.ListBox_1.value := nList + 1
      setproperty('Form_PF','ListBox_1',"CHECKBOXITEM",no,.F.)
   Endif
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Fld_addAll()
*-----------------------------------------------------------------------------*
   local nn := Form_PF.ListBox_2.ItemCount + 1
   Form_PF.ListBox_2.AddItem( cmlb_getItem(nn)  )
   Form_PF.ListBox_2.value := {nn}
   Form_PF.StatusBar.Item(1) := "  "+ZAPS(Form_PF.ListBox_2.ItemCount)+ " Field(s) selected."
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Clr_Fld
*-----------------------------------------------------------------------------*
   Form_PF.ListBox_1.DeleteAllItems
   aeval(m->clItem,{|x|Form_PF.ListBox_1.AddItem( x ) } )
   Form_PF.ListBox_1.value := 1
Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Fld_del
*-----------------------------------------------------------------------------*
   local n1 , vs, no
   local nn := Form_PF.ListBox_2.value

   vs := Form_PF.ListBox_2.item( nn )
   Form_PF.ListBox_2.DeleteItem( nn )
   n1 := Form_PF.ListBox_2.ItemCount
   if nn <= n1
      Form_PF.ListBox_2.value := nn
   else
      Form_PF.ListBox_2.value := n1
   endif
   no := ascan(m->clItem,vs)
   if no > 0
      setproperty('Form_PF','ListBox_1',"CHECKBOXITEM",no ,.T.)
   Endif
   Form_PF.StatusBar.Item(1) := "  "+ZAPS(Form_PF.ListBox_2.ItemCount)+ " Field(s) selected."

Return
/*
*/
*-----------------------------------------------------------------------------*
Function UpFld()
*-----------------------------------------------------------------------------*
   Local i := GetProperty( 'Form_PF', 'ListBox_2', 'value' )
   Local cAux := GetProperty( 'Form_PF', 'ListBox_2', 'item', i )
   Local cAux2 := GetProperty( 'Form_PF', 'ListBox_2', 'item', i - 1 )
   if i = 1
      MessageBoxTimeout (padc('Use the DOWN button !',50 )+CRLF+CRLF;
              +padc("You have reached the top of list !!",50),"Error Top of list !", MB_ICONSTOP, 2300 )
   endif
   if i > 1
      SetProperty( 'Form_PF', 'ListBox_2', 'item', i, cAux2 )
      SetProperty( 'Form_PF', 'ListBox_2', 'item', i - 1, cAux )
      SetProperty( 'Form_PF', 'ListBox_2', 'value', i - 1 )
      DoMethod( 'Form_PF', 'ListBox_2', 'setfocus' )
   endif
Return .T.
/*
*/
*-----------------------------------------------------------------------------*
Function DownFld()
*-----------------------------------------------------------------------------*
   Local i := GetProperty( 'Form_PF', 'ListBox_2', 'value' )
   Local cAux := GetProperty( 'Form_PF', 'ListBox_2', 'item', i )
   Local cAux2 := GetProperty( 'Form_PF', 'ListBox_2', 'item', i + 1 )

   if i < GetProperty( 'Form_PF', 'ListBox_2', 'itemcount' )
      SetProperty( 'Form_PF', 'ListBox_2', 'item', i, cAux2 )
      SetProperty( 'Form_PF', 'ListBox_2', 'item', i + 1, cAux )
      SetProperty( 'Form_PF', 'ListBox_2', 'value', i + 1 )
      DoMethod( 'Form_PF', 'ListBox_2', 'setfocus' )
   Else
      MessageBoxTimeout (padc('Use the UP button !',50 )+CRLF+CRLF;
              +padc("You have reached the bottom of list !!",50),"Error Bottom of list !", MB_ICONSTOP, 2300 )
   endif
Return .T.
/*
*/
*-----------------------------------------------------------------------------*
Function clb_Check(nn)
*-----------------------------------------------------------------------------*
   Local lCheck
   Default nn := Form_PF.ListBox_1.value
   if nn > 0
      lCheck :=  clb_getCheck(nn)
      setproperty('Form_PF','ListBox_1',"CHECKBOXITEM",nn,!lCheck)
   endif
   Form_PF.ListBox_1.Setfocus

return nil
/*
*/
*-----------------------------------------------------------------------------*
function clb_getCheck(nn)
*-----------------------------------------------------------------------------*
return GetProperty('Form_PF','ListBox_1',"CHECKBOXITEM",nn)
/*
*/
*-----------------------------------------------------------------------------*
Procedure  OnPressSpacebar()
*-----------------------------------------------------------------------------*
   if GetProperty('Form_PF',"FOCUSEDCONTROL") == "ListBox_1"
      clb_Check()
   endif
return
/*
*/
*-----------------------------------------------------------------------------*
function cmlb_getItem(nn)
*-----------------------------------------------------------------------------*
return GetProperty('Form_PF','ListBox_1',"ITEM",nn)
/*
*/

#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC ( HMG_INTERACTIVEMOVE )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   if (! IsWindow(hWnd) )
       hWnd = GetFocus();
   keybd_event  (VK_RIGHT, 0, 0, 0);
   keybd_event  (VK_LEFT,  0, 0, 0);
   SendMessage  (hWnd, WM_SYSCOMMAND, SC_MOVE, 0);
   RedrawWindow (hWnd, NULL, NULL, RDW_ERASE | RDW_FRAME | RDW_INVALIDATE |RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW);
}

HB_FUNC ( HMG_INTERACTIVESIZE )
{
   HWND hWnd = (HWND) HB_PARNL (1);
   if (! IsWindow(hWnd) )
       hWnd = GetFocus();
   keybd_event  (VK_DOWN,  0, 0, 0);
   keybd_event  (VK_RIGHT, 0, 0, 0);
   SendMessage  (hWnd, WM_SYSCOMMAND, SC_SIZE, 0);
   RedrawWindow (hWnd, NULL, NULL, RDW_ERASE | RDW_FRAME | RDW_INVALIDATE |RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW);
}

HB_FUNC ( _CONTROLPOS_C_DRAWGRID_ )
{
  int w ;
  int h ;
  int s ;
  int x ;
  int y ;
  int sx ;
  int sy ;
  HWND hWnd =  ( HWND) HB_PARNL( 1 ) ;
  HDC hDC = GetDC( hWnd  );

  w = GetDeviceCaps(hDC , HORZRES ) ;
  h = GetDeviceCaps(hDC , VERTRES ) ;
  s = hb_parni( 2 ) ;
  sx =  hb_parni( 3 ) % s  ;
  if( sx )
     sx = s - sx ;
  sy = hb_parni( 4 ) % s  ;
  if( sy )
     sy = s - sy ;

  for( x=sx ; x < w ; x=x+s )
    {
    for( y=sy ; y < h ; y=y+s)
       {
       if (y >= 65 && y < 70 )
       SetPixel( hDC, x , y , (COLORREF) 0 ) ;
       };
    };

  ReleaseDC( hWnd, hDC ) ;

}

HB_FUNC ( SETWINDOWBRUSH )
{
  hb_retnl( SetClassLong( (HWND) HB_PARNL(1), GCL_HBRBACKGROUND, (LONG) hb_parnl(2) ) );
}

#pragma ENDDUMP


