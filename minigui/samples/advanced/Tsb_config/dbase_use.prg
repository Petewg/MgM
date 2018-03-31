/*
 * MINIGUI - Harbour Win32 GUI library
 *
 * Copyright 2013 Verchenko Andrey <verchenkoag@gmail.com>
*/

#include "minigui.ch"
#include "Dbinfo.ch"

#define FILE_DBF  ChangeFileExt( Application.ExeName, ".dbf" )  
#define FILE_CDX  ChangeFileExt( Application.ExeName, "0.cdx" )
#define FILE_OPER_DBF  GetStartupFolder() + "\Operator.dbf"   
#define FILE_OPER_CDX  GetStartupFolder() + "\Operator0.cdx" 

REQUEST Descend           // do not remove !!! Indexes are not created !!!
REQUEST Stuff, StrTran, RAt, Left, Right, Pad, PadC, PadR, PadL
REQUEST DBFCDX

////////////////////////////////////////////////////////////
// Function: open a database program
FUNCTION DbfLogOpen()
   LOCAL nI, bErrHandler, aDbf := {}, cIndex, cFilter
   LOCAL cFileDbf    := FILE_DBF
   LOCAL cFileIndex  := FILE_CDX
   LOCAL cFileDbf2   := FILE_OPER_DBF
   LOCAL cFileIndex2 := FILE_OPER_CDX
   
   IF !FILE( cFileDbf ) // creation of database fields
      AADD( aDbf , {"DATE"     ,"D",  8,0 } )
      AADD( aDbf , {"TIME"     ,"C",  8,0 } )
      AADD( aDbf , {"NEVENT"   ,"N",  3,0 } )
      AADD( aDbf , {"EVENT"    ,"C", 60,0 } )
      AADD( aDbf , {"COMPUTER" ,"C", 20,0 } )
      AADD( aDbf , {"USER"     ,"C", 20,0 } )
      AADD( aDbf , {"KOPER"    ,"N", 10,0 } )
      AADD( aDbf , {"MEMO2"    ,"M", 10,0 } )
      AADD( aDbf , {"VER"      ,"C", 15,0 } )
      AADD( aDbf , {"FILES"    ,"C", 20,0 } )
      AADD( aDbf , {"NFILE"    ,"N", 10,0 } )
      AADD( aDbf , {"NSIZE"    ,"N", 20,3 } )
      AADD( aDbf , {"MODULE"   ,"C", 20,0 } )
      AADD( aDbf , {"REZULT"   ,"C", 50,0 } )
      AADD( aDbf , {"MEMO"     ,"M", 10,0 } )
      AADD( aDbf , {"ID"       ,"+",  8,0 } )
      DBCreate( cFileDbf, aDbf , "DBFCDX")
      USE ( cFileDbf ) ALIAS LOG_DBF VIA "DBFCDX" NEW EXCLUSIVE
      DbfCreateRecno()  
      CLOSE LOG_DBF
   ENDIF

   DELETEFILE(cFileIndex) // delete temporary index - Special !
   IF !FILE( cFileIndex )
      USE ( cFileDbf ) ALIAS LOG_DBF VIA "DBFCDX" NEW EXCLUSIVE
      cIndex  := "DESCEND( DTOS(FIELD->DATE)+FIELD->TIME )"
      cFilter := "!Deleted()"
      INDEX ON &cIndex TAG MAIN TO ( cFileIndex ) // FOR &cFilter - it is for the conditional indexation
      ORDLISTADD( cFileIndex )
      CLOSE LOG_DBF
   ENDIF

   // --------- opening the database with error checking ----------------
   bErrHandler := ErrorBlock( { || Break() } )
   BEGIN SEQUENCE
      USE ( cFileDbf ) ALIAS LOG_DBF VIA "DBFCDX" NEW SHARED  
      ORDLISTADD( cFileIndex )
   RECOVER
      MsgStop( "MAIN database " + cFileDbf  + CRLF + CRLF + " someone is busy, can not open!", "Error !" )
      RETURN .F.
   END SEQUENCE
   ErrorBlock( bErrHandler )

   IF !FILE( cFileDbf2 ) // creating database fields OPERATOR
      aDbf := {}
      AADD( aDbf , {"KOPER"    ,"N",  3,0 } )
      AADD( aDbf , {"OPER"     ,"C", 30,0 } )
      AADD( aDbf , {"ID"       ,"+",  8,0 } )
      DBCreate( cFileDbf2, aDbf , "DBFCDX")
      USE ( cFileDbf2 ) ALIAS OPER VIA "DBFCDX" NEW EXCLUSIVE
      APPEND BLANK
      OPER->KOPER := 0
      OPER->OPER  := "*******"
      FOR nI := 1 TO 9
          APPEND BLANK
          OPER->KOPER := nI
          OPER->OPER  := "Operator - " + HB_NTOS(nI)
      NEXT
      CLOSE OPER
   ENDIF

   DELETEFILE(cFileIndex2) // delete temporary index - Special!
   IF !FILE( cFileIndex2 )
      USE ( cFileDbf2 ) ALIAS OPER VIA "DBFCDX" NEW EXCLUSIVE
      cIndex  := "FIELD->KOPER"
      INDEX ON &cIndex TAG OPER TO ( cFileIndex2 )  
      ORDLISTADD( cFileIndex2 )
      CLOSE OPER
   ENDIF

   // --------- opening the database operators with error checking ----------------
   bErrHandler := ErrorBlock( { || Break() } )
   BEGIN SEQUENCE
      USE ( cFileDbf2 ) ALIAS OPER VIA "DBFCDX" NEW SHARED  
      ORDLISTADD( cFileIndex2 )
   RECOVER
      MsgStop( "OPERATOR database " + cFileDbf2  + CRLF + CRLF + " someone is busy, can not open!", "Error !" )
      RETURN .F.
   END SEQUENCE
   ErrorBlock( bErrHandler )

   SELECT LOG_DBF 
   SET RELATION TO FIELD->KOPER INTO OPER 
   //dbSetRelation( OPER , {|| KOPER}, OPER )
   
RETURN .T.

////////////////////////////////////////////////////////////
// Function: create records in the database
FUNCTION DbfCreateRecno()
   LOCAL n1,n2,nI,nJ,cFile,cModule,kEvent,cEvent,cRez,cMemo
   LOCAL cList

   FOR nI := 1 TO 100
      n1 := hb_RandomInt( 80 )
      n2 := hb_RandomInt( 50 )
      cFile   := "File_" + HB_NTOS(n1-n2) + Chr( 60 + n2 ) + ".zip"
      cModule := "Function "
      kEvent  := hb_RandomInt( 10 ) //IIF( nI % 10 == 0  , 1 , 0  )
      IF kEvent == 1     ; cEvent := "Success!"
      ELSEIF kEvent == 2 ; cEvent := "No entries!"
      ELSEIF kEvent == 3 ; cEvent := "Error!"
      ELSEIF kEvent == 4 ; cEvent := "Record is deleted. DB:" + ALIAS()
      ELSEIF kEvent == 5 ; cEvent := "Archive is created."
      ELSEIF kEvent == 6 ; cEvent := "The file is sent."
      ELSE               ; cEvent := ""
      ENDIF
      cRez   := "Result of the operation " + Chr( 64 + n2 ) + PadL( nI, 20, '0' )
      cList  := "listing ("+ HB_NTOS( nI ) +"): " + cFile + " ,"
      cMemo  := "remark_" + HB_NTOS( nI ) + CRLF
      FOR nJ := 0 TO kEvent
        cMemo += ProcName(nJ) + "(" +HB_NTOS(procline(nJ))+")" + CRLF
        cList += "File_00" + Chr( 48 + nJ ) + ".zip ,"
        IF nJ % 3 == 0
           cList += CRLF
        ENDIF
      NEXT

      APPEND BLANK
      LOG_DBF->DATE     := DATE() - 365 * n2 + n1
      LOG_DBF->TIME     := SECTOTIME( SECONDS() - n1*100 + n2*50 )
      LOG_DBF->NEVENT   := kEvent 
      LOG_DBF->EVENT    := cEvent 
      LOG_DBF->COMPUTER := NetName()
      LOG_DBF->USER     := hb_UserName()
      LOG_DBF->KOPER    := hb_RandomInt( 8 ) 
      LOG_DBF->VER      := "0.01"
      LOG_DBF->MODULE   := cModule
      LOG_DBF->REZULT   := cRez   
      LOG_DBF->MEMO     := cMemo  
      
      IF kEvent == 5 .OR. kEvent == 6 
          LOG_DBF->FILES := cFile  
          LOG_DBF->NFILE := kEvent
          LOG_DBF->NSIZE := (SECONDS() - n1*100 + n2*50 )/1000 * kEvent
          LOG_DBF->MEMO2 := cList  
      ELSE  
          LOG_DBF->MEMO2 := "Recno ¹: "+ HB_NTOS( nI )   
      ENDIF
      // emulation recno deleted
      IF nI % 15 == 0  
        DELETE        
      ENDIF  
    NEXT

RETURN NIL

////////////////////////////////////////////////////////////
// Function: "delete index files"
FUNCTION MyDbfIndexDelete()

   CLOSE OPER
   DELETEFILE(FILE_OPER_CDX) // delete temporary index

   CLOSE LOG_DBF
   DELETEFILE(FILE_CDX) // delete temporary index

   RETURN NIL

/////////////////////////////////////////////////////////////////////
// Function: "logging"
FUNCTION DbfLogWrite(nOper,cFile,cModule,kEvent,cEvent,cRez,cMemo) 
      LOCAL nSel, nIsxSel := SELECT()
      Default nOper := 0, cFile := "", cModule := "", kEvent := 0
      Default cEvent := "", cRez := "", cMemo := ""

      nSel := SELECT("LOG_DBF")
      IF nSel == 0 
         MsgStop( "MAIN database " + FILE_DBF + " is closed! I can not write! ","Error!" )
      ELSE
         // add a record to the database
         SELECT LOG_DBF
         APPEND BLANK
         IF RLock()
            LOG_DBF->DATE     := DATE()
            LOG_DBF->TIME     := TIME()
            LOG_DBF->COMPUTER := NetName()
            LOG_DBF->USER     := hb_UserName()
            LOG_DBF->KOPER    := nOper
            LOG_DBF->VER      := "0.3"
            LOG_DBF->FILES    := cFile  
            LOG_DBF->MODULE   := cModule
            LOG_DBF->NEVENT   := kEvent 
            LOG_DBF->EVENT    := cEvent 
            LOG_DBF->REZULT   := cRez   
            LOG_DBF->MEMO     := cMemo  
            UNLOCK
         ENDIF
      ENDIF

SELECT(nIsxSel)
Return NIL

/////////////////////////////////////////////////////////////////
// Function: window display of open databases and indexes
FUNCTION BASE_TEK()
LOCAL nI, cText, nSel, nOrder, cAlias

cAlias := ALIAS()
nSel := SELECT()
IF nSel == 0
   cText := "No open databases !" + CRLF + CRLF   
   MsgInfo( cText, "Open the database" )
   RETURN NIL
ENDIF

nOrder := INDEXORD() // remember the main index 

cText := "Open DB - alias: "+Alias()+"()" + CRLF + CRLF
cText += "Open index files: " + CRLF + CRLF 
FOR nI := 1 TO 100
   cAlias := ALLTRIM( DBORDERINFO(DBOI_FULLPATH,,ORDNAME(nI)) )
   IF cAlias == ""
      EXIT
   ELSE
      DBSetOrder( nI )
      cText += cAlias + " " + CRLF + "Focus index: " + ORDSETFOCUS() + CRLF 
      cText += " Key index: [" + DBORDERINFO( DBOI_EXPRESSION ) + "]" + CRLF + CRLF
   ENDIF 
NEXT
DBSetOrder( nOrder ) // switch on the main index
cText += CRLF + "The current index = "+STR(nOrder,3)+" , Focus index: " + ORDSETFOCUS() + CRLF
MsgInfo( cText, "Open the database" )

RETURN NIL
