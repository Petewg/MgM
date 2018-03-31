@echo off

rem Builds Harbour library HbPrinter.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbPrinter h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hbprinter.lib del %MV_BUILD%\hbprinter.lib
  %MV_HRB%\bin\harbour winprint.prg -n -w2 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib winprint.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbprinter.lib +winprint.obj
  if exist %MV_BUILD%\hbprinter.bak del %MV_BUILD%\hbprinter.bak

:CLEANUP
  if %MV_DODEL%==N      goto END
  if exist winprint.c   del winprint.c
  if exist winprint.obj del winprint.obj

:END
  call ..\..\batch\makelibend.bat