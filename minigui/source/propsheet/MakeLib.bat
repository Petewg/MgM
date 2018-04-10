@echo off

rem Builds MiniGui library PropSheet.lib.

:OPT
  call ..\..\batch\makelibopt.bat PropSheet m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\propsheet.lib del %MV_BUILD%\propsheet.lib
  %MV_HRB%\bin\harbour h_propsheet -n -w2 -es2 -gc0 /i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -tWM -O2 -d -6 -OS -I%MV_HRB%\include;%MG_ROOT%\include h_propsheet.c
  %MG_BCC%\bin\bcc32 -c -tWM -O2 -d -6 -OS -I.;%MV_HRB%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib c_propsheet.c
  %MG_BCC%\bin\tlib %MV_BUILD%\propsheet.lib +c_propsheet +h_propsheet
  if exist %MV_BUILD%\propsheet.bak del %MV_BUILD%\propsheet.bak

:CLEANUP
  if %MV_DODEL%==N         goto END
  if exist h_propsheet.c   del h_propsheet.c
  if exist c_propsheet.obj del c_propsheet.obj
  if exist h_propsheet.obj del h_propsheet.obj

:END
  call ..\..\batch\makelibend.bat