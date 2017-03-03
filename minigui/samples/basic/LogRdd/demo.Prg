/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "dbinfo.ch"
#include "hbusrrdd.ch"

// Request for LOGRDD rdd driver
REQUEST LOGRDD

// Here put Request for RDD you want to inherit then add
// function hb_LogRddInherit() (see at bottom)
REQUEST DBFCDX

#include "minigui.ch"

Memvar memvartestcode
Memvar memvartestfirst
Memvar memvartestlast
Memvar memvartestbirth

Function Main

	SET CENTURY ON
	SET DELETED ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI Browse Demo' ;
		MAIN NOMAXIMIZE ;
		ON INIT OpenTables() ;
		ON RELEASE CloseTables()

		DEFINE MAIN MENU 
			POPUP 'File'
				ITEM 'Set Browse Value'	ACTION Form_1.Browse_1.Value := 50
				ITEM 'Get Browse Value'	ACTION MsgInfo ( Str ( Form_1.Browse_1.Value ) )
				ITEM 'Refresh Browse'	ACTION Form_1.Browse_1.Refresh
				SEPARATOR
				ITEM 'Exit'		ACTION Form_1.Release
			END POPUP
			POPUP 'Help'
				ITEM 'About'		ACTION MsgInfo ("MiniGUI Browse Demo") 
			END POPUP
		END MENU

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready'
			STATUSITEM '<Enter> / Double Click To Edit' WIDTH 200
			STATUSITEM 'Alt+A: Append' WIDTH 120
		END STATUSBAR

		@ 10,10 BROWSE Browse_1 ;
		WIDTH 610 ;
		HEIGHT 390 ;
		HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
		WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
		WORKAREA Test ;
		FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
		VALUE 1 ;
		EDIT INPLACE APPEND DELETE ;
		VALID { { || MemVar.Test.Code <= 1000 } , { || !Empty(MemVar.Test.First) } , { || !Empty(MemVar.Test.Last) } , { || Year(MemVar.Test.Birth) >= 1900 } , , } ;
		VALIDMESSAGES { 'Code Range: 0-1000', 'First Name Cannot Be Empty', , , ,  } ;
		LOCK

	END WINDOW

	CENTER WINDOW Form_1

	Form_1.Browse_1.SetFocus

	ACTIVATE WINDOW Form_1

Return Nil


Procedure OpenTables()
   Local cPath := "logs"
   // Set LOGRDD as default RDD otherwise I have to set explicitly use
   // with DRIVER option
   RDDSetDefault( "LOGRDD" )
   // Adding Memofile Info
   rddInfo( RDDI_MEMOVERSION, DB_MEMOVER_CLIP, "LOGRDD" )

   IF !hb_DirExists( cPath )
      hb_DirBuild( cPath )
   ENDIF

   // Define Log File Name and position
   hb_LogRddLogFileName( cPath + "\changes.log" )
   // Define Tag to add for each line logged
   hb_LogRddTag( NETNAME() + "\" + hb_USERNAME() )
   // Activate Logging, it can be stopped/started at any moment
   hb_LogRddActive( .T. )

   // Comment next line to change the logged string to standard LOGRDD message
   hb_LogRddMsgLogBlock( {|cTag, cRDDName, cCmd, nWA, xPar1, xPar2, xPar3| MyToString( cTag, cRDDName, cCmd, nWA, xPar1, xPar2, xPar3 ) } )

   // added a small workaround for logging of OPEN command
   USE test SHARED
   hb_LogRddActive( .F. )
   CLOSE

   hb_LogRddActive( .T. )

   // Open a table with logging (default RDD is LOGRDD)
   USE test SHARED NEW
Return


Procedure CloseTables()
   USE
Return


STATIC FUNCTION MyToString( cTag, cRDDName, cCmd, nWA, xPar1, xPar2, xPar3 )
   LOCAL cString

   HB_SYMBOL_UNUSED( cRDDName )

   DO CASE
      CASE cCmd == "CREATE"
           // Parameters received: xPar1 = aOpenInfo
           cString := xPar1[ UR_OI_NAME ] + " created"
      CASE cCmd == "CREATEFIELDS"
           // Parameters received: xPar1 = aStruct
           cString := hb_ValToExp( xPar1 )
      CASE cCmd == "OPEN"
           // Parameters received: xPar1 = aOpenInfo
           cString := 'Open table : "' + xPar1[ UR_OI_NAME ] + '.dbf", Alias : "' + Alias() + '", WorkArea : ' + hb_ntos( nWA )
      CASE cCmd == "CLOSE"
           // Parameters received: xPar1 = cTableName, xPar2 = cAlias
           cString := 'Close table : "' + xPar1 + '", Alias : "' + xPar2 + '", WorkArea : ' + hb_ntos( nWA )
      CASE cCmd == "APPEND"
           // Parameters received: xPar1 = lUnlockAll
           cString := Alias() + "->RecNo() = " + hb_ntos( RecNo() ) + " appended"
      CASE cCmd == "DELETE"
           // Parameters received: none
           cString := Alias() + "->RecNo() = " + hb_ntos( RecNo() ) + " deleted"
      CASE cCmd == "RECALL"
           // Parameters received: none
           cString := Alias() + "->RecNo() = " + hb_ntos( RecNo() ) + " recalled"
      CASE cCmd == "PUTVALUE"
           // Parameters received: xPar1 = nField, xPar2 = xValue, xPar3 = xOldValue
#ifndef __XHARBOUR__
           HB_SYMBOL_UNUSED( xPar3 ) // Here don't log the previous value
#endif
           cString := Alias() + "(" + hb_ntos( RecNo() ) + ")->" + PadR( FieldName( xPar1 ), 10 ) + " := " + hb_LogRddValueToText( xPar2 ) + " replaced"
      CASE cCmd == "ZAP"
           // Parameters received: none
           cString := 'Alias : "' + Alias() + ' Table : "' + dbInfo( DBI_FULLPATH ) + '" zapped'
   ENDCASE

RETURN DToS( Date() ) + " " + Time() + " " + cTag + " " + cString


FUNCTION hb_LogRddInherit()

RETURN "DBFCDX"
