/*
 * MiniGUI USERTYPE Grid Demo
 * by Adam Lubszczyk
 * mailto:adam_l@poczta.onet.pl
*/

#include "minigui.ch"

PROCEDURE Main

LOCAL aRows:={;                // data for grid
         {"Text",	"Text", "Character Textbox"}     ,;
         {"Number",	3.1415, "Numeric mask 999.9999" },;
         {"Logical",	.F., "Yes/No"}                   ,;
         {"Date",	DATE(), "Date" }                 ,;
         {"Combo",	1, "Choice value"}               ,;
         {"Spin",	0, "Range from -20 to +20" }     ,;
         {"Font Name",	"Arial", "Font Face" }           ,;
         {"Font Size",	12, "In points" }                ,;
         {"Font Bold",	.T., "Use bold style"}           ,;
         {"Font CodePage",1, "Chars codepage"} }

LOCAL aEdit:={;           // types for 'DYNAMIC'
         { 'TEXTBOX','CHARACTER'}                  ,;
         { 'TEXTBOX','NUMERIC','999.9999'}         ,;
         { 'CHECKBOX' , 'Yes' , 'No' }             ,;
         { 'DATEPICKER', 'DROPDOWN'  }             ,;
         { 'COMBOBOX', {'One','Two','Three'}}      ,;
         { 'SPINNER' , -20 , 20 }                  ,;
         { 'TEXTBOX','CHARACTER'}                  ,;
         { 'SPINNER' , 1 , 20 }                    ,;
         { 'CHECKBOX' , 'True' , 'False' }         ,;
         { 'COMBOBOX', {'ANSI','OEM','DEFAULT','SYMBOL'} } }

LOCAL bBlock:={ |r,c| RetEditArr(aEdit, r, c) }

	SET CELLNAVIGATIONMODE VERTICAL

        DEFINE WINDOW Form_1 ;
                AT 0,0 ;
                WIDTH 640 ;
                HEIGHT 400 ;
                TITLE "Expanded Grid - DYNAMIC Type in INPLACE EDIT" ;
                MAIN

                @ 10,10 GRID Grid_1 ;
                WIDTH 620 ;
                HEIGHT 330 ;
                HEADERS {'Option (no editable)','Value (DYNAMIC)','Comment (TEXTBOX)'} ;
                WIDTHS {160,160,160} ;
                ITEMS aRows ;
                EDIT ;
                INPLACE { {}, { 'DYNAMIC', bBlock }, { 'DYNAMIC', bBlock } } ;
                COLUMNWHEN {{||.F.},{||.T.},{||.T.}} ;
		CELLNAVIGATION ;
		VALUE {1, 2}

		ON KEY ESCAPE ACTION ThisWindow.Release()

        END WINDOW

        CENTER WINDOW Form_1

        ACTIVATE WINDOW Form_1

RETURN

************************************
// Function used by codeblock from 'DYNAMIC' type
//    return normal array used in INPLACE EDIT
FUNCTION RetEditArr( aEdit, r, c )
LOCAL aRet

   IF c == 2 .AND. r >= 1 .AND. r <= LEN(aEdit)
      aRet:=aEdit[r]
   ELSE
     aRet:={"TEXTBOX","CHARACTER"}
   ENDIF

RETURN aRet
