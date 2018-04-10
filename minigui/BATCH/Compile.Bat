@echo off

rem ===========================================================================
rem Compile.bat
rem
rem Kevin Carmody - 2013.04.07
rem
rem Revised by Grigory Filatov - 2013.04.07
rem Revised by Petr Chornyj    - 2016.09.08
rem ===========================================================================

rem If no parameters, display command syntax.
if "%1"==""   goto SYNTAX
if "%1"=="?"  goto SYNTAX
if "%1"=="/?" goto SYNTAX
goto PARPARSE

:SYNTAX
  call %~dp0\ShowCmdOpt.bat
  set MV_PAUSE=Y
  goto END

:SYNTERR
  echo Type Compile.bat ? for syntax.
  set MV_PAUSE=Y
  goto END

:PARPARSE
  rem Initialize local variables.
  set MV_USEXHRB=N
  set MV_INTMODE=G
  set MV_DEBUG=N
  set MV_MTHREAD=N
  set MV_USETASM=N
  set MV_ERRFILE=N
  set MV_PAUSE=N
  set MV_DOCCOMP=Y
  set MV_DOCONLY=N
  set MV_DOCMAIN=Y
  set MV_DORONLY=N
  set MV_DOLINK=Y
  set MV_DOLONLY=N
  set MV_DOEXE=Y
  set MV_DODEL=Y
  set MV_DODONLY=N
  set MV_EXECMD=START
  set MV_SWITCH=
  set MV_CSWITCH=
  set MV_ARG=

  if not defined MG_ROOT call :READ_SETTINGS %~dp0\minigui.cfg

  rem Set default paths to BCC, Harbour, xHarbour, MiniGUI
  if     defined MG_CMP  if "%MG_CMP%"=="XHARBOUR" set MV_USEXHRB=Y
  if not defined MG_BCC  set MG_BCC=c:\borland\bcc55
  if not defined MG_ROOT set MG_ROOT=c:\minigui
  if not defined MG_HRB  set MG_HRB=%MG_ROOT%\harbour
  if not defined MG_LIB  set MG_LIB=%MG_ROOT%\lib
  if not defined MG_XHRB set MG_XHRB=c:\xharbour
  if not defined MG_XLIB set MG_XLIB=%MG_ROOT%\xlib
  rem Initialize local variables.
  if %MV_USEXHRB%==N set MV_HRB=%MG_HRB%
  if %MV_USEXHRB%==N set MV_LIB=%MG_LIB%
  if %MV_USEXHRB%==Y set MV_HRB=%MG_XHRB%
  if %MV_USEXHRB%==Y set MV_LIB=%MG_XLIB%
  set MV_SRC=%1
  if exist _tempobj.rsp del _tempobj.rsp
  if exist _templib.rsp del _templib.rsp
  if exist _tempres.rsp del _tempres.rsp

:PARMORE
  rem Start of parameter parse loop, test for end of parameters
  shift
  if   "%1"=="" goto DEFCHECK
  rem Test for individual parameters: branch down when found, then loop back
  if    %1==?   goto SYNTAX
  if    %1==/?  goto SYNTAX
  if /i %1==/x  goto XHARBSET
  if /i %1==/-x goto HARBSET
  if /i %1==/c  goto CONSSET
  if /i %1==/cg goto CONSGUISET
  if /i %1==/d  goto DEBSET
  if /i %1==/mt goto MTHREADSET
  if /i %1==/t  goto TASMSET
  if /i %1==/w  goto WARNSET
  if /i %1==/e  goto ERRSET
  if /i %1==/p  goto PAUSESET
  if /i %1==/nc goto CCOMPSET
  if /i %1==/co goto CONLYSET
  if /i %1==/ro goto RONLYSET
  if /i %1==/nl goto LINKSET
  if /i %1==/lo goto LONLYSET
  if /i %1==/nx goto EXESET
  if /i %1==/nm goto MAINSET
  if /i %1==/nd goto DELSET
  if /i %1==/do goto DONLYSET
  if /i %1==/xi goto IMMEDSET
  if /i %1==/xw goto WAITSET
  if /i %1==/s  goto ADDSWITCH
  if /i %1==/sc goto ADDCSWITCH
  if /i %1==/b  goto ADDOBJ
  if /i %1==/o  goto ODBCLIB
  if /i %1==/z  goto ZIPLIB
  if /i %1==/a  goto ADSLIB
  if /i %1==/m  goto MYSQLLIB
  if /i %1==/pg goto PGSQLLIB
  if /i %1==/l  goto ADDLIB
  if /i %1==/lg goto ADDGLIB
  if /i %1==/le goto ADDELIB
  if /i %1==/r  goto ADDRES
  if /i %1==/xs goto ADDARG
  echo Unknown compile.bat option %1
  goto SYNTERR

:XHARBSET
  set MV_USEXHRB=Y
  set MV_HRB=%MG_XHRB%
  set MV_LIB=%MG_XLIB%
  goto PARMORE

:HARBSET
  set MV_USEXHRB=N
  set MV_HRB=%MG_HRB%
  set MV_LIB=%MG_LIB%
  goto PARMORE

:CONSSET
  set MV_INTMODE=C
  goto PARMORE

:CONSGUISET
  set MV_INTMODE=M
  goto PARMORE

:DEBSET
  set MV_DEBUG=Y
  goto PARMORE

:MTHREADSET
  set MV_MTHREAD=Y
  goto PARMORE

:TASMSET
  set MV_USETASM=Y
  goto PARMORE

:WARNSET
  if not defined MV_SWITCH set MV_SWITCH=-w -es2
  if     defined MV_SWITCH set MV_SWITCH=%MV_SWITCH% -w -es2
  if not defined MV_CSWITCH set MV_CSWITCH=-w -w-par -w-inl
  if     defined MV_CSWITCH set MV_CSWITCH=%MV_SWITCH% -w -w-par -w-inl
  goto PARMORE

:ERRSET
  set MV_ERRFILE=Y
  goto PARMORE

:PAUSESET
  set MV_PAUSE=Y
  goto PARMORE

:CCOMPSET
  set MV_DOCCOMP=N
  goto PARMORE

:CONLYSET
  set MV_DOCONLY=Y
  goto PARMORE

:RONLYSET
  set MV_DORONLY=Y
  goto PARMORE

:LINKSET
  set MV_DOLINK=N
  goto PARMORE

:LONLYSET
  set MV_DOLONLY=Y
  goto PARMORE

:EXESET
  set MV_DOEXE=N
  goto PARMORE

:MAINSET
  set MV_DOCMAIN=N
  goto PARMORE

:DELSET
  set MV_DODEL=N
  goto PARMORE

:DONLYSET
  set MV_DODONLY=Y
  goto PARMORE

:IMMEDSET
  if     exist %MV_SRC%.bat set MV_EXECMD=call
  if not exist %MV_SRC%.bat set MV_EXECMD=
  goto PARMORE

:WAITSET
  set MV_EXECMD=START /W
  goto PARMORE

:ADDSWITCH
  shift
  if "%1"=="" goto ARGMISS
  if not defined MV_SWITCH set MV_SWITCH=%1
  if     defined MV_SWITCH set MV_SWITCH=%MV_SWITCH% %1
  goto PARMORE

:ADDCSWITCH
  shift
  if "%1"=="" goto ARGMISS
  if not defined MV_CSWITCH set MV_CSWITCH=%1
  if     defined MV_CSWITCH set MV_CSWITCH=%MV_CSWITCH% %1
  goto PARMORE

:ADDOBJ
  shift
  if "%1"=="" goto ARGMISS
  echo %1.obj + >> _tempobj.rsp
  goto PARMORE

:ODBCLIB
  echo %MV_HRB%\lib\hbodbc.lib + >> _templib.rsp
  echo %MV_HRB%\lib\odbc32.lib + >> _templib.rsp
  goto PARMORE

:ZIPLIB
  if %MV_USEXHRB%==Y goto XZIPLIB
  echo %MV_HRB%\lib\ziparchive.lib + >> _templib.rsp
  goto PARMORE

:XZIPLIB
  echo %MV_HRB%\lib\hbzip.lib + >> _templib.rsp
  goto PARMORE

:ADSLIB
  echo %MV_HRB%\lib\rddads.lib + >> _templib.rsp
  echo %MV_HRB%\lib\ace32.lib + >> _templib.rsp
  goto PARMORE

:MYSQLLIB
  echo %MV_HRB%\lib\hbmysql.lib + >> _templib.rsp
  echo %MV_HRB%\lib\libmysql.lib + >> _templib.rsp
  goto PARMORE

:PGSQLLIB
  echo %MV_HRB%\lib\libpq.lib + >> _templib.rsp
  echo %MV_HRB%\lib\hbpgsql.lib + >> _templib.rsp
  goto PARMORE

:ADDLIB
  shift
  if "%1"=="" goto ARGMISS
  echo %MV_HRB%\lib\%1.lib + >> _templib.rsp
  goto PARMORE

:ADDGLIB
  shift
  if "%1"=="" goto ARGMISS
  echo %MV_LIB%\%1.lib + >> _templib.rsp
  goto PARMORE

:ADDELIB
  shift
  if "%1"=="" goto ARGMISS
  echo %1.lib + >> _templib.rsp
  goto PARMORE

:ADDRES
  shift
  if "%1"=="" goto ARGMISS
  echo %1.res + >> _tempres.rsp
  goto PARMORE

:ADDARG
  shift
  if "%1"=="" goto ARGMISS
  if not defined MV_ARG set MV_ARG=%1
  if     defined MV_ARG set MV_ARG=%MV_ARG% %1
  goto PARMORE

:ARGMISS
  echo Missing argument after %0 option.
  goto SYNTERR

:DEFCHECK
  rem Check for additional compiler defines
  if %MV_DOCMAIN%==N                  goto SRCCHECK
  if %MV_INTMODE%==G if %MV_DEBUG%==N goto SRCCHECK
  if %MV_INTMODE%==C                  goto SRCCHECK
  if not defined MV_SWITCH set MV_SWITCH=-d_MIXEDMODE_
  if     defined MV_SWITCH set MV_SWITCH=%MV_SWITCH% -d_MIXEDMODE_

:SRCCHECK
  rem Check that source file exists
  if %MV_DOCONLY%==Y goto CCHECK
  if %MV_DORONLY%==Y goto RCCHECK
  if %MV_DOLONLY%==Y goto OBJCHECK
  if %MV_DODONLY%==Y goto CLEANUP

:PRGCHECK
  rem Check that PRG source exists
  if exist %MV_SRC%.prg goto EXECHECK
  echo Cannot find %MV_SRC%.prg.
  goto SYNTERR

:CCHECK
  rem Check that C source exists
  if exist %MV_SRC%.c goto CCOMP
  echo Cannot find %MV_SRC%.c.
  goto SYNTERR

:RCCHECK
  rem Check that RC source exists
  if exist %MV_SRC%.rc goto RCCOMP
  echo Cannot find %MV_SRC%.rc.
  goto SYNTERR

:OBJCHECK
  rem Check that OBJ file exists
  if exist %MV_SRC%.obj goto EXECHECK
  echo Cannot find %MV_SRC%.obj.
  goto SYNTERR

:EXECHECK
  rem Attempt to delete EXE and report if it is in use
  if %MV_DOCCOMP%==N goto COMPCHECK
  if %MV_DOLINK%==N  goto COMPCHECK
  if %MV_DODONLY%==Y goto CLEANUP
  if exist %MV_SRC%.exe del %MV_SRC%.exe
  if not exist %MV_SRC%.exe goto COMPCHECK
  echo.
  echo Error: %MV_SRC%.exe is currently running.
  echo Close it and compile again.
  echo.
  set MV_PAUSE=Y
  goto END

:COMPCHECK
  rem Check for compile options
  if %MV_DOLONLY%==Y goto RSPCHECK
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_DEBUG%==Y   goto DCOMP
  if %MV_DEBUG%==N   goto NCOMP

:NCOMP
  rem Non-debug compile
  if %MV_ERRFILE%==N %MV_HRB%\bin\harbour %MV_SRC%.prg -n -i%MV_HRB%\include;%MG_ROOT%\include; %MV_SWITCH%
  if %MV_ERRFILE%==Y %MV_HRB%\bin\harbour %MV_SRC%.prg -n -i%MV_HRB%\include;%MG_ROOT%\include; %MV_SWITCH% >%MV_SRC%.err
  if not errorlevel 1 goto CCOMP
  echo.
  echo Compile error.
  echo.
  set MV_PAUSE=Y
  goto END

:DCOMP
  rem Debug compile
  if not exist init.mgd echo Screen Size 50 80 > init.mgd
  if not exist init.cld echo Options NoRunAtStartup > init.cld 
  if %MV_ERRFILE%==N %MV_HRB%\bin\harbour %MV_SRC%.prg -n -b -i%MV_HRB%\include;%MG_ROOT%\include; %MV_SWITCH%
  if %MV_ERRFILE%==Y %MV_HRB%\bin\harbour %MV_SRC%.prg -n -b -i%MV_HRB%\include;%MG_ROOT%\include; %MV_SWITCH% >%MV_SRC%.err
  if not errorlevel 1 goto CCOMP
  echo.
  echo Compile error.
  echo.
  set MV_PAUSE=Y
  goto END

:CCOMP
  rem BCC compile of Harbour output
  if %MV_DOCCOMP%==N goto CLEANUP
  if %MV_USETASM%==Y goto TASMCHECK
  if %MV_ERRFILE%==N %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include; -L%MG_BCC%\lib; %MV_CSWITCH% %MV_SRC%.c
  if %MV_ERRFILE%==Y %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include; -L%MG_BCC%\lib; %MV_CSWITCH% %MV_SRC%.c >>%MV_SRC%.err
  if not errorlevel 1 goto RCCOMP
  echo.
  echo C compile error.
  echo.
  set MV_PAUSE=Y
  goto END

:TASMCHECK
  if exist %MG_BCC%\bin\tasm32.exe goto TCCOMP
  echo.
  echo Assembler TASM32.EXE required but not found in %MG_BCC%\bin.
  echo.
  set MV_PAUSE=Y
  goto END

:TCCOMP
  rem BCC compile with Turbo Assembler of Harbour output
  if %MV_ERRFILE%==N %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include; -L%MG_BCC%\lib; -E%MG_BCC%\bin\tasm32.exe %MV_CSWITCH% %MV_SRC%.c
  if %MV_ERRFILE%==Y %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include; -L%MG_BCC%\lib; -E%MG_BCC%\bin\tasm32.exe %MV_CSWITCH% %MV_SRC%.c >>%MV_SRC%.err
  if not errorlevel 1 goto RCCOMP
  echo.
  echo C compile error.
  echo.
  set MV_PAUSE=Y
  goto END

:RCCOMP
  rem Call resource compiler if needed
  if not exist %MV_SRC%.rc goto RSPCHECK
  if %MV_ERRFILE%==N %MG_BCC%\bin\brc32 -r %MV_SRC%.rc
  if %MV_ERRFILE%==Y %MG_BCC%\bin\brc32 -r %MV_SRC%.rc >>%MV_SRC%.err
  if not errorlevel 1 goto RSPCHECK
  echo.
  echo Resource compile error.
  echo.
  set MV_PAUSE=Y
  goto END

:RSPCHECK
  rem Check for custom RSP file
  if %MV_DOCONLY%==Y goto CLEANUP
  if %MV_DORONLY%==Y goto CLEANUP
  if %MV_DOLINK%==N  goto CLEANUP
  if %MV_DODONLY%==Y goto CLEANUP
  if not exist %MV_SRC%.rsp goto RSPSTART
  if exist _temp.rsp del _temp.rsp
  copy %MV_SRC%.rsp _temp.rsp
  goto LINKCHECK

:RSPSTART
  rem Constuct RSP file for link
  if exist _temp.rsp del _temp.rsp
  echo c0w32.obj + > _temp.rsp
  echo %MV_SRC%.obj + >> _temp.rsp
  if exist _tempobj.rsp type _tempobj.rsp >> _temp.rsp
  echo , + >> _temp.rsp
  echo %MV_SRC%.exe, + >> _temp.rsp
  echo %MV_SRC%.map, + >> _temp.rsp
  if %MV_DEBUG%==Y echo %MV_LIB%\dbginit.obj + >> _temp.rsp
  if %MV_USEXHRB%==N goto HRSP
  if %MV_USEXHRB%==Y goto XRSP

:HRSP
  rem Add to RSP file for Harbour EXE
  if %MV_DEBUG%==N if %MV_INTMODE%==G goto HGRSP
  if %MV_DEBUG%==N if %MV_INTMODE%==C goto HCRSP
  if %MV_DEBUG%==N if %MV_INTMODE%==M goto HMRSP
  if %MV_DEBUG%==Y if %MV_INTMODE%==G goto HMRSP
  if %MV_DEBUG%==Y if %MV_INTMODE%==C goto HCRSP
  if %MV_DEBUG%==Y if %MV_INTMODE%==M goto HMRSP

:HGRSP
  rem Add to RSP file for Harbour GUI EXE
  echo %MV_LIB%\tsbrowse.lib + >> _temp.rsp
  echo %MV_LIB%\propgrid.lib + >> _temp.rsp
  echo %MV_LIB%\minigui.lib + >> _temp.rsp
  echo %MV_HRB%\lib\dll.lib + >> _temp.rsp
  echo %MV_HRB%\lib\gtgui.lib + >> _temp.rsp
  goto HRSPREST

:HCRSP
  rem Add to RSP file for Harbour console EXE
  echo %MV_HRB%\lib\gtwin.lib + >> _temp.rsp
  goto HRSPREST

:HMRSP
  rem Add to RSP file for Harbour mixed mode EXE
  echo %MV_LIB%\tsbrowse.lib + >> _temp.rsp
  echo %MV_LIB%\propgrid.lib + >> _temp.rsp
  echo %MV_LIB%\minigui.lib + >> _temp.rsp
  echo %MV_HRB%\lib\dll.lib + >> _temp.rsp
  echo %MV_HRB%\lib\gtwin.lib + >> _temp.rsp
  echo %MV_HRB%\lib\gtgui.lib + >> _temp.rsp
  goto HRSPREST

:XRSP
  rem Add to RSP file for xHarbour EXE
  if %MV_DEBUG%==N if %MV_INTMODE%==G goto XGRSP
  if %MV_DEBUG%==N if %MV_INTMODE%==C goto XCRSP
  if %MV_DEBUG%==N if %MV_INTMODE%==M goto XMRSP
  if %MV_DEBUG%==Y if %MV_INTMODE%==G goto XMRSP
  if %MV_DEBUG%==Y if %MV_INTMODE%==C goto XCRSP
  if %MV_DEBUG%==Y if %MV_INTMODE%==M goto XMRSP

:XGRSP
  rem Add to RSP file for xHarbour GUI EXE
  echo %MV_LIB%\tsbrowse.lib + >> _temp.rsp
  echo %MV_LIB%\propgrid.lib + >> _temp.rsp
  echo %MV_LIB%\minigui.lib + >> _temp.rsp
  echo %MV_HRB%\lib\dll.lib + >> _temp.rsp
  echo %MV_HRB%\lib\gtgui.lib + >> _temp.rsp
  goto XRSPREST

:XCRSP
  rem Add to RSP file for xHarbour console EXE
  echo %MV_HRB%\lib\gtwin.lib + >> _temp.rsp
  goto XRSPREST

:XMRSP
  rem Add to RSP file for xHarbour mixed mode EXE
  echo %MV_LIB%\tsbrowse.lib + >> _temp.rsp
  echo %MV_LIB%\propgrid.lib + >> _temp.rsp
  echo %MV_LIB%\minigui.lib + >> _temp.rsp
  echo %MV_HRB%\lib\dll.lib + >> _temp.rsp
  echo %MV_HRB%\lib\gtwin.lib + >> _temp.rsp
  echo %MV_HRB%\lib\gtgui.lib + >> _temp.rsp
  goto XRSPREST

:HRSPREST
  rem Continue RSP file for Harbour EXE
  if exist _templib.rsp type _templib.rsp >> _temp.rsp
  echo %MV_HRB%\lib\hbcplr.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbrtl.lib + >> _temp.rsp
  if %MV_MTHREAD%==N echo %MV_HRB%\lib\hbvm.lib + >> _temp.rsp
  if %MV_MTHREAD%==Y echo %MV_HRB%\lib\hbvmmt.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hblang.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbcpage.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbmacro.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbrdd.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbhsx.lib + >> _temp.rsp
  echo %MV_HRB%\lib\rddntx.lib + >> _temp.rsp
  echo %MV_HRB%\lib\rddcdx.lib + >> _temp.rsp
  echo %MV_HRB%\lib\rddfpt.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbsix.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbcommon.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbdebug.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbpp.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbpcre.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbct.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbmisc.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbole.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbtip.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbvpdf.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbwin.lib + >> _temp.rsp
  echo ws2_32.lib + >> _temp.rsp
  if %MV_INTMODE%==C goto RSPEND
  echo %MV_HRB%\lib\hbprinter.lib + >> _temp.rsp
  echo %MV_HRB%\lib\miniprint.lib + >> _temp.rsp
  echo %MV_HRB%\lib\socket.lib + >> _temp.rsp
  goto RSPEND

:XRSPREST
  rem Continue RSP file for xHarbour EXE
  if exist _templib.rsp type _templib.rsp >> _temp.rsp
  echo %MV_HRB%\lib\rtl.lib + >> _temp.rsp
  echo %MV_HRB%\lib\vm.lib + >> _temp.rsp
  echo %MV_HRB%\lib\lang.lib + >> _temp.rsp
  echo %MV_HRB%\lib\codepage.lib + >> _temp.rsp
  echo %MV_HRB%\lib\macro.lib + >> _temp.rsp
  echo %MV_HRB%\lib\rdd.lib + >> _temp.rsp
  echo %MV_HRB%\lib\dbfntx.lib + >> _temp.rsp
  echo %MV_HRB%\lib\dbfcdx.lib + >> _temp.rsp
  echo %MV_HRB%\lib\dbffpt.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbsix.lib + >> _temp.rsp
  echo %MV_HRB%\lib\common.lib + >> _temp.rsp
  echo %MV_HRB%\lib\debug.lib + >> _temp.rsp
  echo %MV_HRB%\lib\pp.lib + >> _temp.rsp
  echo %MV_HRB%\lib\pcrepos.lib + >> _temp.rsp
  echo %MV_HRB%\lib\ct.lib + >> _temp.rsp
  echo %MV_HRB%\lib\libmisc.lib + >> _temp.rsp
  echo %MV_HRB%\lib\tip.lib + >> _temp.rsp
  echo %MV_HRB%\lib\hbvpdf.lib + >> _temp.rsp
  if %MV_INTMODE%==C goto RSPEND
  echo %MV_HRB%\lib\hbprinter.lib + >> _temp.rsp
  echo %MV_HRB%\lib\miniprint.lib + >> _temp.rsp
  echo %MV_HRB%\lib\socket.lib + >> _temp.rsp

:RSPEND
  rem Finish RSP file
  echo import32.lib + >> _temp.rsp
  echo %MG_BCC%\lib\psdk\iphlpapi.lib + >> _temp.rsp
  echo %MG_BCC%\lib\psdk\msimg32.lib + >> _temp.rsp
  if %MV_MTHREAD%==N echo cw32.lib, >> _temp.rsp
  if %MV_MTHREAD%==Y echo cw32mt.lib, >> _temp.rsp
  if exist %MV_SRC%.res echo %MV_SRC%.res + >> _temp.rsp
  if exist _tempres.rsp type _tempres.rsp >> _temp.rsp
  if %MV_INTMODE%==C goto LINKCHECK
  echo %MG_ROOT%\resources\hbprinter.res + >> _temp.rsp
  echo %MG_ROOT%\resources\miniprint.res + >> _temp.rsp
  echo %MG_ROOT%\resources\minigui.res >> _temp.rsp

:LINKCHECK
  rem Check for link options
  if %MV_INTMODE%==C goto CLINK
  if %MV_INTMODE%==M goto CLINK

:GLINK
  rem Link for GUI EXE
  if %MV_ERRFILE%==N %MG_BCC%\bin\ilink32 -x -Gn -Tpe -aa -L%MG_BCC%\lib; @_temp.rsp
  if %MV_ERRFILE%==Y %MG_BCC%\bin\ilink32 -x -Gn -Tpe -aa -L%MG_BCC%\lib; @_temp.rsp >>%MV_SRC%.err
  if not errorlevel 1 goto CLEANUP
  echo.
  echo Link error.
  echo.
  set MV_PAUSE=Y
  goto END

:CLINK
  rem Link for console or mixed mode EXE
  if %MV_ERRFILE%==N %MG_BCC%\bin\ilink32 -x -Gn -Tpe -ap -L%MG_BCC%\lib; @_temp.rsp
  if %MV_ERRFILE%==Y %MG_BCC%\bin\ilink32 -x -Gn -Tpe -ap -L%MG_BCC%\lib; @_temp.rsp >>%MV_SRC%.err
  if not errorlevel 1 goto CLEANUP
  echo.
  echo Link error.
  echo.
  set MV_PAUSE=Y
  goto END

:CLEANUP
  rem Delete temporary files
  if %MV_ERRFILE%==N if exist %MV_SRC%.err del %MV_SRC%.err
  if exist %MV_SRC%.tds del %MV_SRC%.tds
  if %MV_DODEL%==N      goto EXESTART
  if exist _temp.rsp    del _temp.rsp
  if exist _templib.rsp del _templib.rsp
  if exist _tempobj.rsp del _tempobj.rsp
  if exist _tempres.rsp del _tempres.rsp
  if %MV_DOCONLY%==Y goto EXESTART
  if %MV_DOLINK%==Y if %MV_DOLONLY%==N if %MV_DOCCOMP%==Y if exist %MV_SRC%.c   del %MV_SRC%.c
  if %MV_DOLINK%==Y if %MV_DOLONLY%==N if %MV_DORONLY%==N if exist %MV_SRC%.res del %MV_SRC%.res
  if %MV_DOLINK%==Y if %MV_DOLONLY%==N                    if exist %MV_SRC%.obj del %MV_SRC%.obj

:EXESTART
  rem Start EXE
  if %MV_DOCONLY%==Y goto END
  if %MV_DOCCOMP%==N goto END
  if %MV_DORONLY%==Y goto END
  if %MV_DOLINK%==N  goto END
  if %MV_DOEXE%==N   goto END
  if %MV_DODONLY%==Y goto END
  if     exist %MV_SRC%.bat                       %MV_EXECMD% %MV_SRC%.bat %MV_ARG%
  if not exist %MV_SRC%.bat if exist %MV_SRC%.exe %MV_EXECMD% %MV_SRC%.exe %MV_ARG%

:END
  rem Delete local variables
  if %MV_PAUSE%==Y pause
  set MV_USEXHRB=
  set MV_INTMODE=
  set MV_DEBUG=
  set MV_MTHREAD=
  set MV_USETASM=
  set MV_ERRFILE=
  set MV_PAUSE=
  set MV_DOCCOMP=
  set MV_DOCONLY=
  set MV_DOCMAIN=
  set MV_DORONLY=
  set MV_DOLINK=
  set MV_DOLONLY=
  set MV_DOEXE=
  set MV_DODEL=
  set MV_DODONLY=
  set MV_EXECMD=
  set MV_SWITCH=
  set MV_CSWITCH=
  set MV_ARG=
  set MV_HRB=
  set MV_LIB=
  set MV_SRC=

exit /b 0

:READ_SETTINGS
set SETTINGSFILE=%1
if not exist %SETTINGSFILE% (
    echo Unable to load config from file %1
)

for /f "eol=# delims== tokens=1,2" %%i in (%SETTINGSFILE%) do (
    set %%i=%%j
)

exit /b 0