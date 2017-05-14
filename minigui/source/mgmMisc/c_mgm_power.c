/*
 * mgm_power C-functions
 * Copyright 2016-2017 Pete D.
 *
 * LockDesktop() -> lSuccess
 * SuspendMonitor( [<nSeconds>] ) -> lSuccess
 * SuspendSystem( [<lHibernate>] ) -> lSuccess
 *
 * NOTE: requires PowrProf.lib (included in MinGW) to be linked! 
 *       add -lpowerprof into your build script.
 */

#include <mgdefs.h>

#include "hbwin.h"
#include "hbwapi.h"
#include "hbapiitm.h"

/* 
 * LockDesktop() -> lSuccess
 * This function has the same result as pressing Ctrl+Alt+Del 
 * and clicking Lock Workstation. To unlock the workstation, the user must log in. 
 * Copyright 2017 Pete D. <pete_westg / at / yahoo.gr>
 */
HB_FUNC( MGM_LOCKDESKTOP )
{
   int i = LockWorkStation();
    hb_retl( i > 0 );
}

/* 
 * SuspendMonitor( [<nSeconds>] ) -> lSuccess
 * Turns off monitor for <nSeconds>, 
 * or until a mouse movement or key-press, if no <nSeconds> specified.
 * Copyright 2017 Pete D. <pete_westg / at / yahoo.gr> 
*/
HB_FUNC( MGM_SUSPENDMONITOR )
{
   int nsecs = hb_parnldef( 1, 0 );
   BOOL lResult = SendNotifyMessage( HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, 2 );
   
   if( nsecs > 0 )
   {
      INPUT input = { INPUT_MOUSE };
      input.mi.dwFlags = MOUSEEVENTF_MOVE;
      
      Sleep( nsecs * 1000 );
      SendInput(1, &input, sizeof(INPUT));
      // SendNotifyMessage( HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, -1 );
   }

   hb_retl( lResult );
}

/* 
 * mgm_SuspendSystem( [<lHibernate>] ) -> lSuccess
 * Suspends the system by shutting power down. 
 * Depending on the optional lHibernate parameter, the system 
 * either enters a suspend (sleep) state or hibernation (S4). 
 * https://msdn.microsoft.com/en-us/library/windows/desktop/aa373201(v=vs.85).aspx
 * Copyright 2017 Pete D. <pete_westg / at / yahoo.gr>
 */
#include "powrprof.h"
HB_FUNC( MGM_SUSPENDSYSTEM )
{
   HB_BOOL lHibernate = hb_parl( 1 );
   
   if( lHibernate )
   {
      SYSTEM_POWER_CAPABILITIES spc;
      if( GetPwrCapabilities( &spc ) )
         lHibernate = (lHibernate && spc.SystemS4);
      else
         lHibernate = FALSE;
   }

   hb_retl( SetSuspendState( lHibernate, FALSE,  FALSE ) );
}
