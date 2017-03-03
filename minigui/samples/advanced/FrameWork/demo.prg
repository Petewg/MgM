/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Win32 Framework for SDI Applications
 * Copyright 2006-2014 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "hmg.ch"
#include "resource.h"

#define IDOK            1
#define CLR_DEFAULT     0xff000000

#define IDX_FILE_NEW    0
#define IDX_FILE_OPEN   1
#define IDX_FILE_SAVE   2
#define IDX_EDIT_CUT    3
#define IDX_EDIT_COPY   4
#define IDX_EDIT_PASTE  5
#define IDX_FILE_PRINT  6
#define IDX_HELP_ABOUT  7

#xtranslate GetResStr( <nID> )  =>  hb_LoadString( <nID> )

//-------------------------------------------------------------
PROCEDURE Main
//-------------------------------------------------------------
   LOCAL aDesk := GetDesktopArea()
   LOCAL nWidth  := aDesk[3] * 0.75
   LOCAL nHeight := aDesk[4] * 0.72

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH nWidth ;
      HEIGHT nHeight ;
      TITLE 'Frame Window' ;
      ICON ID_MAIN ;
      MAIN ;
      ON INIT ( _ExtDisableControl( 'Edit_1', 'Form_1' ), ResizeEdit() ) ;
      ON PAINT PaintChildWindow( GetControlHandle( 'Edit_1', 'Form_1' ), "Client Window" ) ;
      ON SIZE ResizeEdit() ;
      ON MAXIMIZE ResizeEdit()

   DEFINE MAIN MENU

   POPUP "&File"
      MENUITEM "New..." ACTION _dummy() MESSAGE GetResStr( ID_FILE_NEW )
      MENUITEM "&Open..." ACTION _dummy() MESSAGE GetResStr( ID_FILE_OPEN )
      MENUITEM "&Save" ACTION _dummy() MESSAGE GetResStr( ID_FILE_SAVE )
      MENUITEM "Save &As..." ACTION _dummy() MESSAGE GetResStr( ID_FILE_SAVEAS )
      SEPARATOR
      MENUITEM "&Print" ACTION _dummy() MESSAGE GetResStr( ID_FILE_PRINT )
      SEPARATOR
      MENUITEM "E&xit" ACTION ThisWindow.Release() MESSAGE GetResStr( ID_FILE_EXIT )
   END POPUP
   POPUP "&Edit"
      MENUITEM "Undo" ACTION _dummy() MESSAGE GetResStr( ID_EDIT_UNDO )
      MENUITEM "Redo" ACTION _dummy() MESSAGE GetResStr( ID_EDIT_REDO )
      SEPARATOR
      MENUITEM "Cu&t" ACTION _dummy() MESSAGE GetResStr( ID_EDIT_CUT )
      MENUITEM "&Copy" ACTION _dummy() MESSAGE GetResStr( ID_EDIT_COPY )
      MENUITEM "&Paste" ACTION _dummy() MESSAGE GetResStr( ID_EDIT_PASTE )
      MENUITEM "De&lete" ACTION _dummy() MESSAGE GetResStr( ID_EDIT_DELETE )
   END POPUP
   POPUP "&View"
      MENUITEM "&Tool Bar" ACTION ( Form_1.VIEW_TOOLBAR.Checked := ! Form_1.VIEW_TOOLBAR.Checked, ;
         BuildToolBar( Form_1.VIEW_TOOLBAR.Checked ), ResizeEdit() ) ;
         NAME VIEW_TOOLBAR MESSAGE GetResStr( ID_VIEW_TOOLBAR ) CHECKED
      MENUITEM "&Status Bar" ACTION ( Form_1.VIEW_STATUSBAR.Checked := ! Form_1.VIEW_STATUSBAR.Checked, ;
         BuildStatusBar( Form_1.VIEW_STATUSBAR.Checked ), ResizeEdit() ) ;
         NAME VIEW_STATUSBAR MESSAGE GetResStr( ID_VIEW_STATUSBAR ) CHECKED
   END POPUP
   POPUP "&Help"
      MENUITEM "&About" ACTION dlg_about() MESSAGE GetResStr( ID_HELP_ABOUT )
   END POPUP

   END MENU

   BuildToolBar( .T. )

   @ 28, 0 EDITBOX Edit_1 ;
      WIDTH 0 ;
      HEIGHT 0 ;
      VALUE '' ;
      FONT 'Arial' SIZE 11 BOLD ;
      BACKCOLOR WHITE ;
      NOHSCROLL NOVSCROLL

   BuildStatusBar( .T. )

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

Return

//-------------------------------------------------------------
Procedure BuildToolBar( lShow )
//-------------------------------------------------------------
   LOCAL mVar

   IF lShow

      DEFINE IMAGELIST ImageList_1 ;
         OF Form_1 ;
         BUTTONSIZE 16, 15 ;
         IMAGE { 'ID_TOOLBAR' } ;
         COLORMASK CLR_DEFAULT ;
         IMAGECOUNT 8 ;
         MASK

      DEFINE TOOLBAREX ToolBar_1 OF Form_1 BUTTONSIZE 20, 20 IMAGELIST 'ImageList_1' FLAT

      BUTTON Button_1 ;
         PICTUREINDEX IDX_FILE_NEW ;
         TOOLTIP GetResStr( ID_FILE_NEW ) ;
         ACTION _dummy()

      BUTTON Button_2 ;
         PICTUREINDEX IDX_FILE_OPEN ;
         TOOLTIP GetResStr( ID_FILE_OPEN ) ;
         ACTION _dummy()

      BUTTON Button_3 ;
         PICTUREINDEX IDX_FILE_SAVE ;
         TOOLTIP GetResStr( ID_FILE_SAVE ) ;
         ACTION _dummy() ;
         SEPARATOR

      BUTTON Button_4 ;
         PICTUREINDEX IDX_EDIT_CUT ;
         TOOLTIP GetResStr( ID_EDIT_CUT ) ;
         ACTION _dummy()

      BUTTON Button_5 ;
         PICTUREINDEX IDX_EDIT_COPY ;
         TOOLTIP GetResStr( ID_EDIT_COPY ) ;
         ACTION _dummy()

      BUTTON Button_6 ;
         PICTUREINDEX IDX_EDIT_PASTE ;
         TOOLTIP GetResStr( ID_EDIT_PASTE ) ;
         ACTION _dummy() ;
         SEPARATOR

      BUTTON Button_7 ;
         PICTUREINDEX IDX_FILE_PRINT ;
         TOOLTIP GetResStr( ID_FILE_PRINT ) ;
         ACTION _dummy() ;
         SEPARATOR

      BUTTON Button_8 ;
         PICTUREINDEX IDX_HELP_ABOUT ;
         TOOLTIP GetResStr( ID_HELP_ABOUT ) ;
         ACTION dlg_about()

      END TOOLBAR

   ELSE

      Form_1.ToolBar_1.Release
      RELEASE IMAGELIST ImageList_1 OF Form_1
      mVar := '_FORM_1_IMAGELIST_1'
      IF Type ( mVar ) != 'U'
         __mvPut ( mVar, 0 )
      ENDIF

   ENDIF

Return

//-------------------------------------------------------------
Procedure BuildStatusBar( lShow )
//-------------------------------------------------------------

   IF lShow

      _HMG_ActiveFormName := IF( Empty( _HMG_ActiveFormName ), 'Form_1', _HMG_ActiveFormName )
      _HMG_BeginWindowActive := .T.

      DEFINE STATUSBAR OF Form_1 KEYBOARD FONT 'MS Sans Serif' SIZE 8

      END STATUSBAR

      Form_1.StatusBar.Item( 1 ) := "Ready"
      _HMG_DefaultStatusBarMessage := Form_1.StatusBar.Item( 1 )

      _HMG_BeginWindowActive := .F.

   ELSE

      Form_1.StatusBar.Release

   ENDIF

Return

//-------------------------------------------------------------
Procedure ResizeEdit
//-------------------------------------------------------------

   Form_1.Edit_1.Row := IF( IsControlDefined( ToolBar_1, Form_1 ), 28, 0 )

   Form_1.Edit_1.Width := Form_1.Width - 2 * GetBorderWidth()

   Form_1.Edit_1.Height := Form_1.Height - ( GetTitleHeight() + ;
      2 * GetBorderHeight() + GetMenuBarHeight() + ;
      iif( Form_1.VIEW_TOOLBAR.Checked, 28, 0 ) + ;
      iif( Form_1.VIEW_STATUSBAR.Checked, Form_1.StatusBar.Height, 0 ) )

Return

//-------------------------------------------------------------
Procedure dlg_about
//-------------------------------------------------------------

   DEFINE DIALOG f_dialog ;
      OF Form_1 ;
      RESOURCE IDD_DIALOG1 ;
      ON INIT { |DialogHandle| C_Center( DialogHandle ) }

      REDEFINE BUTTON Btn_1 ID IDOK ;
         ACTION ThisWindow.Release

      ON KEY ESCAPE OF f_dialog ACTION ThisWindow.Release

   END DIALOG

Return


#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400

#include <windows.h>
#include "hbapi.h"

#ifdef __XHARBOUR__
  #define HB_STORNI( n, x, y ) hb_storni( n, x, y )
#else
  #define HB_STORNI( n, x, y ) hb_storvni( n, x, y )
#endif

HB_FUNC( HB_LOADSTRING )
{
   LPBYTE cBuffer;

   cBuffer = GlobalAlloc( GPTR, 255 );
   LoadString( GetModuleHandle(NULL), hb_parni(1), (LPSTR) cBuffer, 254 );
   hb_retc( cBuffer );
   GlobalFree( cBuffer );
}

HB_FUNC( PAINTCHILDWINDOW )
{
   HWND hwnd = (HWND) hb_parnl( 1 );
   RECT r;
   PAINTSTRUCT ps;
   HDC hDC = BeginPaint( hwnd, &ps );

   GetClientRect( hwnd, &r );

   hb_retni( DrawText( hDC, (LPCTSTR) hb_parc(2), -1, &r, DT_CENTER | DT_VCENTER | DT_SINGLELINE ) );

   EndPaint( hwnd, &ps );
   ReleaseDC( hwnd, hDC );
}

HB_FUNC( GETDESKTOPAREA )
{
   RECT rect;
   SystemParametersInfo( SPI_GETWORKAREA, 1, &rect, 0 );

   hb_reta(4);
   HB_STORNI( (INT) rect.top, -1, 1 );
   HB_STORNI( (INT) rect.left, -1, 2 );
   HB_STORNI( (INT) rect.right - rect.left, -1, 3 );
   HB_STORNI( (INT) rect.bottom - rect.top, -1, 4 );
}

#pragma ENDDUMP
