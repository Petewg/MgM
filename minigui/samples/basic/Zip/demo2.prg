/*
 Made By Sylvain Robert 2004-01-23

 Modified for MiniGUI by Grigory Filatov 2007-11-03

 This Example show you how to ZIP the all files from the current Directory
 it also ZIP all files in subdirectory.
*/

#include <minigui.ch>

*------------------------------------------------------------------------------*
Procedure Main
*------------------------------------------------------------------------------*

DEFINE WINDOW Form_1 ;
	AT 0, 0 ;
	WIDTH 400 HEIGHT 215 ;
	TITLE "Backup demo by hbziparc library" ;
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
		ACTION CreateZip(/*"abc"*/)
	END BUTTON

	DEFINE BUTTON Button_2
		ROW 140
		COL 205
		WIDTH 150
		HEIGHT 28
		CAPTION "&Recover Backup"
		ACTION UnZip()
	END BUTTON

	DEFINE PROGRESSBAR ProgressBar_0
		ROW 20
		COL 45
		WIDTH 310
		HEIGHT 30
		RANGEMIN 0
		RANGEMAX 100
		VALUE 0
		FORECOLOR {0,130,0}
	END PROGRESSBAR

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
Function CreateZip( cPass )
*------------------------------------------------------------------------------*
Local aDir := Directory( "*.*", "D" ), aFiles:= {}, nLen, lSuccess
Local cPath := CurDrive()+":\"+CurDir()+"\"

FillFiles( aFiles, aDir, cPath )

if ( nLen := Len(aFiles) ) > 0
	Form_1.ProgressBar_0.Value := 0
	Form_1.ProgressBar_1.RangeMax := nLen - lton( file('Backup.Zip') )
	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,0}

	if Empty(cPass)
		COMPRESS aFiles ;
			TO 'Backup.Zip' ;
			BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
			LEVEL 9 ;
			OVERWRITE ;
			STOREPATH ;
			FILEPROGRESS {|nPos, nTotal| ProgressFile( nPos, nTotal, .T. ) } ;
			RESULT lSuccess
	else
		COMPRESS aFiles ;
			TO 'Backup.Zip' ;
			BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
			LEVEL 9 ;
			PASSWORD cPass ;
			OVERWRITE ;
			STOREPATH ;
			FILEPROGRESS {|nPos, nTotal| ProgressFile( nPos, nTotal, .T. ) } ;
			RESULT lSuccess
	endif

	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,255}
	Form_1.Label_1.Value := iif(lSuccess, 'Backup is finished', 'Backup Error')
endif

Return Nil

*------------------------------------------------------------------------------*
Function ProgressUpdate( nPos , cFile , lShowFileName )
*------------------------------------------------------------------------------*

	Default lShowFileName := .F.

	Form_1.ProgressBar_1.Value := nPos
	Form_1.Label_1.Value := cFileNoPath( cFile )

	if lShowFileName
		INKEY(.1)
	endif

Return Nil

*------------------------------------------------------------------------------*
Function ProgressFile( nPos , nTotal , lShowFileProgress )
*------------------------------------------------------------------------------*

	Default lShowFileProgress := .F.

	Form_1.ProgressBar_0.Value := ( nPos / nTotal ) * 100

	if lShowFileProgress
		INKEY(.1)
	endif

Return Nil

*------------------------------------------------------------------------------*
Function UnZip()
*------------------------------------------------------------------------------*
Local cCurDir := GetCurrentFolder(), cArchive, lSuccess

cArchive := Getfile ( { {'Zip Files','*.ZIP'} } , 'Open File' , cCurDir , .f. , .t. )

if !Empty(cArchive)
	Form_1.ProgressBar_0.Value := 0
	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,0}

	if hb_ZipWithPassword(cArchive)
		Form_1.ProgressBar_1.RangeMax := 2

		UNCOMPRESS cArchive ;
			EXTRACTPATH cCurDir + "\BackUp" ;
			FILEMASK "demo.*" ;
			BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
			PASSWORD "abc" ;
			RESULT lSuccess ;
			CREATEDIR
	else
		Form_1.ProgressBar_1.RangeMax := Len( hb_GetFilesInZip(cArchive) )

		UNCOMPRESS cArchive ;
			EXTRACTPATH cCurDir + "\BackUp" ;
			BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
			FILEPROGRESS {|nPos, nTotal| ProgressFile( nPos, nTotal, .T. ) } ;
			RESULT lSuccess ;
			CREATEDIR
	endif

	INKEY(.5)
	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,255}
	Form_1.Label_1.Value := iif(lSuccess, 'Restoration of Backup is finished', 'Restoration Error')
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
