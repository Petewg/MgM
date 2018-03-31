@echo off

rem Builds Harbour library Shell32.lib.

:OPT
  call ..\..\batch\makelibopt.bat Shell32 h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\shell32.lib del %MV_BUILD%\shell32.lib
  %MV_HRB%\bin\harbour shell32.prg -n -w -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib shell32.c
  %MG_BCC%\bin\tlib %MV_BUILD%\shell32.lib +shell32.obj
  if exist %MV_BUILD%\shell32.bak del %MV_BUILD%\shell32.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist *.obj   del *.obj
  if exist *.c     del *.c

:END
  call ..\..\batch\makelibend.bat