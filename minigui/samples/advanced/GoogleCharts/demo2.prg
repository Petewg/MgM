/*
https://developers.google.com/chart/
*/

#include "hmg.ch"

MEMVAR aTypes

Function Main()

Local aRows[6], aCombo:={}, oActiveX

aRows [1]	:= {'Simpson',5}
aRows [2]	:= {'Mulder',30} 
aRows [3]	:= {'Smart',50} 
aRows [4]	:= {'Grillo',120} 
aRows [5]	:= {'Kirk',90} 
aRows [6]	:= {'Barriga',200}

PRIVATE aTypes [5]
aTypes [1] := {"Pie","PieChart"}
aTypes [2] := {"Pie 3D", "PieChart3D"}
aTypes [3] := {"Line", "LineChart"}
aTypes [4] := {"Bar", "BarChart"}
aTypes [5] := {"Column", "ColumnChart"}

AEVAL(aTypes, { |x| AADD( aCombo, x[1]) } )

DEFINE WINDOW Win_1 AT 192 , 422 WIDTH 600 HEIGHT 400 TITLE "Google Chart Html Sample" MAIN

	@ 20,20 GRID Grid_1 ;
		WIDTH 300 ;
		HEIGHT 110 ;
		HEADERS {'Label','Data'} ;
		WIDTHS {100,100};
		ITEMS aRows ;
		COLUMNCONTROLS { { 'TEXTBOX', 'CHARACTER' }, { 'TEXTBOX', 'NUMERIC', '9999' } } ;
		VALUE {1,1} ;
		EDIT ;
		CELLNAVIGATION 

	@ 20, 390 COMBOBOX Combo_1 ;
		WIDTH  135 ;
		HEIGHT 194 ;
		ITEMS aCombo ;  
		VALUE 1

	@ 60,390 TEXTBOX t_Width ;
		VALUE 360 ;
		NUMERIC INPUTMASK "999" 

	@ 100,390 TEXTBOX t_Height ;
		VALUE 150 ;
		NUMERIC INPUTMASK "999" 

	@ 20,340 LABEL Label_1 ;
		WIDTH 50 HEIGHT 20 ;
		VALUE 'Type'

	@ 60,340 LABEL Label_2 ;
		WIDTH 50 HEIGHT 20 ;
		VALUE 'Width'
    
	@ 100,340 LABEL Label_3 ;
		WIDTH 50 HEIGHT 20 ;
		VALUE 'Height'

	@ 150, 460 BUTTON Button_1 ;
		CAPTION "Generate" ;
		ACTION GoogleChartApi_() ;
		WIDTH 100 HEIGHT 28 


    DEFINE ACTIVEX Activex_1
        ROW    150
        COL    20
        WIDTH  430
        HEIGHT 200
        PROGID "shell.explorer.2"
    END ACTIVEX

END WINDOW

HMG_ChangeWindowStyle(GetControlHandle("Activex_1","Win_1"), WS_EX_CLIENTEDGE, NIL, .T.)
oActiveX:= GetProperty('Win_1','Activex_1','XObject')
oActiveX:Silent := 1

END WINDOW

CENTER WINDOW Win_1

ACTIVATE WINDOW Win_1

Return Nil

****************************************************************************************
PROCEDURE GoogleChartApi_()

Local cApiUrl := "https://chart.googleapis.com/chart"
Local cPOSTdata := ""
LOCAL oGoogle, cGoogleResp
Local cChartType := aTypes [Win_1.Combo_1.Value] [2]
Local cChartWidth := Alltrim(STR( Win_1.t_Width.Value ) )
Local cChartHeight := Alltrim(STR( Win_1.t_Height.Value ) )
Local i, cChartData := "", cChartLabel := ""
Local cHeaders := "User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)"
Local cHtmlFile := "GoogleChart.html"
Local cHtmlString := ""
Local oActiveX 

cHtmlString += '<html>  <head>' + CRLF + '<!--Load the AJAX API-->'  + CRLF
cHtmlString += '<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>' + CRLF
cHtmlString += '<script type="text/javascript">' + CRLF 
cHtmlString += '// Load the Visualization API and the corechart package.' + CRLF
cHtmlString += "google.charts.load('current', {'packages':['corechart']});" + CRLF
cHtmlString += '// Set a callback to run when the Google Visualization API is loaded.' + CRLF
cHtmlString += 'google.charts.setOnLoadCallback(drawChart);' + CRLF
cHtmlString += '// Callback that creates and populates a data table, instantiates the chart, passes in the data and draws it.' + CRLF
cHtmlString += 'function drawChart() {' + CRLF
cHtmlString += '// Create the data table.' + CRLF
cHtmlString += 'var data = new google.visualization.DataTable();' + CRLF
cHtmlString += "data.addColumn('string', 'Topping');" + CRLF
cHtmlString += "data.addColumn('number', 'Slices');" + CRLF
cHtmlString += "data.addRows([" + CRLF

FOR i=1 TO Win_1.Grid_1.ItemCount
	
	cHtmlString += "['" + Alltrim(hb_valToStr(Win_1.Grid_1.Cell( i, 1 ))) + "', " + Alltrim(hb_valToStr(Win_1.Grid_1.Cell( i, 2 ))) + "]"
	IF i < Win_1.Grid_1.ItemCount
		cHtmlString += ","
	ENDIF
	
	cHtmlString += CRLF
NEXT i

cHtmlString += "]);" + CRLF
cHtmlString += '// Set chart options' + CRLF
cHtmlString += "var options = {'title':'Sample Google Chart'," + CRLF
IF cChartType == 'PieChart3D'
	cHtmlString += "    'is3D': true,"
	cChartType := 'PieChart'
ENDIF
	
cHtmlString += "               'width':" + cChartWidth + "," + CRLF
cHtmlString += "               'height':" + cChartHeight + "};" + CRLF
cHtmlString += '// Instantiate and draw our chart, passing in some options.' + CRLF
cHtmlString += "var chart = new google.visualization." + cChartType + "(document.getElementById('chart_div'));" + CRLF
cHtmlString += "chart.draw(data, options);" + CRLF
cHtmlString += "}" + CRLF
cHtmlString += '</script>  </head>' + CRLF
cHtmlString += '<body>' + CRLF
cHtmlString += '<!--Div that will hold the chart-->' + CRLF 
cHtmlString += '<div id="chart_div"></div>' + CRLF
cHtmlString += '</body> </html>'

STRFILE( cHtmlString, cHtmlFile )

Win_1.Activex_1.Width := Val(cChartWidth) + 50
Win_1.Activex_1.Height := Val(cChartHeight) + 50

oActiveX:= GetProperty('Win_1','Activex_1','XObject')
oActiveX:Silent := 1
oActiveX:Navigate( "file:///" + GetCurrentFolder() + "\" + cHtmlFile , , , , cHeaders )

RETURN 
