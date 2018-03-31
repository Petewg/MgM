#include <hmg.ch>
#include "DrawBorder.ch"

PROCEDURE MAIN()

   LOAD WINDOW TestBorder AS frmTestBorder

   ON KEY ESCAPE OF frmTestBorder ACTION ThisWindow.Release

   frmTestBorder.Center
   frmTestBorder.Activate

RETURN  // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE Draw_All()

	DRAW BORDER WINDOW "frmTestBorder" CONTROL "Label_1" 
	DRAW BORDER WINDOW "frmTestBorder" CONTROL "Label_2" PENWIDTH 3 UPCOLOR 1 DOWNCOLOR 0
	DRAW BORDER WINDOW "frmTestBorder" CONTROL "Label_3" PENWIDTH 3 UPCOLOR 0 DOWNCOLOR 1
	DRAW BORDER WINDOW "frmTestBorder" CONTROL "Label_4" PENWIDTH 3 UPCOLOR { 190, 210, 230 } DOWNCOLOR { 100, 149, 237 } 

	DRAW BORDER WINDOW "frmTestBorder" CONTROL "Button_1" 
	DRAW BORDER WINDOW "frmTestBorder" CONTROL "Button_2" PENWIDTH 3 UPCOLOR 1 DOWNCOLOR 0
	DRAW BORDER WINDOW "frmTestBorder" CONTROL "Button_3" PENWIDTH 3 UPCOLOR 0 DOWNCOLOR 1

	DrawWideBorder( "frmTestBorder", "Image_1", { 164, 260, 155 } ) 

RETURN  // Draw_All()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE DrawWideBorder( ;
			 cWindowName,;
			 cControlName,;
			 aColor,;
			 nSpace,; 
			 nStep )

   LOCAL nWidness, aCurColor

   HB_DEFAULT( @nSpace, 10 )
   HB_DEFAULT( @nStep, 1 )

   FOR nWidness := 1 TO nSpace STEP nStep

      aCurColor := ACLONE( aColor )

      DRAW BORDER WINDOW cWindowName CONTROL cControlName UPCOLOR aCurColor DOWNCOLOR aCurColor SPACE nWidness

      aColor[ 1 ]  -= 10
      aColor[ 2 ]  -= 10
      aColor[ 3 ]  += 10

    NEXT nWidness 

RETURN  // DrawWideBorder()
