/*
 * Harbour MiniGUI Tone Demo
 *
 * (c) 2009-2011 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Revised by Alexey L. Gustow <gustow33@mail.ru>
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Tone function via sound card Demo' ;
		MAIN

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			CAPTION 'Play Tones'
			ACTION HappyBirthday()
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	45
			COL	10
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

	END WINDOW

	Form_1.Center
	Form_1.Activate

Return Nil


PROCEDURE HappyBirthday

   VALTONE("G2 ",1/4)
   VALTONE("G2 ",1/8)
   VALTONE("A2 ",1/4)
   VALTONE("P ",1/8)
   VALTONE("G2 ",1/4)
   VALTONE("P ",1/8)
   VALTONE("C3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("H2 ",1/4)
   VALTONE("P ",1/8)
   VALTONE("P ",1/8)
   VALTONE("P ",1/8)
   VALTONE("P ",1/8)
   VALTONE("G2 ",1/4)
   VALTONE("G2 ",1/8)
   VALTONE("A2 ",1/4)
   VALTONE("P ",1/8)
   VALTONE("G2 ",1/4)
   VALTONE("P ",1/8)
   VALTONE("D3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("C3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("P ",1/8)
   VALTONE("P ",1/8)
   VALTONE("P ",1/8)
   VALTONE("G2 ",1/4)
   VALTONE("G2 ",1/8)
   VALTONE("G3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("E3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("C3 ",1/4)   //GAL
   VALTONE("C3 ",1/8)   //GAL
   VALTONE("H2 ",1/4)
   VALTONE("P ",1/8)
   VALTONE("A2 ",1/4)
   VALTONE("P ",1/8)
   VALTONE("F3 ",1/4)   //GAL
   VALTONE("F3 ",1/8)   //GAL
   VALTONE("E3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("C3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("D3 ",1/4)   //GAL
   VALTONE("P ",1/8)
   VALTONE("C3 ",1/4)   //GAL
   VALTONE("P ",1/2)

RETURN


FUNCTION VALTONE( val_note, val_time )
   val_time *= 24

   DO CASE
   CASE val_note=="C1 "
      TONE(262,val_time)
   CASE val_note=="C1#"
      TONE(277,val_time)
   CASE val_note=="D1 "
      TONE(294,val_time)
   CASE val_note=="D1#"
      TONE(311,val_time)
   CASE val_note=="E1 "
      TONE(330,val_time)
   CASE val_note=="F1 "
      TONE(349,val_time)
   CASE val_note=="F1#"
      TONE(370,val_time)
   CASE val_note=="G1 "
      TONE(392,val_time)
   CASE val_note=="G1#"
      TONE(415,val_time)
   CASE val_note=="A1 "
      TONE(440,val_time)
   CASE val_note=="A1#"
      TONE(466,val_time)
   CASE val_note=="H1 "
      TONE(494,val_time)
   CASE val_note=="C2 "
      TONE(523,val_time)
   CASE val_note=="C2#"
      TONE(554,val_time)
   CASE val_note=="D2 "
      TONE(587,val_time)
   CASE val_note=="D2#"
      TONE(622,val_time)
   CASE val_note=="E2 "
      TONE(659,val_time)
   CASE val_note=="F2 "
      TONE(698,val_time)
   CASE val_note=="F2#"
      TONE(740,val_time)
   CASE val_note=="G2 "
      TONE(784,val_time)
   CASE val_note=="G2#"
      TONE(831,val_time)
   CASE val_note=="A2 "
      TONE(880,val_time)
   CASE val_note=="A2#"
      TONE(932,val_time)
   CASE val_note=="H2 "
      TONE(988,val_time)
   CASE val_note=="C3 "
      TONE(1047,val_time)
   CASE val_note=="C3#"
      TONE(1109,val_time)
   CASE val_note=="D3 "
      TONE(1175,val_time)
   CASE val_note=="D3#"
      TONE(1244,val_time)
   CASE val_note=="E3 "
      TONE(1318,val_time)
   CASE val_note=="F3 "
      TONE(1397,val_time)
   CASE val_note=="F3#"
      TONE(1480,val_time)
   CASE val_note=="G3 "
      TONE(1568,val_time)
   CASE val_note=="G3#"
      TONE(1661,val_time)
   CASE val_note=="A3 "
      TONE(1760,val_time)
   CASE val_note=="A3#"
      TONE(1865,val_time)
   CASE val_note=="H3 "
      TONE(1976,val_time)
   CASE val_note=="C4 "
      TONE(2094,val_time)
   CASE val_note=="C4#"
      TONE(2218,val_time)
   CASE val_note=="D4 "
      TONE(2350,val_time)
   CASE val_note=="D4#"
      TONE(2489,val_time)
   CASE val_note=="E4 "
      TONE(2637,val_time)
   CASE val_note=="F4 "
      TONE(2794,val_time)
   CASE val_note=="F4#"
      TONE(2960,val_time)
   CASE val_note=="G4 "
      TONE(3136,val_time)
   CASE val_note=="G4#"
      TONE(3322,val_time)
   CASE val_note=="A4 "
      TONE(3520,val_time)
   CASE val_note=="A4#"
      TONE(3730,val_time)
   CASE val_note=="H4 "
      TONE(3951,val_time)
   CASE val_note=="C4 "
      TONE(4187,val_time)
   CASE val_note=="P "
      INKEY(val_time/24)
   ENDCASE

   DoEvents()

RETURN Nil


#pragma BEGINDUMP

/*
   Author: Andi Jahja <harbour@cbn.net.id>

   TONE() for Windows to replace the ugly-heard GT Tone :-)
   Mono approach. Duration has been roughly estimated to be Cli**per-like,
   please refer to tests/sound.prg.
   Using Windows MMsystem, sound card is a must in order to make
   this function work.

   Syntax: TONE( nFreq, nDuration, [ lSmooth ], [ nVol ] ) -> NIL

   nFreq     = INTEGER, Tone frequency
   nDuration = NUMERIC, Duration Time, as in Cl**per
   lSmooth   = LOGICAL, pass .F. to disable sound smoothing, default is .T.
   nVol      = INTEGER, Sound Intensity/Volume, value 0 - 127, Default 127 ( Max )

*/

#include "hbapi.h"
#include <windows.h>
#include <mmsystem.h>
#include <math.h>

#ifndef __XHARBOUR__
   #define ISLOG( n )            HB_ISLOG( n )
   #define ISNUM( n )            HB_ISNUM( n )
#endif

#define SAMPLING_RATE 44100

void HB_EXPORT hb_winTone( UINT, double, BOOL, UINT );

HB_FUNC( TONE )
{
   if ISNUM( 1 )
   {
      hb_winTone( hb_parni( 1 ),
                ( ISNUM( 2 ) ? hb_parnd( 2 ) : 1.0 ) * 2100,
                  ISLOG( 3) ? hb_parl( 3 ) : TRUE,
                  ISNUM( 4 ) ? hb_parni( 4 ) : 127 );
   }
}

/* Keep it here for access from C programs */
void HB_EXPORT hb_winTone( UINT uFrequency, double dwDuration, BOOL bSmoothing, UINT uVolume )
{
   WAVEFORMATEX wfx;
   HWAVEOUT hWaveOut = NULL;

   wfx.wFormatTag = WAVE_FORMAT_PCM;
   wfx.nChannels = 1;
   wfx.nSamplesPerSec = SAMPLING_RATE;
   wfx.nAvgBytesPerSec = SAMPLING_RATE;
   wfx.nBlockAlign = 1;
   wfx.wBitsPerSample = 8;
   wfx.cbSize = 0;

   /*
   WAVE_MAPPER is the most commonly used device
   CallBack is unnecessary since we only play simple tone
   */
   if( waveOutOpen( &hWaveOut, WAVE_MAPPER, &wfx, NULL, NULL, CALLBACK_NULL ) == MMSYSERR_NOERROR )
   {
      char amp = uVolume;
      int i;
      unsigned char* buffer = (unsigned char*) hb_xgrab( (ULONG) dwDuration );
      double dKoef = uFrequency * 2 * 3.14159 / SAMPLING_RATE;
      WAVEHDR wh;

      if ( buffer )
      {
         wh.lpData = (LPSTR) buffer;
         wh.dwBufferLength = (DWORD) dwDuration;
         wh.dwFlags = WHDR_BEGINLOOP;
         wh.dwLoops = 1;

         if( waveOutPrepareHeader( hWaveOut, &wh, sizeof( wh ) ) == MMSYSERR_NOERROR )
         {
            wh.dwFlags = WHDR_BEGINLOOP | WHDR_ENDLOOP | WHDR_PREPARED;
            wh.dwLoops = 1;

            if ( bSmoothing )
            {
               /*
               Manipulating data to smooth sound from clicks at the start
               and end (particularly noted when we call TONE() many times
               in a row). This is a simulation of increasing volume gradually
               before it reaches the peak, and decreasing volume gradually
               before it reaches the end.
               */
               for( i = 0; i < dwDuration; i++ )
               {
                  if ( i < amp )
                  {
                     buffer[ i ] = (unsigned char) ( cos( i * dKoef ) * i + 127 );
                  }
                  else if ( dwDuration - i <= amp - 1  )
                  {
                     amp = max( 0, --amp );
                     buffer[ i ] = (unsigned char) ( cos( i * dKoef ) * amp + 127 );
                  }
                  else
                  {
                     buffer[ i ] = (unsigned char) ( cos( i * dKoef ) * amp + 127 );
                  }
               }
            }
            else
            {
               /*
               Raw sound, may cause annoying clicks when some tones are played
               in a row.
               */
               for( i = 0; i < (int) dwDuration; i++ )
               {
                  buffer[ i ] = (unsigned char) ( cos( i * dKoef ) * amp + 127 );
               }
            }

            /*
            Play the sound here
            */
            if ( waveOutWrite( hWaveOut, &wh, sizeof(WAVEHDR) ) == MMSYSERR_NOERROR )
            {
               /*
               Wait until the sound is finished
               */
               while (!(wh.dwFlags & WHDR_DONE))
               {
                  Sleep( 1 );
               }

               waveOutUnprepareHeader(hWaveOut, &wh, sizeof(WAVEHDR));
            }
         }

         hb_xfree( buffer );
      }
   }
}

#pragma ENDDUMP
