/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Igor Nazarov
 *
*/
#include "hmg.ch"
#include "tsbrowse.ch"

#define PBM_SETPOS       1026

#require "hbxlsxml"

Static nCount := 0
* ======================================================================
FUNCTION XmlSetDefault( oBrw )
local nAlign := 0
local cType  := ''
local n := 0
local oCol

      for n := 1 TO Len(oBrw:aColumns)

          oCol := oBrw:aColumns[n]

          __objAddData  (oCol, 'XML_ColWidth'     )         
          oCol:XML_ColWidth   := oBrw:aColumns[n]:nWidth / 1.3

          __objAddData  (oCol, 'XML_ColFontName'  )
          if n == 1
	     oCol:XML_ColFontName := GetFontParam(GetFontHandle( "Font_7" ))[1]
	  else
	     oCol:XML_ColFontName := GetFontParam(GetFontHandle( "Font_6" ))[1]
	  end

          __objAddData  (oCol, 'XML_ColFontSize'  )
          oCol:XML_ColFontSize := 16

          __objAddData  (oCol, 'XML_ColFontBold'  )
          oCol:XML_ColFontBold := .F.

          __objAddData  (oCol, 'XML_HdrFontName'  )
	    oCol:XML_HdrFontName := GetFontParam( oCol:hFontHead )[1]

          __objAddData  (oCol, 'XML_HdrFontSize'  )
          oCol:XML_HdrFontSize := GetFontParam( oCol:hFontHead )[2]

          __objAddData  (oCol, 'XML_HdrFontBold'  )
          oCol:XML_HdrFontBold := .T.

          __objAddData  (oCol, 'XML_FootFontName'  )
	    oCol:XML_HdrFontName := GetFontParam( oCol:hFontHead )[1]

          __objAddData  (oCol, 'XML_FootFontSize'  )
          oCol:XML_HdrFontSize := GetFontParam( oCol:hFontHead )[2]

          __objAddData  (oCol, 'XML_FootFontBold'  )
          oCol:XML_HdrFontBold := .T.

          __objAddData  (oCol, 'XML_AlignV'       )
          oCol:XML_AlignV := 'Center'

          __objAddData  (oCol, 'XML_AlignH'       )
          nAlign := oCol:nAlign
          switch nAlign
             case DT_LEFT
               oCol:XML_AlignH := "Left"
               Exit
            case DT_CENTER
               oCol:XML_AlignH := "Center"
               Exit
            Case DT_RIGHT
               oCol:XML_AlignH := "Right"
               Exit
         End switch

          __objAddData  (oCol, 'XML_Format'       )
          cType := Valtype(Eval(oCol:bData))
          switch cType
             case 'D'
               oCol:XML_Format := "m/d/yyyy"
               Exit
             case 'N'
               oCol:XML_Format := "#,##0.00"
               Exit

         End switch

      end

Return nil

* ======================================================================
FUNCTION XmlResetDefault( oBrw )
local n , oCol

      for n := 1 TO Len(oBrw:aColumns)
          oCol := oBrw:aColumns[n]
          __objDelData  (oCol, 'XML_ColWidth'     )
          __objDelData  (oCol, 'XML_ColFontName'  )
          __objDelData  (oCol, 'XML_ColFontSize'  )
          __objDelData  (oCol, 'XML_ColFontBold'  )

          __objDelData  (oCol, 'XML_SHdrFontName'  )
          __objDelData  (oCol, 'XML_SHdrFontSize'  )
          __objDelData  (oCol, 'XML_SHdrFontBold'  )

          __objDelData  (oCol, 'XML_HdrFontName'  )
          __objDelData  (oCol, 'XML_HdrFontSize'  )
          __objDelData  (oCol, 'XML_HdrFontBold'  )

          __objDelData  (oCol, 'XML_FootFontName'  )
          __objDelData  (oCol, 'XML_FootFontSize'  )
          __objDelData  (oCol, 'XML_FootFontBold'  )

          __objDelData  (oCol, 'XML_AlignV'       )
          __objDelData  (oCol, 'XML_AlignH'       )
          __objDelData  (oCol, 'XML_Format'       )
      end

Return nil

* ======================================================================
FUNCTION Brw2Xml( oBrw, cFile, lActivate, hProgress, aTitle ) 
   LOCAL oXml, oSheet, oStyle
   LOCAL nLen, nLine
   LOCAL i, j, hFont
   LOCAL nRow  :=  0
   LOCAL nCol  :=  0
   LOCAL cStr := ""
   LOCAL nAlign  := 0
   LOCAL cAlign  := ''
   LOCAL cType  := ''
   LOCAL uData
   LOCAL nSkip  := 0
   LOCAL nRec := iif( oBrw:lIsDbf, ( oBrw:cAlias )->( RecNo() ), 0 )
   LOCAL nOldRow := oBrw:nLogicPos()
   LOCAL nOldCol := oBrw:nCell
   LOCAL lError   := .F.
   LOCAL aColors := {{0,0,""}}
   LOCAL nTotal, nEvery, nColor  := 0
   DEFAULT cFile := "Book.xml", lActivate := .T., hProgress := Nil

   nCount++  // static variable

   If hProgress != Nil
      nTotal := oBrw:nLen 
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * .02 ) ) // refresh hProgress every 2 %
   EndIf

   // Проверяем наличие файла для экспорта и возможность записи в него
   While lError
    lError := .F.
    if File( cFile )                        // Есть такой
        i := Fopen( cFile , 16 )
        if i >  0     // Файл не занят
          Fclose(i)
          lError := .F.
        else                                 // Файл занят
          lError := .T.
        end
        if lError
           cFile := hb_FnameName( cFile ) + '(' + hb_ntoc(nCount ++) + ')' + ".XML" // Переименовываем 
        end
     end
   End

   // Создаем объект XML
   oXml := ExcelWriterXML():New( cFile )
   oXml:setOverwriteFile( .T. )
   oXml:setCodePage( "RU1251" )

   // Определяем Лист
   oSheet := oXml:addSheet( "Sheet1" )

   // Определяем ширины колонок из бровса
   For i := 1 TO Len( oBrw:aColumns )
      oSheet:columnWidth(  i,  oBrw:aColumns[i]:XML_ColWidth )
   Next

   // Определяем стиль названия отчета
   oStyle := oXml:addStyle( "Title" )
   oStyle:alignHorizontal( "Left" )
   oStyle:alignVertical( "Center" )
   oStyle:SetfontName(   GetFontParam(aTitle[2])[1]  )
   oStyle:SetfontSize(   GetFontParam(aTitle[2])[2] )
   if  GetFontParam(aTitle[2])[3]
       oStyle:setFontBold()
   end

   // Определяем суперхидер
   For i := 1 To len( oBrw:aSuperHead )
     oStyle := oXml:addStyle( "SH" + hb_ntoc(i) )
          nAlign := oBrw:aSuperHead[i][12]
          switch nAlign
             case DT_LEFT
               cAlign := "Left"
               Exit
            case DT_CENTER
               cAlign := "Center"
               Exit
            Case DT_RIGHT
               cAlign := "Right"
               Exit
         End switch

     oStyle:alignHorizontal( cAlign )

          nAlign := oBrw:aSuperHead[i][13]
          switch nAlign
             case DT_LEFT
               cAlign := "Left"
               Exit
            case DT_CENTER
               cAlign := "Center"
               Exit
            Case DT_RIGHT
               cAlign := "Right"
               Exit
         End switch

     oStyle:alignVertical( cAlign )
     oStyle:SetfontName(   GetFontParam(oBrw:aSuperHead[i][7])[1]  )
     oStyle:SetfontSize(   GetFontParam(oBrw:aSuperHead[i][7])[2] )
     //oStyle:bgColor( '#' + NToC(oBrw:nClrSpcHdBack, 16) ) // Excel > 2003
     oStyle:bgColor( '#' + NToC(CLR_HGRAY, 16) )            // only Excel 2003
     if  GetFontParam(oBrw:aSuperHead[i][7])[3]
         oStyle:setFontBold()
     end
     oStyle:Border( "All", 2, "Automatic",  "Continuous" )
     oStyle:alignWraptext()
  end

  for i := 1 TO Len( oBrw:aColumns )
   
       // Определяем стили шапки колонок
       oStyle := oXml:addStyle( "H" + hb_ntoc(i) )
       oStyle:Border( "All", 2, "Automatic",  "Continuous" )
       oStyle:alignHorizontal( "Center" )
       oStyle:alignVertical( "Center" )
       //oStyle:bgColor( '#' + NToC(oBrw:nClrHeadBack, 16) )  // Excel > 2003
       oStyle:bgColor( '#' + NToC(CLR_HGRAY, 16) )            // only Excel 2003
       oStyle:alignWraptext()
       oStyle:SetfontName( oBrw:aColumns[i]:XML_HdrFontName  )
       oStyle:SetfontSize( oBrw:aColumns[i]:XML_HdrFontSize )
       if oBrw:aColumns[i]:XML_HdrFontBold
	  oStyle:setFontBold()
       end

       // Определяем стили колонок
       /*oStyle := oXml:addStyle( "S" + hb_ntoc(i) )
       oStyle:Border( "All", 1, "Automatic",  "Continuous" )
       oStyle:alignHorizontal( oBrw:aColumns[i]:XML_AlignH  )
       oStyle:alignVertical( oBrw:aColumns[i]:XML_AlignV  )
       oStyle:SetfontName( oBrw:aColumns[i]:XML_ColFontName )
       oStyle:SetfontSize( oBrw:aColumns[i]:XML_ColFontSize )
       //oStyle:bgColor( '#' + NToC( CLR_BLUE, 16) ) 
       if oBrw:aColumns[i]:XML_ColFontBold
	  oStyle:setFontBold()
       end
       oStyle:alignWraptext()

       if oBrw:aColumns[i]:XML_Format <> NIL
	  oStyle:setNumberFormat( oBrw:aColumns[i]:XML_Format )
       end*/

       // Определяем стили подвалов
       oStyle := oXml:addStyle( "F" + hb_ntoc(i) )
       oStyle:Border( "All", 2, "Automatic",  "Continuous" )
       oStyle:alignHorizontal( "Center" )
       oStyle:alignVertical( "Center" )
       // oStyle:bgColor( '#' + NToC(oBrw:nClrFootBack, 16) )  // Excel > 2003
       oStyle:bgColor( '#' + NToC(CLR_HGRAY, 16) )             // only Excel 2003

       oStyle:alignWraptext()
       oStyle:SetfontName( oBrw:aColumns[i]:XML_FootFontName  )
       oStyle:SetfontSize( oBrw:aColumns[i]:XML_FootFontSize )
       if oBrw:aColumns[i]:XML_HdrFontBold
	  oStyle:setFontBold()
       end

   end

   // Определяем используемые стили ячеек прогоном бровса
   Eval( oBrw:bGoTop )
   nLen   := oBrw:nLen
   nLine  := 1

   While  nLine <= nLen
      for nCol := 1  To Len(oBrw:aColumns)
          nColor := oBrw:aColumns[nCol]:nClrBack
          If hb_isBlock( nColor ) 
             nColor := Eval(nColor, oBrw:nAt, nCol, oBrw )
          end
          // в aColors храним массивы ( строка, столбец. стиль )
          Aadd( aColors, {nLine, nCol, "S" + hb_ntoc(nColor, 16)} )

          nAlign := oBrw:aColumns[nCol]:nAlign
          switch nAlign
            Case  DT_CENTER
                 cAlign := "Center"
                 Exit
            Case  DT_LEFT
                 cAlign := "Left"
                 Exit
            Case  DT_RIGHT
                 cAlign := "Right"
                 Exit
          end Switch

          oStyle := oXml:addStyle( "S" + hb_ntoc(nColor, 16) )
          oStyle:Border( "All", 1, "Automatic",  "Continuous" )
          oStyle:alignHorizontal( cAlign )
          oStyle:alignVertical( "Center" )
          //шрифт
          hFont := oBrw:aColumns[nCol]:hFont
          If hb_isBlock( hFont ) 
             hFont := Eval(hFont, oBrw:nAt, nCol, oBrw )
          end
	  oStyle:SetfontName(   GetFontParam(hFont)[1]  )
   	  oStyle:SetfontSize(   GetFontParam(hFont)[2] )
	  if  GetFontParam(hFont)[3]
            oStyle:setFontBold()
          end
          oStyle:bgColor( '#' + NToC(nColor, 16) ) 
          oStyle:alignWraptext()

      end

      If hProgress != Nil
         If nLine % nEvery == 0
            SendMessage(hProgress, PBM_SETPOS,nLine,0)
         EndIf
      EndIf

      nLine++
      nSkip := oBrw:Skip(1)
      SysRefresh()
      IF nSkip ==0
         EXIT
      ENDIF
   End

   // Пишем название отчета
   nRow := 1
   oSheet:writeString( nRow, 1, aTitle[1]  , "Title" )
   //oSheet:cellMerge(    nRow, 1, 4, 0 )

   nRow++
   nRow++
   // Пишем Суперхидер
   For i := 1 To Len( oBrw:aSuperHead )
     uData := AtRepl( Chr(13)+Chr(10), oBrw:aSuperHead[i][3], "&#10;" )
     oSheet:writeString( nRow,  oBrw:aSuperHead[i][1], uData , "SH" + hb_ntoc(i) )
     oSheet:cellHeight( nRow, 1, oBrw:nHeightSuper )
     oSheet:cellMerge(    nRow, oBrw:aSuperHead[i][1], oBrw:aSuperHead[i][2] - oBrw:aSuperHead[i][1], 0 )
   END
   // Пишем шапку бровса
   nRow ++
   For i := 1 To Len( oBrw:aColumns )
     uData := AtRepl( Chr(13)+Chr(10), oBrw:aColumns[i]:cHeading, "&#10;" )
     oSheet:writeString( nRow,  i, uData , "H" + hb_ntoc(i) )
   End

   oSheet:cellHeight( nRow, 1, oBrw:nHeightHead )

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

   // Пишем таблицу
   Eval( oBrw:bGoTop )

   nRow ++
   nLen   := oBrw:nLen
   nLine  := 1

   While  nLine <= nLen
      oSheet:cellHeight( nRow, 1, oBrw:nHeightCell / 1.3 )
      
      For nCol := 1 To Len( oBrw:aColumns )
         uData  := Eval( oBrw:aColumns[ nCol ]:bData )
         cType := ValType( uData )
         j := Ascan( aColors, {|e| e[1] == nLine .and. e[2] == nCol })

         switch cType
            Case "N"
               oSheet:writeNumber( nRow, nCol, uData, aColors[j][3] )
               //oSheet:writeNumber( nRow, nCol, uData, 'S' + hb_ntoc(nCol) )
               Exit
            Case "C"
	       uData := AtRepl( Chr(13)+Chr(10), uData, "&#10;" )
               oSheet:writeString( nRow, nCol, uData, aColors[j][3] )
               //oSheet:writeString( nRow, nCol, uData, 'S' + hb_ntoc(nCol))
               Exit
            Case "D"
                oSheet:writeDateTime( nRow, nCol, Dtoc(uData), aColors[j][3] )
                //oSheet:writeDateTime( nRow, nCol, Dtoc(uData), 'S' + hb_ntoc(nCol) )
                Exit
            Case "L"
                oSheet:writeString( nRow, nCol, IIF(uData, '.T.' , '.F.'), aColors[j][3] )
                //oSheet:writeString( nRow, nCol, IIF(uData, '.T.' , '.F.'), 'S' + hb_ntoc(nCol) )
                Exit
            Case "U"
               oSheet:writeString( nRow, nCol, '', aColors[j][3] )
               //oSheet:writeString( nRow, nCol, '', 'S' + hb_ntoc(nCol))
               Exit
            Case "T"
               oSheet:writeString( nRow, nCol, HB_TToC( uData), aColors[j][3] )
               //oSheet:writeString( nRow, nCol, HB_TToC( uData), 'S' + hb_ntoc(nCol))
               Exit

         End Switch

      Next

      If hProgress != Nil
         If nLine % nEvery == 0
            SendMessage(hProgress, PBM_SETPOS,nLine,0)
         EndIf
      EndIf

      oBrw:Skip(1)
      nLine++
      nRow++
      SysRefresh()
   End

   // Пишем подвал бровса
   For i := 1 To Len( oBrw:aColumns )
     uData := AtRepl( Chr(13)+Chr(10), oBrw:aColumns[i]:cFooting, "&#10;" )
     oSheet:writeString( nRow,  i, uData , "H" + hb_ntoc(i) )
   End

   oSheet:cellHeight( nRow, 1, oBrw:nHeightFoot )

   if oBrw:lIsDbf
      ( oBrw:cAlias )->( DbGoTo( nRec ) )
   else
      oBrw:GoPos(nOldRow, nOldCol)
   end

   oXml:writeData( cFile )

   If lActivate
      WaitWindow( 'Loading the report in EXCEL ...', .T. ) 
      ShellExecute( 0, "Open", cFile,,, 3 )
      INKEYGUI(800)
      WaitWindow()            // close the wait window
   EndIf

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

   oBrw:Display()

RETURN NIL