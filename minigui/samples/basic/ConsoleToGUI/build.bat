@ECHO OFF

CALL %~dp0SetPaths.bat

:: Compile Resources
   IF EXIST _temp.rc DEL _temp.rc   > NUL
	ECHO #define HMGRPATH %MGMPATH%\RESOURCES > _hmg_resconfig.h
	IF EXIST *.rc COPY /V /A *.rc PRJ_RES_.rc  > NUL

   COPY /V /A %MGMPATH%\resources\hmg.rc + %MGMPATH%\resources\filler + PRJ_RES_.rc + %MGMPATH%\resources\filler _temp.rc  > NUL
	IF EXIST PRJ_RES_.rc DEL PRJ_RES_.rc > NUL
	windres -i _temp.rc -o _temp.o  2> BuildLog.txt

hbmk2 -n -cpu=x86 -lang=en -w3  -ge1 -ql -D__CALLDLL__ demo2 %MGMPATH%\minigui.hbc 2>> BuildLog2.txt

hbmk2 -n -cpu=x86 -gtwvt -lang=en -ql  -D__CALLDLL__ demo1 2>> BuildLog.txt


:Check
   IF ERRORLEVEL 1 GOTO Err
   GOTO Run

:Err
   ECHO 
   ECHO Build Error(s) occured. Inspect BuildLog.txt to see what failed..
   START BuildLog.txt
   PAUSE > NUL
   GOTO Quit

:Run
   ECHO  
   ECHO When end running, press a key to delete demo*.exe
   call demo1.exe 
   call demo2.exe
   PAUSE > NUL
   IF EXIST demo1.exe DEL demo1.exe
   IF EXIST demo2.exe DEL demo2.exe


:Quit
   SET MGMPATH=
   DEL _hmg_resconfig.h > NUL
   DEL _temp.* > NUL
   DEL BuildLog.txt > NUL
   DEL BuildLog2.txt > NUL
   IF EXIST ErrorLog.htm DEL ErrorLog.htm

	