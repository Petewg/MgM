@echo off

rem Builds Harbour library sqlite3facade.lib.

:OPT
  call ..\..\batch\makelibopt.bat sqlite3facade h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\sqlite3facade.lib del %MV_BUILD%\sqlite3facade.lib
  %MV_HRB%\bin\harbour SQLiteFacadeHelper.prg -n -w3 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour SQLiteFacade.prg -n -w3 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour SQLiteFacadeRecordSet.prg -n -w3 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour SQLiteFacadeRecordSetMockup.prg -n -w3 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour SQLiteFacadeStatement.prg -n -w3 -es2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include -L%MV_HRB%\lib;%MG_BCC%\lib SQLiteFacadeHelper.c SQLiteFacade.c SQLiteFacadeRecordSet.c SQLiteFacadeRecordSetMockup.c SQLiteFacadeStatement.c
  %MG_BCC%\bin\tlib %MV_BUILD%\sqlite3facade.lib +SQLiteFacadeHelper.obj +SQLiteFacade.obj +SQLiteFacadeRecordSet.obj +SQLiteFacadeRecordSetMockup.obj +SQLiteFacadeStatement.obj
  if exist %MV_BUILD%\sqlite3facade.bak del %MV_BUILD%\sqlite3facade.bak

:CLEANUP
  if %MV_DODEL%==N goto END
  if exist *.obj   del *.obj
  if exist *.c     del *.c

:END
  call ..\..\batch\makelibend.bat