/*
 * MiniGUI WMI Service Demo
 *
 * (c) 2008-2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Procedure Main
  
	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 + iif(IsVistaOrLater(), GetBorderHeight(), 0) ;
		TITLE 'WMI Services Demo' ;
		MAIN

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			WIDTH	120
			CAPTION 'Processor Info'
			ACTION	ProcessorInfo()
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			WIDTH	120
			CAPTION 'Disk Drive Info'
			ACTION	DiskDriveInfo()
		END BUTTON

		DEFINE BUTTON Button_3
			ROW	70
			COL	10
			WIDTH	120
			CAPTION 'Logical Disk Info'
			ACTION	LogicalDiskInfo()
		END BUTTON

		DEFINE BUTTON Button_4
			ROW	100
			COL	10
			WIDTH	120
			CAPTION 'Physical Media Info'
			ACTION	PhysicalMediaInfo()
		END BUTTON
		
		DEFINE BUTTON Button_5
			ROW	130
			COL	10
			WIDTH	120
			CAPTION 'Account Info'
			ACTION	SIDInfo( GetUserName() )
		END BUTTON		

	END WINDOW

	Form_1.Button_4.Enabled := IsWinNT()
	Form_1.Button_5.Enabled := IsWinNT()

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
#translate IFNOTCHAR( <exp1>,<exp2> ) ;
=> ;
IF( VALTYPE( <exp1> ) != "C",<exp2>,<exp1> )

#define IS_DATE(x)                   (VALTYPE(x) == "D")
#define IS_LOGICAL(x)                (VALTYPE(x) == "L")
#define IS_NUMERIC(x)                (VALTYPE(x) == "N")
#define CASE_AT(x,y,z)               z[AT(x,y)+1]
#define TRIM_NUMBER(x)               LTRIM(STR(x))
#define NULL                         ""

#define XTOC(x)              CASE_AT(VALTYPE(x), "CNDLM", ;
                             { NULL, ;
                               x, ;
                               IF(IS_NUMERIC(x),;
                                  TRIM_NUMBER(x), ;
                                  NULL), ;
                               IF(IS_DATE(x),DTOC(x),NULL),;
                               IF(IS_LOGICAL(x),;
                                  IF(x,".T.",".F."), ;
                                  NULL), ;
                               x })
*--------------------------------------------------------*


FUNCTION ProcessorInfo()

   Local oWmi, oProc
   Local cInfo := ""

   oWmi := WmiService() 

   FOR EACH oProc IN oWmi:ExecQuery( "SELECT * FROM Win32_Processor" )

      cInfo := ""
      cInfo += "Manufacturer: "  + oProc:Manufacturer + CRLF
      cInfo += "Model: "  + oProc:Name + CRLF
      cInfo += "Description: "  + oProc:Description + CRLF
      cInfo += "ID: "  + oProc:ProcessorID + CRLF + CRLF

      if IsWinNT() .AND. !IsWinXPHome()

         cInfo += "Cores: "  + TRIM_NUMBER( oProc:NumberOfCores ) + CRLF
         cInfo += "Logical Processors: "  + TRIM_NUMBER( oProc:NumberOfLogicalProcessors ) + CRLF
         if "Intel" $ oProc:Manufacturer
            cInfo += "Hyper-Threading: "  + iif( oProc:NumberOfCores < oProc:NumberOfLogicalProcessors, "Enabled", "Disabled" ) + CRLF
         endif
         cInfo += CRLF

      endif

      cInfo += "Address Width: "  + TRIM_NUMBER( oProc:AddressWidth ) + " bits" + CRLF
      cInfo += "Data Width: "  + TRIM_NUMBER( oProc:DataWidth ) + " bits" + CRLF + CRLF

      cInfo += "Current Speed: "  + TRIM_NUMBER( oProc:CurrentClockSpeed ) + " MHz" + CRLF
      cInfo += "Max Speed: "  + TRIM_NUMBER( oProc:MaxClockSpeed ) + " MHz" + CRLF
      cInfo += "Ext Clock: "  + TRIM_NUMBER( oProc:ExtClock ) + " MHz"

      MsgInfo( cInfo, oProc:DeviceID )

   NEXT

Return nil 


FUNCTION DiskDriveInfo()

   Local oWmi, oDrive
   Local cInfo := ""

   oWmi := WmiService() 

   FOR EACH oDrive IN oWmi:ExecQuery( "SELECT * FROM Win32_DiskDrive" )

      cInfo += "Model: " + IFEMPTY( oDrive:Model, "N/A", oDrive:Model ) + CRLF
      cInfo += "Name: " + STRTRAN(oDrive:Name, "\\.\", "" ) + CRLF
      cInfo += "Type: " + IFEMPTY( oDrive:InterfaceType, "N/A", oDrive:InterfaceType ) + CRLF

      if IsWinNT()

         cInfo += "Signature: " + IF( IS_NUMERIC(oDrive:Signature), LTRIM( STR( Abs( oDrive:Signature ), 20, 0 ) ), "N/A" ) + CRLF

      endif

      cInfo += CRLF

   NEXT

   MsgInfo( cInfo, "Result" )

Return nil 


FUNCTION LogicalDiskInfo()

   Local oWmi, oDrive, cSerialNumber
   Local cInfo := ""

   oWmi := WmiService() 

   FOR EACH oDrive IN oWmi:ExecQuery( "SELECT * FROM Win32_LogicalDisk" )

      cSerialNumber := XTOC( oDrive:VolumeSerialNumber )
      cInfo += "Volume: " + oDrive:Name + "   Serial Number: " + IFEMPTY( cSerialNumber, "N/A", STUFF( cSerialNumber, 5, 0, "-" ) ) + CRLF

   NEXT

   MsgInfo( cInfo, "Result" )

Return nil 


FUNCTION PhysicalMediaInfo()

   Local oWmi, oDrive
   Local cInfo := ""

   oWmi := WmiService() 

   FOR EACH oDrive IN oWmi:ExecQuery( "SELECT * FROM Win32_PhysicalMedia" )

      cInfo := "Serial: " + IfNotChar( oDrive:SerialNumber, "N/A" )

      MsgInfo( cInfo, IfNotChar( STRTRAN( oDrive:Tag, "\\.\", "" ), "N/A" ) )

   NEXT

Return nil 


FUNCTION SIDInfo( cUserAccount )

   Local oWmi, oProc
   Local cInfo

   oWmi := WmiService() 

   FOR EACH oProc IN oWmi:ExecQuery( "SELECT * FROM Win32_Account WHERE Name = '"+cUserAccount+"'" )
      cInfo := ""
      cInfo += "UserName: "  + oProc:Name + CRLF
      cInfo += "SID: "  + oProc:SID + CRLF
      cInfo += "SIDtype: "  + TRIM_NUMBER( oProc:SIDtype ) + CRLF
      cInfo += "Domain: "  + oProc:Domain + CRLF
      cInfo += "Status: "  + oProc:Status + CRLF
      cInfo += "Caption: "  + oProc:Caption + CRLF
      cInfo += "Description: " + oProc:Description

      MsgInfo( cInfo, "Account Properties" )

   NEXT

Return nil 


STATIC FUNCTION WMIService()

   Static oWMI

   Local oLocator

   if oWMI == NIL

      oLocator   := CreateObject( "wbemScripting.SwbemLocator" )
      oWMI       := oLocator:ConnectServer()

   endif

Return oWMI


Static Function IsWinXPHome()
  Local aVer := WinVersion()

Return "Home" $ aVer[4]
