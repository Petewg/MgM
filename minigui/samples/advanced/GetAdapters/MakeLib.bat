if "%MG_ROOT%"=="" set MG_ROOT=c:\minigui
if "%MG_BCC%"==""  set MG_BCC=c:\borland\bcc55

xcopy %systemroot%\system32\iphlpapi.dll

%MG_BCC%\bin\implib iphlpapi.lib iphlpapi.dll
