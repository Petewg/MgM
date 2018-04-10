/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Program : Test01.prg
 * Purpose : TData class test showing multiple browses of same data file
 *           in MDI-child windows.
 * Note    : Each press of the button will open a new browse of the same file.
*/

#include "minigui.ch"

Static nChild := 0


function Main()

   SET FONT TO "Arial", 10

   DEFINE WINDOW Form_1 ;
      CLIENTAREA 640, 480 ;
      TITLE 'Browse MDI demo' ;
      MAIN ;
      MDI

      DEFINE MAIN MENU

	POPUP 'File'
		ITEM 'Open'		ACTION Customer()
		ITEM 'Close'		ACTION CloseMdi() 
		SEPARATOR
		ITEM 'Exit'		ACTION Form_1.Release
	END POPUP

	POPUP 'Child Windows'
		POPUP '&Tiled' 		    
		    ITEM '&Horizontal '	ACTION WinChildTile(.f.)
		    ITEM '&Vertical '	ACTION WinChildTile(.t.)
		END POPUP
		ITEM '&Cascade'		ACTION WinChildCascade()
		ITEM 'Arrange &Icons' 	ACTION WinChildIcons()
		SEPARATOR
		ITEM 'Close &All'	ACTION WinChildCloseAll()
		ITEM '&Restore All'	ACTION WinChildRestoreAll()
	END POPUP

      END MENU

      DEFINE IMAGELIST ImageList_1 ;
         BUTTONSIZE 24, 24 ;
         IMAGE { 'tb_24.bmp' } ;
         IMAGECOUNT 19

      DEFINE SPLITBOX 

         DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 28,28 IMAGELIST 'ImageList_1' FLAT 

		BUTTON Btn_Open ;
		        PICTUREINDEX 0 ;
			TOOLTIP 'Browse customer' ;
			ACTION Customer()

		BUTTON Btn_Close ;
			PICTUREINDEX 5 ;
			TOOLTIP 'Close Active Child Window' ;
			ACTION CloseMdi()

         END TOOLBAR

      END SPLITBOX

      Form_1.Btn_Close.Enabled := .f.

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1 

return nil


Procedure CloseMdi()

    CLOSE ACTIVE MDICHILD
    Form_1.Btn_Close.Enabled := nChild > 0

Return


// You can call this as many times as you want
// and you'll get a new browse window each time.
function Customer()

   Local a_fields, a_width, a_headers, i

   local oCust := tdata():new(,"cust")

   if oCust:use()

      if ! file("cust2.ntx")
         oCust:createIndex("cust2",,"upper(company)")
         oCust:closeIndex()
      endif
      oCust:addIndex( "cust2" )
      oCust:goTop()

      a_fields := {}
      for i:=1 to oCust:lastRec()
         aadd( a_fields, { oCust:company, oCust:address1, oCust:city } )
         oCust:skip()
      next
      a_headers := { "Customer", "Address", "City" }
      a_width := { 200, 250, 120 }

      nChild++

      DEFINE WINDOW ChildMdi ;
	TITLE "Child " + hb_ntos(nChild) + ": " + oCust:cAlias ;
	MDICHILD ;
	ON INIT ( ResizeEdit() ) ; 
	ON RELEASE ( oCust:close(), ReleaseMdiChild() ) ;
	ON SIZE ResizeEdit();
	ON MAXIMIZE ResizeEdit();
	ON MINIMIZE ResizeEdit();
	ON MOUSECLICK SetEditFocus()

	@ 0,0 GRID BrwMdi								;
		WIDTH 200  										;
		HEIGHT 200										;	
		HEADERS a_headers ;
		WIDTHS a_width ;
		ITEMS a_fields

      END WINDOW
 
      Form_1.Btn_Close.Enabled := .t.

   endif

return nil


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
        _SetControlHeight( "BrwMdi", ChildName, h)
        _SetControlWidth( "BrwMdi", ChildName, w)
    endif

Return


Procedure SetEditFocus()
    Local ChildHandle, ChildName
    Local i

    ChildHandle := GetActiveMdiHandle() 
    i := aScan ( _HMG_aFormHandles , ChildHandle )
    if i > 0  
        ChildName := _HMG_aFormNames [i]
        _SetFocus ( "BrwMdi", ChildName )
        DoMethod ( ChildName, "BrwMdi", "Refresh" )
    endif

Return


Procedure ReleaseMdiChild()
    nChild--
    Form_1.Btn_Close.Enabled := nChild > 0
Return


Procedure ResizeAllChildEdit()
    Local nfrm, ChildName, n

    nFrm := len(_HMG_aFormHandles)
    For n:=1 to nFrm
        if _HMG_aFormType [n] == 'Y' 
            ChildName := _HMG_aFormNames [n]
            ResizeChildEdit(ChildName) 
        endif
    Next

Return


Procedure WinChildTile( lVert )
    if lVert
        TILE MDICHILDS VERTICAL
    else
        TILE MDICHILDS HORIZONTAL
    endif
    ResizeAllChildEdit()
Return


Procedure WinChildCascade()
    CASCADE MDICHILDS
    ResizeAllChildEdit()
Return


Procedure WinChildIcons()
    ARRANGE MDICHILD ICONS
Return


Procedure WinChildCloseAll()
    CLOSE MDICHILDS ALL
Return


Procedure WinChildRestoreAll()
    RESTORE MDICHILDS ALL
Return
