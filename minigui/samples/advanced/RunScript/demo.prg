/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2012 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

PROCEDURE Main

   DEFINE WINDOW Win_Main ;
      AT 0, 0 ;
      WIDTH 600 ;
      HEIGHT 400 ;
      TITLE 'Harbour Script Usage Demo' ;
      MAIN ;
      FONT 'Times New Roman' SIZE 12

   DEFINE STATUSBAR ;
      FONT 'Times New Roman' SIZE 12
      STATUSITEM ''
   END STATUSBAR

   @ 10, 10 BUTTON Btn_1 ;
      CAPTION 'Run Script' ;
      WIDTH 200 ;
      HEIGHT 25 ;
      ONCLICK RunScript()

   END WINDOW

   Win_Main.StatusBar.Item( 1 ) := 'HMG Power Ready'

   CENTER WINDOW Win_Main
   ACTIVATE WINDOW Win_Main

RETURN


PROCEDURE RunScript

   LOCAL cContent, hHandle_Hrb, cPrg, cHrbCode
   LOCAL cFile := "script.hrb", cPassword := "My_Password_Key"

   IF ! File( cFile )

      cPrg := ;
         "PROCEDURE p()" + hb_eol() + ;
         "   SetProperty ( 'Win_Main', 'StatusBar' , 'Item' , 1 , 'Hello World!' ) " + hb_eol() + ;
         "   MsgInfo( 'Hello World!' )" + hb_eol() + ;
         "RETURN"

      cHrbCode := hb_compileFromBuf( cPrg, "harbour", "-n", "-w3", "-es2", "-q0" )

      MemoWrit( cFile, sx_Encrypt( cHrbCode, cPassword ) )

   ENDIF

   cContent := sx_Decrypt( MemoRead( cFile ), cPassword )

   hHandle_Hrb := hb_hrbLoad( cContent )

   hb_hrbDo( hHandle_Hrb )

   hb_hrbUnload( hHandle_Hrb )

RETURN
