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
   LOCAL nResp AS LOGICAL  //? Invalid Hungarian
   
   cLOCALFileName := AllTrim( cLOCALFileName )
   nResp          := isInternet()
   
   IF nResp = .F.
      MsgBox( "Internet is not connected. Update is aborted" )
      RETURN
   ENDIF
   
   oUrl              := TURL():NEW( cURL )
   oCon              := TipClientHttp():NEW( oUrl )
   oCon:nConnTimeout := 20000
   
   // MsgBox( "Connecting with " + oUrl:cServer   )
   // MsgBox( "localfile= "      + cLocalFilename )
   IF oCon:Open( cURL )
      
      // MsgBox( "Connection established." + chr(10) + "Press OK to retrieve " + oUrl:cPath +oUrl:cFile )
      oCon:WriteAll( cLOCALFileName )
      
      // MsgBox( "Downloaded..." )
      oCon:CLOSE()
      
      FORM()
      
   ELSE
      MsgBox( "Can't connect with " + oUrl:cServer )
      
      IF oCon:SocketCon == NIL
         MsgBox( "Connection not initiated" )

      ELSEIF hb_InetErrorCode( oCon:SocketCon ) == 0
         MsgBox( "Server sayed: " + oCon:cReply )
         
      ELSE
         MsgBox( "Error in connection: " + hb_InetErrorDesc( oCon:SocketCon ) )
      ENDIF
      
   ENDIF
   
   RETURN
   
   
*------------------------------------------------------------*
PROCEDURE FORM()
*------------------------------------------------------------*
   
   DEFINE WINDOW Form_2 ;
          AT         0, 0 ;
          WIDTH      400 HEIGHT 215 ;
          TITLE      "Extracting sources of HMGS_IDE to \Updates folder" ;
          NOMAXIMIZE NOSIZE ;
          FONT       "Arial" SIZE 9 ;
          ON INIT    UNZIPFile()
      
      DEFINE PROGRESSBAR ProgressBar_1
         Row        60
         Col        45
         WIDTH      310
         HEIGHT     30
         RANGEMIN   0
         RANGEMAX   10
         VALUE      0
         FORECOLOR  { 0, 130, 0 }
      END PROGRESSBAR

      DEFINE LABEL        Label_1
         Row         100
         Col         25
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

      ON KEY Escape ACTION Form_2.Release

   END WINDOW

   CENTER   WINDOW Form_2

   ACTIVATE WINDOW Form_2

   RETURN


*------------------------------------------------------------*
PROCEDURE UnzipFile()
*------------------------------------------------------------*
   LOCAL cCurDir  := GetStartupFolder()
   LOCAL cArchive := cCurDir + "\ide.zip"
   LOCAL dDate, cTime, lSuccess, cSubDir

   LOCAL aFiles := hb_GetFilesInZip( cArchive )
   LOCAL cExtractDir := "Updates\"

   Form_2.ProgressBar_1.RangeMin := 1
   Form_2.ProgressBar_1.RangeMax := Len( aFiles ) - 1

   /*
  UNCOMPRESS cArchive ;
      EXTRACTPATH cCurDir + "\Updates" ;
      FILEMASK "*.*" ;
      BLOCK { | cFile, nPos | ProgressUpdate( nPos, cFile, .T. ) } ;
      RESULT lSuccess ;
      CREATEDIR
   */

   AEval( aFiles, { | e | cSubDir := hb_FNameDir( e ), hb_DirBuild( cCurDir + cSubDir ) } )

   lSuccess := hb_UnZipFile( cArchive , { | cFile, nPos | ProgressUpdate( nPos, cFile, .T. ) } , ;
                             .T. , , cCurDir , aFiles , )

   IF lSuccess

     /*
     //  RENAME ( cCurDir + "\IDE.EXE" ) TO ( cCurDir + "\IDEOLD.EXE" )
     COPY FILE ( cCurDir + "\UPDATES\BIN\IDE.EXE" ) TO ( cCurDir + "\IDENEW.EXE" )
     hb_FGetDateTime( cCurDir + "\UPDATES\BIN\IDE.EXE", @dDate, @cTime )
     hb_FSetDateTime( cCurDir + "\IDENEW.EXE", @dDate, @cTime )
     */

      IF hb_FileExists( cCurDir + "\UPDATES\BIN\IDE.EXE" )
         IF hb_FileExists( cCurDir + "\IDE.EXE" )
            IF hb_FileExists( cCurDir + "\IDEOLD.EXE" )
               hb_FileDelete( cCurDir + "\IDEOLD.EXE" )
            ENDIF
            hb_vfRename( cCurDir + "\IDE.EXE", cCurDir + "\IDEOLD.EXE" )
         ENDIF

         // COPY FILE ( cCurDir + "\UPDATES\BIN\IDE.EXE" ) TO ( cCurDir + "\IDENEW.EXE" )
         hb_vfCopyFile( cCurDir + "\UPDATES\BIN\IDE.EXE" ,  cCurDir + "\IDE.EXE" )
         hb_FGetDateTime( cCurDir + "\UPDATES\BIN\IDE.EXE", @dDate, @cTime )
         hb_FSetDateTime( cCurDir + "\IDE.EXE", @dDate, @cTime )

      ENDIF

      EXECUTE File ( cCurDir + "\IDE.EXE" )

      aData[ _DISABLEWARNINGS ] := ".T."

      // FErase( cArchive )

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

   DEFAULT lShowFileName := .F.

   Form_2.ProgressBar_1.Value := nPos
   Form_2.Label_1.Value       := cFileNoPath( cFile )

   DoEvents()

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

   uResult := CallDLL( hInstDLL, nProcAddr, NIL, 4, 4, lpdwFlags, 10, lpszConnectionName, 3, dwNameLen, 4, dwReserved )

   FreeLibrary( hInstDLL )

RETURN uResult
*/
