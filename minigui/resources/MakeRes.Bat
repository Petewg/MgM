@echo off

SET Root=%~d0\MiniguiM

SET PATH=%Root%\comp\mingw32\bin

windres -I %Root%\minigui\include -I %Root%\comp\mingw32\i686-w64-mingw32\include -i hmg.rc -o hmg.o
