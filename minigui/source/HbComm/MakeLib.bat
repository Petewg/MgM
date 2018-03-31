@echo off

rem Builds Harbour library HbComm.lib.

:OPT
  call ..\..\batch\makelibopt.bat HbComm h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\hbcomm.lib del %MV_BUILD%\hbcomm.lib
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -DHB_API_MACROS hbcomm.c
  %MG_BCC%\bin\bcc32 -c -d -OS -I%MV_HRB%\include;%MG_BCC%\include -DHB_API_MACROS comm.cpp hblcomm.cpp
  %MG_BCC%\bin\tlib %MV_BUILD%\hbcomm.lib +hbcomm.obj +comm.obj +hblcomm.obj
  if exist %MV_BUILD%\hbcomm.bak del %MV_BUILD%\hbcomm.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist *.obj   del *.obj

:END
  call ..\..\batch\makelibend.bat