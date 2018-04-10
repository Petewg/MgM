@echo off

rem Builds Harbour library HbVpdf.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbVpdf h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hbvpdf.lib del %MV_BUILD%\hbvpdf.lib
  %MV_HRB%\bin\harbour hbvpdf.prg -n1 -w -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour hbvpsup.prg -n1 -w -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib hbvpdf.c hbvpsup.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbvpdf.lib +hbvpdf.obj +hbvpsup.obj
  if exist %MV_BUILD%\hbvpdf.bak del %MV_BUILD%\hbvpdf.bak

:CLEANUP
  if %MV_DODEL%==N      goto END
  if exist hbvpdf.c     del hbvpdf.c
  if exist hbvpdf.obj   del hbvpdf.obj
  if exist hbvpsup.c    del hbvpsup.c
  if exist hbvpsup.obj  del hbvpsup.obj

:END
  call ..\..\batch\makelibend.bat