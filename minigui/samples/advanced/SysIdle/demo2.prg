/******************************************************
* Demo of detection of inactivity of keyboard and mouse
*******************************************************/

#include "hmg.ch"

Static nInterval := 60  // 60 seconds

*---------------------------------------
Function Main
*---------------------------------------

   SET NAVIGATION EXTENDED
   SET FONT TO "Tahoma", 10

   DEFINE WINDOW Win_1 ;
      AT 0,0 WIDTH 640 HEIGHT 480 ;
      TITLE "SysIdle Detection Test" ;
      MAIN ;
      ON INIT Win_1.Text_1.SetFocus()

      @12, 10 LABEL Label_1 VALUE "Caption_1" WIDTH 80 RIGHTALIGN

      @10, 100 TEXTBOX Text_1 ;
         VALUE 10 ;
         NUMERIC

      @42, 10 LABEL Label_2 VALUE "Caption_2" WIDTH 80 RIGHTALIGN

      @40, 100 TEXTBOX Text_2 ;
         VALUE 20 ;
         NUMERIC

      @72, 10 LABEL Label_3 VALUE "Caption_3" WIDTH 80 RIGHTALIGN

      @70, 100 TEXTBOX Text_3 ;
         VALUE 30 ;
         NUMERIC

      DEFINE STATUSBAR FONT "Tahoma" SIZE 9 KEYBOARD
        STATUSITEM ""
      END STATUSBAR

   END WINDOW

   DEFINE TIMER Timer_1 OF Win_1 INTERVAL 1000 ACTION Notification( .T. )

   Win_1.Center()
   Win_1.Activate()

Return Nil

*---------------------------------------
Static Function Notification( lLogOff )
*---------------------------------------
   IF SysIdleSecs() > nInterval

      Win_1.Timer_1.Enabled := .F.

      IF lLogOff
         MsgStop( "Application will be closed due to an inactivity!", "Stop!" )
         QUIT
      ELSE
         MsgAlert( "Application is inactive!", "Alert" )
      ENDIF

      Win_1.Timer_1.Enabled := .T.

   ENDIF

   Win_1.StatusBar.Item(1) := "Idle time elapsed: " + hb_ntos( SysIdleSecs() )

Return Nil

*---------------------------------------
*---------------------------------------

#pragma BEGINDUMP

#include "windows.h"
#include "hbapi.h"

WINUSERAPI BOOL WINAPI GetLastInputInfo(PLASTINPUTINFO);
typedef BOOL (WINAPI *GETLASTINPUTINFO_)(PLASTINPUTINFO);

HB_FUNC( SYSIDLESECS ) 
{
   HINSTANCE handle = LoadLibrary("user32.dll");

   if (handle)
   {
      GETLASTINPUTINFO_ pFunc;

      pFunc = GetProcAddress( handle, "GetLastInputInfo" );

      if( pFunc )
      {
         LASTINPUTINFO lpi;
  
         lpi.cbSize = sizeof(LASTINPUTINFO);

         if (!pFunc(&lpi))
         {
            hb_retni(0);
         }
         else
         {
            hb_retni( ( GetTickCount() - lpi.dwTime ) / 1000 ); 
         }
      }
   else
      hb_retni(0);
   }

   if( handle )
      FreeLibrary( handle );
}

#pragma ENDDUMP
