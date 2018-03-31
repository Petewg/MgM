/*****************************
* Source : makeprg.prg
* System : Tools/MakePrg
* Author : Phil Ide
* Created: 13/05/2004
*
* Purpose:
* ----------------------------
* History:
* ----------------------------
*    13/05/2004 19:38 PPI - Created
*
* Last Revision:
*    $Rev: 18 $
*    $Date: 2004-05-14 16:05:52 +0100 (Fri, 14 May 2004) $
*    $Author: idep $
*    
*****************************/

#include "Common.ch"

Set Procedure To configClass
Set Procedure To configCfgClass

ANNOUNCE RDDSYS

Procedure main( cFile, cMsg, cMode )
   local oCfg

   if PCount() == 0 .or. left(lower(cFile),2) $ '/?:-?:/h:-h'
      help()
   else
      oCfg := Config():new()
      oCfg:write(cFile, cMode, cMsg)
   endif
   return

Procedure Help()
   ? '   <file> <purpose> [/c|/g]'
   ? '   /c = console mode'
   ? '   /g = graphics mode'
   ? '   (default from config file)'
   ?
   return


