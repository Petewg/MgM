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
/*
 * Author: P.Chornyj <myorg63@mail.ru>
 * revised for 16.10.
*/

#include "minigui.ch"

#ifdef __XHARBOUR__
#xcommand END SWITCH => END
#xcommand OTHERWISE  => DEFAULT
#endif

FUNCTION _SetWindowBKBrush( cWindow, lNoDelete, cBrushStyle, nHatch, aColor, xImage )

   LOCAL nIndex, hWnd, hOldBrush, hBrush := 0

   __defaultNIL( @lNoDelete, .F. )
   __defaultNIL( @cBrushStyle, "SOLID" )
   __defaultNIL( @nHatch, HS_VERTICAL )
   __defaultNIL( @aColor, { 255, 0, 255 } )
   __defaultNIL( @xImage, "MINIGUI_EDIT_DELETE" )

   nIndex := GetFormIndex ( cWindow )

   IF nIndex > 0
      hWnd := _HMG_aFormHandles[ nIndex ]

      SWITCH Left ( cBrushStyle, 1 )
      CASE "S"
         hBrush := CreateSolidBrush ( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] )
         EXIT

      CASE "H"
         hBrush := CreateHatchBrush ( nHatch, RGB( aColor[ 1 ], aColor[ 2 ], aColor[ 3 ] ) )
         EXIT

      CASE "P"
         hBrush := CreatePatternBrush ( xImage )
         EXIT

      OTHERWISE
         hBrush := GetWindowBrush ( hWnd )

      END SWITCH

      IF GetObjectType ( hBrush ) == 2  // OBJ_BRUSH
         hOldBrush := SetWindowBrush ( hWnd, hBrush )
         _HMG_aFormBrushHandle[nIndex ] := hBrush

         IF lNoDelete
            RETURN hOldBrush
         ELSE
            DELETE BRUSH hOldBrush
         ENDIF
      ENDIF
   ENDIF

RETURN hBrush
