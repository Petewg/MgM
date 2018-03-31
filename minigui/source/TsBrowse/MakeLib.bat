@echo off

rem Builds MiniGui library TsBrowse.lib.

:OPT
  call ..\..\batch\makelibopt.bat TsBrowse m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\tsbrowse.lib del %MV_BUILD%\tsbrowse.lib

  rem Files for TSBrowse
  %MV_HRB%\bin\harbour h_tbrowse.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include

  rem Addition Classes
  %MV_HRB%\bin\harbour TControl.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour TSColumn.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour scrllbar.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour TComboBox.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour TDatePicker.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour TBtnBox.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour TGetBox.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour TSMulti.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include
  %MV_HRB%\bin\harbour TCursor.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include

  rem for Multi-Lingual feature
  %MV_HRB%\bin\harbour SbMsg.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include

  rem Addition functions
  %MV_HRB%\bin\harbour h_controlmisc1.prg -n1 -w2 -gc0 -i%MV_HRB%\include;%MG_ROOT%\include

  %MG_BCC%\bin\bcc32 -c -O2 -tWM -d -6 -OS -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include -L%MV_HRB%\lib;%MG_BCC%\lib c_tbrowse.c h_tbrowse.c TControl.c TSColumn.c scrllbar.c SbMsg.c c_controlmisc1.c h_controlmisc1.c TComboBox.c TDatePicker.c TBtnBox.c TGetBox.c TSMulti.c TCursor.c
  %MG_BCC%\bin\tlib %MV_BUILD%\tsbrowse.lib +c_tbrowse.obj +h_tbrowse.obj +TControl.obj +TSColumn.obj +scrllbar.obj +SbMsg.obj +c_controlmisc1.obj +h_controlmisc1.obj +TComboBox.obj +TDatePicker.obj +TBtnBox.obj +TGetBox.obj +TSMulti.obj +TCursor.obj
  if exist %MV_BUILD%\tsbrowse.bak del %MV_BUILD%\tsbrowse.bak

:CLEANUP
  if %MV_DODEL%==N          goto END
  if exist *.obj            del *.obj
  if exist h_tbrowse.c      del h_tbrowse.c
  if exist TControl.c       del TControl.c
  if exist TSColumn.c       del TSColumn.c
  if exist scrllbar.c       del scrllbar.c
  if exist TComboBox.c      del TComboBox.c
  if exist TDatePicker.c    del TDatePicker.c
  if exist TBtnBox.c        del TBtnBox.c
  if exist TGetBox.c        del TGetBox.c
  if exist SbMsg.c          del SbMsg.c
  if exist h_controlmisc1.c del h_controlmisc1.c
  if exist TSMulti.c        del TSMulti.c
  if exist TCursor.c        del TCursor.c

:END
  call ..\..\batch\makelibend.bat