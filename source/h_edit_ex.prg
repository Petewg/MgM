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
static _cArea           /*as character*/            // Nombre del area de la bdd.
static _aEstructura     /*as array*/                // Estructura de la bdd.
static _aIndice         /*as array*/                // Nombre de los indices de la bdd.
static _aIndiceCampo    /*as array*/                // N�mero del campo indice.
static _nIndiceActivo   /*as array*/                // Indice activo.
static _aNombreCampo    /*as array*/                // Nombre desciptivo de los campos de la bdd.
static _aEditable       /*as array*/                // Indicador de si son editables.
static _cTitulo         /*as character*/            // T�tulo de la ventana.
static _nAltoPantalla   /*as numeric*/              // Alto de la pantalla.
static _nAnchoPantalla  /*as numeric*/              // Ancho de la pantalla.
static _aEtiqueta       /*as array*/                // Datos de las etiquetas.
static _aControl        /*as array*/                // Datos de los controles.
static _aCampoTabla     /*as array*/                // Nombre de los campos para la tabla.
static _aAnchoTabla     /*as array*/                // Anchos de los campos para la tabla.
static _aCabeceraTabla  /*as array*/                // Texto de las columnas de la tabla.
static _aAlineadoTabla  /*as array*/                // Alineaci�n de las columnas de la tabla.
static _aVisibleEnTabla /*as array*/                // Campos visibles en la tabla.
static _nControlActivo  /*as numeric*/              // Control con foco.
static _aOpciones       /*as array*/                // Opciones del usuario.
static _bGuardar        /*as codeblock*/            // Acci�n para guardar registro.
static _bBuscar         /*as codeblock*/            // Acci�n para buscar registro.
static _bImprimir       /*as codeblock*/            // Acci�n para imprimir listado.
static _lFiltro         /*as logical*/              // Indicativo de filtro activo.
static _cFiltro         /*as character*/            // Condici�n de filtro.


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
function ABM2( cArea, cTitulo, aNombreCampo, ;
                aAvisoCampo, aEditable, aVisibleEnTabla, ;
                aOpciones, bGuardar, bBuscar, bImprimir )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local   i              /*as numeric*/   // Indice de iteraci�n.
        local   k              /*as numeric*/   // Indice de iteraci�n.
        local   nArea          as numeric       // Numero del area de la bdd.
        local   nRegistro      as numeric       // N�mero de regisrto de la bdd.
        local   nEstructura    /*as numeric*/   // Ancho del estructura de la bdd.
        local   lSalida        /*as logical*/   // Control de bucle.
        local   nVeces         /*as numeric*/   // Indice de iteraci�n.
        local   cIndice        as character     // Nombre del indice.
        local   cIndiceActivo  as character     // Nombre del indice activo.
        local   cClave         as character     // Clave del indice.
        local   nInicio        /*as numeric*/   // Inicio de la cadena de busqueda.
        local   nAnchoCampo    /*as numeric*/   // Ancho del campo actual.
        local   nAnchoEtiqueta /*as numeric*/   // Ancho m�ximo de las etiquetas.
        local   nFila          /*as numeric*/   // Fila de creaci�n del control de edici�n.
        local   nColumna       /*as numeric*/   // Columna de creaci�n del control de edici�n.
        local   aTextoOp       /*as numeric*/   // Texto de las opciones de usuario.
        local   _BakExtendedNavigation          // Estado de SET NAVIAGTION.
        local   _BackDeleted                    // Estado de SET DELETED.
        local   cFiltroAnt     as character     // Condici�n del filtro anterior.

        // ------- Gusrdar estado actual de SET DELETED y activarlo
        _BackDeleted := set( _SET_DELETED )
        SET DELETED OFF

        // ------- Inicializaci�n del soporte multilenguaje.---------------------------
        InitMessages()

        // ------- Desactivaci�n de SET NAVIGATION.------------------------------------
        _BakExtendedNavigation  := _HMG_ExtendedNavigation
        _HMG_ExtendedNavigation := .F.

        // ------- Control de par�metros.----------------------------------------------
        // Area de la base de datos.
        if ValType( cArea ) != "C" .or. Empty( cArea )
                _cArea := Alias()
                if _cArea == ""
                        msgExclamation( _HMG_aLangUser[ 1 ], "EDIT EXTENDED" )
                        return NIL
                endif
        else
                _cArea := cArea
        endif
        _aEstructura := ( _cArea )->( dbStruct() )
        nEstructura := Len( _aEstructura )

        // T�tulo de la ventana.
        if Empty( cTitulo ) .or. Valtype( cTitulo ) != "C"
                _cTitulo := _cArea
        else
                _cTitulo := cTitulo
        endif

        // Nombres de los campos.
        lSalida := .t.
        if ValType( aNombreCampo ) != "A"
                lSalida := .f.
        else
                if Len( aNombreCampo ) != nEstructura
                        lSalida := .f.
                else
                        for i := 1 to Len( aNombreCampo )
                                if ValType( aNombreCampo[ i ] ) != "C"
                                        lSalida := .f.
                                        exit
                                endif
                        next
                endif
        endif
        if lSalida
                _aNombreCampo := aNombreCampo
        else
                _aNombreCampo := {}
                for i := 1 to nEstructura
                        aAdd( _aNombreCampo, Upper( Left( _aEstructura[ i, DBS_NAME ], 1 ) ) + ;
                                Lower( SubStr( _aEstructura[ i, DBS_NAME ], 2 ) ) )
                next
        endif

        // Texto de aviso en la barra de estado de la ventana de edici�n de registro.
        lSalida := .t.
        if ValType( aAvisoCampo ) != "A"
                lSalida := .f.
        else
                if Len( aAvisoCampo ) != nEstructura
                        lSalida := .f.
                else
                        for i := 1 to Len( aAvisoCampo )
                                if Valtype( aAvisoCampo[ i ] ) != "C"
                                        lSalida := .f.
                                        exit
                                endif
                        next
                endif
        endif
        if !lSalida
                aAvisoCampo := {}
                for i := 1 to nEstructura
                        do case
                        case _aEstructura[ i, DBS_TYPE ] == "C"
                                aAdd( aAvisoCampo, _HMG_aLangUser[ 2 ] )
                        case _aEstructura[ i, DBS_TYPE ] == "N"
                                aAdd( aAvisoCampo, _HMG_aLangUser[ 3 ] )
                        case _aEstructura[ i, DBS_TYPE ] == "D"
                                aAdd( aAvisoCampo, _HMG_aLangUser[ 4 ] )
                        case _aEstructura[ i, DBS_TYPE ] == "L"
                                aAdd( aAvisoCampo, _HMG_aLangUser[ 5 ] )
                        case _aEstructura[ i, DBS_TYPE ] == "M"
                                aAdd( aAvisoCampo, _HMG_aLangUser[ 6 ] )
                        otherwise
                                aAdd( aAvisoCampo, _HMG_aLangUser[ 7 ] )
                        endcase
                next
        endif

        // Campos visibles en la tabla de la ventana de visualizaci�n de registros.
        lSalida := .t.
        if Valtype( aVisibleEnTabla ) != "A"
                lSalida := .f.
        else
                if Len( aVisibleEnTabla ) != nEstructura
                        lSalida := .f.
                else
                        for i := 1 to Len( aVisibleEnTabla )
                                if ValType( aVisibleEnTabla[ i ] ) != "L"
                                        lSalida := .f.
                                        exit
                                endif
                        next
                endif
        endif
        if lSalida
                _aVisibleEnTabla := aVisibleEnTabla
        else
                _aVisibleEnTabla := {}
                for i := 1 to nEstructura
                        aAdd( _aVisibleEnTabla, .t. )
                next
        endif

        // Estado de los campos en la ventana de edici�n de registro.
        lSalida := .t.
        if ValType( aEditable ) != "A"
                lSalida := .f.
        else
                if Len( aEditable ) != nEstructura
                        lSalida := .f.
                else
                        for i := 1 to Len( aEditable )
                                if ValType( aEditable[ i ] ) != "L"
                                        lSalida := .f.
                                        exit
                                endif
                        next
                endif
        endif
        if lSalida
                _aEditable := aEditable
        else
                _aEditable := {}
                for i := 1 to nEstructura
                        aAdd( _aEditable, .t. )
                next
        endif

        // Opciones del usuario.
        lSalida := .t.

        if ValType( aOpciones ) != "A"
                lSalida := .f.
        elseif len( aOpciones ) < 1
                lSalida := .f.
        elseif Len( aOpciones[ 1 ] ) != 2
                lSalida := .f.
        else
                for i := 1 to Len( aOpciones )
                        if ValType( aOpciones[i, ABM_OPC_TEXTO ] ) != "C" .or. ;
                                        ValType( aOpciones[i, ABM_OPC_BLOQUE ] ) != "B"
                                lSalida := .f.
                                exit
                        endif
                next
        endif

        if lSalida
                _aOpciones := aOpciones
        else
                _aOpciones := {}
        endif

        // Acci�n al guardar.
        if ValType( bGuardar ) == "B"
                _bGuardar := bGuardar
        else
                _bGuardar := NIL
        endif

        // Acci�n al buscar.
        if ValType( bBuscar ) == "B"
                _bBuscar := bBuscar
        else
                _bBuscar := NIL
        endif

        // Acci�n al buscar.
        if ValType( bImprimir ) == "B"
                _bImprimir := bImprimir
        else
                _bImprimir := NIL
        endif

        // ------- Selecci�n del area de la bdd.---------------------------------------
        nRegistro     := ( _cArea )->( RecNo() )
        nArea         := Select()
        cIndiceActivo := ( _cArea )->( ordSetFocus() )
        cFiltroAnt    := ( _cArea )->( dbFilter() )
        dbSelectArea( _cArea )
        ( _cArea )->( dbGoTop() )

        // ------- Inicializaci�n de variables.----------------------------------------
        // Filtro.
        _cFiltro := cFiltroAnt
        _lFiltro := !( Empty( _cFiltro ) )

        // Indices de la base de datos.
        lSalida       := .t.
        k             := 1
        _aIndice      := {}
        _aIndiceCampo := {}
        nVeces        := 1
        aAdd( _aIndice, _HMG_aLangLabel[ 1 ] )
        aAdd( _aIndiceCampo, 0 )
        do while lSalida
                if Empty( ( _cArea )->( ordName( k ) ) )
                        lSalida := .f.
                else
                        cIndice := Upper( ( _cArea )->( ordName( k ) ) )
                        aAdd( _aIndice, cIndice )
                        cClave := Upper( ( _cArea )->( ordKey( k ) ) )
                        for i := 1 to nEstructura
                                if nVeces <= 1
                                        nInicio := At( _aEstructura[ i, DBS_NAME ], cClave )
                                        if  nInicio != 0
                                                aAdd( _aIndiceCampo, i )
                                                nVeces++
                                        endif
                                endif
                        next
                endif
                k++
                nVeces := 1
        enddo

        // Numero de indice.
        if Empty( cIndiceActivo )
                _nIndiceActivo := 1
        else
                _nIndiceActivo := aScan( _aIndice, Upper( ( _cArea )->( ordSetFocus() ) ) )
        endif

        // Tama�o de la pantalla.
        _nAltoPantalla  := getDesktopHeight()
        _nAnchoPantalla := getDesktopWidth()

        // Datos de las etiquetas y los controles de la ventana de edici�n.
        _aEtiqueta     := Array( nEstructura, ABM_LBL_LEN )
        _aControl      := Array( nEstructura, ABM_CON_LEN )
        nFila          := 10
        nColumna       := 10
        nAnchoEtiqueta := 0
        for i := 1 to Len( _aNombreCampo )
                nAnchoEtiqueta := iif( nAnchoEtiqueta > ( Len( _aNombreCampo[ i ] ) * 9 ), ;
                        nAnchoEtiqueta, ;
                        Len( _aNombreCampo[ i ] ) * 9 )
        next
        for i := 1 to nEstructura
                _aEtiqueta[ i, ABM_LBL_NAME ]   := "ABM2Etiqueta" + AllTrim( Str( i ) )
                _aEtiqueta[ i, ABM_LBL_ROW ]    := nFila
                _aEtiqueta[ i, ABM_LBL_COL ]    := nColumna
                _aEtiqueta[ i, ABM_LBL_WIDTH ]  := Len( _aNombreCampo[ i ] ) * 9
                _aEtiqueta[ i, ABM_LBL_HEIGHT ] := 25
                switch Left( _aEstructura[ i, DBS_TYPE ], 1 )
                case "C"
                        _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
                        _aControl[ i, ABM_CON_ROW ]    := nFila
                        _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
                        _aControl[ i, ABM_CON_WIDTH ]  := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50, 50, _aEstructura[ i, DBS_LEN ] * 10 )
                        _aControl[ i, ABM_CON_HEIGHT ] := 25
                        _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
                        _aControl[ i, ABM_CON_TYPE ]   := ABM_TEXTBOXC
                        exit
                case "D"
                        _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
                        _aControl[ i, ABM_CON_ROW ]    := nFila
                        _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
                        _aControl[ i, ABM_CON_WIDTH ]  := _aEstructura[ i, DBS_LEN ] * 10
                        _aControl[ i, ABM_CON_HEIGHT ] := 25
                        _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
                        _aControl[ i, ABM_CON_TYPE ]   := ABM_DATEPICKER
                        exit
                case "N"
                        _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
                        _aControl[ i, ABM_CON_ROW ]    := nFila
                        _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
                        _aControl[ i, ABM_CON_WIDTH ]  := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50, 50, _aEstructura[ i, DBS_LEN ] * 10 )
                        _aControl[ i, ABM_CON_HEIGHT ] := 25
                        _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
                        _aControl[ i, ABM_CON_TYPE ]   := ABM_TEXTBOXN
                        exit
                case "L"
                        _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
                        _aControl[ i, ABM_CON_ROW ]    := nFila
                        _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
                        _aControl[ i, ABM_CON_WIDTH ]  := 25
                        _aControl[ i, ABM_CON_HEIGHT ] := 25
                        _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
                        _aControl[ i, ABM_CON_TYPE ]   := ABM_CHECKBOX
                        exit
                case "M"
                        _aControl[ i, ABM_CON_NAME ]   := "ABM2Control" + AllTrim( Str( i ) )
                        _aControl[ i, ABM_CON_ROW ]    := nFila
                        _aControl[ i, ABM_CON_COL ]    := nColumna + nAnchoEtiqueta + 20
                        _aControl[ i, ABM_CON_WIDTH ]  := 300
                        _aControl[ i, ABM_CON_HEIGHT ] := 70
                        _aControl[ i, ABM_CON_DES ]    := aAvisoCampo[ i ]
                        _aControl[ i, ABM_CON_TYPE ]   := ABM_EDITBOX
                        nFila += 45
                endswitch
                if _aEstructura[ i, DBS_TYPE ] $ "CDNLM"
                        nFila += 35
                endif
        next

        // Datos de la tabla de la ventana de visualizaci�n.

        _aCampoTabla    := { "if(deleted(), 'X', ' ')" }
        _aAnchoTabla    := { 20 }
        _aCabeceraTabla := { "X" }
        _aAlineadoTabla := { BROWSE_JTFY_LEFT }

        for i := 1 to nEstructura
                if _aVisibleEnTabla[ i ]
                        aAdd( _aCampoTabla, _cArea + "->" + _aEstructura[ i, DBS_NAME ] )
                        nAnchoCampo    := iif( ( _aEstructura[ i, DBS_LEN ] * 10 ) < 50,   ;
                                50,                                    ;
                                _aEstructura[ i, DBS_LEN ] * 10 )
                        nAnchoEtiqueta := Len( _aNombreCampo[ i ] ) * 10
                        aAdd( _aAnchoTabla, iif( nAnchoEtiqueta > nAnchoCampo,          ;
                                nAnchoEtiqueta,                        ;
                                nAnchoCampo ) )
                        aAdd( _aCabeceraTabla, _aNombreCampo[ i ] )

                        If _aEstructura[ i, DBS_TYPE ] == "L"
                                aAdd( _aAlineadoTabla, BROWSE_JTFY_CENTER )
                        elseif _aEstructura[ i, DBS_TYPE ] == "D"
                                aAdd( _aAlineadoTabla, BROWSE_JTFY_CENTER )
                        elseif _aEstructura[ i, DBS_TYPE ] == "N"
                                aAdd( _aAlineadoTabla, BROWSE_JTFY_RIGHT )
                        else
                                aAdd( _aAlineadoTabla, BROWSE_JTFY_LEFT )
                        endif
                endif
        next

        // ------- Definici�n de la ventana de visualizaci�n.--------------------------
        define window wndABM2Edit               ;
                at 60, 30                       ;
                width _nAnchoPantalla - 60      ;
                height _nAltoPantalla - 140     ;
                title _cTitulo                  ;
                modal                           ;
                nosize                          ;
                nosysmenu                       ;
                on init {|| ABM2Redibuja() }    ;
                on release {|| ABM2salir( nRegistro, cIndiceActivo, cFiltroAnt, nArea ) } ;
                font _GetSysFont() size 9

        // Define la barra de estado de la ventana de visualizaci�n.
        define statusbar font _GetSysFont() size 9
               statusitem _HMG_aLangLabel[ 19 ]                         // 1
               statusitem _HMG_aLangLabel[ 20 ]      width 100 raised   // 2
               statusitem _HMG_aLangLabel[ 2 ] + ': ' width 200 raised  // 3
        end statusbar

        // Define la barra de botones de la ventana de visualizaci�n.
        define toolbar tbEdit buttonsize 100, 32 flat righttext border
        button tbbCerrar  caption _HMG_aLangButton[ 1 ]  ;
                picture "MINIGUI_EDIT_CLOSE"  ;
                action  wndABM2Edit.Release
        button tbbNuevo   caption _HMG_aLangButton[ 2 ]  ;
                picture "MINIGUI_EDIT_NEW"  ;
                action  {|| ABM2Editar( .t. ) }
        button tbbEditar  caption _HMG_aLangButton[ 3 ]  ;
                picture "MINIGUI_EDIT_EDIT"  ;
                action  {|| ABM2Editar( .f. ) }
        button tbbBorrar  caption _HMG_aLangButton[ 4 ]  ;
                picture "MINIGUI_EDIT_DELETE"  ;
                action  {|| ABM2Borrar() }
        button tbbRecover caption _HMG_aLangButton[ 12 ]  ;
                picture "MINIGUI_EDIT_UNDO"  ;
                action  {|| ABM2Recover() }
        button tbbBuscar  caption _HMG_aLangButton[ 5 ]  ;
                picture "MINIGUI_EDIT_FIND"  ;
                action  {|| ABM2Buscar() }
        button tbbListado caption _HMG_aLangButton[ 6 ]  ;
                picture "MINIGUI_EDIT_PRINT"  ;
                action  {|| ABM2Imprimir() }
        end toolbar

        end window

        // ------- Creaci�n de los controles de la ventana de visualizaci�n.-----------
        @ 50, 10 frame frmEditOpciones          ;
                of wndABM2Edit                  ;
                caption ""                      ;
                width wndABM2Edit.Width - 25    ;
                height 60
        @ 112, 10 frame frmEditTabla            ;
                of wndABM2Edit                  ;
                caption ""                      ;
                width wndABM2Edit.Width - 25    ;
                height wndABM2Edit.Height - 165
        @ 60, 20 label lblIndice               ;
                of wndABM2Edit                  ;
                value _HMG_aLangUser[26 ]       ;
                autosize                        ;
                font _GetSysFont() size 9
        @ 75, 20 combobox cbIndices             ;
                of wndABM2Edit                  ;
                items _aIndice                  ;
                value _nIndiceActivo            ;
                width 150                       ;
                font _GetSysFont() size 9     ;
                on change {|| ABM2CambiarOrden() }
        nColumna := wndABM2Edit.Width - 175
        aTextoOp := {}
        for i := 1 to Len( _aOpciones )
                aAdd( aTextoOp, _aOpciones[ i, ABM_OPC_TEXTO ] )
        next
        @ 60, nColumna label lblOpciones        ;
                of wndABM2Edit                  ;
                value _HMG_aLangLabel[5 ]       ;
                autosize                        ;
                font _GetSysFont() size 9
        @ 75, nColumna combobox cbOpciones      ;
                of wndABM2Edit                  ;
                items aTextoOp                  ;
                value 1                         ;
                width 150                       ;
                font _GetSysFont() size 9     ;
                on change {|| ABM2EjecutaOpcion() }
        @ 65, ( wndABM2Edit.Width / 2 ) -110 button btnFiltro1  ;
                of wndABM2Edit                                  ;
                caption _HMG_aLangButton[ 10 ]                  ;
                action {|| ABM2ActivarFiltro() }                ;
                width 100                                       ;
                height 32                                       ;
                font _GetSysFont() size 9
        @ 65, ( wndABM2Edit.Width / 2 ) + 5 button btnFiltro2   ;
                of wndABM2Edit                                  ;
                caption _HMG_aLangButton[ 11 ]                  ;
                action {|| ABM2DesactivarFiltro() }             ;
                width 100                                       ;
                height 32                                       ;
                font _GetSysFont() size 9
        @ 132, 20 browse brwABM2Edit                                                    ;
                of wndABM2Edit                                                          ;
                width wndABM2Edit.Width - 45                                            ;
                height wndABM2Edit.Height - 195                                         ;
                headers _aCabeceraTabla                                                 ;
                widths _aAnchoTabla                                                     ;
                workarea &_cArea                                                        ;
                fields _aCampoTabla                                                     ;
                value ( _cArea )->( RecNo() )                                           ;
                font _GetSysFont() size 9                                             ;
                on change {|| ( _cArea )->( dbGoto( wndABM2Edit .brwABM2Edit. Value ) ),    ;
                ABM2Redibuja( .f. ) }                                     ;
                on dblclick {|| iif( wndABM2Edit .tbbEditar. Enabled, ABM2Editar( .f. ), ) }  ;
                justify _aAlineadoTabla paintdoublebuffer

        // Comprueba el estado de las opciones de usuario.
        if Len( _aOpciones ) == 0
                wndABM2Edit .cbOpciones. Enabled := .f.
        endif

        // ------- Activaci�n de la ventana de visualizaci�n.--------------------------
        activate window wndABM2Edit

        // ------- Restauraci�n de SET NAVIGATION.-------------------------------------
        _HMG_ExtendedNavigation := _BakExtendedNavigation

        // ------- Restaurar SET DELETED a su valor inicial
        set( _SET_DELETED, _BackDeleted  )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2salir()
 * Descripci�n: Cierra la ventana de visualizaci�n de registros y sale.
 *  Par�metros: Ninguno.
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2salir( nRegistro, cIndiceActivo, cFiltroAnt, nArea )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local bFiltroAnt as codeblock           // Bloque de c�digo del filtro.

        // ------- Inicializaci�n de variables.----------------------------------------
        bFiltroAnt := iif( Empty( cFiltroAnt ), ;
                &( "{||NIL}" ), ;
                &( "{||" + cFiltroAnt + "}" ) )

        // ------- Restaura el area de la bdd inicial.---------------------------------
        ( _cArea )->( dbGoTo( nRegistro ) )
        ( _cArea )->( ordSetFocus( cIndiceActivo ) )
        ( _cArea )->( dbSetFilter( bFiltroAnt, cFiltroAnt ) )
        dbSelectArea( nArea )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Redibuja()
 * Descripci�n: Actualizaci�n de la ventana de visualizaci�n de registros.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2Redibuja( lTabla )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local lDeleted /*as logical*/

        // ------- Control de par�metros.----------------------------------------------
        if ValType( lTabla ) != "L"
                lTabla := .f.
        endif

        // ------- Refresco de la barra de botones.------------------------------------
        if ( _cArea )->( RecCount() ) == 0
                wndABM2Edit .tbbEditar. Enabled  := .f.
                wndABM2Edit .tbbBorrar. Enabled  := .f.
                wndABM2Edit .tbbBuscar. Enabled  := .f.
                wndABM2Edit .tbbListado. Enabled := .f.
        else
                lDeleted := Deleted()
                wndABM2Edit .tbbEditar. Enabled  := !lDeleted
                wndABM2Edit .tbbBorrar. Enabled  := !lDeleted
                wndABM2Edit .tbbBuscar. Enabled  := .t.
                wndABM2Edit .tbbRecover. Enabled := lDeleted
                wndABM2Edit .tbbListado. Enabled := .t.
        endif

        // ------- Refresco de la barra de estado.-------------------------------------
        wndABM2Edit .StatusBar. Item( 1 ) := _HMG_aLangLabel[ 19 ] + _cFiltro
        wndABM2Edit .StatusBar. Item( 2 ) := _HMG_aLangLabel[ 20 ] + iif( _lFiltro, _HMG_aLangUser[ 29 ], _HMG_aLangUser[ 30 ] )
        wndABM2Edit .StatusBar. Item( 3 ) := _HMG_aLangLabel[ 2 ] + ': ' + ;
                AllTrim( Str( ( _cArea )->( RecNo() ) ) ) + "/" + ;
                AllTrim( Str( ( _cArea )->( RecCount() ) ) )

        // ------- Refresca el browse si se indica.
        if lTabla
                wndABM2Edit .brwABM2Edit. Value := ( _cArea )->( RecNo() )
                wndABM2Edit .brwABM2Edit. Refresh
        endif

        // ------- Coloca el foco en el browse.
        wndABM2Edit .brwABM2Edit. SetFocus

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2CambiarOrden()
 * Descripci�n: Cambia el orden activo.
 *  Par�metros: Ninguno.
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2CambiarOrden()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local nIndice /*as numeric*/                // N�mero del indice.

        // ------- Inicializa las variables.-------------------------------------------
        nIndice := wndABM2Edit .cbIndices. Value - 1

        // ------- Cambia el orden del area de trabajo.--------------------------------
        ( _cArea )->( ordSetFocus( nIndice ) )
        // (_cArea)->( dbGoTop() )
        _nIndiceActivo := ++nIndice
        ABM2Redibuja( .t. )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EjecutaOpcion()
 * Descripci�n: Ejecuta las opciones del usuario.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2EjecutaOpcion()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local nItem    /*as numeric*/           // Numero del item seleccionado.
        local bBloque  as codebloc              // Bloque de codigo a ejecutar.

        // ------- Inicializaci�n de variables.----------------------------------------
        nItem   := wndABM2Edit .cbOpciones. Value
        bBloque := _aOpciones[ nItem, ABM_OPC_BLOQUE ]

        // ------- Ejecuta la opci�n.--------------------------------------------------
        Eval( bBloque )

        // ------- Refresca el browse.
        ABM2Redibuja( .t. )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Editar( lNuevo )
 * Descripci�n: Creaci�n de la ventana de edici�n de registro.
 *  Par�metros: lNuevo          Valor l�gico que indica si se est� a�adiendo un registro
 *                              o editando el actual.
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2Editar( lNuevo )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local i              as numeric         // Indice de iteraci�n.
        local nAnchoEtiqueta /*as numeric*/     // Ancho m�ximo de las etiquetas.
        local nAltoControl   /*as numeric*/     // Alto total de los controles de edici�n.
        local nAncho         /*as numeric*/     // Ancho de la ventana de edici�n .
        local nAlto          /*as numeric*/     // Alto de la ventana de edici�n.
        local nAnchoTope     /*as numeric*/     // Ancho m�ximo de la ventana de edici�n.
        local nAltoTope      /*as numeric*/     // Alto m�ximo de la ventana de edici�n.
        local nAnchoSplit    /*as numeric*/     // Ancho de la ventana Split.
        local nAltoSplit     /*as numeric*/     // Alto de la ventana Split.
        local cTitulo        as character       // T�tulo de la ventana.
        local cMascara       as character       // M�scara de edici�n de los controles num�ricos.
        local nAnchoControl  /*as numeric*/
        local cMacroTemp     as character

        // ------- Control de par�metros.----------------------------------------------
        if ValType( lNuevo ) != "L"
                lNuevo := .t.
        endif

        // ------- Incializaci�n de variables.-----------------------------------------
        nAnchoEtiqueta := 0
        nAnchoControl  := 0
        nAltoControl   := 0
        for i := 1 to Len( _aEtiqueta )
                nAnchoEtiqueta := iif( nAnchoEtiqueta > _aEtiqueta[ i, ABM_LBL_WIDTH ], ;
                        nAnchoEtiqueta, ;
                        _aEtiqueta[ i, ABM_LBL_WIDTH ] )
                nAnchoControl  := iif( nAnchoControl > _aControl[ i, ABM_CON_WIDTH ], ;
                        nAnchoControl, ;
                        _aControl[ i, ABM_CON_WIDTH ] )
                nAltoControl   += _aControl[ i, ABM_CON_HEIGHT ] + 10
        next
        nAltoSplit  := 10 + nAltoControl + 25
        nAnchoSplit := 10 + nAnchoEtiqueta + 10 + nAnchoControl + 25
        nAlto       := 80 + nAltoSplit + 15 + iif( IsXPThemeActive(), 10, 0 )
        nAltoTope   := _nAltoPantalla - 130
        nAncho      := 15 + nAnchoSplit + 15
        nAncho      := iif( nAncho < 300, 300, nAncho )
        nAnchoTope  := _nAnchoPantalla - 60
        cTitulo     := iif( lNuevo, _HMG_aLangLabel[ 6 ], _HMG_aLangLabel[ 7 ] )

        // ------- Define la ventana de edici�n de registro.---------------------------
        define window wndABM2EditNuevo                                  ;
                at 70, 40                                               ;
                width iif( nAncho > nAnchoTope, nAnchoTope, nAncho )    ;
                height iif( nAlto > nAltoTope, nAltoTope, nAlto )       ;
                title cTitulo                                           ;
                modal                                                   ;
                nosize                                                  ;
                nosysmenu                                               ;
                font _GetSysFont() size 9

        // Define la barra de estado de la ventana de edici�n de registro.
        define statusbar font _GetSysFont() size 9
                statusitem ""
        end statusbar

        define splitbox

        // Define la barra de botones de la ventana de edici�n de registro.
        define toolbar tbEditNuevo buttonsize 100, 32 flat righttext
        button tbbCancelar caption _HMG_aLangButton[ 7 ]          ;
                picture "MINIGUI_EDIT_CANCEL"        ;
                action  wndABM2EditNuevo.Release
        button tbbAceptar  caption _HMG_aLangButton[ 8 ]          ;
                picture "MINIGUI_EDIT_OK"            ;
                action  ABM2EditarGuardar( lNuevo )
        button tbbCopiar   caption _HMG_aLangButton[ 9 ]          ;
                picture "MINIGUI_EDIT_COPY"          ;
                action  ABM2EditarCopiar()
        end toolbar

        // Define la ventana donde van contenidos los controles de edici�n.
        define window wndABM2EditNuevoSplit             ;
                width iif( nAncho > nAnchoTope,         ;
                nAnchoTope - 10,             ;
                nAnchoSplit  - 1 )           ;
                height iif( nAlto > nAltoTope,          ;
                nAltoTope - 95,             ;
                nAltoSplit - 1 )            ;
                virtual width nAnchoSplit               ;
                virtual height nAltoSplit               ;
                splitchild                              ;
                nocaption                               ;
                font _GetSysFont() size 9             ;
                focused
        end window
        end splitbox
        end window

        // ------- Define las etiquetas de los controles.------------------------------
        for i := 1 to Len( _aEtiqueta )

                cMacroTemp := _aEtiqueta[ i, ABM_LBL_NAME ]
                @ _aEtiqueta[ i, ABM_LBL_ROW ], _aEtiqueta[ i, ABM_LBL_COL ]  ;
                        label &cMacroTemp                               ;
                        of wndABM2EditNuevoSplit                        ;
                        value _aNombreCampo[ i ]                        ;
                        width _aEtiqueta[ i, ABM_LBL_WIDTH ]            ;
                        height _aEtiqueta[ i, ABM_LBL_HEIGHT ]          ;
                        vcenteralign                                    ;
                        font _GetSysFont() size 9
        next

        // ------- Define los controles de edici�n.------------------------------------
        for i := 1 to Len( _aControl )
                do case
                case _aControl[ i, ABM_CON_TYPE ] == ABM_TEXTBOXC

                        cMacroTemp := _aControl[ i, ABM_CON_NAME ]
                        @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
                                textbox &cMacroTemp                             ;
                                of wndABM2EditNuevoSplit                        ;
                                value ""                                        ;
                                height _aControl[ i, ABM_CON_HEIGHT ]           ;
                                width _aControl[ i, ABM_CON_WIDTH ]             ;
                                font "arial" size 9                             ;
                                maxlength _aEstructura[ i, DBS_LEN ]            ;
                                on gotfocus ABM2ConFoco()                       ;
                                on lostfocus ABM2SinFoco()                      ;
                                on enter ABM2AlEntrar()
                case _aControl[ i, ABM_CON_TYPE ] == ABM_DATEPICKER
                        cMacroTemp := _aControl[ i, ABM_CON_NAME ]
                        @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
                                datepicker &cMacroTemp                          ;
                                of wndABM2EditNuevoSplit                        ;
                                height _aControl[ i, ABM_CON_HEIGHT ]           ;
                                width _aControl[ i, ABM_CON_WIDTH ] + 25        ;
                                font "arial" size 9                             ;
                                SHOWNONE                                        ;
                                on gotfocus ABM2ConFoco()                       ;
                                on lostfocus ABM2SinFoco()
                case _aControl[ i, ABM_CON_TYPE ] == ABM_TEXTBOXN
                        if _aEstructura[ i, DBS_DEC ] == 0
                                cMacroTemp := _aControl[ i, ABM_CON_NAME ]
                                @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
                                        textbox &cMacroTemp                             ;
                                        of wndABM2EditNuevoSplit                        ;
                                        value ""                                        ;
                                        height _aControl[ i, ABM_CON_HEIGHT ]           ;
                                        width _aControl[ i, ABM_CON_WIDTH ]             ;
                                        numeric                                         ;
                                        font "arial" size 9                             ;
                                        maxlength _aEstructura[ i, DBS_LEN ]            ;
                                        on gotfocus ABM2ConFoco( i )                    ;
                                        on lostfocus ABM2SinFoco( i )                   ;
                                        on enter ABM2AlEntrar()
                        else
                                cMascara := Replicate( "9", _aEstructura[ i, DBS_LEN ] - ( _aEstructura[ i, DBS_DEC ] + 1 ) )
                                cMascara += "."
                                cMascara += Replicate( "9", _aEstructura[ i, DBS_DEC ] )
                                cMacroTemp := _aControl[ i, ABM_CON_NAME ]
                                @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
                                        textbox &cMacroTemp                             ;
                                        of wndABM2EditNuevoSplit                        ;
                                        value ""                                        ;
                                        height _aControl[ i, ABM_CON_HEIGHT ]           ;
                                        width _aControl[ i, ABM_CON_WIDTH ]             ;
                                        numeric                                         ;
                                        inputmask cMascara                              ;
                                        on gotfocus ABM2ConFoco()                       ;
                                        on lostfocus ABM2SinFoco()                      ;
                                        on enter ABM2AlEntrar()
                        endif
                case _aControl[ i, ABM_CON_TYPE ] == ABM_CHECKBOX
                        cMacroTemp := _aControl[ i, ABM_CON_NAME ]
                        @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
                                checkbox &cMacroTemp                            ;
                                of wndABM2EditNuevoSplit                        ;
                                caption ""                                      ;
                                height _aControl[ i, ABM_CON_HEIGHT ]           ;
                                width _aControl[ i, ABM_CON_WIDTH ]             ;
                                value .f.                                       ;
                                on gotfocus ABM2ConFoco()                       ;
                                on lostfocus ABM2SinFoco()
                case _aControl[ i, ABM_CON_TYPE ] == ABM_EDITBOX
                        cMacroTemp := _aControl[ i, ABM_CON_NAME ]
                        @ _aControl[ i, ABM_CON_ROW ], _aControl[ i, ABM_CON_COL ]    ;
                                editbox &cMacroTemp                             ;
                                of wndABM2EditNuevoSplit                        ;
                                width _aControl[ i, ABM_CON_WIDTH ]             ;
                                height _aControl[ i, ABM_CON_HEIGHT ]           ;
                                value ""                                        ;
                                font "arial" size 9                             ;
                                on gotfocus ABM2ConFoco()                       ;
                                on lostfocus ABM2SinFoco()
                endcase
        next

        // ------- Actualiza los controles si se est� editando.------------------------
        if !lNuevo
                for i := 1 to Len( _aControl )
                        SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value", ( _cArea )->( FieldGet( i ) ) )
                next
        endif

        // ------- Establece el estado inicial de los controles.-----------------------
        for i := 1 to Len( _aControl )
                SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Enabled", _aEditable[ i ] )
        next

        // ------- Establece el estado del bot�n de copia.-----------------------------
        if !lNuevo
                wndABM2EditNuevo .tbbCopiar. Enabled := .f.
        endif

        // ------- Activa la ventana de edici�n de registro.---------------------------
        on key escape ;
                of wndABM2EditNuevoSplit ;
                action wndABM2EditNuevo .tbbCancelar. onclick

        on key return ;
                of wndABM2EditNuevoSplit ;
                action wndABM2EditNuevo .tbbAceptar. onclick

        activate window wndABM2EditNuevo

return NIL


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
static function ABM2ConFoco()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local i         /*as numeric*/          // Indice de iteraci�n.
        local cControl  as character            // Nombre del control activo.
        local acControl /*as array*/            // Matriz con los nombre de los controles.

        // ------- Inicializaci�n de variables.----------------------------------------
        cControl := This.Name
        acControl := {}
        for i := 1 to Len( _aControl )
                aAdd( acControl, _aControl[ i, ABM_CON_NAME ] )
        next
        _nControlActivo := aScan( acControl, cControl )

        // ------- Pone la etiqueta en negrita.----------------------------------------
        SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .t. )

        // ------- Presenta el mensaje en la barra de estado.--------------------------
        wndABM2EditNuevo .StatusBar. Item( 1 ) := _aControl[ _nControlActivo, ABM_CON_DES ]

return nil


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2SinFoco()
 * Descripci�n: Restaura el estado de las etiquetas y de la barra de estado de la ventana
 *              de edici�n de registros al dejar un control de edici�n sin foco.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2SinFoco()

        // ------- Restaura el estado de la etiqueta.----------------------------------
        SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .f. )

        // ------- Restaura el texto de la barra de estado.----------------------------
        wndABM2EditNuevo .StatusBar. Item( 1 ) := ""

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2AlEntrar()
 * Descripci�n: Cambia al siguiente control de edici�n tipo TEXTBOX al pulsar la tecla
 *              ENTER.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2AlEntrar()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local lSalida   /*as logical*/              // Tipo de salida.
        local nTipo     /*as numeric*/              // Tipo del control.

        // ------- Inicializa las variables.-------------------------------------------
        lSalida := .t.

        // ------- Restaura el estado de la etiqueta.----------------------------------
        SetProperty( "wndABM2EditNuevoSplit", _aEtiqueta[ _nControlActivo, ABM_LBL_NAME ], "FontBold", .f. )

        // ------- Activa el siguiente control editable con evento ON ENTER.-----------
        do while lSalida
                _nControlActivo++
                if _nControlActivo > Len( _aControl )
                        _nControlActivo := 1
                endif
                nTipo := _aControl[ _nControlActivo, ABM_CON_TYPE ]
                if nTipo == ABM_TEXTBOXC .or. nTipo == ABM_TEXTBOXN
                        if _aEditable[ _nControlActivo ]
                                lSalida := .f.
                        endif
                endif
        enddo

        Domethod( "wndABM2EditNuevoSplit", _aControl[ _nControlActivo, ABM_CON_NAME ], "SetFocus" )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EditarGuardar( lNuevo )
 * Descripci�n: A�ade o guarda el registro en la bdd.
 *  Par�metros: lNuevo          Valor l�gico que indica si se est� a�adiendo un registro
 *                              o editando el actual.
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2EditarGuardar( lNuevo )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local i          /*as numeric*/             // Indice de iteraci�n.
        local xValor                                // Valor a guardar.
        local lResultado /*as logical*/             // Resultado del bloque del usuario.
        local aValores   /*as array*/               // Valores del registro.

        // ------- Guarda el registro.-------------------------------------------------
        if _bGuardar == NIL

                // No hay bloque de c�digo del usuario.
                if lNuevo
                        ( _cArea )->( dbAppend() )
                endif

                if ( _cArea )->( rlock() )

                        for i := 1 to Len( _aEstructura )
                                xValor := GetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value" )
                                ( _cArea )->( FieldPut( i, xValor ) )
                        next

                        ( _cArea )->( dbunlock() )

                        // Refresca la ventana de visualizaci�n.
                        wndABM2EditNuevo.Release
                        ABM2Redibuja( .t. )

                else
                        Msgstop ( _HMG_aLangUser[41 ], _cTitulo )
                endif
        else

                // Hay bloque de c�digo del usuario.
                aValores := {}
                for i := 1 to Len( _aControl )
                        xValor := GetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value" )
                        aAdd( aValores, xValor )
                next
                lResultado := Eval( _bGuardar, aValores, lNuevo )
                if ValType( lResultado ) != "L"
                        lResultado := .t.
                endif

                // Refresca la ventana de visualizaci�n.
                if lResultado
                        wndABM2EditNuevo.Release
                        ABM2Redibuja( .t. )
                endif
        endif

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Seleccionar()
 * Descripci�n: Presenta una ventana para la selecci�n de un registro.
 *  Par�metros: Ninguno
 *    Devuelve: [nReg]          Numero de registro seleccionado, o cero si no se ha
 *                              seleccionado ninguno.
****************************************************************************************/
static function ABM2Seleccionar()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local lSalida   as logical              // Control de bucle.
        local nReg      as numeric              // Valores del registro
        local nRegistro /*as numeric*/          // N�mero de registro.

        // ------- Inicializaci�n de variables.----------------------------------------
        lSalida   := .f.
        nReg      := 0
        nRegistro := ( _cArea )->( RecNo() )

        // ------- Se situa en el primer registro.-------------------------------------
        ( _cArea )->( dbGoTop() )

        // ------- Creaci�n de la ventana de selecci�n de registro.--------------------
        define window wndSeleccionar            ;
                at 0, 0                         ;
                width 500                       ;
                height 300                      ;
                title _HMG_aLangLabel[ 8 ]      ;
                modal                           ;
                nosize                          ;
                nosysmenu                       ;
                font _GetSysFont() size 9

        // Define la barra de botones de la ventana de selecci�n.
        define toolbar tbSeleccionar buttonsize 100, 32 flat righttext border
        button tbbCancelarSel caption _HMG_aLangButton[ 7 ]               ;
                picture "MINIGUI_EDIT_CANCEL"             ;
                action  {|| lSalida := .f.,               ;
                nReg    := 0,                 ;
                wndSeleccionar.Release }
        button tbbAceptarSel  caption _HMG_aLangButton[ 8 ]                       ;
                picture "MINIGUI_EDIT_OK"                                         ;
                action  {|| lSalida := .t.,                                       ;
                nReg    := wndSeleccionar .brwSeleccionar. Value,       ;
                wndSeleccionar.Release }
        end toolbar

        // Define la barra de estado de la ventana de selecci�n.
        define statusbar font _GetSysFont() size 9
                statusitem _HMG_aLangUser[ 7 ]
        end statusbar

        // Define la tabla de la ventana de selecci�n.
        @ 55, 20 browse brwSeleccionar                                          ;
                width 460                                                       ;
                height 190                                                      ;
                headers _aCabeceraTabla                                         ;
                widths _aAnchoTabla                                             ;
                workarea &_cArea                                                ;
                fields _aCampoTabla                                             ;
                value ( _cArea )->( RecNo() )                                   ;
                font "arial" size 9                                             ;
                on dblclick {|| lSalida := .t.,                                 ;
                nReg := wndSeleccionar .brwSeleccionar. Value,    ;
                wndSeleccionar.Release }                        ;
                justify _aAlineadoTabla paintdoublebuffer

        end window

        // ------- Activa la ventana de selecci�n de registro.-------------------------
        center window wndSeleccionar
        activate window wndSeleccionar

        // ------- Restuara el puntero de registro.------------------------------------
        ( _cArea )->( dbGoTo( nRegistro ) )

return ( nReg )


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EditarCopiar()
 * Descripci�n: Copia el registro seleccionado en los controles de edici�n del nuevo
 *              registro.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2EditarCopiar()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local i         /*as numeric*/          // Indice de iteraci�n.
        local nRegistro /*as numeric*/          // Puntero de registro.
        local nReg      /*as numeric*/          // Numero de registro.

        // ------- Obtiene el registro a copiar.---------------------------------------
        nReg := ABM2Seleccionar()

        // ------- Actualiza los controles de edici�n.---------------------------------
        if nReg != 0
                nRegistro := ( _cArea )->( RecNo() )
                ( _cArea )->( dbGoTo( nReg ) )
                for i := 1 to Len( _aControl )
                        if _aEditable[ i ]
                                SetProperty( "wndABM2EditNuevoSplit", _aControl[ i, ABM_CON_NAME ], "Value", ( _cArea )->( FieldGet( i ) ) )
                        endif
                next
                ( _cArea )->( dbGoTo( nRegistro ) )
        endif

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Borrar()
 * Descripci�n: Borra el registro activo.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2Borrar()

        // ------- Borra el registro si se acepta.-------------------------------------
        if MsgOKCancel( _HMG_aLangUser[ 8 ], _HMG_aLangLabel[ 16 ] )
                if ( _cArea )->( rlock() )
                        ( _cArea )->( dbDelete() )
                        ( _cArea )->( dbCommit() )
                        ( _cArea )->( dbunlock() )
                        if set( _SET_DELETED )
                                ( _cArea )->( dbSkip() )
                                if ( _cArea )->( eof() )
                                        ( _cArea )->( dbGoBottom() )
                                endif
                        endif
                        ABM2Redibuja( .t. )
                else
                        Msgstop( _HMG_aLangUser[41 ], _cTitulo )
                endif
        endif

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Recover()
 * Descripci�n: Restaurar el registro activo.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2Recover()

        // ------- Restaurar el registro si se acepta.-----------------------------------
        if MsgOKCancel( _HMG_aLangUser[ 42 ], StrTran( _HMG_aLangButton[ 12 ], "&", "" ) )
                if ( _cArea )->( rlock() )
                        ( _cArea )->( dbRecall() )
                        ( _cArea )->( dbCommit() )
                        ( _cArea )->( dbunlock() )
                        ABM2Redibuja( .t. )
                else
                        Msgstop( _HMG_aLangUser[41 ], _cTitulo )
                endif
        endif

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Buscar()
 * Descripci�n: Busca un registro por la clave del indice activo.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2Buscar()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local nControl   /*as numeric*/         // Numero del control.
        local lSalida    as logical             // Tipo de salida de la ventana.
        local xValor                            // Valor de busqueda.
        local cMascara   as character           // Mascara de edici�n del control.
        local lResultado /*as logical*/         // Resultado de la busqueda.
        local nRegistro  /*as numeric*/         // Numero de registro.

        // ------- Inicializaci�n de variables.----------------------------------------
        nControl := _aIndiceCampo[ _nIndiceActivo ]

        // ------- Comprueba si se ha pasado una acci�n del usuario.--------------------
        if _bBuscar != NIL
                // msgInfo( "ON FIND" )
                Eval( _bBuscar )
                ABM2Redibuja( .t. )
                return NIL
        endif

        // ------- Comprueba si hay un indice activo.----------------------------------
        if _nIndiceActivo == 1
                msgExclamation( _HMG_aLangUser[ 9 ], _cTitulo )
                return NIL
        endif

        // ------- Comprueba que el campo indice no es del tipo memo o logico.---------
        if _aEstructura[ nControl, DBS_TYPE ] == "L" .or. _aEstructura[ nControl, DBS_TYPE ] == "M"
                msgExclamation( _HMG_aLangUser[ 10 ], _cTitulo )
                return NIL
        endif

        // ------- Crea la ventana de busqueda.----------------------------------------
        define window wndABMBuscar              ;
                at 0, 0                         ;
                width 500                       ;
                height 170                      ;
                title _HMG_aLangLabel[ 9 ]      ;
                modal                           ;
                nosize                          ;
                nosysmenu                       ;
                font _GetSysFont() size 9

        // Define la barra de botones de la ventana de busqueda.
        define toolbar tbBuscar buttonsize 100, 32 flat righttext border
        button tbbCancelarBus caption _HMG_aLangButton[ 7 ]         ;
                picture "MINIGUI_EDIT_CANCEL"                       ;
                action  {|| lSalida := .f.,                         ;
                xValor := wndABMBuscar .conBuscar. Value,           ;
                wndABMBuscar.Release }
        button tbbAceptarBus  caption _HMG_aLangButton[ 8 ]         ;
                picture "MINIGUI_EDIT_OK"                           ;
                action  {|| lSalida := .t.,                         ;
                xValor := wndABMBuscar .conBuscar. Value,           ;
                wndABMBuscar.Release }
        end toolbar

        // Define la barra de estado de la ventana de busqueda.
        define statusbar font _GetSysFont() size 9
                statusitem ""
        end statusbar
        end window

        // ------- Crea los controles de la ventana de busqueda.-----------------------
        // Frame.
        @ 45, 10 frame frmBuscar                        ;
                of wndABMBuscar                         ;
                caption ""                              ;
                width wndABMBuscar.Width - 25           ;
                height wndABMBuscar.Height - 100

        // Etiqueta.
        @ 60, 20 label lblBuscar                                ;
                of wndABMBuscar                                 ;
                value _aNombreCampo[ nControl ]                 ;
                width _aEtiqueta[ nControl, ABM_LBL_WIDTH ]     ;
                height _aEtiqueta[ nControl, ABM_LBL_HEIGHT ]   ;
                font _GetSysFont() size 9

        // Tipo de dato a buscar.
        do case

                // Car�cter.
        case _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXC
                @ 75, 20  textbox conBuscar                             ;
                        of wndABMBuscar                                 ;
                        value ""                                        ;
                        height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
                        width _aControl[ nControl, ABM_CON_WIDTH ]      ;
                        font "arial" size 9                             ;
                        maxlength _aEstructura[ nControl, DBS_LEN ]

                // Fecha.
        case _aControl[ nControl, ABM_CON_TYPE ] == ABM_DATEPICKER
                @ 75, 20 datepicker conBuscar                           ;
                        of wndABMBuscar                                 ;
                        value Date()                                    ;
                        height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
                        width _aControl[ nControl, ABM_CON_WIDTH ] + 25 ;
                        font "arial" size 9

                // Numerico.
        case _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXN
                if _aEstructura[ nControl, DBS_DEC ] == 0

                        // Sin decimales.
                        @ 75, 20 textbox conBuscar                              ;
                                of wndABMBuscar                                 ;
                                value ""                                        ;
                                height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
                                width _aControl[ nControl, ABM_CON_WIDTH ]      ;
                                numeric                                         ;
                                font "arial" size 9                             ;
                                maxlength _aEstructura[ nControl, DBS_LEN ]
                else

                        // Con decimales.
                        cMascara := Replicate( "9", _aEstructura[ nControl, DBS_LEN ] - ( _aEstructura[ nControl, DBS_DEC ] + 1 ) )
                        cMascara += "."
                        cMascara += Replicate( "9", _aEstructura[ nControl, DBS_DEC ] )
                        @ 75, 20 textbox conBuscar                              ;
                                of wndABMBuscar                                 ;
                                value ""                                        ;
                                height _aControl[ nControl, ABM_CON_HEIGHT ]    ;
                                width _aControl[ nControl, ABM_CON_WIDTH ]      ;
                                numeric                                         ;
                                inputmask cMascara
                endif
        endcase

        // ------- Actualiza la barra de estado.---------------------------------------
        wndABMBuscar .StatusBar. Item( 1 ) := _aControl[ nControl, ABM_CON_DES ]

        // ------- Comprueba el tama�o del control de edici�n del dato a buscar.-------
        if wndABMBuscar .conBuscar. Width > wndABM2Edit.Width - 45
                wndABMBuscar .conBuscar. Width := wndABM2Edit.Width - 45
        endif

        // ------- Activa la ventana de busqueda.--------------------------------------
        on key escape ;
                of wndABMBuscar ;
                action wndABMBuscar .tbbCancelarBus. onclick

        on key return ;
                of wndABMBuscar ;
                action wndABMBuscar .tbbAceptarBus. onclick

        center window wndABMBuscar
        activate window wndABMBuscar

        // ------- Busca el registro.--------------------------------------------------
        if lSalida
                nRegistro := ( _cArea )->( RecNo() )
                lResultado := ( _cArea )->( dbSeek( xValor ) )
                if !lResultado
                        msgExclamation( _HMG_aLangUser[ 11 ], _cTitulo )
                        ( _cArea )->( dbGoTo( nRegistro ) )
                else
                        ABM2Redibuja( .t. )
                endif
        endif

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2ActivarFiltro()
 * Descripci�n: Filtra la base de datos.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2ActivarFiltro()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local aCompara   /*as array*/               // Comparaciones.
        local aCampos    /*as array*/               // Nombre de los campos.

        // ------- Comprueba que no hay ningun filtro activo.--------------------------
        if _cFiltro != ""
                MsgInfo( _HMG_aLangUser[ 34 ], '' )
        endif

        // ------- Inicializaci�n de variables.----------------------------------------
        aCampos    := _aNombreCampo
        aCompara   := { _HMG_aLangLabel[ 27 ], ;
                _HMG_aLangLabel[ 28 ], ;
                _HMG_aLangLabel[ 29 ], ;
                _HMG_aLangLabel[ 30 ], ;
                _HMG_aLangLabel[ 31 ], ;
                _HMG_aLangLabel[ 32 ] }


        // ------- Crea la ventana de filtrado.----------------------------------------
        define window wndABM2Filtro                     ;
                at 0, 0                                 ;
                width 400                               ;
                height 325                              ;
                title _HMG_aLangLabel[ 21 ]             ;
                modal                                   ;
                nosize                                  ;
                nosysmenu                               ;
                on init {|| ABM2ControlFiltro() }       ;
                font _GetSysFont() size 9

        // Define la barra de botones de la ventana de filtrado.
        define toolbar tbBuscar buttonsize 100, 32 flat righttext border
        button tbbCancelarFil caption _HMG_aLangButton[ 7 ]           ;
                picture "MINIGUI_EDIT_CANCEL"     ;
                action  {|| wndABM2Filtro.Release, ;
                ABM2Redibuja( .f. ) }
        button tbbAceptarFil  caption _HMG_aLangButton[ 8 ]           ;
                picture "MINIGUI_EDIT_OK"         ;
                action  {|| ABM2EstableceFiltro() }
        end toolbar

        // Define la barra de estado de la ventana de filtrado.
        define statusbar font _GetSysFont() size 9
                statusitem ""
        end statusbar
        end window

        // ------- Controles de la ventana de filtrado.
        // Frame.
        @ 45, 10 frame frmFiltro                ;
                of wndABM2Filtro                ;
                caption ""                      ;
                width wndABM2Filtro.Width - 25  ;
                height wndABM2Filtro.Height - 100
        @ 65, 20 label lblCampos                ;
                of wndABM2Filtro                ;
                value _HMG_aLangLabel[ 22 ]     ;
                width 140                       ;
                height 25                       ;
                font _GetSysFont() size 9
        @ 65, 220 label lblCompara              ;
                of wndABM2Filtro                ;
                value _HMG_aLangLabel[ 23 ]     ;
                width 140                       ;
                height 25                       ;
                font _GetSysFont() size 9
        @ 200, 20 label lblValor                ;
                of wndABM2Filtro                ;
                value _HMG_aLangLabel[ 24 ]     ;
                width 140                       ;
                height 25                       ;
                font _GetSysFont() size 9
        @ 85, 20 listbox lbxCampos                      ;
                of wndABM2Filtro                        ;
                width 140                               ;
                height 100                              ;
                items aCampos                           ;
                value 1                                 ;
                font "Arial" size 9                     ;
                on change {|| ABM2ControlFiltro() }     ;
                on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) := _HMG_aLangLabel[ 25 ] ;
                on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""
        @ 85, 220 listbox lbxCompara                    ;
                of wndABM2Filtro                        ;
                width 140                               ;
                height 100                              ;
                items aCompara                          ;
                value 1                                 ;
                font "Arial" size 9                     ;
                on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) := _HMG_aLangLabel[ 26 ] ;
                on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""
        @ 220, 20 textbox conValor              ;
                of wndABM2Filtro                ;
                value ""                        ;
                height 25                       ;
                width 160                       ;
                font "arial" size 9             ;
                maxlength 16

        // ------- Activa la ventana.
        center window wndABM2Filtro
        activate window wndABM2Filtro

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2ControlFiltro()
 * Descripci�n: Comprueba que el filtro se puede aplicar.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2ControlFiltro()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local nControl /*as numeric*/
        local cMascara as character
        local cMensaje as character

        // ------- Inicializa las variables.
        nControl := wndABM2Filtro .lbxCampos. Value

        // ------- Comprueba que se puede crear el control.----------------------------
        if _aEstructura[ nControl, DBS_TYPE ] == "M"
                msgExclamation( _HMG_aLangUser[ 35 ], _cTitulo )
                return NIL
        endif
        if nControl == 0
                msgExclamation( _HMG_aLangUser[ 36 ], _cTitulo )
                return NIL
        endif

        // ------- Crea el nuevo control.----------------------------------------------
        wndABM2Filtro .conValor. Release
        cMensaje := _aControl[ nControl, ABM_CON_DES ]
        do case

                // Car�cter.
        case _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXC
                @ 226, 20  textbox conValor                                     ;
                        of wndABM2Filtro                                        ;
                        value ""                                                ;
                        height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
                        width _aControl[ nControl, ABM_CON_WIDTH ]              ;
                        font "arial" size 9                                     ;
                        maxlength _aEstructura[ nControl, DBS_LEN ]             ;
                        on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
                                    cMensaje                                    ;
                        on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

                // Fecha.
        case _aControl[ nControl, ABM_CON_TYPE ] == ABM_DATEPICKER
                @ 226, 20 datepicker conValor                                   ;
                        of wndABM2Filtro                                        ;
                        value Date()                                            ;
                        height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
                        width _aControl[ nControl, ABM_CON_WIDTH ] + 25         ;
                        font "arial" size 9                                     ;
                        on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
                                    cMensaje                                    ;
                        on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

                // Numerico.
        case _aControl[ nControl, ABM_CON_TYPE ] == ABM_TEXTBOXN
                if _aEstructura[ nControl, DBS_DEC ] == 0

                        // Sin decimales.
                        @ 226, 20 textbox conValor                                      ;
                                of wndABM2Filtro                                        ;
                                value ""                                                ;
                                height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
                                width _aControl[ nControl, ABM_CON_WIDTH ]              ;
                                numeric                                                 ;
                                font "arial" size 9                                     ;
                                maxlength _aEstructura[ nControl, DBS_LEN ]             ;
                                on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
                                            cMensaje                                    ;
                                on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

                else

                        // Con decimales.
                        cMascara := Replicate( "9", _aEstructura[ nControl, DBS_LEN ] - ( _aEstructura[ nControl, DBS_DEC ] + 1 ) )
                        cMascara += "."
                        cMascara += Replicate( "9", _aEstructura[ nControl, DBS_DEC ] )
                        @ 226, 20 textbox conValor                                      ;
                                of wndABM2Filtro                                        ;
                                value ""                                                ;
                                height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
                                width _aControl[ nControl, ABM_CON_WIDTH ]              ;
                                numeric                                                 ;
                                inputmask cMascara                                      ;
                                on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
                                            cMensaje                                    ;
                                on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""
                endif

                // Logico
        case _aControl[ nControl, ABM_CON_TYPE ] == ABM_CHECKBOX
                @ 226, 20 checkbox conValor                                     ;
                        of wndABM2Filtro                                        ;
                        caption ""                                              ;
                        height _aControl[ nControl, ABM_CON_HEIGHT ]            ;
                        width _aControl[ nControl, ABM_CON_WIDTH ]              ;
                        value .f.                                               ;
                        on gotfocus wndABM2Filtro .StatusBar. Item( 1 ) :=      ;
                                    cMensaje                                    ;
                        on lostfocus wndABM2Filtro .StatusBar. Item( 1 ) := ""

        endcase

        // ------- Actualiza el valor de la etiqueta.----------------------------------
        wndABM2Filtro .lblValor. Value := _aNombreCampo[ nControl ]

        // ------- Comprueba el tama�o del control de edici�n del dato a buscar.-------
        if wndABM2Filtro .conValor. Width > wndABM2Filtro.Width - 45
                wndABM2Filtro .conValor. Width := wndABM2Filtro.Width - 45
        endif

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2EstableceFiltro()
 * Descripci�n: Establece el filtro seleccionado.
 *  Par�metros: Ninguno.
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2EstableceFiltro()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local aOperador  /*as array*/
        local nCampo     /*as numeric*/
        local nCompara   /*as numeric*/
        local cValor     as character

        // ------- Inicializaci�n de variables.----------------------------------------
        nCompara  := wndABM2Filtro .lbxCompara. Value
        nCampo    := wndABM2Filtro .lbxCampos. Value
        cValor    := HB_ValToStr( wndABM2Filtro .conValor. Value )
        aOperador := { "=", "<>", ">", "<", ">=", "<=" }

        // ------- Comprueba que se puede filtrar.-------------------------------------
        if nCompara == 0
                msgExclamation( _HMG_aLangUser[ 37 ], _cTitulo )
                return NIL
        endif
        if nCampo == 0
                msgExclamation( _HMG_aLangUser[ 36 ], _cTitulo )
                return NIL
        endif
        if cValor == ""
                msgExclamation( _HMG_aLangUser[ 38 ], _cTitulo )
                return NIL
        endif
        if _aEstructura[ nCampo, DBS_TYPE ] == "M"
                msgExclamation( _HMG_aLangUser[ 35 ], _cTitulo )
                return NIL
        endif

        // ------- Establece el filtro.------------------------------------------------
        do case
        case _aEstructura[ nCampo, DBS_TYPE ] == "C"
                _cFiltro := "Upper(" + _cArea + "->" + ;
                        _aEstructura[ nCampo, DBS_NAME ] + ")" + ;
                        aOperador[ nCompara ]
                _cFiltro += "'" + Upper( AllTrim( cValor ) ) + "'"

        case _aEstructura[ nCampo, DBS_TYPE ] == "N"
                _cFiltro := _cArea + "->" + ;
                        _aEstructura[ nCampo, DBS_NAME ] + ;
                        aOperador[ nCompara ]
                _cFiltro += AllTrim( cValor )

        case _aEstructura[ nCampo, DBS_TYPE ] == "D"
                _cFiltro := _cArea + "->" + ;
                        _aEstructura[ nCampo, DBS_NAME ] + ;
                        aOperador[ nCompara ]
                _cFiltro += "CToD(" + "'" + cValor + "')"

        case _aEstructura[ nCampo, DBS_TYPE ] == "L"
                _cFiltro := _cArea + "->" + ;
                        _aEstructura[ nCampo, DBS_NAME ] + ;
                        aOperador[ nCompara ]
                _cFiltro += cValor
        endcase
        ( _cArea )->( dbSetFilter( {|| &_cFiltro }, _cFiltro ) )
        _lFiltro := .t.
        wndABM2Filtro.Release
        ABM2Redibuja( .t. )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2DesactivarFiltro()
 * Descripci�n: Desactiva el filtro si procede.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2DesactivarFiltro()

        // ------- Desactiva el filtro si procede.
        if !_lFiltro
                msgExclamation( _HMG_aLangUser[ 39 ], _cTitulo )
                ABM2Redibuja( .f. )
                return NIL
        endif
        if msgYesNo( _HMG_aLangUser[ 40 ], _cTitulo )
                ( _cArea )->( dbClearFilter( NIL ) )
                _lFiltro := .f.
                _cFiltro := ""
                ABM2Redibuja( .t. )
        endif

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Imprimir()
 * Descripci�n: Presenta la ventana de recogida de datos para la definici�n del listado.
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2Imprimir()

        // ------- Declaraci�n de variables locales.-----------------------------------
        local aCampoBase    /*as array*/        // Campos de la bdd.
        local aCampoListado /*as array*/        // Campos del listado.
        local nRegistro     /*as numeric*/      // Numero de registro actual.
        local nCampo        /*as numeric*/      // Numero de campo.
        local cRegistro1    as character        // Valor del registro inicial.
        local cRegistro2    as character        // Valor del registro final.
        local aImpresoras   as array            // Impresoras disponibles.

        // ------- Comprueba si se ha pasado la clausula ON PRINT.---------------------
        IF _bImprimir != NIL
                // msgInfo( "ON PRINT" )
                Eval( _bImprimir )
                ABM2Redibuja( .T. )
                return NIL
        ENDIF

        // ------- Obtiene las impresoras disponibles.---------------------------------
        aImpresoras := {}
        INIT PRINTSYS
        GET PRINTERS TO aImpresoras
        RELEASE PRINTSYS

        // ------- Comprueba que hay un indice activo.---------------------------------
        if _nIndiceActivo == 1
                msgExclamation( _HMG_aLangUser[ 9 ], _cTitulo )
                return NIL
        endif

        // ------- Inicializaci�n de variables.----------------------------------------
        aCampoListado := {}
        aCampoBase    := _aNombreCampo
        SET DELETED ON
        nRegistro     := ( _cArea )->( RecNo() )
        if ( _cArea )->( Deleted() )
                ( _cArea )->( dbSkip() )
        endif

        // Registro inicial y final.
        nCampo := _aIndiceCampo[ _nIndiceActivo ]
        ( _cArea )->( dbGoTop() )
        cRegistro1 := HB_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
        ( _cArea )->( dbGoBottom() )
        cRegistro2 := HB_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
        ( _cArea )->( dbGoTo( nRegistro ) )

        // ------- Definici�n de la ventana de formato de listado.---------------------
        define window wndABM2Listado            ;
                at 0, 0                         ;
                width 390                       ;
                height 365                      ;
                title _HMG_aLangLabel[ 10 ]       ;
                icon "MINIGUI_EDIT_PRINT"       ;
                modal                           ;
                nosize                          ;
                nosysmenu                       ;
                font _GetSysFont() size 9

        // Define la barra de botones de la ventana de formato de listado.
        define toolbar tbListado buttonsize 100, 32 flat righttext border
        button tbbCancelarLis caption _HMG_aLangButton[ 7 ]               ;
                picture "MINIGUI_EDIT_CANCEL"             ;
                action  wndABM2Listado.Release
        button tbbAceptarLis  caption _HMG_aLangButton[ 8 ]               ;
                picture "MINIGUI_EDIT_OK"                 ;
                action  ABM2Listado( aImpresoras )

        end toolbar

        // Define la barra de estado de la ventana de formato de listado.
        define statusbar font _GetSysFont() size 9
                statusitem ""
        end statusbar
        end window

        // ------- Define los controles de edici�n de la ventana de formato de listado.-
        // Frame.
        @ 45, 10 frame frmListado                       ;
                of wndABM2Listado                       ;
                caption ""                              ;
                width wndABM2Listado.Width - 25         ;
                height wndABM2Listado.Height - 100

        // Label
        @ 65, 20 label lblCampoBase             ;
                of wndABM2Listado               ;
                value _HMG_aLangLabel[ 11 ]       ;
                width 140                       ;
                height 25                       ;
                font _GetSysFont() size 9
        @ 65, 220 label lblCampoListado         ;
                of wndABM2Listado               ;
                value _HMG_aLangLabel[ 12 ]       ;
                width 140                       ;
                height 25                       ;
                font _GetSysFont() size 9
        @ 200, 20 label lblImpresoras           ;
                of wndABM2Listado               ;
                value _HMG_aLangLabel[ 13 ]       ;
                width 140                       ;
                height 25                       ;
                font _GetSysFont() size 9
        @ 200, 170 label lblInicial             ;
                of wndABM2Listado               ;
                value _HMG_aLangLabel[ 14 ]       ;
                width 160                       ;
                height 25                       ;
                font _GetSysFont() size 9
        @ 255, 170 label lblFinal               ;
                of wndABM2Listado               ;
                value _HMG_aLangLabel[ 15 ]       ;
                width 160                       ;
                height 25                       ;
                font _GetSysFont() size 9

        // Listbox.
        @ 85, 20 listbox lbxCampoBase                                           ;
                of wndABM2Listado                                               ;
                width 140                                                       ;
                height 100                                                      ;
                items aCampoBase                                                ;
                value 1                                                         ;
                font "Arial" size 9                                             ;
                on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 12 ] ;
                on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
        @ 85, 220 listbox lbxCampoListado                                       ;
                of wndABM2Listado                                               ;
                width 140                                                       ;
                height 100                                                      ;
                items aCampoListado                                             ;
                value 1                                                         ;
                font "Arial" size 9                                             ;
                on gotFocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 13 ] ;
                on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""

        // ComboBox.
        @ 220, 20 combobox cbxImpresoras                                        ;
                of wndABM2Listado                                               ;
                items aImpresoras                                               ;
                value 1                                                         ;
                width 140                                                       ;
                font "Arial" size 9                                             ;
                on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 14 ] ;
                on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""

        // PicButton.
        @ 90, 170 button btnMas                                                 ;
                of wndABM2Listado                                               ;
                picture "MINIGUI_EDIT_ADD"                                      ;
                action ABM2DefinirColumnas( ABM_LIS_ADD )                       ;
                width 40                                                        ;
                height 40                                                       ;
                on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 15 ] ;
                on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
        @ 140, 170 button btnMenos                                              ;
                of wndABM2Listado                                               ;
                picture "MINIGUI_EDIT_DEL"                                      ;
                action ABM2DefinirColumnas( ABM_LIS_DEL )                       ;
                width 40                                                        ;
                height 40                                                       ;
                on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 16 ] ;
                on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
        @ 220, 170 button btnSet1                                               ;
                of wndABM2Listado                                               ;
                picture "MINIGUI_EDIT_SET"                                      ;
                action ABM2DefinirRegistro( ABM_LIS_SET1 )                      ;
                width 25                                                        ;
                height 25                                                       ;
                on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 17 ] ;
                on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""
        @ 275, 170 button btnSet2                                               ;
                of wndABM2Listado                                               ;
                picture "MINIGUI_EDIT_SET"                                      ;
                action ABM2DefinirRegistro( ABM_LIS_SET2 )                      ;
                width 25                                                        ;
                height 25                                                       ;
                on gotfocus wndABM2Listado .StatusBar. Item( 1 ) := _HMG_aLangUser[ 18 ] ;
                on lostfocus wndABM2Listado .StatusBar. Item( 1 ) := ""

        // CheckBox.
        @ 255, 20 checkbox chkVistas            ;
                of wndABM2Listado               ;
                caption _HMG_aLangLabel[ 18 ]   ;
                width 140                       ;
                height 25                       ;
                value .t.                       ;
                font _GetSysFont() size 9
        @ 275, 20 checkbox chkPrevio            ;
                of wndABM2Listado               ;
                caption _HMG_aLangLabel[ 17 ]   ;
                width 140                       ;
                height 25                       ;
                value .t.                       ;
                font _GetSysFont() size 9

        // Editbox.
        @ 220, 196 textbox txtRegistro1         ;
                of wndABM2Listado               ;
                value cRegistro1                ;
                height 25                       ;
                width 160                       ;
                font "arial" size 9             ;
                maxlength 16
        @ 275, 196 textbox txtRegistro2         ;
                of wndABM2Listado               ;
                value cRegistro2                ;
                height 25                       ;
                width 160                       ;
                font "arial" size 9             ;
                maxlength 16

        // ------- Estado de los controles.--------------------------------------------
        wndABM2Listado .txtRegistro1. Enabled := .f.
        wndABM2Listado .txtRegistro2. Enabled := .f.

        // ------- Comrprueba que la selecci�n de registros es posible.----------------
        nCampo := _aIndiceCampo[ _nIndiceActivo ]
        if _aEstructura[ nCampo, DBS_TYPE ] == "L" .or. _aEstructura[ nCampo, DBS_TYPE ] == "M"
                wndABM2Listado .btnSet1. Enabled := .f.
                wndABM2Listado .btnSet2. Enabled := .f.
        endif

        // ------- Activaci�n de la ventana de formato de listado.---------------------
        center window wndABM2Listado
        activate window wndABM2Listado

        // ------- Restaura.-----------------------------------------------------------
        SET DELETED OFF
        ( _cArea )->( dbGoTo( nRegistro ) )
        ABM2Redibuja( .f. )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2DefinirRegistro( nAccion )
 * Descripci�n:
 *  Par�metros: [nAccion]       Numerico. Indica el tipo de accion realizado.
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2DefinirRegistro( nAccion )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local nRegistro as character            // Puntero de registros.
        local nReg      as character            // Registro seleccionado.
        local cValor    as character            // Valor del registro seleccionado.
        local nCampo    /*as numeric*/          // Numero del campo indice.

        // ------- Inicializa las variables.-------------------------------------------
        nRegistro := ( _cArea )->( RecNo() )

        // ------- Selecciona el registro.---------------------------------------------
        nReg := ABM2Seleccionar()
        if nReg == 0
                ( _cArea )->( dbGoTo( nRegistro ) )
                return NIL
        else
                ( _cArea )->( dbGoTo( nReg ) )
                nCampo := _aIndiceCampo[ _nIndiceActivo ]
                cValor := HB_ValToStr( ( _cArea )->( FieldGet( nCampo ) ) )
        endif

        // ------- Actualiza seg�n la acci�n.------------------------------------------
        do case
        case nAccion == ABM_LIS_SET1
                wndABM2Listado .txtRegistro1. Value := cValor
        case nAccion == ABM_LIS_SET2
                wndABM2Listado .txtRegistro2. Value := cValor
        endcase

        // ------- Restaura el registro.
        ( _cArea )->( dbGoTo( nRegistro ) )

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2DefinirColumnas( nAccion )
 * Descripci�n: Controla el contenido de las listas al pulsar los botones de a�adir y
 *              eliminar campos del listado.
 *  Par�metros: [nAccion]       Numerico. Indica el tipo de accion realizado.
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2DefinirColumnas( nAccion )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local aCampoBase    /*as array*/        // Campos de la bbd.
        local aCampoListado /*as array*/        // Campos del listado.
        local i             /*as numeric*/      // Indice de iteraci�n.
        local nItem         /*as numeric*/      // Numero del item seleccionado.
        local cValor        as character

        // ------- Inicializaci�n de variables.----------------------------------------
        aCampoBase  := {}
        aCampoListado := {}
        for i := 1 to wndABM2Listado .lbxCampoBase. ItemCount
                aAdd( aCampoBase, wndABM2Listado .lbxCampoBase. Item( i ) )
        next
        for i := 1 to wndABM2Listado .lbxCampoListado. ItemCount
                aAdd( aCampoListado, wndABM2Listado .lbxCampoListado. Item( i ) )
        next

        // ------- Ejecuta seg�n la acci�n.--------------------------------------------
        do case
        case nAccion == ABM_LIS_ADD

                // Obtiene la columna a a�adir.
                nItem := wndABM2Listado .lbxCampoBase. Value
                cValor := wndABM2Listado .lbxCampoBase. Item( nItem )

                // Actualiza los datos de los campos de la base.
                if Len( aCampoBase ) == 0
                        msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
                        return NIL
                else
                        wndABM2Listado .lbxCampoBase. DeleteAllItems
                        for i := 1 to Len( aCampoBase )
                                if i != nItem
                                        wndABM2Listado .lbxCampoBase. AddItem( aCampoBase[ i ] )
                                endif
                        next
                        wndABM2Listado .lbxCampoBase. Value := iif( nItem > 1, nItem - 1, 1 )
                endif

                // Actualiza los datos de los campos del listado.
                if Empty( cValor )
                        msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
                        return NIL
                else
                        wndABM2Listado .lbxCampoListado. AddItem( cValor )
                        wndABM2Listado .lbxCampoListado. Value := ;
                                wndABM2Listado .lbxCampoListado. ItemCount
                endif
        case nAccion == ABM_LIS_DEL

                // Obtiene la columna a quitar.
                nItem := wndABM2Listado .lbxCampoListado. Value
                cValor := wndABM2Listado .lbxCampoListado. Item( nItem )

                // Actualiza los datos de los campos del listado.
                if Len( aCampoListado ) == 0
                        msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
                        return NIL
                else
                        wndABM2Listado .lbxCampoListado. DeleteAllItems
                        for i := 1 to Len( aCampoListado )
                                if i != nItem
                                        wndABM2Listado .lbxCampoListado. AddItem( aCampoListado[ i ] )
                                endif
                        next
                        wndABM2Listado .lbxCampoListado. Value := ;
                                wndABM2Listado .lbxCampoListado. ItemCount
                endif

                // Actualiza los datos de los campos de la base.
                if Empty( cValor )
                        msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
                        return NIL
                else
                        wndABM2Listado .lbxCampoBase. DeleteAllItems
                        for i := 1 to Len( _aNombreCampo )
                                if aScan( aCampoBase, _aNombreCampo[ i ] ) != 0
                                        wndABM2Listado .lbxCampoBase. AddItem( _aNombreCampo[ i ] )
                                endif
                                if _aNombreCampo[ i ] == cValor
                                        wndABM2Listado .lbxCampoBase. AddItem( _aNombreCampo[ i ] )
                                endif
                        next
                        wndABM2Listado .lbxCampoBase. Value := 1
                endif
        endcase

return NIL


/****************************************************************************************
 *  Aplicaci�n: Comando EDIT para MiniGUI
 *       Autor: Crist�bal Moll� [cemese@terra.es]
 *     Funci�n: ABM2Listado()
 * Descripci�n: Imprime la selecciona realizada por ABM2Imprimir()
 *  Par�metros: Ninguno
 *    Devuelve: NIL
****************************************************************************************/
static function ABM2Listado( aImpresoras )

        // ------- Declaraci�n de variables locales.-----------------------------------
        local i             /*as numeric*/      // Indice de iteraci�n.
        local cCampo        /*as character*/    // Nombre del campo indice.
        local aCampo        /*as array*/        // Nombres de los campos.
        local nCampo        /*as numeric*/      // Numero del campo actual.
        local nPosicion     /*as numeric*/      // Posici�n del campo.
        local aNumeroCampo  /*as array*/        // Numeros de los campos.
        local aAncho        /*as array*/        // Anchos de las columnas.
        local nAncho        /*as numeric*/      // Ancho de las columna actual.
        local lPrevio       /*as logical*/      // Previsualizar.
        local lVistas       /*as logical*/      // Vistas en miniatura.
        local nImpresora    /*as numeric*/      // Numero de la impresora.
        local cImpresora    as character        // Nombre de la impresora.
        local lOrientacion  /*as logical*/      // Orientaci�n de la p�gina.
        local lSalida       /*as logical*/      // Control de bucle.
        local lCabecera     /*as logical*/      // �Imprimir cabecera?.
        local nFila         /*as numeric*/      // Numero de la fila.
        local nColumna      /*as numeric*/      // Numero de la columna.
        local nPagina       /*as numeric*/      // Numero de p�gina.
        local nPaginas      /*as numeric*/      // P�ginas totales.
        local cPie          as character        // Texto del pie de p�gina.
        local nPrimero      /*as numeric*/      // Numero del primer registro a imprimir.
        local nUltimo       /*as numeric*/      // Numero del ultimo registro a imprimir.
        local nTotales      /*as numeric*/      // Registros totales a imprimir.
        local nRegistro     /*as numeric*/      // Numero del registro actual.
        local cRegistro1    as character        // Valor del registro inicial.
        local cRegistro2    as character        // Valor del registro final.
        local xRegistro1                        // Valor de comparaci�n.
        local xRegistro2                        // Valor de comparaci�n.

        // ------- Inicializaci�n de variables.----------------------------------------
        // Previsualizar.
        lPrevio := wndABM2Listado .chkPrevio. Value
        lVistas := wndABM2Listado .chkVistas. Value

        // Nombre de la impresora.
        nImpresora := wndABM2Listado .cbxImpresoras. Value
        if nImpresora == 0
                msgExclamation( _HMG_aLangUser[ 32 ], '' )
        else
                cImpresora := aImpresoras[ nImpresora ]
        endif

        // Nombre del campo.
        aCampo := {}
        for i := 1 to wndABM2Listado .lbxCampoListado. ItemCount
                cCampo := wndABM2Listado .lbxCampoListado. Item( i )
                aAdd( aCampo, cCampo )
        next
        if Len( aCampo ) == 0
                msgExclamation( _HMG_aLangUser[ 23 ], _cTitulo )
                return NIL
        endif

        // N�mero del campo.
        aNumeroCampo := {}
        for i := 1 to Len( aCampo )
                nPosicion := aScan( _aNombreCampo, aCampo[ i ] )
                aAdd( aNumeroCampo, nPosicion )
        next

        // ------- Obtiene el ancho de impresi�n.--------------------------------------
        aAncho := {}
        for i := 1 to Len( aNumeroCampo )
                nCampo := aNumeroCampo[ i ]
                do case
                case _aEstructura[ nCampo, DBS_TYPE ] == "D"
                        nAncho := 9
                case _aEstructura[ nCampo, DBS_TYPE ] == "M"
                        nAncho := 20
                otherwise
                        nAncho := _aEstructura[ nCampo, DBS_LEN ]
                endcase
                nAncho := iif( Len( _aNombreCampo[ nCampo ] ) > nAncho,  ;
                        Len( _aNombreCampo[ nCampo ] ),            ;
                        nAncho )
                aAdd( aAncho, 2 + nAncho )
        next

        // ------- Comprueba el ancho de impresi�n.------------------------------------
        nAncho := 0
        for i := 1 to Len( aAncho )
                nAncho += aAncho[ i ]
        next
        if nAncho > 164
                MsgExclamation( _HMG_aLangUser[ 24 ], _cTitulo )
                return NIL
        else
                lOrientacion := ( nAncho > 109 )  // Horizontal / Vertical
        endif

        // ------- Valores de inicio y fin de listado.---------------------------------
        nRegistro  := ( _cArea )->( RecNo() )
        cRegistro1 := wndABM2Listado .txtRegistro1. Value
        cRegistro2 := wndABM2Listado .txtRegistro2. Value
        do case
        case _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "C"
                xRegistro1 := cRegistro1
                xRegistro2 := cRegistro2
        case _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "N"
                xRegistro1 := Val( cRegistro1 )
                xRegistro2 := Val( cRegistro2 )
        case _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "D"
                xRegistro1 := CToD( cRegistro1 )
                xRegistro2 := CToD( cRegistro2 )
        case _aEstructura[ _aIndiceCampo[ _nIndiceActivo ], DBS_TYPE ] == "L"
                xRegistro1 := ( cRegistro1 == ".t." )
                xRegistro2 := ( cRegistro2 == ".t." )
        endcase
        ( _cArea )->( dbSeek( xRegistro2 ) )
        nUltimo := ( _cArea )->( RecNo() )
        ( _cArea )->( dbSeek( xRegistro1 ) )
        nPrimero := ( _cArea )->( RecNo() )

        // ------- Obtiene el n�mero de p�ginas.---------------------------------------
        nTotales := 1
        ( _cArea )->( dbEval( {|| nTotales++ },, {|| !( RecNo() == nUltimo ) .and. !Eof() },,, .T. ) )
        ( _cArea )->( dbGoTo( nPrimero ) )
        if lOrientacion
                if Mod( nTotales, 33 ) == 0
                        nPaginas := Int( nTotales / 33 )
                else
                        nPaginas := Int( nTotales / 33 ) + 1
                endif
        else
                if Mod( nTotales, 55 ) == 0
                        nPaginas := Int( nTotales / 55 )
                else
                        nPaginas := Int( nTotales / 55 ) + 1
                endif
        endif

        // ------- Inicializa el listado.----------------------------------------------
        INIT PRINTSYS

        // Opciones de la impresi�n.
        if lPrevio
                SELECT PRINTER cImpresora PREVIEW
        else
                SELECT PRINTER cImpresora
        endif
        if lVistas
                ENABLE THUMBNAILS
        endif

        // Control de errores.
        if HBPRNERROR > 0
                msgExclamation( _HMG_aLangUser[ 25 ], _cTitulo )
                return NIL
        endif

        // Definici�n de las fuentes del listado.
        DEFINE FONT "a8"   name "arial" size 8
        DEFINE FONT "a9"   name "arial" size 9
        DEFINE FONT "a9n"  name "arial" size 9  bold
        DEFINE FONT "a10"  NAME "arial" size 10
        DEFINE FONT "a12n" name "arial" size 12 bold

        // Definici�n de los tipos de linea.
        DEFINE PEN "l0" STYLE PS_SOLID width 0.0 color 0x000000
        DEFINE PEN "l1" STYLE PS_SOLID width 0.1 color 0x000000
        DEFINE PEN "l2" STYLE PS_SOLID width 0.2 color 0x000000

        // Definici�n de los patrones de relleno.
        DEFINE BRUSH "s0" STYLE BS_NULL
        DEFINE BRUSH "s1" STYLE BS_SOLID color RGB( 220, 220, 220 )

        // Inicio del listado.
        lCabecera := .t.
        lSalida   := .t.
        nFila     := iif( Empty( _cFiltro ), 12, 13 )
        nPagina   := 1
        START DOC
        SET UNITS ROWCOL
        if lOrientacion
                SET PAGE ORIENTATION DMORIENT_LANDSCAPE ;
                        PAPERSIZE DMPAPER_A4 FONT "a10"
        else
                SET PAGE ORIENTATION DMORIENT_PORTRAIT  ;
                        PAPERSIZE DMPAPER_A4 FONT "a10"
        endif
        START PAGE
        do while lSalida

                // Cabecera el listado.
                if lCabecera
                        set text align right
                        select pen "l2"
                        @ 5, HBPRNMAXCOL - 5 say _cTitulo     font "a12n" to print
                        @ 6, 10, 6, HBPRNMAXCOL - 5 line
                        select pen "l0"
                        @ 7, 29 say _HMG_aLangUser[ 26 ]      font "a9n" to print
                        @ 8, 29 say _HMG_aLangUser[ 27 ]      font "a9n" to print
                        @ 9, 29 say _HMG_aLangUser[ 28 ]      font "a9n" to print
                        if ! Empty( _cFiltro )
                                @ 10, 29 say _HMG_aLangUser[33 ] font "a9n" to print
                        endif
                        set text align left
                        @ 7, 31 say ( _cArea )->( ordName() ) font "a9"  to print
                        @ 8, 31 say cRegistro1                font "a9"  to print
                        @ 9, 31 say cRegistro2                font "a9"  to print
                        if ! Empty( _cFiltro )
                                @ 10, 31 say _cFiltro         font "a9"  to print
                        endif
                        nColumna := 10
                        select pen "l1"
                        select brush "s1"
                        for i := 1 to Len( aCampo )
                                @ nFila - .9, nColumna, nFila, nColumna + aAncho[ i ] fillrect
                                @ nFila - 1, nColumna + 1 say aCampo[ i ] font "a9n" to print
                                nColumna += aAncho[ i ]
                        next
                        select pen "l0"
                        select brush "s0"
                        lCabecera := .f.
                endif

                // Registros.
                nColumna := 10
                for i := 1 to Len( aNumeroCampo )
                        nCampo := aNumeroCampo[ i ]
                        do case
                        case _aEstructura[ nCampo, DBS_TYPE ] == "N"
                                set text align right
                                @ nFila, nColumna + aAncho[ i ] say ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ) font "a8" to print
                        case _aEstructura[ nCampo, DBS_TYPE ] == "L"
                                set text align left
                                @ nFila, nColumna + 1 say iif( ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ), _HMG_aLangUser[ 29 ], _HMG_aLangUser[ 30 ] ) font "a8" to print
                        case _aEstructura[ nCampo, DBS_TYPE ] == "M"
                                set text align left
                                @ nFila, nColumna + 1 say SubStr( ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ), 1, 20 ) font "a8" to print
                        otherwise
                                set text align left
                                @ nFila, nColumna + 1 say ( _cArea )->( FieldGet( aNumeroCampo[ i ] ) ) font "a8" to print
                        endcase
                        nColumna += aAncho[ i ]
                next
                nFila++

                // Comprueba el final del registro.
                if ( _cArea )->( RecNo() ) == nUltimo .or. ( _cArea )->( EOF() )
                        lSalida := .f.
                endif
                ( _cArea )->( dbSkip( 1 ) )

                // Pie.
                if lOrientacion
                        if nFila > 44
                                set text align left
                                select pen "l2"
                                @ 46, 10, 46, HBPRNMAXCOL - 5 line
                                cPie := HB_ValToStr( Date() ) + " " + Time()
                                @ 46, 10 say cPie font "a9n" to print
                                set text align right
                                cPie := _HMG_aABMLangLabel[ 22 ] +        ;
                                        AllTrim( Str( nPagina ) ) +      ;
                                        "/" +                           ;
                                        AllTrim( Str( nPaginas ) )
                                @ 46, HBPRNMAXCOL - 5 say cPie font "a9n" to print
                                nPagina++
                                nFila := iif( Empty( _cFiltro ), 12, 13 )
                                lCabecera := .t.
                                END PAGE
                                START PAGE
                        endif
                else
                        if nFila > 66
                                set text align left
                                select pen "l2"
                                @ 68, 10, 68, HBPRNMAXCOL - 5 line
                                cPie := HB_ValToStr( Date() ) + " " + Time()
                                @ 68, 10 say cPie font "a9n" to print
                                set text align right
                                cPie := _HMG_aABMLangLabel[ 22 ] +        ;
                                        AllTrim( Str( nPagina ) ) +      ;
                                        "/" +                           ;
                                        AllTrim( Str( nPaginas ) )
                                @ 68, HBPRNMAXCOL - 5 say cPie font "a9n" to print
                                nFila := iif( Empty( _cFiltro ), 12, 13 )
                                nPagina++
                                lCabecera := .t.
                                END PAGE
                                START PAGE
                        endif
                endif
        enddo

        // Comprueba que se imprime el pie de la ultima hoja.----------
        if nPagina == nPaginas
                if lOrientacion
                        set text align left
                        select pen "l2"
                        @ 46, 10, 46, HBPRNMAXCOL - 5 line
                        cPie := HB_ValToStr( Date() ) + " " + Time()
                        @ 46, 10 say cPie font "a9n" to print
                        set text align right
                        cPie := _HMG_aABMLangLabel[ 22 ] +        ;
                                AllTrim( Str( nPagina ) ) +      ;
                                "/" +                           ;
                                AllTrim( Str( nPaginas ) )
                        @ 46, HBPRNMAXCOL - 5 say cPie font "a9n" to print
                else
                        set text align left
                        select pen "l2"
                        @ 68, 10, 68, HBPRNMAXCOL - 5 line
                        cPie := HB_ValToStr( Date() ) + " " + Time()
                        @ 68, 10 say cPie font "a9n" to print
                        set text align right
                        cPie := _HMG_aABMLangLabel[ 22 ] +        ;
                                AllTrim( Str( nPagina ) ) +      ;
                                "/" +                           ;
                                AllTrim( Str( nPaginas ) )
                        @ 68, HBPRNMAXCOL - 5 say cPie font "a9n" to print
                endif

                END PAGE
        endif
        END DOC

        RELEASE PRINTSYS

        // ------- Cierra la ventana.--------------------------------------------------
        ( _cArea )->( dbGoTo( nRegistro ) )
        wndABM2Listado.Release

return NIL
