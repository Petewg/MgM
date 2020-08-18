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
	Copyright 1999-2020, https://harbour.github.io/

	"WHAT32"
	Copyright 2002 AJ Wos <andrwos@aust1.net> 

	"HWGUI"
  	Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

---------------------------------------------------------------------------*/

/* 2012-05-07 PCH */
/* for using with _GetFontAttr()/_SetFontAttr() */
#define FONT_ATTR_BOLD       1
#define FONT_ATTR_ITALIC     2
#define FONT_ATTR_UNDERLINE  3
#define FONT_ATTR_STRIKEOUT  4
#define FONT_ATTR_ANGLE      5
#define FONT_ATTR_SIZE       6
#define FONT_ATTR_NAME       7

#xtranslate _GetFontName( <ControlName>, <ParentForm> ) ;
   => ;
   _GetFontAttr( <ControlName>, <ParentForm>, FONT_ATTR_NAME )

#xtranslate _SetFontName( <ControlName>, <ParentForm>, <Value> ) ;
   => ;
   _SetFontAttr( <ControlName>, <ParentForm>, <Value>, FONT_ATTR_NAME )

#xtranslate _GetFontSize( <ControlName>, <ParentForm> ) ;
   => ;
   _GetFontAttr( <ControlName>, <ParentForm>, FONT_ATTR_SIZE )

#xtranslate _SetFontSize( <ControlName>, <ParentForm>, <Value> ) ;
   => ;
   _SetFontAttr( <ControlName>, <ParentForm>, <Value>, FONT_ATTR_SIZE )

#xtranslate _GetFontBold( <ControlName>, <ParentForm> ) ;
   => ;
   _GetFontAttr( <ControlName>, <ParentForm>, FONT_ATTR_BOLD )

#xtranslate _SetFontBold( <ControlName>, <ParentForm>, <Value> ) ;
   => ;
   _SetFontAttr( <ControlName>, <ParentForm>, <Value>, FONT_ATTR_BOLD )

#xtranslate _GetFontItalic( <ControlName>, <ParentForm> ) ;
   => ;
   _GetFontAttr( <ControlName>, <ParentForm>, FONT_ATTR_ITALIC )

#xtranslate _SetFontItalic( <ControlName>, <ParentForm>, <Value> ) ;
   => ;
   _SetFontAttr( <ControlName>, <ParentForm>, <Value>, FONT_ATTR_ITALIC )

#xtranslate _GetFontUnderline( <ControlName>, <ParentForm> ) ;
   => ;
   _GetFontAttr( <ControlName>, <ParentForm>, FONT_ATTR_UNDERLINE )

#xtranslate _SetFontUnderline( <ControlName>, <ParentForm>, <Value> ) ;
   => ;
   _SetFontAttr( <ControlName>, <ParentForm>, <Value>, FONT_ATTR_UNDERLINE )

#xtranslate _GetFontStrikeOut( <ControlName>, <ParentForm> ) ;
   => ;
   _GetFontAttr( <ControlName>, <ParentForm>, FONT_ATTR_STRIKEOUT )

#xtranslate _SetFontStrikeOut( <ControlName>, <ParentForm>, <Value> ) ;
   => ;
   _SetFontAttr( <ControlName>, <ParentForm>, <Value>, FONT_ATTR_STRIKEOUT )

/* for using with GetFontList() */
// nCharSet
#define DEFAULT_CHARSET       1
#ifndef ANSI_CHARSET
#define ANSI_CHARSET          0
#define SYMBOL_CHARSET        2
#define SHIFTJIS_CHARSET      128
#define HANGEUL_CHARSET       129
#define HANGUL_CHARSET        129
#define GB2312_CHARSET        134
#define CHINESEBIG5_CHARSET   136
#define GREEK_CHARSET         161
#define TURKISH_CHARSET       162
#define HEBREW_CHARSET        177
#define ARABIC_CHARSET        178
#define BALTIC_CHARSET        186
#define RUSSIAN_CHARSET       204
#define THAI_CHARSET          222
#define EASTEUROPE_CHARSET    238
#define OEM_CHARSET           255
#endif /* ANSI_CHARSET */

#define JOHAB_CHARSET         130
#define VIETNAMESE_CHARSET    163
#define MAC_CHARSET           77
// nPitch
#define FONT_DEFAULT_PITCH    0
#define FONT_FIXED_PITCH      1
#define FONT_VARIABLE_PITCH   2
// nFontType
#define FONT_VECTOR_TYPE      1
#define FONT_RASTER_TYPE      2
#define FONT_TRUE_TYPE        3


#ifdef _OBJECT_
  #command SET FONT TO <fontname> , <fontsize> ;
    => ;
         _HMG_DefaultFontName := <fontname> ; _HMG_DefaultFontSize := <fontsize> ; oDlu2Pixel( , , <fontsize> )
#else
  #command SET FONT TO <fontname> , <fontsize> ;
    => ;
         _HMG_DefaultFontName := <fontname> ; _HMG_DefaultFontSize := <fontsize>
#endif

/* HMG 1.1 Experimental Build 11a */

#command DEFINE FONT <name>   ;
	FONTNAME <fontname>   ;
	[ SIZE <fontsize> ]   ;
	[ <bold : BOLD> ]     ;
	[ <italic : ITALIC> ] ;
	[ <underline : UNDERLINE> ] ;
	[ <strikeout : STRIKEOUT> ] ;
	[ CHARSET <charset> ]	;
	[ ANGLE <Angle> ]	;
	[ <default : DEFAULT> ] ;
   => ;
	_DefineFont (  ;
	<(name)>,      ;
	<fontname>,    ;
	<fontsize>,    ;
	<.bold.>,      ;
	<.italic.>,    ;
	<.underline.>, ;
	<.strikeout.>, ;
	<Angle>,       ;
	<.default.>,   ;
        <charset> )


#command RELEASE FONT <name1> [, <nameN> ] ;
   => ;
	_ReleaseFont ( <(name1)> ) ;
	[; _ReleaseFont ( <(nameN)> ) ]

///////////////////////////////////////////////////////////////////////////////

#xtranslate GetDefaultFontName () ;
   => ;
	GetSystemFont() \[1\]

#xtranslate GetDefaultFontSize () ;
   => ;
	GetSystemFont() \[2\]

///////////////////////////////////////////////////////////////////////////////

#command SET TITLEBAR FONT TO <fontname> , <fontsize> ;
	[ <bold : BOLD> ] ;
	[ CHARSET <charset> ]	;
   => ;
	SetNonClientFont( 1 , <fontname> , <fontsize> , <.bold.> , <charset> )

#command SET [STANDARD] MENU FONT TO <fontname> , <fontsize> ;
	[ <bold : BOLD> ] ;
	[ CHARSET <charset> ]	;
   => ;
	SetNonClientFont( 2 , <fontname> , <fontsize> , <.bold.> , <charset> )

#command SET STATUSBAR FONT TO <fontname> , <fontsize> ;
	[ <bold : BOLD> ] ;
	[ CHARSET <charset> ]	;
   => ;
	SetNonClientFont( 3 , <fontname> , <fontsize> , <.bold.> , <charset> )

#command SET MESSAGEBOX FONT TO <fontname> , <fontsize> ;
	[ <bold : BOLD> ] ;
	[ CHARSET <charset> ]	;
   => ;
	SetNonClientFont( 4 , <fontname> , <fontsize> , <.bold.> , <charset> )
