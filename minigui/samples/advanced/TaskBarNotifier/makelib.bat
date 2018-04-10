@echo off

rem Builds local library tbn.lib.

:OPT
  call ..\..\..\batch\makelibopt.bat tbn . %*
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\%MV_LIBNAME%.lib del %MV_BUILD%\%MV_LIBNAME%.lib

  %MV_HRB%\bin\harbour TTimerClass.prg -n -q0 -w -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tW -tWM -d -a8 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib TTimerClass.c

  %MV_HRB%\bin\harbour TTaskbarNotifierClass.prg -n -q0 -w -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tW -tWM -d -a8 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib TTaskbarNotifierClass.c

  %MV_HRB%\bin\harbour WndProc.prg -n -q0 -w -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tW -tWM -d -a8 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib WndProc.c

  %MG_BCC%\bin\tlib %MV_BUILD%\%MV_LIBNAME%.lib +TTimerClass.obj +TTaskbarNotifierClass.obj +WndProc.obj

:CLEANUP
  if %MV_DODEL%==N goto END
  call :DELFILES TTimerClass.c TTaskbarNotifierClass.c WndProc.c
  call :DELFILES TTimerClass.obj TTaskbarNotifierClass.obj WndProc.obj
  goto END

:DELFILES
  if exist %1 del %1
  shift
  if not "%1"=="" goto DELFILES
  goto :EOF

:END
  call ..\..\..\batch\makelibend.bat