@ECHO OFF
CLS

SETLOCAL ENABLEEXTENSIONS

SET OLD_PATH=%PATH%
@CALL %~d0\miniguim\batch\setpaths.bat

IF "~%1"=="~" GOTO :DEFAULT
SET SRC=%1
SHIFT /1
GOTO :BUILD


:DEFAULT
SET SRC=PUT_THE_DEFAULT_PRG_NAME_TO_BUILD_HERE

IF "%SRC%"=="PUT_THE_DEFAULT_PRG_NAME_TO_BUILD_HERE" GOTO :HELP
GOTO :BUILD


:HELP
ECHO You must specify the .prg name to build! Press a key...
PAUSE > NUL
REM bellow line needed to set errorlevel to 1. do not delete!
COLOR 00
GOTO :CLEANUP


:BUILD
SET HB_STATIC_CURL=yes
SET HB_STATIC_OPENSSL=yes
:: set bellow setting as needed
SET HB_USER_LIBPATHS=%~d0\MiniguiM\comp\cURLstatLib

rem hbmk2 -w3 -es2 -inc- %SRC% %1 %2 %3 hbssl.hbc hbcurl.hbc statlibs.hbc hbwin.hbc
hbmk2 -w3 -es2 -inc- %SRC% %1 %2 %3 %4 %5 %6 %7 %8 %9 statlibs.hbc hbwin.hbc


:CLEANUP
SET HB_STATIC_CURL=
SET HB_STATIC_OPENSSL=
SET HB_USER_LIBPATHS=
SET PATH=%OLD_PATH%
SET OLD_PATH=
SET MGROOT=

:: IF %ERRORLEVEL% NEQ 0 GOTO :FINITO
IF ERRORLEVEL 1 GOTO :FINITO
CALL :SETEXE %SRC%
SET SRC=


:EXEC
IF NOT EXIST %_EXENAME% GOTO :FINITO
%_EXENAME%
GOTO :FINITO

:SETEXE
SET _EXENAME=%~n1.exe
:: FROM HERE IT RETURNS UP, TO LINE AFTER `CALL`

:FINITO

ENDLOCAL


