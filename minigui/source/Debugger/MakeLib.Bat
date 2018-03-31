@echo off

rem Builds Harbour library Debugger.lib.

:OPT
  call ..\..\batch\makelibopt.bat Debugger m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo Debugger.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\debugger.lib del %MV_BUILD%\debugger.lib
  %MV_HRB%\bin\harbour dbgGUI.prg -n -w -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour dbgHB.prg -n -w2 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib dbgGUI.c dbgHB.c
  %MG_BCC%\bin\tlib %MV_BUILD%\debugger.lib +dbgGUI.obj +dbgHB.obj
  if exist %MV_BUILD%\debugger.bak del %MV_BUILD%\debugger.bak

:CLEANUP
  if %MV_DODEL%==N      goto END
  del *.c
  del *.obj

:END
  call ..\..\batch\makelibend.bat
