@call %~d0\miniguim\batch\buildapp.bat GetDataDemo -norun
@call %~d0\miniguim\batch\buildapp.bat SendDataDemo -norun

start SendDataDemo.exe & start GetDataDemo.exe

@ECHO When end running, close both windows and press a key to delete demo executables
PAUSE > NUL
IF EXIST *.exe DEL *.exe
