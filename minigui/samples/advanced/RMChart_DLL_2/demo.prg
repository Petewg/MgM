/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 Grigory Filatov <gfilatov@inbox.ru>
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "rmchart.ch"

#define APP_TITLE "Example RMCHART"

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
        Graphic1( hWnd, oRMChart, ID_CHART )
        oRMChart:Draw( ID_CHART )
    ENDIF

Return

#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

*-----------------------------------------------------------------------------*
Procedure PrintChart( hWnd )
*-----------------------------------------------------------------------------*

   Graphic1( hWnd, oRMChart, ID_CHART_2, 1 )

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
FUNCTION AMax( x )
*-----------------------------------------------------------------------------*

   LOCAL nVal, oElement

   nVal := x[ 1 ]
   FOR EACH oElement IN x
      IF oElement > nVal
         nVal := oElement
      ENDIF
   NEXT

   RETURN nVal

*-----------------------------------------------------------------------------*
FUNCTION Graphic1( hWnd, oRMChart, nIdChart, nExportOnly, nW, nH )
*-----------------------------------------------------------------------------*

   LOCAL cLegenda, cLabels, cTitulo, aDados, cUnidade, cTextoVert, nMax, oElement, nCont

   DEFAULT nExportOnly TO 0, nW TO 650, nH TO 450

   cLegenda   := "Entradas*Saidas*Mais Um"
   cLabels    := "Janeiro*Fevereiro*Março*Abril*Maio*Junho*Julho*Agosto*Setembro*Outubro*Novembro*Dezembro"
   cTitulo    := "Gráfico de Teste"
   aDados     := { ;
                 { 225.25, 100.00, 100.00, 150.00, 250.00, 300.00, 25.00, 75.00, 300.00, 200.00, 325.00, 300.00 }, ;
                 { 220.00, 100.00, 125.00, 300.00, 150.00, 125.00, 85.00, 50.00, 285.00, 275.00, 295.00, 280.00 }, ;
                 { 125.25, 100.00, 100.00, 150.00, 250.00, 300.00, 25.00, 75.00, 300.00, 200.00, 325.00, 300.00 } }
   cUnidade   := "R$ "
   cTextoVert := ""
   nMax       := 0

   FOR EACH oElement IN aDados
      nMax := Max( nMax, aMax( oElement ) )
   NEXT

   nMax := Round( ( Int( nMax / 10 ) * 10 ) + 10, 2 )

   oRMChart:CreateChart( hWnd, nIdChart, 10, 10, nW, nH, COLOR_AZURE, RMC_CTRLSTYLE3DLIGHT, nExportOnly, "", "", 0, 0 )
   oRMChart:AddRegion( nIdChart, 0, 0, nW, nH, "RmChart", .F. )
   oRMChart:AddCaption( nIdChart, 1, cTitulo, COLOR_TRANSPARENT, COLOR_RED, 9, .T. )
   oRMChart:AddGrid( nIdChart, 1, COLOR_LIGHT_BLUE, .F., 20, 20, nW - 100, nH - 100, RMC_BICOLOR_LABELAXIS )
   oRMChart:AddLabelAxis( nIdChart, 1, cLabels, 1, Len( aDados[ 1 ] ), RMC_LABELAXISBOTTOM, 8, COLOR_BLACK, RMC_TEXTCENTER, COLOR_BLACK, RMC_LINESTYLENONE, "" )
   oRMChart:AddDataAxis( nIdChart, 1, RMC_DATAAXISRIGHT, 0.0, nMax, Len( aDados[ 1 ] ), 8, COLOR_BLACK, COLOR_BLACK, RMC_LINESTYLESOLID, 1, cUnidade, cTextoVert, "", RMC_TEXTCENTER )
   oRMChart:AddLegend( nIdChart, 1, cLegenda, RMC_LEGEND_BOTTOM, COLOR_TRANSPARENT, RMC_LEGENDNORECT, COLOR_RED, 8, .T. )

   FOR nCont = 1 TO Len( aDados )
      oRMChart:AddBarSeries( nIdChart, 1, aDados[ nCont ], 12, RMC_BARGROUP, RMC_BAR_FLAT_GRADIENT2, .F., 0, .F., 1, RMC_VLABEL_NONE, nCont, RMC_HATCHBRUSH_ONPRINTING )
   NEXT

   RETURN NIL
