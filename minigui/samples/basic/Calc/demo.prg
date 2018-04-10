#include "minigui.ch"

Set Proc To Calc.prg

Function Main

        Load Window Demo As Main
        
        ON KEY F2 OF Main ACTION RunCalc()

        Main.Center
        Main.Activate

Return Nil

Function RunCalc()
         Main.Text_1.Value := ShowCalc(Main.Text_1.Value)
         Main.Text_2.Value := System.ClipBoard
Return Nil