:: @call %~d0\miniguim\batch\buildapp.bat demo demo.hbc

@for  %%i  IN (*.prg) DO @call %~d0\miniguim\batch\buildapp.bat %%~ni demo.hbc