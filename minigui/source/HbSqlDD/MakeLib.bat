@echo off

rem Builds Harbour library HbSqlDD.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbSqlDD h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo HbSqlDD.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\hbsqldd.lib del %MV_BUILD%\hbsqldd.lib
  if exist %MV_BUILD%\sddmy.lib del %MV_BUILD%\sddmy.lib
  if exist %MV_BUILD%\sddodbc.lib del %MV_BUILD%\sddodbc.lib
  if exist %MV_BUILD%\sddsqlt3.lib del %MV_BUILD%\sddsqlt3.lib
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -6 -OS -I%MV_HRB%\include sqlmix.c sqlbase.c sddodbc.c
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -6 -OS -I..\hbmysql;%MV_HRB%\include sddmy.c
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -6 -OS -Iinclude;%MV_HRB%\include sddsqlt3.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbsqldd.lib +sqlmix.obj +sqlbase.obj
  %MG_BCC%\bin\tlib %MV_BUILD%\sddmy.lib +sddmy.obj
  %MG_BCC%\bin\tlib %MV_BUILD%\sddodbc.lib +sddodbc.obj
  %MG_BCC%\bin\tlib %MV_BUILD%\sddsqlt3.lib +sddsqlt3.obj
  if exist %MV_BUILD%\hbsqldd.bak del %MV_BUILD%\hbsqldd.bak
  if exist %MV_BUILD%\sddmy.bak del %MV_BUILD%\sddmy.bak
  if exist %MV_BUILD%\sddodbc.bak del %MV_BUILD%\sddodbc.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist sqlmix.obj   del sqlmix.obj
  if exist sqlbase.obj  del sqlbase.obj
  if exist sddmy.obj    del sddmy.obj
  if exist sddodbc.obj  del sddodbc.obj
  if exist sddsqlt3.obj del sddsqlt3.obj

:END
  call ..\..\batch\makelibend.bat