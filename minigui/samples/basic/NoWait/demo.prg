/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

PROCEDURE MAIN

    DEFINE WINDOW MainWindow AT 0,0 ;
           WIDTH 400 HEIGHT 200 ;
           MAIN ;
           TITLE "NoWait window test"

        @ 20,20 BUTTON Btn_Start CAPTION "Start!" ACTION NonStop() DEFAULT

        @ 60,20 BUTTON Btn_Close CAPTION "Close" ACTION ThisWindow.Release()

    END WINDOW

    CENTER WINDOW MainWindow
    ACTIVATE WINDOW MainWindow

RETURN

#define MsgInfo( c )	MsgInfo( c, , , .f. )

PROCEDURE NonStop()
LOCAL nSeconds := 0, nCount := 11, lLoop := .T.

    DEFINE WINDOW NonStop ;
	AT 0,0 ;
	WIDTH 190 HEIGHT 90 ;
	TITLE "Working..." ;
	MODAL NOSYSMENU NOSIZE ;
	ON RELEASE IF( lLoop, ( lLoop := .F., MsgInfo( "Aborted by user request!" ) ), )

	@ 10,10 LABEL Lbl_Title VALUE "This window will be closed in" AUTOSIZE

	@ 30,60 LABEL Lbl_Progress VALUE "" AUTOSIZE

	ON KEY ESCAPE ACTION NonStop.Release()

    END WINDOW

    CENTER WINDOW NonStop
    ACTIVATE WINDOW NonStop NOWAIT

    DO WHILE nCount > 0 .AND. lLoop
        IF ABS( SECONDS() - nSeconds ) >= 1
            nCount--
            NonStop.Lbl_Progress.Value := LTRIM( STR( nCount ) ) + " second" + IF(nCount > 1, "s", "")
            nSeconds := SECONDS()
        ENDIF
        DO EVENTS
    ENDDO

    IF lLoop
        NonStop.Hide()
        MsgInfo( "All is Done!" )
        lLoop := .F.
        NonStop.Release()
	DO MESSAGE LOOP
    ENDIF

RETURN
