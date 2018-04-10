/*
* MiniGUI DLL Demo
*/

#include "minigui.ch"
#include "hbdyn.ch"

Procedure Main

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN ;
		ON RELEASE UnloadAllDll()

		DEFINE MAIN MENU
			DEFINE POPUP 'Test'
				MENUITEM 'Play Sound' ACTION PlaySound ()
			END POPUP
		END MENU

	END WINDOW

	ACTIVATE WINDOW Win_1

Return


Procedure PlaySound

	// the number of waveform-audio output devices present in the system
	If HMG_CallDLL ( "WINMM.DLL" , HB_DYN_CTYPE_INT , "waveOutGetNumDevs" ) > 0

		HMG_CallDLL ( "WINMM.DLL" , , "sndPlaySoundA" , "sample.wav" , 0 )

	EndIf

Return
