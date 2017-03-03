/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2013 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

*-----------------------------------------------------------------------------*
Procedure Main()
*-----------------------------------------------------------------------------*
Local nIdx, cBoxName
Local nRow := 45
Local aOpt := {}

	Aadd( aOpt, "Default Browse" )
	Aadd( aOpt, "The Desktop*" )
	Aadd( aOpt, "Programs Folder" )
	Aadd( aOpt, "Control Panel*" )
	Aadd( aOpt, "Printers*" )
	Aadd( aOpt, "Documents Folder" )
	Aadd( aOpt, "Favorites Folder" )
	Aadd( aOpt, "Startup Folder" )
	Aadd( aOpt, "Recent Folder" )
	Aadd( aOpt, "SendTo Folder" )
	Aadd( aOpt, "Recycle Bin*" )
	Aadd( aOpt, "Start Menu Folder" )
	Aadd( aOpt, "Desktop Folder" )
	Aadd( aOpt, "My Computer*" )
	Aadd( aOpt, "Network Neighborhood*" )
	Aadd( aOpt, "NetHood Folder" )
	Aadd( aOpt, "Fonts Folder" )
	Aadd( aOpt, "ShellNew Folder" )

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 525 ;
		HEIGHT 475 + iif( IsWinXP(), GetBorderHeight(), 0 ) ;
		TITLE "Browse For Folder Demo" ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE ;
		ON INIT OnFormLoad() ;
		FONT "MS Sans Serif" SIZE 9

		@ 5,5   FRAME Frame_1 ;
			CAPTION "Dialog's root folder (nFolder parameter)" ;
			WIDTH 420 HEIGHT 434

		@ 20,15 RADIOGROUP Radio_1 ;
			OPTIONS aOpt ;
			VALUE 1 ;
			WIDTH 138 ;
			SPACING 22

		@ 400 + GetTitleHeight() - iif(IsWinXP(), GetBorderHeight(), 0),20 ;
			LABEL Label_1 ;
			VALUE "* indicates virtual folder" AUTOSIZE

		For nIdx := 1 To 17
			cBoxName := 'TextBox_' + hb_ntos(nIdx)

			@ nRow,155  TEXTBOX &cBoxName VALUE '' WIDTH 255 HEIGHT 21 READONLY

			nRow += 22
		Next

		@ 10,435 BUTTON Button_1 ;
			CAPTION '&Browse...' WIDTH 70 HEIGHT 23 ;
			ACTION Browse_Click() DEFAULT

		@ 40,435 BUTTON Button_2 ;
			CAPTION '&Info' WIDTH 70 HEIGHT 23 ;
			ACTION MsgInfo_Click()

		@ 70,435 BUTTON Button_3 ;
			CAPTION '&Quit' WIDTH 70 HEIGHT 23 ;
			ACTION Form_1.Release()
	END WINDOW

	Form_1.Center()
	Form_1.Activate()

Return

*-----------------------------------------------------------------------------*
Static Function OnFormLoad()
*-----------------------------------------------------------------------------*
  Local nIdx, nFolder, cBoxName, cPath
  
  // Loads the labels with the respective
  // system folder's path (if found)
  For nIdx := 1 To 17

    nFolder := GetFolderValue( nIdx )

    // Get the path of each folder item
    If !Empty( (cPath := C_GETSPECIALFOLDER(nFolder)) )
      
	cBoxName := 'TextBox_' + hb_ntos(nIdx)
        // Display the path in the respective label
        SetProperty( 'Form_1', cBoxName, 'Value', cPath )
      
    Else
      // The folder item doesn't exist, disable it's checkbox
      Form_1.Radio_1.Enabled( nIdx + 1 ) := .F.
    
    End If

  Next

  Form_1.Button_1.Setfocus()

Return Nil

*-----------------------------------------------------------------------------*
Static Function GetFolderValue(nIdx)  // Returns the value of the system folder constant specified by nIdx
*-----------------------------------------------------------------------------*
  Local nGetFolderValue

  // The Desktop
  If nIdx < 2
    nGetFolderValue := 0
    
  // Programs Folder --> Start Menu Folder
  ElseIf nIdx < 12
    nGetFolderValue := nIdx
    
  // Desktop Folder --> ShellNew Folder
  Else   // nIdx >= 12
    nGetFolderValue := nIdx + 4
  End If

Return nGetFolderValue

*-----------------------------------------------------------------------------*
Static Function MsgInfo_Click()
*-----------------------------------------------------------------------------*
  MsgBox( "If a root folder Option Button has no correspnoding folder location " + ;
		"displayed, then no Registry entry exists for it under:" + CRLF + CRLF + ;
		"HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" + CRLF + ;
		CRLF + "As well, if a root folder Option Button is disabled, the folder " + ;
		"does not exist in your file system and cannot be dispalyed as the root in the Browse dialog.", ;
		Form_1.Title, .F. )

Return Nil

*-----------------------------------------------------------------------------*
Function Browse_Click()
*-----------------------------------------------------------------------------*
  Local nFolder, cPath

  nFolder := GetFolderValue( Form_1.Radio_1.Value - 1 )

  If !Empty( (cPath := BrowseForFolder( nFolder )) )
    MsgInfo( cPath, "Result" )
  End If

Return Nil

*-----------------------------------------------------------------------------*
Static Function IsWinXP()
*-----------------------------------------------------------------------------*
Return _HMG_IsXP
