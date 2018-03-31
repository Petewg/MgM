@echo off

rem Builds MiniGui library WinReport.lib.

:OPT
  call ..\..\batch\makelibopt.bat WinReport m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\WinReport.lib del %MV_BUILD%\WinReport.lib
  %MV_HRB%\bin\harbour h_wrepint.prg -n -w2 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour h_wremix.prg -n -w2 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour h_WrePdf.prg -n -w2 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour hmg_hpdf.prg -n -w2 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour fncMyError.prg -n -w2 -es2 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib h_wrepint.c h_wremix.c h_wrepdf.c hmg_hpdf.c fncMyError.c
  %MG_BCC%\bin\tlib %MV_BUILD%\WinReport.lib +h_wrepint.obj +h_wremix.obj +h_wrepdf.obj+hmg_hpdf.obj+fncMyError.obj

  if exist %MV_BUILD%\WinReport.bak del %MV_BUILD%\WinReport.bak

:CLEANUP
  if %MV_DODEL%==N        goto END
  if exist h_wrepint.c    del h_wrepint.c
  if exist h_wrepint.obj  del h_wrepint.obj
  if exist h_wrepdf.c     del h_wrepdf.c
  if exist h_wrepdf.obj   del h_wrepdf.obj
  if exist hmg_hpdf.c     del hmg_hpdf.c
  if exist hmg_hpdf.obj   del hmg_hpdf.obj
  if exist h_wremix.c     del h_wremix.c
  if exist h_wremix.obj   del h_wremix.obj
  if exist fncMyError.c   del fncMyError.c
  if exist fncMyError.obj del fncMyError.obj

:END
  call ..\..\batch\makelibend.bat