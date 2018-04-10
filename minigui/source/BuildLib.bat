@echo off
@setlocal

SET HMGPATH=\minigui

SET PATH=%HMGPATH%\harbour\bin;\borland\bcc55\bin;%PATH%

hbmk2 hmg.hbp > build.log 2>&1

@endlocal
