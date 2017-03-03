/*
 * FileCopy with Progressbar HMG - Demo
 *
 * Copyright 2004 Jacek Kubica <kubica@wssk.wroc.pl>
 * http://www.wssk.wroc.pl/~kubica
 *
 * Revised by Grigory Filatov, June 2013
*/

#include "minigui.ch"

#define _TITLE		'FileCopy demo by Jacek Kubica <kubica@wssk.wroc.pl>'

#define _SHOW_PERCENT	5

#define _SMALL_BLOCK	2048
#define _DEFAULT_BLOCK	4096
#define _LARGE_BLOCK	8192


************************************
FUNCTION Main()
************************************
   Local WybFol

   DEFINE WINDOW Form_1 AT 0,0 WIDTH 483 HEIGHT 230 ;
      MAIN ;
      TITLE _TITLE ; // "HMG FileCopy Demo" ;
      NOSIZE NOMAXIMIZE
      
      @ 6,1     FRAME Frame_1 CAPTION "" WIDTH 474 HEIGHT 128

      @ 29,20   LABEL Label_1 VALUE "Source file:" HEIGHT 19 FONT "Arial" SIZE 9 AUTOSIZE
      @ 28,110  TEXTBOX TextBox_1 WIDTH 298 HEIGHT 19
      @ 26,414  BUTTON Button_1 CAPTION "..." WIDTH 39 HEIGHT 23 ;
		ACTION  {|| Form_1.TextBox_1.Value := Getfile ( { {'All files ','*.*'} } , 'Select file to copy' )}

      @ 62,20   LABEL Label_2 VALUE "Destination:" WIDTH 86 HEIGHT 18
      @ 61,110  TEXTBOX TextBox_2 WIDTH 298 HEIGHT 19
      @ 59,414  BUTTON Button_2 CAPTION "..." WIDTH 39 HEIGHT 23 ;
                  ACTION  {|| WybFol := GetFolder(), ;
                  Form_1.TextBox_2.Value := WybFol+IIF(RIGHT(WybFol,1)$"\/","","\")+MyGetFileName(Form_1.TextBox_1.Value)}

      @ 84,200  LABEL Label_3 VALUE "" WIDTH 271 HEIGHT 16
      @ 103,20  PROGRESSBAR ProgressBar_1 RANGE 0,100 WIDTH 435 HEIGHT 21

      @ 146,96  BUTTON Button_3 CAPTION "Copy" WIDTH 100 HEIGHT 24 ;
		ACTION  FILECOPY(Form_1.TextBox_1.Value, Form_1.TextBox_2.Value, _LARGE_BLOCK, {|nArg| show_it(nArg)})

      @ 146,292 BUTTON Button_4 CAPTION "Exit" WIDTH 100 HEIGHT 24 ACTION ThisWindow.Release

      DEFINE STATUSBAR FONT "Arial" SIZE 9
             STATUSITEM _TITLE
      END STATUSBAR

   END WINDOW

   Form_1.Center
   Form_1.Activate

   RETURN Nil

********************************************************************
FUNCTION FILECOPY(cSource, cDestination, nBuffer, bBlock)
********************************************************************
   Local sourceHandle, destHandle, lSuccess:= .F., TmpBuff, LastPos
   Local BuffPos, ByteCount, cBType:= ValType(bBlock)

   Default nBuffer := _DEFAULT_BLOCK

   IF FILE(cDestination)
      IF !MsgYesNo("Destination file already exist. Overwrite ?","Warning")
         RETURN lSuccess
      ENDIF
   ENDIF

   Form_1.StatusBar.Item(1):="Copying in progress ..."
   If ( (sourceHandle:= fopen(cSource, 0)) != -1 )
      If ( (destHandle:= fcreate(cDestination, 0)) != -1 )
         LastPos:= fseek(sourceHandle, 0, 2)
         BuffPos:= 0
         ByteCount:= 0
         fseek(sourceHandle, 0, 0)
         Do While (BuffPos < LastPos)
            TmpBuff := Space(nBuffer)
            BuffPos += (ByteCount:= fread(sourceHandle, @TmpBuff, nBuffer))
            fwrite(destHandle, TmpBuff, ByteCount)
            If cBType == "B"
               Eval(bBlock, BuffPos / LastPos)
            EndIf
         EndDo
         lSuccess:= fclose(destHandle)
      EndIf
      fclose(sourceHandle)
   EndIf

   IF lSuccess
      Form_1.StatusBar.Item(1):="Filecopy finished successfully"
   ELSE
      Form_1.StatusBar.Item(1):="Filecopy failed !"
   ENDIF

   // InKey(1)

   // Form_1.ProgressBar_1.Value:= 0
   Form_1.Label_3.Value:= ""
   Form_1.StatusBar.Item(1):= "File " + cDestination + " copied!"

   RETURN lSuccess

************************************
FUNCTION SHOW_IT(nDl)
************************************
   Local nPos := int(nDl*100)

   IF ( nPos % _SHOW_PERCENT == 0 )
      Form_1.Label_3.Value := hb_ntos(nPos) + " % complete"
      Form_1.ProgressBar_1.Value := nPos
       DoEvents()
      IF IsVistaOrLater()
         InKey(.01)
      ENDIF
   ENDIF

   RETURN NIL

************************************
FUNCTION MyGetFileName(rsFileName)
************************************
   /*
   LOCAL i
   
   FOR i = Len(rsFileName) TO 1 STEP -1
      IF SUBSTR(rsFileName, i, 1) $ "\/"
         EXIT
      ENDIF
   NEXT
   
   RETURN SUBSTR(rsFileName, i + 1)
   */
   RETURN hb_FNameNameExt( rsFileName )

************************************
STATIC FUNCTION IsVistaOrLater()
************************************
   Local cOSName := WindowsVersion() [1]

   RETURN ( 'Vista' $ cOSName .Or. '7' $ cOSName .Or. ' 8' $ cOSName )
