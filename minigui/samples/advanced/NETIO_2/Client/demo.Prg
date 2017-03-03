#include <minigui.ch>

Procedure Main

        Load Window DEMO As Main
        Main.Center
        Main.Activate

Return

Function _Connect()
     Local c_STR_Con := "net:"
     Local a_IP := Main.Text_1.Value
     Local c_IP := str(a_IP[1], 3) + "." + hb_ntos(a_IP[2]) + "." + hb_ntos(a_IP[3]) + "." + hb_ntos(a_IP[4])

     c_STR_Con += lTrim(c_IP) + ":" + AllTrim(Main.Text_3.Value) + ":" + AllTrim(Main.Text_2.Value)

     if NETIO_CONNECT( c_IP, AllTrim(Main.Text_3.Value) )
	DbUseArea( , , c_STR_Con, "Test" )
        INDEX ON field->CODE TO code
	EDIT EXTENDED
	CLOSE
	Ferase('code.ntx')
     endif

Return Nil
