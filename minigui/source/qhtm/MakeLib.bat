@echo off

rem Builds MiniGui library HMG_QHTM.lib.

:OPT
  call ..\..\batch\makelibopt.bat HMG_QHTM m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hmg_qhtm.lib del %MV_BUILD%\hmg_qhtm.lib
  %MV_HRB%\bin\harbour h_qhtm -n -w -es2 -gc0 /i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -tWM -O2 -d -6 -OS -I%MV_HRB%\include;%MG_ROOT%\include h_qhtm.c
  %MG_BCC%\bin\bcc32 -c -tWM -O2 -d -6 -OS -I.;%MV_HRB%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib c_qhtm.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hmg_qhtm.lib +c_qhtm +h_qhtm
  if exist %MV_BUILD%\hmg_qhtm.bak del %MV_BUILD%\hmg_qhtm.bak

:CLEANUP
  if %MV_DODEL%==N      goto END
  if exist h_qhtm.c   del h_qhtm.c
  if exist c_qhtm.obj del c_qhtm.obj
  if exist h_qhtm.obj del h_qhtm.obj

:END
  call ..\..\batch\makelibend.bat