/*
   Multi-Thread sample by Roberto Lopez. 
   
   Modified / Enhanced by KDJ 08/Nov/2016

   Description: this sample shows how to
   - terminate a new thread from the main thread - hb_threadQuitRequest(nThreadClock),
   - notify the main thread about a child thread completion - PostMessage(Main.HANDLE, WM_APP, 0, 0),
   - receive a value returned from a function completed in another thread - hb_threadJoin(nThreadClock, @cTime).
*/

#include <hmg.ch>

#define HB_THREAD_INHERIT_PUBLIC 1

*--------------------------------------------------------*
FUNCTION Main
*--------------------------------------------------------*

  SET EVENTS FUNCTION TO MYEVENTS

  DEFINE WINDOW Main ;
    AT 0, 0 ;
    WIDTH 550 HEIGHT 350 ;
    TITLE "Multithreading Demo" ;
    MAIN

    DEFINE BUTTON Button_1
      ROW    10
      COL    10
      WIDTH  160
      HEIGHT 28
      ACTION main_button_1_action()
      CAPTION "Start Clock Thread"
      FONTNAME "Arial"
      FONTSIZE 9
    END BUTTON

    DEFINE BUTTON Button_2
      ROW    50
      COL    10
      WIDTH  160
      HEIGHT 28
      ACTION main_button_2_action()
      CAPTION "Start ProgressBar Thread"
      FONTNAME "Arial"
      FONTSIZE 9
    END BUTTON

    DEFINE BUTTON Button_3
      ROW    170
      COL    140
      WIDTH  260
      HEIGHT 28
      ACTION main_button_3_action()
      CAPTION "UI Still Responding to User Events!!!"
      FONTNAME "Arial"
      FONTSIZE 9
    END BUTTON

    DEFINE LABEL Label_1
      ROW    10
      COL    360
      WIDTH  120
      HEIGHT 24
      VALUE "Clock Here!"
      FONTNAME "Arial"
      FONTSIZE 9
    END LABEL

    DEFINE LABEL Label_2
      ROW    10
      COL    180
      WIDTH  150
      HEIGHT 30
      VALUE  ""
      FONTNAME "Arial"
      FONTSIZE 9
    END LABEL

    DEFINE PROGRESSBAR ProgressBar_1
      ROW    50
      COL    360
      WIDTH  150
      HEIGHT 30
      RANGEMIN 1
      RANGEMAX 10
      VALUE 0
    END PROGRESSBAR

    ON KEY ESCAPE ACTION Main.RELEASE

  END WINDOW

  Main.Center
  Main.Activate

RETURN NIL

#define WM_APP 0x8000
*--------------------------------------------------------*
FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )
*--------------------------------------------------------*
  LOCAL result := 0

  SWITCH nMsg
  CASE WM_APP

	IF hWnd == Main.HANDLE
		Show_Time_Completed()
	ENDIF
	EXIT

#ifdef __XHARBOUR__
  DEFAULT
#else
  OTHERWISE
#endif
	result := Events( hWnd, nMsg, wParam, lParam )
  END

RETURN result

*--------------------------------------------------------*
FUNCTION Show_Time_Completed()
*--------------------------------------------------------*

  hb_idleSleep(0.05)
  main_button_1_action()

RETURN NIL

*--------------------------------------------------------*
FUNCTION Show_Time()
*--------------------------------------------------------*
  LOCAL nTimeStart := Seconds()
  LOCAL nTime      := nTimeStart
  LOCAL nHour
  LOCAL nMinute
  LOCAL nSecond
  LOCAL cTime

  DO WHILE (nTime - nTimeStart) < 5
    nTime   := Seconds()
    nHour   := Int(nTime / 3600)
    nSecond := nTime % 3600
    nMinute := Int(nSecond / 60)
    nSecond := nSecond % 60
    cTime   := PadL(nHour, 2, '0') + ':' + PadL(nMinute, 2, '0') + ':' + PadL(nSecond, 5, '0')

    main.label_1.value := cTime

    hb_idleSleep(0.01)
  ENDDO

  PostMessage(Main.HANDLE, WM_APP, 0, 0)

RETURN cTime

*--------------------------------------------------------*
FUNCTION Show_Progress()
*--------------------------------------------------------*
  LOCAL nValue

  DO WHILE .T.
    nValue := main.progressBar_1.value
    nValue ++

    if nValue > 10
      nValue := 1
    endif

    main.progressBar_1.value := nValue

    hb_idleSleep(0.25)
  ENDDO

RETURN nil

*--------------------------------------------------------*
Function main_button_1_action
*--------------------------------------------------------*
  STATIC nThreadClock
  LOCAL cTime

  IF !hb_mtvm()
    MSGSTOP("There is no support for multi-threading, clocks will not be seen.")
    Return Nil
  ENDIF

  IF ValType(nThreadClock) == 'U'
    nThreadClock := hb_threadStart(HB_THREAD_INHERIT_PUBLIC , @Show_Time())
    Main.Button_1.CAPTION  := 'Stop Clock Thread'
    Main.Button_1.FONTBOLD := .T.
    Main.Label_1.FONTBOLD  := .T.
    Main.Label_2.VALUE     := "Clock Thread will be completed after 5 seconds"
  ELSE
    Main.Button_1.CAPTION  := 'Start Clock Thread'
    Main.Button_1.FONTBOLD := .F.
    Main.Label_1.FONTBOLD  := .F.
    Main.Label_2.VALUE     := ""

    IF hb_threadQuitRequest(nThreadClock)
      //MsgBox('Clock Thread has been terminated.')
    ELSEIF hb_threadJoin(nThreadClock, @cTime)
      MsgBox('Clock Thread has been completed at ' + cTime)
    ENDIF

    nThreadClock := NIL
  ENDIF

Return Nil

*--------------------------------------------------------*
Function main_button_2_action
*--------------------------------------------------------*
  STATIC nThreadProgress

  IF !hb_mtvm()
    MSGSTOP("There is no support for multi-threading, ProgressBar will not be seen.")
    Return Nil
  ENDIF

  IF ValType(nThreadProgress) == 'U'
  nThreadProgress := hb_threadStart(HB_THREAD_INHERIT_PUBLIC, @Show_Progress())
  Main.Button_2.CAPTION  := 'Stop ProgressBar Thread'
  Main.Button_2.FONTBOLD := .T.
  ELSE
    IF hb_threadQuitRequest(nThreadProgress)
      nThreadProgress := NIL
      Main.Button_2.CAPTION  := 'Start ProgressBar Thread'
      Main.Button_2.FONTBOLD := .F.
    ENDIF
  ENDIF

Return Nil

*--------------------------------------------------------*
Function main_button_3_action
*--------------------------------------------------------*

  MsgInfo('Clock and ProgressBar keep updating even the main thread is stopped at this MsgInfo!!!')

Return Nil
