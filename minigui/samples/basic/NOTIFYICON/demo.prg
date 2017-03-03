/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Notifycation Icon Demo (Based Upon a Contribution of Grigory Filatov)' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		NOTIFYICON 'DEMO.ICO' ;
		NOTIFYTOOLTIP 'Double Click for Hide/Show of Main Window' ;
		ON NOTIFYDBLCLICK ProcessNotifyDblClick()

		DEFINE NOTIFY MENU 
			ITEM 'About...'			ACTION MsgInfo ( 'MiniGUI Notify Icon Demo', 'About' )
			ITEM 'Change Notify Icon' 	ACTION Form_1.NotifyIcon := 'DEMO2.ICO'
			ITEM 'Change Notify Tooltip'	ACTION Form_1.NotifyTooltip := 'New Notify Tooltip'
			ITEM 'Get Notify Icon Name'	ACTION MsgInfo ( Form_1.NotifyIcon, 'Notify Icon' )
			ITEM 'Get Notify Icon Tooltip'	ACTION MsgInfo ( Form_1.NotifyTooltip, 'Notify Tooltip' )
			SEPARATOR	
			ITEM 'Exit Application'		ACTION ThisWindow.Release
		END MENU

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Procedure ProcessNotifyDblClick()

	If IsWindowVisible( Application.Handle )
		Form_1.Hide
	Else
		Form_1.Restore
	EndIf

Return
