@echo off

rem Builds Harbour library hbgdip.lib.


:OPT
  call ..\..\batch\makelibopt.bat hbgdip h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  set F_SRC=core.c pen.c brush.c image.c imageattr.c graphics.c bitmap.c
  set F_OBJ=+core.obj +pen.obj +brush.obj +image.obj +imageattr.obj +graphics.obj +bitmap.obj

  if exist %MV_BUILD%\hbgdip.lib del %MV_BUILD%\hbgdip.lib
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include %F_SRC%
  %MG_BCC%\bin\tlib %MV_BUILD%\hbgdip.lib %F_OBJ%
  if exist %MV_BUILD%\hbgdip.bak del %MV_BUILD%\hbgdip.bak

:CLEANUP
  if %MV_DODEL%==N   goto END
  if exist *.obj     del *.obj
  set F_SRC=
  set F_OBJ=

:END
  call ..\..\batch\makelibend.bat
