/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
*/

ANNOUNCE RDDSYS

#include <hmg.ch>

#define PROGRAM 'CPU Speed / Clock Checker (Press Esc or Alt+X to exit)'
#define VERSION ' version 1.1'
#define CREATOR ' Pete D. 2016 - (UI based on a sample by G. Filatov)'
#define CLR_SPEED NAVY

STATIC cFontName
STATIC nFontSize
STATIC nSpeed

****************************************************
Procedure Main()
****************************************************

   LOCAL cSpeed
   
   cFontName := iif( IsVistaOrLater(), "Segoe UI", "Times New Roman" )
   nFontSize := 40
  
   cSpeed := GetCPUSpeed() + " MHz"
   nSpeed := Val( cSpeed )

   SET MULTIPLE OFF

   DEFINE WINDOW Form_1 ;
      WIDTH 392 HEIGHT 148 - IF(IsThemed(), 0, 8) ;
      TITLE cSpeed ;
      ICON 'MAIN' ;
      MAIN ;
      NOMAXIMIZE NOSIZE

      @ 5,5 LABEL Label_1a VALUE PROGRAM AUTOSIZE TRANSPARENT FONTCOLOR WHITE
      @ 4,4 LABEL Label_1b VALUE PROGRAM AUTOSIZE TRANSPARENT

      @ 26,12 LABEL Label_2a VALUE cSpeed WIDTH 360 HEIGHT 68 ;
         FONT cFontName SIZE nFontSize BOLD ITALIC ;
         CENTERALIGN TRANSPARENT FONTCOLOR WHITE

      @ 24,10 LABEL Label_2b VALUE cSpeed WIDTH 360 HEIGHT 68 ;
         FONT cFontName SIZE nFontSize BOLD ITALIC ;
         CENTERALIGN TRANSPARENT FONTCOLOR CLR_SPEED

      @ Form_1.Height-iif(IsWinNT(), 48, 44),11 LABEL Label_3a VALUE "Created by "+ CREATOR ;
         WIDTH 360 HEIGHT 16 CENTERALIGN TRANSPARENT FONTCOLOR WHITE

      @ Form_1.Height-iif(IsWinNT(), 49, 45),10 LABEL Label_3b VALUE "Created by " + CREATOR ;
         WIDTH 360 HEIGHT 16 CENTERALIGN TRANSPARENT

      @ 0,0 LABEL Label_4 VALUE "" WIDTH 1 HEIGHT 1 // dummy label for proper drawing of label's shadow

      DEFINE TIMER Timer_1 INTERVAL 5000 ACTION RefreshSpeed()

      ON KEY ALT+X ACTION Form_1.Release
      ON KEY ESCAPE ACTION Form_1.Release

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN


****************************************************
STATIC PROCEDURE RefreshSpeed()
****************************************************

   LOCAL cSpeed := GetCPUSpeed()
   
   IF nSpeed <> Val( cSpeed )
   
      nSpeed := Val( cSpeed )
      cSpeed += " MHz"
      Form_1.Title := cSpeed

      IF IsControlDefined( Label_2a, Form_1 )

         Form_1.Label_2a.Release

         @ 26,12 LABEL Label_2a OF Form_1 VALUE cSpeed ;
            WIDTH 360 HEIGHT 68 ;
            FONT cFontName SIZE nFontSize BOLD ITALIC ;
            CENTERALIGN TRANSPARENT FONTCOLOR WHITE

      ENDIF

      Form_1.Label_2b.Release

      @ 24,10 LABEL Label_2b OF Form_1 VALUE cSpeed ;
         WIDTH 360 HEIGHT 68 ;
         FONT cFontName SIZE nFontSize BOLD ITALIC ;
         CENTERALIGN TRANSPARENT FONTCOLOR CLR_SPEED

   ENDIF
   
   RETURN

/* Using of the WMI command line CPU CurrentClockSpeed query */
****************************************************
FUNCTION GetCPUSpeed()
****************************************************

   LOCAL hResult, cResult, n
   LOCAL cCommand := "wmic.exe cpu get CurrentClockSpeed /VALUE"
   LOCAL cSpeed := "?"
   
   hResult := SysCmd( cCommand, @cResult )
   
   IF hResult != -1
   
      n := At( "=", cResult )
   
      cSpeed := Substr( cResult, n + 1 )  // get Current Clock Speed
      
   ENDIF
   
   IF cSpeed == "?"
      msgInfo( "Try to run program outside of a batch file!")
      QUIT
   ENDIF

   RETURN cSpeed


****************************************************
FUNCTION SysCmd( cCommand, /*@*/ cResult )
****************************************************

   LOCAL hProcess
   LOCAL hStdOut, hStderr, nState, nBytes
   LOCAL cBuff := Space( 1024 )

   // hProcess := HB_PROCESSOPEN( <cCommand>, NIL, @hStdOut, @hStderr, lDetach )
   hProcess := hb_ProcessOpen( cCommand, NIL, @hStdOut, @hStdErr, .T. )
   
   IF hProcess != -1
      
      // nState := hb_ProcessValue( hProcess, lWait )
      nState := hb_ProcessValue( hProcess, .T. )

      WHILE nState <> -1

         nBytes := FRead( hStdOut, @cBuff, 1024 /* cBuff length */ )

         IF nBytes == 0
            EXIT
         ENDIF
           
         nState := hb_ProcessValue( hProcess, .T. )
         
      END

      cBuff := StrTran( cBuff, Chr( 13 ) )
      cBuff := StrTran( cBuff, Chr( 10 ) )
      cResult := Alltrim( StrUnspace( cBuff ) )
      
      hb_ProcessClose( hProcess )

   ENDIF
   
   RETURN hProcess

/* Converts multiple spaces to just one. | source: C:\Harbour\config\lang.hb */
****************************************************
STATIC FUNCTION StrUnspace( cString ) 
****************************************************

   LOCAL cResult := ""
   LOCAL cChar, cCharPrev
   LOCAL tmp

   FOR tmp := 1 TO Len( cString )

      cChar := SubStr( cString, tmp, 1 )

      IF !( cChar == " " ) .OR. !( cCharPrev == " " )
         cResult += cChar
      ENDIF

      cCharPrev := cChar

   NEXT

   RETURN cResult   
