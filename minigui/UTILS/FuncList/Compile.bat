call ..\..\batch\compile.bat Stock      /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Formater   /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Langs      /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat prg_fine   /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat CallsTable /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Common     /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Stock      /lo /b Formater /b Langs /b prg_fine /b CallsTable /b Common %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Formater   /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Langs      /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat prg_fine   /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat CallsTable /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Common     /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Stock      /do %1 %2 %3 %4 %5 %6 %7 %8 %9