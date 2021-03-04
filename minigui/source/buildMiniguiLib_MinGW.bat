@echo off

REM echo %~d0\
REM pause
REM goto :eof

CALL %~d0\MiniguiM\batch\SetPaths.bat

SET SRC=%~d0\MiniguiM\minigui\source

echo ------------------------------------------------------------------------- > Build.log
echo Build MiniGUI Lib started on %date% %time% >> Build.log
echo ------------------------------------------------------------------------- >> Build.log
echo(   >>  Build.log

CD /d %SRC%
 :: hbmk2 hmg.hbp >> %~dp0Build.log 2>>&1
    hbmk2 -lang=en hmg.hbp 2>> %~dp0Build.log 

CD /d %~dp0
echo Build MiniGUI Lib finished on %date% %time% >> Build.log
echo(   >>  Build.log

SET SRC=