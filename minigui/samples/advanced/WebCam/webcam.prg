/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2011 Grigory Filatov <gfilatov@inbox.ru>
*/

#include <minigui.ch>

#define WS_CHILD     0x40000000
#define WS_VISIBLE   0x10000000

Static CamSource     // used to identify the video source
Static hWnd          // used as a window handle

*------------------------------------------------------------------------------*
Procedure Main()
*------------------------------------------------------------------------------*

  LOAD WINDOW webcam

  ON KEY ESCAPE OF webcam ACTION ThisWindow.Release

  CENTER WINDOW webcam

  ACTIVATE WINDOW webcam

Return

*------------------------------------------------------------------------------*
Procedure OnFormLoad()
*------------------------------------------------------------------------------*

cameraSource()

webcam.Button_5.Enabled := .F.
webcam.Button_4.Enabled := .F.
webcam.Button_1.Enabled := .F.
webcam.Button_2.Enabled := .F.
webcam.Button_3.Enabled := .F.

Return

*------------------------------------------------------------------------------*
Procedure OnFormUnLoad()
*------------------------------------------------------------------------------*

If !Empty(hWnd)
   capDriverDisconnect(hWnd)
   DestroyWindow(hWnd)
EndIf
If File("C:\CAPTURE.AVI")
   Ferase("C:\CAPTURE.AVI")
EndIf

Return

*------------------------------------------------------------------------------*
Procedure StartClick()
*------------------------------------------------------------------------------*

If !ISNIL(CamSource)
   webcam.Label_0.Visible := .F.

   previewCamera()

   webcam.Button_1.Enabled := .T.
   webcam.Button_4.Enabled := .F.
   webcam.Button_2.Enabled := .T.
   webcam.Button_5.Enabled := .T.
EndIf

Return

*------------------------------------------------------------------------------*
Procedure cameraSource()
*------------------------------------------------------------------------------*
Local i
Local cDriverName := Space(128)
Local cDriverVersion := Space(128)

For i := 0 To 9
   If capGetDriverDescription(i, @cDriverName, 128, @cDriverVersion, 128)
      webcam.Combo_1.AddItem(cDriverName)
   EndIf
Next

If webcam.Combo_1.ItemCount <> 0
   webcam.Combo_1.Value := 1
   CamSource := webcam.Combo_1.Value - 1
Else
   webcam.Label_0.Visible := .F.
   webcam.Combo_1.AddItem("No capture devices found")
   webcam.Combo_1.Value := 1
EndIf

Return

*------------------------------------------------------------------------------*
Procedure previewCamera()
*------------------------------------------------------------------------------*
Local i := 0
Local nMaxAttempt := 10
Local lConnect

webcam.Image_1.Visible := .F.

hWnd := capCreateCaptureWindow("WebCam", hb_bitOr(WS_CHILD, WS_VISIBLE), ;
   webcam.Image_1.Col, webcam.Image_1.Row, webcam.Image_1.Width, webcam.Image_1.Height, ;
   GetFormHandle("webcam"), 1)

REPEAT
   lConnect := capDriverConnect(hWnd, CamSource)
UNTIL !lConnect .Or. ++i > nMaxAttempt

If lConnect
   // set the preview scale
   capPreviewScale(hWnd, .T.)
   // set the preview rate (ms)
   capPreviewRate(hWnd, 30)
   // start previewing the image
   capPreview(hWnd, .T.)
Else
   // error connecting to video source
   DestroyWindow(hWnd)
   hWnd := 0
EndIf

Return

*------------------------------------------------------------------------------*
Procedure stopPreviewCamera()
*------------------------------------------------------------------------------*

capDriverDisconnect(hWnd)
DestroyWindow(hWnd)

webcam.Image_1.Visible := .T.

Return

*------------------------------------------------------------------------------*
Procedure Button1_Click()  // stop preview
*------------------------------------------------------------------------------*

stopPreviewCamera()

webcam.Button_5.Enabled := .F.
webcam.Button_4.Enabled := .T.
webcam.Button_1.Enabled := .F.

Return

*------------------------------------------------------------------------------*
Procedure Button2_Click()  // recording
*------------------------------------------------------------------------------*
 
webcam.Button_3.Enabled := .T.
webcam.Button_2.Enabled := .F.

capCaptureSequence(hWnd)

Return

*------------------------------------------------------------------------------*
Procedure Button3_Click()  // stop recording and ask to save video
*------------------------------------------------------------------------------*
Local cSaveName

If MsgYesNo("Do you want to save your recording video?", "Recording Video")
   cSaveName := Putfile( {{"Avi files (*.avi)","*.avi"}}, "Save Video As", "C:\", .f., "RecordedVideo" )
   If !Empty(cSaveName)
      capFileSaveAs(hWnd, cSaveName)
   EndIf
EndIf

webcam.Button_2.Enabled := .T.
webcam.Button_3.Enabled := .F.

Return

*------------------------------------------------------------------------------*
Procedure Button4_Click()  // preview
*------------------------------------------------------------------------------*
 
CamSource := webcam.Combo_1.Value - 1

previewCamera()

webcam.Button_5.Enabled := .T.
webcam.Button_4.Enabled := .F.
webcam.Button_1.Enabled := .T.

Return


*------------------------------------------------------------------------------*
Procedure Button5_Click()  // save image
*------------------------------------------------------------------------------*
 
Local cSaveName

If MsgYesNo("Do you want to save current picture?", "Save Image")
   cSaveName := Putfile( {{"Bmp files (*.bmp)","*.bmp"}}, "Save Image As", "C:\", .f., "Image" )
   If !Empty(cSaveName)
      capFileSaveDIB(hWnd, cSaveName)
   EndIf
EndIf

Return


#pragma BEGINDUMP

#include <hbapi.h>
#include <windows.h>
#include <vfw.h>

#if defined( __BORLANDC__ )
#pragma warn -use /* unused var */
#endif

HB_FUNC( CAPGETDRIVERDESCRIPTION )
{
 TCHAR lpszName[128];
 int iName = hb_parni(3);
 TCHAR lpszVer[128];
 int iVer = hb_parni(5);
 BOOL bRet;

 bRet = capGetDriverDescription( (WORD) hb_parnl(1), lpszName, iName, lpszVer, iVer );

 hb_storc( lpszName, 2 );
 hb_storc( lpszVer, 4 );

 hb_retl( bRet );
}

HB_FUNC( CAPCREATECAPTUREWINDOW )
{
 hb_retnl( (LONG) capCreateCaptureWindow( (LPCSTR) hb_parc(1),
                                          (DWORD) hb_parnl(2),
                                          hb_parni(3), hb_parni(4),
                                          hb_parni(5), hb_parni(6),
                                          (HWND) hb_parnl(7),
                                          hb_parni(8) ) );
}

HB_FUNC( CAPDRIVERCONNECT )
{
 hb_retl( capDriverConnect( (HWND) hb_parnl(1), hb_parni(2) ) );
}

HB_FUNC( CAPDRIVERDISCONNECT )
{
 hb_retl( capDriverDisconnect( (HWND) hb_parnl(1) ) );
}

HB_FUNC( CAPPREVIEWRATE )
{
 hb_retl( capPreviewRate( (HWND) hb_parnl(1), (WORD) hb_parnl(2) ) );
}

HB_FUNC( CAPPREVIEWSCALE )
{
 hb_retl( capPreviewScale( (HWND) hb_parnl(1), hb_parl(2) ) );
}

HB_FUNC( CAPPREVIEW )
{
 hb_retl( capPreview( (HWND) hb_parnl(1), hb_parl(2) ) );
}

HB_FUNC( CAPCAPTURESEQUENCE )
{
 hb_retl( capCaptureSequence( (HWND) hb_parnl(1) ) );
}

HB_FUNC( CAPFILESAVEAS )
{
 hb_retl( capFileSaveAs( (HWND) hb_parnl(1), hb_parc(2) ) );
}

HB_FUNC( CAPFILESAVEDIB )
{
 hb_retl( capFileSaveDIB( (HWND) hb_parnl(1), hb_parc(2) ) );
}

#pragma ENDDUMP
