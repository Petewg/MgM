#include "hmg.ch"

PROCEDURE Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 350 ;
		HEIGHT 300 ; 
		TITLE 'Get Desktop Font Size (DPI)' ; 
		MAIN 
		@ Form_1.Height / 2 - 50 , Form_1.Width / 2 - 80 BUTTON Button_1 ;
		CAPTION "Determine DPI font size" WIDTH 140 HEIGHT 30 ACTION GetDPIFontSize()
	END WINDOW 
	Form_1.Center
	Form_1.Activate
	RETURN

PROCEDURE GetDPIFontSize()
	LOCAL nDpi := Asc( GetRegistryValue( HKEY_CURRENT_USER, "Control Panel\Desktop", "LogPixels" ) )
	LOCAL cSize
   // LOCAL nDpi := Asc(GetRegistryValue( HKEY_CURRENT_USER, "Control Panel\Desktop\WindowMetrics", "AppliedDPI" ) )
	
	IF     nDpi ==  96 ;		cSize := "Small"
	ELSEIF nDpi == 120 ;		cSize := "Medium"
	ELSEIF nDpi == 144 ;		cSize := "Large"
	ELSE               ;		cSize := "Custom"
	ENDIF
	
	MsgInfo("Current Font Size: " + cSize + " (" + hb_NtoS( nDpi ) + " dpi)" )

	RETURN
	