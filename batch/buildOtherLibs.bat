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
hbmk2 -ql winprint.hbp   >> %~dp0Build.log 2>>&1

echo    >>  %~dp0Build.log
echo === MINIPRINT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\MiniPrint
hbmk2 -ql miniprint.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === MINIPRINT-2 (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\MiniPrint2
hbmk2 -ql miniprint.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === TSBROWSE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\TsBrowse
hbmk2 -ql tsb.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === ADORDD (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\AdoRDD
hbmk2 -ql adordd.hbp      2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === BOSTAURUS (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\BosTaurus
hbmk2 -ql bostaurus.hbp   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === CALLDLL (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\CallDll
hbmk2 -ql calldll.hbp   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBVPDF (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbVpdf
hbmk2 -ql hbvpdf   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBXML (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbXML
hbmk2 -ql hbxml   2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBZIPARC (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbZipArc
hbmk2 -ql ziparc.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === PROPGRID (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PropGrid
hbmk2 -ql propgrid.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === PROPSHEET (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PropSheet
hbmk2 -ql propsheet.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === QHTM (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\QHTM
hbmk2 -ql qhtm.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === SOCKET (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\Socket
hbmk2 -ql socket.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === TMSAGENT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\TMsAgent
hbmk2 -ql msagent.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === WINREPORT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\WinReport
hbmk2 -ql winreport.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === WINPROCESS (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\WinProcess
hbmk2 -ql winprocess.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HMG_HPDF (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HMG_HPDF
hbmk2 -ql hmg_hpdf.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBAES (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbAES
hbmk2 -ql hbaes.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === DEBUGGER (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\Debugger
hbmk2 -ql debugger.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HbOLE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbOLE
hbmk2 -ql hbole.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBPGSQL (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbpgsql
hbmk2 -ql hbpgsql.hbp    2>> %~dp0Build.log

echo    >>  %~dp0Build.log
echo === HBZEEGRID (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbzeegrid
hbmk2 -ql hbzeegrid.hbp    2>> %~dp0Build.log

echo   >> %~dp0Build.log
echo Build Other Libs finished on %date% %time% >> %~dp0Build.log

SET SRC=
cd %~dp0
