@echo off

rem Makes all MiniGui libraries from folders under SOURCE folder.

@echo.
@echo MiniGui.lib
@echo.
call MakeLib.Bat %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo.
@echo dbginit.obj
@echo.
call MakeObj.Bat %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo.
@echo Debugger.lib
@echo.
cd Debugger
call MakeLib.Bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo PropGrid.lib
@echo.
cd PropGrid
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo PropSheet.lib
@echo.
cd PropSheet
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo TsBrowse.lib
@echo.
cd TsBrowse
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HMG_QHTM.lib
@echo.
cd QHTM
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo WinReport.lib
@echo.
cd WinReport
call MakeLib.Bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

:END