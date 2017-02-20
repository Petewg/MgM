/*
 * MiniGUI CALLDLL library Demo
*/

#include "hmg.ch"
#include "hbdyn.ch"

//   HMG_CallDLL( cLibName, [ nRetType ] , cFuncName [, Arg1, ..., ArgN ] ) ---> xRetValue

FUNCTION MAIN
LOCAL cBuffer, nFlags

   cBuffer := SPACE (256 * 2)
   MsgDebug (HMG_CallDLL ("shell32.dll", HB_DYN_CTYPE_INT, "SHGetSpecialFolderPath", 0, @cBuffer, CSIDL_APPDATA, 0), cBuffer)

   cBuffer := GetCurrentFolder()
   MsgDebug (cBuffer, HMG_CallDLL ("shell32.dll", HB_DYN_CTYPE_VOID, "PathGetShortPath", @cBuffer), cBuffer)

   nFlags := 0
   MsgDebug (nFlags, HMG_CallDLL ("WININET.DLL", HB_DYN_CTYPE_BOOL, "InternetGetConnectedState", @nFlags, 0), nFlags)


   DEFINE WINDOW Win_1 ;
      AT 0,0 ;
      WIDTH 800 ;
      HEIGHT 500 ;
      TITLE 'HMG_CallDLL Demo' ;
      MAIN ;
      ON RELEASE UnloadAllDll()

      ON KEY F3 ACTION (cBuffer := SPACE (256 * 2), MsgDebug (HMG_CallDLL ("USER32.DLL", HB_DYN_CTYPE_INT, "GetWindowModuleFileName", GetFormHANDLE("Win_1"), @cBuffer, 256), cBuffer))

      ON KEY F5 ACTION (cBuffer := SPACE (256 * 2), MsgDebug (HMG_CallDLL ("USER32.DLL", HB_DYN_CTYPE_INT, "GetWindowText", GetFormHANDLE("Win_1"), @cBuffer, 256), cBuffer))

      ON KEY F7 ACTION MsgDebug (HMG_CallDLL ("USER32.DLL", HB_DYN_CTYPE_BOOL, "SetWindowText", GetFormHANDLE("Win_1"), "New title"))

   END WINDOW

   CENTER WINDOW Win_1

   ACTIVATE WINDOW Win_1

RETURN NIL
