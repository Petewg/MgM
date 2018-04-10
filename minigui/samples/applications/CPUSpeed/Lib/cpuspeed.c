#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

double CPUSpeed(void)
{ 
   DWORD dwTimerHi, dwTimerLo; 
   INT   PriorityClass, Priority; 

   PriorityClass = GetPriorityClass(GetCurrentProcess()); 
   Priority = GetThreadPriority(GetCurrentThread());  
   SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS); 
   SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL); 
   Sleep(10); 
   asm
   {
        DW 0x310F 
        mov dwTimerLo, EAX 
        mov dwTimerHi, EDX 
   } 
   Sleep (500); 
   asm
   { 
        DW 0x310F 
        sub EAX, dwTimerLo 
        sub EDX, dwTimerHi 
        mov dwTimerLo, EAX 
        mov dwTimerHi, EDX 
   } 
   SetThreadPriority(GetCurrentThread(), Priority); 
   SetPriorityClass(GetCurrentProcess(), PriorityClass); 
   return dwTimerLo/(1000.0*499.8);
}

HB_FUNC( GETCPUSPEED )
{
   hb_retnl( CPUSpeed() );
}
