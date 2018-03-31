call ..\..\..\batch\compile.bat Modest     /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat DbSave     /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat Export     /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat PrintStr   /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat Options    /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat Modest     /lo /b DbSave /b Export /b PrintStr /b Options %1 /l xhb %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat DbSave     /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat Export     /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat PrintStr   /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat Options    /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat Modest     /do %1 %2 %3 %4 %5 %6 %7 %8 %9