/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

IMAGELIST control source code
(C)2005 Janusz Pora <januszpora@onet.eu>

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

#define MAX_IMAGE 10
*-----------------------------------------------------------------------------*
FUNCTION _DefineImageList ( ControlName , ParentForm , w , h , aImage , aImageMask , aColor , ImageCount , mask )
*-----------------------------------------------------------------------------*
   LOCAL i , mVar , maskimage , color , k
   LOCAL ControlHandles , id , PosImage

   hb_default( @w, 24 )
   hb_default( @h, 24 )
   hb_default( @aImage, {} )
   hb_default( @aImageMask, {} )
   hb_default( @aColor, { 0, 0, 0 } )
   hb_default( @ImageCount, 0 )
   hb_default( @mask, .F. )

   IF _HMG_BeginWindowActive
      ParentForm := _HMG_ActiveFormName
   ENDIF

   IF .NOT. _IsWindowDefined ( ParentForm )
      MsgMiniGuiError( "Window: " + ParentForm + " is not defined." )
   ENDIF

   IF _IsControlDefined ( ControlName, ParentForm )
      MsgMiniGuiError( "Control: " + ControlName + " Of " + ParentForm + " Already defined." )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   k := Len( aImage )
   IF ImageCount == 0
      ImageCount := IFEMPTY( k, MAX_IMAGE, k )
   ENDIF

   Id := _GetId()
   ControlHandles := InitImageList ( w , h , mask , ImageCount )

   k := _GetControlFree()

   Public &mVar. := k

   _HMG_aControlType [k] := "IMAGELIST"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles [k] :=  ControlHandles
   _HMG_aControlParenthandles [k] :=  GetFormHandle( ParentForm )
   _HMG_aControlIds [k] :=  id
   _HMG_aControlProcedures  [k] :=  ""
   _HMG_aControlPageMap  [k] :=  {}
   _HMG_aControlValue  [k] :=  ImageCount
   _HMG_aControlInputMask  [k] :=  ""
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor   [k] := Nil
   _HMG_aControlFontColor   [k] := Nil
   _HMG_aControlDblClick   [k] :=  ""
   _HMG_aControlHeadClick   [k] := {}
   _HMG_aControlRow  [k] :=  0
   _HMG_aControlCol  [k] :=  0
   _HMG_aControlWidth   [k] :=  w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing  [k] :=  0
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 , _HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture  [k] :=  ""
   _HMG_aControlContainerHandle  [k] :=  0
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip   [k] :=  ''
   _HMG_aControlRangeMin  [k] :=  0
   _HMG_aControlRangeMax  [k] :=  0
   _HMG_aControlCaption  [k] :=  ''
   _HMG_aControlVisible  [k] :=  .T.
   _HMG_aControlHelpId  [k] :=  0
   _HMG_aControlFontHandle  [k] :=  0
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  0
   _HMG_aControlMiscData2 [k] :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   FOR i := 1 TO Len( aImage )
      IF mask
         IF Len( aImageMask ) > 0
            maskimage := iif( i <= Len( aImageMask ), aImageMask [i], "" )
            PosImage := IL_Add( ControlHandles , aImage [i] , maskimage , w , h , ImageCount )
         ELSE
            IF IsArrayRGB( aColor )
               color := RGB ( aColor [1] , aColor [2] , aColor [3] )
            ELSE
               color := aColor
            ENDIF
            PosImage := IL_AddMasked( ControlHandles , aImage [i] , color , w , h , ImageCount )
         ENDIF
      ELSE
         PosImage := IL_Add( ControlHandles , aImage [i] , "" , w , h , ImageCount )
      ENDIF
      IF PosImage == -1
         MsgMiniGuiError( "Image: " + aImage [i] + " is not added. Check image size." )
      ENDIF
   NEXT

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _AddImageToImageList ( ControlName, ParentControl, Image, MaskImage )
*-----------------------------------------------------------------------------*
   LOCAL w , h , c

   w := _GetControlWidth ( ControlName, ParentControl )
   h := _GetControlHeight ( ControlName, ParentControl )
   c := GetControlHandle ( ControlName, ParentControl )

RETURN IL_Add( c , image , hb_defaultValue( maskimage, "" ) , w , h )

*-----------------------------------------------------------------------------*
FUNCTION _AddImageMaskedToImageList ( ControlName, ParentControl, Image, aColor )
*-----------------------------------------------------------------------------*
   LOCAL w, h, c, color := 0

   w := _GetControlWidth ( ControlName, ParentControl )
   h := _GetControlHeight ( ControlName, ParentControl )
   c := GetControlHandle ( ControlName, ParentControl )
   IF IsArrayRGB ( aColor )
      color := RGB ( aColor [1], aColor [2], aColor [3] )
   ENDIF

RETURN IL_AddMasked( c , image , color , w , h )

*-----------------------------------------------------------------------------*
FUNCTION _ImageListSetBkColor ( ControlName, ParentControl, aColor )
*-----------------------------------------------------------------------------*
   LOCAL c, color := 0

   c := GetControlHandle ( ControlName, ParentControl )
   IF IsArrayRGB ( aColor )
      color := RGB ( aColor [1], aColor [2], aColor [3] )
   ENDIF

RETURN IL_SetBkColor( c, color )

*-----------------------------------------------------------------------------*
FUNCTION _EraseImage ( ControlName, ParentControl, ix, iy )
*-----------------------------------------------------------------------------*
   LOCAL w, h

   w := _GetControlWidth ( ControlName, ParentControl )
   h := _GetControlHeight ( ControlName, ParentControl )
   IL_EraseImage( GetFormHandle ( ParentControl ), ix, iy, w, h )

RETURN Nil

*-----------------------------------------------------------------------------*
FUNCTION _BeginDragImage ( ControlName, ParentControl, imageindex, ix, iy )
*-----------------------------------------------------------------------------*
   LOCAL c, h

   c := GetControlHandle ( ControlName, ParentControl )
   h := GetFormHandle ( ParentControl )
   _HMG_ActiveDragImageHandle := h
   IL_BeginDrag( h, c, ImageIndex, ix, iy )

RETURN Nil
