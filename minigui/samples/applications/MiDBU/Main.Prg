#include <hmg.ch>
Memvar cArchivo
*------------------------------------------------------------------------------*
Function Main(cBase)
*------------------------------------------------------------------------------*
REQUEST DBFCDX
RDDSETDEFAULT( "DBFCDX" )

SET CODEPAGE TO SPANISH
SET LANGUAGE TO SPANISH
SET DELETED ON
SET CENTURY ON
SET DATE FORMAT "dd-mm-yyyy"
SET EPOCH TO YEAR(DATE())-50

SET TOOLTIPSTYLE BALLOON
SET BROWSESYNC ON
SET NAVIGATION EXTENDED

PUBLIC cArchivo := iif(cBase==NIL,'',cBase)

SET DEFAULT ICON TO 'MAIN'

DEFINE WINDOW Win_1 ;
	AT 0,0 ;
	WIDTH 1024 ;
	HEIGHT 768 ;
	TITLE 'AXIS SoftWare - MiDBU VER 2.00 - M.A.Sistemas' ;
	MAIN ;
	ON INIT iif(! Empty(cArchivo), EditarDBF(), ) ;
        ON MAXIMIZE OnSize() ;
        ON SIZE OnSize()
	
	DEFINE TOOLBAR ToolBar_1 FLAT BUTTONSIZE 100,100 BORDER BREAK
	
		BUTTON Button_1 ;
			CAPTION '';
			TOOLTIP 'Crear o modificar una nueva base de datos';
			PICTURE 'CREAR';
			ACTION NuevaDBF()

		BUTTON Button_10 ;
			CAPTION '';
			TOOLTIP 'Editar base de datos';
			PICTURE 'EDITAR';
			ACTION EditarDBF()

		BUTTON Button_80 ;
			CAPTION '';
			TOOLTIP 'Salir' ;
			PICTURE 'SALIR' ;
			ACTION EXIT PROGRAM

	END TOOLBAR
	
	@ (768/2)-150, (1024/2)-150 IMAGE Imagen_3 PICTURE 'MALOGO' WIDTH 300 HEIGHT 300 TRANSPARENT

	@  665,10 HYPERLINK cWeb;
			VALUE 'http://www.axis-soft.com.ar';
			ADDRESS 'http://www.axis-soft.com.ar';
			AUTOSIZE;
			FONT 'Tahoma';
			SIZE 14;
			BOLD;
			HANDCURSOR
			
	DEFINE STATUSBAR FONT 'Tahoma' SIZE 10
		STATUSITEM "Diseño: (c) M.A.Sistemas <info.masistemas@gmail.com>"
		CLOCK 
		DATE 
	END STATUSBAR

END WINDOW
CENTER WINDOW Win_1
ACTIVATE WINDOW Win_1

Return NIL

*------------------------------------------------------------------------------*
Static Function OnSize()
*------------------------------------------------------------------------------*
Win_1.Imagen_3.ROW := (Win_1.HEIGHT/2)-150
Win_1.Imagen_3.COL := (Win_1.WIDTH/2)-150

Win_1.cWeb.ROW     := (Win_1.HEIGHT)-103

Return NIL
