/*
* MiniGUI ControlS Context Menu Extension
* by Adam Lubszczyk
* mailto:adam_l@poczta.onet.pl
*/

#include "minigui.ch"

Procedure Main

      Load Window demo
      Activate Window demo

Return

FUNCTION SetTabContex( nValue )
IF nValue == 1
 SET CONTEXT MENU OFF
 msgInfo( "Global context menu is now OFF !" + hb_EOL() + ;
          "Click on page 2 to set it ON.." )
ELSE
	SET CONTEXT MENU ON
	msgInfo( "Global context menu is now ON" )
ENDIF
RETURN NIL
