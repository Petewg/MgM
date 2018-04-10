/*
 * MiniGUI DirTree Demo
*/

#include "minigui.ch"
#include "directry.ch"

#define _ID_INI_  0

MEMVAR nItemID, lBreak

PROCEDURE Main

PUBLIC nItemID := NIL

   SET FONT TO "Tahoma", 9

   DEFINE WINDOW Form_1 ;
      AT 0 , 0 ;
      WIDTH 560 HEIGHT 600 ;
      TITLE "Tree Directory" ;
      MAIN ;
      NOMAXIMIZE ;
      NOSIZE

      DEFINE STATUSBAR
         STATUSITEM ""
      END STATUSBAR

      @ 5,5 FRAME Frame_1 WIDTH 540 HEIGHT 90

      @ 25, 15 LABEL Label_1 VALUE "Source"
      @ 20, 70 BTNTEXTBOX TextBoxPATH WIDTH 465 HEIGHT 24 VALUE GetMyDocumentsFolder() ;
               ACTION SelectDir() PICTURE "filefind.bmp" BUTTONWIDTH 24

      @ 65, 15 LABEL Label_2 VALUE "File mask"
      @ 60, 70 TEXTBOX Text_1 WIDTH 120 HEIGHT 24 VALUE "*.*"

      @ 60, 210 CHECKBOX Check_1 CAPTION "Include hidden folders and files" WIDTH 190 HEIGHT 24 VALUE .T.

      @ 60, 435 BUTTON ButtonScan CAPTION "Scan" ACTION BuildTree()

      DEFINE TREE Tree_1 ;
             AT 110, 5 ;
             WIDTH 540 ;
             HEIGHT 360 ;
             NODEIMAGES { "folder.bmp" } ;
             ITEMIMAGES { "documents.bmp" } ;
             ON DBLCLICK MsgInfo( " Value  =  " + hb_ntos(Form_1.Tree_1.Value) + CRLF + ;
                                  " Item   =  " + Form_1.Tree_1.Item (Form_1.Tree_1.Value) ) ;
             ITEMIDS
      END TREE

      Form_1.Tree_1.FontColor := RED
      Form_1.Tree_1.BackColor := WHITE
      Form_1.Tree_1.LineColor := NAVY


      @ 490,  50 BUTTON ButtonExpand   CAPTION "Expand"   ACTION Proc_Expand ()
      @ 490, 175 BUTTON ButtonCollapse CAPTION "Collapse" ACTION Form_1.Tree_1.Collapse ( Form_1.Tree_1.Value )

   END WINDOW
  
   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN


*********************************************************
PROCEDURE EnableButtons ( lEnabled )
*********************************************************
   Form_1.ButtonScan.Enabled     := lEnabled
   Form_1.ButtonExpand.Enabled   := lEnabled
   Form_1.ButtonCollapse.Enabled := lEnabled

RETURN


*********************************************************
PROCEDURE SelectDir
*********************************************************
LOCAL cPath := AllTrim( Form_1.TextBoxPATH.Value )

IF !Empty( cPath := GetFolder( 'Select folder', cPath ) )
   Form_1.TextBoxPATH.Value := cPath
ENDIF

RETURN


*********************************************************
PROCEDURE Proc_Expand
*********************************************************
   IF Form_1.Tree_1.ItemCount > 0
      Form_1.Tree_1.DisableUpdate 
      Form_1.Tree_1.Expand ( Form_1.Tree_1.Value ) 
      Form_1.Tree_1.EnableUpdate
   ENDIF

RETURN


*********************************************************
PROCEDURE BuildTree
*********************************************************
LOCAL   cPath := Form_1.TextBoxPATH.Value
PRIVATE lBreak := .F.

   Form_1.ButtonScan.Caption := "Press Esc Stop"
   EnableButtons( .F. )
   
   ON KEY ESCAPE OF Form_1 ACTION lBreak := MsgYesNo( "Stop Scan?", "Confirm action" )

   IF .NOT.( EMPTY( cPath ) )

      Form_1.Tree_1.DeleteAllItems
      Form_1.Tree_1.DisableUpdate
      nItemID := _ID_INI_
      
      DEFINE NODE cPath  IMAGES { "structure.bmp" }  ID nItemID++
         ScanDir( cPath )
      END NODE
      
      Form_1.Tree_1.Expand ( 1 )
      Form_1.Tree_1.EnableUpdate
      
      Form_1.StatusBar.Item( 1 ) := hb_ntos( Form_1.Tree_1.ItemCount ) + " files/folders"
      
      Form_1.Tree_1.Value := 1
      
      Form_1.Tree_1.SetFocus

   ENDIF

   RELEASE KEY ESCAPE OF Form_1

   Form_1.ButtonScan.Caption := "Scan"
   EnableButtons( .T. )

RETURN


****************************************************************
PROCEDURE ScanDir( cPath )
****************************************************************
LOCAL cMask := AllTrim( Form_1.Text_1.Value )
LOCAL cAttr := iif( Form_1.Check_1.Value, "H", "" )
LOCAL i, aDir, aFiles, xItem

   IF RIGHT( cPath, 1 ) <> "\" 
      cPath += "\"
   ENDIF

   BEGIN SEQUENCE

      aDir := DIRECTORY( cPath, ( "D" + cAttr ) )
      
      FOR i = 1 TO LEN( aDir )
         xItem := aDir [i]
         
         IF ( "D" $ xItem[ F_ATTR ] ) .AND. ( xItem[ F_NAME ] <> "." ) .AND. ( xItem[ F_NAME ] <> ".." )
         
            DEFINE NODE xItem [ F_NAME ]  IMAGES Nil  ID nItemID++
               ScanDir( cPath + xItem [ F_NAME ] )
            END NODE
         
         ENDIF 

         DO EVENTS
         IF lBreak == .T.
            BREAK
         ENDIF 
      NEXT

      aFiles := DIRECTORY( ( cPath + cMask ), cAttr )

      FOR i = 1 TO LEN( aFiles )
         xItem := aFiles [i]
         
         TREEITEM xItem [ F_NAME ]  IMAGES Nil  ID nItemID++
         
         Form_1.StatusBar.Item( 1 ) := "Scan " + HB_NTOS (Form_1.Tree_1.ItemCount) + " files/folders [ " +  cPath + xItem[ F_NAME ] + "]"
         
         DO EVENTS
         IF lBreak == .T.
            BREAK
         ENDIF   
      NEXT
   
   END SEQUENCE
 
RETURN
