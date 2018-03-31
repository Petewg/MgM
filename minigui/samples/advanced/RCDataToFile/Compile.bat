@echo off
call ..\..\..\batch\compile.bat hello /c /nx %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat demo /cg %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat demo2 /l hbmemio %1 %2 %3 %4 %5 %6 %7 %8 %9
if exist hello.exe del hello.exe