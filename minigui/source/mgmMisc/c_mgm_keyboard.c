#include <windows.h>
#include <shlobj.h>

#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"

#include "hbwapi.h"


HB_FUNC( MGM_KEYBRDSELECT )
/*
usage: nHandler := mgm_KeybrdSelect( <cLanguage_identifier> )
      <cLanguage_identifier> format: "0000" + Language Identifier Constant 
      (e.g.: "00000409" for US-english, "0000080c" for French, 
             "00000408" for Greek,      "00000419" for Russian et.c.)
      for Language Identifier Constants see: 
      https://msdn.microsoft.com/en-us/library/windows/desktop/dd318693%28v=vs.85%29.aspx
      NOTE: to work correctly in Harbour .prg level, a valid codepage, for the selected
            keyboard, must be loaded using REQUEST HB_CODEPAGE_XXXX and  hb_CdpSelect("XXXX")
      RETURNS: a Handler to keyboard layout, which can be used to unload this layout
               using the relevant win_KeybrdUnload( handler ) function.
*/
{
   HKL keyboard_Layout_Handler ;
   
   const char * keybID = hb_parc( 1 );
   
   keyboard_Layout_Handler = LoadKeyboardLayout( keybID ,
                                                 KLF_ACTIVATE + KLF_REORDER  /*KLF_SUBSTITUTE_OK*/ 
                                               );
   hb_retnl( (long) keyboard_Layout_Handler ) ;
}

HB_FUNC( MGM_KEYBRDUNLOAD )
{
   HKL keyboard_Layout_Handler = (HKL) hb_parnl( 1 );
   UnloadKeyboardLayout( keyboard_Layout_Handler );
}

HB_FUNC( MGM_GETKEYBOARDLAYOUTNAME )
{
   LPTSTR LayoutName = (char *) hb_xgrab( KL_NAMELENGTH + 1 ); // [ KL_NAMELENGTH ]="";
   if ( GetKeyboardLayoutName( LayoutName ) )
      hb_retc( (char*) LayoutName );
   
   hb_xfree( LayoutName );

}

HB_FUNC( MGM_GETDEFAULTUILANGUAGE )
{ 
   hb_retni( GetSystemDefaultUILanguage() );
}