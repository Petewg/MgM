@Echo off
cls
if exist CPUSpeed.exe Start CPUSpeed.exe && GOTO End
call build.bat
Start CPUSpeed.exe
::Echo please build the program with build.bat and try again.
::pause>nul

:End