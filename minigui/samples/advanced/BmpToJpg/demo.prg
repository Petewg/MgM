/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * DIjpg.dll is public domain DLL
 *
 * Copyright 2007 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*
Local nQ := 80, nP := 1

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 350 ;
      TITLE 'BMP To JPG sample by Grigory Filatov' ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      ON RELEASE Ferase( "demo.jpg" )

	ON KEY F2 ACTION {|| SaveToJPG()}

	DEFINE BUTTON Button_1
		ROW	25
		COL	295
		CAPTION 'Press Me'
		ACTION ( SaveToJPG( nQ, nP ), SetProperty( "Form_1", "Image_2", "Picture", "demo.jpg" ) )
		WIDTH 90 
		HEIGHT 26
		DEFAULT .T.
		TOOLTIP 'Save to JPG'
	END BUTTON

	DEFINE BUTTON Button_2
		ROW	55
		COL	295
		CAPTION 'Cancel'
		ACTION ThisWindow.Release
		WIDTH 90 
		HEIGHT 26
		TOOLTIP 'Exit'
	END BUTTON

	DEFINE LABEL Label_1
		ROW	5
		COL	10
		WIDTH	130
		VALUE 'Source:'
		CENTERALIGN .T.
	END LABEL

	@ 25,5 FRAME Frame_1 WIDTH 130 HEIGHT 130 

	DEFINE IMAGE Image_1
		ROW	30
		COL	10
		HEIGHT	120
		WIDTH	120
		PICTURE	'demo.bmp'
		STRETCH	.F.
	END IMAGE

	DEFINE LABEL Label_2
		ROW	5
		COL	150
		WIDTH	130
		VALUE 'Destination:'
		CENTERALIGN .T.
	END LABEL

	@ 25,150 FRAME Frame_2 WIDTH 130 HEIGHT 130 

	DEFINE IMAGE Image_2
		ROW	30
		COL	155
		HEIGHT	120
		WIDTH	120
		PICTURE	'demo.ipg'
		STRETCH	.F.
	END IMAGE

	@ 170,5 FRAME Frame_3 CAPTION "JPEG:" WIDTH 380 HEIGHT 140

	DEFINE LABEL Label_3
		ROW	225
		COL	20
		WIDTH	100
		VALUE 'Save quality:'
	END LABEL

	DEFINE LABEL Label_4
		ROW	190
		COL	120
		WIDTH	50
		VALUE 'lowest'
	END LABEL

	DEFINE LABEL Label_5
		ROW	190
		COL	320
		WIDTH	40
		VALUE 'best'
		RIGHTALIGN .T.
	END LABEL

	DEFINE LABEL Label_6
		ROW	190
		COL	240
		WIDTH	40
		VALUE Ltrim(Str(nQ))
	END LABEL

	DEFINE SLIDER Slider_1
		ROW	220
		COL	110
		VALUE	nQ
		WIDTH	260
		HEIGHT	30
		RANGEMIN 0
		RANGEMAX 100
		NOTICKS .T.
		BOTH .T.
		ON SCROLL ( nQ := Form_1.Slider_1.Value, Form_1.Label_6.Value := Ltrim(Str(nQ)) )
		ON CHANGE ( nQ := Form_1.Slider_1.Value, Form_1.Label_6.Value := Ltrim(Str(nQ)), Form_1.Button_1.OnClick )
	END SLIDER

	DEFINE CHECKBOX Check_1
		ROW	270
		COL	20
		CAPTION 'Save as &progressive JPG' 
		WIDTH	160
		VALUE ( nP == 1 )
		ON CHANGE nP := IFEMPTY(Form_1.Check_1.Value, 0, 1)
	END CHECKBOX

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return

*-----------------------------------------------------------------------------*
Function SaveToJPG( nQuality, nProgressive )
*-----------------------------------------------------------------------------*
Local nResult
LOCAL cBmp := cFilePath( GetExeFileName() ) + "\tmp.bmp"
LOCAL cJpg := cFilePath( GetExeFileName() ) + "\demo.jpg"

	DEFAULT nQuality := 80, nProgressive := 1
   
	Form_1.Image_1.SaveAs( cBmp )				// Create temporary file which reguired for DIjpg.dll
   
   MSGDEBUG( cbmp, cjpg )

	// nResult := BmpToJpg( cJpg, nQuality, nProgressive )	// Save to JPEG
   // nResult := CallDLL32( "DIJPG.DLL", DLL_TYPE_LONG, "DIWriteJpg", cJpg, nQuality, nProgressive ) // HMG FUNC
   nResult := CallDll32( "DIWriteJpg", "DIJPG.DLL", cJpg, nQuality, nProgressive )  // HARBOUR FUNC
	If nResult # 1						// An error occured
		MsgStop( "BmpToJpg did not succeed!", "Error" )
	EndIf

	Ferase( cBmp )						// Remove temporary file

Return nResult

*-----------------------------------------------------------------------------*

//DECLARE DLL_TYPE_LONG DIWriteJpg(DLL_TYPE_LPCSTR DestPath, DLL_TYPE_LONG quality, DLL_TYPE_LONG progressive) ;
	// IN DIJPG.DLL ALIAS BMPTOJPG

*-----------------------------------------------------------------------------*

// DECLARE DLL_TYPE_LONG DIWriteJpg( DestPath, quality, progressive ) IN DIJPG.DLL ALIAS BMPTOJPG