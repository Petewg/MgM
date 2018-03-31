#include "minigui.ch"
#include "dbuvar.ch"

//------------------------------------------------------------------------------
function DBUbrowse1()
//------------------------------------------------------------------------------

local _DBUname1
local _DBUstructarr
local _DBUanames := {}
local _DBUasizes := {}
local _DBUajustify := {}

local nWBrowseWidth, nWBrowseHeight

IF .not. used()
   msginfo("No database is in use.","DBU")
   return NIL
ENDIF

IF IsWindowDefined( _DBUBrowse )
   release window _DBUBrowse
   do events
ENDIF

_DBUstructarr := dbstruct()

for _DBUi := 1 to len(_DBUstructarr)

   aadd(_DBUanames,_DBUstructarr[_DBUi,1])

   _DBUsize := len(alltrim(_DBUstructarr[_DBUi,1]))*15

   _DBUsize1 := _DBUstructarr[_DBUi,3] * 15

   aadd(_DBUasizes, iif(_DBUsize < _DBUsize1,_DBUsize1,_DBUsize))

   if _DBUi == 1
      aadd(_DBUajustify,0)
   else
      if _DBUstructarr[_DBUi,2] == "N"
         aadd(_DBUajustify,1)
      else
         aadd(_DBUajustify,0)
      endif
   endif
next _DBUi

if len(_DBUanames) == 0
   return nil
endif

_DBUname1 := dbf()

if len(alltrim(_DBUname1)) == 0
   _DBUname1 := substr(_DBUfname,rat("\",_DBUfname),at(".",_DBUfname) - 1)
   if len(alltrim(_DBUname1))==0
      return nil
   endif
endif

_DBUbuttonfirstrow := _DBUwindowheight - 200

_DBUmaxrow := _DBUbuttonfirstrow - 100

_DBUbuttoncol := 5

_DBUbuttoncount := 1


nWBrowseWidth := _DBUscrwidth
nWBrowseHeight := _DBUwindowheight - IF(IsXPThemeActive(), 70, 80)

define window _DBUBrowse at 0,0 ;
         width nWBrowseWidth height nWBrowseHeight title "DBU Browse " + _DBUfname;
         CHILD NOMINIMIZE NOMAXIMIZE NOSIZE NOSYSMENU

   define splitbox
      define toolbar _DBUedittoolbar buttonsize 48,35 flat // righttext
         button _DBUfirst     caption "First"     picture "first"     action DBUBRowsefirstclick()
         button _DBUprevious  caption "Previous"  picture "previous"  action DBUBrowsepreviousclick()
         button _DBUnext      caption "Next"      picture "next"      action DBUBrowsenextclick()
         button _DBUlast      caption "Last"      picture "last"      action DBUBrowselastclick()
      end toolbar
      define toolbar _DBUedittoolbar1 buttonsize 48,35 flat // righttext
         button _DBUEditRec   caption "Edit"      picture "editmode"  action DBUbrowse2edit()
         button _DBUdelrec    caption "Delete"    picture "delete"    action DBUBrowsedelrecclick()
         button _DBUrecall    caption "Recall"    picture "recall"    action DBUBrowserecallclick()
         button _DBUprint     caption "Print"     picture "print"     action DBUbrowseprint()
         button _DBUclose     caption "Exit"      picture "exit"      action _DBUBrowse.release
      end toolbar
   end splitbox

   define browse _DBUrecord
      parent _DBUbrowse
      row 60
      col 3
      width nWBrowseWidth - 10
      height nWBrowseHeight - IF(IsXPThemeActive(), 160, 150 )
      headers _DBUanames
      widths _DBUasizes
      workarea &_DBUname1
      backcolor _DBUgreenish
      fields _DBUanames
      value recno()
      fontname "Arial"
      fontsize 9
      tooltip 'Double click to edit field contents'
      allowappend .t.
      allowedit .t.
      allowdelete .t.
      lock .t.
      inplaceedit .t.
      on change DBUbrowsechanged()
   end browse

   define button _DBUbrowsegotobutton
      row nWBrowseHeight - IF(IsXPThemeActive(), 90, 80)
      col 10
      caption "Goto"
      width 50
      action DBUbrowsegotoclick()
   end button

   define textbox _DBUbrowsegoto
      row nWBrowseHeight - IF(IsXPThemeActive(), 90, 80)
      col 70
      width 100
      backcolor _DBUgreenish
      numeric .t.
      rightalign .t.
      value recno()
      on enter DBUbrowsegotoclick()
   end textbox

   if _DBUfiltered
      define label _DBUfilterconditionlabel
         row nWBrowseHeight - IF(IsXPThemeActive(), 85, 75)
         col 200
         value "Filter Condition :"
         width 150
         fontbold .T.
         // backcolor _DBUgreenish
         // fontcolor {255,0,0}
      end label

      define textbox _DBUfiltercondition
         row nWBrowseHeight - IF(IsXPThemeActive(), 90, 80)
         col 360
         width _DBUwindowwidth - 400
         value _DBUcondition
         readonly .T.
         fontbold .T.
         backcolor _DBUgreenish
         // fontcolor {255,0,0}
      end textbox
   endif

   define statusbar
      statusitem "Browse Window of "+_DBUfname
      statusitem "" width 200
      statusitem "" width 60
      statusitem "" width 60
      statusitem "" width 60
   end statusbar

   * (JK)
   ON KEY ESCAPE OF _DBUBrowse action _DBUBrowse.release
end window

if _DBUfiltered
   _DBUbrowse._DBUbrowsegoto.enabled := .f.
endif

_DBUcurrec := recno()
count for deleted() to _DBUtotdeleted
dbgoto(_DBUcurrec)
_DBUBrowse._DBUrecord.refresh()
_DBUBrowse._DBUrecord.setfocus
_DBUBrowse.center
_DBUBrowse.row := _DBUbuttonfirstrow - 32
_DBUBrowse.activate

return nil

//------------------------------------------------------------------------------
function DBUBrowsefirstclick
if reccount() > 0
   go top
   _DBUbrowse._DBUrecord.value := recno()
   DBUBrowserefreshdbf()
endif
return nil

//------------------------------------------------------------------------------
function DBUBrowsepreviousclick
if .not. bof()
   skip -1
   _DBUbrowse._DBUrecord.value := recno()
   DBUBrowserefreshdbf()
endif
return nil

//------------------------------------------------------------------------------
function DBUBrowsenextclick
if .not. eof()
   skip
   if eof()
      skip -1
   endif
   _DBUbrowse._DBUrecord.value := recno()
   DBUBrowserefreshdbf()
endif
return nil

//------------------------------------------------------------------------------
function DBUBrowselastclick
go bottom
_DBUbrowse._DBUrecord.value := recno()
DBUBrowserefreshdbf()
return nil

//------------------------------------------------------------------------------
function DBUBrowsedelrecclick
if .not. eof()
   delete
   _DBUtotdeleted := _DBUtotdeleted + 1
   DBUBrowserefreshdbf()
endif
return nil

//------------------------------------------------------------------------------
function DBUBrowserecallclick
if deleted()
   recall
   _DBUtotdeleted := _DBUtotdeleted - 1
   DBUBrowserefreshdbf()
endif
return nil

//------------------------------------------------------------------------------
function DBUBrowsegotoclick
if _DBUBrowse._DBUbrowsegoto.value > 0
   if _DBUBrowse._DBUbrowsegoto.value <= reccount()
      dbgoto(_DBUBrowse._DBUbrowsegoto.value)
      _DBUbrowse._DBUrecord.value := recno()
      DBUBrowserefreshdbf()
      return nil
   else
      msginfo("You had entered a record number greater than the dbf size!","DBU")
      go bottom
      _DBUbrowse._DBUrecord.value := recno()
      DBUbrowserefreshdbf()
      _DBUBrowse._DBUbrowsegoto.setfocus()
      return nil
   endif
endif
return nil

//------------------------------------------------------------------------------
function DBUbrowsechanged
dbgoto(_DBUbrowse._DBUrecord.value)
DBUbrowserefreshdbf()
return nil

//------------------------------------------------------------------------------
function DBUBrowserefreshdbf
_DBUBrowse._DBUbrowsegoto.value := recno()
_DBUBrowse.statusbar.item(2) := iif(eof(),"0",alltrim(str(recno(),10,0)))+" / "+alltrim(str(reccount(),10,0))+" record(s) ("+alltrim(str(_DBUtotdeleted,5,0))+" deleted)"
_DBUBrowse.statusbar.item(3) := iif(deleted()," Del","")
_DBUBrowse.statusbar.item(4) := iif(_DBUfiltered,"Filtered","")
_DBUBrowse.statusbar.item(5) := iif(_DBUindexed,"Indexed","")
return nil

//------------------------------------------------------------------------------
function DBUbrowse2edit
_DBUBrowse._DBUrecord.refresh
_DBUbrowse.release
DBUedit1()
return nil
