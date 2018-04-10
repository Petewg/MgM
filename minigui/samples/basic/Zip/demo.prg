/*
 Made By Sylvain Robert 2004-01-23

 Modified for MiniGUI by Grigory Filatov 2007-10-26

 This Example show you how to ZIP the all files from the current Directory
 it also ZIP all files in subdirectory.

 By default the file store in the ZIP file will have Pathname
*/

#include <minigui.ch>

*------------------------------------------------------------------------------*
Procedure Main
*------------------------------------------------------------------------------*

if FILE("BACKUP.ZIP")
	DELETE FILE BACKUP.ZIP
endif

DEFINE WINDOW Form_1 ;
	AT 0, 0 ;
	WIDTH 400 HEIGHT 215 ;
	TITLE "Backup demo by ziparchive library" ;
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
Local aDir := Directory( "*.*", "D" ), aFiles:= {}, nLen
Local cPath := CurDrive()+":\"+CurDir()+"\"

FillFiles( aFiles, aDir, cPath )

if ( nLen := Len(aFiles) ) > 0
	Form_1.ProgressBar_1.RangeMin := 1
	Form_1.ProgressBar_1.RangeMax := nLen
	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,0}

	COMPRESS aFiles ;
		TO 'Backup.Zip' ;
		BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
		LEVEL 9 ;
		OVERWRITE ;
		STOREPATH

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
		INKEY(.1)
	endif

Return Nil

*------------------------------------------------------------------------------*
Function UnZip()
*------------------------------------------------------------------------------*
Local cCurDir := GetCurrentFolder(), cArchive

cArchive := Getfile ( { {'Zip Files','*.ZIP'} } , 'Open File' , cCurDir , .f. , .t. )

if !Empty(cArchive)
	Form_1.ProgressBar_1.RangeMin := 1
	Form_1.ProgressBar_1.RangeMax := Len( HB_GetFilesInZip(cArchive) ) - 1
	MODIFY CONTROL Label_1 OF Form_1 FONTCOLOR {0,0,0}

	UNCOMPRESS cArchive ;
		EXTRACTPATH cCurDir + "\BackUp" ;
		BLOCK {|cFile, nPos| ProgressUpdate( nPos, cFile, .T. ) } ;
		CREATEDIR

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
      aFiles:=FillFiles( aFiles, aSubdir, cPath+cDir[cItem][1]+"\" )
    ENDIF
  NEXT

Return aFiles
