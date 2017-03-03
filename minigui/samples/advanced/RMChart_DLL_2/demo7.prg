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

#define APP_TITLE "Example 7 RMCHART"

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
        Graphic7( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic7( hWnd, oRMChart, ID_CHART_2, .T. )

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
FUNCTION Graphic7( hWnd, oRMChart, nIdChart, nExportOnly, MAX_SIZE_ONE, MAX_SIZE_TWO )
*-----------------------------------------------------------------------------*

   LOCAL aData, sTemp

   DEFAULT nExportOnly TO .F., MAX_SIZE_ONE TO 640, MAX_SIZE_TWO TO 450

   oRmChart:CreateChart( hWnd, nIdChart, 15, 10, MAX_SIZE_ONE,MAX_SIZE_TWO, COLOR_TRANSPARENT, RMC_CTRLSTYLEIMAGETILED, nExportOnly, "seasky.jpg", "Tahoma", 0, COLOR_DEFAULT )
   oRmChart:AddRegion( nIdChart, 5, 5, -15, -15, "", .F. )
   oRmChart:AddGrid( nIdChart, 1, COLOR_TRANSPARENT, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oRmChart:AddDataAxis( nIdChart, 1, RMC_DATAAXISLEFT, 0, 100, 11, 8, COLOR_DEFAULT, COLOR_DEFAULT, RMC_LINESTYLESOLID, 0, "", "", "", RMC_TEXTCENTER )
   sTemp := "2000*2001*2002*2003*2004"
   oRmChart:AddLabelAxis( nIdChart, 1, sTemp, 1,5, RMC_LABELAXISBOTTOM, 8, COLOR_DEFAULT, RMC_TEXTCENTER, COLOR_DEFAULT, RMC_LINESTYLESOLID, "" )
   sTemp := "First quarter*Second quarter*Third quarter*Fourth quarter"
   oRmChart:AddLegend( nIdChart, 1, sTemp, RMC_LEGEND_TOP, COLOR_DEFAULT, RMC_LEGENDNORECT, COLOR_DEFAULT, 8, .F. )
   aData := { 30, 20, 40, 60, 10 }
   oRmChart:AddBarSeries( nIdChart, 1, aData, 5, RMC_BARGROUP, RMC_BAR_HOVER, .F., COLOR_DEFAULT, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   aData := { 30, 20, 50, 70, 60 }
   oRmChart:AddBarSeries( nIdChart, 1, aData, 5, RMC_BARGROUP, RMC_BAR_HOVER, .F., COLOR_DEFAULT, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   aData := { 40, 10, 30, 20, 80 }
   oRmChart:AddBarSeries( nIdChart, 1, aData, 5, RMC_BARGROUP, RMC_BAR_HOVER, .F., COLOR_DEFAULT, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   aData := { 70, 50, 80, 40, 30 }
   oRmChart:AddBarSeries( nIdChart, 1, aData, 5, RMC_BARGROUP, RMC_BAR_HOVER, .F., COLOR_DEFAULT, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oRmChart:SetWatermark( RMC_USERWM, RMC_USERWMCOLOR, RMC_USERWMLUCENT, RMC_USERWMALIGN, RMC_USERFONTSIZE ) 

   RETURN NIL
