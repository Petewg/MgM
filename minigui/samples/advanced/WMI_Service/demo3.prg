/*
 * MiniGUI WMI Service Demo
 *
 * (c) 2010 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Procedure Main
  
	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'WMI Service Demo' ;
		MAIN ;
		ON INTERACTIVECLOSE MsgYesNo ( 'Are You Sure ?', 'Exit' )

		DEFINE BUTTON Button_1
			ROW	10
			COL	10
			WIDTH	120
			CAPTION 'Shell Info'
			ACTION WMIShell( Getfile() )
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	10
			WIDTH	120
			CAPTION 'Cancel'
			ACTION ThisWindow.Release
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_1
	ACTIVATE WINDOW Form_1

Return


FUNCTION WMIShell(cFullPath)

   Local oShell
   Local oFolder
   Local cPath, cFile, cFileNoExt
   Local cFileName, cName
   Local aHeaders := array(35)

   if !Empty(cFullPath)

      cPath      := cFilePath(cFullPath)
      cFile      := cFileNoPath(cFullPath)
      cFileNoExt := cFileNoExt(cFullPath)

      oShell     := CreateObject( "Shell.Application" )
      oFolder    := oShell:Namespace( cPath )

      For i = 1 to 35
         aHeaders[i] := oFolder:GetDetailsOf( oFolder:Items, i-1 )
      Next

      FOR EACH cFileName IN oFolder:Items

         cName := oFolder:GetDetailsOf(cFileName, 0)

         if cName == iif(at(".", cName) == 0, cFileNoExt, cFile)

            cInfo := ""
            For i = 1 to 35
               cName := oFolder:GetDetailsOf( cFileName, i-1 )
               if !Empty(aHeaders[i]) .and. !Empty(cName)
                  cInfo += str(i-1) + Chr(9) + aHeaders[i] + ": " + cName +CRLF
               endif
            Next

            cInfo += CRLF
            cInfo += Chr(9) + "md5: " + Upper( hb_ValToStr( hb_md5file(cFullPath) ) ) +CRLF
            cInfo += Chr(9) + "crc32: " + hb_ValToStr( hb_crc32(cFullPath) )

            MsgInfo( cInfo, "Extended File Properties" )

         endif

      NEXT

   endif

Return nil 
