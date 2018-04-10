/*
  sistema     : superchef pizzaria
  programa    : compras - entradas no estoque de produtos e matéria prima
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function compras()

         define window form_compras;
                at 000,000;
                width 1000;
                height 680;
                title 'Compras / Entrada Estoque ( Produtos e Matéria Prima )';
                icon path_imagens+'icone.ico';
                modal;
                nosize;
                on init zera_temps()

                * linhas separadoras
                define label label_sep_001
                       col 000
                       row 140
                       value ''
                       width 1000
                       height 002
                       transparent .F.
                       backcolor _cinza_002
                end label
                define label label_sep_002
                       col 000
                       row 590
                       value ''
                       width 1000
                       height 002
                       transparent .F.
                       backcolor _cinza_002
                end label
                define label label_sep_003
                       col 495
                       row 140
                       value ''
                       width 002
                       height 450
                       transparent .F.
                       backcolor _cinza_002
                end label

                *--------------------
                
                * solicita fornecedor
                @ 010,005 label lbl_001;
                          of form_compras;
                          value 'Fornecedor';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,005 textbox tbox_001;
                          of form_compras;
                          height 027;
                          width 060;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          numeric;
                          on enter procura_fornecedor('form_compras','tbox_001')
                @ 030,070 label lbl_nome_fornecedor;
                          of form_compras;
                          value '';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _azul_001;
                          transparent

                * solicita forma de pagamento
                @ 010,400 label lbl_004;
                          of form_compras;
                          value 'Forma de pagamento';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,400 textbox tbox_004;
                          of form_compras;
                          height 027;
                          width 060;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          numeric;
                          on enter procura_forma_pagamento('form_compras','tbox_004')
                @ 030,470 label lbl_nome_forma_pagamento;
                          of form_compras;
                          value '';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _azul_001;
                          transparent

                * solicita número do documento (nf/recibo/etc)
                @ 010,650 label lbl_documento;
                          of form_compras;
                          value 'Nº do documento';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,650 textbox tbox_documento;
                          of form_compras;
                          height 027;
                          width 200;
                          value '';
                          maxlength 020;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          uppercase

                * número de parcelas
                @ 070,005 label lbl_005;
                          of form_compras;
                          value 'Nº de parcelas';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 070,110 getbox tbox_005;
                          of form_compras;
                          height 027;
                          width 060;
                          value 1;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@R 999'

                * vencimento
                @ 070,180 label lbl_006;
                          of form_compras;
                          value 'Data de vencimento (se for uma única parcela) ou Data início da primeira parcela';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 070,715 textbox tbox_006;
                          of form_compras;
                          height 027;
                          width 100;
                          value date();
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          date
                          
                * dias entre as parcelas
                @ 100,180 label lbl_007;
                          of form_compras;
                          value 'Caso a compra seja parcelada, digite a quantidade de dias entre as parcelas';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 120,180 label lbl_008;
                          of form_compras;
                          value 'para que o programa possa calcular os vencimentos futuros.';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 110,715 getbox tbox_008;
                          of form_compras;
                          height 027;
                          width 060;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@R 999'

                *--------------------*
                *                    *
                * compra de produtos *
                *                    *
                *--------------------*

                * escolher código do produto
                @ 150,005 label label_produto;
                          of form_compras;
                          value 'Produto';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 170,005 textbox tbox_produto;
                          of form_compras;
                          height 030;
                          width 060;
                          value '';
                          maxlength 015;
                          font 'tahoma' size 010;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          on enter procura_produto_2()
                @ 170,075 label label_nome_produto;
                          of form_compras;
                          value '';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor BLUE;
                          transparent
                * quantidade
                @ 210,005 label lbl_002;
                          of form_compras;
                          value 'Quantidade';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 230,005 getbox tbox_002;
                          of form_compras;
                          height 027;
                          width 120;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@R 999999'
                * valor da compra
                @ 210,135 label lbl_003;
                          of form_compras;
                          value 'Valor Unitário R$';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 230,135 getbox tbox_003;
                          of form_compras;
                          height 027;
                          width 120;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@E 999,999.99'
                * botão para confirmar
                @ 217,265 buttonex botao_confirmar_001;
                          parent form_compras;
                          caption 'Confirma';
                          width 115 height 040;
                          picture path_imagens+'adicionar.bmp';
                          action gravar_produto()
                * botão para excluir
                @ 217,385 buttonex botao_excluir_produto;
                          parent form_compras;
                          caption 'Excluir';
                          width 100 height 040;
                          picture path_imagens+'excluir_item.bmp';
                          action excluir_produto();
			                 notabstop
                * grid
                define grid grid_produtos
                       parent form_compras
                       col 005
                       row 265
                       width 480
                       height 320
                       headers {'id','Fornecedor','Produto','Qtd.','Unitário R$','Subtotal R$'}
                       widths {001,250,200,100,120,120}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                end grid

                *-------------------------*
                *                         *
                * compra de matéria prima *
                *                         *
                *-------------------------*

                * escolher código da matéria prima
                @ 150,505 label label_mprima;
                          of form_compras;
                          value 'Matéria prima';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 170,505 textbox tbox_mprima;
                          of form_compras;
                          height 027;
                          width 060;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          numeric;
                          on enter procura_mprima_2('form_compras','tbox_mprima')
                @ 170,570 label lbl_nome_mprima;
                          of form_compras;
                          value '';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _azul_001;
                          transparent
                * quantidade
                @ 210,505 label lbl_002_2;
                          of form_compras;
                          value 'Quantidade';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 230,505 getbox tbox_002_2;
                          of form_compras;
                          height 027;
                          width 120;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@R 999,999.999'
                * valor da compra
                @ 210,635 label lbl_003_2;
                          of form_compras;
                          value 'Valor Unitário R$';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 230,635 getbox tbox_003_2;
                          of form_compras;
                          height 027;
                          width 120;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@E 999,999.99'
                * botão para confirmar
                @ 217,765 buttonex botao_confirmar_002;
                          parent form_compras;
                          caption 'Confirma';
                          width 115 height 040;
                          picture path_imagens+'adicionar.bmp';
                          action gravar_mprima()
                * botão para excluir
                @ 217,885 buttonex botao_excluir_mprima;
                          parent form_compras;
                          caption 'Excluir';
                          width 100 height 040;
                          picture path_imagens+'excluir_item.bmp';
                          action excluir_mprima();
			                 notabstop
                define grid grid_materia_prima
                       parent form_compras
                       col 505
                       row 265
                       width 485
                       height 320
                       headers {'id','Fornecedor','Matéria Prima','Qtd.','Unitário R$','Subtotal R$'}
                       widths {001,250,200,100,120,120}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                end grid

                *-------------------------------
                
                @ 595,635 buttonex botao_gravar;
                          parent form_compras;
                          picture path_imagens+'img_salvar.bmp';
                          caption 'Gravar as informações';
                          width 200 height 050;
                          action gravar_compras();
                          bold;
                          tooltip 'Clique aqui para gravar todas as informações'
                @ 595,840 buttonex botao_sair;
                          parent form_compras;
                          picture path_imagens+'img_sair.bmp';
                          caption 'Sair desta tela';
                          width 150 height 050;
                          action form_compras.release;
                          bold;
                          tooltip 'Sair desta tela sem gravar informações'

                on key escape action thiswindow.release

         end window

         form_compras.center
         form_compras.activate

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
          creg := getcode_fornecedor(getproperty(cform,ctextbtn,'value'))
          dbselectarea('fornecedores')
          fornecedores->(ordsetfocus('codigo'))
          fornecedores->(dbgotop())
          fornecedores->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_compras','lbl_nome_fornecedor','value',fornecedores->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_fornecedor(value)

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
                     onchange find_fornecedor()
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
static function find_fornecedor()

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
          creg := getcode_forma_pagamento(getproperty(cform,ctextbtn,'value'))
          dbselectarea('formas_pagamento')
          formas_pagamento->(ordsetfocus('codigo'))
          formas_pagamento->(dbgotop())
          formas_pagamento->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_compras','lbl_nome_forma_pagamento','value',formas_pagamento->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_forma_pagamento(value)

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
                     onchange find_forma_pagamento()
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
static function find_forma_pagamento()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       formas_pagamento->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif formas_pagamento->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := formas_pagamento->(recno())
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function procura_produto_2()

       local x_codigo := form_compras.tbox_produto.value

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
                mostra_listagem_produto_2()
                return(nil)
             else
                form_compras.tbox_produto.setfocus
                return(nil)
             endif
          else
             setproperty('form_compras','label_nome_produto','value',produtos->nome_longo)
             return(nil)
          endif
       else
          mostra_listagem_produto_2()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_listagem_produto_2()

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
                     ondblclick mostra_informacao_produto_2()
              end grid

              on key escape action thiswindow.release

       end window

       separa_produto_2()
       form_pesquisa.grid_pesquisa.setfocus
       form_pesquisa.grid_pesquisa.value := 1

       form_pesquisa.center
       form_pesquisa.activate

       return(nil)
*-------------------------------------------------------------------------------
static function separa_produto_2()

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
static function mostra_informacao_produto_2()

       local x_codigo := valor_coluna('grid_pesquisa','form_pesquisa',1)
       local x_nome   := valor_coluna('grid_pesquisa','form_pesquisa',2)
       local x_preco  := 0

       setproperty('form_compras','tbox_produto','value',alltrim(x_codigo))
       setproperty('form_compras','label_nome_produto','value',alltrim(x_nome))

       dbselectarea('produtos')
       produtos->(ordsetfocus('codigo'))
       produtos->(dbgotop())
       produtos->(dbseek(x_codigo))
       if found()
          x_preco := produtos->vlr_venda
       endif

       form_pesquisa.release

       return(nil)
*-------------------------------------------------------------------------------
static function procura_mprima_2(cform,ctextbtn)

       local flag    := .F.
       local creg    := ''
       local nreg_01 := getproperty(cform,ctextbtn,'value')
       local nreg_02 := nreg_01

       dbselectarea('materia_prima')
       materia_prima->(ordsetfocus('codigo'))
       materia_prima->(dbgotop())
       materia_prima->(dbseek(nreg_02))
       if found()
          flag := .T.
       else
          creg := getcode_materia_prima_2(getproperty(cform,ctextbtn,'value'))
          dbselectarea('materia_prima')
          materia_prima->(ordsetfocus('codigo'))
          materia_prima->(dbgotop())
          materia_prima->(dbseek(creg))
          if found()
             flag := .T.
          endif
       endif

       if flag
          setproperty('form_compras','lbl_nome_mprima','value',materia_prima->nome)
       endif

       if !empty(creg)
          setproperty(cform,ctextbtn,'value',creg)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function getcode_materia_prima_2(value)

       local creg := ''
       local nreg := 1

       dbselectarea('materia_prima')
       materia_prima->(ordsetfocus('nome'))
       materia_prima->(dbgotop())

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
                     onchange find_materia_prima_2()
                     uppercase .T.
              end textbox

              define browse browse_pesquisa
                     row 002
                     col 002
                     width 480
                     height 430
                     headers {'Código','Nome'}
                     widths {080,370}
                     workarea materia_prima
                     fields {'materia_prima->codigo','materia_prima->nome'}
                     value nreg
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     backcolor _ciano_001
                     nolines .T.
                     lock .T.
                     readonly {.T.,.T.}
                     justify {BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT}
                     on dblclick (creg:=materia_prima->codigo,thiswindow.release)
              end browse

              on key escape action thiswindow.release

       end window

       form_pesquisa.browse_pesquisa.setfocus

       form_pesquisa.center
       form_pesquisa.activate

       return(creg)
*-------------------------------------------------------------------------------
static function find_materia_prima_2()

       local pesquisa := alltrim(form_pesquisa.txt_pesquisa.value)

       materia_prima->(dbgotop())

       if pesquisa == ''
          return(nil)
       elseif materia_prima->(dbseek(pesquisa))
          form_pesquisa.browse_pesquisa.value := materia_prima->(recno())
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function gravar_produto()

       local x_id := substr(alltrim(str(HB_RANDOM(4000385713,9999999999))),1,10)

       tmp_cpa1->(dbappend())
       tmp_cpa1->id         := x_id
       tmp_cpa1->fornecedor := form_compras.tbox_001.value
       tmp_cpa1->forma_pag  := form_compras.tbox_004.value
       tmp_cpa1->num_parc   := form_compras.tbox_005.value
       tmp_cpa1->data_venc  := form_compras.tbox_006.value
       tmp_cpa1->dias_parc  := form_compras.tbox_008.value
       tmp_cpa1->produto    := form_compras.tbox_produto.value
       tmp_cpa1->qtd        := form_compras.tbox_002.value
       tmp_cpa1->vlr_unit   := form_compras.tbox_003.value
       tmp_cpa1->num_doc    := form_compras.tbox_documento.value
       tmp_cpa1->(dbcommit())

       atualiza_produtos()
       
       form_compras.tbox_produto.setfocus

       return(nil)
*-------------------------------------------------------------------------------
static function atualiza_produtos()

       delete item all from grid_produtos of form_compras

       dbselectarea('tmp_cpa1')
       tmp_cpa1->(dbgotop())

       while .not. eof()
             add item {tmp_cpa1->id,acha_fornecedor(tmp_cpa1->fornecedor),acha_produto(tmp_cpa1->produto),trans(tmp_cpa1->qtd,'@R 999999'),trans(tmp_cpa1->vlr_unit,'@E 99,999.99'),trans(tmp_cpa1->qtd*tmp_cpa1->vlr_unit,'@E 999,999.99')} to grid_produtos of form_compras
             tmp_cpa1->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function excluir_produto()

       local x_id := valor_coluna('grid_produtos','form_compras',1)

       dbselectarea('tmp_cpa1')
       tmp_cpa1->(dbgotop())

       while .not. eof()
             if tmp_cpa1->id == x_id
                if msgyesno('Confirma ?','Excluir')
                   tmp_cpa1->(dbdelete())
                   exit
                endif
             endif
             tmp_cpa1->(dbskip())
       end

       atualiza_produtos()
       
       return(nil)
*-------------------------------------------------------------------------------
static function gravar_mprima()

       local x_id := substr(alltrim(str(HB_RANDOM(4000385713,9999999999))),1,10)

       tmp_cpa2->(dbappend())
       tmp_cpa2->id         := x_id
       tmp_cpa2->fornecedor := form_compras.tbox_001.value
       tmp_cpa2->forma_pag  := form_compras.tbox_004.value
       tmp_cpa2->num_parc   := form_compras.tbox_005.value
       tmp_cpa2->data_venc  := form_compras.tbox_006.value
       tmp_cpa2->dias_parc  := form_compras.tbox_008.value
       tmp_cpa2->mat_prima  := form_compras.tbox_mprima.value
       tmp_cpa2->qtd        := form_compras.tbox_002_2.value
       tmp_cpa2->vlr_unit   := form_compras.tbox_003_2.value
       tmp_cpa2->num_doc    := form_compras.tbox_documento.value
       tmp_cpa2->(dbcommit())

       atualiza_mprima()

       form_compras.tbox_mprima.setfocus

       return(nil)
*-------------------------------------------------------------------------------
static function atualiza_mprima()

       delete item all from grid_materia_prima of form_compras

       dbselectarea('tmp_cpa2')
       tmp_cpa2->(dbgotop())

       while .not. eof()
             add item {tmp_cpa2->id,acha_fornecedor(tmp_cpa2->fornecedor),acha_mprima(tmp_cpa2->mat_prima),trans(tmp_cpa2->qtd,'@R 99,999.999'),trans(tmp_cpa2->vlr_unit,'@E 99,999.99'),trans(tmp_cpa2->qtd*tmp_cpa2->vlr_unit,'@E 999,999.99')} to grid_materia_prima of form_compras
             tmp_cpa2->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function excluir_mprima()

       local x_id := valor_coluna('grid_materia_prima','form_compras',1)

       dbselectarea('tmp_cpa2')
       tmp_cpa2->(dbgotop())

       while .not. eof()
             if tmp_cpa2->id == x_id
                if msgyesno('Confirma ?','Excluir')
                   tmp_cpa2->(dbdelete())
                   exit
                endif
             endif
             tmp_cpa2->(dbskip())
       end

       atualiza_mprima()

       return(nil)
*-------------------------------------------------------------------------------
static function zera_temps()

       dbselectarea('tmp_cpa1')
       zap
       pack

       dbselectarea('tmp_cpa2')
       zap
       pack

       return(nil)
*-------------------------------------------------------------------------------
static function gravar_compras()

       local x_dbf_1            := 0
       local x_dbf_2            := 0
       local x_fornecedor       := 0
       local x_forma_pagamento  := 0
       local x_numero_documento := space(15)
       local x_numero_parcelas  := 0
       local x_data_vencimento  := ctod('  /  /  ')
       local x_dias             := 0
       local x_total            := 0
       local x_i                := 0
       
       dbselectarea('tmp_cpa1')
       tmp_cpa1->(dbgotop())
       if eof()
          x_dbf_1 := 1
       endif

       dbselectarea('tmp_cpa2')
       tmp_cpa2->(dbgotop())
       if eof()
          x_dbf_2 := 1
       endif

       if (x_dbf_1+x_dbf_2) == 2
          msginfo('Não existem informações a serem processadas','Atenção')
          return(nil)
       endif

       * clonar para as tabelas da rede
       
       * produtos
       
       if x_dbf_1 == 0
          dbselectarea('tmp_cpa1')
          tmp_cpa1->(dbgotop())
          while .not. eof()
                dbselectarea('tcompra1')
                tcompra1->(dbappend())
                tcompra1->fornecedor := tmp_cpa1->fornecedor
                tcompra1->forma_pag  := tmp_cpa1->forma_pag
                tcompra1->num_parc   := tmp_cpa1->num_parc
                tcompra1->data_venc  := tmp_cpa1->data_venc
                tcompra1->dias_parc  := tmp_cpa1->dias_parc
                tcompra1->produto    := tmp_cpa1->produto
                tcompra1->qtd        := tmp_cpa1->qtd
                tcompra1->vlr_unit   := tmp_cpa1->vlr_unit
                tcompra1->num_doc    := tmp_cpa1->num_doc
                tcompra1->(dbcommit())
                dbselectarea('tmp_cpa1')
                tmp_cpa1->(dbskip())
          end
       endif

       * matéria prima

       if x_dbf_2 == 0
          dbselectarea('tmp_cpa2')
          tmp_cpa2->(dbgotop())
          while .not. eof()
                dbselectarea('tcompra2')
                tcompra2->(dbappend())
                tcompra2->fornecedor := tmp_cpa2->fornecedor
                tcompra2->forma_pag  := tmp_cpa2->forma_pag
                tcompra2->num_parc   := tmp_cpa2->num_parc
                tcompra2->data_venc  := tmp_cpa2->data_venc
                tcompra2->dias_parc  := tmp_cpa2->dias_parc
                tcompra2->mat_prima  := tmp_cpa2->mat_prima
                tcompra2->qtd        := tmp_cpa2->qtd
                tcompra2->vlr_unit   := tmp_cpa2->vlr_unit
                tcompra2->num_doc    := tmp_cpa2->num_doc
                tcompra2->(dbcommit())
                dbselectarea('tmp_cpa2')
                tmp_cpa2->(dbskip())
          end
       endif
       
       * aumentar quantidade - produto
       
       if x_dbf_1 == 0
          dbselectarea('tmp_cpa1')
          tmp_cpa1->(dbgotop())
          while .not. eof()
                dbselectarea('produtos')
                produtos->(ordsetfocus('codigo'))
                produtos->(dbgotop())
                produtos->(dbseek(tmp_cpa1->produto))
                if found()
                   if lock_reg()
                      produtos->qtd_estoq := produtos->qtd_estoq + tmp_cpa1->qtd
                      produtos->(dbcommit())
                   endif
                endif
                dbselectarea('tmp_cpa1')
                tmp_cpa1->(dbskip())
          end
       endif

       * aumentar quantidade - matéria prima

       if x_dbf_2 == 0
          dbselectarea('tmp_cpa2')
          tmp_cpa2->(dbgotop())
          while .not. eof()
                dbselectarea('materia_prima')
                materia_prima->(ordsetfocus('codigo'))
                materia_prima->(dbgotop())
                materia_prima->(dbseek(tmp_cpa2->mat_prima))
                if found()
                   if lock_reg()
                      materia_prima->qtd := materia_prima->qtd + tmp_cpa2->qtd
                      materia_prima->(dbcommit())
                   endif
                endif
                dbselectarea('tmp_cpa2')
                tmp_cpa2->(dbskip())
          end
       endif

       * contas a pagar - produtos
       
       if x_dbf_1 == 0
          dbselectarea('tmp_cpa1')
          index on fornecedor to indpfor
          go top
          while .not. eof()
                x_fornecedor       := tmp_cpa1->fornecedor
                x_forma_pagamento  := tmp_cpa1->forma_pag
                x_numero_documento := tmp_cpa1->num_doc
                x_numero_parcelas  := tmp_cpa1->num_parc
                x_data_vencimento  := tmp_cpa1->data_venc
                x_dias             := tmp_cpa1->dias_parc
                x_total            := x_total + (tmp_cpa1->qtd*tmp_cpa1->vlr_unit)
                skip
                if tmp_cpa1->fornecedor <> x_fornecedor
                   dbselectarea('contas_pagar')
                   for x_i := 1 to x_numero_parcelas
                       contas_pagar->(dbappend())
                       if x_i > 1
                          contas_pagar->data   := x_data_vencimento + x_dias
                       else
                          contas_pagar->data   := x_data_vencimento
                       endif
                       contas_pagar->valor  := (x_total/x_numero_parcelas)
                       contas_pagar->forma  := x_forma_pagamento
                       contas_pagar->fornec := x_fornecedor
                       contas_pagar->numero := x_numero_documento
                       contas_pagar->id     := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
                       contas_pagar->(dbcommit())
                   next x_i
                endif
          end
       endif

       * contas a pagar - matéria prima

       if x_dbf_2 == 0
          dbselectarea('tmp_cpa2')
          index on fornecedor to indmfor
          go top
          while .not. eof()
                x_fornecedor       := tmp_cpa2->fornecedor
                x_forma_pagamento  := tmp_cpa2->forma_pag
                x_numero_documento := tmp_cpa2->num_doc
                x_numero_parcelas  := tmp_cpa2->num_parc
                x_data_vencimento  := tmp_cpa2->data_venc
                x_dias             := tmp_cpa2->dias_parc
                x_total            := x_total + (tmp_cpa2->qtd*tmp_cpa2->vlr_unit)
                skip
                if tmp_cpa2->fornecedor <> x_fornecedor
                   dbselectarea('contas_pagar')
                   for x_i := 1 to x_numero_parcelas
                       contas_pagar->(dbappend())
                       if x_i > 1
                          contas_pagar->data   := x_data_vencimento + x_dias
                       else
                          contas_pagar->data   := x_data_vencimento
                       endif
                       contas_pagar->valor  := (x_total/x_numero_parcelas)
                       contas_pagar->forma  := x_forma_pagamento
                       contas_pagar->fornec := x_fornecedor
                       contas_pagar->numero := x_numero_documento
                       contas_pagar->id     := substr(alltrim(str(HB_RANDOM(0001240003,9999999999))),1,10)
                       contas_pagar->(dbcommit())
                   next x_i
                endif
          end
       endif

       msginfo('Informações gravadas com sucesso, tecle ENTER','Mensagem')
       
       form_compras.release
       
       return(nil)