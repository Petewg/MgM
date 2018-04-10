/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * (c) 2005-2012 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "message.ch"

Function Main

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'MiniGUI MsgBoxEx Demo (Based Upon a Contribution Of Grigory Filatov)' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE STATUSBAR
			STATUSITEM '[x] Harbour Power Ready!' 
		END STATUSBAR

		DEFINE MAIN MENU 

			POPUP '&MsgBoxEx'

				ITEM 'Message Information'	ACTION	MsgBoxEx( "MessageBox Test","MsgInfo", MSG_INFO )

				ITEM 'Message Stop'		ACTION	MsgBoxEx( "MessageBox Test","MsgStop", MSG_STOP )

				ITEM 'Message Error'		ACTION	MsgBoxEx( "MessageBox Test","MsgAlert", MSG_ALERT )

				ITEM 'Message Box with 2 Buttons: Yes and No' ACTION MsgBoxEx( "MessageBox Test","MsgYesNo", MSG_YESNO )

				ITEM 'Message Box with 2 Buttons: Yes and No reverted' ACTION MsgBoxEx( "MessageBox Test", "MsgNoYes", MSG_NOYES )

				ITEM 'Message Box with 2 Buttons: Ok and Cancel' ACTION MsgBoxEx( "MessageBox Test","MsgOkCancel", MSG_OKCANCEL )

				ITEM 'Message Box with 2 Buttons: Retry and Cancel' ACTION MsgBoxEx( "MessageBox Test","MsgRetryCancel", MSG_RETRYCANCEL )

				ITEM 'Message Box with 3 Buttons: Abort, Retry and Ignore' ACTION MsgBoxDemo()

			    	SEPARATOR	

				ITEM '&Exit'		ACTION Form_1.Release

			END POPUP

			POPUP '&MessageBox'

				ITEM 'Message Box with 2 Buttons: Retry and Cancel and Exclamation Icon' ;
					ACTION MessageBox( "This have Exclamation Icon", "With icons...", MB_RETRYCANCEL + MB_ICONEXCLAMATION )

				ITEM 'Message Box with 2 Buttons: Retry and Cancel and Focus on Cancel' ;
					ACTION MessageBox( "This have Focus on CANCEL button", "With focus...", MB_RETRYCANCEL + MB_ICONQUESTION + MB_DEFBUTTON2 )

				ITEM 'Message Box with 2 Buttons: Retry and Cancel and Modal Dialog' ;
					ACTION MessageBox( "This is a SYSTEM MODAL DIALOG", "Modal...", MB_RETRYCANCEL + MB_SYSTEMMODAL )

			END POPUP

			POPUP '&Help'

				ITEM '&About'		ACTION MsgInfo ( "MiniGUI MsgBoxEx demo" )

			END POPUP

		END MENU

	END WINDOW

	DEFINE TIMER Timer_1 OF Form_1 INTERVAL 40 ACTION ChangeModalItems()

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil


Function msgboxdemo()
   local nRet := 0

   while ( nRet := MessageBox( "Please choose IGNORE", "Please, choose...", MB_ABORTRETRYIGNORE ) ) == MSRETRY
   enddo

   if nRet == MSABORT

      Tone( 600, 2 )

      Form_1.Release

   endif

Return Nil


/*
 *	MsgBoxEx()
 *	Multiple Message Box para todas las necesidades.
 *
 *	Andrade A. Daniel - 2001
 */

/*
 *	MsgBoxEx( [<cMsg>], [<cTitle>], [<nStyle>], [<lNoSound>] ) --> <nReturn>
 *
 *	[Parámetros]
 *	cMsg		= Mensaje del Dialogo
 *	ctitle		= Título del Dialogo
 *	nStyle		= Estilo del Dialogo	(ver Message.ch)
 *	lNoSound	= Desactiva sonidos
 *
 *	NOTA: Todos los parametros son opcionales, pero cMsg deberia contener un texto
 *
 *	[Retorno]
 *	nReturn		= Nro de la Opción seleccionada
 *
 */
FUNCTION MsgBoxEx( cMsg, cTitle, nStyle, lNoSound )

	local	nReturn

	DEFAULT	cMsg		:= ""
	DEFAULT lNoSound	:= .F.

	do case
	case nStyle == MSG_ALERT				// 1 opcion
		DEFAULT	cTitle	:= "Atención ..."
		nStyle	:= MB_ICONEXCLAMATION + MB_OK
		if !(lNoSound); MessageBeep( MB_ICONEXCLAMATION ); endif

	case nStyle == MSG_INFO					// 1 opcion
		DEFAULT	cTitle	:= "Información ..."
		nStyle	:= MB_ICONINFORMATION + MB_OK
		if !(lNoSound); MessageBeep( MB_ICONINFORMATION ); endif

	case nStyle == MSG_ERROR				// 1 opcion
		DEFAULT	cTitle	:= "Error ..."
		nStyle	:= MB_ICONHAND + MB_OK
		if !(lNoSound); MessageBeep( MB_ICONHAND ); endif

	case nStyle == MSG_YESNO				// 2 opciones
		DEFAULT	cTitle	:= "Confirme ..."
		nStyle	:= MB_ICONQUESTION + MB_YESNO
		if !(lNoSound); MessageBeep( MB_ICONQUESTION ); endif

	case nStyle == MSG_NOYES				// 2 opciones
		DEFAULT	cTitle	:= "Confirme ..."
		nStyle	:= MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON2
		if !(lNoSound); MessageBeep( MB_ICONQUESTION ); endif

	case nStyle == MSG_YESNOCANCEL				// 3 opciones
		DEFAULT	cTitle	:= "Seleccione ..."
		nStyle	:= MB_ICONQUESTION + MB_YESNOCANCEL
		if !(lNoSound); MessageBeep( MB_ICONQUESTION ); endif

	case nStyle == MSG_RETRYCANCEL				// 2 opciones
		DEFAULT	cTitle	:= "Seleccione ..."
		nStyle	:= MB_ICONQUESTION + MB_RETRYCANCEL
		if !(lNoSound); MessageBeep( MB_ICONQUESTION ); endif

	case nStyle == MSG_ABORTRETRYIGNORE			// 3 opciones
		DEFAULT	cTitle	:= "Seleccione ..."
		nStyle	:= MB_ICONQUESTION + MB_ABORTRETRYIGNORE + MB_DEFBUTTON3
		if !(lNoSound); MessageBeep( MB_ICONQUESTION ); endif

	case nStyle == MSG_OKCANCEL				// 2 opciones
		DEFAULT	cTitle	:= "Confirme ..."
		nStyle	:= MB_ICONQUESTION + MB_OKCANCEL
		if !(lNoSound); MessageBeep( MB_ICONQUESTION ); endif

	otherwise
		DEFAULT	cTitle	:= "Información ..."		// 1 opcion
		nStyle	:= MB_ICONINFORMATION + MB_OK
		if !(lNoSound); MessageBeep( MB_ICONINFORMATION ); endif

	end

	nReturn	:= MessageBox( cMsg, cTitle, nStyle )

RETURN nReturn


FUNCTION MessageBox( cText, cCaption, nType )
RETURN MessageBoxEx( GetActiveWindow(), cText, cCaption, nType, NIL )


Procedure ChangeModalItems
	Local hwnd, hwnd1, hwnd2

	hwnd := FindWindow( 0, "Modal..." )

	if !empty(hwnd)
		SetWindowText( hwnd, "Modal Dialog..." )
		if ( hwnd1 := GetDialogItemHandle( hwnd, IDRETRY) ) > 0
			SetWindowText( hwnd1, "Retry" )
		endif
		if ( hwnd2 := GetDialogItemHandle( hwnd, IDCANCEL) ) > 0
			SetWindowText( hwnd2, "Cancel" )
		endif
	endif

Return


*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_LONG FindWindow( DLL_TYPE_LPSTR lpClassName, DLL_TYPE_LPSTR lpWindowName ) ;
	IN USER32.DLL
*-----------------------------------------------------------------------------*
DECLARE DLL_TYPE_LONG MessageBoxExA( DLL_TYPE_LONG hWnd, DLL_TYPE_LPSTR lpText, ;
	DLL_TYPE_LPSTR lpCaption, DLL_TYPE_LONG uType, DLL_TYPE_LONG wLanguageId ) ;
	IN USER32.DLL ALIAS MessageBoxEx

DECLARE DLL_TYPE_LONG MessageBeep( DLL_TYPE_LONG uType ) IN USER32.DLL
*-----------------------------------------------------------------------------*
