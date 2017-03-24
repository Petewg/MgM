
@ECHO OFF

SET MGROOT=%~d0\MiniguiM
=======
REM @echo off

SET OLDCD=%cd%
SET OLDDRV=%~d0
%~d0
cd %~d0%~p0..
SET ROOT=%cd%
%OLDDRV%
cd %OLDCD%


SET RES=%MGROOT%\minigui\resources
IF NOT EXIST %RES%\_hmg_resconfig.h ECHO #define HMGRPATH %RES% > %RES%\_hmg_resconfig.h
SET RES=

SET MINGW=%MGROOT%\comp\mingw32\bin
SET PATH=%MINGW%;%MGROOT%\comp\harbour\bin;%windir%\system32
SET MINGW=
<<<<<<< HEAD

SET MGMPATH=%MGROOT%\minigui
=======
SET OLDCD=
SET OLDDRV=

