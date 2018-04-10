/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Program : Test04.prg
 * Purpose : Test Customer class
 * Notes   : This shows how to build add, edit, delete and browse right
             into the customer object. The browse assumes it will be in a
             MDI child window.

             You can open a customer browse just by attaching the following
             to a button:

                TCustomer():new():browse()

             Add, edit, delete, and browse are all user interface methods.
*/

#include "minigui.ch"
#include "hbclass.ch"


//--- For testing only
function main()
   local oDB

   field custno, company

   oDB:=tdata():new(,"cust",,.f.)
   if oDB:use()
      oDB:createIndex("cust",,"custno",,,.f.)
      oDB:createIndex("cust2",,"company",,,.f.)
      oDB:goTop()
      while oDB:recNo() <= oDB:lastRec()
         oDB:recall()
         oDB:skip()
      end
   endif
   oDB:close()

   set epoch to 1980
   set deleted on

   SET FONT TO _GetSysFont(), 12

   DEFINE WINDOW Form_1 ;
      CLIENTAREA 640, 480 ;
      TITLE 'Test TCustomer class' ;
      MAIN ;
      MDI

      DEFINE IMAGELIST ImageList_1 ;
         OF Form_1 ;
         BUTTONSIZE 24, 24 ;
         IMAGE { 'tb_24.bmp' } ;
         IMAGECOUNT 19

      DEFINE SPLITBOX 

         DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 32,32 IMAGELIST 'ImageList_1' FLAT 

		BUTTON Btn_Open ;
		        PICTUREINDEX 0 ;
			TOOLTIP 'Browse customer' ;
			ACTION TCustomer():new():browse()

		BUTTON Btn_Exit ;
		        PICTUREINDEX 5 ;
			TOOLTIP 'Exit' ;
			ACTION ReleaseAllWindows()
         END TOOLBAR

      END SPLITBOX

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1 

return nil
//--- End test




//--- Customer class
class TCustomer from TData
   method new
   method browse
   method add
   method edit
   message delete method _delete
 Hidden:
   data lAdd as logical
endclass


method new()
   ::super:new(,"cust")
   if ::use()
      ::SetArea( Select() )
      ::addIndex("cust")
      ::addIndex("cust2")
      ::setOrder(1)
      ::gotop()
   endif
   ::lAdd:=.f.
return self


method browse()
   Local a_fields, a_width, a_headers, i

   ::setOrder(2)
   ::gotop()

   a_fields := {}
   a_width := {}
   for i:=1 to ::FCount()
      aadd( a_fields, ::FieldName( i ) )
      aadd( a_width, iif(::FieldType( i ) == 'C', 205, 100) )
   next
   a_headers := a_fields

   Form_1.Btn_Open.Enabled := .f.

   set browsesync on

   DEFINE WINDOW ChildMdi ;
	TITLE "Customer" ;
	MDICHILD ;
	ON INIT ResizeEdit() ; 
	ON RELEASE ::end() ;
	ON SIZE ResizeEdit();
	ON MAXIMIZE ResizeEdit();
	ON MINIMIZE ResizeEdit()

      WinChildMaximize()

      DEFINE IMAGELIST ImageList_1 ;
         BUTTONSIZE 24, 24 ;
         IMAGE { 'tb_24.bmp' } ;
         IMAGECOUNT 19

      DEFINE SPLITBOX

         DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 28,28 IMAGELIST 'ImageList_1' FLAT

		BUTTON Btn_New ;
		        PICTUREINDEX 0 ;
			TOOLTIP 'Add' ;
			ACTION (::add(),SetEditFocus(::RecNo()))

		BUTTON Btn_New ;
		        PICTUREINDEX 17 ;
			TOOLTIP 'Edit' ;
			ACTION (::edit(),SetEditFocus(::RecNo()))

		BUTTON Btn_Delete ;
			PICTUREINDEX 5 ;
			TOOLTIP 'Delete' ;
			ACTION (::delete(),::skip(-1),iif(::Bof(),,::skip()),SetEditFocus(::RecNo()))

         END TOOLBAR

      END SPLITBOX

      @ 40,0 BROWSE BrwMdi ;
         WIDTH 200 ;
         HEIGHT 200 ;
         HEADERS a_headers ;
         WIDTHS a_width ;
         FIELDS a_fields ;
         WORKAREA &(::cAlias) ;
         ON DBLCLICK (::edit(),SetEditFocus(::RecNo()))

   END WINDOW

return self


method add()
   ::lAdd:=.t.
   ::blank()  // start with a blank record
   ::edit()
   ::load()   // in case they cancel
   ::lAdd:=.f.
return self


method edit()
   Local mNumLine:= 0
   iif( ::lAdd, ,::load())
   DEFINE WINDOW Edit AT 0,0 WIDTH 360 HEIGHT 240;
       TITLE iif(::lAdd,"Untitled",::company);
       MODAL;
       FONT 'Tahoma' SIZE 9

   @ mNumLine+=  15,  10 LABEL    LABEL_1    VALUE 'Custno'  WIDTH 80  HEIGHT 20  RIGHTALIGN  
   @ mNumLine+=   0, 100 TEXTBOX   TEXTBOX_1 VALUE ::aBuffer[ 1 ]  WIDTH 100  HEIGHT 20  ON LOSTFOCUS ::aBuffer[ 1 ]:=Edit.TEXTBOX_1.VALUE
   @ mNumLine+=  25,  10 LABEL    LABEL_2    VALUE 'Company'  WIDTH 80  HEIGHT 20  RIGHTALIGN  
   @ mNumLine+=   0, 100 TEXTBOX   TEXTBOX_2 VALUE ::aBuffer[ 2 ]  WIDTH 200  HEIGHT 20  ON LOSTFOCUS ::aBuffer[ 2 ]:=Edit.TEXTBOX_2.VALUE
   @ mNumLine+=  25,  10 LABEL    LABEL_3    VALUE 'Address1'  WIDTH 80  HEIGHT 20  RIGHTALIGN  
   @ mNumLine+=   0, 100 TEXTBOX   TEXTBOX_3 VALUE ::aBuffer[ 3 ]  WIDTH 200  HEIGHT 20  ON LOSTFOCUS ::aBuffer[ 3 ]:=Edit.TEXTBOX_3.VALUE
   @ mNumLine+=  25,  10 LABEL    LABEL_4    VALUE 'City'  WIDTH 80  HEIGHT 20  RIGHTALIGN  
   @ mNumLine+=   0, 100 TEXTBOX   TEXTBOX_4 VALUE ::aBuffer[ 4 ]  WIDTH 160  HEIGHT 20  ON LOSTFOCUS ::aBuffer[ 4 ]:=Edit.TEXTBOX_4.VALUE
   @ mNumLine+=  25,  10 LABEL    LABEL_5    VALUE 'State'  WIDTH 80  HEIGHT 20  RIGHTALIGN  
   @ mNumLine+=   0, 100 TEXTBOX   TEXTBOX_5 VALUE ::aBuffer[ 5 ]  WIDTH 60  HEIGHT 20   ON LOSTFOCUS ::aBuffer[ 5 ]:=Edit.TEXTBOX_5.VALUE
   @ mNumLine+=  25,  10 LABEL    LABEL_6    VALUE 'Zip'  WIDTH 80  HEIGHT 20  RIGHTALIGN  
   @ mNumLine+=   0, 100 TEXTBOX   TEXTBOX_6 VALUE ::aBuffer[ 6 ]  WIDTH 120  HEIGHT 20  ON LOSTFOCUS ::aBuffer[ 6 ]:=Edit.TEXTBOX_6.VALUE
   @ mNumLine+=  30, 170 BUTTONEX BUTTONEX_1 CAPTION 'OK'  WIDTH 80  HEIGHT 24  ACTION ( iif( ::lAdd, ::append(), ), ::save(), ThisWindow.Release() )
   @ mNumLine+=   0, 250 BUTTONEX BUTTONEX_2 CAPTION 'Cancel'  WIDTH 80  HEIGHT 24  ACTION ThisWindow.Release()

   END WINDOW
   Edit.Center()
   Edit.Activate()
return self


method _delete()
   if msgYesNo("Delete this record?","Confirmation")
      ::super:delete()
   endif
return self


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
        h := actpos[4]-actpos[2]-40
        _SetControlHeight( "BrwMdi", ChildName, h)
        _SetControlWidth( "BrwMdi", ChildName, w)
    endif

Return


Procedure SetEditFocus(value)
    Local ChildHandle, ChildName
    Local i

    ChildHandle := GetActiveMdiHandle() 
    i := aScan ( _HMG_aFormHandles , ChildHandle )
    if i > 0  
        ChildName := _HMG_aFormNames [i]
        _SetValue ( "BrwMdi", ChildName, value )
        _SetFocus ( "BrwMdi", ChildName )
        DoMethod ( ChildName, "BrwMdi", "Refresh" )
    endif

Return
