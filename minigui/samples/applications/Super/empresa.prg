/*
  sistema     : superchef pizzaria
  programa    : cadastro da empresa
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'
#include 'super.ch'

function empresa()

         local x_nome     := ''
         local x_fixo_1   := ''
         local x_fixo_2   := ''
         local x_endereco := ''
         local x_numero   := ''
         local x_complem  := ''
         local x_bairro   := ''
         local x_cidade   := ''
         local x_uf       := 'PR'
         local x_cep      := ''
         local x_email    := ''
         local x_site     := ''

         dbselectarea('empresa')
         empresa->(dbgotop())
         x_nome     := empresa->nome
         x_fixo_1   := empresa->fixo_1
         x_fixo_2   := empresa->fixo_2
         x_endereco := empresa->endereco
         x_numero   := empresa->numero
         x_complem  := empresa->complem
         x_bairro   := empresa->bairro
         x_cidade   := empresa->cidade
         x_uf       := empresa->uf
         x_cep      := empresa->cep
         x_email    := empresa->email
         x_site     := empresa->site

         define window form_empresa;
                at 000,000;
		          width 585;
		          height 380;
                title 'Cadastro da Pizzaria';
                icon path_imagens+'icone.ico';
                modal;
                nosize

                * entrada de dados
                @ 010,005 label lbl_001;
                          of form_empresa;
                          value 'Nome';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,005 getbox tbox_001;
                          of form_empresa;
                          height 027;
                          width 310;
                          value x_nome;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 010,325 label lbl_002;
                          of form_empresa;
                          value 'Telefone (1)';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,325 getbox tbox_002;
                          of form_empresa;
                          height 027;
                          width 120;
                          value x_fixo_1;
                          font 'verdana' size 012;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 010,455 label lbl_003;
                          of form_empresa;
                          value 'Telefone (2)';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 030,455 getbox tbox_003;
                          of form_empresa;
                          height 027;
                          width 120;
                          value x_fixo_2;
                          font 'verdana' size 012;
                          bold;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 060,005 label lbl_004;
                          of form_empresa;
                          value 'Endereço';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 080,005 getbox tbox_004;
                          of form_empresa;
                          height 027;
                          width 310;
                          value x_endereco;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 060,325 label lbl_005;
                          of form_empresa;
                          value 'Número';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 080,325 getbox tbox_005;
                          of form_empresa;
                          height 027;
                          width 060;
                          value x_numero;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 060,395 label lbl_006;
                          of form_empresa;
                          value 'Complemento';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 080,395 getbox tbox_006;
                          of form_empresa;
                          height 027;
                          width 180;
                          value x_complem;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 110,005 label lbl_007;
                          of form_empresa;
                          value 'Bairro';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 130,005 getbox tbox_007;
                          of form_empresa;
                          height 027;
                          width 180;
                          value x_bairro;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 110,195 label lbl_008;
                          of form_empresa;
                          value 'Cidade';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 130,195 getbox tbox_008;
                          of form_empresa;
                          height 027;
                          width 180;
                          value x_cidade;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 110,385 label lbl_009;
                          of form_empresa;
                          value 'UF';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 130,385 getbox tbox_009;
                          of form_empresa;
                          height 027;
                          width 040;
                          value x_uf;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 110,435 label lbl_010;
                          of form_empresa;
                          value 'CEP';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 130,435 getbox tbox_010;
                          of form_empresa;
                          height 027;
                          width 080;
                          value x_cep;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1;
                          picture '@!'
                @ 160,005 label lbl_011;
                          of form_empresa;
                          value 'e-mail';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 180,005 getbox tbox_011;
                          of form_empresa;
                          height 027;
                          width 450;
                          value x_email;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1
                @ 210,005 label lbl_012;
                          of form_empresa;
                          value 'site';
                          autosize;
                          font 'tahoma' size 010;
                          bold;
                          fontcolor _preto_001;
                          transparent
                @ 230,005 getbox tbox_012;
                          of form_empresa;
                          height 027;
                          width 450;
                          value x_site;
                          font 'tahoma' size 010;
                          backcolor _fundo_get;
                          fontcolor _letra_get_1

                * linha separadora
                define label linha_rodape
                       col 000
                       row form_empresa.height-090
                       value ''
                       width form_empresa.width
                       height 001
                       backcolor _preto_001
                       transparent .F.
                end label

                * botões
                define buttonex button_ok
                       picture path_imagens+'img_gravar.bmp'
                       col form_empresa.width-225
                       row form_empresa.height-085
                       width 120
                       height 050
                       caption 'Ok, gravar'
                       action gravar()
                       fontbold .T.
                       tooltip 'Confirmar as informações digitadas'
                       flat .F.
                       noxpstyle .T.
                end buttonex
                define buttonex button_cancela
                       picture path_imagens+'img_voltar.bmp'
                       col form_empresa.width-100
                       row form_empresa.height-085
                       width 090
                       height 050
                       caption 'Voltar'
                       action form_empresa.release
                       fontbold .T.
                       tooltip 'Sair desta tela sem gravar informações'
                       flat .F.
                       noxpstyle .T.
                end buttonex

                on key escape action thiswindow.release

         end window

         form_empresa.center
         form_empresa.activate

         return(nil)
*-------------------------------------------------------------------------------
static function gravar()

       if lock_reg()
          empresa->nome     := form_empresa.tbox_001.value
          empresa->fixo_1   := form_empresa.tbox_002.value
          empresa->fixo_2   := form_empresa.tbox_003.value
          empresa->endereco := form_empresa.tbox_004.value
          empresa->numero   := form_empresa.tbox_005.value
          empresa->complem  := form_empresa.tbox_006.value
          empresa->bairro   := form_empresa.tbox_007.value
          empresa->cidade   := form_empresa.tbox_008.value
          empresa->uf       := form_empresa.tbox_009.value
          empresa->cep      := form_empresa.tbox_010.value
          empresa->email    := form_empresa.tbox_011.value
          empresa->site     := form_empresa.tbox_012.value
          empresa->(dbcommit())
          empresa->(dbunlock())
          empresa->(dbgotop())
       endif

       form_empresa.release

       return(nil)