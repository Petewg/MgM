@echo off

rem Builds dbginit.obj.

:OPT
  call ..\batch\makelibopt.bat MiniGui m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\dbginit.obj del %MV_BUILD%\dbginit.obj
  %MV_HRB%\bin\harbour dbginit -i%MV_HRB%\include;%mg_root%\include; -n1 -w3 -es2
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include; -L%MV_HRB%\lib;%MG_BCC%\lib; -o%MV_BUILD%\dbginit.obj dbginit.c 

:CLEANUP
  if %MV_DODEL%==N    goto END
  if exist dbginit.c  del dbginit.c

:END
  call ..\batch\makelibend.bat