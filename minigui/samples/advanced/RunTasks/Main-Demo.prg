/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Adapting of the menu to run external console programs.
 * Copyright 2012 Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "minigui.ch"

#define APP_TITLE 'Main Window'
#define MsgAlert( c ) MsgEXCLAMATION( c, "Warning", , .f. )

Memvar hWnd, aRunTask

FUNCTION Main()
Local nI, cButt, cCapt, cMess, cAction, cTask
Local aButton := {}

    Private hWnd

    PUBLIC aRunTask := {} // array of launched tasks to control the output of the program

    AADD( aButton, {170, 20,170,35} )
    AADD( aButton, {220, 20,170,35} )
    AADD( aButton, {270, 20,170,35} )
    AADD( aButton, {320, 20,170,35} )
    AADD( aButton, {170,230,170,35} )
    AADD( aButton, {220,230,170,35} )
    AADD( aButton, {270,230,170,35} )
    AADD( aButton, {320,230,170,35} )
    AADD( aButton, {170,430,170,35} )
    AADD( aButton, {220,430,170,35} )
    AADD( aButton, {270,430,170,35} )
    AADD( aButton, {320,430,170,35} )

    IF IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) )

	MsgAlert( "The " + APP_TITLE + " is already running!" )

        hWnd := FindWindow( APP_TITLE )

	IF hWnd > 0

		IF IsIconic( hWnd )
			_Restore( hWnd )
		ELSE
			SetForeGroundWindow( hWnd )
		ENDIF
	ELSE

		MsgStop( "Cannot find application window!", "Error", , .f. )

	ENDIF

    ELSE

	DEFINE WINDOW Form_Main ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE APP_TITLE ;
		MAIN ;
		BACKCOLOR {159, 191, 236} ;
                ON INTERACTIVECLOSE { || OnExit() }


         hWnd := FindWindow( APP_TITLE )

         DEFINE LABEL Label_1
                ROW    70
                COL    80
                WIDTH  320
                HEIGHT 20
                VALUE "FindWindow( " + APP_TITLE + " ): " + LTRIM(STR(hWnd))
                FONTSIZE 12
                FONTBOLD .T.
                FONTCOLOR {218,37,29}
		BACKCOLOR {159, 191, 236} 
         END LABEL

         DEFINE LABEL Label_2
                ROW    90
                COL    240
                WIDTH  320
                HEIGHT 20
                VALUE "ExeFile: " + cFileNoPath( HB_ArgV( 0 ) )
                FONTSIZE 12
                FONTBOLD .T.
                FONTCOLOR {218,37,29}
		BACKCOLOR {159, 191, 236} 
         END LABEL

         DEFINE LABEL Label_3
                ROW    10
                COL    50
                WIDTH  480
                HEIGHT 50
                VALUE APP_TITLE + " - Menu" 
                FONTSIZE 36
                FONTBOLD .T.
                FONTCOLOR {218,37,29}
		BACKCOLOR {159, 191, 236} 
         END LABEL

         DEFINE LABEL Label_4
                ROW    120
                COL    30
                WIDTH  600
                HEIGHT 50
                VALUE 'Command:  ShellExecute( , "open", "TaskTest.exe", ..... )' 
                FONTNAME "MS Sans serif"
                FONTSIZE 14
                FONTBOLD .t.
                LEFTTEXT .t.
                FONTCOLOR {30,30,30}
		BACKCOLOR {159, 191, 236} 
         END LABEL


        FOR nI := 1 TO LEN(aButton)
            cButt := "Button_"+LTRIM(STR(nI))
            cCapt := "Menu "+LTRIM(STR(nI))
            cTask := "Task-"+LTRIM(STR(nI))
            cMess := 'Command:  ShellExecute( , "open", "TaskTest.exe", "'+cTask+'" "'+LTRIM(STR(hWnd))+'", "" , SW_SHOWNORMAL )' 
            cAction := "ExecTask('"+cTask+"',hWnd)"
        	DEFINE BUTTON &cButt
        	  ROW aButton[nI,1]
        	  COL aButton[nI,2]
                  WIDTH  aButton[nI,3]
                  HEIGHT aButton[nI,4]
        	  CAPTION cCapt
        	  ACTION &cAction
                  TOOLTIP cMess
                  FONTNAME "MS Sans serif"
                  FONTSIZE 14
                  FONTBOLD .t.
                  LEFTTEXT .t.
                  BACKCOLOR WHITE
        	END BUTTON
        NEXT	

       	DEFINE BUTTON EXIT
       		ROW 385
       		COL 20
                WIDTH  580
                HEIGHT 35
       		CAPTION 'Exit'
       		ACTION OnExit()
                FONTNAME "MS Sans serif"
                FONTSIZE 14
                FONTBOLD .t.
                BACKCOLOR BLUE
       	END BUTTON

	END WINDOW

	CENTER WINDOW Form_Main

	ACTIVATE WINDOW Form_Main

    ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
// ShowWindow() Commands     --->  #include "winuser.h"
#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9
#define SW_SHOWDEFAULT      10
#define SW_FORCEMINIMIZE    11
#define SW_MAX              11

Procedure ExecTask(cMenu, hWndMain)
*-----------------------------------------------------------------------------*
Local hWndTask, cParam := cMenu + " " + STR(hWndMain)
Local cFileExe := "TASKTEST.EXE", cPathExe := SubStr( ExeName(), 1, RAt( "\", ExeName() )  )

   IF !FILE(cPathExe+cFileExe)
       MsgStop( "Cannot find application "+cPathExe+cFileExe+" !", "Error", , .f. )
   ELSE

       hWndTask := FindWindow( cMenu )

       IF hWndTask > 0

          MsgAlert( 'The "TaskTest - ' + cMenu + '" is already running ! ' )

          IF IsIconic( hWndTask )
		_Restore( hWndTask )
          ELSE
		SetForeGroundWindow( hWndTask )
          ENDIF
       ELSE

          AADD( aRunTask, cMenu )   // add to array of launched tasks

          ShellExecute( , 'open', cPathExe+cFileExe, cParam, "" , SW_SHOWNORMAL )

       ENDIF
 
   ENDIF

Return
*-----------------------------------------------------------------------------*
FUNCTION OnExit() // Check before running programs
   LOCAL lExit := .T., nLenTask, cMenuTask, hWndTask, nI, cSayRun := "", cMess

   // array of launched tasks to control the output of the program
   IF ( nLenTask := Len( aRunTask ) ) > 0
      FOR nI := 1 TO nLenTask
         cMenuTask := aRunTask[ nI ]
         hWndTask := FindWindow( cMenuTask )
         IF hWndTask > 0
            lExit := .F.
            cSayRun += cMenuTask + '   ;'
            IF IsIconic( hWndTask )
               _Restore( hWndTask )
            ELSE
               SetForeGroundWindow( hWndTask )
            ENDIF
         ENDIF
      NEXT
   ENDIF
   IF lExit == .F.
       cMess := ';You can not close the program, as running other programs:           ; ;'
       cMess +=  AllTrim(cSayRun) + '   ;'
       cMess := AtRepl( ";", cMess, Chr( 13 ) + Chr( 10 ) )
       MsgAlert( cMess )
   ELSE
       RELEASE WINDOW ALL
   ENDIF

   RETURN lExit
*-----------------------------------------------------------------------------*

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( ISICONIC )
{
   hb_retl( IsIconic( ( HWND ) hb_parnl( 1 ) ) );
}

HB_FUNC ( FINDWINDOW )
{
   hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

#pragma ENDDUMP
