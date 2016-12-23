@echo off

@CALL %~d0\MiniguiM\batch\setpaths.bat

hbmk2 debugger.hbp 2> build.log
