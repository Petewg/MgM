@echo off

rem ***************************************************************************
rem HBMK2 Compile batch
rem Based upon an original work of Roberto Lopez for HMG 3.0
rem Last revised by Grigory Filatov 03/10/2017
rem
rem Syntax:
rem
rem	Build [/d] [/e] [/c] [/i [/nh]] [/r] [/n] <PrgFile>|<filelist.hbp> [config.hbc]
rem	
rem	[/d] : Debug Mode
rem	[/e] : Send Warnings to build.log
rem	[/c] : Console mode
rem	[/i] : Incremental Build		[/nh] : No Head Mode
rem	[/r] : Rebuild All Mode
rem	[/n] : No Run After Build
rem
rem	<filelist.hbp> : A text file with a source filelist
rem	<config.hbc>   : A text file with configuration parameters as additional
rem			libs, include paths and lib paths
rem
rem	- build.bat will create an 'error.log' file in the app folder when build
rem			process ends with an error condition.
rem
rem ***************************************************************************

cls

echo building...

if exist build.log del build.log
if exist error.log del error.log

rem ***************************************************************************
rem set environment variables
rem ***************************************************************************

if not defined MG_ROOT set MG_ROOT=%~dp0..
if not defined MG_BCC  set MG_BCC=c:\borland\bcc55

set PATH=%MG_BCC%\bin;%MG_ROOT%\harbour\bin;%PATH%

rem ***************************************************************************
rem set default GT driver
rem ***************************************************************************

set GT=-gtgui

rem ***************************************************************************
rem set default debug mode
rem ***************************************************************************

set DEBUG=-quiet

rem ***************************************************************************
rem set default warning mode
rem ***************************************************************************

set WARN=-warn=no

rem ***************************************************************************
rem set default incremental mode
rem ***************************************************************************

set INCREMENTAL=

rem ***************************************************************************
rem set default incremental head mode
rem ***************************************************************************

set HEAD=native

rem ***************************************************************************
rem set default rebuild mode
rem ***************************************************************************

set REBUILD=

rem ***************************************************************************
rem set default run mode
rem ***************************************************************************

set RUN=-run

rem ***************************************************************************
rem Console Build
rem ***************************************************************************

if "%1"=="/c" goto console
if "%1"=="/C" goto console

:continue0

rem ***************************************************************************
rem If debug mode specified, use GTWIN and pass -b parameter
rem ***************************************************************************

if "%1"=="/d" goto debug
if "%1"=="/D" goto debug

:continue1

rem ***************************************************************************
rem If warning mode specified add the option to command line.
rem ***************************************************************************

if "%1"=="/e" goto warning
if "%1"=="/E" goto warning

:continue2

rem ***************************************************************************
rem If Incremental mode specified add the option to command line.
rem ***************************************************************************

if "%1"=="/i" goto buildtype
if "%1"=="/I" goto buildtype

:continue3

rem ***************************************************************************
rem If Incremental no head mode specified, use -head=off switch.
rem ***************************************************************************

if "%1"=="/nh" goto headtype
if "%1"=="/NH" goto headtype

:continue4

rem ***************************************************************************
rem If Rebuild All mode specified add the option to command line.
rem ***************************************************************************

if "%1"=="/r" goto rebuild
if "%1"=="/R" goto rebuild

:continue5

rem ***************************************************************************
rem If no run after build mode specified add the option to command line.
rem ***************************************************************************

if "%1"=="/n" goto norun
if "%1"=="/N" goto norun

rem ***************************************************************************
rem invoke HBMK2
rem ***************************************************************************

%MG_ROOT%\utils\mpm\cmdredir.exe -eo %MG_ROOT%\harbour\bin\hbmk2.exe -D_HBMK_ %GT% %WARN% -q %RUN% %INCREMENTAL% -head=%HEAD% %REBUILD% %DEBUG% %1 %2 %3 %4 %5 %6 %7 %8 %9 -L${HB_DYN} minigui.hbc > build.log

rem ***************************************************************************
rem Cleanup
rem ***************************************************************************

if exist init.cld del init.cld

rem If build error, create 'error.log' ----------------------------------------

if errorlevel 1 copy /b build.log error.log >nul

echo.

rem If build error, show 'error.log' ------------------------------------------

if exist error.log type error.log
if exist error.log del build.log
if exist error.log pause

goto endbatch

rem ***************************************************************************
rem Procedure Console
rem ***************************************************************************

:console

shift

set GT=-gtwin

goto continue0

rem ***************************************************************************
rem Procedure Norun
rem ***************************************************************************

:norun

shift

set RUN=-run-

goto continue0

rem ***************************************************************************
rem Procedure Debug
rem ***************************************************************************

:debug

shift 

set GT=-gtwin
set DEBUG=-b

echo OPTIONS NORUNATSTARTUP > init.cld

goto continue1

rem ***************************************************************************
rem Procedure Warning
rem ***************************************************************************

:warning

shift

set WARN=-w2 -warn

goto continue2

rem ***************************************************************************
rem Procedure BuildType
rem ***************************************************************************

:buildtype

shift

set INCREMENTAL=-inc

goto continue3

rem ***************************************************************************
rem Procedure HeadType
rem ***************************************************************************

:headtype

shift

set HEAD=off

goto continue4

rem ***************************************************************************
rem Procedure Rebuild
rem ***************************************************************************

:rebuild

shift

set REBUILD=-rebuild

goto continue5

:ENDBATCH

rem ***************************************************************************
rem Delete local variables
rem ***************************************************************************

set HB_PLATFORM=
set GT=
set DEBUG=
set WARN=
set INCREMENTAL=
set HEAD=
set REBUILD=
set RUN=
