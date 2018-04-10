/*
 * MiniGUI Msg2All Demo
 * (c) 2007 Grigory Filatov
 *
 * Functions Msg2All(), NewMsg2All(), Msg2AllPrn() for Xailer
 * Author: Bingen Ugaldebere
 * Final revision: 07/11/2006
*/

#include "minigui.ch"
#include "winprint.ch"

#define CLR_BLUE { 0, 0, 128 }

*-------------------------------------------------------------
Procedure Main
*-------------------------------------------------------------

	SET LANGUAGE TO SPANISH

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 300 ;
		HEIGHT 245 ;
		TITLE 'Msg2All Demo' ;
		ICON "demo.ico" ;
		MAIN ;
		NOMAXIMIZE NOSIZE

		@ 10, 40 FRAME Frame_1 ;
			CAPTION '' ;
			WIDTH  220 ;
			HEIGHT 185

		@ 40 ,70 BUTTON Button_1 ;
			CAPTION "Crear mensajes" ;
			ACTION NewMsg2All() ;
	                WIDTH 160 ;
			HEIGHT 30

		@ 90 ,70 BUTTON Button_2 ;
			CAPTION "Visualizar mensajes" ;
			ACTION Msg2All() ;
	                WIDTH 160 ;
			HEIGHT 30

		@ 140 ,70 BUTTON Button_3 ;
			CAPTION _HMG_aABMLangButton [17] ;
			ACTION Form_1.Release() ;
	                WIDTH 160 ;
			HEIGHT 30

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

//Mensaje a todos los usuarios de una red
*-------------------------------------------------------------
Function NewMsg2All()
*-------------------------------------------------------------
Local lSave := .F.
Local cMessage:=Space(250), cFrom:=Space(30), nValidity:=10

   //Si no existe el archivo crearlo
   If !File("Messages.Dbf")
      DbCreate( "Messages.Dbf",;
                { { "Date"     , "D",   8, 0 },;
                  { "Time"     , "C",   5, 0 },;
                  { "From"     , "C",  30, 0 },;
                  { "Message"  , "C", 250, 0 },;
                  { "ValidDays", "N",   2, 0 },;
                  { "IP"       , "C", 400, 0 } } , "DBFNTX" )
   Endif

   DEFINE WINDOW _NewForm   ;
      AT 0,0                ;
      WIDTH 300             ;
      HEIGHT 250            ;
      TITLE "Nuevo mensaje" ;
      ICON "demo.ico"       ;
      MODAL                 ;
      NOSIZE                ;
      FONT 'MS Sans Serif'  ;
      SIZE 9

      ON KEY ESCAPE ACTION _NewForm.Release

      @ 5, 10 LABEL _Label_1 VALUE "Texto del Mensaje" WIDTH 270 TRANSPARENT

      @ 25, 10 EDITBOX _TextBox_1 VALUE cMessage WIDTH 270 HEIGHT 60 MAXLENGTH Len(cMessage) ;
                 NOHSCROLL

      @ 90, 10 LABEL _Label_2 VALUE "Autor" WIDTH 270 TRANSPARENT

      @ 110, 10 TEXTBOX _TextBox_2 VALUE cFrom WIDTH 270 HEIGHT 20 MAXLENGTH Len(cFrom) ;
                 ON ENTER _NewForm._TextBox_3.SetFocus

      @ 145, 10 LABEL _Label_3 VALUE "Días de Validez" WIDTH 90 TRANSPARENT

      @ 142,110 TEXTBOX _TextBox_3 VALUE nValidity WIDTH 40 HEIGHT 20 NUMERIC INPUTMASK "99" ;
                 ON ENTER _NewForm._Ok.SetFocus

      @ 180, 50 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
                ACTION ( lSave := .T. , ;
                   cFrom := _NewForm._TextBox_2.Value, cMessage := _NewForm._TextBox_1.Value, ;
                   nValidity := _NewForm._TextBox_3.Value, _NewForm.Release )

     @ 180,150 BUTTON _Cancel CAPTION "&"+_HMG_MESSAGE [7] WIDTH 80 HEIGHT 25 ;
                ACTION _NewForm.Release

   END WINDOW

   CENTER WINDOW _NewForm

   ACTIVATE WINDOW _NewForm

   If lSave

      DbUseArea(.T.,"DBFNTX","Messages.Dbf","Messages")
      If NetErr()
         Return Nil
      Endif

      Messages->( DbAppend() )

      Messages->Date      := Date()
      Messages->Time      := Time()
      Messages->From      := cFrom
      Messages->Message   := cMessage
      Messages->ValidDays := nValidity

      Messages->( DbCloseArea() )

   Endif

Return Nil

//Muestra el mensaje a una IP no mostrada aun
*-------------------------------------------------------------
Function Msg2All()
*-------------------------------------------------------------
Local cLocalIP:=GetLocalIp()[1], cFinalIP:=SubStr(cLocalIP,Rat(".",cLocalIP))+"."
Local lOk:=.F.

If File("Messages.Dbf")

   DbUseArea(.T.,"DBFNTX","Messages.Dbf","Messages")
   If NetErr()
      Return Nil
   Endif

   Do While !Eof()

      If Messages->Date+Messages->ValidDays < Date()
         //Borrar mensajes caducados
         IF Rlock()
            Messages->(DbDelete())
         ENDIF

      Else
         //Buscar la IP y mostrar el mensaje si no se encuentra
         If At( cFinalIP,Messages->IP )=0
            DEFINE WINDOW _ReadForm  ;
               AT 0,0                ;
               WIDTH 300             ;
               HEIGHT 190            ;
               TITLE "Mensaje de "+Alltrim(Messages->From)+"  "+Dtoc(Messages->Date)+"  "+Messages->Time ;
               ICON "demo.ico"       ;
               MODAL                 ;
               NOSIZE                ;
               FONT 'MS Sans Serif'  ;
               SIZE 9

               ON KEY ESCAPE ACTION _ReadForm.Release

               @  5, 10 LABEL _Label_1 VALUE "Mensaje de "+Alltrim(Messages->From) WIDTH 270 TRANSPARENT

               @ 25, 10 LABEL _Label_2 VALUE "De fecha "+Dtoc(Messages->Date)+"  "+Messages->Time WIDTH 270 TRANSPARENT

               @ 45, 10 EDITBOX _TextBox_1 VALUE Alltrim(Messages->Message) WIDTH 270 HEIGHT 60 ;
                        NOHSCROLL

               @ 120,20 BUTTON _Print CAPTION "&"+_HMG_aABMLangButton [16] WIDTH 80 HEIGHT 25 ;
                        ACTION Msg2AllPrn( _ReadForm.Title, Alltrim(Messages->Message) )

               @ 120,105 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 ;
                        ACTION ( lOk:=.T., _ReadForm.Release )

               @ 120,190 BUTTON _Demorar CAPTION IF("ES" $ Set( _SET_LANGUAGE ), "&Demorar", "&Delay") WIDTH 80 HEIGHT 25 ;
                        ACTION ( lOk:=.F., _ReadForm.Release )

            END WINDOW

            CENTER WINDOW _ReadForm

            ACTIVATE WINDOW _ReadForm

            IF lOk   //Mensaje aceptado
               IF Rlock()
                  Messages->IP := Left(Alltrim(Messages->IP),Len(Alltrim(Messages->IP))-1)+cFinalIP
               ENDIF
            ENDIF
         Endif
      Endif

      Messages->( DbSkip() )

   Enddo

   Messages->( DbCloseArea() )

Endif

Return Nil

//Prints a Message
*-------------------------------------------------------------
Function Msg2AllPrn( cTitle, cText )
*-------------------------------------------------------------
Local n, aRect := Array(4)

	INIT PRINTSYS

	SELECT PRINTER BY DIALOG

	IF HBPRNERROR != 0 
		Return Nil
	ENDIF

	aRect[1] := ( GetDesktopHeight() - 599 ) / 2
	aRect[2] := ( GetDesktopWidth() - 799 ) / 2
	aRect[3] := GetDesktopHeight() - aRect[1]
	aRect[4] := GetDesktopWidth() - aRect[2]

	DEFINE FONT "Font_1" NAME "Times New Roman" SIZE 14 BOLD UNDERLINE
	DEFINE FONT "Font_2" NAME "Times New Roman" SIZE 12

	SET PAPERSIZE DMPAPER_A4	// Sets paper size to A4

	SET ORIENTATION PORTRAIT	// Sets paper orientation to portrait

	SET PREVIEW ON			// Enables print preview
	SET CLOSEPREVIEW OFF

	SET PREVIEW RECT aRect
	SET PREVIEW SCALE 3

	START DOC NAME cTitle

		START PAGE

			@1, 1+(HBPRNMAXCOL-Len(cTitle))/2 SAY cTitle FONT "Font_1" COLOR CLR_BLUE TO PRINT

			For n:=1 To MlCount( cText, 80 )

				@n+4, 10 SAY MemoLine( cText, 80, n ) FONT "Font_2" TO PRINT

			Next

		END PAGE

	END DOC

	RELEASE PRINTSYS

Return Nil


#pragma BEGINDUMP

#include "windows.h"
#include "hbapi.h"

#ifdef __XHARBOUR__
#define HB_STORC( n, x, y ) hb_storc( n, x, y )
#else
#define HB_STORC( n, x, y ) hb_storvc( n, x, y )
#endif

HB_FUNC( GETLOCALIP )
{
   WSADATA wsa;
   char cHost[256];
   struct hostent *h;
   int nAddr = 0, n = 0;

   WSAStartup( MAKEWORD( 2, 0 ), &wsa );

   if( gethostname( cHost, 256 ) == 0 )
   {
      h = gethostbyname( cHost );
      if( h )
         while( h->h_addr_list[ nAddr ] )
            nAddr++;
   }

   hb_reta( nAddr );

   if( nAddr )
      while( h->h_addr_list[n] )
         {
         char cAddr[256];
         wsprintf( cAddr, "%d.%d.%d.%d", (BYTE) h->h_addr_list[n][0],
                                         (BYTE) h->h_addr_list[n][1],
                                         (BYTE) h->h_addr_list[n][2],
                                         (BYTE) h->h_addr_list[n][3] );
         HB_STORC( cAddr, -1, ++n );
         }

   WSACleanup();
}

#pragma ENDDUMP
