#include "hmg.ch"

Set Procedure To HMG_Zebra.prg

// Claudio Soto (July 2013)

#translate SET WINDOW <cFormName> TRANSPARENT TO <nAlphaBlend> ;
=>;   // nAlphaBlend = 0 to 255 (completely transparent = 0, opaque = 255)
   SetWindowTransparent (GetFormHandle(<"cFormName">), <nAlphaBlend>)

#translate SET WINDOW <cFormName> [ TRANSPARENT ] TO OPAQUE ;
=>;
   SetWindowTransparent (GetFormHandle(<"cFormName">), 255)


#define FLASHW_CAPTION 1
#define FLASHW_TRAY 2
#define FLASHW_ALL (FLASHW_CAPTION + FLASHW_TRAY)

#translate FLASH WINDOW <cFormName> CAPTION COUNT <nTimes> INTERVAL <nMilliseconds> ;
=>;
   FlashWindowEx (GetFormHandle(<"cFormName">), FLASHW_CAPTION, <nTimes>, <nMilliseconds>) 

#translate FLASH WINDOW <cFormName> TASKBAR COUNT <nTimes> INTERVAL <nMilliseconds> ;
=>;
   FlashWindowEx (GetFormHandle(<"cFormName">), FLASHW_TRAY, <nTimes>, <nMilliseconds>) 

#translate FLASH WINDOW <cFormName> [ ALL ] COUNT <nTimes> INTERVAL <nMilliseconds> ;
=>;
   FlashWindowEx (GetFormHandle(<"cFormName">), FLASHW_ALL, <nTimes>, <nMilliseconds>) 

MEMVAR aTypeItems
MEMVAR aValues
MEMVAR aBarColor
MEMVAR aBackColor
*--------------------------------------------------------------*
Function Main
*--------------------------------------------------------------*
   PRIVATE aTypeItems :={;
                         "EAN13","EAN8","UPCA","UPCE","CODE39","ITF","MSI","CODABAR",;
                         "CODE93","CODE11","CODE128","PDF417","DATAMATRIX","QRCODE"}

   PRIVATE aValues :={;
                         "477012345678","1234567","01234567891","123456","ABC123","12345678901","1234","1234567",;
                         "-1234","ABC-123","Code 128","Hello, World of Harbour! It's 2D barcode PDF417",;
                         "Hello, World of Harbour! It's 2D barcode DataMatrix","http://harbour-project.org/"}
   PRIVATE aBarColor := { 0, 0, 0 }
   PRIVATE aBackColor := { 255, 255, 255 }

   SET DEFAULT ICON TO 'demo.ico'

   define window barcode at 0, 0 width 300 height 310 main title 'HMG - BarCode Generator' nomaximize nosize
      define label barcodetypelabel
         row 10
         col 10
         width 100
         value 'Select a Type'
      end label
      define combobox type
         row 10
         col 110
         width 100
         items aTypeItems
         ON CHANGE barcode.code.value := aValues [ barcode.Type.value ]         
      end Combobox           

      define label codelabel
         row 40
         col 10
         width 100
         value 'Enter the Code'
      end label
      define textbox code
         row 40
         col 110
         width 120
//         maxlength 13
      end textbox
      define label widthlabel
         row 70
         col 10
         width 100
         value 'Line Width'
      end label
      define spinner linewidth
         row 70
         col 110
         width 80
         value 2
         rightalign .t.
         rangemin 1
         rangemax 200
      end spinner
      define label heightlabel
         row 100
         col 10
         width 100
         value 'Barcode Height'
      end label
      define spinner lineheight
         row 100
         col 110
         width 80
         value 110
         rightalign .t.
         increment 10
         rangemin 10
         rangemax 2000
      end spinner
      define checkbox showdigits
         row 130
         col 10
         width 120
         caption 'Display Code'
         value .t.
      end checkbox
      define checkbox checksum
         row 130
         col 150
         width 120
         caption 'Checksum'
         value .t.
      end checkbox
      define checkbox wide2_5
         row 160
         col 10
         width 120
         caption 'Wide 2.5'
         onchange iif( this.value, barcode.wide3.value := .f., )
      end checkbox
      define checkbox wide3
         row 160
         col 150
         width 120
         caption 'Wide 3'
         onchange iif( this.value, barcode.wide2_5.value := .f., )
      end checkbox
      define label barcolor
         row 190
         col 10
         width 110
         fontcolor { 0, 0, 0 }
         value 'Barcode Color' 
         fontsize 11
         tooltip 'Click to change color!'
         action changebarcolor()
         alignment center
         alignment vcenter
      end label
      define label backgroundcolor
         row 190
         col 150
         width 100
         backcolor { 255, 255, 255 }
         value 'Back Color' 
         fontsize 11
         tooltip 'Click to change color!'
         action changebackcolor()
         alignment center
         alignment vcenter
      end label

      define button ok
         row 230
         col 60
         width 90
         caption 'Show Barcode'
         action createbarcode()
      end button
      define button png
         row 230
         col 160
         width 90
         caption 'Save to PNG'
         action createbarcodepng()
      end button

   end window
   barcode.type.value := 1
   barcode.center
   barcode.activate
Return Nil


function CreateBarCode
   local hBitMap

   hBitMap := HMG_CreateBarCode( barcode.code.value,;
                   barcode.type.item( barcode.type.value ),;
                   barcode.linewidth.value,;
                   barcode.lineheight.value,;
                   barcode.showdigits.value,;
                   '',;
                   aBarColor,;
                   aBackColor,;
                   barcode.checksum.value,;  // checksum
                   barcode.wide2_5.value,;   // wide2_5
                   barcode.wide3.value )     // wide3
   if hBitMap == 0
      return nIL
   endif      

   if IsWinXPorLater()
      // SET WINDOW barcode TRANSPARENT TO 150   // nAlphaBlend = 0 to 255 (completely transparent = 0, opaque = 255)
   endif

   DEFINE WINDOW Form1;
      AT BT_DesktopHeight()/2, BT_DesktopWidth()/2 ;
      WIDTH  BT_BitmapWidth  ( hBitmap ) + 100 ;
      HEIGHT BT_BitmapHeight ( hBitmap ) + 100 ;
      TITLE 'Display Bar Code' ;
      MODAL ;
      ON RELEASE {|| BT_BitmapRelease ( hBitmap ), iif( IsWinXPorLater(), SET WINDOW barcode TRANSPARENT TO OPAQUE, ) }

      @ 10, 10 IMAGE Image1 PICTURE ""
      BT_HMGSetImage ("Form1", "Image1", hBitmap)
   END WINDOW

   FLASH WINDOW Form1 COUNT 5 INTERVAL 50

   ACTIVATE WINDOW Form1
return nil


function CreateBarCodepng
   local cImageFileName
   cImageFileName := putfile( { { "PNG Files", "*.png" } }, "Save Barcode to PNG File" )
   if len( cImageFileName ) == 0
      return nil
   endif
   if file( cImageFileName )
      if msgyesno( 'Image file already exists. Do you want to overwrite?', 'Confirmation' )
         ferase( cImageFileName )
      else
         return nil
      endif
   endif
   HMG_CreateBarCode( barcode.code.value,;
                   barcode.type.item( barcode.type.value ),;
                   barcode.linewidth.value,;
                   barcode.lineheight.value,;
                   barcode.showdigits.value,;
                   cImageFileName,;
                   aBarColor,;
                   aBackColor,;
                   barcode.checksum.value,;  // checksum
                   barcode.wide2_5.value,;   // wide2_5
                   barcode.wide3.value )     // wide3
   if file( cImageFileName )
      _Execute ( GetActiveWindow() , , cImageFileName, , , 5 )
   endif         
return nil 


function changebarcolor
   local aColor := getcolor( barcode.barcolor.fontcolor )
   if valtype( acolor[ 1 ] ) == 'N'
      barcode.barcolor.fontcolor := aColor
      aBarColor := aColor
   endif   
return nil
   

function changebackcolor
   local aColor := getcolor( barcode.backgroundcolor.backcolor )
   if valtype( acolor[ 1 ] ) == 'N'
      barcode.backgroundcolor.backcolor := aColor
      aBackColor := aColor
   endif
return nil


*--------------------------------------------------------------*
Function SetWindowTransparent (hWnd, nAlphaBlend)
*--------------------------------------------------------------*
   #define LWA_COLORKEY 0x01
   #define LWA_ALPHA    0x02
   // When nAlphaBlend is 0, the window is completely transparent. When nAlphaBlend is 255, the window is opaque.
   IF ValType (nAlphaBlend) <> "N" .OR. nAlphaBlend > 255
      nAlphaBlend := 255   // completely opaque
   ELSEIF nAlphaBlend < 0
      nAlphaBlend := 0     // completely transparent
   ENDIF
Return SetLayeredWindowAttributes (hWnd, 0, nAlphaBlend, LWA_ALPHA)

/*
#pragma BEGINDUMP

#if defined ( __MINGW32__ )
#  define _WIN32_WINNT 0x0500
#endif

#include <windows.h>
#include "hbapi.h"

//        FlashWindowEx (hWnd, dwFlags, uCount, dwTimeout)
HB_FUNC ( FLASHWINDOWEX )
{
   FLASHWINFO FlashWinInfo;

   FlashWinInfo.cbSize    = sizeof (FLASHWINFO);
   FlashWinInfo.hwnd      = (HWND)  hb_parnl (1);
   FlashWinInfo.dwFlags   = (DWORD) hb_parnl (2);
   FlashWinInfo.uCount    = (UINT)  hb_parnl (3);
   FlashWinInfo.dwTimeout = (DWORD) hb_parnl (4);

   hb_retl ((BOOL) FlashWindowEx (&FlashWinInfo));
}

//        SetLayeredWindowAttributes (hWnd, crKey, bAlpha, dwFlags)
HB_FUNC ( SETLAYEREDWINDOWATTRIBUTES )
{
#if defined ( __MINGW32__ )

   HWND     hWnd    = (HWND)     hb_parnl (1);
   COLORREF crKey   = (COLORREF) hb_parnl (2);
   BYTE     bAlpha  = (BYTE)     hb_parni (3);
   DWORD    dwFlags = (DWORD)    hb_parnl (4);

   if (!(GetWindowLong (hWnd, GWL_EXSTYLE) & WS_EX_LAYERED))
       SetWindowLong (hWnd, GWL_EXSTYLE, (GetWindowLong (hWnd, GWL_EXSTYLE) | WS_EX_LAYERED));

   hb_retl ((BOOL) SetLayeredWindowAttributes (hWnd, crKey, bAlpha, dwFlags));

#else
	typedef BOOL (__stdcall *PFN_SETLAYEREDWINDOWATTRIBUTES) (HWND, COLORREF, BYTE, DWORD);

	PFN_SETLAYEREDWINDOWATTRIBUTES pfnSetLayeredWindowAttributes = NULL;

	HINSTANCE hLib = LoadLibrary ("user32.dll");

	if (hLib != NULL)
	{
		pfnSetLayeredWindowAttributes = (PFN_SETLAYEREDWINDOWATTRIBUTES) GetProcAddress(hLib, "SetLayeredWindowAttributes");
	}

	if (pfnSetLayeredWindowAttributes)
	{
		SetWindowLong ((HWND) hb_parnl (1), GWL_EXSTYLE, GetWindowLong((HWND) hb_parnl (1), GWL_EXSTYLE) | WS_EX_LAYERED);
		pfnSetLayeredWindowAttributes ((HWND) hb_parnl (1), (COLORREF) hb_parnl (2), hb_parni (3), (DWORD) hb_parnl (4));
	}

	if (!hLib)
	{
		FreeLibrary (hLib);
	}
#endif
}

#pragma ENDDUMP
*/