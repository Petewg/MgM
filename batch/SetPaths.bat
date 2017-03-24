@ECHO OFF

SET MGROOT=%~d0\MiniguiM

SET RES=%MGROOT%\minigui\resources
IF NOT EXIST %RES%\_hmg_resconfig.h ECHO #define HMGRPATH %RES% > %RES%\_hmg_resconfig.h
SET RES=

SET MINGW=%MGROOT%\comp\mingw32\bin
SET PATH=%MINGW%;%MGROOT%\comp\harbour\bin;%windir%\system32
SET MINGW=

SET MGMPATH=%MGROOT%\minigui
