@ECHO OFF

@FOR  %%i  IN (*.prg) DO @call %~d0\miniguim\batch\buildapp.bat %%~ni

ECHO THAT'S ALL FOLKS! 
