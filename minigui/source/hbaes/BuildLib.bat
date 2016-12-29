@echo off

@CALL %~d0\MiniguiM\batch\setpaths.bat

hbmk2 -ql -hbx=hbaes.hbx hbaes.hbp    2> Build.log
