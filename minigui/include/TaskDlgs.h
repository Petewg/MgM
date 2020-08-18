/*
 * MINIGUI - Harbour Win32 GUI library source code
 * 
 * Copyright 2016 P.Chornyj <myorg63@mail.ru>
 */

#define TDC_CONFIG                  24

#define TDC_HWND                    2  
#define TDC_HINSTANCE               3
#define TDC_TASKDIALOG_FLAGS        4
#define TDC_COMMON_BUTTON_FLAGS     5
#define TDC_WINDOWTITLE             6
#define TDC_MAINICON                7  
#define TDC_MAININSTRUCTION         8
#define TDC_CONTENT                 9
#define TDC_BUTTON                  10
#define TDC_TASKDIALOG_BUTTON       11
#define TDC_DEFAULTBUTTON           12
#define TDC_RADIOBUTTON             13
#define TDC_TASKDIALOG_RADIOBUTTON  14
#define TDC_DEFAULTRADIOBUTTON      15
#define TDC_VERIFICATIONTEXT        16
#define TDC_EXPANDEDINFORMATION     17
#define TDC_EXPANDEDCONTROLTEXT     18
#define TDC_COLLAPSEDCONTROLTEXT    19
#define TDC_FOOTERICON              20 
#define TDC_FOOTER                  21
#define TDC_CALLBACK                22
#define TDC_WIDTH                   24

HRESULT CALLBACK __CBFunc( HWND hWnd, UINT uNotification, WPARAM wParam, LPARAM lParam, LONG_PTR dwRefData );
HRESULT CALLBACK __ClsCBFunc( HWND hWnd, UINT uNotification, WPARAM wParam, LPARAM lParam, LONG_PTR dwRefData );
static HB_BOOL TD_CheckButton( const PHB_ITEM arrayOfButtons, HB_SIZE arraysize );
static const char * TD_NotifyToMsg( UINT uiNotification, PHB_ITEM pObj );
static BOOL TD_objSendMsg( PHB_ITEM pObject, const char * sMsgName, HRESULT * hRes, HWND hWnd, UINT uiNotification, WPARAM wParam, LPARAM lParam );

#if ( ( defined( __BORLANDC__ ) && __BORLANDC__ <= 1410 ) )
// ===================== Task Dialog =========================
#ifndef NOTASKDIALOG
// Task Dialog is only available starting Windows Vista
#if ( NTDDI_VERSION >= NTDDI_VISTA )
#ifdef _WIN32
#include <pshpack1.h>
#endif
typedef HRESULT ( CALLBACK * PFTASKDIALOGCALLBACK )( HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam, LONG_PTR lpRefData );

enum _TASKDIALOG_FLAGS
{
   TDF_ENABLE_HYPERLINKS           = 0x0001,
   TDF_USE_HICON_MAIN              = 0x0002,
   TDF_USE_HICON_FOOTER            = 0x0004,
   TDF_ALLOW_DIALOG_CANCELLATION   = 0x0008,
   TDF_USE_COMMAND_LINKS           = 0x0010,
   TDF_USE_COMMAND_LINKS_NO_ICON   = 0x0020,
   TDF_EXPAND_FOOTER_AREA          = 0x0040,
   TDF_EXPANDED_BY_DEFAULT         = 0x0080,
   TDF_VERIFICATION_FLAG_CHECKED   = 0x0100,
   TDF_SHOW_PROGRESS_BAR           = 0x0200,
   TDF_SHOW_MARQUEE_PROGRESS_BAR   = 0x0400,
   TDF_CALLBACK_TIMER              = 0x0800,
   TDF_POSITION_RELATIVE_TO_WINDOW = 0x1000,
   TDF_RTL_LAYOUT                  = 0x2000,
   TDF_NO_DEFAULT_RADIO_BUTTON     = 0x4000,
   TDF_CAN_BE_MINIMIZED            = 0x8000
};
typedef int TASKDIALOG_FLAGS;                         // Note: _TASKDIALOG_FLAGS is an int

typedef enum _TASKDIALOG_MESSAGES
{
   TDM_NAVIGATE_PAGE                       = WM_USER + 101,
   TDM_CLICK_BUTTON                        = WM_USER + 102, // wParam = Button ID
   TDM_SET_MARQUEE_PROGRESS_BAR            = WM_USER + 103, // wParam = 0 (nonMarque) wParam != 0 (Marquee)
   TDM_SET_PROGRESS_BAR_STATE              = WM_USER + 104, // wParam = new progress state
   TDM_SET_PROGRESS_BAR_RANGE              = WM_USER + 105, // lParam = MAKELPARAM(nMinRange, nMaxRange)
   TDM_SET_PROGRESS_BAR_POS                = WM_USER + 106, // wParam = new position
   TDM_SET_PROGRESS_BAR_MARQUEE            = WM_USER + 107, // wParam = 0 (stop marquee), wParam != 0 (start marquee), lparam = speed (milliseconds between repaints)
   TDM_SET_ELEMENT_TEXT                    = WM_USER + 108, // wParam = element (TASKDIALOG_ELEMENTS), lParam = new element text (LPCWSTR)
   TDM_CLICK_RADIO_BUTTON                  = WM_USER + 110, // wParam = Radio Button ID
   TDM_ENABLE_BUTTON                       = WM_USER + 111, // lParam = 0 (disable), lParam != 0 (enable), wParam = Button ID
   TDM_ENABLE_RADIO_BUTTON                 = WM_USER + 112, // lParam = 0 (disable), lParam != 0 (enable), wParam = Radio Button ID
   TDM_CLICK_VERIFICATION                  = WM_USER + 113, // wParam = 0 (unchecked), 1 (checked), lParam = 1 (set key focus)
   TDM_UPDATE_ELEMENT_TEXT                 = WM_USER + 114, // wParam = element (TASKDIALOG_ELEMENTS), lParam = new element text (LPCWSTR)
   TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE = WM_USER + 115, // wParam = Button ID, lParam = 0 (elevation not required), lParam != 0 (elevation required)
   TDM_UPDATE_ICON                         = WM_USER + 116  // wParam = icon element (TASKDIALOG_ICON_ELEMENTS), lParam = new icon (hIcon if TDF_USE_HICON_* was set, PCWSTR otherwise)
} TASKDIALOG_MESSAGES;

typedef enum _TASKDIALOG_NOTIFICATIONS
{
   TDN_CREATED                = 0,
   TDN_NAVIGATED              = 1,
   TDN_BUTTON_CLICKED         = 2,                      // wParam = Button ID
   TDN_HYPERLINK_CLICKED      = 3,                      // lParam = (LPCWSTR)pszHREF
   TDN_TIMER                  = 4,                      // wParam = Milliseconds since dialog created or timer reset
   TDN_DESTROYED              = 5,
   TDN_RADIO_BUTTON_CLICKED   = 6,                      // wParam = Radio Button ID
   TDN_DIALOG_CONSTRUCTED     = 7,
   TDN_VERIFICATION_CLICKED   = 8,                      // wParam = 1 if checkbox checked, 0 if not, lParam is unused and always 0
   TDN_HELP                   = 9,
   TDN_EXPANDO_BUTTON_CLICKED = 10                      // wParam = 0 (dialog is now collapsed), wParam != 0 (dialog is now expanded)
} TASKDIALOG_NOTIFICATIONS;

typedef struct _TASKDIALOG_BUTTON
{
   int    nButtonID;
   PCWSTR pszButtonText;
} TASKDIALOG_BUTTON;

typedef enum _TASKDIALOG_ELEMENTS
{
   TDE_CONTENT,
   TDE_EXPANDED_INFORMATION,
   TDE_FOOTER,
   TDE_MAIN_INSTRUCTION
} TASKDIALOG_ELEMENTS;

typedef enum _TASKDIALOG_ICON_ELEMENTS
{
   TDIE_ICON_MAIN,
   TDIE_ICON_FOOTER
} TASKDIALOG_ICON_ELEMENTS;

#define TD_WARNING_ICON      MAKEINTRESOURCEW( -1 )
#define TD_ERROR_ICON        MAKEINTRESOURCEW( -2 )
#define TD_INFORMATION_ICON  MAKEINTRESOURCEW( -3 )
#define TD_SHIELD_ICON       MAKEINTRESOURCEW( -4 )

#endif // (NTDDI_VERSION >= NTDDI_VISTA)


#if ( NTDDI_VERSION >= NTDDI_VISTA )
enum _TASKDIALOG_COMMON_BUTTON_FLAGS
{
   TDCBF_OK_BUTTON     = 0x0001,            // selected control return value IDOK
   TDCBF_YES_BUTTON    = 0x0002,            // selected control return value IDYES
   TDCBF_NO_BUTTON     = 0x0004,            // selected control return value IDNO
   TDCBF_CANCEL_BUTTON = 0x0008,            // selected control return value IDCANCEL
   TDCBF_RETRY_BUTTON  = 0x0010,            // selected control return value IDRETRY
   TDCBF_CLOSE_BUTTON  = 0x0020             // selected control return value IDCLOSE
};
typedef int TASKDIALOG_COMMON_BUTTON_FLAGS; // Note: _TASKDIALOG_COMMON_BUTTON_FLAGS is an int

typedef struct _TASKDIALOGCONFIG
{
   UINT             cbSize;
   HWND             hwndParent;
   HINSTANCE        hInstance;                          // used for MAKEINTRESOURCE() strings
   TASKDIALOG_FLAGS dwFlags;                            // TASKDIALOG_FLAGS (TDF_XXX) flags
   TASKDIALOG_COMMON_BUTTON_FLAGS dwCommonButtons;      // TASKDIALOG_COMMON_BUTTON (TDCBF_XXX) flags
   PCWSTR pszWindowTitle;                               // string or MAKEINTRESOURCE()
   union
   {
      HICON  hMainIcon;
      PCWSTR pszMainIcon;
   } DUMMYUNIONNAME;
   PCWSTR pszMainInstruction;
   PCWSTR pszContent;
   UINT   cButtons;
   const TASKDIALOG_BUTTON * pButtons;
   int  nDefaultButton;
   UINT cRadioButtons;
   const TASKDIALOG_BUTTON * pRadioButtons;
   int    nDefaultRadioButton;
   PCWSTR pszVerificationText;
   PCWSTR pszExpandedInformation;
   PCWSTR pszExpandedControlText;
   PCWSTR pszCollapsedControlText;
   union
   {
      HICON  hFooterIcon;
      PCWSTR pszFooterIcon;
   } DUMMYUNIONNAME2;
   PCWSTR pszFooter;
   PFTASKDIALOGCALLBACK pfCallback;
   LONG_PTR lpCallbackData;
   UINT     cxWidth;                                    // width of the Task Dialog's client area in DLU's. If 0, Task Dialog will calculate the ideal width.
} TASKDIALOGCONFIG;

HRESULT TaskDialogIndirect( const TASKDIALOGCONFIG * pTaskConfig, int * pnButton, int * pnRadioButton, BOOL * pfVerificationFlagChecked );
HRESULT TaskDialog( HWND hwndParent, HINSTANCE hInstance, PCWSTR pszWindowTitle, PCWSTR pszMainInstruction, PCWSTR pszContent, TASKDIALOG_COMMON_BUTTON_FLAGS dwCommonButtons, PCWSTR pszIcon, int * pnButton );

typedef  WINCOMMCTRLAPI HRESULT ( WINAPI * fnTaskDialog )( HWND hwndParent, HINSTANCE hInstance, PCWSTR pszWindowTitle, PCWSTR pszMainInstruction, PCWSTR pszContent, TASKDIALOG_COMMON_BUTTON_FLAGS dwCommonButtons, PCWSTR pszIcon, int * pnButton );
typedef  WINCOMMCTRLAPI HRESULT ( WINAPI * fnTaskDialogIndirect )( const TASKDIALOGCONFIG * pTaskConfig, int * pnButton, int * pnRadioButton, BOOL * pfVerificationFlagChecked );

#ifdef _WIN32
#include <poppack.h>
#endif

#endif // (NTDDI_VERSION >= NTDDI_VISTA)
#endif // NOTASKDIALOG
// ==================== End TaskDialog =======================
#endif // defined( __BORLANDC__ )
