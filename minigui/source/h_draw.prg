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

#include "minigui.ch"

*-----------------------------------------------------------------------------*
FUNCTION drawtextout( window, row, col, string, fontcolor, backcolor, fontname, fontsize, bold, italic, underline, strikeout, transparent, angle, once )
*-----------------------------------------------------------------------------*
   LOCAL i, FormHandle, FontHandle
   LOCAL torow, tocol

   IF hb_IsString( window )
      IF ( i := GetFormIndex( window ) ) > 0
         FormHandle := _HMG_aFormHandles [i]
      ENDIF
   ELSE
      FormHandle := window
   ENDIF

   IF IsWindowHandle( FormHandle ) .OR. ( GetObjectType( FormHandle ) == OBJ_DC )
      IF ( FontHandle := GetFontHandle( FontName ) ) != 0
         GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout, @angle )
      ENDIF

      __defaultNIL( @fontname, _HMG_DefaultFontName )
      __defaultNIL( @fontsize, _HMG_DefaultFontSize )
      hb_default( @backcolor, { 255, 255, 255 } )
      hb_default( @fontcolor, { 0, 0, 0 } )
      hb_default( @angle, 0 )
      hb_default( @once, .F. )

      torow := row + iif( transparent .OR. !Empty( angle ), 0, fontsize + 4 )
      tocol := col + ( Len( string ) - 1 ) * fontsize
      textdraw( formhandle, row, col, string, torow, tocol, fontcolor, backcolor, fontname, fontsize, bold, italic, underline, strikeout, transparent, angle )
      IF ! once
         AAdd ( _HMG_aFormGraphTasks [i], {|| textdraw( formhandle,row,col,string,torow,tocol,fontcolor,backcolor,fontname,fontsize,bold,italic,underline,strikeout,transparent,angle ) } )
      ENDIF
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION drawline( window, row, col, row1, col1, penrgb, penwidth )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]

      linedraw( formhandle, row, col, row1, col1, penrgb, penwidth )
      AAdd ( _HMG_aFormGraphTasks [i] , {|| linedraw( formhandle,row,col,row1,col1,penrgb,penwidth ) } )
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION drawrect( window, row, col, row1, col1, penrgb, penwidth, fillrgb )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle, fill

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]
      IF !( fill := ISARRAY( fillrgb ) )
         fillrgb := { 255, 255, 255 }
      ENDIF

      rectdraw( FormHandle, row, col, row1, col1, penrgb, penwidth, fillrgb, fill )
      AAdd ( _HMG_aFormGraphTasks [i] , {|| rectdraw( FormHandle,row,col,row1,col1,penrgb,penwidth,fillrgb,fill ) } )
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION drawroundrect( window, row, col, row1, col1, width, height, penrgb, penwidth, fillrgb )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle, fill

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]
      IF !( fill := ISARRAY( fillrgb ) )
         fillrgb := { 255, 255, 255 }
      ENDIF

      roundrectdraw( FormHandle, row, col, row1, col1, width, height, penrgb, penwidth, fillrgb, fill )
      AAdd ( _HMG_aFormGraphTasks [i] , {|| roundrectdraw( FormHandle,row,col,row1,col1,width,height,penrgb,penwidth,fillrgb,fill ) } )
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION drawellipse( window, row, col, row1, col1, penrgb, penwidth, fillrgb )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle, fill

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]
      IF !( fill := ISARRAY( fillrgb ) )
         fillrgb := { 255, 255, 255 }
      ENDIF

      ellipsedraw( FormHandle, row, col, row1, col1, penrgb, penwidth, fillrgb, fill )
      AAdd ( _HMG_aFormGraphTasks [i] , {|| ellipsedraw( FormHandle ,row,col,row1,col1,penrgb,penwidth,fillrgb,fill ) } )
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION drawarc( window, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]

      arcdraw( FormHandle, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth )
      AAdd ( _HMG_aFormGraphTasks [i] , {|| arcdraw( FormHandle ,row,col,row1,col1,rowr,colr,rowr1,colr1,penrgb,penwidth ) } )
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION drawpie( window, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle, fill

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]
      IF !( fill := ISARRAY( fillrgb ) )
         fillrgb := { 255, 255, 255 }
      ENDIF

      piedraw( FormHandle, row, col, row1, col1, rowr, colr, rowr1, colr1, penrgb, penwidth, fillrgb, fill )
      AAdd ( _HMG_aFormGraphTasks [i] , {|| piedraw( FormHandle,row,col,row1,col1,rowr,colr,rowr1,colr1,penrgb,penwidth,fillrgb,fill ) } )
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION drawpolygon( window, apoints, penrgb, penwidth, fillrgb )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle, fill
   LOCAL xarr := {}, yarr := {}

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]
      IF !( fill := ISARRAY( fillrgb ) )
         fillrgb := { 255, 255, 255 }
      ENDIF

      AEval( apoints, { | x | AAdd( yarr, x[1] ), AAdd( xarr, x[2] ) } )
      polygondraw( FormHandle, xarr, yarr, penrgb, penwidth, fillrgb, fill )
      AAdd( _HMG_aFormGraphTasks [i] , {|| polygondraw( FormHandle,xarr,yarr,penrgb,penwidth,fillrgb,fill ) } )
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION drawpolybezier( window, apoints, penrgb, penwidth )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle
   LOCAL xarr := {}, yarr := {}

   IF i > 0
      hb_default( @penrgb, { 0, 0, 0 } )
      hb_default( @penwidth, 1 )
      FormHandle := _HMG_aFormHandles [i]

      AEval( apoints, { | x | AAdd( yarr, x[1] ), AAdd( xarr, x[2] ) } )
      polybezierdraw( FormHandle, xarr, yarr, penrgb, penwidth )
      AAdd( _HMG_aFormGraphTasks [i] , {|| polybezierdraw( FormHandle,xarr,yarr,penrgb,penwidth ) } )
   ENDIF

RETURN nil

#define COLOR_BTNFACE	15
*-----------------------------------------------------------------------------*
FUNCTION HMG_DrawIcon( window, icon, row, col, w, h, rgb, transparent )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window ), backcolor
   LOCAL FormHandle

   IF i > 0
      hb_default( @w, 0 )
      hb_default( @h, 0 )
      hb_default( @transparent, .F. )
      IF transparent
         backcolor := _HMG_aFormBkColor [i]
         IF IsArrayRGB( backcolor )
            rgb := RGB( backcolor [1], backcolor [2], backcolor [3] )
         ENDIF
      ELSE
         IF IsArrayRGB( rgb )
            rgb := RGB( rgb [1], rgb [2], rgb [3] )
         ENDIF
      ENDIF
      hb_default( @rgb, GetSysColor( COLOR_BTNFACE ) )

      FormHandle := _HMG_aFormHandles [i]

      IF ISNUMERIC( icon )
         DrawIconEx( FormHandle, Col, Row, icon, w, h, rgb, .F. )
         AAdd( _HMG_aFormGraphTasks [i] , {|| DrawIconEx( FormHandle, Col, Row, icon, w, h, rgb, .F. ) } )
      ELSEIF ISSTRING( icon )
         DrawIconEx( FormHandle, Col, Row, LoadIconByName( icon, w, h ), w, h, rgb )
         AAdd( _HMG_aFormGraphTasks [i] , {|| DrawIconEx( FormHandle, Col, Row, LoadIconByName( icon, w, h ), w, h, rgb ) } )
      ENDIF
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION EraseWindow( window )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )

   IF i > 0
      IF _HMG_aFormDeleted [i] == .F.
         IF ISARRAY ( _HMG_aFormGraphTasks [i] )
            ASize ( _HMG_aFormGraphTasks [i], 0 )
            RedrawWindow ( _HMG_aFormHandles [i] )
         ENDIF
      ENDIF
   ENDIF

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION DrawWindowBoxIn( window, row, col, rowr, colr )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle := _HMG_aFormHandles [i]
   LOCAL hDC := GetDC( FormHandle )

   WndBoxIn( hDC, row, col, rowr, colr )
   ReleaseDC( FormHandle, hDC )
   AAdd( _HMG_aFormGraphTasks [i] , {|| WndBoxIn( ( hDC := GetDC( FormHandle ) ), row, col, rowr, colr ), ReleaseDC( FormHandle, hDC ) } )

RETURN nil

*-----------------------------------------------------------------------------*
FUNCTION DrawWindowBoxRaised( window, row, col, rowr, colr )
*-----------------------------------------------------------------------------*
   LOCAL i := GetFormIndex ( Window )
   LOCAL FormHandle := _HMG_aFormHandles [i]
   LOCAL hDC := GetDC( FormHandle )

   WndBoxRaised( hDC, row, col, rowr, colr )
   ReleaseDC( FormHandle, hDC )
   AAdd( _HMG_aFormGraphTasks [i] , {|| WndBoxRaised( ( hDC := GetDC( FormHandle ) ), row, col, rowr, colr ), ReleaseDC( FormHandle, hDC ) } )

RETURN nil
