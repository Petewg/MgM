/*
  sistema     : superchef pizzaria
  programa    : venda delivery
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'hbcompat.ch'
#include 'super.ch'

memvar _conta_pizza
memvar _total_pedido
memvar _preco_antes_borda
memvar _tamanho_selecionado
memvar _numero_tamanho
memvar _conta_sequencia
memvar x_valor_pizza
memvar x_valor_prod
memvar n_largura_janela
memvar n_largura_grid
memvar a_tamanhos_pedacos
memvar x_hora, x_old

function venda_delivery()

		 local x_observacao_1 := ''
		 local x_observacao_2 := ''
		 local a_bordas := {}
		 
         private _conta_pizza := 1
         private _total_pedido := 0
         private _preco_antes_borda := 0
         public _tamanho_selecionado
         public _numero_tamanho := 1
         
         public _conta_sequencia := 100

		 sele bordas
		 go top
		 while .not. eof()
		       aadd(a_bordas,bordas->nome+'-'+trans(bordas->preco,'@E 999.99'))
			   skip
		 end
		 
		 sele montagem
		 zap
		 pack
		 sele temp_vendas
		 zap
		 pack
		 sele tmp_tela
		 zap
		 pack

         define window form_delivery;
                at 000,000;
                width getdesktopwidth();
                height getdesktopheight();
                title 'Venda Delivery';
                icon path_imagens+'icone.ico';
                modal;
                on init zera_tabelas()

                * mostrar texto explicando como fechar o pedido
                @ getdesktopheight()-100,000 label label_fechar_pedido;
                          of form_delivery;
                          width getdesktopwidth();
                          height 040;
                          value 'F9-fechar este pedido  ESC-sair';
                          font 'verdana' size 022;
                          bold;
                          backcolor _preto_001;
                          fontcolor _cinza_001;
                          centeralign

                * separar a tela em 2 partes distintas
                define label label_separador
                       col 400
                       row 000
                       value ''
                       width 002
                       height getdesktopheight()-100
                       transparent .F.
                       backcolor _cinza_002
                end label

                * digitar o telefone
                @ 010,010 label label_telefone;
                          of form_delivery;
                          value 'Telefone';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,010 textbox tbox_telefone;
                          of form_delivery;
                          height 030;
                          width 150;
                          value '';
                          maxlength 015;
                          font 'courier new' size 016;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          on enter procura_cliente('form_delivery','tbox_telefone')

                * botão para cadastrar cliente caso não exista
                @ 020,170 buttonex botao_cadastrar_cliente;
                          parent form_delivery;
                          caption 'Cadastrar novo cliente';
                          width 220 height 040;
                          picture path_imagens+'cadastrar_cliente.bmp';
                          action cadastrar_novo_cliente();
                		  notabstop;
                          tooltip 'Clique aqui para cadastrar um cliente novo, sem precisar sair desta tela'

                * mostrar nome do cliente
                @ 070,010 label label_nome_cliente;
                          of form_delivery;
                          value '';
                          autosize;
                          font 'courier new' size 016;
                          bold;
                          fontcolor BLUE;
                          transparent

                * mostrar o endereço
                @ 100,010 label label_endereco_001;
                          of form_delivery;
                          value '';
                          autosize;
                          font 'courier new' size 014;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 120,010 label label_endereco_002;
                          of form_delivery;
                          value '';
                          autosize;
                          font 'courier new' size 014;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 140,010 label label_endereco_003;
                          of form_delivery;
                          value '';
                          autosize;
                          font 'courier new' size 014;
                          bold;
                          fontcolor _preto_001;
                          transparent
                          
                * histórico do cliente
                @ 180,010 grid grid_historico;
                          parent form_delivery;
                          width 380;
                          height 200;
                          headers {'id cliente','Onde','Data','Hora','Valor R$'};
                          widths {001,100,100,075,090};
                          font 'tahoma' size 010;
                          bold;
                          backcolor _branco_001;
                          fontcolor BLUE;
                          on change mostra_detalhamento()
                @ 390,010 grid grid_detalhamento;
                          parent form_delivery;
                          width 380;
                          height (getdesktopheight()-390)-105;
                          headers {'Qtd.','Produto','Valor R$'};
                          widths {080,190,100};
                          font 'tahoma' size 010;
                          bold;
                          backcolor _branco_001;
                          fontcolor BLUE

			  n_largura_janela := form_delivery.width - 410
			  n_largura_grid   := n_largura_janela / 2
			  a_tamanhos_pedacos := {}
			  aadd(a_tamanhos_pedacos,_tamanho_001+' - '+alltrim(str(_pedaco_001))+' pedaços')
			  aadd(a_tamanhos_pedacos,_tamanho_002+' - '+alltrim(str(_pedaco_002))+' pedaços')
			  aadd(a_tamanhos_pedacos,_tamanho_003+' - '+alltrim(str(_pedaco_003))+' pedaços')
			  aadd(a_tamanhos_pedacos,_tamanho_004+' - '+alltrim(str(_pedaco_004))+' pedaços')
			  aadd(a_tamanhos_pedacos,_tamanho_005+' - '+alltrim(str(_pedaco_005))+' pedaços')
			  aadd(a_tamanhos_pedacos,_tamanho_006+' - '+alltrim(str(_pedaco_006))+' pedaços')

			  @ 010,410 label label_pizza;
     		  			of form_delivery;
                        value 'Escolha o tamanho da pizza';
                        autosize;
                        font 'courier new' size 12;
                        bold;
                        fontcolor _preto_001;
                        transparent
     		  define comboboxex cbo_tamanhos
         	  		 row 30
                     col 410
	              	 width 300
			         height 400
			         items a_tamanhos_pedacos
			         value 1
			         fontname 'courier new'
			         fontsize 12
			         fontcolor BLUE
			         onchange pega_tamanho()
         	  end comboboxex

			  * grids
			  
			  * pizzas
			  @ 060,410 label label_sabores;
     		  			of form_delivery;
                        value 'Defina os sabores';
                        autosize;
                        font 'courier new' size 12;
                        bold;
                        fontcolor _preto_001;
                        transparent
			  @ 080,410 label label_sabores_2;
     		  			of form_delivery;
                        value 'duplo-clique/enter seleciona';
                        autosize;
                        font 'courier new' size 12;
                        bold;
                        fontcolor _azul_001;
                        transparent
              define grid grid_pizzas
                     parent form_delivery
                     col 410
                     row 100
                     width n_largura_grid
                     height 300
                     headers {'','Nome','.','.','.','.','.','.'}
                     widths {1,200,100,100,100,100,100,100}
                     showheaders .T.
                     nolines .T.
                     fontname 'courier new'
                     fontsize 12
                     backcolor _ciano_001
                     fontcolor _preto_001
                     ondblclick adiciona_montagem()
              end grid
       @ 440,410 Browse grid_montagem        ;
                 Of         form_delivery   ;
                 Width      n_largura_grid              ;
                 Height     100              ;
                 Headers    {'ID','Nome'};
                 Widths     {1,n_largura_grid - 30}         ;
                 Workarea   montagem ;
                 Fields     {'montagem->codigo','montagem->nome'};
                 Value      1                 ;
                 Font        'courier new'        ;
                 Size 12                      ;
                 Justify     {BROWSE_JTFY_CENTER,BROWSE_JTFY_LEFT};
                 BackColor   _amarelo_001            ;
                 FontColor   _preto_001

                @ 403,410 buttonex botao_fecha_pizza;
                          parent form_delivery;
                          caption 'Pizza montada';
                          width 120 height 35;
                          picture path_imagens+'adicionar.bmp';
                          action fecha_montagem_pizza()
                @ 403,535 buttonex botao_exclui_pizza;
                          parent form_delivery;
                          caption 'Excluir sabor';
                          width 120 height 35;
                          picture path_imagens+'img_cancela.bmp';
                          action excluir_sabor()
                          
              * observações da pizza, borda e TOTAL
              @ 403,(410 + n_largura_grid + 10) textbox tbox_obs_1;
                        of form_delivery;
                        height 027;
                        width 250;
                        value x_observacao_1;
                        maxlength 30;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 431,(410 + n_largura_grid + 10) textbox tbox_obs_2;
                        of form_delivery;
                        height 027;
                        width 250;
                        value x_observacao_2;
                        maxlength 30;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
     		  define comboboxex cbo_bordas
         	  		 row 460
                     col (410 + n_largura_grid + 10)
	              	 width 250
			         height 400
			         items a_bordas
			         value 1
			         fontname 'courier new'
			         fontsize 12
			         fontcolor BLUE
			         onchange adiciona_borda()
         	  end comboboxex
              @ 490,(410 + n_largura_grid + 10) label label_total_0;
                        of form_delivery;
                        width 250;
                        height 20;
                        value 'TOTAL DO PEDIDO';
                        font 'courier new' size 12;
                        bold;
                        fontcolor _branco_001;
                        backcolor _azul_002;
                        centeralign
              @ 510,(410 + n_largura_grid + 10) label label_total;
                        of form_delivery;
                        width 250;
                        height 50;
                        value '0,00';
                        font 'courier new' size 24;
                        bold;
                        fontcolor _vermelho_001;
                        backcolor _ciano_001;
                        rightalign
                * botão para imprimir o cupom
                @ 520,(410 + n_largura_grid + 265) buttonex botao_cupom;
                          parent form_delivery;
                          caption '';
                          width 40 height 40;
                          picture path_imagens+'img_relatorio.bmp';
                          action imprimir_cupom('-',0,0,0,0,0);
                          tooltip 'Emitir CUPOM'

			  * bebidas e outros
			  @ 060,(410 + n_largura_grid + 10) label label_bebidas;
     		  			of form_delivery;
                        value 'Bebidas / Outros';
                        autosize;
                        font 'courier new' size 12;
                        bold;
                        fontcolor _preto_001;
                        transparent
			  @ 080,(410 + n_largura_grid + 10) label label_bebidas_2;
     		  			of form_delivery;
                        value 'duplo-clique/enter seleciona';
                        autosize;
                        font 'courier new' size 12;
                        bold;
                        fontcolor _azul_001;
                        transparent
              define grid grid_produtos
                     parent form_delivery
                     col 410 + n_largura_grid + 10
                     row 100
                     width n_largura_grid - 20
                     height 300
                     headers {'','Nome','Preço'}
                     widths {1,250,150}
                     showheaders .F.
                     nolines .T.
                     fontname 'courier new'
                     fontsize 12
                     backcolor _ciano_001
                     fontcolor _preto_001
                     ondblclick pede_quantidade()
              end grid
              
              * pedido completo
			  @ 545,410 label label_pedido;
     		  			of form_delivery;
                        value 'Pedido do cliente';
                        autosize;
                        font 'courier new' size 12;
                        bold;
                        fontcolor _preto_001;
                        transparent
                @ 540,585 buttonex botao_exclui_item_pedido;
                          parent form_delivery;
                          caption 'excluir item pedido';
                          width 130 height 25;
                          fontcolor RED;
                          action excluir_item_pedido()

       @ 565,410 Browse grid_pedido        ;
                 Of         form_delivery   ;
                 Width      form_delivery.width - 420              ;
                 Height     form_delivery.height - 670              ;
                 Headers    {'SEQ','Item','Qtd','Unit.R$','SubTotal R$'};
                 Widths     {1,400,60,140,150}         ;
                 Workarea   tmp_tela ;
                 Fields     {'tmp_tela->seq','tmp_tela->item','tmp_tela->qtd','tmp_tela->unitario','tmp_tela->subtotal'};
                 Value      1                 ;
                 Font        'courier new'        ;
                 Size 12                      ;
                 Justify     {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT,BROWSE_JTFY_RIGHT,BROWSE_JTFY_RIGHT};
                 BackColor   _branco_001            ;
                 FontColor   _azul_002

			  separa_pizza()
			  separa_produto()

			  on key F9 action fecha_pedido()
              on key escape action thiswindow.release

         end window

         form_delivery.grid_pizzas.Header(3) := alltrim(_tamanho_001)
         form_delivery.grid_pizzas.Header(4) := alltrim(_tamanho_002)
         form_delivery.grid_pizzas.Header(5) := alltrim(_tamanho_003)
         form_delivery.grid_pizzas.Header(6) := alltrim(_tamanho_004)
         form_delivery.grid_pizzas.Header(7) := alltrim(_tamanho_005)
         form_delivery.grid_pizzas.Header(8) := alltrim(_tamanho_006)

         form_delivery.maximize
         form_delivery.activate

         return(nil)
*-------------------------------------------------------------------------------
static function procura_cliente(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       if empty(nreg_02)
          creg := getcode_clientes(getproperty(cform,ctextbtn,'value'))
          if .not. empty(creg)
             dbselectarea('clientes')
             clientes->(ordsetfocus('fixo'))
             clientes->(dbgotop())
             clientes->(dbseek(creg))
             if found()
                __codigo_cliente := clientes->codigo
                setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
                setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
                setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                if !empty(creg)
                   setproperty(cform,ctextbtn,'value',creg)
                endif
                historico_cliente(__codigo_cliente)
                form_delivery.cbo_tamanhos.setfocus
                return(nil)
             endif
          endif
          if .not. empty(creg)
             dbselectarea('clientes')
             clientes->(ordsetfocus('celular'))
             clientes->(dbgotop())
             clientes->(dbseek(creg))
             if found()
                __codigo_cliente := clientes->codigo
                setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
                setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
                setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                if !empty(creg)
                   setproperty(cform,ctextbtn,'value',creg)
                endif
                historico_cliente(__codigo_cliente)
                form_delivery.cbo_tamanhos.setfocus
                return(nil)
             endif
          endif
       else
          while .T.
                dbselectarea('clientes')
                clientes->(ordsetfocus('fixo'))
                clientes->(dbgotop())
                clientes->(dbseek(nreg_02))
                if found()
                   __codigo_cliente := clientes->codigo
                   setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
                   setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                   setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
                   setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                   historico_cliente(__codigo_cliente)
                   form_delivery.cbo_tamanhos.setfocus
                   exit
                endif
                dbselectarea('clientes')
                clientes->(ordsetfocus('celular'))
                clientes->(dbgotop())
                clientes->(dbseek(nreg_02))
                if found()
                   __codigo_cliente := clientes->codigo
                   setproperty('form_delivery','label_nome_cliente','value',clientes->nome)
                   setproperty('form_delivery','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                   setproperty('form_delivery','label_endereco_002','value',alltrim(clientes->complem))
                   setproperty('form_delivery','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                   historico_cliente(__codigo_cliente)
                   form_delivery.cbo_tamanhos.setfocus
                   exit
                else
                   msgalert('Telefone não está cadastrado','Atenção')
                   form_delivery.tbox_telefone.setfocus
                   return(nil)
                endif
          end
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
              width 690;
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
                     width 600
                     maxlength 040
                     onchange find_clientes()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 680
                     height 430
                     headers {'Fixo','Celular','Nome'}
                     widths {150,150,350}
                     workarea clientes
                     fields {'clientes->fixo','clientes->celular','clientes->nome'}
                     value nreg
                     fontname 'courier new'
                     fontsize 012
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (iif(empty(clientes->fixo),creg:=clientes->celular,creg:=clientes->fixo),thiswindow.release)
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
static function procura_produto()

       local x_codigo := form_delivery.tbox_produto.value

       if empty(x_codigo)
          x_codigo := '9999'
       endif

       dbselectarea('produtos')
       produtos->(ordsetfocus('codigo'))
       produtos->(dbgotop())
       produtos->(dbseek(x_codigo))

       if found()
          if produtos->pizza
             if msgyesno('Este código não é válido. Deseja procurar na lista ?','Atenção')
                mostra_listagem_produto()
                return(nil)
             else
                form_delivery.tbox_produto.setfocus
                return(nil)
             endif
          else
             setproperty('form_delivery','label_nome_produto','value',produtos->nome_longo)
             setproperty('form_delivery','tbox_preco','value',produtos->vlr_venda)
             return(nil)
          endif
       else
          mostra_listagem_produto()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_listagem_produto()

       define window form_pesquisa;
              at 000,000;
              width 560;
              height 610;
              title 'Produtos';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define grid grid_pesquisa
                     parent form_pesquisa
                     col 000
                     row 000
                     width 555
                     height 580
                     headers {'','Nome','Preço R$'}
                     widths {001,395,150}
                     showheaders .F.
                     nolines .T.
                     fontname 'courier new'
                     fontsize 012
                     backcolor _ciano_001
                     fontcolor _preto_001
                     ondblclick mostra_informacao_produto()
              end grid

              on key escape action thiswindow.release

       end window

       separa_produto()
       form_pesquisa.grid_pesquisa.setfocus
       form_pesquisa.grid_pesquisa.value := 1

       form_pesquisa.center
       form_pesquisa.activate

       return(nil)
*-------------------------------------------------------------------------------
static function separa_produto()

       delete item all from grid_produtos of form_delivery

       dbselectarea('produtos')
       produtos->(ordsetfocus('nome_longo'))
       produtos->(dbgotop())

       while .not. eof()
             if !produtos->pizza
                add item {produtos->codigo,alltrim(produtos->nome_longo),trans(produtos->vlr_venda,'@E 999,999.99')} to grid_produtos of form_delivery
             endif
             produtos->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_informacao_produto()

       local x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
       local x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)
       local x_preco  := 0
       
       setproperty('form_delivery','tbox_produto','value',alltrim(x_codigo))
       setproperty('form_delivery','label_nome_produto','value',alltrim(x_nome))

       dbselectarea('produtos')
       produtos->(ordsetfocus('codigo'))
       produtos->(dbgotop())
       produtos->(dbseek(x_codigo))
       if found()
          x_preco := produtos->vlr_venda
       endif
       setproperty('form_delivery','tbox_preco','value',x_preco)
       
       form_pesquisa.release

       return(nil)
*-------------------------------------------------------------------------------
static function procura_pizza()

       local x_codigo := form_delivery.tbox_pizza.value

       if empty(x_codigo)
          x_codigo := '9999'
       endif
       
       dbselectarea('produtos')
       produtos->(ordsetfocus('codigo'))
       produtos->(dbgotop())
       produtos->(dbseek(x_codigo))
       
       if found()
          if !produtos->pizza
             if msgyesno('Este código não é de uma Pizza. Deseja procurar na lista ?','Atenção')
                mostra_listagem_pizza()
                return(nil)
             else
                form_delivery.tbox_pizza.setfocus
                return(nil)
             endif
          else
             setproperty('form_delivery','label_nome_pizza','value',produtos->nome_longo)
             return(nil)
          endif
       else
          mostra_listagem_pizza()
       endif
       
       return(nil)
*-------------------------------------------------------------------------------
static function mostra_listagem_pizza()

       define window form_pesquisa;
              at 000,000;
              width 410;
              height 610;
              title 'Pizzas';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define grid grid_pesquisa
                     parent form_pesquisa
                     col 000
                     row 000
                     width 405
                     height 580
                     headers {'','Nome'}
                     widths {001,395}
                     showheaders .F.
                     nolines .T.
                     fontname 'courier new'
                     fontsize 012
                     backcolor _ciano_001
                     fontcolor _preto_001
                     ondblclick mostra_informacao()
              end grid

              on key escape action thiswindow.release
              
       end window
       
       separa_pizza()
       form_pesquisa.grid_pesquisa.setfocus
       form_pesquisa.grid_pesquisa.value := 1
       
       form_pesquisa.center
       form_pesquisa.activate

       return(nil)
*-------------------------------------------------------------------------------
static function separa_pizza()

       delete item all from grid_pizzas of form_delivery

       dbselectarea('produtos')
       produtos->(ordsetfocus('nome_longo'))
       produtos->(dbgotop())

       while .not. eof()
             if produtos->pizza
                add item {produtos->codigo,alltrim(produtos->nome_longo),alltrim(trans(produtos->val_tm_001,'@E 99,999.99')),alltrim(trans(produtos->val_tm_002,'@E 99,999.99')),alltrim(trans(produtos->val_tm_003,'@E 99,999.99')),alltrim(trans(produtos->val_tm_004,'@E 99,999.99')),alltrim(trans(produtos->val_tm_005,'@E 99,999.99')),alltrim(trans(produtos->val_tm_006,'@E 99,999.99'))} to grid_pizzas of form_delivery
             endif
             produtos->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_informacao()

       local x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
       local x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)

       setproperty('form_delivery','tbox_pizza','value',alltrim(x_codigo))
       setproperty('form_delivery','label_nome_pizza','value',alltrim(x_nome))
       
       form_pesquisa.release

       return(nil)
*-------------------------------------------------------------------------------
static function zera_tabelas()

       dbselectarea('tmp_pizza')
       zap
       pack
       
       dbselectarea('tmp_produto')
       zap
       pack

       return(nil)
*-------------------------------------------------------------------------------
static function cadastrar_novo_cliente()

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
       local x_aniv_dia := 0
       local x_aniv_mes := 0

       define window form_incluir_novo_cliente;
              at 000,000;
		        width 585;
		        height 380;
              title 'Incluir novo cliente';
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              * entrada de dados
              @ 010,005 label lbl_001;
                        of form_incluir_novo_cliente;
                        value 'Nome';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,005 textbox tbox_001;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 310;
                        value x_nome;
                        maxlength 040;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 010,325 label lbl_002;
                        of form_incluir_novo_cliente;
                        value 'Telefone fixo';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,325 textbox tbox_002;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 120;
                        value x_fixo;
                        maxlength 010;
                        font 'verdana' size 012;
                        bold;
                        backcolor BLUE;
                        fontcolor WHITE;
                        uppercase
              @ 010,455 label lbl_003;
                        of form_incluir_novo_cliente;
                        value 'Telefone celular';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,455 textbox tbox_003;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 120;
                        value x_celular;
                        maxlength 010;
                        font 'verdana' size 012;
                        bold;
                        backcolor BLUE;
                        fontcolor WHITE;
                        uppercase
              @ 060,005 label lbl_004;
                        of form_incluir_novo_cliente;
                        value 'Endereço';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_004;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 310;
                        value x_endereco;
                        maxlength 040;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,325 label lbl_005;
                        of form_incluir_novo_cliente;
                        value 'Número';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,325 textbox tbox_005;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 060;
                        value x_numero;
                        maxlength 006;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,395 label lbl_006;
                        of form_incluir_novo_cliente;
                        value 'Complemento';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,395 textbox tbox_006;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 180;
                        value x_complem;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,005 label lbl_007;
                        of form_incluir_novo_cliente;
                        value 'Bairro';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,005 textbox tbox_007;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 180;
                        value x_bairro;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,195 label lbl_008;
                        of form_incluir_novo_cliente;
                        value 'Cidade';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,195 textbox tbox_008;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 180;
                        value x_cidade;
                        maxlength 020;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,385 label lbl_009;
                        of form_incluir_novo_cliente;
                        value 'UF';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,385 textbox tbox_009;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 040;
                        value x_uf;
                        maxlength 002;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 110,435 label lbl_010;
                        of form_incluir_novo_cliente;
                        value 'CEP';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 130,435 textbox tbox_010;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 080;
                        value x_cep;
                        maxlength 008;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 160,005 label lbl_011;
                        of form_incluir_novo_cliente;
                        value 'e-mail';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 180,005 textbox tbox_011;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 450;
                        value x_email;
                        maxlength 050;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        lowercase
              @ 210,005 label lbl_012;
                        of form_incluir_novo_cliente;
                        value 'Dia aniversário';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 230,005 textbox tbox_012;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 080;
                        value x_aniv_dia;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric
              @ 210,120 label lbl_013;
                        of form_incluir_novo_cliente;
                        value 'Mês aniversário';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 230,120 textbox tbox_013;
                        of form_incluir_novo_cliente;
                        height 027;
                        width 080;
                        value x_aniv_mes;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric

              * texto de observação
              @ 265,005 label lbl_observacao;
                        of form_incluir_novo_cliente;
                        value '* os campos na cor azul, telefones fixo e celular, serão utilizados no DELIVERY';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor BLUE;
                        transparent

              * linha separadora
              define label linha_rodape
                     col 000
                     row form_incluir_novo_cliente.height-090
                     value ''
                     width form_incluir_novo_cliente.width
                     height 001
                     backcolor _preto_001
                     transparent .F.
              end label

              * botões
              define buttonex button_ok
                     picture path_imagens+'img_gravar.bmp'
                     col form_incluir_novo_cliente.width-225
                     row form_incluir_novo_cliente.height-085
                     width 120
                     height 050
                     caption 'Ok, gravar'
                     action gravar_novo_cliente()
                     fontbold .T.
                     tooltip 'Confirmar as informações digitadas'
                     flat .F.
                     noxpstyle .T.
              end buttonex
              define buttonex button_cancela
                     picture path_imagens+'img_voltar.bmp'
                     col form_incluir_novo_cliente.width-100
                     row form_incluir_novo_cliente.height-085
                     width 090
                     height 050
                     caption 'Voltar'
                     action form_incluir_novo_cliente.release
                     fontbold .T.
                     tooltip 'Sair desta tela sem gravar informações'
                     flat .F.
                     noxpstyle .T.
              end buttonex

              on key escape action thiswindow.release
              
       end window

       sethandcursor(getcontrolhandle('button_ok','form_incluir_novo_cliente'))
       sethandcursor(getcontrolhandle('button_cancela','form_incluir_novo_cliente'))

       form_incluir_novo_cliente.center
       form_incluir_novo_cliente.activate

       return(nil)
*-------------------------------------------------------------------------------
static function gravar_novo_cliente()

       local codigo  := 0
       local retorna := .F.

       if empty(form_incluir_novo_cliente.tbox_001.value)
          retorna := .T.
       endif

       if retorna
          msgalert('Preencha o campo nome','Atenção')
          return(nil)
       endif

       while .T.
             dbselectarea('conta')
             conta->(dbgotop())
             if lock_reg()
                codigo := conta->c_clientes
                replace c_clientes with c_clientes + 1
                conta->(dbcommit())
                conta->(dbunlock())
                exit
             else
                msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
                loop
             endif
       end
       dbselectarea('clientes')
       clientes->(dbappend())
       clientes->codigo   := codigo
       clientes->nome     := form_incluir_novo_cliente.tbox_001.value
       clientes->fixo     := form_incluir_novo_cliente.tbox_002.value
       clientes->celular  := form_incluir_novo_cliente.tbox_003.value
       clientes->endereco := form_incluir_novo_cliente.tbox_004.value
       clientes->numero   := form_incluir_novo_cliente.tbox_005.value
       clientes->complem  := form_incluir_novo_cliente.tbox_006.value
       clientes->bairro   := form_incluir_novo_cliente.tbox_007.value
       clientes->cidade   := form_incluir_novo_cliente.tbox_008.value
       clientes->uf       := form_incluir_novo_cliente.tbox_009.value
       clientes->cep      := form_incluir_novo_cliente.tbox_010.value
       clientes->email    := form_incluir_novo_cliente.tbox_011.value
       clientes->aniv_dia := form_incluir_novo_cliente.tbox_012.value
       clientes->aniv_mes := form_incluir_novo_cliente.tbox_013.value
       clientes->(dbcommit())
       clientes->(dbgotop())

       form_incluir_novo_cliente.release

       if .not. empty(form_incluir_novo_cliente.tbox_002.value)
          setproperty('form_delivery','tbox_telefone','value',form_incluir_novo_cliente.tbox_002.value)
          form_delivery.tbox_telefone.setfocus
       else
          setproperty('form_delivery','tbox_telefone','value',form_incluir_novo_cliente.tbox_003.value)
          form_delivery.tbox_telefone.setfocus
       endif
       
       return(nil)
*-------------------------------------------------------------------------------
static function gravar_adicionar()

       dbselectarea('tmp_pizza')
       tmp_pizza->(dbappend())
       tmp_pizza->id_produto := form_delivery.tbox_pizza.value
       tmp_pizza->nome       := form_delivery.label_nome_pizza.value
       tmp_pizza->(dbcommit())
       tmp_pizza->(dbgotop())

       form_delivery.grid_pizzas.refresh
       form_delivery.grid_pizzas.setfocus
	    form_delivery.grid_pizzas.value := recno()

       form_delivery.tbox_pizza.value := ''
       form_delivery.tbox_pizza.setfocus
       
       return(nil)
*-------------------------------------------------------------------------------
static function gravar_produto()
/*
       dbselectarea('tmp_produto')
       tmp_produto->(dbappend())
       tmp_produto->produto  := form_delivery.tbox_produto.value
       tmp_produto->nome     := form_delivery.label_nome_produto.value
       tmp_produto->qtd      := form_delivery.tbox_quantidade.value
       tmp_produto->unitario := form_delivery.tbox_preco.value
       tmp_produto->subtotal := (form_delivery.tbox_preco.value*form_delivery.tbox_quantidade.value)
       tmp_produto->(dbcommit())
       tmp_produto->(dbgotop())

       form_delivery.grid_produtos.refresh
       form_delivery.grid_produtos.setfocus
	    form_delivery.grid_produtos.value := recno()

       form_delivery.tbox_produto.value := ''
       form_delivery.tbox_produto.setfocus
*/
       return(nil)
*-------------------------------------------------------------------------------
static function excluir_pizza()

       if empty(tmp_pizza->nome)
          msgalert('Escolha o que deseja excluir primeiro','Atenção')
          return(nil)
       endif
       
       if msgyesno('Excluir : '+alltrim(tmp_pizza->nome),'Excluir')
          tmp_pizza->(dbdelete())
       endif

       form_delivery.grid_pizzas.refresh
	    form_delivery.grid_pizzas.setfocus
	    form_delivery.grid_pizzas.value := recno()
	    
	    return(nil)
*-------------------------------------------------------------------------------
static function excluir_produto()

       if empty(tmp_produto->nome)
          msgalert('Escolha o que deseja excluir primeiro','Atenção')
          return(nil)
       endif

       if msgyesno('Excluir : '+alltrim(tmp_produto->nome),'Excluir')
          tmp_produto->(dbdelete())
       endif

       form_delivery.grid_produtos.refresh
	    form_delivery.grid_produtos.setfocus
	    form_delivery.grid_produtos.value := recno()

	    return(nil)
*-------------------------------------------------------------------------------
static function fecha_pizza()

       dbselectarea('tmp_pizza')
       tmp_pizza->(dbgotop())
       if eof()
          msgexclamation('Nenhuma pizza foi selecionada ainda','Atenção')
          return(nil)
       endif

       define window form_finaliza_pizza;
              at 000,000;
		        width 1000;
		        height 400;
              title 'Finalizar pizza';
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              @ 005,005 label lbl_001;
                        of form_finaliza_pizza;
                        value '1- Selecione o tamanho da pizza';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 025,005 label lbl_002;
                        of form_finaliza_pizza;
                        value '2- Você poderá escolher entre o menor e o maior preço à ser cobrado, no caso de ter mais de 1 sabor na mesma pizza';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 045,005 label lbl_003;
                        of form_finaliza_pizza;
                        value '3- Caso deseje, ao fechamento deste pedido, poderá conceder um desconto especial ao cliente';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 065,005 label lbl_004;
                        of form_finaliza_pizza;
                        value '4- Para finalizar esta pizza e continuar vendendo, dê duplo-clique ou enter sobre o tamanho/preço escolhido';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 085,005 label lbl_005;
                        of form_finaliza_pizza;
                        value '5- ESC fecha esta janela e retorna para a tela de vendas';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _vermelho_002;
                        transparent

              define grid grid_finaliza_pizza
                     parent form_finaliza_pizza
                     col 005
                     row 105
                     width 985
                     height 260
                     headers {'id','Pizza',_tamanho_001,_tamanho_002,_tamanho_003,_tamanho_004,_tamanho_005,_tamanho_006}
                     widths {001,250,120,120,120,120,120,120}
                     value 1
                     celled .T.
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _cinza_005
                     fontcolor _preto_001
                     ondblclick pega_tamanho_valor_pizza()
              end grid

              on key escape action thiswindow.release

       end window

       monta_informacao_pizza()
       
       form_finaliza_pizza.center
       form_finaliza_pizza.activate

       return(nil)
*-------------------------------------------------------------------------------
static function monta_informacao_pizza()

       dbselectarea('tmp_pizza')
       tmp_pizza->(dbgotop())

       delete item all from grid_finaliza_pizza of form_finaliza_pizza
       
       while .not. eof()
             dbselectarea('produtos')
             produtos->(ordsetfocus('codigo'))
             produtos->(dbgotop())
             produtos->(dbseek(tmp_pizza->id_produto))
             if found()
                add item {produtos->codigo,alltrim(produtos->nome_longo)+iif(produtos->promocao,' (promoção)',''),trans(produtos->val_tm_001,'@E 99,999.99'),trans(produtos->val_tm_002,'@E 99,999.99'),trans(produtos->val_tm_003,'@E 99,999.99'),trans(produtos->val_tm_004,'@E 99,999.99'),trans(produtos->val_tm_005,'@E 99,999.99'),trans(produtos->val_tm_006,'@E 99,999.99')} to grid_finaliza_pizza of form_finaliza_pizza
             endif
             dbselectarea('tmp_pizza')
             tmp_pizza->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function pega_tamanho_valor_pizza()

       local valor_do_grid  := form_finaliza_pizza.grid_finaliza_pizza.value
       local item_valor     := form_finaliza_pizza.grid_finaliza_pizza.cell(getproperty('form_finaliza_pizza','grid_finaliza_pizza','value')[1],getproperty('form_finaliza_pizza','grid_finaliza_pizza','value')[2])
       local x_preco        := val(strtran(item_valor,','))/100
       local x_coluna       := valor_do_grid[2]
       local x_nome_tamanho := space(30)

       if x_coluna == 1
          return(nil)
       elseif x_coluna == 2
          return(nil)
       elseif x_coluna == 3
          x_nome_tamanho := alltrim(_tamanho_001)+' '+alltrim(str(_pedaco_001))+'ped'
       elseif x_coluna == 4
          x_nome_tamanho := alltrim(_tamanho_002)+' '+alltrim(str(_pedaco_002))+'ped'
       elseif x_coluna == 5
          x_nome_tamanho := alltrim(_tamanho_003)+' '+alltrim(str(_pedaco_003))+'ped'
       elseif x_coluna == 6
          x_nome_tamanho := alltrim(_tamanho_004)+' '+alltrim(str(_pedaco_004))+'ped'
       elseif x_coluna == 7
          x_nome_tamanho := alltrim(_tamanho_005)+' '+alltrim(str(_pedaco_005))+'ped'
       elseif x_coluna == 8
          x_nome_tamanho := alltrim(_tamanho_006)+' '+alltrim(str(_pedaco_006))+'ped'
       endif

       dbselectarea('tmp_pizza')
       tmp_pizza->(dbgotop())
       while .not. eof()
             if empty(tmp_pizza->sequencia)
                replace sequencia with 'pizza '+alltrim(str(_conta_pizza))
                replace tamanho with x_nome_tamanho
                replace preco with x_preco
             endif
             tmp_pizza->(dbskip())
       end
       
       _conta_pizza ++
       
       form_finaliza_pizza.release
       form_delivery.grid_pizzas.refresh
       form_delivery.grid_pizzas.setfocus
       form_delivery.tbox_observacoes.setfocus
       
       return(nil)
*-------------------------------------------------------------------------------
static function verifica_zero()

       local x_qtd := form_delivery.tbox_quantidade.value
       
       if empty(x_qtd)
          form_delivery.tbox_quantidade.setfocus
          return(nil)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function fecha_pedido()

       local x_old_pizza      := space(10)
       local x_old_valor      := 0
       local x_total_pedido   := 0
       local x_total_recebido := 0

	   local x_borda := form_delivery.cbo_bordas.value
	   local x_preco := 0

       private x_valor_pizza  := 0
       private x_valor_prod   := 0

       dbselectarea('temp_vendas')
       temp_vendas->(dbgotop())

       if eof()
          msgstop('Nenhuma venda foi realizada, tecle ENTER','Atenção')
          return(nil)
       endif

	   index on sequencia to indseq for tipo == 1
	   go top
	   
          while .not. eof()
                   x_old_pizza := temp_vendas->sequencia
                   x_old_valor := temp_vendas->subtotal

				temp_vendas->(dbskip())
				
				if temp_vendas->sequencia <> x_old_pizza
 	  			   x_valor_pizza := (x_valor_pizza+x_old_valor)
      	        endif

          end

	   set index to
	   
       dbselectarea('temp_vendas')
       temp_vendas->(dbgotop())
	   while .not. eof()
       		 if temp_vendas->tipo == 2
                x_valor_prod := (x_valor_prod+temp_vendas->subtotal)
             endif
       	     temp_vendas->(dbskip())
       end

       define window form_fecha_pedido;
              at 000,000;
		      width 500;
		      height 540;
              title 'Fechamento do pedido';
              icon path_imagens+'icone.ico';
		      modal;
		      nosize

              * linhas para separar os elementos na tela
              define label label_sep_001
                     col 000
                     row 190
                     value ''
                     width 500
                     height 002
                     transparent .F.
                     backcolor _cinza_002
              end label
              define label label_sep_002
                     col 000
                     row 390
                     value ''
                     width 500
                     height 002
                     transparent .F.
                     backcolor _cinza_002
              end label

			  *-------------*
			  * valor borda *
			  *-------------*
	   		  dbselectarea('bordas')
	   		  go top
	   		  go x_borda
	   		  x_preco := bordas->preco
	   		  *------

              @ 010,020 label label_001;
                        of form_fecha_pedido;
                        value 'SUBTOTAL PIZZAS';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 010,250 label label_001_valor;
                        of form_fecha_pedido;
                        value trans(x_valor_pizza,'@E 999,999.99');
                        autosize;
                        font 'courier new' size 016;
                        bold;
                        fontcolor BLUE;
                        transparent
                        
                        if .not. empty(x_preco)
              			   @ 004,390 label label_b001;
                           	 of form_fecha_pedido;
                        	 value 'valor da borda';
                        	 autosize;
                        	 font 'tahoma' size 8;
                        	 bold;
                        	 fontcolor BLACK;
                        	 transparent
              			   @ 018,390 label label_b002;
                           	 of form_fecha_pedido;
                        	 value trans(x_preco,'@E 9,999.99');
                        	 autosize;
                        	 font 'courier new' size 014;
                        	 bold;
                        	 fontcolor BLUE;
                        	 transparent
                        endif
              *--------
              @ 040,020 label label_002;
                        of form_fecha_pedido;
                        value 'SUBTOTAL PRODUTOS';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 040,250 label label_002_valor;
                        of form_fecha_pedido;
                        value trans(x_valor_prod,'@E 999,999.99');
                        autosize;
                        font 'courier new' size 016;
                        bold;
                        fontcolor BLUE;
                        transparent
              *--------
              @ 070,020 label label_003;
                        of form_fecha_pedido;
                        value 'TAXA DE ENTREGA';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 070,250 getbox tbox_taxa;
                        of form_fecha_pedido;
                        height 030;
                        width 130;
                        value 0;
                        font 'courier new' size 016;
                        bold;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 9,999.99'
              *--------
              @ 110,020 label label_004;
                        of form_fecha_pedido;
                        value 'DESCONTO';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor _vermelho_002;
                        transparent
              @ 110,250 getbox tbox_desconto;
                        of form_fecha_pedido;
                        height 030;
                        width 130;
                        value 0;
                        font 'courier new' size 016;
                        bold;
                        backcolor _fundo_get;
                        fontcolor _vermelho_002;
                        picture '@E 9,999.99';
                        on change setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod+form_fecha_pedido.tbox_taxa.value+x_preco)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'));
                        on lostfocus setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod+form_fecha_pedido.tbox_taxa.value+x_preco)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'))
              *--------
              @ 150,020 label label_005;
                        of form_fecha_pedido;
                        value 'TOTAL DESTE PEDIDO';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 150,250 label label_005_valor;
                        of form_fecha_pedido;
                        value '';
                        autosize;
                        font 'courier new' size 016;
                        bold;
                        fontcolor BLUE;
                        transparent
                        
              * escolher formas de recebimento
              @ 200,020 label label_006;
                        of form_fecha_pedido;
                        value 'Você pode escolher até 3 formas de recebimento';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor _preto_001;
                        transparent
              * formas de recebimento
              * 1º
		        @ 230,020 combobox combo_1;
			               itemsource formas_recebimento->nome;
			               valuesource formas_recebimento->codigo;
			               value 1;
			               width 250;
			               font 'courier new' size 010
              @ 230,300 getbox tbox_fr001;
                        of form_fecha_pedido;
                        height 030;
                        width 130;
                        value 0;
                        font 'courier new' size 014;
                        bold;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 99,999.99'
              * 2º
		        @ 270,020 combobox combo_2;
			               itemsource formas_recebimento->nome;
			               valuesource formas_recebimento->codigo;
			               value 1;
			               width 250;
			               font 'courier new' size 010
              @ 270,300 getbox tbox_fr002;
                        of form_fecha_pedido;
                        height 030;
                        width 130;
                        value 0;
                        font 'courier new' size 014;
                        bold;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 99,999.99'
              * 3º
		        @ 310,020 combobox combo_3;
			               itemsource formas_recebimento->nome;
			               valuesource formas_recebimento->codigo;
			               value 1;
			               width 250;
			               font 'courier new' size 010
              @ 310,300 getbox tbox_fr003;
                        of form_fecha_pedido;
                        height 030;
                        width 130;
                        value 0;
                        font 'courier new' size 014;
                        bold;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        picture '@E 99,999.99';
                        on lostfocus calcula_final(x_preco)

              @ 360,020 label label_011;
                        of form_fecha_pedido;
                        value 'TOTAL RECEBIDO';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor BLUE;
                        transparent
              @ 360,250 label label_011_valor;
                        of form_fecha_pedido;
                        value '';
                        autosize;
                        font 'courier new' size 016;
                        bold;
                        fontcolor BLUE;
                        transparent

              *--------
              @ 400,020 label label_012;
                        of form_fecha_pedido;
                        value 'TROCO';
                        autosize;
                        font 'verdana' size 012;
                        bold;
                        fontcolor _vermelho_002;
                        transparent
              @ 400,250 label label_012_valor;
                        of form_fecha_pedido;
                        value '';
                        autosize;
                        font 'courier new' size 016;
                        bold;
                        fontcolor BLUE;
                        transparent

              * botões
              @ 460,005 buttonex botao_cupom;
                        parent form_fecha_pedido;
                        caption 'Imprimir CUPOM';
                        width 155 height 040;
                        picture path_imagens+'img_relatorio.bmp';
                        action imprimir_cupom('-',x_valor_pizza+x_valor_prod,form_fecha_pedido.tbox_taxa.value,x_preco,form_fecha_pedido.tbox_desconto.value,0);
                        tooltip 'Clique aqui imprimir o cupom'
              @ 460,165 buttonex botao_ok;
                        parent form_fecha_pedido;
                        caption 'Fechar pedido';
                        width 140 height 040;
                        picture path_imagens+'img_pedido.bmp';
                        action fechamento_geral(x_preco);
                        tooltip 'Clique aqui para finalizar o pedido'
              @ 460,310 buttonex botao_voltar;
                        parent form_fecha_pedido;
                        caption 'Voltar tela anterior';
                        width 180 height 040;
                        picture path_imagens+'img_sair.bmp';
                        action form_fecha_pedido.release;
                        tooltip 'Clique aqui para voltar a vender'

              on key escape action thiswindow.release
              
       end window
       
       form_fecha_pedido.center
       form_fecha_pedido.activate
       
       return(nil)
*-------------------------------------------------------------------------------
static function calcula_final(p_borda)

       local x_val_001  := 0
       local x_val_002  := 0
       local x_val_003  := 0
       local x_val_004  := 0
       local x_val_005  := 0
       local x_val_006  := 0
       local x_val_007  := 0
       local x_total    := 0
       local x_recebido := 0
       local x_troco    := 0
       
       x_val_001 := x_valor_pizza
       x_val_002 := x_valor_prod
       x_val_003 := form_fecha_pedido.tbox_taxa.value
       x_val_004 := form_fecha_pedido.tbox_desconto.value
       x_val_005 := form_fecha_pedido.tbox_fr001.value
       x_val_006 := form_fecha_pedido.tbox_fr002.value
       x_val_007 := form_fecha_pedido.tbox_fr003.value

       x_total    := (x_val_001+x_val_002+x_val_003+p_borda)-(x_val_004)
       x_recebido := (x_val_005+x_val_006+x_val_007)
       x_troco    := (x_recebido-x_total)

       setproperty('form_fecha_pedido','label_011_valor','value',trans(x_recebido,'@E 999,999.99'))
       setproperty('form_fecha_pedido','label_012_valor','value',trans(x_troco,'@E 999,999.99'))
       
       return(nil)
*-------------------------------------------------------------------------------
static function fechamento_geral(p_borda)

       local x_val_001  := 0
       local x_val_002  := 0
       local x_val_003  := 0
       local x_val_004  := 0
       local x_val_005  := 0
       local x_val_006  := 0
       local x_val_007  := 0
       local x_total    := 0
       local x_recebido := 0
       local x_cod_forma_1 := 0
       local x_cod_forma_2 := 0
       local x_cod_forma_3 := 0
       local x_dias := 0

       ******************************
       
       x_val_001     := x_valor_pizza
       x_val_002     := x_valor_prod
       x_val_003     := form_fecha_pedido.tbox_taxa.value
       x_val_004     := form_fecha_pedido.tbox_desconto.value
       x_cod_forma_1 := form_fecha_pedido.combo_1.value
       x_cod_forma_2 := form_fecha_pedido.combo_2.value
       x_cod_forma_3 := form_fecha_pedido.combo_3.value
       x_val_005     := form_fecha_pedido.tbox_fr001.value
       x_val_006     := form_fecha_pedido.tbox_fr002.value
       x_val_007     := form_fecha_pedido.tbox_fr003.value

       x_total    := (x_val_001+x_val_002+x_val_003+p_borda)-(x_val_004)
       x_recebido := (x_val_005+x_val_006+x_val_007)

       *********************************************
       
       * formas de recebimento
       * 1
       if .not. empty(x_val_005)
          dbselectarea('formas_recebimento')
          formas_recebimento->(ordsetfocus('codigo'))
          formas_recebimento->(dbgotop())
          formas_recebimento->(dbseek(x_cod_forma_1))
          if found()
             x_dias := formas_recebimento->dias_receb
          endif
          dbselectarea('contas_receber')
          contas_receber->(dbappend())
          contas_receber->id      := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
          contas_receber->data    := date() + x_dias
          contas_receber->valor   := x_val_005
          contas_receber->forma   := x_cod_forma_1
          contas_receber->cliente := __codigo_cliente
          contas_receber->(dbcommit())
       endif
       * 2
       if .not. empty(x_val_006)
          dbselectarea('formas_recebimento')
          formas_recebimento->(ordsetfocus('codigo'))
          formas_recebimento->(dbgotop())
          formas_recebimento->(dbseek(x_cod_forma_2))
          if found()
             x_dias := formas_recebimento->dias_receb
          endif
          dbselectarea('contas_receber')
          contas_receber->(dbappend())
          contas_receber->id      := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
          contas_receber->data    := date() + x_dias
          contas_receber->valor   := x_val_006
          contas_receber->forma   := x_cod_forma_2
          contas_receber->cliente := __codigo_cliente
          contas_receber->(dbcommit())
       endif
       * 3
       if .not. empty(x_val_007)
          dbselectarea('formas_recebimento')
          formas_recebimento->(ordsetfocus('codigo'))
          formas_recebimento->(dbgotop())
          formas_recebimento->(dbseek(x_cod_forma_3))
          if found()
             x_dias := formas_recebimento->dias_receb
          endif
          dbselectarea('contas_receber')
          contas_receber->(dbappend())
          contas_receber->id      := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
          contas_receber->data    := date() + x_dias
          contas_receber->valor   := x_val_007
          contas_receber->forma   := x_cod_forma_3
          contas_receber->cliente := __codigo_cliente
          contas_receber->(dbcommit())
       endif

       * caixa
       
       dbselectarea('caixa')
       caixa->(dbappend())
       caixa->id        := substr(alltrim(str(HB_RANDOM(0010023003,9999999999))),1,10)
       caixa->data      := date()
       caixa->historico := 'Venda Delivery'
       caixa->entrada   := x_recebido
       caixa->saida     := 0
       caixa->(dbcommit())

       * baixar os produtos
       
       dbselectarea('temp_vendas')
       index on tipo to indtip1 for tipo == 2
       temp_vendas->(dbgotop())
       if .not. eof()
       while .not. eof()
             dbselectarea('produtos')
             produtos->(ordsetfocus('codigo'))
             produtos->(dbgotop())
             produtos->(dbseek(temp_vendas->produto))
             if found()
                if lock_reg()
                   produtos->qtd_estoq := produtos->qtd_estoq - temp_vendas->qtd
                   produtos->(dbcommit())
                endif
             endif
             dbselectarea('temp_vendas')
             temp_vendas->(dbskip())
       end
       endif
       set index to

       * baixar matéria prima

       x_old := space(10)
       
       dbselectarea('temp_vendas')
       index on tipo to indtip0 for tipo == 1
       temp_vendas->(dbgotop())
       if .not. eof()
       while .not. eof()
             dbselectarea('produto_composto')
             produto_composto->(ordsetfocus('id_produto'))
             produto_composto->(dbgotop())
             produto_composto->(dbseek(temp_vendas->produto))
             if found()
                while .T.
                      x_old := produto_composto->id_produto
                      dbselectarea('materia_prima')
                      materia_prima->(ordsetfocus('codigo'))
                      materia_prima->(dbgotop())
                      materia_prima->(dbseek(produto_composto->id_mprima))
                      if found()
                         if lock_reg()
                            materia_prima->qtd := materia_prima->qtd - produto_composto->quantidade
                            materia_prima->(dbcommit())
                            materia_prima->(dbunlock())
                         endif
                      endif
                      dbselectarea('produto_composto')
                      produto_composto->(dbskip())
                      if produto_composto->id_produto <> x_old
                         exit
                      endif
                end
             endif
             dbselectarea('temp_vendas')
             temp_vendas->(dbskip())
       end
       endif
       set index to

       * ultimas compras do cliente

       x_hora := space(08)
       x_hora := time()
       
       dbselectarea('ultimas_compras')
       ultimas_compras->(dbappend())
       ultimas_compras->id_cliente := __codigo_cliente
       ultimas_compras->data       := date()
       ultimas_compras->hora       := x_hora
       ultimas_compras->onde       := 1 //1=delivery 2=mesa 3=balcão
       ultimas_compras->valor      := x_total
       ultimas_compras->(dbcommit())

       * detalhamento - ultimas compras do cliente

	   * produtos
       dbselectarea('temp_vendas')
       index on tipo to indtip2 for tipo == 2
       temp_vendas->(dbgotop())
       if .not. eof()
       while .not. eof()
             dbselectarea('detalhamento_compras')
             detalhamento_compras->(dbappend())
             detalhamento_compras->id_cliente := __codigo_cliente
             detalhamento_compras->data       := date()
             detalhamento_compras->hora       := x_hora
             detalhamento_compras->id_prod    := temp_vendas->produto
             detalhamento_compras->qtd        := temp_vendas->qtd
             detalhamento_compras->unitario   := temp_vendas->unitario
             detalhamento_compras->subtotal   := temp_vendas->subtotal
             detalhamento_compras->(dbcommit())
             dbselectarea('temp_vendas')
             temp_vendas->(dbskip())
       end
       endif
       set index to
       * pizzas
       dbselectarea('temp_vendas')
       index on tipo to indtip3 for tipo == 1
       temp_vendas->(dbgotop())
       if .not. eof()
       while .not. eof()
             dbselectarea('detalhamento_compras')
             detalhamento_compras->(dbappend())
             detalhamento_compras->id_cliente := __codigo_cliente
             detalhamento_compras->data       := date()
             detalhamento_compras->hora       := x_hora
             detalhamento_compras->id_prod    := temp_vendas->produto
             detalhamento_compras->subtotal   := temp_vendas->subtotal
             detalhamento_compras->(dbcommit())
             dbselectarea('temp_vendas')
             temp_vendas->(dbskip())
       end
       endif
       set index to
       
       * jogar para acompanhamento
       
       dbselectarea('clientes')
       clientes->(ordsetfocus('codigo'))
       clientes->(dbgotop())
       clientes->(dbseek(__codigo_cliente))
       dbselectarea('entrega')
       entrega->(dbappend())
       entrega->cliente  := alltrim(clientes->nome)
       entrega->endereco := alltrim(clientes->endereco)+', '+alltrim(clientes->numero)
       if empty(clientes->fixo)
          entrega->telefone := clientes->celular
       else
          entrega->telefone := clientes->fixo
       endif
       entrega->hora     := x_hora
       entrega->origem   := 'Delivery'
       entrega->situacao := 'Montando'
       entrega->vlr_taxa := x_val_003
       entrega->(dbcommit())

       * fechar as janelas
       
       form_fecha_pedido.release
       form_delivery.release
       
       return(nil)
*-------------------------------------------------------------------------------
static function historico_cliente(parametro)

       delete item all from grid_historico of form_delivery

       dbselectarea('ultimas_compras')
       ultimas_compras->(ordsetfocus('id_cliente'))
       ultimas_compras->(dbgotop())
       ultimas_compras->(dbseek(parametro))
       
       if found()
          while .T.
                add item {str(ultimas_compras->id_cliente,6),a_onde[ultimas_compras->onde],dtoc(ultimas_compras->data),alltrim(ultimas_compras->hora),trans(ultimas_compras->valor,'@E 999,999.99')} to grid_historico of form_delivery
                ultimas_compras->(dbskip())
                if ultimas_compras->id_cliente <> parametro
                   exit
                endif
          end
       endif
       
       return(nil)
*-------------------------------------------------------------------------------
static function mostra_detalhamento()

       local x_id      := valor_coluna('grid_historico','form_delivery',1)
       local x_data    := valor_coluna('grid_historico','form_delivery',3)
       local x_hora    := alltrim(valor_coluna('grid_historico','form_delivery',4))
       local x_data_2  := ctod(x_data)
       local x_chave   := x_id+dtos(x_data_2)+x_hora
       local parametro := val(x_id)
       
       delete item all from grid_detalhamento of form_delivery

       dbselectarea('detalhamento_compras')
       detalhamento_compras->(ordsetfocus('id'))
       detalhamento_compras->(dbgotop())
       detalhamento_compras->(dbseek(x_chave))

       if found()
          while .T.
                add item {str(detalhamento_compras->qtd,6),acha_produto(detalhamento_compras->id_prod),trans(detalhamento_compras->subtotal,'@E 999,999.99')} to grid_detalhamento of form_delivery
                detalhamento_compras->(dbskip())
                if detalhamento_compras->id_cliente <> parametro
                   exit
                endif
          end
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function pede_quantidade()

	   local x_codigo := alltrim(valor_coluna('grid_produtos','form_delivery',1))
	   local x_nome := alltrim(valor_coluna('grid_produtos','form_delivery',2))
	   local x_unitario := alltrim(valor_coluna('grid_produtos','form_delivery',3))
	   
       define window form_pquantidade;
              at 0,0;
       		  width 300;
		      height 150;
              title 'Digitação';
              icon path_imagens+'icone.ico';
		      modal;
		      nosize

              @ 10,10 label label_1;
                        value 'Digite a quantidade';
                        autosize;
                        font 'courier new' size 12;
                        bold;
                        transparent
                @ 10,230 textbox tbox_quantidade;
                          height 30;
                          width 60;
                          value '';
                          numeric;
                          font 'courier new' size 12;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          on enter transfere_produto_pedido(x_codigo,x_nome,x_unitario)
              @ 50,10 label label_2;
                	    width form_pquantidade.width;
                        value 'e tecle ENTER';
                        font 'courier new' size 12;
                        fontcolor BLUE;
                        bold;
                        transparent;
                        centeralign

              on key escape action thiswindow.release
              
	   end window
	   
	   form_pquantidade.center
	   form_pquantidade.activate
	   
	   return(nil)
*-------------------------------------------------------------------------------
static function pega_tamanho()

	   _numero_tamanho := 0
	   
	   _tamanho_selecionado := alltrim(substr(form_delivery.cbo_tamanhos.displayvalue,1,10))
	   _numero_tamanho      := form_delivery.cbo_tamanhos.value
	   
	   form_delivery.grid_pizzas.setfocus
	   
	   return(nil)
*-------------------------------------------------------------------------------
static function adiciona_montagem()

       local x_codigo := valor_coluna('grid_pizzas','form_delivery',1)
       local x_nome   := valor_coluna('grid_pizzas','form_delivery',2)

	   sele montagem
	   append blank
	   replace id with x_codigo
	   replace nome with x_nome
	   
	   form_delivery.grid_montagem.setfocus
	   form_delivery.grid_montagem.refresh
	   form_delivery.grid_montagem.value := 1

	   return(nil)
*-------------------------------------------------------------------------------
static function transfere_produto_pedido(p_codigo,p_nome,p_unitario)

	   local p_qtd := alltrim(str(form_pquantidade.tbox_quantidade.value))
	   local x_unitario := 0
	   local total_geral := 0
	   
	   if p_qtd == '0'
	      msginfo('Quantidade não pode ser zero','Atenção')
	      return(nil)
	   endif
	   
       dbselectarea('produtos')
       produtos->(ordsetfocus('codigo'))
       produtos->(dbgotop())
       produtos->(dbseek(p_codigo))
       if found()
          x_unitario := produtos->vlr_venda
       endif

	   dbselectarea('temp_vendas')
	   append blank
	   replace seq with _conta_sequencia
	   replace id with alltrim(str(hb_random(0111222233,9999999889)))
	   replace tipo with 2
	   replace produto with p_codigo
	   replace preco with 0
	   replace sequencia with ''
	   replace nome with p_nome
	   replace qtd with val(p_qtd)
	   replace unitario with x_unitario
	   replace subtotal with x_unitario * val(p_qtd)

	   *-------------------------------------*
	   *                                     *
	   * grava para aparecer na tela somente *
	   *                                     *
	   *-------------------------------------*

	   dbselectarea('tmp_tela')
	   append blank
	   replace seq with _conta_sequencia
	   replace item with p_nome
	   replace qtd with val(p_qtd)
	   replace unitario with x_unitario
	   replace subtotal with x_unitario * val(p_qtd)

	   *---------*
	   * end job *
	   *---------*

	   _conta_sequencia ++

	   form_delivery.grid_pedido.setfocus
	   form_delivery.grid_pedido.refresh
	   form_delivery.grid_pedido.value := 1

	   _total_pedido := ( _total_pedido + (x_unitario * val(p_qtd)) )
	   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))
	   
	   form_pquantidade.release
	   
	   return(nil)
*-------------------------------------------------------------------------------
static function excluir_sabor()

         If DbfVazio('montagem')
            Return(Nil)
         Endif

		 montagem->(DbDelete())
		 pack
   		 montagem->(DbGoTop())

	 	 form_delivery.grid_montagem.setFocus
         form_delivery.grid_montagem.refresh
         form_delivery.grid_montagem.value := 1

         Return(Nil)
*-------------------------------------------------------------------------------
static function excluir_item_pedido()

	   local n_seq := tmp_tela->seq
	   local x_old_seq := 0
	   local x_valor := 0
	   local x_menos := 0
	   
       If DbfVazio('tmp_tela')
       	  Return(Nil)
       Endif
       
       dbselectarea('tmp_tela')
       go top
       while .not. eof()
             if tmp_tela->seq == n_seq
	   		 	tmp_tela->(DbDelete())
	   		 endif
	   		 skip
	   end
	   pack
	   *-----------------------------------------*
	   * nessa rotina pega o valor para diminuir *
	   *-----------------------------------------*
       dbselectarea('temp_vendas')
       index on seq to indseq9 for seq == n_seq
       go top
       while .not. eof()
             x_old_seq := temp_vendas->seq
			 x_valor := temp_vendas->subtotal
			 skip
             if temp_vendas->seq <> x_old_seq
                x_menos := ( x_menos + x_valor )
	   		 endif
	   end
	   set index to
	   *--------------------*
	   * nessa rotina apaga *
	   *--------------------*
       dbselectarea('temp_vendas')
       go top
       while .not. eof()
             if temp_vendas->seq == n_seq
	   		 	temp_vendas->(DbDelete())
	   		 endif
	   		 skip
	   end
	   pack

       dbselectarea('temp_vendas')
       go top
       dbselectarea('tmp_tela')
       go top

	   *---------------------------------------*
	   *                                       *
	   * diminui valor total do pedido na tela *
	   *                                       *
	   *---------------------------------------*
	   _total_pedido := ( _total_pedido - x_menos )
	   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))

	   form_delivery.grid_pedido.setFocus
       form_delivery.grid_pedido.refresh
       form_delivery.grid_pedido.value := 1

	   Return(Nil)
*-------------------------------------------------------------------------------
static function fecha_montagem_pizza()

	   local x_valor := 0
	   local x_maior_valor := 0
	   local x_soma := 0
	   local x_qtd := 0
	   local x_valor_cobrado := 0
	   local a_nome_pizza := {}

	   static x_sequencia := 1
	   
	   dbselectarea('temp_cpz')
	   pack
	   zap
	   
	   dbselectarea('montagem')
	   montagem->(dbgotop())
	   
	   if eof()
	      msginfo('Não existe(m) sabor(es) selecionado(s), tecle ENTER','Atenção')
	      return(nil)
	   endif

	   while .not. eof()
	   
       		 dbselectarea('produtos')
       		 produtos->(ordsetfocus('codigo'))
       		 produtos->(dbgotop())
       		 produtos->(dbseek(montagem->id))
       		 if found()
				if _numero_tamanho == 1
				   x_valor := produtos->val_tm_001
				elseif _numero_tamanho == 2
				   x_valor := produtos->val_tm_002
				elseif _numero_tamanho == 3
				   x_valor := produtos->val_tm_003
				elseif _numero_tamanho == 4
				   x_valor := produtos->val_tm_004
				elseif _numero_tamanho == 5
				   x_valor := produtos->val_tm_005
				elseif _numero_tamanho == 6
				   x_valor := produtos->val_tm_006
				endif
				x_soma := x_soma + x_valor
				aadd(a_nome_pizza,alltrim(produtos->nome_longo))
				dbselectarea('temp_cpz')
				append blank
				replace preco with x_valor
				dbselectarea('produtos')
       		 endif

	         dbselectarea('montagem')
	         montagem->(dbskip())
	         
	   end

       dbselectarea('temp_cpz')
	   index on preco to indpcpz descend
	   go top
	   x_maior_valor := temp_cpz->preco
	   
       dbselectarea('montagem')
       go top
       x_qtd := montagem->(reccount())

	   if _tipo_cobranca == 1 // maior valor
	      x_valor_cobrado := x_maior_valor
	   elseif _tipo_cobranca == 2 // média do valor
		  x_valor_cobrado := ( x_soma / x_qtd )
	   endif
	   
	   *-----------------------*
	   * gravar as informações *
	   *-----------------------*
	   
       dbselectarea('montagem')
       go top

	   while .not. eof()

	   		 dbselectarea('temp_vendas')
	   		 append blank
	   		 replace seq with _conta_sequencia
	   		 replace id with alltrim(str(hb_random(0111222233,9999999889)))
	   		 replace tipo with 1
	   		 replace produto with montagem->id
	   		 replace preco with 0
	   		 replace sequencia with 'pza '+alltrim(str(x_sequencia))
	   		 replace nome with montagem->nome
	   		 replace qtd with 1
	   		 //replace unitario with x_valor_cobrado
	   		 replace subtotal with x_valor_cobrado
	   		 
	   		 dbselectarea('montagem')
	   		 montagem->(dbskip())
	   		 
	   end

	   *-------------------------------------*
	   *                                     *
	   * grava para aparecer na tela somente *
	   *                                     *
	   *-------------------------------------*
       dbselectarea('montagem')
       go top

	   while .not. eof()

	   		 dbselectarea('tmp_tela')
	   		 append blank
	   		 replace seq with _conta_sequencia
	   		 replace item with '1/'+alltrim(str(x_qtd))+' - '+alltrim(montagem->nome)
	   		 
	   		 dbselectarea('montagem')
	   		 montagem->(dbskip())

	   end
	   dbselectarea('tmp_tela')
	   append blank
	   replace seq with _conta_sequencia
	   replace item with '  TOTAL pizza '+alltrim(str(x_sequencia))+' R$ '+trans(x_valor_cobrado,'@E 99,999.99')

	   *---------*
	   * end job *
	   *---------*
	   
	   x_sequencia ++
	   _conta_sequencia ++

	   _total_pedido := ( _total_pedido + x_valor_cobrado )
	   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))

	   dbselectarea('montagem')
	   zap
	   pack
	   form_delivery.grid_montagem.setfocus
	   form_delivery.grid_montagem.refresh
	   form_delivery.grid_montagem.value := 1

       dbselectarea('tmp_tela')
       go top
	   form_delivery.grid_pedido.setfocus
	   form_delivery.grid_pedido.refresh
	   form_delivery.grid_pedido.value := 1

	   return(nil)
*-------------------------------------------------------------------------------
static function imprimir_cupom(p_entregador,p_pedido,p_entrega,p_borda,p_desconto,p_total)

	   local x_observacao_1 := form_delivery.tbox_obs_1.value
	   local x_observacao_2 := form_delivery.tbox_obs_2.value
	   local x_borda := alltrim(substr(form_delivery.cbo_bordas.displayvalue,1,15))
       local x_nome, x_fixo, x_endereco, x_numero
	   local x_telefone_cliente := alltrim(form_delivery.tbox_telefone.value)
       local x_nome_cliente := alltrim(form_delivery.label_nome_cliente.value)
       local x_endereco_1 := alltrim(form_delivery.label_endereco_001.value)
       local x_endereco_2 := alltrim(form_delivery.label_endereco_002.value)
       local x_endereco_3 := alltrim(form_delivery.label_endereco_003.value)
       local x_total := alltrim(form_delivery.label_total.value)

       dbselectarea('empresa')
       empresa->(dbgotop())
       x_nome     := alltrim(empresa->nome)
       x_fixo     := alltrim(empresa->fixo_1)
       x_endereco := alltrim(empresa->endereco)
       x_numero   := alltrim(empresa->numero)

	   Try
	   
          SET PRINTER ON
          SET PRINTER TO LPT1
          SET CONSOLE OFF

          ? x_nome
          ? x_endereco+', '+x_numero+', '+x_fixo
          ? '------------------------------------------------'
          ? '         CUPOM PARA SIMPLES CONFERENCIA'
          ? '             NAO E DOCUMENTO FISCAL'
          ? '================================================'
          ? 'CLIENTE   : '+x_telefone_cliente+'-'+x_nome_cliente
          ? ' '+x_endereco_1
          ? ' '+x_endereco_2
          ? ' '+x_endereco_3
          ? 'ENTREGADOR: '+alltrim(p_entregador)
          ? 'DATA      : '+dtoc(date())+'  HORA: '+time()
          ? '------------------------------------------------'
          ? 'PRODUTO             QTD  UNITARIO     SUB-TOTAL'
          ? ''
          dbselectarea('tmp_tela')
          go top
          while .not. eof()
                if empty(tmp_tela->qtd)
                   if substr(alltrim(tmp_tela->item),1,8) == 'TOTAL'
                      ? '                            '+alltrim(tmp_tela->item)
                   else
                      ? alltrim(tmp_tela->item)
                   endif
				else
                   ? substr(tmp_tela->item,1,20)+' '+trans(tmp_tela->qtd,'@R 99999')+'   '+trans(tmp_tela->unitario,'@E 999.99')+'      '+trans(tmp_tela->subtotal,'@E 999.99')
				endif
                skip
          end
          ? ''
          ? 'BORDA'
          ? '*** '+x_borda+' ***'
          ? ''
          ? '================================================'
          if empty(p_pedido)
          	 ? '                      TOTAL PEDIDO : '+trans(_total_pedido,'@E 999,999.99')
          	 ? '                   TAXA DE ENTREGA : '+trans(p_entrega,'@E 999,999.99')
          	 ? '                             BORDA : '+trans(p_borda,'@E 999,999.99')
          	 ? '                          DESCONTO : '+trans(p_desconto,'@E 999,999.99')
          	 ? '                             TOTAL : '+trans(_total_pedido,'@E 999,999.99')
		  else
          	 ? '                      TOTAL PEDIDO : '+trans(p_pedido,'@E 999,999.99')
          	 ? '                   TAXA DE ENTREGA : '+trans(p_entrega,'@E 999,999.99')
          	 ? '                             BORDA : '+trans(p_borda,'@E 999,999.99')
          	 ? '                          DESCONTO : '+trans(p_desconto,'@E 999,999.99')
          	 ? '                             TOTAL : '+trans((p_pedido+p_entrega+p_borda)-(p_desconto),'@E 999,999.99')
		  endif
          ? ''
          ? '------------------------------------------------'
          ? 'Agradecemos a preferencia, Volte Sempre !'
          ? ''
          ? ''
          ? '------------------------------------------------'
          ? ''
          ? 'Observacoes deste pedido'
          ? '( '+x_observacao_1+' )'
          ? '( '+x_observacao_2+' )'

          ? ''
          ? ''
          ? ''
          ? ''
          ? ''
          ? ''
          ? ''
          ? ''
          ? ''
          ? ''
          ? ''

          SET CONSOLE ON
          SET PRINTER TO
          SET PRINTER OFF
          
       Catch

  		  msgexclamation('A IMPRESSORA está DESLIGADA, por favor verifique','Atenção')
  		  
       End

//     y_flag := .F.

       return(nil)
*-------------------------------------------------------------------------------
static function adiciona_borda()

	   local x_borda := form_delivery.cbo_bordas.value
	   local x_preco := 0
	   
	   dbselectarea('bordas')
	   go top
	   go x_borda
	   x_preco := bordas->preco

	   _total_pedido := ( _total_pedido - _preco_antes_borda ) + ( x_preco )
	   setproperty('form_delivery','label_total','value',trans(_total_pedido,'@E 99,999.99'))

       _preco_antes_borda := x_preco
       
	   return(nil)