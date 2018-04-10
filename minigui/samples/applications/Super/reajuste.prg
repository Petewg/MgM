/*
  sistema     : superchef pizzaria
  programa    : reajustar preços
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

static _conta_acesso := 0

function reajuste()

         local a_001 := {}
         local a_002 := {}
         local a_003 := {}

         aadd(a_001,'Somente as pizzas')
         aadd(a_001,'Demais produtos')

         dbselectarea('categoria_produtos')
         categoria_produtos->(dbgotop())
         aadd(a_002,'000000 - Não escolher')
         while .not. eof()
               aadd(a_002,strzero(categoria_produtos->codigo,6)+' - '+categoria_produtos->nome)
               categoria_produtos->(dbskip())
         end
         
         dbselectarea('subcategoria_produtos')
         subcategoria_produtos->(dbgotop())
         aadd(a_003,'000000 - Não escolher')
         while .not. eof()
               aadd(a_003,strzero(subcategoria_produtos->codigo,6)+' - '+subcategoria_produtos->nome)
               subcategoria_produtos->(dbskip())
         end

         define window form_reajuste;
                at 000,000;
		          width 900;
		          height 600;
                title 'Reajustar Preços de Produtos';
                icon path_imagens+'icone.ico';
                modal;
                nosize;
                on init zera_temporario();
                on release zera_acesso()

                * fase 1
                @ 010,005 label lbl_001;
                          of form_reajuste;
                          value 'Quais produtos reajustar ?';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
		          define comboboxex cbo_001
			              row	030
                       col	005
			              width 200
			              height 200
			              items a_001
			              value 1
                end comboboxex

                * fase 2
                @ 070,005 label lbl_002;
                          of form_reajuste;
                          value 'Selecione a Categoria';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
		          define comboboxex cbo_002
			              row	090
                       col	005
			              width 200
			              height 400
			              items a_002
			              value 1
			              listwidth 300
                end comboboxex

                * fase 3
                @ 130,005 label lbl_003;
                          of form_reajuste;
                          value 'Selecione a Subcategoria';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
		          define comboboxex cbo_003
			              row	150
                       col	005
			              width 200
			              height 400
			              items a_003
			              value 1
			              listwidth 300
                end comboboxex

                * fase 4
                @ 200,005 label lbl_004;
                          of form_reajuste;
                          value 'SOMAR';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor BLUE;
                          transparent
                @ 200,060 getbox tbox_004;
                          of form_reajuste;
                          height 027;
                          width 080;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@E 9,999.99'
                @ 200,150 label lbl_0044;
                          of form_reajuste;
                          value 'ao preço';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 230,005 label lbl_00444;
                          of form_reajuste;
                          value 'de venda já existente';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

                @ 250,040 label lbl_ou;
                          of form_reajuste;
                          value 'ou então';
                          autosize;
                          font 'tahoma' size 018;
                          bold;
                          fontcolor _preto_001;
                          transparent

                * fase 5
                @ 290,005 label lbl_005;
                          of form_reajuste;
                          value 'APLICAR';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor BLUE;
                          transparent
                @ 290,070 getbox tbox_005;
                          of form_reajuste;
                          height 027;
                          width 070;
                          value 0;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@R 999.99'
                @ 290,150 label lbl_0055;
                          of form_reajuste;
                          value '% sobre';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 320,005 label lbl_00555;
                          of form_reajuste;
                          value 'o preço de venda já existente';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

              * botão filtrar
              @ 360,005 buttonex botao_filtrar;
                        parent form_reajuste;
                        caption 'Filtrar informações';
                        width 200 height 040;
                        picture path_imagens+'img_filtro.bmp';
                        action filtrar_informacoes();
                        tooltip 'Clique aqui para separar as informações e visualizar os reajustes antes de efetivá-los'

                * separar a tela em 2 partes
                define label label_separador
                       col 210
                       row 000
                       value ''
                       width 002
                       height 600
                       transparent .F.
                       backcolor _cinza_002
                end label

                * grid e opções do reajuste
                @ 010,220 label lbl_reajuste;
                          of form_reajuste;
                          value 'Aqui serão visualizadas as informações filtradas com base nos critérios ao lado';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent

                * botões
                @ 520,405 buttonex botao_reajustar;
                          parent form_reajuste;
                          caption 'Reajustar os preços com base na projeção';
                          width 300 height 040;
                          picture path_imagens+'img_aplicar.bmp';
                          action gravar_reajuste();
                          tooltip 'Clique aqui para gravar as informações com reajuste no banco de dados'
                @ 520,710 buttonex botao_sair;
                          parent form_reajuste;
                          caption 'Sair desta tela';
                          width 180 height 040;
                          picture path_imagens+'img_sair.bmp';
                          action (zera_acesso(),form_reajuste.release);
                          tooltip 'Clique aqui para sair'

                on key escape action thiswindow.release

         end window

         form_reajuste.center
         form_reajuste.activate

         return(nil)
*-------------------------------------------------------------------------------
static function filtrar_informacoes()

       local x_tipo                := form_reajuste.cbo_001.value
       local x_categoria           := form_reajuste.cbo_002.value
       local x_codigo_categoria    := 0
       local x_subcategoria        := form_reajuste.cbo_003.value
       local x_codigo_subcategoria := 0
       local x_valor               := form_reajuste.tbox_004.value
       local x_percentual          := form_reajuste.tbox_005.value

       if empty(x_valor) .and. empty(x_percentual)
          msgalert('Você precisa digitar ou valor ou percentual para simular o reajuste','Atenção')
          return(nil)
       endif
       
       if x_categoria <> 1
          x_codigo_categoria := val(substr(form_reajuste.cbo_002.item(x_categoria),1,6))
       endif
       
       if x_subcategoria <> 1
          x_codigo_subcategoria := val(substr(form_reajuste.cbo_003.item(x_subcategoria),1,6))
       endif

       if _conta_acesso > 0
          form_reajuste.grid_reajuste.release
       endif
       
       if x_tipo == 1 //pizzas
          _conta_acesso ++
          define grid grid_reajuste
                 parent form_reajuste
                 col 220
                 row 030
                 width 665
                 height 480
                 headers {'.','Produto',_tamanho_001,_tamanho_002,_tamanho_003,_tamanho_004,_tamanho_005,_tamanho_006}
                 widths {001,300,120,120,120,120,120,120}
                 fontname 'verdana'
                 fontsize 010
                 fontbold .T.
                 backcolor _amarelo_001
                 fontcolor BLUE
          end grid
       elseif x_tipo == 2 //demais produtos
          _conta_acesso ++
          define grid grid_reajuste
                 parent form_reajuste
                 col 220
                 row 030
                 width 665
                 height 480
                 headers {'.','Produto','Preço reajustado R$'}
                 widths {001,400,220}
                 fontname 'verdana'
                 fontsize 010
                 fontbold .T.
                 backcolor _amarelo_001
                 fontcolor BLUE
          end grid
       endif

       * limpar dbf temporário
       zera_temporario()
       
       dbselectarea('produtos')
       produtos->(dbgotop())

       * separar as informações
       while .not. eof()
             if x_tipo == 1 //pizzas
                if produtos->pizza
                   dbselectarea('tmp_reajuste')
                   append blank
                   replace cod_prod with produtos->codigo
                   replace nom_prod with produtos->nome_longo
                   replace tam_001 with produtos->val_tm_001
                   replace tam_002 with produtos->val_tm_002
                   replace tam_003 with produtos->val_tm_003
                   replace tam_004 with produtos->val_tm_004
                   replace tam_005 with produtos->val_tm_005
                   replace tam_006 with produtos->val_tm_006
                   replace id_cat with produtos->categoria
                   replace id_subcat with produtos->scategoria
                endif
             elseif x_tipo == 2 //demais produtos
                if !produtos->pizza
                   dbselectarea('tmp_reajuste')
                   append blank
                   replace cod_prod with produtos->codigo
                   replace nom_prod with produtos->nome_longo
                   replace pre_reaj with produtos->vlr_venda
                   replace id_cat with produtos->categoria
                   replace id_subcat with produtos->scategoria
                endif
             endif
             dbselectarea('produtos')
             produtos->(dbskip())
       end
       
       * indexar as informações
       dbselectarea('tmp_reajuste')
       if x_codigo_categoria == 0 .and. x_codigo_subcategoria == 0
          index on nom_prod to indreaj
       endif
       if x_codigo_categoria <> 0 .and. x_codigo_subcategoria <> 0
          index on nom_prod to indreaj for id_cat == x_codigo_categoria .and. id_subcat == x_codigo_subcategoria
       endif
       if x_codigo_categoria <> 0 .and. x_codigo_subcategoria == 0
          index on nom_prod to indreaj for id_cat == x_codigo_categoria
       endif
       if x_codigo_categoria == 0 .and. x_codigo_subcategoria <> 0
          index on nom_prod to indreaj for id_subcat == x_codigo_subcategoria
       endif
       tmp_reajuste->(dbgotop())
       
       * reajustar os preços
       while .not. eof()
             if .not. empty(x_valor)
                if x_tipo == 1 //pizzas
                   replace tam_001 with tam_001 + x_valor
                   replace tam_002 with tam_002 + x_valor
                   replace tam_003 with tam_003 + x_valor
                   replace tam_004 with tam_004 + x_valor
                   replace tam_005 with tam_005 + x_valor
                   replace tam_006 with tam_006 + x_valor
                elseif x_tipo == 2 //demais produtos
                   replace pre_reaj with pre_reaj + x_valor
                endif
             else
                if x_tipo == 1 //pizzas
                   replace tam_001 with tam_001 + ((tam_001*x_percentual)/100)
                   replace tam_002 with tam_002 + ((tam_002*x_percentual)/100)
                   replace tam_003 with tam_003 + ((tam_003*x_percentual)/100)
                   replace tam_004 with tam_004 + ((tam_004*x_percentual)/100)
                   replace tam_005 with tam_005 + ((tam_005*x_percentual)/100)
                   replace tam_006 with tam_006 + ((tam_006*x_percentual)/100)
                elseif x_tipo == 2 //demais produtos
                   replace pre_reaj with pre_reaj + ((pre_reaj*x_percentual)/100)
                endif
             endif
             tmp_reajuste->(dbskip())
       end

       * alimentar o grid
       delete item all from grid_reajuste of form_reajuste
       dbselectarea('tmp_reajuste')
       tmp_reajuste->(dbgotop())
       while .not. eof()
             if x_tipo == 1 //pizzas
                add item {tmp_reajuste->cod_prod,tmp_reajuste->nom_prod,trans(tmp_reajuste->tam_001,'@E 99,999.99'),trans(tmp_reajuste->tam_002,'@E 99,999.99'),trans(tmp_reajuste->tam_003,'@E 99,999.99'),trans(tmp_reajuste->tam_004,'@E 99,999.99'),trans(tmp_reajuste->tam_005,'@E 99,999.99'),trans(tmp_reajuste->tam_006,'@E 99,999.99')} to grid_reajuste of form_reajuste
             elseif x_tipo == 2 //demais produtos
                add item {tmp_reajuste->cod_prod,tmp_reajuste->nom_prod,trans(tmp_reajuste->pre_reaj,'@E 999,999.99')} to grid_reajuste of form_reajuste
             endif
             tmp_reajuste->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function gravar_reajuste()

       local x_flag := .F.
       local x_tipo := form_reajuste.cbo_001.value
       
       dbselectarea('tmp_reajuste')
       tmp_reajuste->(dbgotop())
       
       while .not. eof()
       
             dbselectarea('produtos')
             produtos->(ordsetfocus('codigo'))
             produtos->(dbseek(tmp_reajuste->cod_prod))
             
             if found()
                if x_tipo == 1 //pizzas
                   if lock_reg()
                      replace val_tm_001 with tmp_reajuste->tam_001
                      replace val_tm_002 with tmp_reajuste->tam_002
                      replace val_tm_003 with tmp_reajuste->tam_003
                      replace val_tm_004 with tmp_reajuste->tam_004
                      replace val_tm_005 with tmp_reajuste->tam_005
                      replace val_tm_006 with tmp_reajuste->tam_006
                      produtos->(dbcommit())
                      produtos->(dbunlock())
                   else
                      x_flag := .T.
                   endif
                elseif x_tipo == 2 //demais produtos
                   if lock_reg()
                      replace vlr_venda with tmp_reajuste->pre_reaj
                      produtos->(dbcommit())
                      produtos->(dbunlock())
                   else
                      x_flag := .T.
                   endif
                endif
             endif
             
             dbselectarea('tmp_reajuste')
             tmp_reajuste->(dbskip())
       
       end
       
       if x_flag
          msgstop('Nem todos produtos foram reajustados, confira','Atenção')
       else
          msginfo('Reajuste processado com sucesso, tecle ENTER','Mensagem')
       endif
       
       form_reajuste.release
       
       return(nil)
*-------------------------------------------------------------------------------
static function zera_acesso()
       _conta_acesso := 0
       return(nil)
*-------------------------------------------------------------------------------
static function zera_temporario()

       dbselectarea('tmp_reajuste')
       zap
       pack

       return(nil)