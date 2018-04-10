/*----------------------------------------------------------------------------
 * WALERT()
 *
 * Direct replacement for Clipper ALERT() function
 *
 * Copyright 2006 Ricardo Sassy <rsassy@gmail.com>
 * www - http://www.harley.com.ar
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *----------------------------------------------------------------------------
 * FUNCTION walert( cMessage, aItems, cTitle ) ==> nValue returned
 *
 *    cMessage: Message to be displayed inside ALERT frame. Can contain ";"
 *               character(s) to line feed efect.
 *
 *    aItems  : (optional) An array of choices. If empty, a "OK" button will
 *               be displayed and return "0" value.
 *
 *    cTitle  : (optional) A title for ALERT window. If empty, default to "choice" message.
 *
 *    Function return numeric value from 1 to 4 according to button pressed
 *    or 0 (zero) value in case of interactive window closing.
 *
 *    In case of translate from original Clipper code to Minigui code
 *    only replace "ALERT" word for "WALERT" word.
 *
 *    Sample of Clipper code :  ALERT('Please;Choice output...',{'PRINTER','SCREEN'})
 *    Sample of Minigui code : WALERT('Please;Choice output...',{'PRINTER','SCREEN'})
----------------------------------------------------------------------------*/

#include "minigui.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )

//------------------------------------------//
PROCEDURE Main
//------------------------------------------//

   DEFINE WINDOW Win_1 ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 400 ;
      TITLE 'WALERT Function Test' ;
      MAIN

   DEFINE BUTTON Button_1
      ROW 10
      COL 10
      CAPTION 'Test 1'
      ACTION MsgInfo( "WALERT Return = " + LTrim( Str( WALERT( 'This is;an information screen;ONLY...',, 'Information' ) ) ) )
   END BUTTON

   DEFINE BUTTON Button_2
      ROW 40
      COL 10
      CAPTION 'Test 2'
      ACTION MsgInfo( "WALERT Return = " + LTrim( Str( WALERT( 'Please;Choice output...', { 'PRINTER', 'SCREEN' } ) ) ) )
   END BUTTON

   DEFINE BUTTON Button_3
      ROW 70
      COL 10
      CAPTION 'Test 3'
      ACTION MsgInfo( "WALERT Return = " + LTrim( Str( WALERT( 'Please;Choice output...', { 'PRINTER', 'SCREEN', 'MAIL' } ) ) ) )
   END BUTTON

   DEFINE BUTTON Button_4
      ROW 100
      COL 10
      CAPTION 'Test 4'
      ACTION MsgInfo( "WALERT Return = " + LTrim( Str( WALERT( 'Please;Choice output...', { 'PRINTER', 'SCREEN', 'MAIL', 'FAX' } ) ) ) )
   END BUTTON

   DEFINE BUTTON Button_5
      ROW 130
      COL 10
      CAPTION '&Close'
      ACTION ThisWindow.Release
   END BUTTON

   END WINDOW

   CENTER WINDOW Win_1

   ACTIVATE WINDOW Win_1

RETURN

//------------------------------------------//
FUNCTION walert( cMessage, aItems, cTitle )
//------------------------------------------//
   LOCAL I, J := 0, nStart := 1, nValue := 0, cTextLabel
   LOCAL nItemCount, nHeight, cBtnName

   DEFAULT aItems TO {}
   DEFAULT cMessage TO ' '

   IF SET( _SET_LANGUAGE ) == 'ES'
      DEFAULT cTitle TO 'Seleccione...'
   ELSE
      DEFAULT cTitle TO 'Please, select'
   ENDIF
   cMessage := cMessage + ';'

   DEFINE WINDOW walert ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 215 ;
      TITLE cTitle ;
      MODAL ;
      NOSIZE

   ON KEY ESCAPE ACTION walert.Release

   // ******************** DISPLAY MESSAGE *******************************
   FOR I := 1 TO Len( cMessage )

      IF SubStr( cMessage, I, 1 ) == ';'

         cTextLabel := 'Text' + Str( ++J, 1 )
         @ J * 20 - 10, 16 LABEL &cTextLabel WIDTH 368 HEIGHT 20 ;
            VALUE SubStr( cMessage, nStart, I - nStart ) CENTERALIGN

         nStart := I + 1

      ENDIF

   NEXT I

   // ******************** DRAW BUTTONS ***********************************
   nItemCount := Len( aItems )  // quantity of buttons
   IF nItemCount > 1
      nStart := 200 - ( nItemCount * 80 + ( nItemCount - 1 ) * 20 ) / 2
      /*
        80 - width of Button
        20 - space between buttons
        200 is half of width of walert window
      */
   ENDIF

   nHeight := walert.Height

   IF nItemCount <= 1

      @ nHeight - 70, 160 BUTTON Button_1 ;
         CAPTION '&OK' ;
         ACTION {|| nValue := 0, walert.Release } ;
         WIDTH 80 HEIGHT 28 DEFAULT

   ELSE

      FOR i := 1 TO nItemCount

         cBtnName := "Button_" + Str( i, 1 )
         @ nHeight - 70, nStart + 100 * ( i - 1 ) BUTTON &cBtnName ;
            CAPTION '&' + aItems[ i ] ;
            ACTION {|| nValue := Val( Right( This.Name, 1 ) ), walert.Release } ;
            WIDTH 80 HEIGHT 28

      NEXT i

      IF nItemCount > 3
         walert.Width := ( walert.Width ) + iif( _HMG_IsXP, 2, 1 ) * GetBorderWidth()
      ENDIF

      walert.Button_1.Setfocus

   ENDIF

   END WINDOW

   CENTER WINDOW walert

   ACTIVATE WINDOW walert

RETURN( nValue )
