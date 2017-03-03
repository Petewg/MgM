
****************************************************************************************************************
* PROGRAMA:	BITMAP.CH
* LENGUAJE:	HARBOUR-MINIGUI
* FECHA:	12 JUNIO 2010
* AUTOR:	Dr. CLAUDIO SOTO SILVA
* PAIS:		URUGUAY
* E-MAIL:	srvet@adinet.com.uy
****************************************************************************************************************



****************************************************************************************************************
* MACRO definition   
****************************************************************************************************************

#define ArrayRGB_TO_COLORREF(aRGB)  RGB(aRGB[1],aRGB[2],aRGB[3])

#define RGB_TO_GRAY(R,G,B) INT(R*0.30 + G*0.55 + B*0.15)

#define COLOR_DIST(R1,G1,B1,R2,G2,B2) INT(sqrt((R1-R2)^2 + (G1-G2)^2 + (B1-B2)^2)) 

#define IS_POINT_IN_RECT(Mx,My,x,y,W,H) ((Mx >= x).AND.(Mx <= x + W).AND.(My >= y).AND.(My <= y + H))  

#define BMP_DESKTOP_hWND 0


**********************************************************************************
* BMP constant definition   
**********************************************************************************

// BMP_Get_Info()
#define BMP_INFO_WIDTH     0
#define BMP_INFO_HEIGHT    1
#define BMP_INFO_BITSPIXEL 2


//  BMP_Transform ()
//           MODO                         ANGLE                       COLOR_FILL                
#define BMP_REFLECT_HORIZONTAL 1   //     Not use                     Not use
#define BMP_REFLECT_VERTICAL   2   //     Not use                     Not use
#define BMP_ROTATE             4   //     Angle (0 to 360 degree)     Color fill blank space


//  BMP_IsPoint_In_Sprite ()  
//  BMP_Is_Intersect_Sprite ()
#define BMP_OPAQUE       0 
#define BMP_TRANSPARENT  1


//                                                       _x_ ---> _Copy_, _PutScreen_, _GetScreen_ 
#define BMP_SCALE   0   // BMP_SHOW(),  BMP_Resize(), BMP_x_StretchBlt(), BMP_x_TransparentBlt(), BMP_x_AlphaBlend()
#define BMP_STRETCH 1   // BMP_SHOW(),  BMP_Resize(), BMP_x_StretchBlt(), BMP_x_TransparentBlt(), BMP_x_AlphaBlend()
#define BMP_COPY    3   // BMP_SHOW() 


//BMP_Gray ()       gray_level = 0 To 100%    
#define BMP_GRAY_NONE 0
#define BMP_GRAY_FULL 100


// BMP_Light ()    light_level = -255 To +255
#define BMP_LIGHT_BLACK -255
#define BMP_LIGHT_NONE  0
#define BMP_LIGHT_WHITE 255


// BMP_Changue_Color_Dist()
#define BMP_CHANGUE_COLOR_DIST_EQ 0    // DIST() == Dist  ---> (equal)
#define BMP_CHANGUE_COLOR_DIST_LE 1    // DIST() <= Dist  ---> (less or equal)
#define BMP_CHANGUE_COLOR_DIST_GE 2    // DIST() >= Dist  ---> (great or equal)


// BMP_TextOut()
#define BMP_TEXTOUT_OPAQUE      0
#define BMP_TEXTOUT_TRANSPARENT 1

#define BMP_TEXTOUT_BOLD        2
#define BMP_TEXTOUT_ITALIC      4
#define BMP_TEXTOUT_UNDERLINE   8
#define BMP_TEXTOUT_STRIKEOUT   16

#define BMP_TEXTOUT_LEFT        0
#define BMP_TEXTOUT_CENTER      1
#define BMP_TEXTOUT_RIGHT       2


