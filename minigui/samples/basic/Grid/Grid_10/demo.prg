/*
* MiniGUI Virtual Column Grid Demo
* Author: Grigory Filatov
*/

#include "minigui.ch"

PROCEDURE Main

Local aRows [20] [6]

    DEFINE WINDOW Form_1 ;
        AT 0,0 ;
        WIDTH 640 ;
        HEIGHT 400 ;
        TITLE 'Virtual Column Grid Test' ;
        MAIN

        DEFINE MAIN MENU
            DEFINE POPUP 'File'
                MENUITEM 'Save Data'    ACTION SaveData( aRows )
                SEPARATOR
                MENUITEM 'Exit'        ACTION ThisWindow.Release
            END POPUP
            DEFINE POPUP 'Actions'
                MENUITEM 'Append Row'    ACTION AppendRow( aRows )
                MENUITEM 'Delete Row'    ACTION DeleteRow( aRows )
            END POPUP
        END MENU

    if file('data.ini')
        BEGIN INI FILE "data.ini"
            GET aRows SECTION "Data" ENTRY "Array"
        END INI
        aSort( aRows, , , {|x, y| x[1] < y[1]} )
    else
        aRows [1]    := {'01','Simpson','Homer',5,10,5*10}
        aRows [2]    := {'02','Mulder','Fox',24,32,24*32}
        aRows [3]    := {'03','Smart','Max',43,58,43*58}
        aRows [4]    := {'04','Grillo','Pepe',89,23,89*23}
        aRows [5]    := {'05','Kirk','James',34,73,34*73}
        aRows [6]    := {'06','Barriga','Carlos',39,54,39*54}
        aRows [7]    := {'07','Flanders','Ned',43,11,43*11}
        aRows [8]    := {'08','Smith','John',12,34,12*34}
        aRows [9]    := {'09','Pedemonti','Flavio',10,100,10*100}
        aRows [10]    := {'10','Gomez','Juan',58,32,58*32}
        aRows [11]    := {'11','Fernandez','Raul',32,43,32*43}
        aRows [12]    := {'12','Borges','Javier',26,30,26*30}
        aRows [13]    := {'13','Alvarez','Alberto',54,98,54*98}
        aRows [14]    := {'14','Gonzalez','Ambo',43,73,43*73}
        aRows [15]    := {'15','Batistuta','Gol',48,28,48*28}
        aRows [16]    := {'16','Vinazzi','Amigo',39,83,39*83}
        aRows [17]    := {'17','Pedemonti','Flavio',53,84,53*84}
        aRows [18]    := {'18','Samarbide','Armando',54,73,54*73}
        aRows [19]    := {'19','Pradon','Alejandra',12,45,12*45}
        aRows [20]    := {'20','Reyes','Monica',32,36,32*36}
    endif
        @ 10,10 GRID Grid_1 ;
            WIDTH 612 ;
            HEIGHT 330 ;
            HEADERS { 'Code', 'Last Name', 'First Name', 'Quantity', 'Price', 'Cost' } ;
            WIDTHS {60,100,100,80,80,100} ;
            VIRTUAL ;
            ITEMCOUNT Len(aRows) ;
            ON QUERYDATA QueryTest(aRows) ;
            CELLNAVIGATION ;
            VALUE 1 ;
      ON CHANGE EDITDATA(aRows) ;
            EDIT INPLACE { ;
                    {'TEXTBOX','CHARACTER', '999' } , ;
                    {'TEXTBOX','CHARACTER', } , ;
                    {'TEXTBOX','CHARACTER', } , ;
                    {'TEXTBOX','NUMERIC', '9,999' } , ;
                    {'TEXTBOX','NUMERIC', '999.99' } , ;
                    {'TEXTBOX','NUMERIC', '9,999,999.99' } ;
                    };
            COLUMNWHEN { ;
                    { || Empty ( This.CellValue ) } , ;
                    { || This.CellValue >= 'M' } , ;
                    { || This.CellValue >= 'C' } , ;
                    { || ! Empty ( This.CellValue ) }, ;
                    { || ! Empty ( This.CellValue ) }, ;
                    { || Empty ( This.CellValue ) } ;
                    } ;
            COLUMNVALID { { || SETVIRTUALITEM( aRows ) }, ;
                    { || SETVIRTUALITEM( aRows ) }, ;
                    { || SETVIRTUALITEM( aRows ) }, ;
                    { || SETVIRTUALITEM( aRows ) } , ;
                    { || SETVIRTUALITEM( aRows ) } , ;
                    } ;
            JUSTIFY { GRID_JTFY_LEFT,;
                GRID_JTFY_RIGHT,;
                GRID_JTFY_RIGHT,;
                GRID_JTFY_RIGHT,;
                GRID_JTFY_RIGHT,;
                GRID_JTFY_RIGHT }

    END WINDOW

    CENTER WINDOW Form_1

    ACTIVATE WINDOW Form_1

Return

Procedure QueryTest( aArr )

    This.QueryData := aArr [This.QueryRowIndex][This.QueryColIndex]

Return

Function SETVIRTUALITEM( aArr )
Local nVal := This.CellValue
Local nCol := This.CellColIndex
Local nRow := This.CellRowIndex
Local lRet := .T.

    aArr [nRow] [nCol] := nVal
    if nCol > 3
        aArr [nRow] [6] := aArr [nRow] [iif(nCol==5, 4, 5)] * nVal
    else
        lRet := !Empty(nVal)
    endif

RETURN lRet

Procedure SaveData( aArr )

    BEGIN INI FILE "data.ini"
        SET SECTION "Data" ENTRY "Array" To aArr
    END INI

Return

Procedure AppendRow( aArr )

    Aadd( aArr, {'','Reyes','Monica',1,1,1} )
    Form_1.Grid_1.ItemCount := Len(aArr)
    Form_1.Grid_1.Value := Len(aArr)

Return

Procedure DeleteRow( aArr )
Local nRow := Form_1.Grid_1.Value

    Adel( aArr, nRow[1] )
    Asize( aArr, Len(aArr)-1 )
    Form_1.Grid_1.ItemCount := Len(aArr)
    if nRow[1] > Len(aArr)
        Form_1.Grid_1.Value := Len(aArr)
    endif

Return


PROCEDURE EDITDATA(aArr)
Local nrow := Form_1.Grid_1.Value
Local ccode :=  aArr[nrow[1],1]
Local Lname :=  aArr[nrow[1]][2]
Local Fname :=  aArr[nrow[1]][3]
Local Quantity :=  aArr[nrow[1]][4]
Local Price :=  aArr[nrow[1]][5]
Local Cost :=  aArr[nrow[1]][6]


 DEFINE WINDOW Form_2;
        AT 0,0 ;
        WIDTH 440 ;
        HEIGHT 300 ;
        TITLE 'Virtual DATA' ;
        CHILD

            @040,020 LABEL Lsifra VALUE "Code:" WIDTH 65 HEIGHT 23 FONT "ARIAL" SIZE 09
              @040,200 TEXTBOX C_Code VALUE ccode HEIGHT 23 WIDTH 40 MAXLENGTH 2 ;
                         ON ENTER {|| Form_2.c_prezime.SetFocus  }
       
          @070,020 LABEL Lprez VALUE "Last Name:" WIDTH 75 HEIGHT 23 FONT "ARIAL" SIZE 09
              @070,200 TEXTBOX c_prezime VALUE Lname WIDTH 200 HEIGHT 23 MAXLENGTH 30;
                         FONT "ARIAL" SIZE 09 ON ENTER {|| Form_2.c_ime.SetFocus  }
         
          @100,020 LABEL Lime VALUE "First Name:" WIDTH 75 HEIGHT 23 FONT "ARIAL" SIZE 09
              @100,200 TEXTBOX c_ime VALUE Fname WIDTH 200 HEIGHT 23 MAXLENGTH 30;
                         FONT "ARIAL" SIZE 09 ON ENTER {|| Form_2.n_quant.SetFocus  }
         
          @130,020 LABEL Ltit VALUE "Quantity:" WIDTH 75 HEIGHT 23 FONT "ARIAL" SIZE 09
              @130,200 TEXTBOX n_quant VALUE Quantity HEIGHT 23 WIDTH 80 Numeric INPUTMASK '9,999' ;
                         ON ENTER {|| Form_2.n_Price.SetFocus  }
  
          @160,020 LABEL Lfunk VALUE "Price:" WIDTH 75 HEIGHT 23 FONT "ARIAL" SIZE 09
              @160,200 TEXTBOX n_Price VALUE Price HEIGHT 23 WIDTH 80 Numeric INPUTMASK '999.99';
                   ON ENTER {|| Form_2.N_Cost.SetFocus  }
 
          @190,020 LABEL Loca VALUE "Cost:" WIDTH 75 HEIGHT 23 FONT "ARIAL" SIZE 09
              @190,200 TEXTBOX N_Cost VALUE Cost HEIGHT 23 WIDTH 80 Numeric INPUTMASK '9,999,999.99';
                   ON ENTER {|| NIL  }

    END WINDOW

    CENTER WINDOW Form_2

    ACTIVATE WINDOW Form_2


RETURN