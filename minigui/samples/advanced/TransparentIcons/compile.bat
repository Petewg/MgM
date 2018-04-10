IF EXIST demo1.exe DEL demo1.exe
call ..\..\..\batch\compile.bat demo  %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat demo  %1 /lo /nx /r demo %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat demo  %1 /do %2 %3 %4 %5 %6 %7 %8 %9
ren demo.exe demo1.exe

IF EXIST demo2.exe DEL demo2.exe
call ..\..\..\batch\compile.bat demo   %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat themes %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat demo   %1 /lo /nx /b themes /r demo %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat demo   %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat themes %1 /do %2 %3 %4 %5 %6 %7 %8 %9
ren demo.exe demo2.exe
