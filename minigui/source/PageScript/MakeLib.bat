@echo off

rem Builds Harbour library PScript.lib.

:OPT
  call ..\..\batch\makelibopt.bat PScript h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\pscript.lib del %MV_BUILD%\pscript.lib
  %MV_HRB%\bin\harbour TPScript.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n -w2 -es2 -gc0
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib TPScript.c
  %MG_BCC%\bin\tlib %MV_BUILD%\pscript.lib +TPScript.obj
  if exist %MV_BUILD%\pscript.bak del %MV_BUILD%\pscript.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist TPScript.c   del TPScript.c
  if exist TPScript.obj del TPScript.obj

:END
  call ..\..\batch\makelibend.bat