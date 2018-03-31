@echo off

rem Builds Harbour library hbpgsql.lib and converts original POstgreSQL libpq.lib (COFF) to OMF format (for Borland)
set PQ_VER=9.5

:OPT
  call ..\..\batch\makelibopt.bat hbpgsql h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP
  if %MV_USEXHRB%==N goto BUILD
  echo hbpgsql.lib is not compatible with xHarbour.
  goto END


:BUILD
  if exist %MV_BUILD%\hbpgsql.lib del %MV_BUILD%\hbpgsql.lib
  %MV_HRB%\bin\harbour.exe tpostgre.prg -n -w3 -es2 -gc0 -i%MV_HRB%\include
  %MG_BCC%\bin\bcc32 -c -O2 -I%MG_HRB%\include -I.\%PQ_VER% postgres.c rddcopy.c tpostgre.c
  %MG_BCC%\bin\tlib %MV_BUILD%\hbpgsql.lib +postgres.obj +rddcopy.obj +tpostgre.obj
  if exist %MV_BUILD%\hbpgsql.bak del %MV_BUILD%\hbpgsql.bak

  if exist .\%PQ_VER%\libpq.lib coffimplib .\%PQ_VER%\libpq.lib %MV_BUILD%\libpq.lib
  if not exist .\%PQ_VER%\libpq.lib echo original libpq.lib (COFF) is MISSING: %MV_BUILD%\libpq.lib (OMF) is not created!


:CLEANUP
  if exist postgres.obj del postgres.obj
  if exist rddcopy.obj  del rddcopy.obj
  if exist tpostgre.obj del tpostgre.obj
  if exist tpostgre.c   del tpostgre.c

:END
  call ..\..\batch\makelibend.bat