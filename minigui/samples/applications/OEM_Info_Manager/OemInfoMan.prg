/*
 * MiniGUI OEM Info Manager
 *
 * Copyright 2008 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#define PROGRAM 'OEM Info Manager'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2008 Grigory Filatov'

#define BM_WIDTH        1
#define BM_HEIGHT       2
#DEFINE SW_SHOW         5
#define NTRIM( n )	LTrim( Str( n ) )

MEMVAR cKey, cOemIni, cOemImage

Procedure Main
LOCAL dummy := "", n, cItem
LOCAL cFileIni := GetStartUpFolder() + "\oeminfo.ini"

	PUBLIC cKey := IF( IsWinNT(), "SOFTWARE\Microsoft\Windows NT\CurrentVersion", ;
		"SOFTWARE\Microsoft\Windows\CurrentVersion" )
	PUBLIC cOemIni := GetSystemFolder() + "\oeminfo.ini"
	PUBLIC cOemImage := GetSystemFolder() + "\oemlogo.bmp"

	Load Window Main

	DEFINE TOOLBAR ToolBar_1 PARENT Main BUTTONSIZE 324, 24 FLAT BOTTOM RIGHTTEXT

		BUTTON Button_01  		;
			CAPTION "Copyright " + CHR(169) + COPYRIGHT + ". All rights reserved"	;
			PICTURE 'Dummy'		;
			ACTION _dummy()

		BUTTON Button_02			;
			CAPTION padc('&Apply', 12)	;
			PICTURE 'OK'			;
			ACTION ApplyChanges() AUTOSIZE

		BUTTON Button_03			;
			CAPTION padc('E&xit', 12)	;
			PICTURE 'CANCEL'		;
			ACTION Main.Release AUTOSIZE

	END TOOLBAR

	Main.Button_01.Enabled := .f.

	IF FILE(cOemImage) .AND. FILE(cOemIni)

		Main.IMAGE_1.Picture := cOemImage

	ELSEIF FILE("oemlogo.bmp")

		Main.IMAGE_1.Picture := "oemlogo.bmp"

	ENDIF

	IF FILE(cFileIni) .OR. FILE(cOemIni)

		BEGIN INI FILE IF(FILE(cOemIni), cOemIni, cFileIni )

		Main.TEXTBOX_5.Value := _GetIni( "General", "Manufacturer", "", dummy )
		Main.TEXTBOX_6.Value := _GetIni( "General", "Model", "", dummy )

		For n := 1 To 9
			dummy := _GetIni( "Support Information", "Line"+NTRIM(n), "", dummy )
			IF !Empty( dummy )
				cItem := "TEXTBOX_"+NTRIM(n+6)
				Main.&cItem..Value := dummy
			ENDIF
		Next

		END INI

	ENDIF

	Main.TEXTBOX_2.Value := GetRegistryValue( HKEY_LOCAL_MACHINE, cKey, "RegisteredOwner" )
	Main.TEXTBOX_3.Value := GetRegistryValue( HKEY_LOCAL_MACHINE, cKey, "RegisteredOrganization" )
	Main.TEXTBOX_4.Value := GetRegistryValue( HKEY_LOCAL_MACHINE, cKey, "ProductId" )

	Main.TEXTBOX_5.SetFocus

	Center Window Main
	Activate Window Main

Return

*-----------------------------------------------------------------------------*
Static Procedure ApplyChanges()
*-----------------------------------------------------------------------------*
LOCAL n, cItem

	IF !EMPTY(Main.TEXTBOX_2.Value)
		SetRegistryValue( HKEY_LOCAL_MACHINE, cKey, "RegisteredOwner", Main.TEXTBOX_2.Value )
	ENDIF

	IF !EMPTY(Main.TEXTBOX_3.Value)
		SetRegistryValue( HKEY_LOCAL_MACHINE, cKey, "RegisteredOrganization", Main.TEXTBOX_3.Value )
	ENDIF

	IF !EMPTY(Main.TEXTBOX_4.Value)
		SetRegistryValue( HKEY_LOCAL_MACHINE, cKey, "ProductId", Main.TEXTBOX_4.Value )
	ENDIF

	IF !EMPTY(Main.TEXTBOX_5.Value) .OR. !EMPTY(Main.TEXTBOX_7.Value)

		BEGIN INI FILE cOemIni

		IF !EMPTY(Main.TEXTBOX_5.Value)
			_SetIni( "General", "Manufacturer", Main.TEXTBOX_5.Value )
		ENDIF

		IF !EMPTY(Main.TEXTBOX_6.Value)
			_SetIni( "General", "Model", Main.TEXTBOX_6.Value )
		ENDIF

		For n := 1 To 9
			cItem := "TEXTBOX_"+NTRIM(n+6)
			_SetIni( "Support Information", "Line"+NTRIM(n), Main.&cItem..Value )
		Next

		END INI

		cItem := Main.IMAGE_1.Picture
		IF FILE(cItem)
			IF cItem <> cOemImage
				COPY FILE (cItem) TO (cOemImage)
			ENDIF
		ELSEIF EMPTY(cItem) .AND. FILE(cOemImage)
			FErase(cOemImage)
		ENDIF

		ShellExecute( 0, NIL,'rundll32.exe', "shell32.dll,Control_RunDLL sysdm.cpl,,0", NIL, SW_SHOW )

	ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure OpenPicture()
*-----------------------------------------------------------------------------*
LOCAL cFile := GetFile( { {"Bitmaps (*.bmp)", "*.bmp"} }, "Open logo image" )
LOCAL aBmpSize := {}

   IF !EMPTY(cFile)

	aBmpSize := BmpSize(cFile)

	IF aBmpSize[BM_WIDTH] < 181 .AND. aBmpSize[BM_HEIGHT] < 113

		SetProperty( "Main", "TextBox_1", "Value", cFile )
		SetProperty( "Main", "Image_1", "Picture", cFile )
		DoMethod( "Main", "Image_1", "Refresh" )

	ELSE
		MsgAlert( "This selected logo cannot be saved because the maximum size is exceeded." + CRLF +;
			"Please resize it (until 180 x 112) and try again.", "Size Mismatched" )
	ENDIF

   ENDIF

Return
