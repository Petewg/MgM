/*

	Media Player control demo.

	Author: Roberto Lopez

	Enhanced by Grigory Filatov

*/

#include "minigui.ch"

Function main()

	local w, h, aSize

	w := h := 100

	DEFINE WINDOW Media_Test ;
		WIDTH 420 ;
		HEIGHT 200 ;
		TITLE 'Media Player Test' ;
		MAIN 

		@ 50,10 PLAYER Player_1 ;
			WIDTH w ;
			HEIGHT h ;
			FILE "sample.avi" ;
			/*SHOWALL*/ NOPLAYBAR NOMENU

		aSize := GetAviFileSize( "sample.avi" )
		IF aSize[1] > 0
			Media_Test.Player_1.WIDTH := aSize[1]
			Media_Test.Player_1.HEIGHT := aSize[2]
		ENDIF

		@ 130,10 LABEL Label_1 VALUE 'SAMPLE.AVI'

		@ 0,0 BUTTON Button_D1 ;
			CAPTION "Play AVI" ;
			ACTION Media_Test.Player_1.Play() 

		@ 0,100 BUTTON Button_A1 ;
			CAPTION "Pause AVI" ;
			ACTION Media_Test.Player_1.Pause()

		@ 0,200 BUTTON Button_R1 ;
			CAPTION "Resume AVI" ;
			ACTION Media_Test.Player_1.Resume()

		@ 0,300 BUTTON Button_E1 ;
			CAPTION "End AVI" ;
			ACTION Media_Test.Player_1.Position := 1

	END WINDOW

	CENTER WINDOW Media_Test

	ACTIVATE WINDOW Media_Test 

Return Nil


*-------------------------------------------*
FUNCTION GetAviFileSize( cFile )
*-------------------------------------------*
   LOCAL cStr1, cStr2
   LOCAL nWidth, nHeight
   LOCAL nFileHandle

   cStr1 := cStr2 := Space( 4 )
   nWidth := nHeight := 0

   nFileHandle := FOpen( cFile )
   IF FError() == 0
      FRead( nFileHandle, @cStr1, 4 )

      IF cStr1 == "RIFF"
         FSeek( nFileHandle, 64, 0 )

         FRead( nFileHandle, @cStr1, 4 )
         FRead( nFileHandle, @cStr2, 4 )

         nWidth  := Bin2L( cStr1 )
         nHeight := Bin2L( cStr2 )
      ENDIF

      FClose( nFileHandle )
   ENDIF

RETURN { nWidth, nHeight }
