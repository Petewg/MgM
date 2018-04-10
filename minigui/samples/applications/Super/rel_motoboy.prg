/*
  sistema     : superchef pizzaria
  programa    : relatório comissão motoboys
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function relatorio_motoboy()

         local a_001 := {}

         dbselectarea('motoboys')
         motoboys->(ordsetfocus('nome'))
         motoboys->(dbgotop())
         while .not. eof()
               aadd(a_001,strzero(motoboys->codigo,4)+' - '+motoboys->nome)
               motoboys->(dbskip())
         end

         define window form_comissao_motoboy;
                at 000,000;
                width 400;
                height 250;
                title 'Comissão Motoboys/Entregadores';
                icon path_imagens+'icone.ico';
                modal;
                nosize

                @ 010,010 label lbl_001;
                          of form_comissao_motoboy;
                          value 'Escolha o intervalo de datas';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 080,010 label lbl_002;
                          of form_comissao_motoboy;
                          value 'Escolha o motoboy/entregador';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

                @ 040,010 datepicker dp_inicio;
                          parent form_comissao_motoboy;
                          value date();
                          width 150;
                          height 030;
                          font 'verdana' size 014
                @ 040,170 datepicker dp_final;
                          parent form_comissao_motoboy;
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
                       row form_comissao_motoboy.height-090
                       value ''
                       width form_comissao_motoboy.width
                       height 001
                       backcolor _preto_001
                       transparent .F.
                end label

                * botões
                define buttonex button_ok
                       picture path_imagens+'img_relatorio.bmp'
                       col form_comissao_motoboy.width-255
                       row form_comissao_motoboy.height-085
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
                       col form_comissao_motoboy.width-100
                       row form_comissao_motoboy.height-085
                       width 090
                       height 050
                       caption 'Voltar'
                       action form_comissao_motoboy.release
                       fontbold .T.
                       tooltip 'Sair desta tela'
                       flat .F.
                       noxpstyle .T.
                end buttonex

                on key escape action thiswindow.release

         end window

         form_comissao_motoboy.center
         form_comissao_motoboy.activate

         return(nil)
*-------------------------------------------------------------------------------
static function relatorio()

       local x_codigo_motoboy := 0
       local x_de             := form_comissao_motoboy.dp_inicio.value
       local x_ate            := form_comissao_motoboy.dp_final.value
       local x_motoboy        := form_comissao_motoboy.cbo_001.value

       local p_linha := 046
       local u_linha := 260
       local linha   := p_linha
       local pagina  := 1
       
       local x_diaria   := 0
       local x_subtotal := 0
       local x_total_1  := 0
       local x_total_2  := 0
       local x_old_data := ctod('  /  /  ')

       x_codigo_motoboy := val(substr(form_comissao_motoboy.cbo_001.item(x_motoboy),1,4))

       dbselectarea('motoboys')
       motoboys->(ordsetfocus('codigo'))
       motoboys->(dbgotop())
       motoboys->(dbseek(x_codigo_motoboy))
       if found()
          x_diaria := motoboys->diaria
       endif
       
       dbselectarea('comissao')
       index on dtos(data)+hora to indcmtb for data >= x_de .and. data <= x_ate .and. id == x_codigo_motoboy
       go top

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             x_subtotal := x_subtotal + valor
             x_old_data := data
             
             @ linha,030 PRINT dtoc(data) FONT 'courier new' SIZE 010
             @ linha,060 PRINT hora FONT 'courier new' SIZE 010
             @ linha,100 PRINT trans(valor,'@E 9,999.99') FONT 'courier new' SIZE 010

             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             skip

             if data <> x_old_data
                linha += 5
                @ linha,070 PRINT 'Valor Diária : R$ '+trans(x_diaria,'@E 9,999.99') FONT 'courier new' SIZE 010
                linha += 5
                @ linha,070 PRINT 'Comissões    : R$ '+trans(x_subtotal,'@E 9,999.99') FONT 'courier new' SIZE 010
                linha += 5
                @ linha,070 PRINT 'Total do dia : R$ '+trans(x_diaria+x_subtotal,'@E 9,999.99') FONT 'courier new' SIZE 010
                linha += 5
                @ linha,030 PRINT LINE TO linha,150 PENWIDTH 0.3 COLOR _preto_001
                linha += 3
                x_total_1  := x_total_1 + x_subtotal
                x_total_2  := x_total_2 + ( x_diaria + x_subtotal )
                x_subtotal := 0
             endif
             
       end

       linha += 5
       @ linha,060 PRINT 'Total COMISSÃO          : R$ '+trans(x_total_1,'@E 9,999.99') FONT 'courier new' SIZE 010
       linha += 5
       @ linha,060 PRINT 'Total DIÁRIA + COMISSÃO : R$ '+trans(x_total_2,'@E 9,999.99') FONT 'courier new' SIZE 010
                
       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       local x_codigo_motoboy := 0
       local x_de             := form_comissao_motoboy.dp_inicio.value
       local x_ate            := form_comissao_motoboy.dp_final.value
       local x_motoboy        := form_comissao_motoboy.cbo_001.value
       x_codigo_motoboy       := val(substr(form_comissao_motoboy.cbo_001.item(x_motoboy),1,4))
       
       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'COMISSÃO MOTOBOY/ENTREGADOR' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT dtoc(x_de)+' até '+dtoc(x_ate) FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'De     : '+acha_motoboy(x_codigo_motoboy) FONT 'courier new' SIZE 012
       @ 030,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 036,000 PRINT LINE TO 036,205 PENWIDTH 0.5 COLOR _preto_001

       @ 041,030 PRINT 'DATA' FONT 'courier new' SIZE 010 BOLD
       @ 041,060 PRINT 'HORA' FONT 'courier new' SIZE 010 BOLD
       @ 041,100 PRINT 'VALOR R$' FONT 'courier new' SIZE 010 BOLD

       return(nil)
*-------------------------------------------------------------------------------
static function rodape()

       @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
       @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

       return(nil)