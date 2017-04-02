@ECHO OFF

SET MGROOT=%~d0\MiniguiM

IF NOT EXIST %MGROOT%\minigui\resources\_hmg_resconfig.h (
   ECHO #define HMGRPATH %MGROOT%\minigui\resources > %MGROOT%\minigui\resources\_hmg_resconfig.h
   )

SET PATH=%MGROOT%\comp\mingw32\bin;%MGROOT%\comp\harbour\bin;%windir%\system32

