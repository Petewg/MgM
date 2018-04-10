/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Потоки в MiniGui / Streams in MiniGui
 * Прелодер в MiniGui / Preloader in MiniGui
 *
 * Copyright 2015 Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Пример показа прелодера. Отображение процесса загрузки: файла, индекса, расчётов и т.д.
 * Example of the show preloader. Displays the boot process: file, index calculations, etc.
*/

#include "minigui.ch"
#include "hbthread.ch" 

// имя формы - окна "ожидания" / the name of the form - the window "waiting"
STATIC cStatWinWait  := ""  
// для старта цикла в окне "ожидания"/ for the start of the cycle in the window "waiting"
STATIC lStatWinWait  := .T. 
// массив картинок для окна "ожидания" / an array of images to window "waiting"
STATIC aStatPictWait := {"FR01","FR02","FR03","FR04","FR05","FR06","FR07","FR08",;
                         "FR09","FR10","FR11","FR12"}

PROCEDURE MAIN

   IF !hb_mtvm()
      MsgStop ("No support for multi-threading!" + CRLF + CRLF + ;
                "Compiling with a key /mt" + CRLF )
      QUIT
   ENDIF

   SET FONT TO "Tahoma", 14
 
   DEFINE WINDOW Form_1 AT 100,100 ;
       WIDTH 500 HEIGHT 400 ;
       MAIN ;
       BACKCOLOR TEAL  ;
       TITLE "Window with expectation (preloading) in stream" 

       @ 60, 0  LABEL Label_1 VALUE "Waiting for the start of the calculation ..." ;
         WIDTH 500 HEIGHT 60 FONTCOLOR WHITE BOLD TRANSPARENT CENTERALIGN

       @ 160,20 BUTTON Btn_Start CAPTION "Start!" WIDTH 190 HEIGHT 48 ACTION StartSample() 

       @ 260,20 BUTTON Btn_Close CAPTION "Exit"  WIDTH 190 HEIGHT 48 ACTION ThisWindow.Release()

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN

////////////////////////////////////////////////////////////
FUNCTION StartSample()
   LOCAL cMsg, nTime, nI

   nTime := SECONDS()

   Form_1.Btn_Start.Enabled := .F. // lock a button

   // Create the window waiting with the flow
   WaitThreadCreate( 'Wait a little while being processed ...' )

   // Main loop calculations (for example, OLE for Excel)
   FOR nI := 1 TO 100

      Form_1.Label_1.Value :=  "There is a calculation: " + HB_NtoS(nI) + "/100"

      // final waiting
      INKEYGUI(100)

   NEXT

   WaitThreadClose()   // close the "expectations" window

   cMsg := "The calculation is carried out - 100" + CRLF + CRLF
   cMsg += "Elapsed processing time - " + SECTOTIME( SECONDS() - nTime ) 
   MsgInfo(cMsg)

   Form_1.Btn_Start.Enabled := .T. // unlock a button

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
FUNCTION WaitThreadCreate( cTitle ) 
   LOCAL cFormName := "WaitWin_" + HB_NtoS( _GetId() ) 
   DEFAULT cTitle := "Working..."

   // transfer window name "standby" in the public variable
   // передать имя окна "ожидания" в public переменную
   cStatWinWait := cFormName  
   // To start an infinite loop in the flow preloding
   // для старта бесконечного цикла в потоке
   lStatWinWait := .T.  

   SET INTERACTIVECLOSE OFF

   DEFINE WINDOW &cFormName     ;
     WIDTH 420 HEIGHT 230       ;
     MINWIDTH 420 MINHEIGHT 230 ; 
     MAXWIDTH 420 MAXHEIGHT 230 ;
     MODAL NOCAPTION            ;
     BACKCOLOR WHITE            ;
     FONT 'Tahoma' SIZE 12      ;
     ON MOUSECLICK MoveActiveWindow() 

     @ 10,10 LABEL Label_1      ;
       WIDTH 400 HEIGHT 20      ;
       VALUE "Elapsed time " + TIME() ;
       CENTERALIGN VCENTERALIGN TRANSPARENT

     @ 40, (420-128)/2 IMAGE Image_1 PICTURE aStatPictWait[1] ;
       WIDTH 128 HEIGHT 128 ;
       STRETCH ;
       WHITEBACKGROUND TRANSPARENT

     @ 188, 10 LABEL Label_2    ;
       WIDTH 400 HEIGHT 20      ;
       VALUE cTitle             ;
       TRANSPARENT              ;
       CENTERALIGN VCENTERALIGN

   END WINDOW

   Center Window &cFormName
   Activate Window &cFormName NoWait

   // Start preloding in a separate thread
   // Запускаем preloding в отдельном потоке
   hb_threadDetach( hb_threadStart( HB_THREAD_INHERIT_MEMVARS, @WaitThreadTimer(), SECONDS() ) )

RETURN NIL

//////////////////////////////////////////////////////////////////////
FUNCTION WaitThreadClose()

   // завершить функцию в потоке / complete function in the stream
   lStatWinWait := .F.  
   InkeyGui(100) 

   SET INTERACTIVECLOSE ON

   Domethod( cStatWinWait, "Release" )

   DO MESSAGE LOOP

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
FUNCTION WaitThreadTimer(nTime)
   // Variable nTime is equal SECONDS() - gives an example of the transmission
   // переменная nTime равная SECONDS() - приведена в качестве примера передачи
   LOCAL cFormName, nLogo := 1, cTime

   cFormName := cStatWinWait

   DO WHILE lStatWinWait

      cTime := "Elapsed time " + SECTOTIME( SECONDS() - nTime )

      nLogo ++
      nLogo := iif( nLogo > LEN( aStatPictWait ), 1, nLogo )

      SetProperty( cFormName, "Label_1", "Value", cTime )
      SetProperty( cFormName, "Image_1", "Picture", aStatPictWait[ nLogo ] )

      InkeyGui(100) 

   ENDDO

RETURN NIL

/////////////////////////////////////////////////
#define HTCAPTION          2
#define WM_NCLBUTTONDOWN   161

PROCEDURE MoveActiveWindow( hWnd )
   DEFAULT hWnd := GetActiveWindow()

   PostMessage( hWnd, WM_NCLBUTTONDOWN, HTCAPTION, 0 )

   RC_CURSOR( "MINIGUI_FINGER" )

RETURN
