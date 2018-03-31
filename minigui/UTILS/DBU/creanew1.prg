#include "minigui.ch"
#include "dbuvar.ch"

function DBUcreanew
_DBUstructarr := {}
_DBUdbfsaved := .f.
define window _DBUcreadbf at 0,0 width 600 height 500 title "Create a New DataBase Table (.dbf)" modal nosize nosysmenu
   define frame _DBUcurfield
      row 10
      col 10
      width 550
      height 150
      caption "Field"
   end frame
   define label _DBUnamelabel
      row 40
      col 40
      width 150
      backcolor _DBUreddish
      value "Name"
   end label
   define label _DBUtypelabel
      row 40
      col 195
      backcolor _DBUreddish
      width 100
      value "Type"
   end label
   define label _DBUsizelabel
      row 40
      col 300
      backcolor _DBUreddish
      width 100
      value "Size"
   end label
   define label _DBUdecimallabel
      row 40
      col 405
      backcolor _DBUreddish
      width 100
      value "Decimals"
   end label
   define textbox _DBUfieldname
      row 70
      col 40
      width 150
      backcolor _DBUreddish
      uppercase .t.
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
*      on change DBUtypelostfocus()
   end combobox
   define textbox _DBUfieldsize
      row 70
      col 300
      backcolor _DBUreddish
      value 10
      numeric .t.
      width 100
      on lostfocus DBUsizelostfocus()
      rightalign .t.
   end textbox
   define textbox _DBUfielddecimals
      row 70
      col 405
      backcolor _DBUreddish
      value 0
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
      backcolor _DBUyellowish
      width 450
      on dblclick DBUlineselected()
      height 120
   end grid
   define button _DBUsavestruct
      row 400
      col 200
      caption "Create"
      action DBUsavestructure()
   end button
   define button _DBUexitnew
      row 400
      col 400
      caption "Exit"
      action DBUexitcreatenew()
   end button
end window
center window _DBUcreadbf
activate window _DBUcreadbf
return nil

function DBUexitcreatenew
if len(_DBUstructarr) == 0 .or. _DBUdbfsaved
   DBUtogglemenu()
   release window _DBUcreadbf
else
   if msgyesno("Are you sure to abort creating this dbf?","DBU")
      DBUtogglemenu()
      release window _DBUcreadbf
   endif
endif
return nil


function DBUaddstruct
if _DBUcreadbf._DBUaddline.caption == "Add"
   if .not. DBUnamecheck()
      
      return nil
   endif
   if _DBUcreadbf._DBUfieldsize.value == 0
      msgexclamation("Field size can not be zero!","DBU")
      _DBUcreadbf._DBUfieldsize.setfocus()
      
      return nil
   endif
   DBUtypelostfocus()
   DBUsizelostfocus()
   DBUdeclostfocus()
   if _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
      msgexclamation("You can not have decimal points more than the size!","DBU")
      _DBUcreadbf._DBUfielddecimals.setfocus()
      
      return nil
   endif
   if len(_DBUstructarr) > 0
      for _DBUi := 1 to len(_DBUstructarr)
         if upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
            msgexclamation("Duplicate field names are not allowed!","DBU")
            _DBUcreadbf._DBUfieldname.setfocus()
            
            return nil
         endif
      next _DBUi
   endif
   do case
      case _DBUcreadbf._DBUfieldtype.value == 1
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"C",_DBUcreadbf._DBUfieldsize.value,0})
      case _DBUcreadbf._DBUfieldtype.value == 2
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"N",_DBUcreadbf._DBUfieldsize.value,_DBUcreadbf._DBUfielddecimals.value})
      case _DBUcreadbf._DBUfieldtype.value == 3
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"D",8,0})
      case _DBUcreadbf._DBUfieldtype.value == 4
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"L",1,0})
      case _DBUcreadbf._DBUfieldtype.value == 5
         aadd(_DBUstructarr,{alltrim(_DBUcreadbf._DBUfieldname.value),"M",10,0})
   endcase
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
   _DBUcreadbf._DBUfieldname.value := ""
   _DBUcreadbf._DBUfieldtype.value := 1
   _DBUcreadbf._DBUfieldsize.value := 10
   _DBUcreadbf._DBUfielddecimals.value := 0
   _DBUcreadbf._DBUfieldname.setfocus()
else
   _DBUcurline := _DBUcreadbf._DBUstruct.value
   if _DBUcurline > 0
      if .not. DBUnamecheck()
         
         return nil
      endif
      if _DBUcreadbf._DBUfieldsize.value == 0
         msgexclamation("Field size can not be zero!","DBU")
         _DBUcreadbf._DBUfieldsize.setfocus()
         
         return nil
      endif
      DBUtypelostfocus()
      DBUsizelostfocus()
      DBUdeclostfocus()
      if _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
         msgexclamation("You can not have decimal points more than the size!","DBU")
         _DBUcreadbf._DBUfielddecimals.setfocus()
         
         return nil
      endif
      if len(_DBUstructarr) > 0
         for _DBUi := 1 to len(_DBUstructarr)
            if upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1])) .and. _DBUi <> _DBUcurline
               msgexclamation("Duplicate field names are not allowed!","DBU")
      	       _DBUcreadbf._DBUfieldname.setfocus()
               
   	       return nil
            endif
         next _DBUi
      endif
      do case
         case _DBUcreadbf._DBUfieldtype.value == 1
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"C",_DBUcreadbf._DBUfieldsize.value,0}
         case _DBUcreadbf._DBUfieldtype.value == 2
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"N",_DBUcreadbf._DBUfieldsize.value,_DBUcreadbf._DBUfielddecimals.value}
         case _DBUcreadbf._DBUfieldtype.value == 3
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"D",8,0}
         case _DBUcreadbf._DBUfieldtype.value == 4
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"L",1,0}
         case _DBUcreadbf._DBUfieldtype.value == 5
            _DBUstructarr[_DBUcurline] := {alltrim(_DBUcreadbf._DBUfieldname.value),"M",10,0}
      endcase
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
         _DBUcreadbf._DBUstruct.value := _DBUcurline
      endif
      _DBUcreadbf._DBUaddline.caption := "Add"
      _DBUcreadbf._DBUinsline.enabled := .t.
      _DBUcreadbf._DBUdelline.enabled := .t.
      _DBUcreadbf._DBUfieldname.value := ""
      _DBUcreadbf._DBUfieldtype.value := 1
      _DBUcreadbf._DBUfieldsize.value := 10
      _DBUcreadbf._DBUfielddecimals.value := 0
      _DBUcreadbf._DBUfieldname.setfocus()
   endif
endif

return nil


function DBUinsstruct
if len(_DBUstructarr) == 0 
   DBUaddstruct()
   
   return nil
endif
if _DBUcreadbf._DBUstruct.value == 0
   DBUaddstruct()
   
   return nil
endif
if .not. DBUnamecheck()
   
   return nil
endif
if _DBUcreadbf._DBUfieldsize.value == 0
   msgexclamation("Field size can not be zero!","DBU")
   _DBUcreadbf._DBUfieldsize.setfocus()
   
   return nil
endif
DBUtypelostfocus()
DBUsizelostfocus()
DBUdeclostfocus()
if _DBUcreadbf._DBUfieldtype.value == 2 .and. _DBUcreadbf._DBUfielddecimals.value >= _DBUcreadbf._DBUfieldsize.value
   msgexclamation("You can not have decimal points more than the size!","DBU")
   _DBUcreadbf._DBUfielddecimals.setfocus()
   
   return nil
endif
if len(_DBUstructarr) > 0
   for _DBUi := 1 to len(_DBUstructarr)
      if upper(alltrim(_DBUcreadbf._DBUfieldname.value)) == upper(alltrim(_DBUstructarr[_DBUi,1]))
         msgexclamation("Duplicate field names are not allowed!","DBU")
	 _DBUcreadbf._DBUfieldname.setfocus()
         
	 return nil
      endif
   next _DBUi
endif
_DBUpos := _DBUcreadbf._DBUstruct.value
asize(_DBUstructarr,len(_DBUstructarr)+1)
_DBUstructarr := ains(_DBUstructarr,_DBUpos)
do case
   case _DBUcreadbf._DBUfieldtype.value == 1
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"C",_DBUcreadbf._DBUfieldsize.value,0}
   case _DBUcreadbf._DBUfieldtype.value == 2
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"N",_DBUcreadbf._DBUfieldsize.value,_DBUcreadbf._DBUfielddecimals.value}
   case _DBUcreadbf._DBUfieldtype.value == 3
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"D",8,0}
   case _DBUcreadbf._DBUfieldtype.value == 4
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"L",1,0}
   case _DBUcreadbf._DBUfieldtype.value == 5
      _DBUstructarr[_DBUpos] := {alltrim(_DBUcreadbf._DBUfieldname.value),"M",10,0}
endcase
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
   _DBUcreadbf._DBUstruct.value := _DBUpos
endif
_DBUcreadbf._DBUfieldname.value := ""
_DBUcreadbf._DBUfieldtype.value := 1
_DBUcreadbf._DBUfieldsize.value := 10
_DBUcreadbf._DBUfielddecimals.value := 0
_DBUcreadbf._DBUfieldname.setfocus()

return nil

function DBUdelstruct
_DBUcurline := _DBUcreadbf._DBUstruct.value
if _DBUcurline > 0
   _DBUstructarr := adel(_DBUstructarr,_DBUcurline)
   _DBUstructarr := asize(_DBUstructarr,len(_DBUstructarr) - 1)
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
   if len(_DBUstructarr) > 1
      if len(_DBUstructarr) == 1
         _DBUcreadbf._DBUstruct.value := 1
      else
         _DBUcreadbf._DBUstruct.value := iif(_DBUcurline == 1,1,_DBUcurline - 1)
      endif
   endif
endif

return nil

function DBUnamecheck
local _DBUname := alltrim(_DBUcreadbf._DBUfieldname.value)
local _DBUlegalchars := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890'
local _DBUi
if len(_DBUname) == 0
   msgexclamation("Field Name can not be empty!","DBU")
   _DBUcreadbf._DBUfieldname.setfocus()
   return .f.
endif
if val(substr(_DBUname,1,1)) > 0 .or. substr(_DBUname,1,1) == "_"
   msgexclamation("First letter of the field name can not be a numeric character or special character!","DBU")
   _DBUcreadbf._DBUfieldname.setfocus()
   return .f.
else
   for _DBUi := 1 to len(_DBUname)
      if at(upper(substr(_DBUname,_DBUi,1)),_DBUlegalchars) == 0
         msgexclamation("Field name contains illegal characters. Allowed characters are alphabets, numbers and the special character '_'.","DBU")
         _DBUcreadbf._DBUfieldname.setfocus()
         return .f.
      endif
   next _DBUi
endif
return .t.

function DBUtypelostfocus
do case
   case _DBUcreadbf._DBUfieldtype.value == 3
      _DBUcreadbf._DBUfieldsize.value := 8
      _DBUcreadbf._DBUfielddecimals.value := 0
   case _DBUcreadbf._DBUfieldtype.value == 4
      _DBUcreadbf._DBUfieldsize.value := 1
      _DBUcreadbf._DBUfielddecimals.value := 0
   case _DBUcreadbf._DBUfieldtype.value == 5
      _DBUcreadbf._DBUfieldsize.value := 10
      _DBUcreadbf._DBUfielddecimals.value := 0
endcase
return nil

function DBUsizelostfocus
DBUtypelostfocus()
if _DBUcreadbf._DBUfieldtype.value == 1
      _DBUcreadbf._DBUfielddecimals.value := 0
endif
return nil

function DBUdeclostfocus
DBUtypelostfocus()
DBUsizelostfocus()
if _DBUcreadbf._DBUfieldtype.value <> 2
   _DBUcreadbf._DBUfielddecimals.value := 0
endif
return nil

function DBUlineselected
_DBUcurline := _DBUcreadbf._DBUstruct.value
if _DBUcurline > 0
   _DBUcreadbf._DBUfieldname.value := _DBUstructarr[_DBUcurline,1]
   do case
      case _DBUstructarr[_DBUcurline,2] == "C"
         _DBUcreadbf._DBUfieldtype.value := 1
      case _DBUstructarr[_DBUcurline,2] == "N"
         _DBUcreadbf._DBUfieldtype.value := 2
      case _DBUstructarr[_DBUcurline,2] == "D"
         _DBUcreadbf._DBUfieldtype.value := 3
      case _DBUstructarr[_DBUcurline,2] == "L"
         _DBUcreadbf._DBUfieldtype.value := 4
      case _DBUstructarr[_DBUcurline,2] == "M"
         _DBUcreadbf._DBUfieldtype.value := 5
   end case
   _DBUcreadbf._DBUfieldsize.value := _DBUstructarr[_DBUcurline,3]
   _DBUcreadbf._DBUfielddecimals.value := _DBUstructarr[_DBUcurline,4]
   _DBUcreadbf._DBUinsline.enabled := .f.
   _DBUcreadbf._DBUdelline.enabled := .f.
   _DBUcreadbf._DBUaddline.caption := "Modify"
   _DBUcreadbf._DBUfieldname.setfocus()
endif
return nil

function DBUsavestructure
_DBUfname1 := ""
if len(_DBUstructarr) > 0
   _DBUfname1 := alltrim(putfile({{"Harbour Database File","*.dbf"}},"Enter a filename"))
   if len(_DBUfname1) > 0
      if msgyesno("Are you sure to create this database file?","DBU")
         dbcreate(_DBUfname1,_DBUstructarr)
	      msginfo("File has been created successfully","DBU")
	      if .not. used()
  	         use &_DBUfname1
	         _DBUfname := _DBUfname1
	         _DBUdbfopened := .t.
                 DBUtogglemenu()            
                 release window _DBUcreadbf
	      else
                 release window _DBUcreadbf
   	   endif
      endif
   endif
endif
return nil
