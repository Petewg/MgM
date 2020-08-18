REM @echo off

@CALL %~dp0SetPaths.bat

SET SRC=%~d0\MiniguiM\minigui\source

echo ------------------------------------------------------------------------- >> Build.log
echo Build Other Libs started on %date% %time% >> Build.log
echo ------------------------------------------------------------------------- >> Build.log
echo    >>  Build.log

echo    >>  Build.log
echo === HBPRINTER (%date% %time%) === >> Build.log
CD /d %SRC%\HbPrinter
hbmk2 -ql -warn=max winprint.hbp   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === MINIPRINT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\MiniPrint
hbmk2 -ql -warn=max miniprint.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === TSBROWSE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\TsBrowse
hbmk2 -ql -warn=max tsb.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === ADORDD (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\AdoRDD
hbmk2 -ql -warn=max adordd.hbp      2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === BOSTAURUS (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\BosTaurus
hbmk2 -ql -warn=max bostaurus.hbp   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === CALLDLL (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\CallDll
hbmk2 -ql -warn=max calldll.hbp   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBVPDF (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbVpdf
hbmk2 -ql -warn=max hbvpdf   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBXML (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbXML
hbmk2 -ql -warn=max hbxml   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBZIPARC (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbZipArc
hbmk2 -ql -warn=max ziparc.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === PROPGRID (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PropGrid
hbmk2 -ql -warn=max propgrid.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === PROPSHEET (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PropSheet
hbmk2 -ql -warn=max propsheet.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === QHTM (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\QHTM
hbmk2 -ql -warn=max qhtm.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === SOCKET (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\Socket
hbmk2 -ql -warn=max socket.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === TMSAGENT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\TMsAgent
hbmk2 -ql -warn=max msagent.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === WINREPORT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\WinReport
hbmk2 -ql -warn=max winreport.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === WINPROCESS (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\WinProcess
hbmk2 -ql -warn=max winprocess.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HMG_HPDF (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HMG_HPDF
hbmk2 -ql -warn=max hmg_hpdf.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBAES (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbAES
hbmk2 -ql -warn=max hbaes.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === DEBUGGER (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\Debugger
hbmk2 -ql -warn=max debugger.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HbOLE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbOLE
hbmk2 -ql -warn=max hbole.hbp    2>> %~dp0Build.log

echo   >> %~dp0Build.log
echo Build Other Libs finished on %date% %time% >> %~dp0Build.log

SET SRC=
cd %~dp0
