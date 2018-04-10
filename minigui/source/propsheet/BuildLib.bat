@echo off

SET HMGPATH=c:\minigui

SET PATH=%HMGPATH%\harbour\bin;c:\borland\bcc55\bin;%PATH%

hbmk2 propsheet.hbp
