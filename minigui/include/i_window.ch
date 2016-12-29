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
	www - http://harbour-project.org

	"Harbour Project"
	Copyright 1999-2016, http://harbour-project.org/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

// DECLARE WINDOW Translate Map (Semi-OOP Properties/Methods Access)

#ifdef _SOOP_CONTAINERS_

// 1. Window Property Get
// 2. Window Property Set
// 3. Window Methods
// 4. Standard Controls Properties
// 5. ToolBar Child Buttons Properties
// 6. Tab Child Controls Properties
// 7. SplitBox Child Controls Properties
// 8. SplitBox Child ToolBar Buttons

   #xcommand DECLARE WINDOW <w> ;
   =>;
   #xtranslate <w>   . \<p:Name,Handle,Type,Index,Title,Height,Width,ClientHeight,ClientWidth,Col,Row,NotifyIcon,NotifyToolTip,FocusedControl,BackColor,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Closable,Topmost,HelpButton\> => GetProperty ( <"w">, \<"p"\> ) ;;
   #xtranslate <w>   . \<p:Name,Title,Height,Width,Col,Row,NotifyIcon,NotifyToolTip,FocusedControl,Cursor,BackColor,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Closable,Topmost,HelpButton\> := \<n\> => SetProperty ( <"w">, \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<p:Activate,Center,Release,Maximize,Minimize,Restore,Show,Hide,SetFocus\> \[()\] => DoMethod ( <"w">, \<"p"\> ) ;;
   #xtranslate <w>   . \<p:SaveAs\> (\<a\>) => DoMethod ( <"w"> , "SaveAs", \<a\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:SaveAs\> (\<a\>) => DoMethod ( <"w"> , \<"c"\> , "SaveAs", \<a\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Value,Name,Handle,Type,Index,ClientHeight,ClientWidth,Address,BackColor,FontColor,Picture,Icon,ToolTip,FontName,FontSize,FontBold,FontUnderline,FontItalic,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo,Tabstop,Object\> => GetProperty ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Value,Name,Address,BackColor,FontColor,Picture,Icon,ToolTip,FontName,FontSize,FontBold,FontUnderline,FontItalic,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo,Tabstop\> := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,AllowAppend,AllowDelete,AllowEdit,InputItems,DisplayItems,FormatString,Indent,Linecolor,ItemHeight,AutoFont,RichValue,CueBanner\> => GetProperty ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,AllowAppend,AllowDelete,AllowEdit,Blink,InputItems,DisplayItems,FormatString,Indent,Linecolor,ItemHeight,AutoFont,RichValue,CueBanner\> := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Caption,Header,Image,Item,Icon,ToolTip,Width,ColumnWidth,Enabled,RichValue,HeaderImage,CheckboxItem\> (\<arg\>) => GetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Velocity\> := \<n\> => SetProperty ( <"w">, \<"c"\> , "Velocity" , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Caption,Header,Image,Item,Icon,ToolTip,Width,ColumnWidth,Enabled,RichValue,CheckboxItem\> (\<arg\>) := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) => GetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:HeaderImage\> (\<arg1\>) := \<arg2\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:HeaderImage\> (\<arg1\>) := {\<arg2\> , \<arg3\>} => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> , \<arg3\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:EnableUpdate,DisableUpdate,Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick,ColumnsAutoFit,ColumnsAutoFitH\> \[()\] => Domethod ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek,SetArray,ColumnAutoFit,ColumnAutoFitH\> (\<a\>) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\>) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a1\> , \<a2\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\> , \<a3\> ) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,AddColumn,AddControl,AddPage\> (\<a1\> , \<a2\> , \<a3\> , \<a4\> ) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> , \<a4\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ReadOnly,DisableEdit,Length\> => GetProperty ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ReadOnly,DisableEdit,Speed,Volume,Zoom,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick\> := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> . \<c\> . \<p:Caption,ToolTip,Picture,Enabled,Value\> => GetProperty ( <"w"> , \<"x"\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> . \<c\> . \<p:Caption,ToolTip,Picture,PictureIndex,Action,Enabled,Value\> := \<n\> => SetProperty ( <"w"> , \<"x"\> , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo\> => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo\> := \<n\> => SetProperty ( <"w"> , \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,RichValue\> => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,RichValue\> := \<n\> => SetProperty ( <"w"> , \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Caption,Header,Item,Icon,RichValue,CheckboxItem\> (\<arg\>) => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<arg\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Caption,Header,Item,Icon,RichValue,CheckboxItem\> (\<arg\>) := \<n\> => SetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<arg\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick\> \[()\] => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek\> (\<a\>) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\>) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a1\> , \<a2\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\> , \<a3\> ) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,AddColumn,AddControl,AddPage\> (\<a1\> , \<a2\> , \<a3\> , \<a4\> ) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> , \<a4\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Length\> => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:ReadOnly,DisableEdit,Speed,Volume,Zoom\> := \<n\> => SetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) := \<n\> => SetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> , \<n\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Position,CaretPos,ForeColor,AllowEdit,Object,InputItems,DisplayItems,Cargo\> => GetProperty ( <"w">, "SplitBox" , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Value,Name,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Position,CaretPos,ForeColor,AllowEdit,Blink,InputItems,DisplayItems,Cargo\> := \<n\> => SetProperty ( <"w">, "SplitBox" , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:AllowAppend,AllowDelete,DisableEdit,ReadOnly\> => GetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:AllowAppend,AllowDelete,DisableEdit,ReadOnly\> := \<n\> => SetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Caption,Header,Item,Icon,HeaderImages,CheckboxItem\> (\<arg\>) => GetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<arg\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Caption,Header,Item,Icon,HeaderImages,CheckboxItem\> (\<arg\>) := \<n\> => SetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<arg\> , \<n\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) => GetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) := \<n\> => SetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> , \<n\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick\> \[()\] => Domethod ( <"w">, "SplitBox", \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek\> (\<a\>) => Domethod ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<a\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\>) => Domethod ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<a1\> , \<a2\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\> , \<a3\> ) => Domethod ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:AddItem,AddColumn,AddControl,AddPage\> (\<a1\> , \<a2\> , \<a3\> , \<a4\> ) => Domethod ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> , \<a4\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:Name,Length,CueBanner\> => GetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . SplitBox . \<c\> . \<p:ReadOnly,DisableEdit,Speed,Volume,Zoom,CueBanner\> := \<n\> => SetProperty ( <"w">, "SplitBox", \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . SplitBox . \<x\> . \<c\> . \<p:Caption,Enabled,Value\> => GetProperty ( <"w"> , "SplitBox" , \<"x"\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . SplitBox . \<x\> . \<c\> . \<p:Caption,Enabled,Value\> := \<n\> => SetProperty ( <"w"> , "SplitBox", \<"x"\> , \<"c"\> , \<"p"\> , \<n\> ) 

#else

   #xcommand DECLARE WINDOW <w> ;
   =>;
   #xtranslate <w>   . \<p:Name,Handle,Type,Index,Title,Height,Width,ClientHeight,ClientWidth,Col,Row,NotifyIcon,NotifyToolTip,FocusedControl,BackColor,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Closable,Topmost,HelpButton\> => GetProperty ( <"w">, \<"p"\> ) ;;
   #xtranslate <w>   . \<p:Name,Title,Height,Width,Col,Row,NotifyIcon,NotifyToolTip,FocusedControl,Cursor,BackColor,MinHeight,MinWidth,MaxHeight,MaxWidth,TitleBar,SysMenu,Sizable,MaxButton,MinButton,Closable,Topmost,HelpButton\> := \<n\> => SetProperty ( <"w">, \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<p:Activate,Center,Release,Maximize,Minimize,Restore,Show,Hide,SetFocus\> \[()\] => DoMethod ( <"w">, \<"p"\> ) ;;
   #xtranslate <w>   . \<p:SaveAs\> (\<a\>) => DoMethod ( <"w"> , "SaveAs", \<a\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:SaveAs\> (\<a\>) => DoMethod ( <"w"> , \<"c"\> , "SaveAs", \<a\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Value,Name,Handle,Type,Index,ClientHeight,ClientWidth,Address,BackColor,FontColor,Picture,Icon,ToolTip,FontName,FontSize,FontBold,FontUnderline,FontItalic,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo,Tabstop\> => GetProperty ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Value,Name,Address,BackColor,FontColor,Picture,Icon,ToolTip,FontName,FontSize,FontBold,FontUnderline,FontItalic,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo,Tabstop\> := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,AllowAppend,AllowDelete,AllowEdit,InputItems,DisplayItems,FormatString,Indent,Linecolor,ItemHeight,AutoFont,RichValue,CueBanner\> => GetProperty ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,AllowAppend,AllowDelete,AllowEdit,Blink,InputItems,DisplayItems,FormatString,Indent,Linecolor,ItemHeight,AutoFont,RichValue,CueBanner\> := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Velocity\> := \<n\> => SetProperty ( <"w">, \<"c"\> , "Velocity" , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Caption,Header,Image,Item,Icon,ToolTip,Width,ColumnWidth,Enabled,RichValue,HeaderImage,CheckboxItem\> (\<arg\>) => GetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Caption,Header,Image,Item,Icon,ToolTip,Width,ColumnWidth,Enabled,RichValue,CheckboxItem\> (\<arg\>) := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) => GetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:Cell\> (\<arg1\> , \<arg2\>) := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> , \<n\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:HeaderImage\> (\<arg1\>) := \<arg2\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:HeaderImage\> (\<arg1\>) := {\<arg2\>,\<arg3\>} => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<arg1\> , \<arg2\> , \<arg3\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:EnableUpdate,DisableUpdate,Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick,ColumnsAutoFit,ColumnsAutoFitH\> \[()\] => Domethod ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek,ColumnAutoFit,ColumnAutoFitH\> (\<a\>) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\>) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a1\> , \<a2\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\> , \<a3\>) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:AddItem,AddColumn,AddControl,AddPage\> (\<a1\> , \<a2\> , \<a3\> , \<a4\> ) => Domethod ( <"w">, \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> , \<a4\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ReadOnly,DisableEdit,Length\> => GetProperty ( <"w">, \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<c\> . \<p:ReadOnly,DisableEdit,Speed,Volume,Zoom,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick\> := \<n\> => SetProperty ( <"w">, \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> . \<c\> . \<p:Caption,Picture,Enabled,Value\> => GetProperty ( <"w"> , \<"x"\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> . \<c\> . \<p:Caption,Picture,PictureIndex,Action,Enabled,Value\> := \<n\> => SetProperty ( <"w"> , \<"x"\> , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Value,Name,Value,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo\> => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Value,Name,Value,Address,BackColor,FontColor,Picture,ToolTip,FontName,FontSize,FontBold,FontItalic,FontUnderline,FontStrikeOut,Caption,Row,DisplayValue,Col,Width,Height,Visible,Enabled,Checked,ItemCount,RangeMin,RangeMax,Cargo\> := \<n\> => SetProperty ( <"w"> , \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,RichValue\> => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:ListWidth,Position,CaretPos,ForeColor,RichValue\> := \<n\> => SetProperty ( <"w"> , \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Caption,Header,Item,Icon,RichValue,CheckboxItem\> (\<arg\>) => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<arg\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Caption,Header,Item,Icon,RichValue,CheckboxItem\> (\<arg\>) := \<n\> => SetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<arg\> , \<n\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Refresh,SetFocus,DeleteAllItems,Release,Show,Save,Hide,Play,Stop,Close,Pause,Eject,OpenDialog,Resume,Action,OnClick,OnGotFocus,OnLostFocus,OnChange,OnDblClick\> \[()\] => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,DeleteItem,Open,DeletePage,DeleteColumn,Expand,Collapse,Seek\> (\<a\>) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\>) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a1\> , \<a2\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,AddPage\> (\<a1\> , \<a2\> , \<a3\>) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:AddItem,AddColumn,AddControl,AddPage\> (\<a1\> , \<a2\> , \<a3\> , \<a4\> ) => Domethod ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<a1\> , \<a2\> , \<a3\> , \<a4\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:Length\> => GetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> ) ;;
   #xtranslate <w>   . \<x\> (\<k\>) . \<c\> . \<p:ReadOnly,DisableEdit,Speed,Volume,Zoom\> := \<n\> => SetProperty ( <"w">, \<"x"\> , \<k\> , \<"c"\> , \<"p"\> , \<n\> )

#endif

   #xcommand DEFINE WINDOW <w> ;
         [ AT <row>,<col> ] ;
         [ ROW <row> ] ;
         [ COL <col> ] ;
         [ WIDTH <wi> ] ;
         [ HEIGHT <h> ] ;
         [ MINWIDTH <minWidth> ] ;
         [ MINHEIGHT <minHeight> ] ;
         [ MAXWIDTH <maxWidth> ] ;
         [ MAXHEIGHT <maxHeight> ] ;
         [ VIRTUAL WIDTH <vWidth> ] ;
         [ VIRTUAL HEIGHT <vHeight> ] ;
         [ CLIENTAREA <clientwidth>,<clientheight> ] ;
         [ TITLE <title> ] ;
         [ ICON <icon> ] ;
         [ WINDOWTYPE ] ;
         [ MODAL ] ;
         [ <noshow: NOSHOW> ] ;
         [ <noautorelease: NOAUTORELEASE> ] ;
         [ <nosize: NOSIZE> ] ;
         [ <nosysmenu: NOSYSMENU> ] ;
         [ <nocaption: NOCAPTION> ] ;
         [ CURSOR <cursor> ] ;
         [ ON INIT <InitProcedure> ] ;
         [ ON RELEASE <ReleaseProcedure> ] ;
         [ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
         [ ON MOUSECLICK <ClickProcedure> ] ;
         [ ON MOUSEDRAG <MouseDragProcedure> ] ;
         [ ON MOUSEMOVE <MouseMoveProcedure> ] ;
         [ ON MOVE <MoveProcedure> ] ;
         [ ON SIZE <SizeProcedure> ] ;
         [ ON PAINT <PaintProcedure> ] ;
         [ ON DROPFILES <DropProcedure> ] ;
         [ <dummy: BACKCOLOR, BKBRUSH> <backcolor> ] ;
         [ FONT <FontName> SIZE <FontSize> ] ;
         [ ON GOTFOCUS <GotFocusProcedure> ] ;
         [ ON LOSTFOCUS <LostFocusProcedure> ] ;
         [ ON SCROLLUP <scrollup> ] ;
         [ ON SCROLLDOWN <scrolldown> ] ;
         [ ON SCROLLLEFT <scrollleft> ] ;
         [ ON SCROLLRIGHT <scrollright> ] ;
         [ ON HSCROLLBOX <hScrollBox> ] ;
         [ ON VSCROLLBOX <vScrollBox> ] ;
         [ <helpbutton: HELPBUTTON> ] ;
   =>;
   DECLARE WINDOW <w>  ;;
   _DefineModalWindow ( <"w">, <title>, <col>, <row>, <wi>, <h>, "" , <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>, <minHeight>}, {<maxWidth>, <maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}> , <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>]  , <{PaintProcedure}> , <icon> , <FontName> , <FontSize> , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <cursor> , <.noshow.> , <.noautorelease.> , <{interactivecloseprocedure}> , <{MoveProcedure}> , <{DropProcedure}> , <clientwidth> , <clientheight> )


   #xcommand DEFINE WINDOW <w> ;
         [ <dummy1: OF, PARENT> <parent> ] ;
         [ AT <row>,<col> ] ;
         [ ROW <row> ] ;
         [ COL <col> ] ;
         [ WIDTH <wi> ] ;
         [ HEIGHT <h> ] ;
         [ MINWIDTH <minWidth> ] ;
         [ MINHEIGHT <minHeight> ] ;
         [ MAXWIDTH <maxWidth> ] ;
         [ MAXHEIGHT <maxHeight> ] ;
         [ VIRTUAL WIDTH <vWidth> ] ;
         [ VIRTUAL HEIGHT <vHeight> ] ;
         [ CLIENTAREA <clientwidth>,<clientheight> ] ;
         [ TITLE <title> ] ;
         [ ICON <icon> ] ;
         [ <main:  MAIN> ] ;
         [ <mdi: MDI> ] ;
         [ <child: CHILD> ] ;
         [ <panel: PANEL> ] ;
         [ <main:  WINDOWTYPE MAIN> ] ;
         [ <child: WINDOWTYPE CHILD> ] ;
         [ <panel: WINDOWTYPE PANEL> ] ;
         [ WINDOWTYPE STANDARD ] ;
         [ <noshow: NOSHOW> ] ;
         [ <topmost: TOPMOST> ] ;
         [ <palette: PALETTE> ] ;
         [ <noautorelease: NOAUTORELEASE> ] ;
         [ <nominimize: NOMINIMIZE> ] ;
         [ <nomaximize: NOMAXIMIZE> ] ;
         [ <nosize: NOSIZE> ] ;
         [ <nosysmenu: NOSYSMENU> ] ;
         [ <nocaption: NOCAPTION> ] ;
         [ CURSOR <cursor> ] ;
         [ ON INIT <InitProcedure> ] ;
         [ ON RELEASE <ReleaseProcedure> ] ;
         [ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
         [ ON MOUSECLICK <ClickProcedure> ] ;
         [ ON MOUSEDRAG <MouseDragProcedure> ] ;
         [ ON MOUSEMOVE <MouseMoveProcedure> ] ;
         [ ON MOVE <MoveProcedure> ] ;
         [ ON SIZE <SizeProcedure> ] ;
         [ ON MAXIMIZE <MaximizeProcedure> ] ;
         [ ON MINIMIZE <MinimizeProcedure> ] ;
         [ ON RESTORE <RestoreProcedure> ] ;
         [ ON PAINT <PaintProcedure> ] ;
         [ ON DROPFILES <DropProcedure> ] ;
         [ <dummy2: BACKCOLOR, BKBRUSH> <backcolor> ] ;
         [ FONT <FontName> SIZE <FontSize> ] ;
         [ NOTIFYICON <NotifyIcon> ] ;
         [ NOTIFYTOOLTIP <NotifyIconTooltip> ] ;
         [ ON NOTIFYCLICK <NotifyLeftClick> ] ;
         [ ON NOTIFYDBLCLICK <NotifyDblClick> ] ;
         [ ON NOTIFYBALLOONCLICK <NotifyBalloonClick> ] ;
         [ ON GOTFOCUS <GotFocusProcedure> ] ;
         [ ON LOSTFOCUS <LostFocusProcedure> ] ;
         [ ON SCROLLUP <scrollup> ] ;
         [ ON SCROLLDOWN <scrolldown> ] ;
         [ ON SCROLLLEFT <scrollleft> ] ;
         [ ON SCROLLRIGHT <scrollright> ] ;
         [ ON HSCROLLBOX <hScrollBox> ] ;
         [ ON VSCROLLBOX <vScrollBox> ] ;
         [ <helpbutton: HELPBUTTON> ] ;
   =>;
   DECLARE WINDOW <w>  ;;
   DECLARE CUSTOM COMPONENTS <w> ;;
   _DefineWindow ( <"w">, <title>, <col>, <row>, <wi>, <h>, <.nominimize.>, <.nomaximize.>, <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>, <minHeight>}, {<maxWidth>, <maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}>, <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>] , <{PaintProcedure}> , <.noshow.> , <.topmost.> , <.main.> , <icon> , <.child.> , <FontName> , <FontSize>, <NotifyIcon> , <NotifyIconTooltip> , <{NotifyLeftClick}>  , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight> , <vWidth> , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <{MaximizeProcedure}> , <{MinimizeProcedure}> , <cursor> , <.noautorelease.> , <{interactivecloseprocedure}> , <{RestoreProcedure}> , <{MoveProcedure}> , <{DropProcedure}> , <.mdi.> , <.palette.> , <{NotifyDblClick}> , <"parent"> , <.panel.> , <{NotifyBalloonClick}> , <clientwidth> , <clientheight> )


   #xcommand DEFINE WINDOW <w> ;
      WIDTH <wi> ;
      HEIGHT <h> ;
      [ VIRTUAL WIDTH <vWidth> ] ;
      [ VIRTUAL HEIGHT <vHeight> ] ;
      [ TITLE <title> ] ;
      SPLITCHILD ;
      [ <nocaption: NOCAPTION> ] ;
      [ CURSOR <cursor> ] ;
      [ FONT <FontName> SIZE <FontSize> ] ;
      [ GRIPPERTEXT <grippertext> ] ;
      [ <break: BREAK> ] ;
      [ <focused: FOCUSED> ] ;
      [ ON GOTFOCUS <GotFocusProcedure> ] ;
      [ ON LOSTFOCUS <LostFocusProcedure> ] ;
      [ ON SCROLLUP <scrollup> ] ;
      [ ON SCROLLDOWN <scrolldown> ] ;
      [ ON SCROLLLEFT <scrollleft> ] ;
      [ ON SCROLLRIGHT <scrollright> ] ;
      [ ON HSCROLLBOX <hScrollBox> ] ;
      [ ON VSCROLLBOX <vScrollBox> ] ;
   => ;
   DECLARE WINDOW <w>  ;;
   _DefineSplitChildWindow ( <"w">, <wi>, <h> , <.break.> , <grippertext> , <.nocaption.> , <title> , <FontName> , <FontSize> , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth> , <.focused.>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <cursor> )


   #xcommand DEFINE WINDOW <w> ;
	[ AT <row>,<col> ] ;
	[ ROW <row> ] ;
	[ COL <col> ] ;
	[ WIDTH <wi>] ;
	[ HEIGHT <h>] ;
	[ TITLE <title> ] ;
	MDICHILD ;
	[ <nocaption: NOCAPTION> ] ;
	[ CURSOR <cursor> ] ;
	[ FONT <FontName> SIZE <FontSize> ] ;
	[ <focused: FOCUSED> ] ;
	[ <nominimize: NOMINIMIZE> ] ;
	[ <nomaximize: NOMAXIMIZE> ] ;
	[ <novscroll: NOVSCROLL> ] 	;                             
	[ <nohscroll: NOHSCROLL> ] 	;                             
	[ ON INIT <InitProcedure> ] ;
	[ ON RELEASE <ReleaseProcedure> ] ;
	[ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
	[ ON MOUSECLICK <ClickProcedure> ] ;
	[ ON MOUSEMOVE <MouseMoveProcedure> ] ;
	[ ON GOTFOCUS <GotFocusProcedure> ] ;
	[ ON LOSTFOCUS <LostFocusProcedure> ] ;
	[ ON SIZE <SizeProcedure> ] ;
	[ ON MAXIMIZE <MaximizeProcedure> ] ;
	[ ON MINIMIZE <MinimizeProcedure> ] ;
   => ;
   DECLARE WINDOW <w>  ;;
   _DefineChildMdiWindow ( <"w">, <row>, <col>, <wi>, <h>, <.nominimize.>, <.nomaximize.>, <.nocaption.>, <.novscroll.>, <.nohscroll.>, <title>, <FontName>, <FontSize>, <{InitProcedure}>, <{ReleaseProcedure}>, <{ClickProcedure}>, <{GotFocusProcedure}>, <{LostFocusProcedure}>, <{SizeProcedure}>, <{MaximizeProcedure}>, <{MinimizeProcedure}>, <.focused.>, <cursor>, <{interactivecloseprocedure}>, <{MouseMoveProcedure}> )


#xcommand LOAD WINDOW <w> ;
   => ;
   _HMG_TempWindowName := <"w"> ;;
   DECLARE WINDOW <w> ;;
   DECLARE CUSTOM COMPONENTS <w> ;;
   #include \<<w>.fmg\>

#xcommand LOAD WINDOW <ww> AS <w> ;
   => ;
   _HMG_TempWindowName := <"w"> ;;
   DECLARE WINDOW <w> ;;
   DECLARE CUSTOM COMPONENTS <w> ;;
   #include \<<ww>.fmg\>

// PANEL Windows support

#xcommand LOAD WINDOW <n> AT <r> , <c> WIDTH <w> HEIGHT <h> ; 
   => ;
   DECLARE WINDOW <n> ;;
   _HMG_TempWindowName := <"n"> ;;
   _HMG_LoadWindowRow := <r> ;;
   _HMG_LoadWindowCol := <c> ;;
   _HMG_LoadWindowWidth := <w> ;;
   _HMG_LoadWindowHeight := <h> ;;
   #include \<<n>.fmg\> 


#command RELEASE WINDOW <name> ;
   =>;
   DoMethod ( <"name"> , 'Release' )

#command RELEASE WINDOW ALL ;
   =>;
   ReleaseAllWindows ()

#command RELEASE WINDOW MAIN ;
   =>;
   ReleaseAllWindows ()

#xtranslate EXIT PROGRAM ;
   =>;
   ReleaseAllWindows ()

#ifndef __CONSOLE__

#command QUIT ;
   =>;
   ReleaseAllWindows ()

#endif

#command ACTIVATE WINDOW <name, ...> [ <nowait: NOWAIT> ] ;
   =>;
   _ActivateWindow ( \{<(name)>\}, <.nowait.> )

#command ACTIVATE WINDOW ALL ;
   =>;
   _ActivateAllWindows ()

#command CENTER WINDOW <name> ;
   =>;
   DoMethod ( <"name"> , 'Center' )

#command SET CENTERWINDOW RELATIVE DESKTOP ;
   =>;
   _SetCenterWindowStyle ( .F. )

#command SET CENTERWINDOW RELATIVE PARENT ;
   =>;
   _SetCenterWindowStyle ( .T. )

#translate IsCenterWindowRelativeParent => _SetCenterWindowStyle ()

#command SET DEFAULT ICON TO <iconname> ;
   =>;
   _HMG_DefaultIconName := <iconname>

#command MAXIMIZE WINDOW <name> ;
   =>;
   DoMethod ( <"name"> , 'Maximize' )

#command MINIMIZE WINDOW <name> ;
   =>;
   DoMethod ( <"name"> , 'Minimize' )

#command RESTORE WINDOW <name> ;
   =>;
   DoMethod ( <"name"> , 'Restore' )

#command SHOW WINDOW <name> ;
   =>;
   DoMethod ( <"name"> , 'Show' )

#command HIDE WINDOW <name> ;
   =>;
   DoMethod ( <"name"> , 'Hide' )

#command END WINDOW ;
   =>;
   _EndWindow ()

#xcommand DO EVENTS => DoEvents()

#xcommand DO MESSAGE LOOP => DoMessageLoop()

#xcommand DO MESSAGELOOP => DoMessageLoop()

#xcommand FETCH [ PROPERTY ] [ WINDOW ] <Arg1> <Arg2> TO <Arg3> ;
   => ;
   <Arg3> := GetProperty ( <"Arg1"> , <"Arg2"> )

#xcommand MODIFY [ PROPERTY ] [ WINDOW ] <Arg1> <Arg2> <Arg3> ;
   => ;
   SetProperty ( <"Arg1"> , <"Arg2"> , <Arg3> )


#command DEFINE WINDOW TEMPLATE ;
         [ <dummy1: OF, PARENT> <parent> ] ;
         AT <row>,<col> ;
         WIDTH <wi> ;
         HEIGHT <h> ;
         [ MINWIDTH <minWidth> ] ;
         [ MINHEIGHT <minHeight> ] ;
         [ MAXWIDTH <maxWidth> ] ;
         [ MAXHEIGHT <maxHeight> ] ;
         [ VIRTUAL WIDTH <vWidth> ] ;
         [ VIRTUAL HEIGHT <vHeight> ] ;
         [ CLIENTAREA <clientwidth>,<clientheight> ] ;
         [ TITLE <title> ] ;
         [ ICON <icon> ] ;
         [ <main:  MAIN> ] ;
         [ <mdi: MDI> ] ;
         [ <child: CHILD> ] ;
         [ <panel: PANEL> ] ;
         [ <noshow: NOSHOW> ] ;
         [ <topmost: TOPMOST> ] ;
         [ <palette: PALETTE> ] ;
         [ <noautorelease: NOAUTORELEASE> ] ;
         [ <nominimize: NOMINIMIZE> ] ;
         [ <nomaximize: NOMAXIMIZE> ] ;
         [ <nosize: NOSIZE> ] ;
         [ <nosysmenu: NOSYSMENU> ] ;
         [ <nocaption: NOCAPTION> ] ;
         [ CURSOR <cursor> ] ;
         [ ON INIT <InitProcedure> ] ;
         [ ON RELEASE <ReleaseProcedure> ] ;
         [ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
         [ ON MOUSECLICK <ClickProcedure> ] ;
         [ ON MOUSEDRAG <MouseDragProcedure> ] ;
         [ ON MOUSEMOVE <MouseMoveProcedure> ] ;
         [ ON MOVE <MoveProcedure> ] ;
         [ ON SIZE <SizeProcedure> ] ;
         [ ON MAXIMIZE <MaximizeProcedure> ] ;
         [ ON MINIMIZE <MinimizeProcedure> ] ;
         [ ON RESTORE <RestoreProcedure> ] ;
         [ ON PAINT <PaintProcedure> ] ;
         [ ON DROPFILES <DropProcedure> ] ;
         [ BACKCOLOR <backcolor> ] ;
         [ FONT <FontName> SIZE <FontSize> ] ;
         [ NOTIFYICON <NotifyIcon> ] ;
         [ NOTIFYTOOLTIP <NotifyIconTooltip> ] ;
         [ ON NOTIFYCLICK <NotifyLeftClick> ] ;
         [ ON NOTIFYDBLCLICK <NotifyDblClick> ] ;
         [ ON NOTIFYBALLOONCLICK <NotifyBalloonClick> ] ;
         [ ON GOTFOCUS <GotFocusProcedure> ] ;
         [ ON LOSTFOCUS <LostFocusProcedure> ] ;
         [ ON SCROLLUP <scrollup> ] ;
         [ ON SCROLLDOWN <scrolldown> ] ;
         [ ON SCROLLLEFT <scrollleft> ] ;
         [ ON SCROLLRIGHT <scrollright> ] ;
         [ ON HSCROLLBOX <hScrollBox> ] ;
         [ ON VSCROLLBOX <vScrollBox> ] ;
         [ <helpbutton: HELPBUTTON> ] ;
   =>;
   _DefineWindow ( , <title>, <col>, <row>, <wi>, <h>, <.nominimize.>, <.nomaximize.>, <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>, <minHeight>}, {<maxWidth>, <maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}>, <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>] , <{PaintProcedure}> , <.noshow.> , <.topmost.> , <.main.> , <icon> , <.child.> , <FontName> , <FontSize>, <NotifyIcon> , <NotifyIconTooltip> , <{NotifyLeftClick}> , <{GotFocusProcedure}> , <{LostFocusProcedure}> , <vHeight> , <vWidth> , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <{MaximizeProcedure}> , <{MinimizeProcedure}> , <cursor> , <.noautorelease.> , <{interactivecloseprocedure}> , <{RestoreProcedure}> , <{MoveProcedure}> , <{DropProcedure}> , <.mdi.> , <.palette.> , <{NotifyDblClick}> , <"parent"> , <.panel.> , <{NotifyBalloonClick}> , <clientwidth> , <clientheight> )

#command DEFINE WINDOW TEMPLATE ;
         AT <row>,<col> ;
         WIDTH <wi> ;
         HEIGHT <h> ;
         [ MINWIDTH <minWidth> ] ;
         [ MINHEIGHT <minHeight> ] ;
         [ MAXWIDTH <maxWidth> ] ;
         [ MAXHEIGHT <maxHeight> ] ;
         [ VIRTUAL WIDTH <vWidth> ] ;
         [ VIRTUAL HEIGHT <vHeight> ] ;
         [ CLIENTAREA <clientwidth>,<clientheight> ] ;
         [ TITLE <title> ] ;
         [ ICON <icon> ] ;
         MODAL ;
         [ <noshow: NOSHOW> ] ;
         [ <noautorelease: NOAUTORELEASE> ] ;
         [ <nosize: NOSIZE> ] ;
         [ <nosysmenu: NOSYSMENU> ] ;
         [ <nocaption: NOCAPTION> ] ;
         [ CURSOR <cursor> ] ;
         [ ON INIT <InitProcedure> ] ;
         [ ON RELEASE <ReleaseProcedure> ] ;
         [ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
         [ ON MOUSECLICK <ClickProcedure> ] ;
         [ ON MOUSEDRAG <MouseDragProcedure> ] ;
         [ ON MOUSEMOVE <MouseMoveProcedure> ] ;
         [ ON MOVE <MoveProcedure> ] ;
         [ ON SIZE <SizeProcedure> ] ;
         [ ON PAINT <PaintProcedure> ] ;
         [ ON DROPFILES <DropProcedure> ] ;
         [ BACKCOLOR <backcolor> ] ;
         [ FONT <FontName> SIZE <FontSize> ] ;
         [ ON GOTFOCUS <GotFocusProcedure> ] ;
         [ ON LOSTFOCUS <LostFocusProcedure> ] ;
         [ ON SCROLLUP <scrollup> ] ;
         [ ON SCROLLDOWN <scrolldown> ] ;
         [ ON SCROLLLEFT <scrollleft> ] ;
         [ ON SCROLLRIGHT <scrollright> ] ;
         [ ON HSCROLLBOX <hScrollBox> ] ;
         [ ON VSCROLLBOX <vScrollBox> ] ;
         [ <helpbutton: HELPBUTTON> ] ;
   =>;
   _DefineModalWindow ( , <title>, <col>, <row>, <wi>, <h>, "" , <.nosize.>, <.nosysmenu.>, <.nocaption.>, {<minWidth>, <minHeight>}, {<maxWidth>, <maxHeight>}, <{InitProcedure}>, <{ReleaseProcedure}> , <{MouseDragProcedure}> , <{SizeProcedure}> , <{ClickProcedure}> , <{MouseMoveProcedure}>, [<backcolor>]  , <{PaintProcedure}> , <icon> , <FontName> , <FontSize> , <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <.helpbutton.> , <cursor> , <.noshow.> , <.noautorelease.> , <{interactivecloseprocedure}> , <{MoveProcedure}> , <{DropProcedure}> , <clientwidth> , <clientheight> )


#xcommand DEFINE WINDOW TEMPLATE ;
         WIDTH <wi> ;
         HEIGHT <h> ;
         [ VIRTUAL WIDTH <vWidth> ] ;
         [ VIRTUAL HEIGHT <vHeight> ] ;
         [ TITLE <title> ] ;
         SPLITCHILD ;
         [ <nocaption: NOCAPTION> ] ;
         [ CURSOR <cursor> ] ;
         [ FONT <FontName> SIZE <FontSize> ] ;
         [ GRIPPERTEXT <grippertext> ] ;
         [ <break: BREAK> ] ;
         [ <focused: FOCUSED> ] ;
         [ ON GOTFOCUS <GotFocusProcedure> ] ;
         [ ON LOSTFOCUS <LostFocusProcedure> ] ;
         [ ON SCROLLUP <scrollup> ] ;
         [ ON SCROLLDOWN <scrolldown> ] ;
         [ ON SCROLLLEFT <scrollleft> ] ;
         [ ON SCROLLRIGHT <scrollright> ] ;
         [ ON HSCROLLBOX <hScrollBox> ] ;
         [ ON VSCROLLBOX <vScrollBox> ] ;
   => ;
   _DefineSplitChildWindow ( , <wi>, <h> , <.break.> , <grippertext> , <.nocaption.> , <title> , <FontName> , <FontSize>, <{GotFocusProcedure}>, <{LostFocusProcedure}> , <vHeight>  , <vWidth> , <.focused.>  , <{scrollleft}> , <{scrollright}> , <{scrollup}> , <{scrolldown}> , <{hScrollBox}> , <{vScrollBox}> , <cursor> ) ;;


// MDI CHILD Windows support

#xcommand  DEFINE WINDOW TEMPLATE ;
	[ AT <row>,<col> ] ;
	[ ROW <row> ] ;
	[ COL <col> ] ;
	[ WIDTH <wi>] ;
	[ HEIGHT <h>] ;
	[ TITLE <title> ] ;
	MDICHILD ;
	[ <nocaption: NOCAPTION> ] ;
	[ CURSOR <cursor> ] ;
	[ FONT <FontName> SIZE <FontSize> ] ;
	[ <focused: FOCUSED> ] ;
	[ <nominimize: NOMINIMIZE> ] ;
	[ <nomaximize: NOMAXIMIZE> ] ;
	[ <novscroll: NOVSCROLL> ] 	;                             
	[ <nohscroll: NOHSCROLL> ] 	;                             
	[ ON INIT <InitProcedure> ] ;
	[ ON RELEASE <ReleaseProcedure> ] ;
	[ ON INTERACTIVECLOSE <interactivecloseprocedure> ] ;
	[ ON MOUSECLICK <ClickProcedure> ] ;
	[ ON MOUSEMOVE <MouseMoveProcedure> ] ;
	[ ON GOTFOCUS <GotFocusProcedure> ] ;
	[ ON LOSTFOCUS <LostFocusProcedure> ] ;
	[ ON SIZE <SizeProcedure> ] ;
	[ ON MAXIMIZE <MaximizeProcedure> ] ;
	[ ON MINIMIZE <MinimizeProcedure> ] ;
    => ;
    _DefineChildMdiWindow ( , <row>, <col>, <wi>, <h>, <.nominimize.>, <.nomaximize.>, <.nocaption.>, <.novscroll.>, <.nohscroll.>, <title>, <FontName>, <FontSize>, <{InitProcedure}>, <{ReleaseProcedure}>, <{ClickProcedure}>, <{GotFocusProcedure}>, <{LostFocusProcedure}>, <{SizeProcedure}>, <{MaximizeProcedure}>, <{MinimizeProcedure}>, <.focused.>, <cursor>, <{interactivecloseprocedure}>, <{MouseMoveProcedure}> )


#xcommand FETCH ACTIVE MDICHILD TO <Arg1> ;
    => ;
    <Arg1> := GetActiveMdiHandle()

#xcommand TILE MDICHILDS HORIZONTAL ;
    => ;
    _MdiWindowsTile(.f.)

#xcommand TILE MDICHILDS VERTICAL ;
    => ;
    _MdiWindowsTile(.t.)

#xcommand CASCADE MDICHILDS ;
    => ;
    _MdiWindowsCascade()

#xcommand ARRANGE MDICHILD ICONS ;
    => ;
    _MdiWindowsIcons()

#command RESTORE MDICHILDS ALL ;
    =>;
    _MdiChildRestoreAll()

#command CLOSE MDICHILDS ALL ;
    =>;
    _MdiChildCloseAll()

#command CLOSE ACTIVE MDICHILD ;
    =>;
    _CloseActiveMdi()

////////////////////////////////////////////////////////////
// Set AutoAdjust / AutoZooming
////////////////////////////////////////////////////////////

#xtranslate SET AUTOADJUST ON [<except: NOBUTTONS>] ;
=> ;
_HMG_AutoAdjust := .T. ; _HMG_AutoZooming := .F. ; _HMG_AutoAdjustException := <.except.>

#xtranslate SET AUTOADJUST OFF ;
=> ;
_HMG_AutoAdjust := .F. ; _HMG_AutoZooming := .F.

#xtranslate SET AUTOZOOMING ON ;
=> ;
_HMG_AutoAdjust := .T. ; _HMG_AutoZooming := .T.

#xtranslate SET AUTOZOOMING OFF ;
=> ;
_HMG_AutoAdjust := .F. ; _HMG_AutoZooming := .F.

#include "i_app.ch"
