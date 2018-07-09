/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2018 Sergej Kiselev <bilance@bilance.lv>
 * Copyright 2018 Verchenko Andrey <verchenkoag@gmail.com> Dmitrov, Moscow region
 *
*/
#include "minigui.ch"
#include "tsbrowse.ch"

#define PBM_SETPOS       1026
* ======================================================================
FUNCTION Brw2Dbf( oBrw, cFile, lActivate, hProgress, cVia, cCodePage ) 
   LOCAL a, b, c, i, k, l, m, n, x, u, w
   LOCAL nLine, nCol, xVal, nRec, lCreate, aStruct, cMsg, lNewArea
   LOCAL aFldName, aFldType, aFldLen, aFldDec, aFldPict, cType
   LOCAL nTotal, nEvery, cFileMsk, cFileNew, nStatus
   LOCAL cFilePath, cFileName, cFileExt, lRename, nI, cFileOld
   LOCAL bOldError, cAlias, uData, cField, cFileMemo

   DEFAULT cFile := GetStartUpFolder() + "\Test.dbf", lActivate := .T., hProgress := nil
   DEFAULT cVia  := "DBFCDX", cCodePage := "RU1251"

   // ѕровер€ем им€ файла на количество точек
   lRename := .F.
   cFilePath := HB_FNameDir( cFile )
   cFileName := HB_FNameName( cFile )
   cFileExt  := HB_FNameExt( cFile )
   nI := AtNum( ".", cFileName )
   IF nI > 0 
      lRename := .T.
      cFile := cFilePath + CharRepl( ".", cFileName, "-" ) + cFileExt
   ENDIF

   // ќпредел€ем структуру базы из бровса
   aFldName := {}
   aFldType := {}
   aFldPict := {}
   aFldLen  := {}

   AEVal(oBrw:aColumns, { |oc,nc| AAdd(aFldName, iif(empty(oc:cName), 'Fld_'+hb_ntos(nc), oc:cName )) } )
   AEVal(oBrw:aColumns, { |oc   | AAdd(aFldPict, iif(HB_ISCHAR(oc:cPicture), oc:cPicture, ''       )) } )
   
   w := GetTextWidth(Nil, 'a', oBrw:hFont)
   AEVal(oBrw:aColumns, {|oc| AAdd( aFldLen , int( oc:nWidth / w ) ), ;
                              AAdd( aFldPict, oc:cPicture ) })

   // создадим объекты контейнер дл€ каждой колонки
   a := array(Len( oBrw:aColumns ))              // объект контейнер Type
   x := array(Len( oBrw:aColumns ))              // объект контейнер Len
   u := array(Len( oBrw:aColumns ))              // объект контейнер Dec
   AEVal(a, {|xv,nv| xv := nv, a[ nv ] := oKeyData(), ;
                               x[ nv ] := oKeyData(), ;
                               u[ nv ] := oKeyData() })
   
   n := array(Len( oBrw:aColumns ))              // FieldName

   nRec := IIF(oBrw:nLen > 100, 100, oBrw:nLen )  // кол-во просматриваемых строк
                                                  // исходим, что этого достаточно
   For nLine := 1 TO nRec 
       For nCol := 1 TO Len( oBrw:aColumns )
           xVal := Eval(oBrw:aColumns[ nCol ]:bData)
           cType := Valtype(xVal)
           If cType == 'C' .and. CRLF $ xVal
              cType := 'M'
           EndIf
           n[ nCol ] := oBrw:aColumns[ nCol ]:cName
           a[ nCol ]:Sum(cType, 1)           // созд. уник.список типов в колонке
           If HB_ISNUMERIC(xVal)             // созд. уник.список длин в колонке
              x[ nCol ]:Sum(hb_ntos(Len(hb_ntos(xVal))), 1)   
           ElseIf HB_ISCHAR(xVal)
              x[ nCol ]:Sum(hb_ntos(Len(xVal)), 1)   
           Else
              x[ nCol ]:Sum('0', 1)   
           EndIf
           If HB_ISNUMERIC(xVal)             // созд. уник.список Dec в колонке
              xVal := hb_ntos(xVal)
              If ( i := At('.', xVal) ) > 0
                 u[ nCol ]:Sum(hb_ntos(Len(xVal) - i), 1)
              Else
                 u[ nCol ]:Sum('0', 1)
              EndIf
           Else
              u[ nCol ]:Sum('0', 1)
           EndIf   
       Next
       oBrw:Skip(1)
   Next

   c := {}
   For i := 1 To Len(a)
       // Type
       b := a[ i ]:Eval(.F.)        // массив {{value, key, index}, ...}
       If Len(b) == 1               // структура определена однозначно
          If b[1][2] == 'U'
             AAdd(c, 'C')
          Else
             AAdd(c, b[1][2])
          EndIf
       Else
          // исключаем тип U ( Nil ), если есть
          If ( k := ascan(b, {|av| av[2] == 'U' }) ) > 0
             hb_ADel(b, k, .T.)
          EndIf
          If     Len(b) == 0         // "U" => "C"
             AAdd(c, 'C')
          ElseIf Len(b) == 1         // структура определена однозначно
             If b[1][2] == 'U'
                AAdd(c, 'C')
             Else                    // несколько типов, делаем в dbf "C"
                AAdd(c, b[1][2])
             EndIf
          Else                       // несколько типов, делаем в dbf "C"
             AAdd(c, 'C')
          EndIf
       EndIf
   Next
   // обработка длин
   l := array(Len(a))
   AFill(l, 0)
   For i := 1 To Len(a)
       b := x[ i ]:Eval(.F.)        // массив {{value, key, index}, ...}
       If len(b) == 1
          l[ i ] := Val(b[1][2])    // key - длина строкой
       Else
          m := 0
          AEVal(b, {|ak| m := Max( m, Val(ak[2]) ) })
          l[ i ] := m
       EndIf
   Next

   aFldDec  := array(Len(c))
   For i := 1 To Len(c)
       aFldDec[ i ] := 0
       If     c[ i ] == 'D'
          aFldLen[ i ] := 8
          LOOP
       ElseIf c[ i ] == 'L'
          aFldLen[ i ] := 1
          LOOP
       ElseIf c[ i ] == 'N'
          b := aFldPict[ i ]
          If left(b, 2) == '@R'
             b := subs(b, 4)
          EndIf
          If ! empty(b)
             aFldLen[ i ] := len(b)
             If '.' $ b
                aFldDec[ i ] := aFldLen[ i ] - At('.', b)
             EndIf
          EndIf
          LOOP
       EndIf
       // тут обработка aFldPic
       b := aFldPict[ i ]
       If     empty(b)                   
       ElseIf left(b, 2) == '@K'
          b := subs(b, 4)
       ElseIf left(b, 2) == '@R'
          b := subs(b, 4)
       ElseIf left(b, 2) == '@S'
          b := subs(b, 4)
          If val(b) > 0
             b := repl('X', val(b))
          EndIf
       ElseIf left(b, 1) == '@'
       ElseIf '!' $ b
       EndIf                             
       If ! empty(b)
          aFldLen[ i ] := len(b)
       EndIf
   Next

   aStruct := {}
   For i := 1 To Len(c)              // результат в структуру dbf
       AAdd(aFldName, n[ i ])
       AAdd(aFldType, c[ i ])
       If c[ i ] == 'M'
          aFldLen[ i ] := 10
       EndIf
       //_LogFile(.T., i, aFldName[ i ], aFldType[ i ], aFldLen[ i ], aFldDec[ i ])
       AADD( aStruct, { aFldName[ i ], aFldType[ i ], aFldLen[ i ], aFldDec[ i ] } )
   Next
   
   bOldError := ERRORBLOCK( {|var| BREAK(var)} )  // ѕроста€ обработка ошибок открыти€ файлов
   BEGIN SEQUENCE
     lNewArea := .T.
     cAlias   := "TMP"
     DbCreate( cFile, aStruct, cVia, lNewArea, cAlias, , cCodePage )
     lCreate := .T.
   RECOVER
     cMsg := "Database - ;" + cFile + ";" 
     cMsg += "busy with another process !;;"
     cMsg := AtRepl( ";", cMsg, CRLF )
     MsgStop( cMsg , "Error" )
     lCreate := .F.
   END SEQUENCE
   ERRORBLOCK( bOldError )  // ¬озвратитьс€ к блоку обработки ошибок по умолчанию
   
   If hProgress != Nil
      nTotal := oBrw:nLen 
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * .02 ) ) // refresh hProgress every 2 %
   EndIf

   // переписываем данные из таблицы в dbf-файл
   IF lCreate

      Eval( oBrw:bGoTop )  // переход на начало таблицы

      SELECT TMP
      nLine := oBrw:nLen
      FOR i := 1 TO nLine
          
          APPEND BLANK
          For nCol := 1 To Len( oBrw:aColumns )
             uData  := Eval( oBrw:aColumns[ nCol ]:bData )
             cType  := aFldType[ nCol ]   // ValType( uData )
             cField := aFldName[ nCol ]
             
             IF uData == NIL
                cType := "U"
             ELSE
                TMP->&cField :=  uData 
             ENDIF
          Next

          If hProgress != Nil

             If i % nEvery == 0
                SendMessage(hProgress, PBM_SETPOS, i, 0)
             EndIf

          EndIf

          oBrw:Skip(1)

      NEXT

      TMP->(DbCloseArea())   // закрыть базу

      IF lRename 
         cFileOld := cFile
         cFile := cFilePath + cFileName + cFileExt  // исходное им€ файла
         nStatus := RENAMEFILE( cFileOld, cFile )
         IF nStatus # 0
            cMsg := "Database file - ;" + cFileOld + ";" 
            cMsg += "FAILURE OF ACCESS ( " + HB_NtoS(nStatus) + ") !;;"
            cMsg += "Renaming the file was skipped !;;"
            cMsg := AtRepl( ";", cMsg, CRLF )
            MsgStop( cMsg , "Error" )
         ENDIF
         IF cVia == "DBFCDX"
            cFileMsk := ".fpt"
         ELSE
            cFileMsk := ".dbt"
         ENDIF
         cFileMemo := HB_FNAMENAME( cFileOld ) + cFileMsk
         cFileNew  := cFilePath + cFileName + cFileMsk  // исходное им€ мемо-файла 
         IF FILE(cFileMemo)
            nStatus := RENAMEFILE( cFileMemo, cFileNew )
            IF nStatus # 0
               cMsg := "Database memo - ;" + cFileMemo + ";" 
               cMsg += "FAILURE OF ACCESS ( " + HB_NtoS(nStatus) + ") !;;"
               cMsg += "Renaming the file was skipped !;;"
               cMsg := AtRepl( ";", cMsg, CRLF )
               MsgStop( cMsg , "Error" )
            ENDIF
         ENDIF
      ENDIF

   ENDIF // конец записи данных из таблицы в dbf-файл

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, i, 0 )
      DoEvents()
   EndIf

   If lActivate
      ShellExecute( 0, "Open", cFile,,, 3 )
   EndIf

   If hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   EndIf

RETURN NIL
