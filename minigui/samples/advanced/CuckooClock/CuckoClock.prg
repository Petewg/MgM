/*

  MINIGUI - Harbour Win32 GUI library Demo/Sample

  Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
  http://harbourminigui.googlepages.com

  'CuckooClock' is Open Source/Freeware HMG Demo / Sample

  All bug reports and suggestions are welcome.

  Developed with MiniGUI  - Harbour Win32 GUI library (HMG),
  Compiled and Linked with Harbour Compiler and MinGW.

  Thanks to "Le Roy" Roberto Lopez.

  Copyright 2009 © Bicahi Esgici <esgici @ gmail.com>

  History : 2009-6 : First Release


  Notes : 

   - 'CuckooClock' uses "LcdD" font and this font is in LCDN.TTF font file. 
     This font file exists in standard distribution of Windows XP but as far as I know
     not found in Vista. If so you can use it simply by copying this font file to your 
     Windows\fonts folder. You can use anything else of course. 

   - This sample is a standalone application. If you want use it into your own application :
     add CuckooClock() calling line to your main window's ON INIT event and change "MAIN" 
     property of frmCuckooClock to "CHILD"

   - For seeing CDOW() ( Name of day of week ) in your own language 
     add following two lines at top of Main() procedure / function :

     REQUEST HB_LANG_xx
     HB_LANGSELECT( "xx" ) 

     and replace "xx" in it with your language code.

*/

#include "minigui.ch"

#define CLR_BACK     { 0, 0, 160 }

DECLARE WINDOW frmCuckooClock

PROC Main()

   LOCAL bHideShow := { || iif(IsWindowVisible( GetFormHandle( 'frmCuckooClock' ) ), frmCuckooClock.Hide, frmCuckooClock.Show ) }

   SET CENT ON
   SET DATE GERM

*   REQUEST HB_LANG_ESWIN
*   HB_LANGSELECT( "ESWIN" ) 

   DEFINE WINDOW Form_1 ;
	AT 0,0 ;
	WIDTH 0 HEIGHT 0 ;
	ICON 'demo.ico' ;
	MAIN NOSHOW ;
	ON INIT CuckooClock() ;
	NOTIFYICON 'demo.ico' ;
	NOTIFYTOOLTIP 'Cuckoo Clock' ;
	ON NOTIFYCLICK Eval( bHideShow )

	DEFINE NOTIFY MENU
           MENUITEM "Hide/Show" ACTION Eval( bHideShow )
           SEPARATOR
           MENUITEM "Close" ACTION Form_1.Release
	END MENU

   END WINDOW // Form_1

   Form_1.Activate
   
RETU // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

STATIC PROC CuckooClock( nCaller )

   STATIC lIsColon := .T. ,;
          lSound   := .T. ,;
          lSeconds := .T. ,;
          aLMetrcs := { { 40, 10, 40, 10, 40 }, { 25, 40, 10, 40, 25 } }

   LOCAL cFrmName    := '' ,;
         aCCPrpArray := ARRAY( 5 ),;
         cCurTime    := TIME(),;
         aTmpColor   := {},;
         nLblType ,;
         nlblRow     := 5,;
         nlblWidth,;
         nDigit   ,;
         cDigit

   IF HB_ISNIL( nCaller )
   
      If AddFont() == 0
         MsgStop( "An error is occured at installing the font Lcdn.ttf", "Warning" )
      EndIf

      DEFINE WINDOW frmCuckooClock ;
         AT GetDesktopHeight() - 75 - GetTaskBarHeight(), GetDesktopWidth() - 150 ; 
         WIDTH  150 ; 
         HEIGHT  75 ;
         TITLE 'Cuckoo Clock' ;
         CHILD ; 
         NOCAPTION ;
         NOSIZE ;
         NOMAXIMIZE ;
         BACKCOLOR BLUE ;
         TOPMOST ;
         ON MOVE CoordsCorr() ;
         ON INIT CuckooClock( 0 ) ;
         ON RELEASE RemoveFont()

         ON KEY ESCAPE ACTION ReleaseAllWindows()

         nlblRow   := 5

         FOR nDigit := 1 TO 5
            cDigit := "lblClock" + LTRIM( STR( nDigit ) ) 
            nlblWidth := aLMetrcs[ 1, nDigit ] 
            IF nDigit < 5
               @ 5, nlblRow LABEL &cDigit HEIGHT 40 WIDTH nlblWidth FONT "LcdD" SIZE 25 CENTERALIGN BACKCOLOR CLR_BACK FONTCOLOR WHITE ;
                    ACTION InterActiveMoveHandle( GetFormHandle( 'frmCuckooClock' ) )
            ELSE
               @ 5, nlblRow LABEL &cDigit HEIGHT 40 WIDTH nlblWidth FONT "LcdD" SIZE 25 BACKCOLOR CLR_BACK FONTCOLOR WHITE ;
                    ACTION InterActiveMoveHandle( GetFormHandle( 'frmCuckooClock' ) )
            ENDIF
            nlblRow += nlblWidth
         NEXT    

         DEFINE TIMER tmrClock INTERVAL 1000 ACTION CuckooClock( 0 )

         @ 45, 5 LABEL lblDate HEIGHT 24 WIDTH 140 VALUE DATE() FONT "Tahoma" SIZE 10 CENTERALIGN BACKCOLOR CLR_BACK FONTCOLOR YELLOW ;
                 ACTION InterActiveMoveHandle( GetFormHandle( 'frmCuckooClock' ) )

         DEFINE CONTEXT MENU
            MENUITEM "Backcolor"                     ACTION CuckooClock( 1 )
            MENUITEM "Watch color"                   ACTION CuckooClock( 2 )
            MENUITEM "Date color"                    ACTION CuckooClock( 3 )
            MENUITEM "Sound"   NAME cmuSound CHECKED ACTION CuckooClock( 4 )
            MENUITEM "Seconds" NAME cmuSecos CHECKED ACTION CuckooClock( 5 )
            MENUITEM "Hide"                          ACTION frmCuckooClock.Hide
            SEPARATOR
            MENUITEM "Close   ( Esc)"                ACTION ReleaseAllWindows()
         END MENU

      END WINDOW // frmCuckooClock

      frmCuckooClock.Activate

   ELSE

      cFrmName := ThisWindow.Name

      IF nCaller > 0  

         IF nCaller > 4     // 5: Seconds

            lSeconds := !lSeconds
            frmCuckooClock.cmuSecos.Checked := lSeconds

            nLblType  := IF( lSeconds, 1, 2 )

            FOR nDigit := 1 TO 5
               cDigit := "lblClock" + LTRIM( STR( nDigit ) ) 
               nlblWidth := aLMetrcs[ nLblType, nDigit ]
               SetProperty( cFrmName, cDigit, "COL",   nlblRow  )
               SetProperty( cFrmName, cDigit, "WIDTH", nlblWidth  )
               SetProperty( cFrmName, cDigit, "VALUE", '' )
               nlblRow += nlblWidth
            NEXT    

            lIsColon := lSeconds

         ELSEIF nCaller > 3     // 4: Sound 
            lSound := !lSound
            frmCuckooClock.cmuSound.Checked := lSound
         ELSE                   // 1..3 : Colors
            IF nCaller == 1 // Back Color
               aTmpColor := frmCuckooClock.lblDate.BackColor
            ELSEIF nCaller == 2 // Oclok ForeColor
               aTmpColor := frmCuckooClock.lblClock1.FontColor
            ELSEIF nCaller == 3 // Date ForeColor
               aTmpColor := frmCuckooClock.lblDate.FontColor
            ENDIF

            aTmpColor := GetColor( aTmpColor )

            IF !HB_ISNIL( aTmpColor[ 1 ] )
               IF nCaller == 1 // Back Color
                  AFILL( aCCPrpArray, aTmpColor )
                  CCSetProp( cFrmName, "BackColor", aCCPrpArray )
                  frmCuckooClock.lblDate.BackColor   := aTmpColor
               ELSEIF nCaller == 2 // Oclok ForeColor
                  AFILL( aCCPrpArray, aTmpColor )
                  CCSetProp( cFrmName, "FontColor", aCCPrpArray )
               ELSEIF nCaller == 3 // Date ForeColor
                  frmCuckooClock.lblDate.FontColor := aTmpColor
               ENDIF
            ENDIF !HB_ISNIL( aTmpColor[ 1 ] )
         ENDIF

      ENDIF nCaller > 0  // Colors
   ENDIF HB_ISNIL( nCaller )

   IF lSound
      IF RIGHT( cCurTime, 2 ) == "00"
         IF SUBS( cCurTime, 4, 2 ) == "00"
            PLAY WAVE "RESWAVC2" FROM RESOURCE
         ELSEIF SUBS( cCurTime, 4, 2 ) == "30"
            PLAY WAVE "RESWAVC1" FROM RESOURCE
         ENDIF
      ENDIF
   ENDIF lSound

   IF lSeconds
      aCCPrpArray := { SUBS( cCurTime, 1, 2 ), ":", SUBS( cCurTime, 4, 2 ), ":", SUBS( cCurTime, 7, 2 ) }
   ELSE
      lIsColon := !lIsColon
      aCCPrpArray := { '', SUBS( cCurTime, 1, 2 ), IF( lIsColon, ":", '' ), SUBS( cCurTime, 4, 2 ), '' }
   ENDIF lSeconds

   CCSetProp( cFrmName, "Value", aCCPrpArray )

   frmCuckooClock.lblDate.Value  := DTOC( DATE() ) + "-" + CDOW( DATE() )

RETU // CuckooClock()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

STATIC PROC CCSetProp( cFrmName, cProperty, aValues )

   LOCAL nDigit,;
         cDigit

   FOR nDigit := 1 TO 5
      cDigit := "lblClock" + LTRIM( STR( nDigit ) )
      SetProperty( cFrmName, cDigit, cProperty, aValues[ nDigit ] )
   NEXT

RETU // CCSetProp()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

STATIC PROC CoordsCorr()

   LOCAL nTop := frmCuckooClock.Row,;
         nLeft := frmCuckooClock.Col
         
   IF nTop < 0
      SetProperty( 'frmCuckooClock', 'Row', 0 )
   ENDIF

   IF nLeft < 0
      SetProperty( 'frmCuckooClock', 'Col', 0 )
   ENDIF

   IF nTop + 75 > GetDesktopHeight() - GetTaskBarHeight()
      SetProperty( 'frmCuckooClock', 'Row', GetDesktopHeight() - 75 - GetTaskBarHeight() )
   ENDIF

   IF nLeft + 150 > GetDesktopWidth()
      SetProperty( 'frmCuckooClock', 'Col', GetDesktopWidth() - 150 )
   ENDIF

RETU // CoordsCorr()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

#define FR_PRIVATE   0x10
#define FR_NOT_ENUM  0x20

Static Function AddFont()

Return AddFontResourceEx( "Lcdn.ttf", FR_PRIVATE+FR_NOT_ENUM, 0 )

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

Static Function RemoveFont()

Return RemoveFontResourceEx( "Lcdn.ttf", FR_PRIVATE+FR_NOT_ENUM, 0 )

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

DECLARE DLL_TYPE_INT AddFontResourceEx ( DLL_TYPE_LPCTSTR lpszFilename, DLL_TYPE_DWORD flag, DLL_TYPE_LPVOID pdv ) IN GDI32.DLL
DECLARE DLL_TYPE_BOOL RemoveFontResourceEx ( DLL_TYPE_LPCTSTR lpFileName, DLL_TYPE_DWORD flag, DLL_TYPE_LPVOID pdv ) IN GDI32.DLL

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC ( INTERACTIVEMOVEHANDLE )
{
	keybd_event(
		VK_RIGHT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);
	keybd_event(
		VK_LEFT,	// virtual-key code
		0,		// hardware scan code
		0,		// flags specifying various function options
		0		// additional data associated with keystroke
	);

	SendMessage( (HWND) hb_parnl(1), WM_SYSCOMMAND, SC_MOVE, 10 );
}

#pragma ENDDUMP
