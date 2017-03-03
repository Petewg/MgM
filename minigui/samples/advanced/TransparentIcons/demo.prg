/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2012 Sidorov Aleksandr, Verchenko Andrey <verchenkoag@gmail.com>
 * 
*/

#include "minigui.ch"

#define PROGRAM "The icons and the choice of theme color box"
#define VERSION ' 1.0'
#define COPYRIGHT ' 2012 Verchenko Andrey and Sidorov Aleksandr'

STATIC MyForm

MEMVAR aColors
MEMVAR Thems_color

Procedure Main
   Local aImages := {} , aThemesName := {}, aWinBackColor
   LOCAL aDimRadioGroup := {'One person','Two people','Three men','Many people'}
   LOCAL aDimRGView := { .F. , .F. , .F. , .F. }
   LOCAL aText := { "One person, one seat","Two people, two places","Three men, three places","A lot of people a lot of space" }
   LOCAL aIcons := { "ICO_ONE", "ICO_TWO", "ICO_THREE", "ICO_MANY" }
   Local cFileExe := SubStr( ExeName(), RAt( "\", ExeName() ) + 1 )
   Local nY, nX, nColor, nRadioGroup

   PUBLIC aColors:={} // Used for files: demo.prg and themes.prg
   PUBLIC Thems_color // for file themes.prg

   aadd(M->aColors,RGB(159, 191, 236)) ; aadd(aThemesName, "Office_2003 Blue"  ) ; aadd( aImages , 'BMP00' ) 
   aadd(M->aColors,RGB(234, 240, 207)) ; aadd(aThemesName, "Office_2003 Green" ) ; aadd( aImages , 'BMP03' ) 
   aadd(M->aColors,RGB(251, 230, 148)) ; aadd(aThemesName, "Office_2003 Orange") ; aadd( aImages , 'BMP00' ) 
   aadd(M->aColors,RGB(225, 226, 236)) ; aadd(aThemesName, "Office_2003 Silver") ; aadd( aImages , 'BMP03' ) 
   aadd(M->aColors,RGB(222, 218, 202)) ; aadd(aThemesName, "Azure"             ) ; aadd( aImages , 'BMP00' ) 
   aadd(M->aColors,RGB(89 , 135, 214)) ; aadd(aThemesName, "DarkBlue"          ) ; aadd( aImages , 'BMP03' ) 
   aadd(M->aColors,RGB(235, 245, 214)) ; aadd(aThemesName, "LightGreen"        ) ; aadd( aImages , 'BMP00' ) 
                                                                                   
     MyForm := "WIN_1" // Static variable showing an example of an object                                                     

     IF UPPER(cFileExe) == "DEMO1.EXE"
        nY := 20  ; nX := 144  ;  nColor := 1  ; nRadioGroup := 1
     ELSE
        nY := 20  ; nX := 644  ;  nColor := 3  ; nRadioGroup := 2
     ENDIF
                                                                              
     DEFINE WINDOW &MyForm AT nY, nX WIDTH 430 HEIGHT 400 ;
        ICON "ICO_AWIN" TITLE PROGRAM + VERSION ;
        BACKCOLOR RGB2DIM(M->aColors[nColor]) ;
        MAIN ;
        ON INIT OnInit( aText, aIcons, nColor, nRadioGroup )

     aWinBackColor := GetProperty(MyForm,"BackColor")
     Thems_color := aColors[nColor]

     DEFINE RADIOGROUP RadioGroup_1
            ROW    31
            COL    200
            WIDTH  250
            HEIGHT 50
            OPTIONS aDimRadioGroup 
	    READONLY aDimRGView 			
            VALUE 1
            FONTNAME 'Arial'
            FONTSIZE 12
            TOOLTIP ''
            ONCHANGE ChangeVersion(aText, aIcons )		
            BACKCOLOR aWinBackColor
     END RADIOGROUP  
                      
     DEFINE LABEL Label_1
            ROW    10
            COL    180
            WIDTH  260
            HEIGHT 24
            FONTSIZE 12
            FONTBOLD .T.
            VALUE "Your choice:"
            TRANSPARENT .T.
     END LABEL  	 
	 
     // The word "Ico_128x128" is reserved for the buttons. Only use it. See the file themes.prg
     DEFINE BUTTONEX Ico_128x128
            ROW    30
            COL    30
            WIDTH  128
            HEIGHT 128
            ICON "ICON_ONE"
            BACKCOLOR aWinBackColor
            VERTICAL .t.
     END BUTTONEX
	 
     DEFINE LABEL Label_3
            ROW    170
            COL    30
            WIDTH  340
            HEIGHT 50
            VALUE ""
            FONTNAME 'Arial'
            FONTSIZE 12
            FONTCOLOR RED 
            TRANSPARENT .T.
            FONTBOLD .T.
     END LABEL  

     DEFINE LABEL Label_2
            ROW    210
            COL    30
            WIDTH  220
            HEIGHT 26
            VALUE "Choosing a theme windows:"
            FONTSIZE 12
            FONTBOLD .T.
            TRANSPARENT .T.
     END LABEL  

     DEFINE COMBOBOXEX Combo_1 
       		ROW	229
       		COL	30
       		WIDTH	220 
       		HEIGHT	250 
       		ITEMS	aThemesName 
                FONTSIZE 12
                BACKCOLOR aWinBackColor
       		VALUE	1 
       		IMAGE	aImages
                TOOLTIP 'Choosing a theme'
                ONCHANGE ChangeThemes(This.Value,This.DisplayValue)
     END COMBOBOXEX
                                 
     // The word "Exit_Button" is reserved for the buttons. Only use it. See the file themes.prg
     DEFINE BUTTONEX Exit_Button 
            ROW    270
            COL    280
            WIDTH  120
            HEIGHT 60
            /*CAPTION "EXIT"*/
            ICON "ICO_EXIT"
            FONTNAME 'MS Sans serif'
            FONTSIZE 15 
            BACKCOLOR aWinBackColor
            TOOLTIP 'Exit program'
	    ON CLICK ReleaseAllWindows()
     END BUTTONEX  	 

      DEFINE STATUSBAR
         STATUSITEM COPYRIGHT 
         DATE
         CLOCK
      END STATUSBAR

     END WINDOW

     Activate Window &MyForm

Return
///////////////////////////////////////////////////////////
Function OnInit(aText, aIcons, nColor, nRadioGroup )
   SetProperty( MyForm, "RadioGroup_1", "Value", nRadioGroup ) 
   ChangeVersion( aText, aIcons )
   SetProperty( MyForm, "Combo_1", "Value", nColor )
Return Nil
///////////////////////////////////////////////////////////
Function ChangeVersion(aText, aIcons) 
   Local nI := GetProperty(MyForm,"RadioGroup_1", "Value")
   SetValue( aText[nI],aIcons[nI] )
Return Nil
///////////////////////////////////////////////////////////
Function SetValue(cDescription,cImage)
   SetProperty( MyForm, "Label_3"    , "Value", cDescription )   
   SetProperty( MyForm, "Ico_128x128", "Icon" , cImage )
Return Nil
///////////////////////////////////////////////////////////
Function ChangeThemes(nValue,cValue)
   LOCAL nColor := M->aColors[nValue], aSetColor := RGB2DIM(M->aColors[nValue])

   Thems_color := aColors[nValue]
   
   SetProperty( MyForm, "BackColor"   , aSetColor )   
   SetProperty( MyForm, "RadioGroup_1", "BackColor", aSetColor )   
   SetProperty( MyForm, "Ico_128x128" , "BackColor", aSetColor )   

   Domethod( MyForm, "RadioGroup_1", "Refresh" )
   Domethod( MyForm, "Label_1"     , "Refresh" )
   Domethod( MyForm, "Ico_128x128" , "Refresh" )
   Domethod( MyForm, "Label_3"     , "Refresh" )
   Domethod( MyForm, "Label_2"     , "Refresh" )
   Domethod( MyForm, "Exit_Button" , "Refresh" )

Return Nil
///////////////////////////////////////////////////////////
Static Function RGB2DIM(nColor)

Return { GetRed(nColor) , GetGreen(nColor) , GetBlue(nColor) }
///////////////////////////////////////////////////////////


