REM @echo off

SET ROOT=%~d0\MiniguiM

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
