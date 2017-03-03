#include "minigui.ch"

PROCEDURE Main

   DEFINE WINDOW Win_Main ;
	AT 0,0 ;
	WIDTH 600 ;
	HEIGHT 400 ;
	TITLE 'Harbour Script Usage Demo' ;
	MAIN ;
	FONT 'Times New Roman' SIZE 12

	DEFINE STATUSBAR ;
		FONT 'Times New Roman' SIZE 12
		STATUSITEM ''
	END STATUSBAR

	@10,10 BUTTON Btn_1 ;
		CAPTION 'Run Script' ;
		WIDTH 200 ;
		HEIGHT 25 ;
		ONCLICK RunScript()

   END WINDOW

   Win_Main.StatusBar.Item(1) := 'HMG Power Ready'

   CENTER WINDOW Win_Main
   ACTIVATE WINDOW Win_Main

RETURN


PROCEDURE RunScript

   LOCAL cCONTENT, hHANDLE_HRB, cPRG, cHRBCODE
   LOCAL cFILE := "script.hrb", cPASSWORD := "MyPasswordKey"

   IF !FILE( cFILE )

      cPRG := ;
         "proc p()" + hb_eol() + ;
         "   SetProperty ( 'Win_Main', 'StatusBar' , 'Item' , 1 , 'Hello World!' ) " + hb_eol() + ;
         "   MsgInfo( 'Hello World!' )" + hb_eol() + ;
         "return"

      cHRBCODE := hb_compileFromBuf( cPRG, "harbour", "-n", "-w3", "-es2", "-q0" )

      MEMOWRIT( cFILE, sx_encrypt( cHRBCODE, cPASSWORD ) )

   ENDIF

   cCONTENT := sx_decrypt( MEMOREAD( cFILE ), cPASSWORD )

   hHANDLE_HRB := hb_hrbload( cCONTENT )

   hb_hrbDo( hHANDLE_HRB )

   hb_hrbunload( hHANDLE_HRB )

RETURN
