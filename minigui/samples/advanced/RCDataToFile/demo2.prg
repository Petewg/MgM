/*
 * Author: P.Chornyj <myorg63@mail.ru>
 */

ANNOUNCE RDDSYS

#ifndef __XHARBOUR__
#require "hbmemio"
REQUEST HB_MEMIO
#endif
///////////////////////////////////////////////////////////////////////////////
procedure main()

   local cMemFile  := "mem:image1"
   local cDiskFile := "image1.png"
   local nResult, aXY, x, y, cMsg

   delete file cDiskFile
#ifndef __XHARBOUR__
   nResult := RCDataToFile( "IMAGE1", cMemFile, "PNG" )
#else
   nResult := RCDataToFile( "IMAGE1", cDiskFile, "PNG" )
#endif

   if nResult > 0
#ifndef __XHARBOUR__
      /* Now we can do something, f.e save to disk file */
      hb_vfCopyFile( cMemFile, cDiskFile ) 
#endif

      if hb_FileExists( cDiskFile )
         aXY  := hb_GetImageSize( cDiskFile )

         cMsg := ( "IMAGE1 saved successfully as" + Chr(13) + Chr(10) )
         cMsg += ( cDiskFile + ": " + hb_NtoS( aXY[1] ) + " x " + hb_NtoS( aXY[2] ) + " Pixels" )

         MsgInfo( cMsg, "Congratulations!" )
      endif
   else
      MsgInfo( "Code: " + hb_NtoS( nResult ), "Error" )
   endif

#ifndef __XHARBOUR__
   hb_vfErase( cMemFile )
#endif

return
