#include "minigui.ch"
#include "ide.ch"
#include "tsbrowse.ch"

#define MsgYesNo( c, t ) MsgYesNo( c, t, .F. , , .F. )

DECLARE WINDOW Form_1
DECLARE WINDOW ReportEditor
DECLARE WINDOW ProjectBrowser
DECLARE WINDOW ObjectInspector
DECLARE WINDOW Controls
DECLARE WINDOW Loading
//DECLARE WINDOW LogForm

MEMVAR BaseColTimer
MEMVAR BaseHeight
MEMVAR FoundWindow
MEMVAR FoundControl
MEMVAR ControlAtual
MEMVAR VL
MEMVAR xLin
MEMVAR aControls
MEMVAR LinMain

*------------------------------------------------------------*
PROCEDURE LoadFmg()
*------------------------------------------------------------*
   LOCAL X1             AS NUMERIC                    // Pos of At() Search
   LOCAL X2             AS NUMERIC                    // Pos of At() Search
   LOCAL X4             AS STRING                     // Name of .fmg file
   LOCAL X5             AS STRING                     // Content of .fmg file using MemoRead()
   LOCAL X6             AS NUMERIC                    // Nb of Line in X5 ".fmg file"
   LOCAL lTrue          AS LOGICAL
   LOCAL cBackColor     AS STRING
   LOCAL TabName        AS STRING
   LOCAL nValue         AS NUMERIC

   PUBLIC  New_name     AS STRING

   PRIVATE BaseColTimer AS NUMERIC := 10              //
   PRIVATE BaseHeight   AS NUMERIC := 100             //
   PRIVATE FoundWindow  AS LOGICAL                    //
   PRIVATE FoundControl AS LOGICAL                    // Updated in FindControls()
   PRIVATE ControlAtual AS STRING                     //
   PRIVATE VL           AS ARRAY                      // Updated in ShowControls()
   PRIVATE xLin         AS STRING                     //
   PRIVATE aControls    AS ARRAY                      //
   PRIVATE LinMain      AS STRING                     //

   IF IsWindowDefined( Form_1 )
      RELEASE WINDOW Form_1
   ENDIF

   IF IsWindowDefined( ReportEditor )
      IF IsWindowVisible( _hmg_aFormHandles[ GetFormIndex( "ReportEditor" ) ] )
         IF ! MsgYesNo( "Abandon the current report?" )
            RETURN
         ELSE
            ReportEditor.Release
         ENDIF
      ENDIF
   ENDIF

   IF isWindowActive( Form_1 )
      RETURN
   ENDIF

   IF xParam # NIL
      x4 := xParam + ".fmg"
   ELSE
      CurrentForm := ProjectBrowser.xlist_2.Item( ProjectBrowser.xlist_2.Value )
      IF aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] == "<ProjectFolder>\" .OR. Empty( aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] )
         x4 := ProjectFolder + "\" + CurrentForm
         // MsgBox("value1= "+x4)
      ELSE
         x4 := aFmgNames[ ProjectBrowser.xlist_2.Value, 2 ] + CurrentForm
         // MsgBox( "value2= " + x4 )
      ENDIF
   ENDIF

   x5 := MemoRead( x4 )
   // MsgBox( "x5= " + x5 )

   x6 := MLCount( x5, 1000 )
   // MsgBox( "len x6= " + Str( x6 ) )

   IF Empty( x6 )
      RELEASE WINDOW Loading
      RETURN
   ENDIF

   cTextNotes := VerifyNotes( x5, x6 )

   // MsgBox( "x5= " + x5 )

   ObjectInspector.xGrid_1.DisableUpdate
   ObjectInspector.xGrid_2.DisableUpdate

   nTotControl := 0

   ZeroControls()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   aFormDir := Directory( x4 )
   //formcdate := aFormdir[ 1, 3 ]
   //formctime := aFormdir[ 1, 4 ]

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LoadUci()  // UCI

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FoundWindow  := .F.
   FoundControl := .F.

   aControls    := { "DEFINE BUTTON "      , "DEFINE CHECKBOX"   , "DEFINE LISTBOX"    ,"DEFINE COMBOBOX " ,"DEFINE CHECKBUTTON", "DEFINE GRID"      , ;
                     "DEFINE SLIDER"       , "DEFINE SPINNER"    , "DEFINE IMAGE"      ,"DEFINE DATEPICKER","DEFINE TEXTBOX"    , "DEFINE EDITBOX"   , ;
                     "DEFINE LABEL"        , "DEFINE BROWSE"     , "DEFINE RADIOGROUP" ,"DEFINE FRAME"     ,"DEFINE ANIMATEBOX" , "DEFINE HYPERLINK" , ;
                     "DEFINE MONTHCALENDAR", "DEFINE RICHEDITBOX", "DEFINE PROGRESSBAR","DEFINE PLAYER"    ,"DEFINE IPADDRESS"  , "DEFINE BUTTONEX"  , ;
                     "DEFINE COMBOBOXEX"   , "DEFINE TIMEPICKER" , "DEFINE ACTIVEX"    ,"DEFINE GETBOX"    ,"DEFINE BTNTEXTBOX" , "DEFINE HOTKEYBOX" , ;
                     "DEFINE CHECKLABEL"   , "DEFINE CHECKLISTBOX"                                                                                     ;
                   }

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   FOR xLin := 1 TO x6
       DO EVENTS

       A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )

       IF Len( A1 ) # 0
          // MsgBox( "first A1=  " +A1 + "  len A1= "+Str(Len(A1))+ " total= "+Str(x6) + " linha= "+Str(xlin)  )

          IF FoundWindow == .F.
             x1 := At( "DEFINE WINDOW TEMPLATE ", A1 )
             x2 := At( "DEFINE WINDOW"          , A1 )

             IF X1 # 0 .OR. X2 # 0
                FoundWindow := .T.
                VL          := LoadWindow()

                ShowControls()

             ENDIF

          ENDIF

          IF FoundControl == .F.

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "DEFINE MAIN MENU", A1 )

             IF X1 # 0
                LoadMainMenu( x5 )
             ENDIF

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "DEFINE TOOLBAR", A1 )

             IF X1 # 0
                LoadToolbar( x5 )
             ENDIF

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "DEFINE CONTEXT MENU", A1 )

             IF X1 # 0
                LoadContext( x5 )
             ENDIF

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "DEFINE STATUSBAR", A1 )

             IF X1 # 0
                LoadStatus( x5 )
             ENDIF

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "DEFINE NOTIFY MENU", A1 )

             IF X1 # 0
                LoadNotifyMenu( x5 )
             ENDIF

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "DEFINE DROPDOWN MENU", A1 )

             IF X1 # 0
                LoadDropMenu( x5 )
             ENDIF

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "LOAD WINDOW", A1 )

             IF X1 # 0
                LoadPanel( x5 )
             ENDIF

             *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
             x1 := At( "#INCLUDE", A1 )

             IF X1 # 0
                LoadInclude( x5 )
             ENDIF

          ENDIF

          *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          IF FoundWindow .AND. Len( A1 ) # 0
             x1      := At( "DEFINE TAB", A1 )
             // MsgBox( "findig tab em A1= " + A1 )
             TabName := SubStr( A1, X1+1, Len( A1 ) )
             IF X1 # 0
                LoadTab( X5, X6, TabName )
             ENDIF
             // MsgBox( "finding controls out tab in A1= " + A1 )
             FindControls( X5, "control", A1 )
          ENDIF

          IF xParam == NIL
             nValue := Int( ( xLin / x6 ) * 100 )
             // MsgBox("XLIN = " + Str( xLin )+ " nValue = " + Str( nValue ) )
             Loading.Progress_1.Value := nValue
          ENDIF

       ENDIF

   NEXT xLin

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // XLOGFORM()
   IF xParam == NIL
      RELEASE WINDOW Loading
   ENDIF

   lUpdate := .T.

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF nTotControl = 0
      ObjectInspector.xGrid_1.EnableUpdate
      ObjectInspector.xGrid_2.EnableUpdate
   ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF xParam == NIL
      lUpdate := .T.

      DEFINE TIMER Timer_VerifyForm OF Form_1 INTERVAL 1000 ACTION VerifyForm()

      Form_1.Activate

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE InitValues()
*------------------------------------------------------------*
  aItens[ 1] := {"BUTTON"        ,"DEFINE BUTTON"               , "","ROW","","COL","","WIDTH","","HEIGHT","","CAPTION","","ACTION","NIL","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","HELPID","NIL","FLAT",".F.","TABSTOP",".T.","VISIBLE",".T.","TRANSPARENT",".F.","PICTURE","NIL","DEFAULT",".F.","ICON","NIL","MULTILINE",".F.","NOXPSTYLE", ".F.","END BUTTON"}
  aItens[ 2] := {"CHECKBOX"      ,"DEFINE CHECKBOX"             , "","ROW","","COL","","WIDTH","","HEIGHT","","CAPTION","","VALUE",".F.","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","FIELD","","BACKCOLOR","NIL","FONTCOLOR","NIL","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","TRANSPARENT",".F.","LEFTJUSTIFY",".F.","THREESTATE",".F.","AUTOSIZE",".F.","ONENTER","NIL","END CHECKBOX"}
  aItens[ 3] := {"LISTBOX"       ,"DEFINE LISTBOX"              , "","ROW","","COL","","WIDTH","","HEIGHT","","ITEMS",'{""}',"VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","ONDBLCLICK","NIL","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","SORT",".F.","MULTISELECT",".F.","DRAGITEMS",".F.","MULTITAB",".F.","MULTICOLUMN",".F.","END LISTBOX"}
  aItens[ 4] := {"COMBOBOX"      ,"DEFINE COMBOBOX"             , "","ROW","","COL","","WIDTH","","HEIGHT","","ITEMS",'{""}',"VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","SORT",".F.","ONENTER","NIL","ONDISPLAYCHANGE","NIL","DISPLAYEDIT",".F.","ITEMSOURCE","NIL","VALUESOURCE","","LISTWIDTH","","ONLISTDISPLAY","NIL","ONLISTCLOSE","NIL","GRIPPERTEXT","","BREAK",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","UPPERCASE",".F.","LOWERCASE",".F.","NONE",".T.","END COMBOBOX"}
  aItens[ 5] := {"CHECKBUTTON"   ,"DEFINE CHECKBUTTON"          , "","ROW","","COL","","WIDTH","","HEIGHT","","CAPTION","","VALUE",".F.","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","PICTURE","NIL","END CHECKBUTTON"}
  aItens[ 6] := {"GRID"          ,"DEFINE GRID"                 , "","ROW","","COL","","WIDTH","","HEIGHT","","HEADERS","{'Column1','Column2'}","WIDTHS","{60,60}","ITEMS",'{{"",""}}',"VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","DYNAMICBACKCOLOR","NIL","DYNAMICFORECOLOR","NIL","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONDBLCLICK","NIL","ALLOWEDIT",".F.","ONHEADCLICK","NIL","ONCHECKBOXCLICKED","NIL","INPLACEEDIT",'""',"CELLNAVIGATION",".F.","COLUMNCONTROLS","NIL","COLUMNVALID","NIL","COLUMNWHEN","NIL","VALIDMESSAGES","NIL","VIRTUAL",".F.","ITEMCOUNT","NIL","ONQUERYDATA","NIL","MULTISELECT",".F.","NOLINES",".F.","SHOWHEADERS",".T.","NOSORTHEADERS",".F.","IMAGE","NIL","JUSTIFY","NIL","HELPID","NIL","BREAK",".F.","HEADERIMAGE",'""',"NOTABSTOP",".F.","CHECKBOXES",".F.","LOCKCOLUMNS","NIL","PAINTDOUBLEBUFFER",".F.","END GRID"}
  aItens[ 7] := {"SLIDER"        ,"DEFINE SLIDER"               , "","ROW","","COL","","WIDTH","","HEIGHT","","RANGEMIN","1","RANGEMAX","10","VALUE","0","TOOLTIP",'""',"ONCHANGE","NIL","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","NOTICKS","NIL","BACKCOLOR","NIL","ORIENTATION","1","TICKMARKS","2","VERTICAL",".F.","HORIZONTAL",".T.","BOTH",".F.","NONE",".F.","TOP",".F.","BOTTOM",".T.","LEFT",".F.","RIGHT",".T.","ONSCROLL","NIL","END SLIDER"}
  aItens[ 8] := {"SPINNER"       ,"DEFINE SPINNER"              , "","ROW","","COL","","WIDTH","","HEIGHT","","RANGEMIN","1","RANGEMAX","10","VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","WRAP",".F.","READONLY",".F.","INCREMENT","1","BACKCOLOR","NIL","FONTCOLOR","NIL","END SPINNER"}
  aItens[ 9] := {"IMAGE"         ,"DEFINE IMAGE"                , "","ROW","","COL","","WIDTH","","HEIGHT","","PICTURE","","HELPID","NIL","VISIBLE",".T.","STRETCH",".F.","ACTION","NIL","WHITEBACKGROUND",".F.","ONMOUSEHOVER","NIL","ONMOUSELEAVE","NIL","TRANSPARENT",".F.","BACKGROUNDCOLOR","NIL","ADJUSTIMAGE",".F.","TOOLTIP",'""',"END IMAGE"}
  aItens[10] := {"DATEPICKER"    ,"DEFINE DATEPICKER"           , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE",'CToD("")',"FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","ONENTER","NIL","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","SHOWNONE",".F.","UPDOWN",".F.","RIGHTALIGN",".F.","FIELD","","BACKCOLOR","NIL","FONTCOLOR","NIL","DATEFORMAT","","TITLEBACKCOLOR","NIL","TITLEFONTCOLOR","NIL","END DATEPICKER"}
  aItens[11] := {"TEXTBOX"       ,"DEFINE TEXTBOX"              , "","ROW","","COL","","WIDTH","","HEIGHT","","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","ONENTER","NIL","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","READONLY",".F.","RIGHTALIGN",".F.","LOWERCASE",".F.","UPPERCASE",".F.","NONE",".T.","PASSWORD",".F.","MAXLENGTH","0","BACKCOLOR","NIL","FONTCOLOR","NIL","FIELD","NIL","INPUTMASK",'""',"FORMAT",'""',"DATE",".F.","NUMERIC",".F.","CHARACTER",".T.","VALUE",'""',"CASECONVERT",".F.","DATATYPE",".F.","BORDER",".T.","END TEXTBOX"}
  aItens[12] := {"EDITBOX"       ,"DEFINE EDITBOX"              , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE",'""',"FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","READONLY",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","MAXLENGTH","NIL","FIELD","NIL","HSCROLLBAR",".T.","VSCROLLBAR",".T.","BREAK",".F.","END EDITBOX"}
  aItens[13] := {"LABEL"         ,"DEFINE LABEL"                , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE","","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","VISIBLE",".T.","TRANSPARENT",".F.","ACTION","NIL","AUTOSIZE",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","ALIGNMENT","1","LEFTALIGN",".T.","RIGHTALIGN",".F.","CENTERALIGN",".F.","BORDER",".F.","CLIENTEDGE",".F.","HSCROLL",".F.","VSCROLL",".F.","BLINK",".F.","ONMOUSEHOVER","NIL","ONMOUSELEAVE","NIL","END LABEL"}
  aItens[14] := {"BROWSE"        ,"DEFINE BROWSE"               , "","ROW","","COL","","WIDTH","","HEIGHT","","HEADERS","{''}","WIDTHS","{0}","FIELDS","{''}","VALUE","0","WORKAREA","NIL","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","DYNAMICBACKCOLOR","NIL","DYNAMICFORECOLOR","NIL","FONTCOLOR","NIL","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONDBLCLICK","NIL","ALLOWEDIT",".F.","INPLACEEDIT",".F.","ALLOWAPPEND",".F.","INPUTITEMS","NIL","DISPLAYITEMS","NIL","ONHEADCLICK","NIL","WHEN","NIL","VALID","NIL","VALIDMESSAGES","NIL","PAINTDOUBLEBUFFER",".F.","READONLYFIELDS","NIL","LOCK",".F.","ALLOWDELETE",".F.","NOLINES",".F.","IMAGE","NIL","JUSTIFY","NIL","VSCROLLBAR",".T.","HELPID","NIL","BREAK",".F.","HEADERIMAGE","","NOTABSTOP",".F.","DATABASENAME","NIL","DATABASEPATH","NIL","END BROWSE"} && "INPUTMASK","NIL","FORMAT","NIL",
  aItens[15] := {"RADIOGROUP"    ,"DEFINE RADIOGROUP"           , "","ROW","","COL","","WIDTH","","HEIGHT","","OPTIONS","{'Option 1','Option 2'}","VALUE","1","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","TRANSPARENT",".F.","SPACING","25","BACKCOLOR","NIL","FONTCOLOR","NIL","LEFTJUSTIFY",".F.","HORIZONTAL",".F.","READONLY","","END RADIOGROUP"}
  aItens[16] := {"FRAME"         ,"DEFINE FRAME"                , "","ROW","","COL","","WIDTH","","HEIGHT","","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","CAPTION",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","OPAQUE",".F.","INVISIBLE",".F.","TRANSPARENT",".F.","END FRAME"}
  aItens[17] := {"ANIMATEBOX"    ,"DEFINE ANIMATEBOX"           , "","ROW","","COL","","WIDTH","","HEIGHT","","FILE",'""',"HELPID","NIL","TRANSPARENT",".F.","AUTOPLAY",".F.","CENTER",".F.","BORDER",".T.","END ANIMATEBOX"}
  aItens[18] := {"HYPERLINK"     ,"DEFINE HYPERLINK"            , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE",'"http://sourceforge.net/projects/hmgs-minigui"',"ADDRESS",'"http://sourceforge.net/projects/hmgs-minigui"',"FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","AUTOSIZE",".F.","HELPID","NIL","VISIBLE",".T.","HANDCURSOR",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","RIGHTALIGN",".F.","CENTERALIGN",".F.","END HYPERLINK"}
  aItens[19] := {"MONTHCALENDAR" ,"DEFINE MONTHCALENDAR"        , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE",'CToD("")',"FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","NOTODAY",".F.","NOTODAYCIRCLE",".F.","WEEKNUMBERS",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","TITLEBACKCOLOR","NIL","TITLEFONTCOLOR","NIL","BACKGROUNDCOLOR","NIL","TRAILINGFONTCOLOR","NIL","BKGNDCOLOR","NIL","END MONTHCALENDAR"}
  aItens[20] := {"RICHEDITBOX"   ,"DEFINE RICHEDITBOX"          , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE",'""',"FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","READONLY",".F.","BACKCOLOR","NIL","FIELD","NIL","MAXLENGTH","NIL","FILE","NIL","ONSELECT","NIL","PLAINTEXT",".F.","HSCROLLBAR",".T.","VSCROLLBAR",".T.","FONTCOLOR","NIL","BREAK",".F.","ONVSCROLL","NIL","END RICHEDITBOX"}
  aItens[21] := {"PROGRESSBAR"   ,"DEFINE PROGRESSBAR"          , "","ROW","","COL","","WIDTH","","HEIGHT","","RANGEMIN","1","RANGEMAX","10","VALUE","0","TOOLTIP",'""',"HELPID","NIL","VISIBLE",".T.","SMOOTH",".F.","VERTICAL",".F.","BACKCOLOR","NIL","FORECOLOR","NIL","ORIENTATION","1","MARQUEE",".F.","VELOCITY","40","END PROGRESSBAR"}
  aItens[22] := {"PLAYER"        ,"DEFINE PLAYER"               , "","ROW","","COL","","WIDTH","","HEIGHT","","FILE","","HELPID","NIL","NOAUTOSIZEWINDOW",".F.","NOAUTOSIZEMOVIE",".F.","NOERRORDLG",".F.","NOMENU",".F.","NOOPEN",".F.","NOPLAYBAR",".F.","SHOWALL",".F.","SHOWMODE",".F.","SHOWNAME",".F.","SHOWPOSITION",".F.","END PLAYER"}
  aItens[23] := {"IPADDRESS"     ,"DEFINE IPADDRESS"            , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE","{0,0,0,0}","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","END IPADDRESS"}
  aItens[24] := {"BUTTONEX"      ,"DEFINE BUTTONEX"             , "","ROW","","COL","","WIDTH","","HEIGHT","","CAPTION","","PICTURE","","ICON","","ACTION","NIL","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","FONTCOLOR","NIL","VERTICAL",".F.","LEFTTEXT",".F.","UPPERTEXT",".F.","ADJUST",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","NOHOTLIGHT",".F.","FLAT",".F.","NOTRANSPARENT",".F.","NOXPSTYLE",".F.","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","TABSTOP",".T.","HELPID","NIL","VISIBLE",".T.","DEFAULT",".F.","HANDCURSOR",".F.","END BUTTONEX"}
  aItens[25] := {"COMBOBOXEX"    ,"DEFINE COMBOBOXEX"           , "","ROW","","COL","","WIDTH","","HEIGHT","","ITEMS","","ITEMSOURCE","","VALUE","0","VALUESOURCE","","DISPLAYEDIT",".F.","LISTWIDTH","0","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONENTER","NIL","ONDISPLAYCHANGE","NIL","ONLISTDISPLAY","NIL","ONLISTCLOSE","NIL","TABSTOP",".T.","HELPID","NIL","GRIPPERTEXT",'""',"BREAK",".F.","VISIBLE",".T.","IMAGE","","BACKCOLOR","NIL","FONTCOLOR","NIL","IMAGELIST","","END COMBOBOXEX"}
  aItens[26] := {"TIMEPICKER"    ,"DEFINE TIMEPICKER"           , "","ROW","","COL","","WIDTH","","VALUE","","FIELD","","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"SHOWNONE",".F.","UPDOWN",".F.","TIMEFORMAT","","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONENTER","NIL","HELPID","NIL","VISIBLE",".T.","TABSTOP",".T.","END TIMEPICKER"}
  aItens[27] := {"ACTIVEX"       ,"DEFINE ACTIVEX"              , "","ROW","","COL","","WIDTH","","HEIGHT","","PROGID","","END ACTIVEX"}
  aItens[28] := {"GETBOX"        ,"DEFINE GETBOX"               , "","ROW","","COL","","WIDTH","","HEIGHT","","FIELD","","VALUE","NIL","PICTURE",'""',"VALID","NIL","RANGE","NIL","VALIDMESSAGE",'""',"MESSAGE",'""',"WHEN","NIL","READONLY",".F.","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","PASSWORD",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","RIGHTALIGN",".F.","VISIBLE",".T.","TABSTOP",".T.","HELPID","NIL","ACTION","NIL","ACTION2","NIL","IMAGE",'""',"BUTTONWIDTH","0","BORDER",".T.","NOMINUS",".F.","END GETBOX"}

// aItens[29] :={"BTNTEXTBOX"    ,"DEFINE BTNTEXTBOX"           , "","ROW","","COL","","WIDTH","","HEIGHT","","FIELD","","VALUE",'""',"ACTION","NIL","PICTURE",'""',"BUTTONWIDTH","0","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","NUMERIC",".F.","PASSWORD",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","MAXLENGTH","0","UPPERCASE",".F.","LOWERCASE",".F.","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONENTER","NIL","RIGHTALIGN",".F.","VISIBLE",".T.","TABSTOP",".T.","HELPID","NIL","DISABLEEDIT",".F.","CHARACTER",".F.","NONE",".F.", "CASECONVERT", ".F.","END BTNTEXTBOX"}
  aItens[29] := {"BTNTEXTBOX"    ,"DEFINE BTNTEXTBOX"           , "","ROW","","COL","","WIDTH","","HEIGHT","","FIELD","","VALUE",'""',"ACTION","NIL","PICTURE",'""',"BUTTONWIDTH","0","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","NUMERIC",".F.","PASSWORD",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","MAXLENGTH","0","UPPERCASE",".F.","LOWERCASE",".F.","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONENTER","NIL","RIGHTALIGN",".F.","VISIBLE",".T.","TABSTOP",".T.","HELPID","NIL","DISABLEEDIT",".F.","CHARACTER",".F.","NONE",".F.", "CASECONVERT", ".F.","CUEBANNER", "", "END BTNTEXTBOX"}

  aItens[30] := {"HOTKEYBOX"     ,"DEFINE HOTKEYBOX"            , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"ONCHANGE","NIL","HELPID","NIL","VISIBLE",".T.","TABSTOP",".T.","END HOTKEYBOX"}

  aItens[31] := {"CHECKLABEL"    ,"DEFINE CHECKLABEL"           , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE",'"CHECKLABEL"',"ACTION","NIL","ONMOUSEHOVER","NIL","ONMOUSELEAVE","NIL","AUTOSIZE",".F.","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","IMAGE","NIL","HELPID","NIL","VISIBLE",".T.","BORDER",".T.","CLIENTEDGE",".F.","HSCROLL",".F.","VSCROLL", ".F.","TRANSPARENT",".F." ,"BLINK", ".F.","ALIGNMENT", "1", "LEFTALIGN", ".T.","RIGHTALIGN",".F.","CENTERALIGN",".F.","LEFTCHECK",".F.","CHECKED",".F.","END CHECKLABEL"}
  aItens[32] := {"CHECKLISTBOX"  ,"DEFINE CHECKLISTBOX"         , "","ROW","","COL","","WIDTH","","HEIGHT","","ITEMS",'{""}',"VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","TOOLTIP",'""',"ONCHANGE","NIL","ONGOTFOCUS","NIL","ONLOSTFOCUS","NIL","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","BACKCOLOR","NIL","FONTCOLOR","NIL","ONDBLCLICK","NIL","HELPID","NIL","TABSTOP",".T.","VISIBLE",".T.","SORT",".F.","MULTISELECT",".F.","CHECKBOXITEM","{0}","ITEMHEIGHT","0","END CHECKLISTBOX"}

  aItens[33] := {"TIMER"         ,"DEFINE TIMER"                , "","INTERVAL","0","ACTION","NIL","END TIMER"}
  aItens[34] := {"TREE"          ,"DEFINE TREE"                 , "","ROW","","COL","","WIDTH","","HEIGHT","","VALUE","0","FONT","Arial","SIZE","9","TOOLTIP",'""',"ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONDBLCLICK","NIL","NODEIMAGES","NIL","ITEMIMAGES","NIL","NOROOTBUTTON",".F.","HELPID","NIL","BACKCOLOR","NIL","FONTCOLOR","NIL","LINECOLOR","NIL","INDENT","17","ITEMHEIGHT","18","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","BREAK",".F.","ITEMIDS",".F.","END TREE"}
  aItens[35] := {"TAB"           ,"DEFINE TAB"                  , 'AT',',', 'WIDTH','HEIGHT','VALUE','FONT','SIZE','BOLD','ITALIC','UNDERLINE','STRIKEOUT','TOOLTIP','BUTTONS','FLAT','HOTTRACK','VERTICAL','ON CHANGE','BOTTOM','NOTABSTOP','MULTILINE','BACKCOLOR','PAGECOUNT','PAGEIMAGES','PAGECAPTIONS','PAGETOOLTIPS','END TAB'}
  aItens[36] := {"MAINMENU"      ,"DEFINE MAIN MENU"            , 'DEFINE POPUP','MENUITEM','SEPARATOR','ENDPOPUP','ENDMENU'}
  aItens[37] := {"TOOLBAR"       ,"DEFINE TOOLBAR"              , 'BUTTON','END TOOLBAR'}
  aItens[38] := {"CONTEXT MENU"  ,"DEFINE CONTEXT MENU"         , 'MENUITEM','SEPARATOR','END MENU'}
  aItens[39] := {"STATUSBAR"     ,"DEFINE STATUSBAR"            , 'STATUSITEM','DATE','CLOCK','KEYBOARD','END STATUS'}
  aItens[40] := {"NOTIFY MENU"   ,"DEFINE NOTIFY MENU"          , 'MENUITEM','SEPARATOR','END MENU'}
  aItens[41] := {"DROPDOWN MENU" ,"DEFINE DROPDOWN MENU BUTTON" , 'MENUITEM','SEPARATOR','END MENU'}
  aItens[42] := {"TBROWSE"       ,"DEFINE TBROWSE"              , "","ROW","","COL","","WIDTH","","HEIGHT","","HEADERS","{'CODE','FIRST','LAST','MARRIED','BIRTH','BIO'}","COLSIZES","100,100,100,100,100,100","WORKAREA","TEST","FIELDS","'CODE','FIRST','LAST','MARRIED','BIRTH','BIO'","SELECTFILTER","","FOR","","TO","","VALUE","0","FONTNAME",'"Arial"',"FONTSIZE","9","FONTBOLD",".F.","FONTITALIC",".F.","FONTUNDERLINE",".F.","FONTSTRIKEOUT",".F.","TOOLTIP",'""',"BACKCOLOR","NIL","FONTCOLOR","NIL","COLORS","NIL","ONGOTFOCUS","NIL","ONCHANGE","NIL","ONLOSTFOCUS","NIL","ONDBLCLICK","NIL","EDIT",".F.","GRID",".F.","APPEND",".F.","ONHEADCLICK","NIL","WHEN","NIL","VALID","NIL","VALIDMESSAGES","NIL","MESSAGE","","READONLY","NIL","LOCK",".F.","DELETE",".F.","NOLINES",".F.","IMAGE","NIL","JUSTIFY","NIL","HELPID","","BREAK",".F.","END TBROWSE"}
  aItens[43] := {} // UCI
  aItens[44] := {"QHTM"          ,"DEFINE QHTM"                 ,"","ROW","","COL","","WIDTH","","HEIGHT","","VALUE","","FILE","","RESOURCE","","ONCHANGE","NIL","BORDER",".F.","CWIDTH","","CHEIGHT","","ENDPROP"}
  aItens[45] := {"PANEL"         ,"LOAD WINDOW"                 ,"","AT","",",","","WIDTH","","HEIGHT","","ENDPROP"}

RETURN


*------------------------------------------------------------*
FUNCTION FindControls( x5     AS STRING, ;
                       From   AS STRING, ;
                       A1     AS STRING, ;
                       nrPage AS NUMERIC ;
                     )
*------------------------------------------------------------*
  LOCAL Search      AS LOGICAL := .T.
  LOCAL Item        AS NUMERIC
  LOCAL x1          AS NUMERIC
  LOCAL xPos        AS USUAL     //? VarType
  LOCAL ControlName AS STRING

  // MsgBox( "called from " + From)
  // MsgBox( "finding control in A1= " + A1 )

  InitValues()

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  FOR Item := 1 TO 32

      x1 := At( aControls[ Item ], A1 )

      IF x1 # 0
         ControlName := AllTrim( SubStr( A1, Len( aControls[ Item ] ) + 1, Len( A1 ) ) )
         Xpos        := xLoadControl( Item, x5, ControlName )

         IF nrPage # NIL
            // MsgBox( "Xpos= " + Str( xPos ) + " TABNAME= " + From + " NRPAGE= " + Str( NRPage )+ " " + ControlName )
            xConnectTab( xPos, From, NRPage )
         ENDIF

         FoundControl := .T.
         Search       := .F.
         EXIT
      ENDIF

  NEXT ITEM

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  IF Search
     x1 := At( "DEFINE TIMER", A1 )
     IF X1 # 0
        LoadTimer()
        Search := .F.
     ENDIF
  ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  IF Search
     x1 := At( "DEFINE TREE", A1 )
     IF X1 # 0
        ControlName := AllTrim( SubStr( A1, Len( aItens[ 34 ] )+1, Len( A1 ) ) )
        xPos        := LoadTree()

        IF NRPAGE # NIL
          // MsgBox( "xPos= " + Str( xPos) + " TabName= " + From + " NRPage= "+Str( NRPage ) +  " " + ControlName )
          xConnectTab( xPos, FROM, NRPage )
        ENDIF

        Search := .F.
     ENDIF
  ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  IF Search
     x1 := At( "DEFINE TBROWSE", A1 )

     IF X1 # 0
        ControlName := AllTrim( SubStr( A1, Len( aItens[ 42 ] )+1, Len( A1 ) ) )
        xPos        := LoadTbrowse( x5, ControlName )

        IF NRPAGE # NIL
           // MsgBox( "Xpos= " + Str(xPos)+ " TABNAME= " + FROM + " NRPAGE= " + Str(NRPAGE)+ " " + ControlName )
           xConnectTab( xPos, From, NRPage )
        ENDIF
        Search := .F.
     ENDIF
  ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  IF Search
     x1 := At( "LOAD WINDOW", A1 )
     IF X1 # 0
        LoadPanel()
        Search := .F.
     ENDIF
  ENDIF

  *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  IF Search
     LoadControlUCI( x5, From, NRPage )
  ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION LoadWindow()
*------------------------------------------------------------*
   LOCAL aItens
   LOCAL notend
   LOCAL rest
   LOCAL y
   LOCAL y2
   LOCAL x1
   LOCAL Prop1
   LOCAL Prop2
   LOCAL Prop3
   LOCAL xControl
   LOCAL X2
   LOCAL A3
   LOCAL LinMain2
   LOCAL nLastFound
   LOCAL nLine, npos, VHASH

   xProp  := {".T.","NIL",".F.",235,"",".F.",".F.",350,".F.","",".T.",".T.","NIL","NIL","NIL","NIL","","",".F.",140,".T.",".T.","",".T.",".F.",".T.",550,"STANDARD",350,550,"NIL","NIL","NIL"}
   xEvent := {}

   ASize( xEvent, 23 )
   aItens := {"DEFINE WINDOW TEMPLATE AT"," ,","WIDTH","HEIGHT","MINWIDTH","MINHEIGHT","MAXWIDTH","MAXHEIGHT","VIRTUAL WIDTH","VIRTUAL HEIGHT","TITLE"," ICON"," MAIN","CHILD","MODAL","SPLITCHILD","MDI ","MDICHILD","NOSHOW","TOPMOST","PALETTE","NOAUTORELEASE","NOMINIMIZE","NOMAXIMIZE","NOSIZE","NOSYSMENU","NOCAPTION","CURSOR","ON INIT","ON RELEASE","ON INTERACTIVECLOSE","ON MOUSECLICK","ON MOUSEDRAG","ON MOUSEMOVE","ON MOVE","ON SIZE","ON MAXIMIZE","ON MINIMIZE","ON RESTORE","ON PAINT","BACKCOLOR","FONT"," SIZE ","GRIPPERTEXT","BREAK","FOCUSED","NOTIFYICON","NOTIFYTOOLTIP","ON NOTIFYCLICK","ON GOTFOCUS","ON LOSTFOCUS","ON SCROLLUP","ON SCROLLDOWN","ON SCROLLLEFT","ON SCROLLRIGHT","ON HSCROLLBOX","ON VSCROLLBOX","ON DROPFILES","HELPBUTTON","VIRTUALSIZED","ON NOTIFYBALLOONCLICK","_HMGS_FIM"}
   //XLOGFORM()

   // msgbox('len aitens = ' + Str(Len(aitens)) )  && 62
   LinMain   := ""
   LinMain2  := ""
   xControl  := 0
   nTotControl := 0
   nLastFound := 2

   DELETE ITEM ALL FROM XGRID_1 OF ObjectInspector
   ObjectInspector.Title := "Object Inspector [" + CurrentForm + "]"

   FOR y := 2 TO Len( aItens ) - 1

     X1 := At( aItens[ y ], A1 )
       IF X1 > 0
          nLastFound := y
          ********verify end
          Rest := AllTrim( SubStr( A1, x1 + Len( aItens[ y ] ), Len( A1 ) ) )
          //msgbox('rest= ' + rest )
          if Y = 2
             LinMain +=        AllTrim( SubStr( A1, 1,( X1 - 1 ) ) )  + CRLF  + aItens[ nLastFound ]
           // msgbox('LinmainINITIAL= ' + Linmain )
          else
            LinMain += " " +   AllTrim( SubStr( A1, 1,( X1 - 1 ) ) )  + CRLF  + aItens[ nLastFound ]
           //  msgbox('Linmain = ' + LinMain )
          endif
         A1 := Rest
       ELSE
        LinMain2 +=  aItens[ y ] + ' NIL' + CRLF
       ENDIF
   NEXT
   LinMain += " "+ Rest
  // MSGBOX('Linmain = '+CRLF + Linmain )
  //  msgbox( 'Linmain2 = '+CRLF  + Linmain2 )

    LinMain += CRLF + Linmain2
   //  MSGBOX('Linmain FINAL = ' +CRLF + Linmain )

   VL := {}

   //XLOGFORM()

   FOR nLine := 1 TO Len( aItens )-1

      *npos = 0
      A1 :=  MemoLine( LinMain, 1000, nLine, NIL, .T. )
    //  msgbox('nline = ' + Str(nline) + ' a1 = ' + a1 )

       for y := 1 to Len(aItens)
         if y = 2
           npos := At( AllTrim(aItens[ y ]), A1 )
         else
            npos := At( aItens[ y ], A1 )
         endif
      //   msgbox('npos = ' + Str(npos) + CRLF + "A1= "+A1+ CRLF +" y= "+Str(y)+" value= " +aItens[y] )
         if npos = 1 .or. npos = 2
        //    MsgBox("A1= "+A1+ CRLF +" y= "+Str(y)+" value= " +aItens[y] ) && + CRLF  +" len= "+Str(Len(aItens[y])))
            // MsgBox("A1= "+A1 )
            IF y = 43 // POSITION OF " SIZE "
               A2 := AllTrim( SubStr( A1, ( Len( aItens[ y] ) ), ( Len( A1 ) ) ) )
             //  MsgBox("size prop2 A2= "+A2 )
            ELSE
               A2 := AllTrim( SubStr( A1, ( Len( aItens[ y] ) + 1 ),( Len( A1 ) - Len( aItens[ y ] ) ) ) )
             //  MsgBox("A2= "+A2 )
            ENDIF
            exit
         endif
       next

      PROP1 := aItens[ y ]
      PROP2 := A2
      VHASH := PROP2

      IF Prop1            == "TITLE"         .OR. ;
         AllTrim( prop1 ) == "ICON"          .OR. ;
         Prop1            == "CURSOR"        .OR. ;
         Prop1            == "NOTIFYICON"    .OR. ;
         Prop1            == "NOTIFYTOOLTIP"

         IF Prop2 = "NIL"
            Prop2 := '""'
            A2    := '""'
         ENDIF
      ENDIF

      IF Prop1 == "BACKCOLOR" .AND. Upper( A2 ) == "NIL"
         A2 := NIL
         VHASH := A2

      ELSEIF Prop1 == "BACKCOLOR" .AND. Upper( A2 ) # "NIL"
         A2    := {}
         Prop3 := SubStr( Prop2, 2, At(",", Prop2 ) - 1 )
         AAdd(A2, Val( prop3 ) )
         Prop3 := SubStr( Prop2, At( ",", Prop2 ) + 1, RAt( ",", Prop2 ) - 1 )
         AAdd(A2, Val( prop3 ) )
         Prop3 := SubStr( Prop2, RAt( ",",prop2)+1, Len( Prop2 ) - 1 )
         AAdd(A2, Val( prop3 ) )
         VHASH := A2
      ENDIF

      IF Prop1 == "VIRTUALSIZED" .AND. Upper( A2 ) == "NIL"
         IF Val(VLHASH["VIRTUAL WIDTH"]) > Val(VLHASH["WIDTH"]) .OR. Val(VLHASH["VIRTUAL HEIGHT"]) > Val(VLHASH["HEIGHT"])
             A2 := ".T."
             VHASH := A2
         ELSE
            A2 := ".F."
            VHASH := A2
         ENDIF
      ENDIF

      LoadProp( PROP1, PROP2 )
      // MSGBOX('PROP1 = ' + PROP1 + ' PROP2 = ' + PROP2 )
      IF PROP1 = 'DEFINE WINDOW TEMPLATE AT'
        PROP1 := 'ROW'
      ELSEIF PROP1 = ',' .OR. PROP1 = ' ,'
        PROP1 := 'COL'
      ENDIF

      VLHASH[PROP1] := VHASH

   NEXT nLine

RETURN( vl )


*------------------------------------------------------------*
FUNCTION XLoadControl( Item AS NUMERIC, x5 AS STRING, ControlName AS STRING )
*------------------------------------------------------------*
   LOCAL x       AS NUMERIC
   LOCAL xPos    AS NUMERIC
   LOCAL Prop    AS STRING
   LOCAL Value   AS STRING
   LOCAL nValue  AS NUMERIC
   LOCAL X6      AS STRING

   ControlAtual              := Item
   aItens[ ControlAtual, 3 ] := ControlName
   x6                        := MLCount( x5, 1000 )
   LinMain                   := ""
   nTotControl ++
   LinMain                   += A1 + CRLF
   xItens                    := Len( aItens[ ControlAtual ] )
   A1                        := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )  //? xLin where is it declared

   // MsgBox(A1,"A1")

   Prop  := aItens[ Item, 2 ]
   Value := AllTrim( SubStr( A1, Len( aItens[ Item, 2 ] ) + 2, Len( A1 ) ) )

    //MsgBox("1-PROP= "+PROP)
    //MsgBox("1-VALUE= " +VALUE)

   xPos := AScan( aItens[ Item ], Prop )
     //MsgBox("XPOS= " + Str(XPOS) )
     aItens[ Item, xPos+ 1 ]:= Value
     //MsgBox("AITENS+1= "+aItens[ITEM,XPOS+1] )
   DO WHILE .T.
      xLin ++
      A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
      IF A1 = aItens[ Item, Len( aItens[ Item ] ) ]
         EXIT
      ENDIF

     //MSGBOX(' nTotControl = ' + Str(nTotControl) )
     //IF nTotControl = 72
     //   MsgBox(A1,"A1")
     //ENDIF

      xPos  := At(" ", A1)
      Prop  := SubStr( A1, 1, xPos - 1 )
      Value := AllTrim( SubStr( A1, xPos + 1, Len( A1 ) ) )

      //IF nTotControl= 72
      //   MsgBox( "PROP= "  + PROP  )
      //   MsgBox( "VALUE= " + VALUE )
      //ENDIF

      xPos  := AScan( aItens[ Item ], PROP )

      //IF nTotControl = 72
      //   MsgBox("XPOS= "+Str(XPOS) + " XPOS+1 VALUE = "+ VALUE)
      //ENDIF

      IF xPos > 1
         aItens[ Item, xPos + 1 ] := Value
      ENDIF
   ENDDO

   FOR X := 4 TO Len( aItens[ Item ] ) - 1 STEP 2
       LinMain += aItens[ Item, x ] + " " + aItens[ Item, x+1 ] + CRLF
       // MsgBox( "LinMain= " + LinMain )
   NEXT X

   LinMain += aItens[ Item, Len( aItens[ Item ] ) ]
   // MsgBox("LinMain= "+ LinMain)

   // SaveControlVal()

   SaveControlVal2() // IN TEST

   LinMain := ""

   IF xParam = NIL
      nValue := Int( ( xLin / x6 ) * 100 )
      // MsgBox( "XLIN = " + Str( xLin )+ " nValue = " + Str( nValue ) )
      Loading.Progress_1.Value := nValue
   ENDIF

RETURN( nTotControl )


*------------------------------------------------------------*
PROCEDURE LoadInclude()
*------------------------------------------------------------*
  //? LoadInclude( X5 ) is called with a parameter but not
  //? Not declare here

  AAdd( aInclude, A1 )
RETURN


*------------------------------------------------------------*
PROCEDURE LoadPanel()
*------------------------------------------------------------*
  LOCAL y       AS NUMERIC
  LOCAL A3      AS STRING
  LOCAL X1      AS NUMERIC

  LinMain      := ""
  ControlAtual := 45
  aItens[ ControlAtual ] := { "PANEL", "LOAD WINDOW", "AT", ",", "WIDTH", "HEIGHT" }

  nTotControl++

  // MsgBox( "A1= " + A1 )

  //? A1 is not declare here searching in previous function/procedure
  // in FindControls A1 is a parameter making it a Local parameter not passed to LoadTree()
  // Is X1 assigned with a bad value ?

  FOR Y := 3 TO 6
      X1 := At( aItens[ ControlAtual, y ], A1 )
      IF X1 # 0
         A3      := SubStr( A1, 1 ,( x1 - 1 ) )
         A1      := SubStr( A1, x1, Len( A1 ) )
         LinMain += A3 + CRLF
       ENDIF
  NEXT Y

  LinMain += A1

  // MsgBox("XLinMain= " + LinMain)

  SaveControlVal()

  LinMain := ""

RETURN


*------------------------------------------------------------*
PROCEDURE LoadTimer()
*------------------------------------------------------------*
  LOCAL y       AS NUMERIC
  LOCAL X1      AS NUMERIC
  LOCAL A3      AS STRING

  LinMain      := ""
  ControlAtual := 33
  aItens[ ControlAtual ] := { "TIMER", "DEFINE TIMER", "INTERVAL", "ACTION" }

  nTotControl ++

  //? A1 is not declare here searching in previous function/procedure
  // in FindControls A1 is a parameter making it a Local parameter not passed to LoadTimer()
  // Is X1 assigned with a bad value ?

  FOR Y := 3 TO 4
      X1 := At( aItens[ ControlAtual, y ], A1 )
      IF X1 # 0
         A3      := SubStr( A1, 1 ,( x1 - 1 ) )
         A1      := SubStr( A1, x1, Len( A1 ) )
         LinMain += A3 + CRLF
       ENDIF
  NEXT Y

  LinMain += A1

  SaveControlVal()

  LinMain := ""

RETURN


*------------------------------------------------------------*
FUNCTION LoadTree()
*------------------------------------------------------------*
  LOCAL y        AS NUMERIC
  LOCAL X1       AS NUMERIC
  LOCAL A3       AS STRING
  LOCAL LinMain1 AS STRING  := ""

  LinMain      := ""
  ControlAtual := 34
  aItens[ ControlAtual ] := {"TREE","DEFINE TREE","AT",",","WIDTH","HEIGHT","VALUE","FONT","SIZE","TOOLTIP","ON GOTFOCUS","ON CHANGE";
                   ,"ON LOSTFOCUS","ON DBLCLICK","NODEIMAGES","ITEMIMAGES","NOROOTBUTTON","HELPID","BACKCOLOR","FONTCOLOR",;
                    "LINECOLOR","INDENT","ITEMHEIGHT","FONTBOLD","FONTITALIC","FONTUNDERLINE","FONTSTRIKEOUT","BREAK","ITEMIDS",;
                    "BOLD","ITALIC","UNDERLINE","STRIKEOUT","END TREE"}

  nTotControl ++

  //? A1 is not declare here searching in previous function/procedure
  // in FindControls A1 is a parameter making it a Local parameter not passed to LoadTree()
  // Is X1 assigned with a bad value ?

  FOR Y := 3 TO ControlAtual  // ADDED
      X1 := At( aItens[ ControlAtual, y ], A1 )
      IF X1 # 0
         A3       := SubStr( A1, 1, x1 - 1 )
         LinMain  += A3 + CRLF
         LinMain  += LinMain1
         LinMain1 := ""
         // MsgBox( LinMain, "17-33" )
         A1 := SubStr( A1, X1, Len( A1 ) )
         // MsgBox( A1, "rest" )
      ELSE   // acumula prop
         LinMain1 += aItens[ ControlAtual, y ] + " NIL" + CRLF
         // MsgBox( LinMain1, "LinMain1" )
      ENDIF
  NEXT Y

  IF Len( A1 ) > 0
     LinMain += A1 + CRLF
  ENDIF

  IF Len( LinMain1 ) > 0
     LinMain += LinMain1
  ENDIF

  // MsgBox(LinMain,"LinMain-final")
  SaveControlVal()

  LinMain := ""

RETURN( nTotControl )


*------------------------------------------------------------*
PROCEDURE LoadTab( x5 AS STRING, x6 AS USUAL, TabName AS STRING ) //? X6 is it used
*------------------------------------------------------------*
   LOCAL Y              AS NUMERIC
   LOCAL A3             AS STRING
   LOCAL TempnrControl  AS USUAL     //? VarType
   LOCAL NRPages        AS NUMERIC
   LOCAL XPageImages    AS ARRAY     //? Invalid Hungarian
   LOCAL XPageCaptions  AS ARRAY     //? Invalid Hungarian
   LOCAL XPageTooltips  AS ARRAY     //? Invalid Hungarian
   LOCAL xToolTip       AS NUMERIC
   LOCAL xCapt          AS STRING
   LOCAL NewnrControl   AS USUAL      //? Vartype
   LOCAL ZPageImages    AS STRING
   LOCAL ZPageCaptions  AS STRING
   LOCAL ZPageTooltips  AS STRING
   LOCAL x              AS NUMERIC
   LOCAL X1             AS NUMERIC
   LOCAL X2             AS NUMERIC
   LOCAL X3             AS NUMERIC
   LOCAL X4             AS NUMERIC
   LOCAL TempLinMain    AS STRING
   LOCAL nrLines        AS NUMERIC
   LOCAL xPage          AS NUMERIC   //? Invalid Hungarian
   LOCAL LinMain2       AS STRING    := ""

   LinMain      := ""
   ControlAtual := 35
   aItens[ ControlAtual ]   := { "TAB","DEFINE TAB","AT",",", "WIDTH","HEIGHT","VALUE","FONT","SIZE" ,;
                     "BOLD","ITALIC","UNDERLINE","STRIKEOUT"                             ,;
                     "TOOLTIP","BUTTONS","FLAT","HOTTRACK","VERTICAL"                    ,;
                     "ON CHANGE","BOTTOM","NOTABSTOP","MULTILINE","BACKCOLOR"            ,;
                     "PAGECOUNT","PAGEIMAGES","PAGECAPTIONS","PAGETOOLTIPS","END TAB"     ;
                   }
   nTotControl ++

   **************************
   FOR Y := 3 TO 23

       X1 := At( aItens[ ControlAtual, y ], A1 )

       IF X1 # 0
          A3 := SubStr( A1, 1, ( x1 - 1 ) )
          A1 := SubStr( A1, x1, Len( A1 ) )
          // MsgBox("A1 = " + A1)
          LinMain  += A3 + CRLF
          // MsgBox("1-LinMain= "+LinMain)

          IF Len( LinMain2 ) > 0
             LinMain  := LinMain + LinMain2
             LinMain2 := ""
          ENDIF
          // MsgBox("2-LinMain= "+LinMain)
       ELSE
          LinMain2 := LinMain2 + aItens[ ControlAtual, y ] + iif( y=23, " NIL", " .F." ) + CRLF
          // MsgBox("storing LinMain2= "+LinMain2)
       ENDIF
   NEXT Y

   IF Len( A1 ) > 0
      LinMain := LinMain + A1 + CRLF
      A1      := ""
   ENDIF

   IF Len( LinMain2 ) > 0
      LinMain  := LinMain + LinMain2
      LinMain2 := ""
   ENDIF

   TempLinMain := LinMain

   // MsgBox("tab= " + LinMain )

   SaveControlVal() // parcial

   nrLines        := MLCount( LinMain )
   TempnrControl  := nTotControl

   // MsgBox( "name tab = " + xArray[ nTotControl, 3 ] )

   TabName        := xArray[ nTotControl, 3 ]
   NRPages        := 0
   XPageImages    := {}
   XPageCaptions  := {}
   XPageToolTips  := {}

   DO WHILE .T.

       DO EVENTS

       A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )

       IF Len( A1 ) > 0
          // MsgBox("line in tab = "+A1 + " nr= "+ Str( xLin ) )
          X2 := At( "END TAB",A1)
          IF X2 > 0
             EXIT
          ENDIF

          X2 := At( "END PAGE", A1 )
          IF X2 = 0
             X2 := At( "PAGE", A1 )
             IF X2 > 0
                NRPages ++

                X3 := At( "IMAGE", A1 )
                IF X3 > 0
                   *********************
                   X4 := At( "TOOLTIP", A1 )
                   IF X4 = 0
                      xPage    := AllTrim( SubStr( A1, X3+6, Len( A1 ) ) )
                      // MsgBox("xpage1= "+xpage)
                      xToolTip := ""
                      xCapt    := AllTrim( SubStr( A1, X2+4, (X3-1)-(x2+4)))
                   ELSE
                      xPage    := AllTrim( SubStr( A1, X3+6, (X4-1)-(x3+5)))
                      // MsgBox("xpage2= "+xpage)
                      xCapt    := AllTrim( SubStr( A1, X2+4, (X3-1)-(x2+4)))
                      // MsgBox("XCAPT= "+XCAPT)
                      xToolTip := AllTrim( SubStr( A1, X4+7, Len(A1) ) )
                      // MsgBox("XTOOLTIP= "+XTOOLTIP)
                   ENDIF

                   AAdd( XPageImages  , NoQuota( xPage ) )
                   AAdd( XPageCaptions, XCapt            )
                   AAdd( XPageTooltips, XTooltip         )

                   _AddTabPage( TabName, "Form_1", nrPages, NoQuota( XCapt ), XPage, noquota( XToolTip ) )

                ELSE
                   X4 := At( "TOOLTIP", A1 )
                   IF X4 = 0
                      XToolTip := ""
                      XCapt    := AllTrim( SubStr( A1, X2+4, Len( A1 ) ) )
                   ELSE
                      XCapt    := AllTrim( SubStr( A1, X2+4, ( x4 - 1 ) - ( x2 + 4 ) ) )
                      XToolTip := AllTrim( SubStr( A1, X4+7, Len( A1 ) ) )
                   ENDIF

                   AAdd( XPageImages  , ""       )
                   AAdd( XPageCaptions, XCapt    )
                   AAdd( XPageToolTips, XToolTip )
                   // MsgBox("xcapt= "+xcapt)

                   _AddTabPage( TabName, "Form_1", nrPages, NoQuota( XCapt ), "", NoQuota( XToolTip ) )
                ENDIF
            ENDIF

            *********find controls
            // MsgBox("xlin= "+ Str(xlin)+ " x2= >0-nao procurar "+ Str(x2) )
            IF x2 = 0
               FindControls( x5, TabName, A1, nrPages )
            ENDIF
            // MsgBox("xlin= "+ Str(xlin))
            ****************conext to tab
          ENDIF
       ENDIF

       // find PAGE and PAGE IMAGES
       xLin ++
    ENDDO

   ControlAtual  := 35

   ZPageImages   := "{"
   ZPageCaptions := "{"
   ZPageToolTips := "{"

   FOR x := 1 TO NRPages
       IF Len( AllTrim( XPageImages[ x ] ) ) = 0
          ZPageImages += "'',"
       ELSE
          ZPageImages += "'" + AllTrim( XPageImages[ x ] ) + "',"
       ENDIF

       ZPageCaptions += AllTrim( XPageCaptions[ x ] ) + ","

       IF Len( AllTrim( XPageToolTips[ x ] ) ) = 0
          ZPageToolTips += "'',"
       ELSE
          ZPageToolTips += AllTrim( XPageToolTips[ x ] ) + ","
       ENDIF
   NEXT x

   ZPageImages   := SubStr( ZPageImages  , 1, ( Len( ZPageImages   ) - 1 ) ) + "}"
   ZPageCaptions := SubStr( ZPageCaptions, 1, ( Len( ZPageCaptions ) - 1 ) ) + "}"
   ZPageToolTips := SubStr( ZPageToolTips, 1, ( Len( ZPageToolTips ) - 1 ) ) + "}"

   LinMain := ""
   LinMain += "PAGECOUNT "    + hb_ntos( NRPages ) + CRLF
   LinMain += "PAGEIMAGES "   + ZPageImages        + CRLF
   LinMain += "PAGECAPTIONS " + ZPageCaptions      + CRLF
   LinMain += "PAGETOOLTIPS " + ZPageToolTips      + CRLF
   LinMain += "END TAB"

   // MsgBox("LinMain-rest = "+LinMain)

   NewnrControl := nTotcontrol
   nTotControl    := TempnrControl

   SaveControlVal( nrLines )

   nTotControl    := NewnrControl
   LinMain      := ""

RETURN


*------------------------------------------------------------*
FUNCTION LoadTbrowse( x5 AS STRING, ControlName AS STRING )
*------------------------------------------------------------*
   LOCAL zItens   AS NUMERIC
   LOCAL P1       AS NUMERIC
   LOCAL P2       AS NUMERIC
   LOCAL P3       AS NUMERIC
   LOCAL A2       AS STRING
   LOCAL A3       AS NUMERIC
   LOCAL xFound   AS LOGICAL
   LOCAL xItem    AS NUMERIC
   LOCAL xitens   AS NUMERIC

   LinMain      := ""
   ControlAtual := 42
   aItens[ControlAtual]   := {"TBROWSE","DEFINE TBROWSE","AT",",","WIDTH","HEIGHT","HEADERS","COLSIZES","WORKAREA","FIELDS","SELECTFILTER","FOR","TO ","VALUE","FONTNAME","FONTSIZE","FONTBOLD","FONTITALIC","FONTUNDERLINE","FONTSTRIKEOUT","TOOLTIP","BACKCOLOR","FONTCOLOR","COLORS","ONGOTFOCUS","ONCHANGE","ONLOSTFOCUS","ONDBLCLICK","EDIT","GRID","APPEND","ONHEADCLICK","WHEN","VALID","VALIDMESSAGES","MESSAGE","READONLY","LOCK","DELETE","NOLINES","IMAGE","JUSTIFY","HELPID","BREAK"," BOLD"," ITALIC"," UNDERLINE"," STRIKEOUT","ON GOTFOCUS","ON CHANGE","ON LOSTFOCUS","ON DBLCLICK","ON HEADCLICK"," NAME"," SIZE","CELLED","CELL ","END TBROWSE"}

   nTotControl++

   LinMain += ExtractComma( A1 ) + CRLF
   xitens  := Len( aItens[ ControlAtual ] )
   A2      := A1 + CRLF
   xLin++

   A1      := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
   A1      := ExtractComma( A1 )
   P1      := At( ",", A1 )
   A2      := A2 + SubStr(A1,1,P1-1 ) + CRLF + SubStr( A1, P1, 1 ) + "  " + SubStr( A1, P1+1, Len( A1 ) ) + CRLF

   DO WHILE .T.
      xLin++
      A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
      A1 := ExtractComma( A1 )
      // MsgBox(A1,"A1")
      P1 := At( "SELECTFILTER", A1 )

      IF P1 > 0
         P2 := At( "FOR", A1 )
         IF P2 > 0

            A2 += SubStr( A1, 1, P2-1 ) + CRLF
            A1 := SubStr( A1, P2, Len( A1 ) )
            P3 := At( "TO", A1 )

            IF P3 > 0
               A2 += SubStr( A1, 1, P3-1 )       + CRLF
               A2 += SubStr( A1, P3, Len( A1 ) ) + CRLF
            ELSE
               A2 += A1 + CRLF
            ENDIF

         ELSE
            A2 += A1 + CRLF
         ENDIF

      ELSE
         A2 := A2 + A1 + CRLF
      ENDIF

      IF A1 = aItens[ ControlAtual, xItens ]
         EXIT
      ENDIF
   ENDDO

   // MsgBox( A2, "A2" )

   FOR zItens := 3 TO xItens

       xFound := .F.

       FOR xItem := 2 to MLCount( A2 )
           A1 := AllTrim( MemoLine( A2, 1000, xItem, NIL, .T. ) )
           // MsgBox( A1," A1-linha" )
           // MsgBox( aItens[ ControlAtual,zItens ], "procurando" )
           A3 := At( aItens[ ControlAtual, zItens ], A1 )
           // MsgBox(Str(A3), "A3-posicao" )

           IF A3 = 1
              xFound  := .T.
              LinMain += A1 + CRLF
              xItem   := MLCount( A2 )
              // MsgBox(LinMain, "LinMain-1" )
           ENDIF
       NEXT xItem

       IF xFound = .F.
          LinMain += aItens[ ControlAtual, zItens ] + " NIL" + CRLF
          // MsgBox( LinMain, "LinMain-2" )
       ENDIF
   NEXT

   // MsgBox( LinMain, "LinMain-final" )
   SaveControlVal()

   LinMain := ""

RETURN( nTotControl )


*------------------------------------------------------------*
PROCEDURE LoadMainMenu( X5 AS STRING )
*------------------------------------------------------------*
   LOCAL lTrue    AS LOGICAL
   LOCAL X4       AS NUMERIC

   LinMain      := ""
   ControlAtual := 36
   aItens[ControlAtual]   := {"MAINMENU","DEFINE MAIN MENU","DEFINE POPUP","MENUITEM","SEPARATOR","END POPUP","END MENU"}

   AAdd( aMenu, A1 )

   LinMain += A1 + CRLF
   lTrue   := .T.

   DO WHILE lTRUE
      xLin ++
      // A1 := AllTrim(MemoLine(x5,1000,Xlin,,.T.))
      A1 := MemoLine( X5, 1000, xLin, NIL, .T. )

      X4 := At( aItens[ ControlAtual, 3 ], A1 )  // define popup
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aMenu, A1 )
         *  cCaption := SubStr(A1,13,Len(A1))
         // MsgBox(CCAPTION)
         *  AAdd(ARRAYMENU,{"POPUP",cCaption})
      ENDIF

      X4 := At( aItens[ ControlAtual, 4 ], A1 ) // menuitem
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aMenu, A1 )
         * x5 := At("ACTION",A1)
         * C1Caption := SubStr(A1,x4+9,x5-1)
         * c1Action := SubStr(A1,x5+7)
         // MsgBox(C1CAPTION, c1Action)
         *  AAdd(ARRAYMENU,{"ITEM",c1Caption,c1Action})
      ENDIF

      X4 := At( aItens[ ControlAtual, 5 ], A1 )  // separator
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aMenu, A1 )
         // AAdd(ARRAYMENU,{"SEPARATOR","SEPARATOR"})
      ENDIF

      X4 := At( aItens[ ControlAtual, 6 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aMenu, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 7 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF   //
         AAdd( aMenu, A1 )         //
         lTrue := .F.
         LOOP
      ENDIF

   ENDDO

   // MsgBox( "menu = " + LinMain )

RETURN


*------------------------------------------------------------*
PROCEDURE LoadToolBar( x5 AS STRING )
*------------------------------------------------------------*
   LOCAL lTrue    AS LOGICAL
   LOCAL X4       AS NUMERIC

   LinMain      := ""
   ControlAtual := 37
   //xItem        := 1
   aItens[ControlAtual]   := { "TOOLBAR","DEFINE TOOLBAR","BUTTON","END TOOLBAR" }

   AAdd( aToolbar, A1 )

   LinMain += A1 + CRLF
   lTRUE   := .T.

   DO WHILE lTrue
      xLin ++
      A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
      X4 := At( aItens[ ControlAtual, 3 ], A1 )

      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aToolbar, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 4 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         // MsgBox( LinMain )
         AAdd( aToolbar, A1 )
         lTrue := .F.
         LOOP
      ENDIF

   ENDDO

RETURN


*------------------------------------------------------------*
PROCEDURE LoadContext( x5 AS STRING )
*------------------------------------------------------------*
   LOCAL lTrue    AS LOGICAL
   LOCAL X4       AS NUMERIC

   LinMain      := ""
   ControlAtual := 38
   //xItem        := 1
   aItens[ControlAtual]   := {"CONTEXT MENU","DEFINE CONTEXT MENU","MENUITEM","SEPARATOR","END MENU"}

   AAdd( aContext, A1 )

   LinMain += A1 + CRLF
   lTRUE   := .T.

   DO WHILE lTRUE
      xLin ++

      A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )

      X4 := At( aItens[ ControlAtual, 3 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aContext, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 4 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aContext, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 5 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aContext, A1 )
         lTRUE := .F.
         LOOP
      ENDIF

   ENDDO

RETURN


*------------------------------------------------------------*
FUNCTION LoadStatus( x5 AS STRING )
*------------------------------------------------------------*
   LOCAL lTrue    AS LOGICAL
   LOCAL X4       AS NUMERIC

   LinMain      := ""
   ControlAtual := 39
   //xItem        := 1
   aItens[ControlAtual]   := { "STATUSBAR","DEFINE STATUSBAR","STATUSITEM","DATE","CLOCK","KEYBOARD","PROGRESSITEM","END STATUS" }

   AAdd( aStatus, A1 )

   LinMain += A1 + CRLF
   //MSGBOX('A1=  ' + A1 + '  X5 = ' + X5 )
   lTrue := .T.

   DO WHILE lTrue
      xLin ++
      A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )

      X4 := At( aItens[ ControlAtual, 3 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aStatus, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 4 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aStatus, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 5 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aStatus, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 6 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aStatus, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 7 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aStatus, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 8 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aStatus, A1 )
         lTrue := .F.
         LOOP
      ENDIF

   ENDDO

    //MsgBox("aStatus= "+CRLF +LinMain )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION LoadNotifyMenu( x5 AS STRING )
*------------------------------------------------------------*
   LOCAL lTrue   AS LOGICAL
   LOCAL X4      AS NUMERIC

   LinMain        := ""
   ControlAtual   := 40
   //xItem          := 1
   aItens[ControlAtual]     := { "NOTIFY MENU","DEFINE NOTIFY MENU","MENUITEM","SEPARATOR","END MENU" }

   AAdd( aNotify, A1 )

   LinMain += A1 + CRLF
   lTRUE   := .T.

   DO WHILE lTrue
      XLIN ++
      A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
      X4 := At( aItens[ ControlAtual, 3 ], A1 )

      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aNotify, A1 )
      ENDIF

      X4 := At( aItens[ ControlAtual, 4 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aNotify, A1 )
      ENDIF

      X4 := At(aItens[ ControlAtual, 5 ], A1 )
      IF X4 > 0
         LinMain += A1 + CRLF
         AAdd( aNotify, A1 )
         lTrue := .F.
         LOOP
      ENDIF
   ENDDO

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION LoadDropMenu( x5 AS STRING )
*------------------------------------------------------------*
  LOCAL lTrue    AS LOGICAL
  LOCAL X4       AS NUMERIC

  LinMain      := ""
  ControlAtual := 41
  //xItem        := 1
  aItens[ControlAtual]   := { "DROPDOWN MENU","DEFINE DROPDOWN MENU BUTTON","MENUITEM","SEPARATOR","END MENU" }

  AAdd( aDropDown, A1 )

  LinMain += A1  + CRLF
  lTRUE   := .T.

  DO WHILE lTRUE
     XLIN ++
     A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )

     X4 := At( aItens[ControlAtual, 3 ], A1 )
     IF X4 > 0
        LinMain+= A1 + CRLF
        AAdd( aDropDown, A1 )
     ENDIF

     X4 := At( aItens[ControlAtual, 4 ], A1 )
     IF X4 > 0
        LinMain += A1 + CRLF
        AAdd( aDropDown, A1 )
     ENDIF

     X4 := At( aItens[ControlAtual, 5 ], A1 )
     IF X4 > 0
        LinMain += A1 + CRLF
        AAdd( aDropDown, A1 )
        lTRUE := .F.
        LOOP
     ENDIF

  ENDDO

RETURN( NIL )


*------------------------------------------------------------*
PROCEDURE LoadControlUCI( x5, FROM, NRPAGE AS NUMERIC )
*------------------------------------------------------------*
  LOCAL nPos AS  NUMERIC
  LOCAL xPos AS  NUMERIC
  LOCAL lTrue
  LOCAL Value
  LOCAL Prop
  LOCAL ControlName
  LOCAL cValue
  LOCAL A1

  // LinMain   := ""
  ControlAtual := 43
  ControlName  := NIL

  A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )

  IF Len( A1 ) > 0
     FOR nPos := 1 TO Len( aUciControls )
         cValue := "DEFINE "+ Upper( aUciControls[ nPos ] )
         // MsgBox("CVALUE= " + cValue )

         IF At( cValue, A1 ) > 0

            ControlName := AllTrim(SubStr(A1,At(CVALUE,A1)+Len(CVALUE),Len(A1)))
            // MsgBox("CONTROL UCI -NAME= "+ControlName)
            nTotControl++

            // LinMain += A1 + CRLF
            lTRUE := .T.

            UCISaveControlVal( nPos )

            xPos := AScan( aItens[ControlAtual], cValue )
            aItens[ControlAtual, xPos + 1 ] := ControlName
            DO WHILE lTrue
               xLin ++
               A1 := AllTrim( MemoLine( x5, 1000, xLin, NIL, .T. ) )
               // MsgBox("A1= " + A1)
               IF Len( A1 ) > 0
                  IF At( "END " + Upper( AUCICONTROLS[ nPos ] ), A1 ) = 0
                     // LinMain += A1 + CRLF
                     ********************
                     xPos  := At(" ",A1)
                     Prop  := AllTrim( SubStr( A1, 1, xPos - 1 ) )
                     Value := AllTrim( SubStr( A1, xPos, Len( A1 ) ) )
                     // MsgBox("PROP= "+ PROP+ " VALUE = "+ VALUE)
                     xPos  := AScan( aItens[ ControlAtual ], Prop )

                     IF xPos > 1
                        // MsgBox("FOUND " +  Str(XPOS) + " "+aItens[ControlAtual,XPOS] )
                        aItens[ControlAtual, xPos + 1 ] := Value
                        // MsgBox(aItens[ControlAtual,XPOS] + " = " +VALUE )
                     ELSE
                        // MsgBox("XPOS= "+Str(XPOS) + " NOT FOUND ")
                     ENDIF
                  ELSE
                     // LinMain+= A1  +CRLF
                     lTrue := .F.
                     // MsgBox("LinMain= "+LinMain)
                     // UCISAVECONTROLVAL(npos)
                     SaveControlVal2()
                     // LinMain := ""
                     LOOP

                  ENDIF

               ENDIF

            ENDDO

         ENDIF

     NEXT npos
  ENDIF

  IF NRPAGE # NIL
     IF NRPAGE > 0
        nPos := nTotControl
        // MsgBox("Xpos= "+Str(xpos))
        // MsgBox(" TABNAME= "+FROM )
        // MsgBox("VALTYPE= " + ValType(NRPAGE) )
        // MsgBox(" NRPAGE= "+Str(NRPAGE) )
        // MsgBox("  "+ControlName )
        xConnectTab( nPos, FROM, NRPAGE )
        //ProcessContainers(ControlName)
     ENDIF
  ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE ShowControls()
*------------------------------------------------------------*
  LOCAL h
  LOCAL BaseRow
  LOCAL BaseCol
  LOCAL BaseWidth
  LOCAL BaseHeight


  IF ! IsWindowDefined( Form_1 )

     IF Val(VLHASH["VIRTUAL WIDTH"]) > Val(VLHASH["WIDTH"]) .OR.   Val(VLHASH["VIRTUAL HEIGHT"]) > Val(VLHASH["HEIGHT"])

        LOAD WINDOW FORM_2   AS FORM_1

        SetProperty( "FORM_1", "ROW"   , Val( VLHASH["ROW"] ) )
        SetProperty( "FORM_1", "COL"   , Val( VLHASH["COL"] ) )
        SetProperty( "FORM_1", "WIDTH" , Val( VLHASH["WIDTH"] ) )
        SetProperty( "FORM_1", "HEIGHT", Val( VLHASH["HEIGHT"] ) )
        SetProperty( "FORM_1", "VIRTUAL WIDTH" , Val( VLHASH["VIRTUAL WIDTH"] ) )
        SetProperty( "FORM_1", "VIRTUAL HEIGHT", Val( VLHASH["VIRTUAL HEIGHT"] ) )
     ELSE
        LOAD WINDOW FORM_1

        SetProperty( "FORM_1", "ROW"   , Val( VLHASH["ROW"] ) )
        SetProperty( "FORM_1", "COL"   , Val( VLHASH["COL"] ) )
        SetProperty( "FORM_1", "WIDTH" , Val( VLHASH["WIDTH"] ) )
        SetProperty( "FORM_1", "HEIGHT", Val( VLHASH["HEIGHT"] ) )
     ENDIF

  ENDIF

   SetProperty("FORM_1","TITLE",noquota(VLHASH["TITLE"]))

  IF VLHASH["BACKCOLOR"] # NIL
     SetProperty( "FORM_1", "BACKCOLOR", VLHASH["BACKCOLOR"] )
  ENDIF

  IF LenUci > 0   // UCI
     Controls.xCombo_1.Enabled := .T.
  ENDIF

  lChanges   := .F.

  _DisableMenuItem( "PtaB", "Form_1" )

  h          := GetFormHandle( DesignForm )
  BaseRow    := GetWindowRow( h )
  BaseCol    := GetWindowCol( h )
  BaseWidth  := GetWindowWidth( h )
  BaseHeight := GetWindowHeight( h )

  Controls.Statusbar.Item( 4 ) := "r:" + AllTrim( Str( BaseRow   ) ) + " c:" + AllTrim( Str( BaseCol    ) )
  Controls.Statusbar.Item( 5 ) := "w:" + AllTrim( Str( BaseWidth ) ) + " h:" + AllTrim( Str( BaseHeight ) )

  ObjectInspector.xCombo_1.DeleteAllitems
  ObjectInspector.xCombo_1.AddItem( "Form" )
  ObjectInspector.xCombo_1.Value := 1

  ObjectInspector.xGrid_1.DisableUpdate
  ObjectInspector.xGrid_2.DisableUpdate

  LoadFormProps()

RETURN


*------------------------------------------------------------*
Procedure ShowControls2( nCtrl AS NUMERIC )
*------------------------------------------------------------*
   LOCAL cBackColor
   LOCAL cFontColor
   LOCAL x
   LOCAL cPictureName
   LOCAL aName
   LOCAL cName
   LOCAL aHeaders
   LOCAL acOptions

   LOCAL cCtrlType    AS STRING  //:=          xArray[ nCtrl,  1 ]
   LOCAL cCtrlName    AS STRING  //:= AllTrim( xArray[ nCtrl,  3 ] )
   LOCAL nCtrlRow     AS NUMERIC //:=          xArray[ nCtrl,  5 ]
   LOCAL nCtrlCol     AS NUMERIC //:=          xArray[ nCtrl,  7 ]
   LOCAL nCtrlWidth   AS NUMERIC //:= Val(     xArray[ nCtrl,  9 ] )
   LOCAL nCtrlHeight  AS NUMERIC //:= Val(     xArray[ nCtrl, 11 ] )
   LOCAL cCtrlCaption AS STRING  //:= AllTrim( NoQuota( xArray[ nCtrl, 13 ] ) )

   LOCAL ControlName  AS STRING  //:= cCtrlName

   //aBrowseAC( xArray, "xArray - ShowControls2()" )

   lUpdate := .F.

   // MsgBox( "show CONTROL = " + Str( nCtrl ) )
   ObjectInspector.xCombo_1.AddItem( xArray[ nCtrl, 3 ] )  // name of control

   cCtrlType    :=          xArray[ nCtrl,  1 ]
   cCtrlName    := AllTrim( xArray[ nCtrl,  3 ] )
   IF cCtrlType <> "TIMER"
   nCtrlRow     := Val(     xArray[ nCtrl,  5 ] )
   nCtrlCol     := Val(     xArray[ nCtrl,  7 ] )
   nCtrlWidth   := Val(     xArray[ nCtrl,  9 ] )
   nCtrlHeight  := Val(     xArray[ nCtrl, 11 ] )
   IF ISCHARACTER( NoQuota( xArray[ nCtrl, 13 ] ) )
      cCtrlCaption := AllTrim( NoQuota( xArray[ nCtrl, 13 ] ) )
   ENDIF
   ENDIF

   ControlName  := cCtrlName

   DO CASE
   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "BUTTON"
        // MsgBox( "VALUE 45= " + Upper( xArray[ nCtrl, 45 ] ) )

        IF Upper( xArray[ nCtrl, 45 ] ) # "NIL"
           // MsgBox( "POSITION 1-BITMAP" )
           cPictureName := FindImageName( xArray[nctrl,45], "bmp" )
           @ nCtrlRow, nCtrlCol BUTTON   &CONTROLNAME OF FORM_1  PICTURE cPictureName              WIDTH nCtrlWidth HEIGHT nCtrlHeight ACTION cpreencheGrid() TOOLTIP ControlName

        ELSEIF Upper( xArray[ nCtrl, 49 ] ) # "NIL"
           // MsgBox( "POSITION 2-ICON" )
           cPictureName := FindImageName( xArray[ nCtrl, 49 ], "ico" )
           @ nCtrlRow, nCtrlCol BUTTON   &CONTROLNAME OF FORM_1 ICON cPictureName                  WIDTH nCtrlWidth HEIGHT nCtrlHeight ACTION cpreencheGrid() TOOLTIP ControlName

        ELSEIF Upper(xArray[ nCtrl, 51 ] ) # ".F."
           @ nCtrlRow, nCtrlCol BUTTON   &CONTROLNAME OF FORM_1 CAPTION cCtrlCaption               WIDTH nCtrlWidth HEIGHT nCtrlHeight ACTION cpreencheGrid() TOOLTIP ControlName MULTILINE

        ELSE
           // MsgBox( "POSITION 3-NO IMAGE" )
           @ nCtrlRow, nCtrlCol BUTTON   &CONTROLNAME OF FORM_1 CAPTION cCtrlCaption               WIDTH nCtrlWidth HEIGHT nCtrlHeight ACTION cpreencheGrid() TOOLTIP ControlName
        ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "CHECKBOX"
        cBackColor := xArray[nctrl,39]
        @ nCtrlRow, nCtrlCol CHECKBOX    &CONTROLNAME OF FORM_1 CAPTION cCtrlCaption               WIDTH nCtrlWidth HEIGHT nCtrlHeight TOOLTIP ControlName BACKCOLOR &cBackColor ON CHANGE cpreencheGrid()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "LISTBOX"
        aName := { { ControlName ,""} }
        cBackColor := xArray[nctrl,37]
        @ nCtrlRow, nCtrlCol LISTBOX     &CONTROLNAME OF FORM_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight FONT xArray[nctrl,17]  SIZE Val(xArray[nctrl,19]) TOOLTIP  CONTROLNAME BACKCOLOR &cBackColor ON CHANGE cpreencheGrid()
        FILLITEMS(CONTROLNAME,NCTRL)

   CASE cCtrlType == "CHECKLISTBOX"
        aName := { { ControlName ,""} }
        cBackColor := xArray[nctrl,37]
        @ nCtrlRow, nCtrlCol LISTBOX     &CONTROLNAME OF FORM_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight FONT xArray[nctrl,17]  SIZE Val(xArray[nctrl,19]) TOOLTIP  CONTROLNAME BACKCOLOR &cBackColor ON CHANGE cpreencheGrid()
        FILLITEMS(CONTROLNAME,NCTRL)

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "COMBOBOX"
        cName :=  { ControlName }
        @ nCtrlRow, nCtrlCol COMBOBOXEX  &CONTROLNAME OF FORM_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight ITEMS cName VALUE 1 FONT xArray[nctrl,17]  SIZE Val(xArray[nctrl,19])  TOOLTIP CONTROLNAME NOTABSTOP ON GOTFOCUS cpreencheGrid( This.ToolTip )
        FILLITEMS(CONTROLNAME,NCTRL)

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "CHECKBUTTON"
         IF Upper(xArray[nctrl,43]) # "NIL"
            cPictureName := FindImageName( xArray[nctrl,43], "bmp" )
            @ nCtrlRow, nCtrlCol CHECKBUTTON  &CONTROLNAME OF FORM_1 PICTURE cPictureName               WIDTH nCtrlWidth HEIGHT nCtrlHeight TOOLTIP ControlName ON CHANGE cpreencheGrid()
         ELSE
            @ nCtrlRow, nCtrlCol CHECKBUTTON  &CONTROLNAME OF FORM_1 CAPTION cCtrlCaption               WIDTH nCtrlWidth HEIGHT nCtrlHeight TOOLTIP ControlName ON CHANGE cpreencheGrid()
         ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "GRID"
        aName := { { ControlName ,""} }
        @ nCtrlRow, nCtrlCol GRID  &CONTROLNAME OF FORM_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight HEADERS {"",""} WIDTHS {120,120}  ITEMS aName TOOLTIP ControlName BACKCOLOR &(xArray[nctrl,63]) NOTABSTOP FONT xArray[nctrl,21] SIZE Val(xArray[nctrl,23]) ON GOTFOCUS cpreencheGrid()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "IMAGE"
        IF Len( cCtrlCaption ) > 0
           cPictureName := FindImageName( cCtrlCaption, "bmp" )
           @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1    CAPTION  cCtrlCaption PICTURE cPictureName WIDTH nCtrlWidth HEIGHT nCtrlHeight VERTICAL ADJUST NOHOTLIGHT  ACTION cpreencheGrid()  TOOLTIP CONTROLNAME
        ELSE
           @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1    CAPTION  cCtrlCaption PICTURE "BITMAP48"   WIDTH nCtrlWidth HEIGHT nCtrlHeight VERTICAL ADJUST NOHOTLIGHT  ACTION cpreencheGrid()  TOOLTIP CONTROLNAME
        ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "ANIMATEBOX"
        @ nCtrlRow, nCtrlCol LABEL       &CONTROLNAME OF FORM_1 WIDTH nCtrlWidth HEIGHT nCtrlHeight VALUE ControlName  BORDER  FONT "Arial" SIZE 9 action {||ControlFocus(),cpreencheGrid()} TOOLTIP CONTROLNAME

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "DATEPICKER"
        @ nCtrlRow, nCtrlCol DATEPICKER  &CONTROLNAME OF FORM_1 WIDTH nCtrlWidth HEIGHT nCtrlHeight TOOLTIP Controlname FONT xArray[nctrl,15] SIZE Val(xArray[nctrl,17])  ON GOTFOCUS cpreencheGrid()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "TEXTBOX"
        cBackColor := xArray[nctrl,55]
        CFONTCOLOR := xArray[nctrl,57]
        IF ValType( &cBackColor ) = "A" .AND. Len( &cBackColor ) > 1
           @ nCtrlRow, nCtrlCol LABEL &ControlName OF FORM_1  VALUE xArray[nctrl,3]  ACTION {||ControlFocus(),cpreencheGrid()} WIDTH nCtrlWidth  HEIGHT nCtrlHeight   TOOLTIP CONTROLNAME BACKCOLOR Str2Array(cBackColor) FONTCOLOR Str2Array(CFONTCOLOR) CLIENTEDGE
        ELSE
           @ nCtrlRow, nCtrlCol LABEL &ControlName OF FORM_1  VALUE xArray[nctrl,3]  ACTION {||ControlFocus(),cpreencheGrid()} WIDTH nCtrlWidth  HEIGHT nCtrlHeight   TOOLTIP CONTROLNAME BACKCOLOR &cBackColor FONTCOLOR &CFONTCOLOR CLIENTEDGE
        ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "BTNTEXTBOX"
        IF AllTrim(xArray[nctrl,19]) != '""'
           cPictureName := FindImageName(AllTrim(xArray[nctrl,19]),"bmp")
           @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1    CAPTION  AllTrim(xArray[nctrl,3]) PICTURE cPictureName  WIDTH nCtrlWidth HEIGHT nCtrlHeight LEFTTEXT FLAT NOHOTLIGHT NOXPSTYLE ACTION cpreencheGrid()  TOOLTIP CONTROLNAME  BACKCOLOR &(xArray[nctrl,41]) //WHITE
        ELSE
           @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1    CAPTION  AllTrim(xArray[nctrl,3]) PICTURE "BITMAP58"    WIDTH nCtrlWidth HEIGHT nCtrlHeight LEFTTEXT FLAT NOHOTLIGHT NOXPSTYLE ACTION cpreencheGrid()  TOOLTIP CONTROLNAME  BACKCOLOR &(xArray[nctrl,41]) //WHITE
        ENDIF

    CASE cCtrlType == "CHECKLABEL"
        IF AllTrim(xArray[nctrl,35]) != '""'
           cPictureName := FindImageName(AllTrim(xArray[nctrl,35]),"bmp")
           @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1    CAPTION  AllTrim(xArray[nctrl,3]) PICTURE cPictureName  WIDTH nCtrlWidth HEIGHT nCtrlHeight LEFTTEXT FLAT NOHOTLIGHT NOXPSTYLE ACTION cpreencheGrid()  TOOLTIP CONTROLNAME  BACKCOLOR &(xArray[nctrl,31]) //WHITE
        ELSE
           @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1    CAPTION  AllTrim(xArray[nctrl,3]) PICTURE "BITMAP58"    WIDTH nCtrlWidth HEIGHT nCtrlHeight LEFTTEXT FLAT NOHOTLIGHT NOXPSTYLE ACTION cpreencheGrid()  TOOLTIP CONTROLNAME  BACKCOLOR &(xArray[nctrl,31]) //WHITE
        ENDIF



   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "HOTKEYBOX"
        @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1 CAPTION AllTrim(xArray[nctrl,3]) PICTURE "BITMAP48" WIDTH nCtrlWidth HEIGHT nCtrlHeight VERTICAL ADJUST NOHOTLIGHT  ACTION cpreencheGrid()  TOOLTIP CONTROLNAME

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "EDITBOX"
        @ nCtrlRow, nCtrlCol LABEL &ControlName OF FORM_1 VALUE xArray[nctrl,3] ACTION {||ControlFocus(),cpreencheGrid()} WIDTH nCtrlWidth HEIGHT nCtrlHeight TOOLTIP CONTROLNAME BACKCOLOR Str2Array(xArray[nctrl,43]) CLIENTEDGE HSCROLL VSCROLL

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "LABEL"
        IF xArray[nctrl,39] # "NIL"
           cBackColor := xArray[nctrl,39]
        ELSE
           cBackColor := "{228,228,228}"
        ENDIF

        DEFINE LABEL    &ControlName
          PARENT        Form_1
          ROW           nCtrlRow
          COL           nCtrlCol
          WIDTH         nCtrlWidth
          HEIGHT        nCtrlHeight
          VALUE         cCtrlCaption
          FONTNAME      xArray[15]
          FONTSIZE      Val(xArray[nctrl,17])
          ACTION        {||ControlFocus(),cpreencheGrid()}
          TOOLTIP       ControlName
          BACKCOLOR     Str2Array(cBackColor)
          FONTCOLOR     Str2Array(xArray[nctrl,41])
          FONTBOLD      &(xArray[nctrl,21])
          FONTITALIC    &(xArray[nctrl,23])
          FONTUNDERLINE &(xArray[nctrl,25])
          FONTSTRIKEOUT &(xArray[nctrl,27])
          TRANSPARENT   &(xArray[nctrl,33])
          BORDER        &(xArray[nctrl,51])
          AUTOSIZE      &(xArray[nctrl,37])
          IF xArray[nctrl,47] = ".T."
             RIGHTALIGN .T.
          ELSEIF xArray[nctrl,49] = ".T."
             CENTERALIGN .T.
          ENDIF
        END LABEL

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "PLAYER"
        @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1 PICTURE "BITMAP49"  WIDTH 120 HEIGHT nCtrlHeight VERTICAL ADJUST NOHOTLIGHT ACTION cpreencheGrid() TOOLTIP CONTROLNAME

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "PROGRESSBAR"
        @ nCtrlRow, nCtrlCol LABEL  &ControlName OF FORM_1    WIDTH nCtrlWidth HEIGHT nCtrlHeight VALUE ControlName  BORDER  FONT "Arial" SIZE 9 ACTION {||ControlFocus(),cpreencheGrid()} TOOLTIP ControlName BACKCOLOR &(xArray[nctrl,29])

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "RADIOGROUP"
        IF "{" $ xArray[nctrl,13]            // e um array                    // Renaldo
           acOPTIONS := &( xArray[nctrl,13] )
        ELSE                                 // e uma variavel array          // Renaldo
           acOPTIONS := { xArray[nctrl,13], xArray[nctrl,13] }                // Renaldo
        ENDIF

        IF xArray[nctrl,49] = ".F."
           @ nCtrlRow, nCtrlCol RADIOGROUP &CONTROLNAME OF FORM_1 OPTIONS acOPTIONS VALUE 1 WIDTH nCtrlWidth SPACING Val(xArray[nctrl,41]) BACKCOLOR &(xArray[nctrl,43]) ON CHANGE  cpreencheGrid("RADIOGROUP") TOOLTIP ControlName
        ELSE
           @ nCtrlRow, nCtrlCol RADIOGROUP &CONTROLNAME OF FORM_1 OPTIONS acOPTIONS VALUE 1 WIDTH nCtrlWidth SPACING Val(xArray[nctrl,41]) BACKCOLOR &(xArray[nctrl,43]) ON CHANGE  cpreencheGrid("RADIOGROUP") TOOLTIP ControlName HORIZONTAL
        ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "SLIDER"
        IF xArray[nctrl,33] = "2"
           IF xArray[nctrl,35] = "1"
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL BOTH
           ELSEIF xArray[nctrl,35] = "2"
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL LEFT
           ELSEIF xArray[nctrl,35] = "3"
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL NOTICKS
           ELSE
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid() VERTICAL
           ENDIF
        ELSE
           IF xArray[nctrl,35] = "1"
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid() BOTH
           ELSEIF xArray[nctrl,35] = "3"
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid() NOTICKS
           ELSEIF xArray[nctrl,35] = "4"
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid() TOP
           ELSE
              @ nCtrlRow, nCtrlCol SLIDER  &CONTROLNAME OF FORM_1 RANGE 1,10 VALUE Val(xArray[nctrl,17]) BACKCOLOR &(xArray[nctrl,31]) TOOLTIP ControlName  ON CHANGE cpreencheGrid()
           ENDIF
        ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "SPINNER"
        cBackColor := xArray[nctrl,51]
        @ nCtrlRow, nCtrlCol LABEL &ControlName OF FORM_1  VALUE xArray[nctrl,3]  ACTION {||ControlFocus(),cpreencheGrid()} WIDTH nCtrlWidth HEIGHT nCtrlHeight  TOOLTIP CONTROLNAME BACKCOLOR &cBackColor  CLIENTEDGE VSCROLL

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "FRAME"
        IF xArray[nctrl,25] # "NIL"
           // Update Caption
           cCtrlCaption := AllTrim( NoQuota( xArray[ nCtrl, 25 ] ) )

           IF xArray[nctrl,27] # "NIL"
              cBackColor := xArray[nctrl,27]
              // MsgBox("CONTROLNAME= "+CONTROLNAME + " cBackColor= "+cBackColor )
              // LOGFORM.LIST_1.AddItem("caption-1 "+xArray[nctrl,25] )
              @ nCtrlRow, nCtrlCol FRAME  &CONTROLNAME OF FORM_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight  CAPTION cCtrlCaption FONT xArray[nctrl,13] SIZE Val(xArray[nctrl,15]) BACKCOLOR &cBackColor
           ELSE
               //LOGFORM.LIST_1.AddItem("caption-2 "+xArray[nctrl,25] )
              @ nCtrlRow, nCtrlCol FRAME  &CONTROLNAME OF FORM_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight  CAPTION cCtrlCaption FONT xArray[nctrl,13] SIZE Val(xArray[nctrl,15])
           ENDIF
        ELSE
           //LOGFORM.LIST_1.AddItem("caption-3 "+xArray[nctrl,25] )
           @ nCtrlRow, nCtrlCol FRAME     &CONTROLNAME OF FORM_1     WIDTH nCtrlWidth HEIGHT nCtrlHeight
        ENDIF

        IF xArray[nctrl,17] = ".T."
           SetProperty( "FORM_1", CONTROLNAME, "FONTBOLD", .T. )
        ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "BROWSE"
        aName    := { { "", "" } }
        aHeaders := { ControlName, "" }
        @ nCtrlRow, nCtrlCol GRID         &CONTROLNAME OF FORM_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight  HEADERS aHeaders  WIDTHS {120,120} ITEMS aName TOOLTIP CONTROLNAME BACKCOLOR &(xArray[nctrl,73]) FONT xArray[nctrl,23] SIZE Val(xArray[nctrl,25])  ON GOTFOCUS cpreencheGrid()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "HYPERLINK"
        @ nCtrlRow, nCtrlCol LABEL        &CONTROLNAME OF FORM_1 VALUE "http://sourceforge.net/projects/hmgs-minigui" AUTOSIZE FONT xArray[17] SIZE Val(xArray[nctrl,19]) WIDTH nCtrlWidth HEIGHT nCtrlHeight  UNDERLINE FONTCOLOR {0,0,255} ACTION {||ControlFocus(),cpreencheGrid()} TOOLTIP CONTROLNAME BACKCOLOR &(xArray[nctrl,39])

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "MONTHCALENDAR"
        @  nCtrlRow, nCtrlCol BUTTONEX    &ControlName OF Form_1 PICTURE "BITMAP47"   WIDTH nCtrlWidth HEIGHT nCtrlHeight VERTICAL ADJUST NOHOTLIGHT ACTION cpreencheGrid()  TOOLTIP CONTROLNAME

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "RICHEDITBOX"
        cBackColor := xArray[nctrl,43]
        CFONTCOLOR := xArray[nctrl,59]
        @ nCtrlRow, nCtrlCol RICHEDITBOX  &CONTROLNAME OF FORM_1 VALUE CONTROLNAME WIDTH nCtrlWidth HEIGHT nCtrlHeight TOOLTIP CONTROLNAME BACKCOLOR &cBackColor FONTCOLOR &CFONTCOLOR ON GOTFOCUS cpreencheGrid()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "IPADDRESS"
        @ nCtrlRow, nCtrlCol LABEL        &CONTROLNAME OF FORM_1 VALUE xArray[nctrl,3] BORDER WIDTH nCtrlWidth HEIGHT nCtrlHeight TOOLTIP CONTROLNAME ACTION {||ControlFocus(),cpreencheGrid()}

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "TREE"
        DEFINE TREE &ControlName OF Form_1 AT nCtrlRow, nCtrlCol WIDTH nCtrlWidth HEIGHT nCtrlHeight BACKCOLOR &(xArray[nctrl,37]) TOOLTIP ControlName ON GOTFOCUS cpreencheGrid()
          NODE "Item 1" ID 10
            TREEITEM "Item 1.1" ID 11
            TREEITEM "Item 1.2" ID 12
            TREEITEM "Item 1.3" ID 13
          END NODE
          NODE "Item 2" ID 20
            TREEITEM "Item 2.1" ID 21
            TREEITEM "Item 2.2" ID 22
            TREEITEM "Item 2.3" ID 23
          END NODE
        END TREE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "TIMER"
        @ BaseHeight-iif(Len(aMenu)>0.OR.Len(aStatus)>0,94,80),BaseColTimer  BUTTON &ControlName OF Form_1 PICTURE "BITMAP34"  FLAT ACTION cpreencheGrid() WIDTH 32 HEIGHT 32 TOOLTIP CONTROLNAME
        BaseColTimer += 40

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "TAB"
        cBackColor := xArray[nctrl,45]
        IF xArray[ nCtrl, 29 ]= ".T."
           DEFINE TAB &ControlName OF Form_1 AT nCtrlRow, nCtrlCol WIDTH nCtrlWidth HEIGHT nCtrlHeight FONT xArray[nctrl,15] SIZE Val(xArray[nctrl,17]) TOOLTIP Controlname BACKCOLOR &cBackColor  BUTTONS ON CHANGE {||ControlFocus(), cpreencheGrid()}
        ELSE
           DEFINE TAB &ControlName OF Form_1 AT nCtrlRow, nCtrlCol WIDTH nCtrlWidth HEIGHT nCtrlHeight FONT xArray[nctrl,15] SIZE Val(xArray[nctrl,17]) TOOLTIP Controlname BACKCOLOR &cBackColor  ON CHANGE {||ControlFocus(), cpreencheGrid()}
        ENDIF
        END TAB

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "BUTTONEX"
        IF xArray[ nCtrl, 15 ] # "NIL" .AND. ! Empty( xArray[ nCtrl, 15 ] )   // Renaldo
           cPictureName := FindImageName( AllTrim( xArray[ nCtrl, 15 ] ), "bmp" )
           IF xArray[nctrl,35] = ".F."
              @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1  CAPTION  cCtrlCaption  PICTURE cPictureName  WIDTH nCtrlWidth HEIGHT nCtrlHeight   ACTION cpreencheGrid()   FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP CONTROLNAME     BACKCOLOR WHITE     // Renaldo
           ELSE
              @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1  CAPTION  cCtrlCaption  PICTURE cPictureName  WIDTH nCtrlWidth HEIGHT nCtrlHeight   ACTION cpreencheGrid()   FONT "MS Sans serif"   SIZE 9    BOLD   VERTICAL  TOOLTIP CONTROLNAME     BACKCOLOR WHITE
           ENDIF

        ELSEIF xArray[nctrl,17]# "NIL" .AND. !Empty(xArray[nctrl,17])   // Renaldo
           cPictureName := FindImageName(AllTrim(xArray[nctrl,17]),"ico")
           @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1   CAPTION  cCtrlCaption  ICON    cPictureName  WIDTH nCtrlWidth HEIGHT nCtrlHeight   ACTION cpreencheGrid()   FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP CONTROLNAME     BACKCOLOR WHITE     // Renaldo

        ELSE
           @  nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1  CAPTION  cCtrlCaption  PICTURE "BITMAP51"    WIDTH nCtrlWidth HEIGHT nCtrlHeight   ACTION cpreencheGrid()   FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP CONTROLNAME     BACKCOLOR WHITE     // Renaldo
        ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "COMBOBOXEX"
        @ nCtrlRow, nCtrlCol COMBOBOXEX &ControlName OF Form_1 ITEMS {"one","two","three"} VALUE 1  WIDTH nCtrlWidth TOOLTIP ControlName ON GOTFOCUS cpreencheGrid( This.ToolTip) IMAGE {"BITMAP52","BITMAP53","BITMAP54"} NOTABSTOP

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "GETBOX"
        @ nCtrlRow, nCtrlCol LABEL      &ControlName OF FORM_1 VALUE xArray[nctrl,3]  ACTION {||ControlFocus(),cpreencheGrid()} WIDTH nCtrlWidth HEIGHT nCtrlHeight   TOOLTIP CONTROLNAME BACKCOLOR WHITE CLIENTEDGE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "TIMEPICKER"
        @ nCtrlRow, nCtrlCol TIMEPICKER &ControlName OF FORM_1 WIDTH nCtrlWidth TOOLTIP CONTROLNAME   ON GOTFOCUS cpreencheGrid()

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "ACTIVEX"
        @ nCtrlRow, nCtrlCol BUTTONEX   &ControlName OF FORM_1 CAPTION  cCtrlCaption  WIDTH nCtrlWidth HEIGHT nCtrlHeight ACTION cpreencheGrid()   FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP CONTROLNAME     BACKCOLOR WHITE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "TBROWSE"
        CFILE := System.TempFolder + "\Test.dbf"
        USE &CFILE ALIAS TEST SHARED
        @ nCtrlRow, nCtrlCol TBROWSE &ControlName OF Form_1  WIDTH nCtrlWidth HEIGHT nCtrlHeight ;
          HEADERS  "Code","First","Last","Birth","Bio"   WIDTHS 50,150,150,100,200  FIELDS Test->Code,Test->First,Test->Last,Test->Birth,Test->Bio ;
          WORKAREA "TEST" TOOLTIP CONTROLNAME BACKCOLOR &(xArray[nctrl,43]) FONTCOLOR &(xArray[NCTRL,45]) ON GOTFOCUS cpreencheGrid()
        AAdd( aTbrowse[1], ControlName )
        AAdd( aOtbrowse[1], &ControlName )
        // MsgBox(" len= "+Str(Len(atbrowse[1]) ) )
        // MsgBox("valtype tbrowse= "+ValType(&(atbrowse[ 1, Len(atbrowse[1])])) )

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE cCtrlType == "PANEL"
        @ nCtrlRow, nCtrlCol BUTTONEX &ControlName OF Form_1 PICTURE "BITMAP63"  WIDTH nCtrlWidth HEIGHT nCtrlHeight VERTICAL ADJUST NOHOTLIGHT ACTION cpreencheGrid()  TOOLTIP CONTROLNAME

   ENDCASE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   IF Len( aUCIControls ) > 0
      FOR X := 1 TO Len( aUCIControls )
          // MsgBox("x= "+Str(x)+ " cCtrlType= " +cCtrlType+ " Upper(AUCICONTROLS[X])= " +Upper(AUCICONTROLS[X]) )
          IF cCtrlType == Upper( aUCIControls[ x ] )
             // MsgBox("ucicontrol nr= " +Str(nctrl)+" CONTROLNAME= "+CONTROLNAME)
             @ nCtrlRow, nCtrlCol BUTTONEX &ControlName  OF FORM_1 CAPTION  AllTrim(xArray[nctrl,3])  WIDTH nCtrlWidth HEIGHT nCtrlHeight ACTION {||ControlFocus(),UCIFillGrid(this.name)}    FONT "MS Sans serif"   SIZE 9    BOLD   LEFTTEXT  TOOLTIP CONTROLNAME     BACKCOLOR WHITE
          ENDIF
      NEXT X
   ENDIF

   ObjectInspector.xGrid_1.EnableUpdate
   ObjectInspector.xGrid_2.EnableUpdate
   lupdate := .T.

RETURN


*------------------------------------------------------------*
Procedure FillItems( ControlName AS STRING, nCtrl AS NUMERIC  )
*------------------------------------------------------------*
  LOCAL xArraycombo AS ARRAY
  LOCAL x           AS NUMERIC
  LOCAL cValue      AS STRING

  IF At( "->", xArray[ nCtrl, 13 ] ) > 0
     ADD ITEM ControlName TO &ControlName OF FORM_1

  ELSEIF At( "{", xArray[ nCtrl, 13 ] ) > 0 .AND. ValType( &( xArray[ nCtrl, 13 ] ) ) == "A" .AND. Len( &( xArray[ nCtrl, 13 ] ) ) > 0
     DoMethod( "Form_1", ControlName, "DELETEALLITEMS" )
     xArrayCombo := &(xArray[ nCtrl, 13] )

     for x := 1 TO Len( xArrayCombo )
         cValue := xArrayCombo[ x ]
         IF Len( AllTrim( cvalue ) ) = 0
            cValue := ControlName
         ENDIF
         // MsgBox( "item= " + Str( x ) + " =" + cValue )
         DoMethod( "Form_1", ControlName, "ADDITEM", cValue )
     next x

     SetProperty( "Form_1", ControlName, "VALUE", 1 )

  ELSE
     ADD ITEM ControlName TO &ControlName OF FORM_1
  ENDIF

RETURN


*------------------------------------------------------------*
FUNCTION NoQuota( Param AS STRING )
*------------------------------------------------------------*
  LOCAL cRet AS STRING

  IF Right( Param, 1 ) = '"' .AND. Left( Param, 1 ) = '"' .OR. Right( Param, 1 ) = "'" .AND. Left( Param, 1 ) = "'"
     cRet := SubStr( Param, 2, Len( Param ) - 2 )
  ELSE
     cRet := Param
  ENDIF

RETURN( cRet )


*------------------------------------------------------------*
FUNCTION ExtractComma( Param AS STRING )
*------------------------------------------------------------*
  LOCAL cLine AS STRING := Param

  IF Right( cLine, 1 ) = ";"
     cLine := Left( cLine, Len( cLine )- 1 )
  ENDIF

RETURN( cLine )


*------------------------------------------------------------*
PROCEDURE SaveToIni( Param1 AS STRING, Param2 AS STRING )
*------------------------------------------------------------*
  BEGIN INI FILE cIniFile
    SET SECTION "wVIRTUAL" ENTRY Param1 TO Param2
  END INI
RETURN


*------------------------------------------------------------*
FUNCTION GetVirtualFormWidth()
*------------------------------------------------------------*
  LOCAL RetVal AS NUMERIC := 0

  BEGIN INI FILE cIniFile
    GET RETVAL SECTION "wVIRTUAL" ENTRY "WIDTH"
  END INI

  RetVal += iif( retval < 550, 600, 100 )

RETURN( RetVal )


*------------------------------------------------------------*
FUNCTION GetVirtualFormHeight()
*------------------------------------------------------------*
  LOCAL RetVal AS NUMERIC := 0

  BEGIN INI FILE cIniFile
     GET RETVAL SECTION "wVIRTUAL" ENTRY "HEIGHT"
  END INI

  RetVal += iif( RetVal < 350, 400, 100 )

RETURN( RetVal )


*------------------------------------------------------------*
PROCEDURE LoadProp( xProp1 AS STRING, xProp2 AS STRING )      //OPT
*------------------------------------------------------------*
   xProp1 := AllTrim( Upper( xProp1 ) )
   IF xProp1 == "TITLE" .OR. Left( xProp1, 2 ) == "ON"
      xProp2 := AllTrim( xProp2 )
   ELSE
      xProp2 := AllTrim( Upper( xProp2 ) )
   ENDIF

   IF xProp1 == "DEFINE WINDOW TEMPLATE AT" .OR. xProp1 == "ROW"
      xProp[ 20 ] := xProp2
   ENDIF

   IF xProp1 == ","  .OR. xProp1 == "COL"
      xProp[ 4 ] := xProp2
   ENDIF

   IF xProp1 == "WIDTH"
      xProp[ 27 ] := xProp2
   ENDIF

   IF xProp1 == "VIRTUAL WIDTH"
      xProp[ 29 ] := xProp2
      SaveToIni( "WIDTH", xProp2 )
   ENDIF

   IF xProp1 == "VIRTUALWIDTH"
      xProp[ 29 ] := xProp2
      SaveToIni( "WIDTH", xProp2 )
   ENDIF

   IF xProp1 == "HEIGHT"
      xProp[  8 ] := xProp2
   ENDIF

   IF xProp1 == "VIRTUAL HEIGHT"
      xProp[ 30 ] := xProp2
      SaveToIni( "HEIGHT", xProp2 )
   ENDIF

   IF xProp1 == "VIRTUALHEIGHT"
      xProp[ 30 ] := xProp2
      SaveToIni( "HEIGHT", xProp2 )
   ENDIF

   IF xProp1 == "MINWIDTH"
      xProp[ 13 ] := xProp2
   ENDIF

   IF xProp1 == "MINHEIGHT"
      xProp[ 14 ] := xProp2
   ENDIF

   IF xProp1 == "MAXWIDTH"
      xProp[ 15 ] := xProp2
   ENDIF

   IF xProp1 == "MAXHEIGHT"
      xProp[ 16 ] := xProp2
   ENDIF

   IF xProp1 == "TITLE"          .AND. xProp2 # "NIL"
      xProp[ 23 ] := xProp2
   ENDIF

   IF xProp1 == "ICON"           .AND. xProp2 # "NIL"
      xProp[ 10 ] := xProp2
   ENDIF

   **************************************************used by hmgside.prg
   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "MAIN"
      xProp[ 28 ] := "MAIN"
   ENDIF

   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "CHILD"
      xProp[ 28 ] := "CHILD"
   ENDIF

   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "MODAL"
      xProp[ 28 ] := "MODAL"
   ENDIF

   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "SPLITCHILD"
      xProp[ 28 ] := "SPLITCHILD"
   ENDIF

   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "MDI"
      xProp[ 28 ] := "MDI"
   ENDIF

   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "MDICHILD"
      xProp[ 28 ] := "MDICHILD"
   ENDIF

   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "STANDARD"
      xProp[ 28 ] := "STANDARD"
   ENDIF

   IF xProp1 == "WINDOWTYPE"     .AND. xProp2 == "MAINMDI"
      xProp[ 28 ] := "MAINMDI"
   ENDIF

   ********************************************************used by loadfmg.prg
   IF xProp1 == "MAIN"           .AND. xProp2 # "NIL"
      xProp[ 28 ] := "MAIN"
   ENDIF

   IF xProp1 == "CHILD"          .AND. xProp2 # "NIL"
      xProp[ 28 ] := "CHILD"
   ENDIF

   IF xProp1 == "MODAL"          .AND. xProp2 # "NIL"
      xProp[ 28 ] := "MODAL"
   ENDIF

   IF xProp1 = "SPLITCHILD"      .AND. xProp2 # "NIL"
      xProp[ 28 ] := "SPLITCHILD"
   ENDIF

   IF xProp1 == "MDI"            .AND. xProp2 # "NIL"
      IF xProp[ 28 ] == "MAIN"
         xProp[ 28 ] := "MAINMDI"
      ELSE
         xProp[ 28 ] := "MDI"
      ENDIF
   ENDIF

   IF xProp1 == "MDICHILD"        .AND. xProp2 # "NIL"
      xProp[ 28 ] := "MDICHILD"
   ENDIF

   *******************************************************
   IF xProp1 == "NOSHOW"         .AND. xProp2 # "NIL"
      xProp[ 26 ] := ".F."
   ENDIF

   IF xProp1 == "VISIBLE"        .AND. xProp2 # "NIL"
      xProp[ 26 ] := ".F."
   ENDIF

   IF xProp1 == "TOPMOST"        .AND. xProp2 # "NIL"
      xProp[ 25 ] := ".T."
   ENDIF

   IF xProp1 == "NOAUTORELEASE"  .AND. xProp2 # "NIL"
      xProp[  1 ] := ".F."
   ENDIF

   IF xProp1 == "AUTORELEASE"    .AND. xProp2 # "NIL"
      xProp[  1 ] := xProp2
   ENDIF

   IF xProp1 == "NOMINIMIZE"     .AND. xProp2 # "NIL"
      xProp[ 12 ] := ".F."
   ENDIF

   IF xProp1 == "MINBUTTON"      .AND. xProp2 # "NIL"
      xProp[ 12 ] := xProp2
   ENDIF

   IF xProp1 == "NOMAXIMIZE"     .AND. xProp2 # "NIL"
      xProp[ 11 ] := ".F."
   ENDIF

   IF xProp1 == "MAXBUTTON"      .AND. xProp2 # "NIL"
      xProp[ 11 ] := xProp2
   ENDIF

   IF xProp1 == "NOSIZE"         .AND. xProp2 # "NIL"
      xProp[ 21 ] := ".F."
   ENDIF

   IF xProp1 == "SIZABLE"        .AND. xProp2 # "NIL"
      xProp[ 21 ] := xProp2
   ENDIF

   IF xProp1 == "NOSYSMENU"      .AND. xProp2 # "NIL"
      xProp[ 22 ] := ".F."
   ENDIF

   IF xProp1 == "SYSMENU"        .AND. xProp2 # "NIL"
      xProp[ 22 ] := xProp2
   ENDIF

   IF xProp1 == "NOCAPTION"      .AND. xProp2 # "NIL"
      xProp[ 24 ] := ".F."
   ENDIF

   IF xProp1 == "TITLEBAR"       .AND. xProp2 # "NIL"
      xProp[ 24 ] := xProp2
   ENDIF

   IF xProp1 == "CURSOR"         .AND. xProp2 # "NIL"
      xProp[  5 ] :=  xProp2
   ENDIF

   IF xProp1 == "ON INIT"        .OR.  xProp1 == "ONINIT"
      xEvent[  3 ] := xProp2
   ENDIF

   IF xProp1 == "ON RELEASE"     .OR.  xProp1 == "ONRELEASE"
      xEvent[ 13 ] := xProp2
   ENDIF

   IF xProp1 == "ON INTERACTIVECLOSE" .OR. xProp1 == "ONINTERACTIVECLOSE"
      xEvent[  4 ] := xProp2
   ENDIF

   IF xProp1 == "ON MOUSECLICK"  .OR.  xProp1 == "ONMOUSECLICK"
      xEvent[  8 ] := xProp2
   ENDIF

   IF xProp1 == "ON MOUSEDRAG"   .OR.  xProp1 == "ONMOUSEDRAG"
      xEvent[  9 ] := xProp2
   ENDIF

   IF xProp1 == "ON MOUSEMOVE"   .OR.  xProp1 == "ONMOUSEMOVE"
      xEvent[ 10 ] := xProp2
   ENDIF

   IF xProp1 == "ON MOVE"        .OR.  xProp1 == "ONMOVE"
      xEvent[ 21 ] := xProp2
   ENDIF

   IF xProp1 == "ON DROPFILES"   .OR.  xProp1 == "ONDROPFILES"
      xEvent[ 22 ] := xProp2
   ENDIF

   IF xProp1 == "ON SIZE"        .OR.  xProp1 == "ONSIZE"
      xEvent[18] := xProp2
   ENDIF

   IF xProp1 == "ON MAXIMIZE"    .OR.  xProp1 == "ONMAXIMIZE"
      xEvent[  6 ] := xProp2
   ENDIF

   IF xProp1 == "ON MINIMIZE"    .OR.  xProp1 == "ONMINIMIZE"
      xEvent[  7 ] := xProp2
   ENDIF

   IF xProp1 == "ON RESTORE"     .OR.  xProp1 == "ONRESTORE"
      xEvent[ 20 ] := xProp2
   ENDIF

   IF xProp1 == "ON PAINT"       .OR.  xProp1 == "ONPAINT"
      xEvent[ 12 ] := xProp2
   ENDIF

   IF xProp1 == "BACKCOLOR"
      xProp[  2 ] := xProp2
   ENDIF

   ******************************
   IF xProp1 == "FONT"
      xProp[ 31 ] := xProp2
   ENDIF

   IF xProp1 == "SIZE"           .OR.  xProp1 == "SIZE"
      xProp[ 32 ] := xProp2
   ENDIF

   *******************************
   IF xProp1 == "NOTIFYICON"     .AND. xProp2 # "NIL"
      xProp[ 17 ] := xProp2
   ENDIF

   IF xProp1 == "NOTIFYTOOLTIP"  .AND. xProp2 # "NIL"
      xProp[ 18 ] := xProp2
   ENDIF

   IF xProp1 == "ON NOTIFYCLICK" .OR.  xProp1 == "ONNOTIFYCLICK"
      xEvent[ 11 ] := xProp2
   ENDIF

   IF xProp1 == "ON GOTFOCUS"    .OR.  xProp1 == "ONGOTFOCUS"
      xEvent[  1 ] := xProp2
   ENDIF

   IF xProp1 == "ON LOSTFOCUS"   .OR.  xProp1 == "ONLOSTFOCUS"
      xEvent[  5 ] := xProp2
   ENDIF

   IF xProp1 == "ON SCROLLUP"    .OR.  xProp1 == "ONSCROLLUP"
      xEvent[ 17 ] := xProp2
   ENDIF

   IF xProp1 == "ON SCROLLDOWN"  .OR.  xProp1 == "ONSCROLLDOWN"
      xEvent[ 14 ] := xProp2
   ENDIF

   IF xProp1 == "ON SCROLLLEFT"  .OR.  xProp1 == "ONSCROLLLEFT"
      xEvent[ 15 ] := xProp2
   ENDIF

   IF xProp1 == "ON SCROLLRIGHT" .OR.  xProp1 == "ONSCROLLRIGHT"
      xEvent[ 16 ] := xProp2
   ENDIF

   IF xProp1 == "ON HSCROLLBOX"  .OR.  xProp1 == "ONHSCROLLBOX"
      xEvent[  2 ] := xProp2
   ENDIF

   IF xProp1 == "ON VSCROLLBOX"  .OR.  xProp1 == "ONVSCROLLBOX"
      xEvent[ 19 ] := xProp2
   ENDIF

   IF xProp1 == "HELPBUTTON"     .AND. xProp2 # "NIL"
      xProp[  9 ] := ".T."
   ENDIF

   IF xProp1 == "PALETTE"        .AND. xProp2 # "NIL"
      xProp[ 19 ] := ".T."
   ENDIF

   IF xProp1 == "ON NOTIFYBALLOONCLICK"       .OR.  xProp1 == "ONNOTIFYBALLOONCLICK"
      xEvent[ 23 ] := xProp2
   ENDIF


RETURN


*------------------------------------------------------------*
PROCEDURE UciSaveControlVal( Param AS NUMERIC )
*------------------------------------------------------------*
   LOCAL x     AS NUMERIC
   LOCAL nPos  AS NUMERIC := Param
   LOCAL aTemp AS ARRAY   := {}

   AAdd( aTemp, Upper( aUCIControls[ nPos ] ) )
   AAdd( aTemp, "DEFINE " + Upper( aUCIControls[ nPos ] ) )
   AAdd( aTemp, '""'    )
   AAdd( aTemp, "ROW"   )
   AAdd( aTemp, '""'    )
   AAdd( aTemp, "COL"   )
   AAdd( aTemp, '""'    )
   AAdd( aTemp, "WIDTH" )
   AAdd( aTemp, '""'    )
   AAdd( aTemp, "HEIGHT")
   AAdd( aTemp, '""'    )

   FOR x := 1 TO Len( AUCIPROPS[ nPos ] )
       AAdd( aTemp, Upper( AUCIPROPS[ nPos, x ] ) )
       AAdd( aTemp, '""' )
   NEXT x

   FOR x := 1 TO Len( AUCIEVENTS[ nPos ] )
       AAdd( aTemp, Upper( AUCIEVENTS[ nPos, x ] ) )
       AAdd( aTemp, "NIL" )
   NEXT x

   AAdd( aTemp, "END " + Upper( AUCICONTROLS[ nPos ] ) )

   // MsgBox( "LEN AITENS = " + Str( Len(aTemp ) ) )

   aItens[ControlAtual] := AClone( aTemp )

   // MsgBox( "saving-uci" )
   // SaveControlVal2()

RETURN


*------------------------------------------------------------*
PROCEDURE SaveControlVal2( Param AS USUAL )        //? VarType
*------------------------------------------------------------*
   LOCAL x AS NUMERIC
   LOCAL nPos AS NUMERIC

   // A := ""
   // MsgBox("ControlAtual= "+Str(ControlAtual)+ " nTotControl = " + Str( nTotControl ) )
   FOR x := 1 TO Len( aItens[ ControlAtual] )
      //A += Str(X) + " - " + aItens[ ControlAtual,x] + CRLF
      nPos := nTotControl
      xArray[ nPos, x ] := aItens[ ControlAtual, x ]
   NEXT x

   // MsgBox( A )
   *****************************************
   // MsgBox( "len1= " + Str( Len( aItens[ ControlAtual ] ) ) )
   // MsgBox( "len2= " + Str( Len( xArray[ nPos    ] ) ) )
   // ACopy( aItens[ControlAtual], xArray[ nPos    ] )
   // A := ""
   // MsgBox( "nTotControl= " + Str( nPos ) )
   // FOR x := 1 TO Len( aItens[ ControlAtual ] )
   //     A+= Str( x ) + " - " + xArray[ nPos, x ] + CRLF
   // NEXT x
   // MsgBox( A )

   FixValues()

   IF PARAM = NIL
      // MsgBox( "ADDING CONTROL " + Str( nrTotControl ) )
      ShowControls2( nTotControl )
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE SaveControlVal( Param AS NUMERIC )
*------------------------------------------------------------*
   **** CONTROLS TAB/TBROWSE/TIMER/TREE
   LOCAL X7              AS NUMERIC
   LOCAL X               AS NUMERIC
   LOCAL propnr          AS NUMERIC := 1
   LOCAL A1              AS STRING
   LOCAL A2              AS STRING
   LOCAL cStoredWorkArea AS STRING  := ""
   LOCAL Z               AS NUMERIC
   LOCAL aIniReturn      AS ARRAY   := {}
   LOCAL aField          AS ARRAY   := {}
   LOCAL xLinMain        AS STRING  := ""
   LOCAL nPos            AS NUMERIC
   LOCAL Pos             AS NUMERIC
   //LOCAL LinMain

   IF Param = NIL
      POS := 0
   ELSE
      ****** TO CONTROL TAB
      // MsgBox("param= "+Str(param))
      // MsgBox("LinMain= " + LinMain)
      POS := Param

      FOR Z = 1 TO POS
          xLinMain += CRLF
      NEXT Z

      LinMain := xLinMain + LinMain
      // MsgBox("LinMain= "+LinMain+ " linhas= "+Str(MLCount(LinMain)) )
      PROPNR := PROPNR + ( 2 * POS )
      // MsgBox( "propnr= " + Str( propnr ) )
   ENDIF

   X7 := MLCount( LinMain, 1000 )
   // MsgBox("ControlAtual= "+Str(ControlAtual)+" aItens[ControlAtual,1]= "+aItens[ControlAtual,1]+ " nTotControl = "+Str(nTotControl) )
   nPos := nTotControl
   xArray[ nPos, 1 ] := aItens[ ControlAtual, 1 ]   // FIRST ITEM TYPE OF CONTROL (BUTTON...)
   // MsgBox( " xArray[nPos,1]= " + xArray[nPos,1])

   FOR X := (1+POS) TO (X7)

       A1 := AllTrim( MemoLine( LinMain, 1000, x, NIL, .T. ) ) // ONE LINE OF FILE

       IF Len( A1 )  > 0
          ***********debug
          //if param # NIL
          // MsgBox("x= "+Str(x)+ " LEN= "+Str(X7) )
          // MsgBox("A1=lin= "+LinMain)
          // MsgBox("A1="+A1+ " ControlAtual= "+ Str(ControlAtual) +" "+aItens[ControlAtual,1])
          // ctext := "aitem="+aItens[ControlAtual,X+1]+ " x= "+ Str(x)
          //  ctext += " a="+Str( (Len(aItens[ControlAtual,X+1])+1) )
          //  ctext += " b="+Str( Len(A1) )
          //  ctext += " c="+Str( Len(aItens[ControlAtual,X+1]) )
          //   MsgBox(ctext)
          //ENDIF
          ***********

          IF x = 1                               .OR. ;
             xArray[ nPos, 1 ] = "TAB"      .OR. ;
             xArray[ nPos, 1 ] = "TREE"     .OR. ;
             xArray[ nPos, 1 ] = "TBROWSE"  .OR. ;
             xArray[ nPos, 1 ] = "TIMER"    .OR. ;
             xArray[ nPos, 1 ] = "PANEL"

             IF pos = 0
                A2 := AllTrim( SubStr( A1, ( Len( aItens[ ControlAtual, X+1 ] ) + 1 ), ( Len( A1 ) - Len( aItens[ ControlAtual, X+1 ] ) ) ) )
                // MsgBox( "A2= " + A2 )
             ELSE
                // MsgBox( "x= " + Str(x) )
                // MsgBox( " ControlAtual= " + Str( ControlAtual ) )
                // MsgBox( "aitens= "+aItens[ControlAtual,X+1]+ " x= " + Str(x) )
                A2 := AllTrim(SubStr(A1,(Len(aItens[ControlAtual,X+1])+1),(Len(A1) ))) //-Len(aItens[ControlAtual,X]))))
                // MsgBox( "A2= " + A2 )
             ENDIF
          ELSE
             // MsgBox("NOT TO EXECUTE")
             nPos := At( " ", A1 )
             A2   := AllTrim( SubStr( A1, nPos+1, Len( A1 ) ) )
             // MsgBox("A2= " + A2)
          ENDIF

          IF xArray[ nPos, 1 ] = "TAB"

             DO CASE
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "CAPTION"        ; A2 := '""'
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "FONTNAME"       ; A2 := "'Arial'"
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "FONTSIZE"       ; A2 := "9"
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "TOOLTIP"        ; A2 := '""'
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "FONTBOLD"       ; A2 := ".F."
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "FONTITALIC"     ; A2 := ".F."
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "FONTUNDERLINE"  ; A2 := ".F."
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "FONTSTRIKEOUT"  ; A2 := ".F."
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "TABSTOP"        ; A2 := ".T."
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "VISIBLE"        ; A2 := ".T."
                CASE A2 = "NIL" .AND. aItens[ ControlAtual, X+1 ] = "TRANSPARENT"    ; A2 := ".F."
             ENDCASE
          ENDIF

          // MsgBox("A2-final= "+A2)
          propnr ++
          //if xArray[nPos,1] = "TAB"
          // MsgBox("IS TAB-> X= "+Str(X))
          xArray[ nPos, propnr ] := aItens[ ControlAtual, X+1 ] // new value(name property)
          // MsgBox( " property " +Str(propnr)+ " = "+ aItens[ControlAtual,X+1]  )

          /*
          ELSE
            **** IF USED ARRAY WITH {PROP.Value}
             IF X = 1
                MsgBox("PROP1= "+aItens[ControlAtual,(X+1)] + " = AITENS "+Str(X+1))
                xArray[nPos,propnr] := aItens[ControlAtual,(X+1)] // new value(name property)
             ELSE
                MsgBox("PROP2= "+aItens[ControlAtual,(X*2)]+ " = AITENS "+Str(X*2) )
                xArray[nPos,propnr] := aItens[ControlAtual,(X*2)] // new value(name property)
             ENDIF
             // MsgBox( "NOT TAB-> X= " + Str( x ) )
          ENDIF
          */

          Propnr ++
          xArray[ nPos, Propnr ] := A2
          // MsgBox( " value of  "+ Str( propnr ) + " = " + A2 )

       ENDIF

   NEXT X

   Propnr ++
   xArray[ nPos, Propnr ] := "ENDPROP"

   FixValues()

   IF PARAM = NIL
      ShowControls2( nTotControl )
   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE FixValues()
*------------------------------------------------------------*
   LOCAL aIniReturn AS ARRAY := {}
   LOCAL nPos AS NUMERIC

   nPos := nTotControl

   DO CASE

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 1         // Button

      IF Upper( xArray[ nPos, 37 ] ) = "NIL"    //  Flat
         xArray[ nPos, 37 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 47 ] ) = "NIL"    // Default
         xArray[ nPos, 47 ] := ".F."
      ENDIF

      // IF Upper( xArray[ nPos, 49 ] ) = "NIL" // Icon
      //    xArray[ nPos, 49 ] := '""'
      // ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"    // MultiLine
         xArray[ nPos, 51 ] := ".F."
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 2         // Checkbox

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"    // Value
         xArray[ nPos, 15 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 37 ] ) = "NIL"    // Field
         xArray[ nPos, 37 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"    // LeftJustify
         xArray[ nPos, 51 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 53 ] ) = "NIL"    // ThreeState
         xArray[ nPos, 53 ] := ".F."
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 3         // ListBox

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"    // Items
         xArray[ nPos, 13 ] := '{""}'
      ENDIF

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"    // Value
         xArray[ nPos, 15 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 49 ] ) = "NIL"    // Sort
         xArray[ nPos, 49 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"    // MultiSelect
         xArray[ nPos, 51 ] := ".F."
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 4         // ComboBox

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"    // Items
         xArray[ nPos, 13 ] := '{""}'
      ENDIF

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"    // Value
         xArray[ nPos, 15 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 43 ] ) = "NIL"    // Sort
         xArray[ nPos, 43 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 49 ] ) = "NIL"    // DisplayEdit
         xArray[ nPos, 49 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 53 ] ) = "NIL"    // ValueSource
         xArray[ nPos, 53 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 55 ] ) = "NIL"    // ListWidth
         xArray[ nPos, 55 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 61 ] ) = "NIL"    // GripperText
         xArray[ nPos, 61 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 63 ] ) = "NIL"    // Break
         xArray[ nPos, 63 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 5         // Checkbutton
      IF Upper( xArray[ nPos, 15 ] ) = "NIL"    // Value
         xArray[ nPos, 15 ] := ".F."
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 6         // Grid


      IF Upper( xArray[ nPos, 13 ] ) = "NIL"      // Headers
         xArray[ nPos, 13 ] := '{""}'
      ENDIF

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"    // Widths
         xArray[ nPos, 15 ] := "{0}"
      ENDIF

      IF Upper( xArray[ nPos, 17 ] ) = "NIL"    // Items
         xArray[ nPos, 17 ] := '{{""}}'
      ENDIF

      IF Upper( xArray[ nPos, 19 ] ) = "NIL"    // Value
         xArray[ nPos, 19 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"    // AllowEdit
         xArray[ nPos, 51 ] := ".F."
      ENDIF

      IF Upper( xArray[nPos, 57 ] ) = "NIL"     // InPlaceEdit
         xArray[ nPos, 57 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 59 ] ) = "NIL"    // CellNavigation
         xArray[ nPos, 59 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 69 ] ) = "NIL"    // Virtual
         xArray[ nPos, 69 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 75 ] ) = "NIL"    // MultiSelect
         xArray[ nPos, 75 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 77 ] ) = "NIL"    // NoLines
         xArray[ nPos, 77 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 79 ] ) = "NIL"    // ShowHeaders
         xArray[ nPos, 79 ] := ".T."
      ENDIF

      IF Upper( xArray[nPos, 89 ] ) = "NIL"     // Break
         xArray[ nPos, 89 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 91 ] ) = "NIL"    // HeaderImage
         xArray[ nPos, 91 ] := ""
      ENDIF

      IF Upper( xArray[nPos, 93 ] ) = "NIL"     // NoTabStop
         xArray[ nPos, 93 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 95 ] ) = "NIL"    // CheckBoxes
         xArray[ nPos, 95 ] := ".F."
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 7         // Slider
      IF Upper( xArray[ nPos, 17 ] ) = "NIL"    // Value
         xArray[ nPos, 17 ] := "0"
      ENDIF

      // VERTICAL
      IF xArray[ nPos, 37 ] = ".T."             // Vertical
         xArray[ nPos, 33 ] := "2"

         IF xArray[ nPos, 41 ] = ".T."
            xArray[ nPos, 35 ] := "1"
         ELSEIF xArray[ nPos, 49 ] = ".T."
            xArray[ nPos, 35 ] := "2"
         ELSEIF xArray[ nPos, 29 ] = ".T."
            xArray[ nPos, 35 ] := "3"
         ELSE
            xArray[ nPos, 35 ] := "4"
         ENDIF
      ELSE
         // HORIZONTAL
         xArray[ nPos, 33 ] := "1"

         IF xArray[ nPos, 41 ] = ".T."
            xArray[ nPos, 35 ] := "1"
         ELSEIF xArray[ nPos, 29 ] = ".T."
            xArray[ nPos, 35 ] := "3"
         ELSEIF xArray[ nPos, 45 ] = ".T."
            xArray[ nPos, 35 ] := "4"
         ELSE
            xArray[ nPos, 35 ] := "2"
         ENDIF
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 8         // Spinner

      IF Upper( xArray[ nPos, 17 ] ) = "NIL"    // Value
         xArray[ nPos, 17 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 45 ] ) = "NIL"    // Wrap
         xArray[ nPos, 45 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 47 ] ) = "NIL"    // ReadOnly
         xArray[ nPos, 47 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 49 ] ) = "NIL"    // Increment
         xArray[ nPos, 49 ] := "1"
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 9         // Image

      IF Upper( xArray[ nPos, 19 ] ) = "NIL"    // Stretch
         xArray[ nPos, 19 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 23 ] ) = "NIL"    // WhiteBackGround
         xArray[ nPos, 23 ] := ".F."
      ELSEIF Upper( xArray[ nPos, 23 ] ) = NIL
         xArray[ nPos, 23 ] := ".T."
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 10        // DatePicker

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"    // Value
         xArray[ nPos, 13 ] := "CToD('')"
      ENDIF

      IF Upper( xArray[ nPos, 43 ] ) = "NIL"    // ShowNone
         xArray[ nPos, 43 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 45 ] ) = "NIL"    // UpDown
         xArray[ nPos, 45 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 47 ] ) = "NIL"    // RightAlign
         xArray[ nPos, 47 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 49 ] ) = "NIL"    // Field
         xArray[ nPos, 49 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 55 ] ) = "NIL"    // DateFormat
         xArray[ nPos, 55 ] := '""'
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 11        // TextBox

      IF Upper( xArray[ nPos, 41 ] ) = "NIL"    // ReadOnly
         xArray[ nPos, 41 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 43 ] ) = "NIL"    // RightAlign
         xArray[ nPos, 43 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 53 ] ) = "NIL"    // MaxLength
         xArray[ nPos, 53 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 61 ] ) = "NIL"    // InputMask
         xArray[ nPos, 61 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 63 ] )  = "NIL"   // Format
         xArray[ nPos, 63 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 71 ] ) = "NIL"    // Value
         xArray[ nPos, 71 ] := '""'
      ENDIF

      IF xArray[ nPos, 45 ] = ".T."             // LowerCase
         xArray[ nPos, 73 ] := "1"
      ELSEIF xArray[ nPos, 47 ] = ".T."
         xArray[ nPos, 73 ] :=  "2"
      ELSE
         xArray[ nPos, 73 ] :=  "3"
      ENDIF

      IF xArray[ nPos, 51 ] = ".T."             // Password
         xArray[ nPos, 75 ] := "PASSWORD"
      ELSEIF xArray[ nPos, 65 ] = ".T."
         xArray[ nPos, 75 ] := "DATE"
      ELSEIF xArray[ nPos, 67 ] = ".T."
         xArray[ nPos, 75 ] :=  "NUMERIC"
      ELSE
         xArray[ nPos, 75 ] :=  "CHARACTER"
      ENDIF

   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 12        // Editbox

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"    // Value
         xArray[ nPos, 13 ] := '""'
      ENDIF

      IF Upper( xArray[nPos, 41 ] ) = "NIL"     // ReadOnly
         xArray[ nPos, 41 ] := ".F."
      ENDIF

      IF Upper( xArray[nPos, 47 ] ) = "NIL"     // MaxLength
         xArray[ nPos, 47 ] := "0"
      ENDIF

      IF Upper( xArray[nPos, 49 ] ) = "NIL"     // Field
         xArray[ nPos, 49 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"    // HscrollBar
         xArray[ nPos, 51 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 53 ] ) = "NIL"    // VscrollBar
         xArray[ nPos, 53 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 55 ] ) = "NIL"    // Break
         xArray[ nPos, 55 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 13        // Label

      IF Upper( xArray[ nPos, 37 ] ) = "NIL"    // Autosize
         xArray[ nPos, 37 ] := ".F."
      ENDIF

      IF xArray[ nPos, 47 ] = ".T."             // RightAlign
         xArray[ nPos, 43 ] := "2"
         xArray[ nPos, 45 ] := ".F."
         xArray[ nPos, 49 ] := ".F."

      ELSEIF xArray[ nPos, 49 ] = ".T."         // CenterAlign
         xArray[ nPos, 43 ] := "3"
         xArray[ nPos, 45 ] := ".F."
         xArray[ nPos, 47 ] := ".F."

      ELSE
         xArray[ nPos, 43 ] := "1"
         xArray[ nPos, 45 ] := ".T."
         xArray[ nPos, 47 ] := ".F."
         xArray[ nPos, 49 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 33 ] ) = "NIL"    // Transparent
         xArray[ nPos, 33 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"    // Border
         xArray[ nPos, 51 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 53 ] ) = "NIL"    // ClientEdge
         xArray[ nPos, 53 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 55 ] ) = "NIL"    // Hscroll
         xArray[ nPos, 55 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 57 ] ) = "NIL"    // Vscroll
         xArray[ nPos, 57 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 59 ] ) = "NIL"    // Blink
         xArray[ nPos, 59 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 14        // Browse

      IF Upper( xArray[ nPos, 19 ] ) = "NIL"    // Value
          xArray[ nPos, 19 ] := "0"
       ENDIF

       IF Upper( xArray[ nPos, 53 ] ) = "NIL"   // AllowEdit
          xArray[ nPos, 53 ] := ".F."
       ENDIF

       IF Upper( xArray[ nPos,55 ] ) = "NIL"    // InPlaceEdit
          xArray[ nPos, 55 ] := ".F."
       ENDIF

       IF Upper( xArray[ nPos, 57 ] ) = "NIL"   // AllowAppend
          xArray[ nPos, 57 ] := ".F."
       ENDIF

        IF Upper( xArray[ nPos, 75 ] ) = "NIL"   // Lock
          xArray[ nPos, 75 ] := ".F."
       ENDIF

       IF Upper( xArray[ nPos,77]) = "NIL"      // AllowDelete
          xArray[ nPos, 77 ] := ".F."
       ENDIF

        IF Upper( xArray[ nPos, 79 ] ) = "NIL"   // NoLines
          xArray[ nPos, 79 ] := ".F."
       ENDIF

       IF Upper( xArray[ nPos, 85 ] ) = "NIL"   // VscrollBar
          xArray[ nPos, 85 ] := ".T."
       ENDIF

       IF Upper( xArray[ nPos,91 ] ) = "NIL"    // HeaderImage
          xArray[ nPos, 91 ] := ""
       ENDIF

       IF Upper( xArray[ nPos,93 ] ) = "NIL"    // NoTabStop
          xArray[ nPos, 93 ] := ".F."
       ENDIF

         /********************************************************/
         /* Start Code Arcangelo Molinaro Modified 25/12/2007    */
         /* Load (First) Value from *.fmg file if they Exist     */
         /* IF missing (empty or nil), load them from *.ini file */
         /* for stored value if it exist.                        */
         /********************************************************/
      IF _IsIniDef()
         aIniReturn := MR_INI( xArray[ nPos, 3 ] )

         IF ! Empty( aIniReturn ) .AND. Len( aIniReturn ) > 0
            IF aIniReturn[1]  /* there are value stored in *.ini file */
               IF aIniReturn[ 2, 1 ]     /* IF Stored WorkArea */
                  IF Empty( xArray[ nPos, 21 ] ) .OR. Upper( xArray[ nPos, 89 ] )== "NIL"
                     xArray[ nPos, 21 ] := aIniReturn[ 2, 2 ]
                  ENDIF
               ENDIF

              IF aIniReturn[ 3, 1 ]     /* IF Stored DatabasePath */
                 IF Empty( xArray[ nPos, 97 ] ) .OR. Upper( xArray[ nPos, 87 ] ) == "NIL"
                    xArray[ nPos, 97 ] := aIniReturn[ 3, 2 ]
                 ENDIF
              ENDIF

              IF aIniReturn[ 5, 1 ]     /* IF Stored DatabaseName */
                 IF Empty( xArray[ nPos, 95 ] ) .OR. Upper( xArray[ nPos, 19 ] ) == "NIL"
                    xArray[ nPos, 95 ] := aIniReturn[ 5, 2 ]
                 ENDIF
              ENDIF
          ENDIF

          IF AllTrim(xArray[ nPos, 95 ] ) == AllTrim( xArray[ nPos, 89 ] )
             xArray[ nPos, 21 ] := ""
          ENDIF

        ELSE
        //    MsgInfo("<Project>.ini file is empty !"+CRLF+"No stored data found and loaded !"+CRLF+;
        //          "Unable to restore original value from it"+CRLF+;
        //          "Loading data from <project>.fmg file" ,"Empty <project>.ini file")
                              /* <project>.ini file IS EMPTY ! */
        ENDIF
     ELSE
        //    MsgInfo("<Project>.ini file DOESN"T EXIST !"+CRLF+;
        //          "Unable to restore original value from it"+CRLF+;
        //          "Loading data from <project>.fmg file" ,"Missing <project>.ini file")
                              /* <project>.ini file doesn"t exist ! */
     ENDIF

     /* End Code Arcangelo Molinaro Modified 25/12/2007 */


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 15        // RadioGroup

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"    // Value
         xArray[ nPos, 15 ] := "1"
      ENDIF

      IF Upper( xArray[ nPos, 41 ] ) = "NIL"    // Spacing
         xArray[ nPos, 41 ] := "25"
      ENDIF

      IF Upper( xArray[ nPos, 47 ] ) = "NIL"    // LeftJustify
         xArray[ nPos, 47 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 49 ] ) = "NIL"    // Horizontal
         xArray[ nPos, 49 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"    // ReadOnly
         xArray[ nPos, 51 ] := ""
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 16        // Frame

      IF Upper( xArray[ nPos, 25 ] ) = "NIL"   // Caption
         xArray[ nPos, 25 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 31 ] ) = "NIL"   // Opaque
         xArray[ nPos, 31 ] := ".F."
      ENDIF

      IF Upper( xArray[nPos, 33 ] ) = "NIL"    // Invisible
         xArray[ nPos, 33 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 17        // AnimateBox

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"   // File
         xArray[ nPos, 13 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 19 ] ) = "NIL"   // AutoPlay
         xArray[ nPos, 19 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 21 ] ) = "NIL"   // Center
         xArray[ nPos, 21 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 23 ] ) = "NIL"   // Border
         xArray[ nPos, 23 ] := ".T."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 18        // Hyperlink

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"   // Value
         xArray[ nPos, 13 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 31 ] ) = "NIL"   // AutoSize
         xArray[ nPos, 31 ] := ".F."
      ENDIF

      IF Upper( xArray[nPos, 37 ] ) = "NIL"    // HandCursor
         xArray[ nPos, 37 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 19        // MonthCalendar

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"   // Value
         xArray[ nPos, 13 ] := "CToD('')"
      ENDIF

      IF Upper( xArray[ nPos, 37 ] ) = "NIL"   // NoToday
         xArray[ nPos, 37 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 39 ] ) = "NIL"   // NoTodayCircle
         xArray[ nPos, 39 ] := ".F."
      ENDIF

      IF Upper( xArray[nPos, 41 ] ) = "NIL"    // WeekNumbers
         xArray[ nPos, 41 ] := ".F."
      ENDIF

      IF Upper( xArray[nPos, 55 ] ) = "NIL"    // BkGndColor
         xArray[ nPos, 55 ] :=  ""
      ENDIF

      IF Upper( xArray[nPos, 53 ] ) # "NIL"    // BackGroundColor
         xArray[ nPos, 55 ] :=  xArray[ nPos, 53 ]
      ENDIF




   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 20        // RichEditBox

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"   // Value
         xArray[ nPos, 13 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 41 ] ) = "NIL"   // ReadOnly
         xArray[ nPos, 41 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 45 ] ) # "NIL"
         xArray[ nPos, 49 ] := "NIL"
      //ELSEIF Upper( xArray[ nPos, 45 ] ) = "NIL"
      //   xArray[ nPos, 45 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 47 ] ) = "NIL"   // MaxLength
         xArray[ nPos, 47 ] := "0"
      ENDIF

      //IF Upper( xArray[ nPos, 49 ] ) = "NIL" // File
      //   xArray[ nPos, 49 ] := ""
      //ENDIF

      IF Upper( xArray[ nPos, 53 ] ) = "NIL"   // PlainText
         xArray[ nPos, 53 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 55 ] ) = "NIL"   // HscrollBar
         xArray[ nPos, 55 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 57 ] ) = "NIL"   // VscrollBar
         xArray[ nPos, 57 ] := ".T."
      ENDIF

      //IF Upper( xArray[ nPos, 59 ] ) = "NIL" // FontColor
      //   xArray[ nPos, 59 ] := ".F."
      //ENDIF

      IF Upper( xArray[ nPos, 61 ] ) = "NIL"   // Break
         xArray[ nPos, 61 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 21        // ProgressBar

      IF Upper( xArray[ nPos, 17 ] ) = "NIL"   // Value
         xArray[ nPos, 17 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 25 ] ) = "NIL"   // Smooth
         xArray[ nPos, 25 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 33 ] ) = "NIL"   // Vertical
         xArray[ nPos, 33 ] := "1"
      ENDIF

      IF Upper( xArray[ nPos, 27 ] ) = "NIL"   // Default
         xArray[ nPos, 27 ] := ".F."
      ENDIF

      IF xArray[ nPos, 27 ] = ".F."            // Horizontal
         xArray[ nPos, 33 ] := "1"
      ELSEIF xArray[ nPos, 27 ] = ".T."        // Vertical
         xArray[ nPos, 33 ] := "2"
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 22        // Player

      IF Upper( xArray[ nPos, 17 ] ) = "NIL"   // NoAutoSizeWindow
         xArray[ nPos, 17 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 19 ] ) = "NIL"   // NoAutoSizeMovie
         xArray[ nPos, 19 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 21 ] ) = "NIL"   // NoErrorDlg
         xArray[ nPos, 21 ] := ".F."
      ENDIF

      IF Upper(xArray[ nPos, 23 ] ) = "NIL"    // NoMenu
         xArray[ nPos, 23 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 25 ] ) = "NIL"   // NoOpen
         xArray[ nPos, 25 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 27 ] ) = "NIL"   // NoPlayBar
         xArray[ nPos, 27 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 29 ] ) = "NIL"   // ShowAll
         xArray[ nPos, 29 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 31 ] ) = "NIL"   // ShowMode
         xArray[ nPos, 31 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 33 ] ) = "NIL"   // ShowName
         xArray[ nPos, 33 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 35 ] ) = "NIL"   // ShowPosition
         xArray[ nPos, 35 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 23        // IPAddress
      IF Upper( xArray[nPos, 13 ] ) = "NIL"    // Value
         xArray[ nPos, 13 ] := "{0,0,0,0}"                 // Renaldo
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 24        // ButtonEx

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"   // Picture
         xArray[ nPos, 15 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 17 ] ) = "NIL"   // Icon
         xArray[ nPos, 17 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 35 ] ) = "NIL"   // Vertical
         xArray[ nPos, 35 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 37 ] ) = "NIL"   // LeftText
         xArray[ nPos, 37 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 39 ] ) = "NIL"   // UpperText
         xArray[ nPos, 39 ] := ".F."
      ENDIF

      IF Upper(xArray[ nPos, 41 ] ) = "NIL"    // Adjust
         xArray[ nPos, 41 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 47 ] ) = "NIL"   // NoHotLight
         xArray[ nPos, 47 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 49 ] ) = "NIL"   // Flat
         xArray[ nPos, 49 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 51 ] ) = "NIL"   // NoTransparent
         xArray[ nPos, 51 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 53 ] ) = "NIL"   // NoXPStyle
         xArray[ nPos, 53 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 65 ] ) = "NIL"   // Default
         xArray[ nPos, 65 ] := ".F."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 25        // ComboBoxEx

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"   // Items
         xArray[ nPos, 13 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"   // ItemSource
         xArray[ nPos, 15 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 17 ] ) = "NIL"   // Value
         xArray[ nPos, 17 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 19 ] ) = "NIL"   // ValueSource
         xArray[ nPos, 19 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 21 ] ) = "NIL"   // DisplayEdit
         xArray[ nPos, 21 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 23 ] ) = "NIL"   // ListWidth
         xArray[ nPos, 23 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 57 ] )  = "NIL"  // GripperText
         xArray[ nPos, 57 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 59 ] ) = "NIL"   // Break
         xArray[ nPos, 59 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 63 ] ) = "NIL"   // Image
         xArray[ nPos, 63 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 69 ] ) = "NIL"   // ImageList
         xArray[ nPos, 69 ] := ""
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 26        // TimePicker

      IF Upper( xArray[ nPos, 29 ] ) = "NIL"   // ShowNone
         xArray[ nPos, 29 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 31 ] ) = "NIL"   // UpDown
         xArray[ nPos, 31 ] := ".F."
      ENDIF

      IF Upper( xArray[nPos, 45 ] ) = "NIL"    // Visible
         xArray[ nPos, 45 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 47 ] ) = "NIL"   // TabStop
         xArray[ nPos, 47 ] := ".T."
      ENDIF


   ************************************
   CASE ControlAtual == 28        // GetBox

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"   // Field
         xArray[ nPos, 13 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 17 ] ) = "NIL"   // Picture
         xArray[ nPos, 17 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 23 ] ) = "NIL"   // ValidMessage
         xArray[ nPos, 23 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 25 ] ) = "NIL"   // Message
         xArray[ nPos, 25 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 29 ] ) = "NIL"   // ReadOnly
         xArray[ nPos, 29 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 43 ] ) = "NIL"   // PassWord
         xArray[ nPos, 43 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 57 ] ) = "NIL"   // RightAlign
         xArray[ nPos,57]   := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 59 ] ) = "NIL"   // Visible
         xArray[ nPos, 59 ] := ".T."

      ENDIF
      IF Upper( xArray[ nPos, 61 ] ) = "NIL"   // TabStop
         xArray[ nPos, 61 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 69 ] ) = "NIL"   // Image
         xArray[ nPos, 69 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 71 ] ) = "NIL"   // ButtonWidth
         xArray[ nPos, 71 ] := "0"
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 29        // BtnTextBox

      IF Upper( xArray[ nPos, 15 ] ) = "NIL"   // Value
         xArray[ nPos, 15 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 19 ] ) = "NIL"   // Picture
         xArray[ nPos, 19 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 21 ] ) = "NIL"   // ButtonWidth
         xArray[ nPos, 21 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 45 ] ) = "NIL"   // MaxLenght
         xArray[ nPos, 45 ] := "0"
      ENDIF

      IF Upper( xArray[nPos, 59 ] ) = "NIL"    // RightAlign
         xArray[ nPos, 59 ] := ".F."
      ENDIF




   ************************************
   CASE ControlAtual == 34        // Tree

      IF Upper( xArray[ nPos, 13 ] ) = "NIL"   // Value
         xArray[ nPos, 13 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 33 ] ) = "NIL"   // NoRootButton
         xArray[ nPos, 33 ] := ".F."
      ELSE
         xArray[ nPos, 33 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 43 ] ) = "NIL"   // Indent
         xArray[ nPos, 43 ] := "17"
      ENDIF

      IF Upper( xArray[ nPos, 45 ] ) = "NIL"   // ItemHeight
         xArray[ nPos, 45 ] := "18"
      ENDIF

      IF Upper( xArray[ nPos, 59 ] ) = "NIL"   // FontBold
         xArray[ nPos, 47 ] := ".F."
      ELSE
         xArray[ nPos, 47 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 61 ] ) = "NIL"   // FontItalic
         xArray[ nPos, 49 ] := ".F."
      ELSE
         xArray[ nPos, 49 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 63 ] ) = "NIL"   // FontUnderline
         xArray[ nPos, 51 ] := ".F."
      ELSE
         xArray[ nPos, 51 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 65 ] ) = "NIL"   // FontStrikeout
         xArray[ nPos, 53 ] := ".F."
      ELSE
         xArray[ nPos, 53 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 55 ] ) = "NIL"   // Break
         xArray[ nPos, 55 ] := ".F."
      ENDIF

      IF Upper( xArray[ nPos, 57 ] ) = "NIL"   // ItemIDs
         xArray[ nPos, 57 ] := ".F."
      ELSE
         xArray[ nPos, 57 ] := ".T."
      ENDIF


   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 35        // Tab

      IF xArray[ nPos, 19 ] # ".F."            // FontBold
         xArray[ nPos, 19 ] := ".T."
      ENDIF

      IF xArray[ nPos, 21 ] # ".F."            // FontItalic
         xArray[ nPos, 21 ] := ".T."
      ENDIF

      IF xArray[ nPos, 23 ] #  ".F."           // FontUnderline
         xArray[ nPos, 23 ] := ".T."
      ENDIF

      IF xArray[ nPos, 25 ] # ".F."            // FontStrikeout
         xArray[ nPos, 25 ] := ".T."
      ENDIF

      IF xArray[ nPos, 29 ] # ".F."            // Buttons
         xArray[ nPos, 29 ] := ".T."
      ENDIF

      IF xArray[ nPos, 31 ] # ".F."            // Flat
         xArray[ nPos, 31 ] := ".T."
      ENDIF

      IF xArray[ nPos, 33 ] # ".F."            // HotTrack
         xArray[ nPos, 33 ] := ".T."
      ENDIF

      IF xArray[ nPos, 35 ] # ".F."            // Vertical
         xArray[ nPos, 35 ] := ".T."
      ENDIF

      IF xArray[ nPos, 39 ] # ".F."            // Bottom
         xArray[ nPos, 39 ] := ".T."
      ENDIF

      IF xArray[ nPos, 41 ] # ".F."            // NoTabStop
         xArray[ nPos, 41 ] := ".T."
      ENDIF

      IF xArray[ nPos, 43 ] # ".F."            // MultiLine
         xArray[ nPos, 43 ] := ".T."
      ENDIF


     *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 31        // CheckLabel

       IF xArray[ nPos, 63 ] = ".T."             // RightAlign
         xArray[ nPos, 59 ] := "2"
         xArray[ nPos, 61 ] := ".F."
         xArray[ nPos, 65 ] := ".F."

      ELSEIF xArray[ nPos, 65 ] = ".T."         // CenterAlign
         xArray[ nPos, 59 ] := "3"
         xArray[ nPos, 61 ] := ".F."
         xArray[ nPos, 63 ] := ".F."

      ELSE
         xArray[ nPos, 59 ] := "1"
         xArray[ nPos, 61 ] := ".T."
         xArray[ nPos, 63 ] := ".F."
         xArray[ nPos, 65 ] := ".F."
      ENDIF



   *- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   CASE ControlAtual == 42        // TBrowse
       *****TO VERIFY
      IF Upper( xArray[ nPos, 21 ] ) = "NIL"   // SelectFilter
         xArray[ nPos, 21 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 23 ] ) = "NIL"   // SelectFilterFor
         xArray[ nPos, 23 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 25 ] ) = "NIL"   // SelectFilterTo
         xArray[ nPos, 25 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 27 ] ) = "NIL"   // Value
         xArray[ nPos, 27 ] := "0"
      ENDIF

      IF Upper( xArray[ nPos, 57 ] ) = "NIL"   // Edit
         xArray[ nPos, 57 ] := ".F."
      ELSE
         xArray[ nPos, 57 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 59 ] ) = "NIL"   // Grid
         xArray[ nPos, 59 ] := ".F."
      ELSE
         xArray[ nPos, 59 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 61 ] ) = "NIL"   // Append
         xArray[ nPos, 61 ] := ".F."
      ELSE
         xArray[ nPos, 61 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 71 ] ) = "NIL"   // Message
         xArray[ nPos, 71 ] := '""'
      ENDIF

      IF Upper( xArray[ nPos, 75 ] ) = "NIL"   // Lock
         xArray[ nPos, 75 ] := ".F."
      ELSE
         xArray[ nPos, 75 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 77 ] ) = "NIL"   // Delete
         xArray[ nPos, 77 ] := ".F."
      ELSE
         xArray[ nPos, 77 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 79 ] ) = "NIL"   // NoLines
         xArray[ nPos, 79 ] := ".F."
      ELSE
         xArray[ nPos, 79 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 85 ] ) = "NIL"   // HelpID
         xArray[ nPos, 85 ] := ""
      ENDIF

      IF Upper( xArray[ nPos, 87 ] ) = "NIL"   // Break
         xArray[ nPos, 87 ] := ".F."
      ELSE
         xArray[ nPos, 87 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 89 ] ) = "NIL"   // FontBold
         xArray[ nPos, 33 ] := ".F."
      ELSE
         xArray[ nPos, 33 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 91 ] ) = "NIL"   // FontItalic
         xArray[ nPos, 35 ] := ".F."
      ELSE
         xArray[ nPos, 35 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 93 ] ) = "NIL"   // FontUnderline
         xArray[ nPos, 37 ] := ".F."
      ELSE
         xArray[ nPos, 37 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 95 ] ) = "NIL"   // FontStrikeout
         xArray[ nPos, 39 ] := ".F."
      ELSE
         xArray[ nPos, 39 ] := ".T."
      ENDIF

      *********************************************
      IF Upper( xArray[ nPos, 97 ] ) # "NIL"   // GotFocus
         xArray[ nPos, 49 ] :=  xArray[ nPos, 97 ]
      ENDIF

      IF Upper( xArray[ nPos, 99 ] ) # "NIL"   // Change
         xArray[ nPos, 51 ] :=  xArray[ nPos, 99 ]
      ENDIF

      IF Upper( xArray[ nPos,101 ] ) # "NIL"   // LostFocus
         xArray[ nPos, 53 ] := xArray[ nPos, 101 ]
      ENDIF

      IF Upper( xArray[ nPos,103 ] ) # "NIL"   // DblClick
         xArray[ nPos, 55 ] := xArray[ nPos, 103 ]
      ENDIF

      IF Upper( xArray[ nPos,105 ] ) # "NIL"   // HeadClick
         xArray[ nPos, 63 ] := xArray[ nPos, 105 ]
      ENDIF

      IF Upper( xArray[ nPos, 107 ] ) = "NIL"  // Font
         xArray[ nPos, 29 ] := "Arial"
      ELSE
         xArray[ nPos, 29 ] := xArray[ nPos, 107 ]
      ENDIF

      IF Upper( xArray[ nPos, 109 ] ) = "NIL"  // Size
         xArray[ nPos, 31 ] := "9"
      ELSE
         xArray[ nPos, 31 ] := xArray[ nPos, 109 ]
      ENDIF

      IF Upper( xArray[ nPos, 111 ] ) # "NIL"  // Celled -> Grid
         xArray[ nPos, 59 ] := ".T."
      ENDIF

      IF Upper( xArray[ nPos, 113 ] ) # "NIL"  // Cell  -> Grid
         xArray[ nPos, 59 ] := ".T."
      ENDIF

   ENDCASE

RETURN


*------------------------------------------------------------*
FUNCTION XConnectTab( xPos AS NUMERIC, TabName AS STRING, nrPagina AS NUMERIC )
*------------------------------------------------------------*
  LOCAL k           AS NUMERIC
  LOCAL xRow        AS NUMERIC := Val( xArray[ xPos, 5 ] )
  LOCAL xCol        AS NUMERIC := Val( xArray[ xPos, 7 ] )
  LOCAL ControlName AS ARRAY   :=      xArray[ xPos, 3 ]

  // MsgBox("connecting tab control= "+controlname+ "TABNAME= "+TABNAME)

  _AddTabControl( TabName, ControlName, "FORM_1", nrPagina, xRow, xCol )

  k := GetControlIndex( ControlName, "FORM_1" )

  IF  _HMG_aControlType[k] == "FRAME"       .OR. ;
      _HMG_aControlType[k] == "CHECKBOX"    .OR. ;
      _HMG_aControlType[k] == "RADIOGROUP"

      _HMG_aControlRangeMin[k] := TabName
      _HMG_aControlRangeMax[k] := "FORM_1"

  ELSEIF _HMG_aControlType[k] == "SLIDER"
       _HMG_aControlFontHandle[k] := TabName
       _HMG_aControlMiscDatA1[k]  := "FORM_1"
  ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Str2Array( Arg1 AS STRING )
*------------------------------------------------------------*
  LOCAL A2   AS ARRAY  := {}
  LOCAL Elem AS STRING

  IF Upper( Arg1 ) # "NIL"
     Elem := SubStr( Arg1, 2, At( ",", Arg1 ) - 1 )
     AAdd( A2, Val( Elem ) )

     Elem := SubStr( Arg1, At( ",", Arg1 ) + 1, RAt( ",", Arg1 ) - 1 )
     AAdd( A2, Val( Elem ) )

     Elem := SubStr( Arg1, RAt( ",", Arg1 ) + 1, Len( Arg1 ) - 1 )
     AAdd( A2, Val( Elem ) )
  ELSE
      A2 := NIL
  ENDIF

RETURN( A2 )


*------------------------------------------------------------*
PROCEDURE FLoadFmg()
*------------------------------------------------------------*
   _HMG_ActiveFormNameBak := _HMG_ActiveFormName

#IFDEF _PANEL_
   IF ! Empty( _HMG_ActiveFormName )
      _HMG_ActiveFormName := ""
   ENDIF
#ENDIF

   IF ! IsWindowDefined( Loading )
      LOAD WINDOW Loading
   ENDIF

   IF IsWindowDefined( form_1 ) .AND. isWindowActive( form_1 )
      RELEASE WINDOW form_1
   ENDIF

   IF IsWindowDefined( ViewFormCode )
      RELEASE WINDOW ViewFormCode
   ENDIF

   CENTER WINDOW Loading

   IF ! isWindowActive( Loading )
      ACTIVATE WINDOW Loading
   ELSE
     SHOW WINDOW Loading
   ENDIF

   _HMG_ActiveFormName := _HMG_ActiveFormNameBak

RETURN


*------------------------------------------------------------*
FUNCTION FindImageName( cName AS STRING, Ext AS STRING )
*------------------------------------------------------------*
  LOCAL aBmpAlias    AS ARRAY   := {}
  LOCAL aBmpFile     AS ARRAY   := {}
  LOCAL aIcoAlias    AS ARRAY   := {}
  LOCAL aIcoFile     AS ARRAY   := {}
  LOCAL xx           AS NUMERIC
  LOCAL x5           AS STRING
  LOCAL x6           AS NUMERIC
  LOCAL x7           AS NUMERIC
  LOCAL cL           AS STRING
  LOCAL cP           AS STRING
  LOCAL ArqRC        AS STRING
  LOCAL aRcList      AS ARRAY   := {}
  LOCAL cValue       AS STRING  := ""
  LOCAL ic           AS NUMERIC

  cName := noquota( cName )

  IF File( cName )
     cValue := cName

  ELSEIF File( GetStartupFolder() + "\" + cName )
     cValue := cName

  ELSEIF File( GetCurrentFolder() + "\" + cName )
     cValue := GetCurrentFolder() + "\" + cName

  ELSE
     ic := ProjectBrowser.xlist_3.ItemCount
     FOR xx := 1 TO ic
         AAdd( aRcList , ProjectFolder + "\" + ProjectBrowser.xlist_3.Item( xx ) )
     NEXT

     IF Len( aRcList ) > 0
        FOR xx := 1 to Len( aRcList )

            ArqRc := aRcList[xx]

            IF File( ArqRC )
               x5 := MemoRead( ArqRC )    // open file .Rc
               x6 := MLCount( x5,200 )

               FOR x7 := 1 TO x6          // read lines of .Rc
                   cL := Lower( AllTrim( MemoLine( x5, 200, x7, NIL, .T. ) ) )
                   cp := iif( !":"$ cL .AND. "HmgsIde.rc" $ ARqRC , GetStartupFolder()+"\" , iif( ! ":" $ cl, ProjectFolder + "\" , "" ) )

                   IF "bitmap" $ cL
                      IF AScan( aBmpAlias, AllTrim( SubStr( cL,1, At( " bitmap ",cL)-1 ) ) ) = 0

                         AAdd( aBmpAlias,      AllTrim( SubStr( cL, 1, At( " bitmap ", cL ) - 1 ) ) )
                         AAdd( aBmpFile , cp + AllTrim( SubStr( cL, RAt( " bitmap ", cL ) + 8, 200 ) ) )
                      ENDIF

                   ELSEIF "icon"  $ cL
                      IF AScan( aIcoAlias, AllTrim( SubStr( cL,1, At( " icon "  ,cL)-1 ) ) ) = 0

                         AAdd( aIcoAlias,      AllTrim( SubStr( cL, 1, At( " icon ", cL ) - 1 ) ) )
                         AAdd( aIcoFile , cp + AllTrim( SubStr( cL, RAt( " icon ", cL ) + 5, 200 ) ) )

                      ENDIF
                   ENDIF

               NEXT

            ENDIF

         NEXT

         IF Upper( ext ) ==  "BMP"
            cValue := iif( AScan( aBmpAlias , Lower(cName) ) > 0, aBmpFile[ AScan( aBmpAlias, Lower( cName ) ) ] , "" )
         ELSEIF Upper( ext )== "ICO"
            cValue := iif( AScan( aIcoAlias , Lower(cName) ) > 0, aIcoFile[ AScan( aIcoAlias, Lower( cName ) ) ] , "" )
         ENDIF

     ENDIF

  ENDIF

RETURN( cValue )


*------------------------------------------------------------*
FUNCTION VerifyNotes( x5 AS STRING, x6 AS NUMERIC )
*------------------------------------------------------------*
  LOCAL x          AS NUMERIC
  LOCAL A1         AS STRING
  LOCAL cTextNotes AS STRING  := ""

  FOR x := 1 TO x6
      A1 := AllTrim( MemoLine( x5, 1000, x, NIL, .T. ) )
      IF At( "/*", A1 ) > 0
         DO WHILE .T.
            cTextNotes := cTextNotes + A1 + CRLF
            x          := x+1
            A1         := AllTrim( MemoLine( x5, 1000, x, NIL, .T. ) )

            IF At( "*/", A1 ) > 0
               cTextNotes := cTextNotes + A1 + CRLF
               x          := x6
               EXIT
            ENDIF
        ENDDO
     ENDIF

     IF At( "DEFINE WINDOW", A1 ) > 0
        EXIT
     ENDIF
  NEXT

  // MsgBox( "value = " + cTextNotes )

RETURN( cTextNotes )


*------------------------------------------------------------*
PROCEDURE LoadUci()
*------------------------------------------------------------*
   LOCAL i         AS NUMERIC
   LOCAL cName     AS STRING
   LOCAL nLine     AS NUMERIC
   LOCAL nLines    AS NUMERIC
   LOCAL cLine     AS STRING
   LOCAL aPropTemp AS ARRAY   := {}
   LOCAL cFile     AS STRING
   LOCAL lEvent    AS LOGICAL
   LOCAL nPos      AS NUMERIC
   LOCAL cValue    AS STRING

   aUciNames := Directory( GetStartupFolder() + "\res\*.uci" )
   //MSGBOX('FILE = ' +  GetStartupFolder() + "\res\" )
   LenUci    := Len( AUciNames )

   FOR i := 1 TO lenUci
       cName  := aUciNames[ i, 1 ]
       cFile  := MemoRead( GetStartupFolder() + "\res\" + aUciNames[i][1] )
       nLines := MLCount( cFile, 1000 )
       lEvent := .F.

       FOR nLine := 3 TO nLines
           cLine := AllTrim( MemoLine( cFile, 1000, nLine, NIL, .T. ) )

           **********************
           nPos := At( ",", cLine )

           IF nPos > 0
              cValue := SubStr( cLine, nPos+1, Len( cLine ) )   //? Is it used
              cLine  := SubStr( cLine, 1     , nPos - 1 )
           ENDIF

           ****************************
           // MsgBox( "cLine= " + cLine )
           // cLine := Upper( cLine )
           IF Len( cLine ) > 0

              IF lEvent = .F.

                 IF Upper( cLine ) # "NAME"   .AND. ;
                    Upper( cLine ) # "ROW"    .AND. ;
                    Upper( cLine ) # "COL"    .AND. ;
                    Upper( cLine ) # "WIDTH"  .AND. ;
                    Upper( cLine ) # "HEIGHT"

                    IF Upper( cLine ) # "[EVENTS]"
                       AAdd( aPropTemp, cLine )
                    ELSE
                       AAdd( aUciProps, aPropTemp )
                       aPropTemp := {}
                       lEvent    := .T.
                    ENDIF
                 ENDIF
              ELSE
                 IF Len( cLine ) > 0
                    AAdd( aPropTemp, cLine )
                 ENDIF
              ENDIF
           ENDIF

       NEXT nLine

       AAdd( aUciEvents, aPropTemp )

       aPropTemp := {}
       cName     := SubStr( cName, 1, Len( cName ) - 4 )
       cName     := Upper( cName )

       AAdd( aUciControls, cName )

   NEXT i

   OpenUci()

RETURN


*------------------------------------------------------------*
PROCEDURE UcitoArray( ControlName AS STRING )
*------------------------------------------------------------*
   LOCAL i           AS NUMERIC
   LOCAL cFile       AS STRING
   LOCAL nLines      AS NUMERIC
   LOCAL nLine       AS NUMERIC
   LOCAL cLine       AS STRING
   LOCAL aPropUci    AS ARRAY   := {}
   LOCAL row         AS STRING
   LOCAL col         AS STRING
   LOCAL width       AS STRING
   LOCAL height      AS STRING
   LOCAL xArray3     AS ARRAY
   LOCAL cName       AS STRING
   LOCAL aPropTemp   AS ARRAY
   LOCAL cValue      AS STRING
   LOCAL cInitValue  AS STRING
   LOCAL nPos        AS NUMERIC

   IF CurrentControl # 1
      nTotControl += 1

      ObjectInspector.xCombo_1.AddItem( ControlName )

      ObjectInspector.xCombo_1.Value := ObjectInspector.xCombo_1.ItemCount

      //i := AScan( _HMG_aControlNames, ControlName )
      i      := GetControlIndex( ControlName, "Form_1" )
      row    := AllTrim( Str( _HMG_aControlRow[i]-_HMG_aControlContainerRow[i] ) )
      col    := AllTrim( Str( _HMG_aControlCol[i]-_HMG_aControlContainerCol[i] ) )
      width  := AllTrim( Str( _HMG_aControlWidth[i]  ) )
      height := AllTrim( Str( _HMG_aControlHeight[i] ) )

   ENDIF

   i         := Controls.xCombo_1.Value
   aPropTemp := {}
   cFile     := MemoRead( GetStartupFolder() + "\res\" + aUciNames[ i, 1 ] )
   cName     := aUciNames[ i, 1 ]
   cName     := SubStr( cName, 1, Len( cName ) - 4 )

   // MsgBox( "len= " + Str( Len( cName )) )
   AAdd( aPropTemp, Upper( cName ) )
   AAdd( aPropTemp, "DEFINE " + Upper( cName ) )
   AAdd( aPropTemp, AllTrim( ControlName ) )
   AAdd( aPropTemp, "ROW"    )
   AAdd( aPropTemp, Row      )
   AAdd( aPropTemp, "COL"    )
   AAdd( aPropTemp, Col      )
   AAdd( aPropTemp, "WIDTH"  )
   AAdd( aPropTemp, Width    )
   AAdd( aPropTemp, "HEIGHT" )
   AAdd( aPropTemp, Height   )

   nLines     := MLCount( cFile, 1000 )
   cInitValue := '""'

   FOR nLine := 3 to nLines
       cLine := AllTrim( MemoLine( cFile, 1000, nLine, NIL, .T. ) )
       // cLine := Upper( cLine )
       IF Upper( cLine ) = "[EVENTS]"
          cInitValue := "NIL"
       ENDIF

       **********************
       nPos := At( ",", cLine )
       IF nPos > 0
          cValue := SubStr( cLine, nPos+1, Len( cLine ) )
          cLine  := SubStr( cLine, 1     , nPos - 1 )
       ELSE
          cValue := cInitValue
       ENDIF
       **********************

       IF Len( cLine )   > 0          .AND. ;
          Upper( cLine ) # "[EVENTS]" .AND. ;
          Upper( cLine ) # "NAME"     .AND. ;
          Upper( cLine ) # "ROW"      .AND. ;
          Upper( cLine ) # "COL"      .AND. ;
          Upper( cLine ) # "WIDTH"    .AND. ;
          Upper( cLine ) # "HEIGHT"

          AAdd( aPropTemp, cLine  )
          AAdd( aPropTemp, cValue )

       ENDIF

   NEXT nLine

   AAdd( aPropTemp, "ENDPROP" )

   xArray3 := AClone( aPropTemp )

   // MsgBox("VALTYPE= "+ValType(xArray3) +" LEN= "+Str(Len(xArray2)) )
   nPos := nTotControl
   AEval( xArray3, { | x, y | xArray[ nPos, Y ] := xArray3[ Y ] } )

RETURN


*------------------------------------------------------------*
FUNCTION OpenUci()
*------------------------------------------------------------*
  IF LenUci > 0
     Controls.xCombo_1.DeleteAllitems
     Controls.xCombo_1.AddItem( "User Components..." )
     Controls.xCombo_1.Value := 1
   ENDIF
RETURN NIL


*------------------------------------------------------------*
FUNCTION ReloadUci()
*------------------------------------------------------------*
  LOCAL i     AS NUMERIC
  LOCAL cName AS STRING

  Controls.xCombo_1.DeleteAllitems

  // MsgBox( "len anames= " + Str( Len( aUciNames ) ) )

  FOR i := 1 TO lenUci
      cName := aUciNames[i][1]
      cName := SubStr( cName, 1, Len( cName ) - 4 )

      // MsgBox( "cname= " + cname )

      Controls.xCombo_1.AddItem( cname )
  NEXT

  Control_click( 0 )

RETURN NIL
