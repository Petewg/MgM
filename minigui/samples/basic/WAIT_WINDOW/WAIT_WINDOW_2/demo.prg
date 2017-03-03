/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2015 Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "minigui.ch"

STATIC nStaticLogo

PROCEDURE Main

   DEFINE WINDOW Form1 ;
	AT 0 , 0 ;
	WIDTH 600 HEIGHT 400 ;
	TITLE "Window with expectation (preloading)" ;
        BACKCOLOR SILVER ;
	MAIN 

        @ 50,20 BUTTON Btn_Start CAPTION "Start!" WIDTH 140 HEIGHT 48 ;
          ACTION WaitingProcess() 

        @ 130,20 BUTTON Btn_End CAPTION "Close" WIDTH 140 HEIGHT 48   ;
          ACTION ThisWindow.Release() 

   END WINDOW

   CENTER WINDOW Form1
   ACTIVATE WINDOW Form1

RETURN

///////////////////////////////////////////////////////////////////
FUNCTION WaitingProcess()
   LOCAL nI, nTime, aBegin, nForEnd := 500

   // Create the window waiting
   aBegin := WaitWinCreate( 'Wait a little while being processed ...' )  

   nTime := SECONDS()

   FOR nI := 1 TO nForEnd

      IF (nI % 5) == 0
         WaitWinTimer(aBegin,HB_NtoS(nI) + "/" + HB_NtoS(nForEnd))  // Show the window waiting
      ENDIF

      // final waiting
      INKEYGUI()

   NEXT

   WaitWinClose( aBegin[1] )  // kill the window waiting

   MsgInfo( "Elapsed processing time - " + SECTOTIME( SECONDS() - nTime ) )

RETURN NIL

//////////////////////////////////////////////////////////////////////////////
FUNCTION WaitWinCreate( cTitle, lCenter, nWRow, nWCol)
   LOCAL cFormName := "WaitWin_" + HB_NtoS( _GetId() ) 
   LOCAL nTime := SECONDS()
   LOCAL aPict := {"FR01","FR02","FR03","FR04","FR05","FR06","FR07","FR08",;
                   "FR09","FR10","FR11","FR12"}
   DEFAULT cTitle := "Wait", lCenter := .T., nWRow := 0, nWCol := 0

   nStaticLogo := 1  // assign a number to display picture

   SET INTERACTIVECLOSE OFF

   DEFINE WINDOW &cFormName ;
     ROW 0 COL 0          ;
     WIDTH 420 HEIGHT 230 ;
     TITLE ''             ;
     MINWIDTH 420 MINHEIGHT 230 ;
     MAXWIDTH 420 MAXHEIGHT 230 ;
     CHILD NOCAPTION      ;
     TOPMOST              ; 
     BACKCOLOR WHITE      ;
     FONT 'Tahoma' SIZE 12

     @ 10, 10 LABEL Label_1   ;
       WIDTH 400 HEIGHT 20 ;
       VALUE "Time passed " + TIME() ;
       CENTERALIGN VCENTERALIGN TRANSPARENT

     @ 40, (420-128)/2 IMAGE Image_1 PICTURE aPict[nStaticLogo] ;
       WIDTH 128 HEIGHT 128 ;
       WHITEBACKGROUND TRANSPARENT

     @ 178, 10 LABEL Label_2   ;
       WIDTH 400 HEIGHT 20 ;
       VALUE cTitle        ;
       CENTERALIGN VCENTERALIGN TRANSPARENT

   END WINDOW

   IF lCenter == .F.
      SetProperty( cFormName, "Row", nWRow )
      SetProperty( cFormName, "Col", nWCol )
   ELSE
      Center Window &cFormName
   ENDIF

   Activate Window &cFormName NoWait

RETURN { cFormName, aPict, nTime } // return the number of windows to then kill him by the window

//////////////////////////////////////////////////////////////////////
FUNCTION WaitWinTimer( aDim, cExtra )
   LOCAL cFormName := aDim[1], aPict := aDim[2], cTime, nTime := aDim[3]

      cTime := cExtra + "      Time passed " + SECTOTIME( SECONDS() - nTime )
      SetProperty( cFormName, "Label_1", "Value", cTime )

      nStaticLogo ++  // the number of display picture
      nStaticLogo := IIF( nStaticLogo > LEN(aPict), 1, nStaticLogo )
      SetProperty( cFormName, "Image_1", "Picture", aPict[nStaticLogo] )

RETURN NIL

//////////////////////////////////////////////////////////////////////
FUNCTION WaitWinClose( cFormName )

   SET INTERACTIVECLOSE ON

   Domethod( cFormName, "Release" )

   DO MESSAGE LOOP

RETURN NIL
