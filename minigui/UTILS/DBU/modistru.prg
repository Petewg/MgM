#include "minigui.ch"
#include "dbuvar.ch"

function DBUmodistruct
if len(alltrim(_DBUfname)) == 0 .or. .not. used()
   return NIL
elseif IsWindowDefined( _DBUBrowse ) .or. IsWindowDefined( _DBUedit ) // (P.D. 21-06-2005)
   msgStop( 'Structure change not allowed' + HB_OSNewLine() + ;
            'while browsing or editing records!',;
            'DBU Modify structure' )
   return nil
endif
_DBUoriginalarr := dbstruct()
_DBUstructarr := dbstruct()
_DBUdbfsaved := .f.
define window _DBUcreadbf at 0,0 width 600 height 500 title "Modify DataBase Table" modal nosize nosysmenu
   define frame _DBUcurfield
      row 10
      col 10
      width 550
      height 150
//      backcolor _DBUgreenish
      caption "Field"
   end frame
   define label _DBUnamelabel
      row 40
      col 40
      width 150
      backcolor _DBUgreenish
      value "Name"
   end label
   define label _DBUtypelabel
      row 40
      col 195
      width 100
      backcolor _DBUgreenish
      value "Type"
   end label
   define label _DBUsizelabel
      row 40
      col 300
      width 100
      backcolor _DBUgreenish
      value "Size"
   end label
   define label _DBUdecimallabel
      row 40
      col 405
      backcolor _DBUgreenish
      width 100
      value "Decimals"
   end label
   define textbox _DBUfieldname
      row 70
      col 40
      width 150
      uppercase .t.
      backcolor _DBUgreenish
      maxlength 10
      value ""
   end textbox
   define combobox _DBUfieldtype
      row 70
      col 195
      items {"Character","Numeric","Date","Logical","Memo"}
      width 100
      value 1
      on lostfocus DBUtypelostfocus()
      on enter DBUtypelostfocus()
*      on change typelostfocus()
   end combobox
   define textbox _DBUfieldsize
      row 70
      col 300
      backcolor _DBUgreenish
      value 10
      numeric .t.
      width 100
      on lostfocus DBUsizelostfocus()
      rightalign .t.
   end textbox
   define textbox _DBUfielddecimals
      row 70
      col 405
      value 0
      backcolor _DBUgreenish
      numeric .t.
      width 100
      on lostfocus DBUdeclostfocus()
      rightalign .t.
   end textbox
   define button _DBUaddline
      row 120
      col 75
      caption "Add"
      width 100
      action DBUaddstruct()
   end button
   define button _DBUinsline
      row 120
      col 225
      caption "Insert"
      width 100
      action DBUinsstruct()
   end button
   define button _DBUdelline
      row 120
      col 400
      caption "Delete"
      width 100
      action DBUdelstruct()
   end button
   define frame _DBUstructframe
      row 190
      col 10
      caption "Structure of DBF"
      width 500
      height 180
   end frame
   define grid _DBUstruct
      row 220
      col 40
      headers {"Name","Type","Size","Decimals"}
      justify {0,0,1,1}
      widths {150,100,100,75}
      width 450
      backcolor _DBUyellowish
      items _DBUstructarr
      on dblclick DBUlineselected()
      height 120
   end grid
   define button _DBUsavestruct
      row 400
      col 200
      caption "Modify"
      action DBUmodistructure()
   end button
   define button _DBUexitnew
      row 400
      col 400
      caption "Exit"
      action DBUexitmodidbf()
   end button
end window
center window _DBUcreadbf
_DBUcreadbf._DBUstruct.deleteallitems()
for _DBUi := 1 to len(_DBUstructarr)
   do case
      case _DBUstructarr[_DBUi,2] == "C"
         _DBUtype1 := "Character"
      case _DBUstructarr[_DBUi,2] == "N"
         _DBUtype1 := "Numeric"
      case _DBUstructarr[_DBUi,2] == "D"
         _DBUtype1 := "Date"
      case _DBUstructarr[_DBUi,2] == "L"
         _DBUtype1 := "Logical"
      case _DBUstructarr[_DBUi,2] == "M"
         _DBUtype1 := "Memo"
   end case
   _DBUcreadbf._DBUstruct.additem({_DBUstructarr[_DBUi,1],;
                          _DBUtype1,;
           str(_DBUstructarr[_DBUi,3],8,0),;
             str(_DBUstructarr[_DBUi,4],3,0)})
next _DBUi
if len(_DBUstructarr) > 0
   _DBUcreadbf._DBUstruct.value := len(_DBUstructarr)
endif
activate window _DBUcreadbf
return nil


function DBUmodistructure
local ldeleted
if .not. msgyesno("Caution: If you had modified either the field name or the field type, the data for that fields can not be saved in the modified dbf. However, a backup file (.bak) will be created. Are you sure to modify the structure?","DBU")
   return nil
endif
_DBUmodarr := {}
for _DBUi := 1 to len(_DBUstructarr)
   if _DBUi <= len(_DBUoriginalarr)
      _DBUline := ascan(_DBUoriginalarr,{|_DBUx|upper(alltrim(_DBUx[1])) == upper(alltrim(_DBUstructarr[_DBUi,1]))})
      if _DBUline > 0
         if _DBUoriginalarr[_DBUline,2] == _DBUstructarr[_DBUi,2]
            aadd(_DBUmodarr,_DBUi)
         endif
      endif
   endif
next _DBUi
_DBUfname1 := "DBUtemp"
if len(_DBUstructarr) > 0
   _DBUfname1 := "DBUtemp"
   if len(_DBUfname1) > 0
      dbcreate(_DBUfname1,_DBUstructarr)
      close all
      select b
      use &_DBUfname
      select c
      use &_DBUfname1
      select b
      go top
      if len(_DBUmodarr) > 0
         do while .not. eof()
            ldeleted := deleted()
            select c
            append blank
            for _DBUi := 1 to len(_DBUmodarr)
               _DBUfieldname := _DBUstructarr[_DBUmodarr[_DBUi],1]
               replace c->&_DBUfieldname with b->&_DBUfieldname
            next _DBUi
            if ldeleted
               delete
            endif
            select b
            skip
         enddo
      endif
      select b
      close
      select c
      close
      if at(".",_DBUfname) == 0
         _DBUbackname := alltrim(_DBUfname)+".dbf"
         if file(_DBUbackname)
            if file(alltrim(_DBUfname)+".bak")
              ferase(alltrim(_DBUfname)+".bak")
            endif
            frename(_DBUbackname,alltrim(_DBUfname)+".bak")
            frename('DBUtemp.dbf',alltrim(_DBUfname)+".dbf")
         endif
      else
         _DBUnewname := substr(alltrim(_DBUfname),1,at(".",_DBUfname)-1)+".bak"
         if file(_DBUfname)
            if file(_DBUnewname)
               ferase(_DBUnewname)
            endif
            frename(_DBUfname,_DBUnewname)
            frename('DBUtemp.dbf',alltrim(_DBUfname))
         endif
      endif
      close all
      use &_DBUfname
      DBUtogglemenu()
      release window _DBUcreadbf
   endif
endif
return nil

function DBUexitmodidbf
if len(_DBUstructarr) == 0 .or. _DBUdbfsaved
   DBUtogglemenu()
   release window _DBUcreadbf
else
   if msgyesno("Are you sure to abort Modifying this dbf?","DBU")
      DBUtogglemenu()
      release window _DBUcreadbf
   endif
endif
return nil
