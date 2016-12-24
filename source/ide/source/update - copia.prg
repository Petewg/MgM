#include "hmg.ch"
#include "ide.ch"


*------------------------------------------------------------*
PROCEDURE Update()
*------------------------------------------------------------*
   LOCAL cPath AS STRING := GetStartupFolder()

   IF MsgYesNo( "You're going to download updates from www.hmgextended.com"    + CRLF +        ;
                "The new files will be placed into '\IDE\UPDATES' directory."  + CRLF + CRLF + ;
                "Please note that any newer source files with the same name, " + CRLF +        ;
                "already existing inside this folder will not be overwritten!" + CRLF + CRLF + ;
                "Are you sure you want to proceed?", "UPDATE FROM WEB", .T., NIL, .T. )

      DownloadFromWWW( "http://www.hmgextended.com/files/HMGS-IDE/ide.zip", cPath + "\ide.zip", NIL )

   ENDIF

RETURN


*------------------------------------------------------------*
PROCEDURE DownloadFromWWW( cURL AS STRING, cLOCALFileName AS STRING )
*------------------------------------------------------------*
   LOCAL oCon  AS OBJECT
   LOCAL oUrl  AS OBJECT
   LOCAL cResponse
   // LOCAL nResp AS LOGICAL  //? Invalid Hungarian

   cLocalFileName := AllTrim( cLocalFileName )
   // nResp          := isInternet()

   IF ! IsInternet()   // nResp = .F.
      MsgExclamation( "Seems that Internet connection is not available. Check it and retry..." )
      RETURN
   ENDIF

   oUrl              := TUrl():New( cUrl )
   oCon              := TIPClientHTTP():New( oUrl )
   oCon:nConnTimeout := 20000

   // MsgBox( "Connecting with " + oUrl:cServer   )
   // MsgBox( "localfile= "      + cLocalFilename )

   IF oCon:Open( cUrl )

      // MsgBox( "Connection established." + Chr(10) + "Press OK to retrieve " + oUrl:cPath +oUrl:cFile )
      oCon:WriteAll( cLocalFileName )

      // MsgBox( "Downloaded..." )
      oCon:Close()

      Form()

   ELSE

      // MsgBox( "Can't connect with " + oUrl:cServer )
      cResponse := "Can't connect with " + oUrl:cServer

      IF oCon:SocketCon == NIL
         // MsgBox( "Connection not initiated" )
         cResponse += hb_eol() + "Connection not initiated."

      ELSEIF hb_inetErrorCode( oCon:SocketCon ) == 0
         // MsgBox( "Server responded: " + oCon:cReply )
         cResponse += hb_eol() + "Server responded: " + oCon:cReply
      ELSE
         // MsgBox( "Error in connection: " + hb_inetErrorDesc( oCon:SocketCon ) )
         cResponse += hb_eol() + "Error description: " + hb_inetErrorDesc( oCon:SocketCon )
      ENDIF

      MsgStop( cResponse, "Connection Error")

   ENDIF

   RETURN

*------------------------------------------------------------*
PROCEDURE Form()
*------------------------------------------------------------*

  DEFINE WINDOW Form_2 ;
         AT         0, 0 ;
         WIDTH      400 HEIGHT 215 ;
         TITLE      "Extracting sources of HMGS_IDE to \Updates folder" ;
         NOMAXIMIZE NOSIZE ;
         FONT       "Arial" SIZE 9;
         ON INIT    UNZIPFile()

     DEFINE PROGRESSBAR ProgressBar_1
        ROW        60
        COL        45
        WIDTH      310
        HEIGHT     30
        RANGEMIN   0
        RANGEMAX   10
        VALUE      0
        FORECOLOR  {0,130,0}
     END PROGRESSBAR

     DEFINE LABEL        Label_1
        ROW         100
        COL         25
        WIDTH       350
         HEIGHT      20
         VALUE       ""
        FONTNAME    "Arial"
        FONTSIZE    10
        TOOLTIP     ""
        FONTBOLD    .T.
        TRANSPARENT .T.
        CENTERALIGN .T.
     END LABEL

     ON KEY ESCAPE ACTION Form_2.Release

  END WINDOW

  CENTER   WINDOW Form_2

  ACTIVATE WINDOW Form_2

RETURN

*------------------------------------------------------------*
PROCEDURE UnzipFile()
*------------------------------------------------------------*
   LOCAL cCurDir  := GetStartupFolder()
   LOCAL cArchive := cCurDir + "\ide.zip"
   LOCAL dDate, cTime, lSuccess

   Form_2.ProgressBar_1.RangeMin := 1
   Form_2.ProgressBar_1.RangeMax := Len( hb_GetFilesInZip( cArchive ) ) - 1

   //  RENAME ( cCurDir + "\IDE.EXE" ) TO ( cCurDir + "\IDEOLD.EXE" )

	msgdebug( "before uncompress" )
	
	msgdebug( cArchive )
	// "C:\MiniguiM\minigui\source\IDE\Bin\ide.zip"
   UNCOMPRESS cArchive ;
      EXTRACTPATH cCurDir /*+ "\Updates"*/ ;
		RESULT lSuccess ;
      BLOCK { | cFile, nPos | ProgressUpdate( nPos, cFile, .T. ) } ;
      CREATEDIR
		
	msgdebug( "after uncompress")
   /*
	UNCOMPRESS [ FILE ] <zipfile> ;
		[ EXTRACTPATH <extractpath> ] ;
		[ RESULT [ TO ] <lSuccess> ] ;
		[ BLOCK <block> ] ;
		[ <createdir: CREATEDIR> ] ;
		[ PASSWORD <password> ] ;
		[ <dummy1: FILEMASK, FILEARRAY> <mask> ] ;
		[ FILEPROGRESS <fileblock> ] ;
	=> ;
	[ <lSuccess> := ] hb_UnzipFile( <zipfile> , <block> , <.createdir.> , <password> , <extractpath> , <mask> , <fileblock> )

	*/
	IF lSuccess
	
   msgdebug( "lSuccess" )
	
      IF hb_FileExists( cCurDir + "\UPDATES\BIN\IDE.EXE" )

         IF hb_FileExists( cCurDir + "\IDE.EXE" )
            IF hb_FileExists( cCurDir + "\IDE.OLD" )
               hb_FileDelete( cCurDir + "\IDE.OLD" )
            ENDIF
            hb_vfRename(cCurDir + "\IDE.EXE", cCurDir + "\IDE.OLD")
         ENDIF

         // COPY FILE ( cCurDir + "\UPDATES\BIN\IDE.EXE" ) TO ( cCurDir + "\IDENEW.EXE" )
         hb_vfCopyFile( cCurDir + "\UPDATES\BIN\IDE.EXE" ,  cCurDir + "\IDE.EXE" )
         hb_FGetDateTime( cCurDir + "\UPDATES\BIN\IDE.EXE", @dDate, @cTime )
         hb_FSetDateTime( cCurDir + "\IDE.EXE", @dDate, @cTime )

      ENDIF

      EXECUTE FILE ( cCurDir + "\IDE.EXE" )

      aData[ _DISABLEWARNINGS ] := ".T."

      EXIT()

   ELSE

      MsgStop( "Unzip Error!" )

   ENDIF

   RETURN


*------------------------------------------------------------*
FUNCTION ProgressUpdate( nPos          AS NUMERIC, ; // Progress Bar position
                         cFile         AS STRING,  ; // Extracted FileName
                         lShowFileName AS LOGICAL  ; // Show FileName flag
                       )
*------------------------------------------------------------*

   Default lShowFileName := .F.

   Form_2.ProgressBar_1.Value := nPos
   Form_2.Label_1.Value       := cFileNoPath( cFile )

   DO EVENTS

   IF lShowFileName
      Inkey( .1 )
   ENDIF

RETURN( NIL )

FUNCTION IsInternet( nTimeout )
*******************************************************************************
	LOCAL aAddress, hSocket, lCanConnect

	
   aAddress := hb_socketResolveINetAddr( "www.google.com", 80 )

   IF Empty( aAddress )
      RETURN .F.
   ENDIF

	hSocket := hb_socketOpen()
	lCanConnect := hb_socketConnect( hSocket, aAddress, hb_defaultValue( nTimeout, 2000 ) )
   hb_socketClose( hSocket )

	RETURN lCanConnect

	
/*
*------------------------------------------------------------*
FUNCTION IsInternet()
*------------------------------------------------------------*
  LOCAL nEstado   AS NUMERIC
  LOCAL cConexion AS STRING  := ""

  nEstado := InternetGetConnectedStateEx( 0, @cConexion, 0, 0 )

RETURN( nEstado == 1 )


*------------------------------------------------------------*
FUNCTION InternetGetConnectedStateEx( lpdwFlags, lpszConnectionName, dwNameLen, dwReserved )
*------------------------------------------------------------*
  LOCAL uResult
  LOCAL hInstDLL             := LoadLibrary( "WININET.DLL" )
  LOCAL nProcAddr AS NUMERIC := GetProcAddress( hInstDLL, "InternetGetConnectedStateEx" )

   uResult := CallDll( hInstDLL, nProcAddr, NIL, 4, 4, lpdwFlags, 10, lpszConnectionName, 3, dwNameLen, 4, dwReserved )

   FreeLibrary( hInstDLL )

RETURN uResult
*/
