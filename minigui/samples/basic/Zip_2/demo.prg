/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Based on freeware Zip Component by Belus Technology
*/

#include <minigui.ch>

#command COMPRESS [ FILES ] <afiles> ;
      TO <zipfile> ;
      BLOCK <block>  ;
      [ LEVEL <level> ] ;
      [ <ovr: OVERWRITE> ] ;
      [ <spt: STOREPATH> ] ;
   => ;
      COMPRESSFILES ( <zipfile>, <afiles>, <level>, <block>, <.ovr.>, <.spt.> )


#command UNCOMPRESS [ FILE ] <zipfile> ;
      EXTRACTPATH <extractpath> ;
      [ BLOCK <block> ] ;
      [ <createdir: CREATEDIR> ] ;
      [ PASSWORD <password> ] ;
   => ;
      UNCOMPRESSFILES ( <zipfile>, <block>, <extractpath> )


STATIC ObjZip

*------------------------------------------------------------------------------*
PROCEDURE Main
*------------------------------------------------------------------------------*

   IF IsWinNT() .AND. ! wapi_IsUserAnAdmin()
      MsgStop( 'This Program Runs In An Admin Mode Only!', 'Stop' )
      RETURN
   ENDIF

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 400 HEIGHT 215 ;
      TITLE "Backup" ;
      ICON "demo.ico" ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      ON INIT RegActiveX() ;
      ON RELEASE UnRegActiveX() ;
      FONT "Arial" SIZE 9

   DEFINE BUTTON Button_1
      ROW 140
      COL 45
      WIDTH 150
      HEIGHT 30
      CAPTION "&Create Backup"
      ACTION CreateZip()
   END BUTTON

   DEFINE BUTTON Button_2
      ROW 140
      COL 205
      WIDTH 150
      HEIGHT 28
      CAPTION "&Recover Backup"
      ACTION UnZip()
   END BUTTON

   DEFINE PROGRESSBAR ProgressBar_1
      ROW 60
      COL 45
      WIDTH 310
      HEIGHT 30
      RANGEMIN 0
      RANGEMAX 10
      VALUE 0
      FORECOLOR { 0, 130, 0 }
   END PROGRESSBAR

   DEFINE LABEL Label_1
      ROW 100
      COL 25
      WIDTH 350
      HEIGHT 20
      VALUE ""
      FONTNAME "Arial"
      FONTSIZE 10
      TOOLTIP ""
      FONTBOLD .T.
      TRANSPARENT .T.
      CENTERALIGN .T.
   END LABEL

   ON KEY ESCAPE ACTION Form_1.Release

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN

*------------------------------------------------------------------------------*
FUNCTION CreateZip()
*------------------------------------------------------------------------------*

   LOCAL aDir := Directory( "xzip.*", "D" ), aFiles := {}, nLen
   LOCAL cPath := CurDrive() + ":\" + CurDir() + "\"

   FillFiles( aFiles, aDir, cPath )

   IF ( nLen := Len( aFiles ) ) > 0
      Form_1.ProgressBar_1.RangeMin := 1
      Form_1.ProgressBar_1.RangeMax := nLen
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 0 }

      COMPRESS aFiles ;
         TO 'Backup.Zip' ;
         BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
         LEVEL 9 ;
         OVERWRITE

      InkeyGUI( 250 )
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 255 }
      Form_1.Label_1.Value := 'Backup is finished'
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION ProgressUpdate( nPos, cFile, lShowFileName )
*------------------------------------------------------------------------------*

   DEFAULT lShowFileName := .F.

   Form_1.ProgressBar_1.Value := nPos
   Form_1.Label_1.Value := cFileNoPath( cFile )

   IF lShowFileName
      InkeyGUI( 250 )
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION UnZip()
*------------------------------------------------------------------------------*

   LOCAL cCurDir := GetCurrentFolder(), cArchive

   cArchive := Getfile ( { { 'Zip Files', '*.ZIP' } }, 'Open File', cCurDir, .F., .T. )

   IF ! Empty( cArchive )
      Form_1.ProgressBar_1.RangeMin := 0
      Form_1.ProgressBar_1.RangeMax := GetFilesCountInZip( cArchive )
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 0 }

      UNCOMPRESS cArchive ;
         EXTRACTPATH cCurDir + "\BackUp" ;
         BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
         CREATEDIR

      InkeyGUI( 250 )
      MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR { 0, 0, 255 }
      Form_1.Label_1.Value := 'Restoration of Backup is finished'
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION FillFiles( aFiles, cDir, cPath )
*------------------------------------------------------------------------------*

   LOCAL aSubDir, cItem

   FOR cItem := 1 TO Len( cDir )
      IF cDir[ cItem ][ 5 ] <> "D"
         AAdd( aFiles, cPath + cDir[ cItem ][ 1 ] )
      ELSEIF cDir[ cItem ][ 1 ] <> "." .AND. cDir[ cItem ][ 1 ] <> ".."
         aSubDir := Directory( cPath + cDir[ cItem ][ 1 ] + "\*.*", "D" )
         aFiles := FillFiles( aFiles, aSubdir, cPath + cDir[ cItem ][ 1 ] + "\" )
      ENDIF
   NEXT

RETURN aFiles

*------------------------------------------------------------------------------*
FUNCTION GetFilesCountInZip ( zipfile )
*------------------------------------------------------------------------------*

RETURN GetZipObject():Contents( zipfile ):Count

*------------------------------------------------------------------------------*
STATIC FUNCTION GetZipObject()
*------------------------------------------------------------------------------*

   IF ObjZip == NIL
      objZip := CreateObject( "XStandard.Zip" )
   ENDIF

RETURN ObjZip

*------------------------------------------------------------------------------*
PROCEDURE UNCOMPRESSFILES ( zipfile, block, extractpath )
*------------------------------------------------------------------------------*

   LOCAL oZip
   LOCAL COUNT
   LOCAL objItem
   LOCAL i

   oZip := GetZipObject ()

   Count := oZip:Contents( zipfile ):Count

   FOR i := 1 TO Count

      objItem := oZip:Contents( zipfile ):Item( i )

      IF ValType ( block ) = 'B'
         Eval ( block, objItem:Name, i )
      ENDIF

      oZip:UnPack( zipfile, extractpath, objItem:Name )

   NEXT i

RETURN

*------------------------------------------------------------------------------*
PROCEDURE COMPRESSFILES ( zipfile, afiles, level, block, ovr, lStorePath )
*------------------------------------------------------------------------------*

   LOCAL oZip
   LOCAL i

   oZip := GetZipObject ()

   IF ovr == .T.

      IF File ( zipfile )
         DELETE FILE ( zipfile )
      ENDIF

   ENDIF

   FOR i := 1 TO Len ( afiles )

      Eval ( block, aFiles[i ], i )

      oZip:Pack( afiles[i ], zipfile, lStorePath, , level )

   NEXT i

RETURN

*------------------------------------------------------------------------------*
PROCEDURE RegActiveX()
*------------------------------------------------------------------------------*

   IF File ( GetStartUpFolder() + '\xzip.dll' )
      EXECUTE FILE "regsvr32" PARAMETERS "/s XZip.dll" HIDE
   ENDIF

RETURN

*------------------------------------------------------------------------------*
PROCEDURE UnRegActiveX()
*------------------------------------------------------------------------------*

   IF File ( GetStartUpFolder() + '\xzip.dll' )
      EXECUTE FILE "regsvr32" PARAMETERS "/u /s XZip.dll" HIDE
   ENDIF

RETURN
