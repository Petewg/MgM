/*
 * HMG - Harbour Win32 GUI library Demo
 *
 * Copyright 2013 Dr. Claudio Soto <srvet@adinet.com.uy>
*/

#include "hmg.ch"

MEMVAR nWidth
MEMVAR nHeight
MEMVAR lStretch
MEMVAR lTransparent
MEMVAR lColor
MEMVAR aBackgroundColor
MEMVAR lAdjustImage
MEMVAR aPicture
MEMVAR i

Function Main

PRIVATE nWidth            := 200
PRIVATE nHeight           := 100
PRIVATE lStretch          := .F.
PRIVATE lTransparent      := .F. 
PRIVATE lColor            := .F.
PRIVATE aBackgroundColor  := NIL
PRIVATE lAdjustImage      := .F.
PRIVATE aPicture          := {"img.gif", "img.jpg", "img.wmf", "img.bmp", "img.png", "img.tif"}
PRIVATE i := 1

        DEFINE WINDOW Win_1 ;
               AT 0,0 ;
               WIDTH 800 HEIGHT 600 ;
               TITLE 'Load Image From DISK' ;
               MAIN
 
               DEFINE MAINMENU 
                        DEFINE POPUP "File"
				MENUITEM "Exit" ONCLICK ThisWindow.Release
                        END POPUP
                        DEFINE POPUP "Options"
                           MENUITEM "Stretch"             ONCLICK {lStretch     := ! lStretch,     Define_Image()} NAME Menu_Stretch
                           MENUITEM "Transparent"         ONCLICK {lTransparent := ! lTransparent, Define_Image()} NAME Menu_Transparent
                           MENUITEM "BackgroundColor RED" ONCLICK {lColor       := ! lColor,       Define_Image()} NAME Menu_Color
                           MENUITEM "AdjustImage"         ONCLICK {lAdjustImage := ! lAdjustImage, Define_Image()} NAME Menu_AdjustImage
                           SEPARATOR                           
                           MENUITEM "Width=200 and Height=100" ONCLICK {|| nWidth:=200, nHeight:=100, Define_Image(1)} NAME Menu_Size1
                           MENUITEM "Width=NIL and Height=NIL" ONCLICK {|| nWidth:=NIL, nHeight:=NIL, Define_Image(2)} NAME Menu_Size2
                           MENUITEM "Width=200 and Height=0"   ONCLICK {|| nWidth:=200, nHeight:=0,   Define_Image(3)} NAME Menu_Size3
                           MENUITEM "Width=0   and Height=100" ONCLICK {|| nWidth:=0,   nHeight:=100, Define_Image(4)} NAME Menu_Size4
                        END POPUP
                END MENU

                @ 10 ,10  BUTTON Button_1 CAPTION "Set GIF" ACTION {|| Win_1.Image_1.Picture := "img.gif", ImgSize(1)} WIDTH 100  HEIGHT 30
                @ 10 ,110 BUTTON Button_2 CAPTION "Set JPG" ACTION {|| Win_1.Image_1.Picture := "img.jpg", ImgSize(2)} WIDTH 100  HEIGHT 30
                @ 10 ,210 BUTTON Button_4 CAPTION "Set WMF" ACTION {|| Win_1.Image_1.Picture := "img.wmf", ImgSize(3)} WIDTH 100  HEIGHT 30
                @ 10 ,310 BUTTON Button_6 CAPTION "Set BMP" ACTION {|| Win_1.Image_1.Picture := "img.bmp", ImgSize(4)} WIDTH 100  HEIGHT 30
                @ 10 ,410 BUTTON Button_7 CAPTION "Set PNG" ACTION {|| Win_1.Image_1.Picture := "img.png", ImgSize(5)} WIDTH 100  HEIGHT 30 
                @ 10 ,510 BUTTON Button_8 CAPTION "Set TIF" ACTION {|| Win_1.Image_1.Picture := "img.tif", ImgSize(6)} WIDTH 100  HEIGHT 30

                @ 150, 140 LABEL Label_1 Value "" AUTOSIZE

                Define_Image (1)

        END WINDOW

        Win_1.Center
        ACTIVATE WINDOW Win_1

Return Nil


Procedure ImgSize (Index)
   Local n

   i := Index
   Win_1.Label_1.Value := "Width: "+hb_ntos(Win_1.Image_1.WIDTH)+"    Height: "+hb_ntos(Win_1.Image_1.HEIGHT)

   IF IsControlDefined (Frame_1, Win_1) == .T.
      Win_1.Frame_1.Release
   ENDIF
   n:= 2
   @ (Win_1.Image_1.ROW -n), (Win_1.Image_1.COL -n) FRAME Frame_1 OF Win_1;
      WIDTH  (Win_1.Image_1.WIDTH  +n+n);
      HEIGHT (Win_1.Image_1.HEIGHT +n+n);
      TRANSPARENT 

Return


Procedure Define_Image (nSize)

   Win_1.Menu_Stretch.Checked     := lStretch
   Win_1.Menu_Transparent.Checked := lTransparent
   Win_1.Menu_Color.Checked       := lColor
   Win_1.Menu_AdjustImage.Checked := lAdjustImage

   aBackgroundColor := IF (lColor, RED, NIL)

   IF VALTYPE (nSize) == "N"
      Win_1.Menu_Size1.Checked := .F.
      Win_1.Menu_Size2.Checked := .F.
      Win_1.Menu_Size3.Checked := .F.
      Win_1.Menu_Size4.Checked := .F.
       SetProperty ( "Win_1", "Menu_Size"+LTRIM(STR(nSize)), "Checked", .T. )
   ENDIF

   IF IsControlDefined (Image_1, Win_1) == .T.
      Win_1.Image_1.Release
   ENDIF

   DEFINE IMAGE Image_1
      PARENT            Win_1
      ROW               200
      COL               140
      WIDTH             nWidth
      HEIGHT            nHeight
      PICTURE           aPicture [ i ]
      STRETCH           lStretch
      TRANSPARENT       lTransparent 
      BACKGROUNDCOLOR   aBackgroundColor
      ADJUSTIMAGE       lAdjustImage
   END IMAGE

   IF IsControlDefined (Label_1, Win_1) == .T.
      ImgSize (i)
   ENDIF

Return
