/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * BreakMenu demo
 * (c) 2006 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *  HMG 1.0 Experimental Build 17
*/

#include "minigui.ch"

Procedure Main

Define Window Form_1 ;
       At 0, 0 ;
       Width 400 ;
       Height 200 ;
       Title 'Menu Break Test' ;
       Main ;
       NotifyIcon 'demo.ico'

   Define Main Menu

      Popup 'File'

	Item 'Open'		Action MsgInfo ( 'File:Open'  )
	Item 'Save'		Action MsgInfo ( 'File:Save'  )
	Item 'Print'		Action MsgInfo ( 'File:Print' )
	Item 'Save As...'	Action MsgInfo ( 'File:Save As' ) Disabled
	Separator
	Item 'Exit' Action Form_1.Release

      End Popup

      Popup 'Test' 
	Item 'Item 1' Action MsgInfo ( 'Item 1' )
	Item 'Item 2' Action MsgInfo ( 'Item 2' )
	Item 'Item 3' Action MsgInfo ( 'Item 3' )
	
	// Remark:
	// Menu Item with BreakMenu clause begin a new column
	
	Item 'Item 3.1' Action MsgInfo ( 'Item 3.1' ) BreakMenu Separator
	Item 'Item 3.2' Action MsgInfo ( 'Item 3.2' )
	Separator
	Item 'Item 3.3' Action MsgInfo ( 'Item 3.3' )
	
	MenuItem 'Item 3.3.1' Action MsgInfo ( 'Item 3.3.1' ) BreakMenu
	MenuItem 'Item 3.3.2' Action MsgInfo ( 'Item 3.3.2' )

      End Popup

   End Menu
      
   Define context menu
     Item 'Open'	Action MsgInfo ( 'File:Open'  )
     
     Popup 'Save'
       Item 'Save'	 Action MsgInfo ( 'File:Save'  )
       Item 'Save As...' Action MsgInfo ( 'File:Save As' ) Disabled
     End Popup
     
     Item 'Print'	Action MsgInfo ( 'File:Print' )
     Separator
     Item 'Exit'	Action Form_1.Release

     Item 'Item 1' Action MsgInfo ( 'Item 1' ) BreakMenu Separator
     Item 'Item 2' Action MsgInfo ( 'Item 2' )
     Item 'Item 3' Action MsgInfo ( 'Item 3' )
     
   End menu
   
   Define notify menu
     Item '1st file' Action MsgInfo ( '1st file opened' )
     Item '2nd file' Action MsgInfo ( '2nd file opened' )

     Item 'About' Action MsgInfo ( 'About dialog' ) BreakMenu Separator
     Separator
     Item 'Options' Action MsgInfo ( 'Options dialog' )
     Separator
     Item 'Exit' Action Form_1.Release

   End menu
      
End Window

Center window Form_1
Activate window Form_1

Return
