/*
 * MiniGUI OptionBox Function Demo
 * (c) 2016 Roberto Lopez
 *
*/

ANNOUNCE RDDSYS

#include "hmg.ch"

PROCEDURE MAIN

   // SET WINDOW MAIN OFF
   _HMG_MainWindowFirst := .F.

   MsgInfo( OptionBox( "Your choice", "Option 1;Option 2;Option 3;Option 4;Option 5", 2 ) )

RETURN


FUNCTION OPTIONBOX( cTitle, aOptions, nDefault )

   LOCAL nRet := nDefault

   IF ValType( aOptions ) == 'C'
      aOptions := hb_ATokens( aOptions, ";" )
   ENDIF

   IF ValType( nDefault ) == 'U'
      nDefault := 1
   ENDIF

   DEFINE WINDOW OPTIONBOX ;
      AT 0, 0 ;
      WIDTH 275 HEIGHT 170 + ( 30 * ( Len( aOptions ) - 2 ) ) ;
      TITLE cTitle ;
      MODAL ;
      NOSIZE NOSYSMENU

   DEFINE FRAME Frame_1
      ROW   08
      COL   10
      WIDTH   250
      HEIGHT   80 + ( 30 * ( Len( aOptions ) - 2 ) )
      CAPTION ''
   END FRAME

   DEFINE RADIOGROUP Radio_1
      ROW   25
      COL   30
      WIDTH   220
      HEIGHT   100 + ( 30 * ( Len( aOptions ) - 2 ) )
      OPTIONS   aOptions
      VALUE   nDefault
      ONCHANGE {|| nRet := This.Value }
   END RADIOGROUP

   DEFINE BUTTON OK
      ROW   100 + ( 30 * ( Len( aOptions ) - 2 ) )
      COL   30
      CAPTION   iif( Set ( _SET_LANGUAGE ) == 'ES', 'Aceptar', 'OK' )
      ACTION  {|| nRet := OPTIONBOX_OK() }
   END BUTTON

   DEFINE BUTTON CANCEL
      ROW   100 + ( 30 * ( Len( aOptions ) - 2 ) )
      COL   140
      CAPTION   iif( Set ( _SET_LANGUAGE ) == 'ES', 'Cancelar', 'Cancel' )
      ACTION  {|| nRet := OPTIONBOX_CANCEL() }
   END BUTTON

   ON KEY ESCAPE ACTION ( nRet := OPTIONBOX_CANCEL() )

   END WINDOW

   CENTER WINDOW OPTIONBOX
   ACTIVATE WINDOW OPTIONBOX

RETURN nRet


FUNCTION OPTIONBOX_OK

   LOCAL nRet

   nRet := OPTIONBOX.Radio_1.Value
   ThisWindow.Release

RETURN nRet


FUNCTION OPTIONBOX_CANCEL

   ThisWindow.Release

RETURN 0
