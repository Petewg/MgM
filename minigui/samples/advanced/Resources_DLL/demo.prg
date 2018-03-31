/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2017 Grigory Filatov <gfilatov@inbox.ru>
 * Copyright 2017 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Загрузить ресурсы из mydemo.dll 
 * Download resources from mydemo.dll
*/

ANNOUNCE RDDSYS

#include "minigui.ch"

Static nStaticNum := 0

////////////////////////////////////////////////////////////////////////////
Function MAIN
   Local nI, nRow, nWidth, aIcoExit, aPrgBar, aRes, aBackColorAvi, aSWH
   Local cPathMyDll := GetStartUpFolder() + "\mydemo.dll"

   If !File( cPathMyDll )  
      MsgStop("There is no resource file for the program!" + CRLF + cPathMyDll )
      Quit
   Endif

   aIcoExit := { "Exit48x1" , "Exit48x2" }  // two icons for exit
   // list of icons for snake 
   aPrgBar  := {}
   For nI := 1 TO 8
      Aadd( aPrgBar, "ZMK" + strzero(nI,2) )
   Next

   SET RESOURCES TO ( cPathMyDll )

   DEFINE WINDOW Form_1               ;
   	AT 0,0 WIDTH 700 HEIGHT 550   ;
   	TITLE "Displaying resources from the MyDemo.Dll" ;
        ICON "1MAIN_ICO"              ;
        MAIN                          ;
        FONT 'Tahoma' SIZE 14         ;
        BACKCOLOR WHITE        

        nWidth  := This.ClientWidth

         @ 20, 0 LABEL Label_Vers VALUE MiniGUIVersion() WIDTH nWidth HEIGHT 42 ;
            TRANSPARENT FONTCOLOR BLACK SIZE 12 BOLD CENTERALIGN
         @ 45, 0 LABEL Label_Compil VALUE hb_compiler() WIDTH nWidth HEIGHT 42 ;
            TRANSPARENT FONTCOLOR BLACK SIZE 12 BOLD CENTERALIGN
         @ 70, 0 LABEL Label_Info VALUE Version() WIDTH nWidth HEIGHT 42 ;
            TRANSPARENT FONTCOLOR BLACK SIZE 12 BOLD CENTERALIGN

         DRAW ICON IN WINDOW Form_1 AT 5, 5 PICTURE "1MAIN_ICO" WIDTH 128 HEIGHT 128 TRANSPARENT

         @ 12,Form_1.Width-122 IMAGE Image_1 PICTURE "LOGO128" WIDTH 96 HEIGHT 96 STRETCH 

         @ 128+5*2, 0 IMAGE Image_2 PICTURE "Harbour" WIDTH Form_1.Width HEIGHT 156 STRETCH 

         nRow := 128+5*2 + 156
         @ nRow, 0 LABEL Label_Full VALUE '' WIDTH nWidth+10 HEIGHT 50 

         aSWH := GetAviResSize("ZIPAVI")
         nCol := (nWidth-aSWH[1])/2
         @ nRow,nCol ANIMATEBOX Avi_1 WIDTH aSWH[1] HEIGHT aSWH[2] File "ZIPAVI" AUTOPLAY TRANSPARENT NOBORDER

         aBackColorAvi := nRGB2Arr( GetSysColor( 4 ) )  // 4-COLOR_MENU из i_winuser.ch
         Form_1.Label_Full.BackColor := aBackColorAvi   // fix the background like the system color


         @ 390, 50 LABEL Label_AniIco VALUE 'Animation from Icons' Autosize FONTCOLOR MAROON TRANSPARENT
         DRAW ICON IN WINDOW Form_1 AT 420, 100 PICTURE aPrgBar[1] WIDTH 64 HEIGHT 64 TRANSPARENT

         @ 380, 270 BUTTONEX Button_Dbf CAPTION "Run DBF" + CRLF + "from Resource" ;
           ICON "DBase48" WIDTH 120 HEIGHT 124            ;
           NOXPSTYLE HANDCURSOR NOTABSTOP VERTICAL        ;
           FONTCOLOR WHITE BACKCOLOR SILVER SIZE 10 BOLD  ;
           ACTION {|| RunDBF() }

         @ 380, 410 BUTTONEX Button_Play CAPTION "Play Wave" + CRLF + "from Resource" ;
           PICTURE "Sound48" WIDTH 120 HEIGHT 124         ;
           NOXPSTYLE HANDCURSOR NOTABSTOP VERTICAL        ;
           FONTCOLOR WHITE BACKCOLOR SILVER SIZE 10 BOLD  ;
           ACTION {|| PlayWave("QUARTER",.T.,.F.,.F.,.F.,.F.) }

         @ 380 , 550  BUTTONEX Button_Exit WIDTH 120 HEIGHT 124   ;
           CAPTION "Exiting" + CRLF + "the program" ICON aIcoExit[1] ; 
           FONTCOLOR WHITE BACKCOLOR MAROON SIZE 10 BOLD       ;
           NOXPSTYLE HANDCURSOR NOTABSTOP VERTICAL             ;
           ON MOUSEHOVER ( SetProperty(ThisWindow.Name, This.Name, "ICON", aIcoExit[2] ) ,;
                             SetProperty(ThisWindow.Name, This.Name, "fontcolor", BLACK  ) ) ;
           ON MOUSELEAVE ( SetProperty(ThisWindow.Name, This.Name, "ICON", aIcoExit[1] ) ,;
                                 SetProperty(ThisWindow.Name, This.Name, "fontcolor", WHITE ) ) ;
           ACTION {|| ThisWindow.Release }

         DEFINE TIMER Timer_1 INTERVAL 100 ACTION MyAnimationIcons(420, 100, aPrgBar,64)

   END WINDOW
   Form_1.Sizable   := .F.  // NOSIZE
   Form_1.MaxButton := .F.  // NOMAXIMIZE
   Form_1.Center
   Form_1.Activate

Return Nil

/////////////////////////////////////////////////////////////////////////////////
Static Function MyAnimationIcons(nRow, nCol, aPrgBar, nWH)

   nStaticNum++

   nStaticNum := IIF( nStaticNum > LEN(aPrgBar), 1, nStaticNum )
   DRAW ICON IN WINDOW Form_1 AT nRow, nCol PICTURE aPrgBar[nStaticNum] WIDTH nWH HEIGHT nWH TRANSPARENT

Return Nil

////////////////////////////////////////////////////////////////////////////
Function RunDBF() 
   Local cPath := GetStartupFolder() + "\"
   Local cFile := "test.dbf"

   IF RCDataToFile( "test_dbf", cPath + cFile, "CUSTOM" ) > 0
      // run the file from the disk 
      ShellExecute( 0, "open", "test.dbf", cPath, , 1 )
   ENDIF

Return Nil

*-------------------------------------------*
FUNCTION GetAviFileSize( cFile )
*-------------------------------------------*
   LOCAL cStr1, cStr2
   LOCAL nWidth, nHeight
   LOCAL nFileHandle

   cStr1 := cStr2 := Space( 4 )
   nWidth := nHeight := 0

   nFileHandle := FOpen( cFile )

   IF FError() == 0

      FRead( nFileHandle, @cStr1, 4 )

      IF cStr1 == "RIFF"
         FSeek( nFileHandle, 64, 0 )

         FRead( nFileHandle, @cStr1, 4 )
         FRead( nFileHandle, @cStr2, 4 )

         nWidth  := Bin2L( cStr1 )
         nHeight := Bin2L( cStr2 )
      ENDIF

      FClose( nFileHandle )

   ELSE

      MsgInfo( "Code: " + hb_NtoS( FError() ), "Error" )

   ENDIF

RETURN { nWidth, nHeight }

*-------------------------------------------*
FUNCTION GetAviResSize( cResName )
*-------------------------------------------*
   LOCAL aAviSize := Array( 2 ), nResult
   LOCAL cDiskFile := TempFile( GetTempFolder(), "avi" )

   nResult := RCDataToFile( cResName, cDiskFile, "AVI" )

   IF nResult > 0

      IF hb_FileExists( cDiskFile )
         aAviSize := GetAviFileSize( cDiskFile )
         FErase( cDiskFile )
      ENDIF

   ELSE

      MsgInfo( "Code: " + hb_NtoS( nResult ), "Error" )

   ENDIF

RETURN { aAviSize[1], aAviSize[2] }
