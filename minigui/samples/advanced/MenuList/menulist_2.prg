/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * (c) 2011 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"

#define VerdeAgua       { 204 , 255 , 153 }
#define VerdeDuro  	{  51 , 153 , 255 }
#define VerdeSapo	{   0 , 102 ,   0 }

Static aImages, aImageBak, lChangeImage := .F.

Procedure Main
Local aCaptions := { "General Information", ;
                     "Configuration", ;
                     "Repair Of Tables", ;
                     "Exit..." }, ;
        i, cObject, nPos := 22

        aImages := { "Info.bmp","Estimate.bmp","Repair.bmp","Exit.bmp","Info2.bmp","Estimate2.bmp","Repair2.bmp","Exit2.bmp" }
	aImageBak := Array(2)

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 700 + iif(ISVISTAORLATER(), 0, GetBorderWidth()) ;
		HEIGHT 335 + GetTitleHeight() + iif(ISVISTAORLATER(), 0, GetBorderHeight()) ;
		TITLE "Menu List Demo" ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT Win_1.Image_0.Setfocus

		DEFINE IMAGE Image_0
			ROW    0
			COL    0
			WIDTH  700
			HEIGHT 335
			PICTURE 'Fondo.jpg'
		END IMAGE

		For i := 1 To Len(aCaptions)

			cObject := "Button_" + Str(i, 1)

			DEFINE BUTTONEX &cObject
				ROW  nPos
				COL  20
				WIDTH  314
				HEIGHT 72
				PICTURE aImages [i]
				CAPTION aCaptions [i]
				ACTION DoAction( Val(Right(this.name, 1)), GetProperty( "Win_1", this.name, "Caption" ) )
				VERTICAL .F.
				LEFTTEXT .F.
				FLAT .F.
				FONTNAME 'Tahoma'
				FONTSIZE  16
				FONTBOLD .T.
				FONTCOLOR VerdeAgua
				BACKCOLOR VerdeSapo
				UPPERTEXT .F.
				NOHOTLIGHT .F.
				NOXPSTYLE .T.
				HANDCURSOR .T.
				ONMOUSEHOVER ( SetProperty( "Win_1", this.name, "BackColor", VerdeDuro ), ;
					SetProperty( "Win_1", this.name, "FontColor", WHITE ), ChangeImage( this.name ) )
				ONMOUSELEAVE ( SetProperty( "Win_1", this.name, "BackColor", VerdeSapo ), ;
					SetProperty( "Win_1", this.name, "FontColor", VerdeAgua ), RestoreImage() )
			END BUTTONEX

			nPos += 73

		Next

	END WINDOW

	Center Window Win_1

	Activate Window Win_1

Return


Function DoAction( nMode, cAction )

	switch nMode

	case 1
		exit

	case 2
		exit

	case 3
		exit

	case 4
		thiswindow.release

	end switch

	if nMode < 4
		msginfo( cAction, 'Action ' + hb_ntos(nMode) )
	endif

	Win_1.Image_0.Setfocus

Return Nil


Procedure ChangeImage( cCtrl )
Local nImage := Val(Right(cCtrl, 1))

	if !lChangeImage
		aImageBak[1] := GetProperty( "Win_1", cCtrl, "Picture" )
		aImageBak[2] := cCtrl
		lChangeImage := .T.
	endif

	SetProperty( "Win_1", aImageBak[2], "Picture", aImages[nImage + 4] )

Return


Procedure RestoreImage
Local cName := aImageBak[1]
Local cCtrl := aImageBak[2]

	SetProperty( "Win_1", cCtrl, "Picture", cName )
	lChangeImage := .F.

Return
