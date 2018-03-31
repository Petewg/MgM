/*
 * Author: P.Chornyj <myorg63@mail.ru>
 */

ANNOUNCE RDDSYS

#ifdef __XHARBOUR__
   #include "hbcompat.ch"
#endif

#define IDR_HELLO 1001 
///////////////////////////////////////////////////////////////////////////////
procedure main()

   local cDiskFile := hb_dirTemp() + "\" + "he$$o.tmp"
   local nResult, hProcess, nRet

   delete file cDiskFile

   nResult := RCDataToFile( IDR_HELLO, cDiskFile )

   if nResult > 0
      hProcess := hb_processOpen( cDiskFile )
      nRet := hb_processValue( hProcess, .T. )

      MsgInfo( "Exit Code: " + hb_NtoS( nRet ), "he$$o.tmp" )
   else
      MsgInfo( "Code: " + hb_NtoS( nResult ), "Error" )
   endif

return
