call ..\..\..\Batch\Compile.Bat Main %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Hmg_Error %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\batch\compile.bat Main %1 /lo /b Hmg_Error /l hbhpdf /l libhpdf /l png /l hbzlib /l hbwin /l xhb %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\Batch\Compile.Bat Main %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\Batch\Compile.Bat Hmg_Error %1 /do %2 %3 %4 %5 %6 %7 %8 %9