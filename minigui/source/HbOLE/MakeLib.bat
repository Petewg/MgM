@echo off

rem Builds Harbour library HbOLE.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbOLE h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo HbOLE.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\hbole.lib del %MV_BUILD%\hbole.lib
  %MV_HRB%\bin\harbour win32ole -n -w -es2 -gc0 /i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -I.;%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib w32ole.c
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -I%MV_HRB%\include;%MG_BCC%\include -tW win32ole.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbole.lib +w32ole +win32ole
  if exist %MV_BUILD%\hbole.bak del %MV_BUILD%\hbole.bak

:CLEANUP
  if %MV_DODEL%==N      goto END
  if exist win32ole.c   del win32ole.c
  if exist w32ole.obj   del w32ole.obj
  if exist win32ole.obj del win32ole.obj

:END
  call ..\..\batch\makelibend.bat