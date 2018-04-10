*+--------------------------------------------------------------------
*+
*+ Source Module => DebugArray.PRG
*+
*+ This program is free sample for HMG; you can redistribute it and/or modify it
*+ It's a simple sample for inspect a array Mono or MultiDimensional
*+ When Debugging, inspect a array is very useful
*+ The procedure main is used for to prepare the arrays and for use the procedure for debug
*+ The procedure DebugArray() is the function totaly functional
*+ Please remember of insert the define of CRLF at begining of program.
*+ How to use:
*+ Compile DebugArray
*+ The software open a notepad window for to show the array's data
*+ For to use in your software:
*+ Copy the procedure DebugArray in your software
*+ recall this procedure as maked in main procedure.
*+ If you like to see a monodimensional array recall it as:
*+ DebugArray(Arr, .f., txt)
*+ where Arr is the name of array,
*+ and txt is a right part of name of file txt
*+
*+ If you like to see a multidimensional array recall it as:
*+ DebugArray( ArrMulti, .T., txt )
*+ where ArrMulti is the name of array.
*+ and txt is a right part of name of file txt
*+
*+ Functions: Procedure Main()
*+ Procedure DebugArray()
*+
*+ Eduardo Freni
*+
*+ Functions: Function ValueToText()
*+
*+ Revised by Grigory Filatov, 21/05/2009
*+--------------------------------------------------------------------

#include "Minigui.ch"
#define CRLF chr(13)+chr(10)

procedure Main

local Arr, ArrMulti
local nConta, Txt := "DebugArray.txt"

Arr := array( 10 ) //dim the array nonodimensional
ArrMulti := array( 10, 4 ) //dim the array MultiDimensional

for nConta = 1 to len( arr )
  Arr[ nConta ] := nConta //assign a number to fill the array with some value
next

for nConta = 1 to len( arr )
  ArrMulti[ nConta, 1 ] := nConta //assign a number for to fill the array
  ArrMulti[ nConta, 2 ] := date() + nConta //assign a date for second element of Sub Array
  ArrMulti[ nConta, 3 ] := time() //assign a time for thirt element of Sub Array
  ArrMulti[ nConta, 4 ] := "Paper " + str( nConta, 6 ) + " Col 4 "
next

DebugArray(Arr, .f., txt) //array monodimensional
DebugArray( ArrMulti, .T., txt ) //array multidimensional

return


procedure DebugArray( Arr, MultiDim, OutPut )

local temptext := ""
local I
local I0
local TempArr

if MultiDim
  Output := "Multi" + Output //Adapt the name of array
  TempArr := Arr[ 1 ]
  for i = 1 to len( Arr )
    for I0 = 1 to len( TempArr )
     if I0 = 1
        temptext += "Row " + str( I, 6 ) + ":"
     endif
     temptext += space( 1 ) + ValueToText( Arr[ I, I0 ] )
    next
    temptext += CRLF //change the line
  next
else
  Output := "Mono" + Output //Adapt the name of array
  for i = 1 to len( arr )
    temptext += "Row " + str( I, 6 ) + ":" + space( 1 ) + ValueToText( Arr[ I ] ) + CRLF
  next
endif

hb_memowrit( OutPut, temptext )
ShellExecute( 0, "open", "notepad.exe", OutPut,, 1 )

return


FUNCTION ValueToText( uValue )

   LOCAL cType := ValType( uValue )
   LOCAL cText

   DO CASE
   CASE cType == "C"
      cText := hb_StrToExp( uValue )

   CASE cType == "N"
      cText := hb_NToS( uValue )
      cText := iif( Len( cText ) == 1, ">" + cText, cText )

   CASE cType == "D"
      cText := DToS( uValue )
      cText := "0d" + iif( Empty( cText ), "00000000", cText )

   OTHERWISE
      cText := hb_ValToStr( uValue )
   ENDCASE

RETURN "[" + cType + "]>>>" + cText + "<<<"

*+ EOF: DebugArray.PRG
