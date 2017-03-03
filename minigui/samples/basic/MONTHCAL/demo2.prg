//================================================================//
// Programa......: Mostrando mais meses no controle MonthCalendar
// Programador...: Marcos Antonio Gambeta
// Contato.......: dicasdeprogramacao@yahoo.com.br
// Website.......: http://geocities.yahoo.com.br/marcosgambeta/
//================================================================//
// Linguagem.....: Harbour/xHarbour
// Bibliotecas...: Minigui
// Plataforma....: Windows
// Criado em ....: 19/03/2004 15:57:26
// Atualizado em : 01/09/2004 19:48:39
//================================================================//
// Este exemplo demonstra como mostrar mais meses no controle
// MonthCalendar.
//================================================================//

#include "minigui.ch"

Function Main ()

   // criando a janela principal, sendo que nos
   // eventos ON SIZE e ON MAXIMIZE será executada
   // uma rotina para ajustar o tamanho do calendário
   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 760 ;
      HEIGHT 522 ;
      TITLE "Mais meses no controle MonthCalendar" ;
      MAIN ;
      ON SIZE {||AjustarTamanho()} ;
      ON MAXIMIZE {||AjustarTamanho()}

      // criando o controle MonthCalendar padrão
      // nas coordenadas 0,0
      @ 0,0 MONTHCALENDAR Month1

      // aumentando a largura do controle para a largura da
      // janela, descontando o tamanho das bordas laterais
      Form1.Month1.Width := Form1.Width - GetBorderWidth()*2

      // aumentando a altura do controle para a altura da
      // janela, descontando o tamanho da barra de título e
      // das bordas superiores e inferiores
      Form1.Month1.Height := Form1.Height - GetTitleHeight() - GetBorderHeight()*2

   END WINDOW

   // centralizando a janela
   CENTER WINDOW Form1

   // ativando a janela
   ACTIVATE WINDOW Form1

   Return Nil

Static Function AjustarTamanho ()

   IF GetDesktopWidth() > 800 .AND. GetDesktopHeight() > 600
	Form1.Width := 571
	Form1.Height := 682
	// centralizando a janela
	CENTER WINDOW Form1
   ENDIF

   // ajustando a largura
   Form1.Month1.Width := Form1.Width - GetBorderWidth()*2
   // ajustando a altura
   Form1.Month1.Height := Form1.Height - GetTitleHeight() - GetBorderHeight()*2
   Return Nil
