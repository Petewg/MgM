@echo off

rem Builds Harbour library MySQL.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbMySQL h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo HbMySQL.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\hbmysql.lib del %MV_BUILD%\hbmysql.lib
  %MV_HRB%\bin\harbour.exe tmysql.prg -n -w -es2 -gc0 -i%MV_HRB%\include
  %MV_HRB%\bin\harbour.exe tsqlbrw.prg -n -w -es2 -gc0 -i%MV_HRB%\include
  %MG_BCC%\bin\bcc32 -c -O2 -I%MV_HRB%\include tmysql.c tsqlbrw.c mysql.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbmysql.lib +mysql.obj +tsqlbrw.obj +tmysql.obj
  if exist %MV_BUILD%\hbmysql.bak del %MV_BUILD%\hbmysql.bak

  if exist libmysql.dll implib %MV_BUILD%\libmysql.lib libmysql.dll
  if not exist libmysql.dll echo Libmysql.dll is missing -  %MV_BUILD%\libmysql.lib is not created!

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist mysql.obj   del mysql.obj
  if exist tsqlbrw.c   del tsqlbrw.c
  if exist tmysql.c    del tmysql.c
  if exist tsqlbrw.obj del tsqlbrw.obj
  if exist tmysql.obj  del tmysql.obj

:END
  call ..\..\batch\makelibend.bat