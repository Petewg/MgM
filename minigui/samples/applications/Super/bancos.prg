/*
  sistema     : superchef pizzaria
  programa    : contas bancárias
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function contas_bancarias()

         dbselectarea('bancos')
         ordsetfocus('nome')
         bancos->(dbgotop())
   
         define window form_bancos;
                at 000,000;
                width 800;
                height 605;
                title 'Contas Bancárias';
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
	  		       define buttonex button_sair
              	 		  picture path_imagens+'sair.bmp'
              			  col 515
              			  row 002
              			  width 100
              			  height 100
              			  caption 'ESC Voltar'
              			  action form_bancos.release
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
                define grid grid_bancos
                       parent form_bancos
                       col 000
                       row 105
                       width 795
                       height 430
                       headers {'Código','Nome','Banco','Agência','Conta'}
                       widths {100,250,150,150,100}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados(2)
                end grid
                end splitbox
                
                define label rodape_001
                       parent form_bancos
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
                          of form_bancos;
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
                       parent form_bancos
                       col form_bancos.width - 270
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

         form_bancos.center
         form_bancos.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados(parametro)

       local id
       local titulo     := ''
       local x_nome     := ''
       local x_banco    := ''
       local x_agencia  := ''
       local x_conta    := ''
       local x_limite   := 0
       local x_titular  := ''
       local x_gerente  := ''
       local x_telefone := ''

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := val(valor_coluna('grid_bancos','form_bancos',1))
          titulo := 'Alterar'
          dbselectarea('bancos')
          bancos->(ordsetfocus('codigo'))
          bancos->(dbgotop())
          bancos->(dbseek(id))
          if found()
             x_nome     := bancos->nome
             x_banco    := bancos->banco
             x_agencia  := bancos->agencia
             x_conta    := bancos->conta_c
             x_limite   := bancos->limite
             x_titular  := bancos->titular
             x_gerente  := bancos->gerente
             x_telefone := bancos->telefone
             bancos->(ordsetfocus('nome'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             bancos->(ordsetfocus('nome'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 325;
		        height 420;
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
                        value 'Banco';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_002;
                        of form_dados;
                        height 027;
                        width 140;
                        value x_banco;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,155 label lbl_003;
                        of form_dados;
                        value 'Agência';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,155 textbox tbox_003;
                        of form_dados;
                        height 027;
                        width 140;
                        value x_agencia;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,005 label lbl_004;
                        of form_dados;
                        value 'Nº conta';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,005 textbox tbox_004;
                        of form_dados;
                        height 027;
                        width 140;
                        value x_conta;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,155 label lbl_005;
                        of form_dados;
                        value 'Limite R$';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,155 getbox tbox_005;
                        of form_dados;
                        height 027;
                        width 140;
                        value x_limite;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 999,999.99'
              @ 160,005 label lbl_006;
                        of form_dados;
                        value 'Titular da conta';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 180,005 textbox tbox_006;
                        of form_dados;
                        height 027;
                        width 310;
                        value x_titular;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 210,005 label lbl_007;
                        of form_dados;
                        value 'Gerente da conta';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 230,005 textbox tbox_007;
                        of form_dados;
                        height 027;
                        width 310;
                        value x_gerente;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 260,005 label lbl_008;
                        of form_dados;
                        value 'Telefone';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 280,005 textbox tbox_008;
                        of form_dados;
                        height 027;
                        width 140;
                        value x_telefone;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase

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

       local id := val(valor_coluna('grid_bancos','form_bancos',1))

       dbselectarea('bancos')
       bancos->(ordsetfocus('codigo'))
       bancos->(dbgotop())
       bancos->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          bancos->(ordsetfocus('nome'))
          return(nil)
       else
          if msgyesno('Nome : '+alltrim(bancos->nome),'Excluir')
             if lock_reg()
                bancos->(dbdelete())
                bancos->(dbunlock())
                bancos->(dbgotop())
             endif
             bancos->(ordsetfocus('nome'))
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

       dbselectarea('bancos')
       bancos->(ordsetfocus('nome'))
       bancos->(dbgotop())

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             @ linha,020 PRINT strzero(bancos->codigo,4) FONT 'courier new' SIZE 010
             @ linha,035 PRINT bancos->nome FONT 'courier new' SIZE 010
             @ linha,080 PRINT bancos->banco FONT 'courier new' SIZE 010
             @ linha,120 PRINT bancos->agencia FONT 'courier new' SIZE 010
             @ linha,160 PRINT bancos->conta_c FONT 'courier new' SIZE 010
             
             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             bancos->(dbskip())

       end

       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'RELAÇÃO DE CONTAS BANCÁRIAS' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

       @ 035,020 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
       @ 035,035 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
       @ 035,080 PRINT 'BANCO' FONT 'courier new' SIZE 010 BOLD
       @ 035,120 PRINT 'AGÊNCIA' FONT 'courier new' SIZE 010 BOLD
       @ 035,160 PRINT 'Nº CONTA' FONT 'courier new' SIZE 010 BOLD

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
       if empty(form_dados.tbox_004.value)
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
                   codigo := conta->c_bancos
                   replace c_bancos with c_bancos + 1
                   conta->(dbcommit())
                   conta->(dbunlock())
                   exit
                else
                   msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
                   loop
                endif
          end
          dbselectarea('bancos')
          bancos->(dbappend())
          bancos->codigo   := codigo
          bancos->nome     := form_dados.tbox_001.value
          bancos->banco    := form_dados.tbox_002.value
          bancos->agencia  := form_dados.tbox_003.value
          bancos->conta_c  := form_dados.tbox_004.value
          bancos->limite   := form_dados.tbox_005.value
          bancos->titular  := form_dados.tbox_006.value
          bancos->gerente  := form_dados.tbox_007.value
          bancos->telefone := form_dados.tbox_008.value
          bancos->(dbcommit())
          bancos->(dbgotop())
          form_dados.release
          atualizar()
       elseif parametro == 2
          dbselectarea('bancos')
          if lock_reg()
             bancos->nome     := form_dados.tbox_001.value
             bancos->banco    := form_dados.tbox_002.value
             bancos->agencia  := form_dados.tbox_003.value
             bancos->conta_c  := form_dados.tbox_004.value
             bancos->limite   := form_dados.tbox_005.value
             bancos->titular  := form_dados.tbox_006.value
             bancos->gerente  := form_dados.tbox_007.value
             bancos->telefone := form_dados.tbox_008.value
             bancos->(dbcommit())
             bancos->(dbunlock())
             bancos->(dbgotop())
          endif
          form_dados.release
          atualizar()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function pesquisar()

       local cPesq        := alltrim(form_bancos.tbox_pesquisa.value)
       local lGridFreeze  := .T.
       local nTamNomePesq := len(cPesq)

       dbselectarea('bancos')
       bancos->(ordsetfocus('nome'))
       bancos->(dbseek(cPesq))

       if lGridFreeze
          form_bancos.grid_bancos.disableupdate
       endif

       delete item all from grid_bancos of form_bancos

       while .not. eof()
             if substr(field->nome,1,nTamNomePesq) == cPesq
                add item {str(bancos->codigo),alltrim(bancos->nome),alltrim(bancos->banco),alltrim(bancos->agencia),alltrim(bancos->conta_c)} to grid_bancos of form_bancos
             elseif substr(field->nome,1,nTamNomePesq) > cPesq
                exit
             endif
             bancos->(dbskip())
       end

       if lGridFreeze
          form_bancos.grid_bancos.enableupdate
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar()

       delete item all from grid_bancos of form_bancos

       dbselectarea('bancos')
       bancos->(ordsetfocus('nome'))
       bancos->(dbgotop())

       while .not. eof()
             add item {str(bancos->codigo),alltrim(bancos->nome),alltrim(bancos->banco),alltrim(bancos->agencia),alltrim(bancos->conta_c)} to grid_bancos of form_bancos
             bancos->(dbskip())
       end

       return(nil)