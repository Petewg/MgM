@echo off

rem Builds Harbour library hbunrar.lib.

:OPT
  call ..\..\..\batch\makelibopt.bat hbunrar h %*
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if not exist unrar.dll call :NODLL

  %MG_BCC%\bin\impdef unrar.def unrar.dll
  %MG_BCC%\bin\implib unrar.lib unrar.def

  if exist %MV_BUILD%\%MV_LIBNAME%.lib del %MV_BUILD%\%MV_LIBNAME%.lib

  %MV_HRB%\bin\harbour unrar.prg -n -q0 -w -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tW -tWM -d -a8 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_LIB%;%MG_BCC%\lib unrar.c
  %MG_BCC%\bin\bcc32 -c -O2 -tW -tWM -d -a8 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_LIB%;%MG_BCC%\lib hb_unrar.c

  %MG_BCC%\bin\tlib %MV_BUILD%\%MV_LIBNAME%.lib +unrar.obj +hb_unrar.obj

:CLEANUP
  if %MV_DODEL%==N goto END
  call :DELFILES unrar.c unrar.obj unrar.def hb_unrar.obj
  goto END

:DELFILES
  if exist %1 del %1
  shift
  if not "%1"=="" goto DELFILES
  goto :EOF

:NODLL
  echo.
  echo. Missing unrar.dll, please download it from:
  echo. http://www.rarlab.com/rar/UnRARDLL.exe
  echo.
  echo. Make aborted.
  echo.
  goto :EOF

:END
  call ..\..\..\batch\makelibend.bat