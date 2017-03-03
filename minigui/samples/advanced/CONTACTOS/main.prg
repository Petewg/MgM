/*
* Contactos
* (C) 2003 Roberto Lopez <harbourminigui@gmail.com>
*/

/*
	El archivo 'minigui.ch' debe ser incluido en todos los programas MiniGUI
*/

#include "minigui.ch"


Function Main

///////////////////////////////////////////////////////////////////////////////
// Inicializacion RDD DBFCDX Nativo
///////////////////////////////////////////////////////////////////////////////

	REQUEST DBFCDX , DBFFPT
	RDDSETDEFAULT( "DBFCDX" )

///////////////////////////////////////////////////////////////////////////////

	SET DELETED ON
	SET DATE FRENCH
	SET CENTURY ON
	SET BROWSESYNC ON
	SET AUTOADJUST ON

/*
	Todas los programas MiniGUI, deben tener una ventana principal.
	Esta debe ser definida antes que cualquier otra.
*/

	DEFINE WINDOW Principal ;
		AT 0,0 ;
		WIDTH 640 ;
		HEIGHT 480 ;
		TITLE 'Contactos' ;
		MAIN ;
		ICON 'Tutor.Ico' 

/*
	DEFINE WINDOW:	Inicia la definicion de la ventana. Debe indicarse un
			nombre de ventana que sera unico para todo el programa.
			(Puede usarse en codigo el mismo nombre mas de una vez
			pero solo una puede estar activa al mismo tiempo)	
	AT:		Indica Fila,Columna del angulo superior izquierdo de la 
			ventana (medida en pixels)
	WIDTH:		Ancho de la ventaba medido en pixels.
	HEIGHT:		Altura de la ventana medida en pixels.
	TITLE:		Titulo de la ventana		
	MAIN:		Indica que se esta definiendo la ventana principal del 
			programa.
*/

		// Definicion del menu principal 
		// Cada menu puede tener multiples POPUPs (submenus)
		// Los popups pueden anidarse sin limites.
		// A continuacion de DEFINE POPUP se indica la etiqueta.
		// El '&' se usa para indicar la 'hot-key' asociada con ese
		// item de menu. En el caso del primer popup, sera ALT+A
		// Cada item de menu se define mediante MENUITEM.
		// La clausula ACTION, indica el procedimiento a ejecutarse
		// cuando el usuario selecciona el item.
		// SEPARATOR Incluye una linea horizontal, usada para separar 
		// items.
	
		DEFINE MAIN MENU 
			DEFINE POPUP '&Archivo'
				MENUITEM '&Contactos'		ACTION AdministradorDeContactos()
				MENUITEM '&Tipos de Contacto'	ACTION AdministradorDeTipos()
				SEPARATOR
				MENUITEM '&Salir'		ACTION EXIT PROGRAM
			END POPUP
			DEFINE POPUP 'A&yuda'
				MENUITEM 'A&cerca de...' ACTION MsgInfo ('Tutor ABM' + Chr(13) + Chr(10) + '(c) 2003 Roberto Lopez' )
			END POPUP
		END MENU

		// Fin de la definicion del menu principal 

		// El control TOOLBAR puede contener multiples botones de 
		// comando.
		// El tama¤o de estos botones es definido por medio de la
		// clausula BUTTONSIZE <Ancho>,<Alto>
		// FLAT crea botones 'planos'
		// RIGHTTEXT indica que el texto de los botones se ubicara
		// a la derecha de su imagen.

		DEFINE TOOLBAR ToolBar_1 FLAT BUTTONSIZE 110,35 RIGHTTEXT BORDER

			BUTTON Button_1 ;
				CAPTION 'Contactos' ;
				PICTURE 'Contactos' ;
				ACTION AdministradorDeContactos()

			// CAPTION Indica el titulo del boton.
			// PICTURE El archivo de imagen asociado (BMP)
			// ACTION Un procedimiento de evento asociado al boton
			// (lo que va a ejecutarse cuando se haga click)

			BUTTON Button_2 ;
				CAPTION 'Tipos Ctto.' ;
				PICTURE 'Tipos' ;
				ACTION AdministradorDeTipos()

			BUTTON Button_3 ;
				CAPTION 'Ayuda' ;
				PICTURE 'ayuda' ;
				ACTION MsgInfo ('Tutor ABM' + Chr(13) + Chr(10) + '(c) 2003 Roberto Lopez' )

		END TOOLBAR

		// La barra de estado aparece en la parte inferior de la ventana.
		// Puede tener multiples secciones definidas por medio de STATUSITEM
		// Existen dos secciones (opcionales) predefinidas, llamadas 
		// CLOCK y DATE (muestran un reloj y la fecha respectivamente)

		DEFINE STATUSBAR 
			STATUSITEM "(c) 2003 Roberto Lopez <harbourminigui@gmail.com>" 
			CLOCK 
			DATE 
		END STATUSBAR

	// Fin de la definicion de la ventana

	END WINDOW

	// maximizar la ventana 

	MAXIMIZE WINDOW Principal 

	// Activar la ventana

	ACTIVATE WINDOW Principal

	// El comando ACTIVATE WINDOW genera un estado de espera. 
	// El programa estara detenido en este punto hasta que la ventana
	// sea cerrada interactiva o programaticamente. Solo se ejecutaran
	// los procedimientos de evento asociados a sus controles (o a la 
	// ventana misma)

Return Nil
