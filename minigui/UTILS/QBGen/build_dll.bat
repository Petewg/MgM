@echo off 
rem ===========================================================================
rem build_dll.bat
rem build script for QbGen.dll for MiniGui  2017.10.14
rem
rem Sergej Kiselev <bilance@bilance.lv> 
rem Revised by Verchenko Andrey <verchenkoag@gmail.com> 
rem Revised By Pierpaolo Martinello pier.martinello [at] alice.it
rem ===========================================================================
rem  ATTENTION ! Limitation for the linker BCC 5.5.1
rem  Files with a total size greater than 0.5 MB can not be placed in the resource folder,
rem  since ilink32 can not assemble such a resource, you need to switch to BCC 5.8.2 or MinGW
rem ===========================================================================

SET MySrc=%1
if "%1"=="" SET MySrc=QbGen

if not defined MG_BCC     set MG_BCC=c:\borland\bcc55
if not defined MV_CSWITCH set MV_CSWITCH=-w -w-par -w-inl
if not defined MG_ROOT    set MG_ROOT=c:\minigui
if not defined MG_RES     set MG_RES=%MG_ROOT%\Resources\minigui.res+%MG_ROOT%\Resources\hbprinter.res+%MG_ROOT%\Resources\miniprint.res

if exist build.log del build.log > nul 
if exist %Mysrc%.dll del %Mysrc%.dll > nul

: 
  rem call compile %Mysrc%.c
  %MG_BCC%\BIN\bcc32.EXE -c -tW -d -6 -O2 -OS -Ov -Oi -Oc -I%MG_BCC%\include -L%MG_BCC%\lib %MV_CSWITCH% %Mysrc%.c >>build.log
  if errorlevel 1 goto err 
  rem Call resource compiler if needed
  %MG_BCC%\bin\brc32 -r %Mysrc%.Rc >>build.log
  
  if errorlevel 1 goto err 
  rem Link for create dll
  %MG_BCC%\BIN\ilink32.EXE -Tpd -x -I%MG_BCC%\include -L%MG_BCC%\lib %Mysrc%.obj,%Mysrc%.dll,,import32.lib+cw32.lib,,%Mysrc%.res+%MG_RES% >>build.log
  if errorlevel 1 goto err 
  goto end 

:err 
  echo ===== Error! View file build.log ======= 
  pause 
  start notepad build.log
  goto exit

:end 
  rem Delete temporary files
  if exist %Mysrc%.ilc del %Mysrc%.ilc  > nul
  if exist %Mysrc%.ild del %Mysrc%.ild  > nul
  if exist %Mysrc%.ilf del %Mysrc%.ilf  > nul
  if exist %Mysrc%.ils del %Mysrc%.ils  > nul
  if exist %Mysrc%.map del %Mysrc%.map  > nul
  if exist %Mysrc%.obj del %Mysrc%.obj  > nul
  if exist %Mysrc%.RES del %Mysrc%.RES  > nul
  if exist %Mysrc%.tds del %Mysrc%.tds  > nul 
  if exist build.log   del build.log > nul
  SET MG_RES=
  SET MySrc=

:exit


