#include "hmg.ch"

#define HB_THREAD_INHERIT_PUBLIC 1

DECLARE WINDOW MainWin


FUNCTION main_button_1_action( /*@*/ pClockThread )

   IF MainWin.Button_1.Cargo
   
      IF ! hb_threadQuitRequest( pClockThread )
         msgExclamation( "Can't stop thread!" )
      ELSE
         MainWin.Button_1.Cargo := .F.
         MainWin.label_1.FontBold := .F.
         MainWin.label_1.FontSize := 10
         MainWin.label_1.Value := "00:00:00"
         MainWin.button_1.Caption := "Start Clock Thread"
         pClockThread := NIL
      ENDIF

      ShowThreadsIDs()
      RETURN NIL

   ENDIF

   IF ! hb_mtvm()

      msgStop( "There is no support for multi-threading, clock will not be seen." )

   ELSE
      
      MainWin.label_1.FontBold := .T.
      MainWin.label_1.FontSize := 12
      MainWin.button_1.Caption := "Click to Stop Clock"

      pClockThread := hb_threadStart( HB_THREAD_INHERIT_PUBLIC, @Show_Time() )
      MainWin.Button_1.Cargo := .T.

   ENDIF
   
   ShowThreadsIDs()
   
   RETURN NIL


FUNCTION main_button_2_action( /*@*/ pProgThread )
   
   IF MainWin.Button_2.Cargo
   
      IF ! hb_threadQuitRequest( pProgThread )
         msgExclamation( "Can't stop thread!")
      ELSE
         MainWin.Button_2.Cargo := .F.
         MainWin.progressBar_1.value := 0
         MainWin.button_2.Caption := "Start ProgressBar Thread"
         pProgThread := NIL
      ENDIF

      ShowThreadsIDs()
      RETURN NIL

   ENDIF
   
   IF ! hb_mtvm()

      msgStop("There is no support for multi-threading, ProgressBar will not be seen.")

   ELSE

      MainWin.button_2.Caption := "Click to Stop progress"

      pProgThread := hb_threadStart( HB_THREAD_INHERIT_PUBLIC , @Show_Progress() )
      MainWin.Button_2.Cargo := .T.

   ENDIF

   ShowThreadsIDs()
   
   RETURN NIL


FUNCTION main_button_3_action( pClockThread, pProgThread )
   
   MainWin.Button_31.Enabled := .T.
   
   IF HB_ISPOINTER( pClockThread )
      main_button_1_action( @pClockThread )
   ENDIF
   IF HB_ISPOINTER( pProgThread )
      main_button_2_action( @pProgThread )
   ENDIF
   
   ShowThreadsIDs()
   
   RETURN hb_threadTerminateAll()


FUNCTION main_button_31_action( /*@*/ pClockThread, /*@*/ pProgThread )

   main_button_1_action( @pClockThread )
   main_button_2_action( @pProgThread )
   MainWin.Button_31.Enabled := !( MainWin.Button_1.Cargo .OR. MainWin.Button_2.Cargo )

   ShowThreadsIDs()
   
   RETURN NIL
   
   
FUNCTION main_button_4_action( pClockThread, pProgThread )

   LOCAL nClockID := Iif( HB_ISPOINTER( pClockThread ), hb_threadId( pClockThread ), 0 )
   LOCAL nProgID := Iif( HB_ISPOINTER( pProgThread ), hb_threadId( pProgThread ), 0 )
   LOCAL cClock := "", cProg := ""   

   IF ! Empty( pClockThread )
      cClock := "Clock"
   ENDIF
      
   IF ! Empty( pProgThread )
      cProg := "Progressbar"
   ENDIF
   
   msgInfo( hb_StrFormat( "Currently running threads: %s (ID: %d), %s (ID: %d)", ;
                          cClock, nClockID , cProg, nProgID ) ) 

   RETURN NIL
