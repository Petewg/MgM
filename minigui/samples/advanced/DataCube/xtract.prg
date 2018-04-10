#include <hmg.ch>

Set proc to grid2csv
Set proc to sampledata

memvar dbo
memvar cWindowName
memvar cGridName
memvar aOperations
memvar aOptions
memvar aCols
memvar aAvailcols
memvar aSelRows
memvar aSelCols
memvar aSelData
memvar aColors
memvar aWidths
memvar aFieldOptions

Function Main
local aData := {}
public dbo := nil
  
aData := initdata()  
define window s at 0,0 width 1024 height 768 title "Xtract Sample" main icon "cube"
   define grid data
      row 10
      col 10
      width 1000
      height 600
      items aData
      headers {"REGION","PRODUCT","SALESMAN","QUANTITY","DISCOUNT"}
      widths {150,150,150,150,150}
      justify {0,0,0,1,1}
   	COLUMNCONTROLS { {'TEXTBOX','CHARACTER'} , {'TEXTBOX','CHARACTER'} ,{'TEXTBOX','CHARACTER'},{'TEXTBOX','NUMERIC','999999'}  , {'TEXTBOX','NUMERIC','99'}} 
   end grid
   define button xtract
      row 620
      col 10
      width 80
      caption "Xtract"
      action dataxtract("s","data")
   end button
   define button csvexport
      row 620
      col 110
      width 80
      caption "Xport2CSV"
      action grid2csv("s","data",.t.)
   end button
   define button import
      row 620
      col 210
      width 80
      caption "DBF Import"
      action importfromdbf()
   end button
   define button close
      row 620
      col 310
      width 80
      caption "Close"
      action s.release()
   end button
end window
s.center
s.activate

Return nil


function dataxtract(cWindow,cGrid)
local aTypes := {}
local nItemCount := 0
local aLineData := {}
local i, j
local aEditControls := {}
local aJustify := {}
local aItem := {}
local aFilterValues := {}
local aFieldValues := {}
local nCount
private cWindowName := cWindow
private cGridName := cGrid
private aOperations := {"","SUM","MINIMUM","MAXIMUM","COUNT"}
private aOptions := {"","Row","Column","Data"}
private aCols := {}
private aAvailcols := {}
private aSelRows := {}
private aSelCols := {}
private aSelData := {}
private aColors := {{255,255,100},{255,100,255},{100,255,100}} // Row Color, Col Color and Data Color
private aWidths := {}
private aFieldOptions := {}



nItemCount := getproperty(cWindow,cGrid,"itemcount")
if nItemCount == 0
   return nil
endif
aLineData := getproperty(cWindow,cGrid,"item",1)
for nCount := 1 to len(aLineData)
   aadd(aCols,{getproperty(cWindow,cGrid,"header",nCount),1,1})
   aadd(aAvailCols,getproperty(cWindow,cGrid,"header",nCount))
   aadd(aTypes,valtype(aLineData[nCount]))
next nCount
i := GetControlIndex ( cGrid , cWindow )
aJustify := _HMG_aControlMiscData1 [i] [3]

WAIT WINDOW "Creating Data Environment - Please wait..." NOWAIT
exporttosql("s","data")
wait clear 


for i := 1 to len(aAvailCols)
   aadd(aWidths,120)
   asize(aFieldValues,0)
   aItem := sql(dbo,"select distinct "+alltrim(aAvailCols[i])+" from data order by "+aAvailCols[i])
   if len(aItem) > 0
      for j := 1 to len(aItem)
         aadd(aFieldvalues,aItem[j,1])
      next j
      asize(aFieldvalues,len(aFieldValues)+1)
      ains(aFieldValues,1)
      aFieldValues[1] := ''
      aadd(aFieldOptions,{'COMBOBOX',aclone(aFieldValues)})
   else
      aadd(aFieldOptions,{'COMBOBOX',{}})
   endif      
next i

asize(aFilterValues,len(aAvailCols))
afill(aFilterValues,1)


   
define window xtract at 0,0 width 790 height 630+iif(isappthemed(),8,0) icon "cube" title "Xtract Window" modal 

   define toolbar tool1 buttonsize 32,33
      button autocalc picture "cube2"  tooltip "Auto Calc On/Off (F2)" autosize check
      button calc picture "cube1" action createreport(.t.) tooltip "Refresh/Create Data Cube (F5)" autosize
      button print1 picture "print1" action cubeprint() tooltip "Print Data Cube (Ctrl+P)" autosize
      button close1 picture "close" action xtract.release() tooltip "Exit Data Cube (Esc)" autosize
   end toolbar

   define label available
      row 45
      col 10
      width 200
      fontsize 14
      fontbold .t.
      value "Xtract Cube Construction"
   end label
  
   define grid cols
      row 75
      col 10
      width 300
      height 150
      widths {110,80,80}
      headers {"Field Name","Placement","Operation"}
      cellnavigation .t.
      columncontrols {{'TEXTBOX','CHARACTER'},{'COMBOBOX',aOptions},{'COMBOBOX',aOperations}}
      columnwhen {{||.f.},{||.t.},{||checkdata()}}
      columnvalid {{||.t.},{||checkoperation()},{||checkdataoperation()}}
      allowedit .t.
      on change updateoptions()
   end grid
   define button up
      row 115
      col 315
      width 32
      height 36
      picture "up"
      action fieldup()
   end button
   define button down
      row 157
      col 315
      width 32
      height 36
      picture "down"
      action fielddown()
   end button
   
   define label skeleton
      row 45
      col 350
      width 200
      fontsize 14
      fontbold .t.
      value "Data Cube Skeleton"
   end label
   define grid options
      row 75
      col 350
      height 150
      width 430
      showheaders .f.
      widths {120}
      cellnavigation .t.
      on change updateoptions()
   end grid
   define label filterlabel
      row 225
      col 10
      width 150
      fontbold .t.
      fontsize 14
      value "Filters"
   end label
   define grid filters
      row 250
      col 10
      width 770
      height 60
      headers aAvailCols
      widths aWidths
      cellnavigation .t.
      allowedit .t.
      columncontrols aFieldOptions
      on change createreport(xtract.tool1.autocalc.value)
   end grid
   
   define label datacube
      row 310
      col 10
      width 150
      fontbold .t.
      fontsize 14
      value "Data Cube"
   end label
   
   define statusbar
      statusitem "Welcome"
   end statusbar
end window

on key F2 of xtract action iif(xtract.tool1.autocalc.value,xtract.tool1.autocalc.value := .f.,xtract.tool1.autocalc.value := .t.)
on key F5 of xtract action createreport(.t.)
on key ESCAPE of xtract action xtract.release()
on key CONTROL+P of xtract action cubeprint()


for i := 1 to len(aCols)
   xtract.cols.additem(aCols[i])
next i
if len(aCols) > 0
   xtract.cols.value := {1,2}
endif

xtract.tool1.autocalc.value := .f.

xtract.filters.additem(aFilterValues)
xtract.center
xtract.activate

return nil

function cubeprint
if .not. iscontroldefined(data,xtract)
   return nil
endif
if xtract.data.itemcount > 0   
   gridprint("data","xtract")
endif
return nil   

function checkdata
local aValue := xtract.cols.value
if aValue[1] > 0
   if xtract.cols.cell(aValue[1],2) == 4
      return .t.
   else
      return .f.
   endif
endif
return .f.

function checkoperation
local aValue := xtract.cols.value
if this.cellvalue == 4
   if xtract.cols.cell(aValue[1],3) == 1
      xtract.cols.cell(aValue[1],3) := 2
   endif
else
   xtract.cols.cell(aValue[1],3) := 1
endif
return .t.

function checkdataoperation
local aValue := xtract.cols.value
if this.cellvalue == 1
   if xtract.cols.cell(aValue[1],2) == 4
      return .f.
   endif
endif
return .t.

function fieldup
local aValue := xtract.cols.value
local aTemp := {}
if aValue[1] <= 1
   return nil
else
   aTemp := xtract.cols.item(aValue[1])
   xtract.cols.item(aValue[1]) := xtract.cols.item(aValue[1]-1)
   xtract.cols.item(aValue[1]-1) := aTemp
   xtract.cols.value := {aValue[1]-1,aValue[2]}
endif
updateoptions()
return nil


function fielddown
local aValue := xtract.cols.value
local aTemp := {}
if aValue[1] == xtract.cols.itemcount
   return nil
else
   aTemp := xtract.cols.item(aValue[1])
   xtract.cols.item(aValue[1]) := xtract.cols.item(aValue[1]+1)
   xtract.cols.item(aValue[1]+1) := aTemp
   xtract.cols.value := {aValue[1]+1,aValue[2]}
endif
updateoptions()

return nil



function updateoptions
local nCols := 0
local nRows := 0
local nData := 0
local nTotCols := 0
local nTotRows := 0
local aWidths := {}
local aBackColors := {}
local aItem := {}
local i, j
local nCurCol
local aOldRows := {}
local aOldCols := {}
local aOldData := {}
local bcolor := {|| iif(this.cellrowindex == 1,iif(this.cellcolindex == 1,{255,255,255},aColors[2]),iif(this.cellcolindex == 1,aColors[1],aColors[3]))}

aOldRows := aclone(aSelRows)
aOldCols := aclone(aSelCols)
aOldData := aclone(aSelData)

asize(aSelRows,0)
asize(aSelCols,0)
asize(aSelData,0)

for i := 1 to xtract.cols.itemcount
   do case
      case xtract.cols.cell(i,2) == 2 // selected for row
         aadd(aSelRows,xtract.cols.cell(i,1))
      case xtract.cols.cell(i,2) == 3 // selected for Column
         aadd(aSelCols,xtract.cols.cell(i,1))
      case xtract.cols.cell(i,2) == 4 // selected for data
         aadd(aSelData,{alltrim(xtract.cols.cell(i,1)),alltrim(aOperations[xtract.cols.cell(i,3)])})
   end case
next i

nRows := len(aSelRows)
nCols := len(aSelCols)
nData := len(aSelData)
         


if iscontroldefined(options,xtract)
   xtract.options.release
endif



nTotCols := nCols + 1 + iif(nCols == 0 .and. nData > 0,1,0)
nTotRows := max(nRows,nData) + 1

for i := 1 to nTotCols
   aadd(aWidths,120)
next i

aadd(aItem,'')

for i := 2 to nTotCols
   if i-1 <= nCols
      aadd(aItem,aSelCols[i-1])
   else
      aadd(aItem,'')
   endif
next i

for i := 1 to len(aWidths)
   aadd(aBackColors, bColor)
next i 

define grid options
   parent xtract
   row 75
   col 350
   height 150
   width 430
   showheaders .f.
   widths aWidths
   dynamicbackcolor aBackColors
end grid

xtract.options.additem(aItem)

for i := 2 to nTotRows
   asize(aItem,0)
   nCurCol := 1
   if i-1 <= nRows
      aadd(aItem,aSelRows[i-1])
   else
      aadd(aItem,'') 
   endif
   if nCols > 0 .or. nData > 0
      if i-1 <= nData
         aadd(aItem,alltrim(aSelData[i-1,1])+"-"+alltrim(aSelData[i-1,2]))
      else
         aadd(aItem,'') 
      endif
   endif   
   for j := 3 to nTotCols
      aadd(aItem,'')
   next j
   xtract.options.additem(aItem)
next i
if len(aSelRows) > 0 .or. len(aSelCols) > 0 .or. len(aSelData) > 0
   if .not. (comparearrays(aOldRows,aSelRows) .and. comparearrays(aOldCols,aSelCols) .and. comparearrays(aOldData,aSelData))
      createreport(xtract.tool1.autocalc.value)
   endif   
endif   
return nil


function createreport(lAutoCalc)
local aRowIds := {}
local aColIds := {}
local aDataIds := {}
local aRowData := {}
local aColData := {}
local aData := {}
local aTable := {}
local aColTable := {}
local aResults := {}
local aLine := {}
local aCurRow := {}
local aCurCol := {}
local aCurData := {}
local aReportGrid := {}
local aColHead := {}
local aHeads := {}
local aFirstRow := {}
local aFirstCol := {}
local aFirstData := {}
local aResultLine := {}
local cQStr := ""
local cRowStr := ""
local cColStr := ""
local cDataStr := ""
local cFilterStr := ""
local nRows := 0
local nCols := 0
local nData := 0
local nTotRows := 0
local nTotCols := 0
local i, j, k, aHeaders, aJustify, aRowTotal, aGT
local nCurRow, nCurrent, lDiff, nResRows, nResCols, nHeaders
local aColTotal := {}
local aRowRotal := {}
local bcolor := {|| {255,255,255}}
local aBackColors := {}
local aFilterItems := {}

if .not. lAutoCalc
   return nil
endif


if len(aSelRows) == 0 .and. len(aSelCols) == 0 .and. len(aSelData) == 0
   return nil
endif


wait window "Please wait while tabulating..." nowait


aRowIds := aclone(aSelRows)
aColIds := aclone(aSelCols)
aDataIds := aclone(aSelData)

/*
for i := 1 to xtract.selrows.itemcount
//   aadd(aRowIds,ascan(aCols,xtract.selrows.item(i)))
   aadd(aRowIds,xtract.selrows.item(i))
next i

for i := 1 to xtract.selcols.itemcount
//   aadd(aColIds,ascan(aCols,xtract.selcols.item(i)))
   aadd(aColIds,xtract.selcols.item(i))
next i

for i := 1 to xtract.datacols.itemcount
   aLineData := xtract.datacols.item(i)
//   aadd(aDataIds,{ascan(aCols,aLineData[1]),ascan(aOperations,aLineData[2])})
   aadd(aDataIds,{aLineData[1],aLineData[2]})
next i
*/


//nItemCount := getproperty(cWindowName,cGridName,"itemcount")

nRows := len(aRowIds)
nCols := len(aColIds)
nData := len(aDataIds)

for i := 1 to nRows
   cRowStr := cRowStr + aRowIds[i]
   if i < nRows
      cRowStr := cRowStr + ","
   endif
next i

for i := 1 to nCols
   cColStr := cColStr + aColIds[i]
   if i < nCols
      cColStr := cColStr + ","
   endif
next i

for i := 1 to nData
   do case
      case aDataIds[i,2] == "SUM"
         cDataStr := cDataStr + "sum("+aDataIds[i,1]+")"
      case aDataIds[i,2] == "MINIMUM"
         cDataStr := cDataStr + "min(round("+aDataIds[i,1]+",5))"
      case aDataIds[i,2] == "MAXIMUM"
         cDataStr := cDataStr + "max(round("+aDataIds[i,1]+",5))"
      case aDataIds[i,2] == "COUNT"
         cDataStr := cDataStr + "count("+aDataIds[i,1]+")"
   endcase         
   if i < nData
      cDataStr := cDataStr + ","
   endif
next i

//filters

cFilterStr := ""
for i := 1 to len(aAvailCols)
   if xtract.filters.cell(1,i) > 1
      aFilterItems := aFieldOptions[i,2]
      if len(alltrim(cFilterStr)) == 0
         cFilterStr := cFilterStr + alltrim(aAvailCols[i])+" = "+c2sql((aFilterItems[xtract.filters.cell(1,i)]))
      else
         cFilterStr := cFilterStr + " and "+alltrim(aAvailCols[i])+" = "+c2sql((aFilterItems[xtract.filters.cell(1,i)]))
      endif
   endif
next i   
         


cQStr := "select "

if len(cRowStr) > 0
   cQStr := cQStr + cRowStr
   if len(cColStr) > 0 .or. len(cDataStr) > 0
      cQStr := cQStr + ","
   endif
endif

if len(cColStr) > 0
   cQStr := cQstr + cColStr
   if len(cDataStr) > 0
      cQstr := cQStr + ","
   endif
endif

if len(cDataStr) > 0
   cQStr := cQstr + cDataStr
endif

cQStr := cQStr + " from data"

if len(alltrim(cFilterStr)) > 0  // filters
   cQstr := cQstr + " where "+cFilterStr
endif   



if len(cRowStr) > 0 .or. len(cColStr) > 0
   cQStr := cQstr + " group by "
   
   if len(cRowStr) > 0
      cQStr := cQStr + cRowStr
      if len(cColStr) > 0
         cQStr := cQStr + ","
      endif
   endif
  
   if len(cColStr) > 0
      cQStr := cQstr + cColStr
   endif
 
   cQStr := cQStr + " order by "
  
   if len(cRowStr) > 0
      cQStr := cQStr + cRowStr
      if len(cColStr) > 0 
         cQStr := cQStr + ","
      endif
   endif

   if len(cColStr) > 0
      cQStr := cQstr + cColStr
   endif
endif

//cStart := time()

aTable := sql(dbo,cQstr)

//cTimeTaken := elaptime(cStart,time())
//msginfo("Query took "+substr(cTimeTaken,1,2)+" Hours, "+substr(cTimeTaken,4,2)+" Minutes, "+substr(cTimeTaken,7,2)+" Seconds.")


if len(cColStr) > 0

   cQStr := "select " + cColStr +" from data "+iif(len(alltrim(cFilterStr)) > 0," where "+cFilterStr,"")+" group by "+cColStr+" order by "+cColStr
   aColTable := sql(dbo,cQstr)
endif

asize(aResults,0)



nTotRows := len(aTable) * iif(nData > 0,nData,1)
nTotCols := nRows + iif(nData > 1,1,0)+len(aColTable)+iif(nCols == 0 .and. nData > 0,1,0)

//aResults := array(nTotRows,nTotCols)
nCurRow := 1

if nData <= 1
   aadd(aResults,array(nTotCols))
else
   for j := 1 to nData
      aadd(aResults,array(nTotCols))
   next j      
endif

asize(aFirstRow,0)
asize(aFirstCol,0)
asize(aFirstData,0)

aLine := aTable[1]
for j := 1 to nRows
   aadd(aFirstRow,aLine[j])
next j

for j := 1 to nCols
   aadd(aFirstCol,aLine[nRows+j])
next j

for j := 1 to nData
   aadd(aFirstData,aLine[nRows+nCols+j])
next j


for i := 1 to len(aFirstRow)
   aResults[nCurRow,i] := aFirstRow[i]
next i

if nCols > 0
   if nCols == 1
      nCurrent := ascan(aColTable,{|x|x[1] == aFirstCol[1]})
   else
      nCurrent := ascan(aColTable,{|x|comparearrays(x,aFirstCol)})
   endif
   if nData > 0
      if nData == 1
         aResults[nCurRow,nRows+nCurrent] := aFirstData[1]
      else
         aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
         aResults[nCurRow,nRows+1+nCurrent] := aFirstData[1]
         for j := 2 to nData
            aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
            aResults[nCurRow+j-1,nRows+1+nCurrent] := aFirstData[j]
         next j
      endif
   endif   
else
   if nData > 0
      if nData == 1
         aResults[nCurRow,nRows+1] := aFirstData[1]
      else
         aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
         aResults[nCurRow,nRows+2] := aFirstData[1]
         for j := 2 to nData
            aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
            aResults[nCurRow+j-1,nRows+2] := aFirstData[j]
         next j
      endif
   endif
endif



for i := 2 to len(aTable)
   aLine := aTable[i]

   asize(aCurRow,0)
   asize(aCurCol,0)
   asize(aCurData,0)

   for j := 1 to nRows
      aadd(aCurRow,aLine[j])
   next j
 
   for j := 1 to nCols
      aadd(aCurCol,aLine[nRows+j])
   next j

   for j := 1 to nData
      aadd(aCurData,aLine[nRows+nCols+j])
   next j
   
   if comparearrays(aFirstRow,aCurRow) // Same Row different Column

      if nCols > 0
         if nCols == 1
            nCurrent := ascan(aColTable,{|x|x[1] == aCurCol[1]})
         else
            nCurrent := ascan(aColTable,{|x|comparearrays(x,aCurCol)})
         endif
         if nData > 0 
            if nData == 1
               aResults[nCurRow,nRows+nCurrent] := aCurData[1]
            else
   //            aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
               aResults[nCurRow,nRows+1+nCurrent] := aCurData[1]
               for j := 2 to nData
   //               aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                  aResults[nCurRow+j-1,nRows+1+nCurrent] := aCurData[j]
               next j
            endif
         endif   
      else
         if nData > 0
            if nData == 1
               aResults[nCurRow,nRows+1] := aCurData[1]
            else
//               aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
               aResults[nCurRow,nRows+2] := aCurData[1]
               for j := 2 to nData
//                  aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                  aResults[nCurRow+j-1,nRows+2] := aCurData[j]
               next j
            endif
         endif
      endif
   else // new Row  of data
      if nData <= 1
         nCurRow := nCurRow + 1
         aadd(aResults,array(nTotCols))
      else
         nCurRow := nCurRow + nData
         for j := 1 to nData
            aadd(aResults,array(nTotCols))
   	     next j      
      endif
      lDiff := .f.
      for j := 1 to len(aFirstRow)
         if (.not. lDiff) .and. (aFirstRow[j] <> aCurRow[j])
            lDiff := .t.
         endif
         if lDiff
            aResults[nCurRow,j] := aCurRow[j]
         endif   
      next j
      
      aFirstRow := aclone(aCurRow)
      aFirstCol := aclone(aCurCol)
      aFirstData := aclone(aCurData)
      
      
      
      if nCols > 0
         if nCols == 1
            nCurrent := ascan(aColTable,{|x|x[1] == aFirstCol[1]})
         else
            nCurrent := ascan(aColTable,{|x|comparearrays(x,aFirstCol)})
         endif
         if nData > 0
            if nData == 1
               aResults[nCurRow,nRows+nCurrent] := aFirstData[1]
            else
               aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
               aResults[nCurRow,nRows+1+nCurrent] := aFirstData[1]
               for j := 2 to nData
                  aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                  aResults[nCurRow+j-1,nRows+1+nCurrent] := aFirstData[j]
               next j
            endif
         endif   
      else
         if nData > 0
            if nData == 1
               aResults[nCurRow,nRows+1] := aFirstData[1]
            else
               aResults[nCurRow,nRows+1] := aDataIds[1,2]+"-"+aDataIds[1,1]
               aResults[nCurRow,nRows+2] := aFirstData[1]
               for j := 2 to nData
                  aResults[nCurRow+j-1,nRows+1] := aDataIds[j,2]+"-"+aDataIds[j,1]
                  aResults[nCurRow+j-1,nRows+2] := aFirstData[j]
               next j
            endif
         endif
      endif
   endif
next i      

aColHead := {}
nCurRow := 1
if nCols > 0
   aadd(aColHead,array(nCols))
   aFirstRow := aclone(aColTable[1])
   aColHead[nCurRow] := aclone(aColTable[1])

   for i := 2 to len(aColTable)
      aadd(aColHead,array(nCols))
      nCurRow := nCurRow + 1
      lDiff := .f.
      aCurRow := aclone(aColTable[i])

      for j := 1 to nCols
         if (.not. lDiff) .and. (aFirstRow[j] <> aCurRow[j])
            lDiff := .t.
         endif
         if lDiff
            aColHead[nCurRow,j] := aCurRow[j]
         endif   
      next j
      aFirstRow := aclone(aCurRow)
   next i
endif

aHeaders := {}

if nRows > 0 .or. nCols > 0
   aadd(aHeaders,array(nTotCols))
   for i := 1 to nRows
      aHeaders[1,i] := aRowIds[i]
   next i
   for i := 1 to len(aColHead)
      aHeaders[1,nRows+iif(nData > 1,1,0)+i] := aColHead[i,1]
   next i
   if len(aColHead) > 0
      if len(aColHead[1]) > 1
         for i := 2 to len(aColHead[1])
            aadd(aHeaders,array(nTotCols))
            for j := 1 to len(aColHead)
               aHeaders[i,nRows+iif(nData > 1,1,0)+j] := aColHead[j,i]
            next j
         next i
      endif   
   endif   
endif         

//summation

if nData > 0
   aRowTotal := array(len(aResults))
   aColTotal := array(nData,len(aResults[1]))
   aGT := array(nData)
   
   nResRows := len(aResults)
   nResCols := len(aResults[1])
   
   for i := 1 to nResRows
      aRowTotal[i] := 0
   next i
   for i := 1 to nData
      for j := nRows+iif(nData > 1,1,0)+1 to nResCols
         aColTotal[i,j] := 0
      next j   
   next i
   for i := 1 to nData
      aGt[i] := 0
   next i
   
   
   for i := 1 to nResRows step nData
      for j := nRows+iif(nData > 1,1,0)+1 to nResCols
         for k := 0 to nData - 1
            do case
               case aDataIds[k+1,2] == "SUM" .or. aDataIds[k+1,2] == "COUNT"
                  aRowTotal[i+k] := aRowTotal[i+k] + iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",0,aResults[i+k,j]))
                  aColTotal[k+1,j] := aColTotal[k+1,j] + iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",0,aResults[i+k,j]))
                  aGT[k+1] := aGT[k+1] + iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",0,aResults[i+k,j]))
               case aDataIds[k+1,2] == "MINIMUM" 
                  aRowTotal[i+k] := min(aRowTotal[i+k],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aRowTotal[i+k],aResults[i+k,j])))
                  aColTotal[k+1,j] := min(aColTotal[k+1,j],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aColTotal[k+1,j],aResults[i+k,j])))
                  aGT[k+1] := min(aGT[k+1],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",aGT[k+1],aResults[i+k,j])))
               case aDataIds[k+1,2] == "MAXIMUM"   
                  aRowTotal[i+k] := max(aRowTotal[i+k],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aRowTotal[i+k],aResults[i+k,j])))
                  aColTotal[k+1,j] := max(aColTotal[k+1,j],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),iif(valtype(aResults[i+k,j])=="U",aColTotal[k+1,j],aResults[i+k,j])))
                  aGT[k+1] := max(aGT[k+1],iif(valtype(aResults[i+k,j]) == "C",val(alltrim(aResults[i+k,j])),if(valtype(aResults[i+k,j]) == "U",aGT[k+1],aResults[i+k,j])))
            endcase
         next k
      next j
   next i

   
   if nCols > 0
      for i := 1 to nResRows
         aadd(aResults[i],str(aRowTotal[i]))
      next i
   
      for i := 1 to nData
         aadd(aColTotal[i],aGT[i])
      next i
      
      aadd(aHeaders[1],"Total")
      for i := 2 to len(aHeaders)
         aadd(aHeaders[i],"")
      next i
   endif   

   if nData > 1 .or. nRows > 0 // there is room for "Total"
      aColTotal[1,1] := "Total"
   endif
      
   
   for i := 1 to nData
      for j := 1 to len(aColTotal[i])
         if valtype(aColTotal[i,j]) == "N"
            aColTotal[i,j] := alltrim(str(aColTotal[i,j]))
         endif   
      next j
   next i
      
   for i := 1 to nData
      aadd(aResults,aclone(aColTotal[i]))
   next i

endif

aReportGrid := {}

nHeaders := len(aHeaders)
if nHeaders > 0
   for i := 1 to nHeaders
      aadd(aReportGrid,aclone(aHeaders[i]))
   next i
endif

nResRows := len(aResults)
for i := 1 to nResRows
   aadd(aReportGrid,aclone(aResults[i]))
next i

wait clear 

//aReportGrid := aClone(aResults)

if len(aReportGrid) > 0
   aHeaders := {}
   aWidths := {}
   aJustify := {}
   for i := 1  to len(aReportGrid[1])
      aadd(aHeaders,'')
      aadd(aWidths,100)
      if i > 1 .and. i > nRows+iif(nData > 1,1,0)
         aadd(aJustify,1)
      else
         aadd(aJustify,0)
      endif   
   next i
   
   bcolor := {||iif(this.cellrowindex <= len(aSelCols),;
                    iif(this.cellcolindex <= len(aSelRows),aColors[1],aColors[2]),iif(this.cellcolindex <= len(aSelRows),aColors[1],aColors[3]))}
   

   
   for i := 1 to len(aWidths)
      aadd(aBackColors,bcolor)
   next i
   
   if iscontroldefined(data,xtract)
      xtract.data.release()
   endif
   
   
   define grid data
      parent xtract
      row 335
      col 10
      width 770
      height 250
      widths aWidths
      headers aHeaders
      justify aJustify
      showheaders .f.
      items aReportGrid
      dynamicbackcolor aBackColors
//      cellnavigation .t.
   end grid
else
   if iscontroldefined(data,xtract)
      xtract.data.deleteallitems()
   endif   
endif

return nil

function comparearrays(x,y)
local i,j := 0
local lenx,leny := 0
local xelement, yelement
if valtype(x) == "A" .and. valtype(y) == "A"
   lenx := len(x)
   leny := len(y)
   if lenx <> leny
      return .f.
   endif
   for i := 1 to lenx
      xelement := x[i]
      yelement := y[i]
      if valtype(xelement) <> valtype(yelement)
         return .f.
      else
         if valtype(xelement) == "A"
            if .not. comparearrays(xelement,yelement)
               return .f.
            endif
         else
            if xelement <> yelement
               return .f.
            endif
         endif
      endif
   next i
   return .t.
endif
return nil

function importfromdbf
local cDbfFileName := ""
local aStruct := {}
local aFieldNames := {}
local aFieldTypes := {}
local aWidths := {}
local aData := {}
local aCurRow := {}
local cCurFieldName := ""
local aJustify := {}
local i


cDbfFileName := Getfile ( { {'All DBF Files','*.dbf'} } , 'Open DBF File' , 'c:\' , .f. , .t. )
if len(alltrim(cDbfFileName)) > 0
   select a
   use &cDbfFileName
   aStruct := dbstruct()
   for i := 1 to len(aStruct)
      aadd(aFieldNames,aStruct[i,1])
      aadd(aFieldTypes,aStruct[i,2])
      aadd(aWidths,aStruct[i,3]*10)
      aadd(aJustify,iif(i == 1 .or. aStruct[i,2] == "C" .or. aStruct[i,2] == "D" .or. aStruct[i,2] == "L",0,1))
   next i
   go top
   do while .not. eof()
      for i := 1 to len(aFieldNames)
         cCurFieldName := aFieldNames[i]
         do case
            case aFieldTypes[i] == "C"
               aadd(aCurRow,a->&cCurFieldName)
            case aFieldTypes[i] == "N"                
               aadd(aCurRow,str(a->&cCurFieldName))
            case aFieldTypes[i] == "D"
               aadd(aCurRow,dtoc(a->&cCurFieldName))
            case aFieldTypes[i] == "L"
               aadd(aCurRow,iif(a->&cCurFieldName,"True","False"))
            otherwise
               aadd(aCurRow,a->&cCurFieldName)
         endcase
      next i
      aadd(aData,aclone(aCurRow))
      asize(aCurRow,0)
      select a
      skip
   enddo
   close all
   if iscontroldefined(data,s)
      s.data.release
   endif
   define grid data
      parent s
      row 10
      col 10
      width 1000
      height 600
      items aData
      headers aFieldNames
      widths aWidths
      justify aJustify
   end grid
endif
return nil


function exporttosql(cWindow,cGrid)
local aCols := {}
local aTypes := {}
local nItemCount := 0
local aLineData := {}
local nResult := 0
local i, j, qstr
local nRecCount
local nAtaTime
local cQstr, nCount

nItemCount := getproperty(cWindow,cGrid,"itemcount")
if nItemCount == 0
   return nil
endif
aLineData := getproperty(cWindow,cGrid,"item",1)
for nCount := 1 to len(aLineData)
   aadd(aCols,getproperty(cWindow,cGrid,"header",nCount))
   aadd(aTypes,valtype(aLineData[nCount]))
next nCount


connect2db("")


qstr := "drop table if exists data;"
if .not. miscsql(dbo,qstr)
   return nil
endif

qstr := "create table data ("
for i := 1 to len(aCols)
   qstr := qstr + aCols[i]
   if i < len(aCols)
      qstr := qstr + ","
   endif
next i
qstr := qstr + ");"

if .not. miscsql(dbo,qstr)
   return nil
endif
nRecCount := 0
nAtaTime := 100
cQstr := "BEGIN TRANSACTION;"   
for i := 1 to nItemCount
   if nRecCount >= nAtaTime
      cQstr := cQstr + "COMMIT;"
      if .not. miscsql(dbo,cQstr)
         return nil
      endif      
      nRecCount := 0
      cQstr := ""
      cQstr := "BEGIN TRANSACTION;"   
   endif
   cQstr := cQstr + "insert into data values ("
   aLineData := getproperty(cWindow,cGrid,"item",i)
   for j := 1 to len(aLineData)
      cQstr := cQstr + c2sql(aLineData[j])
      if j < len(aLineData)
         cQstr := cQstr + ","
      endif
   next j
   cQstr := cQstr + ");"
   nReccount := nRecCount + 1
next i
if nRecCount > 0
   cQstr := cQstr + "COMMIT;"
   if .not. miscsql(dbo,cQstr)
      return nil
   endif      
endif   

return nil


FUNCTION connect2db(dbname)
dbo := sqlite3_open( dbname,.t.)
IF Empty( dbo )
   msginfo("Database could not be connected!")
   RETURN nil
ENDIF

//msginfo("Successfully Connected to the MySQL Server",appname)
RETURN nil

function sql(dbo1,qstr)   
local table := {}
local currow := nil
local tablearr := {}
local rowarr := {}
local datetypearr := {}
local numtypearr := {}
local typesarr := {}
local current := ""
local i, j
local stmt
local type1 := ""
table := sqlite3_get_table(dbo1,qstr)
if sqlite3_errcode(dbo1) > 0 // error
   msgstop(sqlite3_errmsg(dbo1)+" Query is : "+qstr)
   return nil
endif 
stmt := sqlite3_prepare(dbo1,qstr)
IF ! Empty( stmt )
   for i := 1 to sqlite3_column_count( stmt )
      type1 := sqlite3_column_decltype( stmt,i)
      do case
         case type1 == "TEXT"
            aadd(typesarr,"C")
         case type1 == "INTEGER" .or. type1 == "REAL"
            aadd(typesarr,"N")
         otherwise
            aadd(typesarr,"C")   
      endcase
   next i
endif
sqlite3_reset( stmt )
   
if len(table) > 1
   asize(tablearr,0)
   rowarr := table[2]
   for i := 1 to len(rowarr)
      current := rowarr[i]
/*      if typesarr[i] == "C" .and. len(alltrim(current)) == 10 .and. val(alltrim(substr(current,1,4))) > 0 .and. val(alltrim(substr(current,6,2))) > 0 .and. val(alltrim(substr(current,6,2))) <= 12 .and. val(alltrim(substr(current,9,2))) > 0 .and. val(alltrim(substr(current,9,2))) <= 31 .and. substr(alltrim(current),5,1) == "-" .and. substr(alltrim(current),8,1) == "-" 
         aadd(datetypearr,.t.)
      else
      */
         aadd(datetypearr,.f.)
/*      endif*/
   next i
   for i := 2 to len(table)
      rowarr := table[i]
      for j := 1 to len(rowarr)
         if datetypearr[j]
            rowarr[j] := CToD(SubStr(alltrim(rowarr[j]),9,2)+"-"+SubStr(alltrim(rowarr[j]),6,2)+"-"+SubStr(alltrim(rowarr[j]),1,4))
         endif
         if typesarr[j] == "N"
            rowarr[j] := val(rowarr[j])
         endif    
      next j
      aadd(tablearr,aclone(rowarr))
   next i
endif
return tablearr

function miscsql(dbo1,qstr)
if empty(dbo1)
   msgstop("Database Connection Error!")
   return .f.
endif
sqlite3_exec(dbo1,qstr)
if sqlite3_errcode(dbo1) > 0 // error
   msgstop(sqlite3_errmsg(dbo1)+" Query is : "+qstr)
   return .f.
endif 
return .t.

function C2SQL(Value)

   local cValue := ""
   local cdate := ""
   if valtype(value) == "C" .and. len(alltrim(value)) > 0
      value := strtran(value,"'","''")
   endif   
   do case
      case Valtype(Value) == "N"
         cValue := "'"+AllTrim(Str(Value))+"'"

      case Valtype(Value) == "D"
         if !Empty(Value)
            cdate := dtos(value)
            cValue := "'"+substr(cDate,1,4)+"-"+substr(cDate,5,2)+"-"+substr(cDate,7,2)+"'"
         else
            cValue := "''"
         endif
      case Valtype(Value) $ "CM"
         IF Empty( Value)
            cValue="''"
         ELSE
            cValue := "'" + value + "'"
         ENDIF

      case Valtype(Value) == "L"
         cValue := AllTrim(Str(iif(Value == .F., 0, 1)))

      otherwise
         cValue := "''"       // NOTE: Here we lose values we cannot convert

   endcase
return cValue
