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
      _HMG_MESSAGE [2] := 'Zavшi okno'
      _HMG_MESSAGE [3] := 'Uzavшenн zakбzбno'
      _HMG_MESSAGE [4] := 'Program uћ bмћн'
      _HMG_MESSAGE [5] := 'Ъprava'
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
         " nenн definovбno. Program ukonиen"                   , ;
         "MiniGUI Error"                                         , ;
         "Prvek: "                                             , ;
         " z "                                                  , ;
         " uћ definovбn. Program ukonиen"                  , ;
         "Browse: Typ nepovolen. Program ukonиen"          , ;
         "Browse: Append frбzi nelze pouћнt s poli nepatшнcнmi do Browse pracovnн oblasti. Program ukonиen", ;
         "Zбznam edituje jinэ uћivatel"                , ;
         "Varovбnн"                                              , ;
         "Chybnэ vstup"                                          }
      _HMG_BRWLangMessage := { 'Jste si jist(a)?' , 'Smazat zбznam' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Smazat zбznam" + Chr( 13 ) + "Jste si jist(a)?" + Chr( 13 ) , ;
         Chr( 13 ) + "Chybн indexovэ soubor" + Chr( 13 ) + "Nemohu hledat" + Chr( 13 )            , ;
         Chr( 13 ) + "Nemohu najнt indexovanй pole" + Chr( 13 ) + "Nemohu hledat" + Chr( 13 )        , ;
         Chr( 13 ) + "Nemohu hledat podle" + Chr( 13 ) + "pole memo nebo logickй" + Chr( 13 )       , ;
         Chr( 13 ) + "Zбznam nenalezen" + Chr( 13 )                                        , ;
         Chr( 13 ) + "Pшнliљ mnoho sloupcщ" + Chr( 13 ) + "Sestava se nevejde na plochu" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Zбznam"      , ;
         "Poиet zбznamщ"         , ;
         "      (Novэ)"          , ;
         "     (Ъprava)"         , ;
         "Zadejte инslo zбznamu" , ;
         "Hledej"                , ;
         "Hledanэ text"          , ;
         "Hledanй datum"         , ;
         "Hledanй инslo"         , ;
         "Definice sestavy"      , ;
         "Sloupce sestavy"       , ;
         "Dostupnй sloupce"      , ;
         "Prvnн zбznam"          , ;
         "Poslednн zбznam"       , ;
         "Sestava "              , ;
         "Datum:"                , ;
         "Prvnн zбznam:"         , ;
         "Poslednн zбznam:"      , ;
         "Tшнdмno dle:"          , ;
         "Ano"                   , ;
         "Ne"                    , ;
         "Strana "               , ;
         " z "                   }

      _HMG_aABMLangButton := { "Zavшнt"    , ;
         "Novэ"      , ;
         "Ъprava"    , ;
         "Smaћ"      , ;
         "Najdi"     , ;
         "Jdi"       , ;
         "Sestava"   , ;
         "Prvnн"     , ;
         "Pшedchozн" , ;
         "Dalљн"     , ;
         "Poslednн"  , ;
         "Uloћ"      , ;
         "Storno"    , ;
         "Pшidej"    , ;
         "Odstraт"   , ;
         "Tisk"      , ;
         "Zavшi"     }
      _HMG_aABMLangError  := { "EDIT, chybн jmйno pracovnн oblasti" , ;
         "EDIT, pracovnн oblast mб vнc jak 16 polн"              , ;
         "EDIT, refresh mode mimo rozsah (prosнm, nahlaste chybu)"      , ;
         "EDIT, hlavnн event инslo mimo rozsah (prosнm, nahlaste chybu)" , ;
         "EDIT, list event инslomimo rozsah (prosнm, nahlaste chybu)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Zavшi",            ; // 1
      "&Novэ",             ; // 2
      "Ъ&prava",           ; // 3
      "S&maћ  ",           ; // 4
      "Na&jdi",            ; // 5
      "&Tisk",             ; // 6
      "&Storno",           ; // 7
      "&Ok",               ; // 8
      "&Kopнruj",          ; // 9
      "Aktivuj &filtr",    ; // 10
      "&Vypni filtr",      ; // 11
      "&Restore"           } // 12
      _HMG_aLangLabel := {            ;
         "Ћбdnэ",                        ; // 1
      "Zбznam",                       ; // 2
      "Suma",                         ; // 3
      "Aktivnн tшнdмnн",              ; // 4
      "Volby",                        ; // 5
      "Novэ zбznam",                  ; // 6
      "Uprav zбznam",                 ; // 7
      "Vyber zбznam",                 ; // 8
      "Najdi zбznam",                 ; // 9
      "Tiskni volby",                 ; // 10
      "Dostupnб pole",                ; // 11
      "Pole k tisku",                 ; // 12
      "Dostupnй tiskбrny",            ; // 13
      "Prvnн zбznam k tisku",         ; // 14
      "Poslednн zбznam k tisku",      ; // 15
      "Smaћ zбznam",                  ; // 16
      "Nбhled",                       ; // 17
      "Zobraz miniatury stran",       ; // 18
      "Filtr: ",                      ; // 19
      "Filtrovбn: ",                  ; // 20
      "Volby filtru",                 ; // 21
      "Pole databбze",                ; // 22
      "Operбtor porovnбnн",           ; // 23
      "Hodnota filtru",               ; // 24
      "Vyber pole do filtru",         ; // 25
      "Vyber operбtor porovnбnн",     ; // 26
      "rovno",                        ; // 27
      "nerovno",                      ; // 28
      "vмtљн neћ",                    ; // 29
      "menљн neћ",                    ; // 30
      "vмtљн nebo rovno neћ",         ; // 31
      "menљн nebo rovno neћ"          } // 32
      _HMG_aLangUser := { ;
         CRLF + "Nelze najнt aktivnн oblast   "  + CRLF + "Prosнm vyberte nмkterou pшed volбnнm EDIT   " + CRLF,         ; // 1
      "Zadejte hodnotu pole (libovolnэ text)",                                                                        ; // 2
      "Zadejte hodnotu pole (libovolnй инslo)",                                                                       ; // 3
      "Vyberte datum",                                                                                                ; // 4
      "Zatrhnмte pro hodnotu true",                                                                                   ; // 5
      "Zadejte hodnotu pole",                                                                                         ; // 6
      "Vyberte jakэkoliv zбznam s stisknмte OK",                                                                      ; // 7
      CRLF + "Chcete smazat tento zбznam  " + CRLF + "Jste si jist(a)?    " + CRLF,                                   ; // 8
      CRLF + "Nenн vybrбno ћбdnй tшнdмnн   " + CRLF + "Prosнm zvolte jedno   " + CRLF,                                ; // 9
      CRLF + "Nelze hledat podle pole memo nebo logic   " + CRLF,                                                     ; // 10
      CRLF + "Zбznam nenalezen   " + CRLF,                                                                            ; // 11
      "Vyberte pole k zaшazenн do seznamu",                                                                           ; // 12
      "Vyberte pole k vyшazenн ze seznamu",                                                                           ; // 13
      "Vyberte tiskбrnu",                                                                                             ; // 14
      "Stisknмte tlaинtko pro zaшazenн pole",                                                                         ; // 15
      "Stisknмtм tlaинtko k vyшazenн pole",                                                                           ; // 16
      "Stisknмte tlaинtko k vэbмru prvnнho zбznamu k tisku",                                                          ; // 17
      "Stisknмtм tlaинtko k vэbмru poslednнho zбznamu k tisku",                                                       ; // 18
      CRLF + "K zaшazenн nezbэvajн pole   " + CRLF,                                                                   ; // 19
      CRLF + "Prvnн vэbмr pole k zaшazenн   " + CRLF,                                                                 ; // 20
      CRLF + "Nelze vyшadit dalљн pole   " + CRLF,                                                                    ; // 21
      CRLF + "Prvnн vэbмr pole k vyшazenн   " + CRLF,                                                                 ; // 22
      CRLF + "Nebylo vybrбno ћбdnй pole   " + CRLF + "Prosнm vyberte pole pro zaшazenн do tisku   " + CRLF,           ; // 23
      CRLF + "Pшнliљ mnoho polн   " + CRLF + "odeberte nмkterб pole   " + CRLF,                                       ; // 24
      CRLF + "Tiskбrna nenн pшipravena   " + CRLF,                                                                    ; // 25
      "Tшнdмno dle",                                                                                                  ; // 26
      "Od zбznamu",                                                                                                   ; // 27
      "Do zбznamu",                                                                                                   ; // 28
      "Ano",                                                                                                          ; // 29
      "Ne",                                                                                                           ; // 30
      "Strana:",                                                                                                      ; // 31
      CRLF + "Prosнm vyberte tiskбrnu   " + CRLF,                                                                     ; // 32
      "Filtrovбno dle",                                                                                               ; // 33
      CRLF + "Filtr nenн aktivnн    " + CRLF,                                                                         ; // 34
      CRLF + "Nelze filtrovat podle memo    " + CRLF,                                                                 ; // 35
      CRLF + "Vyberte pole do filtru    " + CRLF,                                                                     ; // 36
      CRLF + "Vybarte operбtor do filtru    " + CRLF,                                                                 ; // 37
      CRLF + "Zadejte hodnotu do filtru    " + CRLF,                                                                  ; // 38
      CRLF + "Nenн ћбdnэ aktivnн filtr    " + CRLF,                                                                   ; // 39
      CRLF + "Deactivovat filtr?   " + CRLF,                                                                          ; // 40
      CRLF + "Zбznam uzamиen jinэm uћivatelem  " + CRLF,                                                              ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF                     } // 42

   CASE cLang == "HR"  // Croatian
      /////////////////////////////////////////////////////////////
      // CROATIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Are you sure ?'
      _HMG_MESSAGE [2] := 'Zatvori prozor'
      _HMG_MESSAGE [3] := 'Zatvaranje nije dozvoljeno'
      _HMG_MESSAGE [4] := 'Program je veж pokrenut'
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

      _HMG_MESSAGE [1] := 'Etes-vous sыre ?'
      _HMG_MESSAGE [2] := 'Fermer la fenкtre'
      _HMG_MESSAGE [3] := 'Fermeture interdite'
      _HMG_MESSAGE [4] := 'Programme dйjа activй'
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
      _HMG_BRWLangError  := { "Fenкtre: "                                             , ;
         " n'est pas dйfinie. Programme terminй"                 , ;
         "Erreur MiniGUI"                                        , ;
         "Contrфle: "                                            , ;
         " De "                                                  , ;
         " Dйjа dйfini. Programme terminй"                       , ;
         "Modification: Type non autorisй. Programme terminй"    , ;
         "Modification: La clause Ajout ne peut кtre utilisйe avec des champs n'appartenant pas а la zone de travail de Modification. Programme terminй", ;
         "L'enregistrement est utilisй par un autre utilisateur"  , ;
         "Erreur"                                                , ;
         "Entrйe invalide"                                        }
      _HMG_BRWLangMessage := { 'Etes-vous sыre ?' , 'Enregistrement dйtruit' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Suppression d'enregistrement" + Chr( 13 ) + "Etes-vous sыre ?" + Chr( 13 )  , ;
         Chr( 13 ) + "Index manquant" + Chr( 13 ) + "Recherche impossible" + Chr( 13 )            , ;
         Chr( 13 ) + "Champ Index introuvable" + Chr( 13 ) + "Recherche impossible" + Chr( 13 )   , ;
         Chr( 13 ) + "Recherche impossible" + Chr( 13 ) + "sur champs memo ou logique" + Chr( 13 ), ;
         Chr( 13 ) + "Enregistrement non trouvй" + Chr( 13 )                                                     , ;
         Chr( 13 ) + "Trop de colonnes" + Chr( 13 ) + "L'йtat ne peut кtre imprimй" + Chr( 13 )      }
      _HMG_aABMLangLabel  := { "Enregistrement"                       , ;
         "Nb. total enr."                       , ;
         "   (Ajouter)"                        , ;
         "  (Modifier)"                        , ;
         "Entrez le numйro de l'enregistrement" , ;
         "Trouver"                              , ;
         "Chercher texte"                       , ;
         "Chercher date"                        , ;
         "Chercher numйro"                      , ;
         "Dйfinition de l'йtat"                 , ;
         "Colonnes de l'йtat"                   , ;
         "Colonnes disponibles"                 , ;
         "Enregistrement de dйbut"              , ;
         "Enregistrement de fin"                , ;
         "Etat de "                             , ;
         "Date:"                                , ;
         "Enregistrement de dйbut:"             , ;
         "Enregistrement de fin:"               , ;
         "Triй par:"                            , ;
         "Oui"                                  , ;
         "Non"                                  , ;
         " Page"                                , ;
         " de "                                 }
      _HMG_aABMLangButton := { "Fermer"      , ;
         "Nouveau"     , ;
         "Modifier"    , ;
         "Supprimer"   , ;
         "Trouver"     , ;
         "Aller а"     , ;
         "Etat"   , ;
         "Premier"     , ;
         "Prйcйdent"   , ;
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
         "EDIT, йvйnement principal nombre hors limite (Rapport d'erreur merci)"  , ;
         "EDIT, liste d'йvйnements nombre hors limite (Rapport d'erreur merci)"   }

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
         "&Dйactiver Filtre",; // 11
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
      "Champs а imprimer",                       ; // 12
      "Imprimantes connectйes",                  ; // 13
      "Premier enregistrement а imprimer",       ; // 14
      "Dernier enregistrement а imprimer",       ; // 15
      "Enregistrement supprimй",                 ; // 16
      "Prйvisualisation",                        ; // 17
      "Aperзu pages",                            ; // 18
      "Condition filtre : ",                     ; // 19
      "Filtrй : ",                               ; // 20
      "Options de filtrage" ,                    ; // 21
      "Champs de la Bdd" ,                       ; // 22
      "Opйrateurs de comparaison",               ; // 23
      "Valeur du filtre",                        ; // 24
      "Selectionner le champ а filtrer",         ; // 25
      "Selectionner l'opйrateur de comparaison", ; // 26
      "Egal",                                    ; // 27
      "Diffйrent",                               ; // 28
      "Plus grand",                              ; // 29
      "Plus petit",                              ; // 30
      "Plus grand ou йgal",                      ; // 31
      "Plus petit ou йgal"                       } // 32
      _HMG_aLangUser := { ;
         CRLF + "Ne peut trouver une base active.   "  + CRLF + "Sйlectionner une base avant la fonction EDIT  " + CRLF,            ; // 1
      "Entrer la valeur du champ (du texte)",                                                                                       ; // 2
      "Entrer la valeur du champ (un nombre)",                                                                                      ; // 3
      "Sйlectionner la date",                                                                                                       ; // 4
      "Vйrifier la valeur logique",                                                                                                 ; // 5
      "Entrer la valeur du champ",                                                                                                  ; // 6
      "Sйlectionner un enregistrement et appuyer sur OK",                                                                           ; // 7
      CRLF + "Vous voulez dйtruire l'enregistrement actif  " + CRLF + "Etes-vous sыre?   " + CRLF,                                  ; // 8
      CRLF + "Il n'y a pas d'ordre actif   " + CRLF + "Sйlectionner en un   " + CRLF,                                               ; // 9
      CRLF + "Ne peut faire de recherche sur champ memo ou logique   " + CRLF,                                                      ; // 10
      CRLF + "Enregistrement non trouvй  " + CRLF,                                                                                  ; // 11
      "Sйlectionner le champ а inclure а la liste",                                                                                 ; // 12
      "Sйlectionner le champ а exclure de la liste",                                                                                ; // 13
      "Sйlectionner l'imprimante",                                                                                                  ; // 14
      "Appuyer sur le bouton pour inclure un champ",                                                                                ; // 15
      "Appuyer sur le bouton pour exclure un champ",                                                                                ; // 16
      "Appuyer sur le bouton pour sйlectionner le premier enregistrement а imprimer",                                               ; // 17
      "Appuyer sur le bouton pour sйlectionner le dernier champ а imprimer",                                                        ; // 18
      CRLF + "Plus de champs а inclure   " + CRLF,                                                                                  ; // 19
      CRLF + "Sйlectionner d'abord les champs а inclure   " + CRLF,                                                                 ; // 20
      CRLF + "Plus de champs а exclure   " + CRLF,                                                                                  ; // 21
      CRLF + "Sйlectionner d'abord les champs а exclure   " + CRLF,                                                                 ; // 22
      CRLF + "Vous n'avez sйlectionnй aucun champ   " + CRLF + "Sйlectionner les champs а inclure dans l'impression   " + CRLF,     ; // 23
      CRLF + "Trop de champs   " + CRLF + "Rйduiser le nombre de champs   " + CRLF,                                                 ; // 24
      CRLF + "Imprimante pas prкte   " + CRLF,                                                                                      ; // 25
      "Triй par",                                                                                                                   ; // 26
      "De l'enregistrement",                                                                                                        ; // 27
      "A l'enregistrement",                                                                                                         ; // 28
      "Oui",                                                                                                                        ; // 29
      "Non",                                                                                                                        ; // 30
      "Page:",                                                                                                                      ; // 31
      CRLF + "Sйlectionner une imprimante   " + CRLF,                                                                               ; // 32
      "Filtrй par",                                                                                                                 ; // 33
      CRLF + "Il y a un filtre actif    " + CRLF,                                                                                   ; // 34
      CRLF + "Filtre impossible sur champ memo    " + CRLF,                                                                         ; // 35
      CRLF + "Sйlectionner un champ de filtre    " + CRLF,                                                                          ; // 36
      CRLF + "Sйlectionner un opйrateur de filtre   " + CRLF,                                                                       ; // 37
      CRLF + "Entrer une valeur au filtre    " + CRLF,                                                                              ; // 38
      CRLF + "Il n'y a aucun filtre actif    " + CRLF,                                                                              ; // 39
      CRLF + "Dйsactiver le filtre?   " + CRLF,                                                                                     ; // 40
      CRLF + "Record locked by another user    " + CRLF,                                                                            ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF                                   } // 42

   CASE cLang == "DE"  // German
      /////////////////////////////////////////////////////////////
      // GERMAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Sind Sie sicher ?'
      _HMG_MESSAGE [2] := 'Fenster schlieЯen'
      _HMG_MESSAGE [3] := 'SchlieЯen nicht erlaubt'
      _HMG_MESSAGE [4] := 'Programm lдuft bereits'
      _HMG_MESSAGE [5] := 'Bearbeiten'
      _HMG_MESSAGE [6] := 'OK'
      _HMG_MESSAGE [7] := 'Abbruch'
      _HMG_MESSAGE [8] := 'Anwenden'
      _HMG_MESSAGE [9] := 'Seite'
      _HMG_MESSAGE [10] := 'Warnung'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Anhдngen"  , ;
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
         "Ungьltiger Eintrag"                                          }
      _HMG_BRWLangMessage := { 'Sind Sie sicher ?' , 'Datensatz lцschen' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Datensatz lцschen" + Chr( 13 ) + "Sind Sie sicher ?" + Chr( 13 ), ;
         Chr( 13 ) + "Index Datei fehlt" + Chr( 13 ) + "Suche nicht mцglich" + Chr( 13 ), ;
         Chr( 13 ) + "Finde Indexdatenfeld nicht" + Chr( 13 ) + "Suche nicht mцglich" + Chr( 13 ), ;
         Chr( 13 ) + "Suche in Memo oder Logic " + Chr( 13 ) + "Feld nicht mцglich" + Chr( 13 ), ;
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
         "Verfьgbare Spalten"     , ;
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
      _HMG_aABMLangButton := { "SchlieЯen"    , ;
         "Neu"      , ;
         "Bearbeiten"     , ;
         "Lцschen"   , ;
         "Suchen"     , ;
         "Gehe zu"     , ;
         "Report"   , ;
         "Erster"    , ;
         "Davor" , ;
         "Nдchster"     , ;
         "Letzter"     , ;
         "Speichern"     , ;
         "Abbrechen"   , ;
         "Hinzufьgen"      , ;
         "Entfernen"   , ;
         "Drucken"    , ;
         "SchlieЯen"     }
      _HMG_aABMLangError  := { "EDIT, Workarea Name fehlt" , ;
         "EDIT, Workarea hat mehr als 16 Felder" , ;
         "EDIT, Aktualisierung ausserhalb des Bereichs (siehe Fehlermeldungen)" , ;
         "EDIT, Haupt Ereignis ausserhalb des Bereichs (siehe Fehlermeldungen)" , ;
         "EDIT, Listen Ereignis ausserhalb des Bereichs (siehe Fehlermeldungen)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := {  ;
      "S&chlieЯen",          ; // 1
      "&Neu",                ; // 2
      "&Bearbeiten",         ; // 3
      "&Lцschen",            ; // 4
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
      "Datensatz auswдhlen",                           ; // 8
      "Datensatz finden",                              ; // 9
      "Druckeinstellungen",                            ; // 10
      "Verfьgbare Felder",                             ; // 11
      "Zu druckende Felder",                           ; // 12
      "Verfьgbare Drucker",                            ; // 13
      "Erster zu druckender Datensatz",                ; // 14
      "Letzter zu druckender Datensatz",               ; // 15
      "Datensatz lцschen",                             ; // 16
      "Vorschau",                                      ; // 17
      "Ьbersicht",                                     ; // 18
      "Filterbedingung: ",                             ; // 19
      "Gefiltert: ",                                   ; // 20
      "Filter-Einstellungen" ,                         ; // 21
      "Datenbank-Felder" ,                             ; // 22
      "Vergleichs-Operator",                           ; // 23
      "Filterwert",                                    ; // 24
      "Zu filterndes Feld auswдhlen",                  ; // 25
      "Vergleichs-Operator auswдhlen",                 ; // 26
      "Gleich",                                        ; // 27
      "Ungleich",                                      ; // 28
      "GrцЯer als",                                    ; // 29
      "Kleiner als",                                   ; // 30
      "GrцЯer oder gleich als",                        ; // 31
      "Kleiner oder gleich als"                        } // 32
      _HMG_aLangUser := { ;
         CRLF + "Kein aktiver Arbeitsbereich gefunden.   "  + CRLF + "Bitte einen Arbeitsbereich auswдhlen vor dem Aufruf von EDIT   " + CRLF,    ; // 1
      "Einen Text eingeben (alphanumerisch)",                                                                                                     ; // 2
      "Eine Zahl eingeben",                                                                                                                       ; // 3
      "Datum auswдhlen",                                                                                                                          ; // 4
      "Fьr positive Auswahl einen Haken setzen",                                                                                                  ; // 5
      "Einen Text eingeben (alphanumerisch)",                                                                                                     ; // 6
      "Einen Datensatz wдhlen und mit OK bestдtigen",                                                                                             ; // 7
      CRLF + "Sie sind im Begriff, den aktiven Datensatz zu lцschen.   " + CRLF + "Sind Sie sicher?    " + CRLF,                                  ; // 8
      CRLF + "Es ist keine Sortierung aktiv.   " + CRLF + "Bitte wдhlen Sie eine Sortierung   " + CRLF,                                           ; // 9
      CRLF + "Suche nach den Feldern memo oder logisch nicht mцglich.   " + CRLF,                                                                 ; // 10
      CRLF + "Datensatz nicht gefunden   " + CRLF,                                                                                                ; // 11
      "Bitte ein Feld zum Hinzufьgen zur Liste wдhlen",                                                                                           ; // 12
      "Bitte ein Feld zum Entfernen aus der Liste wдhlen ",                                                                                       ; // 13
      "Drucker auswдhlen",                                                                                                                        ; // 14
      "Schaltflдche  Feld hinzufьgen",                                                                                                            ; // 15
      "Schaltflдche  Feld Entfernen",                                                                                                             ; // 16
      "Schaltflдche  Auswahl erster zu druckender Datensatz",                                                                                     ; // 17
      "Schaltflдche  Auswahl letzte zu druckender Datensatz",                                                                                     ; // 18
      CRLF + "Keine Felder zum Hinzufьgen mehr vorhanden   " + CRLF,                                                                              ; // 19
      CRLF + "Bitte erst ein Feld zum Hinzufьgen wдhlen   " + CRLF,                                                                               ; // 20
      CRLF + "Keine Felder zum Entfernen vorhanden   " + CRLF,                                                                                    ; // 21
      CRLF + "Bitte ein Feld zum Entfernen wдhlen   " + CRLF,                                                                                     ; // 22
      CRLF + "Kein Feld ausgewдhlt   " + CRLF + "Bitte die Felder fьr den Ausdruck auswдhlen   " + CRLF,                                          ; // 23
      CRLF + "Zu viele Felder   " + CRLF + "Bitte Anzahl der Felder reduzieren   " + CRLF,                                                        ; // 24
      CRLF + "Drucker nicht bereit   " + CRLF,                                                                                                    ; // 25
      "Sortiert nach",                                                                                                                            ; // 26
      "Von Datensatz",                                                                                                                            ; // 27
      "Bis Datensatz",                                                                                                                            ; // 28
      "Ja",                                                                                                                                       ; // 29
      "Nein",                                                                                                                                     ; // 30
      "Seite:",                                                                                                                                   ; // 31
      CRLF + "Bitte einen Drucker wдhlen   " + CRLF,                                                                                              ; // 32
      "Filtern nach",                                                                                                                             ; // 33
      CRLF + "Es ist kein aktiver Filter vorhanden    " + CRLF,                                                                                   ; // 34
      CRLF + "Kann nicht nach Memo-Feldern filtern    " + CRLF,                                                                                   ; // 35
      CRLF + "Feld zum Filtern auswдhlen    " + CRLF,                                                                                             ; // 36
      CRLF + "Einen Operator zum Filtern auswдhlen    " + CRLF,                                                                                   ; // 37
      CRLF + "Bitte einen Wert fьr den Filter angeben    " + CRLF,                                                                                ; // 38
      CRLF + "Es ist kein aktiver Filter vorhanden    " + CRLF,                                                                                   ; // 39
      CRLF + "Filter deaktivieren?   " + CRLF,                                                                                                    ; // 40
      CRLF + "Datensatz gesperrt durch anderen Benutzer    " + CRLF,                                                                              ; // 41
      CRLF + "Gelцschten Datensatz wiederherstellen   " + CRLF + "Sind sie sicher?    " + CRLF                                                    } // 42

   CASE cLang == "IT"  // Italian
      /////////////////////////////////////////////////////////////
      // ITALIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Sei sicuro ?'
      _HMG_MESSAGE [2] := 'Chiudi la finestra'
      _HMG_MESSAGE [3] := 'Chiusura non consentita'
      _HMG_MESSAGE [4] := 'Il programma и giа in esecuzione'
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
         " non Љ definita. Programma terminato" , ;
         "Errore MiniGUI"  , ;
         "Controllo: " , ;
         " Di " , ;
         " Gi… definito. Programma Terminato" , ;
         "Browse: Tipo non valido. Programma Terminato"  , ;
         "Browse: Modifica non possibile: il campo non Љ pertinente l'area di lavoro.Programma Terminato", ;
         "Record gi… utilizzato da altro utente"                 , ;
         "Attenzione!"                                           , ;
         "Dato non valido" }
      _HMG_BRWLangMessage := { 'Sei sicuro ?' , 'Cancella Record' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Cancellare il record" + Chr( 13 ) + "Sei sicuro ?" + Chr( 13 )      , ;
         Chr( 13 ) + "File indice mancante" + Chr( 13 ) + "Ricerca impossibile" + Chr( 13 )   , ;
         Chr( 13 ) + "Campo indice mancante" + Chr( 13 ) + "Ricerca impossibile" + Chr( 13 )  , ;
         Chr( 13 ) + "Ricerca impossibile per" + Chr( 13 ) + "campi memo o logici" + Chr( 13 ), ;
         Chr( 13 ) + "Record non trovato" + Chr( 13 )                                   , ;
         Chr( 13 ) + "Troppe colonne" + Chr( 13 ) + "Il report non puт essere stampato" + Chr( 13 ) }
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
         "Sм"                 , ;
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
      _HMG_aABMLangError  := { "EDIT, il nome dell'area и mancante" , ;
         "EDIT, quest'area contiene piщ di 16 campi" , ;
         "EDIT, modalitа aggiornamento fuori dal limite (segnalare l'errore)" , ;
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

      _HMG_MESSAGE [1] := 'Czy jesteњ pewny ?'
      _HMG_MESSAGE [2] := 'Zamknij okno'
      _HMG_MESSAGE [3] := 'Zamkniкcie niedozwolone'
      _HMG_MESSAGE [4] := 'Program juї uruchomiony'
      _HMG_MESSAGE [5] := 'Edycja'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Porzuж'
      _HMG_MESSAGE [8] := 'Zastosuj'
      _HMG_MESSAGE [9] := 'Str.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Dodaj"   , ;
         "Edycja"     , ;
         "Porzuж"   , ;
         "OK"        }
      _HMG_BRWLangError  := { "Okno: "                                              , ;
         " nie zdefiniowane.Program zakoсczony"         , ;
         "Bі№d MiniGUI"                                         , ;
         "Kontrolka: "                                             , ;
         " z "                                                  , ;
         " juї zdefiniowana. Program zakoсczony"                  , ;
         "Browse: Niedozwolony typ danych. Program zakoсczony"          , ;
         "Browse: Klauzula Append nie moїe byж stosowana do pуl nie naleї№cych do aktualnego obszaru roboczego. Program zakoсczony", ;
         "Rekord edytowany przez innego uїytkownika"                , ;
         "Ostrzeїenie"                                               , ;
         "Nieprawidіowy wpis"                                          }
      _HMG_BRWLangMessage := { 'Czy jesteњ pewny ?' , 'Skasuj rekord' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Usuniкcie rekordu" + Chr( 13 ) + "Jesteњ pewny ?" + Chr( 13 )                 , ;
         Chr( 13 ) + "Bікdny zbiуr indeksowy" + Chr( 13 ) + "Nie moїna szukaж" + Chr( 13 )         , ;
         Chr( 13 ) + "Nie moїna znaleџж pola indeksu" + Chr( 13 ) + "Nie moїna szukaж" + Chr( 13 ) , ;
         Chr( 13 ) + "Nie moїna szukaж wg" + Chr( 13 ) + "pola memo lub logicznego" + Chr( 13 )         , ;
         Chr( 13 ) + "Rekordu nie znaleziono" + Chr( 13 )                                                     , ;
         Chr( 13 ) + "Zbyt wiele kolumn" + Chr( 13 ) + "Raport nie mieњci siк na arkuszu" + Chr( 13 )      }
      _HMG_aABMLangLabel  := { "Rekord"              , ;
         "Liczba rekordуw"        , ;
         "      (Nowy)"        , ;
         "    (Edycja)"        , ;
         "Wprowadџ numer rekordu" , ;
         "Szukaj"                , ;
         "Szukaj tekstu"         , ;
         "Szukaj daty"         , ;
         "Szukaj liczby"       , ;
         "Definicja Raportu"   , ;
         "Kolumny Raportu"      , ;
         "Dostкpne kolumny"     , ;
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
         "Usuс"   , ;
         "Znajdџ"     , ;
         "Idџ do"     , ;
         "Raport"   , ;
         "Pierwszy"    , ;
         "Poprzedni" , ;
         "Nastкpny"     , ;
         "Ostatni"     , ;
         "Zapisz"     , ;
         "Rezygnuj"   , ;
         "Dodaj"      , ;
         "Usuс"   , ;
         "Drukuj"    , ;
         "Zamknij"     }
      _HMG_aABMLangError  := { "EDIT, bікdna nazwa bazy"                                  , ;
         "EDIT, baza ma wiкcej niї 16 pуl"                   , ;
         "EDIT, tryb odњwierzania poza zakresem (zobacz raport bікdуw)"      , ;
         "EDIT, liczba zdarzeс podstawowych poza zakresem (zobacz raport bікdуw)" , ;
         "EDIT, lista zdarzeд poza zakresem (zobacz raport bікdуw)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := {          ;
         "&Zamknij",        ; // 1
      "&Nowy",           ; // 2
      "&Modyfikuj",      ; // 3
      "&Kasuj",          ; // 4
      "&Znajdџ",         ; // 5
      "&Drukuj",         ; // 6
      "&Porzuж",         ; // 7
      "&Ok",             ; // 8
      "&Kopiuj",         ; // 9
      "&Aktywuj Filtr",  ; // 10
      "&Deaktywuj Filtr", ; // 11
      "&Przywrуж"        } // 12

      _HMG_aLangLabel := {                       ;
         "Brak",                        ; // 1
      "Rekord",                      ; // 2
      "Suma",                        ; // 3
      "Aktywny indeks",              ; // 4
      "Opcje",                       ; // 5
      "Nowy rekord",                 ; // 6
      "Modyfikuj rekord",            ; // 7
      "Wybierz rekord",              ; // 8
      "Znajdџ rekord",               ; // 9
      "Opcje druku",                 ; // 10
      "Dostкpne pola",               ; // 11
      "Pola do druku",               ; // 12
      "Dostкpne drukarki",           ; // 13
      "Pierwszy rekord do druku",    ; // 14
      "Ostatni rekord do druku",     ; // 15
      "Skasuj rekord",               ; // 16
      "Podgl№d",                     ; // 17
      "Pokaї miniatury",             ; // 18
      "Stan filtru: ",               ; // 19
      "Filtrowane: ",                ; // 20
      "Opcje filtrowania" ,          ; // 21
      "Pola bazy danych" ,           ; // 22
      "Operator porуwnania",         ; // 23
      "Wartoњж filtru",              ; // 24
      "Wybierz pola do filtru",      ; // 25
      "Wybierz operator porуwnania", ; // 26
      "Rуwna siк",                   ; // 27
      "Nie rуwna siк",               ; // 28
      "Wiкkszy ",                    ; // 29
      "Mniejszy ",                   ; // 30
      "Wiкkszy lub rуwny ",          ; // 31
      "Mniejszy lub rуwny"           } // 32
      _HMG_aLangUser := { ;
         CRLF + "Aktywny obszar nie odnaleziony   "  + CRLF + "Wybierz obszar przed wywoіaniem EDIT   " + CRLF,   ; // 1
      "Poszukiwany ci№g znakуw (dowolny tekst)",                                                               ; // 2
      "Poszukiwana wartoњж (dowolna liczba)",                                                                  ; // 3
      "Wybierz datк",                                                                                          ; // 4
      "Check for true value",                                                                                  ; // 5
      "Wprowadџ wartoњж",                                                                                      ; // 6
      "Wybierz dowolny rekord i naciњcij OK",                                                                  ; // 7
      CRLF + "Wybraіeњ opcjк kasowania rekordu   " + CRLF + "Czy jesteњ pewien ?    " + CRLF,                  ; // 8
      CRLF + "Brak aktywnych indeksуw   " + CRLF + "Wybierz    " + CRLF,                                       ; // 9
      CRLF + "Nie moїna szukaж w polach typu MEMO lub LOGIC   " + CRLF,                                        ; // 10
      CRLF + "Rekord nie znaleziony   " + CRLF,                                                                ; // 11
      "Wybierz rekord ktуry naleїy dodaж do listy",                                                            ; // 12
      "Wybierz rekord ktуry naleїy wyі№czyж z listy",                                                          ; // 13
      "Wybierz drukarkк",                                                                                      ; // 14
      "Kliknij na przycisk by dodaж pole",                                                                     ; // 15
      "Kliknij na przycisk by odj№ж pole",                                                                     ; // 16
      "Kliknij, aby wybraж pierwszy rekord do druku",                                                          ; // 17
      "Kliknij, aby wybraж ostatni rekord do druku",                                                           ; // 18
      CRLF + "Brak pуl do wі№czenia   " + CRLF,                                                                ; // 19
      CRLF + "Najpierw wybierz pola do wі№czenia   " + CRLF,                                                   ; // 20
      CRLF + "Brak pуl do wyі№czenia   " + CRLF,                                                               ; // 21
      CRLF + "Najpierw wybierz pola do wyі№czenia   " + CRLF,                                                  ; // 22
      CRLF + "Nie wybraіeњ їadnych pуl   " + CRLF + "Najpierw wybierz pola do wі№czenia do wydruku   " + CRLF, ; // 23
      CRLF + "Za wiele pуl   " + CRLF + "Zredukuj liczbк pуl   " + CRLF,                                       ; // 24
      CRLF + "Drukarka nie gotowa   " + CRLF,                                                                  ; // 25
      "Porz№dek wg",                                                                                           ; // 26
      "Od rekordu",                                                                                            ; // 27
      "Do rekordu",                                                                                            ; // 28
      "Tak",                                                                                                   ; // 29
      "Nie",                                                                                                   ; // 30
      "Strona:",                                                                                               ; // 31
      CRLF + "Wybierz drukarkк   " + CRLF,                                                                     ; // 32
      "Filtrowanie wg",                                                                                        ; // 33
      CRLF + "Brak aktywnego filtru    " + CRLF,                                                               ; // 34
      CRLF + "Nie moїna filtrowaж wg. pуl typu MEMO    " + CRLF,                                               ; // 35
      CRLF + "Wybierz pola dla filtru    " + CRLF,                                                             ; // 36
      CRLF + "Wybierz operator porуwnania dla filtru    " + CRLF,                                              ; // 37
      CRLF + "Wpisz dowoln№ wartoњж dla filtru    " + CRLF,                                                    ; // 38
      CRLF + "Brak aktywnego filtru    " + CRLF,                                                               ; // 39
      CRLF + "Deaktywowaж filtr?   " + CRLF,                                                                   ; // 40
      CRLF + "Rekord zablokowany przez innego uїytkownika" + CRLF,                                             ; // 41
      CRLF + "Czy przwrуciж skasowny   " + CRLF + "Czy jesteњ pewien?    " + CRLF                              } // 42

   CASE cLang == "PT"  // Portuguese
      /////////////////////////////////////////////////////////////
      // PORTUGUESE
      ////////////////////////////////////////////////////////////
 
      // MISC MESSAGES
 
      _HMG_MESSAGE [1] := "Vocк tem Certeza ?"
      _HMG_MESSAGE [2] := "Fechar Janela"
      _HMG_MESSAGE [3] := "Fechamento nгo permitido"
      _HMG_MESSAGE [4] := "Programa jб estб em execuзгo"
      _HMG_MESSAGE [5] := "Edita"
      _HMG_MESSAGE [6] := "Ok"
      _HMG_MESSAGE [7] := "Cancela"
      _HMG_MESSAGE [8] := "Aplicar"
      _HMG_MESSAGE [9] := "Pбg."
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'
 
      // BROWSE
 
      _HMG_BRWLangButton  := { "Incluir"  , ;
         "Alterar"  , ;
         "Cancelar" , ;
         "OK"        }
      _HMG_BRWLangError   := { "Window: "                                         , ;
         " Erro nгo definido. Programa serб fechado"        , ;
         "Erro na MiniGUI.lib"                              , ;
         "Controle: "                                       , ;
         "Desligado "                                       , ;
         "Nгo pronto. Programa serб fechado"                , ;
         "Browse: Tipo Invбlido !!!. Programa serб fechado" , ;
         "Browse: Ediзгo nгo pode ser efetivada, campo nгo pertence a essa бrea. Programa serб fechado" , ;
         "Arquivo em uso nгo pode ser editado !!!"          , ;
         "Aguarde..."                                       , ;
         "Dado Invбlido"                                     }
      _HMG_BRWLangMessage := { "Vocк tem Certeza ?" , "Apaga Registro" }
 
      // EDIT
 
      _HMG_aABMLangUser   := { Chr( 13 ) + "Serб apagado o registro atual" + Chr( 13 ) + "Tem certeza ?"                          + Chr( 13 ) , ;
         Chr( 13 ) + "Nгo existe um нndice ativo"    + Chr( 13 ) + "Nгo й possнvel realizar a busca"        + Chr( 13 ) , ;
         Chr( 13 ) + "Nгo encontrado o campo нndice" + Chr( 13 ) + "Nгo й possнvel realizar a busca"        + Chr( 13 ) , ;
         Chr( 13 ) + "Nгo й possнvel realizar busca" + Chr( 13 ) + "por campos memo ou lуgicos"             + Chr( 13 ) , ;
         Chr( 13 ) + "Registro nгo encontrado"       + Chr( 13 )                                                      , ;
         Chr( 13 ) + "Incluнdas colunas em excesso"  + Chr( 13 ) + "A listagem completa nгo caberб na tela" + Chr( 13 )  }
      _HMG_aABMLangLabel  := { "Registro Atual"                 , ;
         "Total Registros"                , ;
         "(Novo)"                         , ;
         "(Editar)"                       , ;
         "Introduza o nъmero do registro" , ;
         "Buscar"                         , ;
         "Texto a buscar"                 , ;
         "Data a buscar"                  , ;
         "Nъmero a buscar"                , ;
         "Definiзгo da lista"             , ;
         "Colunas da lista"               , ;
         "Colunas disponнveis"            , ;
         "Registro inicial"               , ;
         "Registro final"                 , ;
         "Lista de "                      , ;
         "Data:"                          , ;
         "Primeiro registro:"             , ;
         "Ъltimo registro:"               , ;
         "Ordenado por:"                  , ;
         "Sim"                            , ;
         "Nгo"                            , ;
         "Pбgina "                        , ;
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
         "Ъltimo"           , ;
         "Guardar"          , ;
         "Cancelar"         , ;
         "Juntar"           , ;
         "Sair"             , ;
         "Imprimir"         , ;
         "Fechar"            }
      _HMG_aABMLangError  := { "EDIT, nгo foi especificada a бrea"                                      , ;
         "EDIT, A бrea contйm mais de 16 campos"                                  , ;
         "EDIT, Atualizaзгo fora do limite (por favor, comunique o erro)"         , ;
         "EDIT, Evento principal fora do limite (por favor, comunique o erro)"    , ;
         "EDIT, Evento mostrado estб fora do limite (por favor, comunique o erro)" }
 
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
      "Нndice ativo",                       ; // 4
      "Opзгo",                              ; // 5
      "Novo registro",                      ; // 6
      "Modificar registro",                 ; // 7
      "Selecionar registro",                ; // 8
      "Localizar registro",                 ; // 9
      "Opзгo de impressгo",                 ; // 10
      "Campos disponнveis",                 ; // 11
      "Campos selecionados",                ; // 12
      "Impressoras disponнveis",            ; // 13
      "Primeiro registro a imprimir",       ; // 14
      "Ъltimo registro a imprimir",         ; // 15
      "Apagar registro",                    ; // 16
      "Visualizar impressгo",               ; // 17
      "Pбginas em miniatura",               ; // 18
      "Condiзгo do filtro: ",               ; // 19
      "Filtrado: ",                         ; // 20
      "Opзхes do filtro" ,                  ; // 21
      "Campos da tabela" ,                  ; // 22
      "Operador de comparaзгo",             ; // 23
      "Valor de comparaзгo",                ; // 24
      "Selecione o campo a filtrar",        ; // 25
      "Selecione o operador de comparaзгo", ; // 26
      "Igual",                              ; // 27
      "Diferente",                          ; // 28
      "Maior que",                          ; // 29
      "Menor que",                          ; // 30
      "Maior ou igual que",                 ; // 31
      "Menor ou igual que"                  } // 32
      _HMG_aLangUser      := {  CRLF + "Nгo hб uma бrea ativa   "  + CRLF + "Por favor, selecione uma бrea antes de chamar a EDIT EXTENDED   " + CRLF, ; // 1
      "Introduza o valor do campo (texto)",                                                                                  ; // 2
      "Introduza o valor do campo (numйrico)",                                                                               ; // 3
      "Selecione a data",                                                                                                    ; // 4
      "Ative o indicador para valor verdadeiro",                                                                             ; // 5
      "Introduza o valor do campo",                                                                                          ; // 6
      "Selecione um registro e tecle Ok",                                                                                    ; // 7
      CRLF + "Confirma apagar o registro ativo   " + CRLF + "Tem certeza?     " + CRLF,                                      ; // 8
      CRLF + "Nгo hб um нndice selecionado    " + CRLF + "Por favor, selecione um   " + CRLF,                                ; // 9
      CRLF + "Nгo se pode realizar busca por campos tipo memo ou lуgico   " + CRLF,                                          ; // 10
      CRLF + "Registro nгo encontrado   " + CRLF,                                                                            ; // 11
      "Selecione o campo a incluir na lista",                                                                                ; // 12
      "Selecione o campo a excluir da lista",                                                                                ; // 13
      "Selecione a impressora",                                                                                              ; // 14
      "Pressione o botгo para incluir o campo",                                                                              ; // 15
      "Pressione o botгo para excluir o campo",                                                                              ; // 16
      "Pressione o botгo para selecionar o primeiro registro a imprimir",                                                    ; // 17
      "Pressione o botгo para selecionar o ъltimo registro a imprimir",                                                      ; // 18
      CRLF + "Foram incluнdos todos os campos   " + CRLF,                                                                    ; // 19
      CRLF + "Primeiro seleccione o campo a incluir   " + CRLF,                                                              ; // 20
      CRLF + "Nгo hб campos para excluir   " + CRLF,                                                                         ; // 21
      CRLF + "Primeiro selecione o campo a excluir   " + CRLF,                                                               ; // 22
      CRLF + "Nгo foi selecionado nenhum campo   " + CRLF,                                                                   ; // 23
      CRLF + "A lista nгo cabe na pбgina   " + CRLF + "Reduza o nъmero de campos   " + CRLF,                                 ; // 24
      CRLF + "A impressora nгo estб disponнvel   " + CRLF,                                                                   ; // 25
      "Ordenado por",                                                                                                        ; // 26
      "Do registro",                                                                                                         ; // 27
      "Atй registro",                                                                                                        ; // 28
      "Sim",                                                                                                                 ; // 29
      "Nгo",                                                                                                                 ; // 30
      "Pбgina:",                                                                                                             ; // 31
      CRLF + "Por favor, selecione uma impressora   " + CRLF,                                                                ; // 32
      "Filtrado por",                                                                                                        ; // 33
      CRLF + "Nгo hб um filtro ativo    " + CRLF,                                                                            ; // 34
      CRLF + "Nгo se pode filtrar por campos memo    " + CRLF,                                                               ; // 35
      CRLF + "Selecione o campo a filtrar    " + CRLF,                                                                       ; // 36
      CRLF + "Selecione o operador de comparaзгo    " + CRLF,                                                                ; // 37
      CRLF + "Introduza o valor do filtro    " + CRLF,                                                                       ; // 38
      CRLF + "Nгo hб nenhum filtro ativo    " + CRLF,                                                                        ; // 39
      CRLF + "Eliminar o filtro ativo ?   " + CRLF,                                                                          ; // 40
      CRLF + "Registro bloqueado por outro usuбrio    " + CRLF,                                                              ; // 41
      CRLF + "Vocк vai restabelecer o registro apagado   " + CRLF + "Tem certeza ?    " + CRLF                               } // 42

   CASE cLang == "RU"  // Russian
      /////////////////////////////////////////////////////////////
      // RUSSIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Вы уверены ?'
      _HMG_MESSAGE [2] := 'Закрыть окно'
      _HMG_MESSAGE [3] := 'Закрытие не допускается'
      _HMG_MESSAGE [4] := 'Программа уже запущена'
      _HMG_MESSAGE [5] := 'Изменить'
      _HMG_MESSAGE [6] := 'Да'
      _HMG_MESSAGE [7] := 'Отмена'
      _HMG_MESSAGE [8] := 'Применить'
      _HMG_MESSAGE [9] := 'Стр.'
      _HMG_MESSAGE [10] := 'Внимание'
      _HMG_MESSAGE [11] := 'Информация'
      _HMG_MESSAGE [12] := 'Стоп'

      // BROWSE

      _HMG_BRWLangButton := { ;
         "Добавить" , ;
         "Изменить" , ;
         "Отмена"   , ;
         "OK" }
      _HMG_BRWLangError  := { ;
         "Окно: "                                                  , ;
         " не определено. Программа прервана"                      , ;
         "MiniGUI Ошибка"                                          , ;
         "Элемент управления: "                                    , ;
         " из "                                                    , ;
         " Уже определен. Программа прервана"                      , ;
         "Browse: Такой тип не поддерживается. Программа прервана" , ;
         "Browse: Append класс не может использоваться с полями из другой рабочей области. Программа прервана", ;
         "Запись сейчас редактируется другим пользователем"        , ;
         "Предупреждение"                                          , ;
         "Введены неправильные данные" }
      _HMG_BRWLangMessage := { 'Вы уверены ?' , 'Удалить запись' }

      // EDIT

      _HMG_aABMLangUser := { ;
         Chr( 13 ) + "Удаление записи." + Chr( 13 ) + "Вы уверены ?" + Chr( 13 )                       , ;
         Chr( 13 ) + "Отсутствует индексный файл" + Chr( 13 ) + "Поиск невозможен" + Chr( 13 )         , ;
         Chr( 13 ) + "Отсутствует индексное поле" + Chr( 13 ) + "Поиск невозможен" + Chr( 13 )         , ;
         Chr( 13 ) + "Поиск невозможен в" + Chr( 13 ) + "примечаниях или логических полях" + Chr( 13 ) , ;
         Chr( 13 ) + "Запись не найдена" + Chr( 13 )                                                   , ;
         Chr( 13 ) + "Слишком много колонок" + Chr( 13 ) + "Отчет не поместится на листе" + Chr( 13 ) }
      _HMG_aABMLangLabel := { ;
         "Запись"              , ;
         "Всего записей"       , ;
         "     (Новая)"        , ;
         "  (Изменить)"        , ;
         "Введите номер записи", ;
         "Поиск"               , ;
         "Найти текст"         , ;
         "Найти дату"          , ;
         "Найти число"         , ;
         "Настройка отчета"    , ;
         "Колонки отчета"      , ;
         "Доступные колонки"   , ;
         "Начальная запись"    , ;
         "Конечная запись"     , ;
         "Отчет для "          , ;
         "Дата:"               , ;
         "Первая запись:"      , ;
         "Конечная запись:"    , ;
         "Группировка по:"     , ;
         "Да"                  , ;
         "Нет"                 , ;
         "Страница "           , ;
         " из "                 }
      _HMG_aABMLangButton := { ;
         "Закрыть"   , ;
         "Новая"     , ;
         "Изменить"  , ;
         "Удалить"   , ;
         "Поиск"     , ;
         "Перейти"   , ;
         "Отчет"     , ;
         "Первая"    , ;
         "Назад"     , ;
         "Вперед"    , ;
         "Последняя" , ;
         "Сохранить" , ;
         "Отмена"    , ;
         "Добавить"  , ;
         "Удалить"   , ;
         "Печать"    , ;
         "Закрыть"    }
      _HMG_aABMLangError := { ;
         "EDIT, не указано имя рабочей области"                     , ;
         "EDIT, допускается не более 16 полей"                      , ;
         "EDIT, режим обновления вне диапазона (сообщите об ошибке)", ;
         "EDIT, номер события вне диапазона (сообщите об ошибке)"   , ;
         "EDIT, номер события листинга вне диапазона (сообщите об ошибке)" }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Закрыть",           ; // 1
         "&Создать",           ; // 2
         "&Правка",            ; // 3
         "&Удалить",           ; // 4
         "&Найти",             ; // 5
         "П&ечать",            ; // 6
         "От&мена",            ; // 7
         "&Ок",                ; // 8
         "&Копия",             ; // 9
         "&Вкл. фильтр",       ; // 10
         "С&нять фильтр",      ; // 11
         "&Восстановить"       } // 12
      _HMG_aLangLabel := { ;
         "Нет",                          ; // 1
         "Запись",                       ; // 2
         "Всего",                        ; // 3
         "Упорядочение",                 ; // 4
         "Параметры",                    ; // 5
         "Новая запись",                 ; // 6
         "Изменить запись",              ; // 7
         "Выбрать запись",               ; // 8
         "Найти запись",                 ; // 9
         "Параметры печати",             ; // 10
         "Доступные поля",               ; // 11
         "Поля для печати",              ; // 12
         "Доступные принтеры",           ; // 13
         "Начать печать с записи",       ; // 14
         "Завершить печать записью",     ; // 15
         "Удалить запись",               ; // 16
         "Просмотр",                     ; // 17
         "Страница миниатюр",            ; // 18
         "Условие фильтра: ",            ; // 19
         "Фильтр: ",                     ; // 20
         "Параметры фильтра" ,           ; // 21
         "Поля базы данных" ,            ; // 22
         "Операторы сравнения",          ; // 23
         "Значение фильтра",             ; // 24
         "Выбор поля для фильтра",       ; // 25
         "Выбор оператора сравнения",    ; // 26
         "Равно",                        ; // 27
         "Не равно",                     ; // 28
         "Больше",                       ; // 29
         "Меньше",                       ; // 30
         "Больше или равно",             ; // 31
         "Меньше или равно"           }    // 32
      _HMG_aLangUser := { ;
         CRLF + "Не обнаружена активная область."  + CRLF + "Выберите любую область перед обращением к EDIT" + CRLF, ; // 1
         "Введите текстовое значения",                                                                               ; // 2
         "Введите число",                                                                                            ; // 3
         "Укажите дату",                                                                                             ; // 4
         "Логическое значение",                                                                                      ; // 5
         "Введите значение поля",                                                                                    ; // 6
         "Выберите любую запись и нажмите OK",                                                                       ; // 7
         CRLF + "Текущая запись будет удалена " + CRLF + "Продолжать ?    " + CRLF,                                  ; // 8
         CRLF + "Нет упорядочения " + CRLF + "Выберите одно из существующих " + CRLF,                                ; // 9
         CRLF + "Поиск в полях примечаний и логических полях не выполняется " + CRLF,                                ; // 10
         CRLF + "Запись не найдена  " + CRLF,                                                                        ; // 11
         "Поля для включение в список печати",                                                                       ; // 12
         "Список полей для печати",                                                                                  ; // 13
         "Выбор принтера",                                                                                           ; // 14
         "Нажмите для переноса поля в список печати",                                                                ; // 15
         "Нажмите для исключения поля из списка печати",                                                             ; // 16
         "Запись, с которой начинается печать",                                                                      ; // 17
         "Запись, на которой завершается печать",                                                                    ; // 18
         CRLF + "Включаемых полей нет " + CRLF,                                                                      ; // 19
         CRLF + "Первое поле на включение " + CRLF,                                                                  ; // 20
         CRLF + "Исключаемых полей нет " + CRLF,                                                                     ; // 21
         CRLF + "Первое поле на исключение " + CRLF,                                                                 ; // 22
         CRLF + "Нет выбранных полей " + CRLF + "Сформируйте список для печати " + CRLF,                             ; // 23
         CRLF + "Слишком много полей " + CRLF + "Уменьшите их количество " + CRLF,                                   ; // 24
         CRLF + "Принтер не готов  " + CRLF,                                                                         ; // 25
         "Упорядочение ",                                                                                            ; // 26
         "От записи ",                                                                                               ; // 27
         "До записи ",                                                                                               ; // 28
         "Да",                                                                                                       ; // 29
         "Нет",                                                                                                      ; // 30
         "Страница:",                                                                                                ; // 31
         CRLF + "Выберите принтер  " + CRLF,                                                                         ; // 32
         "Отфильтровано по",                                                                                         ; // 33
         CRLF + "Это не активный фильтр    " + CRLF,                                                                 ; // 34
         CRLF + "Поля примечаний не фильтруются  " + CRLF,                                                           ; // 35
         CRLF + "Выберите поля для фильтра    " + CRLF,                                                              ; // 36
         CRLF + "Выберите любой оператор для фильтра" + CRLF,                                                        ; // 37
         CRLF + "Наберите любое значение для фильтра" + CRLF,                                                        ; // 38
         CRLF + "Нет активных фильтров   " + CRLF,                                                                   ; // 39
         CRLF + "Снять фильтр ?   " + CRLF,                                                                          ; // 40
         CRLF + "Запись блокирована другим пользователем " + CRLF,                                                   ; // 41
         CRLF + "Текущая запись будет восстановлена " + CRLF + "Продолжать ?    " + CRLF                             } // 42

   CASE cLang == "UK" .OR. cLang == "UA"  // Ukrainian
      /////////////////////////////////////////////////////////////
      // UKRAINIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE[ 1 ] := 'Ви впевненi ?'
      _HMG_MESSAGE[ 2 ] := 'Закрити вiкно.'
      _HMG_MESSAGE[ 3 ] := 'Закриття не дозволяється.'
      _HMG_MESSAGE[ 4 ] := ( 'Програма виконується.' + CRLF + 'Запуск ще однiєї копiї заборонено.' )
      _HMG_MESSAGE[ 5 ] := 'Змiнити'
      _HMG_MESSAGE[ 6 ] := 'Гаразд'
      _HMG_MESSAGE[ 7 ] := 'Скасувати'
      _HMG_MESSAGE[ 8 ] := 'Застосувати'
      _HMG_MESSAGE[ 9 ] := 'Стор.'
      _HMG_MESSAGE [10] := 'Увага!'
      _HMG_MESSAGE [11] := 'Iнформація'
      _HMG_MESSAGE [12] := 'Стоп'

      // BROWSE

      _HMG_BRWLangButton := { "Додати"    , ;
         "Змiнити"   , ;
         "Скасувати" , ;
         "Гаразд"    }
      _HMG_BRWLangError  := { "Вiкно: "                                              , ;
         " не визначене. Програму зупинено"                        , ;
         "MiniGUI помилка"                                         , ;
         "Елемент управлiння: "                                    , ;
         " з "                                                     , ;
         " вже визначений. Програму зупинено"                      , ;
         "Browse: Такий тип не пiдтримується. Програму зупинено"   , ;
         "Browse: Append клас не використовується з полями iншої рабочої областi. Програму зупинено", ;
         "Запис зараз редагується iншим користувачем"              , ;
         "Попередження"                                            , ;
         "Введено помилковi данi"                                 }
      _HMG_BRWLangMessage := { 'Ви впевненi ?' , 'Видалити запис' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Видалення запису." + Chr( 13 ) + "Ви впевненi ?" + Chr( 13 )             , ;
         Chr( 13 ) + "Вiдсутнiй iндексний файл" + Chr( 13 ) + "Пошук неможливий" + Chr( 13 )       , ;
         Chr( 13 ) + "Вiдсутнє iндексне поле" + Chr( 13 ) + "Пошук неможливий" + Chr( 13 )         , ;
         Chr( 13 ) + "Пошук неможливий в" + Chr( 13 ) + "примiтках або логiчних полях" + Chr( 13 ) , ;
         Chr( 13 ) + "Запис не знайдено" + Chr( 13 )                                         , ;
         Chr( 13 ) + "Занадто багато колонок" + Chr( 13 ) + "Звiт не розмiститься на аркушi" + Chr( 13 ) }
      _HMG_aABMLangLabel  := { "Запис"           , ;
         "Всього записiв"      , ;
         "     (Нова)"         , ;
         "  (Змiнити)"         , ;
         "Вкажiть номер запису", ;
         "Пошук"               , ;
         "Знайти текст"        , ;
         "Знайти дату"         , ;
         "Знайти число"        , ;
         "Налаштування звiту"  , ;
         "Колонки звiту"       , ;
         "Доступнi колонки"    , ;
         "Початковий запис"    , ;
         "Концевий запис"      , ;
         "Звiт для "           , ;
         "Дата:"               , ;
         "Перший запис:"       , ;
         "Концевий запис:"     , ;
         "Згруповано за:"      , ;
         "Так"                 , ;
         "Нi"                  , ;
         "Сторiнка "           , ;
         " з "                  }
      _HMG_aABMLangButton := { "Закрити", ;
         "Нова"       , ;
         "Змiнити"    , ;
         "Видалити"   , ;
         "Пошук"      , ;
         "Перейти"    , ;
         "Звiт"       , ;
         "Перша"      , ;
         "Назад"      , ;
         "Вперед"     , ;
         "Остання"    , ;
         "Зберегти"   , ;
         "Вiдмова"    , ;
         "Додати"     , ;
         "Видалити"   , ;
         "Друк"       , ;
         "Закрити"     }
      _HMG_aABMLangError  := { "EDIT, не вказане iм'я робочої областi"                    , ;
         "EDIT, дозволяється не бiльше 16 полiв"                        , ;
         "EDIT, режим оновления поза дiапазоном (повiдомьте про помилку)", ;
         "EDIT, номер подiї поза дiапазоном (повiдомьте про помилку)"    , ;
         "EDIT, номер подiї лiстингу поза дiапазоном (повiдомьте про помилку)" }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Закрити",           ; // 1
      "&Створити",          ; // 2
      "&Правка",            ; // 3
      "&Видалити",          ; // 4
      "З&найти",            ; // 5
      "&Друк",              ; // 6
      "С&касувати",         ; // 7
      "&Гаразд",            ; // 8
      "&Копiя",             ; // 9
      "Вст. &фiльтр",       ; // 10
      "Зня&ти фiльтр",      ; // 11
      "Від&новити"     }      // 12
      _HMG_aLangLabel := {                   ;
         "Нi",                              ; // 1
      "Запис",                           ; // 2
      "Всього",                          ; // 3
      "Впорядкування",                   ; // 4
      "Параметри",                       ; // 5
      "Новий запис",                     ; // 6
      "Змiнити запис",                   ; // 7
      "Вибрати запис",                   ; // 8
      "Знайти запис",                    ; // 9
      "Параметри друку",                 ; // 10
      "Доступнi поля",                   ; // 11
      "Поля для друку",                  ; // 12
      "Доступнi принтери",               ; // 13
      "Розпочати друк з запису",         ; // 14
      "Завершити друк записом",          ; // 15
      "Видалити запис",                  ; // 16
      "Перегляд",                        ; // 17
      "Сторiнка мiнiатюр",               ; // 18
      "Умова фiльтру: ",                 ; // 19
      "Фiльтр: ",                        ; // 20
      "Параметри фiльтру" ,              ; // 21
      "Поля бази даних" ,                ; // 22
      "Оператори спiвставлення",         ; // 23
      "Значення фiльтру",                ; // 24
      "Вибiр поля для фильтру",          ; // 25
      "Вибiр оператора спiвставлення",   ; // 26
      "Дорiвнює",                        ; // 27
      "Не дорiвнює",                     ; // 28
      "Бiльше",                          ; // 29
      "Менше",                           ; // 30
      "Бiльше або дорiвнює",             ; // 31
      "Менше або дорiвнює"           }     // 32
      _HMG_aLangUser := { ;
         CRLF + "Не виявлено активної областi."  + CRLF + "Оберiть будь-яку область перед зверненням до EDIT" + CRLF, ; // 1
      "Введiть текстове значення",                                                                                 ; // 2
      "Введiть число",                                                                                             ; // 3
      "Вкажiть дату",                                                                                              ; // 4
      "Логiчне значення",                                                                                          ; // 5
      "Введiть значення поля",                                                                                     ; // 6
      "Оберiть будь-який запис i натиснiть OK",                                                                    ; // 7
      CRLF + "Поточний запис буде видалено " + CRLF + "Продовжити ?    " + CRLF,                                   ; // 8
      CRLF + "Вiдсутнє впорядкуваня " + CRLF + "Оберiть одне з iснуючих " + CRLF,                                  ; // 9
      CRLF + "Пошук в полях примiток i логiчних полях не виконується " + CRLF,                                     ; // 10
      CRLF + "Запис не знайдено  " + CRLF,                                                                         ; // 11
      "Поля, доступнi для друку",                                                                                  ; // 12
      "Список полiв для друку",                                                                                    ; // 13
      "Вибiр принтеру",                                                                                            ; // 14
      "Натиснiть для перенесення поля в список друку",                                                             ; // 15
      "Натиснiть для вилучення поля з списку друку",                                                               ; // 16
      "Запис, з якого розпочинається друк",                                                                        ; // 17
      "Запис, яким завершується друк",                                                                             ; // 18
      CRLF + "Вiдсутнi доступнi поля " + CRLF,                                                                     ; // 19
      CRLF + "Перше поле до включення " + CRLF,                                                                    ; // 20
      CRLF + "Вiдсутнi поля для виключення " + CRLF,                                                               ; // 21
      CRLF + "Перше поле для вилучення " + CRLF,                                                                   ; // 22
      CRLF + "Вiдсутнi вибранi поля " + CRLF + "Сформуйте список для друку " + CRLF,                               ; // 23
      CRLF + "Занадто багато полiв " + CRLF + "Зменшiть їх кiлькiсть " + CRLF,                                     ; // 24
      CRLF + "Принтер не пiдготовано " + CRLF,                                                                     ; // 25
      "Впорядкування ",                                                                                            ; // 26
      "Вiд запису ",                                                                                               ; // 27
      "До запису ",                                                                                                ; // 28
      "Так",                                                                                                       ; // 29
      "Нi",                                                                                                        ; // 30
      "Сторiнка:",                                                                                                 ; // 31
      CRLF + "Виберiть принтер  " + CRLF,                                                                          ; // 32
      "Вiдфiльтровано за",                                                                                         ; // 33
      CRLF + "Це не активний фiльтр   " + CRLF,                                                                    ; // 34
      CRLF + "Поля примiток не фiльтруються  " + CRLF,                                                             ; // 35
      CRLF + "Вкажiть поля для фiльтру    " + CRLF,                                                                ; // 36
      CRLF + "Вкажiть оператор для фiльтру" + CRLF,                                                                ; // 37
      CRLF + "Вкажiть значення для фiльтру" + CRLF,                                                                ; // 38
      CRLF + "Вiдсутнi активнi фiльтри   " + CRLF,                                                                 ; // 39
      CRLF + "Зняти фiльтр ?   " + CRLF,                                                                           ; // 40
      CRLF + "Запис заблоковано iншим користувачем " + CRLF,                                                       ; // 41
      CRLF + "Поточний запис буде відновлено " + CRLF + "Продовжити ?    " + CRLF                                  } // 42

   CASE cLang == "ES"  // Spanish
      /////////////////////////////////////////////////////////////
      // SPANISH
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Estб seguro ?'
      _HMG_MESSAGE [2] := 'Cerrar Ventana'
      _HMG_MESSAGE [3] := 'Operaciуn no permitida'
      _HMG_MESSAGE [4] := 'EL programa ya estб ejecutбndose'
      _HMG_MESSAGE [5] := 'Editar'
      _HMG_MESSAGE [6] := 'Aceptar'
      _HMG_MESSAGE [7] := 'Cancelar'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Pag.'
      _HMG_MESSAGE [10] := 'Atencion'
      _HMG_MESSAGE [11] := 'Informaciуn'
      _HMG_MESSAGE [12] := 'Detener'

      // BROWSE  

      _HMG_BRWLangButton := { "Agregar"    , ;
         "Editar"     , ;
         "Cancelar"   , ;
         "Aceptar"     }
      _HMG_BRWLangError  := { "Window: "                                              , ;
         " no estб definida. Ejecuciуn terminada"                , ;
         "MiniGUI Error"                                         , ;
         "Control: "                                             , ;
         " De "                                                  , ;
         " ya definido. Ejecuciуn terminada"                     , ;
         "Browse: Tipo no permitido. Ejecuciуn terminada"        , ;
         "Browse: La calusula APPEND no puede ser usada con campos no pertenecientes al area del BROWSE. Ejecuciуn terminada", ;
         "El registro estб siendo editado por otro usuario"      , ;
         "Peligro"                                               , ;
         "Entrada no vбlida"                                      }
      _HMG_BRWLangMessage := { 'Estб Seguro ?' , 'Eliminar Registro' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Va a eliminar el registro actual" + Chr( 13 ) + "ї Estб seguro ?" + Chr( 13 )                 , ;
         Chr( 13 ) + "No hay un indice activo" + Chr( 13 ) + "No se puede realizar la busqueda" + Chr( 13 )         , ;
         Chr( 13 ) + "No se encuentra el campo indice" + Chr( 13 ) + "No se puede realizar la busqueda" + Chr( 13 ) , ;
         Chr( 13 ) + "No se pueden realizar busquedas" + Chr( 13 ) + "por campos memo o lуgico" + Chr( 13 )         , ;
         Chr( 13 ) + "Registro no encontrado" + Chr( 13 )                                                     , ;
         Chr( 13 ) + "Ha inclido demasiadas columnas" + Chr( 13 ) + "El listado no cabe en la hoja" + Chr( 13 )      }
      _HMG_aABMLangLabel  := { "Registro Actual"                  , ;
         "Registros Totales"                , ;
         "     (Nuevo)"                     , ;
         "    (Editar)"                     , ;
         "Introducca el nъmero de registro" , ;
         "Buscar"                           , ;
         "Texto a buscar"                   , ;
         "Fecha a buscar"                   , ;
         "Nъmero a buscar"                  , ;
         "Definiciуn del listado"           , ;
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
         "Aсadir"           , ;
         "Quitar"           , ;
         "Imprimir"         , ;
         "Cerrar"            }
      _HMG_aABMLangError  := { "EDIT, No se ha especificado el area"                                  , ;
         "EDIT, El area contiene mбs de 16 campos"                              , ;
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
      "Opciones de impresiуn",                 ; // 10
      "Campos disponibles",                    ; // 11
      "Campos del listado",                    ; // 12
      "Impresoras disponibles",                ; // 13
      "Primer registro a imprimir",            ; // 14
      "Ultimo registro a imprimir",            ; // 15
      "Borrar registro",                       ; // 16
      "Vista previa",                          ; // 17
      "Pбginas en miniatura",                  ; // 18
      "Condiciуn del filtro: ",                ; // 19
      "Filtrado: ",                            ; // 20
      "Opciones de filtrado" ,                 ; // 21
      "Campos de la bdd" ,                     ; // 22
      "Operador de comparaciуn",               ; // 23
      "Valor de comparaciуn",                  ; // 24
      "Seleccione el campo a filtrar",         ; // 25
      "Seleccione el operador de comparaciуn", ; // 26
      "Igual",                                 ; // 27
      "Distinto",                              ; // 28
      "Mayor que",                             ; // 29
      "Menor que",                             ; // 30
      "Mayor o igual que",                     ; // 31
      "Menor o igual que"                      } // 32
      _HMG_aLangUser := { ;
         CRLF + "No hay un area activa   "  + CRLF + "Por favor seleccione un area antes de llamar a EDIT EXTENDED   " + CRLF,       ; // 1
      "Introduzca el valor del campo (texto)",                                                                                      ; // 2
      "Introduzca el valor del campo (numйrico)",                                                                                    ; // 3
      "Seleccione la fecha",                                                                                                      ; // 4
      "Active la casilla para indicar un valor verdadero",                                                                                                 ; // 5
      "Introduzca el valor del campo",                                                                                                ; // 6
      "Seleccione un registro y pulse aceptar",                                                                                       ; // 7
      CRLF + "Se dispone a borrar el registro activo   " + CRLF + "їEsta seguro?    " + CRLF,                  ; // 8
      CRLF + "No se ha seleccionado un indice   " + CRLF + "Por favor seleccione uno   " + CRLF,                            ; // 9
      CRLF + "No se pueden realizar busquedad por campos tipo memo o lуgico   " + CRLF,                                                   ; // 10
      CRLF + "Registro no encontrado   " + CRLF,                                                                            ; // 11
      "Seleccione el campo a incluir en el listado",                                                                                  ; // 12
      "Seleccione el campo a excluir del listado",                                                                                ; // 13
      "Seleccione la impresora",                                                                                                   ; // 14
      "Pulse el botуn para incluir el campo",                                                                                         ; // 15
      "Pulse el botуn para excluir el campo",                                                                                         ; // 16
      "Pulse el botуn para seleccionar el primer registro a imprimir",                                                                      ; // 17
      "Pulse el botуn para seleccionar el ъltimo registro a imprimir",                                                                       ; // 18
      CRLF + "Ha incluido todos los campos   " + CRLF,                                                                   ; // 19
      CRLF + "Primero seleccione el campo a incluir   " + CRLF,                                                           ; // 20
      CRLF + "No hay campos para excluir   " + CRLF,                                                                    ; // 21
      CRLF + "Primero seleccione el campo a excluir   " + CRLF,                                                            ; // 22
      CRLF + "No ha seleccionado ningъn campo   " + CRLF,                                              ; // 23
      CRLF + "El listado no cabe en la pбgina   " + CRLF + "Reduzca el numero de campos   " + CRLF,                                   ; // 24
      CRLF + "La impresora no estб disponible   " + CRLF,                                                                           ; // 25
      "Ordenado por",                                                                                                           ; // 26
      "Del registro",                                                                                                          ; // 27
      "Al registro",                                                                                                            ; // 28
      "Si",                                                                                                                  ; // 29
      "No",                                                                                                                   ; // 30
      "Pбgina:",                                                                                                                ; // 31
      CRLF + "Por favor seleccione una impresora   " + CRLF,                                                                     ; // 32
      "Filtrado por",                                                                                                          ; // 33
      CRLF + "No hay un filtro activo    " + CRLF,                                                                  ; // 34
      CRLF + "No se puede filtrar por campos memo    " + CRLF,                                                                ; // 35
      CRLF + "Seleccione el campo a filtrar    " + CRLF,                                                                 ; // 36
      CRLF + "Seleccione el operador de comparaciуn    " + CRLF,                                                              ; // 37
      CRLF + "Introduzca el valor del filtro    " + CRLF,                                                                 ; // 38
      CRLF + "No hay ningъn filtro activo    " + CRLF,                                                              ; // 39
      CRLF + "їEliminar el filtro activo?   " + CRLF,                                                                           ; // 40
      CRLF + "Registro bloqueado por otro usuario    " + CRLF,                                                                   ; // 41
      CRLF + "Se dispone a restaurar el registro suprimido   " + CRLF + "їEsta seguro?    " + CRLF,                  } // 42

   CASE cLang == "FI"  // Finnish
      ///////////////////////////////////////////////////////////////////////
      // FINNISH
      ///////////////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Oletko varma ?'
      _HMG_MESSAGE [2] := 'Sulje ikkuna'
      _HMG_MESSAGE [3] := 'Sulkeminen ei sallittu'
      _HMG_MESSAGE [4] := 'Ohjelma on jo kдynnissд'
      _HMG_MESSAGE [5] := 'Korjaa'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Keskeytд'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Sivu.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Lisдд"  , ;
         "Korjaa" , ;
         " Keskeytд" , ;
         " OK" }

      _HMG_BRWLangError  := { "Ikkuna: " , ;
         " mддrittelemдtцn. Ohjelma lopetettu" , ;
         "MiniGUI Virhe", ;
         "Kontrolli: ", ;
         " / " , ;
         " On jo mддritelty. Ohjelma lopetettu" , ;
         "Browse: Virheellinen tyyppi. Ohjelma lopetettu" , ;
         "Browse: Et voi lisдtд kenttiд jotka eivдt ole BROWSEN mддrityksessд. Ohjelma lopetettu", ;
         "Toinen kдyttдjд korjaa juuri tietuetta" , ;
         "Varoitus" , ;
         "Virheellinen arvo" }

      _HMG_BRWLangMessage := { 'Oletko varma ?' , 'Poista tietue' }

      // EDIT
      _HMG_aABMLangUser   := { Chr( 13 ) + "Poista tietue" + Chr( 13 ) + "Oletko varma?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Indeksi tiedosto puuttuu" + Chr( 13 ) + "En voihakea" + Chr( 13 )            , ;
         Chr( 13 ) + "Indeksikenttд ei lцydy" + Chr( 13 ) + "En voihakea" + Chr( 13 )        , ;
         Chr( 13 ) + "En voi hakea memo" + Chr( 13 ) + "tai loogisen kentдn mukaan" + Chr( 13 )       , ;
         Chr( 13 ) + "Tietue ei lцydy" + Chr( 13 ), ;
         Chr( 13 ) + "Liian monta saraketta" + Chr( 13 ) + "raportti ei mahdu sivulle" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Tietue"              , ;
         "Tietue lukumддrд"    , ;
         "       (Uusi)"       , ;
         "      (Korjaa)"      , ;
         "Anna tietue numero"  , ;
         "Hae"                 , ;
         "Hae teksti"          , ;
         "Hae pдivдys"         , ;
         "Hae numero"          , ;
         "Raportti mддritys"   , ;
         "Raportti sarake"     , ;
         "Sallitut sarakkeet"  , ;
         "Alku tietue"         , ;
         "Loppu tietue"        , ;
         "Raportti "           , ;
         "Pvm:"                , ;
         "Alku tietue:"        , ;
         "Loppu tietue:"       , ;
         "Lajittelu:"         , ;
         "Kyllд"                 , ;
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
         "Ensimmдinen" , ;
         "Edellinen"   , ;
         "Seuraava"    , ;
         "Viimeinen"   , ;
         "Tallenna"    , ;
         "Keskeytд"    , ;
         "Lisдд"       , ;
         "Poista"      , ;
         "Tulosta"     , ;
         "Sulje"     }
      _HMG_aABMLangError  := { "EDIT, tyцalue puuttuu"   , ;
         "EDIT, tyцalueella yli 16 kenttдд", ;
         "EDIT, pдivitysalue ylitys (raportoi virhe)"      , ;
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
      " Keskeytд",         ; // 7
      " Ok",               ; // 8
      " Kopioi",           ; // 9
      " Aktivoi suodin",   ; // 10
      " Deaktivoi suodin", ; // 11
      " Restore"           } // 12

      _HMG_aLangLabel := {                        ;
         "Ei mitддn",                         ; // 1
      "Tietue",                       ; // 2
      "Yhteensд",                        ; // 3
      "Aktiivinen lajittelu",                 ; // 4
      "Optiot",                      ; // 5
      "Uusi tietue",                   ; // 6
      "Muuta tietue",                ; // 7
      "Valitse tietue",                ; // 8
      "Hae tietue",                  ; // 9
      "Tulostus optiot",                ; // 10
      "Valittavat kentдt",               ; // 11
      "Tulostettavat kentдt",              ; // 12
      "Valittavat tulostimet",           ; // 13
      "Ensim. tulostettava tietue",        ; // 14
      "Viim. tulostettava tietue",         ; // 15
      "Poista tietue",                ; // 16
      "Esikatselu",                      ; // 17
      "Nдytд sivujen miniatyyrit",         ; // 18
      "Suodin ehto: ",           ; // 19
      "Suodatettu: ",                   ; // 20
      "Suodatus Optiot" ,           ; // 21
      "Tietokanta kentдt" ,             ; // 22
      "Vertailu operaattori",        ; // 23
      "Suodatus arvo",                 ; // 24
      "Valitse suodatus kenttд",       ; // 25
      "Valitse vertailu operaattori", ; // 26
      "Yhtд kuin",                        ; // 27
      "Erisuuri kuin",                    ; // 28
      "Isompi kuin",                 ; // 29
      "Pienempi kuin",                   ; // 30
      "Isompi tai sama kuin",        ; // 31
      "Pienempi tai sama kuin"           } // 32

      _HMG_aLangUser := { ;
         CRLF + "Tyцalue ei lцydy.   "  + CRLF + "Valitse tyцaluetta ennenkun kutsut Edit  " + CRLF,       ; // 1
      "Anna kenttд arvo (tekstiд)",                                  ; // 2
      "Anna kenttд arvo (numeerinen)",                                  ; // 3
      "Valitse pдivдys",                            ; // 4
      "Tarkista tosi arvo",                     ; // 5
      "Anna kenttд arvo",                    ; // 6
      "Valitse joku tietue ja paina OK",                                     ; // 7
      CRLF + "Olet poistamassa aktiivinen tietue   " + CRLF + "Oletko varma?    " + CRLF,                  ; // 8
      CRLF + "Ei aktiivista lajittelua   " + CRLF + "Valitse lajittelu   " + CRLF,                            ; // 9
      CRLF + "En voi hakea memo tai loogiseten kenttien perusteella  " + CRLF, ; // 10
      CRLF + "Tietue ei lцydy   " + CRLF,                                                ; // 11
      "Valitse listaan lisдttдvдt kentдt",                                                    ; // 12
      "Valitse EI lisдttдvдt kentдt",                                        ; // 13
      "Valitse tulostin",                   ; // 14
      "Paina nдppдin lisддtдksesi kenttд",                                                                  ; // 15
      "Paina nдppдin poistaaksesi kenttд",                                                       ; //16
      "Paina nдppдin valittaaksesi ensimmдinen tulostettava tietue",  ; // 17
      "Paina nдppдin valittaaksesi viimeinen tulostettava tietue",   ; // 18
      CRLF + "Ei lisдд kenttiд   " + CRLF,                                 ; // 19
      CRLF + "Valitse ensin lisдttдvд kenttд   " + CRLF,                                                           ; //20
      CRLF + "EI Lisдд ohitettavia kenttiд   " + CRLF, ; // 21
      CRLF + "Valitse ensin ohitettava kenttд   " + CRLF,                                                            ;//22
      CRLF + "Et valinnut kenttiд   " + CRLF + "Valitse tulosteen kentдt   " + CRLF,   ; // 23
      CRLF + "Liikaa kenttiд   " + CRLF + "Vдhennд kenttд lukumддrд   " + CRLF, ; // 24
      CRLF + "Tulostin ei valmiina   " + CRLF,                                                  ; // 25
      "Lajittelu",             ; // 26
      "Tietueesta",              ; // 27
      "Tietueeseen",                  ; // 28
      "Kyllд",                ; // 29
      "EI",       ; // 30
      "Sivu:",          ; // 31
      CRLF + "Valitse tulostin   " + CRLF,                                       ; // 32
      "Lajittelu",            ; // 33
      CRLF + "Aktiivinen suodin olemassa    " + CRLF,                                                          ; // 34
      CRLF + "En voi suodattaa memo kenttiд    " + CRLF, ;// 35
      CRLF + "Valitse suodattava kenttд    " + CRLF,                                                           ; // 36
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
         " is niet gedefinieerd. Programma beлindigd"           , ;
         "MiniGUI fout", ;
         "Control: ", ;
         " Van ", ;
         " Is al gedefinieerd. Programma beлindigd"                   , ;
         "Browse: Type niet toegestaan. Programma beлindigd"          , ;
         "Browse: Toevoegen-methode kan niet worden gebruikt voor velden die niet bij het Browse werkgebied behoren. Programma beлindigd", ;
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

      _HMG_MESSAGE [1] := 'Ste prepriиani ?'
      _HMG_MESSAGE [2] := 'Zapri okno'
      _HMG_MESSAGE [3] := 'Zapiranje ni dovoljeno'
      _HMG_MESSAGE [4] := 'Program je ћe zagnan'
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

      _HMG_BRWLangMessage := { 'Ste prepriиani ?' , 'Briљi vrstico' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Briљi vrstico" + Chr( 13 ) + "Ste prepriиani ?" + Chr( 13 ) , ;
         Chr( 13 ) + "Manjka indeksna datoteka" + Chr( 13 ) + "Ne morem iskati" + Chr( 13 )       , ;
         Chr( 13 ) + "Ne najdem indeksnega polja" + Chr( 13 ) + "Ne morem iskati" + Chr( 13 )     , ;
         Chr( 13 ) + "Ne morem iskati po" + Chr( 13 ) + "memo ali logiиnih poljih" + Chr( 13 )    , ;
         Chr( 13 ) + "Ne najdem vrstice" + Chr( 13 )                                        , ;
         Chr( 13 ) + "Preveи kolon" + Chr( 13 ) + "Poroиilo ne gre na list" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Vrstica", ;
         "Љtevilo vrstic"         , ;
         "       (Nova)"          , ;
         "      (Popravi)"        , ;
         "Vnesi љtevilko vrstice" , ;
         "Poiљиi"                 , ;
         "Besedilo za iskanje"    , ;
         "Datum za iskanje"       , ;
         "Љtevilka za iskanje"    , ;
         "Parametri poroиila"     , ;
         "Kolon v poroиilu"       , ;
         "Kolon na razpolago"     , ;
         "Zaиetna vrstica"        , ;
         "Konиna vrstica"         , ;
         "Poroиilo za "           , ;
         "Datum:"                 , ;
         "Zaиetna vrstica:"       , ;
         "Konиna vrstica:"        , ;
         "Urejeno po:"            , ;
         "Ja"                     , ;
         "Ne"                     , ;
         "Stran "                 , ;
         " od "                 }

      _HMG_aABMLangButton := { "Zapri" , ;
         "Nova"              , ;
         "Uredi"             , ;
         "Briљi"             , ;
         "Poiљиi"            , ;
         "Pojdi na"          , ;
         "Poroиilo"          , ;
         "Prva"              , ;
         "Prejљnja"          , ;
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
      "&Briљi",             ; // 4
      "&Poiљиi",            ; // 5
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
      "Moћnosti",                      ; // 5
      "Nova vrstica",                  ; // 6
      "Spreminjaj vrstico",            ; // 7
      "Oznaиi vrstico",                ; // 8
      "Najdi vrstico",                 ; // 9
      "Moћnosti tiskanja",             ; // 10
      "Polja na razpolago",            ; // 11
      "Polja za tiskanje",             ; // 12
      "Tiskalniki na razpolago",       ; // 13
      "Prva vrstica za tiskanje",      ; // 14
      "Zadnja vrstica za tiskanje",    ; // 15
      "Briљi vrstico",                 ; // 16
      "Pregled",                       ; // 17
      "Mini pregled strani",           ; // 18
      "Pogoj za filter: ",             ; // 19
      "Filtrirano: ",                  ; // 20
      "Moћnosti filtra" ,              ; // 21
      "Polja v datoteki" ,             ; // 22
      "Operator za primerjavo",        ; // 23
      "Vrednost filtra",               ; // 24
      "Izberi polje za filter",        ; // 25
      "Izberi operator za primerjavo", ; // 26
      "Enako",                         ; // 27
      "Neenako",                       ; // 28
      "Veиje od",                      ; // 29
      "Manjљe od",                     ; // 30
      "Veиje ali enako od",            ; // 31
      "Manjљe ali enako od"            } // 32
      _HMG_aLangUser := { ;
         CRLF + "Can't find an active area.   "  + CRLF + "Please select any area before call EDIT   " + CRLF,    ; // 1
      "Vnesi vrednost (tekst)",                                                                                ; // 2
      "Vnesi vrednost (љtevilka)",                                                                             ; // 3
      "Izberi datum",                                                                                          ; // 4
      "Oznaиi za logiиni DA",                                                                                  ; // 5
      "Vnesi vrednost",                                                                                        ; // 6
      "Izberi vrstico in pritisni <V redu>",                                                                   ; // 7
      CRLF + "Pobrisali boste trenutno vrstico   " + CRLF + "Ste prepriиani?    " + CRLF,                      ; // 8
      CRLF + "Ni aktivnega indeksa   " + CRLF + "Prosimo, izberite ga   " + CRLF,                              ; // 9
      CRLF + "Ne morem iskati po logiиnih oz. memo poljih   " + CRLF,                                          ; // 10
      CRLF + "Ne najdem vrstice   " + CRLF,                                                                    ; // 11
      "Izberite polje, ki BO vkljuиeno na listo",                                                              ; // 12
      "Izberite polje, ki NI vkljuиeno na listo",                                                              ; // 13
      "Izberite tisklanik",                                                                                    ; // 14
      "Pritisnite gumb za vkljuиitev polja",                                                                   ; // 15
      "Pritisnite gumb za izkljuиitev polja",                                                                  ; // 16
      "Pritisnite gumb za izbor prve vrstice za tiskanje",                                                     ; // 17
      "Pritisnite gumb za izbor zadnje vrstice za tiskanje",                                                   ; // 18
      CRLF + "Ni veи polj za dodajanje   " + CRLF,                                                             ; // 19
      CRLF + "Najprej izberite ppolje za vkljuиitev   " + CRLF,                                                ; // 20
      CRLF + "Ni veи polj za izkljuиitev   " + CRLF,                                                           ; // 21
      CRLF + "Najprej izberite polje za izkljuиitev   " + CRLF,                                                ; // 22
      CRLF + "Niste izbrali nobenega polja   " + CRLF + "Prosom, izberite polje za tiskalnje   " + CRLF,       ; // 23
      CRLF + "Preveи polj   " + CRLF + "Zmanjљajte љtevilo polj   " + CRLF,                                    ; // 24
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
      CRLF + "Obnovili boste pobrisano vrstico   " + CRLF + "Ste prepriиani?    " + CRLF                       } // 42

   CASE cLang == "SK"  // Slovak
      /////////////////////////////////////////////////////////////
      // SLOVAK
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Ste si istэ(б)?'
      _HMG_MESSAGE [2] := 'Zatvor okno'
      _HMG_MESSAGE [3] := 'Zatvorenie nedovolenй'
      _HMG_MESSAGE [4] := 'Program uћ beћн'
      _HMG_MESSAGE [5] := 'Ъprava'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Storno'
      _HMG_MESSAGE [8] := 'Aplikuj'
      _HMG_MESSAGE [9] := 'Str.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "P&ridaќ"  , ;
         "&Upraviќ" , ;
         "&Storno" , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Okno: "             , ;
         " nedefinovanй. Program ukonиenэ.", ;
         "MiniGUI Error"                   , ;
         "Prvok: "                         , ;
         " z "                             , ;
         " uћ definovanэ. Program ukonиenэ"                  , ;
         "Prezeranie: Nedovolenэ typ. Program ukonиenэ"      , ;
         "Prezeranie: Clauzula 'Pridaќ' je nepouћiteѕnб so stеpcami nepatriacimi do pracovnej oblasti browse. Program ukonиenэ", ;
         "Zбznam upravuje inэ uћнvateѕ"                      , ;
         "Varovanie"                                         , ;
         "Chybnэ vstup"                                         }
      _HMG_BRWLangMessage := { 'Ste si istэ(б) ?' , 'Zmazaќ zбznam' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Zmazaќ zбznam." + Chr( 13 ) + "Ste si istэ(б)?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Chэba indexovэ sъbor!" + Chr( 13 ) + "Nemфћem hѕadaќ." + Chr( 13 )            , ;
         Chr( 13 ) + "Nebol nбjdenэ index!" + Chr( 13 ) + "Nemфћem hѕadaќ." + Chr( 13 )        , ;
         Chr( 13 ) + "Nemфћem hѕadaќ podѕa" + Chr( 13 ) + "stеpca typu memo alebo logical." + Chr( 13 )       , ;
         Chr( 13 ) + "Zбznam nebol nбjdenэ!" + Chr( 13 )                                        , ;
         Chr( 13 ) + "Prнliљ veѕa stеpcov!" + Chr( 13 ) + "Zostava sa nezmestн na plochu" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Zбznam"   , ;
         "Poиet zбznamov"     , ;
         "      (Novэ)"       , ;
         "   (Upraviќ)"       , ;
         "Zadajte инslo zбznamu", ;
         "Hѕadaj"             , ;
         "Hѕadanэ text"       , ;
         "Hѕadanэ dбtum"      , ;
         "Hѕadanй инslo"      , ;
         "Definнcia zostavy"  , ;
         "Stеpce zostavy"     , ;
         "Dostupnй stеpce"    , ;
         "Prvэ zбznam"        , ;
         "Poslednэ zбznam"    , ;
         "Zostava "           , ;
         "Dбtum:"             , ;
         "Prvэ zбznam:"       , ;
         "Poslednэ zбznam:"   , ;
         "Zoradenй podѕa:"    , ;
         "Бno"                , ;
         "Nie"                , ;
         "Strana "            , ;
         " z "                   }

      _HMG_aABMLangButton := { "Zatvor" , ;
         "Novэ"             , ;
         "Ъprava"           , ;
         "Zruљ"             , ;
         "Nбjdi"            , ;
         "Choп na"          , ;
         "Zostava"          , ;
         "Prvэ"             , ;
         "Predoљlэ"         , ;
         "Пaѕљн"            , ;
         "Poslednэ"         , ;
         "Uloћ"             , ;
         "Storno"           , ;
         "Pridaj"           , ;
         "Odstrбт"          , ;
         "Tlaи"             , ;
         "Zatvor"     }
      _HMG_aABMLangError  := { "EDIT, chэba meno pracovnej oblasti"                              , ;
         "EDIT, pracovnб oblasќ mб viac ako 16 stеpcov"              , ;
         "EDIT, refresh mode je mimo rozsah (prosнm, nahlбste chybu)"      , ;
         "EDIT, инslo hlavnej udalosti mimo rozsah (prosнm, nahlбste chybu)" , ;
         "EDIT, инslo udalosti, list mimo rozsah (prosнm, nahlбste chybu)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Zatvor",           ; // 1
      "&Novэ",             ; // 2
      "Ъ&prava",           ; // 3
      "Zr&uљ",             ; // 4
      "Nб&jdi",            ; // 5
      "&Tlaи",             ; // 6
      "&Storno",           ; // 7
      "&Ok",               ; // 8
      "&Kopнruj",          ; // 9
      "Zapni &filter",     ; // 10
      "&Vypni filter",     ; // 11
      "O&bnov"       }       // 12
      _HMG_aLangLabel := {                     ;
         "Ћiadna",                         ; // 1
      "Veta",                           ; // 2
      "Suma",                           ; // 3
      "Aktнvne zoradenie",              ; // 4
      "Moћnosti",                       ; // 5
      "Novэ zбznam",                    ; // 6
      "Uprav zбznam",                   ; // 7
      "Vyber zбznam",                   ; // 8
      "Nбjdi zбznam",                   ; // 9
      "Tlaи volby",                     ; // 10
      "Dostupnй stеpce",                ; // 11
      "Stеpce pre tlaи",                ; // 12
      "Dostupnй tlaиiarne",             ; // 13
      "Prvэ zбznam pre tlaи",           ; // 14
      "Poslednэ zбznam pre tlaи",       ; // 15
      "Vymaћ zбznam",                   ; // 16
      "Nбhѕad",                         ; // 17
      "Zobraz miniatъry strбn",         ; // 18
      "Podmienky filtra: ",             ; // 19
      "Filtrovanй: ",                   ; // 20
      "Moћnosti filtra",                ; // 21
      "Stеpce dбtabбzy",                ; // 22
      "Operбtor porovnanie",            ; // 23
      "Hodnota filtra",                 ; // 24
      "Vэber pola do filtra",           ; // 25
      "Vэber operбtora porovnania",     ; // 26
      "rovnб sa",                       ; // 27
      "nerovnб sa",                     ; // 28
      "vдиљн ako",                      ; // 29
      "menљн ako",                      ; // 30
      "vдиљн alebo rovnэ ako",          ; // 31
      "menљн alebo rovnэ ako"          }  // 32
      _HMG_aLangUser := { ;
         CRLF + "Nenбjdenб aktнvna oblasќ   "  + CRLF + "Vyberte prosнm pred volanнm EDIT hociktorъ oblasќ   " + CRLF,     ; // 1
      "Zadajte hodnotu stеpca (ѕubovolnэ text)",                                                          ; // 2
      "Zadajte hodnotu stеpca (ѕubovolnй инslo)",                                                         ; // 3
      "Vyberte dбtum",                                                                                    ; // 4
      "Zaљkrtnite pre hodnotu 'true'",                                                                    ; // 5
      "Zadajte hodnotu stеpca",                                                                           ; // 6
      "Vyberte niektorъ vetu a stlaиte OK",                                                               ; // 7
      CRLF + "Chcete zruљiќ tento zбznam   " + CRLF + "Ste si istэ(б)?    " + CRLF,                       ; // 8
      CRLF + "Ћiadnй zoradenie nie je aktнvnй   " + CRLF + "Prosнm vyberte jedno   " + CRLF,              ; // 9
      CRLF + "Nemфћem hѕadaќ podѕa stеpca typu memo alebo logical " + CRLF,                               ; // 10
      CRLF + "Nenбjdenэ zбznam   " + CRLF,                                                                ; // 11
      "Vyberte stеpec k vloћeniu do zoznamu",                                                             ; // 12
      "Vyberte stеpec k odstrбneniu zo zoznamu",                                                          ; // 13
      "Vyberte tlaиiareт",                                                                                ; // 14
      "Stlaиte tlaиidlo zaloћenia stеpca",                                                                ; // 15
      "Stlaиte tlaиidlo odstrбnenia stеpca",                                                              ; // 16
      "Stlaиte tlaиidlo - Prvэ zбznam pre tlaи",                                                          ; // 17
      "Stlaиte tlaиidlo - Poslednэ zбznam ptre tlaи",                                                     ; // 18
      CRLF + "Nie je dostupnэ stеpec k zaloћeniu   " + CRLF,                                              ; // 19
      CRLF + "Najprv vyberte stеpec k zaloћeniu   " + CRLF,                                               ; // 20
      CRLF + "Пalљн stеpec nemфћete odstrбniќ   " + CRLF,                                                 ; // 21
      CRLF + "Najprv vyberte n. stеpec k odstrбneniu   " + CRLF,                                          ; // 22
      CRLF + "Nevybrali ste ani jeden stlpec   " + CRLF + "Prosнm vyberte stеpce pre tlaи   " + CRLF,     ; // 23
      CRLF + "Prнliљ veѕa stеpcov   " + CRLF + "odstrбтte niekterй stеpce   " + CRLF,                     ; // 24
      CRLF + "Tlaиiareт nie je pripravenб   " + CRLF,                                                     ; // 25
      "Zoradenй podѕa",                                                                                   ; // 26
      "Od zбznamu",                                                                                       ; // 27
      "Po zбznam",                                                                                        ; // 28
      "Бno",                                                                                              ; // 29
      "Nie",                                                                                              ; // 30
      "Strana:",                                                                                          ; // 31
      CRLF + "Vyberte si tlaиiareт   " + CRLF,                                                            ; // 32
      "Filtrovanй podѕa",                                                                                 ; // 33
      CRLF + "Aktivnэ filter    " + CRLF,                                                                 ; // 34
      CRLF + "Nemфћete filtrovaќ podѕa stеpca typu memo    " + CRLF,                                      ; // 35
      CRLF + "Vyberte stеpec do filtra    " + CRLF,                                                       ; // 36
      CRLF + "Vyberte operбtor do filtra    " + CRLF,                                                     ; // 37
      CRLF + "Zadajte hodnotu do filtra    " + CRLF,                                                      ; // 38
      CRLF + "Ћiadny aktнvny filter    " + CRLF,                                                          ; // 39
      CRLF + "Deaktivovaќ filter?   " + CRLF,                                                             ; // 40
      CRLF + "Zбznam blokovanэ inэm uћнvateѕom  " + CRLF,                                                 ; // 41
      CRLF + "Chcete obnoviќ vymazanй zбznamy   " + CRLF + "Ste si istэ(б)?    " + CRLF                   } // 42

   CASE cLang == "HU"  // Hungarian
      /////////////////////////////////////////////////////////////
      // HUNGARIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Biztos benne?'
      _HMG_MESSAGE [2] := 'Zбrja be az ablakot'
      _HMG_MESSAGE [3] := 'Bezбrбs tiltva'
      _HMG_MESSAGE [4] := 'Program mбr fut'
      _HMG_MESSAGE [5] := 'Szerkesztйs'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Mйgse'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Old.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES

      _HMG_BRWLangButton := { "Hozzбad"  , ;
         "Szerkesztйs" , ;
         "&Mйgse" , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Ablak: "                            , ;
         " nem definiбlt. Program vйge" , ;
         "MiniGUI Error"                   , ;
         "Elem: "                         , ;
         " ebbхl "                             , ;
         " mбr definiбlt. Program vйge"                  , ;
         "Bцngйszх: Tiltott tнpus. Program vйge"      , ;
         "Bцngйszх: Hozzбad frбzis nem hasznбlhatу olyan mezхre, mely nincs a Bцngйszх munkaterьletйben. Program vйge", ;
         "A rekordot egy mбsik felhasznбlу szerkeszti"                      , ;
         "Figyelmeztetйs"                                         , ;
         "Hibбs adat"                                         }
      _HMG_BRWLangMessage := { 'Biztos benne ?' , 'Rekord tцrlйse' }

      // EDIT MESSAGES

      _HMG_aABMLangUser   := { Chr( 13 ) + "Rekord tцrlйse" + Chr( 13 ) + "Biztos benne ?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Hiбnyzу index бllomбny" + Chr( 13 ) + "Lehetetlen a keresйs" + Chr( 13 )            , ;
         Chr( 13 ) + "Hiбnyzу index mezх" + Chr( 13 ) + "Lehetetlen a keresйs" + Chr( 13 )        , ;
         Chr( 13 ) + "Lehetetlen a keresйs a kцv.alapjбn" + Chr( 13 ) + "mezх memo vagy logikai" + Chr( 13 )       , ;
         Chr( 13 ) + "Nincs rekord" + Chr( 13 )                                        , ;
         Chr( 13 ) + "Tъl sok oszlop" + Chr( 13 ) + "A jelentйs nem fйr el a felьleten" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "Rekord"         , ;
         "Rekord szбmlбlу"          , ;
         "           (Ъj)"          , ;
         "  (Szerkesztйs)"          , ;
         "Adja meg a rekord szбmбt" , ;
         "Keresd"                   , ;
         "Keresett szцveg"          , ;
         "Keresett dбtum"           , ;
         "Keresett szбm"            , ;
         "A jelentйs meghatбrozбsa" , ;
         "A jelentйs oszlopai"      , ;
         "Hasznбlhatу oszlopok"     , ;
         "Kezdх rekord"             , ;
         "Utolsу rekord"            , ;
         "Jelentйs a "              , ;
         "Dбtum:"                   , ;
         "Kezdх rekord:"            , ;
         "Utolsу rekord:"           , ;
         "Rendezve:"                , ;
         "Igen"                     , ;
         "Nem"                      , ;
         "Oldal "                   , ;
         " / "                       }

      _HMG_aABMLangButton := { "Zбrd be" , ;
         "Ъj"            , ;
         "Szerkesztйs"   , ;
         "Tцrцld"        , ;
         "Keresd"        , ;
         "Menj a"        , ;
         "Jelentйs"      , ;
         "Elsх"          , ;
         "Elхzх"         , ;
         "Kцvetkezх"     , ;
         "Utolsу"        , ;
         "Mentsd"        , ;
         "Mйgse"         , ;
         "Add"           , ;
         "Eltбvolнt"     , ;
         "Nyomtatбs"     , ;
         "Zбrd be"     }
      _HMG_aABMLangError  := { "SZERKESZTЙS, hibбs a munkaterьlet neve"                              , ;
         "SZERKESZTЙS, a munkaterьletnek tцbb mint 16 mezхt tartalmaz"              , ;
         "SZERKESZTЙS, a frissнtйsi mуd йrtйken kнvьl (kйrem, jelentse a hibбt)"      , ;
         "SZERKESZTЙS, a fх esemйny szбma йrtйken kнvьl (kйrem, jelentse a hibбt)" , ;
         "SZERKESZTЙS, a lista esemйny szбma йrtйken kнvьl(kйrem, jelentse a hibбt)"  }

      // EDIT EXTENDED

      _HMG_aLangButton := { ;
         "&Zбrd be",               ; // 1
      "Ъ&j",                    ; // 2
      "Mу&dosнtбs",             ; // 3
      "&Tцrцld",                ; // 4
      "&Keresd",                ; // 5
      "&Nyomtatбs",             ; // 6
      "&Mйgse",                 ; // 7
      "&Ok",                    ; // 8
      "Mбso&l",                 ; // 9
      "Szыrх &bekapcsolбsa",    ; // 10
      "Szыrх ki&kapcsolбsa",    ; // 11
      "&Visszahнv"       }        // 12
      _HMG_aLangLabel := {                            ;
         "nincs",                                 ; // 1
      "rekord",                                ; // 2
      "Цsszeg",                                ; // 3
      "Aktнv rendezйs",                        ; // 4
      "Opciуk",                                ; // 5
      "Ъj rekord",                             ; // 6
      "Rekord mуdosнtбsa",                     ; // 7
      "Rekord kivбlasztбsa",                   ; // 8
      "Rekord keresйse",                       ; // 9
      "Nyomtatбsi opciуk",                     ; // 10
      "Hasznбlhatу mezхk",                     ; // 11
      "Nyomtathatу mezхk",                     ; // 12
      "Elйrhetх nyomtatуk",                    ; // 13
      "Nyomtatбs elsх rekordja",               ; // 14
      "Nyomtatбs utolsу rekordja",             ; // 15
      "Rekord tцrlйse",                        ; // 16
      "Elцnйzet",                              ; // 17
      "Oldalak miniatъrakйnt",                 ; // 18
      "Szыrх feltйtele: ",                     ; // 19
      "Szыrve: ",                              ; // 20
      "Szыrх opciуi",                          ; // 21
      "Adatbбzis mezхi",                       ; // 22
      "Цsszehasonlнtу operбtor",               ; // 23
      "Szыrх йrtйke",                          ; // 24
      "Mezхk kivбlasztбsa a szыrхhцz",         ; // 25
      "Цsszehasonlнtу operбctor kivбlasztбsa",  ; // 26
      "egyenlх",                               ; // 27
      "nem egyenlх",                           ; // 28
      "nagyobb mint",                          ; // 29
      "kisebb mint",                           ; // 30
      "nagyobb vagy egyenlх mint",             ; // 31
      "kisebb vagy egyenlх mint"          }      // 32
      _HMG_aLangUser := { ;
         CRLF + "Nincs aktнv munkaterьlet   "  + CRLF + "Kйrem vбlasszon egy munkaterьletet a SZERKESZTЙS hнvбsa elхtt   " + CRLF,     ; // 1
      "Adja meg a mezх йrtйkйt (szцveget)",                                                                 ; // 2
      "Adja meg a mezх йrtйkйt (szбmot)",                                                                   ; // 3
      "Vбlasszon dбtumot",                                                                                  ; // 4
      "Pipбzza az igaz йrtйket",                                                                            ; // 5
      "Adja meg a mezх йrtйkйt",                                                                            ; // 6
      "Vбlasszon egy rekordot йs nyomjon OK",                                                               ; // 7
      CRLF + "Aktнv rekordot kнvбnja tцrцlni   " + CRLF + "Biztos benne?    " + CRLF,                       ; // 8
      CRLF + "Nincs aktнv sorba rendezйs   " + CRLF + "Kйrem vбlasszon egyet   " + CRLF,                    ; // 9
      CRLF + "Nem kereshetek memo vagy logikai mezх utбn   " + CRLF,                                        ; // 10
      CRLF + "Nincs rekord   " + CRLF,                                                                      ; // 11
      "Vбlasszon a listбhoz hozzбadandу mezхt",                                                             ; // 12
      "Vбlasszon a listбbуl kiveendх mezхt",                                                                ; // 13
      "Vбlasszon nyomtatуt",                                                                                ; // 14
      "Mezх hozzбadбs gombot nyomja meg",                                                                   ; // 15
      "Mezх tхrlйse gombot nyomja meg",                                                                     ; // 16
      "A nyomtatбs elsх rekordja gombot nyomja meg",                                                        ; // 17
      "A nyomtatбs utolsу rekordja gombot nyomja meg",                                                      ; // 18
      CRLF + "Nincs tцbb hozzбadhatу mezх   " + CRLF,                                                       ; // 19
      CRLF + "Elхszцr hozzбadandу mezхt vбlasszon   " + CRLF,                                               ; // 20
      CRLF + "Nincs tцbb kivehetх mezх   " + CRLF,                                                          ; // 21
      CRLF + "Elхszцr az n. kiveendх mezхt vбlassza ki   " + CRLF,                                          ; // 22
      CRLF + "Egy mezхt sem vбlasztott ki   " + CRLF + "Kйrem vбlassza ki a nyomtatandу mezхket   " + CRLF, ; // 23
      CRLF + "Tъl sok mezх   " + CRLF + "Redukбlja a mezхk szбmбt   " + CRLF,                               ; // 24
      CRLF + "A nyomtatу nem kйsz   " + CRLF,                                                               ; // 25
      "Rendezve",                                                                                           ; // 26
      "Rekordtуl",                                                                                          ; // 27
      "Rekordig",                                                                                           ; // 28
      "Igen",                                                                                               ; // 29
      "Nem",                                                                                                ; // 30
      "Oldal:",                                                                                             ; // 31
      CRLF + "Kйrem vбlasszon nyomtatуt   " + CRLF,                                                         ; // 32
      "Szыrve",                                                                                             ; // 33
      CRLF + "Ez az aktнv szьrх   " + CRLF,                                                                 ; // 34
      CRLF + "Nem szьrхhetх memo mezх alapjбn   " + CRLF,                                                   ; // 35
      CRLF + "Vбlasszon mezхt a szьrхhцz   " + CRLF,                                                        ; // 36
      CRLF + "Vбlasszon operбtort a szьrхhцz   " + CRLF,                                                    ; // 37
      CRLF + "Adjon йrtйket  a szьrхhцz   " + CRLF,                                                         ; // 38
      CRLF + "Nincs egy aktнv szьrх   " + CRLF,                                                             ; // 39
      CRLF + "A szьrх deaktivбlбsa?   " + CRLF,                                                             ; // 40
      CRLF + "A rekord blokkolva mбsik felhasznбlу бltal   " + CRLF,                                        ; // 41
      CRLF + "Tцrцlt rekordokat kнvбn visszahнvni   " + CRLF + "Biztos benne ?    " + CRLF                  } // 42

   CASE cLang == "EL"  // Greek - Ellinika
      /////////////////////////////////////////////////////////////
      // GREEK - ЕЛЛЗНЙКБ - EL
      /////////////////////////////////////////////////////////////

      // MISC MESSAGES (GREEK EL)

      _HMG_MESSAGE [1] := 'ЕЯуфе вЭвбйпй?'
      _HMG_MESSAGE [2] := 'КлеЯуймп рбсбиэспх'
      _HMG_MESSAGE [3] := 'Ден ерйфсЭрефбй фп клеЯуймп'
      _HMG_MESSAGE [4] := 'Фп рсьгсбммб екфелеЯфбй Юдз'
      _HMG_MESSAGE [5] := 'Ерео.'
      _HMG_MESSAGE [6] := 'Ok'
      _HMG_MESSAGE [7] := 'Бкхсп'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Уел.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE MESSAGES (GREEK EL)

      _HMG_BRWLangButton := { "&НЭп"  , ;
         "&Дйьсищуз"    , ;
         "&Бкхсп"  , ;
         "&OK"       }
      _HMG_BRWLangError  := { "Фп window: "                                           , ;
         " ден Эчей псйуиеЯ. Фп рсьгсбммб фесмбфЯуизке"          , ;
         "MiniGUI Error"                                         , ;
         "Control: "                                             , ;
         " Of "                                                  , ;
         " Эчей Юдз псйуиеЯ. Фп рсьгсбммб фесмбфЯуизке"          , ;
         "Browse: Мз Эгкхспт фэрпт. Фп рсьгсбммб фесмбфЯуизке"          , ;
         "Browse: Append Clause Can't Be Used With Fields Not Belonging To Browse WorkArea.", ;
         "З еггсбцЮ чсзуймпрпйеЯфбй брь бллп чсЮуфз"                , ;
         "РспупчЮ"                                               , ;
         "Мз брпдекфЮ фймЮ"                                          }
      _HMG_BRWLangMessage := { 'ЕЯуфе вЭвбйпй ?' , 'ДйбгсбцЮ еггсбцЮт' }

      // EDIT MESSAGES (GREEK - ЕЛЛЗНЙКБ)

      _HMG_aABMLangUser   := { Chr( 13 ) + "ДйбгсбцЮ еггсбцЮт" + Chr( 13 ) + "ЕЯуфе вЭвбйпй?" + Chr( 13 )    , ;
         Chr( 13 ) + "Фп ехсефЮсйп ден хрЬсчей" + Chr( 13 ) + "БнбжЮфзуз бдэнбфз!" + Chr( 13 )  , ;
         Chr( 13 ) + "Can`t find index field" + Chr( 13 ) + "БнбжЮфзуз бдэнбфз!" + Chr( 13 )        , ;
         Chr( 13 ) + "БнбжЮфзуз бдэнбфз уе" + Chr( 13 ) + "редЯб memo Ю лпгйкЬ" + Chr( 13 )       , ;
         Chr( 13 ) + "З еггсбцЮ ден всЭизке" + Chr( 13 )                                        , ;
         Chr( 13 ) + "РпллЭт уфЮлет" + Chr( 13 ) + "З бнбцпсЬ ден чщсЬ уфз уелЯдб" + Chr( 13 ) }

      _HMG_aABMLangLabel  := { "ЕггсбцЮ"    , ;
         "Бсйи.Еггсбцюн"        , ;
         "       (НЭп)"         , ;
         "     (Дйьс.)"         , ;
         "Дюуфе бсйи.еггсбцЮт"  , ;
         "Еэсеуз"               , ;
         "Еэсеуз кеймЭнпх"      , ;
         "Еэсеуз змес/нЯбт"     , ;
         "Еэсеуз бсйимпэ"       , ;
         "Псйумьт бнбцпсЬт"     , ;
         "УфЮлет Report"        , ;
         "ДйбиЭуймет уфЮлет"    , ;
         "БсчйкЮ еггсбцЮ"       , ;
         "ФелйкЮ еггсбцЮ"       , ;
         "БнбцпсЬ of "          , ;
         "Змес:"                , ;
         "БсчйкЮ еггсбцЮ:"      , ;
         "ФелйкЮ еггсбцЮ:"      , ;
         "Фбойньмзуз by:"       , ;
         "Нбй"                  , ;
         "Пчй"                  , ;
         "Уел. "                , ;
         " of "                 }

      _HMG_aABMLangButton := { "КлеЯуе"    , ;
         "NЭп"                 , ;
         "Дйьсищуз"            , ;
         "ДйбгсбцЮ"            , ;
         "Ехсеуз"              , ;
         "Рзгбйне"             , ;
         "БнбцпсЬ"             , ;
         "Рсюфп"               , ;
         "Рспзг/нп"            , ;
         "Ерьменп"             , ;
         "ФелехфбЯп"           , ;
         "БрпиЮкехуз"          , ;
         "Бкхсп"               , ;
         "РспуиЮкз"            , ;
         "ДйбгсбцЮ"            , ;
         "Екфхрщуз"            , ;
         "КлеЯуймп"     }
	
      _HMG_aABMLangError  := { "ЕРЕОЕСГБУЙБ, фп ьнпмб ресйпчзт есгбуйбт ден хрбсчей"                 , ;
         "ЕРЕОЕСГБУЙБ, з ресйпчЮ есгбуЯбт Эчей ресйууьфесб брп 16 редЯб"                 , ;
         "ЕРЕОЕСГБУЙБ, схимьт бнбнЭщузт екфьт псЯщн (рбсбкблю гнщуфпрпйЮубфе фп bug)"    , ;
         "ЕРЕОЕСГБУЙБ, main event number екфьт псЯщн (рбсбкблю гнщуфпрпйЮубфе фп bug)"   , ;
         "ЕРЕОЕСГБУЙБ, list event number екфьт псЯщн (рбсбкблю гнщуфпрпйЮубфе фп bug)"  }

      // EDIT EXTENDED (GREEK - ЕЛЛЗНЙКБ)

      _HMG_aLangButton := {   ;
         "&КлеЯуймп",       ; // 1
      "&НЭп",            ; // 2
      "&Дйьсищуз",       ; // 3
      "&ДйбгсбцЮ",       ; // 4
      "&Еэсеуз",         ; // 5
      "&Екфэрщуз",       ; // 6
      "&Бкхсп",          ; // 7
      "&Ok",             ; // 8
      "&БнфйгсбцЮ",      ; // 9
      "&ЦЯлфсп",         ; // 10
      "&ЧщсЯт цЯлфсп",   ; // 11
      "&Restore"         } // 12
      _HMG_aLangLabel := {                   ;
         "КбнЭнб",                       ; // 1
      "ЕггсбцЮ",                      ; // 2
      "Уэнплп",                       ; // 3
      "ЕнесгЮ Фбойньмзуз",            ; // 4
      "ЕрйлпгЭт",                     ; // 5
      "НЭб еггсбцЮ",                  ; // 6
      "Дйьси. еггсбцЮт",              ; // 7
      "ЕрйлпгЮ еггсбцЮт",             ; // 8
      "Еэсеуз",                       ; // 9
      "РспфймЮуейт екфэрщузт",        ; // 10
      "ДйбиЭуймб редЯб",              ; // 11
      "РедЯб гйЬ екфэрщуз",           ; // 12
      "ДйбиЭуймпй екфхрщфЭт",         ; // 13
      "Рсюфз еггсбцЮ екфхр.",         ; // 14
      "ФелехфбЯб еггсбцЮ екфхр.",     ; // 15
      "ДйбгсбцЮ еггсбцЮт",            ; // 16
      "Рсперйукьрзуз",                ; // 17
      "МйкспгсбцЯет уелЯдщн",         ; // 18
      "Пспй ЦЯлфспх: ",               ; // 19
      "ЦйлфсбсйумЭнб: ",              ; // 20
      "ЕрйлпгЭт цЯлфспх" ,            ; // 21
      "РедЯб вЬузт дедпмЭнщн" ,       ; // 22
      "ФелеуфЮт уэгксйузт",           ; // 23
      "ФймЮ цЯлфспх",                 ; // 24
      "ЕрйлпгЮ редЯпх гйб цЯлфсп",    ; // 25
      "ЕрйлпгЮ ФелеуфЮ уэгксйузт",    ; // 26
      "Йупн",                         ; // 27
      "Пчй Йупн",                     ; // 28
      "МегблЯфесп брь",               ; // 29
      "Мйксьфесп брь",                ; // 30
      "МегблЯфесп Ю йупн ме",         ; // 31
      "Мйксьфесп Ю йупн ме"           } // 32
      _HMG_aLangUser := { ;
         CRLF + "Ден хрЬсчей енесгЮ ресйпчЮ есгбуЯбт. "  + CRLF + ;
         "ЕрйлЭофе мйЬ ресйпчЮ рсЯн брь фзн клЮуз фзт EDIT   " + CRLF,                                          ; // 1
      "Дюуфе мЯб фймЮ редЯпх (кеЯменп)",                                                                         ; // 2
      "Дюуфе мЯб фймЮ редЯпх (бсйимьт)",                                                                         ; // 3
      "ЕрйлЭофе змес/нЯб",                                                                                       ; // 4
      "ФуекЬсефе бн блзиеэей",                                                                                   ; // 5
      "Дюуфе фймЮ фпх редЯпх",                                                                                   ; // 6
      "ЕрйлЭофе мЯб еггсбцЮ & рйЭуфе OK",                                                                        ; // 7
      CRLF + "З фсЭчпхуб еггсбцЮ иб дйбгсбцеЯ   " + CRLF + "ЕЯуфе вЭвбйпй?    " + CRLF,              ; // 8
      CRLF + "КбнЭнб енесгь ехсефЮсйп  " + CRLF + "Рбсбкблю ерйлЭобфе Энб   " + CRLF,                ; // 9
      CRLF + "Ден гЯнефбй бнбжЮфзуз уе memo Ю logic редЯп " + CRLF,                                      ; // 10
      CRLF + "З еггсбцЮ ден всЭизке  " + CRLF,                                                           ; // 11
      "УхмресЯлзшз фпх редЯпх уфз лЯуфб",                                                                        ; // 12
      "ЕобЯсеуз фпх редЯпх брь фзн лЯуфб",                                                                       ; // 13
      "ЕрйлЭофе екфхрщфЮ",                                                                                       ; // 14
      "РйЭуфе фп кпхмрЯ гйЬ ухмресЯлзшз фпх редЯпх",                                                             ; // 15
      "РйЭуфе фп кпхмрЯ гйЬ еобЯсеуз фпх редЯпх",                                                                ; // 16
      "РйЭуфе фп кпхмрЯ гйЬ ерйлпгЮ  еггсбцзт гйб екфхрщуз",                                                     ; // 17
      "Push button to select the last record to print",                                                          ; // 18
      CRLF + "Ден хрЬсчпхн Ьллб редЯб " + CRLF,                                                          ; // 19
      CRLF + "Рсюфб ерйлЭофе редЯп " + CRLF,                                                             ; // 20
      CRLF + "Ден хрЬсчпхн Ьллб редЯб " + CRLF,                                                          ; // 21
      CRLF + "Рсюфб ерйлЭофе редЯп " + CRLF,                                                             ; // 22
      CRLF + "Ден Эчпхн ерйлегеЯ редЯб " + CRLF + "Рбсбкблю ерйлЭофе редЯб рспт екфэрщуз   " + CRLF, ; // 23
      CRLF + "РЬсб рпллЬ редЯб " + CRLF + "Мейюуфе фпн бсйимь редЯщн " + CRLF,                       ; // 24
      CRLF + "П екфхрщфЮт ден еЯнбй Эфпймпт " + CRLF,                                                    ; // 25
      "Фбойньмзуз бнЬ ",                                                                                         ; // 26
      "Брь еггсбцЮ",                                                                                             ; // 27
      "Ещт еггсбцЮ",                                                                                             ; // 28
      "Нбй",                                                                                                     ; // 29
      "Пчй",                                                                                                     ; // 30
      "Уел.:",                                                                                                   ; // 31
      CRLF + "Рбсбкблю ерйлЭофе екфхрщфЮ " + CRLF,                                                       ; // 32
      "Filtered by",                                                                                             ; // 33
      CRLF + "ХрЬсчей енесгь цЯлфсп " + CRLF,                                                            ; // 34
      CRLF + "БнЭцйкфп фп цйлфсЬсйумб уе редЯп memo " + CRLF,                                            ; // 35
      CRLF + "ЕрйлЭофе редЯб гйЬ фп цЯлфсп " + CRLF,                                                     ; // 36
      CRLF + "ЕрйлЭофе Энбн фелеуфЮ гйЬ фп цЯлфсп " + CRLF,                                              ; // 37
      CRLF + "Дюуфе мЯб фймЮ гйб фп цЯлфсп " + CRLF,                                                     ; // 38
      CRLF + "Ден хрЬсчей енесгь цЯлфсп " + CRLF,                                                        ; // 39
      CRLF + "КбфЬсгзуз цЯлфспх;   " + CRLF,                                                             ; // 40
      CRLF + "ЕггсбцЮ клейдщмЭнз брь Ьллп чсЮуфз    " + CRLF,                                            ; // 41
      CRLF + "You are going to restore the deleted record   " + CRLF + "Are you sure?    " + CRLF    } // 42

   CASE cLang == "BG"  // Bulgarian
      /////////////////////////////////////////////////////////////
      // BULGARIAN
      ////////////////////////////////////////////////////////////

      // MISC MESSAGES

      _HMG_MESSAGE [1] := 'Сигурни ли сте ?'
      _HMG_MESSAGE [2] := 'Затваряне на прозореца'
      _HMG_MESSAGE [3] := 'Затварянето не се допуска'
      _HMG_MESSAGE [4] := 'Програмата вече е стартирана'
      _HMG_MESSAGE [5] := 'Измененение'
      _HMG_MESSAGE [6] := 'Да'
      _HMG_MESSAGE [7] := 'Отмяна'
      _HMG_MESSAGE [8] := 'Apply'
      _HMG_MESSAGE [9] := 'Стр.'
      _HMG_MESSAGE [10] := 'Attention'
      _HMG_MESSAGE [11] := 'Information'
      _HMG_MESSAGE [12] := 'Stop'

      // BROWSE

      _HMG_BRWLangButton := { "Добавяне" , ;
         "Промяна"    , ;
         "Отмяна"      , ;
         "OK"           }
      _HMG_BRWLangError  := { "Прозореца: "                                             , ;
         " не е дефиниран. Програмата прекъсва"                    , ;
         "MiniGUI Грешка"                                        , ;
         "Элемента за управление: "                                  , ;
         " от "                                                  , ;
         " вече е дефиниран. Програмата прекъсва"                         , ;
         "Browse: Такъв тип не се поддържа. Програмата прекъсва"    , ;
         "Browse: Append класа не може да се използва с полета от друа работна област. Програмата прекъсва", ;
         "Записа сега се редактира от друг потребител"           , ;
         "Предупреждение"                                             , ;
         "Въведени са неправилни дани"                                 }
      _HMG_BRWLangMessage := { 'Сигурни ли сте ?' , 'Изтриване на запис' }

      // EDIT

      _HMG_aABMLangUser   := { Chr( 13 ) + "Изтриване на запис." + Chr( 13 ) + "Сигурни ли сте ?" + Chr( 13 )                  , ;
         Chr( 13 ) + "Няма индексен файл" + Chr( 13 ) + "Търсенето е невъзможно" + Chr( 13 )   , ;
         Chr( 13 ) + "Няма индексно поле" + Chr( 13 ) + "Търсенето е невъзможно" + Chr( 13 )   , ;
         Chr( 13 ) + "Търсенето е невъзможно в" + Chr( 13 ) + "МЕМО полетата или логическите полета" + Chr( 13 ) , ;
         Chr( 13 ) + "Записа не е намерен" + Chr( 13 )                                       , ;
         Chr( 13 ) + "Прекалено много колони" + Chr( 13 ) + "Отчета не се събира на листа" + Chr( 13 ) }
      _HMG_aABMLangLabel  := { "Запис"              , ;
         "Всичко записи"       , ;
         "       (Нов)"        , ;
         "   (Промяна)"        , ;
         "Въведете N: на запис", ;
         "Търсене"               , ;
         "Намери текст"        , ;
         "Намери дата"         , ;
         "Намери число"        , ;
         "Настройка на отчета" , ;
         "Колони на отчета"    , ;
         "Достъпни колони"     , ;
         "Първи запис"         , ;
         "Последен запис"      , ;
         "Отчет за  "          , ;
         "Дата:"               , ;
         "Първи запис:"        , ;
         "Последен запис:"     , ;
         "Групиране по:"       , ;
         "Да"                  , ;
         "Не"                  , ;
         "Страница "           , ;
         " от "                 }
      _HMG_aABMLangButton := { "Затвори"   , ;
         "Нов"       , ;
         "Промяна"   , ;
         "Изтрий"   , ;
         "Търси"     , ;
         "Иди на"   , ;
         "Отчет"     , ;
         "Първи"    , ;
         "Назад"     , ;
         "Напред"    , ;
         "Последен" , ;
         "Запиши" , ;
         "Отмяна"    , ;
         "Добави"  , ;
         "Изтрий"   , ;
         "Печат"    , ;
         "Затвори"    }
      _HMG_aABMLangError  := { "EDIT, не указано името на работната област"                     , ;
         "EDIT, допускат се не повече от 16 полета"                      , ;
         "EDIT, режима на обновяване е извън диапазона (съобщете за грешката)", ;
         "EDIT, номера на собитието е извън диапазона (съобщете за грешката)"   , ;
         "EDIT, номер на собитието за листинга е извън диапазона (съобщете за грешката)" }

      // EDIT EXTENDED

      _HMG_aLangButton := {            ;
         "&Изход",             ; // 1
      "&Нов",               ; // 2
      "&Редактиране",       ; // 3
      "&Изтрий",            ; // 4
      "&Намери",            ; // 5
      "П&ечат",             ; // 6
      "От&мяна",            ; // 7
      "&Ок",                ; // 8
      "&Копие",             ; // 9
      "&Вкл. филтър",       ; // 10
      "Ма&хни филтър",      ; // 11
      "&Възстанови"     }     // 12
      _HMG_aLangLabel := {            ;
         "Няма",                         ; // 1
      "Запис",                        ; // 2
      "Всичко",                       ; // 3
      "Подредба",                     ; // 4
      "Параметри",                    ; // 5
      "Нов запис",                    ; // 6
      "Промени запис",                ; // 7
      "Избери запис",                 ; // 8
      "Намери запис",                 ; // 9
      "Параметри за печат",           ; // 10
      "Достъпни полета",              ; // 11
      "Полета за печат",              ; // 12
      "Доступни принтери",            ; // 13
      "Започни печат от запис",       ; // 14
      "Завърши печата със запис",     ; // 15
      "Изтрий запис",                 ; // 16
      "Преглед",                      ; // 17
      "Страница с миниатюри",         ; // 18
      "Условие на филтъра: ",         ; // 19
      "Филтър: ",                     ; // 20
      "Параметри на филтъра" ,        ; // 21
      "Полета на базата" ,            ; // 22
      "Оператори за сравнение",       ; // 23
      "Значение на филтъра",          ; // 24
      "Избор на поле за филтъра",     ; // 25
      "Избор на оператор за сравнение", ; // 26
      "Равно",                        ; // 27
      "Не е равно",                   ; // 28
      "По-голямо",                    ; // 29
      "По-малко",                     ; // 30
      "По-голямо или равно",          ; // 31
      "По-малко или равно"         }    // 32
      _HMG_aLangUser := { ;
         CRLF + "Не е намерена активна област."  + CRLF + "Изберете област переди извикването на EDIT" + CRLF, ; // 1
      "Въведете текст",                                                                                     ; // 2
      "Въведете число",                                                                                     ; // 3
      "Въведете дата",                                                                                      ; // 4
      "Логическа стойност",                                                                                 ; // 5
      "Въведете сойността на полето",                                                                       ; // 6
      "Изберете запис и натиснете OK",                                                                      ; // 7
      CRLF + "Текущият запис ще бъде изтрит " + CRLF + "Да продължа ли ?    " + CRLF,                       ; // 8
      CRLF + "Няма подредба " + CRLF + "Изберете една от съществуващите" + CRLF,                            ; // 9
      CRLF + "Търсене в MEMO полетата и логическите полета не се изпълнява" + CRLF,                         ; // 10
      CRLF + "Записа не е намерен  " + CRLF,                                                                ; // 11
      "Полета за включване в списъка за печат",                                                             ; // 12
      "Списък с полета за печат",                                                                           ; // 13
      "Избор на принтер",                                                                                   ; // 14
      "Натиснете за перенос на полето в списъка за печат",                                                  ; // 15
      "Натиснете за исключване на полето от списъка за печат",                                              ; // 16
      "Запис, от който започва печата",                                                                     ; // 17
      "Запис, до който завършва печата",                                                                    ; // 18
      CRLF + "Включени полета няма " + CRLF,                                                                ; // 19
      CRLF + "Първо поле за включване " + CRLF,                                                             ; // 20
      CRLF + "Полета за изключване няма " + CRLF,                                                           ; // 21
      CRLF + "Първо поле за исключване " + CRLF,                                                            ; // 22
      CRLF + "Няма избрани полета " + CRLF + "Формирайте списък за печат " + CRLF,                          ; // 23
      CRLF + "Прекалено много полета " + CRLF + "Намалете тяхното количество " + CRLF,                      ; // 24
      CRLF + "Принтера не е готов  " + CRLF,                                                                ; // 25
      "Подредба ",                                                                                          ; // 26
      "От запис ",                                                                                          ; // 27
      "До запис ",                                                                                          ; // 28
      "Да",                                                                                                 ; // 29
      "Не",                                                                                                 ; // 30
      "Страница:",                                                                                          ; // 31
      CRLF + "Изберете принтер  " + CRLF,                                                                   ; // 32
      "Филтрирано по",                                                                                      ; // 33
      CRLF + "Това не е активнен филтър    " + CRLF,                                                        ; // 34
      CRLF + "MEMO Полетата не се филтрират  " + CRLF,                                                      ; // 35
      CRLF + "Изберете полета за филтъра    " + CRLF,                                                       ; // 36
      CRLF + "Изберете оператор за филтъра" + CRLF,                                                         ; // 37
      CRLF + "Наберете стойност за филтъра" + CRLF,                                                         ; // 38
      CRLF + "Няма активни филтри   " + CRLF,                                                               ; // 39
      CRLF + "Махни филтъра ?   " + CRLF,                                                                   ; // 40
      CRLF + "Записа е блокиран от друг потребител " + CRLF,                                                ; // 41
      CRLF + "Текущия запис ще бъде възстановен " + CRLF + "Да продължа ли ?    " + CRLF                    } // 42

   ENDCASE

#endif

RETURN
