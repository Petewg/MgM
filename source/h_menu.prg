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

#include "minigui.ch"

STATIC _HMG_xPopupMenuFont, _HMG_xContextPopupMenuFont

*-----------------------------------------------------------------------------*
PROCEDURE _DefineMainMenu ( Parent )
*-----------------------------------------------------------------------------*

   IF ValType( Parent ) == 'U'
      Parent := _HMG_ActiveFormName
   ENDIF

   _HMG_xMenuType := 'MAIN'

   _HMG_xMainMenuParentName := Parent

   _HMG_xMainMenuParentHandle := GetFormHandle ( Parent )

   _HMG_xMainMenuHandle := CreateMenu()

   _HMG_xMenuPopupLevel := 0

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _DefineMenuPopup ( Caption, Name, Image, Font )
*-----------------------------------------------------------------------------*
   LOCAL mVar , k , FormName

   IF _HMG_xMenuType $ 'MAIN,CONTEXT,OWNCONTEXT,NOTIFY,DROPDOWN'

      mVar := Left( _HMG_xMenuType, 1 )
      SWITCH mVar

      CASE 'M'
         IF _HMG_xMenuPopupLevel == 0

            IF ValType( Font ) != 'U' .AND. ValType( _HMG_xPopupMenuFont ) == 'U'
               _HMG_xPopupMenuFont := Font
            ENDIF

         ENDIF

         _HMG_xMenuPopupLevel ++

         _HMG_xMenuPopuphandle[ _HMG_xMenuPopupLevel ] := CreatePopupMenu( 1 )
         _HMG_xMenuPopupCaption[ _HMG_xMenuPopupLevel ] := Caption

         IF _HMG_xMenuPopupLevel > 1

            AppendMenuPopup ( _HMG_xMenuPopuphandle[_HMG_xMenuPopupLevel - 1 ], ;
               _HMG_xMenuPopuphandle[ _HMG_xMenuPopupLevel ], ;
               _HMG_xMenuPopupCaption[ _HMG_xMenuPopupLevel ], 2, Font )

         ENDIF
         EXIT

      CASE 'C'
      CASE 'O'
      CASE 'N'
      CASE 'D'
         SWITCH mVar
         CASE 'C'
            k := 3
            EXIT
         CASE 'N'
            k := 4
            EXIT
         CASE 'O'
         CASE 'D'
            k := 5
         ENDSWITCH

         IF _HMG_xContextPopupLevel == 0

            IF ValType( Font ) != 'U' .AND. ValType( _HMG_xContextPopupMenuFont ) == 'U'
               _HMG_xContextPopupMenuFont := Font
            ENDIF

         ENDIF

         _HMG_xContextPopupLevel ++

         _HMG_xContextPopupHandle[ _HMG_xContextPopupLevel ] := CreatePopupMenu( k )
         _HMG_xContextPopupCaption[ _HMG_xContextPopupLevel ] := Caption

         IF _HMG_xContextPopupLevel > 1

            AppendMenuPopup ( _HMG_xContextPopupHandle[ _HMG_xContextPopupLevel - 1 ], ;
               _HMG_xContextPopupHandle[ _HMG_xContextPopupLevel ], ;
               _HMG_xContextPopupCaption[ _HMG_xContextPopupLevel ], k, Font )

         ENDIF

      ENDSWITCH

      FormName := iif( _HMG_xMenuType == 'MAIN', _HMG_xMainMenuParentName, _HMG_xContextMenuParentName )
      k := _GetControlFree()

      IF ValType ( name ) == 'U'
#ifndef _EMPTY_MENU_
         Name := 'DummyPopupName' + hb_ntos( k )
#else
         Name := ''
#endif
      ENDIF
      IF !Empty ( name )
         mVar := '_' + FormName + '_' + Name
         Public &mVar. := k
      ENDIF

      _HMG_aControlType [k] :=  "POPUP"
      _HMG_aControlNames  [k] :=  Name
      _HMG_aControlHandles  [k] :=  0
      _HMG_aControlIds  [k] :=  iif( _HMG_xMenuType == 'MAIN', _HMG_xMenuPopupLevel, _HMG_xContextPopupLevel )
      _HMG_aControlProcedures [k] :=  Nil
      _HMG_aControlValue  [k] :=  Nil
      _HMG_aControlInputMask   [k] :=  FormName
      _HMG_aControllostFocusProcedure  [k] :=  ""
      _HMG_aControlGotFocusProcedure  [k] :=  ""
      _HMG_aControlChangeProcedure  [k] :=  ""
      _HMG_aControlDeleted  [k] :=  .F.
      _HMG_aControlBkColor  [k] :=  Nil
      _HMG_aControlFontColor  [k] :=  Nil
      _HMG_aControlDblClick   [k] := ""
      _HMG_aControlHeadClick  [k] :=  {}
      _HMG_aControlRow  [k] :=  0
      _HMG_aControlCol  [k] :=  0
      _HMG_aControlWidth  [k] :=  0
      _HMG_aControlHeight  [k] :=  0
      _HMG_aControlContainerRow  [k] :=  -1
      _HMG_aControlContainerCol  [k] :=  -1
      _HMG_aControlPicture  [k] :=  Image
      _HMG_aControlContainerHandle  [k] :=  0
      _HMG_aControlFontName  [k] :=  ''
      _HMG_aControlFontSize  [k] :=  0
      _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
      _HMG_aControlToolTip   [k] :=  ''
      _HMG_aControlRangeMin  [k] :=  0
      _HMG_aControlRangeMax  [k] :=  0
      _HMG_aControlCaption  [k] :=  Caption
      _HMG_aControlVisible  [k] :=  .T.
      _HMG_aControlHelpId  [k] :=  0
      _HMG_aControlFontHandle   [k] :=  0
      _HMG_aControlBrushHandle  [k] :=  0
      _HMG_aControlEnabled  [k] :=  .T.
      _HMG_aControlMiscData1 [k] := 0
      _HMG_aControlMiscData2 [k] := ''

      IF _HMG_xMenuType == 'MAIN'
         _HMG_aControlHandles[ k ]       := _HMG_xMenuPopuphandle[ _HMG_xMenuPopupLevel ]
         _HMG_aControlParentHandles[ k ] := _HMG_xMainMenuParentHandle
         _HMG_aControlPageMap[ k ]       := _HMG_xMainMenuHandle
         _HMG_aControlSpacing[ k ]       := _HMG_xMenuPopupHandle[ _HMG_xMenuPopupLevel ]
      ELSE
         _HMG_aControlHandles[ k ]       := _HMG_xContextPopupHandle[ _HMG_xContextPopupLevel ]
         _HMG_aControlParentHandles[ k ] := _HMG_xContextMenuParentHandle
         _HMG_aControlPageMap[ k ]       := _HMG_xContextMenuHandle
         _HMG_aControlSpacing[ k ]       := _HMG_xContextPopupHandle[ _HMG_xContextPopupLevel ]
      ENDIF

   ELSE

      MsgMiniGuiError( "Menu type incorrect." )

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _EndMenuPopup()
*-----------------------------------------------------------------------------*
   LOCAL k

   IF _HMG_xMenuType == 'MAIN'

      _HMG_xMenuPopupLevel --

      IF _HMG_xMenuPopupLevel == 0

         AppendMenuPopup( _HMG_xMainMenuHandle, _HMG_xMenuPopupHandle[ 1 ], ;
            _HMG_xMenuPopupCaption[ 1 ], 1, _HMG_xPopupMenuFont )

      ENDIF

   ELSEIF _HMG_xMenuType $ 'CONTEXT,OWNCONTEXT,NOTIFY,DROPDOWN'

      _HMG_xContextPopupLevel --

      IF _HMG_xContextPopupLevel == 0

         SWITCH Left( _HMG_xMenuType, 1 )
         CASE 'C'
            k := 3
            EXIT
         CASE 'N'
            k := 4
            EXIT
         CASE 'O'
         CASE 'D'
            k := 5
         ENDSWITCH

         AppendMenuPopup( _HMG_xContextMenuHandle, _HMG_xContextPopupHandle[ 1 ], ;
            _HMG_xContextPopupCaption[ 1 ], k, _HMG_xContextPopupMenuFont )

      ENDIF

   ELSE

      MsgMiniGuiError( "Menu type incorrect." )

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _DefineMenuItem ( caption, action, name, Image, checked, disabled, cMessage, font, check_image, lBreakMenu, lSeparator )
*-----------------------------------------------------------------------------*
   LOCAL Controlhandle , mVar , k , id , hBitmap := 0 , ContextMenuHandle , nBreakCode := 6

   hb_default( @checked, .F. )
   hb_default( @disabled, .F. )
   hb_default( @lBreakMenu, .F. )

   IF lBreakMenu
      nBreakCode := 1
      IF hb_defaultValue( lSeparator, .F. )
         nBreakCode := 2
      ENDIF
   ENDIF

   id := _GetId()

   IF _HMG_xMenuType == 'MAIN'

      IF !( caption == '-' )
         Controlhandle := _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ]
         AppendMenuString( Controlhandle , id , caption , nBreakCode )
      ENDIF

      IF ValType ( image ) != 'U'
         hBitmap := MenuItem_SetBitMaps ( _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ] , id , image , '' )
      ENDIF

      IF ValType ( check_image ) != 'U'
         MenuItem_SetCheckMarks( _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ] , id , check_image , '' )
      ENDIF

      IF ValType ( font ) != 'U'
         MenuItem_SetFont( _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ] , id , font )
      ENDIF

      k := _GetControlFree()

      IF ValType ( name ) == 'U'
#ifndef _EMPTY_MENU_
         Name := 'DummyMenuName' + hb_ntos( k )
#else
         Name := ''
#endif
      ENDIF
      IF !Empty ( name )
         mVar := '_' + _HMG_xMainMenuParentName + '_' + Name
         Public &mVar. := k
      ENDIF

      _HMG_aControlType [k] :=  "MENU"
      _HMG_aControlNames  [k] :=  Name
      _HMG_aControlHandles  [k] :=  Controlhandle
      _HMG_aControlParentHandles  [k] :=  _HMG_xMainMenuParentHandle
      _HMG_aControlIds  [k] :=  id
      _HMG_aControlProcedures  [k] :=  action
      _HMG_aControlPageMap  [k] :=  _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ]
      _HMG_aControlValue  [k] := cMessage
      _HMG_aControlInputMask  [k] :=  ""
      _HMG_aControllostFocusProcedure  [k] :=  ""
      _HMG_aControlGotFocusProcedure  [k] :=  ""
      _HMG_aControlChangeProcedure  [k] :=  ""
      _HMG_aControlDeleted  [k] :=  .F.
      _HMG_aControlBkColor  [k] :=  Nil
      _HMG_aControlFontColor [k] :=   Nil
      _HMG_aControlDblClick   [k] := ""
      _HMG_aControlHeadClick  [k] :=  {}
      _HMG_aControlRow  [k] :=  0
      _HMG_aControlCol   [k] := 0
      _HMG_aControlWidth  [k] :=  0
      _HMG_aControlHeight  [k] :=  0
      _HMG_aControlSpacing  [k] :=  0
      _HMG_aControlContainerRow  [k] :=  -1
      _HMG_aControlContainerCol  [k] :=  -1
      _HMG_aControlPicture  [k] :=  ""
      _HMG_aControlContainerHandle  [k] :=  0
      _HMG_aControlFontName  [k] :=  ''
      _HMG_aControlFontSize  [k] :=  0
      _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
      _HMG_aControlToolTip   [k] :=  ''
      _HMG_aControlRangeMin  [k] :=   0
      _HMG_aControlRangeMax   [k] :=  0
      _HMG_aControlCaption  [k] :=   Caption
      _HMG_aControlVisible  [k] :=   .T.
      _HMG_aControlHelpId  [k] :=   0
      _HMG_aControlFontHandle  [k] :=   0
      _HMG_aControlBrushHandle  [k] :=  hBitmap
      _HMG_aControlEnabled  [k] :=  .T.
      _HMG_aControlMiscData1 [k] := 0
      _HMG_aControlMiscData2 [k] := ''

      IF checked
         xCheckMenuItem ( _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ] , id )
      ENDIF

      IF disabled
         xDisableMenuItem ( _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ] , id )
         _HMG_aControlEnabled [k] := .F.
      ENDIF

   ELSE

      IF !( caption == '-' )
         IF _HMG_xContextPopupLevel > 0
            ContextMenuHandle := _HMG_xContextPopupHandle[ _HMG_xContextPopupLevel ]
            AppendMenuString( ContextMenuHandle, id, caption, iif( lBreakMenu, nBreakCode, 7 ) )
         ELSE
            ContextMenuHandle := _HMG_xContextMenuHandle
            AppendMenuString( ContextMenuHandle, id, caption, iif( lBreakMenu, nBreakCode, 8 ) )
         ENDIF
         ControlHandle := ContextMenuHandle
      ENDIF

      IF ValType ( image ) != 'U'
         hBitmap := MenuItem_SetBitMaps( ContextMenuHandle, id, image , '' )
      ENDIF

      IF ValType ( check_image ) != 'U'
         MenuItem_SetCheckMarks( ContextMenuHandle, id, check_image , '' )
      ENDIF

      IF ValType ( font ) != 'U'
         MenuItem_SetFont( ContextMenuHandle, id, font )
      ENDIF

      k := _GetControlFree()

      IF ValType ( name ) == 'U'
#ifndef _EMPTY_MENU_
         Name := 'DummyMenuName' + hb_ntos( k )
#else
         Name := ''
#endif
      ENDIF
      IF !Empty ( name )
         mVar := '_' + _HMG_xContextMenuParentName + '_' + Name
         Public &mVar. := k
      ENDIF

      _HMG_aControlType  [k] :=  "MENU"
      _HMG_aControlNames  [k] :=  Name
      _HMG_aControlHandles  [k] :=  Controlhandle
      _HMG_aControlParentHandles  [k] :=  _HMG_xContextMenuParentHandle
      _HMG_aControlIds  [k] :=   id
      _HMG_aControlProcedures  [k] :=  action
      _HMG_aControlPageMap  [k] :=  _HMG_xContextMenuHandle
      _HMG_aControlValue  [k] :=  cMessage
      _HMG_aControlInputMask   [k] :=  ""
      _HMG_aControllostFocusProcedure  [k] :=  ""
      _HMG_aControlGotFocusProcedure  [k] :=  ""
      _HMG_aControlChangeProcedure  [k] :=  ""
      _HMG_aControlDeleted  [k] :=  .F.
      _HMG_aControlBkColor  [k] :=  Nil
      _HMG_aControlFontColor  [k] :=  Nil
      _HMG_aControlDblClick  [k] :=  ""
      _HMG_aControlHeadClick  [k] :=  {}
      _HMG_aControlRow  [k] :=  0
      _HMG_aControlCol  [k] :=  0
      _HMG_aControlWidth  [k] :=  0
      _HMG_aControlHeight   [k] :=  0
      _HMG_aControlSpacing   [k] :=  0
      _HMG_aControlContainerRow  [k] :=  -1
      _HMG_aControlContainerCol  [k] :=  -1
      _HMG_aControlPicture  [k] :=  ""
      _HMG_aControlContainerHandle [k] :=  0
      _HMG_aControlFontName  [k] :=  ''
      _HMG_aControlFontSize  [k] :=  0
      _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
      _HMG_aControlToolTip   [k] :=  ''
      _HMG_aControlRangeMin   [k] :=  0
      _HMG_aControlRangeMax  [k] :=  0
      _HMG_aControlCaption  [k] :=  Caption
      _HMG_aControlVisible  [k] :=  .T.
      _HMG_aControlHelpId   [k] :=  0
      _HMG_aControlFontHandle  [k] :=  0
      _HMG_aControlBrushHandle [k] :=  hBitmap
      _HMG_aControlEnabled  [k] :=  .T.
      _HMG_aControlMiscData1 [k] := 1
      _HMG_aControlMiscData2 [k] := ''

      IF checked
         xCheckMenuItem( ContextMenuHandle, id )
      ENDIF

      IF disabled
         xDisableMenuItem( ContextMenuHandle, id )
         _HMG_aControlEnabled [k] := .F.
      ENDIF

   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _DefineSeparator ()
*-----------------------------------------------------------------------------*

   IF _HMG_xMenuType == 'MAIN'

      AppendMenuSeparator ( _HMG_xMenuPopuphandle [_HMG_xMenuPopupLevel ] )

   ELSE

      IF _HMG_xContextPopupLevel > 0

         AppendMenuSeparator ( _HMG_xContextPopupHandle[ _HMG_xContextPopupLevel ] )

      ELSE

         AppendMenuSeparator ( _HMG_xContextMenuHandle )

      ENDIF

   ENDIF

   IF IsExtendedMenuStyleActive() // GF 30/08/10
      _DefineMenuItem ( '-' )
   ENDIF

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _EndMenu()
*-----------------------------------------------------------------------------*
   LOCAL i, j, image

   SWITCH Left( _HMG_xMenuType, 1 )

   CASE 'M' // MAIN

      SetMenu( _HMG_xMainMenuParentHandle , _HMG_xMainMenuHandle )
      EXIT

   CASE 'C' // CONTEXT

      i := GetFormIndex ( _HMG_xContextMenuParentName )
      _HMG_aFormContextMenuHandle [i] := _HMG_xContextMenuHandle
      EXIT

   CASE 'N' // NOTIFY

      i := GetFormIndex ( _HMG_xContextMenuParentName )
      _HMG_aFormNotifyMenuHandle [i] := _HMG_xContextMenuHandle
      EXIT

   CASE 'D' // DROPDOWN

      _HMG_aControlRangeMax [_HMG_xContextMenuButtonIndex] := _HMG_xContextMenuHandle
      EXIT

   CASE 'O' // OWNCONTEXT

      IF ValType( _HMG_xContextMenuButtonIndex ) == "A"

         FOR j := 1 TO Len( _HMG_xContextMenuButtonIndex )

            i := _HMG_aControlHandles[ _HMG_xContextMenuButtonIndex [j] ]
            IF ValType( i ) == "A"
               AEval( i , {|x| AAdd( _HMG_aControlsContextMenu , { x , _HMG_xContextMenuHandle , _HMG_xContextMenuButtonIndex [j] , .T. } ) } )
            ELSE
               AAdd( _HMG_aControlsContextMenu , { i , _HMG_xContextMenuHandle , _HMG_xContextMenuButtonIndex [j] , .T. } )
            ENDIF

         NEXT
      ELSE
         i := _HMG_aControlHandles[ _HMG_xContextMenuButtonIndex ]
         IF ValType( i ) == "A"
            AEval( i , {|x| AAdd( _HMG_aControlsContextMenu , { x , _HMG_xContextMenuHandle , _HMG_xContextMenuButtonIndex , .T. } ) } )
         ELSE
            AAdd( _HMG_aControlsContextMenu , { i , _HMG_xContextMenuHandle , _HMG_xContextMenuButtonIndex , .T. } )
         ENDIF

      ENDIF

   ENDSWITCH

   FOR i := 1 TO Len ( _HMG_aControlHandles )

      IF _HMG_aControlType [i] == "POPUP"

         image := _HMG_aControlPicture [i]
         IF ValType ( image ) != 'U'
            _HMG_aControlBrushHandle [i] := MenuItem_SetBitMaps ( _HMG_aControlPageMap [i] , _HMG_aControlSpacing [i] , image , '' )
         ENDIF

      ENDIF

   NEXT

RETURN

*-----------------------------------------------------------------------------*
STATIC FUNCTION _GetMenuIds ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL id
   LOCAL x := GetControlIndex ( ItemName , FormName )
   LOCAL h := _HMG_aControlPageMap [ x ]

   IF _HMG_aControlType [ x ] == "MENU"
      id := _HMG_aControlIds [ x ]
   ELSEIF _HMG_aControlType [ x ] == "POPUP"
      id := _HMG_aControlSpacing [ x ]
   ENDIF

RETURN { h, id }

*-----------------------------------------------------------------------------*
FUNCTION _DisableMenuItem ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

   xDisableMenuItem ( a [1] , a [2] )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _EnableMenuItem ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

   xEnableMenuItem ( a [1] , a [2] )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _CheckMenuItem ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

   xCheckMenuItem ( a [1] , a [2] )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _UncheckMenuItem ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

   xUncheckMenuItem ( a [1] , a [2] )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _IsMenuItemChecked ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

RETURN xGetMenuCheckState ( a [1] , a [2] )

*-----------------------------------------------------------------------------*
FUNCTION _IsMenuItemEnabled ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

RETURN xGetMenuEnabledState ( a [1] , a [2] )

*-----------------------------------------------------------------------------*
PROCEDURE _DefineContextMenu ( Parent )
*-----------------------------------------------------------------------------*

   _HMG_xContextMenuHandle := 0
   _HMG_xContextMenuParentHandle := 0
   _HMG_xContextPopupLevel := 0
   _HMG_xContextMenuParentName := ""

   _HMG_xMenuType := 'CONTEXT'

   _HMG_xMenuPopupLevel := 0

   IF ValType( Parent ) == 'U'
      Parent := _HMG_ActiveFormName
   ENDIF

   _HMG_xContextMenuParentHandle := GetFormHandle ( Parent )
   _HMG_xContextMenuParentName := Parent
   _HMG_xContextMenuHandle := CreatePopupMenu( 3 )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _DefineNotifyMenu ( Parent )
*-----------------------------------------------------------------------------*

   _HMG_xContextMenuHandle := 0
   _HMG_xContextMenuParentHandle := 0
   _HMG_xContextPopupLevel := 0
   _HMG_xContextMenuParentName := ""

   _HMG_xMenuType := 'NOTIFY'

   _HMG_xMenuPopupLevel := 0

   IF ValType( Parent ) == 'U'
      Parent := _HMG_ActiveFormName
   ENDIF

   _HMG_xContextMenuParentHandle := GetFormHandle ( Parent )
   _HMG_xContextMenuParentName := Parent
   _HMG_xContextMenuHandle := CreatePopupMenu( 4 )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _DefineDropDownMenu ( Button , Parent )
*-----------------------------------------------------------------------------*

   _HMG_xContextMenuHandle := 0
   _HMG_xContextMenuParentHandle := 0
   _HMG_xContextPopupLevel := 0
   _HMG_xContextMenuParentName := ""

   _HMG_xMenuType := 'DROPDOWN'

   _HMG_xMenuPopupLevel := 0

   IF ValType( Parent ) == 'U'
      Parent := _HMG_ActiveFormName
   ENDIF

   _HMG_xContextMenuButtonIndex := GetControlIndex ( Button , Parent )
   _HMG_xContextMenuParentHandle := GetFormHandle ( Parent )
   _HMG_xContextMenuParentName := Parent
   _HMG_xContextMenuHandle := CreatePopupMenu( 5 )

RETURN

// Added HMG Ex v.1.3 build 38
*-----------------------------------------------------------------------------*
PROCEDURE _DefineControlContextMenu ( Control , Parent )
*-----------------------------------------------------------------------------*

   _HMG_xContextMenuHandle := 0
   _HMG_xContextMenuParentHandle := 0
   _HMG_xContextPopupLevel := 0
   _HMG_xContextMenuParentName := ""

   _HMG_xMenuType := 'OWNCONTEXT'

   _HMG_xMenuPopupLevel := 0

   IF ValType( Parent ) == 'U'
      Parent := _HMG_ActiveFormName
   ENDIF

   IF ValType( Control ) == "A"
      _HMG_xContextMenuButtonIndex := {}
      AEval( Control , { |x| AAdd( _HMG_xContextMenuButtonIndex , GetControlIndex ( x , Parent ) ) } )
   ELSE
      _HMG_xContextMenuButtonIndex := GetControlIndex ( Control , Parent )
   ENDIF

   _HMG_xContextMenuParentHandle := GetFormHandle ( Parent )
   _HMG_xContextMenuParentName := Parent
   _HMG_xContextMenuHandle := CreatePopupMenu( 5 )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _ShowControlContextMenu ( Control , Parent , lShow )
*-----------------------------------------------------------------------------*
   LOCAL h := GetControlHandle ( Control, Parent )
   LOCAL i, j

   IF ISARRAY( h )
      FOR j := 1 TO Len( h )
         FOR i := 1 TO Len( _HMG_aControlsContextMenu )
            IF _HMG_aControlsContextMenu[i,1] == h [j]
               _HMG_aControlsContextMenu[i,4] := lShow
            ENDIF
         NEXT
      NEXT
   ELSE
      FOR i := 1 TO Len( _HMG_aControlsContextMenu )
         IF _HMG_aControlsContextMenu[i,1] == h
            _HMG_aControlsContextMenu[i,4] := lShow
         ENDIF
      NEXT
   ENDIF

RETURN

// Added HMG Ex v.1.3 build 35
*-----------------------------------------------------------------------------*
FUNCTION _GetMenuItemCaption ( ItemName , FormName )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

RETURN xGetMenuCaption( a [1] , a [2] )

*-----------------------------------------------------------------------------*
FUNCTION _SetMenuItemCaption ( ItemName , FormName , Caption )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

RETURN xSetMenuCaption( a [1] , a [2] , Caption )

*-----------------------------------------------------------------------------*
PROCEDURE _SetMenuItemBitmap ( ItemName , FormName , Bitmap )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

   _HMG_aControlBrushHandle [GetControlIndex ( ItemName , FormName )] := MenuItem_SetBitMaps ( a [1] , a [2] , Bitmap , '' )

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE _SetMenuItemIcon ( ItemName , FormName , Icon )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

   _HMG_aControlBrushHandle [GetControlIndex ( ItemName , FormName )] := MenuItem_SetIcon ( a [1] , a [2] , Icon )

RETURN

*-----------------------------------------------------------------------------*
FUNCTION _SetMenuItemFont ( ItemName , FormName , Font )
*-----------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

RETURN MenuItem_SetFont ( a [1] , a [2] , Font )

*------------------------------------------------------------------------------*
FUNCTION _InsertMenuItem ( ItemName , FormName , caption , action , name , Image )
*------------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )
   LOCAL Id, mVar, Controlhandle := a [1], hBitmap := 0

   Id := _GetId()

   IF ValType ( name ) != 'U'
      mVar := '_' + _HMG_xMainMenuParentName + '_' + Name
      Public &mVar. := Len( _HMG_aControlNames ) + 1
   ELSE
      mVar := '_MenuDummyVar'
      Public &mVar. := 0
   ENDIF

   InsertMenuItem ( Controlhandle , a [2] , Id , caption )

   IF ValType ( image ) != 'U'
      hBitmap := MenuItem_SetBitMaps ( Controlhandle , Id , image , '' )
   ENDIF

   AAdd ( _HMG_aControlType , "MENU" )
   AAdd ( _HMG_aControlNames , Name )
   AAdd ( _HMG_aControlHandles , Controlhandle )
   AAdd ( _HMG_aControlParentHandles , _HMG_xMainMenuParentHandle )
   AAdd ( _HMG_aControlIds , id )
   AAdd ( _HMG_aControlProcedures , action )
   AAdd ( _HMG_aControlPageMap , a [1] )
   AAdd ( _HMG_aControlValue , Nil ) 
   AAdd ( _HMG_aControlInputMask , "" ) 
   AAdd ( _HMG_aControllostFocusProcedure , "" ) 
   AAdd ( _HMG_aControlGotFocusProcedure , "" ) 
   AAdd ( _HMG_aControlChangeProcedure , "" ) 
   AAdd ( _HMG_aControlDeleted , .F. ) 
   AAdd ( _HMG_aControlBkColor , Nil )
   AAdd ( _HMG_aControlFontColor , Nil )
   AAdd ( _HMG_aControlDblClick , "" )
   AAdd ( _HMG_aControlHeadClick , {} )
   AAdd ( _HMG_aControlRow , 0 )
   AAdd ( _HMG_aControlCol , 0 )
   AAdd ( _HMG_aControlWidth , 0 )
   AAdd ( _HMG_aControlHeight , 0 )
   AAdd ( _HMG_aControlSpacing , 0 )
   AAdd ( _HMG_aControlContainerRow , -1 )
   AAdd ( _HMG_aControlContainerCol , -1 )
   AAdd ( _HMG_aControlPicture , "" )
   AAdd ( _HMG_aControlContainerHandle , 0 )
   AAdd ( _HMG_aControlFontName , '' )
   AAdd ( _HMG_aControlFontSize , 0 )
   AAdd ( _HMG_aControlFontAttributes , { .F. , .F. , .F. , .F. } )
   AAdd ( _HMG_aControlToolTip  , ''  )
   AAdd ( _HMG_aControlRangeMin  , 0  )
   AAdd ( _HMG_aControlRangeMax  , 0  )
   AAdd ( _HMG_aControlCaption  , Caption  )
   AAdd ( _HMG_aControlVisible  , .T. )
   AAdd ( _HMG_aControlHelpId  , 0 )
   AAdd ( _HMG_aControlFontHandle  , 0 )
   AAdd ( _HMG_aControlBrushHandle , hBitmap )
   AAdd ( _HMG_aControlEnabled  , .T. )
   AAdd ( _HMG_aControlMiscData1 , 0 )
   AAdd ( _HMG_aControlMiscData2 , '' )

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _ModifyMenuItem ( ItemName , FormName , Caption , action , name , Image )
*------------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )
   LOCAL x := GetControlIndex ( ItemName , FormName )
   LOCAL Id , mVar

   Id := _HMG_aControlIds [ x ]

   IF ValType ( name ) != 'U'
      mVar := '_' + _HMG_xMainMenuParentName + '_' + Name
      Public &mVar. := x
   ELSE
      mVar := '_MenuDummyVar'
      Public &mVar. := 0
   ENDIF

   ModifyMenuItem ( a [1] , a [2] , Id , Caption )

   IF ValType ( image ) != 'U'
      DeleteObject ( _HMG_aControlBrushHandle [x] )
      _HMG_aControlBrushHandle [x] := MenuItem_SetBitMaps ( a [1] , Id , image , '' )
   ENDIF

   _HMG_aControlNames [x] := Name
   _HMG_aControlProcedures [x] := action
   _HMG_aControlCaption [x] := Caption

RETURN Nil

*------------------------------------------------------------------------------*
FUNCTION _RemoveMenuItem ( ItemName , FormName  )
*------------------------------------------------------------------------------*
   LOCAL a := _GetMenuIds ( ItemName , FormName )

RETURN RemoveMenuItem ( a [1] , a [2] )
