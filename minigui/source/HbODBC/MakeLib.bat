@echo off

rem Builds Harbour libraries HbODBC.lib and ODBC32.lib

:OPT
  call ..\..\batch\makelibopt.bat HbODBC h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo HbODBC.lib and ODBC32.lib are not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\hbodbc.lib del %MV_BUILD%\hbodbc.lib
  %MV_HRB%\bin\harbour.exe todbc.prg -n -w -es2 -gc0 -i%MV_HRB%\include
  %MG_BCC%\bin\bcc32 -c -O2 -I%MV_HRB%\include -DWIN32_LEAN_AND_MEAN todbc.c odbc.c
  %MG_BCC%\bin\implib %MV_BUILD%\odbc32.lib odbc32.def
  %MG_BCC%\bin\tlib %MV_BUILD%\hbodbc.lib +todbc.obj +odbc.obj
  if exist %MV_BUILD%\hbodbc.bak del %MV_BUILD%\hbodbc.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist odbc.obj  del odbc.obj
  if exist todbc.c   del todbc.c
  if exist todbc.obj del todbc.obj

:END
  call ..\..\batch\makelibend.bat