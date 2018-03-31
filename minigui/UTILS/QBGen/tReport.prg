/*******************************************************************************
    Filename        : tReport.prg
    URL             : \\ServerName\Minigui\UTILS\QBGen\tReport.prg

    Created         : 26 October 2017 (13:15:11)
    Created by      : Pierpaolo Martinello

    Last Updated    : 27 December 2017 (15:28:51)
    Updated by      : Pierpaolo

    Comments        : RetEditArr                  Line 209
*******************************************************************************/
#include <hmg.ch>
#include "i_winuser.ch"
#include "dbstruct.ch"
#include "hbzebra.ch"

#define GDER      GRID_JTFY_RIGHT
#define GIZQ      GRID_JTFY_LEFT
#define GCEN      GRID_JTFY_CENTER

#define HDN_ITEMCHANGINGA       (HDN_FIRST-0)
#define HDN_ITEMCHANGEDA        (HDN_FIRST-1)

// ** CONSTANTS (nControl) ***
#define _GRID_COLUMNCAPTION_    -1   // _HMG_aControlPageMap   [i]
#define _GRID_ONHEADCLICK_      -2   // _HMG_aControlHeadClick [i]
#define _GRID_COLUMNWIDTH_       2   // _HMG_aControlMiscData1 [i,2]
#define _GRID_COLUMNJUSTIFY_     3   // _HMG_aControlMiscData1 [i,3]
#define _GRID_DYNAMICFORECOLOR_ 11   // _HMG_aControlMiscData1 [i,11]
#define _GRID_DYNAMICBACKCOLOR_ 12   // _HMG_aControlMiscData1 [i,12]
#define _GRID_COLUMNCONTROLS_   13   // _HMG_aControlMiscData1 [i,13]
#define _GRID_COLUMNVALID_      14   // _HMG_aControlMiscData1 [i,14]
#define _GRID_COLUMNWHEN_       15   // _HMG_aControlMiscData1 [i,15]

#define NTrim( n ) LTRIM( STR( n,20, IF( n == INT( n ), 0, set(_SET_DECIMALS) ) ))
#TRANSLATE ZAPS(<X>) => ALLTRIM(STR(<X>))
#define msgtest( c ) MSGSTOP( "Procedura: "+Procname()+CRLF+c, hb_ntos(procline()))
#define COMMA IF (!Ton,' ;','')

//-----------------------------------------//
// To customize the messages to user
#DEFINE LANG_EN    // Enables LANG_EN tag
//-----------------------------------------//
#IFDEF LANG_EN

#DEFINE RPT_DEFAULT              "Default"
#DEFINE RPT_NO                   "No"
#DEFINE RPT_YES                  "Yes"
#DEFINE RPT_PORTRAIT             "Portrait"
#DEFINE RPT_LANDSCAPE            "Landscape"

#DEFINE RPT_HEADER               '       Fields ->'
#DEFINE RPT_HEADER1              "Header 1"
#DEFINE RPT_HEADER2              "Header 2"
#DEFINE RPT_WIDTH                "Width"
#DEFINE RPT_TOTALS               "Totals"
#DEFINE RPT_FORMATS              "nFormats"

#DEFINE RPT_DEF_IMAGE            'Image '
#DEFINE RPT_DEF_MULTIPLE         'Multiple'
#DEFINE RPT_DEF_MULTIPLE_OPT1    "Image"
#DEFINE RPT_DEF_MULTIPLE_OPT2    "Every"
#DEFINE RPT_DEF_MULTIPLE_OPT3    "Page"
#DEFINE RPT_DEF_MULTIPLE_OPT4    RPT_DEFAULT+" "+RPT_NO


#DEFINE RPT_DEF_LPP              'Lpp'           // Lines Per Page
#DEFINE RPT_DEF_LPP_DEFAULT      RPT_DEFAULT+" 50"

#DEFINE RPT_DEF_CPL              'Cpl'           // Characters Per Line
#DEFINE RPT_DEF_CPL_VALID        "Valid        "
#DEFINE RPT_DEF_CPL_RANGE1       "80 - 96"
#DEFINE RPT_DEF_CPL_RANGE2       "120 - 140"
#DEFINE RPT_DEF_CPL_RANGE3       "160"

#DEFINE RPT_DEF_LEFTMARGIN       'Left Margin'
#DEFINE RPT_DEF_LEFTMARGIN_DF    RPT_DEFAULT+"  0 "
#DEFINE RPT_DEF_TOPMARGIN        'Top Margin'
#DEFINE RPT_DEF_TOPMARGIN_DF     RPT_DEFAULT+"  1 "

#DEFINE RPT_DEF_PAPERSZ          'Papersize'
#DEFINE RPT_DEF_PAPERSZ_DF1      RPT_DEFAULT+"     "
#DEFINE RPT_DEF_PAPERSZ_DF2      "Letter"

#DEFINE RPT_DEF_DOSMODE          'Dosmode'
#DEFINE RPT_DEF_DOSMODE_DF       RPT_DEFAULT+" "+RPT_NO

#DEFINE RPT_DEF_PREVIEW          'Preview'
#DEFINE RPT_DEF_PREVIEW_DF       RPT_DEFAULT+" "+RPT_YES

#DEFINE RPT_DEF_PRINTER          'Select Printer'
#DEFINE RPT_DEF_PRINTER_DF       RPT_DEFAULT+" "+RPT_NO

#DEFINE RPT_DEF_GROUPED          'Grouped By'
#DEFINE RPT_DEF_GROUPED_DF1      RPT_DEFAULT+"     "
#DEFINE RPT_DEF_GROUPED_DF2      "NONE"

#DEFINE RPT_DEF_GRPHEADER        'Group Header'
#DEFINE RPT_DEF_ORIENT           'Orientation'
#DEFINE RPT_DEF_ORIENT_DF1       RPT_DEFAULT+"     "
#DEFINE RPT_DEF_ORIENT_DF2       RPT_PORTRAIT

#DEFINE RPT_DEF_NODATETIME       'NoDateTimeStamp'
#DEFINE RPT_DEF_NODATETIME_DF    RPT_DEFAULT+" "+RPT_NO

#DEFINE OPT_NOTSUMINFIELD        "You can not sum this field !"

#DEFINE LBL_APPTITLE             "URE: User Report Editor"
#DEFINE LBL_TITLE                "Title:"
#DEFINE LBL_SUBTITLE             "Subtitle:"
#DEFINE MNU_DELETECOLUMN         "Delete a focused column. "
#DEFINE BRW_HDR_OPTIONS          "     Options"
#DEFINE BRW_HDR_VALUE            "            Value"
#DEFINE BRW_HDR_FROMROW          "AT <Row>"
#DEFINE BRW_HDR_FROMCOL          "At <Col> "
#DEFINE BRW_HDR_TOROW            "TO <Row>"
#DEFINE BRW_HDR_TOCOL            "To <Col>"

#DEFINE LBL_MOVEFIELDS           "Move Fields"
#DEFINE LBL_IMPORT               "&Import Rpt"
#DEFINE LBL_TEST                 "&Test"
#DEFINE LBL_SAVE                 "&Save"
#DEFINE LBL_BCODE                "&Barcode"

#DEFINE GF_ALLIMAGES             'All images'
#DEFINE GF_JPGFILES              'JPG Files'
#DEFINE GF_BMPFILES              'BMP Files'
#DEFINE GF_GIFIMAGES             'GIF Files'
#DEFINE GF_OPENIMAGE             'Open Image'

// TREPORT()

#DEFINE MSG_WANTWINREPORT        "Do you want use a Winreport Interpreter Template ?"
#DEFINE MSG_QUESTION             "Question"
#DEFINE QUES_SAVECHANGES         '   Do you have saved your latest change ?'
#DEFINE QUES_TITLE               'Remember'
#DEFINE GF_WINREPOINTERPRETER    'Windows Report Interpreter'
#DEFINE GF_WINREPOEXTENSION      '*.Wrpt'
#DEFINE GF_OPENREPORT            'Open Report Template'
#DEFINE GF_ALLREPORTS            'All report'
#DEFINE GF_RPTFILES              'RPT Files'
#DEFINE GF_ALLFILES              "All files (*.*)"
#DEFINE GF_REPORTFILES           "Report files"
#DEFINE GF_RPTEXTENSION          '*.Rpt'

#DEFINE IW_ENTERCHOICE           'Enter choice for saving format '
#DEFINE IW_OUTPUTFORMAT          'Output format :'
#DEFINE IW_FORMTEMPLATE          "Form Template"
#DEFINE IW_PREVIEW               "Enable Preview"
#DEFINE IW_FORMPRG               "Standard Prg"
#DEFINE IW_ROWCOL                "W-R-Int. ( as RowCol )"
#DEFINE IW_MM                    "W-R-Int. ( as MM )"
#DEFINE IW_MINIPRINT             "W-R-Int. ( as MiniPrint using MM )"
#DEFINE IW_PDF                   "W-R-Int. ( as PdfPrint using MM )"
#DEFINE IW_NOTE                  " Note: using MM, manual adjustments may be necessary."

#DEFINE MSG_FILECREATED          'File was created...'
#DEFINE ERR_UNPROPERREPORT       "Error: Unproper Report."+CRLF+CRLF+"Restart the utility !"
#DEFINE ERR_001                  "Forced Exit in Headers"
#DEFINE ERR_002                  "Forced Exit in Fields"
#DEFINE ERR_003                  "Forced Exit in Widths"
#DEFINE ERR_004                  "Forced Exit in Totals"
#DEFINE ERR_005                  "Forced Exit in Nformats"
#DEFINE ERR_007                  "An error occurred in the printer's management"

#DEFINE ERR_ERRORMSG             "Error"
#DEFINE ERR_DONTGROUPMEMO        "You can not group on MEMO Fields !"

#DEFINE MSG_AREYOUSURE           "Are you sure ?"
#DEFINE MSG_DELETINGCOLS         "Deleting Column "

#DEFINE MSG_FILEMISSING          "File Missing: Aborting."
#DEFINE MSG_REQUIREDFILE         "The function require an "
#DEFINE MSG_BARCODEWARN          "Option barcode not aivalable in this format!"

#DEFINE BR_NOPRINT               "ChangeMe Now"
#DEFINE BR_LBL_TYPE              "Select a Type"
#DEFINE BR_LBL_CODE              "Enter the code"
#DEFINE BR_LINE                  "Line "+RPT_WIDTH
#DEFINE BR_HEIGHT                "Barcode Height"
#DEFINE BR_WIDE                  " Wide "
#DEFINE BR_DISPLAY1              " Display the code "
#DEFINE BR_DISPLAY2              "inside the barcode "
#DEFINE BR_DISPLAY3              "out the barcode "
#DEFINE MSG_INVALIDCHECKSUM      "Invald checksum selected !"
#DEFINE BR_NOCHECK               "No other checksum"
#DEFINE BR_TTFIELD               "You can use a database field with: FIELD->Yourfield"
#DEFINE BR_TTSAVEAS              "Save as image"
#DEFINE BR_TEST                  space(20)+"Click here for test the barcode now!"

#ENDIF

//-----------------------------------------//
#IFDEF LANG_ES
#DEFINE RPT_DEFAULT              "Predefinido"
#DEFINE RPT_NO                   "No"
#DEFINE RPT_YES                  "Sí"
#DEFINE RPT_PORTRAIT             "Vertical"
#DEFINE RPT_LANDSCAPE            "Apaisado"

#DEFINE RPT_HEADER               '       Campos ->'
#DEFINE RPT_HEADER1              "Cabecera 1"
#DEFINE RPT_HEADER2              "Cabecera 2"
#DEFINE RPT_WIDTH                "Anchura"
#DEFINE RPT_TOTALS               "Totales"
#DEFINE RPT_FORMATS              "Formatos"

#DEFINE RPT_DEF_IMAGE            'Imagen'
#DEFINE RPT_DEF_MULTIPLE         'Múltiple'
#DEFINE RPT_DEF_MULTIPLE_OPT1    "Imagen"
#DEFINE RPT_DEF_MULTIPLE_OPT2    "Cada"
#DEFINE RPT_DEF_MULTIPLE_OPT3    "Pág"
#DEFINE RPT_DEF_MULTIPLE_OPT4    RPT_DEFAULT+" "+RPT_NO


#DEFINE RPT_DEF_LPP              'LPP'           // Lines Per Page
#DEFINE RPT_DEF_LPP_DEFAULT      RPT_DEFAULT+" 50"

#DEFINE RPT_DEF_CPL              'CPL'           // Characters Per Line
#DEFINE RPT_DEF_CPL_VALID        "Válido       "
#DEFINE RPT_DEF_CPL_RANGE1       "80 - 96"
#DEFINE RPT_DEF_CPL_RANGE2       "120 - 140"
#DEFINE RPT_DEF_CPL_RANGE3       "160"

#DEFINE RPT_DEF_LEFTMARGIN       'Margen Izq'
#DEFINE RPT_DEF_LEFTMARGIN_DF    RPT_DEFAULT+"  0 "
#DEFINE RPT_DEF_TOPMARGIN        'Margen Sup'
#DEFINE RPT_DEF_TOPMARGIN_DF     RPT_DEFAULT+"  1 "

#DEFINE RPT_DEF_PAPERSZ          'Tam.Hoja'
#DEFINE RPT_DEF_PAPERSZ_DF1      RPT_DEFAULT+"     "
#DEFINE RPT_DEF_PAPERSZ_DF2      "Carta "

#DEFINE RPT_DEF_DOSMODE          'Dosmode'
#DEFINE RPT_DEF_DOSMODE_DF       RPT_DEFAULT+" "+RPT_NO

#DEFINE RPT_DEF_PREVIEW          'Previsualizar'
#DEFINE RPT_DEF_PREVIEW_DF       RPT_DEFAULT+" "+RPT_YES

#DEFINE RPT_DEF_PRINTER          'Elegir Impresora'
#DEFINE RPT_DEF_PRINTER_DF       RPT_DEFAULT+" "+RPT_NO

#DEFINE RPT_DEF_GROUPED          'Agrupar por'
#DEFINE RPT_DEF_GROUPED_DF1      RPT_DEFAULT+"     "
#DEFINE RPT_DEF_GROUPED_DF2      "NADA"

#DEFINE RPT_DEF_GRPHEADER        'Tit.Grupo'
#DEFINE RPT_DEF_ORIENT           'Orientación'
#DEFINE RPT_DEF_ORIENT_DF1       RPT_DEFAULT+"     "
#DEFINE RPT_DEF_ORIENT_DF2       RPT_PORTRAIT

#DEFINE RPT_DEF_NODATETIME       'Sin Fecha/Hora'
#DEFINE RPT_DEF_NODATETIME_DF    RPT_DEFAULT+" "+RPT_NO

#DEFINE OPT_NOTSUMINFIELD        "¡ Campo no acumulable !"

#DEFINE LBL_APPTITLE             "EIU: Editor Informes de Usuario"
#DEFINE LBL_TITLE                "Título:"
#DEFINE LBL_SUBTITLE             "Subtítulo:"
#DEFINE MNU_DELETECOLUMN         "Elimina columna elegida"
#DEFINE BRW_HDR_OPTIONS          "     Opciones"
#DEFINE BRW_HDR_VALUE            "            Valor"
#DEFINE BRW_HDR_FROMROW          "Desde <Linea>"
#DEFINE BRW_HDR_FROMCOL          "Desde <Columna>"
#DEFINE BRW_HDR_TOROW            "A <Linea>"
#DEFINE BRW_HDR_TOCOL            "A <Columna>"

#DEFINE LBL_MOVEFIELDS           " Mover Campos"
#DEFINE LBL_IMPORT               "&Importar Rpt"
#DEFINE LBL_TEST                 "&Probar"
#DEFINE LBL_SAVE                 "&Guardar"
#DEFINE LBL_BCODE                "&Barcode"

#DEFINE GF_ALLIMAGES             'Todas las Imágenes'
#DEFINE GF_JPGFILES              'Archivos JPG'
#DEFINE GF_BMPFILES              'Archivos BMP'
#DEFINE GF_GIFIMAGES             'Archivos GIF'
#DEFINE GF_OPENIMAGE             'Abrir imagen'

// TREPORT()

#DEFINE MSG_WANTWINREPORT        "¿ Quiere usar el Modelo de Informe de WinReport ?"
#DEFINE MSG_QUESTION             "Pregunta"
#DEFINE QUES_SAVECHANGES         '¿ Guardó los últimos cambios ?'
#DEFINE QUES_TITLE               'Recordar'
#DEFINE GF_WINREPOINTERPRETER    'Intérprete de Informes de Windows'
#DEFINE GF_WINREPOEXTENSION      '*.Wrpt'
#DEFINE GF_OPENREPORT            'Abrir Modelo de Informe'
#DEFINE GF_ALLREPORTS            'Todos los Informes'
#DEFINE GF_RPTFILES              'Informes RPT'
#DEFINE GF_ALLFILES              "Todos los archivos (*.*)"
#DEFINE GF_REPORTFILES           "Arhivos de Informes"
#DEFINE GF_RPTEXTENSION          '*.Rpt'

#DEFINE IW_ENTERCHOICE           'Elige las opciones de guardado'
#DEFINE IW_OUTPUTFORMAT          'Salvo que se:'
#DEFINE IW_FORMTEMPLATE          "Plantilla de Formulario"
#DEFINE IW_PREVIEW               "Con vista previa"
#DEFINE IW_FORMPRG               "En formato PRG "
#DEFINE IW_ROWCOL                "W-R-Int.( como RowCol )"
#DEFINE IW_MM                    "W-R-Int.( como MM )"
#DEFINE IW_MINIPRINT             "W-R-Int.( como MiniPrint en MM )"
#DEFINE IW_PDF                   "W-R-Int.( como PdfPrint en MM )"
#DEFINE IW_NOTE                  "Nota: usando MM, pueden ser necesarios ajustes manuales."

#DEFINE MSG_FILECREATED          'Archivo creado.'
#DEFINE ERR_UNPROPERREPORT       "Error: Informe Erróneo."+CRLF+CRLF+"¡Reinicia la utilidad !"
#DEFINE ERR_001                  "Salida forzada en Cabecera"
#DEFINE ERR_002                  "Salida forzada en Campos"
#DEFINE ERR_003                  "Salida forzada en Anchura"
#DEFINE ERR_004                  "Salida forzada en Totales"
#DEFINE ERR_005                  "Salida forzada en Formatos"
#DEFINE ERR_007                  "Ocurrió un error en el Administrador de Impresora"

#DEFINE ERR_ERRORMSG             "Error"
#DEFINE ERR_DONTGROUPMEMO        "¡ No puede agrupar campos MEMO !"

#DEFINE MSG_AREYOUSURE           "¿ Está Seguro ?"
#DEFINE MSG_DELETINGCOLS         "Eliminando columna "

#DEFINE MSG_FILEMISSING          "Archivo Inexistente: Finalizando."
#DEFINE MSG_REQUIREDFILE         "La función necesita un "
#DEFINE MSG_BARCODEWARN          "¡Opción código de barras no aivalable en este formato! "

#DEFINE BR_NOPRINT               "Ahora cámbiame"
#DEFINE BR_LBL_TYPE              "Seleccione un tipo"
#DEFINE BR_LBL_CODE              "Ingrese el código"
#DEFINE BR_LINE                  "Línea "+RPT_WIDTH
#DEFINE BR_HEIGHT                "Altura de código de barras"
#DEFINE BR_WIDE                  " Amplio "
#DEFINE BR_DISPLAY1              " Mostrar el código "
#DEFINE BR_DISPLAY2              "dentro del código de barras "
#DEFINE BR_DISPLAY3              "bajo el código de barras "
#DEFINE MSG_INVALIDCHECKSUM      "¡Checksum no válido seleccionado!"
#DEFINE BR_NOCHECK               "No otro checksum"
#DEFINE BR_TTFIELD               "Puede utilizar campos de base de datos con: FIELD->"
#DEFINE BR_TTSAVEAS              "Guardar como imagen"
#DEFINE BR_TEST                  space(3)+"Haga clic aquí para la prueba el código de barras ahora!"

#ENDIF

MEMVAR aTypeItems, aValues, bbcode, aFlags
*-----------------------------------------------------------------------------*
PROCEDURE URE( aHdr1,alen1 )
*-----------------------------------------------------------------------------*
Local ahdr := { RPT_HEADER }  , aLen := {105}, ni
Local  aH1 := { RPT_HEADER1 } , aH2  := { RPT_HEADER2 }, aRows :={}
Local   aW := { RPT_WIDTH }   , aTot := { RPT_TOTALS } , aFo   := { RPT_FORMATS }
Local sBL1 := {{||.F.}} ,           IBL  := { {} },      bValid := {{||cKFld()} }
Local aValM:= {""} , Mlen := 0 , Bk4 ,mF := len( aHdr1 ) , OnHc
LOCAL nMax,  cTf ,  apaper:= aclone(apapeles) , aEdit3 ,   aGrp3:={"None","EVERY PAGE"}

LOCAL aEdit:={;           // types for 'DYNAMIC'
         { 'TEXTBOX','CHARACTER'}                ,;
         { 'TEXTBOX','CHARACTER'}                ,;
         { 'TEXTBOX','NUMERIC','9,999.99'}       ,;
         { 'CHECKBOX' , RPT_YES , RPT_NO }       ,;
         { 'TEXTBOX','CHARACTER'} }

LOCAL bBlock :={ |r,c| RetEditArr(aEdit, r, c) }
LOCAL bBlock3:={ |r,c| RetEditArr2(aEdit3, r, c) }
Local bBlock4:={ |r| SetFocusColumn( r ) }

local aRows3 := {;
                { RPT_DEF_IMAGE      ,"" ,0 ,0,0,0 },;
                { RPT_DEF_MULTIPLE   ,.F.,RPT_DEF_MULTIPLE_OPT1,RPT_DEF_MULTIPLE_OPT2,RPT_DEF_MULTIPLE_OPT3,RPT_DEF_MULTIPLE_OPT4 },;
                { RPT_DEF_LPP        ,50 ,RPT_DEF_LPP_DEFAULT,"","","" },;
                { RPT_DEF_CPL        ,80 ,RPT_DEF_CPL_VALID, RPT_DEF_CPL_RANGE1,RPT_DEF_CPL_RANGE2,RPT_DEF_CPL_RANGE3},;
                { RPT_DEF_LEFTMARGIN ,3  ,RPT_DEF_LEFTMARGIN_DF,"","",""},;
                { RPT_DEF_TOPMARGIN  ,3  ,RPT_DEF_TOPMARGIN_DF,"","","" },;
                { RPT_DEF_PAPERSZ    ,9  ,RPT_DEF_PAPERSZ_DF1,RPT_DEF_PAPERSZ_DF2,"","" },;
                { RPT_DEF_DOSMODE    ,.F.,RPT_DEF_DOSMODE_DF,"","","" },;
                { RPT_DEF_PREVIEW    ,.T.,RPT_DEF_PREVIEW_DF,"","","" } ,;
                { RPT_DEF_PRINTER    ,.F.,RPT_DEF_PRINTER_DF,"","",""},;
                { RPT_DEF_GROUPED    ,1  ,RPT_DEF_GROUPED_DF1,RPT_DEF_GROUPED_DF2,"","" },;
                { RPT_DEF_GRPHEADER  ,"" ,"","","","" },;
                { RPT_DEF_ORIENT     ,1  ,RPT_DEF_ORIENT_DF1,RPT_DEF_ORIENT_DF2,"","" },;
                { RPT_DEF_NODATETIME ,.F.,RPT_DEF_NODATETIME_DF,"","","" } }

Private BBCode := {0,0,BR_NOPRINT,"CODE128",10,5, ," ",0 ,1 } //array(10)
/*  Barcode
<row>       //1
<col>       //2
<txt>       //3
<type>      //4
<h>         //5
<w>         //6
[SUBTITLE]  //7
[INTERNAL]  //8
<flag>      //9
<cFlag>     //10
*/

REQUEST DBFCDX
RDDSETDEFAULT("DBFCDX")

aeval (apaper,{|x,y| apaper[y]:=substr(x,9,len(x) )} ) // remove "DMPAPER_"
aeval(aLen1, {|e,i| aLen1[i] := e/8})

IF "iif" $ aHdr1[1]
   hb_adel(aHdr1,1,.T.)
   mf --
EndIF
OnHc := { bBlock4 }

for ni = 1 to mf
    ctf  := tFld(aHdr1[ni])  // return a type of field
    aadd (OnHc, bblock4 )
    aadd (aHdr,aHdr1[ni])
    aadd (aGrp3,aHdr1[ni])
    aadd (sbl1,{||.T.} )
    aadd (bValid,{||cKFld()})
    aadd (aValm, OPT_NOTSUMINFIELD )
    aadd (IBL , { 'DYNAMIC', bBlock } )
    aadd ( aH1,"" )
    aadd ( aH2,aHdr1[ni] )
    aadd ( aW, aLen1[ni] )
    aadd ( aTot ,IF ( "N" $ ctf,.t.,.F.) )
    aadd ( aFo,tFld(aHdr1[ni],.T.) )
    // Grid Width
    nMax := GetTextWidth( 0, aHdr[ni] )
    nMax := Max( nMax, 50 )
    aadd (aLen,nMax)
Next

 aEdit3:={;           // types for 'DYNAMIC'  Grid 3
         { 'TEXTBOX','CHARACTER'}                    ,;      //    'Image ',"","","
         { 'CHECKBOX' , RPT_YES , RPT_NO }           ,;      //    'Multiple',"",""
         { 'TEXTBOX','NUMERIC'}                      ,;      //    'Lpp',"","","","
         { 'TEXTBOX','NUMERIC'}                      ,;      //    'Cpl',"","","","
         { 'TEXTBOX','NUMERIC'}                      ,;      //    'Lmargin',"","",
         { 'TEXTBOX','NUMERIC'}                      ,;      //    'Tmargin',"","",
         { 'COMBOBOX',apaper }                       ,;      //    'Papersize',"","
         { 'CHECKBOX' , RPT_YES , RPT_NO  }          ,;      //    'Dosmode',"","",
         { 'CHECKBOX' , RPT_YES , RPT_NO  }          ,;      //    'Preview',"","",
         { 'CHECKBOX' , RPT_YES , RPT_NO  }          ,;      //    'Select' ,"","",
         { 'COMBOBOX',aGrp3 }                        ,;      //    'Grouped By',"",
         { 'TEXTBOX','CHARACTER'}                    ,;      //    'Headrgrp',"",""
         { 'COMBOBOX', {RPT_PORTRAIT,RPT_LANDSCAPE} },;      //    'Landscape',"","
         { 'CHECKBOX' , RPT_YES , RPT_NO  } }                //    'Nodatetimestamp

bk4 := Getsyscolor( COLOR_APPWORKSPACE )

AADD( aRows, aH1 )
AADD( aRows, AH2 )
AADD( aRows, aW )
AADD( aRows, aTot )
AADD( aRows, aFo )

aeval(alen,{|x|mlen += x })
mlen += 20
Mlen := min (mlen,GetDesktopWidth ()-5)

IF IsWindowDefined("Form_2")
   Domethod( 'Form_2', 'Setfocus')
   Return
EndIF

        DEFINE WINDOW Form_2 ;
                AT 100,10 ;
                WIDTH mlen ;
                HEIGHT 515 ;
                TITLE LBL_APPTITLE  ;
                WINDOWTYPE STANDARD ;
                ON RELEASE EventRemoveAll () ;
                NOMAXIMIZE ;
                ON SIZE OnResize()

                DEFINE LABEL Title_1
                       COL 5
                       ROW 4
                       VALUE  LBL_TITLE
                       WIDTH 50
                       HEIGHT 25
                END LABEL

                @ 4, 40 TEXTBOX TITLE1 PARENT Win_1 WIDTH 230 HEIGHT 16 VALUE "" BACKCOLOR WHITE FONTCOLOR BLACK  FONT 'Arial' SIZE 9 ToolTip '' NOBORDER

                DEFINE LABEL Title_2
                       COL 287
                       ROW 4
                       VALUE  LBL_SUBTITLE
                       WIDTH 50
                       HEIGHT 25
                       RIGHTALIGN .T.
                END LABEL

                @ 4, 340 TEXTBOX TITLE2 PARENT Win_1 WIDTH 230 HEIGHT 16 VALUE "" BACKCOLOR WHITE FONTCOLOR BLACK  FONT 'Arial' SIZE 9 ToolTip '' NOBORDER

                @ 29,0 GRID Grid_2 ;
                WIDTH mlen ;
                HEIGHT 138 ;
                HEADERS ahdr ;
                WIDTHS aLen ;
                ITEMS aRows ;
                ON HEADCLICK OnHc ;
                EDIT ;
                INPLACE ibl ;
                COLUMNVALID bValid ;
                COLUMNWHEN sbl1 ;
                VALIDMESSAGES aValm ;
                CELLNAVIGATION ;
                VALUE {1, 2} ;

                DEFINE CONTEXT MENU CONTROL Grid_2 of Form_2
                       MENUITEM MNU_DELETECOLUMN ACTION DELETE_Col()
                END MENU

                @ 166,0 GRID Grid_3 ;
                WIDTH 640 ;
                HEIGHT 312 ;
                HEADERS { BRW_HDR_OPTIONS, BRW_HDR_VALUE , BRW_HDR_FROMROW, BRW_HDR_FROMCOL, BRW_HDR_TOROW  , BRW_HDR_TOCOL } ;
                WIDTHS  { 110,135,95,110,90,95} ;
                ITEMS aRows3 ;
                VALUE {1, 2} ;
                EDIT ;
                INPLACE { { } ,{ 'DYNAMIC',Bblock3 }, { 'DYNAMIC',Bblock3 } ,{ 'DYNAMIC',Bblock3 },{ 'DYNAMIC',Bblock3 },{ 'DYNAMIC',Bblock3 } } ;
                COLUMNWHEN { {||.F.},{||ckfld2()},{||CKFLD2()},{||CKFLD2()},{||CKFLD2()},{||CKFLD2()} } ;
                CELLNAVIGATION ;
                JUSTIFY {GIZQ,GIZQ,GCEN,GCEN,GCEN,GCEN} ;
                DYNAMICBACKCOLOR { nil, nil, { || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } ;
                                            ,{ || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } ;
                                            ,{ || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } ;
                                            ,{ || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } }

                @ 0, (ThisWindow.width -40) ButtonEx BL PARENT Form_2 CAPTION "" ACTION MOVE_COL(1)  WIDTH 30 FONT 'Arial' SIZE 9  Picture "Go_First" TOOLTIP "" NOTABSTOP
                @ 0, (ThisWindow.width -10) ButtonEx BR PARENT Form_2 CAPTION "" ACTION MOVE_COL(2)  WIDTH 30 FONT 'Arial' SIZE 9  Picture "Go_Last" TOOLTIP ""  NOTABSTOP

                DEFINE LABEL Mcol
                       COL ThisWindow.width -10
                       ROW 3
                       VALUE  LBL_MOVEFIELDS
                       WIDTH 40
                       HEIGHT 25
                       FONTNAME 'Arial'
                       FONTSIZE 7
                END LABEL


                @ 240, ThisWindow.width-100 Button B1 PARENT Form_2 CAPTION LBL_IMPORT ACTION TReport("IMPORT")   WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""
                @ 275, ThisWindow.width-100 Button B2 PARENT Form_2 CAPTION LBL_TEST   ACTION TReport("EXEC")       WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""
                @ 310, ThisWindow.width-100 Button B3 PARENT Form_2 CAPTION LBL_SAVE   ACTION TReport("SAVE")  WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""
                @ 395, ThisWindow.width-100 Button B4 PARENT Form_2 CAPTION LBL_BCODE  ACTION Wrbc()  WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""

                Form_2.grid_2.ColumnsAutoFitH

                UpdateStatus ( )

                CREATE EVENT PROCNAME EventHandler()

                ON KEY ESCAPE ACTION ThisWindow.Release

        END WINDOW

        Form_2.CENTER ;Form_2.ACTIVATE

        Release bbcode

RETURN
// Function used by codeblock bBlock4
*-----------------------------------------------------------------------------*
Procedure SetFocusColumn ( r )  // FOR GRID_2
*-----------------------------------------------------------------------------*
Form_2.Grid_2.VAlue := { 1, r }

RETURN

// Function used by codeblock bBlock from 'DYNAMIC' type return normal array used in INPLACE EDIT
*-----------------------------------------------------------------------------*
FUNCTION RetEditArr( aEdit, r, c )  // FOR GRID_2
*-----------------------------------------------------------------------------*
LOCAL aRet

   IF c > 1 .AND. r >= 1 .AND. r <= LEN(aEdit)
      aRet := aEdit[r]
   ELSE
     aRet := {"TEXTBOX","CHARACTER"}
   EndIF

RETURN aRet
/*
*/
// Function used by codeblock bBlock3
*-----------------------------------------------------------------------------*
FUNCTION RetEditArr2( aEdit3, r, c )  // FOR GRID_3
*-----------------------------------------------------------------------------*
LOCAL aRet

   IF c == 2 .AND. r >= 1 .AND. r <= LEN(aEdit3)
      aRet := aEdit3[r]
   ElseIF R=1 .and. C > 2
      aRet :=  { 'TEXTBOX','NUMERIC','9,999.99'}
   Else
      aRet := {"TEXTBOX","CHARACTER"}
   EndIF

RETURN aRet
/*
*/
*-----------------------------------------------------------------------------*
Procedure UpdateStatus()
*-----------------------------------------------------------------------------*
Local Ni, mlen := 0, h, Cols

     h := Form_2.Grid_2.HANDLE
  Cols := max(12, ListView_GetColumnCount ( h ) )

  for ni = 1 to Cols
      mLen += Form_2.grid_2.ColumnWIDTH(ni)
  Next
  Form_2.Width := mlen+20

RETURN
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION ckfld( )       // avoid sum on non numeric fields
*-----------------------------------------------------------------------------*
LOCAL aRet := .t. , cFldt
local nCol := This.CellColIndex
local nRow := This.CellRowIndex

   IF nRow = 4
      cFldt := DBFIELDINFO(DBS_TYPE, FieldPos(Form_2.grid_2.header(ncol)) )
      IF cFldt != "N" .and. This.CellValue = .T.
         aRet := .F.
      EndIF
   EndIF

RETURN aRet
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION ckfld2( )       // avoid use  of unused cells
*-----------------------------------------------------------------------------*
LOCAL aRet := .t., cImgFilName
local nCol := This.CellColIndex
local nRow := This.CellRowIndex

   IF nRow > 1 .and. nCol > 2
      aRet := .F.
   ElseIF nRow = 1 .and. Ncol = 2
      cImgFilName := Getfile( { {GF_ALLIMAGES,'*.jpg; *.bmp; *.gif'},;    // acFilter
                                {GF_JPGFILES, '*.jpg'},;
                                {GF_BMPFILES, '*.bmp'},;
                                {GF_GIFIMAGES, '*.gif'} },;
                                 GF_OPENIMAGE,,.F.,.T. )
      IF !EMPTY( cImgFilName ) .OR. FILE( cImgFilName )
          Form_2.Grid_3.cell(1,2):= cImgFilName
          aRet := .F.
      EndIF
   EndIF

RETURN aRet
/*
*/
*-----------------------------------------------------------------------------*
Procedure OnResize()
*-----------------------------------------------------------------------------*
    Local F2w
    IF Form_2.Width < 775
       Form_2.Width := 780
    EndIF
    IF Form_2.Height < IF(IsXPThemeActive(), 523, 520)
       Form_2.Height := IF(IsXPThemeActive(), 515, 507)
    EndIF

    ERASE WINDOW Form_2

    F2w := Form_2.WIDTH
    Form_2.Grid_2.Width  := F2w //-IF(IsXPThemeActive(), 5, 5)

    Form_2.BL.col   := F2w -125
    Form_2.BR.col   := F2w -45
    Form_2.Mcol.col := F2w -85
    Form_2.B1.col   := F2w -110
    Form_2.B2.col   := F2w -110
    Form_2.B3.col   := F2w -110
    Form_2.B4.col   := F2w -110

Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION EventHandler(nHWnd, nMsg, nWParam, nLParam)
*-----------------------------------------------------------------------------*
Local Hndl

  HB_SYMBOL_UNUSED( nHWnd )
  HB_SYMBOL_UNUSED( nWParam )

  IF IsWindowDefined("Form_2")
     hndl := Form_2.Grid_2.HANDLE
  EndIF

  IF nMsg == WM_NOTIFY

     IF GetHWNDFrom( nLParam ) == ListView_GetHeader( Hndl )

        IF GetNotifyCode( nLParam ) == HDN_ITEMCHANGEDA
           UpdateStatus()
        EndIF

     EndIF

  EndIF

RETURN NIL
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION tFld(cFld, LFmt)   // return a correct transform format template
*-----------------------------------------------------------------------------*
local cRval:="" , nFmt , nf ,dc :=0 , cFldt := DBFIELDINFO(DBS_TYPE, FieldPos( cFld ))
Local nLimit := DBFIELDINFO(DBS_LEN, FieldPos( cFld ))

DEFAULT Lfmt to .f.

nLimit := 1+ int (nLimit+nLimit/2 )
IF lFmt
   do case
      case cFldt = "N"
           nFmt := DBFIELDINFO(DBS_DEC, FieldPos( cFld ))
           for nf = 1 to nLimit
               cRval += "9"
               IF ++dc = 3
                  cRval += ","
                  dc := 0
               EndIF
           next
           cRval := CHARMIRR( cRval )
           IF Left( cRval, 1 ) = ","
              cRval := SubStr( cRval, 2 )
           EndIF
           IF nFmt > 0
              cRval += "." + repl( "9", nFmt )
           EndIF
           cRval := "@E "+ cRval
      case cFldt = "L"
           cRval := "Y"
   Endcase
Else
   cRval := DBFIELDINFO(DBS_TYPE, FieldPos( cFld ))
EndIF
REturn cRval
/*
*/
*-----------------------------------------------------------------------------*
procedure TReport(act,prv)   // Test the Report
*-----------------------------------------------------------------------------*
local h,cols, aHeaders1, aHeaders2 ,a := {} ,awidths ,ato,cSaveFile, cstr:='',ni
Local aFormats , aGrpby := {,"EVERY PAGE"}, cGraphic:= NIL , Title, aSrc := {}
Local Cstr2 := '', cFileimp, Ton, spt := space(3), nWrpt, Inde_On, aVo
Local rType := {"RC","HBPRINTER","MINIPRINT","PDFPRINT"},aDl := {} ,atd

DEFAULT act to "EXEC", prv to .F.

   h := Form_2.Grid_2.HANDLE
   Cols := ListView_GetColumnCount ( h )
   aHeaders1 := Form_2.Grid_2.Item (1)
   hb_adel(aHeaders1,1,.t.)
   aHeaders2 := Form_2.Grid_2.Item (2)
   hb_adel(aHeaders2,1,.t.)
   aWidths := Form_2.Grid_2.Item (3)
   hb_adel(aWidths,1,.t.)
   aTo := Form_2.Grid_2.Item (4)
   hb_adel(aTo,1,.t.)
   aFormats := Form_2.Grid_2.Item (5)
   hb_adel(aFormats,1,.t.)

   for ni = 2 to Cols
       aadd ( a, Form_2.Grid_2.Header( ni ) )
       aadd ( aGrpby, Form_2.Grid_2.Header( ni ) )
   Next

   Inde_On := aGrpby[Form_2.Grid_3.Cell( 11, 2 )]
   Title :=  Form_2.Title1.value

   IF !empty(Form_2.Grid_3.Cell( 1, 2 ) )
      cGraphic := Form_2.Grid_3.Cell( 1, 2 )
   EndIF

   IF !empty( Form_2.Title2.value )
      Title := Form_2.Title1.value+"|"+Form_2.title2.value
   EndIF

   // check deleted (hidden) colums
   For Ni = 1 to len(aHeaders2)
       IF Form_2.Grid_2.ColumnWidth(ni+1) = 0
          aadd (aDl,aheaders2[ni])
       EndIF
   Next
   For Ni = 1 to len(adl)
       atd := ascan(aheaders2,adl[ni])
       hb_adel(a,atd,.T.)
       hb_adel(aHeaders1,atd,.T.)
       hb_adel(aHeaders2,atd,.T.)
       hb_adel(awidths,atd,.T.)
       hb_adel(aTo,atd,.T.)
       hb_adel(aformats,atd,.T.)
   Next

   ( alias() )->( dbgotop() )

  Do Case
     Case act ="EXEC"
          check_db_Index ( Inde_On , Form_2.Grid_3.Cell( 11, 2 ) )
          nWrpt  := hb_DirScan(cFilePath( GetExeFileName() ), GF_WINREPOEXTENSION )
          IF len(nWrpt) > 0 .and. !Prv
             IF msgyesno( MSG_WANTWINREPORT ;
                         ,MSG_QUESTION,.T. )
                MessageBoxTimeout (QUES_SAVECHANGES, QUES_TITLE, MB_OK, 1000 )
                cFileimp := Getfile( { {GF_WINREPOINTERPRETER, GF_WINREPOEXTENSION}} ;
                                       ,GF_OPENREPORT, GetcurrentFolder() ,.f., .t. )
                IF !EMPTY( cFileimp )
                   WinRepint( cFileimp,,,,,.T.,)
                EndIF
                Return
             EndIF
          EndIF
          EasyReport (      ;
                 Title     ,;                                                 // Title
                 aheaders1 ,;                                                 // Header 1
                 aheaders2 ,;                                                 // Header 2
                 a         ,;                                                 // Fields
                 awidths   ,;                                                 // Widths
                 ato       ,;                                                 // Totals
                 Form_2.Grid_3.Cell( 3, 2 ) ,;                                // LPP
                 Form_2.Grid_3.Cell( 8, 2 ) ,;                                // Dos Mode
                 .T., ; // Form_2.Grid_3.Cell( 9, 2 ) ,;                      // Preview ALWAIS ACTIVE FOR TESTING
                 cGraphic  ,;                                                 // Image
                 Form_2.Grid_3.Cell( 1, 3 ) , Form_2.Grid_3.Cell( 1, 4 ) ,;   // At Row, At Col
                 Form_2.Grid_3.Cell( 1, 5 ) , Form_2.Grid_3.Cell( 1, 6 ) ,;   // To Row, To Ccol
                 Form_2.Grid_3.Cell( 2, 2 ) ,;                                // Multiple Image
                 aGrpby[Form_2.Grid_3.Cell( 11, 2 )] ,;                       // Group By
                 Form_2.Grid_3.Cell( 12, 2 ) ,;                               // Header Group
                 Form_2.Grid_3.Cell( 13, 2 )>1 ,;                             // Orientation
                 Form_2.Grid_3.Cell(  4, 2 ) ,;                               // Cpl
                 Form_2.Grid_3.Cell( 10, 2 ) ,;                               // Select Printer
                 Alias()   ,;                                                 // Workarea
                 Form_2.Grid_3.Cell(  5, 2 ) ,;                               // Margin Left
                 aformats  ,;                                                 // Formats
                 Form_2.Grid_3.Cell( 7, 2 ) ,;                                // Papersize
                 Form_2.Grid_3.Cell(  6, 2 ) ,;                               // Margin Top
                 Form_2.Grid_3.Cell( 14, 2 ) )                                // NoDateTimeStamp

    Case act = "IMPORT"
         cFileimp := Getfile( { {GF_ALLREPORTS, GF_RPTEXTENSION },;
                                {GF_RPTFILES  , GF_RPTEXTENSION } },;
                                 GF_OPENREPORT ,GetcurrentFolder() ,.f., .t.)

         IF !EMPTY( cFileimp ) .OR. FILE( cFileimp )
            Form_2.title := LBL_APPTITLE +" -> File " + cFileNoPath(cFileimp)
            bbcode[3] := BR_NOPRINT
            rReport( cFileimp , a ,aheaders2 )
         else
            return
         EndIF

    Case act ="SAVE"

         aVo := Scegli({IW_FORMTEMPLATE, IW_FORMPRG, IW_ROWCOL,IW_MM,IW_MINIPRINT,IW_PDF},IW_ENTERCHOICE, IW_NOTE ,1)

         IF aVo [1] = Nil
            Domethod( 'Form_2', 'Setfocus')
            return
         EndIF

         Ton := (aVo[1] = 1)

         IF Ton
            spt := space(7)
         EndIF

         cSaveFile := cFilePath(GetExeFileName())+ "\" + SubStr(Alias(),1,4) + IF(aVo[1] >= 3 ,'.Wrpt','.Rpt')

         IF aVo[1] < 3
            IF !empty(bbcode[4])
               MessageBoxTimeout ( MSG_BARCODEWARN, '', MB_OK, 1500 )
            EndIF

            cSaveFile := PutFile( {  {GF_REPORTFILES+" ("+GF_RPTEXTENSION+")", GF_RPTEXTENSION} ;
                                    ,{GF_WINREPOINTERPRETER+"  ("+GF_WINREPOEXTENSION+")",GF_WINREPOEXTENSION} ;
                                    ,{GF_ALLFILES, "*.*"} }, , , ,cSaveFile , 1 )
         Else
            cSaveFile := PutFile( { {GF_WINREPOINTERPRETER+" ("+GF_WINREPOEXTENSION+")",GF_WINREPOEXTENSION}  ;
                                   ,{GF_REPORTFILES+" ("+GF_RPTEXTENSION+")", GF_RPTEXTENSION} ;
                                   ,{GF_ALLFILES, "*.*"} }, , , ,cSaveFile , 1 )
         EndIF
         IF Empty( cSaveFile )
            return
         EndIF

         IF File(cSaveFile)
            DELETE FILE &(cSaveFile)
         EndIF

         IF aVo[1] >= 3       // WinReport Interpreter
            WrExport(cSavefile,aheaders1,aheaders2, aFormats ,a,aWidths,ato, Inde_On, rtype[aVo[1]-2],aVo[2] )
            Return
         EndIF

         IF Ton
            aadd(aSrc,'DEFINE REPORT TEMPLATE ')
         Else
            aadd(aSrc,'DO REPORT ;')
         EndIF
         aadd(aSrc,spt+'TITLE    '+[']+Title+[']+COMMA )
         aeval(aHeaders1,{|x| cStr +=[']+x+[',]} )
         aeval(aHeaders2,{|x| cStr2 +=[']+x+[',]} )
         aadd(aSrc,spt+'HEADERS  {' +REMRIGHT(cStr,',')+'} , {'+ REMRIGHT(cStr2,',')+'}'+COMMA )
         cStr :=''
         aeval(a,{|x| cStr +=[']+x+[',]} )
         aadd(aSrc,spt+'FIELDS   {'+REMRIGHT( cStr ,',')+'}'+COMMA )
         cStr :=''
         aeval( awidths, {|x|cstr += NTrim(x)+',' } )
         aadd(aSrc,spt+'WIDTHS   {'+REMRIGHT(cStr,",")+"}"+COMMA )
         cStr :=''
         aeval (ato,{|x| cStr += iif(x,'.T.','.F.')+[,]} )
         aadd(aSrc,spt+'TOTALS   {'+REMRIGHT(cStr,",")+"}"+COMMA )
         cStr :=''
         aeval(aFormats,{|x| cStr +=[']+x+[',]} )
         aadd(aSrc,spt+'NFORMATS {'+REMRIGHT( cStr ,',')+'}'+COMMA)
         aadd(aSrc,spt+'WORKAREA '+Alias()+ COMMA )
         aadd(aSrc,spt+'LPP      '+NTrim(Form_2.Grid_3.Cell( 3, 2 ))+COMMA )
         aadd(aSrc,spt+'CPL      '+NTrim(Form_2.Grid_3.Cell( 4, 2 ))+COMMA )
         aadd(aSrc,spt+'LMARGIN  '+NTrim(Form_2.Grid_3.Cell( 5, 2 ))+COMMA )
         aadd(aSrc,spt+'TMARGIN  '+NTrim(Form_2.Grid_3.Cell( 6, 2 ))+COMMA )
         aadd(aSrc,spt+'PAPERSIZE '+apapeles[Form_2.Grid_3.Cell( 7, 2 )]+COMMA )

         IF Form_2.Grid_3.Cell( 8, 2 )
            aadd(aSrc,spt+'DOSMODE' +COMMA )
         EndIF

         IF Form_2.Grid_3.Cell(  9, 2 )
            aadd(aSrc,spt+'PREVIEW'+COMMA )
         EndIF

         IF Form_2.Grid_3.Cell( 10, 2 )
            aadd(aSrc,spt+'SELECT'+COMMA )
         EndIF

         IF !empty( cGraphic )
         aadd(aSrc,spt+'IMAGE    {"'+cGraphic+'",'+NTrim(Form_2.Grid_3.Cell( 1, 3 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 4 )) ;
                                                 +','+NTrim(Form_2.Grid_3.Cell( 1, 5 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 6 ))+"}"+COMMA )
         EndIF

         IF Form_2.Grid_3.Cell(  2, 2 )
            aadd(aSrc,spt+'MULTIPLE'+COMMA )
         EndIF

         IF Form_2.Grid_3.Cell( 11, 2 ) > 1
            aadd(aSrc,spt+'GROUPED BY '+[']+aGrpby[Form_2.Grid_3.Cell( 11, 2 )]+[']+COMMA )
            aadd(aSrc,spt+'HEADRGRP '+[']+Form_2.Grid_3.Cell( 12, 2 )+[']+COMMA )
         EndIF

         IF Form_2.Grid_3.Cell( 13, 2 ) > 1
            aadd(aSrc,spt+'LANDSCAPE'+COMMA )
         EndIF

         IF Form_2.Grid_3.Cell(  14, 2 )
            aadd(aSrc,spt+'NODATETIMESTAMP'+COMMA)
         EndIF


         IF Ton
            aadd(aSrc,'END REPORT')
         Else
            aadd(aSrc,'')
         EndIF

         WriteFile(cSaveFile,aSrc)

         MessageBoxTimeout (MSG_FILECREATED, '', MB_OK, 1000 )

         IF aVo[2]
            TReport("EXEC",.T.)
         EndIF

     Endcase

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure rReport( cFile,nF,Field_name )   // Import the File Report
*-----------------------------------------------------------------------------*
local Hf:= hb_ATokens( MemoRead( cFile ), CRLF ), cObj, uVal, cTmp, nfl ,nFc
local aTrue :={".T.","T","TRUE","Y","S","1"}, aGrpby := {"NONE","EVERY PAGE"}
// local aFalse:={".N.","N","FALSE","0"}
aeval(hf,{|x,y|hf[y] := trim(x)})
aeval(nf,{|x|aadd(aGrpby,x) } )
nfl := len( nf )

Form_2.Grid_2.DisableUpdate
Form_2.Grid_3.DisableUpdate

// Set defaults
Form_2.Grid_3.Cell( 1, 2 ):= ''         // Image
Form_2.Grid_3.Cell( 1, 3 ):= 0          // AT ROW
Form_2.Grid_3.Cell( 1, 4 ):= 0          // AT COL
Form_2.Grid_3.Cell( 1, 5 ):= 0          // TO ROW
Form_2.Grid_3.Cell( 1, 6 ):= 0          // TO COL
Form_2.Grid_3.Cell( 2, 2 ):= .F.        // Multiple
Form_2.Grid_3.Cell( 3, 2 ):= 50         // Lpp
Form_2.Grid_3.Cell( 4, 2 ):= 80         // Cpl
Form_2.Grid_3.Cell( 5, 2 ):= 0          // Left Margin
Form_2.Grid_3.Cell( 6, 2 ):= 0          // Top Margin
Form_2.Grid_2.Cell( 5, 2 ):= 1          // Papersize LETTER
Form_2.Grid_3.Cell( 8, 2 ):= .F.        // Dosmode
Form_2.Grid_3.Cell( 9, 2 ):= .T.        // Preview
Form_2.Grid_3.Cell(10, 2 ):= .F.        // Select  Printer
Form_2.Grid_3.Cell(11, 2 ):= 1          // Group By
Form_2.Grid_3.Cell(12, 2 ):= ""         // Group Header
Form_2.Grid_2.Cell(13, 2 ):= 1          // Orientation PORTRAIT
Form_2.Grid_2.Cell(14, 2 ):= .F.        // NodateTimeStamp

For Each cObj in hf
    cObj := alltrim(REMRIGHT(cObj,';'))
    uVal := alltrim(substr(cObj ,rAt(" ",cObj) ) )

    Do Case
       Case "TITLE" $ cObj
            cTmp := alltrim(substr(ltrim(cobj),6))
            cTmp := ReplLeft(cTmp," ","'")
            cTmp := alltrim(ReplRight(cTmp," ","'"))

            IF "|" $ uVal
              Form_2.title1.value := substr(cTmp,1,at("|",cTmp)-1)
              Form_2.title2.value := substr(cTmp,at("|",cTmp)+1,len(cTmp)-1)
            Else
              Form_2.title1.value := cTmp
              Form_2.title2.value := ""
            EndIF

       Case "HEADERS" $ cObj
           cTmp:= SUBSTR(cObj,at("{",cObj) )
           uVal := at("}",cTmp )
           cTmp:= &(SUBSTR(cTmp,1,uVal ) )
           IF len( ctmp ) > nFl
              msgstop(ERR_UNPROPERREPORT, ERR_001)
              domethod("Form_2", "Release")
              exit
           EndIF
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 1, y+1 ):= x })
           cTmp:= SUBSTR(cObj,rat("{",cObj) )
           uVal := rat("}",cTmp )
           cTmp:= &(SUBSTR(cTmp,1,uVal ) )
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 2, y+1 ):= x })

        Case "FIELDS" $ cObj
           cTmp:= &(SUBSTR(REMRIGHT( cObj ,';'),at("{",cObj) ))
           IF len( ctmp ) > nFl
              msgstop(ERR_UNPROPERREPORT, ERR_002 )
              exit
           EndIF
           for nFc = 1 to len (Field_name)
               IF ascan(cTmp,Field_Name[nFc]) > 0
                  loop
               EndIF
               SetProperty ( "Form_2", "Grid_2" , "ColumnWidth" , nfc+1 , 0 )
           Next
           aeval(cTmp, {|x,y|Form_2.Grid_2.HEADER(y+1 ):= x })

       Case "WIDTHS" $ cObj
           cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
           IF len( ctmp ) > nFl
              msgstop(ERR_UNPROPERREPORT, ERR_003 )
              exit
           EndIF
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 3, y+1 ):= x })

       Case "TOTALS" $ cObj
           cTmp:= &(uVal)
           IF len( ctmp ) > nFl
              msgstop(ERR_UNPROPERREPORT, ERR_004 )
              exit
           EndIF
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 4, y+1 ):= x })

       Case "NFORMATS" $ cObj
           cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
           IF len( ctmp ) > nFl
              msgstop(ERR_UNPROPERREPORT, ERR_005 )
              exit
           EndIF
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 5, y+1 ):= x })

       Case "WORKAREA" $ cObj  //unused in this case
            // wArea := uval

       Case "LPP" $ cObj
            Form_2.Grid_3.Cell( 3, 2 ):= val(uval)

       Case "CPL" $ cObj
            Form_2.Grid_3.Cell( 4, 2 ):= val(uval)

       Case "LMARGIN" $ cObj
            Form_2.Grid_3.Cell( 5, 2 ):= val(uval)

       Case "TMARGIN" $ cObj
            Form_2.Grid_3.Cell( 6, 2 ):= val(uval)

       Case "PAPERSIZE" $ cObj
            Form_2.Grid_3.Cell( 7, 2 ):= ascan(apapeles,uval)

       Case "PREVIEW" $ cObj
            Form_2.Grid_3.Cell( 9, 2 ):= IF (upper(uVal)="PREVIEW",.T.,ascan(aTrue,uVal) > 0)

       case "SELECT" $ cObj
            Form_2.Grid_3.Cell( 10, 2 ):= IF (upper(uVal)="SELECT",.T.,ascan(aTrue,uVal) > 0)

       case "IMAGE" $ cObj
            cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
            aeval(cTmp, {|x,y|Form_2.Grid_3.Cell(1,y+1):= x })

       Case "MULTIPLE" $ cObj
            Form_2.Grid_3.Cell( 2, 2 ):= IF (upper(uVal)="MULTIPLE",.T.,ascan(aTrue,uVal) > 0)

       Case "DOSMODE" $ cObj
            Form_2.Grid_3.Cell( 8, 2 ):= IF (upper(uVal)="DOSMODE",.T.,ascan(aTrue,uVal) > 0)

       Case "LANDSCAPE" $ cObj
            Form_2.Grid_3.Cell( 13, 2 ):= IF (upper(uVal)="LANDSCAPE",2,IF(ascan(aTrue,UPPER(uVal))>0,1,2) )

       Case "PORTRAIT" $ cObj
            Form_2.Grid_3.Cell( 13, 2 ):= IF (upper(uVal)="PORTRAIT",1,IF(ascan(aTrue,UPPER(uVal))>0,1,2) )

       Case "NODATETIMESTAMP" $ cObj
            Form_2.Grid_3.Cell( 14, 2 ):= IF (upper(uVal)="NODATETIMESTAMP",.T.,ascan(aTrue,uVal) > 0)

       Case "GROUPED" $ cObj
            cTmp := upper(REMLEFT(REMRIGHT(SUBSTR(cObj,at("BY",cObj)+3),"'"),"'"))
            Form_2.Grid_3.Cell(11, 2 ):= ascan(aGrpby,ctmp)

       Case "HEADRGRP" $ cObj
            Form_2.Grid_3.Cell(12, 2 ):= REMLEFT(REMRIGHT(UVAL,"'"),"'")

    EndCase
next
Form_2.Grid_2.EnableUpdate
Form_2.Grid_3.EnableUpdate
*/
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE MOVE_Col (action)
*-----------------------------------------------------------------------------*
LOCAL aux,nCol_Disp, cCnt, aCv := Array(5),cv , aVt := Array(5),aHo, aHd
Local NoCln := 1

    aux := get_col()
    IF aux [1] > 0
       nCol_Disp := aux [1]
       cCnt := aux[2]
    Else
       Return
    EndIF

    IF action = 1
       nCol_Disp := nCol_Disp - noCln  // Move column: LEFT
    ELSE             // = 2
       nCol_Disp := nCol_Disp + Nocln  // Move column: RIGTH
    EndIF

    IF Form_2.Grid_2.ColumnWidth(nCol_Disp) = 0    // Emulate Column deletion
       NoCln := 2
       IF action = 1
          nCol_Disp --  // Move column: LEFT
       ELSE             // = 2
          nCol_Disp ++  // Move column: RIGTH
       EndIF
    EndIF
    */
    IF nCol_Disp >= 2 .AND. nCol_Disp <= cCnt
       // Move Header
       aho := Form_2.Grid_2.HEADER(nCol_disp)                                   // Colum destination
       aHd := Form_2.Grid_2.HEADER( nCol_disp+ IF(action=1,NoCln,-NoCln))       // Column to move

       Form_2.Grid_2.HEADER(nCol_disp):= aHd
       Form_2.Grid_2.HEADER( nCol_disp+ IF(action=1,NoCln,-NoCln)):= aHo

       // Move Columns
       for each cv in aCv
           aCv[cv:__enumIndex()]:=Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp )
           aVt[cv:__enumIndex()]:=Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp+ IF(action=1,NoCln,-NoCln))
           Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp ):= aVt[cv:__enumIndex()]
           Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp+ IF(action=1,NoCln,-NoCln) ) := aCv[cv:__enumIndex()]
       Next
*/
       Form_2.Grid_2.setfocus
       Form_2.Grid_2.VAlue := {1,nCol_Disp }

    EndIF

    Form_2.Grid_2.Refresh
RETURN
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION GRID_GetColumnDisplayPos ( cControlName, cParentForm, nColIndex )
*-----------------------------------------------------------------------------*
   LOCAL nPos, ArrayOrder
   IF ValType ( cParentForm ) == "U"
      cParentForm := ThisWindow.Name
   EndIF

   // LISTVIEW_GETCOLUMNORDERARRAY: Low-level function in C (see the end of this file)
   ArrayOrder := LISTVIEW_GETCOLUMNORDERARRAY ( GetControlHandle ( cControlName, cParentForm ), GRID_ColumnCount ( cControlName, cParentForm ) )
   nPos := AScan ( ArrayOrder, nColIndex )

RETURN nPos
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION GRID_ColumnCount ( cControlName, cParentForm )
*-----------------------------------------------------------------------------*
   IF ValType ( cParentForm ) == "U"
      cParentForm := ThisWindow.Name
   EndIF

RETURN LISTVIEW_GETCOLUMNCOUNT ( GetControlHandle ( cControlName, cParentForm ) )
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE DELETE_Col ()
*-----------------------------------------------------------------------------*
Local Tval := get_col()
// nCol := tVal[1]
// TotalColumns := tVal[2]
IF tVal[1] > 0
   IF MsgYesNo(MSG_AREYOUSURE, MSG_DELETINGCOLS+Form_2.Grid_2.HEADER( tVal[1] ) )
      // It is not a real deletion but it only hides the affected column
      // Following zero-width columns will be discarded by the processing
      Form_2.Grid_2.ColumnWidth(tVal[1]):= 0
      // Reposition the focus on grid
      IF tVal[1] < tVAl[2]
         _pushKey( VK_RIGHT )
      Else
         _pushKey( VK_LEFT )
      EndIF
   EndIF
EndIF
Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION Get_Col ()
*-----------------------------------------------------------------------------*
LOCAL aux, nCol_Disp, cCnt, Grid_col

    IF Form_2.Grid_2.Itemcount = 0
       RETURN {0,0}
    EndIF

    aux      := Form_2.Grid_2.Value

    Grid_col := aux[2]
    cCnt     := GRID_ColumnCount ("Grid_2","Form_2")

    IF Grid_col < 2 .OR. Grid_col > cCnt
       msgstop("Please select a valid column!")
       RETURN {0,0}
    EndIF

    nCol_Disp := GRID_GetColumnDisplayPos ("Grid_2", "Form_2", Grid_Col)

Return {nCol_disp,cCnt}
/*
*/
*-----------------------------------------------------------------------------*
Function Scegli(opt,title,note,def)
*-----------------------------------------------------------------------------*
   local r:= {,}, S_HG
   default title to "Scelta stampe", opt to {"Questa Scheda","Tutte"}
   Default note to "", def to 1
   note := space(10)+ note
   s_hg := len (opt)*25 + 150

   DEFINE WINDOW SCEGLI WIDTH 300 HEIGHT S_hg TITLE "Azzeramento Flag" ;
                 ICON NIL MODAL NOSIZE NOSYSMENU CURSOR NIL ;
                 ON INIT Load_Scegli_base(title, def, note) ;

          DEFINE STATUSBAR BOLD
                 STATUSITEM note
          END STATUSBAR

          DEFINE RADIOGROUP RadioGroup_1
                 ROW    11
                 COL    22
                 WIDTH  230
                 HEIGHT 59
                 OPTIONS OPT
                 VALUE 1
                 FONTNAME "Arial"
                 FONTSIZE 9
                 SPACING 25
                 // ON CHANGE PutMouse( "Button_1", "Scegli")
          END RADIOGROUP

          DEFINE CheckBox Check_1
               ROW    S_HG - 138
               COL    22
               VALUE  .T.
               CAPTION IW_PREVIEW
               WIDTH   250
          END CHECKBOX

          DEFINE BUTTONEX Button_1
                 ROW    S_HG - 105
                 COL    20
                 WIDTH  100
                 HEIGHT 40
                 PICTURE "Minigui_EDIT_OK"
                 CAPTION _HMG_aLangButton[8]
                 ACTION  ( r:= {Scegli.RadioGroup_1.value,Scegli.Check_1.value} ,Scegli.release)
                 FONTNAME  "Arial"
                 FONTSIZE  9
          END BUTTONEX

          DEFINE BUTTONEX Button_2
                 ROW    S_Hg - 105
                 COL    174
                 WIDTH  100
                 HEIGHT 40
                 PICTURE "Minigui_EDIT_CANCEL"
                 CAPTION _HMG_aLangButton[7]
                 ACTION   Scegli.release
                 FONTNAME  "Arial"
                 FONTSIZE  9
          END BUTTONEX

   END WINDOW

   Scegli.center
   Scegli.activate
   RELEASE FONT DlgFont
return r
/*
*/
*-----------------------------------------------------------------------------*
Procedure ESCAPE_ON(ARG1)
*-----------------------------------------------------------------------------*
     local WinName:=if(arg1==NIL,procname(1),arg1)
     IF upper(WinName)<>'OFF'
        _definehotkey(arg1,0,27,{||_releasewindow(arg1)})
     else
        ON KEY ESCAPE ACTION nil
     EndIF
return

/*
*/
*-----------------------------------------------------------------------------*
Procedure load_Scegli_base(title,def, note)
*-----------------------------------------------------------------------------*
   Local nWidthCli := Max( 286 , GetTextWidth( Getdc (this.handle), note , GetFontHandle( GetDefaultFontname() ) ) )
   ON KEY RETURN OF SCEGLI ACTION ( SCEGLI.BUTTON_1.SETFOCUS, _PUSHKEY( VK_SPACE ) )
   escape_on('Scegli')
   Scegli.Title := Title
   Scegli.RadioGroup_1.value := def
   Scegli.width := nWidthCli + iif( _HMG_IsXPorLater, 2, 1 ) * GetBorderWidth()
   Scegli.Button_2.col := Scegli.width -125
   PutMouse( "RadioGroup_1", "Scegli")

Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION WrExport (cSavefile,aheaders1,aheaders2,aFormats,a,awidths, atot ,inde_on,rTyp, PreView )
*-----------------------------------------------------------------------------*
Local asrc := {}, cTmp , _dummy, cNF, nCol := 80, tFld, nCip := 0, lct
Local ntotalchar ,aFsize := {80,96,120,140,160}, anFsize := {12,10,8,7,6}, nfsize
Local nlmargin := Form_2.Grid_3.Cell( 5, 2 ) , ntoprow := Form_2.Grid_3.Cell( 6, 2 )
Local Mxrow, Hbprn, StrTot := '{', uTot := ascan(aTot,.T. ) > 0
Local eTot   := {},ISEVERYPAGE := (Form_2.Grid_3.Cell( 11, 2 )=2 )
Local WFsize ,isGroup := (Form_2.Grid_3.Cell( 11, 2 )> 2 ), eSH, sSplash
Local cLang := hb_userlang(),hgFont , prelnL := "(nline", postln := "*lstep"
local gtW :={ |r| 25.4*gettextwidth  ( ,r , hbprn:getobjbyname( "_xT_", "F" ) ) / hbprn:devcaps[ 6 ]  }
local gtH :={ |r| 25.4*gettextheight ( ,r , hbprn:getobjbyname( "_xT_", "F" ) ) / hbprn:devcaps[ 5 ]  }
Local pml, pmt, preline, sTmp

DEFAULT inde_on to "NONE", rTyp to "RC", PreView to .T.

     DO CASE

        CASE "it" $ cLang
           sSplash := 'Attendere......... Creazione stampe!' //ITALIAN

        CASE "fr" $ cLang
           sSplash := "S’il vous plaît patienter...... Création d’impressions !" //FRENCH

        CASE "es" $ cLang
           sSplash := '... Por favor espere ...    Trabajo en proceso' //SPANISH

        CASE "pt" $ cLang
           sSplash := '... Aguarde ......... Criando impressões!'   //PORTUGUESE

        CASE "de" $ cLang
           sSplash := '... Warten Sie bitte...    Arbeiten Sie im Gange' //GERMAN

        CASE "el" $ cLang
           sSplash := "?e??µ??ete ......... ??µ??????a e?t?p?se??!" // GREEK

        CASE "ru" $ cLang
           sSplash := 'Ïîäîæäèòå ......... Èäåò îáðàáîòêà!' // RUSSIAN

        CASE "uk" $ cLang
           sSplash := "Çà÷åêàéòå ......... Âèêîíóþ îáðîáêó!"// UKRAINIAN

        CASE "pl" $ cLang
           sSplash := "Poczekaj ......... Tworzenie wydruków!" // POLISH

        CASE "sl" $ cLang
           sSplash := "Pocakaj ......... Ustvarjanje tiskalnikov!" // SLOVENIAN

        CASE "sr" $ cLang
           sSplash := 'Simama ......... Kuunda Prints!'//C SERBIAN

        CASE "bg" $ cLang
           sSplash := "????????? ......... ????????? ?? ??????????!" // BULGARIAN

        CASE "hu" $ cLang
           sSplash := "Várj ... Nyomtatás létrehozása!" // HUNGARIAN

        CASE "cs" $ cLang
           sSplash := "Cekaj ... ... Stvaranje ispisa!" // CZECH

        CASE "sk" $ cLang
           sSplash :=  "Pockajte ......... Vytváranie výtlackov!" //SLOVAK

        CASE "nl" $ cLang
           sSplash := 'Wacht ......... Prints maken!' // DUTCH

        CASE "fi" $ cLang
           sSplash := "Odota ......... Tulosten luominen!" // FINNISH

        CASE "sv" $ cLang
           sSplash := "Vänta ......... Skapa bilder!" // SWEDISH

        OTHERWISE
           sSplash :=  '... Please wait ...    Work in Progress'

     ENDCASE

     aadd(aSrc,'# REPORT.MOD the lines preceded with # will be ignored!' )
     aadd(aSrc,'# case ncpl= 80    nfsize:=12 ' )
     aadd(aSrc,'# case ncpl= 96    nfsize:=10 ' )
     aadd(aSrc,'# case ncpl= 120   nfsize:=8  ' )
     aadd(aSrc,'# case ncpl= 140   nfsize:=7  ' )
     aadd(aSrc,'# case ncpl= 160   nfsize:=6  ' )
     aadd(aSrc,'')

     cTmp := ' ['
     aeval(aheaders1,{|x,y| cTmp += repl('-',awidths[y])+' ',_dummy := x } )

     ntotalchar := len(cTmp)                                     // Retrieve MaxLenght
     aeval(aFsize,{|x| IF( x <= ntotalchar, nCol := x , ) } )    // SET automatic CPL

     Hbprn := Hbprinter():New
     IF Form_2.Grid_3.Cell( 10, 2 )
        hbprn:selectprinter("" ,Form_2.Grid_3.Cell(  9, 2 )) // Select printer
     Else
        hbprn:selectprinter( ,Form_2.Grid_3.Cell(  9, 2 ))   // Printer default
     EndIF
     IF Hbprn:Error != 0
         MessageBoxTimeout (ERR_007 , 'Export failed', MB_OK, 1000 )
        RETURN nil
     EndIF

     nfsize := AnFsize[ascan(aFsize,ncol)]

     hbprn:setdevmode( 0x00000002 ,Form_2.Grid_3.Cell( 7, 2 ) ) // Set Papaersize
     hbprn:definefont("_xT_","Courier New",nfsize,,,.F.,.F.,.F.,.F.) //Need a font
     //hbprn:definefont("_xT_","Courier New",int(nfsize),,,.F.,.F.,.F.,.F.) //Need a font
     Hbprn:Setpage( Form_2.Grid_3.Cell( 13, 2 ),Form_2.Grid_3.Cell( 7, 2 ),"_xT_"  )  // Set Orientation
     IF ntotalchar >  Hbprn:maxCol
        nfsize --
        sTmp := ascan(anFsize,nfsize)
        ncol := IF (sTmp > 0,aFsize[stmp],atail(aFsize))
        hbprn:modifyfont("_xT_","Courier New",nfsize,,, .F.,.F.,.F.,.F., .F.,.F.,.F.,.F.)
     EndIF
     Mxrow  := max(Hbprn:maxrow,Form_2.Grid_3.Cell( 3, 2 ) )
     // msgmulty({Hbprn:maxrow,Hbprn:maxcol,nfsize} )
     hgFont := eval(gtH,"I") //25.4*gettextheight( ,"-", hbprn:getobjbyname( "_xT_", "F" ) ) / hbprn:devcaps[ 5 ]
     *wdFont := eval(gtw,"I") //25.4*gettextwidth ( ,"H", hbprn:getobjbyname( "_xT_", "F" ) ) / hbprn:devcaps[ 6 ]
     *hgFont := 25.4*gettextheight( ,"-", hbprn:getobjbyname( "_xT_", "F" ) ) / hbprn:devcaps[ 5 ]
     *wdFont := 25.4*gettextwidth ( ,"H", hbprn:getobjbyname( "_xT_", "F" ) ) / hbprn:devcaps[ 6 ]

     pml    := hbprn:DEVCAPS[ 9 ]/hbprn:DEVCAPS[5]*25.4
     pmt    := hbprn:DEVCAPS[ 10 ]/hbprn:DEVCAPS[6]*25.4
     WfSize := NTrim(int(nfsize))

     switch rTyp
            case "RC"
                 aadd(aSrc,'!HBPRINT')
                 preline := "nline"
                 postln  := ''
                 hgfont := 1
                 Exit

            case "HBPRINTER"
                 aadd(aSrc,'!HBPRINT')
                 preline:= "nline*lstep"
                 nlmargin *= hgfont
                 nlmargin += pml
                 Exit

            case "MINIPRINT"
                 aadd(aSrc,'!MINIPRINT')
                 preline:= "nline*lstep"
                 nlmargin *= hgfont
                 nlmargin += pml
                 Exit

            case "PDFPRINT"
                 aadd(aSrc,'!PDFPRINT')
                 preline:= "nline*lstep"
                 nlmargin *= hgfont
                 nlmargin += pml
                 Exit

     Endswitch

     // Declare
     aadd(aSrc,'[DECLARE]'+NTrim( nCol )+ IF(Form_2.Grid_3.Cell( 10, 2 ),'/SELE','') )
     aadd(aSrc,'SET JOB NAME ['+cFilenoext(cSavefile) +']' )
     aadd(aSrc,'SET PAPERSIZE '+apapeles[Form_2.Grid_3.Cell( 7, 2 )] )
     aadd(aSrc,'SET UNITS '+ IF (rTyp = "RC" ,'ROWCOL',"MM") )

     IF rTyp = "PDFPRINT"
        aadd(aSrc,'SET HPDFDOC COMPRESS ALL')
        aadd(aSrc,'SET HPDFINFO DATECREATED TO DATE() TIME TIME()')
        aadd(aSrc,'SET HPDFINFO AUTHOR TO ['+Getusername()+']')
        aadd(aSrc,'SET HPDFINFO CREATOR TO []')
        IF empty(Form_2.Title1.value)
           aadd(aSrc,'SET HPDFINFO TITLE   TO ['+Proper(lower(cFilenoext(cSavefile)))+']')
        Else
           aadd(aSrc,'SET HPDFINFO TITLE   TO ['+Form_2.Title1.value+']')
        EndIF
     EndIF

     aadd(aSrc,'SET ORIENTATION '+IF(Form_2.Grid_3.Cell( 13, 2 ) > 1,'LANDSCAPE','PORTRAIT') )
     aadd(aSrc,'SET PREVIEW '+IF (Form_2.Grid_3.Cell(  9, 2 ),'ON','OFF') )
     aadd(aSrc,'SET CHARSET ANSI_CHARSET')
     aadd(aSrc,'SET SPLASH TO '+sSplash)

     IF rTyp = "RC"
        aadd(aSrc,'DEFINE FONT Fb  NAME [COURIER NEW] SIZE '+WFsize+' BOLD' )
        aadd(aSrc,'DEFINE FONT Ft  NAME [COURIER NEW] SIZE '+NTrim(anFsize[ascan(aFsize,nCol)]+2 )+' BOLD' )
     ElseIF rTyp = "MINIPRINT" .or. rTyp ="PDFPRINT"
        aadd(aSrc,'SET OFFSET HBPCOMPATIBLE')
     EndIF
     aadd(aSrc,'Var _ML '+NTrim(nlmargin)+' N' )

     IF rTyp != "RC"
        aadd(aSrc,'(m->lstep := '+NTrim(hgfont)+')')
     EndIF
     IF uTot           // Need a separate counter
        IF isgroup
           aeval(aTot,{|x,y| IF(x ,StrTot += a[y]+',', )} )
        Else
           aeval(aTot,{|x| IF(x ,StrTot += '0,', )} )
        EndIF
        StrTot := remRight (StrTot,',')+'}'
        IF !isgroup
           aadd(aSrc,'Var aC '+StrTot +' A')
        EndIF
     EndIF
     aadd(aSrc,'')

     IF isgroup
        tFld := DBFIELDINFO(DBS_TYPE, FieldPos( Inde_On ))

        SWITCH tFld

        CASE "C"  // Char
             eSH := 'Ltrim('+inde_on+')'
             exit

        CASE "N"  // Number
             eSH := 'TRANSFORM ('+Inde_On+',"'+ aformats[ascan(a,inde_on)] +'" )'
             EXIT

        CASE "M"  // Memo
             Msgstop("You can not group on MEMO Fields !", "Error" )
             Return NIL

        CASE "D"  // Date
             eSh := 'TRANSFORM ('+Inde_On+',"@D")'
             Exit

        CASE "L"  // Logical
             eSH := 'TRANSFORM ('+Inde_On+',"L")'
             Exit

        ENDSWITCH

        aadd(aSrc,'// (GroupField, Head string, Column string, count total for, where the gtotal, total string, total column, paper_feed_every_group')
        aadd(aSrc,'// total for = Fieldname or array with multiple fieldname')
        aadd(aSrc,'// Example: Example: GROUP first {||rtrim(first)+space(1)+"***"} AUTO {CODE,INCOMING} AUTO [** Subtotal **] 6 .T.')
        aadd(aSrc,'')

        IF uTot  // need a counter
            aadd(aSrc,'SET TOTALSTRING space(_ML)+[*** Total ***]')
            aadd(aSrc,'SET INLINESBT .F.')
            aadd(aSrc,'SET INLINETOT .F.')
            aadd(aSrc,'SET SUBTOTALS .T.')
            aadd(aSrc,'SET GROUPBOLD .T.')
            aadd(aSrc,'// SET SHOWGHEAD .T.')
            aadd(aSrc,'// SET GTGROUPCOLOR BLACK')
            aadd(aSrc,'// SET HGROUPCOLOR RED')
            aadd(aSrc,'')
            aadd(aSrc,'GROUP '+ Inde_On +' {||([**  ** ]+'+ eSH +')} (_ML) '+StrTot+' AUTO  space(_ML)+[** Subtotal **] AUTO .F. ')
        Else    // No Count
            aadd(aSrc,'SET TOTALSTRING space(_ML)')
            aadd(aSrc,'SET INLINESBT .F.')
            aadd(aSrc,'SET INLINETOT .F.')
            aadd(aSrc,'SET SUBTOTALS .F.')
            aadd(aSrc,'SET GROUPBOLD .T.')
            aadd(aSrc,'// SET SHOWGHEAD .T.')
            aadd(aSrc,'// SET GTGROUPCOLOR BLACK')
            aadd(aSrc,'// SET HGROUPCOLOR RED')
            aadd(aSrc,'')
            aadd(aSrc,'GROUP '+ Inde_On +' {||([**  ** ]+'+ eSH +')} (_ML) {} AUTO [] AUTO .F. ')
        EndIF

        aadd(aSrc,'')

     EndIF
     // The Head definitions
     IF rTyp = "RC"
        aadd(aSrc,'[HEAD]'+NTrim(9+ntoprow) )
        aadd(aSrc,'( nline +='+ NTrim(ntoprow)+' )' )
     Else
        aadd(aSrc,'[HEAD]'+NTrim(11+ntoprow) )
        aadd(aSrc,'( nline +='+ NTrim(2+ntoprow)+' )' )
     EndIF
// Image
     IF !empty( Form_2.Grid_3.Cell( 1, 2 ) )
         IF !Form_2.Grid_3.Cell( 2, 2 )
            aadd(aSrc, 'IF ( npag = 1 )')
         EndIF
         IF rTyp = "RC"
            aadd(aSrc, '   @ '+NTrim(Form_2.Grid_3.Cell( 1, 3 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 4 )+3) ;
                        +' PICTURE '+ Form_2.Grid_3.Cell( 1, 2 )+' SIZE ' ;
                        +NTrim(Form_2.Grid_3.Cell( 1, 5 )-Form_2.Grid_3.Cell( 1, 3 )-4 )+',';
                        +NTrim(Form_2.Grid_3.Cell( 1, 6 )-Form_2.Grid_3.Cell( 1, 4 )-2 ) )
         Else
            aadd(aSrc, '   @ '+NTrim(eval(gth,repl("H",Form_2.Grid_3.Cell( 1, 3 )+Form_2.Grid_3.Cell( 6, 2 ) ) )+pmt );
                        +','+NTrim(eval(gtw ,repl("-",Form_2.Grid_3.Cell( 1, 4 )+Form_2.Grid_3.Cell( 5, 2 ) ))+pml ) ;
                        +' PRINT IMAGE '+ Form_2.Grid_3.Cell( 1, 2 )+' WIDTH ' ;
                        +NTrim(Form_2.Grid_3.Cell( 1, 5 )-Form_2.Grid_3.Cell( 1, 3 ) )+' HEIGHT ';
                        +NTrim(Form_2.Grid_3.Cell( 1, 6 )-Form_2.Grid_3.Cell( 1, 4 ) ) )
         EndIF
         IF !Form_2.Grid_3.Cell( 2, 2 )
            aadd(aSrc, 'EndIF')
         EndIF
     EndIF
// Image End

/*  Barcode
<row>       //1
<col>       //2
<txt>       //3
<type>      //4
<h>         //5
<w>         //6
[SUBTITLE]  //7
[INTERNAL]  //8
<flag>      //9
*/
     lct := alltrim(upper(bbcode[3]))
     IF !Empty(lct) .and. ( lct <> upper(BR_NOPRINT) ) // do not add Barcode if the code is a "demo code"
        //<row> <col> BARCODE  <txt> TYPE <type> HEIGHT <h> WIDTH <w> [SUBTITLE] [INTERNAL] [FLAG <flag>] VSH <n>
        aadd(aSrc, NTrim(bbcode[1])+ ","+NTrim(bbcode[2])+" BARCODE ["+bbcode[3] +"] TYPE "+bbcode[4]+ " HEIGH ";
            +NTrim(bbcode[5])+" WIDTH "+NTrim(bbcode[6]/10)+bbcode[7]+bbcode[8];
            +IF(bbcode[9] > 0," FLAG "+NTrim(bbcode[9]),"")+" VSH "+IF (bbcode[8]== " INTERNAL ","2","1" ))
     EndIF

     aadd(aSrc, preline+',   (_ML)     SAY ['+_HMG_MESSAGE [9]+'] Font [COURIER NEW] SIZE '+WFsize)
     IF rTyp = "RC"
        aadd(aSrc, preline+',   '+NTrim(ntotalchar/2)+'        SAY ['+ Form_2.Title1.value +'] Font Ft ALIGN CENTER')
        aadd(aSrc, prelnl+'+1)'+postln+', '+NTrim(ntotalchar/2)+'        SAY ['+ Form_2.Title2.value +'] Font Ft ALIGN CENTER')
     Else
        aadd(aSrc, preline+',   '+NTrim( eval(gtw ,substr(cTmp,1,len(cTmp)/2)) )+'    SAY ['+ Form_2.Title1.value +'] Font [COURIER NEW] SIZE '+NTrim(anFsize[ascan(aFsize,nCol)]+2 )+' BOLD ALIGN CENTER')
        aadd(aSrc, prelnl+'+1)'+postln+', '+NTrim( eval(gtw ,substr(cTmp,1,len(cTmp)/2)) )+'  SAY ['+ Form_2.Title2.value +'] Font [COURIER NEW] SIZE '+NTrim(anFsize[ascan(aFsize,nCol)]+2 )+' BOLD ALIGN CENTER')
     EndIF
     IF Form_2.Grid_3.Cell( 14, 2 ) = .F.   // Print Date and Time
        IF rTyp = "RC"
           aadd(aSrc, preline+',   ('+NTrim(len(cTmp)-10-nlmargin) +'+_ML) SAY date() Font [COURIER NEW] SIZE '+WFsize )
           aadd(aSrc, prelnl+'+1)'+postln+', ('+NTrim(len(cTmp)-10-nlmargin) +'+_ML) SAY time() Font [COURIER NEW] SIZE '+WFsize )
        Else
           aadd(aSrc, preline+',   ('+NTrim(eval(gtw,substr(cTmp,1,len(cTmp)-13) ) ) +'+_ML) SAY date() Font [COURIER NEW] SIZE '+WFsize )
           aadd(aSrc, prelnl+'+1)'+postln+', ('+NTrim(eval(gtw,substr(cTmp,1,len(cTmp)-13)) ) +'+_ML) SAY time() Font [COURIER NEW] SIZE '+WFsize )
        EndIF
     EndIF
     aadd(aSrc, preline+',   (5+_ML)   SAY hb_ntos( npag ) Font [COURIER NEW] SIZE '+WFsize )

     aadd(aSrc, prelnl+'+3)'+postln+', (_ML) SAY '+cTmp+'] Font [COURIER NEW] SIZE '+WFsize )
     cTmp := ' ['
     aeval(aheaders1,{|x,y| cTmp += x+repl(' ',awidths[y]-len(x))+' '} )
     aadd(aSrc,prelnl+'+4)'+postln+', (_ML) SAY '+cTmp+'] Font [COURIER NEW] SIZE '+WFsize +' BOLD')
     cTmp := ' ['
     aeval(aheaders2,{|x,y| cTmp += x+repl(' ',awidths[y]-len(x))+' '} )
     aadd(aSrc,prelnl+'+5)'+postln+', (_ML) SAY '+cTmp+'] Font [COURIER NEW] SIZE '+WFsize +' BOLD')
     cTmp := ' ['
     aeval(aheaders1,{|x,y| cTmp += repl('-',awidths[y])+' ',_dummy := x } )
     aadd(aSrc,prelnl+'+6)'+postln+', (_ML) SAY '+cTmp+'] Font [COURIER NEW] SIZE '+WFsize )

     aadd(aSrc,'')

     // The Body Definitions
     // Add Adaptative Body Height     normal -12  with every and (!utot ,-2 ,-3 )
     IF rTyp = "RC"
        aadd(aSrc,'[BODY]'+NTrim(max(Form_2.Grid_3.Cell( 3, 2 ),mxrow)-NTOPROW+3 -IF(ISEVERYPAGE,if(utot,15,14),12) ) )
     Else
        aadd(aSrc,'[BODY]'+NTrim(max(Form_2.Grid_3.Cell( 3, 2 ),mxrow)-NTOPROW+3 -IF(ISEVERYPAGE,if(utot,15,14),12) ) )
     EndIF

     IF Utot .and. !isgroup
        For Each cNf in aTot
            IF cNF
               nCip ++
               aadd(aSrc,'(aC['+NTrim(nCip)+'] += Field->'+A[cNf:__enumIndex()]+')')
            EndIF
        Next
     EndIF
     nCol := nLmargin
     For Each cNf in a
         tFld := DBFIELDINFO(DBS_TYPE, FieldPos( cNf ))
         SWITCH tFld

         CASE "C"  // Char
              aadd(aSrc, preline+', '+NTrim( nCol )+' SAY (substr(field->'+cNf+',1,'+NTrim(int(awidths[cNf:__enumIndex()] ) )+') ) Font [COURIER NEW] SIZE '+WFsize )
              exit

         CASE "N"  // Number
              aadd(aSrc, preline+', '+NTrim( nCol )+' SAY TRANS(Field->'+cNf+',"'+aformats[cNf:__enumIndex()]+'") Font [COURIER NEW] SIZE '+WFsize )
              IF aTot[cNf:__enumIndex()]
                 aadd (eTot,'   @ (eline+1)'+IF (rTyp != "RC",'*lstep','')+', '+NTrim( nCol )+' SAY IF(.T.,TRANS(ac[|],"'+aformats[cNf:__enumIndex()]+'"),[]) Font [COURIER NEW] SIZE '+WFsize +' BOLD')
              EndIF
              EXIT

         CASE "M"  // Memo
              aadd(aSrc, preline+', '+NTrim( nCol )+' MEMOSAY Field->'+cNf+' LEN '+NTrim(int(awidths[cNf:__enumIndex()] ) )+' Font [COURIER NEW] SIZE '+WFsize )
              exit

         CASE "D"  // Date
         CASE "L"  // Logical
              aadd(aSrc, preline+', '+NTrim( nCol )+' SAY field->'+cNf+' Font [COURIER NEW] SIZE '+WFsize )
              Exit

         ENDSWITCH
         IF rTyp = "RC"
           nCol += (int(awidths[cNf:__enumIndex()] )+1 *hgfont)
         Else
           nCol += 25.4*gettextwidth ( ,repl("H",int(awidths[cNf:__enumIndex()] )+1 ), hbprn:getobjbyname( "_xT_", "F" ) ) / hbprn:devcaps[ 6 ]
         EndIF
     Next

     aadd(aSrc,'')

     // The Feet definitions
     aadd(aSrc,'[FEET]2')
     IF uTot .and. !isGroup
        IF rTyp = "RC"
           aadd(aSrc,'   @ Eline,(_ML) SAY IF(Last_pag, [*** Total ***],[])  Font FB')
        Else
           aadd(aSrc,'   @ Eline*lstep,(_ML) SAY IF(Last_pag, [*** Total ***],[]) Font [COURIER NEW] SIZE '+WFsize+' BOLD')
        EndIF
        For Each cNf in ETot
            CnF := STRTRAN(cNf,"|",NTrim(cNf:__enumIndex()) )
            IF ! ISEVERYPAGE
               CnF := STRTRAN(cNf,".T.","Last_Pag" )
            EndIF
            aadd(aSrc,cNf)
        Next
     EndIF
     aadd(aSrc,'[END]')

     Hbprn:End()

     Writefile(cSavefile,aSrc)  // WriteFile is more fast than StrFile!

     IF PreView
        WinRepint(cSaveFile,,,,,Preview,rTyp )
     Else
         MessageBoxTimeout (MSG_FILECREATED, '', MB_OK, 1000 )
     EndIF

Return nil
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE Writefile(filename,arrayname)
*-----------------------------------------------------------------------------*
   Local f_handle

   * open file and position pointer at the end of file
   IF VALTYPE(filename) == "C"
     f_handle := FOPEN(filename,2)
     *- IF not joy opening file, create one
     IF Ferror() <> 0
        f_handle := Fcreate(filename,0)
     EndIF
     FSEEK(f_handle,0,2)
   ELSE
     f_handle := filename
     FSEEK(f_handle,0,2)
   EndIF

   IF VALTYPE(arrayname) == "A"
     * IF its an array, do a loop to write it out
     * msginfo(str(len(arrayname)),"FKF")
     aeval( Arrayname,{|x|FWRITE(f_handle,x+CRLF )} )
   ELSE
     * must be a character string - just write it
     FWRITE(f_handle,arrayname+CRLF )
     //msgbox(Arrayname,"Array")
   EndIF

   * close the file
   IF VALTYPE(filename)=="C"
      Fclose(f_handle)
   EndIF

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure Check_db_Index ( Arg1,Lvl )
*-----------------------------------------------------------------------------*

IF lvl > 2
   IF ! File ( cFilePath( GetExeFileName() )+'\'+Alias()+'.Cdx' )
      MsgExclamation( MSG_REQUIREDFILE + Alias()+".Cdx", MSG_FILEMISSING)
      Return
   EndIF
   ORDLISTADD(ALIAS())
   (alias())->(ORDSETFOCUS('I'+ arg1))
   (alias())->(dbgotop())
   return
Endif
Return
/*
*/
#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>

static HDC              hDC    = NULL;
static HFONT            hfont;
// ListView_GetHeader( hWnd )
HB_FUNC ( LISTVIEW_GETHEADER )
{
   HB_RETNL( ( LONG_PTR ) ListView_GetHeader( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC ( LISTVIEW_GETCOLUMNORDERARRAY )
{
   int i, *p;
   p = (int*) GlobalAlloc (GMEM_FIXED | GMEM_ZEROINIT, sizeof(int)*hb_parni(2));
   ListView_GetColumnOrderArray ((HWND) hb_parnl(1), hb_parni(2), (int*) p);
   hb_reta (hb_parni(2));
   for( i= 0; i < hb_parni(2); i++ )
        HB_STORNI( (int)(*(p+i))+1, -1, i+1);
   GlobalFree (p);
}
#pragma ENDDUMP
/*
*/
*--------------------------------------------------------------*
Procedure WRBC
*--------------------------------------------------------------*
   Local aTypeItems :={;
                       "EAN13","EAN8","UPCA","UPCE","CODE39","ITF","MSI","CODABAR",;
                       "CODE93","CODE11","CODE128","PDF417","DATAMATRIX","QRCODE"}
   Local acFlags := {}
   Private aFlags   :={{BR_NOCHECK,0 }, ;
                       {"PDF417_TRUNCATED",0x0100},;
                       {"PDF417_LEVEL_MASK",0xF000},;
                       {"PDF417_LEVEL0",0x1000},;
                       {"PDF417_LEVEL1",0x2000},;
                       {"PDF417_LEVEL2",0x3000},;
                       {"PDF417_LEVEL3",0x4000},;
                       {"PDF417_LEVEL4",0x5000},;
                       {"PDF417_LEVEL5",0x6000},;
                       {"PDF417_LEVEL6",0x7000},;
                       {"PDF417_LEVEL7",0x8000},;
                       {"PDF417_LEVEL8",0x9000},;
                       {"DATAMATRIX_SQUARE",0x0100},;
                       {"DATAMATRIX_RECTANGLE",0x0200},;
                       {"QRCODE_LEVEL_MASK",0x0700},;
                       {"QRCODE_LEVEL_L",0x0100},;
                       {"QRCODE_LEVEL_M",0x0200},;
                       {"QRCODE_LEVEL_Q",0x0300},;
                       {"QRCODE_LEVEL_H",0x0400}}

   aeval(aFlags,{|x|aadd(acFlags,x[1])} )

   DEFINE WINDOW Barcode ;
          AT 0 ,0 ;
          WIDTH  325 ;
          HEIGHT 385 ;
          TITLE space(20)+'Winreport (MM) - BarCode Utility' ;
          MODAL           ;
          NOSIZE          ;
          NOSYSMENU       ;
          ON INIT load_Barcode_base( aTypeItems ) ;
          ON RELEASE SetFlag(.T.)

          DEFINE STATUSBAR BOLD
                 STATUSITEM BR_TEST ACTION CreateBCode(.t.)
          END STATUSBAR

       define label barcodetypelabel
         ROW 10
         COL 10
         width 100
         value BR_LBL_TYPE
         alignment vcenter
      end label

      define combobox type
         ROW 10
         COL 155
         width 150
         items aTypeItems
         ON CHANGE (bbcode[4] := aTypeItems [ barcode.Type.value ],SetFlag() )
      end Combobox

      define label codelabel
         ROW 40
         COL 10
         width 100
         value BR_LBL_CODE
         alignment vcenter
      end label

      define textbox code
         ROW 40
         COL 155
         width 150
         on change bbcode[3]:= this.value
         Tooltip BR_TTFIELD
      end textbox

      define label widthlabel
         ROW 70
         COL 10
         width 120
         value BR_LINE
         alignment vcenter
      end label

      define spinner linewidth
         ROW 70
         COL 155
         width 80
         value 0.1
         rightalign .t.
         rangemin 1
         rangemax 10
         increment 1
         on change bbcode[6]:= this.value
      end spinner

      define label heightlabel
         ROW 100
         COL 10
         width 135
         value BR_HEIGHT
         alignment vcenter
      end label

      define spinner lineheight
         ROW 100
         COL 155
         width 80
         value 110
         rightalign .t.
         increment 1
         rangemin 10
         rangemax 200
         on change bbcode[5]:= this.value
      end spinner

      define checkbox showdigits
         ROW 130
         COL 10
         width 270
         caption BR_DISPLAY1
         value .t.
         THREESTATE .T.
         onchange setflag()
      end checkbox

      define checkbox wide2_5
         ROW 160
         COL 10
         width 120
         caption BR_WIDE+"2.5"
         onchange ( iif( this.value, barcode.wide3.value := .f., ), SetFlag() )
      end checkbox

      define checkbox wide3
         ROW 160
         COL 155
         width 120
         caption BR_WIDE+"3"
         onchange ( iif( this.value, barcode.wide2_5.value := .f., ), SetFlag() )
      end checkbox

      define checkbox checksum
         ROW 190
         COL 10
         width 120
         caption ' Checksum'
         value .t.
         onchange SetFlag()
      end checkbox

      define combobox oFlag
         ROW 190
         COL 155
         width 150
         items acFlags
         onchange ( bbcode[10]:= this.value, SetFlag() )
      end Combobox

      define label barRow
         ROW 220
         COL 10
         width 110
         value BRW_HDR_FROMROW
         alignment vcenter
      end label

      define spinner bRow
         ROW 220
         COL 155
         width 80
         value 0
         rightalign .t.
         rangemin 0
         rangemax 1000
         on change bbcode[1]:= this.value
      end spinner

      define label barCol
         ROW 250
         COL 10
         width 100
         value BRW_HDR_FROMCOL
         alignment vcenter
      end label

      define spinner bCol
         ROW 250
         COL 155
         width 80
         value 0
         rightalign .t.
         rangemin 0
         rangemax 1000
         on change bbcode[2]:= this.value
      end spinner

      DEFINE BUTTONEX Button_1
             ROW    290
             COL    10
             WIDTH  100
             HEIGHT 40
             PICTURE "Minigui_EDIT_OK"
             CAPTION _HMG_aLangButton[8]
             ACTION  barcode.release
             FONTNAME  "Arial"
             FONTSIZE  9
      END BUTTONEX

      DEFINE BUTTONEX Button_2
             ROW    290
             COL    110
             WIDTH  100
             HEIGHT 40
             PICTURE "HP_SAVE2"
             CAPTION LBL_SAVE //"&"+_HMG_aABMLangButton[12]
             ACTION  CreateBCode(.F.)
             FONTNAME  "Arial"
             FONTSIZE  9
             Tooltip BR_TTSAVEAS
      END BUTTONEX

      DEFINE BUTTONEX Button_3
             ROW    290
             COL    210
             WIDTH  100
             HEIGHT 40
             PICTURE "Minigui_EDIT_CANCEL"
             CAPTION _HMG_aLangButton[7]
             ACTION  ( bbcode[3] := " " ,barcode.release )
             FONTNAME  "Arial"
             FONTSIZE  9
      END BUTTONEX

   end window
   barcode.center
   barcode.activate
   Release aFlags
   Form_2.setfocus

Return
/*
*/
*-----------------------------------------------------------------------------*
Procedure load_Barcode_base(aTypeItems)
*-----------------------------------------------------------------------------*

barcode.bRow.value := bbcode[1]
barcode.bCol.value := bbcode[2]
barcode.code.value := bbcode[3]
barcode.type.value :=  ascan(aTypeItems,bbcode[4])
barcode.lineheight.value := bbcode[5]
barcode.linewidth.value  := bbcode[6]
barcode.showdigits.value := ( bbcode[7]== " SUBTITLE " )
IF bbcode[8]== " INTERNAL "
   barcode.showdigits.value := Nil
Endif

barcode.Checksum.Value   := ( bbcode[9] > 0   )
barcode.Wide2_5.Value    := ( bbcode[9] > 63  )
barcode.Wide3.Value      := ( bbcode[9] > 127 )
barcode.oFlag.value      :=  bbcode[10]

Return
/*
*/
*--------------------------------------------------------------*
Function SetFlag()
*--------------------------------------------------------------*
   Local nFlags := 0, ret, isv := isValidFlag()

   IF barcode.Checksum.Value
      nFlags := nFlags + HB_ZEBRA_FLAG_CHECKSUM
   EndIF
   IF barcode.Wide2_5.Value
      nFlags := nFlags + HB_ZEBRA_FLAG_WIDE2_5
   EndIF
   IF barcode.wide3.Value
      nFlags := nFlags + HB_ZEBRA_FLAG_WIDE3
   EndIF

   nFlags += isv [1]
   bbcode[9] := nFlags

   if isv[2] ; bbcode[3] := "Demo1S23" ;Endif
   ret:= barcode.showdigits.Value

   IF valtype(ret) == 'U'
       barcode.showdigits.caption := BR_DISPLAY1 + BR_DISPLAY2
       bbcode[7] := " SUBTITLE "
       bbcode[8] := " INTERNAL "

   ElseIF ret == .t.
       barcode.showdigits.caption := BR_DISPLAY1 + BR_DISPLAY3
       bbcode[7] := " SUBTITLE "
       bbcode[8] := ""
   else
       barcode.showdigits.caption :=  BR_DISPLAY1
       bbcode[7] := ""
       bbcode[8] := ""
   EndIF

Return nil
/*
*/
*--------------------------------------------------------------*
Function IsvalidFlag()
*--------------------------------------------------------------*
Local BcTyp := barcode.type.value, cFlag, vRet := {0,.F.}
Local CsTyp := barcode.oFlag.value

if CsTyp > 1
   cFlag := aFlags[barcode.oFlag.value,1]
   cFlag := left(cFlag,at("_",cFlag)-1)
   if barcode.type.item(BcTyp) == cFlag
      Vret := {aFlags[max(barcode.oFlag.value,1),2],.T.}
   Else
      if barcode.oFlag.value > 1
         msgstop(barcode.oFlag.item(CsTyp)+CRLF+ MSG_INVALIDCHECKSUM )
         barcode.oFlag.value := 1
      Endif
   Endif
Endif
if ascan ({"PDF417","DATAMATRIX","QRCODE"}, barcode.type.item(bctyp) ) > 0
   barcode.wide2_5.value  := .F.
   barcode.wide3.value    := .F.
   barcode.checksum.value := .F.
Endif

Return vRet
/*
*/
*--------------------------------------------------------------*
Function CreateBCode(Test)
*--------------------------------------------------------------*
   local cImageFileName := '' ,abarcolor := {0,0,0}, aBackColor := {255,255,255 }
   local Fmt, rtv, show := barcode.showdigits.value, showdigits

   DEFAULT Test TO .F.

   IF valtype(show) == 'U'
      showdigits := 2
   ElseIF show == .t.
      showdigits := 1
   else
      showdigits := 0
   EndIF

   IF !Test
      cImageFileName := putfile( { {"JPG Files","*.Jpg"},{"GIF Files","*.Gif"},{"BMP Files","*.Bmp"} };
      , "Save Barcode to image",,.T. )

      if len( cImageFileName ) == 0
         return nil
      endif
      Fmt := upper(substr(cImageFileName,rat(".",cImageFileName)+1) )
      if file( cImageFileName )
         if msgyesno( 'Image file already exists. Do you want to overwrite?', 'Confirmation' )
            ferase( cImageFileName )
         else
            return nil
         endif
      endif
   Endif

   Rtv := HMG_CreateBarCode( barcode.code.value,;
                    barcode.type.item( barcode.type.value ),;
                    barcode.linewidth.value,;
                    barcode.lineheight.value,;
                    showdigits ,;
                    cImageFileName,;
                    aBarColor,;
                    aBackColor,;
                    bbcode[9],;
                    Fmt )     // Image Format

   if rtv # 0 .and. test
      msginfo("Barcode OK!")
   Endif

   if file( cImageFileName )
      _Execute ( GetActiveWindow() , , cImageFileName, , , 5 )
   endif

return nil
