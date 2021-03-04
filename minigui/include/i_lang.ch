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

#translate SET LANGUAGE TO ENGLISH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_EN		; HB_LANGSELECT( "EN" )		; InitMessages()

#translate SET LANGUAGE TO SPANISH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_ES		; HB_LANGSELECT( "ES" )		; InitMessages()
#translate SET LANGUAGE TO FRENCH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_FR		; HB_LANGSELECT( "FR" )		; InitMessages()
#translate SET LANGUAGE TO PORTUGUESE		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_PT		; HB_LANGSELECT( "PT" )		; InitMessages()
#translate SET LANGUAGE TO ITALIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_IT		; HB_LANGSELECT( "IT" )		; InitMessages()
#translate SET LANGUAGE TO BASQUE		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_EU		; HB_LANGSELECT( "EU" )		; InitMessages()
#translate SET LANGUAGE TO DUTCH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_NL		; HB_LANGSELECT( "NL" )		; InitMessages()
#if ( __HARBOUR__ - 0 > 0x030200 )
#translate SET LANGUAGE TO GERMAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_DE		; HB_LANGSELECT( "DE" )		; InitMessages()
#translate SET LANGUAGE TO GREEK  		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_EL		; HB_LANGSELECT( "EL" )		; InitMessages()
#translate SET LANGUAGE TO RUSSIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_RU		; HB_LANGSELECT( "RU" )		; InitMessages()
#translate SET LANGUAGE TO UKRAINIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_UK		; HB_LANGSELECT( "UK" )		; InitMessages()
#translate SET LANGUAGE TO POLISH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_PL		; HB_LANGSELECT( "PL" )		; InitMessages()
#translate SET LANGUAGE TO CROATIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_HR		; HB_LANGSELECT( "HR" )		; InitMessages()
#translate SET LANGUAGE TO SLOVENIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_SL		; HB_LANGSELECT( "SL" )		; InitMessages()
#translate SET LANGUAGE TO CZECH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_CS		; HB_LANGSELECT( "CS" )		; InitMessages()
#translate SET LANGUAGE TO BULGARIAN            =>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_BG		; HB_LANGSELECT( "BG" )		; InitMessages()
#translate SET LANGUAGE TO HUNGARIAN            =>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_HU		; HB_LANGSELECT( "HU" )		; InitMessages()
#translate SET LANGUAGE TO SLOVAK               =>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_SK		; HB_LANGSELECT( "SK" )		; InitMessages()
#else
#translate SET LANGUAGE TO GERMAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_DEWIN	; HB_LANGSELECT( "DEWIN" )	; InitMessages()
#translate SET LANGUAGE TO GREEK  		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_ELWIN	; HB_LANGSELECT( "ELWIN" )	; InitMessages()
#translate SET LANGUAGE TO RUSSIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_RUWIN	; HB_LANGSELECT( "RUWIN" )	; InitMessages()
#translate SET LANGUAGE TO UKRAINIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_UAWIN	; HB_LANGSELECT( "UAWIN" )	; InitMessages()
#translate SET LANGUAGE TO POLISH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_PLWIN	; HB_LANGSELECT( "PLWIN" )	; InitMessages()
#translate SET LANGUAGE TO CROATIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_HR852	; HB_LANGSELECT( "HR852" )	; InitMessages()
#translate SET LANGUAGE TO SLOVENIAN		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_SLWIN	; HB_LANGSELECT( "SLWIN" )	; InitMessages()
#translate SET LANGUAGE TO CZECH		=>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_CSWIN	; HB_LANGSELECT( "CSWIN" )	; InitMessages()
#translate SET LANGUAGE TO BULGARIAN            =>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_BGWIN	; HB_LANGSELECT( "BGWIN" )	; InitMessages()
#translate SET LANGUAGE TO HUNGARIAN            =>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_HUWIN	; HB_LANGSELECT( "HUWIN" )	; InitMessages()
#translate SET LANGUAGE TO SLOVAK               =>  _HMG_LANG_ID := '  ' ; REQUEST HB_LANG_SKWIN	; HB_LANGSELECT( "SKWIN" )	; InitMessages()
#endif

// Language Is Not Supported by hb_LangSelect()
#translate SET LANGUAGE TO FINNISH		=>  _HMG_LANG_ID := 'FI' ;								; InitMessages()

#translate SET CODEPAGE TO ENGLISH		=>  HB_CDPSELECT( "EN" )

#translate SET CODEPAGE TO SPANISH		=>  REQUEST HB_CODEPAGE_ESWIN	; HB_CDPSELECT( "ESWIN" )
#translate SET CODEPAGE TO FRENCH		=>  REQUEST HB_CODEPAGE_FRWIN	; HB_CDPSELECT( "FRWIN" )
#translate SET CODEPAGE TO PORTUGUESE		=>  REQUEST HB_CODEPAGE_PT850	; HB_CDPSELECT( "PT850" )
#translate SET CODEPAGE TO GERMAN		=>  REQUEST HB_CODEPAGE_DEWIN	; HB_CDPSELECT( "DEWIN" )
#translate SET CODEPAGE TO GREEK  		=>  REQUEST HB_CODEPAGE_ELWIN	; HB_CDPSELECT( "ELWIN" )
#ifdef __XHARBOUR__
#translate SET CODEPAGE TO RUSSIAN		=>  REQUEST HB_CODEPAGE_RUWIN	; HB_CDPSELECT( "RUWIN" )
#else
#translate SET CODEPAGE TO RUSSIAN		=>  REQUEST HB_CODEPAGE_RU1251	; HB_CDPSELECT( "RU1251" )
#endif
#translate SET CODEPAGE TO UKRAINIAN		=>  REQUEST HB_CODEPAGE_UA1251	; HB_CDPSELECT( "UA1251" )
#translate SET CODEPAGE TO ITALIAN		=>  REQUEST HB_CODEPAGE_ITWIN	; HB_CDPSELECT( "ITWIN" )
#translate SET CODEPAGE TO POLISH		=>  REQUEST HB_CODEPAGE_PLWIN	; HB_CDPSELECT( "PLWIN" )
#translate SET CODEPAGE TO SLOVENIAN		=>  REQUEST HB_CODEPAGE_SLWIN	; HB_CDPSELECT( "SLWIN" )
#translate SET CODEPAGE TO SERBIAN		=>  REQUEST HB_CODEPAGE_SRWIN	; HB_CDPSELECT( "SRWIN" )
#translate SET CODEPAGE TO BULGARIAN		=>  REQUEST HB_CODEPAGE_BGWIN	; HB_CDPSELECT( "BGWIN" )
#translate SET CODEPAGE TO HUNGARIAN		=>  REQUEST HB_CODEPAGE_HUWIN	; HB_CDPSELECT( "HUWIN" )
#translate SET CODEPAGE TO CZECH                =>  REQUEST HB_CODEPAGE_CSWIN   ; HB_CDPSELECT( "CSWIN" )
#translate SET CODEPAGE TO SLOVAK               =>  REQUEST HB_CODEPAGE_SKWIN   ; HB_CDPSELECT( "SKWIN" )
#translate SET CODEPAGE TO DUTCH		=>  REQUEST HB_CODEPAGE_NL850	; HB_CDPSELECT( "NL850" )
#translate SET CODEPAGE TO FINNISH		=>  REQUEST HB_CODEPAGE_FI850	; HB_CDPSELECT( "FI850" )
#translate SET CODEPAGE TO TURKISH		=>  REQUEST HB_CODEPAGE_TRWIN	; HB_CDPSELECT( "TRWIN" )
#translate SET CODEPAGE TO SWEDISH		=>  REQUEST HB_CODEPAGE_SVWIN	; HB_CDPSELECT( "SVWIN" )
