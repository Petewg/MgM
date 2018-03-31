/*
  sistema     : superchef pizzaria
  programa    : contas a pagar
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function cpag()

         define window form_cpag;
                at 000,000;
                width 1000;
                height 680;
                title 'Contas a Pagar';
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
              	 		  action dados_cpag(1)
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
              			  action dados_cpag(2)
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
              			  action excluir_cpag()
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
              			  action atualizar_cpag()
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
              	 		  action form_cpag.release
              	 		  fontname 'verdana'
              	 		  fontsize 009
              	 		  fontbold .T.
              	 		  fontcolor _preto_001
              	 		  vertical .T.
              	 		  flat .T.
              	 		  noxpstyle .T.
                       backcolor _branco_001
                end buttonex

                define grid grid_cpag
                       parent form_cpag
                       col 005
                       row 105
                       width 980
                       height 500
                       headers {'id','Vencimento','Fornecedor','Forma Pagamento','Valor R$','Nº Documento','Observação'}
                       widths {001,120,300,200,120,120,200}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados_cpag(2)
                end grid

                define label rodape_001
                       parent form_cpag
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
                define label rodape_002
                       parent form_cpag
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
                @ 610,140 datepicker dp_inicio;
                          parent form_cpag;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 610,280 datepicker dp_final;
                          parent form_cpag;
                          value date();
                          width 100;
                          font 'verdana' size 010
                @ 610,390 buttonex botao_filtrar;
                          parent form_cpag;
                          caption 'Filtrar';
                          width 100 height 030;
                          action atualizar_cpag();
                          bold;
                          tooltip 'Clique aqui para mostrar as informações com base no período selecionado'

                define label rodape_003
                       parent form_cpag
                       col form_cpag.width - 270
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

         form_cpag.center
         form_cpag.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados_cpag(parametro)

       local id
       local titulo       := ''
       local x_fornecedor := 0
       local x_forma      := 0
       local x_data       := date()
       local x_valor      := 0
       local x_numero     := ''
       local x_obs        := ''
       
       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := valor_coluna('grid_cpag','form_cpag',1)
          titulo := 'Alterar'
          dbselectarea('contas_pagar')
          contas_pagar->(ordsetfocus('id'))
          contas_pagar->(dbgotop())
          contas_pagar->(dbseek(id))
          if found()
             x_fornecedor := contas_pagar->fornec
             x_forma      := contas_pagar->forma
             x_data       := contas_pagar->data
             x_valor      := contas_pagar->valor
             x_numero     := contas_pagar->numero
             x_obs        := contas_pagar->obs
             contas_pagar->(ordsetfocus('data'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             contas_pagar->(ordsetfocus('data'))
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
                        value 'Fornecedor';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,005 textbox tbox_001;
                        of form_dados;
                        height 027;
                        width 060;
                        value x_fornecedor;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric;
                        on enter procura_fornecedor('form_dados','tbox_001')
              @ 030,075 label lbl_nome_fornecedor;
                        of form_dados;
                        value '';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _azul_001;
                        transparent
              @ 060,005 label lbl_002;
                        of form_dados;
                        value 'Forma Pagamento';
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
                        on enter procura_forma_pagamento('form_dados','tbox_002')
              @ 080,075 label lbl_nome_forma_pagamento;
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
                     action gravar_cpag(parametro)
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
static function excluir_cpag()

       local id := valor_coluna('grid_cpag','form_cpag',1)

       dbselectarea('contas_pagar')
       contas_pagar->(ordsetfocus('id'))
       contas_pagar->(dbgotop())
       contas_pagar->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          contas_pagar->(ordsetfocus('data'))
          return(nil)
       else
          if msgyesno('Histórico : '+alltrim(contas_pagar->numero),'Excluir')
             if lock_reg()
                contas_pagar->(dbdelete())
                contas_pagar->(dbunlock())
                contas_pagar->(dbgotop())
             endif
             contas_pagar->(ordsetfocus('data'))
             atualizar_cpag()
          endif
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function gravar_cpag(parametro)

       local x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)

       if parametro == 1
          while .T.
                dbselectarea('contas_pagar')
                contas_pagar->(ordsetfocus('id'))
                contas_pagar->(dbgotop())
                contas_pagar->(dbseek(x_id))
                if found()
                   x_id := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
                   loop
                else
                   exit
                endif
          end
          dbselectarea('contas_pagar')
          *--------
          if l_demo
             if reccount() > _limite_registros
                msgstop('Limite de registros esgotado','Atenção')
                return(nil)
             endif
          endif
          *----
          contas_pagar->(dbappend())
          contas_pagar->id     := x_id
          contas_pagar->data   := form_dados.tbox_003.value
          contas_pagar->valor  := form_dados.tbox_004.value
          contas_pagar->forma  := form_dados.tbox_002.value
          contas_pagar->fornec := form_dados.tbox_001.value
          contas_pagar->numero := form_dados.tbox_005.value
          contas_pagar->obs    := form_dados.tbox_006.value
          contas_pagar->(dbcommit())
          contas_pagar->(dbgotop())
          form_dados.release
          atualizar_cpag()
       elseif parametro == 2
          dbselectarea('contas_pagar')
          if lock_reg()
             contas_pagar->data   := form_dados.tbox_003.value
             contas_pagar->valor  := form_dados.tbox_004.value
             contas_pagar->forma  := form_dados.tbox_002.value
             contas_pagar->fornec := form_dados.tbox_001.value
             contas_pagar->numero := form_dados.tbox_005.value
             contas_pagar->obs    := form_dados.tbox_006.value
             contas_pagar->(dbcommit())
             contas_pagar->(dbunlock())
             contas_pagar->(dbgotop())
          endif
          form_dados.release
          atualizar_cpag()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar_cpag()

       local x_data_001 := form_cpag.dp_inicio.value
       local x_data_002 := form_cpag.dp_final.value

       delete item all from grid_cpag of form_cpag

       dbselectarea('contas_pagar')
       index on dtos(data) to ind001 for data >= x_data_001 .and. data <= x_data_002
       go top

       while .not. eof()
             add item {contas_pagar->id,dtoc(contas_pagar->data),acha_fornecedor(contas_pagar->fornec),acha_forma_pagamento(contas_pagar->forma),trans(contas_pagar->valor,'@E 999,999.99'),alltrim(contas_pagar->numero),alltrim(contas_pagar->obs)} to grid_cpag of form_cpag
             contas_pagar->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function procura_fornecedor(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       dbselectarea('fornecedores')
       fornecedores->(ordsetfocus('codigo'))
       fornecedores->(dbgotop())
       fornecedores->(dbseek(nreg_02))
       if found()
          flag := .T.
       else
          creg := getcode_fornecedores(getproperty(cform,ctextbtn,'value'))
          dbselectarea('fornecedores')
          fornecedores->(ordsetfocus('codigo'))
          fornecedores->(dbgotop())
          fornecedores->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_dados','lbl_nome_fornecedor','value',fornecedores->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_fornecedores(value)

       local creg := ''
       local nreg := 1

       dbselectarea('fornecedores')
       fornecedores->(ordsetfocus('nome'))
       fornecedores->(dbgotop())

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
                     onchange find_fornecedores()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 480
                     height 430
                     headers {'Código','Nome'}
                     widths {080,370}
                     workarea fornecedores
                     fields {'fornecedores->codigo','fornecedores->nome'}
                     value nreg
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (creg:=fornecedores->codigo,thiswindow.release)
              end browse

              on key escape action thiswindow.release

       end window

       form_pesquisa.browse_pesquisa.setfocus

       form_pesquisa.center
       form_pesquisa.activate

       return(creg)
*-------------------------------------------------------------------------------
static function find_fornecedores()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       fornecedores->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif fornecedores->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := fornecedores->(recno())
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function procura_forma_pagamento(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       dbselectarea('formas_pagamento')
       formas_pagamento->(ordsetfocus('codigo'))
       formas_pagamento->(dbgotop())
       formas_pagamento->(dbseek(nreg_02))
       if found()
          flag := .T.
       else
          creg := getcode_formas_pagamento(getproperty(cform,ctextbtn,'value'))
          dbselectarea('formas_pagamento')
          formas_pagamento->(ordsetfocus('codigo'))
          formas_pagamento->(dbgotop())
          formas_pagamento->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_dados','lbl_nome_forma_pagamento','value',formas_pagamento->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_formas_pagamento(value)

       local creg := ''
       local nreg := 1

       dbselectarea('formas_pagamento')
       formas_pagamento->(ordsetfocus('nome'))
       formas_pagamento->(dbgotop())

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
                     onchange find_formas_pagamento()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 480
                     height 430
                     headers {'Código','Nome'}
                     widths {080,370}
                     workarea formas_pagamento
                     fields {'formas_pagamento->codigo','formas_pagamento->nome'}
                     value nreg
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (creg:=formas_pagamento->codigo,thiswindow.release)
              end browse

              on key escape action thiswindow.release

       end window

       form_pesquisa.browse_pesquisa.setfocus

       form_pesquisa.center
       form_pesquisa.activate

       return(creg)
*-------------------------------------------------------------------------------
static function find_formas_pagamento()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       formas_pagamento->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif formas_pagamento->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := formas_pagamento->(recno())
       endif

       return(nil)