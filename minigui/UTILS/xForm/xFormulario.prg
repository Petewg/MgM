#include "minigui.ch"
/*
   Herramienta de Edicion de formularios
   Edit Forms Tool

   MINIGUI - Harbour Win32

   Rafael Moran <webrmoran@yahool.com>
*/

MEMVAR mConCuadricula
MEMVAR FileName
MEMVAR mListItem, mValRetur, mRetNom, temptext
MEMVAR mSendItems
MEMVAR mItemRetur
MEMVAR mMacro
MEMVAR mIdioma
MEMVAR mDefine_NAME
MEMVAR mDefine_COL
MEMVAR mDefine_ROW
MEMVAR mDefine_WIDTH
MEMVAR mDefine_HEIGHT
MEMVAR mDefine_CAPTION
MEMVAR mDefine_VALUE
MEMVAR mDefine_PICTURE
MEMVAR mDefine_TOOLTIP
MEMVAR mDefine_OPTIONS
MEMVAR mDefine_SPACING
MEMVAR mDefine_HORIZONTAL
MEMVAR mDefine_ITEMS
MEMVAR mDefine_LISTWIDTH
MEMVAR mDefine_RANGEMIN
MEMVAR mDefine_RANGEMAX

MEMVAR aControles
MEMVAR mTipoAccion 
MEMVAR mTipoControl
MEMVAR aClipBoard
MEMVAR aUnDo
MEMVAR mMoveIman
MEMVAR nNumSkip
MEMVAR mMasButtos
MEMVAR mMasBCaption
MEMVAR mMasBPicture
MEMVAR mMasBToolTip
MEMVAR mTabajando
MEMVAR mxReturn

MEMVAR nTitleBarHeight
MEMVAR nBorderWidth

STATIC mLinea, mColum
STATIC Sys_BackColor, Sys_FontColor

#define MAIN_TITLE       'xFormas 2.1 by Rafael Moran'
#define COLOR_WINDOWTEXT 8
#define COLOR_BTNFACE    15
// ************** INTERFACE **************
// ************** FORMULARIOS QUE SE HACE **************
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Formulario()
// Formularion en Desarrollo
LOCAL mFormRow
LOCAL mFormCol
LOCAL mFormWIDTH
LOCAL mFormHeight
LOCAL mFormTitle
LOCAL I

FOR I:= 1 TO LEN(aControles[1,3])
   IF aControles[1,3,I,1]="ROW"
      mFormRow:= aControles[1,3,I,2]
   ENDIF
   IF aControles[1,3,I,1]="COL"
      mFormCol:= aControles[1,3,I,2]
   ENDIF
   IF aControles[1,3,I,1]="WIDTH"
      mFormWIDTH:= aControles[1,3,I,2]
   ENDIF
   IF aControles[1,3,I,1]="HEIGHT"
      mFormHeight:= aControles[1,3,I,2]
   ENDIF
   IF aControles[1,3,I,1]="TITLE"
      mFormTitle:= aControles[1,3,I,2]
   ENDIF
NEXT

DEFINE WINDOW WForma ;
               AT mFormRow,mFormCol ;
               WIDTH mFormWIDTH HEIGHT mFormHeight ;
               TITLE mFormTitle ;
               CHILD ;
               NOMINIMIZE ;
               NOMAXIMIZE ;
               ON INIT (PInterfaceFormMade_Move(), PInterfaceFormMade_Refresh());
               ON MOUSECLICK PInterfaceFormMade_Click();
               ON MOVE PInterfaceFormMade_Move() ;
               ON SIZE PInterfaceFormMade_Size();
               ON MOUSEMOVE PInterfaceFormMade_Mouse() ;
               BACKCOLOR {206,192,168}
               
   PInterfaceFormMade_KeySetup(1)
   
   DEFINE CONTEXT MENU
            MENUITEM PSayText({"Modo Selección","Select Mode"})    ACTION PObjeto_Acciones("SELECCION","Btn_Nada") IMAGE "select"
            SEPARATOR
            MENUITEM PSayText({"Mover" ,"Move" })      ACTION PObjeto_Activar("MOVER"  ,"Btn_Move")  IMAGE "Move"
            MENUITEM PSayText({"Tamaño","Size" })      ACTION PObjeto_Activar("TAMANIO","Btn_SIZE")  IMAGE "size" 
            MENUITEM PSayText({"Borrar","Erase"})      ACTION PObjeto_Borrar()                       IMAGE "Borrar"
            SEPARATOR
            MENUITEM PSayText({"Copiar","Copy" })      ACTION PObjeto_Copiar()                       IMAGE "Copiar"
            MENUITEM PSayText({"Pegar" ,"Paste"})      ACTION PObjeto_Acciones("PEGAR","Btn_PEGAR")  IMAGE "Pegar" 

   END MENU
   
   PInterfaceFormMade_DefineObjetos()

END WINDOW
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_KeySetup(mStatus)
RELEASE KEY UP    OF WForma
RELEASE KEY DOWN  OF WForma
RELEASE KEY LEFT  OF WForma
RELEASE KEY RIGHT OF WForma
IF mStatus = 1
   ON KEY UP    OF WForma ACTION PInterfaceFormMade_Key("UP")
   ON KEY DOWN  OF WForma ACTION PInterfaceFormMade_Key("DOWN")
   ON KEY LEFT  OF WForma ACTION PInterfaceFormMade_Key("LEFT")
   ON KEY RIGHT OF WForma ACTION PInterfaceFormMade_Key("RIGHT") 
ENDIF

RETURN
*--------------------------------------------------------------------------------------------
// ************** LISTA DE OBJETOS **************
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDeObjetos_Formulario()
LOCAL I
// Ventana de propiedades de Controles
DEFINE WINDOW WControles ;
               AT 250,0 ;
               WIDTH 300 HEIGHT 500 ;
               TITLE PSayText({"Controles","Controls"}) ;
               CHILD ;
               NOSYSMENU
               
@ 10 ,10 COMBOBOX Cbx_Controles;
         PARENT WControles;
         WIDTH 270;
         HEIGHT 150;
         ON CHANGE PInterfaceListaDeObjetos_Cambio()
         
@ 40,10 GRID Grd_Propiedades;
        WIDTH 270;
        HEIGHT 300;
        HEADERS {PSayText({'Propiedad','Propietie'}),PSayText({'Valor','Value'})} ;
        WIDTHS {120,120} ;
        ON DBLCLICK PInterfaceListaDePropiedades_Edit()
        
    // Acciones
     mLinea:= WControles.Grd_Propiedades.ROW+WControles.Grd_Propiedades.HEIGHT+10
     
     @ mLinea, 10 FRAME   Frm_Desplazamiento  CAPTION PSayText({'Desplazamiento','Displacement'})  WIDTH 270  HEIGHT 100  
     mLinea+=20
     mColum:= 20
     @ mLinea   ,mColum+30  BUTTONEX  Btn_Mas    CAPTION "+"        WIDTH 35 HEIGHT 17 ACTION PInterfaceFormMade_Incremento(1)  TOOLTIP PSayText({"Incrementa el Factor de movimiento","Increases move factor"})
     @ mLinea   ,mColum+180 BUTTONEX  Btn_Up     PICTURE "bUp"      WIDTH 35 HEIGHT 35 ACTION PInterfaceFormMade_Key("UP")      TOOLTIP PSayText({"Mueve Hacia Arriba o Reduce el Alto del Control Seleccionado","Move up or reduce the control hiegth"})
     @ mLinea+18,mColum+30  LABEL     Btn_Factor VALUE   ALLTRIM(STR(nNumSkip))        WIDTH 35 HEIGHT 35 BORDER SIZE 12 CENTERALIG
     
     @ mLinea+=35,mColum+145 BUTTONEX Btn_Left    PICTURE "bleft"    WIDTH 35 HEIGHT 35 ACTION PInterfaceFormMade_Key("LEFT")     TOOLTIP PSayText({"Mueve Hacia la Izquierda o Reduce el Ancho del Control Seleccionado","Move Left or reduce the control width"})
     @ mLinea    ,mColum+180 BUTTONEX Btn_Down    PICTURE "bdown"    WIDTH 35 HEIGHT 35 ACTION PInterfaceFormMade_Key("DOWN")  TOOLTIP PSayText({"Mueve Hacia Abajo o Incrementa la Altitud del Control Seleccionado","Move down or increment the control hiegth"})
     @ mLinea    ,mColum+215 BUTTONEX Btn_Rigth   PICTURE "bright"   WIDTH 35 HEIGHT 35 ACTION PInterfaceFormMade_Key("RIGHT")    TOOLTIP PSayText({"Mueve Hacia Derecha o Incrementa el Ancho del Control Seleccionado","Move right or increment the control width"})
     
     @ mLinea+18 ,mColum+30  BUTTONEX Btn_Menos   CAPTION  "-"       WIDTH 35 HEIGHT 17 ACTION PInterfaceFormMade_Incremento(-1)  TOOLTIP PSayText({"Decrementa el Factor de movimiento","Decreases move factor"})

END WINDOW

WControles.Btn_Up.Enabled   := .F.
WControles.Btn_Left.Enabled := .F.
WControles.Btn_Down.Enabled := .F.
WControles.Btn_Rigth.Enabled:= .F.

FOR I:=1 TO LEN(aControles)
  WControles.Cbx_Controles.AddItem(aControles[I,2])
NEXT
RETURN
*--------------------------------------------------------------------------------------------
// ************** FORMULARIO PRINCIPAL **************
*--------------------------------------------------------------------------------------------
FUNCTION Main(mSendNameFile)
// Formulario PRINCIPAL
LOCAL cIniFile := GetStartupFolder() + '\setup.ini'

PRIVATE FileName

PUBLIC aControles
PUBLIC mTipoAccion 
PUBLIC mTipoControl
PUBLIC aClipBoard
PUBLIC aUnDo
PUBLIC mMoveIman:= .T.
PUBLIC mConCuadricula:= .T.
PUBLIC nNumSkip:=1
PUBLIC mMasButtos:= .F.
PUBLIC mMasBCaption
PUBLIC mMasBPicture
PUBLIC mMasBToolTip
PUBLIC mTabajando:= .F.
PUBLIC mIdioma:= 'ESP'

PUBLIC nTitleBarHeight := GetTitleHeight()
PUBLIC nBorderWidth    := GetBorderWidth()

Sys_BackColor:= nRGB2Arr( GetSysColor( COLOR_BTNFACE ) )
Sys_FontColor:= nRGB2Arr( GetSysColor( COLOR_WINDOWTEXT ) )

GetIniValue( cIniFile )  //Load init File

FileName:= PSayText({"Nuevo","New"})

SET DEFAULT ICON TO "aIcon"
SET SHOWDETAILERROR OFF
SET MENUSTYLE EXTENDED
SET EPOCH TO Year(Date())-50

DEFINE WINDOW xFormulario ;
      AT 0,0 ;
      WIDTH 895 ;
      HEIGHT 175 ;
      MAIN;
      NOTIFYICON 'xForma2' ;
      TITLE FileName+' - '+MAIN_TITLE;
      ON INTERACTIVECLOSE PFinalizarForma(cIniFile);
      ON DROPFILES {| aFiles | PArchivo_Tratamiento(aFiles[1]) }
      
     mLinea:= 5
     mColum:= 10
     // Acciones
     
     @ mLinea, mColum FRAME   Frm_Archivo  CAPTION PSayText({'Archivo','File'})  WIDTH 95  HEIGHT 100  

     mLinea+=20
     mColum+= 10
     
     @ mLinea    ,mColum     BUTTONEX    Btn_Nuevo      PICTURE "Nuevo"      WIDTH 35 HEIGHT 35 ACTION  PArchivo_Nuevo()             TOOLTIP PSayText({"Nuevo Archivo","New File"})
     @ mLinea    ,mColum+=35 BUTTONEX    Btn_Abrir      PICTURE "Abrir"      WIDTH 35 HEIGHT 35 ACTION  PArchivo_Tratamiento()       TOOLTIP PSayText({"Abrir Archivo Guardado","Open File"})
     mColum:= 20
     @ mLinea+=35,mColum     BUTTONEX    Btn_GuardarA   PICTURE "guardar"    WIDTH 35 HEIGHT 35 ACTION  PArchivo_Guardar()           TOOLTIP PSayText({"Guarda Archivo actual","Save File"})
     @ mLinea    ,mColum+=35 BUTTONEX    Btn_GuardarB   PICTURE "Guardarb"   WIDTH 35 HEIGHT 35 ACTION  PArchivo_Guardar(.T.)        TOOLTIP PSayText({"Guarda Archivo con otro Nombre","Save As"})
     
     mLinea:= 5
     mColum:= xFormulario.Frm_Archivo.COL+xFormulario.Frm_Archivo.WIDTH+5
     
     @ mLinea, mColum FRAME  Frm_Formulario  CAPTION 'Form'  WIDTH 55  HEIGHT 100
     mLinea+=20
     mColum+= 10
     @ mLinea    ,mColum  CHECKBUTTON Btn_Cuadricula PICTURE "cuadricula" WIDTH 35 HEIGHT 35 VALUE mConCuadricula ON CHANGE  PInterfaceFormMade_Cuadros() TOOLTIP PSayText({"Pone o quita los puntos de Referencia","Off or On reference dots"})
     @ mLinea+=35,mColum  BUTTONEX    Btn_Formulario PICTURE "formulario" WIDTH 35 HEIGHT 35 ACTION  PInterfaceFormMade_Mostrar() TOOLTIP PSayText({"Muestra/Actualiza el Formulario","Show/Refresh form"})

     mLinea:= 5
     mColum:= xFormulario.Frm_Formulario.COL+xFormulario.Frm_Formulario.WIDTH+5


     // Controles
     @ mLinea, mColum FRAME  New_Buttons  CAPTION PSayText({'Controles','Controls'})  WIDTH 370  HEIGHT 100  
     mLinea+=20
     mColum+= 10
     @ mLinea,mColum     CHECKBUTTON Btn_Frame     PICTURE "frame"         WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("FRAME"     ) TOOLTIP "frame"
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Lebel     PICTURE "Label"         WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("LABEL"     ) TOOLTIP "label"
     @ mLinea,mColum+=35 CHECKBUTTON Btn_GetBox    PICTURE "getbox"        WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("GETBOX"    ) TOOLTIP "getbox"
     @ mLinea,mColum+=35 CHECKBUTTON Btn_CHECKBOX  PICTURE "chkbox"        WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("CHECKBOX"  ) TOOLTIP "checkbox" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Radio     PICTURE "radiogrp"      WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("RADIOGROUP") TOOLTIP "radiogroup" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Combo     PICTURE "combo"         WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("COMBOBOX"  ) TOOLTIP "combobox" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_BUTTONEX  PICTURE "boton"         WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("BUTTONEX"  ) TOOLTIP "buttonex" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_DatePic   PICTURE "datepicker"    WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("DATEPICKER") TOOLTIP "datepicker" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Tree      PICTURE "Tree"          WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("TREE")       TOOLTIP "Tree" 
     @ mLinea,mColum+=35 BUTTONEX    Btn_BUTNEXMas PICTURE "botons"        WIDTH 35 HEIGHT 35 ACTION              PMain_MasControles()       TOOLTIP PSayText({"Variedad de buttonex","Variety of buttonex"}) 
     
     mColum:= xFormulario.Frm_Formulario.COL+xFormulario.Frm_Formulario.WIDTH+5
     
     mLinea+=35
     mColum+= 10
     @ mLinea,mColum     CHECKBUTTON Btn_Spliner   PICTURE "spinner"   WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("SPINNER"      ) TOOLTIP "spinner"
     @ mLinea,mColum+=35 CHECKBUTTON Btn_tbrows    PICTURE "tsbrowse"  WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("TBROWSE"      ) TOOLTIP "tbrowse"
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Grid      PICTURE "Grid"      WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("GRID"         ) TOOLTIP "grid"
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Progres   PICTURE "progres"   WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("PROGRESSBAR"  ) TOOLTIP "progresbar" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_ListBox   PICTURE "listbox"   WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("LISTBOX"      ) TOOLTIP "listbox" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_EditBox   PICTURE "editbox"   WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("EDITBOX"      ) TOOLTIP "editbox" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Image     PICTURE "Image"     WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("IMAGE"        ) TOOLTIP "imagen" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_hyperlink PICTURE "hyperlink" WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("HYPERLINK"    ) TOOLTIP "hyperlink" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Timer     PICTURE "timer"     WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("TIMER"        ) TOOLTIP "Timer" 
     @ mLinea,mColum+=35 CHECKBUTTON Btn_ChKButton PICTURE "chkbuton"  WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Tipo("CHECKBUTTON"  ) TOOLTIP "checkbutton" 

     mLinea:= 5
     mColum:= xFormulario.New_Buttons.COL+xFormulario.New_Buttons.WIDTH+5
     
     // Acciones
     @ mLinea, mColum FRAME   Frm_Acciones  CAPTION PSayText({'Acciones','Actions'})  WIDTH 195  HEIGHT 100  
     mLinea+=20
     mColum+= 10
     
     @ mLinea,mColum     CHECKBUTTON Btn_Nada    PICTURE "select"    WIDTH 35 HEIGHT 35 VALUE .T. ON CHANGE PObjeto_Acciones("SELECCION") TOOLTIP PSayText({"Cambia a modo seleccion","Select Mode"})
     @ mLinea,mColum+=35 CHECKBUTTON Btn_ADD     PICTURE "Add"       WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Acciones("AGREGAR")   TOOLTIP PSayText({"agregar un Objeto del Tipo seleccionado","Add a Selected Control"})
     @ mLinea,mColum+=35 CHECKBUTTON Btn_SIZE    PICTURE "size"      WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Acciones("TAMANIO")   TOOLTIP PSayText({"Cambia el tamaño del Objeto Seleccionado (Tambien puede utilizar la Fechas del Teclado)","Change selected object size (also can you use the keyboard arrows)"})
     @ mLinea,mColum+=35 BUTTONEX    Btn_Copiar  PICTURE "Copiar"    WIDTH 35 HEIGHT 35 ACTION              PObjeto_Copiar()              TOOLTIP PSayText({"Copia el Objeto Seleccionado","Copy selected object"})
     @ mLinea,mColum+=35 CHECKBUTTON Btn_Iman    PICTURE "iman"      WIDTH 35 HEIGHT 35 VALUE mMoveIman ON CHANGE PObjeto_Iman()          TOOLTIP PSayText({"Ajusta los Objectos a los Puntos de Referencia","Adjust the object to reference dots"})
     mColum:= xFormulario.New_Buttons.COL+xFormulario.New_Buttons.WIDTH+5
     mColum+=10
     @ mLinea+=35,mColum     CHECKBUTTON Btn_Move    PICTURE "Move"     WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Acciones("MOVER") TOOLTIP PSayText({"Mueve el Objeto Seleccionado (Tambien puede utilizar la Fechas del Teclado)","Move selected object (also can you use the keyboard arrows)"})
     @ mLinea    ,mColum+=35 BUTTONEX    Btn_DEL     PICTURE "Borrar"   WIDTH 35 HEIGHT 35 ACTION              PObjeto_Borrar()          TOOLTIP PSayText({"Borra el Objeto Seleccionado","Delete selected object"})
     @ mLinea    ,mColum+=35 BUTTONEX    Btn_UnDo    PICTURE "Deshacer" WIDTH 35 HEIGHT 35 ACTION              PObjeto_UnDoRestar()      TOOLTIP PSayText({"Deshace la ultima acción","Undo"})
     //@ mLinea    ,mColum+=35 BUTTONEX    Btn_UnDo    PICTURE "Deshacer" WIDTH 35 HEIGHT 35 ACTION     PInterfaceListaDePropiedades_Undo()      TOOLTIP "Deshace la ultima acción"
     @ mLinea    ,mColum+=35 CHECKBUTTON Btn_PEGAR   PICTURE "Pegar"    WIDTH 35 HEIGHT 35 VALUE .F. ON CHANGE PObjeto_Acciones("PEGAR") TOOLTIP PSayText({"Pega un Objeto Igual al que se haya copiado","Paste copied object"})
     @ mLinea    ,mColum+=35 BUTTONEX    Btn_RUN     PICTURE "Play"     WIDTH 35 HEIGHT 35 ACTION              PForm_RUN()               TOOLTIP PSayText({"Compilar para vista previa","Compile to preview"})

     // Acciones
     mLinea:= 5
     mColum:= xFormulario.Frm_Acciones.COL+xFormulario.Frm_Acciones.WIDTH+5

     // Codigo
     @ mLinea, mColum FRAME    Frm_Comandos        CAPTION PSayText({'Código',''})  WIDTH 120  HEIGHT 100 
     mLinea+=20
     mColum+=10
     @ mLinea      , mColum BUTTONEX   Btn_Codigo   CAPTION "010101"  WIDTH 100  HEIGHT 25 ACTION              PGetCodigo(.F.)  TOOLTIP PSayText({"Generar Codigo","Do Code"})
     @ mLinea+=  27, mColum CHECKBOX   Chk_Selpara  CAPTION PSayText({'Generar Vertical','Vertical Code'})   WIDTH 105 HEIGHT 25
     @ mLinea+=  25, mColum CHECKBOX   Chk_LineAdd  CAPTION PSayText({'Conserva Linea'  ,'Keep row'     })     WIDTH 105 HEIGHT 25
     
     DEFINE STATUSBAR 
          STATUSITEM "Mouse Pos" WIDTH 500
          STATUSITEM PSayText({"Language","Idioma"}) WIDTH 100 ACTION PForm_ChanLanguage( cIniFile )
     END STATUSBAR

     DEFINE NOTIFY MENU 
          ITEM '&Restore' ACTION xFormulario.Restore
          SEPARATOR	
          ITEM 'E&xit'    ACTION xFormulario.Release
     END MENU

END WINDOW

xFormulario.center
SETPROPERTY("xFormulario","ROW",1)

PMain_Inicia() 

// Revisar si no envio algun archivo
PxForInit(mSendNameFile)

PInterfaceListaDeObjetos_Formulario()
WControles.Cbx_Controles.value:= 1

PInterfaceFormMade_Formulario()
SETPROPERTY("WControles","ROW", GETPROPERTY("WForma","ROW")    )
SETPROPERTY("WControles","COL", GETPROPERTY("WForma","COL")-310)
IF GETPROPERTY("WControles","COL") <= 0
  SETPROPERTY("WForma","COL",310)
ENDIF

ACTIVATE WINDOW xFormulario,WControles,WForma
RETURN NIL
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PForm_RUN()
LOCAL mPath:= GetStartupFolder()

mPath+= "\"
IF FILE(mPath+"build.bat")
  PGetCodigo(.T.)
  IF FILE(mPath+"myform.prg")
     EXECUTE FILE mPath+"build.bat" PARAMETERS "/e /w"
  ENDIF
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PForm_ChanLanguage( cIniFile )
IF mIdioma = "ESP"
  mIdioma:= "ENG"
ELSE
  mIdioma:= "ESP"
ENDIF

SetIniValue( cIniFile )
Msgbox(PSayText({"Por favor, vuelva a cargar la aplicación para ajustar los cambios","Please, reload the application to set the changes"}))
IF MsgYesNo (PSayText({"¿Desea que cierre la aplicación?","Do you want to close the application?"}))
  xFormulario.release
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE GetIniValue( cIni )
LOCAL nMagnetic:= 1
LOCAL nDotGrid := 1

BEGIN INI FILE cIni
  GET mIdioma   SECTION 'SetUP' ENTRY 'Language'     DEFAULT 'ESP'
  GET nNumSkip  SECTION 'SetUP' ENTRY 'Displacement' DEFAULT 1
  GET nMagnetic SECTION 'SetUP' ENTRY 'Magnetic'     DEFAULT 1
  GET nDotGrid  SECTION 'SetUP' ENTRY 'DotGrid'      DEFAULT 1
END INI

mMoveIman     := IF(nMagnetic=1,.T.,.F.)
mConCuadricula:= IF(nDotGrid =1,.T.,.F.)
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE SetIniValue( cIni )

BEGIN INI FILE cIni
  SET SECTION 'SetUP' ENTRY 'Language'     TO mIdioma
  SET SECTION 'SetUP' ENTRY 'Displacement' TO nNumSkip
  SET SECTION 'SetUP' ENTRY 'Magnetic'     TO IF(mMoveIman,1,0)
  SET SECTION 'SetUP' ENTRY 'DotGrid'      TO IF(mConCuadricula,1,0)
END INI

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PMain_MasControles()
LOCAL mMouseRow,;
      aMouseCol,;
      mNumLine
mMouseRow := GetCursorPos()[ 1 ]-15
aMouseCol := GetCursorPos()[ 2 ]-15

DEFINE WINDOW W_Botones;
       AT mMouseRow,aMouseCol;
       WIDTH 137;
       HEIGHT 168;
       TITLE PSayText({'Botones','Buttons'});
       MODAL


   ON KEY ESCAPE ACTION W_Botones.RELEASE

   mNumLine:= 0

   @ mNumLine+=   9,   9 BUTTONEX        Btn_Aceptar     CAPTION PSayText({'&Aceptar' ,'&Accept'})  PICTURE "Aceptar16"  WIDTH 100  HEIGHT 25  ACTION PMain_MasControlesOk()  TOOLTIP PSayText({'Acepta los Datos actuales','Accept current data'})
   @ mNumLine+=  30,   9 BUTTONEX        Btn_Cancelar    CAPTION PSayText({'&Cancelar','&Cancel'})  PICTURE "CANCELAR16" WIDTH 100  HEIGHT 25  ACTION PMain_MasControlesOk()  TOOLTIP PSayText({'Aborta los Datos Actuales','Cancel current data'})
   @ mNumLine+=  30,   9 BUTTONEX        Btn_Regresar    CAPTION PSayText({'&Regresar','&Return'})  PICTURE "RETORNAR16" WIDTH 100  HEIGHT 25  ACTION PMain_MasControlesOk()  TOOLTIP PSayText({'Regresa al Menu anterior' ,'Back to last menu'})
   @ mNumLine+=  30,   9 BUTTONEX        Brn_Print       CAPTION PSayText({'&Imprimir','&Print' })  PICTURE "PRINT16"    WIDTH 100  HEIGHT 25  ACTION PMain_MasControlesOk()  TOOLTIP PSayText({'Enviar datos a Impresora' ,'Send data to print'})

END WINDOW
W_Botones.ACTIVATE
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PMain_MasControlesOk()
mMasButtos  := .T.
mMasBCaption:=  this.Caption
mMasBPicture:=  this.Picture
mMasBToolTip:=  this.ToolTip
PObjeto_Tipo("BUTTONEX" ,"Btn_BUTTONEX")
W_Botones.Release
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PxForInit(mSendNameFile)
PEnabledDesplazar(.F.)
IF mSendNameFile#NIL
  PArchivo_Abrir(mSendNameFile)
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PMain_Inicia()
LOCAL mFormRow   := GETPROPERTY("xFormulario","ROW")
LOCAL mFormCOL   := GETPROPERTY("xFormulario","COL")
LOCAL mFormHEIGHT:= GETPROPERTY("xFormulario","HEIGHT")
LOCAL mFormWIDTH := GETPROPERTY("xFormulario","WIDTH")
LOCAL mMyRow
LOCAL mMyCol

mMyRow:= mFormRow+mFormHEIGHT+10
mMyCol:= mFormCOL+(mFormWIDTH/2)-250

aClipBoard:= {}
aControles:= {}
aUnDo     := {}

mTipoAccion := "SELECCION"
mTipoControl:= "SELECCION"
AADD(aControles  ,{"FORM",PSayText({"Formulario","Template01"}),{{"NAME",PSayText({"Formulario","Template01"}),1,"V"},{"TITLE","Title",6,"T"},{"ROW",mMyRow,2,"V"},{"COL",mMyCol,3,"V"},{"WIDTH",500,4,"V"},{"HEIGHT",600,5,"V"}}})
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PFinalizarForma(cIniFile)
LOCAL mRespuesta
IF LEN(aControles) > 1
   mRespuesta := MsgYesNoCancel(PSayText({"Guardar Archivo Antes de Salir?","Save the file before to exit?"}),PSayText({"CERRAR APLICACION","CLOSE APPLICATION"}))
ELSE
  mRespuesta:= 0
ENDIF
IF mRespuesta = 1
   PArchivo_Guardar()
ENDIF

IF mRespuesta = -1
  RETURN(.F.)
ENDIF
SetIniValue( cIniFile )
RETURN(.T.)
*--------------------------------------------------------------------------------------------
// ********** PROCEDIMIENTO DEL FORMULARIO QUE SE EDITA
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_DefineObjetos()
// Agregar los Controles ya definidos
LOCAL mCont
IF LEN(aControles) > 1
  FOR mCont:= 2 TO LEN(aControles)
    PObjeto_Crear(aControles[mCont,1],aControles[mCont,3])
  NEXT
ENDIF

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Mostrar()
  IF _IsWindowDefined("WForma")
    // Hacer Refresh
    WForma.SetFocus
    IF mConCuadricula
       PInterfaceFormMade_Refresh()
    ENDIF
  ELSE
    PInterfaceFormMade_Formulario()
    ACTIVATE WINDOW WForma  
  ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Move()
LOCAL mWinRow,mWinTemRow
LOCAL mWinCol,mWinTemCol
LOCAL mWinMainRow
LOCAL mWinMainCol
LOCAL mWinCtrlRow
LOCAL mWinCtrlCol

// Mover las ventanas de Trabajo
mWinRow:= GETPROPERTY("WForma","ROW")
mWinCol:= GETPROPERTY("WForma","COL")
mWinTemRow := aControles[1,3,3,2]
mWinTemCol := aControles[1,3,4,2]

aControles[1,3,3,2]:= mWinRow
aControles[1,3,4,2]:= mWinCol

IF WControles.Cbx_Controles.value # 1
  WControles.Cbx_Controles.value:= 1
ELSE
  PInterfaceListaDeObjetos_Cambio()
ENDIF
// Mover tambien las Otras Ventanas
mWinMainRow:= GETPROPERTY("xFormulario","ROW")
mWinMainCol:= GETPROPERTY("xFormulario","COL")
mWinCtrlRow:= GETPROPERTY("WControles" ,"ROW")
mWinCtrlCol:= GETPROPERTY("WControles" ,"COL")

mWinTemRow:= mWinTemRow-mWinRow
mWinTemCol:= mWinTemCol-mWinCol

mWinMainRow:= mWinMainRow-mWinTemRow
mWinMainCol:= mWinMainCol-mWinTemCol
mWinCtrlRow:= mWinCtrlRow-mWinTemRow
mWinCtrlCol:= mWinCtrlCol-mWinTemCol

SETPROPERTY("xFormulario","ROW",mWinMainRow)
SETPROPERTY("xFormulario","COL",mWinMainCol)
SETPROPERTY("WControles" ,"ROW",mWinCtrlRow)
SETPROPERTY("WControles" ,"COL",mWinCtrlCol)
SETPROPERTY("xFormulario","ROW",mWinMainRow)
SETPROPERTY("xFormulario","COL",mWinMainCol)
SETPROPERTY("WControles" ,"ROW",mWinCtrlRow)
SETPROPERTY("WControles" ,"COL",mWinCtrlCol)

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Size()
LOCAL mWinWidth
LOCAL mWinHeight

mWinWidth  := GETPROPERTY("WForma","Width")
mWinHeight := GETPROPERTY("WForma","Height")

aControles[1,3,5,2]:= mWinWidth
aControles[1,3,6,2]:= mWinHeight

IF WControles.Cbx_Controles.value # 1
  WControles.Cbx_Controles.value:= 1
ELSE
  PInterfaceListaDeObjetos_Cambio()
ENDIF
PInterfaceFormMade_Refresh()

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Mouse()
LOCAL aMousePos
aMousePos:= FGetMousePos()
xFormulario.StatusBar.Item(1):= "Mouse ROW:     "+hb_ntos(aMousePos[1])+"       COL:  "+hb_ntos(aMousePos[2])
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Refresh()
LOCAL cIniFile := GetStartupFolder() + '\setup.ini'
LOCAL mCont1:= 10,;
      mCont2:= 10,;
      mCont1Step,;
      mCont2Step
LOCAL mWinWidth
LOCAL mWinHeight

ERASE WINDOW WForma
IF mConCuadricula
   mWinWidth := GETPROPERTY("WForma","Width")
   mWinHeight:= GETPROPERTY("WForma","Height")
   BEGIN INI FILE cIniFile
     GET mCont1 SECTION 'SetUP' ENTRY 'VertDotsStep' DEFAULT 10
     GET mCont2 SECTION 'SetUP' ENTRY 'HorzDotsStep' DEFAULT 10
   END INI
   mCont1Step:= Max(mCont1,5)
   mCont2Step:= Max(mCont2,5)

   DO WHILE mCont1 < mWinHeight
      DO WHILE mCont2 < mWinWidth
        DRAW LINE IN WINDOW WForma AT mCont1,mCont2 TO mCont1,mCont2+1
        mCont2+= mCont2Step
      ENDDO
      mCont2:= mCont2Step
      mCont1+= mCont1Step
   ENDDO
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Cuadros()
mConCuadricula:= !mConCuadricula
PInterfaceFormMade_Refresh()
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Click()
// Control de Acciones 
LOCAL mNameCtrl,I,J
LOCAL aMousePos
LOCAL mNumItem
LOCAL aPropControl
LOCAL nLocalRow
LOCAL nLocalCol

// Posicion del Raton

DO CASE
CASE mTipoAccion = "AGREGAR"
     aMousePos:= FGetMousePos(.T.)
     mNameCtrl:= FObjeto_NexName(mTipoControl)
     IF mTipoControl = "SELECCION"
       RETURN
     ENDIF

     // Agregar el Nuevo Control
     aPropControl:= PObjeto_Properties(mTipoControl,mNameCtrl,aMousePos)
     PObjeto_Add(mTipoControl,mNameCtrl,aPropControl)
     
     // Sugerir un Modo
     IF mTipoControl = "FRAME"   .OR. ;
        mTipoControl = "TBROWSE" .OR. ;
        mTipoControl = "GRID"    .OR. ;
        mTipoControl = "LISTBOX" .OR. ;
        mTipoControl = "EDITBOX" .OR. ;
        mTipoControl = "IMAGE"
       PObjeto_Acciones("TAMANIO","Btn_SIZE") 
     ELSE
       PObjeto_Acciones("MOVER","Btn_Move")
     ENDIF
     
CASE mTipoAccion = "PEGAR"
   PObjeto_Pegar()
   
CASE mTipoAccion = "SELECCION" .OR. ;
     mTipoAccion = "TAMANIO"   .OR. ;
     mTipoAccion = "MOVER"

    // Seleccionar Frame o Progres Bar
    IF !mTabajando
       aMousePos:= FGetMousePos()
       FOR I:= 1 TO LEN(aControles)
          IF aControles[I,1] = "FRAME" .OR. ;
             aControles[I,1] = "PROGRESSBAR"
             nLocalRow:= 0
             nLocalCol:= 0
             FOR J:=1 TO LEN(aControles[I,3])
                  IF aControles[I,3,J,1]="ROW"
                     nLocalRow:= aControles[I,3,J,2]
                  ENDIF
                  IF aControles[I,3,J,1]="COL"
                     nLocalCol:= aControles[I,3,J,2]
                  ENDIF
             NEXT
             IF nLocalRow <= aMousePos[1] .AND. nLocalRow+20 >= aMousePos[1] .AND.;
                nLocalCol <= aMousePos[2] .AND. nLocalCol+60 >= aMousePos[2]
                // Seleccionar
                mNumItem:= I
                WControles.Cbx_Controles.value:= mNumItem
                PObjeto_Ubicar(WControles.Cbx_Controles.Item(mNumItem))
               EXIT
             ENDIF
          ENDIF
       NEXT
    ELSE
      mTabajando:= .F.  //Esta variable, evita estar revisando el vector en cada momento.
    ENDIF
ENDCASE

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterface_Object_Mover()  
// Mueve un objeto de lugar
LOCAL aMousePos, mNumItem, mNomItem, i
mNumItem:= WControles.Cbx_Controles.value
IF mNumItem = 1
  RETURN
ENDIF
mNomItem:= WControles.Cbx_Controles.ITEM(mNumItem)

DOMETHOD('WForma',"SETFOCUS")
// Esconder el Control y Crear Un Frame
DOMETHOD('WForma',mNomItem,"HIDE")

// Control Temporal
mDefine_COL    := GETPROPERTY("WForma",mNomItem,"COL")
mDefine_ROW    := GETPROPERTY("WForma",mNomItem,"ROW")
mDefine_WIDTH  := GETPROPERTY("WForma",mNomItem,"WIDTH")
mDefine_HEIGHT := GETPROPERTY("WForma",mNomItem,"HEIGHT")

IF _IsControlDefined ("Frm_ShowControl","WForma")
   WForma.Frm_ShowControl.RELEASE
ENDIF

DEFINE FRAME Frm_ShowControl
             PARENT WForma 
             COL mDefine_COL 
             ROW mDefine_ROW 
             CAPTION "" 
             WIDTH mDefine_WIDTH 
             HEIGHT mDefine_HEIGHT 
END FRAME 

mTabajando:= .T.
DO WHILE .T.
  //Si elimino el Control desde el Menu Contextual que se salga
  IF !_IsControlDefined (mNomItem,"WForma")
    EXIT
  ENDIF
  aMousePos:= FGetMousePos(.T.)
  // Si se salio de la ventana
   IF aMousePos[1] < 0 .OR. aMousePos[2] < 0
     EXIT
   ENDIF
   IF aMousePos[1] > GETPROPERTY("WForma","HEIGHT") .OR. ;
      aMousePos[2] > GETPROPERTY("WForma","WIDTH" )
     EXIT
   ENDIF
   
   // Para que no esta cambiando a Cada Rato
   IF GETPROPERTY("WForma",mNomItem,"ROW") # aMousePos[1] .OR. ;
      GETPROPERTY("WForma",mNomItem,"COL") # aMousePos[2]
      
         SETPROPERTY("WForma",mNomItem,"ROW",aMousePos[1])
         SETPROPERTY("WForma",mNomItem,"COL",aMousePos[2]) 
         
         WForma.Frm_ShowControl.ROW:= aMousePos[1]
         WForma.Frm_ShowControl.COL:= aMousePos[2]
        
         FOR I:= 1 TO LEN(aControles[mNumItem,3])
            IF aControles[mNumItem,3,I,1]="ROW"
               aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"ROW"))
            ENDIF
            IF aControles[mNumItem,3,I,1]="COL"
               aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"COL"))
            ENDIF
         NEXT
         PInterfaceListaDeObjetos_Cambio()
  ENDIF
  DO EVENTS  
  IF !mTabajando
    EXIT
  ENDIF
ENDDO

IF _IsControlDefined ("Frm_ShowControl","WForma")
   WForma.Frm_ShowControl.RELEASE
ENDIF

IF _IsControlDefined (mNomItem,"WForma")
  DOMETHOD('WForma',mNomItem,"SHOW")
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterface_Object_Tamanio()
LOCAL aMousePos, mNumItem, mNomItem, i
LOCAL mDefine_COL, mDefine_ROW, mDefine_WIDTH, mDefine_HEIGHT
LOCAL mCtrlRow
LOCAL mCtrlCol
mNumItem:= WControles.Cbx_Controles.value
IF mNumItem = 1
  RETURN
ENDIF
mNomItem:= WControles.Cbx_Controles.ITEM(mNumItem)

DOMETHOD('WForma',"SETFOCUS")

mCtrlRow:= GETPROPERTY("WForma",mNomItem,"ROW")
mCtrlCol:= GETPROPERTY("WForma",mNomItem,"COL")
IF aControles[mNumItem,1] # "LABEL"
    DOMETHOD('WForma',mNomItem,"HIDE")
ENDIF
// Control Temporal
mDefine_COL    := GETPROPERTY("WForma",mNomItem,"COL")
mDefine_ROW    := GETPROPERTY("WForma",mNomItem,"ROW")
mDefine_WIDTH  := GETPROPERTY("WForma",mNomItem,"WIDTH")
mDefine_HEIGHT := GETPROPERTY("WForma",mNomItem,"HEIGHT")

IF _IsControlDefined ("Frm_ShowControl","WForma")
   WForma.Frm_ShowControl.RELEASE
ENDIF

DEFINE FRAME Frm_ShowControl
             PARENT WForma 
             COL mDefine_COL 
             ROW mDefine_ROW 
             CAPTION "" 
             WIDTH mDefine_WIDTH 
             HEIGHT mDefine_HEIGHT 
             
END FRAME 

mTabajando:= .T.
DO WHILE .T.
  aMousePos:= FGetMousePos(.T.)
  IF !_IsControlDefined (mNomItem,"WForma")
    EXIT
  ENDIF
  IF aMousePos[1] < 0 .OR. aMousePos[2] < 0
     EXIT
  ENDIF
  IF aMousePos[1] > GETPROPERTY("WForma","HEIGHT") .OR. ;
     aMousePos[2] > GETPROPERTY("WForma","WIDTH" )
     EXIT
  ENDIF
  
  IF GETPROPERTY("WForma",mNomItem,"WIDTH") #aMousePos[2]-mCtrlCol .OR. ;
     GETPROPERTY("WForma",mNomItem,"HEIGHT")#aMousePos[1]-mCtrlRow
      IF aMousePos[2]-mCtrlCol < 15 
         SETPROPERTY("WForma",mNomItem,"WIDTH",15)
      ELSE
         SETPROPERTY("WForma",mNomItem,"WIDTH",aMousePos[2]-mCtrlCol)
      ENDIF
      WForma.Frm_ShowControl.WIDTH:= GETPROPERTY("WForma",mNomItem,"WIDTH")
      IF aMousePos[1]-mCtrlRow < 15
         SETPROPERTY("WForma",mNomItem,"HEIGHT",15)
      ELSE
         SETPROPERTY("WForma",mNomItem,"HEIGHT",aMousePos[1]-mCtrlRow)
      ENDIF
      WForma.Frm_ShowControl.HEIGHT:= GETPROPERTY("WForma",mNomItem,"HEIGHT")
      
      FOR I:= 1 TO LEN(aControles[mNumItem,3])
         IF aControles[mNumItem,3,I,1]=="WIDTH"
            aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"WIDTH"))
         ENDIF
         IF aControles[mNumItem,3,I,1]="HEIGHT"
            aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"HEIGHT"))
         ENDIF
      NEXT
      PInterfaceListaDeObjetos_Cambio()
  ENDIF
  DO EVENTS  
  IF !mTabajando
    EXIT
  ENDIF
ENDDO

IF _IsControlDefined ("Frm_ShowControl","WForma")
   WForma.Frm_ShowControl.RELEASE
ENDIF

IF _IsControlDefined (mNomItem,"WForma")
  DOMETHOD('WForma',mNomItem,"SHOW")
ENDIF

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Incremento(mIncremento)
// Incrementa el Factor de Movimiento.
nNumSkip:= nNumSkip+mIncremento
IF nNumSkip <= 0
   nNumSkip:= 1
ENDIF
WControles.Btn_Factor.Value:= ALLTRIM(STR(nNumSkip))
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Key(mKey)
LOCAL mNumItem, mNomItem, i
LOCAL mColum
LOCAL mRow
LOCAL mWidth
LOCAL mHeight

mNumItem:= WControles.Cbx_Controles.value
IF mNumItem = 1
  RETURN
ENDIF
mNomItem:= WControles.Cbx_Controles.ITEM(mNumItem)

mColum := GETPROPERTY("WForma",mNomItem,"COL"   )
mRow   := GETPROPERTY("WForma",mNomItem,"ROW"   )
mWidth := GETPROPERTY("WForma",mNomItem,"WIDTH" )
mHeight:= GETPROPERTY("WForma",mNomItem,"HEIGHT")
DO CASE
CASE mKey = "UP"
    mRow-=nNumSkip
    mHeight-=nNumSkip

CASE mKey = "DOWN"
    mRow+=nNumSkip
    mHeight+=nNumSkip

CASE mKey = "LEFT"
    mColum-=nNumSkip
    mWidth-=nNumSkip

CASE mKey = "RIGHT"
    mColum+=nNumSkip
    mWidth+=nNumSkip

ENDCASE

DO CASE
CASE mTipoAccion = "MOVER"
    // Revisa si se esta moviendo fuera del formulario Principal
    DO CASE
    CASE mKey = "UP" .AND. mRow < 0
        mRow+=nNumSkip

    CASE mKey = "DOWN" .AND. mRow > ( GETPROPERTY("WForma","HEIGHT") - GETPROPERTY("WForma",mNomItem,"HEIGHT") - 35 )  //Descontar el Titulo
        mRow-=nNumSkip
    
    CASE mKey = "LEFT" .AND. mColum < 0
        mColum+=nNumSkip
    
    CASE mKey = "RIGHT" .AND. mColum > ( GETPROPERTY("WForma","WIDTH") - GETPROPERTY("WForma",mNomItem,"WIDTH") )
        mColum-=nNumSkip
        
    ENDCASE
    
    
    SETPROPERTY("WForma",mNomItem,"ROW",mRow)
    SETPROPERTY("WForma",mNomItem,"COL",mColum)
    
    FOR I:= 1 TO LEN(aControles[mNumItem,3])
       IF aControles[mNumItem,3,I,1]="ROW"
          aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"ROW"))
       ENDIF
       IF aControles[mNumItem,3,I,1]="COL"
          aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"COL"))
       ENDIF
    NEXT
    PInterfaceListaDeObjetos_Cambio()
    
CASE mTipoAccion = "TAMANIO"
    IF mWidth < 15 
           SETPROPERTY("WForma",mNomItem,"WIDTH",15)
    ELSE
           SETPROPERTY("WForma",mNomItem,"WIDTH",mWidth)
    ENDIF
    IF mHeight < 15
       SETPROPERTY("WForma",mNomItem,"HEIGHT",15)
    ELSE
       SETPROPERTY("WForma",mNomItem,"HEIGHT",mHeight)
    ENDIF
    
    FOR I:= 1 TO LEN(aControles[mNumItem,3])
       IF aControles[mNumItem,3,I,1]=="WIDTH"
          aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"WIDTH"))
       ENDIF
       IF aControles[mNumItem,3,I,1]="HEIGHT"
          aControles[mNumItem,3,I,2]:= INT(GETPROPERTY("WForma",mNomItem,"HEIGHT"))
       ENDIF
    NEXT
    PInterfaceListaDeObjetos_Cambio()
ENDCASE

RETURN
*--------------------------------------------------------------------------------------------
// ********** PROCEDIMIENTO DEL FORMULARIO DE LISTA DE OBJETOS
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDeObjetos_Cambio()
// Seleccion de Controles
LOCAL mNumItem
LOCAL mNomItem
LOCAL I
LOCAL aPropiedades,aPropTemp
mNumItem:= WControles.Cbx_Controles.value
mNomItem:= WControles.Cbx_Controles.ITEM(mNumItem)
// Buscar el item en la Tabla
FOR I:= 1 TO LEN(aControles)
  IF aControles[I,2] = mNomItem
    aPropiedades:= aControles[I,3]
    EXIT
  ENDIF
NEXT

WControles.Grd_Propiedades.DeleteAllItems
// Prepara las caracteristicas para la Grid
FOR I:= 1 TO LEN(aPropiedades)
   aPropTemp:= {}
   AADD(aPropTemp,aPropiedades[I,1])
   DO CASE
   CASE VALTYPE(aPropiedades[I,2])="N"
       AADD(aPropTemp,STR(aPropiedades[I,2]))
   CASE VALTYPE(aPropiedades[I,2])="L"
       AADD(aPropTemp,IF(aPropiedades[I,2],".T.",".F."))
   OTHERWISE
      AADD(aPropTemp,aPropiedades[I,2])
   ENDCASE
   WControles.Grd_Propiedades.AddItem(aPropTemp)
NEXT

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_Edit()
LOCAL mNumControl, i
LOCAL mValue, mValor
LOCAL aItems, mAcceptProp
// Cambia una Propiedad
mNumControl:= WControles.Cbx_Controles.value

mValue:= WControles.Grd_Propiedades.VALUE
aItems:= WControles.Grd_Propiedades.ITEM(mValue)

mAcceptProp:= "NAME;"  + ;
            "CAPTION;" + ;
            "PICTURE;" + ;
              "VALUE;" + ;
            "OPTIONS;" + ;
              "ITEMS;" + ;
            "TOOLTIP;" + ;
                "ROW;" + ;
                "COL;" + ;
              "WIDTH;" + ;
             "HEIGHT;" + ;
         "HORIZONTAL;" + ;
           "VERTICAL;" + ;
         "INTERVAL;"   + ;
        "ITEMHEIGHT;"  + ;
         "SPACING;"    + ;
         "TITLE;"      + ; 
         "CLIENTEDGE;" + ;
         "BORDER;"     + ;
         "RIGHTALIGN;" + ;
         "CENTERALIGN"

IF !(aItems[1] $ mAcceptProp) .OR. aItems[1]=="WIDTHS"
  RETURN
ENDIF
IF aItems[1]="OPTIONS" .OR. ;
   aItems[1]="ITEMS"   .OR. ;
   aItems[1]="PICTURE" 
   IF aControles[mNumControl,1] = "GRID" .OR. ;
      aControles[mNumControl,1] = "TBROWSE"
       msgstop(PSayText({"TBROWSE Y GRID Se deben de Configurar desde el Código","TBROWSE Y GRID must be changed from the code"}))
       RETURN
   ELSE 
       IF aItems[1]="PICTURE"
          mValor:= PInterfaceListaDePropiedades_Imagen(aItems[2])
       ELSE
          mValor:= PInterfaceListaDePropiedades_Items(aItems[2])
       ENDIF
   ENDIF
ELSE
   IF aItems[2]=".T." .OR. aItems[2]=".F."
       mValor:= PInterfaceListaDePropiedades_TrueFalse(aItems[2],aItems[1]) 
   ELSE
       mValor:= PInterfaceListaDePropiedades_ChangePropiedad(aItems[1],PADR(aItems[2],150))
   ENDIF
ENDIF

// Algunos Valores no pueden quedar Vacios
IF EMPTY(mValor) .AND. ;
   (aItems[1]="NAME"       .OR. ;
    aItems[1]="OPTIONS"    .OR. ;
    aItems[1]="ITEMS"      .OR. ;
    aItems[1]="TOOLTIP"    .OR. ;
    aItems[1]="ROW"        .OR. ;
    aItems[1]="COL"        .OR. ;
    aItems[1]="WIDTH"      .OR. ;
    aItems[1]="HEIGHT"     .OR. ;
    aItems[1]="HORIZONTAL" .OR. ;
    aItems[1]="VERTICAL"   .OR. ;
    aItems[1]="SPACING"    .OR. ;
    aItems[1]="INTERVAL"   .OR. ;
    aItems[1]="ITEMHEIGHT" .OR. ;
    aItems[1]="TITLE")
  RETURN
ENDIF

DO CASE
CASE  aItems[1]="NAME"
   // Revisar
   IF AT(" ",ALLTRIM(mValor))#0
       msgstop(PSayText({"El Nombre no debe llevar espacios","The name must not have spaces"}))
       RETURN
   ENDIF

   // Revisar si el Nombre ya existe
   FOR I:= 1 TO LEN(aControles)
       IF UPPER(aControles[I,2])=UPPER(mValor)
          msgstop(PSayText({"Este Nombre de Control ya fue definido","This name already exist"}))
          RETURN
       ENDIF
   NEXT
   
   // Actualizar el Vector
   FOR I:= 1 TO LEN(aControles[mNumControl,3])
       IF aControles[mNumControl,3,I,1]=aItems[1]
          aControles[mNumControl,3,I,2]:= mValor
          EXIT
       ENDIF
   NEXT
   
  // Si Es el Nombre de Formulario 
  IF mNumControl = 1
     aControles[mNumControl,2]:= mValor
  ELSE
     // Borrar el Control Viejo
     DOMETHOD("WForma",aControles[mNumControl,2],"RELEASE")
     // Actualizar el Nombre en el Vector
     aControles[mNumControl,2]:= mValor
     // Definir el Nuevo Control
     PObjeto_Crear(aControles[mNumControl,1],aControles[mNumControl,3])
  ENDIF
  // Actualizar el Nombre en el Combo
  WControles.Cbx_Controles.ITEM(mNumControl):= mValor
  // Reposicionar el Combo de Controles
  WControles.Cbx_Controles.Value:= mNumControl

OTHERWISE

   // Actualizar la Ventana
   WControles.Grd_Propiedades.Cell( mValue , 2 ) := mValor
   
   IF mValor = ".T." .OR. mValor = ".F."
      mValor:= IF(mValor = ".T.",.T.,.F.)
   ENDIF
   
   IF aItems[1]="ROW"     .OR. ;
      aItems[1]="COL"     .OR. ;
      aItems[1]=="WIDTH"   .OR. ;
      aItems[1]="HEIGHT"  .OR. ;
      aItems[1]="INTERVAL"   .OR. ;
      aItems[1]="ITEMHEIGHT"  .OR. ;
      aItems[1]="SPACING"
      mValor:= VAL(mValor)
      IF mValor < 15 .AND. aItems[1]#"SPACING" .AND. ;
                          aItems[1]#"ROW"     .AND. ;
                          aItems[1]#"COL"
        mValor:= 15
      ENDIF
   ENDIF

   // Actualizar el Vector
   FOR I:= 1 TO LEN(aControles[mNumControl,3])
       IF aControles[mNumControl,3,I,1]=aItems[1]
          aControles[mNumControl,3,I,2]:= mValor
          EXIT
       ENDIF
   NEXT
   IF mNumControl = 1
       // Actualizar Control
       SETPROPERTY("WForma",aItems[1],mValor)
   ELSE
       IF aItems[1]="OPTIONS" .OR. aItems[1]="ITEMS" .OR. ;
          aItems[1]="SPACING" .OR. aItems[1]="HORIZONTAL" .OR. ;
          aItems[1]="VERTICAL" 
          
              IF aControles[mNumControl,1] = "RADIOGROUP"  .OR. ;
                 aControles[mNumControl,1] = "PROGRESSBAR" .OR. ;
                 aControles[mNumControl,1] = "CHECKBUTTON"
                 // Qutar el Control y Ponerlo de Nuevo
                 DOMETHOD("WForma",aControles[mNumControl,2],"RELEASE")
                 PObjeto_Crear(aControles[mNumControl,1],aControles[mNumControl,3])
              ELSE
                // Eliminar los Items y agregar los Nuevos
                IF aItems[1]="ITEMS"
                   PInterfaceListaDePropiedades_ChangeItems(aControles[mNumControl,2],mValor)
                ENDIF
              ENDIF
       ELSE
              IF !_IsControlDefined (aControles[mNumControl,2],"WForma") 
                 msgbox(aControles[mNumControl,2]+" "+PSayText({"No se encuentra el Control!","Control not found!"}))
              ELSE
                // Actualizar Control
                SETPROPERTY("WForma",aControles[mNumControl,2],aItems[1],mValor)
                IF aItems[1]="PICTURE" .AND. Empty(mValor)
                   DOMETHOD("WForma",aControles[mNumControl,2],"REFRESH")
                   PInterfaceFormMade_Refresh()
                ENDIF
              ENDIF
       ENDIF
   ENDIF

ENDCASE 

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PInterfaceListaDePropiedades_ChangePropiedad(mcPropName,mxValor)
LOCAL mNumLine
LOCAL mTempVal:= "C"

PRIVATE mxReturn:= mxValor

IF mcPropName="ROW"        .OR. ;
   mcPropName="COL"        .OR. ;
   mcPropName=="WIDTH"     .OR. ;
   mcPropName="HEIGHT"     .OR. ;
   mcPropName="INTERVAL"   .OR. ;
   mcPropName="ITEMHEIGHT" .OR. ;
   mcPropName="SPACING"
   mTempVal:= "N"
   mxValor:= VAL(mxValor)
ENDIF

DEFINE WINDOW Frm_ChangProp;
       AT 376,679;
       WIDTH 397;
       HEIGHT 151;
       TITLE PSayText({'Cambio de Propiedad','Property Change'});
       MODAL

   ON KEY ESCAPE ACTION Frm_ChangProp.RELEASE

   mNumLine:= 0

   @ mNumLine+= 10, 10 LABEL      Lbl_Propiedad  VALUE mcPropName  WIDTH 100  HEIGHT 21
   @ mNumLine+= 30, 10 GETBOX     Gbx_PropVal    VALUE mxValor  WIDTH 360  HEIGHT 20
   @ mNumLine+= 30,270 BUTTONEX   Btn_Aceptar    CAPTION PSayText({'Aceptar' ,'Accept'})  PICTURE 'Aceptar16'  WIDTH 100  HEIGHT 25  ACTION PInterfaceListaDePropiedades_ChangePropOK(mTempVal,1)
   @ mNumLine+=  0,170 BUTTONEX   Btn_Cancelar   CAPTION PSayText({'Cancelar','Cancel'})  PICTURE 'CANCELAR16'  WIDTH 100  HEIGHT 25  ACTION Frm_ChangProp.RELEASE
   @ mNumLine+=  0, 60 BUTTONEX   Btn_Empty      CAPTION PSayText({'Vacio'   ,'Empty' })  WIDTH 100  HEIGHT 25  ACTION PInterfaceListaDePropiedades_ChangePropOK(mTempVal,0) TOOLTIP PSayText({'De ser posible, Deja la propiedad sin valor','if possible,  property without value'})

END WINDOW
Frm_ChangProp.CENTER
Frm_ChangProp.ACTIVATE

RETURN(mxReturn)
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ChangePropOK(mTempVal,mnTipoOK)
LOCAL mGetValue
IF mnTipoOK = 0
  mxReturn:= ""
ELSE
  IF mTempVal = "N"
     mGetValue:= Frm_ChangProp.Gbx_PropVal.VALUE
     mxReturn:= ALLTRIM(STR(mGetValue))
  ELSE
     mxReturn:= ALLTRIM(Frm_ChangProp.Gbx_PropVal.VALUE)
  ENDIF
ENDIF
Frm_ChangProp.RELEASE
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ChangeItems(mControl,mItems)
LOCAL mCont
LOCAL maItems
PRIVATE mListItem
mListItem:= mItems
maItems:= &mListItem
DOMETHOD("WForma",mControl,"DeleteAllItems")
FOR mCont:= 1 TO LEN(maItems)
   DOMETHOD("WForma",mControl,"AddItem",maItems[mCont])
NEXT
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PInterfaceListaDePropiedades_TrueFalse(mValor,mPropiedad)
LOCAL mNumLine
PRIVATE mValRetur:= mValor

DEFINE WINDOW W_FalsoVerdadero;
       AT 186,710;
       WIDTH 136;
       HEIGHT 188;
       TITLE PSayText({'Valor','Value'});
       MODAL

   ON KEY ESCAPE ACTION W_FalsoVerdadero.RELEASE

   mNumLine:= 0

   @ mNumLine+=  3,  9 FRAME        FRAME_1         CAPTION mPropiedad  WIDTH 102  HEIGHT 96
   @ mNumLine+= 22, 24 RADIOGROUP   Rdg_TrueFalse   OPTIONS {PSayText({'Verdadero','True'}),PSayText({'Felso','False'})}  VALUE IF(mValor=".T.",1,2)  WIDTH 70  SPACING 25 ON CHANGE PInterfaceListaDePropiedades_TrueFalseChage()
   @ mNumLine+= 83, 81 BUTTONEX     Btn_Ok          CAPTION 'Ok'  WIDTH 30  HEIGHT 30  ACTION W_FalsoVerdadero.Release  TOOLTIP PSayText({'Aceptar los Cambios','Change accept'})

END WINDOW
W_FalsoVerdadero.CENTER
W_FalsoVerdadero.ACTIVATE
RETURN(mValRetur)
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_TrueFalseChage()
IF W_FalsoVerdadero.Rdg_TrueFalse.VALUE = 1
   mValRetur:=".T."
ELSE
   mValRetur:=".F."
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PInterfaceListaDePropiedades_Items(aItems)
LOCAL mListItem
LOCAL mItemTemp
LOCAL mItemGrid
LOCAL mCont, mNumLine
PRIVATE mSendItems
PRIVATE mItemRetur
mItemRetur:= aItems
mSendItems:= aItems
mListItem:= &mSendItems
mItemGrid:= {}
FOR mCont:= 1 TO LEN(mListItem)
  mItemTemp:= {}
  AADD(mItemTemp,mListItem[mCont])
  AADD(mItemGrid,mItemTemp)
NEXT

DEFINE WINDOW W_ITEMS;
       AT 186,710;
       WIDTH 287;
       HEIGHT 394;
       TITLE 'Items';
       MODAL

   ON KEY ESCAPE ACTION W_ITEMS.RELEASE

   mNumLine:= 0

   @ mNumLine+=  10,  10 GRID       Grd_Items    WIDTH 252  HEIGHT 262  HEADERS {'Items'}  WIDTHS {248}  ITEMS mItemGrid ON CHANGE PInterfaceListaDePropiedades_ItemsGridChange()
   @ mNumLine+= 276,  11 GETBOX     Gbx_Item     VALUE SPACE(200)      WIDTH 250  HEIGHT 23  BACKCOLOR Sys_BackColor  FONTCOLOR Sys_FontColor
   @ mNumLine+=  29,  11 BUTTONEX   Btn_Agregar  PICTURE "Add"         WIDTH 30  HEIGHT 30 ACTION PInterfaceListaDePropiedades_ItemsGridAdd()  TOOLTIP PSayText({'Agrega un Nuevo item'          ,"Add new item"})
   @ mNumLine+=   0,  42 BUTTONEX   Btn_Guardar  PICTURE "Guardar"     WIDTH 30  HEIGHT 30 ACTION PInterfaceListaDePropiedades_ItemsGridSave() TOOLTIP PSayText({'Actualiza el Item Seleccionado',"Refresh selected item"})
   @ mNumLine+=   0,  72 BUTTONEX   Btn_Borrar   PICTURE "Borrar"      WIDTH 30  HEIGHT 30 ACTION PInterfaceListaDePropiedades_ItemsGridDel()  TOOLTIP PSayText({'Borra el Item Seleccionado'    ,"Delete selected item"})
   @ mNumLine+=   0, 233 BUTTONEX   Btn_Ok       CAPTION 'ok'          WIDTH 30  HEIGHT 30 ACTION PInterfaceListaDePropiedades_ItemsOk()       TOOLTIP PSayText({'Agregar a Propiedades'         ,"Add to propertys"})

END WINDOW
W_ITEMS.CENTER
W_ITEMS.ACTIVATE
RETURN(mItemRetur)
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_Undo()
LOCAL mNumLine

DEFINE WINDOW W_ITEMS;
       AT 186,710;
       WIDTH 380;
       HEIGHT 394;
       TITLE 'UnDo ';
       CHILD ;
       ON INIT PInterfaceListaDePropiedades_UndoRefresh()

   ON KEY ESCAPE ACTION W_ITEMS.RELEASE

   mNumLine:= 0

   @ mNumLine+=  10,  10 GRID       Grd_Items   WIDTH 350  HEIGHT 262  HEADERS {'No.',PSayText({'Tipo','Type'}),PSayText({'Nombre','Name'}),PSayText({'Accion','Action'})}  WIDTHS {40,100,100,100}
   @ mNumLine+= 276,  10 BUTTONEX   Btn_UnDo    CAPTION 'UD'          WIDTH 30  HEIGHT 30 ACTION PObjeto_UnDoRestar()                       TOOLTIP PSayText({'Agregar a Propiedades','Add to propertys'})
   @ mNumLine      , 330 BUTTONEX   Btn_Ok      CAPTION 'ok'          WIDTH 30  HEIGHT 30 ACTION PInterfaceListaDePropiedades_UndoRefresh() TOOLTIP PSayText({'Agregar a Propiedades','Add to propertys'})

END WINDOW
W_ITEMS.CENTER
W_ITEMS.ACTIVATE
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_UndoRefresh()
LOCAL mCont
W_ITEMS.Grd_Items.DeleteAllItems
FOR mCont:= 1 TO LEN(aUnDo)
  W_ITEMS.Grd_Items.AddItem({ALLTRIM(STR(mCont)),aUnDo[mCont,1],aUnDo[mCont,2],aUnDo[mCont,4]})
NEXT
W_ITEMS.TITLE:= 'UnDo '
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ItemsGridChange()
LOCAL mValue
LOCAL aItemVal
mValue:= W_ITEMS.Grd_Items.VALUE
aItemVal:= W_ITEMS.Grd_Items.Cell( mValue , 1 )
W_ITEMS.Gbx_Item.value:= PADR(aItemVal,200)
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ItemsGridAdd()
LOCAL mAddItem:= {}
IF !EMPTY(W_ITEMS.Gbx_Item.VALUE)
  AADD(mAddItem,W_ITEMS.Gbx_Item.VALUE)
  W_ITEMS.Grd_Items.AddItem(mAddItem)
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ItemsGridSave()
LOCAL mValue
mValue:= W_ITEMS.Grd_Items.VALUE
IF !EMPTY(W_ITEMS.Gbx_Item.VALUE)
  W_ITEMS.Grd_Items.Cell( mValue, 1 ):= W_ITEMS.Gbx_Item.VALUE
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ItemsGridDel()
LOCAL mValue
mValue:= W_ITEMS.Grd_Items.VALUE
W_ITEMS.Grd_Items.DeleteItem(mValue)
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ItemsOk()
LOCAL mTotItem
LOCAL mCont
mTotItem:= W_ITEMS.Grd_Items.ItemCount
IF mTotItem = 0
  msgstop(PSayText({"Debe de Agregar por lo menos un Item","You must add at least one item"}))
  RETURN
ENDIF
mItemRetur:= '{"'
FOR mCont:= 1 TO mTotItem
   mItemRetur+= ALLTRIM(W_ITEMS.Grd_Items.Cell( mCont , 1 ) )+'","'
NEXT
mItemRetur:= SUBSTR(mItemRetur,1,LEN(mItemRetur)-2)+'}'
W_ITEMS.RELEASE
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PInterfaceListaDePropiedades_Imagen(mNomImg)
LOCAL  aImageList,;
       aGrIdItems,;
       mNumLine
PRIVATE mRetNom:= mNomImg

aImageList:= {"ACEPTAR16"       ,;
              "ANIO16"          ,; 
              "ANULAR16"        ,;
              "BUSCAR16"        ,;
              "CALC16"          ,;
              "CANCELAR16"      ,;
              "CARPETA16"       ,;
              "CARPETABUSCAR16" ,;
              "CONECTAR16"      ,;
              "CONECTADO16"     ,;
              "CONSULTA16"      ,;
              "CONTA16"         ,;
              "CONTA216"        ,;
              "DESCONECTADO16"  ,;
              "DESGLOSE16"      ,;
              "DESGLOSE216"     ,;
              "DESHACER16"      ,;
              "EDITAR16"        ,;
              "ELIMINAR16"      ,;
              "GAS16"           ,;
              "GENERAR16"       ,;
              "GUARDAR16"       ,;
              "GRP016"          ,;
              "GRP116"          ,;
              "LISTA16"         ,;
              "LOCK16"          ,;
              "MASCARA16"       ,;
              "MES16"           ,;
              "MESDOWN16"       ,;
              "MESUP16"         ,;
              "MONEDA16"        ,;
              "MULTIPLE16"      ,;
              "NUEVO16"         ,;
              "NO16"            ,;
              "OTROS16"         ,;
              "PRINT16"         ,;
              "RAIZ16"          ,;
              "RESTA16"         ,;
              "RETORNAR16"      ,;
              "SI16"            ,;
              "SUMA16"          ,;
              "TITULO16"        ,;
              "UNLOCK16"        ,;
              "UP16"            ,;
              "VACIO16"         ,;
              "DOWN16"          ,;
              "LEFT16"          ,;
              "RIGHT16"         }

aGrIdItems :={{00,"ACEPTAR16"       },;
              {01,"ANIO16"          },; 
              {02,"ANULAR16"        },;
              {03,"BUSCAR16"        },;
              {04,"CALC16"          },;
              {05,"CANCELAR16"      },;
              {06,"CARPETA16"       },;
              {07,"CARPETABUSCAR16" },;
              {08,"CONECTAR16"      },;
              {09,"CONECTADO16"     },;
              {00,"CONSULTA16"      },;
              {11,"CONTA16"         },;
              {12,"CONTA216"        },;
              {13,"DESCONECTADO16"  },;
              {14,"DESGLOSE16"      },;
              {15,"DESGLOSE216"     },;
              {16,"DESHACER16"      },;
              {17,"EDITAR16"        },;
              {18,"ELIMINAR16"      },;
              {19,"GAS16"           },;
              {20,"GENERAR16"       },;
              {21,"GUARDAR16"       },;
              {22,"GRP016"          },;
              {23,"GRP116"          },;
              {24,"LISTA16"         },;
              {25,"LOCK16"          },;
              {26,"MASCARA16"       },;
              {27,"MES16"           },;
              {28,"MESDOWN16"       },;
              {29,"MESUP16"         },;
              {30,"MONEDA16"        },;
              {31,"MULTIPLE16"      },;
              {32,"NUEVO16"         },;
              {33,"NO16"            },;
              {34,"OTROS16"         },;
              {35,"PRINT16"         },;
              {36,"RAIZ16"          },;
              {37,"RESTA16"         },;
              {38,"RETORNAR16"      },;
              {39,"SI16"            },;
              {40,"SUMA16"          },;
              {41,"TITULO16"        },;
              {42,"UNLOCK16"        },;
              {43,"UP16"            },;
              {44,"VACIO16"         },;
              {45,"DOWN16"          },;
              {46,"LEFT16"          },;
              {47,"RIGHT16"         }}
              
DEFINE WINDOW W_iMAGENES;
       AT 186,470;
       WIDTH 298;
       HEIGHT 428;
       TITLE PSayText({'Imagenes','Image'});
       MODAL

   ON KEY ESCAPE ACTION W_iMAGENES.RELEASE

   mNumLine:= 0

   @ mNumLine+=  11,   9 GRID       Gri_Imagen      WIDTH 262  HEIGHT 331  HEADERS {"","Nombre"}  WIDTHS {20,200}  ITEMS aGrIdItems VALUE 1 IMAGE aImageList ON DBLCLICK PInterfaceListaDePropiedades_ImagenOk(2)
   @ mNumLine+= 337,   9 BUTTONEX   Btn_Vacio      CAPTION PSayText({'Vacio'   ,'Empty' })                       WIDTH 72  HEIGHT 30  ACTION PInterfaceListaDePropiedades_ImagenOk(1)  TOOLTIP PSayText({'Deja el Objeto sin Imagen','Object without Image'})
   @ mNumLine      ,  86 BUTTONEX   Btn_Cancelar   CAPTION PSayText({'Cancelar','Cancel'})  PICTURE "CANCELAR16" WIDTH 90  HEIGHT 30  ACTION W_iMAGENES.RELEASE
   @ mNumLine      , 181 BUTTONEX   Btn_Ok         CAPTION PSayText({'Aceptar' ,'Accept'})  PICTURE "ACEPTAR16"  WIDTH 90  HEIGHT 30  ACTION PInterfaceListaDePropiedades_ImagenOk(2)  TOOLTIP PSayText({'Aceptar la Imagen Seleccionada','Accept selected image'})

END WINDOW
W_iMAGENES.Gri_Imagen.Value:= aScan(aImageList,mNomImg)
W_iMAGENES.CENTER
W_iMAGENES.ACTIVATE
RETURN ( mRetNom )
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceListaDePropiedades_ImagenOk(mAccion)
LOCAL mValue
IF mAccion = 1
   mRetNom:= GetFile({{PSayText({'Archivo de Imagenes','Image File'}),'*.bmp;*.jpg;*.png'}, {'All File','*.*'}}, PSayText({'Archivo a Trabaja','File to work'}), GetCurrentFolder(), .F., .T.)
ELSE
   mValue:= W_iMAGENES.Gri_Imagen.VALUE
   mRetNom:= W_iMAGENES.Gri_Imagen.Cell( mValue, 2 )
ENDIF
W_iMAGENES.Release
RETURN
*--------------------------------------------------------------------------------------------
// *************** Funcionesd de objetos
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Add(cTipoDeObjeto,cNombreDelObjeto,aPropiedadesDelObjeto,mAddUnDo)
// Agrega un Control al Listado
LOCAL mNumeroDelControl
DEFAULT mAddUnDo:= .T.

AADD(aControles  ,{cTipoDeObjeto,cNombreDelObjeto,aPropiedadesDelObjeto})
mNumeroDelControl:= LEN(aControles)
// Crear el Control en el Formulario
PObjeto_Crear(cTipoDeObjeto,aPropiedadesDelObjeto)
// Actualizar en la ventana de Controles
WControles.Cbx_Controles.AddItem(cNombreDelObjeto)
WControles.Cbx_Controles.value:= mNumeroDelControl
IF mAddUnDo
  PObjeto_UnDoAdd(mNumeroDelControl,"BORRAR")
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PObjeto_Properties(mTipoControl,mNameCtrl,aMousePos)
// Define las Prepiedades de Un Control
LOCAL aPropiedades
aPropiedades:= {}
DO CASE
CASE mTipoControl= "TREE"
    aPropiedades:={{"ROW"       ,aMousePos[1] ,1,"V"},;
                   {"COL"       ,aMousePos[2] ,2,"V"},;
                   {"NAME"      ,mNameCtrl    ,3,"V"},;
                   {"WIDTH"     ,200          ,4,"V"},;
                   {"HEIGHT"    ,300          ,5,"V"},;
                   {"ITEMHEIGHT",20           ,5,"V"}}

CASE mTipoControl= "TIMER"
    aPropiedades:={{"ROW"       ,aMousePos[1] ,1,"V"},;
                   {"COL"       ,aMousePos[2] ,2,"V"},;
                   {"NAME"      ,mNameCtrl    ,3,"V"},;
                   {"INTERVAL"  ,100          ,4,"V"},;
                   {"ACTION"    ,"NIL"        ,5,"V"}}

CASE mTipoControl = "FRAME"
    aPropiedades:= {{"ROW"     ,aMousePos[1] ,1,"V"},;
                    {"COL"     ,aMousePos[2] ,2,"V"},;
                    {"NAME"    ,mNameCtrl,3,"V"},;
                    {"CAPTION" ,mNameCtrl,4,"T"},;
                    {"WIDTH"   ,150      ,5,"V"},;
                    {"HEIGHT"  ,50       ,6,"V"}}

CASE mTipoControl= "LABEL"
    aPropiedades:= {{"ROW"       ,aMousePos[1]  ,1,"V"},;
                    {"COL"       ,aMousePos[2]  ,2,"V"},;
                    {"NAME"      ,mNameCtrl ,3,"V"},;
                    {"VALUE"     ,mNameCtrl ,4,"T"},;
                    {"WIDTH"     ,100       ,5,"V"},;
                    {"HEIGHT"    ,15        ,6,"V"},;
                    {"BORDER"    ,.F.       ,7,"C"},;
                    {"CLIENTEDGE",.F.       ,8,"C"},;
                    {"RIGHTALIGN",.F.       ,9,"C"},;
                    {"CENTERALIGN",.F.     ,10,"C"}}

CASE mTipoControl= "GETBOX"
    aPropiedades:={{"ROW"      ,aMousePos[1]   ,1,"V"},;
                   {"COL"      ,aMousePos[2]   ,2,"V"},;
                   {"NAME"     ,mNameCtrl      ,3,"V"},;
                   {"VALUE"    ,mNameCtrl      ,4,"T"},;
                   {"WIDTH"    ,100            ,5,"V"},;
                   {"HEIGHT"   ,20             ,6,"V"},;
                   {"BACKCOLOR","Sys_BackColor",7,"V"},;
                   {"FONTCOLOR","Sys_FontColor",8,"V"}}

CASE mTipoControl= "BUTTONEX"

    IF mMasButtos
         aPropiedades:={{"ROW"    ,aMousePos[1] ,1,"V"},;
                        {"COL"    ,aMousePos[2] ,2,"V"},;
                        {"NAME"   ,mNameCtrl    ,3,"V"},;
                        {"CAPTION",mMasBCaption ,4,"T"},;
                        {"PICTURE",mMasBPicture ,5,"T"},;
                        {"WIDTH"  ,100          ,6,"V"},;
                        {"HEIGHT" ,25           ,7,"V"},;
                        {"ACTION" ,"NIL"        ,8,"V"},;
                        {"TOOLTIP" ,mMasBToolTip,9,"T"}}
    ELSE
         aPropiedades:={{"ROW"    ,aMousePos[1] ,1,"V"},;
                        {"COL"    ,aMousePos[2] ,2,"V"},;
                        {"NAME"   ,mNameCtrl    ,3,"V"},;
                        {"CAPTION",mNameCtrl    ,4,"T"},;
                        {"PICTURE",""           ,5,"T"},;
                        {"WIDTH"  ,100          ,6,"V"},;
                        {"HEIGHT" ,25           ,7,"V"},;
                        {"ACTION" ,"NIL"        ,8,"V"},;
                        {"TOOLTIP" ,"ToolTip"   ,9,"T"}}
   ENDIF

CASE mTipoControl= "CHECKBOX"
    aPropiedades:={{"ROW"    ,aMousePos[1]  ,1,"V"},;
                   {"COL"    ,aMousePos[2]  ,2,"V"},;
                   {"NAME"   ,mNameCtrl     ,3,"V"},;
                   {"CAPTION",mNameCtrl     ,4,"T"},;
                   {"WIDTH"  ,150           ,5,"V"},;
                   {"HEIGHT" ,25            ,6,"V"}}
    
CASE mTipoControl= "RADIOGROUP"
    aPropiedades:={{"ROW"             ,aMousePos[1] ,1,"V"},;
                   {"COL"             ,aMousePos[2] ,2,"V"},;
                   {"NAME"            ,mNameCtrl,3,"V"},;
                   {"OPTIONS",'{"Option1","Option2"}',4,"V"},;
                   {"VALUE"           ,1        ,5,"V"},;
                   {"WIDTH"           ,150      ,6,"V"},;
                   {"SPACING"         ,35       ,7,"V"},;
                   {"HORIZONTAL"      ,.F.      ,8,"C"}}

CASE mTipoControl= "COMBOBOX"
    aPropiedades:= {{"ROW"      ,aMousePos[1]   ,1,"V"},;
                    {"COL"      ,aMousePos[2]   ,2,"V"},;
                    {"NAME"     ,mNameCtrl  ,3,"V"},;
                    {"ITEMS"    ,'{"'+mNameCtrl+'","Item2  "}',4,"V"},;
                    {"VALUE"    ,1          ,5,"V"},;
                    {"WIDTH"    ,150        ,6,"V"},;
                    {"HEIGHT"   ,100        ,7,"V"},;
                    {"LISTWIDTH",150        ,8,"V"}}

CASE mTipoControl= "SPINNER"
   aPropiedades:= {{"ROW"     ,aMousePos[1]  ,1,"V"},;
                   {"COL"     ,aMousePos[2]  ,2,"V"},;
                   {"NAME"    ,mNameCtrl ,3,"V"},;
                   {"RANGEMIN",1         ,4,"V"},;
                   {"RANGEMAX",100       ,5,"V"},;
                   {"VALUE"   ,1         ,6,"V"},;
                   {"WIDTH"   ,100       ,7,"V"},;
                   {"HEIGHT"  ,25        ,8,"V"}} 

CASE mTipoControl= "TBROWSE"
    aPropiedades:={{"ROW"    ,aMousePos[1] ,1,"V"},;
                   {"COL"    ,aMousePos[2] ,2,"V"},;
                   {"NAME"   ,mNameCtrl    ,3,"V"},;
                   {"WIDTH"  ,200          ,4,"V"},;
                   {"HEIGHT" ,150          ,5,"V"}}

CASE mTipoControl= "GRID"
    aPropiedades:={{"ROW"    ,aMousePos[1]           ,1,"V"},;
                   {"COL"    ,aMousePos[2]           ,2,"V"},;
                   {"NAME"   ,mNameCtrl              ,3,"V"},;
                   {"WIDTH"  ,200                    ,4,"V"},;
                   {"HEIGHT" ,150                    ,5,"V"},;
                   {"HEADERS",'{"Heder1","Heder2"}'  ,6,"V"},;
                   {"WIDTHS" ,"{100,100}"            ,7,"V"},;
                   {"ITEMS"  ,'{{"Item11","Item12"},{"Item21","Item21"}}',8,"V"}}

CASE mTipoControl= "PROGRESSBAR"
   aPropiedades:= {{"ROW"     ,aMousePos[1]  ,1,"V"},;
                   {"COL"     ,aMousePos[2]  ,2,"V"},;
                   {"NAME"    ,mNameCtrl ,3,"V"},;
                   {"RANGEMIN",1         ,4,"V"},;
                   {"RANGEMAX",100       ,5,"V"},;
                   {"VALUE"   ,1         ,6,"V"},;
                   {"WIDTH"   ,150       ,7,"V"},;
                   {"HEIGHT"  ,20        ,8,"V"},; 
                   {"VERTICAL",.F.       ,9,"C"}} 

CASE mTipoControl= "LISTBOX"
    aPropiedades:= {{"ROW"      ,aMousePos[1]   ,1,"V"},;
                    {"COL"      ,aMousePos[2]   ,2,"V"},;
                    {"NAME"     ,mNameCtrl  ,3,"V"},;
                    {"ITEMS"    ,'{"'+mNameCtrl+'","Item2"}',4,"V"},;
                    {"VALUE"    ,1          ,5,"V"},;
                    {"WIDTH"    ,150        ,6,"V"},;
                    {"HEIGHT"   ,100        ,7,"V"}}

CASE mTipoControl= "EDITBOX"
    aPropiedades:={{"ROW"      ,aMousePos[1]       ,1,"V"},;
                   {"COL"      ,aMousePos[2]       ,2,"V"},;
                   {"NAME"     ,mNameCtrl      ,3,"V"},;
                   {"VALUE"    ,PSayText({"Activar con boton Derecho","Rigth Click to active"}),4,"T"},;
                   {"WIDTH"    ,150            ,5,"V"},;
                   {"HEIGHT"   ,150            ,6,"V"}}

CASE mTipoControl= "IMAGE"
    aPropiedades:= {{"ROW"     ,aMousePos[1]    ,1,"V"},;
                    {"COL"     ,aMousePos[2]    ,2,"V"},;
                    {"NAME"    ,mNameCtrl   ,3,"V"},;
                    {"PICTURE" ,"demoimage",4,"T"},;
                    {"WIDTH"   ,100         ,5,"V"},;
                    {"HEIGHT"  ,100         ,6,"V"}}

CASE mTipoControl= "CHECKBUTTON"
    aPropiedades:= {{"ROW"     ,aMousePos[1]    ,1,"V"},;
                    {"COL"     ,aMousePos[2]    ,2,"V"},;
                    {"NAME"    ,mNameCtrl       ,3,"V"},;
                    {"CAPTION" ,"Ckb"           ,4,"T"},;
                    {"PICTURE" ,""              ,5,"T"},;
                    {"WIDTH"   ,30              ,6,"V"},;
                    {"HEIGHT"  ,30              ,7,"V"},;
                    {"VALUE"   ,.F.             ,8,"V"}}

CASE mTipoControl= "DATEPICKER"
    aPropiedades:={{"ROW"      ,aMousePos[1]    ,1,"V"},;
                   {"COL"      ,aMousePos[2]    ,2,"V"},;
                   {"NAME"     ,mNameCtrl       ,3,"V"},;
                   {"VALUE"    ,DATE()          ,4,"V"},;
                   {"WIDTH"    ,100             ,5,"V"},;
                   {"HEIGHT"   ,20              ,6,"V"}}

CASE mTipoControl= "HYPERLINK"
    aPropiedades:={{"ROW"      ,aMousePos[1]    ,1,"V"},;
                   {"COL"      ,aMousePos[2]    ,2,"V"},;
                   {"NAME"     ,mNameCtrl       ,3,"V"},;
                   {"VALUE"    ,"http//www.programer.com" ,4,"T"},;
                   {"ADDRESS"  ,"http//www.programer.com" ,4,"T"},;
                   {"WIDTH"    ,200             ,5,"V"},;
                   {"HEIGHT"   ,20              ,6,"V"}}

ENDCASE 
RETURN(aPropiedades)
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Crear(mControl,aValores)
// Define los Controles en el Formulario
LOCAL mCont, mDefine_ITEMHEIGHT := 20
PRIVATE mMacro

IF aValores = NIL .OR. ;
  VALTYPE(aValores) # "A"
  RETURN
ENDIF

FOR mCont:= 1 TO LEN(aValores)
  mMacro:= "mDefine_"+aValores[mCont,1]
  &mMacro:= aValores[mCont,2]
NEXT

DO CASE
     CASE mControl = "TREE"
         DEFINE TREE &mDefine_NAME PARENT WForma ;
                AT mDefine_ROW, mDefine_COL      ;
                WIDTH mDefine_WIDTH              ;
                HEIGHT mDefine_HEIGHT            ;
                VALUE 1                          ;
                ITEMHEIGHT mDefine_ITEMHEIGHT    ;
                ON CHANGE   PObjeto_Selecionar() ;
                ON DBLCLICK PObjeto_Selecionar()
                
                NODE 'Item 1'
                   TREEITEM 'Item 1.1'
                   TREEITEM 'Item 1.2' ID 999
                   TREEITEM 'Item 1.3'
                END NODE
                
                NODE 'Item 2'
                
                   TREEITEM 'Item 2.1'
                
                   NODE 'Item 2.2'
                      TREEITEM 'Item 2.2.1'
                      TREEITEM 'Item 2.2.2'
                      TREEITEM 'Item 2.2.3'
                      TREEITEM 'Item 2.2.4'
                      TREEITEM 'Item 2.2.5'
                      TREEITEM 'Item 2.2.6'
                      TREEITEM 'Item 2.2.7'
                      TREEITEM 'Item 2.2.8'
                   END NODE
                
                   TREEITEM 'Item 2.3'
                
                END NODE
         END TREE

     CASE mControl = "TIMER"
         DEFINE BUTTONEX &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                PICTURE "timer"
                WIDTH 35
                HEIGHT 35
                ACTION PObjeto_Selecionar()
         END BUTTONEX
         
     CASE mControl = "FRAME"
         DEFINE FRAME &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                CAPTION mDefine_CAPTION
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                TRANSPARENT .T.
         END FRAME

     CASE mControl= "LABEL"
         DEFINE LABEL &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                VALUE mDefine_VALUE
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                ONCLICK PObjeto_Selecionar()
                BORDER .T.
         END LABEL

     CASE mControl= "GETBOX"
         DEFINE GETBOX &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                VALUE mDefine_NAME
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                ACTION PObjeto_Selecionar()
         END GETBOX

     CASE mControl= "BUTTONEX"
         DEFINE BUTTONEX &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                CAPTION mDefine_CAPTION
                PICTURE mDefine_PICTURE
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                ACTION PObjeto_Selecionar()
                TOOLTIP mDefine_TOOLTIP
         END BUTTONEX

     CASE mControl= "CHECKBOX"
         DEFINE CHECKBOX &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                CAPTION mDefine_NAME
                ONCHANGE   PObjeto_Selecionar()
         END CHECKBOX

     CASE mControl= "RADIOGROUP"
         DEFINE RADIOGROUP &mDefine_NAME
            PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                OPTIONS &mDefine_OPTIONS
                VALUE mDefine_VALUE
                WIDTH mDefine_WIDTH
                SPACING mDefine_SPACING
                HORIZONTAL mDefine_HORIZONTAL
                ONCHANGE PObjeto_Selecionar()
         END RADIOGROUP

     CASE mControl= "COMBOBOX"
         DEFINE COMBOBOX &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                ITEMS &mDefine_ITEMS
                VALUE mDefine_VALUE
                LISTWIDTH mDefine_LISTWIDTH   //ONGOTFOCUS PObjeto_Localizar(this.NAME)
                ONCHANGE PObjeto_Selecionar()
         END COMBOBOX

    CASE mControl= "SPINNER"
        DEFINE SPINNER &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                RANGEMIN mDefine_RANGEMIN
                RANGEMAX mDefine_RANGEMAX   //ONGOTFOCUS PObjeto_Localizar(this.NAME)
                ONCHANGE PObjeto_Selecionar()
        END SPINNER 

    CASE mControl= "TBROWSE"

        DEFINE GRID &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                HEADERS {"Heder1","Heder2"}
                WIDTHS {100,100}
                ITEMS {{"ItemAA","ItemAB"},{"ItemBA","ItemBB"}}
                ONHEADCLICK { {||PObjeto_Selecionar()} ,{||PObjeto_Selecionar()} }
        END GRID

    CASE mControl= "GRID"

        DEFINE GRID &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                HEADERS {"Heder1","Heder2"}
                WIDTHS {100,100}
                ITEMS {{"ItemAA","ItemAB"},{"ItemBA","ItemBB"}}
                ONHEADCLICK { {||PObjeto_Selecionar()} ,{||PObjeto_Selecionar()} }
        END GRID

    CASE mControl= "PROGRESSBAR"
        DEFINE PROGRESSBAR &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                RANGEMIN mDefine_RANGEMIN
                RANGEMAX mDefine_RANGEMAX
                VALUE mDefine_VALUE
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
        END PROGRESSBAR 

    CASE mControl= "LISTBOX"
         DEFINE LISTBOX &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                ITEMS &mDefine_ITEMS
                VALUE mDefine_VALUE
                ONCHANGE PObjeto_Selecionar()
         END LISTBOX

     CASE mControl= "EDITBOX"
         DEFINE EDITBOX &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                VALUE mDefine_VALUE
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT    //   ONGOTFOCUS PObjeto_Localizar(this.NAME)
                ONCHANGE PObjeto_Selecionar()
         END EDITBOX

     CASE mControl= "IMAGE"
            DEFINE IMAGE &mDefine_NAME 
                PARENT WForma  
                COL mDefine_COL
                ROW mDefine_ROW
                PICTURE mDefine_PICTURE
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT
                STRETCH .T.
                ACTION PObjeto_Selecionar()
            END IMAGE

     CASE mControl= "CHECKBUTTON"
         IF !EMPTY(mDefine_CAPTION)
              @ mDefine_ROW,mDefine_COL CHECKBUTTON &mDefine_NAME  PARENT WForma  ;
                                         CAPTION mDefine_CAPTION ; 
                                         WIDTH mDefine_WIDTH     ;
                                         HEIGHT mDefine_HEIGHT   ;
                                         VALUE mDefine_VALUE     ;
                                         ON CHANGE PObjeto_Selecionar()
        ELSE
             @ mDefine_ROW,mDefine_COL CHECKBUTTON &mDefine_NAME  PARENT WForma  ;
                                PICTURE mDefine_PICTURE ; 
                                WIDTH mDefine_WIDTH     ;
                                HEIGHT mDefine_HEIGHT   ;
                                VALUE mDefine_VALUE     ;
                                ON CHANGE PObjeto_Selecionar()
        ENDIF

     CASE mControl= "DATEPICKER"
         DEFINE DATEPICKER &mDefine_NAME
                PARENT WForma
                COL mDefine_COL
                ROW mDefine_ROW
                VALUE mDefine_VALUE
                WIDTH mDefine_WIDTH
                HEIGHT mDefine_HEIGHT  // ONGOTFOCUS PObjeto_Localizar(this.NAME)
                ONCHANGE PObjeto_Selecionar()
         END DATEPICKER

     CASE mControl= "HYPERLINK"
     
      @ mDefine_ROW,mDefine_COL  HYPERLINK &mDefine_NAME PARENT WForma ;
         VALUE mDefine_VALUE ;
         ADDRESS "proc:\\PObjeto_Selecionar()" ;
         WIDTH mDefine_WIDTH ;
         HEIGHT mDefine_HEIGHT ;
         HANDCURSOR

     ENDCASE
     PObjeto_CntxMenu()

     mMasButtos:= .F.
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_CntxMenu()
     DEFINE CONTEXT MENU CONTROL &mDefine_NAME OF WForma
            MENUITEM PSayText({"Mover" ,"Move" })      ACTION PObjeto_Activar("MOVER"  ,"Btn_Move")  IMAGE "Move"
            MENUITEM PSayText({"Tamaño","Size" })      ACTION PObjeto_Activar("TAMANIO","Btn_SIZE")  IMAGE "size" 
            MENUITEM PSayText({"Borrar","Erase"})      ACTION PObjeto_Borrar()                       IMAGE "Borrar"
     END MENU
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Borrar(mAddUnDO)
LOCAL mNumItem, mNomItem
LOCAL aInfoTemp, mCont
// Borra un Control
DEFAULT mAddUnDo:= .T.
PEnabledControl()
PEnabledActions()
mNumItem:= WControles.Cbx_Controles.value
IF mNumItem = 1
  RETURN
ENDIF

mNomItem:= WControles.Cbx_Controles.ITEM(mNumItem)
IF mAddUnDo
  PObjeto_UnDoAdd(mNumItem,"AGREGAR")
ENDIF

DOMETHOD("WForma",mNomItem,"RELEASE")
ADEL(aControles,mNumItem)
WControles.Cbx_Controles.DeleteItem(mNumItem)

aInfoTemp:= ACLONE(aControles)
aControles:= {}
FOR mCont:= 1 TO LEN(aInfoTemp)
    IF aInfoTemp[mCont] = NIL
       LOOP 
    ENDIF
    AADD(aControles,aInfoTemp[mCont])
NEXT

WControles.Cbx_Controles.value:= 1
PInterfaceListaDeObjetos_Cambio()
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_UnDoRestar()
// Busco la Ultima Posicion del Bector y la Ejecto
LOCAL I, J, mNumItem
LOCAL aVecTemp
I:= LEN(aUnDo)
IF I = 0
  RETURN
ENDIF

mNumItem:= 0
FOR J:= 1 TO LEN(aControles)
   IF aControles[J,2] = aUnDo[I,2]
     mNumItem:= J
     EXIT
   ENDIF
NEXT

DO CASE
CASE aUnDo[I,4] = "NADA"
  //No Hace Nada
CASE aUnDo[I,4] = "ACCION"

   IF mNumItem > 0
       FOR J:=1 TO LEN(aControles[mNumItem,3])
          aControles[mNumItem,3,J,2]:= aUnDo[I,3,J,2]
          // Revisar que no se cuele un Metodo o Propiedad incambiable
          IF aUnDo[I,3,J,1]="ACTION"
            LOOP
          ENDIF
          SETPROPERTY("WForma",aUnDo[I,2],aUnDo[I,3,J,1],aUnDo[I,3,J,2])
       NEXT
       WControles.Cbx_Controles.VALUE:= mNumItem 
   ENDIF
   
CASE aUnDo[I,4] = "BORRAR"
  IF mNumItem > 0
     WControles.Cbx_Controles.VALUE:= mNumItem
     PObjeto_Borrar(.F.)
     aUnDo[I,4]:= "NADA"
  ENDIF

CASE aUnDo[I,4] = "AGREGAR"
  IF mNumItem = 0
     PObjeto_Add(aUnDo[I,1],aUnDo[I,2],aUnDo[I,3],.F.)
     aUnDo[I,4]:= "NADA"
  ENDIF
ENDCASE

//Borrar la Ultima Posicion del Vector
ADEL(aUnDo,I)
aVecTemp:= ACLONE(aUnDo)
aUnDo:= {}
FOR I:= 1 TO LEN(aVecTemp)
  IF aVecTemp[I] = NIL
    LOOP
  ENDIF
  AADD(aUnDo,aVecTemp[I])
NEXT
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_UnDoAdd(mNumItem,mAccion)
// Guarda el Ultimo Cambio
LOCAL mValTemp1
LOCAL mValTemp2
LOCAL mValTemp3
LOCAL mValTemp4
LOCAL aAddUnDo,aPropiedades,mCont
aAddUnDo    := {}
aPropiedades:= {}

mValTemp1= aControles[mNumItem,1]
AADD(aAddUnDo,mValTemp1)

mValTemp1= aControles[mNumItem,2]
AADD(aAddUnDo,mValTemp1)

// Se pasa todo a Variables locales para que sea un Vector Nuevo
// de lo contrario siempre apunta al vector origen
FOR mCont:= 1 TO LEN(aControles[mNumItem,3])
  mValTemp1:= aControles[mNumItem,3,mCont,1]
  mValTemp2:= aControles[mNumItem,3,mCont,2]
  mValTemp3:= aControles[mNumItem,3,mCont,3]
  mValTemp4:= aControles[mNumItem,3,mCont,4]
   AADD(aPropiedades,{mValTemp1,mValTemp2,mValTemp3,mValTemp4})
NEXT
AADD(aAddUnDo,aPropiedades)
AADD(aAddUnDo,mAccion)
AADD(aAddUnDo,mNumItem)

AADD(aUnDo,aAddUnDo)

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Activar(mAccion,mButton)
// Activa el objeto de la lista
LOCAL mcNombre, mNumControl
PObjeto_Acciones(mAccion,mButton)
mNumControl:= WControles.Cbx_Controles.value
mcNombre:= aControles[mNumControl,2]
PObjeto_Selecionar(mcNombre)
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Selecionar(mNombreDelControl)
// Selecciona el control de la lista
LOCAL mCtrlName
DEFAULT mNombreDelControl:= this.Name
mCtrlName:= mNombreDelControl
PObjeto_Ubicar(mCtrlName)
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Ubicar(mCtrlName)
//Ubica el Control y le da accion
LOCAL mNumObject
mNumObject:= PObjeto_Localizar(mCtrlName)
IF mNumObject = 0
  RETURN
ENDIF

PObjeto_UnDoAdd(mNumObject,"ACCION")
DO CASE
CASE mTipoAccion = "MOVER"
   PInterface_Object_Mover()
CASE mTipoAccion = "TAMANIO"
   PInterface_Object_Tamanio()
ENDCASE
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PObjeto_Localizar(mCtrlName)
// Localiza  un control en la lista
LOCAL mLocalizado, mCont

mLocalizado:= .F.
FOR mCont:= 1 TO LEN(aControles)
  IF aControles[mCont,2] = mCtrlName
    mLocalizado:= .T.
    EXIT
  ENDIF
NEXT

IF !mLocalizado
  RETURN(0)
ENDIF
IF !_IsControlDefined (mCtrlName,"WForma")
  msgbox(mCtrlName+PSayText({" Control no Definido!"," undefinded Control!"}))
  RETURN(0)
ENDIF

WControles.Cbx_Controles.value:= mCont
DOMETHOD("WForma",mCtrlName,"SetFocus")
RETURN(mCont)
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Copiar()
// Copia un Control
LOCAL mNumItem
LOCAL mCont
LOCAL aPropiedades:= {}
LOCAL mValTemp1,;
      mValTemp2,;
      mValTemp3,;
      mValTemp4

mNumItem:= WControles.Cbx_Controles.value
IF mNumItem = 1
  MSGBOX(PSayText({"No es Posible Copiar el Formulario","It's not possible to copy the form"}))
  RETURN
ENDIF
// Apagar los Botones
PObjeto_Acciones("SELECCION","Btn_Nada")  // Pone en Modo Seleccion

aClipBoard:={}
mValTemp1:= aControles[mNumItem,1]
AADD(aClipBoard,mValTemp1)

mValTemp1:= aControles[mNumItem,2]
AADD(aClipBoard,mValTemp1)
// Se pasa todo a Variables locales para que sea un Vector Nuevo
// de lo contrario siempre apunta al vector origen
FOR mCont:= 1 TO LEN(aControles[mNumItem,3])
  mValTemp1:= aControles[mNumItem,3,mCont,1]
  mValTemp2:= aControles[mNumItem,3,mCont,2]
  mValTemp3:= aControles[mNumItem,3,mCont,3]
  mValTemp4:= aControles[mNumItem,3,mCont,4]
   AADD(aPropiedades,{mValTemp1,mValTemp2,mValTemp3,mValTemp4})
NEXT
AADD(aClipBoard,aPropiedades)
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Pegar()
// Retorna un Vector Con Las Posiciones del Raton
LOCAL aMousePos
LOCAL mTControl
LOCAL mNameCtrl
LOCAL maPropiedades
LOCAL mCont
LOCAL mValTemp1,;
      mValTemp2,;
      mValTemp3,;
      mValTemp4
      
aMousePos:= FGetMousePos()

IF LEN(aClipBoard) = 0
   RETURN
ENDIF

mTControl:= aClipBoard[1]
mNameCtrl:= FObjeto_NexName(mTControl)
maPropiedades:= {}

FOR mCont:= 1 TO LEN(aClipBoard[3])
   mValTemp1:= aClipBoard[3,mCont,1]
   mValTemp2:= aClipBoard[3,mCont,2]
   mValTemp3:= aClipBoard[3,mCont,3]
   mValTemp4:= aClipBoard[3,mCont,4]
   AADD(maPropiedades,{mValTemp1,mValTemp2,mValTemp3,mValTemp4})
   IF maPropiedades[mCont,1]="ROW"
      maPropiedades[mCont,2]:= aMousePos[1]
   ENDIF
   IF maPropiedades[mCont,1]="NAME"
     maPropiedades[mCont,2]:= mNameCtrl
   ENDIF
   IF maPropiedades[mCont,1]="COL"
      maPropiedades[mCont,2]:= aMousePos[2]
   ENDIF
NEXT

// Agregar el Nuevo Control
PObjeto_Add(mTControl,mNameCtrl,maPropiedades)
PObjeto_UnDoAdd(LEN(aControles),"BORRAR")
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Acciones(mActionName,mButonNam)
// Selecciona una Accion
LOCAL mNumItem
IF mButonNam = NIL
  mButonNam:= this.Name
ENDIF
mNumItem:= WControles.Cbx_Controles.value

PObjeto_UnDoAdd(mNumItem,"ACCION")
PEnabledActions()
PEnabledControl()
mTipoAccion:= mActionName
// Activar controles de Movimiento
IF mTipoAccion = "TAMANIO" .OR. ;
   mTipoAccion = "MOVER"
   PEnabledDesplazar(.T.)
ENDIF

SETPROPERTY("xFormulario",mButonNam,"VALUE",.T.)
PObjeto_ChangeCursos()
DOMETHOD("WForma","SETFOCUS")
/*
  mTipoAccion:= "SELECCION"
  mTipoAccion:= "AGREGAR"
  mTipoAccion:= "TAMANIO"
  mTipoAccion:= "MOVER"
  mTipoAccion:= "PEGAR"*/
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Iman()
IF xFormulario.Btn_Iman.value
   mMoveIman:= .T.
ELSE
   mMoveIman:= .F.
ENDIF
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_ChangeCursos()
DO CASE
CASE mTipoAccion = "SELECCION"
  WForma.Cursor := GetWindowsFolder()+"\cursors\arrow_i.cur"
CASE mTipoAccion = "AGREGAR"
  WForma.Cursor := GetWindowsFolder()+"\cursors\cross_i.cur"
CASE mTipoAccion = "TAMANIO"
  WForma.Cursor := GetWindowsFolder()+"\cursors\size2_i.cur"
CASE mTipoAccion = "MOVER"
  WForma.Cursor := GetWindowsFolder()+"\cursors\move_i.cur"
CASE mTipoAccion = "PEGAR"
  WForma.Cursor := GetWindowsFolder()+"\cursors\pen_i.cur"
ENDCASE
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PObjeto_Tipo(mCtrlName,mButonNam)
// Selecciona una Accion
IF mButonNam = NIL
  mButonNam:= this.Name
ENDIF

// Desactivar Botones Activos
PEnabledControl()
PEnabledActions()

// Configurar 
xFormulario.Btn_ADD.VALUE:= .T.
mTipoAccion:= "AGREGAR"
mTipoControl:= mCtrlName
PObjeto_ChangeCursos()
SETPROPERTY("xFormulario",mButonNam,"VALUE",.T.)
DOMETHOD("WForma","SETFOCUS")
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PEnabledActions()
// Desactiva las Acciones
PEnabledDesplazar(.F.)
xFormulario.Btn_Nada.VALUE := .F.
xFormulario.Btn_ADD.VALUE  := .F.
xFormulario.Btn_SIZE.VALUE := .F.
xFormulario.Btn_Move.VALUE := .F.
xFormulario.Btn_PEGAR.VALUE:= .F.
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PEnabledControl()
// Inavilita los Controles Seleccionados.
xFormulario.Btn_Frame.VALUE    := .F.
xFormulario.Btn_Lebel.VALUE    := .F.
xFormulario.Btn_GetBox.VALUE   := .F.
xFormulario.Btn_BUTTONEX.VALUE := .F.
xFormulario.Btn_CHECKBOX.VALUE := .F.
xFormulario.Btn_Radio.VALUE    := .F.
xFormulario.Btn_Combo.VALUE    := .F.
xFormulario.Btn_Spliner.VALUE  := .F.
xFormulario.Btn_tbrows.VALUE   := .F.
xFormulario.Btn_Grid.VALUE     := .F.
xFormulario.Btn_Progres.VALUE  := .F.
xFormulario.Btn_ListBox.VALUE  := .F.
xFormulario.Btn_EditBox.VALUE  := .F.
xFormulario.Btn_Image.VALUE    := .F.
xFormulario.Btn_ChKButton.VALUE:= .F.
xFormulario.Btn_DatePic.VALUE  := .F.
xFormulario.Btn_hyperlink.VALUE:= .F.
xFormulario.Btn_Tree.VALUE     := .F.
xFormulario.Btn_Timer.VALUE    := .F.

mTipoControl:= "SELECCION"
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PEnabledDesplazar(mEnabled)
  IF _IsWindowDefined("WControles")
      WControles.Btn_Factor.Enabled:= mEnabled
      WControles.Btn_Up.Enabled    := mEnabled
      WControles.Btn_Mas.Enabled   := mEnabled
      WControles.Btn_Left.Enabled  := mEnabled
      WControles.Btn_Down.Enabled  := mEnabled
      WControles.Btn_Rigth.Enabled := mEnabled
      WControles.Btn_Menos.Enabled := mEnabled
  ENDIF
RETURN
*--------------------------------------------------------------------------------------------
// ********* FUNCIONES 
*--------------------------------------------------------------------------------------------
FUNCTION FObjeto_NexName(mControl)
// Sugiere un Nombre Para El Control
LOCAL mNexControl:= 1
LOCAL mNameCtrl
LOCAL mCont

FOR mCont:= 1 TO LEN(aControles)
  IF aControles[mCont,1] = mControl
    mNexControl++
  ENDIF
NEXT
mNameCtrl:= mControl+"_"+ALLTRIM(STR(mNexControl))

FOR mCont:= 1 TO LEN(aControles)
  IF UPPER(aControles[mCont,2]) = UPPER(mNameCtrl)
    mNexControl++
  ENDIF
NEXT

mNameCtrl:= mControl+"_"+ALLTRIM(STR(mNexControl))
RETURN(mNameCtrl)
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION FGetMousePos(mConIman)
// Retorna un Vector Con Las Posiciones del Raton
LOCAL aMPos,;
      mMouseRow,;
      mMouseCol,;
      mReciduo
      
DEFAULT mConIman:= .F.
     
mMouseRow := GetCursorPos()[ 1 ] - WForma.Row - nTitleBarHeight - nBorderWidth
mMouseCol := GetCursorPos()[ 2 ] - WForma.Col - nBorderWidth

IF mConIman .AND. mMoveIman 
  //Mover a cada 10
  mReciduo:= (mMouseRow/10)-INT(mMouseRow/10)
  IF mReciduo > 0
    mReciduo*= 10
    IF mReciduo < 5
      mMouseRow-= mReciduo
    ELSE
      mMouseRow+= (10-mReciduo)
    ENDIF
  ENDIF

  mReciduo:= (mMouseCol/10)-INT(mMouseCol/10)
  IF mReciduo > 0
    mReciduo*= 10
    IF mReciduo < 5
      mMouseCol-= mReciduo
    ELSE
      mMouseCol+= (10-mReciduo)
    ENDIF
  ENDIF
  
ENDIF
aMPos:= {INT(mMouseRow),INT(mMouseCol)}
RETURN(aMPos)
*--------------------------------------------------------------------------------------------
// *************** Funciones de Archivo
*--------------------------------------------------------------------------------------------
PROCEDURE PArchivo_Guardar(mGuardarComo)
LOCAL temptext:= ""
LOCAL mTemVal, cFile
LOCAL mCont1,mCont2

DEFAULT mGuardarComo:= .F.

temptext:= "{"
FOR mCont1:= 1 TO LEN(aControles)
  temptext+= "{'"+aControles[mCont1,1]+"','"+aControles[mCont1,2]+"',{"
  FOR mCont2:= 1 TO LEN(aControles[mCont1,3])
     temptext+= "{'"+aControles[mCont1,3,mCont2,1]+"',"
     mTemVal:= aControles[mCont1,3,mCont2,2]
     
     DO CASE
     CASE VALTYPE(mTemVal) = "N"
        temptext+= ALLTRIM(STR(mTemVal))+","
     CASE VALTYPE(mTemVal) = "L"
        temptext+= IF(mTemVal,'.T.','.F.')+","
     CASE VALTYPE(mTemVal) = "D"
        temptext+= "CTOD('"+DTOC(mTemVal)+"'),"
     OTHERWISE
        temptext+= "'"+mTemVal+"'," 
     ENDCASE

     temptext+= ALLTRIM(STR(aControles[mCont1,3,mCont2,3]))+","
     temptext+= "'"+aControles[mCont1,3,mCont2,4]+"'},"
  NEXT
  temptext:= SUBSTR(temptext,1,LEN(temptext)-1)
  temptext+= "}},"
  
NEXT
// Quitar las Comas
temptext:= SUBSTR(temptext,1,LEN(temptext)-1)
temptext+= "}"

IF FileName = "Nuevo" .OR. FileName = "New" .OR. mGuardarComo
    cFile := Putfile( { {PSayText({'Archivo de Formulario','Form File'}),'*.xfm'} , {'All Files','*.*'} }, PSayText({'Guardar Archivo','Save File'}), GetCurrentFolder(), .T. )
    IF EMPTY(cFile)
      RETURN
    ELSE
      IF FILE(cFile) .AND. !msgYesNo(PSayText({"Este archivo ya existe desea que se sobreescriba?","This file already exists, do you want to overwrite?"}),PSayText({"YA EXISTE","ALREADY EXISTS"}),.T.)
          RETURN
      ENDIF
      FileName:= cFile
    ENDIF
ENDIF
hb_memowrit( FileName, temptext )      // Escribe el archivo de Texto
SETPROPERTY("xFormulario","TITLE",FileName+" - "+MAIN_TITLE)
//ShellExecute( 0, "open", "notepad.exe", FileName,, 1 )
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE  PArchivo_Nuevo()
// Revisar si No hay un Archivo en uso y si se quiere Guardar
LOCAL cIniFile := GetStartupFolder() + '\setup.ini'
PFinalizarForma(cIniFile)

FileName:= "Nuevo"
SETPROPERTY("xFormulario","TITLE",FileName+" - "+MAIN_TITLE)
PMain_Inicia()
PInterfaceFormMade_Reiniciar()
RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PArchivo_Tratamiento(mFileSend)

IF PArchivo_Abrir(mFileSend)
   PInterfaceFormMade_Reiniciar()
ENDIF

RETURN
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
FUNCTION PArchivo_Abrir(mFileSend)
LOCAL c_File, mPath
PRIVATE temptext

IF mFileSend#NIL 
  IF FILE(mFileSend)
     IF UPPER(SUBSTR(mFileSend,LEN(mFileSend)-3,4))#".XFM"
        msgbox(PSayText({"Formato de Archivo incorrecto","Incorrect format"}))
        RETURN(.F.)
    ENDIF
     c_File:= mFileSend
  ELSE
    RETURN(.F.)
  ENDIF
ELSE
  mPath := GetCurrentFolder()
  c_File := GetFile({{PSayText({'Archivo de Formulario','Form File'}),'*.xfm'}, {'All File','*.*'}}, PSayText({'Archivo a Trabaja','File to work'}), mPath)
ENDIF
IF EMPTY(c_File)
  RETURN(.F.)
ENDIF

FileName:= c_File

temptext:= MEMOREAD(FileName)
temptext:= ALLTRIM(temptext)
SetCurrentFolder(mPath)
IF SUBSTR(temptext,1,1)#"{" .OR. SUBSTR(temptext,LEN(temptext),1)#"}"
  msgbox(PSayText({"Formato de Archivo incorrecto","Incorrect format"}))
  RETURN(.F.)
ENDIF

SETPROPERTY("xFormulario","TITLE",FileName+" - "+MAIN_TITLE)

aControles:= {}
aControles:= &temptext
RETURN(.T.)
*--------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------
PROCEDURE PInterfaceFormMade_Reiniciar(mWinActiva)
LOCAL I
LOCAL mBorrandoForma
DEFAULT mWinActiva:= .T.
WControles.Cbx_Controles.DeleteAllItemS
FOR I:= 1 TO LEN(aControles)
  WControles.Cbx_Controles.AddItem(aControles[I,2])
NEXT
WControles.Cbx_Controles.value:= 1
mBorrandoForma:= .F.
DO WHILE .T.
   IF _IsWindowDefined("WForma")
       IF !mBorrandoForma
          IF mWinActiva
             WForma.Release 
          ENDIF
          mBorrandoForma:= .T.
       ENDIF
   ELSE
      PInterfaceFormMade_Mostrar()
      EXIT
   ENDIF
   DO EVENTS
ENDDO
*--------------------------------------------------------------------------------------------
// ********** GENERAR CODIGO **************
*--------------------------------------------------------------------------------------------
PROCEDURE PGetCodigo(mlpreview)
// Hace el Codigo
LOCAL temptext:= ""
LOCAL mCont,mCont2
LOCAL mVecPos
LOCAL mVecTem
LOCAL mPosActual
LOCAL mNumLine,mPost
LOCAL mVertical
LOCAL mLineAdd
LOCAL mAddTbrose
LOCAL mDiferencia
LOCAL mControl, mNombre, mMasDatos, mRow, mCol, mAddValor

temptext+= '#include "minigui.ch"'+CRLF
temptext+= '#include "tsbrowse.ch"'+CRLF+CRLF
temptext+= "STATIC Sys_BackColor"+CRLF
temptext+= "STATIC Sys_FontColor"+CRLF+CRLF
temptext+= 'Procedure Main()'+CRLF+CRLF
temptext+= "MEMVAR TBrowse_1"+CRLF
temptext+= "LOCAL aTBRWData"+CRLF
temptext+= "LOCAL bColorFondo"+CRLF
temptext+= "LOCAL bColorLetra"+CRLF+CRLF
temptext+= "LOCAL mNumLine"+CRLF+CRLF
temptext+= "SET EPOCH TO Year(Date())-50"+CRLF+CRLF
temptext+= "Sys_BackColor:= {255,255,255}"+CRLF
temptext+= "Sys_FontColor:= {  0,  0,  0}"+CRLF+CRLF
temptext+= "DEFINE WINDOW "+aControles[1,2]+";"+CRLF
temptext+= "       AT "+ALLTRIM(STR(aControles[1,3,3,2]))+","+ALLTRIM(STR(aControles[1,3,4,2]))+";"+CRLF
temptext+= "       WIDTH "+ALLTRIM(STR(aControles[1,3,5,2]))+";"+CRLF
temptext+= "       HEIGHT "+ALLTRIM(STR(aControles[1,3,6,2]))+";"+CRLF
temptext+= "       TITLE '"+aControles[1,3,2,2]+"';"+CRLF
IF mlpreview
    temptext+= "       MAIN ;"+CRLF
    temptext+= "       TOPMOST"+CRLF+CRLF+CRLF
ELSE
    temptext+= "       MAIN //MODAL"+CRLF+CRLF+CRLF
ENDIF
temptext+= "   ON KEY ESCAPE ACTION thiswindow.RELEASE"+CRLF+CRLF
temptext+= "   mNumLine:= 0"+CRLF+CRLF

IF xFormulario.Chk_Selpara.VALUE
  mVertical:= " ;"+CRLF+SPACE(25)
ELSE
  mVertical:= ""
ENDIF

mAddTbrose:= .F.
mLineAdd:= xFormulario.Chk_LineAdd.VALUE

mVecPos:= {}
FOR mCont:= 2 TO LEN(aControles)
    IF aControles[mCont]=NIL
      LOOP
    ENDIF
    mVecTem :=  aControles[mCont,3]
    FOR mCont2:= 1 TO LEN(mVecTem)
       IF mVecTem[mCont2,1]="ROW"
          AADD(mVecPos,{mVecTem[mCont2,2],mCont})
       ENDIF
    NEXT
NEXT

ASORT(mVecPos,,,{|x,y| x[1] < y[1] })

mNumLine:= 0
FOR mCont:= 1 TO LEN(mVecPos)
    mPosActual:= mVecPos[mCont,2]
    IF aControles[mCont]=NIL  // Por si borraron algo
      LOOP
    ENDIF
    mControl:=  PADR(aControles[mPosActual,1],15)
    mNombre :=  aControles[mPosActual,2]
    mVecTem :=  aControles[mPosActual,3]
    mMasDatos:= ""
    FOR mCont2:= 1 TO LEN(mVecTem)
       DO CASE
       && CASE mVecTem[mCont2,1]="HORIZONTAL"
         && IF mVecTem[mCont2,2]
            && mMasDatos+="HORIZONTAL"
         && ENDIF
         
       && CASE mVecTem[mCont2,1]="CLIENTEDGE"
         && IF mVecTem[mCont2,2]
            && mMasDatos+="CLIENTEDGE"
         && ENDIF
         
       && CASE mVecTem[mCont2,1]="BORDER"
         && IF mVecTem[mCont2,2]
            && mMasDatos+="BORDER"
         && ENDIF
         
   && aItems[1]#"BORDER"     .AND. ;
   && aItems[1]#"RIGHTALIGN" .AND. ;
   && aItems[1]#"CENTERALIGN"  
       CASE mVecTem[mCont2,1]="RANGEMIN"
           mMasDatos+="RANGE "+STR(mVecTem[mCont2,2],4)
       
       CASE mVecTem[mCont2,1]="RANGEMAX"
           mMasDatos+=","+STR(mVecTem[mCont2,2],4)+" "
       
       CASE mVecTem[mCont2,1]="ROW"
         
         IF mLineAdd
             mRow       := "mNumLine+"+STR(mVecTem[mCont2,2],4)
         ELSE
             mDiferencia:= mVecTem[mCont2,2]-mNumLine
             mNumLine   := mVecTem[mCont2,2]
             mRow       := "mNumLine+="+STR(mDiferencia,4)
         ENDIF
       
       CASE mVecTem[mCont2,1]="COL"
          mCol:= STR(mVecTem[mCont2,2],4)

       CASE mVecTem[mCont2,1]="NAME"
         IF xFormulario.Chk_Selpara.VALUE
            mNombre :=  ALLTRIM(aControles[mPosActual,2],15)
         ELSE
            mNombre :=  PADR(aControles[mPosActual,2],15)
         ENDIF
          
       OTHERWISE
          
          mAddValor:= mVecTem[mCont2,2]
          IF !EMPTY(mAddValor)
               IF mVecTem[mCont2,4]="C"  //Agregar codigo 
                  IF mVecTem[mCont2,2]
                     mMasDatos+=mVecTem[mCont2,1]
                  ENDIF
               ELSE               
                   mMasDatos+=mVecTem[mCont2,1]+" "
                   DO CASE
                   CASE VALTYPE(mAddValor) = "N"
                     mMasDatos+=ALLTRIM(STR(mAddValor))
                   CASE VALTYPE(mAddValor) = "L"
                     mMasDatos+=IF(mAddValor,'.T.','.F.')
                   CASE VALTYPE(mAddValor) = "D"
                     mMasDatos+="CTOD('"+DTOC(mAddValor)+"')"
                   OTHERWISE
                     IF mVecTem[mCont2,4]="T"  //Agregar un texto
                        mMasDatos+="'"+mAddValor+"'"
                     ELSE
                       mMasDatos+=mAddValor
                     ENDIF
                   ENDCASE
               ENDIF
               mMasDatos+="  "
               mMasDatos+=mVertical
           ENDIF
       
       ENDCASE
    NEXT
    // Quitar la ultima comita
    IF xFormulario.Chk_Selpara.VALUE
        mPost:= RAT(";",mMasDatos)
        mMasDatos = SUBSTR(mMasDatos, 1, mPost-1)+CRLF
    ENDIF
    
    DO CASE
    CASE mControl = "TREE"
       temptext+= "   DEFINE TREE "+ALLTRIM(mNombre)+";"+CRLF
       temptext+= SPACE(25)+"AT  "+mRow+","+mCol+";"+CRLF
       temptext+= SPACE(25)+mMasDatos+CRLF+CRLF
       temptext+= SPACE(30)+"NODE 'Item 1'"+CRLF
       temptext+= SPACE(30)+"   TREEITEM 'Item 1.1'"+CRLF
       temptext+= SPACE(30)+"   TREEITEM 'Item 1.2' ID 999"+CRLF
       temptext+= SPACE(30)+"   TREEITEM 'Item 1.3'"+CRLF
       temptext+= SPACE(30)+"END NODE"+CRLF+CRLF
       temptext+= SPACE(30)+"NODE 'Item 2'"+CRLF
       temptext+= SPACE(30)+"   TREEITEM 'Item 2.1'"+CRLF
       temptext+= SPACE(30)+"   NODE 'Item 2.2'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.1'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.2'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.3'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.4'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.5'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.6'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.7'"+CRLF
       temptext+= SPACE(30)+"      TREEITEM 'Item 2.2.8'"+CRLF
       temptext+= SPACE(30)+"   END NODE"+CRLF
       temptext+= SPACE(30)+"   TREEITEM 'Item 2.3'"+CRLF
       temptext+= SPACE(30)+"END NODE"+CRLF+CRLF
       temptext+= "   END TREE"+CRLF+CRLF
       
    CASE mControl = "TIMER"
      temptext+= "   DEFINE TIMER "+ALLTRIM(mNombre)+" " + mMasDatos +CRLF

    CASE mControl = "TBROWSE"
       mAddTbrose:= .T.
       temptext+= "   PRIVATE "+ALLTRIM(mNombre)+CRLF
       temptext+= "   DEFINE TBROWSE "+ALLTRIM(mNombre)+";"+CRLF
       temptext+= SPACE(25)+"AT  "+mRow+","+mCol+";"+CRLF
       temptext+= SPACE(25)+mMasDatos+CRLF

           temptext+= CRLF+SPACE(30)+"aTBRWData:= {{'Dato1','Dato2'},{'"+PSayText({"Valor a Comparar","Value to compare"})+"','Dato2'},{'Dato1','Dato2'}} "+CRLF+CRLF
           temptext+= SPACE(30)+ALLTRIM(mNombre)+":SetArray(aTBRWData)"+CRLF+CRLF
           temptext+= SPACE(30)+ALLTRIM(mNombre)+":SetColor( { 15 },  { RGB(240,240,240 ) } )  // "+PSayText({"color de la cuadricula","Grid Color"})+CRLF+CRLF
           
           temptext+= SPACE(30)+"bColorFondo :=  { || IF("+ALLTRIM(mNombre)+":nAt % 2 == 0, RGB(241,240,240),RGB( 255,255,255))} "+CRLF
           temptext+= SPACE(30)+"bColorLetra :=  { || IF("+ALLTRIM(mNombre)+":aArray["+ALLTRIM(mNombre)+":nAt,1] = '"+PSayText({"Valor a Comparar","Value to compare"})+"', CLR_RED , CLR_BLACK ) } "+CRLF+CRLF
             
           temptext+= SPACE(30)+"// "+PSayText({"Puedes utilizar este metodo para agregar columnas simples","You can use this method to add simple column"})+CRLF
           temptext+= SPACE(30)+"ADD COLUMN TO TBROWSE "+ALLTRIM(mNombre)+";"+CRLF
           temptext+= SPACE(30)+"      DATA ARRAY ELEMENT 1;"+CRLF
           temptext+= SPACE(30)+"      TITLE   'Header1'   ;"+CRLF
           temptext+= SPACE(30)+"      SIZE    100         ;"+CRLF 
           temptext+= SPACE(30)+"      COLORS  bColorLetra, bColorFondo;"+CRLF
           temptext+= SPACE(30)+"      TOOLTIP 'Column1'"+CRLF+CRLF
           temptext+= SPACE(30)+"// "+PSayText({"o, puedes utilizar esta funcion, (definida abajo) apara utilizar un ciclo","or, You can use this function, (defined down) to use cycles"})+CRLF
           temptext+= SPACE(30)+"FTBRW_GRID_ColumnDefine("+ALLTRIM(mNombre)+",2 /*mElement*/,'Header2',;"+CRLF
           temptext+= SPACE(30)+"                   100 /*Size*/,'Column2',{DT_LEFT,DT_LEFT,DT_LEFT,DT_LEFT},;"+CRLF
           temptext+= SPACE(30)+"                   bColorFondo,bColorLetra,'"+PSayText({"PieDeColumna","FooterOfColumn"})+"')"+CRLF+CRLF
           
           temptext+= SPACE(30)+"// "+PSayText({"esta funcion, (definida abajo) hace standard todas las TsBROWSE","this function, (defined down) made Standard all TsBrowse"})+CRLF
           temptext+= SPACE(30)+"pTsBrowSettingEnd("+ALLTRIM(mNombre)+")"+CRLF+CRLF
      temptext+= "   END TBROWSE"+CRLF+CRLF

    OTHERWISE
       temptext+= "   @ "+mRow+","+mCol+" "+mControl+" "+mNombre+" "+mVertical+mMasDatos+CRLF
    ENDCASE

NEXT
temptext+=""+CRLF
temptext+= "END WINDOW"+CRLF+CRLF
temptext+= aControles[1,2]+".CENTER"+CRLF
temptext+= aControles[1,2]+".ACTIVATE"+CRLF+CRLF

IF mAddTbrose
  temptext+= "RETURN"+CRLF+CRLF+CRLF+CRLF
  temptext+= "*-------------------------------------------------------------------------------"+CRLF
  temptext+= "// "+PSayText({"Crea una columna para una TsBrowse","Add a column to TsBrowse"})+CRLF
  temptext+= "FUNCTION FTBRW_GRID_ColumnDefine(oBrowse,   mElement,        /*3*/mTitulo,;"+CRLF
  temptext+= "                                 mSize ,    mTooltip,        /*6*/aJustify,;"+CRLF
  temptext+= "                                 bColorBack,bColorForeground,/*9*/cFooter)"+CRLF+CRLF
  temptext+= "DEFAULT aJustify:=          {DT_LEFT,DT_LEFT,DT_LEFT,DT_LEFT}"+CRLF
  temptext+= "DEFAULT bColorBack:=        { || IIF( OBrowse:nAt % 2 == 0, RGB(241,240,240),RGB( 255,255,255))}"+CRLF
  temptext+= "DEFAULT bColorForeground:=  {|| RGB(000,000,00) }"+CRLF
  temptext+= "DEFAULT mTooltip:= mTitulo"+CRLF+CRLF
  temptext+= "ADD COLUMN TO TBROWSE oBrowse;"+CRLF
  temptext+= "              DATA ARRAY ELEMENT (mElement);"+CRLF
  temptext+= "              FOOTERS cFooter;"+CRLF
  temptext+= "              ALIGNS  aJustify[1],aJustify[2],aJustify[3];"+CRLF
  temptext+= "              TITLE   mTitulo;"+CRLF
  temptext+= "              SIZE    mSize;"+CRLF
  temptext+= "              COLORS  bColorForeground,bColorBack;"+CRLF
  temptext+= "              TOOLTIP mTooltip"+CRLF
  temptext+= "RETURN (.T.)"+CRLF+CRLF
  temptext+= "*-------------------------------------------------------------------------------"+CRLF
  temptext+= "PROCEDURE pTsBrowSettingEnd(oBrw)"+CRLF
  temptext+= "// "+PSayText({"Hace standard todas las TsBROWSE","Made Standard all TsBrowse"})+CRLF
  temptext+= "oBrw:SetColor( {CLR_FOOTB,CLR_FOOTF}, {CLR_HGRAY,CLR_BLACK}, )"+CRLF
  temptext+= "oBrw:nHeightCell += 6"+CRLF
  temptext+= "oBrw:nHeightFoot += 4"+CRLF
  temptext+= "oBrw:nHeightHead += 7"+CRLF
  temptext+= "oBrw:nWheelLines := 1"+CRLF
  temptext+= "oBrw:lNoResetPos := .F."+CRLF
  temptext+= "oBrw:SetSelectMode(.F.)"+CRLF
  temptext+= "oBrw:SetDeleteMode( .T., .F.,{||.F.} )"+CRLF
ENDIF
temptext+= "RETURN"+CRLF

// Revisa si hay una Tbrowse
hb_memowrit( GetStartupFolder() +"\myform.prg", temptext )      // Escribe el archivo de Texto
IF !mlpreview
   ShellExecute( 0, "open", "notepad.exe", GetStartupFolder()+"\myform.prg",, 1 )
ENDIF

*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
FUNCTION PSayText(maTexto)
LOCAL mcReturn:= ""
DO CASE
CASE mIdioma = "ESP"
   mcReturn:= maTexto[1]
CASE mIdioma = "ENG"
   mcReturn:= maTexto[2]
ENDCASE
RETURN(mcReturn)
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------

/*
 * C-level
*/

#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"
/*
HB_FUNC( SETPIXEL )
{
   hb_retnl( (ULONG) SetPixel( (HDC) hb_parnl( 1 ) ,
				hb_parni( 2 )      ,
				hb_parni( 3 )      ,
			(COLORREF) hb_parnl( 4 ) ) );
}
*/
HB_FUNC( SETCROSSCURSOR )
{
   SetClassLong( ( HWND ) hb_parnl(1), GCL_HCURSOR, ( LONG ) LoadCursor(NULL, IDC_CROSS) );
}

HB_FUNC( INTERACTIVEMOVE )
{
   keybd_event(
      VK_DOWN,
      0,
      0,
      0
      );

   keybd_event(
      VK_RIGHT,
      0,
      0,
      0
      );

   SendMessage( GetFocus(), WM_SYSCOMMAND, SC_MOVE, 10 );
   RedrawWindow( GetFocus(), NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

HB_FUNC( INTERACTIVESIZE )
{
   keybd_event(
      VK_DOWN,
      0,
      0,
      0
      );

   keybd_event(
      VK_RIGHT,
      0,
      0,
      0
      );

   SendMessage( GetFocus(), WM_SYSCOMMAND, SC_SIZE, 0 );
}

#pragma ENDDUMP
