/*
 * HARBOUR MINIGUI PROJECT MANAGER
 *
 * Copyright 2003 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"
#include "ide.ch"

MEMVAR DBS

STATIC zs
STATIC os
STATIC as
STATIC ms
STATIC prg
STATIC pf
STATIC bf
STATIC mf
STATIC hf
STATIC DebugActive
STATIC CleanActive

*-----------------------------------------------------------------------------*
PROCEDURE mpmc( ProjectFile /* "(ExeName).mpm"*/ , Param1 /*DEBUG*/ , Param2 /*INCREMENTAL*/ )
*-----------------------------------------------------------------------------*
   LOCAL c               AS STRING
   LOCAL i               AS NUMERIC
   LOCAL Line            AS STRING
   LOCAL IniFolder       AS STRING  := GetStartupFolder()
   LOCAL EnvironmentFile AS STRING
   LOCAL cError          AS STRING                           //? Not used
   LOCAL nloop           AS NUMERIC
   LOCAL lError          AS LOGICAL
   LOCAL oFile           AS OBJECT
   LOCAL cLine           AS STRING
   LOCAL nPos1           AS NUMERIC
   LOCAL nPos2           AS NUMERIC
   LOCAL nPos3           AS NUMERIC

   PRIVATE DBS           AS STRING

   aError      := {}
   prg         := {}
   DebugActive := .F.
   CleanActive := .F.

   IF aData[ _MINGW32 ] = ".T." // MINGW
      // MsgBox("going to mpmc3")
      mpmc3( ProjectFile, Param1, Param2 )
      RETURN
   ENDIF

   cOutputFolder := aData[ _OUTPUTFOLDER ]

   /*
   IF PCount() = 0 .OR. PCount() > 3
      MsgBox( "Usage: mpmc <ProjectFile> [/d] [/c]")
      RETURN
   ENDIF
   */

   IF ! File( ProjectFile )
      MsgStop( "Project File Is Not Found", "Error" )
      RETURN
   ENDIF

   IF PCount() > 1

      IF AllTrim( Upper( Param1 ) ) = "/D"
         DebugActive := .T.
      ENDIF

      IF ValType( Param2 ) == "C" .AND. AllTrim( Upper( Param2 ) ) = "/D"
         DebugActive := .T.
      ENDIF

      IF AllTrim( Upper( Param1 ) ) = "/C"
         CleanActive := .T.
      ENDIF

      IF  ValType( Param2 ) == "C" .AND. AllTrim( Upper( Param2 ) ) = "/C"
         CleanActive := .T.
      ENDIF

   ENDIF

   IniFolder := FixFolder( IniFolder )

   EnvironmentFile := MemoRead( IniFolder + "mpm.ini" )

   IF Empty( EnvironmentFile )
      SaveEnvironment( IniFolder )
      EnvironmentFile := MemoRead( IniFolder + "mpm.ini" )
   ENDIF

   FOR i := 1 TO MLCount( EnvironmentFile )

       Line := AllTrim( MemoLine( EnvironmentFile , NIL, i ) )

       IF Upper( SubStr( Line, 1, 9 ) ) = "BCCFOLDER"
          bf := SubStr( Line, 11, 255 )
          // MsgBox( "BccFolder= " + AllTrim( bf ) )

       ELSEIF Upper( SubStr( Line, 1, 13 ) ) = "MINIGUIFOLDER"
          mf := SubStr( Line, 15, 255 )
          // MsgBox( "MiniGuiFolder= " + AllTrim( mf ) )

       ELSEIF Upper( SubStr( Line, 1, 13 ) ) = "HARBOURFOLDER"
          hf := SubStr( Line, 15, 255 )
          // MsgBox( "HarbourFolder= " + AllTrim( hf ) )
       ENDIF

   Next i

   IF ! Empty( ProjectFile )

      c := MemoRead(  ProjectFolder + "\" + ProjectFile )

      FOR i := 1 TO MLCount( c )

          Line := AllTrim( MemoLine( c , NIL, i ) )

          DO CASE
             CASE Upper( Line ) = "PROJECTFOLDER"       ;  pf := SubStr( Line , 15 , 255 )
             CASE Upper( Line ) = "ZIPSUPPORT"          ;  zs := ( Upper( SubStr( Line , 12 , 3 ) ) = "YES" )
             CASE Upper( Line ) = "ODBCSUPPORT"         ;  os := ( Upper( SubStr( Line , 13 , 3 ) ) = "YES" )
             CASE Upper( Line ) = "ADSSUPPORT"          ;  as := ( Upper( SubStr( Line , 12 , 3 ) ) = "YES" )
             CASE Upper( Line ) = "MYSQLSUPPORT"        ;  ms := ( Upper( SubStr( Line , 14 , 3 ) ) = "YES" )
             CASE Right( Upper( Line ) , 4 ) == ".PRG"  ;  AAdd( prg , AllTrim( Line ) )
         ENDCASE

      NEXT i

   ENDIF

   IF File( IniFolder + "MPM.TMP" )

      RESTORE FROM( IniFolder + "MPM.TMP" ) ADDITIVE

      IF ( DBS = "DEBUG"   .AND. ! DebugActive )   .OR. ;
         ( DBS = "NODEBUG" .AND. DebugActive   )

         Clean()
      ENDIF

   ELSE

      Clean()

   ENDIF

   IF DebugActive
      DBS := "DEBUG"
   ELSE
      DBS := "NODEBUG"
   ENDIF

   SAVE TO ( IniFolder + "MPM.TMP" ) ALL LIKE DBS

   Build()

   BuildType := iif( aData[ _BUILDTYPE ] = "1", "full", "not" )

   IF BuildType # "full"
      RELEASE WINDOW FORM_SPLASH
   ENDIF

   lError := .F.
   oFile  := TFileRead():New( "_temp" )

   oFile:Open()
   IF oFile:Error()
      MsgBox( oFile:ErrorMsg( "Error File Reading: " ) )
   ELSE
      DO WHILE oFile:MoreToRead()

         cLine := oFile:ReadLine()
         nPos1 := At( "error", cLine )
         nPos2 := At( "Error", cLine )
         nPos3 := At( "Fatal", cLine )

         IF nPos1 > 0 .OR. nPos2 > 0 .OR. nPos3 > 0
            lError := .T.
            AAdd( aError, cline )
         ENDIF

      ENDDO

      oFile:Close()

      IF lError
         IF BuildType # "full"
            ViewErrors()
         ELSE
            SetProperty( "build", "label_17", "value", "Finished with errors" )
            SetProperty( "build", "edit_2", "value", aError[ 1 ] )
            _DefineHotKey( "build", 0,  27, { || BuildExit() } ) // Escape
         ENDIF
      ENDIF

   ENDIF

   IF lError == .F.

      PlayOk()

      IF BuildType = "full"
         SetProperty( "build", "label_17", "blink", .F. )
         SetProperty( "build", "label_17", "fontcolor", { 0, 255, 0 } )
         SetProperty( "build", "label_17", "value", "Status: Finished OK" )
         SetProperty( "build", "edit_2"  , "value", GetProperty( "build", "edit_2", "value" ) + CRLF + "Finished OK" )

         DoMethod( "build", "button_2", "setfocus" )

         nloop := Seconds() + 2
         REPEAT
            IF Seconds() > nloop
               IF IsWindowDefined( Build )
                  RELEASE WINDOW Build
               ENDIF
            ENDIF
            DO EVENTS
         UNTIL isWindowActive( Build )
      ENDIF

      IF aData[ _UPX ] = ".T."
         IF Empty( cOutputFolder )
            WAITRUN( GetStartupFolder() + "\upx.exe --best --lzma " + ProjectFolder + "\" + cFileNoExt( ProjectFile ) + ".exe" )
         ELSE
            WAITRUN( GetStartupFolder() + "\upx.exe --best --lzma " + cOutputFolder + "\" + cFileNoExt( ProjectFile ) + ".exe" )
         ENDIF
      ENDIF

      IF Empty( cOutputFolder )
         EXECUTE File ( cFileNoExt( ProjectFile ) + ".exe" )
      ELSE
         EXECUTE File ( cOutputFolder + "\" + cFileNoExt( ProjectFile ) + ".exe" )
      ENDIF

   ENDIF

   FErase( "_temp" )

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE BuildFixErrors()
*-----------------------------------------------------------------------------*
   IF ! IsWindowDefined( BUILD2 )
      LOAD WINDOW BuildLog AS Build2

      ON KEY F8     OF Build2 ACTION BuildLogDebug()
      ON KEY F5     OF Build2 ACTION BuildLogRun()
      ON KEY ESCAPE OF Build2 ACTION BuildLogClose()
   ENDIF

   IF ! isWindowActive( Build2 )
      ACTIVATE WINDOW Build2
   ELSE
      BuildLogInit( "Build2" )
      SHOW WINDOW Build2
   ENDIF

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE BuildLogInit( Param )
*-----------------------------------------------------------------------------*
   LOCAL cWindow AS STRING

   IF Param = NIL
      cWindow := ThisWindow.Name
   ELSE
      cWindow := Param
   ENDIF

   SetProperty( cWindow, "GRID_2", "CARGO", "File name" )

   DoMethod( cWindow, "GRID_1", "DELETEALLITEMS" )

   AEval( aError, { | cLine | DoMethod( cWindow, "GRID_1", "ADDITEM", { cLine } ) } )

   SetProperty( cWindow, "GRID_1", "VALUE", 1 )

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE BuildExit()
*-----------------------------------------------------------------------------*
   IF isWindowActive( Build )
      RELEASE WINDOW Build
   ENDIF

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE BuildSave()
*-----------------------------------------------------------------------------*
   LOCAL cLocal AS STRING := PutFile( { { "*.log", "*.log" } }, "Save Log", ProjectFolder )

   IF Empty( cLocal )
      RETURN
   ENDIF

   MemoWrit( cLocal, GetProperty( "build", "edit_2", "value" ) )

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE Build
*-----------------------------------------------------------------------------*
   LOCAL MakeName       AS STRING
   LOCAL ParamString    AS STRING
   LOCAL Out            AS STRING  := ""
   LOCAL cAddLib        AS STRING
   LOCAL i              AS NUMERIC
   LOCAL cdados         AS ARRAY
   LOCAL x1             AS NUMERIC
   LOCAL cLib           AS STRING
   LOCAL cProjectFolder AS STRING
   LOCAL ProjectFolder  AS STRING  := _GetShortPathName( pf )
   LOCAL ZIPSupport     AS STRING  := zs
   LOCAL ODBCSupport    AS STRING  := os
   LOCAL ADSSupport     AS STRING  := as
   LOCAL MySQLSupport   AS STRING  := ms
   LOCAL BccFolder      AS STRING  := _GetShortPathName( bf )
   LOCAL MiniGuiFolder  AS STRING  := _GetShortPathName( mf )
   LOCAL HarbourFolder  AS STRING  := _GetShortPathName( hf )
   LOCAL PrgFiles       AS STRING  := Prg
   LOCAL cInclude       AS STRING  := GetIncludes()
   LOCAL xHb            AS LOGICAL

   SetCurrentFolder( ProjectFolder )
   // MsgBox( "ProjectFolder= " + ProjectFolder )
   // MsgBox( "HarbourFolder= " + HarbourFolder )

   DELETE File ( FixFolder( ProjectFolder ) + "End.Txt" )

   CreateFolder( FixFolder( ProjectFolder ) + "OBJ" )

   Out += "HARBOUR_EXE = " + FixFolder( HarbourFolder ) + "BIN\HARBOUR.EXE"  + CRLF
   Out += "CC = "          + FixFolder( BccFolder )     + "BIN\BCC32.EXE"    + CRLF
   Out += "ILINK_EXE = "   + FixFolder( BccFolder )     + "BIN\ILINK32.EXE"  + CRLF
   Out += "BRC_EXE = "     + FixFolder( BccFolder )     + "BIN\BRC32.EXE"    + CRLF

   IF Empty( cOutputFolder )
      Out += "APP_NAME = " + FixFolder( ProjectFolder ) + Left( PrgFiles[ 1 ], Len( PrgFiles[ 1 ] ) - 4 ) + ".Exe" + CRLF
   ELSE
      Out += "APP_NAME = " + FixFolder( cOutputFolder ) + Left( PrgFiles[ 1 ], Len( PrgFiles[ 1 ] ) - 4 ) + ".Exe" + CRLF
   ENDIF

   Out += "RC_FILE = "     + FixFolder( MiniGuiFolder ) + "RESOURCES\MINIGUI.RC"  + CRLF
   Out += "INCLUDE_DIR = " + FixFolder( HarbourFolder ) + "INCLUDE;" + FixFolder( MiniGuiFolder ) + "INCLUDE" + ";" + ProjectFolder + cInclude + CRLF
   Out += "CC_LIB_DIR = "  + FixFolder( BccFolder )     + "LIB"  + CRLF
   Out += "HRB_LIB_DIR = " + FixFolder( HarbourFolder ) + "LIB"  + CRLF
   Out += "OBJ_DIR = "     + FixFolder( ProjectFolder ) + "OBJ"  + CRLF
   Out += "C_DIR = "       + FixFolder( ProjectFolder ) + "OBJ"  + CRLF
   Out += "USER_FLAGS = "  + CRLF

   IF DebugActive
      MemoWrit( FixFolder( ProjectFolder ) +  "Init.Cld" , "OPTIONS NORUNATSTARTUP" )
      Out += "HARBOUR_FLAGS = /i$(INCLUDE_DIR)  /n /m /w /b $(USER_FLAGS)" + CRLF
   ELSE
      Out += "HARBOUR_FLAGS = /i$(INCLUDE_DIR)  /n /m /w $(USER_FLAGS)"    + CRLF
   ENDIF

   Out += "COBJFLAGS =  -c -O2 -tW -M  -I" + FixFolder( BccFolder ) + "INCLUDE -I$(INCLUDE_DIR) -L" + FixFolder( BccFolder ) + "LIB" + CRLF

   Out += CRLF
   Out += "$(APP_NAME) : $(OBJ_DIR)\" + Left( PrgFiles[ 1 ], Len( PrgFiles[ 1 ] ) - 4 )  + ".obj \" + CRLF

   FOR i := 2 TO Len( PrgFiles )

       IF i == Len( PRGFILES )
          Out += "  $(OBJ_DIR)\" + Left( PrgFiles[ i ], Len( PrgFiles[ i ] ) - 4 )  + ".obj" + CRLF
       ELSE
          Out += "  $(OBJ_DIR)\" + Left( PrgFiles[ i ], Len( PrgFiles[ i ] ) - 4 )  + ".obj \" + CRLF
       ENDIF

   NEXT i

   Out += CRLF

   IF File( FixFolder( ProjectFolder ) + Left( PrgFiles[ 1 ] , Len( PrgFiles[ 1 ] ) - 4 ) + ".Rc" )
      Out += " $(BRC_EXE) -d__BORLANDC__ -r -fo" +  FixFolder( ProjectFolder ) + Left( PrgFiles[ 1 ] , Len( PrgFiles[ 1 ] ) - 4 ) + ".Res " + FixFolder( ProjectFolder ) + Left( PrgFiles[ 1 ] , Len( PrgFiles[ 1 ] ) - 4 ) + ".Rc " + CRLF
   ENDIF

   FOR i := 1 TO Len( PrgFiles )
       Out += "     echo $(OBJ_DIR)\" +  Left( PrgFiles[ i ], Len( PrgFiles[ i ] ) - 4 ) +  ".obj + >" + iif( i > 1, ">", "" ) + "b32.bc " + CRLF
   NEXT i

   Out += " echo " + FixFolder( BccFolder ) + "LIB\c0w32.obj, + >> b32.bc " + CRLF

   Out += " echo $(APP_NAME)," + Left( PrgFiles[ 1 ], Len( PrgFiles[ 1 ] ) - 4 ) + ".map, + >> b32.bc" + CRLF
   IF aData[ _GUI ] = ".T." //gui mode
      IF  aData[ _HARBOUR ] = ".T." // harbour
         Out += " echo " + FixFolder( MiniGuiFolder ) + "LIB\minigui.lib  + >> b32.bc" + CRLF
      ELSE
         Out += " echo " + FixFolder( MiniGuiFolder ) + "XLIB\minigui.lib + >> b32.bc" + CRLF
      ENDIF
   ENDIF

   Out += " echo $(HRB_LIB_DIR)\dll.lib + >> b32.bc" + CRLF

   IF aData[ _CONSOLE ] = ".T." // console mode
      Out += " echo $(HRB_LIB_DIR)\gtwin.lib + >> b32.bc" + CRLF
   ENDIF

   IF aData[ _GUI ] = ".T."  // gui mode
      Out += " echo $(HRB_LIB_DIR)\gtgui.lib + >> b32.bc" + CRLF
   ENDIF

   IF aData[ _HARBOUR ] = ".T." // harbour
      cAddLib := aData[ _ADDLIBMINBCCHB ]
   ELSE
      cAddLib := aData[ _ADDLIBMINNCCXHB ]
   ENDIF

   IF Len( cAddLib ) > 0
      IF SubStr( cAddLib, Len( cAddLib ), 1 ) # ";"
         cAddLib += ";"
      ENDIF

      cAddLib := StrTran( cAddLib, ",", ";" )  //? Was missing assignment

      cDados := {}

      DO WHILE .T.
         x1 := At( ";", cAddLib )

         IF x1 > 0
            cLib := SubStr( cAddLib, 1, x1 - 1 )
            IF File( cLib ) .AND. At( ".LIB", Upper( cLib ) ) > 0
               // MsgBox("clib= " +clib)
               AAdd( cdados, cLib )
            // ELSE
               // MsgBox("not found " +clib)
            ENDIF

            cAddLib := SubStr( cAddLib, x1 + 1, Len( cAddLib ) - x1 )

         ELSE
            EXIT
         ENDIF

      ENDDO

      FOR i := 1 TO Len( cdados )
          Out += " echo " + cdados[ i ] + " + >> b32.bc" + CRLF
      NEXT
      // MsgBox(out)
   ENDIF

   xHb := ( aData[ _HARBOUR ] <> ".T." ) // xharbour

   IF xHb == .F.
      Out += " echo $(HRB_LIB_DIR)\hbcplr.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbrtl.lib + >> b32.bc"    + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbvm" + ;
         iif( aData[ _MULTITHREAD ] == ".T." , "mt" , "" ) + ".lib + >> b32.bc" + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbrdd.lib + >> b32.bc"    + CRLF
      Out += " echo $(HRB_LIB_DIR)\rddntx.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\rddcdx.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\rddfpt.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbhsx.lib + >> b32.bc"    + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbsix.lib + >> b32.bc"    + CRLF
      Out += " echo $(HRB_LIB_DIR)\hblang.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbcpage.lib + >> b32.bc"  + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbmacro.lib + >> b32.bc"  + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbcommon.lib + >> b32.bc" + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbdebug.lib + >> b32.bc"  + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbpp.lib + >> b32.bc"     + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbpcre.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbct.lib + >> b32.bc"     + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbmisc.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbole.lib + >> b32.bc"    + CRLF
   ELSE
      Out += " echo $(HRB_LIB_DIR)\rtl.lib + >> b32.bc"      + CRLF
      Out += " echo $(HRB_LIB_DIR)\vm.lib + >> b32.bc"       + CRLF
      Out += " echo $(HRB_LIB_DIR)\rdd.lib + >> b32.bc"      + CRLF
      Out += " echo $(HRB_LIB_DIR)\dbfntx.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\dbfcdx.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\dbffpt.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\hbsix.lib + >> b32.bc"    + CRLF
      Out := " echo $(HRB_LIB_DIR)\lang.lib + >> b32.bc"     + CRLF
      Out += " echo $(HRB_LIB_DIR)\codepage.lib + >> b32.bc" + CRLF
      Out += " echo $(HRB_LIB_DIR)\macro.lib + >> b32.bc"    + CRLF
      Out += " echo $(HRB_LIB_DIR)\common.lib + >> b32.bc"   + CRLF
      Out += " echo $(HRB_LIB_DIR)\debug.lib + >> b32.bc"    + CRLF
      Out += " echo $(HRB_LIB_DIR)\pp.lib + >> b32.bc"       + CRLF
      Out += " echo $(HRB_LIB_DIR)\pcrepos.lib + >> b32.bc"  + CRLF
      Out += " echo $(HRB_LIB_DIR)\ct.lib + >> b32.bc"       + CRLF
      Out += " echo $(HRB_LIB_DIR)\libmisc.lib + >> b32.bc"  + CRLF
   ENDIF

   IF aData[ _CONSOLE ] # ".T."  //  not console
      Out += " echo $(HRB_LIB_DIR)\hbprinter.lib + >> b32.bc" + CRLF
      Out += " echo $(HRB_LIB_DIR)\miniprint.lib + >> b32.bc" + CRLF
      Out += " echo $(HRB_LIB_DIR)\socket.lib    + >> b32.bc" + CRLF
   ENDIF

   IF zs
      IF aData[ _HARBOUR ] = ".T."
         Out += " echo $(HRB_LIB_DIR)\ziparchive.lib + >> b32.bc" + CRLF
      ELSE
         Out += " echo $(HRB_LIB_DIR)\hbzip.lib + >> b32.bc"      + CRLF
      ENDIF
   ENDIF

   IF os
      Out += " echo $(HRB_LIB_DIR)\hbodbc.lib + >> b32.bc" + CRLF
      Out += " echo $(HRB_LIB_DIR)\odbc32.lib + >> b32.bc" + CRLF
   ENDIF

   IF as
      Out += " echo $(HRB_LIB_DIR)\rddads.lib + >> b32.bc" + CRLF
      Out += " echo $(HRB_LIB_DIR)\ace32.lib  + >> b32.bc" + CRLF
   ENDIF

   IF ms
      Out += " echo $(HRB_LIB_DIR)\hbmysql.lib + >> b32.bc"  + CRLF
      Out += " echo $(HRB_LIB_DIR)\libmysql.lib + >> b32.bc" + CRLF
   ENDIF

   Out += " echo $(CC_LIB_DIR)\cw32" + ;
      iif( aData[ _MULTITHREAD ] == ".T." , "mt" , "" ) + ".lib + >> b32.bc" + CRLF
   Out += " echo $(CC_LIB_DIR)\PSDK\msimg32.lib + >> b32.bc" + CRLF
   Out += " echo $(CC_LIB_DIR)\import32.lib, >> b32.bc"      + CRLF

   IF File( FixFolder( ProjectFolder ) + Left( PrgFiles[ 1 ] , Len( PrgFiles[ 1 ] ) - 4 ) + ".Rc" )
      Out += "      echo " + FixFolder( ProjectFolder ) + Left( PrgFiles[ 1 ] , Len( PrgFiles[ 1 ] ) - 4 ) + ".Res" + " + >> b32.bc" + CRLF
   ENDIF

   Out += " echo " + FixFolder( MiniGuiFolder ) + "RESOURCES\hbprinter.res + >> b32.bc" + CRLF
   Out += " echo " + FixFolder( MiniGuiFolder ) + "RESOURCES\miniprint.res + >> b32.bc" + CRLF
   Out += " echo " + FixFolder( MiniGuiFolder ) + "RESOURCES\minigui.res >> b32.bc"     + CRLF

   IF DebugActive .OR. aData[ _CONSOLE ] = ".T."
      Out += " $(ILINK_EXE) -x -Gn -Tpe -ap -L" + FixFolder( BccFolder ) + "LIB" + " @b32.bc" + CRLF
   ELSE
      Out += " $(ILINK_EXE) -x -Gn -Tpe -aa -L" + FixFolder( BccFolder ) + "LIB" + " @b32.bc" + CRLF
   ENDIF

   Out += CRLF

   FOR i := 1 TO Len( PRGFILES )

      Out += CRLF

      IF aPrgNames[ i ][ 2 ] = "<ProjectFolder>\" .OR. Empty( aPrgNames[ i ][ 2 ] )
         CProjectFolder := ProjectFolder + "\"
      ELSE
         CProjectFolder := aPrgNames[ i ][ 2 ]
      ENDIF

      Out += "$(C_DIR)\" + Left( PrgFiles[ i ] , Len( PrgFiles[ i ] ) - 4 ) + ".c : " + FixFolder( CProjectFolder ) + Left( PrgFiles[ i ] , Len( PrgFiles[ i ] ) - 4 ) + ".Prg" + CRLF
      Out += "    $(HARBOUR_EXE) $(HARBOUR_FLAGS) $** -o$@"  + CRLF

      Out += CRLF
      Out += "$(OBJ_DIR)\"  + Left( PrgFiles[ i ] , Len( PrgFiles[ i ] ) - 4 ) + ".obj : $(C_DIR)\" +  Left( PrgFiles[ i ], Len( PrgFiles[ i ] ) - 4 ) + ".c"  + CRLF
      Out += "    $(CC) $(COBJFLAGS) -o$@ $**" + CRLF

   NEXT i

   MemoWrit( FixFolder( ProjectFolder ) +  "_Temp.Bc" , Out )

   MakeName    := FixFolder( BccFolder ) + "BIN\MAKE.EXE"
   ParamString := "/f" + FixFolder( ProjectFolder ) +  "_Temp.Bc"

   MemoWrit( FixFolder( ProjectFolder ) + "_Build.Bat" , ;
             "@echo off" + CRLF + ;
             "SET PATH=;" + CRLF + ;
             MakeName + " " + ParamString + CRLF + ;
             "Echo End > " + FixFolder( ProjectFolder ) + "End.Txt" + CRLF )

   Clean( .F. , CleanActive )

   EXECUTE File( FixFolder( ProjectFolder ) +  "_Build.Bat" ) PARAMETERS "> _temp" HIDE

   REPEAT
      DO EVENTS
   UNTIL ! File( FixFolder( ProjectFolder ) +  "End.txt" )

   DELETE File ( FixFolder( ProjectFolder ) +  "_Build.Bat" )
   DELETE File ( FixFolder( ProjectFolder ) +  "_Temp.Bc"   )
   DELETE File ( FixFolder( ProjectFolder ) +  "B32.Bc"     )
   DELETE File ( FixFolder( ProjectFolder ) +  "End.Txt"    )

RETURN


*-----------------------------------------------------------------------------*
FUNCTION FixFolder( Param AS STRING )
*-----------------------------------------------------------------------------*
   LOCAL cRetVal AS STRING

   IF Right( param , 1 ) != "\"
      cRetval := param + "\"
   ELSE
      cRetval := param
   ENDIF

RETURN( cRetVal )


*-----------------------------------------------------------------------------*
PROCEDURE Clean( DeleteExe AS LOGICAL, DeleteAll AS LOGICAL )
*-----------------------------------------------------------------------------*
   LOCAL ProjectFolder AS STRING  := FixFolder( pf )
   LOCAL aCFiles       AS ARRAY
   LOCAL aObjFiles     AS ARRAY
   LOCAL aMapFiles     AS ARRAY
   LOCAL aTdsFiles     AS ARRAY
   LOCAL i             AS NUMERIC

   DEFAULT DeleteExe TO .T.
   DEFAULT DeleteAll TO .T.

   ASize( aCFiles   , ADir( ProjectFolder + "OBJ\*.C"   ) )
   ASize( aObjFiles , ADir( ProjectFolder + "OBJ\*.OBJ" ) )
   ASize( aMapFiles , ADir( ProjectFolder + "*.MAP"     ) )
   ASize( aTdsFiles , ADir( ProjectFolder + "*.TDS"     ) )

   ADir( ProjectFolder + "OBJ\*.C"  , aCFiles   )
   ADir( ProjectFolder + "OBJ\*.OBJ", aObjFiles )
   ADir( ProjectFolder + "*.MAP"    , aMapFiles )
   ADir( ProjectFolder + "*.TDS"    , aTdsFiles )

   IF DeleteAll
      FOR i := 1 TO Len( aCFiles )
          DELETE FILE ( ProjectFolder + "OBJ\" + aCFiles[ i ] )
      NEXT i

      FOR i := 1 TO Len( aObjFiles )
          DELETE FILE ( ProjectFolder + "OBJ\" +  aObjFiles[ i ] )
      NEXT i
   ENDIF

   FOR i := 1 TO Len( aMapFiles )
       DELETE FILE ( ProjectFolder + aMapFiles[ i ] )
   NEXT i

   FOR i := 1 TO Len( aTdsFiles )
       DELETE FILE ( ProjectFolder + aTdsFiles[ i ] )
   NEXT i

   IF DeleteAll
      IF Len( prg ) > 0
         DELETE FILE ( ProjectFolder + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".res" )
      ENDIF

      IF DeleteExe .AND. Len( Prg ) > 0
         IF Empty( cOutputFolder )
            DELETE FILE ( ProjectFolder + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".exe" )
         ELSE
            DELETE FILE ( FixFolder( cOutputFolder ) + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".exe" )
         ENDIF
      ENDIF
   ENDIF

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE SaveEnvironment( IniFolder AS STRING )
*-----------------------------------------------------------------------------*
   LOCAL c AS STRING := ""

   c += "BccFolder=C:\BORLAND\BCC55"       + CRLF
   c += "MiniGuiFolder=C:\MINIGUI"         + CRLF
   c += "HarbourFolder=C:\MINIGUI\HARBOUR" + CRLF
   c += "PROGRAMEDITOR=NOTEPAD.EXE"        + CRLF

   MemoWrit( IniFolder + "mpm.ini", c )

RETURN


*-----------------------------------------------------------------------------*
STATIC FUNCTION GetIncludes()
*-----------------------------------------------------------------------------*
   LOCAL aInclude AS ARRAY   := {}
   LOCAL x        AS NUMERIC
   LOCAL y        AS STRING  := ""
   LOCAL z        AS NUMERIC

   FOR x := 1 TO Len( aFmgNames )
       IF aFmgNames[ x, 2 ] # "<ProjectFolder>\" .AND. ! Empty( aFmgNames[ x, 2 ] )
          z := AScan( aInclude, aFmgNames[ x, 2 ] )
          IF z == 0
             AAdd( aInclude, aFmgNames[ x, 2 ] )
          ENDIF
       ENDIF
   NEXT x

   FOR x := 1 TO Len( aInclude )
       IF ! Empty( aInclude[ x ] )
          y += ";" + _getshortpathname( aInclude[ x ] )
          IF Right( y, 1 ) = "\"
             y := SubStr( y, 1, ( Len( y ) - 1 ) )
          ENDIF
       ENDIF
   NEXT x

   IF Len( aData[ _ADDLIBINCBCCHB ] ) > 0
      IF SubStr( aData[ _ADDLIBINCBCCHB ], Len( aData[ _ADDLIBINCBCCHB ] ), 1 ) # ";"
         aData[ _ADDLIBINCBCCHB ] := aData[ _ADDLIBINCBCCHB ] + ";"
      ENDIF

      StrTran( aData[ _ADDLIBINCBCCHB ], ",", ";" )  //? Assign result to what?

      y += ";" + aData[ _ADDLIBINCBCCHB ]
   ENDIF

RETURN( y )
