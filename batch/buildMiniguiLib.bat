@echo off

CALL %~dp0SetPaths.bat

SET SRC=%~d0\MiniguiM\minigui\source

echo ------------------------------------------------------------------------- > Build.log
echo Build MiniGUI Lib started on %date% %time% >> Build.log
echo ------------------------------------------------------------------------- >> Build.log
echo   >>  Build.log

CD /d %SRC%
REM hbmk2 hmg.hbp > %~dp0Build.log 2>&1
hbmk2 hmg.hbp 2>> %~dp0Build.log 

CD /d %~dp0
echo Build MiniGUI Lib finished on %date% %time% >> Build.log
echo   >>  Build.log

SET SRC=