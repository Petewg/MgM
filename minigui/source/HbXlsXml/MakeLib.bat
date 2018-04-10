@echo off

rem Builds Harbour library hbxlsxml.lib.

:OPT
  call ..\..\batch\makelibopt.bat hbxlsxml h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hbxlsxml.lib del %MV_BUILD%\hbxlsxml.lib
  %MV_HRB%\bin\harbour xlsxml.prg -n -w2 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour xlsxml_s.prg xlsxml_y.prg -n -w2 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib xlsxml.c xlsxml_s.c xlsxml_y.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbxlsxml.lib +xlsxml.obj +xlsxml_s.obj +xlsxml_y.obj
  if exist %MV_BUILD%\hbxlsxml.bak del %MV_BUILD%\hbxlsxml.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist *.obj   del *.obj
  if exist *.c     del *.c

:END
  call ..\..\batch\makelibend.bat