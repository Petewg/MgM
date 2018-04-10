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

Static aImages, aImageBak, lChangeImage := .f.

Procedure Main
Local aCaptions := { "General Information", ;
                     "Configuration", ;
                     "Repair Of Tables", ;
                     "Exit..." }, ;
        i, cImage, cLabel, nPos := 22

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
		ON GOTFOCUS ( EraseWindow("Win_1"), DrawBorder() ) ;
		ON INIT DrawBorder() ;
		FONT 'Tahoma' SIZE 16

		DEFINE IMAGE Image_0
			ROW    0
			COL    0
			WIDTH  700
			HEIGHT 335
			PICTURE 'Fondo.jpg'
		END IMAGE

		For i := 1 To Len(aCaptions)

			cLabel := "Label_" + Str(i, 1)
			@ nPos, 20 LABEL &cLabel ;
				VALUE "" ;
				WIDTH 64 ;
				HEIGHT 72 ;
				BACKCOLOR VerdeSapo ;
				ACTION DoAction( Val(Right(this.name, 1)) ) ;
				ON MOUSEHOVER ( SetProperty( "Win_1", "Button_" + Right(this.name, 1), "BackColor", VerdeDuro ), ;
					SetProperty( "Win_1", "Label_" + Right(this.name, 1), "BackColor", VerdeDuro ), ;
					SetProperty( "Win_1", "Button_" + Right(this.name, 1), "FontColor", WHITE ), ChangeImage(Val(Right(this.name, 1))) ) ;
				ON MOUSELEAVE ( SetProperty( "Win_1", "Button_" + Right(this.name, 1), "BackColor", VerdeSapo ), ;
					SetProperty( "Win_1", "Label_" + Right(this.name, 1), "BackColor", VerdeSapo ), ;
					SetProperty( "Win_1", "Button_" + Right(this.name, 1), "FontColor", VerdeAgua ), RestoreImage() )

			cImage := "Image_" + Str(i, 1)
			@ nPos + 4, 20 IMAGE &cImage ;
				PICTURE aImages[i] ;
				WIDTH 64 ;
				HEIGHT 64

			cLabel := "Button_" + Str(i, 1)
			@ nPos, 84 LABEL &cLabel ;
				VALUE CRLF + aCaptions[i] ;
				WIDTH 250 ;
				HEIGHT 72 ;
				CENTERALIGN ;
				BACKCOLOR VerdeSapo ;
				FONTCOLOR VerdeAgua ;
				BOLD ;
				ACTION DoAction( Val(Right(this.name, 1)) ) ;
				ON MOUSEHOVER ( SetProperty( "Win_1", this.name, "BackColor", VerdeDuro ), ;
					SetProperty( "Win_1", "Label_" + Right(this.name, 1), "BackColor", VerdeDuro ), ;
					SetProperty( "Win_1", this.name, "FontColor", WHITE ), ChangeImage(Val(Right(this.name, 1))) ) ;
				ON MOUSELEAVE ( SetProperty( "Win_1", this.name, "BackColor", VerdeSapo ), ;
					SetProperty( "Win_1", "Label_" + Right(this.name, 1), "BackColor", VerdeSapo ), ;
					SetProperty( "Win_1", this.name, "FontColor", VerdeAgua ), RestoreImage() )

			nPos += 72

		Next

	END WINDOW

	Center Window Win_1

	Activate Window Win_1

Return


function DoAction( nMode )

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
		msginfo( 'Action ' + hb_ntos(nMode) )
	endif

return nil


Procedure ChangeImage( nImage )
Local cImage := "Image_" + Str(nImage, 1)

	if !lChangeImage
		aImageBak[1] := GetProperty( "Win_1", cImage, "Picture" )
		aImageBak[2] := cImage
		lChangeImage := .t.
	endif

	SetProperty( "Win_1", aImageBak[2], "Picture", aImages[nImage + 4] )

Return


Procedure RestoreImage
Local cImageName := aImageBak[1]
Local cImageCtrl := aImageBak[2]

	SetProperty( "Win_1", cImageCtrl, "Picture", cImageName )
	lChangeImage := .f.

Return


Procedure DrawBorder
Local nPos := 22

	DRAW RECTANGLE				;
		IN WINDOW Win_1			;
		AT nPos-2, 18			;
		TO nPos+72*4+1, 20+64+250+2	;
		PENCOLOR WHITE

Return
