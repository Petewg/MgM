@echo off

SET HMGPATH=%~d0\MiniguiM\comp

SET PATH=%HMGPATH%\mingw32\bin;%HMGPATH%\harbour\bin

hbmk2 hbdll32.hbp

pause