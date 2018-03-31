/*
 * Harbour Win32 Demo
 *
 * The client program - sending data / Клиентская программа - посылка данных
 *
 * Copyright 2015-2016 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Transmission of messages between applications / processes using the WM_COPYDATA
 * Передача сообщений между приложениями/процессами при помощи сообщения WM_COPYDATA 
*/

#include "hbgtinfo.ch"
#include "inkey.ch"

#include "l_names.ch"

FUNCTION Main( cHandleServer, cAppTitleServer, cID )

   LOCAL nHandleServer, nID
   LOCAL nI := 1, nKey, hWnd, cString, cColor := "15/3"

   hb_default( @cHandleServer, "" )
   hb_default( @cAppTitleServer, APPSERVER_TITLE )
   hb_default( @cID, hb_NtoS( APP_ID ) )
 
   hb_gtInfo( HB_GTI_CLOSABLE, .F. )
   hb_GTInfo( HB_GTI_WINTITLE, "Data Client" ) // Define the title of the window from the main menu
   hb_gtInfo( HB_GTI_ALTENTER, .F. )           // allow alt-enter for full screen
   hb_GtInfo( HB_GTI_SETPOS_XY, 0, 0 )

   SetMode( 24, 70 )
   SET SCOREBOARD OFF
   SET CURSOR ON
   SetColor( cColor )
   CLEAR SCREEN

   // Option 1
   nHandleServer := Val( cHandleServer )  // Handle of a server window to receive the message
   // Option 2
   IF Len( cAppTitleServer ) > 0
      hWnd := FindWindow( cAppTitleServer )
   ENDIF

   nID := Val( cID )

   ? PadC( Version(), MaxCol() ) ; ?
   ? "  This example demonstrates the transfer of data"
   ? "  in a window of another program " + cAppTitleServer + " - " + cHandleServer 
   ?? " == ", hb_NtoS( hWnd ), " ", If( hWnd == nHandleServer, "YES", "NO" ) 

   @  0, 0 TO MaxRow(), MaxCol() DOUBLE
   @ MaxRow() - 1, 0 SAY "  ESC-exit  "
   @ MaxRow() - 2, 0 TO MaxRow(), 11 DOUBLE
   ColorWin( MaxRow() - 2, 0, MaxRow(), 11, 78 )
   @ 18, 4 SAY "Using standard function SendMessage() that sends a predetermined" Color( "14/3" )
   @ 19, 4 SAY "message to a window or windows." Color( "14/3" )

   Inkey( 5 )
   
   DO WHILE .T.
      IF nHandleServer > 0
         IF nI <= 9
            cString := 'Transmit data: string ("Hi, text string - ' + hb_NtoS(nI) + '")'
            @ 5 + nI, 5 SAY cString Color( "0/3" )

            TransferDATA( nHandleServer, cString, nID )
         ELSEIF nI == 10
            cString := 'Transmit data: exe file transfer -> demo-client.exe' 
            @ 5 + nI, 5 SAY cString Color( "0/3" )

            TransferDATA( nHandleServer, "FILE", nID )
         ELSE
            @ 16, 5 SAY "End of Data !" Color( "4/3" )
         ENDIF
      ELSE
         @ 15, 5 SAY "No handle of the window [" + cAppTitleServer + "] ! " Color( "15/4" )
      ENDIF
      nI++

      nKey := Inkey( 1, INKEY_ALL )
      IF nKey == K_ESC
         EXIT
      ENDIF
   ENDDO

RETURN 0

////////////////////////////////////////////////////////////////////////////////
FUNCTION TransferDATA( hWnd, cVal, nID )

   LOCAL cBuff, cEncBuff

   IF cVal == "FILE"
      cBuff    := FileStr( APPCLIENT )
      cEncBuff := hb_Base64Encode( cBuff, Len( cBuff ) )
      cBuff    := NIL
      // Encoding binary data for text transmission protocol 
      cVal := cVal + ";" + hb_md5( cEncBuff ) + cEncBuff
   ENDIF

   // Transfer data to window "Server"
   SendMessageData( hwnd, cVal, nID )

RETURN NIL

////////////////////////////////////////////////////////////////////////////////
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

HB_FUNC ( FINDWINDOW )
{
   HB_RETNL( ( LONG_PTR ) FindWindow( 0, hb_parc( 1 ) ) );
}

#pragma ENDDUMP
