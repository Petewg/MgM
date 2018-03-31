@echo off

rem Builds Harbour library HbSQLit3.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbSQLit3 h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo HbSQLit3.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\hbsqlit3.lib del %MV_BUILD%\hbsqlit3.lib
  %MV_HRB%\bin\harbour.exe errstr.prg -n -w3 -es2 -i%MV_HRB%\include
  %MV_HRB%\bin\harbour.exe hdbc.prg -n -w3 -es2 -i%MV_HRB%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I.\include;%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib -DSQLITE_ENABLE_COLUMN_METADATA core.c errstr.c hdbc.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbsqlit3.lib +core.obj +errstr.obj +hdbc.obj
  if exist %MV_BUILD%\hbsqlit3.bak del %MV_BUILD%\hbsqlit3.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist errstr.c del errstr.c
  if exist hdbc.c   del hdbc.c
  if exist *.obj    del *.obj

:END
  call ..\..\batch\makelibend.bat