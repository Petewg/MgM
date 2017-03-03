#include 'minigui.ch'
static oConexion
*--------------------------------------------------------------------------------
procedure inicio
	Set navigation extended
	
	oConexion = todbc():new('DBQ=bd1.mdb;Driver={Microsoft Access Driver (*.mdb)}')
	oConexion:Open()
	
	define window form1;
			at 0,0 width 400 height 400 title 'Demo Odbc/Access';
			Main;
			on init ( ajustar(), cargar_datos(1) );
			on maximize ( ajustar() );
			on size ( ajustar() );
			on release ( oConexion:Destroy() );
			font 'ms sans serif' size 8

		@ 0,  0 button btn1 caption '&Agregar' 	width 80 height 20 action eventos(1)
		@ 0, 80 button btn2 caption '&Editar' 	width 80 height 20 action eventos(2)
		@ 0,160 button btn3 caption '&Borrar' 	width 80 height 20 action eventos(3)
		@ 0,240 button btn4 caption '&Salir' 	width 80 height 20 action form1.release

		define grid grid1
			row 22
			col 5
			width 300
			height 300
			headers {'Id','Descripcion'}
			widths { 60, 300 }
			on dblclick 	eventos(2)
			on change 	form1.statusbar.item(1) := "Registro "+;
						ltrim(str(form1.grid1.value))+" de "+alltrim(str(form1.grid1.itemcount))
			columncontrols	{ ;
					{'TEXTBOX','NUMERIC',repl('9',10)} , ;
					{'TEXTBOX','CHARACTER'} ;
					}
		end grid
		
		define statusbar
			statusitem "Registro "
			date
		end statusbar
	end window
	form1.center
	activate window form1
	
return
*--------------------------------------------------------------------------------
procedure cargar_datos(n)
	local i := 1
	form1.grid1.Deleteallitems

	oConexion:Setsql('SELECT * FROM Sucursal')

	if !oConexion:Open()
		msgstop('No se pudo conectar la base de datos')
	else
		for i= 1 to len( oConexion:aRecordset )
			form1.grid1.additem( oConexion:aRecordset[i] )
		next		
		form1.grid1.value := n
	end
	
	oConexion:Close()
	form1.grid1.setfocus
	
return
*--------------------------------------------------------------------------------
procedure eventos(n)
	local cNombre := "", Cad := ""
	do case
	case n == 1 .or. n == 2
		if n = 2
			cNombre := form1.grid1.cell( form1.grid1.value, 2 )
		end
		define window form1a;
			at 0,0 width 350 height 120;
			title iif(n = 2,'Edicion','Agregar');
			modal;
			font 'ms sans serif' size 8
			
			@ 10, 10 label label1 width 80 height 20 value 'Nombre sucursal'
			@ 10,100 textbox text1 width 200 height 20 value cNombre
			@ 40,170 button button1 caption '&Aceptar' action grabar_datos( n ) width 80 height 20 
			@ 40,250 button button2 caption '&Cerrar' action form1a.release width 80 height 20 

                        on key escape action form1a.button2.onclick
		end window
		form1a.center
		activate window form1a
			
	case n == 3
		Cad := "DELETE FROM Sucursal WHERE id="+str(form1.grid1.cell(form1.grid1.value,1))
		if msgyesno('Desea eliminar este registro '+hb_osnewline()+form1.grid1.cell(form1.grid1.value,2),'Confirmar')
			oConexion:Setsql( Cad )
			if !oConexion:Open()
				msgstop('No se pudo eliminar el registro')
			else
				n := form1.grid1.value
				form1.grid1.deleteitem( n )
				form1.grid1.value := iif(n > 1, n-1, 1)
				form1.statusbar.item(1) := "Registro "+;
					ltrim(str(form1.grid1.value))+" de "+alltrim(str(form1.grid1.itemcount))
			end
			oConexion:Close()
			form1.grid1.setfocus
		end
	endcase
return
*--------------------------------------------------------------------------------
procedure grabar_datos(n)
	local cad := ""
	if n = 1
		Cad := "INSERT INTO sucursal (nombre) VALUES ('"+form1a.text1.value+"')" 
	else
		Cad := "UPDATE sucursal SET nombre='"+form1a.text1.value+;
		 	  "' WHERE id="+str(form1.grid1.cell(form1.grid1.value,1))
	end
	oConexion:Setsql( Cad )
	if !oConexion:Open()
		msgstop('No se pudo actualizar la tabla Sucursal')
	end
	oConexion:Close()
	if n == 1
		cargar_datos( form1.grid1.itemcount+1 )
	else
		form1.grid1.cell( form1.grid1.value, 2 ) := form1a.text1.value
	end
	form1.statusbar.item(1) := "Registro "+;
		ltrim(str(form1.grid1.value))+" de "+alltrim(str(form1.grid1.itemcount))
	form1a.release
	
return		
*--------------------------------------------------------------------------------
procedure ajustar()
	form1.grid1.width := form1.width - 20
	form1.grid1.height:= ( form1.height- form1.grid1.row ) - 60
return
