/*
  sistema     : superchef pizzaria
  programa    : relatório pizzas mais vendidas - por período
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

memvar x_nome_pizza
memvar x_old_pizza

function relatorio_pizza_001()

         local a_001 := {}

         dbselectarea('produtos')
         produtos->(ordsetfocus('nome'))
         produtos->(dbgotop())
         aadd(a_001,'TODAS AS PIZZAS')
         while .not. eof()
               if produtos->pizza
                  aadd(a_001,produtos->nome_longo)
               endif
               produtos->(dbskip())
         end

         define window form_pizzas_001;
                at 000,000;
                width 400;
                height 250;
                title 'Pizzas mais vendidas';
                icon path_imagens+'icone.ico';
                modal;
                nosize

                @ 010,010 label lbl_001;
                          of form_pizzas_001;
                          value 'Escolha o intervalo de datas';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 080,010 label lbl_002;
                          of form_pizzas_001;
                          value 'Escolha a pizza';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

                @ 040,010 datepicker dp_inicio;
                          parent form_pizzas_001;
                          value date();
                          width 150;
                          height 030;
                          font 'verdana' size 014
                @ 040,170 datepicker dp_final;
                          parent form_pizzas_001;
                          value date();
                          width 150;
                          height 030;
                          font 'verdana' size 014
		          define comboboxex cbo_001
			              row	110
                       col	010
			              width 310
			              height 200
			              items a_001
			              value 1
                end comboboxex

                * linha separadora
                define label linha_rodape
                       col 000
                       row form_pizzas_001.height-090
                       value ''
                       width form_pizzas_001.width
                       height 001
                       backcolor _preto_001
                       transparent .F.
                end label

                * botões
                define buttonex button_ok
                       picture path_imagens+'img_relatorio.bmp'
                       col form_pizzas_001.width-255
                       row form_pizzas_001.height-085
                       width 150
                       height 050
                       caption 'Ok, imprimir'
                       action relatorio()
                       fontbold .T.
                       tooltip 'Gerar o relatório'
                       flat .F.
                       noxpstyle .T.
                end buttonex
                define buttonex button_cancela
                       picture path_imagens+'img_sair.bmp'
                       col form_pizzas_001.width-100
                       row form_pizzas_001.height-085
                       width 090
                       height 050
                       caption 'Voltar'
                       action form_pizzas_001.release
                       fontbold .T.
                       tooltip 'Sair desta tela'
                       flat .F.
                       noxpstyle .T.
                end buttonex

                on key escape action thiswindow.release

         end window

         form_pizzas_001.center
         form_pizzas_001.activate

         return(nil)
*-------------------------------------------------------------------------------
static function relatorio()

       local x_de    := form_pizzas_001.dp_inicio.value
       local x_ate   := form_pizzas_001.dp_final.value
       local x_pizza := form_pizzas_001.cbo_001.value
       
       local p_linha := 051
       local u_linha := 260
       local linha   := p_linha
       local pagina  := 1

       local x_soma_qtd := 0
       local x_codigo_produto := space(10)

       x_nome_pizza := alltrim(form_pizzas_001.cbo_001.item(x_pizza))

       dbselectarea('tmp_pizza_relatorio')
       zap
       pack
       
       dbselectarea('produtos')
       produtos->(ordsetfocus('nome_longo'))
       produtos->(dbgotop())
       produtos->(dbseek(x_nome_pizza))
       if found()
          x_codigo_produto := produtos->codigo
       endif
       
       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)

       if x_pizza == 1 //todas
          dbselectarea('detalhamento_compras')
          index on id_prod to indp001 for data >= x_de .and. data <= x_ate .and. qtd == 0
          go top
          x_old_pizza := space(10)
          x_soma_qtd  := 0
          while .not. eof()

                x_old_pizza := detalhamento_compras->id_prod
                x_soma_qtd  := x_soma_qtd + 1

                detalhamento_compras->(dbskip())

                if detalhamento_compras->id_prod <> x_old_pizza
                   dbselectarea('tmp_pizza_relatorio')
                   append blank
                   replace produto with acha_produto(x_old_pizza)
                   replace qtd with x_soma_qtd
                   dbselectarea('detalhamento_compras')
                   x_soma_qtd := 0
                endif
          end
          dbselectarea('tmp_pizza_relatorio')
          index on qtd to indp002 descend
          go top
          while .not. eof()

                @ linha,020 PRINT tmp_pizza_relatorio->produto FONT 'courier new' SIZE 010
                @ linha,105 PRINT strzero(tmp_pizza_relatorio->qtd,6) FONT 'courier new' SIZE 010

                tmp_pizza_relatorio->(dbskip())

                linha += 5
                
                if linha >= u_linha
                   END PRINTPAGE
                   START PRINTPAGE
                   pagina ++
                   cabecalho(pagina)
                   linha := p_linha
                endif
          end
       else
          dbselectarea('detalhamento_compras')
          index on id_prod to indp001 for data >= x_de .and. data <= x_ate .and. qtd == 0
          go top
          x_old_pizza := space(10)
          x_soma_qtd  := 0
          while .not. eof()

                x_old_pizza := detalhamento_compras->id_prod
                x_soma_qtd  := x_soma_qtd + 1

                detalhamento_compras->(dbskip())

                if detalhamento_compras->id_prod <> x_old_pizza
                   dbselectarea('tmp_pizza_relatorio')
                   append blank
                   replace produto with acha_produto(x_old_pizza)
                   replace qtd with x_soma_qtd
                   dbselectarea('detalhamento_compras')
                   x_soma_qtd := 0
                endif
          end
          dbselectarea('tmp_pizza_relatorio')
          index on qtd to indp002 for alltrim(produto) == alltrim(x_nome_pizza)
          go top
          while .not. eof()

                @ linha,020 PRINT tmp_pizza_relatorio->produto FONT 'courier new' SIZE 010
                @ linha,105 PRINT strzero(tmp_pizza_relatorio->qtd,6) FONT 'courier new' SIZE 010

                tmp_pizza_relatorio->(dbskip())

                linha += 5

                if linha >= u_linha
                   END PRINTPAGE
                   START PRINTPAGE
                   pagina ++
                   cabecalho(pagina)
                   linha := p_linha
                endif
          end
       endif
       
       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       local x_de    := form_pizzas_001.dp_inicio.value
       local x_ate   := form_pizzas_001.dp_final.value
       local x_pizza := form_pizzas_001.cbo_001.value
       x_nome_pizza  := alltrim(form_pizzas_001.cbo_001.item(x_pizza))
       
       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'PIZZAS MAIS VENDIDAS' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
       if x_pizza == 1 //todas
          @ 024,070 PRINT 'Pizza : TODAS' FONT 'courier new' SIZE 014
       else
          @ 024,070 PRINT 'Pizza : '+x_nome_pizza FONT 'courier new' SIZE 014
       endif
       @ 030,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

       @ 041,020 PRINT 'PIZZA' FONT 'courier new' SIZE 010 BOLD
       @ 041,100 PRINT 'QUANTIDADE' FONT 'courier new' SIZE 010 BOLD

       return(nil)
*-------------------------------------------------------------------------------
static function rodape()

       @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
       @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

       return(nil)