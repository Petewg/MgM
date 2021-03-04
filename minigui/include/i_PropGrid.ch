/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

   "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@kresin.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - https://harbour.github.io/

   "Harbour Project"
   Copyright 1999-2021, https://harbour.github.io/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
     Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

EXTERNAL PROPGRIDONCUSTOMDRAW

#xcommand @ <row>,<col> PROPGRID  <name>       ;
   [ <dummy1: OF, PARENT> <parent> ] ;
   [ WIDTH <width> ] ;
   [ HEIGHT <height> ] ;
   FROMFILE <cFile> [<xml: XML>];
   [ HEADER <aheadname,...> ];
   [ FONT <fontname> ] ;
   [ SIZE <fontsize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ BACKCOLOR <backcolor> ] ;
   [ FONTCOLOR <fontcolor> ] ;
   [ INDENT    <indent>];
   [ ITEMHEIGHT <itemheight>];
   [ DATAWIDTH <datawidth> ] ;
   [ TOOLTIP <tooltip> ] ;
   [ < okbtn: OKBTN> [USEROKPROC <userokproc>] [ <apply: APPLYBTN> ]];
   [ < cancelbtn: CANCELBTN> [ USERCANCELPROC <usercancelproc> ] ] ;
   [ HELPBTN <helpproc> ] ;
   [ ON GOTFOCUS <gotfocus> ] ;
   [ ON CHANGE <change> ] ;
   [ ON CHANGEVALUE <changevalue> ] ;
   [ ON LOSTFOCUS <lostfocus> ] ;
   [ ON CLOSE <onclose> ] ;
   [ <itemexpand : ITEMEXPAND> ] ;
   [ <singleexpand : SINGLEEXPAND > ];
   [ < readonly: READONLY > ]    ;
   [ < iteminfo: ITEMINFO > [ INFOHEIGHT <nInfoHeight> ]] ;
   [ HELPID <helpid> ] ;
   [ IMAGELIST <imglist> ];
=>;
_DefinePropGrid ( <"name"> , <"parent"> , <row> , <col> , <width> , <height> , <{change}> ,<cFile>,<.xml.>,;
               <tooltip> , <fontname> , <fontsize> , <{gotfocus}> , <{lostfocus}> , <{onclose}>,.f.,;
              , <helpid>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.itemexpand.>,;
              <backcolor>, <fontcolor>, <indent>, <itemheight>, <datawidth> , <imglist>, <.readonly.>,;
              <.iteminfo.> , <nInfoHeight>, <{changevalue}>, \{<aheadname>\}, <.singleexpand.> ,;
              <.okbtn.>, <.apply.>, <{userokproc}>, <.cancelbtn.>, <{usercancelproc}>, <{helpproc}>)


#xcommand @ <row>,<col> PROPGRID  <name>      ;
   [ <dummy1: OF, PARENT> <parent> ] ;
   [ WIDTH <width> ] ;
   [ HEIGHT <height> ] ;
   ARRAYITEM <aProperty> ;
   [ HEADER <aheadname,...> ];
   [ FONT <fontname> ] ;
   [ SIZE <fontsize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ BACKCOLOR <backcolor> ] ;
   [ FONTCOLOR <fontcolor> ] ;
   [ INDENT    <indent>];
   [ ITEMHEIGHT <itemheight>];
   [ DATAWIDTH <datawidth> ] ;
   [ TOOLTIP <tooltip> ] ;
   [ < okbtn: OKBTN> [ USEROKPROC <userokproc>] [ <apply: APPLYBTN> ]] ;
   [ < cancelbtn: CANCELBTN> [ USERCANCELPROC <usercancelproc> ]] ;
   [ HELPBTN <helpproc> ] ;
   [ ON GOTFOCUS <gotfocus> ] ;
   [ ON CHANGE <change> ] ;
   [ ON CHANGEVALUE <changevalue> ] ;
   [ ON LOSTFOCUS <lostfocus> ] ;
   [ ON CLOSE <onclose> ] ;
   [ <itemexpand : ITEMEXPAND> ] ;
   [ <singleexpand : SINGLEEXPAND > ];
   [ < readonly: READONLY > ]    ;
   [ < iteminfo: ITEMINFO > [ INFOHEIGHT <nInfoHeight> ]] ;
   [ HELPID <helpid> ] ;
   [ IMAGELIST <imglist> ];
=>;
_DefinePropGrid ( <"name"> , <"parent"> , <row> , <col> , <width> , <height> , <{change}> ,"",.f.,;
               <tooltip> , <fontname> , <fontsize> , <{gotfocus}> , <{lostfocus}> , <{onclose}>,.f.,;
               <aProperty> , <helpid>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.itemexpand.>,;
              <backcolor>, <fontcolor>, <indent>, <itemheight>, <datawidth> , <imglist>, <.readonly.>,;
              <.iteminfo.> , <nInfoHeight>, <{changevalue}>, \{<aheadname>\}, <.singleexpand.> ,;
              <.okbtn.>, <.apply.>, <{userokproc}>, <.cancelbtn.>, <{usercancelproc}>, <{helpproc}>)


#xcommand DEFINE PROPGRID  <name>       ;
   [ <dummy1: OF, PARENT> <parent> ] ;
   AT <row>,<col>  ;
   [ WIDTH <width> ] ;
   [ HEIGHT <height> ] ;
   [ HEADER <aheadname,...> ];
   [ FONT <fontname> ] ;
   [ SIZE <fontsize> ] ;
   [ <bold : BOLD> ] ;
   [ <italic : ITALIC> ] ;
   [ <underline : UNDERLINE> ] ;
   [ <strikeout : STRIKEOUT> ] ;
   [ BACKCOLOR <backcolor> ] ;
   [ FONTCOLOR <fontcolor> ] ;
   [ INDENT    <indent>];
   [ ITEMHEIGHT <itemheight>];
   [ DATAWIDTH <datawidth> ] ;
   [ TOOLTIP <tooltip> ] ;
   [ < okbtn: OKBTN> [USEROKPROC <userokproc>] [ <apply: APPLYBTN> ]];
   [ < cancelbtn: CANCELBTN> [ USERCANCELPROC <usercancelproc> ] ] ;
   [ HELPBTN <helpproc> ] ;
   [ ON GOTFOCUS <gotfocus> ] ;
   [ ON CHANGE <change> ] ;
   [ ON CHANGEVALUE <changevalue> ] ;
   [ ON LOSTFOCUS <lostfocus> ] ;
   [ ON CLOSE <onclose> ] ;
   [ <itemexpand : ITEMEXPAND> ] ;
   [ <singleexpand : SINGLEEXPAND > ];
   [ < readonly: READONLY > ]    ;
   [ < iteminfo: ITEMINFO > [ INFOHEIGHT <nInfoHeight> ]] ;
   [ HELPID <helpid> ] ;
   [ IMAGELIST <imglist> ];
=>;
_DefinePropGrid ( <"name"> , <"parent"> , <row> , <col> , <width> , <height> , <{change}> ,"",.f.,;
               <tooltip> , <fontname> , <fontsize> , <{gotfocus}> , <{lostfocus}> , <{onclose}>,.f.,;
               , <helpid>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <.itemexpand.>,;
              <backcolor>, <fontcolor>, <indent>, <itemheight>, <datawidth> , <imglist>, <.readonly.>,;
              <.iteminfo.> , <nInfoHeight>, <{changevalue}>, \{<aheadname>\}, <.singleexpand.>,;
              <.okbtn.>, <.apply.>, <{userokproc}>, <.cancelbtn.>, <{usercancelproc}>, <{helpproc}>)


#xcommand CATEGORY <cName>  [ ID <id> ];
=>;
_DefinePropertyItem ( 'category', <cName>, "", "", .t.,.f., <id> )

#xcommand DEFINE CATEGORY <cName>  [ ID <id> ] ;
=>;
_DefinePropertyItem ( 'category', <cName>, "", "", .t.,.f., <id> )

#xcommand END CATEGORY ;
=>;
_EndCategory()


#xcommand PROPERTYITEM <cName>  ;
            [ <dummy1: OF, PARENT> <category> ] ;
            ITEMTYPE <ctype> ;
            VALUE <cValue> ;
            [ ITEMDATA <caData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName> ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( <ctype>, <cName>, <cValue>, <caData>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )

#xcommand PROPERTYITEM <cName>  ;
            [ <dummy1: OF, PARENT> <category> ] ;
            ITEMTYPE <ctype> ;
            VALUE <cValue> ;
            [ ITEMDATA <caData> ];
            WHEN <lEnabled> ;
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName> ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( <ctype>, <cName>, <cValue>, <caData>, !(ValType(<lEnabled>)=="L".and.<lEnabled>), <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM STRING <cName> ;
            VALUE <cValue> ;
            [ ITEMDATA <caData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'string', <cName>, <cValue>, <caData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM INTEGER <cName>;
            VALUE <cValue>;
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'integer', <cName>, <cValue>, "", <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM NUMERIC <cName>;
            VALUE <cValue>;
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'integer', <cName>, <cValue>, "", <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM DOUBLE <cName>  ;
            VALUE <cValue>  ;
            [ ITEMDATA <cInputMask> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'double', <cName>, <cValue>, <cInputMask>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM SYSCOLOR <cName> ;
            VALUE <nValue> ;
            [ ITEMDATA <aSysColorData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'syscolor', <cName>, <nValue>, <aSysColorData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"nValue"> )


#xcommand PROPERTYITEM COLOR <cName>  ;
            VALUE <cValue> ;
            [ ITEMDATA <aColorData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'color', <cName>, <cValue>, <aColorData>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM LOGIC <cName> ;
            VALUE <cValue> ;
            [ ITEMDATA <aData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'logic', <cName>, <cValue>, <aData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM DATE <cName> ;
            [ VALUE <cValue> ] ;
            [ ITEMDATA <aData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'date', <cName>, <cValue>, <aData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM FONT <cName> ;
            [ VALUE <cValue> ]  ;
            [ ITEMDATA <aFontData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'font', <cName>, <cValue>, <aFontData>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM ENUM <cName> ;
            VALUE <nValue> ;
            [ ITEMDATA <acData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'enum', <cName>, <nValue>, <acData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"nValue"> )


#xcommand PROPERTYITEM LIST <cName> ;
            VALUE <nValue> ;
            [ ITEMDATA <acData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'list', <cName>, <nValue>, <acData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"nValue"> )


#xcommand PROPERTYITEM FLAG <cName>  ;
            [ VALUE <cValue> ] ;
            [ ITEMDATA <acData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'flag', <cName>, <cValue>, <acData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM SYSINFO <cName> ;
            [ VALUE <cValue> ] ;
            [ ITEMDATA <cInfoType> ] ;
            [ <disabled : DISABLED> ] ;
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'sysinfo', <cName>, <cValue>, <cInfoType>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM IMAGE <cName>   ;
            [ VALUE <cValue> ] ;
            [ ITEMDATA <acDataFilter> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'image', <cName>, <cValue>, <acDataFilter>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM CHECK <cName> ;
            [ VALUE <cValue> ] ;
            [ ITEMDATA <acData> ] ;
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
=> ;
_DefinePropertyItem ( 'check', <cName>, <cValue>, <acData>, <.disabled.>, .f., <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM SIZE <cName>  ;
            [ VALUE <acValue> ] ;
            [ ITEMDATA <acData> ] ;
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'size', <cName>, <acValue>, <acData>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"acValue"> )


#xcommand PROPERTYITEM ARRAY <cName> ;
            [ VALUE <cValue> ] ;
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'array', <cName>, <cValue>, "", <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM FILE <cName>   ;
            [ VALUE <cValue> ] ;
            [ ITEMDATA <acDataFilter> ] ;
            [ <disabled : DISABLED> ] ;
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'file', <cName>, <cValue>, <acDataFilter>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM FOLDER <cName>   ;
            [ VALUE <cValue> ] ;
            [ ITEMDATA <acDataFolder> ] ;
            [ <disabled : DISABLED> ] ;
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'folder', <cName>, <cValue>, <acDataFolder>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand PROPERTYITEM USERFUN <cName> ;
            [ VALUE <cValue> ] ;
            ITEMDATA <cbDataFun> ;
            [ <disabled : DISABLED> ] ;
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'userfun', <cName>, <cValue>, <cbDataFun>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )

#xcommand PROPERTYITEM PASSWORD <cName> ;
            [ VALUE <cValue> ] ;
            ITEMDATA <cKeyPass> ;
            [ <disabled : DISABLED> ] ;
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_DefinePropertyItem ( 'password', <cName>, <cValue>, <cKeyPass>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand END PROPGRID ;
=> ;
_EndPropGrid()


#xcommand ADD PROPERTYITEM <name>  ;
            <dummy1: OF, PARENT> <parent> ;
            [CATEGORY <cCategory>] ;
            ITEMTYPE <ctype> ;
            NAMEITEM <cNameItem>;
            VALUE <cValue> ;
            [ ITEMDATA <caData> ];
            [ <disabled : DISABLED> ];
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
            [ VARNAME <cVarName>  ] ;
            [ <disableedit : DISABLEEDIT> ];
=> ;
_AddPropertyItem ( <"name"> , <"parent">, <cCategory>, <ctype>, <cNameItem>, <cValue>, <caData>, <.disabled.>, <.disableedit.>, <id>, <cInfo>, <cVarName>, <"cValue"> )


#xcommand ADD CATEGORY <name>  ;
            <dummy1: OF, PARENT> <parent> ;
            [TO CATEGORY <cParentCategory>] ;
            NAMECATEGORY <cNameCategory>;
            [ ID <id> ] ;
            [ INFO <cInfo> ] ;
=> ;
_AddPropertyCategory  (<"name"> , <"parent">, <cParentCategory>, <cNameCategory>, <id>, <cInfo> )


#xcommand GET PROPERTYITEM <name>;
            [ <dummy1: OF, PARENT> <parent> ] ;
            [ ID <id> ] ;
            [ SUBITEM <nSubItem> ] ;
            TO <value> ;
           => <value>:=GetPropGridValue (<"parent">, <"name">, <id>, .f., <nSubItem>  )


#xcommand GET INFO PROPERTYITEM <name>;
            [ <dummy1: OF, PARENT> <parent> ] ;
            [ ID <id> ] ;
            TO <ainfo> ;
           => <ainfo>:=GetPropGridValue ( <"parent">, <"name">, <id>, .t., 0  )

#xcommand GET CHANGED PROPERTYITEM <name>;
            [ <dummy1: OF, PARENT> <parent> ] ;
            TO <aIdItem> ;
           => <aIdItem>:=GetChangedItem ( <"parent">, <"name"> )

#xcommand SET PROPERTYITEM <name>  ;
            [ <dummy1: OF, PARENT> <parent> ] ;
            VALUE <value> ;
            [ITEMDATA <data>];
            [ ID <id> ] ;
            => SetPropGridValue ( <"parent">, <"name">, <id>, <value>, <data> )


#xcommand TOGGLE CATEGORY <name>  ;
            [ <dummy1: OF, PARENT> <parent> ] ;
            CATEGORY <cNameCategory> ;
            => ExpandCategPG ( <"parent">, <"name">, <cNameCategory>, 0 )

#xcommand EXPAND CATEGORY <name>  ;
            [ <dummy1: OF, PARENT> <parent> ] ;
            CATEGORY <cNameCategory> ;
            => ExpandCategPG ( <"parent">, <"name">, <cNameCategory>, 1 )

#xcommand COLLAPSE CATEGORY <name>  ;
            [ <dummy1: OF, PARENT> <parent> ] ;
            CATEGORY <cNameCategory> ;
            => ExpandCategPG ( <"parent">, <"name">, <cNameCategory>, 2 )


#xcommand ENABLE PROPERTYITEM <name>  ;
            [ <dummy1: OF, PARENT> <parent> ] ;
            [ ID <id> ] ;
            => EnablePropGridItem ( <"parent">, <"name">, <id>, .t. )

#xcommand DISABLE PROPERTYITEM <name>  ;
            [ <dummy1: OF, PARENT> <parent> ] ;
            [ ID <id> ] ;
            => EnablePropGridItem ( <"parent">, <"name">, <id>, .f. )


#xcommand REDRAW PROPERTYITEM <name>  ;
            [ <dummy1: OF, PARENT> <parent> ] ;
            [ ID <id> ] ;
            => RedrawPropGridItem ( <"parent">, <"name">, <id> )

#xcommand LOAD PROPERTY <name> ;
            <dummy1: OF, PARENT> <parent>  ;
            FROMFILE <cFile> [<xml: XML>];
            => PgLoadFile(<"parent">, <"name">, <cFile>, .xml.)


#xcommand SAVE MEMVALUE PROPERTY <name> OF <parent> ;
            => SaveMemVarible(<"parent">, <"name">)


///////////////////////////////////////////////////////////////////////////////

#define PG_DEFAULT  0
#define PG_CATEG    1
#define PG_STRING   2
#define PG_INTEGER  3
#define PG_DOUBLE   4
#define PG_SYSCOLOR 5
#define PG_COLOR    6
#define PG_LOGIC    7
#define PG_DATE     8
#define PG_FONT     9
#define PG_ARRAY    10
#define PG_ENUM     11
#define PG_FLAG     12
#define PG_SYSINFO  13
#define PG_IMAGE    14
#define PG_CHECK    15
#define PG_SIZE     16
#define PG_FILE     17
#define PG_FOLDER   18
#define PG_LIST     19
#define PG_USERFUN  20
#define PG_PASSWORD 21
#define PG_ERROR    99

#define PGI_ALLDATA  0
#define PGI_NAME     1
#define PGI_VALUE    2
#define PGI_DATA     3
#define PGI_ENAB     4
#define PGI_CHG      5
#define PGI_DIED     6
#define PGI_TYPE     7
#define PGI_ID       8
#define PGI_INFO     9
#define PGI_VAR     10

#define PGB_OK       7
#define PGB_APPLY    8
#define PGB_CANCEL   9
#define PGB_HELP     10


///////////////////////////////////////////////////////////////////////////////
