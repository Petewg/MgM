/*
  sistema     : superchef pizzaria
  programa    : movimentação do caixa
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function caixa()

         define window form_caixa;
                at 000,000;
                width 800;
                height 605;
                title 'Movimentação do Caixa';
                icon path_imagens+'icone.ico';
                modal;
                nosize

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
	  		       define buttonex button_atualizar
              	 		  picture path_imagens+'atualizar.bmp'
              			  col 311
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
              			  col 413
              			  row 002
              			  width 100
              			  height 100
              			  caption 'ESC Voltar'
              			  action form_caixa.release
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
                define grid grid_caixa
                       parent form_caixa
                       col 000
                       row 105
                       width 795
                       height 430
                       headers {'id','Data','Histórico','Entradas','Saídas'}
                       widths {001,120,400,120,120}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados(2)
                end grid
                end splitbox
                
                define label rodape_001
                       parent form_caixa
                       col 005
                       row 545
                       value 'Escolha o período'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_001
                       transparent .T.
                end label
                define label rodape_002
                       parent form_caixa
                       col 250
                       row 545
                       value 'até'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_001
                       transparent .T.
                end label
                @ 540,140 datepicker dp_inicio;
                          parent form_caixa;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 540,280 datepicker dp_final;
                          parent form_caixa;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 540,390 buttonex botao_filtrar;
                          parent form_caixa;
                          caption 'Filtrar';
                          width 100 height 030;
                          action atualizar();
                          bold;
                          tooltip 'Clique aqui para mostrar as informações com base no período selecionado'

                define label rodape_003
                       parent form_caixa
                       col form_caixa.width - 270
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
                on key escape action thiswindow.release

         end window

         form_caixa.center
         form_caixa.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados(parametro)

       local id
       local titulo      := ''
       local x_data      := date()
       local x_historico := ''
       local x_entrada   := 0
       local x_saida     := 0

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := valor_coluna('grid_caixa','form_caixa',1)
          titulo := 'Alterar'
          dbselectarea('caixa')
          caixa->(ordsetfocus('id'))
          caixa->(dbgotop())
          caixa->(dbseek(id))
          if found()
             x_data      := caixa->data
             x_historico := caixa->historico
             x_entrada   := caixa->entrada
             x_saida     := caixa->saida
             caixa->(ordsetfocus('nome'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             caixa->(ordsetfocus('data'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 325;
		        height 270;
              title (titulo);
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              * entrada de dados
              @ 010,005 label lbl_001;
                        of form_dados;
                        value 'Data';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,005 textbox tbox_001;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_data;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        date
              @ 060,005 label lbl_002;
                        of form_dados;
                        value 'Histórico';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_002;
                        of form_dados;
                        height 027;
                        width 310;
                        value x_historico;
                        maxlength 030;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,005 label lbl_003;
                        of form_dados;
                        value 'Entrada';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 130,005 getbox tbox_003;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_entrada;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 999,999.99'
              @ 110,140 label lbl_004;
                        of form_dados;
                        value 'Saída';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _vermelho_002;
                        transparent
              @ 130,140 getbox tbox_004;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_saida;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 999,999.99'

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

       local id := valor_coluna('grid_caixa','form_caixa',1)

       dbselectarea('caixa')
       caixa->(ordsetfocus('id'))
       caixa->(dbgotop())
       caixa->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          caixa->(ordsetfocus('data'))
          return(nil)
       else
          if msgyesno('Histórico : '+alltrim(caixa->historico),'Excluir')
             if lock_reg()
                caixa->(dbdelete())
                caixa->(dbunlock())
                caixa->(dbgotop())
             endif
             caixa->(ordsetfocus('data'))
             atualizar()
          endif
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function gravar(parametro)

       local x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
       
       if empty(form_dados.tbox_001.value)
          msginfo('Preencha a data','Atenção')
          return(nil)
       endif

       if empty(form_dados.tbox_002.value)
          msginfo('Preencha o histórico','Atenção')
          return(nil)
       endif

       if parametro == 1
          while .T.
                dbselectarea('caixa')
                caixa->(ordsetfocus('id'))
                caixa->(dbgotop())
                caixa->(dbseek(x_id))
                if found()
                   x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
                   loop
                else
                   exit
                endif
          end
          dbselectarea('caixa')
          caixa->(dbappend())
          caixa->id        := x_id
          caixa->data      := form_dados.tbox_001.value
          caixa->historico := form_dados.tbox_002.value
          caixa->entrada   := form_dados.tbox_003.value
          caixa->saida     := form_dados.tbox_004.value
          caixa->(dbcommit())
          caixa->(dbgotop())
          form_dados.release
          atualizar()
       elseif parametro == 2
          dbselectarea('caixa')
          if lock_reg()
             caixa->data      := form_dados.tbox_001.value
             caixa->historico := form_dados.tbox_002.value
             caixa->entrada   := form_dados.tbox_003.value
             caixa->saida     := form_dados.tbox_004.value
             caixa->(dbcommit())
             caixa->(dbunlock())
             caixa->(dbgotop())
          endif
          form_dados.release
          atualizar()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar()

       local x_data_001 := form_caixa.dp_inicio.value
       local x_data_002 := form_caixa.dp_final.value

       delete item all from grid_caixa of form_caixa

       dbselectarea('caixa')
       caixa->(ordsetfocus('data'))
       caixa->(dbgotop())

	    ordscope(0,dtos(x_data_001))
	    ordscope(1,dtos(x_data_002))

       caixa->(dbgotop())

       while .not. eof()
             add item {caixa->id,dtoc(caixa->data),alltrim(caixa->historico),trans(caixa->entrada,'@E 999,999.99'),trans(caixa->saida,'@E 999,999.99')} to grid_caixa of form_caixa
             caixa->(dbskip())
       end

       return(nil)