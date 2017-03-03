/*

  MySqlCli - MySQLClient written in Harbour/HMG

       (c) 2004 Cristobal Molla <cemese@terra.es>
       (c) 2005 Mitja Podgornik <yamamoto@rocketmail.com>
 
   This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
  This application use code from:
  -    Harbour (c) The Harbour project team (www.harbour-project.org)
  -    HMG Harbour Minigui (c) Roberto Lopez (sourceforge.net/projects/harbourminigui)

  March 2005: version 2.0 by Mitja Podgornik
   
   ! rewritten in english
   ! optimized for new Harbour tmysql changes
   + added export/import to/from Dbf
   + dynamic grid fill (only first 1000 records in old version)
   + cosmetic modifications

*/

#include "minigui.ch"

#define PROGRAM "MySqlCli" 
#define BSL hb_ps() // chr(92)  
#define CRLF chr(13)+chr(10)  

Memvar lConnected
Memvar oServer
Memvar cServer
Memvar cUser
Memvar cPaswd

Memvar aDatabases
Memvar aTables
Memvar lTableSelect
Memvar lBaseSelect
Memvar cBase
Memvar cTable

Memvar nScope
Memvar nFrom

*-------------------------------------------------------------*
Procedure Main()
*-------------------------------------------------------------*

	PUBLIC lConnected:= .F.
	PUBLIC oServer:= NIL
	PUBLIC cServer:= "localhost"
	PUBLIC cUser:= "root"
	PUBLIC cPaswd:= ""

	Public aDatabases:={}
	Public aTables:={}
	Public lTableSelect:=.f.
	Public lBaseSelect:=.f.
	Public cBase:=""
	Public cTable:=""

	Public nScope:=500   // max records for select scope (limit)
	Public nFrom:=0      // starting pointer for select scope - Don't touch!

	SET DATE GERMAN
	SET CENTURY ON
	SET MULTIPLE OFF WARNING

	if file("MySqlCli.ini")
	  BEGIN INI FILE "MySqlCli.ini"
		 GET cServer   SECTION "Login" ENTRY "server" 
		 GET cUser     SECTION "Login" ENTRY "user" 
	  END INI
	else
	  BEGIN INI FILE "MySqlCli.ini"
		 SET SECTION "Login" ENTRY "server" TO cServer
		 SET SECTION "Login" ENTRY "user"   TO cUser
	  END INI
	endif

	DEFINE window       F_Main      ;
		at          0, 0                ;
		width       800                 ;
		height      600                 ;
		title       PROGRAM             ;
		icon        "A_ICO_MAIN"        ;
		main                            ;
		nomaximize                      ;
		nosize                          ;
		ON INIT     {|| UpdateMain() }  ;
		ON RELEASE Disconnect()

		DEFINE main menu
			DEFINE popup " &File "
				menuitem "  &Connect  "	      action { || Connect() }	   name mnuConnect
				menuitem "  &Disconnect  "    action { || Disconnect() } name mnuDisconnect
				SEPARATOR
				menuitem "  &Export to DBF  "	action { || SQL2Dbf() }	   name mnusql2dbf
				menuitem "  &Import from DBF  " action { || Dbf2Sql(.t.) } name mnudbf2sql
				SEPARATOR
				menuitem "  &Exit  "  			action F_Main.Release 		name mnuEnd
			END popup

			DEFINE popup " &Help "
				menuitem "About" action ShellAbout( "", PROGRAM+" v.2.0" + CRLF + "Cristobal Molla, Mitja Podgornik" )
			END popup

		END menu

		DEFINE splitbox
			DEFINE toolbar Tbar_1 buttonsize 40, 32 flat	righttext
				button tbbConnect caption "Connect" picture "BMP_32_CONNECT" action {|| Connect() }
				button tbbDisconnect	caption "Disconnect"	picture "BMP_32_DISCONNECT" action {|| Disconnect() }
				button tbbsql2dbf	caption "Export to DBF"	picture "BMP_32_BASE" action {|| SQL2Dbf() }
				button tbbdbf2sql	caption "Import from DBF" picture "BMP_32_TABLE" action {|| Dbf2Sql(.t.) }
			END toolbar
		END splitbox

		DEFINE statusbar
			statusitem ""                                      
			statusitem "" width 200                                      
			statusitem ""  icon "ICO_LEDOFF"      width 035 
		END statusbar

		DEFINE tree TREE_1 at 60,10 width 200 height 460 ;
			ON change    {|| TreeChange() }         ;
			nodeimages   { "BMP_16_SERVER" }        ;
			itemimages   { "BMP_16_ITEMOFF", "BMP_16_ITEMON" } ;
			itemids
		END tree

		DEFINE tab tabInfo at 60, 220	width 565 height 460	value 1

			page "&Structure"
				@ 30, 15 frame frmTable caption "Structure" width 535	height 415 bold
				@ 50, 30 grid  GRD_Table width 505 height 380 ;
					headers { "Name", "Type", "Null", "Key", "Default value", "Extra" } ;
					widths  { 125, 125, 50, 50, 125, 150 } ;
					ON gotfocus  {|| setControl( .T. ) }    ;
					ON lostfocus {|| setControl( .F. ) }
			END page

			page "&Data"
				@ 30, 15 frame  frmData	caption "Data"	width 535 height 415	bold
				@ 50, 30 grid   GRD_Data width 505 height 380 ;
					headers { "" }                     ;
					widths  { 100 }                    ;
					items   { { "" } }                 ;
					value   1                          ;
					ON gotfocus  {|| setControl( .T. ) }    ;
					ON CHANGE {|| AddData(F_Main.GRD_Data.Value), setmessage("Record: "+ntrim(F_Main.GRD_Data.value), 2 ) }    ;
					ON lostfocus {|| setControl( .F. ) }

			END page
		END tab
	END window

	setmessage()
	F_main.tabInfo.Enabled:=.f.
	center window F_Main
	activate window F_Main

	return


*-------------------------------------------------------------*
function Connect()
*-------------------------------------------------------------*
	local nRow, nCol

	if lConnected
	  return nil
	endif

	nRow:= getProperty( "F_Main", "Row" ) + 200
	nCol:= getProperty( "F_Main", "Col" ) + 230

	DEFINE window F_Connect ;
			 at nRow, nCol ;
			 width  315 ;
			 height 205 ;
			 title  " Connect to MySQL server" ;
			 modal ;
			 nosize ;
			 nosysmenu

			@ 10, 10 frame  frm_Data ;
						caption "" ;
						width   285 ;
						height  120 ;
						bold

			@ 34, 20 label lblServer ;
						value "Server" ;
						width 50 ;
						height 21

			@ 64, 20 label lblUser ;
						value "User" ;
						width 50 ;
						height 21

			@ 94, 20 label lblPaswd ;
						value "Password" ;
						width 55 ;
						height 21

			@ 30, 85 textbox txtServer ;
						height 21 ;
						value cServer ;
						width 200 ;
						ON gotfocus {|| setControl( .T. ) }  ;
						ON lostfocus {|| setControl( .F. ) } ;
						maxlength 60

			@ 60, 85 textbox txtUser ;
						height 21 ;
						value cUser ;
						width 100 ;
						ON gotfocus {|| setControl( .T. ) }  ;
						ON lostfocus {|| setControl( .F. ) } ;
						maxlength 40

			@ 90, 85 textbox txtPaswd ;
						height 21 ;
						value cPaswd ;
						width 100 ;
						password ;
						ON gotfocus {|| setControl( .T. ) } ;
						ON lostfocus {|| setControl( .F. ) } ;
						maxlength 40

			@ 140, 225 button btnConnect ;
						  caption "&Connect" ;
						  action {|| Login() } ;
						  width   70 ;
						  height  25

	END window

	activate window F_Connect
	return nil


*-------------------------------------------------------------*
function Login()
*-------------------------------------------------------------*
	cServer := AllTrim(F_Connect.txtServer.Value)
	cUser   := AllTrim(F_Connect.txtUser.Value)
	cPaswd  := AllTrim(F_Connect.txtPaswd.Value)

	if !Empty( cServer ) .AND. !Empty( cUser )
		setMessage( "Connecting to MySQL server...", 1 )
		oServer:= TMySQLServer():New(cServer, cUser, cPaswd)
		if !( oServer:NetErr() )
		  lConnected := .T.
		  F_main.tabInfo.Enabled:=.t.
		  UpdateTree()
		endif
		setMessage()
		UpdateMain()
		BEGIN INI FILE "MySqlCli.ini"
		  SET SECTION "Login" ENTRY "server" TO cServer
		  SET SECTION "Login" ENTRY "user"   TO cUser
		END INI
	endif
	F_connect.release
	return nil


*-------------------------------------------------------------*
function Disconnect()
*-------------------------------------------------------------*
	if lConnected
	  oServer:Destroy()
	  lConnected := .F.
	  F_main.tabinfo.value:=1
	  UpdateTree()
	  UpdateMain()
	  setMessage()
	endif
	F_main.tabInfo.Enabled:=.f.
	lBaseSelect:=.f.
	lTableSelect:=.f.
	F_Main.GRD_Table.DeleteAllItems
	F_Main.GRD_Data.DeleteAllItems
	return nil


*-------------------------------------------------------------*
Procedure UpdateTree()
*-------------------------------------------------------------*
/*
     Node number format: SBBTT
     where: 	S     node Server         1 - 9
					BB    node DataBases     01 - 99
					TT    item Tables        01 - 99
*/

LOCAL i                 AS NUMERIC
LOCAL j                 AS NUMERIC
LOCAL nNodeBase         AS NUMERIC
LOCAL nNodeTable        AS NUMERIC

        IF lConnected

                F_Main.TREE_1.DeleteAllItems
                F_Main.TREE_1.AddItem( oServer:cUser + "@" + cServer, 0, 1 )

                aDatabases:= oServer:ListDBs()
                If oServer:NetErr() 
                  MsGExclamation("Error verifying database list: " + oServer:Error())
                  Return
                endif

                FOR i := 1 TO Len( aDatabases )
                        nNodeBase := Val( "1" + PadL( i, 2, "0" ) )
                        F_Main.TREE_1.AddItem( aDatabases[i], 1, nNodeBase )

                        oServer:SelectDb( aDatabases[i] )
                        If oServer:NetErr() 
                          MsGExclamation("Error connecting to database: " + oServer:Error())
                          Return
                        endif

                        aTables:=oServer:ListTables()
                        If oServer:NetErr() 
                          MsGExclamation("Error verifying tables list: " + oServer:Error())
                          Return 
                        endif

                        FOR j := 1 TO Len( aTables )
                          nNodeTable := Val( nTrim(nNodeBase) + PadL(j, 2, "0") )
                          F_Main.TREE_1.AddItem( aTables[j], nNodeBase, nNodeTable )
                       NEXT

                NEXT

                F_Main.TREE_1.Expand( 1 )
        ELSE
                doMethod( "F_Main", "TREE_1", "DeleteAllItems" )
        ENDIF

        cBase:=""
        cTable:=""
        lBaseSelect:=.f.
        lTableSelect:=.f.

RETURN


*-------------------------------------------------------------*
Procedure UpdateTable()
*-------------------------------------------------------------*
        LOCAL oQuery         AS OBJECT
        LOCAL i              AS NUMERIC
        LOCAL aFile          AS ARRAY

        F_Main.GRD_Table.DeleteAllItems

        IF lConnected
                setMessage( "SQL Query: DESCRIBE " + Upper( cTable ) + "...", 1 )
                oQuery := oServer:Query( "describe " + cTable )
                IF !(oQuery:Neterr())
                        oQuery:Gotop()
                        F_Main.GRD_Data.DisableUpdate
                        FOR i := 1 TO oQuery:LastRec()
                                oQuery:GetRow(i)
                                aFile := oQuery:aRow
                                IF !Empty( aFile[1] )
                                        F_Main.GRD_Table.addItem( aFile )
                                ENDIF
                        NEXT
                        F_Main.GRD_Data.EnableUpdate
                ENDIF
                oQuery:Destroy()
                setMessage()
        ENDIF

RETURN


*-------------------------------------------------------------*
Procedure UpdateData()
*-------------------------------------------------------------*
        LOCAL oQuery            AS OBJECT
        LOCAL i                 AS NUMERIC
        LOCAL nColumns          AS NUMERIC
        LOCAL aFields           AS ARRAY
        LOCAL aWidths           AS ARRAY
        LOCAL aTypes            AS ARRAY
        LOCAL aLine             AS ARRAY

        nColumns := Len( getProperty( "F_Main", "GRD_Data", "Item", 1 ) )

        setMessage( "SQL Query: SELECT * FROM " + Upper( cTable), 1)
        oQuery := oServer:Query( "select * from " + cTable + " limit "+ntrim(nFrom)+","+ntrim(nScope) )
        IF !(oQuery:Neterr())
          aFields := ARRAY( oQuery:FCount() )
          aWidths := ARRAY( oQuery:FCount() )
          aTypes  := ARRAY( oQuery:FCount() )
          FOR i := 1 TO oQuery:FCount()
            aFields[i]:= oQuery:FieldName(i)
            aTypes[i]:= oQuery:FieldType(i)
            aWidths[i] := iif( oQuery:FieldLen(i) > Len(oQuery:FieldName(i)), ;
                               oQuery:FieldLen(i)*14,  Len(oQuery:FieldName(i))*14 )
            aWidths[i] := iif( aWidths[i] > 250, 250, aWidths[i] )
          NEXT
        ELSE
          RETURN
        ENDIF

        DO WHILE nColumns != 0
          F_Main.GRD_Data.DeleteColumn( nColumns )
          nColumns--
        ENDDO

        FOR i := 1 TO oQuery:FCount()
          F_Main.GRD_Data.AddColumn( i, aFields[i], aWidths[i], iif(aTypes[i]=="C", 0, 1) )
        NEXT

        oQuery:GoTop()

        set date ansi
        F_Main.GRD_Data.DisableUpdate

        FOR i := 1 TO oQuery:LastRec()
          if (i%100)==0
            DoEvents()
            setmessage("Record: "+ntrim(i), 2)
          endif

          oQuery:GetRow(i)

          aLine := oQuery:aRow
          IF !Empty( aLine[1] )
            F_Main.GRD_Data.addItem( ItemChar(aLine, aTypes) )
          ENDIF
        NEXT

        F_Main.GRD_Data.EnableUpdate
        set date german

        oQuery:Destroy()
        setMessage()

RETURN


*-------------------------------------------------------------*
function ItemChar(aLine, aType)
*-------------------------------------------------------------*
local aRet:={}, i:=0, l:=0

aRet:=array( len(aLine) )
l:=len(aRet)
for i:=1 to l
  do case
    case aType[i]=="N"
      aRet[i]:=ntrim(aLine[i])
    case aType[i]=="D"
      aRet[i]:=dtoc(aLine[i])
    case aType[i]=="L"
      aRet[i]:=iif(aLine[i], ".T.", ".F.")
    otherwise
      aRet[i]:=aLine[i]
  endcase
next
return aRet


*-------------------------------------------------------------*
Procedure UpdateMain()
*-------------------------------------------------------------*
if lConnected
  setProperty( "F_Main", "TREE_1", "Enabled", .T. )
  setProperty( "F_Main", "tabInfo", "Enabled", .T. )
  setProperty( "F_Main", "tbbConnect", "Enabled", .F. )
  setProperty( "F_Main", "tbbDisconnect", "Enabled", .T. )
  setProperty( "F_Main", "tbbSQL2Dbf", "Enabled", .T. )
  setProperty( "F_Main", "tbbDbf2SQL", "Enabled", .T. )
  setProperty( "F_Main", "StatusBar", "Icon", 3, "ICO_LEDON" )
  setProperty( "F_Main", "mnuConnect", "Enabled", .F. )
  setProperty( "F_Main", "mnuDisconnect", "Enabled", .T. )
  setProperty( "F_Main", "mnusql2dbf", "Enabled", .T. )
  setProperty( "F_Main", "mnudbf2sql", "Enabled", .T. )
else
  setProperty( "F_Main", "TREE_1", "Enabled", .F. )
  setProperty( "F_Main", "tabInfo", "Enabled", .F. )
  setProperty( "F_Main", "tbbConnect", "Enabled", .T. )
  setProperty( "F_Main", "tbbDisconnect", "Enabled", .F. )
  setProperty( "F_Main", "tbbSQL2Dbf", "Enabled", .F. )
  setProperty( "F_Main", "tbbDbf2Sql", "Enabled", .F. )
  setProperty( "F_Main", "StatusBar", "Icon", 3, "ICO_LEDOFF" )
  setProperty( "F_Main", "mnuConnect", "Enabled", .T. )
  setProperty( "F_Main", "mnuDisconnect", "Enabled", .F. )
  setProperty( "F_Main", "mnusql2dbf", "Enabled", .F. )
  setProperty( "F_Main", "mnudbf2sql", "Enabled", .F. )
endif
return


*-------------------------------------------------------------*
Procedure TreeChange()
*-------------------------------------------------------------*
	LOCAL aRecords  AS ARRAY
	LOCAL nItem     AS NUMERIC
	LOCAL oQuery    AS OBJECT

	lTableSelect:=.f.
	lBaseSelect:=.f.
	nItem := getProperty( "F_Main", "TREE_1", "Value" )

	DO CASE
	CASE nItem >= 1 .AND. nItem <= 9
		 setMessage( "Databases: " + nTrim(Len(aDatabases)), 1)

	CASE nItem >= 100 .AND. nItem <= 999
		 cBase := getProperty( "F_Main", "TREE_1", "Item", nItem )
		 oServer:SelectDb( cBase )
		 aTables:=oServer:ListTables()
		 setMessage( "Tables in database " + Upper( cBase ) + ": " + nTrim(Len(aTables)), 1)
		 lBaseSelect:=.t.

	CASE nItem >= 10000 .AND. nItem <= 99999
		 cTable := getProperty( "F_Main", "TREE_1", "Item", nItem )
		 nItem := Val( SubStr( nTrim(nItem), 1, 3 ) )
		 cBase := getProperty( "F_Main", "TREE_1", "Item", nItem )
		 oServer:SelectDB( cBase )
		 aTables:=oServer:ListTables()
		 lBaseSelect:=.t.
		 lTableSelect:=.t.

		 nFrom:=0

		 UpdateTable()
		 UpdateData()

		 oQuery := oServer:Query( "select count(*) from " + cTable )
		 IF !(oQuery:Neterr())
			oQuery:Gotop()
			aRecords := oQuery:aRow()
			setMessage( "Records in table " + Upper( cTable ) + ": " + nTrim(aRecords[1]) ,1)
			oQuery:Destroy()
		 ELSE
			RETURN
		 ENDIF
	ENDCASE

	RETURN


*-------------------------------------------------------------*
function setControl( lValue )
*-------------------------------------------------------------*
	if ValType( lValue ) != "L"
	  lValue := .F.
	endif

	if lValue
	  setProperty( thisWindow.Name, this.Name, "BackColor", { 255, 255, 200 } )
	else
	  setProperty( thisWindow.Name, this.Name, "BackColor", { 255, 255, 255 } )
	endif

	return nil


*-------------------------------------------------------------*
function setMessage( cMessage, nItem )
*-------------------------------------------------------------*
	if cMessage==Nil
	  setProperty( "F_Main", "StatusBar", "Item", 1, " " )
	  setProperty( "F_Main", "StatusBar", "Item", 2, " " )
	else
	  setProperty( "F_Main", "StatusBar", "Item", nItem, " "+cMessage )
	endif
	return nil


*-------------------------------------------------------------*
function SQL2Dbf()
*-------------------------------------------------------------*
	local nRow              AS NUMERIC
	local nCol              AS NUMERIC

	local cFileName:=cTable
	local cMap:=""

	if !lTableSelect
	  msginfo("No table selected...", PROGRAM)
	  return nil
	endif

	nRow:= getProperty( "F_Main", "Row" ) + 200
	nCol:= getProperty( "F_Main", "Col" ) + 230

	DEFINE window    F_2Dbf ;
			 at        nRow, nCol ;
			 width     360 ;
			 height    220 ;
			 title     " Export to DBF" ;
			 modal ;
			 nosize

			 @ 10, 10 frame  frm_2Dbf ;
				caption "" ;
				width   335 ;
				height  100 ;
				bold

			 @ 34, 20 label lblFile ;
				 value "Table name:" ;
				 width 70 ;
				 height 21

			 @ 30, 100 textbox txtFile ;
				height 21 ;
				value cFileName ;
				width 200 ;
				ON gotfocus {|| setControl( .T. ) }  ;
				ON lostfocus {|| setControl( .F. ) } ;
				maxlength 60

			 @ 64, 20 label lblMap ;
				 value "Folder:" ;
				 width 70 ;
				 height 21

			@ 60, 100 textbox txtMap ;
			  height 21 ;
			  value BSL+lower(curdir())+BSL ;
			  width 200 ;
			  ON gotfocus {|| setControl( .T. ) } ;
			  ON lostfocus {|| setControl( .F. ) }

			@ 60, 305 button btnFolder ;
			 caption "..." ;
			 action  {|| (F_2Dbf.txtMap.Value:=GetFolder( "Select folder:" )), F_2Dbf.txtMap.SetFocus } ;
			 width 30 ;
			 height 21

		  @ 120, 275 button btn2Dbf ;
			 caption "&Export" ;
			 action  {|| copy2dbf(F_2Dbf.txtMap.Value, F_2Dbf.txtFile.Value), F_2Dbf.Release } ;
			 width   70 ;
			 height  25

		  @ 155, 275 button btn2DbfCancel ;
			 caption "&Cancel" ;
			 action  {|| F_2Dbf.Release } ;
			 width   70 ;
			 height  25

	END window

	activate window F_2Dbf

	return nil

*----------------------------------------*
function copy2dbf(cFolder, cFile)
*----------------------------------------*
	local cMap:=alltrim(cFolder)
	local cFilename:=alltrim(cFile)

	local oQuery, oRow      AS OBJECT
	local i, j              AS NUMERIC
	local aStruct           AS ARRAY
	local aOKType           AS ARRAY
	local cField:=""

	if lConnected

	  if right(cMap,1)!=BSL .and. !empty(cMap)
		 cMap+=BSL
	  endif  
	  cFileName:=cMap+cFileName
	  if !("."$cFileName)
		 cFileName:=cFileName+".dbf"
	  endif  

	  if file(cFileName)
		 if !msgyesno("File " +cFileName+" allready exists! Overwrite?", PROGRAM)
			return nil
		 endif
	  endif

	  if (i:=fcreate(cFileName))>0
		 fclose(i)
	  else
		 msgexclamation("Incorrect Table name...", PROGRAM)
		 return nil
	  endif

	  setMessage( "Exporting table "+cTable+" in "+cFileName+"...", 1)
	  oQuery := oServer:Query( "select * from " + cTable )
	  if !(oQuery:Neterr())

		 aStruct := ARRAY( oQuery:FCount() )
		 aOKType  := ARRAY( oQuery:FCount() )

		 set date ansi

		 for i := 1 TO oQuery:FCount()
			if (oQuery:FieldType(i))$"CNDLM"
			  aOKType[i]:=.t.
			  aStruct[i]:={ oQuery:FieldName(i), ;
								 oQuery:FieldType(i), ;
								 oQuery:FieldLen(i),  ;
								 oQuery:FieldDec(i)   }
			else
			  aOKType[i]:=.f.
			  aStruct[i]:={ oQuery:FieldName(i), "C", 1, 0 }
			endif
		 next

		 set date german
		
		 dbcreate(cFileName, aStruct)
		 
		 use &cFileName alias dbf_ex new

		 oQuery:GoTop()
		 for i:=1 TO oQuery:LastRec()
			if (i%100)==0
			  DoEvents()
			  setmessage("Record: "+ntrim(i), 2)
			endif
			oRow:=oQuery:GetRow(i)
			append blank
	  
			for j:=1 TO len(aStruct)
			  cField:=rtrim(left(aStruct[j][1],10))
			  if aOKType[j]
				 dbf_ex->&cField:=oRow:FieldGet(j)
			  else
				 dbf_ex->&cField:="?"
			  endif
			next
		 next

		 use
		 oQuery:Destroy()
		 setMessage(" Table: "+cFileName, 1)
		 setmessage("Records: "+ntrim(i-1), 2)
		 msginfo("Export finished!", PROGRAM)
	  else
		 msgexclamation("Error exporting file...", PROGRAM)
	  endif
	  setMessage()
	else
	  msgexclamation("Not connected...", PROGRAM)
	endif

	return nil


*-------------------------------------------------------------*
function AddData(nPos)
*-------------------------------------------------------------*
	local oQuery            AS OBJECT
	local i                 AS NUMERIC
	local aTypes            AS ARRAY
	local aLine             AS ARRAY

	if lConnected .and. lTableSelect .and. nPos==F_Main.GRD_Data.Itemcount

	  nFrom:=nFrom+nScope

	  setMessage( "SQL Query: SELECT * FROM " + Upper( cTable), 1)
	  oQuery := oServer:Query( "select * from " + cTable + " limit "+ntrim(nFrom)+","+ntrim(nScope) )
	  if(oQuery:Neterr())
		 aTypes  := ARRAY( oQuery:FCount() )
		 for i:= 1 TO oQuery:FCount()
			aTypes[i]:= oQuery:FieldType(i)
		 next
	  else
		 nFrom:=0
		 return nil
	  endif

	  oQuery:GoTop()

	  set date ansi
	  F_Main.GRD_Data.DisableUpdate

	  for i := 1 TO oQuery:LastRec()
		 if (i%100)==0
			setmessage("Record: "+ntrim(i), 2)
		 endif

		 oQuery:GetRow(i)

		 aLine := oQuery:aRow
		 if !Empty( aLine[1] )
			F_Main.GRD_Data.addItem( ItemChar(aLine, aTypes) )
		 endif
	  next

	  F_Main.GRD_Data.EnableUpdate
	  set date german

	  oQuery:Destroy()
	  setMessage()

	  F_Main.GRD_Data.Value:=nPos

	endif

	return nil


*------------------------------------------------------*
function wgwin( s )
*------------------------------------------------------*

// 437
s:=strtran(s,"^",chr(200))
s:=strtran(s,"~",chr(232))
s:=strtran(s,"[",chr(138))
s:=strtran(s,"{",chr(154))
s:=strtran(s,"@",chr(142))
s:=strtran(s,"`",chr(158))

// 852 ð
s:=strtran(s,chr(208),chr(240))
// 437 ð
s:=strtran(s,"|",chr(240))
// 437 Ð
s:=strtran(s,BSL,chr(208))

// 852 Š
s:=strtran(s,chr(230),chr(138))
// 437 æ
s:=strtran(s,"}",chr(230))
// 852 æ
s:=strtran(s,chr(134),chr(230))

// 852 Æ
s:=strtran(s,chr(143),chr(198))
// 437 Æ
s:=strtran(s,"]",chr(198))


// 852
s:=strtran(s,chr(172),chr(200))
s:=strtran(s,chr(159),chr(232))
s:=strtran(s,chr(231),chr(154))
s:=strtran(s,chr(166),chr(142))
s:=strtran(s,chr(167),chr(158))
s:=strtran(s,chr(209),chr(208))


// 8859-2
s:=strtran(s,chr(169),chr(138))
s:=strtran(s,chr(185),chr(154))
s:=strtran(s,chr(174),chr(142))
s:=strtran(s,chr(190),chr(158))

// navednica (MySql) z dvojnim narekovajem
s:=strtran(s,"'",'"')
return s


*-------------------------------------------------------------*
function dbf2sql(lCreateTable )
*-------------------------------------------------------------*
local l, f
local fh, cInsert, cQuery, i, cFileName, aDbfFiles, aDbfStruct, lError:=.f., cRec
local xField, cField
local nRef:=0, nWrite:=500

if !lBaseSelect
  msginfo("No dababase selected...", PROGRAM)
  return nil
endif

if lConnected

  aDbfFiles:=getfile({{"*.dbf", "*.DBF"}}, "Select files to copy", "", .T., .F. )

  if len(aDbfFiles)==0
    return nil
  endif

  for f:=1 to len(aDbfFiles)

    if !empty(alias())
      dbffile->(dbCloseArea())
    endif

    l:=len(aDbfFiles[f])
    for i:=1 to l-1
      if substr(aDbfFiles[f],l-i,1)==BSL
        exit
      endif
    next

    cFileName:=strtran(lower(right(aDbfFiles[f],i)),".dbf","")

    if Ascan(aTables, cFileName) > 0
      if !msgyesno("Table " +cFileName+" allready exists! Overwrite?", PROGRAM)
        lError:=.t.
        exit
      endif
    endif

    dbUseArea(.T.,, aDbfFiles[f], "dbffile",, .T.)
    aDbfStruct := dbffile->(dbStruct())

    if lCreateTable
      if Ascan(aTables, cFileName) > 0
        oServer:DeleteTable(cFileName)
        if oServer:NetErr()
          lError:=.t.
          MsgExclamation(oServer:Error(), "-1")
          exit
        endif
      endif
  
      oServer:CreateTable(cFileName, aDbfStruct)
      if oServer:NetErr()
        lError:=.t.
        MsgExclamation(oServer:Error(), "0")
        exit
      endif
    endif

    cRec:="/"+alltrim(str(dbffile->(lastrec())))
    fh:=fcreate("dump.sql")

    if fh<0
      lError:=.t.
      msgexclamation("Handle create?")
      exit
    endif
    
    cInsert:="INSERT INTO "+cFileName+" VALUES "+CRLF
    fwrite(fh, cInsert)
    
    do while !dbffile->(eof())

      cQuery:="("
     
      for i:= 1 to dbffile->(FCount())
        xField:=nil
        xField:=dbffile->(fieldget(i))
        do case
          case valtype(xField)=="D"
            cField:="'"+d2c(xField)+"'"
          case valtype(xField)=="C"
            cField:=alltrim(xField)
            cField:=wgwin(cField)
            cField:="'"+cField+"'"
          case valtype(xField)=="M"
            cField:=memotran(alltrim(xField),"", "")
            cField:=wgwin(cField)
            cField:="'"+cField+"'"
          case valtype(xField)=="N"
            cField:=SQLTrim(xField,aDbfStruct[i, 4])
          case valtype(xField)=="L"
             cField:=l2c(xField)
        endcase
        cQuery:=cQuery+cField+","
        
      next
      // remove last ","
      cQuery:=left(cQuery,len(cQuery)-1)+")"

      fwrite(fh, cQuery)

      nRef++

      dbffile->(dbSkip())
      
      // write after each nWrite records!
      if nRef==nWrite
        DoEvents()
        setmessage(cBase+"."+cFileName+": "+ltrim(Str(dbffile->(RecNo())))+cRec, 1)
        nRef:=0
        if !MySQL_Dump(fh)
          lError:=.t.
          exit         
        endif
        fclose(fh)
        erase dump.sql
        fh:=fcreate("Dump.sql")
        if fh<1
          MsgExclamation("Handle create?")
          lError:=.t.
          exit
        endif
        fwrite(fh, cInsert)
      else
        if !eof()
          fwrite(fh, ", "+CRLF)
        endif
      endif

    enddo

    if nRef>0
      DoEvents()
      setmessage(cBase+"."+cFileName+": "+ltrim(Str(dbffile->(RecNo())))+cRec, 1)
      MySql_Dump(fh)
    endif

    dbffile->(dbCloseArea())

    fclose(fh)
    erase dump.sql

  next

  if !empty(alias())
    dbffile->(dbCloseArea())
  endif

  if !lError
    UpdateTree()
    MsgInfo("Transfer completed.", PROGRAM)
  endif

  setmessage()

endif

DoEvents()
return nil


*-------------------------------------------------------------*
function MySql_Dump(_fh)
*-------------------------------------------------------------*
local flen, oQuery, lret := .T.

//eof, bof
fLen:=fseek(_fh,0,2)
fseek(_fh,0)
oQuery := oServer:Query( freadstr(_fh, flen) )
if oServer:NetErr() 
  MsGInfo( oServer:Error() )
  lret := .f.
else
  oQuery:Destroy()
endif 
return lret


*-------------------------------------------------------------*
function d2c( _date )
*-------------------------------------------------------------*
local cret := '0000-00-00'
if !empty(_date)
  cret := str(year(_date),4)+"-"+strzero(month(_date),2)+"-"+strzero(day(_date),2)
endif
return cret


*-------------------------------------------------------------*
function SQLtrim( _value, _dec )
*-------------------------------------------------------------*
local cret := "0"
if _dec==nil
  _dec:=0
endif

if _value<>0
  cret := alltrim(str(_value, 30, if(_dec==nil, 0, _dec)))
endif
return cret


*-------------------------------------------------------------*
function l2c( _bool )
*-------------------------------------------------------------*
return iif(_bool, "1", "0")


*-------------------------------------------------------------*
function ntrim( nValue )
*-------------------------------------------------------------*
return alltrim(str(nValue))
