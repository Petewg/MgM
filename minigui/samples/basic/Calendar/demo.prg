/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * CALENDAR demo
 * (C) 2005 Javier Giralda <giraldfj@yahoo.es>
 *
 * 2010-05-27 Edited by Alexey L. Gustow <gustow33 @ mail.ru> ("GAL")
 * - translation to English
 * - little reformatting
*/

#include "minigui.ch"

STATIC Ldia

*------------------------------------------------------------*
FUNCTION Main()
*------------------------------------------------------------*

   LOCAL r := 50, c := 10, i, m, z, imagen

   SET LANGUAGE TO ENGLISH    // GAL (SPANISH -> ENGLISH)

   SET MULTIPLE OFF WARNING

   SET DATE FORMAT TO 'dd/mm/yyyy'

   SET TOOLTIPBALLOON ON

   DEFINE WINDOW Agenda;
      AT 0, 0;
      WIDTH  310+GetBorderWidth();
      HEIGHT 390+GetTitleHeight()+GetBorderHeight();
      TITLE "Calendar";
      ICON 'AGENDA.ICO';
      MAIN;
      NOMAXIMIZE NOSIZE

      // Select a picture for season of year
      // (Cambia el fondo segun la estacion)
      imagen := GetSeasonPict( Date() )

      @ 0,0 IMAGE Image_1 ; 
         PICTURE imagen ;
         WIDTH 310 HEIGHT 390

      FOR i := 1 TO 42

         m := "LABEL_" + Ltrim( Str( i ) )

         DEFINE LABEL &m
            ROW    r
            COL    c
            WIDTH  39
            HEIGHT 40
            FONTNAME "Times"
            FONTSIZE 22
            VISIBLE .T.
            TRANSPARENT .T.
            CENTERALIGN .T.
         END LABEL

         c += 40
         IF c > 250
            c := 10
            r += 40
         ENDIF

      NEXT i

      DEFINE LABEL Label_43
         ROW    30
         COL    10
         WIDTH  30
         HEIGHT 20
         VALUE "Mon"        // "Lun"
         FONTNAME "Arial"
         FONTSIZE 9
         VISIBLE .T.
         TRANSPARENT .T.
      END LABEL

      DEFINE LABEL Label_44
         ROW    30
         COL    50
         WIDTH  30
         HEIGHT 20
         VALUE "Tue"        // "Mar"
         FONTNAME "Arial"
         FONTSIZE 9
         VISIBLE .T.
         TRANSPARENT .T.
      END LABEL

      DEFINE LABEL Label_45
         ROW    30
         COL    90
         WIDTH  30
         HEIGHT 20
         VALUE "The"        // "Mie"
         FONTNAME "Arial"
         FONTSIZE 9
         VISIBLE .T.
         TRANSPARENT .T.
      END LABEL

      DEFINE LABEL Label_46
         ROW    30
         COL    130
         WIDTH  30
         HEIGHT 20
         VALUE "Wed"        // "Jue"
         FONTNAME "Arial"
         FONTSIZE 9
         VISIBLE .T.
         TRANSPARENT .T.
      END LABEL

      DEFINE LABEL Label_47
         ROW    30
         COL    170
         WIDTH  30
         HEIGHT 20
         VALUE "Fri"        // "Vie"
         FONTNAME "Arial"
         FONTSIZE 9
         VISIBLE .T.
         TRANSPARENT .T.
      END LABEL

      DEFINE LABEL Label_48
         ROW    30
         COL    210
         WIDTH  30
         HEIGHT 20
         VALUE "Sat"        // "Sab"
         FONTNAME "Arial"
         FONTSIZE 9
         VISIBLE .T.
         TRANSPARENT .T.
      END LABEL

      DEFINE LABEL Label_49
         ROW    30
         COL    250
         WIDTH  30
         HEIGHT 20
         VALUE "Sun"        // "Dom"
         FONTNAME "Arial"
         FONTSIZE 9
         VISIBLE .T.
         TRANSPARENT .T.
         FONTCOLOR { 255, 0, 0 }   // red
         FONTBOLD .T.
      END LABEL

      DEFINE LABEL Label_50
         ROW    5
         COL    10
         WIDTH  150
         HEIGHT 24
         VALUE z
         FONTNAME "Arial"
         FONTSIZE 14
         VISIBLE .T.
         TRANSPARENT .T.
         FONTCOLOR { 0, 0, 255 }   // blue
      END LABEL

      @ 310, 30 BUTTON ANTERIOR ;
         CAPTION '&Previous' ;  // '&Anterior'
         WIDTH 80;
         HEIGHT 28;
         ACTION Anterior()

      @ 310, 110 BUTTON HOY ;
         CAPTION '&Today' ;     // '&Hoy'
         WIDTH 80;
         HEIGHT 28;
         ACTION Hoy()

      @ 310, 190 BUTTON POSTERIOR ;
         CAPTION '&Next' ;      // '&Siguiente'
         WIDTH 80;
         HEIGHT 28;
         ACTION Posterior()

      @ 5, 200 HYPERLINK Label_0 ;
         VALUE 'giraldfj@yahoo.es' ;
         ADDRESS "giraldfj@yahoo.es?cc=&bcc=" + ;
                 "&subject=Calendar%20Feedback:" ;
         WIDTH 100 HEIGHT 14 ;
         TOOLTIP "Send me your commentaries, advices or bug reports" ;
         ;       // "Escríbeme si tienes algún comentario" ;
         FONTCOLOR BLUE TRANSPARENT HANDCURSOR

      Ldia := Calend( Date() )   // Calendar Visualization (1st time - for "today")
                                 // LLama a la rutina de visualizar el calendario
      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Agenda
   ACTIVATE WINDOW Agenda

RETURN NIL

*------------------------------------------------------------*
FUNCTION Calend( Ldia )
*------------------------------------------------------------*

   LOCAL r := 50, c := 10, i, n, m, start

   start := DoW( ctod("01/" + substr( dtoc( Ldia ), 4, 3) + ;
                              substr( dtoc( Ldia ), 7, 4) ) ) - 1
   IF start == 0
      start := 7
   ENDIF

   Agenda.LABEL_50.Value := cMonth( Ldia ) + " " + str( year( Ldia ), 4 )

   FOR i := 1 TO 49  // Setting properties for days controls (Borra todos los dias)
      m := "LABEL_" + Ltrim( Str( i ) )
      IF i < 43
         SetProperty( 'Agenda', m, 'VISIBLE', .F. )
         SetProperty( 'Agenda', m, 'VALUE', Space( 2 ) )
         SetProperty( 'Agenda', m, 'BACKCOLOR', { NIL, NIL, NIL } )
         SetProperty( 'Agenda', m, 'FONTCOLOR', { 0, 0, 0 } )
         SetProperty( 'Agenda', m, 'FONTITALIC', .F. )
         SetProperty( 'Agenda', m, 'FONTBOLD', .F. )
      ELSE
         DoMethod( 'Agenda', m, 'REFRESH' )
      ENDIF
   NEXT

   // Let's visualize new calendar for "Ldia" month and year
   // (Escribe de nuevo el calendario con los datos del nuevo mes)
   FOR i := 1 TO 42
      n := Ltrim( Str( start ) )
      m := "LABEL_" + n
      IF Substr( Dtoc( CtoD( Str( i ) + "-" + Str( Month( Ldia ) ) + "-" + ;
                 Str( Year( Ldia ) ) ) ), 1, 2) <> Space( 2 )
         SetProperty('Agenda', m, 'VALUE', Ltrim( Str( i ) ) )
         start++
         IF i == Day( Date() ) .and. ;
            Month( Ldia ) == Month( Date() ) .and. ;
            Year( Ldia ) == Year( Date() )          // This is TODAY day
                                                    // (Si es dia HOY)
            SetProperty( 'Agenda', m, 'FONTCOLOR', { 0, 0, 255 } )    // blue
            SetProperty( 'Agenda', m, 'FONTITALIC', .T. )
            SetProperty( 'Agenda', m, 'FONTBOLD', .T. )
         ENDIF
         IF i == 25 .and. Month( Ldia ) == 12
            SetProperty( 'Agenda', m, 'FONTCOLOR', { 255, 0, 0 } )    // red
            SetProperty( 'Agenda', m, 'FONTITALIC', .T. )
            SetProperty( 'Agenda', m, 'TOOLTIP', "Christmas" )
         ELSEIF i == 1 .and. Month( Ldia ) == 1
            SetProperty( 'Agenda', m, 'FONTCOLOR', { 255, 0, 0 } )    // red
            SetProperty( 'Agenda', m, 'FONTITALIC', .T. )
            SetProperty( 'Agenda', m, 'TOOLTIP', "New Year" )
         ELSE
            SetProperty( 'Agenda', m, 'TOOLTIP', "Day: " + Ltrim( Str( i ) ) )  // was "Dia: "
         ENDIF
         SetProperty( 'Agenda', m, 'VISIBLE', .T. )
      ELSE
         // This control not corresponded with any day of month (not visible)
         // (Si no corresponde a ningun dia del mes)
         SetProperty( 'Agenda', m, 'VISIBLE', .F. )
         SetProperty( 'Agenda', m, 'VALUE', Space( 2 ) )
      ENDIF
   NEXT

RETURN (Ldia)

*------------------------------------------------------------*
FUNCTION Anterior()   // go to previous month
*------------------------------------------------------------*

   IF Month( Ldia - 28 ) == Month( Ldia )
      Ldia -= 35
   ELSE
      Ldia -= 28
   ENDIF

   Agenda.Image_1.Picture := GetSeasonPict( Ldia )
   Agenda.Hoy.Hide
   Agenda.Hoy.Show
   Agenda.Posterior.Hide
   Agenda.Posterior.Show

RETURN Calend(Ldia)   // Calendar Visualization (LLama a la rutina de visualizar el calendario)

*------------------------------------------------------------*
FUNCTION Hoy()        // go to today
*------------------------------------------------------------*

   Ldia := Date()

   Agenda.Image_1.Picture := GetSeasonPict( Ldia )
   Agenda.Anterior.Hide
   Agenda.Anterior.Show
   Agenda.Posterior.Hide
   Agenda.Posterior.Show

RETURN Calend( Ldia )

*------------------------------------------------------------*
FUNCTION Posterior()  // go to next month
*------------------------------------------------------------*

   IF Month( Ldia + 28 ) == Month( Ldia )
      Ldia += 35
   ELSE
      Ldia += 28
   ENDIF

   Agenda.Image_1.Picture := GetSeasonPict( Ldia )
   Agenda.Anterior.Hide
   Agenda.Anterior.Show
   Agenda.Hoy.Hide
   Agenda.Hoy.Show

RETURN Calend( Ldia )

*------------------------------------------------------------*
FUNCTION GetSeasonPict( dDate )  // Select a picture for season of year
*------------------------------------------------------------*
   LOCAL imagen

      DO CASE 
      CASE Month( dDate ) == 12 .and. Day( dDate ) > 18
         imagen := "XMAS.JPG"
      CASE Month( dDate ) == 12 .or. Month( dDate ) < 3
         imagen := "WINTER.JPG"
      CASE Month( dDate ) > 2 .and. Month( dDate ) < 6
         imagen := "SPRING.JPG"
      CASE Month( dDate ) > 5 .and. Month( dDate ) < 9
         imagen := "SUMMER.JPG"
      CASE Month( dDate ) > 8 .and. Month( dDate ) < 12
         imagen := "AUTUMN.JPG"
      ENDCASE       

RETURN imagen
