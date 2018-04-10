@echo off

if not defined MG_BCC set MG_BCC=c:\borland\bcc55
set PATH=%MG_BCC%\bin;%PATH%

brc32 -r -i..\include;%MG_BCC%\include minigui.rc
brc32 -r hbprinter.rc
brc32 -r miniprint.rc