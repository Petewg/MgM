call ..\..\..\batch\compile.bat sqlite3_test %1 /c /l hbsqlit3 /l sqlite3 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat metadata %1 /c /l hbsqlit3 /l sqlite3 /s /DNODLL %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat blob %1 /c /l hbsqlit3 /l sqlite3 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat pack %1 /c /l hbsqlit3 /l sqlite3 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat authorizer %1 /c /l hbsqlit3 /l sqlite3 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat backup %1 /c /l hbsqlit3 /l sqlite3 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat hooks %1 /c /l hbsqlit3 /l sqlite3 %2 %3 %4 %5 %6 %7 %8 %9