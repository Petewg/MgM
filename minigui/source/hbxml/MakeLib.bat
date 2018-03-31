@echo off

rem Builds Harbour library HbXML.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbXML h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hbxml.lib del %MV_BUILD%\hbxml.lib
  %MV_HRB%\bin\harbour hxmldoc.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n -w -es2 -gc0
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib hxmldoc.c xmlparse.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbxml.lib +hxmldoc.obj +xmlparse.obj
  if exist %MV_BUILD%\hbxml.bak del %MV_BUILD%\hbxml.bak

:CLEANUP
  if %MV_DODEL%==N   goto END
  if exist *.obj     del *.obj
  if exist hxmldoc.c del hxmldoc.c

:END
  call ..\..\batch\makelibend.bat