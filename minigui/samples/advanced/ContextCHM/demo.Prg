#include "MiniGUI.ch"

ANNOUNCE RDDSYS

// Topics
#define HLP_1		100
#define HLP_2		200
#define HLP_INDEX	10000

Procedure Main

SET HELPFILE TO 'Demo.chm'

Define window wDemo ;
    At 0, 0 ;
    Width 550 Height 350 ;
    Title 'Usage Help File in Format CHM' ;
    Main ;
    NoMaximize ;
    NoSize

    Define main menu
        Define popup 'File'
            ITEM '&Welcome'		ACTION DISPLAY HELP MAIN
            ITEM '&Item 2'		ACTION DisplayHelpTopic( HLP_2 )
            ITEM '&Fast Cars'		ACTION DisplayHelpTopic( "fastcars" )
            ITEM '&Expensive Cars'	ACTION DisplayHelpTopic( 'expensivecars' )
            SEPARATOR
            ITEM 'E&xit'		ACTION wDemo.Release
        End Popup
        Define popup 'Help'
            ITEM '&Context'		ACTION DISPLAY HELP CONTEXT HLP_1
            ITEM '&Index'		ACTION DISPLAY HELP CONTEXT HLP_INDEX
        End Popup
    End Menu

    Define statusbar
      StatusItem 'F1 - Help' Action DISPLAY HELP MAIN
    End Statusbar

    On key F1 of wDemo Action DISPLAY HELP MAIN

End Window

Center window wDemo
Activate window wDemo

Return
