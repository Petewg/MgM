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

#ifndef __HMG__
#define __HMG__ 0x020701 /* Three bytes: Major + Minor + Build. */

#ifndef HMG_LEGACY_ON
  #define HMG_LEGACY_OFF
#endif

/* ***********************************************************************
 * Enable multilingual support in HMG
 *
 * Note that if you turn this off, the English will be set as the default language.
 *
 * By default this is turned on.
 */
#define _MULTILINGUAL_

/* ***********************************************************************
 * Enable support for TSBrowse library in HMG
 *
 * By default this is turned on.
 */
#define _TSBROWSE_

/* ***********************************************************************
 * Enable support for PropGrid library in HMG
 *
 * By default this is turned on.
 */
#define _PROPGRID_

/* ***********************************************************************
 * Disable this option if you want that the internal Public variables to be
 * equate to zero at windows and controls destroying (similar to Official HMG).
 *
 * By default this is turned on.
 */
#define _PUBLIC_RELEASE_

/* ***********************************************************************
 * Enable support for optional semi-oop syntax for containers in HMG
 *
 * By default this is turned on.
 */
#define _SOOP_CONTAINERS_

/* ***********************************************************************
 * Enable support for standard Browse control in HMG
 *
 * By default this is turned on.
 */
#define _DBFBROWSE_

/* ***********************************************************************
 * Enable support for Panel windows in HMG
 *
 * By default this is turned on.
 */
#define _PANEL_

/* ***********************************************************************
 * Enable support for Pager toolbar in HMG
 *
 * By default this is turned on.
 */
#define _PAGER_

/* ***********************************************************************
 * Enable support for compatibility with Official HMG code
 *
 * By default this is turned on.
 */
#define _HMG_COMPAT_

/* ***********************************************************************
 * Enable support for simple debug logging
 *
 * By default this is turned off to preserve the proper Harbour functionality.
#ifndef _HMG_OUTLOG
  #define _HMG_OUTLOG
#endif
 */

/* ***********************************************************************
 * Enable support for User Components in HMG
 *
 * By default this is turned on.
 */
#define _USERINIT_

#ifdef _USERINIT_
  #include "i_UsrInit.ch"
  #include "i_UsrSOOP.ch"
#else
  #xcommand DECLARE CUSTOM COMPONENTS <Window> ;
  =>;
  #define SOOP_DUMMY ;;
  #undef SOOP_DUMMY
#endif

#include "i_var.ch"
#include "i_error.ch"
#include "i_media.ch"
#include "i_pseudofunc.ch"
#include "i_exec.ch"
#include "i_comm.ch"
#include "i_keybd.ch"
#include "i_keybd_ext.ch"
#include "i_checkbox.ch"
#include "i_menu.ch"
#include "i_misc.ch"
#include "i_timer.ch"
#include "i_frame.ch"
#include "i_slider.ch"
#include "i_progressbar.ch"
#include "i_window.ch"
#include "i_window_ext.ch"
#include "i_button.ch"
#include "i_image.ch"
#include "i_imagelist.ch"
#include "i_radiogroup.ch"
#include "i_label.ch"
#include "i_combobox.ch"
#include "i_datepicker.ch"
#include "i_listbox.ch"
#include "i_spinner.ch"
#include "i_textbox.ch"
#include "i_editbox.ch"
#include "i_grid.ch"
#include "i_tab.ch"
#include "i_controlmisc.ch"
#include "i_color.ch"
#include "i_toolbar.ch"
#include "i_splitbox.ch"
#include "i_tree.ch"
#include "i_status.ch"
#include "i_ini.ch"
#include "i_encrypt.ch"
#include "i_Help.ch"
#include "i_monthcal.ch"
#include "i_region.ch"
#include "i_socket.ch"
#include "i_ipaddress.ch"
#include "i_altsyntax.ch"
#include "i_ScrSaver.ch"
#include "i_registry.ch"
#include "i_edit.ch"
#include "i_report.ch"
#include "i_lang.ch"
#include "i_this.ch"
#include "i_hyperlink.ch"
#include "i_zip.ch"
#include "i_graph.ch"
#include "i_richeditbox.ch"
#include "i_browse.ch"
#include "i_dll.ch"
#include "i_tooltip.ch"
#include "i_dialog.ch"
#include "i_font.ch"
#include "i_winprop.ch"
#include "i_getbox.ch"
#include "i_btntextbox.ch"
#include "i_hotkeybox.ch"
#include "i_brush.ch"
#include "i_folder.ch"
#include "i_pager.ch"
#include "i_chklabel.ch"

#ifdef _MIXEDMODE_
  ANNOUNCE HB_GTSYS
  REQUEST HB_GT_WIN_DEFAULT
#endif

#endif
