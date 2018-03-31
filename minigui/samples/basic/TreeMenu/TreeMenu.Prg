/*

  MINIGUI - Harbour Win32 GUI library Demo/Sample
 
  Copyright 2002-08 Roberto Lopez <harbourminigui@gmail.com>
 
  TreeMenu is Freeware HMG TREE sample.
    
  Not really an alternative "menu", simply denote to evaluate
  ON DBLCLICK event in TREE.
  
  Since NODE and TREEITEM statements does not have any event
  definition, event management in TREE require a little
  different way.
     
  All bug reports and suggestions are welcome.
    
  Developed under Harbour Compiler and
  MINIGUI - Harbour Win32 GUI library (HMG).
  
  Thanks to "Le Roy" Roberto Lopez.
 
*/

#include "minigui.ch"

PROCEDURE Main()

    DEFINE WINDOW frmTreeMenu ;
        AT 0,0 ;
        WIDTH 640 ;
        HEIGHT 480 ;
        TITLE 'Tree Menu Sample' ;
        MAIN ;
        ON INIT ExpandAll()

        ON KEY ESCAPE ACTION frmTreeMenu.Release

        DEFINE TREE treMenu AT 0,0 WIDTH 100 HEIGHT 160 ;
                    ON DBLCLICK { || RunAction( this.Value ) }
                    
            NODE 'New'                              //  1
                TREEITEM 'Table'                    //  2
                TREEITEM 'Text'                     //  3
                TREEITEM 'Project'                  //  4
            END NODE
                          
            NODE 'Open'                             //  5
                TREEITEM 'Table'                    //  6
                TREEITEM 'Text'                     //  7
                TREEITEM 'Project'                  //  8
            END NODE                                

        END TREE


    END WINDOW

    CENTER   WINDOW frmTreeMenu

    ACTIVATE WINDOW frmTreeMenu

RETURN // Main()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE ExpandAll()

  frmTreeMenu.treMenu.Expand( 1 )
  frmTreeMenu.treMenu.Expand( 5 )

RETURN // ExpandAll()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE RunAction( ;
                 nTreeItemNo )

   SWITCH nTreeItemNo
      CASE 2              // New Table
         NewTable()
         EXIT
      CASE 3              // New Text
         NewText()
         EXIT
      CASE 4              // New Project
         NewProject()
         EXIT
      CASE 6              // Open Table
         OpenTable()
         EXIT
      CASE 7              // Open Text
         OpenText()
          EXIT
     CASE 8              // Open Project
         OpenProject()
   ENDSWITCH

RETURN // RunAction()

*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.

PROCEDURE NewTable()
   MsgBox( "New Table procedure will run." ) 
RETURN // NewTable()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
PROCEDURE NewText()
   MsgBox( "New Text procedure will run." ) 
RETURN // NewText()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
PROCEDURE NewProject()
   MsgBox( "New Project procedure will run." ) 
RETURN // NewProject()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
PROCEDURE OpenTable()
   MsgBox( "Open Table procedure will run." ) 
RETURN // OpenTable()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
PROCEDURE OpenText()
   MsgBox( "Open Text procedure will run." ) 
RETURN // OpenText()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
PROCEDURE OpenProject()
   MsgBox( "Open Project procedure will run." ) 
RETURN // OpenProject()
*-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.-._.
