REM @echo off

@CALL %~dp0SetPaths.bat

SET SRC=%~d0\MiniguiM\minigui\source

echo ------------------------------------------------------------------------- >> Build.log
echo Build Other Libs started on %date% %time% >> Build.log
echo ------------------------------------------------------------------------- >> Build.log
echo(    >>  Build.log

echo(    >>  Build.log
echo === HBPRINTER (%date% %time%) === >> Build.log
CD /d %SRC%\HbPrinter
hbmk2 -lang=en -ql winprint.hbp   >> %~dp0Build.log 2>>&1

echo(    >>  %~dp0Build.log
echo === MINIPRINT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\MiniPrint
hbmk2 -ql miniprint.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === MINIPRINT-2 (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\MiniPrint2
hbmk2 -ql miniprint2.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === ADORDD (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\AdoRDD
hbmk2 -ql adordd.hbp      2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === BOSTAURUS (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\BosTaurus
hbmk2 -ql bostaurus.hbp   2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === CALLDLL (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\CallDll
hbmk2 -ql calldll.hbp   2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === DEBUGGER (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\Debugger
hbmk2 -ql debugger.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBAES (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbAES
hbmk2 -ql hbaes.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === FREEIMAGE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbfimage
hbmk2 -ql hbfimage.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBGDIP (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbgdip
hbmk2 -ql hbgdip.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBMYSQL (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbmysql
hbmk2 -ql hbmysql.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBODBC (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbodbc
hbmk2 -ql hbodbc.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HbOLE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbOLE
hbmk2 -ql hbole.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBPGSQL (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbpgsql
hbmk2 -ql hbpgsql.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBSQLDD (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbSqlDD
hbmk2 -ql hbsqldd.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBSQLITE3 (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbsqlite3
hbmk2 -ql hbsqlit3.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBVPDF (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbVpdf
hbmk2 -ql hbvpdf   2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBXLSXML (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbxlsxml
hbmk2 -ql hbxlsxml.hbp   2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBXML (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbXML
hbmk2 -ql hbxml   2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBZEEGRID (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbzeegrid
hbmk2 -ql hbzeegrid.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HBZIPARC (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HbZipArc
hbmk2 -ql hbziparc.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === HMG_HPDF (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\HMG_HPDF
hbmk2 -ql hmg_hpdf.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === MGMMISC (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\mgmMisc
hbmk2 -ql mgmMisc.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === PAGESCRIPT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PageScript
hbmk2 -ql PScript.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === PDFPRINTER (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PdfPrinter
hbmk2 -ql PdfPrinter.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === PROPGRID (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PropGrid
hbmk2 -ql propgrid.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === PROPSHEET (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\PropSheet
hbmk2 -ql propsheet.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === QHTM (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\QHTM
hbmk2 -ql qhtm.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === SEVENZIP (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\sevenzip
hbmk2 -ql sevenzip.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === SHELL32 (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\shell32
hbmk2 -ql shell32.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === SOCKET (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\Socket
hbmk2 -ql socket.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === SQLITE3FACADE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\sqlite3facade
hbmk2 -ql sqlite3facade.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === TMSAGENT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\TMsAgent
hbmk2 -ql msagent.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === TSBROWSE (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\TsBrowse
hbmk2 -ql tsb.hbp    2>> %~dp0Build.log

echo(    >>  %~dp0Build.log
echo === WINREPORT (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\WinReport
hbmk2 -ql winreport.hbp    2>> %~dp0Build.log


echo(    >>  %~dp0Build.log
echo === HBCRYPTO (%date% %time%) === >> %~dp0Build.log
CD /d %SRC%\hbcrypto
hbmk2 -ql hbcrypto.hbp    2>> %~dp0Build.log


echo   >> %~dp0Build.log
echo Build Other Libs finished on %date% %time% >> %~dp0Build.log

SET SRC=
cd %~dp0
