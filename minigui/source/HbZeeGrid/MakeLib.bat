@echo off

rem Builds Harbour library hbZeeGrid.lib.

:OPT
  call ..\..\batch\makelibopt.bat hbZeeGrid h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hbzeegrid.lib del %MV_BUILD%\hbzeegrid.lib
  %MV_HRB%\bin\harbour cells.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n -w3 -es2
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib hbzggrid.c zgdate.c zgflat.c hbutils.c cells.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbzeegrid.lib +hbzggrid.obj +zgdate.obj +zgflat.obj +hbutils.obj +cells.obj
  if exist %MV_BUILD%\hbzeegrid.bak del %MV_BUILD%\hbzeegrid.bak

:CLEANUP
  if %MV_DODEL%==N  goto END
  if exist *.obj    del *.obj
  if exist cells.c  del cells.c

:END
  call ..\..\batch\makelibend.bat