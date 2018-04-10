/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Static FreeImage usage
 * (c) 2012 Vladimir Chumachenko <ChVolodymyr@yandex.ru>
 *
 * Revised by Grigory Filatov <gfilatov@inbox.ru>
*/

#include "FreeImage.ch"
#include "MiniGUI.ch"


// ������� ������ ����������� ����� ������������� �������

// ���������� ������� ����������� �� �����

#define FI_TOP               30
#define FI_LEFT              30
#define FI_BOTTOM           455
#define FI_RIGHT            380

#define FI_WIDTH            ( FI_RIGHT - FI_LEFT )
#define FI_HEIGHT           ( FI_BOTTOM - FI_TOP )

// ���������� ������� ����������� �� �������

#define RES_TOP             FI_TOP
#define RES_LEFT            ( FI_RIGHT + 50 )
#define RES_BOTTOM          FI_BOTTOM
#define RES_RIGHT           780

#define RES_WIDTH           ( RES_RIGHT - RES_LEFT )
#define RES_HEIGHT          ( RES_BOTTOM - RES_TOP )

// ����� �������� (������������ ������������ Demo.rc), ���� ����� ����������
// ���� � ��������� �� � ��������� ��������.

#define PNG_BIRD            'BIRD'
#define PNG_SEA             'SEA'
#define JPG_TOWN            'TOWN'
#define JPG_WATERFALL       'WATERFALL'


// ��� �����, ��� �������

Static cFileImg 
Static cResImg


/******
*
*       ����� ������� �� ����� � �������
*
*/

Procedure Main

FI_Initialise()

Set font to 'Tahoma', 9

Define window wMain                 ;
       At 0, 0                      ;
       Width 810                    ;
       Height 525                   ;
       Title 'FreeImage Demo'       ;
       NoMaximize                   ;
       NoSize                       ;
       Icon 'MAINICON'              ;
       Main                         ;
       BackColor WHITE              ;
       On Init ( OpenImgFile( GetStartupFolder() + "\Res\Bird.png" ), OpenImgRes( PNG_BIRD, 'PNG' ) ) ;
       On Release FI_DeInitialise() ;
       On Paint { || ShowFile(), ShowRes() }

  Define main menu

    Define Popup '&File'
      MenuItem '&Open'       Action OpenImgFile()
      Separator
      MenuItem 'E&xit Alt+X' Action ReleaseAllWindows()
    End Popup

    // !!! ��� ������ ���� ������� � ������ ���������������� �������

    Define Popup '&Resourse'
      MenuItem 'Bird      (png)' Action OpenImgRes( PNG_BIRD     , 'PNG' )
      MenuItem 'Sea       (png)' Action OpenImgRes( PNG_SEA      , 'PNG' )
      MenuItem 'Town      (jpg)' Action OpenImgRes( JPG_TOWN     , 'JPG' )
      MenuItem 'Waterfall (jpg)' Action OpenImgRes( JPG_WATERFALL, 'JPG' )
    End Popup

  End menu

  @ ( FI_TOP - 25 ), ( FI_LEFT - 25 ) Frame frmFile             ;
                                      Caption 'File'            ;
                                      Width ( FI_WIDTH   + 45 ) ;
                                      Height ( FI_HEIGHT + 45 ) ;
                                      BackColor WHITE

  @ ( RES_TOP - 25 ), ( RES_LEFT - 25 ) Frame frmResource          ;
                                        Caption 'Resource'         ;
                                        Width ( RES_WIDTH   + 45 ) ;
                                        Height ( RES_HEIGHT + 45 ) ;
                                        BackColor WHITE

End window

On Key Alt+X of wMain Action ReleaseAllWindows()

Center window wMain
Activate window wMain

Return

****** End of Main ******


/******
*
*       OpenImgFile()
*
*       ����� ����� ��� ��������
*
*/

Static Procedure OpenImgFile( cFile )

If Empty( cFile )
   cFile := GetFile( { { 'Image files (*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.psd;*.tif;*.ico)', ;
                            '*.bmp;*.jpg;*.jpeg;*.gif;*.png;*.psd;*.tif;*.ico'                ;
                          }                                                                   ;
                        }, 'Select image', GetCurrentFolder(), .F., .T. )
Endif

If !Empty( cFile )
   cFileImg := cFile
   wMain.frmFile.Caption := cFileNoPath( cFile )
   ShowFile()
Endif

Return

****** End of OpenImgFile ******


/******
*
*       ShowFile()
*
*       ����� ����������� �� �����
*
*/

Static Procedure ShowFile
Static nHandleFileImg
Local nTop         := FI_TOP   , ;
      nLeft        := FI_LEFT  , ;
      nBottom      := FI_BOTTOM, ;
      nRight       := FI_RIGHT , ;
      pps                      , ;
      hDC                      , ;
      nWidth                   , ;
      nHeight                  , ;
      nKoeff                   , ;
      nHandleClone

If !( nHandleFileImg == nil )
   FI_Unload( nHandleFileImg )
   nHandleFileImg := nil
Endif

If IsNil( cFileImg )
   Return
Else
   nHandleFileImg := FI_Load( FI_GetFileType( cFileImg ), cFileImg, 0 )  // �������� �������
Endif

InvalidateRect( Application.Handle, 1, FI_LEFT, FI_TOP, FI_RIGHT, FI_BOTTOM )

nWidth  := FI_GetWidth( nHandleFileImg )
nHeight := FI_GetHeight( nHandleFileImg )

If ( ( nHeight > FI_HEIGHT ) .or. ( nWidth > FI_WIDTH )  )

   If ( ( nHeight - FI_HEIGHT ) > ( nWidth - FI_WIDTH ) )
      nKoeff := ( FI_HEIGHT / nHeight )
   Else
      nKoeff := ( FI_WIDTH / nWidth )
   Endif
   
   nHeight := Round( ( nHeight * nKoeff ), 0 )
   nWidth  := Round( ( nWidth  * nKoeff ), 0 )
   
   nHandleClone := FI_Clone( nHandleFileImg )
   FI_Unload( nHandleFileImg )
   
   nHandleFileImg := FI_Rescale( nHandleClone, nWidth, nHeight, FILTER_BICUBIC )
   FI_Unload( nHandleClone )
   
Endif

If ( nWidth < FI_WIDTH )
   nLeft  += Int( ( FI_WIDTH - nWidth ) / 2 )
   nRight := ( nLeft + nWidth )
Endif

If ( nHeight < FI_HEIGHT )
   nTop    += Int( ( FI_HEIGHT - nHeight ) / 2 )
   nBottom := ( nTop + nHeight )
Endif

hDC := BeginPaint( Application.Handle, @pps )

FI_WinDraw( nHandleFileImg, hDC, nTop, nLeft, nBottom, nRight )

EndPaint( Application.Handle, pps )
ReleaseDC( Application.Handle, hDC )

Return

****** End of ShowFile ******


/******
*
*       OpenImgRes( cRes, cType )
*
*       �������� ������� �� �������
*
*/

Static Procedure OpenImgRes( cRes, cType )
Local cData := Win_LoadResource( cRes, cType )

If !Empty( cData )
   cResImg := cData
   wMain.frmResource.Caption := ( cRes + ' (' + cType + ')' )
   ShowRes()
Else
   MsgExclamation( cRes + ' not found.', 'Error' )
Endif

Return

****** End of OpenImgRes ******


/******
*
*       ShowRes()
*
*       ����� ������� �� ���������� (�������, ������������ � ������)
*
*/

Static Procedure ShowRes
Static nHandleResImg
Local nTop         := RES_TOP   , ;
      nLeft        := RES_LEFT  , ;
      nBottom      := RES_BOTTOM, ;
      nRight       := RES_RIGHT , ;
      pps                       , ;
      hDC                       , ;
      nWidth                    , ;
      nHeight                   , ;
      nKoeff                    , ;
      nHandleClone

If !( nHandleResImg == nil )
   FI_Unload( nHandleResImg )
   nHandleResImg := nil
Endif

If Empty( cResImg )
   Return
Else
   nHandleResImg := FI_LoadFromMemory( FI_GetFileTypeFromMemory( cResImg, Len( cResImg ) ), cResImg, 0 )
Endif

InvalidateRect( Application.Handle, 1, RES_LEFT, RES_TOP, RES_RIGHT, RES_BOTTOM )

nWidth  := FI_GetWidth( nHandleResImg )
nHeight := FI_GetHeight( nHandleResImg )

If ( ( nHeight > RES_HEIGHT ) .or. ( nWidth > RES_WIDTH )  )

   If ( ( nHeight - RES_HEIGHT ) > ( nWidth - RES_WIDTH ) )
      nKoeff := ( RES_HEIGHT / nHeight )
   Else
      nKoeff := ( RES_WIDTH / nWidth )
   Endif

   nHeight := Round( ( nHeight * nKoeff ), 0 )
   nWidth  := Round( ( nWidth  * nKoeff ), 0 )

   nHandleClone := FI_Clone( nHandleResImg )
   FI_Unload( nHandleResImg )

   nHandleResImg := FI_Rescale( nHandleClone, nWidth, nHeight, FILTER_BICUBIC )
   FI_Unload( nHandleClone )

Endif

If ( nWidth < FI_WIDTH )
   nLeft  += Int( ( FI_WIDTH - nWidth ) / 2 )
   nRight := ( nLeft + nWidth )
Endif

If ( nHeight < FI_HEIGHT )
   nTop    += Int( ( FI_HEIGHT - nHeight ) / 2 )
   nBottom := ( nTop + nHeight )
Endif

hDC := BeginPaint( Application.Handle, @pps )

FI_WinDraw( nHandleResImg, hDC, nTop, nLeft, nBottom, nRight )

EndPaint( Application.Handle, pps )
ReleaseDC( Application.Handle, hDC )

Return

****** End of ShowRes ******
