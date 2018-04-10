*--------------------
* Simple app for creating backup of source files
*
* Created 2012 by Marek Olszewski "MOL" <mol@pro.onet.pl>
*
* It's a free software! You can change everything!
*
* This software is provided "AS IS"
*--------------------
* Revised 20/03/12 by Bicahi Esgici <esgici@gmail.com>
*
* Adapted for Minigui Extended Edition by Grigory Filatov <gfilatov@inbox.ru>
*--------------------

#include <minigui.ch>

static cGlobalArchiveName
static cAppFolder
static aFileKinds
static cDestinationFolder, nArchiveNameCreatingMethod, cArchiveName, nOverwriteArchive
*--------------------
function main
	local cFileKinds_FNam    := "FilKinds.lst",;   // File kinds file name
		cFileKinds                             // File kinds string
	aFileKinds := {}                               // File kinds array
	cDestinationFolder:=GetCurrentFolder()+"\_Backup"
	nArchiveNameCreatingMethod := 2
	cArchiveName := ""
	nOverwriteArchive := 0

	cAppFolder := GetStartUpFolder()

	cGlobalArchiveName := substr(cAppFolder,rat("\",cAppFolder)+1)

	if empty(cGlobalArchiveName)
		cGlobalArchiveName := "BACKUP"
	endif

//	You can realize getting previous saved settings
//	BEGIN INI FILE cAppFolder+"\archiwizacja.ini"
//		GET cDestinationFolder SECTION "GLOBALNE" ENTRY "FolderArchiwum" DEFAULT "c:\"
//		GET nArchiveNameCreatingMethod SECTION "GLOBALNE" ENTRY "Wybor" DEFAULT 2
//		GET cGlobalArchiveName SECTION "GLOBALNE" ENTRY "Nazwa" DEFAULT ""
//		GET nOverwriteArchive SECTION "GLOBALNE" ENTRY "NadpisujArchiwum" DEFAULT 0
//	END INI

	IF FILE( cFileKinds_FNam )
		cFileKinds := MEMOREAD( cFileKinds_FNam) // File kinds string
		IF !EMPTY( cFileKinds ) 
			aFileKinds := HB_ATOKENS( cFileKinds, CRLF )
		ENDIF
	ENDIF
   
	IF EMPTY( aFileKinds )
		aFileKinds := { "PRG", "FMG" }
	ENDIF
   
	AEVAL( aFileKinds, { | c1, i1 | aFileKinds[ i1 ] := "*." + c1 } )

	Load Window BackUp

	ON KEY ESCAPE OF BackUp ACTION BackUp.Release()
	ON KEY F2 OF BackUp ACTION MakeBackup()
	
	BackUp.T_BackupName.Value := cArchiveName
	Backup.T_BackupFolder.Value := cDestinationFolder
	BackUp.R_ArchiveNameCreatingMethod.Value := nArchiveNameCreatingMethod
	BackUp.T_BackupName.ReadOnly := ( nArchiveNameCreatingMethod <> 3 )
	BackUp.CH_OverwriteBackupsWithoutWarning.Value := ( nOverwriteArchive > 0 )
	
	Center Window BackUp
	Activate Window BackUp

return nil
*-------------------
procedure SelectBackupHolder
	local cGetFolder

	cGetFolder := GetFolder( 'Select folder', ;
		iif(hb_DirExists(Backup.T_BackupFolder.Value), Backup.T_BackupFolder.Value, GetCurrentFolder()) )
	if !empty(cGetFolder)
		backup.T_BackupFolder.Value := cGetFolder
	endif
return
*-------------------
procedure CreateArchiveName
	local cArchiveName := cGlobalArchiveName

	switch BackUp.R_ArchiveNameCreatingMethod.Value
		case 1
			// only name
			BackUp.T_BackupName.Value := cArchiveName
			BackUp.T_BackupName.ReadOnly := .t.
			exit
		case 2
			// name + date
			BackUp.T_BackupName.Value := cArchiveName + "_"+dtos(date())+"_"+strtran(time(),":","")
			BackUp.T_BackupName.ReadOnly := .t.
			exit
		case 3
                        // user choice
			BackUp.T_BackupName.ReadOnly := .f.
	end switch
return
*-------------------
#command COMPRESS [ FILES ] <afiles> ;
		TO <zipfile> ;
		BLOCK <block>  ;
		[ <ovr: OVERWRITE> ] ;
		[ <srp: STOREPATH> ] ;
		[ PASSWORD <password> ] ;
=> ;
	COMPRESSFILES ( <zipfile> , <afiles>, <block> , <.ovr.> , <.srp.> , <password> )
*-------------------
procedure MakeBackup
	local aFilesToBackup := {} , cArchiveName := "" , cFileKind , aTemp

	cArchiveName := alltrim(backup.T_BackupFolder.Value)
	if substr(cArchiveName,-1) <> "\"
		cArchiveName += "\"
	endif

	if !hb_DirExists(cArchiveName)
		if !CreateFolder(cArchiveName)
			MsgStop("Creating archive folder unsuccessful! Operation is stopped!")
			return
		endif
	endif

	cArchiveName += alltrim(BackUp.T_BackupName.Value) +".ZIP"

	if file(cArchiveName) .and. !BackUp.CH_OverwriteBackupsWithoutWarning.Value
		if !MsgYesNo("Backup file: " + cArchiveName + CRLF + "already exists! Overwrite it?","Confirmation",.t.)
			return
		endif
	endif

	BackUp.ProgressIndicator.Visible := .t.

	FOR EACH cFileKind IN aFileKinds
		aTemp := DIRECTORY( cFileKind )
		AEVAL( aTemp, { | a1 | AADD( aFilesToBackup, a1[ 1 ] ) } )
	NEXT
   
	IF EMPTY( aFilesToBackup )
		MsgStop( "No files found to backup !", " ERROR !" )
	ELSE
		BackUp.ProgressIndicator.RangeMax := len(aFilesToBackup)
		BackUp.ProgressIndicator.Value := 0

		COMPRESS aFilesToBackup ;
			TO cArchiveName ;
			BLOCK { |cFile, nPos| BackUp.ProgressIndicator.Value := nPos, cFile := Nil, DoEvents() } ;
			OVERWRITE

		// You can save backub settings here
		//SaveBackupConfiguration()

		InkeyGUI(500)
		msgbox("Backup was created successfully!","Result")
		BackUp.Release
	ENDIF   
return
/*-------------------
function SaveBackupConfiguration
	BEGIN INI FILE cAppFolder+"\archiwizacja.ini"
		SET SECTION "GLOBALNE" ENTRY "FolderArchiwum" TO alltrim(backup.T_BackupFolder.Value)
		SET SECTION "GLOBALNE" ENTRY "Wybor" TO BackUp.R_ArchiveNameCreatingMethod.Value
		SET SECTION "GLOBALNE" ENTRY "Nazwa" TO BackUp.T_BackupName.Value
		SET SECTION "GLOBALNE" ENTRY "NadpisujArchiwum" TO if(BackUp.CH_OverwriteBackupsWithoutWarning.Value, 1, 0)
	END INI
 return nil */
*-------------------
procedure COMPRESSFILES ( cFileName , aDir , bBlock , lOvr , lStorePath , cPassword )
local hZip , cZipFile , i

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

return
*-------------------
