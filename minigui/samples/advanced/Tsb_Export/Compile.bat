call ..\..\..\Batch\Compile.Bat demo %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat tsb2xml %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat tsb2dbf %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat tsb2doc %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Tsb2xlsOleExtern %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat demo %1 /lo /b Tsb2xml /b Tsb2dbf /b Tsb2doc /b Tsb2xlsOleExtern /l hbxlsxml %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat demo %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Tsb2xml %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Tsb2dbf %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Tsb2doc %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Tsb2xlsOleExtern %1 /do %2 %3 %4 %5 %6 %7 %8 %9