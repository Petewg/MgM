@echo off

rem ===========================================================================
rem MakeLibOpt.bat
rem Called by MakeLib.bat files.
rem Kevin Carmody - 2013.04.06
rem
rem Revised by Petr Chornyj - 2016.09.08
rem ===========================================================================

if "%1"=="?"  goto SYNTAX
if "%1"=="/?" goto SYNTAX
goto PARPARSE

:SYNTAX
  echo.
  echo MakeLib.bat
  echo Makes MiniGui or Harbour library
  echo.
  echo Syntax:
  echo MakeLibOpt (libname) (libloc) [/X] [/-X] [/T] [/P] [/ND] [/DO]
  echo.
  echo   (libname)   File name of target library, without extension
  echo   (libloc)    Location of target library, one of the following:
  echo     M           MiniGui library directory
  echo     H           Harbour or xHarbour library directory
  echo     .           Current directory
  echo     (other)     Any other value is interpreted as the directory name
  echo   /X          Use xHarbour, must precede other options,
  echo                 default if MG_CMP set to XHARBOUR, see below
  echo   /-X         Use Harbour, must precede other options,
  echo                 default if MG_CMP missing or not set to XHARBOUR
  echo   /T          Use Turbo Assembler during C compile
  echo   /P          Pause at end
  echo   /ND         Do not delete temporary files after compile and build
  echo   /DO         Delete temporary files only, no compile or build
  echo   Spacing between parameters must be as shown.
  echo.
  pause
  echo You may set the following environment variables.  
  echo Locations in these variables must not have a trailing backslash.
  echo.
  echo   MG_BCC      Location of BCC, default C:\Borland\BCC55
  echo   MG_ROOT     Location of MinuGui, default C:\MiniGui
  echo   MG_HRB      Location of Harbour, default (MG_ROOT)\Harbour
  echo   MG_LIB      Location of Harbour MiniGui libraries, default (MG_ROOT)\Lib
  echo   MG_XHRB     Location of xHarbour, default C:\xHarbour
  echo   MG_XLIB     Location of xHarbour MiniGui libraries, default (MG_ROOT)\xLib
  echo   MG_CMP      If set to XHARBOUR, then use xHarbour by default: 
  echo                 /X is not necessary, may be overridden by /-X
  echo.
  set MV_PAUSE=Y
  set MV_EXIT=Y
  goto END

:SYNTERR
  echo Type MakeLib.bat ? for syntax.
  set MV_PAUSE=Y
  set MV_EXIT=Y
  goto END

:PARPARSE
  set MV_EXIT=N
  set MV_LIBNAME=%1
  set MV_USEXHRB=N
  set MV_USETASM=N
  set MV_PAUSE=N
  set MV_DODEL=Y
  set MV_DODONLY=N
  set MV_MGLIB=N
  set MV_HBLIB=N

   if not defined MG_ROOT call :READ_SETTINGS %~dp0\minigui.cfg

  if     defined MG_CMP  if "%MG_CMP%"=="XHARBOUR" set MV_USEXHRB=Y
  if not defined MG_BCC  set MG_BCC=c:\borland\bcc55
  if not defined MG_ROOT set MG_ROOT=c:\minigui
  if not defined MG_HRB  set MG_HRB=%MG_ROOT%\harbour
  if not defined MG_LIB  set MG_LIB=%MG_ROOT%\lib
  if not defined MG_XHRB set MG_XHRB=c:\xharbour
  if not defined MG_XLIB set MG_XLIB=%MG_ROOT%\xlib
  if %MV_USEXHRB%==N set MV_HRB=%MG_HRB%
  if %MV_USEXHRB%==N set MV_LIB=%MG_LIB%
  if %MV_USEXHRB%==Y set MV_HRB=%MG_XHRB%
  if %MV_USEXHRB%==Y set MV_LIB=%MG_XLIB%
  shift
  if   "%1"=="" goto SYNTERR
  if /i %1==m   goto MLIBSET
  if /i %1==h   goto HLIBSET
  goto OLIBSET
:MLIBSET
  set MV_MGLIB=Y
  goto PARMORE
:HLIBSET
  set MV_HBLIB=Y
  goto PARMORE
:OLIBSET
  set MV_BUILD=%1
  goto PARMORE

:PARMORE
  shift
  if   "%1"=="" goto SETBUILD
  if    %1==?   goto SYNTAX
  if    %1==/?  goto SYNTAX
  if /i %1==/x  goto XHARBSET
  if /i %1==/-x goto HARBSET
  if /i %1==/t  goto TASMSET
  if /i %1==/p  goto PAUSESET
  if /i %1==/nd goto DELSET
  if /i %1==/do goto DONLYSET
  echo Unknown option %1
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
:TASMSET
  set MV_USETASM=Y
  goto PARMORE
:PAUSESET
  set MV_PAUSE=Y
  goto PARMORE
:DELSET
  set MV_DODEL=N
  goto PARMORE
:DONLYSET
  set MV_DODONLY=Y
  goto PARMORE

:SETBUILD
  if %MV_MGLIB%==Y set MV_BUILD=%MV_LIB%
  if %MV_HBLIB%==Y set MV_BUILD=%MV_HRB%\lib

:TASMCHECK
  if %MV_USETASM%==N goto END
  if exist %MG_BCC%\bin\tasm32.exe goto END
  echo Assembler TASM32.EXE required but not found in %MG_BCC%\bin.
  echo %MV_LIBNAME%.lib not built.
  set MV_PAUSE=Y
  set MV_EXIT=Y
  goto END

:END

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