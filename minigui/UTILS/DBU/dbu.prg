#include "minigui.ch"
#include "dbuvar.ch"

#define CR_LF HB_OSNewLine()
#define DBU_VERSION "Summer '05 - Autumn '07"

REQUEST DBFCDX, DBFFPT

#ifdef __XHARBOUR__
   #xtranslate hb_pvalue([<x,...>]) => pvalue(<x>)
#endif

memvar _dbase,_opmode

//------------------------------------------------------------------------------
Function MAIN()
//------------------------------------------------------------------------------
LOCAL aColors
PARAMETERS _dbase,_opmode

public _DBUdbfopened := .f.
public _DBUfname := ""
public _DBUindexed := .f.
public _DBUfiltered := .f.
public _DBUcondition := ""
public _DBUmaxrow := 0
public _DBUcontrolarr := {} // {row,col,name,width,type,size,decimals,page}
public _DBUeditmode := .t.
public _DBUindexfieldname := ""
public _DBUbuttonsdefined := .f.
public _DBUscrwidth := Min(880,getdesktopwidth())
public _DBUscrheight := Min(600,getdesktopheight())

public _DBUwindowwidth  := _DBUscrwidth  - 50
public _DBUwindowheight := _DBUscrheight - 50

public _DBUtotdeleted := 0
public _DBUlastpath := ""
public _DBUlastfname := ""
public _DBUcurrentprinter := ""
public _DBUpath := GetStartupFolder()+"\" // diskname()+":\"+curdir()+"\"
public _DBUparentfname := ""
public _DBUchildfname := ""
public _DBUparentstructarr := {}
public _DBUchildstructarr := {}
public _DBUreddish := {255,200,200}
public _DBUgreenish := {200,255,200}
public _DBUblueish := {200,200,255}
public _DBUyellowish := {255,255,200}
public _DBUblack := {0,0,0}
public _DBUindexfields := {}
public _DBUindexfiles := {}
public _DBUactiveindex := 0

SET DATE TO    BRITISH
SET CENTURY    ON
SET EPOCH TO   1960
SET DELETED    OFF
SET EXCLUSIVE  ON

SET MENUSTYLE  EXTENDED
SET NAVIGATION EXTENDED
SET BROWSESYNC ON
SET INTERACTIVECLOSE QUERY MAIN

SET HELPFILE TO 'DBU.chm'

* (JK) check if some param is passed

* (JK) first param - dbase file to be open

if pcount()>0
   _dbase:=HB_PVALUE(1)
   if file(_dbase+".dbf")==.t.
      _dbase+=".dbf"
   elseif file(_dbase)==.f.
      _dbase:=""
   endif
else
   _dbase:=""
endif

* (JK) 2nd param - open mode  (B - as browse, E as EDIT)

if pcount()>1 .and. ( _opmode := upper(strtran(hb_PValue(2),"/","")) )$'BE'
   if _opmode=='B'
      _opmode:=2
   else
      _opmode:=1
   endif
else
      _opmode:=2
endif

if file(_DBUpath+"dbu.ini")
   begin ini file _DBUpath+"\dbu.ini"
      get _DBUlastpath section "DBUlastpath" entry "path"
      get _DBUlastfname section "DBUlastpath" entry "file"
   end ini
endif

* (JK) clause ON INIT added
define window _DBU at 0,0 ;
       width _DBUscrwidth height _DBUscrheight ;
       title "Harbour Minigui DataBase Utility" ;
       icon "dbuicon" ;
       main ;
       on init {|| iif(len(_dbase)>0, DBUopendbf(_dbase,_opmode),)} ;
       on release DBUclosedbfs() ;
       on maximize DBUwinSize()  ;
       on size DBUwinSize()      ;
       font 'Arial' size 8       ;
       noshow

   define statusbar
      statusitem "Empty" action DBUopendbf()
      statusitem "" width 350
      statusitem "" width 60
      statusitem "" width 60
      statusitem "" width 60
   end statusbar

   aColors := GetMenuColors()

   aColors[ MNUCLR_MENUBARBACKGROUND1 ] := GetSysColor(15)
   aColors[ MNUCLR_MENUBARBACKGROUND2 ] := GetSysColor(15)

   SetMenuColors( aColors )

   SetMenuBitmapHeight( BmpSize( "MENUOPEN" )[ 1 ] ) 

   define main menu

      popup "&File"
         item " Create &New DBF" + Space(16) + 'Ctrl+N' ;
               action DBUcreanew()                 image 'MENUNEW'
         separator
         item " &Open DBF file"  + Space(16) + 'Ctrl+O' ;
               action DBUopendbf()                 image 'MENUOPEN'
         item " &Close DBF"  ;
               action DBUclosedbf() name _DBUitem1 image 'MENUCLOSE'
         separator
         item " Modiy Structure" + Space(16) + 'Ctrl+T' ;
               action DBUmodistruct() name _DBUitem7 image 'MENUSTRU'
         separator
         item " E&xit" + Space(16) + 'Ctrl+X'           ;
               action _DBU.release()               image 'MENUEXIT'
         if len(alltrim(_DBUlastfname)) > 0
            separator
            item _DBUlastfname ;
                 action DBUopenlastdbf()
         endif
      end popup

      popup "&View"
         item " Browse Mode" + Space(16)+'Ctrl+B' ;
               action DBUbrowse1()  name _DBUitem9   image 'MENUBROW'
         separator
         item " Edit Mode" + Space(16)+'Ctrl+E' ;
               action DBUedit1()      name _DBUitem8 image 'MENUEDIT'
      end popup

      popup "&Index"
         item " Open index" ;
               action DBUopenindex() name _DBUitem3
         item " Change Active" ;
               action DBUchangeactiveindex() name _DBUitem4
         separator
         item " Create new index" ;
               action DBUcreaindex() name _DBUitem2  image 'MENUINDEX'
         item " Reindex" ;
               action DBUreindex() name _DBUitem5    image 'MENUREIND'
         separator
         item " Close index" ;
               action DBUcloseindex() name _DBUitem6 image 'MENUCLOIN'
      end popup

      popup "&Edit"
         item " &Replace" + Space(16) + 'Ctrl+R' ;
               action DBUreplace() name _DBUitem13   image 'MENUREPL'
         item " Reca&ll"  + Space(16) + 'Ctrl+L' ;
               action DBUrecallrec() name _DBUitem10 image 'MENURECA'
         item " Pack"  + Space(16)+'Ctrl+K' ;
               action DBUpackdbf() name _DBUitem11   image 'MENUPACK'
         separator
         item " Zap" + Space(16) + 'Ctrl+Z' ;
               action DBUzapdbf() name _DBUitem12    image 'MENUZAP'
      end popup

      popup "&Utilities"

         item " Export OEM dbf to &Ansi" + Space(16) + 'Ctrl+A' ;
               action DBU_OEM2ANSI(.T.) name _DBUitem14 image 'MenuAnsi'
         separator
         item " Export Ansi dbf to OE&M" + Space(16) + 'Ctrl+M' ;
               action DBU_OEM2ANSI(.F.) name _DBUitem15 image 'MenuOem'

      end popup

      popup "&Help"
         item ' &Help ' + Space(16) + 'F1' ;
               action HELP() image 'MENUHELP'
         separator
         item " About" ;
               action DBUaboutclick() image 'MENUQUEST'
         item ' Version' ;
               action MsgInfo ("Dbu version: " + DBU_VERSION      + CR_LF + ;
                              "GUI Library : " + MiniGuiVersion() + CR_LF + ;
                             "Compiler     : " + Version(), 'Versions') image 'MENUVER'
      end popup

   end menu

* (JK) & added to make use with ALT-key shortcut

   ON KEY CONTROL+N ACTION DBUcreanew()
   ON KEY CONTROL+O ACTION DBUopendbf()
   ON KEY CONTROL+T ACTION DBUmodistruct()
   ON KEY CONTROL+X ACTION _DBU.release()

   ON KEY CONTROL+B ACTION DBUbrowse1()
   ON KEY CONTROL+E ACTION DBUedit1()

   ON KEY CONTROL+R ACTION DBUreplace()
   ON KEY CONTROL+L ACTION DBUrecallrec()
   ON KEY CONTROL+K ACTION DBUpackdbf()
   ON KEY CONTROL+Z ACTION DBUzapdbf()

   ON KEY CONTROL+A ACTION DBU_OEM2ANSI(.T.)
   ON KEY CONTROL+M ACTION DBU_OEM2ANSI(.F.)
   ON KEY F1        ACTION HELP()

   define splitbox
      define toolbar _DBUMainTool buttonsize 48,35 flat // righttext
         button _DBUnewfile caption "New" picture "newfile" action DBUcreanew()
         button _DBUopenfile caption "Open" picture "open" action DBUopendbf()
         button _DBUclosefile caption "Close" picture "close" action DBUclosedbf()
         button _DBUmodify    caption "Modify" picture "modify" action DBUmodistruct()
         button _DBUprintstruct caption "Print" picture "print" action DBUprintstruct()
      end toolbar
      define toolbar _DBUMainTool2 buttonsize 48,35 flat // righttext
         button _DBUEditMode caption "Edit" picture "editmode" action DBUedit1()
         button _DBUbrowsemode caption "Browse" picture "browse" action DBUbrowse1()
      end toolbar
      define toolbar _DBUMainTool3 buttonsize 48,35 flat // righttext
         button _DBUindexfile caption "Index" picture "index" action DBUcreaindex() dropdown
         button _DBUfilterfile caption "Filter" picture "filter" action DBUfilterclick() check
//      button _DBUfilterclear caption "Clear Filter" picture "cfilter" action DBUfilterclear() separator
         button _DBURepl caption "Replace" picture "replace" action DBUreplace() separator
         button _DBUpack caption "Pack" picture "pack" action DBUpackdbf()
         button _DBUzap caption "Zap" picture "zap" action DBUzapdbf()
         button _DBUrecallall caption "Rec(all)" picture "recall" action DBUrecallrec()
      end toolbar
      define toolbar _DBUMainTool4 buttonsize 48,35 flat // righttext
         button _DBUabout caption "About" picture "about" action DBUaboutclick()
         button _DBUexit  caption "Exit"  picture "exit" action _DBU.release
      end toolbar
   end splitbox
   define dropdown menu button _DBUindexfile
      item "Create" action DBUcreaindex() name _DBUitem2a
      item "Open" action DBUopenindex() name _DBUitem3a
      item "Change Active" action DBUchangeactiveindex() name _DBUitem4a
      item "Reindex" action DBUreindex() name _DBUitem5a
      item "Close" action DBUcloseindex() name _DBUitem6a
   end menu

   define label _DBUmaillabel
      row _DBUscrheight - 115
      col _DBUscrwidth - 290
      value "E-mail me"
      width 80
   end label

   define hyperlink _DBUemailid
      row _DBUscrheight - 115
      col _DBUscrwidth - 200
      value "srgiri@dataone.in"
      address "srgiri@dataone.in"
      tooltip "Contact me at the above address"
      autosize .t.
      handcursor .t.
      fontname "Arial"
      fontsize 9
   end hyperlink

   define context menu of _DBU
      menuitem "Create" action DBUcreanew()
      menuitem "Open" action DBUopendbf()
      menuitem "Close" action DBUclosedbf() name _DBUcontextclose
      separator
      menuitem "Edit" action DBUedit1() name _DBUcontextedit
      menuitem "Browse" action DBUbrowse1() name _DBUcontextbrowse
   end menu

end window

define window DBUsplashwindow at 0,0 ;
       width 400+2*GetBorderWidth()-2 ;
       height 400+2*GetBorderHeight()-2 ;
       topmost nocaption ;
       on init DBUsplash() on release _DBU.restore()

   define image _DBUlogo
      row 0
      col 0
      picture "splash"
      width 400
      height 400
   end image

end window

DBUtogglemenu()

center window DBUsplashwindow
center window _DBU
activate window DBUsplashwindow, _DBU

return nil

*****************************
function Help()
*****************************
   _Execute( _HMG_MainHandle, "open", GetStartupFolder() + "\Dbu.Chm" )
return nil


*****************************
function DBUsplash(ilsec)
*****************************
local itime
if empty(ilsec)
   ilsec:=2
endif
itime := seconds()
do While seconds() - itime < ilsec
   DO Events
enddo

DBUsplashwindow.release
return nil

* (JK) main window resizing function

*=============================
function DBUwinSize()
*=============================
Local _DBUscrheight := _DBU.Height,_DBUscrwidth := _DBU.Width

_DBU._DBUemailid.Row   := _DBUscrheight - 115
_DBU._DBUemailid.Col   := _DBUscrwidth - 200
_DBU._DBUmaillabel.Row := _DBUscrheight - 115
_DBU._DBUmaillabel.Col := _DBUscrwidth - 290

Return NIL

* (JK) params added _DBfile to be open, edMODE - edit mode

************************************
function DBUopendbf( _DBfile, edMODE )
************************************
Local _editMode

if EMPTY(edMODE) .or. edMODE==NIL
   _editMode:=2
else
   _editMode:=edMODE
endif

if EMPTY(_DBfile) .or. _DBfile==NIL .or. !file(_DBfile)
   _DBUfname1 := getfile({{"xBase File  (*.dbf)","*.dbf"}},"Select a dbf to open",_DBUlastpath,.f.)
else
   _DBUfname1 := _DBfile
endif

_DBUfname1 := alltrim(_DBUfname1)

if len(_DBUfname1) > 0
   if used()
      if msgyesno("Are you sure to close the dbf opened already?","DBU")
         close all
         if MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
            _DBUfname := _DBUfname1
            _DBUdbfopened := .t.
            _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
            _DBUindexed := .f.
            _DBUfiltered := .f.
            DBUtogglemenu()
            * (JK) select browse mode
            if _editMode==1
               DBUedit1()
            else
               DBUbrowse1()
            endif
         endif
      endif
   else
      if MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
         _DBUfname := _DBUfname1
         _DBUdbfopened := .t.
         _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
          DBUtogglemenu()
         * (JK) select browse mode
         if _editMode==1
            DBUedit1()
         else
            DBUbrowse1()
         endif
      endif
   endif
endif
return nil

*************************************
function DBUopenlastdbf()
*************************************
* (JK) changed USE to MG_USE()

_DBUfname1 := alltrim(_DBUlastfname)
if len(_DBUfname1) > 0
   if used()
      if msgyesno("Are you sure to close the dbf opened already?","DBU")
         close all
         if MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
            _DBUfname := _DBUfname1
            _DBUdbfopened := .t.
            _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
            DBUtogglemenu()
            if _opMode==1
               DBUedit1()
            else
               DBUbrowse1()
            endif
          endif
      endif
   else
      if MG_USE("&_DBUfname1","_myDbase",.T.,5,.T.)
         _DBUfname := _DBUfname1
         _DBUdbfopened := .t.
         _DBUlastpath := substr(_DBUfname1,1,rat("\",_DBUfname1))
         DBUtogglemenu()
         if _opMode==1
            DBUedit1()
         else
            DBUbrowse1()
         endif
      endif
   endif
endif
return nil

**************************************
function DBUclosedbf( lAsk )
**************************************
LOCAL lGo := .T.
DEFAULT lAsk TO .T.

IF Used()
   IF lAsk
      lGo := msgyesno("Are you sure to close the dbf?","DBU")
   ENDIF
   IF lGo
      DBUfilterclear()
      DBCloseAll()

      _DBUcondition := ""
      _DBUindexed := .f.
      _DBUfiltered := .f.
      _DBUlastfname := _DBUfname
      _DBUfname := ""
      _DBUdbfopened := .f.
      _DBUactiveindex := 0
      asize(_DBUindexfiles,0)
      asize(_DBUindexfields,0)

      IF IsWindowDefined( _DBUBrowse )
         release window _DBUBrowse
      ENDIF

      DBUtogglemenu()
   ENDIF
ENDIF
return nil

***********************
function DBUrecallrec()
*************************
if msgyesno("This will recall all the records marked for deletion." + CR_LF + ;
            "If you want to recall a particular record, try using edit mode." + CR_LF + ;
            "Are you sure to recall all?", "DBU")
   if used()
      _DBUcurrec := recno()
      recall all
      dbgoto(_DBUcurrec)
      _DBUtotdeleted := 0
      BrowseRefresh()
   endif
endif
return nil

**************************
function DBUpackdbf()
**************************
if msgyesno("All records marked for deletion will be removed physically" + CR_LF + ;
            "from the dbf." + CR_LF + ;
            "Are you sure to pack the dbf?","DBU")
   if used()
      pack
      _DBUtotdeleted := 0
      BrowseRefresh()
      DBUtogglemenu()
   endif
endif
return nil

****************************
function DBUzapdbf
****************************
if msgyesno("Are you sure to zap this dbf?" + CR_LF + ;
            "You can not undo this change.","DBU")
   zap
   BrowseRefresh()
   DBUtogglemenu()
endif
return nil

****************************
function DBUtogglemenu
****************************
if .not. _DBUdbfopened
   _DBU.statusbar.item(1) := "Empty"
   _DBU.statusbar.item(2) := ""
   _DBU._DBUcontextclose.enabled := .f.
   _DBU._DBUcontextedit.enabled := .f.
   _DBU._DBUcontextbrowse.enabled := .f.
   _DBU._DBUitem1.enabled := .f.
   _DBU._DBUitem2.enabled := .f.
   _DBU._DBUitem3.enabled := .f.
   _DBU._DBUitem4.enabled := .f.
   _DBU._DBUitem5.enabled := .f.
   _DBU._DBUitem6.enabled := .f.
   _DBU._DBUitem7.enabled := .f.
   _DBU._DBUitem8.enabled := .f.
   _DBU._DBUitem9.enabled := .f.
   _DBU._DBUitem10.enabled := .f.
   _DBU._DBUitem11.enabled := .f.
   _DBU._DBUitem12.enabled := .f.
   _DBU._DBUitem13.enabled := .f.

   _DBU._DBUclosefile.enabled := .f.
   _DBU._DBUeditmode.enabled := .f.
   _DBU._DBUmodify.enabled := .f.
   _DBU._DBUbrowsemode.enabled := .f.
   _DBU._DBUpack.enabled := .f.
   _DBU._DBUzap.enabled := .f.
   _DBU._DBUrecallall.enabled := .f.
   _DBU._DBUprintstruct.enabled := .f.
   _DBU._DBUindexfile.enabled := .f.
   _DBU._DBUfilterfile.enabled := .F.
   _DBU._DBURepl.enabled := .F.

//   _DBU._DBUfilterclear.enabled := .f.
//   dbu.item8.enabled := .f.
else
   _DBU.statusbar.item(1) := _DBUfname+" (Fields : "+alltrim(str(fcount(),5,0))+") (Records : "+alltrim(str(reccount(),10,0))+")"
   _DBU._DBUcontextclose.enabled := .t.
   _DBU._DBUcontextedit.enabled := .t.
   _DBU._DBUcontextbrowse.enabled := .t.
   _DBU._DBUitem1.enabled := .t.
   _DBU._DBUitem2.enabled := .t.
   _DBU._DBUitem3.enabled := .t.
   _DBU._DBUitem4.enabled := .t.
   _DBU._DBUitem5.enabled := .t.
   _DBU._DBUitem6.enabled := .t.
   _DBU._DBUitem7.enabled := .t.
   _DBU._DBUitem8.enabled := .t.
   _DBU._DBUitem9.enabled := .t.
   _DBU._DBUitem10.enabled := .t.
   _DBU._DBUitem11.enabled := .t.
   _DBU._DBUitem12.enabled := .t.
   _DBU._DBUitem13.enabled := .t.
   _DBU._DBUitem14.enabled := .T.
   _DBU._DBUitem15.enabled := .T.
   _DBU._DBUclosefile.enabled := .t.
   _DBU._DBUeditmode.enabled := .t.
   _DBU._DBUmodify.enabled := .t.
   _DBU._DBUbrowsemode.enabled := .T.
   _DBU._DBURepl.enabled := .T.
   _DBU._DBUpack.enabled := .t.
   _DBU._DBUzap.enabled := .t.
   _DBU._DBUrecallall.enabled := .t.
   _DBU._DBUprintstruct.enabled := .t.
   _DBU._DBUindexfile.enabled := .t.
   _DBU._DBUfilterfile.enabled := .t.
   if len(_DBUindexfiles) == 0
      _DBU._DBUitem4.enabled := .f.
      _DBU._DBUitem5.enabled := .f.
      _DBU._DBUitem6.enabled := .f.
      _DBU._DBUitem4a.enabled := .f.
      _DBU._DBUitem5a.enabled := .f.
      _DBU._DBUitem6a.enabled := .f.
   else
      if len(_DBUindexfiles) > 1
         _DBU._DBUitem4.enabled := .t.
         _DBU._DBUitem4a.enabled := .t.
      else
         _DBU._DBUitem4.enabled := .f.
         _DBU._DBUitem4a.enabled := .f.
      endif
      _DBU._DBUitem5.enabled := .t.
      _DBU._DBUitem6.enabled := .t.
      _DBU._DBUitem5a.enabled := .t.
      _DBU._DBUitem6a.enabled := .t.
   endif
   if _DBUactiveindex > 0
      _DBU.statusbar.item(2) := "Active Index File:"+_DBUindexfiles[_DBUactiveindex]+". Field :"+alltrim(indexkey(indexord()))
   else
      _DBU.statusbar.item(2) := "Active Index File: NIL"
   endif
/*
   if _DBUfiltered
      _DBU._DBUfilterclear.enabled := .t.
   else
      _DBU._DBUfilterclear.enabled := .f.
   endif

   dbu.item8.enabled := .t.
*/
endif
return nil

********************************
function DBUclosedbfs()
********************************
close all
_DBUlastfname := _DBUfname
begin ini file _DBUpath+"dbu.ini"
   set section "DBUlastpath" entry "path" to _DBUlastpath
   if len(alltrim(_DBUlastfname)) > 0
      set section "DBUlastpath" entry "file" to _DBUlastfname
   endif
end ini
return nil


********************************
function DBUaboutclick()
********************************

DEFINE WINDOW _DBUaboutwindow AT 0, 0 WIDTH 368 HEIGHT 523 ;
	TITLE "About" ICON 'dbu' ;
	CHILD ;
	NOSIZE NOSYSMENU ;
	ON MOUSECLICK ThisWindow.Release

    DEFINE IMAGE Image_1
        ROW    2
        COL    2
        WIDTH  358
        HEIGHT 358
        PICTURE "splash"
        HELPID Nil
        VISIBLE .T.
        STRETCH .T.
        ACTION ThisWindow.Release
    END IMAGE

    DEFINE BUTTON Button_1
        ROW    460
        COL    260
        WIDTH  98
        HEIGHT 26
        CAPTION "Ok"
        ACTION ThisWindow.Release
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        HELPID Nil
        FLAT .T.
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .F.
        PICTURE Nil
        DEFAULT .T.
    END BUTTON

    DEFINE LABEL Label_1
        ROW    388
        COL    10
        WIDTH  340
        HEIGHT 72
        VALUE "Developed in : " + SubStr(MiniGUIVersion(), 1, 32) + CR_LF + CR_LF + "Compiler: " + Version()
        FONTNAME "Tahoma"
        FONTSIZE 10
        TOOLTIP ""
        FONTBOLD .T.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        VISIBLE .T.
        TRANSPARENT .F.
        ACTION ThisWindow.Release
        AUTOSIZE .f.
        BACKCOLOR Nil
        FONTCOLOR Nil
    END LABEL

    ON KEY ESCAPE ACTION ThisWindow.Release

END WINDOW

center window _DBUaboutwindow
activate window _DBUaboutwindow

return nil


// Filter Section
*====================================
function DBUsetfilter
*====================================
if .not. used()
   return nil
endif
_DBUstructarr := dbstruct()
_DBUfieldsarr := {}
for _DBUi := 1 to len(_DBUstructarr)
   aadd(_DBUfieldsarr,{_DBUstructarr[_DBUi,1]})
next _DBUi
_DBUdbffunctions := {{"RecNo()"},{"Deleted()"},{"Date()"},{"CToD()"},{"Day()"},{"Month()"},{"Year()"},;
                     {"AllTrim()"},{"Upper()"},{"Lower()"},{"Val()"},{"Str()"},{"Int()"},{"Max()"},{"Min()"}}
define window _DBUfilterbox at 0,0 width 650 height 420 title "Filter Condition" modal nosize nosysmenu
   define editbox _DBUfiltercondition
      row 30
      col 30
      width 600
      height 100
      backcolor _DBUreddish
      value _DBUcondition
   end editbox
   define grid _DBUfieldnames
      row 160
      col 30
      value 1
      backcolor _DBUyellowish
      headers {"Field Name"}
      widths {176}
      items _DBUfieldsarr
      on dblclick _DBUfilterbox._DBUfiltercondition.value := alltrim(alltrim(_DBUfilterbox._DBUfiltercondition.value)+" "+alltrim(_DBUfieldsarr[_DBUfilterbox._DBUfieldnames.value,1]))
      width 200
      height 152
   end grid
   define button _DBUlessthan
      row 200
      col 250
      width 25
      caption "<"
      action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" <"
   end button
   define button _DBUgreaterthan
      row 200
      col 285
      width 25
      caption ">"
      action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" >"
   end button
   define button _DBUequal
      row 200
      col 320
      width 25
      caption "=="
      action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" =="
   end button
   define button _DBUnotequal
      row 200
      col 355
      width 25
      caption "<>"
      action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" <>"
   end button
   define button _DBUand
      row 240
      col 250
      width 40
      caption "and"
      action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .and."
   end button
   define button _DBUor
      row 240
      col 300
      width 40
      caption "or"
      action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .or."
   end button
   define button _DBUnot
      row 240
      col 350
      width 40
      caption "not"
      action _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" .not."
   end button
   define grid _DBUfunctions
      row 160
      col 400
      value 1
      headers {"Functions"}
      widths {176}
      backcolor _DBUgreenish
      items _DBUdbffunctions
      on dblclick _DBUfilterbox._DBUfiltercondition.value := alltrim(_DBUfilterbox._DBUfiltercondition.value)+" "+alltrim(_DBUdbffunctions[_DBUfilterbox._DBUfunctions.value,1])
      width 200
      height 152
   end grid
   define button _DBUsetfilter
      row 340
      col 150
      caption "Set Filter"
      width 100
      action DBUfilterset()
   end button
   define button _DBUclearfilter
      row 340
      col 400
      caption "Clear Filter"
      width 100
      action (DBUfilterclear(),_DBUfilterbox.release)
   end button
end window
center window _DBUfilterbox
activate window _DBUfilterbox
return nil

*====================================
function DBUfilterset()
*====================================
_DBUcondition1 := alltrim(_DBUfilterbox._DBUfiltercondition.value)
if len(_DBUcondition1) == 0
   DBUfilterclear()
   release window _DBUfilterbox
else
   if Type("&_DBUcondition1") # "U"
      _DBUcondition := _DBUcondition1
      dbsetfilter({||&_DBUcondition},_DBUcondition)
      go top
      if eof()
         msgalert("No Records Matching Your Query!","Warning")
         set filter to
         _DBUfiltered := .f.
         _DBUcondition := ""
      else
         _DBUfiltered := .t.
      endif
      DBUtogglemenu()
      release window _DBUfilterbox
      BrowseRefresh()
   else
      msgalert("Wrong Query Condition!","Warning")
   endif
endif
return nil

*====================================
function DBUfilterclear()
*====================================
_DBUcondition := ""
_DBUfiltered := .f.
set filter to
BrowseRefresh()
_DBU._DBUfilterfile.value := .f.
DBUtogglemenu()
return nil

************************************
function DBUsetindex()
************************************
_DBUfieldnames := {}
_DBUstructarr := dbstruct()
aadd(_DBUfieldnames,"<None>")
for _DBUi := 1 to len(_DBUstructarr)
   aadd(_DBUfieldnames,alltrim(_DBUstructarr[_DBUi,1]))
next _DBUi
_DBUinputwindowresult := {}
if .not. _DBUindexed
   _DBUinputwindowinitial := 1
else
   if len(alltrim(_DBUindexfieldname)) > 0
      _DBUinputwindowinitial := ascan(_DBUstructarr,{|x|upper(alltrim(x[1])) == upper(alltrim(_DBUindexfieldname))}) + 1
   endif
endif
_DBUinputwindowresult := inputwindow("Select an Index Field",{"Index On","Ascending"},{_DBUinputwindowinitial,.t.},{_DBUfieldnames,nil})
if len(_DBUinputwindowresult) > 0 .and. (_DBUinputwindowresult[1] <> nil .or. _DBUinputwindowresult[2] <> nil)
   if _DBUinputwindowresult[1] > 0
      if _DBUinputwindowresult[1] == 1
         set index to
         _DBUindexed := .f.
      else
         _DBUindexfieldname := alltrim(_DBUfieldnames[_DBUinputwindowresult[1]])
         if _DBUinputwindowresult[2]
            index on &_DBUindexfieldname to tmpindex
         else
            index on &_DBUindexfieldname to tmpindex descending
         endif
         _DBUindexed := .t.
         go top
      endif
   else
      set index to
      _DBUindexed := .f.
   ENDIF
   BrowseRefresh()
endif
return nil

********************************
function DBUfilterclick()
********************************
if _DBU._DBUfilterfile.value
   DBUsetfilter()
else
   DBUfilterclear()
endif
return nil

*****************************
function DBUreplace
*****************************
local _DBUfieldnamesarr := {}
if .not. used()
   return nil
endif
_DBUstructarr := dbstruct()
for _DBUi := 1 to len(_DBUstructarr)
   aadd(_DBUfieldnamesarr,_DBUstructarr[_DBUi,1])
next _DBUi
// Window redesigned 21-06-05 - (Pete D)
define window _DBUreplace at 0,0 width 452 height 378 title "Replace Field Values" modal nosysmenu nosize

    DEFINE LISTBOX _DBUFields
        ROW    30
        COL    290
        WIDTH  140
        HEIGHT 200
        ITEMS _DBUfieldnamesarr
        VALUE 0
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE _DBUreplace.Repl_Field.Value := alltrim(_DBUreplace._DBUfields.item(_DBUreplace._DBUfields.value))
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
        ONDBLCLICK Nil
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        SORT .F.
        MULTISELECT .F.
    END LISTBOX

    DEFINE FRAME _DBUoptionframe
        ROW    10
        COL    10
        WIDTH  270
        HEIGHT 130
        FONTNAME "Arial"
        FONTSIZE 9
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        CAPTION "Replace scope"
        BACKCOLOR NIL
        FONTCOLOR NIL
        OPAQUE .T.
    END FRAME

    DEFINE TEXTBOX _DBUnextrecords
        ROW    76
        COL    170
        WIDTH  100
        HEIGHT 24
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE Nil
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONENTER Nil
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        READONLY .F.
        RIGHTALIGN .t.
        BACKCOLOR NIL
        FONTCOLOR NIL
        INPUTMASK "99999999"
        FORMAT Nil
        NUMERIC .T.
        VALUE 0
    END TEXTBOX

    DEFINE LABEL _DBUrecordslabel
        ROW    62
        COL    170
        WIDTH  29
        HEIGHT 12
        VALUE "Recs"
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        VISIBLE .T.
        TRANSPARENT .F.
        ACTION Nil
        AUTOSIZE .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
    END LABEL

    DEFINE LABEL _DBUfieldslabel
        ROW    10
        COL    290
        WIDTH  120
        HEIGHT 16
        VALUE "Available Fields"
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        VISIBLE .T.
        TRANSPARENT .F.
        ACTION Nil
        AUTOSIZE .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
    END LABEL

    DEFINE LABEL _DBUwithlabel
        ROW    210
        COL    20
        WIDTH  40
        HEIGHT 16
        VALUE "With"
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        VISIBLE .T.
        TRANSPARENT .F.
        ACTION Nil
        AUTOSIZE .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
    END LABEL

    DEFINE TEXTBOX _DBUvalue
        ROW    230
        COL    20
        WIDTH  250
        HEIGHT 24
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP "You have to enter a 'FUNCTION' returning with a valid value for the VALTYPE() of the field selected except for Character type Fields. For Example, for date fields ctod(),for numeric fields val() for logical fields iif(.t.,.t.,.f.). The value of this textbox will be passed with the macro (&) operator."
        ONCHANGE Nil
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONENTER Nil
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        READONLY .F.
        RIGHTALIGN .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
        INPUTMASK Nil
        FORMAT Nil
        VALUE ""
    END TEXTBOX

    DEFINE CHECKBOX _DBUforcheck
        ROW    260
        COL    20
        WIDTH  40
        HEIGHT 20
        CAPTION "For"
        VALUE .F.
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE iif(iscontroldefined(_DBUfor,_DBUreplace),iif(_DBUreplace._DBUforcheck.value,_DBUreplace._DBUfor.enabled := .t.,_DBUreplace._DBUfor.enabled := .f.),)
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .F.
    END CHECKBOX

    DEFINE TEXTBOX _DBUfor
        ROW    290
        COL    20
        WIDTH  250
        HEIGHT 24
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP "You have to enter a Valid Condition here."
        ONCHANGE iif(iscontroldefined(_DBUfor,_DBUreplace),iif(_DBUreplace._DBUforcheck.value,_DBUreplace._DBUfor.enabled := .t.,_DBUreplace._DBUfor.enabled := .f.),)
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONENTER Nil
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        READONLY .F.
        RIGHTALIGN .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
        INPUTMASK Nil
        FORMAT Nil
        VALUE ""
    END TEXTBOX

    DEFINE BUTTON _DBUexecute
        ROW    250
        COL    290
        WIDTH  140
        HEIGHT 30
        CAPTION "Replace"
        ACTION DBUexecutereplace()
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        HELPID Nil
        FLAT .F.
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .F.
        PICTURE Nil
    END BUTTON

    DEFINE BUTTON _DBUreplaceclose
        ROW    300
        COL    290
        WIDTH  140
        HEIGHT 30
        CAPTION "Close"
        ACTION _DBUreplace.release
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        HELPID Nil
        FLAT .F.
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .F.
        PICTURE Nil
    END BUTTON

    DEFINE RADIOGROUP _DBUoptions
        ROW    30
        COL    40
        WIDTH  130
        HEIGHT 100
        OPTIONS {"Current Record Only","All Records","Next","Rest from Current"}
        VALUE 1
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE iif(iscontroldefined(_DBUnextrecords,_DBUreplace),iif(_DBUreplace._DBUoptions.value == 3,_DBUreplace._DBUnextrecords.enabled := .t.,_DBUreplace._DBUnextrecords.enabled := .f.),)
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        TRANSPARENT .F.
        SPACING 25
        BACKCOLOR NIL
        FONTCOLOR NIL
    END RADIOGROUP

    DEFINE TEXTBOX Repl_Field
        ROW    180
        COL    20
        WIDTH  250
        HEIGHT 24
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        ONCHANGE Nil
        ONGOTFOCUS Nil
        ONLOSTFOCUS Nil
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        ONENTER Nil
        HELPID Nil
        TABSTOP .T.
        VISIBLE .T.
        READONLY .F.
        RIGHTALIGN .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
        INPUTMASK Nil
        FORMAT Nil
        VALUE ""
    END TEXTBOX

    DEFINE LABEL Label_1
        ROW    160
        COL    20
        WIDTH  120
        HEIGHT 16
        VALUE "Field"
        FONTNAME "Arial"
        FONTSIZE 9
        TOOLTIP ""
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        HELPID Nil
        VISIBLE .T.
        TRANSPARENT .F.
        ACTION Nil
        AUTOSIZE .F.
        BACKCOLOR NIL
        FONTCOLOR NIL
    END LABEL

    DEFINE FRAME Frame_1
        ROW    150
        COL    10
        WIDTH  270
        HEIGHT 180
        FONTNAME "Arial"
        FONTSIZE 9
        FONTBOLD .F.
        FONTITALIC .F.
        FONTUNDERLINE .F.
        FONTSTRIKEOUT .F.
        CAPTION NIL
        BACKCOLOR NIL
        FONTCOLOR NIL
        OPAQUE .T.
    END FRAME

END WINDOW

_DBUreplace._DBUfor.enabled := .f.
_DBUreplace._DBUnextrecords.enabled := .f.
_DBUreplace.center
_DBUreplace.activate
return nil


*****************************
function DBUexecutereplace
*****************************
//JK
private _DBUfieldname := alltrim(_DBUreplace._DBUfields.item(_DBUreplace._DBUfields.value))
private _DBUvalue := alltrim(_DBUreplace._DBUvalue.value)

if len(alltrim(_DBUvalue)) == 0
   msgalert("You have to enter the value to be replaced.","DBU Replace")
   _DBUreplace._DBUvalue.setfocus()
   return nil
endif
do case
   case _DBUreplace._DBUoptions.value == 1
      if _DBUreplace._DBUforcheck.value
         _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
         replace &_DBUfieldname with &_DBUvalue for &_DBUforcondition
      else
         replace &_DBUfieldname with &_DBUvalue
      endif
   case _DBUreplace._DBUoptions.value == 2
      if _DBUreplace._DBUforcheck.value
         _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
         replace all &_DBUfieldname with &_DBUvalue for &_DBUforcondition
      else
         replace all &_DBUfieldname with &_DBUvalue
      endif
   case _DBUreplace._DBUoptions.value == 3
      if _DBUreplace._DBUnextrecords.value <= 0
         msgalert("You have to enter the number of records to replace!","DBU Replace")
         _DBUreplace._DBUnextrecords.setfocus
         return nil
      else
         if _DBUreplace._DBUforcheck.value
            _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
            replace next _DBUreplace._DBUnextrecords.value &_DBUfieldname with &_DBUvalue for &_DBUforcondition
         else
            replace next _DBUreplace._DBUnextrecords.value &_DBUfieldname with &_DBUvalue
         endif
      endif
   case _DBUreplace._DBUoptions.value == 4
      if _DBUreplace._DBUforcheck.value
         _DBUforcondition := alltrim(_DBUreplace._DBUfor.value)
         replace rest &_DBUfieldname with &_DBUvalue for &_DBUforcondition
      else
         replace rest &_DBUfieldname with &_DBUvalue
      endif
endcase
if _DBUactiveindex > 0
   msginfo("Records had been replaced!. You have to reindex.","DBU Replace")

else
   msginfo("Records had been replaced!","DBU Replace")

ENDIF

_DBUreplace.release
BrowseRefresh()
return nil


/*
* DBU_OEM2ANSI()
* Export legacy Oem Dbf files to ANSI character set and vice versa
* param: lANSI, logic. If .t. convert to ANSI if .f. converts to OEM
* To Do: i. add possibility to detect automaticaly
*           the appropriate conversion type
*       ii. memo field conversion
*      iii. add progress bar
*****************************************************/
FUNCTION DBU_OEM2ANSI( lANSI )
local nI, nFields, aStruct, cOldDbf, xField, lOk
local cNewDBF, cTitle

DEFAULT lANSI TO .T.

cTitle := IF(lANSI, "ANSI", "OEM")

DBUclosedbf( .F. ) // close all databases without confirmation

cOldDbf := getfile( { {"xBase File (*.dbf)", "*.dbf"} }, ;
                     "Select a DBF to export", _DBUlastpath, .F. )
IF Empty(cOldDbf)
   RETURN NIL
ELSEIF ! MG_USE( cOldDbf, "OldDbf", .T., 5, .T. )
   msgStop( "Failed to open file " + cOldDbf + CR_LF + 'Operation aborted..' )
   RETURN NIL
ELSEIF ! msgOkCancel("Please confirm file export operation." + CR_LF + ;
               "(your original file will remain intact)", cTitle+" export")
   DBUclosedbf( .F. )
   RETURN NIL
ELSE
   cOldDbf := cFileNoPath(cOldDbf)
   WHILE .T.
      cNewDBF := Left(cOldDbf, At(".",cOldDBf)-1)+"_"+cTitle
      cNewDBF := InputBox("Enter a valid filename (without extension)", cTitle+" export", ;
                 cNewDbf,,,.f.)

      IF Empty(cNewDbf)
         IF ! MSGRetryCancel("Blank filename not allowed!", cTitle+" export")
            DBUclosedbf( .F. )
            RETURN NIL
         ENDIF
         LOOP
      ELSE
         IF At(".",cNewDBf) > 0
            cNewDBF := Left(cNewDbf, At(".",cNewDBf)-1)
         ENDIF
         IF File( cNewDbf+".dbf" )
            IF ! msgYesNo("File name already exist." + CR_LF + ;
                         "Overwrite?", cTitle+" export")
               LOOP
            ENDIF
         ENDIF
      ENDIF
      EXIT
   END
ENDIF

aStruct := DBStruct()
nFields := FCount()
DBCreate((cNewDBF), aStruct)
IF ! File( cNewDBF+".dbf" )
   msgStop( "Failed to create new file " + cNewDbf + CR_LF + 'Operation aborted..', cTitle + " export" )
   RETURN NIL
ENDIF
IF ! MG_USE(cNewDbf, 'NewDbf', .T., 5, .T. )
   msgStop( "Failed to open file " + cNewDbf + CR_LF + 'Operation aborted..', cTitle + " export" )
   RETURN NIL
ENDIF
select OldDbf

WHILE ! OldDbf->(Eof())
   NewDBF->(DBAppend())
   FOR nI := 1 TO nFields
      xField := FieldGet(nI)
      IF ValType( xField ) == "C"
         xField := IF( lANSI, HB_OEMTOANSI( xField ), HB_ANSITOOEM(xField) )
      ENDIF
         NewDBF->( FieldPut(nI, xField) )
      NEXT nI
      OldDbf->( DBSkip() )
END

lOk := ( OldDbf->(lastrec()) == NewDbf->(lastrec()) )

DBUclosedbf( .F. ) // close all databases without confirmation

IF lOk
   IF msgYesNo( "The File has been succesfuly exported!" + CR_LF + ;
                + CR_LF + "Browse new file " + cNewDbf + " ?", cTitle+" export" )
      DBUopendbf((cNewDbf+".dbf"),2)
   ENDIF
ELSE
   msgStop("Failed to export file!", cTitle+" export" )
ENDIF

RETURN Nil

FUNCTION BrowseRefresh()
   IF IsWindowDefined( _DBUBrowse )
      domethod( '_DBUBrowse', 'Hide' )
      domethod( '_DBUBrowse','_DBUrecord', 'Refresh' )
      domethod( '_DBUBrowse','Show' )
   ENDIF
RETURN NIL

* (JK)

**********************************************************************
FUNCTION MG_USE(cDbfName, cAlias, lUseExclusive, nTries, lAsk, cdPage)
**********************************************************************
local nTriesOrig, lReturn:=.f.

cdPage := IF(Empty(cdPage), 'EN', cdPage)

if file(cDbfName)==.f. .and. file(cDbfName+".dbf")==.f.
   MsgStop('No access to database file',cDbfName)
   return lReturn
endif

nTriesOrig := nTries
do while nTries > 0
   dbUseArea(.t.,NIL,cDbfName,cAlias,!lUseExclusive,.f.,cdPage)
   if !NetErr() .and. Used()
      lReturn := .t.
      exit
   endif
   inkey(.5)
   nTries--
   if nTries==0 .and. lAsk==.t.
      if MsgRetryCancel("Database is occupied by another user","No access")
         nTries := nTriesOrig
      endif
   endif
enddo
return lReturn
