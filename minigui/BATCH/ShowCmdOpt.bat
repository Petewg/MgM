@echo off

rem ===========================================================================
rem ShowCmdOpt.bat
rem ===========================================================================

cls 
color 0F

:HELP
  rem Display batch file syntax message
  echo.
  echo Compile.bat
  echo Compiles and links a PRG into an EXE, then runs the EXE.
  echo.
  echo Syntax:
  echo Compile (source) [?] [/X] [/-X] [/D] [/C] [/CG] [/MT] [/T] [/W] [/E] [/P]
  echo         [/NC] [/NL] [/NX] [/NM] [/ND] [/CO] [/RO] [/LO] [/DO] [/XI] [/XW]
  echo         [/S (opt) [...]] [/SC (opt) [...]] [/B (obj) [...]]
  echo         [/O] [/Z] [/A] [/M] [/PG]
  echo         [/L (lib) [...]] [/LG (lib) [...]] [/LE (lib) [...]]
  echo         [/R (res) [...]] [/XS (opt) [...]]
  echo.
  pause
  color 0A
  echo   (source)    PRG file name without extension
  echo   /X          Use xHarbour, must precede other options,
  echo                 default if MG_CMP set to XHARBOUR, see below
  echo   /-X         Use Harbour, must precede other options,
  echo                 default if MG_CMP missing or not set to XHARBOUR
  echo   /D          Create debug EXE
  echo   /C          Create console EXE
  echo   /CG         Create mixed console and GUI EXE
  echo   /MT         Create multi threaded EXE
  echo   /T          Use Turbo Assembler during C compile
  echo   /W          Generate compiler warnings
  echo   /E          Send compile and link error output to (source).ERR
  echo   /P          Pause at end
  pause
  echo   /NC         No C compile or link or run, [x]Harbour compile only
  echo   /NL         No link or run, compile only
  echo   /NX         No run, compile and link only
  echo   /NM         Do not compile as a main PRG
  echo   /ND         Do not delete temporary files after compile and link
  echo   /CO         C compile only, no link or run, requires (source).C only
  echo   /RO         Resource compile only, requires (source).RC only
  echo   /LO         Link and run only, requires (source).OBJ only
  echo   /DO         Delete temporary files only, no compile or link
  echo   /XI         Run EXE in immediate mode (without START)
  echo   /XW         Run EXE in wait mode (with START /W)
  pause
  echo   /S          Use additional Harbour compiler switch
  echo   (opt)       Compiler switch
  echo   /SC         Use additional C compiler switch
  echo   (opt)       Compiler switch
  echo   /B          Link additional object file
  echo   (obj)       Name of additional object file without extension
  echo   /O          Link ODBC libraries
  echo   /Z          Link Zip libraries
  echo   /A          Link ADS libraries
  echo   /M          Link MySql libraries
  echo   /PG         Link PostgreSQL libraries
  echo   /L          Link additional [x]Harbour library
  echo   (lib)       Name of additional library without extension
  echo   /LG         Link additional MiniGui library
  echo   (lib)       Name of additional library without extension
  echo   /LE         Link additional external library
  echo   (lib)       Name of additional library with path but without extension
  echo.
  pause
  echo   /R          Link additional resource file
  echo   (res)       Name of additional resource file without extension
  echo   /XS         Add argument to EXE command line
  echo   (arg)       EXE command line argument
  echo   /S (opt), /B (obj), /L (lib), /LG (lib), R (res), /XS (arg) may be repeated.
  echo   Spacing between parameters must be as shown.
  echo.
  echo You may set the following environment variables.
  echo Locations in these variables must not have a trailing backslash.
  echo.
  echo   MG_BCC      Location of BCC, default C:\Borland\BCC55
  echo   MG_ROOT     Location of MinuGui, default C:\MiniGui
  echo   MG_HRB      Location of Harbour, default (MG_ROOT)\Harbour
  echo   MG_LIB      Location of Harbour MiniGui libraries, default (MG_ROOT)\Lib
  echo   MG_XHRB     Location of xHarbour, default C:\xHarbour
  echo   MG_XLIB     Location of xHarbour MiniGui libraries, default (MG_ROOT)\xLib
  echo   MG_CMP      If set to XHARBOUR, then use xHarbour by default,
  echo                 /X is not necessary, may be overridden by /-X
  echo.
  pause
  echo The following files are optional and are used only if present.
  echo.
  echo   (source).RC    Used as resource file, required only if /RO used
  echo   (source).RSP   Used as link response file instead of temporary file:
  echo                      /D, /C, /B, /O, /Z, /A, /M, /L, /LG, /R ignored
  echo   (source).BAT   Run at end instead of (source).EXE
  echo.
  color 0F
