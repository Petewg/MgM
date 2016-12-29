/*
 * MINIGUI - Harbour Win32 GUI library source code
 * 
 * Copyright 2016 P.Chornyj <myorg63@mail.ru>
 */

/* TDF_ Task Dialog Flags - specifies the behavior of the task dialog */
#define TDF_ENABLE_HYPERLINKS           1        // 0x1
#define TDF_USE_HICON_MAIN              2        // 0x2
#define TDF_USE_HICON_FOOTER            4        // 0x4
#define TDF_ALLOW_DIALOG_CANCELLATION   8        // 0x8
#define TDF_USE_COMMAND_LINKS           16       // 0x10
#define TDF_USE_COMMAND_LINKS_NO_ICON   32       // 0x20
#define TDF_EXPAND_FOOTER_AREA          64       // 0x40
#define TDF_EXPANDED_BY_DEFAULT         128      // 0x80
#define TDF_VERIFICATION_FLAG_CHECKED   256      // 0x100
#define TDF_SHOW_PROGRESS_BAR           512      // 0x200
#define TDF_SHOW_MARQUEE_PROGRESS_BAR   1024     // 0x400
#define TDF_CALLBACK_TIMER              2048     // 0x800
#define TDF_POSITION_RELATIVE_TO_WINDOW 4096     // 0x1000
#define TDF_RTL_LAYOUT                  8192     // 0x2000
#define TDF_NO_DEFAULT_RADIO_BUTTON     16384    // 0x4000
#define TDF_CAN_BE_MINIMIZED            32768    // 0x8000
#define TDF_NO_SET_FOREGROUND           65536    // 0x10000
#define TDF_SIZE_TO_CONTENT             16777216 // 0x1000000

/* TDC_ Task Dialog Config */
#define TDC_CONFIG                      TDC_WIDTH
#define TDC_HWND                        2
#define TDC_HINSTANCE                   3
#define TDC_TASKDIALOG_FLAGS            4
#define TDC_COMMON_BUTTON_FLAGS         5
#define TDC_WINDOWTITLE                 6
#define TDC_MAINICON                    7
#define TDC_MAININSTRUCTION             8
#define TDC_CONTENT                     9
#define TDC_BUTTON                      10
#define TDC_TASKDIALOG_BUTTON           11
#define TDC_DEFAULTBUTTON               12
#define TDC_RADIOBUTTON                 13
#define TDC_TASKDIALOG_RADIOBUTTON      14
#define TDC_DEFAULTRADIOBUTTON          15
#define TDC_VERIFICATIONTEXT            16
#define TDC_EXPANDEDINFORMATION         17
#define TDC_EXPANDEDCONTROLTEXT         18
#define TDC_COLLAPSEDCONTROLTEXT        19
#define TDC_FOOTERICON                  20
#define TDC_FOOTER                      21
#define TDC_CALLBACK                    22
#define TDC_WIDTH                       24

/* TDCBF_ Task Dialog Common Button Flags */ 
#define TDCBF_OK_BUTTON                 1  // 0x1 
#define TDCBF_YES_BUTTON                2  // 0x2 
#define TDCBF_NO_BUTTON                 4  // 0x4 
#define TDCBF_CANCEL_BUTTON             8  // 0x8 
#define TDCBF_RETRY_BUTTON              16 // 0x10 
#define TDCBF_CLOSE_BUTTON              32 // 0x20 
  
/* button-click return values */ 
#define IDOK                            1 
#define IDCANCEL                        2 
#define IDABORT                         3 
#define IDRETRY                         4 
#define IDIGNORE                        5 
#define IDYES                           6 
#define IDNO                            7 
#define IDCLOSE                         8 
  
/* TD_ Task Dialog predefined icons */ 
#define TD_NO_ICON                      0     // No icon appears in the task dialog. This is the default. 
#define TD_WARNING_ICON                 65535 // An exclamation-point icon, along with warning sound. 
#define TD_ERROR_ICON                   65534 // A stop-sign icon, along with error sound. 
#define TD_INFORMATION_ICON             65533 // An icon consisting of a lowercase letter `i` in a circle, along with info sound. 
#define TD_SHIELD_ICON                  65532 // A shield icon. NOTE: All shield icons have no sound! 
#define TD_SHIELD_BLUE_ICON             65531 // A shield icon on a blue background. 
#define TD_SHIELD_WARNING_ICON          65530 // An icon consisting of an exclamation-point in a shield. appears in yellow/orange background. 
#define TD_SHIELD_ERROR_ICON            65529 // An icon consisting of a stop-sign in a shield. appears in red background. 
#define TD_SHIELD_SUCCESS_ICON          65528 // An icon consisting of a tick-sign in a shield. appears in green background. 
#define TD_SHIELD_BROWN_ICON            65527 // A shield icon on a brown background. 
#define TD_QUESTION                     99    // An icon consisting of a a question-mark in a circle, no sound!

/* TDN_ Task Dialog Notification */
#define TDN_CREATED                     0
#define TDN_NAVIGATED                   1
#define TDN_BUTTON_CLICKED              2  // wParam = Button ID
#define TDN_HYPERLINK_CLICKED           3  // lParam = (LPCWSTR)pszHREF
#define TDN_TIMER                       4  // wParam = Milliseconds since dialog created or timer reset
#define TDN_DESTROYED                   5
#define TDN_RADIO_BUTTON_CLICKED        6  // wParam = Radio Button ID
#define TDN_DIALOG_CONSTRUCTED          7
#define TDN_VERIFICATION_CLICKED        8  // wParam = 1 if checkbox checked, 0 if not, lParam is unused and always 0
#define TDN_HELP                        9
#define TDN_EXPANDO_BUTTON_CLICKED      10 // wParam = 0 (dialog is now collapsed), wParam != 0 (dialog is now expanded)

/* TDM_ Task Dialog Messages */
#ifndef WM_USER
#define WM_USER                         1024 // 0x0400
#endif

#define TDM_CLICK_BUTTON                WM_USER+102 //Simulates the action of a button click in a task dialog.
#define TDM_CLICK_RADIO_BUTTON          WM_USER+110 //Simulates the action of a radio button click in a task dialog.
#define TDM_CLICK_VERIFICATION          WM_USER+113 //Simulates the action of a verification checkbox click in a task dialog.
#define TDM_ENABLE_BUTTON               WM_USER+111 //Enables or disables a push button in a task dialog.
#define TDM_ENABLE_RADIO_BUTTON         WM_USER+112 //Enables or disables a radio button in a task dialog.
#define TDM_NAVIGATE_PAGE               WM_USER+101 // Recreates a task dialog with new contents, simulating the functionality of a multi-page wizard.
#define TDM_SET_BUTTON_ELEVATION_REQUIRED_STATE WM_USER+115 //Specifies whether a given task dialog button or command link should have a User Account Control (UAC) shield icon; that is, whether the action invoked by the button requires elevation.
#define TDM_SET_ELEMENT_TEXT            WM_USER+108 // Updates a text element in a task dialog.
#define TDM_SET_MARQUEE_PROGRESS_BAR    WM_USER+103 //Indicates whether the hosted progress bar should be displayed in marquee mode.
#define TDM_SET_PROGRESS_BAR_MARQUEE    WM_USER+107 //Starts and stops the marquee display of the progress bar, and sets the speed of the marquee.
#define TDM_SET_PROGRESS_BAR_POS        WM_USER+106 //Sets the current position for a progress bar.
#define TDM_SET_PROGRESS_BAR_RANGE      WM_USER+105 //Sets the minimum and maximum values for the hosted progress bar.
#define TDM_SET_PROGRESS_BAR_STATE      WM_USER+104 //Sets the current state of the progress bar.
#define TDM_UPDATE_ELEMENT_TEXT         WM_USER+114 //Updates a text element in a task dialog.
#define TDM_UPDATE_ICON                 WM_USER+116 //Refreshes the icon of a task dialog.

//
// Success codes
//
#define NOERROR                         0
#define E_OUTOFMEMORY                   0x8007000E
#define E_INVALIDARG                    0x80070057
#define E_FAIL                          0x80004005
#define E_NOTIMPL                       0x80004001
