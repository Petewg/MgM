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

#xcommand ITEMSOURCE <itemsource>;
   =>;
   _HMG_ActiveControlItemSource := <"itemsource">

#xcommand VALUESOURCE <valuesource>;
   =>;
   _HMG_ActiveControlValueSource := <"valuesource">

#xcommand ID <nId> ;
   =>;
   _HMG_ActiveControlId := <nId>

#xcommand WORKAREA <workarea>;
   =>;
   _HMG_ActiveControlWorkArea    := <"workarea">

#xcommand FIELD        <field>;
   =>;
   _HMG_ActiveControlField       := <"field">

#xcommand FIELDS   <fields>;
   =>;
   _HMG_ActiveControlFields      := <fields>

#xcommand ALLOWDELETE   <deletable>;
   =>;
   _HMG_ActiveControlDelete      := <deletable>

#xcommand NOVSCROLLBAR   <nvs>;
   =>;
   _HMG_ActiveControlNoVScroll   := <nvs>

#xcommand VSCROLLBAR   <vs>;
   =>;
   _HMG_ActiveControlNoVScroll   := .not. <vs>

#xcommand NOHSCROLLBAR   <nvs>;
   =>;
   _HMG_ActiveControlNoHScroll   := <nvs>

#xcommand HSCROLLBAR   <vs>;
   =>;
   _HMG_ActiveControlNoHScroll   := .not. <vs>

#xcommand INPLACEEDIT   <inplaceedit>;
   =>;
   _HMG_ActiveControlInPlaceEdit := <inplaceedit>

#xcommand DISPLAYITEMS	<displayitems>;
   =>;
   _HMG_ActiveControlBorder	 := <displayitems>

#xcommand INPUTITEMS	<inputitems>;
   =>;
   _HMG_ActiveControlHandCursor	 := <inputitems>

#xcommand DATE <datetype : .T., .F.>;
   =>;
   _HMG_ActiveControlDateType    := <datetype>

#xcommand DATATYPE DATE;
   =>;
   _HMG_ActiveControlDateType	 := .T.

#xcommand DATATYPE NUMERIC;
   =>;
   _HMG_ActiveControlNumeric	 := .T.

#xcommand DATATYPE CHARACTER;
   =>;
   _HMG_ActiveControlNumeric := .F. ; _HMG_ActiveControlDateType := .F.

#xcommand VALID      <valid>;
   =>;
   _HMG_ActiveControlValid       := <valid>

#xcommand VALIDMESSAGES <validmessages>;
   =>;
   _HMG_ActiveControlValidMessages   := <validmessages>

#xcommand READONLY      <readonly>;
   =>;
   _HMG_ActiveControlReadOnly    := <readonly>

#xcommand VIRTUAL      <virtual>;
   =>;
   _HMG_ActiveControlVirtual     := <virtual>

#xcommand LOCK      <lock>;
   =>;
   _HMG_ActiveControlLock        := <lock>

#xcommand ALLOWAPPEND   <appendable>;
   =>;
   _HMG_ActiveControlAppendable  := <appendable>

#xcommand FONTITALIC   <i>;
   =>;
   _HMG_ActiveControlFontItalic  := <i>

#xcommand FONTSTRIKEOUT   <s>;
   =>;
   _HMG_ActiveControlFontStrikeOut   := <s>

#xcommand FONTUNDERLINE   <u>;
   =>;
   _HMG_ActiveControlFontUnderline   := <u>

#xcommand AUTOSIZE      <a>;
   =>;
   _HMG_ActiveControlAutoSize    := <a>

#xcommand HEADERS <headers> ;
   =>;
   _HMG_ActiveControlHeaders     := <headers>

#xcommand HEADER <headers> ;
   =>;
   _HMG_ActiveControlHeaders     := <headers>

#xcommand WIDTHS <widths> ;
   =>;
   _HMG_ActiveControlWidths      := <widths>

#xcommand ONDBLCLICK <dblclick> ;
   =>;
   _HMG_ActiveControlOnDblClick  := <{dblclick}>

#xcommand ON DBLCLICK <dblclick> ;
   =>;
   _HMG_ActiveControlOnDblClick  := <{dblclick}>

#xcommand ONHEADCLICK <aHeadClick> ;
   =>;
   _HMG_ActiveControlOnHeadClick := <aHeadClick>

#xcommand ON HEADCLICK <aHeadClick> ;
   =>;
   _HMG_ActiveControlOnHeadClick := <aHeadClick>

#xcommand DYNAMICBACKCOLOR <aDynamicBackColor> ;
   =>;
   _HMG_ActiveControlDynamicBackColor := <aDynamicBackColor>

#xcommand DYNAMICFORECOLOR <aDynamicForeColor> ;
   =>;
   _HMG_ActiveControlDynamicForeColor := <aDynamicForeColor>

#xcommand  WHEN <aWhenFields> ;
   =>;
   _HMG_ActiveControlWhen        := <aWhenFields>

#xcommand NOLINES <nolines> ;
   =>;
   _HMG_ActiveControlNoLines     := <nolines>

#xcommand IMAGE <aImage> ;
   =>;
   _HMG_ActiveControlImage       := <aImage>

#xcommand JUSTIFY <aJustify> ;
   =>;
   _HMG_ActiveControlJustify     := <aJustify>

#xcommand MULTISELECT <multiselect> ;
   =>;
   _HMG_ActiveControlMultiSelect := <multiselect>

#xcommand ALLOWEDIT <edit> ;
   =>;
   _HMG_ActiveControlEdit        := <edit>

#xcommand PLAINTEXT <plaintext> ;
   =>;
   _HMG_ActiveControlPlainText   := <plaintext>

#xcommand IMAGELIST <ImageList> ;
   =>;
   _HMG_ActiveControlImageList   := <ImageList>

/*----------------------------------------------------------------------------
Frame
---------------------------------------------------------------------------*/

#xcommand DEFINE FRAME <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlCaption      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlTransparent   := .f.      ;;
   _HMG_ActiveControlOpaque      := .f.      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.

#xcommand OPAQUE <opaque> ;
   =>;
   _HMG_ActiveControlOpaque   := <opaque>

#xcommand END FRAME ;
   =>;
   _BeginFrame (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlCaption,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlOpaque,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlTransparent,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
List Box
---------------------------------------------------------------------------*/

#xcommand DEFINE LISTBOX <name>;
   =>;
   _HMG_ActiveControlDef        := .T.      ;;
   _HMG_ActiveControlName       := <"name"> ;;
   _HMG_ActiveControlOf         := Nil      ;;
   _HMG_ActiveControlId         := Nil      ;;
   _HMG_ActiveControlCol        := Nil      ;;
   _HMG_ActiveControlRow        := Nil      ;;
   _HMG_ActiveControlHeight     := Nil      ;;
   _HMG_ActiveControlItems      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont       := Nil      ;;
   _HMG_ActiveControlSize       := Nil      ;;
   _HMG_ActiveControlTooltip       := Nil   ;;
   _HMG_ActiveControlOnGotFocus    := Nil   ;;
   _HMG_ActiveControlOnChange      := Nil   ;;
   _HMG_ActiveControlOnLostFocus   := Nil   ;;
   _HMG_ActiveControlOnDblClick    := Nil   ;;
   _HMG_ActiveControlMultiSelect   := .f.   ;;
   _HMG_ActiveControlHelpId        := Nil   ;;
   _HMG_ActiveControlBreak         := .f.   ;;
   _HMG_ActiveControlInvisible     := .f.   ;;
   _HMG_ActiveControlNoTabStop     := .f.   ;;
   _HMG_ActiveControlSort          := .f.   ;;
   _HMG_ActiveControlIncrement     := .f.   ;;
   _HMG_ActiveControlWrap          := .f.   ;;
   _HMG_ActiveControlBorder        := .f.   ;;
   _HMG_ActiveControlFormat        := Nil   ;;
   _HMG_ActiveControlFontBold      := .f.   ;;
   _HMG_ActiveControlBackColor     := Nil   ;;
   _HMG_ActiveControlFontColor     := Nil   ;;
   _HMG_ActiveControlFontItalic    := .f.   ;;
   _HMG_ActiveControlFontStrikeOut := .f.   ;;
   _HMG_ActiveControlFontUnderLine := .f.

#xcommand SORT   <sort>   ;
   =>;
   _HMG_ActiveControlSort      := <sort>

#xcommand DRAGITEMS <dragitems> ;
   =>;
   _HMG_ActiveControlIncrement := <dragitems>

#xcommand MULTICOLUMN <mcol> ;
   =>;
   _HMG_ActiveControlWrap      := <mcol>

#xcommand MULTITAB <mtab> ;
   =>;
   _HMG_ActiveControlBorder    := <mtab>

#xcommand TABSWIDTH <w> ;
   =>;
   _HMG_ActiveControlFormat    := <w>

#xcommand END LISTBOX   ;
   =>;
   _HMG_ActiveControlDef   := .F.      ;;
   _DefineListBox(;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlItems,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlOnDblClick,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlBreak,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlSort,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlMultiSelect,;
      _HMG_ActiveControlIncrement,;
      _HMG_ActiveControlWrap,;
      _HMG_ActiveControlBorder,;
      _HMG_ActiveControlFormat,;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Check List Box
---------------------------------------------------------------------------*/

#xcommand DEFINE CHECKLISTBOX <name>;
   =>;
   _HMG_ActiveControlDef           := .T. ;;
   _HMG_ActiveControlName     := <"name"> ;;
   _HMG_ActiveControlOf            := Nil ;;
   _HMG_ActiveControlId            := Nil ;;
   _HMG_ActiveControlCol           := Nil ;;
   _HMG_ActiveControlRow           := Nil ;;
   _HMG_ActiveControlHeight        := Nil ;;
   _HMG_ActiveControlItems         := Nil ;;
   _HMG_ActiveControlValue         := Nil ;;
   _HMG_ActiveControlFont          := Nil ;;
   _HMG_ActiveControlSize          := Nil ;;
   _HMG_ActiveControlTooltip       := Nil ;;
   _HMG_ActiveControlOnGotFocus    := Nil ;;
   _HMG_ActiveControlOnChange      := Nil ;;
   _HMG_ActiveControlOnLostFocus   := Nil ;;
   _HMG_ActiveControlOnDblClick    := Nil ;;
   _HMG_ActiveControlMultiSelect   := .f. ;;
   _HMG_ActiveControlHelpId        := Nil ;;
   _HMG_ActiveControlBreak         := .f. ;;
   _HMG_ActiveControlInvisible     := .f. ;;
   _HMG_ActiveControlNoTabStop     := .f. ;;
   _HMG_ActiveControlSort          := .f. ;;
   _HMG_ActiveControlBorder        := .f. ;;
   _HMG_ActiveControlFormat        := Nil ;;
   _HMG_ActiveControlFontBold      := .f. ;;
   _HMG_ActiveControlBackColor     := Nil ;;
   _HMG_ActiveControlFontColor     := Nil ;;
   _HMG_ActiveControlFontItalic    := .f. ;;
   _HMG_ActiveControlFontStrikeOut := .f. ;;
   _HMG_ActiveControlFontUnderLine := .f.

#xcommand CHECKBOXITEM <check> ;
   =>;
   _HMG_ActiveControlBorder    := <check>

#xcommand ITEMHEIGHT <h> ;
   =>;
   _HMG_ActiveControlFormat    := <h>

#xcommand END CHECKLISTBOX ;
   =>;
   _HMG_ActiveControlDef   := .F.      ;;
   _DefineChkListBox (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlItems,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlOnDblClick,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlBreak,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlSort,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlMultiSelect,;
      _HMG_ActiveControlBorder,;
      _HMG_ActiveControlFormat,;
      _HMG_ActiveControlId )

///////////////////////////////////////////////////////////////////////////////
// ANIMATEBOX COMMANDS
///////////////////////////////////////////////////////////////////////////////

#xcommand DEFINE ANIMATEBOX <name>;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlAutoPlay      := .f.      ;;
   _HMG_ActiveControlCenter      := .f.      ;;
   _HMG_ActiveControlTransparent   := .f.      ;;
   _HMG_ActiveControlBorder        := .t.      ;;
   _HMG_ActiveControlFile      := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil

#xcommand AUTOPLAY <autoplay>;
   =>;
   _HMG_ActiveControlAutoPlay      := <autoplay>

#xcommand CENTER   <center>;
   =>;
   _HMG_ActiveControlCenter      := <center>

#xcommand FILE      <file>;
   =>;
   _HMG_ActiveControlFile      := <file>

#xcommand END ANIMATEBOX;
   =>;
   _DefineAnimateBox(;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlAutoPlay,;
      _HMG_ActiveControlCenter,;
      _HMG_ActiveControlTransparent,;
      _HMG_ActiveControlFile,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlBorder,;
      _HMG_ActiveControlId )

#xcommand DEFINE PLAYER <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlFile      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlNoAutoSizeWindow   := .f.      ;;
   _HMG_ActiveControlNoAutoSizeMovie   := .f.      ;;
   _HMG_ActiveControlNoErrorDlg   := .f.      ;;
   _HMG_ActiveControlNoMenu      := .f.      ;;
   _HMG_ActiveControlNoOpen      := .f.      ;;
   _HMG_ActiveControlNoPlayBar      := .f.      ;;
   _HMG_ActiveControlShowAll      := .f.      ;;
   _HMG_ActiveControlShowMode      := .f.      ;;
   _HMG_ActiveControlShowName      := .f.      ;;
   _HMG_ActiveControlShowPosition   := .f.      ;;
   _HMG_ActiveControlHelpId      := Nil

#xcommand NOAUTOSIZEWINDOW   <noautosizewindow>;
   =>;
   _HMG_ActiveControlNoAutoSizeWindow   := <noautosizewindow>

#xcommand NOAUTOSIZEMOVIE   <noautosizemovie>;
   =>;
   _HMG_ActiveControlNoAutoSizeMovie   := <noautosizemovie>

#xcommand NOERRORDLG   <noerrordlg>;
   =>;
   _HMG_ActiveControlNoErrorDlg   := <noerrordlg>

#xcommand NOMENU   <nomenu>;
   =>;
   _HMG_ActiveControlNoMenu   := <nomenu>

#xcommand NOOPEN   <noopen>;
   =>;
   _HMG_ActiveControlNoOpen   := <noopen>

#xcommand NOPLAYBAR   <noplaybar>;
   =>;
   _HMG_ActiveControlNoPlayBar   := <noplaybar>

#xcommand SHOWALL   <showall>;
   =>;
   _HMG_ActiveControlShowAll   := <showall>

#xcommand SHOWMODE   <showmode>;
   =>;
   _HMG_ActiveControlShowMode   := <showmode>

#xcommand SHOWNAME   <showname>;
   =>;
   _HMG_ActiveControlShowName   := <showname>

#xcommand SHOWPOSITION   <showposition>;
   =>;
   _HMG_ActiveControlShowPosition   := <showposition>

#xcommand END PLAYER;
   =>;
   _DefinePlayer (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlFile,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlNoAutoSizeWindow,;
      _HMG_ActiveControlNoAutoSizeMovie,;
      _HMG_ActiveControlNoErrorDlg,;
      _HMG_ActiveControlNoMenu,;
      _HMG_ActiveControlNoOpen,;
      _HMG_ActiveControlNoPlayBar,;
      _HMG_ActiveControlShowAll,;
      _HMG_ActiveControlShowMode,;
      _HMG_ActiveControlShowName,;
      _HMG_ActiveControlShowPosition,;
      _HMG_ActiveControlHelpId )

/*----------------------------------------------------------------------------
Progress Bar
---------------------------------------------------------------------------*/

#xcommand DEFINE PROGRESSBAR <name>;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlRangeLow      := Nil      ;;
   _HMG_ActiveControlRangeHigh      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlVertical      := .f.      ;;
   _HMG_ActiveControlSmooth      := .f.      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlForeColor      := Nil      ;;
   _HMG_ActiveControlShowMode      := .f.      ;;
   _HMG_ActiveControlFile      := Nil      ;;
   _HMG_ActiveControlValue      := Nil

#xcommand RANGEMIN   <lo>;
   =>;
   _HMG_ActiveControlRangeLow   := <lo>

#xcommand RANGEMAX   <hi>;
   =>;
   _HMG_ActiveControlRangeHigh  := <hi>

#xcommand VERTICAL   <vertical>;
   =>;
   _HMG_ActiveControlVertical   := <vertical>

#xcommand SMOOTH     <smooth>;
   =>;
   _HMG_ActiveControlSmooth     := <smooth>

#xcommand MARQUEE    <showmode>;
   =>;
   _HMG_ActiveControlShowMode   := <showmode>

#xcommand VELOCITY   <file>;
   =>;
   _HMG_ActiveControlFile       := <file>

#xcommand END PROGRESSBAR;
   =>;
   _DefineProgressBar (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlRangeLow,;
      _HMG_ActiveControlRangeHigh,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlVertical,;
      _HMG_ActiveControlSmooth,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlForeColor,;
      _HMG_ActiveControlShowMode,;
      _HMG_ActiveControlFile,;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Radio Group
---------------------------------------------------------------------------*/

#xcommand DEFINE RADIOGROUP <name>;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlOptions   := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip   := Nil      ;;
   _HMG_ActiveControlOnChange   := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlBackColor   := Nil      ;;
   _HMG_ActiveControlFontColor   := Nil      ;;
   _HMG_ActiveControlSpacing   := Nil      ;;
   _HMG_ActiveControlHelpId   := Nil      ;;
   _HMG_ActiveControlInvisible   := .F.       ;;
   _HMG_ActiveControlNoTabStop   := .F.      ;;
   _HMG_ActiveControlFontBold   := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlTransparent   := .f.      ;;
   _HMG_ActiveControlReadOnly  := Nil      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlHorizontal    := .f.      ;;
   _HMG_ActiveControlLeftJustify   := .f.

#xcommand OPTIONS   <aOptions>;
   =>;
   _HMG_ActiveControlOptions      := <aOptions>

#xcommand SPACING   <spacing>;
   =>;
   _HMG_ActiveControlSpacing      := <spacing>

#xcommand HORIZONTAL <horizontal> ;
   =>;
   _HMG_ActiveControlHorizontal   := <horizontal>

#xcommand LEFTJUSTIFY <leftjustify> ;
   =>;
   _HMG_ActiveControlLeftJustify  := <leftjustify>

#xcommand END RADIOGROUP;
   =>;
   _DefineRadioGroup (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlOptions,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlSpacing,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlTransparent,;
      _HMG_ActiveControlHorizontal,;
      _HMG_ActiveControlLeftJustify,;
      _HMG_ActiveControlReadOnly,;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Slider
---------------------------------------------------------------------------*/

#xcommand DEFINE SLIDER <name>;
   =>;
   _HMG_ActiveControlName      := <"name"> ;;
   _HMG_ActiveControlOf        := Nil      ;;
   _HMG_ActiveControlId        := Nil      ;;
   _HMG_ActiveControlCol       := Nil      ;;
   _HMG_ActiveControlRow       := Nil      ;;
   _HMG_ActiveControlWidth     := Nil      ;;
   _HMG_ActiveControlHeight    := Nil      ;;
   _HMG_ActiveControlRangeLow  := Nil      ;;
   _HMG_ActiveControlRangeHigh := Nil      ;;
   _HMG_ActiveControlValue     := Nil      ;;
   _HMG_ActiveControlTooltip   := Nil      ;;
   _HMG_ActiveControlAction    := Nil      ;;
   _HMG_ActiveControlOnChange  := Nil      ;;
   _HMG_ActiveControlVertical  := .f.      ;;
   _HMG_ActiveControlNoTicks   := .f.      ;;
   _HMG_ActiveControlBoth      := .f.      ;;
   _HMG_ActiveControlTop       := .f.      ;;
   _HMG_ActiveControlLeft      := .f.      ;;
   _HMG_ActiveControlBackColor := Nil      ;;
   _HMG_ActiveControlForeColor := Nil      ;;
   _HMG_ActiveControlFormat    := Nil      ;;
   _HMG_ActiveControlBorder    := .f.      ;;
   _HMG_ActiveControlInvisible := .F.      ;;
   _HMG_ActiveControlNoTabStop := .F.      ;;
   _HMG_ActiveControlHelpId    := Nil

#xcommand NOTICKS   <noticks>;
   =>;
   _HMG_ActiveControlNoTicks   := <noticks>

#xcommand TICKMARKS	<tickmarks>;
   =>;
   _HMG_ActiveControlNoTicks	:= .Not. <tickmarks>

#xcommand BOTH      <both>;
   =>;
   _HMG_ActiveControlBoth   := <both>

#xcommand TOP       <top>;
   =>;
   _HMG_ActiveControlTop   := <top>

#xcommand LEFT      <left>;
   =>;
   _HMG_ActiveControlLeft   := <left>

#xcommand ON SCROLL <vscroll>;
   =>;
   _HMG_ActiveControlAction := <{vscroll}>

#xcommand ONSCROLL  <vscroll>;
   =>;
   _HMG_ActiveControlAction := <{vscroll}>

#xcommand ENABLESELRANGE <selrange>;
   =>;
   _HMG_ActiveControlBorder  := <selrange>

#xcommand SELRANGEMIN   <lo>;
   =>;
   _HMG_ActiveControlFontColor := <lo>

#xcommand SELRANGEMAX   <hi>;
   =>;
   _HMG_ActiveControlFormat    := <hi>

#xcommand END SLIDER;
   =>;
   _DefineSlider (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlRangeLow,;
      _HMG_ActiveControlRangeHigh,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlAction,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlVertical,;
      _HMG_ActiveControlNoTicks,;
      _HMG_ActiveControlBoth,;
      _HMG_ActiveControlTop,;
      _HMG_ActiveControlLeft,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlId,;
      _HMG_ActiveControlBorder,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlFormat )

/*----------------------------------------------------------------------------
Text Box
---------------------------------------------------------------------------*/

#xcommand DEFINE TEXTBOX <name>;
   =>;
   _HMG_ActiveControlName     := <"name"> ;;
   _HMG_ActiveControlOf            := Nil ;;
   _HMG_ActiveControlId            := Nil ;;
   _HMG_ActiveControlCol           := Nil ;;
   _HMG_ActiveControlRow           := Nil ;;
   _HMG_ActiveControlWidth         := Nil ;;
   _HMG_ActiveControlHeight        := Nil ;;
   _HMG_ActiveControlValue         := Nil ;;
   _HMG_ActiveControlFont          := Nil ;;
   _HMG_ActiveControlField         := Nil ;;
   _HMG_ActiveControlSize          := Nil ;;
   _HMG_ActiveControlTooltip       := Nil ;;
   _HMG_ActiveControlMaxLength     := Nil ;;
   _HMG_ActiveControlUpperCase     := .f. ;;
   _HMG_ActiveControlLowerCase     := .f. ;;
   _HMG_ActiveControlOptions       := Nil ;;
   _HMG_ActiveControlNumeric       := .f. ;;
   _HMG_ActiveControlPassword      := .f. ;;
   _HMG_ActiveControlOnLostFocus   := Nil ;;
   _HMG_ActiveControlOnGotFocus    := Nil ;;
   _HMG_ActiveControlOnChange      := Nil ;;
   _HMG_ActiveControlOnEnter       := Nil ;;
   _HMG_ActiveControlRightAlign    := .f. ;;
   _HMG_ActiveControlReadonly      := .f. ;;
   _HMG_ActiveControlDateType      := .f. ;;
   _HMG_ActiveControlHelpId        := Nil ;;
   _HMG_ActiveControlInputMask     := Nil ;;
   _HMG_ActiveControlFormat        := Nil ;;
   _HMG_ActiveControlBackColor     := Nil ;;
   _HMG_ActiveControlFontColor     := Nil ;;
   _HMG_ActiveControlFontBold      := .f. ;;
   _HMG_ActiveControlNoTabStop     := .f. ;;
   _HMG_ActiveControlBorder        := .t. ;;
   _HMG_ActiveControlInvisible     := .f. ;;
   _HMG_ActiveControlFontItalic    := .f. ;;
   _HMG_ActiveControlFontStrikeOut := .f. ;;
   _HMG_ActiveControlFontUnderLine := .f.

#xcommand CUEBANNER <CueText>;
   =>;
   _HMG_ActiveControlOptions       := <CueText>

#xcommand PLACEHOLDER <CueText>;
   =>;
   _HMG_ActiveControlOptions       := <CueText>

#xcommand UPPERCASE <uppercase>;
   =>;
   _HMG_ActiveControlUpperCase     := <uppercase>

#xcommand LOWERCASE <lowercase>;
   =>;
   _HMG_ActiveControlLowerCase     := <lowercase>

#xcommand CASECONVERT UPPER;
   =>;
   _HMG_ActiveControlUpperCase     := .T.

#xcommand CASECONVERT LOWER;
   =>;
   _HMG_ActiveControlLowerCase     := .T.

#xcommand CASECONVERT NONE;
   =>;
   _HMG_ActiveControlLowerCase := .F. ; _HMG_ActiveControlUpperCase := .F.

#xcommand NUMERIC <numeric>;
   =>;
   _HMG_ActiveControlNumeric       := <numeric>

#xcommand PASSWORD <password>;
   =>;
   _HMG_ActiveControlPassword      := <password>

#xcommand INPUTMASK <inputmask>;
   =>;
   _HMG_ActiveControlInputMask     := <inputmask>

#xcommand FORMAT <format>;
   =>;
   _HMG_ActiveControlFormat        := <format>

#xcommand END TEXTBOX;
   =>;
   iif ( _HMG_ActiveControlInputMask == Nil .and. _HMG_ActiveControlDateType == .F. ,;
      _DefineTextBox (;
         _HMG_ActiveControlName,;
         _HMG_ActiveControlOf,;
         _HMG_ActiveControlCol,;
         _HMG_ActiveControlRow,;
         _HMG_ActiveControlWidth,;
         _HMG_ActiveControlHeight,;
         _HMG_ActiveControlValue,;
         _HMG_ActiveControlFont,;
         _HMG_ActiveControlSize,;
         _HMG_ActiveControlTooltip,;
         _HMG_ActiveControlMaxLength,;
         _HMG_ActiveControlUpperCase,;
         _HMG_ActiveControlLowerCase,;
         _HMG_ActiveControlNumeric,;
         _HMG_ActiveControlPassword,;
         _HMG_ActiveControlOnLostFocus,;
         _HMG_ActiveControlOnGotFocus,;
         _HMG_ActiveControlOnChange,;
         _HMG_ActiveControlOnEnter,;
         _HMG_ActiveControlRightAlign,;
         _HMG_ActiveControlHelpId , ;
         _HMG_ActiveControlReadonly,;
         _HMG_ActiveControlFontBold , ;
         _HMG_ActiveControlFontItalic , ;
         _HMG_ActiveControlFontUnderLine,;
         _HMG_ActiveControlFontStrikeOut,;
         _HMG_ActiveControlField,;
         _HMG_ActiveControlBackColor,;
         _HMG_ActiveControlFontColor,;
         _HMG_ActiveControlInvisible,;
         _HMG_ActiveControlNoTabStop,;
         .NOT. _HMG_ActiveControlBorder,;
         _HMG_ActiveControlOptions,;
         _HMG_ActiveControlId ),;
      iif ( _HMG_ActiveControlNumeric == .T., _DefineMaskedTextBox (;
         _HMG_ActiveControlName,;
         _HMG_ActiveControlOf,;
         _HMG_ActiveControlCol,;
         _HMG_ActiveControlRow,;
         _HMG_ActiveControlInputMask,;
         _HMG_ActiveControlWidth,;
         _HMG_ActiveControlValue,;
         _HMG_ActiveControlFont,;
         _HMG_ActiveControlSize,;
         _HMG_ActiveControlTooltip,;
         _HMG_ActiveControlOnLostFocus,;
         _HMG_ActiveControlOnGotFocus,;
         _HMG_ActiveControlOnChange,;
         _HMG_ActiveControlHeight,;
         _HMG_ActiveControlOnEnter,;
         _HMG_ActiveControlRightAlign,;
         _HMG_ActiveControlHelpId,;
         _HMG_ActiveControlFormat , ;
         _HMG_ActiveControlFontBold , ;
         _HMG_ActiveControlFontItalic , ;
         _HMG_ActiveControlFontUnderLine , ;
         _HMG_ActiveControlFontStrikeOut,;
         _HMG_ActiveControlField,;
         _HMG_ActiveControlBackColor,;
         _HMG_ActiveControlFontColor,;
         _HMG_ActiveControlReadonly,;
         _HMG_ActiveControlInvisible,;
         _HMG_ActiveControlNoTabStop,;
         .NOT. _HMG_ActiveControlBorder,;
         _HMG_ActiveControlOptions,;
         _HMG_ActiveControlId ) , _DefineCharMaskTextBox ( _HMG_ActiveControlName ,;
         _HMG_ActiveControlOf,;
         _HMG_ActiveControlCol,;
         _HMG_ActiveControlRow,;
         _HMG_ActiveControlInputMask ,;
         _HMG_ActiveControlWidth , ;
         _HMG_ActiveControlValue ,;
         _HMG_ActiveControlFont , ;
         _HMG_ActiveControlSize ,;
         _HMG_ActiveControlTooltip ,;
         _HMG_ActiveControlOnLostFocus , ;
         _HMG_ActiveControlOnGotFocus , ;
         _HMG_ActiveControlOnChange ,;
         _HMG_ActiveControlHeight , ;
         _HMG_ActiveControlOnEnter , ;
         _HMG_ActiveControlRightAlign  ,;
         _HMG_ActiveControlHelpId  , ;
         _HMG_ActiveControlFontBold ,;
         _HMG_ActiveControlFontItalic , ;
         _HMG_ActiveControlFontUnderLine ,;
         _HMG_ActiveControlFontStrikeOut , ;
         _HMG_ActiveControlField , ;
         _HMG_ActiveControlBackColor,;
         _HMG_ActiveControlFontColor,;
         _HMG_ActiveControlDateType,;
         _HMG_ActiveControlReadonly,;
         _HMG_ActiveControlInvisible,;
         _HMG_ActiveControlNoTabStop,;
         .NOT. _HMG_ActiveControlBorder,;
         _HMG_ActiveControlOptions,;
         _HMG_ActiveControlId ) ) )

/*----------------------------------------------------------------------------
Button Text Box
---------------------------------------------------------------------------*/

#xcommand DEFINE BTNTEXTBOX <name>;
   =>;
   _HMG_ActiveControlName   := <"name">   ;;
   _HMG_ActiveControlOf   := Nil      ;;
   _HMG_ActiveControlId   := Nil      ;;
   _HMG_ActiveControlCol   := Nil      ;;
   _HMG_ActiveControlRow   := Nil      ;;
   _HMG_ActiveControlWidth   := Nil      ;;
   _HMG_ActiveControlHeight   := Nil      ;;
   _HMG_ActiveControlValue    := Nil      ;;
   _HMG_ActiveControlAction   := Nil      ;;
   _HMG_ActiveControlOnHeadClick   := Nil      ;;
   _HMG_ActiveControlPicture  := Nil      ;;
   _HMG_ActiveControlButtonWidth := Nil   ;;
   _HMG_ActiveControlFont     := Nil      ;;
   _HMG_ActiveControlSize     := Nil      ;;
   _HMG_ActiveControlTooltip  := Nil      ;;
   _HMG_ActiveControlMaxLength   := Nil      ;;
   _HMG_ActiveControlUpperCase   := .f.      ;;
   _HMG_ActiveControlLowerCase   := .f.      ;;
   _HMG_ActiveControlNumeric   := .f.      ;;
   _HMG_ActiveControlPassword   := .f.      ;;
   _HMG_ActiveControlOnLostFocus := Nil   ;;
   _HMG_ActiveControlOnGotFocus := Nil      ;;
   _HMG_ActiveControlOnChange   := Nil      ;;
   _HMG_ActiveControlOnEnter   := Nil      ;;
   _HMG_ActiveControlRightAlign := .f.      ;;
   _HMG_ActiveControlReadonly   := .f.      ;;
   _HMG_ActiveControlHelpId    := Nil      ;;
   _HMG_ActiveControlOptions   := Nil      ;;
   _HMG_ActiveControlField     := Nil      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlFontBold     := .f.      ;;
   _HMG_ActiveControlNoTabStop    := .f.      ;;
   _HMG_ActiveControlInvisible    := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.   ;;
   _HMG_ActiveControlFontUnderLine   := .f.   ;;
   _HMG_ActiveControlFormat       := .t. ;;
   _HMG_ActiveControlDefault         := .f.

#xcommand BUTTONWIDTH <width> ;
        =>;
        _HMG_ActiveControlButtonWidth := <width>

#xcommand DISABLEEDIT <disableedit> ;
      =>;
      _HMG_ActiveControlReadonly := <disableedit>

#xcommand KEEPFOCUS <keepfocus> ;
        =>;
        _HMG_ActiveControlFormat := <keepfocus>

#xcommand END BTNTEXTBOX;
   =>;
      _DefineBtnTextBox (;
         _HMG_ActiveControlName,;
         _HMG_ActiveControlOf,;
         _HMG_ActiveControlCol,;
         _HMG_ActiveControlRow,;
         _HMG_ActiveControlWidth,;
         _HMG_ActiveControlHeight,;
         _HMG_ActiveControlValue,;
         _HMG_ActiveControlAction,;
         _HMG_ActiveControlOnHeadClick,;
         _HMG_ActiveControlPicture,;
         _HMG_ActiveControlButtonWidth,;
         _HMG_ActiveControlFont,;
         _HMG_ActiveControlSize,;
         _HMG_ActiveControlTooltip,;
         _HMG_ActiveControlMaxLength,;
         _HMG_ActiveControlUpperCase,;
         _HMG_ActiveControlLowerCase,;
         _HMG_ActiveControlNumeric,;
         _HMG_ActiveControlPassword,;
         _HMG_ActiveControlOnLostFocus,;
         _HMG_ActiveControlOnGotFocus,;
         _HMG_ActiveControlOnChange,;
         _HMG_ActiveControlOnEnter,;
         _HMG_ActiveControlRightAlign,;
         _HMG_ActiveControlHelpId,;
         _HMG_ActiveControlFontBold,;
         _HMG_ActiveControlFontItalic,;
         _HMG_ActiveControlFontUnderLine,;
         _HMG_ActiveControlFontStrikeOut,;
         _HMG_ActiveControlField,;
         _HMG_ActiveControlBackColor,;
         _HMG_ActiveControlFontColor,;
         _HMG_ActiveControlInvisible,;
         _HMG_ActiveControlNoTabStop,;
         _HMG_ActiveControlId,;
         _HMG_ActiveControlReadOnly,;
         _HMG_ActiveControlDefault,;
         _HMG_ActiveControlOptions,;
         _HMG_ActiveControlFormat )

/*----------------------------------------------------------------------------
Get Box
---------------------------------------------------------------------------*/

#xcommand DEFINE GETBOX <name>;
   =>;
   _HMG_ActiveControlName   := <"name">   ;;
   _HMG_ActiveControlOf            := Nil ;;
   _HMG_ActiveControlId            := Nil ;;
   _HMG_ActiveControlCol           := Nil ;;
   _HMG_ActiveControlRow           := Nil ;;
   _HMG_ActiveControlWidth         := Nil ;;
   _HMG_ActiveControlHeight        := Nil ;;
   _HMG_ActiveControlValue         := Nil ;;
   _HMG_ActiveControlFont          := Nil ;;
   _HMG_ActiveControlField         := Nil ;;
   _HMG_ActiveControlSize          := Nil ;;
   _HMG_ActiveControlTooltip       := Nil ;;
   _HMG_ActiveControlPassword      := .f. ;;
   _HMG_ActiveControlOnLostFocus   := Nil ;;
   _HMG_ActiveControlOnGotFocus    := Nil ;;
   _HMG_ActiveControlOnChange      := Nil ;;
   _HMG_ActiveControlRightAlign    := .f. ;;
   _HMG_ActiveControlReadonly      := .f. ;;
   _HMG_ActiveControlDateType      := .f. ;;
   _HMG_ActiveControlHelpId        := Nil ;;
   _HMG_ActiveControlInputMask     := Nil ;;
   _HMG_ActiveControlFormat        := Nil ;;
   _HMG_ActiveControlBackColor     := Nil ;;
   _HMG_ActiveControlFontColor     := Nil ;;
   _HMG_ActiveControlFontBold      := .f. ;;
   _HMG_ActiveControlNoTabStop     := .f. ;;
   _HMG_ActiveControlInvisible     := .f. ;;
   _HMG_ActiveControlFontItalic    := .f. ;;
   _HMG_ActiveControlFontStrikeOut := .f. ;;
   _HMG_ActiveControlFontUnderLine := .f. ;;
   _HMG_ActiveControlWrap          := .f. ;;
   _HMG_ActiveControlBorder        := .t. ;;
   _HMG_ActiveControlValid         := Nil ;;
   _HMG_ActiveControlPicture       := Nil ;;
   _HMG_ActiveControlMessage       := Nil ;;
   _HMG_ActiveControlValidMessages := Nil ;;
   _HMG_ActiveControlWhen          := Nil ;;
   _HMG_ActiveControlAction        := Nil ;;
   _HMG_ActiveControlOnHeadClick   := Nil ;; 
   _HMG_ActiveControlImage         := Nil ;;
   _HMG_ActiveControlButtonWidth   := Nil

#xcommand PICTURE <inputmask>;
   =>;
   _HMG_ActiveControlPicture       := <inputmask>

#xcommand VALIDMESSAGE <cvmessage>;
   =>;
   _HMG_ActiveControlValidMessages := <cvmessage>

#xcommand MESSAGE <cmessage>;
   =>;
   _HMG_ActiveControlMessage       := <cmessage>

#xcommand NOMINUS <wrap>;
   =>;
   _HMG_ActiveControlWrap          := <wrap>

#xcommand END GETBOX;
   =>;
      _DefineGetBox (;
         _HMG_ActiveControlName,;
         _HMG_ActiveControlOf,;
         _HMG_ActiveControlCol,;
         _HMG_ActiveControlRow,;
         _HMG_ActiveControlWidth,;
         _HMG_ActiveControlHeight,;
         _HMG_ActiveControlValue,;
         _HMG_ActiveControlFont,;
         _HMG_ActiveControlSize,;
         _HMG_ActiveControlTooltip,;
         _HMG_ActiveControlPassword,;
         _HMG_ActiveControlOnLostFocus,;
         _HMG_ActiveControlOnGotFocus,;
         _HMG_ActiveControlOnChange,;
         _HMG_ActiveControlRightAlign,;
         _HMG_ActiveControlHelpId,;
         _HMG_ActiveControlReadonly,;
         _HMG_ActiveControlFontBold,;
         _HMG_ActiveControlFontItalic,;
         _HMG_ActiveControlFontUnderLine,;
         _HMG_ActiveControlFontStrikeOut,;
         _HMG_ActiveControlField,;
         _HMG_ActiveControlBackColor,;
         _HMG_ActiveControlFontColor,;
         _HMG_ActiveControlInvisible,;
         _HMG_ActiveControlNoTabStop,;
         _HMG_ActiveControlId,;
         _HMG_ActiveControlValid,;
         _HMG_ActiveControlPicture,;
         _HMG_ActiveControlMessage,;
         _HMG_ActiveControlValidMessages,;
         _HMG_ActiveControlWhen,;
         _HMG_ActiveControlAction,;
         _HMG_ActiveControlOnHeadClick,;
         _HMG_ActiveControlImage,;
         _HMG_ActiveControlButtonWidth,;
         _HMG_ActiveControlWrap,;
         .NOT. _HMG_ActiveControlBorder )

/*----------------------------------------------------------------------------
Month Calendar
---------------------------------------------------------------------------*/

#xcommand DEFINE MONTHCALENDAR <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlNoToday      := .f.      ;;
   _HMG_ActiveControlNoTodayCircle   := .f.      ;;
   _HMG_ActiveControlWeekNumbers   := .f.      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnSelect    := Nil      ;;
   _HMG_ActiveControlOnGotFocus        := Nil      ;;
   _HMG_ActiveControlOnLostFocus       := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlNoTabStop      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlBackColor   := Nil      ;;
   _HMG_ActiveControlFontColor     := Nil      ;;
   _HMG_ActiveControlTitleBackColor     := Nil      ;;
   _HMG_ActiveControlTitleFontColor     := Nil      ;;
   _HMG_ActiveControlBackgroundColor    := Nil      ;;
   _HMG_ActiveControlTrailingFontColor  := Nil

#xcommand NOTODAY   <notoday>;
   =>;
   _HMG_ActiveControlNoToday      := <notoday>

#xcommand NOTODAYCIRCLE   <notodaycircle>;
   =>;
   _HMG_ActiveControlNoTodayCircle   := <notodaycircle>

#xcommand WEEKNUMBERS   <weeknumbers>;
   =>;
   _HMG_ActiveControlWeekNumbers   := <weeknumbers>

#xcommand TITLEBACKCOLOR   <color>;
   =>;
   _HMG_ActiveControlTitleBackColor      := <color>

#xcommand TITLEFONTCOLOR   <color>;
   =>;
   _HMG_ActiveControlTitleFontColor      := <color>

#xcommand BKGNDCOLOR   <color>;
   =>;
   _HMG_ActiveControlBackgroundColor      := <color>

#xcommand TRAILINGFONTCOLOR   <color>;
   =>;
   _HMG_ActiveControlTrailingFontColor      := <color>

#xcommand END MONTHCALENDAR;
   =>;
   _DefineMonthCal (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      0,;
      0,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlNoToday,;
      _HMG_ActiveControlNoTodayCircle,;
      _HMG_ActiveControlWeekNumbers,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlTitleBackColor,;
      _HMG_ActiveControlTitleFontColor,;
      _HMG_ActiveControlBackgroundColor,;
      _HMG_ActiveControlTrailingFontColor,;
      _HMG_ActiveControlOnSelect,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Button
---------------------------------------------------------------------------*/

#xcommand DEFINE BUTTON <name> ;
        =>;
        _HMG_ActiveControlName              := <"name"> ;;
        _HMG_ActiveControlOf                := Nil      ;;
        _HMG_ActiveControlId                := Nil      ;;
        _HMG_ActiveControlCol               := Nil      ;;
        _HMG_ActiveControlRow               := Nil      ;;
        _HMG_ActiveControlCaption           := Nil      ;;
        _HMG_ActiveControlAction            := Nil      ;;
        _HMG_ActiveControlWidth             := Nil      ;;
        _HMG_ActiveControlHeight            := Nil      ;;
        _HMG_ActiveControlFont              := Nil      ;;
        _HMG_ActiveControlSize              := Nil      ;;
        _HMG_ActiveControlTooltip           := Nil      ;;
        _HMG_ActiveControlFlat              := .f.      ;;
        _HMG_ActiveControlOnGotFocus        := Nil      ;;
        _HMG_ActiveControlOnLostFocus       := Nil      ;;
        _HMG_ActiveControlNoTabStop         := .f.      ;;
        _HMG_ActiveControlHelpId            := Nil      ;;
        _HMG_ActiveControlInvisible         := .f.      ;;
        _HMG_ActiveControlRow               := Nil      ;;
        _HMG_ActiveControlCol               := Nil      ;;
        _HMG_ActiveControlPicture           := Nil      ;;
        _HMG_ActiveControlIcon              := Nil      ;;
        _HMG_ActiveControlImage             := Nil      ;;
        _HMG_ActiveControlTransparent       := .t.      ;;
        _HMG_ActiveControlNoXpStyle         := .f.      ;;
        _HMG_ActiveControlFontBold          := .f.      ;;
        _HMG_ActiveControlFontItalic        := .f.      ;;
        _HMG_ActiveControlFontStrikeOut     := .f.      ;;
        _HMG_ActiveControlFontUnderLine     := .f.      ;;
	_HMG_ActiveControlBorder            := .f.      ;;
        _HMG_ActiveControlBackColor         := Nil      ;;
        _HMG_ActiveControlFontColor         := Nil      ;;
	_HMG_ActiveControlFormat            := Nil      ;;
        _HMG_ActiveControlDefault           := .f.

#xcommand ROW <row> ;
        =>;
        _HMG_ActiveControlRow := <row>

#xcommand COL  <col> ;
        =>;
        _HMG_ActiveControlCol := <col>

#xcommand PARENT <of> ;
        =>;
        _HMG_ActiveControlOf := <"of">

#xcommand CAPTION  <caption> ;
        =>;
        _HMG_ActiveControlCaption := <caption>

#xcommand ACTION <action> ;
        =>;
        _HMG_ActiveControlAction := <{action}>

#xcommand ACTION2 <action> ;
        =>;
        _HMG_ActiveControlOnHeadClick := <{action}>

#xcommand ONCLICK <action> ;
        =>;
        _HMG_ActiveControlAction := <{action}>

#xcommand ON CLICK <action> ;
        =>;
        _HMG_ActiveControlAction := <{action}>

#xcommand WIDTH <width> ;
        =>;
        _HMG_ActiveControlWidth := <width>

#xcommand HEIGHT <height> ;
        =>;
        _HMG_ActiveControlHeight := <height>

#xcommand FONTNAME <font> ;
        =>;
        _HMG_ActiveControlFont := <font>

#xcommand FONTSIZE <size> ;
        =>;
        _HMG_ActiveControlSize := <size>

#xcommand ITEMCOUNT <itemcount> ;
        =>;
        _HMG_ActiveControlItemCount := <itemcount>

#xcommand TOOLTIP <tooltip> ;
        =>;
        _HMG_ActiveControlTooltip := <tooltip>

#xcommand FLAT <flat> ;
        =>;
        _HMG_ActiveControlFlat := <flat>

#xcommand ONGOTFOCUS <ongotfocus> ;
        =>;
        _HMG_ActiveControlOnGotFocus := <{ongotfocus}>

#xcommand ON GOTFOCUS <ongotfocus> ;
        =>;
        _HMG_ActiveControlOnGotFocus := <{ongotfocus}>

#xcommand ONLOSTFOCUS <onlostfocus> ;
        =>;
        _HMG_ActiveControlOnLostFocus := <{onlostfocus}>

#xcommand ON LOSTFOCUS <onlostfocus> ;
        =>;
        _HMG_ActiveControlOnLostFocus := <{onlostfocus}>

#xcommand TABSTOP <notabstop> ;
        =>;
        _HMG_ActiveControlNoTabStop := .NOT. <notabstop>

#xcommand NOTABSTOP <notabstop> ;
        =>;
        _HMG_ActiveControlNoTabStop := <notabstop>

#xcommand VISIBLE <invisible> ;
        =>;
        _HMG_ActiveControlInvisible := .NOT. <invisible>

#xcommand INVISIBLE <invisible> ;
        =>;
        _HMG_ActiveControlInvisible := <invisible>

#xcommand HELPID <helpid> ;
        =>;
        _HMG_ActiveControlHelpId  := <helpid>

#xcommand PICTURE <picture> ;
        =>;
        _HMG_ActiveControlPicture := <picture>

#xcommand ICON <icon> ;
        =>;
        _HMG_ActiveControlIcon    := <icon>

#xcommand EXTRACT <iconidx> ;
        =>;
        _HMG_ActiveControlImage   := <iconidx>

#xcommand TRANSPARENT <transparent> ;
        =>;
        _HMG_ActiveControlTransparent := <transparent>

#xcommand MULTILINE <multiline> ;
	=>;
	_HMG_ActiveControlBorder  := <multiline>

#xcommand HOTKEY <key> ;
	=>;
	_HMG_ActiveControlFormat  := <"key">

#xcommand DEFAULT <default> ;
        =>;
        _HMG_ActiveControlDefault := <default>

#xcommand END BUTTON ;
        =>;
        iif ( _HMG_ActiveControlPicture == Nil .and. _HMG_ActiveControlIcon == Nil,;
            _DefineButton (;
          _HMG_ActiveControlName,;
          _HMG_ActiveControlOf ,;
          _HMG_ActiveControlCol ,;
          _HMG_ActiveControlRow ,;
          _HMG_ActiveControlCaption ,;
          _HMG_ActiveControlAction ,;
          _HMG_ActiveControlWidth ,;
          _HMG_ActiveControlHeight ,;
          _HMG_ActiveControlFont ,;
          _HMG_ActiveControlSize ,;
          _HMG_ActiveControlTooltip ,;
          _HMG_ActiveControlOnGotFocus  ,;
          _HMG_ActiveControlOnLostFocus ,;
          _HMG_ActiveControlFlat ,;
          _HMG_ActiveControlNoTabStop  ,;
          _HMG_ActiveControlHelpId ,;
          _HMG_ActiveControlInvisible , ;
          _HMG_ActiveControlFontBold , ;
          _HMG_ActiveControlFontItalic , ;
          _HMG_ActiveControlFontUnderLine ,;
          _HMG_ActiveControlFontStrikeOut ,;
          _HMG_ActiveControlBorder ,;
          _HMG_ActiveControlDefault ,;
          _HMG_ActiveControlFormat ,;
          _HMG_ActiveControlId ) ,;
       _DefineImageButton (;
          _HMG_ActiveControlName,;
          _HMG_ActiveControlOf,;
          _HMG_ActiveControlCol,;
          _HMG_ActiveControlRow,;
          "",;
          _HMG_ActiveControlAction ,;
          _HMG_ActiveControlWidth ,;
          _HMG_ActiveControlHeight ,;
          _HMG_ActiveControlPicture ,;
          _HMG_ActiveControlTooltip ,;
          _HMG_ActiveControlOnGotfocus ,;
          _HMG_ActiveControlOnLostfocus ,;
          _HMG_ActiveControlFlat ,;
           .not. _HMG_ActiveControlTransparent ,;
          _HMG_ActiveControlHelpId ,;
          _HMG_ActiveControlInvisible ,;
          _HMG_ActiveControlNoTabStop ,;
          _HMG_ActiveControlDefault ,;
          _HMG_ActiveControlIcon ,;
          (_HMG_ActiveControlImage != NIL) ,;
          _HMG_ActiveControlImage ,;
          _HMG_ActiveControlNoXPStyle ,;
          _HMG_ActiveControlFormat ,;
          _HMG_ActiveControlId ) )

/*----------------------------------------------------------------------------
ButtonEx
---------------------------------------------------------------------------*/

#xcommand DEFINE BUTTONEX <name> ;
        =>;
        _HMG_ActiveControlName              := <"name"> ;;
        _HMG_ActiveControlOf                := Nil      ;;
        _HMG_ActiveControlCol               := Nil      ;;
        _HMG_ActiveControlRow               := Nil      ;;
        _HMG_ActiveControlCaption           := Nil      ;;
        _HMG_ActiveControlAction            := Nil      ;;
        _HMG_ActiveControlWidth             := Nil      ;;
        _HMG_ActiveControlHeight            := Nil      ;;
        _HMG_ActiveControlFont              := Nil      ;;
        _HMG_ActiveControlSize              := Nil      ;;
        _HMG_ActiveControlTooltip           := Nil      ;;
        _HMG_ActiveControlFlat              := .f.      ;;
        _HMG_ActiveControlOnGotFocus        := Nil      ;;
        _HMG_ActiveControlOnLostFocus       := Nil      ;;
        _HMG_ActiveControlNoTabStop         := .f.      ;;
        _HMG_ActiveControlHelpId            := Nil      ;;
        _HMG_ActiveControlInvisible         := .f.      ;;
        _HMG_ActiveControlRow               := Nil      ;;
        _HMG_ActiveControlCol               := Nil      ;;
        _HMG_ActiveControlPicture           := Nil      ;;
        _HMG_ActiveControlIcon              := Nil      ;;
        _HMG_ActiveControlTransparent       := .t.      ;;
        _HMG_ActiveControlNoXpStyle         := .f.      ;;
        _HMG_ActiveControlFontBold          := .f.      ;;
        _HMG_ActiveControlFontItalic        := .f.      ;;
        _HMG_ActiveControlFontStrikeOut     := .f.      ;;
        _HMG_ActiveControlFontUnderLine     := .f.      ;;
        _HMG_ActiveControlDefault           := .f.      ;;
        _HMG_ActiveControlBackColor         := NIL      ;;
        _HMG_ActiveControlFontColor         := NIL      ;;
        _HMG_ActiveControlVertical          := .f.      ;;
        _HMG_ActiveControlLefttext          := .f.      ;;
        _HMG_ActiveControlUptext            := .f.      ;;
        _HMG_ActiveControlNoHotLight        := .f.      ;;
        _HMG_ActiveControlJustify           := .f.      ;;
        _HMG_ActiveControlHandCursor        := .f.      ;;
        _HMG_ActiveControlShowNone          := -1       ;;
        _HMG_ActiveControlStringFormat      := -1

#xcommand NOXPSTYLE <noxpstyle> ;
        =>;
        _HMG_ActiveControlNoXPStyle :=  <noxpstyle>

#xcommand LEFTTEXT <lefttext> ;
        =>;
        _HMG_ActiveControlLeftText :=  <lefttext>

#xcommand UPPERTEXT <uptext> ;
        =>;
        _HMG_ActiveControlUpText :=  <uptext>

#xcommand NOHOTLIGHT <nohotlight> ;
        =>;
        _HMG_ActiveControlNoHotlight :=  <nohotlight>

#xcommand NOTRANSPARENT <transparent> ;
        =>;
        _HMG_ActiveControlTransparent := .not. <transparent>

#xcommand ADJUST <adjust : .T., .F.> ;
        =>;
        _HMG_ActiveControlJustify := <adjust>

#xcommand IMAGEWIDTH  <imagewidth>  ;
   => ;
   _HMG_ActiveControlShowNone     := <imagewidth>

#xcommand IMAGEHEIGHT <imageheight> ;
   => ;
   _HMG_ActiveControlStringFormat := <imageheight>

#xcommand END BUTTONEX ;
        =>;
          _DefineOwnerButton ( ;
          _HMG_ActiveControlName, ;
          _HMG_ActiveControlOf, ;
          _HMG_ActiveControlCol, ;
          _HMG_ActiveControlRow, ;
          _HMG_ActiveControlCaption, ;
          _HMG_ActiveControlAction, ;
          _HMG_ActiveControlWidth, ;
          _HMG_ActiveControlHeight, ;
          _HMG_ActiveControlPicture, ;
          _HMG_ActiveControlTooltip, ;
          _HMG_ActiveControlOnGotfocus, ;
          _HMG_ActiveControlOnLostfocus, ;
           _HMG_ActiveControlFlat, ;
          .not. _HMG_ActiveControlTransparent, ;
          _HMG_ActiveControlHelpId, ;
          _HMG_ActiveControlInvisible, ;
          _HMG_ActiveControlNoTabStop,;
          _HMG_ActiveControlDefault, ;
          _HMG_ActiveControlIcon,;
          _HMG_ActiveControlFont, ;
          _HMG_ActiveControlSize,;
          _HMG_ActiveControlFontBold ,;
          _HMG_ActiveControlFontItalic,;
          _HMG_ActiveControlFontUnderLine,;
          _HMG_ActiveControlFontStrikeOut,;
          _HMG_ActiveControlVertical,;
          _HMG_ActiveControlLeftText,;
          _HMG_ActiveControlUpText,;
          _HMG_ActiveControlBackColor,;
          _HMG_ActiveControlFontColor,;
          _HMG_ActiveControlNoHotlight,;
          _HMG_ActiveControlNoXPStyle,;
          _HMG_ActiveControlJustify,;
          _HMG_ActiveControlHandCursor,;
          _HMG_ActiveControlShowNone, _HMG_ActiveControlStringFormat )

/*----------------------------------------------------------------------------
Image
---------------------------------------------------------------------------*/

#xcommand DEFINE IMAGE <name> ;
   =>;
   _HMG_ActiveControlName        := <"name"> ;;
   _HMG_ActiveControlOf          := Nil      ;;
   _HMG_ActiveControlId          := Nil      ;;
   _HMG_ActiveControlCol         := Nil      ;;
   _HMG_ActiveControlRow         := Nil      ;;
   _HMG_ActiveControlPicture     := Nil      ;;
   _HMG_ActiveControlWidth       := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlAction      := Nil      ;;
   _HMG_ActiveControlTooltip     := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlStretch     := .F.      ;;
   _HMG_ActiveControlWhiteBack   := Nil      ;;
   _HMG_ActiveControlTransparent := .F.      ;;
   _HMG_ActiveControlJustify     := .F.      ;;
   _HMG_ActiveControlOnGotFocus  := Nil      ;;
   _HMG_ActiveControlOnLostFocus := Nil      ;;
   _HMG_ActiveControlInvisible   := .F.

#xcommand END IMAGE ;
   =>;
   _DefineImage (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlPicture,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlAction,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlStretch,;
      _HMG_ActiveControlWhiteBack,;
      _HMG_ActiveControlTransparent,;
      _HMG_ActiveControlJustify,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlId )

#xcommand STRETCH         <stretch>;
   =>;
   _HMG_ActiveControlStretch   := <stretch>

#xcommand BACKGROUNDCOLOR <bkgcolor>;
   =>;
   _HMG_ActiveControlWhiteBack := <bkgcolor>

#xcommand WHITEBACKGROUND      <whitebg>;
   =>;
   _HMG_ActiveControlWhiteBack := iif( <whitebg>, { 255 , 255 , 255 }, Nil )

#xcommand ADJUSTIMAGE     <adjust>;
   =>;
   _HMG_ActiveControlJustify   := <adjust>

/*----------------------------------------------------------------------------
Check Box/Button
---------------------------------------------------------------------------*/

#xcommand DEFINE CHECKBOX <name> ;
   =>;
   _HMG_ActiveControlName       := <"name">    ;;
   _HMG_ActiveControlOf         := Nil         ;;
   _HMG_ActiveControlId         := Nil         ;;
   _HMG_ActiveControlCol        := Nil         ;;
   _HMG_ActiveControlRow        := Nil         ;;
   _HMG_ActiveControlCaption    := Nil         ;;
   _HMG_ActiveControlWidth      := Nil         ;;
   _HMG_ActiveControlHeight     := Nil         ;;
   _HMG_ActiveControlValue      := Nil         ;;
   _HMG_ActiveControlFont       := Nil         ;;
   _HMG_ActiveControlSize       := Nil         ;;
   _HMG_ActiveControlTooltip    := Nil         ;;
   _HMG_ActiveControlOnGotFocus := Nil         ;;
   _HMG_ActiveControlOnChange   := Nil         ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlOnEnter    := Nil         ;;
   _HMG_ActiveControlHelpId     := Nil         ;;
   _HMG_ActiveControlInvisible  := .f.         ;;
   _HMG_ActiveControlNoTabStop  := .f.         ;;
   _HMG_ActiveControlFontBold   := .f.         ;;
   _HMG_ActiveControlFontItalic    := .f.      ;;
   _HMG_ActiveControlFontStrikeOut := .f.      ;;
   _HMG_ActiveControlFontUnderLine := .f.      ;;
   _HMG_ActiveControlBackColor     := Nil      ;;
   _HMG_ActiveControlFontColor     := Nil      ;;
   _HMG_ActiveControlAutoSize      := .f.      ;;
   _HMG_ActiveControlTransparent   := .f.      ;;
   _HMG_ActiveControlField         := Nil      ;;
   _HMG_ActiveControlLeftJustify   := .f.      ;;
   _HMG_ActiveControlThreeState    := .f.


#xcommand DEFINE CHECKBUTTON <name> ;
   =>;
   _HMG_ActiveControlName       := <"name">    ;;
   _HMG_ActiveControlOf         := Nil         ;;
   _HMG_ActiveControlId         := Nil         ;;
   _HMG_ActiveControlCaption      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlPicture           := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine     := .f.      ;;
   _HMG_ActiveControlNoTabStop         := .f.      ;;
   _HMG_ActiveControlField             := Nil      ;;
   _HMG_ActiveControlLeftJustify       := .f.

#xcommand VALUE <value> ;
   =>;
   _HMG_ActiveControlValue := <value>

#xcommand ONCHANGE <onchange> ;
   =>;
   _HMG_ActiveControlOnChange   := <{onchange}>

#xcommand ON CHANGE <onchange> ;
   =>;
   _HMG_ActiveControlOnChange   := <{onchange}>

#xcommand ONSELECT <onselect> ;
   =>;
   _HMG_ActiveControlOnSelect   := <{onselect}>

#xcommand ON SELECT <onselect> ;
   =>;
   _HMG_ActiveControlOnSelect   := <{onselect}>

#xcommand ON QUERYDATA <onquerydata> ;
   =>;
   _HMG_ActiveControlOnQueryData   := <{onquerydata}>

#xcommand ONQUERYDATA <onquerydata> ;
   =>;
   _HMG_ActiveControlOnQueryData  := <{onquerydata}>

#xcommand THREESTATE <threestate> ;
   =>;
   _HMG_ActiveControlthreeState   := <threestate>

#xcommand END CHECKBOX ;
   =>;
   _DefineCheckBox (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlCaption,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlFontBold ,;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlField ,_HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor , ;
      _HMG_ActiveControlTransparent, ;
      _HMG_ActiveControlLeftJustify,;
      _HMG_ActiveControlthreeState,;
      _HMG_ActiveControlOnEnter,;
      _HMG_ActiveControlAutoSize,;
      _HMG_ActiveControlId )

#xcommand END CHECKBUTTON ;
   =>;
   iif ( _HMG_ActiveControlPicture == NIL , _DefineCheckButton (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlCaption,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlId ), ;
                                _DefineImageCheckButton (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlPicture,;
      _HMG_ActiveControlValue,;
      "" ,;
      0 , ;
      _HMG_ActiveControlTooltip, ;
      _HMG_ActiveControlOnChange, ;
      _HMG_ActiveControlWidth, ;
      _HMG_ActiveControlHeight, ;
      _HMG_ActiveControlOnLostFocus, ;
      _HMG_ActiveControlOnGotFocus, ;
      _HMG_ActiveControlHelpId, ;
      _HMG_ActiveControlInvisible, ;
      _HMG_ActiveControlId ) )

/*----------------------------------------------------------------------------
Combo Box
---------------------------------------------------------------------------*/

#xcommand DEFINE COMBOBOX <name>;
   =>;
   _HMG_ActiveControlDef   := .T.      ;;
   _HMG_ActiveControlName       := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight   := Nil      ;;
   _HMG_ActiveControlItems      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip   := Nil      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlNoTabStop   := .f.      ;;
   _HMG_ActiveControlSort      := .f.      ;;
   _HMG_ActiveControlUpperCase   := .f.      ;;
   _HMG_ActiveControlLowerCase   := .f.      ;;
   _HMG_ActiveControlOptions       := Nil      ;;
   _HMG_ActiveControlOnChange   := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlOnEnter   := Nil      ;;
   _HMG_ActiveControlHelpId   := Nil      ;;
   _HMG_ActiveControlInvisible   := .f.      ;;
   _HMG_ActiveControlFontBold   := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlItemSource   := Nil      ;;
   _HMG_ActiveControlValueSource  := Nil      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlBreak      := .f.      ;;
   _HMG_ActiveControlGripperText   := ""      ;;
   _HMG_ActiveControlDisplayEdit   := .f.      ;;
   _HMG_ActiveControlDisplayChange := Nil      ;;
   _HMG_ActiveControlFontUnderLine   := .f. ;;
   _HMG_ActiveControlWrap      := .f.      ;;
   _HMG_ActiveControlPassword  := .f.      ;;
   _HMG_ActiveControlSpacing := Nil ;;
   _HMG_ActiveControlFormat  := Nil   ;;
   _HMG_ActiveControlOnListDisplay := Nil ;;
   _HMG_ActiveControlOnListClose := Nil

#xcommand LISTWIDTH <nListWidth> ;
   =>;
   _HMG_ActiveControlSpacing := <nListWidth>

#xcommand DROPPEDWIDTH <nListWidth> ;
   =>;
   _HMG_ActiveControlSpacing := <nListWidth>

#xcommand DISPLAYEDIT <displayedit> ;
   =>;
   _HMG_ActiveControlDisplayEdit := <displayedit>

#xcommand GRIPPERTEXT <grippertext> ;
   =>;
   _HMG_ActiveControlGripperText := <grippertext>

#xcommand ON DISPLAYCHANGE <displaychange> ;
   =>;
   _HMG_ActiveControlDisplayChange := <{displaychange}>

#xcommand ONDISPLAYCHANGE <displaychange> ;
   =>;
   _HMG_ActiveControlDisplayChange := <{displaychange}>

#xcommand ITEM <aRows> ;
   =>;
   _HMG_ActiveControlItems   := <aRows>

#xcommand ITEMS <aRows> ;
   =>;
   _HMG_ActiveControlItems   := <aRows>

#xcommand ON ENTER <enter> ;
   =>;
   _HMG_ActiveControlOnEnter   := <{enter}>

#xcommand ONENTER <enter> ;
   =>;
   _HMG_ActiveControlOnEnter   := <{enter}>

#xcommand ON LISTDISPLAY <listdisplay> ;
   =>;
   _HMG_ActiveControlOnListDisplay := <{listdisplay}>

#xcommand ONLISTDISPLAY <listdisplay> ;
   =>;
   _HMG_ActiveControlOnListDisplay := <{listdisplay}>

#xcommand ON LISTCLOSE <listclose> ;
   =>;
   _HMG_ActiveControlOnListClose := <{listclose}>

#xcommand ONLISTCLOSE <listclose> ;
   =>;
   _HMG_ActiveControlOnListClose := <{listclose}>

#xcommand ON DROPDOWN <listdisplay> ;
   =>;
   _HMG_ActiveControlOnListDisplay := <{listdisplay}>

#xcommand ONDROPDOWN <listdisplay> ;
   =>;
   _HMG_ActiveControlOnListDisplay := <{listdisplay}>

#xcommand ON CLOSEUP <listclose> ;
   =>;
   _HMG_ActiveControlOnListClose := <{listclose}>

#xcommand ONCLOSEUP <listclose> ;
   =>;
   _HMG_ActiveControlOnListClose := <{listclose}>

#xcommand ONCANCEL  <OnCancel> ;
   =>;
   _HMG_ActiveControlFormat      := <{OnCancel}>

#xcommand AUTOCOMPLETE <ac> ;
   =>;
   _HMG_ActiveControlWrap        := <ac>

#xcommand SHOWDROPDOWN <show> ;
   =>;
   _HMG_ActiveControlPassword    := <show>

#xcommand END COMBOBOX ;
   =>;
   _HMG_ActiveControlDef   := .F.      ;;
   _DefineCombo (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlItems,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlOnEnter,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible ,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlSort,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlItemSource,;
      _HMG_ActiveControlValueSource , ;
      _HMG_ActiveControlDisplayEdit , ;
      _HMG_ActiveControlDisplayChange , ;
      _HMG_ActiveControlBreak , ;
      _HMG_ActiveControlGripperText, ;
      _HMG_ActiveControlSpacing,;
      _HMG_ActiveControlId, ;
      _HMG_ActiveControlOnListDisplay, ;
      _HMG_ActiveControlOnListClose, ;
      _HMG_ActiveControlBackColor, ;
      _HMG_ActiveControlFontColor, ;
      _HMG_ActiveControlUpperCase, ;
      _HMG_ActiveControlLowerCase, ;
      _HMG_ActiveControlOptions, ;
      _HMG_ActiveControlFormat, ;
      _HMG_ActiveControlWrap, ;
      _HMG_ActiveControlPassword )

/* ------------------------------------------------------------------------
Combo extend Style
---------------------------------------------------------------------------*/

#xcommand DEFINE COMBOBOXEX <name>;
   =>;
   _HMG_ActiveControlName       := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight   := Nil      ;;
   _HMG_ActiveControlItems      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip   := Nil      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlNoTabStop   := .f.      ;;
   _HMG_ActiveControlSort      := .f.      ;;
   _HMG_ActiveControlOnChange   := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlOnEnter   := Nil      ;;
   _HMG_ActiveControlHelpId   := Nil      ;;
   _HMG_ActiveControlInvisible   := .f.      ;;
   _HMG_ActiveControlFontBold   := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlItemSource   := Nil      ;;
   _HMG_ActiveControlValueSource  := Nil      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlBreak      := .f.      ;;
   _HMG_ActiveControlGripperText   := ""      ;;
   _HMG_ActiveControlDisplayEdit   := .f.      ;;
   _HMG_ActiveControlDisplayChange := Nil      ;;
   _HMG_ActiveControlImage         := Nil          ;;
   _HMG_ActiveControlImageList     := Nil          ;;
   _HMG_ActiveControlFontUnderLine   := .f. ;;
   _HMG_ActiveControlSpacing := NIL ;;
   _HMG_ActiveControlOnListDisplay := NIL ;;
   _HMG_ActiveControlOnListClose := NIL

#xcommand END COMBOBOXEX ;
   =>;
   _DefineComboEx (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlItems,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlOnEnter,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible ,;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlSort,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic,;
      _HMG_ActiveControlFontUnderLine,;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlItemSource,;
      _HMG_ActiveControlValueSource , ;
      _HMG_ActiveControlDisplayEdit , ;
      _HMG_ActiveControlDisplayChange , ;
      _HMG_ActiveControlBreak , ;
      _HMG_ActiveControlGripperText, ;
      _HMG_ActiveControlImage, ;
      _HMG_ActiveControlSpacing, ;
      _HMG_ActiveControlOnListDisplay, ;
      _HMG_ActiveControlOnListClose, ;
      _HMG_ActiveControlBackColor, ;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlImageList )

/*----------------------------------------------------------------------------
Timepicker
---------------------------------------------------------------------------*/

#xcommand DEFINE TIMEPICKER <name> ;
   => ;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId        := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlShowNone      := .f.      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlField             := Nil          ;;
   _HMG_ActiveControlNoTabStop         := .f.          ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlOnEnter      := Nil      ;;
   _HMG_ActiveControlFontUnderLine   := .f. ;;
   _HMG_ActiveControlStringFormat := NIL

#xcommand SHOWNONE  <shownone> ;
   => ;
   _HMG_ActiveControlShowNone      := <shownone>

#xcommand TIMEFORMAT  <cFormat> ;
   => ;
   _HMG_ActiveControlStringFormat := <cFormat>

#xcommand END TIMEPICKER ;
   => ;
      _DefineTimePick (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlShowNone,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible , ;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlFontBold , ;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlField , ;
      _HMG_ActiveControlOnEnter, ;
      _HMG_ActiveControlStringFormat, ;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Datepicker
---------------------------------------------------------------------------*/

#xcommand DEFINE DATEPICKER <name> ;
   => ;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId        := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlShowNone      := .f.      ;;
   _HMG_ActiveControlUpDown      := .f.      ;;
   _HMG_ActiveControlRightAlign   := .f.      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlNoTabStop         := .f.          ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.   ;;
   _HMG_ActiveControlField             := Nil          ;;
   _HMG_ActiveControlOnEnter      := Nil      ;;
   _HMG_ActiveControlBackColor   := Nil      ;;
   _HMG_ActiveControlFontColor     := Nil      ;;
   _HMG_ActiveControlTitleBackColor     := Nil      ;;
   _HMG_ActiveControlTitleFontColor     := Nil      ;;
   _HMG_ActiveControlTrailingFontColor  := Nil ;;
   _HMG_ActiveControlRangeLow      := Nil      ;;
   _HMG_ActiveControlRangeHigh     := Nil      ;;
   _HMG_ActiveControlStringFormat := NIL

#xcommand SHOWNONE  <shownone> ;
   => ;
   _HMG_ActiveControlShowNone    := <shownone>

#xcommand UPDOWN  <updown> ;
   => ;
   _HMG_ActiveControlUpDown      := <updown>

#xcommand DATEFORMAT  <cFormat> ;
   => ;
   _HMG_ActiveControlStringFormat := <cFormat>

#xcommand END DATEPICKER ;
   => ;
      _DefineDatePick (;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlShowNone,;
      _HMG_ActiveControlUpDown,;
      _HMG_ActiveControlRightAlign,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible , ;
      _HMG_ActiveControlNoTabStop,;
      _HMG_ActiveControlFontBold , ;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut,;
      _HMG_ActiveControlField, ;
      _HMG_ActiveControlOnEnter, ;
      _HMG_ActiveControlBackColor, ;
      _HMG_ActiveControlFontColor, ;
      _HMG_ActiveControlTitleBackColor, ;
      _HMG_ActiveControlTitleFontColor, ;
      _HMG_ActiveControlTrailingFontColor, ;
      _HMG_ActiveControlStringFormat, ;
      _HMG_ActiveControlRangeLow, ;
      _HMG_ActiveControlRangeHigh, ;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Edit Box
---------------------------------------------------------------------------*/

#xcommand DEFINE EDITBOX <name> ;
   =>;
   _HMG_ActiveControlDef   := .T.      ;;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlReadonly      := .f.      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlMaxLength      := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlBreak      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine     := .f.          ;;
   _HMG_ActiveControlNoTabStop         := .f.          ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlField             := Nil ;;
   _HMG_ActiveControlNoVScroll         := .f.          ;;
   _HMG_ActiveControlNoHScroll         := .f.

#xcommand READONLYFIELDS <readonly> ;
   =>;
   _HMG_ActiveControlReadOnly      := <readonly>

#xcommand MAXLENGTH <maxlength> ;
   =>;
   _HMG_ActiveControlMaxLength      := <maxlength>

#xcommand BREAK <break> ;
   =>;
   iif ( _HMG_ActiveControlDef , _HMG_ActiveControlBreak := <break> , EVAL({|b| BREAK(b)}, <break>) )

#xcommand END EDITBOX ;
   =>;
      _HMG_ActiveControlDef   := .F.      ;;
      _DefineEditBox(;
         _HMG_ActiveControlName,;
         _HMG_ActiveControlOf,;
         _HMG_ActiveControlCol,;
         _HMG_ActiveControlRow,;
         _HMG_ActiveControlWidth,;
         _HMG_ActiveControlHeight,;
         _HMG_ActiveControlValue,;
         _HMG_ActiveControlFont,;
         _HMG_ActiveControlSize,;
         _HMG_ActiveControlTooltip,;
         _HMG_ActiveControlMaxLength,;
         _HMG_ActiveControlOnGotFocus,;
         _HMG_ActiveControlOnChange,;
         _HMG_ActiveControlOnLostFocus,;
         _HMG_ActiveControlReadOnly,;
         _HMG_ActiveControlBreak,;
         _HMG_ActiveControlHelpId,;
         _HMG_ActiveControlInvisible , ;
         _HMG_ActiveControlNoTabStop ,;
         _HMG_ActiveControlFontBold , ;
         _HMG_ActiveControlFontItalic , ;
         _HMG_ActiveControlFontUnderLine , ;
         _HMG_ActiveControlFontStrikeOut ,;
         _HMG_ActiveControlField, ;
         _HMG_ActiveControlBackColor, ;
         _HMG_ActiveControlFontColor, ;
         _HMG_ActiveControlNoVScroll, ;
         _HMG_ActiveControlNoHScroll,;
         _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Rich Edit Box
---------------------------------------------------------------------------*/

#xcommand DEFINE RICHEDITBOX <name> ;
   =>;
   _HMG_ActiveControlDef   := .T.      ;;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlReadonly      := .f.      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip     := Nil      ;;
   _HMG_ActiveControlMaxLength   := Nil      ;;
   _HMG_ActiveControlOnGotFocus  := Nil      ;;
   _HMG_ActiveControlOnChange    := Nil      ;;
   _HMG_ActiveControlOnSelect    := Nil      ;;
   _HMG_ActiveControlOnLostFocus := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible   := .f.      ;;
   _HMG_ActiveControlBreak       := .f.      ;;
   _HMG_ActiveControlFontBold       := .f.      ;;
   _HMG_ActiveControlFontItalic     := .f.      ;;
   _HMG_ActiveControlFontStrikeOut  := .f.      ;;
   _HMG_ActiveControlFontUnderLine  := .f.          ;;
   _HMG_ActiveControlNoTabStop      := .f.          ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlFile      := Nil      ;;
   _HMG_ActiveControlField     := Nil  ;;
   _HMG_ActiveControlPlainText := .f.    ;;
   _HMG_ActiveControlNoVScroll := .f.    ;;
   _HMG_ActiveControlNoHScroll := .f.    ;;
   _HMG_ActiveControlAction := Nil

#xcommand ON VSCROLL  <vscroll>;
   =>;
   _HMG_ActiveControlAction := <{vscroll}>

#xcommand ONVSCROLL   <vscroll>;
   =>;
   _HMG_ActiveControlAction := <{vscroll}>

#xcommand END RICHEDITBOX ;
   =>;
      _HMG_ActiveControlDef   := .F.      ;;
      _DefineRichEditBox(;
         _HMG_ActiveControlName,;
         _HMG_ActiveControlOf,;
         _HMG_ActiveControlCol,;
         _HMG_ActiveControlRow,;
         _HMG_ActiveControlWidth,;
         _HMG_ActiveControlHeight,;
         _HMG_ActiveControlValue,;
         _HMG_ActiveControlFont,;
         _HMG_ActiveControlSize,;
         _HMG_ActiveControlTooltip,;
         _HMG_ActiveControlMaxLength,;
         _HMG_ActiveControlOnGotFocus,;
         _HMG_ActiveControlOnChange,;
         _HMG_ActiveControlOnLostFocus,;
         _HMG_ActiveControlReadOnly,;
         _HMG_ActiveControlBreak,;
         _HMG_ActiveControlHelpId,;
         _HMG_ActiveControlInvisible ,;
         _HMG_ActiveControlNoTabStop ,;
         _HMG_ActiveControlFontBold , ;
         _HMG_ActiveControlFontItalic ,;
         _HMG_ActiveControlFontUnderLine ,;
         _HMG_ActiveControlFontStrikeOut ,;
         _HMG_ActiveControlFile,;
         _HMG_ActiveControlField,;
         _HMG_ActiveControlBackColor,;
         _HMG_ActiveControlFontColor,;
         _HMG_ActiveControlPlainText,;
         _HMG_ActiveControlNoHScroll,;
         _HMG_ActiveControlNoVScroll,;
         _HMG_ActiveControlOnSelect ,;
         _HMG_ActiveControlAction )

/*----------------------------------------------------------------------------
Label
---------------------------------------------------------------------------*/

#xcommand DEFINE LABEL <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlBorder      := .f.      ;;
   _HMG_ActiveControlClientEdge   := .f.      ;;
   _HMG_ActiveControlHScroll      := .f.      ;;
   _HMG_ActiveControlVScroll      := .f.      ;;
   _HMG_ActiveControlTransparent   := .f.      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlAction      := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlTooltip         := Nil      ;;
   _HMG_ActiveControlRightAlign  := .F.   ;;
   _HMG_ActiveControlAutoSize    := .f.   ;;
   _HMG_ActiveControlIncrement   := .f.   ;;
   _HMG_ActiveControlOnGotFocus  := Nil   ;;
   _HMG_ActiveControlOnLostFocus := Nil   ;;
   _HMG_ActiveControlVertical    := .f.   ;;
   _HMG_ActiveControlCenterAlign := .F.

#xcommand BACKCOLOR   <color>;
   =>;
   _HMG_ActiveControlBackColor   := <color>

#xcommand CENTERALIGN   <centeralign>;
   => ;
   _HMG_ActiveControlCenterAlign := <centeralign>

#xcommand VCENTERALIGN  <vcenteralign>;
   => ;
   _HMG_ActiveControlVertical := <vcenteralign>

#xcommand RIGHTALIGN  <rightalign>;
   => ;
   _HMG_ActiveControlRightAlign   := <rightalign>

#xcommand ALIGNMENT RIGHT;
   => ;
   _HMG_ActiveControlRightAlign	:= .T. ; _HMG_ActiveControlCenterAlign := .F.

#xcommand ALIGNMENT CENTER;
   => ;
   _HMG_ActiveControlRightAlign	:= .F. ; _HMG_ActiveControlCenterAlign := .T.

#xcommand ALIGNMENT LEFT;
   => ;
   _HMG_ActiveControlRightAlign	:= .F. ; _HMG_ActiveControlCenterAlign := .F.

#xcommand ALIGNMENT VCENTER;
   => ;
   _HMG_ActiveControlVertical := .T.

#xcommand FONTCOLOR   <color>;
   =>;
   _HMG_ActiveControlFontColor   := <color>

#xcommand FORECOLOR   <color>;
   =>;
   _HMG_ActiveControlForeColor   := <color>

#xcommand FONTBOLD   <bold>;
   =>;
   _HMG_ActiveControlFontBold    := <bold>

#xcommand BORDER   <border>;
   =>;
   _HMG_ActiveControlBorder      := <border>

#xcommand CLIENTEDGE   <clientedge>;
   =>;
   _HMG_ActiveControlClientEdge  := <clientedge>

#xcommand HSCROLL   <hscroll>;
   =>;
   _HMG_ActiveControlHScroll     := <hscroll>

#xcommand VSCROLL   <vscroll>;
   =>;
   _HMG_ActiveControlVScroll     := <vscroll>

#xcommand BLINK     <blink>;
   =>;
   _HMG_ActiveControlIncrement   := <blink>

#xcommand ONMOUSEHOVER <ongotfocus> ;
   =>;
   _HMG_ActiveControlOnGotFocus := <{ongotfocus}>

#xcommand ON MOUSEHOVER <ongotfocus> ;
   =>;
   _HMG_ActiveControlOnGotFocus := <{ongotfocus}>

#xcommand ONMOUSELEAVE <onlostfocus> ;
   =>;
   _HMG_ActiveControlOnLostFocus := <{onlostfocus}>

#xcommand ON MOUSELEAVE <onlostfocus> ;
   =>;
   _HMG_ActiveControlOnLostFocus := <{onlostfocus}>

#xcommand END LABEL ;
   =>;
   _DefineLabel(;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlBorder,;
      _HMG_ActiveControlClientEdge,;
      _HMG_ActiveControlHScroll,;
      _HMG_ActiveControlVScroll,;
      _HMG_ActiveControlTransparent,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlAction,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible , ;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut , ;
      _HMG_ActiveControlAutoSize , ;
      _HMG_ActiveControlRightAlign , ;
      _HMG_ActiveControlCenterAlign, ;
      _HMG_ActiveControlIncrement, ;
      _HMG_ActiveControlOnGotFocus, ;
      _HMG_ActiveControlOnLostFocus, ;
      _HMG_ActiveControlVertical, ;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
Check Label
---------------------------------------------------------------------------*/

#xcommand DEFINE CHECKLABEL <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlBorder      := .f.      ;;
   _HMG_ActiveControlClientEdge   := .f.      ;;
   _HMG_ActiveControlHScroll      := .f.      ;;
   _HMG_ActiveControlVScroll      := .f.      ;;
   _HMG_ActiveControlTransparent   := .f.      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlAction      := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlTooltip           := Nil          ;;
   _HMG_ActiveControlRightAlign   := .F.      ;;
   _HMG_ActiveControlAutoSize      := .f. ;;
   _HMG_ActiveControlIncrement     := .f. ;;
   _HMG_ActiveControlLeftJustify   := .f. ;;
   _HMG_ActiveControlDefault       := .f.     ;;
   _HMG_ActiveControlImage       := Nil      ;;
   _HMG_ActiveControlOnGotFocus  := Nil      ;;
   _HMG_ActiveControlOnLostFocus := Nil      ;;
   _HMG_ActiveControlCenterAlign := .F.

#xcommand LEFTCHECK <leftjustify> ;
   =>;
        _HMG_ActiveControlLeftJustify  := <leftjustify>

#xcommand CHECKED <default> ;
   =>;
        _HMG_ActiveControlDefault := <default>

#xcommand END CHECKLABEL ;
   =>;
   _DefineChkLabel(;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlBorder,;
      _HMG_ActiveControlClientEdge,;
      _HMG_ActiveControlHScroll,;
      _HMG_ActiveControlVScroll,;
      _HMG_ActiveControlTransparent,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlAction,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible , ;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut , ;
      _HMG_ActiveControlAutoSize , ;
      _HMG_ActiveControlRightAlign , ;
      _HMG_ActiveControlCenterAlign, ;
      _HMG_ActiveControlIncrement, ;
      _HMG_ActiveControlOnGotFocus, ;
      _HMG_ActiveControlOnLostFocus, ;
      _HMG_ActiveControlImage, ;
      _HMG_ActiveControlLeftJustify, ;
      _HMG_ActiveControlDefault, ;
      _HMG_ActiveControlId )

/*----------------------------------------------------------------------------
IP address
---------------------------------------------------------------------------*/

#xcommand DEFINE IPADDRESS <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlFontBold        := .f.      ;;
   _HMG_ActiveControlFontItalic      := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlInvisible       := .f.      ;;
   _HMG_ActiveControlNoTabStop       := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.

#xcommand END IPADDRESS ;
=>;
   _DefineIPAddress( ;
      _HMG_ActiveControlName , ;
      _HMG_ActiveControlOf , ;
      _HMG_ActiveControlCol , ;
      _HMG_ActiveControlRow , ;
      _HMG_ActiveControlWidth , ;
      _HMG_ActiveControlHeight , ;
      _HMG_ActiveControlValue , ;
      _HMG_ActiveControlFont , ;
      _HMG_ActiveControlSize , ;
      _HMG_ActiveControlTooltip, ;
      _HMG_ActiveControlOnLostFocus , ;
      _HMG_ActiveControlOnGotFocus , ;
      _HMG_ActiveControlOnChange , ;
      _HMG_ActiveControlHelpId  , ;
      _HMG_ActiveControlInvisible , ;
      _HMG_ActiveControlNoTabStop ,;
      _HMG_ActiveControlFontBold , ;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut )

/*----------------------------------------------------------------------------
Grid
---------------------------------------------------------------------------*/

#xcommand DEFINE GRID <name> ;
   =>;
   _HMG_ActiveControlDef   := .T.      ;;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol               := Nil          ;;
   _HMG_ActiveControlRow               := Nil          ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlHeaders      := Nil      ;;
   _HMG_ActiveControlSpacing   := Nil      ;;
   _HMG_ActiveControlWidths      := Nil      ;;
   _HMG_ActiveControlItems      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlIncrement   := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlOnDblClick   := Nil      ;;
   _HMG_ActiveControlOnHeadClick   := Nil      ;;
   _HMG_ActiveControlNoLines      := .f.      ;;
   _HMG_ActiveControlImage      := Nil      ;;
   _HMG_ActiveControlJustify      := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlMultiSelect   := .f.      ;;
   _HMG_ActiveControlEdit              := .f.          ;;
   _HMG_ActiveControlBreak             := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlOnQueryData   := Nil      ;;
   _HMG_ActiveControlItemCount      := Nil      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlDynamicBackColor   := Nil   ;;
   _HMG_ActiveControlDynamicForeColor   := Nil   ;;
   _HMG_ActiveControlReadOnly      := Nil ;;
   _HMG_ActiveControlInPlaceEdit   := .f. ;;
   _HMG_ActiveControlValid         := Nil ;;
   _HMG_ActiveControlWhen          := Nil ;;
   _HMG_ActiveControlValidMessages := Nil ;;
   _HMG_ActiveControlImageList     := Nil ;;
   _HMG_ActiveControlVirtual       := .f. ;;
   _HMG_ActiveControlNoTabStop     := .f. ;;
   _HMG_ActiveControlRangeLow      := .f. ;;
   _HMG_ActiveControlRangeHigh     := Nil ;;
   _HMG_ActiveControlTransparent   := .f. ;;
   _HMG_ActiveControlOptions       := .f. ;;
   _HMG_ActiveControlSort          := Nil ;;
   _HMG_ActiveControlBorder        := .f.

#xcommand ALLOWSORT <sort> ;
   =>;
   _HMG_ActiveControlSort       := iif( <sort>, {}, Nil )

#xcommand COLUMNSORT <aSortColumns> ;
   =>;
   _HMG_ActiveControlSort       := <aSortColumns>

#xcommand SHOWHEADERS <showheaders> ;
   =>;
   _HMG_ActiveControlSpacing    := <showheaders>

#xcommand NOSORTHEADERS <nosort> ;
   =>;
   _HMG_ActiveControlOptions    := <nosort>

#xcommand COLUMNCONTROLS <editcontrols> ;
   =>;
   _HMG_ActiveControlInPlaceEdit := <editcontrols>

#xcommand COLUMNVALID <aValidColumns> ;
   =>;
   _HMG_ActiveControlValid      := <aValidColumns>

#xcommand COLUMNWHEN <aWhenColumns> ;
   =>;
   _HMG_ActiveControlWhen       := <aWhenColumns>

#xcommand HEADERIMAGE <ImageList> ;
   =>;
   _HMG_ActiveControlImageList  := <ImageList>

#xcommand HEADERIMAGES <ImageList> ;
   =>;
   _HMG_ActiveControlImageList  := <ImageList>

#xcommand CELLED <cell> ;
   =>;
   _HMG_ActiveControlBorder	:= <cell>

#xcommand CELLNAVIGATION <cellnavigation> ;
   =>;
   _HMG_ActiveControlBorder	:= <cellnavigation>

#xcommand CHECKBOXES <cb>;
   =>;
   _HMG_ActiveControlRangeLow   := <cb>

#xcommand ON CHECKBOXCLICKED   <onchange>;
   =>;
   _HMG_ActiveControlRangeHigh  := <{onchange}>

#xcommand ONCHECKBOXCLICKED   <onchange>;
   =>;
   _HMG_ActiveControlRangeHigh  := <{onchange}>

#xcommand LOCKCOLUMNS <value> ;
   =>;
   _HMG_ActiveControlIncrement  := <value>

#xcommand END GRID ;
   =>;
_HMG_ActiveControlDef   := .F.      ;;
_DefineGrid ( _HMG_ActiveControlName ,    ;
      _HMG_ActiveControlOf ,    ;
      _HMG_ActiveControlCol ,      ;
      _HMG_ActiveControlRow ,      ;
      _HMG_ActiveControlWidth ,       ;
      _HMG_ActiveControlHeight ,       ;
      _HMG_ActiveControlHeaders ,    ;
      _HMG_ActiveControlWidths ,    ;
      _HMG_ActiveControlItems ,    ;
      _HMG_ActiveControlValue ,   ;
      _HMG_ActiveControlFont ,    ;
      _HMG_ActiveControlSize ,    ;
      _HMG_ActiveControlTooltip ,    ;
      _HMG_ActiveControlOnChange ,   ;
      _HMG_ActiveControlOnDblClick ,  ;
      _HMG_ActiveControlOnHeadClick ,   ;
      _HMG_ActiveControlOnGotFocus ,   ;
      _HMG_ActiveControlOnLostFocus,  ;
      _HMG_ActiveControlNoLines,   ;
      _HMG_ActiveControlImage,   ;
      _HMG_ActiveControlJustify  ,    ;
      _HMG_ActiveControlBreak ,    ;
      _HMG_ActiveControlHelpId ,   ;
      _HMG_ActiveControlFontBold,    ;
      _HMG_ActiveControlFontItalic,    ;
      _HMG_ActiveControlFontUnderLine,    ;
      _HMG_ActiveControlFontStrikeOut , ;
      _HMG_ActiveControlVirtual , ;
      _HMG_ActiveControlOnQueryData ,  ;
      _HMG_ActiveControlItemCount ,    ;
      _HMG_ActiveControlEdit ,  ;
      _HMG_ActiveControlDynamicForeColor , ;
      _HMG_ActiveControlDynamicBackColor , ;
      _HMG_ActiveControlMultiSelect, ;
      _HMG_ActiveControlInPlaceEdit, ;
      _HMG_ActiveControlBackColor, ;
      _HMG_ActiveControlFontColor, ;
      _HMG_ActiveControlId, ;
      _HMG_ActiveControlValid, ;
      _HMG_ActiveControlWhen, ;
      _HMG_ActiveControlValidMessages, ;
      _HMG_ActiveControlSpacing, ;
      _HMG_ActiveControlImageList, ;
      _HMG_ActiveControlNoTabStop, ;
      _HMG_ActiveControlBorder, ;
      _HMG_ActiveControlRangeLow, ;
      _HMG_ActiveControlIncrement, ;
      _HMG_ActiveControlRangeHigh, ;
      _HMG_ActiveControlTransparent, ;
      _HMG_ActiveControlOptions, ;
      _HMG_ActiveControlSort )

/*----------------------------------------------------------------------------
BROWSE
---------------------------------------------------------------------------*/

#xcommand DEFINE BROWSE <name> ;
   =>;
   _HMG_ActiveControlDef   := .T.      ;;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlId      := Nil      ;;
   _HMG_ActiveControlCol               := Nil          ;;
   _HMG_ActiveControlRow               := Nil          ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlHeaders      := Nil      ;;
   _HMG_ActiveControlWidths      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlOnDblClick   := Nil      ;;
   _HMG_ActiveControlOnHeadClick   := Nil      ;;
   _HMG_ActiveControlNoLines      := .f.      ;;
   _HMG_ActiveControlImage      := Nil      ;;
   _HMG_ActiveControlJustify      := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlEdit     := .f.      ;;
   _HMG_ActiveControlBreak    := .f.      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlWorkArea      := Nil      ;;
   _HMG_ActiveControlFields      := Nil      ;;
   _HMG_ActiveControlDelete      := .f.      ;;
   _HMG_ActiveControlAppendable        := .f.      ;;
   _HMG_ActiveControlValid      := Nil      ;;
   _HMG_ActiveControlReadOnly      := Nil      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlLock      := .f.      ;;
   _HMG_ActiveControlValidMessages   := Nil      ;;
   _HMG_ActiveControlDynamicBackColor   := Nil   ;;
   _HMG_ActiveControlDynamicForeColor   := Nil   ;;
   _HMG_ActiveControlNoVScroll     := .f.      ;;
   _HMG_ActiveControlWhen          := Nil ;;
   _HMG_ActiveControlImageList     := Nil ;;
   _HMG_ActiveControlInPlaceEdit   := .f. ;;
   _HMG_ActiveControlHandCursor    := Nil ;;
   _HMG_ActiveControlBorder        := Nil ;;
   _HMG_ActiveControlTransparent   := .f. ;;
   _HMG_ActiveControlNoTabStop     := .f.

#xcommand PAINTDOUBLEBUFFER <buffer> ;
   =>;
   _HMG_ActiveControlTransparent := <buffer>

#xcommand END BROWSE ;
   =>;
_HMG_ActiveControlDef   := .F.      ;;
_DefineBrowse ( _HMG_ActiveControlName ,    ;
      _HMG_ActiveControlOf ,    ;
      _HMG_ActiveControlCol ,      ;
      _HMG_ActiveControlRow ,      ;
      _HMG_ActiveControlWidth ,       ;
      _HMG_ActiveControlHeight ,       ;
      _HMG_ActiveControlHeaders ,    ;
      _HMG_ActiveControlWidths ,    ;
      _HMG_ActiveControlFields ,    ;
      _HMG_ActiveControlValue ,   ;
      _HMG_ActiveControlFont ,    ;
      _HMG_ActiveControlSize ,    ;
      _HMG_ActiveControlTooltip ,    ;
      _HMG_ActiveControlOnChange ,   ;
      _HMG_ActiveControlOnDblClick  ,  ;
      _HMG_ActiveControlOnHeadClick ,;
      _HMG_ActiveControlOnGotFocus ,   ;
      _HMG_ActiveControlOnLostFocus,    ;
      _HMG_ActiveControlWorkArea ,   ;
      _HMG_ActiveControlDelete,     ;
      _HMG_ActiveControlNoLines ,   ;
      _HMG_ActiveControlImage ,   ;
      _HMG_ActiveControlJustify ,    ;
      _HMG_ActiveControlHelpId  , ;
      _HMG_ActiveControlFontBold , ;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut , ;
      _HMG_ActiveControlBreak  , ;
      _HMG_ActiveControlBackColor , ;
      _HMG_ActiveControlFontColor , ;
      _HMG_ActiveControlLock  , ;
      _HMG_ActiveControlInPlaceEdit , ;
      _HMG_ActiveControlNoVScroll , ;
      _HMG_ActiveControlAppendable , ;
      _HMG_ActiveControlReadOnly , ;
      _HMG_ActiveControlValid , ;
      _HMG_ActiveControlValidMessages , ;
      _HMG_ActiveControlEdit , ;
      _HMG_ActiveControlDynamicForeColor , ;
      _HMG_ActiveControlDynamicBackColor , ;
      _HMG_ActiveControlWhen , ;
      _HMG_ActiveControlId , ;
      _HMG_ActiveControlImageList , ;
      _HMG_ActiveControlNoTabStop , ;
      _HMG_ActiveControlHandCursor , ;
      _HMG_ActiveControlBorder , ;
      _HMG_ActiveControlTransparent )

/*----------------------------------------------------------------------------
Hyperlink
 - 2016/10/06 added FontUnderLine attribute - p.d. 
---------------------------------------------------------------------------*/

#xcommand DEFINE HYPERLINK <name> ;
   =>;
   _HMG_ActiveControlName              := <"name"> ;;
   _HMG_ActiveControlOf                := Nil      ;;
   _HMG_ActiveControlCol               := Nil      ;;
   _HMG_ActiveControlRow               := Nil      ;;
   _HMG_ActiveControlWidth             := Nil      ;;
   _HMG_ActiveControlHeight            := Nil      ;;
   _HMG_ActiveControlAddress           := Nil      ;;
   _HMG_ActiveControlValue             := Nil      ;;
   _HMG_ActiveControlAutoSize          := .f.      ;;
   _HMG_ActiveControlFont              := Nil      ;;
   _HMG_ActiveControlSize              := Nil      ;;
   _HMG_ActiveControlFontBold          := .f.      ;;
   _HMG_ActiveControlFontItalic        := .f.      ;;
   _HMG_ActiveControlFontUnderLine     := Nil      ;;
   _HMG_ActiveControlTooltip           := Nil      ;;
   _HMG_ActiveControlBackColor         := Nil      ;;
   _HMG_ActiveControlFontColor         := Nil      ;;
   _HMG_ActiveControlBorder            := .f.      ;;
   _HMG_ActiveControlClientEdge        := .f.      ;;
   _HMG_ActiveControlHScroll           := .f.      ;;
   _HMG_ActiveControlVScroll           := .f.      ;;
   _HMG_ActiveControlTransparent       := .f.      ;;
   _HMG_ActiveControlHelpid            := Nil      ;;
   _HMG_ActiveControlHandCursor        := .F.      ;;
   _HMG_ActiveControlRightAlign        := .F.      ;;
   _HMG_ActiveControlCenterAlign       := .F.      ;;
   _HMG_ActiveControlinvisible         := .f.

#xcommand ADDRESS   <address>;
   =>;
        _HMG_ActiveControlAddress      := <address>

#xcommand HANDCURSOR   <handcursor>;
   =>;
        _HMG_ActiveControlHandCursor   := <handcursor>

#xcommand END HYPERLINK ;
   =>;
        _DefineLabel ( ;
        _HMG_ActiveControlName,;
        _HMG_ActiveControlOf,;
        _HMG_ActiveControlCol,;
        _HMG_ActiveControlRow,;
        _HMG_ActiveControlValue,;
        _HMG_ActiveControlWidth,;
        _HMG_ActiveControlHeight,;
        _HMG_ActiveControlFont,;
        _HMG_ActiveControlSize,;
        _HMG_ActiveControlFontBold,;
        _HMG_ActiveControlBorder,;
        _HMG_ActiveControlClientEdge,;
        _HMG_ActiveControlHScroll,;
        _HMG_ActiveControlVScroll,;
        _HMG_ActiveControlTransparent,;
        _HMG_ActiveControlBackColor,;
	iif(hb_IsArray(_HMG_ActiveControlFontColor), _HMG_ActiveControlFontColor, {0,0,255}), , ;
        _HMG_ActiveControlTooltip,;
        _HMG_ActiveControlHelpId,;
        _HMG_ActiveControlInvisible,;
        _HMG_ActiveControlFontItalic,;
	     _HMG_ActiveControlFontUnderLine, ; // was: .f. - changed by p.d. 2016/10/06
	.f., ;
        _HMG_ActiveControlAutosize,;
        _HMG_ActiveControlRightAlign,;
        _HMG_ActiveControlCenterAlign,;
	.f. ,       ;
	iif(_HMG_ActiveControlHandCursor, {|| RC_CURSOR("MINIGUI_FINGER")}, Nil),, );;
	_setaddress(_HMG_ActiveControlName, iif(hb_IsString(_HMG_ActiveControlOf), _HMG_ActiveControlOf, _HMG_ActiveFormName), _HMG_ActiveControlAddress)

/*----------------------------------------------------------------------------
HotKeyBox
---------------------------------------------------------------------------*/

#xcommand DEFINE HOTKEYBOX <name> ;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlInvisible      := .f.      ;;
   _HMG_ActiveControlNoTabStop    := .f.   ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlTooltip           := Nil

#xcommand END HOTKEYBOX ;
   =>;
   _DefineHotKeyBox(;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlHelpId,;
      _HMG_ActiveControlInvisible , ;
      _HMG_ActiveControlNoTabStop , ;
      _HMG_ActiveControlFontBold,;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut )

/*----------------------------------------------------------------------------
Spinner
---------------------------------------------------------------------------*/

#xcommand DEFINE SPINNER <name>;
   =>;
   _HMG_ActiveControlName      := <"name">   ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlCol      := Nil      ;;
   _HMG_ActiveControlRow      := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlValue      := Nil      ;;
   _HMG_ActiveControlFont      := Nil      ;;
   _HMG_ActiveControlSize      := Nil      ;;
   _HMG_ActiveControlRangeLow      := Nil      ;;
   _HMG_ActiveControlRangeHigh      := Nil      ;;
   _HMG_ActiveControlTooltip      := Nil      ;;
   _HMG_ActiveControlOnChange      := Nil      ;;
   _HMG_ActiveControlOnLostFocus   := Nil      ;;
   _HMG_ActiveControlOnGotFocus   := Nil      ;;
   _HMG_ActiveControlHeight      := Nil      ;;
   _HMG_ActiveControlHelpId      := Nil      ;;
   _HMG_ActiveControlFontBold      := .f.      ;;
   _HMG_ActiveControlFontItalic   := .f.      ;;
   _HMG_ActiveControlFontStrikeOut   := .f.      ;;
   _HMG_ActiveControlFontUnderLine   := .f.      ;;
   _HMG_ActiveControlBackColor      := Nil      ;;
   _HMG_ActiveControlFontColor      := Nil      ;;
   _HMG_ActiveControlOptions       := Nil      ;;
   _HMG_ActiveControlHorizontal    := .f.      ;;
   _HMG_ActiveControlWrap      := .F.      ;;
   _HMG_ActiveControlReadOnly      := .F.      ;;
   _HMG_ActiveControlIncrement      := Nil      ;;
   _HMG_ActiveControlinvisible         := .f.   ;;
   _HMG_ActiveControlNoTabStop      := .f.

#xcommand WRAP      <wrap>;
   =>;
   _HMG_ActiveControlWrap   := <wrap>

#xcommand INCREMENT      <increment>;
   =>;
   _HMG_ActiveControlIncrement   := <increment>

#xcommand END SPINNER;
   =>;
   _DefineSpinner(;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlFont,;
      _HMG_ActiveControlSize,;
      _HMG_ActiveControlRangeLow,;
      _HMG_ActiveControlRangeHigh,;
      _HMG_ActiveControlTooltip,;
      _HMG_ActiveControlOnChange,;
      _HMG_ActiveControlOnLostFocus,;
      _HMG_ActiveControlOnGotFocus,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlHelpId , ;
      _HMG_ActiveControlHorizontal,;
      _HMG_ActiveControlinvisible , ;
      _HMG_ActiveControlNoTabStop , ;
      _HMG_ActiveControlFontBold , ;
      _HMG_ActiveControlFontItalic , ;
      _HMG_ActiveControlFontUnderLine , ;
      _HMG_ActiveControlFontStrikeOut , ;
      _HMG_ActiveControlWrap , ;
      _HMG_ActiveControlReadOnly , ;
      _HMG_ActiveControlIncrement ,;
      _HMG_ActiveControlBackColor,;
      _HMG_ActiveControlFontColor,;
      _HMG_ActiveControlOptions )

/*----------------------------------------------------------------------------
Graph
---------------------------------------------------------------------------*/

#xcommand DEFINE GRAPH IN WINDOW <name>;
   =>;
   _HMG_ActiveControlOf         := <"name"> ;;
   _HMG_ActiveControlRow        := Nil      ;;
   _HMG_ActiveControlCol        := Nil      ;;
   _HMG_ActiveControlRangeLow   := Nil      ;;
   _HMG_ActiveControlRangeHigh  := Nil      ;;
   _HMG_ActiveControlHeight     := Nil      ;;
   _HMG_ActiveControlWidth      := Nil      ;;
   _HMG_ActiveControlOptions    := Nil      ;;
   _HMG_ActiveControlItems      := Nil      ;;
   _HMG_ActiveControlWidths     := Nil      ;;
   _HMG_ActiveControlFont       := Nil      ;;
   _HMG_ActiveControlSize       := Nil      ;;
   _HMG_ActiveControlHScroll    := Nil      ;;
   _HMG_ActiveControlVScroll    := Nil      ;;
   _HMG_ActiveControlFontBold      := .f.   ;;
   _HMG_ActiveControlFontItalic    := .f.   ;;
   _HMG_ActiveControlFontStrikeOut := .f.   ;;
   _HMG_ActiveControlFontUnderLine := .f.   ;;
   _HMG_ActiveControlNoTabStop     := .f.   ;;
   _HMG_ActiveControlWrap          := .F.   ;;
   _HMG_ActiveControlReadOnly      := .F.   ;;
   _HMG_ActiveControlHeaders       := Nil   ;;
   _HMG_ActiveControlBackColor     := Nil   ;;
   _HMG_ActiveControlFontColor     := Nil   ;;
   _HMG_ActiveControlValue         := Nil   ;;
   _HMG_ActiveControlinvisible     := .f.   ;;
   _HMG_ActiveControlFormat        := Nil   ;;
   _HMG_ActiveControlIncrement     := Nil   ;;
   _HMG_ActiveControlBorder        := .t.

#xcommand GRAPHTYPE <type>;
   =>;
   _HMG_ActiveControlValue     := <type>

#xcommand BOTTOM  <b>;
   =>;
   _HMG_ActiveControlRangeLow  := <b>

#xcommand RIGHT   <r>;
   =>;
   _HMG_ActiveControlRangeHigh := <r>

#xcommand SERIES  <s>;
   =>;
   _HMG_ActiveControlOptions   := <s>

#xcommand TITLE   <t>;
   =>;
   _HMG_ActiveControlItems     := <t>

#xcommand YVALUES <yval>;
   =>;
   _HMG_ActiveControlWidths    := <yval>

#xcommand DEPTH   <d>;
   =>;
   _HMG_ActiveControlFont      := <d>

#xcommand BARWIDTH <bw>;
   =>;
   _HMG_ActiveControlSize      := <bw>

#xcommand BARSEPARATOR <bs>;
   =>;
   _HMG_ActiveControlVScroll   := <bs>

#xcommand HVALUES <hval>;
   =>;
   _HMG_ActiveControlHScroll   := <hval>

#xcommand 3DVIEW <v3d>;
   =>;
   _HMG_ActiveControlFontBold  := <v3d>

#xcommand SHOWGRID <grid>;
   =>;
   _HMG_ActiveControlFontItalic  := <grid>

#xcommand SHOWXGRID <xgrid>;
   =>;
   _HMG_ActiveControlFontStrikeOut  := <xgrid>

#xcommand SHOWYGRID <ygrid>;
   =>;
   _HMG_ActiveControlFontUnderLine  := <ygrid>

#xcommand SHOWXVALUES <xval>;
   =>;
   _HMG_ActiveControlNoTabStop  := <xval>

#xcommand SHOWYVALUES <sval>;
   =>;
   _HMG_ActiveControlWrap       := <sval>

#xcommand SHOWLEGENDS <l>;
   =>;
   _HMG_ActiveControlReadOnly   := <l>

#xcommand SERIENAMES <sn>;
   =>;
   _HMG_ActiveControlHeaders     := <sn>

#xcommand COLORS <colors>;
   =>;
   _HMG_ActiveControlFontColor   := <colors>

#xcommand SHOWDATAVALUES <showval>;
   =>;
   _HMG_ActiveControlinvisible   := <showval>

#xcommand DATAMASK   <mask>;
   =>;
   _HMG_ActiveControlFormat      := <mask>

#xcommand LEGENDSWIDTH <lw>;
   =>;
   _HMG_ActiveControlIncrement   := <lw>

#xcommand END GRAPH;
   => ;
   GraphShow(;
   _HMG_ActiveControlOf,;
   _HMG_ActiveControlRow,;
   _HMG_ActiveControlCol,;
   _HMG_ActiveControlRangeLow,;
   _HMG_ActiveControlRangeHigh,;
   _HMG_ActiveControlHeight,;
   _HMG_ActiveControlWidth,;
   _HMG_ActiveControlOptions,;
   _HMG_ActiveControlItems,;
   _HMG_ActiveControlWidths,;
   _HMG_ActiveControlFont,;
   _HMG_ActiveControlSize,;
   _HMG_ActiveControlVScroll,;
   _HMG_ActiveControlHScroll,;
   _HMG_ActiveControlFontBold,;
   _HMG_ActiveControlFontItalic,;
   _HMG_ActiveControlFontStrikeOut,;
   _HMG_ActiveControlFontUnderLine,;
   _HMG_ActiveControlNoTabStop,;
   _HMG_ActiveControlWrap,;
   _HMG_ActiveControlReadOnly,;
   _HMG_ActiveControlHeaders,;
   _HMG_ActiveControlFontColor,;
   _HMG_ActiveControlValue,;
   _HMG_ActiveControlinvisible,;
   _HMG_ActiveControlFormat,;
   _HMG_ActiveControlIncrement,;
   .NOT. _HMG_ActiveControlBorder )


#xcommand DEFINE PIE IN WINDOW <name>;
   =>;
   _HMG_ActiveControlOf         := <"name"> ;;
   _HMG_ActiveControlRow        := Nil      ;;
   _HMG_ActiveControlCol        := Nil      ;;
   _HMG_ActiveControlRangeLow   := Nil      ;;
   _HMG_ActiveControlRangeHigh  := Nil      ;;
   _HMG_ActiveControlOptions    := Nil      ;;
   _HMG_ActiveControlItems      := Nil      ;;
   _HMG_ActiveControlFontBold      := .f.   ;;
   _HMG_ActiveControlNoTabStop     := .f.   ;;
   _HMG_ActiveControlReadOnly      := .F.   ;;
   _HMG_ActiveControlHeaders       := Nil   ;;
   _HMG_ActiveControlFont          := Nil   ;;
   _HMG_ActiveControlFontColor     := Nil   ;;
   _HMG_ActiveControlFormat        := Nil   ;;
   _HMG_ActiveControlBorder        := .t.

#xcommand END PIE;
   => ;
   DrawPieGraph(;
   _HMG_ActiveControlOf,;
   _HMG_ActiveControlRow,;
   _HMG_ActiveControlCol,;
   _HMG_ActiveControlRangeLow,;
   _HMG_ActiveControlRangeHigh,;
   _HMG_ActiveControlOptions,;
   _HMG_ActiveControlHeaders,;
   _HMG_ActiveControlFontColor,;
   _HMG_ActiveControlItems,;
   _HMG_ActiveControlFont,;
   _HMG_ActiveControlFontBold,;
   _HMG_ActiveControlNoTabStop,;
   _HMG_ActiveControlReadOnly,;
   _HMG_ActiveControlFormat,;
   .NOT. _HMG_ActiveControlBorder )

/*----------------------------------------------------------------------------
Animated GIF
---------------------------------------------------------------------------*/

#xcommand DEFINE ANIGIF <name> ;
   =>;
   _HMG_ActiveControlName    := <"name"> ;;
   _HMG_ActiveControlOf      := Nil      ;;
   _HMG_ActiveControlCol     := Nil      ;;
   _HMG_ActiveControlRow     := Nil      ;;
   _HMG_ActiveControlPicture := Nil      ;;
   _HMG_ActiveControlValue   := Nil      ;;
   _HMG_ActiveControlWidth   := Nil      ;;
   _HMG_ActiveControlHeight  := Nil      ;;
   _HMG_ActiveControlBackgroundColor := Nil

#xcommand DELAY <value> ;
   =>;
   _HMG_ActiveControlValue := <value>

#xcommand END ANIGIF ;
   =>;
   _DefineAniGif(;
      _HMG_ActiveControlName,;
      _HMG_ActiveControlOf,;
      _HMG_ActiveControlPicture,;
      _HMG_ActiveControlRow,;
      _HMG_ActiveControlCol,;
      _HMG_ActiveControlWidth,;
      _HMG_ActiveControlHeight,;
      _HMG_ActiveControlValue,;
      _HMG_ActiveControlBackgroundColor )
