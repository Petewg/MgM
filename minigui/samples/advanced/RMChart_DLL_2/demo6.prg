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

#define APP_TITLE "Example 6 RMCHART"

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
        Graphic6( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic6( hWnd, oRMChart, ID_CHART_2, .T. )

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
FUNCTION Graphic6( hWnd, oRMChart, nIdChart, nExportOnly, MAX_SIZE_ONE, MAX_SIZE_TWO )
*-----------------------------------------------------------------------------*

   LOCAL aData, sTemp

   DEFAULT nExportOnly TO .F., MAX_SIZE_ONE TO 650, MAX_SIZE_TWO TO 450

   oRMChart:CreateChart( hWnd, nIdChart, 10, 10, MAX_SIZE_ONE, MAX_SIZE_TWO, COLOR_BISQUE, RMC_CTRLSTYLE3DLIGHT, nExportOnly, "", "Tahoma", 0, COLOR_DEFAULT )
   oRMChart:AddRegion( nIdChart, 5, 5, -5, -5, "this is the footer", .F. )
   oRMChart:AddCaption( nIdChart, 1, "Example of stacked bars", COLOR_BISQUE, COLOR_BLACK, 11, .F. )
   oRMChart:AddGrid( nIdChart, 1, COLOR_CORN_SILK, .F., 0, 0, 0, 0, RMC_BICOLOR_NONE )
   oRMChart:AddDataAxis( nIdChart, 1, RMC_DATAAXISLEFT, 0, 50000, 11, 8, COLOR_BLACK, COLOR_BLACK, RMC_LINESTYLESOLID, 0, " $","optional axis text, 9 points bold\9b", "", RMC_TEXTCENTER )
   sTemp := "Label Nr. 1*Label Nr. 2*Label Nr. 3*Label Nr. 4*Label Nr. 5*Label Nr. 6"
   oRMChart:AddLabelAxis( nIdChart, 1, sTemp, 1, 6, RMC_LABELAXISBOTTOM, 8, COLOR_BLACK, RMC_TEXTCENTER, COLOR_BLACK, RMC_LINESTYLESOLID, "optional label axis text" )
   sTemp := "Apples*Pears*Cherries*Strawberries"
   oRMChart:AddLegend( nIdChart, 1, sTemp, RMC_LEGEND_CUSTOM_UL, COLOR_LIGHT_YELLOW, RMC_LEGENDRECT, COLOR_BLUE, 8, .F. )
   aData := { 10000, 10000, 16000, 12000, 20000, 10000 }
   oRMChart:AddBarSeries( nIdChart, 1, aData, 6, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., COLOR_DARK_BLUE, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   aData := { 5000, 7000, 4000, 15000, 10000, 10000 }
   oRMChart:AddBarSeries( nIdChart, 1, aData, 6, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., COLOR_DARK_GREEN, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   aData := { 10000, 3000, 12000, 10000, 5000, 20000 }
   oRMChart:AddBarSeries(nIdChart,1,aData, 6,RMC_BARSTACKED,RMC_COLUMN_FLAT,.F.,COLOR_MAROON,.F.,1,RMC_VLABEL_NONE,1,RMC_HATCHBRUSH_OFF)
   aData := { 5000, 9000, 12000, 6000, 10000, 5000 }
   oRMChart:AddBarSeries( nIdChart, 1, aData, 6, RMC_BARSTACKED, RMC_COLUMN_FLAT, .F., COLOR_DARK_GOLDENROD, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )
   oRMChart:SetWatermark( RMC_USERWM, RMC_USERWMCOLOR, RMC_USERWMLUCENT, RMC_USERWMALIGN, RMC_USERFONTSIZE ) 

   RETURN NIL
