@echo off

@CALL %~d0\MiniguiM\batch\setpaths.bat

@rem hbmk2 -ql -hbx=hbcab.hbx hbcab.hbp    2> Build.log

hbmk2 hbcab.hbp
