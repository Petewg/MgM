:: file: buildApp.bat 
:: batch file to build samples

   @ECHO OFF

   :: preserve current path, to restore it after execution...
   SET OLD_PATH=%PATH%
   
   :: set bellow BELL=ON to enable system beeper, after compilation
   SET BELL=OFF

   CALL %~dp0SetPaths.bat

   :: we usually want to run the program
   SET RUNEXE=-run

   :: not necessary to strip sample binaries, (normaly it's used on production/release builds)
   :: but if you wish so, feel free to uncomment next line.
   :: SET STRIP=-strip

   :: we use a 'flag' file named <warnlev.max> 
   :: In order to define a lower or elevated warning level
   :: you should either delete or create it. 
   IF EXIST %MGROOT%\batch\warnlev.max (
      SET WARNLEV=-w3
      SET EXITLEV=-es2
      ) ELSE (
      SET WARNLEV=-w2
      SET EXITLEV=-es0
      )

   :: Compile Resources
   ECHO #define HMGRPATH %MGMPATH%\RESOURCES > _hmg_resconfig.h
   IF EXIST _temp.rc DEL _temp.rc   > NUL
   IF EXIST *.rc (
      COPY /V /A *.rc PRJ_RES_.rc  > NUL
      COPY /V /A %MGMPATH%\resources\hmg.rc + %MGMPATH%\resources\filler + PRJ_RES_.rc + %MGMPATH%\resources\filler _temp.rc  > NUL
      DEL PRJ_RES_.rc > NUL 
      ) ELSE COPY /V /A %MGMPATH%\resources\hmg.rc + %MGMPATH%\resources\filler _temp.rc  > NUL
      
   windres --include-dir=%MGMPATH%\resources --input=_temp.rc --output=_temp.o  2> _BuildLog.txt
   

   IF "%2"=="-c" GOTO Console
   IF "%2"=="-norun" SET RUNEXE=-run-
   IF "%2"=="-norun" SHIFT /2

:Gui
   hbmk2 -n -mt -cpu=x86 -lang=en %WARNLEV% %EXITLEV% %RUNEXE% -ge1 -ql %STRIP% -jobs=2 -D__CALLDLL__ %1 %2 %3 %4 %5 %6 %7 %MGMPATH%\minigui.hbc 2>> _BuildLog.txt
   :: hbmk2 -n -cpu=x86 -lang=en %WARNLEV% %EXITLEV% %RUNEXE% -ge1 -ql %STRIP%               %1 %2 %3 %4 %5 %6 %7 %MGMPATH%\minigui.hbc 2>> _BuildLog.txt
   GOTO Check

:Console
   SHIFT /2 
   IF "%2"=="-norun" SET RUNEXE=-run-
   IF "%2"=="-norun" SHIFT /2
   ::hbmk2 -n -cpu=x86 -lang=en %RUNEXE% -ql -info -exitstr %STRIP% -D__CALLDLL__ %1 _temp.o %2 %3 %4 %5 %6 %7 2>> _BuildLog.txt
   hbmk2 -n -mt -cpu=x86 -lang=en %WARNLEV% %EXITLEV% %RUNEXE% -ge1 -ql %STRIP% -jobs=2 -D__CALLDLL__ %1 %2 %3 %4 %5 %6 %7 %MGMPATH%\minigui.hbc 2>> _BuildLog.txt
   
:Check
   IF ERRORLEVEL 1 GOTO Err
   GOTO Run

:Err
   IF %BELL%==ON ECHO 
   ECHO Build Error(s) occured. Inspect _BuildLog.txt to see what failed..
   START _BuildLog.txt
   PAUSE > NUL
   GOTO Quit

:Run
   IF "%2"=="-norun" GOTO Quit
   IF "%RUNEXE%"=="-run-" GOTO Quit
   IF %BELL%==ON ECHO  
   ECHO running %1.exe ... when end running, press a key to delete it.
   ECHO(
   PAUSE > NUL
   IF EXIST %1.exe DEL %1.exe && ECHO sample %1.exe removed from disk...
   ECHO(

:Quit
   :: clean up
   DEL _temp.* > NUL
   DEL _hmg_resconfig.h
   DEL _BuildLog.txt > NUL
   IF EXIST %1.ppo DEL %1.ppo > NUL
   IF EXIST ErrorLog.htm DEL ErrorLog.htm > NUL
   SET MGROOT=
   SET MGMPATH=
   SET BELL=
   SET WARNLEV=
   SET EXITLEV=
   SET RUNEXE=
   
   :: restore path
   SET PATH=%OLD_PATH%
