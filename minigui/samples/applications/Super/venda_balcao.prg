/*
  sistema     : superchef pizzaria
  programa    : venda balcão
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

memvar _conta_pizza
memvar x_valor_pizza
memvar x_valor_prod
memvar x_hora, x_old

function venda_balcao()

         private _conta_pizza := 1
         
         define window form_balcao;
                at 000,000;
                width getdesktopwidth();
                height getdesktopheight();
                title 'Venda Balcão';
                icon path_imagens+'icone.ico';
                modal;
                on init zera_tabelas()

                * mostrar texto explicando como fechar o pedido
                @ getdesktopheight()-100,000 label label_fechar_pedido;
                          of form_balcao;
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
                          of form_balcao;
                          value 'Telefone';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,010 textbox tbox_telefone;
                          of form_balcao;
                          height 030;
                          width 150;
                          value '';
                          maxlength 015;
                          font 'courier new' size 016;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          on enter procura_cliente('form_balcao','tbox_telefone')

                * botão para cadastrar cliente caso não exista
                @ 020,170 buttonex botao_cadastrar_cliente;
                          parent form_balcao;
                          caption 'Cadastrar novo cliente';
                          width 220 height 040;
                          picture path_imagens+'cadastrar_cliente.bmp';
                          action cadastrar_novo_cliente();
			                 notabstop;
                          tooltip 'Clique aqui para cadastrar um cliente novo, sem precisar sair desta tela'

                * mostrar nome do cliente
                @ 070,010 label label_nome_cliente;
                          of form_balcao;
                          value '';
                          autosize;
                          font 'courier new' size 016;
                          bold;
                          fontcolor BLUE;
                          transparent

                * mostrar o endereço
                @ 100,010 label label_endereco_001;
                          of form_balcao;
                          value '';
                          autosize;
                          font 'courier new' size 014;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 120,010 label label_endereco_002;
                          of form_balcao;
                          value '';
                          autosize;
                          font 'courier new' size 014;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 140,010 label label_endereco_003;
                          of form_balcao;
                          value '';
                          autosize;
                          font 'courier new' size 014;
                          bold;
                          fontcolor _preto_001;
                          transparent
                          
                * histórico do cliente
                @ 180,010 grid grid_historico;
                          parent form_balcao;
                          width 380;
                          height 200;
                          headers {'id cliente','Onde','Data','Hora','Valor R$'};
                          widths {001,100,100,075,090};
                          font 'tahoma' size 010;
                          bold;
                          backcolor _branco_001;
                          fontcolor BLUE;
                          on change mostra_detalhamento_2()
                @ 390,010 grid grid_detalhamento;
                          parent form_balcao;
                          width 380;
                          height (getdesktopheight()-390)-105;
                          headers {'Qtd.','Produto','Valor R$'};
                          widths {080,190,100};
                          font 'tahoma' size 010;
                          bold;
                          backcolor _branco_001;
                          fontcolor BLUE

*-Pizzas------------------------------------------------------------------------
                * escolher código da pizza
                @ 010,410 label label_pizza;
                          of form_balcao;
                          value 'Pizza';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,410 textbox tbox_pizza;
                          of form_balcao;
                          height 030;
                          width 100;
                          value '';
                          maxlength 015;
                          font 'courier new' size 016;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          on enter procura_pizza()
                * mostrar nome da pizza
                @ 030,520 label label_nome_pizza;
                          of form_balcao;
                          value '';
                          autosize;
                          font 'courier new' size 016;
                          bold;
                          fontcolor BLUE;
                          transparent
                * botão para confirmar a escolha da pizza
                @ 030,850 buttonex botao_confirmar_pizza;
                          parent form_balcao;
                          caption 'Selecionar pizza';
                          width 165 height 040;
                          picture path_imagens+'adicionar.bmp';
                          action gravar_adicionar();
                          tooltip 'Clique aqui para confirmar a pizza selecionada'

                * mostrar pizzas já selecionadas
                @ 060,410 label label_pizza_selecionada;
                          of form_balcao;
                          value 'Pizzas selecionadas';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 080,410 browse grid_pizzas;
                          parent form_balcao;
                          width getdesktopwidth()-420;
                          height 200;
                          headers {'id produto','Seq.','Nome','Tamanho','Preço R$'};
                          widths {001,100,190,180,100};
                          workarea tmp_pizza;
                          fields {'tmp_pizza->id_produto','tmp_pizza->sequencia','tmp_pizza->nome','tmp_pizza->tamanho','trans(tmp_pizza->preco,"@E 99,999.99")'};
                          value 1;
                          font 'tahoma' size 010;
                          bold;
                          backcolor _amarelo_001;
                          fontcolor _preto_001
                @ 285,410 label label_observacoes;
                          of form_balcao;
                          value 'Observações para a montagem da(s) pizza(s)';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 305,410 textbox tbox_observacoes;
                          of form_balcao;
                          height 030;
                          width 420;
                          value '';
                          maxlength 030;
                          font 'courier new' size 012;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          uppercase

                * botão para excluir ítem na escolha das pizzas
                @ 285,850 buttonex botao_excluir_pizza;
                          parent form_balcao;
                          caption 'Excluir ítem';
                          width 165 height 040;
                          picture path_imagens+'excluir_item.bmp';
                          action excluir_pizza();
			                 notabstop;
                          tooltip 'Clique aqui para excluir uma pizza selecionada acima'

                * explicação de como finalizar as pizzas
                @ 340,410 label label_instrucao_001;
                          of form_balcao;
                          value 'tecle F5 após completar a composição de 1 (uma) pizza, para finalizá-la,';
                          autosize;
                          font 'verdana' size 010;
                          bold;
                          fontcolor _cinza_001;
                          transparent
                @ 360,410 label label_instrucao_002;
                          of form_balcao;
                          value 'ou, para vender mais de 1 (uma) pizza, finalize uma para começar outra.';
                          autosize;
                          font 'verdana' size 010;
                          bold;
                          fontcolor _cinza_001;
                          transparent

*-Produtos----------------------------------------------------------------------
                * escolher código do produto
                @ 400,410 label label_produto;
                          of form_balcao;
                          value 'Produto';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 420,410 textbox tbox_produto;
                          of form_balcao;
                          height 030;
                          width 100;
                          value '';
                          maxlength 015;
                          font 'courier new' size 016;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          on enter procura_produto()
                @ 420,520 label label_nome_produto;
                          of form_balcao;
                          value '';
                          autosize;
                          font 'courier new' size 016;
                          bold;
                          fontcolor BLUE;
                          transparent

                * quantidade
                @ 450,410 label label_quantidade;
                          of form_balcao;
                          value 'Quantidade';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 470,410 textbox tbox_quantidade;
                          of form_balcao;
                          height 030;
                          width 100;
                          value 0;
                          font 'courier new' size 016;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          numeric;
                          on enter verifica_zero()

                * preço
                @ 450,530 label label_preco;
                          of form_balcao;
                          value 'Preço R$';
                          autosize;
                          font 'courier new' size 012;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 470,530 getbox tbox_preco;
                          of form_balcao;
                          height 030;
                          width 130;
                          value 0;
                          font 'courier new' size 016;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@E 9,999.99'

                * botão para confirmar a escolha do produto
                @ 460,670 buttonex botao_confirmar_produto;
                          parent form_balcao;
                          caption 'Selecionar produto';
                          width 165 height 040;
                          picture path_imagens+'adicionar.bmp';
                          action gravar_produto();
                          tooltip 'Clique aqui para confirmar o produto selecionado'

                * produtos já selecionados
                @ 510,410 browse grid_produtos;
                          parent form_balcao;
                          width getdesktopwidth()-420;
                          height getdesktopheight()-615;
                          headers {'id produto','Qtd','Produto','Unitário R$','Subtotal R$'};
                          widths {001,080,210,140,140};
                          workarea tmp_produto;
                          fields {'tmp_produto->produto','tmp_produto->qtd','tmp_produto->nome','trans(tmp_produto->unitario,"@E 9,999.99")','trans(tmp_produto->subtotal,"@E 99,999.99")'};
                          value 1;
                          font 'tahoma' size 010;
                          bold;
                          backcolor _amarelo_001;
                          fontcolor _preto_001

                * botão para excluir produto já selecionado
                @ 460,850 buttonex botao_excluir_produto;
                          parent form_balcao;
                          caption 'Excluir produto';
                          width 165 height 040;
                          picture path_imagens+'excluir_item.bmp';
                          action excluir_produto();
			                 notabstop;
                          tooltip 'Clique aqui para excluir um produto já selecionado'

                on key F5 action fecha_pizza()
                on key F9 action fecha_pedido()
                on key escape action thiswindow.release

         end window

         form_balcao.maximize
         form_balcao.activate

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
                setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
                setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
                setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                if !empty(creg)
                   setproperty(cform,ctextbtn,'value',creg)
                endif
                historico_cliente_2(__codigo_cliente)
                form_balcao.tbox_pizza.setfocus
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
                setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
                setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
                setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                if !empty(creg)
                   setproperty(cform,ctextbtn,'value',creg)
                endif
                historico_cliente_2(__codigo_cliente)
                form_balcao.tbox_pizza.setfocus
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
                   setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
                   setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                   setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
                   setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                   historico_cliente_2(__codigo_cliente)
                   form_balcao.tbox_pizza.setfocus
                   exit
                endif
                dbselectarea('clientes')
                clientes->(ordsetfocus('celular'))
                clientes->(dbgotop())
                clientes->(dbseek(nreg_02))
                if found()
                   __codigo_cliente := clientes->codigo
                   setproperty('form_balcao','label_nome_cliente','value',clientes->nome)
                   setproperty('form_balcao','label_endereco_001','value',alltrim(clientes->endereco)+', '+alltrim(clientes->numero))
                   setproperty('form_balcao','label_endereco_002','value',alltrim(clientes->complem))
                   setproperty('form_balcao','label_endereco_003','value',alltrim(clientes->bairro)+', '+alltrim(clientes->cidade))
                   historico_cliente_2(__codigo_cliente)
                   form_balcao.tbox_pizza.setfocus
                   exit
                else
                   msgalert('Telefone não está cadastrado','Atenção')
                   form_balcao.tbox_telefone.setfocus
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

       local x_codigo := form_balcao.tbox_produto.value

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
                form_balcao.tbox_produto.setfocus
                return(nil)
             endif
          else
             setproperty('form_balcao','label_nome_produto','value',produtos->nome_longo)
             setproperty('form_balcao','tbox_preco','value',produtos->vlr_venda)
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

       delete item all from grid_pesquisa of form_pesquisa

       dbselectarea('produtos')
       produtos->(ordsetfocus('nome_longo'))
       produtos->(dbgotop())

       while .not. eof()
             if !produtos->pizza
                add item {produtos->codigo,alltrim(produtos->nome_longo),trans(produtos->vlr_venda,'@E 999,999.99')} to grid_pesquisa of form_pesquisa
             endif
             produtos->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_informacao_produto()

       local x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
       local x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)
       local x_preco  := 0
       
       setproperty('form_balcao','tbox_produto','value',alltrim(x_codigo))
       setproperty('form_balcao','label_nome_produto','value',alltrim(x_nome))

       dbselectarea('produtos')
       produtos->(ordsetfocus('codigo'))
       produtos->(dbgotop())
       produtos->(dbseek(x_codigo))
       if found()
          x_preco := produtos->vlr_venda
       endif
       setproperty('form_balcao','tbox_preco','value',x_preco)
       
       form_pesquisa.release

       return(nil)
*-------------------------------------------------------------------------------
static function procura_pizza()

       local x_codigo := form_balcao.tbox_pizza.value

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
                form_balcao.tbox_pizza.setfocus
                return(nil)
             endif
          else
             setproperty('form_balcao','label_nome_pizza','value',produtos->nome_longo)
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

       delete item all from grid_pesquisa of form_pesquisa

       dbselectarea('produtos')
       produtos->(ordsetfocus('nome_longo'))
       produtos->(dbgotop())

       while .not. eof()
             if produtos->pizza
                add item {produtos->codigo,alltrim(produtos->nome_longo)+iif(produtos->promocao,' (promoção)','')} to grid_pesquisa of form_pesquisa
             endif
             produtos->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_informacao()

       local x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
       local x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)

       setproperty('form_balcao','tbox_pizza','value',alltrim(x_codigo))
       setproperty('form_balcao','label_nome_pizza','value',alltrim(x_nome))
       
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
          setproperty('form_balcao','tbox_telefone','value',form_incluir_novo_cliente.tbox_002.value)
          form_balcao.tbox_telefone.setfocus
       else
          setproperty('form_balcao','tbox_telefone','value',form_incluir_novo_cliente.tbox_003.value)
          form_balcao.tbox_telefone.setfocus
       endif
       
       return(nil)
*-------------------------------------------------------------------------------
static function gravar_adicionar()

       dbselectarea('tmp_pizza')
       tmp_pizza->(dbappend())
       tmp_pizza->id_produto := form_balcao.tbox_pizza.value
       tmp_pizza->nome       := form_balcao.label_nome_pizza.value
       tmp_pizza->(dbcommit())
       tmp_pizza->(dbgotop())

       form_balcao.grid_pizzas.refresh
       form_balcao.grid_pizzas.setfocus
	    form_balcao.grid_pizzas.value := recno()

       form_balcao.tbox_pizza.value := ''
       form_balcao.tbox_pizza.setfocus
       
       return(nil)
*-------------------------------------------------------------------------------
static function gravar_produto()

       dbselectarea('tmp_produto')
       tmp_produto->(dbappend())
       tmp_produto->produto  := form_balcao.tbox_produto.value
       tmp_produto->nome     := form_balcao.label_nome_produto.value
       tmp_produto->qtd      := form_balcao.tbox_quantidade.value
       tmp_produto->unitario := form_balcao.tbox_preco.value
       tmp_produto->subtotal := (form_balcao.tbox_preco.value*form_balcao.tbox_quantidade.value)
       tmp_produto->(dbcommit())
       tmp_produto->(dbgotop())

       form_balcao.grid_produtos.refresh
       form_balcao.grid_produtos.setfocus
	    form_balcao.grid_produtos.value := recno()

       form_balcao.tbox_produto.value := ''
       form_balcao.tbox_produto.setfocus

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

       form_balcao.grid_pizzas.refresh
	    form_balcao.grid_pizzas.setfocus
	    form_balcao.grid_pizzas.value := recno()
	    
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

       form_balcao.grid_produtos.refresh
	    form_balcao.grid_produtos.setfocus
	    form_balcao.grid_produtos.value := recno()

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
       form_balcao.grid_pizzas.refresh
       form_balcao.grid_pizzas.setfocus
       form_balcao.tbox_observacoes.setfocus
       
       return(nil)
*-------------------------------------------------------------------------------
static function verifica_zero()

       local x_qtd := form_balcao.tbox_quantidade.value
       
       if empty(x_qtd)
          form_balcao.tbox_quantidade.setfocus
          return(nil)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function fecha_pedido()

       local x_old_pizza      := space(10)
       local x_old_valor      := 0
       local x_total_pedido   := 0
       local x_total_recebido := 0
       private x_valor_pizza  := 0
       private x_valor_prod   := 0

       dbselectarea('tmp_pizza')
       tmp_pizza->(dbgotop())
       if eof()
          msgstop('Nenhuma pizza foi vendida','Atenção')
       else
          while .not. eof()
                x_old_pizza := tmp_pizza->sequencia
                x_old_valor := tmp_pizza->preco
                tmp_pizza->(dbskip())
                if tmp_pizza->sequencia <> x_old_pizza
                   x_valor_pizza := (x_valor_pizza+x_old_valor)
                endif
          end
       endif

       dbselectarea('tmp_produto')
       tmp_produto->(dbgotop())
       if eof()
          msgstop('Nenhum produto foi vendido','Atenção')
       else
          while .not. eof()
                x_valor_prod := (x_valor_prod+tmp_produto->subtotal)
                tmp_produto->(dbskip())
          end
       endif

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
                        on change setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'));
                        on lostfocus setproperty('form_fecha_pedido','label_005_valor','value',trans((x_valor_pizza+x_valor_prod)-form_fecha_pedido.tbox_desconto.value,'@E 999,999.99'))
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
                        on lostfocus calcula_final()

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
              @ 460,115 buttonex botao_ok;
                        parent form_fecha_pedido;
                        caption 'Fechar pedido';
                        width 150 height 040;
                        picture path_imagens+'img_pedido.bmp';
                        action fechamento_geral();
                        tooltip 'Clique aqui para finalizar o pedido'
              @ 460,270 buttonex botao_voltar;
                        parent form_fecha_pedido;
                        caption 'Voltar para tela anterior';
                        width 220 height 040;
                        picture path_imagens+'img_sair.bmp';
                        action form_fecha_pedido.release;
                        tooltip 'Clique aqui para voltar a vender'

              on key escape action thiswindow.release
              
       end window
       
       form_fecha_pedido.center
       form_fecha_pedido.activate
       
       return(nil)
*-------------------------------------------------------------------------------
static function calcula_final()

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
       x_val_003 := 0
       x_val_004 := form_fecha_pedido.tbox_desconto.value
       x_val_005 := form_fecha_pedido.tbox_fr001.value
       x_val_006 := form_fecha_pedido.tbox_fr002.value
       x_val_007 := form_fecha_pedido.tbox_fr003.value

       x_total    := (x_val_001+x_val_002+x_val_003)-(x_val_004)
       x_recebido := (x_val_005+x_val_006+x_val_007)
       x_troco    := (x_recebido-x_total)

       setproperty('form_fecha_pedido','label_011_valor','value',trans(x_recebido,'@E 999,999.99'))
       setproperty('form_fecha_pedido','label_012_valor','value',trans(x_troco,'@E 999,999.99'))
       
       return(nil)
*-------------------------------------------------------------------------------
static function fechamento_geral()

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
       x_val_003     := 0
       x_val_004     := form_fecha_pedido.tbox_desconto.value
       x_cod_forma_1 := form_fecha_pedido.combo_1.value
       x_cod_forma_2 := form_fecha_pedido.combo_2.value
       x_cod_forma_3 := form_fecha_pedido.combo_3.value
       x_val_005     := form_fecha_pedido.tbox_fr001.value
       x_val_006     := form_fecha_pedido.tbox_fr002.value
       x_val_007     := form_fecha_pedido.tbox_fr003.value

       x_total    := (x_val_001+x_val_002+x_val_003)-(x_val_004)
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
       caixa->historico := 'Venda Balcão'
       caixa->entrada   := x_recebido
       caixa->saida     := 0
       caixa->(dbcommit())

       * baixar os produtos
       
       dbselectarea('tmp_produto')
       tmp_produto->(dbgotop())
       while .not. eof()
             dbselectarea('produtos')
             produtos->(ordsetfocus('codigo'))
             produtos->(dbgotop())
             produtos->(dbseek(tmp_produto->produto))
             if found()
                if lock_reg()
                   produtos->qtd_estoq := produtos->qtd_estoq - tmp_produto->qtd
                   produtos->(dbcommit())
                endif
             endif
             dbselectarea('tmp_produto')
             tmp_produto->(dbskip())
       end

       * baixar matéria prima

       x_old := space(10)
       
       dbselectarea('tmp_pizza')
       tmp_pizza->(dbgotop())
       while .not. eof()
             dbselectarea('produto_composto')
             produto_composto->(ordsetfocus('id_produto'))
             produto_composto->(dbgotop())
             produto_composto->(dbseek(tmp_pizza->id_produto))
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
             dbselectarea('tmp_pizza')
             tmp_pizza->(dbskip())
       end

       * ultimas compras do cliente

       x_hora := space(08)
       x_hora := time()
       
       dbselectarea('ultimas_compras')
       ultimas_compras->(dbappend())
       ultimas_compras->id_cliente := __codigo_cliente
       ultimas_compras->data       := date()
       ultimas_compras->hora       := x_hora
       ultimas_compras->onde       := 3 //1=delivery 2=mesa 3=balcão
       ultimas_compras->valor      := x_total
       ultimas_compras->(dbcommit())

       * detalhamento - ultimas compras do cliente

       dbselectarea('tmp_produto')
       tmp_produto->(dbgotop())
       while .not. eof()
             dbselectarea('detalhamento_compras')
             detalhamento_compras->(dbappend())
             detalhamento_compras->id_cliente := __codigo_cliente
             detalhamento_compras->data       := date()
             detalhamento_compras->hora       := x_hora
             detalhamento_compras->id_prod    := tmp_produto->produto
             detalhamento_compras->qtd        := tmp_produto->qtd
             detalhamento_compras->unitario   := tmp_produto->unitario
             detalhamento_compras->subtotal   := tmp_produto->subtotal
             detalhamento_compras->(dbcommit())
             dbselectarea('tmp_produto')
             tmp_produto->(dbskip())
       end
       dbselectarea('tmp_pizza')
       tmp_pizza->(dbgotop())
       while .not. eof()
             dbselectarea('detalhamento_compras')
             detalhamento_compras->(dbappend())
             detalhamento_compras->id_cliente := __codigo_cliente
             detalhamento_compras->data       := date()
             detalhamento_compras->hora       := x_hora
             detalhamento_compras->id_prod    := tmp_pizza->id_produto
             detalhamento_compras->subtotal   := tmp_pizza->preco
             detalhamento_compras->(dbcommit())
             dbselectarea('tmp_pizza')
             tmp_pizza->(dbskip())
       end
       
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
       entrega->origem   := 'Balcão'
       entrega->situacao := 'Montando'
       entrega->vlr_taxa := 0
       entrega->(dbcommit())

       * fechar as janelas
       
       form_fecha_pedido.release
       form_balcao.release
       
       return(nil)
*-------------------------------------------------------------------------------
static function historico_cliente_2(parametro)

       delete item all from grid_historico of form_balcao

       dbselectarea('ultimas_compras')
       ultimas_compras->(ordsetfocus('id_cliente'))
       ultimas_compras->(dbgotop())
       ultimas_compras->(dbseek(parametro))

       if found()
          while .T.
                add item {str(ultimas_compras->id_cliente,6),a_onde[ultimas_compras->onde],dtoc(ultimas_compras->data),alltrim(ultimas_compras->hora),trans(ultimas_compras->valor,'@E 999,999.99')} to grid_historico of form_balcao
                ultimas_compras->(dbskip())
                if ultimas_compras->id_cliente <> parametro
                   exit
                endif
          end
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_detalhamento_2()

       local x_id      := valor_coluna('grid_historico','form_balcao',1)
       local x_data    := valor_coluna('grid_historico','form_balcao',3)
       local x_hora    := alltrim(valor_coluna('grid_historico','form_balcao',4))
       local x_data_2  := ctod(x_data)
       local x_chave   := x_id+dtos(x_data_2)+x_hora
       local parametro := val(x_id)

       delete item all from grid_detalhamento of form_balcao

       dbselectarea('detalhamento_compras')
       detalhamento_compras->(ordsetfocus('id'))
       detalhamento_compras->(dbgotop())
       detalhamento_compras->(dbseek(x_chave))

       if found()
          while .T.
                add item {str(detalhamento_compras->qtd,6),acha_produto(detalhamento_compras->id_prod),trans(detalhamento_compras->subtotal,'@E 999,999.99')} to grid_detalhamento of form_balcao
                detalhamento_compras->(dbskip())
                if detalhamento_compras->id_cliente <> parametro
                   exit
                endif
          end
       endif

       return(nil)