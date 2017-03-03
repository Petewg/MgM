/*
* MiniGUI ON KEY Demo
*/

#include "minigui.ch"

#define MsgInfo( c ) MsgInfo( c, , , .f. )

Procedure Main
  
Local abActiveBlocks := {}

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Hello World!' ;
		MAIN  

		ON KEY SHIFT+A ACTION MsgInfo ('Shift+A')
		ON KEY TAB ACTION MsgInfo ('TAB')
		ON KEY RETURN ACTION MsgInfo ('RETURN')
		ON KEY CONTROL+END ACTION MsgInfo ('CONTROL+END')
		ON KEY ESCAPE ACTION MsgInfo ('ESCAPE')
		ON KEY ALT+C ACTION MsgInfo ('ALT+C')

		DEFINE BUTTON Button_1
			ROW 10
			COL 10
			CAPTION 'Activate F11'
			ACTION EnableF11()
		END BUTTON

		DEFINE BUTTON Button_2
			ROW 40
			COL 10
			CAPTION 'Release F11'
			ACTION DisableF11()
		END BUTTON

		DEFINE BUTTON Button_3
			ROW 70
			COL 10
			CAPTION 'Store Key Test'
			ACTION StoreTest()
		END BUTTON

		DEFINE BUTTON Button_4
			ROW 10
			COL 150
			WIDTH 120
			CAPTION 'Save All Fkeys'
			ACTION abActiveBlocks := SAVEONKEY('Win_1')
		END BUTTON

		DEFINE BUTTON Button_5
			ROW 40
			COL 150
			WIDTH 120
			CAPTION 'Clear All Fkeys'
			ACTION CLEARONKEY('Win_1')
		END BUTTON

		DEFINE BUTTON Button_6
			ROW 70
			COL 150
			WIDTH 120
			CAPTION 'Restore All Fkeys'
			ACTION RESTONKEY('Win_1', abActiveBlocks)
		END BUTTON

	END WINDOW

	CENTER WINDOW Win_1

	ACTIVATE WINDOW Win_1

Return

Procedure EnableF11()
	ON KEY F11 OF Win_1 ACTION MsgInfo ('F11 is pressed')
Return

Procedure DisableF11()
	RELEASE KEY F11 OF Win_1
Return

Procedure StoreTest()
Local bBlock

	STORE KEY RETURN OF Win_1 TO bBlock

	RELEASE KEY RETURN OF Win_1

	ON KEY RETURN OF Win_1 ACTION Eval ( bBlock )

Return

/*
  Function SaveOnKey() - MiniGUI DEMO
  (C)2006 Mel Smith <syntel@shaw.ca>
*/
FUNCTION SAVEONKEY(cForm)
LOCAL I,bKeyBlock, abSaveKeys := {}
LOCAL nKey

FOR I = 1 TO 12
   
   nKey := I - 1 + VK_F1      // Gets the Starting Key -- F1
   
   bKeyBlock := _GetHotKeyBlock(cForm,0,nKey)
   AADD(abSaveKeys,bKeyBlock)       // Store 'Regular' Function Keys

   bKeyBlock := _GetHotKeyBlock(cForm,MOD_SHIFT,nKey)
   AADD(abSaveKeys,bKeyBlock)       // Store 'Shift' Function Keys

   bKeyBlock := _GetHotKeyBlock(cForm,MOD_ALT,nKey)
   AADD(abSaveKeys,bKeyBlock)       // Store 'Alt' Function Keys

   bKeyBlock := _GetHotKeyBlock(cForm,MOD_CONTROL,nKey)
   AADD(abSaveKeys,bKeyBlock)       // Store 'Control' Function Keys

NEXT 
// Lastly Store the <Esc> Key
bKeyBlock := _GetHotKeyBlock(cForm,0,VK_ESCAPE)
AADD(abSaveKeys,bKeyBlock)       // Store the <Esc> Key

RETURN abSaveKeys

/*
  Function ClearOnKey() - MiniGUI DEMO
  (C)2006 Mel Smith <syntel@shaw.ca>
*/
FUNCTION CLEARONKEY(cForm)
LOCAL I,nKey
 
FOR I = 1 to 12
   
   nKey := I - 1 + VK_F1      // Gets the Starting Key -- F1
   
   _ReleaseHotKey(cForm,0,nKey)           // Clear 'Regular' Function Keys
   _ReleaseHotKey(cForm,MOD_SHIFT,nKey)   // Clear 'Shift'   Function Keys
   _ReleaseHotKey(cForm,MOD_ALT,nKey)     // Clear 'Alt'     Function Keys
   _ReleaseHotKey(cForm,MOD_CONTROL,nKey) // Clear 'Control' Function Keys
NEXT 

// Lastly Clear the <Esc> Key
_ReleaseHotKey(cForm,0,VK_ESCAPE)

RETURN NIL

/*
  Function RestOnKey() - MiniGUI DEMO
  (C)2006 Mel Smith <syntel@shaw.ca>
*/
FUNCTION RESTONKEY(cForm,abSaveKeys)
LOCAL I,J,nKey, nEscIndex := LEN(abSaveKeys)

IF nEscIndex <> 49      // (i.e., 4 * 12 + 1) Then *big trouble* 
   MsgInfo("Fault in Restoring Hot-Keys." + CRLF + "Run for Cover !")
   RETURN .F.
ENDIF

J := 0

FOR I = 1 to 48 STEP 4                          // 4 * 12 Function Keys
    nKey := VK_F1 + J
    J++ 
   _DefineHotKey(cForm, 0, nKey, abSaveKeys[I])             //Restore 'Regular'
   _DefineHotKey(cForm, MOD_SHIFT, nKey, abSaveKeys[I+1])   //Restore 'Shift'
   _DefineHotKey(cForm, MOD_ALT, nKey, abSaveKeys[I+2])     //Restore 'Alt'
   _DefineHotKey(cForm, MOD_CONTROL,nKey, abSaveKeys[I+3])  //Restore 'Control'
NEXT
// Now Restore the <Esc> Key for the Window
nKey := VK_ESCAPE
_DefineHotKey(cForm, 0, VK_ESCAPE, abSaveKeys[nEscIndex])

RETURN .T.
