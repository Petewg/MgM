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
*       Доступ к архивам 7z, zip с использованием динамической
*       библиотеки 7-zip32.dll (Japanese http://www.csdinc.co.jp/archiver/lib/
*       English http://www.csdinc.co.jp/archiver/lib/main-e.html)
*
*/

PROCEDURE Main
LOCAL oReg

// Формируем полное имя установленного 7-Zip через запись в реестре

OPEN REGISTRY oReg KEY HKEY_CURRENT_USER Section 'Software\7-Zip'

   GET VALUE cPath7z NAME 'Path' OF oReg

CLOSE REGISTRY oReg

IF !Empty( cPath7z )
   cPath7z := hb_DirSepAdd( cPath7z )
   cPath7z += '7z.exe'
ELSE
   // Ошибка - нет соответствующей записи в реестре
   MsgAlert( 'The 7-Zip archiver is not found.', 'Alert' )
ENDIF

IF ( !File( cPath7z  ) .AND. ;
         !File( ALONE_7Z )   ;
         )

// Если нет установленного 7-Zip и консольного варианта архиватора,
// то и дальнейшие действия запрещаем.
// Хотя здесь есть нюанс: использование одной 7-zip32.dll без 7-Zip
// позволяет просматривать архив, но не позволяет создавать или
// извлекать из него файлы.

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

// Отображаем содержимое выбранного архива.

   @ 30, 5 Grid grdContent            ;
      Width 520                  ;
      Height 285                 ;
      Headers { 'Name' }         ;
      Widths { 400 }             ;
      Multiselect

// Операции открытия архива, извлечения и создания

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

// Некоторые установки обработки

   DEFINE PAGE 'Options'

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
      ON Change wMain.btnExtract.Enabled := .F.     ;
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

// Устанавливаем доступ к вариантам теста

IF !File( cPath7z )

// Доступен только запуск консольной версии архиватора

   wMain.rdgSelectTest.Enabled( 1 ) := .F.
   wMain.rdgSelectTest.Enabled( 2 ) := .F.
   wMain.rdgSelectTest.Value := 3

   IF !File( ALONE_7Z )

// Нет нужных файлов. Запрещаем всё

      wMain.rdgSelectTest.Enabled := .F.
      wMain.rdgSelectTest.Value   := 0

   ENDIF

ELSE

// При отсутствии динамической библиотеки и консольной версии
// архиватора посмотреть можно только действие установочной версии 7-Zip

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
*       Запуск обработки. Чем будет выполнятся обработка
*       устанавливается селектором rdgSelectTest
*/

STATIC PROCEDURE RunTest( nChoice )

   LOCAL nSelected := wMain.rdgSelectTest.Value

   DO CASE
   CASE ( nChoice == 1 )        // Создание архива

      IF ( nSelected == 1 )
         // Обработать 7-zip32.dll
         CreateArc()
      ELSE
         // Запустить 7z.exe или 7za.exe
         CreateArcExternal()
      ENDIF

   CASE ( nChoice == 2 )        // Просмотр содержимого

      IF ( nSelected == 1 )
         ViewArc()
      ELSE
         ViewArcExternal()
      ENDIF

   CASE ( nChoice == 3 )        // Извлечение файлов

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
*       Отображение элементов строки состояния
*
*/

STATIC PROCEDURE ShowStatus( cFile, cCount, cType, cVersion )

   wMain.StatusBar.Item( 1 ) := cFile      // Обрабатываемый файл
   wMain.StatusBar.Item( 2 ) := cCount     // Файлов в архиве
   wMain.StatusBar.Item( 3 ) := cType      // Тип архива
   wMain.StatusBar.Item( 4 ) := cVersion   // Информация о процедуре

RETURN

***** End of ShowStatus ******


// --------------------------------------------------------------
// Блок процедур для 7-zip32.dll
// --------------------------------------------------------------

/******
*
*       Version7zip() --> cVersion
*
*       Версия архиватора 7-zip и 7-zip32.dll
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
*       Создание архива
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

         // Определяем тип архива. По умолчанию используется 7z, поэтому
         // запоминаем только в случае изменения в диалоговом окне.

         IF ( Upper( Right( cArcFile, 3 ) ) == 'ZIP' )
            cType := 'zip'
         ENDIF

         // Строим строку команды для передачи в DLL

         IF wMain.cbxHide.Value
            cCommand += '-hide '       // Не отображать процесс
         ENDIF

         IF !Empty( cType )
            cCommand += '-tzip '       // В формате ZIP
         ENDIF

         cCommand += ( cArcFile + ' ' )

         // Указываем файлы для обработки

         AEval( aSource, {| elem | cCommand += ( '"' + elem + '" ' ) } )

         cCommand := RTrim( cCommand )

         IF !( ( nDLLHandle := LoadLibrary( '7-zip32.dll' ) ) > 0 )
            MsgStop( "Can't load 7-zip32.dll.", 'Error' )
         ELSE
            DllCall( nDLLHandle, DC_CALL_STD, 'SevenZip', _HMG_MainHandle, cCommand )
            FreeLibrary( nDLLHandle )

            // Заполнить строку состояния

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
*       Открыть архив и заполнить таблицу содержания
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

   nArcHandle := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipOpenArchive', _HMG_MainHandle, cFile, 0 )   // Открыть архив

   IF Empty( nArcHandle )
      MsgStop( cFile + ' not opened.', 'Error' )
      RETURN
   ENDIF

   nCount  := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileCount', cFile )  // Количество элементов в архиве
   nResult := DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetArchiveType', cFile )  // Тип архива

   DO CASE
   CASE ( nResult == 1 )
      cType := 'ZIP'

   CASE ( nResult == 2 )
      cType := '7Z'

   CASE ( nResult == -1 )
      // Ошибка обработки
      cType := 'Error'

   CASE ( nResult == 0 )
      // Не поддерживаемый тип. Хотя при попытке открыть что-нибудь
      // кроме 7z и Zip функция SevenZipOpenArchive() будет
      // возвращать ошибку.
      cType := '???'

   ENDCASE

   // Инициализация структуры, необходимой для обработки элементов архива и
   // указателя (для передачи в DLL)

   oInfo := ( STRUCT INDIVIDUALINFO )
   pInfo := oInfo : GetPointer()

   // Ищем 1-й файл. Если результат поиска не имеет значения, передачу pInfo
   // можно опустить.

   DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipFindFirst', nArcHandle, '*', pInfo )

   // Переустанавливаем указатель

   oInfo := oInfo : Pointer( pInfo )

   cValue := Space( FNAME_MAX32 )
   DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipGetFileName', nArcHandle, @cValue, FNAME_MAX32 )

   IF !Empty( cValue )

      // Заполняем таблицу формы. Вначале значения заносим в массив,
      // сортируем и передаём Grid

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

   // Закрыть архивный файл, выгрузить библиотеку

   DllCall( nDLLHandle, DC_CALL_STD, 'SevenZipCloseArchive', nArcHandle )
   FreeLibrary( nDLLHandle )

   // Заполнить строку состояния

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
*       Извлечение файлов из архива
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

      // Извлекать с сохранением стуктуры каталогов или нет

      cCommand := ( iif( wMain.cbxExtract.Value, 'x', 'e' ) + ' ' )

      IF wMain.cbxHide.Value

         // Не отображать процесс. Но если потребуется перезапись
         // существующих файлов, соответсвующий запрос всё равно
         // будет выведен.

         cCommand += '-hide '

      ENDIF

      // Перезаписывать существующие файлы без предупреждения

      IF wMain.cbxYesAll.Value
         cCommand += '-y '
      ENDIF

      cCommand += ( '-o' + cDir + ' ' )    // Куда извлечь

      // Не забыть добавить имя архива, содержащего извлекаемые файлы

      // cCommand += ( '"' + AllTrim( wMain.Statusbar.Item( 1 ) ) + '" ' )
      cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )

      // Добавляем извлекаемые файлы. Для упрощения обработки:
      // если количество отмеченных элементов равно общему
      // количеству, то нет смысла выполнять перебор.

      IF ( Len( aPos ) == wMain.grdContent.ItemCount )
         cCommand += '*.*'
      ELSE

         FOR EACH nPos In aPos

            // Позиции, содержащие только имя каталога, пропускаем

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


// Процедуры в 7-zip32.dll

// Версия и подверсия библиотеки

DECLARE DLL_TYPE_WORD SevenZipGetVersion() in 7-zip32.dll
DECLARE DLL_TYPE_WORD SevenZipGetSubVersion() in 7-zip32.dll


// --------------------------------------------------------------
// Блок процедур для 7-zip 7za.exe
// --------------------------------------------------------------

/******
*
*       CreateArcExternal()
*
*       Создание архива
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

      // Обращение непосредственно к самому 7-Zip позволяет создавать
      // большее количество типов архивов

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

         // Определяем тип архива. По умолчанию используется 7z, поэтому
         // запоминаем только в случае изменения в диалоговом окне.

         nPos := RAt( '.', cArcFile )
         cExt := Upper( Right( cArcFile, ( Len( cArcFile ) - nPos ) ) )

         IF !( cExt == '7Z' )
            cType := cExt
         ENDIF

         // Строим строку команды

         IF !Empty( cType )
            cCommand += ( '-t' + cType + ' ' )
         ENDIF

         cCommand += ( cArcFile + ' ' )

         // Указываем файлы для обработки

         AEval( aSource, {| elem | cCommand += ( '"' + elem + '" ' ) } )

         // Запускаем или установленный архиватор или консольную
         // версию, ноходящуюся в папке с демонстрационной программой

         IF ( wMain.rdgSelectTest.Value == 2 )
            cCommand := ( cPath7z + cCommand )
         ELSE
            cCommand := ( ALONE_7Z + cCommand )
         ENDIF

         cCommand := RTrim( cCommand )

         // Запускаем в режиме ожидания окончания обработки. Если
         // при этом само окно архиватора скрыто (для эстетики, т.к. окно
         // консольное), для отображения о том, что работа выполняется (если
         // архив большой), можно вывести какое-нибудь информационное окно,
         // например с таймером.

         // Есть ещё вариант: для 7-Zip запускать не %ProgramFiles%\7-Zip\7z.exe,
         // а %ProgramFiles%\7-Zip\7zG.exe - графический интерфейс архиватора.
         // Получим на экране чудненький индикатор процесса обработки.

         IF wMain.cbxHide.Value
            Execute File ( cCommand ) WAIT Hide
         ELSE
            Execute File ( cCommand ) Wait
         ENDIF

         // Заполнить строку состояния

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
*       Открыть архив и заполнить таблицу содержания
*
*/

STATIC PROCEDURE ViewArcExternal
   // aFiles - набор поддерживаемых типов архивов. Базовым принимаем набор для
   // консольной версии (7za.exe), т.к. её возможности скромнее.
   LOCAL aFilters := { { '7-zip', '*.7z'   }, ;
      { 'Zip', '*.zip'  }, ;
      { 'Cab', '*.cab'  }, ;
      { 'GZip', '*.gzip' }, ;
      { 'Tar', '*.tar'  } ;
      }, ;
      cFile, ;
      aFiles    := {}, ;
      cCommand, ;
      cTmpFile  := '_Arc_.lst', ;     // Или GetTempFolder() + '\_Arc_.lst'
      oFile, ;
      cString

   // Добавим типы архивов, с которыми может работать полная версия (не все,
   // указанные в документации, конечно)

   IF ( wMain.rdgSelectTest.Value == 2 )
      AAdd( aFilters, { 'Rar', '*.rar' } )
      AAdd( aFilters, { 'Arj', '*.arj' } )
      AAdd( aFilters, { 'Chm', '*.chm' } )
      AAdd( aFilters, { 'Lzh', '*.lzh' } )
   ENDIF

   IF Empty( cFile := GetFile( aFilters, 'Select archive', GetCurrentFolder(), .F., .T. ) )
      RETURN
   ENDIF

   // Оглавление архива выводим во временный файл и далее считываем для показа в
   // программе.

   // Можно, конечно, вместо GetEnv( 'COMSPEC' ) употребить просто cmd.exe, но
   // имя командного процессора может отличаться в старых версиях Windows

   cCommand := GetEnv( 'COMSPEC' ) + ' /C '

   IF ( wMain.rdgSelectTest.Value == 2 )
      // Кавычки не помешают, т.к. Program Files имеет пробел в имени.
      // Здесь нужно использовать именно %ProgramFiles%\7-Zip\7z.exe, т.к.
      // графический вариант 7zG.exe не поддерживает перенаправление вывода в файл
      cCommand := ( cCommand + '"' + cPath7z + '"' )
   ELSE
      cCommand := ( cCommand + ALONE_7Z )
   ENDIF

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

   Execute File ( cCommand ) WAIT Hide

   // Более изысканным решением было бы перенаправить вывод консольной программы
   // функцией WinAPI (использовать CreatePipe и работать с ним как с обычным
   // файлом), а не создавать временный файл, но я не такой тонкий знаток.

   IF File( cTmpFile )

      // Временный файл может и не создаться, например, вследствии ошибок
      // в строке команды. Дополнительно не мешало бы проверить и его размер.
      // Если нулевой - то в нём нет ничего.

      // Заполняем массив

      oFile := TFileRead() : New( cTmpFile )
      oFile : Open()

      IF !oFile : Error()

         DO WHILE oFile : MoreToRead()

            IF !Empty( cString := oFile : ReadLine() )

               // Несколько упрщённая обработка. Просто проверяем, не начинается
               // ли строка с "Path =" и, если да - то это имя файла. При
               // необходимости, можно сделать посложнее. Например, игнорировать
               // имена каталогов (строка "Attributes = D...." для файлов .7z)

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

            // Заполнить строку состояния (в ней будет храниться имя считанного
            // архива, необходимое для извлечения файлов)

            ShowStatus( cFile, ( 'Count files: ' + LTrim( Str( Len( aFiles ) ) ) ), ;
               Upper( Right( cFile, ( Len( cFile ) - RAt( '.', cFile ) ) ) ), ;
               iif( ( wMain.rdgSelectTest.Value == 2 ), '7-Zip', '7za' ) )

         ENDIF

      ENDIF

      IF ( wMain.grdContent.ItemCount > 0 )
         wMain.btnExtract.Enabled := .T.
      ENDIF

   ENDIF

   // Временный файл сыграл свою роль и м.б. удалён. Команда не
   // вызывает ошибку и в том случае, когда удаляемый файл не существует.

   FErase ( cTmpFile )

RETURN

***** End of ViewArcExternal ******


/******
*
*       ExtractArcExternal()
*
*       Извлечение файлов из архива
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

      // Извлекать с сохранением структуры каталогов или нет

      cCommand := ( iif( wMain.cbxExtract.Value, 'X', 'E' ) + ' ' )

      // Перезаписывать существующие файлы без предупреждения

      IF wMain.cbxYesAll.Value
         cCommand += '-y '
      ENDIF

      cCommand += ( '-o' + cDir + ' ' )    // Куда извлечь

      cCommand += ( AllTrim( wMain.Statusbar.Item( 1 ) ) + ' ' )

      IF ( Len( aPos ) == wMain.grdContent.ItemCount )

         cCommand += '*.*'

      ELSE

         FOR EACH nPos In aPos

            // Позиции, содержащие только имя каталога, пропускаем

            cFile := AllTrim( wMain.grdContent.Item( nPos )[ 1 ] )

            IF !( Right( cFile, 1 ) == '\' )
               cCommand += ( cFile + ' ' )
            ENDIF

         NEXT

         cCommand := RTrim( cCommand )

      ENDIF

      IF ( wMain.rdgSelectTest.Value == 2 )

         // Если вместо 7z.exe использовать 7zG.exe, то будет отображаться
         // индикатор работы

         cCommand := ( cPath7z + ' ' + cCommand )
      ELSE
         cCommand := ( ALONE_7Z + ' ' + cCommand )
      ENDIF

      // Выполняем.

      IF wMain.cbxHide.Value .AND. !wMain.cbxYesAll.Value
         Execute File ( cCommand ) WAIT Hide
      ELSE
         Execute File ( cCommand ) Wait
      ENDIF

      MsgInfo( 'Extraction is successfully.', 'Result' )

   ENDIF

RETURN

***** End of ExtractArcExternal ******
