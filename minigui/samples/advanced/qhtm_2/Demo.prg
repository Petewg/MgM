/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Joint usage of QHTM & SQLite3 demo
 * (c) 2009 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

/*
������������ ������������� ������� ������������ ���������� QHTM (freeware version)

������������ ��������� �������:
- ����������� DLL QHTM (QHTM_Init(), QHTM_End())
- �������� �������� QHTM; �������� ���������� �� ����������, ���������� ����� (@...QHTM)
- ��������� �������� ��������� QHTM � ���������� �� �����������
- ��������� ��������� � �������� �������� QHTM (QHTM_GetTitle(), QHTM_GetSize())
- ������������� MsgBox() � ����� QHTM (QHTM_MessageBox())
- ������������� ����������� ��������� � ����� QHTM (QHTM_EnableCooltips())
- �������� HTML ���� �������� QHTM
- ������������� ������ � ������ �������� QHTM ��� ���������� ���������� ��������
- ���������� ���-�������� �� ������� (QHTM_SetHTMLButton())
- ���������� ���-���� � ��������� ����������

������� QHTM (���������):
QHTM_Init( [ cDllName ] )
QHTM_End() 
QHTM_MessageBox( cMessage [,cTitle ] [,nFlags ] ) 
QHTM_LoadFile( handle, cFileName ) 
QHTM_LoadRes( handle, cResourceName ) 
QHTM_AddHtml( handle, cText ) 
QHTM_GetTitle( handle ) 
QHTM_GetSize( handle ) 
QHTM_EnableCooltips()
QHTM_SetHTMLButton( handle )
QHTM_PrintCreateContext() --> hContext 
QHTM_PrintSetText( hContext,cHtmlText ) 
QHTM_PrintSetTextFile( hContext,cFileName ) 
QHTM_PrintSetTextResource( hContext,cResourceName ) 
QHTM_PrintLayOut( hDC,hContext ) --> nNumberOfPages 
QHTM_PrintPage( hDC,hContext,nPage ) 
QHTM_PrintDestroyContext( hContext ) 

QhtmFormProc() - ��������������� ��� ��������� ��������� ���������� �����
                 � ���-�����
*/

#include "Directry.ch"
#include "HBSQLit3.ch"
#include "i_qhtm.ch"
#include "MiniGUI.ch"
#include "winprint.ch"


// ����������� WinAPI

#define WM_NOTIFY	             78
#define WM_CTLCOLORSTATIC           312


// ��� ��������� ���� ��������� ����
 
#define WS_EX_CLIENTEDGE            512   // ����������, ��� ���� ����� ����� � ����������� �����.
#define WS_EX_STATICEDGE           8192   // ���� � �������� ������. ���� ����� ������ ������������  
                                          // ��� ��������� ����������, �� ����������� ���� ������. 

#define WS_FLAT                    ( WS_EX_CLIENTEDGE + WS_EX_STATICEDGE )

// ����� ������ � �������� ������������� �������� � ������������� ���������� ��������� �������.

#define MB_YESNO                      4

#define IDYES                         6       // � ������� "��-���" ������ ������ "��"
#define MB_DEFBUTTON2               256       // 2-� ������ � ������� ������� �� ���������


#define DB_NAME            'PicBase.db'       // ������� ����
#define TMP_SOURCE_TXT     'Temp.txt'         // ��������� ���� ��� ��������� ���� ��������

// ������� ������ ������������ ����������� �����������

// ������� ���������

#define LOGO_TOP                      5
#define LOGO_LEFT                     5
#define LOGO_HEIGHT                 130

// ���� �������

#define TB_TOP                      ( LOGO_TOP +  LOGO_HEIGHT + 5 )
#define TB_LEFT                     LOGO_LEFT
#define TB_WIDTH                    260

// ������� ������ ������

#define DATA_TOP                    TB_TOP
#define DATA_LEFT                   ( TB_LEFT + TB_WIDTH + 5 )

// �������������� �������������� ��������� QHTM

#define HWND_HTMLDATA               GetControlHandle( 'HtmlData', 'wMain' )
  
// ������� (��������������� ������)

#define ID_COMMAND                  'COMMAND:'
#define ID_COMMAND_EXPLORER         ( ID_COMMAND + 'EXPLORER'     )  // ������ Explorer
#define ID_COMMAND_CHANGEFOLDER     ( ID_COMMAND + 'CHANGEFOLDER' )  // ������� ������� �����
#define ID_COMMAND_VIEWIMAGE        ( ID_COMMAND + 'VIEWIMAGE'    )  // ������������� �������� �������


// ������� �����, ������������ � ����������

#define HTML_PRINT_DEMO             'Files\QHTM.html'       // ������������ ������
#define HTML_SUBMIT_DEMO            'Files\Index.htm'       // ������������ ������������� ����


Static aParams                      // ������ ������� ���������� 


/******
*
*       ������������ ��������, ���������� � ����������� ������ 
*       � � ���� SQLite
*
*/

Procedure Main
Local cHTML := ''

aParams := { 'StartDir'    => GetSpecialFolder( CSIDL_MYPICTURES ), ;        // ������� "��� �������"
             'pDB'         => nil                                 , ;        // ���������� ����
             'ReadFiles'   => .T.                                 , ;        // ���������� ������ ������
             'SavePos'     => .F.                                 , ;        // ��������� ������� � ������ ������ 
             'Reload'      => .T.                                 , ;        // ������� ������������� ���������� ��
             'TmpDir'      => ( GetTempFolder() + '\' )           , ;        // ������� ��������� ������
             'TmpFilePict' => ''                                    ;        // ��������� ���� ������� �� ���� 
           }

If Empty( aParams[ 'pDB' ] := OpenBase() )
   MsgStop( "Can't open/create " + DB_NAME, 'Error' )
   Quit
Endif

If !QHTM_Init()
   MsgStop( ( 'Library QHTM.dll not loaded.' + CRLF + ;
              'Program terminated.'                   ;
            ), 'Error' )
   Quit
Endif

Set century on
Set date German

Set font to 'Tahoma', 9
Set default icon to 'MAIN'

Set Events function to MyEvents

// ��������� ������������� HTML � ������ ����������� ���������. ������� ������
// ���������� �� ����������� ��������� ����.
// ! ������������� ���� ������� ����������� ������� SET TOOLTIP 

QHTM_EnableCooltips()

Define window wMain                      ;
       At 0, 0                           ;
       Width 780                         ;
       Height 565                        ;
       Title 'QHTM & SQLite3 Usage Demo' ;
       Main                              ;
       On init ReSize()                  ;
       On maximize ReSize()              ;
       On size ReSize() 

   // ������� ����
   
   Define main menu
   
     Define Popup 'File'
       MenuItem 'Change folder' Action ChangeFolder()
       Separator
       MenuItem 'Exit Alt+X'    Action AppDone()
     End Popup

     Define Popup 'View'
       MenuItem 'Less save to disk' Action SetMarker() ;
                                    Name pdLess        ;
                                    Checked
     End Popup
        
     Define Popup 'Record'
       MenuItem 'Add files to base' Action AddToBase()
       MenuItem 'Delete record'     Name pdDelete      ;
                                    Action DelRecord() ;
                                    Disabled
     End Popup
     
     Define Popup 'Tests'
       MenuItem 'Print'    Action DemoPrint()
       Separator
       MenuItem 'Web-form' Action DemoSubmit()
     End Popup
       
     Define Popup 'Info'
       MenuItem 'Get HTML title' Action GetHTMLTitle() 
       MenuItem 'Get sizes'      Action GetHTMLSize()
     End Popup

   End Menu

   @ LOGO_TOP, LOGO_LEFT QHTM HtmlLogo of wMain ;
     Resource 'TOPBAR'                          ;
     Width 760                                  ;
     Height LOGO_HEIGHT                         ;
     Border

   // ������ ������/�������

   Define tab tbData         ;
          at TB_TOP, TB_LEFT ;
          Width TB_WIDTH     ;
          Height 105         ;
          On change SwitchTab()
          
      Page 'Files'
      
        @ 32, 5 Grid grdFiles           ;
                Width ( TB_WIDTH - 10 ) ;
                Height 360              ;
                Widths { 200 }          ;
                NoHeaders               ;
                On Change ShowMe()      ;
                Tooltip ( '<img src="res:INFO" align="right">List files in <br><font color="blue"><b>' + ;
                          aParams[ 'StartDir' ] + '</font></b>' )

      End Page
      
      Page 'Records'

        @ 32, 5 Grid grdRecords          ;
                Width ( TB_WIDTH - 10 )  ;
                Height 360               ;
                Widths { 50, 180 }       ;
                Headers { 'ID', 'Name' } ;
                On Change ShowMe()       ;
                Tooltip ( '<img src="res:INFO">List of pictures, stored in a base' )

      End Page    

   End Tab

   @ DATA_TOP, DATA_LEFT QHTM HtmlData of wMain ;
     Value cHTML                                ;
     Width 505                                  ;
     Height 105                                 ;
     Border

   Define context menu control HtmlData
       MenuItem 'View HTML source' action ViewSource()
   End Menu 

   Define StatusBar
      StatusItem aParams[ 'StartDir' ] Action ChangeFolder() Tooltip 'Current folder'
      StatusItem 'Exit Alt+X without confirm' Width IF(IsXPThemeActive(), 72, 68) Action AppDone() Tooltip 'Click here for exit with confirmation'
   End StatusBar
             
End window

On Key Alt+X of wMain Action AppDone( .T. )

ListFiles()     // ��������� ������ ������
ChangeStyle( GetControlHandle( 'tbData', 'wMain' ), WS_FLAT, , .T. )

Center window wMain
Activate window wMain

Return

****** End of Main ******


/******
*
*       ReSize()
*
*       ���������� � ������������ �������� ��������� ��� ���������
*       ������� ����
*
*/

Static Procedure ReSize
Local nWidth   := ( wMain.Width - 2 * GetBorderWidth() )                                                   , ;
      nHeight  := ( wMain.Height - GetTitleHeight() - ( 2 * GetBorderHeight() ) - GetMenuBarHeight() - 20 ), ;
      nHeight1

nHeight1 := ( nHeight - DATA_TOP - 5 )

wMain.HtmlLogo.Width    := ( nWidth - 2 * LOGO_LEFT )
wMain.tbData.Height     := nHeight1
wMain.grdFiles.Height   := ( nHeight1 - 40 )
wMain.grdRecords.Height := ( nHeight1 - 40 )
wMain.HtmlData.Width    := ( nWidth - TB_LEFT - TB_WIDTH - 2 * LOGO_LEFT  )
wMain.HtmlData.Height   := nHeight1 

Return

****** End of ReSize ******
 

/******
*
*       AppDone( lForce )
*
*       ���������� ������
*
*/

Static Procedure AppDone( lForce )
Local cMsg       := ( '<img src="res:THINK" border="0" hspace="20">' + ;
                      '<font size=+4>  Are you sure that you <i><font color="red">really</font></i> want to <b>exit</b> ?   </font>' + ;
                      '<img src="res:TEAR" border="0" hspace="20">'    ;
                    )                                                , ;
      cTmpSource := ( aParams[ 'TmpDir' ] + TMP_SOURCE_TXT )

Default lForce to .F.

If Iif( !lForce, ( QHTM_MessageBox( cMsg, 'Confirm action' , ( MB_YESNO + MB_DEFBUTTON2 ) ) == IDYES ), .T. )

   QHTM_End()
   
   // �������� ��������� �������
   
   CleanTmpFile()
   
   If File( cTmpSource )
      Erase ( cTmpSource )
   Endif
   
   ReleaseAllWindows()
   
Endif

Return

***** End of AppDone *****


/******
*
*      SetMarker()
*
*      ��������� �������� �������� ���������� ����� �������
*
*/

Static Procedure SetMarker
Local lChecked := wMain.pdLess.Checked, ;
      nValue   := wMain.tbData.Value

lChecked := !lChecked
wMain.pdLess.Checked := lChecked

// ���� � ���� �������� ������ ����, ��������� ���������� ���������
 
If ( nValue == 2 )

   If lChecked
      // ������ ����� ��� ������ �������� �� ��������� ����. ������� ��������
      // �������
      CleanTmpFile() 
   Endif
   
   ShowMe()
   
Endif

Return

****** End of SetMarker ******


/******
*
*       CleanTmpFile()
*
*       �������� ���������� ����� �������, ������������ �� ����
*       ��� ������ � ����
*
*/

Static Procedure CleanTmpFile
Local cFile := ( aParams[ 'TmpDir' ] + aParams[ 'TmpFilePict' ] )

If !Empty( aParams[ 'TmpFilePict' ] )
   If File( cFile )
      Erase ( cFile )
   Endif
Endif

Return

****** End of CleanTmpFile ******
 

/*****
*
*       OpenBase() --> pHandleDB
*
*       ��������/�������� ��
*
*/

Static Function OpenBase
Local lExistDB  := File( DB_NAME )             , ;
      pHandleDB := SQLite3_Open( DB_NAME, .T. ), ;
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

CleanTmpFile()

// ��������� ��������� ��������

If ( nValue == 1 )              // ������� ������ 
   ListFiles()
   wMain.pdDelete.Enabled :=.F.
   wMain.grdFiles.SetFocus       
   
ElseIf( nValue == 2 )           // ������� �������
   ListRecords()
   wMain.pdDelete.Enabled :=.T.
   wMain.grdRecords.SetFocus     

Endif

ShowMe()

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
 
   // ���������� ������ ��������� ���� ������

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
   
Endif

Return

****** End of ListRecords ******


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
*       HTMLForFile( cFile ) --> cHTML
*
*       ������������ ������ ���-�������� ��� ������������� �����
*
*/

Static Function HTMLForFile( cFile )
Local cFullName := ( aParams[ 'StartDir' ] + '\' + cFile ), ;
      cHTML     := ''                                     , ;
      aFileInfo

aFileInfo := Directory( cFullName )

cHTML += ( '<html>' + ;
           '<title>Info for file</title>' + ; 
           '<body margintop=10 marginbottom=10 marginleft=10 marginright=10>' + ;
           CRLF + '<p>' + CRLF )
cHTML += ( '<IMG src="' + cFullName + '" ' + ;
           'align="left" hspace=20 vspace=20 border=0><br>' + CRLF )

// ���������� � ����� (CRLF ������������ �� �����������; ������ ���� ��������
// ������������� ��������� ���������� �����, �������� ��������� � �����
// MsgBox( cHTML ) )
               
cHTML += ( '<b><font size=+2>File: </font></b>' + cFile + CRLF )
cHTML += ( '<br><b><font size=+2>Size: </font></b>' + LTrim( Str( aFileInfo[ 1, F_SIZE ] ) ) + ' byte' + CRLF )
cHTML += ( '<br><b><font size=+2>Date: </font></b>' + DtoC( aFileInfo[ 1, F_DATE ] ) + CRLF )
cHTML += ( '<br><b><font size=+2>Time: </font></b>' + aFileInfo[ 1, F_TIME ] + CRLF )

cHTML += ( '</p>' + CRLF + '</body>' + CRLF + '</html>' )

Return cHTML

****** End of HTMLForFile ******


/******
*
*       HTMLForRec( cID, cName, cImage, lForce ) --> cHTML
*
*       ������������ ������ ���-�������� ��� ������ ��
*
*/

Static Function HTMLForRec( cID, cName, cImage, lForce )
Local lChecked  := wMain.pdLess.Checked                  , ;
      cFile := ( aParams[ 'TmpDir' ] + AllTrim( cName ) ), ;
      cHTML := ''

Default lForce to .F.    // �������������� ����� �����������

If ( !lChecked .or. lForce )
   CleanTmpFile()
   MemoWrit( cFile, cImage )
   aParams[ 'TmpFilePict' ] := AllTrim( cName )   // �������� ��� ���������� ����� (��� ����������� �������)
Endif

cHTML += ( '<html>' + ;
           '<title>Info for record</title>' + ; 
           '<body margintop=10 marginbottom=10 marginleft=10 marginright=10>' + ;
           CRLF + '<p>' + CRLF )

If ( !lChecked .or. lForce )
   // ����� � ��������� ���������� �����
   cHTML += ( '<IMG src="' + cFile + '" ' + ;
              'align="left" hspace=20 vspace=20 border=0><br>' + CRLF )
Else
  // �������� ������������ �� ��������� ���� �� ���������� 
   cHTML += '<A href="COMMAND:VIEWIMAGE" title="Click for view with image">'            
   cHTML += ( '<IMG src="res:GALLERY" align="left" hspace=20 vspace=20 border=0></A><br>' + CRLF )
Endif

cHTML += ( '<b><font size=+2>Record: </font></b>' + cID + CRLF )

cHTML += ( '</p>' + CRLF + '</body>' + CRLF + '</html>' )

Return cHTML

****** End of HTMLForRec ******


/******
*
*       ShowMe( lForce )
*
*       ����������� ����������
*
*/

Static Procedure ShowMe( lForce )
Local nValue := wMain.tbData.Value, ;
      nPos                        , ;
      cID                         , ;
      cHTML  := ''                , ;
      aData

Default lForce to .F.

If ( nValue == 1 )
   nPos := wMain.grdFiles.Value
ElseIf( nValue == 2 )
   nPos := wMain.grdRecords.Value
Endif

If !Empty( nPos )

   If ( nValue == 1 )
      cHTML := HTMLForFile( wMain.grdFiles.Item( nPos )[ 1 ] )
      
   Else
   
      cID   := wMain.grdRecords.Item( nPos )[ 1 ]
      aData := Do_SQL_Query( 'Select Name, Image from Picts Where Id = ' + cId + ';' )

      cHTML := HTMLForRec( cID, aData[ 1, 1 ], aData[ 1, 2 ], lForce )
        
   Endif

Endif

// �������� ������� ������. ������� �������� ����� �� ����������� � ���������
// �������. ��������, ��� ������� ����� ����� ������������� ������� QHTM_RenderHTML()
// � QHTM_RenderHTMLRect(). �� ������ � ���� �� �������� ������� ������� (��� registered only?),
// � ������ ����������� BCC ������������ ������������.

SetWindowText( HWND_HTMLDATA, cHTML )

If lForce
   CleanTmpFile()
Endif
      
Return

****** End of ShowMe ******


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
*       AddToBase()
*
*       ���������� ������� � ����
*
*/

Static Procedure AddToBase
Local aFiles     := GetFile( { { 'Images', '*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.ico' } }, ;
                             'Open file(s)'                                          , ;
                             aParams[ 'StartDir' ], .T., .T. )                       , ;
      pStatement                                                                     , ;
      cFile                                                                          , ;
      cName                                                                          , ;
      cExt                                                                           , ;
      cImage                                                                         , ;
      nTab       := wMain.tbData.Value

If !Empty( aFiles )

   SQLite3_Exec( aParams[ 'pDB' ], 'Begin transaction "DoIt";' )
   pStatement := SQLite3_Prepare( aParams[ 'pDB' ], 'Insert into Picts( Name, Image ) Values( :Name, :Image )' )

   If !Empty( pStatement )
   
      For each cFile in aFiles
         
         cImage := SQLite3_File_to_buff( cFile )
         cName := cExt := ''
         
         HB_FNameSplit( cFile, , @cName, @cExt )

         If ( ( SQLite3_Bind_Text( pStatement, 1, ( cName + cExt )) == SQLITE_OK ) .and. ;
              ( SQLite3_Bind_Blob( pStatement, 2, @cImage )         == SQLITE_OK )       ;
            )
      
           If ( SQLite3_Step( pStatement ) == SQLITE_DONE )
              aParams[ 'Reload' ] := .T.
           Endif 
           SQLite3_Reset( pStatement )

         Endif
         
      Next

      SQLite3_Clear_bindings( pStatement )
      SQLite3_Finalize( pStatement )

      If aParams[ 'Reload' ]
         SQLite3_Exec( aParams[ 'pDB' ], 'Commit transaction "DoIt";' )
      Else
         SQLite3_Exec( aParams[ 'pDB' ], 'Rollback transaction "DoIt";' )
      Endif

   Endif

Endif

If ( nTab == 2 )
   ListRecords()
Endif

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
Local nTab     := wMain.tbData.Value    , ;
      nPos     := wMain.grdRecords.Value, ;
      cID                               , ;
      cCommand                          , ;
      nCount                            , ;
      cMsg

If !( nTab == 2 )
   Return
Endif

If !Empty( nPos )

  cMsg := ( '<img src="res:CRAZY" border="0" hspace="20" vspace="20">'                    + ;
            '<strong><font color="red" size=+5>Are you want to delete of the current record?</font></strong>'   ;
          )

  If ( QHTM_MessageBox( cMsg, 'Confirm action', ( MB_YESNO + MB_DEFBUTTON2 ) ) == IDYES )

     cID := wMain.grdRecords.Item( nPos )[ 1 ]
     cCommand := ( 'Delete from Picts Where Id = ' + cId + ';' )

     If ( SQLite3_Exec( aParams[ 'pDB' ], cCommand ) == SQLITE_OK )

        // ���������� ������
     
        aParams[ 'Reload' ] := .T.
        ListRecords()

        // �� �����������, ��������� �������� �� ��� �� �������
     
        nCount := wMain.grdRecords.ItemCount
     
        nPos := Iif( ( nPos >= nCount ), nCount, nPos )
        wMain.grdRecords.Value := nPos
           
        ShowMe()
           
     Endif
     
  EndIf

Endif

wMain.grdRecords.SetFocus

Return

****** End of DelRecord ******


/******
*
*       MyEvents( hWnd, nMsg, wParam, lParam )
*
*       ���������������� ��������� �������.
*       ����� ����� ��������� ������� ������� �������� � �������� �� �������
*       � QHTM
*
*/
 
Function MyEvents( hWnd, nMsg, wParam, lParam )
Local nPos , ;
      cLink

// � �������� QHTM �� C ��� ����������� ������� �� ����� ������ ������������
// ��������� ��������� ( nMsg == WM_COMMAND ) � ����������� ���������� ��
// LOWORD(wParam). �� ����� ����� ����� �� �����������. ������������� ����
// �� WM_NOTIFY

If ( nMsg == WM_NOTIFY )

   // ������������������ �������� nPos := AScan() + _HMG_aControlNames[ nPos ]
   // (��� nPos := AScan() + (_HMG_aControlType[ nPos ] == 'QHTM' ) ), ������, 
   // �����������. ��� �� ��������� ������� � [������ �� ����� ���� "read"]
   
   If ( ( nPos := AScan( _HMG_aControlIds , wParam ) ) > 0 )

      If ( ( _HMG_aControlNames[ nPos ] == 'HtmlLogo' ) .or. ;
           ( _HMG_aControlNames[ nPos ] == 'HtmlData' )      ;
         )                                                        // ��������� �� ����� ��������... 
   // If ( _HMG_aControlType[ nPos ] == 'QHTM' )                  // ...��� �� ����

         // ����� ����� ���� ��������� ��������� ������� �� ����� ������.
         // ����� � HTML �������� ��������� ������:
         //
         // <a href="http://www.gipsysoft.com">GipsySoft</a>
         // <br><a href="COMMAND:32774">Display QHTM_Box</a>
         // (������� �� ���� QHTM � ����������� ���� ���������)
         
         // 1-� ������� ���������
         //
         // If ( QHTM_GetNotify( lParam ) == 'COMMAND:32774' )
         //   MsgBox( 'Display QHTM_Box' )
         // Endif
         //
         // ��������:
         // - ��� ������ ������ "Display QHTM_Box" ������������ ���� ��������� �
         //   ����� �� ���� ����������� ������� �� ��������� "command:32774" � ������ ������
         // - ��� ������ ������ "GipsySoft" ����������� ������� ��� �������� �� http://www.gipsysoft.com
         
         // 2-� ������� ���������
         //
         // If ( QHTM_GetLink( lParam ) == 'COMMAND:32774' )
         //   MsgBox( 'Display QHTM_Box' )
         // Endif
         //
         // ��������:
         // - ��� ������ ������ "Display QHTM_Box" ������������ ���� ���������
         // - ��� ������ ������ "GipsySoft" - ������� �������. QHTM_GetLink( lParam )
         //   ����� ���������� "http://www.gipsysoft.com"
         
         // 3-� ������� ���������
         //
         // � ���� ������:
         // - ��� ������ ������ "Display QHTM_Box" ������������ ���� ���������
         // - ��� ������ ������ "GipsySoft" ����������� ������� ��� �������� �� http://www.gipsysoft.com

         If ( ID_COMMAND $ QHTM_GetNotify( lParam ) )
            
            cLink := QHTM_GetLink( lParam )
            
            If ( cLink == ID_COMMAND_EXPLORER )              // ������� ������� ����� � ����������
               Execute operation 'Open' file aParams[ 'StartDir' ]
                
            ElseIf ( cLink == ID_COMMAND_CHANGEFOLDER )      // �������� ������� �����
               ChangeFolder()

            ElseIf ( cLink == ID_COMMAND_VIEWIMAGE )         // �������� ����������� � ������
               ShowMe( .T. )
               
            Endif
         
         Endif
         
      Endif
      
   Endif
     
ElseIf ( nMsg == WM_CTLCOLORSTATIC )

   // ��� ������������� QHTM � ��������� Label �������� �������� ��������� �����
   // ������ (��������, Form_1.Label_1.FontColor := RED). ������� ������� ���������
   // � �������� ������� � ��������� ����������.
   
   Return Events( hWnd, nMsg, wParam, lParam ) 
 

Endif

Events( hWnd, nMsg, wParam, lParam )
  
Return 0

****** End of MyEvents ******


/******
*
*       GetHTMLTitle()
*
*       �������� ��������� HTML-��������
*       (� �������� ������ �������� �� ������ ����������� ����� ������
*       <title></title>)
*
*/

Static Procedure GetHTMLTitle
Local cMsg := ( '<p>Data area has title:<br><br><i><font color="blue" size=+3>"' + ;
                QHTM_GetTitle( HWND_HTMLDATA ) + '"</font></i></p>' ) 

QHTM_MessageBox( cMsg, 'Get title' )

Return

****** End of GetHTMLTitle ******


/******
*
*       GetHTMLSize()
*
*       ���������� ������� ������� HTML
*
*/

Static Procedure GetHTMLSize
Local aSize := QHTM_GetSize( HWND_HTMLDATA ), ;
      cMsg  := '' 

If !Empty( aSize )

   cMsg += '<p><b>QHTM_GetSize() for HTML</b></p><p>'
   cMsg += ( 'Height:' + Str( aSize[ 2 ] )  + '<br>' )
   cMsg += ( 'Width :'  + Str( aSize[ 1 ] ) + '<br>' )
   cMsg += '</p><p><b>MiniGUI control</b></p><p>'
   cMsg += ( 'Height:' + Str( wMain.HtmlData.Height ) + '<br>' )
   cMsg += ( 'Width :' + Str( wMain.HtmlData.Width ) + '</p>' )

   QHTM_MessageBox( cMsg, 'Get sizes' )
   
Endif

Return

****** End of GetHTMLSize ******


/******
*
*       ViewSource()
*
*       �������� ��������� ����
*
*/

Static Procedure ViewSource
Local cFile := ( aParams[ 'TmpDir' ] + TMP_SOURCE_TXT )

// ���������� HTML-��� �� ��������� ����

MemoWrit( cFile, GetWindowText( HWND_HTMLDATA ) )

If File( cFile )
   Execute operation 'Open' file cFile
Endif

Return

****** End of ViewSource ******


/******
*
*       DemoPrint()
*
*       ��������� ������������� ���-��������
*
*/

Static Procedure DemoPrint
Local cHTMLFile := HTML_PRINT_DEMO, ;
      cCaption

Define window wForm       ;
       At 0, 0            ;
       Width 500          ;
       Height 500         ;
       Title 'Print demo' ;
       Modal

   @ 5, 5 QHTM HtmlForm of wForm ;
          File cHTMLFile         ;
          Width 480              ;
          Height 350             ;
          Border

   @ 370, 160 Button btnPrint ;
              Caption 'Print' ;
              Width 150       ;
              Height 80       ;
              Action PrintHTML( cHTMLFile )
              
End Window

// ��������� ���-�������� �� ������ � �������� ����� �������

QHTM_SetHTMLButton( GetControlHandle( 'btnPrint', 'wForm' ) )

cCaption := ( '<p align="center"><img src="res:THINK" border="0" hspace="20" align="middle">' + ; 
              '<font color="green" size=+2><b>Print</font></b>' )

wForm.btnPrint.Caption := cCaption

On Key Escape of wForm Action wForm.Release
On Key Alt+X of wForm Action AppDone( .T. )

Center window wForm
Activate window wForm

Return

****** End of DemoPrint ******


/******
*
*       PrintHTML( cHTMLFile )
*
*       ������ ���-��������
*
*/

Static Procedure PrintHTML( cHTMLFile )
Local hContext   , ;
      nCountPages, ;
      Cycle

Init PrintSys
Select by dialog

If !Empty( HBPRNERROR )
   Return
Endif

// ��������� ������ � ���������� �����, ������������ ����� �������
 
Set orientation PORTRAIT
Set PaperSize DMPAPER_A4
Set print margins Top 2 Left 5
Set Preview on
Set preview rect 0, 0, GetDesktopRealHeight(), GetDesktopRealWidth()
Set preview scale 2
Set thumbnails on

hContext := QHTM_PrintCreateContext()

Start doc name 'Print form'

If QHTM_PrintSetTextFile( hContext, cHTMLFile )

   // HBPrn - ������, ����������� Init PrintSys
   // HBPrn : hDC - �������� ���������� ������
   
   nCountPages := QHTM_PrintLayout( HBPrn : hDC, hContext )
   
   For Cycle := 1 to nCountPages
     Start Page
     QHTM_PrintPage( HBPrn : hDC, hContext, Cycle )
     End Page
   Next
   
Endif

End Doc

QHTM_PrintDestroyContext( hContext )
Release PrintSys

Return

****** End of PrintHTML ******


/******
*
*       DemoSubmit()
*
*       ������������� ���-����
*
*/

Static Procedure DemoSubmit
Local cHTMLFile := HTML_SUBMIT_DEMO

Define window wForm        ;
       At 0, 0             ;
       Width 495           ;
       Height 385 + Iif( IsAppThemed(), 8, 0 ) ;
       Title 'Submit demo' ;
       Modal               ;
       NoSize

   @ 5, 5 QHTM HtmlForm of wForm ;
          File cHTMLFile         ;
          Width 480              ;
          Height 350             ;
          Border

End Window

On Key Escape of wForm Action wForm.Release
On Key Alt+X of wForm Action AppDone( .T. )

Center window wForm
Activate window wForm

Return

****** End of DemoSubmit ******


/******
*
*       QhtmFormProc( ControlHandle, cMethod, cAction, cName, aFields )
*
*       ������� �������� ��������� ���������:
*
*       - ControlHandle - ������������� ������� QHTM
*       - cMethod       - ����� (POST)
*       - cAction       - ���������� ( http://127.0.0.1/cgi-win/myapp.exe)
*       - cName         - ������������ ����� (� ���� <FORM></FORM>)
*       - aFields       - ��������� ������ ����������� ������ ("������������� ����"-"��������")
*
*       ��������� ������ ���-����
*
*       ! 1) ������� ������ ���������� ������ ���: QhtmFormProc()
*            (�������� "������" � ���������� ���������� HMG_QHTM)
*         2) ������� �� �.�. ��������� ��� Static
*
*/

Procedure QhtmFormProc( ControlHandle, cMethod, cAction, cName, aFields )
Local nCycle        , ;
      cMessage := '', ;
      nCount

HB_SYMBOL_UNUSED( ControlHandle )

nCount := Len( aFields )

If ( Valtype( cName ) == 'C' )
   cMessage += ( 'Name of form: ' + cName + CRLF )
Endif

cMessage += ( 'Method       : ' + cMethod                + CRLF + ;
              'Action       : ' + cAction                + CRLF + ;
              'Amount fields: ' + LTrim( Str( nCount ) ) + CRLF   ;
            )

For nCycle := 1 to nCount
  cMessage += ( aFields[ nCycle, 1 ] + '  -  ' + aFields[ nCycle, 2 ] + CRLF )
Next

MsgInfo( cMessage, 'Web-form filling' )

Return

****** End of QhtmFormProc ******


// C-level functions

#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT 0x0400
#include <windows.h>
#include "hbapi.h"


/******
*
*       Real width of desktop
*
*/

HB_FUNC_STATIC( GETDESKTOPREALWIDTH ) 
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_retni(rect.right - rect.left);

}

/******
*
*       Real height of desktop (without taskbar)
*
*/

HB_FUNC_STATIC( GETDESKTOPREALHEIGHT ) 
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_retni(rect.bottom - rect.top);
}

#pragma ENDDUMP
