/*
   Multi-Thread sample by Roberto Lopez. 
   
   Modified / Enhanced by p.d. 08/Jul/2016
*/

#include <hmg.ch>

Set Procedure To Actions.prg

STATIC pClockThread, pProgThread // hold pointers of threads


PROCEDURE Main
   
   LOAD WINDOW MainWin
   
   MainWin.Button_1.Cargo := .F.
   MainWin.Button_2.Cargo := .F.

   ShowThreadsIDs()
   
   MainWin.Center
   MainWin.Activate

   RETURN


FUNCTION Show_Time()

   // please note that this function will NEVER return the control!
   // but do not 'locks' the user interface since it is running in a separate thread 

   DO WHILE .T.

      MainWin.label_1.value := Time()
      hb_idleSleep( 0.1 )

   ENDDO

   RETURN NIL


FUNCTION Show_Progress()
   LOCAL nValue
      
   DO WHILE .T.

      nValue := MainWin.progressBar_1.value
      nValue ++

      if nValue > 10
         nValue := 1
      endif

      MainWin.progressBar_1.value := nValue

      hb_idleSleep( 0.2 )

   ENDDO
   
   RETURN NIL

   
PROCEDURE ShowThreadsIDs()

   MainWin.Frame_2.Caption := "Clock (Thread pointer: " + hb_ntos( win_P2N( pClockThread ) ) +")"
   MainWin.Frame_3.Caption := "Progressbar (Thread pointer: " + hb_ntos( win_P2N( pProgThread ) ) +")"

   RETURN
