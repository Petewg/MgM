/*
 * Proyecto: Serivios
 * Descripción: Muestra información relativa a los servicios de Windows
 * Autor: Rafa Carmona
 * Fecha: 07/22/08
 *
 * Adapted by Grigory Filatov <gfilatov@inbox.ru>
 *
 * Revised by Evangelos Tsakalidis <tsakal@otenet.gr>
 */

#include "minigui.ch"

#define _MYTITLE_ ".:: System information about services ::."
*-----------------------------
Static oWS
*-----------------------------
Procedure Main
*-----------------------------

	SET MULTIPLE OFF
	SET AUTOADJUST ON

	oWS := CreateObject("WScript.Shell")

	Load Window Demo As Form_1

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

*-----------------------------
Function AddText( t )
*-----------------------------
Local a := Form_1.RichEdit_1.Value

	a += t + CRLF
	Form_1.RichEdit_1.Value := a

Return Nil

*-----------------------------
STATIC FUNCTION xToString( xValue )
*-----------------------------
LOCAL cType := ValType( xValue )
LOCAL cValue := "", nDecimals := Set( _SET_DECIMALS ), aTmp := {}

   DO CASE
      CASE cType $  "CM";  cValue := alltrim( xValue )
      CASE cType == "N"
	   aTmp := hb_aTokens(LTrim(str(xValue)),'.')
	   if len(aTmp) == 1
	      nDecimals := IIf( xValue == int(xValue), 0, nDecimals)
	   else
	      nDecimals := len(aTmp[2])
	   endif
	   cValue := LTrim( Str( xValue, 20, nDecimals ) )
      CASE cType == "D" ;  cValue := DToC( xValue )
      CASE cType == "T" ;  cValue := hb_TSToStr( xValue, .T. )
      CASE cType == "L" ;  cValue := IIf( xValue, "True", "False" )
      CASE cType == "A" ;  cValue := AToC( xValue )
      CASE cType $  "UE";  cValue := "NIL"
      CASE cType == "B" ;  cValue := "{|| ... }"
      CASE cType == "O" ;  cValue := "{" + xValue:className + "}"
   ENDCASE

RETURN cValue

*-----------------------------
STATIC FUNCTION WMIService()
*-----------------------------
   Static oWMI

   Local oLocator

   if oWMI == NIL

      oLocator   := CreateObject( "wbemScripting.SwbemLocator" )
      oWMI       := oLocator:ConnectServer()

   endif

Return oWMI

*-----------------------------
FUNCTION Btn1Click()
*-----------------------------
   Local oWmi, oService
   Local tBegin := HB_DATETIME(), tEnd

   Form_1.RichEdit_1.Value := ""

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( "Select * From Win32_Service" )

      AddText( oService:DisplayName + " : " + oService:State )

   NEXT
   tEnd := HB_DATETIME()
   AddText( timeMsg( tBegin, tEnd ) )
   oWsSendKeys("^{END}")
Return nil 

*-----------------------------
FUNCTION Btn2Click()
*-----------------------------
   Local oWmi, oService
   Local tBegin := HB_DATETIME(), tEnd

   Form_1.RichEdit_1.Value := ""

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( "Select * From Win32_Service" )

      AddText( "System Name : " + oService:SystemName )
      AddText( "Service Name : " + oService:Name )
      AddText( "Service Type : " + oService:ServiceType )
      AddText( "Service State : " + oService:State )
      AddText( "Code : " + xToString( oService:ExitCode ) )
      AddText( "Process ID : " + xToString( oService:ProcessID ) )
      AddText( "Can Be Paused : " + xToString( oService:AcceptPause ) )
      AddText( "Can Be Stopped : " + xToString( oService:AcceptStop ) )
      AddText( "Caption : " + oService:Caption )
      AddText( "Description : " + xToString( oService:Description ) )
      AddText( "Can Interact with Desktop : " + xToString( oService:DesktopInteract ) )
      AddText( "Display Name : " + oService:DisplayName )
      AddText( "Error Control : " + oService:ErrorControl )
      AddText( "Executable Path Name : " + xToString( oService:PathName ) )
      AddText( "Service Started : " + xToString( oService:Started ) )
      AddText( "Start Mode : " + xToString( oService:StartMode ) )
      AddText( "Start Name : " + xToString( oService:StartName ) )
      AddText( replicate( "-", 145 ) )

   NEXT
   tEnd := HB_DATETIME()
   AddText( timeMsg( tBegin, tEnd ) )
   oWsSendKeys("^{END}")
Return nil 

*-----------------------------
FUNCTION Btn3Click()
*-----------------------------
   Local oWmi, oService
   Local tBegin := HB_DATETIME(), tEnd

   Form_1.RichEdit_1.Value := ""

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( [Select * From Win32_Service Where State <> 'Running'] )

      AddText( oService:DisplayName + " : " + oService:State )

   NEXT
   tEnd := HB_DATETIME()
   AddText( timeMsg( tBegin, tEnd ) )
   oWsSendKeys("^{END}")
Return nil 

*-----------------------------
FUNCTION Btn4Click()
*-----------------------------
   Local oWmi, oService
   Local tBegin := HB_DATETIME(), tEnd

   Form_1.RichEdit_1.Value := ""

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( [Select * From Win32_Service Where PathName = 'C:\\WINDOWS\\system32\\services.exe'] )

      AddText( oService:DisplayName )

   NEXT
   tEnd := HB_DATETIME()
   AddText( timeMsg( tBegin, tEnd ) )
   oWsSendKeys("^{END}")
Return nil 

// List Service Status Changes as recorded in the System Event Log
*-----------------------------
FUNCTION Btn5Click()
*-----------------------------
   Local dtmConvertedDate := CreateObject("WbemScripting.SWbemDateTime")
   Local objWMIService := CreateObject( "wbemScripting.SwbemLocator")
   Local strEvent
   Local oSrv := objWMIService:ConnectServer()
   Local tBegin := HB_DATETIME(), tEnd

   Form_1.RichEdit_1.Value := ""

   FOR EACH strEvent IN oSrv:ExecQuery( [ Select * From Win32_NTLogEvent Where Logfile = 'System' and EventCode = '7036' ] )

      dtmConvertedDate:Value = strEvent:TimeWritten
      AddText( xToString( dtmConvertedDate:GetVarDate ) + chr(9) + strEvent:Message)

   NEXT
   tEnd := HB_DATETIME()
   AddText( timeMsg( tBegin, tEnd ) )
   oWsSendKeys("^{END}")
Return nil 

*-----------------------------
PROCEDURE oWsSendKeys(sKeys)
*-----------------------------
	if oWS:AppActivate(_MYTITLE_)
		Form_1.RichEdit_1.SetFocus()
		oWS:SendKeys(sKeys, .f.)
		// oWS:SendKeys("%+") // Alt+Shift for change keybord languages
	endif
RETURN

*-----------------------------
FUNCTION Btn_1Click()
*-----------------------------
   Local oWmi, oService

   Local tBegin := HB_DATETIME(), tEnd
   Local x := stringBuffer():New()
   Form_1.RichEdit_1.Value := replicate( "Please Wait... Please Wait... Please Wait... Please Wait... Please Wait..."+CRLF, 34 )

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( "Select * From Win32_Service" )

      x:setStr(oService:DisplayName + ' : ' + oService:State)

   NEXT
   tEnd := HB_DATETIME()
   Form_1.RichEdit_1.Value := timeMsg( tBegin, tEnd ) + ;
			      CRLF + ;
			      x:getStr( CRLF )
   Form_1.RichEdit_1.SetFocus()
Return nil 

*-----------------------------
FUNCTION Btn_2Click()
*-----------------------------
   Local oWmi, oService

   Local tBegin := HB_DATETIME(), tEnd
   Local x := stringBuffer():New()
   Form_1.RichEdit_1.Value := replicate( "Please Wait... Please Wait... Please Wait... Please Wait... Please Wait..."+CRLF, 34 )

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( "Select * From Win32_Service" )
      x:setStr( "System Name : " + oService:SystemName )
      x:setStr( "Service Name : " + oService:Name )
      x:setStr( "Service Type : " + oService:ServiceType )
      x:setStr( "Service State : " + oService:State )
      x:setStr( "Code : " + xToString( oService:ExitCode ) )
      x:setStr( "Process ID : " + xToString( oService:ProcessID ) )
      x:setStr( "Can Be Paused : " + xToString( oService:AcceptPause ) )
      x:setStr( "Can Be Stopped : " + xToString( oService:AcceptStop ) )
      x:setStr( "Caption : " + oService:Caption )
      x:setStr( "Description : " + xToString( oService:Description ) )
      x:setStr( "Can Interact with Desktop : " + xToString( oService:DesktopInteract ) )
      x:setStr( "Display Name : " + oService:DisplayName )
      x:setStr( "Error Control : " + oService:ErrorControl )
      x:setStr( "Executable Path Name : " + oService:PathName )
      x:setStr( "Service Started : " + xToString( oService:Started ) )
      x:setStr( "Start Mode : " + oService:StartMode )
      x:setStr( "Start Name : " + oService:StartName )
      x:setStr( replicate( "-", 145 ) )
   NEXT
   tEnd := HB_DATETIME()
   Form_1.RichEdit_1.Value := timeMsg( tBegin, tEnd ) + ;
			      CRLF + ;
			      x:getStr( CRLF )
   Form_1.RichEdit_1.SetFocus()
Return nil 

*-----------------------------
FUNCTION Btn_3Click()
*-----------------------------
   Local oWmi, oService

   Local tBegin := HB_DATETIME(), tEnd
   Local x := stringBuffer():New()
   Form_1.RichEdit_1.Value := replicate( "Please Wait... Please Wait... Please Wait... Please Wait... Please Wait..."+CRLF, 34 )

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( [Select * From Win32_Service Where State <> 'Running'] )

      x:setStr( oService:DisplayName + ' : ' + oService:State )

   NEXT
   tEnd := HB_DATETIME()
   Form_1.RichEdit_1.Value := timeMsg( tBegin, tEnd ) + ;
			      CRLF + ;
			      x:getStr( CRLF )
   Form_1.RichEdit_1.SetFocus()
Return nil 

*-----------------------------
FUNCTION Btn_4Click()
*-----------------------------
   Local oWmi, oService

   Local tBegin := HB_DATETIME(), tEnd
   Local x := stringBuffer():New()
   Form_1.RichEdit_1.Value := replicate( "Please Wait... Please Wait... Please Wait... Please Wait... Please Wait..."+CRLF, 34 )

   oWmi := WmiService() 

   FOR EACH oService IN oWmi:ExecQuery( [Select * From Win32_Service Where PathName = 'C:\\WINDOWS\\system32\\services.exe'] )

      x:setStr( oService:DisplayName )

   NEXT
   tEnd := HB_DATETIME()
   Form_1.RichEdit_1.Value := timeMsg( tBegin, tEnd ) + ;
			      CRLF + ;
			      x:getStr( CRLF )
   Form_1.RichEdit_1.SetFocus()
Return nil 

// List Service Status Changes as recorded in the System Event Log
*-----------------------------
FUNCTION Btn_5Click()
*-----------------------------
   Local dtmConvertedDate := CreateObject("WbemScripting.SWbemDateTime")
   Local objWMIService := CreateObject( "wbemScripting.SwbemLocator")
   Local strEvent, ii := 0
   Local oSrv := objWMIService:ConnectServer()

   Local tBegin := HB_DATETIME(), tEnd
   Local x := stringBuffer():New()
   Form_1.RichEdit_1.Value := replicate( "Please Wait... Please Wait... Please Wait... Please Wait... Please Wait..."+CRLF, 34 )

   FOR EACH strEvent IN oSrv:ExecQuery( [ Select * From Win32_NTLogEvent Where Logfile = 'System' and EventCode = '7036' ] )

      dtmConvertedDate:Value = strEvent:TimeWritten
      x:setStr( xToString( dtmConvertedDate:GetVarDate ) + chr(9) + strEvent:Message )

   NEXT
   tEnd := HB_DATETIME()
   Form_1.RichEdit_1.Value := timeMsg( tBegin, tEnd ) + ;
			      CRLF + ;
			      x:getStr('')
   Form_1.RichEdit_1.SetFocus()
Return nil 

*-----------------------------
function timeMsg( tBegin, tEnd )
*-----------------------------
	local sRet := replicate( "=", 81 ) + ;
		      CRLF + ;
		      'Begin : ' + xToString( tBegin ) + ;
		      ' # End : ' + xToString( tEnd ) + ;
		      ' # Process Time : ' + xToString( ( tEnd - tBegin ) * 86400 ) + ' Seconds' + ;
		      CRLF + ;
		      replicate( "=", 81 )
return( sRet )
//------------------------------------------------------------------//
#include "sBufCLS.prg"
//------------------------------------------------------------------//