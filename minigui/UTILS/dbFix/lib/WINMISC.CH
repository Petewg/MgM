/*
   WINMISC.CH

   Misc. Windows defines not included in the other FiveWin header files
*/
#ifndef WINMISC_CH
#define WINMISC_CH

// MessageBox styles

#define MB_OK                 0         // 0x0000
#define MB_OKCANCEL           1         // 0x0001
#define MB_ABORTRETRYIGNORE   2         // 0x0002
#define MB_YESNOCANCEL        3         // 0x0003
#define MB_YESNO              4         // 0x0004
#define MB_RETRYCANCEL        5         // 0x0005
#define MB_TYPEMASK           15        // 0x000F

#define MB_ICONHAND           16        // 0x0010  Can use w/ MessageBeep()
#define MB_ICONQUESTION       32        // 0x0020  Can use w/ MessageBeep()
#define MB_ICONEXCLAMATION    48        // 0x0030  Can use w/ MessageBeep()
#define MB_ICONASTERISK       64        // 0x0040  Can use w/ MessageBeep()
#define MB_ICONMASK           240       // 0x00F0

#define MB_ICONINFORMATION    MB_ICONASTERISK   // Can use w/ MessageBeep()
#define MB_ICONSTOP           MB_ICONHAND       // Can use w/ MessageBeep()

#define MB_DEFBUTTON1         0         // 0x0000
#define MB_DEFBUTTON2         256       // 0x0100
#define MB_DEFBUTTON3         512       // 0x0200
#define MB_DEFMASK            3840      // 0x0F00

#define MB_APPLMODAL          0         // 0x0000
#define MB_SYSTEMMODAL        4096      // 0x1000
#define MB_TASKMODAL          8192      // 0x2000

#define MB_NOFOCUS            32768     // 0x8000

// Additional listbox style constants

#define LBS_EXTENDEDSEL       2048      // 0x0800

// Standard dialog button IDs

/*
#define IDOK             1      Already defined in FiveWin.ch
#define IDCANCEL         2      Already defined in FiveWin.ch
#define IDHELP           998    Already defined in WinApi/FiveWin.ch
*/
#define IDABORT          3
#define IDRETRY          4
#define IDIGNORE         5
#define IDYES            6
#define IDNO             7

// ShowWindow() constants

#define SW_HIDE             0
#define SW_SHOWNORMAL       1
#define SW_NORMAL           1
#define SW_SHOWMINIMIZED    2
#define SW_SHOWMAXIMIZED    3
#define SW_MAXIMIZE         3
#define SW_SHOWNOACTIVATE   4
#define SW_SHOW             5
#define SW_MINIMIZE         6
#define SW_SHOWMINNOACTIVE  7
#define SW_SHOWNA           8
#define SW_RESTORE          9

// Standard icon resource IDs

#define IDI_APPLICATION   MakeIntResource(32512)
#define IDI_HAND          MakeIntResource(32513)
#define IDI_QUESTION      MakeIntResource(32514)
#define IDI_EXCLAMATION   MakeIntResource(32515)
#define IDI_ASTERISK      MakeIntResource(32516)

// Standard cursor resource IDs

#define IDC_ARROW         MakeIntResource(32512)
#define IDC_IBEAM         MakeIntResource(32513)
#define IDC_WAIT          MakeIntResource(32514)
#define IDC_CROSS         MakeIntResource(32515)
#define IDC_UPARROW       MakeIntResource(32516)
#define IDC_SIZE          MakeIntResource(32640)
#define IDC_ICON          MakeIntResource(32641)
#define IDC_SIZENWSE      MakeIntResource(32642)
#define IDC_SIZENESW      MakeIntResource(32643)
#define IDC_SIZEWE        MakeIntResource(32644)
#define IDC_SIZENS        MakeIntResource(32645)

#endif    // WINMISC_CH

