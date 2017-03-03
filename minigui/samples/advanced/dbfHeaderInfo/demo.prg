/*
 * MiniGUI DBF Header Info Test
 * (c) 2010 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#include "dbstruct.ch"
#include "fileio.ch"


PROCEDURE Main()

	filltable ( 100 )

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 450 ;
		HEIGHT 450 ;
		TITLE 'DBF Header Info' ;
		MAIN

		DEFINE MAIN MENU

			DEFINE POPUP "Test"
				MENUITEM 'Get Header Info' ACTION ( aResult := GetHeaderInfo('test.dbf'),;
					aChoice( ,,,, aResult, "Header Info of TEST.DBF" ) )
				SEPARATOR
                                ITEM 'Exit' ACTION Form_1.Release()
			END POPUP

		END MENU

	END WINDOW 

	Form_1.Center()
	Form_1.Activate()

RETURN


PROCEDURE filltable ( nCount )
   LOCAL aDbf[11][4], i

   if !file('test.dbf')
        aDbf[1][ DBS_NAME ] := "First"
        aDbf[1][ DBS_TYPE ] := "Character"
        aDbf[1][ DBS_LEN ]  := 20
        aDbf[1][ DBS_DEC ]  := 0
        //
        aDbf[2][ DBS_NAME ] := "Last"
        aDbf[2][ DBS_TYPE ] := "Character"
        aDbf[2][ DBS_LEN ]  := 20
        aDbf[2][ DBS_DEC ]  := 0
        //
        aDbf[3][ DBS_NAME ] := "Street"
        aDbf[3][ DBS_TYPE ] := "Character"
        aDbf[3][ DBS_LEN ]  := 30
        aDbf[3][ DBS_DEC ]  := 0
        //
        aDbf[4][ DBS_NAME ] := "City"
        aDbf[4][ DBS_TYPE ] := "Character"
        aDbf[4][ DBS_LEN ]  := 30
        aDbf[4][ DBS_DEC ]  := 0
        //
        aDbf[5][ DBS_NAME ] := "State"
        aDbf[5][ DBS_TYPE ] := "Character"
        aDbf[5][ DBS_LEN ]  := 2
        aDbf[5][ DBS_DEC ]  := 0
        //
        aDbf[6][ DBS_NAME ] := "Zip"
        aDbf[6][ DBS_TYPE ] := "Character"
        aDbf[6][ DBS_LEN ]  := 10
        aDbf[6][ DBS_DEC ]  := 0
        //
        aDbf[7][ DBS_NAME ] := "Hiredate"
        aDbf[7][ DBS_TYPE ] := "Date"
        aDbf[7][ DBS_LEN ]  := 8
        aDbf[7][ DBS_DEC ]  := 0
        //
        aDbf[8][ DBS_NAME ] := "Married"
        aDbf[8][ DBS_TYPE ] := "Logical"
        aDbf[8][ DBS_LEN ]  := 1
        aDbf[8][ DBS_DEC ]  := 0
        //
        aDbf[9][ DBS_NAME ] := "Age"
        aDbf[9][ DBS_TYPE ] := "Numeric"
        aDbf[9][ DBS_LEN ]  := 2
        aDbf[9][ DBS_DEC ]  := 0
        //
        aDbf[10][ DBS_NAME ] := "Salary"
        aDbf[10][ DBS_TYPE ] := "Numeric"
        aDbf[10][ DBS_LEN ]  := 6
        aDbf[10][ DBS_DEC ]  := 0
        //
        aDbf[11][ DBS_NAME ] := "Notes"
        aDbf[11][ DBS_TYPE ] := "Character"
        aDbf[11][ DBS_LEN ]  := 70
        aDbf[11][ DBS_DEC ]  := 0

        DBCREATE("test", aDbf)
   endif

   use test
   zap

   for i := 1 to nCount
      append blank

      replace   first      with   'first'   + str(i)
      replace   last       with   'last'    + str(i)
      replace   street     with   'street'  + str(i)
      replace   city       with   'city'    + str(i)
      replace   state      with   chr( HB_RANDOMINT( 65,90 ) ) + chr( HB_RANDOMINT( 65,90 ) )
      replace   zip        with   alltrim( str( HB_RANDOMINT( 9999 ) ) )
      replace   hiredate   with   date() - 20000 + i
      replace   married    with   ( HB_RANDOMINT() == 1 )
      replace   age        with   HB_RANDOMINT( 99 )
      replace   salary     with   HB_RANDOMINT( 10000 )
      replace   notes      with   'notes' + str(i)
   next i

   use

RETURN


FUNCTION Achoice( t, l, b, r, aInput, cTitle, dummy, nValue )
	LOCAL aItems := {}

	DEFAULT cTitle TO "Please, select", nValue TO 1

	aEval( aInput, {|x| Aadd( aItems, x[2] + ": " + hb_ValToStr( x[1] ) ) } )

	DEFINE WINDOW Win_2 ;
		AT 0,0 ;
		WIDTH 400 HEIGHT 400 + IF(IsXPThemeActive(), 7, 0) ;
		TITLE cTitle ;
		ICON 'sqlite.ico' ;
		TOPMOST ;
		NOMAXIMIZE NOSIZE ;
		ON INIT Win_2.Button_1.SetFocus

		@ 335,190 BUTTON Button_1 ;
		CAPTION 'OK' ;
		ACTION {|| nValue := Win_2.List_1.Value, Win_2.Release } ;
		WIDTH 80

		@ 335,295 BUTTON Button_2 ;
		CAPTION 'Cancel' ;
		ACTION {|| nValue := 0, Win_2.Release } ;
		WIDTH 80

		@ 20,15 LISTBOX List_1 ;
		WIDTH 360 ;
		HEIGHT 300 ;
		ITEMS aItems ;
		VALUE nValue ;
		FONT "Ms Sans Serif" ;
		SIZE 12 ;
		ON DBLCLICK {|| nValue := Win_2.List_1.Value, Win_2.Release }

		ON KEY ESCAPE ACTION Win_2.Button_2.OnClick

	END WINDOW

	CENTER WINDOW Win_2
	ACTIVATE WINDOW Win_2

RETURN nValue


#define FIELD_ENTRY_SIZE 32
#define FIELD_NAME_SIZE  11

Function GetHeaderInfo(database)
Local aRet := {}
Local nHandle
Local dbfhead
Local h1,h2,h3,h4
Local dbftype
Local headrecs
Local headsize
Local recsize
Local nof
Local fieldlist
Local nfield
Local nPos
Local cFieldname
Local cType
Local cWidth,nWidth
Local nDec,cDec

if .not.'.DBF' $ upper(database)
    database+='.DBF'
endif
if ( nHandle := fopen( database, FO_READ ) ) == - 1
  msgstop('Can not open file '+upper(database)+' for reading!')
  return aRet
endif

dbfhead:=space(4)
fread( nHandle, @dbfhead, 4 )

h1:=FT_BYT2HEX(substr(dbfhead,1,1))   //must be 03h or F5h if .fpt exists
dbftype:=h1
h2:=FT_BYT2HEX(substr(dbfhead,2,1))   //yy hex (between 00h and FFh) added to 1900 (decimal)
h3:=FT_BYT2HEX(substr(dbfhead,3,1))   //mm hex (between 01h and 0Ch)
h4:=FT_BYT2HEX(substr(dbfhead,4,1))   //dd hex (between 01h and 1Fh)
if hex2dec(h3) > 12 .or. hex2dec(h4) > 31
   MsgInfo('Date damage in header!')
endif

aadd(aRet, {'0x'+dbftype, 'Type of file'})
aadd(aRet, {strzero(hex2dec(h4),2)+'.'+strzero(hex2dec(h3),2)+'.'+strzero(hex2dec(h2)-if(hex2dec(h2)>100,100,0),2), 'Last update (DD.MM.YY)'})

headrecs:=space(4) //number of records in file
fseek( nHandle, 4, FS_SET )
fread( nHandle, @headrecs, 4 )

h1:=FT_BYT2HEX(substr(headrecs,1,1))
h2:=FT_BYT2HEX(substr(headrecs,2,1))
h3:=FT_BYT2HEX(substr(headrecs,3,1))
h4:=FT_BYT2HEX(substr(headrecs,4,1))
headrecs:=int(hex2dec(h1)+256*hex2dec(h2)+(256**2)*hex2dec(h3)+(256**3)*hex2dec(h4))

aadd(aRet, {headrecs, 'Number of records'})

headsize:=space(2)
fread( nHandle, @headsize, 2 )

h1:=FT_BYT2HEX(substr(headsize,1,1))
h2:=FT_BYT2HEX(substr(headsize,2,1))
headsize:=hex2dec(h1)+256*hex2dec(h2) //header size

aadd(aRet, {headsize, 'Header size'})

recsize:=space(2)
fread( nHandle, @recsize, 2 )

h1:=FT_BYT2HEX(substr(recsize,1,1))
h2:=FT_BYT2HEX(substr(recsize,2,1))
recsize:=hex2dec(h1)+256*hex2dec(h2) //record size

aadd(aRet, {recsize, 'Record size'})

nof:=int(headsize/32)-1   // number of fields

aadd(aRet, {nof, 'Fields count'})

fieldlist:={}
for nField=1 to nof
    nPos := nField * FIELD_ENTRY_SIZE
    fseek( nHandle, nPos, FS_SET ) // Goto File Offset of the nField-th Field
    cFieldName:=space(FIELD_NAME_SIZE)
    fread( nHandle, @cFieldName, FIELD_NAME_SIZE )
    cFieldName:=strtran(cFieldName,chr(0),' ')
    cFieldName:=rtrim(substr(cFieldName,1,at(' ',cFieldName)))

    cType:=space(1)
    fread( nHandle, @cType, 1 )

    fseek( nHandle, 4, FS_RELATIVE )
    if ctype=='C'
       cWidth:=space(2)
       fread( nHandle, @cWidth, 2 )
       h1:=FT_BYT2HEX(substr(cWidth,1,1))
       h2:=FT_BYT2HEX(substr(cWidth,2,1))
       nWidth:=hex2dec(h1)+256*hex2dec(h2) // record size
       nDec:=0
    else
       cWidth:=space(1)
       fread( nHandle, @cWidth, 1 )
       nWidth:=hex2dec(FT_BYT2HEX(cWidth))
       cDec:=space(1)
       fread( nHandle, @cDec, 1 )
       nDec:=hex2dec(FT_BYT2HEX(cDec))
    endif
    aadd(fieldlist,{cFieldName,cType,nWidth,nDec})
next

fclose( nHandle )

aadd(aRet, {'', 'Fields structure'})
aeval(fieldlist,{|x,i| aadd(aRet, {x[1] + " - " + x[2] + "(" + hb_ntos(x[3]) + "," + hb_ntos(x[4]) + ")", hb_ntos(i)})})

RETURN aRet


#define HEXTABLE "0123456789ABCDEF"

FUNCTION HEX2DEC( cHexNum )
   local n, nDec := 0, nHexPower := 1

   for n := len( cHexNum ) to 1 step -1
      nDec += ( at( subs( upper(cHexNum), n, 1 ), HEXTABLE ) - 1 ) * nHexPower
      nHexPower *= 16
   next

RETURN nDec


FUNCTION FT_BYT2HEX(cByte,plusH)
  local xHexString

  default plusH := .f.

  if valtype(cByte) == "C"
     xHexString := substr( HEXTABLE, int(asc(cByte) / 16) + 1, 1 ) ;
                 + substr( HEXTABLE, int(asc(cByte) % 16) + 1, 1 ) ;
                 + iif(plusH, "h", '')
  endif

RETURN xHexString
