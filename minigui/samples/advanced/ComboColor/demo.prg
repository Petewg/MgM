/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
*/

#include "minigui.ch"


#define CLR_DEFAULT		0xff000000
#define CLR_NONE                0xFFFFFFFF

#define COLOR_SCROLLBAR         0
#define COLOR_BACKGROUND        1
#define COLOR_ACTIVECAPTION     2
#define COLOR_INACTIVECAPTION   3
#define COLOR_MENU              4
#define COLOR_WINDOW            5
#define COLOR_WINDOWFRAME       6
#define COLOR_MENUTEXT          7
#define COLOR_WINDOWTEXT        8
#define COLOR_CAPTIONTEXT       9
#define COLOR_ACTIVEBORDER      10
#define COLOR_INACTIVEBORDER    11
#define COLOR_APPWORKSPACE      12
#define COLOR_HIGHLIGHT         13
#define COLOR_HIGHLIGHTTEXT     14
#define COLOR_BTNFACE           15
#define COLOR_BTNSHADOW         16
#define COLOR_GRAYTEXT          17
#define COLOR_BTNTEXT           18
#define COLOR_INACTIVECAPTIONTEXT 19
#define COLOR_BTNHIGHLIGHT      20
#define COLOR_3DDKSHADOW        21
#define COLOR_3DLIGHT           22
#define COLOR_INFOTEXT          23
#define COLOR_INFOBK            24


*------------------------------------------------
Function Main()
*------------------------------------------------
LOCAL n, aColorName := {}, aSysColorName := {}
LOCAL aColor := ;
                {{YELLOW,    "YELLOW"},;
                 {PINK,      "PINK"},;
                 {RED,       "RED"},;
                 {FUCHSIA,   "FUCHSIA"},;
                 {BROWN,     "BROWN"},;
                 {ORANGE,    "ORANGE"},;
                 {GREEN,     "GREEN"},;
                 {PURPLE,    "PURPLE"},;
                 {BLACK,     "BLACK"},;
                 {WHITE,     "WHITE"},;
                 {GRAY,      "GRAY"},;
                 {BLUE,      "BLUE"},;
                 {SILVER,    "SILVER"},;
                 {MAROON,    "MAROON"},;
                 {OLIVE,     "OLIVE"},;
                 {LGREEN,    "LGREEN"},;
                 {AQUA,      "AQUA"},;
                 {NAVY,      "NAVY"},;
                 {TEAL,      "TEAL"}}

LOCAL aSysColor := ;
 {{COLOR_3DDKSHADOW,         "Dark shadow for 3D display elements"},;
  {COLOR_BTNFACE,            "Face color for 3D display elements"},;
  {COLOR_BTNHIGHLIGHT,       "Highlight color for 3D display elements"},;
  {COLOR_3DLIGHT,            "Light color for 3D display elements"},;
  {COLOR_BTNSHADOW,          "Shadow color for 3D display elements"},;
  {COLOR_ACTIVEBORDER,       "Active window border"},;
  {COLOR_ACTIVECAPTION,      "Active window caption"},;
  {COLOR_APPWORKSPACE,       "Background color of MDI applications"},;
  {COLOR_BACKGROUND,         "Desktop"},;
  {COLOR_BTNTEXT,            "Text on push buttons"},;
  {COLOR_CAPTIONTEXT,        "Text in caption, size, and scroll arrow box"},;
  {COLOR_GRAYTEXT,           "Grayed (disabled) text"},;
  {COLOR_HIGHLIGHT,          "Item(s) selected in a control"},;
  {COLOR_HIGHLIGHTTEXT,      "Text of item(s) selected in a control"},;
  {COLOR_INACTIVEBORDER,     "Inactive window border"},;
  {COLOR_INACTIVECAPTION,    "Inactive window caption"},;
  {COLOR_INACTIVECAPTIONTEXT,"Color of text in an inactive caption"},;
  {COLOR_INFOBK,             "Background color for tooltip controls"},;
  {COLOR_INFOTEXT,           "Text color for tooltip controls"},;
  {COLOR_MENU,               "Menu background"},;
  {COLOR_MENUTEXT,           "Text in menus"},;
  {COLOR_SCROLLBAR,          "Scroll bar gray area"},;
  {COLOR_WINDOW,             "Window background"},;
  {COLOR_WINDOWFRAME,        "Window frame"},;
  {COLOR_WINDOWTEXT,         "Text in windows"}}

LOCAL BmpW := 16
LOCAL BmpH := 16

   AEval(aColor, {|x| AAdd(aColorName, x[2]) })
   AEval(aSysColor, {|x| AAdd(aSysColorName, x[2]) })

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 500 HEIGHT 300 ;
      TITLE 'Harbour MiniGUI Combo Color Demo - by Janusz Pora' ;
      MAIN NOMAXIMIZE NOSIZE

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM 'Get HMG Color'	ACTION GetHMGColor(aColor)
            ITEM 'Get System Color'	ACTION GetSystemColor(aSysColor)
            SEPARATOR
            ITEM '&Exit'		ACTION Form_1.Release
         END POPUP
         POPUP '&Help'
            ITEM '&About'		ACTION MsgInfo ("MiniGUI Combo Color Demo")
         END POPUP

      END MENU


      DEFINE IMAGELIST Imagelst_1 ;
         BUTTONSIZE BmpW, BmpH ;
         IMAGE {}

      FOR n:=1 TO Len(aColor)
         HMG_SetColorBtm(aColor[n,1], 0, BmpW, BmpH)
         HMG_SetColorBtm(aColor[n,1], 1, BmpW, BmpH)
         HMG_SetColorBtm(aColor[n,1], 0, BmpW, BmpH)
      NEXT


      DEFINE IMAGELIST Imagelst_2 ;
         BUTTONSIZE BmpW, BmpH ;
         IMAGE {}

      FOR n:=1 TO Len(aSysColor)
         HMG_SetSysColorBtm(aSysColor[n,1], 0, BmpW, BmpH)
         HMG_SetSysColorBtm(aSysColor[n,1], 1, BmpW, BmpH)
         HMG_SetSysColorBtm(aSysColor[n,1], 0, BmpW, BmpH)
      NEXT


      @ 10,20 Label Label_1 Value "HMG Colors ComboColor" AUTOSIZE

      @ 33,20 COMBOBOXEX ComboEx_1 ;
         WIDTH 150 HEIGHT 200;
         ITEMS aColorName ;
         VALUE 1 ;
         ON ENTER GetHMGColor(aColor) ;
         FONT 'MS Sans Serif' SIZE 9 ;
         IMAGELIST "Imagelst_1"   ;
         TOOLTIP "Extend Combo HMG color"

      @ 10,190 Label Label_2 Value "System Colors ComboColor" AUTOSIZE

      @ 33,190 COMBOBOXEX ComboEx_2 ;
         WIDTH 250  HEIGHT 200;
         ITEMS aSysColorName ;
         VALUE 1 ;
         ON ENTER GetSystemColor(aSysColor) ;
         FONT 'MS Sans serif' SIZE 9 ;
         IMAGELIST "Imagelst_2"   ;
         TOOLTIP "Extend Combo System Color"


   END WINDOW

   Form_1.Center
   Form_1.Activate

Return Nil


*--------------------------------------
Function HMG_SetColorBtm(aColor, bChecked, BmpWidh, BmpHeight)
*--------------------------------------
LOCAL hImage, hImageLst, nColor
   hImageLst := This.imagelst_1.Handle
   nColor := RGB( aColor [ 1 ], aColor [ 2 ], aColor [ 3 ] )
   hImage := CreateColorBMP( ThisWindow.Handle, BmpWidh, BmpHeight, nColor, bChecked )
   IL_AddMaskedIndirect( hImageLst , hImage , , BmpWidh , BmpHeight , 1 )
RETURN Nil


*--------------------------------------
Function HMG_SetSysColorBtm(Color, bChecked, BmpWidh, BmpHeight)
*--------------------------------------
LOCAL hImage, hImageLst, nColor
   hImageLst := This.imagelst_2.Handle
   nColor := GetSysColor( Color )
   hImage := CreateColorBMP( ThisWindow.Handle, BmpWidh, BmpHeight, nColor, bChecked )
   IL_AddMaskedIndirect( hImageLst , hImage , , BmpWidh , BmpHeight , 1 )
RETURN Nil


*--------------------------------------
FUNCTION GetHMGColor(aColor)
*--------------------------------------
   LOCAL nPos, cStr, aColorHMG
   nPos := Form_1.ComboEx_1.Value
   aColorHMG := aColor[nPos,1]
   IF nPos > 0
      cStr := aColor[nPos,2]+ '  { '+ AllTrim( Str(aColorHMG[1]))+','+ AllTrim( Str(aColorHMG[2])) +','+ AllTrim( Str(aColorHMG[3])) +' }'
      MsgInfo(cStr, 'Selected color')
   endif
RETURN NIL


*--------------------------------------
FUNCTION GetSystemColor(aColor)
*--------------------------------------
   LOCAL nPos, cStr,nColorSys
   nPos := Form_1.ComboEx_2.Value
   nColorSys := GetSysColor ( aColor[nPos,1] )
   IF nPos > 0
      cStr := aColor[nPos,2]+ '  { '+ AllTrim( Str(GetRed(nColorSys)))+','+ AllTrim( Str(GetGreen(nColorSys))) +','+ AllTrim( Str(GetBlue(nColorSys))) +' }'
      MsgInfo(cStr, 'Selected color')
   endif
RETURN NIL


#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>


static void GoToPoint( HDC hDC, int ix, int iy )
{
   POINT pt;
   MoveToEx( hDC, ix, iy, &pt );
}


HB_FUNC ( CREATECOLORBMP )   //CreateColorBmp(hwnd,BmpWidh,BmpHeight,nColor,bChecked)
{
   HBRUSH hOldBrush;
   HBRUSH hColorBrush;
   HBRUSH hBlackBrush = CreateSolidBrush( RGB( 0, 0, 0 ) );
   HBRUSH hWhiteBrush = CreateSolidBrush( RGB( 255, 255, 255 ) );
   HPEN   hBlackPen   = CreatePen( PS_SOLID, 1, RGB( 0, 0, 0 ) );

   RECT rect;
   HBITMAP hBmp;
   COLORREF clr   = hb_parnl( 4 );
   int bChecked   = hb_parnl( 5 );
   int width      = hb_parni( 2 );
   int height     = hb_parni( 3 );
   HWND handle    = (HWND) HB_PARNL( 1 );
   HDC imgDC      = GetDC ( handle );
   HDC tmpDC      = CreateCompatibleDC(imgDC);

   if( ( width==0 ) & ( height==0 ) )
   {
      width  = 16;
      height = 16;
   }

   SetRect(&rect,0,0,width,height);   // Size Bmp

   hBmp=CreateCompatibleBitmap(imgDC,width,height);
   SelectObject(tmpDC,hBmp);

   hOldBrush = SelectObject( tmpDC, hWhiteBrush );

   FillRect( tmpDC, &rect, hWhiteBrush );

   rect.left   += 1 ;
   rect.top    += 1 ;
   rect.right  -= 1 ;
   rect.bottom -= 1 ;
   FillRect( tmpDC, &rect, hBlackBrush );

   rect.top    += 1 ;
   rect.left   += 1 ;
   rect.right  -= 1 ;
   rect.bottom -= 1 ;

   hColorBrush = CreateSolidBrush( clr );

   SelectObject( tmpDC, hColorBrush );

   FillRect( tmpDC, &rect, hColorBrush );

   rect.top    += 1 ;
   rect.right  -= 4 ;
   rect.bottom -= 1 ;

   if( bChecked == 1 )
   {
      GoToPoint( tmpDC, rect.right, rect.top );

      SelectObject( tmpDC, hBlackPen );

      LineTo( tmpDC, rect.right - 4 , rect.bottom - 3 );
      LineTo( tmpDC, rect.right - 7, rect.bottom - 6 );

      GoToPoint( tmpDC, rect.right, rect.top + 1);
      LineTo( tmpDC, rect.right - 4 , rect.bottom - 2 );
      LineTo( tmpDC, rect.right - 7, rect.bottom - 5 );

      GoToPoint( tmpDC, rect.right, rect.top + 2);
      LineTo( tmpDC, rect.right - 4 , rect.bottom - 1 );
      LineTo( tmpDC, rect.right - 7, rect.bottom - 4 );
   }

   SelectObject( tmpDC, hOldBrush );
   DeleteObject( hBlackBrush );
   DeleteObject( hWhiteBrush );
   DeleteObject( hColorBrush );
   DeleteObject( hBlackPen );


   DeleteDC( imgDC );
   DeleteDC( tmpDC );

   HB_RETNL( ( LONG_PTR ) hBmp );
}

HB_FUNC( IL_ADDMASKEDINDIRECT )   //IL_AddMaskedIndirect( hwnd , himage , color , ix , iy , imagecount )
{
   BITMAP   bm;
   HBITMAP  himage = ( HBITMAP ) HB_PARNL( 2 );
   COLORREF clrBk   = CLR_NONE;
   LRESULT  lResult = -1;
   int      ic      = 1;

   if( hb_parnl( 3 ) )
      clrBk = ( COLORREF ) hb_parnl( 3 );

   if( hb_parni( 6 ) )
      ic = hb_parni( 6 );

   if( GetObject( himage, sizeof( BITMAP ), &bm ) != 0 )
   {
      if( ( hb_parni( 4 ) * ic == bm.bmWidth ) & ( hb_parni( 5 ) == bm.bmHeight ) )
         lResult = ImageList_AddMasked( ( HIMAGELIST ) HB_PARNL( 1 ), himage, clrBk );

      DeleteObject( himage );
   }

   hb_retni( lResult );
}

#pragma ENDDUMP
