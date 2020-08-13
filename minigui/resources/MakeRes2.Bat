@echo off

SET Root=%~d0\MiniguiM

SET PATH=%Root%\comp\mingw32\bin

windres -i hmg2.rc -o hmg2.o
