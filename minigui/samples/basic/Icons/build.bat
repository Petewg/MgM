cd %~p0MyIcons
@call build.bat

cd..

@call %~d0\miniguim\batch\buildapp.bat demo 
@call %~d0\miniguim\batch\buildapp.bat demo2 mgmMisc.hbc
@call %~d0\miniguim\batch\buildapp.bat demo3 

@del myicons.dll

::@for  %%i  IN (*.prg) DO @call %~d0\miniguim\batch\buildapp.bat %%~ni mgmMisc.hbc
