/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Access to 7z archives by 7-zip32.dll demo
 * (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

// Complementary libraries:
// xhb.lib, hbdll32.lib

// Complementary header files

#include "CStruct.ch"                      // from Harbour\Contrib\xHB 
#include "HBCTypes.ch"                     // from Harbour\Contrib\xHB
#include "WinTypes.ch"                     // from Harbour\Contrib\xHB

#include "hmg.ch"
#include "hbdll32.ch"


#define ALONE_7Z          '7za.exe'        // console variant of 7-Zip archiver


Static cPath7z := ''      // Full path to installed 7-Zip archiver


// C-structure, used in SevenZipFindFirst(), SevenZipFindNext()

pragma pack( 4 )

#define FNAME_MAX32       512

typedef struct { ;
  DWORD	dwOriginalSize;
  DWORD	dwCompressedSize;
  DWORD	dwCRC;
  UINT	uFlag;
  UINT	uOSType;
  WORD	wRatio;
  WORD	wDate;
  WORD	wTime;
  char	szFileName[FNAME_MAX32 + 1];
  char	dummy1[3];
  char	szAttribute[8];
  char	szMode[8];
} INDIVIDUALINFO, *PINDIVIDUALINFO;



/******
*
*       ������ � ������� 7z, zip � �������������� ������������
*       ���������� 7-zip32.dll (Japanese http://www.csdinc.co.jp/archiver/lib/
*       English http://www.csdinc.co.jp/archiver/lib/main-e.html)
*
* Access to archives 7z, zip using dynamic libraries 
* 7-zip32.dll (Japanese http://www.csdinc.co.jp/archiver/lib/ 
* English http://www.csdinc.co.jp/archiver/ lib / main-e.html)
*/

Procedure Main

// ��������� ������ ��� �������������� 7-Zip. ��� ���������, ��������
// ��� ��������� ����������� � ������� �� ���������

// Form the full name of the installed 7-Zip. For simplification, taking
// That the program is installed in the default directory

cPath7z := GetProgramFilesFolder() + '\7-zip\7z.exe'

// ����� ��������� ����� - ����� ������ � �������
// You can do otherwise - through a registry entry
/*
Open registry oReg key HKEY_LOCAL_MACHINE Section 'Software\7-Zip'
Get value cPath7z Name 'Path' of oReg 
Close registry oReg

If !Empty( cPath7z )
   cPath7z += '\7z.exe'
Else
   // ������ - ��� ������������� ������ � �������
Endif
*/

If ( !File( cPath7z  ) .and. ;
     !File( ALONE_7Z )       ;
   )
   
   // ���� ��� �������������� 7-Zip � ����������� �������� ����������,
   // �� � ���������� �������� ���������.
   // ���� ����� ���� �����: ������������� ����� 7-zip32.dll ��� 7-Zip
   // ��������� ������������� �����, �� �� ��������� ��������� ���
   // ��������� �� ���� �����.
  
  // If it is not installed 7-Zip archiver and console version,
  // And then further action is prohibited.
  // While there is nuance: the use of one 7-zip32.dll without 7-Zip
  // Allows you to view the archive, but can not create or
  // extract the files from it.   
  
   MsgStop( 'The required programs are not found.', 'Error' )
   Quit
   
Endif

Set font to 'Tahoma', 9

Define window wMain                   ;
       At 0, 0                        ;
       Width 553                      ;
       Height 432                     ;
       Title 'Demo 7-Zip interaction' ;
       Icon 'main.ico'                ;
       Main                           ;
       NoMaximize

  Define tab tbMain ;
          at 5, 5   ;
          Width 535 ;
          Height 370

    Define page 'Archive'

      // ���������� ���������� ���������� ������. 
      // Display the contents of the archive.
      @ 30, 5 Grid grdContent            ;
              Width 520                  ;
              Height 285                 ;
              Headers { 'Name' }         ;
              Widths { 400 }             ;
              Multiselect

      // �������� �������� ������, ���������� � ��������
      // Operations: open the archive, extract and create
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

    End page

    // ��������� ��������� ���������

    Define page 'Options'

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
               On Change wMain.btnExtract.Enabled := .F.     ;
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
      @ 285, 15 Label lbl7z   ;
                Value '7-Zip' ;
                Width 120     ;
                Height 15
      @ 285, 140 Hyperlink hl7z                 ;
                 Value 'http://www.7-zip.org'   ;
                 Address 'http://www.7-zip.org' ;
                 HandCursor
      @ 305, 15 Label lblDLL_JA                ;
                Value '7-Zip32.dll (Japanese)' ;
                Width 120                      ;
                Height 15
      @ 305, 140 Hyperlink hlDLL_JA                              ;
                 Value 'http://www.csdinc.co.jp/archiver/lib/'   ;
                 Address 'http://www.csdinc.co.jp/archiver/lib/' ;
                 Width 270 HandCursor
      @ 325, 15 Label lblDLL_EN               ;
                Value '7-Zip32.dll (English)' ;
                Width 120                     ;
                Height 15
      @ 325, 140 Hyperlink hlDLL_EN                                         ;
                 Value 'http://www.csdinc.co.jp/archiver/lib/main-e.html'   ;
                 Address 'http://www.csdinc.co.jp/archiver/lib/main-e.html' ;
                 Width 270 HandCursor

    End page

  End tab

  Define statusbar
     StatusItem ''
     StatusItem '' Width 120
     StatusItem '' Width 40
     StatusItem '' Width 130
  End statusbar

End window

// ������������� ������ � ��������� �����

If !File( cPath7z )

   // �������� ������ ������ ���������� ������ ����������

   wMain.rdgSelectTest.Enabled( 1 ) := .F.
   wMain.rdgSelectTest.Enabled( 2 ) := .F.
   wMain.rdgSelectTest.Value := 3

   If !File( ALONE_7Z )

      // ��� ������ ������. ��������� ��

      wMain.rdgSelectTest.Enabled := .F.
      wMain.rdgSelectTest.Value   := 0

   Endif

Else

   // ��� ���������� ������������ ���������� � ���������� ������
   // ���������� ���������� ����� ������ �������� ������������ ������ 7-Zip

   wMain.rdgSelectTest.Value := 2

   If !File( '7-zip32.dll' )
      wMain.rdgSelectTest.Enabled( 1 ) := .F.
   Else
      wMain.rdgSelectTest.Value := 1
   Endif

   If !File( ALONE_7Z )
      wMain.rdgSelectTest.Enabled( 3 ) := .F.
   Endif

Endif

wMain.btnExtract.Enabled := .F.

Center window wMain
Activate window wMain

Return

****** End of Main ******


/******
*
*       RunTest( nChoice )
*
*       ������ ���������. ��� ����� ���������� ���������
*       ��������������� ���������� rdgSelectTest 
*/

Static Procedure RunTest( nChoice )
Local nSelected := wMain.rdgSelectTest.Value

Do case
   Case ( nChoice == 1 )        // �������� ������

      If ( nSelected == 1 )
         // ���������� 7-zip32.dll
         CreateArc()
      Else
         // ��������� 7z.exe ��� 7za.exe
         CreateArcExternal()
      Endif

   Case ( nChoice == 2 )        // �������� �����������

      If ( nSelected == 1 )
         ViewArc()
      Else
         ViewArcExternal()
      Endif

   Case ( nChoice == 3 )        // ���������� ������

      If ( nSelected == 1 )
         ExtractArc()
      Else
         ExtractArcExternal()
      Endif

Endcase

Return

****** End of RunTest ******


/******
*
*       ShowStatus( cFile, cCount, cType, cVersion )
*
*       ����������� ��������� ������ ���������
*
*/

Static Procedure ShowStatus( cFile, cCount, cType, cVersion )

wMain.StatusBar.Item( 1 ) := cFile      // �������������� ����
wMain.StatusBar.Item( 2 ) := cCount     // ������ � ������
wMain.StatusBar.Item( 3 ) := cType      // ��� ������
wMain.StatusBar.Item( 4 ) := cVersion   // ���������� � ��������� 

Return

****** End of ShowStatus ******


//--------------------------------------------------------------
// ���� �������� ��� 7-zip32.dll  
//--------------------------------------------------------------

/******
*
*       Version7zip() --> cVersion
*
*       ������ ���������� 7-zip � 7-zip32.dll
*
*/

Static Function Version7zip
Local nVersion    := SevenZipGetVersion()   , ;    // 7-zip 
      nSubversion := SevenZipGetSubVersion(), ;    // 7-zip32.dll
      cVersion    := 'Version '

cVersion += ( Str( ( nVersion / 100 ), 5, 2 ) + '.' + StrZero( ( nSubversion / 100 ), 5, 2 ) )

Return cVersion

****** End of Version7zip ******


/******
*
*       CreateArc()
*
*       �������� ������
*
*/

Static Procedure CreateArc
Local aSource := GetFile( { { 'All files', '*.*' } }     , ;
                             'Select file(s)'            , ;
                             GetCurrentFolder(), .T., .T.  ;
                           )                             , ;
     cArcFile                                            , ;
     cType     := ''                                     , ;
     cCommand  := 'A '                                   , ;
     nDLLHandle
     
If !Empty( aSource )

   cArcFile := PutFile ( { { '7-zip', '*.7z' }, { 'Zip', '*.zip' } }, ;
                         'Create archive'                           , ;
                         GetCurrentFolder()                         , ;
                         .T.                                          ;
                       )                     

   If !Empty( cArcFile )

      // ���������� ��� ������. �� ��������� ������������ 7z, �������
      // ���������� ������ � ������ ��������� � ���������� ����.  

      If ( Upper( Right( cArcFile, 3 ) ) == 'ZIP' )
         cType := 'zip'
      Endif

      // ������ ������ ������� ��� �������� � DLL

      If wMain.cbxHide.Value
         cCommand += '-hide '       // �� ���������� �������
      Endif

      If !Empty( cType )
         cCommand += '-tzip '       // � ������� ZIP
      Endif

      cCommand += ( cArcFile + ' ' )

      // ��������� ����� ��� ���������

      AEval( aSource, { | elem | cCommand += ( '"' + elem + '" ' ) } )

      cCommand := RTrim( cCommand )

      If !( ( nDLLHandle := WIN_P2N( WAPI_LOADLIBRARY( '7-zip32.dll' ) )  > 0 ) )
         MsgStop( "Can't load 7-zip32.dll.", 'Error' )
      Else
         DllCall( nDLLHandle, DC_CALL_STD, 'SevenZip', _HMG_MainHandle, cCommand )
         wapi_FreeLibrary( nDLLHandle )

         // ��������� ������ ���������

         ShowStatus( cArcFile, '', Iif( Empty( cType ), '7z', 'zip' ), Version7zip() )

      Endif

   Endif

Endif

Return

****** End of CreateArc ******


/******
*
*       ViewArc()
*
*       ������� ����� � ��������� ������� ����������
*
*/

Static Procedure ViewArc
Local cFile      := GetFile( { { '7-zip', '*.7z' }, { 'Zip', '*.zip' } }, ;
                             'Select archive'                           , ;
                             GetCurrentFolder()                         , ;
                             .F., .T.                                     ;
                           )                                            , ;
      nDLLHandle                                                        , ;
      nArcHandle                                                        , ;
      nResult                                                           , ;
      cValue                                                            , ;
      nCount    := 0                                                    , ;
      cType     := ''                                                   , ;
      oInfo                                                             , ;
      pInfo                                                             , ;
      aFiles    := {}

If Empty( cFile )
   Return
Endif

If !( ( nDLLHandle := WIN_P2N( WAPI_LOADLIBRARY( '7-zip32.dll' ) ) ) > 0 )
   MsgStop( "Can't load 7-zip32.dll.", 'Error' )
   Return
Endif

nArcHandle := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipOpenArchive', _HMG_MainHandle, cFile, 0 )   // ������� �����

If Empty( nArcHandle )
   MsgStop( cFile + ' not opened.', 'Error' )
   Return
Endif 

nCount  := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileCount'  , cFile )  // ���������� ��������� � ������
nResult := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetArchiveType', cFile )  // ��� ������

Do case
   Case ( nResult == 1 )
     cType := 'ZIP'

   Case ( nResult == 2 )
     cType := '7Z'

   Case ( nResult == -1 )
     // ������ ���������
     cType := 'Error'

   Case ( nResult == 0 )
     // �� �������������� ���. ���� ��� ������� ������� ���-������
     // ����� 7z � Zip ������� SevenZipOpenArchive() �����
     // ���������� ������.
     cType := '???'

Endcase

// ������������� ���������, ����������� ��� ��������� ��������� ������ �
// ��������� (��� �������� � DLL)

oInfo := ( struct INDIVIDUALINFO )
pInfo := oInfo : GetPointer()

// ���� 1-� ����. ���� ��������� ������ �� ����� ��������, �������� pInfo
// ����� ��������.

DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipFindFirst', nArcHandle, '*', pInfo )

// ����������������� ���������

oInfo := oInfo : Pointer( pInfo )

cValue := Space( FNAME_MAX32 )
DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileName', nArcHandle, @cValue, FNAME_MAX32 )

If !Empty( cValue )

   // ��������� ������� �����. ������� �������� ������� � ������,
   // ��������� � ������� Grid

   AAdd( aFiles, { cValue } )

   Do while ( ( nResult := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipFindNext', nArcHandle, pInfo ) ) == 0 )

      cValue := Space( FNAME_MAX32 )
      DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileName', nArcHandle, @cValue, FNAME_MAX32 )

      AAdd( aFiles, { cValue } )

   Enddo

   wMain.grdContent.DeleteAllItems

   ASort( aFiles,,, { | x, y | x[ 1 ] < y[ 1 ] } )

   wMain.grdContent.DisableUpdate
   AEval( aFiles, { | elem | wMain.grdContent.AddItem( elem ) } )
   wMain.grdContent.EnableUpdate
   wMain.grdContent.Value := { 1 }

Endif

// ������� �������� ����, ��������� ����������

DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipCloseArchive', nArcHandle )
wapi_FreeLibrary( nDLLHandle )

// ��������� ������ ���������
         
ShowStatus( cFile, ( 'Count files: ' + LTrim( Str( nCount ) ) ), cType, Version7zip() )

If ( wMain.grdContent.ItemCount > 0 )
   wMain.btnExtract.Enabled := .T.
Endif

Return

****** End of ViewArc ******


/******
*
*       ExtractArc()
*
*       ���������� ������ �� ������
*
*/

Static Procedure ExtractArc
Local aPos      := wMain.grdContent.Value, ;
      cDir                               , ;
      cCommand                           , ;
      nPos                               , ;
      cFile                              , ;
      nDLLHandle

If Empty( aPos )
   MsgStop( 'Select item(s), please!', 'Error' )
   Return
Endif

If !Empty( cDir := GetFolder( 'Extract file(s) to' ) )

   // ��������� � ����������� �������� ��������� ��� ���

   cCommand := ( Iif( wMain.cbxExtract.Value, 'x', 'e' ) + ' ' )

   If wMain.cbxHide.Value

      // �� ���������� �������. �� ���� ����������� ����������
      // ������������ ������, �������������� ������ �� �����
      // ����� �������.

      cCommand += '-hide '

   Endif

   // �������������� ������������ ����� ��� ��������������

   If wMain.cbxYesAll.Value
      cCommand += '-y '
   Endif

   cCommand += ( '-o' + cDir + ' ' )    // ���� �������

   // �� ������ �������� ��� ������, ����������� ����������� �����

   //cCommand += ( '"' + AllTrim( wMain.Statusbar.Item( 1 ) ) + '" ' )
   cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )

   // ��������� ����������� �����. ��� ��������� ���������:
   // ���� ���������� ���������� ��������� ����� ������
   // ����������, �� ��� ������ ��������� �������.

   If ( Len( aPos ) == wMain.grdContent.ItemCount )
      cCommand += '*.*'
   Else

      For Each nPos In aPos

         // �������, ���������� ������ ��� ��������, ����������

         cFile := AllTrim( wMain.grdContent.Item( nPos )[ 1 ] )

         If !( Right( cFile, 1 ) == '\' )
            //cCommand += ( '"' + cFile + '" ' )
            cCommand += ( cFile + ' ' )
         Endif

      Next

      cCommand := RTrim( cCommand )

   Endif

   If !( ( nDLLHandle := WIN_P2N( WAPI_LOADLIBRARY( '7-zip32.dll' ) ) ) > 0 )
      MsgStop( "Can't load 7-zip32.dll.", 'Error' )
   Else
      DllCall( nDLLHandle, DC_CALL_STD, 'SevenZip', _HMG_MainHandle, cCommand )
      wapi_FreeLibrary( nDLLHandle )
      MsgInfo( "Extraction is successfully.", 'Result' )
   Endif

Endif

Return

****** End of ExtractArc ******


// ��������� � 7-zip32.dll

// ������ � ��������� ����������

// Declare DLL_TYPE_WORD SevenZipGetVersion() in 7-zip32.dll
// Declare DLL_TYPE_WORD SevenZipGetSubVersion() in 7-zip32.dll

 Declare SevenZipGetVersion() in 7-zip32.dll
 Declare SevenZipGetSubVersion() in 7-zip32.dll

//--------------------------------------------------------------
// ���� �������� ��� 7-zip 7za.exe  
//--------------------------------------------------------------

/******
*
*       CreateArcExternal()
*
*       �������� ������
*
*/

Static Procedure CreateArcExternal
Local aSource := GetFile( { { 'All files', '*.*' } }     , ;
                             'Select file(s)'            , ;
                             GetCurrentFolder(), .T., .T.  ;
                          )                              , ;
     cArcFile                                            , ;
     nPos                                                , ;
     cExt                                                , ;
     cType     := ''                                     , ;
     cCommand  := ' A '
     
If !Empty( aSource )

   // ��������� ��������������� � ������ 7-Zip ��������� ���������
   // ������� ���������� ����� �������

   cArcFile := PutFile ( { { '7-zip', '*.7z'    }, ;
                           { 'Zip'  , '*.zip'   }, ;
                           { 'GZip' , '*.gzip'  }, ;
                           { 'BZip2', '*.bzip2' }, ;
                           { 'Tar'  , '*.tar'   }  ;
                         }                       , ;
                         'Create archive'        , ;
                         GetCurrentFolder()      , ;
                         .T.                       ;
                       )                     

   If !Empty( cArcFile )

      // ���������� ��� ������. �� ��������� ������������ 7z, �������
      // ���������� ������ � ������ ��������� � ���������� ����.  

      nPos := RAt( '.', cArcFile )
      cExt := Upper( Right( cArcFile, ( Len( cArcFile ) - nPos ) ) )

      If !( cExt == '7Z' )
         cType := cExt
      Endif

      // ������ ������ �������

      If !Empty( cType )
         cCommand += ( '-t' + cType + ' ' )
      Endif

      cCommand += ( cArcFile + ' ' )

      // ��������� ����� ��� ���������

      AEval( aSource, { | elem | cCommand += ( '"' + elem + '" ' ) } )

      // ��������� ��� ������������� ��������� ��� ����������
      // ������, ����������� � ����� � ���������������� ����������

      If ( wMain.rdgSelectTest.Value == 2 )
         cCommand := ( cPath7z + cCommand )
      Else
         cCommand := ( ALONE_7Z + cCommand )
      Endif

      cCommand := RTrim( cCommand )

      // ��������� � ������ �������� ��������� ���������. ����
      // ��� ���� ���� ���� ���������� ������ (��� ��������, �.�. ����
      // ����������), ��� ����������� � ���, ��� ������ ����������� (����
      // ����� �������), ����� ������� �����-������ �������������� ����, 
      // �������� � ��������.

      // ���� ��� �������: ��� 7-Zip ��������� �� %ProgramFiles%\7-Zip\7z.exe,
      // � %ProgramFiles%\7-Zip\7zG.exe - ����������� ��������� ����������.
      // ������� �� ������ ���������� ��������� �������� ���������. 
            
      If wMain.cbxHide.Value
         Execute file ( cCommand ) Wait Hide
      Else
         Execute file ( cCommand ) Wait
      Endif

      // ��������� ������ ���������

      ShowStatus( cArcFile, '', Iif( Empty( cType ), '7Z', cType ), ;
                  Iif( ( wMain.rdgSelectTest.Value == 2 ), '7-Zip', '7za' ) )

   Endif

Endif

Return

****** End of CreateArcExternal ******


/******
*
*       ViewArcExternal()
*
*       ������� ����� � ��������� ������� ����������
*
*/

Static Procedure ViewArcExternal
// aFiles - ����� �������������� ����� �������. ������� ��������� ����� ��� 
// ���������� ������ (7za.exe), �.�. � ����������� ��������.
Local aFilters := { { '7-zip', '*.7z'   }, ;
                    { 'Zip'  , '*.zip'  }, ;
                    { 'Cab'  , '*.cab'  }, ;
                    { 'GZip' , '*.gzip' }, ;
                    { 'Tar'  , '*.tar'  }  ;
                  }                      , ;
        cFile                            , ;
        aFiles    := {}                  , ;
        cCommand                         , ;
        cTmpFile  := '_Arc_.lst'         , ;     // ��� GetTempFolder() + '\_Arc_.lst' 
        oFile                            , ;
        cString

// ������� ���� �������, � �������� ����� �������� ������ ������ (�� ���, 
// ��������� � ������������, �������)

If ( wMain.rdgSelectTest.Value == 2 )
   AAdd( aFilters, { 'Rar', '*.rar' } )
   AAdd( aFilters, { 'Arj', '*.arj' } )
   AAdd( aFilters, { 'Chm', '*.chm' } )
   AAdd( aFilters, { 'Lzh', '*.lzh' } )
Endif

If Empty( cFile := GetFile( aFilters, 'Select archive', GetCurrentFolder(), .F., .T. ) )
   Return
Endif

// ���������� ������ ������� �� ��������� ���� � ����� ��������� ��� ������ �
// ���������.

// �����, �������, ������ GetEnv( 'COMSPEC' ) ���������� ������ cmd.exe, �� 
// ��� ���������� ���������� ����� ���������� � ������ ������� Windows

cCommand := GetEnv( 'COMSPEC' ) + ' /C '

If ( wMain.rdgSelectTest.Value == 2 )
   // ������� �� ��������, �.�. Program Files ����� ������ � �����.
   // ����� ����� ������������ ������ %ProgramFiles%\7-Zip\7z.exe, �.�.
   // ����������� ������� 7zG.exe �� ������������ ��������������� ������ � ����
   cCommand := ( cCommand + '"' + cPath7z + '"' )
Else
   cCommand := ( cCommand + ALONE_7Z )
Endif

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

Execute File ( cCommand ) Wait Hide

// ����� ���������� �������� ���� �� ������������� ����� ���������� ���������
// �������� WinAPI (������������ CreatePipe � �������� � ��� ��� � ������� 
// ������), � �� ��������� ��������� ����, �� � �� ����� ������ ������.

If File( cTmpFile )

   // ��������� ���� ����� � �� ���������, ��������, ���������� ������
   // � ������ �������. ������������� �� ������ �� ��������� � ��� ������.
   // ���� ������� - �� � �� ��� ������.

   // ��������� ������

   oFile := TFileRead() : New( cTmpFile )
   oFile : Open()

   If !oFile : Error()

      Do While oFile : MoreToRead()

         If !Empty( cString := oFile : ReadLine() )

            // ��������� ��������� ���������. ������ ���������, �� ����������
            // �� ������ � "Path =" �, ���� �� - �� ��� ��� �����. ���
            // �������������, ����� ������� ���������. ��������, ������������
            // ����� ��������� (������ "Attributes = D...." ��� ������ .7z)

            If ( Left( cString, 7 ) == 'Path = ' )
               cString := AllTrim( Substr( cString, 8 ) )
               AAdd( aFiles, { cString } )
            Endif

         Endif

      Enddo

      oFile : Close()

      If !Empty( aFiles )

         wMain.grdContent.DeleteAllItems

         ASort( aFiles,,, { | x, y | x[ 1 ] < y[ 1 ] } )

         wMain.grdContent.DisableUpdate
         AEval( aFiles, { | elem | wMain.grdContent.AddItem( elem ) } )
         wMain.grdContent.EnableUpdate
         wMain.grdContent.Value := { 1 }

         // ��������� ������ ��������� (� ��� ����� ��������� ��� ����������
         // ������, ����������� ��� ���������� ������)

         ShowStatus( cFile, ( 'Count files: ' + LTrim( Str( Len( aFiles ) ) ) )   , ;
                     Upper( Right( cFile, ( Len( cFile ) - RAt( '.', cFile ) ) ) ), ;
                     Iif( ( wMain.rdgSelectTest.Value == 2 ), '7-Zip', '7za' ) )

      Endif

   Endif

   If ( wMain.grdContent.ItemCount > 0 )
      wMain.btnExtract.Enabled := .T.
   Endif

Endif

// ��������� ���� ������ ���� ���� � �.�. �����. ������� ��
// �������� ������ � � ��� ������, ����� ��������� ���� �� ����������.

FErase ( cTmpFile )
 
Return

****** End of ViewArcExternal ******


/******
*
*       ExtractArcExternal()
*
*       ���������� ������ �� ������
*
*/

Static Procedure ExtractArcExternal
Local aPos      := wMain.grdContent.Value, ;
      cDir                               , ;
      cCommand                           , ;
      nPos                               , ;
      cFile

If Empty( aPos )
   MsgStop( 'Select item(s), please!', 'Error' )
   Return
Endif

If !Empty( cDir := GetFolder( 'Extract file(s) to' ) )

   // ��������� � ����������� ��������� ��������� ��� ���
    
   cCommand := ( Iif( wMain.cbxExtract.Value, 'X', 'E' ) + ' ' )
   
   // �������������� ������������ ����� ��� ��������������
   
   If wMain.cbxYesAll.Value
      cCommand += '-y '
   Endif
   
   cCommand += ( '-o' + cDir + ' ' )    // ���� �������
   
   cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )
   
   If ( Len( aPos ) == wMain.grdContent.ItemCount )

      cCommand += '*.*'

   Else
   
      For Each nPos In aPos
           
         // �������, ���������� ������ ��� ��������, ����������
           
         cFile := AllTrim( wMain.grdContent.Item( nPos )[ 1 ] )
           
         If !( Right( cFile, 1 ) == '\' )
            cCommand += ( cFile + ' ' )
         Endif
           
      Next
    
      cCommand := RTrim( cCommand )

   Endif

   If ( wMain.rdgSelectTest.Value == 2 )
      
      // ���� ������ 7z.exe ������������ 7zG.exe, �� ����� ������������
      // ��������� ������

      cCommand := ( cPath7z + ' ' + cCommand )
   Else
      cCommand := ( ALONE_7Z + ' ' + cCommand )
   Endif

   // ���������.

   If wMain.cbxHide.Value .and. !wMain.cbxYesAll.Value
      Execute File ( cCommand ) Wait Hide
   Else
      Execute File ( cCommand ) Wait
   Endif

   MsgInfo( 'Extraction is successfully.', 'Result' )

Endif

Return

****** End of ExtractArcExternal ******
