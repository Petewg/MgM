/*
  sistema     : superchef pizzaria
  programa    : entregas
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function mostra_entregas()

         define window form_entrega;
                at 000,000;
                width getdesktopwidth();
                height getdesktopheight();
                title 'Acompanhamento dos pedidos feitos em : venda delivery e : venda balcão';
                icon path_imagens+'icone.ico';
                modal

                @ 005,005 browse grid_entrega;
                          parent form_entrega;
                          width getdesktopwidth()-015;
                          height getdesktopheight()-125;
                          headers {'Situação','Telefone','Cliente','Endereço','Hora','Origem','Motoboy','Taxa R$'};
                          widths {120,080,220,220,080,080,100,080};
                          workarea entrega;
                          fields {'entrega->situacao','entrega->telefone','entrega->cliente','entrega->endereco','entrega->hora','entrega->origem','entrega->motoboy','trans(entrega->vlr_taxa,"@E 999.99")'};
                          value 1;
                          font 'tahoma' size 010;
                          bold;
                          backcolor _acompanhamento;
                          fontcolor BLUE

                * botões
                @ getdesktopheight()-110,005 buttonex botao_f5;
                          parent form_entrega;
                          caption 'F5 - Escolher motoboy/entregador';
                          width 280 height 040;
                          picture path_imagens+'img_motent.bmp';
                          font 'tahoma' size 010;
                          bold;
                          action escolher_motoboy()
                @ getdesktopheight()-110,295 buttonex botao_f6;
                          parent form_entrega;
                          caption 'F6 - Mudar situação do pedido';
                          width 260 height 040;
                          picture path_imagens+'img_situacao.bmp';
                          font 'tahoma' size 010;
                          bold;
                          action mudar_situacao()
                @ getdesktopheight()-110,565 buttonex botao_f9;
                          parent form_entrega;
                          caption 'F9 - Atualizar pedidos';
                          width 210 height 040;
                          picture path_imagens+'img_atualiza.bmp';
                          font 'tahoma' size 010;
                          bold;
                          action atualizar_pedidos()
                @ getdesktopheight()-110,785 buttonex botao_esc;
                          parent form_entrega;
                          caption 'ESC - Sair desta tela';
                          width 200 height 040;
                          picture path_imagens+'img_sair.bmp';
                          font 'tahoma' size 010;
                          bold;
                          action form_entrega.release

                on key F5 action escolher_motoboy()
                on key F6 action mudar_situacao()
                on key F9 action atualizar_pedidos()
                on key escape action thiswindow.release

         end window

         form_entrega.maximize
         form_entrega.activate

         return(nil)
*-------------------------------------------------------------------------------
static function escolher_motoboy()

       dbselectarea('motoboys')
       motoboys->(dbgotop())

       define window form_escolhe;
              at 000,000;
              width 400;
              height 400;
              title 'Escolher Motoboy/Entregador';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define label info_001
                     parent form_escolhe
                     col 010
                     row 005
                     value 'Duplo clique ou ENTER escolhe motoboy'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _preto_001
                     transparent .T.
              end label
              define label info_002
                     parent form_escolhe
                     col 010
                     row 025
                     value 'ESC fecha esta janela'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _vermelho_002
                     transparent .T.
              end label
              @ 005,290 button btn_sair;
                        parent form_escolhe;
                        caption 'Sair';
                        action form_escolhe.release;
                        width 100;
                        height 030

              @ 045,010 browse browse_escolhe;
                        of form_escolhe;
                        width 375;
                        height 310;
                        headers {'ID','Motoboy/Entregador'};
                        widths {1,320};
                        workarea motoboys;
                        fields {'motoboys->codigo','motoboys->nome'};
                        value 1;
                        font 'verdana';
                        size 010;
                        backcolor _branco_001;
                        fontcolor BLUE;
                        on dblclick grava_motoboy(motoboys->codigo,alltrim(motoboys->nome))

              on key escape action form_escolhe.release

       end window

       form_escolhe.center
       form_escolhe.activate

       return(nil)
*-------------------------------------------------------------------------------
static function grava_motoboy(p_codigo,p_nome)

	   dbselectarea('entrega')
	   if lock_reg()
		  replace cod_moto with p_codigo
		  replace motoboy with p_nome
		  commit
		  entrega->(dbunlock())
		  form_escolhe.release
       	  form_entrega.grid_entrega.refresh
	   else
		  msginfo('Não foi possível selecionar a informação, tecle ENTER','Atenção')
		  return(nil)
	   endif

	   return(nil)
*-------------------------------------------------------------------------------
static function mudar_situacao()

       define window form_situacao;
              at 000,000;
              width 400;
              height 400;
              title 'Mudar situação do pedido';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define label info_001
                     parent form_situacao
                     col 010
                     row 005
                     value 'Duplo clique ou ENTER escolhe situação'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _preto_001
                     transparent .T.
              end label
              define label info_002
                     parent form_situacao
                     col 010
                     row 025
                     value 'ESC fecha esta janela'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _vermelho_002
                     transparent .T.
              end label
              @ 005,290 button btn_sair;
                        parent form_situacao;
                        caption 'Sair';
                        action form_situacao.release;
                        width 100;
                        height 030

              on key escape action form_situacao.release

       			@ 45,10 grid grid_situacao;
                  	   	of form_situacao;
                 	   	width 375;
                 	   	height 310;
                 	   	headers {'Situações'};
                 	   	widths {320};
                 	   	fontcolor BLUE;
                 	   	on dblclick grava_situacao()

       end window
       
       mostra_situacao()

       form_situacao.center
       form_situacao.activate

       return(nil)
*-------------------------------------------------------------------------------
static function mostra_situacao()

	   local i := 0
	   local n_tamanho := len(a_situacao)
	   
       delete item all from grid_situacao of form_situacao

	   for i := 1 to n_tamanho
       		 add item {a_situacao[i]} to grid_situacao of form_situacao
	   next

	   return(nil)
*-------------------------------------------------------------------------------
static function grava_situacao()

	   local x_nome := alltrim(valor_coluna('grid_situacao','form_situacao',1))
	   
	   dbselectarea('entrega')
	   if lock_reg()
		  replace situacao with x_nome
		  commit
		  entrega->(dbunlock())
		  form_situacao.release
       	  form_entrega.grid_entrega.refresh
	   else
		  msginfo('Não foi possível selecionar a informação, tecle ENTER','Atenção')
		  return(nil)
	   endif

	   return(nil)
*-------------------------------------------------------------------------------
static function atualizar_pedidos()

       if msgyesno('Atualizar agora ?','Atenção')
          dbselectarea('entrega')
          entrega->(dbgotop())
          while .not. eof()
                if alltrim(entrega->situacao) == 'PEDIDO OK'
       			   * comissão motoboy
       			   dbselectarea('comissao')
       			   comissao->(dbappend())
       			   comissao->id    := entrega->cod_moto
       			   comissao->data  := date()
       			   comissao->hora  := time()
       			   comissao->valor := entrega->vlr_taxa
       			   comissao->(dbcommit())
       			   * apaga da listagem
       			   dbselectarea('entrega')
                   if lock_reg()
                      entrega->(dbdelete())
                      entrega->(dbunlock())
                   endif
                endif
                entrega->(dbskip())
          end
       endif

       entrega->(dbgotop())
       form_entrega.grid_entrega.refresh

       return(nil)