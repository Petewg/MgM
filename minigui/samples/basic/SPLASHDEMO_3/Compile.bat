call ..\..\..\Batch\Compile.Bat main %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat main_check %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat main_forms %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat Main %1 /lo /b main_check /b main_forms /r main %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat main %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat main_check %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat main_forms %1 /do %2 %3 %4 %5 %6 %7 %8 %9
