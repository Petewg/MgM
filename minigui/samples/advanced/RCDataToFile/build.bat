@Echo off
@call %~d0\miniguim\batch\setpaths.bat 

@hbmk2 hello

@windres -i testres.rc -o _temp.o  2> _BuildLog.txt

@hbmk2 testres _temp.o

@del hello.exe

@testres

ECHO.

ECHO press a key to clean up created files
   PAUSE > NUL
@del testres.exe
@del _temp.o
@del _BuildLog.txt

