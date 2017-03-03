#include <minigui.ch>

memvar backcolor
memvar akalai
memvar x
memvar y

function main
local showinterval := 2000
private backcolor := {0,0,0}
private akalai := {}
private x := 250 // xcenter
private y := 250 // ycenter

define window k at 0,0 width 650 height 530 title "Kaleidoscope - 3D v.1.1 by S. Rathinagiri" main icon "kalai" nomaximize nosize on init drawkalai()
   define timer timer1 interval showinterval action (drawkalai(),iif(iswindowactive(s),drawstereowindow(),))

   define label iterationslabel
      row 10
      col 510
      value "Iterations"
      width 80
   end label
   define spinner iterations
      row 10
      col 590
      width 50
      rangemin 1
      rangemax 999
      value 3
   end spinner
   define frame shapes
      row 40
      col 505
      width 135
      height 200
      caption "Shapes"
   end frame
   define checkbox triangles
      row 60
      col 510
      width 120
      caption "Triangles"
   end checkbox
   define checkbox circles
      row 90
      col 510
      width 120
      caption "Circles"
   end checkbox
   define checkbox rectangles
      row 120
      col 510
      width 120
      caption "Rectangles"
   end checkbox
   define checkbox ellipses
      row 150
      col 510
      width 120
      caption "Ellipses"
   end checkbox
   define checkbox squares
      row 180
      col 510
      width 120
      caption "Squares"
   end checkbox
   define checkbox polygons
      row 210
      col 510
      width 120
      caption "Polygons"
      value .t.
   end checkbox
   define button backcolor
      row 250
      col 510
      width 130
      caption "Background Colour"
      action  setbackcolor()
   end button
   define checkbox show1
      row 280
      col 510
      caption "Slideshow ("+alltrim(str(showinterval/1000,5,0))+" Sec)"
      width 130
      onchange show1changed()
   end checkbox
   define button but1
      row 310
      col 510
      width 60
      caption "Show"
      action drawkalai()
   end button
   define button save
      row 310
      col 580
      width 60
      caption "Save"
      action savewindow1()
   end button
   define button showstereo
      row 340
      col 510
      width 130
      caption "Show Stereo"
      action showstereowindow()
   end button
   define hyperlink email1
      row 400
      col 510
      value "Algorithm of Cliff"
      width 130
      handcursor .t.
      address "http://sprott.physics.wisc.edu/pickover/ekscop.html"
   end hyperlink
   define hyperlink email
      row 430
      col 510
      value "E-Mail me"
      width 130
      handcursor .t.
      address "srgiri@dataone.in"
   end hyperlink
   on key escape action thiswindow.release()
end window
k.show1.value := .t.
k.center
activate window k

return nil

function drawkalai
local aPoints
local apoints1
local x1,x2,y1,y2,t
local i,j := 0,r,g,b,r1
local sides

asize(akalai,0)
erase window k
if k.iterations.value < 1
   return nil
endif

drawrect("k",0,0,x*2,y*2,backcolor,,backcolor)

FOR i = 1 to k.iterations.value

   if k.triangles.value
      sides := 3
      aPoints := {}
      for j := 1 to sides
         x1 := random(x)
         y1 := random(y)
         if ( x1 > y1 ) 
            t := x1
            x1 := y1
            y1 := t
         endif
         aadd(apoints,{x1,y1})
      next j
      r := random(255)
      g := random(255)
      b := random(255)
      for j := 1 to 8
         apoints1 := flip(aclone(apoints),x,y,j)
         drawpolygon("k",aPoints1,{r,g,b},,{r,g,b})
         aadd(akalai,{aclone(apoints1),{r,g,b},"TRIANGLE"})
      next j
   endif
   
   if k.circles.value
      x1 = random(x)
      y1 = random(y)
      r1 := random(min(x-x1,y-y1))
      if ( x1 > y1 ) 
         t := x1
         x1 := y1
         y1 := t
      endif
      x2 := x1 + r1
      y2 := y1 + r1
      r := random(255)
      g := random(255)
      b := random(255)
      aPoints := {{x1,y1},{x2,y2}}
      for j := 1 to 8
         apoints1 := flip(aclone(apoints),x,y,j)
         drawellipse("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
         aadd(akalai,{aclone(apoints1),{r,g,b},"CIRCLE"})
      next j   
   endif      
   
   if k.ellipses.value
      sides := 2
      aPoints := {}
      for j := 1 to sides
         x1 := random(x)
         y1 := random(y)
         if ( x1 > y1 ) 
            t := x1
            x1 := y1
            y1 := t
         endif
         aadd(apoints,{x1,y1})
      next j
      r := random(255)
      g := random(255)
      b := random(255)
      for j := 1 to 8
         apoints1 := flip(aclone(apoints),x,y,j)
         drawellipse("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
         aadd(akalai,{aclone(apoints1),{r,g,b},"ELLIPSE"})
      next j
   endif
   
   if k.rectangles.value
      sides := 2
      aPoints := {}
      for j := 1 to sides
         x1 := random(x)
         y1 := random(y)
         if ( x1 > y1 ) 
            t := x1
            x1 := y1
            y1 := t
         endif
         aadd(apoints,{x1,y1})
      next j
      r := random(255)
      g := random(255)
      b := random(255)
      
      for j := 1 to 8
         apoints1 := flip(aclone(apoints),x,y,j)
         drawrect("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
         aadd(akalai,{aclone(apoints1),{r,g,b},"RECTANGLE"})
      next j   
   endif
   
   if k.squares.value
      x1 = random(x)
      y1 = random(y)
      r1 := random(min(x-x1,y-y1))
      if ( x1 > y1 ) 
         t := x1
         x1 := y1
         y1 := t
      endif
      x2 := x1 + r1
      y2 := y1 + r1
      r := random(255)
      g := random(255)
      b := random(255)
      aPoints := {{x1,y1},{x2,y2}}
      for j := 1 to 8
         apoints1 := flip(aclone(apoints),x,y,j)
         drawrect("k",apoints1[1,1],apoints1[1,2],apoints1[2,1],apoints1[2,2],{r,g,b},,{r,g,b})
         aadd(akalai,{aclone(apoints1),{r,g,b},"SQUARE"})
      next j          
   endif
   
   if k.polygons.value .or. empty(j)
      if empty(j)
         k.polygons.value := .t.
      endif
      sides := 4+random(20)
      aPoints := {}
      for j := 1 to sides
         x1 := random(x)
         y1 := random(y)
         if ( x1 > y1 ) 
            t := x1
            x1 := y1
            y1 := t
         endif
         aadd(apoints,{x1,y1})
      next j
      r := random(255)
      g := random(255)
      b := random(255)
      for j := 1 to 8
         apoints1 := flip(aclone(apoints),x,y,j)
         drawpolygon("k",aPoints1,{r,g,b},,{r,g,b})
         aadd(akalai,{aclone(apoints1),{r,g,b},"POLYGON"})
      next j
   endif
next i

return nil

function savewindow1
local filename

if k.show1.value
   k.timer1.enabled := .f.
endif

filename := PutFile ( {{"Bitmap Files (*.bmp)","*.bmp"}} , "Save to bitmap file" ,  , .f. ) 
if !empty(filename)
   if at(".bmp",lower(filename)) > 0
      if .not. right(lower(filename),4) == ".bmp"
         filename := filename + ".bmp"
      endif
   else
      filename := filename + ".bmp"
   endif

   if file(filename)
      if msgyesno("Are you sure to overwrite?","Save to bitmap")
         savewindow("k",filename,0,0,500,500)
      endif
   else
      savewindow("k",filename,0,0,500,500)
   endif
endif

if k.show1.value
   k.timer1.enabled := .t.
endif

return nil

function setbackcolor
backcolor := getcolor(backcolor)
return nil

function show1changed
if .not. iscontroldefined(timer1,k)
   return nil
endif
if k.show1.value
   k.timer1.enabled := .t.
else   
   k.timer1.enabled := .f.
endif
return nil

function showstereowindow

if .not. iswindowdefined(s)
   define window s at 0,0 width 1100 height 580 title "Stereo Window" modal nosize backcolor {0,0,0} on init drawstereowindow()
   define button save1
      row 520
      col 10
      width 50
      caption "Save"
      action savestereowindow1()
   end button
   define button close1
      row 520
      col 70
      width 50
      caption "Close"
      action s.release()
   end button

   on key escape action thiswindow.release()
   end window
   s.center
   s.activate
else
   drawstereowindow()   
endif   

return nil

function drawstereowindow
local stereobase := 30
local sdiff, i
local alpoints1
local arpoints1

if len(akalai) == 0
   return nil
endif
sdiff := stereobase /len(akalai) * 8

erase window s
drawrect("s",0,0,500,1030,backcolor,,backcolor)

for i := 1 to len(akalai)
   
   alpoints1 := converttolpoints(aclone(akalai[i,1]),stereobase,sdiff*int((i-1)/8))
   arpoints1 := converttorpoints(aclone(akalai[i,1]),stereobase)
   
   do case 
      case akalai[i,3] == "TRIANGLE" .or. akalai[i,3] == "POLYGON"
         drawpolygon("s",alPoints1,akalai[i,2],,akalai[i,2])
         drawpolygon("s",arPoints1,akalai[i,2],,akalai[i,2])
      case akalai[i,3] == "CIRCLE" .or. akalai[i,3] == "ELLIPSE"
         drawellipse("s",alpoints1[1,1],alpoints1[1,2],alpoints1[2,1],alpoints1[2,2],akalai[i,2],,akalai[i,2])
         drawellipse("s",arpoints1[1,1],arpoints1[1,2],arpoints1[2,1],arpoints1[2,2],akalai[i,2],,akalai[i,2])
      case akalai[i,3] == "RECTANGLE" .or. akalai[i,3] == "SQUARE"
         drawrect("s",alpoints1[1,1],alpoints1[1,2],alpoints1[2,1],alpoints1[2,2],akalai[i,2],,akalai[i,2])
         drawrect("s",arpoints1[1,1],arpoints1[1,2],arpoints1[2,1],arpoints1[2,2],akalai[i,2],,akalai[i,2])
   endcase   
         
next i

return nil

function converttolpoints(apoints,stereobase,sdiff)
local alpoints := aclone(apoints)
local i

for i := 1 to len(alpoints)
   alpoints[i,2] := alpoints[i,2] + stereobase - sdiff
next i
return alpoints

function converttorpoints(apoints,stereobase)
local arpoints := aclone(apoints)
local i

for i := 1 to len(arpoints)
   arpoints[i,2] := arpoints[i,2] + (2*y) + stereobase
next i
return arpoints

function savestereowindow1
local filename

if k.show1.value
   k.timer1.enabled := .f.
endif

filename := PutFile ( {{"Bitmap Files (*.bmp)","*.bmp"}} , "Save to bitmap file" ,  , .f. ) 
if !empty(filename)
   if at(".bmp",lower(filename)) > 0
      if .not. right(lower(filename),4) == ".bmp"
         filename := filename + ".bmp"
      endif
   else
      filename := filename + ".bmp"
   endif

   if file(filename)
      if msgyesno("Are you sure to overwrite?","Save to bitmap")
         savewindow("s",filename,0,0,1030,500)
      endif
   else
      savewindow("s",filename,0,0,1030,500)
   endif
endif

if k.show1.value
   k.timer1.enabled := .t.
endif

return nil

function flip(apoints,nx,ny,i)
local aout := {}
local j
local x1 := 0
local y1 := 0
local xj
local yj
for j := 1 to len(apoints)
   xj := apoints[j,1]
   yj := apoints[j,2]
   do case
      case i == 1
         x1 := nx + xj
         y1 := ny + yj
      case i == 2
         x1 := nx + xj
         y1 := ny - yj
      case i == 3
         x1 := nx - xj
         y1 := ny + yj
      case i == 4
         x1 := nx - xj
         y1 := ny - yj
      case i == 5
         x1 := ny + yj
         y1 := nx + xj
      case i == 6
         x1 := ny + yj
         y1 := nx - xj
      case i == 7
         x1 := ny - yj
         y1 := nx + xj
      case i == 8
         x1 := ny - yj
         y1 := nx - xj
   endcase
   aadd(aout,{x1,y1})
next j
return aclone(aout)

*------------------------------------------------------------------------------*
FUNCTION SAVEWINDOW ( cWindowName , cFileName , nRow , nCol , nWidth , nHeight )
*------------------------------------------------------------------------------*
Local ntop , nleft , nbottom , nright

	if valtype ( cFileName ) = 'U'
		cFileName := GetStartupFolder() + "\" + cWindowName + '.bmp'
	endif

	if	valtype ( nRow ) = 'U' ;
		.or. ;
		valtype ( nCol ) = 'U' ;
		.or. ;
		valtype ( nWidth ) = 'U' ;
		.or. ;
		valtype ( nHeight ) = 'U' 

		ntop	:= -1
		nleft	:= -1
		nbottom	:= -1
		nright	:= -1

	else

		ntop	:= nRow
		nleft	:= nCol
		nbottom	:= nHeight + nRow
		nright	:= nWidth + nCol

	endif

	SAVEWINDOWBYHANDLE ( GetFormHandle ( cWindowName ) , cFileName , ntop , nleft , nbottom , nright )

RETURN NIL


#pragma BEGINDUMP

#define HB_OS_WIN_USED
#define _WIN32_WINNT  0x0400

#include <shlobj.h>
#include <windows.h>
#include <winuser.h>
#include <wingdi.h>
#include "hbapi.h"
#include "hbapiitm.h"
/*
HANDLE ChangeBmpFormat(HBITMAP , HPALETTE );
WORD GetDIBColors(LPSTR lpDIB) ;
*/
HB_FUNC( SAVEWINDOWBYHANDLE ) 
{

	HWND				hWnd	= ( HWND ) hb_parnl( 1 );
	HDC				hDC	= GetDC( hWnd );
	HDC				hMemDC ;
	RECT				rc ;
	HBITMAP				hBitmap ;
	HBITMAP				hOldBmp ;
	HPALETTE			hPal;
	const char * 			File	= hb_parc(2) ;
	HANDLE				hDIB ;
	int				top	= hb_parni(3) ;
	int				left	= hb_parni(4) ;
	int				bottom	= hb_parni(5) ;
	int				right	= hb_parni(6) ;
	BITMAPFILEHEADER		bmfHdr ;     
	LPBITMAPINFOHEADER		lpBI ;       
	HANDLE				filehandle ;         
	DWORD				dwDIBSize ;
	DWORD				dwWritten ;
	DWORD				dwBmBitsSize ;

	if ( top != -1 && left != -1 && bottom != -1 && right != -1 )
	{
		rc.top = top ;
		rc.left = left ;
		rc.bottom = bottom ;
		rc.right = right ;
	}
	else
	{
		GetClientRect( hWnd, &rc );
	}

	hMemDC  = CreateCompatibleDC( hDC );
	hBitmap = CreateCompatibleBitmap( hDC, rc.right-rc.left, rc.bottom-rc.top );
	hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBitmap );
	BitBlt( hMemDC, 0, 0 , rc.right-rc.left, rc.bottom-rc.top, hDC, rc.top, rc.left, SRCCOPY );
	SelectObject( hMemDC, hOldBmp );
	hDIB = ChangeBmpFormat(hBitmap ,hPal);

	filehandle = CreateFile( File , GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL);

	lpBI = (LPBITMAPINFOHEADER)GlobalLock(hDIB);
	if (!lpBI)
	{
		CloseHandle(filehandle);
		return;
	}

	if (lpBI->biSize != sizeof(BITMAPINFOHEADER))
	{
		GlobalUnlock(hDIB);
		CloseHandle(filehandle);
		return;
	}

	bmfHdr.bfType = ((WORD) ('M' << 8) | 'B'); 

	dwDIBSize = *(LPDWORD)lpBI + ( GetDIBColors( (LPSTR) lpBI ) * sizeof(RGBTRIPLE)) ;

	dwBmBitsSize = ((((lpBI->biWidth)*((DWORD)lpBI->biBitCount))+ 31) / 32 * 4) *  lpBI->biHeight;
	dwDIBSize += dwBmBitsSize;
	lpBI->biSizeImage = dwBmBitsSize;
                   
	bmfHdr.bfSize = dwDIBSize + sizeof(BITMAPFILEHEADER);
	bmfHdr.bfReserved1 = 0;
	bmfHdr.bfReserved2 = 0;

	bmfHdr.bfOffBits = (DWORD)sizeof(BITMAPFILEHEADER) + lpBI->biSize + ( GetDIBColors( (LPSTR) lpBI ) * sizeof(RGBTRIPLE)) ;

	WriteFile(filehandle, (LPSTR)&bmfHdr, sizeof(BITMAPFILEHEADER), &dwWritten, NULL);
   
	WriteFile(filehandle, (LPSTR)lpBI, dwDIBSize, &dwWritten, NULL);

	GlobalUnlock(hDIB);
	CloseHandle(filehandle);

	DeleteDC( hMemDC );
	GlobalFree (hDIB);
	ReleaseDC( hWnd, hDC );

}
/*
HANDLE ChangeBmpFormat(HBITMAP hBitmap, HPALETTE hPal) 
{

	BITMAP              bm;         
	BITMAPINFOHEADER    bi;         
	LPBITMAPINFOHEADER  lpbi;       
	DWORD               dwLen;      
	HGLOBAL             hDIB;
	HGLOBAL             h;
	HDC                 hDC;        
	WORD                biBits;     

	if (!hBitmap)
	{
		return 0 ;
	}

	if (!GetObject(hBitmap, sizeof(bm), (LPSTR)&bm))
	{
		return 0 ;
	}

	if ( hPal == 0 )
	{
		hPal = GetStockObject(DEFAULT_PALETTE);
	}

	biBits = bm.bmPlanes * bm.bmBitsPixel ;

	if (biBits <= 1)
	{
		biBits = 1;
	}
	else if (biBits <= 4)
	{
		biBits = 4;
	}
	else if (biBits <= 8)
	{
		biBits = 8;
	}
	else  
	{
	        biBits = 24;
	}

	bi.biSize = sizeof(BITMAPINFOHEADER);
	bi.biWidth = bm.bmWidth;
	bi.biHeight = bm.bmHeight;
	bi.biPlanes = 1;
	bi.biBitCount = biBits;
	bi.biCompression = BI_RGB;
	bi.biSizeImage = 0;
	bi.biXPelsPerMeter = 0;
	bi.biYPelsPerMeter = 0;
	bi.biClrUsed = 0;
	bi.biClrImportant = 0;

	dwLen = bi.biSize + ( GetDIBColors( (LPSTR)&bi ) * sizeof ( RGBTRIPLE ) ) ;

	hDC = GetDC(NULL);

	hPal = SelectPalette(hDC, hPal, FALSE);
	RealizePalette(hDC);

	hDIB = GlobalAlloc(GHND, dwLen);

	if (!hDIB)
	{
		SelectPalette(hDC, hPal, TRUE);
		RealizePalette(hDC);
		ReleaseDC(NULL, hDC);
		return 0;
	}

	lpbi = (LPBITMAPINFOHEADER)GlobalLock(hDIB);

	*lpbi = bi;

	GetDIBits(hDC, hBitmap, 0, (UINT)bi.biHeight, NULL, (LPBITMAPINFO)lpbi,DIB_RGB_COLORS);

	bi = *lpbi;
	GlobalUnlock(hDIB);

	if (bi.biSizeImage == 0)
	{
		bi.biSizeImage = ((((DWORD)bm.bmWidth * biBits)+ 31) / 32 * 4) * bm.bmHeight;
	}

	dwLen = bi.biSize + ( GetDIBColors( (LPSTR)&bi ) * sizeof(RGBTRIPLE)) + bi.biSizeImage;

	h = GlobalReAlloc( hDIB, (SIZE_T) dwLen, 0);
	if ( h )
	{
		hDIB = h;
	}
	else
	{
		GlobalFree(hDIB);
		hDIB = NULL;
		SelectPalette(hDC, hPal, TRUE);
		RealizePalette(hDC);
		ReleaseDC(NULL, hDC);
		return hDIB;
	}

	lpbi = (LPBITMAPINFOHEADER)GlobalLock(hDIB);

	if (GetDIBits(hDC, hBitmap, 0, (UINT)bi.biHeight, (LPSTR)lpbi + (WORD)lpbi->biSize + ( GetDIBColors ((LPSTR)lpbi) * sizeof(RGBTRIPLE)) , (LPBITMAPINFO)lpbi, DIB_RGB_COLORS) == 0)
	{
		GlobalFree(hDIB);
		hDIB = NULL;
		SelectPalette(hDC, hPal, TRUE);
		RealizePalette(hDC);
		ReleaseDC(NULL, hDC);
		return hDIB;
	}

	bi = *lpbi;

	GlobalUnlock(hDIB);
	SelectPalette(hDC, hPal, TRUE);
	RealizePalette(hDC);
	ReleaseDC(NULL, hDC);

	return hDIB;

}
*/
/*
WORD GetDIBColors(LPSTR lpDIB)
{
    WORD wBitCount = ((LPBITMAPCOREHEADER)lpDIB)->bcBitCount; ;
    return wBitCount;
}
*/
#pragma ENDDUMP