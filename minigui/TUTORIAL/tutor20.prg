#include "minigui.ch"

Function Main

    DEFINE WINDOW Win_1 ;
        AT 0,0 ;
        WIDTH 640 HEIGHT 480 ;
        TITLE 'Tutor 20: BROWSE Test' ;
        MAIN NOMAXIMIZE ;
        ON INIT OpenTables() ;
        ON RELEASE CloseTables()

        DEFINE MAIN MENU 
            POPUP 'File'
                ITEM 'Set Browse Value' ACTION Win_1.Browse_1.Value := Val ( InputBox ('Set Browse Value','') )
                ITEM 'Get Browse Value' ACTION MsgInfo ( Str ( Win_1.Browse_1.Value ) )
                SEPARATOR
                ITEM 'Exit' ACTION Win_1.Release
            END POPUP
            POPUP 'Help'
                ITEM 'About' ACTION MsgInfo ("Tutor 20: BROWSE Test") 
            END POPUP
        END MENU

        @ 10,10 BROWSE Browse_1 ;
            WIDTH 610 ;
            HEIGHT 390 ; 
            HEADERS { 'Code' , 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Biography' } ;
            WIDTHS { 150 , 150 , 150 , 150 , 150 , 150 } ;
            WORKAREA Test ;
            FIELDS { 'Test->Code' , 'Test->First' , 'Test->Last' , 'Test->Birth' , 'Test->Married' , 'Test->Bio' } ;
            DELETE ;
            LOCK ;
            EDIT INPLACE

    END WINDOW

    CENTER WINDOW Win_1

    ACTIVATE WINDOW Win_1

Return Nil

Procedure OpenTables()
    Use Test
    Win_1.Browse_1.Value := RecNo() 
Return

Procedure CloseTables()
    Use
Return
