@echo off

:PARPARSE
  set MGV_USEXHRB=N
  if "%MG_CMP%"=="XHARBOUR" set MGV_USEXHRB=Y
  if "%MG_BCC%"==""  set MG_BCC=c:\borland\bcc55
  if "%MG_ROOT%"=="" set MG_ROOT=c:\minigui
  if "%MG_HRB%"==""  set MG_HRB=%MG_ROOT%\harbour
  if "%MG_LIB%"==""  set MG_LIB=%MG_ROOT%\lib
  if "%MG_XHRB%"=="" set MG_XHRB=c:\xharbour
  if "%MG_XLIB%"=="" set MG_XLIB=%MG_ROOT%\xlib
  if "%1"=="/x"      set MGV_USEXHRB=Y
  if "%1"=="/X"      set MGV_USEXHRB=Y
  if "%1"=="/-x"     set MGV_USEXHRB=N
  if "%1"=="/-X"     set MGV_USEXHRB=N
  if %MGV_USEXHRB%==N set MGV_HRB=%MG_HRB%
  if %MGV_USEXHRB%==N set MGV_LIB=%MG_LIB%
  if %MGV_USEXHRB%==Y set MGV_HRB=%MG_XHRB%
  if %MGV_USEXHRB%==Y set MGV_LIB=%MG_XLIB%

:PROC

  if exist hbdll32.lib del hbdll32.lib

  %MG_BCC%\bin\bcc32 -c -O2 -tW -tWM -d -6 -OS -I%MGV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MGV_HRB%\lib;%MG_BCC%\lib hbdll32.c

  %MG_BCC%\bin\tlib hbdll32.lib +hbdll32.obj

:CLEANUP
  if exist *.obj del *.obj

:END
  set MGV_USEXHRB=
  set MGV_HRB=
  set MGV_LIB=