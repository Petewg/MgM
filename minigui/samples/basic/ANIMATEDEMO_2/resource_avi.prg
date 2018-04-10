/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * 
 * Copyright 2017 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Размер avi-файла на форме / Size of the avi file on the form
*/

#include "hmg.ch"

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
