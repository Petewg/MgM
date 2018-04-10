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
#ifndef VK_LBUTTON

///////////////////////////////////////////////////////////////////////////////
// Virtual key Codes And Modifiers
///////////////////////////////////////////////////////////////////////////////

#define VK_LBUTTON	1
#define VK_RBUTTON	2
#define VK_CANCEL	3
#define VK_MBUTTON	4
#define VK_BACK	8
#define VK_TAB	9
#define VK_CLEAR	12
#define VK_RETURN	13
#define VK_SHIFT	16
#define VK_CONTROL	17
#define VK_MENU	18
#define VK_PAUSE	19
#define VK_PRINT	42
#define VK_CAPITAL	20
#define VK_KANA	0x15
#define VK_HANGEUL	0x15
#define VK_HANGUL	0x15
#define VK_JUNJA	0x17
#define VK_FINAL	0x18
#define VK_HANJA	0x19
#define VK_KANJI	0x19
#define VK_CONVERT	0x1C
#define VK_NONCONVERT	0x1D
#define VK_ACCEPT	0x1E
#define VK_MODECHANGE	0x1F
#define VK_ESCAPE	27
#define VK_SPACE	32
#define VK_PRIOR	33
#define VK_NEXT	34
#define VK_END	35
#define VK_HOME	36
#define VK_LEFT	37
#define VK_UP	38
#define VK_RIGHT	39
#define VK_DOWN	40
#define VK_SELECT	41
#define VK_EXECUTE	43
#define VK_SNAPSHOT	44
#define VK_INSERT	45
#define VK_DELETE	46
#define VK_HELP	47
#define VK_0	48
#define VK_1	49
#define VK_2	50
#define VK_3	51
#define VK_4	52
#define VK_5	53
#define VK_6	54
#define VK_7	55
#define VK_8	56
#define VK_9	57
#define VK_A	65
#define VK_B	66
#define VK_C	67
#define VK_D	68
#define VK_E	69
#define VK_F	70
#define VK_G	71
#define VK_H	72
#define VK_I	73
#define VK_J	74
#define VK_K	75
#define VK_L	76
#define VK_M	77
#define VK_N	78
#define VK_O	79
#define VK_P	80
#define VK_Q	81
#define VK_R	82
#define VK_S	83
#define VK_T	84
#define VK_U	85
#define VK_V	86
#define VK_W	87
#define VK_X	88
#define VK_Y	89
#define VK_Z	90
#define VK_LWIN	0x5B
#define VK_RWIN	0x5C
#define VK_APPS	0x5D
#define VK_NUMPAD0	96
#define VK_NUMPAD1	97
#define VK_NUMPAD2	98
#define VK_NUMPAD3	99
#define VK_NUMPAD4	100
#define VK_NUMPAD5	101
#define VK_NUMPAD6	102
#define VK_NUMPAD7	103
#define VK_NUMPAD8	104
#define VK_NUMPAD9	105
#define VK_MULTIPLY	106
#define VK_ADD	107
#define VK_SEPARATOR	108
#define VK_SUBTRACT	109
#define VK_DECIMAL	110
#define VK_DIVIDE	111
#define VK_F1	112
#define VK_F2	113
#define VK_F3	114
#define VK_F4	115
#define VK_F5	116
#define VK_F6	117
#define VK_F7	118
#define VK_F8	119
#define VK_F9	120
#define VK_F10	121
#define VK_F11	122
#define VK_F12	123
#define VK_F13	124
#define VK_F14	125
#define VK_F15	126
#define VK_F16	127
#define VK_F17	128
#define VK_F18	129
#define VK_F19	130
#define VK_F20	131
#define VK_F21	132
#define VK_F22	133
#define VK_F23	134
#define VK_F24	135
#define VK_NUMLOCK	144
#define VK_SCROLL	145
#define VK_LSHIFT	160
#define VK_LCONTROL	162
#define VK_LMENU	164
#define VK_RSHIFT	161
#define VK_RCONTROL	163
#define VK_RMENU	165
#define VK_PROCESSKEY	229

#define MOD_ALT	1
#define MOD_CONTROL	2
#define MOD_SHIFT	4
#define MOD_WIN	8

#endif

///////////////////////////////////////////////////////////////////////////////
// ON KEY
///////////////////////////////////////////////////////////////////////////////

// Ctrl+Alt Mod Keys

#xcommand ON KEY CTRL+ALT+A [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_A , <{action}> )

#xcommand ON KEY CTRL+ALT+B [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_B , <{action}> )

#xcommand ON KEY CTRL+ALT+C [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_C , <{action}> )

#xcommand ON KEY CTRL+ALT+D [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_D , <{action}> )

#xcommand ON KEY CTRL+ALT+E [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_E , <{action}> )

#xcommand ON KEY CTRL+ALT+F [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F , <{action}> )

#xcommand ON KEY CTRL+ALT+G [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_G , <{action}> )

#xcommand ON KEY CTRL+ALT+H [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_H , <{action}> )

#xcommand ON KEY CTRL+ALT+I [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_I , <{action}> )

#xcommand ON KEY CTRL+ALT+J [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_J , <{action}> )

#xcommand ON KEY CTRL+ALT+K [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_K , <{action}> )

#xcommand ON KEY CTRL+ALT+L [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_L , <{action}> )

#xcommand ON KEY CTRL+ALT+M [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_M , <{action}> )

#xcommand ON KEY CTRL+ALT+N [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_N , <{action}> )

#xcommand ON KEY CTRL+ALT+O [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_O , <{action}> )

#xcommand ON KEY CTRL+ALT+P [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_P , <{action}> )

#xcommand ON KEY CTRL+ALT+Q [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Q , <{action}> )

#xcommand ON KEY CTRL+ALT+R [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_R , <{action}> )

#xcommand ON KEY CTRL+ALT+S [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_S , <{action}> )

#xcommand ON KEY CTRL+ALT+T [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_T , <{action}> )

#xcommand ON KEY CTRL+ALT+U [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_U , <{action}> )

#xcommand ON KEY CTRL+ALT+V [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_V , <{action}> )

#xcommand ON KEY CTRL+ALT+W [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_W , <{action}> )

#xcommand ON KEY CTRL+ALT+X [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_X , <{action}> )

#xcommand ON KEY CTRL+ALT+Y [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Y , <{action}> )

#xcommand ON KEY CTRL+ALT+Z [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Z , <{action}> )

#xcommand ON KEY CTRL+ALT+0 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_0 , <{action}> )

#xcommand ON KEY CTRL+ALT+1 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_1 , <{action}> )

#xcommand ON KEY CTRL+ALT+2 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_2 , <{action}> )

#xcommand ON KEY CTRL+ALT+3 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_3 , <{action}> )

#xcommand ON KEY CTRL+ALT+4 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_4 , <{action}> )

#xcommand ON KEY CTRL+ALT+5 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_5 , <{action}> )

#xcommand ON KEY CTRL+ALT+6 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_6 , <{action}> )

#xcommand ON KEY CTRL+ALT+7 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_7 , <{action}> )

#xcommand ON KEY CTRL+ALT+8 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_8 , <{action}> )

#xcommand ON KEY CTRL+ALT+9 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_9 , <{action}> )

#xcommand ON KEY CTRL+ALT+F1 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F1 , <{action}> )

#xcommand ON KEY CTRL+ALT+F2 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F2 , <{action}> )

#xcommand ON KEY CTRL+ALT+F3 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F3 , <{action}> )

#xcommand ON KEY CTRL+ALT+F4 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F4 , <{action}> )

#xcommand ON KEY CTRL+ALT+F5 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F5 , <{action}> )

#xcommand ON KEY CTRL+ALT+F6 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F6 , <{action}> )

#xcommand ON KEY CTRL+ALT+F7 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F7 , <{action}> )

#xcommand ON KEY CTRL+ALT+F8 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F8 , <{action}> )

#xcommand ON KEY CTRL+ALT+F9 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F9 , <{action}> )

#xcommand ON KEY CTRL+ALT+F10 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F10 , <{action}> )

#xcommand ON KEY CTRL+ALT+F11 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F11 , <{action}> )

#xcommand ON KEY CTRL+ALT+F12 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F12 , <{action}> )

#xcommand ON KEY CTRL+ALT+BACK [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_BACK , <{action}> )

#xcommand ON KEY CTRL+ALT+TAB [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_TAB , <{action}> )

#xcommand ON KEY CTRL+ALT+RETURN [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_RETURN , <{action}> )
 	
#xcommand ON KEY CTRL+ALT+ESCAPE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_ESCAPE , <{action}> )
 	
#xcommand ON KEY CTRL+ALT+END [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_END , <{action}> )
 
#xcommand ON KEY CTRL+ALT+HOME [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_HOME , <{action}> )

#xcommand ON KEY CTRL+ALT+LEFT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_LEFT , <{action}> )
 	
#xcommand ON KEY CTRL+ALT+UP [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_UP , <{action}> )

#xcommand ON KEY CTRL+ALT+RIGHT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_RIGHT , <{action}> )

#xcommand ON KEY CTRL+ALT+DOWN [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_DOWN , <{action}> )
 	
#xcommand ON KEY CTRL+ALT+INSERT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_INSERT , <{action}> )
 	
#xcommand ON KEY CTRL+ALT+DELETE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_DELETE , <{action}> )

#xcommand ON KEY CTRL+ALT+PRIOR [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_PRIOR , <{action}> )
 	
#xcommand ON KEY CTRL+ALT+NEXT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_NEXT , <{action}> )

// Ctrl+Shift Mod Keys

#xcommand ON KEY CTRL+SHIFT+A [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_A , <{action}> )

#xcommand ON KEY CTRL+SHIFT+B [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_B , <{action}> )

#xcommand ON KEY CTRL+SHIFT+C [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_C , <{action}> )

#xcommand ON KEY CTRL+SHIFT+D [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_D , <{action}> )

#xcommand ON KEY CTRL+SHIFT+E [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_E , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F , <{action}> )

#xcommand ON KEY CTRL+SHIFT+G [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_G , <{action}> )

#xcommand ON KEY CTRL+SHIFT+H [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_H , <{action}> )

#xcommand ON KEY CTRL+SHIFT+I [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_I , <{action}> )

#xcommand ON KEY CTRL+SHIFT+J [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_J , <{action}> )

#xcommand ON KEY CTRL+SHIFT+K [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_K , <{action}> )

#xcommand ON KEY CTRL+SHIFT+L [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_L , <{action}> )

#xcommand ON KEY CTRL+SHIFT+M [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_M , <{action}> )

#xcommand ON KEY CTRL+SHIFT+N [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_N , <{action}> )

#xcommand ON KEY CTRL+SHIFT+O [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_O , <{action}> )

#xcommand ON KEY CTRL+SHIFT+P [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_P , <{action}> )

#xcommand ON KEY CTRL+SHIFT+Q [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Q , <{action}> )

#xcommand ON KEY CTRL+SHIFT+R [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_R , <{action}> )

#xcommand ON KEY CTRL+SHIFT+S [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_S , <{action}> )

#xcommand ON KEY CTRL+SHIFT+T [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_T , <{action}> )

#xcommand ON KEY CTRL+SHIFT+U [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_U , <{action}> )

#xcommand ON KEY CTRL+SHIFT+V [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_V , <{action}> )

#xcommand ON KEY CTRL+SHIFT+W [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_W , <{action}> )

#xcommand ON KEY CTRL+SHIFT+X [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_X , <{action}> )

#xcommand ON KEY CTRL+SHIFT+Y [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Y , <{action}> )

#xcommand ON KEY CTRL+SHIFT+Z [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Z , <{action}> )

#xcommand ON KEY CTRL+SHIFT+0 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_0 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+1 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_1 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+2 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_2 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+3 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_3 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+4 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_4 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+5 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_5 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+6 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_6 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+7 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_7 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+8 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_8 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+9 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_9 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F1 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F1 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F2 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F2 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F3 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F3 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F4 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F4 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F5 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F5 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F6 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F6 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F7 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F7 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F8 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F8 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F9 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F9 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F10 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F10 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F11 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F11 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+F12 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F12 , <{action}> )

#xcommand ON KEY CTRL+SHIFT+BACK [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_BACK , <{action}> )

#xcommand ON KEY CTRL+SHIFT+TAB [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_TAB , <{action}> )

#xcommand ON KEY CTRL+SHIFT+RETURN [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_RETURN , <{action}> )
 	
#xcommand ON KEY CTRL+SHIFT+ESCAPE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_ESCAPE , <{action}> )
 	
#xcommand ON KEY CTRL+SHIFT+END [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_END , <{action}> )
 
#xcommand ON KEY CTRL+SHIFT+HOME [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_HOME , <{action}> )

#xcommand ON KEY CTRL+SHIFT+LEFT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_LEFT , <{action}> )
 	
#xcommand ON KEY CTRL+SHIFT+UP [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_UP , <{action}> )

#xcommand ON KEY CTRL+SHIFT+RIGHT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_RIGHT , <{action}> )

#xcommand ON KEY CTRL+SHIFT+DOWN [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DOWN , <{action}> )
 	
#xcommand ON KEY CTRL+SHIFT+INSERT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_INSERT , <{action}> )
 	
#xcommand ON KEY CTRL+SHIFT+DELETE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DELETE , <{action}> )

#xcommand ON KEY CTRL+SHIFT+PRIOR [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_PRIOR , <{action}> )
 	
#xcommand ON KEY CTRL+SHIFT+NEXT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_NEXT , <{action}> )

///////////////////////////////////////////////////////////////////////////////
// RELEASE KEY
///////////////////////////////////////////////////////////////////////////////

// Alt Mod Keys

#xcommand RELEASE KEY CTRL+ALT+A OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_A   )

#xcommand RELEASE KEY CTRL+ALT+B OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_B   )

#xcommand RELEASE KEY CTRL+ALT+C OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_C   )

#xcommand RELEASE KEY CTRL+ALT+D OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_D   )

#xcommand RELEASE KEY CTRL+ALT+E OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_E   )

#xcommand RELEASE KEY CTRL+ALT+F OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F   )

#xcommand RELEASE KEY CTRL+ALT+G OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_G   )

#xcommand RELEASE KEY CTRL+ALT+H OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_H   )

#xcommand RELEASE KEY CTRL+ALT+I OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_I   )

#xcommand RELEASE KEY CTRL+ALT+J OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_J   )

#xcommand RELEASE KEY CTRL+ALT+K OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_K   )

#xcommand RELEASE KEY CTRL+ALT+L OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_L   )

#xcommand RELEASE KEY CTRL+ALT+M OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_M   )

#xcommand RELEASE KEY CTRL+ALT+N OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_N   )

#xcommand RELEASE KEY CTRL+ALT+O OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_O   )

#xcommand RELEASE KEY CTRL+ALT+P OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_P   )

#xcommand RELEASE KEY CTRL+ALT+Q OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Q   )

#xcommand RELEASE KEY CTRL+ALT+R OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_R   )

#xcommand RELEASE KEY CTRL+ALT+S OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_S   )

#xcommand RELEASE KEY CTRL+ALT+T OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_T   )

#xcommand RELEASE KEY CTRL+ALT+U OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_U   )

#xcommand RELEASE KEY CTRL+ALT+V OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_V   )

#xcommand RELEASE KEY CTRL+ALT+W OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_W   )

#xcommand RELEASE KEY CTRL+ALT+X OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_X   )

#xcommand RELEASE KEY CTRL+ALT+Y OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Y   )

#xcommand RELEASE KEY CTRL+ALT+Z OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Z   )

#xcommand RELEASE KEY CTRL+ALT+0 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_0   )

#xcommand RELEASE KEY CTRL+ALT+1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_1   )

#xcommand RELEASE KEY CTRL+ALT+2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_2   )

#xcommand RELEASE KEY CTRL+ALT+3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_3   )

#xcommand RELEASE KEY CTRL+ALT+4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_4   )

#xcommand RELEASE KEY CTRL+ALT+5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_5   )

#xcommand RELEASE KEY CTRL+ALT+6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_6   )

#xcommand RELEASE KEY CTRL+ALT+7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_7   )

#xcommand RELEASE KEY CTRL+ALT+8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_8   )

#xcommand RELEASE KEY CTRL+ALT+9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_9   )

#xcommand RELEASE KEY CTRL+ALT+F1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F1   )

#xcommand RELEASE KEY CTRL+ALT+F2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F2   )

#xcommand RELEASE KEY CTRL+ALT+F3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F3   )

#xcommand RELEASE KEY CTRL+ALT+F4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F4   )

#xcommand RELEASE KEY CTRL+ALT+F5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F5   )

#xcommand RELEASE KEY CTRL+ALT+F6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F6   )

#xcommand RELEASE KEY CTRL+ALT+F7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F7   )

#xcommand RELEASE KEY CTRL+ALT+F8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F8   )

#xcommand RELEASE KEY CTRL+ALT+F9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F9   )

#xcommand RELEASE KEY CTRL+ALT+F10 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F10   )

#xcommand RELEASE KEY CTRL+ALT+F11 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F11   )

#xcommand RELEASE KEY CTRL+ALT+F12 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F12   )

#xcommand RELEASE KEY CTRL+ALT+BACK OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_BACK   )

#xcommand RELEASE KEY CTRL+ALT+TAB OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_TAB   )

#xcommand RELEASE KEY CTRL+ALT+RETURN OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_RETURN   )
 	
#xcommand RELEASE KEY CTRL+ALT+ESCAPE OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_ESCAPE   )
 	
#xcommand RELEASE KEY CTRL+ALT+END OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_END   )
 
#xcommand RELEASE KEY CTRL+ALT+HOME OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_HOME   )

#xcommand RELEASE KEY CTRL+ALT+LEFT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_LEFT   )
 	
#xcommand RELEASE KEY CTRL+ALT+UP OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_UP   )

#xcommand RELEASE KEY CTRL+ALT+RIGHT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_RIGHT   )

#xcommand RELEASE KEY CTRL+ALT+DOWN OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_DOWN   )
 	
#xcommand RELEASE KEY CTRL+ALT+INSERT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_INSERT   )
 	
#xcommand RELEASE KEY CTRL+ALT+DELETE OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_DELETE   )

#xcommand RELEASE KEY CTRL+ALT+PRIOR OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_PRIOR   )
 	
#xcommand RELEASE KEY CTRL+ALT+NEXT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_NEXT   )

// Shift Mod Keys

#xcommand RELEASE KEY CTRL+SHIFT+A OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_A   )

#xcommand RELEASE KEY CTRL+SHIFT+B OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_B   )

#xcommand RELEASE KEY CTRL+SHIFT+C OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_C   )

#xcommand RELEASE KEY CTRL+SHIFT+D OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_D   )

#xcommand RELEASE KEY CTRL+SHIFT+E OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_E   )

#xcommand RELEASE KEY CTRL+SHIFT+F OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F   )

#xcommand RELEASE KEY CTRL+SHIFT+G OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_G   )

#xcommand RELEASE KEY CTRL+SHIFT+H OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_H   )

#xcommand RELEASE KEY CTRL+SHIFT+I OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_I   )

#xcommand RELEASE KEY CTRL+SHIFT+J OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_J   )

#xcommand RELEASE KEY CTRL+SHIFT+K OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_K   )

#xcommand RELEASE KEY CTRL+SHIFT+L OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_L   )

#xcommand RELEASE KEY CTRL+SHIFT+M OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_M   )

#xcommand RELEASE KEY CTRL+SHIFT+N OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_N   )

#xcommand RELEASE KEY CTRL+SHIFT+O OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_O   )

#xcommand RELEASE KEY CTRL+SHIFT+P OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_P   )

#xcommand RELEASE KEY CTRL+SHIFT+Q OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Q   )

#xcommand RELEASE KEY CTRL+SHIFT+R OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_R   )

#xcommand RELEASE KEY CTRL+SHIFT+S OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_S   )

#xcommand RELEASE KEY CTRL+SHIFT+T OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_T   )

#xcommand RELEASE KEY CTRL+SHIFT+U OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_U   )

#xcommand RELEASE KEY CTRL+SHIFT+V OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_V   )

#xcommand RELEASE KEY CTRL+SHIFT+W OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_W   )

#xcommand RELEASE KEY CTRL+SHIFT+X OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_X   )

#xcommand RELEASE KEY CTRL+SHIFT+Y OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Y   )

#xcommand RELEASE KEY CTRL+SHIFT+Z OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Z   )

#xcommand RELEASE KEY CTRL+SHIFT+0 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_0   )

#xcommand RELEASE KEY CTRL+SHIFT+1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_1   )

#xcommand RELEASE KEY CTRL+SHIFT+2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_2   )

#xcommand RELEASE KEY CTRL+SHIFT+3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_3   )

#xcommand RELEASE KEY CTRL+SHIFT+4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_4   )

#xcommand RELEASE KEY CTRL+SHIFT+5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_5   )

#xcommand RELEASE KEY CTRL+SHIFT+6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_6   )

#xcommand RELEASE KEY CTRL+SHIFT+7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_7   )

#xcommand RELEASE KEY CTRL+SHIFT+8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_8   )

#xcommand RELEASE KEY CTRL+SHIFT+9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_9   )

#xcommand RELEASE KEY CTRL+SHIFT+F1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F1   )

#xcommand RELEASE KEY CTRL+SHIFT+F2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F2   )

#xcommand RELEASE KEY CTRL+SHIFT+F3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F3   )

#xcommand RELEASE KEY CTRL+SHIFT+F4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F4   )

#xcommand RELEASE KEY CTRL+SHIFT+F5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F5   )

#xcommand RELEASE KEY CTRL+SHIFT+F6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F6   )

#xcommand RELEASE KEY CTRL+SHIFT+F7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F7   )

#xcommand RELEASE KEY CTRL+SHIFT+F8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F8   )

#xcommand RELEASE KEY CTRL+SHIFT+F9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F9   )

#xcommand RELEASE KEY CTRL+SHIFT+F10 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F10   )

#xcommand RELEASE KEY CTRL+SHIFT+F11 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F11   )

#xcommand RELEASE KEY CTRL+SHIFT+F12 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F12   )

#xcommand RELEASE KEY CTRL+SHIFT+BACK OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_BACK   )

#xcommand RELEASE KEY CTRL+SHIFT+TAB OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_TAB   )

#xcommand RELEASE KEY CTRL+SHIFT+RETURN OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_RETURN   )
 	
#xcommand RELEASE KEY CTRL+SHIFT+ESCAPE OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_ESCAPE   )
 	
#xcommand RELEASE KEY CTRL+SHIFT+END OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_END   )
 
#xcommand RELEASE KEY CTRL+SHIFT+HOME OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_HOME   )

#xcommand RELEASE KEY CTRL+SHIFT+LEFT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_LEFT   )
 	
#xcommand RELEASE KEY CTRL+SHIFT+UP OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_UP   )

#xcommand RELEASE KEY CTRL+SHIFT+RIGHT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_RIGHT   )

#xcommand RELEASE KEY CTRL+SHIFT+DOWN OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DOWN   )
 	
#xcommand RELEASE KEY CTRL+SHIFT+INSERT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_INSERT   )
 	
#xcommand RELEASE KEY CTRL+SHIFT+DELETE OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DELETE   )

#xcommand RELEASE KEY CTRL+SHIFT+PRIOR OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_PRIOR   )
 	
#xcommand RELEASE KEY CTRL+SHIFT+NEXT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_NEXT   )

// Control Mod Keys

#xcommand RELEASE KEY CONTROL+A OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_A   )

#xcommand RELEASE KEY CONTROL+B OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_B   )

#xcommand RELEASE KEY CONTROL+C OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_C   )

#xcommand RELEASE KEY CONTROL+D OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_D   )

#xcommand RELEASE KEY CONTROL+E OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_E   )

#xcommand RELEASE KEY CONTROL+F OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F   )

#xcommand RELEASE KEY CONTROL+G OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_G   )

#xcommand RELEASE KEY CONTROL+H OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_H   )

#xcommand RELEASE KEY CONTROL+I OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_I   )

#xcommand RELEASE KEY CONTROL+J OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_J   )

#xcommand RELEASE KEY CONTROL+K OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_K   )

#xcommand RELEASE KEY CONTROL+L OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_L   )

#xcommand RELEASE KEY CONTROL+M OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_M   )

#xcommand RELEASE KEY CONTROL+N OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_N   )

#xcommand RELEASE KEY CONTROL+O OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_O   )

#xcommand RELEASE KEY CONTROL+P OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_P   )

#xcommand RELEASE KEY CONTROL+Q OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_Q   )

#xcommand RELEASE KEY CONTROL+R OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_R   )

#xcommand RELEASE KEY CONTROL+S OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_S   )

#xcommand RELEASE KEY CONTROL+T OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_T   )

#xcommand RELEASE KEY CONTROL+U OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_U   )

#xcommand RELEASE KEY CONTROL+V OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_V   )

#xcommand RELEASE KEY CONTROL+W OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_W   )

#xcommand RELEASE KEY CONTROL+X OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_X   )

#xcommand RELEASE KEY CONTROL+Y OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_Y   )

#xcommand RELEASE KEY CONTROL+Z OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_Z   )

#xcommand RELEASE KEY CONTROL+0 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_0   )

#xcommand RELEASE KEY CONTROL+1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_1   )

#xcommand RELEASE KEY CONTROL+2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_2   )

#xcommand RELEASE KEY CONTROL+3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_3   )

#xcommand RELEASE KEY CONTROL+4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_4   )

#xcommand RELEASE KEY CONTROL+5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_5   )

#xcommand RELEASE KEY CONTROL+6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_6   )

#xcommand RELEASE KEY CONTROL+7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_7   )

#xcommand RELEASE KEY CONTROL+8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_8   )

#xcommand RELEASE KEY CONTROL+9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_9   )

#xcommand RELEASE KEY CONTROL+F1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F1   )

#xcommand RELEASE KEY CONTROL+F2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F2   )

#xcommand RELEASE KEY CONTROL+F3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F3   )

#xcommand RELEASE KEY CONTROL+F4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F4   )

#xcommand RELEASE KEY CONTROL+F5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F5   )

#xcommand RELEASE KEY CONTROL+F6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F6   )

#xcommand RELEASE KEY CONTROL+F7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F7   )

#xcommand RELEASE KEY CONTROL+F8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F8   )

#xcommand RELEASE KEY CONTROL+F9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F9   )

#xcommand RELEASE KEY CONTROL+F10 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F10   )

#xcommand RELEASE KEY CONTROL+F11 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F11   )

#xcommand RELEASE KEY CONTROL+F12 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_F12   )

#xcommand RELEASE KEY CONTROL+BACK OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_BACK   )

#xcommand RELEASE KEY CONTROL+TAB OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_TAB   )

#xcommand RELEASE KEY CONTROL+RETURN OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_RETURN   )
 	
#xcommand RELEASE KEY CONTROL+ESCAPE OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_ESCAPE   )
 	
#xcommand RELEASE KEY CONTROL+END OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_END   )
 
#xcommand RELEASE KEY CONTROL+HOME OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_HOME   )

#xcommand RELEASE KEY CONTROL+LEFT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_LEFT   )
 	
#xcommand RELEASE KEY CONTROL+UP OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_UP   )

#xcommand RELEASE KEY CONTROL+RIGHT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_RIGHT   )

#xcommand RELEASE KEY CONTROL+DOWN OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_DOWN   )
 	
#xcommand RELEASE KEY CONTROL+INSERT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_INSERT   )
 	
#xcommand RELEASE KEY CONTROL+DELETE OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_DELETE   )

#xcommand RELEASE KEY CONTROL+PRIOR OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_PRIOR   )
 	
#xcommand RELEASE KEY CONTROL+NEXT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_NEXT   )

///////////////////////////////////////////////////////////////////////////////
// STORE KEY
///////////////////////////////////////////////////////////////////////////////

// Alt Mod Keys

#xcommand STORE KEY CTRL+ALT+A OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_A   )

#xcommand STORE KEY CTRL+ALT+B OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_B   )

#xcommand STORE KEY CTRL+ALT+C OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_C   )

#xcommand STORE KEY CTRL+ALT+D OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_D   )

#xcommand STORE KEY CTRL+ALT+E OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_E   )

#xcommand STORE KEY CTRL+ALT+F OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F   )

#xcommand STORE KEY CTRL+ALT+G OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_G   )

#xcommand STORE KEY CTRL+ALT+H OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_H   )

#xcommand STORE KEY CTRL+ALT+I OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_I   )

#xcommand STORE KEY CTRL+ALT+J OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_J   )

#xcommand STORE KEY CTRL+ALT+K OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_K   )

#xcommand STORE KEY CTRL+ALT+L OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_L   )

#xcommand STORE KEY CTRL+ALT+M OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_M   )

#xcommand STORE KEY CTRL+ALT+N OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_N   )

#xcommand STORE KEY CTRL+ALT+O OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_O   )

#xcommand STORE KEY CTRL+ALT+P OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_P   )

#xcommand STORE KEY CTRL+ALT+Q OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Q   )

#xcommand STORE KEY CTRL+ALT+R OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_R   )

#xcommand STORE KEY CTRL+ALT+S OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_S   )

#xcommand STORE KEY CTRL+ALT+T OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_T   )

#xcommand STORE KEY CTRL+ALT+U OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_U   )

#xcommand STORE KEY CTRL+ALT+V OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_V   )

#xcommand STORE KEY CTRL+ALT+W OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_W   )

#xcommand STORE KEY CTRL+ALT+X OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_X   )

#xcommand STORE KEY CTRL+ALT+Y OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Y   )

#xcommand STORE KEY CTRL+ALT+Z OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_Z   )

#xcommand STORE KEY CTRL+ALT+0 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_0   )

#xcommand STORE KEY CTRL+ALT+1 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_1   )

#xcommand STORE KEY CTRL+ALT+2 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_2   )

#xcommand STORE KEY CTRL+ALT+3 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_3   )

#xcommand STORE KEY CTRL+ALT+4 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_4   )

#xcommand STORE KEY CTRL+ALT+5 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_5   )

#xcommand STORE KEY CTRL+ALT+6 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_6   )

#xcommand STORE KEY CTRL+ALT+7 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_7   )

#xcommand STORE KEY CTRL+ALT+8 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_8   )

#xcommand STORE KEY CTRL+ALT+9 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_9   )

#xcommand STORE KEY CTRL+ALT+F1 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F1   )

#xcommand STORE KEY CTRL+ALT+F2 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F2   )

#xcommand STORE KEY CTRL+ALT+F3 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F3   )

#xcommand STORE KEY CTRL+ALT+F4 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F4   )

#xcommand STORE KEY CTRL+ALT+F5 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F5   )

#xcommand STORE KEY CTRL+ALT+F6 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F6   )

#xcommand STORE KEY CTRL+ALT+F7 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F7   )

#xcommand STORE KEY CTRL+ALT+F8 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F8   )

#xcommand STORE KEY CTRL+ALT+F9 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F9   )

#xcommand STORE KEY CTRL+ALT+F10 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F10   )

#xcommand STORE KEY CTRL+ALT+F11 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F11   )

#xcommand STORE KEY CTRL+ALT+F12 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_F12   )

#xcommand STORE KEY CTRL+ALT+BACK OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_BACK   )

#xcommand STORE KEY CTRL+ALT+TAB OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_TAB   )

#xcommand STORE KEY CTRL+ALT+RETURN OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_RETURN   )
 	
#xcommand STORE KEY CTRL+ALT+ESCAPE OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_ESCAPE   )
 	
#xcommand STORE KEY CTRL+ALT+END OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_END   )
 
#xcommand STORE KEY CTRL+ALT+HOME OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_HOME   )

#xcommand STORE KEY CTRL+ALT+LEFT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_LEFT   )
 	
#xcommand STORE KEY CTRL+ALT+UP OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_UP   )

#xcommand STORE KEY CTRL+ALT+RIGHT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_RIGHT   )

#xcommand STORE KEY CTRL+ALT+DOWN OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_DOWN   )
 	
#xcommand STORE KEY CTRL+ALT+INSERT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_INSERT   )
 	
#xcommand STORE KEY CTRL+ALT+DELETE OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_DELETE   )

#xcommand STORE KEY CTRL+ALT+PRIOR OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_PRIOR   )
 	
#xcommand STORE KEY CTRL+ALT+NEXT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_ALT + MOD_CONTROL , VK_NEXT   )

// Shift Mod Keys

#xcommand STORE KEY CTRL+SHIFT+A OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_A   )

#xcommand STORE KEY CTRL+SHIFT+B OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_B   )

#xcommand STORE KEY CTRL+SHIFT+C OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_C   )

#xcommand STORE KEY CTRL+SHIFT+D OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_D   )

#xcommand STORE KEY CTRL+SHIFT+E OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_E   )

#xcommand STORE KEY CTRL+SHIFT+F OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F   )

#xcommand STORE KEY CTRL+SHIFT+G OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_G   )

#xcommand STORE KEY CTRL+SHIFT+H OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_H   )

#xcommand STORE KEY CTRL+SHIFT+I OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_I   )

#xcommand STORE KEY CTRL+SHIFT+J OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_J   )

#xcommand STORE KEY CTRL+SHIFT+K OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_K   )

#xcommand STORE KEY CTRL+SHIFT+L OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_L   )

#xcommand STORE KEY CTRL+SHIFT+M OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_M   )

#xcommand STORE KEY CTRL+SHIFT+N OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_N   )

#xcommand STORE KEY CTRL+SHIFT+O OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_O   )

#xcommand STORE KEY CTRL+SHIFT+P OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_P   )

#xcommand STORE KEY CTRL+SHIFT+Q OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Q   )

#xcommand STORE KEY CTRL+SHIFT+R OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_R   )

#xcommand STORE KEY CTRL+SHIFT+S OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_S   )

#xcommand STORE KEY CTRL+SHIFT+T OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_T   )

#xcommand STORE KEY CTRL+SHIFT+U OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_U   )

#xcommand STORE KEY CTRL+SHIFT+V OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_V   )

#xcommand STORE KEY CTRL+SHIFT+W OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_W   )

#xcommand STORE KEY CTRL+SHIFT+X OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_X   )

#xcommand STORE KEY CTRL+SHIFT+Y OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Y   )

#xcommand STORE KEY CTRL+SHIFT+Z OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_Z   )

#xcommand STORE KEY CTRL+SHIFT+0 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_0   )

#xcommand STORE KEY CTRL+SHIFT+1 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_1   )

#xcommand STORE KEY CTRL+SHIFT+2 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_2   )

#xcommand STORE KEY CTRL+SHIFT+3 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_3   )

#xcommand STORE KEY CTRL+SHIFT+4 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_4   )

#xcommand STORE KEY CTRL+SHIFT+5 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_5   )

#xcommand STORE KEY CTRL+SHIFT+6 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_6   )

#xcommand STORE KEY CTRL+SHIFT+7 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_7   )

#xcommand STORE KEY CTRL+SHIFT+8 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_8   )

#xcommand STORE KEY CTRL+SHIFT+9 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_9   )

#xcommand STORE KEY CTRL+SHIFT+F1 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F1   )

#xcommand STORE KEY CTRL+SHIFT+F2 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F2   )

#xcommand STORE KEY CTRL+SHIFT+F3 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F3   )

#xcommand STORE KEY CTRL+SHIFT+F4 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F4   )

#xcommand STORE KEY CTRL+SHIFT+F5 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F5   )

#xcommand STORE KEY CTRL+SHIFT+F6 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F6   )

#xcommand STORE KEY CTRL+SHIFT+F7 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F7   )

#xcommand STORE KEY CTRL+SHIFT+F8 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F8   )

#xcommand STORE KEY CTRL+SHIFT+F9 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F9   )

#xcommand STORE KEY CTRL+SHIFT+F10 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F10   )

#xcommand STORE KEY CTRL+SHIFT+F11 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F11   )

#xcommand STORE KEY CTRL+SHIFT+F12 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F12   )

#xcommand STORE KEY CTRL+SHIFT+BACK OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_BACK   )

#xcommand STORE KEY CTRL+SHIFT+TAB OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_TAB   )

#xcommand STORE KEY CTRL+SHIFT+RETURN OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_RETURN   )
 	
#xcommand STORE KEY CTRL+SHIFT+ESCAPE OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_ESCAPE   )
 	
#xcommand STORE KEY CTRL+SHIFT+END OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_END   )
 
#xcommand STORE KEY CTRL+SHIFT+HOME OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_HOME   )

#xcommand STORE KEY CTRL+SHIFT+LEFT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_LEFT   )
 	
#xcommand STORE KEY CTRL+SHIFT+UP OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_UP   )

#xcommand STORE KEY CTRL+SHIFT+RIGHT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_RIGHT   )

#xcommand STORE KEY CTRL+SHIFT+DOWN OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DOWN   )
 	
#xcommand STORE KEY CTRL+SHIFT+INSERT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_INSERT   )
 	
#xcommand STORE KEY CTRL+SHIFT+DELETE OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DELETE   )

#xcommand STORE KEY CTRL+SHIFT+PRIOR OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_PRIOR   )
 	
#xcommand STORE KEY CTRL+SHIFT+NEXT OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_NEXT   )

// Win Mod Keys

#xcommand ON KEY WIN+A [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_A , <{action}> )

#xcommand ON KEY WIN+B [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_B , <{action}> )

#xcommand ON KEY WIN+C [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_C , <{action}> )

#xcommand ON KEY WIN+D [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_D , <{action}> )

#xcommand ON KEY WIN+E [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_E , <{action}> )

#xcommand ON KEY WIN+F [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F , <{action}> )

#xcommand ON KEY WIN+G [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_G , <{action}> )

#xcommand ON KEY WIN+H [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_H , <{action}> )

#xcommand ON KEY WIN+I [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_I , <{action}> )

#xcommand ON KEY WIN+J [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_J , <{action}> )

#xcommand ON KEY WIN+K [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_K , <{action}> )

#xcommand ON KEY WIN+L [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_L , <{action}> )

#xcommand ON KEY WIN+M [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_M , <{action}> )

#xcommand ON KEY WIN+N [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_N , <{action}> )

#xcommand ON KEY WIN+O [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_O , <{action}> )

#xcommand ON KEY WIN+P [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_P , <{action}> )

#xcommand ON KEY WIN+Q [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_Q , <{action}> )

#xcommand ON KEY WIN+R [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_R , <{action}> )

#xcommand ON KEY WIN+S [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_S , <{action}> )

#xcommand ON KEY WIN+T [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_T , <{action}> )

#xcommand ON KEY WIN+U [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_U , <{action}> )

#xcommand ON KEY WIN+V [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_V , <{action}> )

#xcommand ON KEY WIN+W [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_W , <{action}> )

#xcommand ON KEY WIN+X [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_X , <{action}> )

#xcommand ON KEY WIN+Y [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_Y , <{action}> )

#xcommand ON KEY WIN+Z [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_Z , <{action}> )

#xcommand ON KEY WIN+0 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_0 , <{action}> )

#xcommand ON KEY WIN+1 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_1 , <{action}> )

#xcommand ON KEY WIN+2 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_2 , <{action}> )

#xcommand ON KEY WIN+3 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_3 , <{action}> )

#xcommand ON KEY WIN+4 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_4 , <{action}> )

#xcommand ON KEY WIN+5 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_5 , <{action}> )

#xcommand ON KEY WIN+6 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_6 , <{action}> )

#xcommand ON KEY WIN+7 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_7 , <{action}> )

#xcommand ON KEY WIN+8 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_8 , <{action}> )

#xcommand ON KEY WIN+9 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_9 , <{action}> )

#xcommand ON KEY WIN+F1 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F1 , <{action}> )

#xcommand ON KEY WIN+F2 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F2 , <{action}> )

#xcommand ON KEY WIN+F3 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F3 , <{action}> )

#xcommand ON KEY WIN+F4 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F4 , <{action}> )

#xcommand ON KEY WIN+F5 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F5 , <{action}> )

#xcommand ON KEY WIN+F6 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F6 , <{action}> )

#xcommand ON KEY WIN+F7 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F7 , <{action}> )

#xcommand ON KEY WIN+F8 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F8 , <{action}> )

#xcommand ON KEY WIN+F9 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F9 , <{action}> )

#xcommand ON KEY WIN+F10 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F10 , <{action}> )

#xcommand ON KEY WIN+F11 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F11 , <{action}> )

#xcommand ON KEY WIN+F12 [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_WIN , VK_F12 , <{action}> )

#xcommand RELEASE KEY WIN+A OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_A   )

#xcommand RELEASE KEY WIN+B OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_B   )

#xcommand RELEASE KEY WIN+C OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_C   )

#xcommand RELEASE KEY WIN+D OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_D   )

#xcommand RELEASE KEY WIN+E OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_E   )

#xcommand RELEASE KEY WIN+F OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F   )

#xcommand RELEASE KEY WIN+G OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_G   )

#xcommand RELEASE KEY WIN+H OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_H   )

#xcommand RELEASE KEY WIN+I OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_I   )

#xcommand RELEASE KEY WIN+J OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_J   )

#xcommand RELEASE KEY WIN+K OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_K   )

#xcommand RELEASE KEY WIN+L OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_L   )

#xcommand RELEASE KEY WIN+M OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_M   )

#xcommand RELEASE KEY WIN+N OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_N   )

#xcommand RELEASE KEY WIN+O OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_O   )

#xcommand RELEASE KEY WIN+P OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_P   )

#xcommand RELEASE KEY WIN+Q OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_Q   )

#xcommand RELEASE KEY WIN+R OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_R   )

#xcommand RELEASE KEY WIN+S OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_S   )

#xcommand RELEASE KEY WIN+T OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_T   )

#xcommand RELEASE KEY WIN+U OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_U   )

#xcommand RELEASE KEY WIN+V OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_V   )

#xcommand RELEASE KEY WIN+W OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_W   )

#xcommand RELEASE KEY WIN+X OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_X   )

#xcommand RELEASE KEY WIN+Y OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_Y   )

#xcommand RELEASE KEY WIN+Z OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_Z   )

#xcommand RELEASE KEY WIN+0 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_0   )

#xcommand RELEASE KEY WIN+1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_1   )

#xcommand RELEASE KEY WIN+2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_2   )

#xcommand RELEASE KEY WIN+3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_3   )

#xcommand RELEASE KEY WIN+4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_4   )

#xcommand RELEASE KEY WIN+5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_5   )

#xcommand RELEASE KEY WIN+6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_6   )

#xcommand RELEASE KEY WIN+7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_7   )

#xcommand RELEASE KEY WIN+8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_8   )

#xcommand RELEASE KEY WIN+9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_9   )

#xcommand RELEASE KEY WIN+F1 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F1   )

#xcommand RELEASE KEY WIN+F2 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F2   )

#xcommand RELEASE KEY WIN+F3 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F3   )

#xcommand RELEASE KEY WIN+F4 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F4   )

#xcommand RELEASE KEY WIN+F5 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F5   )

#xcommand RELEASE KEY WIN+F6 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F6   )

#xcommand RELEASE KEY WIN+F7 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F7   )

#xcommand RELEASE KEY WIN+F8 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F8   )

#xcommand RELEASE KEY WIN+F9 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F9   )

#xcommand RELEASE KEY WIN+F10 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F10   )

#xcommand RELEASE KEY WIN+F11 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F11   )

#xcommand RELEASE KEY WIN+F12 OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_WIN , VK_F12   )

#xcommand STORE KEY WIN+A OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_A   )

#xcommand STORE KEY WIN+B OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_B   )

#xcommand STORE KEY WIN+C OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_C   )

#xcommand STORE KEY WIN+D OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_D   )

#xcommand STORE KEY WIN+E OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_E   )

#xcommand STORE KEY WIN+F OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F   )

#xcommand STORE KEY WIN+G OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_G   )

#xcommand STORE KEY WIN+H OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_H   )

#xcommand STORE KEY WIN+I OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_I   )

#xcommand STORE KEY WIN+J OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_J   )

#xcommand STORE KEY WIN+K OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_K   )

#xcommand STORE KEY WIN+L OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_L   )

#xcommand STORE KEY WIN+M OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_M   )

#xcommand STORE KEY WIN+N OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_N   )

#xcommand STORE KEY WIN+O OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_O   )

#xcommand STORE KEY WIN+P OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_P   )

#xcommand STORE KEY WIN+Q OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_Q   )

#xcommand STORE KEY WIN+R OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_R   )

#xcommand STORE KEY WIN+S OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_S   )

#xcommand STORE KEY WIN+T OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_T   )

#xcommand STORE KEY WIN+U OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_U   )

#xcommand STORE KEY WIN+V OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_V   )

#xcommand STORE KEY WIN+W OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_W   )

#xcommand STORE KEY WIN+X OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_X   )

#xcommand STORE KEY WIN+Y OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_Y   )

#xcommand STORE KEY WIN+Z OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_Z   )

#xcommand STORE KEY WIN+0 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_0   )

#xcommand STORE KEY WIN+1 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_1   )

#xcommand STORE KEY WIN+2 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_2   )

#xcommand STORE KEY WIN+3 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_3   )

#xcommand STORE KEY WIN+4 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_4   )

#xcommand STORE KEY WIN+5 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_5   )

#xcommand STORE KEY WIN+6 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_6   )

#xcommand STORE KEY WIN+7 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_7   )

#xcommand STORE KEY WIN+8 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_8   )

#xcommand STORE KEY WIN+9 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_9   )

#xcommand STORE KEY WIN+F1 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F1   )

#xcommand STORE KEY WIN+F2 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F2   )

#xcommand STORE KEY WIN+F3 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F3   )

#xcommand STORE KEY WIN+F4 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F4   )

#xcommand STORE KEY WIN+F5 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F5   )

#xcommand STORE KEY WIN+F6 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F6   )

#xcommand STORE KEY WIN+F7 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F7   )

#xcommand STORE KEY WIN+F8 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F8   )

#xcommand STORE KEY WIN+F9 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F9   )

#xcommand STORE KEY WIN+F10 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F10   )

#xcommand STORE KEY WIN+F11 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F11   )

#xcommand STORE KEY WIN+F12 OF <parent> TO <baction> ;
=> ;
<baction> := _GetHotKeyBlock ( <"parent"> , MOD_WIN , VK_F12   )

