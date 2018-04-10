/*
  Get file from Internet via HTTP - MiniGUI Demo
  (c) 2005 Jacek Kubica <kubica@wssk.wroc.pl>
*/

#include "minigui.ch"
#include "fileio.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 400 HEIGHT 210 ;
      MAIN ;
      TITLE "Get file via HTTP" ;
      BACKCOLOR { 212, 208, 200 } ;
      NOSIZE NOMAXIMIZE

   @ 19 + 25, 110 TEXTBOX ServerURL VALUE "hmgextended.com" ;
      WIDTH 175 HEIGHT 20
   @ 44 + 25, 110 TEXTBOX FileURL VALUE "/miniguilogo.jpg" ;
      WIDTH 175 HEIGHT 20
   @ 69 + 25, 110 TEXTBOX LocalName VALUE "MyPicture.jpg" ;
      WIDTH 120 HEIGHT 20
   @ 22 + 25, 17 LABEL Label_3 VALUE "ServerURL" HEIGHT 17 ;
      AUTOSIZE BOLD TRANSPARENT
   @ 47 + 25, 17 LABEL Label_2 VALUE "FileURL" HEIGHT 17 ;
      AUTOSIZE BOLD TRANSPARENT
   @ 72 + 25, 17 LABEL Label_4 VALUE "LocalFile" HEIGHT 16 ;
      AUTOSIZE BOLD TRANSPARENT

   @ 80 -10 + 25, 245 BUTTON Button_1 CAPTION "Get It" WIDTH 40 HEIGHT 40 FLAT ;
      ACTION GetFileFromInet( Form_1.ServerURL.Value, Form_1.FileURL.Value, Form_1.LocalName.Value )

   DEFINE STATUSBAR
      STATUSITEM "Author: J.Kubica <kubica@wssk.wroc.pl>"
      DATE
      CLOCK
   END STATUSBAR

   END WINDOW

   Form_1.Center
   Form_1.Activate

RETURN NIL


FUNCTION GetFileFromInet( cServer, cFile, cOutName )

   LOCAL oSock, nHandle, cPic
   LOCAL nPort := 80

   // make new socket
   oSock := THttp():New()
   Form_1.StatusBar.Item( 1 ) := "Connect to " + cServer + ":" + AllTrim( Str( nPort ) )

   // connect to server
   IF oSock:Connect( cServer, nPort )

      Form_1.StatusBar.Item( 1 ) := "Connected"
      Form_1.StatusBar.Item( 1 ) := "Retriving data ... wait pls .."

      // retrive data from server
      cPic := oSock:Get( cFile )

      // extract header data
      cPic := SubStr( cPic, At( CRLF + CRLF, cPic ) + 4 )

      // save extracted data do local file
      IF File( cOutName )
         FErase( cOutName )
      ENDIF

      nHandle := FCreate( cOutName, FC_NORMAL )
      IF nHandle  < 0
         MsgStop( "Local file cannot be created:" + Str( FError() ) )
         RETURN ""
      ELSE
         FWrite( nHandle, cPic )
         FClose( nHandle )
      ENDIF

      Form_1.StatusBar.Item( 1 ) := "Close connection"
      IF oSock:Close()
         Form_1.StatusBar.Item( 1 ) := "Close successful"
      ELSE
         Form_1.StatusBar.Item( 1 ) := "Error on close connection"
      ENDIF

      IF File( cOutName ) .AND. FILESIZE( cOutName ) == 11920
         _Execute( 0, "open", cOutName )
      ENDIF

   ELSE

      Form_1.StatusBar.Item( 1 ) := "Connection Refused"

   ENDIF

RETURN NIL
