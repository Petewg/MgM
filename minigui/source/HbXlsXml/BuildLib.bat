@echo off
@setlocal

SET HMGPATH=c:\minigui

SET PATH=%HMGPATH%\harbour\bin;c:\borland\bcc55\bin;%PATH%

hbmk2 hbxlsxml.hbp

@endlocal
