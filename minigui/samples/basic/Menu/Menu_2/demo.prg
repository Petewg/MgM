#include "minigui.ch"

Function Main ()

   DEFINE WINDOW Form1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 480 ;
      TITLE "HMG Example of Menu with Messages" ;
      MAIN ;
      FONT 'Tahoma' SIZE 9

      // The clause MESSAGE (optional) associates a message with
      // option of the menu. 
      // A STATUSBAR in the window must exist so that
      // the messages are shown. The shown messages in
      // first section  of the STATUSBAR.
      DEFINE MAIN MENU

         POPUP "Archive"
            ITEM "Open"         ACTION MsgInfo ("Archive : Open")        IMAGE "Check.Bmp" MESSAGE "Select archive to open"
            ITEM "Save"         ACTION MsgInfo ("Archive : Save")        IMAGE "Free.Bmp"  MESSAGE "Save archive"
            ITEM "Print"        ACTION MsgInfo ("Archive : Print")       IMAGE "Info.Bmp"  MESSAGE "Print archive"
            ITEM "Save as..."   ACTION MsgInfo ("Archive : Save As...")  MESSAGE "Choose new name for archive before saving"
            SEPARATOR
            ITEM "Exit"          ACTION Form1.Release                        IMAGE "Exit.Bmp"  MESSAGE "Exit program and quit"
         END POPUP
         POPUP "About"
            ITEM "Info"          ACTION MsgInfo ("HMG Example of Menu with Messages"+chr(13)+chr(10)+MiniguiVersion(),"About this demo") MESSAGE "Information about program"
         END POPUP
      END MENU

      DEFINE CONTEXT MENU
         ITEM "Item 1"       ACTION MsgInfo ("Item 1") MESSAGE "Message 1"
         ITEM "Item 2"       ACTION MsgInfo ("Item 2") MESSAGE "Message 2"
         SEPARATOR
         ITEM "Item 3"       ACTION MsgInfo ("Item 3") MESSAGE "Message 3"
      END MENU

	DEFINE STATUSBAR
		STATUSITEM "" DEFAULT // area where the messages of the menu are shown
		CLOCK WIDTH 85
		DATE
	END STATUSBAR

   END WINDOW

   CENTER WINDOW Form1

   ACTIVATE WINDOW Form1

Return Nil
