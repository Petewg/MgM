
****************************************************************************************************************
* PROGRAMA:	BITMAP.PRG
* LENGUAJE:	HARBOUR-MINIGUI
* FECHA:	12 JUNIO 2010
* AUTOR:	Dr. CLAUDIO SOTO SILVA
* PAIS:		URUGUAY
* E-MAIL:	srvet@adinet.com.uy
****************************************************************************************************************

#include "minigui.ch" 


****************************************************************************************************************
* Functions that manipulate the native control IMAGE of HMG (Image Control HMG = static window)
****************************************************************************************************************
* IMAGE_GET_hWND     (cWinName, cImageName) ====> Return hWnd 
*
* IMAGE_GET_hBITMAP  (cWinName, cImageName) ====> Return hBitmap 
*
* IMAGE_SET_hBITMAP  (cWinName, cImageName, hBitmap, Width, Height) ====> Set and show hBITMAP in IMAGE Control of HMG
* 
* IMAGE_SHOW_hBITMAP (hWND, hBitmap)           ====> Show hBitmap in IMAGE Control of HMG
* 
****************************************************************************************************************


****************************************************************************************************************
* Functions that manipulate BITMAP 
****************************************************************************************************************
* BMP_GET_INFO   (hBitmap, Info) ---> Return BMP_INFO_xxx
*
* BMP_LOAD_FILE  (cFileBMP) ---> Return hBITMAP
* BMP_SAVE_FILE  (hBitmap, cFileBMP) ---> Return Success (TRUE or FALSE)
*
* BMP_CREATE     (Width, Height) ---> Return hBITMAP
* BMP_RELEASE    (hBitmap) ---> Return Success (TRUE or FALSE)
*
* BMP_RESIZE     (hBitmap, New_Width, New_Height, modo_stretch) ---> Return new_hBitmap
* BMP_TRANSFORM  (hBitmap, modo, Angle, Color_Fill) ---> Return New_hBitmap
*
* BMP_SET_PIXEL  (hBitmap, x, y, Color_RGB)
* BMP_GET_PIXEL  (hBitmap, x, y) ---> Return {R,G,B}
*
* BMP_GET_SPRITE          (hBitmap, x, y, Width, Height) ---> Return new_hBITMAP
* BMP_PUT_SPRITE          (hBitmap_D, x1, y1, hBitmap_O, x2, y2, Width2, Height2)
* BMP_ISPOINT_IN_SPRITE   (Px, Py, hBitmap, x, y, Width, Height, Color_Transp, modo)
* BMP_IS_INTERSECT_SPRITE (hBitmap1, x1, y1, Width1, Height1, Color_Transp1, hBitmap2, x2, y2, Width2, Height2, Color_Transp2, modo)
*
* BMP_CLIPBOARD_EMPTY ()      ---> Return TRUE (Empty clipboard: DIB format) or FALSE (Not empty clipboard)
* BMP_GET_CLIPBOARD   ()      ---> Return hBitmap (Success) or 0 (Failure or Clipboard Empty DIB format)
* BMP_PUT_CLIPBOARD (hBitmap) ---> Return Success (TRUE or FALSE)
* 
* BMP_COPY_BITBLT         (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2)
* BMP_COPY_STRETCHBLT     (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2, Width2, Height2, modo_stretch)
* BMP_COPY_TRANSPARENTBLT (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2, Width2, Height2, Color_RGB_Transp, modo_stretch)
* BMP_COPY_ALPHABLEND     (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2, Width2, Height2, Alpha, modo_stretch)
* 
* BMP_SHOW                     (hWnd, x, y, Width, Height, hBitmap, modo_stretch)
* BMP_PUTSCREEN_BITBLT         (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2)
* BMP_PUTSCREEN_STRETCHBLT     (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2, Width2, Height2, modo_stretch)
* BMP_PUTSCREEN_TRANSPARENTBLT (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2, Width2, Height2, color_transp, modo_stretch)
* BMP_PUTSCREEN_ALPHABLEND     (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2, Width2, Height2, Alpha, modo_stretch)
* 
* BMP_GETSCREEN_BITBLT         (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2)
* BMP_GETSCREEN_STRETCHBLT     (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2, Width2, Height2, modo_stretch)
* BMP_GETSCREEN_TRANSPARENTBLT (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2, Width2, Height2, color_transp, modo_stretch)
* BMP_GETSCREEN_ALPHABLEND     (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2, Width2, Height2, Alpha, modo_stretch)
* 
* BMP_CLEAN              (hBitmap, x, y, Width, Height, color_RGB)
* BMP_GRAY               (hBitmap, x, y, Width, Height, gray_level)       gray_level = 0 To 100%    
* BMP_LIGHT              (hBitmap, x, y, Width, Height, light_level)       light_level = -255 To +255    
* BMP_CHANGUE_COLOR      (hBitmap, x, y, Width, Height, old_RGB, new_RGB)
* BMP_CHANGUE_COLOR_DIST (hBitmap, x, y, Width, Height, RGB_Color, new_RGB, Dist, Comp)
* 
* BMP_TEXTOUT (hBitmap, x, y, Text, FontName, FontSize, Text_Color, Back_color, Type, Align)
********************************************************************************************************************************


****************************************************************************************************************
* Functions that implement direct GDI functions
****************************************************************************************************************
* GDI_GET_PIXEL (hWND, x, y) ---> Return {R,G,B}
*
* GDI_SET_PIXEL (hWND, x, y, Color_RGB)
****************************************************************************************************************


****************************************************************************************************************
* Miscellaneous functions
****************************************************************************************************************
* WIN_GETCURSOR_POS (hWnd) ---> Return {x,y}
*
* WIN_SETCURSOR_POS (hWnd, x, y)
*
* WIN_GET_CLIENT_RECT (hWnd) ---> Return {Width, Height}
*
* BMP_DESKTOP_hWND ---> Constant 0
****************************************************************************************************************


****************************************************************************************************************
* Functions that DELAY execution of the program
****************************************************************************************************************
* SYS_DELAY (nTicks)                --->  1000 Ticks/seg ---> 1 Ticks = 1 MiliSeg (define in time.h)
*
* SYS_DELAY_WITH_DOEVENTS (nTicks)  --->  1000 Ticks/seg ---> 1 Ticks = 1 MiliSeg (define in time.h)
*
* SYS_CLOCK ()                      ---> Return nTicks
****************************************************************************************************************


*#########################################################################################################################
*   FUNCIONES EN HMG        
*#########################################################################################################################


***********************************************************************************************
* IMAGE_GET_hWND (cWinName, cImageName) ====> Return hWnd
***********************************************************************************************
Function IMAGE_GET_hWND (cWinName, cImageName)
Return GetControlHandle (cImageName, cWinName)


***************************************************************************************************
* IMAGE_GET_hBITMAP (cWinName, cImageName) ====> Return hBitmap 
***************************************************************************************************
Function IMAGE_GET_hBITMAP (cWinName, cImageName)
Local hBitmap := 0
Local k := GetControlIndex (cImageName, cWinName)

     IF k > 0
        hBitmap := _HMG_aControlContainerHandle [k]
     ENDIF
Return hBitmap


****************************************************************************************************
* IMAGE_SHOW_hBITMAP (hWnd, hBitmap) ====> Show hBitmap in IMAGE Control of HMG
****************************************************************************************************
Procedure IMAGE_SHOW_hBITMAP (hWnd, hBitmap)
     #define STM_SETIMAGE  0x0172
     #define IMAGE_BITMAP	0
     SendMessage(hWnd, STM_SETIMAGE, IMAGE_BITMAP, hBitmap)
     #undef  IMAGE_BITMAP
     #undef  STM_SETIMAGE 
Return 


*******************************************************************************************************************
* IMAGE_SET_hBITMAP (cWinName, cImageName, hBitmap, Width, Height) ====> Set and show hBitmap in IMAGE Control of HMG
*******************************************************************************************************************
Procedure IMAGE_SET_hBITMAP (cWinName, cImageName, hBitmap, Width, Height)
Local hWND
Local k := GetControlIndex (cImageName, cWinName)

     IF k > 0
        _HMG_aControlContainerHandle [k] := hBitmap
        _HMG_aControlWidth [k]  := Width
        _HMG_aControlHeight [k] :=  Height
        hWND := IMAGE_GET_hWND  (cWinName, cImageName)
        IMAGE_SHOW_hBITMAP (hWND, hBitmap)
     ENDIF
Return 


*#########################################################################################################################
*   FUNCIONES EN C        
*#########################################################################################################################

#pragma BEGINDUMP

#define WINVER 0x0410

#include <shlobj.h> 
#include <windows.h> 
#include <time.h>
#include <math.h>

#include "hbapi.h"


//*************************************************************************************************
//* SYS_DELAY (nTicks)  --->  1000 Ticks/seg ---> 1 Ticks = 1 MiliSeg (define in time.h)
//*************************************************************************************************
HB_FUNC (SYS_DELAY)
{ 
   clock_t inicio = clock ();
   clock_t ciclos = (clock_t) hb_parnl (1); 
      
   while (clock () - inicio <= ciclos);
}  


//*****************************************************************************************************
//* SYS_DELAY_WITH_DOEVENTS (nTicks)  --->  1000 Ticks/seg ---> 1 Ticks = 1 MiliSeg (define in time.h)
//*****************************************************************************************************
HB_FUNC (SYS_DELAY_WITH_DOEVENTS)
{ 
   MSG Msg;
   clock_t inicio = clock ();
   clock_t ciclos = (clock_t) hb_parnl (1); 
      
   while (clock () - inicio <= ciclos)
   {     if (PeekMessage((LPMSG) &Msg, 0, 0, 0, PM_REMOVE))
         {
            TranslateMessage (&Msg);
            DispatchMessage  (&Msg);
         }
   }
}  


//*************************************************************************************************
//* SYS_CLOCK () ---> Return nTicks
//*************************************************************************************************
HB_FUNC (SYS_CLOCK)
{ 
   hb_retnl ((long) clock ());
}  


//*************************************************************************************************
//* bmp_GetDC (hWnd) ---> Return hDC
//*************************************************************************************************
HDC bmp_GetDC (HWND hWnd)
{   HDC hDC;
    if (hWnd == NULL)
        hDC = CreateDC ("DISPLAY", NULL, NULL, NULL);
    else
        hDC = GetDC (hWnd);
    
    return hDC;        
}


//*************************************************************************************************
//* bmp_ReleaseDC (hWnd, hDC)
//*************************************************************************************************
void bmp_ReleaseDC (HWND hWnd, HDC hDC)
{   
    if (hWnd == NULL)
        DeleteDC (hDC);
    else
        ReleaseDC (hWnd, hDC);        
}


//*************************************************************************************************
//* create_BITMAP_mem (int Width, int Height) ---> Return hBITMAP
//*************************************************************************************************

HBITMAP create_BITMAP_mem (int Width, int Height) 
{   
    LPBYTE  BITMAP_mem_pBits  = NULL;
    HBITMAP hBITMAP_mem;
    HDC hDC_mem;
    BITMAPINFO BI;
                    
    hDC_mem = CreateCompatibleDC(NULL);
    
    BI.bmiHeader.biSize          = sizeof(BITMAPINFOHEADER);
    BI.bmiHeader.biWidth         = Width;
    BI.bmiHeader.biHeight        = -Height;
    BI.bmiHeader.biPlanes        = 1;
    BI.bmiHeader.biBitCount      = 24;
    BI.bmiHeader.biCompression   = BI_RGB;
    BI.bmiHeader.biSizeImage     = 0;
    BI.bmiHeader.biXPelsPerMeter = 0;
    BI.bmiHeader.biYPelsPerMeter = 0;
    BI.bmiHeader.biClrUsed       = 0;
    BI.bmiHeader.biClrImportant  = 0;

    hBITMAP_mem = CreateDIBSection(hDC_mem, (BITMAPINFO *) &BI, DIB_RGB_COLORS, (VOID **) &BITMAP_mem_pBits, NULL, 0);
       
    DeleteDC(hDC_mem);

    return hBITMAP_mem;
}


//**************************************************************************************************
//* BMP_GET_INFO (hBitmap, Info) ---> Return BMP_INFO_xxx
//**************************************************************************************************

#define BMP_INFO_WIDTH     0
#define BMP_INFO_HEIGHT    1
#define BMP_INFO_BITSPIXEL 2

HB_FUNC (BMP_GET_INFO)
{  HBITMAP hBitmap;
   BITMAP bm;
   INT Info;
   
   hBitmap = (HBITMAP)hb_parnl (1);
   Info    = (INT) hb_parnl (2);    
   GetObject(hBitmap, sizeof(BITMAP), (LPSTR)&bm);
 
 /*
   BITMAP:   
     LONG bmType; 
     LONG bmWidth; 
     LONG bmHeight; 
     LONG bmWidthBytes; 
     WORD bmPlanes; 
     WORD bmBitsPixel; 
     LPVOID bmBits; 
 */
 
   switch (Info)    
   {    case BMP_INFO_WIDTH:
             hb_retnl ((long) bm.bmWidth);
             break;
        case BMP_INFO_HEIGHT:
             hb_retnl ((long) bm.bmHeight);
             break;     
        case BMP_INFO_BITSPIXEL:
             hb_retnl ((long) bm.bmBitsPixel);
             break;     
        default:                      
             hb_retnl (0);
    }
}


//*************************************************************************************************
//* BMP_LOAD_FILE (cFileBMP) ---> Return hBITMAP
//*************************************************************************************************
HB_FUNC (BMP_LOAD_FILE)
{   
    HBITMAP hBitmapFile;
    const char *FileName;

    FileName = hb_parcx (1);
  
  // Load file .BMP
     hBitmapFile = (HBITMAP)LoadImage(NULL, FileName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION);
        
  // If fail: load resourse in .EXE file   
     if (hBitmapFile == NULL)
         hBitmapFile = (HBITMAP)LoadImage(GetModuleHandle(NULL), FileName, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
                          
      hb_retnl( (LONG) hBitmapFile );      
}


//*************************************************************************************************
//* BMP_SAVE_FILE (hBitmap, cFileBMP) ---> Return Success (TRUE or FALSE)
//*************************************************************************************************
HB_FUNC (BMP_SAVE_FILE)
{  
   HGLOBAL hBits;
   LPBYTE  lp_hBits;
   HANDLE  hFile;
   HBITMAP hBitmap1, hBitmap2, hBitmap;
   HDC memDC1, memDC2, memDC;
   BITMAPFILEHEADER BIFH;
   BITMAPINFO BI;
   BITMAP bm;
   DWORD nBytes_Bits, nBytes_Written;
   BOOL flag = FALSE; 
   const char *FileName;

   hBitmap1 = (HBITMAP) hb_parnl  (1);
   FileName  = hb_parcx (2);
   
   memDC1 = CreateCompatibleDC(NULL);              
   SelectObject(memDC1, hBitmap1);
                                       
   GetObject(hBitmap1, sizeof(BITMAP), (LPSTR)&bm);

   if (bm.bmBitsPixel == 24)
       hBitmap = hBitmap1;
   else    
   {       
       memDC2 = CreateCompatibleDC(NULL);
           hBitmap2 = create_BITMAP_mem (bm.bmWidth, bm.bmHeight);
           SelectObject(memDC2, hBitmap2);                
           StretchBlt(memDC2, 0, 0, bm.bmWidth, bm.bmHeight, memDC1, 0, 0, bm.bmWidth, bm.bmHeight, SRCCOPY);                                
       DeleteDC(memDC2);
       flag = TRUE;
       hBitmap = hBitmap2;
   }   
   DeleteDC(memDC1);

   memDC = CreateCompatibleDC(NULL);
         SelectObject(memDC, hBitmap);                
         GetObject(hBitmap, sizeof(BITMAP), (LPSTR)&bm);

        // bm.bmWidthBytes = (bm.bmWidth * bm.bmBitsPixel + 15) / 16 * 2;                   
         nBytes_Bits = (DWORD)(bm.bmWidthBytes * labs(bm.bmHeight));

         
         BIFH.bfType = ('M' << 8) + 'B';
         BIFH.bfSize = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER) + nBytes_Bits; 
         BIFH.bfReserved1 = 0;
         BIFH.bfReserved2 = 0;
         BIFH.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
         
                          
         BI.bmiHeader.biSize          = sizeof(BITMAPINFOHEADER);
         BI.bmiHeader.biWidth         = bm.bmWidth;
         BI.bmiHeader.biHeight        = bm.bmHeight;
         BI.bmiHeader.biPlanes        = 1;
         BI.bmiHeader.biBitCount      = 24;
         BI.bmiHeader.biCompression   = BI_RGB;
         BI.bmiHeader.biSizeImage     = 0; //nBytes_Bits;
         BI.bmiHeader.biXPelsPerMeter = 0;
         BI.bmiHeader.biYPelsPerMeter = 0;
         BI.bmiHeader.biClrUsed       = 0;
         BI.bmiHeader.biClrImportant  = 0;
  
         hBits = GlobalAlloc (GHND, (DWORD) nBytes_Bits);
         if (hBits == NULL)
         {   hb_retl (FALSE); 
             return;
         }

         lp_hBits = (LPBYTE) GlobalLock (hBits);
       
         GetDIBits (memDC, hBitmap, 0, BI.bmiHeader.biHeight, (LPVOID) lp_hBits, &BI, DIB_RGB_COLORS);
                   
         hFile = CreateFile (FileName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, NULL);         
            WriteFile(hFile, (LPSTR)&BIFH,          sizeof(BITMAPFILEHEADER), &nBytes_Written, NULL);
            WriteFile(hFile, (LPSTR)&BI.bmiHeader,  sizeof(BITMAPINFOHEADER), &nBytes_Written, NULL);
            WriteFile(hFile, (LPSTR)lp_hBits,       nBytes_Bits,              &nBytes_Written, NULL);          
         CloseHandle (hFile); 
             
         GlobalUnlock (hBits);
         GlobalFree (hBits);
            
   DeleteDC(memDC);
   
   if (flag) 
       DeleteObject (hBitmap2);   
}


//**************************************************************************************************
//* BMP_CREATE (Width, Height) ---> Return hBITMAP
//**************************************************************************************************

HB_FUNC (BMP_CREATE)
{   
   hb_retnl ((LONG) create_BITMAP_mem (hb_parnl (1), hb_parnl (2)));     
}


//*************************************************************************************************
//* BMP_RELEASE (hBitmap) ---> Return Success (TRUE or FALSE)
//*************************************************************************************************
HB_FUNC (BMP_RELEASE)
{   
   hb_retl (DeleteObject ((HBITMAP) hb_parnl (1)));
}


//*************************************************************************************************
//* BMP_RESIZE (hBitmap, New_Width, New_Height, modo_stretch) ---> Return new_hBitmap
//*************************************************************************************************

#define BMP_SCALE   0
#define BMP_STRETCH 1

HB_FUNC (BMP_RESIZE)
{
   HBITMAP hBitmap_O, hBitmap_D;
   HDC memDC1, memDC2;
   BITMAP bm;
   INT New_Width, New_Height, modo_stretch;

   hBitmap_O     = (HBITMAP) hb_parnl  (1);
   New_Width     = hb_parni (2);
   New_Height    = hb_parni (3);
   modo_stretch  = hb_parni (4);
       
   memDC2 = CreateCompatibleDC(NULL);              
   SelectObject(memDC2, hBitmap_O);
                                       
   GetObject(hBitmap_O, sizeof(BITMAP), (LPSTR)&bm);
               
   if (modo_stretch == BMP_SCALE)
   {  if ((int) bm.bmWidth * New_Height / bm.bmHeight <= New_Width)
	      New_Width= (int) bm.bmWidth * New_Height / bm.bmHeight;
	  else		
	      New_Height = (int) bm.bmHeight * New_Width / bm.bmWidth;                 
   }
                
   memDC1 = CreateCompatibleDC(NULL);
   hBitmap_D = create_BITMAP_mem (New_Width, New_Height);
   SelectObject(memDC1, hBitmap_D);                

   StretchBlt(memDC1, 0, 0, New_Width, New_Height, memDC2, 0, 0, bm.bmWidth, bm.bmHeight, SRCCOPY);
                        
   DeleteDC(memDC1);     
   DeleteDC(memDC2);
    
   hb_retnl ((LONG) hBitmap_D); 
}


//***********************************************************************************************************************
//* BMP_TRANSFORM (hBitmap, modo, Angle, Color_Fill) ---> Return New_hBitmap
//***********************************************************************************************************************

#define BMP_REFLECT_HORIZONTAL 1 
#define BMP_REFLECT_VERTICAL   2
#define BMP_ROTATE             4

HB_FUNC (BMP_TRANSFORM)
{  
   HDC memDC1, memDC2;
   HBITMAP hBitmap_O, hBitmap_D;
   BITMAP bm;
   INT Width, Height, modo;
   FLOAT Angle; 
   double radianes, x1, y1, x2, y2, x3, y3;
   XFORM xform1  = {1, 0, 0, 1, 0, 0}; // Normal
   XFORM xform2  = {1, 0, 0, 1, 0, 0}; // Normal
   XFORM xform_D = {1, 0, 0, 1, 0, 0}; // Normal
   RECT rectang;
   HBRUSH hBrush;
   COLORREF Color_Fill;
   
   const double pi = 3.141592;
   #define dABS(n) ((double)n >= 0.0 ? (double) n : (double) -n)
   #define SCALING(n) ((double)n > 1.0 ? (double) (1.0/n) : (double) 1.0)
   
   hBitmap_O     = (HBITMAP)  hb_parnl (1);
   modo          = (INT)      hb_parnl (2);
   Angle         = (FLOAT)    hb_parnd (3);
   Color_Fill    = (COLORREF) hb_parnl (4);
       
   memDC1 = CreateCompatibleDC(NULL);   
   SelectObject(memDC1, hBitmap_O);
   GetObject(hBitmap_O, sizeof(BITMAP), (LPSTR)&bm);

   Width  = bm.bmWidth;
   Height = bm.bmHeight;

   memDC2 = CreateCompatibleDC(NULL);   
   SetGraphicsMode(memDC2, GM_ADVANCED);
      
   if ((modo & BMP_REFLECT_HORIZONTAL) == BMP_REFLECT_HORIZONTAL)
   {   xform1.eM11 = (FLOAT) -1.0; 
       xform1.eDx  = (FLOAT)  (Width -1); 
       
       if ((modo & BMP_ROTATE) == BMP_ROTATE)
            xform1.eDx  = (FLOAT)   Width;  
   }
   
   if ((modo & BMP_REFLECT_VERTICAL) == BMP_REFLECT_VERTICAL)
   {   xform1.eM22 = (FLOAT) -1.0;        
       xform1.eDy  = (FLOAT)  (Height -1);  
       
       if ((modo & BMP_ROTATE) == BMP_ROTATE)
            xform1.eDy  = (FLOAT)  Height;
   }
      
   if ((modo & BMP_ROTATE) == BMP_ROTATE)
   {     
      if ((Angle <= 0.0) || (Angle > 360.0)) 
           Angle = 360.0; 
   
       // Angle = angulo en grados
       radianes = (2*pi) * (double)Angle / (double)360.0;
       
       // x1,y1 = W,0
       // x2,y2 = W,H
       // x3,y3 = 0,H
       
       // A = angulo en radianes
       // new_x = (x * cos A) - (y * sin A) 
       // new_y = (x * sin A) + (y * cos A)
     
     
       x1 = ((double)Width * cos(radianes));
       y1 = ((double)Width * sin(radianes)); 
       
       x2 = ((double)Width * cos(radianes)) - ((double)Height * sin(radianes));
       y2 = ((double)Width * sin(radianes)) + ((double)Height * cos(radianes)); 

       x3 =  - ((double)Height * sin(radianes));
       y3 =    ((double)Height * cos(radianes)); 

     
       xform2.eM11 = (FLOAT)  cos (radianes); 
       xform2.eM12 = (FLOAT)  sin (radianes); 
       xform2.eM21 = (FLOAT) -sin (radianes); 
       xform2.eM22 = (FLOAT)  cos (radianes);
       xform2.eDx  = (FLOAT)  0.0; 
       xform2.eDy  = (FLOAT)  0.0;  
 
       
       if (Angle <= 90.0) 
       {  xform2.eDx  = (FLOAT)  -x3;
          xform2.eDy  = (FLOAT)  0.0;
                  
          Width  = (LONG)dABS((x3-x1));
             
          Height = (LONG)dABS(y2);
       }
       
       if ((Angle > 90.0) && (Angle <= 180.0)) 
       {  xform2.eDx  = (FLOAT)  -x2;
          xform2.eDy  = (FLOAT)  -y3;
                  
          Width  = (LONG)dABS(x2);
             
          Height = (LONG)dABS((y3-y1));
       }

       if ((Angle > 180.0) && (Angle <= 270.0)) 
       {  xform2.eDx  = (FLOAT)  -x1;
          xform2.eDy  = (FLOAT)  -y2;
                  
          Width  = (LONG)dABS((x3-x1));
             
          Height = (LONG)dABS(y2);
       }
              
       if ((Angle > 270.0) && (Angle <= 360.0)) 
       {  xform2.eDx  = (FLOAT)  0.0;
          xform2.eDy  = (FLOAT)  -y1;
                  
          Width  = (LONG)dABS(x2);
             
          Height = (LONG)dABS((y3-y1));
       }
       
       Width++;
       Height++;
       
       if ((Angle == 0.0) || (Angle == 180.0) ||(Angle == 360.0))
       {    Width  = bm.bmWidth;
            Height = bm.bmHeight;
       }
       if ((Angle == 90.0) || (Angle == 270.0))
       {    Width  = bm.bmHeight;
            Height = bm.bmWidth;
       }            
       
   }
   
   hBitmap_D = create_BITMAP_mem (Width, Height);
   SelectObject(memDC2, hBitmap_D);

       hBrush = CreateSolidBrush (Color_Fill);
            SelectObject(memDC2, hBrush);       
            SetRect  (&rectang, 0, 0, Width, Height);          
            FillRect (memDC2, &rectang, hBrush);
       DeleteObject(hBrush);
   
   CombineTransform (&xform_D, &xform1, &xform2);        
   SetWorldTransform(memDC2, &xform_D);   
   
   StretchBlt(memDC2, 0, 0, bm.bmWidth, bm.bmHeight, memDC1, 0, 0, bm.bmWidth, bm.bmHeight, SRCCOPY);   
   
   DeleteDC (memDC1);
   DeleteDC (memDC2);

   hb_retnl ((LONG) hBitmap_D);      
}


//**************************************************************************************************
//* BMP_SET_PIXEL (hBitmap, x, y, Color_RGB)
//**************************************************************************************************

HB_FUNC (BMP_SET_PIXEL)
{   
   HDC memDC;
   HBITMAP hBitmap;
   INT x, y;
   COLORREF color_RGB;

   hBitmap    = (HBITMAP)hb_parnl (1);
   x          = (INT) hb_parni (2);
   y          = (INT) hb_parni (3);
   color_RGB  = (COLORREF) hb_parnl (4);
      
   memDC = CreateCompatibleDC(NULL);     
      SelectObject(memDC, hBitmap);
      SetPixel( memDC, x, y, color_RGB);        
   DeleteDC(memDC); 
}


//**************************************************************************************************
//* BMP_GET_PIXEL (hBitmap, x, y) ---> Return {R,G,B}
//**************************************************************************************************

HB_FUNC (BMP_GET_PIXEL)
{   
   HDC memDC;
   HBITMAP hBitmap;
   INT x, y;
   COLORREF color;

   hBitmap = (HBITMAP)hb_parnl (1);
   x       = (INT) hb_parni (2);
   y       = (INT) hb_parni (3);
   
   memDC = CreateCompatibleDC(NULL);     
      SelectObject(memDC, hBitmap);
      color = GetPixel(memDC, x, y);
   DeleteDC(memDC);
   
   hb_reta( 3 );
   hb_storvni((int) GetRValue(color), -1, 1 );
   hb_storvni((int) GetGValue(color), -1, 2);
   hb_storvni((int) GetBValue(color), -1, 3); 
}


//*************************************************************************************************
//* BMP_GET_SPRITE (hBitmap, x, y, Width, Height) ---> Return new_hBITMAP
//*************************************************************************************************
HB_FUNC (BMP_GET_SPRITE)
{  
   HBITMAP hBitmap, hBITMAP_mem;
   INT y, x, Width, Height;
   HDC memDC1, memDC2; 
   
   hBitmap = (HBITMAP)hb_parnl (1);
   x       = (INT) hb_parni (2);
   y       = (INT) hb_parni (3);
   Width   = (INT) hb_parni (4);
   Height  = (INT) hb_parni (5);
   
   
   memDC1 = CreateCompatibleDC(NULL);   
   SelectObject(memDC1, hBitmap);
   
   memDC2 = CreateCompatibleDC(NULL);
   hBITMAP_mem = (HBITMAP) create_BITMAP_mem (Width, Height);
  
   SelectObject(memDC2, hBITMAP_mem); 
   
   BitBlt(memDC2, 0, 0, Width, Height, memDC1, x, y, SRCCOPY); 
   DeleteDC(memDC1);
   DeleteDC(memDC2); 
   
   hb_retnl ((LONG) hBITMAP_mem);
}


//*************************************************************************************************
//* BMP_PUT_SPRITE (hBitmap_D, x1, y1, hBitmap_O, x2, y2, Width2, Height2)
//*************************************************************************************************
HB_FUNC (BMP_PUT_SPRITE)
{  
   HBITMAP hBitmap_D, hBitmap_O;
   INT x1, y1, x2, y2, Width2, Height2;
   HDC memDC1, memDC2; 
   
   hBitmap_D  = (HBITMAP) hb_parnl (1);
   x1         = (INT)     hb_parni (2);
   y1         = (INT)     hb_parni (3);
   hBitmap_O  = (HBITMAP) hb_parnl (4);
   x2         = (INT)     hb_parni (5);
   y2         = (INT)     hb_parni (6);
   Width2     = (INT)     hb_parni (7);
   Height2    = (INT)     hb_parni (8);
   
   
   memDC1 = CreateCompatibleDC(NULL);   
   SelectObject(memDC1, hBitmap_D);
   
   memDC2 = CreateCompatibleDC(NULL);
   SelectObject(memDC2, hBitmap_O);
   
   StretchBlt(memDC1, x1, y1, Width2, Height2, memDC2, x2, y2, Width2, Height2, SRCCOPY); 

   DeleteDC(memDC1);
   DeleteDC(memDC2); 
}


//**************************************************************************************************
//* BMP_ISPOINT_IN_SPRITE (Px, Py, hBitmap, x, y, Width, Height, Color_Transp, modo)
//**************************************************************************************************

#define BMP_OPAQUE       0 
#define BMP_TRANSPARENT  1

HB_FUNC (BMP_ISPOINT_IN_SPRITE)
{
   POINT Punto;
   HBITMAP hBitmap;
   HDC memDC;
   INT x, y, Width, Height;
   RECT  Sprite;
   COLORREF Color_Transp;
   INT modo;
   INT x_rel, y_rel;
   
   Punto.x    = hb_parnl (1);
   Punto.y    = hb_parnl (2);   
   hBitmap    = (HBITMAP)  hb_parnl (3);
   x          = (INT)      hb_parnl (4);
   y          = (INT)      hb_parnl (5);
   Width      = (INT)      hb_parnl (6);
   Height     = (INT)      hb_parnl (7);
   Color_Transp  = (COLORREF) hb_parnl (8);
   modo       = (INT) hb_parnl (9);
   
   SetRect (&Sprite, x, y, x+Width, y+Height);
   
   if (PtInRect (&Sprite, Punto))
   {  if (modo == BMP_OPAQUE)
          hb_retl (TRUE);
      else
      {
          memDC = CreateCompatibleDC(NULL);     
          SelectObject(memDC, hBitmap);
              x_rel = Punto.x - x;
              y_rel = Punto.y - y;
              
              if (Color_Transp == GetPixel(memDC, x_rel, y_rel))
                  hb_retl (FALSE);
              else
                  hb_retl (TRUE);
                      
          DeleteDC(memDC);
      }          
   }
   else
      hb_retl (FALSE);
}


//********************************************************************************************************************
//* BMP_IS_INTERSECT_SPRITE (hBitmap1, x1, y1, Width1, Height1, Color_Transp1, hBitmap2, x2, y2, Width2, Height2, Color_Transp2, modo)
//********************************************************************************************************************

#define BMP_OPAQUE       0 
#define BMP_TRANSPARENT  1
              
HB_FUNC (BMP_IS_INTERSECT_SPRITE)
{
   HBITMAP hBitmap1, hBitmap2;
   HDC memDC1, memDC2;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2;
   RECT  Rect1, Rect2, Rect;
   COLORREF Color_Transp1, Color_Transp2;
   INT modo;
   INT x_rel1, y_rel1, x_rel2, y_rel2;
   INT x, y, w, h;
   
      
   hBitmap1    = (HBITMAP)  hb_parnl (1);
   x1          = (INT)      hb_parnl (2);
   y1          = (INT)      hb_parnl (3);
   Width1      = (INT)      hb_parnl (4);
   Height1     = (INT)      hb_parnl (5);
   Color_Transp1  = (COLORREF) hb_parnl (6);
  
   hBitmap2    = (HBITMAP)  hb_parnl (7);
   x2          = (INT)      hb_parnl (8);
   y2          = (INT)      hb_parnl (9);
   Width2      = (INT)      hb_parnl (10);
   Height2     = (INT)      hb_parnl (11);
   Color_Transp2  = (COLORREF) hb_parnl (12);
   
   modo          = (INT)      hb_parnl (13);
   
   SetRect (&Rect1, x1, y1, x1+Width1, y1+Height1);
   SetRect (&Rect2, x2, y2, x2+Width2, y2+Height2);
   
   IntersectRect (&Rect, &Rect1, &Rect2);
  
   if (IsRectEmpty (&Rect))
   {  hb_retl (FALSE);
   } 
   else
   {  if (modo == BMP_OPAQUE)
          hb_retl (TRUE);
      else
      {
          memDC1 = CreateCompatibleDC(NULL);     
          SelectObject(memDC1, hBitmap1);
          
          memDC2 = CreateCompatibleDC(NULL);     
          SelectObject(memDC2, hBitmap2);
          
          w = (INT)(Rect.right  - Rect.left);
          h = (INT)(Rect.bottom - Rect.top);
          
          if (x1 >= Rect.left)
              x_rel1 = x1 - Rect.left;
          else    
              x_rel1 = Rect.left - x1;
              
          if (x2 >= Rect.left)
              x_rel2 = x2 - Rect.left;
          else    
              x_rel2 = Rect.left - x2;
              
          
          if (y1 >= Rect.top)
              y_rel1 = y1 - Rect.top;
          else    
              y_rel1 = Rect.top - y1;
              
          if (y2 >= Rect.top)
              y_rel2 = y2 - Rect.top;
          else    
              y_rel2 = Rect.top - y2;    
    
            
          for (y = 0; y < h; y++)
          {  for (x = 0; x < w; x++)
             {   if (Color_Transp1 != GetPixel(memDC1, x_rel1+x, y_rel1+y))
                   if (Color_Transp2 != GetPixel(memDC2, x_rel2+x, y_rel2+y))
                   {   hb_retl (TRUE);
                       goto SALIR;
                   }
             }
          }      
          hb_retl (FALSE);             
          
          SALIR:              
          DeleteDC(memDC1);
          DeleteDC(memDC2);
      }          
   }
}


//************************************************************************************************************
//* BMP_CLIPBOARD_EMPTY () ---> Return TRUE (Empty clipboard: DIB format) or FALSE (Not empty clipboard)
//************************************************************************************************************

HB_FUNC (BMP_CLIPBOARD_EMPTY)
{ 
   if (IsClipboardFormatAvailable (CF_DIB))
      hb_retl (FALSE);   // Not empty clipboard 
   else    
      hb_retl (TRUE);    // Empty clipboard 
}


//*************************************************************************************************
//* BMP_GET_CLIPBOARD () ---> Return hBitmap (Success) or 0 (Failure or Clipboard Empty DIB format)
//*************************************************************************************************

HB_FUNC (BMP_GET_CLIPBOARD)
{ 
   HGLOBAL hClip;
   HDC memDC;
   HBITMAP hBitmap; 
   BITMAPINFO BI;
   LPBITMAPINFO  lpBI ;
   LPBYTE   lp_Bits, lp_Clip;
   LPBYTE   BITMAP_mem_pBits = NULL;
   WORD nBytes_Offset;  

   if (!IsClipboardFormatAvailable (CF_DIB))
   {    hb_retnl (0);
        return;
   }

   if (!OpenClipboard (GetActiveWindow()))
   {   hb_retnl (0);
       return;
   }

   hClip = GetClipboardData(CF_DIB) ;
   if (hClip == NULL)
   {   CloseClipboard();       
       hb_retnl (0); 
       return;   
   }

   lp_Clip = (LPBYTE) GlobalLock(hClip);
   
   lpBI    = (LPBITMAPINFO) lp_Clip;
   
   nBytes_Offset = 0;
   if (lpBI->bmiHeader.biBitCount == 1) nBytes_Offset = sizeof (RGBQUAD) * 2; 
   if (lpBI->bmiHeader.biBitCount == 4) nBytes_Offset = sizeof (RGBQUAD) * 16;
   if (lpBI->bmiHeader.biBitCount == 8) nBytes_Offset = sizeof (RGBQUAD) * 256;
   
   lp_Bits = (LPBYTE) (lp_Clip + (sizeof (BITMAPINFOHEADER) + nBytes_Offset));
    
   BI.bmiHeader.biSize          = sizeof(BITMAPINFOHEADER);
   BI.bmiHeader.biWidth         = lpBI->bmiHeader.biWidth;
   BI.bmiHeader.biHeight        = lpBI->bmiHeader.biHeight;
   BI.bmiHeader.biPlanes        = 1;
   BI.bmiHeader.biBitCount      = 24;
   BI.bmiHeader.biCompression   = BI_RGB;
   BI.bmiHeader.biSizeImage     = 0;
   BI.bmiHeader.biXPelsPerMeter = 0;
   BI.bmiHeader.biYPelsPerMeter = 0;
   BI.bmiHeader.biClrUsed       = 0;
   BI.bmiHeader.biClrImportant  = 0;

   memDC = CreateCompatibleDC(NULL);
            
      hBitmap = CreateDIBSection (memDC, &BI, DIB_RGB_COLORS, (VOID **) &BITMAP_mem_pBits, NULL, 0);
      SetDIBits(memDC, hBitmap, 0, BI.bmiHeader.biHeight, lp_Bits, lpBI, DIB_RGB_COLORS);

   DeleteDC(memDC);
   
   GlobalUnlock(hClip) ;
   CloseClipboard() ;
     
   hb_retnl ((LONG) hBitmap);   
}   


//*************************************************************************************************
//* BMP_PUT_CLIPBOARD (hBitmap) ---> Return Success (TRUE or FALSE)
//*************************************************************************************************

HB_FUNC (BMP_PUT_CLIPBOARD)
{ 
   HGLOBAL hClip;
   HDC memDC;
   HBITMAP hBitmap;
   BITMAPINFO BI;
   BITMAP bm;
   DWORD nBytes_Bits, nBytes_BI, nBytes_Total;
   LPBYTE lp_hClip;
 
   hBitmap = (HBITMAP) hb_parnl (1);
   
   GetObject(hBitmap, sizeof(BITMAP), (LPSTR)&bm);
   
   BI.bmiHeader.biSize          = sizeof(BITMAPINFOHEADER);
   BI.bmiHeader.biWidth         = bm.bmWidth;
   BI.bmiHeader.biHeight        = bm.bmHeight;
   BI.bmiHeader.biPlanes        = 1;
   BI.bmiHeader.biBitCount      = 24;
   BI.bmiHeader.biCompression   = BI_RGB;
   BI.bmiHeader.biSizeImage     = 0;
   BI.bmiHeader.biXPelsPerMeter = 0;
   BI.bmiHeader.biYPelsPerMeter = 0;
   BI.bmiHeader.biClrUsed       = 0;
   BI.bmiHeader.biClrImportant  = 0;

    
   bm.bmWidthBytes = (bm.bmWidth * BI.bmiHeader.biBitCount + 15) / 16 * 2;  
   
   nBytes_BI    = (DWORD) sizeof(BITMAPINFOHEADER);
   nBytes_Bits  = (DWORD)bm.bmWidthBytes * (DWORD)bm.bmHeight;
   nBytes_Total = nBytes_BI + nBytes_Bits; 
   
   
   if (!OpenClipboard (GetActiveWindow()))
   {   
       hb_retl (FALSE);
       return;
   }
   
         
   hClip = GlobalAlloc (GHND, (DWORD) nBytes_Total);
   if (hClip == NULL)
   {   CloseClipboard();
       hb_retl (FALSE); 
       return;
   }
       
   lp_hClip = GlobalLock (hClip);
       
   memcpy (lp_hClip, &BI.bmiHeader, nBytes_BI);
        
   memDC = CreateCompatibleDC(NULL);
   GetDIBits (memDC, hBitmap, 0, bm.bmHeight, (LPVOID) (lp_hClip + nBytes_BI), &BI, DIB_RGB_COLORS);
   
   GlobalUnlock(hClip); 

   EmptyClipboard();
   
   SetClipboardData (CF_DIB, hClip);

   CloseClipboard(); 
 
   DeleteDC(memDC);

   hb_retl (TRUE);     
}   
 

//*************************************************************************************************************
//* BMP_COPY_BITBLT (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2)
//**************************************************************************************************************

HB_FUNC (BMP_COPY_BITBLT)
{   
   HDC memDC1, memDC2;
   HBITMAP hBitmap_D, hBitmap_O;
   INT x1, y1, Width1, Height1, x2, y2;
   
   hBitmap_D  = (HBITMAP)hb_parnl (1);
   x1         = (INT) hb_parni (2);
   y1         = (INT) hb_parni (3);
   Width1     = (INT) hb_parni (4);
   Height1    = (INT) hb_parni (5);
   
   hBitmap_O  = (HBITMAP)hb_parnl (6);
   x2         = (INT) hb_parni (7);
   y2         = (INT) hb_parni (8);
   
   memDC1 = CreateCompatibleDC(NULL);   
   SelectObject(memDC1, hBitmap_D);

   memDC2 = CreateCompatibleDC(NULL);   
   SelectObject(memDC2, hBitmap_O);

   BitBlt(memDC1, x1, y1, Width1, Height1, memDC2, x2, y2, SRCCOPY);
        
   DeleteDC(memDC1);
   DeleteDC(memDC2); 
}


//**********************************************************************************************************************
//* BMP_COPY_STRETCHBLT (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2, Width2, Height2, modo_stretch)
//**********************************************************************************************************************

HB_FUNC (BMP_COPY_STRETCHBLT)
{   
   HDC memDC1, memDC2;
   HBITMAP hBitmap_D, hBitmap_O;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;

   hBitmap_D  = (HBITMAP)hb_parnl (1);
   x1         = (INT) hb_parni (2);
   y1         = (INT) hb_parni (3);
   Width1     = (INT) hb_parni (4);
   Height1    = (INT) hb_parni (5);
   
   hBitmap_O  = (HBITMAP)hb_parnl (6);
   x2         = (INT) hb_parni (7);
   y2         = (INT) hb_parni (8);
   Width2     = (INT) hb_parni (9);
   Height2    = (INT) hb_parni (10);
   
   modo_stretch  = (INT) hb_parnl (11);


   memDC1 = CreateCompatibleDC(NULL);   
   SelectObject(memDC1, hBitmap_D);

   memDC2 = CreateCompatibleDC(NULL);   
   SelectObject(memDC2, hBitmap_O);
   
   if (modo_stretch == BMP_SCALE)
   {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	  else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
   }   
      
   StretchBlt(memDC1, x1, y1, Width1, Height1, memDC2, x2, y2, Width2, Height2, SRCCOPY); 
   
   DeleteDC(memDC1);
   DeleteDC(memDC2);    
}

                                         
//*********************************************************************************************************************************
//* BMP_COPY_TRANSPARENTBLT (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2, Width2, Height2, Color_RGB_Transp, modo_stretch)
//*********************************************************************************************************************************

HB_FUNC (BMP_COPY_TRANSPARENTBLT)
{   
   HDC memDC1, memDC2;
   HBITMAP hBitmap_D, hBitmap_O;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;
   COLORREF color_transp;

   hBitmap_D  = (HBITMAP)hb_parnl (1);
   x1         = (INT) hb_parni (2);
   y1         = (INT) hb_parni (3);
   Width1     = (INT) hb_parni (4);
   Height1    = (INT) hb_parni (5);
   
   hBitmap_O  = (HBITMAP)hb_parnl (6);
   x2         = (INT) hb_parni (7);
   y2         = (INT) hb_parni (8);
   Width2     = (INT) hb_parni (9);
   Height2    = (INT) hb_parni (10);
   
   color_transp    = (COLORREF) hb_parnl (11);

   modo_stretch    = (INT) hb_parni (12);
   
   memDC1 = CreateCompatibleDC(NULL);   
   SelectObject(memDC1, hBitmap_D);

   memDC2 = CreateCompatibleDC(NULL);   
   SelectObject(memDC2, hBitmap_O);

   if (modo_stretch == BMP_SCALE)
   {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	  else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
   }   

   TransparentBlt (memDC1, x1, y1, Width1, Height1, memDC2, x2, y2, Width2, Height2, color_transp);
   
   DeleteDC(memDC1);
   DeleteDC(memDC2);    
}

                                         
//************************************************************************************************************************
//* BMP_COPY_ALPHABLEND (hBitmap_D, x1, y1, Width1, Height1, hBitmap_O, x2, y2, Width2, Height2, Alpha, modo_stretch)
//************************************************************************************************************************

HB_FUNC (BMP_COPY_ALPHABLEND)
{
   HBITMAP hBitmap_O, hBitmap_D;
   HDC memDC1, memDC2;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;
   BLENDFUNCTION blend;
   BYTE Alpha;

   hBitmap_D  = (HBITMAP)hb_parnl (1);
   x1         = (INT) hb_parni (2);
   y1         = (INT) hb_parni (3);
   Width1     = (INT) hb_parni (4);
   Height1    = (INT) hb_parni (5);
   
   hBitmap_O  = (HBITMAP)hb_parnl (6);
   x2         = (INT) hb_parni (7);
   y2         = (INT) hb_parni (8);
   Width2     = (INT) hb_parni (9);
   Height2    = (INT) hb_parni (10);
   
   Alpha      = (BYTE) hb_parni (11);
   
   modo_stretch  = (INT) hb_parni (12);

   blend.BlendOp = AC_SRC_OVER;
   blend.BlendFlags = 0;
   blend.AlphaFormat = 0;
   blend.SourceConstantAlpha = Alpha; 

   memDC1 = CreateCompatibleDC(NULL);   
   SelectObject(memDC1, hBitmap_D);

   memDC2 = CreateCompatibleDC(NULL);   
   SelectObject(memDC2, hBitmap_O);

   if (modo_stretch == BMP_SCALE)
   {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	  else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
   }   

   AlphaBlend (memDC1, x1, y1, Width1, Height1, memDC2, x2, y2, Width2, Height2, blend);
   
   DeleteDC(memDC1);
   DeleteDC(memDC2);    
}


//***********************************************************************************************************************
//* BMP_SHOW (hWnd, x, y, Width, Height, hBitmap, modo_stretch)
//***********************************************************************************************************************

#define BMP_COPY 3

HB_FUNC (BMP_SHOW)
{  
   HWND hWnd; 
   HDC hDC, memDC;
   HBITMAP hBitmap;
   BITMAP bm;
   INT x, y, Width, Height, modo_stretch;

   hWnd          = (HWND)    hb_parnl (1);
   x             = (INT)     hb_parni (2);
   y             = (INT)     hb_parni (3);
   Width         = (INT)     hb_parni (4);
   Height        = (INT)     hb_parni (5);
   hBitmap       = (HBITMAP) hb_parnl (6);
   modo_stretch  = (INT)     hb_parnl (7);

   hDC = bmp_GetDC (hWnd);
   
   memDC = CreateCompatibleDC(NULL);   
   SelectObject(memDC, hBitmap);
   
   if (modo_stretch == BMP_COPY)
       BitBlt(hDC, x, y, Width, Height, memDC, 0, 0, SRCCOPY);
   else
   {
       GetObject(hBitmap, sizeof(BITMAP), (LPSTR)&bm);                 
       if (modo_stretch == BMP_SCALE)
       {  
          if ((int) bm.bmWidth * Height / bm.bmHeight <= Width)
	          Width = (int) bm.bmWidth * Height / bm.bmHeight;
	      else		
	          Height = (int) bm.bmHeight * Width / bm.bmWidth;                 
       }
       StretchBlt(hDC, x, y, Width, Height, memDC, 0, 0, bm.bmWidth, bm.bmHeight, SRCCOPY); 
   }
   
   DeleteDC(memDC);     
   bmp_ReleaseDC(hWnd, hDC);          
}

                                         
//*************************************************************************************************
//* BMP_PUTSCREEN_BITBLT (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2)
//*************************************************************************************************

HB_FUNC (BMP_PUTSCREEN_BITBLT)
{
    HWND hWnd;
    HBITMAP hBitmap;
    HDC memDC, hDC;
    INT x1, y1, Width1, Height1;
    INT x2, y2;
    
    hWnd      = (HWND)    hb_parnl (1);
    x1        = (INT)     hb_parni (2);
    y1        = (INT)     hb_parni (3);
    Width1    = (INT)     hb_parni (4);
    Height1   = (INT)     hb_parni (5);
    
    hBitmap   = (HBITMAP) hb_parnl (6);
    x2        = (INT)     hb_parni (7);
    y2        = (INT)     hb_parni (8);
    
    hDC = bmp_GetDC (hWnd);
        memDC = CreateCompatibleDC(hDC);              
              SelectObject(memDC, hBitmap);                
              BitBlt(hDC, x1, y1, Width1, Height1, memDC, x2, y2, SRCCOPY);                                                         
        DeleteDC(memDC);     
    bmp_ReleaseDC(hWnd, hDC);   
}


//***********************************************************************************************************************
//* BMP_PUTSCREEN_STRETCHBLT (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2, Width2, Height2, modo_stretch)
//***********************************************************************************************************************

HB_FUNC (BMP_PUTSCREEN_STRETCHBLT)
{  
   HWND hWnd; 
   HDC hDC, memDC;
   HBITMAP hBitmap;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;

   hWnd       = (HWND) hb_parnl (1);
   x1         = (INT)  hb_parni (2);
   y1         = (INT)  hb_parni (3);
   Width1     = (INT)  hb_parni (4);
   Height1    = (INT)  hb_parni (5);
   
   hBitmap    = (HBITMAP)hb_parnl (6);
   x2         = (INT) hb_parni (7);
   y2         = (INT) hb_parni (8);
   Width2     = (INT) hb_parni (9);
   Height2    = (INT) hb_parni (10);
   
   modo_stretch  = (INT) hb_parnl (11);

   hDC = bmp_GetDC (hWnd);
   
   memDC = CreateCompatibleDC(NULL);   
   SelectObject(memDC, hBitmap);
   
   if (modo_stretch == BMP_SCALE)
   {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	  else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
   }   
      
   StretchBlt(hDC, x1, y1, Width1, Height1, memDC, x2, y2, Width2, Height2, SRCCOPY); 
   
   DeleteDC(memDC);     
   bmp_ReleaseDC(hWnd, hDC);          
}


//**************************************************************************************************************************
//* BMP_PUTSCREEN_TRANSPARENTBLT (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2, Width2, Height2, color_transp, modo_stretch)
//**************************************************************************************************************************

HB_FUNC (BMP_PUTSCREEN_TRANSPARENTBLT)
{
    HWND hWnd;
    HBITMAP hBitmap;
    HDC memDC, hDC;
    INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;
    COLORREF color_transp;

    hWnd     = (HWND) hb_parnl (1);
    x1       = (INT)  hb_parni (2);
    y1       = (INT)  hb_parni (3);
    Width1   = (INT)  hb_parni (4);
    Height1  = (INT)  hb_parni (5);
   
    hBitmap    = (HBITMAP) hb_parnl (6);
    x2         = (INT)     hb_parni (7);
    y2         = (INT)     hb_parni (8);
    Width2     = (INT)     hb_parni (9);
    Height2    = (INT)     hb_parni (10);
   
    color_transp  = (COLORREF) hb_parnl (11);

    modo_stretch          = (INT) hb_parni (12);

    hDC = bmp_GetDC (hWnd);
    
    memDC = CreateCompatibleDC(hDC);              
    SelectObject(memDC, hBitmap);
              
    if (modo_stretch == BMP_SCALE)
    {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	   else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
    }   
                
    TransparentBlt (hDC, x1, y1, Width1, Height1, memDC, x2, y2, Width2, Height2, color_transp);                                                         
        
    DeleteDC(memDC);     
    bmp_ReleaseDC(hWnd, hDC);   
}


//**********************************************************************************************************************
//* BMP_PUTSCREEN_ALPHABLEND (hWnd, x1, y1, Width1, Height1, hBitmap, x2, y2, Width2, Height2, Alpha, modo_stretch)
//**********************************************************************************************************************

HB_FUNC (BMP_PUTSCREEN_ALPHABLEND)
{
   HWND hWnd;
   HBITMAP hBitmap;
   HDC hDC, memDC;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;
   BLENDFUNCTION blend;
   BYTE Alpha;

   hWnd       = (HWND) hb_parnl (1);
   x1         = (INT)  hb_parni (2);
   y1         = (INT)  hb_parni (3);
   Width1     = (INT)  hb_parni (4);
   Height1    = (INT)  hb_parni (5);
   
   hBitmap    = (HBITMAP)hb_parnl (6);
   x2         = (INT) hb_parni (7);
   y2         = (INT) hb_parni (8);
   Width2     = (INT) hb_parni (9);
   Height2    = (INT) hb_parni (10);
   
   Alpha      = (BYTE) hb_parni (11);
   
   modo_stretch  = (INT) hb_parni (12);
   
   
   blend.BlendOp = AC_SRC_OVER;
   blend.BlendFlags = 0;
   blend.AlphaFormat = 0;
   blend.SourceConstantAlpha = Alpha; 

   hDC = bmp_GetDC (hWnd);
         
   memDC = CreateCompatibleDC(NULL);   
   SelectObject(memDC, hBitmap);
   
   if (modo_stretch == BMP_SCALE)
   {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	  else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
   }   

   AlphaBlend (hDC, x1, y1, Width1, Height1, memDC, x2, y2, Width2, Height2, blend);   
   
   DeleteDC(memDC);     
   bmp_ReleaseDC(hWnd, hDC);  
}


//*************************************************************************************************
//* BMP_GETSCREEN_BITBLT (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2)
//*************************************************************************************************

HB_FUNC (BMP_GETSCREEN_BITBLT)
{
    HWND hWnd;
    HBITMAP hBitmap;
    HDC memDC, hDC;
    INT x1, y1, Width1, Height1;
    INT x2, y2;
    
    hBitmap   = (HBITMAP) hb_parnl (1);
    x1        = (INT)     hb_parni (2);
    y1        = (INT)     hb_parni (3);
    Width1    = (INT)     hb_parni (4);
    Height1   = (INT)     hb_parni (5);
    
    hWnd      = (HWND)    hb_parnl (6);
    x2        = (INT)     hb_parni (7);
    y2        = (INT)     hb_parni (8);
    
    hDC = bmp_GetDC (hWnd);
        memDC = CreateCompatibleDC(hDC);              
              SelectObject(memDC, hBitmap);                
              BitBlt(memDC, x1, y1, Width1, Height1, hDC, x2, y2, SRCCOPY);                                                         
        DeleteDC(memDC);     
    bmp_ReleaseDC(hWnd, hDC);   
}


//***********************************************************************************************************************
//* BMP_GETSCREEN_STRETCHBLT (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2, Width2, Height2, modo_stretch)
//***********************************************************************************************************************

HB_FUNC (BMP_GETSCREEN_STRETCHBLT)
{  
   HWND hWnd; 
   HDC hDC, memDC;
   HBITMAP hBitmap;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;


   hBitmap    = (HBITMAP)hb_parnl (1);
   x1         = (INT)    hb_parni (2);
   y1         = (INT)    hb_parni (3);
   Width1     = (INT)    hb_parni (4);
   Height1    = (INT)    hb_parni (5);
   
   hWnd       = (HWND) hb_parnl (6);
   x2         = (INT)  hb_parni (7);
   y2         = (INT)  hb_parni (8);
   Width2     = (INT)  hb_parni (9);
   Height2    = (INT)  hb_parni (10);
   
   modo_stretch  = (INT) hb_parnl (11);
 

   hDC = bmp_GetDC (hWnd);
   
   memDC = CreateCompatibleDC(NULL);   
   SelectObject(memDC, hBitmap);
   
   if (modo_stretch == BMP_SCALE)
   {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	  else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
   }   
      
   StretchBlt(memDC, x1, y1, Width1, Height1, hDC, x2, y2, Width2, Height2, SRCCOPY); 
   
   DeleteDC(memDC);     
   bmp_ReleaseDC(hWnd, hDC);          
}


//**************************************************************************************************************************
//* BMP_GETSCREEN_TRANSPARENTBLT (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2, Width2, Height2, color_transp, modo_stretch)
//**************************************************************************************************************************

HB_FUNC (BMP_GETSCREEN_TRANSPARENTBLT)
{
    HWND hWnd;
    HBITMAP hBitmap;
    HDC memDC, hDC;
    INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;
    COLORREF color_transp;

    hBitmap  = (HBITMAP) hb_parnl (1);
    x1       = (INT)     hb_parni (2);
    y1       = (INT)     hb_parni (3);
    Width1   = (INT)     hb_parni (4);
    Height1  = (INT)     hb_parni (5);
   
    hWnd     = (HWND) hb_parnl (6);
    x2       = (INT)  hb_parni (7);
    y2       = (INT)  hb_parni (8);
    Width2   = (INT)  hb_parni (9);
    Height2  = (INT)  hb_parni (10);
   
    color_transp  = (COLORREF) hb_parnl (11);

    modo_stretch  = (INT) hb_parni (12);

    hDC = bmp_GetDC (hWnd);
    
    memDC = CreateCompatibleDC(hDC);              
    SelectObject(memDC, hBitmap);
              
    if (modo_stretch == BMP_SCALE)
    {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	   else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
    }   
                
    TransparentBlt (memDC, x1, y1, Width1, Height1, hDC, x2, y2, Width2, Height2, color_transp);                                                         
        
    DeleteDC(memDC);     
    bmp_ReleaseDC(hWnd, hDC);   
}


//**********************************************************************************************************************
//* BMP_GETSCREEN_ALPHABLEND (hBitmap, x1, y1, Width1, Height1, hWnd, x2, y2, Width2, Height2, Alpha, modo_stretch)
//**********************************************************************************************************************

HB_FUNC (BMP_GETSCREEN_ALPHABLEND)
{
   HWND hWnd;
   HBITMAP hBitmap;
   HDC hDC, memDC;
   INT x1, y1, Width1, Height1, x2, y2, Width2, Height2, modo_stretch;
   BLENDFUNCTION blend;
   BYTE Alpha;

   hBitmap    = (HBITMAP)hb_parnl (1);
   x1         = (INT)    hb_parni (2);
   y1         = (INT)    hb_parni (3);
   Width1     = (INT)    hb_parni (4);
   Height1    = (INT)    hb_parni (5);
   
   hWnd       = (HWND)   hb_parnl (6);
   x2         = (INT)    hb_parni (7);
   y2         = (INT)    hb_parni (8);
   Width2     = (INT)    hb_parni (9);
   Height2    = (INT)    hb_parni (10);
   
   Alpha      = (BYTE)   hb_parni (11);
   
   modo_stretch  = (INT) hb_parni (12);
   
   
   blend.BlendOp = AC_SRC_OVER;
   blend.BlendFlags = 0;
   blend.AlphaFormat = 0;
   blend.SourceConstantAlpha = Alpha; 

   hDC = bmp_GetDC (hWnd);
         
   memDC = CreateCompatibleDC(NULL);   
   SelectObject(memDC, hBitmap);
   
   if (modo_stretch == BMP_SCALE)
   {  if ((int) Width2 * Height1 / Height2 <= Width1)
	      Width1= (int) Width2 * Height1 / Height2;
	  else		
	      Height1 = (int) Height2 * Width1 / Width2;                 
   }   

   AlphaBlend (memDC, x1, y1, Width1, Height1, hDC, x2, y2, Width2, Height2, blend);   
   
   DeleteDC(memDC);     
   bmp_ReleaseDC(hWnd, hDC);  
}


//**************************************************************************************************
//* BMP_CLEAN (hBitmap, x, y, Width, Height, color_RGB)
//**************************************************************************************************
HB_FUNC (BMP_CLEAN)
{ 
   HDC memDC;
   HBITMAP hBitmap;
   INT x, y, Width, Height;
   COLORREF color_RGB;
   HBRUSH hBrush;
   RECT rectang;
   
   
   hBitmap    = (HBITMAP)  hb_parnl (1);
   x          = (INT)      hb_parnl (2);
   y          = (INT)      hb_parnl (3);
   Width      = (INT)      hb_parnl (4);
   Height     = (INT)      hb_parnl (5);
   color_RGB  = (COLORREF) hb_parnl (6);
        
   memDC = CreateCompatibleDC(NULL);     
      SelectObject(memDC, hBitmap);
      hBrush = CreateSolidBrush (color_RGB);
         SelectObject(memDC, hBrush);       
         SetRect  (&rectang, x, y, Width, Height);          
         FillRect (memDC, &rectang, hBrush);
      DeleteObject(hBrush);         
   DeleteDC(memDC);       
}


//**************************************************************************************************
//* BMP_GRAY (hBitmap, x, y, Width, Height, gray_level)       gray_level = 0 To 100%    
//**************************************************************************************************

#define BMP_GRAY_NONE 0
#define BMP_GRAY_FULL 100

HB_FUNC (BMP_GRAY)
{ 
   HDC memDC;
   HBITMAP hBitmap;
   INT x1, y1, Width, Height;
   register INT x, y;
   COLORREF old_RGB;
   INT gray, color_R, color_G, color_B;
   FLOAT gray_level;
   
   #define RGB_TO_GRAY(R,G,B) (INT)((float)R * 0.30 + (float)G * 0.55+ (float)B * 0.15)
   
   hBitmap    = (HBITMAP)  hb_parnl (1);
   x1         = (INT)      hb_parnl (2);
   y1         = (INT)      hb_parnl (3);
   Width      = (INT)      hb_parnl (4);
   Height     = (INT)      hb_parnl (5);
   gray_level = (FLOAT)    hb_parnl (6);
   
   if ((gray_level <= 0.0)||(gray_level > 100.0))
       return;
       
   gray_level = gray_level / 100.0;    
         
   memDC = CreateCompatibleDC(NULL);     
      SelectObject(memDC, hBitmap);
      
      for (y = y1; y < (y1 + Height); y++)
           for (x = x1; x < (x1 + Width); x++)
           {    old_RGB = GetPixel (memDC, x, y);
                color_R = GetRValue(old_RGB);
                color_G = GetGValue(old_RGB);
                color_B = GetBValue(old_RGB);
                gray = RGB_TO_GRAY (color_R, color_G, color_B);
                
                if (gray_level == 100.0)
                   SetPixel(memDC, x, y, RGB (gray, gray, gray));
                else
                {  color_R = color_R + (gray - color_R) * gray_level;
                   color_G = color_G + (gray - color_G) * gray_level;
                   color_B = color_B + (gray - color_B) * gray_level;                  
                   SetPixel(memDC, x, y, RGB (color_R, color_G, color_B));
                }   
           }
   DeleteDC(memDC);
}


//**************************************************************************************************
//* BMP_LIGHT (hBitmap, x, y, Width, Height, light_level)       light_level = -255 To +255    
//**************************************************************************************************

#define BMP_LIGHT_BLACK -255
#define BMP_LIGHT_NONE  0
#define BMP_LIGHT_WHITE 255

HB_FUNC (BMP_LIGHT)
{ 
   HDC memDC;
   HBITMAP hBitmap;
   INT x1, y1, Width, Height;
   register INT x, y;
   COLORREF old_RGB;
   INT color_R, color_G, color_B, light_level;
   
      
   hBitmap     = (HBITMAP)  hb_parnl (1);
   x1          = (INT)      hb_parnl (2);
   y1          = (INT)      hb_parnl (3);
   Width       = (INT)      hb_parnl (4);
   Height      = (INT)      hb_parnl (5);
   light_level = (INT)      hb_parnl (6);
   
   if ((light_level < -255)|| (light_level == 0) ||(light_level > 255))
       return;
           
         
   memDC = CreateCompatibleDC(NULL);     
      SelectObject(memDC, hBitmap);
      
      for (y = y1; y < (y1 + Height); y++)
           for (x = x1; x < (x1 + Width); x++)
           {    old_RGB = GetPixel (memDC, x, y);
                
                color_R = GetRValue(old_RGB) + light_level;
                color_G = GetGValue(old_RGB) + light_level;
                color_B = GetBValue(old_RGB) + light_level;
                
                if (color_R < 0) color_R = 0;
                if (color_G < 0) color_G = 0;
                if (color_B < 0) color_B = 0;
               
                if (color_R > 255) color_R = 255;
                if (color_G > 255) color_G = 255;
                if (color_B > 255) color_B = 255;
 
                SetPixel(memDC, x, y, RGB (color_R, color_G, color_B));                   
           }
   DeleteDC(memDC);
}


//**************************************************************************************************
//* BMP_CHANGUE_COLOR (hBitmap, x, y, Width, Height, old_RGB, new_RGB)
//**************************************************************************************************
HB_FUNC (BMP_CHANGUE_COLOR)
{ 
   HDC memDC;
   HBITMAP hBitmap;
   register INT x, y;
   INT x1, y1, Width, Height;
   COLORREF old_RGB, new_RGB;
   
   hBitmap = (HBITMAP)  hb_parnl (1);
   x1       = (INT)     hb_parnl (2);
   y1       = (INT)     hb_parnl (3);
   Width    = (INT)     hb_parnl (4);
   Height   = (INT)     hb_parnl (5);
   old_RGB = (COLORREF) hb_parnl (6);
   new_RGB = (COLORREF) hb_parnl (7);
   
     
   memDC = CreateCompatibleDC(NULL);     
      SelectObject(memDC, hBitmap);
      
      for (y = y1; y < (y1 + Height); y++)
        for (x = x1; x < (x1 + Width); x++)
        {    if (GetPixel(memDC, x, y) == old_RGB)
                    SetPixel(memDC, x, y, new_RGB);
        }
   DeleteDC(memDC);
}


//**************************************************************************************************
//* BMP_CHANGUE_COLOR_DIST (hBitmap, x, y, Width, Height, RGB_Color, new_RGB, Dist, Comp)
//**************************************************************************************************

#define BMP_CHANGUE_COLOR_DIST_EQ 0    // DIST() == Dist  ---> (equal)
#define BMP_CHANGUE_COLOR_DIST_LE 1    // DIST() <= Dist  ---> (less or equal)
#define BMP_CHANGUE_COLOR_DIST_GE 2    // DIST() >= Dist  ---> (great or equal)


HB_FUNC (BMP_CHANGUE_COLOR_DIST)
{ 
   HDC memDC;
   HBITMAP hBitmap;
   register INT x, y;
   INT Dist, Comp, Dist_aux;
   INT x1, y1, Width, Height;
   COLORREF RGB_Color, new_RGB, old_RGB;

   #define DIST(R1,G1,B1,R2,G2,B2) (int)sqrt(pow((R1-R2), 2.0) + pow((G1-G2), 2.0) + pow((B1-B2), 2.0))    

   hBitmap    = (HBITMAP)  hb_parnl (1);
   x1         = (INT)      hb_parnl (2);
   y1         = (INT)      hb_parnl (3);
   Width      = (INT)      hb_parnl (4);
   Height     = (INT)      hb_parnl (5);

   RGB_Color  = (COLORREF) hb_parnl (6);
   new_RGB    = (COLORREF) hb_parnl (7);
   Dist       = (INT)      hb_parnl (8);
   Comp       = (INT)      hb_parnl (9);
   
     
   memDC = CreateCompatibleDC(NULL);     
      SelectObject(memDC, hBitmap);
      
      for (y = y1; y < (y1 + Height); y++)
        for (x = x1; x < (x1 + Width); x++)
           {    old_RGB = GetPixel(memDC, x, y);
                Dist_aux = DIST (GetRValue(old_RGB),GetGValue(old_RGB),GetBValue(old_RGB), GetRValue(RGB_Color),GetGValue(RGB_Color),GetBValue(RGB_Color));
                
                if (Comp == BMP_CHANGUE_COLOR_DIST_EQ && Dist_aux == Dist)
                    SetPixel(memDC, x, y, new_RGB);
                
                if (Comp == BMP_CHANGUE_COLOR_DIST_LE && Dist_aux <= Dist)
                    SetPixel(memDC, x, y, new_RGB);

                if (Comp == BMP_CHANGUE_COLOR_DIST_GE && Dist_aux >= Dist)
                    SetPixel(memDC, x, y, new_RGB);
           }
   DeleteDC(memDC);
}


//*********************************************************************************************
//* BMP_TEXTOUT (hBitmap, x, y, Text, FontName, FontSize, Text_Color, Back_color, Type, Align)
//*********************************************************************************************

#define BMP_TEXTOUT_OPAQUE      0
#define BMP_TEXTOUT_TRANSPARENT 1

#define BMP_TEXTOUT_BOLD        2
#define BMP_TEXTOUT_ITALIC      4
#define BMP_TEXTOUT_UNDERLINE   8
#define BMP_TEXTOUT_STRIKEOUT   16

#define BMP_TEXTOUT_LEFT        0
#define BMP_TEXTOUT_CENTER      1
#define BMP_TEXTOUT_RIGHT       2

HB_FUNC (BMP_TEXTOUT)
{
   HBITMAP hBitmap;
   HDC memDC;
   HFONT hFont;
   const char *Text, *FontName;
   int FontSize;
   int x, y;
   COLORREF Text_Color, Back_Color;
   int Type, Align;

   INT Bold = FW_NORMAL;
   INT Italic = 0, Underline = 0, StrikeOut = 0;


   hBitmap     = (HBITMAP) hb_parnl  (1);
   x           = hb_parni (2);
   y           = hb_parni (3);
   Text        = hb_parcx (4);
   FontName    = hb_parcx (5);
   FontSize    = (INT) hb_parni (6);
   Text_Color  = (COLORREF) hb_parnl  (7);
   Back_Color  = (COLORREF) hb_parnl  (8);
   Type        = (INT) hb_parni  (9);
   Align       = (INT) hb_parni  (10);

   memDC = CreateCompatibleDC(NULL);              
   SelectObject(memDC, hBitmap);
   
   if ((Type & BMP_TEXTOUT_TRANSPARENT) == BMP_TEXTOUT_TRANSPARENT)
       SetBkMode(memDC, TRANSPARENT);
   else    
       SetBkColor(memDC, Back_Color);
   
   if ((Type & BMP_TEXTOUT_BOLD) == BMP_TEXTOUT_BOLD)
       Bold = FW_BOLD;
   
   if ((Type & BMP_TEXTOUT_ITALIC) == BMP_TEXTOUT_ITALIC)    
       Italic = 1;
   
   if ((Type & BMP_TEXTOUT_UNDERLINE) == BMP_TEXTOUT_UNDERLINE)       
       Underline = 1;
       
   if ((Type & BMP_TEXTOUT_STRIKEOUT) == BMP_TEXTOUT_STRIKEOUT)    
       StrikeOut = 1;
      
   FontSize = FontSize * GetDeviceCaps (memDC, LOGPIXELSY) / 72;
	
   hFont = CreateFont (0-FontSize, 0, 0, 0, Bold, Italic, Underline, StrikeOut,
		   DEFAULT_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, FF_DONTCARE, FontName);
  
   SelectObject (memDC, hFont);
   
   if ((Align & BMP_TEXTOUT_CENTER) == BMP_TEXTOUT_CENTER)
        SetTextAlign (memDC, TA_CENTER);   

   if ((Align & BMP_TEXTOUT_RIGHT) == BMP_TEXTOUT_RIGHT)
        SetTextAlign (memDC, TA_RIGHT);   
      
   SetTextColor(memDC, Text_Color);       
   TextOut(memDC, x, y, Text, lstrlen(Text));

   DeleteObject (hFont);
   DeleteDC(memDC);   
}


//******************************************************************************
//* WIN_GETCURSOR_POS (hWnd) ---> Return {x,y}
//******************************************************************************

HB_FUNC (WIN_GETCURSOR_POS)
{  
   POINT punto;
   HWND hWnd;
   
   hWnd = (HWND) hb_parnl (1);
   punto.x = 0;
   punto.y = 0;
   
   GetCursorPos(&punto); 
   ScreenToClient(hWnd, &punto);
   
   hb_reta (2);
   hb_storvnl ((LONG) punto.x, -1, 1);
   hb_storvnl ((LONG) punto.y, -1, 2);
}   


//******************************************************************************
//* WIN_SETCURSOR_POS (hWnd, x , y)
//******************************************************************************

HB_FUNC (WIN_SETCURSOR_POS)
{  
   POINT punto;
   HWND hWnd;
   
   hWnd = (HWND) hb_parnl (1);
   punto.x = hb_parnl (2);
   punto.y = hb_parnl (3);
    
   ClientToScreen (hWnd, &punto);
   SetCursorPos (punto.x, punto.y);
}   


//******************************************************************************
//* WIN_GET_CLIENT_RECT (hWnd) ---> Return {Width, Height}
//******************************************************************************

HB_FUNC (WIN_GET_CLIENT_RECT)
{  
   HWND hWnd;
   RECT rect;
   
   hWnd = (HWND) hb_parnl (1);
   
   if (hWnd != 0)  
       GetClientRect(hWnd, &rect);
   else
   {   
       rect.right  = GetSystemMetrics (SM_CXSCREEN);
       rect.bottom = GetSystemMetrics (SM_CYSCREEN);
   }        

   hb_reta (2);
   hb_storvnl ((LONG) rect.right, -1, 1);
   hb_storvnl ((LONG) rect.bottom, -1, 2);
}   


//*****************************************************************************
//* GDI_GET_PIXEL (hWND, x, y) ---> Return {R,G,B}
//*****************************************************************************
HB_FUNC (GDI_GET_PIXEL)
{  
   HWND hWnd;
   HDC hDC;
   COLORREF color;
   int x,y;
       
   hWnd = (HWND) hb_parnl (1);
   x    = hb_parni(2);
   y    = hb_parni(3);
   
   hDC = bmp_GetDC (hWnd);
     color = GetPixel( hDC, x, y);
   bmp_ReleaseDC (hWnd, hDC);
   
   hb_reta( 3 );
   hb_storvni((int) GetRValue(color), -1, 1 );
   hb_storvni((int) GetGValue(color), -1, 2);
   hb_storvni((int) GetBValue(color), -1, 3);
}


//**********************************************************************************
//* GDI_SET_PIXEL (hWND, x, y, Color_RGB)
//**********************************************************************************
HB_FUNC (GDI_SET_PIXEL)
{  
   HWND hWnd;
   HDC hDC;
   int x,y;
   COLORREF color_RGB;
       
   hWnd       = (HWND) hb_parnl (1);
   x          = hb_parni(2);
   y          = hb_parni(3);
   color_RGB  = (COLORREF) hb_parnl (4);
      
   hDC = bmp_GetDC (hWnd);
       SetPixel( hDC, x, y, color_RGB);
   bmp_ReleaseDC (hWnd, hDC);
}

#pragma ENDDUMP
