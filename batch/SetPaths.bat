@ECHO OFF

REM SET MGROOT=%~d0\MiniguiM
REM SET PATH=%MGROOT%\comp\mingw32\bin;%MGROOT%\comp\harbour\bin;%windir%\system32;%MGROOT%\batch

:: -- NEW SETTINGS -----------------------------------
:: flexible path installation, not necessary to be MiniguiM, can be `MiniGUI` `MgM` or `whatever`

set OLDPATH=%PATH%
set OLDDIR=%CD%
cd %~dp0..
set MGROOT=%CD%
cd %OLDDIR%
set OLDDIR=
:: ---------------------------------------------------

REM SET MINGW=C:\mingw32
REM  SET MINGW=C:\mingw32-9.2.1
REM SET MINGW=C:\Users\User1\Downloads\Downloads\mingw_down\mingw32_930_MSYS2
SET MINGW=%MGROOT%\comp\mingw32

SET PATH=%MINGW%\bin;%MGROOT%\comp\harbour\bin;%windir%\system32;%MGROOT%\batch

