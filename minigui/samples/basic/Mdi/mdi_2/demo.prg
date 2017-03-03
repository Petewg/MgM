/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/

 * Windows Browse MDI demo & tests by Janusz Pora
 * (C)2005 Janusz Pora <januszpora@onet.eu>
 * HMG 1.0 Experimental Build 12
*/

#include "minigui.ch"

#define CLR_DEFAULT	0xff000000

Static nWidth
Static nHeight

Memvar lModif
Memvar nChild
Memvar nAlias

Function Main

    REQUEST DBFCDX

    SET CENTURY ON
    SET DELETED ON

    SET BROWSESYNC ON
	
    Public lModif := .f.
    Public nChild := 0
    Public nAlias := 0

    nWidth  := GetDesktopWidth() * 0.78125
    nHeight := GetDesktopHeight() * 0.78125 

    Set InteractiveClose Query Main

        DEFINE WINDOW Form_1 ;
                AT 0,0 ;
                WIDTH nWidth ;
                HEIGHT nHeight ;
                TITLE 'Browse MDI demo ' ;
                MAIN;
                MDI;
                FONT 'System' SIZE 10 

		DEFINE MAIN MENU

			POPUP 'File'
				ITEM 'Open'		ACTION OpenMDIClient()
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

			POPUP 'Help'
				ITEM 'HMG Version'	ACTION MsgInfo ( MiniGuiVersion() )
				ITEM 'About'		ACTION  MsgInfo ( padc( "MiniGUI MDI Demo", Len(MiniguiVersion()) )+CRLF+ ;
								"Contributed by Janusz Pora <januszpora@onet.eu>"+CRLF+CRLF+ ;
								MiniguiVersion(),"A COOL Feature ;)" )
			END POPUP

		END MENU

		DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
			STATUSITEM "HMG Power Ready!"
			STATUSITEM "" WIDTH 150
			CLOCK
			DATE
		END STATUSBAR

		DEFINE IMAGELIST imagelst_1 ;
			OF Form_1 ;
			BUTTONSIZE 16 , 16  ;
			IMAGE {'BtnLst.bmp'} ;
			COLORMASK CLR_DEFAULT;	
			IMAGECOUNT 6 MASK 

		DEFINE SPLITBOX 

			DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 20,20 IMAGELIST 'imagelst_1' FLAT 

				BUTTON Btn_Open ;
				        PICTUREINDEX 1 ;
					TOOLTIP 'Open a File' ;
					ACTION OpenMDIClient()

				BUTTON Btn_Close ;
					PICTUREINDEX 2 ; 
					TOOLTIP 'Close Active Child Window' ;
					ACTION CloseMdi()

			END TOOLBAR

		END SPLITBOX

		Form_1.Btn_Close.Enabled := .f.

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1 

Return Nil

Function OpenMDIClient()
    Local c_File := GetFile({{'dBase File','*.dbf'}}, 'Get File')

    if empty(c_File)
	    Return Nil
    endif
    If ! File( c_File )
	    MSGSTOP("File I/O error, cannot proceed")
	    Return Nil
    ENDIF

    CreateMDIClient(c_File)

Return Nil

Function CreateMDIClient(cFile)
    Local a_fields , a_width, cxFile 

    if Valtype(cFile) == 'U'
        cFile := "No_Title"
    Endif

    nAlias++
    cxFile :=ALLTRIM(substr(cFile,Rat('\',cFile)+1))
    cxFile :=substr(cxFile,1,len(cxFile)-4)+"_"+ltrim(str(nAlias))
    a_fields := {}
    a_width  := {}

    OpenTables(cFile, cxFile, a_fields, a_width)

    nChild++

	DEFINE WINDOW ChildMdi ;
		TITLE "Child " + ltrim(str(nChild)) + ": " + cFile ;
		MDICHILD ;
		ON INIT ( ResizeEdit(), SetColumnsWidth() ) ; 
		ON RELEASE ( CloseTables(), ReleaseMdiChild() ) ;
		ON SIZE ResizeEdit();
		ON MAXIMIZE ResizeEdit();
		ON MINIMIZE ResizeEdit();
		ON MOUSECLICK SetEditFocus()

		@ 0,0 BROWSE BrwMdi								;
			WIDTH 200  										;
			HEIGHT 200										;	
			HEADERS a_fields ;
			WIDTHS a_width ;
			WORKAREA &cxFile ;
			FIELDS a_fields ;
			TOOLTIP 'Browse Test' ;
			DELETE ;
			LOCK ;
			EDIT

		SET WINDOWPROPERTY "PROP_DBF" VALUE cxFile 

	END WINDOW
 
    lModif := .f.
    Form_1.Btn_Close.Enabled := .t.

Return Nil

Procedure OpenTables(cFile, cAlias, a_fields, a_width)
Local n

    Use &cFile Via "DBFCDX" Alias (cAlias) SHARED NEW
    Go Top

    for n:=1 to fcount()
	    aadd( a_fields , fieldname( n ) )
	    aadd( a_width  , fieldsize( n ) )
    next

Return

Procedure CloseTables()
	Use
Return

Procedure SetChange() 

    if !lModif 
        lModif := .t.
        SET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
    endif

Return

Procedure CloseMdi()

    CLOSE ACTIVE MDICHILD
    Form_1.Btn_Close.Enabled := nChild > 0

Return

Procedure ReleaseMdiChild() 
    Local cFile

    GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
    GET WINDOWPROPERTY "PROP_CFILE" VALUE cFile

    nChild--
    Form_1.Btn_Close.Enabled := nChild > 0

Return

Procedure SetColumnsWidth()
    Local ChildHandle, ChildName
    Local i

    ChildHandle := GetActiveMdiHandle() 
    i := aScan ( _HMG_aFormHandles , ChildHandle )
    if i > 0  
        ChildName := _HMG_aFormNames  [i]
	_EnableListViewUpdate( "BrwMdi", ChildName, .f. )
	_SetColumnsWidthAutoH( "BrwMdi", ChildName )
	_EnableListViewUpdate( "BrwMdi", ChildName, .t. )
    endif

Return


Procedure ResizeChildEdit(ChildName) 
    Local hwndCln, actpos:={0,0,0,0}
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

Procedure SetEditFocus()
    Local ChildHandle, ChildName, cxFile
    Local i

    GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif

    ChildHandle := GetActiveMdiHandle() 
    i := aScan ( _HMG_aFormHandles , ChildHandle )
    if i > 0  
        ChildName := _HMG_aFormNames [i]
        _SetFocus ( "BrwMdi", ChildName )
        DoMethod ( ChildName, "BrwMdi", "Refresh" )
    endif

    GET WINDOWPROPERTY "PROP_DBF" VALUE cxFile
    if Select(cxFile) > 0
       Select(cxFile)
    endif

Return

Procedure WinChildTile(lVert)
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
    CLOSE ALL
    nAlias := 0
Return

Procedure WinChildRestoreAll()
    RESTORE MDICHILDS ALL
Return
