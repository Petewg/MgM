/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 DEFINE BKGBRUSH definition
 (C) P.Chornyj <myorg63@mail.ru>
 HMG Extended Build 30

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

/* Brush Styles */
#define BS_SOLID            0
#define BS_NULL             1
#define BS_HOLLOW           BS_NULL
#define BS_HATCHED          2
#define BS_PATTERN          3

/* Hatch Styles */
#define HS_HORIZONTAL       0       /* ----- */
#define HS_VERTICAL         1       /* ||||| */
#define HS_FDIAGONAL        2       /* \\\\\ */
#define HS_BDIAGONAL        3       /* ///// */
#define HS_CROSS            4       /* +++++ */
#define HS_DIAGCROSS        5       /* xxxxx */

/* P.Ch. 16.10. */
#xtranslate <dummy: CREATE,DEFINE> <dummy1: BKBRUSH,BKGBRUSH> <brush> ;
       [ STYLE ] <style: SOLID,HATCHED,PATTERN> ;
       [ [ HATCHSTYLE ] <hatch> ] ;
       [ <dummy3: BITMAP,IMAGE,PICTURE> <bitmap> ] ;
       [ COLOR <aColor> ] ; 
       [ <nodelete: NODELETE> ] ; 
       [ IN [ <dummy2: FORM,WINDOW> ] <window> ] ;
   =>;
       <brush> := _SetWindowBKBrush( <(window)>, <.nodelete.>, <"style">, <hatch>, <aColor>, <(bitmap)> )

#xtranslate ADD <dummy1: BKBRUSH,BKGBRUSH> <brush> ;
       [ STYLE ] <style: SOLID,HATCHED,PATTERN> ;
       [ [ HATCHSTYLE ] <hatch> ] ;
       [ <dummy3: BITMAP,IMAGE,PICTURE> <bitmap> ] ;
       [ COLOR <aColor> ] ; 
       [ <nodelete: NODELETE> ] ;
       TO [ <dummy2: FORM,WINDOW> ] <window> ;
   =>;
       <brush> := _SetWindowBKBrush( <(window)>, <.nodelete.>, <"style">, <hatch>, <aColor>, <(bitmap)> )

#xtranslate DELETE BRUSH <brush> ;
   =>;
       DeleteObject( <brush> )
