/*
 * MiniGUI Grid to Text Demo
 * (c) 2009 Pierpaolo Martinello <pier.martinello[at]alice.it>
*/

#include "minigui.ch"
#include "fileio.ch"

Function Main

Local aRows [40] [3]

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 ;
      HEIGHT 400 ;
      TITLE 'Grid to Text Test' ;
      MAIN

      DEFINE MAIN MENU
             DEFINE POPUP 'File'
                    ITEM "Grid to Txt" Action Grid2Txt( "Form_1", "Grid_1", "Test.txt", 10 )
                    SEPARATOR
                    ITEM "Exit" ACTION ThisWindow.Release()
             END POPUP
      END MENU

      aRows [1]   := {'Simpson','Homer','555-5555'}
      aRows [2]   := {'Mulder','Fox','324-6432'}
      aRows [3]   := {'Smart','Max','432-5892'}
      aRows [4]   := {'Grillo','Pepe','894-2332'}
      aRows [5]   := {'Kirk','James','346-9873'}
      aRows [6]   := {'Barriga','Carlos','394-9654'}
      aRows [7]   := {'Flanders','Ned','435-3211'}
      aRows [8]   := {'Smith','John','123-1234'}
      aRows [9]   := {'Pedemonti','Flavio','000-0000'}
      aRows [10]   := {'Gomez','Juan','583-4832'}

      aRows [11]   := {'Fernandez','Raul','321-4332'}
      aRows [12]   := {'Borges','Javier','326-9430'}
      aRows [13]   := {'Alvarez','Alberto','543-7898'}
      aRows [14]   := {'Gonzalez','Ambo','437-8473'}
      aRows [15]   := {'Batistuta','Gol','485-2843'}
      aRows [16]   := {'Vinazzi','Amigo','394-5983'}
      aRows [17]   := {'Pedemonti','Flavio','534-7984'}
      aRows [18]   := {'Samarbide','Armando','854-7873'}
      aRows [19]   := {'Pradon','Alejandra','???-????'}
      aRows [20]   := {'Reyes','Monica','432-5836'}

      aRows [21]   := {'Fernandez','Raul','321-4332'}
      aRows [22]   := {'Borges','Javier','326-9430'}
      aRows [23]   := {'Alvarez','Alberto','543-7898'}
      aRows [24]   := {'Gonzalez','Ambo','437-8473'}
      aRows [25]   := {'Batistuta','Gol','485-2843'}
      aRows [26]   := {'Vinazzi','Amigo','394-5983'}
      aRows [27]   := {'Pedemonti','Flavio','534-7984'}
      aRows [28]   := {'Samarbide','Armando','854-7873'}
      aRows [29]   := {'Pradon','Alejandra','???-????'}
      aRows [30]   := {'Reyes','Monica','432-5836'}

      aRows [31]   := {'Fernandez','Raul','321-4332'}
      aRows [32]   := {'Borges','Javier','326-9430'}
      aRows [33]   := {'Alvarez','Alberto','543-7898'}
      aRows [34]   := {'Gonzalez','Ambo','437-8473'}
      aRows [35]   := {'Batistuta','Gol','485-2843'}
      aRows [36]   := {'Vinazzi','Amigo','394-5983'}
      aRows [37]   := {'Pedemonti','Flavio','534-7984'}
      aRows [38]   := {'Samarbide','Armando','854-7873'}
      aRows [39]   := {'Pradon','Alejandra','???-????'}
      aRows [40]   := {'Reyes','Monica','432-5836'}

      @ 10,10 GRID Grid_1 ;
              WIDTH 500 ;
              HEIGHT 322 ;
              HEADERS {'Column 1','Column 2','Column 3'} ;
              WIDTHS {100,100,100} ;
              ITEMS aRows ;
              VALUE 1 ;
              EDIT ;
              INPLACE {} ;
              CELLNAVIGATION

   END WINDOW

   Form_1.Grid_1.Setfocus

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return Nil

*-----------------------------------------------------------------------------*
Function Grid2Txt( cParentForm , cControlName , cOutputFileName , nLen , sP )
*-----------------------------------------------------------------------------*
   Local i, nColIndex
   Local nOutfile, mLen := 0
   Local atemp := {}, Col, Row, aSc, StringList := ""
   Local ic := GetProperty ( cParentForm , cControlName , "ItemCount" )

   Default nLen := 0, Sp := " | "

   i := GetControlIndex ( cControlName , cParentForm )

   nColIndex := Len ( _HMG_aControlPageMap [i] )

   aSc := array(nColIndex)

   If nLen == 0

      * retrieve a max column length

      For Col = 1 to nColIndex

          For Row := 1 To iC

              mlen:= max ( mlen, len(_GetGridCellValue ( cControlName , cParentForm , Row , Col ) ) )

              asc[col] := mlen

          Next Row

          mlen := 0

      Next Col

    Else

      * adapt a colum's length to nLen Parameter

      For Col = 1 to nColIndex

          aSc[ col ] := nLen

      Next Col

    Endif

   * add a colum description Header

   For Col = 1 to nColIndex

       stringList += addspace( _HMG_aControlPageMap [ i ][ col ], aSc[ col ] )+ if( col < nColIndex, sp, CRLF )

   Next

   aadd( atemp, stringList )

   StringList := ''

   * add a colum's details

   For Row := 1 to ic

        For Col := 1 To nColIndex

            StringList += addspace(_GetGridCellValue ( cControlName , cParentForm , Row , Col ), aSc[ col ] ) ;
                       + if( col < nColIndex , sp, CRLF )

        Next Col

        aadd ( atemp, StringList )

        StringList := ''

   Next Row

   nOutfile := FCREATE( cOutputFileName , FC_NORMAL )

   For Row := 1 to len ( aTemp )

       FWRITE( nOutfile , aTemp [Row] )

   Next

   FCLOSE( nOutfile )

   If File( cOutputFileName )
      ShowTxt ( MemoRead( cOutputFileName ) )
   Else
      msgExclamation( "Error at creating " + cOutputFileName )
   Endif

Return Nil

*-----------------------------------------------------------------------------*
FUNCTION addspace(string,final_len)
*-----------------------------------------------------------------------------*
RETURN SUBST(string+REPL(' ',final_len-LEN(string)),1,final_len)

*-----------------------------------------------------------------------------*
Procedure ShowTxt( cText )
*-----------------------------------------------------------------------------*

  DEFINE WINDOW Form_2 ;
         AT 0,0 ;
         WIDTH 640 ;
         HEIGHT 400 ;
         TITLE 'List Grid to Text Demo' ;
         MODAL

        DEFINE EDITBOX Edit_1
               COL 10
               ROW 10
               WIDTH 610
               HEIGHT 330
               VALUE cText
               READONLY .T.
               HSCROLLBAR .F.
               FONTNAME "Courier New"
               FONTSIZE 10
        END EDITBOX

  END WINDOW

  CENTER WINDOW Form_2
  ACTIVATE WINDOW Form_2

Return
