@echo off

rem Makes all Harbour libraries from folders under SOURCE folder.

@echo.
@echo AdoRDD.lib
@echo.
cd AdoRDD
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo BosTaurus.lib
@echo.
cd BosTaurus
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo CallDll.lib
@echo.
cd CallDll
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo Dll.lib
@echo.
cd Dll
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbComm.lib
@echo.
cd HbComm
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbGdiP.lib
@echo.
cd hbgdip
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbODBC.lib and ODBC32.lib
@echo.
cd HbODBC
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbOLE.lib
@echo.
cd HbOLE
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbPgSql.lib
@echo.
cd HbPgSql
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbPrinter.lib
@echo.
cd HbPrinter
call MakeLib.Bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbSqlDD.lib
@echo.
cd HbSqlDD
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbSQLit3.lib
@echo.
cd HbSQLite3
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbVpdf.lib
@echo.
cd HbVpdf
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo Hmg_Hpdf.lib
@echo.
cd Hmg_Hpdf
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbXlsXml.lib
@echo.
cd HbXlsXML
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbXML.lib
@echo.
cd HbXML
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbZeeGrid.lib
@echo.
cd HbZeeGrid
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo HbZipArc.lib
@echo.
cd HbZipArc
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo PScript.lib
@echo.
cd PageScript
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo MiniPrint.lib
@echo.
cd MiniPrint
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo MySQL.lib
@echo.
cd HbMySQL
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo shell32.lib
@echo.
cd shell32
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo Socket.lib
@echo.
cd Socket
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo SQLite3Facade.lib
@echo.
cd SQLite3Facade
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

@echo.
@echo TMsAgent.lib
@echo.
cd TMsAgent
call MakeLib.bat %1 %2 %3 %4 %5 %6 %7 %8 %9
cd ..

:END