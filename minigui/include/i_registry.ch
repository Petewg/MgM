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

#ifndef _REGISTRY_CH
#define _REGISTRY_CH


/* Predefined Keys */
// #define HKEY_CLASSES_ROOT         2147483648
// #define HKEY_CURRENT_USER         2147483649
// #define HKEY_LOCAL_MACHINE        2147483650
// #define HKEY_USERS                2147483651
// #define HKEY_PERFORMANCE_DATA     2147483652
// #define HKEY_CURRENT_CONFIG       2147483653
// #define HKEY_DYN_DATA             2147483654

/* Error Codes */
#define ERROR_SUCCESS                0
#define ERROR_FILE_NOT_FOUND         2
#define ERROR_ACCESS_DENIED          5
#define ERROR_OUTOFMEMORY           14
#define ERROR_NOT_SUPPORTED         50
#define ERROR_INVALID_PARAMETER     87
#define ERROR_LOCK_FAILED          167
#define ERROR_MORE_DATA            234
#define ERROR_NO_MORE_ITEMS        259
#define ERROR_BADDB               1009
#define ERROR_BADKEY              1010
#define ERROR_CANTOPEN            1011
#define ERROR_CANTREAD            1012
#define ERROR_CANTWRITE           1013
#define ERROR_REGISTRY_CORRUPT    1015
#define ERROR_REGISTRY_IO_FAILED  1016
#define ERROR_KEY_DELETED         1018

/* Security Masks */
// #define KEY_QUERY_VALUE             1
// #define KEY_SET_VALUE               2
// #define KEY_CREATE_SUB_KEY          4
// #define KEY_ENUMERATE_SUB_KEYS      8
// #define KEY_NOTIFY                 16
// #define KEY_CREATE_LINK            32
#define KEY_ALL                    63

/* Registery Information Type */
#define REG_NONE                    0 // No value type
// #define REG_SZ                      1 // nul terminated string
// #define REG_EXPAND_SZ               2 // nul terminated string with ref
// #define REG_BINARY                  3 // Free form binary
// #define REG_DWORD                   4 // 32-bit number
#define REG_DWORD_BIG_ENDIAN        5 // 32-bit number
#define REG_LINK                    6 // Symbolic Link
#define REG_MULTI_SZ                7 // Multiple strings
#define REG_RESOURCE_LIST           8 // Resource list in the resource map

/* disposition values */
#define REG_CREATED_NEW_KEY         1 // The key did not exist and was created
#define REG_OPENED_EXISTING_KEY     2 // The key existed and was only opened


#xcommand OPEN REGISTRY <oReg> KEY <hKey> ;
            SECTION <cKey> ;
            => ;
            <oReg>:=TReg32():Create(<hKey>,<cKey>)

#xcommand OPEN REGISTRY <oReg> KEY <hKey> ;
            SECTION <cKey> OLD ;
            => ;
            <oReg>:=TReg32():New(<hKey>,<cKey>)

#xcommand CREATE REGISTRY <oReg> KEY <hKey> ;
            SECTION <cKey> ;
            => ;
            <oReg>:=TReg32():Create(<hKey>,<cKey>)

#xcommand GET VALUE <uVar> ;
            [NAME <cVar> ];
            <of: OF, REGISTRY> <oReg> ;
            => ;
            <uVar> := <oReg>:Get(<cVar>,<uVar>)

#xcommand SET VALUE <cVar> ;
            <of: OF, REGISTRY> <oReg> ;
            [ TO <uVal> ] ;
            => ;
            <oReg>:Set(<cVar>,<uVal>)

#xcommand DELETE VALUE <cVar> ;
            <of: OF, REGISTRY> <oReg> ;
            => ;
            <oReg>:Delete(<cVar>)

#xcommand DELETE KEY <cKey> ;
            <of: OF, REGISTRY> <oReg> ;
            => ;
            <oReg>:KeyDelete(<cKey>)

#xcommand CLOSE REGISTRY <oReg> ;
            => ;
            <oReg>:Close()

#endif