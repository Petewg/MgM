/*
 * Author: P.Chornyj <myorg63@mail.ru>
*/

#include "minigui.ch"

#define c1Tab CHR(9)
#define NTrim( n ) LTRIM( STR( n, IF( n == INT( n ), 0, 2 ) ) )

Memvar aPictures, aImageInfo
Memvar TotalFrames, CurrentFrame

Function main()
Local picture
Local aPictInfo := {}
Public aPictures := {}, aImageInfo := {}
Public TotalFrames, CurrentFrame

        picture := Getfile ( { {'Gif Files', '*.gif'} }, 'Open a File' , GetCurrentFolder(), .f. , .t. )

	IF Empty( picture )
		picture := 'ani-free.gif'
		LoadGif( picture, @aPictInfo, @aPictures, @aImageInfo )
	ELSE
		IF !LoadGif( picture, @aPictInfo, @aPictures, @aImageInfo )
			QUIT
		ENDIF
	ENDIF

	TotalFrames := Len( aPictures )
	CurrentFrame := 1

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 320 HEIGHT 240 ;
		TITLE 'Gif89 Demo' ;
		MAIN NOMAXIMIZE NOSIZE;
		ON INTERACTIVECLOSE OnClose()

		DEFINE MAIN MENU

			DEFINE POPUP "&File" 

				MENUITEM '&Play' ACTION IIF( TotalFrames > 1, Form_Main.Timer_1.Enabled := .T., )
				MENUITEM '&Stop' ACTION IIF( TotalFrames > 1, Form_Main.Timer_1.Enabled := .F., )
				SEPARATOR
				MENUITEM "E&xit" ACTION OnClose()

			END POPUP

			DEFINE POPUP "&?" 

				MENUITEM "GIF &Info" ACTION IIF( TotalFrames > 1, ;
					( Form_Main.Timer_1.Enabled := .F., MsgMulty( { ;
					"Picture name" + c1Tab + ": " + cFileNoPath( picture ), ;
					"Gif Version"  + c1Tab + ": " + aPictInfo [1], ; 
					"Image Width"  + c1Tab + ": " + NTrim( aPictInfo [2] ), ;
					"Image Height" + c1Tab + ": " + NTrim( aPictInfo [3] ), ;
					"Total Frames" + c1Tab + ": " + NTrim( TotalFrames ), ;
					"CurrentFrame" + c1Tab + ": " + NTrim( CurrentFrame ) }, ;
					"GIF Info" ), Form_Main.Timer_1.Enabled := .T. ), )

			END POPUP

		END MENU

                @ 20, 20 IMAGE Image_1 PICTURE picture ;
                        WIDTH aPictInfo [2] ;
                        HEIGHT aPictInfo [3] ;
                        WHITEBACKGROUND TRANSPARENT

	END WINDOW

	IF TotalFrames > 1

		DEFINE TIMER Timer_1 OF Form_Main INTERVAL GetFrameDelay( aImageInfo [CurrentFrame] ) ;
	                ACTION PlayGif()

		Form_Main.Image_1.Picture := aPictures [CurrentFrame]
		Form_Main.Timer_1.Enabled := .T.
		Form_Main.Width := Max( 180, aPictInfo [2] + 2 * GetBorderWidth() + 40 )
		Form_Main.Height := GetTitleHeight() + aPictInfo [3] + 2 * GetBorderHeight() + 60
		Form_Main.Image_1.Col := ( Form_Main.Width - aPictInfo [2] - 2 * GetBorderWidth() ) / 2 + 1

		DRAW PANEL IN WINDOW Form_Main ;
			AT Form_Main.Image_1.Row - 2, Form_Main.Image_1.Col - 4 ;
			TO Form_Main.Image_1.Row + aPictInfo [3] + 2, Form_Main.Image_1.Col + aPictInfo [2] + 4
	ENDIF

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

Return Nil

/*
*/
Function PlayGif()

	IF CurrentFrame < TotalFrames
		CurrentFrame ++
	ELSE
		CurrentFrame := 1
	ENDIF

	Form_Main.Image_1.Picture := aPictures [CurrentFrame]
	Form_Main.Timer_1.Value := GetFrameDelay( aImageInfo [CurrentFrame] )

	Form_Main.Image_1.Refresh

Return Nil

/*
*/
Function OnClose()

	AEVal( aPictures, {|f| FErase( f ) } )

	IF TotalFrames > 1
		Form_Main.Timer_1.Release
	ENDIF

	Form_Main.Release

Return Nil

/*
*/
#include "h_Gif89.prg"
#include "MsM.prg"
