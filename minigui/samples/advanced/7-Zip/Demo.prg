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
*       Доступ к архивам 7z, zip с использованием динамической
*       библиотеки 7-zip32.dll (Japanese http://www.csdinc.co.jp/archiver/lib/
*       English http://www.csdinc.co.jp/archiver/lib/main-e.html)
*
* Access to archives 7z, zip using dynamic libraries 
* 7-zip32.dll (Japanese http://www.csdinc.co.jp/archiver/lib/ 
* English http://www.csdinc.co.jp/archiver/ lib / main-e.html)
*/

Procedure Main

// Формируем полное имя установленного 7-Zip. Для упрощения, принимем
// что программа установлена в каталог по умолчанию

// Form the full name of the installed 7-Zip. For simplification, taking
// That the program is installed in the default directory

cPath7z := GetProgramFilesFolder() + '\7-zip\7z.exe'

// Можно поступить иначе - через запись в реестре
// You can do otherwise - through a registry entry
/*
Open registry oReg key HKEY_LOCAL_MACHINE Section 'Software\7-Zip'
Get value cPath7z Name 'Path' of oReg 
Close registry oReg

If !Empty( cPath7z )
   cPath7z += '\7z.exe'
Else
   // Ошибка - нет соответвующей записи в реестре
Endif
*/

If ( !File( cPath7z  ) .and. ;
     !File( ALONE_7Z )       ;
   )
   
   // Если нет установленного 7-Zip и консольного варианта архиватора,
   // то и дальнейшие действия запрещаем.
   // Хотя здесь есть нюанс: использование одной 7-zip32.dll без 7-Zip
   // позволяет просматривать архив, но не позволяет создавать или
   // извлекать из него файлы.
  
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

      // Отображаем содержимое выбранного архива. 
      // Display the contents of the archive.
      @ 30, 5 Grid grdContent            ;
              Width 520                  ;
              Height 285                 ;
              Headers { 'Name' }         ;
              Widths { 400 }             ;
              Multiselect

      // Операции открытия архива, извлечения и создания
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

    // Некоторые установки обработки

    Define page 'Options'

      // Выбор варианта демонстрации

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

      // Общие параметры

      @ 110, 5 Frame frmCommon  ;
               Caption 'Common' ;
               Width 520        ;
               Height 65        ;
               Bold             ;
               FontColor BLUE

      // Отображение процесса обработки

      @ 135, 15 CheckBox cbxHide           ;
                Caption 'Hide progressbar' ;
                Width 124                  ;
                Value .T.

      // Параметры извлечения

      @ 185, 5 Frame frmExtract  ;
               Caption 'Extract' ;
               Width 520         ;
               Height 65         ;
               Bold              ;
               FontColor BLUE

      // Сохранять структуру каталогов при извлечении

      @ 210, 15 CheckBox cbxExtract                     ;
                Caption 'Extract files with full paths' ;
                Width 176                               ;
                Value .T.

      // Отвечать Yes на все вопросы в процессе обработки

      @ 210, 200 CheckBox cbxYesAll                    ;
                 Caption 'Assume (Yes) on all queries' ;
                 Width 190

      // Полезные ссылки 

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

// Устанавливаем доступ к вариантам теста

If !File( cPath7z )

   // Доступен только запуск консольной версии архиватора

   wMain.rdgSelectTest.Enabled( 1 ) := .F.
   wMain.rdgSelectTest.Enabled( 2 ) := .F.
   wMain.rdgSelectTest.Value := 3

   If !File( ALONE_7Z )

      // Нет нужных файлов. Запрещаем всё

      wMain.rdgSelectTest.Enabled := .F.
      wMain.rdgSelectTest.Value   := 0

   Endif

Else

   // При отсутствии динамической библиотеки и консольной версии
   // архиватора посмотреть можно только действие установочной версии 7-Zip

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
*       Запуск обработки. Чем будет выполнятся обработка
*       устанавливается селектором rdgSelectTest 
*/

Static Procedure RunTest( nChoice )
Local nSelected := wMain.rdgSelectTest.Value

Do case
   Case ( nChoice == 1 )        // Создание архива

      If ( nSelected == 1 )
         // Обработать 7-zip32.dll
         CreateArc()
      Else
         // Запустить 7z.exe или 7za.exe
         CreateArcExternal()
      Endif

   Case ( nChoice == 2 )        // Просмотр содержимого

      If ( nSelected == 1 )
         ViewArc()
      Else
         ViewArcExternal()
      Endif

   Case ( nChoice == 3 )        // Извлечение файлов

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
*       Отображение элементов строки состояния
*
*/

Static Procedure ShowStatus( cFile, cCount, cType, cVersion )

wMain.StatusBar.Item( 1 ) := cFile      // Обрабатываемый файл
wMain.StatusBar.Item( 2 ) := cCount     // Файлов в архиве
wMain.StatusBar.Item( 3 ) := cType      // Тип архива
wMain.StatusBar.Item( 4 ) := cVersion   // Информация о процедуре 

Return

****** End of ShowStatus ******


//--------------------------------------------------------------
// Блок процедур для 7-zip32.dll  
//--------------------------------------------------------------

/******
*
*       Version7zip() --> cVersion
*
*       Версия архиватора 7-zip и 7-zip32.dll
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
*       Создание архива
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

      // Определяем тип архива. По умолчанию используется 7z, поэтому
      // запоминаем только в случае изменения в диалоговом окне.  

      If ( Upper( Right( cArcFile, 3 ) ) == 'ZIP' )
         cType := 'zip'
      Endif

      // Строим строку команды для передачи в DLL

      If wMain.cbxHide.Value
         cCommand += '-hide '       // Не отображать процесс
      Endif

      If !Empty( cType )
         cCommand += '-tzip '       // В формате ZIP
      Endif

      cCommand += ( cArcFile + ' ' )

      // Указываем файлы для обработки

      AEval( aSource, { | elem | cCommand += ( '"' + elem + '" ' ) } )

      cCommand := RTrim( cCommand )

      If !( ( nDLLHandle := WIN_P2N( WAPI_LOADLIBRARY( '7-zip32.dll' ) )  > 0 ) )
         MsgStop( "Can't load 7-zip32.dll.", 'Error' )
      Else
         DllCall( nDLLHandle, DC_CALL_STD, 'SevenZip', _HMG_MainHandle, cCommand )
         wapi_FreeLibrary( nDLLHandle )

         // Заполнить строку состояния

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
*       Открыть архив и заполнить таблицу содержания
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

nArcHandle := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipOpenArchive', _HMG_MainHandle, cFile, 0 )   // Открыть архив

If Empty( nArcHandle )
   MsgStop( cFile + ' not opened.', 'Error' )
   Return
Endif 

nCount  := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileCount'  , cFile )  // Количество элементов в архиве
nResult := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetArchiveType', cFile )  // Тип архива

Do case
   Case ( nResult == 1 )
     cType := 'ZIP'

   Case ( nResult == 2 )
     cType := '7Z'

   Case ( nResult == -1 )
     // Ошибка обработки
     cType := 'Error'

   Case ( nResult == 0 )
     // Не поддерживаемый тип. Хотя при попытке открыть что-нибудь
     // кроме 7z и Zip функция SevenZipOpenArchive() будет
     // возвращать ошибку.
     cType := '???'

Endcase

// Инициализация структуры, необходимой для обработки элементов архива и
// указателя (для передачи в DLL)

oInfo := ( struct INDIVIDUALINFO )
pInfo := oInfo : GetPointer()

// Ищем 1-й файл. Если результат поиска не имеет значения, передачу pInfo
// можно опустить.

DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipFindFirst', nArcHandle, '*', pInfo )

// Переустанавливаем указатель

oInfo := oInfo : Pointer( pInfo )

cValue := Space( FNAME_MAX32 )
DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileName', nArcHandle, @cValue, FNAME_MAX32 )

If !Empty( cValue )

   // Заполняем таблицу формы. Вначале значения заносим в массив,
   // сортируем и передаём Grid

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

// Закрыть архивный файл, выгрузить библиотеку

DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipCloseArchive', nArcHandle )
wapi_FreeLibrary( nDLLHandle )

// Заполнить строку состояния
         
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
*       Извлечение файлов из архива
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

   // Извлекать с сохранением стуктуры каталогов или нет

   cCommand := ( Iif( wMain.cbxExtract.Value, 'x', 'e' ) + ' ' )

   If wMain.cbxHide.Value

      // Не отображать процесс. Но если потребуется перезапись
      // существующих файлов, соответсвующий запрос всё равно
      // будет выведен.

      cCommand += '-hide '

   Endif

   // Перезаписывать существующие файлы без предупреждения

   If wMain.cbxYesAll.Value
      cCommand += '-y '
   Endif

   cCommand += ( '-o' + cDir + ' ' )    // Куда извлечь

   // Не забыть добавить имя архива, содержащего извлекаемые файлы

   //cCommand += ( '"' + AllTrim( wMain.Statusbar.Item( 1 ) ) + '" ' )
   cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )

   // Добавляем извлекаемые файлы. Для упрощения обработки:
   // если количество отмеченных элементов равно общему
   // количеству, то нет смысла выполнять перебор.

   If ( Len( aPos ) == wMain.grdContent.ItemCount )
      cCommand += '*.*'
   Else

      For Each nPos In aPos

         // Позиции, содержащие только имя каталога, пропускаем

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


// Процедуры в 7-zip32.dll

// Версия и подверсия библиотеки

// Declare DLL_TYPE_WORD SevenZipGetVersion() in 7-zip32.dll
// Declare DLL_TYPE_WORD SevenZipGetSubVersion() in 7-zip32.dll

 Declare SevenZipGetVersion() in 7-zip32.dll
 Declare SevenZipGetSubVersion() in 7-zip32.dll

//--------------------------------------------------------------
// Блок процедур для 7-zip 7za.exe  
//--------------------------------------------------------------

/******
*
*       CreateArcExternal()
*
*       Создание архива
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

   // Обращение непосредственно к самому 7-Zip позволяет создавать
   // большее количество типов архивов

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

      // Определяем тип архива. По умолчанию используется 7z, поэтому
      // запоминаем только в случае изменения в диалоговом окне.  

      nPos := RAt( '.', cArcFile )
      cExt := Upper( Right( cArcFile, ( Len( cArcFile ) - nPos ) ) )

      If !( cExt == '7Z' )
         cType := cExt
      Endif

      // Строим строку команды

      If !Empty( cType )
         cCommand += ( '-t' + cType + ' ' )
      Endif

      cCommand += ( cArcFile + ' ' )

      // Указываем файлы для обработки

      AEval( aSource, { | elem | cCommand += ( '"' + elem + '" ' ) } )

      // Запускаем или установленный архиватор или консольную
      // версию, ноходящуюся в папке с демонстрационной программой

      If ( wMain.rdgSelectTest.Value == 2 )
         cCommand := ( cPath7z + cCommand )
      Else
         cCommand := ( ALONE_7Z + cCommand )
      Endif

      cCommand := RTrim( cCommand )

      // Запускаем в режиме ожидания окончания обработки. Если
      // при этом само окно архиватора скрыто (для эстетики, т.к. окно
      // консольное), для отображения о том, что работа выполняется (если
      // архив большой), можно вывести какое-нибудь информационное окно, 
      // например с таймером.

      // Есть ещё вариант: для 7-Zip запускать не %ProgramFiles%\7-Zip\7z.exe,
      // а %ProgramFiles%\7-Zip\7zG.exe - графический интерфейс архиватора.
      // Получим на экране чудненький индикатор процесса обработки. 
            
      If wMain.cbxHide.Value
         Execute file ( cCommand ) Wait Hide
      Else
         Execute file ( cCommand ) Wait
      Endif

      // Заполнить строку состояния

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
*       Открыть архив и заполнить таблицу содержания
*
*/

Static Procedure ViewArcExternal
// aFiles - набор поддерживаемых типов архивов. Базовым принимаем набор для 
// консольной версии (7za.exe), т.к. её возможности скромнее.
Local aFilters := { { '7-zip', '*.7z'   }, ;
                    { 'Zip'  , '*.zip'  }, ;
                    { 'Cab'  , '*.cab'  }, ;
                    { 'GZip' , '*.gzip' }, ;
                    { 'Tar'  , '*.tar'  }  ;
                  }                      , ;
        cFile                            , ;
        aFiles    := {}                  , ;
        cCommand                         , ;
        cTmpFile  := '_Arc_.lst'         , ;     // Или GetTempFolder() + '\_Arc_.lst' 
        oFile                            , ;
        cString

// Добавим типы архивов, с которыми может работать полная версия (не все, 
// указанные в документации, конечно)

If ( wMain.rdgSelectTest.Value == 2 )
   AAdd( aFilters, { 'Rar', '*.rar' } )
   AAdd( aFilters, { 'Arj', '*.arj' } )
   AAdd( aFilters, { 'Chm', '*.chm' } )
   AAdd( aFilters, { 'Lzh', '*.lzh' } )
Endif

If Empty( cFile := GetFile( aFilters, 'Select archive', GetCurrentFolder(), .F., .T. ) )
   Return
Endif

// Оглавление архива выводим во временный файл и далее считываем для показа в
// программе.

// Можно, конечно, вместо GetEnv( 'COMSPEC' ) употребить просто cmd.exe, но 
// имя командного процессора может отличаться в старых версиях Windows

cCommand := GetEnv( 'COMSPEC' ) + ' /C '

If ( wMain.rdgSelectTest.Value == 2 )
   // Кавычки не помешают, т.к. Program Files имеет пробел в имени.
   // Здесь нужно использовать именно %ProgramFiles%\7-Zip\7z.exe, т.к.
   // графический вариант 7zG.exe не поддерживает перенаправление вывода в файл
   cCommand := ( cCommand + '"' + cPath7z + '"' )
Else
   cCommand := ( cCommand + ALONE_7Z )
Endif

// А информацию будем выводить не в табличном, а в техническом режиме (переключатель
// -slt). Тогда каждый файл файл будет описываться в несколько строчек примерно так
// (варируется в зависиомости от типа архива):
// Path = Наш файл архива
// Size = 
// Packed Size = 
// Modified = 
// Attributes = 
// CRC =
// Method =
// Block =
// а имя элемента архива будет выводиться в строке маркированой Path = 

// Временный файл содержания лучше, конечно бы создавать в
// системной папке временных файлов ( GetTempFolder() + '\' + cTmpFile ) 

cCommand += ( ' L -slt ' + cFile + ' > ' + cTmpFile )

Execute File ( cCommand ) Wait Hide

// Более изысканным решением было бы перенаправить вывод консольной программы
// функцией WinAPI (использовать CreatePipe и работать с ним как с обычным 
// файлом), а не создавать временный файл, но я не такой тонкий знаток.

If File( cTmpFile )

   // Временный файл может и не создаться, например, вследствии ошибок
   // в строке команды. Дополнительно не мешало бы проверить и его размер.
   // Если нулевой - то в нём нет ничего.

   // Заполняем массив

   oFile := TFileRead() : New( cTmpFile )
   oFile : Open()

   If !oFile : Error()

      Do While oFile : MoreToRead()

         If !Empty( cString := oFile : ReadLine() )

            // Несколько упрщённая обработка. Просто проверяем, не начинается
            // ли строка с "Path =" и, если да - то это имя файла. При
            // необходимости, можно сделать посложнее. Например, игнорировать
            // имена каталогов (строка "Attributes = D...." для файлов .7z)

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

         // Заполнить строку состояния (в ней будет храниться имя считанного
         // архива, необходимое для извлечения файлов)

         ShowStatus( cFile, ( 'Count files: ' + LTrim( Str( Len( aFiles ) ) ) )   , ;
                     Upper( Right( cFile, ( Len( cFile ) - RAt( '.', cFile ) ) ) ), ;
                     Iif( ( wMain.rdgSelectTest.Value == 2 ), '7-Zip', '7za' ) )

      Endif

   Endif

   If ( wMain.grdContent.ItemCount > 0 )
      wMain.btnExtract.Enabled := .T.
   Endif

Endif

// Временный файл сыграл свою роль и м.б. удалён. Команда не
// вызывает ошибку и в том случае, когда удаляемый файл не существует.

FErase ( cTmpFile )
 
Return

****** End of ViewArcExternal ******


/******
*
*       ExtractArcExternal()
*
*       Извлечение файлов из архива
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

   // Извлекать с сохранением структуры каталогов или нет
    
   cCommand := ( Iif( wMain.cbxExtract.Value, 'X', 'E' ) + ' ' )
   
   // Перезаписывать существующие файлы без предупреждения
   
   If wMain.cbxYesAll.Value
      cCommand += '-y '
   Endif
   
   cCommand += ( '-o' + cDir + ' ' )    // Куда извлечь
   
   cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )
   
   If ( Len( aPos ) == wMain.grdContent.ItemCount )

      cCommand += '*.*'

   Else
   
      For Each nPos In aPos
           
         // Позиции, содержащие только имя каталога, пропускаем
           
         cFile := AllTrim( wMain.grdContent.Item( nPos )[ 1 ] )
           
         If !( Right( cFile, 1 ) == '\' )
            cCommand += ( cFile + ' ' )
         Endif
           
      Next
    
      cCommand := RTrim( cCommand )

   Endif

   If ( wMain.rdgSelectTest.Value == 2 )
      
      // Если вместо 7z.exe использовать 7zG.exe, то будет отображаться
      // индикатор работы

      cCommand := ( cPath7z + ' ' + cCommand )
   Else
      cCommand := ( ALONE_7Z + ' ' + cCommand )
   Endif

   // Выполняем.

   If wMain.cbxHide.Value .and. !wMain.cbxYesAll.Value
      Execute File ( cCommand ) Wait Hide
   Else
      Execute File ( cCommand ) Wait
   Endif

   MsgInfo( 'Extraction is successfully.', 'Result' )

Endif

Return

****** End of ExtractArcExternal ******
