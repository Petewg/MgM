call ..\..\..\Batch\Compile.Bat Main %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat ContactosAdmin %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat TiposAdmin %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat Main %1 /lo /b ContactosAdmin /b TiposAdmin %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat Main %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat ContactosAdmin %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat TiposAdmin %1 /do %2 %3 %4 %5 %6 %7 %8 %9
