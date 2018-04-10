/*
  sistema     : superchef pizzaria
  programa    : relatório movimentação contas a pagar
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function relatorio_cpag_001()

         define window form_mov_cpag;
                at 000,000;
                width 400;
                height 250;
                title 'Contas a Pagar por período';
                icon path_imagens+'icone.ico';
                modal;
                nosize

                @ 010,010 label lbl_001;
                          of form_mov_cpag;
                          value 'Escolha o intervalo de datas';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

                @ 040,010 datepicker dp_inicio;
                          parent form_mov_cpag;
                          value date();
                          width 150;
                          height 030;
                          font 'verdana' size 014
                @ 040,170 datepicker dp_final;
                          parent form_mov_cpag;
                          value date();
                          width 150;
                          height 030;
                          font 'verdana' size 014

                * linha separadora
                define label linha_rodape
                       col 000
                       row form_mov_cpag.height-090
                       value ''
                       width form_mov_cpag.width
                       height 001
                       backcolor _preto_001
                       transparent .F.
                end label

                * botões
                define buttonex button_ok
                       picture path_imagens+'img_relatorio.bmp'
                       col form_mov_cpag.width-255
                       row form_mov_cpag.height-085
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
                       col form_mov_cpag.width-100
                       row form_mov_cpag.height-085
                       width 090
                       height 050
                       caption 'Voltar'
                       action form_mov_cpag.release
                       fontbold .T.
                       tooltip 'Sair desta tela'
                       flat .F.
                       noxpstyle .T.
                end buttonex

                on key escape action thiswindow.release

         end window

         form_mov_cpag.center
         form_mov_cpag.activate

         return(nil)
*-------------------------------------------------------------------------------
static function relatorio()

       local x_de  := form_mov_cpag.dp_inicio.value
       local x_ate := form_mov_cpag.dp_final.value

       local p_linha := 045
       local u_linha := 260
       local linha   := p_linha
       local pagina  := 1

       local x_soma_dia   := 0
       local x_soma_geral := 0
       local x_old_data   := ctod('  /  /  ')

       dbselectarea('contas_pagar')
       contas_pagar->(ordsetfocus('data'))
       contas_pagar->(dbgotop())
	    ordscope(0,dtos(x_de))
	    ordscope(1,dtos(x_ate))
       contas_pagar->(dbgotop())

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             x_old_data := contas_pagar->data
             x_soma_dia := x_soma_dia + contas_pagar->valor
             
             @ linha,015 PRINT dtoc(contas_pagar->data) FONT 'courier new' SIZE 010
             @ linha,040 PRINT acha_fornecedor(contas_pagar->fornec) FONT 'courier new' SIZE 010
             @ linha,120 PRINT acha_forma_pagamento(contas_pagar->forma) FONT 'courier new' SIZE 010
             @ linha,160 PRINT trans(contas_pagar->valor,'@E 999,999.99') FONT 'courier new' SIZE 010
             
             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             @ linha,040 PRINT alltrim(contas_pagar->obs) FONT 'courier new' SIZE 010
             @ linha,120 PRINT alltrim(contas_pagar->numero) FONT 'courier new' SIZE 010

             linha += 5

             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif

             contas_pagar->(dbskip())

             if contas_pagar->data <> x_old_data
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
       contas_pagar->(dbgotop())

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       local x_de  := form_mov_cpag.dp_inicio.value
       local x_ate := form_mov_cpag.dp_final.value
       
       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'CONTAS A PAGAR - PERÍODO' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

       @ 035,015 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
       @ 035,040 PRINT 'FORNECEDOR/' FONT 'courier new' SIZE 010 BOLD
       @ 035,120 PRINT 'FORMA PAGAMENTO/' FONT 'courier new' SIZE 010 BOLD
       @ 035,160 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD
       @ 040,040 PRINT 'OBSERVAÇÃO' FONT 'courier new' SIZE 010 BOLD
       @ 040,120 PRINT 'NÚMERO' FONT 'courier new' SIZE 010 BOLD
       
       return(nil)
*-------------------------------------------------------------------------------
static function rodape()

       @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
       @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

       return(nil)