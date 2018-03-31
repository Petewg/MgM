@echo off

rem Builds Harbour library Dll.lib.

:OPT
  call ..\..\batch\makelibopt.bat Dll h /t %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\dll.lib del %MV_BUILD%\dll.lib
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib -E%MG_BCC%\bin\tasm32.exe _windll.c _wincall.c
  %MG_BCC%\bin\tlib %MV_BUILD%\dll.lib +_windll.obj +_wincall.obj
  if exist %MV_BUILD%\dll.bak del %MV_BUILD%\dll.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist *.obj   del *.obj

:END
  call ..\..\batch\makelibend.bat