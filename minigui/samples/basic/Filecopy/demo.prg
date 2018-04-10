/*
 * FileCopy with Progressbar HMG - Demo
 *
 * Copyright 2004 Jacek Kubica <kubica@wssk.wroc.pl>
 * http://www.wssk.wroc.pl/~kubica
 *
 * Revised by Grigory Filatov, June 2013
*/

#include "minigui.ch"

#define _TITLE  'FileCopy demo by Jacek Kubica <kubica@wssk.wroc.pl>'

#define _SHOW_PERCENT 5

#define _SMALL_BLOCK 2048
#define _DEFAULT_BLOCK 4096
#define _LARGE_BLOCK 8192


***********************************
FUNCTION Main()
***********************************
   LOCAL WybFol

   DEFINE WINDOW Form_1 AT 0, 0 WIDTH 483 HEIGHT 230 ;
      MAIN ;
      TITLE "HMG FileCopy Demo" ;
      NOSIZE NOMAXIMIZE

   @ 6, 1     FRAME Frame_1 CAPTION "" WIDTH 474 HEIGHT 128

   @ 29, 20   LABEL Label_1 VALUE "Source file:" HEIGHT 19 FONT "Arial" SIZE 9 AUTOSIZE
   @ 28, 110  TEXTBOX TextBox_1 WIDTH 298 HEIGHT 19
   @ 26, 414  BUTTON Button_1 CAPTION "..." WIDTH 39 HEIGHT 23 ;
              ACTION  {|| Form_1.TextBox_1.Value := Getfile ( { { 'All files ', '*.*' } }, 'Select file to copy' ) }

   @ 62, 20   LABEL Label_2 VALUE "Destination:" WIDTH 86 HEIGHT 18
   @ 61, 110  TEXTBOX TextBox_2 WIDTH 298 HEIGHT 19
   @ 59, 414  BUTTON Button_2 CAPTION "..." WIDTH 39 HEIGHT 23 ;
              ACTION  {|| WybFol := GetFolder(), ;
                 Form_1.TextBox_2.Value := WybFol + iif( Right( WybFol, 1 ) $ "\/", "", "\" ) + MyGetFileName( Form_1.TextBox_1.Value ) }

   @ 84, 200  LABEL Label_3 VALUE "" WIDTH 271 HEIGHT 16
   @ 103, 20  PROGRESSBAR ProgressBar_1 RANGE 0, 100 WIDTH 435 HEIGHT 21

   @ 146, 96  BUTTON Button_3 CAPTION "Copy" WIDTH 100 HEIGHT 24 ;
      ACTION  FILECOPY( Form_1.TextBox_1.Value, Form_1.TextBox_2.Value, _LARGE_BLOCK, {| nArg| show_it( nArg ) } )

   @ 146, 292 BUTTON Button_4 CAPTION "Exit" WIDTH 100 HEIGHT 24 ACTION ThisWindow.Release

   DEFINE STATUSBAR FONT "Arial" SIZE 9
      STATUSITEM _TITLE
   END STATUSBAR

   END WINDOW

   Form_1.Center
   Form_1.Activate

   RETURN NIL

*******************************************************************
FUNCTION FILECOPY( cSource, cDestination, nBuffer, bBlock )
*******************************************************************
   LOCAL sourceHandle, destHandle, lSuccess := .F., TmpBuff, LastPos
   LOCAL BuffPos, ByteCount, cBType := ValType( bBlock )

   DEFAULT nBuffer := _DEFAULT_BLOCK

   IF File( cDestination )
      IF !MsgYesNo( "Destination file already exist. Overwrite ?", "Warning" )
         RETURN lSuccess
      ENDIF
   ENDIF

   Form_1.StatusBar.Item( 1 ) := "Copying in progress ..."
   IF ( ( sourceHandle := FOpen( cSource, 0 ) ) != -1 )
      IF ( ( destHandle := FCreate( cDestination, 0 ) ) != -1 )
         LastPos := FSeek( sourceHandle, 0, 2 )
         BuffPos := 0
         // ByteCount:= 0
         FSeek( sourceHandle, 0, 0 )
         DO WHILE ( BuffPos < LastPos )
            TmpBuff := Space( nBuffer )
            BuffPos += ( ByteCount := FRead( sourceHandle, @TmpBuff, nBuffer ) )
            FWrite( destHandle, TmpBuff, ByteCount )
            IF cBType == "B"
               Eval( bBlock, BuffPos / LastPos )
            ENDIF
         ENDDO
         lSuccess := FClose( destHandle )
      ENDIF
      FClose( sourceHandle )
   ENDIF

   IF lSuccess
      Form_1.StatusBar.Item( 1 ) := "Filecopy finished successfully"
   ELSE
      Form_1.StatusBar.Item( 1 ) := "Filecopy failed !"
   ENDIF

   InKeyGUI( 1000 )

   Form_1.ProgressBar_1.Value := 0
   Form_1.Label_3.Value := ""
   Form_1.StatusBar.Item( 1 ) := _TITLE

   RETURN lSuccess

***********************************
FUNCTION SHOW_IT( nDl )
***********************************
   LOCAL nPos := Int( nDl * 100 )

   IF ( nPos % _SHOW_PERCENT == 0 )
      Form_1.Label_3.Value := hb_ntos( nPos ) + " % complete"
      Form_1.ProgressBar_1.Value := nPos
      DO EVENTS
      IF IsVistaOrLater()
         InKeyGUI()
      ENDIF
   ENDIF

   RETURN NIL

***********************************
FUNCTION MyGetFileName( rsFileName )
***********************************
   LOCAL i

   FOR i = Len( rsFileName ) TO 1 STEP -1
      IF SubStr( rsFileName, i, 1 ) $ "\/"
         EXIT
      ENDIF
   NEXT

   RETURN SubStr( rsFileName, i + 1 )
