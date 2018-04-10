#include "MiniGUI.ch"

memvar m_ver, p_GetFile

proc main
local x_arq := 'config.dbf'

REQUEST DBFCDX
RDDSETDEFAULT( "DBFCDX" )

SET MULTIPLE OFF WARNING

if !file ( x_arq )
   DBCREATE( x_arq , { ;
   {"ROW"    , "N" , 9 , 3} ,;
   {"COL"    , "N" , 9 , 3} ,;
   {"WIDTH"  , "N" , 9 , 3} ,;
   {"HEIGHT" , "N" , 9 , 3} } )
end

x_arq := 'arq.dbf'

if !file ( x_arq )
   DBCREATE( x_arq , { ;
   {"NOME"   , "C" , 254 , 0} ,;
   {"IMAGEM" , "M" ,  10 , 0} } )
end

use &x_arq alias IMAGE new exclusive
index on field->nome tag image to image

public m_ver := GetStartupFolder() + '\_cas_ver.JPG', p_GetFile := ''

SET DATE BRITISH
SET CENTURY ON
SET DELETED ON

SET BROWSESYNC ON	

Define window Form_1 ;
	At 0, 0 Width 700 Height 500 ;
	on init f_init() ;
	on release f_release() ;
	nosysmenu ;
	Title 'IMAGE to DBF - by cas.soft@gmail.com' Main

	@ 01,1 button btn_read caption 'Importar' action f_importar()
	@ 30,1 button btn_save caption 'Exportar' action f_exportar()
	@ 60,1 button btn_dele caption 'Apagar'   action f_apagar()
	@ 90,1 button btn_sair caption 'Sair'     action thiswindow.release

	@ 1,120 image img_cas picture '' Width 300 Height 120 stretch

	@ 128,1 BROWSE Browse_1 ;
		WIDTH 690 ;
		HEIGHT 330 ;
		HEADERS { 'Arquivo'} ;
		WIDTHS { 668 } ;
		VALUE 1 ;
		WORKAREA IMAGE ;
		FIELDS { 'NOME' } ;
		ON CHANGE browse_1_change() ;
		LOCK ;
		EDIT INPLACE 

	Define context menu
		Item "Importar" Action f_importar()
		Item "Exportar" Action f_exportar()
		Item "Apagar"   Action f_apagar()
		Item "Sair"     Action thiswindow.release
	End Menu

	Define timer timer_1 ;
		interval 250 ;
		action ( setforegroundwindow( getformhandle('form_1') ),;
			form_1.browse_1.setfocus ) once

End Window

form_1.Center
form_1.Activate

Return

*..............................................................................................*

func f_init
local bkp_alias := alias()
local m_row
local m_col
local m_width
local m_height

sele 0
use config
if lastrec() # 0
	m_row := FIELD->ROW
	m_col := FIELD->COL
	m_width := FIELD->WIDTH
	m_height:= FIELD->HEIGHT
else
	m_row := 100
	m_col := 200
	m_width := 300
	m_height:= 400
end
use
sele &bkp_alias

Define window Form_2 ;
	At m_row, m_col Width m_width Height m_height ;
	title 'CAS' ;
	on init f_size() ;
	on maximize f_size() ;
	on size f_size() ;
	nosysmenu ON INTERACTIVECLOSE .f. child
	@ 0,0 image img_cas picture ''
End Window

form_1.browse_1.value := 1
browse_1_change()

form_2.activate

retu nil

*..............................................................................................*

func f_size

form_2.img_cas.width := form_2.width   - 8
form_2.img_cas.height := form_2.height - 8
form_2.img_cas.picture := m_ver

retu nil

*..............................................................................................*

func f_apagar

if empty( lastrec() )
	retu nil
end

repl NOME   with ''
repl IMAGEM with ''
dele
pack
go top

form_1.browse_1.value := recno()
form_1.browse_1.refresh

if empty(form_1.browse_1.value)
	form_1.img_cas.picture := ''
	form_1.img_cas.hide
	form_1.img_cas.show
	form_2.img_cas.picture := ''
	form_2.img_cas.hide
	form_2.img_cas.show
	form_2.title := ''
else
	browse_1_change()
end

retu nil

*..............................................................................................*

func f_exportar
local a_arqs := { ;
	{ "Image Files" , "*.JPG;*.BMP;*.GIF;*.ICO" } ,;
	{ "Arquivos JPG" , "*.JPG" } ,;
	{ "Arquivos BMP" , "*.BMP" } ,;
	{ "Arquivos GIF" , "*.GIF" } ,;
	{ "Arquivos ICO" , "*.ICO" } } ,;
	m_novo := alltrim( IMAGE->NOME ) , cFile

if empty( lastrec() )
	retu nil
end

cFile := Putfile( a_arqs ,;
	'Salvar Arquivo como...' , GetCurrentFolder() , .f. , m_novo )

if empty( cFile )
	retu nil
end

if file( cFile )
	MsgStop( "Arquivo já existe", "Erro", , .f. )
else
	MemoWrit( cFile , UnMaskBinData( FIELD->IMAGEM ) )
end

retu nil

*..............................................................................................*

func browse_1_change

MemoWrit( m_ver , UnMaskBinData( FIELD->IMAGEM ) )

form_1.img_cas.picture := m_ver
form_2.img_cas.picture := m_ver
form_2.title := trim(IMAGE->NOME)

retu nil

*.................................................................*

proc f_release

close all
erase &m_ver

if .not. file('config.dbf')
	return
end

use config
if lastrec() = 0
	append blank
end
repl ROW    with form_2.row
repl COL    with form_2.col
repl WIDTH  with form_2.width
repl HEIGHT with form_2.height

return

*.................................................................*

function MaskBinData( x )                && Não lembro quem fez

x := StrTran( x , chr(26) , '\\#26//' )
x := StrTran( x , chr(00) , '\\#00//' )

return x

*.................................................................*

function UnMaskBinData( x )              && Não lembro quem fez

x := StrTran( x , '\\#26//' , chr(26) )
x := StrTran( x , '\\#00//' , chr(00) )

return x

*.................................................................*

function f_importar
local varios := .t.   && selecionar varios arquivos
local arq_cas, i, n_for, File_cas, m_rat

p_GetFile := iif( empty( p_GetFile ) , GetMyDocumentsFolder() , p_GetFile )

arq_cas := GetFile ( { ;
	{'Image Files' , '*.JPG;*.BMP;*.GIF;*.ICO'} ,;
	{'JPG Files' , '*.JPG'} ,;
	{'BMP Files' , '*.BMP'}  } ,;
	'Open File(s)' , p_GetFile , varios , .t. )

if len( arq_cas ) = 0
	return nil
endif

for n_for := 1 to len( arq_cas )
	i = n_for + 1

	if n_for = len(arq_cas)  && esta consistencia foi feita pq o ultimo arquivo
		i = 1		 && é sempre o primeiro
	endif

	File_cas := strtran( arq_cas[ i ] , '\\' , '\' )

	append blank

	m_rat := rat( '\' , File_cas )
	if m_rat # 0
		repl NOME   with substr( File_cas , m_rat + 1 )
	else
		repl NOME   with File_cas
	end

	repl IMAGEM with MaskBinData( MemoRead( File_cas ) )

next

m_rat = rat('\',arq_cas[1])
p_GetFile := left( arq_cas[1] , m_rat-1 )

form_1.browse_1.value := recno()
form_1.browse_1.refresh

return nil
