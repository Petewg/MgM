call ..\..\..\..\batch\compile.bat DBFview %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\..\batch\compile.bat lang %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\..\batch\compile.bat userfun %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\..\batch\compile.bat DBFview %1 /lo /b lang /b userfun %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\..\..\batch\compile.bat DBFview %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\..\batch\compile.bat lang %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\..\batch\compile.bat userfun %1 /do %2 %3 %4 %5 %6 %7 %8 %9
