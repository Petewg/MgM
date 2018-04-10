/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Windows MDI demo & tests by Janusz Pora
 * (C)2005 Janusz Pora <januszpora@onet.eu>
 * HMG 1.0 Experimental Build 8-12
 *
 * 2006/07/01 Revised by Pierpaolo Martinello <pier.martinello[at]alice.it>
 * Added Maximize, Restore for Mdi Child Window
*/

#include "minigui.ch"

// add By Pier 2006/07/01 Start 
#define WM_MDIMAXIMIZE                  0x0225
#define WM_MDIRESTORE                   0x0223
// add By Pier 2006/07/01 Stop 

Static nWidth
Static nHeight
	
Memvar nChild

Function Main

    Public nChild := 0

    nWidth  := GetDesktopWidth() * 0.78125
    nHeight := GetDesktopHeight() * 0.78125 

    Set InteractiveClose Query Main

       DEFINE WINDOW Form_1 ;
              AT 0,0 ;
              WIDTH nWidth ;
              HEIGHT nHeight ;
              TITLE 'MDI demo ' ;
              MAIN;
              MDI;
              FONT 'System' SIZE 12 

              DEFINE MAIN MENU

                     POPUP 'File'
                            ITEM 'New'          ACTION NewMDIClient()
                            ITEM 'Open'         ACTION OpenMDIClient() 
                            ITEM 'Save'         ACTION SaveMdi()   
                            ITEM 'Save As...'   ACTION SaveMdi("")
                            SEPARATOR
                            ITEM 'Exit'         ACTION Form_1.Release
                     END POPUP

                     POPUP 'Child Windows'
                            POPUP '&Tiled' 
                                ITEM '&Horizontal '  ACTION WinChildTile(.f.)
                                ITEM '&Vertical '    ACTION WinChildTile(.t.)
                            END POPUP
                            ITEM '&Cascade'          ACTION WinChildCascade()
                            ITEM 'Arrange &Icons'    ACTION WinChildIcons()
                            SEPARATOR
                            ITEM 'Maximize'          Action WinChildMaximize()
                            ITEM 'Restore'           Action WinChildRestore()
                            SEPARATOR
                            ITEM 'Close &All'        ACTION WinChildCloseAll()
                            ITEM '&Restore All'      ACTION WinChildRestoreAll()
                     END POPUP

                     POPUP 'Help'
                            ITEM 'HMG Version'       ACTION MsgInfo (MiniGuiVersion())
                            ITEM 'About'             ACTION  MsgInfo (padc("MiniGUI MDI Demo", Len(MiniguiVersion()))+CRLF+ ;
                                                     "Contributed by Janusz Pora <januszpora@onet.eu>"+CRLF+ ;
                                                     "and Pierpaolo Martinello <pier.martinello[at]alice.it>"+CRLF+CRLF+ ;
                                                     MiniguiVersion(),"A COOL Feature ;)")
                     END POPUP

              END MENU

              DEFINE STATUSBAR FONT 'MS Sans Serif' SIZE 9
                     STATUSITEM "HMG Power Ready!"
                     CLOCK
                     DATE
              END STATUSBAR

              DEFINE SPLITBOX 

              DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 17,17 FLAT

                            BUTTON Btn_New ;
                            TOOLTIP 'Create a New Child Window' ;
                            PICTURE 'NEW.BMP' ;
                            ACTION NewMDIClient() 

                            BUTTON Btn_Open ;
                            TOOLTIP 'Open a File' ;
                            PICTURE 'OPEN.BMP' ;
                            ACTION OpenMDIClient()

                            BUTTON Btn_Close ;
                            TOOLTIP 'Close Active Child Window' ;
                            PICTURE 'CLOSE.BMP' ;
                            ACTION CloseMdi()

                            BUTTON Btn_Save ;
                            TOOLTIP 'Save To File' ;
                            PICTURE 'SAVE.BMP' ;
                            ACTION SaveMdi()

                     END TOOLBAR

              END SPLITBOX

              Form_1.Btn_Save.Enabled  := .f.
              Form_1.Btn_Close.Enabled := .f.

       END WINDOW

       CENTER WINDOW Form_1

       ACTIVATE WINDOW Form_1 

Return Nil


Function NewMDIClient()
    CreateMDIClient()
Return Nil


Function OpenMDIClient()
    Local c_File := GetFile({{'Text File','*.txt'}, {'All File','*.*'}}, 'Get File')

    if empty(c_File)
	    Return Nil
    endif
    If ! File( c_File )
	    MSGSTOP("File I/O error, cannot proceed")
	    Return Nil
    ENDIF

    CreateMDIClient(MemoRead(c_File), c_File)

Return Nil


Function SaveMdi(cFile)
    Local ChildHandle, ChildName, cVar

if nChild > 0
    ChildHandle := GetActiveMdiHandle()
    GET WINDOWPROPERTY "PROP_FORMNAME" VALUE ChildName
    if valtype(cFile) == 'U'
        GET WINDOWPROPERTY "PROP_CFILE" VALUE cFile
    endif
    cVar := GetProperty ( ChildName , "EditMdi" , "Value" )
    if 'No Title' $ cFile .or. Empty(cFile)
        cFile := Putfile ( { {'Text Files','*.txt'} , {'All Files','*.*'} } , 'Save File' ) 
        if !empty(cFile)
	    Memowrit( cFile , cVar )
        else
            Return(.f.)
        endif
    else
	    Memowrit( cFile , cVar )
    endif
    SET WINDOWPROPERTY "PROP_MODIFIED" VALUE .f.
    Form_1.Btn_Save.Enabled  := .f.
endif

Return(.t.) 


Function CreateMDIClient(Buffer,title)

    if Valtype(Buffer) == 'U'
        Buffer := ""
    Endif
    if Valtype(Title) == 'U'
        Title := "No Title "+ltrim(str(nchild+1)) // add By Pier 2006/07/01
    Endif

	DEFINE WINDOW ChildMdi ;
		TITLE title ;
		MDICHILD ;
		ON INIT ResizeEdit(); 
		ON RELEASE ReleaseMdiChild() ;
		ON SIZE ResizeEdit();
		ON MAXIMIZE ResizeEdit();
		ON MINIMIZE ResizeEdit();
		ON MOUSECLICK SetEditFocus()

		@ 0 ,0 EDITBOX EditMdi ; 
			WIDTH 200 ;
			HEIGHT 200 ; 
			VALUE Buffer;
			ON CHANGE SetChange() 
 
	END WINDOW
	
    nChild++

	Form_1.Btn_Close.Enabled := .t.
    Form_1.Btn_Save.Enabled  := .f.

Return Nil

Function SetChange() 

    SET WINDOWPROPERTY "PROP_MODIFIED" VALUE .t.
    Form_1.Btn_Save.Enabled  := .t.

Return Nil

Function CloseMdi()

    CLOSE ACTIVE MDICHILD
    Form_1.Btn_Close.Enabled := nChild > 0
    Form_1.Btn_Save.Enabled  := nChild > 0

Return Nil

Function ReleaseMdiChild() 
    Local ChildHandle, cFile, lModif

    GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
    if lModif  
        GET WINDOWPROPERTY "PROP_CFILE" VALUE cFile
        if MsgYesNo ('Save changes?', cFile)
            SaveMdi(cFile)
        endif
    endif
    nChild--
    Form_1.Btn_Close.Enabled := nChild > 0
    Form_1.Btn_Save.Enabled  := nChild > 0

Return .f.

Function ResizeChildEdit(ChildName) 
    Local hwndCln, actpos:={0,0,0,0}
    Local i, w, h 

	i := aScan ( _HMG_aFormNames , ChildName)
	if i > 0  
        hwndCln := _HMG_aFormHandles  [i]
        GetClientRect(hwndCln,actpos)
        w := actpos[3]-actpos[1]
        h := actpos[4]-actpos[2]
        _SetControlHeight( "EditMdi", ChildName, h)
        _SetControlWidth( "EditMdi", ChildName,w)
    endif

Return NIL

Function ResizeAllChildEdit()
    Local nFrm, ChildName, n

    nFrm := len(_HMG_aFormHandles)
    For n:=1 to nFrm
        if _HMG_aFormType  [n] ==  'Y' 
            ChildName := _HMG_aFormNames  [n]
            ResizeChildEdit(ChildName) 
        endif
    Next

Return Nil

Function ResizeEdit() 
    Local ChildHandle, i, ChildName

    ChildHandle := GetActiveMdiHandle() 
    i := aScan ( _HMG_aFormHandles , ChildHandle )
    if i > 0  
        ChildName := _HMG_aFormNames  [i]
        ResizeChildEdit(ChildName)
    endif

Return Nil

// add By Pier 2006/07/01 Start 
Function WinChildMaximize() 
    Local ChildHandle

    ChildHandle := GetActiveMdiHandle() 
    if aScan ( _HMG_aFormHandles , ChildHandle ) > 0  
       Sendmessage(_HMG_MainClientMDIHandle,WM_MDIMAXIMIZE,ChildHandle,0)
    endif

Return Nil

Function WinChildRestore()
    Local ChildHandle, i

    ChildHandle := GetActiveMdiHandle() 
    if aScan ( _HMG_aFormHandles , ChildHandle ) > 0  
       Sendmessage(_HMG_MainClientMDIHandle,WM_MDIRESTORE,ChildHandle,0)
    endif

Return Nil

// add By Pier 2006/07/01 Stop

Function SetEditFocus()
    Local ChildHandle, lModif, ChildName
    Local i  

    ChildHandle := GetActiveMdiHandle() 
    GET WINDOWPROPERTY "PROP_MODIFIED" VALUE lModif
    i := aScan ( _HMG_aFormHandles , ChildHandle )
    if i > 0  
        ChildName := _HMG_aFormNames  [i]
        _SetFocus ( "EditMdi", ChildName)
    endif

    Form_1.Btn_Save.Enabled  := lModif

Return Nil

Function WinChildTile(lVert)
    if lVert
        TILE MDICHILDS VERTICAL
    else
        TILE MDICHILDS HORIZONTAL
    endif
    ResizeAllChildEdit()
Return Nil

Function WinChildCascade()
	CASCADE MDICHILDS
	ResizeAllChildEdit()
Return Nil

Function WinChildIcons()
	ARRANGE MDICHILD ICONS
Return Nil

Function WinChildCloseAll()
    CLOSE MDICHILDS ALL
Return Nil

Function WinChildRestoreAll()
    RESTORE MDICHILDS ALL
Return Nil
