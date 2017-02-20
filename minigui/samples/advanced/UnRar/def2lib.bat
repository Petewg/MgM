@echo off
'SET HMGPATH=c:
'SET PATH=%HMGPATH%\mingw64\bin;%PATH%
@call %~d0\miniguim\batch\SetPaths.bat

dlltool -k -d unrar64.def -l libunrar64.a

SET PATH=%OLD_PATH%
SET OLD_PATH=
