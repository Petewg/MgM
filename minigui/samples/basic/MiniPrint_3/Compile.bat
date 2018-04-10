call ..\..\..\Batch\Compile.Bat TstPPTF3 %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat HL_Libs  %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat PaprTyps %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat PrPTFil3 %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat TstPPTF3 %1 /lo /b HL_Libs /b PaprTyps /b PrPTFil3 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat TstPPTF3 %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat HL_Libs  %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat PaprTyps %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat PrPTFil3 %1 /do %2 %3 %4 %5 %6 %7 %8 %9
