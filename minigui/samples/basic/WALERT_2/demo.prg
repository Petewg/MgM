/*
 * HMG_Alert() Demo
 *
 * Direct replacement for Clipper Alert() function
 *
 * Copyright (c) Francisco Garcia Fernandez
 *
 * Modified by Grigory Filatov at 18-02-2018
 */

#include "hmg.ch"

ANNOUNCE RDDSYS

PROCEDURE MAIN

   SET WINDOW MAIN OFF

   HMG_Alert( ;
      HMG_Alert( "Test Question;Second Line", {"&Yes","&No","Con&tinue","&Cancel"}, "Please, Select" ), ;
      3 /* timeout in the seconds */, "Information", ICON_INFORMATION )

   HMG_Alert( "MessageBox Stop", NIL, "Stop!", ICON_STOP )

   HMG_Alert( "MessageBox Alert", NIL, "Alert" )

RETURN
