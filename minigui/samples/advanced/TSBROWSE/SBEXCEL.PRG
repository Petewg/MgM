#include "MiniGui.ch"
#include "TSBrowse.ch"
/*
#define CLR_PINK   RGB( 255, 128, 128)
*/
Function SBExcel()

  Local oBrw
  FIELD State,last
  MEMVAR aStates
  PUBLIC aStates := {}

  DbSelectArea( "Sta" )
  DbEval( { || AAdd(aStates, Sta->State ) } )
  DbSelectArea( "Employee" )
  Index on State+Last To StName

  IF ! _IsControlDefined ( "Font_1" , "Main" )
     DEFINE FONT Font_1  FONTNAME "Arial" SIZE 10
     DEFINE FONT Font_2  FONTNAME "Wingdings" SIZE 18
     DEFINE FONT Font_3  FONTNAME "MS Sans Serif" SIZE 12
     DEFINE FONT Font_4  FONTNAME "Arial" SIZE 14 BOLD ITALIC
     DEFINE FONT Font_5  FONTNAME "Arial" SIZE 12 UNDERLINE ITALIC
   endif

   DEFINE WINDOW Form_10 At 40,60 ;
         WIDTH 807 HEIGHT 542 ;
         TITLE "Report / Excel conectivity";
         ICON "Demo.ico";
         CHILD;

    DEFINE SPLITBOX
      DEFINE TOOLBAREX Bar_1 BUTTONSIZE 28, 28

         BUTTON Btn_1 PICTURE "Report" ;
            ACTION fReport(oBrw) ;
            TOOLTIP "Report from TSBrowse"

         BUTTON Btn_2 PICTURE "Excel16" ;
            ACTION fExcel( oBrw ) ;
            TOOLTIP "Export Browse to Excel"

         BUTTON Btn_3 PICTURE "Exitb16" ;
            ACTION Form_10.Release ;
            TOOLTIP "Exit"
      END TOOLBAR

      DEFINE TOOLBAREX Bar_2 CAPTION "Set Filter" BUTTONSIZE 28, 28

      BUTTON Btn_1a PICTURE "Tick" ;
            ACTION {|| ChangeFiltr(oBrw)};
            CHECK ;
            TOOLTIP "Activate Filter on TSBrowse"

      END TOOLBAR

      COMBOBOX Combo_1 ;
         ITEMS aStates;
         VALUE 1 ;
         HEIGHT 200 WIDTH 250 ;
         FONT 'Tahoma' SIZE 9 ;
         TOOLTIP 'List of States';
         ON CHANGE ChangeFiltr(oBrw)


    DEFINE TOOLBAREX Bar_3 CAPTION "Hide/Show Column" BUTTONSIZE 28, 28

      BUTTON Btn_31 PICTURE "Tick" ;
            ACTION {|| HideCol(oBrw, 3 ,1)};
            CHECK ;
            TOOLTIP "Hide/show  1 column in TSBrowse"

            BUTTON Btn_32 PICTURE "Tick" ;
            ACTION {|| HideCol(oBrw, {3,4,5},2 )};
            CHECK ;
            TOOLTIP "Hide/show  3 columns in TSBrowse"

      END TOOLBAR

    END SPLITBOX

      @ 35, 0 TBROWSE oBrw ALIAS "Employee"  WIDTH 800 HEIGHT 480  ;
           FONT "Font_1" CELL
      oBrw:LoadFields()
      oBrw:Exchange(3, 5)
      oBrw:ChangeFont(GetFontHandle( "Font_4" ), 0, 2 )
      oBrw:ChangeFont(GetFontHandle( "Font_1" ), 0, 1 )
      oBrw:ChangeFont(GetFontHandle( "Font_3" ), 3, 1 )
      oBrw:nWheelLines := 1

    END WINDOW

    ACTIVATE WINDOW Form_10

    RELEASE FONT Font_1
    RELEASE FONT Font_2
    RELEASE FONT Font_3
    RELEASE FONT Font_4
    RELEASE FONT Font_5

Return NIL

Function HideCol(oBrw,nCol,met)
   LOCAL lCheck
   IF met == 1
      lCheck :=Form_10.Btn_31.Value
   ELSE
      lCheck :=Form_10.Btn_32.Value
   endif
   IF lCheck
      oBrw:HideColumns( nCol, .t.)
   ELSE
      oBrw:HideColumns( nCol, .F.)
   ENDIF
RETURN Nil



FUNCTION ChangeFiltr(oBrw)
   LOCAL pos , cSelState

   IF Form_10.Btn_1a.Value == .t.
      pos:=Form_10.Combo_1.Value
      IF pos >0
          cSelState := SubStr(M->aStates[pos],1,2)
          oBrw:SetFilter( "State+Last", cSelState )
          oBrw:cPrefix := cSelState
          IF FieldGet(FieldPos("State")) != cSelState
            oBrw:Enabled(.f.)
          ELSE
            oBrw:Enabled(.T.)
          endif
          oBrw:Refresh( .T. )
          oBrw:lHasChanged := .T.
      endif

   ELSE
      cSelState := ""
      oBrw:SetFilter( "", cSelState )
      oBrw:Enabled(.T.)
      oBrw:Refresh( .T. )
   ENDIF

RETURN Nil


FUNCTION freport(oBrw)

   oBrw:Report( "Test Report", {1,2,3,4}, .T., .F., .T.,.F.  )

RETURN Nil


Function fExcel( oBrw, cFile, cTitle )

   Local lActivate, lSave, hFont, ;
         nVer    := 1

   Default cFile  := Padr( "NoName.xls", 60 ), ;
           cTitle := "TSBrowse/Excel Conectivity"

   lActivate := .T.
   lSave     := .F.
   cTitle    := PadR( cTitle, 60 )

   IF ! _IsControlDefined ("cFont1","Main")
      DEFINE FONT cFont1 FONTNAME "MS Sans Serif" SIZE 11
   endif
      hFont := GetFontHandle( "cFont1" )
    IF !IsWIndowDefined ("Form_11" )

      DEFINE WINDOW Form_11 At 150, 150 WIDTH 380 HEIGHT 240 ;
         TITLE cTitle CHILD TOPMOST


      @ 22,12 LABEL Lb1 VALUE "File: "  WIDTH 36

      @ 22 ,62 BTNTEXTBOX BtnTxt1 ;
         HEIGHT 18 ;
         WIDTH 282 ;
         VALUE cFile ;
         ACTION {||Form_11.BtnTxt1.Value:= PadR( fSaveFile(cFile), 60 ) }

      @ 54, 12 LABEL Lb2 VALUE "Title "   WIDTH 38

      @ 54 ,62 GETBOX Get_1 ;
         HEIGHT 18;
         WIDTH 282;
         VALUE cTitle;
         ON LOSTFOCUS { || cTitle := Form_11.Get_1.Value }

      @ 86 ,62 CHECKBOX Chk_1;
         CAPTION "Open Excel"  ;
         WIDTH 100 HEIGHT 32 ;
         VALUE lActivate

      @ 78 ,164 RADIOGROUP Radio_1 ;
         OPTIONS { "Excel 2", "Excel Ole"};
         VALUE nVer;
         WIDTH 100 ;
         SPACING 22 ;
         ON CHANGE { || nVer := Form_11.Radio_1.Value }

      @ 86 ,286 CHECKBOX Chk_2;
         CAPTION "Save File"  ;
         WIDTH 100 HEIGHT 32 ;
         VALUE lSave

         @ 132 ,72 BUTTON Btn_1;
            CAPTION "&Accept" ;
            ACTION {|| lSave := Form_11.Chk_2.Value, lActivate := Form_11.Chk_1.Value, ;
               If( nVer == 2, ;
               oBrw:ExcelOle( Form_11.BtnTxt1.Value, lActivate,GetControlHandle ( "Progress_1", "Form_11" ) , cTitle , hFont, lSave ),;
               oBrw:Excel2( Form_11.BtnTxt1.Value, lActivate,GetControlHandle ( "Progress_1", "Form_11" ) , { cTitle, GetFontHandle( "Font_3" ) } , lSave ) ),;
               Form_11.Release };
            WIDTH 76 HEIGHT 24

         @ 132 ,198 BUTTON Btn_2;
            CAPTION"&Exit"  ;
            ACTION Form_11.Release ;
            WIDTH 76 HEIGHT 24

         @ 172 ,12 PROGRESSBAR Progress_1;
            RANGE 1 , 100;
            VALUE 0;
            WIDTH 336 HEIGHT 24


      END WINDOW

      ACTIVATE WINDOW Form_11
      RELEASE FONT cFont1
      oBrw:Refresh( .T. )

   endif

Return Nil


Static Function fSaveFile(cFile)

RETURN  PutFile ( {{"Excel Book (*.xls)" ,"*.xls"}} ,"Select the file" ,  , .T. , cFile )
