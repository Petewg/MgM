call ..\..\..\Batch\Compile.Bat demo %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat tsb2xml %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat demo %1 /lo /b Tsb2xml /l hbxlsxml %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat demo %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Tsb2xml %1 /do %2 %3 %4 %5 %6 %7 %8 %9