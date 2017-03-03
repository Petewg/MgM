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

#define APP_TITLE "Example 2 RMCHART"

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
		WIDTH 730 ;
		HEIGHT 600 ;
		TITLE APP_TITLE ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INTERACTIVECLOSE iif( MsgYesNo("Really want to quit ?", "Exit"), EndWindow( .F. ), .F. )

		@ 525, 125 BUTTON Btn_Chart ;
			CAPTION "RMCHART" ;
			ACTION Chart( thiswindow.Handle ) ;
			WIDTH 150 HEIGHT 30 DEFAULT

		@ 525, 295 BUTTON Btn_Print ;
			CAPTION "PRINT" ;
			ACTION PrintChart( thiswindow.Handle ) ;
			WIDTH 150 HEIGHT 30

		@ 525, 465 BUTTON Btn_Cancel ;
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
        Graphic2( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic2( hWnd, oRMChart, ID_CHART_2, 1 )

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
FUNCTION Graphic2( hWnd, oRMChart, nIdChart, nExportOnly, nW, nH )
*-----------------------------------------------------------------------------*

   LOCAL sTemp, aData

   DEFAULT nExportOnly TO 0, nW TO 700, nH TO 500

   //************** Create the chart ********************** 
   oRMChart:CreateChart(hWnd, nIdChart, 10, 10, nW, nH, COLOR_ALICE_BLUE, RMC_CTRLSTYLEFLATSHADOW, nExportOnly, "", "Tahoma", 0, COLOR_DEFAULT)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Region 1 ***************************** 
   oRMChart:AddRegion(nIdChart,2,2,348,248,"",FALSE)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add grid to region 1 ***************************** 
   oRMChart:AddGrid(nIdChart,1,COLOR_BEIGE,FALSE,0,0,0,0,RMC_BICOLOR_NONE)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add data axis to region 1 ***************************** 
   oRMChart:AddDataAxis(nIdChart,1,RMC_DATAAXISLEFT,0,100,11,8,COLOR_BLACK,COLOR_BLACK,RMC_LINESTYLESOLID,0,"","","",RMC_TEXTCENTER)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add label axis to region 1 ***************************** 
   sTemp := "Label 1*Label 2*Label 3*Label 4*Label 5"
   oRMChart:AddLabelAxis(nIdChart,1, sTemp,1,5,RMC_LABELAXISBOTTOM,8,COLOR_BLACK,RMC_TEXTCENTER,COLOR_BLACK,RMC_LINESTYLESOLID,"")
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 1 to region 1 ******************************* 
   //****** Read data values ******
   aData := Array(5)
   aData[1] := 30 ; aData[2] := 40 ; aData[3] := 70 ; aData[4] = 60 ; aData[5] := 20
   oRMChart:AddBarSeries(nIdChart,1,aData, 5,RMC_BARSINGLE,RMC_BAR_3D,FALSE,COLOR_DEFAULT,FALSE,1,RMC_VLABEL_NONE,1,RMC_HATCHBRUSH_OFF)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Region 2 ***************************** 
   oRMChart:AddRegion(nIdChart,352,2,-2,248,"",FALSE) 
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add grid to region 2 ***************************** 
   oRMChart:AddGrid(nIdChart,2,COLOR_BEIGE,FALSE,0,0,0,0,RMC_BICOLOR_NONE)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add data axis to region 2 ***************************** 
   oRMChart:AddDataAxis(nIdChart,2,RMC_DATAAXISBOTTOM,0,100,11,8,COLOR_BLACK,COLOR_BLACK,RMC_LINESTYLESOLID,0,"","","",RMC_TEXTCENTER)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add label axis to region 2 ***************************** 
   sTemp := "Label 1*Label 2*Label 3*Label 4*Label 5"
   oRMChart:AddLabelAxis(nIdChart,2, sTemp,1,5,RMC_LABELAXISLEFT,8,COLOR_BLACK,RMC_TEXTCENTER,COLOR_BLACK,RMC_LINESTYLESOLID,"")
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 1 to region 2 ******************************* 
   //****** Read data values ******
   aData[1] := 20 ; aData[2] := 10 ; aData[3] := 15 ; aData[4] := 25 ; aData[5] := 30
   oRMChart:AddBarSeries(nIdChart,2,aData, 5,RMC_BARSTACKED,RMC_COLUMN_FLAT,FALSE,COLOR_DEFAULT,TRUE,1,RMC_VLABEL_NONE,1,RMC_HATCHBRUSH_OFF)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 2 to region 2 ******************************* 
   //****** Read data values ******
   aData[1] := 25 ; aData[2] := 30 ; aData[3] := 10 ; aData[4] := 20 ; aData[5] := 15
   oRMChart:AddBarSeries(nIdChart,2,aData, 5,RMC_BARSTACKED,RMC_COLUMN_FLAT,FALSE,COLOR_DEFAULT,TRUE,1,RMC_VLABEL_NONE,1,RMC_HATCHBRUSH_OFF)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 3 to region 2 ******************************* 
   //****** Read data values ******
   aData[1] := 10 ; aData[2] := 20 ; aData[3] := 40 ; aData[4] := 20 ; aData[5] := 30
   oRMChart:AddBarSeries(nIdChart,2,aData, 5,RMC_BARSTACKED,RMC_COLUMN_FLAT,FALSE,COLOR_DEFAULT,TRUE,1,RMC_VLABEL_NONE,1,RMC_HATCHBRUSH_OFF)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 4 to region 2 ******************************* 
   //****** Read data values ******
   aData[1] := 40 ; aData[2] := 30 ; aData[3] := 20 ; aData[4] := 30 ; aData[5] := 20
   oRMChart:AddBarSeries(nIdChart,2,aData, 5,RMC_BARSTACKED,RMC_COLUMN_FLAT,FALSE,COLOR_DEFAULT,TRUE,1,RMC_VLABEL_NONE,1,RMC_HATCHBRUSH_OFF)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Region 3 ***************************** 
   oRMChart:AddRegion(nIdChart,2,252,348,-2,"",FALSE)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 1 to region 3 ******************************* 
   //****** Read data values ******
   aData[1] := 30 ; aData[2] := 50 ; aData[3] := 20 ; aData[4] := 40 ; aData[5] := 60
   oRMChart:AddGridlessSeries(nIdChart,3, aData, 5,0,0,RMC_PIE_3D_GRADIENT,RMC_FULL,2,FALSE,RMC_VLABEL_DEFAULT,RMC_HATCHBRUSH_OFF, 0)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Region 4 ***************************** 
   oRMChart:AddRegion(nIdChart,352,252,-2,-2,"",FALSE)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add grid to region 4 ***************************** 
   oRMChart:AddGrid(nIdChart,4,COLOR_ALICE_BLUE,TRUE,0,0,0,0,RMC_BICOLOR_NONE)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add data axis to region 4 ***************************** 
   oRMChart:AddDataAxis(nIdChart,4,RMC_DATAAXISLEFT,100,250,11,8,COLOR_BLUE,COLOR_BLACK,RMC_LINESTYLESOLID,0,"$ ","","",RMC_TEXTCENTER) 
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add second data axis to region 4 ***************************** 
   oRMChart:AddDataAxis(nIdChart,4,RMC_DATAAXISRIGHT,0,0,0,0,0,0,0,2," %","")
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add label axis to region 4 ***************************** 
   sTemp := ""
   oRMChart:AddLabelAxis(nIdChart,4, sTemp,1,10,RMC_LABELAXISBOTTOM,8,COLOR_BLACK,RMC_TEXTCENTER,COLOR_BLACK,RMC_LINESTYLESOLID,"")
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 1 to region 4 ******************************* 
   //****** Read data values ******
   aData := Array(10)
   aData[1] := 240 ; aData[2] := 230 ; aData[3] := 220 ; aData[4] := 180 ; aData[5] := 170
   aData[6] := 160 ; aData[7] := 145 ; aData[8] := 130 ; aData[9] := 125 ; aData[10]:= 115
   oRMChart:AddBarSeries(nIdChart,4,aData, 10,RMC_BARSINGLE,RMC_BAR_FLAT_GRADIENT2,FALSE,COLOR_GOLD,FALSE,1,RMC_VLABEL_NONE,1,RMC_HATCHBRUSH_OFF)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
   //************** Add Series 2 to region 4 ******************************* 
   //****** Read data values ******
   aData[1] := 8.1 ; aData[2] := 6.2 ; aData[3] := 4.3  ; aData[4] := 2.2 ; aData[5] := 1.2
   aData[6] := 3.1 ; aData[7] := 5.2 ; aData[8] := 11.4 ; aData[9] := 7.3 ; aData[10]:= 4.2
   oRMChart:AddLineSeries(nIdChart,4, aData, 10,0,0,RMC_LINE,RMC_LINE_CABLE,RMC_LSTYLE_LINE,FALSE, ;
                                COLOR_GREEN,RMC_SYMBOL_NONE,2,RMC_VLABEL_DEFAULT,RMC_HATCHBRUSH_OFF)
   IF oRMChart:nError < 0 ; MsgStop("Error!") ; RETURN NIL ; ENDIF
 
   oRMChart:SetWatermark( RMC_USERWM, RMC_USERWMCOLOR, RMC_USERWMLUCENT, RMC_USERWMALIGN, RMC_USERFONTSIZE )

   RETURN NIL
