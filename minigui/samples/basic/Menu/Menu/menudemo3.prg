/*
* MiniGUI Menu Demo
*/

#include "minigui.ch"

Static IsMenuActive

Procedure Main

	DEFINE WINDOW Win_1 ;
		AT 0,0 ;
		WIDTH 400 ;
		HEIGHT 400 ;
		TITLE 'Menu Demo 3' ;
		MAIN ;
		ON INIT buildmenu()

		@ 10,10 LABEL LABEL_1 VALUE "[F2] - ENABLE MENU"

		@ 35,10 LABEL LABEL_2 VALUE "[F3] - ERASE / RESTORE MENU" AUTOSIZE

	END WINDOW

	ON KEY F2 OF Win_1 ACTION EnableMainMenu ('Win_1')
	ON KEY F3 OF Win_1 ACTION iif( IsMenuActive, clearmenu(), buildmenu() )

	ACTIVATE WINDOW Win_1

Return

Procedure buildmenu()
Local n
Local m_char
Local m_executar

	IsMenuActive := .T.

	DEFINE MAIN MENU OF Win_1

	    POPUP "&File"
			MenuItem 'Open'		Action MsgInfo ( 'File:Open'  )
			MenuItem 'Save'		Action MsgInfo ( 'File:Save'  )
			MenuItem 'Print'	Action MsgInfo ( 'File:Print' )
			MenuItem 'Save As...'	Action MsgInfo ( 'File:Save As' ) Name SaveAs Disabled
			Separator
			MenuItem 'Exit'		Action Win_1.Release
	    END POPUP

	    POPUP "&Option"
		        FOR n := 1 TO 3
		            m_char = strzero(n,2)
		            m_executar := "ACT_" + m_char + "()"
		            MENUITEM 'EXE ' + m_char ACTION &m_executar NAME &m_char
		        NEXT
	    END POPUP

	END MENU

Return

Procedure clearmenu()

	IsMenuActive := .F.

	DEFINE MAIN MENU OF Win_1

	END MENU

Return

Procedure act_01()
	DisableMainMenu ('Win_1')
Return

Procedure act_02()
	MsgInfo ('Action 02')
Return

Procedure act_03()
	MsgInfo ('Action 03')
Return

Function DisableMainMenu( cFormName )
Local nFormHandle , i , nControlCount

    nFormHandle   := GetFormHandle ( cFormName )
    nControlCount := Len ( _HMG_aControlHandles )

    For i := 1 To nControlCount

        If _HMG_aControlParentHandles [i] ==  nFormHandle
            If ValType ( _HMG_aControlHandles [i] ) == 'N'
                IF _HMG_aControlType [i] == 'MENU' .and. _HMG_aControlEnabled [i] == .T.
                    _DisableMenuItem ( _HMG_aControlNames [i], cFormName )
                endif
            EndIf
        EndIf

    Next i

Return Nil

Function EnableMainMenu( cFormName )
Local nFormHandle , i , nControlCount

    nFormHandle   := GetFormHandle ( cFormName )
    nControlCount := Len ( _HMG_aControlHandles )

    For i := 1 To nControlCount

        If _HMG_aControlParentHandles [i] ==  nFormHandle
            If ValType ( _HMG_aControlHandles [i] ) == 'N'
                IF _HMG_aControlType [i] == 'MENU' .and. _HMG_aControlEnabled [i] == .T.
                    _EnableMenuItem ( _HMG_aControlNames [i], cFormName )
                endif
            EndIf
        EndIf

    Next i

Return Nil
