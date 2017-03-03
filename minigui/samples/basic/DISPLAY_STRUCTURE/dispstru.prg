/*
   Display Structure v1.1
   Copyright 2004 Marcos Antonio Gambeta

   Contato: marcosgambeta@yahoo.com.br
            marcosgambeta@uol.com.br
            marcos_gambeta@hotmail.com

   Website: http://geocities.yahoo.com.br/marcosgambeta/

   Este arquivo é parte do programa "Display Structure".

   "Display Structure" é um software livre; você pode redistribuí-lo e/ou
   modificá-lo dentro dos termos da Licença Pública Geral GNU como
   publicada pela Fundação do Software Livre (FSF); na versão 2 da
   Licença, ou (na sua opinião) qualquer versão.

   Este programa é distribuído na esperança que possa ser útil,
   mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÂO a qualquer
   MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a Licença Pública Geral GNU
   para maiores detalhes.

   Você deve ter recebido uma cópia da Licença Pública Geral GNU
   junto com este programa, se não, escreva para a Fundação do Software
   Livre(FSF) Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

   Uma versão da Licença Pública Geral GNU pode ser encontrada no endereço
   abaixo:

   http://www.gnu.org/copyleft/gpl.txt

*/

//==========================================================================//
// Arquivos .CH necessários
//==========================================================================//

#include "minigui.ch"

//==========================================================================//
// Variáveis estáticas
//==========================================================================//

Static aCamposN  // armazena todos os campos na ordem natural
Static aCamposC  // armazena os campos correntes
Static nOrder    // ordem de exibição corrente (1=natural/2=alfabética)
Static cTipo     // filtro para tipos de campos
                 // "X" : mostra todos os campos
                 // "C" : mostra campos do tipo C (character)
                 // "N" : mostra campos do tipo N (numeric)
                 // "D" : mostra campos do tipo D (date)
                 // "L" : mostra campos do tipo L (logic)
                 // "M" : mostra campos do tipo M (memo)

//==========================================================================//
// Função: Main
// Janela principal do sistema
//==========================================================================//

Function Main ( cArquivo )

   Local i

   If PCount() == 0
      cArquivo := GetFile( {{'Database files (*.dbf)', '*.dbf'}, {'All files (*.*)', '*.*'}}, ;
                       'Open database' )
   EndIf

   // verifica se foi passado um nome de arquivo
   If cArquivo == Nil
      MsgInfo("Nenhum arquivo fornecido!","Aviso")
      Return Nil
   EndIf

   // verifica se o arquivo existe
   If !File( cArquivo )
      MsgInfo("Arquivo não encontrado!","Aviso")
      Return Nil
   EndIf

   // preenche o vetor aCamposN com
   // os campos do arquivo
   Use (cArquivo) ReadOnly Shared
   If NetErr()
      MsgInfo("O arquivo não pode ser aberto!","Aviso")
      Return Nil
   Endif
   aCamposN := DBStruct()
   Use

   // formata as colunas 'tamanho' e 'decimais'
   For i := 1 To Len(aCamposN)
      aCamposN[i,3] := Str(aCamposN[i,3],5)
      aCamposN[i,4] := If( aCamposN[i,2]=="N", Str(aCamposN[i,4],5), "" )
   Next i

   aCamposC := AClone(aCamposN)
   nOrder   := 1   // ordem natural
   cTipo    := "X" // todos os tipos

   // define a janela principal
   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 420 HEIGHT 480 + iif(IsThemed(), GetBorderHeight(), 0) ;
      TITLE "Display Structure" ;
      ICON "MAIN_ICON" ;
      NOSIZE ;
      NOMAXIMIZE ;
      MAIN

      // define a barra de status
      DEFINE STATUSBAR
         STATUSITEM cArquivo
      END STATUSBAR

      // define o menu principal
      DEFINE MAIN MENU
         POPUP "Opções"
            ITEM "Ordem Natural"          ACTION OrdNat() NAME OrdNat
            ITEM "Ordem Alfabética"       ACTION OrdAlf() NAME OrdAlf
            SEPARATOR
            ITEM "Mostrar todos os tipos" ACTION FiltrarTipo("X") NAME TipoX
            ITEM "Mostrar somente tipo C" ACTION FiltrarTipo("C") NAME TipoC
            ITEM "Mostrar somente tipo N" ACTION FiltrarTipo("N") NAME TipoN
            ITEM "Mostrar somente tipo D" ACTION FiltrarTipo("D") NAME TipoD
            ITEM "Mostrar somente tipo L" ACTION FiltrarTipo("L") NAME TipoL
            ITEM "Mostrar somente tipo M" ACTION FiltrarTipo("M") NAME TipoM
            SEPARATOR
            ITEM "Sair"                   ACTION Form1.Release
         END POPUP
         POPUP "Ajuda"
            ITEM "Sobre..." ACTION Sobre()
         END POPUP
      END MENU

      // define o menu de contexto
      DEFINE CONTEXT MENU
         ITEM "Ordem Natural"          ACTION OrdNat()
         ITEM "Ordem Alfabética"       ACTION OrdAlf()
         SEPARATOR
         ITEM "Mostrar todos os tipos" ACTION FiltrarTipo("X")
         ITEM "Mostrar somente tipo C" ACTION FiltrarTipo("C")
         ITEM "Mostrar somente tipo N" ACTION FiltrarTipo("N")
         ITEM "Mostrar somente tipo D" ACTION FiltrarTipo("D")
         ITEM "Mostrar somente tipo L" ACTION FiltrarTipo("L")
         ITEM "Mostrar somente tipo M" ACTION FiltrarTipo("M")
      END MENU

      // cria o grid para exibição dos campos
      @ 10,10 GRID Grid1 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         HEADERS {"Campo","Tipo","Tamanho","Decimais"} ;
         WIDTHS {125,80,80,80} ;
         ITEMS aCamposC ;
         VALUE 1 ;
         FONT "Courier New" ;
         SIZE 10

   END WINDOW

   Form1.TipoC.Enabled := ( AScan(aCamposN, { |x| x[2] == "C" }) > 0 )
   Form1.TipoN.Enabled := ( AScan(aCamposN, { |x| x[2] == "N" }) > 0 )
   Form1.TipoD.Enabled := ( AScan(aCamposN, { |x| x[2] == "D" }) > 0 )
   Form1.TipoL.Enabled := ( AScan(aCamposN, { |x| x[2] == "L" }) > 0 )
   Form1.TipoM.Enabled := ( AScan(aCamposN, { |x| x[2] == "M" }) > 0 )

   AtualizaOrdem()
   AtualizaTipo()

   Form1.Grid1.SetFocus
   Form1.Center
   Form1.Activate

   Return Nil

//==========================================================================//
// Função: AtualizaOrdem
// Atualiza, no menu, a ordem atual dos campos
//==========================================================================//

Static Function AtualizaOrdem ()

   If nOrder == 1
      // ordem natural
      Form1.OrdNat.Checked := TRUE
      Form1.OrdAlf.Checked := FALSE
   Else
      // ordem alfabética
      Form1.OrdNat.Checked := FALSE
      Form1.OrdAlf.Checked := TRUE
   EndIf
   Return Nil

//==========================================================================//
// Função: AtualizaTipo
// Atualiza, no menu, o tipo dos campos exibidos
//==========================================================================//

Static Function AtualizaTipo ()

   // desmarca todos
   Form1.TipoX.Checked := FALSE
   Form1.TipoC.Checked := FALSE
   Form1.TipoN.Checked := FALSE
   Form1.TipoD.Checked := FALSE
   Form1.TipoL.Checked := FALSE
   Form1.TipoM.Checked := FALSE
   // marca o atual
   Do Case
   Case cTipo == "X" ; Form1.TipoX.Checked := TRUE
   Case cTipo == "C" ; Form1.TipoC.Checked := TRUE
   Case cTipo == "N" ; Form1.TipoN.Checked := TRUE
   Case cTipo == "D" ; Form1.TipoD.Checked := TRUE
   Case cTipo == "L" ; Form1.TipoL.Checked := TRUE
   Case cTipo == "M" ; Form1.TipoM.Checked := TRUE
   EndCase
   Return Nil

//==========================================================================//
// Função: OrdNat
// Preenche o grid com os campos na ordem natural
//==========================================================================//

Static Function OrdNat ()

   Local i

   // limpa o grid
   Form1.Grid1.DeleteAllItems
   // preenche com os campos correntes
   For i := 1 To Len(aCamposC)
      Form1.Grid1.AddItem( aCamposC[i] )
   Next i
   nOrder := 1 // ordem natural
   AtualizaOrdem()
   Return Nil

//==========================================================================//
// Função: OrdAlf
// Preenche o grid com os campos na ordem alfabética
//==========================================================================//

Static Function OrdAlf ()

   Local i
   Local a := AClone(aCamposC)

   // ordena o vetor temporário
   ASort(a,,,{|x,y|x[1]<y[1]})
   // limpa o grid
   Form1.Grid1.DeleteAllItems
   // preenche o grid com os campos correntes
   For i := 1 To Len(a)
      Form1.Grid1.AddItem( a[i] )
   Next i
   nOrder := 2 // ordem alfabética
   AtualizaOrdem()
   Return Nil

//==========================================================================//
// Função: FiltrarTipo
// Seleciona os campos de acordo com o tipo escolhido
//==========================================================================//

Static Function FiltrarTipo ( cTipoSel )

   Local i

   // limpa o vetor dos campos correntes
   aCamposC := {}
   // preenche com os campos do tipo selecionado
   For i := 1 To Len(aCamposN)
      If cTipoSel == "X" .Or. aCamposN[i,2] == cTipoSel
         AAdd(aCamposC,aCamposN[i])
      EndIf
   Next i
   // atualiza o grid
   If nOrder == 1
      OrdNat() // ordem natural
   Else
      OrdAlf() // ordem alfabética
   EndIf
   cTipo := cTipoSel
   AtualizaTipo()
   Return Nil

//==========================================================================//
// Função: Sobre
// Mostra a janela "Sobre..." do programa
//==========================================================================//

Static Function Sobre ()

   DEFINE WINDOW Form2 ;
      AT 0,0 ;
      WIDTH 340 HEIGHT 300 ;
      TITLE "Sobre Display Structure" ;
      MODAL ;
      FONT "Arial" SIZE 10

      @ 15,35 IMAGE Image1 PICTURE "IMAGE_MAIN" WIDTH 48 HEIGHT 48

      @ 130,25 IMAGE Image2 PICTURE "IMAGE_MINIGUI" WIDTH 70 HEIGHT 72

      @ 10,120 LABEL Label1 VALUE "Programa"
      @ 30,120 LABEL Label2 VALUE "Display Structure" ITALIC BOLD

      @ 50,120 LABEL Label3 VALUE "Versão"
      @ 70,120 LABEL Label4 VALUE "1.1" ITALIC BOLD

      @ 90,120 LABEL Label5 VALUE "Autor"
      @ 110,120 LABEL Label6 VALUE "Marcos Antonio Gambeta" WIDTH 200 ITALIC BOLD

      @ 130,120 LABEL Label7 VALUE "E-mail"

      @ 145,120 HYPERLINK Label8 VALUE "marcos_gambeta@hotmail.com" ;
         ADDRESS "marcos_gambeta@hotmail.com" AUTOSIZE BOLD ITALIC ;
         TOOLTIP "Clique aqui para enviar um e-mail para o autor" ;
         HANDCURSOR

      @ 170,120 LABEL Label9 VALUE "Licença"
      @ 190,120 LABEL Label10 VALUE "Free Software (GPL)" WIDTH 200 ITALIC BOLD

      @ 220,120 BUTTON Button1 CAPTION "OK" ACTION Form2.Release

      ON KEY ESCAPE ACTION Form2.Button1.OnClick

   END WINDOW

   Form2.Button1.Setfocus

   Form2.Center
   Form2.Activate

   Return Nil

//==========================================================================//
