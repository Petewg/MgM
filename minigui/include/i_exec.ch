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

#xcommand EXECUTE ;
    FILE <executable> ;
    [ DEFAULT <default> ] ;
    WAIT ;
    [ WHILE <while> ] ;
    [ INTERVAL <msec> ] ;
=> ;
WaitRunTerm ( <executable> , <default> , 5 , <{while}> , <msec> )

#xcommand EXECUTE ;
    FILE <executable> ;
    [ DEFAULT <default> ] ;
    WAIT ;
    [ WHILE <while> ] ;
    [ INTERVAL <msec> ] ;
    MAXIMIZE ;
=> ;
WaitRunTerm ( <executable> , <default> , 3 , <{while}> , <msec> )

#xcommand EXECUTE ;
    FILE <executable> ;
    [ DEFAULT <default> ] ;
    WAIT ;
    [ WHILE <while> ] ;
    [ INTERVAL <msec> ] ;
    MINIMIZE ;
=> ;
WaitRunTerm ( <executable> , <default> , 6 , <{while}> , <msec> )

#xcommand EXECUTE ;
    FILE <executable> ;
    [ DEFAULT <default> ] ;
    WAIT ;
    [ WHILE <while> ] ;
    [ INTERVAL <msec> ] ;
    HIDE ;
=> ;
WaitRunTerm ( <executable> , <default> , 0 , <{while}> , <msec> )


#xcommand EXECUTE ;
    [ OPERATION <operation> ] ;
    FILE <file> ;
    [ PARAMETERS <parameters> ] ;
    [ DEFAULT <default> ] ;
=> ;
_Execute ( , <operation> , <file> , <parameters> , <default> , 5 )

#xcommand EXECUTE ;
    [ OPERATION <operation> ] ;
    FILE <file> ;
    [ PARAMETERS <parameters> ] ;
    [ DEFAULT <default> ] ;
    MAXIMIZE ;
=> ;
_Execute ( , <operation> , <file> , <parameters> , <default> , 3 )

#xcommand EXECUTE ;
    [ OPERATION <operation> ] ;
    FILE <file> ;
    [ PARAMETERS <parameters> ] ;
    [ DEFAULT <default> ] ;
    MINIMIZE ;
=> ;
_Execute ( , <operation> , <file> , <parameters> , <default> , 6 )

#xcommand EXECUTE ;
    [ OPERATION <operation> ] ;
    FILE <file> ;
    [ PARAMETERS <parameters> ] ;
    [ DEFAULT <default> ] ;
    HIDE ;
=> ;
_Execute ( , <operation> , <file> , <parameters> , <default> , 0 )
