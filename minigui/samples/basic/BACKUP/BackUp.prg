/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-07 Grigory Filatov <gfilatov@inbox.ru>
 * Adapted (2012-06-07) by Tsakalidis G. Evangelos <tsakal@otenet.gr>
 * Main adaptations :
 *		recursive backUp of a folder
 *		keeping specific number of backUps for a specific number of days and deleting unnecessary backUps
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "Directry.ch"

#define PROGRAM 'BackUp'
#define VERSION 'ver.1.3'
#define COPYRIGHT 'Grigory Filatov and Tsakalidis G. Evangelos'

#define MYTITLE ".:: " + getFileDate(hb_ProgName()) + " : " + ;
				"Poor Men's "+PROGRAM + ;
				" [" + ltrim( str( nMinDaysToKeep ) ) + "-days, " + ltrim( str( nMinBackUpsToKeep ) ) + "-files] : " + ;
				NETNAME() + "\" + hb_USERNAME() + " : " + VERSION + " ::."

// #define DEBUG
#define NTRIM( n ) LTrim( Str( n ) )

#define MsgInfo( c ) MsgInfo( c, "Information", , .f. )
#define MsgAlert( c ) MsgEXCLAMATION( c, "Attention", , .f. )
#define MsgStop( c ) MsgStop( c, "Stop!", , .f. )

STATIC lConfirm := "", nCompress := 6, cSkin := "", cTarget := "", cZip := ""
STATIC cMsgCancel := "", cMsgSkin := "", cMsgConf := "", cMsgStart := "", ;
       cMsgDir := "", cMsgEmpty := "", cMsgEnd := "", cMsgFailed := "", cMsgCreate := "", cMsgDelete := "", cMsgTotalTime := "", cMsgRate := ""
	   
STATIC cTargetFolder := "", cTargetPrefix := "", cTargetSuffix := "", cTargetExtension := ""
STATIC nMinDaysToKeep := 0, nMinBackUpsToKeep := 0, nMinToKeep := 7, cMaskSeparator := '', cAllFilesMask := '*.*'
STATIC dToDay // backUp's start date

STATIC tStartTime, tTotalTime

MEMVAR aInfo, nTotLen
MEMVAR nActualTot

*--------------------------------------------------------*
PROCEDURE Main()
*--------------------------------------------------------*
	LOCAL aSource := {}
	SET MULTIPLE OFF
	set(_SET_DATEFORMAT,"YYYY-MM-DD")
	aSource := AppInit()
	IF LEN(aSource) > 0
		IF !lConfirm
			do_backup(aSource)
		ELSEIF lConfirm .and. MsgYesNo(cMsgStart, cMsgConf, , , .f.)
			do_backup(aSource)
		ENDIF
	ENDIF
RETURN

*--------------------------------------------------------*
FUNCTION AppInit()
*--------------------------------------------------------*
LOCAL nI, cSourceDir := "", cSubFolders := "", cFileIncludeMask := "", cIsActive := ""
LOCAL aSource := {}

tStartTime := GetTickCount()

cTargetSuffix := hbTimeStamp()

	BEGIN INI FILE ChangeFileExt( hb_ProgName(), '.ini' ) // DirPrg()+"\backup.ini"

		GET lConfirm  SECTION "BACKUP" ENTRY "Confirm Start"     DEFAULT "Yes"
		lConfirm := ( LOWER( lConfirm ) == "yes" )

		GET nCompress SECTION "BACKUP" ENTRY "Compression Ratio" DEFAULT nCompress

		GET cTargetFolder SECTION "BACKUP" ENTRY "TargetFolder" DEFAULT "%H\myBACKUP\"
		if (substr(cTargetFolder,-1) != '\')
			cTargetFolder := cTargetFolder + '\'
		endif
		
		GET cTargetPrefix SECTION "BACKUP" ENTRY "TargetPrefix" DEFAULT "BackUp_"
		if (substr(cTargetPrefix,-1) != '_')
			cTargetPrefix := cTargetPrefix + '_'
		endif

		GET cTargetExtension SECTION "BACKUP" ENTRY "TargetExtension" DEFAULT '.zip'
		if (substr(cTargetExtension, 1, 1) != '.')
			cTargetExtension := '.'+cTargetExtension
		endif
		
		GET nMinDaysToKeep    SECTION "BACKUP" ENTRY "minDaysToKeep"    DEFAULT nMinToKeep
		nMinDaysToKeep := if(nMinDaysToKeep<1, nMinToKeep, nMinDaysToKeep)
		
		GET nMinBackUpsToKeep SECTION "BACKUP" ENTRY "minBackUpsToKeep" DEFAULT nMinToKeep
		nMinBackUpsToKeep := if(nMinBackUpsToKeep<1, nMinToKeep, nMinBackUpsToKeep)
		
		GET cMaskSeparator    SECTION "BACKUP" ENTRY "MaskSeparator"    DEFAULT "|"
		
		GET cSkin             SECTION "BACKUP" ENTRY "Skin"             DEFAULT "Backup.bmp"

		For nI := 0 To 99
			GET cSourceDir   SECTION "SOURCE-" + StrZero(nI, 2, 0) + "/99" ENTRY "SourceDir"  DEFAULT ""
			GET cSubFolders  SECTION "SOURCE-" + StrZero(nI, 2, 0) + "/99" ENTRY "SubFolders" DEFAULT "No"
			GET cFileIncludeMask  SECTION "SOURCE-" + StrZero(nI, 2, 0) + "/99" ENTRY "FileIncludeMask" DEFAULT cAllFilesMask
			GET cIsActive    SECTION "SOURCE-" + StrZero(nI, 2, 0) + "/99" ENTRY "IsActive"   DEFAULT "Yes"
			IF ( LOWER( cIsActive ) == "yes" ) .and. !Empty( cSourceDir )
				Aadd( aSource, { alltrim( cSourceDir ), alltrim( cFileIncludeMask ), alltrim( cSubFolders ) } )
			//ELSE
			//	Exit
			ENDIF
		Next

		GET cMsgCancel SECTION "LANGUAGE" ENTRY "1" DEFAULT "Cancel this backUp?"

		GET cMsgSkin SECTION "LANGUAGE" ENTRY "2" DEFAULT "Cannot find skin %1..."

		GET cMsgConf SECTION "LANGUAGE" ENTRY "4" DEFAULT "Confirm Start"

		GET cMsgStart SECTION "LANGUAGE" ENTRY "9" DEFAULT "Start backUp now?"

		GET cMsgDir SECTION "LANGUAGE" ENTRY "10" DEFAULT "Cannot find directory %1..."

		GET cMsgRate SECTION "LANGUAGE" ENTRY "20" DEFAULT "Rate"

		GET cMsgTotalTime SECTION "LANGUAGE" ENTRY "30" DEFAULT "Total Time"

		GET cMsgEmpty SECTION "LANGUAGE" ENTRY "85" DEFAULT "No files to backUp..."

		GET cMsgEnd SECTION "LANGUAGE" ENTRY "86" DEFAULT "backUp ready!"

		GET cMsgFailed SECTION "LANGUAGE" ENTRY "89" DEFAULT "backUp to %1 failed..."

		GET cMsgCreate SECTION "LANGUAGE" ENTRY "90" DEFAULT "Cannot create %1..."

		GET cMsgDelete SECTION "LANGUAGE" ENTRY "99" DEFAULT "Deleting : %1..."

	END INI
	
return ASORT(aSource,,, { |x, y| LOWER( x[1]+x[2] ) < LOWER( y[1]+y[2] ) }) // aSource

*--------------------------------------------------------*
FUNCTION do_backup(aSource)
*--------------------------------------------------------*
LOCAL aFiles := {}, aDir := {}, aFolders := {}, nI, nJ, nK, cDir, cSub, cPath, cIncludeMask, aIncludeMask := {}
Local cUserFolder := "Documents and Settings\" + hb_USERNAME()
Local iWW := 588, iWH := IF(IsXPThemeActive(), 187, 180)

dToDay := STOD( SUBSTR( cTargetSuffix, 1, 8 ) )

PRIVATE aInfo := {}, nTotLen := 0
	
	IF AT("%U", cTargetFolder) > 0
		cTargetFolder := STRTRAN(cTargetFolder, "%U", left( GetWindowsFolder(), 1 )+ ":\" + cUserFolder )
	ENDIF

	IF AT("%H", cTargetFolder)>0
		cTargetFolder := STRTRAN(cTargetFolder, "%H", CurDrive() + ":\" + CurDir())
		cTargetFolder := STRTRAN(cTargetFolder, "\\", "\")
	ENDIF

	IF AT("%C", cTargetFolder)>0
		cTargetFolder := STRTRAN(cTargetFolder, "%C", CurDrive() + ":")
	ENDIF

	IF AT("%W", cTargetFolder)>0
		cTargetFolder := STRTRAN(cTargetFolder, "%W", GetWindowsFolder())
	ENDIF

	IF AT("%S", cTargetFolder)>0
		cTargetFolder := STRTRAN(cTargetFolder, "%S", GetSystemFolder())
	ENDIF
		
	cTarget := cTargetFolder + cTargetPrefix + cTargetSuffix
	cZip := cTarget + cTargetExtension

#ifdef DEBUG
	msgMulty({cTarget, stod(substr(cTarget, -17, 8)), cZip, stod(substr(cZip, len(cTargetFolder + cTargetPrefix)+1, 8)), dToDay},'Target')
#endif

	cPath := cFilePath( cZip )
	IF !lIsDir( cPath )
		IF ( MAKEDIR( cPath ) # 0 )
			MsgStop( STRTRAN(cMsgCreate, "%1", cPath) )
			return nil
		EndIF
	EndIF

	FOR nI := 1 TO LEN(aSource)
		cDir := aSource[nI][1]
		cIncludeMask := aSource[nI][2]
		cSub := LOWER(aSource[nI][3])
		IF AT("%U", cDir) > 0
			cDir := STRTRAN(cDir, "%U", left( GetWindowsFolder(), 1 )+ ":\" + cUserFolder )
		ENDIF
		IF AT("%H", cDir) > 0
			cDir := STRTRAN(cDir, "%H", CurDrive() + ":\" + CurDir())
		ENDIF
		IF AT("%C", cDir) > 0
			cDir := STRTRAN(cDir, "%C", CurDrive() + ":")
		ENDIF
		IF AT("%W", cDir) > 0
			cDir := STRTRAN(cDir, "%W", GetWindowsFolder())
		ENDIF
		IF AT("%S", cDir) > 0
			cDir := STRTRAN(cDir, "%S", GetSystemFolder())
		ENDIF
		
		do while (substr(cDir,-1) == '\')
			cDir := substr(cDir, 1, LEN(cDir)-1)
		enddo
		
		asize( aFolders, 0 )
		aadd( aFolders, cDir )
		if cSub == 'yes'
			_aSubFolders( cDir, @aFolders ) // recursive subFolders aggregation
		endif
#ifdef DEBUG
		msgMulty( aFolders, cDir )
#endif
		for nJ := 1 to LEN(aFolders)
			aIncludeMask := hb_aTokens(LOWER(cIncludeMask), cMaskSeparator)
#ifdef DEBUG
		msgMulty( aIncludeMask, cDir )
#endif
			tstMaskList(@aIncludeMask)
#ifdef DEBUG
		msgMulty( aIncludeMask, cDir )
#endif
			for nK := 1 to LEN(aIncludeMask)
				cPath := cFilePath( aFolders[nJ] + '\' + aIncludeMask[nK] )
				If !lIsDir( cPath )
					MsgAlert( STRTRAN(cMsgDir, "%1", cPath) )
				Else
					aDir := Directory( aFolders[nJ] + '\' + aIncludeMask[nK] )
					IF LEN(aDir) > 0
						AEVAL(aDir, {|ele| AADD(aFiles, cPath + "\" + ele[F_NAME]), ;
						AADD( aInfo, { cPath+"\"+ele[F_NAME], ele[F_SIZE], ele[F_DATE], ele[F_TIME], ele[F_ATTR] } ), ;
						nTotLen += ele[F_SIZE]})
					ENDIF
				EndIf
			next
		next
	NEXT

	IF LEN(aFiles)==0
		MsgStop( cMsgEmpty )
		return nil
	ENDIF

	DEFINE WINDOW myBackUp ; 
		AT 0, 0 ; 
		WIDTH iWW ; 
		HEIGHT iWH ; 
		TITLE MYTITLE ; 
		ICON 'ICON_1' ;
		MAIN ;
		NOMINIMIZE NOMAXIMIZE NOSIZE ;
		ON INIT ZipFiles(aFiles) ;
		FONT "MS Sans Serif" ;
		SIZE 8

	if FILE( DirPrg() + "\SKINS\" + cSkin )
		@ -2,-2 IMAGE Image_1 ; 
			PICTURE DirPrg()+"\SKINS\"+cSkin ; 
			WIDTH myBackUp.Width - 2; 
			HEIGHT myBackUp.Height - IF(IsXPThemeActive(), 27, 20)
	endif

	@ 34,13 LABEL Label_1 ; 
		WIDTH 557 HEIGHT 16 ;
		BACKCOLOR YELLOW ;
		FONTCOLOR BLUE ;
		CENTERALIGN ;
		BORDER
		
	@ 69,13 LABEL myTimeLabel ; 
		WIDTH 557 HEIGHT 16 ;
		BACKCOLOR BLUE ;
		FONTCOLOR YELLOW ;
		BOLD ;
		CENTERALIGN ;
		BORDER

	@ 104,13 IMAGE Image_2 ; 
		PICTURE "ANIM1" ; 
		WIDTH 15 HEIGHT 20

	@ 104, 33 PROGRESSBAR Progress_1	;
		RANGE 0, 100 			;
		WIDTH 537 ;
		HEIGHT 20 ;
		MARQUEE

	@ myBackUp.Height - IF(IsXPThemeActive(), 47, 40),6 LABEL Label_2 ; 
		VALUE "Copyright " + Chr(169) +" "+ COPYRIGHT ;
		WIDTH 300 HEIGHT 14 ;
		TRANSPARENT

	END WINDOW
	
	if !FILE( DirPrg() + "\SKINS\" + cSkin )
		MsgAlert( STRTRAN(cMsgSkin, "%1", cSkin) )
	endif
	if randomBetween(0, 1) == 0
		CENTER WINDOW myBackUp
	else
		myBackUp.Row := randomBetween(0, GetDesktopHeight( ) - iWH )
		myBackUp.Col := randomBetween(0, GetDesktopWidth( ) - iWW)
	endif
	
	myBackUp.TopMost := .T.
	
	ACTIVATE WINDOW myBackUp
RETURN NIL
//------------------------------------------------------------------//
Function randomBetween(iFrom, iTo)
	iFrom := MIN(iFrom, iTo)
	iTo := MAX(iFrom, iTo)
return(INT(iFrom + HB_RANDOM()*(iTo-iFrom+1)))
//------------------------------------------------------------------//
PROCEDURE tstMaskList(aIn)
	local ii := 0, ll := 0, ff := 0
	 // clear illigal file Names
	AEVAL( aIn, { |cValue,nIndex| cValue := ALLTRIM( cValue ), cValue := IF(tstFileMask( cValue ), cValue, '' ), aIn[nIndex] := cValue } )
	ASORT( aIn,,, { |x, y| x < y } )
	ll := LEN(aIn)
	do while empty(aIn[1])
		ADEL(aIn, 1)
		ll--
	enddo
	ASIZE(aIn, ll)
	if ll > 1
		// clear doublicates
		for ii := 1 to ll - 1 // clear doublicates
			if ASCAN( aIn, aIn[ii], ii+1, ll-ii) > 0
				aIn[ii] := ''
			endif
		next
		ASORT( aIn,,, { |x, y| x < y } )
		do while empty(aIn[1])
			ADEL(aIn, 1)
			ll--
		enddo
		ASIZE(aIn, ll)
		// clear cAllFilesMask, if there are other types
		if ll > 1 .and. (ff := ascan(aIn, cAllFilesMask)) > 0
			ADEL( aIn, ff)
			ll--
		endif
		ASIZE(aIn, ll)
	endif
RETURN
//------------------------------------------------------------------//
FUNCTION tstFileMask( cMaskIn ) // test for illegal characters in mask
	// Use any character in the current code page for a name, 
	// including Unicode characters and characters in the extended character set (128–255), 
	// except for the following:
	// < (less than)
	// > (greater than)
	// : (colon)
	// " (double quote)
	// / (forward slash)
	// \ (backslash)
	// | (vertical bar or pipe)
	// ? (question mark)
	// * (asterisk)
	Local lRet := .f., aTmp := {}, ii := 0
	Local aIlegalFNChars := { '<', '>', ':', '"', '/', '\', '|' }
	Local ll := LEN(aIlegalFNChars)
	aTmp := hb_aTokens( cMaskIn, '.' )
	if LEN( aTmp ) == 2 .and. !( empty(aTmp[1]) .or. empty(aTmp[2]) )
		do while (++ii <= ll) .and. (lRet := !(aIlegalFNChars[ii] $ cMaskIn) )
		enddo
	endif
RETURN lRet
//------------------------------------------------------------------//
PROCEDURE _aSubFolders( cRootFolder, aFolders )  // recursive subFolders aggregation
	local _aFolders := {}, _aDir := Directory( cRootFolder + '\' , 'D' )
	aeval( _aDir, { |x| IF( 'D' $ x[F_ATTR] .and. !('.' $ x[F_NAME]), aadd( _aFolders, x ), Nil ) } )
	if LEN( _aFolders ) > 0
		aeval( _aFolders, { |x| aadd( aFolders, cRootFolder + '\' + x[F_NAME] ),  _aSubFolders( cRootFolder + '\' + x[F_NAME], @aFolders ) } )
	endif
RETURN
*--------------------------------------------------------*
FUNCTION ZipFiles(aFiles)
*--------------------------------------------------------*
LOCAL cBmp := "ANIM", nInterval := 50, nCount := 0, nMax := 17
PRIVATE nActualTot := 0

	nCompress := IF(nCompress < 0, 0, IF(nCompress > 9, 9, nCompress))

	DEFINE TIMER Timer_1 OF myBackUp ;
            INTERVAL nInterval ;
            ACTION ( nCount++, nCount := IF(nCount > nMax, 1, nCount), ;
		myBackUp.Image_2.Picture := cBmp + NTRIM(nCount) )

	COMPRESS aFiles ;
            TO cZip ;
            BLOCK {|cFile, nPos| ProgressUpdate(nPos, cFile) };
            LEVEL nCompress ;
            OVERWRITE STOREPATH

	myBackUp.Timer_1.Enabled := .f.
	myBackUp.Progress_1.Value := 100

	IF FILE(cZip) .AND. DIRECTORY(cZip)[1][F_SIZE] > 22
		myBackUp.Label_1.FontBold := .T.
		myBackUp.Label_1.FontSize := 9
		myBackUp.Label_1.Value := cMsgEnd
		myBackUp.myTimeLabel.Value := cMsgTotalTime + ' : ' + timeToString( tTotalTime, 3 ) + ' - ' + ;
								cMsgRate + ' : ' + lTrim( Transform( ( nTotLen / 1024 ) / ( tTotalTime/1000 ), '999,999,999,999.999' ) ) + ' kB/sec'
		myBackUp.Image_2.Hide
		myBackUp.Image_2.Picture := "ZIP_OK"
		myBackUp.Image_2.Show
		PlayOK()
	ELSE
		myBackUp.Label_1.FontBold := .T.
		myBackUp.Label_1.FontSize := 9
		myBackUp.Label_1.Hide
		myBackUp.Label_1.Value := STRTRAN(cMsgFailed, "%1", cZip)
		myBackUp.Label_1.FontColor := RED
		myBackUp.Label_1.Show
		myBackUp.Image_2.Hide
		myBackUp.Image_2.Picture := "ZIP_NOK"
		myBackUp.Image_2.Show
		PlayExclamation()
	ENDIF
	
	maintainArchive()

	INKEY(5)
	myBackUp.Release

RETURN NIL
//------------------------------------------------------------------//
FUNCTION maintainArchive()
	local aZipFiles := DIRECTORY(cTargetFolder + cTargetPrefix + '*' + cTargetExtension)
	local aZipsToDelete := {}, sD
#ifdef DEBUG
	msgMulty(aZipFiles,cTargetFolder + cTargetPrefix + '*' + cTargetExtension)
#endif
	if LEN(aZipFiles) > nMinBackUpsToKeep
		aeval(aZipFiles, {|x| sD := strtran(x[F_NAME],cTargetPrefix,''), IF(dToDay - stod(substr(sD,1,8)) > nMinDaysToKeep, aadd(aZipsToDelete,cTargetFolder+x[F_NAME]),Nil)})
	endif
#ifdef DEBUG
	 msgMulty(aZipsToDelete,'aZipsToDelete')
#endif
	AEval( aZipsToDelete, { |file| myBackUp.Label_1.Value := LOWER( STRTRAN(cMsgDelete, "%1", file) ), Ferase( file ) } )
RETURN NIL
//------------------------------------------------------------------//
STATIC FUNCTION ProgressUpdate(nPos, cFile)
LOCAL nFileSize := aInfo[nPos][2]

	nActualTot += nFileSize
	myBackUp.Progress_1.Value := Int( ( nActualTot / nTotLen ) * 100 )

	myBackUp.Label_1.Value := LOWER(cFile + " => " + cZip)
	
	tTotalTime := GetTickCount() - tStartTime
	myBackUp.myTimeLabel.Value := cMsgTotalTime + ' : ' + timeToString( tTotalTime, 3 )
	
	DO EVENTS

Return Nil

*--------------------------------------------------------*
Function timeToString( nTime, nDecPoints )
*--------------------------------------------------------*
   local cRet, nDAYS, nHRS, nMINS, nSECS, nDECS, lDecimals := ( nDecPoints > 0 )
   nDECS := nTime % (10^nDecPoints)
   nTime := int((nTime - nDECS)/(10^nDecPoints))
   nSECS := nTime % 60
   nTime := int((nTime - nSECS)/60)
   nMINS := nTime % 60
   nTime := int((nTime - nMINS)/60)
   nHRS  := nTime % 24
   nDAYS := (nTime - nHRS)/24
   cRet := IF(Empty(nDAYS), "", lTrim( str( nDAYS ) ) + ":") + ;
	   strzero( nHRS, 2 ) + ":" + ;
	   strzero( nMINS, 2 ) + ":" + ;
	   strzero( nSECS, 2 ) + ;
	   IF(lDecimals, "." + strzero( nDECS, nDecPoints ), "")
	do while left(cRet ,3) == '00:' // remove leading zeros
		cRet := substr(cRet, 4)
	enddo
Return cRet

*--------------------------------------------------------*
STATIC FUNCTION lIsDir( cDir )
*--------------------------------------------------------*
LOCAL lExist := .T.
   IF DIRCHANGE( cDir ) > 0
	lExist := .F.
   ELSE
	DIRCHANGE( DirPrg() )
   ENDIF
RETURN lExist

*--------------------------------------------------------*
STATIC FUNCTION DirPrg()
*--------------------------------------------------------*
Local cFolder := GetStartupFolder()
RETURN IF(Right(cFolder, 1) == "\", Left(cFolder, LEN(cFolder) - 1), cFolder)

//------------------------------------------------------------------//
STATIC FUNCTION hbTimeStamp()
   local cRet := ''
   local cDf := set(_SET_DATEFORMAT,"YYYY.MM.DD")
   cRet := HB_TTOC(HB_DATETIME())
   set(_SET_DATEFORMAT,cDf)
   cRet := aJoin(sSplit(cRet, ' '),'')
   cRet := aJoin(sSplit(cRet, '.'),'')
   cRet := aJoin(sSplit(cRet, ':'),'')
return(cRet)
//------------------------------------------------------------------//
STATIC Function aJoin(aIn, sDelim)
	local sRet := ''
	local i, iLen := LEN(aIn)
	do case
	case iLen == 0
		sRet := ''
	case iLen == 1
		sRet := aIn[1]
	otherwise
		for i := 1 to iLen - 1
			sRet += (aIn[i] + sDelim)
		next
		sRet += aIn[iLen]
	endcase
return(sRet)
//------------------------------------------------------------------//
function sSplit(sIn, sDelim)
	local aRet := {}, bNilDel, iDLen
	local sTmp1, sTmp, i, iLen := LEN(sIn), iStep
	sDelim := IF(sDelim==Nil .or. valtype(sDelim)!='C','',sDelim)
	iDLen := LEN(sDelim)
	bNilDel := (iDLen == 0)
	iStep := if(bNilDel, 1, iDLen)
	sTmp := ""
	if bNilDel
		for i := 1 to iLen
			sTmp1 := substr(sIn, i, iStep)
			aadd(aRet, sTmp1)
		next
	else
		aRet := hb_aTokens(sIn, sDelim)
	end if
return(aRet)
#ifdef DEBUG
//------------------------------------------------------------------//
STATIC FUNCTION xToString( xValue )
//------------------------------------------------------------------//
LOCAL cType := ValType( xValue )
LOCAL cValue := "", nDecimals := Set( _SET_DECIMALS ), aTmp := {}

   DO CASE
      CASE cType $  "CM";  cValue := alltrim( xValue )
      CASE cType == "N" // ; nDecimals := IF( xValue == int(xValue), 0, nDecimals) ; cValue := LTrim( Str( xValue, 20, nDecimals ) )
	   aTmp := hb_aTokens(LTrim(str(xValue)),'.')
	   if LEN(aTmp) == 1
	      nDecimals := IF( xValue == int(xValue), 0, nDecimals)
	   else
	      nDecimals := LEN(aTmp[2])
	   endif
	   cValue := LTrim( Str( xValue, 20, nDecimals ) )
      CASE cType == "D" ;  cValue := DToC( xValue )
      CASE cType == "T" ;  cValue := hb_TSToStr( xValue, .T. )
      CASE cType == "L" ;  cValue := IF( xValue, "True", "False" )
      CASE cType == "A" ;  cValue := AToC( xValue )
      CASE cType $  "UE";  cValue := "NIL"
      CASE cType == "B" ;  cValue := "{|| ... }"
      CASE cType == "O" ;  cValue := "{" + xValue:className + "}"
   ENDCASE

RETURN cValue
//------------------------------------------------------------------//
/*
	p.MsgMulty()  : Display a message with any type data
	Syntax        : MsgMulty( <xMesaj> [, <cTitle> ] ) -> NIL
	Arguments     : <xMesaj> : Any type data value.
							 If <xMesaj> is an array, each element will display as 
							 a seperated line.                      
				  <cTitle> : Title of message box. 
							 Default is calling module name and line number.
	Return        : NIL
	History :
			7.2006 : First Release  
*/
PROCEDURE MsgMulty( xMesaj, cTitle )
	LOCAL cMessage := ""
	IF xMesaj # NIL
		IF cTitle == NIL
			cTitle := PROCNAME(1) + "\" +   LTRIM(STR( PROCLINE(1) ) )
		ENDIF
		IF VALTYPE( xMesaj  ) == "A"
			AEVAL( xMesaj, { | x1 | cMessage +=  xToString( x1 ) + CRLF } )
		ELSE
			IF VALTYPE( xMesaj  ) == "C"  
				cMessage:=  xMesaj 
			ELSE
				cMessage:=  xToString( xMesaj )
			ENDIF
		ENDIF
		MsgInfo( cMessage, cTitle )
	ENDIF
RETURN //  MsgMulty()
#endif
//------------------------------------------------------------------//
Function getFileDate(sFileName)
	local cRet := '', cDf, tTime
	if file(sFileName)
		cDf := set(_SET_DATEFORMAT,'YYYY-MM-DD')
		hb_FGetDateTime( sFileName, @tTime )
		cRet := HB_TTOC(tTime)
		set(_SET_DATEFORMAT,cDf)
		cRet := sSplit(cRet, '.')[1]
		cRet := aJoin(sSplit(cRet, ' '),'')
		cRet := aJoin(sSplit(cRet, '-'),'')
		cRet := aJoin(sSplit(cRet, ':'),'')
	endif
return(cRet)
//------------------------------------------------------------------//


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

HB_FUNC( GETTICKCOUNT )
{
   hb_retnl( (LONG) GetTickCount() ) ;
}

#pragma ENDDUMP
