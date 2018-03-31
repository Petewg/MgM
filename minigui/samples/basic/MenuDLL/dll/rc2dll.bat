@echo off
rem RC file to 32 bits resources DLL

if "%MG_BCC%"=="" set MG_BCC=c:\borland\bcc55

set PATH=%MG_BCC%\bin;%PATH%

bcc32 -c menu.c
brc32 -r demo.rc
ilink32 /Tpd -x %MG_BCC%\lib\c0d32.obj menu.obj, ..\menu.dll,,%MG_BCC%\lib\cw32.lib %MG_BCC%\lib\import32.lib,, demo.res
del ..\*.il?
del *.obj
del *.res
del ..\*.tds
echo done!