/******
*
* MINIGUI - Harbour Win32 GUI library Demo
*
* Demo functions for show system paths
* 
* (c) 2008 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
*
* Revised by Grigory Filatov <gfilatov@inbox.ru>
* 
*/

#include "MiniGUI.ch"


Static cCurDir


/******
*
*       Варианты представления системных путей
*
*/

Procedure Main

Set font to 'Tahoma', 9

cCurDir := GetCurrentFolder()

Load window Demo as wMain
IF IsVistaOrLater()
   wMain.Width := (wMain.Width) + GetBorderWidth()
   wMain.Height := (wMain.Height) + GetBorderHeight()
ENDIF

wMain.BtnTextBox_1.Value := GetSpecialFolder( CSIDL_APPDATA )

wMain.Label_3.Value := ''          // Компактная форма
wMain.Label_6.Value := ''          // Сокращённое представление (в формате 8.3)

wMain.Label_7.Value := ( wMain.Label_7.Value + ' ' + cCurDir )
 
wMain.Label_8.Value := ''          // Относительный маршрут

wMain.Spinner_1.Value := 30

MakePaths()
 
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

If !Empty( cPath := GetFolder( 'Choose a directory', cPath ) )
   wMain.BtnTextBox_1.Value := cPath
Endif

Return

****** End of SelectDir ******


/******
*
*       MakePaths()
*
*       Формирование представлений путей
*
*/

Static Procedure MakePaths

ShowCompactPath()
ShowShortPath()
ShowRelPath()

Return

****** End of MakePaths ******
 

/******
*
*       ShowCompactPath()
*
*       Сжатая форма представления маршрута
*
*/

Static Procedure ShowCompactPath
Local cPath := wMain.BtnTextBox_1.Value, ;
      nLen  := wMain.Spinner_1.Value 

If ( ( nLen < GetProperty( 'wMain', 'Spinner_1', 'RangeMin' ) ) .or. ;
     ( nLen > Getproperty( 'wMain', 'Spinner_1', 'RangeMax' ) )      ;
   )  
   wMain.Spinner_1.Refresh
Endif

If !Empty( cPath )
   wMain.Label_3.Value := _GetCompactPath( cPath, nLen )
Endif

Return

****** End of ShowCompactPath ******


/******
*
*       ShowShortPath()
*
*       Сокращённое (формат 8.3) представление представлений путей
*
*/

Static Procedure ShowShortPath
Local cPath := wMain.BtnTextBox_1.Value

If !Empty( cPath )
   wMain.Label_6.Value := _GetShortPathName( cPath )
Endif

Return

****** End of ShowShortPath ******


/******
*
*       ShowRelPath()
*
*       Отображение маршрута относительно текущего каталога
*
*/

Static Procedure ShowRelPath
Local cPath := wMain.BtnTextBox_1.Value

If !Empty( cPath )
   wMain.Label_8.Value := RelativePath( cCurDir, cPath )
Endif

Return

****** End of ShowRelPath ******


/******
*
*       RelativePath( cCurPath, cTargetPath ) --> cRelPath
*
*       Относительное выражение пути поиска
*
*/

Static Function RelativePath( cCurPath, cTargetPath )
Local aCurrPath    := HB_ATokens( cCurPath, '\' )   , ;
      aTargetPath  := HB_ATokens( cTargetPath, '\' ), ;
      cRelPath     := ''                            , ;
      nLen                                          , ;
      Cycle 

If ( Upper( cCurPath ) == Upper( cTargetPath ) ) 

   // Каталоги одинаковы
   Return ''
   
   // ... или можно возвращать текущий маршрут 
   // Return cCurPath

Endif

// При построении относительного пути доступа учитываются следующие варианты:
// 1) Каталоги находятся на разных дисках - можно использовать только абсолютный путь
// 2) Целевой каталог подчинён текущему (ниже уровнем)
// 3) Целевой каталог находится в той же ветви, что и текущий, но на более высоком
//    уровне
// 4) Текущий и целевой каталоги находятся на одном диске, но в разных ветвях. 

If ( Upper( aCurrPath[ 1 ] ) == Upper( aTargetPath[ 1 ] ) )       // Диск общий?

   // Пытаемся избавиться от общей части имён каталогов
   
   Do while .T.
   
      If ( Empty( aCurrPath ) .or. Empty( aTargetPath ) )
         Exit
      Endif
      
      If ( Upper( aCurrPath[ 1 ] ) == Upper( aTargetPath[ 1 ] ) )
         
         ADel( aCurrPath, 1 )
         ASize( aCurrPath, ( Len( aCurrPath ) - 1 ) )

         ADel( aTargetPath, 1 )
         ASize( aTargetPath, ( Len( aTargetPath ) - 1 ) )
               
      Else
         Exit
      Endif
      
   Enddo
   
   // Если в массиве описания текущего каталога остались элементы, то к
   // определению относительного пути добавляем соответсвующее число переходов
   // на верхний уровень и остаток описания целевого каталога
   
   If !Empty( aCurrPath )
      cRelPath += Replicate( '..\', Len( aCurrPath ) )
   Endif
   
   If ( ( nLen := Len( aTargetPath ) ) > 0 )
      For Cycle := 1 to nLen
         cRelPath += ( aTargetPath[ Cycle ] + '\' )
      Next
   Endif
      
Else
  cRelPath := cTargetPath        // Каталоги на разных дисках
  
Endif

If ( Right( cRelPath, 1 ) == '\' )
   cRelPath := Left( cRelPath, ( Len( cRelPath ) - 1 ) )
Endif

Return cRelPath


****** End of RelativePath ******
