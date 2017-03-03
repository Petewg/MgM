/*
* MiniGUI ControlPos demo
* by Adam Lubszczyk
* mailto:adam_l@poczta.onet.pl
*/

#include "minigui.ch"

set procedure to "_controlpos3_.prg"

MEMVAR _ControlPosFirst_
MEMVAR _ControlPosProperty_
MEMVAR _ControlPosSizeRect_
MEMVAR _ControlPos_Save_Option_

Function Main

        Load Window test
        Load Window dialog AS form_2

	controlposSTART()

        Activate Window test,form_2

Return nil
