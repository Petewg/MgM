@echo off
rem RC file to 32 bits resources DLL

if "%MG_BCC%"=="" set MG_BCC=c:\borland\bcc55

set PATH=%MG_BCC%\bin;%PATH%

bcc32 -c Timer.c
brc32 -r Timer.rc
ilink32 /Tpd %MG_BCC%\lib\c0d32.obj Timer.obj, ..\Timer.dll,,%MG_BCC%\lib\cw32.lib %MG_BCC%\lib\import32.lib,, Timer.res
del *.obj
del *.res
del ..\*.il?
del ..\*.map
del ..\*.tds
echo done!