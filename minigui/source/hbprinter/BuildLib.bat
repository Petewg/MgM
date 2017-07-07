@echo off

@CALL %~d0\MiniguiM\batch\setpaths.bat

hbmk2 winprint.hbp 2> build.log
if errorlevel 1 goto Err
if errorlevel 0 if not errorlevel 1 del build.log
Goto End
:Err
start build.log

:End



