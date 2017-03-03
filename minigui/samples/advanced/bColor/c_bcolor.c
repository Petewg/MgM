#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

#define HB_STORNI( n, x, y ) hb_storvni( n, x, y )

/*                             ++         +           ''          -           --         ---  B.G.R  */
static DWORD rgb_YL[6]={ 0x00CCFFFF, 0x0099FFFF, 0x0066FFFF, 0x0033FFFF, 0x0000FFFF, 0x0000CCCC };
static DWORD rgb_Y[6] ={ 0x0066CCFF, 0x0000CCFF, 0x0033CCFF, 0x000099CC, 0x003399CC, 0x00006699 };

static DWORD rgb_H[6] ={ 0x000099FF, 0x003399FF, 0x006699CC, 0x000066CC, 0x00336699, 0x00003366 };
static DWORD rgb_HR[6]={ 0x0099CCFF, 0x006699FF, 0x000066FF, 0x003366CC, 0x00003399, 0x00000066 };

static DWORD rgb_RH[6]={ 0x003366FF, 0x000033CC, 0x000033FF, 0x000000FF, 0x000000CC, 0x00000099 };
static DWORD rgb_R[6] ={ 0x00CCCCFF, 0x009999FF, 0x006666FF, 0x003333FF, 0x003300FF, 0x003300CC };
static DWORD rgb_RD[6]={ 0x009999CC, 0x006666CC, 0x003333CC, 0x00333399, 0x00330099, 0x00000033 };
static DWORD rgb_RM[6]={ 0x009966FF, 0x006633FF, 0x006600FF, 0x006633CC, 0x00666699, 0x00333366 };

static DWORD rgb_MR[6]={ 0x00CC99FF, 0x009933FF, 0x009900FF, 0x006600CC, 0x00663399, 0x00330066 };
static DWORD rgb_M[6] ={ 0x00CC66FF, 0x00CC00FF, 0x00CC33FF, 0x009966CC, 0x009900CC, 0x00660099 };
static DWORD rgb_ML[6]={ 0x00FFCCFF, 0x00FF99FF, 0x00FF66FF, 0x00FF33FF, 0x00FF00FF, 0x009933CC };
static DWORD rgb_MV[6]={ 0x00CC99CC, 0x00CC66CC, 0x00CC00CC, 0x00CC33CC, 0x00990099, 0x00993399 };

static DWORD rgb_VM[6]={ 0x00FF66CC, 0x00FF33CC, 0x00FF00CC, 0x00CC0099, 0x00996699, 0x00660066 };
static DWORD rgb_V[6] ={ 0x00FF99CC, 0x00CC3399, 0x00FF3399, 0x00FF0099, 0x00990066, 0x00663366 };
static DWORD rgb_VD[6]={ 0x00CC6699, 0x00FF6699, 0x00CC0066, 0x00CC3366, 0x00993366, 0x00330033 };
static DWORD rgb_VB[6]={ 0x00FFCCCC, 0x00FF9999, 0x00FF3366, 0x00FF0066, 0x00990033, 0x00660033 };

static DWORD rgb_BD[6]={ 0x00CC9999, 0x00FF6666, 0x00CC6666, 0x00996666, 0x00993333, 0x00663333 };
static DWORD rgb_B[6] ={ 0x00FF3333, 0x00FF0033, 0x00CC0033, 0x00CC3333, 0x00990000, 0x00660000 };
static DWORD rgb_BC[6]={ 0x00FF9966, 0x00FF6633, 0x00FF0000, 0x00CC0000, 0x00CC3300, 0x00330000 };

static DWORD rgb_CD[6]={ 0x00FF6600, 0x00CC6600, 0x00CC6633, 0x00FF3300, 0x00993300, 0x00663300 };
static DWORD rgb_CL[6]={ 0x00FFCC99, 0x00FF9933, 0x00FF9900, 0x00CC9966, 0x00996633, 0x00996600 };
static DWORD rgb_C[6] ={ 0x00FFCC66, 0x00FFCC33, 0x00FFCC00, 0x00CC9933, 0x00CC9900, 0x00333300 };
static DWORD rgb_CG[6]={ 0x00CCCC99, 0x00CCCC66, 0x00999933, 0x00999966, 0x00666600, 0x00666633 };

static DWORD rgb_AC[6]={ 0x00FFFFCC, 0x00FFFF99, 0x00FFFF66, 0x00FFFF33, 0x00FFFF00, 0x00CCCC00 };
static DWORD rgb_A[6] ={ 0x00CCFF99, 0x00CCFF66, 0x00CCFF33, 0x00CCFF00, 0x00CCCC33, 0x00999900 };

static DWORD rgb_GA[6]={ 0x0099CC66, 0x0099CC33, 0x0099CC00, 0x00669933, 0x00669900, 0x00336600 };
static DWORD rgb_GL[6]={ 0x0099FF66, 0x0099FF33, 0x0099FF00, 0x0066CC33, 0x0066CC00, 0x00339900 };
static DWORD rgb_G[6] ={ 0x0099FF99, 0x0066FF66, 0x0066FF33, 0x0066FF00, 0x00339933, 0x00006600 };
static DWORD rgb_GF[6]={ 0x00CCFFCC, 0x0099CC99, 0x0066CC66, 0x00669966, 0x00336633, 0x00003300 };
static DWORD rgb_GG[6]={ 0x0033FF33, 0x0033FF00, 0x0000FF00, 0x0000CC00, 0x0033CC33, 0x0033CC00 };
static DWORD rgb_GN[6]={ 0x0000FF66, 0x0033FF66, 0x0000FF33, 0x0000CC33, 0x00009933, 0x00009900 };
static DWORD rgb_GD[6]={ 0x0099FFCC, 0x0066FF99, 0x0000CC66, 0x0033CC66, 0x00339966, 0x00006633 };
static DWORD rgb_GO[6]={ 0x0000FF99, 0x0033FF99, 0x0066CC99, 0x0000CC99, 0x0033CC99, 0x00009966 };

static DWORD rgb_OL[6]={ 0x0066FFCC, 0x0000FFCC, 0x0033FFCC, 0x0099CCCC, 0x00336666, 0x00003333 };
static DWORD rgb_O[6] ={ 0x0066CCCC, 0x0033CCCC, 0x00669999, 0x00339999, 0x00009999, 0x00006666 };

static DWORD rgb_W[6] ={ 0x00FFFFFF, 0x00CCCCCC, 0x00999999, 0x00666666, 0x00333333, 0x00000000 };

static DWORD rgb_Z[6] ={ 0x00D0BDF9, 0x00BBA4F2, 0x00AB88F2, 0x00875FE4, 0x007760AB, 0x00421F94 };

static DWORD rgb_ZB[6]={ 0x00EFD66D, 0x00EFD66D, 0x00EFCD3E, 0x00DFB203, 0x00A7902C, 0x00917601 };

static DWORD rgb_ZG[6]={ 0x00CCEDE1, 0x00CCEDE1, 0x00C0EDDC, 0x00A3DBC6, 0x0085A499, 0x00358E6D };

#define MAX_COLOR_RGB2 39

static char  *rgb_NAME[]={ 
/*  1 */   "YL Соломенный",
/*  2 */   "Y  Желтый",
/*  3 */   "H  Коричневый",
/*  4 */   "HR Коричнево красноватый", 
/*  5 */   "RH Красно коричневатый",
/*  6 */   "R  Красный",
/*  7 */   "RD Темно красный",
/*  8 */   "RM Красный с малиновым",
/*  9 */   "MR Малиново красный",
/* 10 */   "M  Малиновый",
/* 11 */   "ML Светло малиновый",
/* 12 */   "MV Малиновый с фиолетом",
/* 13 */   "VM Фиолетовый с малиновым",
/* 14 */   "V  Фиолетовый",
/* 15 */   "VD Темно фиолетовый",
/* 16 */   "VB Фиолетовый с голубым",
/* 17 */   "BD БлеклоГолубой но темный",
/* 18 */   "B  Синий",
/* 19 */   "BC Синий блеклый к бюрезе",
/* 20 */   "CD Темная берюза",
/* 21 */   "CL Блеклая берюза",
/* 22 */   "C  Берюза",
/* 23 */   "CG Берюза с зеленью",
/* 24 */   "AC Светлая берюза зеленоватая",
/* 25 */   "A  Морская волна",
/* 26 */   "GA Блеклая зелень",
/* 27 */   "GL Блеклая светлая зелень",
/* 28 */   "G  Зеленый",
/* 29 */   "GF Темно зеленый блеклый",
/* 30 */   "GG Изумруд",
/* 31 */   "GN Сероватая зелень",
/* 32 */   "GD Темноватая зелень",
/* 33 */   "GO Блеклая серая зелень",
/* 34 */   "OL Грязная зелень",
/* 35 */   "O  Оливки",
/* 36 */   "W  Черно белый",
/* 37 */   "Z  Зарплата",    
/* 38 */   "ZB Зарплата Голубая",
/* 39 */   "ZG Зарплата Зеленая" };

#define DEF_COLOR2  rgb_W[2]

HB_FUNC( BCOLOR2 )
{
  DWORD dwColor;
  BYTE *_RGB, ch;
  int i, k, n, j;
  char *c;
  char cc[3];

  dwColor = DEF_COLOR2;
  
  if( HB_ISNUM(1) ){
      n = hb_parni(1);

      if(n < 1 || n > MAX_COLOR_RGB2)  hb_retni( MAX_COLOR_RGB2 );
      else                             hb_retc( rgb_NAME[ (n-1) ] );

      return ;
  }

  if( HB_ISCHAR(1) ){

      c = (char *) hb_parc(1);
      k = hb_parclen(1);
      n = 3;
      j = 0;

      cc[0] = ' '; 
      cc[1] = ' ';
      cc[2] = 0;

      for(i=0;i<k;i++){
          ch = c[i];

          if( ch=='-') n += 1;
          else if( ch=='+') n -= 1;

          else if( ch != ' ' && j < 2) { cc[j] = ch; j++; }

      }

      n = (n < 0)? 0 : n;
      n = (n > 5)? 5 : n;

      switch( cc[0] )
      {
         case 'Y' :
                     switch( cc[1] ){
                            case 'L' : dwColor = rgb_YL[n]; break; 
                            case ' ' : dwColor = rgb_Y [n]; break;
                     }
                     break;

         case 'H' :
                     switch( cc[1] ){
                            case 'R' : dwColor = rgb_HR[n]; break;
                            case ' ' : dwColor = rgb_H [n]; break;
                     }
                     break;

         case 'R' :
                     switch( cc[1] ){
                            case 'H' : dwColor = rgb_RH[n]; break;
                            case 'D' : dwColor = rgb_RD[n]; break;
                            case 'M' : dwColor = rgb_RM[n]; break;
                            case ' ' : dwColor = rgb_R [n]; break;
                     }
                     break;

         case 'M' :
                     switch( cc[1] ){
                            case 'R' : dwColor = rgb_MR[n]; break; 
                            case 'L' : dwColor = rgb_ML[n]; break; 
                            case 'V' : dwColor = rgb_MV[n]; break; 
                            case ' ' : dwColor = rgb_M [n]; break; 
                     }
                     break;

         case 'V' :
                     switch( cc[1] ){
                            case 'M' : dwColor = rgb_VM[n]; break; 
                            case 'D' : dwColor = rgb_VD[n]; break; 
                            case 'B' : dwColor = rgb_VB[n]; break; 
                            case ' ' : dwColor = rgb_V [n]; break; 
                     }
                     break;

         case 'B' :
                     switch( cc[1] ){
                            case 'D' : dwColor = rgb_BD[n]; break; 
                            case 'C' : dwColor = rgb_BC[n]; break; 
                            case ' ' : dwColor = rgb_B [n]; break; 
                     }
                     break;

         case 'C' :
                     switch( cc[1] ){
                            case 'D' : dwColor = rgb_CD[n]; break; 
                            case 'L' : dwColor = rgb_CL[n]; break; 
                            case 'G' : dwColor = rgb_CG[n]; break; 
                            case ' ' : dwColor = rgb_C [n]; break; 
                     }
                     break;

         case 'A' :
                     
                     switch( cc[1] ){
                            case 'C' : dwColor = rgb_AC[n]; break; 
                            case ' ' : dwColor = rgb_A [n]; break; 
                     }
                     break;

         case 'G' :
                     switch( cc[1] ){
                            case 'A' : dwColor = rgb_GA[n]; break; 
                            case 'L' : dwColor = rgb_GL[n]; break; 
                            case 'F' : dwColor = rgb_GF[n]; break; 
                            case 'G' : dwColor = rgb_GG[n]; break; 
                            case 'N' : dwColor = rgb_GN[n]; break; 
                            case 'D' : dwColor = rgb_GD[n]; break; 
                            case 'O' : dwColor = rgb_GO[n]; break; 
                            case ' ' : dwColor = rgb_G [n]; break; 
                     }
                     break;

         case 'O' :
                     switch( cc[1] ){
                            case 'L' : dwColor = rgb_OL[n]; break; 
                            case ' ' : dwColor = rgb_O [n]; break; 
                     }
                     break;

         case 'W' :  dwColor = rgb_W[n];   break;  

         case 'Z' :  
                     switch( cc[1] ){
                            case 'G' : dwColor = rgb_ZG[n]; break; 
                            case 'B' : dwColor = rgb_ZB[n]; break; 
                            case ' ' : dwColor = rgb_Z [n]; break; 
                     }
                     break;
      }
  }

  _RGB = (BYTE *) &dwColor;

  hb_reta( 3 );
  HB_STORNI(  _RGB[0], -1, 1 );
  HB_STORNI(  _RGB[1], -1, 2 );
  HB_STORNI(  _RGB[2], -1, 3 ); 
}

static DWORD _RGB_N[5]={ 0x00B2AEAE,0x00A4A0A0,0x00808080,0x00595959,0x00000000 }; 
static DWORD _RGB_B[5]={ 0x00F9D4E2,0x00F0CAA6,0x00FF0000,0x00B30000,0x00800000 };
static DWORD _RGB_G[5]={ 0x00E5DCE5,0x00C0DCC0,0x0000FF00,0x0000B300,0x00008000 };
static DWORD _RGB_C[5]={ 0x00FFFFE5,0x00FFFFAA,0x00FFFF00,0x00B3B300,0x00808000 };
static DWORD _RGB_R[5]={ 0x00E5E5FF,0x009595FF,0x000000FF,0x000000B3,0x00000080 };
static DWORD _RGB_M[5]={ 0x00FFCCFF,0x00FFA4FF,0x00FF00FF,0x00CC00CC,0x00800080 };
static DWORD _RGB_Y[5]={ 0x00F0FBFF,0x00CCFBFF,0x0000FFFF,0x0000CCCC,0x00008080 };
static DWORD _RGB_W[5]={ 0x00FFFFFF,0x00F2F2F2,0x00C0C0C0,0x00BFBFBF,0x00A4A0A0 };

static DWORD _RGB_X[5]={ 0x00C8D7C8,0x00ADC2AD,0x0080A180,0x00759975,0x00608260 };

static DWORD _RGB_Z[5]={ 0x00C2ADED,0x00B296ED,0x009270DB,0x006032BE,0x0046248E };

#define  _RGB_DEFAULT  0x00000001

HB_FUNC( BCOLOR )
{
  DWORD dwColor = _RGB_DEFAULT;
  BYTE *_RGB;
  int i,k;
  char *c;

  if( HB_ISCHAR(1) ){
      c = (char *) hb_parc(1);
      k = hb_parclen(1);
      i = 2;

      if( k > 1 && c[1]=='-') i += 1;
      if( k > 1 && c[1]=='+') i -= 1;
      if( k > 2 && c[2]=='-') i += 1;
      if( k > 2 && c[2]=='+') i -= 1;

      switch( c[0] ){
            case 'N' :
            case 'n' :  dwColor = _RGB_N[i]; break;

            case 'B' :
            case 'b' :  dwColor = _RGB_B[i]; break;

            case 'G' :
            case 'g' :  dwColor = _RGB_G[i]; break;

            case 'C' :
            case 'c' :  dwColor = _RGB_C[i]; break;

            case 'R' :
            case 'r' :  dwColor = _RGB_R[i]; break;

            case 'M' :
            case 'm' :  dwColor = _RGB_M[i]; break;

            case 'Y' :
            case 'y' :  dwColor = _RGB_Y[i]; break;

            case 'W' :
            case 'w' :  dwColor = _RGB_W[i]; break;

            case 'X' :
            case 'x' :  dwColor = _RGB_X[i]; break;

            case 'Z' :
            case 'z' :  dwColor = _RGB_Z[i]; break;
      }   
  }

  _RGB = (BYTE *) &dwColor;

  hb_reta( 3 );
  HB_STORNI( _RGB[0], -1, 1 );
  HB_STORNI( _RGB[1], -1, 2 );
  HB_STORNI( _RGB[2], -1, 3 ); 
}

#pragma ENDDUMP
