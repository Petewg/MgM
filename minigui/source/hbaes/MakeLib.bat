@echo off

rem Builds Harbour library HbAES.lib.

:OPT
  call ..\..\batch\makelibopt.bat hbaes h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo hbaes.lib is not compatible with xHarbour.
  goto END

:BUILD
  if exist %MV_BUILD%\hbaes.lib del %MV_BUILD%\hbaes.lib
  %MV_HRB%\bin\harbour aescrypt.prg -i%MV_HRB%\include;%MG_ROOT%\include -n -w2 -es2
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I.\include;%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib aescrypt.c padlock.c aes.c sha2.c aescrypt2.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbaes.lib +aescrypt.obj +aes.obj +padlock.obj +sha2.obj +aescrypt2.obj

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist aescrypt.c del aescrypt.c
  if exist *.obj del *.obj

:END
  call ..\..\batch\makelibend.bat