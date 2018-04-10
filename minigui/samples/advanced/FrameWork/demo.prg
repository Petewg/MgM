/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Win32 Framework for SDI Applications
 * Copyright 2006-2017 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"
#include "resource.h"

#define IDOK             1

#define IDX_FILE_NEW    18
#define IDX_FILE_OPEN    0
#define IDX_FILE_SAVE    3
#define IDX_EDIT_CUT     6
#define IDX_EDIT_COPY    7
#define IDX_EDIT_PASTE   8
#define IDX_FILE_PRINT   4
#define IDX_HELP_ABOUT  10

#xtranslate GetResStr( <nID> ) => hb_LoadString( <nID> )

*--------------------------------------------------------*
PROCEDURE Main
*--------------------------------------------------------*
   LOCAL aDesk := GetDesktopArea()
   LOCAL nScrWidth := aDesk[ 3 ] - aDesk[ 1 ], nScrHeight := aDesk[ 4 ] - aDesk[ 2 ]
   LOCAL nWidth  := nScrWidth * 0.75
   LOCAL nHeight := nScrHeight * 0.72

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

RETURN

*--------------------------------------------------------*
PROCEDURE BuildToolBar( lShow )
*--------------------------------------------------------*
   LOCAL mVar

   IF lShow

      DEFINE IMAGELIST ImageList_1 ;
         OF Form_1 ;
         BUTTONSIZE 32, 32 ;
         IMAGE { 'ID_TOOLBAR' } ;
         IMAGECOUNT 19

      DEFINE TOOLBAREX ToolBar_1 OF Form_1 BUTTONSIZE 40, 40 IMAGELIST 'ImageList_1' FLAT

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

      IF IsControlDefined( StatusBar, Form_1 )
         Form_1.StatusBar.Item( 1 ) := "Ready"
      ENDIF

   ELSE

      Form_1.ToolBar_1.Release

      RELEASE IMAGELIST ImageList_1 OF Form_1

   ENDIF

RETURN

*--------------------------------------------------------*
PROCEDURE BuildStatusBar( lShow )
*--------------------------------------------------------*

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

RETURN

*--------------------------------------------------------*
PROCEDURE ResizeEdit
*--------------------------------------------------------*

   Form_1.Edit_1.Row := iif( IsControlDefined( ToolBar_1, Form_1 ), 44, 0 )

   Form_1.Edit_1.Width := Form_1.Width - 2 * GetBorderWidth()

   Form_1.Edit_1.Height := Form_1.Height - ( GetTitleHeight() + ;
      2 * GetBorderHeight() + GetMenuBarHeight() + ;
      iif( Form_1.VIEW_TOOLBAR.Checked, 44, 0 ) + ;
      iif( Form_1.VIEW_STATUSBAR.Checked, Form_1.StatusBar.Height, 0 ) )

RETURN

*--------------------------------------------------------*
PROCEDURE dlg_about
*--------------------------------------------------------*

   DEFINE DIALOG f_dialog ;
      OF Form_1 ;
      RESOURCE IDD_DIALOG1 ;
      ON INIT { |DialogHandle| C_Center( DialogHandle ) }

      REDEFINE BUTTON Btn_1 ID IDOK ;
         ACTION ThisWindow.Release

      ON KEY ESCAPE OF f_dialog ACTION ThisWindow.Release

   END DIALOG

RETURN


#pragma BEGINDUMP

#include <mgdefs.h>

HB_FUNC( HB_LOADSTRING )
{
   LPBYTE cBuffer;

   cBuffer = GlobalAlloc( GPTR, 255 );
   LoadString( GetModuleHandle( NULL ), hb_parni( 1 ), ( LPSTR ) cBuffer, 254 );

   hb_retc( cBuffer );
   GlobalFree( cBuffer );
}

HB_FUNC( PAINTCHILDWINDOW )
{
   HWND hwnd = (HWND) HB_PARNL( 1 );
   RECT r;
   PAINTSTRUCT ps;
   HDC hDC = BeginPaint( hwnd, &ps );

   GetClientRect( hwnd, &r );

   hb_retni( DrawText( hDC, ( LPCTSTR ) hb_parc( 2 ), -1, &r, DT_CENTER | DT_VCENTER | DT_SINGLELINE ) );

   EndPaint( hwnd, &ps );
}

#pragma ENDDUMP
