call ..\..\..\Batch\Compile.Bat Main %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat grid2csv %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridprint %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridpdf %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridtoolbar %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat Main %1 /lo /b grid2csv /b gridprint /b gridpdf /b gridtoolbar /r GridToolBar /l hmg_hpdf /l hbhpdf /l libhpdf /l png /l hbzlib %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat Main %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat grid2csv %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridprint %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridpdf %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat gridtoolbar %1 /do %2 %3 %4 %5 %6 %7 %8 %9