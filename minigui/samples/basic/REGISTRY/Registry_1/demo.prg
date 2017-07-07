/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Procedure Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 350 ;
		HEIGHT 300 ; 
		TITLE 'Registry Test' ; 
		MAIN 

		DEFINE MAIN MENU

			DEFINE POPUP "Test"
				MENUITEM 'Read Registry'	ACTION ReadRegistryTest()
				MENUITEM 'Write Registry'	ACTION WriteRegistryTest()
				SEPARATOR
				ITEM 'Exit'			ACTION Form_1.Release
			END POPUP

		END MENU


	END WINDOW 

	Form_1.Center
	Form_1.Activate

Return


Procedure ReadRegistryTest()

	MsgInfo ( GetRegistryValue( HKEY_CURRENT_USER, "Control Panel\Desktop", "Wallpaper" ) , "HKEY_CURRENT_USER\Control Panel\Desktop\Wallpaper" )

Return

Procedure WriteRegistryTest()
Local hKey := HKEY_CURRENT_USER
Local cKey := "Control Panel\Desktop"
Local cVar := "Wallpaper"
Local cValue

	If MsgYesNo ( 'This will change HKEY_CURRENT_USER\Control Panel\Desktop\Wallpaper.', 'Are you sure?' ) 

		cValue := InputBox ( '' , 'New Value:' , GetRegistryValue( hKey, cKey, cVar ) )

		If .Not. Empty (cValue)
			If .Not. SetRegistryValue( hKey , cKey , cVar , cValue  )
				MsgAlert( 'Write Registry is failure!' , 'Error' )
			Endif
		Endif

	Endif

Return
