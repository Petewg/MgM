/*
 * Implementaci�n del comando EDIT EXTENDED para la librer�a MiniGUI.
 * (c) Crist�bal Moll� [cemese@terra.es]
 *
 * - Descripci�n -
 * ===============
 *      EDIT EXTENDED, es un comando que permite realizar el mantenimiento de una bdd. En principio
 *      est� dise�ado para administrar bases de datos que usen los divers DBFNTX y DBFCDX,
 *      presentando otras bases de datos con diferentes drivers resultados inesperados.
 *
 * - Sint�xis -
 * ============
 *      Todos los par�metros del comando EDIT son opcionales.
 *
 *      EDIT EXTENDED                           ;
 *       [ WORKAREA cWorkArea ]                 ;
 *       [ TITLE cTitle ]                       ;
 *       [ FIELDNAMES acFieldNames ]            ;
 *       [ FIELDMESSAGES acFieldMessages ]      ;
 *       [ FIELDENABLED alFieldEnabled ]        ;
 *       [ TABLEVIEW alTableView ]              ;
 *       [ OPTIONS aOptions ]                   ;
 *       [ ON SAVE bSave ]                      ;
 *       [ ON FIND bFind ]                      ;
 *       [ ON PRINT bPrint ]
 *
 *      Si no se pasa ning�n par�metro, el comando EDIT toma como bdd de trabajo la del
 *      area de trabajo actual.
 *
 *      [cWorkArea]             Cadena de texto con el nombre del alias de la base de datos
 *                              a editar. Por defecto el alias de la base de datos activa.
 *
 *      [cTitle]                Cadena de texto con el t�tulo de la ventana de visualizaci�n
 *                              de registros. Por defecto se toma el alias de la base de datos
 *                              activa.
 *
 *      [acFieldNames]          Matriz de cadenas de texto con el nombre descriptivo de los
 *                              campos de la base de datos. Tiene que tener el mismo n�mero
 *                              de elementos que campos la bdd. Por defecto se toma el nombre
 *                              de los campos de la estructura de la bdd.
 *
 *      [acFieldMessages]       Matriz de cadenas de texto con el texto que aparaecer� en la
 *                              barra de estado cuando se este a�adiento o editando un registro.
 *                              Tiene que tener el mismo numero de elementos que campos la bdd.
 *                              Por defecto se rellena con valores internos.
 *
 *      [alFieldEnabled]        Matriz de valores l�gicos que indica si el campo referenciado
 *                              por la matriz esta activo durante la edici�n de registro. Tiene
 *                              que tener el mismo numero de elementos que campos la bdd. Por
 *                              defecto toma todos los valores como verdaderos ( .t. ).
 *
 *      [alTableView]           Matriz de valores l�gicos que indica si el campo referenciado
 *                              por la matriz es visible en la tabla. Tiene que tener el mismo
 *                              numero de elementos que campos la bdd. Por defecto toma todos
 *                              los valores como verdaderos ( .t. ).
 *
 *                              Array of logical values that it indicates if the referenced field
 *                              by the array is visible in the table. It must have the same one
 *                              number of elements as fields count of edited dbf.
 *                              By default it takes all the values as true (t.).
 *
 *      [aOptions]              Matriz de 2 niveles. el primero de tipo texto es la descripci�n
 *                              de la opci�n. El segundo de tipo bloque de c�digo es la opci�n
 *                              a ejecutar cuando se selecciona. Si no se pasa esta variable,
 *                              se desactiva la lista desplegable de opciones.
 *
 *                              Array of 2 elements subarrays. First element( character type)
 *                              it is the description of the option. The second (codeblock type)
 *                              will evaluate when it is selected. If this variable does not go,
 *                              the drop-down list of options is deactivated.
 *                              By default this array is empty.
 *
 *      [bSave]                 Bloque de codigo con el formato {|aValores, lNuevo| Accion } que
 *                              se ejecutar� al pulsar la tecla de guardar registro. Se pasan
 *                              las variables aValores con el contenido del registro a guardar y
 *                              lNuevo que indica si se est� a�adiendo (.t.) o editando (.f.).
 *                              Esta variable ha de devolver .t. para salir del modo de edici�n.
 *                              Por defecto se graba con el c�digo de la funci�n.
 *
 *      [bFind]                 Bloque de codigo a ejecutar cuando se pulsa la tecla de busqueda.
 *                              Por defecto se usa el c�digo de la funci�n.
 *
 *      [bPrint]                Bloque de c�digo a ejecutar cuando se pulsa la tecla de listado.
 *                              Por defecto se usa el codigo de la funci�n.
 *
 *
 * - Historial -
 * =============
 *      Mar 03  - Definici�n de la funci�n.
 *              - Pruebas.
 *              - Soporte para lenguaje en ingl�s.
 *              - Corregido bug al borrar en bdds con CDX.
 *              - Mejora del control de par�metros.
 *              - Mejorada la funci�n de de busqueda.
 *              - Soprte para multilenguaje.
 *              - Versi�n 1.0 lista.
 *      Abr 03  - Corregido bug en la funci�n de busqueda (Nombre del bot�n).
 *              - A�adido soporte para idioma Ruso (Grigory Filiatov).
 *              - A�adido soporte para idioma Catal�n (Por corregir).
 *              - A�adido soporte para idioma Portugu�s (Clovis Nogueira Jr).
 *              - A�adido soporte para idioma Polaco (Janusz Poura).
 *              - A�adido soporte para idioma Franc�s (C. Jouniauxdiv).
 *      May 03  - A�adido soporte para idioma Italiano (Lupano Piero).
 *              - A�adido soporte para idioma Alem�n (Janusz Poura).
 *              - Cambio del formato de llamada al comando.
 *              - La creaci�n de ventanas se realiza en funci�n del alto y ancho
 *                de la pantalla.
 *              - Se elimina la restricci�n de tama�o en los nombre de etiquetas.
 *              - Se elimina la restricci�n de numero de campos del area de la bdd.
 *              - Se elimina la restricci�n de que los campos tipo MEMO tienen que ir
 *                al final de la base de datos.
 *              - Se a�ade la opci�n de visualizar comentarios en la barra de estado.
 *              - Se a�ade opci�n de control de visualizaci�n de campos en el browse.
 *              - Se modifica el par�metro nombre del area de la bdd que pasa a ser
 *                opcional.
 *              - Se a�ade la opci�n de saltar al siguiente foco mediante la pulsaci�n
 *                de la tecla ENTER (Solo a controles tipo TEXTBOX).
 *              - Se a�ade la opci�n de cambio del indice activo.
 *              - Mejora de la rutina de busqueda.
 *              - Mejora en la ventana de definici�n de listados.
 *              - Peque�os cambios en el formato del listado.
 *              - Actualizaci�n del soporte multilenguaje.
 *      Jun 03  - Pruebas de la versi�n 1.5
 *              - Se implementan las nuevas opciones de la librer�a de Ryszard Rylko
 *              - Se implementa el filtrado de la base de datos.
 *      Ago 03  - Se corrige bug en establecimiento de filtro.
 *              - Actualizado soporte para italiano (Arcangelo Molinaro).
 *              - Actualizado soporte multilenguage.
 *              - Actualizado el soporte para filtrado.
 *      Sep 03  - Idioma Vasco listo. Gracias a Gerardo Fern�ndez.
 *              - Idioma Italaino listo. Gracias a Arcangelo Molinaro.
 *              - Idioma Franc�s listo. Gracias a Chris Jouniauxdiv.
 *              - Idioma Polaco listo. Gracias a Jacek Kubica.
 *      Oct 03  - Solucionado problema con las clausulas ON FIND y ON PRINT, ahora
 *                ya tienen el efecto deseado. Gracias a Grigory Filiatov.
 *              - Se cambia la referencia a _ExtendedNavigation por _HMG_ExtendedNavigation
 *                para adecuarse a la sintaxis de la construci�n 76.
 *              - Idioma Alem�n listo. Gracias a Andreas Wiltfang.
 *      Nov 03  - Problema con dbs en set exclusive. Gracias a cas_minigui.
 *              - Problema con tablas con pocos campos. Gracias a cas_minigui.
 *              - Cambio en demo para ajustarse a nueva sintaxis RDD Harbour (DBFFPT).
 *      Dic 03  - Ajuste de la longitud del control para fecha. Gracias a Laszlo Henning.
 *      Ene 04  - Problema de bloqueo con SET DELETED ON. Gracias a Grigory Filiatov y Roberto L�pez.
 *
 *
 * - Limitaciones -
 * ================
 *      - No se pueden realizar busquedas por campos l�gico o memo.
 *      - No se pueden realizar busquedas en indices con claves compuestas, la busqueda
 *        se realiza por el primer campo de la clave compuesta.
 *
 *
 * - Por hacer -
 * =============
 *      - Implementar busqueda del siguiente registro.
 *
 */

// Ficheros de definiciones.---------------------------------------------------
#include "minigui.ch"
#include "dbstruct.ch"
#include "winprint.ch"

// Declaraci�n de definiciones.------------------------------------------------
// Generales.
#define ABM_CRLF                HB_OsNewLine()

// Estructura de la etiquetas.
#define ABM_LBL_LEN             5
#define ABM_LBL_NAME            1
#define ABM_LBL_ROW             2
#define ABM_LBL_COL             3
#define ABM_LBL_WIDTH           4
#define ABM_LBL_HEIGHT          5

// Estructura de los controles de edici�n.
#define ABM_CON_LEN             7
#define ABM_CON_NAME            1
#define ABM_CON_ROW             2
#define ABM_CON_COL             3
#define ABM_CON_WIDTH           4
#define ABM_CON_HEIGHT          5
#define ABM_CON_DES             6
#define ABM_CON_TYPE            7

// Tipos de controles de edici�n.
#define ABM_TEXTBOXC            1
#define ABM_TEXTBOXN            2
#define ABM_DATEPICKER          3
#define ABM_CHECKBOX            4
#define ABM_EDITBOX             5

// Estructura de las opciones de usuario.
#define ABM_OPC_TEXTO           1
#define ABM_OPC_BLOQUE          2

// Tipo de acci�n al definir las columnas del listado.
#define ABM_LIS_ADD             1
#define ABM_LIS_DEL             2

// Tipo de acci�n al definir los registros del listado.
#define ABM_LIS_SET1            1
#define ABM_LIS_SET2            2


#xtranslate Alltrim( Str( <i> ) ) => hb_NtoS( <i> )


// Declaraci�n de variables globales.------------------------------------------
STATIC _cArea           /*as character*/            // Nombre del area de la bdd.
STATIC _aEstructura     /*as array*/                // Estructura de la bdd.
STATIC _aIndice         /*as array*/                // Nombre de los indices de la bdd.
STATIC _aIndiceCampo    /*as array*/                // N�mero del campo indice.
STATIC _nIndiceActivo   /*as array*/                // Indice activo.
STATIC _aNombreCampo    /*as array*/                // Nombre desciptivo de los campos de la bdd.
STATIC _aEditable       /*as array*/                // Indicador de si son editables.
STATIC _cTitulo         /*as character*/            // T�tulo de la ventana.
STATIC _nAltoPantalla   /*as numeric*/              // Alto de la pantalla.
STATIC _nAnchoPantalla  /*as numeric*/              // Ancho de la pantalla.
STATIC _aEtiqueta       /*as array*/                // Datos de las etiquetas.
STATIC _aControl        /*as array*/                // Datos de los controles.
STATIC _aCampoTabla     /*as array*/                // Nombre de los campos para la tabla.
STATIC _aAnchoTabla     /*as array*/                // Anchos de los campos para la tabla.
STATIC _aCabeceraTabla  /*as array*/                // Texto de las columnas de la tabla.
STATIC _aAlineadoTabla  /*as array*/                // Alineaci�n de las columnas de la tabla.
STATIC _aVisibleEnTabla /*as array*/                // Campos visibles en la tabla.
STATIC _nControlActivo  /*as numeric*/              // Control con foco.
STATIC _aOpciones       /*as array*/                // Opciones del usuario.
STATIC _bGuardar        /*as codeblock*/            // Acci�n para guardar registro.
STATIC _bBuscar         /*as codeblock*/            // Acci�n para buscar registro.
STATIC _bImprimir       /*as codeblock*/            // Acci�n para imprimir listado.
STATIC _lFiltro         /*as logical*/              // Indicativo de filtro activo.
STATIC _cFiltro         /*as character*/            // Condici�n de filtro.


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM()
 * Descripci�n: Funci�n inicial. Comprueba los par�metros pasados, crea la estructura
 *              para las etiquetas y controles de edici�n y crea la ventana de visualizaci�n
 *              de registro.
 *  Par�metros: cArea           Nombre del area de la bdd. Por defecto se toma el area
 *                              actual.
 *              cTitulo         T�tulo de la ventana de edici�n. Por defecto se toma el
 *                              nombre de la base de datos actual.
 *              aNombreCampo    Matriz de valores car�cter con los nombres descriptivos de
 *                              los campos de la bdd.
 *              aAvisoCampo     Matriz con los textos que se presentar�n en la barra de
 *                              estado al editar o a�adir un registro.
 *              aEditable       Matriz de val�re l�gicos que indica si el campo referenciado
 *                              esta activo en la ventana de edici�n de registro.
 *              aVisibleEnTabla Matriz de valores l�gicos que indica la visibilidad de los
 *                              campos del browse de la ventana de edici�n.
 *              aOpciones       Matriz con los valores de las opciones de usuario.
 *              bGuardar        Bloque de c�digo para la acci�n de guardar registro.
 *              bBuscar         Bloque de c�digo para la acci�n de buscar registro.
 *              bImprimir       Bloque de c�digo para la acci�n imprimir.
 *    Devuelve: NIL
****************************************************************************************/
FUNCTION ABM2( cArea, cTitulo, aNombreCampo, ;
      aAvisoCampo, aEditable, aVisibleEnTabla, ;
      aOpciones, bGuardar, bBuscar, bImprimir )

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL   i              /*as numeric*/   // Indice de iteraci�n.
   LOCAL   k              /*as numeric*/   // Indice de iteraci�n.
   LOCAL   nArea          as numeric       // Numero del area de la bdd.
   LOCAL   nRegistro      as numeric       // N�mero de regisrto de la bdd.
   LOCAL   nEstructura    /*as numeric*/   // Ancho del estructura de la bdd.
   LOCAL   lSalida        /*as logical*/   // Control de bucle.
   LOCAL   nVeces         /*as numeric*/   // Indice de iteraci�n.
   LOCAL   cIndice        as character     // Nombre del indice.
   LOCAL   cIndiceActivo  as character     // Nombre del indice activo.
   LOCAL   cClave         as character     // Clave del indice.
   LOCAL   nInicio        /*as numeric*/   // Inicio de la cadena de busqueda.
   LOCAL   nAnchoCampo    /*as numeric*/   // Ancho del campo actual.
   LOCAL   nAnchoEtiqueta /*as numeric*/   // Ancho m�ximo de las etiquetas.
   LOCAL   nFila          /*as numeric*/   // Fila de creaci�n del control de edici�n.
   LOCAL   nColumna       /*as numeric*/   // Columna de creaci�n del control de edici�n.
   LOCAL   aTextoOp       /*as numeric*/   // Texto de las opciones de usuario.
   LOCAL   _BakExtendedNavigation          // Estado de SET NAVIAGTION.
   LOCAL   _BackDeleted                    // Estado de SET DELETED.
   LOCAL   cFiltroAnt     as character     // Condici�n del filtro anterior.

   // ------- Gusrdar estado actual de SET DELETED y activarlo
   _BackDeleted := Set( _SET_DELETED )
   SET DELETED OFF

   // ------- Inicializaci�n del soporte multilenguaje.---------------------------
   InitMessages()

   // ------- Desactivaci�n de SET NAVIGATION.------------------------------------
   _BakExtendedNavigation := _HMG_ExtendedNavigation
   _HMG_ExtendedNavigation := .F.

   // ------- Control de par�metros.----------------------------------------------
   // Area de la base de datos.
   IF ValType( cArea ) != "C" .OR. Empty( cArea )
      _cArea := Alias()
      IF _cArea == ""
         msgExclamation( _HMG_aLangUser[ 1 ], "EDIT EXTENDED" )
         RETURN NIL
      ENDIF
   ELSE
      _cArea := cArea
   ENDIF
   _aEstructura := ( _cArea )->( dbStruct() )
   nEstructura := Len( _aEstructura )

   // T�tulo de la ventana.
   IF Empty( cTitulo ) .OR. ValType( cTitulo ) != "C"
      _cTitulo := _cArea
   ELSE
      _cTitulo := cTitulo
   ENDIF

   // Nombres de los campos.
   lSalida := .T.
   IF ValType( aNombreCampo ) != "A"
      lSalida := .F.
   ELSE
      IF Len( aNombreCampo ) != nEstructura
         lSalida := .F.
      ELSE
         FOR i := 1 TO Len( aNombreCampo )
            IF ValType( aNombreCampo[ i ] ) != "C"
               lSalida := .F.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF lSalida
      _aNombreCampo := aNombreCampo
   ELSE
      _aNombreCampo := {}
      FOR i := 1 TO nEstructura
         AAdd( _aNombreCampo, Upper( Left( _aEstructura[ i, DBS_NAME ], 1 ) ) + ;
            Lower( SubStr( _aEstructura[ i, DBS_NAME ], 2 ) ) )
      NEXT
   ENDIF

   // Texto de aviso en la barra de estado de la ventana de edici�n de registro.
   lSalida := .T.
   IF ValType( aAvisoCampo ) != "A"
      lSalida := .F.
   ELSE
      IF Len( aAvisoCampo ) != nEstructura
         lSalida := .F.
      ELSE
         FOR i := 1 TO Len( aAvisoCampo )
            IF ValType( aAvisoCampo[ i ] ) != "C"
               lSalida := .F.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   if ! lSalida
      aAvisoCampo := {}
      FOR i := 1 TO nEstructura
         DO CASE
         CASE _aEstructura[ i, DBS_TYPE ] == "C"
            AAdd( aAvisoCampo, _HMG_aLangUser[ 2 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "N"
            AAdd( aAvisoCampo, _HMG_aLangUser[ 3 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "D"
            AAdd( aAvisoCampo, _HMG_aLangUser[ 4 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "L"
            AAdd( aAvisoCampo, _HMG_aLangUser[ 5 ] )
         CASE _aEstructura[ i, DBS_TYPE ] == "M"
            AAdd( aAvisoCampo, _HMG_aLangUser[ 6 ] )
         OTHERWISE
            AAdd( aAvisoCampo, _HMG_aLangUser[ 7 ] )
         ENDCASE
      NEXT
   ENDIF

   // Campos visibles en la tabla de la ventana de visualizaci�n de registros.
   lSalida := .T.
   IF ValType( aVisibleEnTabla ) != "A"
      lSalida := .F.
   ELSE
      IF Len( aVisibleEnTabla ) != nEstructura
         lSalida := .F.
      ELSE
         FOR i := 1 TO Len( aVisibleEnTabla )
            IF ValType( aVisibleEnTabla[ i ] ) != "L"
               lSalida := .F.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF lSalida
      _aVisibleEnTabla := aVisibleEnTabla
   ELSE
      _aVisibleEnTabla := {}
      FOR i := 1 TO nEstructura
         AAdd( _aVisibleEnTabla, .T. )
      NEXT
   ENDIF

   // Estado de los campos en la ventana de edici�n de registro.
   lSalida := .T.
   IF ValType( aEditable ) != "A"
      lSalida := .F.
   ELSE
      IF Len( aEditable ) != nEstructura
         lSalida := .F.
      ELSE
         FOR i := 1 TO Len( aEditable )
            IF ValType( aEditable[ i ] ) != "L"
               lSalida := .F.
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF
   IF lSalida
      _aEditable := aEditable
   ELSE
      _aEditable := {}
      FOR i := 1 TO nEstructura
         AAdd( _aEditable, .T. )
      NEXT
   ENDIF

   // Opciones del usuario.
   lSalida := .T.

   IF ValType( aOpciones ) != "A"
      lSalida := .F.
   ELSEIF Len( aOpciones ) < 1
      lSalida := .F.
   ELSEIF Len( aOpciones[ 1 ] ) != 2
      lSalida := .F.
   ELSE
      FOR i := 1 TO Len( aOpciones )
         IF ValType( aOpciones[ i, ABM_OPC_TEXTO ] ) != "C" .OR. ;
               ValType( aOpciones[ i, ABM_OPC_BLOQUE ] ) != "B"
            lSalida := .F.
            EXIT
         ENDIF
      NEXT
   ENDIF

   IF lSalida
      _aOpciones := aOpciones
   ELSE
      _aOpciones := {}
   ENDIF

   // Acci�n al guardar.
   IF ValType( bGuardar ) == "B"
      _bGuardar := bGuardar
   ELSE
      _bGuardar := NIL
   ENDIF

   // Acci�n al buscar.
   IF ValType( bBuscar ) == "B"
      _bBuscar := bBuscar
   ELSE
      _bBuscar := NIL
   ENDIF

   // Acci�n al buscar.
   IF ValType( bImprimir ) == "B"
      _bImprimir := bImprimir
   ELSE
      _bImprimir := NIL
   ENDIF

   // ------- Selecci�n del area de la bdd.---------------------------------------
   nRegistro := ( _cArea )->( RecNo() )
   nArea := Select()
   cIndiceActivo := ( _cArea )->( ordSetFocus() )
   cFiltroAnt := ( _cArea )->( dbFilter() )
   dbSelectArea( _cArea )
   ( _cArea )->( dbGoTop() )

   // ------- Inicializaci�n de variables.----------------------------------------
   // Filtro.
   _cFiltro := cFiltroAnt
   _lFiltro := !( Empty( _cFiltro ) )

   // Indices de la base de datos.
   lSalida := .T.
   k := 1
   _aIndice := {}
   _aIndiceCampo := {}
   nVeces := 1
   AAdd( _aIndice, _HMG_aLangLabel[ 1 ] )
   AAdd( _aIndiceCampo, 0 )
   DO WHILE lSalida
      IF Empty( ( _cArea )->( ordName( k ) ) )
         lSalida := .F.
      ELSE
         cIndice := Upper( ( _cArea )->( ordName( k ) ) )
         AAdd( _aIndice, cIndice )
         cClave := Upper( ( _cArea )->( ordKey( k ) ) )
         FOR i := 1 TO nEstructura
            IF nVeces <= 1
               nInicio := At( _aEstructura[ i, DBS_NAME ], cClave )
               IF nInicio != 0
                  AAdd( _aIndiceCampo, i )
                  nVeces++
               ENDIF
            ENDIF
         NEXT
      ENDIF
      k++
      nVeces := 1
   ENDDO

   // Numero de indice.
   IF Empty( cIndiceActivo )
      _nIndiceActivo := 1
   ELSE
      _nIndiceActivo := AScan( _aIndice, Upper( ( _cArea )->( ordSetFocus() ) ) )
   ENDIF

   // Tama�o de la pantalla.
   _nAltoPantalla := getDesktopHeight()
   _nAnchoPantalla := getDesktopWidth()

   // Datos de las etiquetas y los controles de la ventana de edici�n.
   _aEtiqueta := Array( nEstructura, ABM_LBL_LEN )
   _aControl := Array( nEstructura, ABM_CON_LEN )
   nFila := 10
   nColumna := 10
   nAnchoEtiqueta := 0
   FOR i := 1 TO Len( _aNombreCampo )
      nAnchoEtiqueta := iif( nAnchoEtiqueta > ( Len( _aNombreCampo[ i ] ) * 9 ), ;
         nAnchoEtiqueta, ;
         Len( _aNombreCampo[ i ] ) * 9 )
   NEXT
   FOR i := 1 TO nEstructura
      _aEtiqueta[ i, ABM_LBL_NAME ] := "ABM2Etiqueta" + AllTrim( Str( i ) )
      _aEtiqueta[ i, ABM_LBL_ROW ] := nFila
      _aEtiqueta[ i, ABM_LBL_COL ] := nColumna
      _aEtiqueta[ i, ABM_LBL_WIDTH ] := Len( _aNombreCampo[ i ] ) * 9
      _aEtiqueta[ i, ABM_LBL_HEIGHT ] := 25
      switch Left( _aEstructura[ i, DBS_TYPE ], 1 )
      CASE "C"
         _aControl[ i, ABM_CON_NAME ] := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ] := nFila
         _aControl[ i, ABM_CON_COL ] := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ] := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50, 50, _aEstructura[ i, DBS_LEN ] * 10 )
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ] := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ] := ABM_TEXTBOXC
         EXIT
      CASE "D"
         _aControl[ i, ABM_CON_NAME ] := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ] := nFila
         _aControl[ i, ABM_CON_COL ] := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ] := _aEstructura[ i, DBS_LEN ] * 10
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ] := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ] := ABM_DATEPICKER
         EXIT
      CASE "N"
         _aControl[ i, ABM_CON_NAME ] := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ] := nFila
         _aControl[ i, ABM_CON_COL ] := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ] := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50, 50, _aEstructura[ i, DBS_LEN ] * 10 )
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ] := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ] := ABM_TEXTBOXN
         EXIT
      CASE "L"
         _aControl[ i, ABM_CON_NAME ] := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ] := nFila
         _aControl[ i, ABM_CON_COL ] := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ] := 25
         _aControl[ i, ABM_CON_HEIGHT ] := 25
         _aControl[ i, ABM_CON_DES ] := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ] := ABM_CHECKBOX
         EXIT
      CASE "M"
         _aControl[ i, ABM_CON_NAME ] := "ABM2Control" + AllTrim( Str( i ) )
         _aControl[ i, ABM_CON_ROW ] := nFila
         _aControl[ i, ABM_CON_COL ] := nColumna + nAnchoEtiqueta + 20
         _aControl[ i, ABM_CON_WIDTH ] := 300
         _aControl[ i, ABM_CON_HEIGHT ] := 70
         _aControl[ i, ABM_CON_DES ] := aAvisoCampo[ i ]
         _aControl[ i, ABM_CON_TYPE ] := ABM_EDITBOX
         nFila += 45
      endswitch
      IF _aEstructura[ i, DBS_TYPE ] $ "CDNLM"
         nFila += 35
      ENDIF
   NEXT

   // Datos de la tabla de la ventana de visualizaci�n.

   _aCampoTabla := { "if(deleted(), 'X', ' ')" }
   _aAnchoTabla := { 20 }
   _aCabeceraTabla := { "X" }
   _aAlineadoTabla := { BROWSE_JTFY_LEFT }

   FOR i := 1 TO nEstructura
      IF _aVisibleEnTabla[ i ]
         AAdd( _aCampoTabla, _cArea + "->" + _aEstructura[ i, DBS_NAME ] )
         nAnchoCampo := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50, 50, ;
            _aEstructura[ i, DBS_LEN ] * 10 )
         nAnchoEtiqueta := Len( _aNombreCampo[ i ] ) * 10
         AAdd( _aAnchoTabla, iif( nAnchoEtiqueta > nAnchoCampo, ;
            nAnchoEtiqueta, ;
            nAnchoCampo ) )
         AAdd( _aCabeceraTabla, _aNombreCampo[ i ] )

         IF _aEstructura[ i, DBS_TYPE ] == "L"
            AAdd( _aAlineadoTabla, BROWSE_JTFY_CENTER )
         ELSEIF _aEstructura[ i, DBS_TYPE ] == "D"
            AAdd( _aAlineadoTabla, BROWSE_JTFY_CENTER )
         ELSEIF _aEstructura[ i, DBS_TYPE ] == "N"
            AAdd( _aAlineadoTabla, BROWSE_JTFY_RIGHT )
         ELSE
            AAdd( _aAlineadoTabla, BROWSE_JTFY_LEFT )
         ENDIF
      ENDIF
   NEXT

   // ------- Definici�n de la ventana de visualizaci�n.--------------------------
   DEFINE WINDOW wndABM2Edit ;
         AT 60, 30 ;
         WIDTH _nAnchoPantalla - 60 ;
         HEIGHT _nAltoPantalla - 140 ;
         TITLE _cTitulo ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         ON INIT {|| ABM2Redibuja() } ;
         ON RELEASE {|| ABM2salir( nRegistro, cIndiceActivo, cFiltroAnt, nArea ) } ;
         FONT _GetSysFont() SIZE 9

      // Define la barra de estado de la ventana de visualizaci�n.
      DEFINE STATUSBAR FONT _GetSysFont() SIZE 9
         STATUSITEM _HMG_aLangLabel[ 19 ] // 1
         STATUSITEM _HMG_aLangLabel[ 20 ] WIDTH 100 raised // 2
         STATUSITEM _HMG_aLangLabel[ 2 ] + ': ' WIDTH 200 raised // 3
      END STATUSBAR

      // Define la barra de botones de la ventana de visualizaci�n.
      DEFINE TOOLBAR tbEdit buttonsize 100, 32 FLAT righttext BORDER
         BUTTON tbbCerrar CAPTION _HMG_aLangButton[ 1 ] ;
            PICTURE "MINIGUI_EDIT_CLOSE" ;
            ACTION wndABM2Edit.RELEASE
         BUTTON tbbNuevo CAPTION _HMG_aLangButton[ 2 ] ;
            PICTURE "MINIGUI_EDIT_NEW" ;
            ACTION {|| ABM2Editar( .T. ) }
         BUTTON tbbEditar CAPTION _HMG_aLangButton[ 3 ] ;
            PICTURE "MINIGUI_EDIT_EDIT" ;
            ACTION {|| ABM2Editar( .F. ) }
         BUTTON tbbBorrar CAPTION _HMG_aLangButton[ 4 ] ;
            PICTURE "MINIGUI_EDIT_DELETE" ;
            ACTION {|| ABM2Borrar() }
         BUTTON tbbRecover CAPTION _HMG_aLangButton[ 12 ] ;
            PICTURE "MINIGUI_EDIT_UNDO" ;
            ACTION {|| ABM2Recover() }
         BUTTON tbbBuscar CAPTION _HMG_aLangButton[ 5 ] ;
            PICTURE "MINIGUI_EDIT_FIND" ;
            ACTION {|| ABM2Buscar() }
         BUTTON tbbListado CAPTION _HMG_aLangButton[ 6 ] ;
            PICTURE "MINIGUI_EDIT_PRINT" ;
            ACTION {|| ABM2Imprimir() }
      END TOOLBAR

   END WINDOW

   // ------- Creaci�n de los controles de la ventana de visualizaci�n.-----------
   @ 50, 10 FRAME frmEditOpciones ;
      OF wndABM2Edit ;
      CAPTION "" ;
      WIDTH wndABM2Edit.WIDTH -25 ;
      HEIGHT 60
   @ 112, 10 FRAME frmEditTabla ;
      OF wndABM2Edit ;
      CAPTION "" ;
      WIDTH wndABM2Edit.WIDTH -25 ;
      HEIGHT wndABM2Edit.HEIGHT -165
   @ 60, 20 LABEL lblIndice ;
      OF wndABM2Edit ;
      VALUE _HMG_aLangUser[ 26 ] ;
      AUTOSIZE ;
      FONT _GetSysFont() SIZE 9
   @ 75, 20 COMBOBOX cbIndices ;
      OF wndABM2Edit ;
      ITEMS _aIndice ;
      VALUE _nIndiceActivo ;
      WIDTH 150 ;
      FONT _GetSysFont() SIZE 9 ;
      ON CHANGE {|| ABM2CambiarOrden() }
   nColumna := wndABM2Edit.WIDTH -175
   aTextoOp := {}
   FOR i := 1 TO Len( _aOpciones )
      AAdd( aTextoOp, _aOpciones[ i, ABM_OPC_TEXTO ] )
   NEXT
   @ 60, nColumna LABEL lblOpciones ;
      OF wndABM2Edit ;
      VALUE _HMG_aLangLabel[ 5 ] ;
      AUTOSIZE ;
      FONT _GetSysFont() SIZE 9
   @ 75, nColumna COMBOBOX cbOpciones ;
      OF wndABM2Edit ;
      ITEMS aTextoOp ;
      VALUE 1 ;
      WIDTH 150 ;
      FONT _GetSysFont() SIZE 9 ;
      ON CHANGE {|| ABM2EjecutaOpcion() }
   @ 65, ( wndABM2Edit.Width / 2 ) - 110 BUTTON btnFiltro1 ;
      OF wndABM2Edit ;
      CAPTION _HMG_aLangButton[ 10 ] ;
      ACTION {|| ABM2ActivarFiltro() } ;
      WIDTH 100 ;
      HEIGHT 32 ;
      FONT _GetSysFont() SIZE 9
   @ 65, ( wndABM2Edit.Width / 2 ) + 5 BUTTON btnFiltro2 ;
      OF wndABM2Edit ;
      CAPTION _HMG_aLangButton[ 11 ] ;
      ACTION {|| ABM2DesactivarFiltro() } ;
      WIDTH 100 ;
      HEIGHT 32 ;
      FONT _GetSysFont() SIZE 9
   @ 132, 20 BROWSE brwABM2Edit ;
      OF wndABM2Edit ;
      WIDTH wndABM2Edit.WIDTH -45 ;
      HEIGHT wndABM2Edit.HEIGHT -195 ;
      HEADERS _aCabeceraTabla ;
      WIDTHS _aAnchoTabla ;
      WORKAREA &_cArea ;
      FIELDS _aCampoTabla ;
      VALUE ( _cArea )->( RecNo() ) ;
      FONT _GetSysFont() SIZE 9 ;
      ON CHANGE {|| ( _cArea )->( dbGoto( wndABM2Edit.brwABM2Edit.Value ) ), ;
      ABM2Redibuja( .F. ) } ;
      ON DBLCLICK {|| iif( wndABM2Edit.tbbEditar.Enabled, ABM2Editar( .F. ), ) } ;
      justify _aAlineadoTabla paintdoublebuffer

   // Comprueba el estado de las opciones de usuario.
   IF Len( _aOpciones ) == 0
      wndABM2Edit.cbOpciones.Enabled := .F.
   ENDIF

   // ------- Activaci�n de la ventana de visualizaci�n.--------------------------
   ACTIVATE WINDOW wndABM2Edit

   // ------- Restauraci�n de SET NAVIGATION.-------------------------------------
   _HMG_ExtendedNavigation := _BakExtendedNavigation

   // ------- Restaurar SET DELETED a su valor inicial
   Set( _SET_DELETED, _BackDeleted )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2salir()
 * Descripci�n: Cierra la ventana de visualizaci�n de registros y sale.
 *  Par�metros: Ninguno.
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2salir( nRegistro, cIndiceActivo, cFiltroAnt, nArea )

   // ------- Restaura el area de la bdd inicial.---------------------------------
   ( _cArea )->( dbGoto( nRegistro ) )
   ( _cArea )->( ordSetFocus( cIndiceActivo ) )
   IF Empty( cFiltroAnt )
      ( _cArea )->( dbClearFilter() )
   ELSE
      ( _cArea )->( dbSetFilter( &( "{||" + cFiltroAnt + "}" ), cFiltroAnt ) )
   ENDIF
   dbSelectArea( nArea )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Redibuja()
 * Descripci�n: Actualizaci�n de la ventana de visualizaci�n de registros.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2Redibuja( lTabla )

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL lDeleted /*as logical*/

   // ------- Control de par�metros.----------------------------------------------
   IF ValType( lTabla ) != "L"
      lTabla := .F.
   ENDIF

   // ------- Refresco de la barra de botones.------------------------------------
   IF ( _cArea )->( RecCount() ) == 0
      wndABM2Edit.tbbEditar.Enabled := .F.
      wndABM2Edit.tbbBorrar.Enabled := .F.
      wndABM2Edit.tbbBuscar.Enabled := .F.
      wndABM2Edit.tbbListado.Enabled := .F.
   ELSE
      lDeleted := Deleted()
      wndABM2Edit.tbbEditar.Enabled := ! lDeleted
      wndABM2Edit.tbbBorrar.Enabled := ! lDeleted
      wndABM2Edit.tbbBuscar.Enabled := .T.
      wndABM2Edit.tbbRecover.Enabled := lDeleted
      wndABM2Edit.tbbListado.Enabled := .T.
   ENDIF

   // ------- Refresco de la barra de estado.-------------------------------------
   wndABM2Edit.StatusBar.Item( 1 ) := _HMG_aLangLabel[ 19 ] + _cFiltro
   wndABM2Edit.StatusBar.Item( 2 ) := _HMG_aLangLabel[ 20 ] + iif( _lFiltro, _HMG_aLangUser[ 29 ], _HMG_aLangUser[ 30 ] )
   wndABM2Edit.StatusBar.Item( 3 ) := _HMG_aLangLabel[ 2 ] + ': ' + ;
      AllTrim( Str( ( _cArea )->( RecNo() ) ) ) + "/" + ;
      AllTrim( Str( ( _cArea )->( RecCount() ) ) )

   // ------- Refresca el browse si se indica.
   IF lTabla
      wndABM2Edit.brwABM2Edit.VALUE := ( _cArea )->( RecNo() )
      wndABM2Edit.brwABM2Edit.Refresh
   ENDIF

   // ------- Coloca el foco en el browse.
   wndABM2Edit.brwABM2Edit.SetFocus

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2CambiarOrden()
 * Descripci�n: Cambia el orden activo.
 *  Par�metros: Ninguno.
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2CambiarOrden()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL nIndice /*as numeric*/ // N�mero del indice.

   // ------- Inicializa las variables.-------------------------------------------
   nIndice := wndABM2Edit.cbIndices.VALUE -1

   // ------- Cambia el orden del area de trabajo.--------------------------------
   ( _cArea )->( ordSetFocus( nIndice ) )
   // (_cArea)->( dbGoTop() )
   _nIndiceActivo := ++nIndice
   ABM2Redibuja( .T. )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EjecutaOpcion()
 * Descripci�n: Ejecuta las opciones del usuario.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2EjecutaOpcion()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL nItem /*as numeric*/ // Numero del item seleccionado.
   LOCAL bBloque as codebloc // Bloque de codigo a ejecutar.

   // ------- Inicializaci�n de variables.----------------------------------------
   nItem := wndABM2Edit.cbOpciones.VALUE
   bBloque := _aOpciones[ nItem, ABM_OPC_BLOQUE ]

   // ------- Ejecuta la opci�n.--------------------------------------------------
   Eval( bBloque )

   // ------- Refresca el browse.
   ABM2Redibuja( .T. )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Editar( lNuevo )
 * Descripci�n: Creaci�n de la ventana de edici�n de registro.
 *  Par�metros: lNuevo          Valor l�gico que indica si se est� a�adiendo un registro
 *                              o editando el actual.
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2Editar( lNuevo )

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL i              as numeric         // Indice de iteraci�n.
   LOCAL nAnchoEtiqueta /*as numeric*/     // Ancho m�ximo de las etiquetas.
   LOCAL nAltoControl   /*as numeric*/     // Alto total de los controles de edici�n.
   LOCAL nAncho         /*as numeric*/     // Ancho de la ventana de edici�n .
   LOCAL nAlto          /*as numeric*/     // Alto de la ventana de edici�n.
   LOCAL nAnchoTope     /*as numeric*/     // Ancho m�ximo de la ventana de edici�n.
   LOCAL nAltoTope      /*as numeric*/     // Alto m�ximo de la ventana de edici�n.
   LOCAL nAnchoSplit    /*as numeric*/     // Ancho de la ventana Split.
   LOCAL nAltoSplit     /*as numeric*/     // Alto de la ventana Split.
   LOCAL cTitulo        as character       // T�tulo de la ventana.
   LOCAL cMascara       as character       // M�scara de edici�n de los controles num�ricos.
   LOCAL nAnchoControl  /*as numeric*/

   // ------- Control de par�metros.----------------------------------------------
   IF ValType( lNuevo ) != "L"
      lNuevo := .T.
   ENDIF

   // ------- Incializaci�n de variables.-----------------------------------------
   nAnchoEtiqueta := 0
   nAnchoControl := 0
   nAltoControl := 0
   FOR i := 1 TO Len( _aEtiqueta )
      nAnchoEtiqueta := iif( nAnchoEtiqueta > _aEtiqueta[ i, ABM_LBL_WIDTH ], ;
         nAnchoEtiqueta, ;
         _aEtiqueta[ i, ABM_LBL_WIDTH ] )
      nAnchoControl := iif( nAnchoControl > _aControl[ i, ABM_CON_WIDTH ], ;
         nAnchoControl, ;
         _aControl[ i, ABM_CON_WIDTH ] )
      nAltoControl += _aControl[ i, ABM_CON_HEIGHT ] + 10
   NEXT
   nAltoSplit := 10 + nAltoControl + 25
   nAnchoSplit := 10 + nAnchoEtiqueta + 10 + nAnchoControl + 25
   nAlto := 80 + nAltoSplit + 15 + iif( _HMG_IsThemed, 10, 0 )
   nAltoTope := _nAltoPantalla - 130
   nAncho := 15 + nAnchoSplit + 15
   nAncho := iif( nAncho < 300, 300, nAncho )
   nAnchoTope := _nAnchoPantalla - 60
   cTitulo := iif( lNuevo, _HMG_aLangLabel[ 6 ], _HMG_aLangLabel[ 7 ] )

   // ------- Define la ventana de edici�n de registro.---------------------------
   DEFINE WINDOW wndABM2EditNuevo ;
         AT 70, 40 ;
         WIDTH iif( nAncho > nAnchoTope, nAnchoTope, nAncho ) ;
         HEIGHT iif( nAlto > nAltoTope, nAltoTope, nAlto ) ;
         TITLE cTitulo ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         FONT _GetSysFont() SIZE 9

      // Define la barra de estado de la ventana de edici�n de registro.
      DEFINE STATUSBAR FONT _GetSysFont() SIZE 9
         STATUSITEM ""
      END STATUSBAR

      DEFINE SPLITBOX

         // Define la barra de botones de la ventana de edici�n de registro.
         DEFINE TOOLBAR tbEditNuevo buttonsize 100, 32 FLAT righttext
            BUTTON tbbCancelar CAPTION _HMG_aLangButton[ 7 ] ;
               PICTURE "MINIGUI_EDIT_CANCEL" ;
               ACTION wndABM2EditNuevo.RELEASE
            BUTTON tbbAceptar CAPTION _HMG_aLangButton[ 8 ] ;
               PICTURE "MINIGUI_EDIT_OK" ;
               ACTION ABM2EditarGuardar( lNuevo )
            BUTTON tbbCopiar CAPTION _HMG_aLangButton[ 9 ] ;
               PICTURE "MINIGUI_EDIT_COPY" ;
               ACTION ABM2EditarCopiar()
         END TOOLBAR

         // Define la ventana donde van contenidos los controles de edici�n.
         DEFINE WINDOW wndABM2EditNuevoSplit ;
               WIDTH iif( nAncho > nAnchoTope, ;
               nAnchoTope - 10, ;
               nAnchoSplit - 1 ) ;
               HEIGHT iif( nAlto > nAltoTope, ;
               nAltoTope - 95, ;
               nAltoSplit - 1 ) ;
               VIRTUAL WIDTH nAnchoSplit ;
               VIRTUAL HEIGHT nAltoSplit ;
               SPLITCHILD ;
               NOCAPTION ;
               FONT _GetSysFont() SIZE 9 ;
               FOCUSED
         END WINDOW
      END SPLITBOX
   END WINDOW

   // ------- Define las etiquetas de los controles.------------------------------
   FOR i := 1 TO Len( _aEtiqueta )

      @ _aEtiqueta[ i, ABM_LBL_ROW ], _aEtiqueta[ i, ABM_LBL_COL ] ;
         LABEL ( _aEtiqueta[ i, ABM_LBL_NAME ] ) ;
         OF wndABM2EditNuevoSplit ;
         VALUE _aNombreCampo[ i ] ;
         WIDTH _aEtiqueta[ i, ABM_LBL_WIDTH ] ;
         HEIGHT _aEtiqueta[ i, ABM_LBL_HEIGHT ] ;
         VCENTERALIGN ;
         FONT _GetSysFont() SIZE 9
   NEXT

   // ------- Define los controles de edici�n.------------------------------------
   FOR i := 1 TO Len( _aControl )
      DO CASE
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_TEXTBOXC

         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ] ;
            TEXTBOX ( _aControl[ i, ABM_CON_NAME ] ) ;
            OF wndABM2EditNuevoSplit ;
            VALUE "" ;
            HEIGHT _aControl[ i, ABM_CON_HEIGHT ] ;
            WIDTH _aControl[ i, ABM_CON_WIDTH ] ;
            FONT "Arial" SIZE 9 ;
            MAXLENGTH _aEstructura[ i, DBS_LEN ] ;
            ON GOTFOCUS ABM2ConFoco() ;
            ON LOSTFOCUS ABM2SinFoco() ;
            ON ENTER ABM2AlEntrar()
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_DATEPICKER
         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ] ;
            DATEPICKER ( _aControl[ i, ABM_CON_NAME ] ) ;
            OF wndABM2EditNuevoSplit ;
            HEIGHT _aControl[ i, ABM_CON_HEIGHT ] ;
            WIDTH _aControl[ i, ABM_CON_WIDTH ] + 25 ;
            FONT "Arial" SIZE 9 ;
            SHOWNONE ;
            ON GOTFOCUS ABM2ConFoco() ;
            ON LOSTFOCUS ABM2SinFoco()
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_TEXTBOXN
         IF _aEstructura[ i, DBS_DEC ] == 0
            @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ] ;
               TEXTBOX ( _aControl[ i, ABM_CON_NAME ] ) ;
               OF wndABM2EditNuevoSplit ;
               VALUE "" ;
               HEIGHT _aControl[ i, ABM_CON_HEIGHT ] ;
               WIDTH _aControl[ i, ABM_CON_WIDTH ] ;
               NUMERIC ;
               FONT "Arial" SIZE 9 ;
               MAXLENGTH _aEstructura[ i, DBS_LEN ] ;
               ON GOTFOCUS ABM2ConFoco( i ) ;
               ON LOSTFOCUS ABM2SinFoco( i ) ;
               ON ENTER ABM2AlEntrar()
         ELSE
            cMascara := Replicate( "9", _aEstructura[ i, DBS_LEN ] - ( _aEstructura[ i, DBS_DEC ] + 1 ) )
            cMascara += "."
            cMascara += Replicate( "9", _aEstructura[ i, DBS_DEC ] )
            @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ] ;
               TEXTBOX ( _aControl[ i, ABM_CON_NAME ] ) ;
               OF wndABM2EditNuevoSplit ;
               VALUE "" ;
               HEIGHT _aControl[ i, ABM_CON_HEIGHT ] ;
               WIDTH _aControl[ i, ABM_CON_WIDTH ] ;
               NUMERIC ;
               INPUTMASK cMascara ;
               ON GOTFOCUS ABM2ConFoco() ;
               ON LOSTFOCUS ABM2SinFoco() ;
               ON ENTER ABM2AlEntrar()
         ENDIF
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_CHECKBOX
         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ] ;
            CHECKBOX ( _aControl[ i, ABM_CON_NAME ] ) ;
            OF wndABM2EditNuevoSplit ;
            CAPTION "" ;
            HEIGHT _aControl[ i, ABM_CON_HEIGHT ] ;
            WIDTH _aControl[ i, ABM_CON_WIDTH ] ;
            VALUE .F. ;
            ON GOTFOCUS ABM2ConFoco() ;
            ON LOSTFOCUS ABM2SinFoco()
      CASE _aControl[ i, ABM_CON_TYPE ] == ABM_EDITBOX
         @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ] ;
            EDITBOX ( _aControl[ i, ABM_CON_NAME ] ) ;
            OF wndABM2EditNuevoSplit ;
            WIDTH _aControl[ i, ABM_CON_WIDTH ] ;
            HEIGHT _aControl[ i, ABM_CON_HEIGHT ] ;
            VALUE "" ;
            FONT "Arial" SIZE 9 ;
            ON GOTFOCUS ABM2ConFoco() ;
            ON LOSTFOCUS ABM2SinFoco()
      ENDCASE
   NEXT

   // ------- Actualiza los controles si se est� editando.------------------------
   if ! lNuevo
      FOR i := 1 TO Len( _aControl )
         SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value", ( _cArea )->( FieldGet( i ) ) )
      NEXT
   ENDIF

   // ------- Establece el estado inicial de los controles.-----------------------
   FOR i := 1 TO Len( _aControl )
      SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Enabled", _aEditable[ i ] )
   NEXT

   // ------- Establece el estado del bot�n de copia.-----------------------------
   if ! lNuevo
      wndABM2EditNuevo.tbbCopiar.Enabled := .F.
   ENDIF

   // ------- Activa la ventana de edici�n de registro.---------------------------
   ON KEY ESCAPE ;
      OF wndABM2EditNuevoSplit ;
      ACTION wndABM2EditNuevo.tbbCancelar.onclick

   ON KEY RETURN ;
      OF wndABM2EditNuevoSplit ;
      ACTION wndABM2EditNuevo.tbbAceptar.onclick

   ACTIVATE WINDOW wndABM2EditNuevo

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2ConFoco()
 * Descripci�n: Actualiza las etiquetas de los controles y presenta los mensajes en la
 *              barra de estado de la ventana de edici�n de registro al obtener un
 *              control de edici�n el foco.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2ConFoco()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL i /*as numeric*/ // Indice de iteraci�n.
   LOCAL cControl as character // Nombre del control activo.
   LOCAL acControl /*as array*/ // Matriz con los nombre de los controles.

   // ------- Inicializaci�n de variables.----------------------------------------
   cControl := This.NAME
   acControl := {}
   FOR i := 1 TO Len( _aControl )
      AAdd( acControl, _aControl[ i, ABM_CON_NAME ] )
   NEXT
   _nControlActivo := AScan( acControl, cControl )

   // ------- Pone la etiqueta en negrita.----------------------------------------
   SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .T. )

   // ------- Presenta el mensaje en la barra de estado.--------------------------
   wndABM2EditNuevo.StatusBar.Item( 1 ) := _aControl[ _nControlActivo, ABM_CON_DES ]

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2SinFoco()
 * Descripci�n: Restaura el estado de las etiquetas y de la barra de estado de la ventana
 *              de edici�n de registros al dejar un control de edici�n sin foco.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2SinFoco()

   // ------- Restaura el estado de la etiqueta.----------------------------------
   SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .F. )

   // ------- Restaura el texto de la barra de estado.----------------------------
   wndABM2EditNuevo.StatusBar.Item( 1 ) := ""

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2AlEntrar()
 * Descripci�n: Cambia al siguiente control de edici�n tipo TEXTBOX al pulsar la tecla
 *              ENTER.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2AlEntrar()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL lSalida /*as logical*/ // Tipo de salida.
   LOCAL nTipo /*as numeric*/ // Tipo del control.

   // ------- Inicializa las variables.-------------------------------------------
   lSalida := .T.

   // ------- Restaura el estado de la etiqueta.----------------------------------
   SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .F. )

   // ------- Activa el siguiente control editable con evento ON ENTER.-----------
   DO WHILE lSalida
      _nControlActivo++
      IF _nControlActivo > Len( _aControl )
         _nControlActivo := 1
      ENDIF
      nTipo := _aControl[ _nControlActivo, ABM_CON_TYPE ]
      IF nTipo == ABM_TEXTBOXC .OR. nTipo == ABM_TEXTBOXN
         IF _aEditable[ _nControlActivo ]
            lSalida := .F.
         ENDIF
      ENDIF
   ENDDO

   DoMethod( "wndABM2EditNuevoSplit", _aControl[ _nControlActivo, ABM_CON_NAME ], "SetFocus" )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EditarGuardar( lNuevo )
 * Descripci�n: A�ade o guarda el registro en la bdd.
 *  Par�metros: lNuevo          Valor l�gico que indica si se est� a�adiendo un registro
 *                              o editando el actual.
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2EditarGuardar( lNuevo )

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL i /*as numeric*/ // Indice de iteraci�n.
   LOCAL xValor // Valor a guardar.
   LOCAL lResultado /*as logical*/ // Resultado del bloque del usuario.
   LOCAL aValores /*as array*/ // Valores del registro.

   // ------- Guarda el registro.-------------------------------------------------
   IF _bGuardar == NIL

      // No hay bloque de c�digo del usuario.
      IF lNuevo
         ( _cArea )->( dbAppend() )
      ENDIF

      IF ( _cArea )->( RLock() )

         FOR i := 1 TO Len( _aEstructura )
            xValor := GetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value" )
            ( _cArea )->( FieldPut( i, xValor ) )
         NEXT

         ( _cArea )->( dbUnlock() )

         // Refresca la ventana de visualizaci�n.
         wndABM2EditNuevo.RELEASE
         ABM2Redibuja( .T. )

      ELSE
         Msgstop ( _HMG_aLangUser[ 41 ], _cTitulo )
      ENDIF
   ELSE

      // Hay bloque de c�digo del usuario.
      aValores := {}
      FOR i := 1 TO Len( _aControl )
         xValor := GetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value" )
         AAdd( aValores, xValor )
      NEXT
      lResultado := Eval( _bGuardar, aValores, lNuevo )
      IF ValType( lResultado ) != "L"
         lResultado := .T.
      ENDIF

      // Refresca la ventana de visualizaci�n.
      IF lResultado
         wndABM2EditNuevo.RELEASE
         ABM2Redibuja( .T. )
      ENDIF
   ENDIF

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Seleccionar()
 * Descripci�n: Presenta una ventana para la selecci�n de un registro.
 *  Par�metros: Ninguno
 *    Devuelve: [nReg]          Numero de registro seleccionado, o cero si no se ha
 *                              seleccionado ninguno.
****************************************************************************************/
STATIC FUNCTION ABM2Seleccionar()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL lSalida as logical // Control de bucle.
   LOCAL nReg as numeric // Valores del registro
   LOCAL nRegistro /*as numeric*/ // N�mero de registro.

   // ------- Inicializaci�n de variables.----------------------------------------
   lSalida := .F.
   nReg := 0
   nRegistro := ( _cArea )->( RecNo() )

   // ------- Se situa en el primer registro.-------------------------------------
   ( _cArea )->( dbGoTop() )

   // ------- Creaci�n de la ventana de selecci�n de registro.--------------------
   DEFINE WINDOW wndSeleccionar ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 300 ;
         TITLE _HMG_aLangLabel[ 8 ] ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         FONT _GetSysFont() SIZE 9

      // Define la barra de botones de la ventana de selecci�n.
      DEFINE TOOLBAR tbSeleccionar buttonsize 100, 32 FLAT righttext BORDER
         BUTTON tbbCancelarSel CAPTION _HMG_aLangButton[ 7 ] ;
            PICTURE "MINIGUI_EDIT_CANCEL" ;
            ACTION {|| lSalida := .F., ;
            nReg := 0, ;
            wndSeleccionar.Release }
         BUTTON tbbAceptarSel CAPTION _HMG_aLangButton[ 8 ] ;
            PICTURE "MINIGUI_EDIT_OK" ;
            ACTION {|| lSalida := .T., ;
            nReg := wndSeleccionar.brwSeleccionar.VALUE, ;
            wndSeleccionar.Release }
      END TOOLBAR

      // Define la barra de estado de la ventana de selecci�n.
      DEFINE STATUSBAR FONT _GetSysFont() SIZE 9
         STATUSITEM _HMG_aLangUser[ 7 ]
      END STATUSBAR

      // Define la tabla de la ventana de selecci�n.
      @ 55, 20 BROWSE brwSeleccionar ;
         WIDTH 460 ;
         HEIGHT 190 ;
         HEADERS _aCabeceraTabla ;
         WIDTHS _aAnchoTabla ;
         WORKAREA &_cArea ;
         FIELDS _aCampoTabla ;
         VALUE ( _cArea )->( RecNo() ) ;
         FONT "Arial" SIZE 9 ;
         ON DBLCLICK {|| lSalida := .T., ;
         nReg := wndSeleccionar.brwSeleccionar.VALUE, ;
         wndSeleccionar.Release } ;
         justify _aAlineadoTabla paintdoublebuffer

   END WINDOW

   // ------- Activa la ventana de selecci�n de registro.-------------------------
   CENTER WINDOW wndSeleccionar
   ACTIVATE WINDOW wndSeleccionar

   // ------- Restuara el puntero de registro.------------------------------------
   ( _cArea )->( dbGoto( nRegistro ) )

RETURN ( nReg )


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EditarCopiar()
 * Descripci�n: Copia el registro seleccionado en los controles de edici�n del nuevo
 *              registro.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2EditarCopiar()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL i /*as numeric*/ // Indice de iteraci�n.
   LOCAL nRegistro /*as numeric*/ // Puntero de registro.
   LOCAL nReg /*as numeric*/ // Numero de registro.

   // ------- Obtiene el registro a copiar.---------------------------------------
   nReg := ABM2Seleccionar()

   // ------- Actualiza los controles de edici�n.---------------------------------
   IF nReg != 0
      nRegistro := ( _cArea )->( RecNo() )
      ( _cArea )->( dbGoto( nReg ) )
      FOR i := 1 TO Len( _aControl )
         IF _aEditable[ i ]
            SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value", ( _cArea )->( FieldGet( i ) ) )
         ENDIF
      NEXT
      ( _cArea )->( dbGoto( nRegistro ) )
   ENDIF

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Borrar()
 * Descripci�n: Borra el registro activo.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2Borrar()

   // ------- Borra el registro si se acepta.-------------------------------------
   IF MsgOKCancel( _HMG_aLangUser[ 8 ], _HMG_aLangLabel[ 16 ] )
      IF ( _cArea )->( RLock() )
         ( _cArea )->( dbDelete() )
         ( _cArea )->( dbCommit() )
         ( _cArea )->( dbUnlock() )
         IF Set( _SET_DELETED )
            ( _cArea )->( dbSkip() )
            IF ( _cArea )->( Eof() )
               ( _cArea )->( dbGoBottom() )
            ENDIF
         ENDIF
         ABM2Redibuja( .T. )
      ELSE
         Msgstop( _HMG_aLangUser[ 41 ], _cTitulo )
      ENDIF
   ENDIF

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Recover()
 * Descripci�n: Restaurar el registro activo.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2Recover()

   // ------- Restaurar el registro si se acepta.-----------------------------------
   IF MsgOKCancel( _HMG_aLangUser[ 42 ], StrTran( _HMG_aLangButton[ 12 ], "&", "" ) )
      IF ( _cArea )->( RLock() )
         ( _cArea )->( dbRecall() )
         ( _cArea )->( dbCommit() )
         ( _cArea )->( dbUnlock() )
         ABM2Redibuja( .T. )
      ELSE
         Msgstop( _HMG_aLangUser[ 41 ], _cTitulo )
      ENDIF
   ENDIF

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Buscar()
 * Descripci�n: Busca un registro por la clave del indice activo.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2Buscar()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL nControl /*as numeric*/ // Numero del control.
   LOCAL lSalida as logical // Tipo de salida de la ventana.
   LOCAL xValor // Valor de busqueda.
   LOCAL cMascara as character // Mascara de edici�n del control.
   LOCAL lResultado /*as logical*/ // Resultado de la busqueda.
   LOCAL nRegistro /*as numeric*/ // Numero de registro.

   // ------- Inicializaci�n de variables.----------------------------------------
   nControl := _aIndiceCampo[ _nIndiceActivo ]

   // ------- Comprueba si se ha pasado una acci�n del usuario.--------------------
   IF _bBuscar != NIL
      // msgInfo( "ON FIND" )
      Eval( _bBuscar )
      ABM2Redibuja( .T. )
      RETURN NIL
   ENDIF

   // ------- Comprueba si hay un indice activo.----------------------------------
   IF _nIndiceActivo == 1
      msgExclamation( _HMG_aLangUser[ 9 ], _cTitulo )
      RETURN NIL
   ENDIF

   // ------- Comprueba que el campo indice no es del tipo memo o logico.---------
   IF _aEstructura[ nControl, DBS_TYPE ] == "L" .OR. _aEstructura[ nControl, DBS_TYPE ] == "M"
      msgExclamation( _HMG_aLangUser[ 10 ], _cTitulo )
      RETURN NIL
   ENDIF

   // ------- Crea la ventana de busqueda.----------------------------------------
   DEFINE WINDOW wndABMBuscar ;
         AT 0, 0 ;
         WIDTH 500 ;
         HEIGHT 170 ;
         TITLE _HMG_aLangLabel[ 9 ] ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         FONT _GetSysFont() SIZE 9

      // Define la barra de botones de la ventana de busqueda.
      DEFINE TOOLBAR tbBuscar buttonsize 100, 32 FLAT righttext BORDER
         BUTTON tbbCancelarBus CAPTION _HMG_aLangButton[ 7 ] ;
            PICTURE "MINIGUI_EDIT_CANCEL" ;
            ACTION {|| lSalida := .F., ;
            xValor := wndABMBuscar .conBuscar.VALUE, ;
            wndABMBuscar.Release }
         BUTTON tbbAceptarBus CAPTION _HMG_aLangButton[ 8 ] ;
            PICTURE "MINIGUI_EDIT_OK" ;
            ACTION {|| lSalida := .T., ;
            xValor := wndABMBuscar .conBuscar.VALUE, ;
            wndABMBuscar.Release }
      END TOOLBAR

      // Define la barra de estado de la ventana de busqueda.
      DEFINE STATUSBAR FONT _GetSysFont() SIZE 9
         STATUSITEM ""
      END STATUSBAR
   END WINDOW

   // ------- Crea los controles de la ventana de busqueda.-----------------------
   // Frame.
   @ 45, 10 FRAME frmBuscar ;
      OF wndABMBuscar ;
      CAPTION "" ;
      WIDTH wndABMBuscar.WIDTH -25 ;
      HEIGHT wndABMBuscar.HEIGHT -100

   // Etiqueta.
   @ 60, 20 LABEL lblBuscar ;
      OF wndABMBuscar ;
      VALUE _aNombreCampo[ nControl ] ;
      WIDTH _aEtiqueta[ nControl, ABM_LBL_WIDTH ] ;
      HEIGHT _aEtiqueta[ nControl, ABM_LBL_HEIGHT ] ;
      FONT _GetSysFont() SIZE 9

   // Tipo de dato a buscar.
   DO CASE

      // Car�cter.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXC
      @ 75, 20 TEXTBOX conBuscar ;
         OF wndABMBuscar ;
         VALUE "" ;
         HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
         WIDTH _aControl[ nControl, ABM_CON_WIDTH ] ;
         FONT "Arial" SIZE 9 ;
         MAXLENGTH _aEstructura[ nControl, DBS_LEN ]

      // Fecha.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_DATEPICKER
      @ 75, 20 DATEPICKER conBuscar ;
         OF wndABMBuscar ;
         VALUE Date() ;
         HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
         WIDTH _aControl[ nControl, ABM_CON_WIDTH ] + 25 ;
         FONT "Arial" SIZE 9

      // Numerico.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXN
      IF _aEstructura[ nControl, DBS_DEC ] == 0

         // Sin decimales.
         @ 75, 20 TEXTBOX conBuscar ;
            OF wndABMBuscar ;
            VALUE "" ;
            HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
            WIDTH _aControl[ nControl, ABM_CON_WIDTH ] ;
            NUMERIC ;
            FONT "Arial" SIZE 9 ;
            MAXLENGTH _aEstructura[ nControl, DBS_LEN ]
      ELSE

         // Con decimales.
         cMascara := Replicate( "9", _aEstructura[ nControl, DBS_LEN ] - ( _aEstructura[ nControl, DBS_DEC ] + 1 ) )
         cMascara += "."
         cMascara += Replicate( "9", _aEstructura[ nControl, DBS_DEC ] )
         @ 75, 20 TEXTBOX conBuscar ;
            OF wndABMBuscar ;
            VALUE "" ;
            HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
            WIDTH _aControl[ nControl, ABM_CON_WIDTH ] ;
            NUMERIC ;
            INPUTMASK cMascara
      ENDIF
   ENDCASE

   // ------- Actualiza la barra de estado.---------------------------------------
   wndABMBuscar.StatusBar.Item( 1 ) := _aControl[ nControl, ABM_CON_DES ]

   // ------- Comprueba el tama�o del control de edici�n del dato a buscar.-------
   IF wndABMBuscar .conBuscar. Width > wndABM2Edit.WIDTH -45
      wndABMBuscar .conBuscar. WIDTH := wndABM2Edit.WIDTH -45
   ENDIF

   // ------- Activa la ventana de busqueda.--------------------------------------
   ON KEY ESCAPE ;
      OF wndABMBuscar ;
      ACTION wndABMBuscar.tbbCancelarBus.onclick

   ON KEY RETURN ;
      OF wndABMBuscar ;
      ACTION wndABMBuscar.tbbAceptarBus.onclick

   CENTER WINDOW wndABMBuscar
   ACTIVATE WINDOW wndABMBuscar

   // ------- Busca el registro.--------------------------------------------------
   IF lSalida
      nRegistro := ( _cArea )->( RecNo() )
      lResultado := ( _cArea )->( dbSeek( xValor ) )
      if ! lResultado
         msgExclamation( _HMG_aLangUser[ 11 ], _cTitulo )
         ( _cArea )->( dbGoto( nRegistro ) )
      ELSE
         ABM2Redibuja( .T. )
      ENDIF
   ENDIF

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2ActivarFiltro()
 * Descripci�n: Filtra la base de datos.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2ActivarFiltro()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL aCompara /*as array*/ // Comparaciones.
   LOCAL aCampos /*as array*/ // Nombre de los campos.

   // ------- Comprueba que no hay ningun filtro activo.--------------------------
   IF _cFiltro != ""
      MsgInfo( _HMG_aLangUser[ 34 ], '' )
   ENDIF

   // ------- Inicializaci�n de variables.----------------------------------------
   aCampos := _aNombreCampo
   aCompara := { _HMG_aLangLabel[ 27 ], ;
      _HMG_aLangLabel[ 28 ], ;
      _HMG_aLangLabel[ 29 ], ;
      _HMG_aLangLabel[ 30 ], ;
      _HMG_aLangLabel[ 31 ], ;
      _HMG_aLangLabel[ 32 ] }


   // ------- Crea la ventana de filtrado.----------------------------------------
   DEFINE WINDOW wndABM2Filtro ;
         AT 0, 0 ;
         WIDTH 400 ;
         HEIGHT 325 ;
         TITLE _HMG_aLangLabel[ 21 ] ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         ON INIT {|| ABM2ControlFiltro() } ;
         FONT _GetSysFont() SIZE 9

      // Define la barra de botones de la ventana de filtrado.
      DEFINE TOOLBAR tbBuscar buttonsize 100, 32 FLAT righttext BORDER
         BUTTON tbbCancelarFil CAPTION _HMG_aLangButton[ 7 ] ;
            PICTURE "MINIGUI_EDIT_CANCEL" ;
            ACTION {|| wndABM2Filtro.RELEASE, ;
            ABM2Redibuja( .F. ) }
         BUTTON tbbAceptarFil CAPTION _HMG_aLangButton[ 8 ] ;
            PICTURE "MINIGUI_EDIT_OK" ;
            ACTION {|| ABM2EstableceFiltro() }
      END TOOLBAR

      // Define la barra de estado de la ventana de filtrado.
      DEFINE STATUSBAR FONT _GetSysFont() SIZE 9
         STATUSITEM ""
      END STATUSBAR
   END WINDOW

   // ------- Controles de la ventana de filtrado.
   // Frame.
   @ 45, 10 FRAME frmFiltro ;
      OF wndABM2Filtro ;
      CAPTION "" ;
      WIDTH wndABM2Filtro.WIDTH -25 ;
      HEIGHT wndABM2Filtro.HEIGHT -100
   @ 65, 20 LABEL lblCampos ;
      OF wndABM2Filtro ;
      VALUE _HMG_aLangLabel[ 22 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9
   @ 65, 220 LABEL lblCompara ;
      OF wndABM2Filtro ;
      VALUE _HMG_aLangLabel[ 23 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9
   @ 200, 20 LABEL lblValor ;
      OF wndABM2Filtro ;
      VALUE _HMG_aLangLabel[ 24 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9
   @ 85, 20 LISTBOX lbxCampos ;
      OF wndABM2Filtro ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCampos ;
      VALUE 1 ;
      FONT "Arial" SIZE 9 ;
      ON CHANGE {|| ABM2ControlFiltro() } ;
      ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := _HMG_aLangLabel[ 25 ] ;
      ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""
   @ 85, 220 LISTBOX lbxCompara ;
      OF wndABM2Filtro ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCompara ;
      VALUE 1 ;
      FONT "Arial" SIZE 9 ;
      ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := _HMG_aLangLabel[ 26 ] ;
      ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""
   @ 220, 20 TEXTBOX conValor ;
      OF wndABM2Filtro ;
      VALUE "" ;
      HEIGHT 25 ;
      WIDTH 160 ;
      FONT "Arial" SIZE 9 ;
      MAXLENGTH 16

   // ------- Activa la ventana.
   CENTER WINDOW wndABM2Filtro
   ACTIVATE WINDOW wndABM2Filtro

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2ControlFiltro()
 * Descripci�n: Comprueba que el filtro se puede aplicar.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2ControlFiltro()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL nControl /*as numeric*/
   LOCAL cMascara as character
   LOCAL cMensaje as character

   // ------- Inicializa las variables.
   nControl := wndABM2Filtro.lbxCampos.VALUE

   // ------- Comprueba que se puede crear el control.----------------------------
   IF _aEstructura[ nControl, DBS_TYPE ] == "M"
      msgExclamation( _HMG_aLangUser[ 35 ], _cTitulo )
      RETURN NIL
   ENDIF
   IF nControl == 0
      msgExclamation( _HMG_aLangUser[ 36 ], _cTitulo )
      RETURN NIL
   ENDIF

   // ------- Crea el nuevo control.----------------------------------------------
   wndABM2Filtro.conValor.RELEASE
   cMensaje := _aControl[ nControl, ABM_CON_DES ]
   DO CASE

      // Car�cter.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXC
      @ 226, 20 TEXTBOX conValor ;
         OF wndABM2Filtro ;
         VALUE "" ;
         HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
         WIDTH _aControl[ nControl, ABM_CON_WIDTH ] ;
         FONT "Arial" SIZE 9 ;
         MAXLENGTH _aEstructura[ nControl, DBS_LEN ] ;
         ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ;
         cMensaje ;
         ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

      // Fecha.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_DATEPICKER
      @ 226, 20 DATEPICKER conValor ;
         OF wndABM2Filtro ;
         VALUE Date() ;
         HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
         WIDTH _aControl[ nControl, ABM_CON_WIDTH ] + 25 ;
         FONT "Arial" SIZE 9 ;
         ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ;
         cMensaje ;
         ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

      // Numerico.
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXN
      IF _aEstructura[ nControl, DBS_DEC ] == 0

         // Sin decimales.
         @ 226, 20 TEXTBOX conValor ;
            OF wndABM2Filtro ;
            VALUE "" ;
            HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
            WIDTH _aControl[ nControl, ABM_CON_WIDTH ] ;
            NUMERIC ;
            FONT "Arial" SIZE 9 ;
            MAXLENGTH _aEstructura[ nControl, DBS_LEN ] ;
            ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ;
            cMensaje ;
            ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

      ELSE

         // Con decimales.
         cMascara := Replicate( "9", _aEstructura[ nControl, DBS_LEN ] - ( _aEstructura[ nControl, DBS_DEC ] + 1 ) )
         cMascara += "."
         cMascara += Replicate( "9", _aEstructura[ nControl, DBS_DEC ] )
         @ 226, 20 TEXTBOX conValor ;
            OF wndABM2Filtro ;
            VALUE "" ;
            HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
            WIDTH _aControl[ nControl, ABM_CON_WIDTH ] ;
            NUMERIC ;
            INPUTMASK cMascara ;
            ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ;
            cMensaje ;
            ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""
      ENDIF

      // Logico
   CASE _aControl[ nControl, ABM_CON_TYPE ] == ABM_CHECKBOX
      @ 226, 20 CHECKBOX conValor ;
         OF wndABM2Filtro ;
         CAPTION "" ;
         HEIGHT _aControl[ nControl, ABM_CON_HEIGHT ] ;
         WIDTH _aControl[ nControl, ABM_CON_WIDTH ] ;
         VALUE .F. ;
         ON GOTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ;
         cMensaje ;
         ON LOSTFOCUS wndABM2Filtro.StatusBar.Item( 1 ) := ""

   ENDCASE

   // ------- Actualiza el valor de la etiqueta.----------------------------------
   wndABM2Filtro .lblValor.VALUE := _aNombreCampo[ nControl ]

   // ------- Comprueba el tama�o del control de edici�n del dato a buscar.-------
   IF wndABM2Filtro.conValor.Width > wndABM2Filtro.WIDTH -45
      wndABM2Filtro.conValor.WIDTH := wndABM2Filtro.WIDTH -45
   ENDIF

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EstableceFiltro()
 * Descripci�n: Establece el filtro seleccionado.
 *  Par�metros: Ninguno.
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2EstableceFiltro()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL aOperador /*as array*/
   LOCAL nCampo /*as numeric*/
   LOCAL nCompara /*as numeric*/
   LOCAL cValor as character

   // ------- Inicializaci�n de variables.----------------------------------------
   nCompara := wndABM2Filtro.lbxCompara.VALUE
   nCampo := wndABM2Filtro.lbxCampos.VALUE
   cValor := hb_ValToStr( wndABM2Filtro.conValor.Value )
   aOperador := { "=", "<>", ">", "<", ">=", "<=" }

   // ------- Comprueba que se puede filtrar.-------------------------------------
   IF nCompara == 0
      msgExclamation( _HMG_aLangUser[ 37 ], _cTitulo )
      RETURN NIL
   ENDIF
   IF nCampo == 0
      msgExclamation( _HMG_aLangUser[ 36 ], _cTitulo )
      RETURN NIL
   ENDIF
   IF cValor == ""
      msgExclamation( _HMG_aLangUser[ 38 ], _cTitulo )
      RETURN NIL
   ENDIF
   IF _aEstructura[ nCampo, DBS_TYPE ] == "M"
      msgExclamation( _HMG_aLangUser[ 35 ], _cTitulo )
      RETURN NIL
   ENDIF

   // ------- Establece el filtro.------------------------------------------------
   DO CASE
   CASE _aEstructura[ nCampo, DBS_TYPE ] == "C"
      _cFiltro := "Upper(" + _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ")" + ;
         aOperador[ nCompara ]
      _cFiltro += "'" + Upper( AllTrim( cValor ) ) + "'"

   CASE _aEstructura[ nCampo, DBS_TYPE ] == "N"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ;
         aOperador[ nCompara ]
      _cFiltro += AllTrim( cValor )

   CASE _aEstructura[ nCampo, DBS_TYPE ] == "D"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ;
         aOperador[ nCompara ]
      _cFiltro += "CToD(" + "'" + cValor + "')"

   CASE _aEstructura[ nCampo, DBS_TYPE ] == "L"
      _cFiltro := _cArea + "->" + ;
         _aEstructura[ nCampo, DBS_NAME ] + ;
         aOperador[ nCompara ]
      _cFiltro += cValor
   ENDCASE
   ( _cArea )->( dbSetFilter( {|| &_cFiltro }, _cFiltro ) )
   _lFiltro := .T.
   wndABM2Filtro.RELEASE
   ABM2Redibuja( .T. )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2DesactivarFiltro()
 * Descripci�n: Desactiva el filtro si procede.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2DesactivarFiltro()

   // ------- Desactiva el filtro si procede.
   if ! _lFiltro
      msgExclamation( _HMG_aLangUser[ 39 ], _cTitulo )
      ABM2Redibuja( .F. )
      RETURN NIL
   ENDIF
   IF msgYesNo( _HMG_aLangUser[ 40 ], _cTitulo )
      ( _cArea )->( dbClearFilter( NIL ) )
      _lFiltro := .F.
      _cFiltro := ""
      ABM2Redibuja( .T. )
   ENDIF

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Imprimir()
 * Descripci�n: Presenta la ventana de recogida de datos para la definici�n del listado.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2Imprimir()

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL aCampoBase /*as array*/ // Campos de la bdd.
   LOCAL aCampoListado /*as array*/ // Campos del listado.
   LOCAL nRegistro /*as numeric*/ // Numero de registro actual.
   LOCAL nCampo /*as numeric*/ // Numero de campo.
   LOCAL cRegistro1 as character // Valor del registro inicial.
   LOCAL cRegistro2 as character // Valor del registro final.
   LOCAL aImpresoras as array // Impresoras disponibles.

   // ------- Comprueba si se ha pasado la clausula ON PRINT.---------------------
   IF _bImprimir != NIL
      // msgInfo( "ON PRINT" )
      Eval( _bImprimir )
      ABM2Redibuja( .T. )
      RETURN NIL
   ENDIF

   // ------- Obtiene las impresoras disponibles.---------------------------------
   aImpresoras := {}
   INIT PRINTSYS
   GET PRINTERS TO aImpresoras
   RELEASE PRINTSYS

   // ------- Comprueba que hay un indice activo.---------------------------------
   IF _nIndiceActivo == 1
      msgExclamation( _HMG_aLangUser[ 9 ], _cTitulo )
      RETURN NIL
   ENDIF

   // ------- Inicializaci�n de variables.----------------------------------------
   aCampoListado := {}
   aCampoBase := _aNombreCampo
   SET DELETED ON
   nRegistro := ( _cArea )->( RecNo() )
   IF ( _cArea )->( Deleted() )
      ( _cArea )->( dbSkip() )
   ENDIF

   // Registro inicial y final.
   nCampo := _aIndiceCampo[ _nIndiceActivo ]
   ( _cArea )->( dbGoTop() )
   cRegistro1 := hb_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
   ( _cArea )->( dbGoBottom() )
   cRegistro2 := hb_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
   ( _cArea )->( dbGoto( nRegistro ) )

   // ------- Definici�n de la ventana de formato de listado.---------------------
   DEFINE WINDOW wndABM2Listado ;
         AT 0, 0 ;
         WIDTH 390 ;
         HEIGHT 365 ;
         TITLE _HMG_aLangLabel[ 10 ] ;
         ICON "MINIGUI_EDIT_PRINT" ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         FONT _GetSysFont() SIZE 9

      // Define la barra de botones de la ventana de formato de listado.
      DEFINE TOOLBAR tbListado buttonsize 100, 32 FLAT righttext BORDER
         BUTTON tbbCancelarLis CAPTION _HMG_aLangButton[ 7 ] ;
            PICTURE "MINIGUI_EDIT_CANCEL" ;
            ACTION wndABM2Listado.RELEASE
         BUTTON tbbAceptarLis CAPTION _HMG_aLangButton[ 8 ] ;
            PICTURE "MINIGUI_EDIT_OK" ;
            ACTION ABM2Listado( aImpresoras )

      END TOOLBAR

      // Define la barra de estado de la ventana de formato de listado.
      DEFINE STATUSBAR FONT _GetSysFont() SIZE 9
         STATUSITEM ""
      END STATUSBAR
   END WINDOW

   // ------- Define los controles de edici�n de la ventana de formato de listado.-
   // Frame.
   @ 45, 10 FRAME frmListado ;
      OF wndABM2Listado ;
      CAPTION "" ;
      WIDTH wndABM2Listado.WIDTH -25 ;
      HEIGHT wndABM2Listado.HEIGHT -100

   // Label
   @ 65, 20 LABEL lblCampoBase ;
      OF wndABM2Listado ;
      VALUE _HMG_aLangLabel[ 11 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9
   @ 65, 220 LABEL lblCampoListado ;
      OF wndABM2Listado ;
      VALUE _HMG_aLangLabel[ 12 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9
   @ 200, 20 LABEL lblImpresoras ;
      OF wndABM2Listado ;
      VALUE _HMG_aLangLabel[ 13 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9
   @ 200, 170 LABEL lblInicial ;
      OF wndABM2Listado ;
      VALUE _HMG_aLangLabel[ 14 ] ;
      WIDTH 160 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9
   @ 255, 170 LABEL lblFinal ;
      OF wndABM2Listado ;
      VALUE _HMG_aLangLabel[ 15 ] ;
      WIDTH 160 ;
      HEIGHT 25 ;
      FONT _GetSysFont() SIZE 9

   // Listbox.
   @ 85, 20 LISTBOX lbxCampoBase ;
      OF wndABM2Listado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCampoBase ;
      VALUE 1 ;
      FONT "Arial" SIZE 9 ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_aLangUser[ 12 ] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 85, 220 LISTBOX lbxCampoListado ;
      OF wndABM2Listado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCampoListado ;
      VALUE 1 ;
      FONT "Arial" SIZE 9 ;
      ON gotFocus wndABM2Listado.StatusBar.Item( 1 ) := _HMG_aLangUser[ 13 ] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""

   // ComboBox.
   @ 220, 20 COMBOBOX cbxImpresoras ;
      OF wndABM2Listado ;
      ITEMS aImpresoras ;
      VALUE 1 ;
      WIDTH 140 ;
      FONT "Arial" SIZE 9 ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_aLangUser[ 14 ] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""

   // PicButton.
   @ 90, 170 BUTTON btnMas ;
      OF wndABM2Listado ;
      PICTURE "MINIGUI_EDIT_ADD" ;
      ACTION ABM2DefinirColumnas( ABM_LIS_ADD ) ;
      WIDTH 40 ;
      HEIGHT 40 ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_aLangUser[ 15 ] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 140, 170 BUTTON btnMenos ;
      OF wndABM2Listado ;
      PICTURE "MINIGUI_EDIT_DEL" ;
      ACTION ABM2DefinirColumnas( ABM_LIS_DEL ) ;
      WIDTH 40 ;
      HEIGHT 40 ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_aLangUser[ 16 ] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 220, 170 BUTTON btnSet1 ;
      OF wndABM2Listado ;
      PICTURE "MINIGUI_EDIT_SET" ;
      ACTION ABM2DefinirRegistro( ABM_LIS_SET1 ) ;
      WIDTH 25 ;
      HEIGHT 25 ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_aLangUser[ 17 ] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""
   @ 275, 170 BUTTON btnSet2 ;
      OF wndABM2Listado ;
      PICTURE "MINIGUI_EDIT_SET" ;
      ACTION ABM2DefinirRegistro( ABM_LIS_SET2 ) ;
      WIDTH 25 ;
      HEIGHT 25 ;
      ON GOTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := _HMG_aLangUser[ 18 ] ;
      ON LOSTFOCUS wndABM2Listado.StatusBar.Item( 1 ) := ""

   // CheckBox.
   @ 255, 20 CHECKBOX chkVistas ;
      OF wndABM2Listado ;
      CAPTION _HMG_aLangLabel[ 18 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      VALUE .T. ;
      FONT _GetSysFont() SIZE 9
   @ 275, 20 CHECKBOX chkPrevio ;
      OF wndABM2Listado ;
      CAPTION _HMG_aLangLabel[ 17 ] ;
      WIDTH 140 ;
      HEIGHT 25 ;
      VALUE .T. ;
      FONT _GetSysFont() SIZE 9

   // Editbox.
   @ 220, 196 TEXTBOX txtRegistro1 ;
      OF wndABM2Listado ;
      VALUE cRegistro1 ;
      HEIGHT 25 ;
      WIDTH 160 ;
      FONT "Arial" SIZE 9 ;
      MAXLENGTH 16
   @ 275, 196 TEXTBOX txtRegistro2 ;
      OF wndABM2Listado ;
      VALUE cRegistro2 ;
      HEIGHT 25 ;
      WIDTH 160 ;
      FONT "Arial" SIZE 9 ;
      MAXLENGTH 16

   // ------- Estado de los controles.--------------------------------------------
   wndABM2Listado .txtRegistro1.Enabled := .F.
   wndABM2Listado .txtRegistro2.Enabled := .F.

   // ------- Comrprueba que la selecci�n de registros es posible.----------------
   nCampo := _aIndiceCampo[ _nIndiceActivo ]
   IF _aEstructura[ nCampo, DBS_TYPE ] == "L" .OR. _aEstructura[ nCampo, DBS_TYPE ] == "M"
      wndABM2Listado .btnSet1.Enabled := .F.
      wndABM2Listado .btnSet2.Enabled := .F.
   ENDIF

   // ------- Activaci�n de la ventana de formato de listado.---------------------
   CENTER WINDOW wndABM2Listado
   ACTIVATE WINDOW wndABM2Listado

   // ------- Restaura.-----------------------------------------------------------
   SET DELETED OFF
   ( _cArea )->( dbGoto( nRegistro ) )
   ABM2Redibuja( .F. )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2DefinirRegistro( nAccion )
 * Descripci�n:
 *  Par�metros: [nAccion]       Numerico. Indica el tipo de accion realizado.
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2DefinirRegistro( nAccion )

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL nRegistro as character // Puntero de registros.
   LOCAL nReg as character // Registro seleccionado.
   LOCAL cValor as character // Valor del registro seleccionado.
   LOCAL nCampo /*as numeric*/ // Numero del campo indice.

   // ------- Inicializa las variables.-------------------------------------------
   nRegistro := ( _cArea )->( RecNo() )

   // ------- Selecciona el registro.---------------------------------------------
   nReg := ABM2Seleccionar()
   IF nReg == 0
      ( _cArea )->( dbGoto( nRegistro ) )
      RETURN NIL
   ELSE
      ( _cArea )->( dbGoto( nReg ) )
      nCampo := _aIndiceCampo[ _nIndiceActivo ]
      cValor := hb_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
   ENDIF

   // ------- Actualiza seg�n la acci�n.------------------------------------------
   DO CASE
   CASE nAccion == ABM_LIS_SET1
      wndABM2Listado .txtRegistro1.VALUE := cValor
   CASE nAccion == ABM_LIS_SET2
      wndABM2Listado .txtRegistro2.VALUE := cValor
   ENDCASE

   // ------- Restaura el registro.
   ( _cArea )->( dbGoto( nRegistro ) )

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2DefinirColumnas( nAccion )
 * Descripci�n: Controla el contenido de las listas al pulsar los botones de a�adir y
 *              eliminar campos del listado.
 *  Par�metros: [nAccion]       Numerico. Indica el tipo de accion realizado.
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2DefinirColumnas( nAccion )

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL aCampoBase /*as array*/ // Campos de la bbd.
   LOCAL aCampoListado /*as array*/ // Campos del listado.
   LOCAL i /*as numeric*/ // Indice de iteraci�n.
   LOCAL nItem /*as numeric*/ // Numero del item seleccionado.
   LOCAL cValor as character

   // ------- Inicializaci�n de variables.----------------------------------------
   aCampoBase := {}
   aCampoListado := {}
   FOR i := 1 TO wndABM2Listado.lbxCampoBase.ItemCount
      AAdd( aCampoBase, wndABM2Listado.lbxCampoBase.Item( i ) )
   NEXT
   FOR i := 1 TO wndABM2Listado.lbxCampoListado.ItemCount
      AAdd( aCampoListado, wndABM2Listado.lbxCampoListado.Item( i ) )
   NEXT

   // ------- Ejecuta seg�n la acci�n.--------------------------------------------
   DO CASE
   CASE nAccion == ABM_LIS_ADD

      // Obtiene la columna a a�adir.
      nItem := wndABM2Listado.lbxCampoBase.VALUE
      cValor := wndABM2Listado.lbxCampoBase.Item( nItem )

      // Actualiza los datos de los campos de la base.
      IF Len( aCampoBase ) == 0
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoBase.DeleteAllItems
         FOR i := 1 TO Len( aCampoBase )
            IF i != nItem
               wndABM2Listado.lbxCampoBase.AddItem( aCampoBase[ i ] )
            ENDIF
         NEXT
         wndABM2Listado.lbxCampoBase.VALUE := iif( nItem > 1, nItem - 1, 1 )
      ENDIF

      // Actualiza los datos de los campos del listado.
      IF Empty( cValor )
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoListado.AddItem( cValor )
         wndABM2Listado.lbxCampoListado.VALUE := ;
            wndABM2Listado.lbxCampoListado.ItemCount
      ENDIF
   CASE nAccion == ABM_LIS_DEL

      // Obtiene la columna a quitar.
      nItem := wndABM2Listado.lbxCampoListado.VALUE
      cValor := wndABM2Listado.lbxCampoListado.Item( nItem )

      // Actualiza los datos de los campos del listado.
      IF Len( aCampoListado ) == 0
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoListado.DeleteAllItems
         FOR i := 1 TO Len( aCampoListado )
            IF i != nItem
               wndABM2Listado.lbxCampoListado.AddItem( aCampoListado[ i ] )
            ENDIF
         NEXT
         wndABM2Listado.lbxCampoListado.VALUE := ;
            wndABM2Listado.lbxCampoListado.ItemCount
      ENDIF

      // Actualiza los datos de los campos de la base.
      IF Empty( cValor )
         msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
         RETURN NIL
      ELSE
         wndABM2Listado.lbxCampoBase.DeleteAllItems
         FOR i := 1 TO Len( _aNombreCampo )
            IF AScan( aCampoBase, _aNombreCampo[ i ] ) != 0
               wndABM2Listado.lbxCampoBase.AddItem( _aNombreCampo[ i ] )
            ENDIF
            IF _aNombreCampo[ i ] == cValor
               wndABM2Listado.lbxCampoBase.AddItem( _aNombreCampo[ i ] )
            ENDIF
         NEXT
         wndABM2Listado.lbxCampoBase.VALUE := 1
      ENDIF
   ENDCASE

RETURN NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Listado()
 * Descripci�n: Imprime la selecciona realizada por ABM2Imprimir()
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
STATIC FUNCTION ABM2Listado( aImpresoras )

   // ------- Declaraci�n de variables locales.-----------------------------------
   LOCAL i /*as numeric*/ // Indice de iteraci�n.
   LOCAL cCampo /*as character*/ // Nombre del campo indice.
   LOCAL aCampo /*as array*/ // Nombres de los campos.
   LOCAL nCampo /*as numeric*/ // Numero del campo actual.
   LOCAL nPosicion /*as numeric*/ // Posici�n del campo.
   LOCAL aNumeroCampo /*as array*/ // Numeros de los campos.
   LOCAL aAncho /*as array*/ // Anchos de las columnas.
   LOCAL nAncho /*as numeric*/ // Ancho de las columna actual.
   LOCAL lPrevio /*as logical*/ // Previsualizar.
   LOCAL lVistas /*as logical*/ // Vistas en miniatura.
   LOCAL nImpresora /*as numeric*/ // Numero de la impresora.
   LOCAL cImpresora as character // Nombre de la impresora.
   LOCAL lOrientacion /*as logical*/ // Orientaci�n de la p�gina.
   LOCAL lSalida /*as logical*/ // Control de bucle.
   LOCAL lCabecera /*as logical*/ // �Imprimir cabecera?.
   LOCAL nFila /*as numeric*/ // Numero de la fila.
   LOCAL nColumna /*as numeric*/ // Numero de la columna.
   LOCAL nPagina /*as numeric*/ // Numero de p�gina.
   LOCAL nPaginas /*as numeric*/ // P�ginas totales.
   LOCAL cPie as character // Texto del pie de p�gina.
   LOCAL nPrimero /*as numeric*/ // Numero del primer registro a imprimir.
   LOCAL nUltimo /*as numeric*/ // Numero del ultimo registro a imprimir.
   LOCAL nTotales /*as numeric*/ // Registros totales a imprimir.
   LOCAL nRegistro /*as numeric*/ // Numero del registro actual.
   LOCAL cRegistro1 as character // Valor del registro inicial.
   LOCAL cRegistro2 as character // Valor del registro final.
   LOCAL xRegistro1 // Valor de comparaci�n.
   LOCAL xRegistro2 // Valor de comparaci�n.

   // ------- Inicializaci�n de variables.----------------------------------------
   // Previsualizar.
   lPrevio := wndABM2Listado .chkPrevio.VALUE
   lVistas := wndABM2Listado .chkVistas.VALUE

   // Nombre de la impresora.
   nImpresora := wndABM2Listado.cbxImpresoras.VALUE
   IF nImpresora == 0
      msgExclamation( _HMG_aLangUser[ 32 ], '' )
   ELSE
      cImpresora := aImpresoras[ nImpresora ]
   ENDIF

   // Nombre del campo.
   aCampo := {}
   FOR i := 1 TO wndABM2Listado.lbxCampoListado.ItemCount
      cCampo := wndABM2Listado.lbxCampoListado.Item( i )
      AAdd( aCampo, cCampo )
   NEXT
   IF Len( aCampo ) == 0
      msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
      RETURN NIL
   ENDIF

   // N�mero del campo.
   aNumeroCampo := {}
   FOR i := 1 TO Len( aCampo )
      nPosicion := AScan( _aNombreCampo, aCampo[ i ] )
      AAdd( aNumeroCampo, nPosicion )
   NEXT

   // ------- Obtiene el ancho de impresi�n.--------------------------------------
   aAncho := {}
   FOR i := 1 TO Len( aNumeroCampo )
      nCampo := aNumeroCampo[ i ]
      DO CASE
      CASE _aEstructura[ nCampo, DBS_TYPE ] == "D"
         nAncho := 9
      CASE _aEstructura[ nCampo, DBS_TYPE ] == "M"
         nAncho := 20
      OTHERWISE
         nAncho := _aEstructura[ nCampo, DBS_LEN ]
      ENDCASE
      nAncho := iif( Len( _aNombreCampo[ nCampo ] ) > nAncho, ;
         Len( _aNombreCampo[ nCampo ] ), ;
         nAncho )
      AAdd( aAncho, 2 + nAncho )
   NEXT

   // ------- Comprueba el ancho de impresi�n.------------------------------------
   nAncho := 0
   FOR i := 1 TO Len( aAncho )
      nAncho += aAncho[ i ]
   NEXT
   IF nAncho > 164
      MsgExclamation( _HMG_aLangUser[ 24 ], _cTitulo )
      RETURN NIL
   ELSE
      lOrientacion := ( nAncho > 109 ) // Horizontal / Vertical
   ENDIF

   // ------- Valores de inicio y fin de listado.---------------------------------
   nRegistro := ( _cArea )->( RecNo() )
   cRegistro1 := wndABM2Listado .txtRegistro1.VALUE
   cRegistro2 := wndABM2Listado .txtRegistro2.VALUE
   DO CASE
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "C"
      xRegistro1 := cRegistro1
      xRegistro2 := cRegistro2
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "N"
      xRegistro1 := Val( cRegistro1 )
      xRegistro2 := Val( cRegistro2 )
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "D"
      xRegistro1 := CToD( cRegistro1 )
      xRegistro2 := CToD( cRegistro2 )
   CASE _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "L"
      xRegistro1 := ( cRegistro1 == ".t." )
      xRegistro2 := ( cRegistro2 == ".t." )
   ENDCASE
   ( _cArea )->( dbSeek( xRegistro2 ) )
   nUltimo := ( _cArea )->( RecNo() )
   ( _cArea )->( dbSeek( xRegistro1 ) )
   nPrimero := ( _cArea )->( RecNo() )

   // ------- Obtiene el n�mero de p�ginas.---------------------------------------
   nTotales := 1
   ( _cArea )->( dbEval( {|| nTotales++ },, {|| !( RecNo() == nUltimo ) .AND. ! Eof() },,, .T. ) )
   ( _cArea )->( dbGoto( nPrimero ) )
   IF lOrientacion
      IF Mod( nTotales, 33 ) == 0
         nPaginas := Int( nTotales / 33 )
      ELSE
         nPaginas := Int( nTotales / 33 ) + 1
      ENDIF
   ELSE
      IF Mod( nTotales, 55 ) == 0
         nPaginas := Int( nTotales / 55 )
      ELSE
         nPaginas := Int( nTotales / 55 ) + 1
      ENDIF
   ENDIF

   // ------- Inicializa el listado.----------------------------------------------
   INIT PRINTSYS

   // Opciones de la impresi�n.
   IF lPrevio
      SELECT PRINTER cImpresora PREVIEW
   ELSE
      SELECT PRINTER cImpresora
   ENDIF
   IF lVistas
      ENABLE THUMBNAILS
   ENDIF

   // Control de errores.
   IF HBPRNERROR > 0
      msgExclamation( _HMG_aLangUser[ 25 ], _cTitulo )
      RETURN NIL
   ENDIF

   // Definici�n de las fuentes del listado.
   DEFINE FONT "a8" NAME "Arial" SIZE 8
   DEFINE FONT "a9" NAME "Arial" SIZE 9
   DEFINE FONT "a9n" NAME "Arial" SIZE 9 BOLD
   DEFINE FONT "a10" NAME "Arial" SIZE 10
   DEFINE FONT "a12n" NAME "Arial" SIZE 12 BOLD

   // Definici�n de los tipos de linea.
   DEFINE PEN "l0" STYLE PS_SOLID WIDTH 0.0 COLOR 0x000000
   DEFINE PEN "l1" STYLE PS_SOLID WIDTH 0.1 COLOR 0x000000
   DEFINE PEN "l2" STYLE PS_SOLID WIDTH 0.2 COLOR 0x000000

   // Definici�n de los patrones de relleno.
   DEFINE BRUSH "s0" STYLE BS_NULL
   DEFINE BRUSH "s1" STYLE BS_SOLID COLOR RGB( 220, 220, 220 )

   // Inicio del listado.
   lCabecera := .T.
   lSalida := .T.
   nFila := iif( Empty( _cFiltro ), 12, 13 )
   nPagina := 1
   START DOC
   SET UNITS ROWCOL
   IF lOrientacion
      SET PAGE ORIENTATION DMORIENT_LANDSCAPE ;
         PAPERSIZE DMPAPER_A4 FONT "a10"
   ELSE
      SET PAGE ORIENTATION DMORIENT_PORTRAIT ;
         PAPERSIZE DMPAPER_A4 FONT "a10"
   ENDIF
   START PAGE
   DO WHILE lSalida

      // Cabecera el listado.
      IF lCabecera
         SET TEXT ALIGN RIGHT
         SELECT pen "l2"
         @ 5, HBPRNMAXCOL - 5 SAY _cTitulo FONT "a12n" TO PRINT
         @ 6, 10, 6, HBPRNMAXCOL - 5 line
         SELECT pen "l0"
         @ 7, 29 SAY _HMG_aLangUser[ 26 ] FONT "a9n" TO PRINT
         @ 8, 29 SAY _HMG_aLangUser[ 27 ] FONT "a9n" TO PRINT
         @ 9, 29 SAY _HMG_aLangUser[ 28 ] FONT "a9n" TO PRINT
         if ! Empty( _cFiltro )
            @ 10, 29 SAY _HMG_aLangUser[ 33 ] FONT "a9n" TO PRINT
         ENDIF
         SET TEXT ALIGN LEFT
         @ 7, 31 say ( _cArea )->( ordName() ) FONT "a9" TO PRINT
         @ 8, 31 SAY cRegistro1 FONT "a9" TO PRINT
         @ 9, 31 SAY cRegistro2 FONT "a9" TO PRINT
         if ! Empty( _cFiltro )
            @ 10, 31 SAY _cFiltro FONT "a9" TO PRINT
         ENDIF
         nColumna := 10
         SELECT pen "l1"
         SELECT brush "s1"
         FOR i := 1 TO Len( aCampo )
            @ nFila - .9, nColumna, nFila, nColumna + aAncho[ i ] fillrect
            @ nFila - 1, nColumna + 1 SAY aCampo[ i ] FONT "a9n" TO PRINT
            nColumna += aAncho[ i ]
         NEXT
         SELECT pen "l0"
         SELECT brush "s0"
         lCabecera := .F.
      ENDIF

      // Registros.
      nColumna := 10
      FOR i := 1 TO Len( aNumeroCampo )
         nCampo := aNumeroCampo[ i ]
         DO CASE
         CASE _aEstructura[ nCampo, DBS_TYPE ] == "N"
            SET TEXT ALIGN RIGHT
            @ nFila, nColumna + aAncho[ i ] say ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ) FONT "a8" TO PRINT
         CASE _aEstructura[ nCampo, DBS_TYPE ] == "L"
            SET TEXT ALIGN LEFT
            @ nFila, nColumna + 1 SAY iif( ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ), _HMG_aLangUser[ 29 ], _HMG_aLangUser[ 30 ] ) FONT "a8" TO PRINT
         CASE _aEstructura[ nCampo, DBS_TYPE ] == "M"
            SET TEXT ALIGN LEFT
            @ nFila, nColumna + 1 SAY SubStr( ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ), 1, 20 ) FONT "a8" TO PRINT
         OTHERWISE
            SET TEXT ALIGN LEFT
            @ nFila, nColumna + 1 say ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ) FONT "a8" TO PRINT
         ENDCASE
         nColumna += aAncho[ i ]
      NEXT
      nFila++

      // Comprueba el final del registro.
      IF ( _cArea )->( RecNo() ) == nUltimo .OR. ( _cArea )->( Eof() )
         lSalida := .F.
      ENDIF
      ( _cArea )->( dbSkip( 1 ) )

      // Pie.
      IF lOrientacion
         IF nFila > 44
            SET TEXT ALIGN LEFT
            SELECT pen "l2"
            @ 46, 10, 46, HBPRNMAXCOL - 5 line
            cPie := hb_ValToStr( Date() ) + " " + Time()
            @ 46, 10 SAY cPie FONT "a9n" TO PRINT
            SET TEXT ALIGN RIGHT
            cPie := _HMG_aABMLangLabel[ 22 ] + ;
               AllTrim( Str( nPagina ) ) + ;
               "/" + ;
               AllTrim( Str( nPaginas ) )
            @ 46, HBPRNMAXCOL - 5 SAY cPie FONT "a9n" TO PRINT
            nPagina++
            nFila := iif( Empty( _cFiltro ), 12, 13 )
            lCabecera := .T.
            END PAGE
            START PAGE
         ENDIF
      ELSE
         IF nFila > 66
            SET TEXT ALIGN LEFT
            SELECT pen "l2"
            @ 68, 10, 68, HBPRNMAXCOL - 5 line
            cPie := hb_ValToStr( Date() ) + " " + Time()
            @ 68, 10 SAY cPie FONT "a9n" TO PRINT
            SET TEXT ALIGN RIGHT
            cPie := _HMG_aABMLangLabel[ 22 ] + ;
               AllTrim( Str( nPagina ) ) + ;
               "/" + ;
               AllTrim( Str( nPaginas ) )
            @ 68, HBPRNMAXCOL - 5 SAY cPie FONT "a9n" TO PRINT
            nFila := iif( Empty( _cFiltro ), 12, 13 )
            nPagina++
            lCabecera := .T.
            END PAGE
            START PAGE
         ENDIF
      ENDIF
   ENDDO

   // Comprueba que se imprime el pie de la ultima hoja.----------
   IF nPagina == nPaginas
      IF lOrientacion
         SET TEXT ALIGN LEFT
         SELECT pen "l2"
         @ 46, 10, 46, HBPRNMAXCOL - 5 line
         cPie := hb_ValToStr( Date() ) + " " + Time()
         @ 46, 10 SAY cPie FONT "a9n" TO PRINT
         SET TEXT ALIGN RIGHT
         cPie := _HMG_aABMLangLabel[ 22 ] + ;
            AllTrim( Str( nPagina ) ) + ;
            "/" + ;
            AllTrim( Str( nPaginas ) )
         @ 46, HBPRNMAXCOL - 5 SAY cPie FONT "a9n" TO PRINT
      ELSE
         SET TEXT ALIGN LEFT
         SELECT pen "l2"
         @ 68, 10, 68, HBPRNMAXCOL - 5 line
         cPie := hb_ValToStr( Date() ) + " " + Time()
         @ 68, 10 SAY cPie FONT "a9n" TO PRINT
         SET TEXT ALIGN RIGHT
         cPie := _HMG_aABMLangLabel[ 22 ] + ;
            AllTrim( Str( nPagina ) ) + ;
            "/" + ;
            AllTrim( Str( nPaginas ) )
         @ 68, HBPRNMAXCOL - 5 SAY cPie FONT "a9n" TO PRINT
      ENDIF

      END PAGE
   ENDIF
   END DOC

   RELEASE PRINTSYS

   // ------- Cierra la ventana.--------------------------------------------------
   ( _cArea )->( dbGoto( nRegistro ) )
   wndABM2Listado.RELEASE

RETURN NIL
