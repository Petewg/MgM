@if "%MG_BCC%"=="" set MG_BCC=c:\borland\bcc55
@set PATH=%MG_BCC%\bin;%PATH%
@call ..\..\bin\hbmk2 -q0 -w3 -es2 -kmo -l -nulrdd -gc3 -run hbspeed.prg hbspeed.rc
