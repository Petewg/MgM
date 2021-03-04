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
 Copyright 1999-2021, https://harbour.github.io/

 "WHAT32"
 Copyright 2002 AJ Wos <andrwos@aust1.net>

 "HWGUI"
   Copyright 2001-2018 Alexander S.Kresin <alex@kresin.ru>

 ---------------------------------------------------------------------------*/

// Initialize g_hInstance on C-level
REQUEST GETINSTANCE

#include "SET_COMPILE_HMG_UNICODE.ch"

#include "minigui.ch"
#include "i_winuser.ch"

STATIC _HMG_SYSINIT

*------------------------------------------------------------------------------*
PROCEDURE Init
*------------------------------------------------------------------------------*
   LOCAL nCellForeColor := GetSysColor ( COLOR_HIGHLIGHTTEXT )
   LOCAL nCellBackColor := GetSysColor ( COLOR_HIGHLIGHT )

   PUBLIC _HMG_SYSDATA [ _HMG_SYSDATA_SIZE ]

   _HMG_SYSINIT := { Date(), Time() }
//JP Drag Image
   _HMG_ActiveDragImageHandle := 0
//JP MDI
   _HMG_MainClientMDIHandle := 0
   _HMG_MainClientMDIName  := ""
   _HMG_ActiveMDIChildIndex := 0
   _HMG_BeginWindowMDIActive := .F.
   _HMG_MdiChildActive  := .F.
   _HMG_ActiveStatusHandle  := 0
// (JK) HMG 1.0 Experimental Build 6
   _HMG_ErrorLogFile := ""
   _HMG_CreateErrorlog := .T.

   _HMG_AutoScroll  := .T.
   _HMG_AutoAdjust  := .F.
   _HMG_AutoZooming := .F.

   _HMG_GlobalHotkeys := .F.
   _HMG_ProgrammaticChange := .T.
   _HMG_ListBoxDragNotification := 0

   _hmg_UserWindowHandle := 0
   _hmg_activemodalhandle := 0

   _HMG_InplaceParentHandle := 0
   _HMG_DefaultStatusBarMessage := 0
   _HMG_ActiveToolBarFormName := ''

   _HMG_IsXP := os_isWinXP()
   _HMG_IsXPorLater := IsWinXPorLater ()
   _HMG_IsThemed := IsThemed ()

   _HMG_LANG_ID := ''

   _HMG_aLangButton    := {}
   _HMG_aLangLabel     := {}
   _HMG_aLangUser      := {}

   _HMG_aABMLangUser   := {}
   _HMG_aABMLangLabel  := {}
   _HMG_aABMLangButton := {}
   _HMG_aABMLangError  := {}

   _HMG_MESSAGE := Array ( 12 )
   _HMG_RPTDATA := Array ( 165 )

   _HMG_SetFocusExecuted := .F.

   _HMG_InteractiveCloseStarted := .F.
   _HMG_aEventInfo := {}

   _HMG_aUserBlocks := Array ( 7 )
   _HMG_lOOPEnabled := .F.
#ifdef _OBJECT_
   _HMG_bOnFormInit       := {|nIndex, cVar  | Do_OnWndInit   ( nIndex, cVar ) }
   _HMG_bOnFormDestroy    := {|nIndex        | Do_OnWndRelease( nIndex ) }
   _HMG_bOnControlInit    := {|nIndex, cVar  | Do_OnCtlInit   ( nIndex, cVar ) }
   _HMG_bOnControlDestroy := {|nIndex        | Do_OnCtlRelease( nIndex ) }
   _HMG_bOnWndLaunch      := {|hWnd, nMsg, wParam, lParam| Do_OnWndLaunch( hWnd, nMsg, wParam, lParam ) }
   _HMG_bOnCtlLaunch      := {|hWnd, nMsg, wParam, lParam| Do_OnCtlLaunch( hWnd, nMsg, wParam, lParam ) }
#endif
   _HMG_DateTextBoxActive := .F.

   _HMG_ThisFormName := Nil
   _HMG_ThisControlName := Nil

   _HMG_aBrowseSyncStatus := Array ( 2 )
   _HMG_BrowseSyncStatus := .F.
   _HMG_BrowseUpdateStatus := .F.

   _HMG_ActiveTabBold := Nil
   _HMG_ActiveTabItalic := Nil
   _HMG_ActiveTabUnderline := Nil
   _HMG_ActiveTabStrikeout := Nil
   _HMG_ActiveTabImages := Nil

   _HMG_ThisFormIndex := 0

   _HMG_InteractiveClose := 1

   _HMG_ThisEventType := ''

   _HMG_ExtendedNavigation := .F.

   _HMG_xContextMenuButtonIndex := 0

   _HMG_IPE_COL := 1
   _HMG_IPE_ROW := 1

   _HMG_IPE_CANCELLED := .F.
   _HMG_GridNavigationMode := .F.

   _HMG_GridSelectedRowForeColor := { 0 , 0 , 0 }
   _HMG_GridSelectedRowBackColor := { 220 , 220 , 220 }
   _HMG_GridSelectedCellForeColor := nRGB2Arr ( nCellForeColor )
   _HMG_GridSelectedCellBackColor := nRGB2Arr ( nCellBackColor )

   _HMG_DialogCancelled  := .F.
   _HMG_ActiveSplitBoxInverted := .F.

   _HMG_BRWLangButton  := {}
   _HMG_BRWLangError  := {}
   _HMG_BRWLangMessage  := {}

   _HMG_ThisItemRowIndex  := 0
   _HMG_ThisItemColIndex  := 0
   _HMG_ThisItemCellRow  := 0
   _HMG_ThisItemCellCol  := 0
   _HMG_ThisItemCellWidth  := 0
   _HMG_ThisItemCellHeight  := 0
   _HMG_ThisItemCellValue  := Nil

   _HMG_ThisQueryData  := ""
   _HMG_ThisQueryRowIndex  := 0
   _HMG_ThisQueryColIndex  := 0

   _HMG_ThisType    := ''
   _HMG_ThisIndex    := 0
   _HMG_ShowContextMenus  := .T.
   _HMG_lMultiple   := .T.
   _HMG_IsMultiple   := Nil

   _HMG_DefaultIconName  := Nil
   _HMG_DefaultFontName  := _GetSysFont ()
   _HMG_DefaultFontSize  := Max( 9, GetDefaultFontSize () )

   _HMG_TempWindowName := ""

   _HMG_ActiveTabMultiline  := .F.

   _HMG_ActiveIniFile  := ""
   _HMG_ActiveHelpFile := ""
   _HMG_nTopic := 0
   _HMG_nMet   := 0

   _HMG_StatusItemCount := 0
   _HMG_ActiveMessageBarName := ""

   _HMG_ActiveSplitChildIndex := 0

   _HMG_xMenuType := ''
   _HMG_xMainMenuHandle := 0
   _HMG_xMainMenuParentHandle := 0
   _HMG_xMenuPopupLevel := 0
   _HMG_xMenuPopuphandle := Array ( 255 )
   _HMG_xMenuPopupCaption := Array ( 255 )
   _HMG_xMainMenuParentName := ""

   _HMG_xContextMenuHandle := 0
   _HMG_xContextMenuParentHandle := 0
   _HMG_xContextPopupLevel := 0
   _HMG_xContextPopuphandle := Array ( 255 )
   _HMG_xContextPopupCaption := Array ( 255 )
   _HMG_xContextMenuParentName := ""

   _HMG_aControlsContextMenu := {}
   _HMG_xControlsContextMenuID := 0

   _HMG_ActiveTreeValue := 0
   _HMG_ActiveTreeItemIds := .F.

   _HMG_ActiveTreeIndex := 0

   _HMG_ActiveTreeHandle := 0
   _HMG_NodeHandle := Array ( 255 )
   _HMG_NodeIndex := Nil
   _HMG_aTreeMap := {}
   _HMG_aTreeIdMap := {}

   _HMG_ActiveToolBarCaption := ''

   _HMG_SplitChildActive   := .F.

   _HMG_ToolBarActive      := .F.
   _HMG_ActiveToolBarExtend := .F.

   _HMG_ActiveFormNameBak  := ""

   _HMG_SplitLastControl   := ""

   _HMG_ActiveControlDef   := .F.
   _HMG_ActiveToolBarBreak := .F.
   _HMG_ActiveSplitBox     := .F.

   _HMG_ActiveSplitBoxParentFormName := ""

   _HMG_NotifyBalloonClick := ""

   _HMG_ActiveToolBarName := ""

   _HMG_MainWindowFirst := .T.
   _HMG_MainActive      := .F.
   _HMG_MainCargo	:= hmg_Version()
   _HMG_MainHandle      := 0

   _HMG_MouseRow        := 0
   _HMG_MouseCol        := 0
   _HMG_MouseState      := 0

   _HMG_ActiveFormName  := ""
   _HMG_BeginWindowActive := .F.

   _HMG_ActiveFontName  := ""
   _HMG_ActiveFontSize  := 0

   _HMG_FrameLevel      := 0
   _HMG_ActiveFrameParentFormName := Array ( 128 )
   _HMG_ActiveFrameRow  := Array ( 128 )
   _HMG_ActiveFrameCol  := Array ( 128 )

   _HMG_ActiveDialogName   := ""
   _HMG_ActiveDialogHandle := 0
   _HMG_BeginDialogActive  := .F.
   _HMG_ModalDialogProcedure := ""
   _HMG_DialogProcedure    := ""
   _HMG_ModalDialogReturn  := 0
   _HMG_InitDialogProcedure := ""
   _HMG_ActiveTabnId    := 0
   _HMG_aDialogTemplate := {}
   _HMG_aDialogItems    := {}
   _HMG_DialogInMemory  := .F.
   _HMG_aDialogTreeItem := {}

   _HMG_ActiveDlgProcHandle  := 0
   _HMG_ActiveDlgProcMsg     := 0
   _HMG_ActiveDlgProcId      := 0
   _HMG_ActiveDlgProcNotify  := 0
   _HMG_ActiveDlgProcModal   := .F.

   _HMG_FldID := 0
   _HMG_aFolderInfo := {}

   _HMG_BeginPagerActive     := .F.
   _HMG_ActivePagerForm      := 0

#ifdef _TSBROWSE_
   _HMG_ActiveTBrowseName    := ""
   _HMG_ActiveTBrowseHandle  := 0
   _HMG_BeginTBrowseActive   := .F.
#endif
#ifdef _PROPGRID_
   _HMG_ActivePropGridHandle := 0
   _HMG_ActiveCategoryHandle := 0
   _HMG_ActivePropGridIndex  := 0
   _HMG_ActivePropGridArray  := {}
   _HMG_PGLangButton         := {}
   _HMG_PGLangError          := {}
   _HMG_PGLangMessage        := {}
#endif
   _HMG_BeginTabActive := .F.
   _HMG_ActiveTabPage  := 0
   _HMG_ActiveTabFullPageMap := {}
   _HMG_ActiveTabCaptions  := {}
   _HMG_ActiveTabCurrentPageMap := {}
   _HMG_ActiveTabName  := ""
   _HMG_ActiveTabParentFormName := ""
   _HMG_ActiveTabRow   := 0
   _HMG_ActiveTabCol   := 0
   _HMG_ActiveTabWidth := 0
   _HMG_ActiveTabHeight := 0
   _HMG_ActiveTabValue := 0
   _HMG_ActiveTabFontName := ""
   _HMG_ActiveTabFontSize := 0
   _HMG_ActiveTabToolTip  := ""
   _HMG_ActiveTabChangeProcedure := Nil
   _HMG_ActiveTabButtons  := .F.
   _HMG_ActiveTabFlat  := .F.
   _HMG_ActiveTabHotTrack := .F.
   _HMG_ActiveTabVertical := .F.
   _HMG_ActiveTabNoTabStop := .F.
   _HMG_ActiveTabMnemonic  := ""

   _HMG_IsModalActive := .F.

   _HMG_aScrollStep := { 0, 20 }
   _HMG_aFormDeleted  := {}
   _HMG_aFormNames    := {}
   _HMG_aFormHandles  := {}
   _HMG_aFormActive   := {}
   _HMG_aFormType     := {}
   _HMG_aFormParentHandle   := {}
   _HMG_aFormReleaseProcedure := {}
   _HMG_aFormInitProcedure  := {}
   _HMG_aFormToolTipHandle  := {}
   _HMG_aFormContextMenuHandle := {}
   _HMG_aFormMouseDragProcedure := {}
   _HMG_aFormSizeProcedure  := {}
   _HMG_aFormClickProcedure := {}
   _HMG_aFormMouseMoveProcedure := {}
   _HMG_aFormMoveProcedure  := {}
   _HMG_aFormDropProcedure  := {}
   _HMG_aFormBkColor  := {}
   _HMG_aFormPaintProcedure := {}
   _HMG_aFormNoShow  := {}
   _HMG_aFormNotifyIconName := {}
   _HMG_aFormNotifyIconToolTip := {}
   _HMG_aFormNotifyIconLeftClick := {}
   _HMG_aFormNotifyIconDblClick := {}
   _HMG_aFormGotFocusProcedure := {}
   _HMG_aFormLostFocusProcedure := {}
   _HMG_aFormReBarHandle  := {}
   _HMG_aFormNotifyMenuHandle := {}
   _HMG_aFormBrowseList  := {}
   _HMG_aFormSplitChildList := {}
   _HMG_aFormVirtualHeight  := {}
   _HMG_aFormVirtualWidth  := {}
   _HMG_aFormFocused  := {}
   _HMG_aFormScrollUp  := {}
   _HMG_aFormScrollDown  := {}
   _HMG_aFormScrollLeft  := {}
   _HMG_aFormScrollRight  := {}
   _HMG_aFormHScrollBox  := {}
   _HMG_aFormVScrollBox  := {}
   _HMG_aFormBrushHandle  := {}
   _HMG_aFormFocusedControl := {}
   _HMG_aFormGraphTasks  := {}
   _HMG_aFormMaximizeProcedure := {}
   _HMG_aFormMinimizeProcedure := {}
   _HMG_aFormRestoreProcedure := {}
   _HMG_aFormAutoRelease  := {}
   _HMG_aFormInteractiveCloseProcedure := {}
   _HMG_aFormMinMaxInfo  := {}
   _HMG_aFormActivateId  := {}
   _HMG_aFormMiscData1   := {}   
   _HMG_aFormMiscData2   := {} 

   _HMG_aControlDeleted  := {}
   _HMG_aControlType  := {}
   _HMG_aControlNames  := {}
   _HMG_aControlHandles  := {}
   _HMG_aControlParenthandles := {}
   _HMG_aControlIds  := {}
   _HMG_aControlProcedures  := {}
   _HMG_aControlPageMap  := {}
   _HMG_aControlValue  := {}
   _HMG_aControlInputMask  := {}
   _HMG_aControllostFocusProcedure := {}
   _HMG_aControlGotFocusProcedure := {}
   _HMG_aControlChangeProcedure := {}
   _HMG_aControlBkColor  := {}
   _HMG_aControlFontColor  := {}
   _HMG_aControlDblClick  := {}
   _HMG_aControlHeadClick  := {}
   _HMG_aControlRow  := {}
   _HMG_aControlCol  := {}
   _HMG_aControlWidth  := {}
   _HMG_aControlHeight  := {}
   _HMG_aControlSpacing  := {}
   _HMG_aControlContainerRow := {}
   _HMG_aControlContainerCol := {}
   _HMG_aControlPicture  := {}
   _HMG_aControlContainerHandle := {}
   _HMG_aControlFontName  := {}
   _HMG_aControlFontSize  := {}
   _HMG_aControlToolTip  := {}
   _HMG_aControlRangeMin  := {}
   _HMG_aControlRangeMax  := {}
   _HMG_aControlCaption  := {}
   _HMG_aControlVisible  := {}
   _HMG_aControlHelpId  := {}
   _HMG_aControlFontHandle  := {}
   _HMG_aControlFontAttributes := {}
   _HMG_aControlBrushHandle := {}
   _HMG_aControlEnabled  := {}
   _HMG_aControlMiscData1  := {}
   _HMG_aControlMiscData2  := {}

   _HMG_ListBoxDragNotification := _GetDDLMessage()
   _HMG_FindReplaceOptions := Array ( 6 )
   _HMG_CharRange_Min := 0
   _HMG_CharRange_Max := 0
   _HMG_MsgIDFindDlg := RegisterFindMsgString()

#ifdef _USERINIT_
   _HMG_aCustomEventProcedure := {}
   _HMG_aCustomPropertyProcedure := {}
   _HMG_aCustomMethodProcedure := {}
   _HMG_UserComponentProcess := .F.
#endif

   _HMG_ParentWindowActive  := .F.

#ifdef _PANEL_
   _HMG_LoadWindowRow  := -1
   _HMG_LoadWindowCol  := -1
   _HMG_LoadWindowWidth  := -1
   _HMG_LoadWindowHeight  := -1
#endif
#ifdef _HMG_COMPAT_
   _HMG_StopWindowEventProcedure := {}
   _HMG_StopControlEventProcedure := {}
   _HMG_LastActiveFormIndex := 0
   _HMG_LastActiveControlIndex := 0
#endif

#if ! defined( __XHARBOUR__ ) && ( ( __HARBOUR__ - 0 ) > 0x030100 )
#ifdef UNICODE
   Set ( _SET_CODEPAGE, "UTF8" )
#else
   InitCodePage()
#endif
#endif

   InitMessages()

   ResetGlobalListener() // set default Events function

   _HMG_IsMultiple := IsExeRunning ( StrTran( GetExeFileName (), '\', '_' ) )
   _SetErrorLogFile( _GetErrorLogFile() )

RETURN

*------------------------------------------------------------------------------*
FUNCTION TimeFromStart
*------------------------------------------------------------------------------*
   LOCAL aData
   LOCAL cText := ""
   LOCAL n

   aData := _hmg_Elapsed( _HMG_SYSINIT [1], Date(), _HMG_SYSINIT [2], Time() )
   FOR n := 1 TO 4
      cText += hb_ntos( aData[ n ] ) + " "
      cText += iif( n == 1, "days ", iif( n == 2, "hours ", iif( n == 3, "mins ", "secs" ) ) )
   NEXT

RETURN cText

*------------------------------------------------------------------------------*
STATIC FUNCTION _hmg_Elapsed( dStart, dEnd, cTimeStart, cTimeEnd )
*------------------------------------------------------------------------------*
   LOCAL aRetVal [4]
   LOCAL nTotalSec, nCtr, nConstant
   LOCAL nTemp

   nTotalSec := ( dEnd - dStart ) * 86400 + ;
      Val( cTimeEnd ) *  3600 + ;
      Val( SubStr( cTimeEnd, At( ":", cTimeEnd ) + 1, 2 ) ) * 60 + ;
      iif( RAt( ":", cTimeEnd ) == At( ":", cTimeEnd ), 0, ;
      Val( SubStr( cTimeEnd, RAt( ":", cTimeEnd ) + 1 ) ) ) - ;
      Val( cTimeStart ) * 3600 - ;
      Val( SubStr( cTimeStart, At( ":", cTimeStart ) + 1, 2 ) ) * 60 - ;
      iif( RAt( ":", cTimeStart ) == At( ":", cTimeStart ), 0, ;
      Val( SubStr( cTimeStart, RAt( ":", cTimeStart ) + 1 ) ) )

   nTemp := nTotalSec

   FOR nCtr := 1 TO 4
      nConstant := iif( nCtr == 1, 86400, iif( nCtr == 2, 3600, iif( nCtr == 3, 60, 1 ) ) )
      aRetVal[ nCtr ] := Int( nTemp / nConstant )
      nTemp -= aRetVal[ nCtr ] * nConstant
   NEXT

RETURN aRetVal

#if ! defined( __XHARBOUR__ ) && ( ( __HARBOUR__ - 0 ) > 0x030100 )
#ifndef UNICODE
*------------------------------------------------------------------------------*
STATIC PROCEDURE InitCodePage
*------------------------------------------------------------------------------*
   LOCAL cLang

   IF Empty( cLang := hb_UserLang() )

      SET CODEPAGE TO ENGLISH

   ELSE

      DO CASE

      CASE "es" $ cLang
         SET CODEPAGE TO SPANISH

      CASE "pt" $ cLang
         SET CODEPAGE TO PORTUGUESE

      CASE "de" $ cLang
         SET CODEPAGE TO GERMAN

      CASE "el" $ cLang
         SET CODEPAGE TO GREEK

      CASE "ru" $ cLang
         SET CODEPAGE TO RUSSIAN

      CASE "uk" $ cLang
         SET CODEPAGE TO UKRAINIAN

      CASE "pl" $ cLang
         SET CODEPAGE TO POLISH

      CASE "sl" $ cLang
         SET CODEPAGE TO SLOVENIAN

      CASE "sr" $ cLang
         SET CODEPAGE TO SERBIAN

      CASE "bg" $ cLang
         SET CODEPAGE TO BULGARIAN

      CASE "hu" $ cLang
         SET CODEPAGE TO HUNGARIAN

      CASE "cs" $ cLang
         SET CODEPAGE TO CZECH

      CASE "sk" $ cLang
         SET CODEPAGE TO SLOVAK

      CASE "nl" $ cLang
         SET CODEPAGE TO DUTCH

      CASE "fi" $ cLang
         SET CODEPAGE TO FINNISH

      CASE "sv" $ cLang
         SET CODEPAGE TO SWEDISH

      ENDCASE

   ENDIF

RETURN

#endif
#endif
*------------------------------------------------------------------------------*
FUNCTION _GetSysFont()
*------------------------------------------------------------------------------*

   IF _HMG_IsXPorLater
      RETURN GetDefaultFontName()
   ENDIF

RETURN "MS Sans Serif"  // Win NT, 9x

*------------------------------------------------------------------------------*
PROCEDURE InitMessages
*------------------------------------------------------------------------------*
#ifdef _MULTILINGUAL_
   LOCAL cLang
#endif

   // MISC MESSAGES (ENGLISH DEFAULT)

   _HMG_MESSAGE [1] := 'Are you sure ?'
   _HMG_MESSAGE [2] := 'Close Window'
   _HMG_MESSAGE [3] := 'Close not allowed'
   _HMG_MESSAGE [4] := 'Program Already Running'
   _HMG_MESSAGE [5] := 'Edit'
   _HMG_MESSAGE [6] := 'Ok'
   _HMG_MESSAGE [7] := 'Cancel'
   _HMG_MESSAGE [8] := 'Apply'
   _HMG_MESSAGE [9] := 'Pag.'
   _HMG_MESSAGE [10] := 'Attention'
   _HMG_MESSAGE [11] := 'Information'
   _HMG_MESSAGE [12] := 'Stop'

   // BROWSE MESSAGES (ENGLISH DEFAULT)

   _HMG_BRWLangButton := { ;
      "Append"  , ;
      "Edit"    , ;
      "&Cancel" , ;
      "&OK" }
   _HMG_BRWLangError  := { ;
      "Window: "                                              , ;
      " is not defined. Program terminated"                   , ;
      "MiniGUI Error"                                         , ;
      "Control: "                                             , ;
      " Of "                                                  , ;
      " Already defined. Program terminated"                  , ;
      "Browse: Type Not Allowed. Program terminated"          , ;
      "Browse: Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea.", ;
      "Record Is Being Edited By Another User"                , ;
      "Warning"                                               , ;
      "Invalid Entry" }
   _HMG_BRWLangMessage := { 'Are you sure ?' , 'Delete Record' }

   // EDIT MESSAGES (ENGLISH DEFAULT)

   _HMG_aABMLangUser   := { ;
      Chr( 13 ) + "Delete record" + Chr( 13 ) + "Are you sure ?" + Chr( 13 )            , ;
      Chr( 13 ) + "Index file missing" + Chr( 13 ) + "Can`t do search" + Chr( 13 )      , ;
      Chr( 13 ) + "Can`t find index field" + Chr( 13 ) + "Can`t do search" + Chr( 13 )  , ;
      Chr( 13 ) + "Can't do search by" + Chr( 13 ) + "fields memo or logic" + Chr( 13 ) , ;
      Chr( 13 ) + "Record not found" + Chr( 13 )                                        , ;
      Chr( 13 ) + "To many cols" + Chr( 13 ) + "The report can't fit in the sheet" + Chr( 13 ) }

   _HMG_aABMLangLabel := {    ;
      "Record"              , ;
      "Record count"        , ;
      "       (New)"        , ;
      "      (Edit)"        , ;
      "Enter record number" , ;
      "Find"                , ;
      "Search text"         , ;
      "Search date"         , ;
      "Search number"       , ;
      "Report definition"   , ;
      "Report columns"      , ;
      "Available columns"   , ;
      "Initial record"      , ;
      "Final record"        , ;
      "Report of "          , ;
      "Date:"               , ;
      "Initial record:"     , ;
      "Final record:"       , ;
      "Ordered by:"         , ;
      "Yes"                 , ;
      "No"                  , ;
      "Page "               , ;
      " of " }

   _HMG_aABMLangButton := { ;
      "Close"    , ;
      "New"      , ;
      "Edit"     , ;
      "Delete"   , ;
      "Find"     , ;
      "Goto"     , ;
      "Report"   , ;
      "First"    , ;
      "Previous" , ;
      "Next"     , ;
      "Last"     , ;
      "Save"     , ;
      "Cancel"   , ;
      "Add"      , ;
      "Remove"   , ;
      "Print"    , ;
      "Close" }
   _HMG_aABMLangError := { ;
      "EDIT, workarea name missing"                              , ;
      "EDIT, this workarea has more than 16 fields"              , ;
      "EDIT, refresh mode out of range (please report bug)"      , ;
      "EDIT, main event number out of range (please report bug)" , ;
      "EDIT, list event number out of range (please report bug)" }

   // EDIT EXTENDED (ENGLISH DEFAULT)

   _HMG_aLangButton := {    ;
      "&Close",             ; // 1
      "&New",               ; // 2
      "&Modify",            ; // 3
      "&Delete",            ; // 4
      "&Find",              ; // 5
      "&Print",             ; // 6
      "&Cancel",            ; // 7
      "&Ok",                ; // 8
      "&Copy",              ; // 9
      "&Activate Filter",   ; // 10
      "&Deactivate Filter", ; // 11
      "&Restore"            } // 12
   _HMG_aLangLabel := { ;
      "None",                       ; // 1
      "Record",                     ; // 2
      "Total",                      ; // 3
      "Active order",               ; // 4
      "Options",                    ; // 5
      "New record",                 ; // 6
      "Modify record",              ; // 7
      "Select record",              ; // 8
      "Find record",                ; // 9
      "Print options",              ; // 10
      "Available fields",           ; // 11
      "Fields to print",            ; // 12
      "Available printers",         ; // 13
      "First record to print",      ; // 14
      "Last record to print",       ; // 15
      "Delete record",              ; // 16
      "Preview",                    ; // 17
      "View page thumbnails",       ; // 18
      "Filter Condition: ",         ; // 19
      "Filtered: ",                 ; // 20
      "Filtering Options" ,         ; // 21
      "Database Fields" ,           ; // 22
      "Comparison Operator",        ; // 23
      "Filter Value",               ; // 24
      "Select Field To Filter",     ; // 25
      "Select Comparison Operator", ; // 26
      "Equal",                      ; // 27
      "Not Equal",                  ; // 28
      "Greater Than",               ; // 29
      "Lower Than",                 ; // 30
      "Greater or Equal Than",      ; // 31
      "Lower or Equal Than"         } // 32
   _HMG_aLangUser := { ;
      CRLF + "Can't find an active area.   "  + CRLF + "Please select any area before call EDIT   " + CRLF,       ; // 1
      "Type the field value (any text)",                                                                          ; // 2
      "Type the field value (any number)",                                                                        ; // 3
      "Select the date",                                                                                          ; // 4
      "Check for true value",                                                                                     ; // 5
      "Enter the field value",                                                                                    ; // 6
      "Select any record and press OK",                                                                           ; // 7
      CRLF + "You are going to delete the active record   " + CRLF + "Are you sure?    " + CRLF,                  ; // 8
      CRLF + "There isn't any active order   " + CRLF + "Please select one   " + CRLF,                            ; // 9
      CRLF + "Can't do searches by fields memo or logic   " + CRLF,                                               ; // 10
      CRLF + "Record not found   " + CRLF,                                                                        ; // 11
      "Select the field to include to list",                                                                      ; // 12
      "Select the field to exclude from list",                                                                    ; // 13
      "Select the printer",                                                                                       ; // 14
      "Push button to include field",                                                                             ; // 15
      "Push button to exclude field",                                                                             ; // 16
      "Push button to select the first record to print",                                                          ; // 17
      "Push button to select the last record to print",                                                           ; // 18
      CRLF + "No more fields to include   " + CRLF,                                                               ; // 19
      CRLF + "First select the field to include   " + CRLF,                                                       ; // 20
      CRLF + "No more fields to exlude   " + CRLF,                                                                ; // 21
      CRLF + "First select th field to exclude   " + CRLF,                                                        ; // 22
      CRLF + "You don't select any field   " + CRLF + "Please select the fields to include on print   " + CRLF,   ; // 23
      CRLF + "Too many fields   " + CRLF + "Reduce number of fields   " + CRLF,                                   ; // 24
      CRLF + "Printer not ready   " + CRLF,                                                                       ; // 25
      "Ordered by",                                                                                               ; // 26
      "From record",                                                                                              ; // 27
      "To record",                                                                                                ; // 28
      "Yes",                                                                                                      ; // 29
      "No",                                                                                                       ; // 30
      "Page:",                                                                                                    ; // 31
      CRLF + "Please select a printer   " + CRLF,                                                                 ; // 32
      "Filtered by",                                                                                              ; // 33
      CRLF + "There is an active filter    " + CRLF,                                                              ; // 34
      CRLF + "Can't filter by memo fields    " + CRLF,                                                            ; // 35
      CRLF + "Select the field to filter    " + CRLF,                                                             ; // 36
      CRLF + "Select any operator to filter    " + CRLF,                                                          ; // 37
      CRLF + "Type any value to filter    " + CRLF,                                                               ; // 38
      CRLF + "There isn't any active filter    " + CRLF,                                                          ; // 39
      CRLF + "Deactivate filter?   " + CRLF,                                                                      ; // 40
      CRLF + "Record locked by another user    " + CRLF,                                                          ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF                 } // 42

#ifdef _MULTILINGUAL_

   IF _HMG_LANG_ID == 'FI'  // FINNISH - Language Is Not Supported By hb_langSelect() Function
      cLang := 'FI'
   ELSE
      cLang := Upper( Left( Set ( _SET_LANGUAGE ), 2 ) )
   ENDIF

   DO CASE

   CASE cLang == "CS"  // Czech
      /////////////////////////////////////////////////////////////
      // CZECH
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Jste si jist(a)?'
      _HMG_MESSAGE [2] := 'Zav�i okno'
      _HMG_MESSAGE [3] := 'Uzav�en� zak�z�no'
      _HMG_MESSAGE [4] := 'Program u� b��'
      _HMG_MESSAGE [5] := '�prava'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Storno'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Str.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "Append"  , ;
         "Edit"    , ;
         "&Cancel"  , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Okno: "                                              , ;
         " nen� definov�no. Program ukon�en"                   , ;
         "MiniGUI Error"                                         , ;
         "Prvek: "                                             , ;
         " z "                                                  , ;
         " u� definov�n. Program ukon�en"                  , ;
         "Browse: Typ nepovolen. Program ukon�en"          , ;
         "Browse: Append fr�zi nelze pou��t s poli nepat��c�mi do Browse pracovn� oblasti. Program ukon�en", ;
         "Z�znam edituje jin� u�ivatel"                , ;
         "Varov�n�"                                              , ;
         "Chybn� vstup"                                          }
      _HMG_BRWLangMessage := { 'Jste si jist(a)?' , 'Smazat z�znam' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Smazat z�znam" + Chr( 13 ) + "Jste si jist(a)?" + Chr( 13 ) , ;
         Chr( 13 ) + "Chyb� indexov� soubor" + Chr( 13 ) + "Nemohu hledat" + Chr( 13 )            , ;
         Chr( 13 ) + "Nemohu naj�t indexovan� pole" + Chr( 13 ) + "Nemohu hledat" + Chr( 13 )        , ;
         Chr( 13 ) + "Nemohu hledat podle" + Chr( 13 ) + "pole memo nebo logick�" + Chr( 13 )       , ;
         Chr( 13 ) + "Z�znam nenalezen" + Chr( 13 )                                        , ;
         Chr( 13 ) + "P��li� mnoho sloupc�" + Chr( 13 ) + "Sestava se nevejde na plochu" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Z�znam"      , ;
         "Po�et z�znam�"         , ;
         "      (Nov�)"          , ;
         "     (�prava)"         , ;
         "Zadejte ��slo z�znamu" , ;
         "Hledej"                , ;
         "Hledan� text"          , ;
         "Hledan� datum"         , ;
         "Hledan� ��slo"         , ;
         "Definice sestavy"      , ;
         "Sloupce sestavy"       , ;
         "Dostupn� sloupce"      , ;
         "Prvn� z�znam"          , ;
         "Posledn� z�znam"       , ;
         "Sestava "              , ;
         "Datum:"                , ;
         "Prvn� z�znam:"         , ;
         "Posledn� z�znam:"      , ;
         "T��d�no dle:"          , ;
         "Ano"                   , ;
         "Ne"                    , ;
         "Strana "               , ;
         " z "                   }

      _HMG_aABMLangButton := { "Zav��t"    , ;
         "Nov�"      , ;
         "�prava"    , ;
         "Sma�"      , ;
         "Najdi"     , ;
         "Jdi"       , ;
         "Sestava"   , ;
         "Prvn�"     , ;
         "P�edchoz�" , ;
         "Dal��"     , ;
         "Posledn�"  , ;
         "Ulo�"      , ;
         "Storno"    , ;
         "P�idej"    , ;
         "Odstra�"   , ;
         "Tisk"      , ;
         "Zav�i"     }
      _HMG_aABMLangError  := { "EDIT, chyb� jm�no pracovn� oblasti" , ;
         "EDIT, pracovn� oblast m� v�c jak 16 pol�"              , ;
         "EDIT, refresh mode mimo rozsah (pros�m, nahlaste chybu)"      , ;
         "EDIT, hlavn� event ��slo mimo rozsah (pros�m, nahlaste chybu)" , ;
         "EDIT, list event ��slomimo rozsah (pros�m, nahlaste chybu)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Zav�i",            ; // 1
      "&Nov�",             ; // 2
      "�&prava",           ; // 3
      "S&ma�  ",           ; // 4
      "Na&jdi",            ; // 5
      "&Tisk",             ; // 6
      "&Storno",           ; // 7
      "&Ok",               ; // 8
      "&Kop�ruj",          ; // 9
      "Aktivuj &filtr",    ; // 10
      "&Vypni filtr",      ; // 11
      "&Restore"           } // 12
      _HMG_aLangLabel := {            ;
         "��dn�",                        ; // 1
      "Z�znam",                       ; // 2
      "Suma",                         ; // 3
      "Aktivn� t��d�n�",              ; // 4
      "Volby",                        ; // 5
      "Nov� z�znam",                  ; // 6
      "Uprav z�znam",                 ; // 7
      "Vyber z�znam",                 ; // 8
      "Najdi z�znam",                 ; // 9
      "Tiskni volby",                 ; // 10
      "Dostupn� pole",                ; // 11
      "Pole k tisku",                 ; // 12
      "Dostupn� tisk�rny",            ; // 13
      "Prvn� z�znam k tisku",         ; // 14
      "Posledn� z�znam k tisku",      ; // 15
      "Sma� z�znam",                  ; // 16
      "N�hled",                       ; // 17
      "Zobraz miniatury stran",       ; // 18
      "Filtr: ",                      ; // 19
      "Filtrov�n: ",                  ; // 20
      "Volby filtru",                 ; // 21
      "Pole datab�ze",                ; // 22
      "Oper�tor porovn�n�",           ; // 23
      "Hodnota filtru",               ; // 24
      "Vyber pole do filtru",         ; // 25
      "Vyber oper�tor porovn�n�",     ; // 26
      "rovno",                        ; // 27
      "nerovno",                      ; // 28
      "v�t�� ne�",                    ; // 29
      "men�� ne�",                    ; // 30
      "v�t�� nebo rovno ne�",         ; // 31
      "men�� nebo rovno ne�"          } // 32
      _HMG_aLangUser := { ;
         CRLF + "Nelze naj�t aktivn� oblast   "  + CRLF + "Pros�m vyberte n�kterou p�ed vol�n�m EDIT   " + CRLF,         ; // 1
      "Zadejte hodnotu pole (libovoln� text)",                                                                        ; // 2
      "Zadejte hodnotu pole (libovoln� ��slo)",                                                                       ; // 3
      "Vyberte datum",                                                                                                ; // 4
      "Zatrhn�te pro hodnotu true",                                                                                   ; // 5
      "Zadejte hodnotu pole",                                                                                         ; // 6
      "Vyberte jak�koliv z�znam s stiskn�te OK",                                                                      ; // 7
      CRLF + "Chcete smazat tento z�znam  " + CRLF + "Jste si jist(a)?    " + CRLF,                                   ; // 8
      CRLF + "Nen� vybr�no ��dn� t��d�n�   " + CRLF + "Pros�m zvolte jedno   " + CRLF,                                ; // 9
      CRLF + "Nelze hledat podle pole memo nebo logic   " + CRLF,                                                     ; // 10
      CRLF + "Z�znam nenalezen   " + CRLF,                                                                            ; // 11
      "Vyberte pole k za�azen� do seznamu",                                                                           ; // 12
      "Vyberte pole k vy�azen� ze seznamu",                                                                           ; // 13
      "Vyberte tisk�rnu",                                                                                             ; // 14
      "Stiskn�te tla��tko pro za�azen� pole",                                                                         ; // 15
      "Stiskn�t� tla��tko k vy�azen� pole",                                                                           ; // 16
      "Stiskn�te tla��tko k v�b�ru prvn�ho z�znamu k tisku",                                                          ; // 17
      "Stiskn�t� tla��tko k v�b�ru posledn�ho z�znamu k tisku",                                                       ; // 18
      CRLF + "K za�azen� nezb�vaj� pole   " + CRLF,                                                                   ; // 19
      CRLF + "Prvn� v�b�r pole k za�azen�   " + CRLF,                                                                 ; // 20
      CRLF + "Nelze vy�adit dal�� pole   " + CRLF,                                                                    ; // 21
      CRLF + "Prvn� v�b�r pole k vy�azen�   " + CRLF,                                                                 ; // 22
      CRLF + "Nebylo vybr�no ��dn� pole   " + CRLF + "Pros�m vyberte pole pro za�azen� do tisku   " + CRLF,           ; // 23
      CRLF + "P��li� mnoho pol�   " + CRLF + "odeberte n�kter� pole   " + CRLF,                                       ; // 24
      CRLF + "Tisk�rna nen� p�ipravena   " + CRLF,                                                                    ; // 25
      "T��d�no dle",                                                                                                  ; // 26
      "Od z�znamu",                                                                                                   ; // 27
      "Do z�znamu",                                                                                                   ; // 28
      "Ano",                                                                                                          ; // 29
      "Ne",                                                                                                           ; // 30
      "Strana:",                                                                                                      ; // 31
      CRLF + "Pros�m vyberte tisk�rnu   " + CRLF,                                                                     ; // 32
      "Filtrov�no dle",                                                                                               ; // 33
      CRLF + "Filtr nen� aktivn�    " + CRLF,                                                                         ; // 34
      CRLF + "Nelze filtrovat podle memo    " + CRLF,                                                                 ; // 35
      CRLF + "Vyberte pole do filtru    " + CRLF,                                                                     ; // 36
      CRLF + "Vybarte oper�tor do filtru    " + CRLF,                                                                 ; // 37
      CRLF + "Zadejte hodnotu do filtru    " + CRLF,                                                                  ; // 38
      CRLF + "Nen� ��dn� aktivn� filtr    " + CRLF,                                                                   ; // 39
      CRLF + "Deactivovat filtr?   " + CRLF,                                                                          ; // 40
      CRLF + "Z�znam uzam�en jin�m u�ivatelem  " + CRLF,                                                              ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF                     } // 42

   CASE cLang == "HR"  // Croatian
      /////////////////////////////////////////////////////////////
      // CROATIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Are you sure ?'
      _HMG_MESSAGE [2] := 'Zatvori prozor'
      _HMG_MESSAGE [3] := 'Zatvaranje nije dozvoljeno'
      _HMG_MESSAGE [4] := 'Program je ve� pokrenut'
      _HMG_MESSAGE [5] := 'Uredi'
      _HMG_MESSAGE [6] := 'U redu'
      _HMG_MESSAGE [7] := 'Prekid'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Pag.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "Append"  , ;
         "Edit"    , ;
         "&Cancel"  , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Window: "                                           , ;
         " is not defined. Program terminated"                   , ;
         "MiniGUI Error"                                         , ;
         "Control: "                                             , ;
         " Of "                                                  , ;
         " Already defined. Program terminated"                  , ;
         "Browse: Type Not Allowed. Program terminated"          , ;
         "Browse: Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea.", ;
         "Record Is Being Edited By Another User"                , ;
         "Warning"                                               , ;
         "Invalid Entry"                                          }
      _HMG_BRWLangMessage := { 'Are you sure ?' , 'Delete Record' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Delete record" + Chr( 13 ) + "Are you sure ?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Index file missing" + Chr( 13 ) + "Can`t do search" + Chr( 13 )            , ;
         Chr( 13 ) + "Can`t find index field" + Chr( 13 ) + "Can`t do search" + Chr( 13 )        , ;
         Chr( 13 ) + "Can't do search by" + Chr( 13 ) + "fields memo or logic" + Chr( 13 )       , ;
         Chr( 13 ) + "Record not found" + Chr( 13 )                                        , ;
         Chr( 13 ) + "To many cols" + Chr( 13 ) + "The report can't fit in the sheet" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Record"              , ;
         "Record count"        , ;
         "       (New)"        , ;
         "      (Edit)"        , ;
         "Enter record number" , ;
         "Find"                , ;
         "Search text"         , ;
         "Search date"         , ;
         "Search number"       , ;
         "Report definition"   , ;
         "Report columns"      , ;
         "Available columns"   , ;
         "Initial record"      , ;
         "Final record"        , ;
         "Report of "          , ;
         "Date:"               , ;
         "Initial record:"     , ;
         "Final record:"       , ;
         "Ordered by:"         , ;
         "Yes"                 , ;
         "No"                  , ;
         "Page "               , ;
         " of "                 }

      _HMG_aABMLangButton := { "Close"    , ;
         "New"      , ;
         "Edit"     , ;
         "Delete"   , ;
         "Find"     , ;
         "Goto"     , ;
         "Report"   , ;
         "First"    , ;
         "Previous" , ;
         "Next"     , ;
         "Last"     , ;
         "Save"     , ;
         "Cancel"   , ;
         "Add"      , ;
         "Remove"   , ;
         "Print"    , ;
         "Close"     }
      _HMG_aABMLangError  := { "EDIT, workarea name missing"          , ;
         "EDIT, this workarea has more than 16 fields"              , ;
         "EDIT, refresh mode out of range (please report bug)"      , ;
         "EDIT, main event number out of range (please report bug)" , ;
         "EDIT, list event number out of range (please report bug)"  }

      // EDIT EXTENDED MESSAGES

      _HMG_aLangButton := { ;
         "&Close",             ; // 1
      "&New",               ; // 2
      "&Modify",            ; // 3
      "&Delete",            ; // 4
      "&Find",              ; // 5
      "&Print",             ; // 6
      "&Cancel",            ; // 7
      "&Ok",                ; // 8
      "&Copy",              ; // 9
      "&Activate Filter",   ; // 10
      "&Deactivate Filter", ; // 11
      "&Restore"            } // 12
      _HMG_aLangLabel := {            ;
         "None",                         ; // 1
      "Record",                       ; // 2
      "Total",                        ; // 3
      "Active order",                 ; // 4
      "Options",                      ; // 5
      "New record",                   ; // 6
      "Modify record",                ; // 7
      "Select record",                ; // 8
      "Find record",                  ; // 9
      "Print options",                ; // 10
      "Available fields",             ; // 11
      "Fields to print",              ; // 12
      "Available printers",           ; // 13
      "First record to print",        ; // 14
      "Last record to print",         ; // 15
      "Delete record",                ; // 16
      "Preview",                      ; // 17
      "View page thumbnails",         ; // 18
      "Filter Condition: ",           ; // 19
      "Filtered: ",                   ; // 20
      "Filtering Options" ,           ; // 21
      "Database Fields" ,             ; // 22
      "Comparison Operator",          ; // 23
      "Filter Value",                 ; // 24
      "Select Field To Filter",       ; // 25
      "Select Comparison Operator",   ; // 26
      "Equal",                        ; // 27
      "Not Equal",                    ; // 28
      "Greater Than",                 ; // 29
      "Lower Than",                   ; // 30
      "Greater or Equal Than",        ; // 31
      "Lower or Equal Than"           } // 32
      _HMG_aLangUser := { ;
         CRLF + "Can't find an active area.   "  + CRLF + "Please select any area before call EDIT   " + CRLF,       ; // 1
      "Type the field value (any text)",                                                                          ; // 2
      "Type the field value (any number)",                                                                        ; // 3
      "Select the date",                                                                                          ; // 4
      "Check for true value",                                                                                     ; // 5
      "Enter the field value",                                                                                    ; // 6
      "Select any record and press OK",                                                                           ; // 7
      CRLF + "You are going to delete the active record   " + CRLF + "Are you sure?    " + CRLF,                  ; // 8
      CRLF + "There isn't any active order   " + CRLF + "Please select one   " + CRLF,                            ; // 9
      CRLF + "Can't do searches by fields memo or logic   " + CRLF,                                               ; // 10
      CRLF + "Record not found   " + CRLF,                                                                        ; // 11
      "Select the field to include to list",                                                                      ; // 12
      "Select the field to exclude from list",                                                                    ; // 13
      "Select the printer",                                                                                       ; // 14
      "Push button to include field",                                                                             ; // 15
      "Push button to exclude field",                                                                             ; // 16
      "Push button to select the first record to print",                                                          ; // 17
      "Push button to select the last record to print",                                                           ; // 18
      CRLF + "No more fields to include   " + CRLF,                                                               ; // 19
      CRLF + "First select the field to include   " + CRLF,                                                       ; // 20
      CRLF + "No more fields to exlude   " + CRLF,                                                                ; // 21
      CRLF + "First select th field to exclude   " + CRLF,                                                        ; // 22
      CRLF + "You don't select any field   " + CRLF + "Please select the fields to include on print   " + CRLF,   ; // 23
      CRLF + "Too many fields   " + CRLF + "Reduce number of fields   " + CRLF,                                   ; // 24
      CRLF + "Printer not ready   " + CRLF,                                                                       ; // 25
      "Ordered by",                                                                                               ; // 26
      "From record",                                                                                              ; // 27
      "To record",                                                                                                ; // 28
      "Yes",                                                                                                      ; // 29
      "No",                                                                                                       ; // 30
      "Page:",                                                                                                    ; // 31
      CRLF + "Please select a printer   " + CRLF,                                                                 ; // 32
      "Filtered by",                                                                                              ; // 33
      CRLF + "There is an active filter    " + CRLF,                                                              ; // 34
      CRLF + "Can't filter by memo fields    " + CRLF,                                                            ; // 35
      CRLF + "Select the field to filter    " + CRLF,                                                             ; // 36
      CRLF + "Select any operator to filter    " + CRLF,                                                          ; // 37
      CRLF + "Type any value to filter    " + CRLF,                                                               ; // 38
      CRLF + "There isn't any active filter    " + CRLF,                                                          ; // 39
      CRLF + "Deactivate filter?   " + CRLF,                                                                      ; // 40
      CRLF + "Record locked by another user    " + CRLF,                                                          ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF                 } // 42

   CASE cLang == "EU"  // Basque
      /////////////////////////////////////////////////////////////
      // BASQUE
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Are you sure ?'
      _HMG_MESSAGE [2] := 'Close Window'
      _HMG_MESSAGE [3] := 'Close not allowed'
      _HMG_MESSAGE [4] := 'Program Already Running'
      _HMG_MESSAGE [5] := 'Edit'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Cancel'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Pag.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "Append"  , ;
         "Edit"    , ;
         "&Cancel"  , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Window: "                                           , ;
         " is not defined. Program terminated"                   , ;
         "MiniGUI Error"                                         , ;
         "Control: "                                             , ;
         " Of "                                                  , ;
         " Already defined. Program terminated"                  , ;
         "Browse: Type Not Allowed. Program terminated"          , ;
         "Browse: Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea.", ;
         "Record Is Being Edited By Another User"                , ;
         "Warning"                                               , ;
         "Invalid Entry"                                          }
      _HMG_BRWLangMessage := { 'Are you sure ?' , 'Delete Record' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Delete record" + Chr( 13 ) + "Are you sure ?" + Chr( 13 ), ;
         Chr( 13 ) + "Index file missing" + Chr( 13 ) + "Can`t do search" + Chr( 13 )            , ;
         Chr( 13 ) + "Can`t find index field" + Chr( 13 ) + "Can`t do search" + Chr( 13 )        , ;
         Chr( 13 ) + "Can't do search by" + Chr( 13 ) + "fields memo or logic" + Chr( 13 )       , ;
         Chr( 13 ) + "Record not found" + Chr( 13 )                                        , ;
         Chr( 13 ) + "To many cols" + Chr( 13 ) + "The report can't fit in the sheet" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Record"              , ;
         "Record count"        , ;
         "       (New)"        , ;
         "      (Edit)"        , ;
         "Enter record number" , ;
         "Find"                , ;
         "Search text"         , ;
         "Search date"         , ;
         "Search number"       , ;
         "Report definition"   , ;
         "Report columns"      , ;
         "Available columns"   , ;
         "Initial record"      , ;
         "Final record"        , ;
         "Report of "          , ;
         "Date:"               , ;
         "Initial record:"     , ;
         "Final record:"       , ;
         "Ordered by:"         , ;
         "Yes"                 , ;
         "No"                  , ;
         "Page "               , ;
         " of "                 }

      _HMG_aABMLangButton := { "Close"    , ;
         "New"      , ;
         "Edit"     , ;
         "Delete"   , ;
         "Find"     , ;
         "Goto"     , ;
         "Report"   , ;
         "First"    , ;
         "Previous" , ;
         "Next"     , ;
         "Last"     , ;
         "Save"     , ;
         "Cancel"   , ;
         "Add"      , ;
         "Remove"   , ;
         "Print"    , ;
         "Close"     }
      _HMG_aABMLangError  := { "EDIT, workarea name missing"          , ;
         "EDIT, this workarea has more than 16 fields"              , ;
         "EDIT, refresh mode out of range (please report bug)"      , ;
         "EDIT, main event number out of range (please report bug)" , ;
         "EDIT, list event number out of range (please report bug)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := {   ;
         "&Itxi",             ; // 1
         "&Berria",           ; // 2
         "&Aldatu",           ; // 3
         "&Ezabatu",          ; // 4
         "Bi&latu",           ; // 5
         "In&primatu",        ; // 6
         "&Utzi",             ; // 7
         "&Ok",               ; // 8
         "&Kopiatu",          ; // 9
         "I&ragazkia Ezarri", ; // 10
         "Ira&gazkia Kendu",  ; // 11
         "&Restore"           } // 12
      _HMG_aLangLabel := {                  ;
         "Bat ere ez",                      ; // 1
      "Erregistroa",                        ; // 2
      "Guztira",                            ; // 3
      "Orden Aktiboa",                      ; // 4
      "Aukerak",                            ; // 5
      "Erregistro Berria",                  ; // 6
      "Erregistroa Aldatu",                 ; // 7
      "Erregistroa Aukeratu",               ; // 8
      "Erregistroa Bilatu",                 ; // 9
      "Inprimatze-aukerak",                 ; // 10
      "Eremu Libreak",                      ; // 11
      "Inprimatzeko Eremuak",               ; // 12
      "Inprimagailu Libreak",               ; // 13
      "Inprimatzeko Lehenengo Erregistroa", ; // 14
      "Inprimatzeko Azken Erregistroa",     ; // 15
      "Erregistroa Ezabatu",                ; // 16
      "Aurreikusi",                         ; // 17
      "Orrien Irudi Txikiak Ikusi",         ; // 18
      "Iragazkiaren Baldintza: ",           ; // 19
      "Iragazita: ",                        ; // 20
      "Iragazte-aukerak" ,                  ; // 21
      "Datubasearen Eremuak" ,              ; // 22
      "Konparaketa Eragilea",               ; // 23
      "Iragazkiaren Balioa",                ; // 24
      "Iragazteko Eremua Aukeratu",         ; // 25
      "Konparaketa Eragilea Aukeratu",      ; // 26
      "Berdin",                             ; // 27
      "Ezberdin",                           ; // 28
      "Handiago",                           ; // 29
      "Txikiago",                           ; // 30
      "Handiago edo Berdin",                ; // 31
      "Txikiago edo Berdin"                 } // 32
      _HMG_aLangUser := { ;
         CRLF + "Ezin da area aktiborik aurkitu.   "  + CRLF + "Mesedez aukeratu area EDIT deitu baino lehen   " + CRLF,  ; // 1
      "Eremuaren balioa idatzi (edozein testu)",                                                                       ; // 2
      "Eremuaren balioa idatzi (edozein zenbaki)",                                                                     ; // 3
      "Data aukeratu",                                                                                                 ; // 4
      "Markatu egiazko baliorako",                                                                                     ; // 5
      "Eremuaren balioa sartu",                                                                                        ; // 6
      "Edozein erregistro aukeratu eta OK sakatu",                                                                     ; // 7
      CRLF + "Erregistro aktiboa ezabatuko duzu   " + CRLF + "Ziur zaude?    " + CRLF,                                 ; // 8
      CRLF + "Ez dago orden aktiborik   " + CRLF + "Mesedez aukeratu bat   " + CRLF,                                   ; // 9
      CRLF + "Memo edo eremu logikoen arabera ezin bilaketarik egin   " + CRLF,                                        ; // 10
      CRLF + "Erregistroa ez da aurkitu   " + CRLF,                                                                    ; // 11
      "Zerrendan sartzeko eremua aukeratu",                                                                            ; // 12
      "Zerrendatik kentzeko eremua aukeratu",                                                                          ; // 13
      "Inprimagailua aukeratu",                                                                                        ; // 14
      "Sakatu botoia eremua sartzeko",                                                                                 ; // 15
      "Sakatu botoia eremua kentzeko",                                                                                 ; // 16
      "Sakatu botoia inprimatzeko lehenengo erregistroa aukeratzeko",                                                  ; // 17
      "Sakatu botoia inprimatzeko azken erregistroa aukeratzeko",                                                      ; // 18
      CRLF + "Sartzeko eremu gehiagorik ez   " + CRLF,                                                                 ; // 19
      CRLF + "Lehenago aukeratu sartzeko eremua   " + CRLF,                                                            ; // 20
      CRLF + "Kentzeko eremu gehiagorik ez   " + CRLF,                                                                 ; // 21
      CRLF + "Lehenago aukeratu kentzeko eremua   " + CRLF,                                                            ; // 22
      CRLF + "Ez duzu eremurik aukeratu  " + CRLF + "Mesedez aukeratu inprimaketan sartzeko eremuak   " + CRLF,        ; // 23
      CRLF + "Eremu gehiegi   " + CRLF + "Murriztu eremu kopurua   " + CRLF,                                           ; // 24
      CRLF + "Inprimagailua ez dago prest   " + CRLF,                                                                  ; // 25
      "Ordenatuta honen arabera:",                                                                                     ; // 26
      "Erregistro honetatik:",                                                                                         ; // 27
      "Erregistro honetara:",                                                                                          ; // 28
      "Bai",                                                                                                           ; // 29
      "Ez",                                                                                                            ; // 30
      "Orrialdea:",                                                                                                    ; // 31
      CRLF + "Mesedez aukeratu inprimagailua   " + CRLF,                                                               ; // 32
      "Iragazita honen arabera:",                                                                                      ; // 33
      CRLF + "Iragazki aktiboa dago    " + CRLF,                                                                       ; // 34
      CRLF + "Ezin iragazi Memo eremuen arabera    " + CRLF,                                                           ; // 35
      CRLF + "Iragazteko eremua aukeratu    " + CRLF,                                                                  ; // 36
      CRLF + "Iragazteko edozein eragile aukeratu    " + CRLF,                                                         ; // 37
      CRLF + "Idatzi edozein balio iragazteko    " + CRLF,                                                             ; // 38
      CRLF + "Ez dago iragazki aktiborik    " + CRLF,                                                                  ; // 39
      CRLF + "Iragazkia kendu?   " + CRLF,                                                                             ; // 40
      CRLF + "Record locked by another user    " + CRLF,                                                               ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF                      } // 42

   CASE cLang == "FR"  // French
      /////////////////////////////////////////////////////////////
      // FRENCH
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Etes-vous s�re ?'
      _HMG_MESSAGE [2] := 'Fermer la fen�tre'
      _HMG_MESSAGE [3] := 'Fermeture interdite'
      _HMG_MESSAGE [4] := 'Programme d�j� activ�'
      _HMG_MESSAGE [5] := 'Editer'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Abandonner'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Pag.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Ajout"         , ;
         "Modification"  , ;
         "Annuler"       , ;
         "OK"             }
      _HMG_BRWLangError  := { "Fen�tre: "                                             , ;
         " n'est pas d�finie. Programme termin�"                 , ;
         "Erreur MiniGUI"                                        , ;
         "Contr�le: "                                            , ;
         " De "                                                  , ;
         " D�j� d�fini. Programme termin�"                       , ;
         "Modification: Type non autoris�. Programme termin�"    , ;
         "Modification: La clause Ajout ne peut �tre utilis�e avec des champs n'appartenant pas � la zone de travail de Modification. Programme termin�", ;
         "L'enregistrement est utilis� par un autre utilisateur"  , ;
         "Erreur"                                                , ;
         "Entr�e invalide"                                        }
      _HMG_BRWLangMessage := { 'Etes-vous s�re ?' , 'Enregistrement d�truit' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Suppression d'enregistrement" + Chr( 13 ) + "Etes-vous s�re ?" + Chr( 13 )  , ;
         Chr( 13 ) + "Index manquant" + Chr( 13 ) + "Recherche impossible" + Chr( 13 )            , ;
         Chr( 13 ) + "Champ Index introuvable" + Chr( 13 ) + "Recherche impossible" + Chr( 13 )   , ;
         Chr( 13 ) + "Recherche impossible" + Chr( 13 ) + "sur champs memo ou logique" + Chr( 13 ), ;
         Chr( 13 ) + "Enregistrement non trouv�" + Chr( 13 )                                                     , ;
         Chr( 13 ) + "Trop de colonnes" + Chr( 13 ) + "L'�tat ne peut �tre imprim�" + Chr( 13 )      }
      _HMG_aABMLangLabel  := { "Enregistrement"                       , ;
         "Nb. total enr."                       , ;
         "   (Ajouter)"                        , ;
         "  (Modifier)"                        , ;
         "Entrez le num�ro de l'enregistrement" , ;
         "Trouver"                              , ;
         "Chercher texte"                       , ;
         "Chercher date"                        , ;
         "Chercher num�ro"                      , ;
         "D�finition de l'�tat"                 , ;
         "Colonnes de l'�tat"                   , ;
         "Colonnes disponibles"                 , ;
         "Enregistrement de d�but"              , ;
         "Enregistrement de fin"                , ;
         "Etat de "                             , ;
         "Date:"                                , ;
         "Enregistrement de d�but:"             , ;
         "Enregistrement de fin:"               , ;
         "Tri� par:"                            , ;
         "Oui"                                  , ;
         "Non"                                  , ;
         " Page"                                , ;
         " de "                                 }
      _HMG_aABMLangButton := { "Fermer"      , ;
         "Nouveau"     , ;
         "Modifier"    , ;
         "Supprimer"   , ;
         "Trouver"     , ;
         "Aller �"     , ;
         "Etat"   , ;
         "Premier"     , ;
         "Pr�c�dent"   , ;
         "Suivant"     , ;
         "Dernier"     , ;
         "Enregistrer" , ;
         "Annuler"     , ;
         "Ajouter"     , ;
         "Retirer"     , ;
         "Imprimer"    , ;
         "Fermer"      }
      _HMG_aABMLangError  := { "EDIT, nom de la table manquant"                   , ;
         "EDIT, la table a plus de 16 champs"                                     , ;
         "EDIT, mode rafraichissement hors limite (Rapport d'erreur merci)"       , ;
         "EDIT, �v�nement principal nombre hors limite (Rapport d'erreur merci)"  , ;
         "EDIT, liste d'�v�nements nombre hors limite (Rapport d'erreur merci)"   }

      // EDIT EXTENDED

      _HMG_aLangButton := {  ;
         "&Fermer",          ; // 1
         "&Nouveau",         ; // 2
         "&Modifier",        ; // 3
         "&Supprimer",       ; // 4
         "&Trouver",         ; // 5
         "&Imprimer",        ; // 6
         "&Abandon",         ; // 7
         "&Ok",              ; // 8
         "&Copier",          ; // 9
         "&Activer Filtre",  ; // 10
         "&D�activer Filtre",; // 11
         "&Reconstituer"     } // 12
      _HMG_aLangLabel := {                       ;
         "Aucun",                                ; // 1
      "Enregistrement",                          ; // 2
      "Total",                                   ; // 3
      "Ordre actif",                             ; // 4
      "Options",                                 ; // 5
      "Nouvel enregistrement",                   ; // 6
      "Modifier enregistrement",                 ; // 7
      "Selectionner enregistrement",             ; // 8
      "Trouver enregistrement",                  ; // 9
      "Imprimer options",                        ; // 10
      "Champs disponibles",                      ; // 11
      "Champs � imprimer",                       ; // 12
      "Imprimantes connect�es",                  ; // 13
      "Premier enregistrement � imprimer",       ; // 14
      "Dernier enregistrement � imprimer",       ; // 15
      "Enregistrement supprim�",                 ; // 16
      "Pr�visualisation",                        ; // 17
      "Aper�u pages",                            ; // 18
      "Condition filtre : ",                     ; // 19
      "Filtr� : ",                               ; // 20
      "Options de filtrage" ,                    ; // 21
      "Champs de la Bdd" ,                       ; // 22
      "Op�rateurs de comparaison",               ; // 23
      "Valeur du filtre",                        ; // 24
      "Selectionner le champ � filtrer",         ; // 25
      "Selectionner l'op�rateur de comparaison", ; // 26
      "Egal",                                    ; // 27
      "Diff�rent",                               ; // 28
      "Plus grand",                              ; // 29
      "Plus petit",                              ; // 30
      "Plus grand ou �gal",                      ; // 31
      "Plus petit ou �gal"                       } // 32
      _HMG_aLangUser := { ;
         CRLF + "Ne peut trouver une base active.   "  + CRLF + "S�lectionner une base avant la fonction EDIT  " + CRLF,            ; // 1
      "Entrer la valeur du champ (du texte)",                                                                                       ; // 2
      "Entrer la valeur du champ (un nombre)",                                                                                      ; // 3
      "S�lectionner la date",                                                                                                       ; // 4
      "V�rifier la valeur logique",                                                                                                 ; // 5
      "Entrer la valeur du champ",                                                                                                  ; // 6
      "S�lectionner un enregistrement et appuyer sur OK",                                                                           ; // 7
      CRLF + "Vous voulez d�truire l'enregistrement actif  " + CRLF + "Etes-vous s�re?   " + CRLF,                                  ; // 8
      CRLF + "Il n'y a pas d'ordre actif   " + CRLF + "S�lectionner en un   " + CRLF,                                               ; // 9
      CRLF + "Ne peut faire de recherche sur champ memo ou logique   " + CRLF,                                                      ; // 10
      CRLF + "Enregistrement non trouv�  " + CRLF,                                                                                  ; // 11
      "S�lectionner le champ � inclure � la liste",                                                                                 ; // 12
      "S�lectionner le champ � exclure de la liste",                                                                                ; // 13
      "S�lectionner l'imprimante",                                                                                                  ; // 14
      "Appuyer sur le bouton pour inclure un champ",                                                                                ; // 15
      "Appuyer sur le bouton pour exclure un champ",                                                                                ; // 16
      "Appuyer sur le bouton pour s�lectionner le premier enregistrement � imprimer",                                               ; // 17
      "Appuyer sur le bouton pour s�lectionner le dernier champ � imprimer",                                                        ; // 18
      CRLF + "Plus de champs � inclure   " + CRLF,                                                                                  ; // 19
      CRLF + "S�lectionner d'abord les champs � inclure   " + CRLF,                                                                 ; // 20
      CRLF + "Plus de champs � exclure   " + CRLF,                                                                                  ; // 21
      CRLF + "S�lectionner d'abord les champs � exclure   " + CRLF,                                                                 ; // 22
      CRLF + "Vous n'avez s�lectionn� aucun champ   " + CRLF + "S�lectionner les champs � inclure dans l'impression   " + CRLF,     ; // 23
      CRLF + "Trop de champs   " + CRLF + "R�duiser le nombre de champs   " + CRLF,                                                 ; // 24
      CRLF + "Imprimante pas pr�te   " + CRLF,                                                                                      ; // 25
      "Tri� par",                                                                                                                   ; // 26
      "De l'enregistrement",                                                                                                        ; // 27
      "A l'enregistrement",                                                                                                         ; // 28
      "Oui",                                                                                                                        ; // 29
      "Non",                                                                                                                        ; // 30
      "Page:",                                                                                                                      ; // 31
      CRLF + "S�lectionner une imprimante   " + CRLF,                                                                               ; // 32
      "Filtr� par",                                                                                                                 ; // 33
      CRLF + "Il y a un filtre actif    " + CRLF,                                                                                   ; // 34
      CRLF + "Filtre impossible sur champ memo    " + CRLF,                                                                         ; // 35
      CRLF + "S�lectionner un champ de filtre    " + CRLF,                                                                          ; // 36
      CRLF + "S�lectionner un op�rateur de filtre   " + CRLF,                                                                       ; // 37
      CRLF + "Entrer une valeur au filtre    " + CRLF,                                                                              ; // 38
      CRLF + "Il n'y a aucun filtre actif    " + CRLF,                                                                              ; // 39
      CRLF + "D�sactiver le filtre?   " + CRLF,                                                                                     ; // 40
      CRLF + "Record locked by another user    " + CRLF,                                                                            ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF                                   } // 42

   CASE cLang == "DE"  // German
      /////////////////////////////////////////////////////////////
      // GERMAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Sind Sie sicher ?'
      _HMG_MESSAGE [2] := 'Fenster schlie�en'
      _HMG_MESSAGE [3] := 'Schlie�en nicht erlaubt'
      _HMG_MESSAGE [4] := 'Programm l�uft bereits'
      _HMG_MESSAGE [5] := 'Bearbeiten'
      _HMG_MESSAGE [6] := 'OK'
      _HMG_MESSAGE [7] := 'Abbruch'
      _HMG_MESSAGE [8] := 'Anwenden'
      _HMG_MESSAGE [9] := 'Seite'
      _HMG_MESSAGE [10] := 'Warnung'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Anh�ngen"  , ;
         "Bearbeiten"    , ;
         "&Abbruch"  , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Window: "                         , ;
         " ist nicht definiert. Programm Abbruch"                , ;
         "MiniGUI Error"                                         , ;
         "Control: "                                             , ;
         " Of "                                                  , ;
         " bereits definiert. Programm Abbruch"                  , ;
         "Browse: Type nicht erlaubt. Programm Abbruch"          , ;
         "Browse: Append kann nicht auf Feldern in anderen Workarea angewendet werden.", ;
         "Datensatz in Bearbeitung eines anderen Nutzers"        , ;
         "Warnung"                                               , ;
         "Ung�ltiger Eintrag"                                          }
      _HMG_BRWLangMessage := { 'Sind Sie sicher ?' , 'Datensatz l�schen' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Datensatz l�schen" + Chr( 13 ) + "Sind Sie sicher ?" + Chr( 13 ), ;
         Chr( 13 ) + "Index Datei fehlt" + Chr( 13 ) + "Suche nicht m�glich" + Chr( 13 ), ;
         Chr( 13 ) + "Finde Indexdatenfeld nicht" + Chr( 13 ) + "Suche nicht m�glich" + Chr( 13 ), ;
         Chr( 13 ) + "Suche in Memo oder Logic " + Chr( 13 ) + "Feld nicht m�glich" + Chr( 13 ), ;
         Chr( 13 ) + "Datensatz nicht gefunden" + Chr( 13 ), ;
         Chr( 13 ) + "Zu viele Spalten" + Chr( 13 ) + " Report passt nicht auf die Seite" + Chr( 13 ) }
   
      _HMG_aABMLangLabel  := { "Datensatz"              , ;
         "Datensatz Anzahl"        , ;
         "Datensatz (Neu)"        , ;
         "Datensatz (Edit)"        , ;
         "Datensatznummer eintragen" , ;
         "Suchen"                , ;
         "Suche Text"         , ;
         "Suche Datum"         , ;
         "Suche Nummer"       , ;
         "Report Definition"   , ;
         "Report Spalten"      , ;
         "Verf�gbare Spalten"     , ;
         "Erster Datensatz"      , ;
         "Letzter Datensatz"        , ;
         "Report vom "          , ;
         "Datum:"               , ;
         "Erster Datensatz:"     , ;
         "Letzter Datensatz:"       , ;
         "Sortieren nach:"         , ;
         "Ja"                 , ;
         "Nein"                  , ;
         "Seite "               , ;
         " von "                 }
      _HMG_aABMLangButton := { "Schlie�en"    , ;
         "Neu"      , ;
         "Bearbeiten"     , ;
         "L�schen"   , ;
         "Suchen"     , ;
         "Gehe zu"     , ;
         "Report"   , ;
         "Erster"    , ;
         "Davor" , ;
         "N�chster"     , ;
         "Letzter"     , ;
         "Speichern"     , ;
         "Abbrechen"   , ;
         "Hinzuf�gen"      , ;
         "Entfernen"   , ;
         "Drucken"    , ;
         "Schlie�en"     }
      _HMG_aABMLangError  := { "EDIT, Workarea Name fehlt" , ;
         "EDIT, Workarea hat mehr als 16 Felder" , ;
         "EDIT, Aktualisierung ausserhalb des Bereichs (siehe Fehlermeldungen)" , ;
         "EDIT, Haupt Ereignis ausserhalb des Bereichs (siehe Fehlermeldungen)" , ;
         "EDIT, Listen Ereignis ausserhalb des Bereichs (siehe Fehlermeldungen)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := {  ;
      "S&chlie�en",          ; // 1
      "&Neu",                ; // 2
      "&Bearbeiten",         ; // 3
      "&L�schen",            ; // 4
      "&Suchen",             ; // 5
      "&Drucken",            ; // 6
      "&Abbruch",            ; // 7
      "&Ok",                 ; // 8
      "&Kopieren",           ; // 9
      "&Filter aktivieren",  ; // 10
      "&Filter deaktivieren",; // 11
      "&Wiederherstellen"    } // 12
      _HMG_aLangLabel := { ;
      "Keine",                                         ; // 1
      "Datensatz",                                     ; // 2
      "Gesamt",                                        ; // 3
      "Aktive Sortierung",                             ; // 4
      "Einstellungen",                                 ; // 5
      "Neuer Datensatz",                               ; // 6
      "Datensatz bearbeiten",                          ; // 7
      "Datensatz ausw�hlen",                           ; // 8
      "Datensatz finden",                              ; // 9
      "Druckeinstellungen",                            ; // 10
      "Verf�gbare Felder",                             ; // 11
      "Zu druckende Felder",                           ; // 12
      "Verf�gbare Drucker",                            ; // 13
      "Erster zu druckender Datensatz",                ; // 14
      "Letzter zu druckender Datensatz",               ; // 15
      "Datensatz l�schen",                             ; // 16
      "Vorschau",                                      ; // 17
      "�bersicht",                                     ; // 18
      "Filterbedingung: ",                             ; // 19
      "Gefiltert: ",                                   ; // 20
      "Filter-Einstellungen" ,                         ; // 21
      "Datenbank-Felder" ,                             ; // 22
      "Vergleichs-Operator",                           ; // 23
      "Filterwert",                                    ; // 24
      "Zu filterndes Feld ausw�hlen",                  ; // 25
      "Vergleichs-Operator ausw�hlen",                 ; // 26
      "Gleich",                                        ; // 27
      "Ungleich",                                      ; // 28
      "Gr��er als",                                    ; // 29
      "Kleiner als",                                   ; // 30
      "Gr��er oder gleich als",                        ; // 31
      "Kleiner oder gleich als"                        } // 32
      _HMG_aLangUser := { ;
         CRLF + "Kein aktiver Arbeitsbereich gefunden.   "  + CRLF + "Bitte einen Arbeitsbereich ausw�hlen vor dem Aufruf von EDIT   " + CRLF,    ; // 1
      "Einen Text eingeben (alphanumerisch)",                                                                                                     ; // 2
      "Eine Zahl eingeben",                                                                                                                       ; // 3
      "Datum ausw�hlen",                                                                                                                          ; // 4
      "F�r positive Auswahl einen Haken setzen",                                                                                                  ; // 5
      "Einen Text eingeben (alphanumerisch)",                                                                                                     ; // 6
      "Einen Datensatz w�hlen und mit OK best�tigen",                                                                                             ; // 7
      CRLF + "Sie sind im Begriff, den aktiven Datensatz zu l�schen.   " + CRLF + "Sind Sie sicher?    " + CRLF,                                  ; // 8
      CRLF + "Es ist keine Sortierung aktiv.   " + CRLF + "Bitte w�hlen Sie eine Sortierung   " + CRLF,                                           ; // 9
      CRLF + "Suche nach den Feldern memo oder logisch nicht m�glich.   " + CRLF,                                                                 ; // 10
      CRLF + "Datensatz nicht gefunden   " + CRLF,                                                                                                ; // 11
      "Bitte ein Feld zum Hinzuf�gen zur Liste w�hlen",                                                                                           ; // 12
      "Bitte ein Feld zum Entfernen aus der Liste w�hlen ",                                                                                       ; // 13
      "Drucker ausw�hlen",                                                                                                                        ; // 14
      "Schaltfl�che  Feld hinzuf�gen",                                                                                                            ; // 15
      "Schaltfl�che  Feld Entfernen",                                                                                                             ; // 16
      "Schaltfl�che  Auswahl erster zu druckender Datensatz",                                                                                     ; // 17
      "Schaltfl�che  Auswahl letzte zu druckender Datensatz",                                                                                     ; // 18
      CRLF + "Keine Felder zum Hinzuf�gen mehr vorhanden   " + CRLF,                                                                              ; // 19
      CRLF + "Bitte erst ein Feld zum Hinzuf�gen w�hlen   " + CRLF,                                                                               ; // 20
      CRLF + "Keine Felder zum Entfernen vorhanden   " + CRLF,                                                                                    ; // 21
      CRLF + "Bitte ein Feld zum Entfernen w�hlen   " + CRLF,                                                                                     ; // 22
      CRLF + "Kein Feld ausgew�hlt   " + CRLF + "Bitte die Felder f�r den Ausdruck ausw�hlen   " + CRLF,                                          ; // 23
      CRLF + "Zu viele Felder   " + CRLF + "Bitte Anzahl der Felder reduzieren   " + CRLF,                                                        ; // 24
      CRLF + "Drucker nicht bereit   " + CRLF,                                                                                                    ; // 25
      "Sortiert nach",                                                                                                                            ; // 26
      "Von Datensatz",                                                                                                                            ; // 27
      "Bis Datensatz",                                                                                                                            ; // 28
      "Ja",                                                                                                                                       ; // 29
      "Nein",                                                                                                                                     ; // 30
      "Seite:",                                                                                                                                   ; // 31
      CRLF + "Bitte einen Drucker w�hlen   " + CRLF,                                                                                              ; // 32
      "Filtern nach",                                                                                                                             ; // 33
      CRLF + "Es ist kein aktiver Filter vorhanden    " + CRLF,                                                                                   ; // 34
      CRLF + "Kann nicht nach Memo-Feldern filtern    " + CRLF,                                                                                   ; // 35
      CRLF + "Feld zum Filtern ausw�hlen    " + CRLF,                                                                                             ; // 36
      CRLF + "Einen Operator zum Filtern ausw�hlen    " + CRLF,                                                                                   ; // 37
      CRLF + "Bitte einen Wert f�r den Filter angeben    " + CRLF,                                                                                ; // 38
      CRLF + "Es ist kein aktiver Filter vorhanden    " + CRLF,                                                                                   ; // 39
      CRLF + "Filter deaktivieren?   " + CRLF,                                                                                                    ; // 40
      CRLF + "Datensatz gesperrt durch anderen Benutzer    " + CRLF,                                                                              ; // 41
      CRLF + "Gel�schten Datensatz wiederherstellen   " + CRLF + "Sind sie sicher?    " + CRLF                                                    } // 42

   CASE cLang == "IT"  // Italian
      /////////////////////////////////////////////////////////////
      // ITALIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Sei sicuro ?'
      _HMG_MESSAGE [2] := 'Chiudi la finestra'
      _HMG_MESSAGE [3] := 'Chiusura non consentita'
      _HMG_MESSAGE [4] := 'Il programma � gi� in esecuzione'
      _HMG_MESSAGE [5] := 'Edita'
      _HMG_MESSAGE [6] := 'Conferma'
      _HMG_MESSAGE [7] := 'Annulla'
      _HMG_MESSAGE [8] := 'Applica'
      _HMG_MESSAGE [9] := 'Pag.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Aggiungere"   , ;
         "Modificare"  , ;
         "Cancellare"  , ;
         "OK"           }
      _HMG_BRWLangError  := { "Window: " , ;
         " non � definita. Programma terminato" , ;
         "Errore MiniGUI"  , ;
         "Controllo: " , ;
         " Di " , ;
         " Gi� definito. Programma Terminato" , ;
         "Browse: Tipo non valido. Programma Terminato"  , ;
         "Browse: Modifica non possibile: il campo non � pertinente l'area di lavoro.Programma Terminato", ;
         "Record gi� utilizzato da altro utente"                 , ;
         "Attenzione!"                                           , ;
         "Dato non valido" }
      _HMG_BRWLangMessage := { 'Sei sicuro ?' , 'Cancella Record' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Cancellare il record" + Chr( 13 ) + "Sei sicuro ?" + Chr( 13 )      , ;
         Chr( 13 ) + "File indice mancante" + Chr( 13 ) + "Ricerca impossibile" + Chr( 13 )   , ;
         Chr( 13 ) + "Campo indice mancante" + Chr( 13 ) + "Ricerca impossibile" + Chr( 13 )  , ;
         Chr( 13 ) + "Ricerca impossibile per" + Chr( 13 ) + "campi memo o logici" + Chr( 13 ), ;
         Chr( 13 ) + "Record non trovato" + Chr( 13 )                                   , ;
         Chr( 13 ) + "Troppe colonne" + Chr( 13 ) + "Il report non pu� essere stampato" + Chr( 13 ) }
      _HMG_aABMLangLabel  := { "Record"              , ;
         "Record totali"       , ;
         "  (Aggiungi)"        , ;
         "     (Nuovo)"        , ;
         "Inserire il numero del record" , ;
         "Ricerca"                , ;
         "Testo da cercare"         , ;
         "Data da cercare"         , ;
         "Numero da cercare"       , ;
         "Definizione del report"   , ;
         "Colonne del report"      , ;
         "Colonne totali"     , ;
         "Record Iniziale"      , ;
         "Record Finale"        , ;
         "Report di "          , ;
         "Data:"               , ;
         "Primo Record:"     , ;
         "Ultimo Record:"       , ;
         "Ordinare per:"         , ;
         "S�"                 , ;
         "No"                  , ;
         "Pagina "               , ;
         " di "                 }
      _HMG_aABMLangButton := { "Chiudi"    , ;
         "Nuovo"      , ;
         "Modifica"     , ;
         "Cancella"   , ;
         "Ricerca"     , ;
         "Vai a"     , ;
         "Report"   , ;
         "Primo"    , ;
         "Precedente" , ;
         "Successivo"     , ;
         "Ultimo"     , ;
         "Salva"     , ;
         "Annulla"   , ;
         "Aggiungi"      , ;
         "Rimuovi"   , ;
         "Stampa"    , ;
         "Chiudi"     }
      _HMG_aABMLangError  := { "EDIT, il nome dell'area � mancante" , ;
         "EDIT, quest'area contiene pi� di 16 campi" , ;
         "EDIT, modalit� aggiornamento fuori dal limite (segnalare l'errore)" , ;
         "EDIT, evento pricipale fuori dal limite (segnalare l'errore)" , ;
         "EDIT, lista eventi fuori dal limite (segnalare l'errore)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := {  ;
         "&Chiudi",          ; // 1
         "&Nuovo",           ; // 2
         "&Modifica",        ; // 3
         "&Elimina",         ; // 4
         "&Trova",           ; // 5
         "&Stampa",          ; // 6
         "&Annulla",         ; // 7
         "&Ok",              ; // 8
         "C&opia",           ; // 9
         "A&ttiva Filtro",   ; // 10
         "&Disattiva Filtro",; // 11
         "&Ripristina"       } // 12
      _HMG_aLangLabel := {                ;
         "Nessuno",                       ; // 1
      "Record",                           ; // 2
      "Totale",                           ; // 3
      "Ordinamento attivo",               ; // 4
      "Opzioni",                          ; // 5
      "Nuovo record",                     ; // 6
      "Modifica record",                  ; // 7
      "Seleziona record",                 ; // 8
      "Trova record",                     ; // 9
      "Stampa opzioni",                   ; // 10
      "Campi disponibili",                ; // 11
      "Campi da stampare",                ; // 12
      "Stampanti disponibili",            ; // 13
      "Primo  record da stampare",        ; // 14
      "Ultimo record da stampare",        ; // 15
      "Cancella record",                  ; // 16
      "Anteprima",                        ; // 17
      "Visualizza pagina miniature",      ; // 18
      "Condizioni Filtro: ",              ; // 19
      "Filtrato: ",                       ; // 20
      "Opzioni Filtro" ,                  ; // 21
      "Campi del Database" ,              ; // 22
      "Operatori di comparazione",        ; // 23
      "Valore Filtro",                    ; // 24
      "Seleziona campo da filtrare",      ; // 25
      "Seleziona operatore comparazione", ; // 26
      "Uguale",                           ; // 27
      "Non Uguale",                       ; // 28
      "Maggiore di",                      ; // 29
      "Minore di",                        ; // 30
      "Maggiore o uguale a",              ; // 31
      "Minore o uguale a"                 } // 32
      _HMG_aLangUser := { ;
         CRLF + "Nessuna area attiva.   "  + CRLF + "Selezionare un'area prima della chiamata a EDIT   " + CRLF,  ; // 1
      "Digitare valore campo (testo)",                                                                         ; // 2
      "Digitare valore campo (numerico)",                                                                      ; // 3
      "Selezionare data",                                                                                      ; // 4
      "Attivare per valore TRUE",                                                                              ; // 5
      "Inserire valore campo",                                                                                 ; // 6
      "Seleziona un record and premi OK",                                                                      ; // 7
      CRLF + "Cancellazione record attivo   " + CRLF + "Sei sicuro?      " + CRLF,                             ; // 8
      CRLF + "Nessun ordinamento attivo     " + CRLF + "Selezionarne uno " + CRLF,                             ; // 9
      CRLF + "Ricerca non possibile su campi MEMO o LOGICI   " + CRLF,                                         ; // 10
      CRLF + "Record non trovato   " + CRLF,                                                                   ; // 11
      "Seleziona campo da includere nel listato",                                                              ; // 12
      "Seleziona campo da escludere dal listato",                                                              ; // 13
      "Selezionare la stampante",                                                                              ; // 14
      "Premi per includere il campo",                                                                          ; // 15
      "Premi per escludere il campo",                                                                          ; // 16
      "Premi per selezionare il primo record da stampare",                                                     ; // 17
      "Premi per selezionare l'ultimo record da stampare",                                                     ; // 18
      CRLF + "Nessun altro campo da inserire   " + CRLF,                                                       ; // 19
      CRLF + "Prima seleziona il campo da includere " + CRLF,                                                  ; // 20
      CRLF + "Nessun altro campo da escludere       " + CRLF,                                                  ; // 21
      CRLF + "Prima seleziona il campo da escludere " + CRLF,                                                  ; // 22
      CRLF + "Nessun campo selezionato     " + CRLF + "Selezionare campi da includere nel listato   " + CRLF,  ; // 23
      CRLF + "Troppi campi !   " + CRLF + "Redurre il numero di campi   " + CRLF,                              ; // 24
      CRLF + "Stampante non pronta..!   " + CRLF,                                                              ; // 25
      "Ordinato per",                                                                                          ; // 26
      "Dal record",                                                                                            ; // 27
      "Al  record",                                                                                            ; // 28
      "Si",                                                                                                    ; // 29
      "No",                                                                                                    ; // 30
      "Pagina:",                                                                                               ; // 31
      CRLF + "Selezionare una stampante   " + CRLF,                                                            ; // 32
      "Filtrato per ",                                                                                         ; // 33
      CRLF + "Esiste un filtro attivo     " + CRLF,                                                            ; // 34
      CRLF + "Filtro non previsto per campi MEMO   " + CRLF,                                                   ; // 35
      CRLF + "Selezionare campo da filtrare        " + CRLF,                                                   ; // 36
      CRLF + "Selezionare un OPERATORE per filtro  " + CRLF,                                                   ; // 37
      CRLF + "Digitare un valore per filtro        " + CRLF,                                                   ; // 38
      CRLF + "Nessun filtro attivo    " + CRLF,                                                                ; // 39
      CRLF + "Disattivare filtro ?   " + CRLF,                                                                 ; // 40
      CRLF + "Record bloccato da altro utente" + CRLF,                                                         ; // 41
      CRLF + "Ripristinare il record cancellato             " + CRLF + "Sei sicuro  ?    " + CRLF              } // 42

   CASE cLang == "PL"  // Polish
      /////////////////////////////////////////////////////////////
      // POLISH
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Czy jeste� pewny ?'
      _HMG_MESSAGE [2] := 'Zamknij okno'
      _HMG_MESSAGE [3] := 'Zamkni�cie niedozwolone'
      _HMG_MESSAGE [4] := 'Program ju� uruchomiony'
      _HMG_MESSAGE [5] := 'Edycja'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Porzu�'
      _HMG_MESSAGE [8] := 'Zastosuj'
      _HMG_MESSAGE [9] := 'Str.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Dodaj"   , ;
         "Edycja"     , ;
         "Porzu�"   , ;
         "OK"        }
      _HMG_BRWLangError  := { "Okno: "                                              , ;
         " nie zdefiniowane.Program zako�czony"         , ;
         "B��d MiniGUI"                                         , ;
         "Kontrolka: "                                             , ;
         " z "                                                  , ;
         " ju� zdefiniowana. Program zako�czony"                  , ;
         "Browse: Niedozwolony typ danych. Program zako�czony"          , ;
         "Browse: Klauzula Append nie mo�e by� stosowana do p�l nie nale��cych do aktualnego obszaru roboczego. Program zako�czony", ;
         "Rekord edytowany przez innego u�ytkownika"                , ;
         "Ostrze�enie"                                               , ;
         "Nieprawid�owy wpis"                                          }
      _HMG_BRWLangMessage := { 'Czy jeste� pewny ?' , 'Skasuj rekord' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Usuni�cie rekordu" + Chr( 13 ) + "Jeste� pewny ?" + Chr( 13 )                 , ;
         Chr( 13 ) + "B��dny zbi�r indeksowy" + Chr( 13 ) + "Nie mo�na szuka�" + Chr( 13 )         , ;
         Chr( 13 ) + "Nie mo�na znale�� pola indeksu" + Chr( 13 ) + "Nie mo�na szuka�" + Chr( 13 ) , ;
         Chr( 13 ) + "Nie mo�na szuka� wg" + Chr( 13 ) + "pola memo lub logicznego" + Chr( 13 )         , ;
         Chr( 13 ) + "Rekordu nie znaleziono" + Chr( 13 )                                                     , ;
         Chr( 13 ) + "Zbyt wiele kolumn" + Chr( 13 ) + "Raport nie mie�ci si� na arkuszu" + Chr( 13 )      }
      _HMG_aABMLangLabel  := { "Rekord"              , ;
         "Liczba rekord�w"        , ;
         "      (Nowy)"        , ;
         "    (Edycja)"        , ;
         "Wprowad� numer rekordu" , ;
         "Szukaj"                , ;
         "Szukaj tekstu"         , ;
         "Szukaj daty"         , ;
         "Szukaj liczby"       , ;
         "Definicja Raportu"   , ;
         "Kolumny Raportu"      , ;
         "Dost�pne kolumny"     , ;
         "Pierwszy rekord"      , ;
         "Ostatni rekord"        , ;
         "Raport z "          , ;
         "Data:"               , ;
         "Pierwszy rekord:"     , ;
         "Ostatni rekord:"       , ;
         "Sortowanie wg:"         , ;
         "Tak"                 , ;
         "Nie"                  , ;
         "Strona "               , ;
         " z "                 }
      _HMG_aABMLangButton := { "Zamknij"    , ;
         "Nowy"      , ;
         "Edytuj"     , ;
         "Usu�"   , ;
         "Znajd�"     , ;
         "Id� do"     , ;
         "Raport"   , ;
         "Pierwszy"    , ;
         "Poprzedni" , ;
         "Nast�pny"     , ;
         "Ostatni"     , ;
         "Zapisz"     , ;
         "Rezygnuj"   , ;
         "Dodaj"      , ;
         "Usu�"   , ;
         "Drukuj"    , ;
         "Zamknij"     }
      _HMG_aABMLangError  := { "EDIT, b��dna nazwa bazy"                                  , ;
         "EDIT, baza ma wi�cej ni� 16 p�l"                   , ;
         "EDIT, tryb od�wierzania poza zakresem (zobacz raport b��d�w)"      , ;
         "EDIT, liczba zdarze� podstawowych poza zakresem (zobacz raport b��d�w)" , ;
         "EDIT, lista zdarze� poza zakresem (zobacz raport b��d�w)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := {          ;
         "&Zamknij",        ; // 1
      "&Nowy",           ; // 2
      "&Modyfikuj",      ; // 3
      "&Kasuj",          ; // 4
      "&Znajd�",         ; // 5
      "&Drukuj",         ; // 6
      "&Porzu�",         ; // 7
      "&Ok",             ; // 8
      "&Kopiuj",         ; // 9
      "&Aktywuj Filtr",  ; // 10
      "&Deaktywuj Filtr", ; // 11
      "&Przywr��"        } // 12

      _HMG_aLangLabel := {                       ;
         "Brak",                        ; // 1
      "Rekord",                      ; // 2
      "Suma",                        ; // 3
      "Aktywny indeks",              ; // 4
      "Opcje",                       ; // 5
      "Nowy rekord",                 ; // 6
      "Modyfikuj rekord",            ; // 7
      "Wybierz rekord",              ; // 8
      "Znajd� rekord",               ; // 9
      "Opcje druku",                 ; // 10
      "Dost�pne pola",               ; // 11
      "Pola do druku",               ; // 12
      "Dost�pne drukarki",           ; // 13
      "Pierwszy rekord do druku",    ; // 14
      "Ostatni rekord do druku",     ; // 15
      "Skasuj rekord",               ; // 16
      "Podgl�d",                     ; // 17
      "Poka� miniatury",             ; // 18
      "Stan filtru: ",               ; // 19
      "Filtrowane: ",                ; // 20
      "Opcje filtrowania" ,          ; // 21
      "Pola bazy danych" ,           ; // 22
      "Operator por�wnania",         ; // 23
      "Warto�� filtru",              ; // 24
      "Wybierz pola do filtru",      ; // 25
      "Wybierz operator por�wnania", ; // 26
      "R�wna si�",                   ; // 27
      "Nie r�wna si�",               ; // 28
      "Wi�kszy ",                    ; // 29
      "Mniejszy ",                   ; // 30
      "Wi�kszy lub r�wny ",          ; // 31
      "Mniejszy lub r�wny"           } // 32
      _HMG_aLangUser := { ;
         CRLF + "Aktywny obszar nie odnaleziony   "  + CRLF + "Wybierz obszar przed wywo�aniem EDIT   " + CRLF,   ; // 1
      "Poszukiwany ci�g znak�w (dowolny tekst)",                                                               ; // 2
      "Poszukiwana warto�� (dowolna liczba)",                                                                  ; // 3
      "Wybierz dat�",                                                                                          ; // 4
      "Check for true value",                                                                                  ; // 5
      "Wprowad� warto��",                                                                                      ; // 6
      "Wybierz dowolny rekord i naci�cij OK",                                                                  ; // 7
      CRLF + "Wybra�e� opcj� kasowania rekordu   " + CRLF + "Czy jeste� pewien ?    " + CRLF,                  ; // 8
      CRLF + "Brak aktywnych indeks�w   " + CRLF + "Wybierz    " + CRLF,                                       ; // 9
      CRLF + "Nie mo�na szuka� w polach typu MEMO lub LOGIC   " + CRLF,                                        ; // 10
      CRLF + "Rekord nie znaleziony   " + CRLF,                                                                ; // 11
      "Wybierz rekord kt�ry nale�y doda� do listy",                                                            ; // 12
      "Wybierz rekord kt�ry nale�y wy��czy� z listy",                                                          ; // 13
      "Wybierz drukark�",                                                                                      ; // 14
      "Kliknij na przycisk by doda� pole",                                                                     ; // 15
      "Kliknij na przycisk by odj�� pole",                                                                     ; // 16
      "Kliknij, aby wybra� pierwszy rekord do druku",                                                          ; // 17
      "Kliknij, aby wybra� ostatni rekord do druku",                                                           ; // 18
      CRLF + "Brak p�l do w��czenia   " + CRLF,                                                                ; // 19
      CRLF + "Najpierw wybierz pola do w��czenia   " + CRLF,                                                   ; // 20
      CRLF + "Brak p�l do wy��czenia   " + CRLF,                                                               ; // 21
      CRLF + "Najpierw wybierz pola do wy��czenia   " + CRLF,                                                  ; // 22
      CRLF + "Nie wybra�e� �adnych p�l   " + CRLF + "Najpierw wybierz pola do w��czenia do wydruku   " + CRLF, ; // 23
      CRLF + "Za wiele p�l   " + CRLF + "Zredukuj liczb� p�l   " + CRLF,                                       ; // 24
      CRLF + "Drukarka nie gotowa   " + CRLF,                                                                  ; // 25
      "Porz�dek wg",                                                                                           ; // 26
      "Od rekordu",                                                                                            ; // 27
      "Do rekordu",                                                                                            ; // 28
      "Tak",                                                                                                   ; // 29
      "Nie",                                                                                                   ; // 30
      "Strona:",                                                                                               ; // 31
      CRLF + "Wybierz drukark�   " + CRLF,                                                                     ; // 32
      "Filtrowanie wg",                                                                                        ; // 33
      CRLF + "Brak aktywnego filtru    " + CRLF,                                                               ; // 34
      CRLF + "Nie mo�na filtrowa� wg. p�l typu MEMO    " + CRLF,                                               ; // 35
      CRLF + "Wybierz pola dla filtru    " + CRLF,                                                             ; // 36
      CRLF + "Wybierz operator por�wnania dla filtru    " + CRLF,                                              ; // 37
      CRLF + "Wpisz dowoln� warto�� dla filtru    " + CRLF,                                                    ; // 38
      CRLF + "Brak aktywnego filtru    " + CRLF,                                                               ; // 39
      CRLF + "Deaktywowa� filtr?   " + CRLF,                                                                   ; // 40
      CRLF + "Rekord zablokowany przez innego u�ytkownika" + CRLF,                                             ; // 41
      CRLF + "Czy przwr�ci� skasowny   " + CRLF + "Czy jeste� pewien?    " + CRLF                              } // 42

   CASE cLang == "PT"  // Portuguese
      /////////////////////////////////////////////////////////////
      // PORTUGUESE
      ////////////////////////////////////////////////////////////
 
      // MISC MESSAGES
 
      _HMG_MESSAGE [1] := "Voc� tem Certeza ?"
      _HMG_MESSAGE [2] := "Fechar Janela"
      _HMG_MESSAGE [3] := "Fechamento n�o permitido"
      _HMG_MESSAGE [4] := "Programa j� est� em execu��o"
      _HMG_MESSAGE [5] := "Edita"
      _HMG_MESSAGE [6] := "Ok"
      _HMG_MESSAGE [7] := "Cancela"
      _HMG_MESSAGE [8] := "Aplicar"
      _HMG_MESSAGE [9] := "P�g."
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'
 
      // BROWSE
 
      _HMG_BRWLangButton  := { "Incluir"  , ;
         "Alterar"  , ;
         "Cancelar" , ;
         "OK"        }
      _HMG_BRWLangError   := { "Window: "                                         , ;
         " Erro n�o definido. Programa ser� fechado"        , ;
         "Erro na MiniGUI.lib"                              , ;
         "Controle: "                                       , ;
         "Desligado "                                       , ;
         "N�o pronto. Programa ser� fechado"                , ;
         "Browse: Tipo Inv�lido !!!. Programa ser� fechado" , ;
         "Browse: Edi��o n�o pode ser efetivada, campo n�o pertence a essa �rea. Programa ser� fechado" , ;
         "Arquivo em uso n�o pode ser editado !!!"          , ;
         "Aguarde..."                                       , ;
         "Dado Inv�lido"                                     }
      _HMG_BRWLangMessage := { "Voc� tem Certeza ?" , "Apaga Registro" }
 
      // EDIT
 
      _HMG_aABMLangUser   := { Chr( 13 ) + "Ser� apagado o registro atual" + Chr( 13 ) + "Tem certeza ?"                          + Chr( 13 ) , ;
         Chr( 13 ) + "N�o existe um �ndice ativo"    + Chr( 13 ) + "N�o � poss�vel realizar a busca"        + Chr( 13 ) , ;
         Chr( 13 ) + "N�o encontrado o campo �ndice" + Chr( 13 ) + "N�o � poss�vel realizar a busca"        + Chr( 13 ) , ;
         Chr( 13 ) + "N�o � poss�vel realizar busca" + Chr( 13 ) + "por campos memo ou l�gicos"             + Chr( 13 ) , ;
         Chr( 13 ) + "Registro n�o encontrado"       + Chr( 13 )                                                      , ;
         Chr( 13 ) + "Inclu�das colunas em excesso"  + Chr( 13 ) + "A listagem completa n�o caber� na tela" + Chr( 13 )  }
      _HMG_aABMLangLabel  := { "Registro Atual"                 , ;
         "Total Registros"                , ;
         "(Novo)"                         , ;
         "(Editar)"                       , ;
         "Introduza o n�mero do registro" , ;
         "Buscar"                         , ;
         "Texto a buscar"                 , ;
         "Data a buscar"                  , ;
         "N�mero a buscar"                , ;
         "Defini��o da lista"             , ;
         "Colunas da lista"               , ;
         "Colunas dispon�veis"            , ;
         "Registro inicial"               , ;
         "Registro final"                 , ;
         "Lista de "                      , ;
         "Data:"                          , ;
         "Primeiro registro:"             , ;
         "�ltimo registro:"               , ;
         "Ordenado por:"                  , ;
         "Sim"                            , ;
         "N�o"                            , ;
         "P�gina "                        , ;
         " de "                            }
      _HMG_aABMLangButton := { "Fechar"           , ;
         "Novo"             , ;
         "Modificar"        , ;
         "Eliminar"         , ;
         "Buscar"           , ;
         "Ir ao registro"   , ;
         "Listar"           , ;
         "Primeiro"         , ;
         "Anterior"         , ;
         "Seguinte"         , ;
         "�ltimo"           , ;
         "Guardar"          , ;
         "Cancelar"         , ;
         "Juntar"           , ;
         "Sair"             , ;
         "Imprimir"         , ;
         "Fechar"            }
      _HMG_aABMLangError  := { "EDIT, n�o foi especificada a �rea"                                      , ;
         "EDIT, A �rea cont�m mais de 16 campos"                                  , ;
         "EDIT, Atualiza��o fora do limite (por favor, comunique o erro)"         , ;
         "EDIT, Evento principal fora do limite (por favor, comunique o erro)"    , ;
         "EDIT, Evento mostrado est� fora do limite (por favor, comunique o erro)" }
 
      // EDIT EXTENDED
 
      _HMG_aLangButton    := { "&Sair",             ; // 1
      "&Novo",             ; // 2
      "&Alterar",          ; // 3
      "&Eliminar",         ; // 4
      "&Localizar",        ; // 5
      "&Imprimir",         ; // 6
      "&Cancelar",         ; // 7
      "&Aceitar",          ; // 8
      "&Copiar",           ; // 9
      "&Ativar Filtro",    ; // 10
      "&Desativar Filtro", ; // 11
      "&Restaurar"         } // 12
      _HMG_aLangLabel     := {  "Nenhum",                             ; // 1
      "Registro",                           ; // 2
      "Total",                              ; // 3
      "�ndice ativo",                       ; // 4
      "Op��o",                              ; // 5
      "Novo registro",                      ; // 6
      "Modificar registro",                 ; // 7
      "Selecionar registro",                ; // 8
      "Localizar registro",                 ; // 9
      "Op��o de impress�o",                 ; // 10
      "Campos dispon�veis",                 ; // 11
      "Campos selecionados",                ; // 12
      "Impressoras dispon�veis",            ; // 13
      "Primeiro registro a imprimir",       ; // 14
      "�ltimo registro a imprimir",         ; // 15
      "Apagar registro",                    ; // 16
      "Visualizar impress�o",               ; // 17
      "P�ginas em miniatura",               ; // 18
      "Condi��o do filtro: ",               ; // 19
      "Filtrado: ",                         ; // 20
      "Op��es do filtro" ,                  ; // 21
      "Campos da tabela" ,                  ; // 22
      "Operador de compara��o",             ; // 23
      "Valor de compara��o",                ; // 24
      "Selecione o campo a filtrar",        ; // 25
      "Selecione o operador de compara��o", ; // 26
      "Igual",                              ; // 27
      "Diferente",                          ; // 28
      "Maior que",                          ; // 29
      "Menor que",                          ; // 30
      "Maior ou igual que",                 ; // 31
      "Menor ou igual que"                  } // 32
      _HMG_aLangUser      := {  CRLF + "N�o h� uma �rea ativa   "  + CRLF + "Por favor, selecione uma �rea antes de chamar a EDIT EXTENDED   " + CRLF, ; // 1
      "Introduza o valor do campo (texto)",                                                                                  ; // 2
      "Introduza o valor do campo (num�rico)",                                                                               ; // 3
      "Selecione a data",                                                                                                    ; // 4
      "Ative o indicador para valor verdadeiro",                                                                             ; // 5
      "Introduza o valor do campo",                                                                                          ; // 6
      "Selecione um registro e tecle Ok",                                                                                    ; // 7
      CRLF + "Confirma apagar o registro ativo   " + CRLF + "Tem certeza?     " + CRLF,                                      ; // 8
      CRLF + "N�o h� um �ndice selecionado    " + CRLF + "Por favor, selecione um   " + CRLF,                                ; // 9
      CRLF + "N�o se pode realizar busca por campos tipo memo ou l�gico   " + CRLF,                                          ; // 10
      CRLF + "Registro n�o encontrado   " + CRLF,                                                                            ; // 11
      "Selecione o campo a incluir na lista",                                                                                ; // 12
      "Selecione o campo a excluir da lista",                                                                                ; // 13
      "Selecione a impressora",                                                                                              ; // 14
      "Pressione o bot�o para incluir o campo",                                                                              ; // 15
      "Pressione o bot�o para excluir o campo",                                                                              ; // 16
      "Pressione o bot�o para selecionar o primeiro registro a imprimir",                                                    ; // 17
      "Pressione o bot�o para selecionar o �ltimo registro a imprimir",                                                      ; // 18
      CRLF + "Foram inclu�dos todos os campos   " + CRLF,                                                                    ; // 19
      CRLF + "Primeiro seleccione o campo a incluir   " + CRLF,                                                              ; // 20
      CRLF + "N�o h� campos para excluir   " + CRLF,                                                                         ; // 21
      CRLF + "Primeiro selecione o campo a excluir   " + CRLF,                                                               ; // 22
      CRLF + "N�o foi selecionado nenhum campo   " + CRLF,                                                                   ; // 23
      CRLF + "A lista n�o cabe na p�gina   " + CRLF + "Reduza o n�mero de campos   " + CRLF,                                 ; // 24
      CRLF + "A impressora n�o est� dispon�vel   " + CRLF,                                                                   ; // 25
      "Ordenado por",                                                                                                        ; // 26
      "Do registro",                                                                                                         ; // 27
      "At� registro",                                                                                                        ; // 28
      "Sim",                                                                                                                 ; // 29
      "N�o",                                                                                                                 ; // 30
      "P�gina:",                                                                                                             ; // 31
      CRLF + "Por favor, selecione uma impressora   " + CRLF,                                                                ; // 32
      "Filtrado por",                                                                                                        ; // 33
      CRLF + "N�o h� um filtro ativo    " + CRLF,                                                                            ; // 34
      CRLF + "N�o se pode filtrar por campos memo    " + CRLF,                                                               ; // 35
      CRLF + "Selecione o campo a filtrar    " + CRLF,                                                                       ; // 36
      CRLF + "Selecione o operador de compara��o    " + CRLF,                                                                ; // 37
      CRLF + "Introduza o valor do filtro    " + CRLF,                                                                       ; // 38
      CRLF + "N�o h� nenhum filtro ativo    " + CRLF,                                                                        ; // 39
      CRLF + "Eliminar o filtro ativo ?   " + CRLF,                                                                          ; // 40
      CRLF + "Registro bloqueado por outro usu�rio    " + CRLF,                                                              ; // 41
      CRLF + "Voc� vai restabelecer o registro apagado   " + CRLF + "Tem certeza ?    " + CRLF                               } // 42

   CASE cLang == "RU"  // Russian
      /////////////////////////////////////////////////////////////
      // RUSSIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := '�� ������� ?'
      _HMG_MESSAGE [2] := '������� ����'
      _HMG_MESSAGE [3] := '�������� �� �����������'
      _HMG_MESSAGE [4] := '��������� ��� ��������'
      _HMG_MESSAGE [5] := '��������'
      _HMG_MESSAGE [6] := '��'
      _HMG_MESSAGE [7] := '������'
      _HMG_MESSAGE [8] := '���������'
      _HMG_MESSAGE [9] := '���.'
      _HMG_MESSAGE [10] := '��������'
      _HMG_MESSAGE [11] := '����������'
      _HMG_MESSAGE [12] := '����'

      // BROWSE

      _HMG_BRWLangButton := { ;
         "��������" , ;
         "��������" , ;
         "������"   , ;
         "OK" }
      _HMG_BRWLangError  := { ;
         "����: "                                                  , ;
         " �� ����������. ��������� ��������"                      , ;
         "MiniGUI ������"                                          , ;
         "������� ����������: "                                    , ;
         " �� "                                                    , ;
         " ��� ���������. ��������� ��������"                      , ;
         "Browse: ����� ��� �� ��������������. ��������� ��������" , ;
         "Browse: Append ����� �� ����� �������������� � ������ �� ������ ������� �������. ��������� ��������", ;
         "������ ������ ������������� ������ �������������"        , ;
         "��������������"                                          , ;
         "������� ������������ ������" }
      _HMG_BRWLangMessage := { '�� ������� ?' , '������� ������' }

      // EDIT

      _HMG_aABMLangUser := { ;
         Chr( 13 ) + "�������� ������." + Chr( 13 ) + "�� ������� ?" + Chr( 13 )                       , ;
         Chr( 13 ) + "����������� ��������� ����" + Chr( 13 ) + "����� ����������" + Chr( 13 )         , ;
         Chr( 13 ) + "����������� ��������� ����" + Chr( 13 ) + "����� ����������" + Chr( 13 )         , ;
         Chr( 13 ) + "����� ���������� �" + Chr( 13 ) + "����������� ��� ���������� �����" + Chr( 13 ) , ;
         Chr( 13 ) + "������ �� �������" + Chr( 13 )                                                   , ;
         Chr( 13 ) + "������� ����� �������" + Chr( 13 ) + "����� �� ���������� �� �����" + Chr( 13 ) }
      _HMG_aABMLangLabel := { ;
         "������"              , ;
         "����� �������"       , ;
         "     (�����)"        , ;
         "  (��������)"        , ;
         "������� ����� ������", ;
         "�����"               , ;
         "����� �����"         , ;
         "����� ����"          , ;
         "����� �����"         , ;
         "��������� ������"    , ;
         "������� ������"      , ;
         "��������� �������"   , ;
         "��������� ������"    , ;
         "�������� ������"     , ;
         "����� ��� "          , ;
         "����:"               , ;
         "������ ������:"      , ;
         "�������� ������:"    , ;
         "����������� ��:"     , ;
         "��"                  , ;
         "���"                 , ;
         "�������� "           , ;
         " �� "                 }
      _HMG_aABMLangButton := { ;
         "�������"   , ;
         "�����"     , ;
         "��������"  , ;
         "�������"   , ;
         "�����"     , ;
         "�������"   , ;
         "�����"     , ;
         "������"    , ;
         "�����"     , ;
         "������"    , ;
         "���������" , ;
         "���������" , ;
         "������"    , ;
         "��������"  , ;
         "�������"   , ;
         "������"    , ;
         "�������"    }
      _HMG_aABMLangError := { ;
         "EDIT, �� ������� ��� ������� �������"                     , ;
         "EDIT, ����������� �� ����� 16 �����"                      , ;
         "EDIT, ����� ���������� ��� ��������� (�������� �� ������)", ;
         "EDIT, ����� ������� ��� ��������� (�������� �� ������)"   , ;
         "EDIT, ����� ������� �������� ��� ��������� (�������� �� ������)" }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&�������",           ; // 1
         "&�������",           ; // 2
         "&������",            ; // 3
         "&�������",           ; // 4
         "&�����",             ; // 5
         "�&�����",            ; // 6
         "��&����",            ; // 7
         "&��",                ; // 8
         "&�����",             ; // 9
         "&���. ������",       ; // 10
         "�&���� ������",      ; // 11
         "&������������"       } // 12
      _HMG_aLangLabel := { ;
         "���",                          ; // 1
         "������",                       ; // 2
         "�����",                        ; // 3
         "������������",                 ; // 4
         "���������",                    ; // 5
         "����� ������",                 ; // 6
         "�������� ������",              ; // 7
         "������� ������",               ; // 8
         "����� ������",                 ; // 9
         "��������� ������",             ; // 10
         "��������� ����",               ; // 11
         "���� ��� ������",              ; // 12
         "��������� ��������",           ; // 13
         "������ ������ � ������",       ; // 14
         "��������� ������ �������",     ; // 15
         "������� ������",               ; // 16
         "��������",                     ; // 17
         "�������� ��������",            ; // 18
         "������� �������: ",            ; // 19
         "������: ",                     ; // 20
         "��������� �������" ,           ; // 21
         "���� ���� ������" ,            ; // 22
         "��������� ���������",          ; // 23
         "�������� �������",             ; // 24
         "����� ���� ��� �������",       ; // 25
         "����� ��������� ���������",    ; // 26
         "�����",                        ; // 27
         "�� �����",                     ; // 28
         "������",                       ; // 29
         "������",                       ; // 30
         "������ ��� �����",             ; // 31
         "������ ��� �����"           }    // 32
      _HMG_aLangUser := { ;
         CRLF + "�� ���������� �������� �������."  + CRLF + "�������� ����� ������� ����� ���������� � EDIT" + CRLF, ; // 1
         "������� ��������� ��������",                                                                               ; // 2
         "������� �����",                                                                                            ; // 3
         "������� ����",                                                                                             ; // 4
         "���������� ��������",                                                                                      ; // 5
         "������� �������� ����",                                                                                    ; // 6
         "�������� ����� ������ � ������� OK",                                                                       ; // 7
         CRLF + "������� ������ ����� ������� " + CRLF + "���������� ?    " + CRLF,                                  ; // 8
         CRLF + "��� ������������ " + CRLF + "�������� ���� �� ������������ " + CRLF,                                ; // 9
         CRLF + "����� � ����� ���������� � ���������� ����� �� ����������� " + CRLF,                                ; // 10
         CRLF + "������ �� �������  " + CRLF,                                                                        ; // 11
         "���� ��� ��������� � ������ ������",                                                                       ; // 12
         "������ ����� ��� ������",                                                                                  ; // 13
         "����� ��������",                                                                                           ; // 14
         "������� ��� �������� ���� � ������ ������",                                                                ; // 15
         "������� ��� ���������� ���� �� ������ ������",                                                             ; // 16
         "������, � ������� ���������� ������",                                                                      ; // 17
         "������, �� ������� ����������� ������",                                                                    ; // 18
         CRLF + "���������� ����� ��� " + CRLF,                                                                      ; // 19
         CRLF + "������ ���� �� ��������� " + CRLF,                                                                  ; // 20
         CRLF + "����������� ����� ��� " + CRLF,                                                                     ; // 21
         CRLF + "������ ���� �� ���������� " + CRLF,                                                                 ; // 22
         CRLF + "��� ��������� ����� " + CRLF + "����������� ������ ��� ������ " + CRLF,                             ; // 23
         CRLF + "������� ����� ����� " + CRLF + "��������� �� ���������� " + CRLF,                                   ; // 24
         CRLF + "������� �� �����  " + CRLF,                                                                         ; // 25
         "������������ ",                                                                                            ; // 26
         "�� ������ ",                                                                                               ; // 27
         "�� ������ ",                                                                                               ; // 28
         "��",                                                                                                       ; // 29
         "���",                                                                                                      ; // 30
         "��������:",                                                                                                ; // 31
         CRLF + "�������� �������  " + CRLF,                                                                         ; // 32
         "������������� ��",                                                                                         ; // 33
         CRLF + "��� �� �������� ������    " + CRLF,                                                                 ; // 34
         CRLF + "���� ���������� �� �����������  " + CRLF,                                                           ; // 35
         CRLF + "�������� ���� ��� �������    " + CRLF,                                                              ; // 36
         CRLF + "�������� ����� �������� ��� �������" + CRLF,                                                        ; // 37
         CRLF + "�������� ����� �������� ��� �������" + CRLF,                                                        ; // 38
         CRLF + "��� �������� ��������   " + CRLF,                                                                   ; // 39
         CRLF + "����� ������ ?   " + CRLF,                                                                          ; // 40
         CRLF + "������ ����������� ������ ������������� " + CRLF,                                                   ; // 41
         CRLF + "������� ������ ����� ������������� " + CRLF + "���������� ?    " + CRLF                             } // 42

   CASE cLang == "UK" .OR. cLang == "UA"  // Ukrainian
      /////////////////////////////////////////////////////////////
      // UKRAINIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE[ 1 ] := '�� �������i ?'
      _HMG_MESSAGE[ 2 ] := '������� �i���.'
      _HMG_MESSAGE[ 3 ] := '�������� �� ������������.'
      _HMG_MESSAGE[ 4 ] := ( '�������� ����������.' + CRLF + '������ �� ���i�� ���i� ����������.' )
      _HMG_MESSAGE[ 5 ] := '��i����'
      _HMG_MESSAGE[ 6 ] := '������'
      _HMG_MESSAGE[ 7 ] := '���������'
      _HMG_MESSAGE[ 8 ] := '�����������'
      _HMG_MESSAGE[ 9 ] := '����.'
      _HMG_MESSAGE [10] := '�����!'
      _HMG_MESSAGE [11] := 'I���������'
      _HMG_MESSAGE [12] := '����'

      // BROWSE

      _HMG_BRWLangButton := { "������"    , ;
         "��i����"   , ;
         "���������" , ;
         "������"    }
      _HMG_BRWLangError  := { "�i���: "                                              , ;
         " �� ���������. �������� ��������"                        , ;
         "MiniGUI �������"                                         , ;
         "������� ������i���: "                                    , ;
         " � "                                                     , ;
         " ��� ����������. �������� ��������"                      , ;
         "Browse: ����� ��� �� �i����������. �������� ��������"   , ;
         "Browse: Append ���� �� ��������������� � ������ i��� ������ ������i. �������� ��������", ;
         "����� ����� ���������� i���� ������������"              , ;
         "������������"                                            , ;
         "������� ��������i ���i"                                 }
      _HMG_BRWLangMessage := { '�� �������i ?' , '�������� �����' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "��������� ������." + Chr( 13 ) + "�� �������i ?" + Chr( 13 )             , ;
         Chr( 13 ) + "�i�����i� i�������� ����" + Chr( 13 ) + "����� ����������" + Chr( 13 )       , ;
         Chr( 13 ) + "�i����� i������� ����" + Chr( 13 ) + "����� ����������" + Chr( 13 )         , ;
         Chr( 13 ) + "����� ���������� �" + Chr( 13 ) + "����i���� ��� ���i���� �����" + Chr( 13 ) , ;
         Chr( 13 ) + "����� �� ��������" + Chr( 13 )                                         , ;
         Chr( 13 ) + "������� ������ �������" + Chr( 13 ) + "��i� �� ����i������� �� �����i" + Chr( 13 ) }
      _HMG_aABMLangLabel  := { "�����"           , ;
         "������ �����i�"      , ;
         "     (����)"         , ;
         "  (��i����)"         , ;
         "����i�� ����� ������", ;
         "�����"               , ;
         "������ �����"        , ;
         "������ ����"         , ;
         "������ �����"        , ;
         "������������ ��i��"  , ;
         "������� ��i��"       , ;
         "�������i �������"    , ;
         "���������� �����"    , ;
         "�������� �����"      , ;
         "��i� ��� "           , ;
         "����:"               , ;
         "������ �����:"       , ;
         "�������� �����:"     , ;
         "���������� ��:"      , ;
         "���"                 , ;
         "�i"                  , ;
         "����i��� "           , ;
         " � "                  }
      _HMG_aABMLangButton := { "�������", ;
         "����"       , ;
         "��i����"    , ;
         "��������"   , ;
         "�����"      , ;
         "�������"    , ;
         "��i�"       , ;
         "�����"      , ;
         "�����"      , ;
         "������"     , ;
         "�������"    , ;
         "��������"   , ;
         "�i�����"    , ;
         "������"     , ;
         "��������"   , ;
         "����"       , ;
         "�������"     }
      _HMG_aABMLangError  := { "EDIT, �� ������� i�'� ������ ������i"                    , ;
         "EDIT, ������������ �� �i���� 16 ���i�"                        , ;
         "EDIT, ����� ��������� ���� �i�������� (���i������ ��� �������)", ;
         "EDIT, ����� ���i� ���� �i�������� (���i������ ��� �������)"    , ;
         "EDIT, ����� ���i� �i������ ���� �i�������� (���i������ ��� �������)" }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&�������",           ; // 1
      "&��������",          ; // 2
      "&������",            ; // 3
      "&��������",          ; // 4
      "�&�����",            ; // 5
      "&����",              ; // 6
      "�&��������",         ; // 7
      "&������",            ; // 8
      "&���i�",             ; // 9
      "���. &�i����",       ; // 10
      "���&�� �i����",      ; // 11
      "³�&������"     }      // 12
      _HMG_aLangLabel := {                   ;
         "�i",                              ; // 1
      "�����",                           ; // 2
      "������",                          ; // 3
      "�������������",                   ; // 4
      "���������",                       ; // 5
      "����� �����",                     ; // 6
      "��i���� �����",                   ; // 7
      "������� �����",                   ; // 8
      "������ �����",                    ; // 9
      "��������� �����",                 ; // 10
      "�������i ����",                   ; // 11
      "���� ��� �����",                  ; // 12
      "�������i ��������",               ; // 13
      "��������� ���� � ������",         ; // 14
      "��������� ���� �������",          ; // 15
      "�������� �����",                  ; // 16
      "��������",                        ; // 17
      "����i��� �i�i����",               ; // 18
      "����� �i�����: ",                 ; // 19
      "�i����: ",                        ; // 20
      "��������� �i�����" ,              ; // 21
      "���� ���� �����" ,                ; // 22
      "��������� ��i����������",         ; // 23
      "�������� �i�����",                ; // 24
      "���i� ���� ��� �������",          ; // 25
      "���i� ��������� ��i����������",   ; // 26
      "���i����",                        ; // 27
      "�� ���i����",                     ; // 28
      "�i����",                          ; // 29
      "�����",                           ; // 30
      "�i���� ��� ���i����",             ; // 31
      "����� ��� ���i����"           }     // 32
      _HMG_aLangUser := { ;
         CRLF + "�� �������� ������� ������i."  + CRLF + "����i�� ����-��� ������� ����� ���������� �� EDIT" + CRLF, ; // 1
      "����i�� �������� ��������",                                                                                 ; // 2
      "����i�� �����",                                                                                             ; // 3
      "����i�� ����",                                                                                              ; // 4
      "���i��� ��������",                                                                                          ; // 5
      "����i�� �������� ����",                                                                                     ; // 6
      "����i�� ����-���� ����� i ������i�� OK",                                                                    ; // 7
      CRLF + "�������� ����� ���� �������� " + CRLF + "���������� ?    " + CRLF,                                   ; // 8
      CRLF + "�i����� ������������ " + CRLF + "����i�� ���� � i������� " + CRLF,                                  ; // 9
      CRLF + "����� � ����� ����i��� i ���i���� ����� �� ���������� " + CRLF,                                     ; // 10
      CRLF + "����� �� ��������  " + CRLF,                                                                         ; // 11
      "����, �������i ��� �����",                                                                                  ; // 12
      "������ ���i� ��� �����",                                                                                    ; // 13
      "���i� ��������",                                                                                            ; // 14
      "������i�� ��� ����������� ���� � ������ �����",                                                             ; // 15
      "������i�� ��� ��������� ���� � ������ �����",                                                               ; // 16
      "�����, � ����� ������������� ����",                                                                        ; // 17
      "�����, ���� ����������� ����",                                                                             ; // 18
      CRLF + "�i�����i �������i ���� " + CRLF,                                                                     ; // 19
      CRLF + "����� ���� �� ��������� " + CRLF,                                                                    ; // 20
      CRLF + "�i�����i ���� ��� ���������� " + CRLF,                                                               ; // 21
      CRLF + "����� ���� ��� ��������� " + CRLF,                                                                   ; // 22
      CRLF + "�i�����i ������i ���� " + CRLF + "��������� ������ ��� ����� " + CRLF,                               ; // 23
      CRLF + "������� ������ ���i� " + CRLF + "�����i�� �� �i���i��� " + CRLF,                                     ; // 24
      CRLF + "������� �� �i��������� " + CRLF,                                                                     ; // 25
      "������������� ",                                                                                            ; // 26
      "�i� ������ ",                                                                                               ; // 27
      "�� ������ ",                                                                                                ; // 28
      "���",                                                                                                       ; // 29
      "�i",                                                                                                        ; // 30
      "����i���:",                                                                                                 ; // 31
      CRLF + "�����i�� �������  " + CRLF,                                                                          ; // 32
      "�i��i��������� ��",                                                                                         ; // 33
      CRLF + "�� �� �������� �i����   " + CRLF,                                                                    ; // 34
      CRLF + "���� ����i��� �� �i����������  " + CRLF,                                                             ; // 35
      CRLF + "����i�� ���� ��� �i�����    " + CRLF,                                                                ; // 36
      CRLF + "����i�� �������� ��� �i�����" + CRLF,                                                                ; // 37
      CRLF + "����i�� �������� ��� �i�����" + CRLF,                                                                ; // 38
      CRLF + "�i�����i ������i �i�����   " + CRLF,                                                                 ; // 39
      CRLF + "����� �i���� ?   " + CRLF,                                                                           ; // 40
      CRLF + "����� ����������� i���� ������������ " + CRLF,                                                       ; // 41
      CRLF + "�������� ����� ���� ��������� " + CRLF + "���������� ?    " + CRLF                                  } // 42

   CASE cLang == "ES"  // Spanish
      /////////////////////////////////////////////////////////////
      // SPANISH
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Est� seguro ?'
      _HMG_MESSAGE [2] := 'Cerrar Ventana'
      _HMG_MESSAGE [3] := 'Operaci�n no permitida'
      _HMG_MESSAGE [4] := 'EL programa ya est� ejecut�ndose'
      _HMG_MESSAGE [5] := 'Editar'
      _HMG_MESSAGE [6] := 'Aceptar'
      _HMG_MESSAGE [7] := 'Cancelar'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Pag.'
      _HMG_MESSAGE [10] := 'Atencion'
      _HMG_MESSAGE [11] := 'Informaci�n'
      _HMG_MESSAGE [12] := 'Detener'

      // BROWSE  

      _HMG_BRWLangButton := { "Agregar"    , ;
         "Editar"     , ;
         "Cancelar"   , ;
         "Aceptar"     }
      _HMG_BRWLangError  := { "Window: "                                              , ;
         " no est� definida. Ejecuci�n terminada"                , ;
         "MiniGUI Error"                                         , ;
         "Control: "                                             , ;
         " De "                                                  , ;
         " ya definido. Ejecuci�n terminada"                     , ;
         "Browse: Tipo no permitido. Ejecuci�n terminada"        , ;
         "Browse: La calusula APPEND no puede ser usada con campos no pertenecientes al area del BROWSE. Ejecuci�n terminada", ;
         "El registro est� siendo editado por otro usuario"      , ;
         "Peligro"                                               , ;
         "Entrada no v�lida"                                      }
      _HMG_BRWLangMessage := { 'Est� Seguro ?' , 'Eliminar Registro' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Va a eliminar el registro actual" + Chr( 13 ) + "� Est� seguro ?" + Chr( 13 )                 , ;
         Chr( 13 ) + "No hay un indice activo" + Chr( 13 ) + "No se puede realizar la busqueda" + Chr( 13 )         , ;
         Chr( 13 ) + "No se encuentra el campo indice" + Chr( 13 ) + "No se puede realizar la busqueda" + Chr( 13 ) , ;
         Chr( 13 ) + "No se pueden realizar busquedas" + Chr( 13 ) + "por campos memo o l�gico" + Chr( 13 )         , ;
         Chr( 13 ) + "Registro no encontrado" + Chr( 13 )                                                     , ;
         Chr( 13 ) + "Ha inclido demasiadas columnas" + Chr( 13 ) + "El listado no cabe en la hoja" + Chr( 13 )      }
      _HMG_aABMLangLabel  := { "Registro Actual"                  , ;
         "Registros Totales"                , ;
         "     (Nuevo)"                     , ;
         "    (Editar)"                     , ;
         "Introducca el n�mero de registro" , ;
         "Buscar"                           , ;
         "Texto a buscar"                   , ;
         "Fecha a buscar"                   , ;
         "N�mero a buscar"                  , ;
         "Definici�n del listado"           , ;
         "Columnas del listado"             , ;
         "Columnas disponibles"             , ;
         "Registro inicial"                 , ;
         "Registro final"                   , ;
         "Listado de "                      , ;
         "Fecha:"                           , ;
         "Primer registro:"                 , ;
         "Ultimo registro:"                 , ;
         "Ordenado por:"                    , ;
         "Si"                               , ;
         "No"                               , ;
         "Pagina "                          , ;
         " de "                              }
      _HMG_aABMLangButton := { "Cerrar"           , ;
         "Nuevo"            , ;
         "Modificar"        , ;
         "Eliminar"         , ;
         "Buscar"           , ;
         "Ir al registro"   , ;
         "Listado"          , ;
         "Primero"          , ;
         "Anterior"         , ;
         "Siguiente"        , ;
         "Ultimo"           , ;
         "Guardar"          , ;
         "Cancelar"         , ;
         "A�adir"           , ;
         "Quitar"           , ;
         "Imprimir"         , ;
         "Cerrar"            }
      _HMG_aABMLangError  := { "EDIT, No se ha especificado el area"                                  , ;
         "EDIT, El area contiene m�s de 16 campos"                              , ;
         "EDIT, Refesco fuera de rango (por favor comunique el error)"          , ;
         "EDIT, Evento principal fuera de rango (por favor comunique el error)" , ;
         "EDIT, Evento listado fuera de rango (por favor comunique el error)"    }

      // EDIT EXTENDED

      _HMG_aLangButton := {            ;
         "&Cerrar",           ; // 1
      "&Nuevo",            ; // 2
      "&Modificar",        ; // 3
      "&Eliminar",         ; // 4
      "&Buscar",           ; // 5
      "&Imprimir",         ; // 6
      "&Cancelar",         ; // 7
      "&Aceptar",          ; // 8
      "&Copiar",           ; // 9
      "&Activar Filtro",   ; // 10
      "&Desactivar Filtro", ; // 11
      "&Restaurar"         } // 12

      _HMG_aLangLabel := {                                 ;
         "Ninguno",                               ; // 1
      "Registro",                              ; // 2
      "Total",                                 ; // 3
      "Indice activo",                         ; // 4
      "Opciones",                              ; // 5
      "Nuevo registro",                        ; // 6
      "Modificar registro",                    ; // 7
      "Seleccionar registro",                  ; // 8
      "Buscar registro",                       ; // 9
      "Opciones de impresi�n",                 ; // 10
      "Campos disponibles",                    ; // 11
      "Campos del listado",                    ; // 12
      "Impresoras disponibles",                ; // 13
      "Primer registro a imprimir",            ; // 14
      "Ultimo registro a imprimir",            ; // 15
      "Borrar registro",                       ; // 16
      "Vista previa",                          ; // 17
      "P�ginas en miniatura",                  ; // 18
      "Condici�n del filtro: ",                ; // 19
      "Filtrado: ",                            ; // 20
      "Opciones de filtrado" ,                 ; // 21
      "Campos de la bdd" ,                     ; // 22
      "Operador de comparaci�n",               ; // 23
      "Valor de comparaci�n",                  ; // 24
      "Seleccione el campo a filtrar",         ; // 25
      "Seleccione el operador de comparaci�n", ; // 26
      "Igual",                                 ; // 27
      "Distinto",                              ; // 28
      "Mayor que",                             ; // 29
      "Menor que",                             ; // 30
      "Mayor o igual que",                     ; // 31
      "Menor o igual que"                      } // 32
      _HMG_aLangUser := { ;
         CRLF + "No hay un area activa   "  + CRLF + "Por favor seleccione un area antes de llamar a EDIT EXTENDED   " + CRLF,       ; // 1
      "Introduzca el valor del campo (texto)",                                                                                      ; // 2
      "Introduzca el valor del campo (num�rico)",                                                                                    ; // 3
      "Seleccione la fecha",                                                                                                      ; // 4
      "Active la casilla para indicar un valor verdadero",                                                                                                 ; // 5
      "Introduzca el valor del campo",                                                                                                ; // 6
      "Seleccione un registro y pulse aceptar",                                                                                       ; // 7
      CRLF + "Se dispone a borrar el registro activo   " + CRLF + "�Esta seguro?    " + CRLF,                  ; // 8
      CRLF + "No se ha seleccionado un indice   " + CRLF + "Por favor seleccione uno   " + CRLF,                            ; // 9
      CRLF + "No se pueden realizar busquedad por campos tipo memo o l�gico   " + CRLF,                                                   ; // 10
      CRLF + "Registro no encontrado   " + CRLF,                                                                            ; // 11
      "Seleccione el campo a incluir en el listado",                                                                                  ; // 12
      "Seleccione el campo a excluir del listado",                                                                                ; // 13
      "Seleccione la impresora",                                                                                                   ; // 14
      "Pulse el bot�n para incluir el campo",                                                                                         ; // 15
      "Pulse el bot�n para excluir el campo",                                                                                         ; // 16
      "Pulse el bot�n para seleccionar el primer registro a imprimir",                                                                      ; // 17
      "Pulse el bot�n para seleccionar el �ltimo registro a imprimir",                                                                       ; // 18
      CRLF + "Ha incluido todos los campos   " + CRLF,                                                                   ; // 19
      CRLF + "Primero seleccione el campo a incluir   " + CRLF,                                                           ; // 20
      CRLF + "No hay campos para excluir   " + CRLF,                                                                    ; // 21
      CRLF + "Primero seleccione el campo a excluir   " + CRLF,                                                            ; // 22
      CRLF + "No ha seleccionado ning�n campo   " + CRLF,                                              ; // 23
      CRLF + "El listado no cabe en la p�gina   " + CRLF + "Reduzca el numero de campos   " + CRLF,                                   ; // 24
      CRLF + "La impresora no est� disponible   " + CRLF,                                                                           ; // 25
      "Ordenado por",                                                                                                           ; // 26
      "Del registro",                                                                                                          ; // 27
      "Al registro",                                                                                                            ; // 28
      "Si",                                                                                                                  ; // 29
      "No",                                                                                                                   ; // 30
      "P�gina:",                                                                                                                ; // 31
      CRLF + "Por favor seleccione una impresora   " + CRLF,                                                                     ; // 32
      "Filtrado por",                                                                                                          ; // 33
      CRLF + "No hay un filtro activo    " + CRLF,                                                                  ; // 34
      CRLF + "No se puede filtrar por campos memo    " + CRLF,                                                                ; // 35
      CRLF + "Seleccione el campo a filtrar    " + CRLF,                                                                 ; // 36
      CRLF + "Seleccione el operador de comparaci�n    " + CRLF,                                                              ; // 37
      CRLF + "Introduzca el valor del filtro    " + CRLF,                                                                 ; // 38
      CRLF + "No hay ning�n filtro activo    " + CRLF,                                                              ; // 39
      CRLF + "�Eliminar el filtro activo?   " + CRLF,                                                                           ; // 40
      CRLF + "Registro bloqueado por otro usuario    " + CRLF,                                                                   ; // 41
      CRLF + "Se dispone a restaurar el registro suprimido   " + CRLF + "�Esta seguro?    " + CRLF,                  } // 42

   CASE cLang == "FI"  // Finnish
      ///////////////////////////////////////////////////////////////////////
      // FINNISH
      ///////////////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Oletko varma ?'
      _HMG_MESSAGE [2] := 'Sulje ikkuna'
      _HMG_MESSAGE [3] := 'Sulkeminen ei sallittu'
      _HMG_MESSAGE [4] := 'Ohjelma on jo k�ynniss�'
      _HMG_MESSAGE [5] := 'Korjaa'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Keskeyt�'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Sivu.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Lis��"  , ;
         "Korjaa" , ;
         " Keskeyt�" , ;
         " OK" }

      _HMG_BRWLangError  := { "Ikkuna: " , ;
         " m��rittelem�t�n. Ohjelma lopetettu" , ;
         "MiniGUI Virhe", ;
         "Kontrolli: ", ;
         " / " , ;
         " On jo m��ritelty. Ohjelma lopetettu" , ;
         "Browse: Virheellinen tyyppi. Ohjelma lopetettu" , ;
         "Browse: Et voi lis�t� kentti� jotka eiv�t ole BROWSEN m��rityksess�. Ohjelma lopetettu", ;
         "Toinen k�ytt�j� korjaa juuri tietuetta" , ;
         "Varoitus" , ;
         "Virheellinen arvo" }

      _HMG_BRWLangMessage := { 'Oletko varma ?' , 'Poista tietue' }

      // EDIT
      _HMG_aABMLangUser   := { Chr( 13 ) + "Poista tietue" + Chr( 13 ) + "Oletko varma?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Indeksi tiedosto puuttuu" + Chr( 13 ) + "En voihakea" + Chr( 13 )            , ;
         Chr( 13 ) + "Indeksikentt� ei l�ydy" + Chr( 13 ) + "En voihakea" + Chr( 13 )        , ;
         Chr( 13 ) + "En voi hakea memo" + Chr( 13 ) + "tai loogisen kent�n mukaan" + Chr( 13 )       , ;
         Chr( 13 ) + "Tietue ei l�ydy" + Chr( 13 ), ;
         Chr( 13 ) + "Liian monta saraketta" + Chr( 13 ) + "raportti ei mahdu sivulle" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Tietue"              , ;
         "Tietue lukum��r�"    , ;
         "       (Uusi)"       , ;
         "      (Korjaa)"      , ;
         "Anna tietue numero"  , ;
         "Hae"                 , ;
         "Hae teksti"          , ;
         "Hae p�iv�ys"         , ;
         "Hae numero"          , ;
         "Raportti m��ritys"   , ;
         "Raportti sarake"     , ;
         "Sallitut sarakkeet"  , ;
         "Alku tietue"         , ;
         "Loppu tietue"        , ;
         "Raportti "           , ;
         "Pvm:"                , ;
         "Alku tietue:"        , ;
         "Loppu tietue:"       , ;
         "Lajittelu:"         , ;
         "Kyll�"                 , ;
         "Ei"                  , ;
         "Sivu "               , ;
         " / "                 }

      _HMG_aABMLangButton := { "Sulje"    , ;
         "Uusi"     , ;
         "Korjaa"   , ;
         "Poista"   , ;
         "Hae"      , ;
         "Mene"     , ;
         "Raportti" , ;
         "Ensimm�inen" , ;
         "Edellinen"   , ;
         "Seuraava"    , ;
         "Viimeinen"   , ;
         "Tallenna"    , ;
         "Keskeyt�"    , ;
         "Lis��"       , ;
         "Poista"      , ;
         "Tulosta"     , ;
         "Sulje"     }
      _HMG_aABMLangError  := { "EDIT, ty�alue puuttuu"   , ;
         "EDIT, ty�alueella yli 16 kentt��", ;
         "EDIT, p�ivitysalue ylitys (raportoi virhe)"      , ;
         "EDIT, tapahtuma numero ylitys (raportoi virhe)" , ;
         "EDIT, lista tapahtuma numero ylitys (raportoi virhe)" }

      // EDIT EXTENDED

      _HMG_aLangButton := {            ;
         " Sulje",            ; // 1
      " Uusi",             ; // 2
      " Muuta",            ; // 3
      " Poista",           ; // 4
      " Hae",              ; // 5
      " Tulosta",          ; // 6
      " Keskeyt�",         ; // 7
      " Ok",               ; // 8
      " Kopioi",           ; // 9
      " Aktivoi suodin",   ; // 10
      " Deaktivoi suodin", ; // 11
      " Restore"           } // 12

      _HMG_aLangLabel := {                        ;
         "Ei mit��n",                         ; // 1
      "Tietue",                       ; // 2
      "Yhteens�",                        ; // 3
      "Aktiivinen lajittelu",                 ; // 4
      "Optiot",                      ; // 5
      "Uusi tietue",                   ; // 6
      "Muuta tietue",                ; // 7
      "Valitse tietue",                ; // 8
      "Hae tietue",                  ; // 9
      "Tulostus optiot",                ; // 10
      "Valittavat kent�t",               ; // 11
      "Tulostettavat kent�t",              ; // 12
      "Valittavat tulostimet",           ; // 13
      "Ensim. tulostettava tietue",        ; // 14
      "Viim. tulostettava tietue",         ; // 15
      "Poista tietue",                ; // 16
      "Esikatselu",                      ; // 17
      "N�yt� sivujen miniatyyrit",         ; // 18
      "Suodin ehto: ",           ; // 19
      "Suodatettu: ",                   ; // 20
      "Suodatus Optiot" ,           ; // 21
      "Tietokanta kent�t" ,             ; // 22
      "Vertailu operaattori",        ; // 23
      "Suodatus arvo",                 ; // 24
      "Valitse suodatus kentt�",       ; // 25
      "Valitse vertailu operaattori", ; // 26
      "Yht� kuin",                        ; // 27
      "Erisuuri kuin",                    ; // 28
      "Isompi kuin",                 ; // 29
      "Pienempi kuin",                   ; // 30
      "Isompi tai sama kuin",        ; // 31
      "Pienempi tai sama kuin"           } // 32

      _HMG_aLangUser := { ;
         CRLF + "Ty�alue ei l�ydy.   "  + CRLF + "Valitse ty�aluetta ennenkun kutsut Edit  " + CRLF,       ; // 1
      "Anna kentt� arvo (teksti�)",                                  ; // 2
      "Anna kentt� arvo (numeerinen)",                                  ; // 3
      "Valitse p�iv�ys",                            ; // 4
      "Tarkista tosi arvo",                     ; // 5
      "Anna kentt� arvo",                    ; // 6
      "Valitse joku tietue ja paina OK",                                     ; // 7
      CRLF + "Olet poistamassa aktiivinen tietue   " + CRLF + "Oletko varma?    " + CRLF,                  ; // 8
      CRLF + "Ei aktiivista lajittelua   " + CRLF + "Valitse lajittelu   " + CRLF,                            ; // 9
      CRLF + "En voi hakea memo tai loogiseten kenttien perusteella  " + CRLF, ; // 10
      CRLF + "Tietue ei l�ydy   " + CRLF,                                                ; // 11
      "Valitse listaan lis�tt�v�t kent�t",                                                    ; // 12
      "Valitse EI lis�tt�v�t kent�t",                                        ; // 13
      "Valitse tulostin",                   ; // 14
      "Paina n�pp�in lis��t�ksesi kentt�",                                                                  ; // 15
      "Paina n�pp�in poistaaksesi kentt�",                                                       ; //16
      "Paina n�pp�in valittaaksesi ensimm�inen tulostettava tietue",  ; // 17
      "Paina n�pp�in valittaaksesi viimeinen tulostettava tietue",   ; // 18
      CRLF + "Ei lis�� kentti�   " + CRLF,                                 ; // 19
      CRLF + "Valitse ensin lis�tt�v� kentt�   " + CRLF,                                                           ; //20
      CRLF + "EI Lis�� ohitettavia kentti�   " + CRLF, ; // 21
      CRLF + "Valitse ensin ohitettava kentt�   " + CRLF,                                                            ;//22
      CRLF + "Et valinnut kentti�   " + CRLF + "Valitse tulosteen kent�t   " + CRLF,   ; // 23
      CRLF + "Liikaa kentti�   " + CRLF + "V�henn� kentt� lukum��r�   " + CRLF, ; // 24
      CRLF + "Tulostin ei valmiina   " + CRLF,                                                  ; // 25
      "Lajittelu",             ; // 26
      "Tietueesta",              ; // 27
      "Tietueeseen",                  ; // 28
      "Kyll�",                ; // 29
      "EI",       ; // 30
      "Sivu:",          ; // 31
      CRLF + "Valitse tulostin   " + CRLF,                                       ; // 32
      "Lajittelu",            ; // 33
      CRLF + "Aktiivinen suodin olemassa    " + CRLF,                                                          ; // 34
      CRLF + "En voi suodattaa memo kentti�    " + CRLF, ;// 35
      CRLF + "Valitse suodattava kentt�    " + CRLF,                                                           ; // 36
      CRLF + "Valitse suodatus operaattori    " + CRLF,                                                             ; //37
      CRLF + "Anna suodatusarvo    " + CRLF,                                         ; // 38
      CRLF + "Ei aktiivisia suotimia    " + CRLF,                                              ; // 39
      CRLF + "Poista suodin?   " + CRLF,                                        ; // 40
      CRLF + "Tietue lukittu    " + CRLF,                                                              ; // 41
      CRLF + "Palautatko poistetun tietueen   " + CRLF + "Oletko varma?    " + CRLF  } // 42

   CASE cLang == "NL"  // Dutch
      /////////////////////////////////////////////////////////////
      // DUTCH
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Weet u het zeker?'
      _HMG_MESSAGE [2] := 'Sluit venster'
      _HMG_MESSAGE [3] := 'Sluiten niet toegestaan'
      _HMG_MESSAGE [4] := 'Programma is al actief'
      _HMG_MESSAGE [5] := 'Bewerken'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Annuleren'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Pag.'
      _HMG_MESSAGE [10] := 'Aandacht'
      _HMG_MESSAGE [11] := 'Informatie'
      _HMG_MESSAGE [12] := 'Hou op'

      // BROWSE

      _HMG_BRWLangButton := { "Toevoegen"  , ;
         "Bewerken"      , ;
         "&Annuleer"     , ;
         "&OK"           }
      _HMG_BRWLangError  := { "Scherm: ", ;
         " is niet gedefinieerd. Programma be�indigd"           , ;
         "MiniGUI fout", ;
         "Control: ", ;
         " Van ", ;
         " Is al gedefinieerd. Programma be�indigd"                   , ;
         "Browse: Type niet toegestaan. Programma be�indigd"          , ;
         "Browse: Toevoegen-methode kan niet worden gebruikt voor velden die niet bij het Browse werkgebied behoren. Programma be�indigd", ;
         "Regel word al veranderd door een andere gebruiker"          , ;
         "Waarschuwing"                                               , ;
         "Onjuiste invoer"                                            }

      _HMG_BRWLangMessage := { 'Weet u het zeker?' , 'Verwijder regel' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Verwijder regel" + Chr( 13 ) + "Weet u het zeker ?" + Chr( 13 )    , ;
         Chr( 13 ) + "Index bestand is er niet" + Chr( 13 ) + "Kan niet zoeken" + Chr( 13 )          , ;
         Chr( 13 ) + "Kan index veld niet vinden" + Chr( 13 ) + "Kan niet zoeken" + Chr( 13 )        , ;
         Chr( 13 ) + "Kan niet zoeken op" + Chr( 13 ) + "Memo of logische velden" + Chr( 13 )        , ;
         Chr( 13 ) + "Regel niet gevonden" + Chr( 13 ) , ;
         Chr( 13 ) + "Te veel rijen" + Chr( 13 ) + "Het rapport past niet op het papier" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Regel"     , ;
         "Regel aantal"          , ;
         "       (Nieuw)"        , ;
         "      (Bewerken)"      , ;
         "Geef regel nummer"     , ;
         "Vind"                  , ;
         "Zoek tekst"            , ;
         "Zoek datum"            , ;
         "Zoek nummer"           , ;
         "Rapport definitie"     , ;
         "Rapport rijen"         , ;
         "Beschikbare rijen"     , ;
         "Eerste regel"          , ;
         "Laatste regel"         , ;
         "Rapport van "          , ;
         "Datum:"                , ;
         "Eerste regel:"         , ;
         "Laatste tegel:"        , ;
         "Gesorteerd op:"        , ;
         "Ja"                    , ;
         "Nee"                   , ;
         "Pagina "               , ;
         " van "                 }

      _HMG_aABMLangButton := { "Sluiten"   , ;
         "Nieuw"                 , ;
         "Bewerken"              , ;
         "Verwijderen"           , ;
         "Vind"                  , ;
         "Ga naar"               , ;
         "Rapport"               , ;
         "Eerste"                , ;
         "Vorige"                , ;
         "Volgende"              , ;
         "Laatste"               , ;
         "Bewaar"                , ;
         "Annuleren"             , ;
         "Voeg toe"              , ;
         "Verwijder"             , ;
         "Print"                 , ;
         "Sluiten"               }
      _HMG_aABMLangError  := { "BEWERKEN, werkgebied naam bestaat niet", ;
         "BEWERKEN, dit werkgebied heeft meer dan 16 velden", ;
         "BEWERKEN, ververs manier buiten bereik (a.u.b. fout melden)"           , ;
         "BEWERKEN, hoofd gebeurtenis nummer buiten bereik (a.u.b. fout melden)" , ;
         "BEWERKEN, list gebeurtenis nummer buiten bereik (a.u.b. fout melden)"  }

      // EDIT EXTENDED
      _HMG_aLangButton := {            ;
         "&Sluiten",          ; // 1
      "&Nieuw",            ; // 2
      "&Aanpassen",        ; // 3
      "&Verwijderen",      ; // 4
      "&Vind",             ; // 5
      "&Print",            ; // 6
      "&Annuleren",        ; // 7
      "&Ok",               ; // 8
      "&Kopieer",          ; // 9
      "&Activeer filter",  ; // 10
      "&Deactiveer filter", ; // 11
      "&Restore"           } // 12
      _HMG_aLangLabel := {                            ;
         "Geen",                             ; // 1
      "Regel",                            ; // 2
      "Totaal",                           ; // 3
      "Actieve volgorde",                 ; // 4
      "Opties",                           ; // 5
      "Nieuw regel",                      ; // 6
      "Aanpassen regel",                  ; // 7
      "Selecteer regel",                  ; // 8
      "Vind regel",                       ; // 9
      "Print opties",                     ; //10
      "Beschikbare velden",               ; //11
      "Velden te printen",                ; //12
      "Beschikbare printers",             ; //13
      "Eerste regel te printen",          ; //14
      "Laatste regel te printen",         ; //15
      "Verwijder regel",                  ; //16
      "Voorbeeld",                        ; //17
      "Laat pagina klein zien",           ; //18
      "Filter condities: ",               ; //19
      "Gefilterd: ",                      ; //20
      "Filter opties" ,                   ; //21
      "Database velden" ,                 ; //22
      "Vergelijkings operator",           ; //23
      "Filter waarde",                    ; //24
      "Selecteer velden om te filteren",  ; //25
      "Selecteer vergelijkings operator", ; //26
      "Gelijk",                           ; //27
      "Niet gelijk",                      ; //28
      "Groter dan",                       ; //29
      "Kleiner dan",                      ; //30
      "Groter dan of gelijk aan",         ; //31
      "Kleiner dan of gelijk aan"         } //32
      _HMG_aLangUser := { ;
         CRLF + "Kan geen actief werkgebied vinden   "  + CRLF + "Selecteer A.U.B. een actief werkgebied voor BEWERKEN aan te roepen   " + CRLF, ; // 1
      "Geef de veld waarde (een tekst)", ; // 2
      "Geef de veld waarde (een nummer)", ; // 3
      "Selecteer de datum", ; // 4
      "Controleer voor geldige waarde", ; // 5
      "Geef de veld waarde", ; // 6
      "Selecteer een regel en druk op OK", ; // 7
      CRLF + "Je gaat het actieve regel verwijderen  " + CRLF + "Zeker weten?    " + CRLF, ; // 8
      CRLF + "Er is geen actieve volgorde " + CRLF + "Selecteer er A.U.B. een   " + CRLF, ; // 9
      CRLF + "Kan niet zoeken in memo of logische velden   " + CRLF, ; // 10
      CRLF + "Regel niet gevonden   " + CRLF, ; // 11
      "Selecteer het veld om in de lijst in te sluiten", ; // 12
      "Selecteer het veld om uit de lijst te halen", ; // 13
      "Selecteer de printer", ; // 14
      "Druk op de knop om het veld in te sluiten", ; // 15
      "Druk op de knop om het veld uit te sluiten", ; // 16
      "Druk op de knop om het eerste veld te selecteren om te printen", ; // 17
      "Druk op de knop om het laatste veld te selecteren om te printen", ; // 18
      CRLF + "Geen velden meer om in te sluiten   " + CRLF, ; // 19
      CRLF + "Selecteer eerst het veld om in te sluiten   " + CRLF, ; // 20
      CRLF + "Geen velden meer om uit te sluiten   " + CRLF, ; // 21
      CRLF + "Selecteer eerst het veld om uit te sluiten   " + CRLF, ; // 22
      CRLF + "Je hebt geen velden geselecteerd   " + CRLF + "Selecteer A.U.B. de velden om in te sluiten om te printen   " + CRLF, ; // 23
      CRLF + "Teveel velden   " + CRLF + "Selecteer minder velden   " + CRLF, ; // 24
      CRLF + "Printer niet klaar   " + CRLF, ; // 25
      "Volgorde op", ; // 26
      "Van regel", ; // 27
      "Tot regel", ; // 28
      "Ja", ; // 29
      "Nee", ; // 30
      "Pagina:", ; // 31
      CRLF + "Selecteer A.U.B. een printer " + CRLF, ; // 32
      "Gefilterd op", ; // 33
      CRLF + "Er is een actief filter    " + CRLF, ; // 34
      CRLF + "Kan niet filteren op memo velden    " + CRLF, ; // 35
      CRLF + "Selecteer het veld om op te filteren    " + CRLF, ; // 36
      CRLF + "Selecteer een operator om te filteren    " + CRLF, ; // 37
      CRLF + "Type een waarde om te filteren " + CRLF, ; // 38
      CRLF + "Er is geen actief filter    " + CRLF, ; // 39
      CRLF + "Deactiveer filter?   " + CRLF, ; // 40
      CRLF + "Regel geblokkeerd door een andere gebuiker    " + CRLF, ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF } // 42

   CASE cLang == "SL"  // Slovenian
      /////////////////////////////////////////////////////////////
      // SLOVENIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Ste prepri�ani ?'
      _HMG_MESSAGE [2] := 'Zapri okno'
      _HMG_MESSAGE [3] := 'Zapiranje ni dovoljeno'
      _HMG_MESSAGE [4] := 'Program je �e zagnan'
      _HMG_MESSAGE [5] := 'Popravi'
      _HMG_MESSAGE [6] := 'V redu'
      _HMG_MESSAGE [7] := 'Prekini'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Str.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "Dodaj" , ;
         "Popravi"        , ;
         "Prekini"        , ;
         "V redu" }

      _HMG_BRWLangError  := { "Window: "                    , ;
         " not defined."     , ;
         "MiniGUI Error"                        , ;
         "Control: "                            , ;
         " Of "                                 , ;
         " Already defined." , ;
         "Type Not Allowed." , ;
         "False WorkArea."   , ;
         "Zapis ureja drug uporabnik"           , ;
         "Opozorilo"                            , ;
         "Narobe vnos" }

      _HMG_BRWLangMessage := { 'Ste prepri�ani ?' , 'Bri�i vrstico' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Bri�i vrstico" + Chr( 13 ) + "Ste prepri�ani ?" + Chr( 13 ) , ;
         Chr( 13 ) + "Manjka indeksna datoteka" + Chr( 13 ) + "Ne morem iskati" + Chr( 13 )       , ;
         Chr( 13 ) + "Ne najdem indeksnega polja" + Chr( 13 ) + "Ne morem iskati" + Chr( 13 )     , ;
         Chr( 13 ) + "Ne morem iskati po" + Chr( 13 ) + "memo ali logi�nih poljih" + Chr( 13 )    , ;
         Chr( 13 ) + "Ne najdem vrstice" + Chr( 13 )                                        , ;
         Chr( 13 ) + "Preve� kolon" + Chr( 13 ) + "Poro�ilo ne gre na list" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Vrstica", ;
         "�tevilo vrstic"         , ;
         "       (Nova)"          , ;
         "      (Popravi)"        , ;
         "Vnesi �tevilko vrstice" , ;
         "Poi��i"                 , ;
         "Besedilo za iskanje"    , ;
         "Datum za iskanje"       , ;
         "�tevilka za iskanje"    , ;
         "Parametri poro�ila"     , ;
         "Kolon v poro�ilu"       , ;
         "Kolon na razpolago"     , ;
         "Za�etna vrstica"        , ;
         "Kon�na vrstica"         , ;
         "Poro�ilo za "           , ;
         "Datum:"                 , ;
         "Za�etna vrstica:"       , ;
         "Kon�na vrstica:"        , ;
         "Urejeno po:"            , ;
         "Ja"                     , ;
         "Ne"                     , ;
         "Stran "                 , ;
         " od "                 }

      _HMG_aABMLangButton := { "Zapri" , ;
         "Nova"              , ;
         "Uredi"             , ;
         "Bri�i"             , ;
         "Poi��i"            , ;
         "Pojdi na"          , ;
         "Poro�ilo"          , ;
         "Prva"              , ;
         "Prej�nja"          , ;
         "Naslednja"         , ;
         "Zadnja"            , ;
         "Shrani"            , ;
         "Prekini"           , ;
         "Dodaj"             , ;
         "Odstrani"          , ;
         "Natisni"           , ;
         "Zapri"     }
      _HMG_aABMLangError  := { "EDIT, workarea name missing"              , ;
         "EDIT, this workarea has more than 16 fields"              , ;
         "EDIT, refresh mode out of range (please report bug)"      , ;
         "EDIT, main event number out of range (please report bug)" , ;
         "EDIT, list event number out of range (please report bug)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Zapri",             ; // 1
      "&Nova",              ; // 2
      "&Spremeni",          ; // 3
      "&Bri�i",             ; // 4
      "&Poi��i",            ; // 5
      "&Natisni",           ; // 6
      "&Prekini",           ; // 7
      "&V redu",            ; // 8
      "&Kopiraj",           ; // 9
      "&Aktiviraj Filter",  ; // 10
      "&Deaktiviraj Filter", ; // 11
      "&Obnovi"             } // 12
      _HMG_aLangLabel := {                 ;
         "Prazno",                        ; // 1
      "Vrstica",                       ; // 2
      "Skupaj",                        ; // 3
      "Activni indeks",                ; // 4
      "Mo�nosti",                      ; // 5
      "Nova vrstica",                  ; // 6
      "Spreminjaj vrstico",            ; // 7
      "Ozna�i vrstico",                ; // 8
      "Najdi vrstico",                 ; // 9
      "Mo�nosti tiskanja",             ; // 10
      "Polja na razpolago",            ; // 11
      "Polja za tiskanje",             ; // 12
      "Tiskalniki na razpolago",       ; // 13
      "Prva vrstica za tiskanje",      ; // 14
      "Zadnja vrstica za tiskanje",    ; // 15
      "Bri�i vrstico",                 ; // 16
      "Pregled",                       ; // 17
      "Mini pregled strani",           ; // 18
      "Pogoj za filter: ",             ; // 19
      "Filtrirano: ",                  ; // 20
      "Mo�nosti filtra" ,              ; // 21
      "Polja v datoteki" ,             ; // 22
      "Operator za primerjavo",        ; // 23
      "Vrednost filtra",               ; // 24
      "Izberi polje za filter",        ; // 25
      "Izberi operator za primerjavo", ; // 26
      "Enako",                         ; // 27
      "Neenako",                       ; // 28
      "Ve�je od",                      ; // 29
      "Manj�e od",                     ; // 30
      "Ve�je ali enako od",            ; // 31
      "Manj�e ali enako od"            } // 32
      _HMG_aLangUser := { ;
         CRLF + "Can't find an active area.   "  + CRLF + "Please select any area before call EDIT   " + CRLF,    ; // 1
      "Vnesi vrednost (tekst)",                                                                                ; // 2
      "Vnesi vrednost (�tevilka)",                                                                             ; // 3
      "Izberi datum",                                                                                          ; // 4
      "Ozna�i za logi�ni DA",                                                                                  ; // 5
      "Vnesi vrednost",                                                                                        ; // 6
      "Izberi vrstico in pritisni <V redu>",                                                                   ; // 7
      CRLF + "Pobrisali boste trenutno vrstico   " + CRLF + "Ste prepri�ani?    " + CRLF,                      ; // 8
      CRLF + "Ni aktivnega indeksa   " + CRLF + "Prosimo, izberite ga   " + CRLF,                              ; // 9
      CRLF + "Ne morem iskati po logi�nih oz. memo poljih   " + CRLF,                                          ; // 10
      CRLF + "Ne najdem vrstice   " + CRLF,                                                                    ; // 11
      "Izberite polje, ki BO vklju�eno na listo",                                                              ; // 12
      "Izberite polje, ki NI vklju�eno na listo",                                                              ; // 13
      "Izberite tisklanik",                                                                                    ; // 14
      "Pritisnite gumb za vklju�itev polja",                                                                   ; // 15
      "Pritisnite gumb za izklju�itev polja",                                                                  ; // 16
      "Pritisnite gumb za izbor prve vrstice za tiskanje",                                                     ; // 17
      "Pritisnite gumb za izbor zadnje vrstice za tiskanje",                                                   ; // 18
      CRLF + "Ni ve� polj za dodajanje   " + CRLF,                                                             ; // 19
      CRLF + "Najprej izberite ppolje za vklju�itev   " + CRLF,                                                ; // 20
      CRLF + "Ni ve� polj za izklju�itev   " + CRLF,                                                           ; // 21
      CRLF + "Najprej izberite polje za izklju�itev   " + CRLF,                                                ; // 22
      CRLF + "Niste izbrali nobenega polja   " + CRLF + "Prosom, izberite polje za tiskalnje   " + CRLF,       ; // 23
      CRLF + "Preve� polj   " + CRLF + "Zmanj�ajte �tevilo polj   " + CRLF,                                    ; // 24
      CRLF + "Tiskalnik ni pripravljen   " + CRLF,                                                             ; // 25
      "Urejeno po",                                                                                            ; // 26
      "Od vrstice",                                                                                            ; // 27
      "do vrstice",                                                                                            ; // 28
      "Ja",                                                                                                    ; // 29
      "Ne",                                                                                                    ; // 30
      "Stran:",                                                                                                ; // 31
      CRLF + "Izberite tiskalnik   " + CRLF,                                                                   ; // 32
      "Filtrirano z",                                                                                          ; // 33
      CRLF + "Aktivni filter v uporabi    " + CRLF,                                                            ; // 34
      CRLF + "Ne morem filtrirati z memo polji    " + CRLF,                                                    ; // 35
      CRLF + "Izberi polje za filtriranje    " + CRLF,                                                         ; // 36
      CRLF + "Izberi operator za filtriranje    " + CRLF,                                                      ; // 37
      CRLF + "Vnesi vrednost za filtriranje    " + CRLF,                                                       ; // 38
      CRLF + "Ni aktivnega filtra    " + CRLF,                                                                 ; // 39
      CRLF + "Deaktiviram filter?   " + CRLF,                                                                  ; // 40
      CRLF + "Vrstica zaklenjena - uporablja jo drug uporabnik    " + CRLF,                                    ; // 41
      CRLF + "Obnovili boste pobrisano vrstico   " + CRLF + "Ste prepri�ani?    " + CRLF                       } // 42

   CASE cLang == "SK"  // Slovak
      /////////////////////////////////////////////////////////////
      // SLOVAK
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Ste si ist�(�)?'
      _HMG_MESSAGE [2] := 'Zatvor okno'
      _HMG_MESSAGE [3] := 'Zatvorenie nedovolen�'
      _HMG_MESSAGE [4] := 'Program u� be��'
      _HMG_MESSAGE [5] := '�prava'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Storno'
      _HMG_MESSAGE [8] := 'Aplikuj'
      _HMG_MESSAGE [9] := 'Str.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "P&rida�"  , ;
         "&Upravi�" , ;
         "&Storno" , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Okno: "             , ;
         " nedefinovan�. Program ukon�en�.", ;
         "MiniGUI Error"                   , ;
         "Prvok: "                         , ;
         " z "                             , ;
         " u� definovan�. Program ukon�en�"                  , ;
         "Prezeranie: Nedovolen� typ. Program ukon�en�"      , ;
         "Prezeranie: Clauzula 'Prida�' je nepou�ite�n� so st�pcami nepatriacimi do pracovnej oblasti browse. Program ukon�en�", ;
         "Z�znam upravuje in� u��vate�"                      , ;
         "Varovanie"                                         , ;
         "Chybn� vstup"                                         }
      _HMG_BRWLangMessage := { 'Ste si ist�(�) ?' , 'Zmaza� z�znam' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Zmaza� z�znam." + Chr( 13 ) + "Ste si ist�(�)?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Ch�ba indexov� s�bor!" + Chr( 13 ) + "Nem��em h�ada�." + Chr( 13 )            , ;
         Chr( 13 ) + "Nebol n�jden� index!" + Chr( 13 ) + "Nem��em h�ada�." + Chr( 13 )        , ;
         Chr( 13 ) + "Nem��em h�ada� pod�a" + Chr( 13 ) + "st�pca typu memo alebo logical." + Chr( 13 )       , ;
         Chr( 13 ) + "Z�znam nebol n�jden�!" + Chr( 13 )                                        , ;
         Chr( 13 ) + "Pr�li� ve�a st�pcov!" + Chr( 13 ) + "Zostava sa nezmest� na plochu" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Z�znam"   , ;
         "Po�et z�znamov"     , ;
         "      (Nov�)"       , ;
         "   (Upravi�)"       , ;
         "Zadajte ��slo z�znamu", ;
         "H�adaj"             , ;
         "H�adan� text"       , ;
         "H�adan� d�tum"      , ;
         "H�adan� ��slo"      , ;
         "Defin�cia zostavy"  , ;
         "St�pce zostavy"     , ;
         "Dostupn� st�pce"    , ;
         "Prv� z�znam"        , ;
         "Posledn� z�znam"    , ;
         "Zostava "           , ;
         "D�tum:"             , ;
         "Prv� z�znam:"       , ;
         "Posledn� z�znam:"   , ;
         "Zoraden� pod�a:"    , ;
         "�no"                , ;
         "Nie"                , ;
         "Strana "            , ;
         " z "                   }

      _HMG_aABMLangButton := { "Zatvor" , ;
         "Nov�"             , ;
         "�prava"           , ;
         "Zru�"             , ;
         "N�jdi"            , ;
         "Cho� na"          , ;
         "Zostava"          , ;
         "Prv�"             , ;
         "Predo�l�"         , ;
         "�a���"            , ;
         "Posledn�"         , ;
         "Ulo�"             , ;
         "Storno"           , ;
         "Pridaj"           , ;
         "Odstr��"          , ;
         "Tla�"             , ;
         "Zatvor"     }
      _HMG_aABMLangError  := { "EDIT, ch�ba meno pracovnej oblasti"                              , ;
         "EDIT, pracovn� oblas� m� viac ako 16 st�pcov"              , ;
         "EDIT, refresh mode je mimo rozsah (pros�m, nahl�ste chybu)"      , ;
         "EDIT, ��slo hlavnej udalosti mimo rozsah (pros�m, nahl�ste chybu)" , ;
         "EDIT, ��slo udalosti, list mimo rozsah (pros�m, nahl�ste chybu)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Zatvor",           ; // 1
      "&Nov�",             ; // 2
      "�&prava",           ; // 3
      "Zr&u�",             ; // 4
      "N�&jdi",            ; // 5
      "&Tla�",             ; // 6
      "&Storno",           ; // 7
      "&Ok",               ; // 8
      "&Kop�ruj",          ; // 9
      "Zapni &filter",     ; // 10
      "&Vypni filter",     ; // 11
      "O&bnov"       }       // 12
      _HMG_aLangLabel := {                     ;
         "�iadna",                         ; // 1
      "Veta",                           ; // 2
      "Suma",                           ; // 3
      "Akt�vne zoradenie",              ; // 4
      "Mo�nosti",                       ; // 5
      "Nov� z�znam",                    ; // 6
      "Uprav z�znam",                   ; // 7
      "Vyber z�znam",                   ; // 8
      "N�jdi z�znam",                   ; // 9
      "Tla� volby",                     ; // 10
      "Dostupn� st�pce",                ; // 11
      "St�pce pre tla�",                ; // 12
      "Dostupn� tla�iarne",             ; // 13
      "Prv� z�znam pre tla�",           ; // 14
      "Posledn� z�znam pre tla�",       ; // 15
      "Vyma� z�znam",                   ; // 16
      "N�h�ad",                         ; // 17
      "Zobraz miniat�ry str�n",         ; // 18
      "Podmienky filtra: ",             ; // 19
      "Filtrovan�: ",                   ; // 20
      "Mo�nosti filtra",                ; // 21
      "St�pce d�tab�zy",                ; // 22
      "Oper�tor porovnanie",            ; // 23
      "Hodnota filtra",                 ; // 24
      "V�ber pola do filtra",           ; // 25
      "V�ber oper�tora porovnania",     ; // 26
      "rovn� sa",                       ; // 27
      "nerovn� sa",                     ; // 28
      "v��� ako",                      ; // 29
      "men�� ako",                      ; // 30
      "v��� alebo rovn� ako",          ; // 31
      "men�� alebo rovn� ako"          }  // 32
      _HMG_aLangUser := { ;
         CRLF + "Nen�jden� akt�vna oblas�   "  + CRLF + "Vyberte pros�m pred volan�m EDIT hociktor� oblas�   " + CRLF,     ; // 1
      "Zadajte hodnotu st�pca (�ubovoln� text)",                                                          ; // 2
      "Zadajte hodnotu st�pca (�ubovoln� ��slo)",                                                         ; // 3
      "Vyberte d�tum",                                                                                    ; // 4
      "Za�krtnite pre hodnotu 'true'",                                                                    ; // 5
      "Zadajte hodnotu st�pca",                                                                           ; // 6
      "Vyberte niektor� vetu a stla�te OK",                                                               ; // 7
      CRLF + "Chcete zru�i� tento z�znam   " + CRLF + "Ste si ist�(�)?    " + CRLF,                       ; // 8
      CRLF + "�iadn� zoradenie nie je akt�vn�   " + CRLF + "Pros�m vyberte jedno   " + CRLF,              ; // 9
      CRLF + "Nem��em h�ada� pod�a st�pca typu memo alebo logical " + CRLF,                               ; // 10
      CRLF + "Nen�jden� z�znam   " + CRLF,                                                                ; // 11
      "Vyberte st�pec k vlo�eniu do zoznamu",                                                             ; // 12
      "Vyberte st�pec k odstr�neniu zo zoznamu",                                                          ; // 13
      "Vyberte tla�iare�",                                                                                ; // 14
      "Stla�te tla�idlo zalo�enia st�pca",                                                                ; // 15
      "Stla�te tla�idlo odstr�nenia st�pca",                                                              ; // 16
      "Stla�te tla�idlo - Prv� z�znam pre tla�",                                                          ; // 17
      "Stla�te tla�idlo - Posledn� z�znam ptre tla�",                                                     ; // 18
      CRLF + "Nie je dostupn� st�pec k zalo�eniu   " + CRLF,                                              ; // 19
      CRLF + "Najprv vyberte st�pec k zalo�eniu   " + CRLF,                                               ; // 20
      CRLF + "�al�� st�pec nem��ete odstr�ni�   " + CRLF,                                                 ; // 21
      CRLF + "Najprv vyberte n. st�pec k odstr�neniu   " + CRLF,                                          ; // 22
      CRLF + "Nevybrali ste ani jeden stlpec   " + CRLF + "Pros�m vyberte st�pce pre tla�   " + CRLF,     ; // 23
      CRLF + "Pr�li� ve�a st�pcov   " + CRLF + "odstr��te niekter� st�pce   " + CRLF,                     ; // 24
      CRLF + "Tla�iare� nie je pripraven�   " + CRLF,                                                     ; // 25
      "Zoraden� pod�a",                                                                                   ; // 26
      "Od z�znamu",                                                                                       ; // 27
      "Po z�znam",                                                                                        ; // 28
      "�no",                                                                                              ; // 29
      "Nie",                                                                                              ; // 30
      "Strana:",                                                                                          ; // 31
      CRLF + "Vyberte si tla�iare�   " + CRLF,                                                            ; // 32
      "Filtrovan� pod�a",                                                                                 ; // 33
      CRLF + "Aktivn� filter    " + CRLF,                                                                 ; // 34
      CRLF + "Nem��ete filtrova� pod�a st�pca typu memo    " + CRLF,                                      ; // 35
      CRLF + "Vyberte st�pec do filtra    " + CRLF,                                                       ; // 36
      CRLF + "Vyberte oper�tor do filtra    " + CRLF,                                                     ; // 37
      CRLF + "Zadajte hodnotu do filtra    " + CRLF,                                                      ; // 38
      CRLF + "�iadny akt�vny filter    " + CRLF,                                                          ; // 39
      CRLF + "Deaktivova� filter?   " + CRLF,                                                             ; // 40
      CRLF + "Z�znam blokovan� in�m u��vate�om  " + CRLF,                                                 ; // 41
      CRLF + "Chcete obnovi� vymazan� z�znamy   " + CRLF + "Ste si ist�(�)?    " + CRLF                   } // 42

   CASE cLang == "HU"  // Hungarian
      /////////////////////////////////////////////////////////////
      // HUNGARIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Biztos benne?'
      _HMG_MESSAGE [2] := 'Z�rja be az ablakot'
      _HMG_MESSAGE [3] := 'Bez�r�s tiltva'
      _HMG_MESSAGE [4] := 'Program m�r fut'
      _HMG_MESSAGE [5] := 'Szerkeszt�s'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'M�gse'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Old.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "Hozz�ad"  , ;
         "Szerkeszt�s" , ;
         "&M�gse" , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Ablak: "                            , ;
         " nem defini�lt. Program v�ge" , ;
         "MiniGUI Error"                   , ;
         "Elem: "                         , ;
         " ebb�l "                             , ;
         " m�r defini�lt. Program v�ge"                  , ;
         "B�ng�sz�: Tiltott t�pus. Program v�ge"      , ;
         "B�ng�sz�: Hozz�ad fr�zis nem haszn�lhat� olyan mez�re, mely nincs a B�ng�sz� munkater�let�ben. Program v�ge", ;
         "A rekordot egy m�sik felhaszn�l� szerkeszti"                      , ;
         "Figyelmeztet�s"                                         , ;
         "Hib�s adat"                                         }
      _HMG_BRWLangMessage := { 'Biztos benne ?' , 'Rekord t�rl�se' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Rekord t�rl�se" + Chr( 13 ) + "Biztos benne ?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Hi�nyz� index �llom�ny" + Chr( 13 ) + "Lehetetlen a keres�s" + Chr( 13 )            , ;
         Chr( 13 ) + "Hi�nyz� index mez�" + Chr( 13 ) + "Lehetetlen a keres�s" + Chr( 13 )        , ;
         Chr( 13 ) + "Lehetetlen a keres�s a k�v.alapj�n" + Chr( 13 ) + "mez� memo vagy logikai" + Chr( 13 )       , ;
         Chr( 13 ) + "Nincs rekord" + Chr( 13 )                                        , ;
         Chr( 13 ) + "T�l sok oszlop" + Chr( 13 ) + "A jelent�s nem f�r el a fel�leten" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Rekord"         , ;
         "Rekord sz�ml�l�"          , ;
         "           (�j)"          , ;
         "  (Szerkeszt�s)"          , ;
         "Adja meg a rekord sz�m�t" , ;
         "Keresd"                   , ;
         "Keresett sz�veg"          , ;
         "Keresett d�tum"           , ;
         "Keresett sz�m"            , ;
         "A jelent�s meghat�roz�sa" , ;
         "A jelent�s oszlopai"      , ;
         "Haszn�lhat� oszlopok"     , ;
         "Kezd� rekord"             , ;
         "Utols� rekord"            , ;
         "Jelent�s a "              , ;
         "D�tum:"                   , ;
         "Kezd� rekord:"            , ;
         "Utols� rekord:"           , ;
         "Rendezve:"                , ;
         "Igen"                     , ;
         "Nem"                      , ;
         "Oldal "                   , ;
         " / "                       }

      _HMG_aABMLangButton := { "Z�rd be" , ;
         "�j"            , ;
         "Szerkeszt�s"   , ;
         "T�r�ld"        , ;
         "Keresd"        , ;
         "Menj a"        , ;
         "Jelent�s"      , ;
         "Els�"          , ;
         "El�z�"         , ;
         "K�vetkez�"     , ;
         "Utols�"        , ;
         "Mentsd"        , ;
         "M�gse"         , ;
         "Add"           , ;
         "Elt�vol�t"     , ;
         "Nyomtat�s"     , ;
         "Z�rd be"     }
      _HMG_aABMLangError  := { "SZERKESZT�S, hib�s a munkater�let neve"                              , ;
         "SZERKESZT�S, a munkater�letnek t�bb mint 16 mez�t tartalmaz"              , ;
         "SZERKESZT�S, a friss�t�si m�d �rt�ken k�v�l (k�rem, jelentse a hib�t)"      , ;
         "SZERKESZT�S, a f� esem�ny sz�ma �rt�ken k�v�l (k�rem, jelentse a hib�t)" , ;
         "SZERKESZT�S, a lista esem�ny sz�ma �rt�ken k�v�l(k�rem, jelentse a hib�t)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Z�rd be",               ; // 1
      "�&j",                    ; // 2
      "M�&dos�t�s",             ; // 3
      "&T�r�ld",                ; // 4
      "&Keresd",                ; // 5
      "&Nyomtat�s",             ; // 6
      "&M�gse",                 ; // 7
      "&Ok",                    ; // 8
      "M�so&l",                 ; // 9
      "Sz�r� &bekapcsol�sa",    ; // 10
      "Sz�r� ki&kapcsol�sa",    ; // 11
      "&Visszah�v"       }        // 12
      _HMG_aLangLabel := {                            ;
         "nincs",                                 ; // 1
      "rekord",                                ; // 2
      "�sszeg",                                ; // 3
      "Akt�v rendez�s",                        ; // 4
      "Opci�k",                                ; // 5
      "�j rekord",                             ; // 6
      "Rekord m�dos�t�sa",                     ; // 7
      "Rekord kiv�laszt�sa",                   ; // 8
      "Rekord keres�se",                       ; // 9
      "Nyomtat�si opci�k",                     ; // 10
      "Haszn�lhat� mez�k",                     ; // 11
      "Nyomtathat� mez�k",                     ; // 12
      "El�rhet� nyomtat�k",                    ; // 13
      "Nyomtat�s els� rekordja",               ; // 14
      "Nyomtat�s utols� rekordja",             ; // 15
      "Rekord t�rl�se",                        ; // 16
      "El�n�zet",                              ; // 17
      "Oldalak miniat�rak�nt",                 ; // 18
      "Sz�r� felt�tele: ",                     ; // 19
      "Sz�rve: ",                              ; // 20
      "Sz�r� opci�i",                          ; // 21
      "Adatb�zis mez�i",                       ; // 22
      "�sszehasonl�t� oper�tor",               ; // 23
      "Sz�r� �rt�ke",                          ; // 24
      "Mez�k kiv�laszt�sa a sz�r�h�z",         ; // 25
      "�sszehasonl�t� oper�ctor kiv�laszt�sa",  ; // 26
      "egyenl�",                               ; // 27
      "nem egyenl�",                           ; // 28
      "nagyobb mint",                          ; // 29
      "kisebb mint",                           ; // 30
      "nagyobb vagy egyenl� mint",             ; // 31
      "kisebb vagy egyenl� mint"          }      // 32
      _HMG_aLangUser := { ;
         CRLF + "Nincs akt�v munkater�let   "  + CRLF + "K�rem v�lasszon egy munkater�letet a SZERKESZT�S h�v�sa el�tt   " + CRLF,     ; // 1
      "Adja meg a mez� �rt�k�t (sz�veget)",                                                                 ; // 2
      "Adja meg a mez� �rt�k�t (sz�mot)",                                                                   ; // 3
      "V�lasszon d�tumot",                                                                                  ; // 4
      "Pip�zza az igaz �rt�ket",                                                                            ; // 5
      "Adja meg a mez� �rt�k�t",                                                                            ; // 6
      "V�lasszon egy rekordot �s nyomjon OK",                                                               ; // 7
      CRLF + "Akt�v rekordot k�v�nja t�r�lni   " + CRLF + "Biztos benne?    " + CRLF,                       ; // 8
      CRLF + "Nincs akt�v sorba rendez�s   " + CRLF + "K�rem v�lasszon egyet   " + CRLF,                    ; // 9
      CRLF + "Nem kereshetek memo vagy logikai mez� ut�n   " + CRLF,                                        ; // 10
      CRLF + "Nincs rekord   " + CRLF,                                                                      ; // 11
      "V�lasszon a list�hoz hozz�adand� mez�t",                                                             ; // 12
      "V�lasszon a list�b�l kiveend� mez�t",                                                                ; // 13
      "V�lasszon nyomtat�t",                                                                                ; // 14
      "Mez� hozz�ad�s gombot nyomja meg",                                                                   ; // 15
      "Mez� t�rl�se gombot nyomja meg",                                                                     ; // 16
      "A nyomtat�s els� rekordja gombot nyomja meg",                                                        ; // 17
      "A nyomtat�s utols� rekordja gombot nyomja meg",                                                      ; // 18
      CRLF + "Nincs t�bb hozz�adhat� mez�   " + CRLF,                                                       ; // 19
      CRLF + "El�sz�r hozz�adand� mez�t v�lasszon   " + CRLF,                                               ; // 20
      CRLF + "Nincs t�bb kivehet� mez�   " + CRLF,                                                          ; // 21
      CRLF + "El�sz�r az n. kiveend� mez�t v�lassza ki   " + CRLF,                                          ; // 22
      CRLF + "Egy mez�t sem v�lasztott ki   " + CRLF + "K�rem v�lassza ki a nyomtatand� mez�ket   " + CRLF, ; // 23
      CRLF + "T�l sok mez�   " + CRLF + "Reduk�lja a mez�k sz�m�t   " + CRLF,                               ; // 24
      CRLF + "A nyomtat� nem k�sz   " + CRLF,                                                               ; // 25
      "Rendezve",                                                                                           ; // 26
      "Rekordt�l",                                                                                          ; // 27
      "Rekordig",                                                                                           ; // 28
      "Igen",                                                                                               ; // 29
      "Nem",                                                                                                ; // 30
      "Oldal:",                                                                                             ; // 31
      CRLF + "K�rem v�lasszon nyomtat�t   " + CRLF,                                                         ; // 32
      "Sz�rve",                                                                                             ; // 33
      CRLF + "Ez az akt�v sz�r�   " + CRLF,                                                                 ; // 34
      CRLF + "Nem sz�r�het� memo mez� alapj�n   " + CRLF,                                                   ; // 35
      CRLF + "V�lasszon mez�t a sz�r�h�z   " + CRLF,                                                        ; // 36
      CRLF + "V�lasszon oper�tort a sz�r�h�z   " + CRLF,                                                    ; // 37
      CRLF + "Adjon �rt�ket  a sz�r�h�z   " + CRLF,                                                         ; // 38
      CRLF + "Nincs egy akt�v sz�r�   " + CRLF,                                                             ; // 39
      CRLF + "A sz�r� deaktiv�l�sa?   " + CRLF,                                                             ; // 40
      CRLF + "A rekord blokkolva m�sik felhaszn�l� �ltal   " + CRLF,                                        ; // 41
      CRLF + "T�r�lt rekordokat k�v�n visszah�vni   " + CRLF + "Biztos benne ?    " + CRLF                  } // 42

   CASE cLang == "EL"  // Greek - Ellinika
      /////////////////////////////////////////////////////////////
      // GREEK - �������� - EL
      /////////////////////////////////////////////////////////////

      // MISC MESSAGES (GREEK EL)

      _HMG_MESSAGE [1] := '����� �������?'
      _HMG_MESSAGE [2] := '�������� ���������'
      _HMG_MESSAGE [3] := '��� ����������� �� ��������'
      _HMG_MESSAGE [4] := '�� ��������� ���������� ���'
      _HMG_MESSAGE [5] := '����.'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := '�����'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := '���.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES (GREEK EL)

      _HMG_BRWLangButton := { "&���"  , ;
         "&��������"    , ;
         "&�����"  , ;
         "&OK"       }
      _HMG_BRWLangError  := { "�� window: "                                           , ;
         " ��� ���� �������. �� ��������� ������������"          , ;
         "MiniGUI Error"                                         , ;
         "Control: "                                             , ;
         " Of "                                                  , ;
         " ���� ��� �������. �� ��������� ������������"          , ;
         "Browse: �� ������� �����. �� ��������� ������������"          , ;
         "Browse: Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea.", ;
         "� ������� ��������������� ��� ���� ������"                , ;
         "�������"                                               , ;
         "�� �������� ����"                                          }
      _HMG_BRWLangMessage := { '����� ������� ?' , '�������� ��������' }

      // EDIT MESSAGES (GREEK - ��������)

      _HMG_aABMLangUser   := { Chr( 13 ) + "�������� ��������" + Chr( 13 ) + "����� �������?" + Chr( 13 )    , ;
         Chr( 13 ) + "�� ��������� ��� �������" + Chr( 13 ) + "��������� �������!" + Chr( 13 )  , ;
         Chr( 13 ) + "Can`t find index field" + Chr( 13 ) + "��������� �������!" + Chr( 13 )        , ;
         Chr( 13 ) + "��������� ������� ��" + Chr( 13 ) + "����� memo � ������" + Chr( 13 )       , ;
         Chr( 13 ) + "� ������� ��� �������" + Chr( 13 )                                        , ;
         Chr( 13 ) + "������ ������" + Chr( 13 ) + "� ������� ��� ���� ��� ������" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "�������"    , ;
         "����.��������"        , ;
         "       (���)"         , ;
         "     (����.)"         , ;
         "����� ����.��������"  , ;
         "������"               , ;
         "������ ��������"      , ;
         "������ ����/����"     , ;
         "������ �������"       , ;
         "������� ��������"     , ;
         "������ Report"        , ;
         "���������� ������"    , ;
         "������ �������"       , ;
         "������ �������"       , ;
         "������� of "          , ;
         "����:"                , ;
         "������ �������:"      , ;
         "������ �������:"      , ;
         "���������� by:"       , ;
         "���"                  , ;
         "���"                  , ;
         "���. "                , ;
         " of "                 }

      _HMG_aABMLangButton := { "������"    , ;
         "N��"                 , ;
         "��������"            , ;
         "��������"            , ;
         "������"              , ;
         "�������"             , ;
         "�������"             , ;
         "�����"               , ;
         "�����/��"            , ;
         "�������"             , ;
         "���������"           , ;
         "����������"          , ;
         "�����"               , ;
         "��������"            , ;
         "��������"            , ;
         "��������"            , ;
         "��������"     }
	
      _HMG_aABMLangError  := { "�����������, �� ����� �������� �������� ��� �������"                 , ;
         "�����������, � ������� �������� ���� ����������� ��� 16 �����"                 , ;
         "�����������, ������ ��������� ����� ����� (�������� �������������� �� bug)"    , ;
         "�����������, main event number ����� ����� (�������� �������������� �� bug)"   , ;
         "�����������, list event number ����� ����� (�������� �������������� �� bug)"  }

      // EDIT EXTENDED (GREEK - ��������)

      _HMG_aLangButton := {   ;
         "&��������",       ; // 1
      "&���",            ; // 2
      "&��������",       ; // 3
      "&��������",       ; // 4
      "&������",         ; // 5
      "&��������",       ; // 6
      "&�����",          ; // 7
      "&Ok",             ; // 8
      "&���������",      ; // 9
      "&������",         ; // 10
      "&����� ������",   ; // 11
      "&Restore"         } // 12
      _HMG_aLangLabel := {                   ;
         "������",                       ; // 1
      "�������",                      ; // 2
      "������",                       ; // 3
      "������ ����������",            ; // 4
      "��������",                     ; // 5
      "��� �������",                  ; // 6
      "�����. ��������",              ; // 7
      "������� ��������",             ; // 8
      "������",                       ; // 9
      "����������� ���������",        ; // 10
      "��������� �����",              ; // 11
      "����� ��� ��������",           ; // 12
      "���������� ���������",         ; // 13
      "����� ������� �����.",         ; // 14
      "��������� ������� �����.",     ; // 15
      "�������� ��������",            ; // 16
      "�������������",                ; // 17
      "������������ �������",         ; // 18
      "���� �������: ",               ; // 19
      "�������������: ",              ; // 20
      "�������� �������" ,            ; // 21
      "����� ����� ���������" ,       ; // 22
      "�������� ���������",           ; // 23
      "���� �������",                 ; // 24
      "������� ������ ��� ������",    ; // 25
      "������� ������� ���������",    ; // 26
      "����",                         ; // 27
      "��� ����",                     ; // 28
      "���������� ���",               ; // 29
      "��������� ���",                ; // 30
      "���������� � ���� ��",         ; // 31
      "��������� � ���� ��"           } // 32
      _HMG_aLangUser := { ;
         CRLF + "��� ������� ������ ������� ��������. "  + CRLF + ;
         "�������� ��� ������� ���� ��� ��� ����� ��� EDIT   " + CRLF,                                          ; // 1
      "����� ��� ���� ������ (�������)",                                                                         ; // 2
      "����� ��� ���� ������ (�������)",                                                                         ; // 3
      "�������� ����/���",                                                                                       ; // 4
      "��������� �� ��������",                                                                                   ; // 5
      "����� ���� ��� ������",                                                                                   ; // 6
      "�������� ��� ������� & ������ OK",                                                                        ; // 7
      CRLF + "� �������� ������� �� ���������   " + CRLF + "����� �������?    " + CRLF,              ; // 8
      CRLF + "������ ������ ���������  " + CRLF + "�������� ��������� ���   " + CRLF,                ; // 9
      CRLF + "��� ������� ��������� �� memo � logic ����� " + CRLF,                                      ; // 10
      CRLF + "� ������� ��� �������  " + CRLF,                                                           ; // 11
      "����������� ��� ������ ��� �����",                                                                        ; // 12
      "�������� ��� ������ ��� ��� �����",                                                                       ; // 13
      "�������� ��������",                                                                                       ; // 14
      "������ �� ������ ��� ����������� ��� ������",                                                             ; // 15
      "������ �� ������ ��� �������� ��� ������",                                                                ; // 16
      "������ �� ������ ��� �������  �������� ��� ��������",                                                     ; // 17
      "Push button to select the last record to print",                                                          ; // 18
      CRLF + "��� �������� ���� ����� " + CRLF,                                                          ; // 19
      CRLF + "����� �������� ����� " + CRLF,                                                             ; // 20
      CRLF + "��� �������� ���� ����� " + CRLF,                                                          ; // 21
      CRLF + "����� �������� ����� " + CRLF,                                                             ; // 22
      CRLF + "��� ����� �������� ����� " + CRLF + "�������� �������� ����� ���� ��������   " + CRLF, ; // 23
      CRLF + "���� ����� ����� " + CRLF + "������� ��� ������ ������ " + CRLF,                       ; // 24
      CRLF + "� ��������� ��� ����� ������� " + CRLF,                                                    ; // 25
      "���������� ��� ",                                                                                         ; // 26
      "��� �������",                                                                                             ; // 27
      "��� �������",                                                                                             ; // 28
      "���",                                                                                                     ; // 29
      "���",                                                                                                     ; // 30
      "���.:",                                                                                                   ; // 31
      CRLF + "�������� �������� �������� " + CRLF,                                                       ; // 32
      "Filtered by",                                                                                             ; // 33
      CRLF + "������� ������ ������ " + CRLF,                                                            ; // 34
      CRLF + "�������� �� ����������� �� ����� memo " + CRLF,                                            ; // 35
      CRLF + "�������� ����� ��� �� ������ " + CRLF,                                                     ; // 36
      CRLF + "�������� ���� ������� ��� �� ������ " + CRLF,                                              ; // 37
      CRLF + "����� ��� ���� ��� �� ������ " + CRLF,                                                     ; // 38
      CRLF + "��� ������� ������ ������ " + CRLF,                                                        ; // 39
      CRLF + "��������� �������;   " + CRLF,                                                             ; // 40
      CRLF + "������� ���������� ��� ���� ������    " + CRLF,                                            ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF    } // 42

   CASE cLang == "BG"  // Bulgarian
      /////////////////////////////////////////////////////////////
      // BULGARIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := '������� �� ��� ?'
      _HMG_MESSAGE [2] := '��������� �� ���������'
      _HMG_MESSAGE [3] := '����������� �� �� �������'
      _HMG_MESSAGE [4] := '���������� ���� � ����������'
      _HMG_MESSAGE [5] := '�����������'
      _HMG_MESSAGE [6] := '��'
      _HMG_MESSAGE [7] := '������'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := '���.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "��������" , ;
         "�������"    , ;
         "������"      , ;
         "OK"           }
      _HMG_BRWLangError  := { "���������: "                                             , ;
         " �� � ���������. ���������� ��������"                    , ;
         "MiniGUI ������"                                        , ;
         "�������� �� ����������: "                                  , ;
         " �� "                                                  , ;
         " ���� � ���������. ���������� ��������"                         , ;
         "Browse: ����� ��� �� �� ��������. ���������� ��������"    , ;
         "Browse: Append ����� �� ���� �� �� �������� � ������ �� ���� ������� ������. ���������� ��������", ;
         "������ ���� �� ��������� �� ���� ����������"           , ;
         "��������������"                                             , ;
         "�������� �� ���������� ����"                                 }
      _HMG_BRWLangMessage := { '������� �� ��� ?' , '��������� �� �����' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "��������� �� �����." + Chr( 13 ) + "������� �� ��� ?" + Chr( 13 )                  , ;
         Chr( 13 ) + "���� �������� ����" + Chr( 13 ) + "��������� � ����������" + Chr( 13 )   , ;
         Chr( 13 ) + "���� �������� ����" + Chr( 13 ) + "��������� � ����������" + Chr( 13 )   , ;
         Chr( 13 ) + "��������� � ���������� �" + Chr( 13 ) + "���� �������� ��� ����������� ������" + Chr( 13 ) , ;
         Chr( 13 ) + "������ �� � �������" + Chr( 13 )                                       , ;
         Chr( 13 ) + "��������� ����� ������" + Chr( 13 ) + "������ �� �� ������ �� �����" + Chr( 13 ) }
      _HMG_aABMLangLabel  := { "�����"              , ;
         "������ ������"       , ;
         "       (���)"        , ;
         "   (�������)"        , ;
         "�������� N: �� �����", ;
         "�������"               , ;
         "������ �����"        , ;
         "������ ����"         , ;
         "������ �����"        , ;
         "��������� �� ������" , ;
         "������ �� ������"    , ;
         "�������� ������"     , ;
         "����� �����"         , ;
         "�������� �����"      , ;
         "����� ��  "          , ;
         "����:"               , ;
         "����� �����:"        , ;
         "�������� �����:"     , ;
         "��������� ��:"       , ;
         "��"                  , ;
         "��"                  , ;
         "�������� "           , ;
         " �� "                 }
      _HMG_aABMLangButton := { "�������"   , ;
         "���"       , ;
         "�������"   , ;
         "������"   , ;
         "�����"     , ;
         "��� ��"   , ;
         "�����"     , ;
         "�����"    , ;
         "�����"     , ;
         "������"    , ;
         "��������" , ;
         "������" , ;
         "������"    , ;
         "������"  , ;
         "������"   , ;
         "�����"    , ;
         "�������"    }
      _HMG_aABMLangError  := { "EDIT, �� ������� ����� �� ��������� ������"                     , ;
         "EDIT, �������� �� �� ������ �� 16 ������"                      , ;
         "EDIT, ������ �� ���������� � ����� ��������� (�������� �� ��������)", ;
         "EDIT, ������ �� ��������� � ����� ��������� (�������� �� ��������)"   , ;
         "EDIT, ����� �� ��������� �� �������� � ����� ��������� (�������� �� ��������)" }

      // EDIT EXTENDED

      _HMG_aLangButton := {            ;
         "&�����",             ; // 1
      "&���",               ; // 2
      "&�����������",       ; // 3
      "&������",            ; // 4
      "&������",            ; // 5
      "�&����",             ; // 6
      "��&����",            ; // 7
      "&��",                ; // 8
      "&�����",             ; // 9
      "&���. ������",       ; // 10
      "��&��� ������",      ; // 11
      "&����������"     }     // 12
      _HMG_aLangLabel := {            ;
         "����",                         ; // 1
      "�����",                        ; // 2
      "������",                       ; // 3
      "��������",                     ; // 4
      "���������",                    ; // 5
      "��� �����",                    ; // 6
      "������� �����",                ; // 7
      "������ �����",                 ; // 8
      "������ �����",                 ; // 9
      "��������� �� �����",           ; // 10
      "�������� ������",              ; // 11
      "������ �� �����",              ; // 12
      "�������� ��������",            ; // 13
      "������� ����� �� �����",       ; // 14
      "������� ������ ��� �����",     ; // 15
      "������ �����",                 ; // 16
      "�������",                      ; // 17
      "�������� � ���������",         ; // 18
      "������� �� �������: ",         ; // 19
      "������: ",                     ; // 20
      "��������� �� �������" ,        ; // 21
      "������ �� ������" ,            ; // 22
      "��������� �� ���������",       ; // 23
      "�������� �� �������",          ; // 24
      "����� �� ���� �� �������",     ; // 25
      "����� �� �������� �� ���������", ; // 26
      "�����",                        ; // 27
      "�� � �����",                   ; // 28
      "��-������",                    ; // 29
      "��-�����",                     ; // 30
      "��-������ ��� �����",          ; // 31
      "��-����� ��� �����"         }    // 32
      _HMG_aLangUser := { ;
         CRLF + "�� � �������� ������� ������."  + CRLF + "�������� ������ ������ ����������� �� EDIT" + CRLF, ; // 1
      "�������� �����",                                                                                     ; // 2
      "�������� �����",                                                                                     ; // 3
      "�������� ����",                                                                                      ; // 4
      "��������� ��������",                                                                                 ; // 5
      "�������� ��������� �� ������",                                                                       ; // 6
      "�������� ����� � ��������� OK",                                                                      ; // 7
      CRLF + "�������� ����� �� ���� ������ " + CRLF + "�� �������� �� ?    " + CRLF,                       ; // 8
      CRLF + "���� �������� " + CRLF + "�������� ���� �� ��������������" + CRLF,                            ; // 9
      CRLF + "������� � MEMO �������� � ����������� ������ �� �� ���������" + CRLF,                         ; // 10
      CRLF + "������ �� � �������  " + CRLF,                                                                ; // 11
      "������ �� ��������� � ������� �� �����",                                                             ; // 12
      "������ � ������ �� �����",                                                                           ; // 13
      "����� �� �������",                                                                                   ; // 14
      "��������� �� ������� �� ������ � ������� �� �����",                                                  ; // 15
      "��������� �� ���������� �� ������ �� ������� �� �����",                                              ; // 16
      "�����, �� ����� ������� ������",                                                                     ; // 17
      "�����, �� ����� �������� ������",                                                                    ; // 18
      CRLF + "�������� ������ ���� " + CRLF,                                                                ; // 19
      CRLF + "����� ���� �� ��������� " + CRLF,                                                             ; // 20
      CRLF + "������ �� ���������� ���� " + CRLF,                                                           ; // 21
      CRLF + "����� ���� �� ���������� " + CRLF,                                                            ; // 22
      CRLF + "���� ������� ������ " + CRLF + "���������� ������ �� ����� " + CRLF,                          ; // 23
      CRLF + "��������� ����� ������ " + CRLF + "�������� ������� ���������� " + CRLF,                      ; // 24
      CRLF + "�������� �� � �����  " + CRLF,                                                                ; // 25
      "�������� ",                                                                                          ; // 26
      "�� ����� ",                                                                                          ; // 27
      "�� ����� ",                                                                                          ; // 28
      "��",                                                                                                 ; // 29
      "��",                                                                                                 ; // 30
      "��������:",                                                                                          ; // 31
      CRLF + "�������� �������  " + CRLF,                                                                   ; // 32
      "���������� ��",                                                                                      ; // 33
      CRLF + "���� �� � �������� ������    " + CRLF,                                                        ; // 34
      CRLF + "MEMO �������� �� �� ���������  " + CRLF,                                                      ; // 35
      CRLF + "�������� ������ �� �������    " + CRLF,                                                       ; // 36
      CRLF + "�������� �������� �� �������" + CRLF,                                                         ; // 37
      CRLF + "�������� �������� �� �������" + CRLF,                                                         ; // 38
      CRLF + "���� ������� ������   " + CRLF,                                                               ; // 39
      CRLF + "����� ������� ?   " + CRLF,                                                                   ; // 40
      CRLF + "������ � �������� �� ���� ���������� " + CRLF,                                                ; // 41
      CRLF + "������� ����� �� ���� ����������� " + CRLF + "�� �������� �� ?    " + CRLF                    } // 42

   ENDCASE

#endif

RETURN
