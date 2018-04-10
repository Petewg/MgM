:BUILD_DLL
call ..\..\..\..\batch\hbmk2.bat %* -hbdyn myicons.c -omyicons_empty

rem http://www.angusj.com/resourcehacker/
set RH_PATH="%ProgramFiles%\Resource Hacker"

:BUILD_SCRIPT
@echo off
@echo [FILENAMES]> myicons_upd.rhs
@echo Open=myicons_empty.dll>> myicons_upd.rhs
@echo SaveAs=myicons.dll>> myicons_upd.rhs
@echo Log=myicons.log>> myicons_upd.rhs
@echo [COMMANDS]>> myicons_upd.rhs
@echo -delete ,,>> myicons_upd.rhs
@echo -add ..\IconVista.ico,ICONGROUP,ICONVISTA,>> myicons_upd.rhs

:UPDATE_DLL
%RH_PATH%\ResourceHacker.exe -script myicons_upd.rhs

:CLEAN
del myicons_upd.rhs

set RH_PATH=
