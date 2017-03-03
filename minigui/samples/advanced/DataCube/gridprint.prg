#include "minigui.ch"
#include "miniprint.ch"

memvar msgarr
memvar fontname
memvar fontsizesstr
memvar headerarr
memvar sizes
memvar headersizes
memvar selectedprinter
memvar columnarr
memvar fontnumber
memvar windowname
memvar lines
memvar linedata
memvar cPrintdata
memvar gridname
memvar ajustifiy
memvar aJustify
memvar psuccess
memvar aprinternames
memvar defaultprinter
memvar papernames
memvar papersizes
memvar printerno
memvar header1
memvar header2
memvar header3
memvar xres
memvar maxcol2
memvar curcol1

*------------------------------------------------------------------------------*
Init Procedure _InitPrintGrid
*------------------------------------------------------------------------------*

	InstallMethodHandler ( 'Print' , 'MyGridPrint' )

Return

*------------------------------------------------------------------------------*
Procedure MyGridPrint (  cWindowName , cControlName , MethodName )
*------------------------------------------------------------------------------*
MethodName := Nil

	If GetControlType ( cControlName , cWindowName ) == 'GRID'

		gridprint( cControlName , cWindowName  )

		_HMG_UserComponentProcess := .T.

	else

		_HMG_UserComponentProcess := .F.

	endif

Return


DECLARE window printgrid

function gridprint(cGrid,cWindow,fontsize,orientation,aHeaders,fontname1,showwindow1)
local count1 := 0
local count2 := 0
local maxcol1 := 0
local i := 0
private msgarr := {"Nothing to print",;    //1
                   "No printers have been installed!",;  //2
                   "Print Wizard",;  //3
                   "Report Writer",; //4
                   "Columns",; //5
                   "Name of the Column",; //6
                   "Width (mm)",; //7
                   "Double Click a Column to toggle between selecting and not selecting for printing.",; //8
                   "Edit Text Column Size",; //9
                   "Total Width :",; //10
                   "out of",;  //11
                   "Header 1",;  //12
                   "Header 2",; //13
                   "Header 3",; //14
                   "Footer 1",; //15
                   "Report Properties",; //16
                   "Font Size",; //17
                   "Lengthy Line",; //18
                   "Word Wrap",; //19
                   "Truncate",; //20
                   "Pagination",; //21
                   "Off",; //22
                   "Top",; //23
                   "Bottom",; //24
                   "Grid Lines",; //25
                   "Column",; //26
                   "Row",; //27
                   "Page Center",; //28
                   "Vertical",; //29
                   "Page/Printer",; //30 
                   "Orientation",; //31
                   "Landscape",; //32
                   "Portrait",; //33
                   "Printer: ",; //34
                   "Page Size",; //35
                   "Page Width",; //36
                   "Page Height",; //37
                   "Margins (mm)",; //38
                   "Top",; //39
                   "Right",; //40
                   "Left",; //41
                   "Bottom",; //42
                   "Print",; //43
                   "Cancel",; //44
                   "Welcome to Print Wizard",; //45
                   "You had selected more columns than to fit in a page!",; //46
                   "You have to select a printer!",; //47
                   "Printer could not be selected! Check Availability of Printer.",; //48
                   "Page No. :",; //49
                   "Size :",; //50
                   "Done",; //51
                   "Size of Columns other than text type can not be modified!",; //52
                   "Justification constants not given properly.",; //53
                   "Whitespace",; //54
                   "Spread",; //55
                   "Apply",; //56
                   }

private fontname := ""
PRIVATE fontsizesstr := {}
PRIVATE headerarr := {}
PRIVATE sizes := {}
private headersizes := {}
PRIVATE selectedprinter := ""
PRIVATE columnarr := {}
PRIVATE fontnumber := 0
PRIVATE windowname := cWindow
private lines := 0
private cPrintdata := {}
private linedata := {}
PRIVATE gridname := cGrid
PRIVATE ajustifiy := {}
PRIVATE psuccess := .f.
PRIVATE aprinternames := aprinters()
PRIVATE defaultprinter := GetDefaultPrinter()
private papernames := {"Letter","Legal","Executive","A3","A4","Custom"}
private papersizes := {{216,279},{216,355.6},{184.1,266.7},{297,420},{210,297},{216,279}}
PRIVATE printerno := 0
PRIVATE header1 := ""
PRIVATE header2 := ""
PRIVATE header3 := ""
private xres := {}
private maxcol2 := 0.0
private curcol1 := 0.0
DEFAULT fontsize := 12
DEFAULT orientation := "P"
default fontname1 := "Arial"
default aheaders := {"","",""}
DEFAULT ShowWindow1 := .t.

switch len(aheaders)
   case 3
      header1 := aheaders[1]
      header2 := aheaders[2]
      header3 := aheaders[3]
      exit
   case 2
      header1 := aheaders[1]
      header2 := aheaders[2]
      exit
   case 1
      header1 := aheaders[1]
end switch

fontname := fontname1
lines := getproperty(windowname,gridname,"itemcount")
IF lines == 0
   msginfo(msgarr[1])
   RETURN nil
ENDIF

IF Len(aprinternames) == 0
   msgstop(msgarr[2],msgarr[3])
   RETURN nil
ENDIF
fontsizesstr := {"8","9","10","11","12","14","16","18","20","22","24","26","28","36","48","72"}
FOR count1 := 1 TO Len(fontsizesstr)
   IF Val(fontsizesstr[count1]) == fontsize
      fontnumber := count1
   ENDIF
NEXT count1
IF fontnumber == 0
   fontnumber := 1
ENDIF
linedata := getproperty(windowname,gridname,"item",1)
asize(sizes,0)
for count1 := 1 to len(linedata)
   aadd(sizes,0)
   aadd(headerarr,getproperty(windowname,gridname,"header",count1))
next count1

i := GetControlIndex ( gridname , windowname )
aJustify := _HMG_aControlMiscData1 [i] [3]

FOR count1 := 1 TO Len(headerarr)
   AAdd(columnarr,{1,headerarr[count1],sizes[count1],ajustify[count1]})
NEXT count1
FOR count1 := 1 TO Len(aprinternames)
   IF Upper(AllTrim(aprinternames[count1])) == Upper(AllTrim(defaultprinter))
      printerno := count1
      EXIT
   ENDIF
NEXT count1
IF printerno == 0
   printerno := 1
ENDIF

   define window printgrid at 0,0 width 700 height 440 title msgarr[4] modal nosize nosysmenu
      define tab tab1 at 10,10 width 285 height 335
         define page msgarr[5]
            DEFINE grid columns
               row 30
               col 10
               width 250
               height 240
               widths {0,130,70}
               justify {0,0,1}
               headers {"",msgarr[6],msgarr[7]}
               image {'wrong','right'}
               tooltip msgarr[8]
               ondblclick printgridtoggle()
               onchange editcoldetails()
            END GRID
            DEFINE label sizelabel1
               Row 280
               Col 10
               value msgarr[50]
               width 40
            END label
            DEFINE textbox size
               Row 280
               Col 50
               width 60
               value 0.0
               numeric .t.
               rightalign .t.
               inputmask "999.99"
            END textbox
            DEFINE button done
               Row 280
               Col 120
               width 50
               caption msgarr[56]
               action setprintgridcoldetails()
            END button
         end page
         define page msgarr[16]
            DEFINE label header1label
               Row 35
               Col 10
               width 100
               value msgarr[12]
            END label
            DEFINE textbox header1
               Row 30
               Col 110
               width 165
               Value header1
               on change printgridpreview()
            END textbox
            DEFINE label header2label
               Row 75
               Col 10
               width 100
               value msgarr[13]
            END label
            DEFINE textbox header2
               Row 70
               Col 110
               Value header2
               on change printgridpreview()
               width 165
            END textbox
            DEFINE label header3label
               Row 105
               Col 10
               width 100
               value msgarr[14]
            END label
            DEFINE textbox Header3
               Row 100
               Col 110
               Value header3
               on change printgridpreview()
               width 165
            END textbox
            DEFINE label footer1label
               Row 135
               Col 10
               width 100
               value msgarr[15]
            END label
            DEFINE textbox Footer1
               Row 130
               Col 110
               width 165
               on change printgridpreview()
            END textbox
            define label selectfontsizelabel
               row 165
               col 10
               value msgarr[17]
               width 100
            end label
            define combobox selectfontsize
               row 160
               col 110
               width 50
               items fontsizesstr
               on change fontsizechanged()
               value fontnumber
            end combobox
            define label multilinelabel
               row 195
               col 10
               value msgarr[18]
               width 100
            end label
            define combobox wordwrap
               row 190
               col 110
               width 90
               items {msgarr[19],msgarr[20]}
               on change printgridpreview()
               value 2
            end combobox
            define label pagination
               row 225
               col 10
               value msgarr[21]
               width 100
            end label
            define combobox pageno
               row 220
               col 110
               width 90
               items {msgarr[22],msgarr[23],msgarr[24]}
               on change printgridpreview()
               value 2
            end combobox
            define label separatorlab
               row 255
               col 10
               width 100
               value msgarr[25]
            end label
            DEFINE checkbox collines
               Row 250
               Col 110
               width 70
               on change printgridpreview()
               caption msgarr[26]
               value .t.
            END checkbox
            DEFINE checkbox rowlines
               Row 250
               Col 180
               width 50
               on change printgridpreview()
               caption msgarr[27]
               value .t.
            END checkbox
            define label centerlab
               row 280
               col 10
               width 100
               value msgarr[28]
            end label
            DEFINE checkbox vertical
               Row 275
               Col 110
               width 60
               on change printgridpreview()
               caption msgarr[29]
               value .t.
            END checkbox
            define label spacelab
               row 305
               col 10
               width 100
               height 20
               value msgarr[54]
            end label
            DEFINE checkbox spread
               Row 305
               Col 110
               width 60
               height 20
               on change fontsizechanged()
               caption msgarr[55]
               value .t.
            END checkbox            
         end page
         define page msgarr[30]
            define label orientationlabel
               row 30
               col 10
               Value msgarr[31]
               width 100
            end label
            define combobox paperorientation
               row 30
               col 110
               width 90
               items {msgarr[32],msgarr[33]}
               on change papersizechanged()
               value IIf(orientation == "P",2,1)
            end combobox
            DEFINE label printerslabel
               Row 60
               Col 10
               width 100
               value msgarr[34]
            END label
            DEFINE combobox printers
               Row 60
               Col 110
               width 165
               items aprinternames
               value printerno
            END combobox
            define label sizelabel
               row 90
               col 10
               width 100
               value msgarr[35]
            end label
            DEFINE combobox pagesizes
               Row 90
               Col 110
               width 165
               items papernames
               onchange papersizechanged()
            END combobox
            define label widthlabel
               row 120
               col 10
               value msgarr[36]
               width 100
            end label
            define textbox width
               row 120
               col 110
               width 60
               inputmask "999.99"
               on change printgridpreview()
               numeric .t.
               rightalign .t.
            end textbox
            define label widthmm
               row 120
               col 170
               value "mm"
               width 25
            end label
            define label heightlabel
               row 150
               col 10
               value msgarr[37]
               width 100
            end label
            define textbox height
               row 150
               col 110
               width 60
               inputmask "999.99"
               on change printgridpreview()
               numeric .t.
               rightalign .t.
            end textbox
            define label heightmm
               row 150
               col 170
               value "mm"
               width 25
            end label
            define frame margins
               row 180
               col 5
               width 185
               height 80
               caption msgarr[38]
            end frame
            define label toplabel
               row 200
               col 10
               width 35
               value msgarr[39]
            end label
            define textbox top
               row 200
               col 45
               width 50
               inputmask "99.99"
               numeric .t.
               on change printgridpreview()
               rightalign .t.
            end textbox
            define label rightlabel
               row 200
               col 100
               width 35
               value msgarr[40]
            end label
            define textbox right
               row 200
               col 135
               width 50
               inputmask "99.99"
               on change papersizechanged()
               numeric .t.
               rightalign .t.
            end textbox
            define label leftlabel
               row 230
               col 10
               width 35
               value msgarr[41]
            end label
            define textbox left
               row 230
               col 45
               width 50
               inputmask "99.99"
               on change papersizechanged()
               numeric .t.
               rightalign .t.
            end textbox
            define label bottomlabel
               row 230
               col 100
               width 35
               value msgarr[42]
            end label
            define textbox bottom
               row 230
               col 135
               width 50
               inputmask "99.99"
               numeric .t.
               on change printgridpreview()
               rightalign .t.
            end textbox
         end page
      end tab
      define button browseprint1
         row 350
         col 160
         caption msgarr[43]
         action printstart()
         width 80
      end button
      define button browseprintcancel
         row 350
         col 260
         caption msgarr[44]
         action printgrid.release
         width 80
      end button
      DEFINE statusbar
         statusitem msgarr[45] width 200
         statusitem msgarr[10] + "mm "+msgarr[11]+"mm" width 300
      END statusbar
   end window
printgrid.pagesizes.value := 1
printgrid.top.value := 20.0
printgrid.right.value := 20.0
printgrid.bottom.value := 20.0
printgrid.left.value := 20.0
papersizechanged()
printgrid.center
IF .not. showwindow1
   IF printgrid.browseprint1.enabled
      printstart()
   ELSE
      printgrid.activate
   ENDIF
ELSE
   printgrid.activate
ENDIF
return nil

function printcoltally
LOCAL col := 0
local count1 := 0
local count2 := 0
local totcol := 0.0
if .not. iscontroldefined(browseprintcancel,printgrid)
   return nil
endif
for count1 := 1 to Len(columnarr)
   IF columnarr[count1,1] == 1
      col := col + columnarr[count1,3] + 2 // 2 mm for column separation
      count2 := count2 + 1
   endif
next count1
if col < maxcol2 .and. printgrid.spread.value
   totcol := col - (count2 * 2)
   for count1 := 1 to len(columnarr)
      IF columnarr[count1,1] == 1
         columnarr[count1,3] := (maxcol2 - (count2 *2) - 5) * columnarr[count1,3] / totcol
      endif
   next count1
   col := maxcol2 - 5
endif
curcol1 := col
printgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))

IF maxcol2 >= curcol1
   printgrid.browseprint1.enabled := .t.
   printgrid.statusbar.item(1) := msgarr[45]
ELSE
   printgrid.statusbar.item(1) := msgarr[46]
   printgrid.browseprint1.enabled := .f.
   return nil
endif
return nil

function fontsizechanged
LOCAL fontsize1 := 0 
local cPrintdata := ""
local count1 := 0
local count2 := 0
local aec := ""
local aitems := {}
if .not. iscontroldefined(browseprintcancel,printgrid)
   return nil
endif
fontsize1 := val(alltrim(printgrid.selectfontsize.item(printgrid.selectfontsize.value)))
IF fontsize1 > 0
   linedata := getproperty(windowname,gridname,"item",1)
   asize(sizes,0)
   asize(headersizes,0)
   for count1 := 1 to len(linedata)
      aadd(sizes,0)
      aadd(headersizes,0)
   next count1
   for count1 := 1 to lines
      linedata := getproperty(windowname,gridname,"item",count1)
      for count2 := 1 to len(linedata)
         sizes[count2] := max(sizes[count2],printlen(alltrim(linedata[count2]),fontsize1,fontname))
      next count2
   next count1
   for count1 := 1 to len(headerarr)
       headersizes[count1] := printlen(alltrim(headerarr[count1]),fontsize1,fontname)
   next count1
   FOR count1 := 1 TO Len(columnarr)
      columnarr[count1,3] := max(sizes[count1],headersizes[count1])
   NEXT count1
ENDIF
printcoltally()
refreshcolumnprintgrid()
printgridpreview()
return nil



function printstart
local printername, size, lastrow
LOCAL row := 0
LOCAL col := 0
LOCAL lh := 0 // line height
LOCAL pageno := 0
LOCAL printdata := {}
LOCAL justifyarr := {}
LOCAL maxrow1 := 0
LOCAL maxcol1 := curcol1
LOCAL maxlines := 0
LOCAL totrows := getproperty(windowname,gridname,"itemcount")
LOCAL leftspace := 0
LOCAL rightspace := 0
LOCAL firstrow := 0
LOCAL size1 := 0
LOCAL data1 := ""
LOCAL paperwidth := printgrid.width.value
LOCAL paperheight := printgrid.height.value
LOCAL totcols := 0
local papersize := 0
local sizesarr := {}
local totcol := 0
local colcount := 0
local nextline := {}
local nextcount := 0
local count1 := 0
local count2 := 0
local count3 := 0
local count4 := 0
local dataprintover := .t.
local cPrintdata := ""
local aec := ""
local aitems := {}

IF printgrid.printers.value > 0
   printername := AllTrim(printgrid.printers.item(printgrid.printers.value))
ELSE
   msgstop(msgarr[47],msgarr[3])
   RETURN nil
ENDIF
//private papernames := {"Letter","Legal","Executive","A3","A4","Custom"}

do case
   case printgrid.pagesizes.value == 1 //letter
      papersize := PRINTER_PAPER_LETTER
   case printgrid.pagesizes.value == 2 //legal
      papersize := PRINTER_PAPER_LEGAL
   case printgrid.pagesizes.value == 3 //executive
      papersize := PRINTER_PAPER_EXECUTIVE
   case printgrid.pagesizes.value == 4 //A3
      papersize := PRINTER_PAPER_A3
   case printgrid.pagesizes.value == 5 //A4
      papersize := PRINTER_PAPER_A4
   case printgrid.pagesizes.value == 6 //Custom
      papersize := PRINTER_PAPER_USER
endcase

if printgrid.pagesizes.value == 6 // custom
    SELECT PRINTER printername TO psuccess ORIENTATION IIf(printgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
        PAPERSIZE papersize;
        PAPERLENGTH printgrid.height.value;
        PAPERWIDTH printgrid.width.value;
        COPIES 1;
        PREVIEW
else
    SELECT PRINTER printername TO psuccess ORIENTATION IIf(printgrid.paperorientation.value == 1,PRINTER_ORIENT_LANDSCAPE,PRINTER_ORIENT_PORTRAIT);
        PAPERSIZE papersize;
        COPIES 1;
        PREVIEW
endif
IF .not. psuccess
   msgstop(msgarr[48],msgarr[3])
   RETURN nil
ENDIF

size1 := val(alltrim(printgrid.selectfontsize.item(printgrid.selectfontsize.value)))


start printdoc
row := printgrid.top.value
maxrow1 := printgrid.height.value - printgrid.bottom.value
if printgrid.vertical.value
   col := (printgrid.width.value - curcol1)/2
else
   col := printgrid.left.value
endif
lh := Int((size1/72 * 25.4)) + 1 // line height
start printpage
pageno := 1
IF printgrid.pageno.value == 2
   @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
   row := row + lh
ENDIF
IF Len(AllTrim(printgrid.header1.value)) > 0
   @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header1.value) font fontname size size1+2 center
   row := row + lh + lh
ENDIF
IF Len(AllTrim(printgrid.header2.value)) > 0
   @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header2.value) font fontname size size1+2 center
   row := row + lh + lh
ENDIF
IF Len(AllTrim(printgrid.header3.value)) > 0
   @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header3.value) font fontname size size1+2 center
   row := row + lh + lh
ENDIF

firstrow := Row
@ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
ASize(printdata,0)
ASize(justifyarr,0)
asize(sizesarr,0)
FOR count1 := 1 TO Len(columnarr)
   IF columnarr[count1,1] == 1
      size := columnarr[count1,3]
      data1 := columnarr[count1,2]
      IF printLen(AllTrim(data1),size1,fontname) <= size
         AAdd(printdata,alltrim(data1))
      ELSE // header size bigger than column! to be truncated.
         count2 := len(data1)
         do while printlen(substr(data1,1,count2),size1,fontname) > size
            count2 := count2 - 1
         enddo
         AAdd(printdata,substr(data1,1,count2))
      ENDIF
      AAdd(justifyarr,columnarr[count1,4])
      aadd(sizesarr,columnarr[count1,3])
   ENDIF
NEXT count1
printline(row,col,printdata,justifyarr,sizesarr,fontname,size1)
row := row + lh
@ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
FOR count1 := 1 TO totrows
   linedata := getproperty(windowname,gridname,"item",count1)
   ASize(printdata,0)
   asize(nextline,0)
   FOR count2 := 1 TO Len(columnarr)
      IF columnarr[count2,1] == 1
         size := columnarr[count2,3]
         data1 := linedata[count2]
         IF printLen(AllTrim(data1),size1,fontname) <= size
            aadd(printdata,alltrim(data1))
            aadd(nextline,0)
         ELSE  // truncate or wordwrap!
            IF printgrid.wordwrap.value == 2 // truncate
               count3 := len(data1)
               do while printlen(substr(data1,1,count3),size1,fontname) > size
                  count3 := count3 - 1
               enddo
               AAdd(printdata,substr(data1,1,count3))
               aadd(nextline,0)
            ELSE // wordwrap
               count3 := len(data1)
               do while printlen(substr(data1,1,count3),size1,fontname) > size
                  count3 := count3 - 1
               enddo
               data1 := substr(data1,1,count3)
               if rat(" ",data1) > 0
                  count3 := rat(" ",data1)
               endif
               AAdd(printdata,substr(data1,1,count3))
               aadd(nextline,count3)
            ENDIF
         ENDIF
      ENDIF
   NEXT count2
   printline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
   Row := Row + lh
   dataprintover := .t.
   for count2 := 1 to len(nextline)
      if nextline[count2] > 0
         dataprintover := .f.
      endif
   next count2
   do while .not. dataprintover
      ASize(printdata,0)
      for count2 := 1 to len(columnarr)
         IF columnarr[count2,1] == 1
            size := columnarr[count2,3]
            data1 := linedata[count2]
            if nextline[count2] > 0 //there is some next line
               data1 := substr(data1,nextline[count2]+1,len(data1))
               IF printLen(AllTrim(data1),size1,fontname) <= size
                  aadd(printdata,alltrim(data1))
                  nextline[count2] := 0
               ELSE // there are further lines!
                  count3 := len(data1)
                  do while printlen(substr(data1,1,count3),size1,fontname) > size
                     count3 := count3 - 1
                  enddo
                  data1 := substr(data1,1,count3)
                  if rat(" ",data1) > 0
                     count3 := rat(" ",data1)
                  endif
                  AAdd(printdata,substr(data1,1,count3))
                  nextline[count2] := nextline[count2]+count3
               ENDIF
            else
               AAdd(printdata,"")
               nextline[count2] := 0
            endif
         endif
      next count2
      printline(row,col,printdata,justifyarr,sizesarr,fontname,size1,lh)
      Row := Row + lh
      dataprintover := .t.
      for count2 := 1 to len(nextline)
         if nextline[count2] > 0
            dataprintover := .f.
         endif
      next count2
   enddo

   IF Row+lh >= maxrow1
      @ Row,Col-1 print line TO Row,col+maxcol1-1  penwidth 0.25
      lastrow := Row
      totcol := 0
      @ firstrow,Col-1 print line TO lastrow,Col-1  penwidth 0.25
      IF printgrid.collines.value
         colcount := 0
         for count2 := 1 to len(columnarr)
            IF columnarr[count2,1] == 1
                  totcol := totcol + columnarr[count2,3]
                  colcount := colcount + 1
                  @ firstrow,col+totcol+(colcount * 2)-1 print line TO lastrow,col+totcol+(colcount * 2)-1 penwidth 0.25
            ENDIF
         next count2
      ENDIF
      @ firstrow,col+maxcol1-1 print line TO lastrow,col+maxcol1-1 penwidth 0.25
      IF Len(AllTrim(printgrid.footer1.value)) > 0
         @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.footer1.value) font fontname size size1+2 center
         row := row + lh + lh
      ENDIF
      IF printgrid.pageno.value == 3
         Row := Row + lh
         @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
      ENDIF
      END printpage
      pageno := pageno + 1
      row := printgrid.top.value
      start printpage
      IF printgrid.pageno.value == 2
         @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
         row := row + lh
      ENDIF
      IF Len(AllTrim(printgrid.header1.value)) > 0
         @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header1.value) font fontname size size1+2 center
         row := row + lh + lh
      ENDIF
      IF Len(AllTrim(printgrid.header2.value)) > 0
         @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header2.value) font fontname size size1+2 center
         row := row + lh + lh
      ENDIF
      IF Len(AllTrim(printgrid.header3.value)) > 0
         @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.header3.value) font fontname size size1+2 center
         row := row + lh + lh
      ENDIF

      firstrow := Row
      @ Row ,Col-1  print line TO Row ,col+maxcol1-1 penwidth 0.25
      ASize(printdata,0)
      ASize(justifyarr,0)
      asize(sizesarr,0)
      FOR count2 := 1 TO Len(columnarr)
         IF columnarr[count2,1] == 1
            size := columnarr[count2,3]
            data1 := columnarr[count2,2]
            IF printLen(AllTrim(data1),size1,fontname) <= size
               AAdd(printdata,alltrim(data1))
            ELSE // header size bigger than column! truncated as of now.
               count3 := len(data1)
               do while printlen(substr(data1,1,count3),size1,fontname) > size
                  count3 := count3 - 1
               enddo
               AAdd(printdata,substr(data1,1,count3))
            ENDIF
            AAdd(justifyarr,columnarr[count2,4])
            aadd(sizesarr,columnarr[count2,3])
         ENDIF
      NEXT count2
      printline(row,col,printdata,justifyarr,sizesarr,fontname,size1)
      row := row + lh
      @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
   ELSE
      IF printgrid.rowlines.value
         @ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
      ENDIF
   ENDIF
NEXT count1
@ Row,Col-1 print line TO Row,col+maxcol1-1 penwidth 0.25
lastrow := Row
totcol := 0
colcount := 0
@ firstrow,Col-1 print line TO lastrow,Col-1 penwidth 0.25
IF printgrid.collines.value
   for count1 := 1 to len(columnarr)
      IF columnarr[count1,1] == 1
         totcol := totcol + columnarr[count1,3]
         colcount := colcount + 1
         @ firstrow,col+totcol+(colcount * 2)-1 print line TO lastrow,col+totcol+(colcount * 2)-1 penwidth 0.25
      ENDIF
   next count2
ENDIF
@ firstrow,col+maxcol1-1 print line TO lastrow,col+maxcol1-1 penwidth 0.25

IF Len(AllTrim(printgrid.footer1.value)) > 0
   @ Row+(lh/2),col+Int(maxcol1/2) print AllTrim(printgrid.footer1.value) font fontname size size1+2 center
   row := row + lh + lh
ENDIF
IF printgrid.pageno.value == 3
   Row := Row + lh
   @ Row,(col+maxcol1 - printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname) - 5) print msgarr[49]+alltrim(str(pageno,10,0)) font fontname size size1
ENDIF
end printpage
end printdoc
IF iswindowactive(printgrid)
   printgrid.release
ENDIF
return nil


FUNCTION printgridtoggle
LOCAL lineno := printgrid.columns.value
LOCAL linedetail := {}
if .not. iscontroldefined(browseprintcancel,printgrid)
   return nil
endif
IF lineno > 0
   IF columnarr[lineno,1] == 1
      columnarr[lineno,1] := 0
   ELSE
      columnarr[lineno,1] := 1
   ENDIF
   printgrid.columns.value := lineno
ENDIF
fontsizechanged()
RETURN nil

FUNCTION refreshcolumnprintgrid
local count1 := 0
if .not. iscontroldefined(browseprintcancel,printgrid)
   return nil
endif
printgrid.columns.deleteallitems()
FOR count1 := 1 TO Len(columnarr)
   printgrid.columns.additem({columnarr[count1,1],columnarr[count1,2],AllTrim(Str(columnarr[count1,3]))})
NEXT count1
if printgrid.columns.itemcount > 0
   printgrid.columns.value := 1
endif
RETURN nil

FUNCTION editcoldetails
LOCAL lineno := printgrid.columns.value
LOCAL columnsize := 0
IF lineno > 0
   printgrid.size.value := columnarr[lineno,3] 
   if ajustify[lineno] == 0 .or. ajustify[lineno] == 2
      printgrid.size.enabled := .t.
   else
      printgrid.size.enabled := .f.
//      msginfo(msgarr[52])
   endif
ENDIF
RETURN nil

FUNCTION setprintgridcoldetails
LOCAL lineno := printgrid.columns.value
IF lineno > 0
   columnarr[lineno,3] := printgrid.size.value
ENDIF
printcoltally()
refreshcolumnprintgrid()
printgrid.columns.value := lineno
printgridpreview()
RETURN nil

function printline(row,col,aitems,ajustify,sizesarr,fontname,size1)
local tempcol := 0
local count1 := 0
local njustify
if len(aitems) <> len(ajustify)
   msginfo(msgarr[53])
ENDIF
tempcol := col
for count1 := 1 to len(aitems)
   njustify := ajustify[count1]
   do case
      case njustify == 0 //left
         @ Row,tempcol print aitems[count1] font fontname size size1
      case njustify == 1 //right
         @ Row,tempcol+sizesarr[count1] print aitems[count1] font fontname size size1 right
      case njustify == 2 // center
         @ Row,tempcol+(sizesarr[count1]/2) print aitems[count1] font fontname size size1 center
   end case
   tempcol := tempcol + sizesarr[count1] + 2
next count1
return nil

function printLen( cString,fontsize,fontname)
return round(gettextwidth(Nil,cString,fontname)*0.072/72*25.4*fontsize,2)

function papersizechanged
if .not. iscontroldefined(browseprintcancel,printgrid)
   return nil
endif
if printgrid.pagesizes.value > 0
   if printgrid.paperorientation.value == 2 //portrait
      printgrid.width.value := papersizes[printgrid.pagesizes.value,1]
      printgrid.height.value := papersizes[printgrid.pagesizes.value,2]
   else // landscape
      printgrid.width.value := papersizes[printgrid.pagesizes.value,2]
      printgrid.height.value := papersizes[printgrid.pagesizes.value,1]
   endif
   maxcol2 := printgrid.width.value - printgrid.left.value - printgrid.right.value
   printgrid.statusbar.item(2) := msgarr[10]+" "+alltrim(str(curcol1,12,2))+" "+msgarr[11]+" "+alltrim(str(maxcol2,12,2))   
endif
if printgrid.pagesizes.value == printgrid.pagesizes.itemcount // custom
   printgrid.width.readonly := .f.
   printgrid.height.readonly := .f.
else
   printgrid.width.readonly := .t.
   printgrid.height.readonly := .t.
endif
fontsizechanged()
return nil


function printgridpreview
local startx := 10
local starty := 300
local endx := 360
local endy := 690
local maxwidth := endy - starty - (10 * 2) // 10 for each side
local maxheight := endx - startx - (10 * 2)
local width := 0.0 
local height := 0.0
local resize := 1
local curx := 0
local cury := 0
LOCAL lh := 0 // line height
LOCAL pageno := 0
LOCAL printdata := {}
LOCAL justifyarr := {}
LOCAL totrows := getproperty(windowname,gridname,"itemcount")
LOCAL firstrow := 0
LOCAL lastrow := 0
LOCAL size := 0
LOCAL size1 := 0
LOCAL data1 := ""
local sizesarr := {}
local totcol := 0
local maxrow1 := 0
LOCAL maxcol1 := 0.0
local pl := 0
local colcount := 0
local nextline := {}
local count1 := 0
local count2 := 0
local count3 := 0
local cPrintdata := ""
local aec := ""
local aitems := {}
local dataprintover := .t.

if .not. iscontroldefined(browseprintcancel,printgrid)
   return nil
endif

width := printgrid.width.value
height := printgrid.height.value
maxcol1 := curcol1


if maxwidth >= width .and. maxheight >= height
   resize := 1 // resize not required
else
   resize := min(maxwidth/width,maxheight/height)
endif

curx := startx + (maxheight - (height * resize))/2 + 10
cury := starty + (maxwidth - (width * resize))/2 + 10
ERASE WINDOW printgrid
DRAW RECTANGLE IN WINDOW printgrid AT curx,cury	TO curx + (height * resize),cury + (width * resize) FILLCOLOR {255,255,255}

size1 := val(alltrim(printgrid.selectfontsize.item(printgrid.selectfontsize.value)))

maxrow1 := curx + ((printgrid.height.value - printgrid.bottom.value) * resize)
curx := curx+ (printgrid.top.value * resize)
maxcol1 := (maxcol1) * resize
if printgrid.vertical.value
   cury := cury + ((printgrid.width.value - curcol1)/2 * resize)
else
   cury := cury + (printgrid.left.value * resize)
endif

lh := (Int((size1/72 * 25.4)) + 1) * resize // line height
pageno := 1
IF printgrid.pageno.value == 2
   pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
   draw line in window printgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
   curx := curx + lh
ENDIF
IF Len(AllTrim(printgrid.header1.value)) > 0
   pl := printlen(AllTrim(printgrid.header1.value),size1,fontname) * resize
   draw line in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
   curx := curx + lh + lh
ENDIF
IF Len(AllTrim(printgrid.header2.value)) > 0
   pl := printlen(AllTrim(printgrid.header2.value),size1,fontname) * resize
   draw line in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
   curx := curx + lh + lh
ENDIF
IF Len(AllTrim(printgrid.header3.value)) > 0
   pl := printlen(AllTrim(printgrid.header3.value),size1,fontname) * resize
   draw line in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
   curx := curx + lh + lh
ENDIF

firstrow := curx
draw line in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
ASize(printdata,0)
ASize(justifyarr,0)
asize(sizesarr,0)
FOR count1 := 1 TO Len(columnarr)
   IF columnarr[count1,1] == 1
      size := columnarr[count1,3]
      data1 := columnarr[count1,2]
      IF printLen(AllTrim(data1),size1,fontname) <= size
         AAdd(printdata,alltrim(data1))
      ELSE // header size bigger than column! to be truncated.
         count2 := len(data1)
         do while printlen(substr(data1,1,count2),size1,fontname) > size
            count2 := count2 - 1
         enddo
         AAdd(printdata,substr(data1,1,count2))
      ENDIF
      AAdd(justifyarr,columnarr[count1,4])
      aadd(sizesarr,columnarr[count1,3])
   ENDIF
NEXT count1
printpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
curx := curx + lh
draw line in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
FOR count1 := 1 TO totrows
   linedata := getproperty(windowname,gridname,"item",count1)
   ASize(printdata,0)
   asize(nextline,0)
   FOR count2 := 1 TO Len(columnarr)
      IF columnarr[count2,1] == 1
         size := columnarr[count2,3]
         data1 := linedata[count2]
         IF printLen(AllTrim(data1),size1,fontname) <= size
            aadd(printdata,alltrim(data1))
            aadd(nextline,0)
         ELSE
            IF printgrid.wordwrap.value == 2
               count3 := len(data1)
               do while printlen(substr(data1,1,count3),size1,fontname) > size
                  count3 := count3 - 1
               enddo
               AAdd(printdata,substr(data1,1,count3))
               aadd(nextline,0)
            ELSE
               count3 := len(data1)
               do while printlen(substr(data1,1,count3),size1,fontname) > size
                  count3 := count3 - 1
               enddo
               data1 := substr(data1,1,count3)
               if rat(" ",data1) > 0
                  count3 := rat(" ",data1)
               endif
               AAdd(printdata,substr(data1,1,count3))
               aadd(nextline,count3)
            ENDIF
         ENDIF
      ENDIF
   NEXT count2
   printpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
   curx := curx + lh
   dataprintover := .t.
   for count2 := 1 to len(nextline)
      if nextline[count2] > 0
         dataprintover := .f.
      endif
   next count2
   do while .not. dataprintover
      ASize(printdata,0)
      for count2 := 1 to len(columnarr)
         IF columnarr[count2,1] == 1
            size := columnarr[count2,3]
            data1 := linedata[count2]
            if nextline[count2] > 0 //there is some next line
               data1 := substr(data1,nextline[count2]+1,len(data1))
               IF printLen(AllTrim(data1),size1,fontname) <= size
                  aadd(printdata,alltrim(data1))
                  nextline[count2] := 0
               ELSE // there are further lines!
                  count3 := len(data1)
                  do while printlen(substr(data1,1,count3),size1,fontname) > size
                     count3 := count3 - 1
                  enddo
                  data1 := substr(data1,1,count3)
                  if rat(" ",data1) > 0
                     count3 := rat(" ",data1)
                  endif
                  AAdd(printdata,substr(data1,1,count3))
                  nextline[count2] := nextline[count2]+count3
               ENDIF
            else
               AAdd(printdata,"")
               nextline[count2] := 0
            endif
         endif
      next count2
      printpreviewline(curx+(lh/2),cury,printdata,justifyarr,sizesarr,fontname,size1,resize)
      curx := curx + lh
      dataprintover := .t.
      for count2 := 1 to len(nextline)
         if nextline[count2] > 0
            dataprintover := .f.
         endif
      next count2
   enddo

   IF curx+lh >= maxrow1
      draw line in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
      lastrow := curx
      totcol := 0
      draw line in window printgrid at firstrow,cury to lastrow,cury
      IF printgrid.collines.value
         colcount := 0
         for count2 := 1 to len(columnarr)
            IF columnarr[count2,1] == 1
               colcount := colcount + 1
               totcol := totcol + columnarr[count2,3]
               draw line in window printgrid at firstrow,cury+(totcol+(colcount * 2)-1) * resize to lastrow,cury+(totcol+(colcount * 2)-1) * resize
            ENDIF
         next count2
      ENDIF
      draw line in window printgrid at firstrow,cury+maxcol1-(1*resize) to lastrow,cury+maxcol1-(1*resize)
      IF Len(AllTrim(printgrid.footer1.value)) > 0
         pl := printlen(AllTrim(printgrid.footer1.value),size1,fontname) * resize
         draw line in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
         curx := curx + lh + lh
      ENDIF
      IF printgrid.pageno.value == 3
         pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
         draw line in window printgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
         curx := curx + lh
      ENDIF
      count1 := totrows
   ELSE
      IF printgrid.rowlines.value
         draw line in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
      ENDIF
   ENDIF
NEXT count1
draw line in window printgrid at curx,cury to curx,cury+maxcol1-(1*resize)
lastrow := curx
totcol := 0
colcount := 0
draw line in window printgrid at firstrow,cury to lastrow,cury
IF printgrid.collines.value
   for count1 := 1 to len(columnarr)
      IF columnarr[count1,1] == 1
         totcol := totcol + columnarr[count1,3]
         colcount := colcount + 1
         draw line in window printgrid at firstrow,cury+(totcol+(colcount * 2)-1) * resize to lastrow,cury+(totcol+(colcount * 2)-1) * resize
      ENDIF
   next count1
ENDIF
draw line in window printgrid at firstrow,cury+maxcol1-(1*resize) to lastrow,cury+maxcol1-(1*resize)
IF Len(AllTrim(printgrid.footer1.value)) > 0
   pl := printlen(AllTrim(printgrid.footer1.value),size1,fontname) * resize
   draw line in window printgrid at curx+(lh/2),cury + ((maxcol1 - pl)/2) to curx+(lh/2),cury + ((maxcol1 - pl)/2) + pl
   curx := curx + lh + lh
ENDIF
IF printgrid.pageno.value == 3
   pl := printlen(msgarr[49]+alltrim(str(pageno,10,0)),size1,fontname)*resize
   draw line in window printgrid at curx,cury+maxcol1 - pl to curx,cury+maxcol1
   curx := curx + lh
ENDIF
return nil


function printpreviewline(row,col,aitems,ajustify,sizesarr,fontname,size1,resize)
local tempcol := 0
local count1 := 0
local pl := 0
local njustify
if len(aitems) <> len(ajustify)
   msginfo(msgarr[53])
ENDIF
tempcol := col
for count1 := 1 to len(aitems)
   njustify := ajustify[count1]
   pl := printlen(AllTrim(aitems[count1]),size1,fontname) * resize
   do case
      case njustify == 0 //left
         draw line in window printgrid at row,tempcol to row,tempcol+pl
      case njustify == 1 //right
         draw line in window printgrid at row,tempcol+((sizesarr[count1] + 2) * resize)-pl to row,tempcol+((sizesarr[count1] + 2) * resize)
      case njustify == 2 //center not implemented
         draw line in window printgrid at row,tempcol to row,tempcol+pl
   end case
   tempcol := tempcol + ((sizesarr[count1] + 2) * resize)
next count1
return nil
