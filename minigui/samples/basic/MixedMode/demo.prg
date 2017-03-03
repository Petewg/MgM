#include "minigui.ch"

Static cConsoleTitle

Function Main

    SET STATIONNAME TO "MAINPROC"
    _HMG_Commpath := GetCurrentFolder()+"\"

    cConsoleTitle := _HMG_Commpath + "demo.exe"

    DEFINE WINDOW Form_1 ;
        AT 0,0 ;
        WIDTH 640 HEIGHT 480 ;
        TITLE 'Harbour MiniGUI Demo' ;
        MAIN ;
        FONT 'Arial' SIZE 10
        
        DEFINE LABEL Label1
            ROW 10
            COL 10
            VALUE "Good morning"   
        END LABEL 

        DEFINE GETBOX Box11
            ROW 10
            COL 100
            VALUE 2.5
            PICTURE '999,999,999,999.9999'
        END GETBOX 

        DEFINE BUTTON Btn1
            ROW 50
            COL 10
            CAPTION 'DOS 1'
            ACTION THIS.CAPTION:=ALLTRIM(STR(GETDATA(FN1())))
        END BUTTON

        DEFINE BUTTON Btn2
            ROW 100
            COL 10
            CAPTION 'Message'
            ACTION  FN2(3)
        END BUTTON

        DEFINE BUTTON Btn4
            ROW 150
            COL 10
            CAPTION 'EXIT'
            ACTION Form_1.release
        END BUTTON

    END WINDOW

    HideConsole(cConsoleTitle)
    Form_1.Center()
    Form_1.Activate()
Return Nil

FUNCTION FN1()
LOCAL r1 := 0
LOCAL r2 := 0
MEMVAR GetList
    HIDE WINDOW Form_1
    ShowConsole(cConsoleTitle)
    CLEAR SCREEN

    @ 10,10 SAY ' S1 ' GET r1 pict '9999'
    @ 12,10 SAY ' S2 ' GET r2 pict '9999'
    READ
    SENDDATA("MAINPROC",R2)
    HideConsole(cConsoleTitle)
    RESTORE WINDOW Form_1
RETURN NIL


FUNCTION FN2(n)
LOCAL i
    HIDE WINDOW Form_1
    ShowConsole(cConsoleTitle)
    CLEAR SCREEN
    FOR i:=1 TO n
        ?i
    NEXT 
    WAIT
    HideConsole(cConsoleTitle)
    RESTORE WINDOW Form_1
    MsgBox('bla'+TRANSFORM(n,'99'),'Title')
RETURN NIL


#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( HIDECONSOLE )
{
    ShowWindow(( HWND) FindWindow( NULL, hb_parc(1) ), SW_MINIMIZE);
}

HB_FUNC( SHOWCONSOLE )
{
    ShowWindow(( HWND) FindWindow( NULL, hb_parc(1) ), SW_RESTORE);
}

#pragma ENDDUMP
