/*
 * MINIGUI - Harbour Win32 GUI library Demo
*/

#include "minigui.ch"

Function Main
	Local d1:=Date()-30, d2:=Date()+1

	SET CENTURY ON
	SET DATE BRITISH

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 HEIGHT 400 ;
		TITLE "MiniGUI DatePicker Demo 2" ;
		MAIN ;
		FONT "Arial" SIZE 10

		DEFINE DATEPICKER Date_1
			ROW	10
			COL	10
			VALUE Date()
			RANGEMIN d1
			RANGEMAX d2
			TOOLTIP 'DatePicker Control With Dates Range'
			SHOWNONE .F.
		END DATEPICKER

		@ 09,140 BUTTON Button_1 ;
		CAPTION "Set Date Range" ;
		WIDTH 120 HEIGHT 26 ;
		ACTION ( Form_1.Date_1.RangeMin := date()-7, Form_1.Date_1.RangeMax := date()+7 )

		@ 40,140 BUTTON Button_2 ;
		CAPTION "Get Date Range" ;
		WIDTH 120 HEIGHT 26 ;
		ACTION MsgInfo ( GetDateRange ( "Date_1" ) ) 

		@ 71,140 BUTTON Button_3 ;
		CAPTION "Erase Date Range" ;
		WIDTH 120 HEIGHT 26 ;
		ACTION ( Form_1.Date_1.RangeMin := 0, Form_1.Date_1.RangeMax := 0, PlayBeep() )

		@ 10,310 DATEPICKER Date_2 ;
		VALUE Date() ;
		TOOLTIP "DatePicker Control ShowNone RightAlign" ;
		RANGE d1, d2 ;
		SHOWNONE ;
		RIGHTALIGN

		@ 09,440 BUTTON Button_21 ;
		CAPTION "Get Date Range" ;
		WIDTH 120 HEIGHT 26 ;
		ACTION MsgInfo ( GetDateRange ( "Date_2" ) )

		@ 230,10 DATEPICKER Date_3 ;
		VALUE Date() ;
		TOOLTIP "DatePicker Control UpDown" ;
		UPDOWN

		@ 229,140 BUTTON Button_4 ;
		CAPTION "Get Min Date" ;
		WIDTH 120 HEIGHT 26 ;
		ACTION MsgInfo ( Form_1.Date_3.RangeMin, "Min Value" ) 

		@ 230,310 DATEPICKER Date_4 ;
		VALUE Date() ;
		TOOLTIP "DatePicker Control ShowNone UpDown" ;
		SHOWNONE ;
		UPDOWN

		@ 229,440 BUTTON Button_5 ;
		CAPTION "Get Max Date" ;
		WIDTH 120 HEIGHT 26 ;
		ACTION MsgInfo ( Form_1.Date_4.RangeMax, "Max Value" ) 

	END WINDOW

	Form_1.Date_3.RangeMin := date()-7  // set min value only for Date_3
	Form_1.Date_4.RangeMax := date()+7  // set max value only for Date_4

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Function  GetDateRange ( cDatePick )
	Local cRet := "", dVal := GetProperty( 'Form_1', cDatePick, "RangeMin" )

	If ! Empty(dVal)
		cRet += DtoC( dVal ) + CRLF + ;
			DtoC( GetProperty( 'Form_1', cDatePick, "RangeMax" ) )
	Else
		cRet := "DatePicker " + cDatePick + " Have Not A Date Range!"
	EndIf

Return cRet
