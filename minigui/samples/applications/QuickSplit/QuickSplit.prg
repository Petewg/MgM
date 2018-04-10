/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2006 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#include "minigui.ch"
#include "fileio.ch"

#define PROGRAM 'QuickSplit'
#define VERSION " v.1.1"
#define COPYRIGHT ' 2006, Grigory Filatov'

#define IDI_MAIN 1001
#define NTRIM( n ) LTrim( Str( n ) )
#define MsgInfo( c, t ) MsgInfo( c, t, IDI_MAIN, .f. )
#define MsgStop( c, t ) MsgStop( c, t, , .f. )

STATIC lexit := .F., nUnits := 0
MEMVAR cFileIni
/*
*/
PROCEDURE Main

   LOCAL nDestSize := 1.44, nSizeType := 3, lCreateBatFile := .T., ;
      cFile := "", cFolder := "", aEscBlock := {|| NIL }

   PUBLIC cFileIni := GetStartUpFolder() + "\" + PROGRAM + '.ini'

   IF File( cFileIni + '.ini' )
      BEGIN INI FILE cFileIni
        GET nDestSize SECTION "Settings" ENTRY "DestSize"
        GET nSizeType SECTION "Settings" ENTRY "SizeType"
        GET lCreateBatFile SECTION "Settings" ENTRY "CreateBatFile"
      END INI
   ELSE
      BEGIN INI FILE cFileIni
        SET SECTION "Settings" ENTRY "DestSize" TO nDestSize
        SET SECTION "Settings" ENTRY "SizeType" TO nSizeType
        SET SECTION "Settings" ENTRY "CreateBatFile" TO lCreateBatFile
      END INI
   ENDIF

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 422 HEIGHT IF( IsXPThemeActive(), 148, 142 ) ;
      TITLE PROGRAM ;
      ICON IDI_MAIN ;
      MAIN ;
      NOMAXIMIZE NOSIZE ;
      FONT "MS Sans Serif" SIZE 8 ;
      ON RELEASE iif( Empty( cFile ), , SaveSettings() )

   @ 10, 2 LABEL Label_1 VALUE "Source file:" WIDTH 56 RIGHTALIGN
   @ 7, 62 BTNTEXTBOX Text_1 WIDTH 345 HEIGHT 22 ;
      VALUE '' ;
      ACTION {|| cFile := GetFile( NIL, NIL, ;
      iif( Empty( cFile ), GetMyDocumentsFolder(), cFilePath( cFile ) ), .F., .F. ), ;
      iif( Empty( cFile ), , ( Form_1 .Text_1. Value := cFile, ;
      Form_1.Text_2.Value := cFilePath( cFile ) + "\", lExistFile( cFile ), Form_1.Text_1. SetFocus ) ) } ;
      PICTURE "OPEN" ;
      BUTTONWIDTH 19

   @ 38, 2 LABEL Label_2 VALUE "Split to:" WIDTH 56 RIGHTALIGN
   @ 35, 62 BTNTEXTBOX Text_2 WIDTH 345 HEIGHT 22 ;
      VALUE '' ;
      ACTION {|| cFolder := GetFolder(), ;
      iif( Empty( cFolder ), , ( Form_1.Text_2.Value := cFolder, Form_1.Text_2. SetFocus ) ) } ;
      PICTURE "OPEN" ;
      BUTTONWIDTH 19

   @ 66, 2 LABEL Label_3 VALUE "Split size:" WIDTH 56 RIGHTALIGN
   @ 63, 62 GETBOX Text_3 WIDTH 44 HEIGHT 22 ;
      VALUE nDestSize ;
      PICTURE "9999.99" ;
      ON CHANGE iif( lExistFile( cFile ), nDestSize := Form_1.Text_3.Value, )

   @ 63, 108 COMBOBOX ComboBox_1 ;
      ITEMS { "Bytes", "KBytes", "MBytes" } ;
      VALUE nSizeType WIDTH 60 ;
      ON CHANGE iif( lExistFile( cFile ), nSizeType := Form_1.ComboBox_1.Value, ) ;
      ON LISTDISPLAY ( aEscBlock := EscapeOff() ) ;
      ON LISTCLOSE ( EscapeOn( aEscBlock ) )

   @ 64, 175 CHECKBOX CheckBox_1 CAPTION 'Create BAT file' VALUE lCreateBatFile ;
      WIDTH 90 HEIGHT 22

   @ 62, 305 BUTTON Button_1 ;
      CAPTION '? ' ;
      ACTION MsgAbout() ;
      WIDTH 26 HEIGHT 24

   @ 62, 348 BUTTON Button_2 ;
      CAPTION '&Split' ;
      ACTION {|| Form_1.Button_2.Visible := .F., Form_1.Button_3.Visible := .T., Form_1.Button_3.SetFocus, ;
      SplitFile( Form_1.Text_1.Value, Form_1.Text_2.Value, Form_1.Text_3.Value, ;
      Form_1.ComboBox_1.Value, Form_1.CheckBox_1.Value ), lexit := .F., Form_1.ProgressBar_1.Value := 0, ;
      Form_1.Button_3.Visible := .F., Form_1.Button_2.Visible := .T., Form_1.Button_2.SetFocus } ;
      WIDTH 59 HEIGHT 24

   @ 62, 348 BUTTON Button_3 ;
      CAPTION '&Cancel' ;
      ACTION lexit := .T. ;
      WIDTH 59 HEIGHT 24

   DRAW BOX IN WINDOW Form_1 AT 91, 6 TO 109, 299

   @ 93, 7 LABEL Label_4 VALUE "None" WIDTH 290 HEIGHT 15

   @ 91, 305 PROGRESSBAR ProgressBar_1 RANGE 0, 100 ;
      WIDTH 102 HEIGHT 19 SMOOTH

   ON KEY ESCAPE ACTION ( cFile := "", ThisWindow.Release )

   END WINDOW

   Form_1.Button_3.Visible := .F.

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN
/*
*/
STATIC FUNCTION lExistFile( cSource )

   LOCAL hsource                 // file handle for source file
   LOCAL nfilesize               // file size to be split
   LOCAL nbyte                   // size of each split file
   LOCAL nkoef
   LOCAL nSizeType := Form_1.ComboBox_1.Value, nDestSize := Form_1.Text_3.Value

   IF Empty( cSource ) .OR. !File( cSource )
      Form_1.Label_4.Value := "File doesn't exist!"
      RETURN .F.
   ENDIF

   nkoef := iif( nSizeType == 1, 1, iif( nSizeType == 2, 1024, 1024 * 1024 ) )
   nDestSize := iif( nSizeType == 1, Int( nDestSize ), nDestSize )
   // size of each split file
   nbyte := nDestSize * nkoef

   // open the source file
   IF ( hsource := FOpen( csource, FO_READ + FO_SHARED ) ) <> -1
      // is file size smaller than chunk size ?
      IF ( nfilesize := FSeek( hsource, 0, FS_END ) ) <= nbyte
         Form_1.Label_4.Value := "File size is smaller than unit size!"
      ELSE
         nUnits := Round( nfilesize / nbyte + .5, 0 )
         Form_1.Label_4.Value := Form_1.Label_1.Value + " " + NTRIM( Round( nfilesize / nkoef, 1 ) ) + " " + ;
            Form_1.ComboBox_1.Item( nSizeType ) + ", Split: " + NTRIM( nUnits ) + " files"
      ENDIF
      FClose( hsource )
   ELSE
      RETURN .F.
   ENDIF

RETURN .T.
/*
*/
FUNCTION SplitFile( cSource, cTarget, nDestSize, nSizeType, lCreateBatFile )

   LOCAL i                           // general counter
   LOCAL ccommand      := ""         // dos command for joining files
   LOCAL nbufsize      := 16         // 16k for buffer Read/Write
   LOCAL hsource                     // file handle for source file
   LOCAL hdestination                // file handle for destination file
   LOCAL cbuffer       := ""         // buffer for read/write
   LOCAL nblock                      // bytes read
   LOCAL ncurrent      := 0          // total bytes copied
   LOCAL nsplit        := 1          // destination file name extension
   LOCAL cbat                        // for joining split files
   LOCAL ctmp          := "@echo off" + CRLF // 1st line in .bat
   LOCAL cdestination                // destination filename
   LOCAL hbat                        // file handle for .bat
   LOCAL afile         := {}         // for information upon completion
   LOCAL nfilesize                   // file size to be split
   LOCAL hfile                       // split file sizes
   LOCAL lsplit        := .F.        // return value
   LOCAL csplit                      // destination name
   LOCAL nbyte                       // size of each split file
   LOCAL nkoef

   IF lExistFile( cSource )

      csplit := cFileNoExt( cSource ) + "."    // destination name
      cbat   := cTarget + csplit + "bat"       // batch name

      nkoef := if( nSizeType == 1, 1, if( nSizeType == 2, 1024, 1024 * 1024 ) )
      nDestSize := if( nSizeType == 1, Int( nDestSize ), nDestSize )
      // size of each split file
      nbyte := nDestSize * nkoef

      // open the source file
      IF ( hsource := FOpen( csource, FO_READ + FO_SHARED ) ) <> -1
         nfilesize := FSeek( hsource, 0, FS_END )
         FSeek( hsource, 0, FS_SET )                             // go to top of file
         cdestination := cTarget + csplit + NTRIM( nsplit )      // destination file name

         IF lCreateBatFile
            hbat         := FCreate( cbat )               // .bat
            ctmp         += "rem source file " + cFileName( cSource ) + " size " + NTRIM( nfilesize ) + CRLF
            ctmp         += "rem split on " + DToC( Date() ) + " " + Time() + CRLF
            ccommand     := "copy /b "                    // line in join.bat
            ccommand     += cFileName( cdestination ) + "+" // line in join.bat
         ENDIF

         hdestination := FCreate( cdestination )                 // create 1st split file
         IF nSizeType == 2
            nbufsize     := 1024                                 // buffer size
         ELSEIF nSizeType == 3
            nbufsize     *= 1024                                 // buffer size
         ENDIF
         cbuffer      := Space( nbufsize )                       // buffer read/write

         IF lCreateBatFile
            AAdd( afile, cbat )
            AAdd( afile, cdestination )
         ENDIF

         WHILE !lsplit .AND. !lexit
            lsplit := ( ( ( nblock := FRead( hsource, @cbuffer, nbufsize ) ) == 0 ) .OR. ;
               ( FWrite ( hdestination, cbuffer, nblock ) < nblock ) )
            ncurrent += nblock
            Form_1.ProgressBar_1.Value := nsplit * 100 / nUnits
            IF ncurrent >= nbyte                                     // files size already exceed ?
               FClose( hdestination )                                // close file
               ncurrent      := 0                                    // reset counter
               cdestination  := cTarget + csplit + NTRIM( ++nsplit ) // next file name
               IF lCreateBatFile
                  ccommand += cFileName( cdestination ) + "+"   // line in join.bat
               ENDIF
               hdestination  := FCreate( cdestination )              // create next file
               IF lCreateBatFile
                  AAdd( afile, cdestination )
               ENDIF
            ENDIF
            DO events
         ENDDO

         FClose( hsource )         // close source file
         FClose( hdestination )    // close split file

         Inkey( .2 )
         DO events

         IF lCreateBatFile
            ccommand := Left( ccommand, RAt( "+", ccommand ) -1 ) + " "  // line in .bat
            ccommand += cFileName( cSource ) + CRLF                      // line in .bat
            ctmp += "rem the following files should be placed in a directory" + CRLF
            FOR i := 2 TO Len( afile )
               hfile     := FOpen( afile[ i ], FO_READ + FO_SHARED )
               nfilesize := FSeek( hfile, 0, FS_END )
               FClose( hfile )
               ctmp += "rem " + cFileName( afile[ i ] ) + " - " + NTRIM( nfilesize ) + CRLF
            NEXT
            FOR i := 2 TO Len( afile )                                  // error checker
               ctmp += "if not exist " + cFileName( afile[ i ] ) + " goto error" + NTRIM( i -1 ) + CRLF
            NEXT
            ctmp += ccommand
            ctmp += "goto end" + CRLF
            FOR i := 2 TO Len( afile )
               ctmp += ":error" + NTRIM( i -1 ) + CRLF
               ctmp += "echo missing file " + cFileName( afile[ i ] ) + CRLF
               ctmp += "goto end" + CRLF
            NEXT
            ctmp += ":end" + CRLF
            FWrite( hbat, ctmp )                                        // write .bat
            FClose( hbat )                                              // close handle
         ENDIF
      ENDIF
   ENDIF

RETURN lsplit
/*
*/
STATIC FUNCTION MsgAbout()
RETURN MsgInfo( PadC( PROGRAM + VERSION, 42 ) + CRLF + ;
      "Copyright " + Chr( 169 ) + COPYRIGHT + CRLF + CRLF + ;
      hb_Compiler() + CRLF + Version() + CRLF + ;
      Left( MiniGuiVersion(), 38 ) + CRLF + CRLF + ;
      PadC( "This program is Freeware!", 40 ), "About" )
/*
*/
STATIC FUNCTION SaveSettings()

   LOCAL nDestSize := Form_1.Text_3.Value, nSizeType := Form_1.ComboBox_1.Value, ;
      lCreateBatFile := Form_1.CheckBox_1.Value

   BEGIN INI FILE cFileIni
     SET SECTION "Settings" ENTRY "DestSize" TO nDestSize
     SET SECTION "Settings" ENTRY "SizeType" TO nSizeType
     SET SECTION "Settings" ENTRY "CreateBatFile" TO lCreateBatFile
   END INI

RETURN NIL
/*
*/
STATIC FUNCTION EscapeOff

   LOCAL bKeyBlock, abRetVal := {}

   STORE KEY ESCAPE OF Form_1 TO bKeyBlock
   AAdd( abRetVal, bKeyBlock )
   RELEASE KEY ESCAPE OF Form_1

RETURN( abRetVal )
/*
*/
STATIC PROCEDURE EscapeOn( aKeyBlock )

   _DefineHotKey( "Form_1", 0, 27, aKeyBlock[ 1 ] )

RETURN
/*
*/
FUNCTION cFileName( cPathMask )

RETURN cFileNoPath( cPathMask )
/*
*/
FUNCTION cFilePath( cPathMask )

   LOCAL n := RAt( "\", cPathMask )

RETURN iif( n > 0, Left( cPathMask, n -1 ), Left( cPathMask, 2 ) )
