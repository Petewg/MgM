:BUILD_DLL
hbmk2 -hbdyn myicons.c -omyicons_empty

@echo off
rem http://www.angusj.com/resourcehacker/
SET RH_PATH="%ProgramFiles%\Resource Hacker"
:BUILD_SCRIPT
@echo [FILENAMES] > myicons_upd.rhs
@echo Open=myicons_empty.dll >> myicons_upd.rhs
@echo SaveAs=..\myicons.dll     >> myicons_upd.rhs
@echo Log=CON        >> myicons_upd.rhs
@echo [COMMANDS]             >> myicons_upd.rhs
:: @echo -delete ,,,            >> myicons_upd.rhs
:: @echo -add IconVista.ico,ICONGROUP,MAINICON,0 >> myicons_upd.rhs
@echo -add ..\IconVista.ico,ICONGROUP,ICONVISTA,0 >> myicons_upd.rhs



:UPDATE_DLL
%RH_PATH%\ResourceHacker.exe -script myicons_upd.rhs
if errorlevel 1 echo failed!


:CLEAN
del myicons_upd.rhs
del myicons_empty.dll
