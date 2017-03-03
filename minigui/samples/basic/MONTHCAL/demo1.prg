//================================================================//
// Programa......: Margens no controle MonthCalendar
// Programador...: Marcos Antonio Gambeta
// Contato.......: dicasdeprogramacao@yahoo.com.br
// Website.......: http://geocities.yahoo.com.br/marcosgambeta/
//================================================================//
// Linguagem.....: Harbour/xHarbour
// Bibliotecas...: Minigui
// Plataforma....: Windows
// Criado em ....: 19/03/2004 10:47:14
// Atualizado em : 01/09/2004 19:47:47
//================================================================//
// Este exemplo demonstra como modificar as margens do controle
// MonthCalendar e manipular sua cor.
//================================================================//

#include "minigui.ch"

Function Main ()

   // criando a janela principal
   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "Margens no controle MonthCalendar" ;
      MAIN

      //-----------------//
      // controle Month1 //
      //-----------------//

      // criando o primeiro controle MonthCalendar padrão
      @ 10,10 MONTHCALENDAR Month1 ;
         TOOLTIP "Controle MonthCalendar padrão"

      //-----------------//
      // controle Month2 //
      //-----------------//

      // criando o segundo controle MonthCalendar padrão
      @ 10,330 MONTHCALENDAR Month2 ;
         TOOLTIP "Controle MonthCalendar com 15 pontos em cada margem"

      // aumentando as margens esquerda e direita, do
      // controle Month2, em 15 pontos
      Form1.Month2.Width := Form1.Month1.Width + 30

      // aumentando as margens superior e inferior, do
      // controle Month2, em 15 pontos
      Form1.Month2.Height := Form1.Month1.Height + 30

      //-----------------//
      // controle Month3 //
      //-----------------//

      // criando o terceiro controle MonthCalendar padrão
      @ 220,10 MONTHCALENDAR Month3 ;
         TOOLTIP "Controle MonthCalendar com 20 pontos em cada margem e margem na cor laranja" ;
         BACKGROUNDCOLOR ORANGE

      // aumentando as margens esquerda e direita, do
      // controle Month3, em 20 pontos
      Form1.Month3.Width := Form1.Month1.Width + 40

      // aumentando as margens superior e inferior, do
      // controle Month3, em 20 pontos
      Form1.Month3.Height := Form1.Month1.Height + 40

      //-----------------//
      // controle Month4 //
      //-----------------//

      // criando o quarto controle MonthCalendar padrão
      @ 220,330 MONTHCALENDAR Month4 ;
         TOOLTIP "Controle MonthCalendar com margens diferentes na cor verde" ;
         BACKGROUNDCOLOR GREEN

      // aumentando as margens esquerda e direita, do
      // controle Month4, em 15 pontos
      Form1.Month4.Width := Form1.Month1.Width + 30

      // aumentando as margens superior e inferior, do
      // controle Month4, em 20 pontos
      Form1.Month4.Height := Form1.Month1.Height + 40

   END WINDOW

   // centralizando a janela
   CENTER WINDOW Form1

   // ativando a janela
   ACTIVATE WINDOW Form1

   Return Nil
