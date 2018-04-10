/*
  sistema     : superchef pizzaria
  programa    : relatório posição do estoque - matéria prima
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function posicao_mprima()

         define window form_estoque_mprima;
                at 000,000;
                width 400;
                height 250;
                title 'Posição do estoque (matéria prima)';
                icon path_imagens+'icone.ico';
                modal;
                nosize

                @ 010,010 label lbl_001;
                          of form_estoque_mprima;
                          value 'Este relatório irá listar todas as matérias primas em';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,010 label lbl_002;
                          of form_estoque_mprima;
                          value 'estoque, mostrando a quantidade atual disponível.';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

                * linha separadora
                define label linha_rodape
                       col 000
                       row form_estoque_mprima.height-090
                       value ''
                       width form_estoque_mprima.width
                       height 001
                       backcolor _preto_001
                       transparent .F.
                end label

                * botões
                define buttonex button_ok
                       picture path_imagens+'img_relatorio.bmp'
                       col form_estoque_mprima.width-255
                       row form_estoque_mprima.height-085
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
                       col form_estoque_mprima.width-100
                       row form_estoque_mprima.height-085
                       width 090
                       height 050
                       caption 'Voltar'
                       action form_estoque_mprima.release
                       fontbold .T.
                       tooltip 'Sair desta tela'
                       flat .F.
                       noxpstyle .T.
                end buttonex

                on key escape action thiswindow.release

         end window

         form_estoque_mprima.center
         form_estoque_mprima.activate

         return(nil)
*-------------------------------------------------------------------------------
static function relatorio()

       local p_linha := 040
       local u_linha := 260
       local linha   := p_linha
       local pagina  := 1
       
       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       dbselectarea('materia_prima')
       materia_prima->(ordsetfocus('nome'))
       materia_prima->(dbgotop())
       
       cabecalho(pagina)
       
       while .not. eof()

             @ linha,020 PRINT alltrim(str(materia_prima->codigo)) FONT 'courier new' SIZE 010
             @ linha,040 PRINT alltrim(materia_prima->nome) FONT 'courier new' SIZE 010
             @ linha,100 PRINT str(materia_prima->qtd,12,3) FONT 'courier new' SIZE 010
             @ linha,150 PRINT acha_unidade(materia_prima->unidade) FONT 'courier new' SIZE 010

             linha += 5
                
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif

             materia_prima->(dbskip())

       end

       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'RELAÇÃO POSIÇÃO ESTOQUE - m.prima' FONT 'courier new' SIZE 018 BOLD
       @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001

       @ 035,020 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
       @ 035,040 PRINT 'PRODUTO' FONT 'courier new' SIZE 010 BOLD
       @ 035,100 PRINT 'QUANTIDADE ESTOQUE' FONT 'courier new' SIZE 010 BOLD
       @ 035,150 PRINT 'UNIDADE' FONT 'courier new' SIZE 010 BOLD

       return(nil)
*-------------------------------------------------------------------------------
static function rodape()

       @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
       @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

       return(nil)