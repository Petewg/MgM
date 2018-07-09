#include "Minigui.ch"

FUNCTION Func1( xValue )
   Msginfo( "Func1 ", xValue )
RETURN xValue

FUNCTION Func2( ... )
   Msgdebug( "Func2 parameter List->", {...} )
RETURN NIL

FUNCTION Func3()
   MsgInfo( "Now i change the Statusbar")
   SetProperty ( 'Win_Main', 'StatusBar' , 'Item' , 1 , '  HMG Power Ready Changed.' )
RETURN time()
