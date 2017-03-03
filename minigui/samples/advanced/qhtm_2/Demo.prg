/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Joint usage of QHTM & SQLite3 demo
 * (c) 2009 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

/*
Демонстрация использования функций динамической библиотеки QHTM (freeware version)

Представлены следующие функции:
- подключение DLL QHTM (QHTM_Init(), QHTM_End())
- создание элемента QHTM; загрузка содержания из переменной, ресурсного файла (@...QHTM)
- изменение размеров элементов QHTM и обновление их содержимого
- получение заголовка и размеров элемента QHTM (QHTM_GetTitle(), QHTM_GetSize())
- использование MsgBox() в стиле QHTM (QHTM_MessageBox())
- использование всплывающих подсказок в стиле QHTM (QHTM_EnableCooltips())
- просмотр HTML кода элемента QHTM
- использование ссылок в тексте элемента QHTM для выполнения внутренних процедур
- применение веб-разметки на кнопках (QHTM_SetHTMLButton())
- заполнение веб-форм и получение результата

Функции QHTM (справочно):
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

QhtmFormProc() - предопределённое имя процедуры обработки результата ввода
                 в веб-формы
*/

#include "Directry.ch"
#include "HBSQLit3.ch"
#include "i_qhtm.ch"
#include "MiniGUI.ch"
#include "winprint.ch"


// Определения WinAPI

#define WM_NOTIFY	             78
#define WM_CTLCOLORSTATIC           312


// Для изменения вида элементов окна
 
#define WS_EX_CLIENTEDGE            512   // Определяет, что окно имеет рамку с углубленным краем.
#define WS_EX_STATICEDGE           8192   // Окно с объемной рамкой. Этот стиль обычно используется  
                                          // для элементов управления, не позволяющих ввод данных. 

#define WS_FLAT                    ( WS_EX_CLIENTEDGE + WS_EX_STATICEDGE )

// Набор кнопок в диалогах подтверждения действий и иденификаторы результата обработки запроса.

#define MB_YESNO                      4

#define IDYES                         6       // В диалоге "Да-Нет" нажата кнопка "Да"
#define MB_DEFBUTTON2               256       // 2-я кнопка в диалоге выбрана по умолчанию


#define DB_NAME            'PicBase.db'       // Рабочая база
#define TMP_SOURCE_TXT     'Temp.txt'         // Временный файл для просмотра кода страницы

// Область вывода графического изображения фиксирована

// Область логотипов

#define LOGO_TOP                      5
#define LOGO_LEFT                     5
#define LOGO_HEIGHT                 130

// Блок вкладок

#define TB_TOP                      ( LOGO_TOP +  LOGO_HEIGHT + 5 )
#define TB_LEFT                     LOGO_LEFT
#define TB_WIDTH                    260

// Область вывода данных

#define DATA_TOP                    TB_TOP
#define DATA_LEFT                   ( TB_LEFT + TB_WIDTH + 5 )

// Идентификаторы обрабатываемых элементов QHTM

#define HWND_HTMLDATA               GetControlHandle( 'HtmlData', 'wMain' )
  
// Команды (переназначаемые ссылки)

#define ID_COMMAND                  'COMMAND:'
#define ID_COMMAND_EXPLORER         ( ID_COMMAND + 'EXPLORER'     )  // Запуск Explorer
#define ID_COMMAND_CHANGEFOLDER     ( ID_COMMAND + 'CHANGEFOLDER' )  // Сменить рабочую папку
#define ID_COMMAND_VIEWIMAGE        ( ID_COMMAND + 'VIEWIMAGE'    )  // Принудительно показать рисунок


// Внешние файлы, используемые в процедурах

#define HTML_PRINT_DEMO             'Files\QHTM.html'       // Демонстрация печати
#define HTML_SUBMIT_DEMO            'Files\Index.htm'       // Демонстрация использования форм


Static aParams                      // Массив рабочих параметров 


/******
*
*       Демонстрация рисунков, хранящихся в графических файлах 
*       и в базе SQLite
*
*/

Procedure Main
Local cHTML := ''

aParams := { 'StartDir'    => GetSpecialFolder( CSIDL_MYPICTURES ), ;        // Каталог "Мои рисунки"
             'pDB'         => nil                                 , ;        // Дескриптор базы
             'ReadFiles'   => .T.                                 , ;        // Перечитать список файлов
             'SavePos'     => .F.                                 , ;        // Сохранять позицию в списке файлов 
             'Reload'      => .T.                                 , ;        // Признак необходимости перечитать БД
             'TmpDir'      => ( GetTempFolder() + '\' )           , ;        // Каталог временных файлов
             'TmpFilePict' => ''                                    ;        // Временный файл рисунка из базы 
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

// Разрешаем использование HTML в тексте всплывающих подсказок. Функция должна
// вызываться ДО определения элементов окна.
// ! Использование этой функции перекрывает команды SET TOOLTIP 

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

   // Главное меню
   
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

   // Список файлов/записей

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

ListFiles()     // Заполняем список файлов
ChangeStyle( GetControlHandle( 'tbData', 'wMain' ), WS_FLAT, , .T. )

Center window wMain
Activate window wMain

Return

****** End of Main ******


/******
*
*       ReSize()
*
*       Приведение в соответствие размеров элементов при изменении
*       размера окна
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
*       Завершение работы
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
   
   // Очистить временный каталог
   
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
*      Изменение признака создания временного файла рисунка
*
*/

Static Procedure SetMarker
Local lChecked := wMain.pdLess.Checked, ;
      nValue   := wMain.tbData.Value

lChecked := !lChecked
wMain.pdLess.Checked := lChecked

// Если в окне показаны записи базы, выполняем обновление состояния
 
If ( nValue == 2 )

   If lChecked
      // Выбран режим без вывода картинки во временный файл. Поэтому выполним
      // очистку
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
*       Удаление временного файла рисунка, извлечённого из базы
*       для вывода в окне
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
*       Открытие/создание БД
*
*/

Static Function OpenBase
Local lExistDB  := File( DB_NAME )             , ;
      pHandleDB := SQLite3_Open( DB_NAME, .T. ), ;
      cCommand

If !Empty( pHandleDB )
   
   // При auto_vacuum = 0 после завершения операций удаления данных размер файла БД не изменяется.
   // Освобождённые блоки помечаются как "свободные" и могут повторно использоваться в 
   // последующих операциях добавления новых записей.
   // Для уменьшения размера файла необходимо выполнить команду Vacuum
   
   SQLite3_Exec( pHandleDB, 'PRAGMA auto_vacuum = 0' )

   If !lExistDB
      
      // Создаём таблицу
    
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
*      Обработка переключения между списками (файлы-записи)
*
*/

Static Procedure SwitchTab
Local nValue := wMain.tbData.Value

CleanTmpFile()

// Установка активного элемента

If ( nValue == 1 )              // Вкладка файлов 
   ListFiles()
   wMain.pdDelete.Enabled :=.F.
   wMain.grdFiles.SetFocus       
   
ElseIf( nValue == 2 )           // Вкладка записей
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
*       Формирование списка графических файлов
*
*/
    
Static Procedure ListFiles
Local nPos   := wMain.grdFiles.Value, ; 
      aFiles := {}

If aParams[ 'ReadFiles' ]
 
   // Используем только некоторые типы файлов

   AEval( Directory( aParams[ 'StartDir' ] + '\*.jpg'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.jpeg' ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.png'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.gif'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.bmp'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )
   AEval( Directory( aParams[ 'StartDir' ] + '\*.ico'  ), { | elem | AAdd( aFiles, Lower( elem[ F_NAME ] ) ) } )

   wMain.grdFiles.DeleteAllItems

   If !Empty( aFiles )
   
      ASort( aFiles, { | x, y | x < y } )       // Сортируем список

      wMain.grdFiles.DisableUpdate              // Запрет на обновление грида (актуально при большом количестве графических файлов в папке)

      AEval( aFiles, { | elem | wMain.grdFiles.AddItem( { elem } ) } )

      wMain.grdFiles.EnableUpdate               // Разрешаем показать выполненные изменения в гриде

      // При обновлении списка текущего каталога позицию указателя сохраняем
   
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
*       Заполнение таблицы имеющихся в БД записей
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
         // В выборке только 2 поля: идентификатор и имя файла
         wMain.grdRecords.AddItem( { aItem[ 1 ], aItem[ 2 ] } )
      Next
   
      wMain.grdRecords.Value := 1
   
   Endif

   // Необходимо переформирование списка записей, имеющихся в БД
   // Признак устанавливается при инициализации или после добавления и
   // удаления записей
   
   aParams[ 'Reload' ] := .F.
   
Endif

Return

****** End of ListRecords ******


/******
*
*       Do_SQL_Query( cQuery ) --> aResult
*
*       Выполнение выборки
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
*       Формирование текста веб-страници для существующего файла
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

// Информация о файле (CRLF использовать не обязательно; только если появится
// необходимость проверить полученный текст, например запросить в конце
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
*       Формирование текста веб-страници для записи БД
*
*/

Static Function HTMLForRec( cID, cName, cImage, lForce )
Local lChecked  := wMain.pdLess.Checked                  , ;
      cFile := ( aParams[ 'TmpDir' ] + AllTrim( cName ) ), ;
      cHTML := ''

Default lForce to .F.    // Принудительный вывод изображения

If ( !lChecked .or. lForce )
   CleanTmpFile()
   MemoWrit( cFile, cImage )
   aParams[ 'TmpFilePict' ] := AllTrim( cName )   // Запомним имя созданного файла (для последующей очистки)
Endif

cHTML += ( '<html>' + ;
           '<title>Info for record</title>' + ; 
           '<body margintop=10 marginbottom=10 marginleft=10 marginright=10>' + ;
           CRLF + '<p>' + CRLF )

If ( !lChecked .or. lForce )
   // Режим с созданием временного файла
   cHTML += ( '<IMG src="' + cFile + '" ' + ;
              'align="left" hspace=20 vspace=20 border=0><br>' + CRLF )
Else
  // Картинка сбрасывается во временный файл по требованию 
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
*       Отображение информации
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

// Обновить область данных. Большие картинки могут не поместиться в отведённой
// области. Возможно, для решения этого нужно задействовать функции QHTM_RenderHTML()
// и QHTM_RenderHTMLRect(). Но первая у меня не вызывает никакой реакции (для registered only?),
// а вторую компоновщик BCC отказывается обнаруживать.

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
*       Смена текущего каталога
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
*       Добавление рисунка в базу
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
*       Удаление записи из базы
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

        // Перечитать список
     
        aParams[ 'Reload' ] := .T.
        ListRecords()

        // По возможности, указатель оставить на той же позиции
     
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
*       Пользовательская обработка событий.
*       Здесь будем разделять команды запуска процедур и перехода по ссылкам
*       в QHTM
*
*/
 
Function MyEvents( hWnd, nMsg, wParam, lParam )
Local nPos , ;
      cLink

// В примерах QHTM на C для определения реакции на выбор ссылки используется
// обработка сообщения ( nMsg == WM_COMMAND ) с последующим селектором по
// LOWORD(wParam). Но здесь такая схема не срабатывает. Анализировать надо
// по WM_NOTIFY

If ( nMsg == WM_NOTIFY )

   // Последовательность проверки nPos := AScan() + _HMG_aControlNames[ nPos ]
   // (или nPos := AScan() + (_HMG_aControlType[ nPos ] == 'QHTM' ) ), похоже, 
   // обязательна. Без неё программа валится с [Память не может быть "read"]
   
   If ( ( nPos := AScan( _HMG_aControlIds , wParam ) ) > 0 )

      If ( ( _HMG_aControlNames[ nPos ] == 'HtmlLogo' ) .or. ;
           ( _HMG_aControlNames[ nPos ] == 'HtmlData' )      ;
         )                                                        // Проверить по имени элемента... 
   // If ( _HMG_aControlType[ nPos ] == 'QHTM' )                  // ...или по типу

         // Здесь может быть несколько вариантов реакции на выбор ссылки.
         // Пусть в HTML записаны следующие строки:
         //
         // <a href="http://www.gipsysoft.com">GipsySoft</a>
         // <br><a href="COMMAND:32774">Display QHTM_Box</a>
         // (переход на сайт QHTM и отображения окна сообщения)
         
         // 1-й вариант обработки
         //
         // If ( QHTM_GetNotify( lParam ) == 'COMMAND:32774' )
         //   MsgBox( 'Display QHTM_Box' )
         // Endif
         //
         // Получаем:
         // - При выборе ссылки "Display QHTM_Box" отображается окно сообщения и
         //   вслед за этим запускается браузер со значением "command:32774" в строке адреса
         // - При выборе ссылки "GipsySoft" запускается браузер для перехода по http://www.gipsysoft.com
         
         // 2-й вариант обработки
         //
         // If ( QHTM_GetLink( lParam ) == 'COMMAND:32774' )
         //   MsgBox( 'Display QHTM_Box' )
         // Endif
         //
         // Получаем:
         // - При выборе ссылки "Display QHTM_Box" отображается окно сообщения
         // - При выборе ссылки "GipsySoft" - никакой реакции. QHTM_GetLink( lParam )
         //   будет возвращать "http://www.gipsysoft.com"
         
         // 3-й вариант обработки
         //
         // В этом случае:
         // - При выборе ссылки "Display QHTM_Box" отображается окно сообщения
         // - При выборе ссылки "GipsySoft" запускается браузер для перехода по http://www.gipsysoft.com

         If ( ID_COMMAND $ QHTM_GetNotify( lParam ) )
            
            cLink := QHTM_GetLink( lParam )
            
            If ( cLink == ID_COMMAND_EXPLORER )              // Открыть рабочую папку в Проводнике
               Execute operation 'Open' file aParams[ 'StartDir' ]
                
            ElseIf ( cLink == ID_COMMAND_CHANGEFOLDER )      // Изменить рабочую папку
               ChangeFolder()

            ElseIf ( cLink == ID_COMMAND_VIEWIMAGE )         // Показать изображение в тексте
               ShowMe( .T. )
               
            Endif
         
         Endif
         
      Endif
      
   Endif
     
ElseIf ( nMsg == WM_CTLCOLORSTATIC )

   // При использовании QHTM в элементах Label перестаёт работать изменение цвета
   // шрифта (например, Form_1.Label_1.FontColor := RED). Поэтому передаём обработку
   // в основную функцию с возвратом результата.
   
   Return Events( hWnd, nMsg, wParam, lParam ) 
 

Endif

Events( hWnd, nMsg, wParam, lParam )
  
Return 0

****** End of MyEvents ******


/******
*
*       GetHTMLTitle()
*
*       Получить заголовок HTML-элемента
*       (в исходном тексте страницы он должен размещаться между тегами
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
*       Определить размеры области HTML
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
*       Просмотр исходного кода
*
*/

Static Procedure ViewSource
Local cFile := ( aParams[ 'TmpDir' ] + TMP_SOURCE_TXT )

// Сбрасываем HTML-код во временный файл

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
*       Обработка интерактивной веб-страницы
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

// Разрешаем веб-разметку на кнопке и изменяем стиль надписи

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
*       Печать веб-страницы
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

// Назначаем размер и ориентацию листа, предпросмотр перед печатью
 
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

   // HBPrn - объект, создаваемый Init PrintSys
   // HBPrn : hDC - контекст устройства печати
   
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
*       Использование веб-форм
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
*       Функция получает следующие параметры:
*
*       - ControlHandle - идентификатор объекта QHTM
*       - cMethod       - метод (POST)
*       - cAction       - получатель ( http://127.0.0.1/cgi-win/myapp.exe)
*       - cName         - наименование формы (в тэге <FORM></FORM>)
*       - aFields       - двумерный массив заполненных данных ("идентификатор поля"-"значение")
*
*       Обработка данных веб-форм
*
*       ! 1) Функция должна называться именно так: QhtmFormProc()
*            (название "зашито" в процедурах библиотеки HMG_QHTM)
*         2) Функция не д.б. объявлена как Static
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
