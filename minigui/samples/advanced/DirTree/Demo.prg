/******
*
* MINIGUI - Harbour Win32 GUI library Demo
*
* Build tree of folders, files and archives
* 
* (c) 2008-2009 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
*
* Revised by Grigory Filatov <gfilatov@inbox.ru>
* 
*/


/*
������� ���������.

+ ���������
* ��������
- �������

������ 2009 �.

* ����� �� Zip-������ ����������� � ����������� ���������.
  ������ ������� ���������� hbzlib.lib �� ziparchive.lib � �������
  ��������� HB_OEMtoANSI() �� ����� ��������� ����� ����� �����������
  ����������, ���������� 7-Zip
* ��� ��������� ���������� Zip-������� ������ ������� ZipIndex() 
  ������������ ������� HB_GetFilesInZip(). ZipIndex() ��������� �
  ������ ��������� � ������������������ ���� (�� ������ ������).
+ ��������� ������ 7-Zip ������ � ���� ����������� ���������� �
  ���������� ������ ��� ������ ������, ���������� ���� � ������
  ��������� ������ ��������. ������� ��� ��������� ������, ����������
  ��� ��������������� ������ ������������.
+ ���������� �������� ������������ ������

������� 2008 �.

��������� ������.
*/


#include "HBCompat.ch"
#include "Directry.ch"
#include "MiniGUI.ch"

// ����������� ����� ���������� 7-Zip

#define FULL_7Z             '7z.exe'         // ������ ������
#define DLL_7Z              '7z.dll'         // ���������� � ������ ������  
#define ALONE_7Z            '7za.exe'        // ���������� �������  

#define TEMP_FOLDER         ( GetTempFolder() + '\' )
#define TMP_ARC_INDEX       ( TEMP_FOLDER + '_Arc_.lst' )     // ��������� ���� ��� ������ ���������� ������
                                               
// ���������� ���������

#translate BREAK_ACTION_()                                                                                 ;
           =>                   lBreak := MsgYesNo( 'Stop operation?', 'Confirm action', .T., , .F., .F. )

// ��������� ������ ���������

// 1) �������� ��������: ������ ������������
#translate SET_DOSCAN_()                                                           ;
           =>                   wMain.ButtonEX_1.Caption     := 'Scan'             ;
                                ; wMain.ButtonEX_1.Picture   := 'OK'               ;
                                ; wMain.ButtonEX_1.Action    := { || BuildTree() } 
// 2) ���������� ������: ���������� ���������
#translate SET_STOP_SCAN_()                                                        ;
           =>                   wMain.ButtonEX_1.Caption   := '[Esc] Stop'         ;
                                ; wMain.ButtonEX_1.Picture := 'STOP'               ;
                                ; wMain.ButtonEX_1.Action  := { || BREAK_ACTION_() }


Static cApp7z   := ''         // ��������� 7-Zip
Static cOSPaths := ''         // �������� ��������� ���������� PATH (������������ ������ ��� ������ ������ 7-Zip)

Memvar lBreak                 // �������� ���������


/******
*
*    ������ ��������� � ������
*
*/

Procedure Main
Local cSysPath := Upper( GetEnv( 'PATH' ) ), ;
      cPath7z  := ''                       , ;
      oReg

Set font to 'Tahoma', 9

// ��� ������ � �������� (����� Zip) ���������� 7-Zip. ��������� ���� �� ���������:
// - ��������� ������������� (������ ������);
// - � ������� � ���������� �������� ����� 7z.exe � 7z.dll (��������� �� �������������, ��
//   ���������������� ����������� �� ��, ��� � � ������������ ������);
// - � �������� � ���������� ��������� ���������� ������ (7za.exe)
// �������� ������ �� ���������. ��� ����� ��������� ����������� ����������� ��������. ����������
// ������ ������ 7-Zip (���������������� �������������) ���� ����� ������ �������
// ����� ����, ��� ������������� 7-Zip, ������������ � Program Files, ����������� ��������� ����������
// ��������� ������ - �� ����������� �������, � ������� � � ����� ���������, � �����-��������� 
// ������������ ����� � ���������:
// %COMSPEC% /C "%\ProgramFiles%\7-Zip\7z.exe" L -slt "Some data.7z"
// ��� ������ ����� �������� � ��������� ���������� PATH ��������� ������� ������ 7z.exe, � �����
// ���������� ��������� - ��������������� �������� �������� PATH.
// ���� 7z.exe � 7z.dll ��������� � �������� ���������, �������� PATH �� ����������.
 
// ��� ������� Zip ������ ���������� ���������� �����������.

Open registry oReg key HKEY_LOCAL_MACHINE Section 'Software\7-Zip'
Get value cPath7z Name 'Path' of oReg 
Close registry oReg

If !Empty( cPath7z )                              // ���������������� ������

   cPath7z := Upper( cPath7z )
   
   If !( cPath7z $ cSysPath )
      
      cOSPaths := cSysPath
      
      If !( Right( cOSPaths, 1 ) == ';' )
         cOSPaths += ';'
      Endif
      
      cOSPaths += ( cPath7z + '\' ) 
      cApp7z := FULL_7Z
            
   Endif
   
ElseIf ( File( FULL_7Z ) .and. File( DLL_7Z ) )   // � �������� � ���������� ��������� 7z.exe � 7z.dll
   cApp7z := FULL_7Z
   
ElseIf File( ALONE_7Z )                           // � �������� � ���������� ��������� 7za.exe
   cApp7z := ALONE_7Z

Endif

Load window Demo as wMain

wMain.BtnTextBox_1.Value := GetMyDocumentsFolder()   // ������� ��� ������������ �� ���������

// ��� ����������� ���������� ������ 7-Zip ��������� ������ ��������� �������� ��������,
// ����, ��������, ��� ��������� RAR ����� ������������ ������ ������ 7-Zip 

If !Empty( cApp7z )
   
   // �������������� ���� ������� ��� ������ � ���������� ������
   
   If ( cApp7z == FULL_7Z )
      wMain.Combo_1.AddItem( 'ZIP; 7Z; RAR; CAB; ARJ; LZH' )
   Else
      wMain.Combo_1.AddItem( 'ZIP; 7Z' )
   Endif
   
   wMain.Combo_1.Value := 2
   
Endif

SET_DOSCAN_()

wMain.ButtonEX_2.Enabled := .F.
wMain.ButtonEX_3.Enabled := .F.
wMain.ButtonEX_4.Enabled := .F.

Center window wMain
Activate window wMain 

Return

****** End of Main ******


/******
*
*       SelectDir()
*
*       ����� �������� ��� ������������
*
*/

Static Procedure SelectDir
Local cPath := AllTrim( wMain.BtnTextBox_1.Value )

If !Empty( cPath := GetFolder( 'Select folder', cPath ) )
   wMain.BtnTextBox_1.Value := cPath
Endif

Return

****** End of SelectDir ******

 
/******
*
*       BuildTree()
*
*       ���������� ������
*
*/

Static Procedure BuildTree
Local cPath     := wMain.BtnTextBox_1.Value, ;
      cSavePath := ''

Private lBreak := .F.          // �������� ���������
SET_STOP_SCAN_()
On key Escape of wMain Action BREAK_ACTION_()

If !Empty( cPath )

   // ��� ������������� ������������ ������ 7-Zip �������� ���������
   // ���������� PATH
   
   If !Empty( cOSPaths )
      cSavePath := GetEnv( 'PATH' )
      SetEnvironmentVariable( 'PATH', cOSPaths )
   Endif
   
   wMain.Tree_1.DeleteAllItems
   wMain.Tree_1.DisableUpdate

   // ������� ������� ���� ��������� ��������

   Node wMain.BtnTextBox_1.Value Images { 'STRUCTURE' }
      ScanDir( cPath )
   End Node
   wMain.StatusBar.Item( 1 ) := ''
   
   // ������������ �������� �������� ��������� ���������� PATH (���� ���
   // ���� ��������).
   
   If !Empty( cSavePath )
      SetEnvironmentVariable( 'PATH', cSavePath )
   Endif
   
   wMain.Tree_1.Expand( 1 )
   wMain.Tree_1.EnableUpdate
   
   wMain.Tree_1.Value := 1
   wMain.Tree_1.SetFocus
   
   If ( wMain.Tree_1.ItemCount > 1 )
      wMain.ButtonEX_2.Enabled := .T.
      wMain.ButtonEX_3.Enabled := .T.
      wMain.ButtonEX_4.Enabled := .T.
   Else
      wMain.ButtonEX_2.Enabled := .F.
      wMain.ButtonEX_3.Enabled := .F.
      wMain.ButtonEX_4.Enabled := .T.
   Endif
   
Endif

SET_DOSCAN_()
Release key Escape of wMain

Return

****** End of BuildTree ******


/******
*
*       ScanDir( cPath )
*
*       ������������ ��������
*
*/

Static Procedure ScanDir( cPath )
Local cMask     := AllTrim( wMain.Text_1.Value )      , ;
      cAttr     := Iif( wMain.Check_1.Value, 'H', '' ), ;
      aFullList                                       , ;
      aDir      := {}                                 , ;
      aFiles                                          , ;
      xItem

If !( Right( cPath, 1 ) == '\' )
   cPath += '\'
Endif

Begin Sequence

   // ��������� ��� ������� ����� �������������� �����, ��������� ��������� �������.
   // 1) �������� ������ ���� ������������ ��������� ���������� (����� �� �����������,
   //    ��������� ��� ���� ����� �������������� ���� �����������)
   // 2) ��� ������� ����������� ����������� ������ ������������� ��� ������
   //    � ������ �������
   // 3) ���������� �� ����������� � ������, ���� ��������� ������ ��� � �� ���������
   //    ���������� ������ ���������
 
   If !Empty( aFullList := ASort( Directory( cPath, ( 'D' + cAttr ) ),,, ;
                                  { | x, y | Upper( x[ F_NAME ] ) < Upper( y[ F_NAME ] ) } ) )

      For each xItem in aFullList

        If ( 'D' $ xItem[ F_ATTR ] )
           If ( !( xItem[ F_NAME ] == '.' ) .and. !( xItem[ F_NAME ] == '..' ) )
              AAdd( aDir, xItem[ F_NAME ] )
           Endif 
        Endif 

        Do Events
        
        If lBreak
           Break
        Endif 

      Next

   Endif

   // ������������ ���������� ������ ���������. ��� ���� ����������� �����������
   // ����� ��������� ��� ������������ ����� �������� �������

   If !Empty( aDir )

      For each xItem in aDir

        // ����� ����������� ���� �������� ��������� ������� � ��
        // ������, ����������� � �������� ��� ������������. ����� ����� ������ ����
        // �� �����.
     
        // ���� ����� ��������� ������ ������� ������:
        // If !Empty( Directory( ( cPath + xItem + '\' + cMask ), cAttr ) )
        // ������ � ���� ������ ��������, � ������� ��� ������ (�� �������� �����), 
        // �� ���� �����������, � ���������� �������� �� �����, ��� � �����, �����������
        // � ���. 
     
        If ( !Empty( Directory( ( cPath + xItem + '\' + cMask ), cAttr ) ) .or.  ;
             ( wMain.Check_3.Value                                         .and. ;
               !Empty( Directory( ( cPath + xItem ), ( 'D' + cAttr ) ) )         ;
             )                                                                   ;
           )

           Node xItem   
             ScanDir( cPath + xItem )
           End Node

           Do Events

           If lBreak
              Break
           Endif 
     
        Endif
     
      Next
   
   Endif

   // ��������� ������ ������

   If !Empty( aFiles := ASort( Directory( ( cPath + cMask ), cAttr ),,, ;
                               { | x, y | Upper( x[ F_NAME ] ) < Upper( y[ F_NAME ] ) } ) )

      For each xItem in aFiles
      
         wMain.StatusBar.Item( 1 ) := ( cPath + xItem[ F_NAME ] )
         
         Do Events
      
         If !wMain.Check_2.Value         // �� ����������� ������
            TreeItem xItem[ F_NAME ]
         Else
            GetArc( cPath, xItem[ F_NAME ] )
         Endif   

         If lBreak
            Break
         Endif   
   
      Next
   
   Endif

End
 
Return

****** End of ScanDir ******


/******
*
*       GetArc( cPath, cFile )
*
*       ��������� ��������� �����
*
*/

Static Procedure GetArc( cPath, cFile )
Local cArcTypes := wMain.Combo_1.DisplayValue, ;
      cExt                                   , ;
      aFileList                              , ;
      cItem

HB_FNameSplit( cFile, , , @cExt )

If !Empty( cExt := Upper( cExt ) )

   If ( Left( cExt, 1 ) == '.' )
      cExt := Substr( cExt, 2 )
   Endif
   
   // ���� ���������� ����������� ��������� ����, �������� ����������
   // ������. ��� ���� ������ ZIP �������������� ������������ ����������.
   // � ��������� - ������� �����������
   
   If !( cExt $ cArcTypes )
      TreeItem cFile
      
   Else
   
      // ���������� ������ �������� 2-� ���������: ����������� ����������
      // ZIP � �������� 7-Zip. ������ ������ � Zip-������ ����� �������� �
      // ������� �������� HB_GetFilesInZip( cPath + cFile ).
      // � ���������� ������� Harbour ���������� ������� ��������� � ���������
      // ������� ��� ���������� ���� ������� �� ������� ���������� �������, 
      // ������� ���� ������� ������� ZipIndex(). �� � ��������� ����� ��� ����� 
      // ���������, ������� ZipIndex() ��������� � ������ ���������, �� �� ������������.
      
      Try
        //aFileList := Iif( ( cExt == 'ZIP' ), ZipIndex( cPath + cFile ), ArcIndex( cPath + cFile ) )
        aFileList := Iif( ( cExt == 'ZIP' ), HB_GetFilesInZip( cPath + cFile ), ArcIndex( cPath + cFile ) )
      Catch
        aFileList := {}
      End
            
      If !Empty( aFileList )
         
         Node cFile Images Iif( ( cExt == 'ZIP' ), { 'ARC_ZIP' }, { 'ARC_7ZIP' } )
            For each cItem in aFileList
               TreeItem cItem
             Next   
         End Node
         
      Else
         TreeItem cFile
         
      Endif
         
   Endif

Else
   TreeItem cFile
   
Endif
     
Return

****** End of GetArc ******


// ������� ZipIndex() �������������� ��� ������ HB_GetFilesInZip(), �� � ���������
// ������� Harbour ������������� � ��� ������. ��������� ��� �������.
  
/******
*
*       ZipIndex( cArcFile ) --> aFiles
*
*       ������ ������ � ������ ZIP
*
*/

/*
Static Function ZipIndex( cArcFile )
Local aFiles := {}                      , ;
      hUnzip := HB_UnZipOpen( cArcFile ), ;
      nError                            , ;
      cFile

If !Empty( hUnzip )

    nError := HB_UnZipFileFirst( hUnzip )

    Do while Empty( nError )

       HB_UnZipFileInfo( hUnzip, @cFile )
       
       AAdd( aFiles, cFile )

       nError := HB_UnZipFileNext( hUnzip )

    Enddo

    HB_UnZipClose( hUnzip )

Endif

Return aFiles
*/

****** End of ZipIndex ******


/******
*
*       ArcIndex( cArcFile ) --> aFiles
*
*       ������ ������ � ������ �� ZIP-����
*
*/

Static Function ArcIndex( cArcFile )
Local aFiles   := {}                                       , ;
      cCommand := ( GetEnv( 'COMSPEC' ) + ' /C ' + cApp7z ), ;
      cString, oFile

// ���������� ������ ������� �� ��������� ���� � ����� ��������� ��� ������ �
// ���������.

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

cCommand += ( ' L -slt "' + cArcFile + '" > ' + TMP_ARC_INDEX )
Execute file ( cCommand ) Wait Hide

If File( TMP_ARC_INDEX )

   // ��������� ���� ����� � �� ���������, ��������, ���������� ������
   // � ������ �������. ������������� �� ������ �� ��������� � ��� ������.
   // ���� ������� - �� � �� ��� ������.

   // ��������� ������
  
   oFile := TFileRead() : New( TMP_ARC_INDEX )
   oFile : Open()

   If !oFile : Error()

      Do while oFile : MoreToRead()
   
         If !Empty( cString := oFile : ReadLine() )
   
            // ��������� ���������� ���������. ������ ���������, �� ����������
            // �� ������ � "Path =" �, ���� �� - �� ��� ��� �����. ���
            // �������������, ����� ������� ���������. ��������, ������������
            // ����� ��������� (������ "Attributes = D...." ��� ������ .7z)
          
            If ( Left( cString, 7 ) == 'Path = ' )
            
               cString := HB_OEMtoANSI( AllTrim( Substr( cString, 8 ) ) )

               // ��������� ������ 7-Zip � ����� � ���������� ������ ���������
               // ������������ ������ ������ (����� � ������ "Path =").
               // ������� ������ ��������.
               
               If !( Upper( cArcFile ) == Upper( cString ) )
                  AAdd( aFiles, cString )
               Endif
               
            Endif
         
         Endif
      
      Enddo

      oFile : Close()

   Endif

Endif

// ��������� ���� ������ ���� ���� � �.�. �����.

Erase ( TMP_ARC_INDEX )
 
Return aFiles

****** End of ArcIndex ******


/******
*
*       ShowTreeNode( nMode )
*
*       ���������� (1) ��� �������� (0) ��� ���� ������
*
*/

Static Procedure ShowTreeNode( nMode )
Local nCount := wMain.Tree_1.ItemCount, ;
      Cycle

If !Empty( nCount )

   wMain.Tree_1.DisableUpdate

   For Cycle := 1 to nCount
   
     // ������������ ������ ��������, �� ������� �������� ������ (����)

     If IsTreeNode( 'wMain', 'Tree_1', Cycle )

        If ( nMode == 1 )
           wMain.Tree_1.Expand( Cycle )
        Else
           wMain.Tree_1.Collapse( Cycle )
        Endif
        
     Endif
     
   Next

   If ( nMode == 1 )
      wMain.Tree_1.Value := 1
   Endif
   
   wMain.Tree_1.EnableUpdate
   wMain.Tree_1.SetFocus
   
Endif

Return

****** End of ShowTreeNode ******


/******
*
*       IsTreeNode( cFormName, cTreeName, nPos ) --> lIsNode
*
*       ��������, �������� �� ������� ������ �����
*
*/

Static Function IsTreeNode( cFormName, cTreeName, nPos )
Local nVal            := GetProperty( cFormName, cTreeName, 'Value' )    , ;
      nAmount         := GetProperty( cFormName, cTreeName, 'ItemCount' ), ;
      nIndex                                                             , ;
      nHandle                                                            , ;
      nTreeItemHandle

If ( Valtype( nPos ) == 'N' )
   If ( ( nPos > 0 ) .and. ( nPos <= nAmount ) )
      nVal := nPos
   Endif
Endif

nIndex          := GetControlIndex( cTreeName, cFormName )
nHandle         := _HMG_aControlHandles[ nIndex ]
nTreeItemHandle := _HMG_aControlPageMap[ nIndex, nVal ]

// ������� ������ ��������� �����, ���� ����� ���������� ��������

Return !Empty( TreeView_GetChild( nHandle, nTreeItemHandle ) )

****** End of IsTreeNode ******


/******
*
*       OpenObj( cFormName, cTreeName )
*
*       ������� ������� ������, �������������� ��������� ������
*
*/

Static Procedure OpenObj( cFormName, cTreeName )
Local nVal            := GetProperty( cFormName, cTreeName, 'Value' ), ;
      nIndex                                                         , ;
      nHandle                                                        , ;
      nTreeHandle                                                    , ;
      nTreeItemHandle                                                , ;
      nTempHandle                                                    , ;
      cChain                                                         , ;
      aTokens                                                        , ;
      cArcName        := ''                                          , ;
      cElem                                                          , ;
      cExt                                                           , ;
      cSavePath       := ''                                          , ;
      cCommand        := ( GetEnv( 'COMSPEC' ) + ' /C ' + cApp7z )

If Empty( nVal )
   Return
Endif

// ������������ ����� � �������� ������� ��� ����������� �������� � �����

nTreeHandle := GetControlHandle( cTreeName, cFormName ) 

nIndex  := GetControlIndex( cTreeName, cFormName )
nHandle := _HMG_aControlHandles[ nIndex ]

nTreeItemHandle := _HMG_aControlPageMap[ nIndex, nVal ]

cChain      := TreeView_GetItem( nTreeHandle, nTreeItemHandle )
nTempHandle := TreeView_GetParent( nHandle, nTreeItemHandle )

Do while !Empty( nTempHandle )
   nTreeItemHandle := nTempHandle 
   nTempHandle     := TreeView_GetParent( nHandle, nTreeItemHandle )
   cChain          := ( TreeView_GetItem( nTreeHandle, nTreeItemHandle ) + ;
                      Iif( Right( TreeView_GetItem( nTreeHandle, nTreeItemHandle ), 1 ) == '\', '', '\' ) + cChain )
Enddo

// ���������� �������� �.�. ���������, ������ ��� ������ � ������. � ��������� ������
// ���� ����� ������������� ������ �����������, ���������� � �����. 

If ( HB_DirExists( cChain ) .or. File( cChain ) )

   // ������� ��� ����. ��� �������� ��������� �����, ��� ����� - ��������� ��������������� ���������.
   // !!! ����� � ��������� "�������" � ��� ����� �� ��������.
   
   Execute operation 'Open' file ( '"' + cChain + '"' )

Else

  // ���� � ������. ��������� ������ ��� � ���������� ������������ ������ ������.
  
  aTokens := HB_ATokens( cChain, '\' )
  
  For each cElem in aTokens
  
    If !Empty( cArcName )
       cArcName += '\'
    Endif
    
    cArcName += cElem
    
    If File( cArcName )
       Exit
    Endif
    
  Next

  // ��� ������ ��������� �� ���������� ������ ��������. 
  
  cChain := Substr( cChain, ( Len( cArcName ) + 1 ) )  // ������ ��� ��� ����� � ������
  
  If ( Left( cChain, 1 ) == '\' )
     cChain := Substr( cChain, 2 )
  Endif
  
  // ��� ��� ��������� �������� ������������� �����, ��������� � ���
  // ����� �������� ��������� ������ � ��������� "�������".
  
  If File( cArcName )
  
     HB_FNameSplit( cArcName, , , @cExt )

     If !Empty( cExt := Upper( cExt ) )

        If ( Left( cExt, 1 ) == '.' )
           cExt := Substr( cExt, 2 )
        Endif
        
        If ( cExt == 'ZIP' )
           
           // ������ ZIP �������������� ������������ ����������.
           
           // !!! ����� � ������ � ���������� � ����� ���������� ZIP �� �����������.
           // ����� ��������������� 7-Zip

           If HB_UnZipFile( cArcName,,,, TEMP_FOLDER, cChain )

              // ����������� � Zip-������ ����� ����������� ������ ������, �������
              // ���� ���������������.

              cChain := Slashs( cChain )

              // ��������� ��������������� ��������� ���������, ������� � ����������
              // � ������� ����������� ���� (��� ������������� - � �������).
              
              // !!! ������ � ������ �� �����������.
           
              ShowFile( cChain )
           
              If !Empty( nVal := At( '\', cChain ) )
                 
                 cChain := Left( cChain, ( nVal - 1 ) )
                 
                 If HB_DirExists( TEMP_FOLDER + cChain )
                    DirRemove( TEMP_FOLDER + cChain )
                 Endif
                 
              Endif
              
           Endif
                      
        Else
        
           // ��������� 7-Zip
         
           If !Empty( cOSPaths )
              cSavePath := GetEnv( 'PATH' )
              SetEnvironmentVariable( 'PATH', cOSPaths )
           Endif

           cCommand += ( ' E -y -o' + TEMP_FOLDER + ' "' + cArcName + '" "' + cChain + '"' )
           
           Execute file ( cCommand ) Wait Hide
             
           If !Empty( cSavePath )
              SetEnvironmentVariable( 'PATH', cSavePath )
           Endif

           cChain := Slashs( cChain )
           
           // ����� ��������� �������� ����� ������ �� ����� �����.
           
           If !Empty( nVal := ( RAt( '\', cChain ) ) )
              cChain := Substr( cChain, ( nVal + 1 ) )
           Endif
           
           ShowFile( cChain )
                      
        Endif
        
     Endif
  
  Endif
  
Endif

Return

****** End of OpenObj ******


/******
*
*       Slashs( cPath ) --> cPath
*
*       ��������� ������������ ���������, ������������ �
*       �������, �� ���������
*
*/

Static Function Slashs( cPath )

If !Empty( At( '/', cPath ) )
   cPath := StrTran( cPath, '/', '\' )
Endif

Return cPath

****** End of Slashs ******


/******
*
*       ShowFile( cChain )
*
*       ������� ����������� �� ������ ����.
*       ����� ���������� ��������� ���� ���������.
*
*/

Static Procedure ShowFile( cChain )
Local cExt, ;
      cApp, ;
      nPos

// ���� � ���������� ����� ����� ���������� ����� ���� (���������� � ������),
// ���������� ���������� �� ��.

If ( ( nPos := RAt( '\', cChain ) ) > 0 )
   cChain := Substr( cChain, ( nPos + 1 ) )
Endif

If File( TEMP_FOLDER + cChain  )

   HB_FNameSplit( cChain, , , @cExt )
                  
   // ���������� ��������������� ��������� � ������� � ��� ����.
   // ���� ��������� �� ����� ������������, ����������� ������
   // ��������� ����������� ���� (��� �������, ����� ���������
   // ���������, � ������� ����� ����������� ��� �����).
                  
   If !Empty( cApp := GetOpenCommand( cExt ) )
      Execute file ( cApp + ' "' + TEMP_FOLDER + cChain + '"' ) Wait
   Else
      Execute file ( TEMP_FOLDER + cChain ) Wait
   Endif

   Erase( TEMP_FOLDER + cChain )
                    
Endif

Return

****** End of ShowFile ******


/******
*
*       GetOpenCommand( cExt )
*
*       ����������� ���������, ��������� � �����������.
*
*/

Static Function GetOpenCommand( cExt )
Local oReg       , ;
      cVar1      , ;
      cVar2 := '', ;
      nPos

If !IsChar( cExt )
   Return ''
Endif

// ������� ��������. � HKEY_CLASSES_ROOT ���� �����, �������������� �����������
// ���������� (� ������� ������) � ���������� ������������ ���� ����� (��������
// "(�� ���������)". ��������, ��� ���������� "jpg" ���� HKEY_CLASSES_ROOT\.jpg
// � �������� ��� ���������� - "jpegfile".
// � ���� �� ����� HKEY_CLASSES_ROOT ���� ������ ������� ���������, ��������� �
// ���� ����� ����� (HKEY_CLASSES_ROOT\<��� ����������>\shell\open\command)
// ��������, HKEY_CLASSES_ROOT\jpegfile\shell\open\command
// � �������� ��������� "(�� ���������)" ��������� ������� �������� ����� ����
// �����: "C:\\Program Files\\Internet Explorer\\iexplore.exe\" -nohome

If ( !Left( cExt, 1 ) == '.' )
   cExt := ( '.' + cExt )
Endif

oReg  := TReg32() : New( HKEY_CLASSES_ROOT, cExt, .F. )
cVar1 := RTrim( StrTran( oReg : Get( Nil, '' ), Chr( 0 ), ' ' ) )   // �������� ����� "(�� ���������)"
oReg : Close()

If !Empty( cVar1 )

   oReg  := TReg32() : New( HKEY_CLASSES_ROOT, ( cVar1 + '\shell\open\command' ), .F. )
   cVar2 := RTrim( StrTran( oReg : Get( Nil, '' ), Chr( 0 ), ' ' ) )  // �������� ����� "(�� ���������)"
   oReg : Close()

   // ��������� �������� �� �������� ���������� ��������������� ���������
   
   If ( nPos := RAt( ' %1', cVar2 ) ) > 0        // �������� �� ����������� ��������� (�������)
      cVar2 := SubStr( cVar2, 1, nPos )
      
   Elseif ( nPos := RAt( '"%', cVar2 ) ) > 0     // ��������� ���� "%1", "%L" � �.�. (� ���������)
      cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )
      
   Elseif ( nPos := RAt( '%', cVar2 ) ) > 0      // ��������� ���� "%1", "%L" � �.�. (��� �������)
      cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )
      
   Elseif ( nPos := RAt( ' /', cVar2 ) ) > 0     // ������� "/"
      cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )
      
   Endif

Endif

Return RTrim( cVar2 )

****** End of GetOpenCommand ******



#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

// ������ ������� ���� � ����������� Harbour/xHarbour
// Harbour - VWN_SETENVIRONMENTVARIABLE � CONTRIB\HBWHAT\whtmisc.c 
// xHarbour - SETENVIRONMENTVARIABLE � CONTRIB\WHAT32\SOURCE\_winmisc.c 

HB_FUNC_STATIC( SETENVIRONMENTVARIABLE )
{
   hb_retl( SetEnvironmentVariableA( hb_parcx( 1 ),
                                     hb_parcx( 2 )
                                     ) );
}

#pragma ENDDUMP
