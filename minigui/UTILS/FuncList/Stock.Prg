/*
  with GAL edition (Alexey L. Gustow <gustow33 [dog] mail.ru>)
  2011.Oct.01-08
*/

#include "Directry.ch"
#include "Common.ch"
#include "Inkey.ch"
#include "MiniGUI.ch"
#include "Stock.ch"


// Max amount of space character, adde to function name
// at saving to file

#define SPACES_TO_NAME            30
#define SPACES_TO_TYPE            20

// Bims in the catalog

#define SOURCE_PATH               '#Path '        // Path to sources
#define SOURCE_TITLE              '#Title '       // Catalog's description

// Work parameters

#define ONSTART_NONEACTION        1              // No startup action
#define ONSTART_OPENLAST          2              // To open MRU folder
#define SEARCH_EQUAL              1              // Search for exact correspondence
#define SEARCH_ENTRY              2              // Search for matched entry
#define EDITOR_SIMPLEOPEN         1              // To open in editor (without conditions)
#define EDITOR_GOTO               2              // To open and go to string
#define EDITOR_FIND               3              // To open and transfer the search expression

Memvar aOptions

Memvar gugupath // GAL


/******
*
*       Stock()
*
*       Inventory of the distribution's structure
*
*/

Procedure Main

// Проверка на наличие необходимых каталогов. Сообщения об
// ошибках выводяться без языкового изменения, поскольку
// требуемые файлы должны находиться в проверяемых каталогах.

If !DirCheck()
   MsgStop( "Don't create work directories!", 'Fatal error' )
   Quit
Endif

Set Navigation Extended
Set Font To 'Tahoma', 9

Private aOptions := ReadOptions()

//// GAL added (for path to sources)
Private gugupath := CurDrive() + ":\" + CurDir()
////

SetBaseLang()     // Установка языка сообщений

Define window wStock                                      ;
       At 132, 235                                        ;
       Width 556                                          ;
       Height 403                                         ;
       Title APPTITLE                                     ;
       Icon 'STOCK'                                       ;
       Main                                               ;
       On Init ReSize()                                   ;
       On Size ReSize()                                   ;
       On Maximize ReSize()                               ;
       On Minimize ReSize()

   // Панель инструментов

   Define Toolbar tbrTools ButtonSize 20, 20
       Button btnNew     Picture 'NEW'     Action NewList()  Tooltip 'Create new list'
       Button btnOpen    Picture 'OPEN'    Action LoadList() Tooltip 'Load list from file'
       Button btnSave    Picture 'SAVE'    Action SaveList() Tooltip 'Save to file'
       Button btnEdit    Picture 'EDIT'    Action OpenFile() Tooltip 'Open in external editor'
       Button btnOptions Picture 'OPTIONS' Action Options()  Tooltip 'Settings'
   End Toolbar

   // Размеры элементов диалога условны, т.к. их изменение выполняется программно.

   // Рабочий список. Его бы раскрасить, но назначение DynamicBackcolor
   // ОЧЕНЬ замедляет формирование нового списка.

   @ 31, 3 Grid grdContent                                   ;
           Width 535                                         ;
           Height 305                                        ;
           Headers { 'Name', 'Type', 'Comment' }             ;
           Widths { 200, 100, 200 }                          ;
           Font 'Tahoma' Size 10                             ;
           On change GridStatus()                            ;
           NoLines                                           ;
           Edit Inplace {}                                   ;
           ColumnWhen { { || .F. }, { || .F. }, { || .T. } }

   // Условие поиска

   @ 340, 5 Label lblSearch    ;
            Value 'Find'       ;
            Width 40 Height 18 ;
            FontColor BLUE     ;
            Bold

   @ ( wStock.lblSearch.Row - 4 ), ( wStock.lblSearch.Col + wStock.lblSearch.Width + 10 ) ;
     TextBox txbSearch                    ;
     Width 400                            ;
     Height 20                            ;
     UpperCase                            ;
     On change QSeek()                    ;
     On enter wStock.grdContent.SetFocus  ;
     Tooltip 'String for search'

   @ wStock.txbSearch.Row, ( wStock.txbSearch.Col + wStock.txbSearch.Width + 5 ) ;
     Button btnSearch   ;
     Picture 'FIND'     ;
     Width 20           ;
     Height 20          ;
     Action QSeek()     ;
     Tooltip 'Find more'

   @ wStock.btnSearch.Row, ( wStock.btnSearch.Col + wStock.btnSearch.Width + 5 ) ;
     Button btnFindAll  ;
     Picture 'FINDALL'  ;
     Width 20           ;
     Height 20          ;
     Action FindAll()   ;
     Tooltip 'Find all'

   // Строка состояния

   Define Statusbar
       StatusItem '' Default
       StatusItem '' Width 80 Default
   End Statusbar

   On key ALT+X of wStock Action wStock.Release

End Window

// Если указан языковой файл и он в наличии, выполняется инициализация

If ( !Empty( aOptions[ OPTIONS_LANGFILE ] )              .and. ;
     File( LANGFILE_PATH + aOptions[ OPTIONS_LANGFILE ] )      ;
   )
   BuildMenu( GetLangStrings( GET_MENU_LANG, aOptions[ OPTIONS_LANGFILE ] ) )
   ModifyMainForm( GetLangStrings( GET_MAINFORM_LANG, aOptions[ OPTIONS_LANGFILE ] ) )
Else   
   BuildMenu()
   ModifyMainForm()
Endif

// Если указано восстановление просмотра последнего файла

If ( aOptions[ OPTIONS_ONSTART ] == ONSTART_OPENLAST )
   If !Empty( aOptions[ OPTIONS_LASTFILE ] )
      LoadList( aOptions[ OPTIONS_LASTFILE ] )
   Endif
Endif

SetState()

Center window wStock
Activate window wStock

Return

****** End of Main ******


/*******
*
*       DirCheck() --> lSuccess
*
*       Checkup and creation of the folders
*
*/

Static Function DirCheck
Local lSuccess := .F.

Begin Sequence

  // Каталог даных
  
  If !CheckPath( DATA_PATH, .T. )
     Break
  Endif

  // Каталог языковых файлов
  
  If !CheckPath( LANGFILE_PATH, .T. )
     Break
  Endif

  lSuccess := .T.

End

Return lSuccess

****** End of DirCheck ******


/******
*
*       BuildMenu( aStrings )
*
*       Building the main menu of the program.
*       Separate procedure is exuded for possibility of
*       the change language interface.
*
*/

Procedure BuildMenu( aStrings )

If !( Valtype( aStrings ) == 'A' )
   aStrings := GetLangStrings( GET_MENU_LANG )
Endif

Define main menu of wStock

  Define popup aStrings[ 1, 2 ]             // File
    MenuItem aStrings[ 2, 2 ] ;
        Action NewList()      ;
        Message aStrings[ 3, 2 ]
    MenuItem aStrings[ 4, 2 ] ;
        Action LoadList()     ;
        Message aStrings[ 5, 2 ]
    MenuItem aStrings[ 6, 2 ] ;
        Action SaveList()     ;
        Name SaveList         ;
        Message aStrings[ 7, 2 ]
    Separator
    MenuItem ( aStrings[ 8, 2 ]  + '	Alt+X' ) ;
        Action ThisWindow.Release                     ;
        Message aStrings[ 9, 2 ]
  End Popup

  Define popup aStrings[ 10, 2 ]           // Edit
    MenuItem aStrings[ 11, 2 ] ;
        Action SetTitle()      ;
        Name SetTitle          ;
        Message aStrings[ 12, 2 ]
    Separator
    MenuItem aStrings[ 13, 2 ] ;
        Action OpenFile()      ;
        Name OpenFile          ;
        Message aStrings[ 14, 2 ]
    Separator
    MenuItem aStrings[ 15, 2 ]                      ;
        Action CopyToClipboard( GetNameFunction() ) ;
        Name CopyIt                                 ;
        Message aStrings[ 16, 2 ]
  End Popup
  
  Define popup aStrings[ 17, 2 ]           // Tools
    MenuItem aStrings[ 18, 2 ] ;
        Action Formater()      ;
        Name Reformatter       ;
        Message aStrings[ 19, 2 ]
    MenuItem aStrings[ 20, 2 ]   ;
        Action CallsTable()      ;
        Name CallsTable          ;
        Message aStrings[ 21, 2 ]
  End Popup

  Define popup aStrings[ 22, 2 ]           // Service
    Define popup aStrings[ 23, 2 ]
       MenuItem aStrings[ 24, 2 ]  ;
           Action SelectLanguage() ;
           Message aStrings[ 25, 2 ]
       Separator
       MenuItem aStrings[ 26, 2 ]    ;
           Action MakeLangTemplate() ;
           Message aStrings[ 27, 2 ]
    End Popup
    
    Separator
    MenuItem aStrings[ 28, 2 ] ;
        Action Options()       ;
        Message aStrings[ 29, 2 ]
  End Popup
  
  Define popup '?'                         // ?
    MenuItem aStrings[ 30, 2 ]        ;
    Action About( aStrings[ 30, 2 ] ) ;
    Message aStrings[ 31, 2 ]
  End Popup

End Menu

Return

****** End of BuildMenu *****
 

/******
*
*       ModifyMainForm( aStrings )
*
*       Changing of the main window language interface.
*       Separate procedure is exuded for possibility of
*       the change language interface.
*
*/

Procedure ModifyMainForm( aStrings )

If !( Valtype( aStrings ) == 'A' )
   aStrings := GetLangStrings( GET_MAINFORM_LANG )
Endif

// Заголовок главного окна

wStock.Title := aStrings[ 1, 2 ]

// Панель инструментов

wStock.tbrTools.btnNew.Tooltip     := aStrings[ 2, 2 ]
wStock.tbrTools.btnOpen.Tooltip    := aStrings[ 3, 2 ]
wStock.tbrTools.btnSave.Tooltip    := aStrings[ 4, 2 ]
wStock.tbrTools.btnEdit.Tooltip    := aStrings[ 5, 2 ]
wStock.tbrTools.btnOptions.Tooltip := aStrings[ 6, 2 ]

// Заголовки колонок таблицы

wStock.grdContent.Header( 1 ) := aStrings[ 7, 2 ]
wStock.grdContent.Header( 2 ) := aStrings[ 8, 2 ]
wStock.grdContent.Header( 3 ) := aStrings[ 9, 2 ]

// Условие поиска

wStock.lblSearch.Value    := aStrings[ 10, 2 ]
wStock.txbSearch.Tooltip  := aStrings[ 11, 2 ]
wStock.btnSearch.Tooltip  := aStrings[ 12, 2 ]
wStock.btnFindAll.Tooltip := aStrings[ 13, 2 ]

Return

****** End of ModifyMainForm *****


/*****
*
*       ReSize()
*
*       Matching of the sizes list and window
*
*/

Static Procedure ReSize
Local nWidth  := wStock.Width , ;
      nHeight := wStock.Height

// Изменяем размер отображаемого списка

wStock.grdContent.Row := 31
wStock.grdContent.Col := 3
wStock.grdContent.Width  := ( nWidth - 2 * wStock.grdContent.Col - 2 * GetBorderWidth() )
wStock.grdContent.Height := ( nHeight - wStock.grdContent.Row - GetTitleHeight() - ;
                              GetMenubarHeight() - 2 * GetBorderHeight() - 52 )

If !Empty( wStock.grdContent.ItemCount )
   wStock.grdContent.ColumnsAutoFit()
Endif

// Метка поисковой строки

wStock.lblSearch.Row := ( wStock.grdContent.Row + wStock.grdContent.Height + 10 )
wStock.lblSearch.Col := wStock.grdContent.Col

// Поле ввода поискового значения и кнопка поиска

wStock.txbSearch.Row := ( wStock.lblSearch.Row - 4 )
wStock.txbSearch.Col := ( wStock.lblSearch.Col + wStock.lblSearch.Width + 10 )
wStock.txbSearch.Width := ( wStock.grdContent.Width - wStock.lblSearch.Width - ;
                            wStock.txbSearch.Col - wStock.btnSearch.Width + 10 )

wStock.btnSearch.Row := wStock.txbSearch.Row
wStock.btnSearch.Col := ( wStock.txbSearch.Col + wStock.txbSearch.Width + 5 )

wStock.btnFindAll.Row := wStock.btnSearch.Row
wStock.btnFindAll.Col := ( wStock.btnSearch.Col + wStock.btnSearch.Width + 5 )
 
Return

****** End of ReSize ******


/******
*
*       SetState()
*
*       Control for the condition of dialog elements
*
*/

Static Procedure SetState
Memvar aOptions

If !Empty( wStock.grdContent.ItemCount )

   wStock.SaveList.Enabled    := .T.
   wStock.SetTitle.Enabled    := .T.
   wStock.CopyIt.Enabled      := .T.
   wStock.Reformatter.Enabled := .T.
   wStock.CallsTable.Enabled  := .T.
   wStock.OpenFile.Enabled    := !Empty( aOptions[ OPTIONS_EDITOR ] )

   wStock.btnSave.Enabled := .T.
   wStock.btnEdit.Enabled := !Empty( aOptions[ OPTIONS_EDITOR ] )

   wStock.txbSearch.Enabled := .T.

Else

   wStock.SaveList.Enabled    := .F.
   wStock.SetTitle.Enabled    := .F.
   wStock.CopyIt.Enabled      := .F.
   wStock.Reformatter.Enabled := .F.
   wStock.CallsTable.Enabled  := .F.
   wStock.OpenFile.Enabled    := .F.

   wStock.btnSave.Enabled := .F.
   wStock.btnEdit.Enabled := .F.

   wStock.txbSearch.Enabled := .F.

Endif

wStock.btnSearch.Enabled  := !Empty( wStock.txbSearch.Value )
wStock.btnFindAll.Enabled := !Empty( wStock.txbSearch.Value )

Return

****** End of SetState ******


/*****
*
*       GridStatus()
*
*       Show of the position inside list
*
*/

Static Procedure GridStatus
wStock.Statusbar.Item( 2 ) := ( LTrim( Str( wStock.grdContent.Value ) )     + ;
                                '/'                                         + ;
                                LTrim( Str( wStock.grdContent.ItemCount ) )   ;
                               )

Return

****** End of GridStatus ******


/*****
*
*       NewList()
*
*       Formation of the new list
*
*/

Static Procedure NewList
Memvar aOptions
Local cPath                                                                           , ;
      aStrings  := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      aFileList := {}                                                                 , ;
      Cycle                                                                           , ;
      nLen                                                                            , ;
      cNum

/// GAL added
if Empty( aOptions[ OPTIONS_GETPATH ] )
  aOptions[ OPTIONS_GETPATH ] := GetStartUpFolder()
endif
///

If !Empty( cPath := GetFolder( aStrings[ 6, 2 ], aOptions[ OPTIONS_GETPATH ] ) )

   //// GAL added
   gugupath := cPath
   if Empty( gugupath )
     gugupath := CurDrive() + ":\" + Curdir()
   endif
   ////

   // Внесение в список файлов .prg
   aFileList := GetFileList( aFileList, ( cPath + '\*.prg' ) )

   // Внесение в список файлов .c
   aFileList := GetFileList( aFileList, ( cPath + '\*.c' ) )

   If !Empty( aFileList )

      // Упорядочение списка: файлы с расширением *.prg и *.c
      // должны оказаться рядом

      ASort( aFileList, , , { | x, y | BaseCompare( x ) < BaseCompare( y ) } )

      // Внесение в отображаемый список

      nLen := Len( aFileList )
      cNum := LTrim( Str( nLen ) )

      // Запретить обновление и доступ к GRID

      wStock.grdContent.DisableUpdate
      wStock.grdContent.Enabled := .F.
      wStock.grdContent.DeleteAllItems

      For Cycle := 1 to nLen

        wStock.Statusbar.Item( 1 ) := aFileList[ Cycle ]
        wStock.Statusbar.Item( 2 ) := ( LTrim( Str( Cycle ) ) + '/' + cNum )

        // Анализ содержимого файла

        ParseFile( cPath, aFileList[ Cycle ] )

      Next

      wStock.Statusbar.Item( 1 ) := cPath
      wStock.Statusbar.Item( 2 ) := ''

      // Запросить наименование созданного каталога и файл для сохранения

      aOptions[ OPTIONS_TITLE ] := cPath

      SetTitle()
      SaveList()
      
      // Возврат главного окна к рабочему состоянию

      wStock.grdContent.ColumnsAutoFit
      wStock.grdContent.EnableUpdate
      wStock.grdContent.Enabled := .T.

      wStock.grdContent.Value := 1
      wStock.grdContent.SetFocus

      // Запомнить последний использованный каталог

      aOptions[ OPTIONS_GETPATH ] := cPath

   Endif

Endif

SetState()
GridStatus()

Return

****** End of NewList *****


/*****
*
*       GetFileList( aFileList, cPattern ) --> aFileList
*
*       Entering to the filelist with required extension
*
*/

Static Function GetFileList( aFileList, cPattern )
Local aFiles, ;
      Cycle , ;
      nLen

If !Empty( aFiles := Directory( cPattern ) )

   nLen := Len( aFiles )
   For Cycle := 1 to nLen
     AAdd( aFileList, aFiles[ Cycle, F_NAME ] )
   Next

Endif

Return aFileList

***** End of GetFileList *****


/*****
*
*       BaseCompare( cValue ) --> cValue
*
*       Allocation of the base for compare from the symbol expression
*
*/

Static Function BaseCompare( cValue )

// От сортировки ожидаем следующего:
// - связанные файлы (prg и c) будут располагаться рядом
// - файлы с расширением *.prg располагаются выше связанных с ними файлов *.c

// Применительно к дистрибутиву MiniGUI этого можно достичь:
// - избавлением от префикса H_ (для *.prg) и C_ (для *.c) - после этого имена
//   файлов станут одинаковы
// - для *.prg удалить расширение - имя укорачивается и получает при сортировке
//   более высокий приоритет

cValue := Upper( cValue )

If ( Left( cValue, 2 ) == 'H_' )
   cValue := Left( cValue, ( Len( cValue ) - 4 ) )
Endif

If ( ( Left( cValue, 2 ) == 'H_' ) .or. ;
     ( Left( cValue, 2 ) == 'C_' )      ;
   )
   cValue := Substr( cValue, 3 )
Endif

Return cValue

****** End of BaseCompare *****


/*****
*
*       ParseFile( cPath, cFile )
*
*       Поиск операторов
*
*/

Static Procedure ParseFile( cPath, cFile )
Local oFile   := TFileRead() : New( cPath + '\' + cFile ), ;
      cString                                            , ;
      nPos                                               , ;
      cType                                              , ;
      cWord

AddToContent( cFile, '', '' )   // Добавляем в список программный файл

oFile : Open()
If !oFile : Error()

   Do while oFile : MoreToRead()

      cString := oFile : ReadLine()

      If !Empty( cString )    // Пустые строки игнорируем

         cString := LTrim( cString )

         // Комментарии пропускаем

         Do case
            Case ( Left( cString, 1 ) == '*' )
              Loop

            Case ( Left( cString, 2 ) == '//' )
              Loop

            Case ( ( '/*' $ cString ) .and. ( '*/' $ cString ) )
              Loop

            Case ( Left( cString, 2 ) == '/*' )

              // Многострочный комментарий

              Do while oFile : MoreToRead()

                 cString := oFile : ReadLine()

                 If ( '*/' $ cString )
                    Exit
                 Endif

              Enddo

              Loop

         Endcase

         // Получение имени процедуры/функции и указания на её область видимости

         If ( Left( cString, 7 ) == 'HB_FUNC' )

            // Функции C (WinAPI)

            If !Empty( nPos := At( '(', cString ) )

               cString := Substr( cString, ( nPos + 1 ) )

               If !Empty( nPos := At( ')', cString ) )
                  cString := AllTrim( Left( cString, ( nPos - 1 ) ) )
                  AddToContent( ( Space( 3 ) + cString ), 'HB_FUNC', '' )
               Endif

            Endif

         Else

            // Выделяем 1-е слово

           If !Empty( nPos := At( ' ', cString ) )

              cWord := AllTrim( Left( cString, ( nPos - 1 ) ) )

              // Проверяем вхождение в список ключевых слов. В первую
              // очередь проверяется область видимости, далее выясняется
              // оператор

              cWord += ' '
              If !Empty( AScan( { 'STATIC ', 'STATI ', 'STAT ' }     , ;
                                { | elem | elem == Upper( cWord ) } )  ;
                       )
                 cType := 'Static '

                 // В этом случае необходимо изменить определяемое выражение

                 cString := AllTrim( Substr( cString, ( nPos + 1 ) ) )

                 If !Empty( nPos := At( ' ', cString ) )
                    cWord := ( AllTrim( Left( cString, ( nPos - 1 ) ) ) + ' ' )
                 Endif

              Else
                 cType := ''

              Endif

              If !Empty( cWord )

                 Do case
                    Case !Empty( AScan( { 'PROCEDURE ', 'PROCEDUR ', 'PROCEDU ', ;
                                          'PROCED '   , 'PROCE '   , 'PROC '     ;
                                        }                                      , ;
                                        { | elem | elem == Upper( cWord ) } )    ;
                               )
                      cType += ' Procedure'

                    Case !Empty( AScan( { 'FUNCTION ', 'FUNCTIO ', 'FUNCTI ' , ;
                                          'FUNCT '   , 'FUNC '                 ;
                                        }                                    , ;
                                        { | elem | elem == Upper( cWord ) } )  ;
                               )
                      cType += ' Function'

                 Endcase

                 // Определение имени процедуры/функции

                 cType := AllTrim( cType )
                 If ( !Empty( cType ) .and. !( cType == 'Static' ) )
                    cString := AllTrim( Substr( cString, ( nPos + 1 ) ) )

                    // Удаление всего, что слудует за именем

                    If !Empty( nPos := At( '(', cString ) )
                       cString := AllTrim( Left( cString, ( nPos - 1 ) ) )
                    Endif

                    If !Empty( nPos := At( ' ', cString ) )
                       cString := AllTrim( Left( cString, ( nPos - 1 ) ) )
                    Endif

                    AddToContent( ( Space( 3 ) + cString ), cType, '' )

                 Endif

              Endif

           Endif

         Endif

      Endif

   Enddo

   oFile : Close()

Endif

Return

****** End of ParseFile ******


/******
*
*       AddToContent( cName, cType, cComment )
*
*       Addition of the string to list
*
*/

Static Procedure AddToContent( cName, cType, cComment )
wStock.grdContent.AddItem( { cName, cType, cComment } )
Return

****** End of AddToContent ******


/******
*
*       IsFound( cValue, cItem ) --> lFound
*
*       Checkup of the presence required fragment in the string
*
*/

Static Function IsFound( cValue, cItem )
Memvar aOptions
Local nLen   := Len( cValue ), ;
      lFound := .F.

// Варианты выполнения поиска

If ( aOptions[ OPTIONS_SEARCH ] == SEARCH_EQUAL )      // Точное соответствие
   lFound := ( Upper( Left( AllTrim( cItem ), nLen ) ) == cValue )

ElseIf ( aOptions[ OPTIONS_SEARCH ] == SEARCH_ENTRY )  // Вхождение поисковой подстроки
   lFound := ( cValue $ Upper( AllTrim( cItem ) ) )

Endif

Return lFound

****** End of IsFound ******


/******
*
*       QSeek()
*
*       Seek into list
*
*/

Static Procedure QSeek
Local cValue := AllTrim( wStock.txbSearch.Value ), ;
      nPos   := ( wStock.grdContent.Value + 1 )  , ;
      nCount := wStock.grdContent.ItemCount      , ;
      Cycle                                      , ;
      lFound

wStock.btnSearch.Enabled   := !Empty( cValue )
wStock.btnFindAll.Enabled  := !Empty( cValue )
wStock.txbSearch.Backcolor := WHITE

If !Empty( cValue )

   // Поиск начинается со следующей строки таблицы

   For Cycle := nPos to nCount

     If ( lFound := IsFound( cValue, wStock.grdContent.Item( Cycle )[ 1 ] ) )
        wStock.grdContent.Value := Cycle
        Exit
     Endif

   Next

   // Выделяем цветом поле поискового значения, если выражение не обнаружено

   If !lFound
      wStock.txbSearch.Backcolor := { 255, 127, 127 }
   Endif

Endif

Return

****** End of QSeek ******


/******
*
*       FindAll()
*
*       Find all matched enties
*
*/

Static Procedure FindAll
Memvar aOptions
Local cValue   := AllTrim( wStock.txbSearch.Value )                               , ;
      nCount   := wStock.grdContent.ItemCount                                     , ;
      aStrings := GetLangStrings( GET_FINDALL_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      aMatches := {}                                                              , ;
      Cycle                                                                       , ;
      cItem                                                                       , ;
      cFile

wStock.btnSearch.Enabled  := !Empty( cValue )
wStock.btnFindAll.Enabled := !Empty( cValue )

If !Empty( cValue )

   Define window wFindAll     ;
       At 0, 0                ;
       Width 350              ;
       Height 300             ;
       Title aStrings[ 1, 2 ] ;
       Icon 'STOCK'           ;
       Modal

      @ 10, 5 Label lblName                                    ;
              Value ( aStrings[ 1, 2 ] + ' [' + cValue + ']' ) ;
              Width 330                                        ;
              Height 18                                        ;
              Bold                                             ;
              FontColor BLUE

      @ ( wFindAll.lblName.Row + wFindAll.lblName.Height + 3 ), wFindAll.lblName.Col ; 
        Grid grdMatches                                                  ;
        Width 330                                                        ;
        Height 200                                                       ;
        Headers { aStrings[ 3, 2 ], aStrings[ 4, 2 ], aStrings[ 5, 2 ] } ;
        Widths { 150, 100, 200 }                                         ;
        Font 'Tahoma' Size 10                                            ;
        NoLines                                                          ;
        On DblClick Do_GoTo( aMatches )

      @ ( wFindAll.grdMatches.Row + wFindAll.grdMatches.Height + 10 ), ;
        ( wFindAll.grdMatches.Col + 55 )                               ;
        Button btnGoto                                                 ;
        Caption aStrings[ 6, 2 ]                                       ;
        Action Do_GoTo( aMatches ) 

      @ wFindAll.btnGoto.Row, ( wFindAll.btnGoto.Col + wFindAll.btnGoto.Width + 30 ) ;
        Button btnCancel                                                             ;
        Caption _HMG_MESSAGE[ 7 ]                                                    ;
        Action wFindAll.Release 

      On key Escape of wFindAll Action wFindAll.Release
      On key Alt+X  of wFindAll Action ReleaseAllWindows()

   End window

   // Отобрать все вхождения

   wFindAll.grdMatches.DeleteAllItems
   
   For Cycle := 1 to nCount

     cItem := wStock.grdContent.Item( Cycle )[ 1 ]
     
     If !( Left( cItem, 1 ) == Space( 1 ) )
        cFile := AllTrim( cItem )
     Endif 

     cItem := AllTrim( cItem )
     
     If IsFound( cValue, cItem )
        AAdd( aMatches, Cycle )
        wFindAll.grdMatches.AddItem( { cItem, cFile, wStock.grdContent.Item( Cycle )[ 2 ] } )
     Endif

   Next
   
   If Empty( wFindAll.grdMatches.ItemCount )
      wFindAll.btnGoto.Enabled := .F.
   Else
      wFindAll.grdMatches.Value := 1
   Endif

   CenterInside( 'wStock', 'wFindAll' )
   Activate window wFindAll

Endif

Return

****** End of FindAll ******


/******
*
*       Do_GoTo( aMatches )
*
*       Go to selected position
*
*/

Static Procedure Do_GoTo( aMatches )
Local nPos := wFindAll.grdMatches.Value

If !Empty( nPos )
   nPos := aMatches[ nPos ]
   wFindAll.Release
   wStock.grdContent.Value := nPos
Endif

Return

****** End of Do_GoTo ******


/******
*
*       GetNameFunction() --> cName
*
*       Reading the cell value (function name)
*
*/

Static Function GetNameFunction
Local nValue := wStock.grdContent.Value
Return AllTrim( wStock.grdContent.Cell( nValue, 1 ) )

****** End of GetNameFunction ******


/******
*
*       SaveList()
*
*       Saving of list to file
*
*/

Static Procedure SaveList
Memvar aOptions
Local cFile                                  , ;
      nLen     := wStock.grdContent.ItemCount, ;
      Cycle                                  , ;
      cNum                                   , ; 
      aStrings := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] )

cFile := PutFile( { { aStrings[ 3, 2 ], '*.txt' }, ;
                    { aStrings[ 5, 2 ], '*.*'   }  ;
                  }                              , ;
                  aStrings[ 7, 2 ]               , ;
                  DATA_PATH                      , ;
                  .T.                              ;
                )

If !Empty( cFile )

   wStock.grdContent.Enabled  := .F.
   cNum                       := LTrim( Str( nLen ) )

   Set alternate to ( cFile )
   Set console off
   Set alternate on

   // Маршрут к ресурсам текущего каталога, описание

   ?? SOURCE_PATH + aOptions[ OPTIONS_GETPATH ]
   ?
   ?? SOURCE_TITLE + aOptions[ OPTIONS_TITLE ]
   ?

   For Cycle := 1 to nLen

     wStock.Statusbar.Item( 1 ) := AllTrim( wStock.grdContent.Item( Cycle )[ 1 ] )
     wStock.Statusbar.Item( 2 ) := ( LTrim( Str( Cycle ) ) + '/' + cNum )

     ?? PadR( wStock.grdContent.Item( Cycle )[ 1 ], SPACES_TO_NAME ) + Chr( K_TAB )
     ?? PadR( wStock.grdContent.Item( Cycle )[ 2 ], SPACES_TO_TYPE ) + Chr( K_TAB )
     ?? wStock.grdContent.Item( Cycle )[ 3 ]
     ?
   Next

   Set alternate off
   Set console on
   Set alternate to

   // Запомнить файл последнего каталога

   aOptions[ OPTIONS_LASTFILE ] := cFile

   Begin ini file STOCK_INI

     Set section 'MAIN' entry 'LastFile' to aOptions[ OPTIONS_LASTFILE ]

   End Ini

   wStock.Statusbar.Item( 1 ) := aOptions[ OPTIONS_GETPATH ]
   wStock.grdContent.Enabled  := .T.
   wStock.grdContent.SetFocus

   GridStatus()

Endif

Return

****** End of SaveList ******


/******
*
*      LoadList( cFile )
*
*      Loading of list from file
*
*/

Static Procedure LoadList( cFile )
Memvar aOptions
Local cString , ;
      oFile   , ;
      nPos    , ;
      cName   , ;
      cType   , ;
      cComment, ;
      aStrings

If ( cFile == nil )

   aStrings := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] )

   cFile := GetFile( { { aStrings[ 3, 2 ], '*.txt' } , ;
                       { aStrings[ 5, 2 ], '*.*'   }   ;
                     }                               , ;
                     aStrings[ 1, 2 ]                , ;
                     DATA_PATH                       , ;
                     .F.                             , ;
                     .T.                               ;
                   )
Endif

If !Empty( cFile )

   oFile := TFileRead() : New( cFile )

   oFile : Open()

   If !oFile : Error()

      // Запретить обновление и доступ к GRID

      wStock.grdContent.DisableUpdate
      wStock.grdContent.Enabled := .F.
      wStock.grdContent.DeleteAllItems

      wStock.Statusbar.Item( 1 ) := ''
      wStock.Statusbar.Item( 2 ) := ''

      // Сбрасываем действующее значение маршрута каталогизированных ресурсов.

      aOptions[ OPTIONS_GETPATH ] := ''

      Do while oFile : MoreToRead()

         If !Empty( cString := oFile : ReadLine() )

            // В первой строке - маршрут к каталогизированным ресурсам.

            If ( ( Left( cString, Len( SOURCE_PATH ) ) == SOURCE_PATH ) .and. ;
                 Empty( aOptions[ OPTIONS_GETPATH ] )                         ;
               )
               aOptions[ OPTIONS_GETPATH ] := AllTrim( Substr( cString, ( Len( SOURCE_PATH ) + 1 ) ) )
               Loop

            ElseIf ( ( Left( cString, Len( SOURCE_TITLE ) ) == SOURCE_TITLE ) .and. ;
                     Empty( aOptions[ OPTIONS_TITLE ] )                             ;
                   )
               aOptions[ OPTIONS_TITLE ] := AllTrim( Substr( cString, ( Len( SOURCE_TITLE ) +1 ) ) )
               Loop

            Endif

            // Заполнение таблицы

            If !Empty( nPos := At( Chr( K_TAB ), cString ) )

               cType := cComment := ''
               cName := Left( cString, ( nPos - 1 ) )

               cString := Substr( cString, ( nPos + 1 ) )

               If !Empty( nPos := At( Chr( K_TAB ), cString ) )
                  cType    := AllTrim( Left( cString, ( nPos - 1 ) ) )
                  cComment := AllTrim( Substr( cString, ( nPos + 1 ) ) )
               Endif

               wStock.Statusbar.Item( 1 ) := AllTrim( cName )
               AddToContent( cName, cType, cComment )

            Endif

         Endif

      Enddo

      oFile : Close()

      wStock.Statusbar.Item( 1 ) := aOptions[ OPTIONS_GETPATH ]
      wStock.Statusbar.Item( 2 ) := ''

      StoreTitle()

      wStock.grdContent.ColumnsAutoFit
      wStock.grdContent.EnableUpdate
      wStock.grdContent.Enabled := .T.

      wStock.grdContent.Value := 1
      wStock.grdContent.SetFocus

      // Запомнить файл последнего каталога

      aOptions[ OPTIONS_LASTFILE ] := cFile

      Begin ini file STOCK_INI

        Set section 'MAIN' entry 'LastFile' to aOptions[ OPTIONS_LASTFILE ]

      End Ini

   Endif

Endif

SetState()
GridStatus()

Return

****** End of LoadList ******


/******
*
*       SetTitle()
*
*       Input/editing of the catalog name
*
*/

Static Procedure SetTitle
Memvar aOptions
Local aStrings := GetLangStrings( GET_SETTITLE_LANG, aOptions[ OPTIONS_LANGFILE ] )

Define window wSetTitle       ;
       At 132, 235            ;
       Width 406              ;
       Height 142             ;
       Title aStrings[ 1, 2 ] ;
       Icon 'STOCK'           ;
       Modal

   @ 10, 5 Label lblName          ;
           Value aStrings[ 2, 2 ] ;
           Width 100              ;
           Height 18              ;
           Bold                   ;
           FontColor BLUE

   @ ( wSetTitle.lblName.Row + wSetTitle.lblName.Height + 10 ), wSetTitle.lblName.Col ;
     TextBox txbName                 ;
     Height 20                       ;
     Value aOptions[ OPTIONS_TITLE ]

   @ ( wSetTitle.txbName.Row + wSetTitle.txbName.Height + 15 ), 150               ;
     Button btnOK                                                                 ;
     Caption _HMG_MESSAGE[ 6 ]                                                    ;
     Action { || aOptions[ OPTIONS_TITLE ] := AllTrim( wSetTitle.txbName.Value ), ;
                 StoreTitle()                                                   , ;
                 ThisWindow.Release                                               ;
            }

   @ wSetTitle.btnOk.Row, ( wSetTitle.btnOk.Col + wSetTitle.btnOk.Width + 25 ) ;
     Button btnCancel          ;
     Caption _HMG_MESSAGE[ 7 ] ;
     Action ThisWindow.Release

   On key Escape of wSetTitle Action wSetTitle.Release
   On key Alt+X  of wSetTitle Action ReleaseAllWindows()

End window

wSetTitle.txbName.Width := ( wSetTitle.Width - 2 * wSetTitle.txbName.Col  - ;
                             2 * GetBorderWidth() )
wSetTitle.txbName.SetFocus

CenterInside( 'wStock', 'wSetTitle')
Activate window wSetTitle

Return

****** End of SetTitle ******


/******
*
*       StoreTitle()
*
*       Output of the catalog name in the title of main form
*
*/

Static Procedure StoreTitle
Memvar aOptions

wStock.Title := ( APPTITLE + Iif( !Empty( aOptions[ OPTIONS_TITLE ] )  , ;
                                  ( ' - ' + aOptions[ OPTIONS_TITLE ] ), ;
                                  '' )                                   ;
                )

Return

****** End of StoreTitle ******


/******
*
*       Options()
*
*       Program tuning
*
*/

Static Procedure Options
Memvar aOptions
Local aStrings := GetLangStrings( GET_OPTIONSFORM_LANG, aOptions[ OPTIONS_LANGFILE ] ), ;
      aLang    := GetLangStrings( GET_SYSDIALOGS_LANG, aOptions[ OPTIONS_LANGFILE ] )

Define window wOptions        ;
       At 132, 235            ;
       Width 433              ;
       Height 309             ;
       Title aStrings[ 1, 2 ] ;
       Icon 'STOCK'           ;
       Modal

   @ 5, 5 Frame frmOnStart         ;
          Caption aStrings[ 2, 2 ] ;
          Width 205                ;
          Height 75                ;
          Bold                     ;
          Fontcolor BLUE

   @ ( wOptions.frmOnStart.Row + 15 ), ( wOptions.frmOnStart.Col + 10 ) ;
     RadioGroup rdgOnStart                                              ;
     Options { aStrings[ 3, 2 ], aStrings[ 4, 2 ] }                     ;
     Width 185                                                          ;
     Value aOptions[ OPTIONS_ONSTART ]

   @ wOptions.frmOnStart.Row                                           , ;
     ( wOptions.frmOnStart.Col + wOptions.frmOnStart.Width + 5 )         ;
     Frame frmSearch                                                     ;
     Caption aStrings[ 5, 2 ]                                            ;
     Width wOptions.frmOnStart.Width Height wOptions.frmOnStart.Height   ;
     Bold                                                                ;
     Fontcolor BLUE

   @ wOptions.rdgOnStart.Row, ( wOptions.frmSearch.Col + 15 ) ;
     RadioGroup rdgSearch                                     ;
     Options { aStrings[ 6, 2 ], aStrings[ 7, 2 ] }           ;
     Width 165                                                ;
     Value aOptions[ OPTIONS_SEARCH ]

   @ ( wOptions.frmOnStart.Row + wOptions.frmOnStart.Height + 5 )      , ;
     wOptions.frmOnStart.Col                                             ;
     Frame frmEditor                                                     ;
     Caption aStrings[ 8, 2 ]                                            ;
     Width ( wOptions.frmOnStart.Width + wOptions.frmSearch.Width + 5 )  ;
     Height 140                                                          ;
     Bold                                                                ;
     Fontcolor BLUE

   @ ( wOptions.frmEditor.Row + 25 ), ( wOptions.frmEditor.Col + 10 ) ;
     Textbox txbEditor                                                ;
     Value aOptions[ OPTIONS_EDITOR ]                                 ;
     Height 20                                                        ;
     Width ( wOptions.frmEditor.Width - 45 )

   @ wOptions.txbEditor.Row                                          , ;
     ( wOptions.txbEditor.Col + wOptions.txbEditor.Width + 5 )         ;
     Button btnSearch                                                  ;
     Picture 'FIND'                                                    ;
     Action { |cFile| cFile  := GetFile( { { aLang[ 4, 2 ], '*.exe' }, ;
                                           { aLang[ 5, 2 ], '*.*'   }  ;
                                         }                           , ;
                                         aLang[ 2, 2 ]             , , ;
                                         .F.                         , ;
                                         .T.                           ;
                                       )                             , ;
                      Iif( !Empty( cFile )                           , ;
                           SetProperty( 'wOptions', 'txbEditor', 'Value', cFile ), ) ;
             }                                                                       ;
     Width 20 Height 20

   @ ( wOptions.txbEditor.Row + 25 ), wOptions.txbEditor.Col            ;
     RadioGroup rdgParameters                                           ;
     Options { aStrings[ 9, 2 ], aStrings[ 10, 2 ], aStrings[ 11, 2 ] } ; 
     Width 270                                                          ;
     Spacing 28                                                         ;
     Value aOptions[ OPTIONS_RUNMODE ]                                  ;
     On change EnableParameters()

   @ ( wOptions.rdgParameters.Row + 30 )                              , ;
     ( wOptions.rdgParameters.Col + wOptions.rdgParameters.Width + 5 )  ;
     Textbox txbWithNumber                                              ;
     Height 20                                                          ;
     Width 120

   @ ( wOptions.txbWithNumber.Row + 30 ), wOptions.txbWithNumber.Col ;
     Textbox txbWithName                                             ;
     Height 20                                                       ;
     Width 120

   @ ( wOptions.Height - 70 ), 80 Button btnOk Caption _HMG_MESSAGE[ 6 ] ;
     Action { || SaveOptions(), wOptions.Release }

   @ wOptions.btnOk.Row, ( wOptions.btnOk.Col + wOptions.btnOk.Width + 70 ) ;
     Button btnCancel Caption _HMG_MESSAGE[ 7 ]                             ;
     Action wOptions.Release

   On key Escape of wOptions Action wOptions.Release
   On key Alt+X  of wOptions Action ReleaseAllWindows()

End window

// Отображаемые значения и установка доступа к элементам диалога

Do case
   Case ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_SIMPLEOPEN )
     wOptions.txbWithNumber.Value := ''
     wOptions.txbWithName.Value   := ''

   Case ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_GOTO )
     wOptions.txbWithNumber.Value := aOptions[ OPTIONS_EDITOR_PARMS ]
     wOptions.txbWithName.Value   := ''

   Case ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_FIND )
     wOptions.txbWithNumber.Value := ''
     wOptions.txbWithName.Value   := aOptions[ OPTIONS_EDITOR_PARMS ]

Endcase

EnableParameters()

CenterInside( 'wStock', 'wOptions' )
Activate window wOptions

Return

****** End of Options ******


/******
*
*       EnableParameters()
*
*       Administration for the edition of complementary parameters
*       for editor launching
*
*/

Static Procedure EnableParameters

Do case
   Case ( wOptions.rdgParameters.Value == EDITOR_SIMPLEOPEN )
     wOptions.txbWithNumber.Enabled := .F.
     wOptions.txbWithName.Enabled   := .F.

   Case ( wOptions.rdgParameters.Value == EDITOR_GOTO )
     wOptions.txbWithNumber.Enabled := .T.
     wOptions.txbWithName.Enabled   := .F.

   Case ( wOptions.rdgParameters.Value == EDITOR_FIND )
     wOptions.txbWithNumber.Enabled := .F.
     wOptions.txbWithName.Enabled   := .T.

Endcase

Return

****** End of EnableParameters ******


/******
*
*       SaveOptions()
*
*       Preservation the options
*
*/

Static Procedure SaveOptions
Memvar aOptions

Begin ini file STOCK_INI

  Set section 'MAIN' entry 'OnStart' to wOptions.rdgOnStart.Value
  aOptions[ OPTIONS_ONSTART ] := wOptions.rdgOnStart.Value

  Set section 'MAIN' entry 'Search'  to wOptions.rdgSearch.Value
  aOptions[ OPTIONS_SEARCH ] := wOptions.rdgSearch.Value

  Set section 'EDITOR' entry 'Editor'  to AllTrim( wOptions.txbEditor.Value )
  aOptions[ OPTIONS_EDITOR ] := AllTrim( wOptions.txbEditor.Value )

  Set section 'EDITOR' entry 'RunWith' to wOptions.rdgParameters.Value
  aOptions[ OPTIONS_RUNMODE ] := wOptions.rdgParameters.Value

  Do case
     Case ( wOptions.rdgParameters.Value == EDITOR_SIMPLEOPEN ) // Открыть файл в редакторе (без условий)
       Set section 'EDITOR' entry 'EditParms' to ''
       aOptions[ OPTIONS_EDITOR_PARMS ] := ''

     Case ( wOptions.rdgParameters.Value == EDITOR_GOTO )       // Открыть и перейти на строку
       Set section 'EDITOR' entry 'EditParms' to AllTrim( wOptions.txbWithNumber.Value )
       aOptions[ OPTIONS_EDITOR_PARMS ] := AllTrim( wOptions.txbWithNumber.Value )

     Case ( wOptions.rdgParameters.Value == EDITOR_FIND )       // Открыть и передать выражение для поиска
       Set section 'EDITOR' entry 'EditParms' to AllTrim( wOptions.txbWithName.Value )
       aOptions[ OPTIONS_EDITOR_PARMS ] := AllTrim( wOptions.txbWithName.Value )

  Endcase

End Ini

SetState()

Return

****** End of SaveOptions ******


/******
*
*       ReadOptions() --> aOptions
*
*       Restoration the options
*
*/

Static Function ReadOptions
Local aOptions := Array( OPTIONS_ALEN )

aOptions[ OPTIONS_ONSTART      ] := ONSTART_NONEACTION
aOptions[ OPTIONS_SEARCH       ] := SEARCH_EQUAL
aOptions[ OPTIONS_GETPATH      ] := ''
aOptions[ OPTIONS_TITLE        ] := ''
aOptions[ OPTIONS_LASTFILE     ] := ''
aOptions[ OPTIONS_EDITOR       ] := ''
aOptions[ OPTIONS_RUNMODE      ] := EDITOR_SIMPLEOPEN
aOptions[ OPTIONS_EDITOR_PARMS ] := ''
aOptions[ OPTIONS_LANGFILE     ] := ''

If File( STOCK_INI )

   Begin ini file STOCK_INI
     Get aOptions[ OPTIONS_ONSTART      ] section 'MAIN'   entry 'OnStart'   Default ONSTART_NONEACTION
     Get aOptions[ OPTIONS_SEARCH       ] section 'MAIN'   entry 'Search'    Default SEARCH_EQUAL
     Get aOptions[ OPTIONS_LASTFILE     ] section 'MAIN'   entry 'LastFile'  Default ''
     Get aOptions[ OPTIONS_LANGFILE     ] section 'MAIN'   entry 'LangFile'  Default ''
     Get aOptions[ OPTIONS_EDITOR       ] section 'EDITOR' entry 'Editor'    Default ''
     Get aOptions[ OPTIONS_RUNMODE      ] section 'EDITOR' entry 'RunWith'   Default EDITOR_SIMPLEOPEN
     Get aOptions[ OPTIONS_EDITOR_PARMS ] section 'EDITOR' entry 'EditParms' Default ''

   End Ini

Endif

Return aOptions

****** End of ReadOptions ******


/******
*
*       CurrtFileName() --> cFile
*
*       To determine the program file Определить программный файл, allusive the current
*       (into list) procedure
*
*/

Function CurrFileName
Local nPos   := wStock.grdContent.Value, ;
      cFile  := ''

// Ищем программный файл, содержащий текущий элемент.

Do while .T.

   If Empty( wStock.grdContent.Item( nPos )[ 2 ] )
      cFile := AllTrim( wStock.grdContent.Item( nPos )[ 1 ] )
      Exit
   Endif

   nPos --

   If ( nPos <= 0 )
      Exit
   Endif

Enddo

Return cFile

****** End of CurrFileName ******


/******
*
*       OpenFile()
*
*       To open with external editor
*
*/

Static Procedure OpenFile
Memvar aOptions, cSearch, cString
Local cFile  := CurrFileName(), ;
      nPos                    , ;
      cParms                  , ;
      oFile                   , ;
      Cycle  := 1

Private cSearch, ;
        cString

If !Empty( cFile )

   cFile := ( aOptions[ OPTIONS_GETPATH ] + '\' + cFile )

   Do case
      Case ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_SIMPLEOPEN )  // Открыть файл в редакторе
        Execute file ( aOptions[ OPTIONS_EDITOR ] ) Parameters cFile

      Case ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_GOTO )        // Открыть c переходом на строку

        nPos    := wStock.grdContent.Value
        cSearch := ''

        If ( !Empty( aOptions[ OPTIONS_EDITOR_PARMS ] ) .and. ;
             !Empty( wStock.grdContent.Item( nPos )[ 2 ] )              ;
           )

          // Формируем поисковое выражение

          If ( AllTrim( wStock.grdContent.Item( nPos )[ 2 ] ) == 'HB_FUNC' )
             cSearch += '.and. ( "HB_FUNC" $ cString )'
          Endif

          If ( 'Static' $ wStock.grdContent.Item( nPos )[ 2 ] )
             cSearch += '.and. ( "STAT" $ cString )'
          Endif

          If ( 'Procedure' $ wStock.grdContent.Item( nPos )[ 2 ] )
             cSearch += '.and. ( "PROC" $ cString )'
          Endif

          If ( 'Function' $ wStock.grdContent.Item( nPos )[ 2 ] )
             cSearch += '.and. ( "FUNC" $ cString )'
          Endif

          cSearch += ( '.and. ( "' + Upper( AllTrim( wStock.grdContent.Item( nPos )[ 1 ] ) ) + '" $ cString )' )

          If ( Left( cSearch, 1 ) == '.' )
             cSearch := Substr( cSearch, 6 )
          Endif

          oFile := TFileRead() : New( cFile )
          oFile : Open()

          If !oFile : Error()

             Do while oFile : MoreToRead()

                cString := Upper( oFile : ReadLine() )

                If &cSearch
                   Exit
                Endif

                Cycle ++

             Enddo

             oFile : Close()

          Endif

          If ( Cycle > 1 )        // Найдено?
             cParms := StrTran( aOptions[ OPTIONS_EDITOR_PARMS ], '%N', AllTrim( Str( Cycle ) ) )
          Else
             cParms := ''
          Endif

          cParms := ( cFile + ' ' + cParms )

        Else
          cParms := cFile

        Endif

        Execute file ( aOptions[ OPTIONS_EDITOR ] ) Parameters cParms

      Case ( aOptions[ OPTIONS_RUNMODE ] == EDITOR_FIND )        // Открыть с поиском
        If !Empty( cParms := aOptions[ OPTIONS_EDITOR_PARMS ] )
           nPos   := wStock.grdContent.Value
           cParms := StrTran( cParms, '%P', AllTrim( wStock.grdContent.Item( nPos )[ 1 ] ) )
           cParms := ( cFile + ' ' + cParms )
        Else
           cParms := cFile
        Endif

        Execute file ( aOptions[ OPTIONS_EDITOR ] ) Parameters cParms

   Endcase

Endif

Return

****** End of OpenFile ******


/******
*
*       About( cTitle )
*
*       About program
*
*/

Static Procedure About( cTitle )
Local cMsg := ( APPTITLE + ' ' + APPVERSION + CRLF + COPYRIGHT + CRLF + ;
  'with GAL edition (Alexey L. Gustow <gustow33 [dog] mail.ru>)' + CRLF + ;
  '2011.Oct.01-08' )

MsgInfo( cMsg, cTitle )

Return

****** End of About ******
