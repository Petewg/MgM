/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Reception data from another program / Прием данных из другой программы 
 *
 * Copyright 2016 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Transmission of messages between applications / processes using the WM_COPYDATA
 * Передача сообщений между приложениями/процессами при помощи сообщения WM_COPYDATA 
 *
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

#include "l_names.ch"

STATIC s_cStaticMsg, s_nCounter := 1

FUNCTION Main()

   SET DATE FORMAT "DD.MM.YYYY"

   IF hb_FileExists( "test.exe" )
      FErase( "test.exe" ) 
   ENDIF

   s_cStaticMsg := "Start program - " + DtoC( Date() ) + " " + Time() + CRLF + CRLF

   SET EVENTS FUNCTION TO MyEventsHandler

   DEFINE WINDOW Form_Main ;
      AT 20,700 ;
      WIDTH 500 HEIGHT 400 ;
      TITLE APPSERVER_TITLE ;
      MAIN ;
      TOPMOST ;
      BACKCOLOR ORANGE ;
      ON INIT RunNewExe( App.Handle ) ;
      ON RELEASE CloseClient()

      @ 0, 0 LABEL Label_1 VALUE "Reception data from another program: " + APPCLIENT_TITLE ; 
        WIDTH 500 HEIGHT 32 SIZE 11 BOLD ;
        TRANSPARENT CENTERALIGN VCENTERALIGN

      @ 30, 10 LABEL Label_2 VALUE "Handle this window - " + hb_NtoS( App.Handle ) ; 
        WIDTH 480 HEIGHT 18 SIZE 10 BOLD  ;
        FONTCOLOR WHITE TRANSPARENT CENTERALIGN VCENTERALIGN

      @ 60, 20 EDITBOX Edit_Result WIDTH 450 HEIGHT 250 ;
        VALUE s_cStaticMsg  NOHSCROLL READONLY        

      @ 320, 280  BUTTONEX Button_3  WIDTH 190 ;
        CAPTION 'Exit' BACKCOLOR MAROON FONTCOLOR WHITE ;
        SIZE 11 BOLD NOXPSTYLE HANDCURSOR ACTION ThisWindow.Release

   END WINDOW

   //CENTER WINDOW Form_Main
   ACTIVATE WINDOW Form_Main

RETURN 0

////////////////////////////////////////////////////////////////////////////////
PROCEDURE RunNewExe( hHandleMain )

     LOCAL cParamStr

     IF 0 == FindWindowEx( ,,, APPCLIENT_TITLE )
         // hHandleMain transfer option in the new program, to return of his message SendMessage()
         cParamStr := hb_NtoS( hHandleMain ) + ' ' + APPSERVER_TITLE + ' ' + hb_NtoS( APP_ID )

         ShellExecute( 0, "open", APPCLIENT, cParamStr,, 1 )
     ENDIF

     INKEYGUI( 1000 )

     IF 0 == FindWindowEx( ,,, APPCLIENT_TITLE )
        s_cStaticMsg += "Can not found the window: " + APPCLIENT_TITLE + "  (" + APPCLIENT + ")" + CRLF
     ELSE
        s_cStaticMsg += "The client is running, the window: " + APPCLIENT_TITLE + CRLF
     ENDIF

     Form_Main.Edit_Result.Value := s_cStaticMsg

RETURN

////////////////////////////////////////////////////////////////////////////////
#define WM_CLOSE 0x0010

PROCEDURE CloseClient()

   LOCAL hWnd := FindWindowEx( ,,, APPCLIENT_TITLE )

   IF hWnd != 0
      PostMessage( hWnd, WM_CLOSE, 0, 0 )
   ENDIF

RETURN

#define WM_COPYDATA 74

///////////////////////////////////////////////////////////////////////////////
FUNCTION MyEventsHandler( hWnd, nMsg, wParam, lParam )

   LOCAL cData, nDataID := 0
   LOCAL cMsg, cBuff, cMd5

   IF nMsg == WM_COPYDATA
      // to get data
      cData := GetMessageData( lParam, @nDataID )

      IF nDataID == APP_ID // it's our data?
         cMsg := "Received " + DTOC( DATE() ) + "  " + TIME() + "  (" + hb_NtoS( s_nCounter++ ) + ") - "

         IF hb_LeftEqI( cData, "FILE;" )
            cMd5  := SubStr( cData, 6, 32 )   // md5 hash
            cBuff := SubStr( cData, 6 + 32 )  // file body

            IF cMd5 == hb_md5( cBuff )        // checksum verify
               // Decoding the received binary data protocol for text
               cBuff := hb_Base64Decode( cBuff )

               StrFile( cBuff, "test.exe", .F.)  // write to a file 

               s_cStaticMsg += cMsg + "-> reception and recording file: test.exe " + CRLF
            ELSE
               s_cStaticMsg += cMsg + "-> data corrupted: test.exe " + CRLF
            ENDIF
         ELSE
            s_cStaticMsg += cMsg + ValType( cData ) + ": " + hb_ValToExp( cData ) + CRLF
         ENDIF

         Form_Main.Edit_Result.Value := s_cStaticMsg

         RETURN 1
      ENDIF

   ENDIF

RETURN Events( hWnd, nMsg, wParam, lParam )

/////////////////////////////////////////////////////////////////
#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( SENDMESSAGEDATA )
{
   HWND hwnd = ( HWND ) HB_PARNL( 1 );

   if( IsWindow( hwnd ) )  
   {
      COPYDATASTRUCT cds;

      cds.dwData = ( ULONG_PTR ) hb_parni( 3 ) ;
      cds.lpData = ( char * ) hb_parc( 2 );
      cds.cbData = hb_parclen( 2 );

      SendMessage( hwnd, WM_COPYDATA, 0, ( LPARAM ) &cds );
   }
}

HB_FUNC( GETMESSAGEDATA )
{
   PCOPYDATASTRUCT pcds = ( PCOPYDATASTRUCT ) HB_PARNL( 1 );

   hb_retc_null();

   if( pcds )
   {
      if( pcds->lpData )
      {
         hb_retclen(  pcds->lpData, pcds->cbData );
      }

      if( HB_ISBYREF( 2 ) )
      {
         hb_stornl( pcds->dwData, 2 );
      }
   }
}

#pragma ENDDUMP
