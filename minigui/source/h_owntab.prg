/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2008 Walter Formigoni <walter.formigoni@uol.com.br>

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

#include "i_winuser.ch"
#include "minigui.ch"

#define DT_CENTER     1

*------------------------------------------------------------------------------*
FUNCTION OwnTabPaint ( lParam )
*------------------------------------------------------------------------------*
   LOCAL hDC, hBrush, hOldFont, hImage
   LOCAL aBkColor, aForeColor, aInactiveColor, aBmp, aMetr, aBtnRc
   LOCAL oldTextColor, oldBkMode, nTextColor, bkColor
   LOCAL i, nItemId, x1, y1, x2, y2, xp1, yp1, xp2, yp2
   LOCAL lSelected, lBigFsize, lBigFsize2

   hDC := GETOWNBTNDC( lParam )

   i := AScan( _HMG_aControlHandles, GETOWNBTNHANDLE( lParam ) )

   IF Empty( hDC ) .OR. i == 0
      RETURN( 1 )
   ENDIF

   nItemId    := GETOWNBTNITEMID( lParam ) + 1
   aBtnRc     := GETOWNBTNRECT( lParam )
   lSelected  := AND( GETOWNBTNSTATE( lParam ), ODS_SELECTED ) == ODS_SELECTED
   lBigFsize  := ( _HMG_aControlFontSize [i] > 12 )
   lBigFsize2 := ( _HMG_aControlFontSize [i] > 18 )

   _HMG_aControlMiscData1 [i] [1] := aBtnRc [4] - aBtnRc [2]  // store a bookmark height

   hOldFont     := SelectObject( hDC, _HMG_aControlFontHandle [i] )
   aMetr        := GetTextMetric( hDC )
   oldBkMode    := SetBkMode( hDC, TRANSPARENT )
   nTextColor   := GetSysColor( COLOR_BTNTEXT )
   oldTextColor := SetTextColor( hDC, GetRed( nTextColor ), GetGreen( nTextColor ), GetBlue( nTextColor ) )

   IF ISARRAY( _HMG_aControlMiscData2 [i] ) .AND. nItemId <= Len( _HMG_aControlMiscData2 [i] ) .AND. ;
      IsArrayRGB( _HMG_aControlMiscData2 [i] [nItemId] )
      aBkColor := _HMG_aControlMiscData2 [i] [nItemId]
   ELSE
      aBkColor := _HMG_aControlBkColor [i]
   ENDIF

   bkColor := RGB( aBkColor [1], aBkColor [2], aBkColor [3] )
   SetBkColor( hDC, bkColor )

   hBrush := CreateSolidBrush( aBkColor [1], aBkColor [2], aBkColor [3] )
   FillRect( hDC, aBtnRc [1], aBtnRc [2], aBtnRc [3], aBtnRc [4], hBrush )
   DeleteObject( hBrush )

   x1 := aBtnRc [1]
   y1 := Round( aBtnRc [4] / 2, 0 ) - ( aMetr [1] - 10 )
   x2 := aBtnRc [3] - 2
   y2 := y1 + aMetr [1]

   IF _HMG_aControlMiscData1 [i] [2]  // ImageFlag

      nItemId := Min( nItemId, Len( _HMG_aControlPicture [i] ) )
      hImage  := LoadBitmap( _HMG_aControlPicture [i] [nItemId] )
      aBmp    := GetBitmapSize( hImage )

      xp1 := 4
      xp2 := aBmp [1]
      yp2 := aBmp [2]
      yp1 := Round( aBtnRc [4] / 2 - yp2 / 2, 0 )
      x1  += 2 * xp1 + xp2

      IF _HMG_aControlMiscData1 [i] [4]  // Bottom Tab

         IF lSelected
            DrawGlyph( hDC, aBtnRc [1] + 2 * xp1, 2 * yp1 - iif( lBigFsize, 8, 5 ), xp2, 2 * yp2 - iif( lBigFsize, 8, 5 ), hImage, bkColor, .F., .F. )
         ELSE
            DrawGlyph( hDC, aBtnRc [1] + xp1, 2 * yp1 - iif( lBigFsize, 8, 5 ), xp2, 2 * yp2 - iif( lBigFsize, 8, 5 ), hImage, bkColor, .F., .F. )
         ENDIF

      ELSE

         IF lSelected
            DrawGlyph( hDC, aBtnRc [1] + 2 * xp1, yp1 - 2, xp2, yp2, hImage, bkColor, .F., .F. )
         ELSE
            DrawGlyph( hDC, aBtnRc [1] + xp1, yp1 + 2, xp2, yp2, hImage, bkColor, .F., .F. )
         ENDIF

      ENDIF

      DeleteObject( hImage )

   ENDIF

   IF lSelected

      IF _HMG_aControlMiscData1 [i] [5]  // HotTrack

         IF IsArrayRGB ( aForeColor := _HMG_aControlMiscData1 [i] [6] )
            SetTextColor( hDC, aForeColor [1], aForeColor [2], aForeColor [3] )
         ELSEIF bkColor == GetSysColor( COLOR_BTNFACE )
            SetTextColor( hDC, 0, 0, 128 )
         ELSE
            SetTextColor( hDC, 255, 255, 255 )
         ENDIF

      ENDIF

   ELSE

      IF IsArrayRGB ( aInactiveColor := _HMG_aControlMiscData1 [i] [7] )
         SetTextColor( hDC, aInactiveColor [1], aInactiveColor [2], aInactiveColor [3] )
      ENDIF

   ENDIF

   IF _HMG_aControlMiscData1 [i] [4]  // Bottom Tab

      IF lSelected
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, 2 * y1 - iif( lBigFsize2, -3, iif( lBigFsize, 6, 12 ) ), x2, 2 * y2 - iif( lBigFsize2, -3, iif( lBigFsize, 6, 12 ) ), DT_CENTER )
      ELSE
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, 2 * y1 - iif( lBigFsize2, -6, iif(lBigFsize, 2, 8 ) ), x2, 2 * y2 - iif( lBigFsize2, -6, iif( lBigFsize, 2, 8 ) ), DT_CENTER )
      ENDIF

   ELSE

      IF lSelected
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, y1 - iif( lBigFsize2, -5, iif( lBigFsize, 0, 4 ) ), x2, y2 - iif( lBigFsize2, -5, iif( lBigFsize, 0, 4 ) ), DT_CENTER )
      ELSE
         DrawText( hDC, _HMG_aControlCaption [i] [nItemId], x1, y1 + iif( lBigFsize2, 8, iif( lBigFsize, 4, 0 ) ), x2, y2 + iif( lBigFsize2, 8, iif( lBigFsize, 4, 0 ) ), DT_CENTER )
      ENDIF

   ENDIF

   SelectObject( hDC, hOldFont )
   SetBkMode( hDC, oldBkMode )
   SetTextColor( hDC, oldTextColor )

RETURN( 0 )
