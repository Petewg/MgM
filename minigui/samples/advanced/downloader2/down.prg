/*
   Simple http downloader.
   Copyright (c) 2017 by Pete D. <pete_westg@yahoo.gr>
   Licence: CC BY-SA 4.0
*/

#include "hmg.ch"

PROCEDURE Main()

	LOAD WINDOW downWin

	CENTER WINDOW downWIn
	
   SetProperty( "downWin", "txt_URL", "Value", "https://codeload.github.com/Petewg/MgM/zip/master" )

	ACTIVATE WINDOW downWin
	
	RETURN

PROCEDURE GetHeaders( cURL )

	LOCAL oServer, nTries, cHeaders
	
	hb_Default( @cUrl, AllTrim( GetProperty( "downWin", "txt_URL", "Value" ) ) )
	
	If Empty( cURL )
		RETURN
	Endif
	
   oServer := Win_OleCreateObject( "MSXML2.ServerXMLHTTP.6.0" )
	nTries := 103
	
	cHeaders := ""
	WHILE --nTries >= 0 .AND. Empty( cHeaders )
	
		oServer:Open( "HEAD", cURL, .f. )
		oServer:Send()
		cHeaders := oServer:getAllResponseHeaders()
      
      If ! Empty( cHeaders )
         If Val( oServer:getResponseHeader("Content-Length") ) != 0
            Exit
         Else
            cHeaders := ""
         Endif
      Endif
     		
	END
   /*
   If Val( oServer:getResponseHeader("Content-Length") ) == 0
      oServer:Open( "HEAD", cURL, .f. )
		oServer:Send()
		cHeaders := oServer:getAllResponseHeaders()
   Endif
   */   
   
	SetProperty( "downWin", "lbl_Size", "Value", ;
	              Transform( Val( oServer:getResponseHeader("Content-Length") ) / 1024, "@E 999,999.99") )
		
	SetProperty( "downWin", "Edit_1", "Value", cHeaders )
			
	oServer := NIL

	RETURN


FUNCTION DownloadFile( cUrl, cLocalFile )

   LOCAL oServer, nBytesReceived, xReceived, nHandle, nSec, nFileSize
 
   hb_Default( @cUrl, AllTrim( GetProperty( "downWin", "txt_URL", "Value" ) ) )
	hb_Default( @cLocalFile, "mgm.7z" )
	
	oServer := Win_OleCreateObject( "MSXML2.ServerXMLHTTP.6.0" )
	
   /*
	oServer:Open( "HEAD", cUrl, .f. )
   oServer:Send()
   nFileSize := Val( oServer:getResponseHeader("Content-Length") ) / 1024
	*/
		
   IF ! MsgYesNo( "Ok to download?", "Please Confirm" )
		RETURN .F.
	ENDIF
   
   oServer:Open( "GET", cUrl, .t. ) // .t. = asynchronous call, which means it returns immediately.
                                    // (https://msdn.microsoft.com/en-us/library/ms763809(v=vs.85).aspx)
                                    // We want this, for to provide the user a basic progress output,
                                    // basically, displaying the time elapsing during download
	oServer:Send()
   
	nSec := 1
	
   WHILE (oServer:readyState != 4) // https://msdn.microsoft.com/en-us/library/ms761388(v=vs.85).aspx
      oServer:waitForResponse( 1 )   // seconds
		SetProperty( "downWin", "lbl_Time", "Value", hb_ntos( nSec++ ) )
   END
   
   IF ! ( oServer:status == 200 )
      MsgExclamation( "Error: " + hb_ntos( oServer:status ) + " " + oServer:responseText, "Error!" )
      RETURN .F.
   ENDIF
   
   // oServer:onreadystatechange := @doHttpReadyStateChange()
   xReceived := oServer:ResponseBody()
   nBytesReceived := Len( xReceived )
	
	
   // ? "Server response was : ", oServer:status, oServer:responseText
   MsgInfo( "Total bytes received: " + hb_eol() + Transform( nBytesReceived, "@E 999,999,999,999.99 bytes" ) )
   
   nHandle := FCreate( cLocalFile )
         
   IF ValType( xReceived ) == "C"
   
      fWrite( nHandle, xReceived )
      
   ELSEIF ValType( xReceived ) == "A"

      AEVal( xReceived, {|b| FWrite( nHandle, Chr( b ) ) } )

   ENDIF
   
   FClose( nHandle )
   
   // wait "press a key to show received data"
   
   hb_ProcessRun( "cmd.exe /c start " + cLocalFile )
      
   RETURN .T.
	
 /*
 =============================================
#define CRLF Chr(10)
request hb_codepage_utf8ex, hb_codepage_elwin
STATIC oSoap
PROCEDURE Main( cURL )

   LOCAL cPath AS STRING := hb_CWD()
   
   hb_cdpselect( "ELWIN" )

   // SoapDownloadFile( "https://www.github.com/vszakats/harbour-core/releases/download/v3.4.0dev/harbour-snapshot-win.7z", cPath+"snap.7z" )
   hb_Default( @cURL, "https://codeload.github.com/Petewg/MgM/zip/master" )
   SoapDownloadFile( cURL )

   RETURN


FUNCTION SoapDownloadFile( cURL, cFile )
   LOCAL nBytesReceived, xReceived, nHandle, nSec
   local aHeaders
 
   oSoap := Win_OleCreateObject( "MSXML2.ServerXMLHTTP.6.0" )
   oSoap:Open( "HEAD", cURL, .f. )
   oSoap:Send()
   cls
   ? "File size to download: ", Val( oSoap:getResponseHeader("Content-Length") ) / 1024 , " Kbytes"
   ? "Content-Type", oSoap:getResponseHeader("Content-Type")
   ? "status", oSoap:Status, oSoap:StatusText //responseText(  )
   ? "Location", oSoap:GetResponseHeader("Location")
   aHeaders := hb_ATokens( oSoap:getAllResponseHeaders(), hb_eol() )
   AEval( aHeaders, {|e| Qout(e)} )
   ? "=============="
   ? "Server Options: ", oSoap:getOption(-1),oSoap:getOption(0),oSoap:getOption(1),oSoap:getOption(2),oSoap:getOption(3)
   ? "=============="
   ? 
   
   ? "Ok to download? (y/N)"
   
   If Chr( Inkey(0) ) != "y"
      quit
   Endif
   
   oSoap:Open( "GET", "cURL", .t. ) // asynchronous to 
   oSoap:Send()
   ? "Downloading (press Esc to abort)"
   ?
   nSec := 1
   while (oSoap:readyState != 4) // https://msdn.microsoft.com/en-us/library/ms761388(v=vs.85).aspx
   
      oSoap:waitForResponse( 1 )   // seconds
      // @ Row(), 0 SAY "Time elapsed: " + hb_ntos( nSec++ ) + " seconds."
      ?? "•"
      nSec ++
      If Inkey() == 27
         oSoap:Abort()
         ? "download aborted by user"
         quit
      Endif
     
   end
   ? "Time elapsed: " + hb_ntos( nSec++ ) + " seconds."
   if !(oSoap:status == 200)
      ? "Error: ", oSoap:status, oSoap:StatusText
      quit
   endif
   
   // oSoap:onreadystatechange := @doHttpReadyStateChange()
   xReceived := oSoap:ResponseBody()
   nBytesReceived := Len( xReceived )
   ? "Server response was : ", oSoap:status, oSoap:StatusText
   ? "Total bytes received: ", trans( nBytesReceived, "@E 999,999,999,999.99 bytes" )
   
   nHandle := FCreate( "mgm.7z" )
         
   IF ValType( xReceived ) == "C"
   
      fWrite( nHandle, xReceived )
      
   ELSEIF ValType( xReceived ) == "A"

      AEVal( xReceived, {|b| FWrite( nHandle, Chr( b ) ) } )

   ENDIF
   
   FClose( nHandle )
   
   wait "press a key to show received data"
   
   hb_ProcessRun( "cmd.exe /c start mgm.7z" )
      
   RETURN
   

=============================================

best regards,
 
 ---
 Pete
 */  
