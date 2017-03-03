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

#define APP_TITLE "Example 5 RMCHART"

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
        Graphic5( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic5( hWnd, oRMChart, ID_CHART_2, .T. )

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
FUNCTION Graphic5( hWnd, oRMChart, nIdChart, nExportOnly, MAX_SIZE_ONE, MAX_SIZE_TWO )
*-----------------------------------------------------------------------------*

   LOCAL aColors := { COLOR_LIGHT_GREEN, COLOR_YELLOW, COLOR_GOLDENROD, COLOR_CRIMSON }
   LOCAL aData   := { 40, 30, 60, 20 }

   DEFAULT nExportOnly TO .F., MAX_SIZE_ONE TO 650, MAX_SIZE_TWO TO 450

   oRmChart:CreateChart( hWnd,nIdChart,10,10,MAX_SIZE_ONE,MAX_SIZE_TWO,COLOR_MIDNIGHT_BLUE,RMC_CTRLSTYLEIMAGE,nExportOnly,"seasky.jpg","Tahoma", 0, COLOR_DEFAULT )
   oRMChart:AddRegion(nIdChart,5,5,-5,-5,"",.F.)
   oRMChart:AddLegend(nIdChart,1,"Apples*Citrons*Bananas*Cherries",RMC_LEGEND_CUSTOM_CENTER,COLOR_DEFAULT,RMC_LEGENDNORECT,COLOR_WHITE,8,.F.)
   oRmChart:AddGridlessSeries(nIdChart,1, aData, 4, aColors, 4,RMC_DONUT_GRADIENT,RMC_FULL,0,.F.,RMC_VLABEL_TWIN,RMC_HATCHBRUSH_OFF, 0)
   oRmChart:SetWatermark(RMC_USERWM,RMC_USERWMCOLOR,RMC_USERWMLUCENT,RMC_USERWMALIGN,RMC_USERFONTSIZE)

   RETURN NIL
