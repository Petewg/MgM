# include "minigui.ch"

function grid2csv(windowname,gridname,lheader)

local filename := ""
local adata := {}
local lines := 0
local i, count2
local aeditcontrols := {}
local count1 := 0
local linedata := {}
local xres, aec, aitems
local cdata := ""
local aclinedata := {}
local fhandle := 0
local linebreak := chr(13)
local aline := {}
local cline := ''
local ncolumns := 0
default lheader := .f.

filename :=  PutFile ( {{"Comma Separated Value Files (*.csv)","*.csv"}} , "Export to text file (CSV)" ,  , .f. ) 
if len(alltrim(filename)) == 0
   return nil
endif

if at(".csv",lower(filename)) > 0
   if .not. right(lower(filename),4) == ".csv"
      filename := filename + ".csv"
   endif
else
   filename := filename + ".csv"
endif

if file(filename)
   if .not. msgyesno("Are you sure to overwrite?","Export to text file (CSV)")
      return nil
   endif
endif

fhandle := fcreate(filename)
if fhandle < 0
   msgstop("File "+filename+" could not be created!")
   return nil
endif


lines := getproperty(windowname,gridname,"itemcount")
IF lines == 0
   msginfo("No rows to save!")
   RETURN nil
ENDIF

i := GetControlIndex ( gridname , windowname )

aEditcontrols := _HMG_aControlMiscData1 [i] [13]

if lheader
   asize(aclinedata,0)
   ncolumns := len(getproperty(windowname,gridname,"item",1))
   for count1 := 1 to ncolumns
      cdata := getproperty(windowname,gridname,"header",count1)
      aadd(aclinedata,cdata)
   next count1
   aadd(adata,aclone(aclinedata))
endif

for count1 := 1 to lines
   linedata := getproperty(windowname,gridname,"item",count1)
   asize(aclinedata,0)
   for count2 := 1 to len(linedata)
      do case
         case ValType(linedata[count2]) == "N"
            xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
            AEC := XRES [1]
            AITEMS := XRES [5]
            IF AEC == 'COMBOBOX'
               cdata := aitems[linedata[count2]]
            else
               cdata := LTrim( Str( linedata[count2] ) )
            ENDIF
         case ValType(linedata[count2]) == "D"
            cdata := dtoc( linedata[count2])
         case ValType(linedata[count2]) == "L"
            xres := _PARSEGRIDCONTROLS ( AEDITCONTROLS , count2 )
            AEC := XRES [1]
            AITEMS := XRES [8]
            IF AEC == 'CHECKBOX'
               cdata := iif(linedata[count2],aitems[1],aitems[2])
            else
               cdata := iif(linedata[count2],"TRUE","FALSE")
            endif
         otherwise
            cdata := linedata[count2]
      endcase
      aadd(aclinedata,cdata)
   next count2
   aadd(adata,aclone(aclinedata))
next count1
for count1 := 1 to len(adata)
   cline := ''
   aline := adata[count1]
   for count2 := 1 to len(aline)
      cline := cline + '"' + _parsequote(aline[count2]) + '"'
      if .not. count2 == len(aline)
         cline := cline + ','
      endif
   next count2
   cline := cline + linebreak
   fwrite(fhandle,cline)
next count1
if fclose(fhandle)
   msginfo("Exported Successfully!")
else
   msgstop("Error in saving!")
endif
return nil
         

function _parsequote(cdata)
local i := 0
local cout := ""
for i := 1 to len(cdata)
   if substr(cdata,i,1) == '"'
      cout := cout + substr(cdata,i,1) + '"'
   else
      cout := cout + substr(cdata,i,1)
   endif
next i
return cout   