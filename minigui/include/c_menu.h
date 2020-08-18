/**
 * This file is part of the MiniGUI.
 * 
 */
#ifndef _HMG_MENUS_
#define _HMG_MENUS_

static INT bm_size    = 16;
static INT min_width  = 20;
static INT min_height = 20;
static INT cx_delta   = 4;
static INT cy_delta   = 4;

static BOOL gradientVertical = TRUE;

typedef enum
{
   Full,
   Short
} MENUCURSORTYPE;

typedef enum
{
   Single,
   Double
} SEPARATORTYPE;

typedef enum
{
   Left,
   Middle,
   Right
} SEPARATORPOSITION;

static MENUCURSORTYPE eMenuCursorType       = Full;

static SEPARATORTYPE     eSeparatorType     = Double;
static SEPARATORPOSITION eSeparatorPosition = Left;
static BOOL bSelectedItemBorder3d           = TRUE;

static COLORREF clrMenuBar1                 = RGB( 236, 233, 216 );
static COLORREF clrMenuBar2                 = RGB( 236, 233, 216 );

static COLORREF clrMenuBarText              = RGB( 0, 0, 0 );
static COLORREF clrMenuBarSelectedText      = RGB( 0, 0, 0 );
static COLORREF clrMenuBarGrayedText        = RGB( 192, 192, 192 );

static COLORREF clrSelectedMenuBarItem1     = RGB( 255, 252, 248 );
static COLORREF clrSelectedMenuBarItem2     = RGB( 136, 133, 116 );

static COLORREF clrText1                    = RGB( 0, 0, 0 );
static COLORREF clrSelectedText1            = RGB( 0, 0, 0 );
static COLORREF clrGrayedText1              = RGB( 192, 192, 192 );

static COLORREF clrBk1                      = RGB( 255, 255, 255 );
static COLORREF clrBk2                      = RGB( 255, 255, 255 );

static COLORREF clrSelectedBk1              = RGB( 182, 189, 210 );
static COLORREF clrSelectedBk2              = RGB( 182, 189, 210 );

static COLORREF clrGrayedBk1                = RGB( 255, 255, 255 );
static COLORREF clrGrayedBk2                = RGB( 255, 255, 255 );

static COLORREF clrImageBk1                 = RGB( 246, 245, 244 );
static COLORREF clrImageBk2                 = RGB( 207, 210, 200 );

static COLORREF clrSeparator1               = RGB( 168, 169, 163 );
static COLORREF clrSeparator2               = RGB( 255, 255, 255 );

static COLORREF clrSelectedItemBorder1      = RGB( 10, 36, 106 );
static COLORREF clrSelectedItemBorder2      = RGB( 10, 36, 106 );
static COLORREF clrSelectedItemBorder3      = RGB( 10, 36, 106 );
static COLORREF clrSelectedItemBorder4      = RGB( 10, 36, 106 );

static COLORREF clrCheckMark                = RGB( 0, 0, 0 );
static COLORREF clrCheckMarkBk              = RGB( 216, 220, 224 );
static COLORREF clrCheckMarkSq              = RGB( 64, 116, 200 );
static COLORREF clrCheckMarkGr              = RGB( 128, 128, 128 );

static BOOL s_bCustomDraw                   = FALSE;

typedef struct _MENUITEM
{
   UINT    cbSize;
   UINT    uiID;
   LPSTR   caption;
   UINT    cch;
   HBITMAP hBitmap;
   HFONT   hFont;
   UINT    uiItemType;
   HWND    hwnd;
   void *  lpReserved;
} MENUITEM, NEAR * PMENUITEM, * LPMENUITEM;

#ifdef __cplusplus
extern "C" {
#endif

VOID           DrawCheck( HDC hdc, SIZE size, RECT rect, BOOL enabled, BOOL selected, HBITMAP hbitmap );
VOID           DrawGlyph( HDC hDC, int x, int y, int dx, int dy, HBITMAP hBmp, COLORREF rgbTransparent, BOOL disabled, BOOL stretched );
VOID           DrawSeparator( HDC hDC, RECT r );
VOID           DrawBitmapBK( HDC hDC, RECT r );
VOID           DrawItemBk( HDC hDC, RECT r, BOOL fSelected, BOOL fGrayed, UINT itemType, BOOL clear );
VOID           DrawSelectedItemBorder( HDC hDC, RECT r /*, BOOL fSelected, BOOL fGrayed*/, UINT itemType, BOOL clear );

#ifndef __WINNT__
VOID           SetMenuBarColor( HMENU hMenu, COLORREF clrBk, BOOL fSubMenu );
#endif
static BOOL    IsColorEqual( COLORREF clr1, COLORREF clr2 );
static BOOL    _DestroyMenu( HMENU menu );

extern BOOL    EnabledGradient( void );
extern BOOL    FillGradient( HDC hDC, RECT * rect, BOOL vertical, COLORREF crFrom, COLORREF crTo );
extern HBRUSH  LinearGradientBrush( HDC pDC, long cx, long cy, COLORREF cFrom, COLORREF cTo, BOOL bVert );

WINUSERAPI BOOL WINAPI EndMenu( VOID );

#ifdef __cplusplus
}
#endif
#endif
