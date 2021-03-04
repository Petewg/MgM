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

/*
 * Public Variables Used By MiniGUI Modules
*/

#ifndef __SYSDATA__
  #define __SYSDATA__
  MEMVAR _HMG_SYSDATA
#endif

#define _HMG_SYSDATA_SIZE			455

#xtranslate _HMG_ErrorLogFile			=> _HMG_SYSDATA\[1]
#xtranslate _HMG_CreateErrorlog			=> _HMG_SYSDATA\[2]

#xtranslate _HMG_ActiveIniFile			=> _HMG_SYSDATA\[3]
#xtranslate _HMG_ActiveTreeValue		=> _HMG_SYSDATA\[4]
#xtranslate _HMG_ActiveTreeIndex		=> _HMG_SYSDATA\[5]
#xtranslate _HMG_ActiveTreeHandle		=> _HMG_SYSDATA\[6]
#xtranslate _HMG_NodeHandle			=> _HMG_SYSDATA\[7]
#xtranslate _HMG_NodeIndex			=> _HMG_SYSDATA\[8]
#xtranslate _HMG_aTreeMap			=> _HMG_SYSDATA\[9]
#xtranslate _HMG_aTreeIdMap			=> _HMG_SYSDATA\[10]
#xtranslate _HMG_ActiveTreeItemIds		=> _HMG_SYSDATA\[11]
#xtranslate _HMG_ActiveDragImageHandle		=> _HMG_SYSDATA\[12]

//JP MDI

#xtranslate  _HMG_MainClientMDIHandle		=> _HMG_SYSDATA\[13]
#xtranslate  _HMG_MainClientMDIName  		=> _HMG_SYSDATA\[14]
#xtranslate  _HMG_ActiveMDIChildIndex		=> _HMG_SYSDATA\[15]
#xtranslate  _HMG_BeginWindowMDIActive		=> _HMG_SYSDATA\[16]
#xtranslate  _HMG_MdiChildActive      		=> _HMG_SYSDATA\[17]
#xtranslate  _HMG_ActiveStatusHandle 		=> _HMG_SYSDATA\[18]

#xtranslate _HMG_ActiveToolBarCaption		=> _HMG_SYSDATA\[19]
#xtranslate _HMG_SplitChildActive		=> _HMG_SYSDATA\[20]
#xtranslate _HMG_ActiveFormNameBak		=> _HMG_SYSDATA\[21]
#xtranslate _HMG_SplitLastControl		=> _HMG_SYSDATA\[22]
#xtranslate _HMG_ActiveToolBarBreak		=> _HMG_SYSDATA\[23]
#xtranslate _HMG_ActiveSplitBox			=> _HMG_SYSDATA\[24]
#xtranslate _HMG_ActiveSplitBoxParentFormName	=> _HMG_SYSDATA\[25]
#xtranslate _HMG_NotifyBalloonClick		=> _HMG_SYSDATA\[26]
#xtranslate _HMG_ActiveToolBarName		=> _HMG_SYSDATA\[27]
#xtranslate _HMG_Id				=> _HMG_SYSDATA\[28]
#xtranslate _HMG_MainActive			=> _HMG_SYSDATA\[29]
#xtranslate _HMG_MainHandle			=> _HMG_SYSDATA\[30]
#xtranslate _HMG_MouseRow			=> _HMG_SYSDATA\[31]
#xtranslate _HMG_MouseCol			=> _HMG_SYSDATA\[32]
#xtranslate _HMG_ActiveFormName			=> _HMG_SYSDATA\[33]
#xtranslate _HMG_BeginWindowActive		=> _HMG_SYSDATA\[34]
#xtranslate _HMG_ActiveFontName			=> _HMG_SYSDATA\[35]
#xtranslate _HMG_ActiveFontSize			=> _HMG_SYSDATA\[36]
#xtranslate _HMG_FrameLevel			=> _HMG_SYSDATA\[37]
#xtranslate _HMG_ActiveFrameParentFormName	=> _HMG_SYSDATA\[38]
#xtranslate _HMG_ActiveFrameRow			=> _HMG_SYSDATA\[39]
#xtranslate _HMG_ActiveFrameCol			=> _HMG_SYSDATA\[40]
#xtranslate _HMG_BeginTabActive			=> _HMG_SYSDATA\[41]
#xtranslate _HMG_ActiveTabPage			=> _HMG_SYSDATA\[42]
#xtranslate _HMG_ActiveTabFullPageMap		=> _HMG_SYSDATA\[43]
#xtranslate _HMG_ActiveTabCaptions		=> _HMG_SYSDATA\[44]
#xtranslate _HMG_ActiveTabCurrentPageMap	=> _HMG_SYSDATA\[45]
#xtranslate _HMG_ActiveTabName			=> _HMG_SYSDATA\[46]
#xtranslate _HMG_ActiveTabParentFormName	=> _HMG_SYSDATA\[47]
#xtranslate _HMG_ActiveTabRow			=> _HMG_SYSDATA\[48]
#xtranslate _HMG_ActiveTabCol			=> _HMG_SYSDATA\[49]
#xtranslate _HMG_ActiveTabWidth			=> _HMG_SYSDATA\[50]
#xtranslate _HMG_ActiveTabHeight		=> _HMG_SYSDATA\[51]
#xtranslate _HMG_ActiveTabValue			=> _HMG_SYSDATA\[52]
#xtranslate _HMG_ActiveTabFontName		=> _HMG_SYSDATA\[53]
#xtranslate _HMG_ActiveTabFontSize		=> _HMG_SYSDATA\[54]
#xtranslate _HMG_ActiveTabToolTip		=> _HMG_SYSDATA\[55]
#xtranslate _HMG_ActiveTabChangeProcedure	=> _HMG_SYSDATA\[56]
#xtranslate _HMG_ActiveTabButtons		=> _HMG_SYSDATA\[57]
#xtranslate _HMG_ActiveTabFlat			=> _HMG_SYSDATA\[58]
#xtranslate _HMG_ActiveTabHotTrack		=> _HMG_SYSDATA\[59]
#xtranslate _HMG_ActiveTabVertical		=> _HMG_SYSDATA\[60]
#xtranslate _HMG_ActiveTabNoTabStop		=> _HMG_SYSDATA\[61]
#xtranslate _HMG_ActiveTabMnemonic		=> _HMG_SYSDATA\[62]

#xtranslate _HMG_ActiveDialogName		=> _HMG_SYSDATA\[63]
#xtranslate _HMG_ActiveDialogHandle		=> _HMG_SYSDATA\[64]
#xtranslate _HMG_BeginDialogActive		=> _HMG_SYSDATA\[65]
#xtranslate _HMG_ModalDialogProcedure		=> _HMG_SYSDATA\[66]
#xtranslate _HMG_DialogProcedure		=> _HMG_SYSDATA\[67]
#xtranslate _HMG_ModalDialogReturn		=> _HMG_SYSDATA\[68]
#xtranslate _HMG_InitDialogProcedure		=> _HMG_SYSDATA\[69]
#xtranslate _HMG_ActiveTabnId			=> _HMG_SYSDATA\[70]
#xtranslate _HMG_aDialogTemplate		=> _HMG_SYSDATA\[71]
#xtranslate _HMG_aDialogItems			=> _HMG_SYSDATA\[72]
#xtranslate _HMG_DialogInMemory			=> _HMG_SYSDATA\[73]
#xtranslate _HMG_aDialogTreeItem		=> _HMG_SYSDATA\[74]

#xtranslate _HMG_ActiveDlgProcHandle		=> _HMG_SYSDATA\[75]
#xtranslate _HMG_ActiveDlgProcMsg		=> _HMG_SYSDATA\[76]
#xtranslate _HMG_ActiveDlgProcId		=> _HMG_SYSDATA\[77]
#xtranslate _HMG_ActiveDlgProcNotify		=> _HMG_SYSDATA\[78]
#xtranslate _HMG_ActiveDlgProcModal		=> _HMG_SYSDATA\[79]

#xtranslate _HMG_ActivePropGridHandle		=> _HMG_SYSDATA\[80]
#xtranslate _HMG_ActiveCategoryHandle		=> _HMG_SYSDATA\[81]
#xtranslate _HMG_ActivePropGridIndex		=> _HMG_SYSDATA\[82]
#xtranslate _HMG_ActivePropGridArray		=> _HMG_SYSDATA\[83]
#xtranslate _HMG_aFormMoveProcedure		=> _HMG_SYSDATA\[84]
#xtranslate _HMG_ActiveTabBottom		=> _HMG_SYSDATA\[85]
#xtranslate _HMG_aControlsContextMenu		=> _HMG_SYSDATA\[86]
#xtranslate _HMG_xControlsContextMenuID		=> _HMG_SYSDATA\[87]
#xtranslate _HMG_ActiveControlButtonWidth	=> _HMG_SYSDATA\[88]
#xtranslate _HMG_ActiveControlDef		=> _HMG_SYSDATA\[89]
#xtranslate _HMG_MouseState			=> _HMG_SYSDATA\[90]

#xtranslate _HMG_IsModalActive			=> _HMG_SYSDATA\[91]
#xtranslate _HMG_aFormDeleted			=> _HMG_SYSDATA\[92]
#xtranslate _HMG_aFormNames			=> _HMG_SYSDATA\[93]
#xtranslate _HMG_aFormHandles			=> _HMG_SYSDATA\[94]
#xtranslate _HMG_aFormActive			=> _HMG_SYSDATA\[95]
#xtranslate _HMG_aFormType			=> _HMG_SYSDATA\[96]
#xtranslate _HMG_aFormParentHandle		=> _HMG_SYSDATA\[97]
#xtranslate _HMG_aFormReleaseProcedure		=> _HMG_SYSDATA\[98]
#xtranslate _HMG_aFormInitProcedure		=> _HMG_SYSDATA\[99]
#xtranslate _HMG_aFormToolTipHandle		=> _HMG_SYSDATA\[100]
#xtranslate _HMG_aFormContextMenuHandle		=> _HMG_SYSDATA\[101]
#xtranslate _HMG_aFormMouseDragProcedure	=> _HMG_SYSDATA\[102]
#xtranslate _HMG_aFormSizeProcedure		=> _HMG_SYSDATA\[103]
#xtranslate _HMG_aFormClickProcedure		=> _HMG_SYSDATA\[104]
#xtranslate _HMG_aFormMouseMoveProcedure	=> _HMG_SYSDATA\[105]
#xtranslate _HMG_aFormBkColor			=> _HMG_SYSDATA\[106]
#xtranslate _HMG_aFormPaintProcedure		=> _HMG_SYSDATA\[107]
#xtranslate _HMG_aFormNoShow			=> _HMG_SYSDATA\[108]
#xtranslate _HMG_aFormNotifyIconName		=> _HMG_SYSDATA\[109]
#xtranslate _HMG_aFormNotifyIconToolTip		=> _HMG_SYSDATA\[110]
#xtranslate _HMG_aFormNotifyIconLeftClick	=> _HMG_SYSDATA\[111]
#xtranslate _HMG_aFormGotFocusProcedure		=> _HMG_SYSDATA\[112]
#xtranslate _HMG_aFormLostFocusProcedure	=> _HMG_SYSDATA\[113]
#xtranslate _HMG_aFormReBarHandle		=> _HMG_SYSDATA\[114]
#xtranslate _HMG_aFormNotifyMenuHandle		=> _HMG_SYSDATA\[115]
#xtranslate _HMG_aFormBrowseList		=> _HMG_SYSDATA\[116]
#xtranslate _HMG_aFormSplitChildList		=> _HMG_SYSDATA\[117]
#xtranslate _HMG_aFormVirtualHeight		=> _HMG_SYSDATA\[118]
#xtranslate _HMG_aFormVirtualWidth		=> _HMG_SYSDATA\[119]
#xtranslate _HMG_aFormFocused			=> _HMG_SYSDATA\[120]
#xtranslate _HMG_aFormScrollUp			=> _HMG_SYSDATA\[121]
#xtranslate _HMG_aFormScrollDown		=> _HMG_SYSDATA\[122]
#xtranslate _HMG_aFormScrollLeft		=> _HMG_SYSDATA\[123]
#xtranslate _HMG_aFormScrollRight		=> _HMG_SYSDATA\[124]
#xtranslate _HMG_aFormHScrollBox		=> _HMG_SYSDATA\[125]
#xtranslate _HMG_aFormVScrollBox		=> _HMG_SYSDATA\[126]
#xtranslate _HMG_aFormBrushHandle		=> _HMG_SYSDATA\[127]
#xtranslate _HMG_aFormFocusedControl		=> _HMG_SYSDATA\[128]
#xtranslate _HMG_aFormGraphTasks		=> _HMG_SYSDATA\[129]
#xtranslate _HMG_aFormMaximizeProcedure		=> _HMG_SYSDATA\[130]
#xtranslate _HMG_aFormMinimizeProcedure		=> _HMG_SYSDATA\[131]
#xtranslate _HMG_aFormRestoreProcedure		=> _HMG_SYSDATA\[132]
#xtranslate _HMG_aFormInteractiveCloseProcedure	=> _HMG_SYSDATA\[133]

#xtranslate _HMG_aControlDeleted		=> _HMG_SYSDATA\[134]
#xtranslate _HMG_aControlType			=> _HMG_SYSDATA\[135]
#xtranslate _HMG_aControlNames			=> _HMG_SYSDATA\[136]
#xtranslate _HMG_aControlHandles		=> _HMG_SYSDATA\[137]
#xtranslate _HMG_aControlParenthandles		=> _HMG_SYSDATA\[138]
#xtranslate _HMG_aControlIds			=> _HMG_SYSDATA\[139]
#xtranslate _HMG_aControlProcedures		=> _HMG_SYSDATA\[140]
#xtranslate _HMG_aControlPageMap		=> _HMG_SYSDATA\[141]
#xtranslate _HMG_aControlValue			=> _HMG_SYSDATA\[142]
#xtranslate _HMG_aControlInputMask		=> _HMG_SYSDATA\[143]
#xtranslate _HMG_aControllostFocusProcedure	=> _HMG_SYSDATA\[144]
#xtranslate _HMG_aControlGotFocusProcedure	=> _HMG_SYSDATA\[145]
#xtranslate _HMG_aControlChangeProcedure	=> _HMG_SYSDATA\[146]
#xtranslate _HMG_aControlBkColor		=> _HMG_SYSDATA\[147]
#xtranslate _HMG_aControlFontColor		=> _HMG_SYSDATA\[148]
#xtranslate _HMG_aControlDblClick		=> _HMG_SYSDATA\[149]
#xtranslate _HMG_aControlHeadClick		=> _HMG_SYSDATA\[150]
#xtranslate _HMG_aControlRow			=> _HMG_SYSDATA\[151]
#xtranslate _HMG_aControlCol			=> _HMG_SYSDATA\[152]
#xtranslate _HMG_aControlWidth			=> _HMG_SYSDATA\[153]
#xtranslate _HMG_aControlHeight			=> _HMG_SYSDATA\[154]
#xtranslate _HMG_aControlSpacing		=> _HMG_SYSDATA\[155]
#xtranslate _HMG_aControlContainerRow		=> _HMG_SYSDATA\[156]
#xtranslate _HMG_aControlContainerCol		=> _HMG_SYSDATA\[157]
#xtranslate _HMG_aControlPicture		=> _HMG_SYSDATA\[158]
#xtranslate _HMG_aControlContainerHandle	=> _HMG_SYSDATA\[159]
#xtranslate _HMG_aControlFontName		=> _HMG_SYSDATA\[160]
#xtranslate _HMG_aControlFontSize		=> _HMG_SYSDATA\[161]
#xtranslate _HMG_aControlToolTip		=> _HMG_SYSDATA\[162]
#xtranslate _HMG_aControlRangeMin		=> _HMG_SYSDATA\[163]
#xtranslate _HMG_aControlRangeMax		=> _HMG_SYSDATA\[164]
#xtranslate _HMG_aControlCaption		=> _HMG_SYSDATA\[165]
#xtranslate _HMG_aControlVisible		=> _HMG_SYSDATA\[166]
#xtranslate _HMG_aControlFontHandle		=> _HMG_SYSDATA\[167]
#xtranslate _HMG_aControlFontAttributes		=> _HMG_SYSDATA\[168]
#xtranslate _HMG_aControlBrushHandle		=> _HMG_SYSDATA\[169]
#xtranslate _HMG_aControlEnabled		=> _HMG_SYSDATA\[170]
#xtranslate _HMG_aControlMiscData1		=> _HMG_SYSDATA\[171]

#xtranslate _HMG_aCustomEventProcedure		=> _HMG_SYSDATA\[172]
#xtranslate _HMG_aCustomPropertyProcedure	=> _HMG_SYSDATA\[173]
#xtranslate _HMG_aCustomMethodProcedure		=> _HMG_SYSDATA\[174]
#xtranslate _HMG_UserComponentProcess		=> _HMG_SYSDATA\[175]
#xtranslate _HMG_aFormDropProcedure		=> _HMG_SYSDATA\[176]
#xtranslate _HMG_aFormMinMaxInfo		=> _HMG_SYSDATA\[177]
#xtranslate _HMG_InplaceParentHandle		=> _HMG_SYSDATA\[178]
#xtranslate _HMG_AutoScroll			=> _HMG_SYSDATA\[179]
#xtranslate _HMG_IsXPorLater			=> _HMG_SYSDATA\[180]

#xtranslate _HMG_StationName			=> _HMG_SYSDATA\[181]
#xtranslate _HMG_SendDataCount			=> _HMG_SYSDATA\[182]
#xtranslate _HMG_CommPath			=> _HMG_SYSDATA\[183]
#xtranslate _HMG_InteractiveClose		=> _HMG_SYSDATA\[184]

#xtranslate _HMG_xMenuType			=> _HMG_SYSDATA\[185]
#xtranslate _HMG_xMainMenuHandle		=> _HMG_SYSDATA\[186]
#xtranslate _HMG_xMainMenuParentHandle		=> _HMG_SYSDATA\[187]
#xtranslate _HMG_xMenuPopupLevel		=> _HMG_SYSDATA\[188]
#xtranslate _HMG_xMenuPopuphandle		=> _HMG_SYSDATA\[189]
#xtranslate _HMG_xMenuPopupCaption		=> _HMG_SYSDATA\[190]
#xtranslate _HMG_xMainMenuParentName		=> _HMG_SYSDATA\[191]

#xtranslate _HMG_xContextMenuHandle		=> _HMG_SYSDATA\[192]
#xtranslate _HMG_xContextMenuParentHandle	=> _HMG_SYSDATA\[193]
#xtranslate _HMG_xContextPopupLevel 		=> _HMG_SYSDATA\[194]
#xtranslate _HMG_xContextPopuphandle 		=> _HMG_SYSDATA\[195]
#xtranslate _HMG_xContextPopupCaption 		=> _HMG_SYSDATA\[196]
#xtranslate _HMG_xContextMenuParentName 	=> _HMG_SYSDATA\[197]
#xtranslate _HMG_xContextMenuButtonIndex	=> _HMG_SYSDATA\[198]

#xtranslate _HMG_ActiveSplitChildIndex		=> _HMG_SYSDATA\[199]

#xtranslate _HMG_ActiveControlImageList		=> _HMG_SYSDATA\[200]
#xtranslate _HMG_ActiveMessageBarName		=> _HMG_SYSDATA\[201]
#xtranslate _HMG_StatusItemCount		=> _HMG_SYSDATA\[202]
#xtranslate _HMG_ToolBarActive			=> _HMG_SYSDATA\[203]
#xtranslate _HMG_ActiveToolBarExtend		=> _HMG_SYSDATA\[204]

#xtranslate _HMG_nTopic				=> _HMG_SYSDATA\[205]
#xtranslate _HMG_nMet				=> _HMG_SYSDATA\[206]	
#xtranslate _HMG_ActiveHelpFile 		=> _HMG_SYSDATA\[207]
#xtranslate _HMG_ActiveTabMultiline		=> _HMG_SYSDATA\[208]
#xtranslate _HMG_aControlHelpId			=> _HMG_SYSDATA\[209]

#xtranslate _HMG_TempWindowName			=> _HMG_SYSDATA\[210]

#xtranslate _HMG_LoadWindowActive		=> _HMG_SYSDATA\[211]

#xtranslate _HMG_DefaultFontName		=> _HMG_SYSDATA\[212]
#xtranslate _HMG_DefaultFontSize		=> _HMG_SYSDATA\[213]

#xtranslate _HMG_lMultiple			=> _HMG_SYSDATA\[214]
#xtranslate _HMG_IsMultiple			=> _HMG_SYSDATA\[215]
#xtranslate _HMG_ShowContextMenus		=> _HMG_SYSDATA\[216]
#xtranslate _HMG_ThisIndex			=> _HMG_SYSDATA\[217]
#xtranslate _HMG_ThisType			=> _HMG_SYSDATA\[218]
#xtranslate _HMG_ThisFormIndex 			=> _HMG_SYSDATA\[219]

#xtranslate _HMG_ThisQueryRowIndex		=> _HMG_SYSDATA\[220]
#xtranslate _HMG_ThisQueryColIndex		=> _HMG_SYSDATA\[221]
#xtranslate _HMG_ThisQueryData			=> _HMG_SYSDATA\[222]

#xtranslate _HMG_ThisItemRowIndex		=> _HMG_SYSDATA\[223]
#xtranslate _HMG_ThisItemColIndex		=> _HMG_SYSDATA\[224]
#xtranslate _HMG_ThisItemCellRow		=> _HMG_SYSDATA\[225]
#xtranslate _HMG_ThisItemCellCol		=> _HMG_SYSDATA\[226]
#xtranslate _HMG_ThisItemCellWidth		=> _HMG_SYSDATA\[227]
#xtranslate _HMG_ThisItemCellHeight		=> _HMG_SYSDATA\[228]
#xtranslate _HMG_ThisItemCellValue		=> _HMG_SYSDATA\[229]

#xtranslate _HMG_BRWLangButton			=> _HMG_SYSDATA\[230]
#xtranslate _HMG_BRWLangError			=> _HMG_SYSDATA\[231]
#xtranslate _HMG_ActiveSplitBoxInverted		=> _HMG_SYSDATA\[232]

#xtranslate _HMG_GridSelectedRowForeColor	=> _HMG_SYSDATA\[233]
#xtranslate _HMG_GridSelectedRowBackColor	=> _HMG_SYSDATA\[234]
#xtranslate _HMG_GridSelectedCellForeColor	=> _HMG_SYSDATA\[235]
#xtranslate _HMG_GridSelectedCellBackColor	=> _HMG_SYSDATA\[236]

#xtranslate _HMG_DialogCancelled		=> _HMG_SYSDATA\[237]

#xtranslate _HMG_IPE_CANCELLED			=> _HMG_SYSDATA\[238]
#xtranslate _HMG_IPE_COL			=> _HMG_SYSDATA\[239]
#xtranslate _HMG_IPE_ROW			=> _HMG_SYSDATA\[240]

#xtranslate _HMG_ExtendedNavigation		=> _HMG_SYSDATA\[241]
#xtranslate _HMG_ThisEventType			=> _HMG_SYSDATA\[242]
#xtranslate _HMG_InteractiveCloseQuery		=> _HMG_SYSDATA\[243]
#xtranslate _HMG_InteractiveCloseQMain		=> _HMG_SYSDATA\[244]

#xtranslate _HMG_ActiveTabBold			=> _HMG_SYSDATA\[245]
#xtranslate _HMG_ActiveTabItalic		=> _HMG_SYSDATA\[246]
#xtranslate _HMG_ActiveTabUnderline		=> _HMG_SYSDATA\[247]
#xtranslate _HMG_ActiveTabStrikeout		=> _HMG_SYSDATA\[248]
#xtranslate _HMG_ActiveTabImages		=> _HMG_SYSDATA\[249]

#xtranslate _HMG_aBrowseSyncStatus		=> _HMG_SYSDATA\[250]
#xtranslate _HMG_BrowseSyncStatus		=> _HMG_aBrowseSyncStatus\[1]
#xtranslate _HMG_BrowseUpdateStatus		=> _HMG_aBrowseSyncStatus\[2]

#xtranslate _HMG_BrowseOnChangeAllowed		=> _HMG_SYSDATA\[251]

#xtranslate _HMG_aFormActivateId		=> _HMG_SYSDATA\[252]
#xtranslate _HMG_aFormAutoRelease		=> _HMG_SYSDATA\[253]

#xtranslate _HMG_ThisFormName 			=> _HMG_SYSDATA\[254]
#xtranslate _HMG_ThisControlName 		=> _HMG_SYSDATA\[255]

#xtranslate _HMG_DateTextBoxActive		=> _HMG_SYSDATA\[256]

#xtranslate _HMG_aEventInfo			=> _HMG_SYSDATA\[257]
#xtranslate _HMG_InteractiveCloseStarted	=> _HMG_SYSDATA\[258]

#xtranslate _HMG_SetFocusExecuted		=> _HMG_SYSDATA\[259]

#xtranslate _HMG_MainCargo			=> _HMG_SYSDATA\[260]

#xtranslate _HMG_BRWLangMessage			=> _HMG_SYSDATA\[261]

#xtranslate _HMG_MESSAGE			=> _HMG_SYSDATA\[262]

#xtranslate _HMG_aABMLangUser			=> _HMG_SYSDATA\[263]
#xtranslate _HMG_aABMLangLabel  		=> _HMG_SYSDATA\[264]
#xtranslate _HMG_aABMLangButton 		=> _HMG_SYSDATA\[265]
#xtranslate _HMG_aABMLangError  		=> _HMG_SYSDATA\[266]

#xtranslate _HMG_aLangButton       		=> _HMG_SYSDATA\[267]
#xtranslate _HMG_aLangLabel			=> _HMG_SYSDATA\[268]
#xtranslate _HMG_aLangUser			=> _HMG_SYSDATA\[269]

#xtranslate _HMG_LANG_ID			=> _HMG_SYSDATA\[270]

#xtranslate _HMG_IsXP				=> _HMG_SYSDATA\[271]

#xtranslate _HMG_ActiveToolBarFormName		=> _HMG_SYSDATA\[272]

#xtranslate _HMG_DefaultStatusBarMessage	=> _HMG_SYSDATA\[273]

#xtranslate _hmg_DelayedSetFocus		=> _HMG_SYSDATA\[274]

#xtranslate _hmg_activemodalhandle		=> _HMG_SYSDATA\[275]

#xtranslate _hmg_UserWindowHandle		=> _HMG_SYSDATA\[276]

/*--------------------------------------------------------------------------
Memvariables
--------------------------------------------------------------------------*/

#xtranslate _HMG_ActiveControlMessage			=> _HMG_SYSDATA\[277]
#xtranslate _HMG_ActiveControlDefault			=> _HMG_SYSDATA\[278]
#xtranslate _HMG_ActiveControlHorizontal		=> _HMG_SYSDATA\[279]
#xtranslate _HMG_ActiveControlLefttext			=> _HMG_SYSDATA\[280]
#xtranslate _HMG_ActiveControlUptext			=> _HMG_SYSDATA\[281]
#xtranslate _HMG_ActiveControlStringFormat		=> _HMG_SYSDATA\[282]
#xtranslate _HMG_ActiveControlNoHotLight		=> _HMG_SYSDATA\[283]
#xtranslate _HMG_ActiveControlNoXpStyle			=> _HMG_SYSDATA\[284]
#xtranslate _HMG_ActiveControlLeftJustify		=> _HMG_SYSDATA\[285]
#xtranslate _HMG_ActiveControlIcon			=> _HMG_SYSDATA\[286]
#xtranslate _HMG_ActiveControlHandCursor		=> _HMG_SYSDATA\[287]
#xtranslate _HMG_ActiveControlCenterAlign		=> _HMG_SYSDATA\[288]
#xtranslate _HMG_ActiveControlNoHScroll			=> _HMG_SYSDATA\[289]
#xtranslate _HMG_ActiveControlGripperText		=> _HMG_SYSDATA\[290]
#xtranslate _HMG_ActiveControlDisplayEdit		=> _HMG_SYSDATA\[291]
#xtranslate _HMG_ActiveControlDisplayChange		=> _HMG_SYSDATA\[292]
#xtranslate _HMG_ActiveControlNoVScroll			=> _HMG_SYSDATA\[293]
#xtranslate _HMG_ActiveControlPlainText			=> _HMG_SYSDATA\[294]
#xtranslate _HMG_ActiveControlForeColor			=> _HMG_SYSDATA\[295]
#xtranslate _HMG_ActiveControlDateType			=> _HMG_SYSDATA\[296]
#xtranslate _HMG_ActiveControlWhen			=> _HMG_SYSDATA\[297]
#xtranslate _HMG_ActiveControlDynamicForeColor		=> _HMG_SYSDATA\[298]
#xtranslate _HMG_ActiveControlDynamicBackColor		=> _HMG_SYSDATA\[299]
#xtranslate _HMG_ActiveControlInPlaceEdit		=> _HMG_SYSDATA\[300]
#xtranslate _HMG_ActiveControlItemSource		=> _HMG_SYSDATA\[301]
#xtranslate _HMG_ActiveControlValueSource		=> _HMG_SYSDATA\[302]
#xtranslate _HMG_ActiveControlWrap			=> _HMG_SYSDATA\[303]
#xtranslate _HMG_ActiveControlIncrement			=> _HMG_SYSDATA\[304]
#xtranslate _HMG_ActiveControlAddress			=> _HMG_SYSDATA\[305]
#xtranslate _HMG_ActiveControlItemCount			=> _HMG_SYSDATA\[306]
#xtranslate _HMG_ActiveControlOnQueryData		=> _HMG_SYSDATA\[307]
#xtranslate _HMG_ActiveControlAutoSize			=> _HMG_SYSDATA\[308]
#xtranslate _HMG_ActiveControlVirtual			=> _HMG_SYSDATA\[309]
#xtranslate _HMG_ActiveControlWhiteBack			=> _HMG_SYSDATA\[310]
#xtranslate _HMG_ActiveControlStretch			=> _HMG_SYSDATA\[311]
#xtranslate _HMG_ActiveControlFontBold			=> _HMG_SYSDATA\[312]
#xtranslate _HMG_ActiveControlFontItalic		=> _HMG_SYSDATA\[313]
#xtranslate _HMG_ActiveControlFontStrikeOut		=> _HMG_SYSDATA\[314]
#xtranslate _HMG_ActiveControlFontUnderLine		=> _HMG_SYSDATA\[315]
#xtranslate _HMG_ActiveControlName			=> _HMG_SYSDATA\[316]
#xtranslate _HMG_ActiveControlOf			=> _HMG_SYSDATA\[317]
#xtranslate _HMG_ActiveControlCaption			=> _HMG_SYSDATA\[318]
#xtranslate _HMG_ActiveControlAction			=> _HMG_SYSDATA\[319]
#xtranslate _HMG_ActiveControlWidth			=> _HMG_SYSDATA\[320]
#xtranslate _HMG_ActiveControlHeight			=> _HMG_SYSDATA\[321]
#xtranslate _HMG_ActiveControlFont			=> _HMG_SYSDATA\[322]
#xtranslate _HMG_ActiveControlSize			=> _HMG_SYSDATA\[323]
#xtranslate _HMG_ActiveControlTooltip			=> _HMG_SYSDATA\[324]
#xtranslate _HMG_ActiveControlFlat			=> _HMG_SYSDATA\[325]
#xtranslate _HMG_ActiveControlOnGotFocus		=> _HMG_SYSDATA\[326]
#xtranslate _HMG_ActiveControlOnLostFocus		=> _HMG_SYSDATA\[327]
#xtranslate _HMG_ActiveControlNoTabStop			=> _HMG_SYSDATA\[328]
#xtranslate _HMG_ActiveControlHelpId			=> _HMG_SYSDATA\[329]
#xtranslate _HMG_ActiveControlInvisible			=> _HMG_SYSDATA\[330]
#xtranslate _HMG_ActiveControlRow			=> _HMG_SYSDATA\[331]
#xtranslate _HMG_ActiveControlCol			=> _HMG_SYSDATA\[332]
#xtranslate _HMG_ActiveControlPicture			=> _HMG_SYSDATA\[333]
#xtranslate _HMG_ActiveControlValue			=> _HMG_SYSDATA\[334]
#xtranslate _HMG_ActiveControlOnChange			=> _HMG_SYSDATA\[335]
#xtranslate _HMG_ActiveControlOnSelect			=> _HMG_SYSDATA\[336]
#xtranslate _HMG_ActiveControlItems			=> _HMG_SYSDATA\[337]
#xtranslate _HMG_ActiveControlOnEnter			=> _HMG_SYSDATA\[338]

#xtranslate _HMG_ActiveControlShowNone			=> _HMG_SYSDATA\[339]
#xtranslate _HMG_ActiveControlUpDown			=> _HMG_SYSDATA\[340]
#xtranslate _HMG_ActiveControlRightAlign		=> _HMG_SYSDATA\[341]

#xtranslate _HMG_ActiveControlReadOnly			=> _HMG_SYSDATA\[342]
#xtranslate _HMG_ActiveControlMaxLength			=> _HMG_SYSDATA\[343]
#xtranslate _HMG_ActiveControlBreak			=> _HMG_SYSDATA\[344]

#xtranslate _HMG_ActiveControlOpaque			=> _HMG_SYSDATA\[345]

#xtranslate _HMG_ActiveControlHeaders			=> _HMG_SYSDATA\[346]
#xtranslate _HMG_ActiveControlWidths			=> _HMG_SYSDATA\[347]
#xtranslate _HMG_ActiveControlOnDblClick		=> _HMG_SYSDATA\[348]
#xtranslate _HMG_ActiveControlOnHeadClick		=> _HMG_SYSDATA\[349]
#xtranslate _HMG_ActiveControlNoLines			=> _HMG_SYSDATA\[350]
#xtranslate _HMG_ActiveControlImage			=> _HMG_SYSDATA\[351]
#xtranslate _HMG_ActiveControlJustify			=> _HMG_SYSDATA\[352]

#xtranslate _HMG_ActiveControlNoToday			=> _HMG_SYSDATA\[353]
#xtranslate _HMG_ActiveControlNoTodayCircle		=> _HMG_SYSDATA\[354]
#xtranslate _HMG_ActiveControlWeekNumbers		=> _HMG_SYSDATA\[355]

#xtranslate _HMG_ActiveControlMultiSelect		=> _HMG_SYSDATA\[356]
#xtranslate _HMG_ActiveControlEdit			=> _HMG_SYSDATA\[357]

#xtranslate _HMG_ActiveControlBackColor			=> _HMG_SYSDATA\[358]
#xtranslate _HMG_ActiveControlFontColor			=> _HMG_SYSDATA\[359]
#xtranslate _HMG_ActiveControlBorder			=> _HMG_SYSDATA\[360]
#xtranslate _HMG_ActiveControlClientEdge		=> _HMG_SYSDATA\[361]
#xtranslate _HMG_ActiveControlHScroll			=> _HMG_SYSDATA\[362]
#xtranslate _HMG_ActiveControlVscroll			=> _HMG_SYSDATA\[363]
#xtranslate _HMG_ActiveControlTransparent		=> _HMG_SYSDATA\[364]

#xtranslate _HMG_ActiveControlSort			=> _HMG_SYSDATA\[365]

#xtranslate _HMG_ActiveControlRangeLow			=> _HMG_SYSDATA\[366]
#xtranslate _HMG_ActiveControlRangeHigh			=> _HMG_SYSDATA\[367]
#xtranslate _HMG_ActiveControlVertical			=> _HMG_SYSDATA\[368]
#xtranslate _HMG_ActiveControlSmooth			=> _HMG_SYSDATA\[369]

#xtranslate _HMG_ActiveControlOnListDisplay		=> _HMG_SYSDATA\[370]
#xtranslate _HMG_ActiveControlOnListClose		=> _HMG_SYSDATA\[371]

#xtranslate _HMG_ActiveControlOptions			=> _HMG_SYSDATA\[372]
#xtranslate _HMG_ActiveControlSpacing			=> _HMG_SYSDATA\[373]

#xtranslate _HMG_ActiveControlNoTicks			=> _HMG_SYSDATA\[374]
#xtranslate _HMG_ActiveControlBoth			=> _HMG_SYSDATA\[375]
#xtranslate _HMG_ActiveControlTop			=> _HMG_SYSDATA\[376]
#xtranslate _HMG_ActiveControlLeft			=> _HMG_SYSDATA\[377]

#xtranslate _HMG_ActiveControlUpperCase			=> _HMG_SYSDATA\[378]
#xtranslate _HMG_ActiveControlLowerCase			=> _HMG_SYSDATA\[379]
#xtranslate _HMG_ActiveControlNumeric			=> _HMG_SYSDATA\[380]
#xtranslate _HMG_ActiveControlPassword			=> _HMG_SYSDATA\[381]
#xtranslate _HMG_ActiveControlInputMask			=> _HMG_SYSDATA\[382]

#xtranslate _HMG_ActiveControlWorkArea			=> _HMG_SYSDATA\[383]
#xtranslate _HMG_ActiveControlFields			=> _HMG_SYSDATA\[384]
#xtranslate _HMG_ActiveControlDelete			=> _HMG_SYSDATA\[385]
#xtranslate _HMG_ActiveControlValid			=> _HMG_SYSDATA\[386]
#xtranslate _HMG_ActiveControlValidMessages		=> _HMG_SYSDATA\[387]
#xtranslate _HMG_ActiveControlLock			=> _HMG_SYSDATA\[388]
#xtranslate _HMG_ActiveControlAppendable		=> _HMG_SYSDATA\[389]

#xtranslate _HMG_ActiveControlFile			=> _HMG_SYSDATA\[390]
#xtranslate _HMG_ActiveControlAutoPlay			=> _HMG_SYSDATA\[391]
#xtranslate _HMG_ActiveControlCenter			=> _HMG_SYSDATA\[392]
#xtranslate _HMG_ActiveControlNoAutoSizeWindow		=> _HMG_SYSDATA\[393]
#xtranslate _HMG_ActiveControlNoAutoSizeMovie		=> _HMG_SYSDATA\[394]
#xtranslate _HMG_ActiveControlNoErrorDlg		=> _HMG_SYSDATA\[395]
#xtranslate _HMG_ActiveControlNoMenu			=> _HMG_SYSDATA\[396]
#xtranslate _HMG_ActiveControlNoOpen			=> _HMG_SYSDATA\[397]
#xtranslate _HMG_ActiveControlNoPlayBar			=> _HMG_SYSDATA\[398]
#xtranslate _HMG_ActiveControlShowAll			=> _HMG_SYSDATA\[399]
#xtranslate _HMG_ActiveControlShowMode			=> _HMG_SYSDATA\[400]
#xtranslate _HMG_ActiveControlShowName			=> _HMG_SYSDATA\[401]
#xtranslate _HMG_ActiveControlShowPosition		=> _HMG_SYSDATA\[402]

#xtranslate _HMG_ActiveControlFormat			=> _HMG_SYSDATA\[403]
#xtranslate _HMG_ActiveControlField			=> _HMG_SYSDATA\[404]
#xtranslate _HMG_ActiveControlThreeState		=> _HMG_SYSDATA\[405]
#xtranslate _HMG_ActiveControlId			=> _HMG_SYSDATA\[406]

#xtranslate _HMG_ActiveControlTitleBackColor		=> _HMG_SYSDATA\[407]
#xtranslate _HMG_ActiveControlTitleFontColor		=> _HMG_SYSDATA\[408]
#xtranslate _HMG_ActiveControlBackgroundColor		=> _HMG_SYSDATA\[409]
#xtranslate _HMG_ActiveControlTrailingFontColor		=> _HMG_SYSDATA\[410]

#xtranslate _HMG_ActiveTBrowseName			=> _HMG_SYSDATA\[411]
#xtranslate _HMG_ActiveTBrowseHandle			=> _HMG_SYSDATA\[412]
#xtranslate _HMG_BeginTBrowseActive			=> _HMG_SYSDATA\[413]
#xtranslate _HMG_AutoAdjust				=> _HMG_SYSDATA\[414]
#xtranslate _HMG_ProgrammaticChange			=> _HMG_SYSDATA\[415]
#xtranslate _HMG_aFormNotifyIconDblClick		=> _HMG_SYSDATA\[416]
#xtranslate _HMG_ActiveTabColor				=> _HMG_SYSDATA\[417]
#xtranslate _HMG_FldID					=> _HMG_SYSDATA\[418]
#xtranslate _HMG_aFolderInfo				=> _HMG_SYSDATA\[419]

#xtranslate _HMG_ListBoxDragListId			=> _HMG_SYSDATA\[420]
#xtranslate _HMG_ListBoxDragItem			=> _HMG_SYSDATA\[421]
#xtranslate _HMG_ListBoxDragNotification		=> _HMG_SYSDATA\[422]

#xtranslate _HMG_DefaultIconName			=> _HMG_SYSDATA\[423]
#xtranslate _HMG_aControlMiscData2			=> _HMG_SYSDATA\[424]

#xtranslate _HMG_BeginPagerActive			=> _HMG_SYSDATA\[425]
#xtranslate _HMG_ActivePagerForm			=> _HMG_SYSDATA\[426]

#xtranslate _HMG_LoadWindowRow				=> _HMG_SYSDATA\[427]
#xtranslate _HMG_LoadWindowCol				=> _HMG_SYSDATA\[428]
#xtranslate _HMG_LoadWindowWidth			=> _HMG_SYSDATA\[429]
#xtranslate _HMG_LoadWindowHeight			=> _HMG_SYSDATA\[430]

#xtranslate _HMG_ParentWindowActive			=> _HMG_SYSDATA\[431]
#xtranslate _HMG_AutoAdjustException			=> _HMG_SYSDATA\[432]
#xtranslate _HMG_AutoZooming				=> _HMG_SYSDATA\[433]
#xtranslate _HMG_GlobalHotkeys				=> _HMG_SYSDATA\[434]
#xtranslate _HMG_GridNavigationMode			=> _HMG_SYSDATA\[435]

#xtranslate _HMG_PGLangButton				=> _HMG_SYSDATA\[436]
#xtranslate _HMG_PGLangError				=> _HMG_SYSDATA\[437]
#xtranslate _HMG_PGLangMessage				=> _HMG_SYSDATA\[438]
#xtranslate _HMG_PGEncodingXml				=> _HMG_SYSDATA\[439]

#xtranslate _HMG_LastActiveFormIndex			=> _HMG_SYSDATA\[440]
#xtranslate _HMG_LastActiveControlIndex			=> _HMG_SYSDATA\[441]
#xtranslate _HMG_StopWindowEventProcedure		=> _HMG_SYSDATA\[442]
#xtranslate _HMG_StopControlEventProcedure		=> _HMG_SYSDATA\[443]
#xtranslate _HMG_MainWindowFirst			=> _HMG_SYSDATA\[444]
#xtranslate _HMG_aScrollStep				=> _HMG_SYSDATA\[445]

#xtranslate _HMG_aFormMiscData1				=> _HMG_SYSDATA\[446]
#xtranslate _HMG_aFormMiscData2				=> _HMG_SYSDATA\[447]

#xtranslate _HMG_aUserBlocks				=> _HMG_SYSDATA\[448]
#xtranslate _HMG_bOnFormInit				=> _HMG_aUserBlocks\[1]
#xtranslate _HMG_bOnFormDestroy				=> _HMG_aUserBlocks\[2]
#xtranslate _HMG_bOnControlInit				=> _HMG_aUserBlocks\[3]
#xtranslate _HMG_bOnControlDestroy			=> _HMG_aUserBlocks\[4]
#xtranslate _HMG_bOnWndLaunch				=> _HMG_aUserBlocks\[5]
#xtranslate _HMG_bOnCtlLaunch				=> _HMG_aUserBlocks\[6]
#xtranslate _HMG_lOOPEnabled				=> _HMG_aUserBlocks\[7]

#xtranslate _HMG_IsThemed				=> _HMG_SYSDATA\[449]
#xtranslate _HMG_RptData				=> _HMG_SYSDATA\[450]

#xtranslate _HMG_MsgIDFindDlg				=> _HMG_SYSDATA\[451]
#xtranslate _HMG_FindReplaceOnAction			=> _HMG_SYSDATA\[452]
#xtranslate _HMG_FindReplaceOptions			=> _HMG_SYSDATA\[453]
#xtranslate _HMG_CharRange_Min				=> _HMG_SYSDATA\[454]
#xtranslate _HMG_CharRange_Max				=> _HMG_SYSDATA\[455]

