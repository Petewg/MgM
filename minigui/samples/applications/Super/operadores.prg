/*
  sistema     : superchef pizzaria
  programa    : operadores do programa
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'miniprint.ch'
#include 'super.ch'

function operadores()

         dbselectarea('operadores')
         ordsetfocus('nome')
         operadores->(dbgotop())
   
         define window form_operadores;
                at 000,000;
                width 800;
                height 605;
                title 'Operadores do Programa';
                icon path_imagens+'icone.ico';
                modal;
                nosize;
                on init pesquisar()

                * botões (toolbar)
	  		       define buttonex button_incluir
              	 		  picture path_imagens+'incluir.bmp'
              			  col 005
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F5 Incluir'
              			  action dados(1)
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_alterar
              	 		  picture path_imagens+'alterar.bmp'
              			  col 107
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F6 Alterar'
              			  action dados(2)
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_excluir
              	 		  picture path_imagens+'excluir.bmp'
              			  col 209
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F7 Excluir'
              			  action excluir()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_imprimir
              	 		  picture path_imagens+'imprimir.bmp'
              			  col 311
              			  row 002
              			  width 100
              			  height 100
              			  caption 'F8 Imprimir'
              			  action relacao()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_atualizar
              	 		  picture path_imagens+'atualizar.bmp'
              			  col 413
              			  row 002
              			  width 100
              			  height 100
              			  caption 'Atualizar'
              			  action atualizar()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_acessos
              	 		  picture path_imagens+'acessos.bmp'
              			  col 515
              			  row 002
              			  width 100
              			  height 100
              			  caption 'Acessos'
              			  action acesso()
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex
	  		       define buttonex button_sair
              	 		  picture path_imagens+'sair.bmp'
              			  col 617
              			  row 002
              			  width 100
              			  height 100
              			  caption 'ESC Voltar'
              			  action form_operadores.release
              			  fontname 'verdana'
              			  fontsize 009
              			  fontbold .T.
              			  fontcolor _preto_001
              			  vertical .T.
              			  flat .T.
              			  noxpstyle .T.
                       backcolor _branco_001
					 end buttonex

                define splitbox
                define grid grid_operadores
                       parent form_operadores
                       col 000
                       row 105
                       width 795
                       height 430
                       headers {'Código','Nome'}
                       widths {100,650}
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       backcolor _amarelo_001
                       fontcolor _preto_001
                       ondblclick dados(2)
                end grid
                end splitbox
                
                define label rodape_001
                       parent form_operadores
                       col 005
                       row 545
                       value 'Digite sua pesquisa'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_001
                       transparent .T.
                end label
                @ 540,160 textbox tbox_pesquisa;
                          of form_operadores;
                          height 027;
                          width 300;
                          value '';
                          maxlength 040;
                          font 'verdana' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          uppercase;
                          on change pesquisar()
                define label rodape_002
                       parent form_operadores
                       col form_operadores.width - 270
                       row 545
                       value 'DUPLO CLIQUE : Alterar informação'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _verde_002
                       transparent .T.
                end label

                on key F5 action dados(1)
                on key F6 action dados(2)
                on key F7 action excluir()
                on key F8 action relacao()
                on key escape action thiswindow.release

         end window

         form_operadores.center
         form_operadores.activate

         return(nil)
*-------------------------------------------------------------------------------
static function dados(parametro)

       local id
       local titulo  := ''
       local x_nome  := ''
       local x_senha := ''

       if parametro == 1
          titulo := 'Incluir'
       elseif parametro == 2
          id     := val(valor_coluna('grid_operadores','form_operadores',1))
          titulo := 'Alterar'
          dbselectarea('operadores')
          operadores->(ordsetfocus('codigo'))
          operadores->(dbgotop())
          operadores->(dbseek(id))
          if found()
             x_nome  := operadores->nome
             x_senha := operadores->senha
             operadores->(ordsetfocus('nome'))
          else
             msgexclamation('Selecione uma informação','Atenção')
             operadores->(ordsetfocus('nome'))
             return(nil)
          endif
       endif

       define window form_dados;
              at 000,000;
		        width 325;
		        height 220;
              title (titulo);
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              * entrada de dados
              @ 010,005 label lbl_001;
                        of form_dados;
                        value 'Nome';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 030,005 textbox tbox_001;
                        of form_dados;
                        height 027;
                        width 310;
                        value x_nome;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 060,005 label lbl_002;
                        of form_dados;
                        value 'Senha';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 080,005 textbox tbox_002;
                        of form_dados;
                        height 027;
                        width 120;
                        value x_senha;
                        maxlength 010;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase;
                        password
                        
              * linha separadora
              define label linha_rodape
                     col 000
                     row form_dados.height-090
                     value ''
                     width form_dados.width
                     height 001
                     backcolor _preto_001
                     transparent .F.
              end label

              * botões
              define buttonex button_ok
                     picture path_imagens+'img_gravar.bmp'
                     col form_dados.width-225
                     row form_dados.height-085
                     width 120
                     height 050
                     caption 'Ok, gravar'
                     action gravar(parametro)
                     fontbold .T.
                     tooltip 'Confirmar as informações digitadas'
                     flat .F.
                     noxpstyle .T.
              end buttonex
              define buttonex button_cancela
                     picture path_imagens+'img_voltar.bmp'
                     col form_dados.width-100
                     row form_dados.height-085
                     width 090
                     height 050
                     caption 'Voltar'
                     action form_dados.release
                     fontbold .T.
                     tooltip 'Sair desta tela sem gravar informações'
                     flat .F.
                     noxpstyle .T.
              end buttonex

       end window

       sethandcursor(getcontrolhandle('button_ok','form_dados'))
       sethandcursor(getcontrolhandle('button_cancela','form_dados'))

       form_dados.center
       form_dados.activate

       return(nil)
*-------------------------------------------------------------------------------
static function excluir()

       local id := val(valor_coluna('grid_operadores','form_operadores',1))

       dbselectarea('operadores')
       operadores->(ordsetfocus('codigo'))
       operadores->(dbgotop())
       operadores->(dbseek(id))

       if .not. found()
          msgexclamation('Selecione uma informação','Atenção')
          operadores->(ordsetfocus('nome'))
          return(nil)
       else
          if msgyesno('Nome : '+alltrim(operadores->nome),'Excluir')
             if lock_reg()
                operadores->(dbdelete())
                operadores->(dbunlock())
                operadores->(dbgotop())
             endif
             operadores->(ordsetfocus('nome'))
             atualizar()
          endif
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function relacao()
       
       local p_linha := 040
       local u_linha := 260
       local linha   := p_linha
       local pagina  := 1

       dbselectarea('operadores')
       operadores->(ordsetfocus('nome'))
       operadores->(dbgotop())

       SELECT PRINTER DIALOG PREVIEW

       START PRINTDOC NAME 'Gerenciador de impressão'
       START PRINTPAGE

       cabecalho(pagina)
       
       while .not. eof()

             @ linha,030 PRINT strzero(operadores->codigo,4) FONT 'courier new' SIZE 010
             @ linha,050 PRINT operadores->nome FONT 'courier new' SIZE 010

             linha += 5
             
             if linha >= u_linha
                END PRINTPAGE
                START PRINTPAGE
                pagina ++
                cabecalho(pagina)
                linha := p_linha
             endif
             
             operadores->(dbskip())

       end

       rodape()
       
       END PRINTPAGE
       END PRINTDOC

       return(nil)
*-------------------------------------------------------------------------------
static function cabecalho(p_pagina)

       @ 007,010 PRINT IMAGE path_imagens+'logotipo.bmp' WIDTH 050 HEIGHT 020 STRETCH
       @ 010,070 PRINT 'RELAÇÃO DE OPERADORES' FONT 'courier new' SIZE 018 BOLD
       @ 018,070 PRINT 'ordem alfabética' FONT 'courier new' SIZE 014
       @ 024,070 PRINT 'página : '+strzero(p_pagina,4) FONT 'courier new' SIZE 012

       @ 030,000 PRINT LINE TO 030,205 PENWIDTH 0.5 COLOR _preto_001
       
       @ 035,030 PRINT 'CÓDIGO' FONT 'courier new' SIZE 010 BOLD
       @ 035,050 PRINT 'NOME' FONT 'courier new' SIZE 010 BOLD

       return(nil)
*-------------------------------------------------------------------------------
static function rodape()

       @ 275,000 PRINT LINE TO 275,205 PENWIDTH 0.5 COLOR _preto_001
       @ 276,010 PRINT 'impresso em '+dtoc(date())+' as '+time() FONT 'courier new' SIZE 008

       return(nil)
*-------------------------------------------------------------------------------
static function gravar(parametro)

       local codigo  := 0
       local retorna := .F.

       if empty(form_dados.tbox_001.value)
          retorna := .T.
       endif
       if empty(form_dados.tbox_002.value)
          retorna := .T.
       endif

       if retorna
          msgalert('Preencha todos os campos','Atenção')
          return(nil)
       endif
       
       if parametro == 1
          while .T.
                dbselectarea('conta')
                conta->(dbgotop())
                if lock_reg()
                   codigo := conta->c_operador
                   replace c_operador with c_operador + 1
                   conta->(dbcommit())
                   conta->(dbunlock())
                   exit
                else
                   msgexclamation('Servidor congestionado, tecle ENTER e aguarde','Atenção')
                   loop
                endif
          end
          dbselectarea('operadores')
          operadores->(dbappend())
          operadores->codigo := codigo
          operadores->nome   := form_dados.tbox_001.value
          operadores->senha  := form_dados.tbox_002.value
          operadores->(dbcommit())
          operadores->(dbgotop())
          form_dados.release
          atualizar()
       elseif parametro == 2
          dbselectarea('operadores')
          if lock_reg()
             operadores->nome  := form_dados.tbox_001.value
             operadores->senha := form_dados.tbox_002.value
             operadores->(dbcommit())
             operadores->(dbunlock())
             operadores->(dbgotop())
          endif
          form_dados.release
          atualizar()
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function pesquisar()

       local cPesq        := alltrim(form_operadores.tbox_pesquisa.value)
       local lGridFreeze  := .T.
       local nTamNomePesq := len(cPesq)

       dbselectarea('operadores')
       operadores->(ordsetfocus('nome'))
       operadores->(dbseek(cPesq))

       if lGridFreeze
          form_operadores.grid_operadores.disableupdate
       endif

       delete item all from grid_operadores of form_operadores

       while .not. eof()
             if substr(field->nome,1,nTamNomePesq) == cPesq
                add item {str(operadores->codigo),alltrim(operadores->nome)} to grid_operadores of form_operadores
             elseif substr(field->nome,1,nTamNomePesq) > cPesq
                exit
             endif
             operadores->(dbskip())
       end

       if lGridFreeze
          form_operadores.grid_operadores.enableupdate
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function atualizar()

       delete item all from grid_operadores of form_operadores

       dbselectarea('operadores')
       operadores->(ordsetfocus('nome'))
       operadores->(dbgotop())

       while .not. eof()
             add item {str(operadores->codigo),alltrim(operadores->nome)} to grid_operadores of form_operadores
             operadores->(dbskip())
       end

       return(nil)
*-------------------------------------------------------------------------------
static function acesso()

       local x_id   := val(valor_coluna('grid_operadores','form_operadores',1))
       local x_nome := alltrim(valor_coluna('grid_operadores','form_operadores',2))
       local x_opcao_001, x_opcao_002, x_opcao_003, x_opcao_004
       local x_opcao_005, x_opcao_006, x_opcao_007, x_opcao_008
       local x_opcao_009, x_opcao_010, x_opcao_011, x_opcao_012
       local x_opcao_013, x_opcao_014, x_opcao_015, x_opcao_016
       local x_opcao_017, x_opcao_018, x_opcao_019, x_opcao_020
       local x_opcao_021, x_opcao_022, x_opcao_023, x_opcao_024
       local x_opcao_025, x_opcao_026, x_opcao_027, x_opcao_028
       local x_opcao_029, x_opcao_030, x_opcao_031, x_opcao_032
       local x_opcao_033, x_opcao_034, x_opcao_035, x_opcao_036
       local x_opcao_037, x_opcao_038, x_opcao_039, x_opcao_040
       local x_opcao_041, x_opcao_042, x_opcao_043
       local x_tipo := 1
       
       x_opcao_001 := x_opcao_002 := x_opcao_003 := x_opcao_004 := .F.
       x_opcao_005 := x_opcao_006 := x_opcao_007 := x_opcao_008 := .F.
       x_opcao_009 := x_opcao_010 := x_opcao_011 := x_opcao_012 := .F.
       x_opcao_013 := x_opcao_014 := x_opcao_015 := x_opcao_016 := .F.
       x_opcao_017 := x_opcao_018 := x_opcao_019 := x_opcao_020 := .F.
       x_opcao_021 := x_opcao_022 := x_opcao_023 := x_opcao_024 := .F.
       x_opcao_025 := x_opcao_026 := x_opcao_027 := x_opcao_028 := .F.
       x_opcao_029 := x_opcao_030 := x_opcao_031 := x_opcao_032 := .F.
       x_opcao_033 := x_opcao_034 := x_opcao_035 := x_opcao_036 := .F.
       x_opcao_037 := x_opcao_038 := x_opcao_039 := x_opcao_040 := .F.
       x_opcao_041 := x_opcao_042 := x_opcao_043 := .F.

       if empty(x_id)
          msgalert('Escolha uma informação primeiro','Atenção')
          return(nil)
       endif

       dbselectarea('acesso')
       acesso->(ordsetfocus('operador'))
       acesso->(dbgotop())
       acesso->(dbseek(x_id))
       if found()
          x_tipo := 2
          x_opcao_001 := acesso->acesso_001
          x_opcao_002 := acesso->acesso_002
          x_opcao_003 := acesso->acesso_003
          x_opcao_004 := acesso->acesso_004
          x_opcao_005 := acesso->acesso_005
          x_opcao_006 := acesso->acesso_006
          x_opcao_007 := acesso->acesso_007
          x_opcao_008 := acesso->acesso_008
          x_opcao_009 := acesso->acesso_009
          x_opcao_010 := acesso->acesso_010
          x_opcao_011 := acesso->acesso_011
          x_opcao_012 := acesso->acesso_012
          x_opcao_013 := acesso->acesso_013
          x_opcao_014 := acesso->acesso_014
          x_opcao_015 := acesso->acesso_015
          x_opcao_016 := acesso->acesso_016
          x_opcao_017 := acesso->acesso_017
          x_opcao_018 := acesso->acesso_018
          x_opcao_019 := acesso->acesso_019
          x_opcao_020 := acesso->acesso_020
          x_opcao_021 := acesso->acesso_021
          x_opcao_022 := acesso->acesso_022
          x_opcao_023 := acesso->acesso_023
          x_opcao_024 := acesso->acesso_024
          x_opcao_025 := acesso->acesso_025
          x_opcao_026 := acesso->acesso_026
          x_opcao_027 := acesso->acesso_027
          x_opcao_028 := acesso->acesso_028
          x_opcao_029 := acesso->acesso_029
          x_opcao_030 := acesso->acesso_030
          x_opcao_031 := acesso->acesso_031
          x_opcao_032 := acesso->acesso_032
          x_opcao_033 := acesso->acesso_033
          x_opcao_034 := acesso->acesso_034
          x_opcao_035 := acesso->acesso_035
          x_opcao_036 := acesso->acesso_036
          x_opcao_037 := acesso->acesso_037
          x_opcao_038 := acesso->acesso_038
          x_opcao_039 := acesso->acesso_039
          x_opcao_040 := acesso->acesso_040
          x_opcao_041 := acesso->acesso_041
          x_opcao_042 := acesso->acesso_042
          x_opcao_043 := acesso->acesso_043
       endif
       
       define window form_acesso;
              at 000,000;
		        width 625;
		        height 560;
              title 'Definir acessos para : '+x_nome;
              icon path_imagens+'icone.ico';
		        modal;
		        nosize

              define tab tab_acesso;
                       of form_acesso;
                       at 003,003;
                       width 615;
                       height form_acesso.height-090;
                       font 'verdana';
                       size 010;
                       bold;
                       value 001;
                       flat

                       page 'Principal' image path_imagens+'img_hum.bmp'
                            define checkbox chkbox_001
                                   caption 'Venda Delivery'
                                   col 150
                                   row 050
                                   width 350
                                   value x_opcao_001
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_002
                                   caption 'Venda Mesas'
                                   col 150
                                   row 080
                                   width 350
                                   value x_opcao_002
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_003
                                   caption 'Venda Balcão'
                                   col 150
                                   row 110
                                   width 350
                                   value x_opcao_003
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_004
                                   caption 'Cadastro Clientes'
                                   col 150
                                   row 140
                                   width 350
                                   value x_opcao_004
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_005
                                   caption 'Cadastro Produtos'
                                   col 150
                                   row 170
                                   width 350
                                   value x_opcao_005
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                       end page
                       page 'Tabelas' image path_imagens+'img_dois.bmp'
                            define checkbox chkbox_006
                                   caption 'Fornecedores'
                                   col 150
                                   row 050
                                   width 350
                                   value x_opcao_006
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_007
                                   caption 'Grupo de Fornecedores'
                                   col 150
                                   row 080
                                   width 350
                                   value x_opcao_007
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_008
                                   caption 'Matéria Prima'
                                   col 150
                                   row 110
                                   width 350
                                   value x_opcao_008
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_009
                                   caption 'Categorias de Produtos'
                                   col 150
                                   row 140
                                   width 350
                                   value x_opcao_009
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_010
                                   caption 'Sub-Categorias de Produtos'
                                   col 150
                                   row 170
                                   width 350
                                   value x_opcao_010
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_011
                                   caption 'Formas de Recebimento'
                                   col 150
                                   row 200
                                   width 350
                                   value x_opcao_011
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_012
                                   caption 'Formas de Pagamento'
                                   col 150
                                   row 230
                                   width 350
                                   value x_opcao_012
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_013
                                   caption 'Unidades de Medida'
                                   col 150
                                   row 260
                                   width 350
                                   value x_opcao_013
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_014
                                   caption 'Contas Bancárias'
                                   col 150
                                   row 290
                                   width 350
                                   value x_opcao_014
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_015
                                   caption 'Impostos e Alíquotas'
                                   col 150
                                   row 320
                                   width 350
                                   value x_opcao_015
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_016
                                   caption 'Mesas da Pizzaria'
                                   col 150
                                   row 350
                                   width 350
                                   value x_opcao_016
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_017
                                   caption 'Atendentes ou Garçons'
                                   col 150
                                   row 380
                                   width 350
                                   value x_opcao_017
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_018
                                   caption 'Motoboys ou Entregadores'
                                   col 150
                                   row 410
                                   width 350
                                   value x_opcao_018
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_019
                                   caption 'Operadores do Programa'
                                   col 150
                                   row 440
                                   width 350
                                   value x_opcao_019
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                       end page
                       page 'Relatórios' image path_imagens+'img_tres.bmp'
                            define checkbox chkbox_020
                                   caption 'Fechamento do dia de trabalho'
                                   col 150
                                   row 050
                                   width 350
                                   value x_opcao_020
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_021
                                   caption 'Movimentação do Caixa'
                                   col 150
                                   row 080
                                   width 350
                                   value x_opcao_021
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_022
                                   caption 'Movimentação Bancária'
                                   col 150
                                   row 110
                                   width 350
                                   value x_opcao_022
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_023
                                   caption 'Contas a Pagar por período'
                                   col 150
                                   row 140
                                   width 350
                                   value x_opcao_023
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_024
                                   caption 'Contas a Pagar por fornecedor'
                                   col 150
                                   row 170
                                   width 350
                                   value x_opcao_024
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_025
                                   caption 'Contas a Receber por período'
                                   col 150
                                   row 200
                                   width 350
                                   value x_opcao_025
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_026
                                   caption 'Contas a Receber por cliente'
                                   col 150
                                   row 230
                                   width 350
                                   value x_opcao_026
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_027
                                   caption 'Pizzas mais vendidas'
                                   col 150
                                   row 260
                                   width 350
                                   value x_opcao_027
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_028
                                   caption 'Produtos mais vendidos'
                                   col 150
                                   row 290
                                   width 350
                                   value x_opcao_028
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_029
                                   caption 'Relação estoque mínimo'
                                   col 150
                                   row 320
                                   width 350
                                   value x_opcao_029
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_030
                                   caption 'Posição do estoque (produtos)'
                                   col 150
                                   row 350
                                   width 350
                                   value x_opcao_030
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_031
                                   caption 'Posição do estoque (matéria prima)'
                                   col 150
                                   row 380
                                   width 350
                                   value x_opcao_031
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_032
                                   caption 'Comissão Motoboys/Entregadores'
                                   col 150
                                   row 410
                                   width 350
                                   value x_opcao_032
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_033
                                   caption 'Comissão Atendentes/Garçons'
                                   col 150
                                   row 440
                                   width 350
                                   value x_opcao_033
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                       end page
                       page 'Financeiro' image path_imagens+'img_quatro.bmp'
                            define checkbox chkbox_034
                                   caption 'Movimentação do Caixa'
                                   col 150
                                   row 050
                                   width 350
                                   value x_opcao_034
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_035
                                   caption 'Movimentação Bancária'
                                   col 150
                                   row 080
                                   width 350
                                   value x_opcao_035
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_036
                                   caption 'Compras / Entrada Estoque'
                                   col 150
                                   row 110
                                   width 350
                                   value x_opcao_036
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_037
                                   caption 'Contas a Pagar'
                                   col 150
                                   row 140
                                   width 350
                                   value x_opcao_037
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_038
                                   caption 'Contas a Receber'
                                   col 150
                                   row 170
                                   width 350
                                   value x_opcao_038
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                       end page
                       page 'Ferramentas' image path_imagens+'img_cinco.bmp'
                            define checkbox chkbox_039
                                   caption 'Tamanhos de Pizza'
                                   col 150
                                   row 050
                                   width 350
                                   value x_opcao_039
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_040
                                   caption 'Cadastro da Pizzaria'
                                   col 150
                                   row 080
                                   width 350
                                   value x_opcao_040
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_041
                                   caption 'Incluir ou Excluir Promoção'
                                   col 150
                                   row 110
                                   width 350
                                   value x_opcao_041
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_042
                                   caption 'Reajustar Preços de Produtos'
                                   col 150
                                   row 140
                                   width 350
                                   value x_opcao_042
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                            define checkbox chkbox_043
                                   caption 'Backup do Banco de Dados'
                                   col 150
                                   row 170
                                   width 350
                                   value x_opcao_043
                                   fontname 'verdana'
                                   fontsize 10
                                   fontbold .T.
                                   transparent .F.
                            end checkbox
                       end page

              end tab
              
              * botões
              define buttonex button_ok
                     picture path_imagens+'img_gravar.bmp'
                     col form_acesso.width-225
                     row form_acesso.height-085
                     width 120
                     height 050
                     caption 'Ok, gravar'
                     action gravar_acesso(x_id,x_tipo)
                     fontbold .T.
                     tooltip 'Confirmar as informações selecionadas'
                     flat .F.
                     noxpstyle .T.
              end buttonex
              define buttonex button_cancela
                     picture path_imagens+'img_voltar.bmp'
                     col form_acesso.width-100
                     row form_acesso.height-085
                     width 090
                     height 050
                     caption 'Voltar'
                     action form_acesso.release
                     fontbold .T.
                     tooltip 'Sair desta tela sem selecionar informações'
                     flat .F.
                     noxpstyle .T.
              end buttonex

              on key escape action thiswindow.release
              
       end window
       
       form_acesso.center
       form_acesso.activate
       
       return(nil)
*-------------------------------------------------------------------------------
static function gravar_acesso(parametro,tipo)

       if tipo == 1
          dbselectarea('acesso')
          acesso->(dbappend())
          acesso->operador   := parametro
          acesso->acesso_001 := form_acesso.chkbox_001.value
          acesso->acesso_002 := form_acesso.chkbox_002.value
          acesso->acesso_003 := form_acesso.chkbox_003.value
          acesso->acesso_004 := form_acesso.chkbox_004.value
          acesso->acesso_005 := form_acesso.chkbox_005.value
          acesso->acesso_006 := form_acesso.chkbox_006.value
          acesso->acesso_007 := form_acesso.chkbox_007.value
          acesso->acesso_008 := form_acesso.chkbox_008.value
          acesso->acesso_009 := form_acesso.chkbox_009.value
          acesso->acesso_010 := form_acesso.chkbox_010.value
          acesso->acesso_011 := form_acesso.chkbox_011.value
          acesso->acesso_012 := form_acesso.chkbox_012.value
          acesso->acesso_013 := form_acesso.chkbox_013.value
          acesso->acesso_014 := form_acesso.chkbox_014.value
          acesso->acesso_015 := form_acesso.chkbox_015.value
          acesso->acesso_016 := form_acesso.chkbox_016.value
          acesso->acesso_017 := form_acesso.chkbox_017.value
          acesso->acesso_018 := form_acesso.chkbox_018.value
          acesso->acesso_019 := form_acesso.chkbox_019.value
          acesso->acesso_020 := form_acesso.chkbox_020.value
          acesso->acesso_021 := form_acesso.chkbox_021.value
          acesso->acesso_022 := form_acesso.chkbox_022.value
          acesso->acesso_023 := form_acesso.chkbox_023.value
          acesso->acesso_024 := form_acesso.chkbox_024.value
          acesso->acesso_025 := form_acesso.chkbox_025.value
          acesso->acesso_026 := form_acesso.chkbox_026.value
          acesso->acesso_027 := form_acesso.chkbox_027.value
          acesso->acesso_028 := form_acesso.chkbox_028.value
          acesso->acesso_029 := form_acesso.chkbox_029.value
          acesso->acesso_030 := form_acesso.chkbox_030.value
          acesso->acesso_031 := form_acesso.chkbox_031.value
          acesso->acesso_032 := form_acesso.chkbox_032.value
          acesso->acesso_033 := form_acesso.chkbox_033.value
          acesso->acesso_034 := form_acesso.chkbox_034.value
          acesso->acesso_035 := form_acesso.chkbox_035.value
          acesso->acesso_036 := form_acesso.chkbox_036.value
          acesso->acesso_037 := form_acesso.chkbox_037.value
          acesso->acesso_038 := form_acesso.chkbox_038.value
          acesso->acesso_039 := form_acesso.chkbox_039.value
          acesso->acesso_040 := form_acesso.chkbox_040.value
          acesso->acesso_041 := form_acesso.chkbox_041.value
          acesso->acesso_042 := form_acesso.chkbox_042.value
          acesso->acesso_043 := form_acesso.chkbox_043.value
          acesso->(dbcommit())
          acesso->(dbgotop())
          form_acesso.release
       elseif tipo == 2
          dbselectarea('acesso')
          if lock_reg()
             acesso->acesso_001 := form_acesso.chkbox_001.value
             acesso->acesso_002 := form_acesso.chkbox_002.value
             acesso->acesso_003 := form_acesso.chkbox_003.value
             acesso->acesso_004 := form_acesso.chkbox_004.value
             acesso->acesso_005 := form_acesso.chkbox_005.value
             acesso->acesso_006 := form_acesso.chkbox_006.value
             acesso->acesso_007 := form_acesso.chkbox_007.value
             acesso->acesso_008 := form_acesso.chkbox_008.value
             acesso->acesso_009 := form_acesso.chkbox_009.value
             acesso->acesso_010 := form_acesso.chkbox_010.value
             acesso->acesso_011 := form_acesso.chkbox_011.value
             acesso->acesso_012 := form_acesso.chkbox_012.value
             acesso->acesso_013 := form_acesso.chkbox_013.value
             acesso->acesso_014 := form_acesso.chkbox_014.value
             acesso->acesso_015 := form_acesso.chkbox_015.value
             acesso->acesso_016 := form_acesso.chkbox_016.value
             acesso->acesso_017 := form_acesso.chkbox_017.value
             acesso->acesso_018 := form_acesso.chkbox_018.value
             acesso->acesso_019 := form_acesso.chkbox_019.value
             acesso->acesso_020 := form_acesso.chkbox_020.value
             acesso->acesso_021 := form_acesso.chkbox_021.value
             acesso->acesso_022 := form_acesso.chkbox_022.value
             acesso->acesso_023 := form_acesso.chkbox_023.value
             acesso->acesso_024 := form_acesso.chkbox_024.value
             acesso->acesso_025 := form_acesso.chkbox_025.value
             acesso->acesso_026 := form_acesso.chkbox_026.value
             acesso->acesso_027 := form_acesso.chkbox_027.value
             acesso->acesso_028 := form_acesso.chkbox_028.value
             acesso->acesso_029 := form_acesso.chkbox_029.value
             acesso->acesso_030 := form_acesso.chkbox_030.value
             acesso->acesso_031 := form_acesso.chkbox_031.value
             acesso->acesso_032 := form_acesso.chkbox_032.value
             acesso->acesso_033 := form_acesso.chkbox_033.value
             acesso->acesso_034 := form_acesso.chkbox_034.value
             acesso->acesso_035 := form_acesso.chkbox_035.value
             acesso->acesso_036 := form_acesso.chkbox_036.value
             acesso->acesso_037 := form_acesso.chkbox_037.value
             acesso->acesso_038 := form_acesso.chkbox_038.value
             acesso->acesso_039 := form_acesso.chkbox_039.value
             acesso->acesso_040 := form_acesso.chkbox_040.value
             acesso->acesso_041 := form_acesso.chkbox_041.value
             acesso->acesso_042 := form_acesso.chkbox_042.value
             acesso->acesso_043 := form_acesso.chkbox_043.value
          endif
          form_acesso.release
       endif
       
       return(nil)