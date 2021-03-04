/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 Implementación del comando EDIT para la librería MiniGUI.
 (c) 2003 Cristóbal Mollá <cemese@terra.es>

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

 "Harbour GUI framework for Win32"
  Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
  Copyright 2001 Antonio Linares <alinares@fivetech.com>
 www - https://harbour.github.io/

 "Harbour Project"
 Copyright 1999-2021, https://harbour.github.io/

 "WHAT32"
 Copyright 2002 AJ Wos <andrwos@aust1.net>

 "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

 ---------------------------------------------------------------------------*/

 /***************************************************************************************
 *   Historial: Mar 03  - Definición de la función.
 *                      - Pruebas.
 *                      - Soporte para lenguaje en inglés.
 *                      - Corregido bug al borrar en bdds con CDX.
 *                      - Mejora del control de parámetros.
 *                      - Mejorada la función de soprte de busqueda.
 *                      - Soprte para multilenguaje.
 *              Abr 03  - Corregido bug en la función de busqueda (Nombre del botón).
 *                      - Añadido soporte para lenguaje Ruso (Grigory Filiatov).
 *                      - Añadido soporte para lenguaje Catalán.
 *                      - Añadido soporte para lenguaje Portugués (Clovis Nogueira Jr).
 *   - Añadido soporte para lenguaja Polaco 852 (Janusz Poura).
 *   - Añadido soporte para lenguaje Francés (C. Jouniauxdiv).
 *              May 03  - Añadido soporte para lenguaje Italiano (Lupano Piero).
 *                      - Añadido soporte para lenguaje Alemán (Janusz Poura).
 ***************************************************************************************/

#include "minigui.ch"
#include "winprint.ch"

// Modos.
#define ABM_MODO_VER            1
#define ABM_MODO_EDITAR         2

// Eventos de la ventana principal.
#define ABM_EVENTO_SALIR        1
#define ABM_EVENTO_NUEVO        2
#define ABM_EVENTO_EDITAR       3
#define ABM_EVENTO_BORRAR       4
#define ABM_EVENTO_BUSCAR       5
#define ABM_EVENTO_IR           6
#define ABM_EVENTO_LISTADO      7
#define ABM_EVENTO_PRIMERO      8
#define ABM_EVENTO_ANTERIOR     9
#define ABM_EVENTO_SIGUIENTE   10
#define ABM_EVENTO_ULTIMO      11
#define ABM_EVENTO_GUARDAR     12
#define ABM_EVENTO_CANCELAR    13

// Eventos de la ventana de definición de listados.
#define ABM_LISTADO_CERRAR      1
#define ABM_LISTADO_MAS         2
#define ABM_LISTADO_MENOS       3
#define ABM_LISTADO_IMPRIMIR    4

#xtranslate Alltrim( Str( <i> ) ) => hb_NtoS( <i> )

/*
 * ABM()
 *
 * Descipción:
 *      ABM es una función para la realización de altas, bajas y modificaciones
 *      sobre una base de datos dada (el nombre del area). Esta función esta basada
 *      en la libreria GUI para [x]Harbour/W32 de Roberto López, MiniGUI.
 *
 * Limitaciones:
 *      - El tamaño de la ventana de dialogo es de 640 x 480 pixels.
 *      - No puede manejar bases de datos de más de 16 campos.
 *      - El tamaño máximo de las etiquetas de los campos es de 70 pixels.
 *      - El tamaño máximo de los controles de edición es de 160 pixels.
 *      - Si no se especifica función de busqueda, esta se realiza por el
 *        indice activo (si existe) y solo en campos tipo carácter y fecha.
 *        El indice activo tiene que tener el mismo nombre que el campo por
 *        el que va indexada la base de datos.
 *      - Los campos Memo deben ir al final de la base de datos.
 *
 * Sintaxis:
 *      ABM( cArea, [cTitulo], [aCampos], [aEditables], [bGuardar], [bBuscar] )
 *              cArea      Cadena de texto con el nombre del area de la base de
 *                         datos a tratar.
 *              cTitulo    Cadena de texto con el nombre de la ventana, se le añade
 *                         "Listado de " como título de los listados. Por defecto se
 *                         toma el nombre del area de la base de datos.
 *              aCampos    Matriz de cadenas de texto con los nombres desciptivos
 *                         de los campos de la base de datos. Tiene que tener el mismo
 *                         numero de elementos que campos hay en la base de datos.
 *                         Por defecto se toman los nombres de los campos de la
 *                         estructura de la base de datos.
 *              aEditables Array de valores lógicos qie indican si un campo es editable.
 *                         Normalmente se utiliza cuando se usan campos calculados y se
 *                         pasa el bloque de código para el evento de guardar registro.
 *                         Tiene que tener el mismo numero de elementos que campos hay en
 *                         la estructura de la base de datos. Por defecto es una matriz
 *                         con todos los valores verdaderos (.t.).
 *              bGuardar   Bloque de codigo al que se le pasa uan matriz con los
 *                         valores a guardar/editar y una variable lógica que indica
 *                         si se esta editando (.t.) o añadiendo (.f.). El bloque de código
 *                         tendrá la siguiente forma {|p1, p2| MiFuncion( p1, p2 ) }, donde
 *                         p1 será un array con los valores para cada campo y p2 sera el
 *                         valor lógico que indica el estado. Por defecto se guarda usando
 *                         el código interno de la función. Tras la operación se realiza un
 *                         refresco del cuadro de dialogo. La función debe devolver un valor
 *                         .f. si no se quiere salir del modo de edición o cualquier otro
 *                         si se desea salir. Esto es util a la hora de comprobar los valores
 *                         a añadir a la base de datos.
 *              bBuscar    Bloque de código para la función de busqueda. Por defecto se usa
 *                         el código interno que solo permite la busqueda por el campo
 *                         indexado actual, y solo si es de tipo caracter o fecha.
 *
 */


// Declaración de variables globales.
STATIC _cArea := "" // Nombre del area.
STATIC _aEstructura := {} // Estructura de la bdd.
STATIC _cTitulo := "" // Titulo de la ventana.
STATIC _aCampos := {} // Nombre de los campos.
STATIC _aEditables := {} // Controles editables.
STATIC _bGuardar := NIL // Bloque para la accion guardar.
STATIC _bBuscar := NIL // Bloque para la acción buscar.
STATIC _HMG_aControles := {} // Controles de edición.
STATIC _aBotones := {} // Controles BUTTON.
STATIC _lEditar := .T. // Modo.
STATIC _aCamposListado := {} // Campos del listado.
STATIC _aAnchoCampo := {} // Ancho campos listado.
STATIC _aNumeroCampo := {} // Numero de campo del listado.


 /***************************************************************************************
 *     Función: ABM( cArea, [cTitulo], [aCampos], [aEditables], [bGuardar], [bBuscar] )
 *       Autor: Cristóbal Mollá.
 * Descripción: Crea un dialogo de altas, bajas y modificaciones a partir
 *              de la estructura del area de datos pasada.
 *  Parámetros: cArea        Cadena de texto con el nombre del area de la BDD.
 *              [cTitulo]    Cadena de texto con el título de la ventana.
 *              [aCampos]    Array con cadenas de texto para las etiquetas de los campos.
 *              [aEditables] Array de valores lógicos que indican si el campo es editable.
 *              [bGuardar]   Bloque de codigo para la acción de guardar registro.
 *              [bBuscar]    Bloque de código para la acción de buscar registro.
 *    Devuelve: NIL
 ****************************************************************************************/
FUNCTION ABM( cArea, cTitulo, aCampos, aEditables, bGuardar, bBuscar )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nArea // Area anterior.
   LOCAL nRegistro // Numero de registro anterior.
   LOCAL nCampos := 0 // Numero de campos de la base.
   LOCAL nItem // Indice de iteración.
   LOCAL nFila // Fila de creación del control.
   LOCAL nColumna // Columna de creación de control.
   LOCAL aEtiquetas // Array con los controles LABEL.
   LOCAL aBrwCampos // Títulos de columna del BROWSE.
   LOCAL aBrwAnchos // Anchos de columna del BROWSE.
   LOCAL nBrwAnchoCampo // Ancho del campo para el browse.
   LOCAL nBrwAnchoRegistro // Ancho del registro para el browse.
   LOCAL cMascara // Mascara de datos para el TEXTBOX.
   LOCAL nMascaraTotal // Tamaño de la máscara de edición.
   LOCAL nMascaraDecimales // Tamaño de los decimales.
   LOCAL _BackDeleted
   LOCAL cMacroTemp

   // Inicializa el soporte multilenguaje.----------------------------------------
   InitMessages()

   // Gusrdar estado actual de SET DELETED y activarlo
   _BackDeleted := Set( _SET_DELETED )
   SET DELETED ON

   // Control de parámetros.
   // Area de la base de datos.---------------------------------------------------
   IF ( ValType( cArea ) != "C" ) .OR. Empty( cArea )
      MsgMiniGUIError( _HMG_aABMLangError[ 1 ] )
   ELSE
      _cArea := cArea
      _aEstructura := ( _cArea )->( dbStruct() )
      nCampos := Len( _aEstructura )
   ENDIF

   // Numero de campos.-----------------------------------------------------------
   IF ( nCampos > 16 )
      MsgMiniGUIError( _HMG_aABMLangError[ 2 ] )
   ENDIF

   // Titulo de la ventana.-------------------------------------------------------
   IF ( ValType( cTitulo ) != "C" ) .OR. Empty( cTitulo )
      _cTitulo := cArea
   ELSE
      _cTitulo := cTitulo
   ENDIF

   // Nombre de los campos.-------------------------------------------------------
   _aCampos := Array( nCampos )
   IF ( ValType( aCampos ) != "A" ) .OR. ( Len( aCampos ) != nCampos )
      _aCampos := Array( nCampos )
      FOR nItem := 1 TO nCampos
         _aCampos[ nItem ] := Lower( _aEstructura[ nItem, 1 ] )
      NEXT
   ELSE
      FOR nItem := 1 TO nCampos
         IF ValType( aCampos[ nItem ] ) != "C"
            _aCampos[ nItem ] := Lower( _aEstructura[ nItem, 1 ] )
         ELSE
            _aCampos[ nItem ] := aCampos[ nItem ]
         ENDIF
      NEXT
   ENDIF

   // Array de controles editables.-----------------------------------------------
   _aEditables := Array( nCampos )
   IF ( ValType( aEditables ) != "A" ) .OR. ( Len( aEditables ) != nCampos )
      _aEditables := Array( nCampos )
      FOR nItem := 1 TO nCampos
         _aEditables[ nItem ] := .T.
      NEXT
   ELSE
      FOR nItem := 1 TO nCampos
         IF ValType( aEditables[ nItem ] ) != "L"
            _aEditables[ nItem ] := .T.
         ELSE
            _aEditables[ nItem ] := aEditables[ nItem ]
         ENDIF
      NEXT
   ENDIF

   // Bloque de codigo de la acción guardar.--------------------------------------
   IF ValType( bGuardar ) != "B"
      _bGuardar := NIL
   ELSE
      _bGuardar := bGuardar
   ENDIF

   // Bloque de código de la acción buscar.---------------------------------------
   IF ValType( bBuscar ) != "B"
      _bBuscar := NIL
   ELSE
      _bBuscar := bBuscar
   ENDIF

   // Inicialización de variables.------------------------------------------------
   aEtiquetas := Array( nCampos, 3 )
   aBrwCampos := Array( nCampos )
   aBrwAnchos := Array( nCampos )
   _HMG_aControles := Array( nCampos, 3 )

   // Propiedades de las etiquetas.-----------------------------------------------
   nFila := 20
   nColumna := 20
   FOR nItem := 1 TO nCampos
      aEtiquetas[ nItem, 1 ] := "lbl" + "Etiqueta" + AllTrim( Str( nItem ) )
      aEtiquetas[ nItem, 2 ] := nFila
      aEtiquetas[ nItem, 3 ] := nColumna
      nFila += 25
      IF nFila >= 200
         nFila := 20
         nColumna := 270
      ENDIF
   NEXT

   // Propiedades del browse.-----------------------------------------------------
   FOR nItem := 1 TO nCampos
      aBrwCampos[ nItem ] := cArea + "->" + _aEstructura[ nItem, 1 ]
      nBrwAnchoRegistro := _aEstructura[ nItem, 3 ] * 10
      nBrwAnchoCampo := Len( _aCampos[ nItem ] ) * 10
      nBrwAnchoCampo := iif( nBrwanchoCampo >= nBrwAnchoRegistro, nBrwanchoCampo, nBrwAnchoRegistro )
      aBrwAnchos[ nItem ] := nBrwAnchoCampo
   NEXT

   // Propiedades de los controles de edición.------------------------------------
   nFila := 20
   nColumna := 20
   FOR nItem := 1 TO nCampos
      DO CASE
      CASE _aEstructura[ nItem, 2 ] == "C" // Campo tipo caracter.
         _HMG_aControles[ nItem, 1 ] := "txt" + "Control" + AllTrim( Str( nItem ) )
         _HMG_aControles[ nItem, 2 ] := nFila
         _HMG_aControles[ nItem, 3 ] := nColumna + 80
      CASE _aEstructura[ nItem, 2 ] == "N" // Campo tipo numerico.
         _HMG_aControles[ nItem, 1 ] := "txn" + "Control" + AllTrim( Str( nItem ) )
         _HMG_aControles[ nItem, 2 ] := nFila
         _HMG_aControles[ nItem, 3 ] := nColumna + 80
      CASE _aEstructura[ nItem, 2 ] == "D" // Campo tipo fecha.
         _HMG_aControles[ nItem, 1 ] := "dat" + "Control" + AllTrim( Str( nItem ) )
         _HMG_aControles[ nItem, 2 ] := nFila
         _HMG_aControles[ nItem, 3 ] := nColumna + 80
      CASE _aEstructura[ nItem, 2 ] == "L" // Campo tipo lógico.
         _HMG_aControles[ nItem, 1 ] := "chk" + "Control" + AllTrim( Str( nItem ) )
         _HMG_aControles[ nItem, 2 ] := nFila - 2
         _HMG_aControles[ nItem, 3 ] := nColumna + 80
      CASE _aEstructura[ nItem, 2 ] == "M" // Campo tipo memo.
         _HMG_aControles[ nItem, 1 ] := "edt" + "Control" + AllTrim( Str( nItem ) )
         _HMG_aControles[ nItem, 2 ] := nFila
         _HMG_aControles[ nItem, 3 ] := nColumna + 80
         nFila += 25
      ENDCASE
      nFila += 25
      IF nFila >= 200
         nFila := 20
         nColumna := 270
      ENDIF
   NEXT

   // Propiedades de los botones.-------------------------------------------------
   _aBotones := { "btnCerrar", "btnNuevo", "btnEditar", "btnBorrar", "btnBuscar", ;
      "btnIr", "btnListado", "btnPrimero", "btnAnterior", "btnSiguiente", ;
      "btnUltimo", "btnGuardar", "btnCancelar" }

   // Defincinión de la ventana de edición.---------------------------------------
   DEFINE WINDOW wndABM ;
         AT 0, 0 ;
         WIDTH 640 + iif( IsVistaOrLater(), GetBorderWidth() / 2 + 2, 0 ) ;
         HEIGHT 480 + iif( IsVistaOrLater(), GetBorderHeight() / 2 + 2, 0 ) ;
         TITLE _cTitulo ;
         MODAL ;
         NOSYSMENU ;
         FONT "Serif" ;
         SIZE 8 ;
         ON INIT ABMRefresh( ABM_MODO_VER )
   END WINDOW

   // Defincición del frame.------------------------------------------------------
   @ 10, 10 frame frmFrame1 OF wndABM WIDTH 510 HEIGHT 290

   // Defincición de las etiquetas.-----------------------------------------------
   FOR nItem := 1 TO nCampos

      cMacroTemp := aEtiquetas[ nItem, 1 ]

      @ aEtiquetas[ nItem, 2 ], aEtiquetas[ nItem, 3 ] LABEL &cMacroTemp ;
         OF wndABM ;
         VALUE _aCampos[ nItem ] ;
         WIDTH 70 ;
         HEIGHT 21 ;
         FONT "ms sans serif" ;
         SIZE 8
   NEXT
   @ 310, 535 LABEL lblLabel1 ;
      OF wndABM ;
      VALUE _HMG_aABMLangLabel[ 1 ] ;
      WIDTH 85 ;
      HEIGHT 20 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 330, 535 LABEL lblRegistro ;
      OF wndABM ;
      VALUE "9999" ;
      WIDTH 85 ;
      HEIGHT 20 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 350, 535 LABEL lblLabel2 ;
      OF wndABM ;
      VALUE _HMG_aABMLangLabel[ 2 ] ;
      WIDTH 85 ;
      HEIGHT 20 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 370, 535 LABEL lblTotales ;
      OF wndABM ;
      VALUE "9999" ;
      WIDTH 85 ;
      HEIGHT 20 ;
      FONT "ms sans serif" ;
      SIZE 8

   // Defincición del browse.-----------------------------------------------------
   @ 310, 10 browse brwBrowse ;
      OF wndABM ;
      WIDTH 510 ;
      HEIGHT 125 ;
      headers _aCampos ;
      widths aBrwAnchos ;
      workarea &_cArea ;
      fields aBrwCampos ;
      value ( _cArea )->( RecNo() ) ;
      ON change {|| ( _cArea )->( dbGoto( wndABM.brwBrowse.Value ) ), ABMRefresh( ABM_MODO_VER ) }

   // Definición de los botones.--------------------------------------------------
   @ 400, 535 BUTTON btnCerrar ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 1 ] ;
      ACTION ABMEventos( ABM_EVENTO_SALIR ) ;
      WIDTH 85 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 20, 535 BUTTON btnNuevo ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 2 ] ;
      ACTION ABMEventos( ABM_EVENTO_NUEVO ) ;
      WIDTH 85 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 65, 535 BUTTON btnEditar ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 3 ] ;
      ACTION ABMEventos( ABM_EVENTO_EDITAR ) ;
      WIDTH 85 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 110, 535 BUTTON btnBorrar ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 4 ] ;
      ACTION ABMEventos( ABM_EVENTO_BORRAR ) ;
      WIDTH 85 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 155, 535 BUTTON btnBuscar ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 5 ] ;
      ACTION ABMEventos( ABM_EVENTO_BUSCAR ) ;
      WIDTH 85 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 200, 535 BUTTON btnIr ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 6 ] ;
      ACTION ABMEventos( ABM_EVENTO_IR ) ;
      WIDTH 85 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 245, 535 BUTTON btnListado ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 7 ] ;
      ACTION ABMEventos( ABM_EVENTO_LISTADO ) ;
      WIDTH 85 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 260, 20 BUTTON btnPrimero ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 8 ] ;
      ACTION ABMEventos( ABM_EVENTO_PRIMERO ) ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 260, 100 BUTTON btnAnterior ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 9 ] ;
      ACTION ABMEventos( ABM_EVENTO_ANTERIOR ) ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 260, 180 BUTTON btnSiguiente ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 10 ] ;
      ACTION ABMEventos( ABM_EVENTO_SIGUIENTE ) ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 260, 260 BUTTON btnUltimo ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 11 ] ;
      ACTION ABMEventos( ABM_EVENTO_ULTIMO ) ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 260, 355 BUTTON btnGuardar ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 12 ] ;
      ACTION ABMEventos( ABM_EVENTO_GUARDAR ) ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 260, 435 BUTTON btnCancelar ;
      OF wndABM ;
      CAPTION _HMG_aABMLangButton[ 13 ] ;
      ACTION ABMEventos( ABM_EVENTO_CANCELAR ) ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8

   // Defincición de los controles de edición.------------------------------------
   FOR nItem := 1 TO nCampos
      cMacroTemp := _HMG_aControles[ nItem, 1 ]

      DO CASE
      CASE _aEstructura[ nItem, 2 ] == "C" // Campo tipo caracter.

         @ _HMG_aControles[ nItem, 2 ], _HMG_aControles[ nItem, 3 ] textbox &cMacroTemp ;
            OF wndABM ;
            HEIGHT 21 ;
            VALUE "" ;
            WIDTH Max( 26, iif( ( _aEstructura[ nItem, 3 ] * 10 ) > 160, 160, _aEstructura[ nItem, 3 ] * 10 ) ) ;
            FONT "Arial" ;
            SIZE 9 ;
            MAXLENGTH _aEstructura[ nItem, 3 ]

      CASE _aEstructura[ nItem, 2 ] == "N" // Campo tipo numerico

         IF _aEstructura[ nItem, 4 ] == 0

            @ _HMG_aControles[ nItem, 2 ], _HMG_aControles[ nItem, 3 ] textbox &cMacroTemp ;
               OF wndABM ;
               HEIGHT 21 ;
               VALUE 0 ;
               WIDTH iif( ( _aEstructura[ nItem, 3 ] * 10 ) > 160, 160, _aEstructura[ nItem, 3 ] * 10 ) ;
               NUMERIC ;
               MAXLENGTH _aEstructura[ nItem, 3 ] ;
               FONT "Arial" ;
               SIZE 9
         ELSE
            nMascaraTotal := _aEstructura[ nItem, 3 ]
            nMascaraDecimales := _aEstructura[ nItem, 4 ]

            cMascara := Replicate( "9", nMascaraTotal - ( nMascaraDecimales + 1 ) )
            cMascara += "."
            cMascara += Replicate( "9", nMascaraDecimales )

            @ _HMG_aControles[ nItem, 2 ], _HMG_aControles[ nItem, 3 ] textbox &cMacroTemp ;
               OF wndABM ;
               HEIGHT 21 ;
               VALUE 0 ;
               WIDTH iif( ( _aEstructura[ nItem, 3 ] * 10 ) > 160, 160, _aEstructura[ nItem, 3 ] * 10 ) ;
               NUMERIC ;
               INPUTMASK cMascara
         ENDIF

      CASE _aEstructura[ nItem, 2 ] == "D" // Campo tipo fecha.

         @ _HMG_aControles[ nItem, 2 ], _HMG_aControles[ nItem, 3 ] datepicker &cMacroTemp ;
            OF wndABM ;
            VALUE Date() ;
            WIDTH 100 ;
            HEIGHT 21 ;
            shownone ;
            FONT "Arial" ;
            SIZE 9

      CASE _aEstructura[ nItem, 2 ] == "L" // Campo tipo logico.

         @ _HMG_aControles[ nItem, 2 ], _HMG_aControles[ nItem, 3 ] checkbox &cMacroTemp ;
            OF wndABM ;
            CAPTION NIL ;
            WIDTH 21 ;
            HEIGHT 21 ;
            VALUE .T. ;
            FONT "Arial" ;
            SIZE 9

      CASE _aEstructura[ nItem, 2 ] == "M" // Campo tipo memo.

         @ _HMG_aControles[ nItem, 2 ], _HMG_aControles[ nItem, 3 ] EDITBOX &cMacroTemp ;
            OF wndABM ;
            WIDTH 160 ;
            HEIGHT 47
      ENDCASE
   NEXT

   // Puntero de registros.------------------------------------------------------
   nArea := Select()
   nRegistro := RecNo()
   dbSelectArea( _cArea )
   ( _cArea )->( dbGoTop() )

   // Activación de la ventana.---------------------------------------------------
   CENTER WINDOW wndABM
   ACTIVATE WINDOW wndABM

   // Restaurar SET DELETED a su valor inicial
   Set( _SET_DELETED, _BackDeleted )

   // Salida.---------------------------------------------------------------------
   ( _cArea )->( dbGoTop() )
   dbSelectArea( nArea )
   dbGoto( nRegistro )

RETURN ( nil )


 /***************************************************************************************
 *     Función: ABMRefresh( [nEstado] )
 *       Autor: Cristóbal Mollá
 * Descripción: Refresca la ventana segun el estado pasado.
 *  Parámetros: nEstado    Valor numerico que indica el tipo de estado.
 *    Devuelve: NIL
 ***************************************************************************************/
STATIC FUNCTION ABMRefresh( nEstado )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem // Indice de iteración.

   // Refresco del cuadro de dialogo.
   DO CASE
      // Modo de visualización.----------------------------------------------
   CASE nEstado == ABM_MODO_VER

      // Estado de los controles.
      // Botones Cerrar y Nuevo.
      FOR nItem := 1 TO 2
         SetProperty( "wndABM", _aBotones[ nItem ], "Enabled", .T. )
      NEXT

      // Botones Guardar y Cancelar.
      FOR nItem := ( Len( _aBotones ) - 1 ) TO Len( _aBotones )
         SetProperty( "wndABM", _aBotones[ nItem ], "Enabled", .F. )
      NEXT

      // Resto de botones.
      IF ( _cArea )->( RecCount() ) == 0
         wndABM.brwBrowse.Enabled := .F.
         FOR nItem := 3 to ( Len( _aBotones ) - 2 )
            SetProperty( "wndABM", _aBotones[ nItem ], "Enabled", .F. )
         NEXT
      ELSE
         wndABM.brwBrowse.Enabled := .T.
         FOR nItem := 3 to ( Len( _aBotones ) - 2 )
            SetProperty( "wndABM", _aBotones[ nItem ], "Enabled", .T. )
         NEXT
      ENDIF

      // Controles de edición.
      FOR nItem := 1 TO Len( _HMG_aControles )
         SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Enabled", .F. )
      NEXT

      // Contenido de los controles.
      // Controles de edición.
      FOR nItem := 1 TO Len( _HMG_aControles )
         SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value", ( _cArea )->( FieldGet( nItem ) ) )
      NEXT

      // Numero de registro y total.
      wndABM.lblRegistro.VALUE := AllTrim( Str( ( _cArea )->( RecNo() ) ) )
      wndABM.lblTotales.VALUE := AllTrim( Str( ( _cArea )->( RecCount() ) ) )

      // Modo de edición.----------------------------------------------------
   CASE nEstado == ABM_MODO_EDITAR

      // Estado de los controles.
      // Botones Guardar y Cancelar.
      FOR nItem := ( Len( _aBotones ) - 1 ) TO Len( _aBotones )
         SetProperty( "wndABM", _aBotones[ nItem ], "Enabled", .T. )
      NEXT

      // Resto de los botones.
      FOR nItem := 1 to ( Len( _aBotones ) - 2 )
         SetProperty( "wndABM", _aBotones[ nItem ], "Enabled", .F. )
      NEXT
      wndABM.brwBrowse.Enabled := .F.

      // Contenido de los controles.
      // Controles de edición.
      FOR nItem := 1 TO Len( _HMG_aControles )
         SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Enabled", _aEditables[ nItem ] )
      NEXT

      // Numero de registro y total.
      wndABM.lblRegistro.VALUE := AllTrim( Str( ( _cArea )->( RecNo() ) ) )
      wndABM.lblTotales.VALUE := AllTrim( Str( ( _cArea )->( RecCount() ) ) )

      // Control de error.---------------------------------------------------
   OTHERWISE
      MsgMiniGUIError( _HMG_aABMLangError[ 3 ] )
   END CASE

RETURN ( nil )


 /***************************************************************************************
 *     Función: ABMEventos( nEvento )
 *       Autor: Cristóbal Mollá
 * Descripción: Gestiona los eventos que se producen en la ventana wndABM.
 *  Parámetros: nEvento    Valor numérico que indica el evento a ejecutar.
 *    Devuelve: NIL
 ****************************************************************************************/
STATIC FUNCTION ABMEventos( nEvento )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem // Indice de iteración.
   LOCAL aValores := {} // Valores de los campos de edición.
   LOCAL nRegistro // Numero de registro.
   LOCAL lGuardar // Salida del bloque _bGuardar.
   LOCAL cModo // Texto del modo.
   LOCAL cRegistro // Numero de registro.

   // Gestión de eventos.
   DO CASE
      // Pulsación del botón CERRAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_SALIR
      wndABM.RELEASE

      // Pulsación del botón NUEVO.------------------------------------------
   CASE nEvento == ABM_EVENTO_NUEVO
      _lEditar := .F.
      cModo := _HMG_aABMLangLabel[ 3 ]
      wndABM.TITLE := wndABM.TITLE + cModo

      // Pasa a modo de edición.
      ABMRefresh( ABM_MODO_EDITAR )

      // Actualiza los valores de los controles de edición.
      FOR nItem := 1 TO Len( _HMG_aControles )
         DO CASE
         CASE _aEstructura[ nItem, 2 ] == "C"
            SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value", "" )
         CASE _aEstructura[ nItem, 2 ] == "N"
            SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value", 0 )
         CASE _aEstructura[ nItem, 2 ] == "D"
            SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value", Date() )
         CASE _aEstructura[ nItem, 2 ] == "L"
            SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value", .F. )
         CASE _aEstructura[ nItem, 2 ] == "M"
            SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value", "" )
         ENDCASE
      NEXT

      // Esteblece el foco en el primer control.
      Domethod( "wndABM", _HMG_aControles[ 1, 1 ], "SetFocus" )

      // Pulsación del botón EDITAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_EDITAR
      _lEditar := .T.
      cModo := _HMG_aABMLangLabel[ 4 ]
      wndABM.TITLE := wndABM.TITLE + cModo

      // Pasa a modo de edicion.
      ABMRefresh( ABM_MODO_EDITAR )

      // Actualiza los valores de los controles de edición.
      FOR nItem := 1 TO Len( _HMG_aControles )
         SetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value", ( _cArea )->( FieldGet( nItem ) ) )
      NEXT

      // Establece el foco en el primer coltrol.
      Domethod( "wndABM", _HMG_aControles[ 1, 1 ], "SetFocus" )

      // Pulsación del botón BORRAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_BORRAR

      // Borra el registro si se acepta.
      IF MsgOKCancel( _HMG_aABMLangUser[ 1 ], "" )
         IF ( _cArea )->( RLock() )
            ( _cArea )->( dbDelete() )
            ( _cArea )->( dbCommit() )
            ( _cArea )->( dbUnlock() )
            IF .NOT. Set( _SET_DELETED )
               SET DELETED ON
            ENDIF
            ( _cArea )->( dbSkip() )
            IF ( _cArea )->( Eof() )
               ( _cArea )->( dbGoBottom() )
            ENDIF
         ELSE
            Msgstop( _HMG_aLangUser[ 41 ], _cTitulo )
         ENDIF
      ENDIF

      // Refresca.
      wndABM.brwBrowse.Refresh
      wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )

      // Pulsación del botón BUSCAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_BUSCAR
      IF ValType( _bBuscar ) != "B"
         IF Empty( ( _cArea )->( ordSetFocus() ) )
            msgExclamation( _HMG_aABMLangUser[ 2 ] )
         ELSE
            ABMBuscar()
         ENDIF
      ELSE
         Eval( _bBuscar )
         wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )
      ENDIF

      // Pulsación del botón IR AL REGISTRO.---------------------------------
   CASE nEvento == ABM_EVENTO_IR
      cRegistro := InputBox( _HMG_aABMLangLabel[ 5 ], "" )
      if ! Empty( cRegistro )
         nRegistro := Val( cRegistro )
         IF ( nRegistro != 0 ) .AND. ( nRegistro <= ( _cArea )->( RecCount() ) )
            ( _cArea )->( dbGoto( nRegistro ) )
            wndABM.brwBrowse.VALUE := nRegistro
         ENDIF
      ENDIF

      // Pulsación del botón LISTADO.----------------------------------------
   CASE nEvento == ABM_EVENTO_LISTADO
      ABMListado()

      // Pulsación del botón PRIMERO.----------------------------------------
   CASE nEvento == ABM_EVENTO_PRIMERO
      ( _cArea )->( dbGoTop() )
      wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )
      wndABM.lblRegistro.VALUE := AllTrim( Str( ( _cArea )->( RecNo() ) ) )
      wndABM.lblTotales.VALUE := AllTrim( Str( ( _cArea )->( RecCount() ) ) )

      // Pulsación del botón ANTERIOR.---------------------------------------
   CASE nEvento == ABM_EVENTO_ANTERIOR
      ( _cArea )->( dbSkip( -1 ) )
      wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )
      wndABM.lblRegistro.VALUE := AllTrim( Str( ( _cArea )->( RecNo() ) ) )
      wndABM.lblTotales.VALUE := AllTrim( Str( ( _cArea )->( RecCount() ) ) )

      // Pulsación del botón SIGUIENTE.--------------------------------------
   CASE nEvento == ABM_EVENTO_SIGUIENTE
      ( _cArea )->( dbSkip( 1 ) )
      wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )
      wndABM.lblRegistro.VALUE := AllTrim( Str( ( _cArea )->( RecNo() ) ) )
      wndABM.lblTotales.VALUE := AllTrim( Str( ( _cArea )->( RecCount() ) ) )

      // Pulsación del botón ULTIMO.-----------------------------------------
   CASE nEvento == ABM_EVENTO_ULTIMO
      ( _cArea )->( dbGoBottom() )
      wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )
      wndABM.lblRegistro.VALUE := AllTrim( Str( ( _cArea )->( RecNo() ) ) )
      wndABM.lblTotales.VALUE := AllTrim( Str( ( _cArea )->( RecCount() ) ) )

      // Pulsación del botón GUARDAR.----------------------------------------
   CASE nEvento == ABM_EVENTO_GUARDAR
      IF ValType( _bGuardar ) != "B"

         // Guarda el registro.
         IF .NOT. _lEditar
            ( _cArea )->( dbAppend() )
         ENDIF

         IF ( _cArea )->( RLock() )

            FOR nItem := 1 TO Len( _HMG_aControles )
               ( _cArea )->( FieldPut( nItem, GetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value" ) ) )
            NEXT

            ( _cArea )->( dbCommit() )
            ( _cArea )->( dbUnlock() )

            // Refresca el browse.
            wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )
            wndABM.brwBrowse.Refresh
            wndABM.TITLE := SubStr( wndABM.TITLE, 1, Len( wndABM.Title ) - 12 )

         ELSE

            MsgStop( _HMG_aLangUser[ 41 ], _cTitulo )

         ENDIF

      ELSE

         // Evalúa el bloque de código bGuardar.
         FOR nItem := 1 TO Len( _HMG_aControles )
            AAdd( aValores, GetProperty( "wndABM", _HMG_aControles[ nItem, 1 ], "Value" ) )
         NEXT
         lGuardar := Eval( _bGuardar, aValores, _lEditar )
         lGuardar := iif( ValType( lGuardar ) != "L", .T., lGuardar )
         IF lGuardar
            ( _cArea )->( dbCommit() )

            // Refresca el browse.
            wndABM.brwBrowse.VALUE := ( _cArea )->( RecNo() )
            wndABM.brwBrowse.Refresh
            wndABM.TITLE := SubStr( wndABM.TITLE, 1, Len( wndABM.Title ) - 12 )
         ENDIF
      ENDIF

      // Pulsación del botón CANCELAR.---------------------------------------
   CASE nEvento == ABM_EVENTO_CANCELAR

      // Pasa a modo de visualización.
      ABMRefresh( ABM_MODO_VER )
      IF "(" $ wndABM.TITLE
         wndABM.TITLE := SubStr( wndABM.TITLE, 1, Len( wndABM.Title ) - 12 )
      ENDIF
      Domethod( "wndABM", "brwBrowse", "SetFocus" )

      // Control de error.---------------------------------------------------
   OTHERWISE

      MsgMiniGUIError( _HMG_aABMLangError[ 4 ] )

   ENDCASE

RETURN ( nil )


 /***************************************************************************************
 *     Función: ABMBuscar()
 *       Autor: Cristóbal Mollá
 * Descripción: Definición de la busqueda
 *  Parámetros: Ninguno
 *    Devuelve: NIL
 ***************************************************************************************/
STATIC FUNCTION ABMBuscar()

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem // Indice de iteración.
   LOCAL aCampo := {} // Nombre de los campos.
   LOCAL aTipoCampo := {} // Matriz con los tipos de campo.
   LOCAL cCampo // Nombre del campo.
   LOCAL nTipoCampo // Indice el tipo de campo.
   LOCAL cTipoCampo // Tipo de campo.
   LOCAL cModo // Texto del modo de busqueda.

   // Obtiene el nombre y el tipo de campo.---------------------------------------
   FOR nItem := 1 TO Len( _aEstructura )
      AAdd( aCampo, _aEstructura[ nItem, 1 ] )
      AAdd( aTipoCampo, _aEstructura[ nItem, 2 ] )
   NEXT

   // Evalua si el campo indexado existe y obtiene su tipo.-----------------------
   cCampo := Upper( ( _cArea )->( ordSetFocus() ) )
   nTipoCampo := AScan( aCampo, cCampo )
   IF nTipoCampo == 0
      msgExclamation( _HMG_aABMLangUser[ 3 ] )
      RETURN ( nil )
   ENDIF
   cTipoCampo := aTipoCampo[ nTipoCampo ]

   // Comprueba si el tipo se puede buscar.---------------------------------------
   IF ( cTipoCampo == "N" ) .OR. ( cTipoCampo == "L" ) .OR. ( cTipoCampo == "M" )
      MsgExclamation( _HMG_aABMLangUser[ 4 ] )
      RETURN ( nil )
   ENDIF

   // Define la ventana de busqueda.----------------------------------------------
   DEFINE WINDOW wndABMBuscar ;
         AT 0, 0 ;
         WIDTH 200 ;
         HEIGHT 160 ;
         TITLE _HMG_aABMLangLabel[ 6 ] ;
         MODAL ;
         NOSYSMENU ;
         FONT "Serif" ;
         SIZE 8
   END WINDOW

   // Define los controles de la ventana de busqueda.-----------------------------
   // Etiquetas
   @ 20, 20 LABEL lblEtiqueta1 ;
      OF wndABMBuscar ;
      VALUE "" ;
      WIDTH 160 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      SIZE 8

   // Botones.
   @ 80, 20 BUTTON btnGuardar ;
      OF wndABMBuscar ;
      CAPTION "&" + _HMG_aABMLangButton[ 5 ] ;
      action {|| ABMBusqueda() } ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 80, 100 BUTTON btnCancelar ;
      OF wndABMBuscar ;
      CAPTION "&" + _HMG_aABMLangButton[ 13 ] ;
      action {|| wndABMBuscar.Release } ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8

   // Controles de edición.
   DO CASE
   CASE cTipoCampo == "C"
      cModo := _HMG_aABMLangLabel[ 7 ]
      wndABMBuscar .lblEtiqueta1. VALUE := cModo
      @ 45, 20 textbox txtBuscar ;
         OF wndABMBuscar ;
         HEIGHT 21 ;
         VALUE "" ;
         WIDTH 160 ;
         FONT "Arial" ;
         SIZE 9 ;
         MAXLENGTH _aEstructura[ nTipoCampo, 3 ]
   CASE cTipoCampo == "D"
      cModo := _HMG_aABMLangLabel[ 8 ]
      wndABMBuscar .lblEtiqueta1. VALUE := cModo
      @ 45, 20 datepicker txtBuscar ;
         OF wndABMBuscar ;
         VALUE Date() ;
         WIDTH 100 ;
         FONT "Arial" ;
         SIZE 9
   ENDCASE

   ON KEY RETURN OF wndABMBuscar ACTION wndABMBuscar.btnGuardar.onclick
   wndABMBuscar.txtBuscar.setfocus

   // Activa la ventana.----------------------------------------------------------
   CENTER WINDOW wndABMBuscar
   ACTIVATE WINDOW wndABMBuscar

RETURN ( nil )


 /***************************************************************************************
 *     Función: ABMBusqueda()
 *       Autor: Cristóbal Mollá
 * Descripción: Realiza la busqueda en la base de datos
 *  Parámetros: Ninguno
 *    Devuelve: NIL
 ***************************************************************************************/
STATIC FUNCTION ABMBusqueda()

   // Declaración de variables locales.-------------------------------------------
   LOCAL nRegistro := ( _cArea )->( RecNo() ) // Registro anterior.

   // Busca el registro.----------------------------------------------------------
   IF ( _cArea )->( dbSeek( wndABMBuscar.txtBuscar.Value ) )
      nRegistro := ( _cArea )->( RecNo() )
   ELSE
      msgExclamation( _HMG_aABMLangUser[ 5 ] )
      ( _cArea )->( dbGoto( nRegistro ) )
   ENDIF

   // Cierra y actualiza.---------------------------------------------------------
   wndABMBuscar.RELEASE
   wndABM.brwBrowse.VALUE := nRegistro

RETURN ( nil )


 /***************************************************************************************
 *     Función: ABMListado()
 *       Autor: Cristóbal Mollá
 * Descripción: Definición del listado.
 *  Parámetros: Ninguno
 *    Devuelve: NIL
 ***************************************************************************************/
FUNCTION ABMListado()

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem // Indice de iteración.
   LOCAL aCamposListado := {} // Matriz con los campos del listado.
   LOCAL aCamposTotales := {} // Matriz con los campos totales.
   LOCAL nPrimero // Registro inicial.
   LOCAL nUltimo // Registro final.
   LOCAL nRegistro := ( _cArea )->( RecNo() ) // Registro anterior.

   // Inicialización de variables.------------------------------------------------
   // Campos imprimibles.
   FOR nItem := 1 TO Len( _aEstructura )

      // Todos los campos son imprimibles menos los memo.
      IF _aEstructura[ nItem, 2 ] != "M"
         AAdd( aCamposTotales, _aEstructura[ nItem, 1 ] )
      ENDIF
   NEXT

   // Rango de registros.
   ( _cArea )->( dbGoTop() )
   nPrimero := ( _cArea )->( RecNo() )
   ( _cArea )->( dbGoBottom() )
   nUltimo := ( _cArea )->( RecNo() )
   ( _cArea )->( dbGoto( nRegistro ) )

   // Defincicón de la ventana del proceso.---------------------------------------
   DEFINE WINDOW wndABMListado ;
         AT 0, 0 ;
         WIDTH 420 + iif( IsVistaOrLater(), GetBorderWidth() / 2 + 2, 0 ) ;
         HEIGHT 295 + iif( IsVistaOrLater(), GetBorderHeight() / 2 + 2, 0 ) ;
         TITLE _HMG_aABMLangLabel[ 10 ] ;
         MODAL ;
         NOSYSMENU ;
         FONT "Serif" ;
         SIZE 8
   END WINDOW

   // Definición de los controles.------------------------------------------------
   // Frame.
   @ 10, 10 frame frmFrame1 OF wndABMListado WIDTH 390 HEIGHT 205

   // Label.
   @ 20, 20 LABEL lblLabel1 ;
      OF wndABMListado ;
      VALUE _HMG_aABMLangLabel[ 11 ] ;
      WIDTH 140 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 20, 250 LABEL lblLabel2 ;
      OF wndABMListado ;
      VALUE _HMG_aABMLangLabel[ 12 ] ;
      WIDTH 140 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 160, 20 LABEL lblLabel3 ;
      OF wndABMListado ;
      VALUE _HMG_aABMLangLabel[ 13 ] ;
      WIDTH 140 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 160, 250 LABEL lblLabel4 ;
      OF wndABMListado ;
      VALUE _HMG_aABMLangLabel[ 14 ] ;
      WIDTH 140 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      SIZE 8

   // ListBox.
   @ 45, 20 LISTBOX lbxListado ;
      OF wndABMListado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      items aCamposListado ;
      VALUE 1 ;
      FONT "Arial" ;
      SIZE 9
   @ 45, 250 LISTBOX lbxCampos ;
      OF wndABMListado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      items aCamposTotales ;
      VALUE 1 ;
      FONT "Arial" ;
      SIZE 9 ;
      SORT

   // Spinner.
   @ 185, 20 SPINNER spnPrimero ;
      OF wndABMListado ;
      RANGE 1, ( _cArea )->( RecCount() ) ;
      VALUE nPrimero ;
      WIDTH 70 ;
      HEIGHT 21 ;
      FONT "Arial" ;
      SIZE 9
   @ 185, 250 SPINNER spnUltimo ;
      OF wndABMListado ;
      RANGE 1, ( _cArea )->( RecCount() ) ;
      VALUE nUltimo ;
      WIDTH 70 ;
      HEIGHT 21 ;
      FONT "Arial" ;
      SIZE 9

   // Botones.
   @ 45, 170 BUTTON btnMas ;
      OF wndABMListado ;
      CAPTION _HMG_aABMLangButton[ 14 ] ;
      action {|| ABMListadoEvento( ABM_LISTADO_MAS ) } ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 85, 170 BUTTON btnMenos ;
      OF wndABMListado ;
      CAPTION _HMG_aABMLangButton[ 15 ] ;
      action {|| ABMListadoEvento( ABM_LISTADO_MENOS ) } ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8
   @ 225, 240 BUTTON btnImprimir ;
      OF wndABMListado ;
      CAPTION _HMG_aABMLangButton[ 16 ] ;
      action {|| ABMListadoEvento( ABM_LISTADO_IMPRIMIR ) } ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP
   @ 225, 330 BUTTON btnCerrar ;
      OF wndABMListado ;
      CAPTION _HMG_aABMLangButton[ 17 ] ;
      action {|| ABMListadoEvento( ABM_LISTADO_CERRAR ) } ;
      WIDTH 70 ;
      HEIGHT 30 ;
      FONT "ms sans serif" ;
      SIZE 8 ;
      NOTABSTOP

   // Activación de la ventana----------------------------------------------------
   CENTER WINDOW wndABMListado
   ACTIVATE WINDOW wndABMListado

RETURN ( nil )


 /***************************************************************************************
 *     Función: ABMListadoEvento( nEvento )
 *       Autor: Cristóbal Mollá
 * Descripción: Ejecuta los eventos de la ventana de definición del listado.
 *  Parámetros: nEvento    Valor numérico con el tipo de evento a ejecutar.
 *    Devuelve: NIL
 ***************************************************************************************/
FUNCTION ABMListadoEvento( nEvento )

   // Declaración de variables locales.-------------------------------------------
   LOCAL cItem // Nombre del item.
   LOCAL nItem // Numero del item.
   LOCAL aCampo := {} // Nombres de los campos.
   LOCAL nIndice // Numero del campo.
   LOCAL nAnchoCampo // Ancho del campo.
   LOCAL nAnchoTitulo // Ancho del título.
   LOCAL nTotal := 0 // Ancho total.
   LOCAL nPrimero := wndABMListado .spnPrimero. VALUE // Registro inicial.
   LOCAL nUltimo := wndABMListado .spnUltimo. VALUE // Registro final.

   // Control de eventos.
   DO CASE
      // Cerrar el cuadro de dialogo de definición de listado.---------------
   CASE nEvento == ABM_LISTADO_CERRAR
      wndABMListado.RELEASE

      // Añadir columna.-----------------------------------------------------
   CASE nEvento == ABM_LISTADO_MAS
      IF .NOT. ( wndABMListado.lbxCampos.ItemCount == 0 .OR. ;
            wndABMListado.lbxCampos.VALUE == 0 )
         nItem := wndABMListado.lbxCampos.VALUE
         cItem := wndABMListado.lbxCampos.Item( nItem )
         wndABMListado.lbxListado.addItem( cItem )
         DELETE ITEM nItem FROM lbxCampos OF wndABMListado
         wndABMListado.lbxCampos.VALUE := iif( nItem < wndABMListado.lbxCampos.ItemCount, nItem, wndABMListado.lbxCampos.ItemCount )
         wndABMListado.lbxCampos.setFocus
      ENDIF

      // Quitar columna.-----------------------------------------------------
   CASE nevento == ABM_LISTADO_MENOS
      IF .NOT. ( wndABMListado.lbxListado.ItemCount == 0 .OR. ;
            wndABMListado.lbxListado.VALUE == 0 )
         nItem := wndABMListado.lbxListado.VALUE
         cItem := wndABMListado.lbxListado.Item( nItem )
         wndABMListado.lbxCampos.addItem( cItem )
         DELETE ITEM nItem FROM lbxListado OF wndABMListado
         wndABMListado.lbxListado.VALUE := iif( nItem < wndABMListado.lbxListado.ItemCount, nItem, wndABMListado.lbxListado.ItemCount )
         wndABMListado.lbxListado.setFocus
      ENDIF

      // Imprimir listado.---------------------------------------------------
   CASE nevento == ABM_LISTADO_IMPRIMIR

      // Copia el contenido de los controles a las variables.
      _aCamposListado := {}
      FOR nItem := 1 TO wndABMListado.lbxListado.ItemCount
         AAdd( _aCamposListado, wndABMListado.lbxListado.Item( nItem ) )
      NEXT

      // Establece el numero de orden del campo a listar.
      _aNumeroCampo := {}
      FOR nItem := 1 TO Len( _aEstructura )
         AAdd( aCampo, _aEstructura[ nItem, 1 ] )
      NEXT
      FOR nItem := 1 TO Len( _aCamposListado )
         AAdd( _aNumeroCampo, AScan( aCampo, _aCamposListado[ nItem ] ) )
      NEXT

      // Establece el ancho del campo a listar.
      _aAnchoCampo := {}
      FOR nItem := 1 TO Len( _aCamposListado )
         nIndice := _aNumeroCampo[ nItem ]
         nAnchoTitulo := Len( _aCampos[ nIndice ] )
         nAnchoCampo := _aEstructura[ nIndice, 3 ]
         IF _aEstructura[ nIndice, 2 ] == "D"
            AAdd( _aAnchoCampo, iif( nAnchoTitulo > nAnchoCampo, ;
               nAnchoTitulo + 4, ;
               nAnchoCampo + 4 ) )
         ELSE
            AAdd( _aAnchoCampo, iif( nAnchoTitulo > nAnchoCampo, ;
               nAnchoTitulo + 2, ;
               nAnchoCampo + 2 ) )
         ENDIF
      NEXT

      // Comprueba el tamaño del listado y lanza la impresión.
      FOR nItem := 1 TO Len( _aAnchoCampo )
         nTotal += _aAnchoCampo[ nItem ]
      NEXT
      IF nTotal > 164

         // No cabe en la hoja.
         MsgExclamation( _HMG_aABMLangUser[ 6 ] )
      ELSE
         IF nTotal > 109

            // Cabe en una hoja horizontal.
            ABMListadoImprimir( .T., nPrimero, nUltimo )
         ELSE

            // Cabe en una hoja vertical.
            ABMListadoImprimir( .F., nPrimero, nUltimo )
         ENDIF
      ENDIF

      // Control de error.---------------------------------------------------
   OTHERWISE
      MsgMiniGUIError( _HMG_aABMLangError[ 5 ] )
   ENDCASE

RETURN ( nil )


 /***************************************************************************************
 *     Función: ABMListadoImprimir( lOrientacion, nPrimero, nUltimo )
 *       Autor: Cristóbal Mollá
 * Descripción: Lanza el listado definido a la impresora.
 *  Parámetros: lOrientacion    Lógico que indica si el listado es horizontal (.t.)
 *                              o vertical (.f.)
 *              nPrimero        Valor numerico con el primer registro a imprimir.
 *              nUltimo         Valor numérico con el último registro a imprimir.
 *    Devuelve: NIL
 ***************************************************************************************/
FUNCTION ABMListadoImprimir( lOrientacion, nPrimero, nUltimo )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nLineas := 1 // Numero de linea.
   LOCAL nPaginas // Numero de páginas.
   LOCAL nFila := 12 // Numero de fila.
   LOCAL nColumna // Numero de columna.
   LOCAL nItem // Indice de iteracion.
   LOCAL nIndice // Indice de campo.
   LOCAL lCabecera // ¿Imprimir cabecera?.
   LOCAL nPagina := 1 // Numero de pagina.
   LOCAL lSalida // ¿Salir del listado?.
   LOCAL nRegistro := ( _cArea )->( RecNo() ) // Registro anterior.
   LOCAL cTexto // Texto para lógicos.

   // Definición del rango del listado.-------------------------------------------
   ( _cArea )->( dbGoto( nPrimero ) )
   ( _cArea )->( dbEval( {|| nLineas++ },, {|| !( RecNo() == nUltimo ) .AND. ! Eof() },,, .T. ) )
   ( _cArea )->( dbGoto( nPrimero ) )

   // Inicialización de la impresora.---------------------------------------------
   INIT PRINTSYS

   SELECT BY DIALOG PREVIEW

   // Control de errores.---------------------------------------------------------
   IF HBPRNERROR != 0
      RETURN ( nil )
   ENDIF

   // Definición de fuentes, rellenos y tipos de linea.---------------------------
   // Fuentes.
   DEFINE FONT "f10" name "arial" SIZE 10
   DEFINE FONT "f10n" name "arial" SIZE 10 bold
   DEFINE FONT "f9ns" name "arial" SIZE 9 bold underline
   DEFINE FONT "f14n" name "arial" SIZE 14 bold
   DEFINE FONT "f8n" name "arial" SIZE 8 bold
   DEFINE FONT "f8" name "arial" SIZE 8

   // Inicio del listado.
   START DOC

   SET UNITS ROWCOL

   // Definición de orientacion.--------------------------------------------------
   IF lOrientacion
      SET PAGE ORIENTATION DMORIENT_LANDSCAPE ;
         PAPERSIZE DMPAPER_FIRST FONT "f10"
   ELSE
      SET PAGE ORIENTATION DMORIENT_PORTRAIT ;
         PAPERSIZE DMPAPER_FIRST FONT "f10"
   ENDIF

   lCabecera := .T.
   lSalida := .T.
   DO WHILE lSalida

      // Cabecera.-----------------------------------------------------------
      IF lCabecera
         START PAGE
         Cabecera( nPrimero, nUltimo )
         lCabecera := .F.
      ENDIF

      // Registros.----------------------------------------------------------
      nColumna := 10
      FOR nItem := 1 TO Len( _aNumeroCampo )
         nIndice := _aNumeroCampo[ nItem ]
         DO CASE
         CASE _aEstructura[ nIndice, 2 ] == "L"
            SET TEXT ALIGN LEFT
            cTexto := iif( ( _cArea )->( FieldGet( nIndice ) ), _HMG_aABMLangLabel[ 20 ], _HMG_aABMLangLabel[ 21 ] )
            @ nFila, nColumna SAY cTexto FONT "f10" TO PRINT
            nColumna += _aAnchoCampo[ nItem ]
         CASE _aEstructura[ nIndice, 2 ] == "N"
            SET TEXT ALIGN RIGHT
            nColumna += _aAnchoCampo[ nItem ] - 2
            @ nFila, nColumna say ( _cArea )->( FieldGet( nIndice ) ) FONT "f10" TO PRINT
            nColumna += 2
         OTHERWISE
            SET TEXT ALIGN LEFT
            @ nFila, nColumna say ( _cArea )->( FieldGet( nIndice ) ) FONT "f10" TO PRINT
            nColumna += _aAnchoCampo[ nItem ]
         ENDCASE
      NEXT
      nFila++
      ( _cArea )->( dbSkip( 1 ) )

      // Pie.----------------------------------------------------------------
      IF lOrientacion
         // Horizontal
         IF nFila > 43
            nPaginas := Int( nLineas / 32 )
            IF .NOT. Mod( nLineas, 32 ) == 0
               nPaginas++
            ENDIF

            SET TEXT ALIGN LEFT

            @ 45, 10, 45, HBPRNMAXCOL - 5 line
            SET TEXT ALIGN CENTER
            @ 45, HBPRNMAXCOL / 2 SAY _HMG_aABMLangLabel[ 22 ] + AllTrim( Str( nPagina ) ) + _HMG_aABMLangLabel[ 23 ] + AllTrim( Str( nPaginas ) ) FONT "f10n" TO PRINT
            lCabecera := .T.
            nPagina++
            nFila := 12

            END PAGE
         ENDIF
      ELSE
         // Vertical
         IF nFila > 63
            nPaginas := Int( nLineas / 52 )
            IF .NOT. Mod( nLineas, 52 ) == 0
               nPaginas++
            ENDIF

            SET TEXT ALIGN LEFT

            @ 65, 10, 65, HBPRNMAXCOL - 5 line

            SET TEXT ALIGN CENTER

            @ 65, HBPRNMAXCOL / 2 SAY _HMG_aABMLangLabel[ 22 ] + AllTrim( Str( nPagina ) ) + _HMG_aABMLangLabel[ 23 ] + AllTrim( Str( nPaginas ) ) FONT "f10n" TO PRINT
            lCabecera := .T.
            nPagina++
            nFila := 12

            END PAGE
         ENDIF
      ENDIF

      // Comprobación del rango de registro.---------------------------------
      IF ( ( _cArea )->( RecNo() ) == nUltimo )
         IF lCabecera
            START PAGE
            Cabecera( nPrimero, nUltimo )
            lCabecera := .F.
         ENDIF
         nColumna := 10

         // Imprime el último registro.
         FOR nItem := 1 TO Len( _aNumeroCampo )
            nIndice := _aNumeroCampo[ nItem ]
            DO CASE
            CASE _aEstructura[ nIndice, 2 ] == "L"
               SET TEXT ALIGN LEFT
               cTexto := iif( ( _cArea )->( FieldGet( nIndice ) ), _HMG_aABMLangLabel[ 20 ], _HMG_aABMLangLabel[ 21 ] )
               @ nFila, nColumna SAY cTexto FONT "f10" TO PRINT
               nColumna += _aAnchoCampo[ nItem ]
            CASE _aEstructura[ nIndice, 2 ] == "N"
               SET TEXT ALIGN RIGHT
               nColumna += _aAnchoCampo[ nItem ] - 2
               @ nFila, nColumna say ( _cArea )->( FieldGet( nIndice ) ) FONT "f10" TO PRINT
               nColumna += 2
            OTHERWISE
               SET TEXT ALIGN LEFT
               @ nFila, nColumna say ( _cArea )->( FieldGet( nIndice ) ) FONT "f10" TO PRINT
               nColumna += _aAnchoCampo[ nItem ]
            ENDCASE
         NEXT
         lSalida := .F.
      ENDIF
      IF ( _cArea )->( Eof() )
         lSalida := .F.
      ENDIF
   ENDDO

   // Comprueba que se imprime el pie al finalizar.-------------------------------
   IF lOrientacion
      // Horizontal
      IF nFila <= 43
         nPaginas := Int( nLineas / 32 )
         IF .NOT. Mod( nLineas, 32 ) == 0
            nPaginas++
         ENDIF
         SET TEXT ALIGN LEFT
         @ 45, 10, 45, HBPRNMAXCOL - 5 line
         SET TEXT ALIGN CENTER
         @ 45, HBPRNMAXCOL / 2 SAY _HMG_aABMLangLabel[ 22 ] + AllTrim( Str( nPagina ) ) + _HMG_aABMLangLabel[ 23 ] + AllTrim( Str( nPaginas ) ) FONT "f10n" TO PRINT
      ENDIF
   ELSE
      // Vertical
      IF nFila <= 63
         nPaginas := Int( nLineas / 52 )
         IF .NOT. Mod( nLineas, 52 ) == 0
            nPaginas++
         ENDIF
         SET TEXT ALIGN LEFT
         @ 65, 10, 65, HBPRNMAXCOL - 5 line
         SET TEXT ALIGN CENTER
         @ 65, HBPRNMAXCOL / 2 SAY _HMG_aABMLangLabel[ 22 ] + AllTrim( Str( nPagina ) ) + _HMG_aABMLangLabel[ 23 ] + AllTrim( Str( nPaginas ) ) FONT "f10n" TO PRINT
      ENDIF
   ENDIF

   END PAGE
   END DOC
   RELEASE PRINTSYS

   // Restaura.-------------------------------------------------------------------
   ( _cArea )->( dbGoto( nRegistro ) )

RETURN ( nil )

 /***************************************************************************************
 * static function Cabecera( nPrimero, nUltimo )
 ***************************************************************************************/
STATIC FUNCTION Cabecera( nPrimero, nUltimo )

   LOCAL nColumna // Numero de columna.
   LOCAL nItem // Indice de iteracion.
   LOCAL nIndice // Indice de campo.

   SET TEXT ALIGN LEFT
   @ 5, 10 SAY _HMG_aABMLangLabel[ 15 ] + _cTitulo FONT "f14n" TO PRINT
   @ 6, 10, 6, HBPRNMAXCOL - 5 line
   @ 7, 10 SAY _HMG_aABMLangLabel[ 16 ] FONT "f10n" TO PRINT
   @ 7, 18 SAY Date() FONT "f10" TO PRINT
   @ 8, 10 SAY _HMG_aABMLangLabel[ 17 ] FONT "f10n" TO PRINT
   @ 8, 30 SAY AllTrim( Str( nPrimero ) ) FONT "f10" TO PRINT
   @ 8, 40 SAY _HMG_aABMLangLabel[ 18 ] FONT "f10n" TO PRINT
   @ 8, 60 SAY AllTrim( Str( nUltimo ) ) FONT "f10" TO PRINT
   @ 9, 10 SAY _HMG_aABMLangLabel[ 19 ] FONT "f10n" TO PRINT
   @ 9, 30 SAY ordName() FONT "f10" TO PRINT
   nColumna := 10
   FOR nItem := 1 TO Len( _aNumeroCampo )
      nIndice := _aNumeroCampo[ nItem ]
      @ 11, nColumna SAY _aCampos[ nIndice ] FONT "f9ns" TO PRINT
      nColumna += _aAnchoCampo[ nItem ]
   NEXT

RETURN ( nil )

 /***************************************************************************************
 * function NoArray( aOldArray )
 ***************************************************************************************/
FUNCTION NoArray( aOldArray )

   LOCAL aNewArray := {}

   IF ISARRAY ( aOldArray )
      ASize ( aNewArray, Len ( aOldArray ) )
      AEval ( aOldArray, {| x, i | aNewArray[ i ] := ! x } )
   ENDIF

RETURN ( aNewArray )
