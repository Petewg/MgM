/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "rmchart.ch"

#define APP_TITLE "Example 8 RMCHART"

#define ID_CHART   1001
#define ID_CHART_2 1002

Static oRMChart, lDraw := .F.

SET PROCEDURE TO rmchart.prg

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*

        oRMChart := RMChart():New()

	SET FONT TO "Times New Roman" , 10

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
        Graphic8( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic8( hWnd, oRMChart, ID_CHART_2, .T. )

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
FUNCTION Graphic8( hWnd, oRMChart, nIdChart, nExportOnly, nW, nH )
*-----------------------------------------------------------------------------*

   LOCAL cLabels, cTitle, aData, cUnidade, cTextoVert, nMin, nMax

   DEFAULT nExportOnly TO .F., nW TO 650, nH TO 450

   cLabels    := "Label A*Label B*Label C*Label D*Label E"
   cTitle     := "This is our chart's caption"
   aData      := { 55.0, 70.0, 40.0, 60.0, 30.0 }
   cUnidade   := "%"
   cTextoVert := "Axis Text"
   nMin       := 0.0
   nMax       := 100.0

   oRMChart:CreateChart( hWnd, nIdChart, 10, 10, nW, nH, COLOR_AZURE, RMC_CTRLSTYLEFLAT, nExportOnly, "", "", 0, 0 )
   oRMChart:AddRegion( nIdChart, 5, 5, -5, -5, "", .F. )
   oRMChart:AddCaption( nIdChart, 1, cTitle, COLOR_TRANSPARENT, COLOR_BLUE, 11, .T. )
   oRMChart:AddGrid( nIdChart, 1, COLOR_BEIGE, .F., 0, 0, 0, 0, RMC_BICOLOR_LABELAXIS )
   oRMChart:AddDataAxis( nIdChart, 1, RMC_DATAAXISLEFT, nMin, nMax, 11, 8, COLOR_BLACK, COLOR_BLACK, RMC_LINESTYLEDOT, 0, cUnidade, cTextoVert, "", RMC_TEXTCENTER )
   oRMChart:AddLabelAxis( nIdChart, 1, cLabels, 1, 5, RMC_LABELAXISBOTTOM, 8, COLOR_BLACK, RMC_TEXTCENTER, COLOR_BLACK, RMC_LINESTYLENONE, "" )

   oRMChart:AddBarSeries( nIdChart, 1, aData, 5, RMC_BARSINGLE, RMC_BAR_FLAT_GRADIENT2, .F., COLOR_CORN_FLOWER_BLUE, .F., 1, RMC_VLABEL_NONE, 1, RMC_HATCHBRUSH_OFF )

   RETURN NIL
