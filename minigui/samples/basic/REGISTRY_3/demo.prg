/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Writing Registry Value as Binary
 * Demo was contributed to HMG forum by Edward 18/May/2017
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov
 */

#include "minigui.ch"
#include "hbwin.ch"

Procedure Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 350 ;
		HEIGHT 300 ; 
		TITLE 'Registry BINARY Value Test' ; 
		MAIN

		DEFINE MAIN MENU

			DEFINE POPUP "Test"
				MENUITEM 'Write TEST Value'	ACTION WriteRegistryTest()
				MENUITEM 'Delete TEST Value'	ACTION DeleteRegistryTest()
				SEPARATOR
				ITEM 'Exit'			ACTION Form_1.Release
			END POPUP

		END MENU

	END WINDOW

	Form_1.Center
	Form_1.Activate

Return


Procedure WriteRegistryTest()
Local hKey := "HKCU\"
Local cKey := "_TEST\"
Local aReg, cReg := "", nByte

If MsgYesNo( 'This will add a binary TEST value into the Windows Registry.', 'Are you sure?' ) 

	//binary array
	aReg := {0x6e,0x00,0x6f,0x00,0x74,0x00,0x65,0x00,0x70,0x00,0x61,0x00,0x64,0x00,0x2e,0x00,0x65,0x00,0x78,0x00,0x65,0x00,0x00,;
		    0x00,0x44,0x00,0x3a,0x00,0x5c,0x00,0x44,0x00,0x45,0x00,0x56,0x00,0x5c,0x00,0x53,0x00,0x63,0x00,0x72,0x00,0x69,0x00,0x70,0x00,;
		    0x74,0x00,0x45,0x00,0x64,0x00,0x69,0x00,0x74,0x00,0x5c,0x00,0x56,0x00,0x42,0x00,0x53,0x00,0x45,0x00,0x64,0x00,0x69,0x00,0x74,;
		    0x00,0x5c,0x00,0x56,0x00,0x42,0x00,0x53,0x00,0x00,0x00}
		 
	//binary string
	FOR EACH nByte IN aReg
		cReg += Chr(nByte)
	NEXT
	
	//writing registry value as binary array
	MsgInfo( win_regWriteEx( hKey + cKey + "a", aReg, WIN_REG_BINARY ) , 'Binary Array' )
	
	//writing registry value as binary string
	MsgInfo( win_regWriteEx( hKey + cKey + "c", cReg, WIN_REG_BINARY ) , 'Binary String' )

Endif

Return


Procedure DeleteRegistryTest()
Local lSuccess

	lSuccess := win_regDelete( "HKCU\_TEST\a" )
	lSuccess := lSuccess .AND. win_regDelete( "HKCU\_TEST\c" )
	lSuccess := lSuccess .AND. win_regDelete( "HKCU\_TEST\" )

	IF lSuccess
		MsgInfo( "Registry TEST value was deleted successfully." )
	ENDIF

Return


FUNCTION win_regWriteEx( cRegPath, xValue, nType, nRegSam )
LOCAL nHKEY, cKey, cEntry

	win_regPathSplit( cRegPath, @nHKEY, @cKey, @cEntry )

RETURN win_regSetEx( nHKEY, cKey, cEntry, xValue, nType, nRegSam )


FUNCTION win_regSetEx( nHKEY, cKeyName, cEntryName, xValue, nValueType, nRegSam )
LOCAL cName
LOCAL lRetVal := .F.
LOCAL pKeyHandle
LOCAL nByte

hb_default( @nRegSam, 0 )

IF win_regCreateKeyEx( nHKEY, cKeyName, 0, 0, 0, hb_bitOr( KEY_SET_VALUE, nRegSam ), 0, @pKeyHandle )
	/* no support for Arrays, Codeblock ... */
	SWITCH ValType( xValue )
	CASE "A"		//added support for array of binary
		IF HB_ISNUMERIC( nValueType ) .AND. nValueType == WIN_REG_BINARY
			cName := ''
			FOR EACH nByte IN xValue
				cName += Chr( nByte )
			NEXT
		ELSE
			cName := Nil
		ENDIF
		EXIT
	CASE "L"
		nValueType := WIN_REG_DWORD
		cName := iif( xValue, 1, 0 )
		EXIT
	CASE "D"
		nValueType := WIN_REG_SZ
		cName := DToS( xValue )
		EXIT
	CASE "N"
		IF ! HB_ISNUMERIC( nValueType ) .OR. ;
			!( nValueType == WIN_REG_DWORD .OR. ;
			nValueType == WIN_REG_DWORD_LITTLE_ENDIAN .OR. ;
			nValueType == WIN_REG_DWORD_BIG_ENDIAN .OR. ;
			nValueType == WIN_REG_QWORD .OR. ;
			nValueType == WIN_REG_QWORD_LITTLE_ENDIAN )
			nValueType := WIN_REG_DWORD
		ENDIF
		cName := xValue
		EXIT
	CASE "C"
	CASE "M"
		//added support for string of binary
		IF ! HB_ISNUMERIC( nValueType ) .OR. ;
			!( nValueType == WIN_REG_SZ .OR. ;
			nValueType == WIN_REG_EXPAND_SZ .OR. ;
			nValueType == WIN_REG_BINARY .OR. ;
			nValueType == WIN_REG_MULTI_SZ )
			nValueType := WIN_REG_SZ
		ENDIF
		cName := xValue
		EXIT
	ENDSWITCH

	IF cName != NIL
		lRetVal := win_regSetValueEx( pKeyHandle, cEntryName, 0, nValueType, cName )
	ENDIF

	win_regCloseKey( pKeyHandle )
ENDIF

RETURN lRetVal
