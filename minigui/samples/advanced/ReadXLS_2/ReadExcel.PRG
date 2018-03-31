
ANNOUNCE RDDSYS

#define _HMG_OUTLOG

#include "hmg.ch"
 
#define adOpenForwardOnly  0
#define adOpenKeyset       1
#define adOpenDynamic      2
#define adOpenStatic       3
#DEFINE pNULL           ""
#DEFINE pON             .T.
#DEFINE pOFF            .F.
#DEFINE pMEMO           "M"
#DEFINE pDATE           "D"
#DEFINE pLOGICAL        "L"
#DEFINE pNUMERIC        "N"
#DEFINE pCHARACTER      "C"
#DEFINE pARRAY          "A"
#DEFINE pUNDEFINED      "U"
#DEFINE pNON_EXPRESSION "UE"

#ifndef __XHARBOUR__
   #xcommand TRY              => bError := ErrorBlock( {|oErr| break( oErr ) } ) ;;
                                 BEGIN SEQUENCE
   #xcommand CATCH [<!oErr!>] => ErrorBlock( bError ) ;;
                                 RECOVER [USING <oErr> ] <-oErr->;;
                                 ErrorBlock( bError )
#endif

***************
FUNCTION MAIN()
***************

DEFINE WINDOW main_form ;
   MAIN ;
   AT 0,0 ;
   WIDTH  600 ;
   HEIGHT 350 ;
   TITLE 'Read Excel file and Convert to Text file' ;
   BACKCOLOR SILVER ;
   NOMAXIMIZE NOSIZE

   @ 10,10 LABEL Label_1 ;
      VALUE "Excel to convert to TXT " ;
      WIDTH 200 ;
      HEIGHT 35 ;
      FONT 'Arial' SIZE 09 ;
      BACKCOLOR SILVER

   @ 10,220 TEXTBOX TDOC ;
      TOOLTIP 'Filename'	;
      WIDTH 320 ;
      MAXLENGTH 80	;
      VALUE GetStartupFolder()+'\TTC034.xls' ;
      ON ENTER ReadExcel() ;
      BACKCOLOR SILVER	;
      FONTCOLOR BLUE BOLD ;
      ON GOTFOCUS  Main_form.TDOC.BackColor := WHITE ;
      ON LOSTFOCUS Main_form.TDOC.BackColor := SILVER 


   @ 40,10 LABEL Label_2 ;
      VALUE "From row (A1..ZZZZ9999)  " ;
      WIDTH 200 ;
      HEIGHT 35 ;
      FONT 'Arial' SIZE 09 ;
      BACKCOLOR SILVER 

   @ 40,220 TEXTBOX TROW ;
      TOOLTIP 'Row'	;
      WIDTH 320 ;
      MAXLENGTH 80	;
      VALUE 'A1' ;
      ON ENTER ReadExcel() ;
      BACKCOLOR SILVER	;
      FONTCOLOR BLUE BOLD ;
      ON GOTFOCUS  Main_form.TROW.BackColor := WHITE ;
      ON LOSTFOCUS Main_form.TROW.BackColor := SILVER 


   @ 70,10 LABEL Label_3 ;
      VALUE "From COL (A1..ZZZZ9999)  " ;
      WIDTH 200 ;
      HEIGHT 35 ;
      FONT 'Arial' SIZE 09 ;
      BACKCOLOR SILVER 

   @ 70,220 TEXTBOX TCOL ;
      TOOLTIP 'Row'	;
      WIDTH 320 ;
      MAXLENGTH 80	;
      VALUE 'N200' ;
      ON ENTER ReadExcel() ;
      BACKCOLOR SILVER	;
      FONTCOLOR BLUE BOLD ;
      ON GOTFOCUS  Main_form.TCOL.BackColor := WHITE ;
      ON LOSTFOCUS Main_form.TCOL.BackColor := SILVER 

   @ 100,10 LABEL Label_4 ;
      VALUE "Sheet " ;
      WIDTH 200 ;
      HEIGHT 35 ;
      FONT 'Arial' SIZE 09 ;
      BACKCOLOR SILVER 

   @ 100,220 TEXTBOX TSHT ;
      TOOLTIP 'Sheet'	;
      WIDTH 320 ;
      MAXLENGTH 80	;
      VALUE 'A501DE' ;
      ON ENTER ReadExcel() ;
      BACKCOLOR SILVER	;
      FONTCOLOR BLUE BOLD ;
      ON GOTFOCUS  Main_form.TSHT.BackColor := WHITE ;
      ON LOSTFOCUS Main_form.TSHT.BackColor := SILVER 

   @ 130,10 LABEL Label_5 ;
      VALUE "Header " ;
      WIDTH 200 ;
      HEIGHT 35 ;
      FONT 'Arial' SIZE 09 ;
      BACKCOLOR SILVER 

   @ 130,220 CHECKBOX CHDR;
      CAPTION '' ;
      WIDTH 140 ;
      VALUE .T.     ;
      BACKCOLOR SILVER	;
      FONT 'Arial' SIZE 12    
    
   @ 160,10 LABEL Label_6 ;
      VALUE "All col+rows " ;
      WIDTH 200 ;
      HEIGHT 35 ;
      FONT 'Arial' SIZE 09 ;
      BACKCOLOR SILVER 

   @ 160,220 CHECKBOX CALL;
      CAPTION '' ;
      WIDTH 140 ;
      VALUE .T.     ;
      BACKCOLOR SILVER	;
      FONT 'Arial' SIZE 12    

   @ 190,10 LABEL Label_7 ;
      VALUE "Stop reading when an empty row is encountered " ;
      WIDTH 200 ;
      HEIGHT 35 ;
      FONT 'Arial' SIZE 09 ;
      BACKCOLOR SILVER 

   @ 190,220 CHECKBOX CSTP;
      CAPTION '' ;
      WIDTH 140 ;
      VALUE .F.     ;
      BACKCOLOR SILVER	;
      FONT 'Arial' SIZE 12    


   @ 240,10 BUTTON Start ;
      CAPTION '&Start ' ;
      ACTION ReadExcel()

END WINDOW 

Main_form.center
Main_form.activate

Return NIL


********************
Function ReadExcel() 
********************
//This function reads data from an Excel sheet without using MS-Office

LOCAL arrData, arrLEN, i, j
LOCAL objExcel, objRS, objRS1, oError
LOCAL strHeader, strRange, cOUT
LOCAL myXlsFile  := Main_form.TDOC.Value    
LOCAL my1stCell  := Main_form.TROW.Value    
LOCAL myLastCell := Main_form.TCOL.Value    
LOCAL mySheet    := Main_form.TSHT.Value
LOCAL blnHeader  := Main_form.CHDR.Value
LOCAL bALL       := Main_form.CALL.Value
LOCAL bSTP       := Main_form.CSTP.Value


Main_form.Start.enabled := .F.
InkeyGUI()

//Define header parameter string for Excel object
If blnHeader 
   strHeader := "HDR=YES;"
Else
   strHeader := "HDR=NO;"
EndIf

SET LOGFILE TO "output.txt"


objExcel := TOleauto():New('ADODB.Connection')
objExcel:ConnectionString ='Provider=Microsoft.ACE.OLEDB.12.0;' + ;
                     'Data Source=' + myXlsFile + ';' + ;
                     'Extended Properties="Excel 12.0 Xml;' + strHeader + 'IMEX=1' + '";' 

TRY
   objExcel:Open()
CATCH oError
   MsgStop("Operation: " + oError:Operation + " - Description: " + oError:Description, "Error")
   RETURN arrData
END


//Open a recordset object for the sheet and range
objRS  := TOleAuto():New('ADODB.Recordset')
objRS1 := TOleAuto():New('ADODB.Recordset')

IF bALL
   strRange = mySheet + '$' // ALL
ELSE
   strRange = mySheet + "$" + my1stCell + ":" + myLastCell
ENDIF


objRS1:Open ("Select count(*) from [" + strRange + "]", objExcel, adOpenStatic)
DO WHILE .NOT. objRS1:EOF()
   ? '# records', PADR(objRS1:Fields(0):Value(), 80, ' ')
   objRS1:MoveNext()
ENDDO
objRS1:Close()


objRS:Open ("Select * from [" + strRange + "]", objExcel, adOpenStatic)
? 'objRS:Fields:Count ',  objRS:Fields:Count


arrLEN := {}
FOR i = 1 TO objRS:Fields:Count
   AADD(arrLEN, { i, 0 } )
NEXT 

DO WHILE .NOT. objRS:EOF()
   FOR j = 0 To objRS:Fields:Count -1 
      IF EMPTY( objRS:Fields(j):Value )
      ELSE
         IF LEN(STRVALUE(objRS:Fields(j):Value())) > arrLEN [j+1] [2]
            arrLEN [j+1] [2] := LEN(STRVALUE(objRS:Fields(j):Value())) 
         ENDIF
      ENDIF
   Next
   objRS:MoveNext()
ENDDO

FOR I = 1 TO LEN(arrLEN)
   IF arrLEN [I] [2] > 0
      ? '#', arrLEN [I] [1], 'max column length:' , arrLEN [I] [2] 
   ENDIF
NEXT 
? '->'

//Read the data from the Excel sheet
arrData := {}
objRS:MoveFirst()  // go top

DO WHILE .NOT. objRS:EOF()

   //Stop reading when an empty row is encountered in the Excel sheet
   If EMPTY( objRS:Fields(0):Value ) .AND. bSTP
      EXIT
   ENDIF

   FOR j = 0 To objRS:Fields:Count -1 
      IF EMPTY(objRS:Fields(j):Value())
         cOUT := SPACE(arrLEN [j+1] [2] )
      ELSE
         cOUT := PADR(objRS:Fields(j):Value(), arrLEN [j+1] [2] , ' ')
      ENDIF

      aadd(arrData, cOUT)
      ?? cOUT
      
   Next
   ? '->'
   //Move to the next row
   objRS:MoveNext()

ENDDO

//Close the file and release the objects
objRS:Close()
objExcel:Close()

InkeyGUI(1000)
Main_form.Start.enabled := .T.

objRS:=NIL
objExcel:=NIL

ShowTxt ( MemoRead( "Output.txt" ) )

RETURN arrData


***************************
FUNCTION Strvalue( string )
***************************
LOCAL retval := pNULL

DO CASE
CASE VALTYPE( string ) == pCHARACTER
	retval := string

CASE VALTYPE( string ) == pNUMERIC
	retval := hb_ntos( string )

CASE VALTYPE( string ) == pMEMO
	retval := IF( (LEN(string) > (MEMORY(0) * 1024) * .80), ;
						SUBSTR(string,1, INT((MEMORY(0) * 1024) * .80)), ;
						string )

CASE VALTYPE( string ) == pDATE
	retval := DTOC( string )

CASE VALTYPE( STOD( string ) ) == pDATE
	retval := DTOC( STOD( string ) )

CASE VALTYPE( string ) == pLOGICAL
	retval := IF(string, "J", "N") 

OTHERWISE
	retval := ''

ENDCASE

RETURN( retval )


*-----------------------------------------------------------------------------*
PROCEDURE ShowTxt( cText )
*-----------------------------------------------------------------------------*

   DEFINE WINDOW Form_2 ;
	CLIENTAREA 800, 600 ;
	TITLE 'Show output' ;
	MODAL

	DEFINE EDITBOX Edit_1
		COL 10
		ROW 10
		WIDTH 780
		HEIGHT 580
		VALUE cText
		READONLY .T.
		HSCROLLBAR .F.
		FONTNAME "Courier New"
		FONTSIZE 12
	END EDITBOX

	ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   CENTER WINDOW Form_2
   ACTIVATE WINDOW Form_2

RETURN