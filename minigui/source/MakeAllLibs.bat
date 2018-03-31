@echo off

rem Makes all libraries from folders under SOURCE folder.

call MakeAllMiniguiLibs.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
call MakeAllHarbourLibs.bat %1 %2 %3 %4 %5 %6 %7 %8 %9

:END