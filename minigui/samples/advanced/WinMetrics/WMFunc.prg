************************************
STATIC Function FilSysMet()
************************************
LOCAL aMetrics := {;
{ "WIN_SM_CXSCREEN", "0", "The width of the screen of the primary display monitor, in pixels. This is the same value obtained by calling GetDeviceCaps as follows: GetDeviceCaps( hdcPrimaryMonitor, HORZRES)." }, ;
{ "WIN_SM_CYSCREEN", "1", "The height of the screen of the primary display monitor, in pixels. This is the same value obtained by calling GetDeviceCaps as follows: GetDeviceCaps( hdcPrimaryMonitor, VERTRES)." }, ;
{ "WIN_SM_CXVSCROLL", "2", "The width of a vertical scroll bar, in pixels." }, ;
{ "WIN_SM_CYHSCROLL", "3", "The height of a horizontal scroll bar, in pixels." }, ;
{ "WIN_SM_CYCAPTION", "4", "The height of a caption area, in pixels." }, ;
{ "WIN_SM_CXBORDER", "5", "The width of a window border, in pixels. This is equivalent to the SM_CXEDGE value for windows with the 3-D look." }, ;
{ "WIN_SM_CYBORDER", "6", "The height of a window border, in pixels. This is equivalent to the SM_CYEDGE value for windows with the 3-D look." }, ;
{ "WIN_SM_CXDLGFRAME", "7", "This value is the same as SM_CXFIXEDFRAME." }, ;
{ "WIN_SM_CXFIXEDFRAME", "7", "The thickness of the frame around the perimeter of a window that has a caption but is not sizable, in pixels. SM_CXFIXEDFRAME is the height of the horizontal border, and SM_CYFIXEDFRAME is the width of the vertical border.  This value is the same as SM_CXDLGFRAME." }, ;
{ "WIN_SM_CYDLGFRAME", "8", "This value is the same as SM_CYFIXEDFRAME." }, ;
{ "WIN_SM_CYFIXEDFRAME", "8", "The thickness of the frame around the perimeter of a window that has a caption but is not sizable, in pixels. SM_CXFIXEDFRAME is the height of the horizontal border, and SM_CYFIXEDFRAME is the width of the vertical border. This value is the same as SM_CYDLGFRAME." }, ;
{ "WIN_SM_CYVTHUMB", "9", "The height of the thumb box in a vertical scroll bar, in pixels." }, ;
{ "WIN_SM_CXHTHUMB", "10", "The width of the thumb box in a horizontal scroll bar, in pixels." }, ;
{ "WIN_SM_CXICON", "11", "The default width of an icon, in pixels. The LoadIcon function can load only icons with the dimensions that SM_CXICON and SM_CYICON specifies." }, ;
{ "WIN_SM_CYICON", "12", "The default height of an icon, in pixels. The LoadIcon function can load only icons with the dimensions SM_CXICON and SM_CYICON." }, ;
{ "WIN_SM_CXCURSOR", "13", "The width of a cursor, in pixels. The system cannot create cursors of other sizes." }, ;
{ "WIN_SM_CYCURSOR", "14", "The height of a cursor, in pixels. The system cannot create cursors of other sizes." }, ;
{ "WIN_SM_CYMENU", "15", "The height of a single-line menu bar, in pixels." }, ;
{ "WIN_SM_CXFULLSCREEN", "16", "The width of the client area for a full-screen window on the primary display monitor, in pixels. To get the coordinates of the portion of the screen that is not obscured by the system taskbar or by application desktop toolbars, call the SystemParametersInfo function with the SPI_GETWORKAREA value." }, ;
{ "WIN_SM_CYFULLSCREEN", "17", "The height of the client area for a full-screen window on the primary display monitor, in pixels. To get the coordinates of the portion of the screen not obscured by the system taskbar or by application desktop toolbars, call the SystemParametersInfo function with the SPI_GETWORKAREA value." }, ;
{ "WIN_SM_CYKANJIWINDOW", "18", "For double byte character set versions of the system, this is the height of the Kanji window at the bottom of the screen, in pixels." }, ;
{ "WIN_SM_MOUSEPRESENT", "19", "Nonzero if a mouse is installed; otherwise, 0. This value is rarely zero, because of support for virtual mice and because some systems detect the presence of the port instead of the presence of a mouse." }, ;
{ "WIN_SM_CYVSCROLL", "20", "The height of the arrow bitmap on a vertical scroll bar, in pixels." }, ;
{ "WIN_SM_CXHSCROLL", "21", "The width of the arrow bitmap on a horizontal scroll bar, in pixels." }, ;
{ "WIN_SM_DEBUG", "22", "Nonzero if the debug version of User.exe is installed; otherwise, 0." }, ;
{ "WIN_SM_SWAPBUTTON", "23", "Nonzero if the meanings of the left and right mouse buttons are swapped; otherwise, 0." }, ;
{ "WIN_SM_CXMIN", "28", "The minimum width of a window, in pixels." }, ;
{ "WIN_SM_CYMIN", "29", "The minimum height of a window, in pixels." }, ;
{ "WIN_SM_CXSIZE", "30", "The width of a button in a window caption or title bar, in pixels." }, ;
{ "WIN_SM_CYSIZE", "31", "The height of a button in a window caption or title bar, in pixels." }, ;
{ "WIN_SM_CXFRAME", "32", "This value is the same as SM_CXSIZEFRAME." }, ;
{ "WIN_SM_CXSIZEFRAME", "32", "The thickness of the sizing border around the perimeter of a window that can be resized, in pixels. SM_CXSIZEFRAME is the width of the horizontal border, and SM_CYSIZEFRAME is the height of the vertical border.  This value is the same as SM_CXFRAME." }, ;
{ "WIN_SM_CYFRAME", "33", "This value is the same as SM_CYSIZEFRAME." }, ;
{ "WIN_SM_CYSIZEFRAME", "33", "The thickness of the sizing border around the perimeter of a window that can be resized, in pixels. SM_CXSIZEFRAME is the width of the horizontal border, and SM_CYSIZEFRAME is the height of the vertical border. This value is the same as SM_CYFRAME." }, ;
{ "WIN_SM_CXMINTRACK", "34", "The minimum tracking width of a window, in pixels. The user cannot drag the window frame to a size smaller than these dimensions. A window can override this value by processing the WM_GETMINMAXINFO message." }, ;
{ "WIN_SM_CYMINTRACK", "35", "The minimum tracking height of a window, in pixels. The user cannot drag the window frame to a size smaller than these dimensions. A window can override this value by processing the WM_GETMINMAXINFO message." }, ;
{ "WIN_SM_CXDOUBLECLK", "36", "The width of the rectangle around the location of a first click in a double-click sequence, in pixels. The second click must occur within the rectangle that is defined by SM_CXDOUBLECLK and SM_CYDOUBLECLK for the system to consider the two clicks a double-click. The two clicks must also occur within a specified time. To set the width of the double-click rectangle, call SystemParametersInfo with SPI_SETDOUBLECLKWIDTH." }, ;
{ "WIN_SM_CYDOUBLECLK", "37", "The height of the rectangle around the location of a first click in a double-click sequence, in pixels. The second click must occur within the rectangle defined by SM_CXDOUBLECLK and SM_CYDOUBLECLK for the system to consider the two clicks a double-click. The two clicks must also occur within a specified time. To set the height of the double-click rectangle, call SystemParametersInfo with SPI_SETDOUBLECLKHEIGHT." }, ;
{ "WIN_SM_CXICONSPACING", "38", "The width of a grid cell for items in large icon view, in pixels. Each item fits into a rectangle of size SM_CXICONSPACING by SM_CYICONSPACING when arranged. This value is always greater than or equal to SM_CXICON." }, ;
{ "WIN_SM_CYICONSPACING", "39", "The height of a grid cell for items in large icon view, in pixels. Each item fits into a rectangle of size SM_CXICONSPACING by SM_CYICONSPACING when arranged. This value is always greater than or equal to SM_CYICON." }, ;
{ "WIN_SM_MENUDROPALIGNMENT", "40", "Nonzero if drop-down menus are right-aligned with the corresponding menu-bar item; 0 if the menus are left-aligned." }, ;
{ "WIN_SM_PENWINDOWS", "41", "Nonzero if the Microsoft Windows for Pen computing extensions are installed; zero otherwise." }, ;
{ "WIN_SM_DBCSENABLED", "42", "Nonzero if User32.dll supports DBCS; otherwise, 0. " }, ;
{ "WIN_SM_CMOUSEBUTTONS", "43", "The number of buttons on a mouse, or zero if no mouse is installed." }, ;
{ "WIN_SM_SECURE", "44", "This system metric should be ignored; it always returns 0." }, ;
{ "WIN_SM_CXEDGE", "45", "The width of a 3-D border, in pixels. This metric is the 3-D counterpart of SM_CXBORDER." }, ;
{ "WIN_SM_CYEDGE", "46", "The height of a 3-D border, in pixels. This is the 3-D counterpart of SM_CYBORDER." }, ;
{ "WIN_SM_CXMINSPACING", "47", "The width of a grid cell for a minimized window, in pixels. Each minimized window fits into a rectangle this size when arranged. This value is always greater than or equal to SM_CXMINIMIZED." }, ;
{ "WIN_SM_CYMINSPACING", "48", "The height of a grid cell for a minimized window, in pixels. Each minimized window fits into a rectangle this size when arranged. This value is always greater than or equal to SM_CYMINIMIZED." }, ;
{ "WIN_SM_CXSMICON", "49", "The recommended width of a small icon, in pixels. Small icons typically appear in window captions and in small icon view." }, ;
{ "WIN_SM_CYSMICON", "50", "The recommended height of a small icon, in pixels. Small icons typically appear in window captions and in small icon view." }, ;
{ "WIN_SM_CYSMCAPTION", "51", "The height of a small caption, in pixels." }, ;
{ "WIN_SM_CXSMSIZE", "52", "The width of small caption buttons, in pixels." }, ;
{ "WIN_SM_CYSMSIZE", "53", "The height of small caption buttons, in pixels." }, ;
{ "WIN_SM_CXMENUSIZE", "54", "The width of menu bar buttons, such as the child window close button that is used in the multiple document interface, in pixels." }, ;
{ "WIN_SM_CYMENUSIZE", "55", "The height of menu bar buttons, such as the child window close button that is used in the multiple document interface, in pixels." }, ;
{ "WIN_SM_ARRANGE", "56", "The flags that specify how the system arranged minimized windows. For more information, see the Remarks section in this topic." }, ;
{ "WIN_SM_CXMINIMIZED", "57", "The width of a minimized window, in pixels." }, ;
{ "WIN_SM_CYMINIMIZED", "58", "The height of a minimized window, in pixels." }, ;
{ "WIN_SM_CXMAXTRACK", "59", "The default maximum width of a window that has a caption and sizing borders, in pixels. This metric refers to the entire desktop. The user cannot drag the window frame to a size larger than these dimensions. A window can override this value by processing the WM_GETMINMAXINFO message." }, ;
{ "WIN_SM_CYMAXTRACK", "60", "The default maximum height of a window that has a caption and sizing borders, in pixels. This metric refers to the entire desktop. The user cannot drag the window frame to a size larger than these dimensions. A window can override this value by processing the WM_GETMINMAXINFO message." }, ;
{ "WIN_SM_CXMAXIMIZED", "61", "The default width, in pixels, of a maximized top-level window on the primary display monitor." }, ;
{ "WIN_SM_CYMAXIMIZED", "62", "The default height, in pixels, of a maximized top-level window on the primary display monitor." }, ;
{ "WIN_SM_NETWORK", "63", "The least significant bit is set if a network is present; otherwise, it is cleared. The other bits are reserved for future use." }, ;
{ "WIN_SM_CLEANBOOT", "67", "The value that specifies how the system is started: 0 Normal boot - 1 Fail-safe boot - 2 Fail-safe with network boot" }, ;
{ "WIN_SM_CXDRAG", "68", "The number of pixels on either side of a mouse-down point that the mouse pointer can move before a drag operation begins. This allows the user to click and release the mouse button easily without unintentionally starting a drag operation. If this value is negative, it is subtracted from the left of the mouse-down point and added to the right of it." }, ;
{ "WIN_SM_CYDRAG", "69", "The number of pixels above and below a mouse-down point that the mouse pointer can move before a drag operation begins. This allows the user to click and release the mouse button easily without unintentionally starting a drag operation. If this value is negative, it is subtracted from above the mouse-down point and added below it." }, ;
{ "WIN_SM_SHOWSOUNDS", "70", "Nonzero if the user requires an application to present information visually in situations where it would otherwise present the information only in audible form; otherwise, 0." }, ;
{ "WIN_SM_CXMENUCHECK", "71", "The width of the default menu check-mark bitmap, in pixels." }, ;
{ "WIN_SM_CYMENUCHECK", "72", "The height of the default menu check-mark bitmap, in pixels." }, ;
{ "WIN_SM_SLOWMACHINE", "73", "Nonzero if the computer has a low-end (slow) processor; otherwise, 0." }, ;
{ "WIN_SM_MIDEASTENABLED", "74", "Nonzero if the system is enabled for Hebrew and Arabic languages, 0 if not." }, ;
{ "WIN_SM_MOUSEWHEELPRESENT", "75", "Nonzero if a mouse with a vertical scroll wheel is installed; otherwise 0. " }, ;
{ "WIN_SM_XVIRTUALSCREEN", "76", "The coordinates for the left side of the virtual screen. The virtual screen is the bounding rectangle of all display monitors. The SM_CXVIRTUALSCREEN metric is the width of the virtual screen. " }, ;
{ "WIN_SM_YVIRTUALSCREEN", "77", "The coordinates for the top of the virtual screen. The virtual screen is the bounding rectangle of all display monitors. The SM_CYVIRTUALSCREEN metric is the height of the virtual screen. " }, ;
{ "WIN_SM_CXVIRTUALSCREEN", "78", "The width of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors. The SM_XVIRTUALSCREEN metric is the coordinates for the left side of the virtual screen. " }, ;
{ "WIN_SM_CYVIRTUALSCREEN", "79", "The height of the virtual screen, in pixels. The virtual screen is the bounding rectangle of all display monitors. The SM_YVIRTUALSCREEN metric is the coordinates for the top of the virtual screen." }, ;
{ "WIN_SM_CMONITORS", "80", "The number of display monitors on a desktop. For more information, see the Remarks section in this topic. " }, ;
{ "WIN_SM_SAMEDISPLAYFORMAT", "81", "Nonzero if all the display monitors have the same color format, otherwise, 0. Two displays can have the same bit depth, but different color formats. For example, the red, green, and blue pixels can be encoded with different numbers of bits, or those bits can be located in different places in a pixel color value. " }, ;
{ "WIN_SM_IMMENABLED", "82", "Nonzero if Input Method Manager/Input Method Editor features are enabled; otherwise, 0. SM_IMMENABLED indicates whether the system is ready to use a Unicode-based IME on a Unicode application. To ensure that a language-dependent IME works, check SM_DBCSENABLED and the system ANSI code page. Otherwise the ANSI-to-Unicode conversion may not be performed correctly, or some components like fonts or registry settings may not be present." }, ;
{ "WIN_SM_CXFOCUSBORDER", "83", "The width of the left and right edges of the focus rectangle that the DrawFocusRect draws. This value is in pixels.  Windows 2000:  This value is not supported." }, ;
{ "WIN_SM_CYFOCUSBORDER", "84", "The height of the top and bottom edges of the focus rectangle drawn by DrawFocusRect. This value is in pixels. Windows 2000:  This value is not supported." }, ;
{ "WIN_SM_TABLETPC", "86", "Nonzero if the current operating system is the Windows XP Tablet PC edition or if the current operating system is Windows Vista or Windows 7 and the Tablet PC Input service is started; otherwise, 0. The SM_DIGITIZER setting indicates the type of digitizer input supported by a device running Windows 7 or Windows Server 2008 R2. For more information, see Remarks. " }, ;
{ "WIN_SM_MEDIACENTER", "87", "Nonzero if the current operating system is the Windows XP, Media Center Edition, 0 if not." }, ;
{ "WIN_SM_STARTER", "88", "Nonzero if the current operating system is Windows 7 Starter Edition, Windows Vista Starter, or Windows XP Starter Edition; otherwise, 0." }, ;
{ "WIN_SM_SERVERR2", "89", "The build number if the system is Windows Server 2003 R2; otherwise, 0." }, ;
{ "WIN_SM_MOUSEHORIZONTALWHEELPRESENT", "91", "Nonzero if a mouse with a horizontal scroll wheel is installed; otherwise 0." }, ;
{ "WIN_SM_CXPADDEDBORDER", "92", "The amount of border padding for captioned windows, in pixels. Windows XP/2000:  This value is not supported." }, ;
{ "WIN_SM_DIGITIZER", "94", "Nonzero if the current operating system is Windows 7 or Windows Server 2008 R2 and the Tablet PC Input service is started; otherwise, 0. The return value is a bit mask that specifies the type of digitizer input supported by the device. For more information, see Remarks. Windows Server 2008, Windows Vista, and Windows XP/2000:  This value is not supported." }, ;
{ "WIN_SM_MAXIMUMTOUCHES", "95", "Nonzero if there are digitizers in the system; otherwise, 0. SM_MAXIMUMTOUCHES returns the aggregate maximum of the maximum number of contacts supported by every digitizer in the system. If the system has only single-touch digitizers, the return value is 1. If the system has multi-touch digitizers, the return value is the number of simultaneous contacts the hardware can provide. Windows Server 2008, Windows Vista, and Windows XP/2000:  This value is not supported." }, ;
{ "WIN_SM_REMOTESESSION", "4096", "This system metric is used in a Terminal Services environment. If the calling process is associated with a Terminal Services client session, the return value is nonzero. If the calling process is associated with the Terminal Services console session, the return value is 0. Windows Server 2003 and Windows XP:  The console session is not necessarily the physical console. For more information, see WTSGetActiveConsoleSessionId." }, ;
{ "WIN_SM_SHUTTINGDOWN", "8192", "Nonzero if the current session is shutting down; otherwise, 0. Windows 2000:  This value is not supported." }, ;
{ "WIN_SM_REMOTECONTROL", "8193", "This system metric is used in a Terminal Services environment. Its value is nonzero if the current session is remotely controlled; otherwise, 0." } ;
}
LOCAL nI, nLen
LOCAL aRet := {}, ele
nLen := LEN(aMetrics)
FOR nI := 1 to nLen
	ele := { PADL(nI,2,"0"), aMetrics[nI,1],  PADL( WAPI_GetSystemMetrics( VAL( aMetrics[nI,2] ) ), 5 ), aMetrics[nI,3] }
	AADD( aRet, ele )
NEXT
RETURN aRet
