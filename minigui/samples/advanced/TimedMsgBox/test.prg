/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2008 Roberto Lopez <harbourminigui@gmail.com>
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
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - https://harbour.github.io

	"Harbour Project"
	Copyright 1999-2018, https://harbour.github.io/
---------------------------------------------------------------------------
     THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
     ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
     THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
     PARTICULAR PURPOSE.
*-----------------------------------------------------------------------------*/

#include <minigui.ch>

#define IDOK 1
#define IDCANCEL 2
#define IDRETRY 4
#define IDYES 6
#define IDNO 7

*-----------------------------------------------------------------------------*
Procedure Main()
*-----------------------------------------------------------------------------*

 DEFINE WINDOW FrmTMsgTest;
    AT 0, 0;
    WIDTH 300;
    HEIGHT 200;
    TITLE "Timed Message Test";
    MAIN;
    ON INIT (Msgt(3,"Timed Message Test" + CRLF + "Duration is 3 seconds","Info"),test2())

 END WINDOW

 FrmTMsgTest.Center
 FrmTMsgTest.Activate

Return

*-----------------------------------------------------------------------------*
Procedure Test2()
*-----------------------------------------------------------------------------*
      SET NAVIGATION EXTENDED

      DEFINE WINDOW FrmTest2;
             AT 0, 0;
             WIDTH 400;
             HEIGHT 200;        
             TITLE "Timed Message";
             ON INIT Msgt(5,"2° Timed Message Test" + CRLF + "Duration is 5 seconds","2 Info");
             ON INTERACTIVECLOSE ReleaseAllWindows()

             @ 10,10 LABEL label_1 ;
                           VALUE 'Simple Code:' ;
                           WIDTH 100

             @ 10,120 TEXTBOX text_2 ;                      
                      VALUE 'Test2'  ;                       
                      On Enter Msgt("On enter - No Timer!",[test2]) 

             @ 40,120 TEXTBOX text_3 ;                      
                      VALUE 'Test3';                         
                      On Enter Msgt(2,"on enter",[test3],"YESNO")

             @ 70,120 TEXTBOX text_4 ;
                      VALUE 'test 4' ;
                      On Lostfocus Quiz_Test()

      END WINDOW

      FrmTest2.Center
      FrmTest2.Activate

Return

*-----------------------------------------------------------------------------*
Function Quiz_Test()
*-----------------------------------------------------------------------------*
local result:= msgt(4,"Does a triangle have three sides?","Quiz",'YESNO')

      do case
         case Result==IDYES .Or. Result==IDOK .Or. Result==IDRETRY
              Msgt("That's right!", "Result")

         case Result==IDNO .Or. Result==IDCANCEL
              Msgt("Believe it or not, triangles "+CRLF+"really do have three sides.", "Result")

         otherwise
              Msgt("I sensed some hesitation there. "+CRLF+"The correct answer is Yes.", "Result")
      endcase

return result

*-----------------------------------------------------------------------------*
Function Msgt (nTimeout, Message, Title, Flags) 
*-----------------------------------------------------------------------------*
* Created at 04/20/2005 By Pierpaolo Martinello Italy                         *
*-----------------------------------------------------------------------------*
        local switch:=.f., rtv:=0

        DEFAULT Message TO "" , Title TO "" , Flags TO "MSGBOX"

        If ValType (nTimeout) != 'U' .and. ValType (nTimeout) = 'C'  
              Flags    :=  Title
              Title    :=  Message
              Message  :=  nTimeout
              switch   :=  .t.
        endif 

        Flags:=UPPER(Flags)
        Message+= if(empty(Message),"Empty string!","")

        if switch 
           do case

              case "RETRYCANCEL" == FLAGS
                   rtv := MsgRetryCancel(Message,title)

              case "OKCANCEL" == FLAGS
                   rtv := MsgOkCancel(Message,Title)

              case "YESNO" == FLAGS
                   rtv := MsgYesNo(Message,Title)

              case "YESNO_ID" == FLAGS
                   rtv := MsgYesNo(Message,Title,.t.)

              case "INFO" == FLAGS
                   rtv := MsgInfo(Message,Title)

              case "STOP" == FLAGS
                   rtv := MsgStop(Message,Title)

              case "EXCLAMATION" == FLAGS
                   rtv := MsgExclamation(Message,Title)

              otherwise 
                   MsgBox(Message,Title)
           endcase
        else
           do case

              case "RETRYCANCEL" == FLAGS
                   rtv := C_T_MSGRETRYCANCEL(Message,Title,nTimeout*1000)

              case "OKCANCEL" == FLAGS
                   rtv := C_T_MSGOKCANCEL(Message,Title,nTimeout*1000)

              case "YESNO" == FLAGS
                   rtv := C_T_MSGYESNO(Message,Title,nTimeout*1000)

              case "YESNO_ID" == FLAGS
                   rtv := C_T_MSGYESNO_ID(Message,Title,nTimeout*1000)

              case "INFO" == FLAGS
                   rtv := C_T_MSGINFO(Message,Title,nTimeout*1000)

              case "STOP" == FLAGS
                   rtv := C_T_MSGSTOP(Message,Title,nTimeout*1000)

              case "EXCLAMATION" == FLAGS
                   rtv := C_T_MSGEXCLAMATION(Message,Title,nTimeout*1000)

              otherwise 
                   rtv := C_T_MSGBOX(Message,Title,nTimeout*1000)
           endcase
       endif 
return rtv


#pragma BEGINDUMP

#define _WIN32_IE      0x0500
#define HB_OS_WIN_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include "hbapi.h"

#pragma argsused    // We need a lowercase!!!

void CALLBACK
MessageBoxTimer(HWND hwnd , UINT uiMsg , UINT idEvent , DWORD  dwTime)
{
    PostQuitMessage(0);
}

UINT
TimedMessageBox(
    HWND hwndParent,
    LPCTSTR ptszMessage,
    LPCTSTR ptszTitle,
    UINT flags,
    DWORD dwTimeout)
{
    UINT idTimer;
    UINT uiResult;
    MSG msg;

    /*
     *  Set a timer to dismiss the Message box.
     */
    idTimer = SetTimer(NULL, 0, dwTimeout, (TIMERPROC)MessageBoxTimer);

    uiResult = MessageBox(hwndParent, ptszMessage ? ptszMessage : "", ptszTitle ? ptszTitle :"", flags);

    /*
     *  Finished with the timer.
     */
    KillTimer(NULL, idTimer);

    /*
     *  See if there is a WM_QUIT Message in the queue. If so,
     *  then you timed out. Eat the Message so you don't quit the
     *  entire application.
     */
    if (PeekMessage(&msg, NULL, WM_QUIT, WM_QUIT, PM_REMOVE)) {

        /*
         *  If you timed out, then return zero.
         */
        uiResult = 0;
    }

    return uiResult;
}

HB_FUNC( C_T_MSGRETRYCANCEL )
{
	int r ;
	r = TimedMessageBox( NULL, hb_parc(1),hb_parc(2) , MB_RETRYCANCEL | MB_ICONQUESTION | MB_SYSTEMMODAL ,hb_parni(3)) ;
	hb_retni ( r ) ;
}

HB_FUNC( C_T_MSGOKCANCEL )
{
	int r ;
	r = TimedMessageBox( NULL, hb_parc(1),hb_parc(2) , MB_OKCANCEL | MB_ICONQUESTION | MB_SYSTEMMODAL ,hb_parni(3)) ;
	hb_retni ( r ) ;
}

HB_FUNC( C_T_MSGYESNO )
{
	int r ;
	r = TimedMessageBox( NULL, hb_parc(1),hb_parc(2) , MB_YESNO | MB_ICONQUESTION | MB_SYSTEMMODAL ,hb_parni(3)) ;
	hb_retni ( r ) ;
}

HB_FUNC( C_T_MSGYESNO_ID )
{
	int r ;
	r = TimedMessageBox( NULL, hb_parc(1),hb_parc(2) , MB_YESNO | MB_ICONQUESTION | MB_SYSTEMMODAL| MB_DEFBUTTON2 ,hb_parni(3)) ;
	hb_retni ( r ) ;
}

HB_FUNC( C_T_MSGBOX )
{
	TimedMessageBox( NULL, hb_parc(1),hb_parc(2) ,MB_SYSTEMMODAL,hb_parni(3)) ;
}

HB_FUNC( C_T_MSGINFO )
{
	TimedMessageBox( NULL, hb_parc(1) , hb_parc(2) , MB_OK | MB_ICONINFORMATION | MB_SYSTEMMODAL ,hb_parni(3));
}

HB_FUNC( C_T_MSGSTOP )
{
	TimedMessageBox( NULL , hb_parc(1) , hb_parc(2) , MB_OK | MB_ICONSTOP | MB_SYSTEMMODAL ,hb_parni(3));
}

HB_FUNC( C_T_MSGEXCLAMATION )
{
	TimedMessageBox(NULL, hb_parc(1), hb_parc(2), MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL, hb_parni(3));
}

#pragma ENDDUMP
