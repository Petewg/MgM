/*
https://developers.google.com/chart/image/docs/making_charts
*/

#include "hmg.ch"

MEMVAR aTypes

Function Main()

Local aRows[6], aCombo:={}

aRows [1]	:= {'Simpson',5}
aRows [2]	:= {'Mulder',30} 
aRows [3]	:= {'Smart',50} 
aRows [4]	:= {'Grillo',120} 
aRows [5]	:= {'Kirk',90} 
aRows [6]	:= {'Barriga',200}

PRIVATE aTypes [5]
aTypes [1] := {"Pie","p"}
aTypes [2] := {"Pie 3D", "p3"}
aTypes [3] := {"Line", "lc"}
aTypes [4] := {"Line sparkless", "ls"}
aTypes [5] := {"Bar", "bvg"}

AEVAL(aTypes, { |x| AADD( aCombo, x[1]) } )

DEFINE WINDOW Win_1 AT 192 , 422 WIDTH 550 HEIGHT 350 TITLE "Google Chart Static Sample" MAIN

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

	@ 150, 390 BUTTON Button_1 ;
		CAPTION "Generate" ;
		ACTION GoogleChartApi_() ;
		WIDTH  100 HEIGHT 28 

	@ 150, 20 IMAGE Image_1 ;
		PICTURE "" ;
		WIDTH 360 HEIGHT 150 STRETCH
		
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

FOR i=1 TO Win_1.Grid_1.ItemCount

	cChartData  += Alltrim(hb_valToStr(Win_1.Grid_1.Cell( i, 2 )))
	cChartLabel += Alltrim(hb_valToStr(Win_1.Grid_1.Cell( i, 1 )))
	
	IF i < Win_1.Grid_1.ItemCount
		cChartData += ","
		cChartLabel += "|"
	ENDIF
NEXT i


//Init
BEGIN SEQUENCE WITH {|o| break(o)}
	oGoogle := Win_OleCreateObject( "MSXML2.ServerXMLHTTP" )

RECOVER
     MsgStop( "Microsoft XML Core Services (MSXML) 6.0 is not installed.")
     oGoogle:=""

END SEQUENCE

IF EMPTY(oGoogle)
	MsgStop("Error while init.")
	RETURN 
ENDIF

cPOSTdata := "cht=" + cChartType + "&chs=" + cChartWidth + "x" + cChartHeight + ;
		"&chd=t:" + cChartData + "&chl=" + cChartLabel + "&chds=a" 

//Sending POST
BEGIN SEQUENCE WITH {|o| break(o)}
	oGoogle:Open( "POST", cApiUrl, .F. )
	oGoogle:Send( cPOSTdata )
	cGoogleResp := oGoogle:ResponseBody()

	IF oGoogle:Status != 200
		BREAK
	ENDIF
	STRFILE( cGoogleResp , 'GoogleChart.png' )

RECOVER
	MsgStop("ERROR! " + CRLF + cGoogleResp)
	RETURN
 
END SEQUENCE
 	
//Close
oGoogle:Abort()

Win_1.Image_1.Width := Val(cChartWidth)
Win_1.Image_1.Height := Val(cChartHeight)
Win_1.Image_1.Picture := 'GoogleChart.png'

RETURN 
