/*                                                         
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
 * Экспорт таблицы в Excel xls/xml
 * Export table to Excel xls/xml     
*/
                                     
#define _HMG_OUTLOG

#include "hmg.ch"
#include "TSBrowse.ch"

REQUEST HB_CODEPAGE_RU1251 
REQUEST DBFCDX, DBFFPT

#define  SHOW_WAIT_WINDOW_LINE    1000

STATIC TSB_SUPERHEADER := .T. , TSB_MULTILINE := .F.
STATIC TSB_HEADER      := .T. , TSB_FOOTING   := .T.
/////////////////////////////////////////////////////////////////////////////
PROCEDURE MAIN( cParam )
   LOCAL aParam, nCol, oBrw, aDatos 
   LOCAL hFont, nFont 
   LOCAL cFontName1 := "Comic Sans MS" 
   LOCAL cFontName2 := _HMG_DefaultFontName
   LOCAL cFontName3 := _HMG_DefaultFontName
   LOCAL cFontName4 := _HMG_DefaultFontName
   LOCAL cFontName5 := _HMG_DefaultFontName
   LOCAL cFontName6 := "Times New Roman"
   LOCAL cFontName7 := "Arial Black"
   LOCAL nFontSize  := 16 
   LOCAL nWwnd, nLine, nHcell, nHrow, nHSpr, nHhead, nHfoot, nHwnd
   DEFAULT cParam := ""

   If ! empty(cParam) 
      aParam := &cParam
      TSB_SUPERHEADER := aParam[1]
      TSB_HEADER      := aParam[2]
      TSB_FOOTING     := aParam[3]
      TSB_MULTILINE   := aParam[4]
   EndIf

   SET DECIMALS TO 4
   SET DATE     TO GERMAN
   SET EPOCH    TO 2000
   SET CENTURY  ON
   SET EXACT    ON
   SET MULTIPLE OFF WARNING 
   RDDSETDEFAULT('DBFCDX')

   SET FONT     TO cFontName1, nFontSize

   DEFINE FONT Font_1  FONTNAME cFontName1 SIZE nFontSize BOLD
   DEFINE FONT Font_2  FONTNAME cFontName2 SIZE nFontSize BOLD
   DEFINE FONT Font_3  FONTNAME cFontName3 SIZE nFontSize 
   DEFINE FONT Font_4  FONTNAME cFontName4 SIZE nFontSize 
   DEFINE FONT Font_5  FONTNAME cFontName5 SIZE nFontSize 
   DEFINE FONT Font_6  FONTNAME cFontName6 SIZE nFontSize 
   DEFINE FONT Font_7  FONTNAME cFontName7 SIZE nFontSize 

   TsbFont()                      // init фонты работы для tsb

   aDatos := CreateDatos(nLine) // создать массив для показа в таблице

   AAdd( aDatos, GetFontHandle( "Font_7" ) )  // массив фонтов header, footer
   
   // вычислить высоту таблицы, алгоритм тсб
   hFont := InitFont( cFontName1, nFontSize )    
   nFont := GetTextHeight( 0, "B", hFont ) + 1  // высота шрифта для таблицы
   DeleteObject( hFont )
   
   nLine  := iif( empty(nLine), 15, nLine )  // кол-во строк  в таблице
   nHcell := nFont + 6                       // высота ячейки в таблице

   nHhead := nHfoot := nHSpr := nHcell       // высота шапки, подвала и суперхидера таблицы для одной строчки 
                                             // задаём равным высоте ячейке в таблице, если две строчки, то * 2
   nHrow  := nLine * nHcell + 1              // высота всех строк в таблице 
                                             // + 1 увеличиваем высоту на XX пиксел 
   IF TSB_MULTILINE 
      nHcell := nFont * 3                    // высота ячейки в таблице для 3-х строк
      nHhead := nFont * 2                    // высота шапка таблицы для 2-х строк
      nHfoot := nFont * 2                    // высота подвал таблицы для 2-х строк
      nHSpr  := nFont * 2                    // высота суперхидера таблицы для 2-х строк
   ENDIF

   IF ! TSB_SUPERHEADER  // нет суперхидера таблицы - показ только 1 пикселя
      nHSpr := 1
   ENDIF
   IF ! TSB_HEADER       // нет шапки таблицы - показ только 1 пикселя
      nHhead := 1
   ENDIF
   IF ! TSB_FOOTING      // нет подвала таблицы - показ только 1 пикселя
      nHfoot := 1
   ENDIF

   nHwnd  := nHhead + nHrow + nHfoot + nHSpr + 56 // итоговая высота таблицы
                                                  // 56=5+46+5 - отступ сверху окна
   nWwnd  := 300 // ширину окна потом пересчитаем и приведем к ширине таблицы 

   DEFINE WINDOW test                          ;
      AT 0,0 WIDTH nWwnd HEIGHT 720            ;
      TITLE "SetArrayTo Demo - Export XLS/XML/DOC/DBF !" ;
      ICON  "1MAIN_ICO"                        ;
      MAIN  TOPMOST NOMAXIMIZE NOSIZE          ;
      BACKCOLOR { 93,114,148}                  ;
      ON INIT ( TestErrorLine(oBrw), OnInitTest(oBrw,cParam), This.Topmost := .F. )

      @ 5, 10 BUTTONEX BUTTON_Tsb WIDTH 150 HEIGHT 46                               ;
         CAPTION "Table" ICON "iTable32x1" FONTCOLOR BLACK                          ;
         SIZE 16 BOLD FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                           ;
         BACKCOLOR { { 0.5, CLR_GRAY, CLR_MAGENTA }    , { 0.5, CLR_MAGENTA, CLR_GRAY } } ;
         GRADIENTFILL { { 0.5, CLR_MAGENTA, CLR_WHITE }, { 0.5, CLR_WHITE, CLR_MAGENTA } } ; 
         ON MOUSEHOVER ( This.Backcolor := BLACK , This.Fontcolor := WHITE , This.Icon := "iTable32x2" ) ; 
         ON MOUSELEAVE ( This.Backcolor := ORANGE, This.Fontcolor := BLACK , This.Icon := "iTable32x1" ) ; 
         ACTION TableSetup(oBrw) 

      @ 5, 170 BUTTONEX BUTTON_Color WIDTH 150 HEIGHT 46                             ;
         CAPTION "Color" ICON "iColor32x1" FONTCOLOR BLACK                          ;
         SIZE 16 BOLD FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                           ;
         BACKCOLOR { { 0.5, CLR_GRAY, CLR_GREEN } , { 0.5, CLR_GREEN, CLR_GRAY } }  ;
         GRADIENTFILL { { 0.5, RGB(255,128,64), CLR_WHITE }, { 0.5, CLR_WHITE, RGB(255,128,64) } } ; 
         ON MOUSEHOVER ( This.Backcolor := BLACK , This.Fontcolor := WHITE , This.Icon := "iColor32x2" ) ; 
         ON MOUSELEAVE ( This.Backcolor := ORANGE, This.Fontcolor := BLACK , This.Icon := "iColor32x1" ) ; 
         ACTION TableColor(oBrw) 

      @ 5, 330 BUTTONEX BUTTON_Export WIDTH 150 HEIGHT 46                          ;
         CAPTION "Export" ICON "iXls32x1" FONTCOLOR BLACK                          ;
         SIZE 16 BOLD  FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                         ;
         BACKCOLOR { { 0.5, CLR_BLACK, CLR_GREEN } , { 0.5, CLR_GREEN, CLR_BLACK } } ;
         GRADIENTFILL { { 0.5, CLR_GREEN, CLR_WHITE }, { 0.5, CLR_WHITE, CLR_GREEN } }            ; 
         ON MOUSEHOVER ( This.Backcolor := BLACK  , This.Fontcolor := WHITE , This.Icon := "iXls32x2" ) ; 
         ON MOUSELEAVE ( This.Backcolor := LGREEN , This.Fontcolor := BLACK , This.Icon := "iXls32x1" ) ; 
         ACTION TableExport(oBrw)

      @ 5, 490 BUTTONEX BUTTON_Exit WIDTH 150 HEIGHT 46                          ;
         CAPTION "Exit" ICON "iExit32x1" FONTCOLOR BLACK                         ;
         SIZE 16 BOLD FLAT NOXPSTYLE HANDCURSOR NOTABSTOP                        ;
         BACKCOLOR { { 0.5, CLR_WHITE, CLR_GREEN } , { 0.5, CLR_GREEN, CLR_WHITE } } ;
         GRADIENTFILL { { 0.5, CLR_HRED, CLR_WHITE }, { 0.5, CLR_WHITE, CLR_HRED } }            ; 
         ON MOUSEHOVER ( This.Backcolor := BLACK  , This.Fontcolor := WHITE , This.Icon := "iExit32x2" ) ; 
         ON MOUSELEAVE ( This.Backcolor := RED    , This.Fontcolor := BLACK , This.Icon := "iExit32x1" ) ; 
         ACTION ThisWindow.Release

      nCol := test.Button_Exit.Col + test.Button_Exit.Width + 20
      @ 10, nCol PROGRESSBAR PBar_1 WIDTH 300 HEIGHT 36 ;
         RANGE 0,100  VALUE 0   

      DEFINE TBROWSE oBrw AT 46+10, 0 ;
         WIDTH  ThisWindow.ClientWidth ;
         HEIGHT ThisWindow.ClientHeight - 46 -10 ;
         FONT  cFontName1  SIZE  nFontSize ;
         GRID

         // создать таблицу / сreate table
         TsbCreate(oBrw, aDatos, nHSpr, nHcell, nHhead, nHfoot)

      END TBROWSE

   END WINDOW

   CENTER   WINDOW test
   ACTIVATE WINDOW test
   
RETURN
* ======================================================================
STATIC FUNCTION OnInitTest(oBrw,cParam)
   LOCAL nCol, nPBarWidth, nMaxWidth, nMaxHeight

   _Restore( This.Handle )  // восстановить окно программы на экране при перезапуске
   DO EVENTS

   nMaxWidth  := This.ClientWidth   
   nMaxHeight := This.ClientHeight
   // установим новую ширину PROGRESSBAR
   nCol := test.Button_Exit.Col + test.Button_Exit.Width + 20
   nPBarWidth := nMaxWidth - nCol - 20
   test.PBar_1.Width := nPBarWidth
   test.PBar_1.Setfocus

   ? "Start - " + cFileNoPath( Application.ExeName ) + " " + cParam 
   ? "  Number of records in the table: " + HB_NtoS(oBrw:nLen)
   ? "  "+ OS()
   ? "  "+ MiniGuiVersion()
   ? "  ."

   oBrw:SetFocus()  // фокус на таблицу

RETURN NIL

* ======================================================================
STATIC FUNCTION TsbCreate( oBrw, aDatos, nHSpr, nHcell, nHhead, nHfoot )
   LOCAL aRect := GetDeskTopArea()   //   { left, top, right, bottom }
   LOCAL nDeskTopWidth  := aRect[ 3 ] - aRect[ 1 ] - GetBorderWidth()
   LOCAL nDeskTopHeight := aRect[ 4 ] - aRect[ 2 ] - GetBorderHeight()
   LOCAL aArray, aFontHF, aHead, aSize, aFoot, aPict, aAlign, aName
   LOCAL nI, nCol, oCol, nWwnd

   aArray   := aDatos[ 1 ]        // массив значений
   aHead    := aDatos[ 2 ]        // массив шапки таблицы
   aSize    := aDatos[ 3 ]        // массив размеров колонок таблицы
   aFoot    := aDatos[ 4 ]        // массив подвала таблицы
   aPict    := aDatos[ 5 ]        // массив шаблонов для значений таблицы
   aAlign   := aDatos[ 6 ]        // массив центрирования значений
   aName    := aDatos[ 7 ]        // массив имен колонок для обращения через них
   aFontHF  := aDatos[ 8 ]        // массив фонтов header, footer

   WITH OBJECT oBrw  // oBrw объект установлен\зарегистрирован

      :Cargo := 6         // задаём свой номер цвета/закраски таблицы

      // создаём таблицу из массивов
      :SetArrayTo(aArray, aFontHF, aHead, aSize, aFoot, aPict, aAlign, aName)

      // Создаём СУПЕРХИДЕР в таблице  
      If TSB_SUPERHEADER

         nCol := :nColumn('Name_5')
         ADD SUPER HEADER TO oBrw FROM COLUMN    1     TO COLUMN nCol  ;
             COLOR CLR_WHITE, CLR_BLACK TITLE " SuperHider_1" + ;
             IIF(TSB_MULTILINE, CRLF + " line-2" , "") HORZ DT_LEFT  

         ADD SUPER HEADER TO oBrw FROM COLUMN nCol + 1 TO :nColCount()  ;
             COLOR CLR_WHITE, CLR_BLACK TITLE "SuperHider_2 " + ;
             IIF(TSB_MULTILINE, CRLF + "line-2 " , "") HORZ DT_RIGHT  

         :nHeightSuper := nHSpr  // высота заголовка ( суперхидер )

      EndIf

      :lNoHScroll   := .T.         // не показывать вертикального скролинга
      :nWheelLines  := 1           // прокрутка колесом мыши
      :nClrLine     := COLOR_GRID  // цвет линий между ячейками таблицы
      :lNoChangeOrd := .T.         // убрать сортировку по полю в таблице
      :nColOrder    := 0           // убрать значок сортировки по полю
      :lNoGrayBar   := .F.         // показывать неактивный курсор в таблице

      /*:nHeightSuper := nHSpr    // высота заголовка ( суперхидер ) */
      :nHeightCell  := nHcell   // высота ячейки в таблице
      :nHeightHead  := nHhead   // высота шапки таблицы для одной строчки
      :nHeightFoot  := nHfoot   // высота подвала таблицы для одной строчки
      :lFooting     := .T.      // использовать подвал
      :lDrawFooters := .T.      // рисовать  подвалы

      :nFreeze      := 1        // заморозить первый столбец
      :lLockFreeze  := .T.      // избегать прорисовки курсора на замороженных столбцах

      :nLineStyle   := LINES_ALL   // LINES_NONE LINES_ALL LINES_VERT LINES_HORZ LINES_3D LINES_DOTTED
                                   // стиль линий в таблице

      For nI := 1 To :nColCount()
         oCol            := :aColumns[ nI ]
         // центровка подвала таблицы
         oCol:nFAlign    := DT_CENTER
         If oCol:cName == 'Name_1'
            oCol:nAlign  := DT_CENTER  // центровка колонки 'Name_1'
         EndIf
         // фонты для строк таблицы
         oCol:hFont      := {|nr,nc,ob| TsbFont(nr, nc, ob)} 
         // -------------- Fixed cursor , фиксированный курсор ---------
         :aColumns[nI]:lFixLite := TRUE
                                               
         IF ! TSB_HEADER
            oCol:cHeading := ''
         ENDIF
         IF ! TSB_FOOTING
            oCol:cFooting := ''
         ENDIF                                 
      Next

      TsbColor( oBrw )  // задание цветов таблицы

      // вычислить ширину таблицы 
      nWwnd := :GetAllColsWidth() + GetBorderWidth()   // ширина всех колонок таблицы

      If :nLen > :nRowCount()   //  кол-во строк таблицы > кол-ва строк таблицы на экране
         nWwnd += GetVScrollBarWidth()   // добавить к ширине таблицы если есть вертикальный скролинг
      EndIf

      IF nWwnd > nDeskTopWidth               // ширина таблицы больше ширины экрана
         nWwnd := nDeskTopWidth
         :lNoHScroll   := .F.                // показывать горизонтальный скролинг
      ENDIF

      ThisWindow.Width  := nWwnd             // установим внешнюю ширину окна
      This.oBrw.Width   := This.ClientWidth  // установим ширину таблицы по клиентской области окна

   END WITH  // oBrw объект снят

   // только для 6 колонки
   oBrw:aColumns[6]:cPicture := '@R 99:99:99' // без этого не работает

   oBrw:SetNoHoles() // убрать дырку внизу таблицы 

   oBrw:GoPos( 5, oBrw:nFreeze + 2 ) // уст. МАРКЕР на ХХ строку и ХХ колонку
   oBrw:SetFocus()

   RETURN Nil

* ======================================================================
STATIC FUNCTION TsbColor( oBrw, aHColor, aBColor, nHClr1, nHClr2 )
   DEFAULT aHColor := {255, 255, 255} , ;      // Цвет шапки таблицы
           aBColor := {174, 174, 174} , ;      // Цвет фона  таблицы
           nHClr2  := MyRGB( aHColor ), ;
           nHClr1  := MyRGB( { 51, 51, 51 } )

   WITH OBJECT oBrw  // oBrw объект установлен\зарегистрирован
   
     :SetColor( { 1}, { { || CLR_BLACK                         } } ) // 1 , текста в ячейках таблицы                              
     :SetColor( { 2}, { { || MyRGB(aBColor)                    } } ) // 2 , фона в ячейках таблицы                                
     :Setcolor( { 3}, { CLR_WHITE                                } ) // 3 , текста шапки таблицы 
     :SetColor( { 4}, { { || { nHClr1, nHClr2                } } } ) // 4 , фона шапка таблицы
     :SetColor( { 5}, { { ||   CLR_YELLOW                      } } ) // 5 , текста курсора, текст в ячейках с фокусом             
     :SetColor( { 6}, { { || { CLR_HBLUE,0}                    } } ) // 6 , фона курсора                                          
     :SetColor( { 7}, { { ||   CLR_RED                         } } ) // 7 , текста редактируемого поля                            
     :SetColor( { 8}, { { ||   CLR_YELLOW                      } } ) // 8 , фона редактируемого поля                              
     :SetColor( { 9}, { CLR_WHITE                              } ) // 9 , текста подвала таблицы                                
     :SetColor( {10}, { { || { nHClr1, nHClr2                } } } ) // 10, фона подвала таблицы                                  
     :SetColor( {11}, { { ||   CLR_GRAY                        } } ) // 11, текста неактивного курсора (selected cell no focused)
     :SetColor( {12}, { { || { RGB(255,255,74), RGB(240,240,0)}} } ) // 12, фона неактивного курсора (selected cell no focused)   
     :SetColor( {13}, { { ||   CLR_HRED                        } } ) // 13, текста шапки выбранного индекса
     :SetColor( {14}, { { || { nHClr1, nHClr2                } } } ) // 14, фона шапки выбранного индекса  
     :SetColor( {15}, { { ||   CLR_WHITE                       } } ) // 15, линий между ячейками таблицы 
     :SetColor( {16}, { { || { CLR_BLACK, CLR_GRAY           } } } ) // 16, фона спецхидер                                  
     :SetColor( {17}, { { || CLR_YELLOW                        } } ) // 17, текста спецхидер
     
     // ---- cтавим цвет фона по всем колонкам ----( oCol:nClrBack = oBrw:SetColor( {2} ...) ----
     AEval(:aColumns, {|oCol| oCol:nClrBack := { |nr,nc,ob| TsbColorBack(nr,nc,ob) } } )
     AEval(:aColumns, {|oCol| oCol:nClrFore := { |nr,nc,ob| TsbColorFore(nr,nc,ob) } } )

   END WITH  // oBrw объект снят

   RETURN Nil
   
* ======================================================================
FUNCTION TsbGet( oBrw, xCol )
RETURN Eval( oBrw:GetColumn(xCol):bData )
   
* ======================================================================
FUNCTION TsbPut( oBrw, xCol, xVal )
RETURN Eval( oBrw:GetColumn(xCol):bData, xVal )

* ======================================================================
STATIC FUNCTION TsbColorBack( nAt, nCol, oBrw )
   LOCAL nTsbColor := oBrw:Cargo  // current color from oBrw:Cargo
   // пример для раскраски таблицы по колонке сумма
   LOCAL nSumma := TsbGet(oBrw, 'Name_9' )
   LOCAL nClr3  := TsbGet(oBrw, 'Name_3' )
   LOCAL nColor

   // обработка ошибочной ситуации
   IF VALTYPE(nSumma) != "N" 
      nColor := CLR_RED  
      RETURN nColor
   ENDIF

   IF     nTsbColor == 1   // the default color of the table
         nColor := CLR_WHITE
   ELSEIF nTsbColor == 2   // color table gray
      nColor := CLR_HGRAY
   ELSEIF nTsbColor == 3   // color of the table "ruler"
      IF nAt % 2 == 0
         nColor := CLR_HGRAY
      ELSE
         nColor := CLR_WHITE
      ENDIF
   ELSEIF nTsbColor == 4    // the color of the table "columns"
      IF nCol % 2 == 0
         nColor := CLR_HGRAY
      ELSE
         nColor := CLR_WHITE
      ENDIF
   ELSEIF nTsbColor == 5    // the color of the table "chess"
      IF nAt % 2 == 0
         If nCol % 2 == 0; nColor := CLR_HGRAY
         Else            ; nColor := CLR_WHITE
         EndIf
      ELSE
         If nCol % 2 == 0; nColor := CLR_WHITE
         Else            ; nColor := CLR_HGRAY
         EndIf
      ENDIF
   ELSEIF nTsbColor == 6    // the color of the table "multicolor"
      IF     nClr3 == 1
         nColor := RGB(159,191,236)  // Office_2003 Blue
      ELSEIF nClr3 == 2
         nColor := RGB(234,240,207)  // Office_2003 GREEN 
      ELSEIF nClr3 == 3
         nColor := RGB(225,226,236)  // Office_2003 SILVER 
      ELSEIF nClr3 == 4
         nColor := RGB(251,230,148)  // Office_2003 ORANGE 
      ELSEIF nClr3 == 5
         nColor := RGB(255,153,255)  // Office_2003 PURPLE
      ELSEIF nClr3 == 6
         nColor := RGB(118,170,235)  // TWITER
      ELSEIF nClr3 == 7
         nColor := RGB(225,237,204)  // 
      ELSEIF nClr3 == 8
         nColor := RGB(229,220,229)  //  
      ELSEIF nClr3 == 9
         nColor := RGB(51,255,255)   //  
      ELSE
         nColor := CLR_WHITE
      ENDIF
   ENDIF
   // цвет по условию сумма
   IF nSumma == 1500
      nColor := RGB(255,128,64) // ORANGE
   ENDIF

   RETURN nColor

* ======================================================================
STATIC FUNCTION TsbColorFore( nAt, nCol, oBrw )
   LOCAL nColor, nTsbColor := TsbGet(oBrw, 'Name_9')
   Default nAt := 0 , nCol := 0

   // обработка ошибочной ситуации
   IF VALTYPE(nTsbColor) != "N" 
      nColor := CLR_HGRAY  
      RETURN nColor
   ENDIF

   IF nTsbColor <= -100    
      nColor := CLR_HRED
   ELSEIF nTsbColor < 0         
      nColor := CLR_RED
   ELSE 
      nColor := CLR_BLACK
   ENDIF

   RETURN nColor

* ======================================================================
STATIC FUNCTION MyRGB( aDim )
   RETURN RGB( aDim[1], aDim[2], aDim[3] )

* ======================================================================
STATIC FUNCTION TestErrorLine( oBrw )  // Эмуляция ошибки
   LOCAL nI
   // Удаляем значения, для создания ошибочных ситуаций.
   // тестовая проверка правильной работы при ошибках в таблице. 
   For nI := 2 To oBrw:nColCount()
      TsbPut( oBrw, nI, NIL )   
   Next
   oBrw:Refresh(.T.)               // перечитывает данные в таблице 

   RETURN NIL   

* ======================================================================
STATIC FUNCTION TsbFont( nAt, nCol, oBrw )
   LOCAL hFont, lVal
   STATIC a_Font
   Default nAt := 0

   If a_Font == Nil .or. pCount() == 0
      a_Font := {}

      AAdd( a_Font, GetFontHandle( "Font_1" ) )
      AAdd( a_Font, GetFontHandle( "Font_2" ) )
      AAdd( a_Font, GetFontHandle( "Font_3" ) )
      AAdd( a_Font, GetFontHandle( "Font_4" ) )
      AAdd( a_Font, GetFontHandle( "Font_5" ) )
      AAdd( a_Font, GetFontHandle( "Font_6" ) )
      AAdd( a_Font, GetFontHandle( "Font_7" ) )

      RETURN a_Font
   EndIf

   lVal := TsbGet(oBrw, 2)     // или так oBrw:aArray[ nAt ][2]
   IF VALTYPE(lVal) != "L"
      lVal := .F.
   ENDIF

   If     nCol == 1             // фонт столбца 1 
       hFont := a_Font[7]
   ElseIf lVal                  // изменить фонт строки ячеек таблицы 
       hFont := a_Font[1]       // по условию для колонки 2
   Else                        
       hFont := a_Font[6]
   EndIf
       
RETURN hFont

* ======================================================================
FUNCTION TableSetup(oBrw)   
   LOCAL Font1, Font2, Font3, Font7, nY, nX
   LOCAL cForm  := oBrw:cParentWnd
   LOCAL nTsbSH := 0, nTsbML := 0, nTsbH := 0, nTsbF := 0
   LOCAL lTsbSH := TSB_SUPERHEADER           
   LOCAL lTsbML := TSB_MULTILINE            
   LOCAL lTsbH  := TSB_HEADER            
   LOCAL lTsbF  := TSB_FOOTING            
   LOCAL cParam, aParam[4]

   nY := GetProperty(ThisWindow.Name,This.Name,"Row") + GetProperty(ThisWindow.Name,This.Name,"Height")
   nX := GetProperty(ThisWindow.Name,This.Name,"Col")
   nY += GetProperty(cForm, "Row") + GetTitleHeight() + 2
   nX += GetProperty(cForm, "Col") + GetBorderWidth() - 4         
   
   Font1 := GetFontHandle( "Font_1" )
   Font2 := GetFontHandle( "Font_6" )
   Font3 := GetFontHandle( "Font_3" )                                     
   Font7 := GetFontHandle( "Font_7" )

   SET MENUSTYLE EXTENDED     // switch the menu style to advanced
   SetMenuBitmapHeight( 18 )  // set icon size 18x18

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  'SUPERHEADER on  '  ACTION nTsbSH := 1 FONT Font1
       MENUITEM  'SUPERHEADER off '  ACTION nTsbSH := 2 FONT Font1
       SEPARATOR                          
       MENUITEM  'HEADER on       '  ACTION nTsbH  := 1 FONT Font1
       MENUITEM  'HEADER off      '  ACTION nTsbH  := 2 FONT Font1
       SEPARATOR                          
       MENUITEM  'FOOTING on      '  ACTION nTsbF  := 1 FONT Font1
       MENUITEM  'FOOTING off     '  ACTION nTsbF  := 2 FONT Font1
       SEPARATOR                          
       MENUITEM  'MULTILINE on    '  ACTION nTsbML := 1 FONT Font1
       MENUITEM  'MULTILINE off   '  ACTION nTsbML := 2 FONT Font1
       SEPARATOR                         
       MENUITEM  "Exit"              ACTION Nil         FONT Font7 
   END MENU

   _ShowContextMenu(cForm, nY, nX) // displaying the menu
   InkeyGui(10)

   DEFINE CONTEXT MENU OF &cForm  // deleting menu after exiting 
   END MENU

   SET MENUSTYLE STANDARD  // MANDATORY! Return to the standard menu style!

   IF nTsbSH > 0 .OR. nTsbML > 0  .OR. nTsbH > 0  .OR. nTsbF > 0 

      test.Hide
      WaitWindow( 'Restart the program ...', .T. )   // open the wait window
      INKEYGUI(3)

      IF nTsbSH == 1
        aParam[1] := .T.
      ELSEIF nTsbSH == 2
        aParam[1] := .F.
      ELSE
        aParam[1] := lTsbSH
      ENDIF

      IF nTsbH == 1
        aParam[2] := .T.
      ELSEIF nTsbH == 2
        aParam[2] := .F.
      ELSE
        aParam[2] := lTsbH
      ENDIF

      IF nTsbF == 1
        aParam[3] := .T.
      ELSEIF nTsbF == 2
        aParam[3] := .F.
      ELSE
        aParam[3] := lTsbF
      ENDIF

      IF nTsbML == 1
        aParam[4] := .T.
      ELSEIF nTsbML == 2
        aParam[4] := .F.
      ELSE
        aParam[4] := lTsbML
      ENDIF

      cParam := '"' + HB_ValToExp(aParam) + '"'
      ? "  ."
      ? "  ShellExecute( , 'open', '" + Application.ExeName + "' , " + cParam + " , 3 )"
      ? "  ."
      ShellExecute( , 'open', Application.ExeName, cParam, , 2 )
      //INKEYGUI(2)

      ReleaseAllWindows()  // закрыть программу

   ENDIF 
 
   oBrw:SetFocus()
   DO EVENTS

   RETURN NIL

* ======================================================================
FUNCTION TableColor(oBrw)   
   LOCAL Font1, Font2, Font3, Font7, nY, nX
   LOCAL nTsbColor := oBrw:Cargo  // текущий цвет из oBrw:Cargo
   LOCAL cForm   := oBrw:cParentWnd

   nY := GetProperty(ThisWindow.Name,This.Name,"Row") + GetProperty(ThisWindow.Name,This.Name,"Height")
   nX := GetProperty(ThisWindow.Name,This.Name,"Col")
   nY += GetProperty(cForm, "Row") + GetTitleHeight() + 2
   nX += GetProperty(cForm, "Col") + GetBorderWidth() - 4         
   
   Font1 := GetFontHandle( "Font_1" )
   Font2 := GetFontHandle( "Font_6" )
   Font3 := GetFontHandle( "Font_3" )                                     
   Font7 := GetFontHandle( "Font_7" )

   SET MENUSTYLE EXTENDED     // switch the menu style to advanced
   SetMenuBitmapHeight( 18 )  // set icon size 18x18

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  'color table white         '       ACTION nTsbColor := 1 FONT Font1
       MENUITEM  'color table gray          '       ACTION nTsbColor := 2 FONT Font1
       MENUITEM  'color of the table "ruler"'       ACTION nTsbColor := 3 FONT Font1
       MENUITEM  'color of the table "columns"'     ACTION nTsbColor := 4 FONT Font1
       MENUITEM  'color of the table "chess"'       ACTION nTsbColor := 5 FONT Font1
       MENUITEM  'color of the table "multicolor"'  ACTION nTsbColor := 6 FONT Font1
       SEPARATOR                             
       MENUITEM  "Export Color to file"          ACTION ToColorFile(oBrw) FONT Font3 
       SEPARATOR                             
       MENUITEM  "Exit"                          ACTION Nil               FONT Font7 
   END MENU

   _ShowContextMenu(cForm, nY, nX) // displaying the menu
   InkeyGui(10)

   DEFINE CONTEXT MENU OF &cForm  // deleting menu after exiting 
   END MENU

   SET MENUSTYLE STANDARD  // MANDATORY! Return to the standard menu style!

   IF nTsbColor # oBrw:Cargo          // менялся ли цвет в меню 
      oBrw:Cargo := nTsbColor         // сохранили новую установку цвета 
      oBrw:Display() 
      oBrw:Refresh(.T.)               // перечитывает данные в таблице 
   ENDIF 
 
   oBrw:SetFocus()
   DO EVENTS

   RETURN NIL

* ======================================================================
FUNCTION TableExport(oBrw)   
   LOCAL Font1, Font2, Font3, Font7, nY, nX
   LOCAL cForm := oBrw:cParentWnd
   LOCAL nTsbColor := oBrw:Cargo  // текущий цвет из oBrw:Cargo

   nY := GetProperty(ThisWindow.Name,This.Name,"Row") + GetProperty(ThisWindow.Name,This.Name,"Height")
   nX := GetProperty(ThisWindow.Name,This.Name,"Col")
   nY += GetProperty(cForm, "Row") + GetTitleHeight() + 2
   nX += GetProperty(cForm, "Col") + GetBorderWidth() - 4         
   
   Font1 := GetFontHandle( "Font_1" )
   Font2 := GetFontHandle( "Font_6" )
   Font3 := GetFontHandle( "Font_3" )
   Font7 := GetFontHandle( "Font_7" )

   SET MENUSTYLE EXTENDED     // switch the menu style to advanced
   SetMenuBitmapHeight( 18 )  // set icon size 18x18

   DEFINE CONTEXT MENU OF &cForm
       MENUITEM  "Export to Excel (xls-files)"       ACTION ToExcel1(oBrw)    FONT Font3 
       SEPARATOR                             
       MENUITEM  "Export to Ole-Excel 1 (xls-files)" ACTION ToExcel2(oBrw,1)  FONT Font3 
       MENUITEM  "Export to Ole-Excel 2 (xls-files)" ACTION ToExcel2(oBrw,2)  FONT Font3 
       SEPARATOR                             
       MENUITEM  "Export to Excel (xml-files)"       ACTION ToExcel3(oBrw)    FONT Font3 
       SEPARATOR                                                              
       MENUITEM  "Export to Ole-Word 1 (doc-files)"  ACTION ToWinWord(oBrw,1) FONT Font3 
       MENUITEM  "Export to Ole-Word 2 (doc-files)"  ACTION ToWinWord(oBrw,2) FONT Font3 
       SEPARATOR                                                              
       MENUITEM  "Export to Dbf-files"               ACTION ToDbf(oBrw)       FONT Font3 
       SEPARATOR                                                              
       MENUITEM  "Exit"                              ACTION Nil               FONT Font7 
   END MENU

   _ShowContextMenu(cForm, nY, nX, .F. ) // displaying the menu
   InkeyGui(10)

   DEFINE CONTEXT MENU OF &cForm  // deleting menu after exiting 
   END MENU

   SET MENUSTYLE STANDARD  // MANDATORY! Return to the standard menu style!

   oBrw:SetFocus()
   DO EVENTS

   RETURN NIL

* ======================================================================
FUNCTION _ShowContextMenu(ParentFormName, nRow, nCol, lCentered)
   LOCAL xContextMenuParentHandle
   LOCAL aRow := GetCursorPos()
   DEFAULT lCentered := nRow == NIL .and. nCol == NIL
   DEFAULT nRow := 0, nCol := 0, ParentFormName := ""

   If .Not. _IsWindowDefined (ParentFormName)
      xContextMenuParentHandle := _HMG_xContextMenuParentHandle
   else
      xContextMenuParentHandle := GetFormHandle ( ParentFormName )
   Endif
   if xContextMenuParentHandle == 0
      MsgMiniGuiError("Context Menu is not defined. Program terminated")
   endif
   IF lCentered
   ELSEIF nRow == 0 .and. nCol == 0
      nCol := aRow[2]
      nRow := aRow[1]
   ENDIF

   TrackPopupMenu ( _HMG_xContextMenuHandle , nCol , nRow , xContextMenuParentHandle )

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToExcel1(oBrw)  
   LOCAL hFont, aFont, cFontName, cTitle, aTitle, nCol
   LOCAL aOld1 := array(oBrw:nColCount()) 
   LOCAL aOld2 := array(oBrw:nColCount()) 
   LOCAL aOld3 := array(oBrw:nColCount()) 
   LOCAL nFSize, cXlsFile, lActivate, hProgress, lSave 
   LOCAL bPrintRow, cMaska, cPath, hFontTitle, nTime

   // Внимание ! Выгружать больше 65533 строк в Excel НЕЛЬЗЯ ! Ограничение Excel.
   // Attention ! Upload more than 65533 rows in Excel is NOT possible ! Excel Restriction.

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // Экспорт идёт с текущей позиции курсора
   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.  // блокировать область таблицы (Строки не отображаются)

   //hFont := oBrw:aColumns[ 1 ]:hFont        // взять фонт таблицы ячеек
   hFont := GetFontHandle( "Font_6" )         // указать свой фонт
   aFont := GetFontParam( hFont )
   nFSize := 12                               // указать свой размер фонта для Excel  
   cFontName := "Font_" + hb_ntos( _GetId() )  
   // загружаем фонт для экспорта в Excel
   _DefineFont( cFontName, aFont[1], nFSize, aFont[3], aFont[4] )  
  
   FOR nCol := 1 TO LEN( oBrw:aColumns )
      // запомнить фонт для восстановления
      aOld1[ nCol ] := oBrw:aColumns[ nCol ]:hFont      
      aOld2[ nCol ] := oBrw:aColumns[ nCol ]:hFontHead 
      aOld3[ nCol ] := oBrw:aColumns[ nCol ]:hFontFoot
      // установить новый фонт
      oBrw:aColumns[ nCol ]:hFont     := GetFontHandle( cFontName )  
      oBrw:aColumns[ nCol ]:hFontHead := GetFontHandle( cFontName )
      oBrw:aColumns[ nCol ]:hFontFoot := GetFontHandle( cFontName )
   NEXT

   // --------------------- дообработка -----------------------------
   //oBrw:aColumns[ 6 ]:cDataType := 'N' // не использовать шаблон для числовых полей,
   //oBrw:aColumns[ 6 ]:cPicture  := ''  // т.к. при экспорте в Excel поле будет пустое !!!       

   cTitle := "_" + Space(50) + "Example of exporting a table (TITLE OF THE TABLE)"
   hFontTitle := GetFontHandle( "Font_7" )  // указать свой фонт
   aTitle     := { cTitle, hFontTitle }     // титул со своим фонтом 

   cPath     := GetStartUpFolder() + "\"   // путь записи файла
   cMaska    := "Test1_Excel"              // шаблон файла
   cXlsFile   := cPath + cMaska + "_" + DTOC( DATE() ) + "-"
   cXlsFile   += CharRem( ":", TIME() ) + ".xls"

   lActivate := .T.                 // открыть Excel       
   hProgress := test.PBar_1.Handle  // хенд для ProgressBar
   lSave     := .T.                 // сохранить файл
   bPrintRow := nil   // блок кода на каждой строке, возвращает T/F - если .F. пропускает строку

   nTime := SECONDS()
   oBrw:Excel2( cXlsFile, lActivate, hProgress, aTitle, lSave, bPrintRow ) 
   TotalTimeExports("oBrw:Excel2()=", cXlsFile, SECONDS() - nTime )  

   _ReleaseFont( cFontName )  // удалить использованный фонт
  
   AEval(oBrw:aColumns, {|oc,nn| oc:hFont     := aOld1[ nn ] }) // восстановить фонт 
   AEval(oBrw:aColumns, {|oc,nn| oc:hFontHead := aOld2[ nn ] }) // восстановить фонт 
   AEval(oBrw:aColumns, {|oc,nn| oc:hFontFoot := aOld3[ nn ] }) // восстановить фонт 

   oBrw:lEnabled := .T.    // разблокировать область таблицы (Строки отображаются)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()            // close the wait window
   EndIf

   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToExcel2(oBrw,nView)  
   LOCAL hFont, aFont, cFontName, hFontTitle, cTitle, aTitle, cMsg
   LOCAL nFSize, cXlsFile, lActivate, hProgress, lSave, nTime 
   LOCAL bExternXls, aColSel, bPrintRow, cMaska, cPath, lTsbFont

   // Внимание ! Выгружать больше 65533 строк в Excel НЕЛЬЗЯ ! Ограничение Excel.
   // Attention ! Upload more than 65533 rows in Excel is NOT possible ! Excel Restriction.

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // Экспорт идёт с текущей позиции курсора
   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.  // блокировать область таблицы (Строки не отображаются)

   //hFont := oBrw:aColumns[ 1 ]:hFont        // взять фонт таблицы ячеек
   hFont := GetFontHandle( "Font_6" )         // указать свой фонт
   aFont := GetFontParam( hFont )
   nFSize := 14                               // указать свой размер фонта для вывода таблицы в Excel  
   cFontName := "Font_" + hb_ntos( _GetId() ) // загружаем новый размер фонта 
   _DefineFont( cFontName, aFont[1], nFSize, aFont[3], aFont[4] )  
   hFont := GetFontHandle( cFontName )        // указать свой фонт для вывода таблицы в Excel

   cTitle     := "_" + Space(20) + "Example of exporting a table (TITLE OF THE TABLE)"
   hFontTitle := GetFontHandle( "Font_7" )  // указать свой фонт
   aTitle     := { cTitle, hFontTitle }     // титул со своим фонтом 

   cPath      := GetStartUpFolder() + "\"   // путь записи файла
   cMaska     := "Test2_ExcelOle"           // шаблон файла
   cXlsFile   := cPath + cMaska + "_" + CharRepl( ".", DTOC( DATE() ), "_" ) + "-"
   cXlsFile   += CharRem( ":", TIME() )     //+ ".xls" - не надо

   lActivate  := .T.                        // открыть Excel
   hProgress  := test.PBar_1.Handle         // хенд для ProgressBar
   lSave      := .T.                        // сохранить файл

   IF nView == 1
      bExternXls := nil  // подключение внешнего блока для оформления oSheet и объект Tsbrowse
   ELSE
      lTsbFont   := .T.  // перенести фонты с таблицы на экспортный файл
      bExternXls := {|oSheet,oBrw| ExcelOleExtern(hProgress,lTsbFont,oSheet,oBrw) }   // Tsb2xlsOleExtern.prg
   ENDIF

   aColSel    := nil  // определяет по заданным колонкам (от длины массива) какие буквы для ячеек использовать
   bPrintRow  := nil  // блок кода на каждой строке, возвращает T/F - если .F. пропускает строку

   // Проверить имя файла на количества точек
   // В случае наличия нескольких точек в имени файла Excel может "отрезать" имя файла
   IF AtNum( ".", HB_FNameName( cXlsFile ) ) > 0 
      cMsg := 'Calling from: ' + ProcName(0) + '(' + hb_ntos( ProcLine(0) )  
      cMsg += ') --> ' + ProcFile(0) + ';;' 
      cMsg += 'Output File Name - "' + HB_FNameName( cXlsFile ) + '";' 
      cMsg += 'contains several signs dot !;'
      cMsg += 'Excel can "truncate" the file name !;;'
      cMsg := AtRepl( ";", cMsg, CRLF )
      MsgStop( cMsg , "Error" )
   ENDIF

   nTime := SECONDS()
   oBrw:ExcelOle( cXlsFile, lActivate, hProgress, aTitle, hFont, lSave, bExternXls, aColSel, bPrintRow )
   TotalTimeExports("oBrw:ExcelOle(" + HB_NtoS(nView) + ")=", cXlsFile, SECONDS() - nTime )  

   _ReleaseFont( cFontName )  // удалить использованный фонт
  
   oBrw:lEnabled := .T.    // разблокировать область таблицы (Строки отображаются)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()           // close the wait window
   EndIf

   oBrw:Display() 
   oBrw:Refresh(.T.)         // перечитывает данные в таблице 
   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToExcel3(oBrw)  
   LOCAL hFont, cTitle, aTitle, lActivate, hProgress
   LOCAL cPath, cMaska, cXlsFile, nTime

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // Экспорт идёт с текущей позиции курсора

   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.  // блокировать область таблицы (Строки не отображаются)

   hFont := GetFontHandle( "Font_7" )         // указать свой фонт
   cTitle := "_" + Space(50) + "Example of exporting a table (TITLE OF THE TABLE)"
   aTitle := { cTitle, hFont }  // титул со своим фонтом

   XmlSetDefault( oBrw )                      // параметры xml --> Tsb2xml.prg
   // Можно задать свой формат - значения по умолчанию переопределить
   oBrw:aColumns[6]:XML_Format := "00\:00\:00" 
   oBrw:aColumns[9]:XML_Format := "0.00_ ;[Red]\-0.00\ "   

   cPath     := GetStartUpFolder() + "\"   // путь записи файла
   cMaska    := "Test3_ExcelXML"           // шаблон файла
   cXlsFile  := cPath + cMaska + "_" + DTOC( DATE() ) + "-"
   cXlsFile  += CharRem( ":", TIME() ) + ".XML"
   lActivate := .T.                        // открыть Excel
   hProgress := test.PBar_1.Handle         // хенд для ProgressBar

   nTime := SECONDS()
   Brw2Xml(oBrw, cXlsFile, lActivate, hProgress, aTitle)  // Export to xml --> Tsb2xml.prg
   XmlReSetDefault( oBrw )                                // восстановить параметры  xml --> Tsb2xml.prg
   TotalTimeExports("Brw2Xml()=", cXlsFile, SECONDS() - nTime )  

   oBrw:lEnabled := .T.    // разблокировать область таблицы (Строки отображаются)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()            // close the wait window
   EndIf

   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToWinWord(oBrw,nView)  
   LOCAL hFont, aFont, cFontName, cTitle, aTitle, hFontTitle
   LOCAL nFSize, cDocFile, lActivate, hProgress, lSave, nTime
   LOCAL cMaska, cPath, bExternDoc, lTsbFont

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // Экспорт идёт с текущей позиции курсора
   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.  // блокировать область таблицы (Строки не отображаются)

   //hFont := oBrw:aColumns[ 1 ]:hFont        // взять фонт таблицы ячеек
   hFont := GetFontHandle( "Font_6" )         // указать свой фонт
   aFont := GetFontParam( hFont )
   nFSize := 14                               // указать свой размер фонта для WinWord
   cFontName := "Font_" + hb_ntos( _GetId() )  
   // загружаем фонт для экспорта в Excel
   _DefineFont( cFontName, aFont[1], nFSize, aFont[3], aFont[4] )  
   hFont := GetFontHandle( cFontName )        // указать для экспорта свой фонт
  
   cTitle     := "Example of exporting a table (TITLE OF THE TABLE)"
   hFontTitle := GetFontHandle( "Font_7" )  // указать свой фонт
   aTitle := { cTitle, hFontTitle }         // титул со своим фонтом

   cPath     := GetStartUpFolder() + "\"   // путь записи файла
   cMaska    := "Test4_WordOle"            // шаблон файла
   cDocFile  := cPath + cMaska + "_" + DTOC( DATE() ) + "-"
   cDocFile  += CharRem( ":", TIME() ) + ".doc"

   lActivate := .T.                  // открыть Excel
   hProgress := test.PBar_1.Handle   // хенд для ProgressBar
   lSave     := .T.                  // сохранить файл

   IF nView == 1
      bExternDoc := nil  // подключение внешнего блока для оформления oTbl и объект Tsbrowse
   ELSE
      lTsbFont   := .T.  // перенести фонты с таблицы на экспортный файл
      bExternDoc := {|oTbl,oBrw,oActive| WordOleExtern(hProgress,lTsbFont,oTbl,oBrw,oActive) } // Tsb2doc.prg
   ENDIF

   nTime := SECONDS()
   Brw2Doc(oBrw, cDocFile, lActivate, hProgress, aTitle, hFont, lSave, bExternDoc )
   TotalTimeExports("Brw2Doc("+ HB_NtoS(nView) +")=", cDocFile, SECONDS() - nTime )  

   _ReleaseFont( cFontName )  // удалить использованный фонт
  
   oBrw:lEnabled := .T.       // разблокировать область таблицы (Строки отображаются)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()           // close the wait window
   EndIf

   oBrw:Display() 
   oBrw:Refresh(.T.)         // перечитывает данные в таблице 
   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
STATIC FUNCTION ToDbf(oBrw)  
   LOCAL cDbfFile, lActivate, cMaska, cPath, hProgress, nTime

   oBrw:GoTop()
   oBrw:GoPos( oBrw:nRowPos, oBrw:nFreeze+1 )  // Экспорт идёт с текущей позиции курсора
   DO EVENTS

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow( 'Loading the report in EXCEL ...', .T. )   // open the wait window
   EndIf

   oBrw:lEnabled := .F.   // блокировать область таблицы (Строки не отображаются)

   cPath     := GetStartUpFolder()    // путь записи файла
   cMaska    := "\Test5_Dbf"          // шаблон файла
   cDbfFile  := cPath + cMaska + "_" + DTOC( DATE() ) + "-"
   cDbfFile  += CharRem( ":", TIME() ) + ".dbf"
   lActivate := .T.                 // открыть Dbf-файл
   hProgress := test.PBar_1.Handle  // хенд для ProgressBar

   nTime := SECONDS()
   Brw2Dbf(oBrw, cDbfFile, lActivate, hProgress, "DBFCDX", "RU1251" )       // Tsb2dbf.prg
   TotalTimeExports("Brw2Dbf()=", cDbfFile, SECONDS() - nTime )  

   oBrw:lEnabled := .T.    // разблокировать область таблицы (Строки отображаются)

   If oBrw:nLen > SHOW_WAIT_WINDOW_LINE
      WaitWindow()         // close the wait window
   EndIf

   oBrw:GoTop() 
   oBrw:Reset() 
   oBrw:Display()  
   oBrw:SetFocus()
   DO EVENTS

   RETURN Nil

* ======================================================================
FUNCTION ToColorFile(oBrw)   
   LOCAL nLine, nCol, nBackColor, aBackCell, aClr, aBColor, nColor
   LOCAL cFile := hb_defaultValue( _SetGetLogFile(), GetStartUpFolder() + "\_MsgLog.txt" )

   DELETEFILE(cFile)

   // выводим массив цвета фона суперхидера таблицы
   ? "Superheider table background color"
   If ! Empty( oBrw:aSuperHead )
      For nCol := 1 To Len( oBrw:aSuperHead )
         ? "  nCol=", nCol
         nColor := oBrw:aSuperhead[ nCol, 5 ]   // oBrw:nClrSpcHdBack
         ?? oBrw:aSuperhead[ nCol, 3 ] 
         If Valtype( nColor ) == "B" 
            nColor := Eval( oBrw:aSuperhead[ nCol, 5 ] )  
            If Valtype( nColor ) == "A"
               nColor := nColor[1]
            EndIf  
         EndIf  
         aBColor := { GetRed(nColor), GetGreen(nColor), GetBlue(nColor) } 
         ?? HB_ValToExp(aBColor)
      Next
   Endif
   // выводим массив цвета фона шапки таблицы
   ? "Background color of the table header"
   If AScan( oBrw:aColumns, { |o| o:cHeading != Nil  } ) > 0   
       For nCol := 1 TO Len( oBrw:aColumns )
          ? "  nCol=", nCol
          ?? oBrw:aColumns[ nCol ]:cHeading
          nColor := oBrw:aColumns[ nCol ]:nClrHeadBack
          If Valtype( nColor ) == "B" 
             nColor := Eval( oBrw:aColumns[ nCol ]:nClrHeadBack, nCol, oBrw ) 
             If Valtype( nColor ) == "A"
                nColor := nColor[1]
             EndIf  
          EndIf  
          aBColor := { GetRed(nColor), GetGreen(nColor), GetBlue(nColor) } 
          ?? HB_ValToExp(aBColor)
       Next
   Endif
   // создаём массив цвета фона ячеек для всех колонок таблицы
   aBackCell := {}
   ? "Cell background color for all columns and the entire table"
   For nLine := 1 TO oBrw:nLen
       aClr := {}
       ? "  nLine=", nLine 
       For nCol := 1 TO Len( oBrw:aColumns )
           nBackColor := oBrw:aColumns[ nCol ]:nClrBack  
           If Valtype( nBackColor ) == "B" 
              nBackColor := Eval( oBrw:aColumns[ nCol ]:nClrBack, oBrw:nAt, nCol, oBrw )
              //nBackColor := Eval( nBackColor, oBrw:nAt, nCol, oBrw ) 
           EndIf  
           AADD( aClr, nBackColor ) 
       Next
       ?? HB_ValToExp(aClr)
       AADD( aBackCell, aClr ) 
      oBrw:Skip(1)
   Next
   // выводим массив цвета фона подвала таблицы
   ? "Background color of the basement table"
   // как определить, что есть ПОДВАЛ таблицы - вот так правильно ?
   If AScan( oBrw:aColumns, { |o| o:cFooting != Nil  } ) > 0   
       For nCol := 1 TO Len( oBrw:aColumns )
          ? "  nCol=", nCol
          ?? oBrw:aColumns[ nCol ]:cFooting
          nColor := oBrw:aColumns[ nCol ]:nClrFootBack
          If Valtype( nColor ) == "B" 
             nColor := Eval( oBrw:aColumns[ nCol ]:nClrFootBack, nCol, oBrw ) 
             If Valtype( nColor ) == "A"
                nColor := nColor[1]
             EndIf  
          EndIf  
          aBColor := { GetRed(nColor), GetGreen(nColor), GetBlue(nColor) } 
          ?? HB_ValToExp(aBColor)
       Next
   Endif

   DO EVENTS

   ShellExecute( 0, "Open", cFile,,, 3 )

   oBrw:GoTop() 
   oBrw:Reset() 
   DO EVENTS 
   oBrw:Display()  
   oBrw:Refresh(.T.)               // перечитывает данные в таблице  
   oBrw:SetFocus() 
   DO EVENTS 

   RETURN NIL

* ======================================================================
FUNCTION TotalTimeExports( cMsg, cFile, nTime )   
   ? "=> " + cMsg + " " + cFile 
   ? "  Total time spent on exports - " + SECTOTIME(nTime )
   ? "  ."
   RETURN NIL

* ======================================================================
STATIC FUNCTION CreateDatos()
   LOCAL i, k := 250, aDatos, aHead, aSize := NIL, aFoot, aPict := NIL, aAlign := NIL, aName
   LOCAL aDim, hFont, n7Pict := 0, n7Len := 0, c7Str := "", nI := 1, nDom := 1, nIdom := 1
   LOCAL aDom := { "/2", "a", " CTP. 5", "/3", "c", " CTP. 1", "/5", "e", "/123", " CTP. 3" }

   If k > SHOW_WAIT_WINDOW_LINE
      SET WINDOW MAIN OFF
      WaitWindow( 'Create an array for work ...', .T. )   // open the wait window
   EndIf

   aDatos := Array( k )
   FOR i := 1 TO k

      aDim := {} 
      AADD( aDim,  hb_ntos(i)+'.'                          )     // 1  C
      AADD( aDim,  i % 2 == 0                              )     // 2  L
      AADD( aDim,  i                                       )     // 3  N
      AADD( aDim,  "Str"+ntoc( i ) + "_123"                )     // 4  C
      AADD( aDim,  Date() + i                              )     // 5  D
      AADD( aDim,  CharRem( ":", TIME())                   )     // 6  C
      AADD( aDim,  PadR( "Test line - " + ntoc( i ), 20 )  )     // 7  C
      AADD( aDim,  Round( ( 10000 -i ) * i / 3, 2 )        )     // 8  N
      AADD( aDim,  100.00 * i                              )     // 9  N
      AADD( aDim,  '0'                                     )     // 10 C
      //AADD( aDim,  i % 5 == 0                              )     // 11  L
      //AADD( aDim,  "Str"+ntoc( i ) + "_123"                )     // 12  C
      //AADD( aDim,  Date() + i                              )     // 13  D
      //AADD( aDim,  CharRem( ":", TIME())                   )     // 14  C
      //AADD( aDim,  PadR( "Test line - " + ntoc( i ), 20 )  )     // 15  C
      //AADD( aDim,  100.00 * i                              )     // 16  N
      //AADD( aDim,  "TXT"+ntoc( i ) + PADC("9",20,"9")      )     // 17  C
      //AADD( aDim,  "TXT"+ntoc( i ) + PADC("8",20,"8")      )     // 18  C
      //AADD( aDim,  "TXT"+ntoc( i ) + PADC("0",20,"0")      )     // 19  C

      aDatos[ i ] := aDim


      IF LEN(aDatos[i]) >= 9
         IF i % 10 == 0
            aDatos[i,9] :=  -1.00
         ELSEIF i % 11 == 0
            aDatos[i,9] :=  -100.00
         ELSEIF i % 15 == 0
            aDatos[i,9] :=  1500.00
         ENDIF
      ENDIF

      aDatos[i,3] := nI
      IF i % 3 == 0
         nI++
         IF nI > 10
            nI := 1
         ENDIF
      ENDIF

      aDatos[i,6] := CharRem( ":", SECTOTIME( SECONDS() - i*2 ) )  // столбец - время

      IF TSB_MULTILINE 
         aDatos[i,7] := aDatos[i,7] + CRLF + SPACE(5) + "string test - 2;0123456789" + CRLF + SPACE(5) + "string test - 3;0123456789"
      ENDIF
     
      IF LEN(aDatos[i]) >= 10  
         aDatos[i,10] :=  HB_NtoS(nDom)    // столбец - номера домов
         nDom++
         IF nDom > 100
            nDom := 1
         ENDIF
         IF i % 3 == 0
            aDatos[i,10] := aDatos[i,10] + aDom[nIdom] 
            nIdom++
            nIdom := IIF( nIdom > LEN(aDom) , 1 , nIdom )
         ELSEIF i % 5 == 0
            aDatos[i,10] := aDatos[i,10] + aDom[nIdom] 
            nIdom++
            nIdom := IIF( nIdom > LEN(aDom) , 1 , nIdom )
         ELSEIF i % 6 == 0
            aDatos[i,10] := aDatos[i,10] + aDom[nIdom] 
            nIdom++
            nIdom := IIF( nIdom > LEN(aDom) , 1 , nIdom )
         ENDIF
      ENDIF
      
   NEXT
   // подсчёт для 7-ой колонке
   IF TSB_MULTILINE 
      n7Len  := LEN( CRLF + SPACE(5) + "string test - 2;0123456789" )
      n7Pict := REPL("x",n7Len * 3 )
   ENDIF

   aHead  := AClone( aDatos[ 1 ] )
   AEval( aHead, {| x, n| x:=nil, aHead[ n ] := "Head_" + hb_ntos( n ) + IIF(TSB_MULTILINE, CRLF + "line-2" , "") } ) 
   aFoot  := Array( Len( aDatos[ 1 ] ) )
   AEval( aFoot, {| x, n| x:=nil, aFoot[ n ] := "Foot_" + hb_ntos( n ) + IIF(TSB_MULTILINE, CRLF + "line-2" , "") } )
   aName     := Array( Len( aDatos[ 1 ] ) )
   AEval( aName, {| x, n| x:=nil, aName[ n ] := "Name_" + hb_ntos( n ) } )

   aPict  := Array( Len( aDatos[ 1 ] ) )    // формат всех колонок
   aAlign := Array( Len( aDatos[ 1 ] ) )    // центровка всех колонок
   aSize  := Array( Len( aDatos[ 1 ] ) )    // ширина всех колонок
   aFill( aSize,  NIL )

   // только для 6 колонки
   hFont := GetFontHandle( "Font_1" )  
    aPict[ 6 ] := "@R 99:99:99" 
   aAlign[ 6 ] := DT_CENTER
    aSize[ 6 ] := GetTextWidth(0, "99099099", hFont) // ширина 

   IF LEN(aDatos[1]) >= 10  
      // только для 10 колонки
      aAlign[ 10 ] := DT_CENTER
   ENDIF

   IF TSB_MULTILINE 
      // только для 7 колонки
      hFont := GetFontHandle( "Font_2" )
      aPict[ 7 ] := n7Pict 
      c7Str := REPL("a", n7Len)
      aSize[ 7 ] := GetTextWidth(0, c7Str, hFont)
   ENDIF

   If k > SHOW_WAIT_WINDOW_LINE
      WaitWindow()            // close the wait window
      SET WINDOW MAIN ON
   EndIf
 
RETURN { aDatos, aHead, aSize, aFoot, aPict, aAlign, aName }
