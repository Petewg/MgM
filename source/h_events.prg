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

#include "i_winuser.ch"
#include "minigui.ch"
#include "error.ch"

#ifdef _TSBROWSE_
   MEMVAR _TSB_aControlhWnd, _TSB_aControlObjects
#endif
#ifndef __XHARBOUR__
   /* FOR EACH hb_enumIndex() */
   #xtranslate hb_enumIndex( <!v!> ) => <v>:__enumIndex()
#endif
*-----------------------------------------------------------------------------*
FUNCTION Events ( hWnd, nMsg, wParam, lParam )
*-----------------------------------------------------------------------------*
   LOCAL i, z, x, lvc, k, aPos, maskstart, ts, r, a, oGet
   LOCAL ControlCount, mVar, TmpStr, Tmp, aCellData, nGridRowValue
   LOCAL NextControlHandle, NewPos, NewHPos, NewVPos
#ifdef _DBFBROWSE_
   LOCAL xs, xd, RecordCount, SkipCount, BackRec, BackArea, BrowseArea
   LOCAL nr, hws, hwm, DeltaSelect, aTemp, aTemp2, dBc, dFc
#endif
   LOCAL nDestinationColumn, nFrozenColumnCount, aOriginalColumnWidths
#ifdef _USERINIT_
   LOCAL cProc
#endif
   STATIC lOpaque := .F., IsInitMenuPopup := .F., lCellGridRowChanged := .F.
   STATIC IsXPThemed, nOldPage, SpaceKeyIsPressedInGrid := 0
#ifdef _TSBROWSE_
   oGet := GetObjectByHandle( hWnd )
   IF ISOBJECT( oGet )

      r := oGet:HandleEvent ( nMsg, wParam, lParam )

      IF ValType ( r ) == 'N'
         IF r != 0
            RETURN r
         ENDIF
      ENDIF
   ENDIF
#endif
#ifdef _USERINIT_
   FOR EACH cProc IN _HMG_aCustomEventProcedure

      r := &cProc ( hWnd , nMsg , wParam , lParam )

      IF ValType ( r ) <> 'U'
         RETURN r
      ENDIF

   NEXT
#endif

   SWITCH nMsg
   //**********************************************************************
   CASE WM_MEASUREITEM
   //**********************************************************************

      SWITCH GETMISCTLTYPE( lParam )

      CASE ODT_MENU
         _OnMeasureMenuItem( hWnd, nMsg, wParam, lParam )
         EXIT
      CASE ODT_LISTBOX
         _OnMeasureListBoxItem( lParam )

      END SWITCH
      EXIT
   //**********************************************************************
   CASE WM_DRAWITEM
   //**********************************************************************

      i := AScan ( _HMG_aFormHandles, hWnd )
      ts := ( i > 0 .AND. _IsControlDefined( "StatusBar", _HMG_aFormNames [i] ) )

      SWITCH GETOWNBTNCTLTYPE( lParam )

      CASE ODT_MENU
         IF ts .AND. GetDrawItemHandle( lParam ) == GetControlHandle( "StatusBar", _HMG_aFormNames [i] )
            _OnDrawStatusItem( hWnd, lParam )
            RETURN 0
         ELSE
            _OnDrawMenuItem( lParam )
            RETURN 0
         ENDIF
      CASE ODT_LISTBOX
         _OnDrawListBoxItem( lParam )
         RETURN 0
      CASE ODT_BUTTON
         RETURN ( OwnButtonPaint( lParam ) )
      CASE ODT_TAB
         RETURN ( OwnTabPaint( lParam ) )

      END SWITCH

      IF ts
         _OnDrawStatusItem( hWnd, lParam )
      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_CTLCOLORSTATIC
   //**********************************************************************

      i := AScan ( _HMG_aControlHandles , lParam )

      IF i > 0

         TmpStr := _HMG_aControlType [i]

         IF TmpStr $ "GETBOX,LABEL,HYPERLINK,CHECKBOX,FRAME,SLIDER,NUMTEXT,MASKEDTEXT,CHARMASKTEXT,BTNTEXT,BTNNUMTEXT,EDIT,CHECKLABEL"

            IF TmpStr $ "GETBOX,NUMTEXT,MASKEDTEXT,CHARMASKTEXT,BTNTEXT,BTNNUMTEXT,EDIT"

               IF IsWindowEnabled( _HMG_aControlHandles [i] )

                  IF _HMG_aControlFontColor [i] != Nil

                     IF ValType( _HMG_aControlFontColor [ i, 2 ] ) == "A" .AND. Len( _HMG_aControlFontColor [ i, 2 ] ) == 3
                        SetTextColor( wParam, _HMG_aControlFontColor [ i, 2, 1 ], _HMG_aControlFontColor [ i, 2, 2 ], _HMG_aControlFontColor [ i, 2, 3 ] )
                     ELSEIF ValType( _HMG_aControlFontColor [ i, 2 ] ) == "N" .AND. Len( _HMG_aControlFontColor [ i ] ) == 3
                        SetTextColor( wParam, _HMG_aControlFontColor [ i, 1 ], _HMG_aControlFontColor [ i, 2 ], _HMG_aControlFontColor [ i ,3 ] )
                     ENDIF

                  ENDIF

                  IF _HMG_aControlBkColor [i] != Nil

                     IF ValType( _HMG_aControlBkColor [ i, 2 ] ) == "A" .AND. Len( _HMG_aControlBkColor [ i, 2 ] ) == 3

                        SetBkColor( wParam , _HMG_aControlBkColor [ i, 2, 1 ] , _HMG_aControlBkColor [ i, 2, 2 ] , _HMG_aControlBkColor [ i, 2, 3 ] )
                        DeleteObject ( _HMG_aControlBrushHandle [ i ] )
                        _HMG_aControlBrushHandle [ i ] := CreateSolidBrush( _HMG_aControlBkColor [ i, 2, 1 ] , _HMG_aControlBkColor [ i, 2, 2 ] , _HMG_aControlBkColor [ i, 2, 3 ] )
                        RETURN ( _HMG_aControlBrushHandle [i] )

                     ELSE

                        IF ValType( _HMG_aControlBkColor [ i, 2] ) == "N" .AND. Len( _HMG_aControlBkColor [ i ] ) == 3
                           SetBkColor( wParam , _HMG_aControlBkColor [ i, 1 ] , _HMG_aControlBkColor [ i, 2 ] , _HMG_aControlBkColor [ i, 3 ] )
                           DeleteObject ( _HMG_aControlBrushHandle [ i ] )
                           _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [ i, 1 ] , _HMG_aControlBkColor [ i, 2 ] , _HMG_aControlBkColor [ i, 3 ] )
                           RETURN _HMG_aControlBrushHandle [i]
                        ENDIF

                     ENDIF

                  ELSE

                     a := nRGB2Arr ( GetSysColor ( COLOR_3DFACE ) )
                     SetBkColor( wParam , a [1] , a [2] , a [3] )
                     DeleteObject ( _HMG_aControlBrushHandle [i] )
                     _HMG_aControlBrushHandle [i] := CreateSolidBrush( a [1] , a [2] , a [3] )
                     RETURN _HMG_aControlBrushHandle [i]

                  ENDIF

               ENDIF

            ELSE

               IF IsXPThemed == Nil
                  IsXPThemed := IsThemed()
               ENDIF

               Tmp := _HMG_aControlContainerRow [i] <> -1 .AND. _HMG_aControlContainerCol [i] <> -1 .AND. _HMG_aControlBkColor [i] == Nil

               IF IsXPThemed .AND. TmpStr == "SLIDER" .AND. Tmp

                  IF ( a := _GetBackColor ( _HMG_aControlFontHandle [i], _HMG_aControlMiscData1 [i] ) ) != Nil
                     _HMG_aControlBkColor [i] := a
                  ELSE
                     IF _HMG_aControlDblClick [i] == .F. .AND. !lOpaque
                        r := GetControlIndex( _HMG_aControlFontHandle [i], _HMG_aControlMiscData1 [i] )
                        DeleteObject ( _HMG_aControlBrushHandle [r] )
                        z := GetControlHandle( _HMG_aControlFontHandle [i], _HMG_aControlMiscData1 [i] )
                        _HMG_aControlBrushHandle [r] := GetTabBrush( z )
                        RETURN GetTabbedControlBrush ( wParam , lParam , z , _HMG_aControlBrushHandle [r] )
                     ENDIF
                  ENDIF

               ENDIF

               IF IsXPThemed .AND. TmpStr == "FRAME" .AND. Tmp

                  IF _HMG_aControlDblClick [i] == .F.
                     r := GetControlIndex( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] )
                     DeleteObject ( _HMG_aControlBrushHandle [r] )
                     z := GetControlHandle( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] )
                     _HMG_aControlBrushHandle [r] := GetTabBrush( z )
                     RETURN GetTabbedControlBrush ( wParam , lParam , z , _HMG_aControlBrushHandle [r] )
                  ELSE
                     lOpaque := .T.
                  ENDIF

               ENDIF

               IF IsXPThemed .AND. TmpStr == "CHECKBOX" .AND. Tmp

                  IF ( a := _GetBackColor ( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] ) ) != Nil
                     IF ISLOGICAL ( _HMG_aControlInputMask [i] ) .AND. _HMG_aControlInputMask [i] == .F.
                        SetBkColor( wParam , a [1] , a [2] , a [3] )
                        DeleteObject ( _HMG_aControlBrushHandle [i] )
                        _HMG_aControlBrushHandle [i] := CreateSolidBrush( a [1] , a [2] , a [3] )
                        RETURN _HMG_aControlBrushHandle [i]
                     ENDIF
                  ELSE
                     IF _HMG_aControlDblClick [i] == .F. .AND. !lOpaque
                        r := GetControlIndex( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] )
                        DeleteObject ( _HMG_aControlBrushHandle [r] )
                        z := GetControlHandle( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] )
                        _HMG_aControlBrushHandle [r] := GetTabBrush( z )
                        RETURN GetTabbedControlBrush ( wParam , lParam , z , _HMG_aControlBrushHandle [r] )
                     ENDIF
                  ENDIF

               ENDIF

               IF _HMG_aControlFontColor [i] != Nil
                  SetTextColor( wParam , _HMG_aControlFontColor [i] [1] , _HMG_aControlFontColor [i] [2] , _HMG_aControlFontColor [i] [3] )
               ENDIF

               IF ISLOGICAL ( _HMG_aControlInputMask [i] )
                  IF _HMG_aControlInputMask [i] == .T.
                     SetBkMode( wParam , TRANSPARENT )
                     RETURN GetStockObject ( NULL_BRUSH )
                  ENDIF
               ENDIF

               IF IsXPThemed .AND. TmpStr == 'LABEL' .AND. Tmp

                  IF ( a := _GetBackColor ( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] ) ) == Nil
                     IF _HMG_aControlDblClick [i] == .T.
                        a := nRGB2Arr ( GetSysColor ( COLOR_BTNFACE ) )
                     ELSEIF ( r := GetControlIndex( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] ) ) > 0
                        DeleteObject ( _HMG_aControlBrushHandle [r] )
                        z := GetControlHandle( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] )
                        _HMG_aControlBrushHandle [r] := GetTabBrush( z )
                        RETURN GetTabbedControlBrush ( wParam , lParam , z , _HMG_aControlBrushHandle [r] )
                     ELSE
                        a := _HMG_ActiveTabColor [1]
                     ENDIF
                  ENDIF
                  IF ISARRAY( a )
                     SetBkColor( wParam , a [1] , a [2] , a [3] )
                     DeleteObject ( _HMG_aControlBrushHandle [i] )
                     _HMG_aControlBrushHandle [i] := CreateSolidBrush( a [1] , a [2] , a [3] )
                     RETURN _HMG_aControlBrushHandle [i]
                  ENDIF

               ENDIF

               IF _HMG_aControlBkColor [i] != Nil
                  SetBkColor( wParam , _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                  DeleteObject ( _HMG_aControlBrushHandle [i] )
                  _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                  RETURN _HMG_aControlBrushHandle [i]
               ELSE
                  a := nRGB2Arr ( GetSysColor ( COLOR_3DFACE ) )
                  SetBkColor( wParam , a [1] , a [2] , a [3] )
                  DeleteObject ( _HMG_aControlBrushHandle [i] )
                  _HMG_aControlBrushHandle [i] := CreateSolidBrush( a [1] , a [2] , a [3] )
                  RETURN _HMG_aControlBrushHandle [i]
               ENDIF

            ENDIF

         ENDIF

      ELSE

         FOR i := 1 TO Len ( _HMG_aControlhandles )

            IF ValType ( _HMG_aControlHandles [i] ) == 'A'

               IF _HMG_aControlType [i] == 'RADIOGROUP'

                  FOR x := 1 TO Len ( _HMG_aControlHandles [i] )

                     IF _HMG_aControlHandles [i] [x] == lParam

                        IF _HMG_aControlFontColor [i] != Nil
                           SetTextColor( wParam , _HMG_aControlFontColor [i] [1] , _HMG_aControlFontColor [i] [2] , _HMG_aControlFontColor [i] [3] )
                        ENDIF

                        IF IsXPThemed == Nil
                           IsXPThemed := IsThemed()
                        ENDIF

                        IF IsXPThemed .AND. _HMG_aControlContainerRow [i] <> -1 .AND. _HMG_aControlContainerCol [i] <> -1

                           IF ( a := _GetBackColor ( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] ) ) != Nil
                              IF ISLOGICAL ( _HMG_aControlInputMask [i] ) .AND. _HMG_aControlInputMask [i] == .T.
                                 _HMG_aControlBkColor [i] := a
                              ENDIF
                           ELSE
                              IF _HMG_aControlDblClick [i] == .F. .AND. !lOpaque .AND. _HMG_aControlBkColor [i] == Nil
                                 r := GetControlIndex( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] )
                                 DeleteObject ( _HMG_aControlBrushHandle [r] )
                                 z := GetControlHandle( _HMG_aControlRangeMin [i], _HMG_aControlRangeMax [i] )
                                 _HMG_aControlBrushHandle [r] := GetTabBrush( z )
                                 RETURN GetTabbedControlBrush ( wParam , lParam , z , _HMG_aControlBrushHandle [r] )
                              ENDIF
                           ENDIF

                        ENDIF

                        IF ValType ( _HMG_aControlInputMask [i] ) == 'L'
                           IF _HMG_aControlInputMask [i] == .T. .AND. _HMG_aControlBkColor [i] == Nil
                              SetBkMode( wParam , TRANSPARENT )
                              RETURN GetStockObject( NULL_BRUSH )
                           ENDIF
                        ENDIF

                        IF _HMG_aControlBkColor [i] != Nil
                           SetBkColor( wParam , _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                           IF x == 1
                              DeleteObject ( _HMG_aControlBrushHandle [i] )
                              _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                           ENDIF
                           RETURN _HMG_aControlBrushHandle [i]
                        ELSE
                           IF x == 1
                              DeleteObject ( _HMG_aControlBrushHandle [i] )
                              _HMG_aControlBrushHandle [i] := CreateSolidBrush( GetRed ( GetSysColor ( COLOR_3DFACE ) ) , GetGreen ( GetSysColor ( COLOR_3DFACE ) ) , GetBlue ( GetSysColor ( COLOR_3DFACE ) ) )
                           ENDIF
                           SetBkColor( wParam , GetRed ( GetSysColor ( COLOR_3DFACE ) ) , GetGreen ( GetSysColor ( COLOR_3DFACE ) ) , GetBlue ( GetSysColor ( COLOR_3DFACE ) ) )
                           RETURN _HMG_aControlBrushHandle [i]
                        ENDIF

                     ENDIF

                  NEXT x

               ENDIF

            ENDIF

         NEXT i

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_CTLCOLOREDIT
   CASE WM_CTLCOLORLISTBOX
   //**********************************************************************

      i := AScan ( _HMG_aControlHandles , lParam )

      IF i > 0

         TmpStr := _HMG_aControlType [i]

         IF TmpStr $ "GETBOX,NUMTEXT,MASKEDTEXT,CHARMASKTEXT,EDIT,BTNTEXT,BTNNUMTEXT,MULTILIST,COMBO"

            IF _HMG_aControlFontColor [i] != Nil

               IF ValType( _HMG_aControlFontColor [i,1] ) == "N"
                  SetTextColor( wParam, _HMG_aControlFontColor [i] [1], _HMG_aControlFontColor [i] [2] , _HMG_aControlFontColor [i] [3] )

               ELSEIF ValType( _HMG_aControlFontColor [i,1] ) == "A"

                  IF Len( _HMG_aControlFontColor [i] ) > 2 .AND. GetFocus() == _HMG_aControlHandles [i]
                     SetTextColor( wParam, _HMG_aControlFontColor [i, 3, 1], _HMG_aControlFontColor [i, 3, 2] , _HMG_aControlFontColor [i, 3, 3] )
                  ELSE
                     SetTextColor( wParam, _HMG_aControlFontColor [i, 1, 1], _HMG_aControlFontColor [i, 1, 2] , _HMG_aControlFontColor [i, 1, 3] )
                  ENDIF

               ENDIF

               IF _HMG_aControlBkColor [i] == Nil
                  a := nRGB2Arr ( GetSysColor ( COLOR_WINDOW ) )
                  SetBkColor( wParam , a [1] , a [2] , a [3] )
                  DeleteObject ( _HMG_aControlBrushHandle [i] )
                  _HMG_aControlBrushHandle [i] := CreateSolidBrush( a [1] , a [2] , a [3] )
                  RETURN _HMG_aControlBrushHandle [i]
               ENDIF

            ENDIF

            IF _HMG_aControlBkColor [i] != Nil

               IF ValType( _HMG_aControlBkColor [i,1] ) == "N"

                  SetBkColor( wParam, _HMG_aControlBkColor [i] [1], _HMG_aControlBkColor [i] [2], _HMG_aControlBkColor [i] [3] )
                  DeleteObject ( _HMG_aControlBrushHandle [i] )
                  _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [i] [1], _HMG_aControlBkColor [i] [2], _HMG_aControlBkColor [i] [3] )
                  RETURN ( _HMG_aControlBrushHandle [i] )

               ELSE

                  IF ValType( _HMG_aControlBkColor [i,1] ) == "A"

                     IF Len( _HMG_aControlBkColor[i] ) == 3 .AND. GetFocus() == _HMG_aControlHandles [i]
                        SetBkColor( wParam, _HMG_aControlBkColor [i, 3, 1], _HMG_aControlBkColor [i, 3, 2], _HMG_aControlBkColor [i, 3, 3] )
                        DeleteObject ( _HMG_aControlBrushHandle [i] )
                        _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [i, 3, 1], _HMG_aControlBkColor [i, 3, 2], _HMG_aControlBkColor [i, 3, 3] )
                        RETURN ( _HMG_aControlBrushHandle [i] )
                     ELSE
                        SetBkColor( wParam, _HMG_aControlBkColor [i, 1, 1], _HMG_aControlBkColor [i, 1, 2], _HMG_aControlBkColor [i, 1, 3] )
                        DeleteObject ( _HMG_aControlBrushHandle [i] )
                        _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [i, 1, 1], _HMG_aControlBkColor [i, 1, 2], _HMG_aControlBkColor [i, 1, 3] )
                        RETURN _HMG_aControlBrushHandle [i]
                     ENDIF

                  ENDIF

               ENDIF

            ENDIF

         ENDIF

      ELSE

         ControlCount := Len ( _HMG_aControlHandles )
         FOR i := 1 TO ControlCount

            IF ValType ( _HMG_aControlHandles [i] ) == 'A'

               IF _HMG_aControlType [i] == 'SPINNER'

                  IF _HMG_aControlHandles [i] [1] == lParam

                     IF _HMG_aControlFontColor [i] != Nil
                        SetTextColor( wParam , _HMG_aControlFontColor [i] [1] , _HMG_aControlFontColor [i] [2] , _HMG_aControlFontColor [i] [3] )
                        IF _HMG_aControlBkColor [i] == Nil
                           a := nRGB2Arr ( GetSysColor ( COLOR_WINDOW ) )
                           SetBkColor( wParam , a [1] , a [2] , a [3] )
                           DeleteObject ( _HMG_aControlBrushHandle [i] )
                           _HMG_aControlBrushHandle [ i ] := CreateSolidBrush( a [1] , a [2] , a [3] )
                           RETURN _HMG_aControlBrushHandle [i]
                        ENDIF
                     ENDIF

                     IF _HMG_aControlBkColor [i] != Nil
                        SetBkColor( wParam , _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                        DeleteObject ( _HMG_aControlBrushHandle [i] )
                        _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                        RETURN _HMG_aControlBrushHandle [i]
                     ENDIF

                  ENDIF

               ENDIF

            ENDIF

            IF _HMG_aControlType [i] == "COMBO"

               IF _HMG_aControlMiscData1 [i] [2] == .T. .AND. ( GetFocus() == _HMG_aControlRangeMin [i] .OR. _HMG_aControlRangeMin [i] == lParam ) .OR. ;
                  GetFocus() == _HMG_aControlHandles [i] .AND. ( _HMG_aControlHandles [i] == lParam .OR. _HMG_aControlMiscData1 [i] [2] == .F. )

                  IF _HMG_aControlFontColor [i] != Nil
                     SetTextColor( wParam , _HMG_aControlFontColor [i] [1] , _HMG_aControlFontColor [i] [2] , _HMG_aControlFontColor [i] [3] )
                     IF _HMG_aControlBkColor [i] == Nil
                        a := nRGB2Arr ( GetSysColor ( COLOR_WINDOW ) )
                        SetBkColor( wParam , a [1] , a [2] , a [3] )
                        DeleteObject ( _HMG_aControlBrushHandle [i] )
                        _HMG_aControlBrushHandle [ i ] := CreateSolidBrush( a [1] , a [2] , a [3] )
                        RETURN _HMG_aControlBrushHandle [i]
                     ENDIF
                  ENDIF

                  IF _HMG_aControlBkColor [i] != Nil
                     IF _HMG_aControlRangeMin [i] == lParam
                        SetBkColor( lParam , _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                     ENDIF
                     SetBkColor( wParam , _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                     DeleteObject ( _HMG_aControlBrushHandle [i] )
                     _HMG_aControlBrushHandle [i] := CreateSolidBrush( _HMG_aControlBkColor [i] [1] , _HMG_aControlBkColor [i] [2] , _HMG_aControlBkColor [i] [3] )
                     RETURN _HMG_aControlBrushHandle [i]
                  ENDIF

               ENDIF

            ENDIF

         NEXT i

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_MENUSELECT
   //**********************************************************************

      IF AND( HIWORD( wParam ), MF_HILITE ) <> 0

         i := AScan ( _HMG_aControlIds, LOWORD( wParam ) )  // LOWORD(wParam) = menu id

         IF i > 0

            IF ( x := AScan ( _HMG_aFormHandles, _HMG_aControlParentHandles [i] ) ) > 0
               IF _IsControlDefined ( "StatusBar", _HMG_aFormNames [x] )
                  IF _HMG_aControlValue [i] # Nil
                     SetProperty( _HMG_aFormNames [x], "StatusBar", "Item", 1, _HMG_aControlValue [i] )
                  ELSEIF ISCHARACTER ( _HMG_DefaultStatusBarMessage )
                     SetProperty( _HMG_aFormNames [x], "StatusBar", "Item", 1, _HMG_DefaultStatusBarMessage )
                  ENDIF
               ENDIF
            ENDIF

         ELSEIF ( x := AScan ( _HMG_aFormHandles, hWnd ) ) > 0
            IF _IsControlDefined ( "StatusBar", _HMG_aFormNames [x] )
               IF ISCHARACTER ( _HMG_DefaultStatusBarMessage )
                  SetProperty ( _HMG_aFormNames [x], "StatusBar", "Item", 1, _HMG_DefaultStatusBarMessage )
               ENDIF
            ENDIF

         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_MENUCHAR
   //**********************************************************************

      IF IsExtendedMenuStyleActive()

         x := Chr( LOWORD( wParam ) )  // LOWORD(wParam) = pressed char code
         IF ( i := AScan( GetMenuItems ( ( HIWORD( wParam ) == MF_POPUP ), lParam ), {|r| "&" + Upper( x ) $ Upper( r ) } ) ) > 0
            RETURN MAKELRESULT( i - 1, MNC_EXECUTE )
         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_INITMENUPOPUP
   //**********************************************************************
      IsInitMenuPopup := .T.
      EXIT
   //**********************************************************************
   CASE WM_UNINITMENUPOPUP
   //**********************************************************************
      IsInitMenuPopup := .F.
      EXIT
   //**********************************************************************
   CASE WM_HOTKEY
   //**********************************************************************

      // Process HotKeys

      i := AScan ( _HMG_aControlIds , wParam )

      IF i > 0
         IF _HMG_aControlType [i] == "HOTKEY"
            IF _HMG_aControlValue [i] == VK_ESCAPE .AND. IsInitMenuPopup == .T.
               _CloseMenu()
               RETURN 0
            ENDIF
            //JP MDI HotKey
            IF _HMG_BeginWindowMDIActive
               IF _HMG_aControlParentHandles [i] == GetActiveMdiHandle() .OR. _HMG_InplaceParentHandle <> 0
                  IF _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
                     RETURN 0
                  ENDIF
               ELSEIF _HMG_aControlParentHandles [i] == GetActiveWindow() .OR. _HMG_GlobalHotkeys
                  IF _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
                     RETURN 0
                  ENDIF
               ENDIF
            //End JP
            ELSE
               IF _HMG_aControlParentHandles [i] == GetForegroundWindow() .OR. _HMG_GlobalHotkeys
                  IF _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
                     RETURN 0
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_MOUSEWHEEL
   //**********************************************************************

      hwnd := 0

      IF ! _HMG_AutoAdjust

         i := AScan ( _HMG_aFormHandles , GetFocus() )

         IF i > 0

            IF _HMG_aFormVirtualHeight [i] > 0
               hwnd := _HMG_aFormHandles [i]
            ENDIF

         ELSE

            IF ( i := AScan ( _HMG_aControlHandles , GetFocus() ) ) > 0

               x := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [i] )

               IF x > 0
                  IF _HMG_aFormVirtualHeight [x] > 0
                     hwnd := _HMG_aFormHandles [x]
                  ENDIF
               ENDIF

            ELSE

               ControlCount := Len ( _HMG_aControlHandles )
               FOR i := 1 TO ControlCount

                  IF _HMG_aControlType [i] == 'RADIOGROUP'

                     IF AScan ( _HMG_aControlHandles [i] , GetFocus() ) > 0

                        z := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [i] )
                        IF z > 0
                           IF _HMG_aFormVirtualHeight [z] > 0
                              hwnd := _HMG_aFormHandles [z]
                              EXIT
                           ENDIF
                        ENDIF

                     ENDIF

                  ENDIF

               NEXT i

            ENDIF

         ENDIF

      ENDIF

      IF hwnd != 0

         IF HIWORD( wParam ) == WHEEL_DELTA
            IF GetScrollPos( hwnd , SB_VERT ) < 25
               SendMessage ( hwnd , WM_VSCROLL , SB_TOP , 0 )
            ELSE
               SendMessage ( hwnd , WM_VSCROLL , SB_PAGEUP , 0 )
            ENDIF
         ELSE
            IF GetScrollPos( hwnd , SB_VERT ) >= GetScrollRangeMax ( hwnd , SB_VERT ) - 10
               SendMessage ( hwnd , WM_VSCROLL , SB_BOTTOM , 0 )
            ELSE
               SendMessage ( hwnd , WM_VSCROLL , SB_PAGEDOWN , 0 )
            ENDIF
         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_CREATE
   //**********************************************************************

      IF _HMG_BeginWindowMDIActive .AND. _HMG_MainClientMDIHandle == 0
         _HMG_MainClientMDIHandle := InitMDIClientWindow( hWnd )
      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_ACTIVATE
   //**********************************************************************

      i := AScan ( _HMG_aFormhandles , hWnd )

      IF i > 0

         IF LoWord( wparam ) == 0

            IF ! _HMG_GlobalHotkeys

               FOR EACH r IN _HMG_aControlType
                  IF r == 'HOTKEY'
                     x := hb_enumindex( r )
                     ReleaseHotKey ( _HMG_aControlParentHandles [x] , _HMG_aControlIds [x] )
                  ENDIF
               NEXT

            ENDIF

            _HMG_aFormFocusedControl [i] := GetFocus()

            _DoWindowEventProcedure ( _HMG_aFormLostFocusProcedure [i] , i , 'WINDOW_LOSTFOCUS' )

         ELSE

            UpdateWindow ( hWnd )

         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_SETFOCUS
   //**********************************************************************

      i := AScan ( _HMG_aFormHandles , hWnd )

      IF i > 0

         IF _HMG_aFormActive [i] == .T. .AND. _HMG_aFormType [i] != 'X'
            _HMG_UserWindowHandle := hWnd
         ENDIF

         ControlCount := Len ( _HMG_aControlHandles )

         FOR x := 1 TO ControlCount
            //JP MDI HotKey
            IF _HMG_aControlType [x] == 'HOTKEY'
               IF .NOT. _HMG_BeginWindowMDIActive
                  ReleaseHotKey ( _HMG_aControlParentHandles [x] , _HMG_aControlIds [x] )
               ELSEIF _HMG_aControlParentHandles [x] != GetFormHandle( _HMG_MainClientMDIName ) .OR. _HMG_InplaceParentHandle <> 0
                  ReleaseHotKey ( _HMG_aControlParentHandles [x] , _HMG_aControlIds [x] )
               ENDIF
            ENDIF
            //End
         NEXT x

         FOR x := 1 TO ControlCount
            IF _HMG_aControlType [x] == 'HOTKEY'
               IF _HMG_aControlParentHandles [x] == hWnd
                  InitHotKey ( hWnd , _HMG_aControlPageMap [x] , _HMG_aControlValue [x] , _HMG_aControlIds [x] )
               ENDIF
            ENDIF
         NEXT x

         _DoWindowEventProcedure ( _HMG_aFormGotFocusProcedure [i] , i , 'WINDOW_GOTFOCUS' )

         IF _HMG_IsModalActive .AND. Empty ( _HMG_InplaceParentHandle ) .AND. ;
            ( _HMG_aFormVirtualWidth [i] == 0 .OR. _HMG_aFormVirtualHeight [i] == 0 ) .AND. ;
            _HMG_SplitLastControl != "TOOLBAR"
            IF iswinnt() .OR. _HMG_aFormType [i] != 'M'
               BringWindowToTop ( _HMG_ActiveModalHandle )
            ENDIF
            IF iswinnt() .AND. _HMG_aFormType [i] != 'M'
               // Form's caption blinking if a top window is not Modal window
               FlashWindowEx ( _HMG_ActiveModalHandle , 1 , 5 , 60 )
            ENDIF
         ENDIF

         IF _HMG_aFormFocusedControl [i] != 0
            setfocus ( _HMG_aFormFocusedControl [i] )
         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_HELP
   //**********************************************************************

      i := AScan ( _HMG_aControlHandles , GetHelpData ( lParam ) )

      IF i > 0

         IF Right( AllTrim( Upper( _HMG_ActiveHelpFile ) ) , 4 ) == '.CHM'

            _HMG_nTopic := _HMG_aControlHelpId [i]

            _Execute( hWnd , "open" , "hh.exe" , ;
               iif( ValType( _HMG_nTopic ) == "C", '"' + _HMG_ActiveHelpFile + '::/' + AllTrim( _HMG_nTopic ) + '"', ;
               iif( ValType( _HMG_nTopic ) == "N" .AND. _HMG_nTopic > 0, '-mapid ' + hb_ntos( _HMG_nTopic ) + ' ' + ;
               _HMG_ActiveHelpFile, '"' + _HMG_ActiveHelpFile + '"' ) ) , , SW_SHOW )

         ELSE

            WinHelp ( hWnd , _HMG_ActiveHelpFile , 2 , _HMG_aControlHelpId [i] )

         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_GETMINMAXINFO
   //**********************************************************************

      RETURN _OnGetMinMaxInfo ( hWnd, lParam )
   //**********************************************************************
   CASE WM_VSCROLL
   //**********************************************************************

      i := AScan ( _HMG_aFormHandles , hWnd )

      IF i > 0

         // Vertical ScrollBar Processing

         IF _HMG_aFormVirtualHeight [i] > 0 .AND. lParam == 0

            IF _HMG_aFormRebarhandle [i] > 0
               MsgMiniGuiError( "SplitBox's Parent Window cannot be a 'Virtual Dimensioned' window (use 'Virtual Dimensioned' SplitChild instead)." )
            ENDIF

            z := iif( _HMG_aScrollStep [1] > 0, _HMG_aScrollStep [1], GetScrollRangeMax ( hwnd , SB_VERT ) / _HMG_aScrollStep [2] )

            IF LoWord( wParam ) == SB_LINEDOWN

               NewPos := GetScrollPos( hwnd, SB_VERT ) + z
               IF NewPos >= GetScrollRangeMax( hwnd, SB_VERT ) - 10
                  NewPos := GetScrollRangeMax( hwnd, SB_VERT )
               ENDIF
               SetScrollPos ( hwnd , SB_VERT , NewPos , .T. )

            ELSEIF LoWord( wParam ) == SB_LINEUP

               NewPos := GetScrollPos( hwnd, SB_VERT ) - z
               IF NewPos < 10
                  NewPos := 0
               ENDIF
               SetScrollPos ( hwnd , SB_VERT , NewPos , .T. )

            ELSEIF LoWord( wParam ) == SB_TOP

               NewPos := 0
               SetScrollPos ( hwnd , SB_VERT , NewPos , .T. )

            ELSEIF LoWord( wParam ) == SB_BOTTOM

               NewPos := GetScrollRangeMax( hwnd, SB_VERT )
               SetScrollPos ( hwnd , SB_VERT , NewPos , .T. )

            ELSEIF LoWord( wParam ) == SB_PAGEUP

               NewPos := GetScrollPos( hwnd, SB_VERT ) - _HMG_aScrollStep [2]
               SetScrollPos ( hwnd , SB_VERT , NewPos , .T. )

            ELSEIF LoWord( wParam ) == SB_PAGEDOWN

               NewPos := GetScrollPos( hwnd, SB_VERT ) + _HMG_aScrollStep [2]
               SetScrollPos ( hwnd , SB_VERT , NewPos , .T. )

            ELSEIF LoWord( wParam ) == SB_THUMBPOSITION

               NewPos := HIWORD( wParam )
               SetScrollPos ( hwnd , SB_VERT , NewPos , .T. )

            ENDIF

            IF _HMG_aFormVirtualWidth [i] > 0
               NewHPos := GetScrollPos ( hwnd , SB_HORZ )
            ELSE
               NewHPos := 0
            ENDIF

            // Control Repositioning

            IF LoWord( wParam ) == SB_THUMBPOSITION .OR. LoWord( wParam ) == SB_LINEDOWN .OR. LoWord( wParam ) == SB_LINEUP .OR. LoWord( wParam ) == SB_PAGEUP .OR. LoWord( wParam ) == SB_PAGEDOWN .OR. LoWord( wParam ) == SB_BOTTOM .OR. LoWord( wParam ) == SB_TOP .AND. ! _HMG_AutoAdjust

               FOR x := 1 TO Len ( _HMG_aControlhandles )

                  IF _HMG_aControlParentHandles [x] == hwnd

                     IF _HMG_aControlType [x] == 'SPINNER'

                        MoveWindow ( _HMG_aControlhandles [x] [1] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewPos , _HMG_aControlWidth [x] - GetWindowWidth( _HMG_aControlhandles [x] [2] ) + 1 , _HMG_aControlHeight [x] , .T. )
                        MoveWindow ( _HMG_aControlhandles [x] [2] , _HMG_aControlCol [x] + _HMG_aControlWidth [x] - GetWindowWidth( _HMG_aControlhandles [x] [2] ) - NewHPos , _HMG_aControlRow [x] - NewPos , GetWindowWidth( _HMG_aControlhandles [x] [2] ) , _HMG_aControlHeight [x] , .T. )
#ifdef _DBFBROWSE_
                     ELSEIF _HMG_aControlType [x] == 'BROWSE'

                        MoveWindow ( _HMG_aControlhandles [x] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewPos , _HMG_aControlWidth [x] - GETVSCROLLBARWIDTH() , _HMG_aControlHeight [x] , .T. )
                        MoveWindow ( _HMG_aControlIds [x] , _HMG_aControlCol [x] + _HMG_aControlWidth [x] - GETVSCROLLBARWIDTH() - NewHPos , _HMG_aControlRow [x] - NewPos , GETVSCROLLBARWIDTH() , GetWIndowHeight( _HMG_aControlIds [x] ) , .T. )

                        MoveWindow ( _HMG_aControlMiscData1 [x] [1] , _HMG_aControlCol [x] + _HMG_aControlWidth [x] - GETVSCROLLBARWIDTH() - NewHPos , _HMG_aControlRow [x] + _HMG_aControlHeight [x] - GetHScrollBarHeight () - NewPos , ;
                           GetWindowWidth( _HMG_aControlMiscData1 [x][1] ) , GetWindowHeight( _HMG_aControlMiscData1 [x][1] ) , .T. )

                        ReDrawWindow ( _HMG_aControlhandles [x] )
#endif
                     ELSEIF _HMG_aControlType [x] == 'RADIOGROUP'

                        FOR z := 1 TO Len ( _HMG_aControlhandles [x] )
                           IF _HMG_aControlMiscData1 [x] == .F.
                              MoveWindow ( _HMG_aControlhandles [x] [z] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewPos + ( (z - 1 ) * _HMG_aControlSpacing[x] ), _HMG_aControlWidth [x] , _HMG_aControlHeight [x] / Len ( _HMG_aControlhandles [x] ) , .T. )
                           ELSE // horizontal
                              MoveWindow ( _HMG_aControlhandles [x] [z] , _HMG_aControlCol [x] - NewHPos + ( z - 1 ) * ( _HMG_aControlWidth [x] + _HMG_aControlSpacing[x] ), _HMG_aControlRow [x] - NewPos , _HMG_aControlWidth [x] , _HMG_aControlHeight [x] , .T. )
                           ENDIF
                        NEXT z

                     ELSEIF _HMG_aControlType [x] == 'TOOLBAR'

                        MsgMiniGuiError( "ToolBar's Parent Window cannot be a 'Virtual Dimensioned' window (use 'Virtual Dimensioned' SplitChild instead)." )

                     ELSE

                        MoveWindow ( _HMG_aControlhandles [x] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewPos , _HMG_aControlWidth [x] , _HMG_aControlHeight [x] , .T. )

                     ENDIF

                  ENDIF
               NEXT x

               ReDrawWindow ( hwnd )

            ENDIF

         ENDIF

         SWITCH LoWord ( wParam )

         CASE SB_LINEDOWN
            _DoWindowEventProcedure ( _HMG_aFormScrollDown [i] , i )
            EXIT
         CASE SB_LINEUP
            _DoWindowEventProcedure ( _HMG_aFormScrollUp [i] , i )
            EXIT
         CASE SB_THUMBPOSITION
         CASE SB_PAGEUP
         CASE SB_PAGEDOWN
         CASE SB_TOP
         CASE SB_BOTTOM
            _DoWindowEventProcedure ( _HMG_aFormVScrollBox [i] , i )

         END SWITCH

      ENDIF

#ifdef _DBFBROWSE_
      i := AScan ( _HMG_aControlIds , lParam )

      IF i > 0

         IF _HMG_aControlType [i] == 'BROWSE'

            IF LoWord( wParam ) == SB_LINEDOWN
               setfocus( _HMG_aControlHandles [i] )
               InsertDown()
            ENDIF

            IF LoWord( wParam ) == SB_LINEUP
               setfocus( _HMG_aControlHandles [i] )
               InsertUp()
            ENDIF

            IF LoWord( wParam ) == SB_PAGEUP
               setfocus( _HMG_aControlHandles [i] )
               InsertPrior()
            ENDIF

            IF LoWord( wParam ) == SB_PAGEDOWN
               setfocus( _HMG_aControlHandles [i] )
               InsertNext()
            ENDIF

            IF LoWord( wParam ) == SB_THUMBPOSITION

               BackArea := Alias()
               BrowseArea := _HMG_aControlSpacing [i]

               IF Select ( BrowseArea ) != 0

                  Select &BrowseArea
                  BackRec := RecNo()

                  IF ordKeyCount() > 0
                     RecordCount := ordKeyCount()
                  ELSE
                     RecordCount := RecCount()
                  ENDIF

                  SkipCount := Int ( HIWORD( wParam ) * RecordCount / GetScrollRangeMax ( _HMG_aControlIds [ i ] , 2 ) )

                  IF SkipCount > ( RecordCount / 2 )
                     GO BOTTOM
                     Skip - ( RecordCount - SkipCount )
                  ELSE
                     GO TOP
                     IF SkipCount > 1
                        SKIP SkipCount - RecCount() / 100
                     ENDIF
                  ENDIF

                  IF EOF()
                     Skip -1
                  ENDIF

                  nr := RecNo()

                  SetScrollPos ( _HMG_aControlIds [i] , 2 , HIWORD( wParam ) , .T. )

                  GO BackRec

                  IF Select ( BackArea ) != 0
                     Select &BackArea
                  ELSE
                     SELECT 0
                  ENDIF

                  _BrowseSetValue ( '' , '' , nr , i )

               ENDIF

            ENDIF

         ENDIF

      ENDIF
#endif
      _ProcessSliderEvents ( lParam , wParam )
      EXIT
   //**********************************************************************
   CASE WM_TASKBAR
   //**********************************************************************

      IF wParam == ID_TASKBAR .AND. lParam # WM_MOUSEMOVE

         SWITCH lParam

         CASE WM_LBUTTONDOWN

            i := AScan ( _HMG_aFormHandles , hWnd )
            IF i > 0
               _DoWindowEventProcedure ( _HMG_aFormNotifyIconLeftClick [i] , i )
            ENDIF
            EXIT

         CASE TTM_DELTOOLA

            IF IsToolTipBalloonActive .AND. hWnd == _HMG_MainHandle
               _DoWindowEventProcedure ( _HMG_NotifyBalloonClick , AScan ( _HMG_aFormHandles , hWnd ) )
            ENDIF
            EXIT

         CASE WM_LBUTTONDBLCLK

            i := AScan ( _HMG_aFormHandles , hWnd )
            IF i > 0
               _DoWindowEventProcedure ( _HMG_aFormNotifyIconDblClick [i] , i )
            ENDIF
            EXIT

         CASE WM_RBUTTONDOWN

            IF _HMG_ShowContextMenus

               aPos := GetCursorPos()

               i := AScan ( _HMG_aFormHandles , hWnd )
               IF i > 0
                  IF _HMG_aFormNotifyMenuHandle [i] != 0
                     TrackPopupMenu ( _HMG_aFormNotifyMenuHandle [i] , aPos [2] , aPos [1] , hWnd , .T. )
                  ENDIF
               ENDIF

            ENDIF

         END SWITCH

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_NEXTDLGCTL
   //**********************************************************************

      NextControlHandle := GetNextDlgTabITem ( GetActiveWindow() , GetFocus() , ( Wparam != 0 ) )

      setfocus( NextControlHandle )

      i := AScan ( _HMG_aControlHandles , NextControlHandle )

      IF i > 0

         IF _HMG_aControlType [i] == 'BUTTON'
            SendMessage ( NextControlHandle , BM_SETSTYLE , LOWORD ( BS_DEFPUSHBUTTON ) , 1 )
         ELSEIF _HMG_aControlType [i] == 'EDIT' .OR. _HMG_aControlType [i] == 'TEXT'
            SendMessage( _HMG_aControlHandles [i] , EM_SETSEL , 0 , -1 )
         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_HSCROLL
   //**********************************************************************

      i := AScan ( _HMG_aFormHandles , hWnd )

      IF i > 0

         // Horizontal ScrollBar Processing

         IF _HMG_aFormVirtualWidth [i] > 0 .AND. lParam == 0

            IF _HMG_aFormRebarhandle [i] > 0
               MsgMiniGuiError( "SplitBox's Parent Window cannot be a 'Virtual Dimensioned' window (use 'Virtual Dimensioned' SplitChild instead)." )
            ENDIF

            z := iif( _HMG_aScrollStep [1] > 0, _HMG_aScrollStep [1], GetScrollRangeMax ( hwnd , SB_HORZ ) / _HMG_aScrollStep [2] )

            IF LoWord( wParam ) == SB_LINERIGHT

               NewHPos := GetScrollPos( hwnd, SB_HORZ ) + z
               IF NewHPos >= GetScrollRangeMax( hwnd, SB_HORZ ) - 10
                  NewHPos := GetScrollRangeMax( hwnd, SB_HORZ )
               ENDIF
               SetScrollPos ( hwnd , SB_HORZ , NewHPos , .T. )

            ELSEIF LoWord( wParam ) == SB_LINELEFT

               NewHPos := GetScrollPos( hwnd, SB_HORZ ) - z
               IF NewHPos < 10
                  NewHPos := 0
               ENDIF
               SetScrollPos ( hwnd , SB_HORZ , NewHPos , .T. )

            ELSEIF LoWord( wParam ) == SB_PAGELEFT

               NewHPos := GetScrollPos( hwnd, SB_HORZ ) - _HMG_aScrollStep [2]
               SetScrollPos ( hwnd , SB_HORZ , NewHPos , .T. )

            ELSEIF LoWord( wParam ) == SB_PAGERIGHT

               NewHPos := GetScrollPos( hwnd, SB_HORZ ) + _HMG_aScrollStep [2]
               SetScrollPos ( hwnd , SB_HORZ , NewHPos , .T. )

            ELSEIF LoWord( wParam ) == SB_THUMBPOSITION

               NewHPos := HIWORD( wParam )
               SetScrollPos ( hwnd , SB_HORZ , NewHPos , .T. )

            ENDIF

            IF _HMG_aFormVirtualHeight [i] > 0
               NewVPos := GetScrollPos ( hwnd , SB_VERT )
            ELSE
               NewVPos := 0
            ENDIF

            // Control Repositioning

            IF LoWord( wParam ) == SB_THUMBPOSITION .OR. LoWord( wParam ) == SB_LINELEFT .OR. LoWord( wParam ) == SB_LINERIGHT .OR. LoWord( wParam ) == SB_PAGELEFT .OR. LoWord( wParam ) == SB_PAGERIGHT .AND. ! _HMG_AutoAdjust

               FOR x := 1 TO Len ( _HMG_aControlhandles )

                  IF _HMG_aControlParentHandles [x] == hwnd

                     IF _HMG_aControlType [x] == 'SPINNER'

                        MoveWindow ( _HMG_aControlhandles [x] [1] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewVPos , _HMG_aControlWidth [x] - GetWindowWidth( _HMG_aControlhandles [x] [2] ) + 1 , _HMG_aControlHeight [x] , .T. )
                        MoveWindow ( _HMG_aControlhandles [x] [2] , _HMG_aControlCol [x] + _HMG_aControlWidth [x] - GetWindowWidth( _HMG_aControlhandles [x] [2] ) - NewHPos , _HMG_aControlRow [x] - NewVPos , ;
                           GetWindowWidth( _HMG_aControlhandles [x] [2] ) , _HMG_aControlHeight [x] , .T. )
#ifdef _DBFBROWSE_
                     ELSEIF _HMG_aControlType [x] == 'BROWSE'

                        MoveWindow ( _HMG_aControlhandles [x] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewVPos , _HMG_aControlWidth [x] - GETVSCROLLBARWIDTH() , _HMG_aControlHeight [x] , .T. )

                        MoveWindow ( _HMG_aControlIds [x] , _HMG_aControlCol [x] + _HMG_aControlWidth [x] - GETVSCROLLBARWIDTH() - NewHPos , _HMG_aControlRow [x] - NewVPos , ;
                           GetWindowWidth( _HMG_aControlIds [x] ) , GetWindowHeight( _HMG_aControlIds [x] ) , .T. )

                        MoveWindow ( _HMG_aControlMiscData1 [x] [1] , _HMG_aControlCol [x] + _HMG_aControlWidth [x] - GETVSCROLLBARWIDTH() - NewHPos , _HMG_aControlRow [x] + _HMG_aControlHeight[x] - GethScrollBarHeight() - NewVPos , ;
                           GetWindowWidth( _HMG_aControlMiscData1 [x] [1] ) , GetWindowHeight ( _HMG_aControlMiscData1 [x][1] ) , .T. )

                        ReDrawWindow ( _HMG_aControlhandles [x] )
#endif
                     ELSEIF _HMG_aControlType [x] == 'RADIOGROUP'

                        FOR z := 1 TO Len ( _HMG_aControlhandles [x] )
                           IF _HMG_aControlMiscData1 [x] == .F.
                              MoveWindow ( _HMG_aControlhandles [x] [z] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewVPos + ( (z - 1 ) * _HMG_aControlSpacing[x] ), ;
                                 _HMG_aControlWidth [x] , _HMG_aControlHeight [x] / Len ( _HMG_aControlhandles [x] ) , .T. )
                           ELSE  // horizontal
                              MoveWindow ( _HMG_aControlhandles [x] [z] , _HMG_aControlCol [x] - NewHPos + ( z - 1 ) * ( _HMG_aControlWidth [x] + _HMG_aControlSpacing[x] ) , _HMG_aControlRow [x] - NewVPos , ;
                                 _HMG_aControlWidth [x] , _HMG_aControlHeight [x] , .T. )
                           ENDIF
                        NEXT z

                     ELSEIF _HMG_aControlType [x] == 'TOOLBAR'

                        MsgMiniGuiError( "ToolBar's Parent Window cannot be a 'Virtual Dimensioned' window (use 'Virtual Dimensioned' SplitChild instead)." )

                     ELSE

                        MoveWindow ( _HMG_aControlhandles [x] , _HMG_aControlCol [x] - NewHPos , _HMG_aControlRow [x] - NewVPos , _HMG_aControlWidth [x] , _HMG_aControlHeight [x] , .T. )

                     ENDIF

                  ENDIF
               NEXT x

               RedrawWindow ( hwnd )

            ENDIF

         ENDIF

         SWITCH LoWord ( wParam )

         CASE SB_LINERIGHT
            _DoWindowEventProcedure ( _HMG_aFormScrollRight [i] , i )
            EXIT
         CASE SB_LINELEFT
            _DoWindowEventProcedure ( _HMG_aFormScrollLeft [i] , i )
            EXIT
         CASE SB_THUMBPOSITION
         CASE SB_PAGELEFT
         CASE SB_PAGERIGHT
            _DoWindowEventProcedure ( _HMG_aFormHScrollBox [i] , i )

         END SWITCH

      ENDIF

      _ProcessSliderEvents ( lParam , wParam )
      EXIT
   //**********************************************************************
   CASE WM_PAINT
   //**********************************************************************

      FOR EACH r IN _HMG_aFormHandles
         z := hb_enumindex( r )
         IF _HMG_aFormDeleted [z] == .F. .AND. _HMG_aFormType [z] == 'X'
            a := _HMG_aFormGraphTasks [z]
            IF ISARRAY ( a ) .AND. Len ( a ) > 0
               AEval ( a, { |x| Eval ( x ) } )
            ENDIF
         ENDIF
      NEXT

      i := AScan ( _HMG_aFormHandles , hWnd )

      IF i > 0

         IF _HMG_ProgrammaticChange

            _DoWindowEventProcedure ( _HMG_aFormPaintProcedure [i] , i )

         ENDIF

         FOR x := 1 TO Len ( _HMG_aFormGraphTasks [i] )

            Eval ( _HMG_aFormGraphTasks [i] [x] )

         NEXT x

         ts := 0
         FOR EACH r IN _HMG_aControlHandles
            z := hb_enumindex( r )
            IF _HMG_aControlParentHandles [z] == hWnd
               IF _HMG_aControlType [z] == "TOOLBAR" .AND. And( GetWindowLong ( r , GWL_STYLE ), CCS_BOTTOM ) == CCS_BOTTOM
                  ts := r
                  EXIT
               ENDIF
            ENDIF
         NEXT

         IF ts > 0 .AND. _IsControlDefined ( "StatusBar" , _HMG_aFormNames [i] ) .AND. _HMG_SplitLastControl != "TOOLBAR"
            aPos := { 0, 0, 0, 0 }
            GetClientRect ( _HMG_aFormHandles [i], /*@*/ aPos )
            SetWindowPos ( ts, 0, 0, aPos [4] - LoWord( GetSizeToolBar( ts ) ) - GetBorderHeight() - GetProperty( _HMG_aFormNames [i], "StatusBar", "Height" ), 0, 0, SWP_NOSIZE + SWP_NOZORDER )
         ENDIF

         IF _HMG_ProgrammaticChange

            RETURN 0

         ELSE

            DefWindowProc ( hWnd, nMsg, wParam, lParam )

            _DoWindowEventProcedure ( _HMG_aFormPaintProcedure [i] , i )

            RETURN 1

         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_MBUTTONDOWN
   CASE WM_RBUTTONDOWN
   //**********************************************************************

      _HMG_MouseRow := HIWORD( lParam )
      _HMG_MouseCol := LOWORD( lParam )
      _HMG_MouseState := iif( nMsg == WM_RBUTTONDOWN, 2, 3 )

      IF _HMG_ShowContextMenus == .F.

         i := AScan ( _HMG_aFormHandles , hWnd )

         IF i > 0

            _MouseCoordCorr( hWnd , i )

            _DoWindowEventProcedure ( _HMG_aFormClickProcedure [i] , i )

         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_LBUTTONDOWN
   //**********************************************************************

      _HMG_MouseRow := HIWORD( lParam )
      _HMG_MouseCol := LOWORD( lParam )
      _HMG_MouseState := 1

      i := AScan ( _HMG_aFormhandles , hWnd )

      IF i > 0

         _MouseCoordCorr( hWnd , i )

         _DoWindowEventProcedure ( _HMG_aFormClickProcedure [i] , i )

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_MBUTTONUP
   CASE WM_RBUTTONUP
   CASE WM_LBUTTONUP
   //**********************************************************************

      _HMG_MouseState := 0
      EXIT
   //**********************************************************************
   CASE WM_MOUSEMOVE
   //**********************************************************************

      _HMG_MouseRow := HIWORD( lParam )
      _HMG_MouseCol := LOWORD( lParam )

      i := AScan ( _HMG_aFormhandles , hWnd )

      IF i > 0

         _MouseCoordCorr( hWnd , i )

         IF wParam == MK_LBUTTON
            _DoWindowEventProcedure ( _HMG_aFormMouseDragProcedure [i] , i )
         ELSE
            _DoWindowEventProcedure ( _HMG_aFormMouseMoveProcedure [i] , i )
         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_DROPFILES
   //**********************************************************************

      i := AScan ( _HMG_aFormhandles , hWnd )

      IF i > 0

         SetForegroundWindow( hWnd )

         Eval( _HMG_aFormDropProcedure [i], DragQueryFiles( wParam ) )

         DragFinish( wParam )

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_CONTEXTMENU
   //**********************************************************************

      _HMG_MouseRow := HIWORD( lParam )
      _HMG_MouseCol := LOWORD( lParam )

      i := AScan ( _HMG_aControlsContextMenu , { |x| x[1] == wParam } )

      IF i > 0 .AND. _HMG_aControlsContextMenu [i, 4] == .T.

         setfocus( wParam )

         _HMG_xControlsContextMenuID := _HMG_aControlsContextMenu [i, 3]
         TrackPopupMenu ( _HMG_aControlsContextMenu [i, 2] , _HMG_MouseCol , _HMG_MouseRow , hWnd )

      ELSEIF _HMG_ShowContextMenus == .T.

         setfocus( wParam )

         i := AScan ( _HMG_aFormhandles , hWnd )

         IF i > 0

            IF _HMG_aFormContextMenuHandle [i] != 0

               _MouseCoordCorr( hWnd , i )

               TrackPopupMenu ( _HMG_aFormContextMenuHandle [i] , LOWORD( lparam ) , HIWORD( lparam ) , hWnd )

            ENDIF

         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_TIMER
   //**********************************************************************

      i := AScan ( _HMG_aControlIds , wParam )

      IF i > 0
         _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_MOVE
   //**********************************************************************

      _HMG_MouseRow := HIWORD( lParam )
      _HMG_MouseCol := LOWORD( lParam )

      i := AScan ( _HMG_aFormhandles , hWnd )

      IF i > 0

         IF _HMG_MainActive == .T.
            _DoWindowEventProcedure ( _HMG_aFormMoveProcedure [i] , i )
         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_SIZE
   //**********************************************************************

      ControlCount := Len ( _HMG_aControlHandles )

      i := AScan ( _HMG_aFormHandles , hWnd )

      IF i > 0

         r := 0
         IF _HMG_aFormReBarHandle [i] > 0
            SizeRebar ( _HMG_aFormReBarHandle [i] )
            r := RebarHeight ( _HMG_aFormReBarHandle [i] )
            RedrawWindow ( _HMG_aFormReBarHandle [i] )
         ENDIF

         FOR x := 1 TO ControlCount
            IF _HMG_aControlParentHandles [x] == hWnd
               IF _HMG_aControlType [x] == "MESSAGEBAR"
                  MoveWindow( _HMG_aControlHandles [x] , 0 , 0 , 0 , 0 , .T. )
                  RefreshItemBar ( _HMG_aControlHandles [x] , _GetStatusItemWidth( hWnd, 1 ) )
                  IF ( k := GetControlIndex( 'ProgressMessage', GetParentFormName( x ) ) ) != 0
                     RefreshProgressItem ( _HMG_aControlMiscData1 [k,1], _HMG_aControlHandles [k], _HMG_aControlMiscData1 [k,2] )
                  ENDIF
                  EXIT
               ENDIF
            ENDIF
         NEXT x

         IF _HMG_MainClientMDIHandle != 0

            IF wParam != SIZE_MINIMIZED

               SizeClientWindow( hWnd, _HMG_ActiveStatusHandle, _HMG_MainClientMDIHandle, r )

            ENDIF

         ENDIF

         IF _HMG_MainActive == .T.

            IF wParam == SIZE_MAXIMIZED

               _DoWindowEventProcedure ( _HMG_aFormMaximizeProcedure [i], i )

               IF _HMG_AutoAdjust .AND. _HMG_MainClientMDIHandle == 0
                  _Autoadjust( hWnd )
               ENDIF

            ELSEIF wParam == SIZE_MINIMIZED

               _DoWindowEventProcedure ( _HMG_aFormMinimizeProcedure [i], i )

            ELSEIF wParam == SIZE_RESTORED .AND. !IsWindowSized( hWnd )

               _DoWindowEventProcedure ( _HMG_aFormRestoreProcedure [i], i )

            ELSE

               _DoWindowEventProcedure ( _HMG_aFormSizeProcedure [i], i )

               IF _HMG_AutoAdjust .AND. _HMG_MainClientMDIHandle == 0
                  _Autoadjust( hWnd )
               ENDIF

            ENDIF

         ENDIF

      ENDIF

      FOR i := 1 TO ControlCount
         IF _HMG_aControlParentHandles [i] == hWnd
            IF _HMG_aControlType [i] == "TOOLBAR"
               SendMessage( _HMG_aControlHandles [i], TB_AUTOSIZE, 0, 0 )
            ENDIF
         ENDIF
      NEXT i

      IF _HMG_MainClientMDIHandle != 0
         RETURN 1
      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_COMMAND
   //**********************************************************************

      ControlCount := Len ( _HMG_aControlHandles )

      //...............................................
      // Search Control From Received Id LoWord(wParam)
      //...............................................

      i := AScan ( _HMG_aControlIds , LoWord( wParam ) )

      IF i > 0

      // Process Menus .......................................

         IF HiWord( wParam ) == 0 .AND. _HMG_aControlType [i] == "MENU"
            IF _HMG_aControlMiscData1 [i] == 1
               _CloseMenu()
            ENDIF
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            RETURN 0
         ENDIF

      // Process ToolBar Buttons ............................

         IF _HMG_aControlType [i] == "TOOLBUTTON"
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            RETURN 0
         ENDIF

      ENDIF

      //..............................................
      // Search Control From Received Handle (lparam)
      //..............................................

#ifdef _TSBROWSE_
      oGet := GetObjectByHandle( lParam )
      IF ISOBJECT( oGet )

         r := oGet:HandleEvent ( nMsg, wParam, lParam )

         IF ValType( r ) == 'N'
            IF r != 0
               RETURN r
            ENDIF
         ENDIF
      ENDIF
#endif

      i := AScan ( _HMG_aControlHandles , lParam )

      // If Handle Not Found, Look For Spinner

      IF i == 0

         FOR x := 1 TO ControlCount
            IF ValType ( _HMG_aControlHandles [x] ) == 'A'
               IF _HMG_aControlHandles [x] [1] == lParam .AND. _HMG_aControlType [x] == 'SPINNER'
                  i := x
                  EXIT
               ENDIF
            ENDIF
         NEXT x

      ENDIF

      //................................
      // Process Command (Handle based)
      //................................

      IF i > 0

      // Button Click ........................................

         IF HIWORD( wParam ) == BN_CLICKED .AND. _HMG_aControlType [i] $ "OBUTTON"
            IF _HMG_aControlType [i] == "BUTTON"
               SetFocus( _HMG_aControlHandles [i] )
               SendMessage ( _HMG_aControlHandles [i] , BM_SETSTYLE , LOWORD ( BS_DEFPUSHBUTTON ) , 1 )
            ELSEIF _HMG_aControlRangeMax [i] == 1  // GF 08/27/2010
               a := GetCursorPos()
               IF ( x := GetWindowCol( lParam ) ) + GetWindowWidth( lParam ) < a[2] .OR. ;
                     ( r := GetWindowRow( lParam ) ) + GetWindowHeight( lParam ) < a[1] .OR. x > a[2] .OR. r > a[1]
                  RETURN 0
               ENDIF
            ENDIF
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            RETURN 0
         ENDIF

      // CheckBox Click ......................................

         IF HIWORD( wParam ) == BN_CLICKED .AND. _HMG_aControlType [i] == "CHECKBOX"
            _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
            RETURN 0
         ENDIF

      // Label / HyperLink / Image Click .....................

         IF HiWord ( wParam ) == STN_CLICKED .AND. ( "LABEL" $ _HMG_aControlType [i] .OR. _HMG_aControlType [i] == "HYPERLINK" .OR. _HMG_aControlType [i] == "IMAGE" )
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            RETURN 0
         ENDIF

      // Process Richedit Area Change ........................

         IF HIWORD( wParam ) == EN_VSCROLL .AND. ( _HMG_aControlType [i] == "RICHEDIT" )
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            RETURN 0
         ENDIF

      // TextBox and GetBox Change ...........................

         IF HiWord ( wParam ) == EN_CHANGE

            IF _HMG_DateTextBoxActive == .T.
               _HMG_DateTextBoxActive := .F.
            ELSE

               IF Len ( _HMG_aControlInputMask [i] ) > 0

                  IF _HMG_aControlType [i] == 'GETBOX'

                     IF GetFocus( i ) == _HMG_aControlHandles [i]
                        oGet := _HMG_aControlHeadClick [i]
                        IF oGet:Changed
                           _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
                        ENDIF
                     ENDIF

                  ELSEIF _HMG_aControlType [i] == 'MASKEDTEXT'

                     IF _HMG_aControlSpacing [i] == .T.
                        ProcessCharmask ( i, .T. )
                     ENDIF

                     _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )

                  ELSEIF _HMG_aControlType [i] == 'CHARMASKTEXT'

                     _HMG_DateTextBoxActive := .T.
                     ProcessCharMask ( i )

                     _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )

                  ENDIF

               ELSE

                  IF 'NUMTEXT' $ _HMG_aControlType[i]
                     ProcessNumText ( i )
                  ENDIF

                  IF _HMG_aControlType [i] <> 'GETBOX'
                     _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
                  ENDIF

               ENDIF

            ENDIF

            RETURN 0

         ENDIF

         // TextBox LostFocus ...................................

         IF HiWord( wParam ) == EN_KILLFOCUS

            IF _HMG_aControlType [i] == 'MASKEDTEXT'

               _HMG_DateTextBoxActive := .T.
               _HMG_aControlSpacing [i] := .F.

               IF "E" $ _HMG_aControlPageMap [i]

                  Ts := GetWindowText ( _HMG_aControlHandles [i] )

                  IF "." $ _HMG_aControlPageMap [i]
                     DO CASE
                     CASE At ( '.' , Ts ) > At ( ',' , Ts )
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlHandles[i] ) , i ) , _HMG_aControlPageMap[i] ) )
                     CASE At ( ',' , Ts ) > At ( '.' , Ts )
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromTextSp ( GetWindowText ( _HMG_aControlHandles[i] ) , i ) , _HMG_aControlPageMap[i] ) )
                     ENDCASE
                  ELSE
                     DO CASE
                     CASE At ( '.' , Ts ) != 0
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromTextSp ( GetWindowText ( _HMG_aControlHandles[i] ) , i ) , _HMG_aControlPageMap[i] ) )
                     CASE At ( ',' , Ts ) != 0
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlHandles[i] ) , i ) , _HMG_aControlPageMap[i] ) )
                     OTHERWISE
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlHandles[i] ) , i ) , _HMG_aControlPageMap[i] ) )
                     ENDCASE
                  ENDIF

               ELSE

                  SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles [i] ) , i ) , _HMG_aControlPageMap[i] ) )

               ENDIF

            ENDIF

            IF _HMG_aControlType [i] == 'CHARMASKTEXT'

               IF ValType ( _HMG_aControlHeadCLick [i] ) == 'L'
                  IF _HMG_aControlHeadCLick [i] == .T.
                     _HMG_DateTextBoxActive := .T.
                     SetWindowText ( _HMG_aControlHandles [i] , DToC ( CToD ( GetWindowText ( _HMG_aControlHandles [i] ) ) ) )
                  ENDIF
               ENDIF

            ENDIF

            IF _HMG_InteractiveCloseStarted != .T.

               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i], i )

               // Spinner Checking ..............................

               IF _HMG_aControlType [i] == "SPINNER"
                  Ts := GetWindowText ( _HMG_aControlHandles [i] [1] )

                  IF ! _HMG_aControlMiscData1 [i] [2] .AND. ! Empty ( Ts )
                     z := Val( Ts )
                     IF z < _HMG_aControlRangeMin [i]
                        SetSpinnerValue ( _HMG_aControlHandles [i] [2] , _HMG_aControlRangeMin [i] )
                     ELSEIF z > _HMG_aControlRangeMax [i]
                        SetSpinnerValue ( _HMG_aControlHandles [i] [2] , _HMG_aControlRangeMax [i] )
                     ENDIF
                  ENDIF
               ENDIF

            ENDIF

            RETURN 0

         ENDIF

         // TextBox GotFocus ....................................

         IF HIWORD( wParam ) == EN_SETFOCUS

            VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )

            IF _HMG_aControlType [i] == 'MASKEDTEXT'

               _HMG_DateTextBoxActive := .T.

               IF "E" $ _HMG_aControlPageMap [i]

                  Ts := GetWindowText ( _HMG_aControlHandles[i] )

                  IF "." $ _HMG_aControlPageMap [i]
                     DO CASE
                     CASE At ( '.' , Ts ) >  At ( ',' , Ts )
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles [i] ) , i ) , _HMG_aControlInputMask [i] ) )
                     CASE At ( ',' , Ts ) > At ( '.' , Ts )
                        TmpStr := Transform ( GetNumFromTextSP ( GetWindowText ( _HMG_aControlhandles [i] ) , i )  , _HMG_aControlInputMask [i] )
                        IF Val ( TmpStr ) == 0
                           TmpStr := StrTran ( TmpStr , '0.' , ' .' )
                        ENDIF
                        SetWindowText ( _HMG_aControlhandles [i] , TmpStr )
                     ENDCASE
                  ELSE
                     DO CASE
                     CASE At ( '.' , Ts ) !=  0
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromTextSP ( GetWindowText ( _HMG_aControlhandles [i] ) , i ) , _HMG_aControlInputMask [i] ) )
                     CASE At ( ',' , Ts )  != 0
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles [i] ) , i ) , _HMG_aControlInputMask [i] ) )
                     OTHERWISE
                        SetWindowText ( _HMG_aControlhandles [i] , Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles [i] ) , i ) , _HMG_aControlInputMask [i] ) )
                     ENDCASE
                  ENDIF

               ELSE

                  TmpStr := Transform ( GetNumFromText ( GetWindowText ( _HMG_aControlhandles [i] ) , i ) , _HMG_aControlInputMask [i] )

                  IF Val ( TmpStr ) == 0
                     TmpStr := StrTran ( TmpStr , '0.' , ' .' )
                  ENDIF

                  SetWindowText ( _HMG_aControlhandles [i] , TmpStr )

               ENDIF

               SendMessage( _HMG_aControlhandles [i] , EM_SETSEL , 0 , -1 )

               _HMG_aControlSpacing [i] := .T.

            ENDIF

            IF _HMG_aControlType [i] == 'CHARMASKTEXT'

               MaskStart := 1

               FOR x := 1 TO Len ( _HMG_aControlInputMask [i] )
                  z := SubStr ( _HMG_aControlInputMask [i] , x , 1 )
                  IF IsDigit( z ) .OR. IsAlpha( z ) .OR. z == '!'
                     MaskStart := x
                     EXIT
                  ENDIF
               NEXT x

               SendMessage( _HMG_aControlhandles [i] , EM_SETSEL , MaskStart - 1 , -1 )

            ENDIF

            _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )

            RETURN 0

         ENDIF

      // ListBox Processing ..................................

         IF 'LIST' $ _HMG_aControlType[i]

            // ListBox OnChange ....................................

            IF HIWORD( wParam ) == LBN_SELCHANGE
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
               RETURN 0
            ENDIF

            // ListBox LostFocus ...................................

            IF HIWORD( wParam ) == LBN_KILLFOCUS
               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
               RETURN 0
            ENDIF

            // ListBox GotFocus ....................................

            IF HIWORD( wParam ) == LBN_SETFOCUS
               VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
               RETURN 0
            ENDIF

            // ListBox Double Click ................................

            IF HIWORD( wParam ) == LBN_DBLCLK
               _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
               RETURN 0
            ENDIF

         ENDIF

      // ComboBox Processing .................................

         IF _HMG_aControlType [i] == 'COMBO'

            // ComboBox Change .....................................

            IF HIWORD( wParam ) == CBN_SELCHANGE
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
               RETURN 0
            ENDIF

            // ComboBox OnCancel ...................................

            IF HIWORD( wParam ) == CBN_SELENDCANCEL .AND. _HMG_aControlMiscData1 [i][1] <> 1
               IF CheckBit ( GetKeyState( VK_ESCAPE ), 32768 )
                  _DoControlEventProcedure ( _HMG_aControlMiscData1 [i][10] , i )
               ENDIF
               RETURN 0
            ENDIF

            // ComboBox DropDownList visible .......................

            IF HIWORD( wParam ) == CBN_DROPDOWN
               _DoControlEventProcedure ( _HMG_aControlInputMask [i] , i )
               RETURN 0
            ENDIF

            // ComboBox DropDownList closed ........................

            IF HIWORD( wParam ) == CBN_CLOSEUP
               _DoControlEventProcedure ( _HMG_aControlPicture [i] , i )
               RETURN 0
            ENDIF

            // ComboBox LostFocus ..................................

            IF HIWORD( wParam ) == CBN_KILLFOCUS
               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
               RETURN 0
            ENDIF

            // ComboBox GotFocus ...................................

            IF HIWORD( wParam ) == CBN_SETFOCUS
               VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
               RETURN 0
            ENDIF

            // Process Combo Display Area Change ...................

            IF HIWORD( wParam ) == CBN_EDITCHANGE
               _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
               IF _HMG_aControlMiscData1 [i][1] == 0 .AND. _HMG_aControlMiscData1 [i][2] == .T. .AND. _HMG_aControlMiscData1 [i][7] == .T.
                  DoComboAutoComplete ( i )
               ENDIF
               RETURN 0
            ENDIF

         ENDIF

      // Button LostFocus ....................................

         IF HIWORD( wParam ) == BN_KILLFOCUS .AND. _HMG_aControlType [i] != 'COMBO'
            _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
            RETURN 0
         ENDIF

      // Button GotFocus .....................................

         IF HIWORD( wParam ) == BN_SETFOCUS
            VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
            _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
            RETURN 0
         ENDIF

      ELSE

      // Process RadioGrop ...................................

         IF HIWORD( wParam ) == BN_CLICKED

            FOR i := 1 TO ControlCount
               IF ValType ( _HMG_aControlHandles [i] ) == "A" .AND. _HMG_aControlParentHandles [i] == hWnd
                  FOR x := 1 TO Len ( _HMG_aControlHandles [i] )
                     IF _HMG_aControlHandles [i] [x] == lParam
                        IF _HMG_aControlValue [i] != ( z := _GetValue( , , i ) ) .OR. ! _HMG_ProgrammaticChange
                           _HMG_aControlValue [i] := z
                           _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
                        ENDIF
                        IF _HMG_aControlPicture [i] == .F. // No TabStop
                           IF IsTabStop( _HMG_aControlHandles [i] [x] )
                              SetTabStop( _HMG_aControlHandles [i] [x] , .F. )
                           ENDIF
                        ENDIF
                        RETURN 0
                     ENDIF
                  NEXT x
               ENDIF
            NEXT i

         ELSEIF HIWORD( wParam ) == BN_SETFOCUS

            FOR i := 1 TO ControlCount
               IF ValType ( _HMG_aControlHandles [i] ) == "A" .AND. _HMG_aControlParentHandles [i] == hWnd
                  FOR x := 1 TO Len ( _HMG_aControlHandles [i] )
                     IF _HMG_aControlHandles [i] [x] == lParam
                        VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] [x] , _HMG_aControlParentHandles [i] )
                        IF _HMG_aControlPicture [i] == .F. // No TabStop
                           IF IsTabStop( _HMG_aControlHandles [i] [x] )
                              SetTabStop( _HMG_aControlHandles [i] [x] , .F. )
                           ENDIF
                        ENDIF
                        RETURN 0
                     ENDIF
                  NEXT x
               ENDIF
            NEXT i

         ENDIF

      ENDIF

      //...................
      // Process Enter Key
      //...................

#ifdef _TSBROWSE_
      oGet := GetObjectByHandle( GetFocus() )
      IF ISOBJECT( oGet )
         r := oGet:HandleEvent ( nMsg, wParam, lParam )
         IF ValType( r ) == 'N'
            IF r != 0
               RETURN r
            ENDIF
         ENDIF
      ENDIF
#endif

      i := AScan ( _HMG_aControlHandles , GetFocus() )

      IF i > 0

      // CheckBox or CheckButton Enter ......................................

         IF _HMG_aControlType [i] == "CHECKBOX" .AND. HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1
            IF Empty( _HMG_aControlMiscData1 [i] )
               _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            ENDIF
            IF _HMG_ExtendedNavigation == .T.
               _SetNextFocus()
            ENDIF
            RETURN 0
         ENDIF

      // ButtonEx Enter ......................................

         IF _HMG_aControlType [i] == "OBUTTON" .AND. HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            RETURN 0
         ENDIF

      // DatePicker or TimePicker Enter ......................

         IF ( _HMG_aControlType [i] == "DATEPICK" .OR. _HMG_aControlType [i] == "TIMEPICK" ) .AND. ( HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1 )
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
            IF _HMG_ExtendedNavigation == .T.
               _SetNextFocus()
            ENDIF
            RETURN 0
         ENDIF

#ifdef _DBFBROWSE_
      // Browse Escape .......................................

         IF _HMG_aControlType [i] == "BROWSE" .AND. lparam == 0 .AND. wparam == 2
            RETURN 1
         ENDIF

      // Browse Enter ........................................

         IF _HMG_aControlType [i] == "BROWSE" .AND. lparam == 0 .AND. wparam == 1
            IF _hmg_acontrolmiscdata1 [i] [6] == .T.
               IF _HMG_aControlFontColor [i] == .T.
                  ProcessInPlaceKbdEdit( i )
               ELSE
                  _BrowseEdit ( _hmg_acontrolhandles[i] , _HMG_acontrolmiscdata1 [i] [4] , _HMG_acontrolmiscdata1 [i] [5] , _HMG_acontrolmiscdata1 [i] [3] , _HMG_aControlInputMask [i] , .F. , _HMG_aControlFontColor [i] )
               ENDIF
            ELSE
               _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
            ENDIF
            RETURN 1 // JP12
         ENDIF
#endif
      // Grid Enter ..........................................

         IF ( _HMG_aControlType [i] == "GRID" .OR. _HMG_aControlType [i] == "MULTIGRID" ) .AND. lParam == 0 .AND. wParam == 1
            IF _hmg_acontrolspacing [i] == .T.
               IF _HMG_aControlMiscData1 [i] [20] == .T. .OR. _HMG_aControlFontColor [i] == .T.
                  IF _HMG_aControlFontColor [i] == .F.
                     _GridInplaceKBDEdit ( i )
                  ELSE
                     _GridInplaceKBDEdit_2 ( i )
                  ENDIF
               ELSE
                  _EditItem ( _hmg_acontrolhandles [i] )
               ENDIF
            ELSE
               _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
            ENDIF
            RETURN 0
         ENDIF

      // ComboBox Enter ......................................

         IF _HMG_aControlType [i] == "COMBO" .AND. HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1
            _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
            IF _HMG_ExtendedNavigation == .T.
               _SetNextFocus()
            ENDIF
            RETURN 0
         ENDIF

      // ListBox Enter .......................................

         IF ( _HMG_aControlType [i] == "LIST" .OR. _HMG_aControlType [i] == "MULTILIST" ) .AND. ( HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1 )
            _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
            RETURN 0
         ENDIF

      // TextBox Enter .......................................

         IF "TEXT" $ _HMG_aControlType [i] .AND. HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1
            IF _HMG_aControlType [i] == "BTNTEXT" .OR. _HMG_aControlType [i] == "BTNNUMTEXT"
               IF _HMG_aControlMiscData1 [i][4]
                  _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
                  RETURN 0
               ENDIF
            ENDIF
            _HMG_SetFocusExecuted := .F.
            _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
            IF _HMG_SetFocusExecuted == .F.
               IF _HMG_ExtendedNavigation == .T.
                  _SetNextFocus()
               ENDIF
            ELSE
               _HMG_SetFocusExecuted := .F.
            ENDIF
            RETURN 0
         ENDIF

      // Tree Enter ..........................................

         IF _HMG_aControlType [i] == "TREE" .AND. HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1
            _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
            RETURN 0
         ENDIF

      ELSE

      // ComboBox (DisplayEdit) ..............................

         FOR i := 1 TO ControlCount
            IF _HMG_aControlType [i] == "COMBO" .AND. HiWord( wParam ) == 0 .AND. LoWord( wParam ) == 1
               IF _hmg_acontrolrangemin [i] == GetFocus() .OR. _hmg_acontrolrangemax [i] == GetFocus()
                  _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
                  IF _HMG_ExtendedNavigation == .T.
                     _SetNextFocus()
                  ENDIF
                  EXIT
               ENDIF
            ENDIF
         NEXT i

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_NOTIFY
   //**********************************************************************

   // Process ToolBar ToolTip .....................................

      IF GetNotifyCode ( lParam ) == TTN_NEEDTEXT          // for tooltip TOOLBUTTON
         x := AScan ( _HMG_aControlIds , GetNotifyId( lParam ) )
         IF x > 0 .AND. _HMG_aControlType [x] == "TOOLBUTTON"
            SetButtonTip ( lParam , _HMG_aControlToolTip [x] )
         ELSE  // JR
            a := GetMessagePos()
            k := WindowFromPoint ( { LoWord( a ), HiWord( a ) } )  // control handle
            x := AScan( _HMG_aControlHandles, k )
            IF x > 0 .AND. _HMG_aControlType [x] == 'TAB'
               IF ValType( _HMG_aControlTooltip [x] ) == 'A'
                  i := GetNotifyId ( lParam )  // page number
                  SetButtonTip ( lParam , _HMG_aControlTooltip [x, i + 1] )
               ELSE
                  SetButtonTip ( lParam , _HMG_aControlTooltip [x] )
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      IF GetNotifyCode ( lParam ) == RBN_CHEVRONPUSHED     // Notify for chevron button
         _CreatePopUpChevron ( hWnd, wParam, lParam )
      ENDIF

#ifdef _TSBROWSE_
   // Process TSBrowse .....................................

      oGet := GetObjectByHandle( GetHwndFrom ( lParam ) )
      IF ISOBJECT( oGet )

         r := oGet:HandleEvent ( nMsg, wParam, lParam )

         IF ValType( r ) == 'N'
            IF r != 0
               RETURN r
            ENDIF
         ENDIF
      ENDIF
#endif

      i := AScan ( _HMG_aControlHandles , GetHwndFrom ( lParam ) )

      IF i > 0

#ifdef _PAGER_
      // Process Pager .....................................

         IF _HMG_aControlType [i] == "PAGER"
            IF GetNotifyCode ( lParam ) == PGN_CALCSIZE
               IF _HMG_aControlMiscData1 [i] == .T.
                  PagerCalcSize( lParam , _HMG_aControlHeight [i] )
               ELSE
                  PagerCalcSize( lParam , _HMG_aControlWidth [i] )
               ENDIF
            ENDIF
            IF GetNotifyCode ( lParam ) == PGN_SCROLL
               PagerScroll( lParam ,  _HMG_aControlSpacing [i] )
            ENDIF
         ENDIF
#endif
#ifdef _DBFBROWSE_
      // Process Browse ....................................

         IF _HMG_aControlType [i] == "BROWSE"

            // Browse Refresh On Column Size ...............

            IF GetNotifyCode ( lParam ) == NM_CUSTOMDRAW

               hws := 0
               hwm := .F.
               FOR x := 1 TO Len ( _HMG_aControlProcedures [i] )
                  hws += ListView_GetColumnWidth ( _HMG_aControlHandles [i] , x - 1 )
                  IF _HMG_aControlProcedures [i] [x] != ListView_GetColumnWidth ( _HMG_aControlHandles [i] , x - 1 )
                     hwm := .T.
                     _HMG_aControlProcedures [i] [x] := ListView_GetColumnWidth ( _HMG_aControlHandles [i] , x - 1 )
                     _BrowseRefresh( '', '', i )
                  ENDIF
               NEXT x

            // Browse ReDraw Vertical ScrollBar If Needed ...

               IF _HMG_aControlIds [i] != 0 .AND. hwm == .T.
                  IF hws > _HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() - 4
                     MoveWindow ( _HMG_aControlIds [i] , _HMG_aControlCol[i] + _HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] , GETVSCROLLBARWIDTH() , ;
                        _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT() , .T. )
                     MoveWindow ( _HMG_aControlMiscData1 [i] [1], _HMG_aControlCol[i] + _HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] + _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT() , ;
                        GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() , .T. )
                  ELSE
                     MoveWindow ( _HMG_aControlIds [i] , _HMG_aControlCol[i] + _HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] , GETVSCROLLBARWIDTH() , _HMG_aControlHeight[i] , .T. )
                     MoveWindow ( _HMG_aControlMiscData1 [i] [1], _HMG_aControlCol[i] + _HMG_aControlWidth[i] - GETVSCROLLBARWIDTH() , _HMG_aControlRow[i] + _HMG_aControlHeight[i] - GETHSCROLLBARHEIGHT() , 0 , 0 , .T. )
                  ENDIF
               ENDIF

            ENDIF

            dBc := _HMG_aControlMiscData1 [i] [10]
            dFc := _HMG_aControlMiscData1 [i] [ 9]

            IF GetNotifyCode ( lParam ) == NM_CUSTOMDRAW .AND. ( ValType ( dBc ) == 'A' .OR. ValType ( dFc ) == 'A' )
               IF ( r := GetDs ( lParam ) ) <> -1
                  RETURN r
               ELSE
                  a := GetRc ( lParam )

                  IF a[1] >= 1 .AND. a[1] <= Len ( _HMG_aControlRangeMax [i] ) .AND. ;  // MaxBrowseRows
                     a[2] >= 1 .AND. a[2] <= Len ( _HMG_aControlRangeMin [i] )       // MaxBrowseCols
                     aTemp  := _HMG_aControlMiscData1 [i] [18]
                     aTemp2 := _HMG_aControlMiscData1 [i] [17]
                     IF ValType ( aTemp ) == 'A' .AND. ValType ( aTemp2 ) <> 'A'
                        IF Len ( aTemp ) >= a[1]
                           IF aTemp [a[1]] [a[2]] <> -1
                              RETURN SetBcFc ( lParam , aTemp [a[1]] [a[2]] , RGB( 0, 0, 0 ) )
                           ELSE
                              RETURN SETBRCCD( lParam )
                           ENDIF
                        ENDIF
                     ELSEIF ValType ( aTemp ) <> 'A' .AND. ValType ( aTemp2 ) == 'A'
                        IF Len ( aTemp2 ) >= a[1]
                           IF aTemp2 [a[1]] [a[2]] <> -1
                              RETURN SetBcFc ( lParam , RGB( 255, 255, 255 ) , aTemp2 [a[1]] [a[2]] )
                           ELSE
                              RETURN SETBRCCD( lParam )
                           ENDIF
                        ENDIF
                     ELSEIF ValType ( aTemp ) == 'A' .AND. ValType ( aTemp2 ) == 'A'
                        IF Len ( aTemp ) >= a[1] .AND. Len ( aTemp2 ) >= a[1]
                           IF aTemp [a[1]] [a[2]] <> -1
                              RETURN SetBcFc ( lParam , aTemp [a[1]] [a[2]] , aTemp2 [a[1]] [a[2]] )
                           ELSE
                              RETURN SETBRCCD( lParam )
                           ENDIF
                        ENDIF
                     ENDIF
                  ELSE
                     RETURN SETBRCCD( lParam )
                  ENDIF

               ENDIF

            ENDIF

         // Browse Click ................................

            IF GetNotifyCode ( lParam ) == NM_CLICK .OR. GetNotifyCode ( lParam ) == LVN_BEGINDRAG .OR. ;
                  GetNotifyCode ( lParam ) == NM_RCLICK

               IF LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) > 0
                  DeltaSelect := LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) - AScan ( _HMG_aControlRangeMax [i] , _HMG_aControlValue [i] )
                  _HMG_aControlValue [i] :=  _HMG_aControlRangeMax [i] [ LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] ) ]
                  _BrowseVscrollFastUpdate ( i , DeltaSelect )
                  _BrowseOnChange ( i )
               ENDIF

               RETURN 0

            ENDIF

         // Browse Key Handling .........................

            IF GetNotifyCode ( lParam ) == LVN_KEYDOWN

               DO CASE

               CASE GetGridvKey( lParam ) == 65 .AND. ( GetAltState() == -127 .OR. GetAltState() == -128 ) .AND. GetKeyState( VK_CONTROL ) >= 0 .AND. GetKeyState( VK_SHIFT ) >= 0 // ALT + A

                  IF _HMG_acontrolmiscdata1 [i] [2] == .T.
                     _BrowseEdit ( _hmg_acontrolhandles [i] , _HMG_acontrolmiscdata1 [i] [4] , _HMG_acontrolmiscdata1 [i] [5] , ;
                        _HMG_acontrolmiscdata1 [i] [3] , _HMG_aControlInputMask [i] , .T. , _HMG_aControlFontColor [i] , _HMG_acontrolmiscdata1 [i] [13] )
                  ENDIF

               CASE GetGridvKey( lParam ) == 46 // DEL

                  IF _HMG_aControlMiscData1 [i] [12] == .T.
                     IF MsgYesNo ( _HMG_BRWLangMessage [1] , _HMG_BRWLangMessage [2] )
                        _BrowseDelete( '', '', i )
                     ENDIF
                  ENDIF

               CASE GetGridvKey( lParam ) == 36 // HOME

                  _BrowseHome( '', '', i )
                  RETURN 1

               CASE GetGridvKey( lParam ) == 35 // END

                  _BrowseEnd( '', '', i )
                  RETURN 1

               CASE GetGridvKey( lParam ) == 33 // PGUP

                  _BrowsePrior( '', '', i )
                  RETURN 1

               CASE GetGridvKey( lParam ) == 34 // PGDN

                  _BrowseNext( '', '', i )
                  RETURN 1

               CASE GetGridvKey( lParam ) == 38 // UP

                  _BrowseUp( '', '', i )
                  RETURN 1

               CASE GetGridvKey( lParam ) == 40 // DOWN

                  _BrowseDown( '', '', i )
                  RETURN 1

               ENDCASE

               RETURN 0

            ENDIF

         // Browse Double Click .........................

            IF GetNotifyCode ( lParam ) == NM_DBLCLK

               _PushEventInfo()
               _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
               _HMG_ThisType := 'C'
               _HMG_ThisIndex := i
               _HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ]
               _HMG_ThisControlName := _HMG_aControlNames [_HMG_THISIndex ]
               r := ListView_HitTest ( _HMG_aControlHandles [i] , GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [i] ) , GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [i] ) )
               IF r [2] == 1
                  ListView_Scroll( _HMG_aControlHandles [i] , -10000 , 0 )
                  r := ListView_HitTest ( _HMG_aControlHandles [i] , GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [i] ) , GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [i] ) )
               ELSE
                  r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i] , r [1] - 1 , r [2] - 1 )
                  //                CellCol            CellWidth
                  xs := ( _HMG_aControlCol [i] + r [2] + r [3] ) - ( _HMG_aControlCol [i] + _HMG_aControlWidth [i] )
                  xd := 20
                  IF xs > - xd
                     ListView_Scroll( _HMG_aControlHandles [i] , xs + xd , 0 )
                  ELSE
                     IF r [2] < 0
                        ListView_Scroll( _HMG_aControlHandles [i] , r[2] , 0 )
                     ENDIF
                  ENDIF
                  r := ListView_HitTest ( _HMG_aControlHandles [i] , GetCursorRow() - GetWindowRow ( _HMG_aControlHandles [i] ) , GetCursorCol() - GetWindowCol ( _HMG_aControlHandles [i] ) )
               ENDIF

               _HMG_ThisItemRowIndex := r [1]
               _HMG_ThisItemColIndex := r [2]
               IF r [2] == 1
                  r := LISTVIEW_GETITEMRECT ( _HMG_aControlHandles [i] , r [1] - 1 )
               ELSE
                  r := LISTVIEW_GETSUBITEMRECT ( _HMG_aControlHandles [i] , r [1] - 1 , r [2] - 1 )
               ENDIF
               _HMG_ThisItemCellRow := _HMG_aControlRow [i] + r [1]
               _HMG_ThisItemCellCol := _HMG_aControlCol [i] + r [2]
               _HMG_ThisItemCellWidth  := r [3]
               _HMG_ThisItemCellHeight := r [4]

               IF _hmg_acontrolmiscdata1 [i] [6] == .T.
                  _BrowseEdit ( _hmg_acontrolhandles [i] , _HMG_acontrolmiscdata1 [i] [4] , _HMG_acontrolmiscdata1 [i] [5] , ;
                     _HMG_acontrolmiscdata1 [i] [3] , _HMG_aControlInputMask [i] , .F. , _HMG_aControlFontColor [i] , _HMG_acontrolmiscdata1 [i] [13] )
               ELSE
                  IF ValType( _HMG_aControlDblClick [i] ) == 'B'
                     Eval( _HMG_aControlDblClick [i]  )
                  ENDIF
               ENDIF

               _PopEventInfo()
               _HMG_ThisItemRowIndex := 0
               _HMG_ThisItemColIndex := 0
               _HMG_ThisItemCellRow := 0
               _HMG_ThisItemCellCol := 0
               _HMG_ThisItemCellWidth := 0
               _HMG_ThisItemCellHeight := 0

            ENDIF

         // Browse LostFocus ............................

            IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // Browse GotFocus .............................

            IF GetNotifyCode ( lParam ) == NM_SETFOCUS
               VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // Browse Header Click .........................

            IF GetNotifyCode ( lParam ) == LVN_COLUMNCLICK
               IF ValType ( _HMG_aControlHeadClick [i] ) == 'A'
                  lvc := GetGridColumn( lParam ) + 1
                  IF Len ( _HMG_aControlHeadClick [i] ) >= lvc
                     _DoControlEventProcedure ( _HMG_aControlHeadClick [i] [lvc] , i , , lvc )
                  ENDIF
               ENDIF
               RETURN 0
            ENDIF

         ENDIF
#endif
      // ToolBar DropDown Button Click .......................

         IF GetNotifyCode ( lParam ) == TBN_DROPDOWN

            DefWindowProc( hWnd, TBN_DROPDOWN, wParam, lParam )
            x := AScan ( _HMG_aControlIds , GetButtonPos( lParam ) )
            k := _HMG_aControlValue [x]
            IF x > 0 .AND. _HMG_aControlType [x] == "TOOLBUTTON"
               aPos := { 0, 0, 0, 0 }
               GetWindowRect( _HMG_aControlHandles [i], /*@*/aPos )
               r := GetButtonBarRect( _HMG_aControlHandles [i], k - 1 )
               TrackPopupMenu ( _HMG_aControlRangeMax [x] , aPos [1] + LoWord( r ) , aPos [2] + HiWord( r ) + ( aPos [4] - aPos [2] - HiWord( r ) ) / 2 , hWnd )
            ENDIF

            RETURN 0

         ENDIF

      // RichEdit Selection Change ........................

         IF _HMG_aControlType [i] == "RICHEDIT"

            IF GetNotifyCode ( lParam ) == EN_MSGFILTER // for typing text
               IF ValType( _HMG_aControlChangeProcedure [i] ) == 'B'
                  _HMG_ThisType := 'C'
                  _HMG_ThisIndex := i
                  Eval( _HMG_aControlChangeProcedure [i] )
                  _HMG_ThisIndex := 0
                  _HMG_ThisType := ''
               ENDIF
            ENDIF
            IF GetNotifyCode ( lParam ) == EN_DRAGDROPDONE // for change text by drag
               IF ValType( _HMG_aControlChangeProcedure [i] ) == 'B'
                  _HMG_ThisType := 'C'
                  _HMG_ThisIndex := i
                  Eval( _HMG_aControlChangeProcedure [i] )
                  _HMG_ThisIndex := 0
                  _HMG_ThisType := ''
               ENDIF
            ENDIF
            IF GetNotifyCode ( lParam ) == EN_SELCHANGE // for change text
               IF ValType( _HMG_aControlDblClick [i] ) == 'B'
                  _HMG_ThisType := 'C'
                  _HMG_ThisIndex := i
                  Eval( _HMG_aControlDblClick [i] )
                  _HMG_ThisIndex := 0
                  _HMG_ThisType := ''
               ENDIF
            ENDIF
         ENDIF

      // MonthCalendar Selection Change ......................

         IF _HMG_aControlType [i] == "MONTHCAL"
            IF GetNotifyCode ( lParam ) == MCN_SELECT
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
               RETURN 0
            ENDIF
            IF GetNotifyCode ( lParam ) == MCN_SELCHANGE
               _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i , 'CONTROL_ONCHANGE' )
               RETURN 0
            ENDIF
         ENDIF

      // Grid Processing .....................................

         IF _HMG_aControlType [i] $ "MULTIGRID"

            IF _HMG_aControlFontColor [i] == .T.

            // Grid Key Handling .........................

               IF GetNotifyCode ( lParam ) == LVN_KEYDOWN

                  SWITCH GetGridvKey( lParam )

                  CASE 37 // LEFT
                     IF _HMG_aControlMiscData1 [i] [ 17 ] > 1
                        _HMG_aControlMiscData1 [i] [ 17 ] --

                        nFrozenColumnCount := _HMG_aControlMiscData1 [i] [ 19 ]
                        IF nFrozenColumnCount > 0
                           nDestinationColumn := _HMG_aControlMiscData1 [i] [ 17 ]
                           IF nDestinationColumn >= nFrozenColumnCount + 1
                              aOriginalColumnWidths := _HMG_aControlMiscData1 [i] [ 2 ]
                              // Set Destination Column Width To Original
                              LISTVIEW_SETCOLUMNWIDTH ( _HMG_aControlHandles [i] , nDestinationColumn - 1 , aOriginalColumnWidths [ nDestinationColumn ] )
                           ENDIF
                        ENDIF

                        _GRID_KBDSCROLL( i )

                        LISTVIEW_REDRAWITEMS ( _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 , _HMG_aControlMiscData1 [i] [ 1 ] - 1 )
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
                  CASE 39 // RIGHT
                     IF _HMG_aControlMiscData1 [i] [ 17 ] < Len ( _HMG_aControlCaption [i] )
                        _HMG_aControlMiscData1 [i] [ 17 ] ++

                        nFrozenColumnCount := _HMG_aControlMiscData1 [i] [ 19 ]
                        IF nFrozenColumnCount > 0
                           nDestinationColumn := _HMG_aControlMiscData1 [i] [ 17 ]
                           FOR k := nDestinationColumn TO Len( _HMG_aControlCaption [ i ] ) - 1
                              IF LISTVIEW_GETCOLUMNWIDTH ( _HMG_aControlHandles [i] , k - 1 ) == 0
                                 _HMG_aControlMiscData1 [i] [ 17 ] ++
                              ENDIF
                           NEXT k

                           IF nDestinationColumn > nFrozenColumnCount + 1
                              // Set Current Column Width To 0
                              LISTVIEW_SETCOLUMNWIDTH ( _HMG_aControlHandles [i] , nDestinationColumn - 2 , 0 )
                           ENDIF
                        ENDIF

                        _GRID_KBDSCROLL( i )

                        LISTVIEW_REDRAWITEMS ( _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 , _HMG_aControlMiscData1 [i] [ 1 ] - 1 )
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
                  CASE 38 // UP
                     IF _HMG_aControlMiscData1 [i] [ 17 ] == 0
                        _HMG_aControlMiscData1 [i] [ 17 ] := 1
                     ENDIF
                     IF _HMG_aControlMiscData1 [i] [ 1 ] > 1
                        _HMG_aControlMiscData1 [i] [ 1 ] --
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
                  CASE 40 // DOWN
                     IF _HMG_aControlMiscData1 [i] [ 17 ] == 0
                        _HMG_aControlMiscData1 [i] [ 17 ] := 1
                     ENDIF
                     IF _HMG_aControlMiscData1 [i] [ 1 ] < SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )
                        _HMG_aControlMiscData1 [i] [ 1 ] ++
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
                  CASE 33 // PGUP
                     nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]

                     IF _HMG_aControlMiscData1 [i] [ 1 ] == SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + 1
                        _HMG_aControlMiscData1 [i] [ 1 ] -= SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 ) - 1
                     ELSE
                        _HMG_aControlMiscData1 [i] [ 1 ] := SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + 1
                     ENDIF

                     IF _HMG_aControlMiscData1 [i] [ 1 ] < 1
                        _HMG_aControlMiscData1 [i] [ 1 ] := 1
                     ENDIF

                     IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
                  CASE 34 // PGDOWN
                     nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]

                     IF _HMG_aControlMiscData1 [i] [ 1 ] == SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 )
                        _HMG_aControlMiscData1 [i] [ 1 ] += SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 ) - 1
                     ELSE
                        _HMG_aControlMiscData1 [i] [ 1 ] := SendMessage ( _HMG_aControlHandles [i] , LVM_GETTOPINDEX , 0 , 0 ) + SendMessage ( _HMG_aControlHandles [i] , LVM_GETCOUNTPERPAGE , 0 , 0 )
                     ENDIF

                     IF _HMG_aControlMiscData1 [i] [ 1 ] > SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )
                        _HMG_aControlMiscData1 [i] [ 1 ] := SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )
                     ENDIF

                     IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
                  CASE 35 // END
                     nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]

                     _HMG_aControlMiscData1 [i] [ 1 ] := SendMessage( _HMG_aControlHandles [i] , LVM_GETITEMCOUNT , 0 , 0 )

                     IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
                  CASE 36 // HOME
                     nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ]

                     _HMG_aControlMiscData1 [i] [ 1 ] := 1

                     IF nGridRowValue <> _HMG_aControlMiscData1 [i] [ 1 ]
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                     EXIT
#ifndef __XHARBOUR__
                  OTHERWISE
#else
                  DEFAULT
#endif
                     RETURN 1
                  END SWITCH

               ENDIF

            ENDIF

            IF GetNotifyCode ( lParam ) == NM_CUSTOMDRAW

               IF ( r := iif( _HMG_aControlFontColor [i] == .T. , ;
                     GetDs ( lParam , _HMG_aControlHandles [i] , _HMG_aControlMiscData1 [i] [ 1 ] - 1 ), ;
                     GetDs ( lParam ) ) ) <> -1
                  RETURN r
               ELSE
                  a := GetRc ( lParam )
                  IF _HMG_aControlFontColor [i] == .T.
                     IF a [1] == _HMG_aControlMiscData1 [i] [ 1 ] .AND. a [2] == _HMG_aControlMiscData1 [i] [ 17 ]
                        RETURN SetBcFc ( lParam , RGB( _HMG_GridSelectedCellBackColor[1] , _HMG_GridSelectedCellBackColor[2] , _HMG_GridSelectedCellBackColor[3] ) , RGB( _HMG_GridSelectedCellForeColor[1] , _HMG_GridSelectedCellForeColor[2] , _HMG_GridSelectedCellForeColor[3] ) )
                     ELSEIF a [1] == _HMG_aControlMiscData1 [i] [ 1 ] .AND. a [2] <> _HMG_aControlMiscData1 [i] [ 17 ]
                        RETURN SetBcFc ( lParam , RGB( _HMG_GridSelectedRowBackColor[1] , _HMG_GridSelectedRowBackColor[2] , _HMG_GridSelectedRowBackColor[3] ) , RGB( _HMG_GridSelectedRowForeColor[1] , _HMG_GridSelectedRowForeColor[2] , _HMG_GridSelectedRowForeColor[3] ) )
                     ELSE
                        RETURN _DoGridCustomDraw ( i , a , lParam )
                     ENDIF
                  ELSE
                     RETURN _DoGridCustomDraw ( i , a , lParam )
                  ENDIF
               ENDIF

            ENDIF

            IF GetNotifyCode ( lParam ) == - 181
               ReDrawWindow ( _hmg_acontrolhandles [i] )
            ENDIF

         // Grid OnQueryData ............................

            IF GetNotifyCode ( lParam ) == LVN_GETDISPINFO

               IF ValType( _HMG_aControlProcedures [i] ) == 'B'

                  _PushEventInfo()
                  _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles [i] )
                  _HMG_ThisType  := 'C'
                  _HMG_ThisIndex := i
                  _HMG_ThisFormName := _HMG_aFormNames [ _HMG_ThisFormIndex ]
                  _HMG_ThisControlName := _HMG_aControlNames [ _HMG_ThisIndex ]
                  aPos := GETGRIDDISPINFOINDEX ( lParam )
                  _HMG_ThisQueryRowIndex := aPos [1]
                  _HMG_ThisQueryColIndex := aPos [2]

                  Eval( _HMG_aControlProcedures [i] )

                  IF Len ( _HMG_aControlBkColor [i] ) > 0 .AND. _HMG_ThisQueryColIndex == 1
                     SetGridQueryImage ( lParam , _HMG_ThisQueryData )
                  ELSE
                     SetGridQueryData ( lParam , hb_ValToStr( _HMG_ThisQueryData ) )
                  ENDIF
                  _HMG_ThisQueryRowIndex := 0
                  _HMG_ThisQueryColIndex := 0
                  _HMG_ThisQueryData := ""
                  _PopEventInfo()

               ENDIF

            ENDIF

         // Grid LostFocus ..............................

            IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // Grid GotFocus ...............................

            IF GetNotifyCode ( lParam ) == NM_SETFOCUS
               VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // Grid Change .................................

            IF GetNotifyCode ( lParam ) == LVN_KEYDOWN .AND. GetGridvKey( lParam ) == 32
               SpaceKeyIsPressedInGrid := _HMG_aControlHandles [i]
            ENDIF
            IF GetNotifyCode ( lParam ) == LVN_ITEMCHANGED
               #define LVIS_UNCHECKED 0x1000
               #define LVIS_CHECKED   0x2000
               IF GetGridNewState( lParam ) == LVIS_UNCHECKED .OR. GetGridNewState( lParam ) == LVIS_CHECKED
                  aCellData := _GetGridCellData ( i )
                  IF aCellData [1] > 0 .AND. aCellData [1] <= ListViewGetItemCount ( _HMG_aControlHandles [i] ) .OR. ;
                     SpaceKeyIsPressedInGrid == _HMG_aControlHandles [i]
                     _DoControlEventProcedure ( _HMG_aControlMiscData1 [i] [23] , i , 'CONTROL_ONCHANGE' , SpaceKeyIsPressedInGrid )
                     SpaceKeyIsPressedInGrid := 0
                     RETURN 0
                  ENDIF
               ENDIF
               IF GetGridOldState( lParam ) == 0 .AND. GetGridNewState( lParam ) != 0
                  IF _HMG_aControlFontColor [i] == .T.
                     lCellGridRowChanged := .T.
                     _HMG_aControlMiscData1 [i] [ 1 ] := LISTVIEW_GETFIRSTITEM ( _HMG_aControlHandles [i] )
                  ELSE
                     _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
                  ENDIF
                  RETURN 0
               ENDIF
            ENDIF

         // Grid Header Click ..........................

            IF GetNotifyCode ( lParam ) == LVN_COLUMNCLICK
               IF ValType ( _HMG_aControlHeadClick [i] ) == 'A'
                  lvc := GetGridColumn( lParam ) + 1
                  IF Len ( _HMG_aControlHeadClick [i] ) >= lvc
                     _DoControlEventProcedure ( _HMG_aControlHeadClick [i] [lvc] , i , , lvc )
                     RETURN 0
                  ENDIF
               ENDIF
            ENDIF

         // Grid Click ...........................

            IF GetNotifyCode ( lParam ) == NM_CLICK

               IF _HMG_aControlFontColor [i] == .T.
                  aCellData := _GetGridCellData ( i )
                  IF ( NewPos := aCellData [2] ) > 0
                     x := _HMG_aControlMiscData1 [i] [ 17 ]
                     _HMG_aControlMiscData1 [i] [ 17 ] := NewPos
                     IF ( nGridRowValue := _HMG_aControlMiscData1 [i] [ 1 ] ) == 0
                        _HMG_aControlMiscData1 [i] [ 1 ] := aCellData [1]
                     ENDIF

                     IF lCellGridRowChanged .OR. x != NewPos
                        lCellGridRowChanged := .F.
                        LISTVIEW_REDRAWITEMS ( _HMG_aControlHandles [i] , nGridRowValue - 1 , nGridRowValue - 1 )
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
                     ENDIF
                  ENDIF
               ENDIF

            ENDIF

         // Grid Double Click ...........................

            IF GetNotifyCode ( lParam ) == NM_DBLCLK

               IF _hmg_aControlSpacing [i] == .T.

                  IF _HMG_aControlMiscData1 [i] [20] == .T. .OR. _HMG_aControlFontColor [i] == .T.

                     _PushEventInfo()
                     _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
                     _HMG_ThisType := 'C'
                     _HMG_ThisIndex := i
                     _HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ]
                     _HMG_ThisControlName :=  _HMG_aControlNames [_HMG_ThisIndex]
                     aCellData := _GetGridCellData( i )

                     _HMG_ThisItemRowIndex := aCellData [1]
                     _HMG_ThisItemColIndex := aCellData [2]
                     _HMG_ThisItemCellRow := aCellData [3]
                     _HMG_ThisItemCellCol := aCellData [4]
                     _HMG_ThisItemCellWidth := aCellData [5]
                     _HMG_ThisItemCellHeight := aCellData [6]

                     _GridInplaceEdit( i )

                     _PopEventInfo()
                     _HMG_ThisItemRowIndex := 0
                     _HMG_ThisItemColIndex := 0
                     _HMG_ThisItemCellRow := 0
                     _HMG_ThisItemCellCol := 0
                     _HMG_ThisItemCellWidth := 0
                     _HMG_ThisItemCellHeight := 0

                  ELSE
                     _EditItem ( _hmg_acontrolhandles [i] )
                  ENDIF

               ELSE

                  IF ValType( _HMG_aControlDblClick [i]  ) == 'B'

                     _PushEventInfo()
                     _HMG_ThisFormIndex := AScan ( _HMG_aFormHandles , _HMG_aControlParentHandles[i] )
                     _HMG_ThisType := 'C'
                     _HMG_ThisIndex := i
                     _HMG_ThisFormName :=  _HMG_aFormNames [ _HMG_ThisFormIndex ]
                     _HMG_ThisControlName :=  _HMG_aControlNames [_HMG_ThisIndex]
                     aCellData := _GetGridCellData( i )

                     _HMG_ThisItemRowIndex := aCellData [1]
                     _HMG_ThisItemColIndex := aCellData [2]
                     _HMG_ThisItemCellRow := aCellData [3]
                     _HMG_ThisItemCellCol := aCellData [4]
                     _HMG_ThisItemCellWidth := aCellData [5]
                     _HMG_ThisItemCellHeight := aCellData [6]

                     Eval( _HMG_aControlDblClick [i]  )

                     _PopEventInfo()
                     _HMG_ThisItemRowIndex := 0
                     _HMG_ThisItemColIndex := 0
                     _HMG_ThisItemCellRow := 0
                     _HMG_ThisItemCellCol := 0
                     _HMG_ThisItemCellWidth := 0
                     _HMG_ThisItemCellHeight := 0

                  ENDIF

               ENDIF
               RETURN 0

            ENDIF

         ENDIF

      // DatePicker Process ..................................

         IF _HMG_aControlType [i] == "DATEPICK" .OR. _HMG_aControlType [i] == "TIMEPICK"

         // DatePicker Change ............................

            IF GetNotifyCode ( lParam ) == DTN_DATETIMECHANGE .AND. SendMessage( _HMG_aControlHandles [i] , DTM_GETMONTHCAL , 0 , 0 ) == 0 .OR. GetNotifyCode ( lParam ) == DTN_CLOSEUP
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
               RETURN 0
            ENDIF

         // DatePicker LostFocus ........................

            IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // DatePicker GotFocus .........................

            IF GetNotifyCode ( lParam ) == NM_SETFOCUS
               VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         ENDIF

      // Tab Processing ......................................

         IF _HMG_aControlType [i] == "TAB"

         // Tab Change ..................................

            IF GetNotifyCode ( lParam ) == TCN_SELCHANGING
               nOldPage := _GetValue( , , i )
               RETURN 0
            ELSEIF GetNotifyCode ( lParam ) == TCN_SELCHANGE
               IF Len ( _HMG_aControlPageMap [i] ) > 0
                  IF ! _HMG_ProgrammaticChange
                     UpdateTab ( i )
                     _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
                  ELSEIF ! ISBLOCK( _HMG_aControlChangeProcedure [i] ) .OR. ;
                        _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' , nOldPage )
                     UpdateTab ( i )
                  ELSE
                     TabCtrl_SetCurSel ( _HMG_aControlHandles [i] , nOldPage )
                  ENDIF
               ENDIF
               RETURN 0
            ENDIF

         ENDIF

      // Tree Processing .....................................

         IF _HMG_aControlType [i] == "TREE"

         // Tree LostFocus .............................

            IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // Tree GotFocus ..............................

            IF GetNotifyCode ( lParam ) == NM_SETFOCUS
               VirtualChildControlFocusProcess ( _HMG_aControlHandles [i] , _HMG_aControlParentHandles [i] )
               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // Tree Change ................................

            IF GetNotifyCode ( lParam ) == TVN_SELCHANGED
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
               RETURN 0
            ENDIF

         // Tree Double Click .........................

            IF GetNotifyCode ( lParam ) == NM_DBLCLK
               _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
               RETURN 0
            ENDIF

         ENDIF

#ifdef _TSBROWSE_
         IF _HMG_aControlType [i] == "TOOLBAR"

            IF GetNotifyCode ( lParam ) == TBN_QUERYINSERT .OR. ;
               GetNotifyCode ( lParam ) == TBN_QUERYDELETE
               RETURN 1
            ENDIF
            IF GetNotifyCode ( lParam ) == TBN_DELETINGBUTTON
                RETURN 1
            ENDIF
            IF GetNotifyCode ( lParam ) == TBN_INITCUSTOMIZE
               RETURN TBNRF_HIDEHELP
            ENDIF

            RETURN iif( ToolBarExCustFunc ( hWnd, nMsg, wParam, lParam ), 1, 0 )

         ENDIF
#endif

#ifdef _PROPGRID_
      // PropGrid Processing ...............................

         IF _HMG_aControlType [i] == "PROPGRID"

         // PropGrid LostFocus .............................

            IF GetNotifyCode ( lParam ) == NM_KILLFOCUS
               _DoControlEventProcedure ( _HMG_aControlLostFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // PropGrid GotFocus ..............................

            IF GetNotifyCode ( lParam ) == NM_SETFOCUS
               _DoControlEventProcedure ( _HMG_aControlGotFocusProcedure [i] , i )
               RETURN 0
            ENDIF

         // PropGrid Double Click ..........................

            IF GetNotifyCode ( lParam ) == NM_DBLCLK
               _DoControlEventProcedure ( _HMG_aControlDblClick [i] , i )
               RETURN 0
            ENDIF

         // PropGrid Change ................................

            IF GetNotifyCode ( lParam ) == TVN_SELCHANGED
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i , 'CONTROL_ONCHANGE' )
               RETURN 0
            ENDIF

            IF GetNotifyCode ( lParam ) == - 181
               ReDrawWindow ( _hmg_acontrolhandles [i] )
            ENDIF

         ENDIF
#endif
      // StatusBar Processing ..............................

         IF _HMG_aControlType [i] == "MESSAGEBAR"

            IF GetNotifyCode ( lParam ) == NM_CLICK  // StatusBar Click

               DefWindowProc( hWnd, NM_CLICK, wParam, lParam )

               x := GetItemPos( lParam ) + 1

               FOR EACH r IN _HMG_aControlHandles

                  i := hb_enumindex( r )

                  IF _HMG_aControlType [i] == "ITEMMESSAGE" .AND. _HMG_aControlParentHandles [i] == hWnd

                     IF r == x
                        IF _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )
                           RETURN 0
                        ENDIF
                     ENDIF

                  ENDIF

               NEXT

            ENDIF

         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_NCACTIVATE
   //**********************************************************************

      IF _HMG_IsXPorLater .AND. wParam == 0 .AND. lParam == 0
         IF _HMG_InplaceParentHandle <> 0
            InsertReturn ()
         ENDIF
      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_QUERYENDSESSION
   //**********************************************************************

      __Quit()
      EXIT
   //**********************************************************************
   CASE WM_CLOSE
   //**********************************************************************

#ifdef _TSBROWSE_
      oGet := GetObjectByHandle( hWnd )
      IF GetEscapeState() < 0 .AND. ( 'EDIT' $ _GetFocusedControlType( hWnd ) .OR. iif( ISOBJECT( oGet ), 'Edit' $ oGet:cChildControl, .F. ) )
#else
      IF GetEscapeState() < 0 .AND. 'EDIT' $ _GetFocusedControlType( hWnd )
#endif
         RETURN ( 1 )
      ENDIF

      i := AScan ( _HMG_aFormHandles , hWnd )

      IF i > 0

      // Process Interactive Close Event / Setting
         IF ValType ( _HMG_aFormInteractiveCloseProcedure [i] ) == 'B'
            r := _DoWindowEventProcedure ( _HMG_aFormInteractiveCloseProcedure [i] , i , 'WINDOW_ONINTERACTIVECLOSE' )
            IF ValType ( r ) == 'L' .AND. r == .F.
               RETURN ( 1 )
            ENDIF
         ENDIF

         IF lParam <> 1
            SWITCH _HMG_InteractiveClose
            CASE 0
               MsgStop ( _HMG_MESSAGE [3] )
               RETURN ( 1 )
            CASE 2
               IF ! MsgYesNo ( _HMG_MESSAGE [1] , _HMG_MESSAGE [2] )
                  RETURN ( 1 )
               ENDIF
               EXIT
            CASE 3
               IF _HMG_aFormType [i] == 'A'
                  IF ! MsgYesNo ( _HMG_MESSAGE [1] , _HMG_MESSAGE [2] )
                     RETURN ( 1 )
                  ENDIF
               ENDIF
            END SWITCH
         ENDIF

      // Process AutoRelease Property
         IF _HMG_aFormAutoRelease [i] == .F.
            _HideWindow ( _HMG_aFormNames [i] )
            RETURN ( 1 )
         ENDIF

      // If Not AutoRelease Destroy Window
         IF _HMG_aFormType [i] == 'A'
            ReleaseAllWindows()
         ELSE
            IF ValType( _HMG_aFormReleaseProcedure [i] ) == 'B'
               _HMG_InteractiveCloseStarted := .T.
               _DoWindowEventProcedure ( _HMG_aFormReleaseProcedure [i] , i , 'WINDOW_RELEASE' )
            ENDIF
            _hmg_OnHideFocusManagement ( i )
         ENDIF

      ENDIF
      EXIT
   //**********************************************************************
   CASE WM_DESTROY
   //**********************************************************************

      i := AScan ( _HMG_aFormHandles , hWnd )

      IF i > 0

      // Remove Child Controls

         FOR EACH r IN _HMG_aControlParentHandles
            IF r == hWnd
               _EraseControl ( hb_enumindex( r ) , i )
            ENDIF
         NEXT

      // Delete Brush

         DeleteObject ( _HMG_aFormBrushHandle [i] )

      // Delete ToolTip

         ReleaseControl ( _HMG_aFormToolTipHandle [i] )

      // Update/Release Form Index Variable

         mVar := '_' + _HMG_aFormNames [i]
         IF __mvExist ( mVar )
#ifndef _PUBLIC_RELEASE_
            __mvPut ( mVar , 0 )
#else
            __mvXRelease ( mVar )
#endif
         ENDIF

      // If Window was Multi-activated, determine If it is a Last one.
      // If Yes, then post Quit message to finish the Message Loop.

      // Quit Message, will be posted always for single activated windows.

         IF _HMG_aFormActivateId [i] > 0

            TmpStr := '_HMG_ACTIVATE_' + hb_ntos ( _HMG_aFormActivateId [i] )

            IF __mvExist ( TmpStr )

               Tmp := __mvGet ( TmpStr )

               IF ValType ( Tmp ) == 'N'

                  __mvPut ( TmpStr , --Tmp )

                  IF Tmp == 0
                     PostQuitMessage ( 0 )
                     __mvXRelease ( TmpStr )
                  ENDIF

               ENDIF

            ENDIF

         ELSE

            PostQuitMessage( 0 )

         ENDIF

         _HMG_aFormDeleted             [i] := .T.
         _HMG_aFormhandles             [i] := 0
         _HMG_aFormNames               [i] := ""
         _HMG_aFormActive              [i] := .F.
         _HMG_aFormType                [i] := ""
         _HMG_aFormParenthandle        [i] := 0
         _HMG_aFormInitProcedure       [i] := ""
         _HMG_aFormReleaseProcedure    [i] := ""
         _HMG_aFormToolTipHandle       [i] := 0
         _HMG_aFormContextMenuHandle   [i] := 0
         _HMG_aFormMouseDragProcedure  [i] := ""
         _HMG_aFormSizeProcedure       [i] := ""
         _HMG_aFormClickProcedure      [i] := ""
         _HMG_aFormMouseMoveProcedure  [i] := ""
         _HMG_aFormMoveProcedure       [i] := ""
         _HMG_aFormDropProcedure       [i] := ""
         _HMG_aFormBkColor             [i] := Nil
         _HMG_aFormPaintProcedure      [i] := ""
         _HMG_aFormNoShow              [i] := .F.
         _HMG_aFormNotifyIconName      [i] := ''
         _HMG_aFormNotifyIconToolTip   [i] := ''
         _HMG_aFormNotifyIconLeftClick [i] := ''
         _HMG_aFormNotifyIconDblClick  [i] := ''
         _HMG_aFormReBarHandle         [i] := 0
         _HMG_aFormNotifyMenuHandle    [i] := 0
         _HMG_aFormBrowseList          [i] := {}
         _HMG_aFormSplitChildList      [i] := {}
         _HMG_aFormVirtualHeight       [i] := 0
         _HMG_aFormGotFocusProcedure   [i] := ""
         _HMG_aFormLostFocusProcedure  [i] := ""
         _HMG_aFormVirtualWidth        [i] := 0
         _HMG_aFormFocused             [i] := .F.
         _HMG_aFormScrollUp            [i] := ""
         _HMG_aFormScrollDown          [i] := ""
         _HMG_aFormScrollLeft          [i] := ""
         _HMG_aFormScrollRight         [i] := ""
         _HMG_aFormHScrollBox          [i] := ""
         _HMG_aFormVScrollBox          [i] := ""
         _HMG_aFormBrushHandle         [i] := 0
         _HMG_aFormFocusedControl      [i] := 0
         _HMG_aFormGraphTasks          [i] := {}
         _HMG_aFormMaximizeProcedure   [i] := Nil
         _HMG_aFormMinimizeProcedure   [i] := Nil
         _HMG_aFormRestoreProcedure    [i] := Nil
         _HMG_aFormAutoRelease         [i] := .F.
         _HMG_aFormInteractiveCloseProcedure [i] := ""
         _HMG_aFormMinMaxInfo          [i] := {}
         _HMG_aFormActivateId          [i] := 0

         _HMG_InteractiveCloseStarted := .F.

      ENDIF
      EXIT
   //**********************************************************************
#ifndef __XHARBOUR__
   OTHERWISE
#else
   DEFAULT
#endif
   //**********************************************************************
      IF nMsg == _HMG_ListBoxDragNotification

         SWITCH GET_DRAG_LIST_NOTIFICATION_CODE( lParam )

         CASE DL_BEGINDRAG
            // Original Item
            _HMG_ListBoxDragItem := GET_DRAG_LIST_DRAGITEM( lParam )
            RETURN 1

         CASE DL_DRAGGING
            // Current Item
            _HMG_ListBoxDragListId := GET_DRAG_LIST_DRAGITEM( lParam )

            IF _HMG_ListBoxDragListId > _HMG_ListBoxDragItem
               DRAG_LIST_DRAWINSERT( hWnd, lParam, _HMG_ListBoxDragListId + 1 )
            ELSE
               DRAG_LIST_DRAWINSERT( hWnd, lParam, _HMG_ListBoxDragListId )
            ENDIF

            IF _HMG_ListBoxDragListId <> -1

               IF _HMG_ListBoxDragListId > _HMG_ListBoxDragItem
                  SetResCursor( LoadCursor( GetInstance(), "MINIGUI_DRAGDOWN" ) )
               ELSE
                  SetResCursor( LoadCursor( GetInstance(), "MINIGUI_DRAGUP" ) )
               ENDIF

               RETURN 0

            ENDIF

            RETURN DL_STOPCURSOR

         CASE DL_CANCELDRAG
            _HMG_ListBoxDragItem := -1
            EXIT

         CASE DL_DROPPED
            _HMG_ListBoxDragListId := GET_DRAG_LIST_DRAGITEM( lParam )

            IF _HMG_ListBoxDragListId <> -1
               DRAG_LIST_MOVE_ITEMS( lParam, _HMG_ListBoxDragItem, _HMG_ListBoxDragListId )
            ENDIF

            DRAG_LIST_DRAWINSERT( hWnd, lParam, -1 )

            _HMG_ListBoxDragItem := -1

         END SWITCH

      ENDIF

   END SWITCH

RETURN ( 0 )

*-----------------------------------------------------------------------------*
PROCEDURE _SetNextFocus( lSkip )
*-----------------------------------------------------------------------------*
   LOCAL NextControlHandle, lShift, i, hWnd
   LOCAL lMdiChildActive := ( _HMG_BeginWindowMDIActive .AND. !_HMG_IsModalActive )

   hWnd := iif( lMdiChildActive , GetActiveMdiHandle() , GetActiveWindow() )
   NextControlHandle := GetNextDlgTabITem ( hWnd , GetFocus() , hb_defaultValue( lSkip, .F. ) )
   lShift := CheckBit ( GetKeyState( VK_SHIFT ), 32768 )  // Is Shift key pressed ?

   i := AScan ( _HMG_aControlHandles , NextControlHandle )
   IF i > 0
      IF _HMG_aControlType [i] == 'BUTTON' .OR. lMdiChildActive
         SetFocus( NextControlHandle )
         IF lMdiChildActive .AND. ( i := AScan ( _HMG_aFormHandles , hWnd ) ) > 0
            _HMG_aFormFocusedControl [i] := NextControlHandle
         ELSE
            SendMessage ( NextControlHandle , BM_SETSTYLE , LOWORD ( BS_DEFPUSHBUTTON ) , 1 )
         ENDIF
      ELSE
         iif( lshift , InsertShiftTab() , InsertTab() )
      ENDIF
   ELSEIF ! lMdiChildActive
      iif( lshift , InsertShiftTab() , InsertTab() )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _PushEventInfo
*-----------------------------------------------------------------------------*
   AAdd ( _HMG_aEventInfo , { _HMG_ThisFormIndex , _HMG_ThisEventType , _HMG_ThisType , _HMG_ThisIndex , _HMG_ThisFormName , _HMG_ThisControlName } )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _PopEventInfo
*-----------------------------------------------------------------------------*
   LOCAL l := Len ( _HMG_aEventInfo )

   IF l > 0

      _HMG_ThisFormIndex   := _HMG_aEventInfo [l] [1]
      _HMG_ThisEventType   := _HMG_aEventInfo [l] [2]
      _HMG_ThisType        := _HMG_aEventInfo [l] [3]
      _HMG_ThisIndex       := _HMG_aEventInfo [l] [4]
      _HMG_ThisFormName    := _HMG_aEventInfo [l] [5]
      _HMG_ThisControlName := _HMG_aEventInfo [l] [6]

      ASize ( _HMG_aEventInfo , l - 1 )

   ELSE

      _HMG_ThisIndex := 0
      _HMG_ThisFormIndex := 0
      _HMG_ThisType := ''
      _HMG_ThisEventType := ''
      _HMG_ThisFormName :=  ''
      _HMG_ThisControlName := ''

   ENDIF

RETURN

#ifdef _TSBROWSE_
*-----------------------------------------------------------------------------*
FUNCTION GetObjectByHandle( hWnd )
*-----------------------------------------------------------------------------*
   LOCAL oWnd, nPos

   IF Type( '_TSB_aControlhWnd' ) == 'A' .AND. Len( _TSB_aControlhWnd ) > 0
      IF ( nPos := AScan( _TSB_aControlhWnd, hWnd ) ) > 0
         oWnd := _TSB_aControlObjects [nPos]
      ENDIF
   ENDIF

RETURN oWnd
#endif

#ifdef _USERINIT_
*-----------------------------------------------------------------------------*
PROCEDURE InstallEventHandler ( cProcedure )
*-----------------------------------------------------------------------------*
   AAdd ( _HMG_aCustomEventProcedure , AllTrim ( Upper ( NoBrackets ( cProcedure ) ) ) )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE InstallPropertyHandler ( cPropertyName , cSetProcedure , cGetProcedure )
*-----------------------------------------------------------------------------*
   AAdd ( _HMG_aCustomPropertyProcedure , { AllTrim ( Upper ( cPropertyName ) ) , AllTrim ( Upper ( cSetProcedure ) ) , AllTrim ( Upper ( cGetProcedure ) ) } )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE InstallMethodHandler ( cEventName , cMethodProcedure )
*-----------------------------------------------------------------------------*
   AAdd ( _HMG_aCustomMethodProcedure , { AllTrim ( Upper ( cEventName ) ) , AllTrim ( Upper ( cMethodProcedure ) ) } )

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION NoBrackets ( cStr )
*-----------------------------------------------------------------------------*
   LOCAL nPos

   IF ( nPos := At ( '(', cStr ) ) > 0
      RETURN Left ( cStr, nPos - 1 )
   ENDIF

RETURN cStr
#endif

*------------------------------------------------------------------------------*
STATIC FUNCTION GetMenuItems ( lMenuItem, hMenu )
*------------------------------------------------------------------------------*
   LOCAL i, aMenuItems := {}
   LOCAL cMenuType := iif( lMenuItem, "MENU", "POPUP" )
   LOCAL nControlCount := Len ( _HMG_aControlHandles )

   FOR i := 1 TO nControlCount
      IF _HMG_aControlType [i] == cMenuType .AND. _HMG_aControlPageMap [i] == hMenu .AND. iif( lMenuItem, .T., ( _HMG_aControlIds [i] == 1 ) )
         AAdd( aMenuItems, _HMG_aControlCaption [i] )
      ENDIF
   NEXT i

RETURN aMenuItems

#define DT_VCENTER       0x00000004
#define DT_SINGLELINE    0x00000020
*-----------------------------------------------------------------------------*
STATIC PROCEDURE _OnDrawStatusItem ( hWnd, lParam )
*-----------------------------------------------------------------------------*
   LOCAL hDC, aRect, nItem, hBrush, oldBkMode
   LOCAL i, h, nIndex := 0

   hDC := GETOWNBTNDC( lParam )
   aRect := GETOWNBTNRECT( lParam )
   nItem := GETOWNBTNITEMID( lParam )

   FOR EACH h IN _HMG_aControlParentHandles

      i := hb_enumindex( h )

      IF _HMG_aControlType [i] == "ITEMMESSAGE" .AND. h == hWnd

         IF nIndex++ == nItem
            oldBkMode := SetBkMode( hDC, TRANSPARENT )
            IF _HMG_aControlBkColor [i] != Nil
               hBrush := CreateSolidBrush( _HMG_aControlBkColor [i] [1], _HMG_aControlBkColor [i] [2], _HMG_aControlBkColor [i] [3] )
               FillRect( hDC, aRect [1], aRect [2], aRect [3], aRect [4], hBrush )
               DeleteObject( hBrush )
            ENDIF
            IF _HMG_aControlFontColor [i] != Nil
               SetTextColor( hDC, _HMG_aControlFontColor [i] [1], _HMG_aControlFontColor [i] [2], _HMG_aControlFontColor [i] [3] )
            ENDIF
            DrawText( hDC, _HMG_aControlCaption [i], aRect [1] + 1, aRect [2], aRect [3] - 1, aRect [4], hb_BitOr( _HMG_aControlSpacing [i], DT_SINGLELINE, DT_VCENTER ) )
            SetBkMode( hDC, oldBkMode )
            EXIT
         ENDIF

      ENDIF

   NEXT

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION _OnGetMinMaxInfo ( hWnd, pMinMaxInfo )
*-----------------------------------------------------------------------------*
   LOCAL i := AScan ( _HMG_aFormhandles, hWnd ), nRet := 0

   IF i > 0
      IF Len ( _HMG_aFormMinMaxInfo [i] ) > 0
         nRet := SetMinMaxInfo ( pMinMaxInfo, _HMG_aFormMinMaxInfo [i] )
      ENDIF
   ENDIF

RETURN nRet

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _MouseCoordCorr ( hWnd, i )
*-----------------------------------------------------------------------------*
   IF _hmg_aformvirtualheight [i] > 0
      _HMG_MouseRow += GetScrollPos( hWnd, SB_VERT )
   ENDIF

   IF _hmg_aformvirtualwidth [i] > 0
      _HMG_MouseCol += GetScrollPos( hWnd, SB_HORZ )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _ProcessSliderEvents ( lParam, wParam )
*-----------------------------------------------------------------------------*
   LOCAL i
   STATIC lOnChangeEvent := .F., lOnScrollEvent := .F.

   i := AScan ( _HMG_aControlHandles , lParam )

   IF i > 0

      IF _HMG_aControlType [i] == 'SLIDER'

         SWITCH LoWord ( wParam )

         CASE TB_ENDTRACK
            IF lOnScrollEvent
               lOnScrollEvent := .F.
            ELSE
               lOnChangeEvent := .T.
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
            ENDIF
            EXIT
         CASE TB_THUMBPOSITION
            IF lOnChangeEvent
               lOnChangeEvent := .F.
            ELSE
               lOnScrollEvent := .T.
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [i] , i )
            ENDIF
            EXIT
         CASE TB_THUMBTRACK
         CASE TB_LINEUP
         CASE TB_LINEDOWN
         CASE TB_PAGEUP
         CASE TB_PAGEDOWN
            _DoControlEventProcedure ( _HMG_aControlProcedures [i] , i )

         END SWITCH

      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE DoComboAutoComplete ( i )
*-----------------------------------------------------------------------------*
   LOCAL hWnd := _HMG_aControlHandles [i]
   LOCAL cValue := GetWindowText( _HMG_aControlRangeMin [i] )
   LOCAL nStart := Len( cValue )
   LOCAL lShowDropDown := _HMG_aControlMiscData1 [i][8]
   LOCAL nPos := _HMG_aControlMiscData1 [i][9]

   IF nPos > 0

      IF nStart == nPos

         IF nStart > 1

            cValue := SubStr( cValue, 1, nStart - 1 )

         ELSE

            IF ComboFindString( hWnd, cValue ) > 0

               ComboSelectString( hWnd, cValue )
               ComboEditSetSel( hWnd, 0, -1 )
               _HMG_aControlMiscData1 [i][9] := 0

               RETURN

            ENDIF

         ENDIF

      ENDIF

   ENDIF

   _HMG_aControlMiscData1 [i][9] := nStart

   IF hWnd > 0

      IF lShowDropDown
         ComboShowDropDown( hWnd )
      ENDIF

      IF ComboFindString( hWnd, cValue ) > 0

         ComboSelectString( hWnd, cValue )
         ComboEditSetSel( hWnd, nStart, -1 )

      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _AutoAdjust ( hWnd, aInitSize )
*-----------------------------------------------------------------------------*
   LOCAL i, k, ParentForm, ControlCount, ControlName, ControlType
   LOCAL nDivw, nDivh, nDivw2, nDivh2
   LOCAL lAutoZooming := ( _HMG_AutoZooming == .T. )
   LOCAL cControlExcept := "IMAGE"
   LOCAL lInvisible := .T.
   LOCAL nWidth, nHeight
#ifdef _TSBROWSE_
   LOCAL oBrw
#endif

   nWidth := iif( GetDesktopWidth() < GetWindowWidth( hWnd ), GetDesktopWidth(), GetWindowWidth( hWnd ) )
   nHeight := iif( GetDesktopHeight() < GetWindowHeight( hWnd ), GetDesktopHeight(), GetWindowHeight( hWnd ) )

   IF IsWindowVisible( hWnd ) .AND. ! IsAppXPThemed()
      HideWindow( hWnd )
   ELSE
      lInvisible := .F.
   ENDIF

   i := AScan( _HMG_aFormHandles , hWnd )
   ParentForm := _HMG_aFormNames [i]

   IF ISARRAY( aInitSize )
      _HMG_aFormVirtualWidth  [i] := aInitSize [1]
      _HMG_aFormVirtualHeight [i] := aInitSize [2]
   ENDIF

   IF _HMG_aFormVirtualWidth [i] > 0 .AND. _HMG_aFormVirtualHeight [i] > 0
      nDivw := nWidth / _HMG_aFormVirtualWidth [i]
      nDivh := nHeight / _HMG_aFormVirtualHeight [i]
   ELSE
      nDivw := 1
      nDivh := 1
   ENDIF

   IF lAutoZooming
      nDivw2 := nDivw
      nDivh2 := nDivh
   ELSEIF _HMG_AutoAdjustException == .T.
      cControlExcept += ",OBUTTON,CHECKBOX"
   ENDIF

   ControlCount := Len( _HMG_aControlHandles )

   FOR k := 1 TO ControlCount

      IF _HMG_aControlParentHandles [k] == hWnd

         ControlName := _HMG_aControlNames [k]
         ControlType := _HMG_aControlType [k]

         IF !Empty( ControlName ) .AND. !( ControlType $ "MENU,HOTKEY,TOOLBAR,MESSAGEBAR,ITEMMESSAGE,TIMER" ) .AND. ;
            Empty( GetControlContainerHandle( ControlName, ParentForm ) )

            IF ControlType == "RADIOGROUP"
               _HMG_aControlSpacing [k] := _HMG_aControlSpacing [k] * iif( _HMG_aControlMiscData1 [k], nDivw, nDivh )
            ENDIF

            IF ! lAutoZooming
               DO CASE
               CASE ControlType $ cControlExcept .OR. "PICK" $ ControlType
                  nDivw2 := 1
                  nDivh2 := 1
               CASE "TEXT" $ ControlType .OR. "LABEL" $ ControlType .OR. ControlType $ "GETBOX,SPINNER,HYPERLINK,PROGRESSBAR,COMBO,HOTKEYBOX"
                  nDivw2 := nDivw
                  nDivh2 := 1
               OTHERWISE
                  nDivw2 := nDivw
                  nDivh2 := nDivh
               ENDCASE
            ENDIF

            _SetControlSizePos( ControlName, ParentForm, ;
               _GetControlRow( ControlName, ParentForm ) * nDivh, _GetControlCol( ControlName, ParentForm ) * nDivw, ;
               _GetControlWidth( ControlName, ParentForm ) * nDivw2, _GetControlHeight( ControlName, ParentForm ) * nDivh2 )

#ifdef _TSBROWSE_
            IF ControlType == "TBROWSE"
               oBrw := _HMG_aControlIds [k]
               IF oBrw:lIsDbf
                  oBrw:UpStable()
               ELSE
                  oBrw:Refresh( .T. )
                  oBrw:DrawSelect()
               ENDIF
            ELSEIF lAutoZooming .AND. ControlType <> "SLIDER"
#else
               IF lAutoZooming .AND. ControlType <> "SLIDER"
#endif
                  _SetFontSize( ControlName, ParentForm, _HMG_aControlFontSize [k] * nDivh )
               ENDIF

            ENDIF

         ENDIF

   NEXT k

   _HMG_aFormVirtualWidth  [i] := nWidth
   _HMG_aFormVirtualHeight [i] := nHeight

   IF lInvisible
      ShowWindow( hWnd )
   ENDIF

RETURN
