#include "hmg.ch"

DECLARE WINDOW WinMain
FUNCTION Main()
	
	SET AUTOADJUST ON 
	
	DEFINE WINDOW WinMain ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 420 ;
		TITLE 'Socket Test' ;
		MAIN 
		
		DEFINE EDITBOX Edit_1
			COL 10 
			ROW 10 
			WIDTH  300
			HEIGHT 360
			VALUE ""
			READONLY .T.
		END EDITBOX
		
		DEFINE BUTTON Button_1 
			COL 320
			ROW 10
			WIDTH 60
			HEIGHT 30
			CAPTION "Connect"
			ACTION Connect()
		END BUTTON
		
	END WINDOW
		
	CENTER WINDOW WinMain
		
	ACTIVATE WINDOW WinMain
		
	RETURN NIL

FUNCTION Connect( cProxy, nProxyPort )
	LOCAL oSock
	LOCAL cServer  :=  "harbour.github.io" // "support.google.com" // "www.google.com" // "localhost"  // https://support.google.com/blogger/answer/76315/?hl=en
	LOCAL nPort    := 80               // 8080         //
	LOCAL cText    := ""
	LOCAL Eol := hb_EoL() + hb_EoL()
	LOCAL cPage

	hb_Default( @nProxyPort, "8080" )

	oSock := THttp():New()
	IF cProxy != NIL
		oSock:SetProxy( cProxy, VAL(nProxyPort) )
	ENDIF
	
	cText += "Connecting to " + cServer + ":" + AllTrim( Str( nPort ) ) + Eol + "Please wait..." + Eol 
	
	WinMain.Edit_1.Value := cText
	
	IF oSock:Connect( cServer, nPort )
		
		cText += "Connected!" + Eol 
		
		WinMain.Edit_1.Value := cText

		cText += "Let's get a page" + Eol
		
		WinMain.Edit_1.Value := cText
	
		// cPage := oSock:Get( "/intl/en/policies/privacy/" )
		// cPage := oSock:Get( "/blogger/answer/76315")
		// cPage := oSock:Get( "/safetycenter/tools/#help-keep-the-blogosphere-safe-for-all" )
		
		cPage := oSock:Get( "/index.html" )
		
		// WinMain.Edit_1.Value := cText + Eol 

		cText += "Closing connection" + Eol
		WinMain.Edit_1.Value := cText
		
		IF oSock:Close()
			
			cText +=  "Close successfull" + Eol
			WinMain.Edit_1.Value := cText
		
		ELSE
		
			cText += "Error on close connection" + Eol
			WinMain.Edit_1.Value := cText

		ENDIF
		
		IF ! Empty(cPage)
		
			IF MsgYesNo( "Browse page? ")
				MemoWrit( "Page.html", SubStr(cPage, hb_AtI( "<!DOCTYPE html>", cPage ) ) )	
				wapi_Shellexecute( 0, "open", "Page.html")
			ENDIF
			
		ENDIF

	ELSE
	
		cText += "The connection refused by server..." + Eol
		WinMain.Edit_1.Value := cText
	
	ENDIF
	
	RETURN NIL
	
