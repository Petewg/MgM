/*
 * Author: P.Chornyj <myorg63@mail.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define c1Tab CHR(9)
#define NTrim( n ) LTRIM( STR( n, IF( n == INT( n ), 0, 2 ) ) )

#define BM_WIDTH     1
#define BM_HEIGHT    2
#define	BM_BITSPIXEL 3

#define IMAGE_FILES_GROUP '*.bmp;*.png;*.jpg;*.gif;*.tif'


Function main()
	Local picture := 'Demo', aPictInfo

        aPictInfo := BmpSize( picture )
 
	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 320 HEIGHT 240 ;
		TITLE 'Get Bitmap Size Demo' ;
		MAIN ;
		NOMAXIMIZE 

		DEFINE MAIN MENU

			DEFINE POPUP "&File" 

				MENUITEM '&Open' ;
					ACTION ( picture := GetFile( { {'Image Files', IMAGE_FILES_GROUP } },'Open a File',GetCurrentFolder(),.f.,.t. ),;
						aPictInfo := BmpSize( picture ), ;
						Form_Main.Image_1.Picture := picture , AdJustWin( aPictInfo ) )
						
				SEPARATOR
				MENUITEM "E&xit" ACTION ThisWindow.Release

			END POPUP

			DEFINE POPUP "&?" 

				MENUITEM "Bitmap &Info" ACTION MsgMulty( { ;
					"Picture name" + c1Tab + ": " + cFileNoPath( picture ), ;
					"Image Width"  + c1Tab + ": " + NTrim( aPictInfo [BM_WIDTH] ), ;
					"Image Height" + c1Tab + ": " + NTrim( aPictInfo [BM_HEIGHT] ), ;
					"BitsPerPixel" + c1Tab + ": " + NTrim( aPictInfo [BM_BITSPIXEL] ) }, ;
					"BMP Info" )

			END POPUP

		END MENU

                @ 0, 0 IMAGE Image_1 PICTURE picture ADJUST 

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

Return Nil

STATIC FUNC AdJustWin( aPictInfo )

IF Form_Main.Width < aPictInfo [BM_WIDTH] 
	Form_Main.Width := aPictInfo [BM_WIDTH] + 20
ENDIF
	
IF Form_Main.Height < aPictInfo [BM_HEIGHT]
	Form_Main.Height := aPictInfo [BM_HEIGHT] + 50 
ENDIF
RETURN NIL






/* ------------------------------------------------------------ */
#include "MsM.prg"
