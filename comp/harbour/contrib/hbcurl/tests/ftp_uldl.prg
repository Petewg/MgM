/* Copyright 2008-2017 Viktor Szakats (vszakats.net/harbour) */

/* NOTE: Redirect STDERR to a file to see the verbose output. */

#require "hbcurl"

#define UPLOAD_FILE_AS  "test_ul.bin"
#define RENAME_FILE_TO  "test_ul_renamed.bin"
#define REMOTE_URL      "ftp://username:password@localhost/" + UPLOAD_FILE_AS
#define REMOTE_URL_DEL  "ftp://username:password@localhost/" + RENAME_FILE_TO
#define REMOTE_URL_MEM  "ftp://username:password@localhost/from_mem.txt"

#include "fileio.ch"

PROCEDURE Main( cDL, cUL )

   LOCAL lSystemCA, cCA := hb_PathJoin( iif( hb_DirBase() == "", hb_cwd(), hb_DirBase() ), "cacert.pem" )

   LOCAL curl
   LOCAL info
   LOCAL tmp
   LOCAL tmp1

   LOCAL tDate
   LOCAL cFileName

   LOCAL lVerbose := .F.

   Set( _SET_DATEFORMAT, "yyyy-mm-dd" )

   ? curl_version()
   ? curl_getdate( "Sun, 1 Jun 2008 02:10:58 +0200" )

   FOR EACH tmp IN curl_version_info()
      ? tmp:__enumIndex(), ""
      SWITCH tmp:__enumIndex()
      CASE HB_CURLVERINFO_PROTOCOLS
         FOR EACH tmp1 IN tmp
            ?? tmp1, ""
         NEXT
         EXIT
      CASE HB_CURLVERINFO_VERSION_NUM
         ?? "0x" + hb_NumToHex( tmp )
         EXIT
      CASE HB_CURLVERINFO_FEATURES
         ?? "0x" + hb_NumToHex( tmp ), "multi:", hb_bitAnd( tmp, HB_CURL_VERSION_MULTI_SSL ) != 0
         EXIT
      OTHERWISE
         ?? tmp
      ENDSWITCH
   NEXT

   ? "curl_global_sslset():", curl_global_sslset( -1,, @tmp )
   ? "Available SSL backends:", hb_ValToExp( tmp )

   WAIT

   #if defined( __PLATFORM__UNIX )
      lSystemCA := .T.
   #elif defined( __PLATFORM__WINDOWS )
      /* Switch to SChannel SSL backend, if available (on Windows).
         Doing this to use the OS certificate store. */
      curl_global_sslset( -1,, @tmp )
      IF ( lSystemCA := ;
         HB_CURLSSLBACKEND_SCHANNEL $ tmp .AND. ;
         curl_global_sslset( HB_CURLSSLBACKEND_SCHANNEL ) == HB_CURLSSLSET_OK )
         cCA := NIL
      ELSE
         cCA := hb_DirBase() + hb_DirSepToOS( "../../../bin/" ) + cCA
      ENDIF
   #else
      lSystemCA := .F.
   #endif

   ? "curl_global_init():", curl_global_init()

   IF ! Empty( curl := curl_easy_init() )

      ? "curl_easy_escape():", tmp := curl_easy_escape( curl, "https://example.org/my dir with space&more/" )
      ? "curl_easy_unescape():", curl_easy_unescape( curl, tmp )

      WAIT

      hb_default( @cUL, __FILE__ )

      ? curl_easy_setopt( curl, HB_CURLOPT_UPLOAD )
      ? curl_easy_setopt( curl, HB_CURLOPT_URL, REMOTE_URL )
      ? curl_easy_setopt( curl, HB_CURLOPT_UL_FILE_SETUP, cUL )
      ? curl_easy_setopt( curl, HB_CURLOPT_INFILESIZE, hb_vfSize( cUL ) ), hb_vfSize( cUL )
#if 0
      /* May use this instead of embedding in URL */
      ? curl_easy_setopt( curl, HB_CURLOPT_USERPWD, "username:password" )
#endif
      ? curl_easy_setopt( curl, HB_CURLOPT_XFERINFOBLOCK, {| nPos, nLen | hb_DispOutAt( 10, 10, Str( ( nPos / nLen ) * 100, 6, 2 ) + "%" ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_NOPROGRESS, 0 )
      ? curl_easy_setopt( curl, HB_CURLOPT_POSTQUOTE, { "RNFR " + UPLOAD_FILE_AS, "RNTO " + RENAME_FILE_TO } )
      ? curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, lVerbose )
      ? curl_easy_setopt( curl, HB_CURLOPT_DEBUGBLOCK, {| ... | QOut( "DEBUG:", ... ) } )

      ? "Upload file:", curl_easy_perform( curl )

      ? curl_easy_getinfo( curl, HB_CURLINFO_EFFECTIVE_URL )
      ? curl_easy_getinfo( curl, HB_CURLINFO_TOTAL_TIME )

      info := curl_easy_getinfo( curl, HB_CURLINFO_SSL_ENGINES, @tmp )
      ? "SSL engines:", tmp, Len( info )
      FOR EACH tmp IN info
         ?? tmp, ""
      NEXT

      curl_easy_reset( curl )

      WAIT

      /* Delete file */

      ? curl_easy_setopt( curl, HB_CURLOPT_UPLOAD )
      ? curl_easy_setopt( curl, HB_CURLOPT_UL_NULL_SETUP )
      ? curl_easy_setopt( curl, HB_CURLOPT_URL, REMOTE_URL_DEL )
#if 0
      /* May use this instead of embedding in URL */
      ? curl_easy_setopt( curl, HB_CURLOPT_USERPWD, "username:password" )
#endif
      ? curl_easy_setopt( curl, HB_CURLOPT_NOPROGRESS )
      ? curl_easy_setopt( curl, HB_CURLOPT_POSTQUOTE, { "DELE " + RENAME_FILE_TO } )
      ? curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, lVerbose )
      ? curl_easy_setopt( curl, HB_CURLOPT_DEBUGBLOCK, {| ... | QOut( "DEBUG:", ... ) } )

      ? "Delete file:", curl_easy_perform( curl )

      curl_easy_reset( curl )

      WAIT

      /* Upload file from memory */

      tmp := "This will be the content of the file"

      ? curl_easy_setopt( curl, HB_CURLOPT_UPLOAD )
      ? curl_easy_setopt( curl, HB_CURLOPT_URL, REMOTE_URL_MEM )
      ? curl_easy_setopt( curl, HB_CURLOPT_UL_BUFF_SETUP, tmp )
      ? curl_easy_setopt( curl, HB_CURLOPT_INFILESIZE, hb_BLen( tmp ) ), hb_BLen( tmp )
#if 0
      /* May use this instead of embedding in URL */
      ? curl_easy_setopt( curl, HB_CURLOPT_USERPWD, "username:password" )
#endif
      ? curl_easy_setopt( curl, HB_CURLOPT_XFERINFOBLOCK, {| nPos, nLen | hb_DispOutAt( 10, 10, Str( ( nPos / nLen ) * 100, 6, 2 ) + "%" ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_NOPROGRESS, 0 )
      ? curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, lVerbose )
      ? curl_easy_setopt( curl, HB_CURLOPT_DEBUGBLOCK, {| ... | QOut( "DEBUG:", ... ) } )

      ? "Upload file (from memory):", curl_easy_perform( curl )

      ? curl_easy_getinfo( curl, HB_CURLINFO_EFFECTIVE_URL )
      ? curl_easy_getinfo( curl, HB_CURLINFO_TOTAL_TIME )

      curl_easy_reset( curl )

      WAIT

      IF ! lSystemCA
         IF hb_vfExists( cCA )
            curl_easy_setopt( curl, HB_CURLOPT_CAINFO, cCA )
         ELSE
            ?
            ? "Error: Trusted Root Certificates missing. Open this URL in your web browser:"
            ? "  " + "https://curl.haxx.se/ca/cacert.pem"
            ? "and save the file as:"
            ? "  " + cCA
            RETURN
         ENDIF
      ENDIF

      hb_default( @cDL, "https://www.example.org/index.html" )

      /* Now let's download to a file */

      ? curl_easy_setopt( curl, HB_CURLOPT_DOWNLOAD )
      ? curl_easy_setopt( curl, HB_CURLOPT_URL, cDL )
      ? curl_easy_setopt( curl, HB_CURLOPT_DL_FILE_SETUP, cFileName := "test_dl.bin" )
      ? curl_easy_setopt( curl, HB_CURLOPT_FAILONERROR, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_FILETIME, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_XFERINFOBLOCK, {| nPos, nLen | hb_DispOutAt( 11, 10, Str( ( nPos / nLen ) * 100, 6, 2 ) + "%" ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_NOPROGRESS, 0 )
      ? curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, lVerbose )
      ? curl_easy_setopt( curl, HB_CURLOPT_DEBUGBLOCK, {| ... | QOut( "DEBUG:", ... ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_CAINFO, cCA )
      ? curl_easy_setopt( curl, HB_CURLOPT_CERTINFO, .T. )

      ? "Download file (to filename):", curl_easy_perform( curl )
      ? "Server timestamp:", tDate := UnixTimeToT( curl_easy_getinfo( curl, HB_CURLINFO_FILETIME ) )
      ? "CERTINFO:", hb_jsonEncode( curl_easy_getinfo( curl, HB_CURLINFO_CERTINFO ), .T. )

      curl_easy_reset( curl )

      hb_vfTimeSet( cFileName, tDate )

      WAIT

      /* Now let's download to a VF file handle */

      ? curl_easy_setopt( curl, HB_CURLOPT_DOWNLOAD )
      ? curl_easy_setopt( curl, HB_CURLOPT_URL, cDL )
      ? curl_easy_setopt( curl, HB_CURLOPT_DL_FILE_SETUP, tmp1 := hb_vfOpen( cFileName := "test_dlh.bin", FO_CREAT + FO_TRUNC + FO_WRITE ) )
      ? curl_easy_setopt( curl, HB_CURLOPT_FAILONERROR, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_FILETIME, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_XFERINFOBLOCK, {| nPos, nLen | hb_DispOutAt( 11, 10, Str( ( nPos / nLen ) * 100, 6, 2 ) + "%" ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_NOPROGRESS, 0 )
      ? curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, lVerbose )
      ? curl_easy_setopt( curl, HB_CURLOPT_DEBUGBLOCK, {| ... | QOut( "DEBUG:", ... ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_CAINFO, cCA )

      ? "Download file (to VF file handle):", curl_easy_perform( curl )
      ? "Server timestamp:", tDate := UnixTimeToT( curl_easy_getinfo( curl, HB_CURLINFO_FILETIME ) )

      curl_easy_reset( curl )

      ? hb_vfClose( tmp1 )

      hb_vfTimeSet( cFileName, tDate )

      WAIT

      /* Now let's download to an OS file handle */

      ? curl_easy_setopt( curl, HB_CURLOPT_DOWNLOAD )
      ? curl_easy_setopt( curl, HB_CURLOPT_URL, cDL )
      ? curl_easy_setopt( curl, HB_CURLOPT_DL_FILE_SETUP, tmp1 := FCreate( cFileName := "test_dlo.bin" ) )
      ? curl_easy_setopt( curl, HB_CURLOPT_FAILONERROR, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_FILETIME, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_XFERINFOBLOCK, {| nPos, nLen | hb_DispOutAt( 11, 10, Str( ( nPos / nLen ) * 100, 6, 2 ) + "%" ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_NOPROGRESS, 0 )
      ? curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, lVerbose )
      ? curl_easy_setopt( curl, HB_CURLOPT_DEBUGBLOCK, {| ... | QOut( "DEBUG:", ... ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_CAINFO, cCA )

      ? "Download file (to OS file handle):", curl_easy_perform( curl )
      ? "Server timestamp:", tDate := UnixTimeToT( curl_easy_getinfo( curl, HB_CURLINFO_FILETIME ) )

      curl_easy_reset( curl )

      ? FClose( tmp1 )

      hb_vfTimeSet( cFileName, tDate )

      WAIT

      /* Now let's download to memory */

      ? curl_easy_setopt( curl, HB_CURLOPT_DOWNLOAD )
      ? curl_easy_setopt( curl, HB_CURLOPT_URL, cDL )
      ? curl_easy_setopt( curl, HB_CURLOPT_DL_BUFF_SETUP )
      ? curl_easy_setopt( curl, HB_CURLOPT_FAILONERROR, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_FILETIME, .T. )
      ? curl_easy_setopt( curl, HB_CURLOPT_XFERINFOBLOCK, {| nPos, nLen | hb_DispOutAt( 11, 10, Str( ( nPos / nLen ) * 100, 6, 2 ) + "%" ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_NOPROGRESS, 0 )
      ? curl_easy_setopt( curl, HB_CURLOPT_VERBOSE, lVerbose )
      ? curl_easy_setopt( curl, HB_CURLOPT_DEBUGBLOCK, {| ... | QOut( "DEBUG:", ... ) } )
      ? curl_easy_setopt( curl, HB_CURLOPT_CAINFO, cCA )

      ? "Download file (to memory):", curl_easy_perform( curl )
      ? "Server timestamp:", tDate := UnixTimeToT( curl_easy_getinfo( curl, HB_CURLINFO_FILETIME ) )

      ? "Writing to file:", cFileName := "test_dlm.bin"

      hb_MemoWrit( cFileName, curl_easy_dl_buff_get( curl ) )
      hb_vfTimeSet( cFileName, tDate )

      curl_easy_reset( curl )

      WAIT

      /* Cleanup session */

      curl_easy_cleanup( curl )
   ENDIF

   curl_global_cleanup()

   RETURN

STATIC FUNCTION UnixTimeToT( nUnixTime )
   RETURN hb_SToT( "19700101000000" ) + nUnixTime / 86400
