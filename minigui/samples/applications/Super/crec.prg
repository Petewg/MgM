/*
  sistema     : superchef pizzaria
  programa    : contas a receber
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function crec()

         define window form_crec;
                at 000,000;
                width 1000;
                height 680;
                title 'Contas a Receber';
                icon path_imagens+'icone.ico';
                modal;
                nosize

                * botões (toolbar)
                define buttonex button_incluir_2
   	 		           picture path_imagens+'incluir.bmp'
    			           col 005
    			           row 002
              	 		  width 100
              	 		  height 100
              	 		  caption 'F5 Incluir'
              	 		  action dados_crec(1)
              	 		  fontname 'verdana'
              	 		  fontsize 009
              	 		  fontbold .T.
              	 		  fontcolor _preto_001
              	 		  vertical .T.
              	 		  flat .T.
              	 		  noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex button_alterar_2
   	 		           picture path_imagens+'alterar.bmp'
              			  col 107
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F6 Alterar'
              			  action dados_crec(2)
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex button_excluir_2
   	 		           picture path_imagens+'excluir.bmp'
              			  col 209
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F7 Excluir'
              			  action excluir_crec()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex button_atualizar_2
   	 		           picture path_imagens+'atualizar.bmp'
              			  col 311
              			  row 002
              			  width 100
              			  height 100
              			  caption 'Atualizar'
              			  action atualizar_crec()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex button_sair_2
   	 		           picture path_imagens+'sair.bmp'
              			  col 413
              			  row 002
              			  width 100
              			  height 100
              			  caption 'ESC Voltar'
              			  action form_crec.release
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
                end buttonex

                define grid grid_crec
                       parent form_crec
                       col 005
                       row 105
                       width 980
                       height 500
                       headers {'id','Vencimento','Cliente','Forma Recebimento','Valor R$','Nº Documento','Observação'}
                       widths {001,120,300,200,120,120,200}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados_crec(2)
                end grid

                define label rodape_001_2
                       parent form_crec
                       col 005
                       row 615
                       value 'Escolha o período'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_001
                       transparent .T.
                end label
                define label rodape_002_2
                       parent form_crec
                       col 250
                       row 615
                       value 'até'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_001
                       transparent .T.
                end label
                @ 610,140 datepicker dp_inicio_2;
                          parent form_crec;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 610,280 datepicker dp_final_2;
                          parent form_crec;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 610,390 buttonex botao_filtrar_2;
                          parent form_crec;
                          caption 'Filtrar';
                          width 100 height 030;
                          action atualizar_crec();
                          bold;
                          tooltip 'Clique aqui para mostrar as informações com base no período selecionado'

                define label rodape_003_2
                       parent form_crec
                       col form_crec.width - 270
                       row 615
                       value 'DUPLO CLIQUE : Alterar informação'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _verde_002
                       transparent .T.
                end label

                on key escape action thiswindow.release

         end window

         form_crec.center
         form_crec.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados_crec(parametro)

       local id
       local titulo    := ''
       local x_cliente := 0
       local x_forma   := 0
       local x_data    := date()
       local x_valor   := 0
       local x_numero  := ''
       local x_obs     := ''

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := valor_coluna('grid_crec','form_crec',1)
          titulo := 'Alterar'
          dbselectarea('contas_receber')
          contas_receber->(ordsetfocus('id'))
          contas_receber->(dbgotop())
          contas_receber->(dbseek(id))
          if found()
             x_cliente := contas_receber->cliente
             x_forma   := contas_receber->forma
             x_data    := contas_receber->data
             x_valor   := contas_receber->valor
             x_numero  := contas_receber->numero
             x_obs     := contas_receber->obs
             contas_receber->(ordsetfocus('data'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             contas_receber->(ordsetfocus('data'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 430;
		        height 330;
              title (titulo);
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              * entrada de dados
              @ 010,005 label lbl_001;
                        of form_dados;
                        value 'Cliente';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,005 textbox tbox_001;
                        of form_dados;
                        height 027;
                        width 060;
                        value x_cliente;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric;
                        on enter procura_cliente('form_dados','tbox_001')
              @ 030,075 label lbl_nome_cliente;
                        of form_dados;
                        value '';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _azul_001;
                        transparent
              @ 060,005 label lbl_002;
                        of form_dados;
                        value 'Forma Recebimento';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_002;
                        of form_dados;
                        height 027;
                        width 060;
                        value x_forma;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric;
                        on enter procura_forma_recebimento('form_dados','tbox_002')
              @ 080,075 label lbl_nome_forma_recebimento;
                        of form_dados;
                        value '';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _azul_001;
                        transparent

              @ 110,005 label lbl_003;
                        of form_dados;
                        value 'Data';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 130,005 textbox tbox_003;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_data;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        date

              @ 110,140 label lbl_004;
                        of form_dados;
                        value 'Valor R$';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _vermelho_002;
                        transparent
              @ 130,140 getbox tbox_004;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_valor;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 999,999.99'

              @ 110,270 label lbl_005;
                        of form_dados;
                        value 'Número documento';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,270 textbox tbox_005;
                        of form_dados;
                        height 027;
                        width 150;
                        value x_numero;
                        maxlength 015;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase

              @ 160,005 label lbl_006;
                        of form_dados;
                        value 'Observação';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 180,005 textbox tbox_006;
                        of form_dados;
                        height 027;
                        width 200;
                        value x_obs;
                        maxlength 030;
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
                     action gravar_crec(parametro)
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
static function excluir_crec()

       local id := valor_coluna('grid_crec','form_crec',1)

       dbselectarea('contas_receber')
       contas_receber->(ordsetfocus('id'))
       contas_receber->(dbgotop())
       contas_receber->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          contas_receber->(ordsetfocus('data'))
          return(nil)
       else
          if msgyesno('Histórico : '+alltrim(contas_receber->numero),'Excluir')
             if lock_reg()
                contas_receber->(dbdelete())
                contas_receber->(dbunlock())
                contas_receber->(dbgotop())
             endif
             contas_receber->(ordsetfocus('data'))
             atualizar_crec()
          endif
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function gravar_crec(parametro)

       local x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)

       if parametro == 1
          while .T.
                dbselectarea('contas_receber')
                contas_receber->(ordsetfocus('id'))
                contas_receber->(dbgotop())
                contas_receber->(dbseek(x_id))
                if found()
                   x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
                   loop
                else
                   exit
                endif
          end
          dbselectarea('contas_receber')
          *--------
          if l_demo
             if reccount() > _limite_registros
                msgstop('Limite de registros esgotado','Atenção')
                return(nil)
             endif
          endif
          *----
          contas_receber->(dbappend())
          contas_receber->id      := x_id
          contas_receber->data    := form_dados.tbox_003.value
          contas_receber->valor   := form_dados.tbox_004.value
          contas_receber->forma   := form_dados.tbox_002.value
          contas_receber->cliente := form_dados.tbox_001.value
          contas_receber->numero  := form_dados.tbox_005.value
          contas_receber->obs     := form_dados.tbox_006.value
          contas_receber->(dbcommit())
          contas_receber->(dbgotop())
          form_dados.release
          atualizar_crec()
       elseif parametro == 2
          dbselectarea('contas_receber')
          if lock_reg()
             contas_receber->data    := form_dados.tbox_003.value
             contas_receber->valor   := form_dados.tbox_004.value
             contas_receber->forma   := form_dados.tbox_002.value
             contas_receber->cliente := form_dados.tbox_001.value
             contas_receber->numero  := form_dados.tbox_005.value
             contas_receber->obs     := form_dados.tbox_006.value
             contas_receber->(dbcommit())
             contas_receber->(dbunlock())
             contas_receber->(dbgotop())
          endif
          form_dados.release
          atualizar_crec()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar_crec()

       local x_data_001 := form_crec.dp_inicio_2.value
       local x_data_002 := form_crec.dp_final_2.value

       delete item all from grid_crec of form_crec

       dbselectarea('contas_receber')
       index on dtos(data) to ind001 for data >= x_data_001 .and. data <= x_data_002
       go top

       while .not. eof()
             add item {contas_receber->id,dtoc(contas_receber->data),acha_cliente(contas_receber->cliente),acha_forma_recebimento(contas_receber->forma),trans(contas_receber->valor,'@E 999,999.99'),alltrim(contas_receber->numero),alltrim(contas_receber->obs)} to grid_crec of form_crec
             contas_receber->(dbskip())
       end

       return(nil)
       
*-------------------------------------------------------------------------------
static function procura_cliente(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       dbselectarea('clientes')
       clientes->(ordsetfocus('codigo'))
       clientes->(dbgotop())
       clientes->(dbseek(nreg_02))
       if found()
          flag := .T.
       else
          creg := getcode_clientes(getproperty(cform,ctextbtn,'value'))
          dbselectarea('clientes')
          clientes->(ordsetfocus('codigo'))
          clientes->(dbgotop())
          clientes->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_dados','lbl_nome_cliente','value',clientes->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_clientes(value)

       local creg := ''
       local nreg := 1

       dbselectarea('clientes')
       clientes->(ordsetfocus('nome'))
       clientes->(dbgotop())

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
                     onchange find_clientes()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 480
                     height 430
                     headers {'Código','Nome'}
                     widths {080,370}
                     workarea clientes
                     fields {'clientes->codigo','clientes->nome'}
                     value nreg
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (creg:=clientes->codigo,thiswindow.release)
              end browse

              on key escape action thiswindow.release

       end window

       form_pesquisa.browse_pesquisa.setfocus

       form_pesquisa.center
       form_pesquisa.activate

       return(creg)
*-------------------------------------------------------------------------------
static function find_clientes()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       clientes->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif clientes->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := clientes->(recno())
       endif

       return(nil)

*-------------------------------------------------------------------------------
static function procura_forma_recebimento(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       dbselectarea('formas_recebimento')
       formas_recebimento->(ordsetfocus('codigo'))
       formas_recebimento->(dbgotop())
       formas_recebimento->(dbseek(nreg_02))
       if found()
          flag := .T.
       else
          creg := getcode_formas_recebimento(getproperty(cform,ctextbtn,'value'))
          dbselectarea('formas_recebimento')
          formas_recebimento->(ordsetfocus('codigo'))
          formas_recebimento->(dbgotop())
          formas_recebimento->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_dados','lbl_nome_forma_recebimento','value',formas_recebimento->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_formas_recebimento(value)

       local creg := ''
       local nreg := 1

       dbselectarea('formas_recebimento')
       formas_recebimento->(ordsetfocus('nome'))
       formas_recebimento->(dbgotop())

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
                     onchange find_formas_recebimento()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 480
                     height 430
                     headers {'Código','Nome'}
                     widths {080,370}
                     workarea formas_recebimento
                     fields {'formas_recebimento->codigo','formas_recebimento->nome'}
                     value nreg
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (creg:=formas_recebimento->codigo,thiswindow.release)
              end browse

              on key escape action thiswindow.release

       end window

       form_pesquisa.browse_pesquisa.setfocus

       form_pesquisa.center
       form_pesquisa.activate

       return(creg)
*-------------------------------------------------------------------------------
static function find_formas_recebimento()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       formas_recebimento->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif formas_recebimento->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := formas_recebimento->(recno())
       endif

       return(nil)