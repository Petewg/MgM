@echo off

if exist *.hbp Goto hbpComp
goto prgComp

:hbpComp
@for  %%i  IN (*.hbp) DO @call %~d0\miniguim\batch\buildapp.bat  %%~ni
goto finish

:prgComp
@for  %%i  IN (*.prg) DO @call %~d0\miniguim\batch\buildapp.bat  %%~ni

:finish
