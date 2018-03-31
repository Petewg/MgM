// #define __NODEBUG__
#include 'debug.ch'
/*
 * Proyecto: PdfPrinter
 * Fichero: HaruUtils.prg
 * Descripción:
 * Autor:
 * Fecha: 22/02/2017
 */

#ifndef __XHARBOUR__
   #xcommand TRY  => BEGIN SEQUENCE WITH {| oErr | Break( oErr ) }
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
   #xcommand FINALLY => ALWAYS
   #xtranslate Throw( <oErr> ) => ( Eval( ErrorBlock(), <oErr> ), Break( <oErr> ) )
#endif

FUNCTION HaruOpenPdf( cPdf )

   LOCAL oShell
   LOCAL lOk := .T.

   TRY
      #ifdef __XHARBOUR__
            oShell := CreateObject( "WScript.Shell" )
      #else
            oShell := Win_OleCreateObject( "WScript.Shell" )
      #endif
   CATCH
      lOk := .F.
   END

   IF lOk

      TRY
         oShell:Run( "%COMSPEC% /c " + cPdf, 0, .T. )
      CATCH
         lOk := .F.
      END

   ENDIF

RETURN lOk
