/*
  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com/

  Desarrollado con Harbour Compiler y
  MINIGUI - Harbour Win32 GUI library (HMG).

  Copyright 2007 Jose Miguel <josemisu@yahoo.com.ar>
*/

#include "minigui.ch"
#include "winprint.ch"

PROCEDURE Main()

   LOCAL aIMP90

   INIT PRINTSYS
   GET PRINTERS TO aIMP90
   RELEASE PRINTSYS

   SET FONT TO _GetSysFont(), 9

   DEFINE WINDOW W_Imp1 ;
      AT 10, 10 ;
      WIDTH 800 HEIGHT 600 ;
      TITLE 'Pruebas' ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE

   @15, 10 LABEL L_ImpDef1 VALUE "GET DEFAULT PRINTER TO" AUTOSIZE TRANSPARENT
   @10, 200 TEXTBOX T_ImpDef1 WIDTH 300 FONT _GetSysFont() SIZE 10

   @45, 10 LABEL L_Impresora VALUE "GET PRINTERS TO" AUTOSIZE TRANSPARENT
   @40, 200 COMBOBOX C_Impresora WIDTH 300 ;
      ITEMS aIMP90 VALUE 1 ON CHANGE Actualizar1() FONT _GetSysFont() SIZE 10

   @75, 10 LABEL L_PRINTER VALUE "GET SELECTED PRINTER TO" AUTOSIZE TRANSPARENT
   @70, 200 TEXTBOX T_PRINTER WIDTH 300 FONT _GetSysFont() SIZE 10

   @105, 10 LABEL L_BACKCOLOR VALUE "GET BACKCOLOR TO" AUTOSIZE TRANSPARENT
   @100, 200 TEXTBOX T_BACKCOLOR WIDTH 300 NUMERIC RIGHTALIGN FONT _GetSysFont() SIZE 10

   @135, 10 LABEL L_TEXTCOLOR VALUE "GET TEXTCOLOR TO" AUTOSIZE TRANSPARENT
   @130, 200 TEXTBOX T_TEXTCOLOR WIDTH 300 NUMERIC RIGHTALIGN FONT _GetSysFont() SIZE 10

   @15, 550 LABEL L_UNITS VALUE "SET UNITS" AUTOSIZE TRANSPARENT
   @10, 650 RADIOGROUP R_UNITS ;
      OPTIONS { 'ROWCOL', 'MM', 'INCHES', 'PIXELS' } ;
      VALUE 2 ;
      WIDTH 75 TRANSPARENT ;
      ON CHANGE Actualizar2()

   @135, 550 LABEL L_HBPRNMAXROW VALUE "HBPRNMAXROW" AUTOSIZE TRANSPARENT
   @130, 650 TEXTBOX T_HBPRNMAXROW WIDTH 100 NUMERIC RIGHTALIGN FONT _GetSysFont() SIZE 10

   @165, 550 LABEL L_HBPRNMAXCOL VALUE "HBPRNMAXCOL" AUTOSIZE TRANSPARENT
   @160, 650 TEXTBOX T_HBPRNMAXCOL WIDTH 100 NUMERIC RIGHTALIGN FONT _GetSysFont() SIZE 10

   @160, 10 GRID GR_Bins ;
      HEIGHT 100 ;
      WIDTH 250 ;
      HEADERS { 'GET BINS TO', 'numero' } ;
      WIDTHS { 150, 80 } ;
      ITEMS {} ;
      VALUE 1 FONT _GetSysFont() SIZE 10

   @160, 270 GRID GR_PORTS ;
      HEIGHT 100 ;
      WIDTH 230 ;
      HEADERS { 'GET PORTS TO' } ;
      WIDTHS { 200 } ;
      ITEMS {} ;
      VALUE 1 FONT _GetSysFont() SIZE 10

   @270, 10 GRID GR_Papers ;
      HEIGHT 280 ;
      WIDTH 490 ;
      HEADERS { 'GET PAPERS TO', 'numero', 'ancho', 'alto' } ;
      WIDTHS { 200, 80, 80, 80 } ;
      ITEMS {} ;
      VALUE 1 ON CHANGE Actualizar2() FONT _GetSysFont() SIZE 10

   Actualizar1()

   ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW W_Imp1
   ACTIVATE WINDOW W_Imp1

RETURN


STATIC FUNCTION Actualizar1()

   LOCAL ImpresoraDefecto, cPRINTER, aIMP91, aIMP92, aPORTS, nBACKCOLOR, nTEXTCOLOR
   LOCAL aIMP91B, aIMP92B, N

   INIT PRINTSYS
   GET DEFAULT PRINTER TO ImpresoraDefecto
   SELECT PRINTER W_Imp1 .C_Impresora. DisplayValue
   GET SELECTED PRINTER TO cPRINTER
   GET BINS TO aIMP91
   GET PAPERS TO aIMP92
   GET PORTS TO aPORTS
   GET BACKCOLOR TO nBACKCOLOR
   GET TEXTCOLOR TO nTEXTCOLOR
   RELEASE PRINTSYS

   W_Imp1.T_ImpDef1.Value := ImpresoraDefecto
   W_Imp1.T_PRINTER.Value := cPRINTER
   W_Imp1.T_BACKCOLOR.Value := nBACKCOLOR
   W_Imp1.T_TEXTCOLOR.Value := nTEXTCOLOR


   aIMP91B := {}
   FOR N = 1 TO Len( aIMP91 )
      DO CASE
      CASE Len( aIMP91[ N ] ) = 1
         AAdd( aIMP91B, { aIMP91[ N ], "" } )
      CASE Len( aIMP91[ N ] ) = 2
         AAdd( aIMP91B, aIMP91[ N ] )
      ENDCASE
   NEXT
   W_Imp1.GR_Bins.DeleteAllItems
   IF Len( aIMP91B ) > 0
      FOR N = 1 TO Len( aIMP91B )
         W_Imp1.GR_Bins.AddItem( aIMP91B[ N ] )
      NEXT
   ENDIF
   W_Imp1.GR_Bins.Refresh


   W_Imp1.GR_PORTS.DeleteAllItems
   IF Len( aPORTS ) > 0
      FOR N = 1 TO Len( aPORTS )
         IF N == W_Imp1.C_Impresora.Value
            W_Imp1.GR_PORTS.AddItem( { aPORTS[ N ] } )
            EXIT
         ENDIF
      NEXT
   ENDIF
   W_Imp1.GR_PORTS.Refresh


   aIMP92B := {}
   FOR N = 1 TO Len( aIMP92 )
      IF Len( aIMP92[ N ] ) = 4
         AAdd( aIMP92B, aIMP92[ N ] )
      ENDIF
   NEXT
   W_Imp1.GR_Papers.DeleteAllItems
   IF Len( aIMP92B ) > 0
      FOR N = 1 TO Len( aIMP92B )
         W_Imp1.GR_Papers.AddItem( aIMP92B[ N ] )
      NEXT
      W_Imp1.GR_Papers.Refresh
   ENDIF
   IF W_Imp1.GR_Papers.ItemCount > 1
      W_Imp1.GR_Papers.Value := 1
   ENDIF

RETURN NIL


STATIC FUNCTION Actualizar2()

   INIT PRINTSYS
   SELECT PRINTER W_Imp1.C_Impresora.DisplayValue
   SET PAGE PAPERSIZE Val( W_Imp1.GR_Papers.Cell( W_Imp1.GR_Papers.Value, 2 ) )
   DO CASE
   CASE W_Imp1.R_UNITS.Value = 1
      SET UNITS ROWCOL
   CASE W_Imp1.R_UNITS.Value = 2
      SET UNITS MM
   CASE W_Imp1.R_UNITS.Value = 3
      SET UNITS INCHES
   CASE W_Imp1.R_UNITS.Value = 4
      SET UNITS PIXELS
   ENDCASE
   W_Imp1.T_HBPRNMAXROW.Value := HBPRNMAXROW
   W_Imp1.T_HBPRNMAXCOL.Value := HBPRNMAXCOL
   RELEASE PRINTSYS

RETURN NIL
