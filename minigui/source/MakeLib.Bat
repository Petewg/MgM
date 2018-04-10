@echo off

rem Builds MiniGui.lib.

:OPT
  call ..\batch\makelibopt.bat MiniGui m %1 %2 %3 %4 %5 %6 %7 %8 %9
  if %MV_EXIT%==Y    goto END
  if %MV_DODONLY%==Y goto CLEANUP

:BUILD
  if exist %MV_BUILD%\minigui.lib del %MV_BUILD%\minigui.lib
  %MV_HRB%\bin\harbour h_activex h_animate h_browse h_scrsaver h_error.prg h_ipaddress.prg h_monthcal.prg h_help.prg h_crypt.prg h_status.prg h_tree.prg h_toolbar.prg errorsys.prg h_init.prg h_media.prg h_webcam.prg h_winapimisc.prg h_slider.prg h_button.prg h_checkbox.prg h_combo.prg h_controlmisc.prg h_datepicker.prg h_editbox.prg h_dialogs.prg h_grid.prg h_windows.prg h_windowsmdi.prg h_image.prg h_imagelist.prg h_label.prg h_listbox.prg h_menu.prg h_msgbox.prg h_frame.prg h_progressbar.prg h_radio.prg h_spinner.prg h_tab.prg h_textbox.prg h_timer.prg h_ini.prg h_report.prg h_registry.prg h_font.prg h_hyperlink.prg h_hotkey.prg h_draw.prg h_graph.prg h_dialog.prg h_richeditbox.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n1 -w3 -es2
  %MV_HRB%\bin\harbour h_winprop.prg h_socket.prg h_getbox.prg h_btntextbox.prg h_hotkeybox.prg h_events.prg h_edit.prg h_edit_ex.prg h_wbrush.prg h_gradient.prg h_mru.prg h_folder.prg h_pager.prg h_chklabel.prg h_chklistbox.prg h_clbutton.prg h_splitbutton.prg h_Gif89.prg h_objmisc.prg h_misc.prg h_rptgen.prg h_alert.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n1 -w3 -es2
  %MV_HRB%\bin\harbour h_objects.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n1 -w3 -es2
  %MV_HRB%\bin\harbour h_taskdlg.prg -i%MV_HRB%\include;%MG_ROOT%\include; -n1 -w3 -es2
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include; -L%MV_HRB%\lib;%MG_BCC%\lib; h_scrsaver.c h_edit.c h_edit_ex.c h_error.c h_ipaddress.c c_ipaddress.c h_monthcal.c c_monthcal.c h_help.c c_help.c h_crypt.c c_crypt.c h_status.c c_status.c h_tree.c c_tree.c c_toolbar.c h_toolbar.c errorsys.c h_init.c h_media.c c_media.c h_winapimisc.c h_slider.c c_button.c c_checkbox.c c_combo.c c_controlmisc.c c_datepicker.c c_resource.c c_cursor.c c_ini.c h_ini.c h_report.c h_registry.c h_font.c c_font.c h_hyperlink.c h_richeditbox.c c_richeditbox.c c_bitmap.c c_dialog.c c_imagelist.c h_imagelist.c c_windowsAPI.c c_windowsCLS.c
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include; -L%MV_HRB%\lib;%MG_BCC%\lib; c_winxp.c c_editbox.c c_dialogs.c c_grid.c c_windows.c c_windowsmdi.c c_image.c c_label.c c_listbox.c c_menu.c c_msgbox.c c_frame.c c_progressbar.c c_radio.c c_registry.c c_slider.c c_spinner.c c_tab.c c_textbox.c c_timer.c h_webcam.c c_winapimisc.c h_button.c h_checkbox.c h_combo.c h_controlmisc.c h_datepicker.c h_editbox.c h_dialogs.c h_grid.c h_windows.c h_windowsmdi.c h_image.c h_label.c h_listbox.c h_menu.c h_msgbox.c h_frame.c h_progressbar.c h_radio.c h_spinner.c h_tab.c h_textbox.c h_timer.c c_scrsaver.c h_hotkey.c h_events.c
  %MG_BCC%\bin\bcc32 -c -tWM -d -6 -O2 -OS -Ov -Oi -Oc -I%MV_HRB%\include;%MG_BCC%\include;%MG_ROOT%\include; -L%MV_HRB%\lib;%MG_BCC%\lib; c_hotkey.c h_draw.c c_draw.c h_graph.c c_graph.c h_activex.c h_animate.c h_browse.c c_browse.c h_socket.c h_dialog.c h_winprop.c c_winprop.c h_getbox.c c_getbox.c h_btntextbox.c c_btntextbox.c h_hotkeybox.c c_hotkeybox.c h_wbrush.c h_gradient.c h_mru.c h_folder.c c_folder.c h_pager.c c_pager.c h_chklabel.c c_chklabel.c h_chklistbox.c c_chklistbox.c h_clbutton.c h_splitbutton.c h_Gif89.c h_taskdlg.c c_taskdlgs.c c_tooltip.c c_cuebanner.c c_hmgapp.c hbgdiplus.c c_icon.c c_monitors.c c_error.c h_objects.c h_objmisc.c h_misc.c h_rptgen.c h_alert.c
  %MG_BCC%\bin\tlib /P32 %MV_BUILD%\minigui.lib +h_scrsaver.obj +h_edit.obj +h_edit_ex.obj +h_error.obj +h_ipaddress.obj +c_ipaddress.obj +h_monthcal.obj +c_monthcal.obj +h_help.obj +c_help.obj +h_status.obj +c_status.obj +h_tree.obj +c_tree.obj +h_toolbar.obj +c_toolbar.obj +errorsys.obj +h_init.obj +h_media.obj + c_media.obj +c_resource.obj +c_cursor.obj +h_ini.obj +c_ini.obj +h_report.obj +h_font.obj +c_font.obj +h_hyperlink.obj +c_scrsaver.obj +h_hotkey.obj +c_hotkey.obj +h_draw.obj +c_draw.obj +h_graph.obj +c_graph.obj +h_richeditbox.obj +c_richeditbox.obj +h_activex.obj +h_animate.obj +h_browse.obj +c_browse.obj +h_socket.obj +c_bitmap.obj +c_imagelist.obj +h_imagelist.obj +c_winxp.obj +h_objects.obj +h_objmisc.obj
  %MG_BCC%\bin\tlib /P32 %MV_BUILD%\minigui.lib +c_crypt.obj +h_crypt.obj +h_webcam.obj +h_winapimisc.obj +h_slider.obj +c_button.obj +c_checkbox.obj +c_combo.obj +c_controlmisc.obj +c_datepicker.obj +c_editbox.obj +c_dialogs.obj +c_grid.obj +c_windows.obj +c_windowsmdi.obj +c_image.obj +c_label.obj +c_listbox.obj +c_menu.obj +c_msgbox.obj +c_frame.obj +c_progressbar.obj +c_radio.obj +c_registry.obj +c_slider.obj +c_spinner.obj +c_tab.obj +c_textbox.obj +c_timer.obj +c_dialog.obj +c_winapimisc.obj +h_button.obj +h_checkbox.obj +h_combo.obj +h_controlmisc.obj +h_datepicker.obj +h_editbox.obj +h_dialogs.obj +h_grid.obj +h_windows.obj +h_windowsmdi.obj +h_image.obj +h_label.obj +h_listbox.obj +h_Gif89.obj +h_rptgen.obj
  %MG_BCC%\bin\tlib /P32 %MV_BUILD%\minigui.lib +h_menu.obj +h_msgbox.obj +h_frame.obj +h_progressbar.obj +h_radio.obj +h_spinner.obj +h_tab.obj +h_textbox.obj +h_timer.obj +h_registry.obj +h_dialog.obj +h_winprop.obj +c_winprop.obj +h_getbox.obj +c_getbox.obj +h_btntextbox.obj +c_btntextbox.obj +h_hotkeybox.obj +c_hotkeybox.obj +c_windowsAPI.obj +c_windowsCLS.obj +h_wbrush.obj +h_gradient.obj +h_events.obj +h_mru.obj +h_folder.obj +c_folder.obj +h_pager.obj +c_pager.obj +h_chklabel.obj +c_chklabel.obj +h_chklistbox.obj +c_chklistbox.obj +h_clbutton.obj +h_splitbutton.obj +h_taskdlg.obj +c_taskdlgs.obj +c_tooltip.obj +c_cuebanner.obj +c_hmgapp.obj +hbgdiplus.obj +c_icon.obj +c_monitors.obj +c_error.obj +h_misc.obj +h_alert.obj
  if exist %MV_BUILD%\minigui.bak del %MV_BUILD%\minigui.bak

:CLEANUP
  if %MV_DODEL%==N    goto END
  if exist *.obj      del *.obj
  if exist h_*.c      del h_*.c
  if exist errorsys.c del errorsys.c

:END
  call ..\batch\makelibend.bat
