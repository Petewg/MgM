call ..\..\..\batch\compile.bat demo         /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat mailwithblat /nl %1 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\batch\compile.bat demo         /lo /b mailwithblat %1 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\batch\compile.bat demo         /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat mailwithblat /do %1 %2 %3 %4 %5 %6 %7 %8 %9
