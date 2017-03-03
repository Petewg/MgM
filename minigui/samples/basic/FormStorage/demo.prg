/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * (C) 2006 Krutov Oleg <krutoff@mail.ru>
*/

#include "MiniGui.ch"

MEMVAR cFileIni

Procedure Main
PUBLIC cFileIni := GetStartUpFolder() + "\" + Lower(cFileNoExt(GetExeFileName()))+'.ini'

    DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 200 ;
		TITLE 'Form Storage' ;
		MAIN ;
                ON INIT RestoreConrols(ThisWindow.Name) ;
                ON RELEASE SaveConrols(ThisWindow.Name)

		DEFINE TEXTBOX Text_1
			ROW    10
			COL    10
			WIDTH  200
			HEIGHT 24
			FONTNAME "Tahoma"
			FONTSIZE 9
			TABSTOP .T.
			READONLY .F.
			BACKCOLOR YELLOW
			FONTCOLOR RED
        		VALUE ""
		END TEXTBOX

		DEFINE CHECKBUTTON CheckBtn_1
			ROW    40
			COL    10
			WIDTH  100
			HEIGHT 28
			CAPTION "Disable Edit"
			VALUE .F.
			FONTNAME "Tahoma"
			FONTSIZE 9
			ONCHANGE Form_1.Text_1.Enabled := !Form_1.Text_1.Enabled
			TABSTOP .T.
			VISIBLE .T.
		END CHECKBUTTON

		DEFINE BUTTON Button_1
			ROW	10
			COL	270
			CAPTION 'OK' 
			ACTION MsgBox('Hello World!')
			DEFAULT .T.
		END BUTTON

		DEFINE BUTTON Button_2
			ROW	40
			COL	270
			CAPTION 'Cancel'
			ACTION ( Form_1.CheckBtn_1.Value := .F., ThisWindow.Release )
		END BUTTON

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return

/*
*/
PROCEDURE SaveConrols( FormName )
LOCAL i, hWnd, ControlCount

hWnd := GetFormHandle(FormName)
ControlCount := Len (_HMG_aControlHandles)

BEGIN INI FILE cFileIni
  _SetIni(FormName, FormName+'.Row',	GetWindowRow(hWnd))
  _SetIni(FormName, FormName+'.Col',	GetWindowCol(hWnd))
  _SetIni(FormName, FormName+'.Width',	GetWindowWidth(hWnd))
  _SetIni(FormName, FormName+'.Height',	GetWindowHeight(hWnd))
  For i := 1 To ControlCount
    IF _HMG_aControlParentHandles[i] == hWnd .AND. _HMG_aControlValue[i] <> Nil
       SET SECTION FormName ENTRY _HMG_aControlNames[i] TO GetProperty(FormName, _HMG_aControlNames[i], 'Value')
    ENDIF
  Next i
END INI

RETURN

/*
*/
PROCEDURE RestoreConrols( FormName )
LOCAL i, hWnd, ControlCount, uVar

hWnd := GetFormHandle(FormName)
ControlCount := Len(_HMG_aControlHandles)

BEGIN INI FILE cFileIni
  IF (i := _GetIni(FormName,FormName+'.Row',-1,0)) # -1
     SetProperty(FormName,'Row',i)
  ENDIF
  IF (i := _GetIni(FormName,FormName+'.Col',-1,0)) # -1
     SetProperty(FormName,'Col',i)
  ENDIF
  IF (i := _GetIni(FormName,FormName+'.Width',-1,0)) # -1
     SetProperty(FormName,'Width',i)
  ENDIF
  IF (i := _GetIni(FormName,FormName+'.Height',-1,0)) # -1
     SetProperty(FormName,'Height',i)
  endif
  For i := 1 To ControlCount
     IF _HMG_aControlParentHandles[i] == hWnd
        IF (uVar := _GetIni(FormName,_HMG_aControlNames[i],NIL,_HMG_aControlValue[i])) <> Nil
           SetProperty(FormName, _HMG_aControlNames[i], 'Value', @uVar)
        ENDIF
     ENDIF
  Next i
END INI

RETURN
