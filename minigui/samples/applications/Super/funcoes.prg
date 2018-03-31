/*
  sistema     : superchef pizzaria
  programa    : funções genéricas
  compilador  : xharbour 1.2 simplex
  lib gráfica : minigui 1.7 extended
  programador : marcelo neves
*/

#include 'minigui.ch'

memvar path_dbf
memvar _nome_unidade

function open_dbf(nome,apelido,modo)

        local arquivo := path_dbf + nome + '.dbf'
        local ret

        if modo
           use (arquivo) alias (apelido) via 'dbfcdx' shared new
        else
           use (arquivo) alias (apelido) via 'dbfcdx' exclusive new
        endif

        if .not. neterr()
           ret := .T.
        else
           msgstop('Não foi possível abrir '+alltrim(apelido)+', Tente novamente','Atenção')
           ret := .F.
        endif

        return(ret)
*________________________________________________________________________________________
function Lock_Dbf()

         local ret

         if flock()
            ret := .T.
         else
            msgstop('Não foi possível bloquear uma tabela','Atenção')
            ret := .F.
         endif

         return(ret)
*________________________________________________________________________________________________
function Lock_Reg()

         local ret

         if rlock()
            ret := .T.
         else
            msgstop('Não foi possível acessar esta informação','Atenção')
            ret := .F.
         endif

         return(ret)
*________________________________________________________________________________________________
function add_reg()

         local ret

         dbappend()

         if .not. neterr()
            ret := .T.
         else
            msgstop('Não foi possível gravar estas informações','Atenção')
            ret := .F.
         endif

         return(ret)
*________________________________________________________________________________________________
function Chk_Mes(parametro,tipo)

         local retorno

	 if tipo == 1
	    retorno := {'Jan','Fev','Mar','Abr','Mai','Jun',;
		        'Jul','Ago','Set','Out','Nov','Dez'} [Parametro]
	 elseif tipo == 2
	    retorno := {'Janeiro  ','Fevereiro','Marco    ','Abril    ','Maio     ','Junho    ',;
		        'Julho    ','Agosto   ','Setembro ','Outubro  ','Novembro ',;
		        'Dezembro '} [Parametro]
	 endif

         return(retorno)
*________________________________________________________________________________________________
function dia_da_semana(p_data,p_tipo)

	 local cSem_ext,cSem_abv,cData

	 if p_tipo == 1
	    cSem_ext := {'Domingo','Segunda-Feira','Terça-Feira' ,;
			 'Quarta-Feira','Quinta-Feira','Sexta-Feira' ,;
			 'Sábado'}
	    cData := cSem_ext[dow(p_data)]
	    return(cData)
	 elseif p_tipo == 2
	    cSem_abv := {'Dom','Seg','Ter','Qua','Qui','Sex','Sáb'}
	    cData    := cSem_abv[dow(p_data)]
	    return(cData)
	 endif

	 return(nil)
*________________________________________________________________________________________________
function check_window()

         local largura := getdesktopwidth()
         local altura  := getdesktopheight()
         local ret

         if largura < 1000 .and. altura < 750
            msgstop('Este programa é melhor visualizado e operado com a resolução de vídeo 1024 x 768','Atenção')
            ret := .F.
         elseif largura > 1030 .and. altura > 780
            msgstop('Este programa é melhor visualizado e operado com a resolução de vídeo 1024 x 768','Atenção')
            ret := .F.
         else
            ret := .T.
         endif

         return(ret)
*________________________________________________________________________________________________
function valor_coluna(xObj,xForm,nCol)

         local nPos := GetProperty(xForm,xObj,'Value')
         local aRet := GetProperty(xForm,xObj,'Item',nPos)

         return aRet[nCol]
*-------------------------------------------------------------------------------
function acha_unidade(parametro)

         local area_aberta := select()
         local retorno     := space(10)
         
         if empty(parametro)
            return('---')
         endif
         
         dbselectarea('unidade_medida')
         unidade_medida->(ordsetfocus('codigo'))
         unidade_medida->(dbgotop())
         unidade_medida->(dbseek(parametro))
         
         if found()
            retorno := unidade_medida->nome
         else
            retorno := '---'
         endif
         
         dbselectarea(area_aberta)
         
         return(retorno)
*-------------------------------------------------------------------------------
function acha_banco(parametro)

         local area_aberta := select()
         local retorno     := space(20)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('bancos')
         bancos->(ordsetfocus('codigo'))
         bancos->(dbgotop())
         bancos->(dbseek(parametro))

         if found()
            retorno := bancos->nome
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_tamanho(parametro)

         local area_aberta := select()
         local retorno     := space(20)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('tamanho_pizza')
         tamanho_pizza->(ordsetfocus('codigo'))
         tamanho_pizza->(dbgotop())
         tamanho_pizza->(dbseek(parametro))

         if found()
            retorno := tamanho_pizza->nome
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_mprima(parametro)

         local area_aberta := select()
         local retorno     := space(20)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('materia_prima')
         materia_prima->(ordsetfocus('codigo'))
         materia_prima->(dbgotop())
         materia_prima->(dbseek(parametro))

         if found()
            retorno       := materia_prima->nome
            _nome_unidade := materia_prima->unidade
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_vmprima(parametro)

         local area_aberta := select()
         local retorno     := space(20)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('materia_prima')
         materia_prima->(ordsetfocus('codigo'))
         materia_prima->(dbgotop())
         materia_prima->(dbseek(parametro))

         if found()
            retorno := trans(materia_prima->preco,'@E 99,999.99')
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_fornecedor(parametro)

         local area_aberta := select()
         local retorno     := space(40)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('fornecedores')
         fornecedores->(ordsetfocus('codigo'))
         fornecedores->(dbgotop())
         fornecedores->(dbseek(parametro))

         if found()
            retorno := alltrim(fornecedores->nome)
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_fornecedor_2(parametro)

         local area_aberta := select()
         local retorno     := space(40)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('fornecedores')
         fornecedores->(ordsetfocus('codigo'))
         fornecedores->(dbgotop())
         fornecedores->(dbseek(parametro))

         if found()
            retorno := fornecedores->nome+'- '+alltrim(fornecedores->fixo)+' - '+alltrim(fornecedores->celular)
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_produto(parametro)

         local area_aberta := select()
         local retorno     := space(40)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('produtos')
         produtos->(ordsetfocus('codigo'))
         produtos->(dbgotop())
         produtos->(dbseek(parametro))

         if found()
            retorno := alltrim(produtos->nome_longo)
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_forma_pagamento(parametro)

         local area_aberta := select()
         local retorno     := space(40)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('formas_pagamento')
         formas_pagamento->(ordsetfocus('codigo'))
         formas_pagamento->(dbgotop())
         formas_pagamento->(dbseek(parametro))

         if found()
            retorno := alltrim(formas_pagamento->nome)
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_forma_recebimento(parametro)

         local area_aberta := select()
         local retorno     := space(40)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('formas_recebimento')
         formas_recebimento->(ordsetfocus('codigo'))
         formas_recebimento->(dbgotop())
         formas_recebimento->(dbseek(parametro))

         if found()
            retorno := alltrim(formas_recebimento->nome)
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_cliente(parametro)

         local area_aberta := select()
         local retorno     := space(40)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('clientes')
         clientes->(ordsetfocus('codigo'))
         clientes->(dbgotop())
         clientes->(dbseek(parametro))

         if found()
            retorno := alltrim(clientes->nome)
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_motoboy(parametro)

         local area_aberta := select()
         local retorno     := space(20)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('motoboys')
         motoboys->(ordsetfocus('codigo'))
         motoboys->(dbgotop())
         motoboys->(dbseek(parametro))

         if found()
            retorno := motoboys->nome
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function acha_atendente(parametro)

         local area_aberta := select()
         local retorno     := space(20)

         if empty(parametro)
            return('---')
         endif

         dbselectarea('atendentes')
         atendentes->(ordsetfocus('codigo'))
         atendentes->(dbgotop())
         atendentes->(dbseek(parametro))

         if found()
            retorno := atendentes->nome
         else
            retorno := '---'
         endif

         dbselectarea(area_aberta)

         return(retorno)
*-------------------------------------------------------------------------------
function DbfVazio( cParametro )

         sele (cParametro )

	 If Eof()
	    msgexclamation('A tabela '+alltrim(upper(cParametro))+' está vazia','Atenção')
	    Return( .t. )
	 Endif

	 Return( .f. )