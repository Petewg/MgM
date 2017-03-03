/*
 * MiniGUI Simple MP3 Player Demo
 *
 * Copyright 2013 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS
 
#include "hmg.ch"

MEMVAR fileName
MEMVAR isOpen
MEMVAR isPaused
MEMVAR mediaName
MEMVAR notifyHandle

FUNCTION Main()

   PRIVATE fileName As Character
   PRIVATE isOpen As Logical
   PRIVATE isPaused As Logical
   PRIVATE mediaName := "media"
   PRIVATE notifyHandle

   SET EVENTS FUNCTION TO MYEVENTS

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 475 HEIGHT 155 ;
      MAIN ;
      TITLE "Mini MP3 Player" ;
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
      mciSendString(playCommand, NIL, 0, NIL)
      isOpen := FALSE
   ENDIF

RETURN

*-------------------------------------------*
STATIC PROCEDURE OpenMediaFile()
*-------------------------------------------*

   LOCAL playCommand

   ClosePlayer()
   playCommand := "Open " + fileName + " type mpegvideo alias " + mediaName
   mciSendString(playCommand, NIL, 0, NIL)
   isOpen := TRUE

RETURN

*-------------------------------------------*
STATIC PROCEDURE PlayMediaFile()
*-------------------------------------------*

   LOCAL playCommand

   IF isOpen
       playCommand := "Play " + mediaName + " notify"
       mciSendString(playCommand, NIL, 0, notifyHandle)
   ENDIF

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
FUNCTION Play( file, notifyForm )
*-------------------------------------------*

   fileName := _GetShortPathName( File )
   notifyHandle := notifyForm

   IF isPaused
      ResumeMediaFile()
   ELSE
      OpenMediaFile()
      PlayMediaFile()
   ENDIF

RETURN NIL

*-------------------------------------------*
STATIC PROCEDURE RefreshStop( stop )
*-------------------------------------------*

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
#include "hbdll32.ch"
declare ansi mciSendString( command,  returnValue,  returnLength,  hWnd ) IN WINMM.DLL
//mciSendString 
/*
DECLARE DLL_TYPE_LONG mciSendString( ;
	DLL_TYPE_LPSTR command, DLL_TYPE_LPTSTR returnValue, DLL_TYPE_INT returnLength, DLL_TYPE_LONG hWnd ) ;
	IN WINMM.DLL
*/