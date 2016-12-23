@echo off

rem Builds Harbour library HbZipArc.lib.

:OPT
  call ..\..\batch\makelibopt.bat hbziparc h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo HbZipArc.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\hbziparc.lib del %MV_BUILD%\hbziparc.lib
  %MV_HRB%\bin\harbour hbziparc.prg -n -w3 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib hbziparc.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbziparc.lib +hbziparc.obj
  if exist %MV_BUILD%\hbziparc.bak del %MV_BUILD%\hbziparc.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist *.obj   del *.obj
  if exist *.c     del *.c

:END
  call ..\..\batch\makelibend.bat