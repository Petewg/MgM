/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"
#include "tsbrowse.ch"

FIELD id, info
*-----------------------------------
PROCEDURE Main
*-----------------------------------
   LOCAL i, obrw

   IF !hb_FileExists( "datab.dbf" )
      dbCreate( "datab", { { "ID", "N", 5, 0 }, { "INFO", "C", 15, 0 } } )
   ENDIF

   USE datab ALIAS base NEW
   INDEX ON id TO datab temporary

   IF LastRec() == 0
      FOR i := 1 TO 100
         APPEND BLANK
         REPLACE id WITH RecNo(), info WITH "record " + hb_ntos( RecNo(), 4 )
      NEXT
   ENDIF

   DEFINE WINDOW win_1 AT 0, 0 WIDTH 400 HEIGHT 500 ;
      MAIN TITLE "TSBrowse Add Record Demo" NOMAXIMIZE NOSIZE

      @06, 10 BUTTON BRUN CAPTION "Add Record" ACTION AddRecord( obrw ) DEFAULT

      DEFINE TBROWSE obrw AT 40, 10 GRID ALIAS "base" ;
         WIDTH 370 HEIGHT 418

      ADD COLUMN TO obrw HEADER "ID" ;
         SIZE 100 ;
         DATA FieldWBlock( "id", Select( "base" ) )

      ADD COLUMN TO obrw HEADER "INFO" ;
         SIZE 150 ;
         DATA FieldWBlock( "info", Select( "base" ) )

      obrw:lNoHScroll := .T.
      obrw:SetColor( { 2 }, { {|| iif( base->( ordKeyNo() ) % 2 == 0, RGB( 255, 255, 255 ), RGB( 230, 230, 230 ) ) } } )

      END TBROWSE

   END WINDOW

   CENTER WINDOW win_1
   ACTIVATE WINDOW win_1

RETURN

*-----------------------------------
PROCEDURE AddRecord( obrw )
*-----------------------------------
   APPEND BLANK
   REPLACE id WITH RecNo(), info WITH "record " + hb_ntos( RecNo(), 4 )

   obrw:GoToRec( base->( RecNo() ) )
   obrw:SetFocus()

RETURN
