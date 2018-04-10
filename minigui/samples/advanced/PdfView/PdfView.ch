//hotkeys
#include "i_keybd.ch"

//D
#xcommand ON KEY CONTROL+SHIFT+D [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_D , <{action}> )

#xcommand RELEASE KEY CONTROL+SHIFT+D OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_D )

//F
#xcommand ON KEY CONTROL+SHIFT+F [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F , <{action}> )

#xcommand RELEASE KEY CONTROL+SHIFT+F OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_F )

//R
#xcommand ON KEY CONTROL+SHIFT+R [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_R , <{action}> )

#xcommand RELEASE KEY CONTROL+SHIFT+R OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_R )

//TAB
#xcommand ON KEY CONTROL+SHIFT+TAB [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_TAB , <{action}> )
#xcommand RELEASE KEY CONTROL+SHIFT+TAB OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_TAB )

//PLUS
#xcommand ON KEY CONTROL+PLUS [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL , VK_OEM_PLUS , <{action}> )
#xcommand RELEASE KEY CONTROL+PLUS OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_OEM_PLUS )

#xcommand ON KEY CONTROL+SHIFT+PLUS [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_OEM_PLUS , <{action}> )
#xcommand RELEASE KEY CONTROL+SHIFT+PLUS OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_OEM_PLUS )

//MINUS
#xcommand ON KEY CONTROL+MINUS [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL , VK_OEM_MINUS , <{action}> )
#xcommand RELEASE KEY CONTROL+MINUS OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL , VK_OEM_MINUS )

#xcommand ON KEY CONTROL+SHIFT+MINUS [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_OEM_MINUS , <{action}> )
#xcommand RELEASE KEY CONTROL+SHIFT+MINUS OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_OEM_MINUS )

//ADD (Num+)
#xcommand ON KEY CONTROL+SHIFT+ADD [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_ADD , <{action}> )
#xcommand RELEASE KEY CONTROL+SHIFT+ADD OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_ADD )

//SUBTRACT (Num-)
#xcommand ON KEY CONTROL+SHIFT+SUBTRACT [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_SUBTRACT , <{action}> )
#xcommand RELEASE KEY CONTROL+SHIFT+SUBTRACT OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_SUBTRACT )

//MULTIPLY (Num*)
#xcommand ON KEY CONTROL+SHIFT+MULTIPLY [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_MULTIPLY , <{action}> )
#xcommand RELEASE KEY CONTROL+SHIFT+MULTIPLY OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_MULTIPLY )

//DIVIDE (Num/)
#xcommand ON KEY CONTROL+SHIFT+DIVIDE [ OF <parent> ] ACTION <action> ;
=> ;
_DefineHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DIVIDE , <{action}> )
#xcommand RELEASE KEY CONTROL+SHIFT+DIVIDE OF <parent> ;
=> ;
_ReleaseHotKey ( <"parent"> , MOD_CONTROL + MOD_SHIFT , VK_DIVIDE )
