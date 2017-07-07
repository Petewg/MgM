@echo off

@CALL %~d0\MiniguiM\batch\setpaths.bat

hbmk2 -warn=max mgmMisc.hbp > build.log 2>&1


