/*
 * HARBOUR MINIGUI PROJECT MANAGER - Command Line Version
 *
 * Copyright 2003-2004 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Modified for MiniGUI Extended Distribution by MiniGUI team
*/

//***************************************************************************

ANNOUNCE RDDSYS

#include 'common.ch'

MEMVAR zs , os , as , ms , prg , pf , bf , mf , hf , DebugActive , CleanActive
MEMVAR DBS

//***************************************************************************

PROCEDURE Main ( ProjectFile , Param1 , Param2 )

   LOCAL C , i , Line , WinFolder := GetWindowsFolder(), EnvironmentFile
   PUBLIC zs , os , as , ms , prg := {} , pf , bf , mf , hf , DebugActive := .F. , CleanActive := .F.
   PRIVATE DBS

   IF PCount() = 0 .OR. PCount() > 3
      ? "Harbour MiniGUI Project Manager R.24 (Command Line Version)"
      ? "(c) 2003-2004 Roberto Lopez <harbourminigui@gmail.com>"
      ? ''
      ? "Modified for MiniGUI Extended Distribution by MiniGUI team"
      ? ''
      ? "Usage: mpmc <ProjectFile> [/d] [/c]"
      ? ''
      WAIT
      RETURN
   ENDIF

   IF .NOT. File ( ProjectFile )
      ? 'Project File Is Not Found'
      ? ''
      WAIT
      RETURN
   ENDIF

   IF PCount() > 1
      IF AllTrim( Upper( Param1 ) ) = "/D"
         DebugActive := .T.
      ENDIF
      IF ValType( Param2 ) == 'C' .AND. AllTrim( Upper( Param2 ) ) = "/D"
         DebugActive := .T.
      ENDIF
      IF AllTrim( Upper( Param1 ) ) = "/C"
         CleanActive := .T.
      ENDIF
      IF  ValType( Param2 ) == 'C' .AND. AllTrim( Upper( Param2 ) ) = "/C"
         CleanActive := .T.
      ENDIF
   ENDIF

   WinFolder += iif ( Right ( WinFolder , 1 ) != '\' , '\' , '' )
   EnvironmentFile := MemoRead ( WinFolder + 'mpm.ini' )

   IF Empty ( EnvironmentFile )
      SaveEnvironment ( WinFolder )
      EnvironmentFile := MemoRead ( WinFolder + 'mpm.ini' )
   ENDIF

   FOR i := 1 TO MLCount ( EnvironmentFile )

      Line := AllTrim ( MemoLine ( EnvironmentFile , , i ) )

      IF Upper ( Line ) = 'BCCFOLDER'
         bf := SubStr ( Line , 11 , 255 )
      ELSEIF Upper ( Line ) = 'MINIGUIFOLDER'
         mf := SubStr ( Line , 15 , 255 )
      ELSEIF Upper ( Line ) = 'HARBOURFOLDER'
         hf := SubStr ( Line , 15 , 255 )
      ENDIF

   NEXT i
		
   IF ! Empty ( Projectfile )

      C := MemoRead ( ProjectFile )

      FOR i := 1 TO MLCount ( C )

         Line := AllTrim ( MemoLine ( C , , i ) )

         IF  Upper ( Line ) = 'PROJECTFOLDER'
            pf := SubStr ( Line , 15 , 255 )
         ELSEIF Upper ( Line ) = 'ZIPSUPPORT'
            zs := ( Upper ( SubStr ( Line , 12 , 3 ) ) = 'YES' )
         ELSEIF Upper ( Line ) = 'ODBCSUPPORT'
            os := ( Upper ( SubStr ( Line , 13 , 3 ) ) = 'YES' )
         ELSEIF Upper ( Line ) = 'ADSSUPPORT'
            as := ( Upper ( SubStr ( Line , 12 , 3 ) ) = 'YES' )
         ELSEIF Upper ( Line ) = 'MYSQLSUPPORT'
            ms := ( Upper ( SubStr ( Line , 14 , 3 ) ) = 'YES' )
         ELSEIF Right ( Upper ( Line ) , 4 ) == '.PRG' .AND. Left ( Line , 1 ) != '/'
            AAdd ( prg , AllTrim( Line ) )
         ENDIF

      NEXT i

   ENDIF

   IF File ( 'C:\MPM.TMP' )

      RESTORE FROM C:\MPM.TMP ADDITIVE

      IF ( DBS = 'DEBUG' .AND. DebugActive == .F. ) ;
            .OR. ;
            ( DBS = 'NODEBUG' .AND. DebugActive == .T. )
         Clean()
      ENDIF

   ELSE

      Clean()

   ENDIF

   IF DebugActive == .T.
      DBS := 'DEBUG'
   ELSE
      DBS := 'NODEBUG'
   ENDIF

   SAVE TO C:\MPM.TMP ALL LIKE DBS

   Build()

   ? ''
   ? 'Finished.'
   ? ''
   WAIT

RETURN

//***************************************************************************

PROCEDURE Build

   LOCAL MakeName
   LOCAL ParamString
   LOCAL Out := ''
   LOCAL i
   LOCAL PROJECTFOLDER := pf + iif ( Right ( pf , 1 ) != '\' , '\' , '' )
   LOCAL ZIPSUPPORT := zs
   LOCAL ODBCSUPPORT := os
   LOCAL ADSSUPPORT := as
   LOCAL MYSQLSUPPORT := ms
   LOCAL BCCFOLDER  := bf + iif ( Right ( bf , 1 ) != '\' , '\' , '' )
   LOCAL MINIGUIFOLDER := mf + iif ( Right ( mf , 1 ) != '\' , '\' , '' )
   LOCAL HARBOURFOLDER := hf + iif ( Right ( hf , 1 ) != '\' , '\' , '' )
   LOCAL PRGFILES  := prg

   SetCurrentFolder ( pf )

   DELETE FILE ( PROJECTFOLDER + 'End.Txt' )

   CreateFolder ( PROJECTFOLDER + 'OBJ' )

   Out := Out + 'HARBOUR_EXE = ' + HARBOURFOLDER + 'BIN\HARBOUR.EXE'  + Chr( 13 ) + Chr( 10 )
   Out := Out + 'CC = ' + BCCFOLDER + 'BIN\BCC32.EXE'  + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'ILINK_EXE = ' + BCCFOLDER + 'BIN\ILINK32.EXE'  + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'BRC_EXE = ' + BCCFOLDER + 'BIN\BRC32.EXE'  + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'APP_NAME = ' + PROJECTFOLDER + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 ) + '.Exe' + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'RC_FILE = ' + MINIGUIFOLDER + 'RESOURCES\MINIGUI.RC'  + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'INCLUDE_DIR = ' + HARBOURFOLDER + 'INCLUDE;' + MINIGUIFOLDER + 'INCLUDE' + ';' + pf + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'CC_LIB_DIR = ' + BCCFOLDER + 'LIB'  + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'HRB_LIB_DIR = ' + HARBOURFOLDER + 'LIB'  + Chr( 13 ) + Chr( 10 )
   Out := Out + 'OBJ_DIR = ' + PROJECTFOLDER + 'OBJ' + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'C_DIR = ' + PROJECTFOLDER + 'OBJ' + Chr( 13 ) + Chr( 10 ) 
   Out := Out + 'USER_FLAGS = ' + Chr( 13 ) + Chr( 10 ) 

   IF DebugActive == .T.
      MemoWrit ( PROJECTFOLDER +  'Init.Cld' , 'OPTIONS NORUNATSTARTUP' )
      Out := Out + 'HARBOUR_FLAGS = /i$(INCLUDE_DIR)  /n /b $(USER_FLAGS)' + Chr( 13 ) + Chr( 10 ) 
   ELSE
      Out := Out + 'HARBOUR_FLAGS = /i$(INCLUDE_DIR)  /n $(USER_FLAGS)' + Chr( 13 ) + Chr( 10 ) 
   ENDIF

   Out := Out + 'COBJFLAGS =  -c -O2 -tW -M  -I' + BCCFOLDER + 'INCLUDE -I$(INCLUDE_DIR) -L' + BCCFOLDER + 'LIB' + Chr( 13 ) + Chr( 10 )

   Out := Out + Chr( 13 ) + Chr( 10 )
   Out := Out + '$(APP_NAME) : $(OBJ_DIR)\' + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 )  + '.obj \' + Chr( 13 ) + Chr( 10 )
   FOR i := 2 TO Len ( PrgFiles )

      IF i == Len ( PrgFiles )
         Out := Out + '  $(OBJ_DIR)\' + Left ( PRGFILES [i] , Len( PRGFILES [i] ) - 4 )  + '.obj' + Chr( 13 ) + Chr( 10 )
      ELSE
         Out := Out + '  $(OBJ_DIR)\' + Left ( PRGFILES [i] , Len( PRGFILES [i] ) - 4 )  + '.obj \' + Chr( 13 ) + Chr( 10 )
      ENDIF

   NEXT i
   Out := Out + Chr( 13 ) + Chr( 10 )

   IF File ( PROJECTFOLDER + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 ) + '.Rc' )
      Out := Out + ' $(BRC_EXE) -d__BORLANDC__ -r -fo' +  PROJECTFOLDER + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 ) + '.Res ' + PROJECTFOLDER + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 ) + '.Rc ' + Chr( 13 ) + Chr( 10 )
   ENDIF

   FOR i := 1 TO Len ( PrgFiles )
      Out := Out + '     echo $(OBJ_DIR)\' +  Left ( PRGFILES [i] , Len( PRGFILES [i] ) - 4 ) +  '.obj + >' + if( i > 1, '>', '' ) + 'b32.bc ' + Chr( 13 ) + Chr( 10 )
   NEXT i

   Out := Out + ' echo ' + BCCFOLDER + 'LIB\c0w32.obj, + >> b32.bc ' + Chr( 13 ) + Chr( 10 )

   Out := Out + ' echo $(APP_NAME),' + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 ) + '.map, + >> b32.bc' + Chr( 13 ) + Chr( 10 )

   Out := Out + ' echo ' + MINIGUIFOLDER + 'LIB\tsbrowse.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo ' + MINIGUIFOLDER + 'LIB\propgrid.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo ' + MINIGUIFOLDER + 'LIB\minigui.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )

   Out := Out + ' echo $(HRB_LIB_DIR)\dll.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\calldll.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\gtgui.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
#ifdef __XHARBOUR__
   Out := Out + ' echo $(HRB_LIB_DIR)\rtl.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\vm.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\rdd.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\dbfntx.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\dbfcdx.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\dbffpt.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbsix.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\lang.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\codepage.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\macro.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\common.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\debug.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\pp.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\pcrepos.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\ct.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\libmisc.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
#else
   Out := Out + ' echo $(HRB_LIB_DIR)\hbcplr.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbrtl.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbvm.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbrdd.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\rddntx.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\rddcdx.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\rddfpt.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbsix.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hblang.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbcpage.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbmacro.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbcommon.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbdebug.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbpp.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbpcre.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbct.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbmisc.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\hbole.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
#endif
   Out := Out + ' echo $(HRB_LIB_DIR)\hbprinter.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\miniprint.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(HRB_LIB_DIR)\socket.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )

   IF ZIPSUPPORT == .T.     
      Out := Out + ' echo $(HRB_LIB_DIR)\ziparchive.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   ENDIF

   IF ODBCSUPPORT == .T.     
      Out := Out + ' echo $(HRB_LIB_DIR)\hbodbc.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
      Out := Out + ' echo $(HRB_LIB_DIR)\odbc32.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   ENDIF

   IF ADSSUPPORT == .T.     
      Out := Out + ' echo $(HRB_LIB_DIR)\rddads.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
      Out := Out + ' echo $(HRB_LIB_DIR)\ace32.lib  + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   ENDIF

   IF MYSQLSUPPORT == .T.     
      Out := Out + ' echo $(HRB_LIB_DIR)\mysql.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
      Out := Out + ' echo $(HRB_LIB_DIR)\libmysql.lib  + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   ENDIF

   Out := Out + ' echo $(CC_LIB_DIR)\cw32.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(CC_LIB_DIR)\PSDK\msimg32.lib + >> b32.bc' + Chr( 13 ) + Chr ( 10 )
   Out := Out + ' echo $(CC_LIB_DIR)\import32.lib, >> b32.bc' + Chr( 13 ) + Chr ( 10 )

   IF File ( PROJECTFOLDER + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 ) + '.Rc' )
      Out := Out + '      echo ' + PROJECTFOLDER + Left ( PRGFILES [1] , Len( PRGFILES [1] ) - 4 ) + '.Res' + ' + >> b32.bc' + Chr( 13 ) + Chr( 10 )
   ENDIF

   Out := Out + '     echo ' + MINIGUIFOLDER + 'RESOURCES\hbprinter.res + >> b32.bc' + Chr( 13 ) + Chr( 10 )
   Out := Out + '     echo ' + MINIGUIFOLDER + 'RESOURCES\miniprint.res + >> b32.bc' + Chr( 13 ) + Chr( 10 )
   Out := Out + '     echo ' + MINIGUIFOLDER + 'RESOURCES\minigui.res >> b32.bc' + Chr( 13 ) + Chr( 10 )

   IF DebugActive == .T.

      Out := Out + ' $(ILINK_EXE)  -Gn -Tpe -ap -L' + BCCFOLDER + 'LIB' + ' @b32.bc' + Chr( 13 ) + Chr( 10 )

   ELSE

      Out := Out + ' $(ILINK_EXE)  -Gn -Tpe -aa -L' + BCCFOLDER + 'LIB' + ' @b32.bc' + Chr( 13 ) + Chr( 10 )

   ENDIF

   Out := Out + Chr( 13 ) + Chr( 10 )

   FOR i := 1 TO Len ( PrgFiles )

      Out := Out + Chr( 13 ) + Chr( 10 )
      Out := Out + '$(C_DIR)\' + Left ( PRGFILES [i] , Len( PRGFILES [i] ) - 4 ) + '.c : ' + PROJECTFOLDER + Left ( PRGFILES [i] , Len( PRGFILES [i] ) - 4 ) + '.Prg' + Chr( 13 ) + Chr( 10 )
      Out := Out + '    $(HARBOUR_EXE) $(HARBOUR_FLAGS) $** -o$@'  + Chr( 13 ) + Chr( 10 )

      Out := Out + Chr( 13 ) + Chr( 10 )
      Out := Out + '$(OBJ_DIR)\'  + Left ( PRGFILES [i] , Len( PRGFILES [i] ) - 4 ) + '.obj : $(C_DIR)\' +  Left ( PRGFILES [i] , Len( PRGFILES [i] ) - 4 ) + '.c'  + Chr( 13 ) + Chr( 10 )
      Out := Out + '    $(CC) $(COBJFLAGS) -o$@ $**' + Chr( 13 ) + Chr( 10 )

   NEXT i

   MemoWrit ( PROJECTFOLDER +  '_Temp.Bc' , Out )

   MakeName := BCCFOLDER + 'BIN\MAKE.EXE'
   ParamString := '/f' + PROJECTFOLDER + '_Temp.Bc'

   MemoWrit ( PROJECTFOLDER + '_Build.Bat' , '@ECHO OFF' + Chr( 13 ) + Chr( 10 ) + MakeName + ' ' + ParamString + Chr( 13 ) + Chr( 10 ) + 'Echo End > ' + PROJECTFOLDER + 'End.Txt' + Chr( 13 ) + Chr( 10 ) )

   RUN ( PROJECTFOLDER + '_Build.Bat ' )

   DELETE FILE ( PROJECTFOLDER + '_Build.Bat' )
   DELETE FILE ( PROJECTFOLDER + '_Temp.Bc' )
   DELETE FILE ( PROJECTFOLDER + 'B32.Bc' )
   DELETE FILE ( PROJECTFOLDER + 'End.Txt' )

   IF CleanActive == .T.

      Clean ( .F. )

   ENDIF

RETURN

//***************************************************************************

PROCEDURE Clean ( deleteexe )

   LOCAL PROJECTFOLDER := pf + iif ( Right ( pf , 1 ) != '\' , '\' , '' )

   LOCAL aCFiles  [ ADIR ( PROJECTFOLDER + 'OBJ\*.C' ) ]
   LOCAL aObjFiles[ ADIR ( PROJECTFOLDER + 'OBJ\*.OBJ' ) ]
   LOCAL aMapFiles[ ADIR ( PROJECTFOLDER + '*.MAP' ) ]
   LOCAL aTdsFiles[ ADIR ( PROJECTFOLDER + '*.TDS' ) ]
   LOCAL aResFiles[ ADIR ( PROJECTFOLDER + '*.RES' ) ]

   LOCAL i

   DEFAULT deleteexe TO .T.

   ADir ( PROJECTFOLDER + 'OBJ\*.C'   , aCFiles )
   ADir ( PROJECTFOLDER + 'OBJ\*.OBJ' , aObjFiles )
   ADir ( PROJECTFOLDER + '*.MAP'     , aMapFiles )
   ADir ( PROJECTFOLDER + '*.TDS'     , aTdsFiles )
   ADir ( PROJECTFOLDER + '*.RES'     , aResFiles )
	
   FOR i := 1 TO Len ( aCFiles )
      DELETE FILE ( PROJECTFOLDER + 'OBJ\' +  aCFiles[i] )
   NEXT i

   FOR i := 1 TO Len ( aObjFiles )
      DELETE FILE ( PROJECTFOLDER + 'OBJ\' +  aObjFiles[i] )
   NEXT i

   FOR i := 1 TO Len ( aMapFiles )
      DELETE FILE ( PROJECTFOLDER + aMapFiles[i] )
   NEXT i

   FOR i := 1 TO Len ( aTdsFiles )
      DELETE FILE ( PROJECTFOLDER + aTdsFiles[i] )
   NEXT i

   FOR i := 1 TO Len ( aResFiles )
      DELETE FILE ( PROJECTFOLDER + aResFiles[i] )
   NEXT i

   IF deleteexe == .T.
      DELETE FILE ( PROJECTFOLDER + Left ( prg[1] , Len ( prg[1] ) - 4 ) + '.exe' )
   ENDIF

RETURN

//***************************************************************************

PROCEDURE SaveEnvironment ( WinFolder )

   LOCAL c := ''

   c += 'BCCFOLDER=C:\BORLAND\BCC55' + Chr( 13 ) + Chr( 10 )
   c += 'MINIGUIFOLDER=C:\MINIGUI' + Chr( 13 ) + Chr( 10 )
   c += 'HARBOURFOLDER=C:\MINIGUI\HARBOUR' + Chr( 13 ) + Chr( 10 )
   c += 'PROGRAMEDITOR=NOTEPAD.EXE' + Chr( 13 ) + Chr( 10 )

   MemoWrit ( WinFolder + 'mpm.ini' , c )

RETURN

//***************************************************************************

#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

HB_FUNC( GETWINDOWSFOLDER )
{
 char szBuffer[ MAX_PATH + 1 ] = {0};

 GetWindowsDirectory( szBuffer, MAX_PATH );

 hb_retc( szBuffer );
}

HB_FUNC ( CREATEFOLDER )
{
 CreateDirectory( (LPCTSTR) hb_parc(1) , NULL );
}

HB_FUNC ( SETCURRENTFOLDER )
{
 SetCurrentDirectory( (LPCTSTR) hb_parc(1) );
}

#pragma ENDDUMP

//***************************************************************************
