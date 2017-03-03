/*
* MiniGUI DLL Demo
*/

#include "minigui.ch"
#include "hbdyn.ch"

PROCEDURE Main()

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
      ON RELEASE HMG_UnloadAllDll()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Play Sound' ACTION PlaySound()
			END POPUP
		END MENU
      
      @ 060, 150 BUTTON btn_0 CAPTION "Play pacman sound" WIDTH 120 HEIGHT 24 ACTION PlaySound("pacman_begins.wav")
      @ 100, 150 BUTTON btn_1 CAPTION "Play sample sound" WIDTH 120 HEIGHT 24 ACTION PlaySound("sample.wav")
      @ 140, 100 BUTTON btn_2 CAPTION "Have Internet?" ACTION MsgInfo( Iif( CheckInternet(), "Yes!", "No!" ), "Have Internet?" )
      @ 140, 200 BUTTON btn_2_1 CAPTION "What Internet?" ACTION CheckInternet(.T.)
      @ 180, 150 BUTTON btn_3 CAPTION "Quit.." ACTION Thiswindow.Release()
	END WINDOW

   CENTER WINDOW Win_1
   
	ACTIVATE WINDOW Win_1

   RETURN


PROCEDURE PlaySound( cWavFile )

   hb_Default( @cWavFile, "sample.wav" )
	// the number of waveform-audio output devices present in the system
   IF CallDll32 ( "waveOutGetNumDevs", "WINMM.DLL" ) > 0

      CallDll32 ( "sndPlaySoundA","WINMM.DLL", cWavFile, 0 )

	ENDIF

   RETURN


FUNCTION CheckInternet( lShowType )

   LOCAL lpdwFlags := 0x0000000000000000
   LOCAL lpszConnectionName := Space( 256 )
   LOCAL dwNameLen := Len( lpszConnectionName )
   LOCAL dwReserved := 0
   LOCAL lConnected
   
   hb_Default( @lShowType, .F. )
   
   lConnected := CallDLL32( "InternetGetConnectedStateEx", ;
                            "WININET.DLL", ;
                            @lpdwFlags, ;
                            @lpszConnectionName, ;
                            dwNameLen, ;
                            dwReserved ) > 0
   IF lShowType
      IF lConnected
         MsgInfo(  "Internet connection type: " + hb_EoL() + lpszConnectionName,  "WININET.DLL" )
      ELSE
         MsgInfo(  "No active internet connection.", "WININET.DLL" )
      ENDIF
   ENDIF
   RETURN lConnected

/*
INTERNET_CONNECTION_RAS_INSTALLED 0x10 Remote Access Service (RAS) is installed
INTERNET_CONNECTION_CONFIGURED    0x40 Local system has a valid connection to the Internet, but it might or might not be currently connected.
INTERNET_CONNECTION_LAN           0x02 Local system uses a local area network to connect to the Internet.
INTERNET_CONNECTION_MODEM         0x01 Local system uses a modem to connect to the Internet.
INTERNET_CONNECTION_OFFLINE       0x20 Local system is in offline mode.
INTERNET_CONNECTION_PROXY         0x04 Local system uses a proxy server to connect to the Internet.
*/