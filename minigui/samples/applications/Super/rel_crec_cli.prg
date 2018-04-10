/*
  sistema     : superchef pizzaria
  programa    : relatório movimentação contas a receber - por cliente
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function relatorio_crec_002()

         local a_001 := {}

         dbselectarea('clientes')
         clientes->(ordsetfocus('nome'))
         clientes->(dbgotop())
         while .not. eof()
               aadd(a_001,strzero(clientes->codigo,6)+' - '+clientes->nome)
               clientes->(dbskip())
         end

         define window form_mov_crec_cli;
                at 000,000;
                width 400;
                height 250;
                title 'Contas a Receber por cliente';
                icon path_imagens+'icone.ico';
                modal;
                nosize

                @ 010,010 label lbl_001;
                          of form_mov_crec_cli;
                          value 'Escolha o intervalo de datas';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 080,010 label lbl_002;
                          of form_mov_crec_cli;
                          value 'Escolha o cliente';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

                @ 040,010 datepicker dp_inicio;
                          parent form_mov_crec_cli;
                          value date();
                          width 150;
                          height 030;
                          font 'verdana' size 014
                @ 040,170 datepicker dp_final;
                          parent form_mov_crec_cli;
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
                       row form_mov_crec_cli.height-090
                       value ''
                       width form_mov_crec_cli.width
                       height 001
                       backcolor _preto_001
                       transparent .F.
                end label

                * botões
                define buttonex button_ok
                       picture path_imagens+'img_relatorio.bmp'
                       col form_mov_crec_cli.width-255
                       row form_mov_crec_cli.height-085
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
                       col form_mov_crec_cli.width-100
                       row form_mov_crec_cli.height-085
                       width 090
                       height 050
                       caption 'Voltar'
                       action form_mov_crec_cli.release
                       fontbold .T.
                       tooltip 'Sair desta tela'
                       flat .F.
                       noxpstyle .T.
                end buttonex

                on key escape action thiswindow.release

         end window

         form_mov_crec_cli.center
         form_mov_crec_cli.activate

         return(nil)
*-------------------------------------------------------------------------------
static function relatorio()

       local x_codigo_cliente := 0
       local x_de             := form_mov_crec_cli.dp_inicio.value
       local x_ate            := form_mov_crec_cli.dp_final.value
       local x_cliente        := form_mov_crec_cli.cbo_001.value
       
       local p_linha := 051
       local u_linha := 260
       local linha   := p_linha
       local pagina  := 1

       local x_soma_dia   := 0
       local x_soma_geral := 0
       local x_old_data   := ctod('  /  /  ')

       x_codigo_cliente := val(substr(form_mov_crec_cli.cbo_001.item(x_cliente),1,6))
       
       dbselectarea('contas_receber')
       contas_receber->(ordsetfocus('composto'))
       contas_receber->(dbgotop())
	    ordscope(0,str(x_codigo_cliente,6)+dtos(x_de))
	    ordscope(1,str(x_codigo_cliente,6)+dtos(x_ate))
       contas_receber->(dbgotop())

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             x_old_data := contas_receber->data
             x_soma_dia := x_soma_dia + contas_receber->valor
             
             @ linha,015 PRINT dtoc(contas_receber->data) FONT 'courier new' SIZE 010
             @ linha,040 PRINT acha_cliente(contas_receber->cliente) FONT 'courier new' SIZE 010
             @ linha,120 PRINT acha_forma_recebimento(contas_receber->forma) FONT 'courier new' SIZE 010
             @ linha,160 PRINT trans(contas_receber->valor,'@E 999,999.99') FONT 'courier new' SIZE 010
             
             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             @ linha,040 PRINT alltrim(contas_receber->obs) FONT 'courier new' SIZE 010
             @ linha,120 PRINT alltrim(contas_receber->numero) FONT 'courier new' SIZE 010

             linha += 5

             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif

             contas_receber->(dbskip())

             if contas_receber->data <> x_old_data
                @ linha,100 PRINT 'Subtotal : R$ ' FONT 'courier new' SIZE 010 BOLD
                @ linha,160 PRINT trans(x_soma_dia,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD
                x_soma_geral := x_soma_geral + x_soma_dia
                x_soma_dia   := 0
                linha += 5
             endif
             
       end

       @ linha,090 PRINT 'Total do período : R$ ' FONT 'courier new' SIZE 010 BOLD
       @ linha,160 PRINT trans(x_soma_geral,'@E 999,999.99') FONT 'courier new' SIZE 010 BOLD

       rodape()
       
       END PRINTPAGE
       END PRINTDOC

	    ordscope(0,0)
	    ordscope(1,0)
       contas_receber->(dbgotop())

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       local x_de             := form_mov_crec_cli.dp_inicio.value
       local x_ate            := form_mov_crec_cli.dp_final.value
       local x_codigo_cliente := 0
       local x_cliente        := form_mov_crec_cli.cbo_001.value
       x_codigo_cliente       := val(substr(form_mov_crec_cli.cbo_001.item(x_cliente),1,6))

       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'CONTAS A RECEBER - PERÍODO' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'Cliente : '+acha_cliente(x_codigo_cliente) FONT 'courier new' SIZE 014
       @ 030,070 PRINT 'página  : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

       @ 041,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
       @ 041,040 PRINT 'CLIENTE/' FONT 'courier new' SIZE 010 BOLD
       @ 041,120 PRINT 'FORMA RECEBIMENTO/' FONT 'courier new' SIZE 010 BOLD
       @ 041,160 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD
       @ 046,040 PRINT 'OBSERVAÇÃO' FONT 'courier new' SIZE 010 BOLD
       @ 046,120 PRINT 'NÚMERO' FONT 'courier new' SIZE 010 BOLD
       
       return(nil)
*-------------------------------------------------------------------------------
static function rodape()

       @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
       @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

       return(nil)