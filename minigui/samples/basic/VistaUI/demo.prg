/*
 * Program   : DEMO.PRG
 * Aim       : How to use new vista buttons
 * Date      : 08/03/2017
 * Author(s) : Grigory Filatov - MiniGUI Team
 * Copyright : (c) 2017 All Rights Reserved.
 */

#include "minigui.ch"

*------------------------------------------------------------------------------*
FUNCTION Main()
*------------------------------------------------------------------------------*
LOCAL cWinTitle := "Vista UI Sample"

// SET TOOLTIP MAX WIDTH OF LINE
SET TOOLTIP MAXWIDTH TO 128

// FONT OBJECT CREATIONS
DEFINE FONT ObjFONT1 FONTNAME "MS Sans Serif" SIZE 28 BOLD
DEFINE FONT ObjFONT2 FONTNAME "MS Sans Serif" SIZE 12 BOLD

// MAIN WINDOW CREATION
DEFINE WINDOW WndMain       ;
       MAIN                 ;
       WIDTH 442 HEIGHT 300 ;
       TITLE cWinTitle      ;
       NOMAXIMIZE NOSIZE    ;
       ON INTERACTIVECLOSE MainDoExit()

    @ 005,020 LABEL lblTitle VALUE "Windows Vista new UI"        ;
            WIDTH 410 HEIGHT 35                                  ;
            FONT "ObjFONT1"

IF isVistaCompatible()

    @ 60,100 CLBUTTON ID_BTN0 WIDTH 250 HEIGHT 80                ;
                        CAPTION "Vista DEF_Command Link"         ;
                        NOTETEXT "Note"                          ;
                        ACTION MsgInfo( this.name )              ;
                        DEFAULT

    @ 145,100 CLBUTTON ID_BTN1 WIDTH 250 HEIGHT 40               ;
                        CAPTION "Vista Command Link"             ;
                        NOTETEXT NIL                             ;
                        ACTION MsgInfo( this.name )

    @ 190,100 SPLITBUTTON ID_BTN2 WIDTH 250 HEIGHT 40            ;
                        CAPTION "Split Button"                   ;
                        ACTION MsgInfo( this.name )              ;
                        FONT "ObjFONT2"                          ;
                        TOOLTIP "Vista Split Button"+CRLF+       ;
                                "Multi line tooltip"

    DEFINE DROPDOWN MENU BUTTON ID_BTN2
        MENUITEM "Drop Down Menu 1" ACTION MsgInfo( "Button Drop Down Menu 1" )
        MENUITEM "Drop Down Menu 2" ACTION MsgInfo( "Button Drop Down Menu 2" )
    END MENU

ENDIF

END WINDOW

CENTER WINDOW WndMain

ACTIVATE WINDOW WndMain

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION MainDoExit()
*------------------------------------------------------------------------------*
   IF MsgYesNo( ;
                  "Do you want to quit ?",;
		  "Question" )
      RETURN(.T.) // Terminate current app.
   ENDIF

RETURN(.F.)       // Do not quit, keep on current task

*------------------------------------------------------------------------------*
FUNCTION IsVistaCompatible()
*------------------------------------------------------------------------------*
RETURN IsWinNT() .AND. IsVistaOrLater()
