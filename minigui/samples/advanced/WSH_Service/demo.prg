/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

#include "minigui.ch"

PROCEDURE Main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 334 ;
		HEIGHT 276 ;
		TITLE 'Windows Script Host Demo' ;
		MAIN 

		DEFINE MAIN MENU

			DEFINE POPUP "Test"
				MENUITEM 'Create Desktop Shortcuts' ACTION CreateShortcuts()
				MENUITEM 'Remove Desktop Shortcuts' ACTION DeleteShortcuts(;
					{"Shutdown", "Log Off", "Restart"})
		  		SEPARATOR
			        ITEM 'Exit' ACTION Form_1.Release()
			END POPUP

		END MENU

	END WINDOW 

	Form_1.Center()
	Form_1.Activate()

RETURN

*------------------------------------------------------------------------------*
PROCEDURE CreateShortcuts()
*------------------------------------------------------------------------------*
	
local WshShell := CreateObject("WScript.Shell")
local DesktopFolder := WshShell:SpecialFolders:Item("Desktop")
  
	MakeShortCut(WshShell, DesktopFolder + "\Shutdown.lnk", ;
		"%systemroot%\System32\shutdown.exe", "-s -t 0", ;
		"%systemroot%\System32\shell32.dll,27", ;
		"Shutdown Computer (Power Off)", "%systemroot%\System32\")

	MakeShortCut(WshShell, DesktopFolder + "\Log Off.lnk", ;
		"%systemroot%\System32\shutdown.exe", "-l", ;
		"%systemroot%\System32\shell32.dll,44", ;
		"Log Off (Switch User)", "%systemroot%\System32\")

	MakeShortCut(WshShell, DesktopFolder + "\Restart.lnk", ;
		"%systemroot%\System32\shutdown.exe", "-r -t 0", ;
		"%systemroot%\System32\shell32.dll,176", ;
		"Restart Computer (Reboot)", "%systemroot%\System32\")

	MsgInfo("Created <Shutdown>, <Restart> and <Log Off> shortcuts", "Result")
  
	WshShell := Nil
	
RETURN

*------------------------------------------------------------------------------*
PROCEDURE MakeShortCut(WshShell, LinkName, ;
		TargetPath, Arguments, IconLocation, Description, WorkingDirectory)
*------------------------------------------------------------------------------*
	
local FileShortcut

  FileShortcut := WshShell:CreateShortcut(LinkName)
  FileShortcut:TargetPath := TargetPath
  FileShortcut:Arguments := Arguments
  FileShortcut:WindowStyle := 1
  FileShortcut:IconLocation := IconLocation
  FileShortcut:Description := Description
  FileShortcut:WorkingDirectory := WorkingDirectory
  FileShortcut:Save()

  FileShortcut := Nil
	
RETURN

*------------------------------------------------------------------------------*
PROCEDURE DeleteShortcuts(aLinks)
*------------------------------------------------------------------------------*
	
local WshShell := CreateObject("WScript.Shell")
local DesktopFolder := WshShell:SpecialFolders:Item("Desktop")
local FSO := CreateObject("Scripting.fileSystemObject")
local cLink, cLinkName, lError := .F.

	For Each cLink In aLinks
		cLinkName := DesktopFolder + "\" + cLink + ".lnk"
		IF FSO:FileExists(cLinkName)
			FSO:DeleteFile(cLinkName)
		ELSE
			lError := .T.
			MsgInfo("Shortcut <" + cLink + "> not found on desktop")
		ENDIF
	Next

	IF ! lError
		MsgInfo("Shortcuts were removed from desktop", "Result")
	ENDIF

	FSO := Nil
	WshShell := Nil
	
RETURN
