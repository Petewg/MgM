#include "minigui.ch"

Function main()

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Menu Test' ;
		MAIN 

		DEFINE MAIN MENU

			POPUP 'File'

				ITEM 'Open' 		ACTION MsgInfo ('File:Open') IMAGE 'Check.Bmp' 
				ITEM 'Save' 		ACTION MsgInfo ('File:Save') IMAGE 'Free.Bmp' DISABLED 
				ITEM 'Print' 		ACTION MsgInfo ('File:Print') IMAGE 'Info.Bmp'  
				ITEM 'Save As...' 	ACTION MsgInfo ('File:Save As') DISABLED
				ITEM 'HMG Version' 	ACTION MsgInfo (MiniGuiVersion())
				SEPARATOR
				ITEM 'Exit' 		ACTION Form_1.Release IMAGE 'Exit.Bmp'

			END POPUP

			POPUP 'Test' 

				ITEM 'Item 1' 		ACTION MsgInfo ('Item 1')  name xxx
				ITEM 'Item 2' 		ACTION MsgInfo ('Item 2')

				POPUP 'Item 3' name test
					ITEM 'Item 3.1' 		ACTION MsgInfo ('Item 3.1') DISABLED 
					ITEM 'Item 3.2' 		ACTION MsgInfo ('Item 3.2')

					POPUP 'Item 3.3'
						ITEM 'Item 3.3.1' 		ACTION MsgInfo ('Item 3.3.1')
						ITEM 'Item 3.3.2' 		ACTION MsgInfo ('Item 3.3.2')

						POPUP 'Item 3.3.3' 	

							ITEM 'Item 3.3.3.1' 		ACTION MsgInfo ('Item 3.3.3.1')
							ITEM 'Item 3.3.3.2' 		ACTION MsgInfo ('Item 3.3.3.2')
							ITEM 'Item 3.3.3.3' 		ACTION MsgInfo ('Item 3.3.3.3') DISABLED 
							ITEM 'Item 3.3.3.4' 		ACTION MsgInfo ('Item 3.3.3.4') DISABLED 
							ITEM 'Item 3.3.3.5' 		ACTION MsgInfo ('Item 3.3.3.5')
							ITEM 'Item 3.3.3.6' 		ACTION MsgInfo ('Item 3.3.3.6')  

						END POPUP

						ITEM 'Item 3.3.4' 		ACTION MsgInfo ('Item 3.3.4') DISABLED

					END POPUP

				END POPUP

				ITEM 'Item 4' 		ACTION MsgInfo ('Item 4') DISABLED

			END POPUP

			POPUP 'Help'

				ITEM 'About' 		ACTION MsgInfo ('Help:ABout')

			END POPUP

		END MENU

		DEFINE CONTEXT MENU
			ITEM 'Item 1' 		ACTION MsgInfo ('Item 1') 
			ITEM 'Item 2' 		ACTION MsgInfo ('Item 2') DISABLED
			SEPARATOR
			ITEM 'Item 3' 		ACTION MsgInfo ('Item 3')
		END MENU

		ON KEY ESCAPE ACTION ThisWindow.Release

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil
