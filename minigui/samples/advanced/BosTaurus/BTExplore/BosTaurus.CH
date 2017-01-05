
/*----------------------------------------------------------------------------
 BOS TAURUS - Graphic Library for HMG

 Copyright 2012-2013 by Dr. Claudio Soto (from Uruguay). 
 mail: <srvet@adinet.com.uy>
 blog: http://srvet.blogspot.com

 This program is free software; you can redistribute it and/or modify it under 
 the terms of the GNU General Public License as published by the Free Software 
 Foundation; either version 2 of the License, or (at your option) any later 
 version. 

 This program is distributed in the hope that it will be useful, but WITHOUT 
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301, USA
 (or visit their web site at http://www.gnu.org/).
 
 As a special exception, you have permission for additional uses of the text 
 contained in this release of BOS TAURUS.

 The exception is that, if you link the BOS TAURUS library with other 
 files to produce an executable, this does not by itself cause the resulting 
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the 
 BOS TAURUS library code into it.
----------------------------------------------------------------------------*/


******************************************************************************
* ARCHIVO:  BosTaurus.CH
* LENGUAJE: HMG 
* FECHA:    Setiembre 2012
* AUTOR:    Dr. CLAUDIO SOTO
* PAIS:     URUGUAY
* E-MAIL:   srvet@adinet.com.uy
* BLOG:     http://srvet.blogspot.com
******************************************************************************

#ifndef _BT_
   #define _BT_

// Bos Taurus: Minimum Requirements: Windows XP, HMG 3.0.43 or MiniGUI 2.1.5  


#define _BT_INFO_NAME_           "Bos Taurus"
#define _BT_INFO_MAJOR_VERSION_   1
#define _BT_INFO_MINOR_VERSION_   0
#define _BT_INFO_PATCHLEVEL_      4
#define _BT_INFO_AUTHOR_         "(c) Dr. Claudio Soto (from Uruguay)"


#define ArrayRGB_TO_COLORREF(aRGB)  RGB(aRGB[1],aRGB[2],aRGB[3])

#define CRLF CHR(13)+CHR(10)


// BT_DC_CREATE()
   // Type
   #define BT_HDC_DESKTOP            1
   #define BT_HDC_WINDOW             2
   #define BT_HDC_ALLCLIENTAREA      3
   #define BT_HDC_INVALIDCLIENTAREA  4
   #define BT_HDC_BITMAP             5


// BT_SCR_GETINFO()
   // Mode
   #define BT_SCR_DESKTOP    0
   #define BT_SCR_WINDOW     1
   #define BT_SCR_CLIENTAREA 2

   // Info
   #define BT_SCR_INFO_WIDTH  0
   #define BT_SCR_INFO_HEIGHT 1

   
// BT_DRAW_HDC_FILLEDOBJECT()   
   // Type
   #define BT_FILLRECTANGLE  1
   #define BT_FILLELLIPSE    2
   #define BT_FILLROUNDRECT  3  // RoundWidth , RoundHeight

   
// BT_DRAW_HDC_BITMAP(), BT_BMP_PASTE ()
   // Action
   #define BT_BITMAP_OPAQUE        0
   #define BT_BITMAP_TRANSPARENT   1

   
// BT_DRAW_HDC_BITMAP(), BT_DRAW_HDC_BITMAPALPHABLEND () 
   // Mode_Stretch
   #define BT_SCALE   0
   #define BT_STRETCH 1
   #define BT_COPY    3

   
// BT_DRAW_HDC_BITMAPALPHABLEND ()   
   // Alpha = 0 to 255
   #define BT_ALPHABLEND_TRANSPARENT   0
   #define BT_ALPHABLEND_OPAQUE      255

   
// BT_DRAW_HDC_GRADIENTFILL()
   #define BT_GRADIENTFILL_HORIZONTAL 0   
   #define BT_GRADIENTFILL_VERTICAL   1   

   
// BT_DRAW_HDC_TEXTOUT ()   
   // Type
   #define BT_TEXT_OPAQUE      0
   #define BT_TEXT_TRANSPARENT 1

   #define BT_TEXT_BOLD        2
   #define BT_TEXT_ITALIC      4
   #define BT_TEXT_UNDERLINE   8
   #define BT_TEXT_STRIKEOUT   16

   // Align
   #define BT_TEXT_LEFT        0
   #define BT_TEXT_CENTER      6
   #define BT_TEXT_RIGHT       2

   #define BT_TEXT_TOP         0  
   #define BT_TEXT_BASELINE   24
   #define BT_TEXT_BOTTOM      8 

   // Orientation
   #define BT_TEXT_NORMAL_ORIENTATION      0
   #define BT_TEXT_VERTICAL_ASCENDANT     90
   #define BT_TEXT_VERTICAL_DESCENDANT   -90
   #define BT_TEXT_DIAGONAL_ASCENDANT     45
   #define BT_TEXT_DIAGONAL_DESCENDANT   -45


// BT_DRAW_HDC_TO_HDC ()
   // Action
   #define BT_HDC_OPAQUE        0
   #define BT_HDC_TRANSPARENT   1


// BT_BMP_SAVEFILE() 
   // nTypePicture
   #define BT_FILEFORMAT_BMP   0
   #define BT_FILEFORMAT_JPG   1 
   #define BT_FILEFORMAT_GIF   2
   #define BT_FILEFORMAT_TIF   3
   #define BT_FILEFORMAT_PNG   4

   
// BT_BMP_CAPTURESCR()
   // Mode
   #define BT_BITMAP_CAPTURE_DESKTOP    0
   #define BT_BITMAP_CAPTURE_WINDOW     1
   #define BT_BITMAP_CAPTURE_CLIENTAREA 2 

   
// BT_BMP_GETINFO ()   
   // Info 
   #define BT_BITMAP_INFO_WIDTH         0
   #define BT_BITMAP_INFO_HEIGHT        1
   #define BT_BITMAP_INFO_BITSPIXEL     2
   #define BT_BITMAP_INFO_GETCOLORPIXEL 3

   
// BT_BMP_PROCESS ()
   // Action                                       Value
   #define BT_BMP_PROCESS_INVERT        0          // NIL
   #define BT_BMP_PROCESS_GRAYNESS      1          // Gray_Level     = 0 to 100%
   #define BT_BMP_PROCESS_BRIGHTNESS    2          // Light_Level    = -255 To +255
   #define BT_BMP_PROCESS_CONTRAST      3          // Contrast_Angle = angle in radians
   #define BT_BMP_PROCESS_MODIFYCOLOR   4          // { R = -255 To +255, G = -255 To +255, B = -255 To +255 }
   #define BT_BMP_PROCESS_GAMMACORRECT  5          // {RedGamma = 0.2 To 5.0, GreenGamma = 0.2 To 5.0, BlueGamma = 0.2 To 5.0}

   // Gray_Level = 0 To 100%
   #define BT_BITMAP_GRAY_NONE 0
   #define BT_BITMAP_GRAY_FULL 100

   // Light_Level = -255 To +255
   #define BT_BITMAP_LIGHT_BLACK -255
   #define BT_BITMAP_LIGHT_NONE  0
   #define BT_BITMAP_LIGHT_WHITE 255


// BT_BMP_TRANSFORM () 
   // Mode
   #define BT_BITMAP_REFLECT_HORIZONTAL 1 
   #define BT_BITMAP_REFLECT_VERTICAL   2
   #define BT_BITMAP_ROTATE             4   // Angle = 0 To 360º   &&  Color_Fill_Bk = color to fill the empty spaces the background

   
// BT_DRAW_HDC_PIXEL ()
   // Action
   #define BT_HDC_GETPIXEL   0
   #define BT_HDC_SETPIXEL   1


// BT_BMP_COPYANDRESIZE ()
   // Algorithm
   #define BT_RESIZE_COLORONCOLOR   0
   #define BT_RESIZE_HALFTONE       1
   #define BT_RESIZE_BILINEAR       2

#endif
