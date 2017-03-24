REM @echo off

SET OLDCD=%cd%
SET OLDDRV=%~d0
%~d0
cd %~d0%~p0..
SET ROOT=%cd%
%OLDDRV%
cd %OLDCD%

REM SET MINGW=C:\mingw32\bin
SET MINGW=%ROOT%\comp\mingw32\bin

SET OLD_PATH=%PATH%

REM SET PATH=%ROOT%\comp\mingw32\bin;%ROOT%\comp\harbour\bin;%windir%\system32
SET PATH=%MINGW%;%ROOT%\comp\harbour\bin;%windir%\system32

SET MGMPATH=%ROOT%\minigui

SET ROOT=
SET MINGW=
SET OLDCD=
SET OLDDRV=
