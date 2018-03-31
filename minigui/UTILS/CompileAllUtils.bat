:: Compile All Utils
::
::
@ echo off


:Utils


cd Code_ReIndent

@echo .
@echo .
@echo .
@echo Utils\Code_ReIndent
@echo .
cd..\Code_ReIndent
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\DBU
@echo .
cd..\DBU
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\DBA
@echo .
cd..\DBA
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\FMG2PRG
@echo .
cd..\FMG2PRG
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\FuncList
@echo .
cd..\FuncList
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\HB_LIB
@echo .
cd..\HB_LIB
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\hmg_dbview
@echo .
cd..\hmg_dbview
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\hmg_funclist
@echo .
cd..\hmg_funclist
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\HMG_MYSYNC
@echo .
cd..\HMG_MYSYNC
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\LL_DBU
@echo .
cd..\LL_DBU
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\MPM
@echo .
cd..\MPM
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\MPMC
@echo .
cd..\MPMC
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\Project_Analyzer
@echo .
cd..\Project_Analyzer
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\SOURCE_ARCHIVER
@echo .
cd..\SOURCE_ARCHIVER
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\SqlDBU
@echo .
cd..\SqlDBU
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

@echo .
@echo .
@echo .
@echo Utils\xForm
@echo .
cd..\xForm
call compile.bat /nx %1 %2 %3 %4 %5 %6 %7 %8 %9

cd ..

@echo .
@echo .

:ENDUtils


:END
