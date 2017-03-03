/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "rmchart.ch"

#define RMC_USERWM         ""               // Your watermark
#define RMC_USERWMCOLOR    COLOR_BLACK      // Color for the watermark
#define RMC_USERWMLUCENT   30               // Lucent factor between 1(=not visible) and 255(=opaque)
#define RMC_USERWMALIGN    RMC_TEXTCENTER   // Alignment for the watermark
#define RMC_USERFONTSIZE   0                // Fontsize; if 0: maximal size is used

#define APP_TITLE "Example 10 RMCHART"

#define ID_CHART   1001
#define ID_CHART_2 1002

Static oRMChart, lDraw := .F.

SET PROCEDURE TO rmchart.prg

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*

	SET FONT TO "Times New Roman" , 10

        oRMChart := RMChart():New()

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 680 ;
		HEIGHT 550 ;
		TITLE APP_TITLE ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INTERACTIVECLOSE iif( MsgYesNo("Really want to quit ?", "Exit"), EndWindow( .F. ), .F. )

		@ 475, 100 BUTTON Btn_Chart ;
			CAPTION "RMCHART" ;
			ACTION Chart( thiswindow.Handle ) ;
			WIDTH 150 HEIGHT 30 DEFAULT

		@ 475, 270 BUTTON Btn_Print ;
			CAPTION "PRINT" ;
			ACTION PrintChart( thiswindow.Handle ) ;
			WIDTH 150 HEIGHT 30

		@ 475, 440 BUTTON Btn_Cancel ;
			CAPTION "Close" ;
			ACTION EndWindow() ;
			WIDTH 150 HEIGHT 30

		ON KEY ESCAPE ACTION Win_1.Btn_Cancel.OnClick

	END WINDOW

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return

*-----------------------------------------------------------------------------*
Procedure Chart( hWnd )
*-----------------------------------------------------------------------------*

    IF !lDraw
        lDraw := .T.
        Graphic10( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic10( hWnd, oRMChart, ID_CHART_2, 1 )

    IF CallDll32( "RMC_DRAW2PRINTER", "RMCHART.DLL", ID_CHART_2, RMC_LANDSCAPE, 10, 10, 220, 150, RMC_EMFPLUS ) < 0

       MsgStop("Print error!")
       
    ENDIF

   oRmChart:DeleteChart( ID_CHART_2 )

Return

*-----------------------------------------------------------------------------*
Procedure endwindow( lClose )
*-----------------------------------------------------------------------------*
    Default lClose To .T.

    IF lDraw
        oRmChart:DeleteChart( ID_CHART )
        oRMChart:Destroy()
    ENDIF

    IF lClose
        Win_1.Release
    ENDIF

Return

*-----------------------------------------------------------------------------*
FUNCTION Graphic10( hWnd, oRMChart, nIdChart, nExportOnly, nW, nH )
*-----------------------------------------------------------------------------*

   LOCAL aPPC, aData, aData2, sTemp, aXPos, aYPos

   DEFAULT nExportOnly TO 0, nW TO 650, nH TO 450

   ************** Create the chart **********************
   oRMChart:CreateChart(hWnd,nIdChart,10,10,nW,nH,COLOR_FADE_GREEN,RMC_CTRLSTYLEFLATSHADOW,nExportOnly,"","Tahoma", 0, COLOR_DEFAULT)

   ************** Add Region 1 *****************************
   oRMChart:AddRegion(nIdChart,10,10,-5,-5,"data source: www.federalreserve.gov + www.ecb.int",FALSE)

   ************** Add caption to region 1 *******************
   oRMChart:AddCaption(nIdChart,1,"Prime Rates in USA and Euroland",COLOR_PALE_GREEN,COLOR_MIDNIGHT_BLUE,10,1)

   ************** Add grid to region 1 *****************************
   oRMChart:AddGrid(nIdChart,1,COLOR_AZURE,1,0,0,0,0,RMC_BICOLOR_DATAAXIS)

   ************* Add data axis to region 1 *****************************
   oRMChart:AddDataAxis(nIdChart,1,RMC_DATAAXISLEFT,0,7,15,8,COLOR_DARK_BLUE,COLOR_DARK_BLUE,RMC_LINESTYLENONE,2," %","","",RMC_TEXTCENTER)

   ************** Add label axis to region 1 *****************************
   sTemp := "1999*2000*2001*2002*2003*2004*2005*2006"
   oRMChart:AddLabelAxis(nIdChart,1, sTemp,1,8,RMC_LABELAXISBOTTOM,8,COLOR_DARK_BLUE,RMC_TEXTCENTER,COLOR_DARK_SALMON,RMC_LINESTYLEDOT,"") 

   ************** Add Series 1 to region 1 ******************************* 
   ****** Read points per column ******
   aPPC := { 12 }
   ****** Read data values ******
   aData := { ;
    4.75 , 4.75 , 4.75 , 4.75 , 4.75 , ;
    5 , 5 , 5.25 , 5.25 , 5.25 , ;
    5.5 , 5.5 , 5.5 , 5.75 , 6 , ;
    6 , 6.5 , 6.5 , 6.5 , 6.5 , ;
    6.5 , 6.5 , 6.5 , 6.5 , 5.5 , ;
    5.5 , 5 , 4.5 , 4 , 3.75 , ;
    3.75 , 3.5 , 3 , 2.5 , 2 , ;
    1.75 , 1.75 , 1.75 , 1.75 , ;
    1.75 , 1.75 , 1.75 , 1.75 , ;
    1.75 , 1.75 , 1.75 , 1.25 , ;
    1.25 , 1.25 , 1.25 , 1.25 , ;
    1.25 , 1.25 , 1 , 1 , 1 , ;
    1 , 1 , 1 , 1 , 1 , ;
    1 , 1 , 1 , 1 , 1 , ;
    1 , 1.25 , 1.5 , 1.75 , 2 , ;
    2.25 , 2.25 , 2.5 , 2.75 , ;
    2.75 , 3 , 3.25 , 3.25 , 3.5 , ;
    3.75 , 3.75 , 4 , 4.25 , 4.5 , ;
    4.5 , 4.75 , 4.75 , 5 , 5.25 , ;
    5.25 , 5.25 , 5.25 , 5.25 , 5.25 , 5.25 }

   oRMChart:AddLineSeries(nIdChart,1, aData, 96,aPPC,1,RMC_LINE,RMC_LINE_CABLE_SHADOW,RMC_LSTYLE_STAIR,FALSE, ;
                                    COLOR_GREEN,RMC_SYMBOL_NONE,1,RMC_VLABEL_NONE,RMC_HATCHBRUSH_OFF)

   ************** Add Series 2 to region 1 *******************************
   ****** Read data values ******
   aData2 := { ;
    3 , 3 , 3 , 2.5 , 2.5 , ;
    2.5 , 2.5 , 2.5 , 2.5 , 2.5 , ;
    3 , 3 , 3 , 3.25 , 3.5 , ;
    3.75 , 3.75 , 4.25 , 4.25 , ;
    4.5 , 4.5 , 4.75 , 4.75 , 4.75 , ;
    4.75 , 4.75 , 4.75 , 4.75 , ;
    4.5 , 4.5 , 4.5 , 4.25 , 3.75 , ;
    3.75 , 3.25 , 3.25 , 3.25 , ;
    3.25 , 3.25 , 3.25 , 3.25 , ;
    3.25 , 3.25 , 3.25 , 3.25 , ;
    3.25 , 3.25 , 2.75 , 2.75 , ;
    2.75 , 2.5 , 2.5 , 2.5 , 2 , ;
    2 , 2 , 2 , 2 , 2 , ;
    2 , 2 , 2 , 2 , 2 , ;
    2 , 2 , 2 , 2 , 2 , ;
    2 , 2 , 2 , 2 , 2 , ;
    2 , 2 , 2 , 2 , 2 , ;
    2 , 2 , 2 , 2 , 2.25 , ;
    2.25 , 2.25 , 2.5 , 2.5 , 2.5 , ;
    2.75 , 2.75 , 3 , 3 , 3.25 , 3.25 , 3.5 }

   oRMChart:AddLineSeries(nIdChart,1, aData2, 96,aPPC,1,RMC_LINE,RMC_LINE_CABLE_SHADOW,RMC_LSTYLE_STAIR,FALSE, ;
                                    COLOR_GOLDENROD,RMC_SYMBOL_NONE,1,RMC_VLABEL_NONE,RMC_HATCHBRUSH_OFF)

   ************** Add CustomObjects ******************************* 
   aXPos := Array(2)
   aXPos[1] := 216 ; aXPos[2] := 287
   aYPos := Array(2)
   aYPos[1] := 109 ; aYPos[2] := 109
   oRMChart:COLine(nIdChart, 1, aXPos, aYPos, 2, RMC_LINE_FLAT, COLOR_GREEN, 0, 2, RMC_ANCHOR_ARROW_CLOSED, RMC_ANCHOR_NONE)

   sTemp := "USA (Federal Funds Rate)"
   oRMChart:COText(nIdChart, 2, sTemp, 295, 102, 0, 0, RMC_BOX_NONE, COLOR_DEFAULT, COLOR_DEFAULT, 0, RMC_LINE_HORIZONTAL, COLOR_DEFAULT, "00BC")

   aXPos := Array(2)
   aXPos[1] := 260 ; aXPos[2] := 287
   aYPos := Array(2)
   aYPos[1] := 192 ; aYPos[2] := 192
   oRMChart:COLine(nIdChart, 3, aXPos, aYPos, 2, RMC_LINE_FLAT, COLOR_GOLD, 0, 2, RMC_ANCHOR_ARROW_CLOSED, RMC_ANCHOR_NONE)

   sTemp := "Euroland (Prime Rate)"
   oRMChart:COText(nIdChart, 4, sTemp, 295, 185, 0, 0, RMC_BOX_NONE, COLOR_DEFAULT, COLOR_DEFAULT, 0, RMC_LINE_HORIZONTAL, COLOR_DEFAULT, "00BC")
 
   oRMChart:SetWatermark(RMC_USERWM,RMC_USERWMCOLOR,RMC_USERWMLUCENT,RMC_USERWMALIGN,RMC_USERFONTSIZE)

   RETURN NIL
