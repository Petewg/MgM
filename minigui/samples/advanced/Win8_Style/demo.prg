/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2002-07 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Show examples test Metro interface colors
 * Copyright 2013 Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "minigui.ch"
#include "metrocolor.ch"
                                             
#define PROGRAM 'ButtonEx with METRO color background (1)'
#define COPYRIGHT ' (c) 2013 Andrey Verchenko, Russia, Dmitrov. ' + MiniGUIVersion()

STATIC aObjButton := {},  aObjImage := {}, lStatusBar := .T.

Function Main()
     LOCAL cResIco, cResPict := NIL, bAction, cTooltip, nWidth, nHeight
     LOCAL nStRow1 := 60, nStRow2 := 188, nStRow3 := 317, nStRow4 := 447
     LOCAL aFontColor := WHITE

	DEFINE WINDOW Form_1 ;
		AT 0,0 WIDTH 870 HEIGHT 650 ;
		MINWIDTH 870 MINHEIGHT 650  ;
                MAIN ;
                ICON "1MAIN" ;
		TITLE PROGRAM  ;
	        ON SIZE { || MyRefresh() } ;
        	ON MAXIMIZE { || MyRefresh() } ;
                ON INTERACTIVECLOSE { || MyExit() } ;
	        BACKCOLOR COLOR_DESKTOP_DARK_YELLOW 

                MyPopup()

  	        nWidth  := Form_1.Width
	        nHeight := Form_1.Height

		@ 20,30 LABEL label_1 VALUE "Start" WIDTH 120 HEIGHT 28 SIZE 18 FONTCOLOR WHITE BOLD TRANSPARENT 

                // the first row of tiles 
                cResIco  := NIL  ; cResPict := "bMail"
                bAction  := 'MsgInfo("PRESS OButton_1x1 BUTTONEX")'
                cTooltip := "OButton_1x1 BUTTONEX with icon"
                METRO_BUTTON("OButton_1x1",nStRow1,50,247,120,"Mail",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_DARK_BLUE,bAction,cTooltip)
        
                cResIco  := NIL 
                cResPict := "bWeather"
                bAction  := 'MsgInfo("PRESS OButton_1x2 BUTTONEX")'
                cTooltip := "OButton_1x2 BUTTONEX with icon"
                METRO_BUTTON("OButton_1x2",nStRow1,300+5,247,120,"Weather",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_BLUE,bAction,cTooltip)

                cResIco  := NIL
                cResPict := "bMaps"
                bAction  := 'MsgInfo("PRESS OButton_1x3 BUTTONEX")'
                cTooltip := "OButton_1x3 BUTTONEX with icon"
                METRO_BUTTON("OButton_1x3",nStRow1,554+5,121,120,"Maps",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_BRIGHT_PURPLE,bAction,cTooltip)
        
                cResIco  := NIL
                cResPict := "bSkyDrive"
                bAction  := 'MsgInfo("PRESS OButton_1x4 BUTTONEX")'
                cTooltip := "OButton_1x4 BUTTONEX with icon"
                METRO_BUTTON("OButton_1x4",nStRow1,683+5,121,120,"SkyDrive",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_BLUE_BLUE,bAction,cTooltip)

                // the second row of tiles 
                cResIco  := "iPeople"
                cResPict := NIL
                bAction  := 'MsgInfo("PRESS OButton_2x1 BUTTONEX")'
                cTooltip := "OButton_2x1 BUTTONEX with icon"
                METRO_BUTTON("OButton_2x1",nStRow2,50,247,120,"People",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_PURPLE,bAction,cTooltip)
        
                cResPict := "Desktop"
                bAction  := 'MsgInfo("PRESS OImage_2x2 IMAGE")'
                METRO_IMAGE("OImage_2x2",nStRow2,300+5,247,120,"Desktop",cResPict,;
                             aFontColor,bAction)

                cResIco  := NIL
                cResPict := "bNews"
                bAction  := 'MsgInfo("PRESS OButton_2x3 BUTTONEX")'
                cTooltip := "OButton_2x3 BUTTONEX with icon"
                METRO_BUTTON("OButton_2x3",nStRow2,555+5,247,120,"News",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_RED,bAction,cTooltip)
        
                // third row of tiles 
                cResIco  := "iMusic"
                cResPict := NIL
                bAction  := 'MsgInfo("PRESS OButton_3x1 BUTTONEX")'
                cTooltip := "OButton_3x1 BUTTONEX with icon"
                METRO_BUTTON("OButton_3x1",nStRow3,50,247,120,"Music",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_ORANGE,bAction,cTooltip)

                cResIco  := NIL
                cResPict := "bIE"
                bAction  := 'MsgInfo("PRESS OButton_3x2 BUTTONEX")'
                cTooltip := "OButton_3x2 BUTTONEX with icon"
                METRO_BUTTON("OButton_3x2",nStRow3,300+5,121,120,"Internet Explorer",;
                             cResPict,cResIco,aFontColor,COLOR_BUTTONE_DARK_PURPLE,bAction,cTooltip)
        
                cResIco  := NIL
                cResPict := "bShop"
                bAction  := 'MsgInfo("PRESS OButton_1x4 BUTTONEX")'
                cTooltip := "OButton_3x3 BUTTONEX with icon"
                METRO_BUTTON("OButton_3x3",nStRow3,427+5,121,120,"Shop",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_GREEN,bAction,cTooltip)

                cResIco  := NIL
                cResPict := "MyFoto"
                bAction  := 'MsgInfo("PRESS OImage_3x4 IMAGE")'
                METRO_IMAGE("OImage_3x4",nStRow3,555+5,247,120,"My Foto",cResPict,;
                             aFontColor,bAction)

                // fourth row of tiles 
                cResIco  := "iMessage"
                cResPict := NIL
                bAction  := 'MsgInfo("PRESS OButton_4x1 BUTTONEX")'
                cTooltip := "OButton_4x1 BUTTONEX with icon"
                METRO_BUTTON("OButton_4x1",nStRow4,50,247,120,"Message",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_BRIGHT_PURPLE,bAction,cTooltip)

                cResIco  := NIL
                cResPict := "Bing"
                bAction  := 'MsgInfo("PRESS OImage_4x2 IMAGE")'
                METRO_IMAGE("OImage_4x2",nStRow4,300+5,247,120,"Bing",cResPict,;
                             aFontColor,bAction)

                // Exit from the program
                cResIco  := "iExit"
                cResPict := NIL
                bAction  := 'MyExit()'  //'EXIT'
                cTooltip := "OButton_4x3 - Exit programm !"
                METRO_BUTTON("OButton_4x3",nStRow4,555+5,247,120,"Exit",cResPict,cResIco,;
                             aFontColor,COLOR_BUTTONE_BRIGHT_RED,bAction,cTooltip)

                DEFINE STATUSBAR  SIZE 10 BOLD
                    STATUSITEM COPYRIGHT
                    CLOCK
                    DATE
                END STATUSBAR

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return NIL
//////////////////////////////////////////////////////////////////////
Function MyPopup()
 
    // add an object to a form
    DEFINE MAIN MENU OF Form_1
      Popup 'File'
           Separator
           Item 'Exit' Action MyExit() Image 'EXIT'
      End Popup
      Popup '&BackColor WINDOW'
           Item 'COLOR_DESKTOP_DARK_CYAN    ' Action ( Form_1.BackColor := COLOR_DESKTOP_DARK_CYAN    ,MyRefresh() )
           Item 'COLOR_DESKTOP_DARK_GREEN   ' Action ( Form_1.BackColor := COLOR_DESKTOP_DARK_GREEN   ,MyRefresh() )
           Item 'COLOR_DESKTOP_DARK_PURPLE  ' Action ( Form_1.BackColor := COLOR_DESKTOP_DARK_PURPLE  ,MyRefresh() )
           Item 'COLOR_DESKTOP_DARK_YELLOW  ' Action ( Form_1.BackColor := COLOR_DESKTOP_DARK_YELLOW  ,MyRefresh() )
           Item 'COLOR_DESKTOP_BRIGHT_GREEN ' Action ( Form_1.BackColor := COLOR_DESKTOP_BRIGHT_GREEN ,MyRefresh() )
           Item 'COLOR_DESKTOP_YELLOW_ORANGE' Action ( Form_1.BackColor := COLOR_DESKTOP_YELLOW_ORANGE,MyRefresh() )
      End Popup
      Popup '&Property'
           Item 'Hide STATUSBAR' Action ( Form_1.Statusbar.Visible := .F. , lStatusBar := .F.)
           Item 'Show STATUSBAR' Action ( Form_1.Statusbar.Visible := .T. , lStatusBar := .T.)
           Separator
           Item 'Hide MENU'      Action ( ClearMenu() )
      End Popup
   END MENU

Return NIL
//////////////////////////////////////////////////////////////////////
Function METRO_BUTTON( cObject,nRow,nCol,nWidth,nHeight,cCaption,cResPicture,cResIco,;
                       aFontColor,aBACKCOLOR,bAction,cTooltip)

    AADD( aObjButton , { cObject,nRow,nCol } )  // add the item to refresh

    DEFINE BUTTONEX &cObject
    	ROW  nRow
            COL  nCol
            WIDTH  nWidth
            HEIGHT nHeight
            PICTURE cResPicture 
            ICON cResIco 
            CAPTION cCaption
            ACTION IIF(bAction=='EXIT',ThisWindow.Release,&(bAction))
            VERTICAL .T.
            LEFTTEXT .F. 
            FLAT .F.
            FONTSIZE  10
            FONTBOLD .t.
            FONTCOLOR aFontColor
            BACKCOLOR aBACKCOLOR
            UPPERTEXT .F.
            TOOLTIP cTooltip
            NOHOTLIGHT .F.
            NOXPSTYLE .t.
    END BUTTONEX

Return NIL
//////////////////////////////////////////////////////////////////////
Function METRO_IMAGE( cObject,nRow,nCol,nWidth,nHeight,cCaption,cResPicture,;
                      aFontColor,bAction)
   LOCAL aBackgroundColor := Form_1.BackColor

   AADD(  aObjImage , { cObject,nRow,nCol } )  // add the item to refresh

   DEFINE IMAGE &cObject
      PARENT            Form_1
      ROW               nRow
      COL               nCol
      WIDTH             nWidth
      HEIGHT            nHeight
      PICTURE           cResPicture
      ACTION            IIF(bAction=='EXIT',ThisWindow.Release,&(bAction))
      STRETCH           .T.
      TRANSPARENT       .F. 
      BACKGROUNDCOLOR   aBackgroundColor
      ADJUSTIMAGE       .F.
   END IMAGE

   @ nRow + 90,nCol+20 LABEL &( "Label_" + cObject ) VALUE cCaption ;
      WIDTH nWidth-20 HEIGHT 20 SIZE 10 FONTCOLOR aFontColor BOLD TRANSPARENT 

Return NIL
////////////////////////////////////////////////////////////
FUNCTION MyRefresh()          
   LOCAL nI, cWnd := _HMG_ThisFormName, cObj
   LOCAL nHeight, nHeight2, nWidth, nWidth2

   nHeight := GetProperty( cWnd, "Height") 
   nWidth  := GetProperty( cWnd, "Width")  

   //  refresh METRO_BUTTON
   FOR nI := 1 TO LEN(aObjButton)
       cObj := aObjButton[nI,1]
       nHeight2 := nHeight - 660 + aObjButton[nI,2] 
       nWidth2  := (nWidth - 870)/2 + aObjButton[nI,3] 
       SetProperty( cWnd, cObj, "Visible" , .F. )
       SetProperty( cWnd, cObj, "Row"     , nHeight2 ) 
       SetProperty( cWnd, cObj, "Col"     , nWidth2 ) 
       SetProperty( cWnd, cObj, "Visible" , .T. )
   NEXT
   //  refresh METRO_IMAGE
   FOR nI := 1 TO LEN(aObjImage)
       cObj := aObjImage[nI,1]
       nHeight2 := nHeight - 660 + aObjImage[nI,2]  
       nWidth2  := (nWidth  - 870)/2 + aObjImage[nI,3] 
       SetProperty( cWnd, cObj, "Visible" , .F. )
       SetProperty( cWnd, cObj, "Row"     , nHeight2 ) 
       SetProperty( cWnd, cObj, "Col"     , nWidth2 ) 
       SetProperty( cWnd, cObj, "Visible" , .T. )

       cObj := "Label_" + aObjImage[nI,1]
       nHeight2 := nHeight - 660 + aObjImage[nI,2] + 90
       nWidth2  := (nWidth  - 870)/2 + aObjImage[nI,3] + 20
       SetProperty( cWnd, cObj, "Visible" , .F. )
       SetProperty( cWnd, cObj, "Row"     , nHeight2 ) 
       SetProperty( cWnd, cObj, "Col"     , nWidth2 ) 
       SetProperty( cWnd, cObj, "Visible" , .T. )
   NEXT

   nHeight := GetProperty( cWnd, "Height") - 660 + 20 
   SetProperty( cWnd, "Label_1", "Visible" , .F. )
   SetProperty( cWnd, "Label_1", "Row"     , nHeight ) 
   SetProperty( cWnd, "Label_1", "Visible" , .T. )

   IF lStatusBar 
      SetProperty( cWnd, "STATUSBAR", "Visible" , .F. )
      SetProperty( cWnd, "STATUSBAR", "Visible" , .T. )
   ENDIF

Return NIL
////////////////////////////////////////////////////////////
Procedure ClearMenu()

        DEFINE MAIN MENU OF Form_1

        END MENU

Return
////////////////////////////////////////////////////////////
FUNCTION MyExit()          // Exit programm
   LOCAL lExit, cMess

   cMess := ';Do you really want to exit?  ; ;'
   cMess := AtRepl( ";", cMess, CRLF )
   lExit := MsgYesNo( cMess, "Exit", .F. )
   IF lExit
      RELEASE WINDOW ALL
   ENDIF

RETURN lExit
