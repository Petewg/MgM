@echo off
:: - search for the given file in the directories specified by the path, and display the first match
::
::    The main ideas for this script were taken from Raymond Chen's blog:
::
::         http://blogs.msdn.com/b/oldnewthing/archive/2005/01/20/357225.asp
::
:: - it'll be nice to at some point extend this so it won't stop on the first match. That'll
::     help diagnose situations with a conflict of some sort.
:: ---------------------------------------------------------------------------------
:: p.d. NOTE: found in stackoverflow -> http://stackoverflow.com/questions/4002819/
:: usage : fip <filename>

setlocal

:: - search the current directory as well as those in the path
set PATHLIST=.;%PATH%
set EXTLIST=%PATHEXT%

if not "%EXTLIST%" == "" goto :extlist_ok
set EXTLIST=.COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH
:extlist_ok

:: - first look for the file as given (not adding extensions)
for %%i in (%1) do if NOT "%%~$PATHLIST:i"=="" echo %%~$PATHLIST:i

:: - now look for the file adding extensions from the EXTLIST
for %%e in (%EXTLIST%) do @for %%i in (%1%%e) do if NOT "%%~$PATHLIST:i"=="" echo %%~$PATHLIST:i
