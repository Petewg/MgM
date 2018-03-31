/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2016 Sergej Kiselev <bilance@bilance.lv>
 * Design and color were made by Verchenko Andrey <verchenkoag@gmail.com>
 *
 * Opening/closing the database in one window - Открытие/закрытие базы в одном окне
 * filling the column with the help of the table - заполнение колонки средствами таблицы
 * filling the base field with the database driver - заполнение поля базы средствами драйвера базы
*/

#include "hmg.ch"
#include "tsbrowse.ch"

REQUEST DBFCDX

MEMVAR nY, nX, nW, nH, aPrivBColor, nPrivFsize

STATIC oStaticBrw, lStaticFilter := .F.

/////////////////////////////////////////////////////////////////////////////
SET PROCEDURE TO util.prg
/////////////////////////////////////////////////////////////////////////////

#define PROGRAM	  "TSBrowse: The discovery of different databases on a single form."
*---------------------------------------------------
PROCEDURE Main
*---------------------------------------------------
    LOCAL aBase, nFontSize, nMaxWidth, nMaxHeight

    PRIVATE nY, nX, nW, nH, nPrivFsize
    PRIVATE aPrivBColor := { {192,185,154} , {159,191,236} , {195,224,133}, {251,230,148} }
 
    SET EXACT    ON
    SET CENTURY  ON
    SET EPOCH    TO ( Year(Date()) - 50 )
    SET DATE     TO GERMAN
 
    RDDSETDEFAULT('DBFCDX')
 
    SET AUTOPEN   ON
    SET EXCLUSIVE ON
    SET SOFTSEEK  ON
    SET DELETED   ON
 
    SET TOOLTIP BALLOON ON

    // Create a database and return a list of databases
    aBase := MyCreateDbfCdx()  

    nFontSize  := 9
    nMaxWidth  := GetDesktopWidth() 
    nMaxHeight := ( GetDesktopHeight() - GetTaskBarHeight() ) 
    IF nMaxWidth > 1200
       nFontSize  := 12
       nMaxWidth  := 1200 
       nMaxHeight := 700 
    ENDIF
    nPrivFsize := nFontSize  // to declare the size of the background for the table 

    SET FONT TO "Arial" , nFontSize             // Default font

    DEFINE WINDOW      wMain	   ;   
           AT          0, 0        ;
           WIDTH       nMaxWidth   ;
           HEIGHT      nMaxHeight  ;
           TITLE       'DEMO Tsb4' ;
           ICON        '1MAIN_ICO' ;
           MAIN                    ; 
           ON INIT ( wStandardWnd(aBase, nMaxWidth, nMaxHeight), ;
                     wMain.Release() )

    END WINDOW

    CENTER    WINDOW wMain
    ACTIVATE  WINDOW wMain 

RETURN    

////////////////////////////////////////////////////////////
FUNCTION wStandardWnd( aBase, nMaxWidth, nMaxHeight )
   LOCAL cForm  := "Form_1"
   LOCAL oBrw, nHbar, nCliW
   LOCAL nRow := 10, nCol := 10

   If _IsWindowDefined(cForm)
      RETURN NIL
   EndIf

   DEFINE WINDOW &cForm AT 0, 0 WIDTH nMaxWidth HEIGHT nMaxHeight ;
      TITLE PROGRAM                 ;
      ICON "1MAIN_ICO"              ;
      WINDOWTYPE STANDARD TOPMOST   ;
      NOMAXIMIZE NOSIZE             ;
      BACKCOLOR { 93,114,148}       ;
      ON INIT   {|| wMain.Hide, DoMethod( cForm, "Restore" ), ;
                    SetProperty(cForm, "Topmost", .F.) }

      nCliW := This.ClientWidth

      DEFINE STATUSBAR BOLD  
          STATUSITEM ''                           // остаток ширины тут
          STATUSITEM MiniGuiVersion() WIDTH nCliW * 0.4 ICON '1MAIN_ICO'
          STATUSITEM ''               WIDTH nCliW * 0.1
          DATE                        WIDTH 100
          CLOCK                       WIDTH 100
      END STATUSBAR

      // верхнее меню кнопок таблицы
      nHbar := MyToolBar(cForm, nRow, nCol, aBase )
      // установим кооординаты таблицы
      nY := nHbar + 5
      nX := 2
      nW := -( nX * 2 )
      nH := -( GetWindowHeight(This.StatusBar.Handle) + 4 )
      
      oBrw := MyTsb(1,aBase)  // первый вызов построения таблицы

      oStaticBrw := oBrw // для доступа из других функций

      oBrw:SetFocus()

   END WINDOW

   CENTER   WINDOW &cForm
   ACTIVATE WINDOW &cForm

 RETURN NIL

////////////////////////////////////////////////////////////
FUNCTION MyTsb( nBrw, aBase )
   LOCAL cForm  := ThisWindow.Name
   LOCAL cBrw   := "BrwLog"
   LOCAL cAlias
   LOCAL oBrw, lCell := .T., cFile
   LOCAL aFont, cFont, nFont
   LOCAL aBackcolor, aMarker[2], aCursorBC, aBackColor2

   aFont  := { "Tahoma", "Times New Roman", "Comic Sans MS", 'Arial' }
   cFile  := aBase[ nBrw, 1 ]     // File dbf
   cAlias := aBase[ nBrw, 2 ]     // Alias dbf
   cFont  := aFont[ nBrw ]
   nFont  := nPrivFsize               // Private variable
   aBackcolor := aPrivBColor[ nBrw ]  // Private variable
   This.BaseName.Value := "Alias: " + cAlias
  
   // Закрываем базу и удаляем объект таблицы при нажатии кнопки верхнего меню !
   // Close the database and delete the table object by clicking the top menu button!
   If _IsControlDefined(cBrw, cForm)
      If Select(cAlias) > 0
         ( cAlias )->( dbClosearea() )
      EndIf
      DoMethod(cForm, cBrw, 'Release')
   EndIf
   
   Use &cFile Via "DBFCDX" Alias &cAlias Shared New
  
   If OrdCount() > 0
      OrdSetFocus(1)
   EndIf

   // DEFINE TBROWSE ...
   oBrw := TBrw_Create(cBrw, cForm, nY, nX, nW, nH, cAlias, lCell, cFont, nFont, aBackcolor)  

   WITH OBJECT oBrw   // oBrw объект установлен\зарегистрирован

      :LoadFields(.F.) 
   
      :lNoChangeOrd := .T.               // убрать сортировку по полю
      :lNoGrayBar   := .T.               // неактивный курсор
      :nColOrder    := 0                 // убрать значок сортировки по полю
      :lNoHScroll   := .T.               // показ горизонтального скролинга
      :nHeightCell  += 5
      :nHeightHead  := :nHeightCell
      :nHeightFoot  := :nHeightHead      // высота строки подвала
      :lFooting     := .T.               // использовать подвал
      :lDrawFooters := .T.               // рисовать  подвалы
  
      aEval(:aColumns, {|oCol,nCol| oCol:cFooting := hb_ntos(nCol) }) // цифры в подвале таблицы
      aEval(:aColumns, {|oCol     | oCol:nFAlign  := DT_CENTER     }) // центровка подвала таблицы
      aEval(:aColumns, {|oCol     | oCol:lFixLite := .T.           }) // Fixed cursor , фикс.курсор

      // -------------- Тестовый вывод отладки в файл наимен.колонок таблицы ---------
      //   AEval(oBrw:aColumns, {|oCol,nCol| _LogFile(.T.,nCol, oCol:cName) })
  
      aMarker[ 1 ] := Rgb( 255, 255, 255 )   // белый
      aMarker[ 2 ] := Rgb( 127, 127, 127 )   // серый 25%          

      // переназначим цвет: строка маркера/курсора текущй записи базы
      aCursorBC := { 4915199,255}
      :SetColor( { 6}, { { |a,b,c,d| a:=d, IF( c:nCell == b, aCursorBC ,;  
                                { aMarker[1], aMarker[2] })  }  } )            

      // -------------------- Установить цвета в таблице ------------------------------
      :SetColor( { 1}, { { || CLR_BLACK                         } } ) // текста в ячейках таблицы
      :SetColor( { 3}, { { || CLR_YELLOW                        } } ) // текста шапки таблицы                                  
      :SetColor( { 4}, { { || { RGB(43,149,168), RGB(0,54,94) } } } ) // фона шапка таблицы
      :SetColor( { 9}, { { ||   CLR_YELLOW                      } } ) // текста подвала таблицы                                
      :SetColor( {10}, { { || { RGB(43,149,168), RGB(0,54,94) } } } ) // фона подвала таблицы                                  

      :nClrLine := RGB(43,149,168) // цвет линий между ячейками таблицы 
  
      aBackColor2 := { 215, 215, 215 }   // белый, затенение 15%
      If nBrw < 4
         // примеры закраски всей строки по номеру строки чётная\нечётная
         :SetColor( { 2}, { { |a,b,o| a:=b, iif( o:nAt % 2 == 0, MyRGB(aBackColor2 ), ;
                                                        MyRGB(aBackcolor) ) } } )
         If nBrw == 1 
            // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
            AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_1 ) } } )
         ElseIf nBrw == 2 
            // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
            AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_2 ) } } )
         EndIf
      Else
         // цвета для 4-й таблицы
         // примеры закраски всей строки по году поля FIELD->DATE_4
         :SetColor( { 2}, { { |a,b,o| a:=b, iif( Year( (o:cAlias)->DATE_4 ) % 2 == 0, ;
                                   MyRGB( aBackColor2 ), MyRGB( aBackcolor ) ) } } )

         // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
         AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_4 ) } } )
      Endif

      If nBrw == 3  // цвета для 3-й таблицы
         // ---- Ставим по всем колонкам ----( oCol:nClrBack = oBrw:SetColor( {2} ...) ----
         AEval(:aColumns, {|oCol| oCol:nClrBack := { |a,b,o| a:=b, ;
            iif( 'hmg' $ LOWER( (o:cAlias)->NAME_3 ) .OR. ;
                 'box' $ LOWER( (o:cAlias)->NAME_3 ), MyRGB({235,117,123}), ;
            iif( o:nAt % 2 == 0, MyRGB(aBackcolor), MyRGB(aBackColor2) ) ) } })
         // --- меняем цвета текста в ячейках таблицы --( oCol:nClrFore = oBrw:SetColor({1}...)---
         AEval(:aColumns, {|oCol| oCol:nClrFore := { |a,b,o| a:=b, MyTsbColorText( (o:cAlias)->ERR_3 ) } } )
      Endif

      :ResetVScroll()  // показ вертикального скроллинга

      // ------------ вывод в подвале ИТОГО по колонкам -----------------------
      :aColumns[1]:cFooting := { || '[' + HB_NtoS( oBrw:nLen ) + ']' }
      :aColumns[5]:cFooting := { || '[' + HB_NtoS( MyGetCountField("SIZE_",nBrw) ) + ' Mb]' }
  
   END WITH         // oBrw объект снят
  
   // END TBROWSE
   TBrw_Show(oBrw)           
   
   oBrw:Refresh(.T.)  // перечитать таблицу
   
   oBrw:nCell := 2    // передвинуть МАРКЕР 

   RETURN oBrw

////////////////////////////////////////////////////////////
STATIC FUNCTION MyTsbColorText(nVal)
   LOCAL nColor

   IF nVal == -1 
     nColor := CLR_HRED
   ELSEIF nVal == 1 
     nColor := CLR_HBLUE
   ELSE
     nColor := CLR_BLACK
   ENDIF

   RETURN nColor

///////////////////////////////////////////////////////////////////////////////////////////
// Функция подсчета суммы поля по таблице
FUNCTION MyGetCountField(cField,nBrw) 
   LOCAL cAlias, nLen, nRec

   nLen := 0
   cAlias := ALIAS()
   nRec := ( cAlias )->( RecNo() )
   cField := cField + HB_NtoS(nBrw)

   ( cAlias )->( DbEval( { || nLen += &(cField) } ) )

   ( cAlias )->( DbGoTo( nRec ) )

   nLen := nLen  / 1024 / 1024

   RETURN nLen

////////////////////////////////////////////////////////////
FUNCTION MyToolBar( cForm, nRow, nCol, aBase )
   LOCAL nY,nX,nW,nH,cB,cC,cT
   LOCAL nMaxWidth := This.ClientWidth     
       //-------------------Define user toolbar buttons------------------------------//
         nY := nRow
         nX := nCol
         nW := 48
         nH := 48
         
         cB := "Butt_1"; cC := "Dbf-1";  cT := "Open Base_1.dbf"
       @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT ;
                 BACKCOLOR aPrivBColor[1] BOLD ;
                 ACTION {|oBrw| oBrw := MyTsb(1,aBase), oBrw:SetFocus() ,;
                                oStaticBrw := oBrw, SetProperty(cForm,"StatusBar","Item",2,"") } ;
                 WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "Butt_2"; cC := "Dbf-2";  cT := "Open Base_2.dbf"
       @ nY, nX  BUTTONEX &cB  CAPTION cC TOOLTIP cT  ;
                 BACKCOLOR aPrivBColor[2] BOLD ;
                 ACTION {|oBrw| oBrw := MyTsb(2,aBase), oBrw:SetFocus() ,;
                                oStaticBrw := oBrw, SetProperty(cForm,"StatusBar","Item",2,"") } ;
                 WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "Butt_3"; cC := "Dbf-3";  cT := "Open Base_3.dbf"
       @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT  ;
                 BACKCOLOR aPrivBColor[3] BOLD ;
                 ACTION {|oBrw| oBrw := MyTsb(3,aBase), oBrw:SetFocus() ,;
                                oStaticBrw := oBrw, SetProperty(cForm,"StatusBar","Item",2,"") } ;
                 WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "Butt_4"; cC := "Dbf-4";  cT := "Open Base_4.dbf"
       @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT  ;
                 BACKCOLOR aPrivBColor[4] BOLD ;
                 ACTION {|oBrw| oBrw := MyTsb(4,aBase), oBrw:SetFocus() ,;
                                oStaticBrw := oBrw, SetProperty(cForm,"StatusBar","Item",2,"") } ;
                 WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
         nX += GetWindowWidth(GetControlHandle(cB, cForm))

         cB := "Butt_5"; cC := "Exit";   cT := "Exit from programm"
       @ nY, nX  BUTTONEX &cB  CAPTION cC  TOOLTIP cT  ;
                 FONTCOLOR WHITE BACKCOLOR MAROON BOLD     ;
                 ACTION ThisWindow.Release                 ;
                 WIDTH  nW HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP
         nX += GetWindowWidth(GetControlHandle(cB, cForm)) + nW
         
       @ nY, nX LABEL BaseName  VALUE '' WIDTH nMaxWidth-nX HEIGHT nH SIZE 20 ;
         FONTCOLOR WHITE TRANSPARENT VCENTERALIGN

       @ nY, nX + 250  BUTTONEX Butt_Metka1  CAPTION "Mark (1)"+ CRLF + "Column 8" ;
                 TOOLTIP "Сhange the label of the base field"  ;
                 FONTCOLOR WHITE BACKCOLOR LGREEN BOLD   ;
                 ACTION {|| Metka_Test() }               ;
                 WIDTH nW*2 HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP

       @ nY, nX + 250 + 5 + nW*2 BUTTONEX Butt_Metka2  CAPTION "Mark (2)"+ CRLF + "Column 8" ;
                 TOOLTIP "Сhange the label of the base field"  ;
                 FONTCOLOR WHITE BACKCOLOR LGREEN BOLD   ;
                 ACTION {|| Metka_Test2() }              ;
                 WIDTH nW*2 HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP

       @ nY, nX + 250 + 5*2 + nW*4  BUTTONEX Butt_Fltr  CAPTION "Filter"+ CRLF + "No filter" ;
                 TOOLTIP "To put / remove the filter on the base"  ;
                 FONTCOLOR WHITE BACKCOLOR BLUE BOLD     ;
                 ACTION {|| Filter_Test() }              ;
                 WIDTH nW*2 HEIGHT nH NOXPSTYLE HANDCURSOR NOTABSTOP

       nY += GetWindowHeight(GetControlHandle(cB, cForm))  

RETURN nY

///////////////////////////////////////////////////////////////////////////
FUNCTION MyCreateDbfCdx()
   LOCAL aBase, aDbf, aStr, a2Str, cPath := GetStartUpFolder()+"\" 
   LOCAL aFindPath, aFiles, cFileMask, aResult := NIL, cFld, cStr, nErr
   LOCAL nL, nI, nJ, cAlias, cFile, cFileIndx, cI, aField /*[9]*/
   LOCAL cPathBCC, cPathGUI, cPathSmpl, cPathIncl, lHmg
 
   aDbf := {'zBASE_1.DBF','zBASE_2.DBF','zBASE_3.DBF','zBASE_4.DBF'}
   aStr := {} 
   AAdd( aStr, { 'NN'  , 'N',  6, 0 } )
   AAdd( aStr, { 'TBL' , 'C', 15, 0 } )
   AAdd( aStr, { 'PATH', 'C', 35, 0 } )
   AAdd( aStr, { 'NAME', 'C', 30, 0 } )
   AAdd( aStr, { 'SIZE', 'N', 12, 0 } )
   AAdd( aStr, { 'DATE', 'D',  8, 0 } )
   AAdd( aStr, { 'TIME', 'C', 10, 0 } )
   AAdd( aStr, { 'DIR' , 'L',  1, 0 } )
   AAdd( aStr, { 'ERR' , 'N',  2, 0 } )

   aBase := {} 
   // Проверка на наличие файлов и создание их из путей МиниГуи
   If !file(cPath + aDbf[1]) .OR. !file(cPath + aDbf[2])  .OR. ;
      !file(cPath + aDbf[3]) .OR. !file(cPath + aDbf[4])

      cPathBCC  := GetEnv( 'MG_BCC'  )
      cPathGUI  := GetEnv( 'MG_ROOT' )
      lHmg := IIF( cPathGUI == "", .F., .T. )
      cPathBCC  := IIF( cPathBCC == "", GetEnv( 'windir' ), cPathBCC )
      cPathGUI  := IIF( lHmg, cPathGUI, GetEnv( 'windir' )                              )
      cPathIncl := IIF( lHmg, cPathGUI+"\Include" , GetEnv( 'windir' )+"\Help"          )
      cPathSmpl := IIF( lHmg, cPathGUI+"\SAMPLES" , GetEnv( 'windir' )+"\Microsoft.NET" )
      aFindPath := { cPathBCC, cPathGUI, cPathIncl, cPathSmpl }

      SET WINDOW MAIN OFF
      WaitWindow( "Processing...", .T. )
      For nI := 1 TO 4
         a2Str := {}
         For nJ := 1 TO LEN(aStr)
             cFld := aStr[nJ,1]+"_"+hb_ntos(nI)
             AADD( a2Str, { cFld,aStr[nJ,2],aStr[nJ,3],aStr[nJ,4] } )
         Next
         cFile := cPath + aDbf[nI]
         DbCreate( cFile, a2Str )
         Use (cFile) Via "DBFCDX" Alias BASE Exclusive New

         cFileMask := IIF( nI == 4 .AND. lHmg, "*.prg", "*.*" )
         aFiles := DirectoryRecurse( aFindPath[nI], cFileMask, aResult )
         Select BASE
         cI := "_"+hb_ntos(nI)
         aField := { 'NN'+cI, 'TBL'+cI, 'PATH'+cI, 'NAME'+cI, 'SIZE'+cI,'DATE'+cI, 'TIME'+cI, 'DIR'+cI, 'ERR'+cI }
         For nJ := 1 TO LEN(aFiles)
             APPEND BLANK
             BASE->&(aField[1]) := nJ
             BASE->&(aField[2]) := "Table ( " + HB_NtoS(nI) + " )" 
             If nI == 4
                nL := LEN(cPathSmpl)
                cStr := cFilePath( aFiles[nJ,1] ) + "\"
                cStr := "..." + SUBSTR( cStr, nL+1 )
                BASE->&(aField[3]) := cStr
             Else
                BASE->&(aField[3]) := cFilePath( aFiles[nJ,1] ) + "\"
             Endif
             BASE->&(aField[4]) := cFileNoPath( aFiles[nJ,1] )
             BASE->&(aField[5]) := aFiles[nJ,2] 
             BASE->&(aField[6]) := aFiles[nJ,3]
             BASE->&(aField[7]) := aFiles[nJ,4]
             BASE->&(aField[8]) := IIF( aFiles[nJ,5] == "D", .F. , .T. )
             nErr := IIF( nJ % 11 == 0, -1, IIF( nJ % 7 == 0, 1, 0 ) )
             BASE->&(aField[9]) := nErr
         Next
         cFileIndx := ChangeFileExt( cFile, ".cdx" )
         If ! File(cFileIndx)
            cFld := "Upper(FIELD->PATH_"+hb_ntos(nI)+")"
            If nI == 1 
               INDEX ON &cFld TAG Name
            ElseIf nI == 2
               INDEX ON &cFld TAG Name
            ElseIf nI == 3   
               INDEX ON &cFld TAG Name
            Else
               INDEX ON DTOS(FIELD->DATE_4) TAG Name
            Endif
         Endif
         Close BASE
         cAlias := 'BASE_' + HB_NtoS(nI)
         AADD( aBase, { cFile, cAlias } )
      Next
      WaitWindow()
      SET WINDOW MAIN ON
   Else
      For nI := 1 TO 4
         cFile := cPath + aDbf[nI]
         cAlias := 'BASE_' + HB_NtoS(nI)
         AADD( aBase, { cFile, cAlias } )
      NEXT
   Endif

   RETURN aBase

///////////////////////////////////////////////////////////////////////////
Static Function DirectoryRecurse( cPath, cFileMask, aResult )
   local n, aFiles := Directory( cPath + "\*.*", "D" )
   local aFindMask := Directory( cPath + "\" + cFileMask )

   if ProcName( 5 ) == "DIRECTORYRECURSE"
      return {}
   endif

   if aResult == NIL
      aResult := {}
   endif

   if Len( aFindMask ) > 0

      Aeval( aFindMask, { |e| if( "TMP" $ e[ 1 ] .or. !"." $ e[ 1 ], , Aadd( aResult, {cPath + "\" + e[ 1 ], e[ 2 ], e[ 3 ], e[ 4 ], e[ 5 ]} ) ) } )

   endif

   for n := 1 to Len( aFiles )

      if "D" $ aFiles[ n ][ 5 ] .and. ! ( aFiles[ n ][ 1 ] $ ".." )

         DirectoryRecurse( cPath + "\" + aFiles[ n ][ 1 ], cFileMask, aResult )

      endif

   next

   Return aResult

////////////////////////////////////////////////////////////////////
STATIC FUNCTION MyRGB( aDim )
   RETURN RGB( aDim[1], aDim[2], aDim[3] )

////////////////////////////////////////////////////////////////////
// filling the column with the help of the table
// заполнение колонки средствами таблицы
FUNCTION Metka_Test()   
   LOCAL nI, nRPos, nRecAll, nCol, lMark, cFld, cAlias, bBlock, nCell

   cAlias := oStaticBrw:cAlias 
   cFld := 'DIR'+SUBSTR(cAlias,5)  // DIR_1, DIR_2, ...
   nCol := oStaticBrw:nColumn(cFld) 
   bBlock := oStaticBrw:GetColumn(cFld):bData

   nCell := oStaticBrw:nCell       // номер текущего столбца в таблице
   nRPos := oStaticBrw:nAt         // номер текущей строки в таблице
   // или
   // nRPos := oStaticBrw:nRowPos  
   
   nRecAll := oStaticBrw:nLen      // общее кол-во записей

   WaitWindow( "Processing...", .T. )   // open the wait window

   For nI := 1 To nRecAll                 
      oStaticBrw:GoPos(nI,nCol)    // передвинуть МАРКЕР по строке и колонке
      lMark  := Eval(bBlock)       // получить значение колонки DIR_1/2/3/4
      IF (cAlias)->(RLock())
         Eval(bBlock, !lMark)      // записать значение в колонку DIR_1/2/3/4
         (cAlias)->( DbUnlock() )
      ELSE
         MsgStop("Line " +HB_NtoS(nI)+ " in the table is blocked!")
      ENDIF
      //oStaticBrw:DrawSelect()    // перерисовать тек.строку курсора - не обязательно
   Next
   oStaticBrw:GoTop() 
   oStaticBrw:GoPos(nRPos,nCell)   // передвинуть на строку где первоначально стоял МАРКЕР 
   (cAlias)->( DBCOMMIT() )

   WaitWindow()            // close the wait window

   oStaticBrw:SetFocus() 
  
   RETURN Nil

//////////////////////////////////////////////////////////////////////////
// filling the base field with the database driver
// заполнение поля базы средствами драйвера базы
FUNCTION Metka_Test2()   
   LOCAL nRec, lMark, cFld, cAlias 

   cAlias := oStaticBrw:cAlias 
   cFld := 'DIR'+SUBSTR(cAlias,5)     // DIR_1, DIR_2, ...

   WaitWindow( "Processing...", .T. ) // open the wait window

   SELECT(cAlias) 
   nRec := (cAlias)->( RecNo() )      // номер текущей записи
   (cAlias)->( dbGotop() )
   DO WHILE ! (cAlias)->( EOF() )
      lMark  := (cAlias)->&(cFld)     // получить значение колонки DIR_1/2/3/4
      IF (cAlias)->(RLock())
         (cAlias)->&(cFld) := !lMark  // записать значение в колонку DIR_1/2/3/4
         (cAlias)->( DbUnlock() )
      ELSE
         MsgStop("Recording " +HB_NtoS(RECNO())+ " in the database is blocked!")
      ENDIF
      SKIP
   ENDDO
   (cAlias)->( DBCOMMIT() )

   oStaticBrw:Refresh()     
   (cAlias)->( dbGoto( nRec ) )     // передвинуть на номер где первоначально стоял МАРКЕР 

   WaitWindow()                    // close the wait window

   oStaticBrw:SetFocus() 
  
   RETURN Nil

////////////////////////////////////////////////////////////////////
FUNCTION Filter_Test()
   LOCAL cExp, cAlias, cVal, cForm

   lStaticFilter := !lStaticFilter

   cForm  := oStaticBrw:cParentWnd
   cAlias := oStaticBrw:cAlias 

   IF cAlias == 'BASE_1'
      cExp := "'.EXE' $ UPPER(NAME_1)"
   ELSEIF cAlias == 'BASE_2'
      cExp := "'.EXE' $ UPPER(NAME_2)"
   ELSEIF cAlias == 'BASE_3'
      cExp := "'HMG' $ UPPER(NAME_3)"
   ELSEIF cAlias == 'BASE_4'
      cExp := "'MAIN.' $ UPPER(NAME_4)"
   ENDIF

   SELECT(cAlias) 

   IF lStaticFilter
      (cAlias)->( DbSetFilter( &("{||" + cExp + "}"), cExp ) )
      cVal := " Filter: " + cExp
   ELSE
      (cAlias)->( DbClearFilter() )
      cVal := " No Filter !" 
   END

   SetProperty ( cForm, "StatusBar" , "Item" , 2 , cVal )

   oStaticBrw:Reset() 
   oStaticBrw:GoTop() 
   oStaticBrw:SetFocus() 
  
   RETURN Nil
