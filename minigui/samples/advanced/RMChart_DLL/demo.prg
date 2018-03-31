/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2008 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Revised by Antonio Carlos <acdornelas@bol.com.br>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "dll32.ch"

#define APP_TITLE "Example RMCHART"

#define ID_CHART   1001
#define ID_CHART_2 1002

Static hInstDLL, lDraw := .F.

*-----------------------------------------------------------------------------*
Procedure Main
*-----------------------------------------------------------------------------*
    Local sTemp := "" 

    sTemp += "00003650|00004450|000051|000061|000071|00008-6697831|00009401|00011Tahoma|100011"
    sTemp += "|1000310|1000410|10005-5|10006-5|1000910|100101|100111|100121|100131|100181|1002"
    sTemp += "00|100217|1002215|100238|100272|100331|100341|100358|100378|100411|100482|100492"
    sTemp += "|10051-6751336|10052-15132304|10053-983041|100541|100558|10056-16777077|10057-16"
    sTemp += "777077|100586|10060-16777077|10061-1468806|100622|10180data source: www.federalr"
    sTemp += "eserve.gov + www.ecb.int|10181Prime Rates in USA and Euroland|10183 %|101871999*"
    sTemp += "2000*2001*2002*2003*2004*2005*2006|110011|1100221|110035|1100434|110052|110063|1"
    sTemp += "10073|1100970|1101312|110171|11019-16744448|1102115|110221|1102396|110262|110521"
    sTemp += "2|110534.75*4.75*4.75*4.75*4.75*5*5*5.25*5.25*5.25*5.5*5.5*5.5*5.75*6*6*6.5*6.5*"
    sTemp += "6.5*6.5*6.5*6.5*6.5*6.5*5.5*5.5*5*4.5*4*3.75*3.75*3.5*3*2.5*2*1.75*1.75*1.75*1.7"
    sTemp += "5*1.75*1.75*1.75*1.75*1.75*1.75*1.75*1.25*1.25*1.25*1.25*1.25*1.25*1.25*1*1*1*1*"
    sTemp += "1*1*1*1*1*1*1*1*1*1*1.25*1.5*1.75*2*2.25*2.25*2.5*2.75*2.75*3*3.25*3.25*3.5*3.75"
    sTemp += "*3.75*4*4.25*4.5*4.5*4.75*4.75*5*5.25*5.25*5.25*5.25*5.25*5.25*5.25|120011|12002"
    sTemp += "21|120035|1200434|120052|120063|120073|1200950|1201312|120171|12019-2448096|1202"
    sTemp += "115|120221|1202396|120262|1205212|120533*3*3*2.5*2.5*2.5*2.5*2.5*2.5*2.5*3*3*3*3"
    sTemp += ".25*3.5*3.75*3.75*4.25*4.25*4.5*4.5*4.75*4.75*4.75*4.75*4.75*4.75*4.75*4.5*4.5*4"
    sTemp += ".5*4.25*3.75*3.75*3.25*3.25*3.25*3.25*3.25*3.25*3.25*3.25*3.25*3.25*3.25*3.25*3."
    sTemp += "25*2.75*2.75*2.75*2.5*2.5*2.5*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*2*"
    sTemp += "2*2*2*2*2*2.25*2.25*2.25*2.5*2.5*2.5*2.75*2.75*3*3*3.25*3.25*3.5|010011|010054|0"
    sTemp += "100721|01014-16744448|010222|01024216*287|01025109*109|010272|010283|010012|0100"
    sTemp += "51|01010295|01011102|010191|01026USA (Federal Funds Rate)|010013|010054|0100721|"
    sTemp += "01014-10496|010222|01024260*287|01025192*192|010272|010283|010014|010051|0101029"
    sTemp += "5|01011185|010191|01026Euroland (Prime Rate)"

	SET FONT TO "Times New Roman" , 10

        hInstDLL := LoadLibrary('rmchart.DLL')

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 680 ;
		HEIGHT 550 ;
		TITLE APP_TITLE ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON RELEASE FreeLibrary(hInstDLL) ;
		ON INTERACTIVECLOSE IF( MsgYesNo("Really want to quit ?", "Exit"), EndWindow(.f.), .F. )

		@ 475, 100 BUTTON Btn_Chart ;
			CAPTION "RMCHART" ;
			ACTION Chart(sTemp) ;
			WIDTH 150 HEIGHT 30 DEFAULT

		@ 475, 270 BUTTON Btn_Print ;
			CAPTION "PRINT" ;
			ACTION PrintChart(sTemp) ;
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
Procedure Chart(sTemp)
*-----------------------------------------------------------------------------*

    IF !lDraw
        lDraw := .T.
        CreateChart(GetFormHandle("Win_1"), ID_CHART, 10, 10, 0, sTemp)
        DrawChart(ID_CHART)
    ENDIF

Return

#define RMC_DEFAULT   O
#define RMC_PORTRAIT  1
#define RMC_LANDSCAPE 2

#define RMC_EMF       1
#define RMC_EMFPLUS   2
#define RMC_BMP       3

*-----------------------------------------------------------------------------*
Procedure PrintChart(sTemp)
*-----------------------------------------------------------------------------*

    CreateChart(GetFormHandle("Win_1"), ID_CHART_2, 10, 10, 1, sTemp)

    //IF Draw2Printer(ID_CHART, RMC_LANDSCAPE) < 0
    IF Draw2Printer(ID_CHART_2, RMC_LANDSCAPE, 10, 10, 250, 150, RMC_EMFPLUS) < 0
       MsgStop("Print error!", "Error")
    ENDIF

    DeleteChart(ID_CHART_2)

Return

*-----------------------------------------------------------------------------*
Procedure endwindow(lClose)
*-----------------------------------------------------------------------------*
    Default lClose To .T.

    IF lDraw
        DeleteChart(ID_CHART)
    ENDIF

    IF lClose
        Win_1.Release
    ENDIF

Return

*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_LONG RMC_CREATECHARTFROMFILE( DLL_TYPE_LONG hWnd, DLL_TYPE_LONG ChartId, ;
	DLL_TYPE_LONG nX, DLL_TYPE_LONG nY, DLL_TYPE_LONG nExportOnly, DLL_TYPE_LPSTR sRMCFile ) ;
	ALIAS CreateChart IN hInstDLL

*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_LONG RMC_DRAW( DLL_TYPE_LONG ChartId ) ;
	ALIAS DrawChart IN hInstDLL

*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_LONG RMC_DELETECHART( DLL_TYPE_LONG ChartId ) ;
	ALIAS DeleteChart IN hInstDLL

*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_LONG RMC_DRAW2PRINTER( DLL_TYPE_LONG nChartId, DLL_TYPE_LONG nPrintDC, ;
	DLL_TYPE_LONG nLeft, DLL_TYPE_LONG nTop, DLL_TYPE_LONG nWidth, DLL_TYPE_LONG nHeight, DLL_TYPE_LONG nType ) ;
	ALIAS Draw2Printer IN hInstDLL
