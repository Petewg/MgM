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
PROCEDURE mpmc3( ProjectFile, Param1, Param2 )
*-----------------------------------------------------------------------------*
   LOCAL c
   LOCAL i
   LOCAL Line
   LOCAL IniFolder       := GetStartupFolder()
   LOCAL EnvironmentFile
   LOCAL cError
   LOCAL cError1
   LOCAL cOutputFolder
   LOCAL nloop

   PRIVATE DBS

   // Initialise static var
   prg           := {}
   DebugActive   := .F.
   CleanActive   := .F.

   cOutputFolder := iif( aData[ _MINIGUIEXT ] = ".T.", aData[ _HMGOUTPUTFOLDER ], aData[ _HMG2OUTPUTFOLDER ] )

   /*
   IF PCount() = 0 .OR. PCount() > 3
      MsgBox( "Usage: mpmc <ProjectFile> [/d] [/c]")
      RETURN
   ENDIF
   */

   IF ! File( ProjectFile )
      MsgStop( 'Project File Is Not Found', 'Error' )
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

   IniFolder       += iif( Right( IniFolder , 1 ) != '\' , '\' , "" )
   EnvironmentFile := MemoRead( IniFolder + 'mpm.ini' )

   IF Empty( EnvironmentFile )
      SaveEnvironment( IniFolder )
      EnvironmentFile := MemoRead( IniFolder + 'mpm.ini' )
   ENDIF

   FOR i := 1 TO MLCount( EnvironmentFile )

      Line := AllTrim( MemoLine( EnvironmentFile, NIL, i ) )

      IF Upper( SubStr( Line, 1, 9 ) ) = 'BCCFOLDER'
         bf := SubStr( Line, 11, 255 )

      ELSEIF Upper( SubStr( Line, 1, 13 ) ) = 'MINIGUIFOLDER'
         mf := SubStr( Line, 15, 255 )

      ELSEIF Upper( SubStr( Line, 1, 13 ) ) = 'HARBOURFOLDER'
         hf := SubStr( Line, 15, 255 )
      ENDIF

   NEXT i

   IF ! Empty( ProjectFile )

      c := MemoRead(  ProjectFolder + '\' + ProjectFile )

      FOR i := 1 To MLCount( C )

         Line := AllTrim( MemoLine( c, NIL, i ) )

         IF Upper( Line ) = 'PROJECTFOLDER'
            pf := SubStr( Line , 15 , 255 )
         ELSEIF Upper( Line ) = 'ZIPSUPPORT'
            zs := ( Upper( SubStr( Line , 12 , 3 ) ) = 'YES' )
         ELSEIF Upper( Line ) = 'ODBCSUPPORT'
            os := ( Upper( SubStr( Line , 13 , 3 ) ) = 'YES' )
         ELSEIF Upper( Line ) = 'ADSSUPPORT'
            as := ( Upper( SubStr( Line , 12 , 3 ) ) = 'YES' )
         ELSEIF Upper( Line ) = 'MYSQLSUPPORT'
            ms := ( Upper( SubStr( Line , 14 , 3 ) ) = 'YES' )
         ELSEIF Right( Upper( Line ) , 4 ) == '.PRG'
            AAdd( prg, AllTrim( Line ) )
         ENDIF

      NEXT i

   ENDIF

   IF File( IniFolder + 'MPM.TMP' )

      RESTORE FROM ( IniFolder + 'MPM.TMP' ) ADDITIVE

      IF ( DBS = 'DEBUG'   .AND. DebugActive == .F. )  .OR. ;
         ( DBS = 'NODEBUG' .AND. DebugActive )

         Clean2()

      ENDIF

   ELSE

      Clean2()

   ENDIF

   IF DebugActive
      DBS := 'DEBUG'
   ELSE
      DBS := 'NODEBUG'
   ENDIF

   SAVE TO ( IniFolder + 'MPM.TMP' ) ALL LIKE DBS

   Build2()

   BuildType := iif( aData[ _BUILDTYPE ] = '1', 'full', 'not' )

   IF BuildType # 'full'
      RELEASE WINDOW FORM_SPLASH
   ENDIF

   cError  := MemoRead( '_temp' )
   cError1 := MemoRead( '_temp1' )

   // MsgBox( 'cError= ' + cError )
   IF At( 'ERROR', Upper( cError ) ) > 0 .OR. At( 'FATAL', Upper( cError ) ) > 0
      IF buildtype # 'full'
         viewerrors()
      ELSE
         SetProperty( 'build', 'label_17', 'value', 'Finished with errors' )
         SetProperty( 'build', 'edit_2', 'value', cError )
      ENDIF
   ELSEIF At( 'ERROR', Upper( cError1 ) ) > 0 .OR. At( 'FATAL', Upper( cError1 ) ) > 0
      IF buildtype # 'full'
         viewerrors()
      ELSE
         SetProperty( 'build', 'label_17', 'value', 'Finished with errors' )
         SetProperty( 'build', 'edit_2', 'value', cError1 )
      ENDIF
   ELSE
      PlayOk()

      IF BuildType = 'full'
         SetProperty( 'build', 'label_17', 'blink'    , .F. )
         SetProperty( 'build', 'label_17', 'fontcolor', { 0, 255, 0 } )
         SetProperty( 'build', 'label_17', 'value'    , 'Status: Finished OK' )
         SetProperty( 'build', 'edit_2'  , 'value'    , GetProperty( 'build', 'edit_2', 'value' ) + CRLF + 'Finished OK' )

         DoMethod( 'build', 'button_2', 'setfocus' )

         nloop := Seconds() + 2
         REPEAT
            IF Seconds() > nloop
               IF IsWindowDefined( build )
                  RELEASE WINDOW Build
               ENDIF
            ENDIF

            DO EVENTS

         UNTIL isWindowActive( build )
      ENDIF

      IF aData[ _UPX ] = ".T."
         IF Empty( cOutputFolder )
            WAITRUN( GetStartupFolder() + "\upx.exe --best --lzma" + ProjectFolder + '\' + cFileNoExt( ProjectFile ) + '.exe' )
         ELSE
            WAITRUN( GetStartupFolder() + "\upx.exe --best --lzma" + cOutputFolder + '\' + cFileNoExt( ProjectFile ) + '.exe' )
         ENDIF
      ENDIF

      // MsgBox('executing')

      IF Empty( cOutputFolder )
         EXECUTE FILE ( cFileNoExt( ProjectFile ) + '.exe' )
      ELSE
         EXECUTE File ( cOutputFolder + '\' + cFileNoExt( ProjectFile ) + '.exe' )
      ENDIF

   ENDIF

   FErase( '_temp' )
   FErase( '_temp1' )

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE Build2()
*-----------------------------------------------------------------------------*
   LOCAL MakeName        AS STRING
   LOCAL ParamString     AS STRING
   LOCAL Out             AS STRING  := ""
   LOCAL i               AS NUMERIC
   LOCAL cdados          AS ARRAY
   // LOCAL x1
   LOCAL cLib            AS STRING
   LOCAL cProjectFolder  AS STRING
   LOCAL ProjectFolder   AS STRING  := _getshortpathname( pf )
   LOCAL ZIPSUPPORT      AS STRING  := zs
   LOCAL ODBCSUPPORT     AS STRING  := os
   LOCAL ADSSUPPORT      AS STRING  := as
   LOCAL MYSQLSUPPORT    AS STRING  := ms
   LOCAL BccFolder       AS STRING  := _getshortpathname( bf )
   LOCAL MiniGuiFolder   AS STRING  := _getshortpathname( mf )
   LOCAL HarbourFolder   AS STRING  := iif( aData[ _MINIGUIEXT ] = ".T.", aData[ _HMGMING32HARBOURFOLDER ], aData[ _HMG2MING32HARBOURFOLDER ] ) //_getshortpathname(hf)
   LOCAL PRGFILES        AS STRING  := prg
   LOCAL CINCLUDE        AS STRING  := getincludes()
   LOCAL MINGW32FOLDER   AS STRING  := iif( aData[ _MINIGUIEXT ] = ".T.", aData[ _HMGMING32FOLDER ], aData[ _HMG2MING32FOLDER ] )
   LOCAL XHarbourFolder  AS STRING  := iif( aData[ _MINIGUIEXT ] = ".T.", aData[ _HMGXHARBOURFOLDER ], aData[ _HMG2XHARBOURFOLDER ] )
   LOCAL cFile1          AS STRING

   SetCurrentFolder( ProjectFolder )

   DELETE FILE ( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "End.Txt" )

   CreateFolder ( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "OBJ" )


   Out += "PATH = " + MINGW32FOLDER + "\BIN;" + MINGW32FOLDER + "\LIBEXEC\GCC\MINGW32\3.4.5" + ";" + ProjectFolder + CRLF
   Out += "MINGW = " + MINGW32FOLDER + CRLF

   IF aData[ _HARBOUR ] = ".T."
      // Harbour
      Out += "HRB_DIR = " + HarbourFolder  + CRLF   //c:\HMG\harbour
   ELSE
      // Xharbour
      Out += "HRB_DIR = " + XHarbourFolder + CRLF
   ENDIF

   Out += "MINIGUI_INSTALL = " + MiniGuiFolder + CRLF
   Out += "INC_DIR = "         + MiniGuiFolder + iif( Right( MiniGuiFolder , 1 ) != "\" , "\" , "" ) + "INCLUDE" + CRLF
   Out += "OBJ_DIR = "         + ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) + "OBJ"     + CRLF
   Out += "ProjectFolder = "   + ProjectFolder + CRLF

   Out += "CFLAGS = -Wall -mwindows -mno-cygwin -O3" + CRLF

   Out += CRLF

   Out += "SOURCE=" + Left( PrgFiles[ 1 ] , Len( PrgFiles[ 1 ] ) - 4 ) + CRLF

   Out += CRLF

   //all: test.exe $(OBJ_DIR)/test.o $(OBJ_DIR)/test.c
   cFile1 := Left( PrgFiles[ 1 ] , Len( PrgFiles[ 1 ] ) - 4 )
   Out    += "all: " + cFile1 + ".exe $(OBJ_DIR)/" + cFile1 + ".o $(OBJ_DIR)/" + cFile1 + ".c"

   FOR i := 2 TO Len( PrgFiles )

       cFile := Left( PrgFiles[ i ] , Len( PrgFiles[ i ] ) - 4 )

       Out += " $(OBJ_DIR)/" + cFile + ".o $(OBJ_DIR)/" + cFile + ".c"

   NEXT i

   IF aData[ _GUI ] = ".T." // gui mode
      // MsgBox('value= '+ProjectFolder + iif( Right( ProjectFolder , 1 ) != '\' , '\' , "" )+cfile1+'.rc' )
      IF File( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) + cFile1 + ".rc" )
         Out += " $(MINIGUI_INSTALL)/resources/_temp.o "
      ELSE
         IF aData[ _MINIGUIEXT ] = ".T."
            Out += " $(MINIGUI_INSTALL)/resources/hbprinter.o "
            Out += " $(MINIGUI_INSTALL)/resources/miniprint.o "
         ENDIF
         Out += " $(MINIGUI_INSTALL)/resources/minigui.o "
      ENDIF
   ENDIF


   Out += CRLF
   //Out += "   @echo Running the programa" + CRLF
   //Out += "   " + cFile1 + ".exe"         + CRLF
   Out += CRLF

   // test.exe : $(OBJ_DIR)/test.c  $(OBJ_DIR)/test.o
   Out += cFile1 + ".exe  :"
   FOR i := 1 TO Len( PrgFiles )
       cFile := Left( PrgFiles[ i ] , Len( PrgFiles[ i ] ) - 4 )
       Out += " $(OBJ_DIR)/" + cFile + ".o "
   NEXT i

   IF aData[ _GUI ] = ".T." // gui mode
      IF File( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) + cFile1 + ".rc" )
         Out += " $(MINIGUI_INSTALL)/resources/_temp.o "
      ELSE
         IF aData[ _MINIGUIEXT ] = ".T." // extended
            Out += " $(MINIGUI_INSTALL)/resources/hbprinter.o "
            Out += " $(MINIGUI_INSTALL)/resources/miniprint.o "
         ENDIF
         Out += " $(MINIGUI_INSTALL)/resources/minigui.o "
      ENDIF
   ENDIF

   Out += CRLF
   Out += "   gcc -Wall -mno-cygwin -o$(SOURCE).exe "

   IF aData[ _GUI ] = ".T." // gui mode
      Out += " -mwindows "
   ENDIF

   FOR i := 1 TO Len( PRGFILES )
       cFile := Left( PrgFiles[ i ], Len( PrgFiles[ i ] ) - 4 )
       Out   += "$(OBJ_DIR)/" + cFile + ".o "
   NEXT i

   IF aData[ _GUI ] = ".T." // gui mode
      IF File( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) + cFile1 + ".rc" )
         Out += " $(MINIGUI_INSTALL)/resources/_temp.o "
      ELSE
         IF aData[ _MINIGUIEXT ] = ".T." // extended
            Out += " $(MINIGUI_INSTALL)/resources/hbprinter.o "
            Out += " $(MINIGUI_INSTALL)/resources/miniprint.o "
         ENDIF
         Out += " $(MINIGUI_INSTALL)/resources/minigui.o "
      ENDIF
   ENDIF

   Out += "-L$(MINGW)/lib -L$(HRB_DIR)/lib -L$(MINIGUI_INSTALL)/lib -Wl,--start-group "
   ***********include rest of libs here

   IF aData[ _GUI ] = ".T." // gui mode
      IF aData[ _HARBOUR ] = ".T."    //harbour
         IF aData[ _MINIGUIEXT ] = ".T." // extended
            Out += " -lgtgui  -lminigui"
         ELSE
            Out += " -lgtgui -lgui -lminigui"
         ENDIF
      ELSE
         Out += " -lgtgui -lxminigui"
      ENDIF
   ENDIF

   IF aData[ _HARBOUR ] = ".T." // harbour
      IF aData[ _MINIGUIEXT ] = ".T." // extended
         Out += " -lgtwin -ldll  -luser32 -lwinspool -lcomctl32 -lcomdlg32 -lgdi32 -lole32 -loleaut32 -luuid -lwinmm -lvfw32 -lwsock32  -lhbapollo -lhbbmcdx -lhbbtree -lhbclipsm -lhbcommon -lhbcpage -lhbcplr -lhbct -lhbcurl -lhbfbird -lhbgd -lhbhpdf -lhbhsx -lhblang -lhbmacro -lhbmainstd -lhbmisc -lhbmsql  -lhbmzip -lhbnf  -lhbpcre -lhbpgsql -lhbpp -lhbrdd -lhbrtl -lhbsix -lhbsqlit3 -lhbtip -lhbusrrdd -lhbvm -lhbvpdf -lhbw32  -lrddado  -lrddcdx -lrddfpt -lrddntx -lxhb "
      ELSE
         Out += " -lgtwin -ldll  -luser32 -lwinspool -lcomctl32 -lcomdlg32 -lgdi32 -lole32 -loleaut32 -luuid -lwinmm -lvfw32 -lwsock32  -lhbapollo -lhbbmcdx -lhbbtree -lhbclipsm -lhbcommon -lhbcpage -lhbcplr -lhbct -lhbcurl -lhbfbird -lhbgd -lhbhpdf -lhbhsx -lhblang -lhbmacro -lhbmainstd -lhbmisc -lhbmsql  -lhbmzip -lhbzlib -lhbnf  -lhbpcre -lhbpgsql -lhbpp -lhbrdd -lhbrtl -lhbsix -lhbsqlit3 -lhbtip -lhbusrrdd -lhbvm -lhbvpdf -lhbw32  -lrddado  -lrddcdx -lrddfpt -lrddntx -lxhb "
      ENDIF
   ELSE
      Out += " -lgtwin -ldebug -lvm -lrtl -llang -lcodepage -lmacro -lpp -ldbfntx -ldbfcdx -ldbffpt -lhsx -lhbsix -lcommon -lct -ltip -lpcrepos -luser32 -lwinspool -lole32 -loleaut32 -luuid -lgdi32 -lcomctl32 -lcomdlg32 -lmapi32 -lrdd  -lnulsys -lwinmm -lvfw32 "
   ENDIF

   // console mode
   IF aData[ _CONSOLE ] = ".T."
      Out += " -lgtwin "
   ENDIF

   IF aData[ _CONSOLE ] # ".T."  //  not console
      IF aData[ _HARBOUR ] = ".T." // harbour
         IF aData[ _MINIGUIEXT ] = ".T." // extended
            Out += " -lhbprinter -lminiprint  -lsocket "
         ELSE
            Out += " -lsocket "
         ENDIF
      ELSE
         Out += " -lhbprinter -lminiprint  -lwsock32 "
      ENDIF
   ENDIF

   IF zs  // zip   // En HMG 2 se necesita siempre hbzlib
      IF aData[ _HARBOUR ] = ".T." // harbour
         IF aData[ _MINIGUIEXT ] = ".T." // extended
            Out += " -lhbzlib "
         ENDIF
      ELSE
         Out += " -lzlib "
      ENDIF
   ENDIF

   iif( os, Out += " -lhbodbc -lodbc32 "   , NIL )   // odbc
   iif( as, Out += " -lrddads "            , NIL )   // rddads
   iif( ms, Out += " -lhbmysql -lmysqldll ", NIL )   // mysql

   Out += " -Wl,--end-group "
   Out += CRLF

   FOR i := 1 TO Len( PRGFILES )
       cFile := Left( PrgFiles[ i ] , Len( PrgFiles[ i ] ) - 4 )
       Out   += "$(OBJ_DIR)/" + cFile + ".o    : $(OBJ_DIR)/" + cFile + ".c" + CRLF
       Out   += "   gcc $(CFLAGS)  -I$(INC_DIR) -I$(HRB_DIR)/include -I$(MINGW)/include -I$(MINGW)/LIB/GCC/MINGW32/3.4.5/include -c $(OBJ_DIR)/" + cFile + ".c -o $(OBJ_DIR)/" + cFile + ".o" + CRLF
   NEXT i

   Out += CRLF

   FOR i := 1 To Len( Prgfiles )
       cFile := Left( PrgFiles[ i ] , Len( PrgFiles[ i ] ) - 4 )
       Out   += "$(OBJ_DIR)/" + cFile + ".c   : $(ProjectFolder)/" + cFile + ".prg" + CRLF
       Out   += "   $(HRB_DIR)/bin/harbour.exe $^ -n -w -I$(HRB_DIR)/include -I$(MINIGUI_INSTALL)/include -i$(INC_DIR) -I$(ProjectFolder) -d__WINDOWS__ -o$@ $^" + CRLF
   NEXT i

   Out += CRLF

   IF File( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) + cFile1 + ".rc" )
      Out += "$(MINIGUI_INSTALL)/resources/_temp.o    : $(ProjectFolder)/" + cFile1 + ".rc" + CRLF
      Out += "   windres -i $(ProjectFolder)/" + cFile1 + ".rc -o $(MINIGUI_INSTALL)/resources/_temp.o" + CRLF
   ELSE
      IF aData[ _MINIGUIEXT ] = ".T."
         Out += "$(MINIGUI_INSTALL)/resources/hbprinter.o    : $(MINIGUI_INSTALL)/resources/hbprinter.rc" + CRLF
         Out += "   windres -i $(MINIGUI_INSTALL)/resources/hbprinter.rc -o $(MINIGUI_INSTALL)/resources/hbprinter.o --include-dir $(MINIGUI_INSTALL)/resources" + CRLF

         Out += "$(MINIGUI_INSTALL)/resources/miniprint.o    : $(MINIGUI_INSTALL)/resources/miniprint.rc" + CRLF
         Out += "   windres -i $(MINIGUI_INSTALL)/resources/miniprint.rc -o $(MINIGUI_INSTALL)/resources/miniprint.o --include-dir $(MINIGUI_INSTALL)/resources" + CRLF
      ENDIF

      Out += "$(MINIGUI_INSTALL)/resources/minigui.o    : $(MINIGUI_INSTALL)/resources/minigui.rc" + CRLF
      Out += "   windres -i $(MINIGUI_INSTALL)/resources/minigui.rc -o $(MINIGUI_INSTALL)/resources/minigui.o --include-dir $(MINIGUI_INSTALL)/resources " + CRLF

   ENDIF


   /*  resources// cria arquivo res/ ming criar arquivo .o

   ///mingw
   out += "if exist "+param+".rc copy /b %MINIGUI_INSTALL%\resources\minigui.rc+"+param+".rc+%MINIGUI_INSTALL%\resources\filler _temp.rc >NUL" +CRLF
   //$(ProjectFolder)
    out += "if exist "+param+".rc windres -i _temp.rc -o _temp.o" +CRLF


   ********************* adiciona arquivo res/ mingw adicionar arquivo -o

    IF    exist %1.rc gcc -Wall -o%1.exe %1.o _temp.o                               -L%MINGW%\lib
    if not exist %1.rc gcc -Wall -o%1.exe %1.o %MINIGUI_INSTALL%\resources\minigui.o -L%MINGW%\lib
   ************mingw adicionar arquivo .0
   //Out += '$(MINIGUI_INSTALL)/resources/hbprinter.o    : $(MINIGUI_INSTALL)/resources/hbprinter.rc'+CRLF
   //Out += 'windres -i $(MINIGUI_INSTALL)/resources/hbprinter.rc -o $(MINIGUI_INSTALL)/resources/hbprinter.o" +CRLF


   ************additional libs
   IF Len(aData[ _ADDLIBMINMINGHB ]) > 0
      IF SubStr(aData[ _ADDLIBMINMINGHB ,Len(aData[ _ADDLIBMINMINGHB ]),1) # ';'
         aData[ _ADDLIBMINMINGHB ] := aData[ _ADDLIBMINMINGHB ] + ';'
      ENDIF

      StrTran(aData[ _ADDLIBMINMINGHB ],',',';')

      cdados := {}
      do while .T.
         x1 := At(';',aData[ _ADDLIBMINMINGHB ])
         if x1 > 0
            cLib := SubStr(aData[ _ADDLIBMINMINGHB ],1,x1-1)
            if File(Clib) .AND. At('.LIB',Upper(Clib)) > 0
               AAdd(cdados,Clib)
            ENDIF
            aData[ _ADDLIBMINMINGHB ] := SubStr(aData[ _ADDLIBMINMINGHB ],x1+1,Len(aData[ _ADDLIBMINMINGHB ])-x1)
         ELSE
            exit
         ENDIF
      enddo

      FOR i := 1 TO Len(cdados)
          Out += ' echo ' + cdados[i] + ""
      NEXT
   ENDIF

   IF DebugActive .OR. aData[ _CONSOLE ] = ".T."
      Out += ' $(ILINK_EXE)  -Gn -Tpe -ap -L'+ BccFolder + iif( Right( BccFolder , 1 ) != '\' , '\' , "" ) + 'LIB' + ' @b32.bc' + CRLF
   ELSE
      Out += ' $(ILINK_EXE)  -Gn -Tpe -aa -L'+ BccFolder + iif( Right( BccFolder , 1 ) != '\' , '\' , "" ) + 'LIB' + ' @b32.bc' + CRLF
   ENDIF

   */

   MemoWrit( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "Makefile.Gcc", Out )
   // MsgBox( out )

   MakeName    := MINGW32FOLDER + "\BIN\mingw32-make.exe"
   ParamString := "-f  makefile.gcc 1>_temp 2>_temp1"

   MemoWrit( ProjectFolder + iif( Right( ProjectFolder, 1 ) != "\" , "\" , "" ) + "_Build.Bat", "REM @echo off" + CRLF + "REM SET PATH=;" + CRLF + MakeName + " " + ParamString + CRLF + "Echo End > " + ProjectFolder + iif( Right( ProjectFolder, 1 ) != "\" , "\" , "" ) + "End.Txt" + CRLF )

   Clean2( .F. , CleanActive )

   EXECUTE FILE ( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "_Build.Bat" ) HIDE

   REPEAT
      DO EVENTS
   UNTIL ! File( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "End.txt" )

   DELETE FILE ( ProjectFolder + iif( Right( ProjectFolder , 1 ) != "\" , "\" , "" ) +  "End.Txt" )

RETURN


*-----------------------------------------------------------------------------*
PROCEDURE Clean2( DeleteExe, DeleteAll )
*-----------------------------------------------------------------------------*

   LOCAL ProjectFolder AS STRING  := pf + iif( Right ( pf , 1 ) != "\" , "\" , "" )
   LOCAL aCFiles       AS ARRAY   := ADir( ProjectFolder + "OBJ\*.C" )
   LOCAL aObjFiles     AS ARRAY   := ADir( ProjectFolder + "OBJ\*.O" )
   LOCAL aMapFiles     AS ARRAY   := ADir( ProjectFolder + "*.MAP"   )
   LOCAL aTdsFiles     AS ARRAY   := ADir( ProjectFolder + "*.TDS"   )
   LOCAL i             AS NUMERIC
   LOCAL cOutputFolder AS STRING  := iif( aData[ _MINIGUIEXT ] = ".T.", aData[ _HMGOUTPUTFOLDER ], aData[ _HMG2OUTPUTFOLDER ] )

   DEFAULT DeleteExe TO .T.
   DEFAULT DeleteAll TO .T.

   ADir( ProjectFolder + "OBJ\*.C", aCFiles   )
   ADir( ProjectFolder + "OBJ\*.O", aObjFiles )
   ADir( ProjectFolder + "*.MAP"  , aMapFiles )
   ADir( ProjectFolder + "*.TDS"  , aTdsFiles )

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
      IF Len( Prg ) > 0
         DELETE FILE ( ProjectFolder + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".res" )
      ENDIF

      IF DeleteExe .AND. Len( Prg ) > 0
         IF Empty( cOutputFolder )
            DELETE FILE ( ProjectFolder + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".exe" )
         ELSE
            DELETE FILE ( cOutputFolder + "\" + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".exe" )
         ENDIF
      ENDIF
   ENDIF

   // MsgBox('deleting exe ->PRG= '+PRG[1] )
   IF Empty( cOutputFolder )
      DELETE FILE ( ProjectFolder + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".exe" )
   ELSE
      DELETE FILE ( cOutputFolder + "\" + Left( Prg[ 1 ] , Len( Prg[ 1 ] ) - 4 ) + ".exe" )
   ENDIF

RETURN


*-----------------------------------------------------------------------------*
STATIC FUNCTION GetIncludes()
*-----------------------------------------------------------------------------*
   LOCAL aInclude  AS ARRAY   := {}
   LOCAL x         AS NUMERIC
   LOCAL y         AS STRING  := ""
   LOCAL z         AS NUMERIC
   LOCAL cAddPaths AS STRING  := ""

   FOR x := 1 TO Len( aFmgNames )
       IF aFmgNames[ x ][ 2 ] # '<ProjectFolder>\' .AND. ! Empty( aFmgNames[ x ][ 2 ] )
          z := AScan( aInclude, aFmgNames[ x ][ 2 ] )
          if z == 0
             AAdd( aInclude, aFmgNames[ x ][ 2 ] )
          ENDIF
       ENDIF
   NEXT x

   FOR x := 1 TO Len( aInclude )
       IF ! Empty( aInclude[ x ] )
         y += ';' + _getshortpathname( aInclude[ x ] )
         IF Right( y, 1 ) = '\'
            y := SubStr( y, 1, ( Len( y ) - 1 ) )
         ENDIF
      ENDIF
   NEXT x

   IF aData[ _HMG2 ] = ".T."   // hmg2
      cAddPaths := aData[ _ADDLIBINCHMG2HB ]

   ELSEIF aData[ _MINIGUIEXT ] = ".T." //minigui ext
      IF aData[ _HARBOUR ] = ".T."
         cAddPaths := aData[ _ADDLIBINCMINGHB ]  // harbour
      ELSE
         cAddPaths := aData[ _ADDLIBINCMINGXHB ]  // xharbour
      ENDIF
   ENDIF

   IF Len( cAddPaths ) > 0
      IF SubStr( cAddPaths, Len( cAddPaths ), 1 ) # ';'
         cAddPaths := cAddPaths + ';'
      ENDIF

      cAddPaths := StrTran( cAddPaths, ',', ';' ) //SL : Was missing cAddPaths :=

      IF Len( y ) > 0
         y += ';' + cAddPaths
      ELSE
         y += cAddPaths
      ENDIF

   ENDIF

RETURN( y )
