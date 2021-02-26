/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 Property Sheet control source code
 (C)2008 Janusz Pora <januszpora@onet.eu>

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
    Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
   www - http://harbour-project.org

   "Harbour Project"
   Copyright 1999-2012, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
     Copyright 2001-2009 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/


#include "minigui.ch"
#include "i_PropSheet.ch"

#define WM_CLOSE        16
#define WM_COMMAND      273
#define WM_DESTROY      2
#define WM_NOTIFY       78
#define BN_CLICKED       0
#define WM_INITDIALOG   272

#define IDOK                1
#define IDCANCEL            2
#define IDABORT             3
#define IDRETRY             4
#define IDIGNORE            5
#define IDYES               6
#define IDNO                7
#define IDCLOSE             8
#define IDHELP              9


#define PSH_DEFAULT             0x00000000
#define PSH_PROPTITLE           0x00000001
#define PSH_USEHICON            0x00000002
#define PSH_USEICONID           0x00000004
#define PSH_PROPSHEETPAGE       0x00000008
#define PSH_WIZARDHASFINISH     0x00000010
#define PSH_WIZARD              0x00000020
#define PSH_USEPSTARTPAGE       0x00000040
#define PSH_NOAPPLYNOW          0x00000080  // hide Apply button
#define PSH_USECALLBACK         0x00000100
#define PSH_HASHELP             0x00000200
#define PSH_MODELESS            0x00000400
#define PSH_RTLREADING          0x00000800
#define PSH_WIZARDCONTEXTHELP   0x00001000
#define PSH_WIZARD97            0x01000000
#define PSH_WATERMARK           0x00008000
#define PSH_USEHBMWATERMARK     0x00010000  // user pass in a hbmWatermark instead of pszbmWatermark
#define PSH_USEHPLWATERMARK     0x00020000  //
#define PSH_STRETCHWATERMARK    0x00040000  // stretchwatermark also applies for the header
#define PSH_HEADER              0x00080000
#define PSH_USEHBMHEADER        0x00100000
#define PSH_USEPAGELANG         0x00200000  // use frame dialog template matched to page
// ----------------------------------------

// ----- New flags for wizard-lite --------
#define PSH_WIZARD_LITE         0x00400000
#define PSH_NOCONTEXTHELP       0x02000000
// ----------------------------------------


#define PSP_DEFAULT                0x00000000
#define PSP_DLGINDIRECT            0x00000001
#define PSP_USEHICON               0x00000002
#define PSP_USEICONID              0x00000004
#define PSP_USETITLE               0x00000008
#define PSP_RTLREADING             0x00000010

#define PSP_HASHELP                0x00000020
#define PSP_USEREFPARENT           0x00000040
#define PSP_USECALLBACK            0x00000080
#define PSP_PREMATURE              0x00000400

#define PSP_HIDEHEADER             0x00000800
#define PSP_USEHEADERTITLE         0x00001000
#define PSP_USEHEADERSUBTITLE      0x00002000


#define PSCB_INITIALIZED  1
#define PSCB_PRECREATE    2
#define PSCB_BUTTONPRESSED 3

#define PSBTN_BACK              0
#define PSBTN_NEXT              1
#define PSBTN_FINISH            2
#define PSBTN_OK                3
#define PSBTN_APPLYNOW          4
#define PSBTN_CANCEL            5
#define PSBTN_HELP              6
#define PSBTN_MAX               6

#define PSWIZB_BACK             0x00000001
#define PSWIZB_NEXT             0x00000002
#define PSWIZB_FINISH           0x00000004
#define PSWIZB_DISABLEDFINISH   0x00000008

#define PSN_FIRST               -200


#define PSN_SETACTIVE           (PSN_FIRST-0)
#define PSN_KILLACTIVE          (PSN_FIRST-1)
#define PSN_APPLY               (PSN_FIRST-2)
#define PSN_RESET               (PSN_FIRST-3)
#define PSN_HELP                (PSN_FIRST-5)
#define PSN_WIZBACK             (PSN_FIRST-6)
#define PSN_WIZNEXT             (PSN_FIRST-7)
#define PSN_WIZFINISH           (PSN_FIRST-8)
#define PSN_QUERYCANCEL         (PSN_FIRST-9)
#define PSN_GETOBJECT           (PSN_FIRST-10)
#define PSN_TRANSLATEACCELERATOR (PSN_FIRST-12)
#define PSN_QUERYINITIALFOCUS   (PSN_FIRST-13)

#define DWL_MSGRESULT       0
#define DS_SETFONT          64   /* User specified font for Dlg controls */


MEMVAR mVar

MEMVAR _HMG_ActivePropSheetHandle, _HMG_ActivePropSheetModeless, _HMG_ActivePropSheetWizard
MEMVAR _HMG_InitPropSheetProcedure, _HMG_ApplyPropSheetProcedure, _HMG_CancelPropSheetProcedure
MEMVAR _HMG_ValidPropSheetProcedure, _HMG_PropSheetProcedure
MEMVAR _HMG_aPropSheetPagesTemp, _HMG_aPropSheetTemplate, _HMG_aPropSheetPages, _HMG_aPropSheetActivePages

STATIC aHwndSheetPages := {}
STATIC _HMG_PropSheetButton := 0

*------------------------------------------------------------------------------*
FUNCTION _BeginPropSheet(  FormName, ParentForm, row, col, width, height, caption, icon, fontname, fontsize,;
      dialogproc, initproc, applyproc, cancelproc, validproc, bold, italic, underline, strikeout, ;
      modal, wizard, watermark, headerbmp, lite )
*------------------------------------------------------------------------------*
   LOCAL aFont, FontHandle

   IF _HMG_BeginDialogActive = .T.
      MsgMiniGuiError( "DEFINE PROPERTY SHEET Structures can't be nested." )
   ENDIF

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      aFont := GetFontParam( FontHandle )
      FontName      := aFont[ 1 ]
      FontSize      := aFont[ 2 ]
      bold          := aFont[ 3 ]
      italic        := aFont[ 4 ]
      underline     := aFont[ 5 ]
      strikeout     := aFont[ 6 ]
   ENDIF

   IF _HMG_BeginWindowActive = .T.
      IF .NOT. Empty ( _HMG_ActiveFontName ) .AND. ValType( fontname ) == "U"
         fontname := _HMG_ActiveFontName
      ENDIF
      IF .NOT. Empty ( _HMG_ActiveFontSize ) .AND. ValType( fontsize ) == "U"
         fontsize := _HMG_ActiveFontSize
      ENDIF
   ENDIF

   IF ValType ( ParentForm ) == 'U'
      ParentForm := _HMG_ActiveFormName
   ENDIF

   _DefinePropSheet (  FormName, ParentForm, row, col, width, height, caption, icon, fontname, fontsize, dialogproc, initproc, applyproc, cancelproc, validproc, bold, italic, underline, strikeout, modal, wizard, watermark, headerbmp, lite )

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION _DefinePropSheet ( FormName, ParentForm,  y, x, w, h,  caption, IdIcon, fontname, fontsize, PropSheetProcedure, InitProcedure, ApplyProcedure, CancelProcedure, ValidProcedure,  bold, italic, underline, strikeout, modal, wizard, IdWaterMark, IdHeader, lite )
*------------------------------------------------------------------------------*
   LOCAL i, htooltip := NIL, mVar, k, modeless
   LOCAL FormHandle := Nil, ParentHandle, cWaterMark := "", cHeader := "", cIcon := "", Style := PSH_USECALLBACK + DS_SETFONT

   HB_SYMBOL_UNUSED( underline )
   HB_SYMBOL_UNUSED( strikeout )

   DEFAULT x       TO 0
   DEFAULT y       TO 0
   DEFAULT w       TO 0
   DEFAULT h       TO 0
   DEFAULT IdWaterMark TO 0
   DEFAULT IdHeader TO 0

   aHwndSheetPages := {}

   _HMG_aPropSheetTemplate := {}
   _HMG_aPropSheetPages    := {}
   _HMG_aPropSheetActivePages    := {}
   _HMG_InitPropSheetProcedure   := ""
   _HMG_ApplyPropSheetProcedure  := ""
   _HMG_CancelPropSheetProcedure := ""
   _HMG_ValidPropSheetProcedure  := ""
   _HMG_PropSheetProcedure       := ""
   _HMG_ActivePropSheetWizard    := .F.

   modeless := ( !modal .AND. !wizard )
   IF ValType( IdWaterMark ) == 'C'
      cWaterMark := IdWaterMark
      IdWaterMark := 0
   ENDIF
   IF ValType( IdHeader ) == 'C'
      cHeader := IdHeader
      IdHeader := 0
   ENDIF
   IF ValType( IdIcon ) == 'C'
      cIcon := IdIcon
      IdIcon := 0
      Style += PSP_USEHICON
   ELSE
      Style += PSH_USEICONID
   ENDIF

   IF ValType( FormName ) == "U"
      FormName := _HMG_TempWindowName
   ENDIF

   _HMG_ActivePropSheetModeless := modeless
   _HMG_ActivePropSheetWizard := wizard
   FormName := AllTrim( FormName )

   i := AScan ( _HMG_aFormType, 'A' )
   IF i <= 0
      MsgMiniGuiError( "Main Window Not Defined." )
   ENDIF

   IF _IsWindowDefined ( FormName )
      MsgMiniGuiError( "Property Sheet: " + FormName + " already defined." )
   ENDIF

   mVar := '_' + FormName

   ParentHandle = GetFormHandle ( ParentForm )

   IF !Empty( cWaterMark ) .OR. IdWatermark > 0
      Style += PSH_WATERMARK
   ENDIF
   IF !Empty( cHeader ) .OR. IdHeader > 0
      Style += PSH_HEADER
   ENDIF
   IF modeless
      Style +=  PSH_MODELESS
   ENDIF
   IF wizard
      IF lite
         Style += PSH_WIZARD_LITE
      ELSE
         Style += PSH_WIZARD97       // PSH_AEROWIZARD + PSH_WOZARD   // New style
      ENDIF
   ENDIF
   _HMG_aPropSheetTemplate  := { 0, ParentHandle, modal, style, 0, x, y, w, h, caption, fontname, fontsize, bold, Italic, IdWaterMark, cWaterMark, IdHeader, cHeader, IdIcon, cIcon }
   _HMG_aPropSheetPagesTemp := {}

   IF ValType( InitProcedure ) == "B"
      _HMG_InitPropSheetProcedure := InitProcedure
   ENDIF
   IF ValType( ApplyProcedure ) == "B"
      _HMG_ApplyPropSheetProcedure := ApplyProcedure
   ENDIF
   IF ValType( CancelProcedure ) == "B"
      _HMG_CancelPropSheetProcedure := CancelProcedure
   ENDIF
   IF ValType( ValidProcedure ) == "B"
      _HMG_ValidPropSheetProcedure := ValidProcedure
   ENDIF
   IF ValType( PropSheetProcedure ) == "B"
      _HMG_PropSheetProcedure := PropSheetProcedure
   ENDIF

   _HMG_ActivePropSheetHandle := 0

   IF !modeless
      RETURN NIL
   ENDIF

   IF ValType( FontName ) == "U"
      _HMG_ActiveFontName := ""
   ELSE
      _HMG_ActiveFontName := FontName
   ENDIF

   IF ValType( FontSize ) == "U"
      _HMG_ActiveFontSize := 0
   ELSE
      _HMG_ActiveFontSize := FontSize
   ENDIF

   k := AScan ( _HMG_aFormDeleted, .T. )

   IF k > 0

      Public &mVar. := k

      _HMG_aFormNames[ k ]              :=  FormName
      _HMG_aFormHandles[ k ]           :=  FormHandle
      _HMG_aFormActive[ k ]            :=  .T.
      _HMG_aFormType[ k ]              :=  'S'     // Proposition 'D' Windows type PropSheet
      _HMG_aFormParentHandle[ k ]      :=  ParentHandle
      _HMG_aFormReleaseProcedure[ k ]  :=  ApplyProcedure
      _HMG_aFormInitProcedure[ k ]     :=  InitProcedure
      _HMG_aFormToolTipHandle[ k ]     :=  htooltip
      _HMG_aFormContextMenuHandle[ k ] :=  0
      _HMG_aFormMouseDragProcedure[ k ] :=  ""
      _HMG_aFormSizeProcedure[ k ]     :=  ""
      _HMG_aFormClickProcedure[ k ]    :=  PropSheetProcedure
      _HMG_aFormMouseMoveProcedure[ k ] :=  ""
      _HMG_aFormMoveProcedure[ k ]     :=  ""
      _HMG_aFormDropProcedure[ k ]     :=  ""
      _HMG_aFormDeleted[ k ]           := .F.
      _HMG_aFormBkColor[ k ]           := { -1, -1, -1 }
      _HMG_aFormPaintProcedure[ k ]     :=   ""
      _HMG_aFormNoShow[ k ]            :=  .F.
      _HMG_aFormNotifyIconName[ k ]    :=  ""
      _HMG_aFormNotifyIconToolTip[ k ]  := ""
      _HMG_aFormNotifyIconLeftClick[ k ] := ""
      _HMG_aFormNotifyIconDblClick[ k ] := ""
      _HMG_aFormGotFocusProcedure[ k ] := ""
      _HMG_aFormLostFocusProcedure[ k ] := ValidProcedure
      _HMG_aFormReBarHandle[ k ]     :=  0
      _HMG_aFormNotifyMenuHandle[ k ]  := 0
      _HMG_aFormBrowseList[ k ]      :=  {}
      _HMG_aFormSplitChildList[ k ]    := {}
      _HMG_aFormVirtualHeight[ k ]   :=  0
      _HMG_aFormVirtualWidth[ k ]    :=  0
      _HMG_aFormFocused[ k ]         :=  .F.
      _HMG_aFormScrollUp[ k ]        :=  ""
      _HMG_aFormScrollDown[ k ]      :=  ""
      _HMG_aFormScrollLeft[ k ]      :=  ""
      _HMG_aFormScrollRight[ k ]     :=  ""
      _HMG_aFormHScrollBox[ k ]     := ""
      _HMG_aFormVScrollBox[ k ]     := ""
      _HMG_aFormBrushHandle[ k ]    := 0
      _HMG_aFormFocusedControl[ k ]    := 0
      _HMG_aFormGraphTasks[ k ]     := {}
      _HMG_aFormMaximizeProcedure[ k ]  :=  Nil
      _HMG_aFormMinimizeProcedure[ k ]  :=  Nil
      _HMG_aFormRestoreProcedure[ k ]   :=  CancelProcedure
      _HMG_aFormAutoRelease[ k ]        :=  .F.
      _HMG_aFormInteractiveCloseProcedure[ k ] :=  ""
      _HMG_aFormMinMaxInfo[ k ]         := {}
      _HMG_aFormActivateId[ k ]         := 0
      _HMG_aFormMiscData1 [ k ]         := {}   
      _HMG_aFormMiscData2 [ k ]         := '' 

   ELSE

      k := Len( _HMG_aFormNames ) + 1

      Public &mVar. := k

      AAdd ( _HMG_aFormNames, FormName )
      AAdd ( _HMG_aFormHandles, FormHandle )
      AAdd ( _HMG_aFormActive, .T. )
      AAdd ( _HMG_aFormType, 'S'  )    // Windows type PropSheet
      AAdd ( _HMG_aFormParentHandle, ParentHandle )
      AAdd ( _HMG_aFormReleaseProcedure, ApplyProcedure )
      AAdd ( _HMG_aFormInitProcedure, InitProcedure )
      AAdd ( _HMG_aFormToolTipHandle, htooltip )
      AAdd ( _HMG_aFormContextMenuHandle, 0 )
      AAdd ( _HMG_aFormMouseDragProcedure, "" )
      AAdd ( _HMG_aFormSizeProcedure, "" )
      AAdd ( _HMG_aFormClickProcedure, PropSheetProcedure )
      AAdd ( _HMG_aFormMouseMoveProcedure, "" )
      AAdd ( _HMG_aFormMoveProcedure, "" )
      AAdd ( _HMG_aFormDropProcedure, "" )
      AAdd ( _HMG_aFormDeleted, .F. )
      AAdd ( _HMG_aFormBkColor, { -1, -1, -1 } )
      AAdd ( _HMG_aFormPaintProcedure, "" )
      AAdd ( _HMG_aFormNoShow, .F. )
      AAdd ( _HMG_aFormNotifyIconName, ""    )
      AAdd ( _HMG_aFormNotifyIconToolTip, ""    )
      AAdd ( _HMG_aFormNotifyIconLeftClick, ""    )
      AAdd ( _HMG_aFormNotifyIconDblClick, ""    )
      AAdd ( _HMG_aFormGotFocusProcedure, "" )
      AAdd ( _HMG_aFormLostFocusProcedure, ValidProcedure )
      AAdd ( _HMG_aFormReBarHandle, 0 )
      AAdd ( _HMG_aFormNotifyMenuHandle, 0 )
      AAdd ( _HMG_aFormBrowseList, {} )
      AAdd ( _HMG_aFormSplitChildList, {} )
      AAdd ( _HMG_aFormVirtualHeight, 0 )
      AAdd ( _HMG_aFormVirtualWidth, 0 )
      AAdd ( _HMG_aFormFocused, .F. )
      AAdd ( _HMG_aFormScrollUp, "" )
      AAdd ( _HMG_aFormScrollDown, "" )
      AAdd ( _HMG_aFormScrollLeft, "" )
      AAdd ( _HMG_aFormScrollRight, "" )
      AAdd ( _HMG_aFormHScrollBox, "" )
      AAdd ( _HMG_aFormVScrollBox, "" )
      AAdd ( _HMG_aFormBrushHandle, 0 )
      AAdd ( _HMG_aFormFocusedControl, 0 )
      AAdd ( _HMG_aFormGraphTasks, {} )
      AAdd ( _HMG_aFormMaximizeProcedure, "" )
      AAdd ( _HMG_aFormMinimizeProcedure, "" )
      AAdd ( _HMG_aFormRestoreProcedure, CancelProcedure )
      AAdd ( _HMG_aFormAutoRelease, .F. )
      AAdd ( _HMG_aFormInteractiveCloseProcedure, "" )
      AAdd ( _HMG_aFormMinMaxInfo, {} )
      AAdd ( _HMG_aFormActivateId, 0 )
      AAdd ( _HMG_aFormMiscData1, {} )
      AAdd ( _HMG_aFormMiscData2, '' )
   ENDIF

   IF Len( _HMG_aPropSheetTemplate ) > 0
      _HMG_aPropSheetTemplate[ 1 ]  := &mVar.
   ENDIF

RETURN ( FormHandle )

*------------------------------------------------------------------------------*
FUNCTION _DefineSheetPage ( DialogName, Id, cTitle, HdTitle, SubHdTitle, HideHeader )
*------------------------------------------------------------------------------*
   LOCAL style := PSP_USETITLE
   DEFAULT Id := 0, SubHdTitle := ""
   IF Id == 0
      MsgMiniGuiError( "PROPERTY SHEET Structures only from Resourses." )
   ENDIF
   IF _IsWindowDefined ( DialogName )
      MsgMiniGuiError( "Dialog: " + DialogName + " already defined." )
   ENDIF

   _HMG_ActiveDialogHandle    := 0
   _HMG_ActiveDialogName      := DialogName
   _HMG_BeginDialogActive     := .T.
   _HMG_DialogInMemory        := .F.
   _HMG_aDialogTemplate       := _HMG_aPropSheetTemplate

   IF HideHeader
      Style += PSP_HIDEHEADER
   ENDIF
   IF !Empty( HdTitle )
      Style += PSP_USEHEADERTITLE
   ENDIF
   IF !Empty( SubHdTitle )
      Style += PSP_USEHEADERSUBTITLE
   ENDIF

   _HMG_aPropSheetPagesTemp   := { cTitle, Id, Style, HdTitle, SubHdTitle }
   _HMG_ActiveDialogHandle    := CreatePropertySeeetPage( _HMG_aPropSheetPagesTemp )

   AAdd( aHwndSheetPages, _HMG_ActiveDialogHandle  )
   AAdd( _HMG_aPropSheetPages, { DialogName, Id, _HMG_ActiveDialogHandle, 0, _HMG_DialogInMemory, .F. }  )

   _HMG_ActiveDialogHandle       := 0
   _HMG_ActiveDialogName         := ""
   _HMG_BeginDialogActive        := .F.

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION _BeginSheetPage ( DialogName, Id, cTitle, HdTitle, SubHdTitle, HideHeader )
*------------------------------------------------------------------------------*
   LOCAL Style := PSP_USETITLE
   DEFAULT Id := 0, SubHdTitle := ""

   _HMG_ActiveDialogHandle    := 0
   _HMG_ActiveDialogName      := DialogName
   _HMG_BeginDialogActive     := .T.
   _HMG_DialogInMemory        := .T.
   _HMG_aDialogItems          := {}
   _HMG_aDialogTemplate       := _HMG_aPropSheetTemplate

   IF _IsWindowDefined ( DialogName )
      MsgMiniGuiError( "Dialog: " + DialogName + " already defined." )
   ENDIF

   AAdd( _HMG_aPropSheetPages, { DialogName, Id, 0, 0, _HMG_DialogInMemory, .F. }  )
   IF HideHeader
      Style += PSP_HIDEHEADER
   ENDIF
   IF !Empty( HdTitle )
      Style += PSP_USEHEADERTITLE
   ENDIF
   IF !Empty( SubHdTitle )
      Style += PSP_USEHEADERSUBTITLE
   ENDIF

   _HMG_aPropSheetPagesTemp := { cTitle, Id, Style, HdTitle, SubHdTitle }

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION _EndSheetPage()
*------------------------------------------------------------------------------*
   IF _HMG_BeginDialogActive
      _HMG_ActiveDialogHandle := CreatePropSeeetPageIndirect( _HMG_aPropSheetPagesTemp, _HMG_aPropSheetTemplate, _HMG_aDialogItems )
      AAdd( aHwndSheetPages, _HMG_ActiveDialogHandle  )
      _HMG_aPropSheetPages[ Len( _HMG_aPropSheetPages ), 2 ] := _HMG_aPropSheetPagesTemp[ 2 ]
      _HMG_aPropSheetPages[ Len( _HMG_aPropSheetPages ), 3 ] := _HMG_ActiveDialogHandle
      _HMG_aPropSheetPages[ Len( _HMG_aPropSheetPages ), 4 ] := _HMG_aDialogItems
      _HMG_aPropSheetPages[ Len( _HMG_aPropSheetPages ), 6 ] := .F.
   ENDIF
   _HMG_ActiveDialogHandle       := 0
   _HMG_ActiveDialogName         := ""
   _HMG_BeginDialogActive        := .F.
   _HMG_DialogInMemory           := .F.

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION _EndPropSheet()
*------------------------------------------------------------------------------*
   LOCAL Formhandle, k
   Formhandle := CreatePropertySheet( _HMG_ActivePropSheetHandle, aHwndSheetPages, ;
      _HMG_aPropSheetTemplate, _HMG_ActivePropSheetModeless )

   IF _HMG_ActivePropSheetModeless .AND.  Formhandle > 0

      k := _HMG_aPropSheetTemplate[ 1 ]

      _HMG_ActivePropSheetHandle    := Formhandle
      _HMG_aFormHandles[k ]        :=  FormHandle
      _HMG_aFormToolTipHandle[k ]  :=  InitToolTip( FormHandle )
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION _DefineSheetDialog ( FormName, Id_resource, FormHandle, hWndParent  )
*------------------------------------------------------------------------------*
   LOCAL mVar, k

   HB_SYMBOL_UNUSED( Id_resource )

   mVar := '_' + FormName
   IF _HMG_DialogInMemory
      _HMG_aDialogItems := {}
   ENDIF

   k := AScan ( _HMG_aFormDeleted, .T. )

   IF k > 0

      Public &mVar. := k

      _HMG_aFormNames[k ] := FormName
      _HMG_aFormHandles[k ] :=  FormHandle
      _HMG_aFormActive[k ] :=  .T.
      _HMG_aFormType[k ] :=  'S'     // Proposition 'D' Windows type Dialog
      _HMG_aFormParentHandle[k ] :=  hWndParent
      _HMG_aFormReleaseProcedure[k ] :=  ""
      _HMG_aFormInitProcedure[k ] :=  ""
      _HMG_aFormToolTipHandle[k ] :=  0
      _HMG_aFormContextMenuHandle[k ] :=  0
      _HMG_aFormMouseDragProcedure[k ] :=  ""
      _HMG_aFormSizeProcedure[k ] :=  ""
      _HMG_aFormClickProcedure[k ] :=  ""
      _HMG_aFormMouseMoveProcedure[k ] :=  ""
      _HMG_aFormMoveProcedure[k ] :=  ""
      _HMG_aFormDropProcedure[k ] :=  ""
      _HMG_aFormDeleted[k ] := .F.
      _HMG_aFormBkColor[k ] := { -1, -1, -1 }
      _HMG_aFormPaintProcedure[k ] :=   ""
      _HMG_aFormNoShow[k ] :=  .F.
      _HMG_aFormNotifyIconName[k ] :=  ""
      _HMG_aFormNotifyIconToolTip[k ] := ""
      _HMG_aFormNotifyIconLeftClick[k ] := ""
      _HMG_aFormNotifyIconDblClick[k ] := ""
      _HMG_aFormGotFocusProcedure[k ] := ""
      _HMG_aFormLostFocusProcedure[k ] := ""
      _HMG_aFormReBarHandle[k ] :=  0
      _HMG_aFormNotifyMenuHandle[k ] := 0
      _HMG_aFormBrowseList[k ] :=  {}
      _HMG_aFormSplitChildList[k ] := {}
      _HMG_aFormVirtualHeight[k ] :=  0
      _HMG_aFormVirtualWidth[k ] :=  0
      _HMG_aFormFocused[k ] :=  .F.
      _HMG_aFormScrollUp[k ] :=  ""
      _HMG_aFormScrollDown[k ] :=  ""
      _HMG_aFormScrollLeft[k ] :=  ""
      _HMG_aFormScrollRight[k ] :=  ""
      _HMG_aFormHScrollBox[k ] := ""
      _HMG_aFormVScrollBox[k ] := ""
      _HMG_aFormBrushHandle[k ] := 0
      _HMG_aFormFocusedControl[k ] := 0
      _HMG_aFormGraphTasks[k ] := {}
      _HMG_aFormMaximizeProcedure[k ] :=  Nil
      _HMG_aFormMinimizeProcedure[k ] :=  Nil
      _HMG_aFormRestoreProcedure[k ] :=  Nil
      _HMG_aFormAutoRelease[k ] :=  .F.
      _HMG_aFormInteractiveCloseProcedure[k ] :=  ""
      _HMG_aFormMinMaxInfo[k ] := {}
      _HMG_aFormActivateId[k ] := 0
      _HMG_aFormMiscData1  [k] := {}   
      _HMG_aFormMiscData2  [k] := '' 

   ELSE

      k := Len( _HMG_aFormNames ) + 1

      Public &mVar. := k

      AAdd ( _HMG_aFormNames, FormName )
      AAdd ( _HMG_aFormHandles, FormHandle )
      AAdd ( _HMG_aFormActive, .T. )
      AAdd ( _HMG_aFormType, 'S'  )    // Windows type Dialog
      AAdd ( _HMG_aFormParentHandle, hWndParent )
      AAdd ( _HMG_aFormReleaseProcedure, "" )
      AAdd ( _HMG_aFormInitProcedure, "" )
      AAdd ( _HMG_aFormToolTipHandle, 0 )
      AAdd ( _HMG_aFormContextMenuHandle, 0 )
      AAdd ( _HMG_aFormMouseDragProcedure, "" )
      AAdd ( _HMG_aFormSizeProcedure, "" )
      AAdd ( _HMG_aFormClickProcedure, "" )
      AAdd ( _HMG_aFormMouseMoveProcedure, "" )
      AAdd ( _HMG_aFormMoveProcedure, "" )
      AAdd ( _HMG_aFormDropProcedure, "" )
      AAdd ( _HMG_aFormDeleted, .F. )
      AAdd ( _HMG_aFormBkColor, { -1, -1, -1 } )
      AAdd ( _HMG_aFormPaintProcedure, "" )
      AAdd ( _HMG_aFormNoShow, .F. )
      AAdd ( _HMG_aFormNotifyIconName, ""    )
      AAdd ( _HMG_aFormNotifyIconToolTip, ""    )
      AAdd ( _HMG_aFormNotifyIconLeftClick, ""    )
      AAdd ( _HMG_aFormNotifyIconDblClick, ""    )
      AAdd ( _HMG_aFormGotFocusProcedure, "" )
      AAdd ( _HMG_aFormLostFocusProcedure, "" )
      AAdd ( _HMG_aFormReBarHandle, 0 )
      AAdd ( _HMG_aFormNotifyMenuHandle, 0 )
      AAdd ( _HMG_aFormBrowseList, {} )
      AAdd ( _HMG_aFormSplitChildList, {} )
      AAdd ( _HMG_aFormVirtualHeight, 0 )
      AAdd ( _HMG_aFormVirtualWidth, 0 )
      AAdd ( _HMG_aFormFocused, .F. )
      AAdd ( _HMG_aFormScrollUp, "" )
      AAdd ( _HMG_aFormScrollDown, "" )
      AAdd ( _HMG_aFormScrollLeft, "" )
      AAdd ( _HMG_aFormScrollRight, "" )
      AAdd ( _HMG_aFormHScrollBox, "" )
      AAdd ( _HMG_aFormVScrollBox, "" )
      AAdd ( _HMG_aFormBrushHandle, 0 )
      AAdd ( _HMG_aFormFocusedControl, 0 )
      AAdd ( _HMG_aFormGraphTasks, {} )
      AAdd ( _HMG_aFormMaximizeProcedure, "" )
      AAdd ( _HMG_aFormMinimizeProcedure, "" )
      AAdd ( _HMG_aFormRestoreProcedure, Nil )
      AAdd ( _HMG_aFormAutoRelease, .F. )
      AAdd ( _HMG_aFormInteractiveCloseProcedure, "" )
      AAdd ( _HMG_aFormMinMaxInfo, {} )
      AAdd ( _HMG_aFormActivateId, 0 )
      AAdd ( _HMG_aFormMiscData1, {} )
      AAdd ( _HMG_aFormMiscData2, '' )
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION InitPageDlgProc( hwndDlg, idDlg, hWndParent )
*------------------------------------------------------------------------------*
   LOCAL i, n, aDialogItems, k_old, nId, k, blInit
   LOCAL FontHandle, ControlHandle
   _HMG_ActiveDialogHandle     := hwndDlg
   _HMG_BeginDialogActive      := .T.
   _HMG_ActiveDlgProcHandle    := hwndDlg
   _HMG_ActiveDlgProcId        := idDlg

   i := AScan (  _HMG_aPropSheetActivePages,  hwndDlg )
   IF i == 0
      AAdd( _HMG_aPropSheetActivePages, hwndDlg )
   ENDIF
   i := AScan (  _HMG_aPropSheetPages, {| x| x[ 2 ] == idDlg } )
   IF i > 0
      _HMG_ActiveDialogName   := _HMG_aPropSheetPages[i, 1 ]
      aDialogItems            := _HMG_aPropSheetPages[i, 4 ]
      _HMG_DialogInMemory     := _HMG_aPropSheetPages[i, 5 ]
      _HMG_aPropSheetPages[i, 3 ] :=  hwndDlg
   ENDIF
   _DefineSheetDialog ( _HMG_ActiveDialogName,  IdDlg, hwndDlg, hWndParent  )
   IF _HMG_DialogInMemory .AND. ValType( aDialogItems ) == 'A'
      k_old := 0
      FOR n := 1 TO Len( aDialogItems )
         nId     := aDialogItems[ n, 1 ]
         k       := aDialogItems[ n, 2 ]
         blInit  := aDialogItems[ n, 19 ]
         ControlHandle := GetDialogItemHandle( _HMG_ActiveDialogHandle, nId )
         FontHandle    := GetFontHandle( aDialogItems[ n, 13 ] )
         IF FontHandle != 0
            _SetFontHandle ( ControlHandle, FontHandle )
         ELSEIF IsWindowHandle( ControlHandle )
            IF ValType( aDialogItems[ n, 13 ] ) != "U" .AND. ValType( aDialogItems[ n, 14 ] ) != "U"
               FontHandle := _SetFont ( ControlHandle, aDialogItems[ n, 13 ], aDialogItems[ n, 14 ], aDialogItems[ n, 15 ], aDialogItems[ n, 16 ], aDialogItems[ n, 17 ], aDialogItems[ n, 18 ] )
            ELSE
               FontHandle := _SetFont ( ControlHandle, _HMG_DefaultFontName, _HMG_DefaultFontSize, aDialogItems[ n, 15 ], aDialogItems[ n, 16 ], aDialogItems[ n, 17 ], aDialogItems[ n, 18 ] )
            ENDIF
         ENDIF
         IF _HMG_ActivePropSheetModeless
            IF ValType( aDialogItems[ n, 12 ] ) != "U" .AND. IsWindowHandle( GetFormToolTipHandle ( _HMG_ActiveDialogName ) )
               SetToolTip ( ControlHandle, aDialogItems[ n, 12 ], GetFormToolTipHandle ( _HMG_ActiveDialogName ) )
            ENDIF
            IF  k > 0
               IF k_old != k
                  IF ValType( _HMG_aControlHandles[ k ] ) != "A"
                     _HMG_aControlHandles[ k ] :=  ControlHandle
                  ELSE
                     _HMG_aControlHandles[ k ] :=  {}
                     AAdd ( _HMG_aControlHandles[ k ], ControlHandle )
                  ENDIF
               ELSE
                  AAdd ( _HMG_aControlHandles[ k ], ControlHandle )
               ENDIF
               _HMG_aControlParentHandles[ k ] :=  _HMG_ActiveDialogHandle
               k_old := k
            ENDIF
         ENDIF
         IF ValType( blInit ) == "B"  .AND. _HMG_aControlDeleted[k ] != .T.
            Eval( blInit, _HMG_ActiveDialogName, ControlHandle, k )
         ENDIF
      NEXT
   ENDIF

   IF ValType( _HMG_InitPropSheetProcedure ) == 'B'
      Eval( _HMG_InitPropSheetProcedure,  hwndDlg, idDlg )
   ENDIF

   _HMG_ActiveDialogHandle     := 0
   _HMG_BeginDialogActive      := .F.
   _HMG_ActiveDlgProcHandle    := 0
   _HMG_ActiveDlgProcId        := 0

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION ButtonPageDlgProc( hwndDlg, Msg, IdDlg, nPage )
*------------------------------------------------------------------------------*
   LOCAL i, lRet := TRUE, lChd := .F.
   _HMG_ActiveDialogHandle     := hwndDlg
   _HMG_BeginDialogActive      := .T.
   _HMG_ActiveDlgProcHandle    := hwndDlg
   _HMG_ActiveDlgProcId        := IdDlg
   IF IdDlg == 0
      i := nPage + 1
      IdDlg  :=  _HMG_aPropSheetPages[i, 2 ]
   ELSE
      i := AScan ( _HMG_aPropSheetPages, {| x| x[ 2 ] == IdDlg } )
   ENDIF
   IF i > 0
      _HMG_ActiveDialogName := _HMG_aPropSheetPages[i, 1 ]
      lChd := _HMG_aPropSheetPages[i, 6 ]
   ENDIF
   DO CASE
   CASE Msg == PSN_APPLY

      IF ValType( _HMG_ApplyPropSheetProcedure ) == 'B' .AND. lChd
         lRet := RetValue( Eval( _HMG_ApplyPropSheetProcedure, hwndDlg, idDlg, nPage ), lRet )
      ENDIF

   CASE Msg == PSN_RESET

      IF ! _HMG_ActivePropSheetWizard
         IF ValType( _HMG_CancelPropSheetProcedure ) == 'B' .AND. lChd
            lRet := RetValue( Eval( _HMG_CancelPropSheetProcedure, hwndDlg, idDlg, nPage ), lRet )
         ELSE
            lRet := FALSE
         ENDIF
      ENDIF

   CASE Msg == PSN_QUERYCANCEL

      IF _HMG_ActivePropSheetWizard
         IF ValType( _HMG_CancelPropSheetProcedure ) != 'B'
            lRet := MsgYesNo ( 'Are you sure you want to Quit?', GetWindowText ( GetActiveWindow() ) )
         ELSE
            lRet := RetValue( Eval( _HMG_CancelPropSheetProcedure,  hwndDlg, idDlg, nPage ), lRet )
         ENDIF
      ENDIF

   CASE Msg == PSN_KILLACTIVE

      IF ValType( _HMG_ValidPropSheetProcedure ) == 'B'
         lRet := RetValue( Eval( _HMG_ValidPropSheetProcedure, hwndDlg, idDlg, nPage ), lRet )
      ENDIF

   ENDCASE

   _HMG_ActiveDialogHandle     := 0
   _HMG_BeginDialogActive      := .F.
   _HMG_ActiveDlgProcHandle    := 0
   _HMG_ActiveDlgProcId        := 0

RETURN IF( lRet, 1, 0 )

*------------------------------------------------------------------------------*
FUNCTION PropSheetProc( hwndPropSheet, nMsg, lParam )
*------------------------------------------------------------------------------*
   LOCAL lRet := TRUE, k

   DO CASE
   CASE nMsg == PSCB_INITIALIZED
      k := _HMG_aPropSheetTemplate[ 1 ]
      IF k > 0
         _HMG_aFormhandles[ k ] := hwndPropSheet
      ENDIF
   CASE nMsg ==  PSCB_BUTTONPRESSED
      DO CASE
      CASE lParam ==  PSBTN_OK
      CASE lParam ==  PSBTN_CANCEL
      CASE lParam ==  PSBTN_APPLYNOW
      CASE lParam ==  PSBTN_HELP
      CASE lParam ==  PSBTN_BACK
      CASE lParam ==  PSBTN_NEXT
      CASE lParam ==  PSBTN_FINISH
      ENDCASE
      _HMG_PropSheetButton := lParam
   ENDCASE

RETURN IF( lRet, 1, 0 )

*------------------------------------------------------------------------------*
FUNCTION PageDlgProc( hwndParent, hwndDlg, nMsg, wParam, lParam )
*------------------------------------------------------------------------------*
   LOCAL lRet := FALSE, i, nPage, nPageMode, NotifyCode, hwndActive, ControlHandle
   _HMG_ActiveDlgProcHandle    := hwndDlg
   _HMG_ActiveDlgProcMsg       := nMsg
   _HMG_ActiveDlgProcId        := wParam
   _HMG_ActiveDlgProcNotify    := lParam
   _HMG_ActiveDlgProcModal     := .F.

   DO CASE
   CASE nMsg == WM_DESTROY
      _ReleasePropertySheet( hwndParent, hwndDlg )
   CASE nMsg == WM_COMMAND
      nPage := PropSheetHwndToIndex( hwndParent, hwndDlg )
      i := AScan ( _HMG_aFormhandles, hwndParent )  // find PropSheetProcedure
      IF i > 0
         IF ValType( _HMG_aFormClickProcedure[i ] ) == 'B' .AND. _HMG_aFormType[i ] == 'S'
            IF ( lRet := RetValue( Eval( _HMG_aFormClickProcedure[i ], hwndDlg, nMsg, LOWORD( wParam ), HIWORD( wParam ) ), lRet ) )
               PropSheet_Changed( hWndParent, hWndDlg )
               IF nPage > -1 .AND. nPage + 1 <= Len( _HMG_aPropSheetPages )
                  _HMG_aPropSheetPages[ nPage + 1, 6 ] := .T.
               ENDIF
            ENDIF
         ELSE
            ControlHandle := GetDialogITemHandle( hwndDlg, LOWORD( wParam ) )
            Events( hwndDlg, nMsg, wParam, ControlHandle )
            lRet := TRUE
         ENDIF
      ELSE
         IF ValType( _HMG_PropSheetProcedure ) == 'B'
            IF ( lRet := RetValue( Eval(  _HMG_PropSheetProcedure, hwndDlg, nMsg, LOWORD( wParam ), HIWORD( wParam ) ), lRet ) )
               PropSheet_Changed( hWndParent, hWndDlg )
               IF nPage > -1 .AND. nPage + 1 <= Len( _HMG_aPropSheetPages )
                  _HMG_aPropSheetPages[ nPage + 1, 6 ] := .T.
               ENDIF
            ENDIF
         ELSE
            ControlHandle := GetDialogITemHandle( hwndDlg, LOWORD( wParam ) )
            Events( hwndDlg, nMsg, wParam, ControlHandle )
            lRet := TRUE
         ENDIF
      ENDIF
      IF lRet == FALSE
         ControlHandle := GetDialogITemHandle( hwndDlg, LOWORD( wParam ) )
         Events( hwndDlg, nMsg, wParam, ControlHandle )
         lRet := TRUE
      ENDIF

   CASE nMsg == WM_NOTIFY

      nPage := PropSheetHwndToIndex( hwndParent, hwndDlg )
      NotifyCode := GetNotifyCode( lParam )
      switch  NotifyCode
      CASE PSN_APPLY   // sent when OK or Apply button pressed
         IF nPage + 1 <= Len( _HMG_aPropSheetPages )
            _HMG_aPropSheetPages[ nPage + 1, 6 ] := .F.
         ENDIF
         PropSheet_UnChanged( hWndParent, hWndDlg )
         EXIT
      CASE PSN_RESET   // sent when Cancel button pressed

         i := AScan ( _HMG_aPropSheetActivePages,  hwndDlg )
         IF i > 0
            ADel( _HMG_aPropSheetActivePages, i )
            ASize( _HMG_aPropSheetActivePages, Len( _HMG_aPropSheetActivePages ) -1 )
         ENDIF
         hwndActive := PropSheetGetCurrentPageHwnd( hwndParent )
         IF _HMG_ActivePropSheetModeless
            IF hwndActive == 0
               _ReleasePropertySheet( hwndParent, hwndDlg )
            ENDIF
            IF Len( _HMG_aPropSheetActivePages ) == 0
               _ReleasePropertySheet( hwndParent, hwndDlg )
            ENDIF
         ELSE
            IF hwndActive == hWndDlg  .AND. !_HMG_ActivePropSheetWizard
               _ReleasePropertySheet( hwndParent, hwndDlg )
            ENDIF
         ENDIF
         EXIT
      CASE PSN_SETACTIVE

         nPageMode := IF( nPage == Len( _HMG_aPropSheetPages ) -1, 2, IF( nPage == 0, 0, 1 ) )
         PropSheetSetWizButtons( hWndParent, nPageMode )       // this will be ignored if the property sheet is not a wizard
         EXIT
      CASE PSN_KILLACTIVE
         EXIT
      CASE PSN_QUERYCANCEL
         EXIT
      CASE -211
         IF nPage == 0 .AND.  _HMG_ActivePropSheetModeless  .AND. _HMG_PropSheetButton == PSBTN_OK
            _ReleasePropertySheet( hwndParent, hwndDlg )
         ENDIF
      END
   OTHERWISE
      ControlHandle := GetDialogITemHandle( hwndDlg, LOWORD( wParam ) )
      Events( hwndDlg, nMsg, wParam, ControlHandle )
      lRet := TRUE                                                         // end
   ENDCASE

   _HMG_ActiveDlgProcHandle    := 0
   _HMG_ActiveDlgProcMsg       := 0
   _HMG_ActiveDlgProcId        := 0
   _HMG_ActiveDlgProcNotify    := 0

RETURN  lRet

*------------------------------------------------------------------------------*
FUNCTION PropSheet_Chd( hWndParent, hWndDlg )
*------------------------------------------------------------------------------*
   LOCAL  i := AScan ( _HMG_aPropSheetPages, {| x| x[ 3 ] == hWndDlg } )
   IF i > 0
      _HMG_aPropSheetPages[ i, 6 ] := .T.
   ENDIF
   PropSheet_Changed( hWndParent, hWndDlg )

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION RetValue( lRet, def )
*------------------------------------------------------------------------------*
   IF lRet == NIL .OR. ValType( lRet ) != 'L'
      IF ValType( lRet ) == "N"
         lRet := if( lRet == 0, FALSE, TRUE )
      ELSE
         lRet := def
      ENDIF
   ENDIF

RETURN lRet

*------------------------------------------------------------------------------*
FUNCTION _ReleasePropertySheet( hwndPropSheet, hWndDlg )
*------------------------------------------------------------------------------*
   LOCAL n
   FOR n := 1 TO Len( _HMG_aFormParentHandle )
      IF _HMG_aFormParentHandle[n ] == hwndPropSheet
         EraseDialog( _HMG_aFormHandles[n ] )
      ENDIF
   NEXT
   IF _HMG_ActivePropSheetModeless
      ErasePropSheet( hwndPropSheet )
      DestroyWindow( hwndPropSheet )
   ELSE
      EndDialog( hwndDlg, 0 )
   ENDIF

RETURN NIL

*------------------------------------------------------------------------------*
STATIC FUNCTION ErasePropSheet( hWnd )
*------------------------------------------------------------------------------*
   LOCAL i

   i := AScan ( _HMG_aFormhandles, hWnd )
   IF i > 0

      mVar := '_' + _HMG_aFormNames[i ]
      IF Type ( mVar ) != 'U'
#ifdef _ZEROPUBLIC_
         __mvPut ( mVar, 0 )
#else
         __mvXRelease( mVar )
#endif
      ENDIF

      _HMG_aFormDeleted[i ]   := .T.
      _HMG_aFormhandles[i ]   := 0
      _HMG_aFormNames[i ]   := ""
      _HMG_aFormActive[i ]   := .F.
      _HMG_aFormType[i ]   := ""
      _HMG_aFormParenthandle[i ]   := 0
      _HMG_aFormInitProcedure[i ]   := ""
      _HMG_aFormReleaseProcedure[i ]   := ""
      _HMG_aFormToolTipHandle[i ]   := 0
      _HMG_aFormContextMenuHandle[i ]   := 0
      _HMG_aFormMouseDragProcedure[i ]   := ""
      _HMG_aFormSizeProcedure[i ]   := ""
      _HMG_aFormClickProcedure[i ]   := ""
      _HMG_aFormMouseMoveProcedure[i ]   := ""
      _HMG_aFormMoveProcedure[i ]   := ""
      _HMG_aFormDropProcedure[i ]   := ""
      _HMG_aFormBkColor[i ]   := Nil
      _HMG_aFormPaintProcedure[i ]   := ""
      _HMG_aFormNoShow[i ]   := .F.
      _HMG_aFormNotifyIconName[i ]   := ''
      _HMG_aFormNotifyIconToolTip[i ]   := ''
      _HMG_aFormNotifyIconLeftClick[i ]   := ''
      _HMG_aFormNotifyIconDblClick[i ]   := ''
      _HMG_aFormReBarHandle[i ]   := 0
      _HMG_aFormNotifyMenuHandle[i ]   := 0
      _HMG_aFormBrowseList[i ]   := {}
      _HMG_aFormSplitChildList[i ]   := {}
      _HMG_aFormVirtualHeight[i ]   := 0
      _HMG_aFormGotFocusProcedure[i ]   := ""
      _HMG_aFormLostFocusProcedure[i ]   := ""
      _HMG_aFormVirtualWidth[i ]   := 0
      _HMG_aFormFocused[i ]   := .F.
      _HMG_aFormScrollUp[i ]   := ""
      _HMG_aFormScrollDown[i ]   := ""
      _HMG_aFormScrollLeft[i ]   := ""
      _HMG_aFormScrollRight[i ]   := ""
      _HMG_aFormHScrollBox[i ]   := ""
      _HMG_aFormVScrollBox[i ]   := ""
      _HMG_aFormBrushHandle[i ]   := 0
      _HMG_aFormFocusedControl[i ]   := 0
      _HMG_aFormGraphTasks[i ]   := {}
      _HMG_aFormMaximizeProcedure[i ]   := Nil
      _HMG_aFormMinimizeProcedure[i ]   := Nil
      _HMG_aFormRestoreProcedure[i ]   := Nil
      _HMG_aFormAutoRelease[i ]   := .F.
      _HMG_aFormInteractiveCloseProcedure[i ] := ""
      _HMG_aFormMinMaxInfo[i ]   := {}
      _HMG_aFormActivateId[i ]   := 0
      _HMG_aFormMiscData1  [ i ] := {}
      _HMG_aFormMiscData2  [ i ] := ''

      _HMG_InteractiveCloseStarted := .F.

   ENDIF

RETURN NIL
