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
История изменений.

+ добавлено
* изменено
- удалено

Август 2009 г.

* файлы из Zip-архива извлекаются и открываются нормально.
  Решено заменой библиотеки hbzlib.lib на ziparchive.lib и вызовом
  процедуры HB_OEMtoANSI() во время обработки строк файла технической
  информации, созданного 7-Zip
* для получения оглавления Zip-архивов вместо функции ZipIndex() 
  используется типовая HB_GetFilesInZip(). ZipIndex() оставлена в
  тексте программы в закомментированном виде (на всякий случай).
+ последние версии 7-Zip вносят в файл технической информации о
  содержимом архива имя самого архива, вследствии чего в дереве
  создаются лишние элементы. Поэтому при обработке строки, содержащие
  имя обрабатываемого архива игнорируются.
+ прерывание операции формирования дерева

Октябрь 2008 г.

Начальная версия.
*/


#include "HBCompat.ch"
#include "Directry.ch"
#include "MiniGUI.ch"

// Программные файлы архиватора 7-Zip

#define FULL_7Z             '7z.exe'         // Полная версия
#define DLL_7Z              '7z.dll'         // Библиотека к полной версии  
#define ALONE_7Z            '7za.exe'        // Консольный вариант  

#define TEMP_FOLDER         ( GetTempFolder() + '\' )
#define TMP_ARC_INDEX       ( TEMP_FOLDER + '_Arc_.lst' )     // Временный файл для вывода содержания архива
                                               
// Прерывание обработки

#translate BREAK_ACTION_()                                                                                 ;
           =>                   lBreak := MsgYesNo( 'Stop operation?', 'Confirm action', .T., , .F., .F. )

// Изменение кнопки обработки

// 1) Исходное значение: запуск сканирования
#translate SET_DOSCAN_()                                                           ;
           =>                   wMain.ButtonEX_1.Caption     := 'Scan'             ;
                                ; wMain.ButtonEX_1.Picture   := 'OK'               ;
                                ; wMain.ButtonEX_1.Action    := { || BuildTree() } 
// 2) Построение дерева: прерывание обработки
#translate SET_STOP_SCAN_()                                                        ;
           =>                   wMain.ButtonEX_1.Caption   := '[Esc] Stop'         ;
                                ; wMain.ButtonEX_1.Picture := 'STOP'               ;
                                ; wMain.ButtonEX_1.Action  := { || BREAK_ACTION_() }


Static cApp7z   := ''         // Архиватор 7-Zip
Static cOSPaths := ''         // Значения системной переменной PATH (используется только для полной версии 7-Zip)

Memvar lBreak                 // Прервать обработку


/******
*
*    Дерево каталогов и файлов
*
*/

Procedure Main
Local cSysPath := Upper( GetEnv( 'PATH' ) ), ;
      cPath7z  := ''                       , ;
      oReg

Set font to 'Tahoma', 9

// Для работы с архивами (кроме Zip) используем 7-Zip. Проверяем один из вариантов:
// - архиватор инсталлирован (полная версия);
// - в каталог с программой помещены файлы 7z.exe и 7z.dll (архиватор не инсталлирован, но
//   функциональность практически та же, что и в установочной версии);
// - в каталоге с программой размещена консольная версия (7za.exe)
// Выбираем лучший из вариантов. Для этого проверяем доступность необходимых программ. Размещение
// полной версии 7-Zip (предпочтительное использование) ищем через запись реестра
// Кроме того, при использовании 7-Zip, размещённого в Program Files, проявляются некоторые недостатки
// командной строки - не выполняется команда, в которой и в имени программы, и файле-параметре 
// используются имена с пробелами:
// %COMSPEC% /C "%\ProgramFiles%\7-Zip\7z.exe" L -slt "Some data.7z"
// Для обхода такой ситуации в системную переменную PATH добавляем маршрут поиска 7z.exe, а после
// завершения обработки - восстанавливаем исходное значение PATH.
// Если 7z.exe и 7z.dll находятся в каталоге программы, значение PATH не изменяется.
 
// Для архивов Zip всегда используем встроенные возможности.

Open registry oReg key HKEY_LOCAL_MACHINE Section 'Software\7-Zip'
Get value cPath7z Name 'Path' of oReg 
Close registry oReg

If !Empty( cPath7z )                              // Инсталлированная версия

   cPath7z := Upper( cPath7z )
   
   If !( cPath7z $ cSysPath )
      
      cOSPaths := cSysPath
      
      If !( Right( cOSPaths, 1 ) == ';' )
         cOSPaths += ';'
      Endif
      
      cOSPaths += ( cPath7z + '\' ) 
      cApp7z := FULL_7Z
            
   Endif
   
ElseIf ( File( FULL_7Z ) .and. File( DLL_7Z ) )   // В каталоге с программой находится 7z.exe и 7z.dll
   cApp7z := FULL_7Z
   
ElseIf File( ALONE_7Z )                           // В каталоге с программой находится 7za.exe
   cApp7z := ALONE_7Z

Endif

Load window Demo as wMain

wMain.BtnTextBox_1.Value := GetMyDocumentsFolder()   // Каталог для сканирования по умолчанию

// При обнаружении консольной версии 7-Zip расширяем список доступных архивных форматов,
// хотя, например, для обработки RAR нужно использовать полную версию 7-Zip 

If !Empty( cApp7z )
   
   // Поддерживаемые типы архивов для полной и консольной версии
   
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
*       Выбор каталога для сканирования
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
*       Построение дерева
*
*/

Static Procedure BuildTree
Local cPath     := wMain.BtnTextBox_1.Value, ;
      cSavePath := ''

Private lBreak := .F.          // Прервать обработку
SET_STOP_SCAN_()
On key Escape of wMain Action BREAK_ACTION_()

If !Empty( cPath )

   // Для использования установочной версии 7-Zip изменяем системную
   // переменную PATH
   
   If !Empty( cOSPaths )
      cSavePath := GetEnv( 'PATH' )
      SetEnvironmentVariable( 'PATH', cOSPaths )
   Endif
   
   wMain.Tree_1.DeleteAllItems
   wMain.Tree_1.DisableUpdate

   // Вначале добавим узел корневого каталога

   Node wMain.BtnTextBox_1.Value Images { 'STRUCTURE' }
      ScanDir( cPath )
   End Node
   wMain.StatusBar.Item( 1 ) := ''
   
   // Восстановить исходное значение системной переменной PATH (если она
   // была изменена).
   
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
*       Сканирование каталога
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

   // Поскольку для выборки может использоваться маска, поступаем следующим образом.
   // 1) Получаем список ВСЕХ подкаталогов выбранной директории (маска не учитывается,
   //    поскольку при этом могут игнорироваться сами подкаталоги)
   // 2) Для каждого подкаталога формируется список принадлежащих ему файлов
   //    С УЧЕТОМ ШАБЛОНА
   // 3) Подкаталог не добавляется в дерево, если требуемых файлов нет и не разрешено
   //    добавление пустых каталогов
 
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

   // Обрабатываем полученный список каталогов. При этом выполняется рекурсивный
   // вызов процедуры для сканирования более глубоких уровней

   If !Empty( aDir )

      For each xItem in aDir

        // Перед добавлением узла каталога проверяем наличие в нём
        // файлов, совпадающих с шаблоном или подкаталогов. Имена самих файлов пока
        // не важны.
     
        // Хотя можно проверять только наличие файлов:
        // If !Empty( Directory( ( cPath + xItem + '\' + cMask ), cAttr ) )
        // Только в этом случае каталоги, в которых нет файлов (по заданной маске), 
        // но есть подкаталоги, в построение включены не будут, как и файлы, находящиеся
        // в них. 
     
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

   // Добавляем список файлов

   If !Empty( aFiles := ASort( Directory( ( cPath + cMask ), cAttr ),,, ;
                               { | x, y | Upper( x[ F_NAME ] ) < Upper( y[ F_NAME ] ) } ) )

      For each xItem in aFiles
      
         wMain.StatusBar.Item( 1 ) := ( cPath + xItem[ F_NAME ] )
         
         Do Events
      
         If !wMain.Check_2.Value         // Не расскрывать архивы
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
*       Обработка архивного файла
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
   
   // Если расширение принадлежит архивному типу, получаем содержание
   // архива. При этом архивы ZIP обрабатываются собственными средствами.
   // а остальные - внешним архиватором
   
   If !( cExt $ cArcTypes )
      TreeItem cFile
      
   Else
   
      // Оглавление архива получаем 2-я способами: собственной обработкой
      // ZIP и запуском 7-Zip. Список файлов в Zip-архиве можно получить и
      // готовой функцией HB_GetFilesInZip( cPath + cFile ).
      // В предыдущих версиях Harbour замечалось падение программы с системной
      // ошибкой при выполнении этой функции на большом количестве архивов, 
      // поэтому была создана функция ZipIndex(). Но в настоящее время все вроде 
      // нормально, поэтому ZipIndex() оставлена в тексте программы, но не используется.
      
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


// Функция ZipIndex() использовалась как аналог HB_GetFilesInZip(), но в последних
// версиях Harbour необходимость в ней отпала. Оставлена для истории.
  
/******
*
*       ZipIndex( cArcFile ) --> aFiles
*
*       Список файлов в архиве ZIP
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
*       Список файлов в архиве не ZIP-типа
*
*/

Static Function ArcIndex( cArcFile )
Local aFiles   := {}                                       , ;
      cCommand := ( GetEnv( 'COMSPEC' ) + ' /C ' + cApp7z ), ;
      cString, oFile

// Оглавление архива выводим во временный файл и далее считываем для показа в
// программе.

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

cCommand += ( ' L -slt "' + cArcFile + '" > ' + TMP_ARC_INDEX )
Execute file ( cCommand ) Wait Hide

If File( TMP_ARC_INDEX )

   // Временный файл может и не создаться, например, вследствие ошибок
   // в строке команды. Дополнительно не мешало бы проверить и его размер.
   // Если нулевой - то в нём нет ничего.

   // Заполняем массив
  
   oFile := TFileRead() : New( TMP_ARC_INDEX )
   oFile : Open()

   If !oFile : Error()

      Do while oFile : MoreToRead()
   
         If !Empty( cString := oFile : ReadLine() )
   
            // Несколько упрощённая обработка. Просто проверяем, не начинается
            // ли строка с "Path =" и, если да - то это имя файла. При
            // необходимости, можно сделать посложнее. Например, игнорировать
            // имена каталогов (строка "Attributes = D...." для файлов .7z)
          
            If ( Left( cString, 7 ) == 'Path = ' )
            
               cString := HB_OEMtoANSI( AllTrim( Substr( cString, 8 ) ) )

               // Последние версии 7-Zip в отчет о содержимом архива добавляют
               // наименование самого архива (также в строке "Path =").
               // Поэтому вводим проверку.
               
               If !( Upper( cArcFile ) == Upper( cString ) )
                  AAdd( aFiles, cString )
               Endif
               
            Endif
         
         Endif
      
      Enddo

      oFile : Close()

   Endif

Endif

// Временный файл сыграл свою роль и м.б. удалён.

Erase ( TMP_ARC_INDEX )
 
Return aFiles

****** End of ArcIndex ******


/******
*
*       ShowTreeNode( nMode )
*
*       Развернуть (1) или свернуть (0) все узлы дерева
*
*/

Static Procedure ShowTreeNode( nMode )
Local nCount := wMain.Tree_1.ItemCount, ;
      Cycle

If !Empty( nCount )

   wMain.Tree_1.DisableUpdate

   For Cycle := 1 to nCount
   
     // Обрабатываем только элементы, не имеющие дочерних ветвей (узлы)

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
*       Проверка, является ли элемент дерева узлом
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

// Элемент дерева считается узлом, если имеет подчинённые элементы

Return !Empty( TreeView_GetChild( nHandle, nTreeItemHandle ) )

****** End of IsTreeNode ******


/******
*
*       OpenObj( cFormName, cTreeName )
*
*       Открыть текущий объект, представленный элементом дерева
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

// Обрабатываем ветвь в обратном порядке для определения маршрута к файлу

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

// Полученное значение м.б. каталогом, файлом или файлом в архиве. В последнем случае
// файл может располагаться внутри подкаталога, занесённого в архив. 

If ( HB_DirExists( cChain ) .or. File( cChain ) )

   // Каталог или файл. Для каталога открываем обзор, для файла - запускаем ассоциированную программу.
   // !!! Файлы с атрибутом "Скрытый" в эту ветвь не попадают.
   
   Execute operation 'Open' file ( '"' + cChain + '"' )

Else

  // Файл в архиве. Разбиваем полное имя и определяем наименование самого архива.
  
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

  // Имя архива исключаем из полученной строки описания. 
  
  cChain := Substr( cChain, ( Len( cArcName ) + 1 ) )  // Теперь это имя файла в архиве
  
  If ( Left( cChain, 1 ) == '\' )
     cChain := Substr( cChain, 2 )
  Endif
  
  // Ещё раз выполнить проверку существования файла, поскольку в эту
  // ветвь попадает обработка файлов с атрибутом "Скрытый".
  
  If File( cArcName )
  
     HB_FNameSplit( cArcName, , , @cExt )

     If !Empty( cExt := Upper( cExt ) )

        If ( Left( cExt, 1 ) == '.' )
           cExt := Substr( cExt, 2 )
        Endif
        
        If ( cExt == 'ZIP' )
           
           // Архивы ZIP обрабатываются собственными средствами.
           
           // !!! Файлы в архиве с кириллицей в имени внутренним ZIP не извлекаются.
           // Лучше воспользоваться 7-Zip

           If HB_UnZipFile( cArcName,,,, TEMP_FOLDER, cChain )

              // Подкаталоги в Zip-архиве могут разделяться прямым слэшем, поэтому
              // путь преобразовываем.

              cChain := Slashs( cChain )

              // Запускаем ассоциированную программу просмотра, ожидаем её завершения
              // и удаляем извлечённый файл (при необходимости - и каталог).
              
              // !!! Данные в архиве не обновляются.
           
              ShowFile( cChain )
           
              If !Empty( nVal := At( '\', cChain ) )
                 
                 cChain := Left( cChain, ( nVal - 1 ) )
                 
                 If HB_DirExists( TEMP_FOLDER + cChain )
                    DirRemove( TEMP_FOLDER + cChain )
                 Endif
                 
              Endif
              
           Endif
                      
        Else
        
           // Обработка 7-Zip
         
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
           
           // Здесь выполнять просмотр нужно только по имени файла.
           
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
*       Изменение разделителей каталогов, используемых в
*       архивах, на системные
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
*       Открыть извлечённый из архива файл.
*       После завершения просмотра файл удаляется.
*
*/

Static Procedure ShowFile( cChain )
Local cExt, ;
      cApp, ;
      nPos

// Если в полученном имени файла содержится часть пути (сохранённая в архиве),
// необходимо избавиться от неё.

If ( ( nPos := RAt( '\', cChain ) ) > 0 )
   cChain := Substr( cChain, ( nPos + 1 ) )
Endif

If File( TEMP_FOLDER + cChain  )

   HB_FNameSplit( cChain, , , @cExt )
                  
   // Определить ассоциированную программу и открыть в ней файл.
   // Если программа не будет сопоставлена, попробовать просто
   // выполнить извлечённый файл (как вариант, можно назначить
   // программу, в которой будут открываться все файлы).
                  
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
*       Определение программы, связанной с расширением.
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

// Принцип действия. В HKEY_CLASSES_ROOT ищем ветвь, соответсвующую переданному
// расширению (с ведущей точкой) и определяем наименование типа файла (параметр
// "(По умолчанию)". Например, для расширения "jpg" ищем HKEY_CLASSES_ROOT\.jpg
// и получаем имя ассоциации - "jpegfile".
// В этой же ветке HKEY_CLASSES_ROOT ищем строку запуска программы, связанной с
// этим типом файла (HKEY_CLASSES_ROOT\<имя ассоциации>\shell\open\command)
// Например, HKEY_CLASSES_ROOT\jpegfile\shell\open\command
// В значении параметра "(По умолчанию)" находится команда открытия этого типа
// файла: "C:\\Program Files\\Internet Explorer\\iexplore.exe\" -nohome

If ( !Left( cExt, 1 ) == '.' )
   cExt := ( '.' + cExt )
Endif

oReg  := TReg32() : New( HKEY_CLASSES_ROOT, cExt, .F. )
cVar1 := RTrim( StrTran( oReg : Get( Nil, '' ), Chr( 0 ), ' ' ) )   // Значение ключа "(По умолчанию)"
oReg : Close()

If !Empty( cVar1 )

   oReg  := TReg32() : New( HKEY_CLASSES_ROOT, ( cVar1 + '\shell\open\command' ), .F. )
   cVar2 := RTrim( StrTran( oReg : Get( Nil, '' ), Chr( 0 ), ' ' ) )  // Значение ключа "(По умолчанию)"
   oReg : Close()

   // Обработка указаний на передачу параметров ассоциированной программе
   
   If ( nPos := RAt( ' %1', cVar2 ) ) > 0        // Параметр не обрамляется кавычками (Блокнот)
      cVar2 := SubStr( cVar2, 1, nPos )
      
   Elseif ( nPos := RAt( '"%', cVar2 ) ) > 0     // Параметры вида "%1", "%L" и т.д. (с кавычками)
      cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )
      
   Elseif ( nPos := RAt( '%', cVar2 ) ) > 0      // Параметры вида "%1", "%L" и т.д. (без кавычек)
      cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )
      
   Elseif ( nPos := RAt( ' /', cVar2 ) ) > 0     // Вставка "/"
      cVar2 := SubStr( cVar2, 1, ( nPos - 1 ) )
      
   Endif

Endif

Return RTrim( cVar2 )

****** End of GetOpenCommand ******



#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

// Данная функция есть в библиотеках Harbour/xHarbour
// Harbour - VWN_SETENVIRONMENTVARIABLE в CONTRIB\HBWHAT\whtmisc.c 
// xHarbour - SETENVIRONMENTVARIABLE в CONTRIB\WHAT32\SOURCE\_winmisc.c 

HB_FUNC_STATIC( SETENVIRONMENTVARIABLE )
{
   hb_retl( SetEnvironmentVariableA( hb_parcx( 1 ),
                                     hb_parcx( 2 )
                                     ) );
}

#pragma ENDDUMP
