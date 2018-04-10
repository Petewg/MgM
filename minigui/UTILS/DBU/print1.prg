#include "minigui.ch"
#include "winprint.ch"
#include "dbuvar.ch"

function DBUeditprint
local _t, _l, _b, _r
set century on
if .not. used()
   return nil
endif
init printsys
select by dialog preview
_t := (GetDesktopHeight() - 699) / 2
_l := (GetDesktopWidth() - 499) / 2
_b := GetDesktopHeight() - _t
_r := GetDesktopWidth() - _l
set preview rect _t, _l, _b, _r
define font "f0" name "Courier New" size 12
select font "f0"
start doc
   set page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
   start page
   _DBUmaxrow1 := hbprnmaxrow - 3
   _DBUmaxcol1 := hbprnmaxcol - 5
   _DBUrow := 3
   _DBUcol := 5
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol say "Current Record Number   : "+alltrim(str(recno(),10,0)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   _DBUstructarr := dbstruct()
   _DBUfieldnamearr := {}
   for _DBUi := 1 to len(_DBUstructarr)
      aadd(_DBUfieldnamearr,alltrim(_DBUstructarr[_DBUi,1]))
   next _DBUi
   _DBUlongest := bigelem(_DBUfieldnamearr)
   for _DBUi := 1 to len(_DBUfieldnamearr)
      do case
         case _DBUstructarr[_DBUi,2] == "C"
            @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+alltrim(&(_DBUfieldnamearr[_DBUi])) to print
         case _DBUstructarr[_DBUi,2] == "D"
            @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+dtoc(&(_DBUfieldnamearr[_DBUi])) to print
         case _DBUstructarr[_DBUi,2] == "L"
            @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+iif(&(_DBUfieldnamearr[_DBUi]),"True","False") to print
         case _DBUstructarr[_DBUi,2] == "N"
            @ _DBurow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+alltrim(str(&(_DBUfieldnamearr[_DBUi]),_DBUstructarr[_DBUi,3],_DBUstructarr[_DBUi,4])) to print
         case _DBUstructarr[_DBUi,2] == "M"
            @ _DBUrow,_DBUcol say _DBUfieldnamearr[_DBUi] + space(_DBUlongest - len(alltrim(_DBUfieldnamearr[_DBUi])))+" : "+"Memo" to print
      end case
      _DBUrow := _DBUrow + 1                  
      if _DBUrow >= _DBUmaxrow
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
         end page
         start page
         _DBUrow := 3
      endif         
   next _DBUi
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   end page
end doc
release printsys
return nil


function DBUbrowseprint
if .not. used()
   return nil
endif
init printsys
get printers to _DBUavailableprinters
get default printer to _DBUcurrentprinter
select default
start doc
define font "f0" name "Courier New" size 12
set page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
_DBUmaxportraitcol := hbprnmaxcol - 4
set page orientation DMORIENT_LANDSCAPE paperSize DMPAPER_A4 font "f0"
_DBUmaxlandscapecol := hbprnmaxcol - 4
end doc
release printsys
_DBUfontsizesstr := {"8","9","10","11","12","14","16","18","20","22","24","26","28","36","48","72"}
_DBUmaxcol1 := _DBUmaxlandscapecol
_DBUstructarr := dbstruct()
_DBUfieldnamearr := {}
_DBUfieldsizearr := {}
for _DBUi := 1 to len(_DBUstructarr)
   aadd(_DBUfieldnamearr,alltrim(_DBUstructarr[_DBUi,1]))
   if _DBUstructarr[_DBUi,2] <> "M"
      aadd(_DBUfieldsizearr,iif(len(alltrim(_DBUstructarr[_DBUi,1])) > _DBUstructarr[_DBUi,3],len(alltrim(_DBUstructarr[_DBUi,1])),_DBUstructarr[_DBUi,3]))
   else
      aadd(_DBUfieldsizearr,len(alltrim(_DBUstructarr[_DBUi,1])))
   endif
next _DBUi
define window _DBUprintfields at 0,0 width 800 height 540 title "Select Print Fields" modal nosize nosysmenu
   define label _DBUtotfieldslab
      row 30
      col 30
      value "Fields in the dbf"
      width 200
      fontbold .t.
   end label
   define listbox _DBUfields
      row 60
      col 30
      width 200
      height 400
      items _DBUfieldnamearr
      multiselect .t.
   end listbox
   define button _DBUfieldadd
      row 100
      col 260
      caption "Add"
      width 100
      action DBUprintfieldsadd()
   end button
   define button _DBUfieldremove
      row 140
      col 260
      caption "Remove"
      width 100
      action DBUprintfieldremove()
   end button
   define button _DBUfieldaddall
      row 180
      col 260
      caption "Add All"
      width 100
      action DBUprintfieldaddall()
   end button
   define button _DBUfieldremoveall
      row 220
      col 260
      caption "Remove All"
      width 100
      action (_DBUprintfields._DBUselectedfields.deleteallitems,DBUprintcoltally())
   end button
   define label _DBUselectedfieldslabel
      row 30
      col 390
      width 200
      value "Selected Fields"
      fontbold .t.
   end label
   define listbox _DBUselectedfields
      row 60
      col 390
      width 200
      height 400
      multiselect .t.
   end listbox
   define label _DBUorientationlabel
      row 30
      col 600
      value "Orientation"
      width 150
      fontbold .t.
   end label
   define radiogroup _DBUpaperorientation
      row 60
      col 600
      width 150
      height 100
      options {"Landscape","Portrait"}
      on change DBUorientationchange()
      value 1
   end radiogroup
   define label _DBUselectprinterlabel
      row 170
      col 600
      value "Select Printer"
      width 150
      fontbold .t.
   end label
   define listbox _DBUprinters
      row 200
      col 600
      width 150
      height 100
      items _DBUavailableprinters
      value ascan(_DBUavailableprinters,_DBUcurrentprinter)
   end listbox
   define label _DBUselectfontsizelabel
      row 310
      col 600
      value "Font Size"
      width 150
      fontbold .t.
   end label
   define listbox _DBUselectfontsize
      row 340
      col 600
      width 150
      height 100
      items _DBUfontsizesstr
      on change DBUfontsizechanged()
      value 5
   end listbox
   define button _DBUbrowseprint1
      row 260
      col 260
      caption "Print"
      action DBUprintstart()
      width 100
   end button
   define button _DBUbrowseprintcancel
      row 300
      col 260
      caption "Cancel"
      action _DBUprintfields.release
      width 100
   end button
   define label _DBUmaxcollabel
      row 470
      col 30
      width 200
      value "Maximum Print Columns:" 
      fontbold .t.
   end label   
   define textbox _DBUmaximumcol
      row 470
      col 240
      width 50
      readonly .t.
      value _DBUmaxcol1
      numeric .t.
      rightalign .t.
   end textbox
   define label _DBUcurrentcollabel
      row 470
      col 300
      width 200
      value "Current Print Columns:"
      fontbold .t.
   end label
   define textbox _DBUcurrentcol
      row 470
      col 510
      width 50
      readonly .t.
      value 2
      numeric .t.
      rightalign .t.
   end textbox
end window
DBUprintcoltally()
_DBUprintfields.center
_DBUprintfields.activate
return nil

function DBUprintfieldsadd
local _DBUselfields1 := _DBUprintfields._DBUfields.value
if len(_DBUselfields1) == 0
   return nil
endif
for _DBUi := 1 to len(_DBUselfields1)
   _DBUfieldfound := .f.
   for _DBUj := 1 to _DBUprintfields._DBUselectedfields.itemcount
      if upper(alltrim(_DBUprintfields._DBUselectedfields.item(_DBUj))) == upper(alltrim(_DBUprintfields._DBUfields.item(_DBUselfields1[_DBUi])))
         _DBUfieldfound := .t.
      endif
   next _DBUj
   if .not. _DBUfieldfound
      _DBUprintfields._DBUselectedfields.additem(_DBUprintfields._DBUfields.item(_DBUselfields1[_DBUi]))
   endif
next _DBUi
DBUprintcoltally()
return nil

function DBUprintfieldremove
local _DBUselfields1 := _DBUprintfields._DBUselectedfields.value
if len(_DBUselfields1) == 0
   DBUprintcoltally()
   return nil
endif
for _DBUi := len(_DBUselfields1) to 1 step -1
   _DBUprintfields._DBUselectedfields.deleteitem(_DBUselfields1[_DBUi])
next _DBUi
DBUprintcoltally()
return nil


function DBUprintfieldaddall
_DBUprintfields._DBUselectedfields.deleteallitems
for _DBUi := 1 to _DBUprintfields._DBUfields.itemcount
   _DBUprintfields._DBUselectedfields.additem(_DBUprintfields._DBUfields.item(_DBUi))
next _DBUi
DBUprintcoltally()
return nil

function DBUprintcoltally
_DBUstructarr := dbstruct()
_DBUcol := 2
for _DBUi := 1 to _DBUprintfields._DBUselectedfields.itemcount
   _DBUpos := ascan(_DBUstructarr,{|x|upper(alltrim(x[1])) == upper(alltrim(_DBUprintfields._DBUselectedfields.item(_DBUi)))})
   if _DBUpos > 0
      _DBUcol := _DBUcol + 2 + iif(_DBUstructarr[_DBUpos,2] <> "M",max(len(alltrim(_DBUstructarr[_DBUpos,1])),_DBUstructarr[_DBUpos,3]),max(len(alltrim(_DBUstructarr[_DBUpos,1])),6))
   endif
next _DBUi
_DBUprintfields._DBUcurrentcol.value := _DBUcol
if _DBUprintfields._DBUselectedfields.itemcount > 0 
   if _DBUprintfields._DBUmaximumcol.value >= _DBUprintfields._DBUcurrentcol.value
      _DBUprintfields._DBUbrowseprint1.enabled := .t.
   else
      msgalert("You had selected more fields than to fit in a the page!","Warning")
      _DBUprintfields._DBUbrowseprint1.enabled := .f.
      return nil
   endif
else
   _DBUprintfields._DBUbrowseprint1.enabled := .f.
endif
return nil

function DBUorientationchange
if _DBUprintfields._DBUpaperorientation.value == 1
   _DBUprintfields._DBUmaximumcol.value := _DBUmaxlandscapecol   
else
   _DBUprintfields._DBUmaximumcol.value := _DBUmaxportraitcol   
endif
DBUprintcoltally()
return nil

function DBUfontsizechanged
init printsys
select default
start doc
define font "f0" name "Courier New" size val(alltrim(_DBUprintfields._DBUselectfontsize.item(_DBUprintfields._DBUselectfontsize.value)))
set page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
_DBUmaxportraitcol := hbprnmaxcol - 4
set page orientation DMORIENT_LANDSCAPE paperSize DMPAPER_A4 font "f0"
_DBUmaxlandscapecol := hbprnmaxcol - 4
end doc
release printsys
DBUorientationchange()
return nil


function DBUprintstart
local _t, _l, _b, _r
set century on
_DBUstructarr := dbstruct()
_DBUselectedstructarr := {}
for _DBUi := 1 to _DBUprintfields._DBUselectedfields.itemcount
   _DBUpos := ascan(_DBUstructarr,{|x|upper(alltrim(x[1])) == upper(alltrim(_DBUprintfields._DBUselectedfields.item(_DBUi)))})
   aadd(_DBUselectedstructarr,_DBUstructarr[_DBUpos])
next _DBUi
_DBUrow := 3
_DBUcol := 2
_DBUmaxcol1 := _DBUCol
_DBUheadingarr := {}
_DBUjustifyarr := {}
_DBUlinesrefarr := {}
for _DBUi := 1 to len(_DBUselectedstructarr) 
   _DBUlongest := iif(_DBUselectedstructarr[_DBUi,2] <> "M",max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),_DBUselectedstructarr[_DBUi,3]),max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),6))
   do case
      case _DBUselectedstructarr[_DBUi,2] == "N"
         aadd(_DBUjustifyarr,1)
         aadd(_DBUheadingarr,space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+alltrim(_DBUselectedstructarr[_DBUi,1])+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      case _DBUselectedstructarr[_DBUi,2] == "C"
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      case _DBUselectedstructarr[_DBUi,2] == "L"
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      case _DBUselectedstructarr[_DBUi,2] == "D"
         if _DBUlongest < 10
            _DBUlongest := 10
         endif
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - len(alltrim(_DBUselectedstructarr[_DBUi,1])))+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
      case _DBUselectedstructarr[_DBUi,2] == "M"
         aadd(_DBUjustifyarr,0)
         aadd(_DBUheadingarr,alltrim(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - 6)+"  ")
         _DBUmaxcol1 := _DBUmaxcol1 + _DBUlongest + 2
   endcase
   aadd(_DBUlinesrefarr,_DBUmaxcol1 - iif(_DBUi == len(_DBUselectedstructarr),0,1))
next _DBUi
init printsys
select printer alltrim(_DBUprintfields._DBUprinters.item(_DBUprintfields._DBUprinters.value)) preview
_t := (GetDesktopHeight() - 599) / 2
_l := (GetDesktopWidth() - 799) / 2
_b := GetDesktopHeight() - _t
_r := GetDesktopWidth() - _l
set preview rect _t, _l, _b, _r
enable thumbnails
define font "f0" name "Courier New" size val(alltrim(_DBUprintfields._DBUselectfontsize.item(_DBUprintfields._DBUselectfontsize.value)))
select font "f0"
if _DBUprintfields._DBUpaperorientation.value == 1
   set page orientation DMORIENT_LANDSCAPE paperSize DMPAPER_A4 font "f0"
else
   set page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
endif   
start doc
//_DBUmaxcol1 := hbprnmaxcol - 10
_DBUmaxrow1 := hbprnmaxrow - 6
start page
   _DBUpageno := 1
   @ _DBUrow,_DBUmaxcol1 - 20 say "Page No. : "+alltrim(str(_DBUpageno,10,0)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
   _DBUrow := _DBUrow + 1
   _DBUfirstrow := _DBUrow
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
   _DBUrow := _DBUrow + 1
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   _DBUcurrentrecordarr := {}
   _DBUcurrec := recno()
   go top
   do while .not. eof()
      asize(_DBUcurrentrecordarr,0)
      for _DBUi := 1 to len(_DBUselectedstructarr)
         _DBUlongest := iif(_DBUselectedstructarr[_DBUi,2] <> "M",max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),_DBUselectedstructarr[_DBUi,3]),max(len(alltrim(_DBUselectedstructarr[_DBUi,1])),6))
         do case
            case _DBUselectedstructarr[_DBUi,2] == "C"
               aadd(_DBUcurrentrecordarr,&(_DBUselectedstructarr[_DBUi,1])+space(_DBUlongest - _DBUselectedstructarr[_DBUi,3])+"  ")
            case _DBUselectedstructarr[_DBUi,2] == "N"
               aadd(_DBUcurrentrecordarr,space(_DBUlongest - _DBUselectedstructarr[_DBUi,3])+str(&(_DBUselectedstructarr[_DBUi,1]),_DBUselectedstructarr[_DBUi,3],_DBUselectedstructarr[_DBUi,4])+"  ")
            case _DBUselectedstructarr[_DBUi,2] == "L"
               aadd(_DBUcurrentrecordarr,iif(&(_DBUselectedstructarr[_DBUi,1]),"T","F")+space(_DBUlongest - _DBUselectedstructarr[_DBUi,3])+"  ")
            case _DBUselectedstructarr[_DBUi,2] == "D"
               if _DBUlongest < 10
                  _DBUlongest := 10
               endif
               aadd(_DBUcurrentrecordarr,dtoc(&(_DBUselectedstructarr[_DBUi,1]))+space(_DBUlongest - (_DBUselectedstructarr[_DBUi,3]+2))+"  ")
            case _DBUselectedstructarr[_DBUi,2] == "M"
               aadd(_DBUcurrentrecordarr,"<Memo>"+space(_DBUlongest - 6)+"  ")
         end case      
      next _DBUi   
      DBUprintline(_DBUrow,_DBUcol,_DBUcurrentrecordarr,_DBUjustifyarr,"f0")
      _DBUrow := _DBUrow + 1
      if _DBUrow >= _DBUmaxrow1
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
         _DBUlastrow := _DBUrow
         @ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
         for _DBUi := 1 to len(_DBUlinesrefarr)
            @ _DBUfirstrow,_DBUlinesrefarr[_DBUi],_DBUlastrow,_DBUlinesrefarr[_DBUi] line
         next _DBUi
         _DBUpageno := _DBUpageno + 1
         _DBUrow := 3   
         end page
         start page
         @ _DBUrow,_DBUmaxcol1 - 20 say "Page No. : "+alltrim(str(_DBUpageno,10,0)) to print
         _DBUrow := _DBUrow + 1
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
         @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
         _DBUrow := _DBUrow + 1
         @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
         _DBUrow := _DBUrow + 1
         _DBUfirstrow := _DBUrow
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
         DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
         _DBUrow := _DBUrow + 1
         @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      endif
      skip
   enddo
   dbgoto(_DBUcurrec)
   @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   _DBUlastrow := _DBUrow
   @ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
   for _DBUi := 1 to len(_DBUlinesrefarr)
      @ _DBUfirstrow,_DBUlinesrefarr[_DBUi],_DBUlastrow,_DBUlinesrefarr[_DBUi] line
   next _DBUi
end page
end doc
release printsys
_DBUprintfields.release
return nil


function DBUprintstruct
local _t, _l, _b, _r
if .not. used()
   return nil
endif
init printsys
select by dialog preview
_t := (GetDesktopHeight() - 699) / 2
_l := (GetDesktopWidth() - 499) / 2
_b := GetDesktopHeight() - _t
_r := GetDesktopWidth() - _l
set preview rect _t, _l, _b, _r
define font "f0" name "Courier New" size 12
select font "f0"
start doc
set page orientation DMORIENT_PORTRAIT paperSize DMPAPER_A4 font "f0"
start page
_DBUmaxrow1 := hbprnmaxrow - 3
_DBUmaxcol1 := 40
_DBUrow := 3
_DBUcol := 2
@ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
@ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
_DBUrow := _DBUrow + 1
@ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
_DBUrow := _DBUrow + 1

_DBUheadingarr := {"Field Name  ","Type       ","Size   ","Decimals  "}
_DBUjustifyarr := {0,0,1,1}
_DBUlinesrefarr := {13,24,31,40}
_DBUstructarr := dbstruct()
@ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
_DBUfirstrow := _DBUrow
DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
_DBUrow := _DBUrow + 1
@ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
_DBUtype1 := ""
for _DBUi := 1 to len(_DBUstructarr)
   do case
      case _DBUstructarr[_DBUi,2] == "C"
         _DBUtype1 := "Character"
      case _DBUstructarr[_DBUi,2] == "N"
         _DBUtype1 := "Numeric  "
      case _DBUstructarr[_DBUi,2] == "L"
         _DBUtype1 := "Logical  "
      case _DBUstructarr[_DBUi,2] == "D"
         _DBUtype1 := "Date     "
      case _DBUstructarr[_DBUi,2] == "M"
         _DBUtype1 := "Memo     "
   endcase         
   DBUprintline(_DBUrow,_DBUcol,{_DBUStructarr[_DBUi,1]+space(10 - len(alltrim(_DBUstructarr[_DBUi,1])))+"  ",;
                                 _DBUtype1+"  ",;
                                 str(_DBUstructarr[_DBUi,3],5,0)+"  ",;
                                 str(_DBUstructarr[_DBUi,4],5,0)+"  "},_DBUjustifyarr,"f0")
   _DBUrow := _DBUrow + 1
   if _DBUrow >= _DBUmaxrow1
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      _DBUlastrow := _DBUrow
      @ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
      for _DBUj := 1 to len(_DBUlinesrefarr)
         @ _DBUfirstrow,_DBUlinesrefarr[_DBUj],_DBUlastrow,_DBUlinesrefarr[_DBUj] line
      next _DBUj
      _DBUpageno := _DBUpageno + 1
      _DBUrow := 3   
      end page
      start page
      @ _DBUrow,_DBUmaxcol1 - 20 say "Page No. : "+alltrim(str(_DBUpageno,10,0)) to print
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      @ _DBUrow,_DBUcol say "File Name               : "+cFileNoPath(alltrim(_DBUfname)) to print
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol say "Total Number of Records : "+alltrim(str(reccount(),10,0)) to print
      _DBUrow := _DBUrow + 1
      _DBUfirstrow := _DBUrow
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
      DBUprintline(_DBUrow,_DBUcol,_DBUheadingarr,_DBUjustifyarr,"f0")
      _DBUrow := _DBUrow + 1
      @ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
   endif
next _DBUi
@ _DBUrow,_DBUcol,_DBUrow,_DBUmaxcol1 line
_DBUlastrow := _DBUrow
@ _DBUfirstrow,_DBUcol,_DBUlastrow,_DBUcol line
for _DBUi := 1 to len(_DBUlinesrefarr)
   @ _DBUfirstrow,_DBUlinesrefarr[_DBUi],_DBUlastrow,_DBUlinesrefarr[_DBUi] line
next _DBUi
end page
end doc
release printsys
return nil
      

/*
===============================================================
| FUNCTION BIGELEM()
===============================================================
| 
|  Short:
|  ------
|  BIGELEM() Returns length of longest string in an array
| 
|  Returns:
|  --------
|  <nLength> => Length of longest string in an array
| 
|  Syntax:
|  -------
|  BIGELEM(aTarget)
| 
|  Description:
|  ------------
|  Determines the length of the longest string element
|  in <aTarget> Array may have mixed types
| 
|  Examples:
|  ---------
|   ?BIGELEM(  {"1","22","333"}  )  => returns 3
| 
|  Notes:
|  -------
|  This was a C function in previous SuperLibs
| 
|  Source:
|  -------
|  S_BIGEL.PRG
| 
===============================================================*/
Function BIGELEM(aArray)
local nLongest := 0
local nIterator
for nIterator = 1 to len(aArray)
   if valtype(aArray[nIterator])=="C"
     nLongest := max(nLongest,len(aArray[nIterator]))
   endif
next
return nLongest


function DBUprintline(row,col,aitems,ajustify,currentfont)
local tempcol := 0
local i
local oldstyle
local njustify
if len(aitems) <> len(ajustify)
   msgalert("Justification constants not given properly.","Warning")
endif
tempcol := col
get text align to oldstyle
for i := 1 to len(aitems)
   njustify := ajustify[i]
   do case
      case njustify == 0
         set text align left
      case njustify == 1
         set text align right
      case njustify == 2
         set text align center
   end case
   @ row,iif(njustify == 1,tempcol + len(aitems[i]),tempcol) say aitems[i] font currentfont to print
   tempcol := tempcol + len(aitems[i])
next i
set text align oldstyle
return nil
