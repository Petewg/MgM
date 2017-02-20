/*
 * MiniGUI UnRar Demo
 * Author: P.Chornyj <myorg63@mail.ru>
*/

#include "minigui.ch"
#include "unrar.ch"

#define cTab CHR(9)
#define msginfo( c ) MsgInfo( c, , , .f. )

Procedure Main

   DEFINE WINDOW Win_1 ;
      AT 0,0 ;
      WIDTH 400 ;
      HEIGHT 400 ;
      TITLE 'UNRAR Test' ;
      ICON 'UNRAR' ;
      MAIN

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Test 0: Testing archive..'			ACTION Test0()
            MENUITEM 'Test 1: Get archive info..'			ACTION Test1()
            MENUITEM 'Test 2: The number of files in archive..'		ACTION Test2()
            MENUITEM 'Test 3: Get file info..'				ACTION Test3()
            MENUITEM 'Test 4: Extract all files from archive..'		ACTION Test4("out\", .T. )
            MENUITEM 'Test 4: Extract some files from archive..'	ACTION Test4("out\", .F. )
            MENUITEM 'Test 5: Get archive comments..'			ACTION Test5()
            SEPARATOR                                           
            MENUITEM 'Test 6: Get Unrar.dll API version'		ACTION Test6()
            SEPARATOR
            ITEM 'Exit' ACTION ThisWindow.Release
         END POPUP
      END MENU

      DEFINE STATUSBAR 
	STATUSITEM ""   
      END STATUSBAR

   END WINDOW

   CENTER WINDOW Win_1

   ACTIVATE WINDOW Win_1

Return

/*
   Test 0:
   -------
   Hb_RarTestFiles( ArchiveName, cPassWord, File ) ---> lSuccess
   Hb_RarGetProcStatus() ---> nLastUnRarProcessStatus

   nLastUnRarProcessStatus is one from possible values:

   RAR_ST_SUCCESS     0  - an          action is successful
   RAR_ST_OPEN        1  - open archive process error
   RAR_ST_OUT         2  - out  archive process error
   RAR_ST_OPEN_OUT    3
   RAR_ST_HBROKEN     4  - file header broken

*/
Procedure Test0()
   Local x

   x := Getfile ( { {'Rar Files','*.rar'} } , 'Open archive' , GetCurrentFolder() , .f. , .t. )

   IF ( ! Empty( x ) )
      IF ( Hb_RarTestFiles( x ) )	
         msginfo ( "Testing is OK for" + CRLF + x )
      ELSE
         UnRarErrorInfo( x, Hb_RarGetProcStatus() )
      ENDIF
   ENDIF

Return

/*
   Test 1:
   -------
   Hb_RarGetArchiveInfo( ArchiveName ) ---> nFlags

   nFlags - combination of bit flags.

   Possible values:

   0x0001  - Volume attribute (archive volume)
   0x0002  - Archive comment present
   0x0004  - Archive lock attribute
   0x0008  - Solid attribute (solid archive)
   0x0010  - New volume naming scheme ('volname.partN.rar')
   0x0020  - Authenticity information present
   0x0040  - Recovery record present
   0x0080  - Block headers are encrypted
   0x0100  - First volume (set only by RAR 3.0 and later)
*/
Procedure Test1()
   Local x, msg := ""
   Local flags
   Local status := 0

   x := Getfile ( { {'Rar Files','*.rar'} } , 'Open archive' , GetCurrentFolder() , .f. , .t. )

   IF ( ! Empty( x ) )
      flags := Hb_RarGetArchiveInfo( x ) 	

      status := Hb_RarGetProcStatus()
      IF ( status <> RAR_ST_SUCCESS )
         UnRarErrorInfo( x, status )
         RETURN
      ENDIF

      msg += ( "Archive     " + cTab + " : " + x + CRLF )
      msg += ( "Volume      " + cTab + " : " + iif( lAnd( flags,  1 ), "yes", "no" ) + CRLF )
      msg += ( "Comment     " + cTab + " : " + iif( lAnd( flags,  2 ), "yes", "no" ) + CRLF )
      msg += ( "Locked      " + cTab + " : " + iif( lAnd( flags,  4 ), "yes", "no" ) + CRLF )
      msg += ( "Solid" + cTab + cTab + " : " + iif( lAnd( flags,  8 ), "yes", "no" ) + CRLF )
      msg += ( "New naming  " + cTab + " : " + iif( lAnd( flags, 16 ), "yes", "no" ) + CRLF )
      msg += ( "Authenticity" + cTab + " : " + iif( lAnd( flags, 32 ), "yes", "no" ) + CRLF )
      msg += ( "Recovery    " + cTab + " : " + iif( lAnd( flags, 64 ), "yes", "no" ) + CRLF )
      msg += ( "Encr.headers" + cTab + " : " + iif( lAnd( flags,128 ), "yes", "no" ) + CRLF )
      msg += ( "First volume" + cTab + " : " + iif( lAnd( flags,256 ), "yes", "no or older than 3.0" ) )

      MsgInfo( msg, "Archive Info" )
   ENDIF

Return

/*
   Test 2:
   -------
   Hb_RarGetFilesCount( ArchiveName, cPassWord, lIncludeDirectory ) ---> nNumberOfFiles
*/
Procedure Test2()
   Local x
   Local nCount1 := 0, nCount2 := 0, status := 0
   Local msg := ""

   x := Getfile ( { {'Rar Files','*.rar'} } , 'Open archive' , GetCurrentFolder() , .f. , .t. )
   IF ( ! Empty( x ) )
      nCount1 := Hb_RarGetFilesCount( x, , .T. )
      nCount2 := Hb_RarGetFilesCount( x, , .F. )

      status := Hb_RarGetProcStatus()
      IF ( status == RAR_ST_SUCCESS )
         msg += ( "Archive name " + cTab + ": " + x + CRLF )
         msg += ( "The number of files in archive" + cTab + " : " +  str( nCount2 ) + CRLF )
         msg += ( "number of folders "  + cTab + cTab + " : " +  str( nCount1 - nCount2 ) + CRLF )
         msginfo( msg )
      ELSE
         UnRarErrorInfo( x, status )
      ENDIF
   ENDIF

Return

/*
   Test 3:
   --------
   Hb_RarGetFilesCount( ArchiveName, cPassWord, lIncludeDirectory ) ---> nNumberOfFiles
   Hb_RarGetFilesList( ArchiveName, cPassWord, lFileTimeAsDate, lIncludeTime, lIncludeSeconds )
*/
Procedure Test3()
   Local x
   Local nCount := 0, i := 1
   Local lFileTimeAsDate := .F., lIncludeTime := .T., lIncludeSeconds := .T.
   Local msg := "", OsName := ""
   Local aFiles
   Local status := 0

   x := Getfile ( { {'Rar Files','*.rar'} } , 'Open archive' , GetCurrentFolder() , .f. , .t. )
   IF ( ! Empty( x ) )
      nCount = Hb_RarGetFilesCount( x )		

      status := Hb_RarGetProcStatus()
      IF ( status <> RAR_ST_SUCCESS )
         UnRarErrorInfo( x, status )
         RETURN
      ENDIF

      IF nCount > 0		

         aFiles := Hb_RarGetFilesList( x,, lFileTimeAsDate, lIncludeTime, lIncludeSeconds )

         status := Hb_RarGetProcStatus()
         IF ( status <> RAR_ST_SUCCESS )
            UnRarErrorInfo( x, status )
            RETURN
         ENDIF

         FOR i := 1 TO nCount
            msg = ""
            msg += ( "Archive name " + cTab + ": " + aFiles[ i ][ RAR_ARCNAME ] + CRLF )
            msg += ( "File name    " + cTab + ": " + Hb_OemToAnsi( aFiles[ i ][ RAR_FILENAME ] )  + CRLF )
            msg += ( "Packed size, b  " + cTab + ": " + ltrim( transform( aFiles[i][ RAR_PACKSIZE ], "999 999 999" ) ) + CRLF )
            msg += ( "Unpacked size, b" + cTab + ": " + ltrim( transform( aFiles[i][ RAR_UNPSIZE ], "999 999 999" ) ) + CRLF )

            msg += ( "file continued from previous volume " + cTab + ": " + iif( lAnd( aFiles[ i ][ RAR_FLAGS ],  1 ), "yes", "no" ) + CRLF )
            msg += ( "file continued on next volume       " + cTab + ": " + iif( lAnd( aFiles[ i ][ RAR_FLAGS ],  2 ), "yes", "no" ) + CRLF )
            msg += ( "file encrypted with password        " + cTab + ": " + iif( lAnd( aFiles[ i ][ RAR_FLAGS ],  4 ), "yes", "no" ) + CRLF )
            msg += ( "file comment present                " + cTab + ": " + iif( lAnd( aFiles[ i ][ RAR_FLAGS ],  8 ), "yes", "no" ) + CRLF )
            msg += ( "compression of previous files is used (solid flag)" + cTab + ": " + iif( lAnd( aFiles[ i ][ RAR_FLAGS ],  16 ), "yes", "no" ) + CRLF )

            SWITCH aFiles[ i ][ RAR_HOSTOS ]
         CASE 0
            OsName := "MS DOS"
            EXIT
         CASE 1
            OsName := "OS/2"
            EXIT
         CASE 2
            OsName := "Win32"
            EXIT
         CASE 3
            OsName := "Unix"
            EXIT
            END SWITCH

            msg += ( "Host OS      "    + cTab + ": " + OsName       + CRLF )
            msg += ( "File time    "    + cTab + ": " + aFiles[ i ][ RAR_FILETIME ] + CRLF )
/*
            UnpVer - RAR version needed to extract file.
            It is encoded as 10 * Major version + minor version.
*/
            msg += ( "Unpack version "  + cTab + ": " + str( aFiles[ i ][ RAR_UNPVER ]/10 ) + CRLF )
            msg += ( "File attribute "  + cTab + ": " + aFiles[ i ][ RAR_FILEATTR ] + CRLF )

            MsgInfo( msg, "File Info : " + Hb_OemToAnsi( aFiles[ i ][ RAR_FILENAME ] ) )
         NEXT
      ENDIF
   ENDIF

Return

/*
   Test 4:
   -------
   Hb_UnrarFiles( ArchiveName, cPassWord, cOutPath, File )
*/
Procedure Test4( cOutDir, lAllFiles )
   Local x := Getfile ( { {'Rar Files','*.rar'} } , 'Open archive' , GetCurrentFolder() , .f. , .t. )
   Local status := 0

   IF ! Empty( x )
      IF lAllFiles
         Hb_UnrarFiles( x, , cOutDir )	
      ELSE
         Hb_UnrarFiles( x, , cOutDir, { "eis.ico", "rhs.file", 8 } )	
      ENDIF

      status := Hb_RarGetProcStatus()
      IF ( status <> RAR_ST_SUCCESS )
         UnRarErrorInfo( x, status )
         RETURN
      ENDIF
   ENDIF

Return

/*
   Test 5:	get archive comments
   ----------------------------
   Hb_RarSetCmtBufSize( [ nCmtBufSize ] ) ---> lSucces

   nCmtBufSize - contain size of buffer for archive comments ( in bytes ).
   Manimum comment size is 64.
   Maximum comment size is limited to 64Kb ( 65536-1 bytes ).
   Default value is 16384 bytes.

   If the comment text is larger than the buffer size,
      the comment text will be truncated.

      Hb_RarGetCmtBufSize( ) ---> nCmtBufSize
      CmtBufSize is size ( in bytes ) of buffer for archive comments.

      Hb_RarGetComment( ArchiveName, [ @CmtState ] ) ---> cArchiveComments
*/
Procedure Test5()
   Local x
   Local cmt, CmtState := 0
   Local msg

   Hb_RarSetCmtBufSize( 1024 )

   x := Getfile ( { {'Rar Files','*.rar'} } , 'Open archive' , GetCurrentFolder() , .f. , .t. )
   IF ( ! Empty( x ) )

      cmt := Hb_RarGetComment( x, @CmtState )

      SWITCH CmtState
   CASE 1
      msg := cmt
      EXIT
   CASE 0
      msg := "Absent comments"
      EXIT
   CASE ERAR_NO_MEMORY
      msg := "Not enough memory to extract comments"
      EXIT
   CASE ERAR_BAD_DATA
      msg :=  "Broken comment"
      EXIT
   CASE ERAR_UNKNOWN_FORMAT
      msg :=  "Unknown comment format"
      EXIT
   CASE ERAR_SMALL_BUF
      msg := "Buffer too small, comments not completely read"
      EXIT
      END SWITCH
      MsgInfo( msg, iif( CmtState == 1, "Archive comments", "Error" ) )
   ENDIF

   Return

/*
   Get Unrar.dll API version
   -------------------------
   Hb_RarGetDllVersion( ) ---> nAPIVersion

   Returns an integer value denoting UnRAR.dll API version,
   which is also defined in unrar.h as RAR_DLL_VERSION.
   API version number is incremented only in case of
   noticeable changes in UnRAR.dll API.
   Do not confuse it with version of UnRAR.dll stored in DLL resources,
   which is incremented with every DLL rebuild.

   If Hb_RarGetDllVersion() returns a value lower than UnRAR.dll
   which your application was designed for, it may indicate
   that DLL version is too old and it will fail to provide
   all necessary functions to your application.

    Hb_RarGetDllVersion( ) returns 0 for old versions of UnRAR.dll.
*/
Procedure Test6()
   Local n := Hb_RarGetDllVersion( )

   IF n > 0
      msginfo ( "UnRar.DLL API Version is " + Ltrim( Str( Hb_RarGetDllVersion( ), 3 ) ) )
   ELSEIF n == 0	
      msginfo ( "Warning: your UnRar.DLL version is too old !!" )
   END

Return

/*
*/
Function lAnd( n1, n2 )
Return ( AND( n1, n2 ) <> 0 )

/*
   Hb_RarGetErrorInfo() ---> aUnRarErrorInfo

   Warning:
   Hb_RarGetProcStatus after a call HbRarGetErrorInfo()
   always returns RAR_ST_SUCCESS ;(
*/
Procedure UnRarErrorInfo( ArchiveName, ErrorStatus )
   Local msg := ""
   Local aUnRarErrorInfo := Hb_RarGetErrorInfo()

   msg += ( ArchiveName + CRLF )
   IF ErrorStatus == RAR_ST_OPEN
      msg += ( "Error Code   " + cTab + " : " + str( aUnRarErrorInfo[ 1 ] ) + CRLF )
      msg += ( "Error Message" + cTab + " : " + aUnRarErrorInfo[ 2 ]        + CRLF )
   ELSEIF ErrorStatus == RAR_ST_OUT	
      msg += ( "Bad   File   " + cTab + " : " + aUnRarErrorInfo[ 5 ]        + CRLF )
      msg += ( "Error Code   " + cTab + " : " + str( aUnRarErrorInfo[ 3 ] ) + CRLF )
      msg += ( "Error Message" + cTab + " : " + aUnRarErrorInfo[ 4 ]        + CRLF )
   ELSEIF ErrorStatus == RAR_ST_OPEN_OUT	
      msg += ( "Error Code   " + cTab + " : " + str( aUnRarErrorInfo[ 1 ] ) + CRLF )
      msg += ( "Error Message" + cTab + " : " + aUnRarErrorInfo[ 2 ]        + CRLF )
      msg += CRLF
      msg += ( "Bad   File   " + cTab + " : " + aUnRarErrorInfo[ 5 ]        + CRLF )
      msg += ( "Error Code   " + cTab + " : " + str( aUnRarErrorInfo[ 3 ] ) + CRLF )
      msg += ( "Error Message" + cTab + " : " + aUnRarErrorInfo[ 4 ]        + CRLF )
   ELSE
      msg += ( "File header broken!" + CRLF )
   ENDIF

   MsgStop( msg, "Error" )

Return

/*
*/
Function HB_RarCallBackFunc( p1, p2, p3, p4 )
LOCAL result := 0

   IF p1 == UCM_CHANGEVOLUME 

      IF p4 == RAR_VOL_NOTIFY 
          Win_1.StatusBar.Item(1) := Hb_OemToAnsi( p3 ) 
          result := 0

      ELSEIF p4 == RAR_VOL_ASK
         result := InputBox( "Volume", "Can't open", p3 )
         IF result == ""
            result := -1
         ENDIF
      ENDIF

   ELSEIF p1 == UCM_NEEDPASSWORD
         result := InputBox( "", "Password" )

   ENDIF

Return result
