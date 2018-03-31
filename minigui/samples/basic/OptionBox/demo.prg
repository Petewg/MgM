/*
 * MiniGUI OptionBox Function Demo
 * (c) 2016 Roberto Lopez
 *
*/

ANNOUNCE RDDSYS

#define _HMG_OUTLOG

#include "hmg.ch"

PROCEDURE MAIN

   LOCAL cOption := "", i

   FOR i := 1 TO 5
      cOption += "Option " + hb_ntos( i ) + iif( i == 5, "", ";" )
   NEXT

   SET WINDOW MAIN OFF

   SET FONT TO "Arial", 10

   MsgInfo( OptionBox( "Your choice", cOption, 2 ) )

RETURN


FUNCTION OPTIONBOX( cTitle, aOptions, nDefault )

   LOCAL nRet := nDefault
   LOCAL nOptHeight

   SET LOGFILE TO "debug.txt"

   IF ValType( aOptions ) == 'C'
      aOptions := hb_ATokens( aOptions, ";" )

? aOptions
? repl('-',8)
?a aOptions

   ENDIF

   nOptHeight := 30 * ( Len( aOptions ) - 2 )

   IF ValType( nDefault ) == 'U'
      nDefault := 1
   ENDIF

   DEFINE WINDOW OPTIONBOX ;
      AT 0, 0 ;
      WIDTH 275 HEIGHT 170 + nOptHeight ;
      TITLE cTitle ;
      MODAL ;
      NOSIZE NOSYSMENU

   DEFINE FRAME Frame_1
      ROW   08
      COL   10
      WIDTH 250
      HEIGHT   80 + nOptHeight
      CAPTION ''
   END FRAME

   DEFINE RADIOGROUP Radio_1
      ROW   25
      COL   30
      WIDTH  220
      HEIGHT   100 + nOptHeight
      OPTIONS  aOptions
      VALUE    nDefault
      ONCHANGE {|| nRet := This.Value }
      SPACING  28
      AUTOSIZE .T.
   END RADIOGROUP

   DEFINE BUTTON OK
      ROW   100 + nOptHeight
      COL   30
      CAPTION   iif( Set ( _SET_LANGUAGE ) == 'ES', 'Aceptar', 'OK' )
      ACTION  {|| nRet := OPTIONBOX_OK() }
   END BUTTON

   DEFINE BUTTON CANCEL
      ROW   100 + nOptHeight
      COL   140
      CAPTION   iif( Set ( _SET_LANGUAGE ) == 'ES', 'Cancelar', 'Cancel' )
      ACTION  {|| nRet := OPTIONBOX_CANCEL() }
   END BUTTON

   ON KEY ESCAPE ACTION ( nRet := OPTIONBOX_CANCEL() )

   END WINDOW

   CENTER WINDOW OPTIONBOX
   ACTIVATE WINDOW OPTIONBOX

? "Return: ", nRet
? repl('-',9)

RETURN nRet


FUNCTION OPTIONBOX_OK

   LOCAL nRet

   nRet := OPTIONBOX.Radio_1.Value
   ThisWindow.Release

RETURN nRet


FUNCTION OPTIONBOX_CANCEL

   ThisWindow.Release

RETURN 0
