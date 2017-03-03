ANNOUNCE RDDSYS

#include "hmg.ch"

#define ICON_EXCLAMATION      1  // default value
#define ICON_QUESTION         2
#define ICON_INFORMATION      3
#define ICON_STOP             4
#define ICON_SAVE             5

SET PROCEDURE TO ALERT

PROCEDURE MAIN

   SET WINDOW MAIN OFF

   _alert( _alert( "Test Question;Second Line", {"&Yes","&No","Con&tinue","&Cancel"}, "Please, Select" ), 3, "Information", ICON_INFORMATION )

   _alert( "Test Alert", , "Stop!", ICON_STOP )

   _alert( "Test Alert", , "Alert" )

RETURN
