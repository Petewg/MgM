/*-------------------------------------------------------------------------
   MINIGUI - Harbour Win32 GUI library source code

   Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
   http://harbourminigui.googlepages.com/

   This  program is free software; you can redistribute it and/or modify it
   under  the  terms  of the GNU General Public License as published by the
   Free  Software  Foundation; either version 2 of the License, or (at your
   option) any later version.

   This  program  is  distributed  in  the hope that it will be useful, but
   WITHOUT   ANY   WARRANTY;   without   even   the   implied  warranty  of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
   Public License for more details.

   You  should have received a copy of the GNU General Public License along
   with  this  software;  see  the  file COPYING. If not, write to the Free
   Software  Foundation,  Inc.,  59  Temple  Place,  Suite  330, Boston, MA
   02111-1307 USA (or visit the web site http://www.gnu.org/).

   As  a  special exception, you have permission for additional uses of the
   text contained in this release of Harbour Minigui.

   The  exception  is  that,  if  you link the Harbour Minigui library with
   other  files to produce an executable, this does not by itself cause the
   resulting  executable  to  be covered by the GNU General Public License.
   Your  use  of  that  executable  is  in  no way restricted on account of
   linking the Harbour-Minigui library code into it.

   Parts of this project are based upon:

    "Harbour GUI framework for Win32"
    Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
    Copyright 2001 Antonio Linares <alinares@fivetech.com>
    www - https://harbour.github.io/

    "Harbour Project"
    Copyright 1999-2018, https://harbour.github.io/

    "WHAT32"
    Copyright 2002 AJ Wos <andrwos@aust1.net>

    "HWGUI"
    Copyright 2001-2015 Alexander S.Kresin <alex@belacy.ru>

   Parts of this code  is contributed and used here under permission of his
   author: Copyright 2016 (C) P.Chornyj <myorg63@mail.ru>
   ----------------------------------------------------------------------*/

#ifndef WM_USER
#define WM_USER                 0x0400
#endif
#define TTM_SETDELAYTIME        (WM_USER + 3)
#define TTM_SETTIPBKCOLOR       (WM_USER + 19)
#define TTM_SETTIPTEXTCOLOR     (WM_USER + 20)
#define TTM_SETMAXTIPWIDTH      (WM_USER + 24)
#define TTM_SETTITLE            (WM_USER + 32)

#define TTI_NONE                0
#define TTI_INFO                1
#define TTI_WARNING             2
#define TTI_ERROR               3
#define TTI_INFO_LARGE          4
#define TTI_WARNING_LARGE       5
#define TTI_ERROR_LARGE         6

#define TTDT_AUTOMATIC          0
#define TTDT_RESHOW             1
#define TTDT_AUTOPOP            2
#define TTDT_INITIAL            3

#define TTS_ALWAYSTIP           0x1
#define TTS_NOPREFIX            0x2
#define TTS_NOANIMATE           0x10
#define TTS_NOFADE              0x20
#define TTS_BALLOON             0x40
#define TTS_CLOSE               0x80
#define TTS_USEVISUALSTYLE      0x100

#define TTF_IDISHWND            0x1
#define TTF_CENTERTIP           0x2
#define TTF_RTLREADING          0x4
#define TTF_SUBCLASS            0x10
#define TTF_TRACK               0x20
#define TTF_ABSOLUTE            0x80
#define TTF_TRANSPARENT         0x100
#define TTF_PARSELINKS          0x1000
#define TTF_DI_SETITEM          0x8000

#xcommand SET TOOLTIP [ACTIVATE] <x:ON,OFF> => SetToolTipActivate ( Upper(<(x)>) == "ON" )

// SET TOOLTIP ACTIVATE .. OF Form has no effect if SET TOOLTIP OFF
#xcommand SET TOOLTIP [ACTIVATE] <x:ON,OFF> OF <form> => TTM_Activate( GetFormToolTipHandle (<"form">), Upper(<(x)>) == "ON" )
#xcommand SET TOOLTIP [ACTIVATE] TO <t> OF <form>     => TTM_Activate( GetFormToolTipHandle (<"form">), <t> )

#xcommand SET TOOLTIPSTYLE STANDARD => SetToolTipBalloon ( .F. )
#xcommand SET TOOLTIPSTYLE BALLOON  => SetToolTipBalloon ( .T. )

#xcommand SET TOOLTIPBALLOON  <x:ON,OFF> => SetToolTipBalloon ( Upper(<(x)>) == "ON" )
#xcommand SET TOOLTIP BALLOON <x:ON,OFF> => SetToolTipBalloon ( Upper(<(x)>) == "ON" )

#translate IsToolTipBalloonActive => SetToolTipBalloon ()
#translate IsToolTipActive        => SetToolTipActivate ()

#xcommand ADD TOOLTIPICON <icon> WITH <dummy:MESSAGE,TITLE> <message> <dummy2:TO,OF> <form> ;
   => ; 
   SendMessageString( GetFormToolTipHandle (<"form">), TTM_SETTITLE, <icon>, <message> )

#xcommand ADD TOOLTIPICON <icon:ERROR,ERROR_LARGE,INFO,INFO_LARGE,WARNING,WARNING_LARGE> WITH <dummy:MESSAGE,TITLE> <message> <dummy2:TO,OF> <form> ;
   => ; 
   SendMessageString( GetFormToolTipHandle (<"form">), TTM_SETTITLE, TTI_<icon>, <message> )

#xcommand CLEAR TOOLTIPICON OF <form> ;
   => ;
   SendMessageString( GetFormToolTipHandle (<"form">), TTM_SETTITLE, TTI_NONE, "" )

#xcommand SET TOOLTIP TEXTCOLOR TO <color> OF <form> ;
   => ;
   TTM_SetTipTextColor( GetFormToolTipHandle (<"form">), <color> )

#xcommand SET TOOLTIP BACKCOLOR TO <color> OF <form> ;
   => ;
   TTM_SetTipBKColor( GetFormToolTipHandle (<"form">), <color> )

#xcommand SET TOOLTIP MAXWIDTH TO <w> ;
   => ;
   SetToolTipMaxWidth ( <w> )

#xcommand SET TOOLTIP MAXWIDTH TO <w> OF <form> ;
   => ;
   TTM_SetMaxTipWidth( GetFormToolTipHandle (<"form">), <w> )

#xcommand SET TOOLTIP VISIBLETIME TO <t> OF <form> ;
   => ;
   TTM_SetDelayTime( GetFormToolTipHandle (<"form">), TTDT_AUTOPOP, <t> )
