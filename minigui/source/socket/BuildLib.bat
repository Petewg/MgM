@echo off

@CALL %~d0\MiniguiM\batch\setpaths.bat

hbmk2 socket.hbp 2> err.log
