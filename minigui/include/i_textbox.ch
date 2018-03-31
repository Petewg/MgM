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

// TEXTBOX

#command @ <row>, <col> TEXTBOX <name>	;
        [ID <nId>]			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ HEIGHT <height> ]          	;
        [ WIDTH <width> ]            	;
    	[ FIELD <field> ]		;
        [ VALUE <value> ]            	;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]          	;
        [ SIZE <fontsize> ]          	;
        [ <bold : BOLD> ]		;
        [ <italic : ITALIC> ]		;
        [ <underline : UNDERLINE> ]	;
        [ <strikeout : STRIKEOUT> ]	;
        [ TOOLTIP <tooltip> ]        	;
        [ BACKCOLOR <backcolor> ]	;
        [ FONTCOLOR <fontcolor> ]	;
        [ MAXLENGTH <maxlength> ]    	;
        [ <upper: UPPERCASE> ]       	;
        [ <lower: LOWERCASE> ]       	;
        [ <numeric: NUMERIC> ]       	;
        [ <password: PASSWORD> ]     	;
        [ ON CHANGE <change> ]       	;
        [ ON GOTFOCUS <gotfocus> ]   	;
        [ ON LOSTFOCUS <lostfocus> ] 	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]	;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
         =>;
         _DefineTextBox( <"name">, <"parent">, <col>, <row>, <width>, <height>, <value>, <fontname>, <fontsize>, <tooltip>, <maxlength>, ;
		<.upper.>, <.lower.>, <.numeric.>, <.password.>, <{lostfocus}>, <{gotfocus}>, <{change}>, <{enter}>, ;
		<.RightAlign.>, <helpid>, <.readonly.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <"field">, ;
		<backcolor> , <fontcolor> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )


#command REDEFINE TEXTBOX <name>	;
        ID <nId>			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ FIELD <field> ]		;
        [ VALUE <value> ]            	;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]          	;
        [ SIZE <fontsize> ]          	;
        [ <bold : BOLD> ]               ;
        [ <italic : ITALIC> ]           ;
        [ <underline : UNDERLINE> ]     ;
        [ <strikeout : STRIKEOUT> ]     ;
        [ TOOLTIP <tooltip> ]        	;
        [ BACKCOLOR <backcolor> ]       ;
        [ FONTCOLOR <fontcolor> ]       ;
        [ MAXLENGTH <maxlength> ]    	;
        [ <upper: UPPERCASE> ]       	;
        [ <lower: LOWERCASE> ]       	;
        [ <numeric: NUMERIC> ]       	;
        [ <password: PASSWORD> ]     	;
        [ ON CHANGE <change> ]       	;
        [ ON GOTFOCUS <gotfocus> ]   	;
        [ ON LOSTFOCUS <lostfocus> ] 	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]	;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
         =>;
         _DefineTextBox( <"name">, <"parent">, 0, 0, 0, 0, <value>, <fontname>, <fontsize>, <tooltip>, <maxlength>, ;
		<.upper.>, <.lower.>, <.numeric.>, <.password.>, <{lostfocus}>, <{gotfocus}>, <{change}>, <{enter}>, ;
		<.RightAlign.>, <helpid>, <.readonly.>, <.bold.>, <.italic.>, <.underline.>, <.strikeout.>, <"field">, ;
		<backcolor> , <fontcolor> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )


// TEXTBOX ( NUMERIC INPUTMASK )

#command @ <row>,<col> TEXTBOX <name>	;
        [ID <nId>]			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ HEIGHT <height> ]		;
        [ WIDTH <w> ]			;
        [ FIELD <field> ]		;
        [ VALUE <value> ]		;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]		;
        [ SIZE <fontsize> ]		;
        [ <bold : BOLD> ]		;
        [ <italic : ITALIC> ]		;
        [ <underline : UNDERLINE> ]	;
        [ <strikeout : STRIKEOUT> ]	;
        [ TOOLTIP <tooltip> ]		;
        [ BACKCOLOR <backcolor> ]	;
        [ FONTCOLOR <fontcolor> ]	;
        NUMERIC				;
        INPUTMASK <inputmask>		;
        [ FORMAT <format> ]		;
        [ ON CHANGE <change> ]		;
        [ ON GOTFOCUS <gotfocus> ]	;
        [ ON LOSTFOCUS <lostfocus> ]	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]    ;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
	=>;
	_DefineMaskedTextBox ( <"name">, <"parent">, <col>, <row>, <inputmask> , <w> , <value> , <fontname> , <fontsize> , <tooltip> , <{lostfocus}> , <{gotfocus}> , <{change}> , <height> , <{enter}> , <.RightAlign.> , <helpid> , <format> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <"field"> , <backcolor> , <fontcolor> , <.readonly.> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )


#command REDEFINE TEXTBOX <name>	;
        ID <nId>			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ FIELD <field> ]		;
        [ VALUE <value> ]		;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]		;
        [ SIZE <fontsize> ]		;
        [ <bold : BOLD> ]		;
        [ <italic : ITALIC> ]		;
        [ <underline : UNDERLINE> ]	;
        [ <strikeout : STRIKEOUT> ]	;
        [ TOOLTIP <tooltip> ]		;
        [ BACKCOLOR <backcolor> ]	;
        [ FONTCOLOR <fontcolor> ]	;
        NUMERIC				;
        INPUTMASK <inputmask>		;
        [ FORMAT <format> ]		;
        [ ON CHANGE <change> ]		;
        [ ON GOTFOCUS <gotfocus> ]	;
        [ ON LOSTFOCUS <lostfocus> ]	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]    ;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
	=>;
	_DefineMaskedTextBox ( <"name">, <"parent">, 0, 0, <inputmask> , 0 , <value> , <fontname> , <fontsize> , <tooltip> , <{lostfocus}> , <{gotfocus}> , <{change}> , 0 , <{enter}> , <.RightAlign.> , <helpid> , <format> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <"field"> , <backcolor> , <fontcolor> , <.readonly.> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )


// TEXTBOX ( CHARACTER INPUTMASK )

#command @ <row>,<col> TEXTBOX <name>	;
        [ID <nId>]			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ HEIGHT <height> ]		;
        [ WIDTH <w> ]			;
        [ FIELD <field> ]		;
        [ VALUE <value> ]		;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]		;
        [ SIZE <fontsize> ]		;
        [ <bold : BOLD> ]		;
        [ <italic : ITALIC> ]		;
        [ <underline : UNDERLINE> ]	;
        [ <strikeout : STRIKEOUT> ]	;
        [ TOOLTIP <tooltip> ]		;
        [ BACKCOLOR <backcolor> ]	;
        [ FONTCOLOR <fontcolor> ]	;
        INPUTMASK <inputmask>		;
        [ ON CHANGE <change> ]		;
        [ ON GOTFOCUS <gotfocus> ]	;
        [ ON LOSTFOCUS <lostfocus> ]	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]    ;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
	=>;
	_DefineCharMaskTextBox ( <"name">, <"parent">, <col>, <row>, <inputmask> , <w> , <value> , <fontname> , <fontsize> , <tooltip> , <{lostfocus}> , <{gotfocus}> , <{change}> , <height> , <{enter}> , <.RightAlign.> , <helpid> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <"field"> , <backcolor> , <fontcolor> , .f. , <.readonly.> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )


#command REDEFINE TEXTBOX <name>	;
        ID <nId>			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ FIELD <field> ]		;
        [ VALUE <value> ]		;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]		;
        [ SIZE <fontsize> ]		;
        [ <bold : BOLD> ]		;
        [ <italic : ITALIC> ]		;
        [ <underline : UNDERLINE> ]	;
        [ <strikeout : STRIKEOUT> ]	;
        [ TOOLTIP <tooltip> ]		;
        [ BACKCOLOR <backcolor> ]	;
        [ FONTCOLOR <fontcolor> ]	;
        INPUTMASK <inputmask>		;
        [ ON CHANGE <change> ]		;
        [ ON GOTFOCUS <gotfocus> ]	;
        [ ON LOSTFOCUS <lostfocus> ]	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]    ;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
	=>;
	_DefineCharMaskTextBox ( <"name">, <"parent">, 0, 0, <inputmask> , 0 , <value> , <fontname> , <fontsize> , <tooltip> , <{lostfocus}> , <{gotfocus}> , <{change}> , 0 , <{enter}> , <.RightAlign.> , <helpid> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <"field"> , <backcolor> , <fontcolor> , .f. , <.readonly.> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )


// TEXTBOX ( DATE TYPE )

#xcommand @ <row>,<col> TEXTBOX <name>	;
        [ID <nId>]			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ HEIGHT <height> ]		;
        [ WIDTH <w> ]			;
        [ FIELD <field> ]		;
        [ VALUE <value> ]		;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]		;
        [ SIZE <fontsize> ]		;
        [ <bold : BOLD> ]		;
        [ <italic : ITALIC> ]		;
        [ <underline : UNDERLINE> ]	;
        [ <strikeout : STRIKEOUT> ]	;
        [ TOOLTIP <tooltip> ]		;
        [ BACKCOLOR <backcolor> ]	;
        [ FONTCOLOR <fontcolor> ]	;
        < date : DATE > 		;
        [ ON CHANGE <change> ]		;
        [ ON GOTFOCUS <gotfocus> ]	;
        [ ON LOSTFOCUS <lostfocus> ]	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]    ;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
	=>;
	_DefineCharMaskTextBox ( <"name">, <"parent">, <col>, <row>, "" , <w> , <value> , <fontname> , <fontsize> , <tooltip> , <{lostfocus}> , <{gotfocus}> , <{change}> , <height> , <{enter}> , <.RightAlign.> , <helpid> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <"field"> , <backcolor> , <fontcolor> , <.date.> , <.readonly.> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )


#xcommand REDEFINE TEXTBOX <name>	;
        ID <nId>			;
        [ <dummy1: OF, PARENT, DIALOG> <parent> ] ;
        [ FIELD <field> ]		;
        [ VALUE <value> ]		;
        [ < readonly: READONLY > ] 	;
        [ FONT <fontname> ]		;
        [ SIZE <fontsize> ]		;
        [ <bold : BOLD> ]		;
        [ <italic : ITALIC> ]		;
        [ <underline : UNDERLINE> ]	;
        [ <strikeout : STRIKEOUT> ]	;
        [ TOOLTIP <tooltip> ]		;
        [ BACKCOLOR <backcolor> ]	;
        [ FONTCOLOR <fontcolor> ]	;
        < date : DATE > 		;
        [ ON CHANGE <change> ]		;
        [ ON GOTFOCUS <gotfocus> ]	;
        [ ON LOSTFOCUS <lostfocus> ]	;
        [ ON ENTER <enter> ]		;
        [ <RightAlign: RIGHTALIGN> ]    ;
        [ <invisible: INVISIBLE> ]	;
        [ <notabstop: NOTABSTOP> ]	;
        [ <noborder: NOBORDER> ]	;
        [ HELPID <helpid> ] 		;
        [ <cuebanner : CUEBANNER, PLACEHOLDER> <CueText> ] ;
	=>;
	_DefineCharMaskTextBox ( <"name">, <"parent">, 0, 0, "" , 0 , <value> , <fontname> , <fontsize> , <tooltip> , <{lostfocus}> , <{gotfocus}> , <{change}> , 0 , <{enter}> , <.RightAlign.> , <helpid> , <.bold.>, <.italic.>, <.underline.>, <.strikeout.> , <"field"> , <backcolor> , <fontcolor> , <.date.> , <.readonly.> , <.invisible.> , <.notabstop.> , <.noborder.> , [<CueText>] , <nId> )
