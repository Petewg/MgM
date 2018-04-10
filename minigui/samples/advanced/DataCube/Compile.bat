call ..\..\..\Batch\Compile.Bat xtract %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridprint %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat xtract %1 /lo /b gridprint /l hbsqlit3 /l sqlite3 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat xtract %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridprint %1 /do %2 %3 %4 %5 %6 %7 %8 %9
