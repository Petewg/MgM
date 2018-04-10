/*
 * MiniGUI Simple MP3 Player Demo
 *
 * Copyright 2013-2016 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

 
#include "minigui.ch"

#define APP_TITLE "Mini MP3 Player"

MEMVAR fileName
MEMVAR isOpen
MEMVAR isPaused
MEMVAR mediaName
MEMVAR mediaLength
MEMVAR notifyHandle

*-------------------------------------------*
FUNCTION Main()
*-------------------------------------------*

   PRIVATE fileName As Character
   PRIVATE isOpen As Logical
   PRIVATE isPaused As Logical
   PRIVATE mediaName := "media"
   PRIVATE mediaLength := 0
   PRIVATE notifyHandle

   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 445 HEIGHT 150 ;
      MAIN ;
      TITLE APP_TITLE ;
      ICON "MP3.ICO" ;
      NOMAXIMIZE NOSIZE ;
      ON RELEASE ClosePlayer()

      @ 22,015 Label Label_1 Value "MP3 File" HEIGHT 24 VCENTERALIGN

      DEFINE TEXTBOX Text_1
            ROW    22
            COL    70
            WIDTH  270
            HEIGHT 24
            TABSTOP .F.
            VISIBLE .T.
            VALUE ''
      END TEXTBOX

      @ 20,350 BUTTON Button_0 ;
         CAPTION "Browse" ;
         WIDTH 70 ;
         ACTION BrowseButton_Click() DEFAULT

      @ 72,020 BUTTON Button_1 ;
         CAPTION "Play MP3" ;
         ACTION PlayButton_Click() 

      @ 72,120 BUTTON Button_2 ;
         CAPTION "Pause MP3" ;
         ACTION PauseButton_Click()
                                 
      @ 72,220 BUTTON Button_3 ;
         CAPTION "Resume MP3" ;
         ACTION ResumeButton_Click()

      @ 72,320 BUTTON Button_4 ;
         CAPTION "Stop MP3" ;
         ACTION StopButton_Click()

      ON KEY ESCAPE ACTION ThisWindow.Release()

   END WINDOW

   RefreshStop(FALSE)

   Form_1.Center
   Form_1.Activate

RETURN NIL

*-------------------------------------------*
PROCEDURE playButton_Click()
*-------------------------------------------*

   IF hb_FileExists(Form_1.Text_1.Value)
      Play(Form_1.Text_1.Value, Application.Handle)
      RefreshStop(TRUE)
      Form_1.Button_4.SetFocus()
   ELSE
      MsgAlert("The MP3 file does not exist.", "File Not Found")
   ENDIF

RETURN

*-------------------------------------------*
PROCEDURE PauseButton_Click()
*-------------------------------------------*

   PauseMediaFile()
   Form_1.Button_3.SetFocus()

RETURN

*-------------------------------------------*
PROCEDURE ResumeButton_Click()
*-------------------------------------------*

   ResumeMediaFile()
   Form_1.Button_4.SetFocus()

RETURN

*-------------------------------------------*
PROCEDURE stopButton_Click()
*-------------------------------------------*

   ClosePlayer()
   RefreshStop(FALSE)
   Form_1.Button_1.SetFocus()

RETURN

*-------------------------------------------*
PROCEDURE browseButton_Click()
*-------------------------------------------*

   LOCAL cFileName

   cFileName := GetFile( { { 'MP3 Files' , '*.mp3'} }, "Select File", CurDir() )

   IF !EMPTY( cFileName )
	Form_1.Text_1.Value := cFileName
	Form_1.Text_1.ToolTip := cFileName
	Form_1.Button_1.SetFocus()
   ENDIF

RETURN

*-------------------------------------------*
STATIC PROCEDURE ClosePlayer()
*-------------------------------------------*

   LOCAL playCommand

   IF isOpen
      playCommand := "Close " + mediaName
      mciSendString(playCommand, NIL, 0, notifyHandle)
      isPaused := FALSE
      isOpen := FALSE
      IF IsControlDefined(Timer_1, Form_1)
         Form_1.Timer_1.Release()
      ENDIF
      Form_1.Title := APP_TITLE
      ERASE WINDOW Form_1
   ENDIF

RETURN

*-------------------------------------------*
STATIC PROCEDURE OpenMediaFile()
*-------------------------------------------*

   LOCAL playCommand

   ClosePlayer()
   playCommand := "Open " + fileName + " type mpegvideo alias " + mediaName
   mciSendString(playCommand, NIL, 0, notifyHandle)
   playCommand := "Set " + mediaName + " time format milliseconds"
   mciSendString(playCommand, NIL, 0, notifyHandle)
   isOpen := TRUE

RETURN

*-------------------------------------------*
STATIC PROCEDURE PlayMediaFile()
*-------------------------------------------*

   LOCAL playCommand, h, m, s

   IF isOpen
      playCommand := "Play " + mediaName + " notify"
      mciSendString(playCommand, NIL, 0, notifyHandle)
      mediaLength := GetMediaLength()
      DEFINE TIMER Timer_1 OF Form_1 INTERVAL 1000 ACTION RefreshPBar()
      ConvertToHHMMSS(val(mediaLength), @h, @m, @s)
      Form_1.Title := " 0:00 /" + str(m, 2) + ':' + strzero(s, 2)
   ENDIF

RETURN

*-------------------------------------------*
STATIC FUNCTION GetMediaLength()
*-------------------------------------------*

   LOCAL playCommand, str := space(128)

   IF isOpen
      playCommand := "Status " + mediaName + " length"
      mciSendString(playCommand, @str, 128, notifyHandle)
   ENDIF

RETURN str

*-------------------------------------------*
STATIC FUNCTION GetCurrentPositon()
*-------------------------------------------*

   LOCAL playCommand, str := space(128)

   IF isOpen
      playCommand := "Status " + mediaName + " position"
      mciSendString(playCommand, @str, 128, notifyHandle)
   ENDIF

RETURN str

*-------------------------------------------*
STATIC PROCEDURE ConvertToHHMMSS(milliseconds, Hour, Min, Sec)
*-------------------------------------------*

   milliseconds /= 1000 
   Sec := Mod(milliseconds, 60) 
   milliseconds /= 60 
   Min := Mod(milliseconds, 60) 
   milliseconds /= 60 
   Hour := Mod(milliseconds, 60) 

RETURN

*-------------------------------------------*
STATIC PROCEDURE PauseMediaFile()
*-------------------------------------------*

   LOCAL playCommand

   IF isOpen
      playCommand := "Pause " + mediaName
      mciSendString(playCommand, NIL, 0, notifyHandle)
      isPaused := TRUE
   ENDIF

RETURN

*-------------------------------------------*
STATIC PROCEDURE ResumeMediaFile()
*-------------------------------------------*

   LOCAL playCommand

   IF isOpen .AND. isPaused
      playCommand := "Resume " + mediaName
      mciSendString(playCommand, NIL, 0, notifyHandle)
      isPaused := FALSE
   ENDIF

RETURN

*-------------------------------------------*
PROCEDURE Play( file, notifyForm )
*-------------------------------------------*

   fileName := _GetShortPathName( File )
   notifyHandle := notifyForm

   IF isPaused
      ResumeMediaFile()
   ELSE
      OpenMediaFile()
      PlayMediaFile()
   ENDIF

RETURN

*-------------------------------------------*
STATIC PROCEDURE RefreshPBar()
*-------------------------------------------*
   LOCAL h, m, s, h1, m1, s1, pos, length

   IF isOpen
      pos := val(GetCurrentPositon())
      length := val(mediaLength)
      custom_progress_bar('Form_1', 55, 20, 400, 10, GRAY, round( pos / length * 100, 0 ), 100)
      ConvertToHHMMSS(length, @h, @m, @s)
      ConvertToHHMMSS(pos, @h1, @m1, @s1)
      Form_1.Title := str(m1, 2) + ":" + strzero(s1, 2) + " /" + str(m, 2) + ':' + strzero(s, 2)
   ENDIF

RETURN

*-------------------------------------------*
STATIC PROCEDURE RefreshStop( stop )
*-------------------------------------------*

   Form_1.Button_2.Enabled := stop
   Form_1.Button_3.Enabled := stop
   Form_1.Button_4.Enabled := stop

RETURN

#define MM_MCINOTIFY        0x3B9           /* MCI */
*--------------------------------------------------------*
FUNCTION MyEvents ( hWnd, nMsg, wParam, lParam )
*--------------------------------------------------------*

   LOCAL result := 0

	SWITCH nMsg
	CASE MM_MCINOTIFY

		If wParam == 1  // play is over
			IF IsControlDefined(Timer_1, Form_1)
				Form_1.Timer_1.Release()
			ENDIF
			Form_1.Title := APP_TITLE
			RefreshStop(FALSE)
		EndIf

		EXIT

#ifdef __XHARBOUR__
	DEFAULT
#else
	OTHERWISE
#endif
		result := Events( hWnd, nMsg, wParam, lParam )
	END

RETURN result

//mciSendString 
DECLARE DLL_TYPE_LONG mciSendString( ;
	DLL_TYPE_LPSTR command, DLL_TYPE_LPTSTR returnValue, DLL_TYPE_INT returnLength, DLL_TYPE_LONG hWnd ) ;
	IN WINMM.DLL

*-------------------------------------------*
PROCEDURE custom_progress_bar( cWindowName, nRow, nCol, nWidth, nHeight, aColor, nValue, nMax )
*-------------------------------------------*

   LOCAL nStartRow, nStartCol, nFinishRow, nFinishCol

   // progress bar
   IF nWidth > nHeight  // Horizontal Progress Bar
      nStartRow := nRow + 1
      nStartCol := nCol + 1
      nFinishRow := nRow + nHeight - 1
      nFinishCol := nCol + 1 + ((nWidth - 2) * nValue / nMax)
   ELSE  // Vertical Progress Bar
      nStartRow := nRow + nHeight - 1
      nStartCol := nCol + 1
      nFinishRow := nStartRow - ((nHeight - 2) * nValue / nMax)
      nFinishCol := nCol + nWidth - 1
   ENDIF

   DRAW RECTANGLE IN WINDOW &cWindowName AT nStartRow, nStartCol TO nFinishRow, nFinishCol PENCOLOR BLACK FILLCOLOR aColor

RETURN
