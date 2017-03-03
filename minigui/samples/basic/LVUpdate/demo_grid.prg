* Harbour MiniGUI Grid Demo
* (c) 2002-2004 Roberto Lopez <harbourminigui@gmail.com>
******************************************************************
* EnableUpdate & DisableUpdate Methods Demo for GRID
* Jacek Kubica <kubica@wssk.wroc.pl>
* enable/disable screen update for controls from ListView family
* HMG 1.1 Experimental Build 10b
******************************************************************
* Based on sample provided by Honorio <info2000informa@ig.com.br>

#include "minigui.ch"

Static lGridFreeze := .t.

MEMVAR _BLUE,_YELLOW,_BLACK,_ROSA,_BLUE3
MEMVAR _BLUE2,_YELLOW2,_BLUE5,_VERDE

Function Main()

PUBLIC _BLUE:={0,0,255},_YELLOW:={255,255,200},_BLACK:={0,0,0},_ROSA:={255,200,200},_BLUE3:={211,237,250}
PUBLIC _BLUE2:={0,128,255},_YELLOW2:={255,255,225},_BLUE5:={ 0 , 0 ,255},_VERDE:={0,128,128}

USE PECAS Alias PECAS EXCLUSIVE NEW
SET INDEX TO PECAS002



	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
                WIDTH 800 HEIGHT 600 ;
                TITLE 'Grid enable/disable update demo' ;
                MAIN ;
                ON INIT PESQUISA_PECAS()

                
       @ 070,005 GRID GRID_PECAS     ;
                 WIDTH  780          ;
                 HEIGHT 400          ;
                 HEADERS {"Código", "Original", "Cód Fornecedor 1", "Descrição", "Embalagem","Marca", "Preço Venda", "Estoque" , "Aplicação", "Obervação", "Record"};
                 WIDTHS  { 100, 100, 100, 240, 60, 80, 90, 60, 300, 300, 70 }  ;
                 VALUE 1                        ;
                 Font "Arial" Size 8 Bold;
                 BACKCOLOR _YELLOW FONTCOLOR BLACK  ;
                 JUSTIFY { BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT}

       @ 485,005 LABEL  Label_PESQUISA ;
                 VALUE "PESQUISA "     ;
                 WIDTH 70              ;
                 HEIGHT 20             ;
                 FONTCOLOR _BLUE ;
                 FONT "MS SANS SERIF" SIZE 09 BOLD;
                 TRANSPARENT

       @ 480,075 TEXTBOX TXTPESQUISA                   ;
                 WIDTH 280                             ;
                 TOOLTIP "Digite o Nome para PESQUISA" ;
                 FONT "MS SANS SERIF" SIZE 9 BOLD;
                 BACKCOLOR _YELLOW2 FONTCOLOR _VERDE  ;
                 MAXLENGTH 40 UPPERCASE                ;
                 ON GOTFOCUS This.BackColor:= _BLUE3  ;
                 ON LOSTFOCUS This.BackColor:=_YELLOW2;
                 ON CHANGE { || PESQUISA_PECAS() }

       @ 485,365 LABEL  Label_QUAL          ;
                 VALUE "Digite a Descrição" ;
                 WIDTH 250             ;
                 HEIGHT 20             ;
                 FONTCOLOR _BLUE5 ;
                 FONT "MS SANS SERIF" SIZE 10 BOLD;
                 TRANSPARENT

       @ 505,005 LABEL  Label_X ;
                 VALUE "" ;
                 WIDTH 700             ;
                 HEIGHT 40             ;
                 FONTCOLOR _BLUE ;
                 FONT "MS SANS SERIF" SIZE 09 BOLD;
                 TRANSPARENT

        DEFINE MAIN MENU
          POPUP "&Freeze"
            MENUITEM "Enable grid update " ACTION lGridFreeze := .f.
            MENUITEM "Disable grid update" ACTION lGridFreeze := .t.
          END POPUP
        END MENU

	END WINDOW


*** Centraliza Janela
CENTER WINDOW Win_1
Win_1.TXTPESQUISA.SETFOCUS

ACTIVATE WINDOW Win_1


Return Nil


**
**

Function PESQUISA_PECAS()

Local cPesq := Upper(AllTrim( WIN_1.TXTPESQUISA.VALUE  ))
Local nTamanhoNomeParaPESQUISA		:= Len(cPesq)
Local nQuantRegistrosProcessados	:= 0
Local nQuantMaximaDeRegistrosNoGRID	:= 70
Local cCAMPO := "DESCRICAO"

DBSELECTAREA("PECAS")

*** Efetua PESQUISA no Arquivo para posicionar no primeiro registro que satisfaça a condição
DBSeek( cPesq )

if lGridFreeze
	Win_1.GRID_PECAS.DisableUpdate // disable GRID update
endif

*** Exclui todos os registros do GRID
DELETE ITEM ALL FROM GRID_PECAS OF WIN_1

*** Entra no Laço (While ) até que encontre o fim do arquivo
DO WHILE ! Eof()
   *** Se o Substr do apelido for igual à variavel cPesq ( Conteúdo do campo TXTPESQUISA)
   If Substr( FIELD->&cCAMPO,1,nTamanhoNomeParaPESQUISA) == cPesq
      *** Acumula contador
      nQuantRegistrosProcessados += 1
      *** Se a quantidade de resgistros lidos atingiu o limite de registros definidos para o GRID sai do laço/While
      if nQuantRegistrosProcessados > nQuantMaximaDeRegistrosNoGRID
         EXIT
      EndIf
      *** Adiciona registro no GRID
      ADD ITEM { PECAS->CODIGO ,PECAS->CODORIG, PECAS->COD_PECA1, PECAS->DESCRICAO, TRANSF(PECAS->PRECO5,"@E 999.999"), PECAS->MARCA , TRANSF(PECAS->PR_VENDA, "@E 9,999,999.99"), TRANSF(PECAS->ESTQ,"999999") , PECAS->APLICA, PECAS->OBS, TRANSF( RECNO(), "999999" ) } TO GRID_PECAS OF WIN_1
      *** Se o Substr de Apelido estiver fora da faixa de PESQUISA, abandona o laço
  ElseIf Substr( FIELD->&cCAMPO,1,nTamanhoNomeParaPESQUISA) > cPesq
     EXIT
  Endif
  ** Pula para Próximo registro
  DBSkip()
ENDDO

if lGridFreeze
	Win_1.GRID_PECAS.EnableUpdate // enable GRID update
endif

Return Nil

