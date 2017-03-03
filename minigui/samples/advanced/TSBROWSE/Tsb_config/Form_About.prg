/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2014, Verchenko Andrey <verchenkoag@gmail.com>
 *
*/

#include "minigui.ch"

#define COPYRIGHT  "(c) Copyright by Andrey Verchenko. All Right Reserved. Dmitrov, 2014."
#define PRG_NAME   "Showing work in TSBrowse MiniGui !"
#define PRG_VERS   "Version 1.0"
#define PRG_INFO1  "Many thanks for your help: Grigory Filatov <gfilatov@inbox.ru>"
#define PRG_INFO2  "Tips and tricks programmers from our forum http://clipper.borda.ru"
#define PRG_INFO3  "Igor Nazarov, Sidorov Aleksandr, SergKis and other..."

///////////////////////////////////////////////////////////////////////////////////////
FUNCTION MsgAbout()
   RETURN MsgInfo( PadC( PRG_NAME + " - " + PRG_VERS , 70 ) + CRLF + CRLF +  ;
                   PadC( COPYRIGHT, 70 ) + CRLF + CRLF + ;
                   PadC( PRG_INFO1, 70 ) + CRLF + ;
                   PadC( PRG_INFO2, 70 ) + CRLF + ;
                   PadC( PRG_INFO3, 70 ) + CRLF + CRLF + ;
                   hb_compiler() + CRLF + ;
                   Version() + CRLF + ;
                   MiniGuiVersion() + CRLF + CRLF + ;
                   PadC( "This program is Freeware!", 70 ) + CRLF + ;
                   PadC( "Copying is allowed!", 70 ), "About", "1MAIN_ICON", .F. )

///////////////////////////////////////////////////////////////////////////////////////
FUNCTION MsgAboutDim(nVal)
   LOCAL aDim := { COPYRIGHT, PRG_INFO1, PRG_INFO2, PRG_INFO3 }
   DEFAULT nVal := 1
   RETURN aDim[nVal] 
