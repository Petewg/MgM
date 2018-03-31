@echo off

rem Builds MiniGui library PropGrid.lib.

:OPT
  call ..\..\batch\makelibopt.bat PropGrid m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\propgrid.lib del %MV_BUILD%\propgrid.lib
  %MV_HRB%\bin\harbour h_propgrid h_pglang -n -w2 -es2 -gc0 /i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -tWM -O2 -d -6 -OS -I%MV_HRB%\include;%MG_ROOT%\include h_propgrid.c h_pglang.c
  %MG_BCC%\bin\bcc32 -c -tWM -O2 -d -6 -OS -I.;%MV_HRB%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib c_propgrid.c
  %MG_BCC%\bin\tlib %MV_BUILD%\propgrid.lib +c_propgrid +h_propgrid +h_pglang
  if exist %MV_BUILD%\propgrid.bak del %MV_BUILD%\propgrid.bak

:CLEANUP
  if %MV_DODEL%==N   goto END
  if exist h_propgrid.c   del h_propgrid.c
  if exist h_pglang.c     del h_pglang.c
  if exist c_propgrid.obj del c_propgrid.obj
  if exist h_propgrid.obj del h_propgrid.obj
  if exist h_pglang.obj   del h_pglang.obj

:END
  call ..\..\batch\makelibend.bat