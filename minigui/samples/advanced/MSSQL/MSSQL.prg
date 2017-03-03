/*
 * MiniGui - Microsoft SQL sample
 *
 * Copyright 2011 Alen Uzelac <alen@bbm.hr>
 *
*/

#include "minigui.ch"
#include "dbinfo.ch"

REQUEST SQLMIX, SDDODBC 

Static nSQLConnection 

#ifndef __XHARBOUR__
   #xcommand TRY  => BEGIN SEQUENCE WITH {|oErr| Break( oErr )}
   #xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#endif

*------------------------
Function main()
*------------------------

  nSQLConnection := 0

  SET DATE TO GERMAN
  SET DELETED ON

  DEFINE WINDOW Win1 ;
  AT 0,0 WIDTH 600 HEIGHT 250 ;
  TITLE "Microsoft SQL demo";
  NOSIZE NOMAXIMIZE;
  MAIN

  @ 32 , 30 label   labLabel1   value "Server:"           width 60
  @ 30 ,100 textbox txtServer   value "SERVER\SQLEXPRESS" width 250
  @ 62 , 30 label   labLabel2   value "Database:"         width 60
  @ 60 ,100 textbox txtDatabase value "test"
  @ 92 , 30 label   labLabel3   value "Table:"            width 60
  @ 90 ,100 textbox txtTable    value "demo"
  @ 122, 30 label   labLabel4   value "Username:"         width 65
  @ 120,100 textbox txtUser     value "sa"
  @ 152, 30 label   labLabel5   value "Password:"         width 60
  @ 150,100 textbox txtPass     value "pass"
  
  @ 30,400 button btnButton1 caption "Connect to database" width 150 action ConnectDatabase() 
  @ 60,400 button btnButton2 caption "Create table"        width 150 action Table_Create()
  @ 90,400 button btnButton3 caption "Fill with data"      width 150 action Table_Fill()
  @120,400 button btnButton4 caption "Browse data"         width 150 action Table_Browse()
  @150,400 button btnButton5 caption "Disconnect"          width 150 action DisconnectDatabase()
  
  END WINDOW
  ShowButtons( .F. )
  Win1.Center
  Win1.Activate
RETURN Nil


PROCEDURE ShowButtons( lShow )
 Win1.btnButton1.enabled := !lShow
 Win1.btnButton2.enabled :=  lShow
 Win1.btnButton3.enabled :=  lShow
 Win1.btnButton4.enabled :=  lShow
 Win1.btnButton5.enabled :=  lShow
 Win1.txtServer.Enabled  := !lShow
 Win1.txtDatabase.Enabled:= !lShow
 Win1.txtTable.Enabled   := !lShow
 Win1.txtUser.Enabled    := !lShow
 Win1.txtPass.Enabled    := !lShow
RETURN


PROCEDURE ConnectDatabase()
 nSQLConnection := SQL_ConnectDatabase( Win1.txtServer.Value, Win1.txtDatabase.Value, Win1.txtUser.Value, Win1.txtPass.Value )

 If nSQLConnection = 0
    msgstop("Connection to server '"+win1.txtServer.value+"' database '"+win1.txtDatabase.value+"' failed.")
 Else
    Win1.btnButton1.Caption := "Connected"
    ShowButtons( .T. )
 EndIf
RETURN


PROCEDURE DisconnectDatabase()
 IF SQL_Disconnect( nSQLConnection ) > 0
    Win1.btnButton1.Caption := "Connect to database"
    ShowButtons(.F.)
 ENDIF   
RETURN


PROCEDURE Table_Create()
 IF SQL_CreateTable( win1.txtTable.value )
    MsgInfo( "Table '"+win1.txtTable.value+"' created." )
 ELSE
    MsgStop( "Table '" + win1.txtTable.value+"' not created." )
 ENDIF
RETURN


PROCEDURE Table_Fill()
 LOCAL nI, nRecords:=100, cStr:="", cDate:=DTOC( Date() )

 FOR nI := 1 to nRecords
  cStr += "('20"+Right(cDate, 2)+"-"+SubStr(cDate, 4, 2)+"-"+Left(cDate, 2)+"',"
  cStr += "'"+Time()+"',"
  cStr += "'Demo text "+AllTrim( Str( nI ) )+"',"
  cStr += "'Table_fill1'),"
 NEXT nI 

 cStr:=left(cStr, len(cStr)-1) // deleting last ,

 IF RDDINFO( RDDI_EXECUTE, "INSERT INTO "+Win1.txtTable.value+" values "+cStr,"SQLMIX" )
    MsgInfo( "Added "+AllTrim(str(nRecords))+" records." )
 ELSE
    MsgStop( "Error executing SQL command." + CRLF + "INSERT INTO "+Win1.txtTable.value+" values "+cStr )
 ENDIF   
RETURN


PROCEDURE Table_Browse()
 LOCAL oError

 TRY 
   DBUSEAREA( .T.,"SQLMIX", "SELECT * FROM "+Win1.txtTable.value, "table" ,,,,nSQLConnection ) 
 CATCH oError
   MsgInfo("Cannot open table '"+Win1.txtTable.value+"' on server '"+Win1.txtServer.value+"'.")
   RETURN
 END  
   
 DEFINE WINDOW Win2 ;
	AT Win1.row+100,Win1.col+10 ;
	WIDTH 500 HEIGHT 400 ;
	TITLE 'Browse MSSQL data' ;
	MODAL;
	FONT 'Arial' SIZE 10 
		    
	ON KEY Escape ACTION ThisWindow.Release
    
	@ 20,20 BROWSE brwBrowse1									;
		WIDTH 460  										;
		HEIGHT 330 										;
		HEADERS { 'Date', 'Time', 'Text', 'Type'} ;
		WIDTHS {   80   ,  80   ,  100  ,  80  } ;
		WORKAREA table ;
		FIELDS { 'table->date', 'table->time', 'table->text', 'table->type'} ;
		JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT, BROWSE_JTFY_LEFT};
		FONT "MS Sans serif" SIZE 09 

 END WINDOW
 ACTIVATE WINDOW Win2
 
 DbCloseArea()
  
RETURN


Function SQL_ConnectDatabase( cServer, cDatabase, cUser, cPassword)
RETURN RDDINFO( RDDI_CONNECT, { "ODBC", "Driver={SQL Server};Server="+cServer+";Database="+cDatabase+";Uid="+cUser+";Pwd="+cPassword+";" },'SQLMIX' ) 

Function SQL_Disconnect( nConnection )
Return RDDINFO(RDDI_DISCONNECT,nConnection) 

Function SQL_CreateTable( cTable )
RETURN RDDINFO( RDDI_EXECUTE, "CREATE TABLE [dbo].["+cTable+"] ( [DATE] date NULL,  [TIME] varchar(8) NULL,  [TEXT] varchar(30) NULL,  [TYPE] varchar(30) NULL)","SQLMIX") 
