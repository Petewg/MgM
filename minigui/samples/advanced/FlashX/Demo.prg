/*
   Marcelo Torres, Noviembre de 2006.
   TActivex para [x]Harbour Minigui.
   Adaptacion del trabajo de:
   ---------------------------------------------
   Lira Lira Oscar Joel [oSkAr]
   Clase TAxtiveX_FreeWin para Fivewin
   Noviembre 8 del 2006
   email: oscarlira78@hotmail.com
   http://freewin.sytes.net
   CopyRight 2006 Todos los Derechos Reservados
   ---------------------------------------------
   Copyright 2007 Walter Formigoni <walter.formigoni@uol.com.br>
   Adapted from sample of flash from Fivewin to Minigui
   ---------------------------------------------
*/

#include "minigui.ch"

Set Procedure To tAxPrg.prg

STATIC oWActiveX
STATIC oActiveX

*--------------------------------------------------------*
FUNCTION Main()
*--------------------------------------------------------*
   
   DEFINE WINDOW WinDemo ;
      AT 0,0 ;
      WIDTH 560 ;
      HEIGHT 434 ;
      TITLE 'Minigui ActiveX Flash Support Demo' ;
      ICON 'demo.ico' ;
      MAIN ;
      ON INIT fOpenActivex() ;
      ON RELEASE fCloseActivex() ;
      ON SIZE Adjust() ;
      ON MAXIMIZE Adjust()

	DEFINE MAIN MENU

		DEFINE POPUP "&File"
			MENUITEM "&Open"	ACTION iif( oActiveX == NIL, ( oWActiveX:Hide(), fOpenActivex() ), )
			MENUITEM "&Close"	ACTION ( oWActiveX:Hide(), oActiveX := NIL )
			SEPARATOR
			MENUITEM "E&xit"	ACTION ReleaseAllWindows()
		END POPUP

		DEFINE POPUP "&Help"
			MENUITEM "&About"	ACTION MsgAbout()
		END POPUP

	END MENU

   
   END WINDOW

   Center Window WinDemo
   Activate Window WinDemo

RETURN NIL


*--------------------------------------------------------*
STATIC PROCEDURE fOpenActivex()
*--------------------------------------------------------*
  oWActiveX := TActiveX():New( "WinDemo", ;
	"ShockwaveFlash.ShockwaveFlash.1", 0 , 0 , ;
	GetProperty( "WinDemo" , "Width" ) - 2 * GetBorderWidth() - 1 , ;
	GetProperty( "WinDemo" , "Height" ) - 2 * GetBorderHeight() - GetTitleHeight() - GetMenuBarHeight() )

  oActiveX := oWActiveX:Load()

  // Look for a SWF file
  oActiveX:LoadMovie( 0, GetFile( { {'SWF Files','*.swf'} }, 'Open a Flash', GetCurrentFolder() ) )

  oActiveX:Play()
   
RETURN


*--------------------------------------------------------*
STATIC PROCEDURE fCloseActivex()
*--------------------------------------------------------*
   oWActiveX:Release()
   oWActivex := Nil
   oActivex := Nil

RETURN


*--------------------------------------------------------*
STATIC PROCEDURE adjust()
*--------------------------------------------------------*
   oWActiveX:Adjust()

RETURN


*--------------------------------------------------------*
STATIC FUNCTION MsgAbout()
*--------------------------------------------------------*

RETURN MsgInfo( "Flash Player Version " + GetPlayerVersion() + CRLF + CRLF + ;
	"Using Flash Player from Adobe Inc." + CRLF + ;
	"http://www.adobe.com" + CRLF + CRLF + ;
	"Thank you, Adobe!", "About", , .f. )


*--------------------------------------------------------*
STATIC FUNCTION GetPlayerVersion()
*--------------------------------------------------------*
LOCAL oReg, cKey := ""

	OPEN REGISTRY oReg KEY HKEY_LOCAL_MACHINE ;
		SECTION "Software\Macromedia\FlashPlayer"

	GET VALUE cKey NAME "CurrentVersion" OF oReg

	CLOSE REGISTRY oReg

	IF !EMPTY(cKey)
		cKey := StrTran(cKey, ",", ".")
	ENDIF

RETURN cKey
