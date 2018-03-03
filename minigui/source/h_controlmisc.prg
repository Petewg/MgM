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
   Copyright 1999-2017, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "i_winuser.ch"

#define WM_SETREDRAW      0x0b
#define ESB_ENABLE_BOTH   0x0000
#define ESB_DISABLE_BOTH  0x0003
#define EM_SETCUEBANNER   0x1501
#define CB_SETCUEBANNER   0x1703

#ifndef __XHARBOUR__
   /* FOR EACH hb_enumIndex() */
   #xtranslate hb_enumIndex( <!v!> ) => <v>:__enumIndex()
#endif
MEMVAR aResult
*-----------------------------------------------------------------------------*
FUNCTION _GetValue ( ControlName, ParentForm, Index )
*-----------------------------------------------------------------------------*
   LOCAL t , x , c , ix , oGet , auxval , WorkArea , BackRec , Tmp , Ts
   LOCAL retval As Numeric , rcount As Numeric

   IF PCount() == 2
      IF Upper ( ControlName ) == 'VSCROLLBAR'
         RETURN GetScrollPos ( GetFormHandle ( ParentForm ) , SB_VERT )
      ELSEIF Upper ( ControlName ) == 'HSCROLLBAR'
         RETURN GetScrollPos ( GetFormHandle ( ParentForm ) , SB_HORZ )
      ENDIF
      T := GetControlType ( ControlName, ParentForm )
      c := GetControlHandle ( ControlName, ParentForm )
      ix := GetControlIndex ( ControlName, ParentForm )
   ELSE
      T := _HMG_aControlType [ Index ]
      c := _HMG_aControlHandles [ Index ]
      ix := Index
   ENDIF

   DO CASE
#ifdef _DBFBROWSE_
   CASE T == "BROWSE"
      retval := _BrowseGetValue ( '' , '' , ix )
#endif
   CASE T == "PROGRESSBAR"
      retval := SendMessage ( c, PBM_GETPOS, 0, 0 )

   CASE T == "IPADDRESS"
      retval := GetIPAddress ( c )

   CASE T == "MONTHCAL"
      retval := hb_Date( GetMonthCalYear ( c ), GetMonthCalMonth ( c ), GetMonthCalDay ( c ) )

   CASE T == "TREE"
      retval := iif( _HMG_aControlInputMask [ix] == .F. , AScan ( _HMG_aControlPageMap [ix] , TreeView_GetSelection ( c ) ), TreeView_GetSelectionId ( c ) )

   CASE T == "MASKEDTEXT"
      IF "E" $ _HMG_aControlPageMap [ix]
         Ts := GetWindowText ( c )

         IF "." $ _HMG_aControlPageMap [ix]
            DO CASE
            CASE At ( '.' , Ts ) >  At ( ',' , Ts )
               retval := GetNumFromText ( GetWindowText ( c ) , ix )
            CASE At ( ',' , Ts ) > At ( '.' , Ts )
               retval := GetNumFromTextSp ( GetWindowText ( c ) , ix )
            ENDCASE
         ELSE
            DO CASE
            CASE At ( '.' , Ts ) != 0
               retval := GetNumFromTextSp ( GetWindowText ( c ) , ix )
            CASE At ( ',' , Ts ) != 0
               retval := GetNumFromText ( GetWindowText ( c ) , ix )
            OTHERWISE
               retval := GetNumFromText ( GetWindowText ( c ) , ix )
            ENDCASE
         ENDIF

      ELSE

         retval := GetNumFromText ( GetWindowText ( c ) , ix )

      ENDIF

   CASE T == "CHECKLABEL"
      retval := GetChkLabel( c )

   CASE T == "TEXT" .OR. T == "BTNTEXT" .OR. T == "EDIT" .OR. "LABEL" $ T .OR. T == "HYPERLINK" .OR. T == "CHARMASKTEXT" .OR. T == "RICHEDIT"
      IF t == "CHARMASKTEXT"
         IF ValType ( _HMG_aControlHeadCLick [ix] ) == 'L'
            IF _HMG_aControlHeadCLick [ix] == .T.
               retval := CToD ( AllTrim ( GetWindowText ( c ) ) )
            ELSE
               retval := GetWindowText ( c )
            ENDIF
         ELSE
            retval := GetWindowText ( c )
         ENDIF
      ELSE
         retval := GetWindowText ( c )
      ENDIF

   CASE "NUMTEXT" $ T
      retval := Int ( Val( GetWindowText( c ) ) )

   CASE T == "SPINNER"
      retval := GetSpinnerValue ( c [2] )

   CASE T == "CHECKBOX"
      auxval := SendMessage ( c , BM_GETCHECK , 0 , 0 )

      SWITCH auxval
      CASE BST_CHECKED
         retval := .T.
         EXIT
      CASE BST_UNCHECKED
         retval := .F.
         EXIT
      CASE BST_INDETERMINATE
         retval := Nil
      ENDSWITCH

   CASE T == "RADIOGROUP"
      FOR EACH x IN c
         auxval := SendMessage( x , BM_GETCHECK , 0 , 0 )
         IF auxval == BST_CHECKED
            retval := hb_enumindex( x )
            EXIT
         ENDIF
      NEXT

   CASE T == "COMBO"
      IF ValType ( _HMG_aControlSpacing [ix] ) == 'C'
         auxval := ComboGetCursel ( c )
         WorkArea := _HMG_aControlSpacing [ix]
         BackRec := ( WorkArea )->( RecNo() )
         ( WorkArea )->( dbGoTop() )
         DO WHILE ! ( WorkArea )->( EOF() )
            IF ++rcount == auxval
               IF Empty ( _HMG_aControlCaption [ix] )
                  RetVal := ( WorkArea )->( RecNo() )
               ELSE
                  Tmp := _HMG_aControlCaption [ix]
                  RetVal := &Tmp
               ENDIF
            ENDIF
            ( WorkArea )->( dbSkip() )
         ENDDO
         ( WorkArea )->( dbGoto( BackRec ) )
      ELSE
         retval := ComboGetCursel ( c )
      ENDIF

   CASE T == "LIST" .OR. T == "CHKLIST"
      retval := ListBoxGetCursel ( c )

   CASE T == "GRID"
      retval := iif( _HMG_aControlFontColor [ix] == .T. , { _HMG_aControlMiscData1 [ix] [ 1 ], _HMG_aControlMiscData1 [ix] [ 17 ] }, ;
         LISTVIEW_GETFIRSTITEM ( c ) )

   CASE T == "TAB"
      retval := TABCTRL_GETCURSEL ( c )

   CASE T == "DATEPICK"
      retval := hb_Date( GetDatePickYear ( c ), GetDatePickMonth ( c ), GetDatePickDay ( c ) )

   CASE T == "TIMEPICK"
      retval := iif( GetDatePickHour ( c ) >= 0, ;
         StrZero( GetDatePickHour ( c ), 2 ) + ":" + StrZero( GetDatePickMinute ( c ), 2 ) + ":" + StrZero( GetDatePickSecond ( c ), 2 ), "" )

   CASE T == "SLIDER"
      retval := SendMessage( c, TBM_GETPOS, 0, 0 )

   CASE T == "MULTILIST" .OR. T == "MULTICHKLIST"
      retval := ListBoxGetMultiSel ( c )

   CASE T == "MULTIGRID"
      retval := ListViewGetMultiSel ( c )

   CASE T == "TOOLBUTTON"
      retval := IsButtonBarChecked( _HMG_aControlContainerHandle [ix] , _HMG_aControlValue [ix] - 1 )

   CASE T == "GETBOX"
      oGet := _HMG_aControlHeadClick [ix]
      retval := oGet:VarGet()

   CASE T == "HOTKEYBOX"
      retval := C_GetHotKey ( c )

   OTHERWISE
      retval := _HMG_aControlValue [ix]

   ENDCASE

RETURN ( retval )

*-----------------------------------------------------------------------------*
FUNCTION _SetValue ( ControlName, ParentForm, Value, index )
*-----------------------------------------------------------------------------*
   LOCAL nValue As Numeric, rcount As Numeric
   LOCAL t , h , c , x , ix , oGet , backrec , workarea , aPos
   LOCAL TreeItemHandle , aTemp , lEqual := .T. , xPreviousValue

   ix := iif ( PCount() == 3, GetControlIndex ( ControlName, ParentForm ), index )

   t := _HMG_aControlType [ix]
   h := _HMG_aControlParentHandles [ix]
   c := _HMG_aControlHandles [ix]

   IF ISARRAY ( Value )

      aTemp := _GetValue ( , , ix )

      IF ISARRAY ( aTemp )

         IF Len( aTemp ) == Len( Value )

            FOR x := 1 TO Len ( Value )
               IF ValType ( aTemp [x] ) == ValType ( Value [x] )
                  IF aTemp [x] <> Value [x]
                     lEqual := .F.
                     EXIT
                  ENDIF
               ELSE
                  lEqual := .F.
                  EXIT
               ENDIF
            NEXT x

            IF lEqual == .T.
               RETURN Nil
            ENDIF

         ENDIF

      ENDIF

   ELSEIF T == "CHECKLABEL"

      IF Value == NIL
         Value := ! GetChkLabel ( c )
      ENDIF

      SetChkLabel ( c , Value )
      RETURN Nil

   ELSEIF !( "LABEL" $ T ) .AND. T != "RICHEDIT"

      xPreviousValue := _GetValue ( , , ix )
      iif( T == "GRID" .AND. ISARRAY ( xPreviousValue ), xPreviousValue := xPreviousValue [1], Nil )

      IF ValType ( xPreviousValue ) == ValType ( Value )
         IF xPreviousValue == Value
            RETURN Nil
         ENDIF
      ENDIF

   ENDIF

   DO CASE
#ifdef _DBFBROWSE_
   CASE T == "BROWSE"
      _BrowseSetValue ( '' , '' , Value , ix )
#endif
   CASE T == "IPADDRESS"
      Value := IFEMPTY( Value, {}, Value )

      IF Len( Value ) == 0
         ClearIpAddress( c )
      ELSE
         SetIPAddress( c , Value [1] , Value [2] , Value [3] , Value [4] )
      ENDIF

   CASE T == "MONTHCAL"
      Value := IFEMPTY( Value, CToD( '' ), Value )
      SetMonthCalValue( c, Year( value ), Month( value ), Day( value ) )

      _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

   CASE T == "TREE"
      IF Empty( Value )
         RETURN Nil
      ENDIF

      IF _HMG_aControlInputMask [ix] == .F.
         IF Value > TreeView_GetCount ( c )
            RETURN Nil
         ENDIF
         TreeItemHandle := _HMG_aControlPageMap [ix] [Value]
      ELSE
         aPos := AScan ( _HMG_aControlPicture [ix] , Value )
         IF aPos == 0
            MsgMiniGuiError ( "Value Property: Invalid TreeItem Reference." )
         ENDIF
         TreeItemHandle := _HMG_aControlPageMap [ix] [aPos]
      ENDIF

      TreeView_SelectItem ( c , TreeItemHandle )

   CASE T == "MASKEDTEXT"
      Value := IFEMPTY( Value, 0, Value )

      IF GetFocus() == c
         SetWindowText ( _HMG_aControlhandles [ix] , Transform ( Value , _HMG_aControlInputMask [ix] ) )
      ELSE
         SetWindowText ( _HMG_aControlhandles [ix] , Transform ( value , _HMG_aControlPageMap [ix] ) )
      ENDIF

   CASE T == "TIMER"
      x := _HMG_aControlIds [ix]
      IF _HMG_aControlEnabled [ix] == .T.
         KillTimer ( _HMG_aControlParentHandles [ix] , x )
      ENDIF

      FOR EACH h IN _HMG_aControlIds
         IF h == x
            IF _HMG_aControlEnabled [ix] == .T.
               InitTimer ( GetFormHandle( ParentForm ) , h , Value )
            ENDIF
            _HMG_aControlValue [ix] := value
            EXIT
         ENDIF
      NEXT

   CASE "LABEL" $ T .OR. T == "HYPERLINK"
      IF Empty( Value )
         value := iif( "LABEL" $ T, iif( ISCHARACTER( Value ), Value, "" ), "@" )
      ENDIF

      IF _HMG_aControlSpacing [ix] == 1
         _SetControlWidth ( ControlName , ParentForm , GetTextWidth( NIL, Value, _HMG_aControlFontHandle [ix] ) + ;
            iif( _HMG_aControlFontAttributes [ix] [1] == .T. .AND. _HMG_IsThemed, GetTextWidth( NIL, " ", _HMG_aControlFontHandle [ix] ), 0 ) ) // Fixed for problem with display bold label at themed WinXP
         _SetControlHeight ( ControlName , ParentForm , _HMG_aControlFontSize [ix] + 16 )
      ENDIF

      SetWindowText ( c , value )

      IF ISLOGICAL ( _HMG_aControlInputMask [ix] )
         IF _HMG_aControlInputMask [ix] == .T.
            RedrawWindowControlRect( h , _HMG_aControlRow[ix] , _HMG_aControlCol[ix] , _HMG_aControlRow[ix] + _HMG_aControlHeight[ix] , _HMG_aControlCol[ix] + _HMG_aControlWidth [ix] )
         ENDIF
      ENDIF

   CASE T == "TEXT" .OR. T == "BTNTEXT" .OR. T == "EDIT" .OR. T == "CHARMASKTEXT" .OR. T == "RICHEDIT"
      Value := IFEMPTY( Value, '', Value )

      IF T == "CHARMASKTEXT"
         IF ISLOGICAL ( _HMG_aControlHeadCLick [ix] )
            IF _HMG_aControlHeadCLick [ix] == .T.
               SetWindowText ( c , RTrim( DToC( hb_defaultValue( value, CToD( '' ) ) ) ) )
            ELSE
               SetWindowText ( c , RTrim( value ) )
            ENDIF
         ELSE
            SetWindowText ( c , RTrim( value ) )
         ENDIF

      ELSEIF T == "EDIT"
         SetWindowText ( c , value )
         _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

      ELSEIF T == "RICHEDIT" .AND. _HMG_IsXPorLater
         IF Empty( value ) .OR. !( Left( value, 7 ) == "{\rtf1\" )
            SetWindowText ( c , value )
         ELSE
            SetWindowTextW ( c , value )
         ENDIF
      ELSE
         SetWindowText ( c , RTrim( value ) )
      ENDIF

   CASE "NUMTEXT" $ T
      Value := IFEMPTY( Value, 0, Value )
      SetWindowText ( c , hb_ntos( Int( value ) ) )

   CASE T == "SPINNER"
      Value := IFEMPTY( Value, 0, Value )
      SetSpinnerValue ( c [2] , Value )

   CASE T == "CHECKBOX"
      Value := iif( ISLOGICAL ( Value ), Value, NIL )

      IF _HMG_aControlSpacing [ix] .AND. value == NIL
         SendMessage ( c , BM_SETCHECK , BST_INDETERMINATE , 0 )
      ELSEIF value == .T.
         SendMessage ( c , BM_SETCHECK , BST_CHECKED , 0 )
      ELSEIF value == .F.
         SendMessage ( c , BM_SETCHECK , BST_UNCHECKED , 0 )
      ENDIF

      IF Empty( _HMG_aControlMiscData1 [ix] )
         _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )
      ENDIF

   CASE T == "RADIOGROUP"
      IF ISNUMERIC( Value ) .AND. Value <= Len( c )  // EF 93
         AEval( c, { |x| SendMessage( x , BM_SETCHECK , BST_UNCHECKED , 0 ) } )
         _HMG_aControlValue [ix] := value

         IF value > 0
            h := c [value]
            SendMessage( h , BM_SETCHECK , BST_CHECKED , 0 )
            IF _HMG_aControlPicture [ix] == .F. .AND. IsTabStop( h )
               SetTabStop( h , .F. )
            ENDIF
         ENDIF

         IF value > 0
            setfocus( h )
         ENDIF
         _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )
      ENDIF

   CASE T == "COMBO"
      Value := IFNUMERIC( Value, Value, 0 )

      IF ValType ( _HMG_aControlSpacing [ix] ) == 'C'
         _HMG_aControlValue [ix] := value
         WorkArea := _HMG_aControlSpacing [ix]
         BackRec := ( WorkArea )->( RecNo() )
         ( WorkArea )->( dbGoTop() )
         DO WHILE ! ( WorkArea )->( EOF() )
            rcount++
            IF value == ( WorkArea )->( RecNo() )
               value := rcount
               EXIT
            ENDIF
            ( WorkArea )->( dbSkip() )
         ENDDO
         ( WorkArea )->( dbGoto( BackRec ) )
      ENDIF

      ComboSetCursel ( c , value )

      IF _HMG_ProgrammaticChange
         _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )
      ENDIF

   CASE T == "LIST" .OR. T == "CHKLIST"
      Value := IFNUMERIC( Value, Value, 0 )

      ListBoxSetCursel ( c , value )

      _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

   CASE T == "GRID"
      IF _HMG_aControlFontColor [ix] == .F.

         ListView_SetCursel ( c, iif( ISARRAY ( Value ), value [1], value ) )
         ListView_EnsureVisible( c , iif( ISARRAY ( Value ), value [1], value ) )

      ELSE

         x := ( ISARRAY ( Value ) .AND. ( _HMG_aControlMiscData1 [ix] [ 1 ] <> value [1] .OR. ;
            _HMG_aControlMiscData1 [ix] [ 17 ] <> value [2] ) )
         _HMG_aControlMiscData1 [ix] [ 1 ]  := iif( ISARRAY ( Value ), value [1], value )
         _HMG_aControlMiscData1 [ix] [ 17 ] := iif( ISARRAY ( Value ), value [2], 1 )

         IF ISARRAY ( Value ) .AND. value[1] * value[2] == 0
            _HMG_aControlMiscData1 [ix] [ 1 ]  := 0
            _HMG_aControlMiscData1 [ix] [ 17 ] := 0
            RedrawWindow ( c )
            _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

         ELSEIF x == .T. .OR. !ISARRAY ( Value )
            ListView_SetCursel ( c, iif( ISARRAY ( Value ), value [1], value ) )
            ListView_EnsureVisible( c , iif( ISARRAY ( Value ), value [1], value ) )
            RedrawWindow ( c )
            _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

         ENDIF

      ENDIF

   CASE T == "TAB"
      Assign nValue := value

      IF nValue < 1
         MsgMiniGuiError( 'TAB: Wrong Value (only value > 0 is allowed).' )
      ENDIF

      TABCTRL_SETCURSEL ( c , nValue )

      IF Len ( _HMG_aControlPageMap [ix] ) > 0
         UpdateTab ( ix )
         _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )
      ENDIF

   CASE T == "DATEPICK"
      IF Empty( Value )
         SetDatePickNull( c )
      ELSE
         SetDatePick( c, Year( value ), Month( value ), Day( value ) )
      ENDIF

      _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

   CASE T == "TIMEPICK"
      IF Empty( Value )
         SetDatePickNull( c )
      ELSEIF ISCHARACTER( Value )
         SetTimePick( c, Val( Left( value, 2 ) ), Val( SubStr( value, 4, 2 ) ), Val( SubStr( value, 7, 2 ) ) )
      ENDIF

      _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

   CASE T == "PROGRESSBAR"
      Value := IFEMPTY( Value, 0, Value )
      SendMessage( c, PBM_SETPOS , value , 0 )

   CASE T == "SLIDER"
      Value := IFEMPTY( Value, 0, Value )
      SendMessage( c , TBM_SETPOS , 1 , value )

      _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )

   CASE T == "MULTILIST" .OR. T == "MULTICHKLIST"
      LISTBOXSETMULTISEL ( c , value )

   CASE T == "MULTIGRID"
      IF ISNUMBER( value )  // GF 09/02/2013
         Value := { Value }
      ENDIF
      LISTVIEWSETMULTISEL ( c , value )

      IF Len ( value ) > 0
         ListView_EnsureVisible( c , value [1] )
      ENDIF

   CASE T == "TOOLBUTTON"
      CheckButtonBar( _HMG_aControlContainerHandle [ ix ] , _HMG_aControlValue [ix] - 1 , value )

   CASE T == "GETBOX"
      _SetGetBoxValue( ix , c , Value )

      oGet := _HMG_aControlHeadClick [ix]
      IF oGet:Changed
         _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )
      ENDIF

   CASE T == "HOTKEYBOX"
      SetHotKeyValue ( c , value )

   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _AddItem ( ControlName , ParentForm , Value , Parent , aImage , Id )
*-----------------------------------------------------------------------------*
   LOCAL t , c , NewHandle , TempHandle , i , ix , aPos
   LOCAL ChildHandle , BackHandle , ParentHandle
   LOCAL TreeItemHandle , ImgDef , iUnSel , iSel
#ifdef _TSBROWSE_
   LOCAL oGet
#endif

   ix := GetControlIndex ( ControlName , ParentForm )
   T := _HMG_aControltype [ix]
   c := _HMG_aControlhandles [ix]

   __defaultNIL( @Id, 0 )

   IF ValType ( aImage ) == 'N'
      Id := aImage
   ENDIF

   DO CASE

   CASE T == "TREE"
      IF _HMG_aControlInputmask [ix] == .F.

         IF Parent > TreeView_GetCount ( c ) .OR. Parent < 0
            MsgMiniGuiError ( "AddItem Method: Invalid Parent Value." )
         ENDIF

      ENDIF

      ImgDef := iif( ValType( aImage ) == "A" , Len( aImage ), 0 )  //Tree+

      IF Parent != 0

         IF _HMG_aControlInputmask [ix] == .F.
            TreeItemHandle := _HMG_aControlPageMap [ ix ] [ Parent ]
         ELSE
            aPos := AScan ( _HMG_aControlPicture [ix] , Parent )
            IF aPos == 0
               MsgMiniGuiError ( "AddItem Method: Invalid Parent Value." )
            ENDIF

            TreeItemHandle := _HMG_aControlPageMap [ ix ] [ aPos ]
         ENDIF

         IF ImgDef == 0
            iUnsel := 2   // Pointer to defalut Node Bitmaps, no Bitmap loaded
            iSel   := 3
         ELSE
            iUnSel := AddTreeViewBitmap( c, aImage[1] ) - 1
            iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( c, aImage[2] ) - 1 )
            // If only one bitmap in array iSel = iUnsel, only one Bitmap loaded
         ENDIF

         NewHandle := AddTreeItem ( c , TreeItemHandle , Value, iUnsel, iSel , Id )

         // Determine Position of New Item
         TempHandle := TreeView_GetChild ( c , TreeItemHandle )

         i := 0

         DO WHILE .T.

            i++

            IF TempHandle == NewHandle
               EXIT
            ENDIF

            ChildHandle := TreeView_GetChild ( c , TempHandle )

            IF ChildHandle == 0
               BackHandle := TempHandle
               TempHandle := TreeView_GetNextSibling ( c , TempHandle )
            ELSE
               i++
               BackHandle := Childhandle
               TempHandle := TreeView_GetNextSibling ( c , ChildHandle )
            ENDIF

            DO WHILE TempHandle == 0

               ParentHandle := TreeView_GetParent ( c , BackHandle )

               TempHandle := TreeView_GetNextSibling ( c , ParentHandle )

               IF TempHandle == 0
                  BackHandle := ParentHandle
               ENDIF

            ENDDO

         ENDDO

         // Resize Array
         ASize ( _HMG_aControlPageMap [ ix ] , TreeView_GetCount ( c ) )
         ASize ( _HMG_aControlPicture [ ix ] , TreeView_GetCount ( c ) )

         // Insert New Element
         IF _HMG_aControlInputmask [ix] == .F.
            AIns ( _HMG_aControlPageMap [ ix ] , Parent + i  )
            AIns ( _HMG_aControlPicture [ ix ] , Parent + i  )
         ELSE
            AIns ( _HMG_aControlPageMap [ ix ] , aPos + i )
            AIns ( _HMG_aControlPicture [ ix ] , aPos + i )
         ENDIF

         // Assign Handle
         IF _HMG_aControlInputmask [ix] == .F.

            _HMG_aControlPageMap [ ix ] [ Parent + i ] := NewHandle
            _HMG_aControlPicture [ ix ] [ Parent + i ] := Id

         ELSE

            IF AScan ( _HMG_aControlPicture [ ix ] , Id ) != 0
               MsgMiniGuiError ( "AddItem Method: Item Id " + hb_ntos( Id ) + " Already In Use." )
            ENDIF

            _HMG_aControlPageMap [ ix ] [ aPos + i ] := NewHandle
            _HMG_aControlPicture [ ix ] [ aPos + i ] := Id

         ENDIF

      ELSE

         IF ImgDef == 0
            iUnsel := 0   // Pointer to defalut Node Bitmaps, no Bitmap loaded
            iSel   := 1
         ELSE
            iUnSel := AddTreeViewBitmap( c, aImage[1] ) - 1
            iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( c, aImage[2] ) - 1 )
            // If only one bitmap in array iSel = iUnsel, only one Bitmap loaded
         ENDIF

         NewHandle := AddTreeItem ( c , 0 , Value, iUnsel, iSel , Id )

         AAdd ( _HMG_aControlPageMap [ ix ] , NewHandle )

         IF _HMG_aControlInputmask [ix] == .T.
            IF AScan ( _HMG_aControlPicture [ ix ] , Id ) != 0
               MsgMiniGuiError ( "AddItem Method: Item Id Already In Use." )
            ENDIF
         ENDIF

         AAdd ( _HMG_aControlPicture [ ix ] , Id )

      ENDIF

   CASE T == "COMBO"
      // (JK) HMG 1.0 Experimental Build 8
      IF _HMG_aControlMiscData1 [ix][1] == 0      // standard combo
         ComboAddString ( c , value )
      ELSEIF _HMG_aControlMiscData1 [ix][1] == 1  // extend combo - "parent" is a picture Id. ;-)
         ComboAddStringEx ( c , value , Parent )
      ENDIF

   CASE "LIST" $ T
      IF "CHKLIST" $ T
         ChkListboxAddItem ( c , value, 1 )
      ELSE
         IF _HMG_aControlMiscData1 [ix] [2] .AND. ValType( value ) == 'A'
            value := LB_Array2String( value )
         ENDIF

         ListBoxAddstring ( c , value )
      ENDIF

   CASE "GRID" $ T
      IF _HMG_aControlMiscData1 [ix][5] == .F.
         _AddGridRow ( ControlName, ParentForm, value )
         IF _HMG_aControlEnabled [ix] == .T.
            _UpdateGridColors ( ix )
         ENDIF
      ENDIF
#ifdef _TSBROWSE_
   CASE T == "TBROWSE"
      oGet := GetObjectByHandle( c )
      IF ISOBJECT( oGet )
         oGet:AddItem( value )
      ENDIF
#endif
   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DeleteItem ( ControlName , ParentForm , Value )
*-----------------------------------------------------------------------------*
   LOCAL t , c , BeforeCount , AfterCount , DeletedCount , i , ix , aPos
   LOCAL TreeItemHandle
#ifdef _TSBROWSE_
   LOCAL oGet
#endif

   ix := GetControlIndex ( ControlName , ParentForm )

   T := _HMG_aControlType [ix]
   c := _HMG_aControlHandles [ix]

   DO CASE

   CASE T == "TREE"
      BeforeCount := TreeView_GetCount ( c )

      IF _HMG_aControlInputmask [ix] == .F.

         IF Value > BeforeCount .OR. Value < 1
            MsgMiniGuiError ( "DeleteItem Method: Invalid Item Specified." )
         ENDIF

         TreeItemHandle := _HMG_aControlPageMap [ix] [Value]
         TreeView_DeleteItem ( c , TreeItemHandle )

      ELSE

         aPos := AScan ( _HMG_aControlPicture [ix] , Value )

         IF aPos == 0
            MsgMiniGuiError ( "DeleteItem Method: Invalid Item Id." )
         ENDIF

         TreeItemHandle := _HMG_aControlPageMap [ix] [aPos]
         TreeView_DeleteItem ( c , TreeItemHandle )

      ENDIF

      AfterCount := TreeView_GetCount ( c )
      DeletedCount := BeforeCount - AfterCount

      IF _HMG_aControlInputmask [ix] == .F.
         IF DeletedCount == 1
            ADel ( _HMG_aControlPageMap [ix] , Value )
         ELSE
            FOR i := 1 TO DeletedCount
               ADel ( _HMG_aControlPageMap [ix] , Value )
            NEXT i
         ENDIF
      ELSE
         IF DeletedCount == 1
            ADel ( _HMG_aControlPageMap [ix] , aPos )
            ADel ( _HMG_aControlPicture [ix] , aPos )
         ELSE
            FOR i := 1 TO DeletedCount
               ADel ( _HMG_aControlPageMap [ix] , aPos )
               ADel ( _HMG_aControlPicture [ix] , aPos )
            NEXT i
         ENDIF
      ENDIF

      ASize ( _HMG_aControlPageMap [ix] , AfterCount )
      ASize ( _HMG_aControlPicture [ix] , AfterCount )

   CASE "LIST" $ T
      ListBoxDeleteString ( c , value )

   CASE T == "COMBO"
      ComboBoxDeleteString ( c , value )
      ComboSetCursel ( c , value )

   CASE "GRID" $ T
      IF _HMG_aControlMiscData1 [ix][5] == .F.

         ListViewDeleteString ( c , value )

         IF _HMG_aControlFontColor [ix] == .T. .AND. T == "GRID"

            IF _HMG_aControlMiscData1 [ix] [ 1 ] == value
               _HMG_aControlMiscData1 [ix] [ 1 ]  := 0
               _HMG_aControlMiscData1 [ix] [ 17 ] := 0

            ELSEIF _HMG_aControlMiscData1 [ix] [ 1 ] > value
               _HMG_aControlMiscData1 [ix] [ 1 ] --
               _DoControlEventProcedure ( _HMG_aControlChangeProcedure [ix] , ix , 'CONTROL_ONCHANGE' )
            ENDIF

            AfterCount := ListViewGetItemCount ( c )
            IF value > AfterCount .AND. AfterCount > 0
               _HMG_aControlMiscData1 [ix] [ 1 ] := AfterCount
            ENDIF

         ENDIF

         _UpdateGridColors ( ix )

      ENDIF
#ifdef _TSBROWSE_
   CASE T == "TBROWSE"
      oGet := GetObjectByHandle( c )
      IF ISOBJECT( oGet )
         oGet:DeleteRow()
      ENDIF
#endif
   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DeleteAllItems ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL t , c , i
#ifdef _TSBROWSE_
   LOCAL oGet
#endif

   i := GetControlIndex ( ControlName , ParentForm )

   t := _HMG_aControlType [i]
   c := _HMG_aControlhandles [i]

   DO CASE

   CASE t == "TREE"
      TreeView_DeleteAllItems ( c )
      ASize ( _HMG_aControlPageMap [i] , 0 )
      ASize ( _HMG_aControlPicture [i] , 0 )

   CASE "LIST" $ t
      ListBoxReset ( c )

   CASE t == "COMBO"
      ComboBoxReset ( c )

   CASE "GRID" $ t
      IF _HMG_aControlMiscData1 [i] [5] == .F.

         ListViewReset ( c )

         IF _HMG_aControlFontColor [i] == .T. .AND. T == "GRID"
            _HMG_aControlMiscData1 [i] [ 1 ]  := 0
            _HMG_aControlMiscData1 [i] [ 17 ] := 0
         ENDIF

      ENDIF
#ifdef _TSBROWSE_
   CASE t == "TBROWSE"
      oGet := GetObjectByHandle( c )
      IF ISOBJECT( oGet ) .AND. oGet:lIsArr
         oGet:DeleteRow( .T. )
      ENDIF
#endif
   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION GetControlIndex ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL mVar := '_' + ParentForm + '_' + ControlName

   IF __mvExist ( mVar )
      RETURN __mvGet ( mVar )
   ENDIF

RETURN 0

*-----------------------------------------------------------------------------*
FUNCTION GetControlName ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      RETURN ''
   ENDIF

RETURN ( _HMG_aControlNames [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetControlHandle ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      MsgMiniGuiError ( "Control " + ControlName + " Of " + ParentForm + " Not defined." )
   ENDIF

RETURN ( _HMG_aControlHandles [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetControlContainerHandle ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      RETURN 0
   ENDIF

RETURN ( _HMG_aControlContainerHandle [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetControlParentHandle ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      RETURN 0
   ENDIF

RETURN ( _HMG_aControlParentHandles [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetControlId ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      RETURN 0
   ENDIF

RETURN ( _HMG_aControlIds [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetControlType ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      RETURN ''
   ENDIF

RETURN ( _HMG_aControlType [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetControlValue ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      RETURN Nil
   ENDIF

   IF _HMG_aControlType [ i ] == "CHECKLABEL"
      RETURN GetChkLabel( _HMG_aControlHandles [ i ] )
   ENDIF
  
RETURN ( _HMG_aControlValue [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION GetControlPageMap ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) == 0
      RETURN {}
   ENDIF

RETURN ( _HMG_aControlPageMap [ i ] )

*-----------------------------------------------------------------------------*
FUNCTION _SetFocus ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL MaskStart As Numeric
   LOCAL H , T , x , i , ControlCount , ParentFormHandle

   H := GetControlHandle ( ControlName , ParentForm )
   T := GetControlType ( ControlName , ParentForm )
   i := GetControlIndex ( ControlName , ParentForm )

   DO CASE

   CASE T == 'TEXT' .OR. T == 'NUMTEXT' .OR. T == 'MASKEDTEXT' .OR. T == 'BTNTEXT' .OR. T == 'BTNNUMTEXT'
      setfocus( H )
      SendMessage ( H , EM_SETSEL , 0 , -1 )

   CASE 'GRID' $ T
      setfocus( H )
      _UpdateGridColors ( i )

   CASE T == "CHARMASKTEXT"
      setfocus( H )

      FOR x := 1 TO Len ( _HMG_aControlInputMask [i] )
         t := SubStr ( _HMG_aControlInputMask [i] , x , 1 )
         IF IsDigit( t ) .OR. IsAlpha( t ) .OR. t == '!'
            MaskStart := x
            EXIT
         ENDIF
      NEXT x

      IF MaskStart > 0
         SendMessage ( H , EM_SETSEL , MaskStart - 1 , -1 )
      ENDIF

   CASE T == 'BUTTON'

      IF _HMG_aControlEnabled [i] == .T.
         ControlCount := Len ( _HMG_aControlNames )
         ParentFormHandle := _HMG_aControlParentHandles [i]
         FOR x := 1 TO ControlCount
            IF _HMG_aControlType [x] == 'BUTTON'
               IF _HMG_aControlParentHandles [x] == ParentFormHandle
                  SendMessage ( _HMG_aControlHandles [x] , BM_SETSTYLE , LOWORD ( BS_PUSHBUTTON ) , 1 )
                  IF Empty( _HMG_aControlBrushHandle [x] )
                     LOOP
                  ENDIF
                  RedrawWindow ( _HMG_aControlHandles [x] )
               ENDIF
            ENDIF
         NEXT
         setfocus( H )
         SendMessage ( H , BM_SETSTYLE , LOWORD ( BS_DEFPUSHBUTTON ) , 1 )
      ENDIF

   CASE T == 'SPINNER'
      setfocus( H [1] )

   CASE T == 'RADIOGROUP'
      x := _GetValue ( , , i )
      _HMG_aControlValue [i] := x
      setfocus( H [ iif( Empty( x ), 1, x ) ] )

   OTHERWISE
      setfocus( H )

   ENDCASE

   _HMG_SetFocusExecuted := .T.

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _DisableControl ( ControlName , ParentForm , nPosition )
*-----------------------------------------------------------------------------*
   LOCAL T , c , y , s , z , w

   T := GetControlType ( ControlName , ParentForm )
   c := GetControlHandle ( ControlName , ParentForm )
   y := GetControlIndex ( ControlName , ParentForm )

   IF T == "BUTTON" .AND. _HMG_aControlEnabled [y] == .T.
      SendMessage ( c , BM_SETSTYLE , LOWORD ( BS_PUSHBUTTON ) , 1 )
      RedrawWindow ( c )
      IF !Empty( _HMG_aControlInputMask [y] )
         z := _DetermineKey( _HMG_aControlInputMask [y] )
         _ReleaseHotKey ( ParentForm , z [2] , z [1] )
      ENDIF
   ENDIF

   DO CASE

      // HMG 1.0 Experimental build 9 (JK)
   CASE T == "BUTTON" .AND. !Empty( _HMG_aControlBrushHandle [y] ) .AND. ValType( _HMG_aControlPicture [y] ) == "A" .AND. _HMG_aControlMiscData1 [y] == 0
      IF _HMG_aControlEnabled [y] == .T.
         IF _HMG_aControlDblClick [y] == .F. .AND. _HMG_IsThemed
            ImageList_Destroy( _HMG_aControlBrushHandle [y] )
            _HMG_aControlBrushHandle [y] := _SetMixedBtnPicture ( c , _HMG_aControlPicture [y][2] )
            ReDrawWindow ( c )
         ELSE
            _DestroyBtnPicture( c, y )
            _SetBtnPicture( c, _HMG_aControlPicture [y][2] )
         ENDIF
         DisableWindow( c )
      ENDIF

   CASE T == "BUTTON" .AND. !Empty( _HMG_aControlBrushHandle [y] ) .AND. ValType( _HMG_aControlPicture [y] ) == "C" .AND. _HMG_aControlMiscData1 [y] == 0
      IF _HMG_aControlEnabled [y] == .T.
         IF _HMG_aControlDblClick [y] == .F. .AND. _HMG_IsThemed
            ImageList_Destroy( _HMG_aControlBrushHandle [y] )
            _HMG_aControlBrushHandle [y] := _SetMixedBtnPicture ( c , _HMG_aControlPicture [y] )
            ReDrawWindow ( c )
         ELSE
            _SetBtnPictureMask( c, y )
            _DestroyBtnPicture( c, y )
         ENDIF
         DisableWindow( c )
      ENDIF

   CASE T == "CHECKBOX" .AND. !Empty( _HMG_aControlBrushHandle [y] ) .AND. ValType( _HMG_aControlPicture [y] ) == "C" .AND. _HMG_aControlMiscData1 [y] == 1
      IF _HMG_aControlEnabled [y] == .T.
         IF _HMG_IsThemed
            ImageList_Destroy( _HMG_aControlBrushHandle [y] )
            _HMG_aControlBrushHandle [y] := _SetMixedBtnPicture ( c , _HMG_aControlPicture [y] )
            ReDrawWindow ( c )
         ELSE
            _SetBtnPictureMask( c, y )
            _DestroyBtnPicture( c, y )
         ENDIF
         DisableWindow( c )
      ENDIF

#ifdef _DBFBROWSE_
   CASE T == "BROWSE"
      DisableWindow ( c )
      IF _HMG_aControlIds [y] != 0
         DisableWindow ( _HMG_aControlIds [y] )
      ENDIF
      _EnableScrollBars ( c, SB_HORZ, ESB_DISABLE_BOTH )
#endif
   CASE T == "GRID"
      DisableWindow ( c )
      _EnableScrollBars ( c, SB_BOTH, ESB_DISABLE_BOTH )

   CASE T == "TOOLBUTTON"
      _DisableToolBarButton ( ControlName, ParentForm )

   CASE T == "MENU" .OR. T == "POPUP"
      _DisableMenuItem ( ControlName, ParentForm )

   CASE T == "TIMER"
      IF _HMG_aControlEnabled [y] == .T.
         w := GetControlParentHandle ( ControlName, ParentForm )
         s := GetControlId ( ControlName, ParentForm )
         KillTimer ( w , s )
      ENDIF

   CASE T == "SPINNER"
      AEval ( c, { |y| DisableWindow ( y ) } )

   CASE T == "RADIOGROUP"
      IF PCount() == 3  // Position is defined, which Radiobutton to disable
         DisableWindow ( c [nPosition] )
         _HMG_aControlPageMap [y] [nPosition] := .T.
      ELSE
         AEval( c, {|y| DisableWindow ( y ) } )
      ENDIF

   CASE T == "TAB"
      IF PCount() == 3  // Position is defined, which Page to disable
         s := iif( nPosition > _GetItemCount ( ControlName , ParentForm ) , 1 , nPosition )
      ELSE
         DisableWindow ( c )
         s := TabCtrl_GetCurSel ( _HMG_aControlHandles [y] )
      ENDIF
      FOR EACH w IN _HMG_aControlPageMap [y] [s]
         IF ValType ( w ) <> "A"
            DisableWindow ( w )
         ELSE
            FOR EACH z IN w
               DisableWindow ( z )
            NEXT
         ENDIF
      NEXT

   CASE t == "GETBOX"
      FOR z := 1 TO 3
         DisableWindow ( _HMG_aControlRangeMin [y][z] )
      NEXT z

   CASE T == "BTNTEXT" .OR. T == "BTNNUMTEXT"
      FOR z := 1 TO 3
         DisableWindow ( _HMG_aControlSpacing [y][z] )
      NEXT z

   OTHERWISE
      DisableWindow ( c )

   ENDCASE

   _HMG_aControlEnabled [y] := .F.

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EnableControl ( ControlName , ParentForm , nPosition )
*-----------------------------------------------------------------------------*
   LOCAL t , c , y , s , z , w

   T := GetControlType ( ControlName , ParentForm )
   c := GetControlHandle ( ControlName , ParentForm )
   y := GetControlIndex ( ControlName , ParentForm )

   IF T == "BUTTON" .AND. _HMG_aControlEnabled [y] == .F.
      IF !Empty( _HMG_aControlInputMask [y] )
         z := _DetermineKey( _HMG_aControlInputMask [y] )
         _DefineHotKey ( ParentForm , z [2] , z [1] , _HMG_aControlProcedures [y] )
      ENDIF
   ENDIF

   DO CASE
   // HMG 1.0 Experimental build 9 (JK)
   CASE T == "BUTTON" .AND. !Empty( _HMG_aControlBrushHandle [y] ) .AND. ValType( _HMG_aControlPicture [y] ) == "A" .AND. _HMG_aControlMiscData1 [y] == 0
      IF _HMG_aControlEnabled [y] == .F.
         IF _HMG_aControlDblClick [y] == .F. .AND. _HMG_IsThemed
            ImageList_Destroy( _HMG_aControlBrushHandle [y] )
            _HMG_aControlBrushHandle [y] := _SetMixedBtnPicture ( c , _HMG_aControlPicture [y][1] )
            ReDrawWindow ( c )
         ELSE
            _DestroyBtnPicture( c, y )
            _HMG_aControlBrushHandle [y] := _SetBtnPicture( c, _HMG_aControlPicture [y][1] )
         ENDIF
         EnableWindow( c )
      ENDIF

   CASE T == "BUTTON" .AND. !Empty( _HMG_aControlBrushHandle [y] ) .AND. ValType( _HMG_aControlPicture [y] ) == "C" .AND. _HMG_aControlMiscData1 [y] == 0
      IF _HMG_aControlEnabled [y] == .F.
         IF _HMG_aControlDblClick [y] == .F. .AND. _HMG_IsThemed
            ImageList_Destroy( _HMG_aControlBrushHandle [y] )
            _HMG_aControlBrushHandle [y] := _SetMixedBtnPicture ( c , _HMG_aControlPicture [y] )
            ReDrawWindow ( c )
         ELSE
            _DestroyBtnPictureMask( c, y )
            _HMG_aControlBrushHandle [y] := _SetBtnPicture( c, _HMG_aControlPicture [y] )
         ENDIF
         EnableWindow( c )
      ENDIF

   CASE T == "CHECKBOX" .AND. !Empty( _HMG_aControlBrushHandle [y] ) .AND. ValType( _HMG_aControlPicture [y] ) == "C" .AND. _HMG_aControlMiscData1 [y] == 1
      IF _HMG_aControlEnabled [y] == .F.
         IF _HMG_IsThemed
            ImageList_Destroy( _HMG_aControlBrushHandle [y] )
            _HMG_aControlBrushHandle [y] := _SetMixedBtnPicture ( c , _HMG_aControlPicture [y] )
            ReDrawWindow ( c )
         ELSE
            _DestroyBtnPictureMask( c, y )
            _HMG_aControlBrushHandle [y] := _SetBtnPicture( c, _HMG_aControlPicture [y] )
         ENDIF
         EnableWindow( c )
      ENDIF

#ifdef _DBFBROWSE_
   CASE T == "BROWSE"
      EnableWindow ( c )
      IF _HMG_aControlIds [y] != 0
         EnableWindow ( _HMG_aControlIds [y] )
      ENDIF
      _EnableScrollBars ( c, SB_BOTH, ESB_ENABLE_BOTH )
#endif
   CASE T == "GRID"
      EnableWindow ( c )
      _EnableScrollBars ( c, SB_BOTH, ESB_ENABLE_BOTH )

   CASE T == "TOOLBUTTON"
      _EnableToolBarButton ( ControlName, ParentForm )

   CASE T == "MENU" .OR. T == "POPUP"
      _EnableMenuItem ( ControlName, ParentForm )

   CASE T == "TIMER"
      s := GetControlId ( ControlName, ParentForm )
      FOR EACH z IN _HMG_aControlIds
         IF ISNUMERIC ( z ) .AND. z == s
            InitTimer ( GetFormHandle( ParentForm ) , z , _HMG_aControlValue [ hb_enumindex( z ) ] )
            EXIT
         ENDIF
      NEXT

   CASE T == "SPINNER"
      AEval ( c, { |y| EnableWindow ( y ) } )

   CASE T == "RADIOGROUP"
      IF PCount() == 3  // Position is defined, which Radiobutton to enable
         EnableWindow ( c [nPosition] )
         _HMG_aControlPageMap [y] [nPosition] := .F.
      ELSE
         AEval( c, { |y| EnableWindow ( y ) } )
      ENDIF

   CASE T == "TAB"
      IF PCount() == 3  // Position is defined, which Page to enable
         s := iif( nPosition > _GetItemCount ( ControlName , ParentForm ) , 1 , nPosition )
      ELSE
         EnableWindow ( c )
         s := TabCtrl_GetCurSel ( _HMG_aControlHandles [y] )
      ENDIF
      FOR EACH w IN _HMG_aControlPageMap [y] [s]
         IF ValType ( w ) <> "A"
            EnableWindow ( w )
         ELSE
            FOR EACH z IN w
               EnableWindow ( z )
            NEXT
         ENDIF
      NEXT

   CASE t == "GETBOX"
      FOR z := 1 TO 3
         EnableWindow ( _HMG_aControlRangeMin [y][z] )
      NEXT z

   CASE T == "BTNTEXT" .OR. T == "BTNNUMTEXT"
      FOR z := 1 TO 3
         EnableWindow ( _HMG_aControlSpacing [y][z] )
      NEXT z

   OTHERWISE
      EnableWindow ( c )

   ENDCASE

   _HMG_aControlEnabled [y] := .T.

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _ShowControl ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL t, i, c, w, s, y, z, r
   LOCAL TabHide := .F.

   T := GetControlType ( ControlName , ParentForm )
   c := GetControlHandle ( ControlName , ParentForm )
   y := GetControlIndex ( ControlName , ParentForm )

   IF _HMG_aControlVisible [y] == .T.
      RETURN Nil
   ENDIF

   // If the control is inside a TAB and the page is not visible,
   // the control must not be showed

   FOR i := 1 TO Len ( _HMG_aControlPageMap )

      IF _HMG_aControlType [i] == "TAB"

         s := TabCtrl_GetCurSel ( _HMG_aControlHandles [i] )

         FOR r := 1 TO Len ( _HMG_aControlPageMap [i] )

            FOR w := 1 TO Len ( _HMG_aControlPageMap [i] [r] )

               IF t == 'RADIOGROUP'

                  IF ValType ( _HMG_aControlPageMap [i] [r] [w] ) == 'A'

                     IF _HMG_aControlPageMap [i] [r] [w] [1] == _HMG_aControlHandles [y] [1]

                        IF r != s
                           TabHide := .T.
                        ENDIF

                        EXIT

                     ENDIF

                  ENDIF

               ELSEIF t == 'SPINNER'

                  IF ValType ( _HMG_aControlPageMap [i] [r] [w] ) == 'A'

                     IF _HMG_aControlPageMap [i] [r] [w] [1] == _HMG_aControlHandles [y] [1]

                        IF r != s
                           TabHide := .T.
                        ENDIF

                        EXIT

                     ENDIF

                  ENDIF
#ifdef _DBFBROWSE_
               ELSEIF t == 'BROWSE'

                  IF ValType ( _HMG_aControlPageMap [i] [r] [w] ) == 'A'

                     IF _HMG_aControlPageMap [i] [r] [w] [1] == _HMG_aControlHandles [y]

                        IF r != s
                           TabHide := .T.
                        ENDIF

                        EXIT

                     ENDIF

                  ELSEIF ValType ( _HMG_aControlPageMap [i] [r] [w] ) == 'N'

                     IF _HMG_aControlPageMap [i] [r] [w] == _HMG_aControlHandles [y]

                        IF r != s
                           TabHide := .T.
                        ENDIF

                        EXIT

                     ENDIF

                  ENDIF
#endif
               ELSE

                  IF ValType ( _HMG_aControlPageMap [i] [r] [w] ) == 'N'

                     IF _HMG_aControlPageMap [i] [r] [w] == _HMG_aControlHandles [y]

                        IF r != s
                           TabHide := .T.
                        ENDIF

                        EXIT

                     ENDIF

                  ENDIF

               ENDIF

            NEXT w

         NEXT r

      ENDIF

   NEXT i

   IF TabHide == .T.
      _HMG_aControlVisible [y] := .T.
      RETURN Nil
   ENDIF

   DO CASE

   CASE T == "SPINNER"
      AEval ( c, { |y| CShowControl ( y ) } )

#ifdef _DBFBROWSE_
   CASE T == "BROWSE"
      CShowControl ( c )

      IF _HMG_aControlIds [y] != 0
         CShowControl ( _HMG_aControlIds [y] )
      ENDIF
      IF _HMG_aControlMiscData1 [y] [1] != 0
         CShowControl ( _HMG_aControlMiscData1 [y] [1] )
      ENDIF
#endif
   CASE T == "TAB"
      CShowControl ( c )

      s := TabCtrl_GetCurSel ( _HMG_aControlHandles [y] )
      FOR EACH w IN _HMG_aControlPageMap [y] [s]
         IF ValType ( w ) <> "A"
            CShowControl ( w )
         ELSE
            FOR EACH z IN w
               CShowControl ( z )
            NEXT
         ENDIF
      NEXT

   CASE T == "RADIOGROUP"
      AEval( c, {|y| ShowWindow ( y ) } )

#ifdef _PROPGRID_
   CASE T == "PROPGRID"
      AEval( c, {|y| ShowWindow ( y ) } )
#endif
   CASE T == "GETBOX"
      FOR z := 1 TO 3
         CShowControl ( _HMG_aControlRangeMin [y][z] )
      NEXT z

   CASE T == "BTNTEXT" .OR. T == "BTNNUMTEXT"
      FOR z := 1 TO 3
         CShowControl ( _HMG_aControlSpacing [y][z] )
      NEXT z

   OTHERWISE
      CShowControl ( c )

   END CASE

   _HMG_aControlVisible [y] := .T.

   DoEvents()

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _HideControl ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL t, c, y, r, w, z

   T := GetControlType ( ControlName , ParentForm )
   c := GetControlHandle ( ControlName , ParentForm )
   y := GetControlIndex ( ControlName , ParentForm )

   DO CASE

   CASE T == "SPINNER"
      AEval ( c, { |y| HideWindow ( y ) } )

#ifdef _DBFBROWSE_
   CASE T == "BROWSE"
      HideWindow ( c )

      IF _HMG_aControlIds [y] != 0
         HideWindow ( _HMG_aControlIds [y] )
      ENDIF
      IF _HMG_aControlMiscData1 [y] [1] != 0
         HideWindow ( _HMG_aControlMiscData1 [y] [1] )
      ENDIF
#endif
   CASE T == "TAB"
      HideWindow ( c )

      FOR EACH r IN _HMG_aControlPageMap [y]
         FOR EACH w IN r
            IF ValType ( w ) <> "A"
               HideWindow ( w )
            ELSE
               FOR EACH z IN w
                  HideWindow ( z )
               NEXT
            ENDIF
         NEXT
      NEXT

   CASE T == "RADIOGROUP"
      AEval( c, {|y| HideWindow ( y ) } )

#ifdef _PROPGRID_
   CASE T == "PROPGRID"
      AEval( c, {|y| HideWindow ( y ) } )
#endif
   CASE T == "COMBO"
      SendMessage ( c , 335 , 0 , 0 )  // close DropDown list
      HideWindow ( c )

   CASE T == "GETBOX"
      FOR z := 1 TO 3
         HideWindow ( _HMG_aControlRangeMin [y][z] )
      NEXT z

   CASE T == "BTNTEXT" .OR. T == "BTNNUMTEXT"
      FOR z := 1 TO 3
         HideWindow ( _HMG_aControlSpacing [y][z] )
      NEXT z

   OTHERWISE
      HideWindow ( c )

   END CASE

   _HMG_aControlVisible [y] := .F.

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetItem ( ControlName , ParentForm , Item , Value , index )
*-----------------------------------------------------------------------------*
   LOCAL t , c , i , Pos , TreeHandle , ItemHandle
   LOCAL AEDITCONTROLS
   LOCAL ci, bd
   LOCAL XRES
   LOCAL ATEMP
   LOCAL AEC
   LOCAL CTYPE
   LOCAL CINPUTMASK
   LOCAL CFORMAT
   LOCAL AITEMS
   LOCAL ALABELS

   i := iif( PCount() == 5, index, GetControlIndex ( ControlName, ParentForm ) )

   t := _HMG_aControlType [i]
   c := _HMG_aControlHandles [i]

   DO CASE
   CASE t == 'TREE'

      IF _HMG_aControlInputmask [i] == .F.
         IF Item > TreeView_GetCount ( c ) .OR. Item < 1
            MsgMiniGuiError ( "Item Property: Invalid Item Reference." )
         ENDIF
      ENDIF

      TreeHandle := c

      IF _HMG_aControlInputmask [i] == .F.
         ItemHandle := _HMG_aControlPageMap [ i ] [ Item ]
      ELSE

         Pos := AScan ( _HMG_aControlPicture [i] , Item )

         IF Pos == 0
            MsgMiniGuiError ( "Item Property: Invalid Item Id." )
         ENDIF

         ItemHandle := _HMG_aControlPageMap [ i ] [ Pos ]

      ENDIF

      TreeView_SetItem ( TreeHandle , ItemHandle , Value )

   CASE T == "LIST"

      IF _HMG_aControlMiscData1 [i] [2] .AND. ValType(value) == 'A'
         value := LB_Array2String( value )
      ENDIF

      ListBoxDeleteString ( c , Item )
      ListBoxInsertString ( c , value , Item )
      ListBoxSetCurSel ( c , Item )

   CASE T == "CHKLIST"

      Pos := iif( ChkList_GetCheckBox ( c , Item ), 2, 1 )
      ListBoxDeleteString ( c , Item )
      ChkListBoxInsertItem ( c , value , Item, Pos )
      ListBoxSetCurSel ( c , Item )

   CASE T == "MULTILIST"

      aTemp := ListBoxGetMultiSel ( c )
      ListBoxDeleteString ( c , Item )
      ListBoxInsertString ( c , value , Item )
      ListBoxSetMultiSel ( c , aTemp )

   CASE T == "MULTICHKLIST"

      Pos := iif( ChkList_GetCheckBox ( c , Item ), 2, 1 )
      aTemp := ListBoxGetMultiSel ( c )
      ListBoxDeleteString ( c , Item )
      ChkListBoxInsertItem ( c , value , Item, Pos )
      ListBoxSetMultiSel ( c , aTemp )

   CASE T == "COMBO"

      IF _HMG_aControlMiscData1 [i][1] == 0       // standard combo
         ComboBoxDeleteString ( c , Item )
         ComboInsertString ( c , value , Item )
      ELSEIF _HMG_aControlMiscData1 [i][1] == 1   // extend combo - value is array (1-image index, 2-string)
         ComboBoxDeleteItemEx ( c , Item )
         ComboInsertStringEx ( c , value[2] , value[1] , Item )
      ENDIF

   CASE "GRID" $ T

      IF _HMG_aControlMiscData1 [i][5] == .F.

         AEDITCONTROLS := _HMG_aControlMiscData1 [i][13]

         IF ValType ( AEDITCONTROLS ) != 'A'

            ListViewSetItem ( c , value , Item )

         ELSE

            ATEMP := Array ( Len ( VALUE ) )

            FOR ci := 1 TO Len ( VALUE )

               XRES := _ParseGridControls ( AEDITCONTROLS , CI , Item )

               AEC        := XRES [1]
               CTYPE      := XRES [2]
               CINPUTMASK := XRES [3]
               CFORMAT    := XRES [4]
               AITEMS     := XRES [5]
               ALABELS    := XRES [8]

               IF AEC == 'TEXTBOX'
                  IF CTYPE == 'CHARACTER'
                     IF Empty ( CINPUTMASK )
                        aTemp [ci] := VALUE [CI]
                     ELSE
                        aTemp [ci] := Transform ( VALUE [CI] , CINPUTMASK )
                     ENDIF
                  ELSEIF CTYPE == 'NUMERIC'
                     IF Empty ( CINPUTMASK )
                        aTemp [ci] := Str ( VALUE [CI] )
                     ELSE
                        IF Empty ( CFORMAT )
                           aTemp [ci] := Transform ( VALUE [CI] , CINPUTMASK )
                        ELSE
                           aTemp [ci] := Transform ( VALUE [CI], '@' + CFORMAT + ' ' + CINPUTMASK )
                        ENDIF
                     ENDIF
                  ELSEIF CTYPE == 'DATE'
                     aTemp [ci] := DToC ( VALUE [CI] )
                  ENDIF

               ELSEIF AEC == 'DATEPICKER'
                  bd := Set ( _SET_DATEFORMAT )
                  SET CENTURY ON
                  aTemp [ci] := DToC ( VALUE [CI] )
                  SET ( _SET_DATEFORMAT , bd )

               ELSEIF AEC == 'COMBOBOX'
                  IF VALUE [CI] == 0
                     aTemp [ci] := ''
                  ELSE
                     aTemp [ci] := AITEMS [ VALUE [CI] ]
                  ENDIF

               ELSEIF AEC == 'SPINNER'
                  aTemp [ci] := Str ( VALUE [CI] )

               ELSEIF AEC == 'CHECKBOX'
                  IF VALUE [CI] == .T.
                     aTemp [ci] := ALABELS [1]
                  ELSE
                     aTemp [ci] := ALABELS [2]
                  ENDIF
               ENDIF

            NEXT ci

            ListViewSetItem ( c , aTemp , Item )

         ENDIF

         IF Len ( _HMG_aControlBkColor [i] ) > 0
            SetImageListViewItems ( c, item , value [1] )
         ENDIF

         _UpdateGridColors ( i )

      ENDIF

   CASE T == "MESSAGEBAR"  // JP

      IF _IsOwnerDrawStatusBarItem ( c , Item , Value , .T. )
         RefreshStatusItem ( c , Item )
      ELSE
         SetItemBar ( c , value , Item - 1 )
      ENDIF

   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetItem ( ControlName , ParentForm , Item , index )
*-----------------------------------------------------------------------------*
   LOCAL t , c , RetVal , TreeHandle , ItemHandle , i , Pos
   LOCAL AEDITCONTROLS, CI, XRES, ATEMP, AEC, CTYPE, CFORMAT
   LOCAL AITEMS, ALABELS, V, Z, X, ColumnCount

   i := iif( PCount() == 4 , index , GetControlIndex ( ControlName , ParentForm ) )

   t := _HMG_aControlType [i]
   c := _HMG_aControlHandles [i]

   DO CASE
   CASE t == "TREE"

      IF _HMG_aControlInputmask [i] == .F.
         IF Item > TreeView_GetCount ( c ) .OR. Item < 1
            MsgMiniGuiError ( "Item Property: Invalid Item Reference." )
         ENDIF
      ENDIF

      TreeHandle := c

      IF _HMG_aControlInputmask [i] == .F.
         ItemHandle := _HMG_aControlPageMap [ i ] [ Item ]
      ELSE

         Pos := AScan ( _HMG_aControlPicture [i] , Item )

         IF Pos == 0
            MsgMiniGuiError ( "Item Property: Invalid Item Id." )
         ENDIF

         ItemHandle := _HMG_aControlPageMap [ i ] [ Pos ]

      ENDIF

      RetVal := TreeView_GetItem ( TreeHandle , ItemHandle )

   CASE "LIST" $ T

      RetVal := ListBoxGetString ( c , Item )
      IF ISARRAY ( _HMG_aControlMiscData1 [i] ) .AND. _HMG_aControlMiscData1 [i] [2]
         RetVal := LB_String2Array( RetVal )
      ENDIF

   CASE T == "COMBO"

      RetVal := ComboGetString ( c , Item )

   CASE "GRID" $ T

      ColumnCount := ListView_GetColumnCount ( c )

      IF _HMG_aControlMiscData1 [i] [5] == .T.

         RetVal := _GetIVirtualItem ( Item , i , ColumnCount )

      ELSE

         AEDITCONTROLS := _HMG_aControlMiscData1 [i] [13]

         IF ValType ( AEDITCONTROLS ) != 'A'

            RetVal := ListViewGetItem ( c , Item , ColumnCount )

         ELSE

            V := ListViewGetItem ( c , Item , ColumnCount )

            ATEMP := Array ( ColumnCount )

            FOR CI := 1 TO ColumnCount

               XRES := _ParseGridControls ( AEDITCONTROLS , CI , Item )

               AEC      := XRES [1]
               CTYPE    := XRES [2]
               CFORMAT  := XRES [4]
               AITEMS   := XRES [5]
               ALABELS  := XRES [8]

               IF AEC == 'TEXTBOX'
                  IF CTYPE == 'NUMERIC'
                     IF CFORMAT == 'E'
                        ATEMP [CI] := GetNumFromCellTextSp ( V [CI] )
                     ELSE
                        ATEMP [CI] := GetNumFromCellText ( V [CI] )
                     ENDIF
                  ELSEIF CTYPE == 'DATE'
                     ATEMP [CI] := CToD ( V [CI] )
                  ELSEIF CTYPE == 'CHARACTER'
                     ATEMP [CI] := V [CI]
                  ENDIF

               ELSEIF AEC == 'DATEPICKER'
                  ATEMP [CI] := CToD ( V [CI] )

               ELSEIF AEC == 'COMBOBOX'
                  Z := 0
                  FOR EACH X IN AITEMS
                     IF Upper ( AllTrim( V [CI] ) ) == Upper( AllTrim( X ) )
                        Z := hb_enumindex( X )
                        EXIT
                     ENDIF
                  NEXT
                  ATEMP [CI] := Z

               ELSEIF AEC == 'SPINNER'
                  ATEMP [CI] := Val ( V [CI] )

               ELSEIF AEC == 'CHECKBOX'
                  ATEMP [CI] := ( Upper( AllTrim( V [CI] ) ) == Upper( AllTrim( ALABELS [1] ) ) )
               ENDIF

            NEXT CI

            RetVal := ATEMP

         ENDIF

         IF Len ( _HMG_aControlBkColor [i] ) > 0
            IF Len ( RetVal ) >= 1
               RetVal [1] := GetImageListViewItems ( c , Item )
            ENDIF
         ENDIF

      ENDIF

   CASE T == "MESSAGEBAR"  //JK

      IF _IsOwnerDrawStatusBarItem ( c , Item , @i )
         RetVal := _HMG_aControlCaption [i]
      ELSE
         RetVal := GetItemBar ( c , Item )
      ENDIF

   ENDCASE

RETURN ( RetVal )

*-----------------------------------------------------------------------------*
FUNCTION _SetControlSizePos ( ControlName, ParentForm, row, col, width, height )
*-----------------------------------------------------------------------------*
   LOCAL t, i, c, x , NewCol , NewRow , r , w , z , p , xx , sx , sy
#ifdef _DBFBROWSE_
   LOCAL b , hws
#endif
   LOCAL DelTaRow, DelTaCol, DelTaWidth, SpinW
   LOCAL tCol, tRow, tWidth, tHeight

   T := GetControlType ( ControlName, ParentForm )
   c := GetControlHandle ( ControlName, ParentForm )
   x := GetControlIndex ( ControlName, ParentForm )

   sx := GetScrollPos ( GetFormHandle ( ParentForm ), 0 )
   sy := GetScrollPos ( GetFormHandle ( ParentForm ), 1 )

   DO CASE

   CASE T == "TAB"

      DelTaRow    := Row   - _HMG_aControlRow   [x]
      DelTaCol    := Col   - _HMG_aControlCol   [x]
      DelTaWidth  := Width - _HMG_aControlWidth [x]

      _HMG_aControlRow    [x] := Row
      _HMG_aControlCol    [x] := Col
      _HMG_aControlWidth  [x] := Width
      _HMG_aControlHeight [x] := Height

      MoveWindow ( c , col - sx , Row - sy , Width , Height , .T. )

      FOR r := 1 TO Len ( _HMG_aControlPageMap [x] )
         FOR w := 1 TO Len ( _HMG_aControlPageMap [x] [r] )

            IF ValType ( _HMG_aControlPageMap [x] [r] [w] ) <> "A"

               p := AScan ( _HMG_aControlhandles , _HMG_aControlPageMap [x] [r] [w] )

               IF p > 0
                  tCol    := _HMG_aControlCol    [p]
                  tRow    := _HMG_aControlRow    [p]
                  tWidth  := _HMG_aControlWidth  [p]
                  tHeight := _HMG_aControlHeight [p]

                  MoveWindow ( _HMG_aControlPageMap [x] [r] [w] , tCol + DeltaCol - sx , tRow + DeltaRow - sy , tWidth , tHeight , .T. )

                  _HMG_aControlRow [p] :=  tRow + DeltaRow
                  _HMG_aControlCol [p] :=  tCol + DeltaCol

                  _HMG_aControlContainerRow [p] :=  Row
                  _HMG_aControlContainerCol [p] :=  Col
               ENDIF

            ELSE

               p := AScan ( _HMG_aControlhandles , _HMG_aControlPageMap [x] [r] [w] [1] )

               IF p > 0 .AND. _HMG_aControlType [p] == 'BROWSE'

#ifdef _DBFBROWSE_
                  tCol    := _HMG_aControlCol    [p]
                  tRow    := _HMG_aControlRow    [p]
                  tWidth  := _HMG_aControlWidth  [p]
                  tHeight := _HMG_aControlHeight [p]

                  IF _HMG_aControlIds [p] != 0

                     MoveWindow ( _HMG_aControlPageMap [x] [r] [w] [1] , tCol + DeltaCol - sx , tRow + DeltaRow - sy , tWidth - GETVSCROLLBARWIDTH() , tHeight , .T. )

                     hws := 0
                     FOR b := 1 TO Len ( _HMG_aControlProcedures [p] )
                        hws += ListView_GetColumnWidth ( _HMG_aControlHandles [p] , b - 1 )
                     NEXT b

                     IF hws > _HMG_aControlWidth [p] - GETVSCROLLBARWIDTH() - 4

                        MoveWindow ( _HMG_aControlIds [p] , tCol + DeltaCol + tWidth - GETVSCROLLBARWIDTH() - sx , tRow + DeltaRow - sy , GETVSCROLLBARWIDTH() , tHeight - GetHScrollBarHeight() , .T. )
                        MoveWindow ( _HMG_aControlMiscData1 [p] [1], tCol + DeltaCol + tWidth - GETVSCROLLBARWIDTH() - sx , tRow + DeltaRow + tHeight - GetHScrollBarHeight() - sy , ;
                           GetWindowWidth( _HMG_aControlMiscData1 [p] [1] ) , GetWindowHeight( _HMG_aControlMiscData1 [p] [1] ) , .T. )

                     ELSE

                        MoveWindow ( _HMG_aControlIds [p] , tCol + DeltaCol + tWidth - GETVSCROLLBARWIDTH() - sx , tRow + DeltaRow - sy , GETVSCROLLBARWIDTH() , tHeight , .T. )
                        MoveWindow ( _HMG_aControlMiscData1 [p] [1], tCol + DeltaCol + tWidth - GETVSCROLLBARWIDTH() - sx , tRow + DeltaRow + tHeight - GetHScrollBarHeight() - sy , 0 , 0 , .T. )

                     ENDIF

                     _BrowseRefresh ( '' , '' , p )

                     ReDrawWindow ( _HMG_aControlIds [p] )

                     ReDrawWindow ( _HMG_aControlMiscData1 [p] [1] )

                  ELSE

                     MoveWindow ( _HMG_aControlPageMap [x] [r] [w] [1] , tCol + DeltaCol - sx , tRow + DeltaRow - sy , tWidth , tHeight , .T. )

                  ENDIF

                  _HMG_aControlRow [p] := tRow + DeltaRow
                  _HMG_aControlCol [p] := tCol + DeltaCol

                  _HMG_aControlContainerRow [p] := Row
                  _HMG_aControlContainerCol [p] := Col
#endif
               ELSEIF p > 0 .AND. ( _HMG_aControlType [p] == "BTNNUMTEXT" .OR. _HMG_aControlType [p] == "BTNTEXT" .OR. ( _HMG_aControlType [p] == "GETBOX" .AND. _HMG_aControlMiscData1 [p] [4] != Nil ) )

                  tCol    := _HMG_aControlCol    [p]
                  tRow    := _HMG_aControlRow    [p]
                  tWidth  := _HMG_aControlWidth  [p]
                  tHeight := _HMG_aControlHeight [p]

                  IF _HMG_aControlType [p] == "GETBOX"
                     MoveWindow ( _HMG_aControlRangeMin [p] [1] , tCol + DeltaCol - sx , tRow + DeltaRow - sy , tWidth + DelTaWidth , tHeight , .T. )
                     MoveBtnTextBox( _HMG_aControlRangeMin [p] [1], _HMG_aControlRangeMin [p] [2], _HMG_aControlRangeMin [p] [3], ;
                        _HMG_aControlMiscData1 [p] [7], _HMG_aControlMiscData1 [p] [6], tWidth + DelTaWidth, tHeight )
                  ELSE

                     MoveWindow ( _HMG_aControlSpacing [p] [1] , tCol + DeltaCol - sx , tRow + DeltaRow - sy , tWidth + DelTaWidth , tHeight , .T. )
                     MoveBtnTextBox( _HMG_aControlSpacing [p] [1], _HMG_aControlSpacing [p] [2], _HMG_aControlSpacing [p] [3], ;
                        _HMG_aControlMiscData1 [p] [2], _HMG_aControlRangeMin [p], tWidth + DelTaWidth, tHeight )
                  ENDIF

                  _HMG_aControlRow [ p ] := _HMG_aControlRow [ p ] + DeltaRow
                  _HMG_aControlCol [ p ] := _HMG_aControlCol [ p ] + DeltaCol
                  _HMG_aControlWidth [ p ] := _HMG_aControlWidth [ p ] + DeltaWidth
                  _HMG_aControlContainerRow [ p ] := Row
                  _HMG_aControlContainerCol [ p ] := Col

               ELSEIF p > 0 .AND. _HMG_aControlType [p] == "GETBOX"

                  MoveWindow ( _HMG_aControlRangeMin [p] [1] , _HMG_aControlCol [p] + DeltaCol - sx , _HMG_aControlRow [p] + DeltaRow - sy , _HMG_aControlWidth [p] , _HMG_aControlHeight [p] , .T. )

                  _HMG_aControlRow [ p ] := _HMG_aControlRow [ p ] + DeltaRow
                  _HMG_aControlCol [ p ] := _HMG_aControlCol [ p ] + DeltaCol
                  _HMG_aControlContainerRow [ p ] := Row
                  _HMG_aControlContainerCol [ p ] := Col

               ELSE

                  FOR z := 1 TO Len ( _HMG_aControlPageMap [x] [r] [w] )

                     FOR xx := 1 TO Len ( _HMG_aControlType )

                        IF ValType ( _HMG_aControlhandles [xx] ) == 'A'

                           IF _HMG_aControlPageMap [x] [r] [w] == _HMG_aControlhandles [xx]

                              IF _HMG_aControlType [xx] == 'RADIOGROUP'
                                 IF _HMG_aControlMiscData1 [ xx ] == .T.
                                    MoveWindow ( _HMG_aControlhandles [xx] [z] , _HMG_aControlCol [xx] + DeltaCol - sx + ( _HMG_aControlWidth [xx] + _HMG_aControlSpacing [xx] ) * ( z - 1 ) , _HMG_aControlRow [xx] + DeltaRow - sy, ;
                                       _HMG_aControlWidth [xx] , _HMG_aControlHeight [xx] , .T. )
                                 ELSE
                                    MoveWindow ( _HMG_aControlhandles [xx] [z] , _HMG_aControlCol [xx] + DeltaCol - sx , _HMG_aControlRow [xx] + DeltaRow - sy + _HMG_aControlSpacing [xx] * ( z - 1 ) , _HMG_aControlWidth [xx] , 28 , .T. )
                                 ENDIF
                              ENDIF

                              IF _HMG_aControlType [xx] == 'RADIOGROUP' .AND. z == Len ( _HMG_aControlPageMap [x] [r] [w] )
                                 _HMG_aControlRow [ xx ] := _HMG_aControlRow [ xx ] + DeltaRow
                                 _HMG_aControlCol [ xx ] := _HMG_aControlCol [ xx ] + DeltaCol
                                 _HMG_aControlContainerRow [ xx ] := Row
                                 _HMG_aControlContainerCol [ xx ] := Col
                              ENDIF

                              IF _HMG_aControlType [xx] == 'SPINNER' .AND. z == 1
                                 // JD 07/22/2007
                                 SpinW := GetWindowWidth( _HMG_aControlhandles [xx] [2] )
                                 MoveWindow ( _HMG_aControlhandles [xx] [1] , _HMG_aControlCol [xx] + DeltaCol - sx , _HMG_aControlRow [xx] + DeltaRow - sy , _HMG_aControlWidth [xx] - SpinW + Get3DEdgeWidth() , _HMG_aControlHeight [xx] , .T. )
                              ENDIF

                              IF _HMG_aControlType [xx] == 'SPINNER' .AND. z == 2
                                 // JD 07/22/2007
                                 SpinW := GetWindowWidth( _HMG_aControlhandles [xx] [2] )
                                 MoveWindow ( _HMG_aControlhandles [xx] [2] , _HMG_aControlCol [xx] + DeltaCol - sx + _HMG_aControlWidth [xx] - SpinW , _HMG_aControlRow [xx] + DeltaRow - sy , SpinW , _HMG_aControlHeight [xx] , .T. )
                                 _HMG_aControlRow [ xx ] := _HMG_aControlRow [ xx ] + DeltaRow
                                 _HMG_aControlCol [ xx ] := _HMG_aControlCol [ xx ] + DeltaCol
                                 _HMG_aControlContainerRow [ xx ] := Row
                                 _HMG_aControlContainerCol [ xx ] := Col
                              ENDIF

                           ENDIF

                        ENDIF

                     NEXT xx

                  NEXT z
               ENDIF
            ENDIF
         NEXT w
      NEXT r

   CASE T == "SPINNER"

      // JD 07/22/2007
      SpinW := GetWindowWidth( c [2] )

      IF _HMG_aControlContainerRow [x] == -1

         _HMG_aControlRow    [ x ] := Row
         _HMG_aControlCol    [ x ] := Col
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         // JD 07/22/2007
         MoveWindow ( c [1] , Col - sx , Row - sy , Width - SpinW + Get3DEdgeWidth(), Height , .T. )
         MoveWindow ( c [2] , Col - sx + Width - SpinW , Row - sy , SpinW , Height , .T. )

      ELSE

         _HMG_aControlRow    [ x ] := Row + _HMG_aControlContainerRow [x]
         _HMG_aControlCol    [ x ] := Col + _HMG_aControlContainerCol [x]
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         // JD 07/22/2007
         MoveWindow ( c [1] , Col + _HMG_aControlContainerCol [x] - sx , Row + _HMG_aControlContainerRow [x] - sy , Width - SpinW + Get3DEdgeWidth() , Height , .T. )
         MoveWindow ( c [2] , Col + _HMG_aControlContainerCol [x] - sx + Width - SpinW , Row + _HMG_aControlContainerRow [x] - sy , SpinW , Height , .T. )

      ENDIF

#ifdef _DBFBROWSE_
   CASE T == "BROWSE"

      IF _HMG_aControlContainerRow [x] == -1

         _HMG_aControlRow    [ x ] := Row
         _HMG_aControlCol    [ x ] := Col
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         IF _HMG_aControlIds[x] != 0

            MoveWindow ( c , col - sx , Row - sy , Width - GETVSCROLLBARWIDTH() , Height , .T. )

            hws := 0
            FOR b := 1 TO Len ( _HMG_aControlProcedures [x] )
               hws += ListView_GetColumnWidth ( _HMG_aControlHandles [x] , b - 1 )
            NEXT b

            IF hws > _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH() - 4

               MoveWindow ( _HMG_aControlIds [x] , Col + Width - sx - GETVSCROLLBARWIDTH() , Row - sy , GETVSCROLLBARWIDTH() , Height - GetHScrollBarHeight() , .T. )
               MoveWindow ( _HMG_aControlMiscData1 [x] [1], Col + Width - sx - GETVSCROLLBARWIDTH() , Row + Height - sy - GetHScrollBarHeight() , GetWindowWidth( _HMG_aControlMiscData1 [x] [1] ) , GetWindowHeight( _HMG_aControlMiscData1 [x] [1] ) , .T. )

            ELSE

               MoveWindow ( _HMG_aControlIds[x] , col + Width - sx - GETVSCROLLBARWIDTH() , Row - sy , GETVSCROLLBARWIDTH() , Height , .T. )
               MoveWindow ( _HMG_aControlMiscData1[x] [1], col + Width - sx - GETVSCROLLBARWIDTH() , Row + Height - sy - GetHScrollBarHeight() , 0 , 0 , .T. )

            ENDIF

            _BrowseRefresh ( '' , '' , x )
            ReDrawWindow ( _HMG_aControlIds [x] )
            ReDrawWindow ( _HMG_aControlMiscData1 [x] [1] )
         ELSE
            MoveWindow ( c , col - sx , Row - sy , Width , Height , .T. )
         ENDIF

      ELSE

         _HMG_aControlRow    [ x ] := Row + _HMG_aControlContainerRow [x]
         _HMG_aControlCol    [ x ] := Col + _HMG_aControlContainerCol [x]
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         IF _HMG_aControlIds[x] != 0

            MoveWindow ( c , col + _HMG_aControlContainerCol [x] - sx, Row + _HMG_aControlContainerRow [x] - sy , Width - GETVSCROLLBARWIDTH() , Height , .T. )

            hws := 0
            FOR b := 1 TO Len ( _HMG_aControlProcedures [x] )
               hws += ListView_GetColumnWidth ( _HMG_aControlHandles [x] , b - 1 )
            NEXT b

            IF hws > _HMG_aControlWidth[x] - GETVSCROLLBARWIDTH() - 4

               MoveWindow ( _HMG_aControlIds[x] , col + _HMG_aControlContainerCol [x] + Width - sx - GETVSCROLLBARWIDTH() , Row + _HMG_aControlContainerRow [x] - sy, GETVSCROLLBARWIDTH() , Height - GetHScrollBarHeight() , .T. )
               MoveWindow ( _HMG_aControlMiscData1[x] [1], col + _HMG_aControlContainerCol [x] + Width - sx - GETVSCROLLBARWIDTH() , Row + _HMG_aControlContainerRow [x] + Height - sy - GetHScrollBarHeight() , ;
                  GetWindowWidth( _HMG_aControlMiscData1[x] [1] ) , GetWindowHeight( _HMG_aControlMiscData1[x][1] ) , .T. )

            ELSE

               MoveWindow ( _HMG_aControlIds [x] , col + _HMG_aControlContainerCol [x] + Width - sx - GETVSCROLLBARWIDTH() , Row + _HMG_aControlContainerRow [x] - sy, GETVSCROLLBARWIDTH() , Height , .T. )
               MoveWindow ( _HMG_aControlMiscData1 [x] [1] , col + _HMG_aControlContainerCol [x] + Width - sx - GETVSCROLLBARWIDTH() , Row + _HMG_aControlContainerRow [x] + Height - sy - GetHScrollBarHeight() , 0 , 0 , .T. )

            ENDIF

            _BrowseRefresh ( '' , '' , x )
            ReDrawWindow ( _HMG_aControlIds [x] )
            ReDrawWindow ( _HMG_aControlMiscData1 [x] [1] )

         ELSE
            MoveWindow ( c , col + _HMG_aControlContainerCol [x] - sx , Row + _HMG_aControlContainerRow [x] - sy , Width , Height , .T. )
         ENDIF

      ENDIF

      ReDrawWindow ( c )
#endif
   CASE T == "RADIOGROUP"

      IF _HMG_aControlContainerRow [x] == -1

         _HMG_aControlRow    [ x ] := Row
         _HMG_aControlCol    [ x ] := Col
         _HMG_aControlWidth  [ x ] := Width

         FOR i := 1 TO Len ( c )

            IF _HMG_aControlMiscData1 [ x ] == .T.
               NewCol := Col + ( i - 1 ) * ( Width + _HMG_aControlSpacing [ x ] )
               MoveWindow ( c [i] , NewCol - sx , Row - sy , Width , height , .T. )
            ELSE
               NewRow := Row + ( i - 1 ) * _HMG_aControlSpacing [ x ]
               MoveWindow ( c [i] , col - sx , NewRow - sy , Width , 28 , .T. )
            ENDIF

         NEXT i

      ELSE

         _HMG_aControlRow    [ x ] := Row + _HMG_aControlContainerRow [x]
         _HMG_aControlCol    [ x ] := Col + _HMG_aControlContainerCol [x]
         _HMG_aControlWidth  [ x ] := Width

         FOR i := 1 TO Len ( c )

            IF _HMG_aControlMiscData1 [ x ] == .T.
               NewCol := Col + _HMG_aControlContainerCol [x] + ( i - 1 ) * ( Width + _HMG_aControlSpacing [ x ] )
               // JD 07/20/2007 Added _HMG_aControlContainerRow [x]
               MoveWindow ( c [i] , NewCol - sx , Row + _HMG_aControlContainerRow [x] - sy , Width , height , .T. )
            ELSE
               NewRow := Row + _HMG_aControlContainerRow [x] + ( i - 1 ) * _HMG_aControlSpacing [ x ]
               MoveWindow ( c [i] , Col + _HMG_aControlContainerCol [x] - sx , NewRow - sy , Width , 28 , .T. )
            ENDIF

         NEXT i

      ENDIF

   CASE T == "BTNTEXT" .OR. T == "BTNNUMTEXT" .OR. ( T == "GETBOX" .AND. _HMG_aControlMiscData1 [x] [4] != Nil )

      IF _HMG_aControlContainerRow [x] == -1

         _HMG_aControlRow    [ x ] := Row
         _HMG_aControlCol    [ x ] := Col
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         IF T == "GETBOX"

            MoveWindow ( _HMG_aControlRangeMin [x] [1] , col - sx , row - sy , width , height , .T. )
            MoveBtnTextBox ( _HMG_aControlRangeMin [x] [1] , _HMG_aControlRangeMin [x] [2] , _HMG_aControlRangeMin [x] [3] , ;
               _HMG_aControlMiscData1 [x] [7] , _HMG_aControlMiscData1 [x] [6] , width , height )
         ELSE

            MoveWindow ( _HMG_aControlSpacing [x] [1] , col - sx , row - sy , width , height , .T. )
            MoveBtnTextBox ( _HMG_aControlSpacing [x] [1] , _HMG_aControlSpacing [x] [2] , _HMG_aControlSpacing [x] [3] , ;
               _HMG_aControlMiscData1 [x] [2] , _HMG_aControlRangeMin [x] , width , height )
         ENDIF

      ELSE

         _HMG_aControlRow    [ x ] := Row + _HMG_aControlContainerRow [x]
         _HMG_aControlCol    [ x ] := Col + _HMG_aControlContainerCol [x]
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         IF T == "GETBOX"

            MoveWindow ( _HMG_aControlRangeMin [x] [1] , col + _HMG_aControlContainerCol [x] - sx , row + _HMG_aControlContainerRow [x] - sy , width , height , .T. )
            MoveBtnTextBox ( _HMG_aControlRangeMin [x] [1] , _HMG_aControlRangeMin [x] [2] , _HMG_aControlRangeMin [x] [3] , ;
               _HMG_aControlMiscData1 [x] [7] , _HMG_aControlMiscData1 [x] [6] , width , height )
         ELSE

            MoveWindow ( _HMG_aControlSpacing [x] [1] , col + _HMG_aControlContainerCol [x] - sx , row + _HMG_aControlContainerRow [x] - sy , width , height , .T. )
            MoveBtnTextBox ( _HMG_aControlSpacing [x] [1] , _HMG_aControlSpacing [x] [2] , _HMG_aControlSpacing [x] [3] , ;
               _HMG_aControlMiscData1 [x] [2] , _HMG_aControlRangeMin [x] , width , height )
         ENDIF

      ENDIF

   OTHERWISE

      IF _HMG_aControlContainerRow [x] == -1

         _HMG_aControlRow    [ x ] := Row
         _HMG_aControlCol    [ x ] := Col
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         MoveWindow ( c , col - sx , row - sy , width , height , .T. )

      ELSE

         _HMG_aControlRow    [ x ] := Row + _HMG_aControlContainerRow [x]
         _HMG_aControlCol    [ x ] := Col + _HMG_aControlContainerCol [x]
         _HMG_aControlWidth  [ x ] := Width
         _HMG_aControlHeight [ x ] := Height

         MoveWindow ( c , col + _HMG_aControlContainerCol [x] - sx , row + _HMG_aControlContainerRow [x] - sy , width , height , .T. )

      ENDIF

      IF T == "LABEL" .OR. T == "BUTTON"
         _Refresh( x )
      ENDIF

   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetItemCount ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL nRetVal As Numeric
   LOCAL t , c

   t := GetControlType ( ControlName , ParentForm )
   c := GetControlHandle ( ControlName , ParentForm )

   DO CASE

   CASE t == "TREE"
      nRetVal := TreeView_GetCount ( c )

   CASE "LIST" $ t
      nRetVal := ListBoxGetItemCount ( c )

   CASE t == "COMBO"
      nRetVal := ComboBoxGetItemCount ( c )

   CASE "GRID" $ t
      nRetVal := ListViewGetItemCount ( c )

   CASE t == "TAB"
      nRetVal := Len ( _HMG_aControlPageMap [ GetControlIndex( ControlName , ParentForm ) ] )

   ENDCASE

RETURN nRetVal

*-----------------------------------------------------------------------------*
FUNCTION _GetControlRow ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL mVar := '_' + ParentForm + '_' + ControlName
   LOCAL i := __mvGet ( mVar )

   IF i == 0 .OR. ( ValType ( _HMG_aControlRow [i] ) == 'U' .AND. ValType ( _HMG_aControlCol [i] ) == 'U' )
      RETURN 0
   ENDIF

RETURN iif ( _HMG_aControlContainerRow [ i ] == -1, _HMG_aControlRow [i], _HMG_aControlRow [i] - _HMG_aControlContainerRow [i] )

*-----------------------------------------------------------------------------*
FUNCTION _GetControlCol ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL mVar := '_' + ParentForm + '_' + ControlName
   LOCAL i := __mvGet ( mVar )

   IF i == 0 .OR. ( ValType ( _HMG_aControlRow [i] ) == 'U' .AND. ValType ( _HMG_aControlCol [i] ) == 'U' )
      RETURN 0
   ENDIF

RETURN iif ( _HMG_aControlContainerCol [i] == -1, _HMG_aControlCol [i], _HMG_aControlCol [i] - _HMG_aControlContainerCol [i] )

*-----------------------------------------------------------------------------*
FUNCTION _GetControlWidth ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL mVar := '_' + ParentForm + '_' + ControlName
   LOCAL i := __mvGet ( mVar )

   IF i == 0
      RETURN 0
   ENDIF

RETURN ( _HMG_aControlWidth [i] )

*-----------------------------------------------------------------------------*
FUNCTION _GetControlHeight ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL mVar := '_' + ParentForm + '_' + ControlName
   LOCAL i := __mvGet ( mVar )

   IF i == 0
      RETURN 0
   ENDIF

RETURN ( _HMG_aControlHeight [i] )

*-----------------------------------------------------------------------------*
FUNCTION _SetControlCaption ( ControlName , ParentForm , Value )
*-----------------------------------------------------------------------------*
   LOCAL cValue As String
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   Assign cValue := Value
   _HMG_aControlCaption [i] := cValue

   IF _HMG_aControlType [i] == 'TOOLBUTTON'
      SetToolButtonCaption ( _HMG_aControlContainerHandle [i] , _HMG_aControlIds [i] , cValue )
   ELSE
      SetWindowText ( GetControlHandle( ControlName , ParentForm ) , cValue )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetPicture ( ControlName , ParentForm , FileName )
*-----------------------------------------------------------------------------*
   LOCAL w, h, t, i, c, cImage, oGet

   c := GetControlHandle ( ControlName , ParentForm )
   i := GetControlIndex ( ControlName , ParentForm )
   t := GetControlType ( ControlName , ParentForm )

   DO CASE

   CASE t == 'IMAGE'

      IF Empty( _HMG_aControlValue [i] )
         w := _HMG_aControlRangeMin [i]  // original Width
         h := _HMG_aControlRangeMax [i]  // original Height
      ELSE
         w := _HMG_aControlWidth [i]
         h := _HMG_aControlHeight [i]
      ENDIF

      DeleteObject ( _hmg_aControlBrushHandle [i] )
      _HMG_aControlPicture [i] := FileName

      _HMG_aControlBrushHandle [i] := C_SetPicture ( c , FileName , w , h , _HMG_aControlValue [i] , _HMG_aControlInputMask [i] , ;
         _HMG_aControlSpacing [i] , _HMG_aControlCaption [i] , _HMG_aControlDblClick [i] .AND. HasAlpha( FileName ) , _HMG_aControlMiscData1 [i] )

      IF Empty( _HMG_aControlValue [i] )
         _HMG_aControlWidth [i] := GetWindowWidth  ( c )
         _HMG_aControlHeight [i] := GetWindowHeight ( c )
      ENDIF

   CASE t == 'GETBOX'

      oGet := _HMG_aControlHeadClick [i]
      oGet:SetFocus()
      oGet:Picture := Filename
      _HMG_aControlInputMask [i] := _GetPictureData ( oGet , Filename )

      _SetValue( , , oGet:VarGet(), i )

   CASE t == 'BTNTEXT' .OR. t == 'BTNNUMTEXT'

      DeleteObject ( _HMG_aControlSpacing [i][4] )
      _HMG_aControlPicture [i] := FileName
      cImage := iif( ISARRAY ( Filename ), Filename [1], Filename )
      _HMG_aControlSpacing [i][4] := _SetBtnPicture ( _HMG_aControlSpacing [i][2] , cImage )
      IF ISARRAY ( Filename )
         DeleteObject ( _HMG_aControlSpacing [i][5] )
         _HMG_aControlSpacing [i][5] := _SetBtnPicture ( _HMG_aControlSpacing [i][3] , Filename [2] )
      ENDIF

   CASE t == 'TOOLBUTTON'

      IF _HMG_aControlMiscData1 [i] == 1
         SetToolButtonImage ( _HMG_aControlContainerHandle [i] , _HMG_aControlIds [i] , hb_defaultValue ( Filename , 0 ) )
      ELSE
         h := _HMG_aControlHandles [i]
         _HMG_aControlHandles [i] := ReplaceToolButtonImage ( _HMG_aControlContainerHandle [i] , c , Filename , Empty( Filename ) , _HMG_aControlIds [i] )
         ReDrawWindow ( _HMG_aControlContainerHandle [i] )
         _HMG_aControlPicture [i] := FileName
         IF !Empty( _HMG_aControlHandles [i] )
            DeleteObject ( h )
         ENDIF
      ENDIF

   OTHERWISE  // picture for [check]buttons

      IF _HMG_aControlEnabled [i] == .T.

         IF !Empty( _HMG_aControlBrushhandle [i] )
            IF t <> "OBUTTON" .AND. _HMG_IsThemed
               ImageList_Destroy ( _HMG_aControlBrushHandle [i] )
            ENDIF
            DeleteObject ( _HMG_aControlBrushHandle [i] )
         ENDIF

         _HMG_aControlPicture [i] := FileName
         cImage := iif( ISARRAY ( Filename ) , Filename [1] , Filename )

         IF _HMG_aControlMiscData1 [i] == 0  // bitmap
            IF t <> "OBUTTON" .AND. _HMG_IsThemed
               _HMG_aControlBrushHandle [i] := _SetMixedBtnPicture ( c , cImage )
               ReDrawWindow ( c )
            ELSE
               IF t == "OBUTTON"
                  _HMG_aControlBrushHandle [i] := _SetBtnPicture ( c , cImage , _HMG_aControlHeadClick [i][1] , _HMG_aControlHeadClick [i][2] )
               ELSE
                  _HMG_aControlBrushHandle [i] := _SetBtnPicture ( c , cImage , -1 , -1 )
               ENDIF
            ENDIF
         ELSE                                // icon
            IF t <> "OBUTTON" .AND. _HMG_IsThemed
               _HMG_aControlBrushHandle [i] := _SetMixedBtnIcon ( c , cImage )
               ReDrawWindow ( c )
            ELSE
               _HMG_aControlBrushHandle [i] := _SetBtnIcon ( c , cImage )
            ENDIF
         ENDIF

      ENDIF

   END CASE

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION _EnableToolbarButton ( ButtonName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL i , cCaption , c , bAction

   IF ( i := GetControlIndex ( ButtonName, FormName ) ) > 0

      EnableToolButton ( _HMG_aControlContainerHandle [i] , GetControlId ( ButtonName , FormName ) )

      bAction := _HMG_aControlProcedures [i]
      cCaption := _HMG_aControlCaption [i]

      IF ValType ( cCaption ) != 'U'

         cCaption := Upper ( cCaption )

         IF ( i := At ( '&' , cCaption ) ) > 0

            c := Asc ( SubStr ( cCaption , i + 1 , 1 ) )
            IF c >= 48 .AND. c <= 90
               _DefineHotKey ( FormName , MOD_ALT , c , bAction )
            ENDIF

         ENDIF

      ENDIF

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION _DisableToolbarButton ( ButtonName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL i , cCaption , c

   IF ( i := GetControlIndex ( ButtonName , FormName ) ) > 0

      DisableToolButton ( _HMG_aControlContainerHandle [i] , GetControlId ( ButtonName , FormName ) )

      cCaption := _HMG_aControlCaption [i]

      IF ValType ( cCaption ) != 'U'

         cCaption := Upper ( cCaption )

         IF ( i := At ( '&' , cCaption ) ) > 0

            c := Asc ( SubStr ( cCaption , i + 1 , 1 ) )
            IF c >= 48 .AND. c <= 90
               _ReleaseHotKey ( FormName , MOD_ALT , c )
            ENDIF

         ENDIF

      ENDIF

   ENDIF

RETURN Nil

// (JK) HMG 1.0 Experimental Build 8
*-----------------------------------------------------------------------------*
FUNCTION _GetComboItemValue ( ControlName , ParentForm , nItemIndex )
*-----------------------------------------------------------------------------*
   LOCAL nItem As Numeric

   IF GetControlIndex ( ControlName , ParentForm ) == 0
      RETURN NIL
   ENDIF

   Assign nItem := nItemIndex

RETURN ComboGetString ( GetControlHandle ( ControlName , ParentForm ) , nItem )

*-----------------------------------------------------------------------------*
FUNCTION _GetControlAction ( ControlName , ParentForm , cEvent )
*-----------------------------------------------------------------------------*
   LOCAL bAction As Block
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i != 0

      DO CASE
      CASE cEvent == 'ONCHANGE'
         bAction := _HMG_aControlChangeProcedure [i]

      CASE cEvent == 'ONGOTFOCUS'
         bAction := _HMG_aControlGotFocusProcedure [i]

      CASE cEvent == 'ONLOSTFOCUS'
         bAction := _HMG_aControlLostFocusProcedure [i]

      CASE cEvent == 'ONDBLCLICK'
         IF GetControlType ( ControlName, ParentForm ) $ "BROWSE,GRID,LISTBOX,TREE"
            bAction := _HMG_aControlDblClick [i]
         ENDIF

      OTHERWISE
         bAction := _HMG_aControlProcedures [i]
      END CASE

   ENDIF

RETURN bAction

*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetControlAction ( ControlName , ParentForm , Value , cEvent )
*-----------------------------------------------------------------------------*
   LOCAL bBlock As Block
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN Nil
   ENDIF

   Assign bBlock := Value

   DO CASE
   CASE cEvent == 'ONCHANGE'
      _HMG_aControlChangeProcedure [i] := bBlock
   CASE cEvent == 'ONGOTFOCUS'
      _HMG_aControlGotFocusProcedure [i] := bBlock
   CASE cEvent == 'ONLOSTFOCUS'
      _HMG_aControlLostFocusProcedure [i] := bBlock
   CASE cEvent == 'ONDBLCLICK'
      IF GetControlType ( ControlName, ParentForm ) $ "BROWSE,GRID,LISTBOX,TREE"
         _HMG_aControlDblClick [i] := bBlock
      ENDIF
   OTHERWISE
      _HMG_aControlProcedures [i] := bBlock
   END CASE

   IF _HMG_aControlType [i] $ 'IMAGE,LABEL'
      ChangeStyle ( _HMG_aControlHandles [i] , SS_NOTIFY )
   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetToolTip ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN ''
   ENDIF

RETURN ( _HMG_aControlToolTip [i] )

*-----------------------------------------------------------------------------*
FUNCTION _SetToolTip ( ControlName , ParentForm , Value , Page )
*-----------------------------------------------------------------------------*
   LOCAL cValue As String
   LOCAL i , t , c , h

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) > 0

      Assign cValue := Value
      c := GetControlHandle ( ControlName , ParentForm )
      t := GetControlType ( ControlName , ParentForm )
      IF t == 'TAB'
         IF ISNUMBER( Page )  // GF 10/12/2010
            IF Page > 0 .AND. Page <= Len( _HMG_aControlToolTip [i] )
               _HMG_aControlToolTip [i] [Page] := cValue
            ENDIF
         ENDIF
      ELSE
         _HMG_aControlToolTip [i] := cValue
         IF t $ 'IMAGE,LABEL'
            ChangeStyle ( _HMG_aControlHandles [i] , SS_NOTIFY )
         ELSEIF t == 'SPINNER'
            c := c [1]
         ENDIF
         h := GetFormToolTipHandle ( ParentForm )
         IF t == 'RADIOGROUP'
            AEval ( c, { |x| SetToolTip ( x , cValue , h ) } )
         ELSEIF !( t == "TOOLBUTTON" )  // GF 15/11/2016
            SetToolTip ( c , cValue , h )
         ENDIF
         // HMG 1.0 Experimental Build 8
         IF t == 'COMBO'  // tooltips for editable or/and extend combo
            IF !Empty( _hmg_acontrolrangemin [i] )
               SetToolTip ( _hmg_acontrolrangemin [i] , cValue , h )
            ENDIF
            IF !Empty( _hmg_acontrolrangemax [i] )
               SetToolTip ( _hmg_acontrolrangemax [i] , cValue , h )
            ENDIF
         ENDIF
      ENDIF

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetMultiToolTip ( ControlName , ParentForm , Item )  // GF 10/12/2010
*-----------------------------------------------------------------------------*
   LOCAL nItem As Numeric
   LOCAL i

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) > 0

      Assign nItem := Item
      IF nItem <= _GetItemCount ( ControlName , ParentForm )
         RETURN ( _HMG_aControlToolTip [i] [nItem] )
      ENDIF

   ENDIF

RETURN ''

*-----------------------------------------------------------------------------*
FUNCTION _SetRangeMin ( ControlName, ParentForm , Value  )
*-----------------------------------------------------------------------------*
   LOCAL i , h , t , m

   i := GetControlIndex ( ControlName , ParentForm )
   h := _HMG_aControlHandles [i]
   t := GetControlType ( ControlName , ParentForm )
   m := _HMG_aControlRangeMax [i]

   DO CASE

   CASE t == 'SLIDER'
      SetSliderRange ( h , Value , m )

   CASE t == 'SPINNER'
      SetSpinnerRange ( h [2] , Value , m )

   CASE t == 'PROGRESSBAR'
      SetProgressBarRange ( h , Value , m )

   CASE t == 'DATEPICK'
      _SetDatePickerRange ( h , Value , m , i )

   END CASE

   _HMG_aControlRangeMin [i] := Value

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _SetRangeMax ( ControlName , ParentForm , Value  )
*-----------------------------------------------------------------------------*
   LOCAL i , h , t , m

   i := GetControlIndex ( ControlName , ParentForm )
   h := _HMG_aControlHandles [i]
   t := GetControlType ( ControlName , ParentForm )
   m := _HMG_aControlRangeMin [i]

   DO CASE

   CASE t == 'SLIDER'
      SetSliderRange ( h , m , Value  )

   CASE t == 'SPINNER'
      SetSpinnerRange ( h [2] , m , Value )

   CASE t == 'PROGRESSBAR'
      SetProgressBarRange ( h , m , Value )

   CASE t == 'DATEPICK'
      _SetDatePickerRange ( h , m , Value , i )

   END CASE

   _HMG_aControlRangeMax [i] := Value

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetRangeMin ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN 0
   ENDIF

RETURN ( _HMG_aControlRangeMin [i] )

*-----------------------------------------------------------------------------*
FUNCTION _GetRangeMax ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN 0
   ENDIF

RETURN ( _HMG_aControlRangeMax [i] )

*-----------------------------------------------------------------------------*
FUNCTION _SetMultiCaption ( ControlName , ParentForm , Column , Value  )
*-----------------------------------------------------------------------------*
   LOCAL nColumn As Numeric
   LOCAL i , h , t

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) > 0  // JD 11/30/2006

      h := _HMG_aControlhandles [i]
      t := GetControlType ( ControlName , ParentForm )

      Assign nColumn := Column

      _HMG_aControlCaption [i] [nColumn] := Value

      DO CASE

      CASE 'GRID' $ t
         SETGRIDCOLUMNHEADER ( h , nColumn , Value , _HMG_aControlMiscData1 [i,3] [nColumn] )

      CASE t == 'BROWSE'
         SETGRIDCOLUMNHEADER ( h , nColumn , Value , _HMG_aControlMiscData1 [i,16] [nColumn] )

      CASE t == 'RADIOGROUP'
         SetWindowText ( h [nColumn] , Value )

      CASE t == 'TAB'
         SETTABCAPTION ( h , nColumn , Value )
         UpdateTab ( i )

      ENDCASE

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetMultiCaption ( ControlName , ParentForm , Item )
*-----------------------------------------------------------------------------*
   LOCAL nItem As Numeric
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN ''
   ENDIF

   Assign nItem := Item

RETURN ( _HMG_aControlCaption [i] [nItem] )

*-----------------------------------------------------------------------------*
FUNCTION _SetMultiImage ( ControlName, ParentForm, Column, Value, lRightAlign )
*-----------------------------------------------------------------------------*
   LOCAL i , h , t

   IF ( i := GetControlIndex ( ControlName, ParentForm ) ) > 0

      h := _HMG_aControlhandles [i]

      t := GetControlType ( ControlName, ParentForm )

      DO CASE

      CASE t $ 'MULTIGRID,BROWSE'  // EF 01/09/2008
         SetGridColumnHeaderImage ( h, Column, Value, hb_defaultValue( lRightAlign, .F. ) )

      CASE t == 'TAB'  // JD 11/30/2006
         IF Column > 0 .AND. Column <= Len( _HMG_aControlPicture [i] )
            _HMG_aControlPicture [i] [Column] := Value
         ENDIF

         IF !Empty( _HMG_aControlInputMask [i] )
            IMAGELIST_DESTROY ( _HMG_aControlInputMask [i] )
         ENDIF

         _HMG_aControlInputMask [i] := AddTabBitMap ( h, _HMG_aControlPicture [i] )
         UpdateTab ( i )

      CASE t == 'TREE'  // GF 12/23/2013
         TreeItemChangeImage ( ControlName, ParentForm, Column, Value )

      ENDCASE

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetMultiImage ( ControlName , ParentForm , Item )  // JD 11/30/2006
*-----------------------------------------------------------------------------*
   LOCAL nItem As Numeric
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN ''
   ENDIF

   Assign nItem := Item

RETURN ( _HMG_aControlPicture [i] [nItem] )

*-----------------------------------------------------------------------------*
FUNCTION InputWindow ( cTitle, aLabels, aValues, aFormats, nRow, nCol, lCenterWindow, aButOKCancelCaptions, nLabelWidth, nControlWidth )
*-----------------------------------------------------------------------------*
   LOCAL i, l, ControlRow := 10, ControlCol, e := 0, LN, CN, r, c, nWidth, wHeight, diff, lExtendedNavigation

   lCenterWindow := ( nRow == NIL .AND. nCol == NIL )
   DEFAULT nRow TO 0, nCol TO 0
   DEFAULT aButOKCancelCaptions TO {}
   DEFAULT nLabelWidth TO 90, nControlWidth TO 140

   IF Len( aButOKCancelCaptions ) == 0
      AAdd( aButOKCancelCaptions, _HMG_MESSAGE [6] )
      AAdd( aButOKCancelCaptions, _HMG_MESSAGE [7] )
   ENDIF

   l := Len ( aLabels )

   PRIVATE aResult [l]

   lExtendedNavigation := _HMG_ExtendedNavigation
   _HMG_ExtendedNavigation := .T.

   FOR i := 1 TO l

      IF ValType ( aValues [i] ) == 'C'
         IF ValType ( aFormats [i] ) == 'N'
            IF aFormats [i] > 32
               e++
            ENDIF
         ENDIF
      ENDIF

      IF ValType ( aValues [i] ) == 'M'
         e++
      ENDIF

   NEXT i

   wHeight := l * 30 + 90 + e * 60

   IF PCount() == 4
      r := 0
      c := 0
   ELSE
      r := nRow
      c := nCol
      IF r + wHeight > GetDeskTopHeight()
         diff := r + wHeight - GetDeskTopHeight()
         r -= diff
      ENDIF
   ENDIF

   nWidth := nLabelWidth + nControlWidth + 50

   ControlCol := nLabelWidth + 30

   DEFINE WINDOW _InputWindow ;
      AT r, c ;
      WIDTH nWidth ;
      HEIGHT wHeight ;
      TITLE cTitle ;
      MODAL ;
      NOSIZE ;
      ON INIT _SetFocus ( 'Control_1' , '_InputWindow' )

   FOR i := 1 TO l

      LN := 'Label_' + hb_ntos( i )
      CN := 'Control_' + hb_ntos( i )

      @ ControlRow , 10 LABEL &LN VALUE aLabels [i] WIDTH nLabelWidth

      diff := 30

      SWITCH ValType ( aValues [i] )
      CASE 'L'
         @ ControlRow , ControlCol CHECKBOX &CN CAPTION '' VALUE aValues [i] WIDTH 16 HEIGHT 16
         EXIT
      CASE 'D'
         @ ControlRow , ControlCol DATEPICKER &CN VALUE aValues [i] WIDTH nControlWidth
         EXIT
      CASE 'N'
         IF ValType ( aFormats [i] ) == 'A'
            @ ControlRow , ControlCol COMBOBOX &CN ITEMS aFormats [i] VALUE aValues [i] WIDTH nControlWidth
         ELSEIF  ValType ( aFormats [i] ) == 'C'
            IF At ( '.' , aFormats [i] ) > 0
               @ ControlRow , ControlCol TEXTBOX &CN VALUE aValues [i] WIDTH nControlWidth NUMERIC INPUTMASK aFormats [i]
            ELSE
               @ ControlRow , ControlCol TEXTBOX &CN VALUE aValues [i] WIDTH nControlWidth MAXLENGTH Len( aFormats [i] ) NUMERIC
            ENDIF
         ENDIF
         EXIT
      CASE 'C'
         IF ValType ( aFormats [i] ) == 'N'
            IF aFormats [i] <= 32
               @ ControlRow , ControlCol TEXTBOX &CN VALUE aValues [i] WIDTH nControlWidth MAXLENGTH aFormats [i]
            ELSE
               @ ControlRow , ControlCol EDITBOX &CN WIDTH nControlWidth HEIGHT 90 VALUE aValues [i] MAXLENGTH aFormats [i]
               diff := 94
            ENDIF
         ENDIF
         EXIT
      CASE 'M'
         @ ControlRow , ControlCol EDITBOX &CN WIDTH nControlWidth HEIGHT 90 VALUE aValues [i]
         diff := 94
      ENDSWITCH

      ControlRow += diff

   NEXT i

   @ ControlRow + 10 , nWidth / 2 - 110 BUTTON BUTTON_1 ;
      CAPTION '&' + aButOKCancelCaptions [1] ;
      ACTION _InputWindowOk()

   @ ControlRow + 10 , nWidth / 2 BUTTON BUTTON_2 ;
      CAPTION '&' + aButOKCancelCaptions [2] ;
      ACTION _InputWindowCancel()

   END WINDOW

   IF lCenterWindow
      CENTER WINDOW _InputWindow
   ENDIF

   ACTIVATE WINDOW _InputWindow

   _HMG_ExtendedNavigation := lExtendedNavigation

RETURN ( aResult )

*-----------------------------------------------------------------------------*
FUNCTION _InputWindowOk
*-----------------------------------------------------------------------------*

   AEval( aResult, {|x, i| HB_SYMBOL_UNUSED( x ), aResult [i] := _GetValue ( 'Control_' + hb_ntos( i ), '_InputWindow' ) } )

   RELEASE WINDOW _InputWindow

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _InputWindowCancel
*-----------------------------------------------------------------------------*

   AEval( aResult, {|x, i| HB_SYMBOL_UNUSED( x ), aResult [i] := Nil } )

   RELEASE WINDOW _InputWindow

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _ReleaseControl ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i , t , r , w , z , x , y , k

   i := GetControlIndex ( ControlName, ParentForm )
   t := GetControlType ( ControlName, ParentForm )
   k := GetFormIndex ( ParentForm )

   DO CASE

   CASE t == "ANIMATEBOX"
      _DestroyAnimateBox ( ControlName, ParentForm )

   CASE t == "PLAYER"
      _DestroyPlayer ( ControlName, ParentForm )

   CASE t == "SPINNER" .OR. t == "RADIOGROUP"
      AEval ( _HMG_aControlHandles [i], { |y| ReleaseControl ( y ) } )

   CASE t == "MESSAGEBAR"
      IF _IsControlDefined ( 'StatusBarKbd' , ParentForm )
         ReleaseControl ( _HMG_aControlHandles [ GetControlIndex ( 'StatusBarKbd' , ParentForm ) ] )
         _EraseControl ( GetControlIndex ( 'StatusBarKbd' , ParentForm ) , k )
      ENDIF

      IF _IsControlDefined ( 'StatusTimer' , ParentForm )
         ReleaseControl ( _HMG_aControlHandles [ GetControlIndex ( 'StatusTimer' , ParentForm) ] )
         _EraseControl ( GetControlIndex ( 'StatusTimer' , ParentForm ) , k )
      ENDIF

      IF _IsControlDefined ( 'StatusKeyBrd' , ParentForm )
         ReleaseControl ( _HMG_aControlHandles [ GetControlIndex ( 'StatusKeyBrd' , ParentForm ) ] )
         _EraseControl ( GetControlIndex ( 'StatusKeyBrd' , ParentForm ) , k )
      ENDIF

      IF ( z := SendMessage( _HMG_aControlHandles [i], SB_GETPARTS, 0, 0 ) ) > 0
         FOR x := 1 TO z
            SetStatusItemIcon ( _HMG_aControlHandles [i] , x , Nil )
         NEXT x
      ENDIF

      ReleaseControl ( _HMG_aControlHandles [i] )

#ifdef _DBFBROWSE_
   CASE t == "BROWSE"
      ReleaseControl ( _HMG_aControlHandles [i] )

      IF _HMG_aControlIds [i] != 0

         ReleaseControl ( _HMG_aControlIds [i] )
         ReleaseControl ( _HMG_aControlMiscData1 [i] [1] )

      ENDIF
#endif

   CASE t == "TAB"
      FOR r := 1 TO Len ( _HMG_aControlPageMap [i] )

         FOR w := 1 TO Len ( _HMG_aControlPageMap [i] [r] )

            IF ValType ( _HMG_aControlPageMap [i] [r] [w] ) <> "A"
               ReleaseControl ( _HMG_aControlPageMap [i] [r] [w] )
               x := AScan ( _HMG_aControlHandles , _HMG_aControlPageMap [i] [r] [w] )
               IF x > 0
                  _EraseControl( x, k )
               ENDIF
            ELSE
               FOR z := 1 TO Len ( _HMG_aControlPageMap [i] [r] [w] )
                  ReleaseControl ( _HMG_aControlPageMap [i] [r] [w] [z] )
               NEXT z

               FOR x := 1 TO Len ( _HMG_aControlHandles )
                  IF ValType( _HMG_aControlHandles [x] ) == 'A'
                     IF _HMG_aControlHandles [x] [1] == _HMG_aControlPageMap [i] [r] [w] [1]
                        _EraseControl( x, k )
                        EXIT
                     ENDIF
                  ENDIF
               NEXT x

            ENDIF

         NEXT w

      NEXT r

      ReleaseControl ( _HMG_aControlHandles [i] )

   OTHERWISE

      IF i > 0
         ReleaseControl ( _HMG_aControlHandles [i] )
      ENDIF

   ENDCASE

   // If the control is inside a TAB, PageMap must be updated

   FOR y := 1 TO Len ( _HMG_aControlPageMap )

      IF _HMG_aControlType [y] == "TAB"

         FOR r := 1 TO Len ( _HMG_aControlPageMap [y] )

            FOR w := 1 TO Len ( _HMG_aControlPageMap [y] [r] )

               IF t == 'RADIOGROUP'

                  IF ValType ( _HMG_aControlPageMap [y] [r] [w] ) == 'A'

                     IF _HMG_aControlPageMap [y] [r] [w] [1] == _HMG_aControlHandles [i] [1]

                        ADel ( _HMG_aControlPageMap [y] [r] , w )
                        ASize ( _HMG_aControlPageMap [y] [r] , Len( _HMG_aControlPageMap [y] [r] ) - 1 )
                        EXIT

                     ENDIF

                  ENDIF

               ELSEIF t == 'SPINNER'

                  IF ValType ( _HMG_aControlPageMap [y] [r] [w] ) == 'A'

                     IF _HMG_aControlPageMap [y] [r] [w] [1] == _HMG_aControlHandles [i] [1]

                        ADel ( _HMG_aControlPageMap [y] [r] , w )
                        ASize ( _HMG_aControlPageMap [y] [r] , Len( _HMG_aControlPageMap [y] [r] ) - 1 )
                        EXIT

                     ENDIF

                  ENDIF
#ifdef _DBFBROWSE_
               ELSEIF t == 'BROWSE'

                  IF ValType ( _HMG_aControlPageMap [y] [r] [w] ) == 'A'

                     IF _HMG_aControlPageMap [y] [r] [w] [1] == _HMG_aControlHandles [i]

                        ADel ( _HMG_aControlPageMap [y] [r] , w )
                        ASize ( _HMG_aControlPageMap [y] [r] , Len( _HMG_aControlPageMap [y] [r] ) - 1 )
                        EXIT

                     ENDIF

                  ELSEIF ValType ( _HMG_aControlPageMap [y] [r] [w] ) == 'N'

                     IF _HMG_aControlPageMap [y] [r] [w] == _HMG_aControlHandles [i]

                        ADel ( _HMG_aControlPageMap [y] [r] , w )
                        ASize ( _HMG_aControlPageMap [y] [r] , Len( _HMG_aControlPageMap [y] [r] ) - 1 )
                        EXIT

                     ENDIF

                  ENDIF
#endif
               ELSE

                  IF ValType ( _HMG_aControlPageMap [y] [r] [w] ) == 'N'

                     IF _HMG_aControlPageMap [y] [r] [w] == _HMG_aControlHandles [i]

                        ADel ( _HMG_aControlPageMap [y] [r] , w )
                        ASize ( _HMG_aControlPageMap [y] [r] , Len( _HMG_aControlPageMap [y] [r] ) - 1 )
                        EXIT

                     ENDIF

                  ENDIF

               ENDIF

            NEXT w

         NEXT r

      ENDIF

   NEXT y

   _EraseControl( i, k )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EraseControl ( i, p )
*-----------------------------------------------------------------------------*
   LOCAL mVar, t, hWnd, x

   DeleteObject ( _HMG_aControlFontHandle [i] )
   DeleteObject ( _HMG_aControlBrushHandle [i] )

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlDestroy, i )
   ENDIF

   t := _HMG_aControlType [i]

   DO CASE

   CASE t == 'HOTKEY'
      ReleaseHotKey ( _HMG_aControlParentHandles [i] , _HMG_aControlIds [i] )
   CASE 'LABEL' $ t
      IF _HMG_aControlMiscData1 [i] [2] == .T.
         _ReleaseControl ( 'BlinkTimer' + hb_ntos( i ), _HMG_aFormNames [p] )
      ENDIF
      IF ISARRAY( _HMG_aControlPicture [i] ) // erase CheckLabel bitmap
         x := _HMG_aControlPicture [i] [1]
         IF File( x ) .AND. cFilePath ( x ) == GetTempFolder()
            FErase( x )
         ENDIF
      ENDIF
   CASE t == 'BUTTON' .OR. t == 'CHECKBOX'
      IF !Empty( _HMG_aControlBrushHandle [i] ) .AND. _HMG_IsThemed
         ImageList_Destroy ( _HMG_aControlBrushHandle [i] )
      ENDIF
   CASE t == 'GETBOX'
      AEval ( _HMG_aControlRangeMin [i], { |x| DeleteObject ( x ) } )
   CASE t == 'BTNTEXT' .OR. t == 'BTNNUMTEXT'
      AEval ( _HMG_aControlSpacing [i], { |x| DeleteObject ( x ) } )
   CASE t == 'TAB'
      IF !Empty( _HMG_aControlInputMask [i] )
         IMAGELIST_DESTROY ( _HMG_aControlInputMask [i] )
      ENDIF
#ifdef _DBFBROWSE_
   CASE t == 'BROWSE'
      IF !Empty( _HMG_aControlMiscData1 [i] [15] )
         IMAGELIST_DESTROY ( _HMG_aControlMiscData1 [i] [15] )
      ENDIF
#endif
   CASE 'GRID' $ t
      IF !Empty( _HMG_aControlRangeMin [i] )
         IMAGELIST_DESTROY ( _HMG_aControlRangeMin [i] )
      ENDIF
   CASE t == 'PAGER'
      // Remove Pager Child Controls
      hWnd := _HMG_aControlHandles [i]
      FOR x := 1 TO Len ( _HMG_aControlHandles )
         IF _HMG_aControlParentHandles [x] == hWnd
            _EraseControl( x, p )
         ENDIF
      NEXT x

   ENDCASE

   mVar := '_' + _HMG_aFormNames [p] + '_' + _HMG_aControlNames [i]

   IF __mvExist ( mVar )
#ifndef _PUBLIC_RELEASE_
      __mvPut ( mVar , 0 )
#else
      __mvXRelease( mVar )
#endif
   ENDIF

   _HMG_aControlDeleted            [i] := .T.
   _HMG_aControlType               [i] := ""
   _HMG_aControlNames              [i] := ""
   _HMG_aControlHandles            [i] := 0
   _HMG_aControlParentHandles      [i] := 0
   _HMG_aControlIds                [i] := 0
   _HMG_aControlProcedures         [i] := ""
   _HMG_aControlPageMap            [i] := {}
   _HMG_aControlValue              [i] := Nil
   _HMG_aControlInputMask          [i] := ""
   _HMG_aControllostFocusProcedure [i] := ""
   _HMG_aControlGotFocusProcedure  [i] := ""
   _HMG_aControlChangeProcedure    [i] := ""
   _HMG_aControlBkColor            [i] := Nil
   _HMG_aControlFontColor          [i] := Nil
   _HMG_aControlDblClick           [i] := ""
   _HMG_aControlHeadClick          [i] := {}
   _HMG_aControlRow                [i] := 0
   _HMG_aControlCol                [i] := 0
   _HMG_aControlWidth              [i] := 0
   _HMG_aControlHeight             [i] := 0
   _HMG_aControlSpacing            [i] := 0
   _HMG_aControlContainerRow       [i] := 0
   _HMG_aControlContainerCol       [i] := 0
   _HMG_aControlPicture            [i] := ''
   _HMG_aControlContainerHandle    [i] := 0
   _HMG_aControlFontName           [i] := ''
   _HMG_aControlFontSize           [i] := 0
   _HMG_aControlToolTip            [i] := ''
   _HMG_aControlRangeMin           [i] := 0
   _HMG_aControlRangeMax           [i] := 0
   _HMG_aControlCaption            [i] := ''
   _HMG_aControlVisible            [i] := .F.
   _HMG_aControlHelpId             [i] := 0
   _HMG_aControlFontHandle         [i] := 0
   _HMG_aControlFontAttributes     [i] := {}
   _HMG_aControlBrushHandle        [i] := 0
   _HMG_aControlEnabled            [i] := .F.
   _HMG_aControlMiscData1          [i] := 0
   _HMG_aControlMiscData2          [i] := ''
#ifdef _HMG_COMPAT_
   IF __mvExist ( '_HMG_SYSDATA[443][i]' )
      _HMG_StopControlEventProcedure [i] := .F.
   ENDIF
#endif

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _IsControlVisibleFromHandle ( Handle )
*-----------------------------------------------------------------------------*
   LOCAL lVisible As Logical
   LOCAL hControl

   FOR EACH hControl IN _HMG_aControlHandles
      IF ValType ( hControl ) == 'N'
         IF hControl == Handle
            lVisible := _HMG_aControlVisible [ hb_enumindex( hControl ) ]
            EXIT
         ENDIF
      ELSEIF ValType ( hControl ) == 'A'
         IF hControl [1] == Handle
            lVisible := _HMG_aControlVisible [ hb_enumindex( hControl ) ]
            EXIT
         ENDIF
      ENDIF
   NEXT

RETURN lVisible

*-----------------------------------------------------------------------------*
FUNCTION _IsControlVisible ( ControlName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL lVisible As Logical
   LOCAL ix

   ix := GetControlIndex ( ControlName, FormName )
   IF ix > 0
      lVisible := _HMG_aControlVisible [ix]
   ENDIF

RETURN lVisible

*-----------------------------------------------------------------------------*
FUNCTION _SetCaretPos ( ControlName , FormName , Pos )
*-----------------------------------------------------------------------------*
   LOCAL nPos As Numeric
   LOCAL i := GetControlIndex ( ControlName, FormName )

   IF i == 0
      RETURN Nil
   ENDIF

   Assign nPos := Pos

   SendMessage( _HMG_aControlhandles [i] , EM_SETSEL , nPos , nPos )
   SendMessage( _HMG_aControlhandles [i] , EM_SCROLLCARET , 0 , 0 )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetCaretPos ( ControlName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL i := GetControlIndex ( ControlName, FormName )

   IF i == 0
      RETURN 0
   ENDIF

RETURN ( HiWord ( SendMessage( _HMG_aControlhandles [i] , EM_GETSEL , 0 , 0 ) ) )

*-----------------------------------------------------------------------------*
PROCEDURE SetProperty( Arg1 , Arg2 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 )
*-----------------------------------------------------------------------------*
   LOCAL i
#ifdef _USERINIT_
   LOCAL cMacro
#endif

   SWITCH PCount()
   CASE 3 // PCount() == 3 (WINDOW)

      IF .NOT. _IsWindowDefined ( Arg1 )
         MsgMiniGuiError( "Window: " + Arg1 + " is not defined." )
      ENDIF

      Arg2 := Upper ( Arg2 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomPropertyProcedure )

         IF Arg2 == _HMG_aCustomPropertyProcedure [i] [1]
            cMacro := _HMG_aCustomPropertyProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 )
            IF _HMG_UserComponentProcess == .T.
               RETURN
            ENDIF
         ENDIF

      NEXT i
#endif
      DO CASE

      CASE Arg2 == "TITLE"

         SetWindowText ( GetFormHandle( Arg1 ) , Arg3 )

      CASE Arg2 == "HEIGHT"

         _SetWindowSizePos ( Arg1 , , , , Arg3 )

      CASE Arg2 == "WIDTH"

         _SetWindowSizePos ( Arg1 , , , Arg3 , )

      CASE Arg2 == "COL"
#ifdef _PANEL_
         IF GetWindowType ( Arg1 ) == 'P'
            Arg3 += GetBorderWidth()
         ENDIF
#endif
         _SetWindowSizePos ( Arg1 , , Arg3 , , )

      CASE Arg2 == "ROW"
#ifdef _PANEL_
         IF GetWindowType ( Arg1 ) == 'P'
            Arg3 += GetTitleHeight() + GetBorderHeight()
         ENDIF
#endif
         _SetWindowSizePos ( Arg1 , Arg3 , , , )

      CASE Arg2 == "NOTIFYICON"

         _SetNotifyIconName ( Arg1 , Arg3 )

      CASE Arg2 == "NOTIFYTOOLTIP"

         _SetNotifyIconTooltip ( Arg1 , Arg3 )

      CASE Arg2 == "CURSOR"

         SetWindowCursor ( GetFormHandle( Arg1 ) , Arg3 )

      CASE Arg2 == "TITLEBAR"

         _ChangeWindowStyle ( Arg1 , WS_CAPTION , Arg3 )

      CASE Arg2 == "SYSMENU"

         _ChangeWindowStyle ( Arg1 , WS_SYSMENU , Arg3 )

      CASE Arg2 == "SIZABLE"

         _ChangeWindowStyle ( Arg1 , WS_SIZEBOX , Arg3 )

      CASE Arg2 == "MAXBUTTON"

         _ChangeWindowStyle ( Arg1 , WS_MAXIMIZEBOX , Arg3 )

      CASE Arg2 == "MINBUTTON"

         _ChangeWindowStyle ( Arg1 , WS_MINIMIZEBOX , Arg3 )

      CASE Arg2 == "CLOSABLE"

         IF IsWindowHasStyle ( GetFormHandle( Arg1 ) , WS_CAPTION ) .AND. IsWindowHasStyle ( GetFormHandle( Arg1 ) , WS_SYSMENU )
            xDisableCloseButton ( GetFormHandle( Arg1 ) , Arg3 )
         ENDIF

      CASE Arg2 == "TOPMOST"

         _ChangeWindowTopmostStyle ( GetFormHandle( Arg1 ) , Arg3 )

      CASE Arg2 == "HELPBUTTON"

         _ChangeWindowHelpButtonStyle ( Arg1 , Arg3 )

      CASE Arg2 == "BACKCOLOR"

         _SetWindowBackColor ( GetFormHandle( Arg1 ) , Arg3 )

      CASE Arg2 == "CARGO"

         _WindowCargo ( Arg1 , Arg3 )

      CASE Arg2 == "MINWIDTH" // Grigory Filatov HMG 1.4 Ext Build 43

         _SetGetMinMaxInfo ( Arg1 , 5 , Arg3 )

      CASE Arg2 == "MINHEIGHT"

         _SetGetMinMaxInfo ( Arg1 , 6 , Arg3 )

      CASE Arg2 == "MAXWIDTH"

         _SetGetMinMaxInfo ( Arg1 , 7 , Arg3 )

      CASE Arg2 == "MAXHEIGHT"

         _SetGetMinMaxInfo ( Arg1 , 8 , Arg3 )

      END CASE
      EXIT

   CASE 4 // PCount() == 4 (CONTROL)

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomPropertyProcedure )

         IF Arg3 == _HMG_aCustomPropertyProcedure [i] [1]
            cMacro := _HMG_aCustomPropertyProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 , Arg4 )
            IF _HMG_UserComponentProcess == .T.
               RETURN
            ENDIF
         ENDIF

      NEXT i
#endif
      IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
         MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
      ENDIF

      DO CASE

      CASE Arg3 == "CUEBANNER" /* P.Ch. 16.10. */
         
         IF IsVistaOrLater() 

            IF "TEXT" $ GetControlType( Arg2, Arg1 )
               SendMessageWideString( GetControlHandle ( Arg2, Arg1 ), EM_SETCUEBANNER, .T., Arg4 )

            ELSEIF GetControlType( Arg2, Arg1 ) == "SPINNER"
               SendMessageWideString( GetControlHandle ( Arg2, Arg1 ) [1], EM_SETCUEBANNER, .T., Arg4 )

            ELSEIF GetControlType( Arg2, Arg1 ) == "COMBO"
               i := GetControlIndex ( Arg2 , Arg1 )

               IF _HMG_aControlMiscData1 [i] [2] == .T.
                  SendMessageWideString( _HMG_aControlRangeMin [i], EM_SETCUEBANNER, .T., Arg4 )
               ELSE
                  SendMessageWideString( GetControlHandle ( Arg2, Arg1 ), CB_SETCUEBANNER, .T., Arg4 )
               ENDIF

            ENDIF

         ENDIF

      CASE Arg3 == "ALIGNMENT" // GF 12/01/17

         _SetAlign ( Arg2 , Arg1 , Upper ( Arg4 ) )

      CASE Arg3 == "VALUE"

         _SetValue ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FORMATSTRING"

         _SetGetDatePickerDateFormat ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "CARGO"  //(GF) HMG 1.7 Exp. Build 76

         _ControlCargo ( Arg2 , Arg1 , Arg4 )

#ifdef _DBFBROWSE_
      CASE Arg3 == "ALLOWEDIT"

         _SetBrowseAllowEdit ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "ALLOWAPPEND"

         _SetBrowseAllowAppend ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "ALLOWDELETE"

         _SetBrowseAllowDelete ( Arg2 , Arg1 , Arg4 )
#endif
      CASE Arg3 $ "PICTURE,PICTUREINDEX,ICON"

         _SetPicture ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "HBITMAP"

         _SetGetImageHBitmap ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "TOOLTIP"

         _SetTooltip ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FONTNAME"

         _SetFontName ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FONTSIZE"

         _SetFontSize ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FONTBOLD"

         _SetFontBold ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FONTITALIC"

         _SetFontItalic ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FONTUNDERLINE"

         _SetFontUnderline ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FONTSTRIKEOUT"

         _SetFontStrikeout ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "CAPTION"

         _SetControlCaption( Arg2 , Arg1 , Arg4 )

      CASE Arg3 $ "ACTION,ONCLICK,ONGOTFOCUS,ONLOSTFOCUS,ONCHANGE,ONDBLCLICK" // GF 10/28/10

         _SetControlAction ( Arg2 , Arg1 , Arg4 , Arg3 )

      CASE Arg3 == "DISPLAYVALUE"

         _SetValue ( Arg2 , Arg1 , 0 )
         SetWindowText ( GetControlHandle( Arg2 , Arg1 ) , Arg4 )

      CASE Arg3 == "ROW"

         _SetControlRow ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "COL"

         _SetControlCol ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "LISTWIDTH"

         _SetGetDropDownWidth( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "WIDTH"

         _SetControlWidth ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "HEIGHT"

         _SetControlHeight ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "VISIBLE"

         iif ( Arg4 == .T. , _ShowControl ( Arg2 , Arg1 ) , _HideControl ( Arg2 , Arg1 ) )

      CASE Arg3 == "ENABLED"

         iif ( Arg4 == .T. , _EnableControl ( Arg2 , Arg1 ) , _DisableControl ( Arg2 , Arg1 ) )

      CASE Arg3 == "CHECKED"

         IF GetControlType ( Arg2 , Arg1 ) == "CHECKLABEL"
            SetChkLabel ( GetControlHandle ( Arg2 , Arg1 ) , Arg4 )
         ELSE
            iif ( Arg4 == .T. , _CheckMenuItem ( Arg2 , Arg1 ) , _UnCheckMenuItem ( Arg2 , Arg1 ) )
         ENDIF

      CASE Arg3 == "BLINK"

         IF "LABEL" $ GetControlType ( Arg2 , Arg1 ) .AND. ( _IsControlVisible ( Arg2 , Arg1 ) .OR. Arg4 == .F. )

            i := GetControlIndex ( Arg2 , Arg1 )
            IF _HMG_aControlMiscData1 [i] [2] == .T.
               iif ( Arg4 == .T. , _EnableControl ( 'BlinkTimer' + hb_ntos( i ) , Arg1 ) , _DisableControl ( 'BlinkTimer' + hb_ntos( i ) , Arg1 ) )
               IF _HMG_aControlMiscData1 [i] [3] == .F.
                  _ShowControl ( Arg2 , Arg1 )
               ENDIF
            ELSEIF Arg4 == .T.
               _HMG_aControlMiscData1 [i] [2] := Arg4
               _DefineTimer ( 'BlinkTimer' + hb_ntos( i ) , Arg1 , 500 , {|| _HMG_aControlMiscData1 [i] [3] := ! _HMG_aControlMiscData1 [i] [3], ;
                  iif( _HMG_aControlMiscData1 [i] [3] == .T. , _ShowControl ( Arg2 , Arg1 ), _HideControl ( Arg2 , Arg1 ) ) } )
            ENDIF

         ENDIF

      CASE Arg3 == "RANGEMIN"

         _SetRangeMin ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "RANGEMAX"

         _SetRangeMax ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "REPEAT"

         IF Arg4 == .T.
            _SetPlayerRepeatOn ( Arg2 , Arg1 )
         ELSE
            _SetPlayerRepeatOff ( Arg2 , Arg1 )
         ENDIF

      CASE Arg3 == "SPEED"

         _SetPlayerSpeed ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "VOLUME"

         _SetPlayerVolume ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "ZOOM"

         _SetPlayerZoom ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "POSITION"

         IF Arg4 == 0
            _SetPlayerPositionHome ( Arg2 , Arg1 )
         ELSEIF Arg4 == 1
            _SetPlayerPositionEnd ( Arg2 , Arg1 )
         ENDIF

      CASE Arg3 == "CARETPOS"

         _SetCaretPos ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "BACKCOLOR"

         _SetBackColor ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "FONTCOLOR" .OR. Arg3 == "FORECOLOR"

         _SetFontColor ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "ADDRESS"

         _SetAddress ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "TABSTOP"

         SetTabStop( GetControlHandle( Arg2 , Arg1 ) , Arg4 )

#ifdef _DBFBROWSE_
      CASE Arg3 == "INPUTITEMS"

         _SetBrowseInputItems ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "DISPLAYITEMS"

         _SetBrowseDisplayItems ( Arg2 , Arg1 , Arg4 )
#endif
      CASE Arg3 == "READONLY" .OR. Arg3 == "DISABLEEDIT"

         IF GetControlType ( Arg2 , Arg1 ) == "RADIOGROUP"
            _SetRadioGroupReadOnly ( Arg2 , Arg1 , Arg4 )
         ELSE
            _SetTextEditReadOnly ( Arg2 , Arg1 , Arg4 )
         ENDIF

      CASE Arg3 == "ITEMCOUNT"

         ListView_SetItemCount ( GetControlHandle ( Arg2 , Arg1 ) , Arg4 )

      CASE Arg3 == "INDENT"

         TreeView_SetIndent( GetControlHandle ( Arg2 , Arg1 ), Arg4 )

      CASE Arg3 == "LINECOLOR"

         TreeView_SetLineColor( GetControlHandle ( Arg2 , Arg1 ), Arg4 )

      CASE Arg3 == "ITEMHEIGHT"

         IF GetControlType( Arg2, Arg1 ) == "COMBO"
            ComboSetItemHeight ( GetControlHandle( Arg2 , Arg1 ) , Arg4 )
         ELSE
            TreeView_SetItemHeight( GetControlHandle ( Arg2 , Arg1 ), Arg4 )
         ENDIF

      CASE Arg3 == "RICHVALUE" // Kevin Carmody <i@kevincarmody.com> 2007.04.23

         _SetGetRichValue ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == "AUTOFONT" // Kevin Carmody <i@kevincarmody.com> 2007.04.23

         _SetGetAutoFont ( Arg2 , Arg1 , Arg4 )

      END CASE
      EXIT

   CASE 5 // PCount() == 5 (CONTROL WITH ARGUMENT OR TOOLBAR BUTTON OR SPLITBOX CHILD CONTROL WITHOUT ARGUMENT)

      IF Upper( Arg2 ) <> "SPLITBOX" .AND. GetControlType ( Arg2 , Arg1 ) != "TOOLBAR"

         IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
            MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
         ENDIF

      ENDIF

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomPropertyProcedure )

         IF Arg3 == _HMG_aCustomPropertyProcedure [i] [1]
            cMacro := _HMG_aCustomPropertyProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 , Arg4 , Arg5 )
            IF _HMG_UserComponentProcess == .T.
               RETURN
            ENDIF
         ENDIF

      NEXT i
#endif
      IF Upper( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )

            SetProperty ( Arg1 , Arg3 , Arg4 , Arg5 )

         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ELSE

         DO CASE
         CASE Arg3 == "CAPTION" .OR. Arg3 == "HEADER"

            _SetMultiCaption ( Arg2 , Arg1 , Arg4 , Arg5 )

         CASE Arg3 == "IMAGE" .OR. Arg3 == "HEADERIMAGE"

            _SetMultiImage ( Arg2 , Arg1 , Arg4 , Arg5 )

         CASE Arg3 == "TOOLTIP"

            _SetTooltip ( Arg2 , Arg1 , Arg5 , Arg4 )

         CASE Arg3 == "ITEM"

            _SetItem ( Arg2 , Arg1 , Arg4 , Arg5 )

         CASE Arg3 == "ICON"

            _SetStatusIcon ( Arg2 , Arg1 , Arg4 , Arg5 )

         CASE Arg3 == "WIDTH"

            _SetStatusWidth ( Arg1 , Arg4 , Arg5 )

         CASE Arg3 == 'COLUMNWIDTH' //(JK) HMG 1.0 Experimental Build 6

            _SetColumnWidth( Arg2 , Arg1 , Arg4 , Arg5 )

         CASE Arg3 == "ENABLED" // To ENABLE / DISABLE Radiobuttons and Tab pages

            iif ( Arg5 == .T. , _EnableControl ( Arg2 , Arg1, Arg4 ) , _DisableControl ( Arg2 , Arg1, Arg4 ) )

         CASE Arg3 == "RICHVALUE" // Kevin Carmody <i@kevincarmody.com> 2007.04.23

            _SetGetRichValue ( Arg2 , Arg1 , Arg5 , Arg4 )

         CASE Arg3 == "CHECKBOXITEM"

            IF "GRID" $ GetControlType ( Arg2 , Arg1 ) // Eduardo Fernandes 2009/JUN/17
               _SetGetCheckBoxItemState ( Arg2 , Arg1 , Arg4 , Arg5 )
            ELSE
               _SetGetChkListItemState ( Arg2 , Arg1 , Arg4 , Arg5 )
            ENDIF

         OTHERWISE  // If Property Not Matched Look For ToolBar Button

            IF GetControlType ( Arg2 , Arg1 ) == "TOOLBAR"

               IF GetControlHandle ( Arg2 , Arg1 ) != GetControlContainerHandle ( Arg3 , Arg1 )
                  MsgMiniGuiError( 'Control Does Not Belong To Container.' )
               ENDIF

               SetProperty ( Arg1 , Arg3 , Arg4 , Arg5 )

            ENDIF
         END CASE

      ENDIF
      EXIT
      
   CASE 6 // PCount() == 6 (TAB CHILD CONTROL OR SPLITBOX CHILD WITH ARGUMENT OR SPLITCHILD TOOLBAR BUTTON)

      IF Upper ( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )

            SetProperty ( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 )

         ELSE

            IF _IsControlDefined ( Arg4 , Arg1 )

               IF _IsControlSplitBoxed ( Arg4 , Arg1 )

                  SetProperty ( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 )

               ELSE
                  MsgMiniGuiError( 'Control Does Not Belong To Container.' )
               ENDIF

            ELSE
               MsgMiniGuiError( 'Control Does Not Belong To Container.' )
            ENDIF

         ENDIF

      ELSE

         IF ValType ( Arg3 ) != "N"

            Arg3 := Upper ( Arg3 )

            IF Arg3 == "CELL"

               IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
                  MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
               ENDIF

               _SetGridCellValue ( Arg2 , Arg1 , Arg4 , Arg5 , Arg6 )

            ELSEIF Arg3 == "HEADERIMAGE"    // Grid & Browse

               _SetMultiImage ( Arg2 , Arg1 , Arg4 , Arg5 , Arg6 )

            ENDIF

         ELSE

            IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
               MsgMiniGuiError( 'Control Does Not Belong To Container.' )
            ENDIF

            SetProperty ( Arg1 , Arg4 , Arg5 , Arg6 )

         ENDIF

      ENDIF
      EXIT

   CASE 7 // PCount() == 7 (TAB CHILD CONTROL WITH ARGUMENT OR SPLITBOX CHILD WITH 2 ARGUMENTS)

      IF Upper( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            SetProperty ( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 )
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ELSE

         IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

         SetProperty ( Arg1 , Arg4 , Arg5 , Arg6 , Arg7 )

      ENDIF
      EXIT

   CASE 8 // PCount() == 8 (TAB CHILD CONTROL WITH 2 ARGUMENTS OR SPLITBOX CHILD WITH 3 ARGUMENT)

      IF Upper( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            SetProperty ( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 )
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ELSE

         IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

         SetProperty ( Arg1 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 )

      ENDIF

   ENDSWITCH

RETURN 

*-----------------------------------------------------------------------------*
FUNCTION GetProperty ( Arg1 , Arg2 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 )
*-----------------------------------------------------------------------------*
   LOCAL RetVal, ix
#ifdef _USERINIT_
   LOCAL i, cMacro
#endif

   SWITCH PCount()
   CASE 2 // PCount() == 2 (WINDOW)

      IF .NOT. _IsWindowDefined ( Arg1 )
         MsgMiniGuiError( "Window: " + Arg1 + " is not defined." )
      ENDIF

      Arg2 := Upper ( Arg2 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomPropertyProcedure )

         IF Arg2 == _HMG_aCustomPropertyProcedure [i] [1]
            cMacro := _HMG_aCustomPropertyProcedure [i] [3]
            RetVal := &cMacro ( Arg1 , Arg2 )
            IF _HMG_UserComponentProcess == .T.
               RETURN RetVal
            ENDIF
         ENDIF

      NEXT i
#endif
      DO CASE

      CASE Arg2 == "TITLE"

         RetVal := GetWindowText ( GetFormHandle( Arg1 ) )

      CASE Arg2 == "FOCUSEDCONTROL"

         RetVal := _GetFocusedControl ( Arg1 )

      CASE Arg2 == "NAME"

         RetVal := GetFormName ( Arg1 )

      CASE Arg2 == "HANDLE"

         RetVal := GetFormHandle ( Arg1 )

      CASE Arg2 == "INDEX"

         RetVal := GetFormIndex ( Arg1 )

      CASE Arg2 == "TYPE"

         RetVal := GetWindowType ( Arg1 )

      CASE Arg2 == "HEIGHT"

         RetVal := GetWindowHeight ( GetFormHandle ( Arg1 ) )

      CASE Arg2 == "WIDTH"

         RetVal := GetWindowWidth ( GetFormHandle ( Arg1 ) )

      CASE Arg2 == "COL"

         RetVal := GetWindowCol ( GetFormHandle ( Arg1 ) )
#ifdef _PANEL_
         IF GetWindowType ( Arg1 ) == 'P'
            RetVal -= GetBorderWidth()
         ENDIF
#endif
      CASE Arg2 == "ROW"

         RetVal := GetWindowRow ( GetFormHandle ( Arg1 ) )
#ifdef _PANEL_
         IF GetWindowType ( Arg1 ) == 'P'
            RetVal -= GetTitleHeight() + GetBorderHeight()
         ENDIF
#endif
      CASE Arg2 == "TITLEBAR"

         RetVal := IsWindowHasStyle ( GetFormHandle( Arg1 ) , WS_CAPTION )

      CASE Arg2 == "SYSMENU"

         RetVal := IsWindowHasStyle ( GetFormHandle( Arg1 ) , WS_SYSMENU )

      CASE Arg2 == "SIZABLE"

         RetVal := IsWindowSized ( GetFormHandle( Arg1 ) )

      CASE Arg2 == "MAXBUTTON"

         RetVal := IsWindowHasStyle ( GetFormHandle( Arg1 ) , WS_MAXIMIZEBOX )

      CASE Arg2 == "MINBUTTON"

         RetVal := IsWindowHasStyle ( GetFormHandle( Arg1 ) , WS_MINIMIZEBOX )

      CASE Arg2 == "CLOSABLE"

         RetVal := xGetMenuEnabledState ( GetSystemMenu ( GetFormHandle( Arg1 ) ), SC_CLOSE )

      CASE Arg2 == "TOPMOST"

         RetVal := IsWindowHasExStyle( GetFormHandle( Arg1 ), WS_EX_TOPMOST )

      CASE Arg2 == "HELPBUTTON"

         RetVal := IsWindowHasExStyle( GetFormHandle( Arg1 ), WS_EX_CONTEXTHELP )

      CASE Arg2 == "NOTIFYICON"

         RetVal := _GetNotifyIconName ( Arg1 )

      CASE Arg2 == "NOTIFYTOOLTIP"

         RetVal := _GetNotifyIconTooltip ( Arg1 )

      CASE Arg2 == "BACKCOLOR"

         RetVal := _HMG_aFormBkColor [ GetFormIndex ( Arg1 ) ]

      CASE Arg2 == "CARGO"

         RetVal := _WindowCargo ( Arg1 )

#ifdef _OBJECT_
      CASE Arg2 == "OBJECT"

         RetVal := _WindowObj ( Arg1 )
#endif
      CASE Arg2 == "MINWIDTH" // Grigory Filatov HMG 1.4 Ext Build 43

         RetVal := _SetGetMinMaxInfo ( Arg1 , 5 )

      CASE Arg2 == "MINHEIGHT"

         RetVal := _SetGetMinMaxInfo ( Arg1 , 6 )

      CASE Arg2 == "MAXWIDTH"

         RetVal := _SetGetMinMaxInfo ( Arg1 , 7 )

      CASE Arg2 == "MAXHEIGHT"

         RetVal := _SetGetMinMaxInfo ( Arg1 , 8 )

      END CASE
      EXIT

   CASE 3 // PCount() == 3 (CONTROL)

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomPropertyProcedure )

         IF Arg3 == _HMG_aCustomPropertyProcedure [i] [1]
            cMacro := _HMG_aCustomPropertyProcedure [i] [3]
            RetVal := &cMacro ( Arg1 , Arg2 , Arg3 )
            IF _HMG_UserComponentProcess == .T.
               RETURN RetVal
            ENDIF
         ENDIF

      NEXT i
#endif
      IF ( Upper( Arg2 ) == "VSCROLLBAR" .OR. Upper( Arg2 ) == "HSCROLLBAR" )
         IF .NOT. _IsWindowDefined ( Arg1 )
            MsgMiniGuiError ( "Window: " + Arg1 + " is not defined." )
         ENDIF
      ELSE
         IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
            MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
         ENDIF
      ENDIF

      DO CASE

      CASE Arg3 == "CUEBANNER" /* P.Ch. 16.10. */
         
         IF IsVistaOrLater() 

            IF "TEXT" $ GetControlType( Arg2, Arg1 )
               RetVal := GetCueBannerText( GetControlHandle ( Arg2, Arg1 ) )
            ELSEIF GetControlType( Arg2, Arg1 ) == "SPINNER"
               RetVal := GetCueBannerText( GetControlHandle ( Arg2, Arg1 ) [1] )
            ELSEIF GetControlType( Arg2, Arg1 ) == "COMBO"
               ix := GetControlIndex ( Arg2 , Arg1 )
               IF _HMG_aControlMiscData1 [ix] [2] == .T.
                  RetVal := GetCueBannerText( _HMG_aControlRangeMin [ix] )
               ELSE
                  RetVal := GetCueBannerText( GetControlHandle ( Arg2, Arg1 ) )
               ENDIF
            ENDIF

         ENDIF

      CASE Arg3 == "ALIGNMENT" // GF 12/01/17

         IF IsWindowHasStyle ( GetControlHandle ( Arg2 , Arg1 ) , ES_CENTER )
            RetVal := "CENTER"
         ELSEIF IsWindowHasStyle ( GetControlHandle ( Arg2 , Arg1 ) , ES_RIGHT )
            RetVal := "RIGHT"
         ELSEIF IsWindowHasStyle ( GetControlHandle ( Arg2 , Arg1 ) , SS_CENTERIMAGE )
            RetVal := "VCENTER"
         ELSE
            RetVal := "LEFT"
         ENDIF

      CASE Arg3 == "VALUE"

         RetVal := _GetValue ( Arg2 , Arg1 )

      CASE Arg3 == "FORMATSTRING"

         RetVal := _SetGetDatePickerDateFormat ( Arg2 , Arg1 )

      CASE Arg3 == "CARGO"  //(GF) HMG 1.7 Exp. Build 76

         RetVal := _ControlCargo ( Arg2 , Arg1 )

#ifdef _OBJECT_
      CASE Arg3 == "OBJECT"

         RetVal := _ControlObj ( Arg2 , Arg1 )
#endif
      CASE Arg3 == "NAME"

         RetVal := GetControlName ( Arg2 , Arg1 )

      CASE Arg3 == "HANDLE"
  
         RetVal := GetControlHandle ( Arg2 , Arg1 )
     
      CASE Arg3 == "INDEX"

         RetVal := GetControlIndex ( Arg2 , Arg1 )

      CASE Arg3 == "TYPE"

         RetVal := GetUserControlType ( Arg2 , Arg1 )
  
#ifdef _DBFBROWSE_
      CASE Arg3 == "ALLOWEDIT"

         RetVal := _GetBrowseAllowEdit ( Arg2 , Arg1 )

      CASE Arg3 == "ALLOWAPPEND"

         RetVal := _GetBrowseAllowAppend ( Arg2 , Arg1 )

      CASE Arg3 == "ALLOWDELETE"

         RetVal := _GetBrowseAllowDelete ( Arg2 , Arg1 )

      CASE Arg3 == "INPUTITEMS"

         RetVal := _GetBrowseInputItems ( Arg2 , Arg1 )

      CASE Arg3 == "DISPLAYITEMS"

         RetVal := _GetBrowseDisplayItems ( Arg2 , Arg1 )
#endif
      CASE Arg3 $ "PICTURE,ICON"

         RetVal := _GetPicture ( Arg2 , Arg1 )

      CASE Arg3 == "HBITMAP"

         RetVal := _SetGetImageHBitmap ( Arg2 , Arg1 )

      CASE Arg3 == "TOOLTIP"

         RetVal := _GetTooltip ( Arg2 , Arg1 )

      CASE Arg3 == "FONTNAME"

         RetVal := _GetFontName ( Arg2 , Arg1 )

      CASE Arg3 == "FONTSIZE"

         RetVal := _GetFontSize ( Arg2 , Arg1 )

      CASE Arg3 == "FONTBOLD"

         RetVal := _GetFontBold ( Arg2 , Arg1 )

      CASE Arg3 == "FONTITALIC"

         RetVal := _GetFontItalic ( Arg2 , Arg1 )

      CASE Arg3 == "FONTUNDERLINE"

         RetVal := _GetFontUnderline ( Arg2 , Arg1 )

      CASE Arg3 == "FONTSTRIKEOUT"

         RetVal := _GetFontStrikeout ( Arg2 , Arg1 )

      CASE Arg3 == "CAPTION"

         RetVal := _GetCaption ( Arg2 , Arg1 )

      CASE Arg3 $ "ACTION,ONCLICK,ONGOTFOCUS,ONLOSTFOCUS,ONCHANGE,ONDBLCLICK" // GF 10/28/10

         RetVal := _GetControlAction ( Arg2 , Arg1 , Arg3 )

      CASE Arg3 == "DISPLAYVALUE"

         //(JK) HMG 1.0 Experimental Build 14
         ix := GetControlIndex ( Arg2 , Arg1 )

         IF _HMG_aControltype [ix] == "GETBOX"
            RetVal := GetWindowText ( GetControlHandle ( Arg2 , Arg1 ) )
         ELSEIF _HMG_aControltype [ix] == "COMBO"
            IF _HMG_aControlMiscData1 [ix][1] == 1
               IF Empty ( _hmg_aControlRangemin [ix] )
                  RetVal := _GetComboItemValue ( Arg2 , Arg1 , ComboGetCursel ( _HMG_aControlHandles [ix] ) )
               ELSE
                  RetVal := GetWindowText ( GetControlHandle ( Arg2 , Arg1 ) )
               ENDIF
            ELSE
               IF _HMG_aControlMiscData1 [ix][2] == .T. .AND. iif( Empty( _HMG_aControlCaption [ix] ), _GetValue ( , , ix ) > 0, .F. ) // GF 05/05/17
                  RetVal := _GetComboItemValue ( Arg2 , Arg1 , ComboGetCursel ( _HMG_aControlHandles [ix] ) )
               ELSE
                  RetVal := GetWindowText ( iif( Empty ( _hmg_aControlRangemin [ix] ), GetControlHandle ( Arg2 , Arg1 ), _hmg_aControlRangemin [ix] ) )
               ENDIF
            ENDIF
         ENDIF

      CASE Arg3 == "ROW"

         RetVal := _GetControlRow ( Arg2 , Arg1 )

      CASE Arg3 == "COL"

         RetVal := _GetControlCol ( Arg2 , Arg1 )

      CASE Arg3 == "WIDTH"

         RetVal := _GetControlWidth ( Arg2 , Arg1 )

      CASE Arg3 == "LISTWIDTH"

         RetVal := _SetGetDropDownWidth( Arg2 , Arg1 )

      CASE Arg3 == "HEIGHT"

         RetVal := _GetControlHeight ( Arg2 , Arg1 )

      CASE Arg3 == "VISIBLE"

         RetVal := _IsControlVisible ( Arg2 , Arg1 )

      CASE Arg3 == "ENABLED"

         RetVal := _IsControlEnabled ( Arg2 , Arg1 )

      CASE Arg3 == "CHECKED"

         IF GetControlType ( Arg2 , Arg1 ) == "CHECKLABEL"
            RetVal := GetChkLabel( GetControlHandle ( Arg2 , Arg1 ) )
         ELSE
            RetVal := _IsMenuItemChecked ( Arg2 , Arg1 )
         ENDIF

      CASE Arg3 == "ITEMCOUNT"

         RetVal := _GetItemCount ( Arg2 , Arg1 )

      CASE Arg3 == "RANGEMIN"

         RetVal := _GetRangeMin ( Arg2 , Arg1 )

      CASE Arg3 == "RANGEMAX"

         RetVal := _GetRangeMax ( Arg2 , Arg1 )

      CASE Arg3 == "LENGTH"

         RetVal := _GetPlayerLength ( Arg2 , Arg1 )

      CASE Arg3 == "POSITION"

         RetVal := _GetPlayerPosition ( Arg2 , Arg1 )

      CASE Arg3 == "VOLUME"

         RetVal := _GetPlayerVolume ( Arg2 , Arg1 )

      CASE Arg3 == "CARETPOS"

         RetVal := _GetCaretPos ( Arg2 , Arg1 )

      CASE Arg3 == "BACKCOLOR"

         RetVal := _GetBackColor ( Arg2 , Arg1 )

      CASE Arg3 == "FONTCOLOR" .OR. Arg3 == "FORECOLOR"

         RetVal := _GetFontColor ( Arg2 , Arg1 )

      CASE Arg3 == "ADDRESS"

         RetVal := _GetAddress ( Arg2 , Arg1 )

      CASE Arg3 == "TABSTOP"

         ix := GetControlHandle( Arg2 , Arg1 )

         RetVal := IsTabStop( IFARRAY( ix , ix[1] , ix ) )

      CASE Arg3 == "READONLY" .OR. Arg3 == "DISABLEEDIT"

         IF GetControlType ( Arg2 , Arg1 ) == "RADIOGROUP"
            RetVal := _GetRadioGroupReadOnly ( Arg2 , Arg1 )
         ELSE
            RetVal := IsWindowHasStyle ( GetControlHandle ( Arg2 , Arg1 ) , ES_READONLY )
         ENDIF

      CASE Arg3 == "INDENT"

         RetVal := TreeView_GetIndent ( GetControlHandle ( Arg2 , Arg1 ) )

      CASE Arg3 == "LINECOLOR"

         RetVal := TreeView_GetLineColor ( GetControlHandle ( Arg2 , Arg1 ) )

      CASE Arg3 == "ITEMHEIGHT"

         IF GetControlType( Arg2, Arg1 ) == "COMBO"
            RetVal := GetWindowHeight ( GetControlHandle ( Arg2 , Arg1 ) ) - 6
         ELSE
            RetVal :=  TreeView_GetItemHeight ( GetControlHandle ( Arg2 , Arg1 ) )
         ENDIF

      CASE Arg3 == "RICHVALUE" // Kevin Carmody <i@kevincarmody.com> 2007.04.10

         RetVal := _SetGetRichValue ( Arg2 , Arg1 )

      CASE Arg3 == "AUTOFONT"  // Kevin Carmody <i@kevincarmody.com> 2007.04.23

         RetVal := _SetGetAutoFont ( Arg2 , Arg1 )

      END CASE
      EXIT

   CASE 4 // PCount() == 4 (CONTROL WITH ARGUMENT OR TOOLBAR BUTTON OR (JK) HMG 1.0 Experimental Buid 6 GRID/BROWSE COLUMN - ColumnWidth OR SPLITBOX CHILD WITHOUT ARGUMENT)

      IF Upper( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            RetVal := GetProperty ( Arg1 , Arg3 , Arg4 )
         ELSE
            MsgMiniGuiError ( 'Control Does Not Belong To Container.' )
         ENDIF

      ELSE

         IF GetControlType ( Arg2 , Arg1 ) != "TOOLBAR"
            IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
               MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
            ENDIF
         ENDIF

         Arg3 := Upper ( Arg3 )

         DO CASE

         CASE Arg3 == "ITEM"

            RetVal := _GetItem (  Arg2 , Arg1 , Arg4 )

         CASE Arg3 == "WIDTH" // GF 01/05/2007

            RetVal := _GetStatusItemWidth( GetFormHandle ( Arg1 ) , Arg4 )

         CASE Arg3 == "CAPTION" .OR. Arg3 == "HEADER"

            RetVal := _GetMultiCaption ( Arg2 , Arg1 , Arg4 )

         CASE Arg3 == "IMAGE" .OR. Arg3 == "HEADERIMAGE"

            RetVal := _GetMultiImage ( Arg2 , Arg1 , Arg4 )

         CASE Arg3 == "TOOLTIP"

            RetVal := _GetMultiToolTip ( Arg2 , Arg1 , Arg4 )

         CASE Arg3 == "COLUMNWIDTH" //(JK) HMG 1.0 Experimental Build 6

            IF Empty ( Arg4 ) .OR. Arg4 < 1
               MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + ". Unproper or empty index param." )
            ENDIF

            RetVal := _GetColumnWidth( Arg2 , Arg1 , Arg4 )

         CASE Arg3 == "ENABLED"

            RetVal := _IsControlEnabled ( Arg2 , Arg1 , Arg4 )

         CASE Arg3 == "RICHVALUE" // Kevin Carmody <i@kevincarmody.com> 2007.04.23

            RetVal := _SetGetRichValue ( Arg2 , Arg1 , , Arg4 )

         CASE Arg3 == "CHECKBOXITEM"

            IF "GRID" $ GetControlType ( Arg2 , Arg1 ) // Eduardo Fernandes 2009/JUN/17
               RetVal := _SetGetCheckBoxItemState ( Arg2 , Arg1 , Arg4 , )
            ELSE
               RetVal := _SetGetChkListItemState ( Arg2 , Arg1 , Arg4  )
            ENDIF

         OTHERWISE // If Property Not Matched Look For Contained Control With No Arguments (ToolBar Button)

            IF GetControlType ( Arg2 , Arg1 ) == "TOOLBAR"
               IF GetControlHandle ( Arg2 , Arg1 ) != GetControlContainerHandle ( Arg3 , Arg1 )
                  MsgMiniGuiError ( 'Control Does Not Belong To Container.' )
               ENDIF
               RetVal := GetProperty ( Arg1 , Arg3 , Arg4 )
            ENDIF

         END CASE

      ENDIF
      EXIT

   CASE 5 // PCount() == 5 (TAB CHILD CONTROL (WITHOUT ARGUMENT) OR SPLITBOX CHILD WITH ARGUMENT)

      IF Upper( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            RetVal := GetProperty ( Arg1 , Arg3 , Arg4 , Arg5 )
         ELSE
            IF _IsControlDefined ( Arg4 , Arg1 )
               IF _IsControlSplitBoxed ( Arg4 , Arg1 )
                  RetVal := GetProperty ( Arg1 , Arg3 , Arg4 , Arg5 )
               ELSE
                  MsgMiniGuiError ( 'Control Does Not Belong To Container.' )
               ENDIF
            ELSE
               MsgMiniGuiError ( 'Control Does Not Belong To Container.' )
            ENDIF
         ENDIF

      ELSE

         IF ValType ( Arg3 ) != "N"

            Arg3 := Upper ( Arg3 )

            IF Arg3 == "CELL"
               RetVal := _GetGridCellValue ( Arg2 , Arg1 , Arg4 , Arg5 )
            ENDIF

         ELSE

            IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
               MsgMiniGuiError ( "Control Does Not Belong To Container." )
            ENDIF

            RetVal := GetProperty ( Arg1 , Arg4 , Arg5 )
         ENDIF

      ENDIF
      EXIT

   CASE 6 // PCount() == 6 (TAB CHILD CONTROL WITH 1 ARGUMENT OR SPLITBOX CHILD WITH 2 ARGUMENT)

      IF Upper( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            RetVal := GetProperty ( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 )
         ELSE
            MsgMiniGuiError ( "Control Does Not Belong To Container." )
         ENDIF

      ELSE

         IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
            MsgMiniGuiError ( "Control Does Not Belong To Container." )
         ENDIF

         RetVal := GetProperty ( Arg1 , Arg4 , Arg5 , Arg6 )

      ENDIF
      EXIT

   CASE 7 // PCount() == 7 (TAB CHILD CONTROL WITH 2 ARGUMENT OR SPLITBOX CHILD WITH 3 ARGUMENT)

      IF Upper( Arg2 ) == "SPLITBOX"

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            RetVal := GetProperty ( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 )
         ELSE
            MsgMiniGuiError ( "Control Does Not Belong To Container." )
         ENDIF

      ELSE

         IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
            MsgMiniGuiError ( "Control Does Not Belong To Container." )
         ENDIF

         RetVal := GetProperty ( Arg1 , Arg4 , Arg5 , Arg6 , Arg7 )

      ENDIF

   ENDSWITCH

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNCTION DoMethod ( Arg1 , Arg2 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 , Arg9 )
*-----------------------------------------------------------------------------*
   LOCAL i
#ifdef _USERINIT_
   LOCAL cMacro
#endif

   IF PCount() == 2 // Window

      IF ValType ( Arg1 ) == "C"
         IF .NOT. _IsWindowDefined ( Arg1 )
            MsgMiniGuiError( "Window: " + Arg1 + " is not defined." )
         ENDIF
      ENDIF

      Arg2 := Upper ( Arg2 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomMethodProcedure )

         IF Arg2 == _HMG_aCustomMethodProcedure [i] [1]
            cMacro := _HMG_aCustomMethodProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 )
            IF _HMG_UserComponentProcess == .T.
               RETURN NIL
            ENDIF
         ENDIF

      NEXT i
#endif

      DO CASE

      CASE Arg2 == "ACTIVATE"

         IF ! ISARRAY ( Arg1 )
            Arg1 := { Arg1 }
         ENDIF

         _ActivateWindow ( Arg1 )

      CASE Arg2 == "CENTER"

         _CenterWindow ( Arg1 , _SetCenterWindowStyle () )

      CASE Arg2 == 'REDRAW'

         RedrawWindow ( GetFormHandle( Arg1 ) )

      CASE Arg2 == "RELEASE"

         _ReleaseWindow ( Arg1 )

      CASE Arg2 == "MAXIMIZE"

         _MaximizeWindow ( Arg1 )

      CASE Arg2 == "MINIMIZE"

         _MinimizeWindow ( Arg1 )

      CASE Arg2 == "RESTORE"

         _RestoreWindow ( Arg1 )

      CASE Arg2 == "SHOW"

         _ShowWindow ( Arg1 )

      CASE Arg2 == "HIDE"

         _HideWindow ( Arg1 )

      CASE Arg2 == "SETFOCUS"

         i := GetFormIndex ( Arg1 )

         IF i >= 1 .AND. i <= Len ( _HMG_aFormHandles )

            IF _HMG_aFormActive [i] == .T.
               setfocus ( _HMG_aFormHandles [i] )
            ENDIF

         ENDIF

      END CASE

   ELSEIF PCount() == 3 // CONTROL

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomMethodProcedure )

         IF Arg3 == _HMG_aCustomMethodProcedure [i] [1]
            cMacro := _HMG_aCustomMethodProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 )
            IF _HMG_UserComponentProcess == .T.
               RETURN NIL
            ENDIF
         ENDIF

      NEXT i
#endif
      IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
         MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
      ENDIF

      DO CASE

      CASE Arg3 == 'COLUMNSAUTOFIT'  //(JK) HMG 1.0 Experimental Build 6

         _SetColumnsWidthAuto( Arg2 , Arg1 )

      CASE Arg3 == 'COLUMNSAUTOFITH' //(JK) HMG 1.0 Experimental Build 6

         _SetColumnsWidthAutoH( Arg2 , Arg1 )

      CASE Arg3 == 'ENABLEUPDATE'

         _EnableListViewUpdate( Arg2 , Arg1 , .T. )

      CASE Arg3 == 'DISABLEUPDATE'

         _EnableListViewUpdate( Arg2 , Arg1 , .F. )

      CASE Arg3 == 'REFRESH'

         _Refresh ( GetControlIndex ( Arg2 , Arg1 ) )

      CASE Arg3 == 'REDRAW'

         _RedrawControl ( GetControlIndex ( Arg2 , Arg1 ) )

      CASE Arg3 == 'SAVE'

         _SaveData ( Arg2 , Arg1 )

      CASE Arg3 == 'SETFOCUS'

         _SetFocus ( Arg2 , Arg1 )

      CASE Arg3 $ 'ACTION,ONCLICK,ONGOTFOCUS,ONLOSTFOCUS,ONCHANGE,ONDBLCLICK' // GF 10/28/10

         Eval ( _GetControlAction ( Arg2 , Arg1 , Arg3 ) )

      CASE Arg3 == 'DELETEALLITEMS'

         _DeleteAllItems ( Arg2 , Arg1 )

      CASE Arg3 == 'RELEASE'

         _ReleaseControl ( Arg2 , Arg1 )

      CASE Arg3 == 'SHOW'

         _ShowControl ( Arg2 , Arg1 )

      CASE Arg3 == 'HIDE'

         _HideControl ( Arg2 , Arg1 )

      CASE Arg3 == 'PLAY'

         iif ( GetControlType ( Arg2 , Arg1 ) == "ANIMATEBOX" , _PlayAnimateBox ( Arg2 , Arg1 ) , _PlayPlayer ( Arg2 , Arg1 ) )

      CASE Arg3 == 'STOP'

         iif ( GetControlType ( Arg2 , Arg1 ) == "ANIMATEBOX" , _StopAnimateBox ( Arg2 , Arg1 ) , _StopPlayer ( Arg2 , Arg1 ) )

      CASE Arg3 == 'CLOSE'

         iif ( GetControlType ( Arg2 , Arg1 ) == "ANIMATEBOX" , _CloseAnimateBox ( Arg2 , Arg1 ) , _ClosePlayer ( Arg2 , Arg1 ) )

      CASE Arg3 == 'PLAYREVERSE'

         _PlayPlayerReverse ( Arg2 , Arg1 )

      CASE Arg3 == 'PAUSE'

         _PausePlayer ( Arg2 , Arg1 )

      CASE Arg3 == 'EJECT'

         _EjectPlayer ( Arg2 , Arg1 )

      CASE Arg3 == 'OPENDIALOG'

         _OpenPlayerDialog ( Arg2 , Arg1 )

      CASE Arg3 == 'RESUME'

         _ResumePlayer ( Arg2 , Arg1 )

      END CASE

   ELSEIF PCount() == 4   // CONTROL WITH 1 ARGUMENT OR SPLITBOX CHILD WITHOUT ARGUMENT

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomMethodProcedure )

         IF Arg3 == _HMG_aCustomMethodProcedure [i] [1]
            cMacro := _HMG_aCustomMethodProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 , Arg4 )
            IF _HMG_UserComponentProcess == .T.
               RETURN NIL
            ENDIF
         ENDIF

      NEXT i
#endif
      IF Upper( Arg2 ) == 'SPLITBOX'

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            DoMethod( Arg1 , Arg3 , Arg4 )
            RETURN Nil
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ENDIF

      IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
         MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
      ENDIF

      //(JK) HMG 1.0 Experimental Build 6 (2 new method for GRID/BROWSE control COLUMNAUTOFIT(n),COLUMNAUTOFITH(n))

      DO CASE

      CASE Arg3 == 'COLUMNAUTOFIT'

         _SetColumnWidthAuto( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'COLUMNAUTOFITH'

         _SetColumnWidthAutoH( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'DELETEITEM'

         _DeleteItem ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'DELETEPAGE'

         _DeleteTabPage ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'OPEN'

         iif ( GetControlType ( Arg2 , Arg1 ) == "ANIMATEBOX" , _OpenAnimateBox ( Arg2 , Arg1 , Arg4 ) , _OpenPlayer ( Arg2 , Arg1 , Arg4 ) )

      CASE Arg3 == 'SEEK'

         _SeekAnimateBox ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'ADDITEM'

         _AddItem ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'EXPAND'

         _Expand ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'COLLAPSE'

         _Collapse ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'DELETECOLUMN'

         _DeleteGridColumn ( Arg2 , Arg1 , Arg4 )

      CASE Arg3 == 'DELETEIMAGE'  //JP ImageList

         _RemoveImageFromImageList ( Arg2 , Arg1 , Arg4 - 1 )

      CASE Arg3 == 'SETARRAY' // GF

         _SetArrayToControl ( Arg2 , Arg1 , Arg4 )

      END CASE

   ELSEIF PCount() == 5 .AND. ValType ( Arg3 ) == 'C' // CONTROL WITH 2 ARGUMENTS OR SPLITBOX CHILD WITH 1 ARGUMENT

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomMethodProcedure )

         IF Arg3 == _HMG_aCustomMethodProcedure [i] [1]
            cMacro := _HMG_aCustomMethodProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 , Arg4 , Arg5 )
            IF _HMG_UserComponentProcess == .T.
               RETURN NIL
            ENDIF
         ENDIF

      NEXT i
#endif
      IF Upper( Arg2 ) == 'SPLITBOX'

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            DoMethod( Arg1 , Arg3 , Arg4 , Arg5 )
            RETURN Nil
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ENDIF

      IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
         MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
      ENDIF

      DO CASE

      CASE Arg3 == 'ADDITEM'

         _AddItem ( Arg2 , Arg1 , Arg4 , Arg5 )

      CASE Arg3 == 'ADDPAGE'

         _AddTabPage ( Arg2 , Arg1 , Arg4 , Arg5 )

      CASE Arg3 == 'ADDIMAGE'  //JP ImageList

         _AddImageToImageList ( Arg2 , Arg1 , Arg4 , Arg5 )

      CASE Arg3 == 'ADDIMAGEMASK'  //JP ImageList

         _AddImageMaskedToImageList ( Arg2 , Arg1 , Arg4 , Arg5 )

      END CASE

   ELSEIF PCount() == 5  .AND. ValType ( Arg3 ) == 'N' // TAB CHILD WITHOUT ARGUMENTS

      IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
         MsgMiniGuiError( 'Control Does Not Belong To Container.' )
      ENDIF

      DoMethod ( Arg1 , Arg4 , Arg5 )

   ELSEIF PCount() == 6 .AND. ValType ( Arg3 ) == 'C' // CONTROL WITH 3 ARGUMENTS OR SPLITBOX CHILD WITH 2 ARGUMENTS

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomMethodProcedure )

         IF Arg3 == _HMG_aCustomMethodProcedure [i] [1]
            cMacro := _HMG_aCustomMethodProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 , Arg4 , Arg5 , Arg6 )
            IF _HMG_UserComponentProcess == .T.
               RETURN NIL
            ENDIF
         ENDIF

      NEXT i
#endif
      IF Upper( Arg2 ) == 'SPLITBOX'

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            DoMethod( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 )
            RETURN Nil
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ENDIF

      IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
         MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
      ENDIF

      IF Arg3 == 'ADDITEM'

         _AddItem ( Arg2 , Arg1 , Arg4 , Arg5 , Arg6 )

      ELSEIF Arg3 == 'ADDPAGE'

         _AddTabPage ( Arg2 , Arg1 , Arg4 , Arg5 , Arg6 )

      ENDIF

   ELSEIF PCount() == 6 .AND. ValType ( Arg3 ) == 'N' // TAB CHILD WITH 1 ARGUMENT

      IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
         MsgMiniGuiError( 'Control Does Not Belong To Container.' )
      ENDIF

      DoMethod ( Arg1 , Arg4 , Arg5 , Arg6 )

   ELSEIF PCount() == 7 .AND. ValType ( Arg3 ) == 'C' // CONTROL WITH 4 ARGUMENTS OR SPLITBOX CHILD WITH 3 ARGUMENTS

      Arg3 := Upper ( Arg3 )

#ifdef _USERINIT_
      FOR i := 1 TO Len ( _HMG_aCustomMethodProcedure )

         IF Arg3 == _HMG_aCustomMethodProcedure [i] [1]
            cMacro := _HMG_aCustomMethodProcedure [i] [2]
            &cMacro ( Arg1 , Arg2 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 )
            IF _HMG_UserComponentProcess == .T.
               RETURN NIL
            ENDIF
         ENDIF

      NEXT i
#endif
      IF Upper( Arg2 ) == 'SPLITBOX'

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            DoMethod( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 )
            RETURN Nil
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ENDIF

      IF .NOT. _IsControlDefined ( Arg2 , Arg1 )
         MsgMiniGuiError ( "Control: " + Arg2 + " Of " + Arg1 + " Not defined." )
      ENDIF

      DO CASE

      CASE Arg3 == 'ADDCONTROL'

         _AddTabControl ( Arg2 , Arg4 , Arg1 , Arg5 , Arg6 , Arg7 )

      CASE Arg3 == 'ADDCOLUMN'

         _AddGridColumn ( Arg2 , Arg1 , Arg4 , Arg5 , Arg6 , Arg7 )

      CASE Arg3 == 'ADDITEM'

         _AddItem ( Arg2 , Arg1 , Arg4 , Arg5 , Arg6 , Arg7 )

      CASE Arg3 == 'ADDPAGE'  // JR

         _AddTabPage ( Arg2 , Arg1 , Arg4 , Arg5 , Arg6, Arg7 )

      END CASE

   ELSEIF PCount() == 7 .AND. ValType ( Arg3 ) == 'N' // TAB CHILD WITH 2 ARGUMENTS

      IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
         MsgMiniGuiError( 'Control Does Not Belong To Container.' )
      ENDIF

      DoMethod ( Arg1 , Arg4 , Arg5 , Arg6 , Arg7 )

   ELSEIF PCount() == 8 // TAB CHILD WITH 3 ARGUMENTS OR SPLITBOX CHILD WITH 4 ARGUMENTS

      IF Upper( Arg2 ) == 'SPLITBOX'

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            DoMethod( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 )
            RETURN Nil
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ENDIF

      IF ValType ( Arg3 ) == 'N'

         IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

         DoMethod ( Arg1 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 )

      ENDIF

   ELSEIF PCount() == 9 // TAB CHILD WITH 4 ARGUMENTS OR SPLITBOX CHILD WITH 5 ARGUMENTS

      IF Upper( Arg2 ) == 'SPLITBOX'

         IF _IsControlSplitBoxed ( Arg3 , Arg1 )
            DoMethod( Arg1 , Arg3 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 , Arg9 )
            RETURN Nil
         ELSE
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

      ENDIF

      IF ValType ( Arg3 ) == 'N'

         IF GetControlTabPage ( Arg4 , Arg2 , Arg1 ) <> Arg3
            MsgMiniGuiError( 'Control Does Not Belong To Container.' )
         ENDIF

         DoMethod ( Arg1 , Arg4 , Arg5 , Arg6 , Arg7 , Arg8 , Arg9 )

      ENDIF

   ENDIF

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION GetControlTabPage ( cControlName , cTabName , cParentWindowName )
*-----------------------------------------------------------------------------*
   LOCAL nRetVal As Numeric
   LOCAL xControlHandle , tabpage , c , r , k
   LOCAL niTab := GetControlIndex ( cTabName , cParentWindowName )
   LOCAL niControl := GetControlIndex ( cControlName , cParentWindowName )

   IF niControl > 0
      xControlHandle := _HMG_aControlHandles [ niControl ]

      FOR EACH tabpage IN _HMG_aControlPageMap [ niTab ]
         k := hb_enumindex( tabpage )

         FOR EACH c IN tabpage
            IF ValType ( c ) == 'N' .AND. ValType ( xControlHandle ) == 'N'
               IF c == xControlHandle
                  nRetVal := k
                  EXIT
               ENDIF

            ELSEIF ValType ( c ) == "A" .AND. ValType ( xControlHandle ) == "A"
               FOR EACH r IN xControlHandle
                  IF AScan ( c , r ) <> 0
                     nRetVal := k
                     EXIT
                  ENDIF
               NEXT
               IF nRetVal <> 0
                  EXIT
               ENDIF

            ELSEIF ValType ( c ) == "A" .AND. ValType ( xControlHandle ) == "N"
               IF AScan ( c , xControlHandle ) <> 0
                  nRetVal := k
                  EXIT
               ENDIF
            ENDIF
         NEXT
         IF nRetVal <> 0
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN nRetVal

*-----------------------------------------------------------------------------*
STATIC FUNCTION _IsControlSplitBoxed ( cControlName , cWindowName )
*-----------------------------------------------------------------------------*
   LOCAL lSplitBoxed As Logical
   LOCAL i

   IF ( i := GetControlIndex ( cControlName, cWindowName ) ) > 0

      IF ValType ( _HMG_aControlRow [i] ) == 'U' .AND. ValType ( _HMG_aControlCol [i] ) == 'U' .OR. ;
         "GRID" $ _HMG_aControlType [i] .AND. Empty ( _HMG_aControlRow [i] ) .AND. Empty ( _HMG_aControlCol [i] )
         lSplitBoxed := .T.
      ENDIF

   ENDIF

RETURN lSplitBoxed

*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetArrayToControl ( ControlName, ParentForm, aValue )  // GF 03/30/16
*-----------------------------------------------------------------------------*
   LOCAL t , i , BackValue
#ifdef _TSBROWSE_
   LOCAL oGet
#endif
   IF ! ISARRAY ( aValue )
      RETURN Nil
   ENDIF

   i := GetControlIndex ( ControlName, ParentForm )
   T := _HMG_aControlType [i]

   DO CASE

   CASE "LIST" $ T
      _HMG_aControlRangeMin [i] := aValue

      BackValue := _GetValue ( , , i )
      _DeleteAllItems ( ControlName, ParentForm )
      aEval ( aValue, { | row | DoMethod ( ParentForm, ControlName, 'AddItem', row ) } )

      _SetValue ( , , BackValue , i )

   CASE T == "COMBO"
      IF ValType ( _HMG_aControlSpacing [i] ) != 'C' .AND. _HMG_aControlMiscData1 [i][1] <> 1
         _HMG_aControlMiscData1 [i][4] := aValue
         _Refresh( i )
      ENDIF

   CASE "GRID" $ T
      IF Len ( aValue ) > 0 .AND. Len ( aValue [1] ) != Len ( _HMG_aControlMiscData1 [i][2] )
         MsgMiniGuiError ( "Grid: ITEMS length mismatch." )
      ELSE
         _HMG_aControlMiscData1 [i][4] := aValue

         BackValue := _GetValue ( , , i )
         _DeleteAllItems ( ControlName, ParentForm )
         aEval ( aValue, { | row | DoMethod ( ParentForm, ControlName, 'AddItem', row ) } )
         _SetValue ( , , BackValue , i )
      ENDIF

#ifdef _TSBROWSE_
   CASE T == "TBROWSE"
      oGet := GetObjectByHandle( _HMG_aControlHandles [i] )
      IF ISOBJECT( oGet )
         oGet:SetItems( aValue )
      ENDIF
#endif
   ENDCASE

RETURN Nil

*-----------------------------------------------------------------------------*
PROCEDURE _Refresh( i )
*-----------------------------------------------------------------------------*
   LOCAL Field, rows, BackValue
   LOCAL T := _HMG_aControlType [i]

   DO CASE

   CASE 'TEXT' $ T
      _DataTextBoxRefresh ( i )

   CASE T == 'COMBO'
      IF ValType ( _HMG_aControlSpacing [i] ) == 'C'
         _DataComboRefresh ( i )

      ELSEIF _HMG_aControlMiscData1 [i][1] <> 1  // GF 03/30/16
         t := _HMG_aControlHandles [i]
         rows := _HMG_aControlMiscData1 [i][4]

         BackValue := _GetValue ( , , i )
         ComboboxReset ( t )
         AEval ( rows, { |v| ComboAddString ( t, v ) } )

         IF BackValue > 0 .AND. BackValue <= Len ( rows )
            _SetValue ( , , BackValue , i )
         ENDIF

      ENDIF

   CASE 'PICK' $ T .OR. T == 'CHECKBOX' .OR. T == 'RICHEDIT'
      Field := _HMG_aControlPageMap [i]

      IF ValType ( Field ) != 'U'
         _SetValue (  ,  , &Field , i )
      ELSE
         MsgMiniGuiError ( "Control: " + _HMG_aControlNames [i] + " Of " + GetParentFormName ( i ) + " : Refresh method can be used only if FIELD clause is set." )
      ENDIF

   CASE T == 'EDIT'
      _DataEditBoxRefresh ( i )

   CASE T == 'GETBOX'
      _DataGetBoxRefresh ( i )

#ifdef _DBFBROWSE_
   CASE T == 'BROWSE'
      _BrowseRefresh ( '', '', i )
#endif
   CASE 'GRID' $ T
      IF _HMG_aControlMiscData1 [i] [5] == .T.
         ListView_SetItemCount ( _HMG_aControlHandles [i] , ListViewGetItemCount ( _HMG_aControlHandles [i] ) )
      ENDIF
      _UpdateGridColors ( i )

   OTHERWISE
      RedrawWindowControlRect ( _HMG_aControlParentHandles [i] , _HMG_aControlRow [i] , _HMG_aControlCol [i] , _HMG_aControlRow [i] + _HMG_aControlHeight [i] , _HMG_aControlCol [i] + _HMG_aControlWidth [i] )

   END CASE

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SaveData ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL Field
   LOCAL i := GetControlIndex ( ControlName, ParentForm )
   LOCAL T := _HMG_aControlType [i]

   IF 'TEXT' $ T
      _DataTextBoxSave ( ControlName , ParentForm )

   ELSEIF 'PICK' $ T .OR. T == 'CHECKBOX' .OR. T == 'EDIT'
      Field := _HMG_aControlPageMap [i]

      IF _IsFieldExists ( Field )
         REPLACE &Field WITH _GetValue ( ControlName , ParentForm )
      ENDIF

   ELSEIF T == 'RICHEDIT'  // JP Exp. build 8
      _DataBaseRichEditBoxSave ( ControlName , ParentForm )

   ELSEIF T == 'GETBOX'
      _DataGetBoxSave ( ControlName , ParentForm )

   ENDIF

RETURN

#define HWND_TOPMOST    (-1)
#define HWND_NOTOPMOST  (-2)
*-----------------------------------------------------------------------------*
PROCEDURE _ChangeWindowTopmostStyle( FormHandle, Value )
*-----------------------------------------------------------------------------*
   LOCAL lTopmost As Logical

   Assign lTopmost := Value

   SetWindowPos( FormHandle, iif( lTopmost, HWND_TOPMOST, HWND_NOTOPMOST ), 0, 0, 0, 0, SWP_NOSIZE + SWP_NOMOVE )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _ChangeWindowHelpButtonStyle( FormName, Value )
*-----------------------------------------------------------------------------*
   LOCAL lHelpButton As Logical
   LOCAL h := GetFormHandle( FormName )

   Assign lHelpButton := Value

   IF lHelpButton
      ChangeStyle( h, WS_EX_CONTEXTHELP, , .T. )
   ELSE
      ChangeStyle( h, , WS_EX_CONTEXTHELP, .T. )
   ENDIF

   _ChangeWindowStyle( FormName, WS_MAXIMIZEBOX, !lHelpButton )
   _ChangeWindowStyle( FormName, WS_MINIMIZEBOX, !lHelpButton )

RETURN

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _ChangeWindowStyle( FormName, Style, Value )
*-----------------------------------------------------------------------------*
   LOCAL lSwitch As Logical
   LOCAL h := GetFormHandle( FormName )

   Assign lSwitch := Value

   SetWindowStyle( h, Style, lSwitch )

   h := GetWindowHeight( h )  // store the current height of the window

   // Refresh Title
   _SetWindowSizePos ( FormName , , , , 0 )
   _SetWindowSizePos ( FormName , , , , h )

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _SetWindowBackColor( FormHandle, aColor )
*-----------------------------------------------------------------------------*
   LOCAL hBrush, i := AScan( _HMG_aFormHandles, FormHandle )

   DeleteObject( _HMG_aFormBrushHandle [i] )

   hBrush := PaintBkGnd( FormHandle, aColor )

   SetWindowBackground( FormHandle, hBrush )

   _HMG_aFormBkColor [i] := aColor
   _HMG_aFormBrushHandle [i] := hBrush

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _GetFocusedControl ( cFormName )
*-----------------------------------------------------------------------------*
   LOCAL cRetVal As String
   LOCAL hControl , i , hCtrl, hFocusedControlHandle
   LOCAL hFormHandle := GetFormHandle ( cFormName )

   IF ( hFocusedControlHandle := GetFocus() ) != 0

      FOR EACH hControl IN _HMG_aControlHandles

         i := hb_enumindex( hControl )

         IF _HMG_aControlParentHandles [i] == hFormHandle

            IF ValType ( hControl ) == 'N'
               IF hControl == hFocusedControlHandle .OR. ;
                  ( ! Empty( _HMG_aControlType [i] ) .AND. ( ValType( _HMG_aControlRangeMin [i] ) == 'N' .AND. _HMG_aControlRangeMin [i] == hFocusedControlHandle ) .OR. ;
                                                           ( ValType( _HMG_aControlRangeMax [i] ) == 'N' .AND. _HMG_aControlRangeMax [i] == hFocusedControlHandle ) ) .OR. ;
                  ( ISARRAY( _HMG_aControlSpacing [i] ) .AND. ValType( _HMG_aControlSpacing [i][1] ) == 'N' .AND. AScan ( _HMG_aControlSpacing [i], hFocusedControlHandle ) > 0 ) .OR. ;
                  ( ISARRAY( _HMG_aControlRangeMin [i] ) .AND. ValType( _HMG_aControlRangeMin [i][1] ) == 'N' .AND. AScan ( _HMG_aControlRangeMin [i], hFocusedControlHandle ) > 0 )
                  cRetVal := _HMG_aControlNames [i]
               ENDIF

            ELSEIF ValType ( hControl ) == 'A'
               FOR EACH hCtrl IN hControl
                  IF hCtrl == hFocusedControlHandle
                     cRetVal := _HMG_aControlNames [i]
                     EXIT
                  ENDIF
               NEXT

            ENDIF

         ENDIF

         IF ! Empty ( cRetVal )
            EXIT
         ENDIF

      NEXT

   ENDIF

RETURN cRetVal

*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetFontColor ( ControlName, ParentForm, Value )
*-----------------------------------------------------------------------------*
   LOCAL i , t , c , default := GetSysColor ( COLOR_WINDOWTEXT )

   IF value == Nil .OR. ! IsArrayRGB ( Value )
      RETURN Nil
   ENDIF

   i := GetControlIndex ( ControlName, ParentForm )
   t := GetControlType ( ControlName, ParentForm )
   c := GetControlHandle ( ControlName, ParentForm )

   DO CASE

   CASE t $ 'MULTIGRID,BROWSE'
      ListView_SetTextColor ( c, value [1] , value [2] , value [3] )
      RedrawWindow ( c )

   CASE t == 'RICHEDIT'
      SetFontRTF( c, -1, _HMG_aControlFontName [i], _HMG_aControlFontSize [i], _HMG_aControlFontAttributes [i][1], _HMG_aControlFontAttributes [i][2], ;
         RGB ( Value [1], Value [2], Value [3] ), _HMG_aControlFontAttributes [i][3], _HMG_aControlFontAttributes [i][4] )
      RedrawWindow ( c )

   CASE t == 'DATEPICK'
      _HMG_aControlFontColor [i] := Value
      SetDatePickFontColor( c, value [1], value [2], value [3] )

   CASE t == 'MONTHCAL'
      _HMG_aControlFontColor [i] := Value
      SetMonthCalFontColor( c, value [1], value [2], value [3] )

   CASE t == 'PROGRESSBAR'
      _HMG_aControlFontColor [i] := Value
      SetProgressBarBarColor( c, value [1], value [2], value [3] )

   CASE t == 'TREE'
      _HMG_aControlFontColor [i] := Value
      TreeView_SetTextColor( c, value )

   CASE "TEXT" $ t .OR. t == "EDIT"
      _HMG_aControlFontColor [i] := iif( ISARRAY ( Value ), Value, nRGB2Arr ( default ) )
      RedrawWindow ( c )

   OTHERWISE
      _HMG_aControlFontColor [i] := Value
      _RedrawControl ( i )

   END CASE

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetBackColor ( ControlName, ParentForm , Value )
*-----------------------------------------------------------------------------*
   LOCAL i , t , c , f := GetSysColor ( COLOR_3DFACE ), d := GetSysColor ( COLOR_WINDOW )

   IF Value == Nil .OR. ! IsArrayRGB ( Value )
      RETURN Nil
   ENDIF

   i := GetControlIndex ( ControlName, ParentForm )
   t := GetControlType ( ControlName, ParentForm )
   c := GetControlHandle ( ControlName, ParentForm )

   DO CASE

   CASE t == 'SLIDER'
      _HMG_aControlBkColor [i] := Value
      RedrawWindow ( c )
      f := GetFocus()
      setfocus( c )
      setfocus( f )

   CASE t $ 'MULTIGRID,BROWSE'
      ListView_SetBkColor ( c, Value [1], Value [2], Value [3] )
      ListView_SetTextBkColor ( c, Value [1], Value [2], Value [3] )
      RedrawWindow ( c )

   CASE t == 'RICHEDIT'
      SendMessage ( c, EM_SETBKGNDCOLOR, 0, RGB ( Value [1], Value [2], Value [3] ) )
      RedrawWindow ( c )

   CASE t == 'DATEPICK'
      _HMG_aControlBkColor [i] := Value
      SetDatePickBkColor( c, Value [1], Value [2], Value [3] )

   CASE t == 'MONTHCAL'
      _HMG_aControlBkColor [i] := Value
      SetMonthCalMonthBkColor( c, Value [1], Value [2], Value [3] )

   CASE t == 'PROGRESSBAR'
      _HMG_aControlBkColor [i] := Value
      SetProgressBarBkColor( c, Value [1], Value [2], Value [3] )

   CASE t == 'TREE'
      _HMG_aControlBkColor [i] := Value
      TreeView_SetBkColor( c, Value )

   CASE t == 'TAB'
      _HMG_aControlBkColor [i] := Value
      DeleteObject ( _HMG_aControlBrushHandle [i] )
      _HMG_aControlBrushHandle [i] := CreateSolidBrush ( Value [1], Value [2], Value [3] )
      SetWindowBrush ( c, _HMG_aControlBrushHandle [i] )
      RedrawWindow ( c )

   CASE "TEXT" $ t .OR. t == "EDIT" .OR. t == "GETBOX"
      _HMG_aControlBkColor [i] := iif( ISARRAY ( Value ), Value, { nRGB2Arr ( d ), nRGB2Arr ( f ), nRGB2Arr ( d ) } )
      RedrawWindow ( c )

   OTHERWISE
      _HMG_aControlBkColor [i] := Value
      _RedrawControl ( i )

   END CASE

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION _GetFontColor ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i , t , RetVal [3] , Tmp

   i := GetControlIndex ( ControlName, ParentForm )
   t := GetControlType ( ControlName, ParentForm )

   IF t $ 'MULTIGRID,BROWSE'
      Tmp := ListView_GetTextColor ( _HMG_aControlHandles [i] )
      RetVal [1] := GetRed ( Tmp )
      RetVal [2] := GetGreen ( Tmp )
      RetVal [3] := GetBlue ( Tmp )
   ELSE
      RetVal := _HMG_aControlFontColor [i]
   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNCTION _GetBackColor ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i , t , RetVal , Tmp

   i := GetControlIndex ( ControlName, ParentForm )
   t := GetControlType ( ControlName, ParentForm )

   IF t $ 'MULTIGRID,BROWSE'
      Tmp := ListView_GetBkColor ( _HMG_aControlHandles [i] )
      RetVal := nRGB2Arr ( Tmp )
   ELSE
      IF i > 0
         RetVal := _HMG_aControlBkColor [i]
      ENDIF
   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
STATIC PROCEDURE _SetTextEditReadOnly ( ControlName, ParentForm, Value )
*-----------------------------------------------------------------------------*
   LOCAL lValue As Logical
   LOCAL i , t

   Assign lValue := Value

   i := GetControlIndex ( ControlName, ParentForm )
   t := GetControlType ( ControlName, ParentForm )

   IF t == "TEXT" .OR. t == "NUMTEXT" .OR. t == "MASKEDTEXT" .OR. t == "CHARMASKTEXT" .OR. t == "SPINNER"
      _HMG_aControlMiscData1 [ i, 2 ] := lValue
   ELSEIF t == "GETBOX"
      _HMG_aControlMiscData1 [ i, 2 ] := lValue
      _HMG_aControlProcedures [i] := iif( lValue, NIL, _HMG_aControlMiscData1 [ i, 4 ] )
      _HMG_aControlDblClick [i] := iif( lValue, NIL, _HMG_aControlMiscData1 [ i, 5 ] )
   ELSEIF t == "EDIT" .OR. t == "BTNTEXT" .OR. t == "BTNNUMTEXT"
      _HMG_aControlMiscData1 [ i, 3 ] := lValue
   ENDIF

   IF t == "SPINNER"
      SendMessage( _HMG_aControlHandles [i][1], EM_SETREADONLY, iif( lValue, 1, 0 ), 0 )
   ELSEIF t == "COMBO" .AND. _HMG_aControlMiscData1 [i][2] == .T.
      SendMessage( _HMG_aControlRangeMin [i], EM_SETREADONLY, iif( lValue, 1, 0 ), 0 )
   ELSE
      SendMessage( _HMG_aControlHandles [i], EM_SETREADONLY, iif( lValue, 1, 0 ), 0 )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SetStatusIcon ( ControlName , ParentForm , Item , Icon )
*-----------------------------------------------------------------------------*
   LOCAL nItem As Numeric
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   Assign nItem := Item

   SetStatusItemIcon ( _HMG_aControlHandles [i] , nItem , Icon )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SetStatusWidth ( ParentForm , Item , Size )
*-----------------------------------------------------------------------------*
   LOCAL nItem As Numeric , nSize As Numeric
   LOCAL FormHandle := GetFormHandle ( ParentForm ) , aWidths , StatusHandle

   Assign nItem := Item
   Assign nSize := Size

   IF ( StatusHandle := GetControlHandle ( "StatusBar" , ParentForm ) ) > 0
      aWidths := _GetStatusItemWidth ( FormHandle )
      _SetStatusItemWidth ( nItem , nSize , FormHandle )
      aWidths [ nItem ] := nSize
      SetStatusBarSize ( StatusHandle , aWidths )
      RefreshItemBar ( StatusHandle , _GetStatusItemWidth ( FormHandle , 1 ) )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _GetControlFree()
*-----------------------------------------------------------------------------*
   LOCAL k := AScan ( _HMG_aControlDeleted , .T. )

#ifdef _HMG_COMPAT_
   IF k == 0 .OR. ( __mvExist ( '_HMG_SYSDATA[443][k]' ) .AND. _HMG_StopControlEventProcedure [k] == .T. )
#else
   IF k == 0
#endif
      k := Len( _HMG_aControlNames ) + 1

      AAdd ( _HMG_aControlType         , Nil )
      AAdd ( _HMG_aControlNames        , Nil )
      AAdd ( _HMG_aControlHandles      , Nil )
      AAdd ( _HMG_aControlParenthandles, Nil )
      AAdd ( _HMG_aControlIds          , Nil )
      AAdd ( _HMG_aControlProcedures   , Nil )
      AAdd ( _HMG_aControlPageMap      , Nil )
      AAdd ( _HMG_aControlValue        , Nil )
      AAdd ( _HMG_aControlInputMask    , Nil )
      AAdd ( _HMG_aControllostFocusProcedure, Nil )
      AAdd ( _HMG_aControlGotFocusProcedure , Nil )
      AAdd ( _HMG_aControlChangeProcedure   , Nil )
      AAdd ( _HMG_aControlDeleted      , Nil )
      AAdd ( _HMG_aControlBkColor      , Nil )
      AAdd ( _HMG_aControlFontColor    , Nil )
      AAdd ( _HMG_aControlDblClick     , Nil )
      AAdd ( _HMG_aControlHeadClick    , Nil )
      AAdd ( _HMG_aControlRow          , Nil )
      AAdd ( _HMG_aControlCol          , Nil )
      AAdd ( _HMG_aControlWidth        , Nil )
      AAdd ( _HMG_aControlHeight       , Nil )
      AAdd ( _HMG_aControlSpacing      , Nil )
      AAdd ( _HMG_aControlContainerRow , Nil )
      AAdd ( _HMG_aControlContainerCol , Nil )
      AAdd ( _HMG_aControlPicture      , Nil )
      AAdd ( _HMG_aControlContainerHandle   , Nil )
      AAdd ( _HMG_aControlFontName     , Nil )
      AAdd ( _HMG_aControlFontSize     , Nil )
      AAdd ( _HMG_aControlFontAttributes    , Nil )
      AAdd ( _HMG_aControlToolTip      , Nil )
      AAdd ( _HMG_aControlRangeMin     , Nil )
      AAdd ( _HMG_aControlRangeMax     , Nil )
      AAdd ( _HMG_aControlCaption      , Nil )
      AAdd ( _HMG_aControlVisible      , Nil )
      AAdd ( _HMG_aControlHelpId       , Nil )
      AAdd ( _HMG_aControlFontHandle   , Nil )
      AAdd ( _HMG_aControlBrushHandle  , Nil )
      AAdd ( _HMG_aControlEnabled      , Nil )
      AAdd ( _HMG_aControlMiscData1    , Nil )
      AAdd ( _HMG_aControlMiscData2    , Nil )
#ifdef _HMG_COMPAT_
      AAdd ( _HMG_StopControlEventProcedure, .F. )
#endif
   ENDIF

RETURN k

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.1 Experimental Build 10b
// enable/disable screen update for List controls
*-----------------------------------------------------------------------------*
FUNCTION _EnableListViewUpdate ( ControlName, ParentForm, lEnable )
*-----------------------------------------------------------------------------*
   LOCAL i := GetControlIndex ( ControlName, ParentForm )
   LOCAL t := _HMG_aControlType [i]

   IF "GRID" $ t .OR. t == "COMBO" .OR. "BROWSE" $ t .OR. t == "TREE"
      SendMessage ( _HMG_aControlHandles [i], WM_SETREDRAW, iif( lEnable, 1, 0 ), 0 )
      _HMG_aControlEnabled [i] := lEnable
   ELSE
      MsgMiniGuiError ( "Method " + iif( lEnable, "En", "Dis" ) + "ableUpdate is not available for control " + ControlName )
   ENDIF

RETURN NIL

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.1 Experimental Build 11a
// cFile - string to be compacted (may be for example fullpath, path or file name)
// nMax  - required string size (characters count)
// _GetCompactPath("C:\Program Files\Adobe",20) -> "C:\Program...\Adobe"
*-----------------------------------------------------------------------------*
FUNCTION _GetCompactPath ( cFile, nMax )
*-----------------------------------------------------------------------------*
   LOCAL cShort := Space( IFNUMERIC( nMax, nMax + 1, 64 ) )

RETURN iif( GetCompactPath( @cShort, cFile, IFNUMERIC( nMax, nMax, 63 ), NIL ) > 0, cShort, cFile )

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.1 Experimental Build 11a
// _GetShortPathName("C:\Program Files\Adobe") -> "C:\Program~1\Adobe"
*-----------------------------------------------------------------------------*
FUNCTION _GetShortPathName ( cPath )
*-----------------------------------------------------------------------------*
   LOCAL cShortPathName

RETURN iif( GetShortPathName( cPath, @cShortPathName ) > 0, cShortPathName, cPath )

// Jacek Kubica <kubica@wssk.wroc.pl> HMG 1.1 Experimental Build 12a
// Extend disable/enable control without change any control properties
*-----------------------------------------------------------------------------*
FUNCTION _ExtDisableControl ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL hWnd := GetControlHandle ( ControlName, ParentForm )
   LOCAL icp, icpe
#ifdef _DBFBROWSE_
   LOCAL idx
#endif
   IF IsWindowEnabled ( hWnd )
      icp  := HiWord ( SendMessage ( hWnd , EM_GETSEL , 0 , 0 ) )
      icpe := LoWord ( SendMessage ( hWnd , EM_GETSEL , 0 , 0 ) )
      ChangeStyle ( hWnd , WS_DISABLED , , .F. )
      IF icp <> icpe
         SendMessage ( hWnd , EM_SETSEL , icpe , icpe )
      ENDIF
      HideCaret ( hWnd )
#ifdef _DBFBROWSE_
      IF GetControlType ( ControlName, ParentForm ) == "BROWSE"
         idx := GetControlIndex ( ControlName, ParentForm )
         IF _HMG_aControlIds [idx] != 0
            ChangeStyle ( _HMG_aControlIds [idx] , WS_DISABLED , , .F. )
         ENDIF
      ENDIF
#endif
   ENDIF

RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION _ExtEnableControl ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL hWnd := GetControlHandle ( ControlName, ParentForm )
#ifdef _DBFBROWSE_
   LOCAL idx
#endif
   IF ! IsWindowEnabled ( hWnd )
      ChangeStyle ( hWnd, , WS_DISABLED, .F. )
      ShowCaret ( hWnd )
#ifdef _DBFBROWSE_
      IF GetControlType ( ControlName, ParentForm ) == "BROWSE"
         idx := GetControlIndex ( ControlName, ParentForm )
         IF _HMG_aControlIds [idx] != 0
            ChangeStyle ( _HMG_aControlIds [idx], , WS_DISABLED, .F. )
         ENDIF
      ENDIF
#endif
   ENDIF

RETURN NIL

// Kevin Carmody <i@kevincarmody.com> 2007.04.23
// Set/Get RTF value of rich edit box.
*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetGetRichValue ( ControlName, ParentForm, cValue, nType )
*-----------------------------------------------------------------------------*
   LOCAL RetVal As String
   LOCAL i := GetControlIndex ( ControlName, ParentForm )

   IF _HMG_aControlType [i] == 'RICHEDIT'

      IF ValType( cValue ) == 'C'
         _DataRichEditBoxSetValue ( ControlName, ParentForm, cValue, nType )
      ELSE
         RetVal := _DataRichEditBoxGetValue ( ControlName, ParentForm, nType )
      ENDIF

   ENDIF

RETURN RetVal

// Kevin Carmody <i@kevincarmody.com> 2007.04.23
// Set/Get AutoFont mode of rich edit box.
*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetGetAutoFont ( ControlName, ParentForm, lAuto )
*-----------------------------------------------------------------------------*
   LOCAL RetVal := .T. , i := GetControlIndex ( ControlName, ParentForm )

   IF _HMG_aControlType [i] == 'RICHEDIT'

      IF ISLOGICAL ( lAuto )
         SetAutoFontRTF ( GetControlHandle ( ControlName , ParentForm ), lAuto )
      ELSE
         RetVal := GetAutoFontRTF ( GetControlHandle ( ControlName , ParentForm ) )
      ENDIF

   ENDIF

RETURN RetVal

// Eduardo Fernandes 2009/JUN/17
// Set/Get Grid Checkboxes item state.
*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetGetCheckboxItemState ( ControlName, ParentForm, Item, lState )
*-----------------------------------------------------------------------------*
   LOCAL RetVal As Logical
   LOCAL i

   i := GetControlIndex ( ControlName , ParentForm )

   IF "GRID" $ _HMG_aControlType [i]

      IF _HMG_aControlMiscData1 [i] [18]  // if checkboxes mode was activated

         IF ISLOGICAL ( lState )
            ListView_SetCheckState ( _HMG_aControlHandles [i], Item, lState )
         ELSE
            RetVal := ListView_GetCheckState ( _HMG_aControlHandles [i], Item )
         ENDIF

      ENDIF

   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNCTION _SetType ( cType )    // (c) 1996-1997, Bryan Duchesne
*-----------------------------------------------------------------------------*
   LOCAL xRetVal, cFormat := Set( 4 )

   SWITCH Upper( Left( cType, 1 ) )

   CASE "S"
      xRetVal := ""
      EXIT
   CASE "N"
      xRetVal := 0
      EXIT
   CASE "D"
      cFormat := Upper( cFormat )
      cFormat := StrTran( cFormat, "Y", " " )
      cFormat := StrTran( cFormat, "M", " " )
      cFormat := StrTran( cFormat, "D", " " )
      xRetVal := CToD( cFormat )
      EXIT
   CASE "B"
      xRetVal := {|| NIL }
      EXIT
   CASE "A"
      xRetVal := {}
      EXIT
   CASE "L"
      xRetVal := .F.

   ENDSWITCH

RETURN xRetVal

*-----------------------------------------------------------------------------*
FUNCTION _IsTyped ( a, b )     // (c) 1996-1997, Bryan Duchesne
*-----------------------------------------------------------------------------*

   IF a != NIL
      IF !( ValType ( a ) == ValType ( b ) )
         MsgMiniGuiError ( "Strongly Typed Variable Assignment: Data Type Mismatch." )
      ENDIF
   ENDIF

RETURN b

*-----------------------------------------------------------------------------*
FUNCTION _GetId ( nMax )
*-----------------------------------------------------------------------------*
   LOCAL nRetVal

   hb_default( @nMax, 65536 )

   REPEAT
      nRetVal := Random ( nMax )
   UNTIL ( AScan ( _HMG_aControlIds, nRetVal ) <> 0 )

RETURN nRetVal

*-----------------------------------------------------------------------------*
FUNCTION IsArrayRGB ( aColor )
*-----------------------------------------------------------------------------*

   IF ISARRAY ( aColor ) .AND. Len ( aColor ) == 3
      RETURN ( aColor [1] <> Nil .AND. aColor [2] <> Nil .AND. aColor [3] <> Nil )
   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
FUNCTION cFilePath ( cPathMask )
*-----------------------------------------------------------------------------*
   LOCAL cPath

   hb_FNameSplit ( cPathMask, @cPath )

RETURN Left( cPath, Len( cPath ) - 1 )

*-----------------------------------------------------------------------------*
FUNCTION cFileNoPath( cPathMask )
*-----------------------------------------------------------------------------*
   LOCAL cName, cExt

   hb_FNameSplit ( cPathMask, , @cName, @cExt )

RETURN ( cName + cExt )

*-----------------------------------------------------------------------------*
FUNCTION cFileNoExt( cPathMask )
*-----------------------------------------------------------------------------*
   LOCAL cName

   hb_FNameSplit( cPathMask, , @cName )

RETURN cName

// (JK) HMG 1.0 Experimental Build 8
*-----------------------------------------------------------------------------*
FUNCTION _IsComboExtend ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName, ParentForm ) ) > 0

      IF GetControlType ( ControlName, ParentForm ) == "COMBO" .AND. ;
         _HMG_aControlMiscData1 [i] [1] == 1
         RETURN .T.
      ENDIF

   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
FUNCTION _DefineLetterOrDigitHotKey ( Caption, i, FormName, bAction )
*-----------------------------------------------------------------------------*
   LOCAL c := Asc ( SubStr ( Caption , i + 1 , 1 ) )

   IF c >= 48 .AND. c <= 90
      _DefineHotKey ( FormName , MOD_ALT , c , bAction )
   ENDIF

RETURN Nil

#ifdef _PANEL_
*-----------------------------------------------------------------------------*
FUNCTION _IsWindowVisibleFromHandle ( Handle )
*-----------------------------------------------------------------------------*
   LOCAL lVisible As Logical
   LOCAL hForm

   FOR EACH hForm IN _HMG_aFormHandles

      IF hForm == Handle
         lVisible := .NOT. _HMG_aFormNoShow [ hb_enumindex( hForm ) ]
         EXIT
      ENDIF

   NEXT

RETURN lVisible

#endif
*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetGetMinMaxInfo ( cWindowName , nIndex , nValue )
*-----------------------------------------------------------------------------*
   LOCAL i, RetVal

   IF ( i := GetFormIndex ( cWindowName ) ) > 0

      IF PCount() == 2
         RetVal := _HMG_aFormMinMaxInfo [i] [nIndex]
      ELSE
         _HMG_aFormMinMaxInfo [i] [nIndex] := nValue
      ENDIF

   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetGetImageHBitmap ( ControlName , ParentForm , hBitmap )
*-----------------------------------------------------------------------------*
   LOCAL i, hWnd, RetVal

   IF ( i := GetControlIndex ( ControlName , ParentForm ) ) > 0

      IF PCount() == 2
         RetVal := _HMG_aControlBrushHandle [i]
      ELSE
         IF _HMG_aControlBrushHandle [i] <> 0
            DeleteObject ( _HMG_aControlBrushHandle [i] )
         ENDIF
         _HMG_aControlBrushHandle [i] := hBitmap
         hWnd := GetControlHandle ( ControlName, ParentForm )

         SendMessage ( hWnd, STM_SETIMAGE, IMAGE_BITMAP, hBitmap )

         IF Empty( _HMG_aControlValue [i] )
            _HMG_aControlWidth [i] := GetWindowWidth ( hWnd )
            _HMG_aControlHeight [i] := GetWindowHeight ( hWnd )
         ENDIF
      ENDIF

   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNCTION _GetPicture ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN ''
   ENDIF

RETURN iif( ISARRAY ( _HMG_aControlPicture [i] ) , _HMG_aControlPicture [i] [1] , _HMG_aControlPicture [i] )

*-----------------------------------------------------------------------------*
FUNCTION _GetCaption ( ControlName , ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL cRetVal
   LOCAL i := GetControlIndex ( ControlName , ParentForm )

   IF i == 0
      RETURN ''
   ENDIF

   IF _HMG_aControlType [i] == 'TOOLBUTTON'

      cRetVal := _HMG_aControlCaption [i]

   ELSE

      cRetVal := GetWindowText ( _HMG_aControlHandles [i] )

   ENDIF

RETURN cRetVal

*-----------------------------------------------------------------------------*
FUNCTION _GetFocusedControlType ( nFormHandle )
*-----------------------------------------------------------------------------*
   LOCAL nHandle := GetFocus()
   LOCAL cType As String
   LOCAL hControl, i

   FOR EACH hControl IN _HMG_aControlHandles

      i := hb_enumindex( hControl )

      IF _HMG_aControlParentHandles [i] == nFormHandle

         IF ValType ( hControl ) == 'N' .AND. hControl == nHandle
            cType := _HMG_aControlType [i]
            EXIT
         ENDIF

      ENDIF

   NEXT

RETURN cType

*-----------------------------------------------------------------------------*
FUNCTION _IsFieldExists ( Field )
*-----------------------------------------------------------------------------*
   LOCAL WorkArea
   LOCAL x := At ( '>', Field )

   WorkArea := Left ( Field , x - 2 )
   Field := Right ( Field, Len ( Field ) - x )

RETURN ( ( WorkArea )->( FieldPos ( Field ) ) != 0 )

*-----------------------------------------------------------------------------*
FUNCTION _IsControlEnabled ( ControlName, ParentForm, Position )
*-----------------------------------------------------------------------------*
   LOCAL i , t , w , RetVal

   i := GetControlIndex ( ControlName, ParentForm )
   t := GetControlType ( ControlName, ParentForm )

   IF t == 'MENU'
      RetVal := _IsMenuItemEnabled ( ControlName, ParentForm )

   ELSEIF t == 'RADIOGROUP'
      RetVal := IsWindowEnabled( _HMG_aControlHandles [i] [hb_defaultValue( Position, 1 )] )

   ELSEIF t == 'TAB' .AND. ISNUMBER( Position )
      FOR EACH w IN _HMG_aControlPageMap [i] [Position]
         IF ValType ( w ) <> "A"
            RetVal := IsWindowEnabled( w )
         ELSE
            FOR EACH t IN w
               RetVal := IsWindowEnabled( t )
               IF RetVal
                  EXIT
               ENDIF
            NEXT
         ENDIF
         IF RetVal
            EXIT
         ENDIF
      NEXT

   ELSE
      RetVal := _HMG_aControlEnabled [i]

   ENDIF

RETURN RetVal

*-----------------------------------------------------------------------------*
FUNCTION _IsControlDefined ( ControlName, FormName )
*-----------------------------------------------------------------------------*
   LOCAL mVar , i

   mVar := '_' + NoQuote ( FormName ) + '_' + NoQuote ( ControlName )

   IF __mvExist ( mVar ) .AND. Type ( mVar ) == 'N'

      i := __mvGet ( mVar )
      IF i == 0
         RETURN .F.
      ENDIF
      RETURN ( .NOT. _HMG_aControlDeleted [ i ] )

   ENDIF

RETURN .F.

*-----------------------------------------------------------------------------*
STATIC FUNCTION NoQuote ( cStr )
*-----------------------------------------------------------------------------*

RETURN CharRem ( Chr( 34 ) + Chr( 39 ), cStr )

*-----------------------------------------------------------------------------*
STATIC FUNCTION GetUserControlType ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
   LOCAL i, cRetName

   IF ( i := GetControlIndex ( ControlName, ParentForm ) ) == 0
      RETURN ''
   ENDIF

   cRetName := _HMG_aControlType [i]

   IF cRetName == 'CHECKBOX' .AND. ValType ( _HMG_aControlPageMap [i] ) == 'A'
      cRetName := 'CHECKBUTTON'

   ELSEIF cRetName == 'COMBO'
      IF _HMG_aControlMiscData1 [i][1] == 0      // standard combo
         cRetName += 'BOX'

      ELSEIF _HMG_aControlMiscData1 [i][1] == 1  // extend combo
         cRetName += 'BOXEX'
      ENDIF

   ELSEIF "TEXT" $ cRetName .OR. "EDIT" $ cRetName .OR. ( "LIST" $ cRetName .AND. cRetName != 'IMAGELIST' )
      cRetName += 'BOX'

   ELSEIF "PICK" $ cRetName
      cRetName += 'ER'

   ELSEIF "MONTHCAL" $ cRetName
      cRetName += 'ENDAR'

   ELSEIF cRetName == 'MESSAGEBAR'
      cRetName := 'STATUSBAR'

   ELSEIF cRetName == 'ITEMMESSAGE'
      cRetName := 'STATUSITEM'

   ENDIF

RETURN cRetName

*-----------------------------------------------------------------------------*
STATIC FUNCTION _SetAlign ( ControlName, ParentForm, cAlign )
*-----------------------------------------------------------------------------*
   LOCAL i

   IF ( i := GetControlIndex ( ControlName, ParentForm ) ) == 0
      RETURN Nil
   ENDIF

   IF cAlign == "LEFT"

      ChangeStyle ( _HMG_aControlHandles [i] , , ES_CENTER + ES_RIGHT )

   ELSEIF cAlign == "RIGHT"

      ChangeStyle ( _HMG_aControlHandles [i] , ES_RIGHT , ES_CENTER + ES_RIGHT )

   ELSEIF cAlign == "CENTER"

      ChangeStyle ( _HMG_aControlHandles [i] , ES_CENTER , ES_CENTER + ES_RIGHT )

   ELSEIF cAlign == "VCENTER"

      ChangeStyle ( _HMG_aControlHandles [i] , SS_CENTERIMAGE )

   ENDIF

   _Refresh( i )

RETURN Nil

*-----------------------------------------------------------------------------*
STATIC FUNCTION _RedrawControl ( i )
*-----------------------------------------------------------------------------*
   LOCAL ControlHandle

   IF i > 0
      ControlHandle := _HMG_aControlHandles [i]
      IF ValType (ControlHandle ) == "A"
         AEval ( ControlHandle, { |x| RedrawWindow ( x , .T. ) } )
      ELSE
         RedrawWindow ( ControlHandle )
      ENDIF
   ENDIF

RETURN Nil
