/*
HMGS - MiniGUI - IDE - Harbour Win32 GUI Designer

Copyright 2005-2015 Walter Formigoni <walter.formigoni@gmail.com>
http://sourceforge.net/projects/hmgs-minigui/

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License along with
   this software; see the file COPYING. IF not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
   (or visit the web site http://www.gnu.org/).


   Parts of this project are based upon:
   MINIGUI - Harbour Win32 GUI Designer

   Copyright 2002 Roberto Lopez <roblez@ciudad.com.ar>
   http://www.geocities.com/harbour_minigui/

   Harbour Minigui IDE

   (c)2004-2005 Roberto Lopez <roblez@ciudad.com.ar>
   http://www.geocities.com/harbour_minigui/

   (c)2007-2008 Arcangelo Molinaro <arcangelo.molinaro@fastwebnet.it>
   Readflds.prg donated to public domain
   for Minigui HMGS-IDE by Walter Formigoni
   Browse Automated Control 'DatabaseName' , 'Fields', 'Widths', 'Headers'
   'Valid', 'ValidMessages','Image', 'ReadOnlyFields','Justify','When',
   'OnHeadClick', 'WorkArea' .

   Rel.0.35  Date : 18/01/2008 Time : 13.45
*/

#DEFINE CTRL_ON    .T.
#DEFINE CTRL_OFF   .F.
#DEFINE NOT_SAVED  .F.
#DEFINE SAVED      .T.
#DEFINE ALIASONLY  1
#DEFINE DBFONLY    2
#DEFINE ALIASDBF   3

#include "minigui.ch"
#include "ide.ch"
#include "dbstruct.ch"


DECLARE WINDOW Form_Fld
DECLARE WINDOW ObjectInspector
DECLARE WINDOW BrwAdvanced

*------------------------------------------------------------*
FUNCTION PICK_FLD_FW( A1 AS STRING,  ;
                      A2 AS STRING,  ;
                      A3 AS STRING,  ;
                      A4 AS STRING   ;
                    )
*------------------------------------------------------------*
   LOCAL aMyFields      AS ARRAY   := {}    /* pick-up array Database Fields list */
   LOCAL aMyNewField    AS ARRAY   := {}    /* picked-up array Selected Database Fields list */
   LOCAL aDownLoad      AS ARRAY   := {}    /* array with old value */
   LOCAL cFileName      AS STRING  := ""
   LOCAL cDatabasePath  AS STRING  := ""
   LOCAL cAlias         AS STRING  := ""
   LOCAL lMes           AS LOGICAL := .T.
   LOCAL cStoredDbName  AS STRING  := ""

   PUBLIC _lChngd       AS LOGICAL := .F.

   SET INTERACTIVECLOSE OFF
   SET TOOLTIPSTYLE BALLOON
   SET TOOLTIP BALLOON ON

   cFileName     := xArray[ xControle( A3 ), 95 ]     /* DatabaseName  in Browse Control */
   cDatabasePath := xArray[ xControle( A3 ), 97 ]     /* DatabasePath  in Browse Control */
   cAlias        := xArray[ xControle( A3 ), 21 ]     /* WorkArea      in Browse Control */
   aDownLoad     := SAVEOLD_FSTR( A1, A2, A3, A4 )    /* save actual data                */

   LOAD WINDOW Form_Fld

   Ctrl_Envis_ONOFF( CTRL_OFF )

   SET TOOLTIP MaxWidth  TO 600    OF Form_Fld
   SET TOOLTIP TextColor TO YELLOW OF Form_Fld
   SET TOOLTIP BackColor TO BLACK  OF Form_Fld

   SetToolTipFont( GetFormToolTipHandle( "Form_Fld" ),, 20,,,,, 0 )

   CENTER WINDOW Form_Fld

   ACTIVATE WINDOW Form_Fld

RETURN NIL


*------------------------------------------------------------*
FUNCTION MR_INI( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL lExistStoredAlias  AS LOGICAL := .F.
   LOCAL lExistStoredPath   AS LOGICAL := .F.
   LOCAL lExistStoredDbPath AS LOGICAL := .F.
   LOCAL lExistStruct       AS LOGICAL := .F.
   LOCAL lExistStoredDbName AS LOGICAL := .F.
   LOCAL lIniExist          AS USUAL   := _IsIniDef()  //? VarType
   LOCAL cStoredPath        AS STRING  := ""
   LOCAL cStoredAlias       AS STRING  := ""
   LOCAL cStoredDbName      AS STRING  := ""
   LOCAL cStoredDbPath      AS STRING  := ""
   LOCAL aReturn            AS ARRAY   := {}
   LOCAL aField             AS ARRAY   := {}
   LOCAL aStruct            AS ARRAY   := {}

   IF lIniExist                      /* Read Value Stored in *.INI file and set Stored flags */
      AAdd( aReturn, lIniExist )     /* 1  */

      lExistStoredAlias := fstralias_ck( A3 )

      IF lExistStoredAlias           /* .T. if Stored WorkArea in *.ini file exist and is !Empty and !Upper("nil") */
         cStoredAlias := loadalias( A3 )
      ENDIF

      AAdd( aField, lExistStoredAlias )  /* 2 WorkArea */
      AAdd( aField, cStoredAlias      )
      AAdd( aField, 'WorkArea'        )
      AAdd( aReturn, aField           )

      aField           := {}
      lExistStoredPath := fstrPath_ck( A3 )

      IF lExistStoredPath               /* .T. if Stored Path  in *.ini file exist and is !Empty and !Upper("nil") */
         cStoredPath := loadpath( A3 )
      ENDIF

      AAdd( aField, lExistStoredPath )  /* 3 DatabasePath */
      AAdd( aField, cStoredPath      )
      AAdd( aField, 'DatabasePath'   )
      AAdd( aReturn, aField          )

      aField       := {}
      lExistStruct := fstrStruct_ck( A3 )

      IF lExistStruct             /* .T. if Stored dbStruct()  in *.ini file exist and is !Empty */
         aStruct := LOADSTRUCT( A3 )
      ENDIF

      AAdd( aField, lExistStruct     )         /* 4 dbStruct() */
      AAdd( aField, aStruct          )
      AAdd( aField, 'DatabaseStruct' )
      AAdd( aReturn, aField          )

      aField             := {}
      lExistStoredDbName := fstrDbName_ck( A3 )

      IF lExistStoredDbName      /* .T. if Stored *.DBF name in *.ini file exist and is !Empty and !Upper("nil") */
         cStoredDbName := lddbfname( A3 )
      ENDIF

      AAdd( aField, lExistStoredDbName )    /* 5 DatabaseName */
      AAdd( aField, cStoredDbName      )
      AAdd( aField, 'DatabaseName'     )
      AAdd( aReturn, aField            )

      aField := {}

      IF lExistStoredDbName .AND. lExistStoredPath
         IF lExistStoredDbPath := fex_ck( cStoredPath + "\" + cStoredDbName + ".dbf" ) /* .T. if DatabaseName value in *.ini file exist in the specified Path and is !Empty and !Upper("nil") */
            cStoredDbPath := cStoredPath + "\" + cStoredDbName + ".dbf"
         ENDIF
      ENDIF

      AAdd( aField, lExistStoredDbPath )   /* 6 DatabasePathName */
      AAdd( aField, cStoredDbPath      )
      AAdd( aField, 'DatabasePathName' )   /* I Add 3^ value only for debug */
      AAdd( aReturn, aField            )

      aField := {}
   ELSE
      /* <project>.ini file doesn't exist */
   ENDIF

RETURN aReturn


*------------------------------------------------------------*
FUNCTION Choose_Way( A1        AS STRING, ;
                     A2        AS STRING, ;
                     A3        AS STRING, ;
                     A4        AS STRING, ;
                     cFilename AS STRING, ;
                     aMyFields AS ARRAY   ;
                   )
*------------------------------------------------------------*
   LOCAL nPos             AS NUMERIC := 0
   LOCAL lMode            AS LOGICAL := .T.
   LOCAL lFlag            AS LOGICAL := .F.
   LOCAL cMyWidths        AS STRING  := ""
   LOCAL cMyHeaders       AS STRING  := ""
   LOCAL cMyPath          AS STRING  := ""
   LOCAL cMyAlias         AS STRING  := ""
   LOCAL lExistFields     AS LOGICAL
   LOCAL lExistDatabase   AS LOGICAL
   LOCAL lExistDbPath     AS LOGICAL
   LOCAL lExistAlias      AS LOGICAL
   LOCAL aReturn          AS ARRAY   := {}
   LOCAL cFilePath        AS STRING  := ""
   LOCAL cMyValid         AS STRING
   LOCAL cMyValidMessages AS STRING
   LOCAL cImageNames      AS STRING
   LOCAL cReadOnlyValues  AS STRING
   LOCAL cMyJustifyValues AS STRING
   LOCAL cWhen            AS STRING
   LOCAL cOnHeadClick     AS STRING
   LOCAL cAlias           AS STRING  := ""
   LOCAL aStruct          AS ARRAY   := {}
   LOCAL aPass            AS ARRAY   := {}
   LOCAL aChoice          AS ARRAY   := {}
   LOCAL aIniReturn       AS ARRAY   := {}
   LOCAL aIniField        AS ARRAY   := {}
   LOCAL cDatabasePath    AS STRING  := ""
   LOCAL lInsert          AS LOGICAL := .T.
   LOCAL lNewAlias        AS LOGICAL := .F.
   LOCAL cMessage         AS STRING  := ""
   LOCAL cMessage1        AS STRING  := ""
   LOCAL cText            AS STRING  := ""
   LOCAL nChoice          AS NUMERIC := 0
   LOCAL cTempAlias       AS STRING  := ""
   LOCAL cWindowTitle     AS STRING  := ""
   LOCAL cWindowText      AS STRING  := ""
   LOCAL aButtonCaption   AS ARRAY   := {}
   LOCAL lNewCreateDB     AS LOGICAL := .F.
   LOCAL lExec            AS LOGICAL
   LOCAL cOlddir          AS STRING

   aReturn        := MR_FSTR()                                 /* Read Value Stored in Browser Inspector  */
   cFilePath      := aReturn[ 3 ] + "\" + aReturn[ 2 ] + ".dbf"
   lExistDatabase := fname_ck( aReturn[ 2 ] )                    /* .T. if DatabaseName Value in Browser is !Empty and !Upper("nil"), Value is Valid    */
   lExistFields   := ffield_ck( aReturn[ 1 ] )                   /* .T. if Fields   Value in Browser is !Empty and valid                            */
   lExistAlias    := falias_ck( aReturn[ 11 ] )                  /* .T. if WorkArea Value in Browser is !Empty and !Upper("nil"), Value is Valid    */
   lExistDbPath   := fex_ck( cFilePath )                         /* .T. if DatabaseName value in Browser exist in the specified Path in Browser and is !Empty and !Upper("nil")     */

   IF lExistFields .AND. lExistAlias .AND. lExistDatabase
      cTempAlias := RCVR_WKA( aReturn[ 1 ], aReturn[ 2 ], A3 )

      IF cTempAlias <> aReturn[ 11 ]
         cWindowTitle   := "WARNING MESSAGE"
         cWindowText    := "'WorkArea'alias = " + AllTrim( aReturn[ 11 ] ) + ;
                           "   'Fields'  alias = " + cTempAlias + CRLF + ;
                           "Select the correct value !"

         aButtonCaption := { "WorkArea", "Fields" }
         nChoice        := MsgOptions( cWindowTitle, cWindowText, aButtonCaption )

         IF nChoice = 1
            Form_fld.Text_2.Value := aReturn[ 11 ]
            cAlias                := aReturn[ 11 ]
            aReturn[ 1 ]          := AtRepl( cTempAlias, aReturn[ 1 ], cAlias )

            sv_objfield( { "Fields", "WorkArea" }, { aReturn[ 1 ], aReturn[ 11 ] } , A3, NOT_SAVED, SAVED )
         ELSE
            sv_objfield( "WorkArea", cTempAlias, A3, NOT_SAVED, SAVED )

            aReturn[ 11 ]          := cTempAlias
            Form_fld.Text_2.Value := cTempAlias
         ENDIF

         EXIT_WND()
         RETURN NIL
      ENDIF
   ENDIF

   nChoice := 0

   /* Added 15/01/2008 A.M. - Start Code */
   IF lExistFields .AND. lExistAlias .AND. ! lExistDatabase
      IF MsgYesNo( "DatabaseName not found !!" + CRLF + "Look for *.DBF ? ", "Message" )
         cOlddir := GetCurrentFolder()
         aPass   := ChooseOnlyDbf( A3, cFilename )
         IF aPass[ 1 ]
            cFilename      := aPass[ 2 ]

            StrDbfPath( cOldDir, A3 )

            A2             := ""
            aReturn        := MR_FSTR()
            cFilePath      := aReturn[ 3 ] + "\" + aReturn[ 2 ] + ".dbf"
            lExistDbPath   := fex_ck( cFilePath )
            lExistDatabase := .T.
         ELSE
            EXIT_WND()
            RETURN NIL
         ENDIF
      ELSE
         MSGSTOP( "WorkArea is present but no DatabaseName "        + CRLF + ;
                  " and/or No DatabasePath !"                       + CRLF + ;
                  "Before to continue you have"                     + CRLF + ;
                  "to create, copy or restore the *.DBF", "WARNING" )

         EXIT_WND()
         RETURN nil
      ENDIF
   ENDIF
   /* Added 15/01/2008 A.M. - End Code */


   IF ! lExistAlias .OR. ! lExistDbPath .OR. ! lExistDatabase

      /* Set Message */
      IF lExistAlias .AND. ! lExistDatabase
         cMessage  := "Database not found !"
         cMessage1 := "Look for Database ?"
         cText     := "Select a Database"
         cAlias    := aReturn[ 11 ]
         nChoice   := DBFONLY

      ELSEIF ! lExistAlias .AND. lExistDatabase
         cMessage   := "WorkArea not found !"
         cMessage1  := "Select new one ?"
         cText      := "Select WorkArea"
         nChoice    := ALIASONLY

      ELSEIF ! lExistAlias .AND. ! lExistDatabase
         cMessage   := "WorkArea and Database not found !"
         cMessage1  := "Select WorkArea and Database Now ?"
         cText      := "Select WorkArea and Database"
         nChoice    := ALIASDBF
      ENDIF

      IF MsgYesNo( cMessage + CRLF + cMessage1, cText )
         aPass     := ChooseFileVerify( A3, lInsert, nChoice )
         cFilename := aPass[ 1 ]

         IF Empty( cFilename ) .AND. ( nChoice = DBFONLY .OR. nChoice = ALIASDBF )   /* No Database Choice, all is the same */
            EXIT_WND()
            RETURN NIL

         ELSEIF Empty( cFilename ) .AND. nChoice = ALIASONLY
            cFilename := aReturn[ 2 ]
         ENDIF

         if ! Empty( aPass ) .AND. Len( aPass ) = 2 .AND. ( nChoice = ALIASONLY .OR. nChoice = ALIASDBF )
            cAlias := aPass[ 2 ]
         ELSE
            cAlias := aReturn[ 11 ]
         ENDIF

         Form_fld.Text_1.Value := cFilename
         Form_fld.Text_2.Value := cAlias

         IF nChoice = DBFONLY
            cAlias := ""
            Strt_dBuild( cFilename, cAlias, A3, A4 )
            A2             := ""
            lExistDatabase := .T.

         ELSEIF nChoice = ALIASDBF
            Strt_dBuild( cFilename, cAlias, A3, A4 )
            A2             := ""
            lExistDatabase := .T.
            lExistAlias    := .T.
            lNewAlias      := .T.
         ELSE
            cFilename := Imp_String( A1, A2, A3, A4, cFilename, cAlias, lMode ) /* Modify  Mode */
            What_Field( A3 )
            lExistAlias := .T.
            lNewAlias   := .T.
         ENDIF
      ELSE
         IF A1 <> 'DatabaseName' .AND. A1 <> 'DatabasePath'
            EXIT_WND()
            RETURN NIL
         ENDIF
      ENDIF
   ENDIF

   IF lExistDatabase .AND. A1 == 'DatabaseName' .AND. Form_fld.List_2.ItemCount = 0
      Form_Fld.Button_5.Enabled := .T.

      IF lNewAlias = .F.
         IF MsgYesNo( "Select a new Database ?", "MESSAGE" )
            aPass     := ChooseFileVerify( A3, lInsert, DBFONLY )   /* Choose DATABASE and Write DatabasePath and WorkArea in Object Inspector */
            cFilename := aPass[ 1 ]
            IF Empty( cFilename )           /* No Choice, all is the same */
               EXIT_WND()
               RETURN NIL
            ELSE
               cAlias := ""
               Strt_dBuild( cFilename, cAlias, A3, A4 )
               A2    := ""                      /* restart */
               lMode := .F.
            ENDIF
         ELSE
            IF ! lNewAlias
               cAlias := aReturn[ 11 ]
            ENDIF
         ENDIF
      ELSE
         lNewAlias := .F.
      ENDIF
      Form_fld.Text_1.Value := cFilename
      Form_fld.Text_2.Value := cAlias

      IF lExistFields
         cFilename := Imp_String( A1, A2, A3, A4, cFilename, cAlias, lMode ) /* Modify  Mode */
      ELSE
         cFilename := MR_FSTR()[ 2 ]
         cFilename := Check_fields( A1, A2, A3, A4, cFilename, aMyFields, ! lInsert )
      ENDIF

   ELSEIF lExistFields .AND. lExistDatabase .AND. A1 != 'DatabaseName' .AND. A1 != 'WorkArea' .AND. A1 != 'DatabasePath'
      /* MsgInfo("EXIST Fields Value - Exist Database name and A1 != 'DatabaseName' and A1 !='WorkArea'","DEBUG MESSAGE") */
      cAlias                := aReturn[ 11 ]
      Form_fld.Text_1.Value := cFilename
      Form_fld.Text_2.Value := cAlias
      cFilename             := Imp_String( A1, A2, A3, A4, cFilename, cAlias, lMode ) /* MODIFY */

   ELSEIF lExistFields .AND. ! lExistAlias .AND. A1 == 'WorkArea'
      IF MsgYesNo( "WorkArea Name has been deleted " + CRLF + ;
                   "or manually changed" + CRLF + ;
                   " Try to recover it from 'Fields' ? ", "Recover WorkArea" )

         cAlias                := RCVR_WKA( MR_FSTR()[ 1 ], cFilename, A3 )
         Form_fld.Text_1.Value := cFilename
         Form_fld.Text_2.Value := cAlias

         Imp_String( A1, A2, A3, A4, cFilename, cAlias, lMode )
      ELSE
         EXIT_WND()
      ENDIF

   ELSEIF ! lExistFields .AND. ! lExistDatabase
      /* MsgInfo(" No Fields  - No Database name -Insert procedure","DEBUG MESSAGE") */
      cFilename := Check_fields( A1, A2, A3, A4, cFilename, aMyFields, lInsert )

   ELSEIF ! lExistFields .AND. lExistDatabase .AND. ( A1 == 'Fields' .OR. A1 == 'Widths' .OR. A1 == 'Headers' )
      /*  MsgInfo("! Fields  - Exist Database name","DEBUG MESSAGE") */
      cFilename             := aReturn[ 2 ]
      Form_fld.Text_1.Value := cFilename
      Form_fld.Text_2.Value := cAlias
      cFilename             := Check_fields( A1, A2, A3, A4, cFilename, aMyFields, ! lInsert )

   ELSEIF lExistDatabase .AND. A1 == 'WorkArea'
      IF ! lNewAlias
         cAlias                := aReturn[ 11 ]
         Form_fld.Text_1.Value := cFilename
         Form_fld.Text_2.Value := cAlias
         cFilename             := Imp_String( A1, A2, A3, A4, cFilename, cAlias, lMode ) /* MODIFY */

         MDFY_LS( cAlias, A3, NOT_SAVED )
      ELSE
         cFilename := Imp_String( A1, A2, A3, A4, cFilename, cAlias, lMode ) /* MODIFY */
      ENDIF

   ELSEIF lExistDatabase .AND. A1 == 'DatabasePath'
      ************************
      lExec := ctrl_path( A3 )
      IF lExec .OR. ! lExec      //? Why
      **********************
         aReturn               := MR_FSTR()              /* Read Value Stored in Browser Inspector */
         cFilename             := aReturn[ 2 ]
         cAlias                := aReturn[ 11 ]
         Form_fld.Text_1.Value := cFilename

         IF ! Empty( cAlias ) .AND. Upper( cAlias ) <> "NIL"
            Form_fld.Text_2.Value := cAlias
         ELSE
            Form_fld.Text_2.Value := ""
         ENDIF
         cFilename := Imp_String( A1, A2, A3, A4, cFilename, cAlias, lMode ) /* MODIFY */
      ENDIF

   ELSEIF ! lExistDatabase .AND. A1 == 'DatabasePath'
      ********************
      lExec := ! ( ctrl_path( A3 ) )

      IF  lExec .OR. ! lExec
         aReturn               := MR_FSTR()              /* Read Value Stored in Browser Inspector */
         cFilename             := aReturn[ 2 ]
         cAlias                := aReturn[ 11 ]
         Form_fld.Text_1.Value := cFilename

         IF ! Empty( cAlias ) .AND. Upper( cAlias ) <> "NIL"
            Form_fld.Text_2.Value := cAlias
         ELSE
            Form_fld.Text_2.Value := ""
         ENDIF
      ENDIF
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Strt_dBuild( cFilename AS STRING, cAlias AS STRING, A3 AS STRING, A4 AS STRING )
*------------------------------------------------------------*
   MW_FSTR( cFilename, cAlias, A3, A4 ) /* Write New database name and WorkArea in control */

   Movesx_AllField( A3 )            /* clear windows and set initial value */

   Ctrl_Envis_ONOFF( CTRL_OFF )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Ctrl_alias( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL lMode       AS LOGICAL := .T.
   LOCAL lExistAlias AS LOGICAL
   LOCAL cAlias      AS STRING  := ""
   LOCAL aPass       AS ARRAY   := {}
   LOCAL aReturn     AS ARRAY   := {}
   LOCAL cMessage    AS STRING  := ""
   LOCAL cText       AS STRING  := ""

   DECLARE WINDOW FORM_FLD

   aReturn     := MR_FSTR()                     /* Read Value Stored in Browser Inspector */
   lExistAlias := falias_ck( aReturn[ 11 ] )        /* .T. if WorkArea    Value in Browser is !Empty and !Upper("nil"), Value is Valid    */
   cText       := "Select WorkArea"

   IF lExistAlias
      cAlias   := aReturn[ 11 ]
      cMessage := "Select a New WorkArea ?"

   ELSEIF ! lExistAlias
      cMessage := "No WorkArea found - insert one ?"
   ENDIF

   IF MsgYesNo( cMessage, cText )
      cAlias := NSRT_LS( cAlias, A3, NOT_SAVED )
      IF Empty( cAlias ) .OR. Upper( cAlias ) == "NIL"
         cAlias := ""
         lMode  := .F.
      ENDIF
   ENDIF

   AAdd( aPass, lMode )
   AAdd( aPass, cAlias )

RETURN( aPass )


*------------------------------------------------------------*
FUNCTION Ctrl_path( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL lMode         AS LOGICAL := .T.
   LOCAL lExistDbPath  AS LOGICAL
   LOCAL cFilePath     AS STRING  := ""
   LOCAL cDatabasePath AS STRING  := ""
   LOCAL aReturn       AS ARRAY   := {}
   LOCAL cMessage      AS STRING  := ""
   LOCAL cText         AS STRING  := ""

   aReturn       := MR_FSTR()                                /* Read Value Stored in Browser Inspector */
   cFilePath     := aReturn[ 3 ] + "\" + aReturn[ 2 ] + ".dbf"
   cDatabasePath := aReturn[ 3 ]
   lExistDbPath  := fex_ck( cFilePath )                      /* .T. if DatabaseName value in Browser exist in the specified Path in Browser and is !Empty and !Upper("nil")     */

   IF lExistDbPath .AND.  A1 == 'DatabasePath'
      /* Here we can ask for a "Change Path ?" if need */
      cMessage := "Change DatabasePath ? "
      cText := "Change DatabasePath"

   ELSEIF ! lExistDbPath .AND. A1 == 'DatabasePath'
      /* Choiche a folder */
      cMessage := "Select a New Folder ? "
      cText := "Select a Folder"
   ENDIF

   IF MsgYesNo( cMessage, cText )
      cDatabasePath := GetFolder( "Select a Folder", cDatabasePath )

      IF ! Empty( cDatabasePath ) .AND. ! Upper( cDatabasePath ) == "NIL"
         sv_objfield( "DatabasePath", cDatabasePath, A3, NOT_SAVED, SAVED )
      ENDIF
   ELSE
      lMode := .F.
   ENDIF

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION Check_Fields( A1        AS STRING, ;
                       A2        AS STRING, ;
                       A3        AS STRING, ;
                       A4        AS STRING, ;
                       cFilename AS STRING, ;
                       aMyFields AS ARRAY,  ;
                       lInsert   AS LOGICAL ;
                     )
*------------------------------------------------------------*
   LOCAL cMessage      AS STRING  := ""
   LOCAL aReturn       AS ARRAY   := {}
   LOCAL aPass         AS ARRAY   := {}
   LOCAL cDatabasePath AS STRING  := ""
   LOCAL cAlias        AS STRING  := ""

   aPass := MR_FSTR()
   cDatabasePath := aPass[ 3 ]
   cAlias := aPass[ 11 ]

   IF ! Empty( cFilename ) .AND. Upper( cFilename ) <> "NIL"

      IF ! File( cDatabasePath + "\" + cFilename + ".dbf" )

         cMessage := "Selected Database Not Found ! Choose one ?"
         aReturn  := Choose_File( cFilename, aMyFields, cMessage, A3, A4, lInsert )

         IF ! Empty( aReturn )
            cFilename := aReturn[ 1 ]
            aMyFields := aReturn[ 2 ]
            cAlias    := aReturn[ 3 ]
         ELSE
            EXIT_WND()
         ENDIF
      ELSE
         aMyFields := Fill_wflds( cFilename, A3 )
      ENDIF

   ELSE    /* cFilename=="" .OR. NIL  */
      cMessage := "No Database Selected ! Choose one ?"
      aReturn  := Choose_File( cFilename, aMyFields, cMessage, A3, A4, lInsert )

      IF ! Empty( aReturn )
         cFilename := aReturn[ 1 ]
         aMyFields := aReturn[ 2 ]
         cAlias    := aReturn[ 3 ]
      ELSE
         EXIT_WND()
      ENDIF
   ENDIF

   Form_fld.List_2.DeleteAllitems
   Form_fld.List_1.DeleteAllitems

   AEval( aMyFields, { | x | Form_Fld.List_1.AddItem( x ) } )

RETURN( cFilename )


*------------------------------------------------------------*
FUNCTION choose_File( cFilename AS STRING, ;
                      aMyFields AS ARRAY,  ;
                      cMessage  AS STRING, ;
                      A3        AS STRING, ;
                      A4        AS STRING, ;
                      lInsert   AS LOGICAL ;
                    )
*------------------------------------------------------------*
   LOCAL aReturn AS ARRAY  := {}
   LOCAL aPass   AS ARRAY  := {}
   LOCAL cAlias  AS STRING := ""

   IF ! MsgYesNo( cMessage, "Warning" )
      RETURN nil /*  Exit */
   ELSE
      aPass     := ChooseFileVerify( A3, lInsert, DBFONLY )
      cFilename := aPass[ 1 ]

      IF Empty( cFilename )
         RETURN nil
      ELSE
         cAlias := aPass[ 2 ]
         aMyFields := fill_wflds( cFilename, A3 )
      ENDIF

   ENDIF

   AAdd( aReturn, cFilename )
   AAdd( aReturn, aMyFields )
   AAdd( aReturn, cAlias )

RETURN( aReturn )


*------------------------------------------------------------*
FUNCTION ChooseFileVerify( A3           AS STRING,  ;
                           lInsert      AS LOGICAL, ;
                           lChooseAlias AS LOGICAL  ;
                         )
*------------------------------------------------------------*
   LOCAL cFilename AS STRING := ""
   LOCAL cOlddir   AS STRING := GetCurrentFolder()
   lOCAL cAlias    AS STRING := ""
   LOCAL aPass     AS ARRAY  := {}
   LOCAL aReturn   AS ARRAY  := {}

   aReturn := MR_FSTR()

   IF ! Empty( aReturn[ 11 ] ) .AND. Upper( aReturn[ 11 ] ) <> "NIL"
      cAlias := aReturn[ 11 ] /* actual WorkArea */
   ENDIF

   IF ! lInsert
      cAlias := Form_fld.Text_2.Value
   ENDIF

   IF lChooseAlias = ALIASONLY
      cAlias := NSRT_LS( cAlias, A3, NOT_SAVED )

   ELSEIF lChooseAlias = DBFONLY
      cFilename := aReturn[ 2 ] /* actual Filename */
      aPass     := ChooseOnlyDbf( A3, cFilename )

      IF aPass[ 1 ]
         cFilename := aPass[ 2 ]
         StrdbfPath( cOldDir, A3 )

         Form_fld.List_2.DeleteAllitems
      ENDIF

   ELSEIF lChooseAlias = ALIASDBF
      cFilename := aReturn[ 2 ] /* actual Filename */
      aPass     := ChooseOnlyDbf( A3, cFilename )

      IF aPass[ 1 ]
         cFilename := aPass[ 2 ]
         StrdbfPath( cOldDir, A3 )
         Form_fld.List_2.DeleteAllitems
         cAlias := NSRT_LS( cAlias, A3, NOT_SAVED ) /* Change alias only if change database */
      ENDIF
   ENDIF

   aPass := {}
   AAdd( aPass, cFilename )
   AAdd( aPass, cAlias )

RETURN( aPass )


*------------------------------------------------------------*
FUNCTION NSRT_LS( cAlias AS STRING, ;
                  A3     AS STRING, ;
                  nMode  AS NUMERIC ;
                )
*------------------------------------------------------------*
   LOCAL cOldAlias AS STRING := cAlias

   SET EXACT ON
   /* Don't remove - Match fails when cAlias is a Sub string of cOldAlias !! */

   DECLARE WINDOW FORM_FLD

   IF ! Empty( cAlias ) .AND. Upper( cAlias ) <> "NIL"
      cAlias := InputBox( "Type the WorkArea Name for the selected *.dbf", "Input WorkArea Name", cAlias ,, )
   ELSE
      cAlias := InputBox( "Type the WorkArea Name for the selected *.dbf", "Input WorkArea Name",,, )
   ENDIF

   IF ! Empty( cAlias ) .AND. Upper( cAlias ) <> "NIL"
      IF AllTrim( cOldAlias ) <> AllTrim( cAlias )
         sv_objfield( "WorkArea", cAlias, A3, nMode, SAVED )
         Form_fld.Text_2.Value := cAlias
      ENDIF
   ELSE
      cAlias := ""
   ENDIF

   SET EXACT OFF

RETURN( cAlias )


*------------------------------------------------------------*
FUNCTION ChooseOnlyDbf( A3 AS STRING, cFilename AS STRING )
*------------------------------------------------------------*
   LOCAL cOldFileName AS STRING  := cFilename
   LOCAL lMode        AS LOGICAL := .F.
   LOCAL cOpen        AS STRING  := aData[ _DBFPATH ]

   cFilename := GetFile( { { '*.dbf', '*.dbf' } } , 'Open Database', copen )
   cFilename := StrTran( cFilename, GetCurrentFolder() + "\", "" )        /* .dbf File name without path */

   IF ! Empty( cFilename )
      cFilename             := SubStr( cFilename, 1, Len( cFilename ) - 4 ) /* delete *.DBF suffix in File name */
      Form_fld.Text_1.Value := cFilename

      sv_objfield( "DatabaseName", cFilename, A3, NOT_SAVED, SAVED )
      lMode             := .T.
      aData[ _DBFPATH ] := GetCurrentFolder()

      SavePreferences()
   ELSE
      cFilename := cOldFileName
   ENDIF

RETURN( { lMode, cFilename } )


*------------------------------------------------------------*
FUNCTION StrDbfPath( cOldDir AS STRING, A3 AS STRING )
*------------------------------------------------------------*
   LOCAL cDatabasePath AS STRING := GetCurrentFolder()

   sv_objfield( "DatabasePath", cDatabasePath, A3, NOT_SAVED, SAVED )

   SetCurrentFolder( cOldDir )

RETURN( nil )


*------------------------------------------------------------*
FUNCTION Fill_wFlds( cFilename AS STRING, A3 AS STRING )
*------------------------------------------------------------*
   LOCAL aMyFields AS ARRAY   := {}   /* Fields name array for pick-up list */
   LOCAL aStruct   AS ARRAY   := {}     /* dbf structure  array               */

   aStruct := Ret_Struct( cFilename, A3 )

   IF ! Empty( aStruct ) .AND. Len( aStruct ) > 0
      AEval( aStruct, { | aField | AAdd( aMyFields, aField[ DBS_NAME ] ) } )

      SaveStruct( A3, aStruct )
   ENDIF

RETURN( aMyFields )


*------------------------------------------------------------*
FUNCTION Ret_Widths( cFilename AS STRING, cFieldName AS STRING, A3 AS STRING )
*------------------------------------------------------------*
   LOCAL aStruct   AS ARRAY   := {}     /* dbf structure  array */
   LOCAL nMyWidths AS NUMERIC := 0
   LOCAL size      AS NUMERIC := 0
   LOCAL size1     AS NUMERIC := 0
   LOCAL cType     AS STRING  := ""
   LOCAL cMyName   AS STRING  := ""

   aStruct := Ret_struct( cFilename, A3 )

   IF ! Empty( aStruct ) .AND. Len( aStruct ) > 0
      AEval( aStruct, { | aField | iif( aField[ DBS_NAME ] == cFieldName, nMyWidths := aField[ DBS_LEN ] , nMyWidths ) } )
      AEval( aStruct, { | aField | iif( aField[ DBS_TYPE ] == "N"       , cType   := "N"             , cType     ) } )
      AEval( aStruct, { | aField | iif( aField[ DBS_NAME ] == cFieldName, cMyName := aField[ DBS_NAME ], cMyName   ) } )

      size      := Len( cMyName ) * 15
      size1     := iif( cMyName == aStruct[ 1, 1 ] .AND. cType == "N", nMyWidths * 15, nMyWidths * 10 )
      nMyWidths := iif( size < size1, size1, size )
   ENDIF

RETURN( nMyWidths )


*------------------------------------------------------------*
FUNCTION Ret_Struct( cFilename AS STRING, A3 AS STRING )
*------------------------------------------------------------*
   LOCAL aStruct         AS ARRAY   := {}     /* dbf structure  array */
   LOCAL aChoice         AS ARRAY   := {}
   LOCAL aReturn         AS ARRAY   := {}
   LOCAL cFilePath       AS STRING  := ""
   LOCAL lExistDbPath    AS LOGICAL := .F.
   LOCAL cDatabasePath   AS STRING  := ""
   LOCAL cAlias          AS STRING  := ""
   LOCAL nArea           AS NUMERIC := Select()
   LOCAL lExistStruct    AS LOGICAL

   aReturn         := MR_FSTR()                         /* Read Value Stored in Browser Inspector */
   cDatabasePath   := aReturn[ 3 ]
   cAlias          := aReturn[ 11 ]
   cFilePath       := aReturn[ 3 ] + "\" + aReturn[ 2 ] + ".dbf"
   lExistDbPath    := fex_ck( cFilePath )               /* .T. if DatabaseName value in Browser exist in the specified Path in Browser and is !Empty and !Upper("nil")     */

   IF Used()
      select ( cFilename )
      aStruct := dbStruct()
      close ( cFilename )

   ELSE

      IF ! lExistDbPath /* Database Path *not* in Browser */
         /* Is it Stored in *.ini file ? */
         cDatabasePath := LoadPath( A3 )

         IF ! Empty( cDatabasePath ) .AND. Upper( cDatabasePath ) <> "NIL"

            IF ! MsgYesNo( "DatabasePath not stored in Browser " + CRLF + "Load it from *.ini file ? ", "Loading Path from *.ini file" )
               cDatabasePath := ""
            ELSE
               lExistDbPath  := .T.
            ENDIF
         ELSE
            MsgInfo( "DatabasePath not found in <project>.ini file", "Unable Loading Path from <project>.ini file" )
         ENDIF
      ENDIF

      IF File( cDatabasePath + "\" + cFilename + ".dbf" ) .AND. lExistDbPath
         USE ( cDatabasePath + "\" + cFilename + ".dbf" ) NEW READONLY
         aStruct := dbStruct()
         use

      ELSE
         IF lExistStruct := fstrStruct_ck( A3 ) .AND. lExistDbPath    /* .T. if Stored dbStruct()  in *.ini file exist and is !Empty */
            aStruct := LoadStruct( A3 )

            IF Empty( cAlias ) .OR. Upper( cAlias ) == "NIL"
               aChoice := ctrl_alias( A3 )

               IF aChoice[ 1 ]  /* Exist Valid WorkArea */
                  dbCreate( cDatabasePath + "\" + cFilename, aStruct, "DBFNTX", .T., aChoice[ 2 ] )
               ELSE
                  dbCreate( cDatabasePath + "\" + cFilename, aStruct, "DBFNTX", .T., )
               ENDIF
               use
            ELSE
               dbCreate( cDatabasePath + "\" + cFilename, aStruct, "DBFNTX", .T., cAlias )
            ENDIF

         ELSEIF ! lExistStruct .AND. lExistDbPath   /* dbStruct() ! Exist */
            MsgInfo( "Unable to create File !" + CRLF + " dbStruct() not saved in *.INI file" + CRLF + "Procedure aborted !", "Create File" )
            aStruct := {}

         ELSEIF ! lExistStruct .AND. lExistDbPath   /* dbStruct() ! Exist */
            MsgInfo( "Unable to create File !" + CRLF + " DatabasePath not saved in *.INI file" + CRLF + "Procedure aborted !", "Create File" )
            aStruct := {}
         ENDIF
      ENDIF
   ENDIF

   Select( nArea )

RETURN( aStruct )


*------------------------------------------------------------*
FUNCTION Exp_String( A1        AS STRING, ;
                     A2        AS STRING, ;
                     A3        AS STRING, ;
                     A4        AS STRING, ;
                     aDownLoad AS ARRAY,  ;
                     lMes      AS LOGICAL ;
                   )
*------------------------------------------------------------*
   LOCAL OldValue          //? Unused
   LOCAL v1                //? Unused
   LOCAL x                 //? Unused
   LOCAL cMyWidths         AS STRING  := ""
   LOCAL cMyFields         AS STRING            // SL: was missing
   LOCAL cMyHeaders        AS STRING  := ""
   LOCAL cFilename         AS STRING  := ""
   LOCAL aReturn           AS ARRAY   := {}
   LOCAL lRet              AS LOGICAL := .T.
   LOCAL cMyPath           AS STRING  := ""
   LOCAL lMode             AS LOGICAL := .T.
   LOCAL cMyValid          AS STRING
   LOCAL cMyValidMessages  AS STRING
   LOCAL cImageNames       AS STRING
   LOCAL cReadOnlyValues   AS STRING
   LOCAL cMyJustifyValues  AS STRING
   LOCAL cWhen             AS STRING
   LOCAL cOnHeadClick      AS STRING
   LOCAL cAlias            AS STRING  := ""

   IF _lChngd
      cAlias           := Form_fld.Text_2.Value
      cFilename        := Form_fld.Text_1.Value
      A2               := Form_fld.Edit_1.Value
      cMyWidths        := Form_fld.Edit_2.Value
      cMyHeaders       := Form_fld.Edit_3.Value
      aReturn          := MR_FSTR()
      cMyPath          := aReturn[  3 ]
      cMyValid         := aReturn[  4 ]
      cMyValidMessages := aReturn[  5 ]
      cImageNames      := aReturn[  6 ]
      cReadOnlyValues  := aReturn[  7 ]
      cMyJustifyValues := aReturn[  8 ]
      cWhen            := aReturn[  9 ]
      cOnHeadClick     := aReturn[ 10 ]

      /* Flow control */

      IF lMes
         lRet := MsgYesNo( "Store DATA in Browse Control ?", "Save" )
      ENDIF

      IF lRet
         SV_ALL_FLDS( A1, A2, A3, A4, cFilename, cMyHeaders, cMyWidths, cMyPath, cMyValid, cMyValidMessages, cImageNames, cReadOnlyValues, cMyJustifyValues, cWhen, cOnHeadClick, cAlias, lMode )
         aDownLoad := SaveOld_FSTR( A1, A2, A3, A4 )
         /* array with actual value->became old value after SaveForm */

         Savepath( A3, cMyPath )

         SaveAlias( A3, cAlias )

         SaveDbfName( A3, cFilename )

         IF Form_fld.List_2.ItemCount <> 0

            Form_Fld.Button_5.Visible := .T.
            Form_Fld.Button_5.Enabled := .T.
         ELSE
            // When RESET button is pressed 'Headers' and 'Widths' Have to be "NIL" -
            cFilename        := aDownLoad[  1, 2 ]
            cMyHeaders       := "NIL"
            cMyWidths        := "NIL"
            cMyFields        := aDownLoad[  4, 2 ]
            cMyPath          := aDownLoad[  5, 2 ]
            cMyValid         := aDownLoad[  6, 2 ]
            cMyValidMessages := aDownLoad[  7, 2 ]
            cImageNames      := aDownLoad[  8, 2 ]
            cReadOnlyValues  := aDownLoad[  9, 2 ]
            cMyJustifyValues := aDownLoad[ 10, 2 ]
            cWhen            := aDownLoad[ 11, 2 ]
            cOnHeadClick     := aDownLoad[ 12, 2 ]
            cAlias           := aDownLoad[ 13, 2 ]

            SV_ALL_FLDS( A1, A2, A3, A4, cFilename, cMyHeaders, cMyWidths, cMyPath, cMyValid, ;
                         cMyValidMessages, cImageNames, cReadOnlyValues, cMyJustifyValues, ;
                         cWhen , cOnHeadClick, cAlias, lMode )

            aDownLoad := SaveOld_FStr( A1, A2, A3, A4 )

            /* array with actual value->became old value after SaveForm */
            /* Advanced Browse Setting Values HAVE TO BE ALL NIL when RESET button was pressed - */

            SV_ABS_ALLNIL( A3, lMode, A4 )

            Form_Fld.Button_5.Visible := .F.
            Form_Fld.Button_5.Enabled := .F.
         ENDIF

         _lChngd := .F.

      ELSE
         /*restore initial value when not saved !!!*/
         cFilename        := aDownLoad[  1, 2 ]
         cMyHeaders       := aDownLoad[  2, 2 ]
         cMyWidths        := aDownLoad[  3, 2 ]
         cMyFields        := aDownLoad[  4, 2 ]
         cMyPath          := aDownLoad[  5, 2 ]
         cMyValid         := aDownLoad[  6, 2 ]
         cMyValidMessages := aDownLoad[  7, 2 ]
         cImageNames      := aDownLoad[  8, 2 ]
         cReadOnlyValues  := aDownLoad[  9, 2 ]
         cMyJustifyValues := aDownLoad[ 10, 2 ]
         cWhen            := aDownLoad[ 11, 2 ]
         cOnHeadClick     := aDownLoad[ 12, 2 ]
         cAlias           := aDownLoad[ 13, 2 ]

         SV_ALL_FLDS( A1, A2, A3, A4, cFilename, cMyHeaders, cMyWidths, cMyPath, cMyValid, cMyValidMessages, ;
                      cImageNames, cReadOnlyValues, cMyJustifyValues, cWhen, cOnHeadClick, cAlias, lMode )

         aDownLoad := SAVEOLD_FSTR( A1, A2, A3, A4 )
         //EXIT_WND()
      ENDIF

      EXIT_WND()
      ObjectInspector.xGrid_1.Value := A4

      ObjectInspector.xGrid_1.SetFocus
   ENDIF

RETURN( aDownLoad )


*------------------------------------------------------------*
FUNCTION SV_Abs_AllNil( A3 AS STRING, lMode AS LOGICAL, A4 AS USUAL ) //? VarType
*------------------------------------------------------------*
   LOCAL aUpdate           AS ARRAY   := {}      //,aMessage:={}
   LOCAL x                 AS NUMERIC
   LOCAL v1                AS NUMERIC
   LOCAL OldValue          AS USUAL              //? VarType
   LOCAL nLen              AS NUMERIC := 0
   LOCAL i                 AS NUMERIC := 0
   LOCAL cMyValid          AS STRING  := "NIL"
   LOCAL cMyValidMessages  AS STRING  := "NIL"
   LOCAL cImageNames       AS STRING  := "NIL"
   LOCAL cReadOnlyValues   AS STRING  := "NIL"
   LOCAL cMyJustifyValues  AS STRING  := "NIL"
   LOCAL cWhen             AS STRING  := "NIL"
   LOCAL cOnHeadClick      AS STRING  := "NIL"

   aUpdate := { { "Valid"         , cMyValid          },;
                { "ValidMessages" , cMyValidMessages  },;
                { "Image"         , cImageNames       },;
                { "ReadOnlyFields", cReadOnlyValues   },;
                { "Justify"       , cMyJustifyValues  },;
                { "When"          , cWhen             } ;
              }

   nLen := Len( aUpdate )
   FOR i := 1 TO nLen
      oldvalue :=  ObjectInspector.xGrid_1.Value

      ObjectInspector.xGrid_1.DisableUpdate

      FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

         ObjectInspector.xGrid_1.Value := x
         v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

         IF v1 == aUpdate[ i, 1 ]
            SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ i, 2 ] )

            IF lMode
               SavePropControl( A3, aUpdate[ i, 2 ], v1 )
            ENDIF

            // MsgInfo( aMessage[ i, 2 ] + aUpdate[ i, 2 ], "Debug Message" )
         ENDIF
      NEXT x

      ObjectInspector.xGrid_1.Value := oldvalue  /* riposiziona la condizione iniziale */
      ObjectInspector.xGrid_1.EnableUpdate

   NEXT i

   aUpdate := { { "OnHeadClick", cOnHeadClick } }
   nLen    := Len( aUpdate )

   ObjectInspector.xGrid_2.DisableUpdate

   FOR i := 1 TO nLen

       oldvalue := ObjectInspector.xGrid_2.Value

       FOR x := 1 TO ObjectInspector.xGrid_2.ItemCount

           ObjectInspector.xGrid_2.Value := x
           v1                            := GetColValue( "XGRID_2", "ObjectInspector", 1 )

           IF v1 == aUpdate[ i, 1 ]
              SetColValue( "XGRID_2", "ObjectInspector", 2, aUpdate[ i, 2 ] )
              IF lMode
                 SavePropControl( A3, aUpdate[ i, 2 ], v1 )
              ENDIF
              /*  MsgInfo(aMessage[i][2]+aUpdate[i][2],"Debug Message") */
           ENDIF
       NEXT x

       ObjectInspector.xGrid_2.Value := oldvalue  /* riposiziona la condizione iniziale */

    NEXT i

    ObjectInspector.xGrid_2.EnableUpdate

    ObjectInspector.xGrid_1.Value := A4
    ObjectInspector.xGrid_1.SetFocus

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION SV_ALL_FLDS(                               ;
                      A1               AS STRING,   ; //
                      A2               AS STRING,   ; //
                      A3               AS STRING,   ; //
                      A4               AS STRING,   ; //
                      cFilename        AS STRING,   ; //
                      cMyHeaders       AS STRING,   ; //
                      cMyWidths        AS STRING,   ; //
                      cMyPath          AS STRING,   ; //
                      cMyValid         AS STRING,   ; //
                      cMyValidMessages AS STRING,   ; //
                      cImageNames      AS STRING,   ; //
                      cReadOnlyValues  AS STRING,   ; //
                      cMyJustifyValues AS STRING,   ; //
                      cWhen            AS STRING,   ; //
                      cOnHeadClick     AS STRING,   ; //
                      cAlias           AS STRING,   ; //
                      lMode            AS LOGICAL   ; //
                    )
*------------------------------------------------------------*
   LOCAL aUpdate   AS ARRAY   := {}
   LOCAL x         AS NUMERIC
   LOCAL v1        AS NUMERIC
   LOCAL oldvalue  AS USUAL           //? VarType
   LOCAL nLen      AS NUMERIC := 0
   LOCAL i         AS NUMERIC := 0

   IF lMode
      aUpdate := { { "DatabaseName"  , cFilename         },;
                   { "Headers"       , cMyHeaders        },;
                   { "Widths"        , cMyWidths         },;
                   { "Fields"        , A2                },;
                   { "DatabasePath"  , cMyPath           },;
                   { "Valid"         , cMyValid          },;
                   { "ValidMessages" , cMyValidMessages  },;
                   { "Image"         , cImageNames       },;
                   { "ReadOnlyFields", cReadOnlyValues   },;
                   { "Justify"       , cMyJustifyValues  },;
                   { "When"          , cWhen             },;
                   { "WorkArea"      , cAlias            } ;
                 }
   ELSE
      aUpdate := { { "DatabaseName", cFilename }, { "WorkArea", cAlias } }
   ENDIF

   _EnableListViewUpdate( 'XGRID_1', 'ObjectInspector', .F. )

   nLen := Len( aUpdate )
   FOR i := 1 TO nLen

       oldvalue := ObjectInspector.xGrid_1.Value

       FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

          ObjectInspector.xGrid_1.Value := x
          v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

          IF v1 == aUpdate[ i, 1 ]
             SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ i, 2 ] )

             SavePropControl( A3, aUpdate[ i, 2 ], v1 )

          ENDIF

       NEXT x

       ObjectInspector.xGrid_1.Value := oldvalue  /* Initial Value */

   NEXT I

   _EnableListViewUpdate( "XGRID_1", "ObjectInspector", .T. )

   aUpdate := { { "OnHeadClick", cOnHeadClick } }
   nLen    := Len( aUpdate )

   ObjectInspector.xGrid_2.DisableUpdate

   FOR i := 1 TO nLen

       OldValue := ObjectInspector.xGrid_2.Value

       FOR x := 1 TO ObjectInspector.xGrid_2.ItemCount

           ObjectInspector.xGrid_2.Value := x
           v1                            := GetColValue( "XGRID_2", "ObjectInspector", 1 )

           IF v1 == aUpdate[ i, 1 ]

              SetColValue( "XGRID_2", "ObjectInspector", 2, aUpdate[ i, 2 ] )

              IF lMode
                 SavePropControl( A3, aUpdate[ i, 2 ], v1 )
              ENDIF
           ENDIF

       NEXT x

       ObjectInspector.xGrid_2.Value := oldvalue  /* Initial Value */

   NEXT I

   ObjectInspector.xGrid_2.EnableUpdate
   ObjectInspector.xGrid_1.Value := A4
   ObjectInspector.xGrid_1.SetFocus

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION MoveDx_Field( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL Value       AS NUMERIC := 0
   LOCAL nVal        AS NUMERIC := 0
   LOCAL oldval      AS STRING  := ""
   LOCAL nNewVal     AS NUMERIC := - 1
   LOCAL cFilename   AS STRING  := ""

   _lChngd := .T.

   IF ! Empty( Form_fld.Text_2.Value )
      cFilename := AllTrim( Form_fld.Text_2.Value )
   ELSE
      cFilename := AllTrim( Form_fld.Text_1.Value )
   ENDIF

   Value  := Form_fld.List_1.Value
   oldval := Form_fld.List_1.Item( Value )

   Form_fld.List_1.DeleteItem( Value )

   nNewVal := Form_fld.List_1.ItemCount

   IF Value <= nNewVal
      Form_Fld.List_1.Value := Value
   ENDIF

   IF Value > nNewVal
      Form_Fld.List_1.Value := nNewVal
   ENDIF

   nVal := Form_fld.List_2.ItemCount + 1

   Form_fld.List_2.AddItem( oldval )

   Form_fld.List_2.Value     := nVal
   Form_fld.Button_1.Enabled := .T.
   Form_fld.Button_2.Enabled := .T.
   Form_fld.Button_4.Enabled := .T.

   What_Field( A3 )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION MoveSx_Field( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL Value       AS NUMERIC := 0
   LOCAL nVal        AS NUMERIC := 0
   LOCAL oldval      AS STRING  := ""
   LOCAL nNewVal     AS NUMERIC := - 1
   LOCAL cFilename   AS STRING  := ""

   _lChngd := .T.

   IF ! Empty( Form_fld.Text_2.Value )
      cFilename := AllTrim( Form_fld.Text_2.Value )
   ELSE
      cFilename := AllTrim( Form_fld.Text_1.Value )
   ENDIF

   Value  := Form_fld.List_2.Value
   oldval := Form_fld.List_2.Item( Value )

   Form_fld.List_2.DeleteItem( Value )

   nNewVal := Form_fld.List_2.ItemCount

   IF Value <= nNewVal
      Form_Fld.List_2.Value := Value
   ENDIF

   IF Value > nNewVal
      Form_Fld.List_2.Value := nNewVal
   ENDIF

   nVal := Form_fld.List_1.ItemCount + 1
   Form_fld.List_1.AddItem( oldval )
   Form_fld.List_1.Value := nVal

   What_Field( A3 )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION MoveSx_AllField( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL aMyFields AS ARRAY  := {}
   LOCAL aMyWidths AS ARRAY  := {}
   LOCAL cFilename AS STRING := ""

   _lChngd := .T.

   IF ! Empty( Form_fld.Text_2.Value )
      cFilename := AllTrim( Form_fld.Text_2.Value )
   ELSE
      cFilename := AllTrim( Form_fld.Text_1.Value )
   ENDIF

   Form_fld.List_2.DeleteAllitems
   Form_fld.List_1.DeleteAllitems

   aMyFields := fill_wflds( Form_fld.Text_1.Value, A3 )

   AEval( aMyFields, { | x | Form_Fld.List_1.AddItem( x ) } )

   What_Field( A3 )

   Form_fld.Button_1.Enabled := .F.

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION MoveDx_AllField( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL aMyFields AS ARRAY  := {}
   LOCAL aMyWidths AS ARRAY  := {}
   LOCAL cFilename AS STRING := ""

   _lChngd := .T.

   IF ! Empty( Form_fld.Text_2.Value )
      cFilename := AllTrim( Form_fld.Text_2.Value )
   ELSE
      cFilename := AllTrim( Form_fld.Text_1.Value )
   ENDIF

   Form_fld.List_2.DeleteAllitems
   Form_fld.List_1.DeleteAllitems

   aMyFields := fill_wflds( Form_fld.Text_1.Value, A3 )

   AEval( aMyFields, { | x | Form_Fld.List_2.AddItem( x ) } )

   What_Field( A3 )

   Form_fld.Button_4.Enabled := .F.

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION What_Field( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL nLen        AS NUMERIC := Form_fld.List_2.ItemCount
   LOCAL cFilename   AS STRING  := ""
   LOCAL aFieldName  AS ARRAY   := {}
   LOCAL aFieldValue AS ARRAY   := {}
   LOCAL i           AS NUMERIC

   DECLARE WINDOW Form_fld

   IF ! Empty( Form_fld.Text_2.Value ) .AND.  Upper( Form_fld.Text_2.Value ) <> "NIL"
      cFilename := AllTrim( Form_fld.Text_2.Value )
   ELSE
      cFilename := AllTrim( Form_fld.Text_1.Value )
   ENDIF

   Form_fld.Edit_1.Value := ""

   /* Added 27/12/2007 */
   Form_fld.Edit_2.Value := ""
   Form_fld.Edit_3.Value := ""

   IF nLen <> 0
      Ctrl_Envis_OnOff( CTRL_ON )
   ELSE
      Ctrl_Envis_OnOff( CTRL_OFF )
   ENDIF

   FOR i := 1 TO nLen
       IF i = 1
          Form_fld.Edit_1.Value := "{"
          Form_fld.Edit_2.Value := "{"
          Form_fld.Edit_3.Value := "{"
       ENDIF

       IF i <> nLen
          Form_fld.Edit_1.Value := Form_fld.Edit_1.Value + "'" + cFilename + "->" + Form_fld.List_2.Item( i ) + "'" + ","
          Form_fld.Edit_2.Value := Form_fld.Edit_2.Value + AllTrim( Str( ret_Widths( AllTrim( Form_fld.Text_1.Value ), Form_fld.List_2.Item( i ), A3 ) ) ) + ","
          Form_fld.Edit_3.Value := Form_fld.Edit_3.Value + "'" + Form_fld.List_2.Item( i ) + "'" + ","
       ELSE
          Form_fld.Edit_1.Value := Form_fld.Edit_1.Value + "'" + cFilename + "->" + Form_fld.List_2.Item( i ) + "'" + "}"
          Form_fld.Edit_2.Value := Form_fld.Edit_2.Value + AllTrim( Str( ret_Widths( AllTrim( Form_fld.Text_1.Value ), Form_fld.List_2.Item( i ), A3 ) ) ) + "}"
          Form_fld.Edit_3.Value := Form_fld.Edit_3.Value + "'" + Form_fld.List_2.Item( i ) + "'" + "}"
       ENDIF
   NEXT i

   aFieldName  := { "Fields", "Widths", "Headers" }
   aFieldValue := { Form_fld.Edit_1.Value, Form_fld.Edit_2.Value, Form_fld.Edit_3.Value }

   sv_objfield( aFieldName, aFieldValue, A3, NOT_SAVED, NOT_SAVED )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Imp_String(                         ; //
                     A1          AS STRING,  ; //
                     A2          AS STRING,  ; //
                     A3          AS STRING,  ; //
                     A4          AS STRING,  ; //
                     cFilename   AS STRING,  ; //
                     cAlias      AS STRING,  ; //
                     lMode       AS LOGICAL  ; //
                   )
*------------------------------------------------------------*
   LOCAL OldValue       AS USUAL            //? VarType
   LOCAL v1             AS STRING
   LOCAL x              AS NUMERIC
   LOCAL aStructFields  AS ARRAY   := {}
   LOCAL nLenAstruct    AS NUMERIC := 0
   LOCAL aReturn        AS ARRAY   := {}
   LOCAL nLen           AS NUMERIC
   LOCAL cSTRING        AS STRING  := ""
   LOCAL cNewString     AS STRING  := ""
   LOCAL aMyFields      AS ARRAY   := {}
   LOCAL cMyString      AS STRING  := ""
   LOCAL cWorkArea      AS STRING  := ""
   LOCAL i              AS NUMERIC
   LOCAL k              AS NUMERIC

   DECLARE WINDOW FORM_FLD

   FORM_FLD.SetFocus

   IF A1 = "Widths"        .OR. ;
      A1 = "Headers"       .OR. ;
      A1 = "DatabaseName"  .OR. ;
      A1 = "WorkArea"      .OR. ;
      A1 = "DatabasePath"

      cMyString := MR_FSTR()[ 1 ]  /* Read 'Fields' Value String */
   ELSE
      cMyString := A2
      /* MsgInfo(cMystring + "Len: "+AllTrim(Str(Len(cMystring))),"A2") */
   ENDIF

   IF ! Empty ( cMyString ) .AND. Upper( cMyString ) <> "NIL" .AND. cMyString <> "{''}"

      cWorkArea := SubStr( cMyString, 3, At( "->", cMyString ) - 1 )
      cSTRING   := AtRepl( cWorkArea, cMyString, "" )
      cSTRING   := AtRepl( "{", cSTRING, "" )
      cSTRING   := AtRepl( "}", cSTRING, "" )
      cSTRING   := AtRepl( "'", cSTRING, "" )
      nLen      := Len( cSTRING )

      FOR i := 1 TO nLen
          IF SubStr( cSTRING, i, 1 ) <> ","
             cNewString := cNewString + SubStr( cSTRING, i, 1 )
          ELSE
             AAdd( aReturn, cNewString )
             cNewString := ""
          ENDIF
      NEXT i
      AAdd( aReturn, cNewString )
      aMyFields := aReturn
   ENDIF

   IF ! Empty( cFilename ) .AND. Upper( cFilename ) <> "NIL"
      aStructFields := fill_wflds( cFilename, A3 )
      IF ! Empty( aStructFields )
         nLenAstruct := Len( aStructFields )
         FOR i := 1 TO Len( aReturn )
             FOR k := 1 to nLenAstruct
                IF aStructFields[ k ] == SubStr( aReturn[ i ], ( ( RAt( ">", aReturn[ i ] ) ) - Len( aReturn[ i ] ) ) )
                   ADel( aStructFields, k )
                   nLenAstruct := nLenAstruct - 1
                   ASize( aStructFields, nLenAstruct )
                ENDIF
             next k
         NEXT i
      ELSE
         Exit_Wnd()
         RETURN( NIL )
      ENDIF

      IF lMode
         ctrl_envis_ONOFF( CTRL_ON )
      ELSE
         ctrl_envis_ONOFF( CTRL_OFF )
      ENDIF

      Form_fld.List_1.DeleteAllitems

      AEval( aStructFields, { | x | Form_Fld.List_1.AddItem( x ) } )

      Form_fld.List_2.DeleteAllitems

      AEval( aMyFields, { | x | Form_Fld.List_2.AddItem( x ) } )

      OldValue := ObjectInspector.xGrid_1.Value

      FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

         ObjectInspector.xGrid_1.Value := x
         v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

         IF v1 = 'Fields'
            Form_fld.Edit_1.Value := GetColValue( "XGRID_1", "ObjectInspector", 2 )

         ELSEIF v1 =  'Widths'
            Form_fld.Edit_2.Value := GetColValue( "XGRID_1", "ObjectInspector", 2 )

         ELSEIF v1 = 'Headers'
            Form_fld.Edit_3.Value := GetColValue( "XGRID_1", "ObjectInspector", 2 )
         ENDIF

      NEXT x

      ObjectInspector.xGrid_1.Value := OldValue                      /* riposiziona la condizione iniziale */
      OldValue                      := ObjectInspector.xGrid_1.Value
      ObjectInspector.xGrid_1.Value := A4

      ObjectInspector.xGrid_1.SetFocus
   ELSE
      /* We Need to delete cDatabasePath from <*.ini> file */
      SavePath( A3, "" )
   ENDIF

RETURN( cFilename )


*------------------------------------------------------------*
FUNCTION MR_FSTR()
*------------------------------------------------------------*
   /* Read Stored Value in ObjectInspector and RETURN an array of string value */
   /* for actual 'Fields', 'DatabaseName', 'DatabasePath','Valid','ValidMessages' */
   /* 'Image','ReadOnlyFields','Justify','When','OnHeadClick','WorkArea'         */

   LOCAL cMyString        AS STRING  := ""
   LOCAL x                AS NUMERIC
   LOCAL v1               AS STRING
   LOCAL oldvalue         AS USUAL           //? VarType
   LOCAL cFilename        AS STRING
   LOCAL aReturn          AS ARRAY   := {}
   LOCAL cDatabasePath    AS STRING  := ""
   LOCAL cMyValid         AS STRING
   LOCAL cMyValidMessages AS STRING
   LOCAL cImageNames      AS STRING
   LOCAL cReadOnlyValues  AS STRING
   LOCAL cMyJustifyValues AS STRING
   LOCAL cWhen            AS STRING
   LOCAL cOnHeadClick     AS STRING
   LOCAL cAlias           AS STRING  := ""

   OldValue := ObjectInspector.xGrid_1.Value  /* Save Initial Value */

   FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

       ObjectInspector.xGrid_1.Value := x
       v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

       DO CASE
          CASE v1 == 'Fields'         ; cMyString         := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'DatabaseName'   ; cFilename         := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'DatabasePath'   ; cDatabasePath     := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'Valid'          ; cMyValid          := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'ValidMessages'  ; cMyValidMessages  := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'Image'          ; cImageNames       := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'ReadOnlyFields' ; cReadOnlyValues   := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'Justify'        ; cMyJustifyValues  := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'When'           ; cWhen             := GetColValue( "XGRID_1", "ObjectInspector", 2 )
          CASE v1 == 'WorkArea'       ; cAlias            := GetColValue( "XGRID_1", "ObjectInspector", 2 )
       ENDCASE

   NEXT x

   ObjectInspector.xGrid_1.Value := OldValue                       /* Restore Initial Value */

   OldValue                      := ObjectInspector.xGrid_2.Value  /* Save Initial Value */

   FOR x := 1 TO ObjectInspector.xGrid_2.ItemCount
       ObjectInspector.xGrid_2.Value := x
       v1 := GetColValue( "XGRID_2", "ObjectInspector", 1 )
       IF v1 == 'OnHeadClick'
          cOnHeadClick := GetColValue( "XGRID_2", "ObjectInspector", 2 )
       ENDIF
   NEXT x

   ObjectInspector.xGrid_2.Value := OldValue  /* Restore Initial Value */

   AAdd( aReturn, cMyString        )
   AAdd( aReturn, cFilename        )
   AAdd( aReturn, cDatabasePath    )
   AAdd( aReturn, cMyValid         )
   AAdd( aReturn, cMyValidMessages )
   AAdd( aReturn, cImageNames      )
   AAdd( aReturn, cReadOnlyValues  )
   AAdd( aReturn, cMyJustifyValues )
   AAdd( aReturn, cWhen            )
   AAdd( aReturn, cOnHeadClick     )
   AAdd( aReturn, cAlias           )

RETURN( aReturn )


*------------------------------------------------------------*
FUNCTION fField_ck( cFieldString AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF Empty( cFieldString ) .OR. cFieldString == "{''}"
      lMode := .F.
   ENDIF

   /* lMode is .F. ONLY if cFieldString IS empty or if cFieldString== "{''}" */
RETURN( lMode )


*------------------------------------------------------------*
FUNCTION fname_ck( cWorkAreaName AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF ( Upper( cWorkAreaName ) == "NIL" .OR.  Empty( cWorkAreaName ) )
      lMode := .F.
   ENDIF
   /* lMode is .F. if cWorkAreaName is Empty .OR. Nil */

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION fex_ck( cFilePath AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF ! File( cFilePath )
      lMode := .F.
   ENDIF
   /* lMode is .F. ONLY if *.dbf not exist in the specified Path in Browser OR *.INI */

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION falias_ck( cAlias AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF Empty( cAlias ) .OR. Upper( cAlias ) == "NIL"
      lMode := .F.
   ENDIF

   /* lMode is .T. ONLY if WorkArea in Browser exist */

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION fstralias_ck( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF Empty( LoadAlias( A3 ) ) .OR. ( Upper( LoadAlias( A3 ) ) == "NIL" )
      lMode := .F.
   ENDIF
   /* lMode is .F. ONLY if Stored WorkArea in *.ini file is empty or nil */

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION fstrPath_ck( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF Empty( LoadPath( A3 ) ) .OR. ( Upper( LoadPath( A3 ) ) == "NIL" )
      lMode := .F.
   ENDIF
   /* lMode is .F. ONLY if Stored Path in *.ini file IS empty or nil */

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION fstrDbName_ck( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF Empty( lddbfname( A3 ) ) .OR. ( Upper( lddbfname( A3 ) ) == "NIL" )
      lMode := .F.
   ENDIF
   /* lMode is .F. ONLY if Stored *.DBF name in *.ini file IS empty or nil */

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION fstrStruct_ck( A3 AS STRING )
*------------------------------------------------------------*
   LOCAL lMode AS LOGICAL := .T.

   IF Empty( LoadStruct( A3 ) )
      lMode := .F.
   ENDIF
   /* lMode is .F. ONLY if Stored DBStruct in *.ini file IS empty */

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION MW_FSTR( cFilename AS STRING, cAlias AS STRING, A3 AS STRING, A4 AS STRING )
*------------------------------------------------------------*
   LOCAL aFieldName  AS ARRAY := { "DatabaseName", "Headers", "Widths", "Fields", "WorkArea" }
   LOCAL aFieldValue AS ARRAY := { cFilename     , " "      , " "     , " "     , cAlias     }

   SV_ObjField( aFieldName, aFieldValue, A3, NOT_SAVED, SAVED )

   SV_Abs_AllNil( A3, NOT_SAVED, A4 )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION sv_objfield( uFieldName  AS USUAL,   ; //
                      uFieldValue AS USUAL,   ; //
                      A3          AS STRING,  ; //
                      lSaved      AS LOGICAL, ; //
                      lChanged    AS LOGICAL  ; //
                    )
*------------------------------------------------------------*
   /* IF lSaved = .T. cField value in Object Inspector is saved in *.fmg otherwise not */
   LOCAL aUpdate  AS ARRAY   := {}
   LOCAL aField   AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS STRING
   LOCAL oldvalue AS USUAL          //? VarType
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0
   LOCAL nLen1    AS NUMERIC := 0

   IF ValType( uFieldName ) == "C"  /* Single String */
      AAdd( aField , uFieldName  )
      AAdd( aField , uFieldValue )
      AAdd( aUpdate, aField      )
      aField := {}

   ELSEIF ValType( uFieldName ) == "A" .AND. ValType( uFieldValue ) == "A"
      nLen  := Len( uFieldName )
      nLen1 := Len( uFieldValue )
      IF nLen = nLen1
         FOR i := 1 TO nLen
            AAdd( aField, uFieldName[ I ] )
            AAdd( aField, uFieldValue[ I ] )
            AAdd( aUpdate, aField )
            aField := {}
         next I
      ELSE
         MsgStop( "Array 'uFieldName' lenght "           + CRLF + ;
                  "not equal Array 'uFieldName' lenght"  + CRLF + ;
                  "Program Aborted !", "Debug Message" )
         RETURN nil
      ENDIF

   ELSE
      /* Strong Parameter type - error -    */
      MsgStop( "Strong type 'uFieldName'Parameter" + CRLF + ;
               "Or Missing 'uFieldName' Parameter" + CRLF + ;
               "Program Aborted !", "Debug Message" )
      RETURN nil
   ENDIF

   //i    := 0
   //nLen := 0
   nLen := Len( aUpdate )

   FOR i := 1 TO nLen

      oldvalue := ObjectInspector.xGrid_1.Value

      FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

         ObjectInspector.xGrid_1.Value := x
         v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

         IF v1 = aUpdate[ i, 1 ]
            SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ I, 2 ] )

            IF lChanged                                .AND. ;
               ( aUpdate[ i, 1 ] == "DatabasePath"     .OR.  ;
                 aUpdate[ i, 1 ] == "WorkArea"         .OR.  ;
                 aUpdate[ i, 1 ] == "DatabaseName" )
               _lChngd := .T.
            ENDIF

            IF lSaved
               SavePropControl( A3, aUpdate[ I, 2 ], v1 )
            ENDIF
         ENDIF
      NEXT x

      ObjectInspector.xGrid_1.Value := OldValue  /* riposiziona la condizione iniziale */

   NEXT i

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Ctrl_Envis_OnOff( lMode AS LOGICAL )
*------------------------------------------------------------*
   DECLARE Form_Fld

   Form_fld.SetFocus
   Form_fld.Edit_1.Visible   := lMode
   Form_fld.Edit_2.Visible   := lMode
   Form_fld.Edit_3.Visible   := lMode
   Form_fld.Label_4.Visible  := lMode
   Form_fld.Label_5.Visible  := lMode
   Form_fld.Label_6.Visible  := lMode
   Form_Fld.Button_5.Visible := lMode
   Form_fld.Button_1.Enabled := lMode
   Form_fld.Button_4.Enabled := lMode

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RCVR_WKA( aMyField AS ARRAY, cFilename AS STRING, A3 AS STRING )
*------------------------------------------------------------*
   LOCAL nPos      AS NUMERIC
   LOCAL cWorkArea AS STRING  := ""
   LOCAL i         AS NUMERIC

   IF Len( aMyField ) <> 0
      FOR i := 1 TO Len( aMyField )
         IF SubStr( aMyField, i, 1 ) == ">"
            cWorkArea := Left( aMyField, I - 2 )
            EXIT
         ENDIF
      NEXT i
   ENDIF

   cWorkArea := AllTrim( AtRepl( "{'", cWorkArea, " " ) )

   IF AllTrim( cWorkArea ) == AllTrim( cFilename )
      cWorkArea := ""
   ELSE
      sv_ObjField( "WorkArea", cWorkArea, A3, NOT_SAVED, NOT_SAVED )
   ENDIF

RETURN( cWorkArea )


*------------------------------------------------------------*
FUNCTION ST_CHNGD()
*------------------------------------------------------------*
   _lChngd := .T.
RETURN( NIL )


*------------------------------------------------------------*
FUNCTION AskForExit( A1        AS STRING, ; //
                     A2        AS STRING, ; //
                     A3        AS STRING, ; //
                     A4        AS STRING, ; //
                     aDownLoad AS ARRAY   ; //
                   )
*------------------------------------------------------------*
   LOCAL cFilename         AS STRING
   LOCAL cMyWidths         AS STRING
   LOCAL cMyHeaders        AS STRING
   LOCAL cMyFields         AS STRING
   LOCAL nChoice           AS NUMERIC
   LOCAL nHandle           AS NUMERIC
   LOCAL lMes              AS LOGICAL
   LOCAL lMode             AS LOGICAL
   LOCAL cMyPath           AS STRING
   LOCAL cMyValid          AS STRING
   LOCAL cMyValidMessages  AS STRING
   LOCAL cImageNames       AS STRING
   LOCAL cReadOnlyValues   AS STRING
   LOCAL cMyJustifyValues  AS STRING
   LOCAL cWhen             AS STRING
   LOCAL cOnHeadClick      AS STRING
   LOCAL cAlias            AS STRING

   IF _lChngd
      cFilename        := aDownLoad[ 1 ][ 2 ]
      cMyHeaders       := aDownLoad[ 2 ][ 2 ]
      cMyWidths        := aDownLoad[ 3 ][ 2 ]
      cMyFields        := aDownLoad[ 4 ][ 2 ]
      cMyPath          := aDownLoad[ 5 ][ 2 ]
      cMyValid         := aDownLoad[ 6 ][ 2 ]
      cMyValidMessages := aDownLoad[ 7 ][ 2 ]
      cImageNames      := aDownLoad[ 8 ][ 2 ]
      cReadOnlyValues  := aDownLoad[ 9 ][ 2 ]
      cMyJustifyValues := aDownLoad[ 10 ][ 2 ]
      cWhen            := aDownLoad[ 11 ][ 2 ]
      cOnHeadClick     := aDownLoad[ 12 ][ 2 ]
      cAlias           := aDownLoad[ 13 ][ 2 ]
      lMode            := .T.
      lMes             := .F.
      nChoice          := MsgYesNoCancel( "Save Changes?", "Exit" )

      DO CASE
         CASE nChoice = 1    /* Save Change and exit */
              aDownLoad := Exp_String( A1, A2, A3, A4, aDownLoad, lMes )
              SavePath( A3, cMyPath )
              SaveDbfName( A3, cFilename )
              SaveAlias( A3, cAlias )
              SaveForm()
              /* Save Form_1 only on EXIT  */
              /* Saveform() also Save Path of database stored in Object Inspector to <project>*.ini file */
              EXIT_WND()

         CASE nChoice = 0    /* Restore Old Value */
              /*
              MsgInfo( "Restoring Old Value ->"+CRLF+;
                       "Old DatabaseName : "+cFilename+CRLF+;
                       "Old Headers  : "+cMyHeaders+CRLF+;
                       "Old Widths   : "+cMyWidths+CRLF+;
                       "Old Fields   : "+cMyFields+CRLF+;
                       "Old DBPath   : "+cMyPath+CRLF+;
                       "Old Valid    : "+cMyValid+CRLF+;
                       "Old ValidMes : "+cMyValidMessages+CRLF+;
                       "Old ImageName: "+cImageNames+CRLF+;
                       "Old Justify  : "+cMyJustifyValues+CRLF+;
                       "Old When     : "+cWhen+CRLF+;
                       "Old OnHeadCl : "+cOnHeadClick+CRLF+;
                       "Old WorkArea : "+cAlias,"Debug Message" )
             */

             SV_ALL_FLDS( aDownLoad[ 4 ][ 1 ], aDownLoad[ 4 ][ 2 ], aDownLoad[ 16 ], aDownLoad[ 17 ], cFilename, cMyHeaders, cMyWidths, cMyPath, ;
                          cMyValid, cMyValidMessages, cImageNames, cReadOnlyValues, cMyJustifyValues, cWhen, cOnHeadClick, cAlias, lMode )

             aDownLoad := SAVEOLD_FSTR( aDownLoad[ 4 ][ 1 ], aDownLoad[ 4 ][ 2 ], aDownLoad[ 16 ], aDownLoad[ 17 ] )

             Imp_String( aDownLoad[ 4 ][ 1 ], aDownLoad[ 4 ][ 2 ], aDownLoad[ 16 ], aDownLoad[ 17 ], cFilename, cAlias, lMode )

             SavePath( A3, cMyPath )
             SaveDbfName( A3, cFilename )
             SaveAlias( A3, cAlias )

             Form_Fld.Button_5.Visible := .T.
             Form_Fld.Button_5.Enabled := .T.
             EXIT_WND()
      ENDCASE
   ELSE
      EXIT_WND()
   ENDIF

RETURN( aDownLoad )


*------------------------------------------------------------*
FUNCTION SaveOld_Fstr( A1 AS STRING, A2 AS STRING, A3 AS STRING, A4 AS STRING )
*------------------------------------------------------------*
   LOCAL aDownLoad      AS ARRAY   := {}
   LOCAL aTempDownLoad  AS ARRAY   := {}
   LOCAL x              AS NUMERIC
   LOCAL v1             AS USUAL              //? VarType
   LOCAL oldvalue       AS USUAL              //? VarType
   LOCAL nLen           AS NUMERIC := 0
   LOCAL i              AS NUMERIC := 0

   aDownLoad := { { "DatabaseName"  , "" },;
                  { "Headers"       , "" },;
                  { "Widths"        , "" },;
                  { "Fields"        , "" },;
                  { "DatabasePath"  , "" },;
                  { "Valid"         , "" },;
                  { "ValidMessages" , "" },;
                  { "Image"         , "" },;
                  { "ReadOnlyFields", "" },;
                  { "Justify"       , "" },;
                  { "When"          , "" } ;
                }

   DoMethod( "ObjectInspector", "XGRID_1", "DISABLEUPDATE" )

   nLen := Len( aDownLoad )
   FOR i := 1 TO nLen
       OldValue :=   ObjectInspector.xGrid_1.Value
       FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

           ObjectInspector.xGrid_1.Value := x
           v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

           IF v1 == aDownLoad[ i, 1 ]
              aDownLoad[ i, 2 ] := GetColValue( "XGRID_1", "ObjectInspector", 2 )
           ENDIF
       NEXT x
       ObjectInspector.xGrid_1.Value := OldValue  /* riposiziona la condizione iniziale */
   NEXT I

   DoMethod( "ObjectInspector", "XGRID_1", "ENABLEUPDATE" )

   aTempDownLoad := { { "OnHeadClick", "" } }
   nLen          := Len( aTempDownLoad )

   ObjectInspector.xGrid_2.DisableUpdate

   FOR i := 1 TO nLen

      oldvalue := ObjectInspector.xGrid_2.Value

      FOR x := 1 TO ObjectInspector.xGrid_2.ItemCount

          ObjectInspector.xGrid_2.Value := x
          v1                            := GetColValue( "XGRID_2", "ObjectInspector", 1 )

          IF v1 == aTempDownLoad[ i, 1 ]
             aTempDownLoad[ i, 2 ] := GetColValue( "XGRID_2", "ObjectInspector", 2 )
             AAdd( aDownLoad, { aTempDownLoad[ I ][ 1 ], aTempDownLoad[ i, 2 ] } )
          ENDIF
       NEXT x

      ObjectInspector.xGrid_2.Value := oldvalue  /* riposiziona la condizione iniziale */
      ObjectInspector.xGrid_2.EnableUpdate

   NEXT I

   aTempDownLoad := { { "WorkArea", "" } }
   nLen          := Len( aTempDownLoad )

   ObjectInspector.xGrid_1.DisableUpdate

   FOR i := 1 TO nLen

       OldValue :=   ObjectInspector.xGrid_1.Value

       FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

           ObjectInspector.xGrid_1.Value := x
           v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

           IF v1 == aTempDownLoad[ i, 1 ]
              aTempDownLoad[ i, 2 ] := GetColValue( "XGRID_1", "ObjectInspector", 2 )
              AAdd( aDownLoad, { aTempDownLoad[ i, 1 ], aTempDownLoad[ i, 2 ] } )
           ENDIF

       NEXT x

       ObjectInspector.xGrid_1.Value := OldValue  /* riposiziona la condizione iniziale */
       ObjectInspector.xGrid_1.EnableUpdate

   NEXT i

   AAdd( aDownLoad, A1 )
   AAdd( aDownLoad, A2 )
   AAdd( aDownLoad, A3 )
   AAdd( aDownLoad, A4 )

RETURN( aDownLoad )


*------------------------------------------------------------*
FUNCTION EXIT_WND()
*------------------------------------------------------------*
   _lChngd := .F.

   DECLARE WINDOW Form_Fld

   SET INTERACTIVECLOSE ON  /* I have had problem if omitted this code  */
   SET TOOLTIP BALLOON OFF

   RELEASE WINDOW Form_Fld

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION chk_ifCanLoad( A1        AS STRING, ; //
                        A2        AS STRING, ; //
                        A3        AS STRING, ; //
                        A4        AS STRING, ; //
                        aDownLoad AS ARRAY   ; //
                      )
*------------------------------------------------------------*
   LOCAL nLen           AS NUMERIC := 0
   LOCAL lExistFields   AS LOGICAL
   LOCAL lExistDatabase AS LOGICAL
   LOCAL i              AS NUMERIC := 0
   LOCAL aMyFields      AS ARRAY   := {}
   LOCAL aOldValues     AS ARRAY   := {}
   LOCAL aReturn        AS ARRAY   := {}
   LOCAL cString        AS STRING  := ""
   LOCAL lMode          AS LOGICAL := .F.
   LOCAL lMes           AS LOGICAL := .F.
   LOCAL aLdReturn      AS ARRAY   := {}

   aLdReturn      := MR_FSTR()                                /* Read Value Stored in Browser Inspector */
   lExistDatabase := fname_ck( aLdReturn[ 2 ] )               /* .T. if DatabaseName Value is !Empty , Value is Valid  */
   lExistFields   := ffield_ck( aLdReturn[ 1 ] )              /* .T. if Fields   Value is !Empty and valid */

   IF ! lExistFields .AND. ! lExistDatabase
      /*
      MsgStop("Advanced Browse Setting Window not available !         "+CRLF+;
              "Check 'DatabaseName' and 'Fields' value before to continue."+CRLF+;
              " ","DEBUG MESSAGE")
      */
      aDownLoad := Exp_String( A1, A2, A3, A4, aDownLoad, lMes )
   ENDIF

   nLen := Form_Fld.List_2.ItemCount

   Tst_fldfld( A3, nLen )

   Ctrl_InsFld( CTRL_OFF )

   FOR i := 1 TO nLen
       AAdd( aMyFields, Form_Fld.List_2.Item( i ) )
   NEXT i

   SET INTERACTIVECLOSE OFF
   SET TOOLTIPSTYLE BALLOON
   SET TOOLTIP BALLOON ON

   IF IsWindowDefined( BrwAdvanced )
      DECLARE WINDOW BrwAdvanced /* don't delete this line - otherwise an error occurs during compilation */
      BrwAdvanced.SetFocus
      RETURN NIL
   ELSE
      LOAD WINDOW BrwAdvanced
      SET TOOLTIP MAXWIDTH TO 600 OF BrwAdvanced
      SET TOOLTIP TEXTCOLOR TO YELLOW OF BrwAdvanced
      SET TOOLTIP BACKCOLOR TO BLACK OF BrwAdvanced
      SetToolTipFont ( GetFormToolTipHandle( "BrwAdvanced" ),, 20,,,,, 0 )
      ACTIVATE WINDOW BrwAdvanced
   ENDIF

   Ctrl_InsFld( CTRL_ON )

RETURN( aDownLoad )


*------------------------------------------------------------*
FUNCTION Tst_FldFld( A3 AS STRING, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL aMyValid         := ""   //? VarType
   LOCAL aMyValidMessages := ""
   LOCAL aImageNames      := ""
   LOCAL aReadOnlyValues  := ""
   LOCAL aMyJustifyValues := ""
   LOCAL aWhen            := ""
   LOCAL aOnHeadClick     := ""

   /* 'Valid' Stored !="NIL"  AND array lenght <> # of selected Field(s) -Need to be correct */
   IF ( ( ( Upper( xArray[ xControle( A3 ), 55 ] ) ) <> "NIL" ) .AND. ( Len( Strg_2_Array( xArray[ xControle( A3 ), 55 ] )[ 1 ] ) <> nLen )  )
      aMyValid := Strg_2_Array( xArray[ xControle( A3 ), 55 ] )
      Correct_Vld( A3, aMyValid, nLen )
   ENDIF

   /* 'ValidMessages' Stored !="NIL"  AND array lenght <> # of selected Field(s) -Need to be correct */
   IF ( ( Upper( ( xArray[ xControle( A3 ), 57 ] ) ) <> "NIL" ) .AND. ( Len( Strg_2_Array( xArray[ xControle( A3 ), 57 ] ) ) <> nLen ) )
      aMyValidMessages := Strg_2_Array( xArray[ xControle( A3 ), 57 ] )
      Correct_VldMsg( A3, aMyValidMessages, nLen )
   ENDIF

   /* 'ImageName' Stored !="NIL"  AND array lenght <> # of selected Field(s) -Need to be correct */
   IF ( ( Upper( ( xArray[ xControle( A3 ), 77 ] ) ) <> "NIL" ) .AND. ( Len( Strg_2_Array( xArray[ xControle( A3 ), 77 ] ) ) <> nLen ) )
      aImageNames := Strg_2_Array( xArray[ xControle( A3 ), 77 ] )
      Correct_ImageName( A3, aImageNames, nLen )
   ENDIF

   /* 'ReadOnlyFields' Stored !="NIL"  AND array lenght <> # of selected Field(s) -Need to be correct */
   IF ( ( Upper( ( xArray[ xControle( A3 ), 83 ] ) ) <> "NIL" ) .AND. ( Len( Strg_2_Array( xArray[ xControle( A3 ), 83 ] ) ) <> nLen ) )
      aReadOnlyValues := Strg_2_Array( xArray[ xControle( A3 ), 83 ] )
      Correct_RDOFLD( A3, aReadOnlyValues, nLen )
   ENDIF

   /* 'JustifyFields' Stored !="NIL"  AND array lenght <> # of selected Field(s) -Need to be correct */
   IF ( ( Upper( ( xArray[ xControle( A3 ), 79 ] ) ) <> "NIL" ) .AND. ( Len( Strg_2_Array( xArray[ xControle( A3 ), 79 ] ) ) <> nLen ) )
      aMyJustifyValues := Strg_2_Array( xArray[ xControle( A3 ), 79 ] )
      Correct_JstfyFlds( A3, aMyJustifyValues, nLen )
   ENDIF

   /* 'WhenFields' Stored !="NIL"  AND array lenght <> # of selected Field(s) -Need to be correct */
   IF ( ( Upper( ( xArray[ xControle( A3 ), 71 ] ) ) <> "NIL" ) .AND. ( Len( Strg_2_Array( xArray[ xControle( A3 ), 71 ] )[ 1 ] ) <> nLen ) )
      aWhen := Strg_2_Array( xArray[ xControle( A3 ), 71 ] )
      Correct_When( A3, aWhen, nLen )
   ENDIF

   /* 'OnHeadClick' Stored !="NIL"  AND array lenght <> # of selected Field(s) -Need to be correct */
   IF ( ( Upper( ( xArray[ xControle( A3 ), 49 ] ) ) <> "NIL" ) .AND. ( Len( Strg_2_Array( xArray[ xControle( A3 ), 49 ] )[ 1 ] ) <> nLen ) )
      aOnHeadClick := Strg_2_Array( xArray[ xControle( A3 ), 49 ] )
      Correct_OnHClk( A3, aOnHeadClick, nLen )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Correct_Vld( A3 AS STRING, aMyValid AS ARRAY, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL nStrLen  AS NUMERIC
   LOCAL nDiff    AS NUMERIC
   LOCAL i        AS NUMERIC := 0
   LOCAL cLast    AS STRING  := ""
   LOCAL nChoice  AS LOGICAL := .F.
   LOCAL cMyValid AS STRING  := "{"

   /*
   nChoice:=MsgYesNo("Advanced Browse Setting Window not available yet !    "+CRLF+;
                     "New record(s) were added or deleted in 'Browse Fields'"+CRLF+;
                     "To save stored value , correct lenght and loading     "+CRLF+;
                     "------------------------------------------------------"+CRLF+;
                     "new 'Valid' Field(s) with DEFAULT value click -> YES  "+CRLF+;
                     "new 'Valid' Field(s) with NIL     value click ->  NO  ","DEBUG Message")

   */

   /* ---------------Start Correct Array lenght 'Valid'----------------*/
   nStrLen := Len( aMyValid[ 1 ] )

   ASize( aMyValid[ 1 ], nLen )

   IF ( nLen > nStrLen )  /* New Field(s) added */
      nDiff := ( nLen - nStrLen )
      FOR i := 1 TO nDiff
          /* fill added fields with DEFAULT or NIL value*/
          IF nChoice
             aMyValid[ 1 ][ nStrLen + i ] := "{|| vcb" + AllTrim( Str( nStrLen + i ) ) + "}"
          ELSE
             aMyValid[ 1 ][ nStrLen + i ] := "{|| NIL }"
          ENDIF
      NEXT i
   ELSE        /* Field(s) erased -> array cutted */
   ENDIF

   /* Array -> String */
   FOR i := 1 TO nLen   /* Array to String  to save in Grid1 */
       iif( i = nLen, cLast := "}", cLast := "," )
       cMyValid := cMyValid + aMyValid[ 1, i ] + cLast
   NEXT i

   /* Save value valid */
   SV_VLD_FLDS( A3, cMyValid )

   /* ---------------End Correct Array lenght 'Valid'----------------*/

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Correct_VldMsg( A3 AS STRING, aMyValidMessages AS ARRAY, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL nStrLen          AS NUMERIC
   LOCAL nDiff            AS NUMERIC
   LOCAL i                AS NUMERIC := 0
   LOCAL cLast            AS STRING  := ""
   LOCAL nChoice          AS LOGICAL := .F.
   LOCAL cMyValidMessages AS STRING  := "{"

   /*
   nChoice:=MsgYesNo("Advanced Browse Setting Window not available yet !            "+CRLF+;
                     "New record(s) were added or deleted in 'Browse Fields'        "+CRLF+;
                     "To save stored value , correct lenght and loading             "+CRLF+;
                     "--------------------------------------------------------------"+CRLF+;
                     "new 'ValidMessages' Field(s) with DEFAULT value click -> YES  "+CRLF+;
                     "new 'ValidMessages' Field(s) with NIL     value click ->  NO  ","DEBUG Message")
   */

   /* ---------------Start Correct Array lenght 'ValidMessages'------*/

   nStrLen := Len( aMyValidMessages )

   ASize( aMyValidMessages, nLen )

   IF ( nLen > nStrLen )  /* New Field(s) added */
      nDiff := ( nLen - nStrLen )
      FOR i := 1 TO nDiff
         /* fill added fields with DEFAULT or NIL value*/
         IF nChoice
            aMyValidMessages[ nStrLen + i ] := "Text" + AllTrim( Str( nStrLen + i ) )
         ELSE
            aMyValidMessages[ nStrLen + i ] := "NIL"
         ENDIF
      NEXT i
   ELSE        /* Field(s) erased -> array cutted */
   ENDIF

   /* Array -> String */
   FOR i := 1 TO nLen   /* Array to String  to save in Grid1 */
       iif( i = nLen, cLast := "}", cLast := "," )
       cMyValidMessages := cMyValidMessages + aMyValidMessages[ i ] + cLast
    NEXT i

   /* Save value validMessages */
   SV_VLDMSG_FLDS( A3, cMyValidMessages )
   /* ---------------End Correct Array lenght 'ValidMessages'--------*/

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Correct_ImageName( A3 AS STRING, aImageNames AS ARRAY, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL nStrLen     AS NUMERIC
   LOCAL nDiff       AS NUMERIC
   LOCAL i           AS NUMERIC := 0
   LOCAL cLast       AS STRING  := ""
   LOCAL nChoice     AS LOGICAL := .F.
   LOCAL cImageNames AS STRING  := "{"

   /*
   nChoice:=MsgYesNo("Advanced Browse Setting Window not available yet !        "+CRLF+;
                     "New record(s) were added or deleted in 'Browse Fields'    "+CRLF+;
                     "To save stored value , correct lenght and loading         "+CRLF+;
                     "----------------------------------------------------------"+CRLF+;
                     "new 'ImageName' Field(s) with DEFAULT value click -> YES  "+CRLF+;
                     "new 'ImageName' Field(s) with NIL     value click ->  NO  ","DEBUG Message")
   */

   /* ---------------Start Correct Array lenght 'ImageNames'------*/
   nStrLen := Len( aImageNames )

   ASize( aImageNames, nLen )

   IF ( nLen > nStrLen )  /* New Field(s) added */
      nDiff := ( nLen - nStrLen )
      FOR i := 1 TO nDiff
          /* fill added fields with DEFAULT or NIL value*/
          IF nChoice
             aImageNames[ nStrLen + i ] := "ImgName" + AllTrim( Str( nStrLen + i ) )
          ELSE
             aImageNames[ nStrLen + i ] := "NIL"
          ENDIF
      NEXT i
   ELSE        /* Field(s) erased -> array cutted */
   ENDIF

   /* Array -> String */
   FOR i := 1 TO nLen   /* Array to String  to save in Grid1 */
       iif( i = nLen, cLast := "}", cLast := "," )
       cImageNames := cImageNames + aImageNames[ i ] + cLast
   NEXT i
   /* Save value 'ImageNames' */
   SV_IMG_FLDS( A3, cImageNames )
   /* ---------------End Correct Array lenght 'ImageNames'--------*/

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Correct_RDOFLD( A3 AS STRING, aReadOnlyValues AS ARRAY, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL nStrLen         AS NUMERIC
   LOCAL nDiff           AS NUMERIC
   LOCAL i               AS NUMERIC := 0
   LOCAL cLast           AS STRING  := ""
   LOCAL nChoice         AS LOGICAL := .F.
   LOCAL cReadOnlyValues AS STRING  := "{"
   /*
   nChoice:=MsgYesNo("Advanced Browse Setting Window not available yet !        "+CRLF+;
                     "New record(s) were added or deleted in 'Browse Fields'    "+CRLF+;
                     "To save stored value , correct lenght and loading         "+CRLF+;
                     "----------------------------------------------------------"+CRLF+;
                     "new 'ReadOnly' Field(s) with DEFAULT value click -> YES   "+CRLF+;
                     "new 'ReadOnly' Field(s) with NIL     value click ->  NO   ","DEBUG Message")
   */

   /* ---------------Start Correct Array lenght 'ReadOnlyValues'------*/

   nStrLen := Len( aReadOnlyValues )

   ASize( aReadOnlyValues, nLen )

   IF ( nLen > nStrLen )  /* New Field(s) added */
      nDiff := ( nLen - nStrLen )
      FOR i := 1 TO nDiff
         /* fill added fields with DEFAULT or NIL value*/
         IF nChoice
            aReadOnlyValues[ nStrLen + i ] := ".T."
         ELSE
            aReadOnlyValues[ nStrLen + i ] := "NIL"
         ENDIF
      next i
   ELSE        /* Field(s) erased -> array cutted */
   ENDIF

   /* Array -> String */
   FOR i := 1 TO nLen   /* Array to String  to save in Grid1 */
       iif( i = nLen, cLast := "}", cLast := "," )
       cReadOnlyValues := cReadOnlyValues + iif( aReadOnlyValues[ i ] = "NIL", "NIL", iif( aReadOnlyValues[ i ] = ".T.", ".T.", ".F." ) ) + cLast
   NEXT i

   /* Save value 'ReadOnlyValues' */
   SV_RDO_FLDS( A3, cReadOnlyValues )
   /* ---------------End Correct Array lenght 'ReadOnlyValues'--------*/

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Correct_JstfyFlds( A3 AS STRING, aMyJustifyValues AS ARRAY, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL nStrLen          AS NUMERIC
   LOCAL nDiff            AS NUMERIC
   LOCAL i                AS NUMERIC := 0
   LOCAL cLast            AS STRING  := ""
   LOCAL nChoice          AS LOGICAL := .F.
   LOCAL cMyJustifyValues AS STRING  := "{"

   /*
   nChoice:=MsgYesNo("Advanced Browse Setting Window not available yet !       "+CRLF+;
                     "New record(s) were added or deleted in 'Browse Fields'   "+CRLF+;
                     "To save stored value , correct lenght and loading        "+CRLF+;
                     "---------------------------------------------------------"+CRLF+;
                     "new 'Justify' Field(s) with DEFAULT value click -> YES   "+CRLF+;
                     "new 'Justify' Field(s) with NIL     value click ->  NO   ","DEBUG Message")
   */

   /* ---------------Start Correct Array lenght 'JustifyValues'------*/
   nStrLen := Len( aMyJustifyValues )

   ASize( aMyJustifyValues, nLen )

   IF ( nLen > nStrLen )  /* New Field(s) added */
      nDiff := ( nLen - nStrLen )
      For i = 1 to nDiff
          /* fill added fields with DEFAULT or NIL value*/
          IF nChoice
             aMyJustifyValues[ nStrLen + i ] := "BROWSE_JTFY_LEFT"
          ELSE
             aMyJustifyValues[ nStrLen + i ] := "NIL"
          ENDIF
      next i
   ELSE        /* Field(s) erased -> array cutted */
   ENDIF

   /* Array -> String */
   FOR i := 1 TO nLen   /* Array to String  to save in Grid1 */
       iif( i = nLen, cLast := "}", cLast := "," )
       cMyJustifyValues := cMyJustifyValues + aMyJustifyValues[ i ] + cLast
   NEXT i

   /* Save value 'JustifyValues' */
   SV_JFY_FLDS( A3, cMyJustifyValues )
   /* ---------------End Correct Array lenght 'JustifyValues'--------*/

RETURN( nil )


*------------------------------------------------------------*
FUNCTION Correct_When( A3 AS STRING, aWhen AS ARRAY, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL nStrLen  AS NUMERIC
   LOCAL nDiff    AS NUMERIC
   LOCAL i        AS NUMERIC := 0
   LOCAL cLast    AS STRING  := ""
   LOCAL nChoice  AS LOGICAL := .F.
   LOCAL cWhen    AS STRING  := "{"

   /*
   nChoice:=MsgYesNo("Advanced Browse Setting Window not available yet !    "+CRLF+;
                     "New record(s) were added or deleted in 'Browse Fields'"+CRLF+;
                     "To save stored value , correct lenght and loading     "+CRLF+;
                     "------------------------------------------------------"+CRLF+;
                     "new 'When' Field(s) with DEFAULT value click -> YES   "+CRLF+;
                     "new 'When' Field(s) with NIL     value click ->  NO   ","DEBUG Message")
   */

   /* ---------------Start Correct Array lenght 'When'----------------*/
   nStrLen := Len( aWhen[ 1 ] )

   ASize( aWhen[ 1 ], nLen )

   IF ( nLen > nStrLen )  /* New Field(s) added */
      nDiff := ( nLen - nStrLen )
      FOR i := 1 to nDiff
          /* fill added fields with DEFAULT or NIL value*/
          IF nChoice
             aWhen[ 1 ][ nStrLen + i ] := "{|| wcb" + AllTrim( Str( nStrLen + i ) ) + "}"
          ELSE
             aWhen[ 1 ][ nStrLen + i ] := "{|| NIL }"
          ENDIF
      NEXT i
   ELSE        /* Field(s) erased -> array cutted */
   ENDIF

   /* Array -> String */
   FOR i := 1 TO nLen   /* Array to String  to save in Grid1 */
       iif( i = nLen, cLast := "}", cLast := "," )
       cWhen := cWhen + aWhen[ 1 ][ i ] + cLast
   NEXT i

   /* Save value When */
   SV_WHEN_FLDS( A3, cWhen )
   /* ---------------End Correct Array lenght 'When'----------------*/

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Correct_OnHClk( A3 AS STRING, aOnHeadClick AS ARRAY, nLen AS NUMERIC )
*------------------------------------------------------------*
   LOCAL nStrLen      AS NUMERIC
   LOCAL nDiff        AS NUMERIC
   LOCAL i            AS NUMERIC := 0
   LOCAL cLast        AS STRING  := ""
   LOCAL nChoice      AS LOGICAL := .F.
   LOCAL cOnHeadClick AS STRING  := "{"

   /*
   nChoice:=MsgYesNo("Advanced Browse Setting Window not available yet !           "+CRLF+;
                     "New record(s) were added or deleted in 'Browse Fields'       "+CRLF+;
                     "To save stored value , correct lenght and loading            "+CRLF+;
                     "----------------------------------------------------------- -"+CRLF+;
                     "new 'OnHeadClick' Field(s) with DEFAULT value click -> YES   "+CRLF+;
                      "new 'OnHeadClick' Field(s) with NIL     value click ->  NO   ","DEBUG Message")
   */

   /* ---------------Start Correct Array lenght 'OnHeadClick'----------------*/
   nStrLen := Len( aOnHeadClick[ 1 ] )

   ASize( aOnHeadClick[ 1 ], nLen )

   IF ( nLen > nStrLen )  /* New Field(s) added */
      nDiff := ( nLen - nStrLen )
      FOR i := 1 to nDiff
         /* fill added fields with DEFAULT or NIL value*/
         IF nChoice
            aOnHeadClick[ 1 ][ nStrLen + i ] := "{|| ohcb" + AllTrim( Str( nStrLen + i ) ) + "}"
         ELSE
            aOnHeadClick[ 1 ][ nStrLen + i ] := "{|| NIL }"
         ENDIF
      NEXT i
   ELSE        /* Field(s) erased -> array cutted */
   ENDIF

   /* Array -> String */
   FOR i := 1 TO nLen   /* Array to String  to save in Grid1 */
       iif( i = nLen, cLast := "}", cLast := "," )
       cOnHeadClick := cOnHeadClick + aOnHeadClick[ 1 ][ i ] + cLast
   NEXT i

   /* Save value OnHeadClick */
   SV_ALLEXTG2_FLDS( A3, cOnHeadClick )
   /* ---------------End Correct Array lenght 'OnHeadClick'----------------*/

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Ctrl_InsFld( lMode AS LOGICAL )
*------------------------------------------------------------*
   Form_Fld.Button_1.Enabled := lMode   /* avoid inserting new fields when .F.*/
   Form_Fld.Button_2.Enabled := lMode
   Form_Fld.Button_3.Enabled := lMode
   Form_Fld.Button_4.Enabled := lMode

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION ExitTPM_Wnd()
*------------------------------------------------------------*
   SET INTERACTIVECLOSE ON

   RELEASE WINDOW BrwAdvanced

   SET INTERACTIVECLOSE OFF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Wnd_IntCls( lMode AS LOGICAL )
*------------------------------------------------------------*
   IF lMode
      SET INTERACTIVECLOSE OFF
   ELSE
      SET INTERACTIVECLOSE ON
   ENDIF

RETURN( NIL )


/*-------------------------------BrwAdvanced.fmg---------------------*/
/*-------------------------------------------------------------------*/

*------------------------------------------------------------*
FUNCTION Brw_Strt( A1         AS STRING, ; //
                   A2         AS STRING, ; //
                   A3         AS STRING, ; //
                   A4         AS STRING, ; //
                   aOldValues AS ARRAY   ; //
                 )
*------------------------------------------------------------*
   //aOldValues:=BAO_READ( A1, A2, A3, A4, aOldValues )
   aOldValues := BAO_READ( aOldValues )

RETURN aOldValues


*------------------------------------------------------------*
FUNCTION Adv_Choice( A1         AS STRING, ; //
                     A2         AS STRING, ; //
                     A3         AS STRING, ; //
                     A4         AS STRING, ; //
                     aOldValues AS ARRAY   ; //
                   )
*------------------------------------------------------------*
   aOldValues := BAO_READ( aOldValues )   /*  Read Stored values , Display them and restore in aOldValues */
RETURN aOldValues


*------------------------------------------------------------*
FUNCTION BAO_SetDefAll( A3 AS STRING, aOldValues AS ARRAY, A4 AS STRING )
*------------------------------------------------------------*
   LOCAL aMyValid          AS ARRAY   := {}
   LOCAL aMyValidMessages  AS ARRAY   := {}
   LOCAL aImageNames       AS ARRAY   := {}
   LOCAL aReadOnlyValues   AS ARRAY   := {}
   LOCAL aMyJustifyValues  AS ARRAY   := {}
   LOCAL aWhen             AS ARRAy   := {}
   LOCAL aOnHeadClick      AS ARRAY   := {}
   LOCAL nChoice           AS NUMERIC           //? Is it used ?
   LOCAL cMyValid          AS STRING  := "{"
   LOCAL cMyValidMessages  AS STRING  := "{"
   LOCAL cImageNames       AS STRING  := "{"
   LOCAL cReadOnlyValues   AS STRING  := "{"
   LOCAL cMyJustifyValues  AS STRING  := "{"
   LOCAL cWhen             AS STRING  := "{"
   LOCAL cOnHeadClick      AS STRING  := "{"
   LOCAL cLast             AS STRING  := ""
   LOCAL i                 AS NUMERIC := 0
   LOCAL aReturn           AS ARRAY   := {}
   LOCAL lRet              AS LOGICAL := .F.
   LOCAL nLen              AS NUMERIC

   IF BrwAdvanced.RadioGroup_4.Value = 2
      nLen := BrwAdvanced.Combo_1.ItemCount

      FOR i := 1 TO nLen

          AAdd( aMyValid        , "{|| vcb"  + AllTrim( Str( i ) ) + "}" )
          AAdd( aMyValidMessages, "'Text"    + AllTrim( Str( i ) ) + "'" )
          AAdd( aImageNames     , "ImgName"  + AllTrim( Str( i ) ) )
          AAdd( aReadOnlyValues , .T. )
          AAdd( aMyJustifyValues, "BROWSE_JTFY_LEFT" )
          AAdd( aWhen           , "{|| wcb"  + AllTrim( Str( i ) ) + "}" )
          AAdd( aOnHeadClick    , "{|| ohcb" + AllTrim( Str( i ) ) + "}" )

      NEXT i

      FOR i := 1 TO nLen   /* Array to String  to save in Grid1 - Grid2*/

          iif( i = nLen, cLast := "}", cLast := "," )

          cMyValid         := cMyValid         + aMyValid[ i ]         + cLast
          cMyValidMessages := cMyValidMessages + aMyValidMessages[ i ] + cLast
          cImageNames      := cImageNames      + aImageNames[ i ]      + cLast
          cReadOnlyValues  := cReadOnlyValues  + iif( aReadOnlyValues[ i ], ".T.", ".F." ) + cLast
          cMyJustifyValues := cMyJustifyValues + aMyJustifyValues[ i ] + cLast
          cWhen            := cWhen            + aWhen[ i ]            + cLast
          cOnHeadClick     := cOnHeadClick     + aOnHeadClick[ i ]     + cLast

      NEXT i

      /* Save It  ? */
      // IF ((lRet:=MsgYesNo("Store DATA in Browse Control ?","Message")) .AND. (BrwAdvanced.RadioGroup_4.Value=2) )
      SV_ALLEXTG2_FLDS( A3, cOnHeadClick )
      SV_ALLEXT_FLDS( A3, cMyValid, cMyValidMessages, cImageNames, cReadOnlyValues, cMyJustifyValues, cWhen, A4 )

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )
      // ENDIF

   ELSEIF BrwAdvanced.RadioGroup_4.Value = 3
      aOldValues := BAO_SetDefAllNil( A3, aOldValues, A4 )

   ELSEIF BrwAdvanced.RadioGroup_4.Value = 1
      aOldValues       := MR_FSTR()
      cMyValid         := aOldValues[  4 ]
      cMyValidMessages := aOldValues[  5 ]
      cImageNames      := aOldValues[  6 ]
      cReadOnlyValues  := aOldValues[  7 ]
      cMyJustifyValues := aOldValues[  8 ]
      cWhen            := aOldValues[  9 ]
      cOnHeadClick     := aOldValues[ 10 ]

      SV_ALLEXTG2_FLDS( A3, cOnHeadClick )
      SV_ALLEXT_FLDS( A3, cMyValid, cMyValidMessages, cImageNames, cReadOnlyValues, cMyJustifyValues, cWhen, A4 )

      SetProperty( "BrwAdvanced", "RADIOGROUP_3", "VALUE", 1 )    /* Valid          */
      SetProperty( "BrwAdvanced", "RADIOGROUP_5", "VALUE", 1 )    /* ValidMessages  */
      SetProperty( "BrwAdvanced", "RADIOGROUP_6", "VALUE", 1 )    /* Images         */
      SetProperty( "BrwAdvanced", "RADIOGROUP_7", "VALUE", 1 )    /* When           */
      SetProperty( "BrwAdvanced", "RADIOGROUP_8", "VALUE", 1 )    /* OnHeadClick    */

      aOldValues := {}

      aOldValues := BAO_READ( aOldValues )

   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION BAO_SetDefAllNil( A3 AS STRING, aOldValues AS ARRAY, A4 AS STRING )
*------------------------------------------------------------*
   LOCAL cMyValid          AS STRING  := "NIL"
   LOCAL cMyValidMessages  AS STRING  := "NIL"
   LOCAL cImageNames       AS STRING  := "NIL"
   LOCAL cReadOnlyValues   AS STRING  := "NIL"
   LOCAL cMyJustifyValues  AS STRING  := "NIL"
   LOCAL cWhen             AS STRING  := "NIL"
   LOCAL cOnHeadClick      AS STRING  := "NIL"
   LOCAL aReturn           AS ARRAY   := {}
   LOCAL lRet              AS LOGICAL := .F.

   /* Save It  ? */
   // IF ((lRet:=MsgYesNo("Store DATA in Browse Control ?","Message")) .AND. (BrwAdvanced.RadioGroup_4.Value=3) )
   SV_ALLEXTG2_FLDS( A3, cOnHeadClick )

   SV_ALLEXT_FLDS( A3, cMyValid, cMyValidMessages, cImageNames, cReadOnlyValues, cMyJustifyValues, cWhen, A4 )

   aOldValues := {}

   aOldValues := BAO_READ( aOldValues )
   // ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION SV_AllExtG2_FldS( A3 AS STRING, cOnHeadClick AS STRING )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY   := { { "OnHeadClick", cOnHeadClick } }
   LOCAL aMessage AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS NUMERIC
   LOCAL oldvalue AS USUAL           //? VarType
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   _lChngd := .T.


   // aMessage := { { "Set Value 'OnHeadClick' ?","Update 'OnHeadClick': " } }

   nLen := Len( aUpdate )
   ObjectInspector.xGrid_2.DisableUpdate

   FOR i := 1 TO nLen
       // IF MsgYesNo( aMessage[ i, 1 ], " Debug Message" )
       oldvalue := ObjectInspector.xGrid_2.Value
       FOR x := 1 TO ObjectInspector.xGrid_2.ItemCount

           ObjectInspector.xGrid_2.Value := x
           v1                            := GetColValue( "XGRID_2", "ObjectInspector", 1 )

           IF v1 == aUpdate[ i, 1 ]
              SetColValue( "XGRID_2", "ObjectInspector", 2, aUpdate[ i, 2 ] )
              SavePropControl( A3, aUpdate[ i, 2 ], v1 )
              // MsgInfo( aMessage[ i, 2 ] + aUpdate[ i, 2 ], "Debug Message" )
           ENDIF
       NEXT x

       ObjectInspector.xGrid_2.Value := oldvalue  /* riposiziona la condizione iniziale */
       // ENDIF
   NEXT I

   ObjectInspector.xGrid_2.EnableUpdate

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION SV_AllExt_Flds(                             ; //
                         A3               AS STRING, ; //
                         cMyValid         AS STRING, ; //
                         cMyValidMessages AS STRING, ; //
                         cImageNames      AS STRING, ; //
                         cReadOnlyValues  AS STRING, ; //
                         cMyJustifyValues AS STRING, ; //
                         cWhen            AS STRING, ; //
                         A4               AS STRING  ; // SL: New
                       )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY   := {}
   LOCAL aMessage AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS NUMERIC
   LOCAL OldValue AS USUAL         //? VarType
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   _lChngd := .T.

   aUpdate := { { "Valid"         , cMyValid          }, ;
                { "ValidMessages" , cMyValidMessages  }, ;
                { "Image"         , cImageNames       }, ;
                { "ReadOnlyFields", cReadOnlyValues   }, ;
                { "Justify"       , cMyJustifyValues  }, ;
                { "When"          , cWhen             }  ;
              }

   /*
   aMessage:={{"Set Value 'Valid' ?","Update 'Valid' : "},{"Set Value 'ValidMessages' ?", "Update 'ValidMessages' : "},;
             {"Set Value 'Image' ?","Update 'Image': "},{"SetValue 'ReadOnlyFields' ?","Updated 'ReadOnlyFields': "},;
             {"Set Value 'Justify' ?","Update 'Justify': "},{"Set Value 'When' ?","Update 'When': "} }
   */

   ObjectInspector.xGrid_1.DisableUpdate

   nLen := Len( aUpdate )

   FOR i := 1 to nLen
      // IF MsgYesNo( aMessage[i][1], " Debug Message" )
      OldValue :=   ObjectInspector.xGrid_1.Value
      FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

          ObjectInspector.xGrid_1.Value := x
          v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

          IF v1 == aUpdate[ i, 1 ]
             SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ i, 2 ] )
             SavePropControl( A3, aUpdate[ i, 2 ], v1 )
             // MsgInfo( aMessage[i][2] + aUpdate[i][2], "Debug Message" )
          ENDIF
      NEXT x
      ObjectInspector.xGrid_1.Value := OldValue  /* riposiziona la condizione iniziale */
      // ENDIF
   NEXT I

   ObjectInspector.xGrid_1.EnableUpdate
   ObjectInspector.xGrid_1.Value := A4
   ObjectInspector.xGrid_1.SetFocus

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION BAO_Read( aOldValues AS ARRAY )
*------------------------------------------------------------*
   LOCAL aDownLoad         AS ARRAY   := MR_FSTR()
   LOCAL aMessage          AS ARRAY   := {}
   LOCAL x                 AS NUMERIC
   //LOCAL v1                                   // Not Used
   //LOCAL OldValue                             // Not Used
   LOCAL nLen              AS NUMERIC := 0
   LOCAL i                 AS NUMERIC := 0
   LOCAL nFields           AS NUMERIC := 0
   LOCAL cMyValid          AS STRING
   LOCAL cMyValidMessages  AS STRING
   LOCAL cImageNames       AS STRING
   LOCAL cReadOnlyValues   AS STRING
   LOCAL cMyJustifyValues  AS STRING
   LOCAL cWhen             AS STRING
   LOCAL cOnHeadClick      AS STRING
   LOCAL aMyValid          AS ARRAY   := aDownLoad[  4 ]
   LOCAL aMyValidMessages  AS ARRAY   := aDownLoad[  5 ]
   LOCAL aImageNames       AS ARRAY   := aDownLoad[  6 ]
   LOCAL aReadOnlyValues   AS ARRAY   := aDownLoad[  7 ]
   LOCAL aMyJustifyValues  AS ARRAY   := aDownLoad[  8 ]
   LOCAL aWhen             AS ARRAY   := aDownLoad[  9 ]
   LOCAL aOnHeadClick      AS ARRAY   := aDownLoad[ 10 ]
   LOCAL nChoice           AS NUMERIC

   FOR i := 4 TO 10
       AAdd( aOldValues, aDownLoad[ i ] )
   NEXT I

   nFields := BrwAdvanced.Combo_1.ItemCount
   nChoice := BrwAdvanced.Combo_1.Value

   IF nChoice = 0 .AND. nFields <> 0
      nChoice := 1
   ENDIF

   /* Transform strings to arrays only if they are [!EMPTY] [!NIL]*/
   IF CHK_NLSTATE( cMyValid )
      aMyValid := Strg_2_Array( cMyValid )
   ENDIF

   IF CHK_NLSTATE( cMyValidMessages )
      aMyValidMessages := Strg_2_Array( cMyValidMessages )
   ENDIF

   IF CHK_NLSTATE( cImageNames )
      aImageNames := Strg_2_Array( cImageNames )
   ENDIF

   IF CHK_NLSTATE( cReadOnlyValues )
      aReadOnlyValues := Strg_2_Array( cReadOnlyValues )
   ENDIF

   IF CHK_NLSTATE( cMyJustifyValues )
      aMyJustifyValues := Strg_2_Array( cMyJustifyValues )
   ENDIF

   IF CHK_NLSTATE( cWhen )
      aWhen := Strg_2_Array( cWhen )
   ENDIF

   IF CHK_NLSTATE( cOnHeadClick )
      aOnHeadClick := Strg_2_Array( cOnHeadClick )
   ENDIF

   iif( CHK_NLSTATE( cMyValid )        , SetProperty( "BrwAdvanced", "TEXT_1", "VALUE", aMyValid[ 1, nChoice ] )     , SetProperty( "BrwAdvanced", "TEXT_1", "VALUE", "NIL" ) )
   iif( CHK_NLSTATE( cMyValidMessages ), SetProperty( "BrwAdvanced", "TEXT_2", "VALUE", aMyValidMessages[ nChoice ] ), SetProperty( "BrwAdvanced", "TEXT_2", "VALUE", "NIL" ) )
   iif( CHK_NLSTATE( cImageNames )     , SetProperty( "BrwAdvanced", "TEXT_3", "VALUE", aImageNames[ nChoice ] )     , SetProperty( "BrwAdvanced", "TEXT_3", "VALUE", "NIL" ) )
   iif( CHK_NLSTATE( cReadOnlyValues ) , SetProperty( "BrwAdvanced", "TEXT_4", "VALUE", aReadOnlyValues[ nChoice ] ) , SetProperty( "BrwAdvanced", "TEXT_4", "VALUE", "NIL" ) )
   iif( CHK_NLSTATE( cMyJustifyValues ), SetProperty( "BrwAdvanced", "TEXT_5", "VALUE", aMyJustifyValues[ nChoice ] ), SetProperty( "BrwAdvanced", "TEXT_5", "VALUE", "NIL" ) )
   iif( CHK_NLSTATE( cWhen )           , SetProperty( "BrwAdvanced", "TEXT_6", "VALUE", aWhen[ 1, nChoice ] )        , SetProperty( "BrwAdvanced", "TEXT_6", "VALUE", "NIL" ) )
   iif( CHK_NLSTATE( cOnHeadClick )    , SetProperty( "BrwAdvanced", "TEXT_7", "VALUE", aOnHeadClick[ 1, nChoice ] ) , SetProperty( "BrwAdvanced", "TEXT_7", "VALUE", "NIL" ) )

   RDGP_Global()

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION RDGP_GlobaL()
*------------------------------------------------------------*
   RDGP_SetTxt1()
   RDGP_SetTxt2()
   RDGP_SetTxt3()
   RDGP_GetTxt4()
   RDGP_GetTxt5()
   RDGP_GetTxt6()
   RDGP_GetTxt7()

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Chk_NLState( cString AS STRING )
*------------------------------------------------------------*
   LOCAL lMode := .F.

   iif( ! Empty( cString ) .AND. Upper( cString ) <> "NIL", lMode := .T., lMode )

RETURN( lMode )


*------------------------------------------------------------*
FUNCTION Strg_2_Array( cTestArray AS STRING )
*------------------------------------------------------------*
   LOCAL i        AS NUMERIC := 0
   LOCAL nLen     AS NUMERIC := Len( cTestArray )
   LOCAL nCounter AS NUMERIC := 0
   LOCAL nIndex   AS NUMERIC
   LOCAL aReturn  AS ARRAY
   LOCAL cTest    AS STRING  := ""

   /* FIRST MUST CHECK FOR CODE BLOCK */
   FOR i := 1 TO nLen
       iif( ! Empty( SubStr( cTestArray, i, 1 ) ), cTest := cTest + SubStr( cTestArray, i, 1 ), NIL )
   NEXT i

   IF Left( cTest, 4 ) == "{{||"  /* IT'S A CODE BLOCK {{|| cb }  */
      RETURN aReturn := strg_cb_array( cTest )
   ENDIF

   FOR i := 1 TO nLen
       iif( ( SubStr( cTestArray, i, 1 ) == "{" ), nCounter ++, NIL )
   NEXT i

   nIndex := ( nCounter - 1 )

   IF nIndex < 0
      aReturn := "NIL"
      /* MsgInfo("'aReturn' VALUE is : "+aReturn,"DEBUG MESSAGE") */
      RETURN  aReturn
   ENDIF

   aReturn := {}

   IF nIndex = 0           /*  SIMPLE ARRAY {A,B,C} */
      aReturn := strg_s_array( cTestArray )
   ELSE                  /*  NESTED ARRAY {{A},{B},{C}} */
      aReturn := strg_m_array( cTestArray )
   ENDIF

RETURN( aReturn )


*------------------------------------------------------------*
FUNCTION Strg_s_Array( cMyFields AS STRING )
*------------------------------------------------------------*
   LOCAL nLen     AS NUMERIC := Len( cMyFields )
   LOCAL i        AS NUMERIC := 0
   LOCAL nCounter AS NUMERIC := 0
   LOCAL cString  AS STRING  := ""
   LOCAL aMyField AS ARRAY   := {}

   FOR i := 1 TO nLen
       IF ! ( SubStr( cMyFields, i, 1 ) = "{" ) .AND.  ! ( SubStr( cMyFields, i, 1 ) = "}" )
          IF ! ( SubStr( cMyFields, i, 1 ) = "," )
             cString := cString + SubStr( cMyFields, i, 1 )
             IF i = nLen - 1
                AAdd( aMyField, cString )
                cString := ""
             ENDIF
          ELSE
             AAdd( aMyField, cString )
             cString := ""
          ENDIF
       ENDIF
   NEXT i

RETURN( aMyField )


*------------------------------------------------------------*
FUNCTION Strg_m_array( cMyFields AS STRING )
*------------------------------------------------------------*
   LOCAL nLen        AS NUMERIC := Len( cMyFields )
   LOCAL i           AS NUMERIC := 0
   LOCAL nCounter    AS NUMERIC := 0
   LOCAL cString     AS STRING  := ""
   LOCAL aMyField    AS ARRAY   := {}
   LOCAL aMyReturn   AS ARRAY   := {}

   FOR i := 1 TO nLen

       IF ! ( SubStr( cMyFields, i, 1 ) = "{" ) .AND. ! ( SubStr( cMyFields, i, 1 ) = "}" )
          IF ! ( SubStr( cMyFields, i, 1 ) = "," )
             cString := cString + SubStr( cMyFields, i, 1 )
             IF i = nLen
                AAdd( aMyField, cString )
                cString := ""
             ENDIF
          ELSE
             AAdd( aMyField, cString )
             cString := ""
          ENDIF
       ENDIF
   NEXT i

   AAdd( aMyField, cString )

   // cString := "" // Not needed since it;s local

   AAdd( aMyReturn, aMyField )

RETURN( aMyReturn )


*------------------------------------------------------------*
FUNCTION Strg_cb_Array( cMyFields AS STRING )
*------------------------------------------------------------*
   LOCAL nLen        AS NUMERIC := Len( cMyFields )
   LOCAL i           AS NUMERIC := 0
   LOCAL nCounter    AS NUMERIC := 0
   LOCAL cString     AS STRING  := ""
   LOCAL aMyField    AS ARRAY   := {}
   LOCAL aMyReturn   AS ARRAY   := {}

   FOR i := 1 TO nLen
       IF ! ( SubStr( cMyFields, i, 1 ) = "{" ) .AND. ! ( SubStr( cMyFields, i, 1 ) = "}" )
          IF ! ( SubStr( cMyFields, i, 1 ) = "," )
             cString := cString + SubStr( cMyFields, i, 1 )
             IF i = nLen
                cString := AtRepl( "{||", "{" + cString + "}", "{|| " )
                AAdd( aMyField, cString )
                cString := ""
             ENDIF
          ELSE
             cString := AtRepl( "{||", "{" + cString + "}", "{|| " )
             AAdd( aMyField, cString )
             cString := ""
          ENDIF
       ENDIF
   NEXT i

   cString := AtRepl( "{||", "{" + cString + "}", "{|| " )

   AAdd( aMyField, cString )
   AAdd( aMyReturn, aMyField )

RETURN( aMyReturn )


*------------------------------------------------------------*
FUNCTION Trsf_cblok( cStringa AS STRING )
*------------------------------------------------------------*
   LOCAL nLen  AS NUMERIC := Len( cStringa )
   LOCAL cTest AS STRING  := ""
   LOCAL i     AS NUMERIC := 0

   FOR i := 1 TO nLen
       iif( ! Empty( SubStr( cStringa, i, 1 ) ), cTest := cTest + SubStr( cStringa, i, 1 ), NIL )
   NEXT i

   IF ( ( Left( cTest, 4 ) == "{{||" .AND. Right( cTest, 2 ) == "}}" )    .OR. ;
        ( Left( cTest, 3 ) == "{||"  .AND. Right( cTest, 1 ) == "}"  ) )
      /* IT'S A CODE BLOCK */
   ELSE
      /* BUILT CODE BLOCK DELETING NOT SUPPORTED SYMBOL IN STRING */
      cTest    := AtRepl( "|", cTest, " " )
      cTest    := AtRepl( "{", cTest, " " )
      cTest    := AtRepl( "}", cTest, " " )
      cStringa := ""

      FOR i := 1 TO nLen
          iif( ! Empty( SubStr( cTest, i, 1 ) ), cStringa := cStringa + SubStr( cTest, i, 1 ), NIL )
      NEXT i

      cStringa := "{|| " + cStringa + "}"
   ENDIF

RETURN( cStringa )


*------------------------------------------------------------*
FUNCTION brw_settxtVLD( A3 AS STRING, aOldValues AS ARRAY )    /* {|| codeBlock } */
*------------------------------------------------------------*
   LOCAL aMyValid    AS ARRAY
   LOCAL cMyValid    AS STRING
   LOCAL nChoice     AS NUMERIC
   LOCAL cValue      AS STRING
   LOCAL aTempValid  AS ARRAY   := {}
   LOCAL cTempValid  AS STRING  := "{"
   LOCAL nLen        AS NUMERIC := 0
   LOCAL cLast       AS STRING  := ""
   LOCAL i           AS NUMERIC

   IF ! Empty( aOldValues )

      nChoice  := BrwAdvanced.Combo_1.Value
      nLen     := BrwAdvanced.Combo_1.ItemCount
      cMyValid := aOldValues[ 1 ]

      /* What happen if cMyValid is "NIL" ? */
      aMyValid := Strg_2_Array( cMyValid )  /* Old Value */

      IF Upper( cMyValid ) == "NIL" .AND. Upper( aMyValid ) == "NIL"  /* EMPTY FIELDS */
         aMyValid := { Array( nLen ) }
         AFill( aMyValid[ 1 ], "{|| NIL}" )
      ENDIF

      /* Is a correct string ? */
      aMyValid[ 1, nChoice ] := Trsf_cBlok( GetProperty( "BrwAdvanced", "TEXT_1", "VALUE" ) ) /* New Value */

      FOR i := 1 TO nLen
          iif( i = nLen, cLast := "}", cLast := "," )
          cTempValid := cTempValid + aMyValid[ 1, I ] + cLast
      NEXT i

      SV_VLD_FLDS( A3, cTempValid )

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )

      BckGrndOld()
   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION RDGP_SetTxt1()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC
   LOCAL cString AS STRING  := ""

   cString := GetProperty( "BrwAdvanced", "TEXT_1", "VALUE" )

   IF BrwAdvanced.RadioGroup_4.Value <> 1
      iif( ( AllTrim( cString ) == "{|| NIL}" .OR. AllTrim( cString ) == "NIL" ), nValue := 3, nValue := 2 )
      SetProperty( "BrwAdvanced", "RADIOGROUP_3", "VALUE", nValue )
   ELSE
      SetProperty( "BrwAdvanced", "RADIOGROUP_3", "VALUE", 1 )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION SV_VLD_FLDS( A3 AS STRING, cMyValid AS STRING )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY   := {}
   LOCAL aMessage AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS USUAL            //? VarType
   LOCAL oldvalue AS USUAL            //? VarType
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   _lChngd := .T.

   aUpdate := { { "Valid", cMyValid } }

   /*
   aMessage:={{"Set Value 'Valid' ?", "Update 'Valid' : "}}
   */

   ObjectInspector.xGrid_1.DisableUpdate
   nLen := Len( aUpdate )
   FOR i := 1 TO nLen
       /* IF MsgYesNo( aMessage[i, 1 ], " Debug Message" ) */
       OldValue :=   ObjectInspector.xGrid_1.Value
       FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

           ObjectInspector.xGrid_1.Value := x
           v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

           IF v1 == aUpdate[ i, 1 ]
              SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ i, 2 ] )
              SavePropControl( A3, aUpdate[ i, 2 ], v1 )
              // MsgInfo(aMessage[i][2]+aUpdate[i][2],"Debug Message")
           ENDIF
      NEXT x

      ObjectInspector.xGrid_1.Value := oldvalue  /* riposiziona la condizione iniziale */
      /* ENDIF */

   NEXT i

   ObjectInspector.xGrid_1.EnableUpdate

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Brw_SetTxtVM( A3 AS STRING, aOldValues AS ARRAY )        /* { array } */
*------------------------------------------------------------*
   LOCAL aMyValidMessages  AS ARRAY
   LOCAL cMyValidMessages  AS STRING
   LOCAL nChoice           AS NUMERIC
   LOCAL cValue            AS STRING
   LOCAL aTempMessages     AS ARRAY   := {}
   LOCAL cTempMessages     AS STRING  := "{"
   LOCAL nLen              AS NUMERIC := 0
   LOCAL cLast             AS STRING  := ""
   LOCAL i                 AS NUMERIC

   IF ! Empty( aOldValues )

      nChoice          := BrwAdvanced.Combo_1.Value
      nLen             := BrwAdvanced.Combo_1.ItemCount
      cMyValidMessages := aOldValues[ 2 ]

      /* What happen if NewValue is "NIL" ? */
      aMyValidMessages := Strg_2_Array( cMyValidMessages )  /* Old Value */

      IF Upper( cMyValidMessages ) == "NIL" .AND. Upper( aMyValidMessages ) == "NIL"  /* EMPTY FIELDS */
         aMyValidMessages := Array( nLen )
         AFill( aMyValidMessages, "NIL" )
      ENDIF

      aMyValidMessages[ nChoice ] := GetProperty( "BrwAdvanced", "TEXT_2", "VALUE" ) /* New Value */

      FOR i := 1 TO nLen
          iif( i = nLen, cLast := "}", cLast := "," )
          cTempMessages := cTempMessages + aMyValidMessages[ I ] + cLast
      NEXT i

      SV_VLDMSG_FLDS( A3, cTempMessages )

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )

      bckgrndold()
   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION SV_VLDMSG_FLDS( A3, cMyValidMessages )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY   := {}
   LOCAL aMessage AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS USUAL          //?VarType
   LOCAL oldvalue AS USUAL
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   _lChngd := .T.
   aUpdate := { { "ValidMessages", cMyValidMessages } }

   // aMessage:={{"Set Value 'ValidMessages' ?", "Update 'ValidMessages' : "}}
   ObjectInspector.xGrid_1.DisableUpdate
   nLen := Len( aUpdate )
   FOR i := 1 TO nLen
      /* IF MsgYesNo(aMessage[i][1]," Debug Message") */
      oldvalue :=   ObjectInspector.xGrid_1.Value
      FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

         ObjectInspector.xGrid_1.Value := x
         v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

         IF v1 == aUpdate[ I ][ 1 ]
            SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ I ][ 2 ] )
            SavePropControl( A3, aUpdate[ I ][ 2 ], v1 )
            // MsgInfo(aMessage[i][2]+aUpdate[i][2],"Debug Message")
         ENDIF

      NEXT x

      ObjectInspector.xGrid_1.Value := oldvalue  /* riposiziona la condizione iniziale */
      /* ENDIF */
   NEXT I

   ObjectInspector.xGrid_1.EnableUpdate

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDGP_SetTxt2()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC
   LOCAL cString AS STRING  := GetProperty( "BrwAdvanced", "TEXT_2", "VALUE" )

   IF BrwAdvanced.RadioGroup_4.Value <> 1
      iif( AllTrim( cString ) == "NIL", nValue := 3, nValue := 2 )
      SetProperty( "BrwAdvanced", "RADIOGROUP_5", "VALUE", nValue )
   ELSE
      SetProperty( "BrwAdvanced", "RADIOGROUP_5", "VALUE", 1 )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Brw_SetTxtIMG( A3 AS STRING, aOldValues AS ARRAY )       /* { array } */
*------------------------------------------------------------*
   LOCAL aImageNames    AS ARRAY   := {}
   LOCAL cImageNames    AS STRING  := ""
   LOCAL nChoice        AS NUMERIC
   LOCAL cValue         AS STRING
   LOCAL aTempMessages  AS ARRAY   := {}
   LOCAL cTempMessages  AS STRING  := "{"
   LOCAL nLen           AS NUMERIC := 0
   LOCAL cLast          AS STRING  := ""
   LOCAL i

   IF ! Empty( aOldValues )

      nChoice     := BrwAdvanced.Combo_1.Value
      nLen        := BrwAdvanced.Combo_1.ItemCount
      cImageNames := aOldValues[ 3 ]

      /* What happen if cImageNames is "NIL" ? */
      aImageNames := Strg_2_Array( cImageNames )  /* Old Value */

      IF Upper( cImageNames ) == "NIL"  .AND. Upper( aImageNames ) == "NIL"
         aImageNames := Array( nLen )
         AFill( aImageNames, "NIL" )
      ENDIF

      aImageNames[ nChoice ] := GetProperty( "BrwAdvanced", "TEXT_3", "VALUE" ) /* New Value */

      FOR i := 1 TO nLen
          iif( i = nLen, cLast := "}", cLast := "," )
          cTempMessages := cTempMessages + aImageNames[ I ] + cLast
      NEXT i

      SV_IMG_FLDS( A3, cTempMessages )

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )

      BckgrndOld()

   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION SV_IMG_FLDS( A3 AS STRING, cImageNames AS STRING )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY   := {}
   LOCAL aMessage AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS USUAL          //? VarType
   LOCAL oldvalue AS USUAL          //? VarType
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   aUpdate := { { "Image", cImageNames } }

   // aMessage:={{"Set Value 'Image' ?", "Update 'Image' : "}}

   ObjectInspector.xGrid_1.DisableUpdate
   nLen := Len( aUpdate )
   FOR i := 1 TO nLen
       /* IF MsgYesNo(aMessage[i][1]," Debug Message") */
       oldvalue := ObjectInspector.xGrid_1.Value
       FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

           ObjectInspector.xGrid_1.Value := x
           v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

           IF v1 == aUpdate[ i, 1 ]
              SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ i, 2 ] )
              SavePropControl( A3, aUpdate[ i, 2 ], v1 )
              // MsgInfo(aMessage[i][2]+aUpdate[i][2],"Debug Message" )
           ENDIF
      NEXT x
      ObjectInspector.xGrid_1.Value := OldValue  /* riposiziona la condizione iniziale */
      /* ENDIF */
   NEXT I

   ObjectInspector.xGrid_1.EnableUpdate

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Brw_SetTxtRDO( A3 AS STRING, aOldValues AS ARRAY )    /* { array } */
*------------------------------------------------------------*
   LOCAL aReadOnlyValues AS ARRAY
   LOCAL cReadOnlyValues AS STRING
   LOCAL nChoice         AS NUMERIC
   LOCAL cValue          AS STRING
   LOCAL aTempMessages   AS ARRAY   := {}
   LOCAL cTempMessages   AS STRING  := "{"
   LOCAL nLen            AS NUMERIC := 0
   LOCAL cLast           AS STRING  := ""
   LOCAL i

   IF ! Empty( aOldValues )

      nChoice         := BrwAdvanced.Combo_1.Value
      nLen            := BrwAdvanced.Combo_1.ItemCount
      cReadOnlyValues := aOldValues[ 4 ]

      /* What happen if cReadOnlyValues is "NIL" ? */
      aReadOnlyValues := Strg_2_Array( cReadOnlyValues )  /* Old Value */

      IF Upper( cReadOnlyValues ) == "NIL" .AND. Upper( aReadOnlyValues ) == "NIL"
         aReadOnlyValues := Array( nLen )
         AFill( aReadOnlyValues, "NIL" )
      ENDIF

      aReadOnlyValues[ nChoice ] := GetProperty( "BrwAdvanced", "TEXT_4", "VALUE" ) /* New Value */

      FOR i := 1 TO nLen
          iif( i = nLen, cLast := "}", cLast := "," )
          cTempMessages := cTempMessages + aReadOnlyValues[ I ] + cLast
      NEXT i

      SV_RDO_FLDS( A3, cTempMessages )

      bckgrndold()

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )
   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION SV_RDO_FLDS( A3 AS STRING, cReadOnlyValues AS STRING )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY  := {}
   LOCAL aMessage AS ARRAY  := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS USUAL         //? VarType
   LOCAL oldvalue AS NUMERIC
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   _lChngd := .T.
   aUpdate := { { "ReadOnlyFields", cReadOnlyValues } }

   // aMessage:={{"Set Value '"ReadOnlyFields"' ?", "Update '"ReadOnlyFields"' : "}}

   ObjectInspector.xGrid_1.DisableUpdate

   nLen := Len( aUpdate )
   FOR i := 1 TO nLen
       /* IF MsgYesNo(aMessage[i][1]," Debug Message") */
       oldvalue :=   ObjectInspector.xGrid_1.Value
       FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

          ObjectInspector.xGrid_1.Value := x
          v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

          IF v1 == aUpdate[ i, 1 ]
             SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ i, 2 ] )
             SavePropControl( A3, aUpdate[ i, 2 ], v1 )
             // MsgInfo( aMessage[ i, 2 ] + aUpdate[ i, 2 ], "Debug Message" )
          ENDIF

       NEXT x

       ObjectInspector.xGrid_1.Value := oldvalue  /* riposiziona la condizione iniziale */
       /* ENDIF */
   NEXT i

   ObjectInspector.xGrid_1.EnableUpdate

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDGP_SetTxt3()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC
   LOCAL cString AS STRING  := GetProperty( "BrwAdvanced", "TEXT_3", "VALUE" )

   IF BrwAdvanced.RadioGroup_4.Value <> 1
      iif( AllTrim( cString ) == "NIL", nValue := 3, nValue := 2 )
      SetProperty( "BrwAdvanced", "RADIOGROUP_6", "VALUE", nValue )
   ELSE
      SetProperty( "BrwAdvanced", "RADIOGROUP_6", "VALUE", 1 )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Brw_SetTxtJfy( A3 AS STRING, aOldValues AS ARRAY )    /* { array } */
*------------------------------------------------------------*
   LOCAL aMyJustifyValues  AS ARRAY  := {}
   LOCAL cMyJustifyValues  AS STRING := "{"
   LOCAL nChoice           AS NUMERIC
   LOCAL cValue            AS STRING
   LOCAL aTempMessages     AS ARRAY   := {}
   LOCAL cTempMessages     AS STRING  := "{"
   LOCAL nLen              AS NUMERIC := 0
   LOCAL cLast             AS STRING  := ""
   LOCAL i                 AS NUMERIC

   IF ! Empty( aOldValues )

      nChoice          := BrwAdvanced.Combo_1.Value
      nLen             := BrwAdvanced.Combo_1.ItemCount
      cMyJustifyValues := aOldValues[ 5 ]
      aMyJustifyValues := Strg_2_Array( cMyJustifyValues )  /* Old Value */

      /* What happen if cMyJustifyValues is "NIL" ? */
      IF Upper( cMyJustifyValues ) == "NIL" .AND. Upper( aMyJustifyValues ) == "NIL"
         aMyJustifyValues := Array( nLen )
         AFill( aMyJustifyValues, "NIL" )
      ENDIF

      aMyJustifyValues[ nChoice ] := GetProperty( "BrwAdvanced", "TEXT_5", "VALUE" ) /* New Value */

      FOR i := 1 TO nLen
          iif( i = nLen, cLast := "}", cLast := "," )
          cTempMessages := cTempMessages + aMyJustifyValues[ I ] + cLast
      NEXT i

      SV_JFY_FLDS( A3, cTempMessages )

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )

      bckgrndold()
   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION SV_Jfy_Flds( A3 AS STRING, cMyJustifyValues AS STRING )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY   := {}
   LOCAL aMessage AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS NUMERIC
   LOCAL oldvalue AS USUAL            //? VarType
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   _lChngd := .T.
   aUpdate := { { "Justify", cMyJustifyValues } }

   // aMessage:={{"Set Value '"Justify"' ?", "Update '"Justify"' : "}}

   ObjectInspector.xGrid_1.DisableUpdate
   nLen := Len( aUpdate )
   FOR i := 1 TO nLen
       /* IF MsgYesNo(aMessage[i][1]," Debug Message") */
       OldValue := ObjectInspector.xGrid_1.Value
       FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

          ObjectInspector.xGrid_1.Value := x
          v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

          IF v1 == aUpdate[ i, 1 ]
             SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ i, 2 ] )
             SavePropControl( A3, aUpdate[ i, 2 ], v1 )
             /*  MsgInfo(aMessage[i][2]+aUpdate[i][2],"Debug Message") */
          ENDIF

      NEXT x

      ObjectInspector.xGrid_1.Value := OldValue  /* riposiziona la condizione iniziale */
      /* ENDIF */

   NEXT I

   ObjectInspector.xGrid_1.EnableUpdate

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Brw_SetTxtWhen( A3 AS STRING, aOldValues AS ARRAY )   /* {|| codeBlock } */
*------------------------------------------------------------*
   LOCAL aWhen       AS ARRAY
   LOCAL cWhen       AS STRING
   LOCAL nChoice     AS NUMERIC
   LOCAL cValue      AS STRING
   LOCAL aTempValid  AS ARRAY   := {}
   LOCAL cTempValid  AS STRING  := "{"
   LOCAL nLen        AS NUMERIC := 0
   LOCAL cLast       AS STRING  := ""
   LOCAL i           AS NUMERIC := 0

   IF ! Empty( aOldValues )

      nChoice  := BrwAdvanced.Combo_1.Value
      nLen     := BrwAdvanced.Combo_1.ItemCount
      cWhen    := aOldValues[ 6 ]
      aWhen    := Strg_2_Array( cWhen )  /* Old Value */

      /* What happen if cWhen is "NIL" ? */
      IF Upper( cWhen ) == "NIL" .AND. Upper( aWhen ) == "NIL"
         aWhen := { Array( nLen ) }
         AFill( aWhen[ 1 ], "{|| NIL}" )
      ENDIF

      aWhen[ 1 ][ nChoice ] := Trsf_cBlok( GetProperty( "BrwAdvanced", "TEXT_6", "VALUE" ) ) /* New Value */

      FOR i := 1 TO nLen
          iif( i = nLen, cLast := "}", cLast := "," )
          cTempValid := cTempValid + aWhen[ 1, i ] + cLast
      NEXT i

      SV_WHEN_FLDS( A3, cTempValid )

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )

      bckgrndold()
   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION SV_WHEN_FLDS( A3 AS STRING, cWhen AS STRING )
*------------------------------------------------------------*
   LOCAL aUpdate  AS ARRAY   := {}
   LOCAL aMessage AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL v1       AS NUMERIC
   LOCAL oldvalue AS USUAL          //? VarType
   LOCAL nLen     AS NUMERIC := 0
   LOCAL i        AS NUMERIC := 0

   _lChngd := .T.
   aUpdate := { { "When", cWhen } }

   // aMessage:={{"Set Value 'When' ?", "Update 'When' : "}}

   ObjectInspector.xGrid_1.DisableUpdate
   nLen := Len( aUpdate )
   FOR i := 1 TO nLen
      /* IF MsgYesNo(aMessage[i][1]," Debug Message") */
      oldvalue := ObjectInspector.xGrid_1.Value
      FOR x := 1 TO ObjectInspector.xGrid_1.ItemCount

         ObjectInspector.xGrid_1.Value := x
         v1                            := GetColValue( "XGRID_1", "ObjectInspector", 1 )

         IF v1 == aUpdate[ I, 1 ]
            SetColValue( "XGRID_1", "ObjectInspector", 2, aUpdate[ I, 2 ] )

            SavePropControl( A3, aUpdate[ I, 2 ], v1 )
            // MsgInfo(aMessage[i][2]+aUpdate[i][2],"Debug Message")
         ENDIF

      NEXT x

      ObjectInspector.xGrid_1.Value := oldvalue  /* riposiziona la condizione iniziale */
      /* ENDIF */

   NEXT I

   ObjectInspector.xGrid_1.EnableUpdate

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDGP_GetTxt6()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC
   LOCAL cString AS STRING  := GetProperty( "BrwAdvanced", "TEXT_6", "VALUE" )

   IF BrwAdvanced.RadioGroup_4.Value <> 1
      iif( ( AllTrim( cString ) == "{|| NIL}".OR. AllTrim( cString ) == "NIL" ), nValue := 3, nValue := 2 )
      SetProperty( "BrwAdvanced", "RADIOGROUP_7", "VALUE", nValue )
   ELSE
      SetProperty( "BrwAdvanced", "RADIOGROUP_7", "VALUE", 1 )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION Brw_SetTxtOHC( A3 AS STRING, aOldValues AS ARRAY )   /* {|| codeBlock } */
*------------------------------------------------------------*
   LOCAL aOnHeadClick AS ARRAY   := {}
   LOCAL cOnHeadClick AS STRING  := "{"
   LOCAL nChoice      AS NUMERIC
   LOCAL cValue       AS STRING
   LOCAL aTempValid   AS ARRAY   := {}
   LOCAL cTempValid   AS STRING  := "{"
   LOCAL nLen         AS NUMERIC := 0
   LOCAL cLast        AS STRING  := ""
   LOCAL i            AS NUMERIC := 0

   IF ! Empty( aOldValues )

      nChoice      := BrwAdvanced.Combo_1.Value
      nLen         := BrwAdvanced.Combo_1.ItemCount
      cOnHeadClick := aOldValues[ 7 ] /* old value stored */
      aOnHeadClick := Strg_2_Array( cOnHeadClick )  /* Array Old Value */

      /* What happen if cOnHeadClick is "NIL" ? */
      IF Upper( cOnHeadClick ) == "NIL" .AND. Upper( aOnHeadClick ) == "NIL"
         aOnHeadClick := { Array( nLen ) }
         AFill( aOnHeadClick[ 1 ], "{|| NIL}" )
      ENDIF

      aOnHeadClick[ 1, nChoice ] := Trsf_cBlok( GetProperty( "BrwAdvanced", "TEXT_7", "VALUE" ) ) /* New Value */

      FOR i := 1 to nLen
          iif( i = nLen, cLast := "}", cLast := "," )
          cTempValid := cTempValid + aOnHeadClick[ 1, i ] + cLast
      NEXT i

      SV_ALLEXTG2_FLDS( A3, cTempValid )

      aOldValues := {}
      aOldValues := BAO_READ( aOldValues )

      bckgrndold()

   ENDIF

RETURN( aOldValues )


*------------------------------------------------------------*
FUNCTION RDGP_GetTxt7()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC
   LOCAL cString AS STRING  := GetProperty( "BrwAdvanced", "TEXT_7", "VALUE" )

   IF BrwAdvanced.RadioGroup_4.Value <> 1
      iif( ( AllTrim( cString ) == "{|| NIL}".OR. AllTrim( cString ) == "NIL" ), nValue := 3, nValue := 2 )
      SetProperty( "BrwAdvanced", "RADIOGROUP_8", "VALUE", nValue )
   ELSE
      SetProperty( "BrwAdvanced", "RADIOGROUP_8", "VALUE", 1 )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDGP_SetTxt4()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC := GetProperty( "BrwAdvanced", "RADIOGROUP_1", "VALUE" )
   LOCAL cString AS STRING  := ""

   BrwAdvanced.Text_4.SetFocus

   DO CASE
      CASE nValue = 1 ; cString := ".T."
      CASE nValue = 2 ; cString := ".F."
      CASE nValue = 3 ; cString := "NIL"
   ENDCASE

   SetProperty( "BrwAdvanced", "TEXT_4", "VALUE", cString )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDGP_GetTxt4()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC
   LOCAL cString AS STRING  := ""

   IF BrwAdvanced.RadioGroup_4.Value <> 1
      cString := GetProperty( "BrwAdvanced", "TEXT_4", "VALUE" )
   ELSE
      cString := AllTrim( Upper( MR_FSTR()[ 7 ] ) )
   ENDIF

   DO CASE
      CASE cString = ".T." ; nValue := 1
      CASE cString = ".F." ; nValue := 2
      CASE cString = "NIL" ; nValue := 3
   ENDCASE

   SetProperty( "BrwAdvanced", "RADIOGROUP_1", "VALUE", nValue )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDGP_GetTxt5()
*------------------------------------------------------------*
   LOCAL nValue  AS NUMERIC
   LOCAL cString AS STRING  := ""

   IF BrwAdvanced.RadioGroup_4.Value <> 1
      cString := GetProperty( "BrwAdvanced", "TEXT_5", "VALUE" )
   ELSE
      cString := AllTrim( Upper( MR_FSTR()[ 8 ] ) )
   ENDIF

   DO CASE
      CASE cString = "BROWSE_JTFY_LEFT"    ; nValue := 1
      CASE cString = "BROWSE_JTFY_CENTER"  ; nValue := 2
      CASE cString = "BROWSE_JTFY_RIGHT"   ; nValue := 3
      CASE cString = "NIL"                 ; nValue := 4
   ENDCASE

   SetProperty( "BrwAdvanced", "RADIOGROUP_2", "VALUE", nValue )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDGP_SetTxt5()
*------------------------------------------------------------*
   LOCAL nValue     AS NUMERIC := GetProperty( "BrwAdvanced", "RADIOGROUP_2", "VALUE" )
   LOCAL cString    AS STRING  := ""
   LOCAL cOldString AS STRING  := "" //? Not used

   BrwAdvanced.Text_5.SetFocus

   DO CASE
      CASE nValue = 1  ; cString := "BROWSE_JTFY_LEFT"
      CASE nValue = 2  ; cString := "BROWSE_JTFY_CENTER"
      CASE nValue = 3  ; cString := "BROWSE_JTFY_RIGHT"
      CASE nValue = 4  ; cString := "NIL"
   ENDCASE

   SetProperty( "BrwAdvanced", "TEXT_5", "VALUE", cString )

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDG3TXT1_STNL()
*------------------------------------------------------------*
   LOCAL nFields AS NUMERIC := BrwAdvanced.Combo_1.Value

   BrwAdvanced.Text_1.SetFocus

   IF BrwAdvanced.RadioGroup_3.Value = 2
      SetProperty( "BrwAdvanced", "TEXT_1", "VALUE", "{|| vcb" + AllTrim( Str( nFields ) ) + "}" )

   ELSEIF BrwAdvanced.RadioGroup_3.Value = 3
      SetProperty( "BrwAdvanced", "TEXT_1", "VALUE", "{|| NIL}" )

   ELSEIF BrwAdvanced.RadioGroup_3.Value = 1
      SetProperty( "BrwAdvanced", "TEXT_1", "VALUE", Strg_2_Array( MR_FSTR()[ 4 ] )[ 1 ][ nFields ] )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDG5TXT2_STNL()
*------------------------------------------------------------*
   LOCAL nFields AS NUMERIC := BrwAdvanced.Combo_1.Value

   BrwAdvanced.Text_2.SetFocus

   IF BrwAdvanced.RadioGroup_5.Value = 2
      SetProperty( "BrwAdvanced", "TEXT_2", "VALUE", "'Text" + AllTrim( Str( nFields ) ) + "'" )

   ELSEIF BrwAdvanced.RadioGroup_5.Value = 3
      SetProperty( "BrwAdvanced", "TEXT_2", "VALUE", "NIL" )

   ELSEIF BrwAdvanced.RadioGroup_5.Value = 1
      SetProperty( "BrwAdvanced", "TEXT_2", "VALUE", Strg_2_Array( MR_FSTR()[ 5 ] )[ nFields ] )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDG6TXT3_STNL()
*------------------------------------------------------------*
   LOCAL nFields AS NUMERIC := BrwAdvanced.Combo_1.Value

   BrwAdvanced.Text_3.SetFocus

   IF BrwAdvanced.RadioGroup_6.Value = 2
      SetProperty( "BrwAdvanced", "TEXT_3", "VALUE", "ImgName" + AllTrim( Str( nFields ) ) )

   ELSEIF BrwAdvanced.RadioGroup_6.Value = 3
      SetProperty( "BrwAdvanced", "TEXT_3", "VALUE", "NIL" )

   ELSEIF BrwAdvanced.RadioGroup_6.Value = 1
      SetProperty( "BrwAdvanced", "TEXT_3", "VALUE", Strg_2_Array( MR_FStr()[ 6 ] )[ nFields ] )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDG7TXT6_STNL()
*------------------------------------------------------------*
   LOCAL nFields AS NUMERIC := BrwAdvanced.Combo_1.Value

   BrwAdvanced.Text_6.SetFocus

   IF BrwAdvanced.RadioGroup_7.Value = 2
      SetProperty( "BrwAdvanced", "TEXT_6", "VALUE", "{|| wcb" + AllTrim( Str( nFields ) ) + "}" )

   ELSEIF BrwAdvanced.RadioGroup_7.Value = 3
      SetProperty( "BrwAdvanced", "TEXT_6", "VALUE", "{|| NIL}" )

   ELSEIF BrwAdvanced.RadioGroup_7.Value = 1
      SetProperty( "BrwAdvanced", "TEXT_6", "VALUE", Strg_2_Array( MR_FStr()[ 9 ] )[ 1 ][ nFields ] )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION RDG8TXT7_STNL()
*------------------------------------------------------------*
   LOCAL nFields AS NUMERIC := BrwAdvanced.Combo_1.Value

   BrwAdvanced.Text_7.SetFocus

   IF BrwAdvanced.RadioGroup_8.Value = 2
      SetProperty( "BrwAdvanced", "TEXT_7", "VALUE", "{|| ohcb" + AllTrim( Str( nFields ) ) + "}" )

   ELSEIF BrwAdvanced.RadioGroup_8.Value = 3
      SetProperty( "BrwAdvanced", "TEXT_7", "VALUE", "{|| NIL}" )

   ELSEIF BrwAdvanced.RadioGroup_8.Value = 1
      SetProperty( "BrwAdvanced", "TEXT_7", "VALUE", Strg_2_Array( MR_FStr()[ 10 ] )[ 1 ][ nFields ] )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION BckgrndNew()
*------------------------------------------------------------*
   THIS.BackColor := YELLOW
RETURN( NIL )


*------------------------------------------------------------*
FUNCTION BckgrndOld()
*------------------------------------------------------------*
   THIS.BackColor := WHITE
RETURN( NIL )


*------------------------------------------------------------*
FUNCTION OPEN_absw_hlpfl()
*------------------------------------------------------------*
   LOCAL nHandle       AS NUMERIC := _HMG_aFormHandles[ GetFormIndex( "BrwAdvanced" ) ]
   LOCAL cHelpFilename AS STRING  := SubStr( GetExeFilename(), 1, RAt( "\", GetExeFilename() ) ) + "ABSW.HLP"

   /* ABSW.HLP must be allocated in *.exe folder */
   LOCAL nStyle        AS NUMERIC := 3   /* Needs Modification in file c_help.c - See Change */

   /* Added HELP_FORCEFILE style */
   IF File( cHelpFilename )
      WINHELP ( nHandle, cHelpFilename, nStyle )
   ELSE
      msgstop( 'ABSW.HLP  not found !! - Put it in the program folder!' )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION MDFY_LS( cAlias AS STRING, A3 AS STRING, nMode AS NUMERIC )
*------------------------------------------------------------*
   LOCAL lMode          AS LOGICAL := .F.
   LOCAL nChoice        AS NUMERIC := 0
   LOCAL cWindowTitle   AS STRING  := "WorkArea Maintenance"
   LOCAL cWindowText    AS STRING  := ""
   LOCAL aButtonCaption AS ARRAY   := {}

   IF ! Empty( cAlias ) .AND. Upper( cAlias ) <> "NIL"

      cWindowText    := "DELETE or CHANGE " + CRLF + "stored WorkArea ?"
      aButtonCaption := { "Delete", "Change", "Exit" }
      nChoice        := MsgOptions( cWindowTitle, cWindowText, aButtonCaption )

      IF nChoice = 1
         cAlias                := ""
         Form_fld.Text_2.Value := cAlias

         sv_objfield( "WorkArea", cAlias, A3, nMode, SAVED )
         lMode  := .T.

      ELSEIF nChoice = 2
         NSRT_LS( cAlias, A3, nMode )
         lMode := .T.

      ELSEIF nChoice = 3
         EXIT_WND()
         RETURN NIL
      ENDIF

   ELSEIF Empty( cAlias ) .OR. Upper( cAlias ) = "NIL"  /*Empty or NIL -> Insert New WorkArea Name */
      IF MsgYesNo( "Insert New WorkArea name ?", "WorkArea Maintenance" )
         NSRT_LS( cAlias, A3, nMode )
         lMode := .T.
      ENDIF
   ENDIF

   IF lMode
      What_Field( A3 )
   ENDIF

RETURN( NIL )


*------------------------------------------------------------*
FUNCTION MsgOptions( cWindowTitle, cWindowText, aButtonCaption )
/*************************************************************************
 * Original Source Adapted for readflds.prg donated to public domain.    *
 * (c) 2007 by Arcangelo Molinaro for HMGS-IDE by Walter Formigoni.      *
 *------------------------------------------------------------------------
 *                                                                       *
 * MsgOptions(cWindowTitle,cWindowText,aButtonCaption)                   *
 * cWindowTitle:="Window Title" (check lenght)                           *
 * cWindowText:= "I am here !"                        (check single line)*
 * cWindowText:= "I am here !"+CRLF+"I am here too !" (check Multi  line)*
 * aButtonCaption:={"First Button","Second Button"...and so on....}      *
 *                                                                       *
 * -----------------------------------------------------------------------
 * MiniGUI MsgEdit, MsgDate, MsgCopy, MsgMove, MsgDelete, MsgPostIt Demo *
 * (c) 2007 Grigory Filatov                                              *
 *                                                                       *
 * FUNCTIONs MsgEdit(), MsgDate(), MsgCopy(), MsgMove(), MsgDelete(),    *
 * MsgPostIt() for Xailer                                                *
 * Author: Bingen Ugaldebere                                             *
 * Final revision: 07/11/2006                                            *
 ********************************************************************/

   LOCAL nItem             AS NUMERIC := 0
   LOCAL nBtnWidth         AS NUMERIC := 0
   LOCAL aBtn              AS ARRAY   := Array( Len( aButtonCaption ) )
   LOCAL nBtnLenght        AS NUMERIC := 0
   LOCAL nTextLenght       AS NUMERIC := 0
   LOCAL nLabelPosX        AS NUMERIC := 0
   LOCAL nWindowWidth      AS NUMERIC := 0
   LOCAL nWindowHeight     AS NUMERIC := 0
   LOCAL nLabelWidth       AS NUMERIC := 0
   LOCAL nLabelHeight      AS NUMERIC := 0
   LOCAL nDefaultOption    AS NUMERIC := Len( aButtonCaption )
   LOCAL nTitleLenght      AS NUMERIC := 0
   LOCAL nSpaceLenght      AS NUMERIC := 0
   LOCAL nButtonGap        AS NUMERIC := 10
   LOCAL nBtnCaptionSpace  AS NUMERIC := 10
   LOCAL nWindowMargin     AS NUMERIC := 15
   LOCAL nBtnPosX          AS NUMERIC := 10
   LOCAL nBtnPosY          AS NUMERIC := 85
   LOCAL cOption           AS STRING  := ""
   LOCAL nLen              AS NUMERIC := 0
   LOCAL aText             AS ARRAY   := {}
   LOCAL nStart            AS NUMERIC := 0
   LOCAL nRighe            AS NUMERIC := 0
   LOCAL aReturn           AS ARRAY   := {}
   LOCAL aMyArray          AS ARRAY   := {}

   DEFAULT cWindowText     TO ""
   DEFAULT cWindowTitle    TO ""

   DEFINE FONT _Font_Options FONTNAME "MS Sans Serif" SIZE 9

   FOR nItem := 1 TO Len( aButtonCaption )
      aButtonCaption[ nItem ] := AllTrim( aButtonCaption[ nItem ] )
      nBtnWidth := Max( GetTextWidth(, aButtonCaption[ nItem ], GetFontHandle( "_Font_Options" ) ), nBtnWidth )
   NEXT

   nBtnWidth    += Int( nBtnCaptionSpace )

   nSpaceLenght := GetTextWidth(, Space( nWindowMargin * 2 ), GetFontHandle( "_Font_Options" ) )

   /* Button + nBtnCaptionSpace + nButtonGap */
   nBtnLenght   := nBtnWidth + ( Len( aButtonCaption ) - 1 ) * ( nBtnWidth + nButtonGap )

   /* We Need to split Text in Multi line input if need */

   aReturn       := _splt_Text( cWindowText )
   nTextLenght   := aReturn[ 1 ]
   aText         := aReturn[ 2 ]
   nRighe        := aReturn[ 3 ]
   nLabelHeight  :=  30 + ( 10 * nRighe )
   nWindowHeight := 160 + ( 10 * nRighe )
   nBtnPosY      := nBtnPosY + 10 * nRighe

   nTitleLenght  := Max( GetTextWidth(, cWindowTitle, GetFontHandle( "_Font_Options" ) ), nTitleLenght )
   aMyArray      := { { "cWindowTitle", nTitleLenght }, { "cWindowText", nTextLenght }, { "cButton", nBtnLenght } }

   ASort( aMyArray,,, { | x, y | x[ 2 ] > y[ 2 ] } )

   nWindowWidth := aMyArray[ 1 ][ 2 ] + nSpaceLenght
   nBtnPosX     := int( ( nWindowWidth - nBtnLenght ) / 2 )
   nLabelPosX   := int( nWindowWidth - nTextLenght / 2 )
   nLabelWidth  := nTextLenght

   DEFINE WINDOW _Options      ;
          AT 0, 0              ;
          WIDTH nWindowWidth   ;
          HEIGHT nWindowHeight ;
          TITLE cWindowTitle   ;
          MODAL                ;
          NOSYSMENU            ;
          NOSIZE               ;

      nLabelPosX := int( ( nWindowWidth - nTextLenght ) / 2 )

      FOR nItem := 1 To Len( aButtonCaption )
          aBtn[ nItem ] := "_Btn_" + LTrim( Str( nItem ) )
          cOption := aBtn[ nItem ]
          @ nBtnPosY, nBtnPosX BUTTON &cOption CAPTION aButtonCaption[ nItem ] WIDTH nBtnWidth HEIGHT 25 FONT "_Font_Options" ;
             ACTION ( cOption := GetProperty( "_Options", This.Name, "Caption" ), _Options.Release )
          nBtnPosX += nBtnWidth + nButtonGap
      NEXT

      @ 15, nLabelPosX LABEL _Label VALUE cWindowText WIDTH nLabelWidth HEIGHT nLabelHeight ;
            TRANSPARENT CENTERALIGN FONT "_Font_Options"

      DoMethod( "_Options", aBtn[ nDefaultOption ], "SetFocus" )

   END WINDOW

   CENTER WINDOW _Options

   ACTIVATE WINDOW _Options

   RELEASE FONT _Font_Options

RETURN( AScan( aButtonCaption, AllTrim( cOption ) ) )


*------------------------------------------------------------*
FUNCTION _splt_Text( cWindowText AS STRING )
*------------------------------------------------------------*
   LOCAL nNumber     AS NUMERIC := - 1
   LOCAL cString     AS STRING  := CRLF
   LOCAL nLen        AS NUMERIC := Len( cWindowText )
   LOCAL aText       AS ARRAY   := {}
   LOCAL nTextLenght AS NUMERIC := 0
   LOCAL i           AS NUMERIC := 0
   LOCAL aReturn     AS ARRAY   := {}

   DO WHILE nNumber <> 0
      nNumber := AtNum( cString, cWindowText, 1 )
      IF nNumber > 0
         AAdd( aText, SubStr( cWindowText, 1, nNumber - 1 ) )
         cWindowText := SubStr( cWindowText, nNumber + 2, nLen )
         nLen := Len( cWindowText )
      ENDIF
   ENDDO

   nLen := Len( aText )

   IF nLen > 0 /* Multilines Message */
      FOR i := 1 TO nLen
         nTextLenght := Max( GetTextWidth(, aText[ i ], GetFontHandle( "_Font_Options" ) ), nTextLenght )
      NEXT
   ELSE      /* Single Line Message */
      nTextLenght := Max( GetTextWidth(, cWindowText, GetFontHandle( "_Font_Options" ) ), nTextLenght )
      AAdd( aText, cWindowText )
   ENDIF

   AAdd( aReturn, nTextLenght )
   AAdd( aReturn, aText )
   AAdd( aReturn, Len( aText ) )

RETURN( aReturn )


*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// C Programming section


#pragma begindump

#define _WIN32_IE 0x0500
#define HB_OS_WIN_32_USED

// #define _WIN32_WINNT 0x0400 // redefinition warn by gcc. p.d.25/02/2016

#include <shlobj.h>
#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"

HFONT PrepareFont (char *Fontname, int FontSize, int Weight, int Italic, int Underline, int StrikeOut, int Angle );

HB_FUNC ( SETTOOLTIPFONT )
{
  HFONT hFont ;
  INT iBold = FW_NORMAL;
  INT iItalic = 0;
  INT iUnderline = 0;
  INT iStrikeout = 0;
  INT iAngle = 0;

  if ( hb_parl (4) )
  {
    iBold = FW_BOLD;
  }

  if ( hb_parl (5) )
  {
    iItalic = 1;
  }

  if ( hb_parl (6) )
  {
    iUnderline = 1;
  }

  if ( hb_parl (7) )
  {
    iStrikeout = 1;
  }

  if ( hb_parl (8) )
  {
    iAngle = 1;
  }

  hFont = (HFONT) PrepareFont( ( char * ) hb_parc(2), hb_parni(3), iBold , iItalic, iUnderline, iStrikeout, iAngle ) ;
  SendMessage( (HWND) hb_parnl(1) , (UINT) WM_SETFONT,(WPARAM) hFont , (LPARAM) 1 ) ;
  hb_retnl ( (LONG) hFont );
}

#pragma enddump
