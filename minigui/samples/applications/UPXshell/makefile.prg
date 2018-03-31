#include "fileio.ch"

*--------------------------------------------------------*
PROCEDURE MkFile( cUpx )
*--------------------------------------------------------*

   IF ! hb_vfExists( cUpx )
      hb_MemoWrit( cUpx, UpxExe() )
      // give OS a little time to "see" the newly created file
      hb_IdleSleep( 0.5 ) 
      // hide the file from user's sight to protect it from "accidents"
      //hb_vfAttrSet( cUpx,  HB_FA_HIDDEN + HB_FA_READONLY + HB_FA_SYSTEM )
   ENDIF

RETURN

*--------------------------------------------------------*
STATIC FUNCTION UpxExe()
*--------------------------------------------------------*
#pragma __binarystreaminclude "UPX.EXE" | RETURN %s
