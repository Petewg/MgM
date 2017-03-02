@echo off

SET Root=%~d0\MiniguiM

SET PATH=%Root%\comp\mingw32\bin

windres -i hmg.rc -o hmg.o
