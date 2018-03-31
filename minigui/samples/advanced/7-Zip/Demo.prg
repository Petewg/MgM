/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Access to 7z archives by 7-zip32.dll
 * (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *
 * Last Revised by Grigory Filatov 03/10/2017
*/

// Complementary libraries:
// xhb.lib, hbdll32.lib

// Complementary header files

#include "CStruct.ch"                      // from Harbour\Contrib\xHB
#include "HBCTypes.ch"                     // from Harbour\Contrib\xHB
#include "WinTypes.ch"                     // from Harbour\Contrib\xHB

#include "MiniGUI.ch"


#define ALONE_7Z          '7za.exe'        // console variant of 7-Zip archiver


STATIC cPath7z := ''      // Full path to installed 7-Zip archiver


// C-structure, used in SevenZipFindFirst(), SevenZipFindNext()

pragma pack( 4 )

#define FNAME_MAX32       512

typedef struct { ;
      DWORD dwOriginalSize;
      DWORD dwCompressedSize;
      DWORD dwCRC;
      UINT uFlag;
      UINT uOSType;
      WORD wRatio;
      WORD wDate;
      WORD wTime;
      char szFileName[ FNAME_MAX32 + 1 ];
      char dummy1[ 3 ];
      char szAttribute[ 8 ];
      char szMode[ 8 ];
      } INDIVIDUALINFO, * PINDIVIDUALINFO;



/******
*
*       ������ � ������� 7z, zip � �������������� ������������
*       ���������� 7-zip32.dll (Japanese http://www.csdinc.co.jp/archiver/lib/
*       English http://www.csdinc.co.jp/archiver/lib/main-e.html)
*
*/

PROCEDURE Main
LOCAL oReg

// ��������� ������ ��� �������������� 7-Zip ����� ������ � �������

OPEN REGISTRY oReg KEY HKEY_CURRENT_USER Section 'Software\7-Zip'

   GET VALUE cPath7z NAME 'Path' OF oReg

CLOSE REGISTRY oReg

IF !Empty( cPath7z )
   cPath7z := hb_DirSepAdd( cPath7z )
   cPath7z += '7z.exe'
ELSE
   // ������ - ��� ��������������� ������ � �������
   MsgAlert( 'The 7-Zip archiver is not found.', 'Alert' )
ENDIF

IF ( !File( cPath7z  ) .AND. ;
         !File( ALONE_7Z )   ;
         )

// ���� ��� �������������� 7-Zip � ����������� �������� ����������,
// �� � ���������� �������� ���������.
// ���� ����� ���� �����: ������������� ����� 7-zip32.dll ��� 7-Zip
// ��������� ������������� �����, �� �� ��������� ��������� ���
// ��������� �� ���� �����.

   MsgStop( 'The required programs are not found.', 'Error' )
   QUIT

ENDIF

SET FONT TO 'Tahoma', 9

DEFINE WINDOW wMain                                         ;
      At 0, 0                                               ;
      Width 553 + iif( IsSeven(), GetBorderWidth() -2, 0 )  ;
      Height 432 + iif( IsSeven(), GetBorderHeight() -2, 0 );
      Title 'Demo 7-Zip interaction'                        ;
      Icon 'main.ico'                                       ;
      Main                                                  ;
      NoMaximize

   DEFINE TAB tbMain ;
      at 5, 5   ;
      Width 535 ;
      Height 370

   DEFINE PAGE 'Archive'

// ���������� ���������� ���������� ������.

   @ 30, 5 Grid grdContent            ;
      Width 520                  ;
      Height 285                 ;
      Headers { 'Name' }         ;
      Widths { 400 }             ;
      Multiselect

// �������� �������� ������, ���������� � ��������

   @ 330, 15 ButtonEx btnCreate  ;
      Caption 'Create'    ;
      Action RunTest( 1 ) ;
      Tooltip 'Create archive'

   @ 330, 220 ButtonEx btnView    ;
      Caption 'View'      ;
      Action RunTest( 2 ) ;
      Tooltip 'View 7z/zip archive'

   @ 330, 415 ButtonEx btnExtract ;
      Caption 'Extract'   ;
      Action RunTest( 3 ) ;
      Tooltip 'Extract file(s) from archive'

   END PAGE

// ��������� ��������� ���������

   DEFINE PAGE 'Options'

// ����� �������� ������������

   @ 30, 5 Frame frmSelectTest   ;
      Caption 'Select test' ;
      Width 520             ;
      Height 65             ;
      Bold                  ;
      FontColor BLUE

   @ 55, 15 RadioGroup rdgSelectTest                      ;
      Options { '7-zip32.dll', '7-Zip', '7za.exe' } ;
      Width 100                                     ;
      Spacing 20                                    ;
      ON Change wMain.btnExtract.Enabled := .F.     ;
      Horizontal

// ����� ���������

   @ 110, 5 Frame frmCommon  ;
      Caption 'Common' ;
      Width 520        ;
      Height 65        ;
      Bold             ;
      FontColor BLUE

// ����������� �������� ���������

   @ 135, 15 CheckBox cbxHide           ;
      Caption 'Hide progressbar' ;
      Width 124                  ;
      Value .T.

// ��������� ����������

   @ 185, 5 Frame frmExtract  ;
      Caption 'Extract' ;
      Width 520         ;
      Height 65         ;
      Bold              ;
      FontColor BLUE

// ��������� ��������� ��������� ��� ����������

   @ 210, 15 CheckBox cbxExtract                     ;
      Caption 'Extract files with full paths' ;
      Width 176                               ;
      Value .T.

// �������� Yes �� ��� ������� � �������� ���������

   @ 210, 200 CheckBox cbxYesAll                    ;
      Caption 'Assume (Yes) on all queries' ;
      Width 190

// �������� ������

   @ 260, 5 Frame frmLinks  ;
      Caption 'Links' ;
      Width 520       ;
      Height 100      ;
      Bold            ;
      FontColor BLUE
   @ 285, 15 LABEL lbl7z   ;
      Value '7-Zip' ;
      Width 120     ;
      Height 15
   @ 285, 140 Hyperlink hl7z                 ;
      Value 'http://www.7-zip.org'   ;
      Address 'http://www.7-zip.org' ;
      HandCursor
   @ 305, 15 LABEL lblDLL_JA                ;
      Value '7-Zip32.dll (Japanese)' ;
      Width 120                      ;
      Height 15
   @ 305, 140 Hyperlink hlDLL_JA                              ;
      Value 'http://www.csdinc.co.jp/archiver/lib/'   ;
      Address 'http://www.csdinc.co.jp/archiver/lib/' ;
      Width 270 HandCursor
   @ 325, 15 LABEL lblDLL_EN               ;
      Value '7-Zip32.dll (English)' ;
      Width 120                     ;
      Height 15
   @ 325, 140 Hyperlink hlDLL_EN                                         ;
      Value 'http://www.csdinc.co.jp/archiver/lib/main-e.html'   ;
      Address 'http://www.csdinc.co.jp/archiver/lib/main-e.html' ;
      Width 270 HandCursor

   END PAGE

   END TAB

   DEFINE STATUSBAR
      StatusItem ''
      StatusItem '' Width 120
      StatusItem '' Width 40
      StatusItem '' Width 130
   END STATUSBAR

END WINDOW

// ������������� ������ � ��������� �����

IF !File( cPath7z )

// �������� ������ ������ ���������� ������ ����������

   wMain.rdgSelectTest.Enabled( 1 ) := .F.
   wMain.rdgSelectTest.Enabled( 2 ) := .F.
   wMain.rdgSelectTest.Value := 3

   IF !File( ALONE_7Z )

// ��� ������ ������. ��������� ��

      wMain.rdgSelectTest.Enabled := .F.
      wMain.rdgSelectTest.Value   := 0

   ENDIF

ELSE

// ��� ���������� ������������ ���������� � ���������� ������
// ���������� ���������� ����� ������ �������� ������������ ������ 7-Zip

   wMain.rdgSelectTest.Value := 2

   IF !File( '7-zip32.dll' )
      wMain.rdgSelectTest.Enabled( 1 ) := .F.
   ELSE
      wMain.rdgSelectTest.Value := 1
   ENDIF

   IF !File( ALONE_7Z )
      wMain.rdgSelectTest.Enabled( 3 ) := .F.
   ENDIF

ENDIF

wMain.btnExtract.Enabled := .F.

CENTER WINDOW wMain
ACTIVATE WINDOW wMain

RETURN

***** End of Main ******


/******
*
*       RunTest( nChoice )
*
*       ������ ���������. ��� ����� ���������� ���������
*       ��������������� ���������� rdgSelectTest
*/

STATIC PROCEDURE RunTest( nChoice )

   LOCAL nSelected := wMain.rdgSelectTest.Value

   DO CASE
   CASE ( nChoice == 1 )        // �������� ������

      IF ( nSelected == 1 )
         // ���������� 7-zip32.dll
         CreateArc()
      ELSE
         // ��������� 7z.exe ��� 7za.exe
         CreateArcExternal()
      ENDIF

   CASE ( nChoice == 2 )        // �������� �����������

      IF ( nSelected == 1 )
         ViewArc()
      ELSE
         ViewArcExternal()
      ENDIF

   CASE ( nChoice == 3 )        // ���������� ������

      IF ( nSelected == 1 )
         ExtractArc()
      ELSE
         ExtractArcExternal()
      ENDIF

   ENDCASE

RETURN

***** End of RunTest ******


/******
*
*       ShowStatus( cFile, cCount, cType, cVersion )
*
*       ����������� ��������� ������ ���������
*
*/

STATIC PROCEDURE ShowStatus( cFile, cCount, cType, cVersion )

   wMain.StatusBar.Item( 1 ) := cFile      // �������������� ����
   wMain.StatusBar.Item( 2 ) := cCount     // ������ � ������
   wMain.StatusBar.Item( 3 ) := cType      // ��� ������
   wMain.StatusBar.Item( 4 ) := cVersion   // ���������� � ���������

RETURN

***** End of ShowStatus ******


// --------------------------------------------------------------
// ���� �������� ��� 7-zip32.dll
// --------------------------------------------------------------

/******
*
*       Version7zip() --> cVersion
*
*       ������ ���������� 7-zip � 7-zip32.dll
*
*/

STATIC FUNCTION Version7zip

   LOCAL nVersion := SevenZipGetVersion(), ;    // 7-zip
      nSubversion := SevenZipGetSubVersion(), ; // 7-zip32.dll
      cVersion    := 'Version '

   cVersion += ( Str( ( nVersion / 100 ), 5, 2 ) + '.' + StrZero( ( nSubversion / 100 ), 5, 2 ) )

RETURN cVersion

***** End of Version7zip ******


/******
*
*       CreateArc()
*
*       �������� ������
*
*/

STATIC PROCEDURE CreateArc

   LOCAL aSource := GetFile( { { 'All files', '*.*' } }, ;
      'Select file(s)', ;
      GetCurrentFolder(), .T., .T.  ;
      ), ;
      cArcFile, ;
      cType     := '', ;
      cCommand  := 'A ', ;
      nDLLHandle

   IF !Empty( aSource )

      cArcFile := PutFile ( { { '7-zip', '*.7z' }, { 'Zip', '*.zip' } }, ;
         'Create archive', ;
         GetCurrentFolder(), ;
         .T.                                          ;
         )

      IF !Empty( cArcFile )

         // ���������� ��� ������. �� ��������� ������������ 7z, �������
         // ���������� ������ � ������ ��������� � ���������� ����.

         IF ( Upper( Right( cArcFile, 3 ) ) == 'ZIP' )
            cType := 'zip'
         ENDIF

         // ������ ������ ������� ��� �������� � DLL

         IF wMain.cbxHide.Value
            cCommand += '-hide '       // �� ���������� �������
         ENDIF

         IF !Empty( cType )
            cCommand += '-tzip '       // � ������� ZIP
         ENDIF

         cCommand += ( cArcFile + ' ' )

         // ��������� ����� ��� ���������

         AEval( aSource, {| elem | cCommand += ( '"' + elem + '" ' ) } )

         cCommand := RTrim( cCommand )

         IF !( ( nDLLHandle := LoadLibrary( '7-zip32.dll' ) ) > 0 )
            MsgStop( "Can't load 7-zip32.dll.", 'Error' )
         ELSE
            DllCall( nDLLHandle, DC_CALL_STD, 'SevenZip', _HMG_MainHandle, cCommand )
            FreeLibrary( nDLLHandle )

            // ��������� ������ ���������

            ShowStatus( cArcFile, '', iif( Empty( cType ), '7z', 'zip' ), Version7zip() )

         ENDIF

      ENDIF

   ENDIF

RETURN

***** End of CreateArc ******


/******
*
*       ViewArc()
*
*       ������� ����� � ��������� ������� ����������
*
*/

STATIC PROCEDURE ViewArc

   LOCAL cFile      := GetFile( { { '7-zip', '*.7z' }, { 'Zip', '*.zip' } }, ;
      'Select archive', ;
      GetCurrentFolder(), ;
      .F., .T.                                     ;
      ), ;
      nDLLHandle, ;
      nArcHandle, ;
      nResult, ;
      cValue, ;
      nCount    := 0, ;
      cType     := '', ;
      oInfo, ;
      pInfo, ;
      aFiles    := {}

   IF Empty( cFile )
      RETURN
   ENDIF

   IF !( ( nDLLHandle := LoadLibrary( '7-zip32.dll' ) ) > 0 )
      MsgStop( "Can't load 7-zip32.dll.", 'Error' )
      RETURN
   ENDIF

   nArcHandle := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipOpenArchive', _HMG_MainHandle, cFile, 0 )   // ������� �����

   IF Empty( nArcHandle )
      MsgStop( cFile + ' not opened.', 'Error' )
      RETURN
   ENDIF

   nCount  := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileCount', cFile )  // ���������� ��������� � ������
   nResult := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetArchiveType', cFile )  // ��� ������

   DO CASE
   CASE ( nResult == 1 )
      cType := 'ZIP'

   CASE ( nResult == 2 )
      cType := '7Z'

   CASE ( nResult == -1 )
      // ������ ���������
      cType := 'Error'

   CASE ( nResult == 0 )
      // �� �������������� ���. ���� ��� ������� ������� ���-������
      // ����� 7z � Zip ������� SevenZipOpenArchive() �����
      // ���������� ������.
      cType := '???'

   ENDCASE

   // ������������� ���������, ����������� ��� ��������� ��������� ������ �
   // ��������� (��� �������� � DLL)

   oInfo := ( STRUCT INDIVIDUALINFO )
   pInfo := oInfo : GetPointer()

   // ���� 1-� ����. ���� ��������� ������ �� ����� ��������, �������� pInfo
   // ����� ��������.

   DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipFindFirst', nArcHandle, '*', pInfo )

   // ����������������� ���������

   oInfo := oInfo : Pointer( pInfo )

   cValue := Space( FNAME_MAX32 )
   DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileName', nArcHandle, @cValue, FNAME_MAX32 )

   IF !Empty( cValue )

      // ��������� ������� �����. ������� �������� ������� � ������,
      // ��������� � ������� Grid

      AAdd( aFiles, { cValue } )

      DO WHILE ( ( nResult := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipFindNext', nArcHandle, pInfo ) ) == 0 )

         cValue := Space( FNAME_MAX32 )
         DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileName', nArcHandle, @cValue, FNAME_MAX32 )

         AAdd( aFiles, { cValue } )

      ENDDO

      wMain.grdContent.DeleteAllItems

      ASort( aFiles,,, {| x, y | x[ 1 ] < y[ 1 ] } )

      wMain.grdContent.DisableUpdate
      AEval( aFiles, {| elem | wMain.grdContent.AddItem( elem ) } )
      wMain.grdContent.EnableUpdate
      wMain.grdContent.Value := { 1 }

   ENDIF

   // ������� �������� ����, ��������� ����������

   DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipCloseArchive', nArcHandle )
   FreeLibrary( nDLLHandle )

   // ��������� ������ ���������

   ShowStatus( cFile, ( 'Count files: ' + LTrim( Str( nCount ) ) ), cType, Version7zip() )

   IF ( wMain.grdContent.ItemCount > 0 )
      wMain.btnExtract.Enabled := .T.
   ENDIF

RETURN

***** End of ViewArc ******


/******
*
*       ExtractArc()
*
*       ���������� ������ �� ������
*
*/

STATIC PROCEDURE ExtractArc

   LOCAL aPos := wMain.grdContent.Value, ;
      cDir, ;
      cCommand, ;
      nPos, ;
      cFile, ;
      nDLLHandle

   IF Empty( aPos )
      MsgStop( 'Select item(s), please!', 'Error' )
      RETURN
   ENDIF

   IF !Empty( cDir := GetFolder( 'Extract file(s) to' ) )

      // ��������� � ����������� �������� ��������� ��� ���

      cCommand := ( iif( wMain.cbxExtract.Value, 'x', 'e' ) + ' ' )

      IF wMain.cbxHide.Value

         // �� ���������� �������. �� ���� ����������� ����������
         // ������������ ������, �������������� ������ �� �����
         // ����� �������.

         cCommand += '-hide '

      ENDIF

      // �������������� ������������ ����� ��� ��������������

      IF wMain.cbxYesAll.Value
         cCommand += '-y '
      ENDIF

      cCommand += ( '-o' + cDir + ' ' )    // ���� �������

      // �� ������ �������� ��� ������, ����������� ����������� �����

      // cCommand += ( '"' + AllTrim( wMain.Statusbar.Item( 1 ) ) + '" ' )
      cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )

      // ��������� ����������� �����. ��� ��������� ���������:
      // ���� ���������� ���������� ��������� ����� ������
      // ����������, �� ��� ������ ��������� �������.

      IF ( Len( aPos ) == wMain.grdContent.ItemCount )
         cCommand += '*.*'
      ELSE

         FOR EACH nPos In aPos

            // �������, ���������� ������ ��� ��������, ����������

            cFile := AllTrim( wMain.grdContent.Item( nPos )[ 1 ] )

            IF !( Right( cFile, 1 ) == '\' )
               // cCommand += ( '"' + cFile + '" ' )
               cCommand += ( cFile + ' ' )
            ENDIF

         NEXT

         cCommand := RTrim( cCommand )

      ENDIF

      IF !( ( nDLLHandle := LoadLibrary( '7-zip32.dll' ) ) > 0 )
         MsgStop( "Can't load 7-zip32.dll.", 'Error' )
      ELSE
         DllCall( nDLLHandle, DC_CALL_STD, 'SevenZip', _HMG_MainHandle, cCommand )
         FreeLibrary( nDLLHandle )
         MsgInfo( "Extraction is successfully.", 'Result' )
      ENDIF

   ENDIF

RETURN

***** End of ExtractArc ******


// ��������� � 7-zip32.dll

// ������ � ��������� ����������

DECLARE DLL_TYPE_WORD SevenZipGetVersion() in 7-zip32.dll
DECLARE DLL_TYPE_WORD SevenZipGetSubVersion() in 7-zip32.dll


// --------------------------------------------------------------
// ���� �������� ��� 7-zip 7za.exe
// --------------------------------------------------------------

/******
*
*       CreateArcExternal()
*
*       �������� ������
*
*/

STATIC PROCEDURE CreateArcExternal

   LOCAL aSource := GetFile( { { 'All files', '*.*' } }, ;
      'Select file(s)', ;
      GetCurrentFolder(), .T., .T.  ;
      ), ;
      cArcFile, ;
      nPos, ;
      cExt, ;
      cType     := '', ;
      cCommand  := ' A '

   IF !Empty( aSource )

      // ��������� ��������������� � ������ 7-Zip ��������� ���������
      // ������� ���������� ����� �������

      cArcFile := PutFile ( { { '7-zip', '*.7z'    }, ;
         { 'Zip', '*.zip'   }, ;
         { 'GZip', '*.gzip'  }, ;
         { 'BZip2', '*.bzip2' }, ;
         { 'Tar', '*.tar'   }  ;
         }, ;
         'Create archive', ;
         GetCurrentFolder(), ;
         .T.                       ;
         )

      IF !Empty( cArcFile )

         // ���������� ��� ������. �� ��������� ������������ 7z, �������
         // ���������� ������ � ������ ��������� � ���������� ����.

         nPos := RAt( '.', cArcFile )
         cExt := Upper( Right( cArcFile, ( Len( cArcFile ) - nPos ) ) )

         IF !( cExt == '7Z' )
            cType := cExt
         ENDIF

         // ������ ������ �������

         IF !Empty( cType )
            cCommand += ( '-t' + cType + ' ' )
         ENDIF

         cCommand += ( cArcFile + ' ' )

         // ��������� ����� ��� ���������

         AEval( aSource, {| elem | cCommand += ( '"' + elem + '" ' ) } )

         // ��������� ��� ������������� ��������� ��� ����������
         // ������, ����������� � ����� � ���������������� ����������

         IF ( wMain.rdgSelectTest.Value == 2 )
            cCommand := ( cPath7z + cCommand )
         ELSE
            cCommand := ( ALONE_7Z + cCommand )
         ENDIF

         cCommand := RTrim( cCommand )

         // ��������� � ������ �������� ��������� ���������. ����
         // ��� ���� ���� ���� ���������� ������ (��� ��������, �.�. ����
         // ����������), ��� ����������� � ���, ��� ������ ����������� (����
         // ����� �������), ����� ������� �����-������ �������������� ����,
         // �������� � ��������.

         // ���� ��� �������: ��� 7-Zip ��������� �� %ProgramFiles%\7-Zip\7z.exe,
         // � %ProgramFiles%\7-Zip\7zG.exe - ����������� ��������� ����������.
         // ������� �� ������ ���������� ��������� �������� ���������.

         IF wMain.cbxHide.Value
            Execute File ( cCommand ) WAIT Hide
         ELSE
            Execute File ( cCommand ) Wait
         ENDIF

         // ��������� ������ ���������

         ShowStatus( cArcFile, '', iif( Empty( cType ), '7Z', cType ), ;
            iif( ( wMain.rdgSelectTest.Value == 2 ), '7-Zip', '7za' ) )

      ENDIF

   ENDIF

RETURN

***** End of CreateArcExternal ******


/******
*
*       ViewArcExternal()
*
*       ������� ����� � ��������� ������� ����������
*
*/

STATIC PROCEDURE ViewArcExternal
   // aFiles - ����� �������������� ����� �������. ������� ��������� ����� ���
   // ���������� ������ (7za.exe), �.�. � ����������� ��������.
   LOCAL aFilters := { { '7-zip', '*.7z'   }, ;
      { 'Zip', '*.zip'  }, ;
      { 'Cab', '*.cab'  }, ;
      { 'GZip', '*.gzip' }, ;
      { 'Tar', '*.tar'  } ;
      }, ;
      cFile, ;
      aFiles    := {}, ;
      cCommand, ;
      cTmpFile  := '_Arc_.lst', ;     // ��� GetTempFolder() + '\_Arc_.lst'
      oFile, ;
      cString

   // ������� ���� �������, � �������� ����� �������� ������ ������ (�� ���,
   // ��������� � ������������, �������)

   IF ( wMain.rdgSelectTest.Value == 2 )
      AAdd( aFilters, { 'Rar', '*.rar' } )
      AAdd( aFilters, { 'Arj', '*.arj' } )
      AAdd( aFilters, { 'Chm', '*.chm' } )
      AAdd( aFilters, { 'Lzh', '*.lzh' } )
   ENDIF

   IF Empty( cFile := GetFile( aFilters, 'Select archive', GetCurrentFolder(), .F., .T. ) )
      RETURN
   ENDIF

   // ���������� ������ ������� �� ��������� ���� � ����� ��������� ��� ������ �
   // ���������.

   // �����, �������, ������ GetEnv( 'COMSPEC' ) ���������� ������ cmd.exe, ��
   // ��� ���������� ���������� ����� ���������� � ������ ������� Windows

   cCommand := GetEnv( 'COMSPEC' ) + ' /C '

   IF ( wMain.rdgSelectTest.Value == 2 )
      // ������� �� ��������, �.�. Program Files ����� ������ � �����.
      // ����� ����� ������������ ������ %ProgramFiles%\7-Zip\7z.exe, �.�.
      // ����������� ������� 7zG.exe �� ������������ ��������������� ������ � ����
      cCommand := ( cCommand + '"' + cPath7z + '"' )
   ELSE
      cCommand := ( cCommand + ALONE_7Z )
   ENDIF

   // � ���������� ����� �������� �� � ���������, � � ����������� ������ (�������������
   // -slt). ����� ������ ���� ���� ����� ����������� � ��������� ������� �������� ���
   // (���������� � ������������ �� ���� ������):
   // Path = ��� ���� ������
   // Size =
   // Packed Size =
   // Modified =
   // Attributes =
   // CRC =
   // Method =
   // Block =
   // � ��� �������� ������ ����� ���������� � ������ ������������ Path =

   // ��������� ���� ���������� �����, ������� �� ��������� �
   // ��������� ����� ��������� ������ ( GetTempFolder() + '\' + cTmpFile )

   cCommand += ( ' L -slt ' + cFile + ' > ' + cTmpFile )

   Execute File ( cCommand ) WAIT Hide

   // ����� ���������� �������� ���� �� ������������� ����� ���������� ���������
   // �������� WinAPI (������������ CreatePipe � �������� � ��� ��� � �������
   // ������), � �� ��������� ��������� ����, �� � �� ����� ������ ������.

   IF File( cTmpFile )

      // ��������� ���� ����� � �� ���������, ��������, ���������� ������
      // � ������ �������. ������������� �� ������ �� ��������� � ��� ������.
      // ���� ������� - �� � �� ��� ������.

      // ��������� ������

      oFile := TFileRead() : New( cTmpFile )
      oFile : Open()

      IF !oFile : Error()

         DO WHILE oFile : MoreToRead()

            IF !Empty( cString := oFile : ReadLine() )

               // ��������� ��������� ���������. ������ ���������, �� ����������
               // �� ������ � "Path =" �, ���� �� - �� ��� ��� �����. ���
               // �������������, ����� ������� ���������. ��������, ������������
               // ����� ��������� (������ "Attributes = D...." ��� ������ .7z)

               IF ( Left( cString, 7 ) == 'Path = ' )
                  cString := AllTrim( SubStr( cString, 8 ) )
                  AAdd( aFiles, { cString } )
               ENDIF

            ENDIF

         ENDDO

         oFile : Close()

         IF !Empty( aFiles )

            wMain.grdContent.DeleteAllItems

            ASort( aFiles,,, {| x, y | x[ 1 ] < y[ 1 ] } )

            wMain.grdContent.DisableUpdate
            AEval( aFiles, {| elem | wMain.grdContent.AddItem( elem ) } )
            wMain.grdContent.EnableUpdate
            wMain.grdContent.Value := { 1 }

            // ��������� ������ ��������� (� ��� ����� ��������� ��� ����������
            // ������, ����������� ��� ���������� ������)

            ShowStatus( cFile, ( 'Count files: ' + LTrim( Str( Len( aFiles ) ) ) ), ;
               Upper( Right( cFile, ( Len( cFile ) - RAt( '.', cFile ) ) ) ), ;
               iif( ( wMain.rdgSelectTest.Value == 2 ), '7-Zip', '7za' ) )

         ENDIF

      ENDIF

      IF ( wMain.grdContent.ItemCount > 0 )
         wMain.btnExtract.Enabled := .T.
      ENDIF

   ENDIF

   // ��������� ���� ������ ���� ���� � �.�. �����. ������� ��
   // �������� ������ � � ��� ������, ����� ��������� ���� �� ����������.

   FErase ( cTmpFile )

RETURN

***** End of ViewArcExternal ******


/******
*
*       ExtractArcExternal()
*
*       ���������� ������ �� ������
*
*/

STATIC PROCEDURE ExtractArcExternal

   LOCAL aPos := wMain.grdContent.Value, ;
      cDir, ;
      cCommand, ;
      nPos, ;
      cFile

   IF Empty( aPos )
      MsgStop( 'Select item(s), please!', 'Error' )
      RETURN
   ENDIF

   IF !Empty( cDir := GetFolder( 'Extract file(s) to' ) )

      // ��������� � ����������� ��������� ��������� ��� ���

      cCommand := ( iif( wMain.cbxExtract.Value, 'X', 'E' ) + ' ' )

      // �������������� ������������ ����� ��� ��������������

      IF wMain.cbxYesAll.Value
         cCommand += '-y '
      ENDIF

      cCommand += ( '-o' + cDir + ' ' )    // ���� �������

      cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )

      IF ( Len( aPos ) == wMain.grdContent.ItemCount )

         cCommand += '*.*'

      ELSE

         FOR EACH nPos In aPos

            // �������, ���������� ������ ��� ��������, ����������

            cFile := AllTrim( wMain.grdContent.Item( nPos )[ 1 ] )

            IF !( Right( cFile, 1 ) == '\' )
               cCommand += ( cFile + ' ' )
            ENDIF

         NEXT

         cCommand := RTrim( cCommand )

      ENDIF

      IF ( wMain.rdgSelectTest.Value == 2 )

         // ���� ������ 7z.exe ������������ 7zG.exe, �� ����� ������������
         // ��������� ������

         cCommand := ( cPath7z + ' ' + cCommand )
      ELSE
         cCommand := ( ALONE_7Z + ' ' + cCommand )
      ENDIF

      // ���������.

      IF wMain.cbxHide.Value .AND. !wMain.cbxYesAll.Value
         Execute File ( cCommand ) WAIT Hide
      ELSE
         Execute File ( cCommand ) Wait
      ENDIF

      MsgInfo( 'Extraction is successfully.', 'Result' )

   ENDIF

RETURN

***** End of ExtractArcExternal ******
