/*
   HMG Fill Directory List Demo

   (c) 2011 Bicahi Esgici
   
*/

#include "minigui.ch"

PROCEDURE MAIN()

   DEFINE WINDOW frmTestDirList;
      AT 0, 0;
      WIDTH  500 ;
      HEIGHT 500 ;
      TITLE "Test DIR List" ;
      MAIN ; 
      ON INIT FillDirList(.t.)

      ON KEY ESCAPE ACTION ThisWindow.Release

      @ 10,  100 BUTTON  btnReLoad    CAPTION "Re-Load" ACTION FillDirList()
      @ 100, 100 LISTBOX lstbxDirList WIDTH 300 HEIGHT 300 SORT

   END WINDOW // frmTestDirList

   frmTestDirList.Center
   frmTestDirList.Activate

RETURN // MAIN()

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PROCEDURE FillDirList(lInit)

LOCAL cDIRName   := GetFolder( "Choose a folder" ) 
LOCAL aDirList   AS ARRAY
LOCAL nDirElemNo

DEFAULT lInit := .f.

IF !EMPTY( cDIRName ) 

   cDIRName += "\*.*"
   cDIRName := STRTRAN( cDIRName, "\\", "\" )

   ASSIGN aDirList := Directory( cDIRName )
   IF EMPTY( aDirList )
      MsgInfo( cDIRName + CRLF + " This folder doesn't contains ordinary file.")
   ELSE

      IF !lInit
         frmTestDirList.lstbxDirList.DeleteAllItems()
      ENDIF !lInit

      FOR nDirElemNo := 1 to LEN( aDirList )
         frmTestDirList.lstbxDirList.AddItem( aDirList[ nDirElemNo, 1 ] )  
      NEXT
   ENDIF EMPTY( aDirList )

ENDIF !EMPTY( cDIRName ) 

RETURN // FillDirList()

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
