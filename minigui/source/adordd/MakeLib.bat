@echo off

rem Builds Harbour library AdoRdd.lib.

:OPT
  call ..\..\batch\makelibopt.bat AdoRdd h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo AdoRdd.lib is not compatible with xHarbour.
  echo Please use AdoRdd.lib from xHarbour contribution.
  goto END

:BUILD
  if exist %MV_BUILD%\adordd.lib del %MV_BUILD%\adordd.lib
  %MV_HRB%\bin\harbour adordd.prg -n -w2 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib adordd.c
  %MG_BCC%\bin\tlib %MV_BUILD%\adordd.lib +adordd.obj
  if exist %MV_BUILD%\adordd.bak del %MV_BUILD%\adordd.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist *.obj   del *.obj
  if exist *.c     del *.c

:END
  call ..\..\batch\makelibend.bat