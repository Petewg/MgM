call ..\..\..\batch\compile.bat PdfView    /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat PdfView_C  /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat SumatraPDF /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat PdfView    /lo /b PdfView_C /b SumatraPDF /l calldll %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat PdfView    /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat PdfView_C  /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\..\batch\compile.bat SumatraPDF /do %1 %2 %3 %4 %5 %6 %7 %8 %9