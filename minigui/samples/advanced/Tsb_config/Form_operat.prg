/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2013 Verchenko Andrey <verchenkoag@gmail.com>
 * Helped and taught by Grigory Filatov <gfilatov@inbox.ru>
 *
*/

#include "minigui.ch"

MEMVAR oBrw
//////////////////////////////////////////////////////////////////////////////
// Function: Additional window to guide operators
FUNCTION DimOperat(aPole) 
  LOCAL aDim := {}
  LOCAL nVal := aPole[1]  // number processed in the column of the table
  LOCAL nIsxSel := SELECT(), aCod := {}, aNom := {}
***************** The list of fields TBrowse *********************************
* |    1  |   2  |   3  |    4  |      5   |     6     |     7    | 8
* | Column| Base | Field| Field | Field    | Processing| Treating | Writing
* | Name  | alias| name | Format| Alignment| Field     | Function | in a field
  LOCAL cPCode := aPole[2][8], cAlias := aPole[2][2], cPName := aPole[2][3]

     SELECT(cAlias)
     GOTO TOP
     DO WHILE !EOF() 
        IF !DELETED()
           AADD( aCod, FIELDGET(FIELDNUM(cPName)) )
           AADD( aNom, FIELDGET(FIELDNUM(cPCode)) )
        ENDIF
        SKIP 
     ENDDO
     SELECT(nIsxSel)
     aDim := { aCod , aNom }
     // Display the directory (option 1)
     // oBrw:SetData( nVal, ComboWBlock( oBrw, cAlias+"->"+cPName, nVal, aDim ) )

     // Display the directory (option 2)
     oBrw:SetData( nVal, NIL, aDim )
     oBrw:aColumns[nVal]:bEditing := { |uVar,oBrw| CreateHelpLabel(), oBrw:aColumns[oBrw:nCell]:oEdit:LButtonDown() }
     oBrw:aColumns[nVal]:bEditEnd := { |uVal,oBrw,lSave| SaveOp(uVal,lSave,cPCode) }

  RETURN .T.

//////////////////////////////////////////////////////////////////////////////
FUNCTION SaveOp(nVal, lSave, cPCode)
   LOCAL nI, cObject

   DoMethod("Form_0","help","release")
   // ----------- show all buttons -----------
   FOR nI := 1 TO LEN(M->aToolBtn)
       cObject := M->aToolBtn[nI]+str(nI,1)
       SetProperty( "Form_0", cObject, "Visible", .T. )
   NEXT

   IF lSave .AND. M->oBrw:lHasChanged
        IF (oBrw:cAlias)->( RLock() )
           Replace &cPCode With nVal
           UnLock
        ELSE
           MsgInfo("Record is locked!")
        ENDIF
   ENDIF

 RETURN .T.

//////////////////////////////////////////////////////////////////////////////
FUNCTION CreateHelpLabel()
   LOCAL nI, cObject

   // ----------- hide all buttons -----------
   FOR nI := 1 TO LEN(M->aToolBtn)
       cObject := M->aToolBtn[nI]+str(nI,1)
       SetProperty("Form_0", cObject, "Visible", .F.) 
   NEXT

     DEFINE LABEL help
        ROW 5
        COL oBrw:aColumns[oBrw:nCell]:oEdit:nLeft
        WIDTH oBrw:aColumns[oBrw:nCell]:oEdit:nRight - oBrw:aColumns[oBrw:nCell]:oEdit:nLeft + 40
        HEIGHT 28
        PARENT Form_0
        VALUE "Enter - complete the entry"
        CENTERALIGN .T.
        VCENTERALIGN .T.
        BACKCOLOR WHITE
        FONTSIZE 12
        FONTBOLD .T.
        FONTUNDERLINE .T.
     END LABEL

 RETURN .T.
