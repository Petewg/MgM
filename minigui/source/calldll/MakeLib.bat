@echo off

rem Builds Harbour library CallDll.lib.

:OPT
  call ..\..\batch\makelibopt.bat CallDll h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo CallDll.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\calldll.lib del %MV_BUILD%\calldll.lib
  %MV_HRB%\bin\harbour calldll.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n -w3 -es2 -gc0
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib calldll.c
  %MG_BCC%\bin\tlib %MV_BUILD%\calldll.lib +calldll.obj
  if exist %MV_BUILD%\calldll.bak del %MV_BUILD%\calldll.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist calldll.c   del calldll.c
  if exist calldll.obj del calldll.obj

:END
  call ..\..\batch\makelibend.bat