/*
  sistema     : superchef pizzaria
  programa    : atendentes da pizzaria
  compilador  : xharbour 1.2 simplex
  lib gr�fica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function atendentes()

         dbselectarea('atendentes')
         ordsetfocus('nome')
         atendentes->(dbgotop())
   
         define window form_atendentes;
                at 000,000;
                width 800;
                height 605;
                title 'Atendentes ou Gar�ons';
                icon path_imagens+'icone.ico';
                modal;
                nosize;
                on init pesquisar()

                * bot�es (toolbar)
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
              			  action form_atendentes.release
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
                define grid grid_atendentes
                       parent form_atendentes
                       col 000
                       row 105
                       width 795
                       height 430
                       headers {'C�digo','Nome','Comiss�o (%)'}
                       widths {100,500,150}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados(2)
                end grid
                end splitbox
                
                define label rodape_001
                       parent form_atendentes
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
                          of form_atendentes;
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
                       parent form_atendentes
                       col form_atendentes.width - 270
                       row 545
                       value 'DUPLO CLIQUE : Alterar informa��o'
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

         form_atendentes.center
         form_atendentes.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados(parametro)

       local id
       local titulo     := ''
       local x_nome     := ''
       local x_comissao := 0

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := val(valor_coluna('grid_atendentes','form_atendentes',1))
          titulo := 'Alterar'
          dbselectarea('atendentes')
          atendentes->(ordsetfocus('codigo'))
          atendentes->(dbgotop())
          atendentes->(dbseek(id))
          if found()
             x_nome     := atendentes->nome
             x_comissao := atendentes->comissao
             atendentes->(ordsetfocus('nome'))
          else
             msgexclamation('Selecione uma informa��o','Aten��o')
             atendentes->(ordsetfocus('nome'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 325;
		        height 220;
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
                        value 'Comiss�o (%)';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 getbox tbox_002;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_comissao;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@R 999.99'

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

              * bot�es
              define buttonex button_ok
                     picture path_imagens+'img_gravar.bmp'
                     col form_dados.width-225
                     row form_dados.height-085
                     width 120
                     height 050
                     caption 'Ok, gravar'
                     action gravar(parametro)
                     fontbold .T.
                     tooltip 'Confirmar as informa��es digitadas'
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
                     tooltip 'Sair desta tela sem gravar informa��es'
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

       local id := val(valor_coluna('grid_atendentes','form_atendentes',1))

       dbselectarea('atendentes')
       atendentes->(ordsetfocus('codigo'))
       atendentes->(dbgotop())
       atendentes->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informa��o','Aten��o')
          atendentes->(ordsetfocus('nome'))
          return(nil)
       else
          if msgyesno('Nome : '+alltrim(atendentes->nome),'Excluir')
             if lock_reg()
                atendentes->(dbdelete())
                atendentes->(dbunlock())
                atendentes->(dbgotop())
             endif
             atendentes->(ordsetfocus('nome'))
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

       dbselectarea('atendentes')
       atendentes->(ordsetfocus('nome'))
       atendentes->(dbgotop())

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impress�o'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             @ linha,030 PRINT strzero(atendentes->codigo,4) FONT 'courier new' SIZE 010
             @ linha,045 PRINT atendentes->nome FONT 'courier new' SIZE 010
             @ linha,090 PRINT trans(atendentes->comissao,'@R 999.99') FONT 'courier new' SIZE 010

             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             atendentes->(dbskip())

       end

       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'RELA��O DE ATENDENTES/GAR�ONS' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT 'ordem alfab�tica' FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'p�gina : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001
       
       @ 035,030 PRINT 'C�DIGO' FONT 'courier new' SIZE 010 BOLD
       @ 035,045 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
       @ 035,090 PRINT 'COMISS�O (%)' FONT 'courier new' SIZE 010 BOLD
       
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

       if retorna
          msgalert('Preencha todos os campos','Aten��o')
          return(nil)
       endif
       
       if parametro == 1
          while .T.
                dbselectarea('conta')
                conta->(dbgotop())
                if lock_reg()
                   codigo := conta->c_atende
                   replace c_atende with c_atende + 1
                   conta->(dbcommit())
                   conta->(dbunlock())
                   exit
                else
                   msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Aten��o')
                   loop
                endif
          end
          dbselectarea('atendentes')
          atendentes->(dbappend())
          atendentes->codigo   := codigo
          atendentes->nome     := form_dados.tbox_001.value
          atendentes->comissao := form_dados.tbox_002.value
          atendentes->(dbcommit())
          atendentes->(dbgotop())
          form_dados.release
          atualizar()
       elseif parametro == 2
          dbselectarea('atendentes')
          if lock_reg()
             atendentes->nome     := form_dados.tbox_001.value
             atendentes->comissao := form_dados.tbox_002.value
             atendentes->(dbcommit())
             atendentes->(dbunlock())
             atendentes->(dbgotop())
          endif
          form_dados.release
          atualizar()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function pesquisar()

       local cPesq        := alltrim(form_atendentes.tbox_pesquisa.value)
       local lGridFreeze  := .T.
       local nTamNomePesq := len(cPesq)

       dbselectarea('atendentes')
       atendentes->(ordsetfocus('nome'))
       atendentes->(dbseek(cPesq))

       if lGridFreeze
          form_atendentes.grid_atendentes.disableupdate
       endif

       delete item all from grid_atendentes of form_atendentes

       while .not. eof()
             if substr(field->nome,1,nTamNomePesq) == cPesq
                add item {str(atendentes->codigo),alltrim(atendentes->nome),trans(atendentes->comissao,'@R 999.99')} to grid_atendentes of form_atendentes
             elseif substr(field->nome,1,nTamNomePesq) > cPesq
                exit
             endif
             atendentes->(dbskip())
       end

       if lGridFreeze
          form_atendentes.grid_atendentes.enableupdate
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar()

       delete item all from grid_atendentes of form_atendentes

       dbselectarea('atendentes')
       atendentes->(ordsetfocus('nome'))
       atendentes->(dbgotop())

       while .not. eof()
             add item {str(atendentes->codigo),alltrim(atendentes->nome),trans(atendentes->comissao,'@R 999.99')} to grid_atendentes of form_atendentes
             atendentes->(dbskip())
       end

       return(nil)