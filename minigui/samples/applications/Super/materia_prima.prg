/*
  sistema     : superchef pizzaria
  programa    : matéria prima
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function materia_prima()

         dbselectarea('materia_prima')
         ordsetfocus('nome')
         materia_prima->(dbgotop())
   
         define window form_materia_prima;
                at 000,000;
                width 800;
                height 605;
                title 'Matéria Prima';
                icon path_imagens+'icone.ico';
                modal;
                nosize;
                on init pesquisar()

                * botões (toolbar)
	  		       define buttonex button_incluir
              	 		  picture path_imagens+'incluir.bmp'
              			  col 005
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F5 Incluir'
              			  action dados(1)
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_alterar
              	 		  picture path_imagens+'alterar.bmp'
              			  col 107
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F6 Alterar'
              			  action dados(2)
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_excluir
              	 		  picture path_imagens+'excluir.bmp'
              			  col 209
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F7 Excluir'
              			  action excluir()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_imprimir
              	 		  picture path_imagens+'imprimir.bmp'
              			  col 311
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F8 Imprimir'
              			  action relacao()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_atualizar
              	 		  picture path_imagens+'atualizar.bmp'
              			  col 413
              			  row 002
              			  width 100
              			  height 100
              			  caption 'Atualizar'
              			  action atualizar()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_fornecedores
              	 		  picture path_imagens+'fornecedores.bmp'
              			  col 515
              			  row 002
              			  width 100
              			  height 100
              			  caption 'Fornecedores'
              			  action fornecedores_mprima()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_sair
              	 		  picture path_imagens+'sair.bmp'
              			  col 617
              			  row 002
              			  width 100
              			  height 100
              			  caption 'ESC Voltar'
              			  action form_materia_prima.release
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex

                define splitbox
                define grid grid_materia_prima
                       parent form_materia_prima
                       col 000
                       row 105
                       width 795
                       height 430
                       headers {'Código','Nome','Unidade','Preço R$','Qtd.'}
                       widths {080,320,120,120,120}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados(2)
                end grid
                end splitbox
                
                define label rodape_001
                       parent form_materia_prima
                       col 005
                       row 545
                       value 'Digite sua pesquisa'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_001
                       transparent .T.
                end label
                @ 540,160 textbox tbox_pesquisa;
                          of form_materia_prima;
                          height 027;
                          width 300;
                          value '';
                          maxlength 040;
                          font 'verdana' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          uppercase;
                          on change pesquisar()
                define label rodape_002
                       parent form_materia_prima
                       col form_materia_prima.width - 270
                       row 545
                       value 'DUPLO CLIQUE : Alterar informação'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _verde_002
                       transparent .T.
                end label

                on key F5 action dados(1)
                on key F6 action dados(2)
                on key F7 action excluir()
                on key F8 action relacao()
                on key escape action thiswindow.release

         end window

         form_materia_prima.center
         form_materia_prima.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados(parametro)

       local id
       local titulo    := ''
       local x_nome    := ''
       local x_unidade := 0
       local x_preco   := 0
       local x_qtd     := 0

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := val(valor_coluna('grid_materia_prima','form_materia_prima',1))
          titulo := 'Alterar'
          dbselectarea('materia_prima')
          materia_prima->(ordsetfocus('codigo'))
          materia_prima->(dbgotop())
          materia_prima->(dbseek(id))
          if found()
             x_nome    := materia_prima->nome
             x_unidade := materia_prima->unidade
             x_preco   := materia_prima->preco
             x_qtd     := materia_prima->qtd
             materia_prima->(ordsetfocus('nome'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             materia_prima->(ordsetfocus('nome'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 325;
		        height 300;
              title (titulo);
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              * entrada de dados
              @ 010,005 label lbl_001;
                        of form_dados;
                        value 'Nome';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,005 textbox tbox_001;
                        of form_dados;
                        height 027;
                        width 310;
                        value x_nome;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,005 label lbl_002;
                        of form_dados;
                        value 'Unidade';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_002;
                        of form_dados;
                        height 027;
                        width 060;
                        value x_unidade;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric;
                        on enter procura_unidade('form_dados','tbox_002')
              @ 080,075 label lbl_nome_unidade;
                        of form_dados;
                        value '';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _azul_001;
                        transparent
              @ 110,005 label lbl_003;
                        of form_dados;
                        value 'Preço R$';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,005 getbox tbox_003;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_preco;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 999,999.99'
              @ 110,135 label lbl_004;
                        of form_dados;
                        value 'Quantidade';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,135 getbox tbox_004;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_qtd;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@R 99,999.999'

              * linha separadora
              define label linha_rodape
                     col 000
                     row form_dados.height-090
                     value ''
                     width form_dados.width
                     height 001
                     backcolor _preto_001
                     transparent .F.
              end label

              * botões
              define buttonex button_ok
                     picture path_imagens+'img_gravar.bmp'
                     col form_dados.width-225
                     row form_dados.height-085
                     width 120
                     height 050
                     caption 'Ok, gravar'
                     action gravar(parametro)
                     fontbold .T.
                     tooltip 'Confirmar as informações digitadas'
                     flat .F.
                     noxpstyle .T.
              end buttonex
              define buttonex button_cancela
                     picture path_imagens+'img_voltar.bmp'
                     col form_dados.width-100
                     row form_dados.height-085
                     width 090
                     height 050
                     caption 'Voltar'
                     action form_dados.release
                     fontbold .T.
                     tooltip 'Sair desta tela sem gravar informações'
                     flat .F.
                     noxpstyle .T.
              end buttonex

       end window

       sethandcursor(getcontrolhandle('button_ok','form_dados'))
       sethandcursor(getcontrolhandle('button_cancela','form_dados'))

       form_dados.center
       form_dados.activate

       return(nil)
*-------------------------------------------------------------------------------
static function excluir()

       local id := val(valor_coluna('grid_materia_prima','form_materia_prima',1))

       dbselectarea('materia_prima')
       materia_prima->(ordsetfocus('codigo'))
       materia_prima->(dbgotop())
       materia_prima->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          materia_prima->(ordsetfocus('nome'))
          return(nil)
       else
          if msgyesno('Nome : '+alltrim(materia_prima->nome),'Excluir')
             if lock_reg()
                materia_prima->(dbdelete())
                materia_prima->(dbunlock())
                materia_prima->(dbgotop())
             endif
             materia_prima->(ordsetfocus('nome'))
             atualizar()
          endif
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function relacao()
       
       local p_linha := 040
       local u_linha := 260
       local linha   := p_linha
       local pagina  := 1

       dbselectarea('materia_prima')
       materia_prima->(ordsetfocus('nome'))
       materia_prima->(dbgotop())

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             @ linha,030 PRINT strzero(materia_prima->codigo,4) FONT 'courier new' SIZE 010
             @ linha,045 PRINT materia_prima->nome FONT 'courier new' SIZE 010
             @ linha,120 PRINT acha_unidade(materia_prima->unidade) FONT 'courier new' SIZE 010
             @ linha,150 PRINT trans(materia_prima->preco,'@E 9,999.99') FONT 'courier new' SIZE 010
             @ linha,170 PRINT trans(materia_prima->qtd,'@R 99,999.999') FONT 'courier new' SIZE 010
             
             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             materia_prima->(dbskip())

       end

       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'RELAÇÃO DE MATÉRIA PRIMA' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001
       
       @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
       @ 035,045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
       @ 035,120 PRINT 'UNIDADE' FONT 'courier new' SIZE 010 BOLD
       @ 035,150 PRINT 'PREÇO R$' FONT 'courier new' SIZE 010 BOLD
       @ 035,180 PRINT 'QTD.' FONT 'courier new' SIZE 010 BOLD

       return(nil)
*-------------------------------------------------------------------------------
static function rodape()

       @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
       @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

       return(nil)
*-------------------------------------------------------------------------------
static function gravar(parametro)

       local codigo  := 0
       local retorna := .F.

       if empty(form_dados.tbox_001.value)
          retorna := .T.
       endif
       if empty(form_dados.tbox_002.value)
          retorna := .T.
       endif
       if empty(form_dados.tbox_003.value)
          retorna := .T.
       endif

       if retorna
          msgalert('Preencha todos os campos','Atenção')
          return(nil)
       endif
       
       if parametro == 1
          while .T.
                dbselectarea('conta')
                conta->(dbgotop())
                if lock_reg()
                   codigo := conta->c_mprima
                   replace c_mprima with c_mprima + 1
                   conta->(dbcommit())
                   conta->(dbunlock())
                   exit
                else
                   msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
                   loop
                endif
          end
          dbselectarea('materia_prima')
          *--------
          if l_demo
             if reccount() > _limite_registros
                msgstop('Limite de registros esgotado','Atenção')
                return(nil)
             endif
          endif
          *----
          materia_prima->(dbappend())
          materia_prima->codigo  := codigo
          materia_prima->nome    := form_dados.tbox_001.value
          materia_prima->unidade := form_dados.tbox_002.value
          materia_prima->preco   := form_dados.tbox_003.value
          materia_prima->qtd     := form_dados.tbox_004.value
          materia_prima->(dbcommit())
          materia_prima->(dbgotop())
          form_dados.release
          atualizar()
       elseif parametro == 2
          dbselectarea('materia_prima')
          if lock_reg()
             materia_prima->nome    := form_dados.tbox_001.value
             materia_prima->unidade := form_dados.tbox_002.value
             materia_prima->preco   := form_dados.tbox_003.value
             materia_prima->qtd     := form_dados.tbox_004.value
             materia_prima->(dbcommit())
             materia_prima->(dbunlock())
             materia_prima->(dbgotop())
          endif
          form_dados.release
          atualizar()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function pesquisar()

       local cPesq        := alltrim(form_materia_prima.tbox_pesquisa.value)
       local lGridFreeze  := .T.
       local nTamNomePesq := len(cPesq)

       dbselectarea('materia_prima')
       materia_prima->(ordsetfocus('nome'))
       materia_prima->(dbseek(cPesq))

       if lGridFreeze
          form_materia_prima.grid_materia_prima.disableupdate
       endif

       delete item all from grid_materia_prima of form_materia_prima

       while .not. eof()
             if substr(field->nome,1,nTamNomePesq) == cPesq
                add item {str(materia_prima->codigo),alltrim(materia_prima->nome),acha_unidade(materia_prima->unidade),trans(materia_prima->preco,'@E 999,999.99'),trans(materia_prima->qtd,'@R 99,999.999')} to grid_materia_prima of form_materia_prima
             elseif substr(field->nome,1,nTamNomePesq) > cPesq
                exit
             endif
             materia_prima->(dbskip())
       end

       if lGridFreeze
          form_materia_prima.grid_materia_prima.enableupdate
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar()

       delete item all from grid_materia_prima of form_materia_prima

       dbselectarea('materia_prima')
       materia_prima->(ordsetfocus('nome'))
       materia_prima->(dbgotop())

       while .not. eof()
             add item {str(materia_prima->codigo),alltrim(materia_prima->nome),acha_unidade(materia_prima->unidade),trans(materia_prima->preco,'@E 999,999.99'),trans(materia_prima->qtd,'@R 99,999.999')} to grid_materia_prima of form_materia_prima
             materia_prima->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function procura_unidade(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       dbselectarea('unidade_medida')
       unidade_medida->(ordsetfocus('codigo'))
       unidade_medida->(dbgotop())
       unidade_medida->(dbseek(nreg_02))
       if found()
          flag := .T.
       else
          creg := getcode_unidade(getproperty(cform,ctextbtn,'value'))
          dbselectarea('unidade_medida')
          unidade_medida->(ordsetfocus('codigo'))
          unidade_medida->(dbgotop())
          unidade_medida->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_dados','lbl_nome_unidade','value',unidade_medida->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_unidade(value)

       local creg := ''
       local nreg := 1

       dbselectarea('unidade_medida')
       unidade_medida->(ordsetfocus('nome'))
       unidade_medida->(dbgotop())

       define window form_pesquisa;
              at 000,000;
              width 490;
              height 500;
              title 'Pesquisa por nome';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define label label_pesquisa
                     col 005
                     row 440
                     value 'Buscar'
                     autosize .T.
                     fontname 'verdana'
                     fontsize 012
                     fontbold .T.
                     fontcolor _preto_001
                     transparent .T.
              end label
              define textbox txt_pesquisa
                     col 075
                     row 440
                     width 400
                     maxlength 040
                     onchange find_unidade()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 480
                     height 430
                     headers {'Código','Nome'}
                     widths {080,370}
                     workarea unidade_medida
                     fields {'unidade_medida->codigo','unidade_medida->nome'}
                     value nreg
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (creg:=unidade_medida->codigo,thiswindow.release)
              end browse

              on key escape action thiswindow.release

       end window

       form_pesquisa.browse_pesquisa.setfocus

       form_pesquisa.center
       form_pesquisa.activate

       return(creg)
*-------------------------------------------------------------------------------
static function find_unidade()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       unidade_medida->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif unidade_medida->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := unidade_medida->(recno())
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function fornecedores_mprima()

       local x_codigo_mprima := val(valor_coluna('grid_materia_prima','form_materia_prima',1))
       local x_nome_mprima   := valor_coluna('grid_materia_prima','form_materia_prima',2)

       if empty(x_nome_mprima)
          msgexclamation('Escolha uma matéria prima','Atenção')
          return(nil)
       endif

       define window form_fornecedor_mprima;
              at 000,000;
		        width 600;
		        height 500;
              title 'Fornecedores de : '+alltrim(x_nome_mprima);
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              * botões (toolbar)
	  		     define buttonex button_sair
    	 		         picture path_imagens+'sair.bmp'
              			col 005
              			row 002
              			width 100
              			height 100
              			caption 'ESC Voltar'
              			action form_fornecedor_mprima.release
              			fontname 'verdana'
              			fontsize 009
              			fontbold .T.
              			fontcolor _preto_001
              			vertical .T.
              			flat .T.
              			noxpstyle .T.
                     backcolor _branco_001
	           end buttonex

              define grid grid_fornecedor_mprima
                     parent form_fornecedor_mprima
                     col 005
                     row 104
                     width 585
                     height 360
                     headers {'Nome do fornecedor'}
                     widths {570}
                     fontname 'verdana'
                     fontsize 010
                     fontbold .F.
                     nolines .T.
                     backcolor _branco_001
                     fontcolor _preto_001
              end grid

              on key escape action thiswindow.release

       end window

       filtra_fornecedor(x_codigo_mprima)

       form_fornecedor_mprima.center
       form_fornecedor_mprima.activate

       return(nil)
*-------------------------------------------------------------------------------
static function filtra_fornecedor(parametro)

       local x_old_fornecedor := 0

       delete item all from grid_fornecedor_mprima of form_fornecedor_mprima

       dbselectarea('tcompra2')
       index on fornecedor to indcpa12 for mat_prima == parametro
       go top

       while .not. eof()
             x_old_fornecedor := fornecedor
             skip
             if fornecedor <> x_old_fornecedor
                add item {acha_fornecedor_2(x_old_fornecedor)} to grid_fornecedor_mprima of form_fornecedor_mprima
             endif
       end

       return(nil)