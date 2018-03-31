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
                                             
#define PROGRAM 'ButtonEx with METRO color background (2)'
#define COPYRIGHT ' (c) 2013 Andrey Verchenko, Russia, Dmitrov. ' + MiniGUIVersion()

STATIC aObjButton := {}, aObjImage := {}, aPicture := {}, aTekBackColor, aTekPict
STATIC nOldRow, nOldCol, nOldWidth, nOldHeight, lMaximize := .F.

Function Main()
     LOCAL cResIco, cResPict := NIL, bAction, cTooltip, nWidth, nHeight
     LOCAL nStRow1 := 90, nStRow2 := 218, nStRow3 := 347, nStRow4 := 477
     LOCAL aFontColor := WHITE
      
     MyInitPicture() // Read the background images to an array 

	DEFINE WINDOW Form_1 ;
		AT 0,0 WIDTH 870 HEIGHT 650 ;
                MAIN ;
                ICON "1MAIN" ;
		TITLE PROGRAM  ;
                NOMAXIMIZE NOSIZE NOCAPTION ;
                ON INIT ( Form_1.OButton_4x3.SetFocus ) ;
	        BACKCOLOR COLOR_DESKTOP_DARK_CYAN 

  	        nWidth  := Form_1.Width
	        nHeight := Form_1.Height

                @ 1,90 LABEL Label_Title WIDTH nWidth - 50*2 - 70  HEIGHT 22 VALUE PROGRAM ;
                  FONTCOLOR WHITE SIZE 14 BOLD TRANSPARENT CENTERALIGN ;
                  ACTION MoveActiveWindow() ;
                  OnMouseHover RC_CURSOR( "hand32" )
 
                MyPopupImageMenu()

                MySizesWinExit()  // management - right up windows

                @ 25, 0  IMAGE Img_Bckgrnd PICTURE '' WIDTH nWidth HEIGHT nHeight STRETCH 

		@ 50,30 LABEL label_1 VALUE "Start" WIDTH 120 HEIGHT 28 SIZE 18 FONTCOLOR WHITE BOLD TRANSPARENT 

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

		@ nHeight-30,10 LABEL Label_StatusBar VALUE COPYRIGHT ;
                  WIDTH nWidth-20 HEIGHT 16 SIZE 11 BOLD ;
                  CENTERALIGN FONTCOLOR WHITE TRANSPARENT 

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return NIL
//////////////////////////////////////////////////////////////////////
Function MyPopupImageMenu()
    LOCAL nI, cItemName, HBtn1DropMenu, cFile, cAction 
 
    @ 0,0 IMAGE Image_Menu PICTURE 'W_Menu' WIDTH 85 HEIGHT 25 ;
       STRETCH TRANSPARENT BACKGROUNDCOLOR Form_1.BackColor ;
       ACTION { || ShowBtnDropMenu('Form_1', This.Name,HBtn1DropMenu)} 
        DEFINE CONTEXT MENU CONTROL Image_Menu
           MenuItem 'COLOR_DESKTOP_DARK_CYAN    ' Action ( MyRefresh( COLOR_DESKTOP_DARK_CYAN    , NIL ) )
           MenuItem 'COLOR_DESKTOP_DARK_GREEN   ' Action ( MyRefresh( COLOR_DESKTOP_DARK_GREEN   , NIL ) )
           MenuItem 'COLOR_DESKTOP_DARK_PURPLE  ' Action ( MyRefresh( COLOR_DESKTOP_DARK_PURPLE  , NIL ) )
           MenuItem 'COLOR_DESKTOP_DARK_YELLOW  ' Action ( MyRefresh( COLOR_DESKTOP_DARK_YELLOW  , NIL ) )
           MenuItem 'COLOR_DESKTOP_BRIGHT_GREEN ' Action ( MyRefresh( COLOR_DESKTOP_BRIGHT_GREEN , NIL ) )
           MenuItem 'COLOR_DESKTOP_YELLOW_ORANGE' Action ( MyRefresh( COLOR_DESKTOP_YELLOW_ORANGE, NIL ) )
           Separator
           IF Len( aPicture ) > 0
              FOR nI := 1 TO LEN(aPicture)
                 cItemName := "IMAGE  ( " + aPicture[nI,1]+" )"
                 cFile := aPicture[nI,2]
                 cAction := "MyRefresh(NIL,'"+cFile+"')"
                 MENUITEM cItemName ACTION  &cAction 
              NEXT
           ENDIF
           Separator
           MenuItem 'Exit' Action MyExit() Image 'EXIT'
        END MENU
        HBtn1DropMenu := _HMG_xContextMenuHandle
        SET CONTEXT MENU CONTROL Image_Menu OF Form_1 OFF

Return NIL
//////////////////////////////////////////////////////////////////////
Function  MySizesWinExit()  // management - right up windows
   LOCAL aBackgroundColor := COLOR_DESKTOP_YELLOW_ORANGE  //Form_1.BackColor
   LOCAL nWidth  := Form_1.Width

@ 2,nWidth - 25 BUTTONEX WIN_EXIT WIDTH 24 HEIGHT 24 ICON "iW_Exit" ;                    
      ACTION MyExit() NOTRANSPARENT ;
      NOHOTLIGHT NOXPSTYLE BACKCOLOR aBackgroundColor

@ 2,nWidth - 50 BUTTONEX WIN_MAX WIDTH 24 HEIGHT 24 ICON "iW_Green" ;                    
      ACTION { || iif(lMaximize, (lMaximize := .F., ;
		Form_1.Row := nOldRow, Form_1.Col := nOldCol, ;
                Form_1.WIN_MAX.Picture := "iW_Green", ;
		Form_1.Width := nOldWidth, Form_1.Height := nOldHeight, MyRefresh(aTekBackColor, aTekPict)), ;
		(lMaximize := .T., ;
		nOldRow := Form_1.Row, nOldCol := Form_1.Col, ;
		nOldWidth := Form_1.Width, nOldHeight := Form_1.Height, ;
                Form_1.WIN_MAX.Picture := "iW_White", ;
		Form_1.Row := 0, Form_1.Col := 0, ;
		Form_1.Width := (System.DesktopWidth), Form_1.Height := (System.DesktopHeight) - GetTaskBarHeight(), ;
		MyRefresh(aTekBackColor, aTekPict))) } ;
      NOHOTLIGHT NOXPSTYLE BACKCOLOR aBackgroundColor

@ 2,nWidth - 75 BUTTONEX WIN_MIN WIDTH 24 HEIGHT 24 ICON "iW_Yellow" ;                    
      ACTION { || Form_1.Minimize }  ;
      NOHOTLIGHT NOXPSTYLE BACKCOLOR aBackgroundColor

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
FUNCTION MyRefresh(aBackColor,cImage)          
   LOCAL nI, cWnd := _HMG_ThisFormName, cObj
   LOCAL nHeight, nHeight2, nWidth, nWidth2
   DEFAULT aBackColor TO {}
   DEFAULT cImage TO ""

   nHeight := GetProperty( cWnd, "Height") 
   nWidth  := GetProperty( cWnd, "Width")  

   //  refresh windows BackColor 
   IF LEN(aBackColor) > 0
      SetProperty( cWnd, "BackColor", aBackColor )
      aTekBackColor := aBackColor 
      aTekPict := NIL
      SetProperty( cWnd, "Img_Bckgrnd", "Visible" , .F. )
   ENDIF

   //  refresh IMAGE windows Background 
   IF LEN(cImage) > 0
      SetProperty( cWnd, "Img_Bckgrnd", "Visible" , .F.     )
      SetProperty( cWnd, "Img_Bckgrnd", "Picture" , cImage  )
      SetProperty( cWnd, "Img_Bckgrnd", "Height"  , nHeight ) 
      SetProperty( cWnd, "Img_Bckgrnd", "Width"   , nWidth  ) 
      SetProperty( cWnd, "Img_Bckgrnd", "Visible" , .T.     )
      aTekPict := cImage
   ENDIF

   //  refresh METRO_BUTTON
   FOR nI := 1 TO LEN(aObjButton)
       cObj := aObjButton[nI,1]
       nHeight2 := nHeight - 650 + aObjButton[nI,2] 
       nWidth2  := (nWidth - 870)/2 + aObjButton[nI,3] 
       SetProperty( cWnd, cObj, "Visible" , .F. )
       SetProperty( cWnd, cObj, "Row"     , nHeight2 ) 
       SetProperty( cWnd, cObj, "Col"     , nWidth2 ) 
       SetProperty( cWnd, cObj, "Visible" , .T. )
   NEXT
   //  refresh METRO_IMAGE
   FOR nI := 1 TO LEN(aObjImage)
       cObj := aObjImage[nI,1]
       nHeight2 := nHeight - 650 + aObjImage[nI,2]  
       nWidth2  := (nWidth  - 870)/2 + aObjImage[nI,3] 
       SetProperty( cWnd, cObj, "Visible" , .F. )
       SetProperty( cWnd, cObj, "Row"     , nHeight2 ) 
       SetProperty( cWnd, cObj, "Col"     , nWidth2 ) 
       SetProperty( cWnd, cObj, "Visible" , .T. )

       cObj := "Label_" + aObjImage[nI,1]
       nHeight2 := nHeight - 650 + aObjImage[nI,2] + 90
       nWidth2  := (nWidth  - 870)/2 + aObjImage[nI,3] + 20
       SetProperty( cWnd, cObj, "Visible" , .F. )
       SetProperty( cWnd, cObj, "Row"     , nHeight2 ) 
       SetProperty( cWnd, cObj, "Col"     , nWidth2 ) 
       SetProperty( cWnd, cObj, "Visible" , .T. )
   NEXT

   SetProperty( cWnd, "Label_1", "Visible"  , .F. )
   SetProperty( cWnd, "Label_1", "Row"      , nHeight - 650 + 50 ) 
   SetProperty( cWnd, "Label_1", "BACKCOLOR", Form_1.BackColor )
   SetProperty( cWnd, "Label_1", "Visible"  , .T. )

   SetProperty( cWnd, "Label_StatusBar", "Visible" , .F. )
   SetProperty( cWnd, "Label_StatusBar", "Row"     , nHeight - 30 ) 
   SetProperty( cWnd, "Label_StatusBar", "Width"   , nWidth -20   ) 
   SetProperty( cWnd, "Label_StatusBar", "BACKCOLOR", Form_1.BackColor )
   SetProperty( cWnd, "Label_StatusBar", "Visible" , .T. )

   SetProperty( cWnd, "WIN_EXIT", "Visible" , .F. )
   SetProperty( cWnd, "WIN_EXIT", "Col"     , nWidth - 25 ) 
   SetProperty( cWnd, "WIN_EXIT", "Visible" , .T. )

   SetProperty( cWnd, "WIN_MAX", "Visible" , .F. )
   SetProperty( cWnd, "WIN_MAX", "Col"     , nWidth - 50 ) 
   SetProperty( cWnd, "WIN_MAX", "Visible" , .T. )

   SetProperty( cWnd, "WIN_MIN", "Visible" , .F. )
   SetProperty( cWnd, "WIN_MIN", "Col"     , nWidth - 75 ) 
   SetProperty( cWnd, "WIN_MIN", "Visible" , .T. )

   SetProperty( cWnd, "Label_Title", "Visible"   , .F. )
   SetProperty( cWnd, "Label_Title", "Width"     , nWidth - 50*2 - 70 ) 
   SetProperty( cWnd, "Label_Title", "BACKCOLOR" , Form_1.BackColor )
   SetProperty( cWnd, "Label_Title", "Visible"   , .T. )

   SetProperty( cWnd, "Image_Menu", "Visible" , .F. )
   SetProperty( cWnd, "Image_Menu", "Visible" , .T. )

Return NIL
///////////////////////////////////////////////////////////
// This function initializes the picture on the menu
FUNCTION MyInitPicture()
   LOCAL aDim, nI, cPath := GetStartupFolder() + "\PICTURE\"
 
   aDim := Directory( cPath + "*.jpg" )
   IF Len( aDim ) > 0

      FOR nI := 1 TO Len( aDim )
         AAdd( aPicture, { aDim[ nI, 1 ], cPath + aDim[ nI, 1 ] } )
      NEXT
   
   ENDIF

   RETURN Nil
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
////////////////////////////////////////////////////////////
#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow(hWnd)

	Default hWnd := GetActiveWindow()

	PostMessage(hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0)

	RC_CURSOR( "Grabbed32" )

RETURN
//-------------------------------------------------------------------\\
//   Copyright (C) 2013 Sergey Logoshny
//-------------------------------------------------------------------\\
FUNCTION ShowBtnDropMenu(cWin,cBut,HBtnDropMenu)
LOCAL aPos:={0,0,0,0}

	GetWindowRect( GetControlHandle( cBut, cWin ), /*@*/aPos )

	TrackPopupMenu( HBtnDropMenu, aPos[1], ;
                aPos[2] + GetProperty(cWin,cBut,'Height'), GetFormHandle( cWin ) )
RETURN NIL
