/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *  
 * Image and wave - Josef Planeta, Czech Republic                 *
 *               (planeta@iach.cz)                                *
 *                                                                *
*/

#include "minigui.ch"

#define HEAPPY  1
#define RUN     2
#define SIT     3
#define LIE     4
#define SLEEP   5

Static lPlay := .F.
Static lDrag := .F.
Static aAnim := {{2,3},{4,5,6,7},{8,9,10,11},{12,13},{14,15,16},{17,18},{19,20,21},{22,23},{24,25,26,27,28,29}}
Static xDog  := 500
Static yDog  := 120
Static xCur  := 0
Static yCur  := 0
Static Faze  := SLEEP
Static xOld  := 0
Static yOld  := 0
Static aMovX := {}
Static aMovY := {}
Static nMov  := 1
Static nDir  := 1
Static hMenu := 20
Static hToolBar  := 40
Static ColorMask := {192,192,192}
Static HotSpotX  := 0
Static HotSpotY  := 0

Memvar nImg
Memvar nCount
Memvar bPlayImage

Memvar Image_Row
Memvar Image_Col
Memvar Image_Index

Function Main

    Public nImg := 1
    Public nCount := 1
    Public bPlayImage := {|| Nil }

    Public	Image_Row := 0
    Public	Image_Col := 0
    Public	Image_Index := 0


	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI ImageList Demo (Based Upon a Contribution Of Janusz Pora)' ;
		ICON 'DOG.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 ;
		ON INIT initIL();
		ON SIZE RePaintImage();
		ON MOUSECLICK SetPlayImage(0);
		ON MOUSEDRAG DragImage();
		ON MOUSEMOVE StopDragImage();
		BACKCOLOR {192,192,64} 

		DEFINE IMAGELIST imagelst_1 ;
			BUTTONSIZE 35 , 35  ;
			IMAGE {'dog.bmp'} ;
			IMAGEMASK {'dogmask.bmp'} ;
			IMAGECOUNT 30 ;
			MASK

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour Power Ready!' 
		END STATUSBAR

		DEFINE MAIN MENU 
			POPUP '&Image'
				ITEM 'Masked ImageList '		ACTION CreateImageList(1,1)
				ITEM 'Color Masked ImageList '	ACTION CreateImageList(2,1)
    			SEPARATOR	
				ITEM 'Erase Image'		ACTION EraseImage(3)
		    	SEPARATOR	
				ITEM '&Exit'			ACTION Form_1.Release
			END POPUP
/*
			POPUP '&Animation'
				ITEM 'Heappy Dog'		ACTION SetPlayImage(4)
				ITEM 'Running Dog'		ACTION SetPlayImage(3)
				ITEM 'Sitdown Dog'		ACTION SetPlayImage(5)
				ITEM 'Lying Dog'		ACTION SetPlayImage(6)
				ITEM 'Sleeping Dog'		ACTION SetPlayImage(9)
			END POPUP
*/
			POPUP '&Help'
				ITEM '&About'			ACTION MsgInfo ("MiniGUI ImageList demo") 
			END POPUP
		END MENU
 
		DEFINE SPLITBOX 

			DEFINE TOOLBAR ToolBar_a BUTTONSIZE 85,35 SIZE 8  FLAT RIGHTTEXT

				BUTTON Button_1a ;
					CAPTION '&Run' ;
					PICTURE 'm5.bmp' ;
					TOOLTIP 'Running Dog';
					ACTION ImageAnimat(3)

				BUTTON Button_2a ;
					CAPTION '&Sit' ;
					PICTURE 'm20.bmp' ;
					TOOLTIP 'Sitdown Dog';
					ACTION ImageAnimat(5)
					
				BUTTON Button_3a ;
					CAPTION '&Heappy' ;
					PICTURE 'm3.bmp' ;
					TOOLTIP 'Heaping Dog';
					ACTION ImageAnimat(4)

				BUTTON Button_4a ;
					CAPTION '&Lie' ;
					PICTURE 'm22.bmp' ;
					TOOLTIP 'Lying Dog';
					ACTION ImageAnimat(6)

				BUTTON Button_5a ;
					CAPTION '&Sleep' ;
					PICTURE 'm29.bmp' ;
					TOOLTIP 'Sleeping Dog';
					ACTION ImageAnimat(9)

			END TOOLBAR
	
		END SPLITBOX

		@ 150 ,200   IMAGE image_1 ; 
			PICTURE 'dog.gif' ;
			WIDTH 100 HEIGHT 100 ;
			STRETCH TRANSPARENT BACKGROUNDCOLOR {192,192,64}

		@ 200,40 LABEL label_1;
			VALUE 'Click here!'+CRLF+'or drag Dog.';
			ACTION SetPlayImage(0);
			HEIGHT 40; 
			TRANSPARENT 
         
		DEFINE TIMER Timer_1 ;
			INTERVAL 70 ;
			ACTION TimerPlayImage()

		Form_1.Timer_1.Enabled := .F.

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Function initIL()
    DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog , xDog IMAGEINDEX 28

    Image_Row := yDog
    Image_Col := xDog
    Image_Index := 28

Return Nil


Function TimerPlayImage()
    Eval(bPlayImage,nImg)
Return Nil


Function SetPlayImage(typ)
    HB_SYMBOL_UNUSED(typ)

    if MoveDat()
        ERASE IMAGE imagelst_1 OF Form_1 AT yDog , xDog

        HotSpotX = _HMG_MouseCol - Image_Col 
        HotSpotY = _HMG_MouseRow - Image_Row 

        BEGINDRAG IMAGE imagelst_1 OF Form_1 AT _HMG_MouseRow - HotSpotY, _HMG_MouseCol - HotSpotX ;
            IMAGEINDEX Image_Index

        ENTERDRAG IMAGE AT _HMG_MouseRow - HotSpotY, _HMG_MouseCol - HotSpotX
        lDrag :=.t.
    else
        bPlayImage := {|| MoveImage()}
        Form_1.Timer_1.Enabled := .t.
    endif

Return Nil


Function ImageAnimat(typ)
    bPlayImage := {|| animation(typ)}
    if typ < 5
        nCount := 4
    else
        nCount := 1
    endif
    
    Form_1.Timer_1.Enabled := .t.
Return Nil


Function SetColor_IL()
    _ImageListSetBkColor( 'imagelst_1', 'Form_1' , ColorMask)
Return Nil


Function CreateImageList(typ)
    if typ == 2
        ColorMask := GetColor (ColorMask )
	If ColorMask[1] == Nil
		ColorMask := {192,192,192}
		MsgInfo("Color no selected!")
		Return nil
	endif
    endif

    if _IsControlDefined ('imagelst_1', 'Form_1') 
        RELEASE IMAGELIST imagelst_1 OF Form_1 
        RELEASE CONTROL imagelst_1 OF Form_1 
    endif

    if typ ==1
        DEFINE IMAGELIST imagelst_1 ;
            OF Form_1 ;
            BUTTONSIZE 35 , 35  ;
            IMAGE {'dog.bmp'} ;
            IMAGEMASK {'dogmask.bmp'} ;
            IMAGECOUNT 30 ;
		MASK
    else
        DEFINE IMAGELIST imagelst_1 ;
            OF Form_1 ;
            BUTTONSIZE 35 , 35  ;
            IMAGE {'dog.bmp'} ;
            COLORMASK ColorMask ;
            IMAGECOUNT 30 ;
		MASK
    endif
Return nil


Function DelImage(ImgIndex)
	DELETE IMAGE ImgIndex FROM imagelst_1 OF Form_1
Return nil


Function animation(typ)
    Local pos , aTab

    aTab := aAnim[typ]
    if nImg <= len(aTab)
        pos:= aTab[nImg]
        ERASE IMAGE imagelst_1 OF Form_1 AT yDog , xDog
        DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog , xDog IMAGEINDEX pos
        Image_Index := pos
        nImg ++
    else
        nCount--
        nImg := 1
        if nCount <= 0
             Form_1.Timer_1.Enabled := .f.
        endif
    endif
Return Nil


Function EraseImage()
	ERASE IMAGE imagelst_1 OF Form_1 AT yDog , xDog
Return Nil

Function MoveImage()
    Local pos , aTab

    xOld := xDog
    yOld := yDog
    aTab := aAnim[if(nDir==1,2,3)]
    if nMov <= len(aMovX) .and. nMov > 0
      xDog := aMovX[nMov]
      yDog := aMovY[nMov]
    endif

    ERASE IMAGE imagelst_1 OF Form_1 AT yOld , xOld
    if nImg <= len(aTab)
        pos:= aTab[nImg]
        DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog , xDog IMAGEINDEX pos
	    Image_Row := yDog
	    Image_Col := xDog
	    Image_Index := pos
        nImg ++
    else
        DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog , xDog IMAGEINDEX Image_Index
        nCount--
        nImg := 1
    endif
    nMov++
    if nMov > len(aMovX)
        Form_1.Timer_1.Enabled := .f.
        PLAY WAVE 'dog.wav'
        nMov := 1
        nImg := 1
        ImageAnimat(if(nDir==1,1,4))
    endif
Return Nil


Function MoveDat()
    Local dx, dy, nA, n, InDog:=.f.
   
    yCur:= _HMG_MouseRow
    xCur:= _HMG_MouseCol
    if yCur >= yDog .and. yCur <= yDog+35 .and. xCur >=xDog .and. xCur <= xDog+35
        InDog:=.t.
    else
        nDir := if(xCur > xDog, 1 , -1 )
        nA := int((xCur - xDog)* nDir / 5)
        dx := (xCur - xDog)* nDir / na
        dy:=  (yCur - yDog)/na
        aMovX :=Array(nA)
        aMovY :=Array(nA)
        for n:=1 to nA
            aMovX[n] := xDog + dx*n*nDir
            aMovY[n] := yDog + dy*n
        next
        nMov:=1
    endif
Return InDog


Function DragImage()
        MOVE IMAGE AT _HMG_MouseRow - HotSpotY ,_HMG_MouseCol - HotSpotX

        if lDrag
            xDog := _HMG_MouseCol
            yDog := _HMG_MouseRow
        endif
Return Nil


Function StopDragImage()
    IF lDrag ==.T.
        ENDDRAG IMAGE
        RePaintImage()
        lDrag :=.F.
    ENDIF
Return Nil


Function RePaintImage()
	DRAW IMAGELIST imagelst_1 OF Form_1 AT yDog , xDog IMAGEINDEX Image_Index
Return Nil
