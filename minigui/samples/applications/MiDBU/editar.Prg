#include <hmg.ch>
Memvar cArchivo
Memvar aNomb,aJust,aLong,aHdr,cBase,cCampo,cFiltro
*------------------------------------------------------------------------------*
Function EditarDBF()
*------------------------------------------------------------------------------*
LOCAL nCamp,aEst,cCarpeta,i,nPos
PUBLIC aNomb,aJust,aLong,aHdr,cBase,cCampo,cFiltro := ''

SET SOFTSEEK ON

IF cArchivo == ''
	cCarpeta := GetCurrentFolder()
	cArchivo := Getfile ( { {'DBFs','*.DBF'} } , 'Abrir base de datos' , cCarpeta , .F. , .T. )
Endif

nPos := RAT( '\',cArchivo )
cCarpeta := SubStr( cArchivo,1,nPos )
cArchivo := SubStr( cArchivo,nPos+1,Len(cArchivo) )

nPos := RAT( '.',cArchivo )
cArchivo := SubStr( cArchivo,1,nPos-1 )

IF FILE(cCarpeta+cArchivo+'.DBF')
   USE (cCarpeta+cArchivo) ALIAS (cArchivo) EXCLUSIVE NEW
   INDEX ON &(FieldName(1)) TO Aux1

   cBase := Alias()
   nCamp := Fcount()
   aEst  := DBstruct()

   aNomb := {} 
   aHdr  := {} 
   aJust := {} 
   aLong := {}

   For i := 1 to nCamp
     aadd(aNomb,aEst[i,1])
     aadd(aHdr,aEst[i,1])
     aadd(aJust,iif(aEst[i,2]=='N',1,0))
     aadd(aLong,Min(250,Max(Len(aEst[i,1]),aEst[i,3])*iif(aEst[i,3]>5,10,12)))
   Next

   CreaBR()
Endif
Return NIL
*------------------------------------------------------------------------------*
Static Function CreaBR()
*------------------------------------------------------------------------------*

DEFINE WINDOW Win_2;
	AT 0,0;
	WIDTH 1024;
	HEIGHT 768;
	TITLE Upper( cArchivo );
	MODAL;
	ON RELEASE ( DBCLOSEALL(), Ferase ('Aux1.CDX') )
    
	DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 58,36 IMAGESIZE 20,20  FLAT BORDER
		BUTTON PRIMERO;
			CAPTION '&Primero'	;
			PICTURE 'PRIMERO';
			ACTION ( _BrowseHome('BR_1', 'Win_2') , Win_2.BR_1.Value := RecNo() )

		BUTTON ANTERIOR;
			CAPTION '&Anterior';
			PICTURE 'ANTERIOR';
			ACTION ( _BrowseUp('BR_1', 'Win_2') , Win_2.BR_1.Value := RecNo() ) 

		BUTTON SIGUIENTE;
			CAPTION '&Siguiente';
			PICTURE 'SIGUIENTE';
			ACTION ( _BrowseDown('BR_1', 'Win_2') , Win_2.BR_1.Value := RecNo() ) 

		BUTTON ULTIMO;
			CAPTION '&Ultimo';
			PICTURE 'ULTIMO';
			ACTION ( _BrowseEnd('BR_1', 'Win_2') , Win_2.BR_1.Value := RecNo() ) SEPARATOR 

		BUTTON NUEVO;
			CAPTION '&Nuevo';
			PICTURE 'NUEVO1';
			ACTION ( Nuevo() )

		BUTTON DELE;
			CAPTION '&Borrar';
			PICTURE 'BORRAR';
			ACTION ( Borrar() )

		BUTTON ZAP;
			CAPTION '&Pack';
			PICTURE 'BORRAR';
			ACTION ( BorrarTodo() ) 
			
		BUTTON CERRAR;
			CAPTION '&Cerrar';
			PICTURE 'CERRAR1';
			ACTION ( cArchivo := '', Win_2.release )

	END TOOLBAR

	@ 60, 10 LABEL LABEL_1 VALUE 'Buscar:' AUTOSIZE
	@ 60, 70 TEXTBOX Control_1 WIDTH 250 ON ENTER ( Buscar() )      

	@ 60,450 LABEL LABEL_2    VALUE 'Ordenar:' AUTOSIZE
	@ 60,510 COMBOBOX Combo_1 ITEMS aNomb VALUE 1 WIDTH 250 ON CHANGE ( Ordenar() )      

	@ 60,880 LABEL LABEL_3 VALUE 'Filtrar:' AUTOSIZE
	@ 51,940 BUTTON FILTRAR CAPTION '' PICTURE 'FILTRAR' WIDTH 38 HEIGHT 38 TOP TOOLTIP 'Seleccionar registros' ACTION ( Filtrar() )
	
	@ 90,10 BROWSE BR_1;
			WIDTH ( Win_2.width-38 );
			HEIGHT ( Win_2.height-135 );
			WIDTHS aLong;
			HEADERS aHdr;
			WORKAREA &(cBase);
			FIELDS aNomb;
			JUSTIFY aJust;
			INPLACE;
			PAINTDOUBLEBUFFER;
			ON DBLCLICK ( Win_2.BR_1.AllowEdit := .T. )
			
END WINDOW
SET TOOLTIP BACKCOLOR TO { 255,255,184 } OF Win_2
SET TOOLTIP TEXTCOLOR TO { 000,000,000 } OF Win_2
Win_2.BR_1.SetFocus

CENTER WINDOW Win_2
ACTIVATE WINDOW Win_2

Return NIL
*------------------------------------------------------------------------------*
Static Function Ordenar()
*------------------------------------------------------------------------------*
INDEX ON &(Win_2.Combo_1.Item(Win_2.Combo_1.Value)) TO Aux1
&cBase->(DbGoTop())

Win_2.BR_1.Value := &cBase->(RecNo())

Win_2.BR_1.Refresh
Win_2.BR_1.SetFocus

Return NIL
*------------------------------------------------------------------------------*
Static Function Buscar()
*------------------------------------------------------------------------------*
cCampo := Win_2.Combo_1.Item(Win_2.Combo_1.Value)

&cBase->(DbSetOrder(1))
&cBase->(DbGoTop())
IF ValType(&cCampo) == 'C'
    &cBase->(DbSeek( Win_2.Control_1.Value )) 
ELSEIF ValType(&cCampo) == 'N'
    &cBase->(DbSeek( Val(Win_2.Control_1.Value) )) 
ELSEIF ValType(&cCampo) == 'D'
    &cBase->(DbSeek( CtoD(Win_2.Control_1.Value) )) 
ENDIF

Win_2.BR_1.Value := &cBase->(RecNo())

Win_2.BR_1.Refresh
Win_2.BR_1.SetFocus

Return NIL
*------------------------------------------------------------------------------*
Static Function Nuevo()
*------------------------------------------------------------------------------*
&cBase->(DbAppend())

Win_2.BR_1.Value := &cBase->(RecNo())

Win_2.BR_1.Refresh
Win_2.BR_1.SetFocus

Return NIL
*------------------------------------------------------------------------------*
Static Function Borrar()
*------------------------------------------------------------------------------*

&cBase->(DbDelete())
&cBase->(DbSkip(-1))
IF &cBase->(Bof())
    &cBase->(DbGoTop())
ENDIF

Win_2.BR_1.Value := &cBase->(RecNo())

Win_2.BR_1.Refresh
Win_2.BR_1.SetFocus

Return NIL
*------------------------------------------------------------------------------*
Static Function BorrarTodo()
*------------------------------------------------------------------------------*
Select(cBase)
Pack
DbGoTop()

Win_2.BR_1.Value := RecNo()

Win_2.BR_1.Refresh
Win_2.BR_1.SetFocus

Return NIL
*------------------------------------------------------------------------------*
Static Function Filtrar()
*------------------------------------------------------------------------------*
cCampo := UPPER(ALLTRIM(FIELD(Win_2.Combo_1.Value)))

Select(cBase)
cFiltro := UPPER(ALLTRIM(InputBox( 'Filtro:' , 'Busqueda' , cFiltro )))

IF Len(cFiltro) != 0
    IF ValType(&cCampo) == 'C'
        SET FILTER TO ( cFiltro $ &cBase->(&cCampo) )                    
    ELSEIF ValType(&cCampo) == 'N'
        SET FILTER TO ( Val(cFiltro) == &cBase->(&cCampo) )                    
    ELSEIF ValType(&cCampo) == 'D'
        SET FILTER TO ( CtoD(cFiltro) == &cBase->(&cCampo) )                    
    ENDIF
ELSE
    SET FILTER TO
ENDIF
DbGoTop()

Win_2.BR_1.Value := RecNo()

Win_2.BR_1.Refresh
Win_2.BR_1.SetFocus

Return NIL
