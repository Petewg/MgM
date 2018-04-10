#include "minigui.ch"
#include "dbuvar.ch"

#define CR_LF HB_OSNewLine()

function DBUedit1
Private _DBUFieldName:=""
asize(_DBUcontrolarr,0)
_DBUstructarr := dbstruct()
if len(_DBUstructarr) == 0
   return nil
endif

_DBUbuttonfirstrow := _DBUwindowheight - 80
_DBUmaxrow := _DBUbuttonfirstrow - 100
_DBUbuttonrow := _DBUbuttonfirstrow
_DBUbuttoncol := 10
_DBUbuttoncount := 1
_DBUhspace := 5
_DBUvspace := 25
_DBUmaxcol := _DBUwindowwidth - 20
_DBUrow := 40
_DBUcol := 20
_DBUpages := 1

for _DBUi := 1 to len(_DBUstructarr)
   _DBUfieldnamesize := len(alltrim(_DBUstructarr[_DBUi,1]))
   _DBUfieldsize := _DBUstructarr[_DBUi,3]
   _DBUspecifysize := .f.
   do case
      case _DBUstructarr[_DBUi,2] == "C" .or. _DBUstructarr[_DBUi,2] == "N"
         _DBUsize := min(max(_DBUfieldnamesize+4,_DBUfieldsize) * 10,_DBUmaxcol-50)
         _DBUspecifysize := .t.
      case _DBUstructarr[_DBUi,2] == "D"
         _DBUsize := 120
      case _DBUstructarr[_DBUi,2] == "L"
         _DBUsize := (_DBUfieldnamesize*10)+30
      case _DBUstructarr[_DBUi,2] == "M"
         _DBUsize := _DBUmaxcol
   endcase
   if _DBUcol + _DBUsize + _DBUhspace >= _DBUmaxcol
      _DBUrow := _DBUrow + _DBUvspace + _DBUvspace
      _DBUcol := 20
   endif
   if _DBUrow + _DBUvspace + _DBUvspace >= _DBUmaxrow
      _DBUpages := _DBUpages + 1
      _DBUrow := 40
      _DBUcol := 20
   endif
   aadd(_DBUcontrolarr,{_DBUrow,_DBUcol,alltrim(_DBUstructarr[_DBUi,1]),_DBUsize,"H",iif(_DBUspecifysize,_DBUfieldsize,0),,_DBUpages})
   aadd(_DBUcontrolarr,{_DBUrow+20,_DBUcol,alltrim(_DBUstructarr[_DBUi,1]),_DBUsize,_DBUstructarr[_DBUi,2],_DBUfieldsize,_DBUstructarr[_DBUi,4],_DBUpages})
   _DBUcol := _DBUcol + _DBUhspace + _DBUsize
next _DBUi
define window _DBUedit at 0,0 width _DBUwindowwidth height _DBUwindowheight title "DBU Edit Window" modal nosize nosysmenu
   define splitbox
      define toolbar _DBUedittoolbar buttonsize 48,35 flat // righttext
         button _DBUfirst     caption "First"     picture "first"     action DBUeditfirstclick()
         button _DBUprevious  caption "Previous"  picture "previous"  action DBUeditpreviousclick()
         button _DBUnext      caption "Next"      picture "next"      action DBUeditnextclick()
         button _DBUlast      caption "Last"      picture "last"      action DBUeditlastclick()
      end toolbar
      define toolbar _DBUedittoolbar1 buttonsize 48,35 flat // righttext
         button _DBUnewrec    caption "New"       picture "new"       action DBUeditnewrecclick()
         button _DBUsave      caption "Save"      picture "Save"      action DBUeditsaveclick()
         button _DBUdelrec    caption "Delete"    picture "delete"    action DBUeditdelrecclick()
         button _DBUrecall    caption "Recall"    picture "recall"    action DBUeditrecallclick()
         button _DBUprint     caption "Print"     picture "print"     action DBUeditprint()
         button _DBUclose     caption "Exit"      picture "exit"      action _DBUedit.release
      end toolbar
   end splitbox
   define tab _DBUrecord at 70,10 width _DBUwindowwidth - 20 height _DBUbuttonfirstrow - 90
      for _DBUi := 1 to _DBUpages
         define page "Page "+alltrim(str(_DBUi,3,0))
            for _DBUj := 1 to len(_DBUcontrolarr)
               if _DBUcontrolarr[_DBUj,8] == _DBUi
                  _DBUfieldname := alltrim(alias())+"->"+_DBUcontrolarr[_DBUj,3]
                  _DBUControlName:=_DBUcontrolarr[_DBUj,3]
                  do case
                     case _DBUcontrolarr[_DBUj,5] == "H" // Header
                        _DBUheader1 := _DBUcontrolarr[_DBUj,3]+"label"
                        define label &_DBUheader1
                           row _DBUcontrolarr[_DBUj,1]
                           col _DBUcontrolarr[_DBUj,2]
                           value _DBUcontrolarr[_DBUj,3]+iif(_DBUcontrolarr[_DBUj,6] > 0,":"+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0)),"")
                           width _DBUcontrolarr[_DBUj,4]
                           fontbold .t.
//                           backcolor _DBUyellowish
                           fontcolor {0,0,255}
                        end label
                     case _DBUcontrolarr[_DBUj,5] == "C" // Character

                           define textbox &_DBUControlName
                              row _DBUcontrolarr[_DBUj,1]
                              col _DBUcontrolarr[_DBUj,2]
                              tooltip "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Character. Maximum Length is "+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0))+"."
                              width _DBUcontrolarr[_DBUj,4]
                              field &_DBUFieldName
                              backcolor _DBUyellowish
                              fontcolor {0,0,255}
                              fontbold .t.
                              maxlength _DBUcontrolarr[_DBUj,6]
                           end textbox

                     case _DBUcontrolarr[_DBUj,5] == "N" // Numeric

                           define textbox &_DBUControlName
                              row _DBUcontrolarr[_DBUj,1]
                              col _DBUcontrolarr[_DBUj,2]
                              width _DBUcontrolarr[_DBUj,4]
                              maxlength _DBUcontrolarr[_DBUj,6]
                              tooltip "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Numeric. Maximum Length is "+alltrim(str(_DBUcontrolarr[_DBUj,6],6,0))+", with decimals "+alltrim(str(_DBUcontrolarr[_DBUj,7],3,0))+"."
                              backcolor _DBUyellowish
                              fontcolor {255,0,0}
                              numeric .t.
                              fontbold .t.
                              field &_DBUFieldName
                              rightalign .t.
                              if _DBUcontrolarr[_DBUj,7] > 0
                                 inputmask replicate("9",_DBUcontrolarr[_DBUj,6] - _DBUcontrolarr[_DBUj,7] - 1)+"."+replicate("9",_DBUcontrolarr[_DBUj,7])
                              endif
                           end textbox
                     case _DBUcontrolarr[_DBUj,5] == "D" // Date
                           define datepicker &_DBUControlName
                              row _DBUcontrolarr[_DBUj,1]
                              col _DBUcontrolarr[_DBUj,2]
                              tooltip "Enter the date value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+"."
                              field &_DBUFieldName
                              fontbold .t.
                              width _DBUcontrolarr[_DBUj,4]
                              shownone .t.
                           end datepicker
                     case _DBUcontrolarr[_DBUj,5] == "L" // Logical
                           define checkbox &_DBUControlName
                              row _DBUcontrolarr[_DBUj,1]
                              col _DBUcontrolarr[_DBUj,2]
                              tooltip "Select True of False for this Logical Field "+alltrim(_DBUcontrolarr[_DBUj,3])+"."
                              field &_DBUFieldName
                              fontbold .t.
                              backcolor _DBUyellowish
//                              fontcolor {0,255,0}
                              width _DBUcontrolarr[_DBUj,4]
                              caption _DBUcontrolarr[_DBUj,3]
                           end checkbox
                     case _DBUcontrolarr[_DBUj,5] == "M" // Memo
                           define textbox &_DBUControlName
                              row _DBUcontrolarr[_DBUj,1]
                              col _DBUcontrolarr[_DBUj,2]
                              tooltip "Enter the value for the field "+alltrim(_DBUcontrolarr[_DBUj,3])+". Type of the field is Memo."
                              fontbold .t.
                              fontcolor {255,0,0}
                              backcolor _DBUyellowish
                              field &_DBUFieldName
                              width _DBUcontrolarr[_DBUj,4]
                           end textbox
                  endcase
               endif
            next _DBUj
         end page
      next _DBUi
   end tab
   define button _DBUeditgotobutton
      row _DBUbuttonfirstrow - 10
      col 10
      caption "Goto"
      width 50
      action DBUeditgotoclick()
   end button
   define textbox _DBUeditgoto
      row _DBUbuttonfirstrow - 10
      col 70
      width 100
      backcolor _DBUyellowish
      numeric .t.
      rightalign .t.
      value recno()
      on enter DBUeditgotoclick()
   end textbox
   if _DBUfiltered
      define label _DBUfilterconditionlabel
         row _DBUbuttonfirstrow - 5
         col 200
         value "Filter Condition :"
//         backcolor _DBUyellowish
         width 150
         fontbold .t.
      end label
      define textbox _DBUfiltercondition
         row _DBUbuttonfirstrow - 10
         col 360
//         fontcolor {255,0,0}
         width _DBUwindowwidth - 400
         backcolor _DBUyellowish
         fontbold .t.
         value _DBUcondition
         readonly .t.
      end textbox
   endif
   define statusbar
      statusitem "Edit "+_DBUfname
      statusitem "" width 200
      statusitem "" width 60
      statusitem "" width 60
      statusitem "" width 60
   end statusbar

   * (JK)
   ON KEY ESCAPE OF _DBUedit action _DBUedit.release

end window
if _DBUfiltered
   _DBUedit._DBUeditgoto.enabled := .f.
endif
_DBUcurrec := recno()
count for deleted() to _DBUtotdeleted
dbgoto(_DBUcurrec)
DBUeditrefreshdbf()
_DBUedit.center
_DBUedit.activate
return nil

function DBUeditfirstclick
go top
DBUeditrefreshdbf()
return nil

function DBUeditpreviousclick
if .not. bof()
   skip -1
   DBUeditrefreshdbf()
endif
return nil

function DBUeditnextclick
if .not. eof()
   skip
   if eof()
      skip -1
   endif
   DBUeditrefreshdbf()
endif
return nil

function DBUeditlastclick
go bottom
DBUeditrefreshdbf()
return nil

function DBUeditnewrecclick
if msgyesno("A new record will be appended to the dbf."+CR_LF+;
      "You can edit the record and it will be saved only after you click 'Save'."+CR_LF+;
      "Are you sure to append a blank record?","DBU")
   append blank
   DBUeditrefreshdbf()
endif
return nil

function DBUeditsaveclick()
Private _DBUcontrolName:=""
for _DBUi := 1 to len(_DBUcontrolarr)
   if _DBUControlarr[_DBUi,5] <> "H"
      _DBUcontrolName:=_DBUcontrolarr[_DBUi,3]
      DoMethod('_DBUedit', _DBUcontrolName, 'Save')
   endif
next _DBUi
Release _DBUcontrolName
DBUeditrefreshdbf()
return nil

function DBUeditdelrecclick
if .not. eof()
   delete
   _DBUtotdeleted := _DBUtotdeleted + 1
   DBUeditrefreshdbf()
endif
return nil

function DBUeditrecallclick
if deleted()
   recall
   _DBUtotdeleted := _DBUtotdeleted - 1
   DBUeditrefreshdbf()
endif
return nil

function DBUeditgotoclick
if _DBUedit._DBUeditgoto.value > 0
   if _DBUedit._DBUeditgoto.value <= reccount()
      dbgoto(_DBUedit._DBUeditgoto.value)
      DBUeditrefreshdbf()
   else
      msginfo("You had entered a record number greater than the dbf size!","DBU")
      _DBUedit._DBUeditgoto.value := reccount()
      _DBUedit._DBUeditgoto.setfocus()
      return nil
   endif
endif
return nil

function DBUeditrefreshdbf
for _DBUi := 1 to len(_DBUcontrolarr)
   if _DBUControlarr[_DBUi,5] <> "H"
      DoMethod('_DBUedit', _DBUcontrolarr[_DBUi,3], 'Refresh')
   endif
next _DBUi
_DBUedit._DBUeditgoto.value := recno()
_DBUedit.statusbar.item(2) := iif(eof(),"0",alltrim(str(recno(),10,0)))+" / "+alltrim(str(reccount(),10,0))+" record(s) ("+alltrim(str(_DBUtotdeleted,5,0))+" deleted)"
_DBUedit.statusbar.item(3) := iif(deleted()," Del","")
_DBUedit.statusbar.item(4) := iif(_DBUfiltered,"Filtered","")
_DBUedit.statusbar.item(5) := iif(_DBUindexed,"Indexed","")
return nil
