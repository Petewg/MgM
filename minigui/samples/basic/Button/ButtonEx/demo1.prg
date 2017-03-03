/*
 * MINIGUI - Harbour Win32 GUI library
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * ButtonEx Demo1
 * (C) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
 * HMG 1.0 Experimental Build 9a
*/

#include "MiniGUI.ch"

MEMVAR lState, lRecord, aMusic, lThemed
****************************
FUNCTION Main()
****************************
   PUBLIC lState := .F., lRecord := .F., aMusic := {}, lThemed := IsThemed()

   DEFINE WINDOW Form_1 ;
      AT 141, 245 WIDTH 457 HEIGHT 291 ;
      MAIN ;
      TITLE "ButtonEX Demo1" ;
      NOMAXIMIZE NOSIZE ;
      ON INIT ONOFF( .T., .T. ) ;
      FONT "MS Sans serif" SIZE 8

   ON KEY ESCAPE      ACTION ONOFF( lState )
   ON KEY ALT + X     ACTION ThisWindow.Release
   ON KEY CONTROL + X ACTION ThisWindow.Release

   @ 20, 10 LABEL label_1 VALUE "Stainway HMG 1.0 Exp. Build 9a Demo" WIDTH 420 HEIGHT 28 FONT "MS Sans serif" SIZE 15 ITALIC BOLD CENTERALIGN TRANSPARENT

   @ 66, 20 BUTTONEX ONOFF ;
      WIDTH 54 ;
      HEIGHT 70 ;
      VERTICAL ;
      CAPTION "ON" ;
      PICTURE "piano000" ;
      FONTCOLOR RED ;
      BOLD ;
      NOTRANSPARENT ;
      BACKCOLOR  WHITE ;
      FLAT ;
      ACTION ONOFF( lState )

   @140, 20 BUTTONEX REC_1 CAPTION "REC" FONTCOLOR RED WIDTH 54 HEIGHT 25 BOLD ACTION DOREC( lRecord )

   @ 140, 91 BUTTONEX BUTTONEX_1 CAPTION "C" WIDTH 31 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white";
      ACTION  {|| ( PLAYTONE( This.Caption ) ) };
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) }

   @ 66, 108 BUTTONEX BUTTONEX_9 CAPTION "C#" WIDTH 26 HEIGHT 72 VERTICAL;
      BACKCOLOR iif( lThemed, NIL, BLACK ) ;
      FONTCOLOR iif( lThemed, NIL, WHITE ) ;
      ON GOTFOCUS {|| ( This.Picture := "blackdot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "black" ) };
      PICTURE "black";
      ACTION  {|| ( PLAYTONE( This.Caption ) ) } UPPERTEXT

   @ 140, 123 BUTTONEX BUTTONEX_2 CAPTION "D" WIDTH 31 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white" ;
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) };
      ACTION  {|| ( PLAYTONE( This.Caption ) ) }

   @ 66, 142 BUTTONEX BUTTONEX_10 CAPTION "D#" WIDTH 26 HEIGHT 72 VERTICAL;
      ON GOTFOCUS {|| ( This.Picture := "blackdot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "black" ) };
      BACKCOLOR iif( lThemed, NIL, BLACK ) ;
      FONTCOLOR iif( lThemed, NIL, WHITE ) ;
      PICTURE "black";
      ACTION  {|| ( PLAYTONE( This.Caption ) ) } UPPERTEXT

   @ 140, 155 BUTTONEX BUTTONEX_3 CAPTION "E" WIDTH 32 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white" ;
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) };
      ACTION  {|| ( PLAYTONE( This.Caption ) ) }

   @ 140, 188 BUTTONEX BUTTONEX_4 CAPTION "F" WIDTH 32 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white" ;
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) };
      ACTION  {|| ( PLAYTONE( This.Caption ) ) }

   @ 66, 208 BUTTONEX BUTTONEX_11 CAPTION "F#" WIDTH 26 HEIGHT 72 VERTICAL;
      ON GOTFOCUS {|| ( This.Picture := "blackdot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "black" ) };
      BACKCOLOR iif( lThemed, NIL, BLACK ) ;
      FONTCOLOR iif( lThemed, NIL, WHITE ) ;
      PICTURE "black";
      ACTION  {|| ( PLAYTONE( This.Caption ) ) } UPPERTEXT

   @ 140, 221 BUTTONEX BUTTONEX_5 CAPTION "G" WIDTH 32 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white" ;
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) };
      ACTION  {|| ( PLAYTONE( This.Caption ) ) }

   @ 66, 241 BUTTONEX BUTTONEX_12 CAPTION "G#" WIDTH 26 HEIGHT 72 VERTICAL;
      ON GOTFOCUS {|| ( This.Picture := "blackdot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "black" ) };
      BACKCOLOR iif( lThemed, NIL, BLACK ) ;
      FONTCOLOR iif( lThemed, NIL, WHITE ) ;
      PICTURE "black";
      ACTION  {|| ( PLAYTONE( This.Caption ) ) } UPPERTEXT

   @ 140, 254 BUTTONEX BUTTONEX_6 CAPTION "A" WIDTH 32 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white" ;
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) };
      ACTION  {|| ( This.Picture := "whitedot", PLAYTONE( This.Caption ) ) }

   @ 66, 274 BUTTONEX BUTTONEX_13 CAPTION "A#" WIDTH 26 HEIGHT 72 VERTICAL;
      ON GOTFOCUS {|| ( This.Picture := "blackdot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "black" ) };
      BACKCOLOR iif( lThemed, NIL, BLACK ) ;
      FONTCOLOR iif( lThemed, NIL, WHITE ) ;
      PICTURE "black";
      ACTION  {|| ( PLAYTONE( This.Caption ) ) } UPPERTEXT

   @ 140, 287 BUTTONEX BUTTONEX_7 CAPTION "H" WIDTH 32 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white" ;
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) };
      ACTION  {|| ( PLAYTONE( This.Caption ) ) }

   @ 140, 320 BUTTONEX BUTTONEX_8 CAPTION "C1" WIDTH 32 HEIGHT 91;
      BACKCOLOR WHITE BOLD VERTICAL PICTURE "white" ;
      ON GOTFOCUS {|| ( This.Picture := "whitedot" ) };
      ON LOSTFOCUS {|| ( This.Picture := "white" ) };
      ACTION  {|| ( PLAYTONE( This.Caption ) ) }

   END WINDOW

   Form_1.Center
   Form_1.Activate

RETURN NIL

****************************
FUNCTION PLAYIT( aMuza )
****************************
   LOCAL i

   lRecord := .F.

   FOR i = 1 TO Len( aMuza )
      PLAYTONE( aMuza[ i, 1 ] )
      InkeyGUI( 100 )   // delay
   NEXT i

   aMusic := {}
   Form_1.REC_1.Caption := "REC"

RETURN NIL

****************************
FUNCTION DOREC( lRec )
****************************
   LOCAL cDef := "{", i

   IF lRec == .F.
      aMusic := {}
      Form_1.REC_1.Caption := "STOP"
      lRecord := !lRec
   ELSE
      Form_1.REC_1.Caption := "REC"
      IF Len( aMusic ) > 0
         FOR i = 1 TO Len( aMusic )
            cDef += "{'" + aMusic[ i, 1 ] + "',1},;" + CRLF
         NEXT i
         cDef += "}"
         // TONE(100)
         COPYTOCLIPBOARD( cDef )
         Form_1.REC_1.Caption := "PLAY"
         PLAYIT( aMusic )
         lRecord := !lRec
      ENDIF
   ENDIF

RETURN NIL

****************************
FUNCTION ONOFF( mystate, lInit )
****************************

   IF !Empty( lInit ) .AND. lInit == .T.

      DisableAllButtons()
      Form_1.ONOFF.Enabled := .T.
      Form_1.ONOFF.Caption := iif( mystate, "ON", "OFF" )
      Form_1.ONOFF.FontColor := iif( mystate, RED, GREEN )

      RETURN NIL
   ENDIF

   IF lState

      DisableAllButtons()

      Form_1.ONOFF.Enabled := .T.
      Form_1.ONOFF.Picture := "piano002"
      InkeyGUI( 100 )
      Form_1.ONOFF.Picture := "piano001"
      InkeyGUI( 100 )
      Form_1.ONOFF.Picture := "piano000"
   ELSE
      Form_1.ONOFF.Picture := "piano001"
      InkeyGUI( 100 )
      Form_1.ONOFF.Picture := "piano002"
      InkeyGUI( 100 )
      Form_1.ONOFF.Picture := "piano003"

      EnableAllButtons()

      PlayAllSounds()
   ENDIF

   Form_1.ONOFF.Enabled := .T.
   Form_1.ONOFF.Caption := iif( mystate, "ON", "OFF" )
   Form_1.ONOFF.FontColor := iif( mystate, RED, GREEN )
   lState := !mystate

RETURN NIL

****************************
FUNCTION PLAYTONE( cTone )
****************************
   LOCAL i, aTones := { ;
      { "C ", 261.70 }, ;
      { "C#", 277.20 }, ;
      { "D ", 293.70 }, ;
      { "D#", 311.10 }, ;
      { "E ", 329.60 }, ;
      { "F ", 349.20 }, ;
      { "F#", 370.00 }, ;
      { "G ", 392.00 }, ;
      { "G#", 415.30 }, ;
      { "A ", 440.00 }, ;
      { "A#", 466.20 }, ;
      { "H ", 493.90 }, ;
      { "C1", 523.30 }, }


   i := AScan( aTones, {| aVal| aVal[ 1 ] == PadR( cTone, 2 ) } )

   IF i > 0
      Tone( aTones[ i, 2 ] )

      IF lRecord
         AAdd( aMusic, { cTone, 1 } )
      ELSEIF Form_1.REC_1.Caption == "PLAY"
         _SetFocus ( GetBtnName( aTones[ i, 1 ] ), 'Form_1' )
      ENDIF

   ENDIF

RETURN NIL

****************************
FUNCTION GetBtnName( cCaption )
****************************
   LOCAL i, cBtn := "BUTTONEX_1"

   FOR i = 1 TO Len( _HMG_aControlType )

      IF At( "BUTTON", _HMG_aControlType[ i ] ) > 0

         IF Len( _HMG_aControlCaption[ i ] ) <= 2 .AND. _HMG_aControlCaption[ i ] == Trim( cCaption )

            cBtn := _HMG_aControlNames[ i ]

            EXIT

         ENDIF

      ENDIF

   NEXT i

RETURN cBtn

****************************
FUNCTION DisableAllButtons()
****************************
   LOCAL i

   FOR i = 1 TO Len( _HMG_aControlType )
      IF At( "BUTTON", _HMG_aControlType[ i ] ) > 0
         _DisableControl ( _HMG_aControlNames[ i ], "Form_1" )
      ENDIF
   NEXT i

RETURN NIL

****************************
FUNCTION EnableAllButtons()
****************************
   LOCAL i

   FOR i = 1 TO Len( _HMG_aControlType )
      IF At( "BUTTON", _HMG_aControlType[ i ] ) > 0
         _EnableControl ( _HMG_aControlNames[ i ], "Form_1" )
      ENDIF
   NEXT i

RETURN NIL

****************************
FUNCTION PlayAllSounds()
****************************
   LOCAL i

   FOR i = 1 TO Len( _HMG_aControlType )

      IF At( "BUTTON", _HMG_aControlType[ i ] ) > 0

         IF Len( _HMG_aControlCaption[ i ] ) <= 2 .AND. Len( _HMG_aControlCaption[ i ] ) > 0 .AND. _HMG_aControlCaption[ i ] <> "ON"

            _SetFocus ( _HMG_aControlNames[ i ], 'Form_1' )

            PLAYTONE( _HMG_aControlCaption[i ] )
            InkeyGUI( 100 )        // delay

         ENDIF

      ENDIF

   NEXT i

RETURN NIL
