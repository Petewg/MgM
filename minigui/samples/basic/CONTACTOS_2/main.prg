/*
* Contactos
* (C) 2003 Roberto Lopez <harbourminigui@gmail.com>
*
* (C) 2005 Designed by MigSoft with MiniGUI IDE :: Roberto Lopez ::
*/

#include "minigui.ch"

Static Nuevo := .F.

Function Main

        set delete on
        set browsesync on
        set century on
        set date french

        Request DBFCDX , DBFFPT
        Rddsetdefault( "DBFCDX" )

	Set Default Icon To "Tutor"
        Load Window Principal
	Activate Window Principal

Return Nil
*------------------------------------------------------------------------------*
PROCEDURE AdministradorDeContactos
*------------------------------------------------------------------------------*

        Load Window Win_1
      	Win_1.Browse_1.SetFocus
	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

RETURN
*------------------------------------------------------------------------------*
PROCEDURE AbrirTablas
*------------------------------------------------------------------------------*

	USE TIPOS INDEX TIPOS SHARED NEW
	SET ORDER TO TAG Cod_Tipo
	GO TOP

	USE CONTACTOS INDEX CONTACTOS SHARED NEW
	SET ORDER TO TAG Apellido
	GO TOP

	Win_1.Browse_1.Value := Contactos->(RecNo())

RETURN
*------------------------------------------------------------------------------*
PROCEDURE CerrarTablas
*------------------------------------------------------------------------------*

	Close Contactos
	Close Tipos

RETURN
*------------------------------------------------------------------------------*
PROCEDURE DesactivarEdicion
*------------------------------------------------------------------------------*

	Win_1.Browse_1.Enabled		:= .T.
	Win_1.Control_1.Enabled		:= .F.
	Win_1.Control_2.Enabled		:= .F.
	Win_1.Control_3.Enabled		:= .F.
	Win_1.Control_4.Enabled		:= .F.
	Win_1.Control_5.Enabled		:= .F.
	Win_1.Control_6.Enabled		:= .F.
	Win_1.Control_7.Enabled		:= .F.
	Win_1.Control_8.Enabled		:= .F.
	Win_1.Control_9.Enabled		:= .F.
	Win_1.Control_10.Enabled	:= .F.
	Win_1.Control_11.Enabled	:= .F.
	Win_1.Control_12.Enabled	:= .F.

	Win_1.Aceptar.Enabled		:= .F.
	Win_1.Cancelar.Enabled		:= .F.

	Win_1.ToolBar_1.Enabled		:= .T.

	Win_1.Browse_1.SetFocus

RETURN
*------------------------------------------------------------------------------*
PROCEDURE ActivarEdicion
*------------------------------------------------------------------------------*

	Win_1.Browse_1.Enabled		:= .F.
	Win_1.Control_1.Enabled		:= .T.
	Win_1.Control_2.Enabled		:= .T.
	Win_1.Control_3.Enabled		:= .T.
	Win_1.Control_4.Enabled		:= .T.
	Win_1.Control_5.Enabled		:= .T.
	Win_1.Control_6.Enabled		:= .T.
	Win_1.Control_7.Enabled		:= .T.
	Win_1.Control_8.Enabled		:= .T.
	Win_1.Control_9.Enabled		:= .T.
	Win_1.Control_10.Enabled	:= .T.
	Win_1.Control_11.Enabled	:= .T.
	Win_1.Control_12.Enabled	:= .T.

	Win_1.Aceptar.Enabled		:= .T.
	Win_1.Cancelar.Enabled		:= .T.
	Win_1.ToolBar_1.Enabled		:= .F.

	Win_1.Control_1.SetFocus

RETURN
*------------------------------------------------------------------------------*
PROCEDURE CancelarEdicion()
*------------------------------------------------------------------------------*

	DesactivarEdicion()
	Actualizar()
	UNLOCK
	Nuevo := .F.

RETURN
*------------------------------------------------------------------------------*
PROCEDURE AceptarEdicion()
*------------------------------------------------------------------------------*

	DesactivarEdicion()

	Tipos->(DbGoTo (Win_1.Control_2.Value))

	If Nuevo == .T.
		Contactos->(DbAppend())
		Nuevo := .F.
	EndIf

	Contactos->Apellido	:= Win_1.Control_1.Value
	Contactos->Cod_Tipo	:= Tipos->Cod_Tipo
	Contactos->Nombres	:= Win_1.Control_3.Value
	Contactos->Calle	:= Win_1.Control_4.Value
	Contactos->Numero	:= Win_1.Control_5.Value
	Contactos->Piso		:= Win_1.Control_6.Value
	Contactos->Dpto		:= Win_1.Control_7.Value
	Contactos->Tel_Part	:= Win_1.Control_8.Value
	Contactos->Tel_Cel	:= Win_1.Control_9.Value
	Contactos->E_Mail	:= Win_1.Control_10.Value
	Contactos->Fecha_Nac	:= Win_1.Control_11.Value
	Contactos->Observ	:= Win_1.Control_12.Value

	Win_1.Browse_1.Refresh


	If Nuevo == .T.
		Win_1.Browse_1.Value := Contactos->(RecNo())
	EndIf

	UNLOCK

RETURN
*------------------------------------------------------------------------------*
PROCEDURE Nuevo()
*------------------------------------------------------------------------------*

	// Se asignan valores iniciales a los controles.

	Win_1.Control_1.Value := ''
	Win_1.Control_2.Value := 0
	Win_1.Control_3.Value := ''
	Win_1.Control_4.Value := ''
	Win_1.Control_5.Value := 0
	Win_1.Control_6.Value := 0
	Win_1.Control_7.Value := ''
	Win_1.Control_8.Value := ''
	Win_1.Control_9.Value := ''
	Win_1.Control_10.Value := ''
	Win_1.Control_11.Value := CtoD ('01/01/1960')
	Win_1.Control_12.Value := ''

	ActivarEdicion()

RETURN
*------------------------------------------------------------------------------*
PROCEDURE Actualizar()
*------------------------------------------------------------------------------*

	Tipos->( DbSeek ( Contactos->Cod_Tipo ) )

	Win_1.Control_1.Value	:= Contactos->Apellido
	Win_1.Control_2.Value	:= Tipos->(RecNo())
	Win_1.Control_3.Value	:= Contactos->Nombres
	Win_1.Control_4.Value	:= Contactos->Calle
	Win_1.Control_5.Value 	:= Contactos->Numero
	Win_1.Control_6.Value	:= Contactos->Piso
	Win_1.Control_7.Value 	:= Contactos->Dpto
	Win_1.Control_8.Value	:= Contactos->Tel_Part
	Win_1.Control_9.Value	:= Contactos->Tel_Cel
	Win_1.Control_10.Value	:= Contactos->E_Mail
	Win_1.Control_11.Value	:= Contactos->Fecha_Nac
	Win_1.Control_12.Value	:= Contactos->Observ

Return
*------------------------------------------------------------------------------*
Function BloquearRegistro()
*------------------------------------------------------------------------------*
Local RetVal

	If Contactos->(RLock())
		RetVal := .t.
	Else
		MsgExclamation ('El Registro Esta Siendo Editado Por Otro Usuario. Reintente Mas Tarde')
		RetVal := .f.
	EndIf

Return RetVal
*------------------------------------------------------------------------------*
Procedure Eliminar
*------------------------------------------------------------------------------*

	If MsgYesNo ( 'Esta Seguro')

		If BloquearRegistro()
			Contactos->(dbdelete())
			Contactos->(dbgotop())
			Win_1.Browse_1.Refresh
			Win_1.Browse_1.Value := Contactos->(RecNo())
			Actualizar()
		EndIf
	EndIf

Return
*------------------------------------------------------------------------------*
Procedure Buscar
*------------------------------------------------------------------------------*
Local Buscar

	Buscar := Upper ( AllTrim ( InputBox( 'Ingrese Apellido a Buscar:' , 'Busqueda' ) ) )

	If .Not. Empty(Buscar)

		If Contactos->(DbSeek(Buscar))
			Win_1.Browse_1.Value := Contactos->(RecNo())
		Else
			MsgExclamation('No se encontraron registros')
		EndIf

	EndIf

Return
*------------------------------------------------------------------------------*
Procedure Imprimir()
*------------------------------------------------------------------------------*
Local RecContactos , RecTipos

	RecContactos := Contactos->(RecNo())
	RecTipos := Tipos->(RecNo())

	Select Contactos
	Set Relation To Field->Cod_Tipo Into Tipos
	Go Top

	DO REPORT								;
		TITLE 'Contactos'						;
		HEADERS  {'','','','',''} , {'Apellido','Nombres','Calle','Numero','Tipo'};
		FIELDS   {'Contactos->Apellido','Contactos->Nombres','Contactos->Calle','Contactos->Numero','Tipos->Desc'};
		WIDTHS   {10,15,20,7,15} 						;
		TOTALS   {.F.,.F.,.F.,.F.,.F.}					;
		WORKAREA Contactos						;
		LPP 50								;
		CPL 80								;
		LMARGIN 5							;
		PREVIEW

	Select Contactos
	Set Relation To

	Contactos->(DbGoTo(RecContactos))
	Tipos->(DbGoTo(RecTipos))

Return

PROCEDURE AdministradorDeTipos

        Load Window Win_2
	Win_2.Text_1.SetFocus
	CENTER WINDOW Win_2
	ACTIVATE WINDOW Win_2

RETURN

*------------------------------------------------------------------------------*
FUNCTION Busqueda
*------------------------------------------------------------------------------*
Local RetVal := .F. , nRecCount := 0

	If Empty ( Win_2.Text_1.Value )
		Return .F.
	EndIf

	Win_2.Grid_1.DeleteAllItems

	Use Tipos Index Tipos Shared
	Set Order To Tag Desc

	If AllTrim (AllTrim(Win_2.Text_1.Value)) == '*'

		Go Top

		Do While .Not. Eof()
			nRecCount++
			Win_2.Grid_1.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
			Skip
		EndDo

		If nRecCount > 0
			RetVal := .T.
			Win_2.StatusBar.Item(1) := AllTrim(Str(nRecCount)) + ' Registros Encontrados'
		ELse
			RetVal := .F.
			Win_2.StatusBar.Item(1) := 'No se encontraron registros'
		EndIf

	Else

		If DbSeek(AllTrim(Win_2.Text_1.Value))

			RetVal := .T.

			Do While Upper(Tipos->Desc) = AllTrim(Win_2.Text_1.Value)
				nRecCount++
				Win_2.Grid_1.AddItem ( { Str(Tipos->Cod_Tipo) , Tipos->Desc } )
				Skip
			EndDo

			RetVal := .T.
			Win_2.StatusBar.Item(1) := AllTrim(Str(nRecCount)) + ' Registros Encontrados'

		Else
			Win_2.StatusBar.Item(1) := 'No se encontraron registros'
		EndIf

	EndIf

	Close Tipos

Return ( RetVal )
*------------------------------------------------------------------------------*
PROCEDURE Agregar
*------------------------------------------------------------------------------*
Local cDesc , nCod_Tipo

	cDesc := InputBox ( 'Descripcion:' , 'Agregar Registro' )

	If .Not. Empty ( cDesc )

		Use Tipos Index Tipos Shared
		Set Order To Tag Cod_Tipo

		If flock()

			Go Bottom

			nCod_Tipo := Tipos->Cod_Tipo + 1

			Append Blank

			Tipos->Cod_Tipo := nCod_Tipo
			Tipos->Desc	:= cDesc

			Close Tipos

			If ( Busqueda() == .T. , ( Win_2.Grid_1.Value := 1 , Win_2.Grid_1.SetFocus ) , Nil )

		Else

			MsgStop ('Operacion Cancelada: El Archivo esta siendo actualizado por otro usuario. Reintente mas tarde')

		EndIf

	EndIf

Return
*------------------------------------------------------------------------------*
PROCEDURE Borrar
*------------------------------------------------------------------------------*
Local ItemPos , aItem

	ItemPos := Win_2.Grid_1.Value

	If ItemPos == 0
		MsgStop ('No hay regostros seleccionados','Borrar Registro')
		Return
	EndIf

	If MsgYesNo ( 'Esta Seguro' , 'Borrar Registro' )

		Use Contactos Index Contactos Shared New
		Set Order To Tag Cod_Tipo

		Use Tipos Index Tipos Shared New
		Set Order To Tag Cod_Tipo

		aItem := Win_2.Grid_1.Item ( ItemPos )

		Seek Val ( aItem[1] )

		If found()
			If rlock()
				If Contactos->(DbSeek(Tipos->Cod_Tipo))
					Close Tipos
					Close Contactos
					MsgStop('Operacion cancelada: El registro esta asociado a uno o mas contactos. No puede eliminarse','Borrar registro')
				Else
					Delete
					Close Tipos
					Close Contactos
					If ( Busqueda() == .T. , ( Win_2.Grid_1.Value := 1 , Win_2.Grid_1.SetFocus ) , Nil )
				EndIf
			Else
				Close Tipos
				MsgStop('Operacion cancelada: El registro esta siendo editado por otro usuario. reintente mas tarde','Borrar registro')
			EndIf
		Else
			Close Tipos
			MsgStop('Operacion cancelada: El registro ha sido eliminado por otro usuario','Borrar registro')
		EndIf

	EndIf

Return
*------------------------------------------------------------------------------*
PROCEDURE Modificar
*------------------------------------------------------------------------------*
Local ItemPos , aItem , cDesc , nCodTipo , i

	ItemPos := Win_2.Grid_1.Value

	If ItemPos == 0
		MsgStop ('No hay regostros seleccionados','Editar Registro')
		Return
	EndIf

	Use Tipos Index Tipos Shared
	Set Order To Tag Cod_Tipo

	aItem := Win_2.Grid_1.Item ( ItemPos )

	If dBSeek ( Val ( aItem[1] ) )
		If rlock()
			cDesc := InputBox ( 'Descripcion:','Editar Registro', AllTrim(Tipos->Desc))

			If ! Empty ( cDesc )
				Tipos->Desc := cDesc
			EndIf

			nCodTipo := Tipos->Cod_Tipo

			Close Tipos

			If Busqueda()

				Win_2.Grid_1.Value := 1

				For i := 1 To Win_2.Grid_1.ItemCount

					aItem := Win_2.Grid_1.Item ( i )

					If Val ( aItem [1] ) == nCodTipo
						Win_2.Grid_1.Value := i
						Win_2.Grid_1.SetFocus
						Exit
					EndIf

				Next i

			EndIf
		Else
			Close Tipos
			MsgStop('Operacion cancelada: El registro esta siendo editado por otro usuario. reintente mas tarde','Editar Registro')
		EndIf
	Else
		Close Tipos
		MsgStop('Operacion cancelada: El registro ha sido eliminado por otro usuario','Editar Registro')
	EndIf

Return
*------------------------------------------------------------------------------*
Procedure Impresion()
*------------------------------------------------------------------------------*

	Use Tipos Index Tipos Shared New
	Set Order To Tag Cod_Tipo
	Go Top

	DO REPORT							;
		TITLE 'Tipos'						;
		HEADERS  {'',''} , {'Codigo','Descripcion'}		;
		FIELDS   {'Cod_Tipo','Desc'}				;
		WIDTHS   {20,20} 					;
		TOTALS   {.F.,.F.}					;
		WORKAREA Tipos						;
		LPP 50							;
		CPL 80							;
		LMARGIN 5						;
		PREVIEW

	Close Tipos

Return
