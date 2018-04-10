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
 	Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - https://harbour.github.io/

	"Harbour Project"
	Copyright 1999-2018, https://harbour.github.io/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

// WINDOWS (THIS)

#xtranslate This . <p:Title,NotifyIcon,NotifyTooltip,FocusedControl,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Topmost,HelpButton,Object> => GetProperty ( _HMG_THISFORMNAME , <"p"> )
#xtranslate This . <p:Title,NotifyIcon,NotifyTooltip,Cursor,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Topmost,HelpButton> := <arg> => SetProperty ( _HMG_THISFORMNAME , <"p"> , <arg> )
#xtranslate This . <p:Activate,Center,Redraw,Release,Maximize,Minimize,Restore> [ () ] => DoMethod ( _HMG_THISFORMNAME , <"p"> )

#xtranslate This . <c> . <p:ClientWidth>  => _GetClientRect ( GetControlHandle ( <"c"> , _HMG_THISFORMNAME ) ) \[3]
#xtranslate This . <c> . <p:ClientHeight> => _GetClientRect ( GetControlHandle ( <"c"> , _HMG_THISFORMNAME ) ) \[4]
#xtranslate This . <c> . <p:Value,Name,Handle,Type,Index,Address,BackColor,FontColor,Picture,Icon,HBitmap,ToolTip,FontName,FontSize,FontBold,FontUnderline,FontItalic,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo,Tabstop> => GetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> )
#xtranslate This . <c> . <p:Value,Name,Address,BackColor,FontColor,Picture,Icon,HBitmap,ToolTip,FontName,FontSize,FontBold,FontUnderline,FontItalic,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo,Tabstop> := <n> => SetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <n> )
#xtranslate This . <c> . <p:ListWidth,Position,CaretPos,ForeColor,AllowAppend,AllowDelete,AllowEdit,InputItems,DisplayItems,FormatString,Indent,Linecolor,ItemHeight,AutoFont,RichValue,CueBanner,Alignment,GradientFill,GradientOver,Object> => GetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> )
#xtranslate This . <c> . <p:ListWidth,Position,CaretPos,ForeColor,AllowAppend,AllowDelete,AllowEdit,Blink,InputItems,DisplayItems,FormatString,Indent,Linecolor,ItemHeight,AutoFont,RichValue,CueBanner,Alignment,GradientFill,GradientOver> := <n> => SetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <n> )
#xtranslate This . <c> . <p:Caption,Header,Image,Item,Icon,ToolTip,Width,ColumnWidth,Enabled,RichValue,HeaderImage,CheckboxItem> (<arg>) => GetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <arg> )
#xtranslate This . <c> . <p:Velocity> := <n> => SetProperty ( _HMG_THISFORMNAME, <"c"> , "Velocity" , <n> )
#xtranslate This . <c> . <p:Caption,Header,Image,Item,Icon,ToolTip,Width,ColumnWidth,Enabled,RichValue,CheckboxItem> (<arg>) := <n> => SetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <arg> , <n> )
#xtranslate This . <c> . <p:Cell> (<arg1> , <arg2>) => GetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <arg1> , <arg2> )
#xtranslate This . <c> . <p:Cell> (<arg1> , <arg2>) := <n> => SetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <arg1> , <arg2> , <n> )
#xtranslate This . <c> . <p:HeaderImage> (<arg1>) := <arg2> => SetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <arg1> , <arg2> )
#xtranslate This . <c> . <p:HeaderImage> (<arg1>) := {<arg2> , <arg3>} => SetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <arg1> , <arg2> , <arg3> )
#xtranslate This . <c> . <p:EnableUpdate,DisableUpdate,Redraw,Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick,ColumnsAutoFit,ColumnsAutoFitH> \[()\] => Domethod ( _HMG_THISFORMNAME, <"c"> , <"p"> )
#xtranslate This . <c> . <p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek,ColumnAutoFit,ColumnAutoFitH> (<a>) => Domethod ( _HMG_THISFORMNAME, <"c"> , <"p"> , <a> )
#xtranslate This . <c> . <p:AddItem,AddPage> (<a1> , <a2>) => Domethod ( _HMG_THISFORMNAME, <"c"> , <"p"> , <a1> , <a2> )
#xtranslate This . <c> . <p:AddItem,AddPage> (<a1> , <a2> , <a3> ) => Domethod ( _HMG_THISFORMNAME, <"c"> , <"p"> , <a1> , <a2> , <a3> )
#xtranslate This . <c> . <p:AddItem,AddColumn,AddControl,AddPage> (<a1> , <a2> , <a3> , <a4> ) => Domethod ( _HMG_THISFORMNAME, <"c"> , <"p"> , <a1> , <a2> , <a3> , <a4> )
#xtranslate This . <c> . <p:ReadOnly,DisableEdit,Length> => GetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> )
#xtranslate This . <c> . <p:ReadOnly,DisableEdit,Speed,Volume,Zoom,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick> := <n> => SetProperty ( _HMG_THISFORMNAME, <"c"> , <"p"> , <n> )
#xtranslate This . <x> . <c> . <p:Caption,Enabled,Value> => GetProperty ( _HMG_THISFORMNAME , <"x"> , <"c"> , <"p"> )
#xtranslate This . <x> . <c> . <p:Caption,Enabled,Value> := <n> => SetProperty ( _HMG_THISFORMNAME , <"x"> , <"c"> , <"p"> , <n> )
#xtranslate This . <x> (<k>) . <c> . <p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo> => GetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> )
#xtranslate This . <x> (<k>) . <c> . <p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo> := <n> => SetProperty ( _HMG_THISFORMNAME , <"x"> , <k> , <"c"> , <"p"> , <n> )
#xtranslate This . <x> (<k>) . <c> . <p:ListWidth,Position,CaretPos,ForeColor,RichValue> => GetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> )
#xtranslate This . <x> (<k>) . <c> . <p:ListWidth,Position,CaretPos,ForeColor,RichValue> := <n> => SetProperty ( _HMG_THISFORMNAME , <"x"> , <k> , <"c"> , <"p"> , <n> )
#xtranslate This . <x> (<k>) . <c> . <p:Caption,Header,Item,Icon,RichValue,CheckboxItem> (<arg>) => GetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <arg> )
#xtranslate This . <x> (<k>) . <c> . <p:Caption,Header,Item,Icon,RichValue,CheckboxItem> (<arg>) := <n> => SetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <arg> , <n> )
#xtranslate This . <x> (<k>) . <c> . <p:Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick> \[()\] => Domethod ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> )
#xtranslate This . <x> (<k>) . <c> . <p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek> (<a>) => Domethod ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <a> )
#xtranslate This . <x> (<k>) . <c> . <p:AddItem,AddPage> (<a1> , <a2>) => Domethod ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <a1> , <a2> )
#xtranslate This . <x> (<k>) . <c> . <p:AddItem,AddPage> (<a1> , <a2> , <a3> ) => Domethod ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <a1> , <a2> , <a3> )
#xtranslate This . <x> (<k>) . <c> . <p:AddItem,AddColumn,AddControl,AddPage> (<a1> , <a2> , <a3> , <a4> ) => Domethod ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <a1> , <a2> , <a3> , <a4> )
#xtranslate This . <x> (<k>) . <c> . <p:Length> => GetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> )
#xtranslate This . <x> (<k>) . <c> . <p:ReadOnly,DisableEdit,Speed,Volume,Zoom> := <n> => SetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <n> )
#xtranslate This . <x> (<k>) . <c> . <p:Cell> (<arg1> , <arg2>) => GetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <arg1> , <arg2> )
#xtranslate This . <x> (<k>) . <c> . <p:Cell> (<arg1> , <arg2>) := <n> => SetProperty ( _HMG_THISFORMNAME, <"x"> , <k> , <"c"> , <"p"> , <arg1> , <arg2> , <n> )
#xtranslate This . SplitBox  . <c> . <p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Position,CaretPos,ForeColor,AllowEdit,Object,InputItems,DisplayItems,Cargo> => GetProperty ( _HMG_THISFORMNAME, "SplitBox" , <"c"> , <"p"> )
#xtranslate This . SplitBox  . <c> . <p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Position,CaretPos,ForeColor,AllowEdit,Blink,InputItems,DisplayItems,Cargo> := <n> => SetProperty ( _HMG_THISFORMNAME, "SplitBox" , <"c"> , <"p"> , <n> )
#xtranslate This . SplitBox  . <c> . <p:AllowAppend,AllowDelete,DisableEdit,ReadOnly> => GetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> )
#xtranslate This . SplitBox  . <c> . <p:AllowAppend,AllowDelete,DisableEdit,ReadOnly> := <n> => SetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <n> )
#xtranslate This . SplitBox  . <c> . <p:Caption,Header,Item,Icon,HeaderImages,CheckboxItem> (<arg>) => GetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <arg> )
#xtranslate This . SplitBox  . <c> . <p:Caption,Header,Item,Icon,HeaderImages,CheckboxItem> (<arg>) := <n> => SetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <arg> , <n> )
#xtranslate This . SplitBox  . <c> . <p:Cell> (<arg1> , <arg2>) => GetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <arg1> , <arg2> )
#xtranslate This . SplitBox  . <c> . <p:Cell> (<arg1> , <arg2>) := <n> => SetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <arg1> , <arg2> , <n> )
#xtranslate This . SplitBox  . <c> . <p:Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick> \[()\] => Domethod ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> )
#xtranslate This . SplitBox  . <c> . <p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek> (<a>) => Domethod ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <a> )
#xtranslate This . SplitBox  . <c> . <p:AddItem,AddPage> (<a1> , <a2>) => Domethod ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <a1> , <a2> )
#xtranslate This . SplitBox  . <c> . <p:AddItem,AddPage> (<a1> , <a2> , <a3> ) => Domethod ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <a1> , <a2> , <a3> )
#xtranslate This . SplitBox  . <c> . <p:AddItem,AddColumn,AddControl,AddPage> (<a1> , <a2> , <a3> , <a4> ) => Domethod ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <a1> , <a2> , <a3> , <a4> )
#xtranslate This . SplitBox  . <c> . <p:Name,Length> => GetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> )
#xtranslate This . SplitBox  . <c> . <p:ReadOnly,DisableEdit,Speed,Volume,Zoom> := <n> => SetProperty ( _HMG_THISFORMNAME, "SplitBox", <"c"> , <"p"> , <n> )
#xtranslate This . SplitBox  . <x> . <c> . <p:Caption,Enabled,Value> => GetProperty ( _HMG_THISFORMNAME , "SplitBox" , <"x"> , <"c"> , <"p"> )
#xtranslate This . SplitBox  . <x> . <c> . <p:Caption,Enabled,Value> := <n> => SetProperty ( _HMG_THISFORMNAME , "SplitBox", <"x"> , <"c"> , <"p"> , <n> )

// WINDOWS (THISWINDOW)

#xtranslate ThisWindow . <p:Title,NotifyIcon,NotifyTooltip,FocusedControl,BackColor,Name,Handle,Type,Index,Row,Col,Width,Height,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Topmost,HelpButton,Cargo,Object> => GetProperty ( _HMG_THISFORMNAME , <"p"> )
#xtranslate ThisWindow . <p:Title,NotifyIcon,NotifyTooltip,Cursor,BackColor,Row,Col,Width,Height,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Topmost,HelpButton,Cargo> := <arg> => SetProperty ( _HMG_THISFORMNAME , <"p"> , <arg> )
#xtranslate ThisWindow . <p:Activate,Center,Redraw,Release,Maximize,Minimize,Restore,Show,Hide,SetFocus> [ () ] => DoMethod ( _HMG_THISFORMNAME , <"p"> )
#xtranslate ThisWindow . <p:ClientWidth>  => _GetClientRect ( GetFormHandle ( _HMG_THISFORMNAME ) ) \[3]
#xtranslate ThisWindow . <p:ClientHeight> => _GetClientRect ( GetFormHandle ( _HMG_THISFORMNAME ) ) \[4]

// CONTROLS

* Property without arguments

#xtranslate This . <p:FontColor,ForeColor,Value,ReadOnly,DisableEdit,Address,Picture,Icon,HBitmap,Tooltip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeout,Caption,Displayvalue,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Length,Position,CaretPos,CueBanner,Alignment,GradientFill,GradientOver> => GetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> )
#xtranslate This . <p:FontColor,ForeColor,Value,ReadOnly,DisableEdit,Address,Picture,Icon,HBitmap,Tooltip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeout,Caption,DisplayValue,Visible,Enabled,Checked,RangeMin,RangeMax,Repeat,Speed,Volume,Zoom,Position,CaretPos,Action,Blink,Alignment,CueBanner,GradientFill,GradientOver> := <arg> => SetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <arg> )

* Property with 1 argument

#xtranslate This . <p:Item,Caption,Header,Icon,Width,ColumnWidth,Enabled> (<n>) => GetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <n> )
#xtranslate This . <p:Item,Caption,Header,Icon,Width,ColumnWidth,Enabled> (<n>) := <arg> => SetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <n> , <arg> )

* Property with 2 arguments

#xtranslate This . <p:Cell> ( <n1> , <n2> ) => GetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <n1> , <n2> )
#xtranslate This . <p:Cell> ( <n1> , <n2> ) := <arg> 	=> SetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <n1> , <n2> , <arg> )

* Method without arguments

#xtranslate This . <p:Redraw,Refresh,DeleteAllItems,Release,Play,Stop,Close,PlayReverse,Pause,Eject,OpenDialog,Resume,Save,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick,EnableUpdate,DisableUpdate,ColumnAutoFit,ColumnAutoFitH> [ () ] => DoMethod ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> )

* Method with 1 argument

#xtranslate This . <p:AddItem,DeleteItem,Open,Seek,SetArray,DeletePage,DeleteColumn,Expand,Collapse> (<arg>) => DoMethod ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <arg> )

* Method with 2 arguments

#xtranslate This . <p:AddItem,AddPage> ( <arg1> , <arg2> )	=> DoMethod ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <arg1> , <arg2> )

* Method with 3 arguments

#xtranslate This . <p:AddItem,AddPage> ( <arg1>,<arg2>,<arg3> )	=> DoMethod ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <arg1> , <arg2> , <arg3> )

* Method with 4 arguments

#xtranslate This . <p:AddItem,AddControl,AddColumn,AddPage> ( <arg1> , <arg2> , <arg3> , <arg4> ) => DoMethod ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <arg1> , <arg2> , <arg3> , <arg4> )


// COMMON ( REQUIRES TYPE CHECK )

#xtranslate This . <p:Name,Handle,Type,Index,Row,Col,Width,Height,BackColor,Cargo,Object> => iif ( _HMG_THISType == 'C' , GetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> ) , GetProperty ( _HMG_THISFORMNAME , <"p"> ) )
#xtranslate This . <p:Row,Col,Width,Height,BackColor,Cargo> := <arg> => iif ( _HMG_THISType == 'C' , SetProperty ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> , <arg> ) , SetProperty ( _HMG_THISFORMNAME , <"p"> , <arg> ) )
#xtranslate This . <p:Show,Hide,SetFocus> [ () ] => iif ( _HMG_THISType == 'C' , DoMethod ( _HMG_THISFORMNAME , _HMG_THISCONTROLNAME , <"p"> ) , DoMethod ( _HMG_THISFORMNAME , <"p"> ) )
#xtranslate This . <p:ClientWidth>  => _GetClientRect ( iif ( _HMG_THISType == 'C' , GetControlHandle ( _HMG_THISCONTROLNAME , _HMG_THISFORMNAME ) , GetFormHandle ( _HMG_THISFORMNAME ) ) ) \[3]
#xtranslate This . <p:ClientHeight> => _GetClientRect ( iif ( _HMG_THISType == 'C' , GetControlHandle ( _HMG_THISCONTROLNAME , _HMG_THISFORMNAME ) , GetFormHandle ( _HMG_THISFORMNAME ) ) ) \[4]

// EVENT PROCEDURES

#xtranslate This . QueryRowIndex => _HMG_THISQueryRowIndex
#xtranslate This . QueryColIndex => _HMG_THISQueryColIndex
#xtranslate This . QueryData => _HMG_THISQueryData
#xtranslate This . CellRowIndex => _HMG_THISItemRowIndex
#xtranslate This . CellColIndex => _HMG_THISItemColIndex
#xtranslate This . CellRow => _HMG_THISItemCellRow
#xtranslate This . CellCol => _HMG_THISItemCellCol
#xtranslate This . CellWidth => _HMG_THISItemCellWidth
#xtranslate This . CellHeight => _HMG_THISItemCellHeight
#xtranslate This . CellValue => _HMG_THISItemCellValue
#xtranslate This . CellValue := <arg> => _SetGridCellEditValue ( <arg> ) 
