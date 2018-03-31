/*
  sistema     : superchef pizzaria
  programa    : motoboys/entregadores
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function motoboys_entregadores()

         dbselectarea('motoboys')
         ordsetfocus('nome')
         motoboys->(dbgotop())
   
         define window form_motoboys;
                at 000,000;
                width 800;
                height 605;
                title 'Motoboys ou Entregadores';
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
              			  action form_motoboys.release
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
                define grid grid_motoboys
                       parent form_motoboys
                       col 000
                       row 105
                       width 795
                       height 430
                       headers {'Código','Nome','Telefone fixo','Telefone celular'}
                       widths {080,400,140,140}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados(2)
                end grid
                end splitbox
                
                define label rodape_001
                       parent form_motoboys
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
                          of form_motoboys;
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
                       parent form_motoboys
                       col form_motoboys.width - 270
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

         form_motoboys.center
         form_motoboys.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados(parametro)

       local id
       local titulo     := ''
       local x_nome     := ''
       local x_fixo     := ''
       local x_celular  := ''
       local x_endereco := ''
       local x_numero   := ''
       local x_complem  := ''
       local x_bairro   := ''
       local x_cidade   := ''
       local x_uf       := 'PR'
       local x_cep      := ''
       local x_email    := ''
       local x_diaria   := 0

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := val(valor_coluna('grid_motoboys','form_motoboys',1))
          titulo := 'Alterar'
          dbselectarea('motoboys')
          motoboys->(ordsetfocus('codigo'))
          motoboys->(dbgotop())
          motoboys->(dbseek(id))
          if found()
             x_nome     := motoboys->nome
             x_fixo     := motoboys->fixo
             x_celular  := motoboys->celular
             x_endereco := motoboys->endereco
             x_numero   := motoboys->numero
             x_complem  := motoboys->complem
             x_bairro   := motoboys->bairro
             x_cidade   := motoboys->cidade
             x_uf       := motoboys->uf
             x_cep      := motoboys->cep
             x_email    := motoboys->email
             x_diaria   := motoboys->diaria
             motoboys->(ordsetfocus('nome'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             motoboys->(ordsetfocus('nome'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 585;
		        height 360;
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
                        maxlength 040;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 010,325 label lbl_002;
                        of form_dados;
                        value 'Telefone fixo';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,325 textbox tbox_002;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_fixo;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 010,455 label lbl_003;
                        of form_dados;
                        value 'Telefone celular';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,455 textbox tbox_003;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_celular;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,005 label lbl_004;
                        of form_dados;
                        value 'Endereço';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_004;
                        of form_dados;
                        height 027;
                        width 310;
                        value x_endereco;
                        maxlength 040;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,325 label lbl_005;
                        of form_dados;
                        value 'Número';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,325 textbox tbox_005;
                        of form_dados;
                        height 027;
                        width 060;
                        value x_numero;
                        maxlength 006;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,395 label lbl_006;
                        of form_dados;
                        value 'Complemento';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,395 textbox tbox_006;
                        of form_dados;
                        height 027;
                        width 180;
                        value x_complem;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,005 label lbl_007;
                        of form_dados;
                        value 'Bairro';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,005 textbox tbox_007;
                        of form_dados;
                        height 027;
                        width 180;
                        value x_bairro;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,195 label lbl_008;
                        of form_dados;
                        value 'Cidade';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,195 textbox tbox_008;
                        of form_dados;
                        height 027;
                        width 180;
                        value x_cidade;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,385 label lbl_009;
                        of form_dados;
                        value 'UF';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,385 textbox tbox_009;
                        of form_dados;
                        height 027;
                        width 040;
                        value x_uf;
                        maxlength 002;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,435 label lbl_010;
                        of form_dados;
                        value 'CEP';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,435 textbox tbox_010;
                        of form_dados;
                        height 027;
                        width 080;
                        value x_cep;
                        maxlength 008;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 160,005 label lbl_011;
                        of form_dados;
                        value 'e-mail';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 180,005 textbox tbox_011;
                        of form_dados;
                        height 027;
                        width 450;
                        value x_email;
                        maxlength 050;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        lowercase
              @ 210,005 label lbl_013;
                        of form_dados;
                        value 'Diária (R$)';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 230,005 getbox tbox_013;
                        of form_dados;
                        height 027;
                        width 140;
                        value x_diaria;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 9,999.99'

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

       local id := val(valor_coluna('grid_motoboys','form_motoboys',1))

       dbselectarea('motoboys')
       motoboys->(ordsetfocus('codigo'))
       motoboys->(dbgotop())
       motoboys->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          motoboys->(ordsetfocus('nome'))
          return(nil)
       else
          if msgyesno('Nome : '+alltrim(motoboys->nome),'Excluir')
             if lock_reg()
                motoboys->(dbdelete())
                motoboys->(dbunlock())
                motoboys->(dbgotop())
             endif
             motoboys->(ordsetfocus('nome'))
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

       dbselectarea('motoboys')
       motoboys->(ordsetfocus('nome'))
       motoboys->(dbgotop())

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             @ linha,010 PRINT strzero(motoboys->codigo,4) FONT 'courier new' SIZE 010
             @ linha,025 PRINT motoboys->nome FONT 'courier new' SIZE 010
             @ linha,100 PRINT motoboys->fixo FONT 'courier new' SIZE 010
             @ linha,130 PRINT motoboys->celular FONT 'courier new' SIZE 010
             @ linha,160 PRINT trans(motoboys->diaria,'@E 9,999.99') FONT 'courier new' SIZE 010
             
             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             motoboys->(dbskip())

       end

       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'RELAÇÃO DE MOTOBOYS ou ENTREGADORES' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001
       
       @ 035,010 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
       @ 035,025 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD
       @ 035,100 PRINT 'TEL.FIXO' FONT 'courier new' SIZE 010 BOLD
       @ 035,130 PRINT 'TEL.CELULAR' FONT 'courier new' SIZE 010 BOLD
       @ 035,160 PRINT 'DIÁRIA(R$)' FONT 'courier new' SIZE 010 BOLD
       
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

       if retorna
          msgalert('Preencha todos os campos','Atenção')
          return(nil)
       endif
       
       if parametro == 1
          while .T.
                dbselectarea('conta')
                conta->(dbgotop())
                if lock_reg()
                   codigo := conta->c_motent
                   replace c_motent with c_motent + 1
                   conta->(dbcommit())
                   conta->(dbunlock())
                   exit
                else
                   msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
                   loop
                endif
          end
          dbselectarea('motoboys')
          motoboys->(dbappend())
          motoboys->codigo   := codigo
          motoboys->nome     := form_dados.tbox_001.value
          motoboys->fixo     := form_dados.tbox_002.value
          motoboys->celular  := form_dados.tbox_003.value
          motoboys->endereco := form_dados.tbox_004.value
          motoboys->numero   := form_dados.tbox_005.value
          motoboys->complem  := form_dados.tbox_006.value
          motoboys->bairro   := form_dados.tbox_007.value
          motoboys->cidade   := form_dados.tbox_008.value
          motoboys->uf       := form_dados.tbox_009.value
          motoboys->cep      := form_dados.tbox_010.value
          motoboys->email    := form_dados.tbox_011.value
          motoboys->diaria   := form_dados.tbox_013.value
          motoboys->(dbcommit())
          motoboys->(dbgotop())
          form_dados.release
          atualizar()
       elseif parametro == 2
          dbselectarea('motoboys')
          if lock_reg()
             motoboys->nome     := form_dados.tbox_001.value
             motoboys->fixo     := form_dados.tbox_002.value
             motoboys->celular  := form_dados.tbox_003.value
             motoboys->endereco := form_dados.tbox_004.value
             motoboys->numero   := form_dados.tbox_005.value
             motoboys->complem  := form_dados.tbox_006.value
             motoboys->bairro   := form_dados.tbox_007.value
             motoboys->cidade   := form_dados.tbox_008.value
             motoboys->uf       := form_dados.tbox_009.value
             motoboys->cep      := form_dados.tbox_010.value
             motoboys->email    := form_dados.tbox_011.value
             motoboys->diaria   := form_dados.tbox_013.value
             motoboys->(dbcommit())
             motoboys->(dbunlock())
             motoboys->(dbgotop())
          endif
          form_dados.release
          atualizar()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function pesquisar()

       local cPesq        := alltrim(form_motoboys.tbox_pesquisa.value)
       local lGridFreeze  := .T.
       local nTamNomePesq := len(cPesq)

       dbselectarea('motoboys')
       motoboys->(ordsetfocus('nome'))
       motoboys->(dbseek(cPesq))

       if lGridFreeze
          form_motoboys.grid_motoboys.disableupdate
       endif

       delete item all from grid_motoboys of form_motoboys

       while .not. eof()
             if substr(field->nome,1,nTamNomePesq) == cPesq
                add item {str(motoboys->codigo),alltrim(motoboys->nome),alltrim(motoboys->fixo),alltrim(motoboys->celular)} to grid_motoboys of form_motoboys
             elseif substr(field->nome,1,nTamNomePesq) > cPesq
                exit
             endif
             motoboys->(dbskip())
       end

       if lGridFreeze
          form_motoboys.grid_motoboys.enableupdate
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar()

       delete item all from grid_motoboys of form_motoboys

       dbselectarea('motoboys')
       motoboys->(ordsetfocus('nome'))
       motoboys->(dbgotop())

       while .not. eof()
             add item {str(motoboys->codigo),alltrim(motoboys->nome),alltrim(motoboys->fixo),alltrim(motoboys->celular)} to grid_motoboys of form_motoboys
             motoboys->(dbskip())
       end

       return(nil)