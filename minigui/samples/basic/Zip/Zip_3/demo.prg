/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Based on HBMZIP Harbour contribution library samples
 *
 * Adapted for MiniGUI Extended Edition by Grigory Filatov - 2008-2012
*/

#include <minigui.ch>

#command COMPRESS [ FILES ] <afiles> ;
		TO <zipfile> ;
		BLOCK <block>  ;
		[ <ovr: OVERWRITE> ] ;
		[ <srp: STOREPATH> ] ;
		[ PASSWORD <password> ] ;
=> ;
	COMPRESSFILES ( <zipfile> , <afiles>, <block> , <.ovr.> , <.srp.> , <password> )


#command UNCOMPRESS [ FILE ] <zipfile> ;
		[ BLOCK <block> ] ;
		[ PASSWORD <password> ] ;
=> ;
	UNCOMPRESSFILES ( <zipfile> , <block> , <password> )

*------------------------------------------------------------------------------*
Procedure Main
*------------------------------------------------------------------------------*

DEFINE WINDOW Form_1 ;
	AT 0, 0 ;
	WIDTH 400 HEIGHT 215 ;
	TITLE "Backup" ;
	ICON "demo.ico" ;
	MAIN ;
	NOMAXIMIZE NOSIZE ;
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
		FORECOLOR {0,130,0}
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

Return

*------------------------------------------------------------------------------*
Function CreateZip()
*------------------------------------------------------------------------------*
Local aDir := Directory( "f*.txt", "D" ), aFiles:= {}, nLen
Local cPath := CurDrive()+":\"+CurDir()+"\"

FillFiles( aFiles, aDir, cPath )

if ( nLen := Len(aFiles) ) > 0
	Form_1.ProgressBar_1.RangeMin := 1
	Form_1.ProgressBar_1.RangeMax := nLen
	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,0}

	COMPRESS aFiles ;
		TO 'ZipTest.Zip' ;
		BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
		PASSWORD "mypass" ;
		STOREPATH ;
		OVERWRITE

	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,255}
	Form_1.Label_1.Value := 'Backup is finished'
endif

Return Nil

*------------------------------------------------------------------------------*
Function ProgressUpdate( nPos , cFile , lShowFileName )
*------------------------------------------------------------------------------*

	Default lShowFileName := .F.

	Form_1.ProgressBar_1.Value := nPos
	Form_1.Label_1.Value := cFileNoPath( cFile )

	if lShowFileName
		INKEY(.2)
	endif

Return Nil

*------------------------------------------------------------------------------*
Function UnZip()
*------------------------------------------------------------------------------*
Local cCurDir := GetCurrentFolder(), cArchive

cArchive := Getfile ( { {'Zip Files','*.ZIP'} } , 'Open File' , cCurDir , .f. , .t. )

if !Empty(cArchive)
	Form_1.ProgressBar_1.RangeMin := 0
	Form_1.ProgressBar_1.RangeMax := GetFilesCountInZip( cArchive )
	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,0}

	UNCOMPRESS cArchive ;
		BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
		PASSWORD "mypass"

	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,255}
	Form_1.Label_1.Value := 'Restoration of Backup is finished'
endif

Return Nil

*------------------------------------------------------------------------------*
Function FillFiles( aFiles, cDir, cPath )
*------------------------------------------------------------------------------*
  Local aSubDir, cItem

  FOR cItem :=1 TO LEN(cDir)
    IF cDir[cItem][5] <> "D"
      AADD( aFiles, cPath+cDir[cItem][1] )
    ELSEIF cDir[cItem][1] <> "." .AND. cDir[cItem][1] <> ".."
      aSubDir := DIRECTORY( cPath+cDir[cItem][1]+"\*.*", "D" )
      aFiles := FillFiles( aFiles, aSubdir, cPath+cDir[cItem][1]+"\" )
    ENDIF
  NEXT

Return aFiles

*------------------------------------------------------------------------------*
Function GETFILESCOUNTINZIP ( cFileName )
*------------------------------------------------------------------------------*
LOCAL i := 0 , hUnzip , nErr

	hUnzip := HB_UNZIPOPEN( cFileName )

	nErr := HB_UNZIPFILEFIRST( hUnzip )

	DO WHILE nErr == 0

		i++
		nErr := HB_UNZIPFILENEXT( hUnzip )

	ENDDO

	HB_UNZIPCLOSE( hUnzip )

Return i

*------------------------------------------------------------------------------*
PROCEDURE COMPRESSFILES ( cFileName , aDir , bBlock , lOvr , lStorePath , cPassword )
*------------------------------------------------------------------------------*
LOCAL hZip , cZipFile , i

	if valtype (lOvr) == 'L'
		if lOvr == .t.
			if file (cFileName)
				delete file (cFileName)
			endif
		endif
	endif

	hZip := HB_ZIPOPEN( cFileName )
	IF ! EMPTY( hZip )
		FOR i := 1 To Len (aDir)
			if valtype (bBlock) == 'B'
				Eval ( bBlock , aDir [i] , i )     
			endif
			cZipFile := iif( lStorePath, aDir [i], cFileNoPath( aDir [i] ) )
			HB_ZipStoreFile( hZip, aDir [i], cZipFile, cPassword )
		NEXT
	ENDIF

	HB_ZIPCLOSE( hZip )

RETURN

*------------------------------------------------------------------------------*
PROCEDURE UNCOMPRESSFILES ( cFileName , bBlock , cPassword )
*------------------------------------------------------------------------------*
LOCAL i := 0 , hUnzip , nErr
LOCAL cFile, dDate, cTime, nSize, nCompSize, lCrypted, cComment, cStorePath

	hUnzip := HB_UNZIPOPEN( cFileName )

	nErr := HB_UNZIPFILEFIRST( hUnzip )

	DO WHILE nErr == 0

		HB_UnzipFileInfo( hUnzip, @cFile, @dDate, @cTime,,,, @nSize, @nCompSize, @lCrypted, @cComment )

		if ! Empty( (cStorePath := cFilePath( cFile )) ) .AND. ! hb_DirExists( hb_DirSepAdd( cStorePath ) )
			hb_DirBuild( hb_DirSepAdd( cStorePath ) )
		endif

		if valtype (bBlock) == 'B'
			Eval ( bBlock , cFile , ++i )
		endif

		HB_UnzipExtractCurrentFile( hUnzip, NIL, iif( lCrypted, cPassword, NIL ) )

		nErr := HB_UNZIPFILENEXT( hUnzip )

	ENDDO

	HB_UNZIPCLOSE( hUnzip )

RETURN
