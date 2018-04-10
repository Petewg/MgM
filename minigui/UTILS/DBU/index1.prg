#include "minigui.ch"
#include "dbuvar.ch"

********************************************************
Function DBUcreaindex()
********************************************************
private _DBUfieldnames := {}
_DBUstructarr := dbstruct()
if len(_DBUstructarr) == 0
   return nil
endif
for _DBUi := 1 to len(_DBUstructarr)
   aadd(_DBUfieldnames,_DBUstructarr[_DBUi,1])
next _DBUi
define window _DBUcreaindex at 0,0 width 300 height 500 title "Create Index" modal nosize nosysmenu
   define label _DBUfieldslabel
      row 10
      col 10
      width 280
      value "Field Names List:"
      fontbold .t.
   end label
   define grid _DBUfields
      row 40
      col 10
      width 280
      height 380
      widths {0,200}
      headers {"","Field Names"}
      image {"wrong","right"}
      tooltip "Double Click a field name to toggle between creating and not creating an index for that field."
      ondblclick _DBUindexfieldtoggle()
   end grid
   define button _DBUsaveindex
      row 430
      col 40
      caption "Create"
      action _DBUcreateindex()
   end button
   define button _DBUcancelindex
      row 430
      col 160
      caption "Cancel"
      action _DBUcreaindex.release
   end button
end window
for _DBUi := 1 to len(_DBUfieldnames)
   _DBUcreaindex._DBUfields.additem({iif(_DBUi == 1,1,0),alltrim(_DBUfieldnames[_DBUi])})
next _DBUi
_DBUcreaindex.center
_DBUcreaindex.activate
return nil

**************************************
Function _DBUcreateindex()
**************************************
private _DBUindexlist := {}
private _DBUcurrentitem := {}
private _DBUfieldname := ""
private _DBUindexfile := ""

for _DBUi := 1 to _DBUcreaindex._DBUfields.itemcount
   _DBUcurrentitem := _DBUcreaindex._DBUfields.item(_DBUi)
   if _DBUcurrentitem[1] == 1
      aadd(_DBUindexlist,_DBUcurrentitem[2])
   endif
next _DBUi
if len(_DBUindexlist) == 0
   msginfo("You have to mark at least one field name to create index!","DBU Create Index")
   return nil
else
   if msgyesno("Are you sure to create index for "+alltrim(str(len(_DBUindexlist)))+" field(s) you had selected?","DBU Create Index")
      for _DBUi := 1 to len(_DBUindexlist)
         _DBUfieldname := _DBUindexlist[_DBUi]
         _DBUindexfile := _DBUlastpath+alltrim(_DBUfieldname)
         aadd(_DBUindexfields,_DBUfieldname)
         aadd(_DBUindexfiles,_DBUindexfile)
         * (JK)
         _REINDEKS(_DBUindexfile,_DBUfieldname)
      next _DBUi
      _DBUactiveindex := 1
      set index to &_DBUindexfile
      msginfo("Index files created for "+alltrim(str(len(_DBUindexlist)))+" field(s) you had selected. The Current Active Index is "+indexkey(indexord()),"DBU Create Index")
//      msginfo(_DBUindexfields[_DBUactiveindex],"DBU Current Active Index")
      DBUtogglemenu()
      _DBUcreaindex.release()
   endif
endif
return nil

***********************************************
Function _DBUindexfieldtoggle()
***********************************************
local lineno := _DBUcreaindex._DBUfields.value
local _DBUcurrentitem
if lineno > 0
   _DBUcurrentitem := _DBUcreaindex._DBUfields.item(lineno)
   if _DBUcurrentitem[1] == 0
      _DBUcurrentitem[1] := 1
   else
      _DBUcurrentitem[1] := 0
   endif
   _DBUcreaindex._DBUfields.item(lineno) := _DBUcurrentitem
endif
return nil

**********************************************
Function DBUopenindex()
**********************************************
//JK
private _DBUindexfile := ""
private _DBUopenfilenames := getfile({{"Harbour DataBase Index File(s)  (*.ntx)","*.ntx"}},"Choose the Index Files to Open",_DBUlastpath,.t.,.t.)
if len(_DBUopenfilenames) > 0
   for _DBUi := 1 to len(_DBUopenfilenames)
      _DBUindexfile:=_DBUopenfilenames[_DBUi]
      set index to &_DBUindexfile
      aadd(_DBUindexfiles,_DBUopenfilenames[_DBUi])
      aadd(_DBUindexfields,indexkey(indexord()))
   next _DBUi
   if _DBUactiveindex == 0
      _DBUactiveindex := 1
      _DBUindexfile:=_DBUindexfiles[_DBUactiveindex]
      set index to &_DBUindexfile
      msginfo("Index files Opened. The Current Active Index is "+indexkey(indexord()),"DBU Open Index")
   else
      _DBUindexfile:=_DBUindexfiles[_DBUactiveindex]
      set index to &_DBUindexfile  //JK
      msginfo("Index files Opened. The Current Active Index is "+indexkey(indexord())+" (Not changed.)","DBU Open Index")
   endif
endif
DBUtogglemenu()
BrowseRefresh()
RELEASE _DBUopenfilenames
return nil

* (JK)**************************************
Function DBUreindex()
*******************************************
private _CurDBUindexfile := ""
if len(_DBUindexfiles) == 0
   msginfo("No index files created/opened.","DBU Change Active Index")
   return nil
endif

for _DBUi := 1 to len(_DBUindexfiles)
    _DBUindexfile:=_DBUindexfiles[_DBUi]
    _DBUfieldname:=_DBUindexfields[_DBUi]
    _REINDEKS(_DBUindexfile,_DBUfieldname)
next _DBUi
_CurDBUindexfile:=_DBUindexfiles[_DBUactiveindex]
set index to &_CurDBUindexfile
BrowseRefresh()
msginfo("All index files have been (re)created.","DBU reindex")

return nil

*******************************************
Function DBUcloseindex()
*******************************************
if len(_DBUindexfiles) == 0
   msginfo("No index files created/opened.","DBU Change Active Index")
   return nil
endif
define window _DBUcloseindex at 0,0 width 300 height 400 title "DBU Close Index" modal nosize nosysmenu
   define label _DBUcurrentlabel
      row 10
      col 10
      value "Choose the index file(s) to close"
      width 280
   end label
   define listbox _DBUcurrentindices
      row 40
      col 10
      width 280
      height 250
      items _DBUindexfields
      multiselect .t.
   end listbox
   define button _DBUcloseindexbutton
      row 320
      col 10
      caption "Close"
      action DBUcloseindexdone()
   end button
end window
_DBUcloseindex.center
_DBUcloseindex.activate
return nil

*******************************************
Function DBUcloseindexdone()
*******************************************
local activeindexfile
local linenos := _DBUcloseindex._DBUcurrentindices.value
if len(linenos) == 0
   msginfo("No files selected for closing.","DBU close index")
   return nil
endif
for _DBUi := len(linenos) to 1 step -1
    adel(_DBUindexfiles,linenos[_DBUi])
    adel(_DBUindexfields,linenos[_DBUi])
    asize(_DBUindexfiles,(len(_DBUindexfiles)-1))
    asize(_DBUindexfields,(len(_DBUindexfields)-1))
    if linenos[_DBUi] == _DBUactiveindex
       _DBUactiveindex := 0
    endif
    if linenos[_DBUi] < _DBUactiveindex .and. _DBUactiveindex > 0
       _DBUactiveindex := _DBUactiveindex - 1
    endif
next _DBUi
if _DBUactiveindex == 0
   if len(_DBUindexfiles) > 0
      msginfo("You had selected to close the active index too. Hence the first open index is made active now.","DBU close index")
      _DBUactiveindex := 1
      activeindexfile := _DBUindexfiles[_DBUactiveindex]
      set index to &activeindexfile
      msginfo("The Current Active Index is "+indexkey(indexord()),"DBU Close Index")
   else
      set index to
      msginfo("All index files had been closed. No index is active!","DBU close index")
   endif
else
   activeindexfile := _DBUindexfiles[_DBUactiveindex]
   set index to &activeindexfile
endif
DBUtogglemenu()
_DBUcloseindex.release
BrowseRefresh()
return nil

********************************************************
Function DBUchangeactiveindex()
********************************************************
if len(_DBUindexfiles) == 0
   msginfo("No index files created/opened.","DBU Change Active Index")
   return nil
endif
if len(_DBUindexfiles) == 1
    msginfo("Only one index file opened. You have to open more than one index file to change!","DBU Change Active Index")
    return nil
endif
define window _DBUactiveindex at 0,0 width 300 height 400 title "DBU Active Index Change" modal nosize nosysmenu
   define label _DBUcurrentlabel
      row 10
      col 10
      value "Change the field to make it active"
      width 280
   end label
   define listbox _DBUcurrentindices
      row 40
      col 10
      width 280
      height 250
      items _DBUindexfields
      value _DBUactiveindex
   end listbox
   define button _DBUchangeactivedone
      row 320
      col 10
      caption "Done"
      action DBUchangeactiveindexdone()
   end button
end window
_DBUactiveindex.center
_DBUactiveindex.activate
return nil

********************************************************
Function DBUchangeactiveindexdone()
********************************************************
local lineno := _DBUactiveindex._DBUcurrentindices.value

if lineno > 0
   _DBUactiveindex := lineno
_DBUindexfile:=_DBUindexfiles[_DBUactiveindex]
   set index to &_DBUindexfile
   msginfo("The Current Active Index is "+indexkey(indexord()),"DBU Change Active Index")
   _DBUactiveindex.release
else
   msginfo("You have to select atleast one index file!","DBU change Active Index")
   return nil
endif
DBUtogglemenu()
BrowseRefresh()
return nil

* (JK) *******************************************************
FUNCTION _REINDEKS(cIdxNaz,cIdxWYR)
**********************************************************
Local cNazIdx:=cIdxNaz

   DEFINE WINDOW Form_idx AT 274,282 ;
          WIDTH 298 HEIGHT 100;
          TITLE "Indexing in progress - don`t interrupt !!!!";
          ICON "Tool";
          MODAL  ;
          NOSIZE ;
          ON INIT _INDEKSUJ(cIdxWYR,cNazIdx);
          FONT 'Arial' SIZE 09
          @ 30,19 PROGRESSBAR ProgressBar_1 RANGE 0,100 WIDTH 252 HEIGHT 18
          @ 6,94 LABEL Label_001 VALUE "Completed " WIDTH 120 HEIGHT 24
   define statusbar
      statusitem cNazIdx
   end statusbar

   END WINDOW
   Form_idx.center
   Form_idx.ACTIVATE

RETURN NIL

** (JK) *********************************
FUNCTION _INDEKSUJ(cWyrazenie,cNazIdx)
*****************************************

INDEX ON &cWyrazenie TO &cNazIdx EVAL NtxProgress() EVERY LASTREC()/20
Form_idx.Release
RETURN NIL

** (JK) *************************
FUNCTION NtxProgress()
********************************
LOCAL nComplete := INT((RECNO()/LASTREC()) * 100)
Local cComplete := LTRIM(STR(nComplete))
Form_idx.Label_001.Value := "Completed "+ cComplete + "%"
Form_idx.ProgressBar_1.Value := nComplete
Return .t.
