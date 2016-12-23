@echo off

SET Root=C:\MiniguiM

SET PATH=%Root%\comp\mingw32\bin

windres -i hmg.rc -o hmg.o
