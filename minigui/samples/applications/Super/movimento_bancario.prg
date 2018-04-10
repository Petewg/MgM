/*
  sistema     : superchef pizzaria
  programa    : movimentação bancária
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function movimento_bancario()

         local a_001 := {}
         
         dbselectarea('bancos')
         bancos->(ordsetfocus('nome'))
         bancos->(dbgotop())
         while .not. eof()
               aadd(a_001,strzero(bancos->codigo,6)+' - '+bancos->nome)
               bancos->(dbskip())
         end

         define window form_movban;
                at 000,000;
                width 800;
                height 605;
                title 'Movimentação Bancária';
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
              			  action form_movban.release
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
                define grid grid_movban
                       parent form_movban
                       col 000
                       row 105
                       width 795
                       height 380
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

                define label rodape_000
                       parent form_movban
                       col 005
                       row 500
                       value 'Escolha o banco'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_001
                       transparent .T.
                end label
		          define comboboxex cbo_001
			              row	500
                       col	140
			              width 300
			              height 200
			              items a_001
			              value 1
                end comboboxex
                
                define label rodape_001
                       parent form_movban
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
                       parent form_movban
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
                          parent form_movban;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 540,280 datepicker dp_final;
                          parent form_movban;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 540,390 buttonex botao_filtrar;
                          parent form_movban;
                          caption 'Filtrar';
                          width 100 height 030;
                          action atualizar();
                          bold;
                          tooltip 'Clique aqui para mostrar as informações com base no período selecionado'

                define label rodape_003
                       parent form_movban
                       col form_movban.width - 270
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

         form_movban.center
         form_movban.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados(parametro)

       local id
       local titulo      := ''
       local x_banco     := 0
       local x_data      := date()
       local x_historico := ''
       local x_entrada   := 0
       local x_saida     := 0

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := valor_coluna('grid_movban','form_movban',1)
          titulo := 'Alterar'
          dbselectarea('movimento_bancario')
          movimento_bancario->(ordsetfocus('id'))
          movimento_bancario->(dbgotop())
          movimento_bancario->(dbseek(id))
          if found()
             x_banco     := movimento_bancario->banco
             x_data      := movimento_bancario->data
             x_historico := movimento_bancario->historico
             x_entrada   := movimento_bancario->entrada
             x_saida     := movimento_bancario->saida
             movimento_bancario->(ordsetfocus('nome'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             movimento_bancario->(ordsetfocus('data'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 325;
		        height 320;
              title (titulo);
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              * entrada de dados
              @ 010,005 label lbl_000;
                        of form_dados;
                        value 'Banco';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,005 textbox tbox_000;
                        of form_dados;
                        height 027;
                        width 060;
                        value x_banco;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric;
                        on enter procura_banco_2('form_dados','tbox_000')
              @ 030,070 label lbl_nome_banco;
                        of form_dados;
                        value '';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _azul_001;
                        transparent
              @ 060,005 label lbl_001;
                        of form_dados;
                        value 'Data';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_001;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_data;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        date
              @ 110,005 label lbl_002;
                        of form_dados;
                        value 'Histórico';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,005 textbox tbox_002;
                        of form_dados;
                        height 027;
                        width 310;
                        value x_historico;
                        maxlength 030;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 160,005 label lbl_003;
                        of form_dados;
                        value 'Entrada';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 180,005 getbox tbox_003;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_entrada;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 999,999.99'
              @ 160,140 label lbl_004;
                        of form_dados;
                        value 'Saída';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _vermelho_002;
                        transparent
              @ 180,140 getbox tbox_004;
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

       local id := valor_coluna('grid_movban','form_movban',1)

       dbselectarea('movimento_bancario')
       movimento_bancario->(ordsetfocus('id'))
       movimento_bancario->(dbgotop())
       movimento_bancario->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          movimento_bancario->(ordsetfocus('data'))
          return(nil)
       else
          if msgyesno('Histórico : '+alltrim(movimento_bancario->historico),'Excluir')
             if lock_reg()
                movimento_bancario->(dbdelete())
                movimento_bancario->(dbunlock())
                movimento_bancario->(dbgotop())
             endif
             movimento_bancario->(ordsetfocus('data'))
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
                dbselectarea('movimento_bancario')
                movimento_bancario->(ordsetfocus('id'))
                movimento_bancario->(dbgotop())
                movimento_bancario->(dbseek(x_id))
                if found()
                   x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
                   loop
                else
                   exit
                endif
          end
          dbselectarea('movimento_bancario')
          movimento_bancario->(dbappend())
          movimento_bancario->id        := x_id
          movimento_bancario->banco     := form_dados.tbox_000.value
          movimento_bancario->data      := form_dados.tbox_001.value
          movimento_bancario->historico := form_dados.tbox_002.value
          movimento_bancario->entrada   := form_dados.tbox_003.value
          movimento_bancario->saida     := form_dados.tbox_004.value
          movimento_bancario->(dbcommit())
          movimento_bancario->(dbgotop())
          form_dados.release
          atualizar()
       elseif parametro == 2
          dbselectarea('movimento_bancario')
          if lock_reg()
             movimento_bancario->banco     := form_dados.tbox_000.value
             movimento_bancario->data      := form_dados.tbox_001.value
             movimento_bancario->historico := form_dados.tbox_002.value
             movimento_bancario->entrada   := form_dados.tbox_003.value
             movimento_bancario->saida     := form_dados.tbox_004.value
             movimento_bancario->(dbcommit())
             movimento_bancario->(dbunlock())
             movimento_bancario->(dbgotop())
          endif
          form_dados.release
          atualizar()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar()

       local x_banco        := form_movban.cbo_001.value
       local x_codigo_banco := 0
       local x_data_001     := form_movban.dp_inicio.value
       local x_data_002     := form_movban.dp_final.value

       x_codigo_banco := val(substr(form_movban.cbo_001.item(x_banco),1,6))
       
       delete item all from grid_movban of form_movban

       dbselectarea('movimento_bancario')
       movimento_bancario->(ordsetfocus('composto'))
       movimento_bancario->(dbgotop())

	    ordscope(0,str(x_codigo_banco,4)+dtos(x_data_001))
	    ordscope(1,str(x_codigo_banco,4)+dtos(x_data_002))

       movimento_bancario->(dbgotop())

       while .not. eof()
             add item {movimento_bancario->id,dtoc(movimento_bancario->data),alltrim(movimento_bancario->historico),trans(movimento_bancario->entrada,'@E 999,999.99'),trans(movimento_bancario->saida,'@E 999,999.99')} to grid_movban of form_movban
             movimento_bancario->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function procura_banco_2(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       dbselectarea('bancos')
       bancos->(ordsetfocus('codigo'))
       bancos->(dbgotop())
       bancos->(dbseek(nreg_02))
       if found()
          flag := .T.
       else
          creg := getcode_banco_2(getproperty(cform,ctextbtn,'value'))
          dbselectarea('bancos')
          bancos->(ordsetfocus('codigo'))
          bancos->(dbgotop())
          bancos->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_dados','lbl_nome_banco','value',bancos->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_banco_2(value)

       local creg := ''
       local nreg := 1

       dbselectarea('bancos')
       bancos->(ordsetfocus('nome'))
       bancos->(dbgotop())

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
                     onchange find_banco_2()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 480
                     height 430
                     headers {'Código','Nome'}
                     widths {080,370}
                     workarea bancos
                     fields {'bancos->codigo','bancos->nome'}
                     value nreg
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (creg:=bancos->codigo,thiswindow.release)
              end browse

              on key escape action thiswindow.release

       end window

       form_pesquisa.browse_pesquisa.setfocus

       form_pesquisa.center
       form_pesquisa.activate

       return(creg)
*-------------------------------------------------------------------------------
static function find_banco_2()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       bancos->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif bancos->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := bancos->(recno())
       endif

       return(nil)