Hi All,
I developed a GUI Debugger for HMG Official.

The difference with others debuggers is that HMG Debugger overlaps the windows
message loop and does not stop or crash of the system when a windows is activated.

The trick is easy:

1) creates the windows of debugger

2) activate the windows of debugger without calls of the loop message of Windows,
   eg.
   while( GetMessage( &Msg, NULL, 0, 0) )

3) insert into loop of the HandleEvent() method of the debugger the function DoEvents(),
   eg.
   while( PeekMessage ( &Msg, NULL, 0, 0, PM_REMOVE ) )

These steps allow applications to call the message loop without affecting the operation
of the debugger.

4) creates WH_CALLWNDPROC and WH_MSGFILTER hooks, eg.
 
 hHook_CallWndProc = SetWindowsHookEx (WH_CALLWNDPROC, CallWndProc, (HINSTANCE) NULL, GetCurrentThreadId());
 hHook_MessageProc = SetWindowsHookEx (WH_MSGFILTER,   MessageProc, (HINSTANCE) NULL, GetCurrentThreadId());

5) in the CALLBACK functions of the hooks: you constantly enable the windows of debugger
   to prevent that other windows or dialog boxes disable the windows of debugger,
   eg.
   EnableWindow ( hWnd_FormDebugger, TRUE );

If HMG Debugger is useful for you, it is made in two files:

- dbgHB.prg with only functions of Harbour and hence independent from the GUI library;
- dbgGUI.prg, only is need to adapt this file for the different GUI libraries.

Best regards,
Claudio Soto
srvet@adinet.com.uy
