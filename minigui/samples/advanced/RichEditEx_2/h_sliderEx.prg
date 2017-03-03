/*----------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code

Copyright 2002-2009 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/

 SliderEx control source code
 (C)2009 Janusz Pora <januszpora@onet.eu>


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
   Copyright 1999-2009, http://harbour-project.org/

   "WHAT32"
   Copyright 2002 AJ Wos <andrwos@aust1.net>

   "HWGUI"
   Copyright 2001-2007 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/

#include "minigui.ch"

*-----------------------------------------------------------------------------*
Function _SetThumbLength ( ControlName, ParentForm , Value  )
*-----------------------------------------------------------------------------*
Local i , h

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   SetThumbLength ( h , Value  )
Return Nil

*-----------------------------------------------------------------------------*
Function _SetSelStart ( ControlName, ParentForm , Value  )
*-----------------------------------------------------------------------------*
Local i , h

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   SetSelStart ( h , Value  )
Return Nil

*-----------------------------------------------------------------------------*
Function _SetSelEnd ( ControlName, ParentForm , Value  )
*-----------------------------------------------------------------------------*
Local i , h

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   SetSelEnd ( h , Value  )
Return Nil


*-----------------------------------------------------------------------------*
Function _SetTic ( ControlName, ParentForm , Value  )
*-----------------------------------------------------------------------------*
Local i , h

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   SetTic ( h , Value  )
Return Nil
*-----------------------------------------------------------------------------*
Function _ClearTics ( ControlName, ParentForm   )
*-----------------------------------------------------------------------------*
Local i , h

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   ClearTics ( h  )
Return Nil

*-----------------------------------------------------------------------------*
Function _SetPageSize ( ControlName, ParentForm , Value  )
*-----------------------------------------------------------------------------*
Local i , h

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   SetPageSize ( h , Value )
Return Nil

*-----------------------------------------------------------------------------*
Function _SetPosSlider ( ControlName, ParentForm , Value)
*-----------------------------------------------------------------------------*
Local i , h

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   SetPos ( h , Value )
Return Nil



*-----------------------------------------------------------------------------*
Function _GetPosSlider ( ControlName, ParentForm )
*-----------------------------------------------------------------------------*
Local i , h , nPos

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   nPos := GetPos ( h )
Return nPos

*-----------------------------------------------------------------------------*
Function _GetTicPos ( ControlName, ParentForm ,Value)
*-----------------------------------------------------------------------------*
Local i , h , nPos

   i := GetControlIndex ( ControlName, ParentForm )
   h := _HMG_aControlhandles [i]

   nPos := GetTicPos ( h ,Value )
Return nPos


*********************************************************************

#pragma BEGINDUMP


#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include <richedit.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"
#include "Winuser.h"
#include <wingdi.h>
#include <setupapi.h>



#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"

/*
HB_FUNC ( INITSLIDER )
{
   HWND hwnd;
   HWND hbutton;

   int Style = WS_CHILD | TBS_FIXEDLENGTH | TBS_ENABLESELRANGE ;

   INITCOMMONCONTROLSEX  i;
   i.dwSize = sizeof(INITCOMMONCONTROLSEX);
   i.dwICC = ICC_DATE_CLASSES;
   InitCommonControlsEx(&i);

   hwnd = (HWND) hb_parnl (1);

   if ( !hb_parl (10) )
   {
      Style = Style | TBS_AUTOTICKS ;
   }

   if ( hb_parl (10) )
   {
      Style = Style | TBS_NOTICKS ;
   }

   if ( hb_parl (9) )
   {
      Style = Style | TBS_VERT ;
   }

   if ( hb_parl (11) )
   {
      Style = Style | TBS_BOTH ;
   }

   if ( hb_parl (12) )
   {
      Style = Style | TBS_TOP ;
   }

   if ( hb_parl (13) )
   {
      Style = Style | TBS_LEFT ;
   }

   if ( !hb_parl (14) )
   {
      Style = Style | WS_VISIBLE ;
   }

   if ( !hb_parl (15) )
   {
      Style = Style | WS_TABSTOP ;
   }

   hbutton = CreateWindow(TRACKBAR_CLASS ,0,
   Style ,
   hb_parni(3), hb_parni(4) ,hb_parni(5) ,hb_parni(6) ,
   hwnd,(HMENU)hb_parni(2) , GetModuleHandle(NULL) , NULL ) ;

   SendMessage( hbutton, TBM_SETRANGE, TRUE, MAKELONG(hb_parni(7),hb_parni(8)));

   hb_retnl ( (LONG) hbutton );
}

*/

HB_FUNC ( SETTHUMBLENGTH )
{
   SendMessage( (HWND) hb_parnl (1), TBM_SETTHUMBLENGTH, (WPARAM)(INT) hb_parni(2),0);
}

HB_FUNC ( SETSELEND )
{
   SendMessage( (HWND) hb_parnl (1), TBM_SETSELEND, (WPARAM)(BOOL) TRUE, (LPARAM) (LONG) hb_parnl(2));
}

HB_FUNC ( SETSELSTART )
{
   SendMessage( (HWND) hb_parnl (1), TBM_SETSELSTART, (WPARAM)(BOOL) TRUE, (LPARAM) (LONG) hb_parnl(2));
}
HB_FUNC ( SETTIC )
{
   SendMessage( (HWND) hb_parnl (1), TBM_SETTIC, 0, (LPARAM) (LONG) hb_parnl(2));
}
HB_FUNC ( CLEARTICS  )
{
   SendMessage( (HWND) hb_parnl (1), TBM_CLEARTICS,(WPARAM)(BOOL) TRUE, 0);
}
HB_FUNC ( SETPAGESIZE  )
{
   SendMessage( (HWND) hb_parnl (1), TBM_SETPAGESIZE, 0 , (LPARAM) (LONG) hb_parnl(2));
}
/*
HB_FUNC ( SETPOS  )
{
   SendMessage( (HWND) hb_parnl (1), TBM_SETPOS,(WPARAM)(BOOL) TRUE , (LPARAM) (LONG) hb_parnl(2));
}
*/
HB_FUNC ( GETPOS  )
{
    WORD pos;
   pos = SendMessage( (HWND) hb_parnl (1), TBM_GETPOS, 0 , 0);
    hb_retnl ( (LONG) pos);
}

HB_FUNC ( GETTICPOS  )
{
    WORD pos;
   pos = SendMessage( (HWND) hb_parnl (1), TBM_GETTICPOS, (WPARAM) (WORD) hb_parnl (2) , 0);
    hb_retnl ( (LONG) pos);
}





#pragma ENDDUMP



