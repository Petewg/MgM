/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Joint usage of FreeImage & SQLite3 demo
 * (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "Directry.ch"
#include "FreeImage.ch"
#include "HBSQLit3.ch"
#include "MiniGUI.ch"

#define DB_NAME            'PicBase.s3db'   // ������� ����

#define WM_PAINT	     15             // ��� �������������� ����������� ����

// ������� ������ ������������ ����������� �����������

// ����������

#define FI_TOP                5
#define FI_LEFT             260
#define FI_BOTTOM           470
#define FI_RIGHT            765

// �������

#define FI_WIDTH            ( FI_RIGHT - FI_LEFT )
#define FI_HEIGHT           ( FI_BOTTOM - FI_TOP )



Static lCreateBase := .T.   // �������: ������������� ��������� ����� ����
Static aParams              // ������ ������� ���������� 


/******
*
*       ������������ ��������, ���������� � ����������� ������ 
*       � � ���� SQLite
*
*/

Procedure Main

aParams := { 'StartDir'  => GetCurrentFolder(), ;        // ������� �������
             'pDB'       => nil               , ;        // ���������� ����
             'ReadFiles' => .T.               , ;        // ���������� ������ ������
             'SavePos'   => .F.               , ;        // ��������� ������� � ������ ������ 
             'Reload'    => .T.                 ;        // ������� ������������� ���������� ��
           }

If Empty( aParams[ 'pDB' ] := OpenBase() )
   MsgStop( "Can't open/create " + DB_NAME, "Error" )
   Quit
Endif

FI_Initialise()          // ������������� ���������� FreeImage

Set font to 'Tahoma', 9

Define window wMain                   ;
       At 0, 0                        ;
       Width 780                      ;
       Height 525                     ;
       Title 'FreeImage & SQLite3 Usage Demo' ;
       NoMaximize                     ;
       NoSize                         ;
       Icon 'main.ico'                ;
       Main                           ;
       On Release FI_DeInitialise()   ;
       On Paint ShowMe()

   // ShowMe() - ��������� ������ �����������. � �������� ���� � �����
   // ������� ������ � On paint. ��� �������� ��������� ����������
   // �������� ���� ��� ������ �����������. �������������� ��������
   // On init ShowMe() �������� � �������� ���� ��������� ��� �������.
   
   Define tab tbData ;
          at 5, 5    ;
          Width 250  ;
          Height 470 ;
          On Change SwitchTab()
          
      Page 'Files'
      
         @ 32, 5 Grid grdFiles   ;
                 Width 235       ;
                 Height 340      ;
                 Widths { 200 }  ;
                 NoHeaders       ;
                 On Change ShowMe()

         @ 385, 5 ButtonEx btnChDir       ;
                  Caption 'Change folder' ;
                  Width 235               ;
                  Picture 'DIR'           ;
                  Action ChangeFolder()

         @ 430, 5 ButtonEx btnAdd        ;
                  Caption 'Copy to base' ;
                  Width 235              ;
                  Picture 'COPY'         ;          
                  Action AddToBase()

      End Page
      
      Page 'Records'

        @ 32, 5 Grid grdRecords          ;
                Width 235                ;
                Height 340               ;
                Widths { 50, 180 }       ;
                Headers { 'ID', 'Name' } ;
                On Change ShowMe()      

         @ 385, 5 ButtonEx btnDelete      ;
                  Caption 'Delete record' ;
                  Width 235               ;
                  Picture 'DELETE'        ;
                  Action DelRecord()

         @ 430, 5 ButtonEx btnSave       ;
                  Caption 'Save to file' ;
                  Width 235              ;
                  Picture 'SAVE'         ;
                  Action SaveToFile()
      
      End Page    
      
   End Tab

   Define StatusBar
      StatusItem aParams[ 'StartDir' ]
      StatusItem 'Exit Alt+X' Width 70
   End StatusBar
             
End window

On Key Alt+X of wMain Action ReleaseAllWindows()

ListFiles()     // ��������� ������ ������

Center window wMain
Activate window wMain

Return

****** End of Main ******


/*****
*
*       OpenBase() --> pHandleDB
*
*       ��������/�������� ��
*
*/

Static Function OpenBase
Local lExistDB  := File( DB_NAME )                     , ;
      pHandleDB := SQLite3_Open( DB_NAME, lCreateBase ), ;
      cCommand

If !Empty( pHandleDB )
   
   // ��� auto_vacuum = 0 ����� ���������� �������� �������� ������ ������ ����� �� �� ����������.
   // ������������ ����� ���������� ��� "���������" � ����� �������� �������������� � 
   // ����������� ��������� ���������� ����� �������.
   // ��� ���������� ������� ����� ���������� ��������� ������� Vacuum
   
   SQLite3_Exec( pHandleDB, 'PRAGMA auto_vacuum = 0' )

   If !lExistDB
      
      // ������ �������
    
      cCommand := 'Create table if not exists Picts( Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, Image BLOB );'
      SQLite3_Exec( pHandleDB, cCommand )

   Endif
   
Endif

Return pHandleDB

****** End of OpenBase ******


/******
*
*      SwitchTab()
*
*      ��������� ������������ ����� �������� (�����-������)
*
*/

Static Procedure SwitchTab
Local nValue := wMain.tbData.Value

// ��������� ��������� ��������

If ( nValue == 1 )
   ListFiles()
   wMain.grdFiles.SetFocus       // ������� ������
   
ElseIf( nValue == 2 )

   ListRecords()
   wMain.grdRecords.SetFocus     // ������� �������
   
Endif

RefreshMe()

Return

****** End of SwitchTab ******


/******
*
*       ListFiles()
*
*       ������������ ������ ����������� ������
*
*/
    
Static Procedure ListFiles
Local nPos   := wMain.grdFiles.Value, ; 
      aFiles := {}

If aParams[ 'ReadFiles' ]
 
   // �� �������������� FreeImage ����� ������ ���������� ������ �����

   AEval( Directory( aParams[ 'StartDir' ] + '\*.jpg'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.jpeg' ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.png'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.gif'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.bmp'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.ico'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )

   wMain.grdFiles.DeleteAllItems

   If !Empty( aFiles )
   
      ASort( aFiles, { | x, y | x < y } )       // ��������� ������

      wMain.grdFiles.DisableUpdate              // ������ �� ���������� ����� (��������� ��� ������� ���������� ����������� ������ � �����)

      AEval( aFiles, { | elem | wMain.grdFiles.AddItem( { elem } ) } )

      wMain.grdFiles.EnableUpdate               // ��������� �������� ����������� ��������� � �����

      // ��� ���������� ������ �������� �������� ������� ��������� ���������
   
      If !aParams[ 'SavePos' ]    
         
         wMain.grdFiles.Value := 1
         wMain.grdFiles.SetFocus
         
         aParams[ 'SavePos' ] := .T.
   
      Else
      
         If ( nPos > 0 )
            wMain.grdFiles.Value := nPos
         Endif
               
      Endif
      
   Endif
   
   aParams[ 'ReadFiles' ] := .F.

Endif

Return

****** End of ListFiles ******


/******
*
*       ListRecords()
*       
*       ���������� ������� ��������� � �� �������
*
*/

Static Procedure ListRecords
Local aData, ;
      aItem

If aParams[ 'Reload' ]

   wMain.grdRecords.DeleteAllItems

   aData := Do_SQL_Query( 'Select Id, Name from Picts Order by Name;' )

   If !Empty( aData )
   
      For each aItem in aData
         // � ������� ������ 2 ����: ������������� � ��� �����
         wMain.grdRecords.AddItem( { aItem[ 1 ], aItem[ 2 ] } )
      Next
   
      wMain.grdRecords.Value := 1
   
   Endif

   // ���������� ���������������� ������ �������, ��������� � ��
   // ������� ��������������� ��� ������������� ��� ����� ���������� �
   // �������� �������
   
   aParams[ 'Reload' ] := .F.
   
   If ( wMain.grdRecords.ItemCount > 0 )
      wMain.btnDelete.Enabled := .T.
   Else
      wMain.btnDelete.Enabled := .F.
   Endif
      
Endif

Return

****** End of ListRecords ******


/******
*
*       ChangeFolder()
*
*       ����� �������� ��������
*
*/

Static Procedure ChangeFolder
Local cFolder := GetFolder( 'Select folder', aParams[ 'StartDir' ] )

If !Empty( cFolder )

   aParams[ 'StartDir'  ] := cFolder
   aParams[ 'ReadFiles' ] := .T.
   aParams[ 'SavePos'   ] := .F.
   
   ListFiles()
   
   wMain.StatusBar.Item( 1 ) := aParams[ 'StartDir' ]
   
   ShowMe()
   
Endif

Return

****** End of ChangeFolder ******


/******
*
*       ShowMe()
*
*       ����� �����������
*
*/

Static Procedure ShowMe
Static nHandleImg
Local nTabValue := wMain.tbData.Value, ;
      nTop      := FI_TOP            , ;
      nLeft     := FI_LEFT           , ;
      nBottom   := FI_BOTTOM         , ;
      nRight    := FI_RIGHT          , ;
      nPos                           , ; 
      cFile                          , ;
      cImage                         , ;
      pps                            , ;
      hDC                            , ;
      nWidth                         , ;
      nHeight                        , ;
      cID                            , ;
      aData                          , ;
      nKoeff                         , ;
      nHandleClone

If !( nHandleImg == nil )
   
   FI_Unload( nHandleImg )
   
   // ����� ����������� �������� ������� ����� �������� �������� � 
   // ��������� ��������. ������� ����� �������� �������, �������
   // � "����������������".
   // ������������ ������������ �� �� ���� ���������, � ������ �����,
   // � ������� ������������ ��������.
     
   // �������� �������: ��� ����������� ���� �� ������� ������ �� �����������
   // �������� ���������.
   
   InvalidateRect( Application.Handle, 1, FI_LEFT, 0, ( wMain.Width - 1 ), ( wMain.Height - 15 ) )
      
   nHandleImg := nil
   
Endif

If ( nTabValue == 1 )
   nPos := wMain.grdFiles.Value
Else
   nPos := wMain.grdRecords.Value
Endif

If Empty( nPos )
   Return
Endif

   // ������� �������� �� ������ ����������, � ����������� �� ������� �������
   
   If ( nTabValue == 1 )
   
      // �� �����
      
      If !File( cFile := aParams[ 'StartDir' ] + '\' + wMain.grdFiles.Item( nPos )[ 1 ] )
         Return
      Endif

      cImage := MemoRead( cFile )         // �������� � ������
      
  Else
  
     cID := wMain.grdRecords.Item( nPos )[ 1 ]
     aData := Do_SQL_Query( 'Select Image from Picts Where Id = ' + cId + ';' )

     If !Empty( aData )
        cImage := aData[ 1, 1 ]
     Else
        Return
     Endif
  
  Endif
   
If Empty( cImage )
   Return
Endif

// ��� �������� ������� ��������������� �� �����
// nHandleImg := FI_Load( FI_GetFileType( cFile ), cFile, 0 )

// ������� �������������� ����������� � ������ � ��������� ������

nHandleImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cImage, Len( cImage ) ), cImage, 0 )

// ������������ ������ �����������

nWidth  := FI_GetWidth( nHandleImg )
nHeight := FI_GetHeight( nHandleImg )

// FreeImage ����� ��������� ������� ����������� � �������� �������, ��
// ��� ���� ����� ���������. ������� ��� ������� �������� ������������
// ����������� ���������� (���������������).

// ! ��������
// ������ � ��������� ��������� ������� �������� ��������� ����� �����������

If ( ( nHeight > FI_HEIGHT ) .or. ( nWidth > FI_WIDTH )  )

   // ����������� ������� �� ����������� ���������� �������.
   // ����������� ����������� ���������������.
   
   If ( ( nHeight - FI_HEIGHT ) > ( nWidth - FI_WIDTH ) )
      
      // ���������� ������� �� ������. ������ ����������� �� �����
      // ���������.
      
      nKoeff := ( FI_HEIGHT / nHeight )
   Else
      nKoeff := ( FI_WIDTH / nWidth )
   Endif
   
   nHeight := Round( ( nHeight * nKoeff ), 0 )
   nWidth  := Round( ( nWidth  * nKoeff ), 0 )
   
   nHandleClone := FI_Clone( nHandleImg )
   FI_Unload( nHandleImg )
   
   nHandleImg := FI_Rescale( nHandleClone, nWidth, nHeight, FILTER_BICUBIC )
   FI_Unload( nHandleClone )
   
Endif

// ���������������� �����������. ���� ������ ������ �������� �������
// ������, ������� ������������ �� ���� ���.

If ( nWidth < FI_WIDTH )
   nLeft  += Int( ( FI_WIDTH - nWidth ) / 2 )
   nRight := ( nLeft + nWidth )
Endif

If ( nHeight < FI_HEIGHT )
   nTop    += Int( ( FI_HEIGHT - nHeight ) / 2 )
   nBottom := ( nTop + nHeight )
Endif

// ����� �����������

hDC := BeginPaint( Application.Handle, @pps )

FI_WinDraw( nHandleImg, hDC, nTop, nLeft, nBottom, nRight )

EndPaint( Application.Handle, pps )

Return

****** End of ShowMe ******


/******
*
*       RefreshMe()
*
*       ����������� �����������
*
*/

Static Procedure RefreshMe
   
	DO EVENTS

	SendMessage( _HMG_MainHandle, WM_PAINT, 0, 0 )

Return

****** End of RefreshMe ******


/******
*
*       Do_SQL_Query( cQuery ) --> aResult
*
*       ���������� �������
*
*/

Static Function Do_SQL_Query( cQuery )
Local pStatement := SQLite3_Prepare( aParams[ 'pDB' ], cQuery ), ;
      aResult    := {}                                         , ;
      aTmp                                                     , ;
      nColAmount                                               , ;
      Cycle                                                    , ;
      nType

If !Empty( pStatement )

   Do while ( SQlite3_Step( pStatement ) == SQLITE_ROW )
   
      If ( ( nColAmount := SQLite3_Column_Count( pStatement ) ) > 0 )
      
         aTmp := Array( nColAmount )
         AFill( aTmp, '' )
      
         For Cycle := 1 to nColAmount
            
            nType := SQLite3_Column_Type( pStatement, Cycle )
            
            Do case
               Case ( nType == SQLITE_NULL )
               Case ( nType == SQLITE_FLOAT )
               Case ( nType == SQLITE_INTEGER )
                  aTmp[ Cycle ] := LTrim( Str( SQLite3_Column_Int( pStatement, Cycle ) ) )
                  
               Case ( nType == SQLITE_TEXT )
                  aTmp[ Cycle ] := SQLite3_Column_Text( pStatement, Cycle )
                  
               Case ( nType == SQLITE_BLOB )
                  aTmp[ Cycle ] := SQLite3_Column_Blob( pStatement, Cycle )
                  
            Endcase
            
         Next
         
         AAdd( aResult, aTmp )
          
      Endif
      
   Enddo
   
   SQLite3_Finalize( pStatement )
   
Endif
                
Return aResult

****** End of Do_SQL_Query ******


/******
*
*       AddToBase()
*
*       ���������� ������� � ����
*
*/

Static Procedure AddToBase
Local nPos       := wMain.grdFiles.Value, ;
      cFile                             , ;
      cImage                            , ;
      pStatement

If !Empty( nPos )

   cFile := wMain.grdFiles.Item( nPos )[ 1 ]
   
   If !File( aParams[ 'StartDir' ] + '\' + cFile )
      Return
   Endif
   
Else
   Return
      
Endif

pStatement := SQLite3_Prepare( aParams[ 'pDB' ], 'Insert into Picts( Name, Image ) Values( :Name, :Image )' )

If !Empty( pStatement )
   
   cImage := SQLite3_File_to_buff( aParams[ 'StartDir' ] + '\' + cFile )

   If ( ( SQLite3_Bind_text( pStatement, 1, cFile   ) == SQLITE_OK ) .and. ;
        ( SQLite3_Bind_blob( pStatement, 2, @cImage ) == SQLITE_OK )       ;
      )
      
     If ( SQLite3_Step( pStatement ) == SQLITE_DONE )
        aParams[ 'Reload' ] := .T.
        MsgInfo( ( 'File' + CRLF + cFile + CRLF + 'is copied in a base.' ), ;
                 'Success', , .F., .F. )
     Endif 

   Endif

   SQLite3_Clear_bindings( pStatement )
   SQLite3_Finalize( pStatement )

Endif

wMain.grdFiles.SetFocus

Return

****** End of AddToBase ******


/******
*
*       DelRecord()
*
*       �������� ������ �� ����
*
*/

Static Procedure DelRecord
Local nPos     := wMain.grdRecords.Value, ;
      cID                               , ;
      cCommand                          , ;
      nCount

If !Empty( nPos )

  If MsgYesNo( 'Delete current record?', 'Confirm', .T., , .F., .F.  )

     cID := wMain.grdRecords.Item( nPos )[ 1 ]
     cCommand := ( 'Delete from Picts Where Id = ' + cId + ';' )

     If ( SQLite3_Exec( aParams[ 'pDB' ], cCommand ) == SQLITE_OK )

        // ��� ���������� ������� ����� �� ���������� ��������� �������
        // Vacuum. �� ��� ������� �� �� ��� ����� �������������
        // ��������� �����.
        
        If ( SQLite3_exec( aParams[ 'pDB' ], 'Vacuum' ) == SQLITE_OK )
        
           // ���������� ������
     
           aParams[ 'Reload' ] := .T.
           ListRecords()

           // �� �����������, ��������� �������� �� ��� �� �������
     
           nCount := wMain.grdRecords.ItemCount
     
           nPos := Iif( ( nPos >= nCount ), nCount, nPos )
           wMain.grdRecords.Value := nPos

           RefreshMe()
           
        Endif
        
     Endif
     
  EndIf

Endif

wMain.grdRecords.SetFocus

Return

****** End of DelRecord ******


/******
*
*       SaveToFile()
*
*       ������� ������� �� �� � ����
*
*/

Static Procedure SaveToFile
Local nPos       := wMain.grdRecords.Value, ;
      cID                                 , ;
      aData                               , ;
      cImage                              , ;
      cFile                               , ;
      cExt                                , ;
      nHandleImg                          , ;
      nFIF                                , ;
      nFormat                             , ;
      lSuccess

If !Empty( nPos )

   cID   := wMain.grdRecords.Item( nPos )[ 1 ]
   cFile := wMain.grdRecords.Item( nPos )[ 2 ]
   aData := Do_SQL_Query( 'Select Image from Picts Where Id = ' + cId + ';' )
   
   If Empty( aData )
      Return
   Endif

   cImage := aData[ 1, 1 ]

   // �.�. �� ���������� ����� ���������� ����� ������ �����������,
   // �� ��� �������� ���������� ���������� ���� ��������� ���������� �����
   // (�� ��������� ������������ ��� ������� ������)

   cFile := PutFile( { { 'JPG files', '*.jpg' }, { 'JPEG files', '*.jpeg' }, ; 
                       { 'PNG files', '*.png' }, { 'GIF files' , '*.gif'  }, ;
                       { 'BMP files', '*.bmp' }, { 'ICO files', '*.ico'   }  ;
                     }                                                     , ;
                     'Save image'                                          , ;
                     aParams[ 'StartDir' ]                                 , ;
                     .T.                                                   , ;
                     cFile                                                   ;
                   )
                   
   If Empty( cFile )
      Return
      
   Else
      If File( cFile )
         If !MsgYesNo( ( 'File' + CRLF + ;
                         cFile  + CRLF + ;
                         'already exist. Rewrite it?' ;
                       ), 'Confirm', .T., , .F., .F.  )
            Return
         Endif
      Endif
   
   Endif

   nHandleImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cImage, Len( cImage ) ), cImage, 0 )
   
   If Empty( nHandleImg )
      Return
   Endif

   // �� ���������� ����� ���������� ������������� ����������� �
   // ��������� ��� �������� ����������
   
   HB_FNameSplit( cFile, , , @cExt )
   cExt := Lower( cExt )
   
   Do case
      Case ( cExt == '.png' )
        nFIF    := FIF_PNG            // ������������� ����������� ��� �����/������
        nFormat := PNG_DEFAULT 

      Case ( cExt == '.gif' )
        nFIF    := FIF_GIF
        nFormat := GIF_DEFAULT 
         
      Case ( cExt == '.bmp' )
        nFIF    := BMP_DEFAULT
        nFormat := GIF_DEFAULT 

      Case ( cExt == '.ico' )
        nFIF    := FIF_ICO
        nFormat := ICO_DEFAULT 

      Otherwise
      
        // �� ��������� JPG ��� JPEG
        nFIF    := FIF_JPEG
        nFormat := JPEG_DEFAULT 

   Endcase
 
   lSuccess := FI_Save( nFIF, nHandleImg, cFile, nFormat )
   
   If !lSuccess
      MsgStop( ( "Can't save a file" + HB_OSNewLine() + cFile ), 'Error', , .F., .F. )
   Endif
   
   FI_Unload( nHandleImg )

   // ���� ������ ��������� �������, ���������� ���������� ������ ������.
   // ������� ��������� �� �������� (��� ���������), ���� ������ ����������
   // �� ������ ������ � ����� ����� ���������� ������� ���� � ������ ���
   // ��������� � ����������������� ������.
   
   If lSuccess
      aParams[ 'ReadFiles' ] := .T.
   Endif
   
Endif

Return

****** End of SaveToFile ******
