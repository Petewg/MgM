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

#define APP_TITLE "Example 11 RMCHART"

#define ID_CHART   5001
#define ID_CHART_2 5002

Static oRMChart, lDraw := .F.

SET PROCEDURE TO rmchart.prg

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*

	SET FONT TO "Times New Roman" , 10

        oRMChart := RMChart():New()

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 745 ;
		HEIGHT 370 ;
		TITLE APP_TITLE ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INTERACTIVECLOSE iif( MsgYesNo("Really want to quit ?", "Exit"), EndWindow( .F. ), .F. )

		@ 295, 120 BUTTON Btn_Chart ;
			CAPTION "RMCHART" ;
			ACTION CreateCharts( thiswindow.Handle ) ;
			WIDTH 150 HEIGHT 30 DEFAULT

		@ 295, 290 BUTTON Btn_Print ;
			CAPTION "SAVE RMC" ;
			ACTION SaveCharts() ;
			WIDTH 150 HEIGHT 30

		@ 295, 460 BUTTON Btn_Cancel ;
			CAPTION "Close" ;
			ACTION EndWindow() ;
			WIDTH 150 HEIGHT 30

		ON KEY ESCAPE ACTION Win_1.Btn_Cancel.OnClick

	END WINDOW

	Win_1.Btn_Print.Enabled := .F.

	CENTER WINDOW Win_1
	ACTIVATE WINDOW Win_1

Return

*-----------------------------------------------------------------------------*
Procedure CreateCharts( hWnd )
*-----------------------------------------------------------------------------*

    IF !lDraw
        lDraw := .T.

        // Create a Pie Chart
        IF FILE( "chart11.rmc" )
           oRMChart:CreateChartFromFile( hWnd, ID_CHART, 20, 20, 0, "chart11.rmc" )
        ELSE
           Graphic11( hWnd, oRMChart, ID_CHART )
        ENDIF
        oRMChart:Draw( ID_CHART )

        // Create a line Chart
        IF FILE( "chart12.rmc" )
           oRMChart:CreateChartFromFile( hWnd, ID_CHART_2, 380, 20, 0, "chart12.rmc" )
        ELSE
           Graphic12( hWnd, oRMChart, ID_CHART_2 )
        ENDIF
        oRMChart:Draw( ID_CHART_2 )

	Win_1.Btn_Print.Enabled := .T.
    ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure SaveCharts()
*-----------------------------------------------------------------------------*

    LOCAL nError, nError_2

    oRmChart:WriteRMCFile( ID_CHART, "chart11.rmc" )
    nError := oRmChart:nError

    oRmChart:WriteRMCFile( ID_CHART_2, "chart12.rmc" )
    nError_2 := oRmChart:nError

    IF nError == 0 .AND. nError_2 == 0
       MsgInfo( 'RMC files were saved successfully.' )
    ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure endwindow( lClose )
*-----------------------------------------------------------------------------*
    Default lClose To .T.

    IF lDraw
        oRmChart:DeleteChart( ID_CHART )
        oRmChart:DeleteChart( ID_CHART_2 )
        oRMChart:Destroy()
    ENDIF

    IF lClose
        Win_1.Release
    ENDIF

Return

*-----------------------------------------------------------------------------*
FUNCTION GetSampleData()
*-----------------------------------------------------------------------------*

   LOCAL aData := Array(10)

   aData[1] := 20
   aData[2] := 32
   aData[3] := 45
   aData[4] := 76
   aData[5] := 50
   aData[6] := 89
   aData[7] := 72
   aData[8] := 41
   aData[9] := 45
   aData[10]:= 27

   RETURN aData

*-----------------------------------------------------------------------------*
FUNCTION Graphic11( hWnd, oRMChart11, nIdChart, MAX_SIZE_ONE, MAX_SIZE_TWO )
*-----------------------------------------------------------------------------*

   LOCAL aData1 := GetSampleData()

   DEFAULT MAX_SIZE_ONE TO 330, MAX_SIZE_TWO TO 250

   oRMChart11:CreateChart(hWnd,nIdChart, 20, 20, MAX_SIZE_ONE, MAX_SIZE_TWO, 0, 0, 0, "", "", 0, 0)
   oRMChart11:AddRegion(nIdChart , 0 , 0 , 0 , 0 , "" , 0)
   oRMChart11:AddGridlessSeries(nIdChart,1,aData1,10,0,0,0,0,0,0,RMC_VLABEL_PERCENT,0,0)

   RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION Graphic12( hWnd, oRMChart12, nIdChart, MAX_SIZE_ONE, MAX_SIZE_TWO )
*-----------------------------------------------------------------------------*

   LOCAL aData2 := GetSampleData()

   DEFAULT MAX_SIZE_ONE TO 330, MAX_SIZE_TWO TO 250

   oRMChart12:CreateChart(hWnd,nIdChart, 380, 20, MAX_SIZE_ONE, MAX_SIZE_TWO, 0, 0, 0, "", "", 0, 0)
   oRMChart12:AddRegion(nIdChart , 0 , 0 , 0 , 0 , "" , 0)
   oRMChart12:AddGrid(nIdChart,1,0,0,0,0,0,0,0)
   oRMChart12:AddLabelAxis(nIdChart, 1, "10*20*30*40*50*60*70*80*90*100", 0,0,0,0,0,0,0,0,"")
   oRMChart12:AddDataAxis(nIdChart,1,0,0,100,0,0,0,0,0,0,"","","",0)
   oRMChart12:AddLineSeries(nIdChart,1,0,0,0,0,0,0,0,0,0,0,0,0,0)
   oRMChart12:SetSeriesData(nIdChart, 1, 1, aData2, 10, 0)

   RETURN NIL
