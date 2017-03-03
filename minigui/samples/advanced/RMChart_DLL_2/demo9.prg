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

#define APP_TITLE "Example 9 RMCHART"

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
        Graphic9( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic9( hWnd, oRMChart, ID_CHART_2, .T. )

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
FUNCTION Graphic9( hWnd, oRMChart, nIdChart, nExportOnly, nW, nH )
*-----------------------------------------------------------------------------*

   LOCAL aColor, aData, sTemp

   DEFAULT nExportOnly TO .F., nW TO 650, nH TO 450

   oRMChart:CreateChart( hWnd, nIdChart, 10, 10, nW, nH, COLOR_TRANSPARENT, RMC_CTRLSTYLEFLAT, nExportOnly, "", "Tahoma", 0, COLOR_DEFAULT )
   ORMChart:AddRegion( nIdChart, 5, 5, -5, -5, "", .F. )
   aColor := { COLOR_MAROON, COLOR_MEDIUM_BLUE, COLOR_CRIMSON, COLOR_DEFAULT }
   aData := { 80, 50, 60, 30 }
   oRMChart:AddGridlessSeries(nIdChart, 1, aData, 4, aColor, 4, RMC_PIE_3D_GRADIENT, RMC_HALF_TOP, 0, .F., RMC_VLABEL_NONE, RMC_HATCHBRUSH_OFF, 0)
   sTemp := "This is a 3D pie with semicircle alignment, tooltips, a custom text" + Chr(10) + Chr(13) + "and a discreet watermark."
   oRMChart:COText( nIdChart, 1, sTemp, 100, 270, 400, 50, RMC_BOX_3D_SHADOW, COLOR_MOCCASIN, COLOR_DEFAULT, 0, RMC_LINE_HORIZONTAL, COLOR_MAROON, "09C" )
   oRMChart:SetWatermark( "RMChart", COLOR_AUTUMN_ORANGE, 25, 1, RMC_USERFONTSIZE ) 
   RETURN NIL
