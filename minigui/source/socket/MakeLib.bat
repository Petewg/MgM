@echo off

rem Builds Harbour library Socket.lib.

:OPT
  call ..\..\batch\makelibopt.bat Socket h %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\socket.lib del %MV_BUILD%\socket.lib
  %MV_HRB%\bin\harbour tftp.prg tpair.prg tdecode.prg thttp.prg tpop3.prg tsmtp.prg tsocket.prg -n -w2 -es2 -i%MV_HRB%\include
  %MG_BCC%\bin\bcc32 -DHB_API_MACROS -O2 -c -tWM -w -w-sig- -I%MV_HRB%\include;%MG_BCC%\include;.\ -L%MV_HRB%\lib;%MG_BCC%\lib tftp.c tpair.c tdecode.c thttp.c tpop3.c tsmtp.c tsocket.c socket.c base64.c md5c.c hmac_md5.c
  %MG_BCC%\bin\tlib %MV_BUILD%\socket.lib +tftp.obj +tpair.obj +tdecode.obj +thttp.obj +tpop3.obj +tsmtp.obj +tsocket.obj +socket.obj +md5c.obj +hmac_md5.obj +base64.obj
  if exist %MV_BUILD%\socket.bak del %MV_BUILD%\socket.bak

:CLEANUP
  if %MV_DODEL%==N   goto END
  if exist *.obj     del *.obj
  if exist tpair.c   del tpair.c
  if exist tdecode.c del tdecode.c
  if exist thttp.c   del thttp.c
  if exist tpop3.c   del tpop3.c
  if exist tsmtp.c   del tsmtp.c
  if exist tsocket.c del tsocket.c
  if exist tftp.c    del tftp.c

:END
  call ..\..\batch\makelibend.bat