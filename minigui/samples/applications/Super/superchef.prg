/*
  sistema     : superchef pizzaria
  programa    : principal
  compilador  : xharbour 1.2
  lib gráfica : minigui extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function main()

         local aColors

         public l_demo            := .F.
         public _limite_registros := 10
         public _nome_cliente_    := 'Q-Pizza Pizzaria'
         public _numero_serie_    := 'SCP62431348BR'
         public __codigo_cliente  := 0
         public _codigo_usuario_  := 0
         public _nome_usuario_    := space(10)
         public _tipo_cobranca    := 0
         public _zero             := 0
         
         public _tamanho_001 := ''
         public _tamanho_002 := ''
         public _tamanho_003 := ''
         public _tamanho_004 := ''
         public _tamanho_005 := ''
         public _tamanho_006 := ''
         public _pedaco_001  := 0
         public _pedaco_002  := 0
         public _pedaco_003  := 0
         public _pedaco_004  := 0
         public _pedaco_005  := 0
         public _pedaco_006  := 0
         
         public path_dbf     := GetStartUpFolder() + '\tabelas\'
         public path_imagens := GetStartUpFolder() + '\imagens\'

         * cores para labels, botões e janelas
         public _branco_001     := {255,255,255}
         public _preto_001      := {000,000,000}
         public _azul_001       := {108,108,255}
         public _azul_002       := {000,000,255}
         public _azul_003       := {032,091,164}
         public _azul_004       := {023,063,115}
         public _azul_005       := {071,089,135}
         public _azul_006       := {000,073,148}
         public _laranja_001    := {255,163,070}
         public _verde_001      := {000,094,047}
         public _verde_002      := {000,089,045}
         public _cinza_001      := {128,128,128}
         public _cinza_002      := {192,192,192}
         public _cinza_003      := {229,229,229}
         public _cinza_004      := {226,226,226}
         public _cinza_005      := {245,245,245}
         public _vermelho_001   := {255,000,000}
         public _vermelho_002   := {160,000,000}
         public _vermelho_003   := {190,000,000}
         public _amarelo_001    := {255,255,225}
         public _amarelo_002    := {255,255,121}
         public _marrom_001     := {143,103,080}
         public _ciano_001      := {215,255,255}
         public _grid_001       := _branco_001
         public _grid_002       := {210,233,255}
         public _super          := {128,128,255}
         public _acompanhamento := {255,255,220}

         * cores para get
         public _fundo_get   := {255,255,255}
         public _letra_get_1 := {000,000,255}
         
         * variáveis de apoio
         public _nome_unidade := 0
         public a_onde        := {'Delivery','Mesa','Balcão'}
         public a_situacao    := {'Montando','Assando','Sendo entregue','PEDIDO OK'}
         
         * variáveis para liberar o acesso
         public _a_001 := _a_002 := _a_003 := _a_004 := _a_005 := .F.
         public _a_006 := _a_007 := _a_008 := _a_009 := _a_010 := .F.
         public _a_011 := _a_012 := _a_013 := _a_014 := _a_015 := .F.
         public _a_016 := _a_017 := _a_018 := _a_019 := _a_020 := .F.
         public _a_021 := _a_022 := _a_023 := _a_024 := _a_025 := .F.
         public _a_026 := _a_027 := _a_028 := _a_029 := _a_030 := .F.
         public _a_031 := _a_032 := _a_033 := _a_034 := _a_035 := .F.
         public _a_036 := _a_037 := _a_038 := _a_039 := _a_040 := .F.
         public _a_041 := _a_042 := _a_043 := .F.
         
         REQUEST DBFCDX
         RDDSETDEFAULT('DBFCDX')

         set autoadjust on
         set deleted on
         set interactiveclose off
         set date british
         set century on
         set epoch to 1960
         set browsesync on
         set multiple off warning
         set tooltipballoon on
         set navigation extended
         set codepage to portuguese
         set language to portuguese

	      SET MENUSTYLE EXTENDED
	      SET MENUCURSOR FULL
	      SET MENUSEPARATOR SINGLE RIGHTALIGN
	      SET MENUITEM BORDER 3D

	      aColors := GetMenuColors()

	      aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 ) //linha separadora
	      aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 236, 233, 216 ) //RGB( 226, 234, 247 ) //fundo bmp do ítem
	      aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 236, 233, 216 ) //RGB( 226, 234, 247 ) //fundo bmp do ítem
      	  aColors[ MNUCLR_MENUBARBACKGROUND1 ] := GetSysColor(15)
      	  aColors[ MNUCLR_MENUBARBACKGROUND2 ] := GetSysColor(15)
      	  aColors[ MNUCLR_MENUBARSELECTEDITEM1 ] := RGB( 198, 211, 239 ) //GetSysColor(15)
      	  aColors[ MNUCLR_MENUBARSELECTEDITEM2 ] := RGB( 198, 211, 239 ) //GetSysColor(15)
      	  aColors[ MNUCLR_MENUITEMSELECTEDTEXT ] := RGB( 000, 000, 000 )
      	  aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 255, 255, 255 ) //fundo geral menu
      	  aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 255, 255, 255 ) //fundo geral menu
      	  aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB( 049, 105, 198 ) //bordas do ítem
      	  aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB( 049, 105, 198 ) //bordas do ítem
      	  aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB( 049, 105, 198 ) //bordas do ítem
      	  aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB( 049, 105, 198 ) //bordas do ítem
	      aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB( 198, 211, 239 ) //fundo ítem menu
	      aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB( 198, 211, 239 ) //fundo ítem menu

          SetMenuColors( aColors )

         *-----------------------------------------*
         * data limite versão demo                 *
         *                                         *
         public _data_limite := ctod('01/02/2020')
         *                                         *
         if l_demo
            _nome_cliente_ := 'CÓPIA DEMONSTRAÇÃO'
            _numero_serie_ := 'SCP-----------------'
         endif
         *                                         *
         *-----------------------------------------*
         
         define window form_main;
                at 000,000;
                width getdesktopwidth();
                height getdesktopheight();
                title 'SuperChef Pizza 4.0';
                main;
                noshow;
                icon path_imagens+'icone.ico';
                nosize;
                backcolor _azul_005;
                on init (cria_dbf_cdx(),login())

                define image img_wallpaper
                       row 000
                       col 000
                       height getdesktopheight()
                       width getdesktopwidth()
                       picture path_imagens+'wallpaper.bmp'
                       stretch .T.
                end image

                //se for cópia demo
                if l_demo
                   define label label_demo
                          col 000
                          row getdesktopheight()-300
                          width getdesktopwidth()
                          height 045
                          value 'CÓPIA DE AVALIAÇÃO - CÓPIA DE AVALIAÇÃO - CÓPIA DE AVALIAÇÃO - CÓPIA DE AVALIAÇÃO'
                          fontname 'tahoma'
                          fontsize 026
                          fontbold .T.
                          fontcolor _amarelo_002
                          backcolor _vermelho_003
                          transparent .F.
                   end label
                   _numero_serie_ := 'SCP---------------'
                endif

                * menu
                define main menu of form_main
                define popup 'Tabelas'
                       menuitem 'Fornecedores' action iif(libera(_a_006),fornecedores(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_fornecedores.bmp'
                       menuitem 'Grupo de Fornecedores' action iif(libera(_a_007),grupo_fornecedores(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_grupo_fornecedores.bmp'
                       separator
                       menuitem 'Matéria Prima' action iif(libera(_a_008),materia_prima(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_materia_prima.bmp'
                       separator
                       menuitem 'Categorias de Produtos' action iif(libera(_a_009),categoria_produtos(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_categorias.bmp'
                       menuitem 'Sub-Categorias de Produtos' action iif(libera(_a_010),subcategoria_produtos(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_subcategorias.bmp'
                       separator
                       menuitem 'Formas de Recebimento' action iif(libera(_a_011),formas_recebimento(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_formas_recebimento.bmp'
                       menuitem 'Formas de Pagamento' action iif(libera(_a_012),formas_pagamento(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_formas_pagamento.bmp'
                       separator
                       menuitem 'Unidades de Medida' action iif(libera(_a_013),unidades_medida(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_medidas.bmp'
                       menuitem 'Contas Bancárias' action iif(libera(_a_014),contas_bancarias(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_contas_bancarias.bmp'
                       menuitem 'Impostos e Alíquotas' action iif(libera(_a_015),impostos_aliquotas(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_impostos.bmp'
                       separator
                       menuitem 'Mesas da Pizzaria' action iif(libera(_a_016),mesas(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_mesas.bmp'
                       menuitem 'Atendentes ou Garçons' action iif(libera(_a_017),atendentes(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_atendentes.bmp'
                       menuitem 'Motoboys ou Entregadores' action iif(libera(_a_018),motoboys_entregadores(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_motoboys.bmp'
                       menuitem 'Operadores do Programa' action iif(libera(_a_019),operadores(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_operadores.bmp'
                end popup
                define popup 'Relatórios'
                       menuitem 'Fechamento do dia de trabalho' action iif(libera(_a_020),fechamento_dia(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       separator
                       menuitem 'Movimentação do Caixa' action iif(libera(_a_021),movimentacao_caixa(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       menuitem 'Movimentação Bancária' action iif(libera(_a_022),movimentacao_bancaria(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       separator
                       menuitem 'Contas a Pagar por período' action iif(libera(_a_023),relatorio_cpag_001(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       menuitem 'Contas a Pagar por fornecedor' action iif(libera(_a_024),relatorio_cpag_002(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       separator
                       menuitem 'Contas a Receber por período' action iif(libera(_a_025),relatorio_crec_001(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       menuitem 'Contas a Receber por cliente' action iif(libera(_a_026),relatorio_crec_002(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       separator
                       menuitem 'Pizzas mais vendidas' action iif(libera(_a_027),relatorio_pizza_001(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       menuitem 'Produtos mais vendidos' action iif(libera(_a_028),relatorio_produto_001(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       separator
                       menuitem 'Relação estoque mínimo' action iif(libera(_a_029),relatorio_estoque_minimo(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       menuitem 'Posição do estoque (produtos)' action iif(libera(_a_030),posicao_estoque(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       menuitem 'Posição do estoque (matéria prima)' action iif(libera(_a_031),posicao_mprima(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       separator
                       menuitem 'Comissão Motoboys/Entregadores' action iif(libera(_a_032),relatorio_motoboy(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                       menuitem 'Comissão Atendentes/Garçons' action iif(libera(_a_033),relatorio_garcon(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_relatorios.bmp'
                end popup
                define popup 'Financeiro'
                       menuitem 'Movimentação do Caixa' action iif(libera(_a_034),caixa(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_mov_caixa.bmp'
                       menuitem 'Movimentação Bancária' action iif(libera(_a_035),movimento_bancario(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_mov_bancaria.bmp'
                       separator
                       menuitem 'Compras / Entrada Estoque' action iif(libera(_a_036),compras(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_compras.bmp'
                       separator
                       menuitem 'Contas a Pagar' action iif(libera(_a_037),cpag(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_pagar_receber.bmp'
                       menuitem 'Contas a Receber' action iif(libera(_a_038),crec(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_pagar_receber.bmp'
                end popup
                define popup 'Ferramentas'
                       menuitem 'Cadastro da Pizzaria' action iif(libera(_a_040),empresa(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_cadastro.bmp'
                       separator
                       menuitem 'Tamanhos de Pizza' action iif(libera(_a_039),tamanhos_pizza(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_tamanhos.bmp'
					   menuitem 'Bordas de Pizza' action bordas_pizza() image path_imagens+'img_borda.bmp'
                       menuitem 'Configurar Venda de Pizza' action configurar_venda() image path_imagens+'img_prevda.bmp'
                       separator
                       menuitem 'Incluir ou Excluir Promoção' action iif(libera(_a_041),promocao(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_promocoes.bmp'
                       menuitem 'Reajustar Preços de Produtos' action iif(libera(_a_042),reajuste(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_reajustar.bmp'
                       separator
                       menuitem 'Backup do Banco de Dados' action iif(libera(_a_043),backup(),msgexclamation('Este usuário não possui acesso','Mensagem')) image path_imagens+'img_backup.bmp'
                end popup
                end menu

                * botões (toolbar)
                define buttonex venda_delivery
                       parent form_main
                       picture path_imagens+'delivery.bmp'
                       col 000
                       row 000
                       width 170
                       height 080
                       caption 'F5'+CRLF+'Venda'+CRLF+'Delivery'
                       action iif(libera(_a_001),venda_delivery(),msgexclamation('Este usuário não possui acesso','Mensagem'))
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _preto_001
                       vertical .F.
                       lefttext .F.
                       flat .T.
                       noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex venda_mesas
                       parent form_main
                       picture path_imagens+'mesas.bmp'
                       col 170
                       row 000
                       width 170
                       height 080
                       caption 'F6'+CRLF+'Venda'+CRLF+'Mesas'
                       action iif(libera(_a_002),venda_mesas(),msgexclamation('Este usuário não possui acesso','Mensagem'))
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _preto_001
                       vertical .F.
                       lefttext .F.
                       flat .T.
                       noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex venda_balcao
                       parent form_main
                       picture path_imagens+'balcao.bmp'
                       col 340
                       row 000
                       width 170
                       height 080
                       caption 'F7'+CRLF+'Venda'+CRLF+'Balcão'
                       action iif(libera(_a_003),venda_balcao(),msgexclamation('Este usuário não possui acesso','Mensagem'))
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _preto_001
                       vertical .F.
                       lefttext .F.
                       flat .T.
                       noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex clientes
                       parent form_main
                       picture path_imagens+'clientes.bmp'
                       col 510
                       row 000
                       width 170
                       height 080
                       caption 'F8'+CRLF+'Cadastro'+CRLF+'Clientes'
                       action iif(libera(_a_004),clientes(),msgexclamation('Este usuário não possui acesso','Mensagem'))
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _preto_001
                       vertical .F.
                       lefttext .F.
                       flat .T.
                       noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex produtos
                       parent form_main
                       picture path_imagens+'produtos.bmp'
                       col 680
                       row 000
                       width 170
                       height 080
                       caption 'F9'+CRLF+'Cadastro'+CRLF+'Produtos'
                       action iif(libera(_a_005),produtos(),msgexclamation('Este usuário não possui acesso','Mensagem'))
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _preto_001
                       vertical .F.
                       lefttext .F.
                       flat .T.
                       noxpstyle .T.
                       backcolor _branco_001
                end buttonex
                define buttonex sair_programa
                       parent form_main
                       picture path_imagens+'sair_programa.bmp'
                       col 850
                       row 000
                       width 172
                       height 080
                       caption 'ESC'+CRLF+'Sair do'+CRLF+'Programa'
                       action form_main.release
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _vermelho_002
                       vertical .F.
                       lefttext .F.
                       flat .T.
                       noxpstyle .T.
                       backcolor _branco_001
                end buttonex

                * frame
                define frame frame_main
                       parent form_main
                       col getdesktopwidth()-180
                       row 082
                       caption ''
                       width 175
                       height 300
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       opaque .T.
                       transparent .F.
                end frame

                * acompanhamento dos pedidos e entregas
                define label acompanhamento_001
                       parent form_main
                       col getdesktopwidth()-175
                       row 095
                       value 'tecla F10'
                       action mostra_entregas()
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor YELLOW
                       transparent .T.
                end label
                define label acompanhamento_002
                       parent form_main
                       col getdesktopwidth()-175
                       row 110
                       value 'Acompanhamento dos'
                       action mostra_entregas()
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label
                define label acompanhamento_003
                       parent form_main
                       col getdesktopwidth()-175
                       row 125
                       value 'pedidos feitos'
                       action mostra_entregas()
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label
                define label acompanhamento_004
                       parent form_main
                       col getdesktopwidth()-175
                       row 140
                       value 'em : venda delivery'
                       action mostra_entregas()
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label
                define label acompanhamento_005
                       parent form_main
                       col getdesktopwidth()-175
                       row 155
                       value 'em : venda balcão'
                       action mostra_entregas()
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label

                * operador
                define label operador_001
                       parent form_main
                       col getdesktopwidth()-175
                       row 185
                       value 'Operador atual'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor YELLOW
                       transparent .T.
                end label
                define label operador_002
                       parent form_main
                       col getdesktopwidth()-175
                       row 200
                       value ''
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label
                define label operador_003
                       parent form_main
                       col getdesktopwidth()-175
                       row 215
                       value dtoc(date())+' as '+substr(time(),1,5)+'h'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label

                * número de série do produto
                define label numero_serie_001
                       parent form_main
                       col getdesktopwidth()-170
                       row 330
                       value 'Número de Série'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _branco_001
                       transparent .T.
                end label
                define label numero_serie_002
                       parent form_main
                       col getdesktopwidth()-170
                       row 350
                       value _numero_serie_
                       autosize .T.
                       fontname 'verdana'
                       fontsize 012
                       fontbold .T.
                       fontcolor _ciano_001
                       transparent .T.
                end label

                * nome do cliente e do programa
                define label nome_cliente_001
                       parent form_main
                       col 005
                       row getdesktopheight()-130
                       value ''
                       width 600
                       height 080
                       fontname 'courier new'
                       fontsize 030
                       fontbold .T.
                       fontcolor _ciano_001
                       transparent .T.
                end label
                define label nome_programa_001
                       parent form_main
                       col getdesktopwidth()-310
                       row getdesktopheight()-230
                       value 'SuperChef'
                       width 200
                       height 050
                       fontname 'tahoma'
                       fontsize 022
                       fontbold .T.
                       fontcolor _super
                       transparent .T.
                end label
                define label nome_programa_002
                       parent form_main
                       col getdesktopwidth()-150
                       row getdesktopheight()-230
                       value 'pizza'
                       width 200
                       height 050
                       fontname 'tahoma'
                       fontsize 022
                       fontbold .T.
                       fontcolor _laranja_001
                       transparent .T.
                end label

                * nome da softhouse
                define label softhouse_001
                       parent form_main
                       col getdesktopwidth()-310
                       row getdesktopheight()-190
                       value 'Este software foi desenvolvido por'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _branco_001
                       transparent .T.
                end label
                define label softhouse_002
                       parent form_main
                       col getdesktopwidth()-310
                       row getdesktopheight()-175
                       value 'xxxxxxxxxxxx'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 014
                       fontbold .T.
                       fontcolor _amarelo_001
                       transparent .T.
                end label
                define image brasil
                       row getdesktopheight()-175
                       col getdesktopwidth()-150
                       height 038
                       width 054
                       picture path_imagens+'bandeira_brasil.jpg'
                       stretch .T.
                end image

                * suporte
                define image suporte
                       row getdesktopheight()-135
                       col getdesktopwidth()-360
                       height 048
                       width 048
                       picture path_imagens+'suporte.bmp'
                       stretch .T.
                end image
                define label suporte_001
                       parent form_main
                       col getdesktopwidth()-310
                       row getdesktopheight()-135
                       value 'Para obter suporte técnico deste produto'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _branco_001
                       transparent .T.
                end label
                define label suporte_002
                       parent form_main
                       col getdesktopwidth()-310
                       row getdesktopheight()-120
                       value 'Telefone: (99) 9999-9999'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label
                define label suporte_003
                       parent form_main
                       col getdesktopwidth()-310
                       row getdesktopheight()-105
                       value 'E-mail:xxxxxx@xxxxxxxx.com.br'
                       autosize .T.
                       fontname 'verdana'
                       fontsize 010
                       fontbold .T.
                       fontcolor _cinza_004
                       transparent .T.
                end label

                on key F5 action venda_delivery()
                on key F6 action venda_mesas()
                on key F7 action venda_balcao()
                on key F8 action clientes()
                on key F9 action produtos()
                on key F10 action mostra_entregas()
                on key escape action form_main.release
                
         end window

         form_main.maximize
         form_main.activate

         return(nil)
*-------------------------------------------------------------------------------
static function cria_dbf_cdx()

       local a_dbf := {}
       local x_largura := getdesktopwidth()
       local x_altura := getdesktopheight()

	   if x_largura < 1024 .and. x_altura < 768
	      msgexclamation('Este programa não funciona nesta resolução de tela, tecle ENTER','Atenção')
		  form_main.release
	   endif

       * dados da empresa
	    if .not. file(path_dbf+'empresa.dbf')
          aadd(a_dbf,{'nome','c',40,0})
          aadd(a_dbf,{'fixo_1','c',10,0})
          aadd(a_dbf,{'fixo_2','c',10,0})
          aadd(a_dbf,{'endereco','c',40,0})
          aadd(a_dbf,{'numero','c',06,0})
          aadd(a_dbf,{'complem','c',20,0})
          aadd(a_dbf,{'bairro','c',20,0})
          aadd(a_dbf,{'cidade','c',20,0})
          aadd(a_dbf,{'uf','c',02,0})
          aadd(a_dbf,{'cep','c',08,0})
          aadd(a_dbf,{'email','c',50,0})
          aadd(a_dbf,{'site','c',50,0})
          dbcreate(path_dbf+'empresa',a_dbf)
          dbclosearea()
	       if open_dbf('empresa','empresa',.T.)
             if add_reg()
                empresa->nome     := 'Empresa demonstração'
                empresa->fixo_1   := ''
                empresa->fixo_2   := ''
                empresa->endereco := ''
                empresa->numero   := ''
                empresa->complem  := ''
                empresa->bairro   := ''
                empresa->cidade   := ''
                empresa->uf       := ''
                empresa->cep      := ''
                empresa->email    := ''
                empresa->site     := ''
	             empresa->(dbcommit())
	             empresa->(dbunlock())
             endif
          endif
	       dbclosearea()
       endif

       * essas tabelas serão usadas somente localmente
       a_dbf := {}
       * temp para relatório de pizzas
	    if .not. file('tmprpza.dbf')
          aadd(a_dbf,{'produto','c',40,0})
          aadd(a_dbf,{'qtd','n',10,0})
          dbcreate('tmprpza',a_dbf)
          dbclosearea()
       endif
       a_dbf := {}
       * temp para pizza
	    if .not. file('tmpza.dbf')
          aadd(a_dbf,{'id_produto','c',10,0})
          aadd(a_dbf,{'sequencia','c',10,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'tamanho','c',10,0})
          aadd(a_dbf,{'preco','n',10,2})
          dbcreate('tmpza',a_dbf)
          dbclosearea()
       endif
       a_dbf := {}
       * temp para produto
	    if .not. file('tmpprod.dbf')
          aadd(a_dbf,{'produto','c',10,0})
          aadd(a_dbf,{'nome','c',30,0})
          aadd(a_dbf,{'qtd','n',04,0})
          aadd(a_dbf,{'unitario','n',10,2})
          aadd(a_dbf,{'subtotal','n',12,2})
          dbcreate('tmpprod',a_dbf)
          dbclosearea()
       endif
       a_dbf := {}
       * temp para reajuste
	    if .not. file('tmpreaj.dbf')
          aadd(a_dbf,{'cod_prod','c',10,0})
          aadd(a_dbf,{'nom_prod','c',40,0})
          aadd(a_dbf,{'tam_001','n',10,2})
          aadd(a_dbf,{'tam_002','n',10,2})
          aadd(a_dbf,{'tam_003','n',10,2})
          aadd(a_dbf,{'tam_004','n',10,2})
          aadd(a_dbf,{'tam_005','n',10,2})
          aadd(a_dbf,{'tam_006','n',10,2})
          aadd(a_dbf,{'pre_reaj','n',10,2})
          aadd(a_dbf,{'id_cat','n',6,0})
          aadd(a_dbf,{'id_subcat','n',6,0})
          dbcreate('tmpreaj',a_dbf)
          dbclosearea()
       endif
       a_dbf := {}
       * temp para compras - produtos
	    if .not. file('tmpcpa1.dbf')
          aadd(a_dbf,{'id','c',10,0})
          aadd(a_dbf,{'fornecedor','n',06,0})
          aadd(a_dbf,{'forma_pag','n',06,0})
          aadd(a_dbf,{'num_parc','n',03,0})
          aadd(a_dbf,{'data_venc','d',08,0})
          aadd(a_dbf,{'dias_parc','n',03,0})
          aadd(a_dbf,{'produto','c',10,0})
          aadd(a_dbf,{'qtd','n',06,0})
          aadd(a_dbf,{'vlr_unit','n',12,2})
          aadd(a_dbf,{'num_doc','c',15,0})
          dbcreate('tmpcpa1',a_dbf)
          dbclosearea()
       endif
       a_dbf := {}
       * temp para compras - matéria prima
	    if .not. file('tmpcpa2.dbf')
          aadd(a_dbf,{'id','c',10,0})
          aadd(a_dbf,{'fornecedor','n',06,0})
          aadd(a_dbf,{'forma_pag','n',06,0})
          aadd(a_dbf,{'num_parc','n',03,0})
          aadd(a_dbf,{'data_venc','d',08,0})
          aadd(a_dbf,{'dias_parc','n',03,0})
          aadd(a_dbf,{'mat_prima','n',06,0})
          aadd(a_dbf,{'qtd','n',12,3})
          aadd(a_dbf,{'vlr_unit','n',12,2})
          aadd(a_dbf,{'num_doc','c',15,0})
          dbcreate('tmpcpa2',a_dbf)
          dbclosearea()
       endif

       a_dbf := {}
       * dbf igual ao temp para compras - produtos (rede)
	    if .not. file(path_dbf+'tcompra1.dbf')
          aadd(a_dbf,{'fornecedor','n',06,0})
          aadd(a_dbf,{'forma_pag','n',06,0})
          aadd(a_dbf,{'num_parc','n',03,0})
          aadd(a_dbf,{'data_venc','d',08,0})
          aadd(a_dbf,{'dias_parc','n',03,0})
          aadd(a_dbf,{'produto','c',10,0})
          aadd(a_dbf,{'qtd','n',06,0})
          aadd(a_dbf,{'vlr_unit','n',12,2})
          aadd(a_dbf,{'num_doc','c',15,0})
          dbcreate(path_dbf+'tcompra1',a_dbf)
          dbclosearea()
       endif

       a_dbf := {}
       * dbf igual ao temp para compras - matéria prima (rede)
	    if .not. file(path_dbf+'tcompra2.dbf')
          aadd(a_dbf,{'fornecedor','n',06,0})
          aadd(a_dbf,{'forma_pag','n',06,0})
          aadd(a_dbf,{'num_parc','n',03,0})
          aadd(a_dbf,{'data_venc','d',08,0})
          aadd(a_dbf,{'dias_parc','n',03,0})
          aadd(a_dbf,{'mat_prima','n',06,0})
          aadd(a_dbf,{'qtd','n',12,3})
          aadd(a_dbf,{'vlr_unit','n',12,2})
          aadd(a_dbf,{'num_doc','c',15,0})
          dbcreate(path_dbf+'tcompra2',a_dbf)
          dbclosearea()
       endif

       a_dbf := {}
       * tamanhos de pizza - pré definido
	    if .not. file(path_dbf+'tamanhos.dbf')
          aadd(a_dbf,{'nome','c',15,0})
          aadd(a_dbf,{'pedacos','n',02,0})
          dbcreate(path_dbf+'tamanhos',a_dbf)
          dbclosearea()
	       if open_dbf('tamanhos','tamanhos',.T.)
             if add_reg()
                tamanhos->nome    := 'definir'
                tamanhos->pedacos := 1
	             tamanhos->(dbcommit())
	             tamanhos->(dbunlock())
             endif
             if add_reg()
                tamanhos->nome    := 'definir'
                tamanhos->pedacos := 1
	             tamanhos->(dbcommit())
	             tamanhos->(dbunlock())
             endif
             if add_reg()
                tamanhos->nome    := 'definir'
                tamanhos->pedacos := 1
	             tamanhos->(dbcommit())
	             tamanhos->(dbunlock())
             endif
             if add_reg()
                tamanhos->nome     := 'definir'
                tamanhos->pedacos := 1
	             tamanhos->(dbcommit())
	             tamanhos->(dbunlock())
             endif
             if add_reg()
                tamanhos->nome    := 'definir'
                tamanhos->pedacos := 1
	             tamanhos->(dbcommit())
	             tamanhos->(dbunlock())
             endif
             if add_reg()
                tamanhos->nome    := 'definir'
                tamanhos->pedacos := 1
	             tamanhos->(dbcommit())
	             tamanhos->(dbunlock())
             endif
          endif
	       dbclosearea()
       endif

       a_dbf := {}
       * bordas de pizza - pré definido
	    if .not. file(path_dbf+'bordas.dbf')
          aadd(a_dbf,{'nome','c',15,0})
          aadd(a_dbf,{'preco','n',10,2})
          dbcreate(path_dbf+'bordas',a_dbf)
          dbclosearea()
	       if open_dbf('bordas','bordas',.T.)
             if add_reg()
                bordas->nome  := 'Sem borda'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
             if add_reg()
                bordas->nome  := 'definir'
                bordas->preco := 0
	            bordas->(dbcommit())
	            bordas->(dbunlock())
             endif
           endif
	       dbclosearea()
       endif

       a_dbf := {}
       * códigos
	    if .not. file(path_dbf+'conta.dbf')
          aadd(a_dbf,{'c_clientes','n',06,0})
          aadd(a_dbf,{'c_fornec','n',06,0})
          aadd(a_dbf,{'c_gfornec','n',04,0})
          aadd(a_dbf,{'c_mprima','n',06,0})
          aadd(a_dbf,{'c_catprod','n',04,0})
          aadd(a_dbf,{'c_scatprod','n',04,0})
          aadd(a_dbf,{'c_mesas','n',04,0})
          aadd(a_dbf,{'c_frecebe','n',04,0})
          aadd(a_dbf,{'c_fpaga','n',04,0})
          aadd(a_dbf,{'c_umedida','n',04,0})
          aadd(a_dbf,{'c_bancos','n',04,0})
          aadd(a_dbf,{'c_impostos','n',04,0})
          aadd(a_dbf,{'c_atende','n',04,0})
          aadd(a_dbf,{'c_motent','n',04,0})
          aadd(a_dbf,{'c_operador','n',04,0})
          dbcreate(path_dbf+'conta',a_dbf)
          dbclosearea()
	       if open_dbf('conta','conta',.T.)
             if add_reg()
                conta->c_clientes := 1
                conta->c_fornec   := 1
                conta->c_gfornec  := 1
                conta->c_mprima   := 1
                conta->c_catprod  := 1
                conta->c_scatprod := 1
                conta->c_mesas    := 1
                conta->c_frecebe  := 1
                conta->c_fpaga    := 1
                conta->c_umedida  := 1
                conta->c_bancos   := 1
                conta->c_impostos := 1
                conta->c_atende   := 1
                conta->c_motent   := 1
                conta->c_operador := 1
	             conta->(dbcommit())
	             conta->(dbunlock())
             endif
          endif
	       dbclosearea()
       endif

       a_dbf := {}
       * clientes
	    if .not. file(path_dbf+'clientes.dbf')
          aadd(a_dbf,{'codigo','n',06,0})
          aadd(a_dbf,{'nome','c',40,0})
          aadd(a_dbf,{'fixo','c',10,0})
          aadd(a_dbf,{'celular','c',10,0})
          aadd(a_dbf,{'endereco','c',40,0})
          aadd(a_dbf,{'numero','c',06,0})
          aadd(a_dbf,{'complem','c',20,0})
          aadd(a_dbf,{'bairro','c',20,0})
          aadd(a_dbf,{'cidade','c',20,0})
          aadd(a_dbf,{'uf','c',02,0})
          aadd(a_dbf,{'cep','c',08,0})
          aadd(a_dbf,{'email','c',50,0})
          aadd(a_dbf,{'aniv_dia','n',02,0})
          aadd(a_dbf,{'aniv_mes','n',02,0})
          dbcreate(path_dbf+'clientes',a_dbf)
          dbclosearea()
          if open_dbf('clientes','clientes',.T.)
             if add_reg()
                clientes->codigo := 999999
                clientes->nome   := 'Cliente - venda mesa'
	             clientes->(dbcommit())
	             clientes->(dbunlock())
              endif
              dbclosearea()
          endif
       endif
       if .not. file(path_dbf+'clientes.cdx')
          if open_dbf('clientes','clientes',.F.)
             index on codigo tag codigo to (path_dbf)+'clientes.cdx'
             index on nome tag nome to (path_dbf)+'clientes.cdx'
             index on fixo tag fixo to (path_dbf)+'clientes.cdx'
             index on celular tag celular to (path_dbf)+'clientes.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * fornecedores
	    if .not. file(path_dbf+'fornec.dbf')
          aadd(a_dbf,{'codigo','n',06,0})
          aadd(a_dbf,{'nome','c',40,0})
          aadd(a_dbf,{'fixo','c',10,0})
          aadd(a_dbf,{'celular','c',10,0})
          aadd(a_dbf,{'endereco','c',40,0})
          aadd(a_dbf,{'numero','c',06,0})
          aadd(a_dbf,{'complem','c',20,0})
          aadd(a_dbf,{'bairro','c',20,0})
          aadd(a_dbf,{'cidade','c',20,0})
          aadd(a_dbf,{'uf','c',02,0})
          aadd(a_dbf,{'cep','c',08,0})
          aadd(a_dbf,{'email','c',50,0})
          aadd(a_dbf,{'grupo','n',04,0})
          dbcreate(path_dbf+'fornec',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'fornec.cdx')
          if open_dbf('fornec','fornecedores',.F.)
             index on codigo tag codigo to (path_dbf)+'fornec.cdx'
             index on nome tag nome to (path_dbf)+'fornec.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * grupo de fornecedores
	    if .not. file(path_dbf+'gfornec.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          dbcreate(path_dbf+'gfornec',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'gfornec.cdx')
          if open_dbf('gfornec','grupo_fornecedores',.F.)
             index on codigo tag codigo to (path_dbf)+'gfornec.cdx'
             index on nome tag nome to (path_dbf)+'gfornec.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * matéria prima
	    if .not. file(path_dbf+'mprima.dbf')
          aadd(a_dbf,{'codigo','n',06,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'unidade','n',04,0})
          aadd(a_dbf,{'preco','n',10,2})
          aadd(a_dbf,{'qtd','n',12,3})
          dbcreate(path_dbf+'mprima',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'mprima.cdx')
          if open_dbf('mprima','materia_prima',.F.)
             index on codigo tag codigo to (path_dbf)+'mprima.cdx'
             index on nome tag nome to (path_dbf)+'mprima.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * categoria de produtos
	    if .not. file(path_dbf+'catprod.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          dbcreate(path_dbf+'catprod',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'catprod.cdx')
          if open_dbf('catprod','categoria_produtos',.F.)
             index on codigo tag codigo to (path_dbf)+'catprod.cdx'
             index on nome tag nome to (path_dbf)+'catprod.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * sub-categoria de produtos
	    if .not. file(path_dbf+'scatprod.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          dbcreate(path_dbf+'scatprod',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'scatprod.cdx')
          if open_dbf('scatprod','subcategoria_produtos',.F.)
             index on codigo tag codigo to (path_dbf)+'scatprod.cdx'
             index on nome tag nome to (path_dbf)+'scatprod.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * mesas
	    if .not. file(path_dbf+'mesas.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'hora','c',10,0})
          aadd(a_dbf,{'id','c',18,0})
          dbcreate(path_dbf+'mesas',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'mesas.cdx')
          if open_dbf('mesas','mesas',.F.)
             index on codigo tag codigo to (path_dbf)+'mesas.cdx'
             index on nome tag nome to (path_dbf)+'mesas.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * formas de recebimento
	    if .not. file(path_dbf+'frecebe.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'banco','n',04,0})
          aadd(a_dbf,{'dias_receb','n',02,0})
          dbcreate(path_dbf+'frecebe',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'frecebe.cdx')
          if open_dbf('frecebe','formas_recebimento',.F.)
             index on codigo tag codigo to (path_dbf)+'frecebe.cdx'
             index on nome tag nome to (path_dbf)+'frecebe.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * formas de pagamento
	    if .not. file(path_dbf+'fpaga.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'banco','n',04,0})
          aadd(a_dbf,{'dias_paga','n',02,0})
          dbcreate(path_dbf+'fpaga',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'fpaga.cdx')
          if open_dbf('fpaga','formas_pagamento',.F.)
             index on codigo tag codigo to (path_dbf)+'fpaga.cdx'
             index on nome tag nome to (path_dbf)+'fpaga.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * unidades de medida
	    if .not. file(path_dbf+'umedida.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',10,0})
          dbcreate(path_dbf+'umedida',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'umedida.cdx')
          if open_dbf('umedida','unidade_medida',.F.)
             index on codigo tag codigo to (path_dbf)+'umedida.cdx'
             index on nome tag nome to (path_dbf)+'umedida.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * contas bancárias
	    if .not. file(path_dbf+'bancos.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'banco','c',10,0})
          aadd(a_dbf,{'agencia','c',10,0})
          aadd(a_dbf,{'conta_c','c',10,0})
          aadd(a_dbf,{'limite','n',12,2})
          aadd(a_dbf,{'titular','c',20,0})
          aadd(a_dbf,{'gerente','c',20,0})
          aadd(a_dbf,{'telefone','c',10,0})
          dbcreate(path_dbf+'bancos',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'bancos.cdx')
          if open_dbf('bancos','bancos',.F.)
             index on codigo tag codigo to (path_dbf)+'bancos.cdx'
             index on nome tag nome to (path_dbf)+'bancos.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * impostos e alíquotas
	    if .not. file(path_dbf+'impostos.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'aliquota','n',10,2})
          dbcreate(path_dbf+'impostos',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'impostos.cdx')
          if open_dbf('impostos','impostos',.F.)
             index on codigo tag codigo to (path_dbf)+'impostos.cdx'
             index on nome tag nome to (path_dbf)+'impostos.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * atendentes
	    if .not. file(path_dbf+'atende.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'comissao','n',10,2})
          dbcreate(path_dbf+'atende',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'atende.cdx')
          if open_dbf('atende','atendentes',.F.)
             index on codigo tag codigo to (path_dbf)+'atende.cdx'
             index on nome tag nome to (path_dbf)+'atende.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * motoboys ou entregadores
	    if .not. file(path_dbf+'motent.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'comissao','n',10,2})
          aadd(a_dbf,{'diaria','n',10,2})
          aadd(a_dbf,{'fixo','c',10,0})
          aadd(a_dbf,{'celular','c',10,0})
          aadd(a_dbf,{'endereco','c',40,0})
          aadd(a_dbf,{'numero','c',10,0})
          aadd(a_dbf,{'complem','c',20,0})
          aadd(a_dbf,{'bairro','c',20,0})
          aadd(a_dbf,{'cidade','c',20,0})
          aadd(a_dbf,{'uf','c',02,0})
          aadd(a_dbf,{'cep','c',08,0})
          aadd(a_dbf,{'email','c',40,0})
          dbcreate(path_dbf+'motent',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'motent.cdx')
          if open_dbf('motent','motoboys',.F.)
             index on codigo tag codigo to (path_dbf)+'motent.cdx'
             index on nome tag nome to (path_dbf)+'motent.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * operadores do programa
	    if .not. file(path_dbf+'operador.dbf')
          aadd(a_dbf,{'codigo','n',04,0})
          aadd(a_dbf,{'nome','c',10,0})
          aadd(a_dbf,{'senha','c',10,0})
          dbcreate(path_dbf+'operador',a_dbf)
          dbclosearea()
          if open_dbf('operador','operadores',.T.)
             if add_reg()
                operadores->codigo := 9999
                operadores->nome   := 'SChef'
                operadores->senha  := '9999'
	             operadores->(dbcommit())
	             operadores->(dbunlock())
              endif
              dbclosearea()
          endif
       endif
       if .not. file(path_dbf+'operador.cdx')
          if open_dbf('operador','operadores',.F.)
             index on codigo tag codigo to (path_dbf)+'operador.cdx'
             index on nome tag nome to (path_dbf)+'operador.cdx'
             index on senha tag senha to (path_dbf)+'operador.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * definir acesso aos operadores do programa
	    if .not. file(path_dbf+'libusu.dbf')
          aadd(a_dbf,{'operador','n',04,0})   //id do operador
          aadd(a_dbf,{'acesso_001','l',01,0}) //venda delivery
          aadd(a_dbf,{'acesso_002','l',01,0}) //venda mesas
          aadd(a_dbf,{'acesso_003','l',01,0}) //venda balcão
          aadd(a_dbf,{'acesso_004','l',01,0}) //clientes
          aadd(a_dbf,{'acesso_005','l',01,0}) //produtos
          
          aadd(a_dbf,{'acesso_006','l',01,0}) //fornecedores
          aadd(a_dbf,{'acesso_007','l',01,0}) //grupo de fornecedores
          aadd(a_dbf,{'acesso_008','l',01,0}) //matéria prima
          aadd(a_dbf,{'acesso_009','l',01,0}) //categorias de produtos
          aadd(a_dbf,{'acesso_010','l',01,0}) //sub-categoria de produtos
          aadd(a_dbf,{'acesso_011','l',01,0}) //formas de recebimento
          aadd(a_dbf,{'acesso_012','l',01,0}) //formas de pagamento
          aadd(a_dbf,{'acesso_013','l',01,0}) //unidades de medida
          aadd(a_dbf,{'acesso_014','l',01,0}) //contas bancárias
          aadd(a_dbf,{'acesso_015','l',01,0}) //impostos e alíquotas
          aadd(a_dbf,{'acesso_016','l',01,0}) //mesas da pizzaria
          aadd(a_dbf,{'acesso_017','l',01,0}) //atendentes ou garçons
          aadd(a_dbf,{'acesso_018','l',01,0}) //motoboys ou entregadores
          aadd(a_dbf,{'acesso_019','l',01,0}) //operadores do programa
          
          aadd(a_dbf,{'acesso_020','l',01,0}) //fechamento do dia de trabalho
          aadd(a_dbf,{'acesso_021','l',01,0}) //movimentação do caixa
          aadd(a_dbf,{'acesso_022','l',01,0}) //movimentação bancária
          aadd(a_dbf,{'acesso_023','l',01,0}) //contas a pagar por período
          aadd(a_dbf,{'acesso_024','l',01,0}) //contas a pagar por fornecedor
          aadd(a_dbf,{'acesso_025','l',01,0}) //contas a receber por período
          aadd(a_dbf,{'acesso_026','l',01,0}) //contas a receber por cliente
          aadd(a_dbf,{'acesso_027','l',01,0}) //pizzas mais vendidas
          aadd(a_dbf,{'acesso_028','l',01,0}) //produtos mais vendidos
          aadd(a_dbf,{'acesso_029','l',01,0}) //relação estoque mínimo
          aadd(a_dbf,{'acesso_030','l',01,0}) //posição do estoque (produtos)
          aadd(a_dbf,{'acesso_031','l',01,0}) //posição do estoque (matéria prima)
          aadd(a_dbf,{'acesso_032','l',01,0}) //comissão motoboys/entregadores
          aadd(a_dbf,{'acesso_033','l',01,0}) //comissão atendentes/garçons
          
          aadd(a_dbf,{'acesso_034','l',01,0}) //movimentação do caixa
          aadd(a_dbf,{'acesso_035','l',01,0}) //movimentação bancária
          aadd(a_dbf,{'acesso_036','l',01,0}) //compras / entrada estoque
          aadd(a_dbf,{'acesso_037','l',01,0}) //contas a pagar
          aadd(a_dbf,{'acesso_038','l',01,0}) //contas a receber
          
          aadd(a_dbf,{'acesso_039','l',01,0}) //tamanhos de pizza
          aadd(a_dbf,{'acesso_040','l',01,0}) //cadastro da pizzaria
          aadd(a_dbf,{'acesso_041','l',01,0}) //incluir ou excluir promoção
          aadd(a_dbf,{'acesso_042','l',01,0}) //reajustar preços de produtos
          aadd(a_dbf,{'acesso_043','l',01,0}) //backup do banco de dados
          aadd(a_dbf,{'acesso_044','l',01,0})
          aadd(a_dbf,{'acesso_045','l',01,0})
          aadd(a_dbf,{'acesso_046','l',01,0})
          aadd(a_dbf,{'acesso_047','l',01,0})
          aadd(a_dbf,{'acesso_048','l',01,0})
          aadd(a_dbf,{'acesso_049','l',01,0})
          aadd(a_dbf,{'acesso_050','l',01,0})
          aadd(a_dbf,{'acesso_051','l',01,0})
          aadd(a_dbf,{'acesso_052','l',01,0})
          aadd(a_dbf,{'acesso_053','l',01,0})
          aadd(a_dbf,{'acesso_054','l',01,0})
          aadd(a_dbf,{'acesso_055','l',01,0})
          aadd(a_dbf,{'acesso_056','l',01,0})
          aadd(a_dbf,{'acesso_057','l',01,0})
          aadd(a_dbf,{'acesso_058','l',01,0})
          aadd(a_dbf,{'acesso_059','l',01,0})
          aadd(a_dbf,{'acesso_060','l',01,0})
          aadd(a_dbf,{'acesso_061','l',01,0})
          aadd(a_dbf,{'acesso_062','l',01,0})
          aadd(a_dbf,{'acesso_063','l',01,0})
          aadd(a_dbf,{'acesso_064','l',01,0})
          aadd(a_dbf,{'acesso_065','l',01,0})
          aadd(a_dbf,{'acesso_066','l',01,0})
          aadd(a_dbf,{'acesso_067','l',01,0})
          aadd(a_dbf,{'acesso_068','l',01,0})
          aadd(a_dbf,{'acesso_069','l',01,0})
          aadd(a_dbf,{'acesso_070','l',01,0})
          aadd(a_dbf,{'acesso_071','l',01,0})
          aadd(a_dbf,{'acesso_072','l',01,0})
          aadd(a_dbf,{'acesso_073','l',01,0})
          aadd(a_dbf,{'acesso_074','l',01,0})
          aadd(a_dbf,{'acesso_075','l',01,0})
          aadd(a_dbf,{'acesso_076','l',01,0})
          aadd(a_dbf,{'acesso_077','l',01,0})
          aadd(a_dbf,{'acesso_078','l',01,0})
          aadd(a_dbf,{'acesso_079','l',01,0})
          aadd(a_dbf,{'acesso_080','l',01,0})
          aadd(a_dbf,{'acesso_081','l',01,0})
          aadd(a_dbf,{'acesso_082','l',01,0})
          aadd(a_dbf,{'acesso_083','l',01,0})
          aadd(a_dbf,{'acesso_084','l',01,0})
          aadd(a_dbf,{'acesso_085','l',01,0})
          aadd(a_dbf,{'acesso_086','l',01,0})
          aadd(a_dbf,{'acesso_087','l',01,0})
          aadd(a_dbf,{'acesso_088','l',01,0})
          aadd(a_dbf,{'acesso_089','l',01,0})
          aadd(a_dbf,{'acesso_090','l',01,0})
          aadd(a_dbf,{'acesso_091','l',01,0})
          aadd(a_dbf,{'acesso_092','l',01,0})
          aadd(a_dbf,{'acesso_093','l',01,0})
          aadd(a_dbf,{'acesso_094','l',01,0})
          aadd(a_dbf,{'acesso_095','l',01,0})
          aadd(a_dbf,{'acesso_096','l',01,0})
          aadd(a_dbf,{'acesso_097','l',01,0})
          aadd(a_dbf,{'acesso_098','l',01,0})
          aadd(a_dbf,{'acesso_099','l',01,0})
          aadd(a_dbf,{'acesso_100','l',01,0})
          dbcreate(path_dbf+'libusu',a_dbf)
          dbclosearea()
          if open_dbf('libusu','acesso',.T.)
             if add_reg()
                acesso->operador   := 9999
                acesso->acesso_019 := .T.
	             acesso->(dbcommit())
	             acesso->(dbunlock())
              endif
              dbclosearea()
          endif
       endif
       if .not. file(path_dbf+'libusu.cdx')
          if open_dbf('libusu','acesso',.F.)
             index on operador tag operador to (path_dbf)+'libusu.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * produtos
	    if .not. file(path_dbf+'produtos.dbf')
          aadd(a_dbf,{'codigo','c',10,0})
          aadd(a_dbf,{'cbarra','c',15,0})
          aadd(a_dbf,{'nome_longo','c',40,0})
          aadd(a_dbf,{'nome_cupom','c',15,0})
          aadd(a_dbf,{'categoria','n',04,0})
          aadd(a_dbf,{'scategoria','n',04,0})
          aadd(a_dbf,{'imposto','n',04,0})
          aadd(a_dbf,{'baixa','l',01,0})
          aadd(a_dbf,{'qtd_estoq','n',06,0})
          aadd(a_dbf,{'qtd_min','n',06,0})
          aadd(a_dbf,{'qtd_max','n',06,0})
          aadd(a_dbf,{'vlr_custo','n',12,2})
          aadd(a_dbf,{'vlr_venda','n',12,2})
          aadd(a_dbf,{'promocao','l',01,0})
          aadd(a_dbf,{'pizza','l',01,0})
          aadd(a_dbf,{'val_tm_001','n',10,2})
          aadd(a_dbf,{'val_tm_002','n',10,2})
          aadd(a_dbf,{'val_tm_003','n',10,2})
          aadd(a_dbf,{'val_tm_004','n',10,2})
          aadd(a_dbf,{'val_tm_005','n',10,2})
          aadd(a_dbf,{'val_tm_006','n',10,2})
          dbcreate(path_dbf+'produtos',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'produtos.cdx')
          if open_dbf('produtos','produtos',.F.)
             index on codigo tag codigo to (path_dbf)+'produtos.cdx'
             index on cbarra tag cbarra to (path_dbf)+'produtos.cdx'
             index on nome_longo tag nome_longo to (path_dbf)+'produtos.cdx'
             index on nome_cupom tag nome_cupom to (path_dbf)+'produtos.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * ultimas compras do cliente
	    if .not. file(path_dbf+'cli_uc.dbf')
          aadd(a_dbf,{'id_cliente','n',06,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'hora','c',08,0})
          aadd(a_dbf,{'onde','n',01,0})
          aadd(a_dbf,{'valor','n',12,2})
          dbcreate(path_dbf+'cli_uc',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'cli_uc.cdx')
          if open_dbf('cli_uc','ultimas_compras',.F.)
             index on id_cliente tag id_cliente to (path_dbf)+'cli_uc.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * detalhamento - ultimas compras do cliente
	    if .not. file(path_dbf+'cli_dc.dbf')
          aadd(a_dbf,{'id_cliente','n',06,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'hora','c',08,0})
          aadd(a_dbf,{'id_prod','c',10,0})
          aadd(a_dbf,{'qtd','n',06,0})
          aadd(a_dbf,{'unitario','n',10,2})
          aadd(a_dbf,{'subtotal','n',12,2})
          dbcreate(path_dbf+'cli_dc',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'cli_dc.cdx')
          if open_dbf('cli_dc','detalhamento_compras',.F.)
             index on str(id_cliente,6)+dtos(data)+hora tag id to (path_dbf)+'cli_dc.cdx'
             index on dtos(data) tag data to (path_dbf)+'cli_dc.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * composição de produto
	    if .not. file(path_dbf+'prodcomp.dbf')
          aadd(a_dbf,{'id_produto','c',10,0})
          aadd(a_dbf,{'id_mprima','n',06,0})
          aadd(a_dbf,{'quantidade','n',12,3})
          dbcreate(path_dbf+'prodcomp',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'prodcomp.cdx')
          if open_dbf('prodcomp','produto_composto',.F.)
             index on id_produto tag id_produto to (path_dbf)+'prodcomp.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * caixa
	    if .not. file(path_dbf+'caixa.dbf')
          aadd(a_dbf,{'id','c',10,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'historico','c',30,0})
          aadd(a_dbf,{'entrada','n',12,2})
          aadd(a_dbf,{'saida','n',12,2})
          dbcreate(path_dbf+'caixa',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'caixa.cdx')
          if open_dbf('caixa','caixa',.F.)
             index on id tag id to (path_dbf)+'caixa.cdx'
             index on dtos(data) tag data to (path_dbf)+'caixa.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * movimento bancário
	    if .not. file(path_dbf+'movban.dbf')
          aadd(a_dbf,{'id','c',10,0})
          aadd(a_dbf,{'banco','n',04,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'historico','c',30,0})
          aadd(a_dbf,{'entrada','n',12,2})
          aadd(a_dbf,{'saida','n',12,2})
          dbcreate(path_dbf+'movban',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'movban.cdx')
          if open_dbf('movban','movimento_bancario',.F.)
             index on id tag id to (path_dbf)+'movban.cdx'
             index on dtos(data) tag data to (path_dbf)+'movban.cdx'
             index on str(banco,4)+dtos(data) tag composto to (path_dbf)+'movban.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * contas a pagar
	    if .not. file(path_dbf+'cpag.dbf')
          aadd(a_dbf,{'id','c',10,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'valor','n',12,2})
          aadd(a_dbf,{'forma','n',06,0})
          aadd(a_dbf,{'fornec','n',06,0})
          aadd(a_dbf,{'numero','c',15,0})
          aadd(a_dbf,{'obs','c',30,0})
          aadd(a_dbf,{'baixa','l',01,0})
          dbcreate(path_dbf+'cpag',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'cpag.cdx')
          if open_dbf('cpag','contas_pagar',.F.)
             index on id tag id to (path_dbf)+'cpag.cdx'
             index on dtos(data) tag data to (path_dbf)+'cpag.cdx'
             index on str(fornec,6)+dtos(data) tag composto to (path_dbf)+'cpag.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * contas a receber
	    if .not. file(path_dbf+'crec.dbf')
          aadd(a_dbf,{'id','c',10,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'valor','n',12,2})
          aadd(a_dbf,{'forma','n',06,0})
          aadd(a_dbf,{'cliente','n',06,0})
          aadd(a_dbf,{'numero','c',15,0})
          aadd(a_dbf,{'obs','c',30,0})
          aadd(a_dbf,{'baixa','l',01,0})
          dbcreate(path_dbf+'crec',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'crec.cdx')
          if open_dbf('crec','contas_receber',.F.)
             index on id tag id to (path_dbf)+'crec.cdx'
             index on dtos(data) tag data to (path_dbf)+'crec.cdx'
             index on str(cliente,6)+dtos(data) tag composto to (path_dbf)+'crec.cdx'
          endif
          dbclosearea()
       endif

       a_dbf := {}
       * comissões dos motoboys
	    if .not. file(path_dbf+'comissao.dbf')
          aadd(a_dbf,{'id','n',04,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'hora','c',08,0})
          aadd(a_dbf,{'valor','n',12,2})
          dbcreate(path_dbf+'comissao',a_dbf)
          dbclosearea()
       endif

       a_dbf := {}
       * comissões de atendentes/garçons
	    if .not. file(path_dbf+'com_mesa.dbf')
          aadd(a_dbf,{'id','n',04,0})
          aadd(a_dbf,{'data','d',08,0})
          aadd(a_dbf,{'hora','c',08,0})
          aadd(a_dbf,{'valor','n',12,2})
          dbcreate(path_dbf+'com_mesa',a_dbf)
          dbclosearea()
       endif

       a_dbf := {}
       * entregas
	    if .not. file(path_dbf+'entrega.dbf')
          aadd(a_dbf,{'cliente','c',30,0})
          aadd(a_dbf,{'endereco','c',30,0})
          aadd(a_dbf,{'hora','c',08,0})
          aadd(a_dbf,{'origem','c',10,0})
          aadd(a_dbf,{'telefone','c',10,0})
          aadd(a_dbf,{'cod_moto','n',04,0})
          aadd(a_dbf,{'motoboy','c',15,0})
          aadd(a_dbf,{'situacao','c',15,0})
          aadd(a_dbf,{'vlr_taxa','n',10,2})
          dbcreate(path_dbf+'entrega',a_dbf)
          dbclosearea()
       endif

       *----------
       
       a_dbf := {}
       * temp para pizza - em rede - compartilhado - venda mesas
	    if .not. file(path_dbf+'tmp_pza.dbf')
          aadd(a_dbf,{'id_mesa','c',18,0})
          aadd(a_dbf,{'id_produto','c',10,0})
          aadd(a_dbf,{'sequencia','c',10,0})
          aadd(a_dbf,{'nome','c',20,0})
          aadd(a_dbf,{'tamanho','c',10,0})
          aadd(a_dbf,{'preco','n',10,2})
          dbcreate(path_dbf+'tmp_pza',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'tmp_pza.cdx')
          if open_dbf('tmp_pza','temp_pizzas',.F.)
             index on id_mesa tag id to (path_dbf)+'tmp_pza.cdx'
          endif
          dbclosearea()
       endif
       *----
       a_dbf := {}
       * temp para pizzas e produtos na venda delivery
	    if .not. file(path_dbf+'tmp_vda.dbf')
          aadd(a_dbf,{'seq','n',10,0})
          aadd(a_dbf,{'id','c',15,0})
          aadd(a_dbf,{'tipo','n',1,0})
          aadd(a_dbf,{'produto','c',10,0})
          aadd(a_dbf,{'preco','n',10,2})
          aadd(a_dbf,{'sequencia','c',10,0})
          aadd(a_dbf,{'nome','c',30,0})
          aadd(a_dbf,{'qtd','n',04,0})
          aadd(a_dbf,{'unitario','n',10,2})
          aadd(a_dbf,{'subtotal','n',12,2})
          dbcreate(path_dbf+'tmp_vda',a_dbf)
          dbclosearea()
       endif
       *----
       a_dbf := {}
       * temp para mostrar os itens vendidos de uma forma mais amigável na tela de vendas
	    if .not. file(path_dbf+'tmp_tela.dbf')
          aadd(a_dbf,{'seq','n',10,0})
          aadd(a_dbf,{'item','c',40,0})
          aadd(a_dbf,{'qtd','n',6,0})
          aadd(a_dbf,{'unitario','n',10,2})
          aadd(a_dbf,{'subtotal','n',12,2})
          dbcreate(path_dbf+'tmp_tela',a_dbf)
          dbclosearea()
       endif
       *----
       a_dbf := {}
       * temp para classificar valor de pizza
	    if .not. file(path_dbf+'tmp_cpz.dbf')
          aadd(a_dbf,{'preco','n',10,2})
          dbcreate(path_dbf+'tmp_cpz',a_dbf)
          dbclosearea()
       endif
       *----
       a_dbf := {}
       * temp para produto - em rede - compartilhado - venda mesas
	    if .not. file(path_dbf+'tmp_prd.dbf')
          aadd(a_dbf,{'id_mesa','c',18,0})
          aadd(a_dbf,{'produto','c',10,0})
          aadd(a_dbf,{'nome','c',30,0})
          aadd(a_dbf,{'qtd','n',04,0})
          aadd(a_dbf,{'unitario','n',10,2})
          aadd(a_dbf,{'subtotal','n',12,2})
          dbcreate(path_dbf+'tmp_prd',a_dbf)
          dbclosearea()
       endif
       if .not. file(path_dbf+'tmp_prd.cdx')
          if open_dbf('tmp_prd','temp_produtos',.F.)
             index on id_mesa tag id to (path_dbf)+'tmp_prd.cdx'
          endif
          dbclosearea()
       endif
       *----
       a_dbf := {}
       * temp para montagem das pizzas
	    if .not. file(path_dbf+'montagem.dbf')
          aadd(a_dbf,{'id','c',10,0})
          aadd(a_dbf,{'nome','c',30,0})
          dbcreate(path_dbf+'montagem',a_dbf)
          dbclosearea()
       endif
       *----
       a_dbf := {}
       * config para determinar como será cobrança do preço da pizza
	    if .not. file(path_dbf+'config.dbf')
          aadd(a_dbf,{'tipo','n',1,0})
          dbcreate(path_dbf+'config',a_dbf)
          dbclosearea()
          if open_dbf('config','config',.T.)
             if add_reg()
                config->tipo := 1
             	config->(dbcommit())
             	config->(dbunlock())
              endif
              dbclosearea()
          endif
       endif

       *----
       
       open_dbf_cdx()

       dbselectarea('empresa')
       empresa->(dbgotop())
       setproperty('form_main','nome_cliente_001','value',substr(empresa->nome,1,30))

       dbselectarea('config')
       config->(dbgotop())
       _tipo_cobranca := config->tipo

       dbselectarea('tamanhos')
       tamanhos->(dbgotop())
       _tamanho_001 := tamanhos->nome
       _pedaco_001  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_002 := tamanhos->nome
       _pedaco_002  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_003 := tamanhos->nome
       _pedaco_003  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_004 := tamanhos->nome
       _pedaco_004  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_005 := tamanhos->nome
       _pedaco_005  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_006 := tamanhos->nome
       _pedaco_006  := tamanhos->pedacos

       return(nil)
*-------------------------------------------------------------------------------
static function open_dbf_cdx()

       use tmprpza alias tmp_pizza_relatorio exclusive new
       use tmpza alias tmp_pizza exclusive new
       use tmpprod alias tmp_produto exclusive new
       use tmpreaj alias tmp_reajuste exclusive new
       use tmpcpa1 alias tmp_cpa1 exclusive new
       use tmpcpa2 alias tmp_cpa2 exclusive new

       if open_dbf('config','config',.F.)
       endif
       if open_dbf('tmp_tela','tmp_tela',.F.)
       endif
       if open_dbf('tmp_vda','temp_vendas',.F.)
       endif
       if open_dbf('tmp_cpz','temp_cpz',.F.)
       endif
       if open_dbf('montagem','montagem',.F.)
       endif
       if open_dbf('entrega','entrega',.F.)
       endif
       if open_dbf('comissao','comissao',.T.)
       endif
       if open_dbf('com_mesa','comissao_mesa',.T.)
       endif
       if open_dbf('tcompra1','tcompra1',.T.)
       endif
       if open_dbf('tcompra2','tcompra2',.T.)
       endif
       if open_dbf('empresa','empresa',.T.)
       endif
       if open_dbf('conta','conta',.T.)
       endif
       if open_dbf('tamanhos','tamanhos',.T.)
       endif
       if open_dbf('bordas','bordas',.T.)
       endif
       if open_dbf('clientes','clientes',.T.)
          set index to (path_dbf)+'clientes.cdx'
       endif
       if open_dbf('fornec','fornecedores',.T.)
          set index to (path_dbf)+'fornec.cdx'
       endif
       if open_dbf('gfornec','grupo_fornecedores',.T.)
          set index to (path_dbf)+'gfornec.cdx'
       endif
       if open_dbf('mprima','materia_prima',.T.)
          set index to (path_dbf)+'mprima.cdx'
       endif
       if open_dbf('catprod','categoria_produtos',.T.)
          set index to (path_dbf)+'catprod.cdx'
       endif
       if open_dbf('scatprod','subcategoria_produtos',.T.)
          set index to (path_dbf)+'scatprod.cdx'
       endif
       if open_dbf('mesas','mesas',.T.)
          set index to (path_dbf)+'mesas.cdx'
       endif
       if open_dbf('frecebe','formas_recebimento',.T.)
          set index to (path_dbf)+'frecebe.cdx'
       endif
       if open_dbf('fpaga','formas_pagamento',.T.)
          set index to (path_dbf)+'fpaga.cdx'
       endif
       if open_dbf('umedida','unidade_medida',.T.)
          set index to (path_dbf)+'umedida.cdx'
       endif
       if open_dbf('bancos','bancos',.T.)
          set index to (path_dbf)+'bancos.cdx'
       endif
       if open_dbf('impostos','impostos',.T.)
          set index to (path_dbf)+'impostos.cdx'
       endif
       if open_dbf('atende','atendentes',.T.)
          set index to (path_dbf)+'atende.cdx'
       endif
       if open_dbf('motent','motoboys',.T.)
          set index to (path_dbf)+'motent.cdx'
       endif
       if open_dbf('operador','operadores',.T.)
          set index to (path_dbf)+'operador.cdx'
       endif
       if open_dbf('libusu','acesso',.T.)
          set index to (path_dbf)+'libusu.cdx'
       endif
       if open_dbf('produtos','produtos',.T.)
          set index to (path_dbf)+'produtos.cdx'
       endif
       if open_dbf('cli_uc','ultimas_compras',.T.)
          set index to (path_dbf)+'cli_uc.cdx'
       endif
       if open_dbf('cli_dc','detalhamento_compras',.T.)
          set index to (path_dbf)+'cli_dc.cdx'
       endif
       if open_dbf('prodcomp','produto_composto',.T.)
          set index to (path_dbf)+'prodcomp.cdx'
       endif
       if open_dbf('caixa','caixa',.T.)
          set index to (path_dbf)+'caixa.cdx'
       endif
       if open_dbf('movban','movimento_bancario',.T.)
          set index to (path_dbf)+'movban.cdx'
       endif
       if open_dbf('cpag','contas_pagar',.T.)
          set index to (path_dbf)+'cpag.cdx'
       endif
       if open_dbf('crec','contas_receber',.T.)
          set index to (path_dbf)+'crec.cdx'
       endif
       if open_dbf('tmp_pza','temp_pizzas',.T.)
          set index to (path_dbf)+'tmp_pza.cdx'
       endif
       if open_dbf('tmp_prd','temp_produtos',.T.)
          set index to (path_dbf)+'tmp_prd.cdx'
       endif

       if l_demo
          if date() > _data_limite
             msgstop('O período de avaliação deste programa foi encerrado. Caso tenha gostado e deseje aquirir, por favor ligue para os telefones que estão na tela ou envie e-mail solicitando uma cópia definitiva, com direito a suporte e atualizações, ou então, para manifestar sua opinião, críticas e sugestões serão analisadas. Muito obrigado - equipe de desenvolvimento.','Atenção')
             form_main.release
          endif
       endif
       
       return(nil)
*-------------------------------------------------------------------------------
static function tamanhos_pizza()

       dbselectarea('tamanhos')
       tamanhos->(dbgotop())

       define window form_tamanhos;
              at 000,000;
              width 400;
              height 300;
              title 'Tamanhos de pizza';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define label info_001
                     parent form_tamanhos
                     col 010
                     row 005
                     value 'Duplo clique ou ENTER altera'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _preto_001
                     transparent .T.
              end label
              define label info_002
                     parent form_tamanhos
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
                        parent form_tamanhos;
                        caption 'Sair';
                        action (define_nomes(),form_tamanhos.release);
                        width 100;
                        height 030

              @ 045,010 browse browse_tamanhos;
                        of form_tamanhos;
                        width 375;
                        height 210;
                        headers {'Tamanho','Nº pedaços'};
                        widths {200,120};
                        workarea tamanhos;
                        fields {'tamanhos->nome','tamanhos->pedacos'};
                        value 1;
                        font 'verdana';
                        size 010;
                        backcolor _amarelo_001;
                        fontcolor BLUE;
                        on dblclick altera_tamanho()

              on key escape action thiswindow.release
              
       end window
       
       form_tamanhos.center
       form_tamanhos.activate
       
       return(nil)
*-------------------------------------------------------------------------------
static function altera_tamanho()

       local x_nome   := space(15)
       local x_pedaco := 0
       
       define window form_altera_tamanho;
              at 000,000;
              width 200;
              height 160;
              title 'Alterar';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              x_nome   := tamanhos->nome
              x_pedaco := tamanhos->pedacos

              @ 005,005 label lbl_001;
                        of form_altera_tamanho;
                        value 'Nome';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 025,005 textbox tbox_001;
                        of form_altera_tamanho;
                        height 027;
                        width 180;
                        value x_nome;
                        maxlength 015;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 055,005 label lbl_002;
                        of form_altera_tamanho;
                        value 'Nº pedaços';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 075,005 textbox tbox_002;
                        of form_altera_tamanho;
                        height 027;
                        width 100;
                        value x_pedaco;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric;
                        on lostfocus grava_tamanho()

              on key escape action thiswindow.release
              
       end window
       
       form_altera_tamanho.center
       form_altera_tamanho.activate

       return(nil)
*-------------------------------------------------------------------------------
static function grava_tamanho()

       local x_nome   := form_altera_tamanho.tbox_001.value
       local x_pedaco := form_altera_tamanho.tbox_002.value

       dbselectarea('tamanhos')
       if lock_reg()
          tamanhos->nome    := x_nome
          tamanhos->pedacos := x_pedaco
          tamanhos->(dbcommit())
       endif

       form_altera_tamanho.release
       form_tamanhos.browse_tamanhos.refresh
       
       return(nil)
*-------------------------------------------------------------------------------
static function define_nomes()

       dbselectarea('tamanhos')
       tamanhos->(dbgotop())
       _tamanho_001 := tamanhos->nome
       _pedaco_001  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_002 := tamanhos->nome
       _pedaco_002  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_003 := tamanhos->nome
       _pedaco_003  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_004 := tamanhos->nome
       _pedaco_004  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_005 := tamanhos->nome
       _pedaco_005  := tamanhos->pedacos
       tamanhos->(dbskip())
       _tamanho_006 := tamanhos->nome
       _pedaco_006  := tamanhos->pedacos

       return(nil)
*-------------------------------------------------------------------------------
static function login()

       local x_senha := ''
       
       define window form_login;
              at 000,000;
              width 400;
              height 250;
              title 'Acesso ao programa (senha = 9999)';
              icon path_imagens+'icone.ico';
              modal;
              noautorelease;
              nosize;
              nosysmenu

              define label lbl_top
                     parent form_login
                     col 000
                     row 000
                     value ' SuperChef'
                     width 600
                     height 045
                     fontname 'tahoma'
                     fontsize 022
                     fontbold .T.
                     backcolor _azul_006
                     fontcolor _super
                     transparent .F.
              end label
              define label lbl_top1
                     parent form_login
                     col 170
                     row 000
                     value 'pizza'
                     width 350
                     height 045
                     fontname 'tahoma'
                     fontsize 022
                     fontbold .T.
                     backcolor _azul_006
                     fontcolor _laranja_001
                     transparent .T.
              end label
              define label lbl_top2
                     parent form_login
                     col 300
                     row 010
                     value 'v.4.0, 2011'
                     width 350
                     height 020
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     backcolor _azul_006
                     fontcolor _branco_001
                     transparent .T.
              end label
              
              * senha
              define label label_login
                     col 050
                     row 070
                     value 'Digite sua senha'
                     autosize .T.
                     fontcolor _cinza_001
                     fontname 'verdana'
                     fontsize 010
                     fontbold .T.
                     transparent .T.
              end label
              @ 070,190 textbox tbox_senha;
                        of form_login;
                        height 027;
                        width 120;
                        value x_senha;
                        maxlength 010;
                        font 'verdana' size 010;
                        backcolor _branco_001;
                        fontcolor _preto_001;
                        password

				  if l_demo
              	  define label label_senha_demo
                     	col 100
                     	row 100
                     	value 'digite a senha 9999'
                     	autosize .T.
                     	fontcolor RED
                     	fontname 'verdana'
                     	fontsize 012
                     	fontbold .T.
                     	transparent .T.
     				  end label
				  endif 

              * linha separadora
              define label linha_rodape
                     col 000
                     row 165
                     value ''
                     width form_login.width
                     height 001
                     backcolor _preto_001
                     transparent .F.
              end label

              @ 170,220 buttonex btn_ok;
                        caption 'Ok';
                        picture path_imagens+'img_ok.bmp';
                        flat;
                        noxpstyle;
                        width 060;
                        height 040;
                        font 'verdana';
                        size 9;
                        fontcolor BLACK;
                        bold;
                        backcolor WHITE;
                        tooltip 'Confirma a entrada no programa';
                        action confirma_entrada()
              @ 170,290 buttonex btnex_cancela;
                        caption 'Cancela';
                        picture path_imagens+'img_cancela.bmp';
                        flat;
                        noxpstyle;
                        width 100;
                        height 040;
                        font 'verdana';
                        size 9;
                        fontcolor BLACK;
                        bold;
                        backcolor WHITE;
                        tooltip 'Cancela a entrada ao programa';
                        action form_main.release

       end window

       form_login.setfocus
       form_login.tbox_senha.setfocus

       form_login.center
       form_login.activate

       return(nil)
*-------------------------------------------------------------------------------
static function confirma_entrada()

       local x_senha := form_login.tbox_senha.value

       if empty(x_senha)
          msgalert('Senha não pode ser em branco','Atenção')
          form_login.tbox_senha.setfocus
          return(nil)
       endif
       
       dbselectarea('operadores')
       operadores->(ordsetfocus('senha'))
       operadores->(dbgotop())
       operadores->(dbseek(x_senha))

       if found()
          form_login.release
          show window form_main
          _codigo_usuario_ := operadores->codigo
          _nome_usuario_   := operadores->nome
          dbselectarea('acesso')
          acesso->(ordsetfocus('operador'))
          acesso->(dbgotop())
          acesso->(dbseek(_codigo_usuario_))
          if found()
             _a_001 := acesso->acesso_001
             _a_002 := acesso->acesso_002
             _a_003 := acesso->acesso_003
             _a_004 := acesso->acesso_004
             _a_005 := acesso->acesso_005
             _a_006 := acesso->acesso_006
             _a_007 := acesso->acesso_007
             _a_008 := acesso->acesso_008
             _a_009 := acesso->acesso_009
             _a_010 := acesso->acesso_010
             _a_011 := acesso->acesso_011
             _a_012 := acesso->acesso_012
             _a_013 := acesso->acesso_013
             _a_014 := acesso->acesso_014
             _a_015 := acesso->acesso_015
             _a_016 := acesso->acesso_016
             _a_017 := acesso->acesso_017
             _a_018 := acesso->acesso_018
             _a_019 := acesso->acesso_019
             _a_020 := acesso->acesso_020
             _a_021 := acesso->acesso_021
             _a_022 := acesso->acesso_022
             _a_023 := acesso->acesso_023
             _a_024 := acesso->acesso_024
             _a_025 := acesso->acesso_025
             _a_026 := acesso->acesso_026
             _a_027 := acesso->acesso_027
             _a_028 := acesso->acesso_028
             _a_029 := acesso->acesso_029
             _a_030 := acesso->acesso_030
             _a_031 := acesso->acesso_031
             _a_032 := acesso->acesso_032
             _a_033 := acesso->acesso_033
             _a_034 := acesso->acesso_034
             _a_035 := acesso->acesso_035
             _a_036 := acesso->acesso_036
             _a_037 := acesso->acesso_037
             _a_038 := acesso->acesso_038
             _a_039 := acesso->acesso_039
             _a_040 := acesso->acesso_040
             _a_041 := acesso->acesso_041
             _a_042 := acesso->acesso_042
             _a_043 := acesso->acesso_043
          else
             _a_001 := .F.
             _a_002 := .F.
             _a_003 := .F.
             _a_004 := .F.
             _a_005 := .F.
             _a_006 := .F.
             _a_007 := .F.
             _a_008 := .F.
             _a_009 := .F.
             _a_010 := .F.
             _a_011 := .F.
             _a_012 := .F.
             _a_013 := .F.
             _a_014 := .F.
             _a_015 := .F.
             _a_016 := .F.
             _a_017 := .F.
             _a_018 := .F.
             _a_019 := .T.
             _a_020 := .F.
             _a_021 := .F.
             _a_022 := .F.
             _a_023 := .F.
             _a_024 := .F.
             _a_025 := .F.
             _a_026 := .F.
             _a_027 := .F.
             _a_028 := .F.
             _a_029 := .F.
             _a_030 := .F.
             _a_031 := .F.
             _a_032 := .F.
             _a_033 := .F.
             _a_034 := .F.
             _a_035 := .F.
             _a_036 := .F.
             _a_037 := .F.
             _a_038 := .F.
             _a_039 := .F.
             _a_040 := .F.
             _a_041 := .F.
             _a_042 := .F.
             _a_043 := .F.
          endif
          setproperty('form_main','operador_002','value',alltrim(_nome_usuario_))
       else
          msgexclamation('Senha não confere','Atenção')
          form_login.tbox_senha.setfocus
          return(nil)
       endif

       return(nil)
*-------------------------------------------------------------------------------
static function libera(parametro)

       if !parametro
          return(.F.)
       endif

       return(.T.)
*-------------------------------------------------------------------------------
static function configurar_venda()

	   local x_tipo  := 0
	   local a_tipos := {'Calcular pelo MAIOR preço','Calcular pela MÉDIA de preços'}
	   
       dbselectarea('config')
       config->(dbgotop())
       x_tipo := config->tipo
define window form_configurar;
              at 000,000;
              width 400;
              height 270;
              title 'Configurar Venda de Pizza';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define label info_001
                     parent form_configurar
                     col 010
                     row 005
                     value 'ESC fecha esta janela'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _vermelho_002
                     transparent .T.
              end label
              define label info_002
                     parent form_configurar
                     col 010
                     row 050
                     value 'Defina de que forma o programa deverá cobrar o valor'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _azul_002
                     transparent .T.
              end label
              define label info_003
                     parent form_configurar
                     col 010
                     row 070
                     value 'das pizzas vendidas, quando for selecionado mais  de'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _azul_002
                     transparent .T.
              end label
              define label info_004
                     parent form_configurar
                     col 010
                     row 090
                     value 'um sabor.'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _azul_002
                     transparent .T.
              end label
     		  define comboboxex cbo_tipo
         	  		 row 120
                     col 010
	              	 width 380
			         height 400
			         items a_tipos
			         value x_tipo
			         fontname 'courier new'
			         fontsize 12
			         fontcolor BLACK
         	  end comboboxex

              @ 005,290 button btn_sair;
                        parent form_configurar;
                        caption 'Sair';
                        action form_configurar.release;
                        width 100;
                        height 030
              @ 200,290 button btn_gravar;
                        parent form_configurar;
                        caption 'Gravar';
                        action gravar_config();
                        width 100;
                        height 030

              on key escape action thiswindow.release

       end window

       form_configurar.center
       form_configurar.activate

       return(nil)
*-------------------------------------------------------------------------------
static function gravar_config()

	   local x_tipo := form_configurar.cbo_tipo.value
	   
       dbselectarea('config')
       config->(dbgotop())
       replace tipo with x_tipo
       commit

       _tipo_cobranca := x_tipo
       
       form_configurar.release
       
   	   return(nil)
*-------------------------------------------------------------------------------
static function bordas_pizza()

       dbselectarea('bordas')
       tamanhos->(dbgotop())

       define window form_bordas;
              at 000,000;
              width 400;
              height 300;
              title 'Bordas de pizza';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              define label info_001
                     parent form_bordas
                     col 010
                     row 005
                     value 'Duplo clique ou ENTER altera'
                     autosize .T.
                     fontname 'tahoma'
                     fontsize 010
                     fontbold .T.
                     fontcolor _preto_001
                     transparent .T.
              end label
              define label info_002
                     parent form_bordas
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
                        parent form_bordas;
                        caption 'Sair';
                        action form_bordas.release;
                        width 100;
                        height 030

              @ 045,010 browse browse_bordas;
                        of form_bordas;
                        width 375;
                        height 210;
                        headers {'Descrição','Preço R$'};
                        widths {200,120};
                        workarea bordas;
                        fields {'bordas->nome',"trans(bordas->preco,'@E 999,999.99')"};
                        value 1;
                        font 'verdana';
                        size 010;
                        backcolor _amarelo_001;
                        fontcolor BLUE;
                        on dblclick altera_borda()

              on key escape action thiswindow.release

       end window

       form_bordas.center
       form_bordas.activate

       return(nil)
*-------------------------------------------------------------------------------
static function altera_borda()

       local x_nome  := space(15)
       local x_preco := 0

       define window form_altera_borda;
              at 000,000;
              width 200;
              height 160;
              title 'Alterar';
              icon path_imagens+'icone.ico';
              modal;
              nosize

              x_nome  := bordas->nome
              x_preco := bordas->preco

              @ 005,005 label lbl_001;
                        of form_altera_borda;
                        value 'Descrição';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 025,005 textbox tbox_001;
                        of form_altera_borda;
                        height 027;
                        width 180;
                        value x_nome;
                        maxlength 015;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        uppercase
              @ 055,005 label lbl_002;
                        of form_altera_borda;
                        value 'Preço R$';
                        autosize;
                        font 'tahoma' size 010;
                        bold;
                        fontcolor _preto_001;
                        transparent
              @ 075,005 textbox tbox_002;
                        of form_altera_borda;
                        height 027;
                        width 100;
                        value x_preco;
                        font 'tahoma' size 010;
                        backcolor _fundo_get;
                        fontcolor _letra_get_1;
                        numeric INPUTMASK "99,999.99";
                        on lostfocus grava_borda()

              on key escape action thiswindow.release

       end window

       form_altera_borda.center
       form_altera_borda.activate

       return(nil)
*-------------------------------------------------------------------------------
static function grava_borda()

       local x_nome  := form_altera_borda.tbox_001.value
       local x_preco := form_altera_borda.tbox_002.value

       dbselectarea('bordas')
       if lock_reg()
          bordas->nome  := x_nome
          bordas->preco := x_preco
          bordas->(dbcommit())
       endif

       form_altera_borda.release
       form_bordas.browse_bordas.refresh

       return(nil)