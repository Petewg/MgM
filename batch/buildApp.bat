@ECHO OFF

:: ECHO Compiling %1 sources 

CALL %~dp0SetPaths.bat
SET RUNEXE=-run
SET STRIP=-strip

:: Compile Resources
   IF EXIST _temp.rc DEL _temp.rc   > NUL
   
	ECHO #define HMGRPATH %MGMPATH%\RESOURCES > _hmg_resconfig.h
   
	IF EXIST *.rc COPY /V /A *.rc PRJ_RES_.rc  > NUL
	
   COPY /V /A %MGMPATH%\resources\hmg.rc + %MGMPATH%\resources\filler + PRJ_RES_.rc + %MGMPATH%\resources\filler _temp.rc  > NUL
   
	IF EXIST PRJ_RES_.rc DEL PRJ_RES_.rc > NUL
   
	windres -i _temp.rc -o _temp.o  2> _BuildLog.txt
   
   :: DEL _hmg_resconfig.h > NUL

IF "%2"=="-c" GOTO Console

IF "%2"=="-norun" SET RUNEXE=-run-
IF "%2"=="-norun" SHIFT /2

:Gui
echo GUI
      hbmk2 -n -mt -cpu=x86 -lang=en -w2 %RUNEXE% -ge1 -ql %STRIP% -jobs=2 -D__CALLDLL__ %1 %2 %3 %4 %5 %6 %7 %MGMPATH%\minigui.hbc 2>> _BuildLog.txt
   :: hbmk2 -n -cpu=x86 -lang=en -w3 %RUNEXE% -ge1 -ql %STRIP% %1 %2 %3 %4 %5 %6 %7 %MGMPATH%\minigui.hbc 2>> _BuildLog.txt
   GOTO Check

:Console
   SHIFT /2 
   IF "%2"=="-norun" SET RUNEXE=-run-
   IF "%2"=="-norun" SHIFT /2
   ::hbmk2 -n -cpu=x86 -lang=en %RUNEXE% -ql -info -exitstr %STRIP% -D__CALLDLL__ %1 _temp.o %2 %3 %4 %5 %6 %7 2>> _BuildLog.txt
   hbmk2 -n -mt -cpu=x86 -lang=en -w3 %RUNEXE% -ge1 -ql %STRIP% -jobs=2 -D__CALLDLL__ %1 %2 %3 %4 %5 %6 %7 %MGMPATH%\minigui.hbc 2>> _BuildLog.txt
   

:Check
   IF ERRORLEVEL 1 GOTO Err
   GOTO Run

:Err
   ECHO 
   ECHO Build Error(s) occured. Inspect _BuildLog.txt to see what failed..
   START _BuildLog.txt
   PAUSE > NUL
   GOTO Quit

:Run
   IF "%2"=="-norun" GOTO Quit
	IF "%RUNEXE%"=="-run-" GOTO Quit
   ECHO  
   ECHO Running %1 ...
   ECHO ----------------------------------------------
   ECHO When end running, press a key to delete %1.exe
   PAUSE > NUL
   IF EXIST %1.exe DEL %1.exe


:Quit
   :: Clean up
   SET MGMPATH=
   DEL _hmg_resconfig.h
   DEL _temp.* > NUL
   DEL _BuildLog.txt > NUL
   IF EXIST %1.ppo DEL %1.ppo > NUL
   IF EXIST ErrorLog.htm DEL ErrorLog.htm > NUL
   SET PATH=%OLD_PATH%



	