@echo off

rem Builds Harbour library Hmg_Hpdf.lib.

:OPT
  call ..\..\batch\makelibopt.bat hmg_hpdf h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hmg_hpdf.lib del %MV_BUILD%\hmg_hpdf.lib
  %MV_HRB%\bin\harbour hmg_hpdf.prg -n -w3 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib hmg_hpdf.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hmg_hpdf.lib +hmg_hpdf.obj
  if exist %MV_BUILD%\hmg_hpdf.bak del %MV_BUILD%\hmg_hpdf.bak

:CLEANUP
  if %MV_DODEL%==N      goto END
  if exist hmg_hpdf.c   del hmg_hpdf.c
  if exist hmg_hpdf.obj del hmg_hpdf.obj

:END
  call ..\..\batch\makelibend.bat