/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Program : Test02.prg
 * Purpose : A MDI Browse with fields from a related file
 * Notes   : I expect the seek() method is faster since you are only
 *           keeping one record in synch.
*/

// An example relation in Clipper
/*
use arcust new
index on custno to temp
use invmast new
set relation to custno into arcust

list invmast->invno,invmast->custno,arcust->custno,arcust->company

*/


#include "minigui.ch"


function main()

   DEFINE WINDOW Form_1 ;
      CLIENTAREA 640, 480 ;
      TITLE 'MDI demo' ;
      MAIN ;
      MDI ;
      NOMAXIMIZE NOSIZE ;
      ON INIT InvMDI()

   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1 

return nil


//--- Invoice browse
function InvMDI()
   Local a_fields, a_width, a_headers, i
   local oCust, oInvoice

   oCust := tdata():new(,"cust")
   oCust:use()
   oCust:createIndex("cust",,"custno")
   oInvoice := tdata():new(,"invmast")
   oInvoice:use()

   a_fields := {}
   for i:=1 to oInvoice:lastRec()
      aadd( a_fields, { oInvoice:invno, oInvoice:custno, (oCust:seek(oInvoice:custno), oCust:custno), oCust:company } )
      oInvoice:skip()
   next
   a_headers := { "Invoice", "CustNo", "CustNo", "Company" }
   a_width := { 100, 100, 100, 300 }

   DEFINE WINDOW ChildMdi ;
	TITLE "Invoice browse" ;
	MDICHILD ;
	ON INIT ( WinChildMaximize(), ResizeEdit() ) ; 
	ON RELEASE ( oInvoice:end(),oCust:end() )

	@ 0,0 GRID BrwInv								;
		WIDTH 200  										;
		HEIGHT 200										;	
		HEADERS a_headers ;
		WIDTHS a_width ;
		ITEMS a_fields

   END WINDOW

return nil


#define WM_MDIMAXIMIZE 0x0225

Function WinChildMaximize()
Local ChildHandle

ChildHandle := GetActiveMdiHandle()
if aScan ( _HMG_aFormHandles , ChildHandle ) > 0
   SendMessage( _HMG_MainClientMDIHandle, WM_MDIMAXIMIZE, ChildHandle, 0 )
endif

Return Nil


Procedure ResizeEdit() 
    Local ChildHandle, ChildName
    Local i

    ChildHandle := GetActiveMdiHandle() 
    i := aScan ( _HMG_aFormHandles , ChildHandle )
    if i > 0  
        ChildName := _HMG_aFormNames [i]
        ResizeChildEdit(ChildName)
    endif

Return


Procedure ResizeChildEdit(ChildName) 
    Local hwndCln, actpos := {0,0,0,0}
    Local i, w, h 

    i := aScan ( _HMG_aFormNames , ChildName )
    if i > 0  
        hwndCln := _HMG_aFormHandles  [i]
        GetClientRect(hwndCln, actpos)
        w := actpos[3]-actpos[1]
        h := actpos[4]-actpos[2]
        _SetControlHeight( "BrwInv", ChildName, h)
        _SetControlWidth( "BrwInv", ChildName, w)
    endif

Return
