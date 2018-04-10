@echo off

rem Builds MiniGui library MiniPrint2.lib.

:OPT
  call ..\..\batch\makelibopt.bat MiniPrint2 m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\miniprint2.lib del %MV_BUILD%\miniprint2.lib
  %MV_HRB%\bin\harbour miniprint.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n -w3 -es2
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib -D_ERRORMSG_ miniprint.c
  %MG_BCC%\bin\tlib %MV_BUILD%\miniprint2.lib +miniprint.obj
  if exist %MV_BUILD%\miniprint2.bak del %MV_BUILD%\miniprint2.bak

:CLEANUP
  if %MV_DODEL%==N       goto END
  if exist miniprint.c   del miniprint.c
  if exist miniprint.obj del miniprint.obj

:END
  call ..\..\batch\makelibend.bat