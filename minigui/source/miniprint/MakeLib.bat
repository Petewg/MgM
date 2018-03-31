@echo off

rem Builds Harbour library MiniPrint.lib.

:OPT
  call ..\..\batch\makelibopt.bat MiniPrint h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\miniprint.lib del %MV_BUILD%\miniprint.lib
  %MV_HRB%\bin\harbour h_miniprint.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n -w3 -es2
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib -D_ERRORMSG_ h_miniprint.c c_miniprint.c
  %MG_BCC%\bin\tlib %MV_BUILD%\miniprint.lib +h_miniprint.obj +c_miniprint.obj
  if exist %MV_BUILD%\miniprint.bak del %MV_BUILD%\miniprint.bak

:CLEANUP
  if %MV_DODEL%==N       goto END
  if exist *.obj         del *.obj
  if exist h_miniprint.c del h_miniprint.c

:END
  call ..\..\batch\makelibend.bat