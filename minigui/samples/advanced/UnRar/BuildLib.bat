rem @echo off

@CALL %~d0\MiniguiM\batch\setpaths.bat

hbmk2 unrar.hbp > unrar.log 2>&1

SET PATH=%OLD_PATH%

SET OLD_PATH=