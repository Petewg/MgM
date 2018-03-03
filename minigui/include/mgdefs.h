/*
 * Harbour MiniGUI Project source code:
 * The definitions for minigui C-level code.
 *
 * Copyright 2015 Grigory Filatov <gfilatov@inbox.ru>
 * www - http://www.hmgextended.com
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 */

#ifndef MG_SETUP_H_
#define MG_SETUP_H_

#ifndef MGM_VERSION
   #define MGM_VERSION   0x0709  /* 1801 */
#endif

#ifndef WINVER
  #if defined( __WIN98__ )
    #define WINVER   0x0400      /* version 4.0 */
  #else
    #define WINVER   0x0501      /* version 5.0 */
  #endif
#endif /* !WINVER */

#ifndef _WIN32_WINNT
  #define _WIN32_WINNT   WINVER  /* XP = 0x0501 , Vista = 0x0600 */
#endif

#ifndef _WIN32_IE
  #define _WIN32_IE 0x0501
#endif /* !_WIN32_IE */

#include "hbapi.h"

#ifndef NO_LEAN_AND_MEAN
  #define WIN32_LEAN_AND_MEAN
#endif /* !NO_LEAN_AND_MEAN */

#include <windows.h>

#ifndef NO_LEAN_AND_MEAN
  #undef  WIN32_LEAN_AND_MEAN
#endif /* !NO_LEAN_AND_MEAN */

#ifndef HMG_LEGACY_ON
//#define HMG_LEGACY_OFF
#endif

#if defined( _WIN64 )
  #define HB_arraySetNL    hb_arraySetNLL
  #define HB_arrayGetNL    hb_arrayGetNLL
  #define HB_PARNI         hb_parvni
  #define HB_PARNL         hb_parnll
  #define HB_PARVNL        hb_parvnll
  #define HB_RETNL         hb_retnll
  #define HB_STORC         hb_storvc
  #define HB_STORNI        hb_storvni
  #define HB_STORNL        hb_stornll
  #define HB_STORVNL       hb_storvnll
  #define HB_STORL         hb_storvl
#else
  #define HB_arraySetNL    hb_arraySetNL
  #define HB_arrayGetNL    hb_arrayGetNL
  #define HB_PARNL         hb_parnl
  #define HB_RETNL         hb_retnl
  #define HB_STORNL        hb_stornl
#if !( defined( __XHARBOUR__ ) || defined( __XCC__ ) )
  #define HB_PARNI         hb_parvni
  #define HB_PARVNL        hb_parvnl
  #define HB_STORC         hb_storvc
  #define HB_STORNI        hb_storvni
  #define HB_STORVNL       hb_storvnl
  #define HB_STORL         hb_storvl
#else
  #define HB_PARNI         hb_parni
  #define HB_PARVNL        hb_parnl
  #define HB_STORC         hb_storc
  #define HB_STORNI        hb_storni
  #define HB_STORVNL       hb_stornl
  #define HB_STORL         hb_storl
#endif /* !( __XHARBOUR__ || __XCC__ ) */
#endif /* _WIN64 */

/* Harbour macro\functions mapped to xHarbour ones */
#ifdef __XHARBOUR__
#include "hbverbld.h"

#if defined( HB_VER_CVSID ) && ( HB_VER_CVSID < 9639 )
  #define HB_ISCHAR        ISCHAR
  #define HB_ISNUM         ISNUM
  #define HB_ISBYREF       ISBYREF
#endif

#if defined( HB_VER_CVSID ) && ( HB_VER_CVSID < 9798 )
  #define HB_ISNIL         ISNIL
#endif

#if defined( HB_VER_CVSID ) && ( HB_VER_CVSID < 9820 )
  #define HB_ISLOG         ISLOG
  #define HB_ISARRAY       ISARRAY
#endif

#define HB_ISDATE          ISDATE

#define hb_parldef( l1, l2 )        ( ISLOG( l1 ) ? hb_parl( l1 )    : l2 )
#define hb_parnidef( n1, n2 )       ( ISNUM( n1 ) ? hb_parni( n1 )   : n2 )
#define hb_parnldef( n1, n2 )       ( ISNUM( n1 ) ? hb_parnl( n1 )   : n2 )
#define hb_parnintdef( n1, n2 )     ( ISNUM( n1 ) ? hb_parnint( n1 ) : n2 )
#endif /* __XHARBOUR__ */

#define _isValidCtrlClass  _isValidCtrlClassA

#endif /* MG_SETUP_H_ */
