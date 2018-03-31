@echo off 
rem ===========================================================================
rem build_dll.bat
rem build script for mydemo.dll for MiniGui  2017.10.14
rem
rem Sergej Kiselev <bilance@bilance.lv> 
rem Revised by Verchenko Andrey <verchenkoag@gmail.com> 
rem ===========================================================================
rem  ATTENTION ! Limitation for the linker BCC 5.5.1
rem  Files with a total size greater than 0.5 MB can not be placed in the resource folder,
rem  since ilink32 can not assemble such a resource, you need to switch to BCC 5.8.2 or MinGW
rem ===========================================================================

if not defined MG_BCC     set MG_BCC=c:\borland\bcc55
if not defined MV_CSWITCH set MV_CSWITCH=-w -w-par -w-inl
if exist build.log del build.log > nul 
: 
  rem call compile MyDemo.c
  %MG_BCC%\BIN\bcc32.EXE -c -tW -d -6 -O2 -OS -Ov -Oi -Oc -I%MG_BCC%\include -L%MG_BCC%\lib %MV_CSWITCH% MyDemo.c >>build.log
  if errorlevel 1 goto err 
  rem Call resource compiler if needed        
  %MG_BCC%\bin\brc32 -r MyDemo.rc >>build.log
  if errorlevel 1 goto err 
  rem Link for create dll
  %MG_BCC%\BIN\ilink32.EXE -Tpd -x -I%MG_BCC%\include -L%MG_BCC%\lib MyDemo.obj,MyDemo.dll,,import32.lib+cw32.lib,,MyDemo.res >>build.log
  if errorlevel 1 goto err 
  goto end 

:err 
  echo ===== Error! View file build.log ======= 
  pause 

:end 
  rem Delete temporary files
  if exist MyDemo.ilc del MyDemo.ilc  > nul
  if exist MyDemo.ild del MyDemo.ild  > nul
  if exist MyDemo.ilf del MyDemo.ilf  > nul
  if exist MyDemo.ils del MyDemo.ils  > nul
  if exist MyDemo.map del MyDemo.map  > nul
  if exist mydemo.obj del mydemo.obj  > nul
  if exist mydemo.RES del mydemo.RES  > nul
  if exist MyDemo.tds del MyDemo.tds  > nul 

  echo Compile demo.prg 
  call Compile.bat
