/*
 * Grid com MultiSelect
 * Author: CAS <cas_webnet@yahoo.com.br>
 * 14/Nov/2005  01:31am
*/

#include "minigui.ch"

Memvar aRows, a_image, a_cab, a_width

Function Main

Declare aRows[20][3], a_image[4], a_cab[3], a_width[3]

* Imagens para ficar mudando dentro da GRID
a_image[1] = 'BMP_CAS'    && 0
a_image[2] = 'BMP_OK'     && 1
a_image[3] = 'BMP_COR'    && 2
a_image[4] = 'BMP_NO'     && 3

*              IMG
aRows [01] := { 1 , 'Ayrton Senna'      , '???-????'}
aRows [02] := { 0 , 'Pele'              , '324-6432'}
aRows [03] := { 0 , 'Smart Max'         , '432-5892'}
aRows [04] := { 0 , 'Grillo Pepe'       , '894-2332'}
aRows [05] := { 0 , 'Kirk James'        , '346-9873'}
aRows [06] := { 0 , 'Barriga Carlos'    , '394-9654'}
aRows [07] := { 0 , 'Flanders Ned'      , '435-3211'}
aRows [08] := { 0 , 'Smith John'        , '123-1234'}
aRows [09] := { 0 , 'Pedemonti Flavio'  , '000-0000'}
aRows [10] := { 0 , 'Gomez Juan'        , '583-4832'}
aRows [11] := { 0 , 'Fernandez Raul'    , '321-4332'}
aRows [12] := { 0 , 'Borges Javier'     , '326-9430'}
aRows [13] := { 0 , 'Alvarez Alberto'   , '543-7898'}
aRows [14] := { 0 , 'Gonzalez Ambo'     , '437-8473'}
aRows [15] := { 0 , 'Batistuta Gol'     , '485-2843'}
aRows [16] := { 0 , 'Vinazzi Amigo'     , '394-5983'}
aRows [17] := { 0 , 'Pedemonti Flavio'  , '534-7984'}
aRows [18] := { 0 , 'Samarbide Armando' , '854-7873'}
aRows [19] := { 0 , 'Pradon Alejandra'  , '555-5555'}
aRows [20] := { 0 , 'Reyes Monica'      , '432-5836'}

a_cab[1] = '?'     ; a_width[1] = 22
a_cab[2] = 'Name'  ; a_width[2] = 220
a_cab[3] = 'Phone' ; a_width[3] = 220


DEFINE WINDOW Form_1 ;
	AT 0,0 WIDTH 640 HEIGHT 480 ;
	TITLE 'Grid MultiSelect - Press Delete    By CAS - cas_webnet@yahoo.com.br' MAIN NOMAXIMIZE NOSIZE

	DEFINE STATUSBAR 
		STATUSITEM "" action nil
	END STATUSBAR

	ON KEY DELETE ACTION cas_del()
	ON KEY RETURN ACTION NIL

	@ 2,0   BUTTON btn_cas1 caption 'Result' action cas_result() default
	@ 2,150 BUTTON btn_cas2 caption 'Limpa'  action cas_limpa("click")
	@ 2,300 BUTTON btn_cas3 caption 'Update' action form_1.grid_1.cell( 1 , 2 ) := 'cas_webnet@yahoo.com.br'
	@ 2,450 BUTTON btn_cas4 caption 'Exit'  action thiswindow.release

	@ 50,70 GRID Grid_1 ;
	WIDTH  484 ;
	HEIGHT 328 ;
	HEADERS a_cab ;
	WIDTHS a_width ;
	ITEMS aRows ;
	VALUE {1,3} ;
	IMAGE a_image ;
	TOOLTIP 'Grid CAS' ;
	ON DBLCLICK cas_click() ;
	ON CHANGE cas_change() MULTISELECT

END WINDOW

form_1.center ; form_1.activate

Return Nil

*.......................................................*

proc cas_limpa
local n_for, n_pos, a_result
local m_itemcount := form_1.grid_1.itemcount

if m_itemcount = 0
   return
endif

form_1.grid_1.DisableUpdate
for n_for=1 to m_itemcount
	if form_1.grid_1.cell( n_for , 1 ) # 0
		form_1.grid_1.cell( n_for , 1 ) := 0
	end
next
form_1.grid_1.EnableUpdate

if pcount()=1
	return
end

a_result := form_1.grid_1.value
if len( a_result ) = 0
	return
end

form_1.grid_1.DisableUpdate
for n_for=1 to len( a_result )
	n_pos := a_result[ n_for ]
	form_1.grid_1.cell( n_pos , 1 ) := 1
next
form_1.grid_1.EnableUpdate

return

*.......................................................*

proc cas_click
local x := ;
	'CellRowIndex  = ' + alltrim( str( This.CellRowIndex ) ) +chr(13)+;
	'CellColIndex  = ' + alltrim( str( This.CellColIndex ) ) +chr(13)+;
	'CellColRow    = ' + alltrim( str( This.CellRow ) )      +chr(13)+;
	'CellColCol    = ' + alltrim( str( This.CellCol ) )      +chr(13)+;
	'CellColWidth  = ' + alltrim( str( This.CellWidth ) )    +chr(13)+;
	'CellColHeight = ' + alltrim( str( This.CellHeight ) )   

Form_1.Grid_1.Cell( This.CellRowIndex , This.CellColIndex ) := 'cas_webnet@yahoo.com.br'

MsgInfo( x , 'This.Cellxxxxxx' )

return

*.......................................................*

func cas_change
local spc := space(3)
form_1.statusbar.item(1) := ;
	'Selected: ' + alltrim( str( len(this.value) ) ) +'/'+;
	alltrim( str( form_1.grid_1.ItemCount ) )

cas_limpa()

retu nil

*.......................................................*

proc cas_del
local m_go, a_grid, a_grid_value
local m_itemcount := form_1.grid_1.itemcount

if m_itemcount = 0
   return
endif

m_go = 0
a_grid_value := form_1.grid_1.value

do while .t.
	a_grid = form_1.grid_1.value
	if len( a_grid ) = 0
		exit
	end
	if m_go = 0
		m_go = a_grid[ 1 ]
	end
	Form_1.Grid_1.DeleteItem( a_grid[ 1 ] )
enddo

if len( a_grid_value ) = 1 .and. m_itemcount = a_grid_value[ 1 ]
	m_go = a_grid_value[ 1 ] - 1
end

form_1.grid_1.setfocus
form_1.grid_1.value := { m_go }

return

*.......................................................*

proc cas_result
local n_for, n_pos, x, a_result
local m_itemcount := form_1.grid_1.itemcount

if m_itemcount = 0
   return
endif

a_result := form_1.grid_1.value
if len( a_result ) = 0
	return
end

x := ''
for n_for=1 to len( a_result )
	n_pos := a_result[ n_for ]
	x += ;
	form_1.grid_1.header( 2 ) +'='+;
	form_1.grid_1.cell( n_pos , 2 ) +space(15)+;
	form_1.grid_1.header( 3 ) +'='+;
	form_1.grid_1.cell( n_pos , 3 ) + chr(13)
next

msginfo( x , 'Selected item(s): ' + alltrim( str( len( a_result ) ) ) )

return
