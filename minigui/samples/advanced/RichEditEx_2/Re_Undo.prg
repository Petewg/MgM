/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2005 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2003-2009 Janusz Pora <JanuszPora@onet.eu>
*/

#include "minigui.ch"

*-----------------------------------------------------------------------------*
Function Undo_Click()
*-----------------------------------------------------------------------------*
    lUndo :=.t.
    UndoRTF(hEd)
    lUndo :=.f.
Return NIL

*-----------------------------------------------------------------------------*
Function Redo_Click()
*-----------------------------------------------------------------------------*
    RedoRTF(hEd)
Return NIL

*--------------------------------------------------
Function AddMenuUndo( nUndo ,typ )
*--------------------------------------------------
    Local x, n, cx, nu
    Local action , cAction , Caption, cyUndo_Id, cxUndo_Id

    X:=len(aUndo)
    Caption := emumUndo[nUndo+1]
    cAction := '{|| mUndo_Click( 1 ) }'
    action :=&cAction

    if typ == 1
        // Check if this is the first item
        If len(aUndo) == 0
            // Modify a first element the menu
            cxUndo_Id := cUndo_Id
            _ModifyMenuItem ( cxUndo_Id , MainForm ,caption , action  )
            aadd( aUndo , { nUndo, cUndo_Id, action, 1 })
        Else
            if aUndo[1,1] != nUndo
                cx:=  alltrim(str( x ))   //strzero(x,2)
                cyUndo_Id := cUndo_Id +'_'+ cx
                cxUndo_Id := aUndo[1,2]
                _InsertMenuItem ( cxUndo_Id , MainForm ,caption , action, cyUndo_Id  )
                ASIZE(aUndo, Len(aUndo)+1)
                AINS( aUndo, 1 )
                cAction := '{|| mUndo_Click( 1 )}'
                action :=&cAction
                aUndo[ 1 ] := {nUndo,cyUndo_Id,action,1}
            else
                nU := aUndo[ 1 , 4 ] + 1
                aUndo[ 1 , 4 ] := nU
                cxUndo_Id := aUndo[1,2]
                _ModifyMenuItem ( cxUndo_Id , MainForm , Caption+' ('+alltrim(str(nU))+')' , aUndo[1,3] )

            endif

        Endif
    else
            if aUndo[1,1] != nUndo
                cxUndo_Id := aUndo[ 1 , 2 ]
                ADEL( aUndo, 1 )
                ASIZE(aUndo, Len(aUndo)-1)
                if len(aUndo)>0
                  _RemoveMenuItem( cxUndo_Id , MainForm)
                else
                  _ModifyMenuItem ( cxUndo_Id , MainForm ,caption , action  )
                endif
            else
                nU := aUndo[ 1 , 4 ] - 1
                aUndo[ 1 , 4 ] := nU
                cxUndo_Id := aUndo[1,2]
                _ModifyMenuItem ( cxUndo_Id , MainForm , Caption+' ('+alltrim(str(nU))+')' , aUndo[1,3] )
            endif
    endif
    if CanUndo(hEd)
        if len(aUndo) != X
            for n := 1 to len(aUndo)
                cAction := '{|| mUndo_Click( '+str(n) + ') }'
                action :=&cAction
                nU := aUndo[ n , 4 ]
                Caption := emumUndo[aUndo[n,1]+1]
                cxUndo_Id := aUndo[n,2]
                _ModifyMenuItem ( cxUndo_Id , MainForm , Caption+' ('+alltrim(str(nU))+')' , action )
            next
        endif
    else
        aUndo := {}
    endif
Return Nil

*--------------------------------------------------
Function mUndo_Click( nUndoIt )
*--------------------------------------------------
    Local nPos , n , nUndo
    Local aTyp := {}
    nPos :=  nUndoIt
    for n := 1 to nPos
        Aadd(aTyp,aUndo[n,1])
    next
    syg(0)
    for n := 1 to len(aTyp)
        nUndo := aTyp[n]
        do while nUndo == GetUndoName(hEd) .and. CanUndo(hEd)
            Undo_Click()
        enddo
    next
    if ! CanUndo(hEd)
       aUndo := {}
    endif
Return Nil

*--------------------------------------------------
Function ClearUndo_Click()
*--------------------------------------------------
    Local n , cxUndo_Id
    for n :=1 to len(aUndo)
       cxUndo_Id := aUndo[ n , 2 ]
      _RemoveMenuItem( cxUndo_Id , MainForm)
    next
    aUndo:={}
    ClearUndoBuffer(hEd)
    Btn_Stat(1)
Return Nil

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


#pragma argsused
int CALLBACK enumFontFamilyProc(ENUMLOGFONTEX *lpelfe, NEWTEXTMETRICEX *lpntme, DWORD FontType, LPARAM lParam)
{
   if (lpelfe && lParam)
   {
      if (FontType == TRUETYPE_FONTTYPE ) //DEVICE_FONTTYPE | RASTER_FONTTYPE
         SendMessage( (HWND) lParam, CB_ADDSTRING, 0, (LPARAM) (LPSTR) lpelfe->elfFullName);
   }
    return 1;
}

void enumFonts(HWND hWndEdit )
{
   LOGFONT lf;
   HDC hDC = GetDC(NULL);
   HWND hWnd = hWndEdit;
   lf.lfCharSet=ANSI_CHARSET;
   lf.lfPitchAndFamily=0;
   strcpy(lf.lfFaceName,"\0");

   EnumFontFamiliesEx(hDC, &lf, (FONTENUMPROC) enumFontFamilyProc, (LPARAM) hWnd, 0);
   SendMessage( (HWND) hWnd, CB_SETDROPPEDWIDTH, 200, 0);
   ReleaseDC(NULL, hDC);
}

HB_FUNC( RE_GETFONTS)
{
   enumFonts((HWND) hb_parnl (1) );
}


HB_FUNC ( GETDEVCAPS ) // GetDevCaps ( hwnd )
{

    INT      ix;
    HDC      hdc;
    HWND     hwnd;

    hwnd =   (HWND) hb_parnl (1);

    hdc = GetDC( hwnd );

    ix =  GetDeviceCaps( hdc,LOGPIXELSX );

    ReleaseDC( hwnd, hdc );

    hb_retni( (UINT) ix );

}


#pragma ENDDUMP

