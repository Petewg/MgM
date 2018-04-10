call ..\..\Batch\Compile.Bat CLDBFix  %1 /nl %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat clrepair %1 /nl %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\Batch\Compile.Bat CLDBFix  %1 /c /lo /b clrepair /l clraylib %2 %3 %4 %5 %6 %7 %8 %9

call ..\..\Batch\Compile.Bat CLDBFix  %1 /do %2 %3 %4 %5 %6 %7 %8 %9
call ..\..\Batch\Compile.Bat clrepair %1 /do %2 %3 %4 %5 %6 %7 %8 %9