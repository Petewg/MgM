/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2005-2013 Grigory Filatov <gfilatov@inbox.ru>
*/

ANNOUNCE RDDSYS

#include "minigui.ch"
#include "sm.ch"

#define PROGRAM "System Metrics"
#define VERSION " v.1.0.0.3"
#define COPYRIGHT " 2005-2013 Grigory Filatov"

#define NTRIM( n ) hb_ntos( n )

*--------------------------------------------------------*
Function Main()
*--------------------------------------------------------*
LOCAL aMetrics := GetMetricsArr(), nWidth

SET AUTOADJUST ON

DEFINE WINDOW Form_1 ; 
	AT 0,0 ; 
	WIDTH 600  + IF( _HMG_IsXP .And. IsThemed(), 6, 0 ) ; 
	HEIGHT 269 + IF( _HMG_IsXP .And. IsThemed(), 6, 0 ) ;
	TITLE PROGRAM ; 
	ICON 'MAIN' ;
	MAIN ;
	ON MAXIMIZE Form_1.Grid_1.ColumnsAutoFit() ;
	ON MOUSECLICK MsgAbout() ;
	FONT 'MS Sans Serif' ;
	SIZE 9

	nWidth := Form_1.Width - 2 * GetBorderWidth() - 10

	@ 6,6 GRID Grid_1 ;
		WIDTH nWidth ;
		HEIGHT Form_1.Height - GetTitleHeight() - 2 * GetBorderHeight() - 10 ;
		HEADERS { 'Name', 'Value', 'Description' } ; 
		WIDTHS { 162, 42, nWidth - GetSystemMetrics ( SM_CXVSCROLL ) - 208 } ;
		ITEMS aMetrics ;
		NOLINES ;
		ON DBLCLICK ( CopyToClipboard( ;
			Form_1.Grid_1.Cell( GetProperty( "Form_1", "Grid_1", "Value" ), 1 ) ), ;
			MsgInfo( "The name have been copied to clipboard", PROGRAM ) ) ;
		JUSTIFY { GRID_JTFY_LEFT, GRID_JTFY_RIGHT, GRID_JTFY_LEFT }

	ON KEY ESCAPE ACTION ThisWindow.Release()

END WINDOW

Form_1.MinWidth := GetProperty( 'Form_1', 'Width' )
Form_1.MinHeight := GetProperty( 'Form_1', 'Height' )

CENTER WINDOW Form_1

ACTIVATE WINDOW Form_1

Return Nil

*--------------------------------------------------------*
Static Function GetMetricsArr()
*--------------------------------------------------------*
LOCAL i, aItems := {}
LOCAL sm := ;
{ ;
{SM_ARRANGE,		"SM_ARRANGE", "Flags specifying how the system arranged minimized windows. For more information about minimized windows, see the following Remarks section."},;
{SM_CLEANBOOT,		"SM_CLEANBOOT", "Value that specifies how the system was started: 0 Normal boot; 1 - Fail-safe boot; 2 - Fail-safe with network boot. Fail-safe boot (also called SafeBoot) bypasses the user's startup files."},;
{SM_CMONITORS,		"SM_CMONITORS", "Windows 2000 and later; Windows 98: Number of display monitors on the desktop."},;
{SM_CMOUSEBUTTONS,	"SM_CMOUSEBUTTONS", "Number of buttons on mouse, or zero if no mouse is installed."},;
{SM_CXBORDER,		"SM_CXBORDER", ""},;
{SM_CYBORDER,		"SM_CYBORDER", "Width and height, in pixels, of a window border. This is equivalent to the SM_CXEDGE value for windows with the 3-D look."},;
{SM_CXCURSOR,		"SM_CXCURSOR", ""},;
{SM_CYCURSOR,		"SM_CYCURSOR", "Width and height, in pixels, of a cursor. The system cannot create cursors of other sizes. "},;
{SM_CXDLGFRAME,		"SM_CXDLGFRAME", ""},;
{SM_CYDLGFRAME,		"SM_CYDLGFRAME", "Same as SM_CXFIXEDFRAME and SM_CYFIXEDFRAME. "},;
{SM_CXDOUBLECLK,	"SM_CXDOUBLECLK", " "},;
{SM_CYDOUBLECLK,	"SM_CYDOUBLECLK", "Width and height, in pixels, of the rectangle around the location of a first click in a double-click sequence. The second click must occur within this rectangle for the system to consider the two clicks a double-click. (The two clicks must also occur within a specified time.) To set the width and height of the double-click rectangle, call SystemParametersInfo with the SPI_SETDOUBLECLKHEIGHT and SPI_SETDOUBLECLKWIDTH flags."},;
{SM_CXDRAG,		"SM_CXDRAG", ""},;
{SM_CYDRAG,		"SM_CYDRAG", "Width and height, in pixels, of a rectangle centered on a drag point to allow for limited movement of the mouse pointer before a drag operation begins. This allows the user to click and release the mouse button easily without unintentionally starting a drag operation. "},;
{SM_CXEDGE,		"SM_CXEDGE", ""},;
{SM_CYEDGE,		"SM_CYEDGE", "Dimensions, in pixels, of a 3-D border. These are the 3-D counterparts of SM_CXBORDER and SM_CYBORDER. "},;
{SM_CXFIXEDFRAME,	"SM_CXFIXEDFRAME", ""},;
{SM_CYFIXEDFRAME,	"SM_CYFIXEDFRAME", "Thickness, in pixels, of the frame around the perimeter of a window that has a caption but is not sizable. SM_CXFIXEDFRAME is the width of the horizontal border and SM_CYFIXEDFRAME is the height of the vertical border. Same as SM_CXDLGFRAME and SM_CYDLGFRAME."},;
{SM_CXFRAME,		"SM_CXFRAME", ""},;
{SM_CYFRAME,		"SM_CYFRAME", "Same as SM_CXSIZEFRAME and SM_CYSIZEFRAME. "},;
{SM_CXFULLSCREEN,	"SM_CXFULLSCREEN", ""},;
{SM_CYFULLSCREEN,	"SM_CYFULLSCREEN", "Width and height of the client area for a full-screen window on the primary display monitor. To get the coordinates of the portion of the screen not obscured by the system taskbar or by application desktop toolbars, call the SystemParametersInfo function with the SPI_GETWORKAREA value.  "},;
{SM_CXHSCROLL,		"SM_CXHSCROLL", ""},;
{SM_CYHSCROLL,		"SM_CYHSCROLL", "Width, in pixels, of the arrow bitmap on a horizontal scroll bar; and height, in pixels, of a horizontal scroll bar. "},;
{SM_CXHTHUMB,		"SM_CXHTHUMB", "Width, in pixels, of the thumb box in a horizontal scroll bar. "},;
{SM_CXICON,		"SM_CXICON", " "},;
{SM_CYICON,		"SM_CYICON", "The default width and height, in pixels, of an icon. The LoadIcon function can load only icons of these dimensions.  "},;
{SM_CXICONSPACING,	"SM_CXICONSPACING", ""},;
{SM_CYICONSPACING,	"SM_CYICONSPACING", "Dimensions, in pixels, of a grid cell for items in large icon view. Each item fits into a rectangle of this size when arranged. These values are always greater than or equal to SM_CXICON and SM_CYICON. "},;
{SM_CXMAXIMIZED,	"SM_CXMAXIMIZED", ""},;
{SM_CYMAXIMIZED,	"SM_CYMAXIMIZED", "Default dimensions, in pixels, of a maximized top-level window on the primary display monitor. "},;
{SM_CXMAXTRACK,		"SM_CXMAXTRACK", ""},;
{SM_CYMAXTRACK,		"SM_CYMAXTRACK", "Default maximum dimensions, in pixels, of a window that has a caption and sizing borders. This metric refers to the entire desktop. The user cannot drag the window frame to a size larger than these dimensions. A window can override these values by processing the WM_GETMINMAXINFO message. "},;
{SM_CXMENUCHECK,	"SM_CXMENUCHECK", ""},;
{SM_CYMENUCHECK,	"SM_CYMENUCHECK", "Dimensions, in pixels, of the default menu check-mark bitmap. "},;
{SM_CXMENUSIZE,		"SM_CXMENUSIZE", ""},;
{SM_CYMENUSIZE,		"SM_CYMENUSIZE", "Dimensions, in pixels, of menu bar buttons, such as the child window close button used in the multiple document interface.  "},;
{SM_CXMIN,		"SM_CXMIN", ""},;
{SM_CYMIN,		"SM_CYMIN", "Minimum width and height, in pixels, of a window. "},;
{SM_CXMINIMIZED,	"SM_CXMINIMIZED", ""},;
{SM_CYMINIMIZED,	"SM_CYMINIMIZED", "Dimensions, in pixels, of a normal minimized window. "},;
{SM_CXMINSPACING,	"SM_CXMINSPACING", ""},;
{SM_CYMINSPACING,	"SM_CYMINSPACING", "Dimensions, in pixels, of a grid cell for minimized windows. Each minimized window fits into a rectangle this size when arranged. These values are always greater than or equal to SM_CXMINIMIZED and SM_CYMINIMIZED. "},;
{SM_CXMINTRACK,		"SM_CXMINTRACK", ""},;
{SM_CYMINTRACK,		"SM_CYMINTRACK", "Minimum tracking width and height, in pixels, of a window. The user cannot drag the window frame to a size smaller than these dimensions. A window can override these values by processing the WM_GETMINMAXINFO message. "},;
{SM_CXSCREEN,		"SM_CXSCREEN", " "},;
{SM_CYSCREEN,		"SM_CYSCREEN", "Width and height, in pixels, of the screen of the primary display monitor. These are the same values you obtain by calling GetDeviceCaps(hdcPrimaryMonitor, HORZRES/VERTRES). "},;
{SM_CXSIZE,		"SM_CXSIZE", ""},;
{SM_CYSIZE,		"SM_CYSIZE", "Width and height, in pixels, of a button in a window's caption or title bar. "},;
{SM_CXSIZEFRAME,	"SM_CXSIZEFRAME", ""},;
{SM_CYSIZEFRAME,	"SM_CYSIZEFRAME", "Thickness, in pixels, of the sizing border around the perimeter of a window that can be resized. SM_CXSIZEFRAME is the width of the horizontal border, and SM_CYSIZEFRAME is the height of the vertical border.  Same as SM_CXFRAME and SM_CYFRAME."},;
{SM_CXSMICON,		"SM_CXSMICON", ""},;
{SM_CYSMICON,		"SM_CYSMICON", "Recommended dimensions, in pixels, of a small icon. Small icons typically appear in window captions and in small icon view. "},;
{SM_CXSMSIZE,		"SM_CXSMSIZE", ""},;
{SM_CYSMSIZE,		"SM_CYSMSIZE", "Dimensions, in pixels, of small caption buttons. "},;
{SM_CXVIRTUALSCREEN,	"SM_CXVIRTUALSCREEN", ""},;
{SM_CYVIRTUALSCREEN,	"SM_CYVIRTUALSCREEN", "Windows 2000 and later; Windows 98: Width and height, in pixels, of the virtual screen. The virtual screen is the bounding rectangle of all display monitors. The SM_XVIRTUALSCREEN, SM_YVIRTUALSCREEN metrics are the coordinates of the top-left corner of the virtual screen. "},;
{SM_CXVSCROLL,		"SM_CXVSCROLL", ""},;
{SM_CYVSCROLL,		"SM_CYVSCROLL", "Width, in pixels, of a vertical scroll bar; and height, in pixels, of the arrow bitmap on a vertical scroll bar. "},;
{SM_CYCAPTION,		"SM_CYCAPTION", "Height, in pixels, of a normal caption area. "},;
{SM_CYKANJIWINDOW,	"SM_CYKANJIWINDOW", "For double byte character set versions of the system, this is the height, in pixels, of the Kanji window at the bottom of the screen. "},;
{SM_CYMENU,		"SM_CYMENU", "Height, in pixels, of a single-line menu bar. "},;
{SM_CYSMCAPTION,	"SM_CYSMCAPTION", "Height, in pixels, of a small caption. "},;
{SM_CYVTHUMB,		"SM_CYVTHUMB", "Height, in pixels, of the thumb box in a vertical scroll bar. "},;
{SM_DBCSENABLED,	"SM_DBCSENABLED", "TRUE or nonzero if the double-byte character-set (DBCS) version of User.exe is installed; FALSE or zero otherwise. "},;
{SM_DEBUG,		"SM_DEBUG", "TRUE or nonzero if the debugging version of User.exe is installed; FALSE or zero otherwise. "},;
;//	{SM_IMMENABLED,		"SM_IMMENABLED", "Windows 2000: TRUE or nonzero if Input Method Manager/Input Method Editor features are enabled; FALSE or zero otherwise. Can determine if the system handles Unicode IME. However, if the IME is language dependent you should also check that the target language has been installed. Otherwise some components, like fonts or registry settings, may not be present. "},;
{SM_MENUDROPALIGNMENT,	"SM_MENUDROPALIGNMENT", "TRUE or nonzero if drop-down menus are right-aligned with the corresponding menu-bar item; FALSE or zero if the menus are left-aligned. "},;
{SM_MIDEASTENABLED,	"SM_MIDEASTENABLED", "TRUE if the system is enabled for Hebrew and Arabic languages. "},;
{SM_MOUSEPRESENT,	"SM_MOUSEPRESENT", "TRUE or nonzero if a mouse is installed; FALSE or zero otherwise. "},;
{SM_MOUSEWHEELPRESENT,	"SM_MOUSEWHEELPRESENT", "Windows NT 4.0 and later, Windows 98: TRUE or nonzero if a mouse with a wheel is installed; FALSE or zero otherwise. "},;
{SM_NETWORK,		"SM_NETWORK", "The least significant bit is set if a network is present; otherwise, it is cleared. The other bits are reserved for future use. "},;
{SM_PENWINDOWS,		"SM_PENWINDOWS", "TRUE or nonzero if the Microsoft Windows for Pen computing extensions are installed; FALSE or zero otherwise. "},;
;//	{SM_REMOTESESSION,	"SM_REMOTESESSION", "Terminal Server Edition 4.0 SP4 or Windows 2000 or later: This system metric is used in a Terminal Services environment. If the calling process is associated with a Terminal Services client session, the return value is TRUE or nonzero. If the calling process is associated with the Terminal Server console session, the return value is zero. "},;
{SM_SECURE,		"SM_SECURE", "TRUE if security is present; FALSE otherwise. "},;
{SM_SAMEDISPLAYFORMAT,	"SM_SAMEDISPLAYFORMAT", "Windows 2000 and later; Windows 98: TRUE if all the display monitors have the same color format, FALSE otherwise. Note that two displays can have the same bit depth, but different color formats. For example, the red, green, and blue pixels can be encoded with different numbers of bits, or those bits can be located in different places in a pixel's color value. "},;
{SM_SHOWSOUNDS,		"SM_SHOWSOUNDS", "TRUE or nonzero if the user requires an application to present information visually in situations where it would otherwise present the information only in audible form; FALSE, or zero, otherwise. "},;
{SM_SLOWMACHINE,	"SM_SLOWMACHINE", "TRUE if the computer has a low-end (slow) processor; FALSE otherwise. "},;
{SM_SWAPBUTTON,		"SM_SWAPBUTTON", "TRUE or nonzero if the meanings of the left and right mouse buttons are swapped; FALSE or zero otherwise. "},;
{SM_XVIRTUALSCREEN,	"SM_XVIRTUALSCREEN", ""},;
{SM_YVIRTUALSCREEN,	"SM_YVIRTUALSCREEN", "Windows 2000 and later; Windows 98: Coordinates for the left side and the top of the virtual screen. The virtual screen is the bounding rectangle of all display monitors. The SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN metrics are the width and height of the virtual screen. "};
}

FOR i := 1 TO Len( sm )

	Aadd( aItems, { sm [i] [2], NTRIM( GetSystemMetrics ( sm [i] [1] ) ), sm [i] [3] } )

NEXT

Return aItems

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	"eMail: gfilatov@inbox.ru" + CRLF + CRLF + ;
	"This program is Freeware!" + CRLF + ;
	padc("Copying is allowed!", 30), "About..." )
