@echo off
call build_dll.bat QbGen
call ..\..\batch\compile.bat Quickb /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat HMG_Zebra /nl %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\batch\compile.bat Quickb /lo /b HMG_Zebra /lg winreport /l hbhpdf /l libhpdf /l png /l hbzlib /l hbzebra /l BosTaurus %1 %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\Batch\Compile.Bat Quickb /do %1 %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat HMG_Zebra /do %1 %2 %3 %4 %5 %6 %7 %8 %9
