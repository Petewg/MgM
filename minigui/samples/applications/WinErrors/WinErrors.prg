/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * Copyright 2006 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM 'WinErrors'
#define VERSION ' version 1.0'
#define COPYRIGHT ' 2006 by Grigory Filatov'
#define MsgInfo( c, t ) MsgInfo( c, t, , .f. )

*--------------------------------------------------------*
PROCEDURE Main
*--------------------------------------------------------*
Local aHeaders := { 'Code', 'Description' }, ;
  aFields := { 'T1', 'T2' }, aJustify := { 1, 0 }

  SET EXCLUSIVE OFF

  DEFINE WINDOW Form_1 ;
    AT 0,0 ;
    WIDTH 529 HEIGHT 339 + IF(IsXPThemeActive(), 6, 0 ) ;
    TITLE PROGRAM ;
    MAIN ;
    ICON "MAINICON" ;
    NOMAXIMIZE NOSIZE ;
    ON INIT OnInit() ;
    ON RELEASE OnExit() ;
    FONT "MS Sans Serif" SIZE 8

    @ 8,10 LABEL Label_1        ;
      VALUE ""        ;
      WIDTH Form_1.Width - 24           ;
      HEIGHT 18       ;
      FONT 'MS Sans Serif' SIZE 9     ;
      BOLD          ;
      CENTERALIGN       ;
      TRANSPARENT

    DEFINE BROWSE Browse_1
      ROW 30
      COL 10
      WIDTH Form_1.Width - 30
      HEIGHT 152
      HEADERS aHeaders
      WIDTHS { 40, 438 }
      FIELDS aFields
      JUSTIFY aJustify
      WORKAREA ERRMSG
      NOLINES .T.
    END BROWSE

    DEFINE BROWSE Browse_2
      ROW 30
      COL 10
      WIDTH Form_1.Width - 30
      HEIGHT 152
      HEADERS aHeaders
      WIDTHS { 90, 388 }
      FIELDS aFields
      JUSTIFY aJustify
      WORKAREA ERRMSG2
      NOLINES .T.
    END BROWSE

    @ 200,10 IMAGE Image_1 ;
      PICTURE 'LOGO' ;
      ON CLICK Form_1.Text_1.SetFocus;
      WIDTH 317 HEIGHT 105

    @ 268,182 TEXTBOX Text_1 ; 
      HEIGHT 20 ;
      WIDTH 120 ;
      MAXLENGTH 10 ;
      ON CHANGE OnCodeChange(Form_1.Text_1.Value) ;
      RIGHTALIGN

    @ 240,Form_1.Width - 174 BUTTONEX Image_2 ;
      PICTURE 'HELP' ;
      WIDTH 54 HEIGHT 54 ;
      TOOLTIP 'Help' ;
      ACTION ( MsgInfo('Enter the error code number of scroll down the available list.', PROGRAM), ;
        Form_1.Text_1.Setfocus )

    @ 200,Form_1.Width - 178 RADIOGROUP Radio_1 ;
      OPTIONS { 'Win Errors', 'OLE Errors' } ;
      VALUE 1 ;
      WIDTH 70 ;
      SPACING 16 ;
      ON CHANGE OnErrChange() ;
      HORIZONTAL

    @ 240,Form_1.Width - 98 BUTTONEX Button_1 ;
      CAPTION '&About' ;
      WIDTH 80 HEIGHT 24 ;
      TOOLTIP 'About the program' ;
      ACTION ( MsgInfo( padc(PROGRAM + VERSION, 38) + CRLF + ;
        padc("Copyright " + Chr(169) + COPYRIGHT, 38) + CRLF + CRLF + ;
        hb_compiler() + CRLF + version() + CRLF + ;
        Left(MiniGuiVersion(), 38) + CRLF + CRLF + ;
        padc("This program is Freeware!", 38) + CRLF + ;
        padc("Copying is allowed!", 42), "About" ), ;
        Form_1.Text_1.Setfocus )

    @ 280,Form_1.Width - 98 BUTTONEX Button_2 ;
      CAPTION '&Close' ;
      WIDTH 80 HEIGHT 24 ;
      TOOLTIP 'Close the program' ;
      ACTION Form_1.Release

    ON KEY ALT+X ACTION Form_1.Release

  END WINDOW

  Form_1.Center

  ACTIVATE WINDOW Form_1

Return

*--------------------------------------------------------*
PROCEDURE OnInit
*--------------------------------------------------------*
Local cProgramPath := GetStartUpFolder() + "\"

  IF !FILE(cProgramPath + "ERRMSG.DBF") .OR. !FILE(cProgramPath + "ERRMSG2.DBF")
    MsgStop( "Databases don't exist!", "Stop" )
    ReleaseAllWindows()
  ENDIF

  USE ERRMSG NEW READONLY
  USE ERRMSG2 NEW READONLY

  OnErrChange()

RETURN

*--------------------------------------------------------*
PROCEDURE OnExit
*--------------------------------------------------------*

  CLOSE DATABASES

RETURN

*--------------------------------------------------------*
PROCEDURE OnCodeChange( cSeek )
*--------------------------------------------------------*
Local nCode := Form_1.Radio_1.Value, cBrowse := "Browse_" + Str(nCode, 1)

IF nCode == 1
  IF EMPTY(cSeek)
    SET FILTER TO
  ELSE
    SET FILTER TO STR(VAL(Form_1.Text_1.Value)) $ STR(FIELD->T1, 4)
  ENDIF
ELSE
  IF EMPTY(cSeek)
    SET FILTER TO
  ELSE
    SET FILTER TO UPPER(Form_1.Text_1.Value) $ FIELD->T1
  ENDIF
ENDIF

GO TOP
SetProperty( 'Form_1', cBrowse, 'Value', RecNo() )

RETURN

*--------------------------------------------------------*
PROCEDURE OnErrChange
*--------------------------------------------------------*
Local nCode := Form_1.Radio_1.Value

IF nCode == 1
  SELECT ERRMSG
  Form_1.Browse_2.Hide
  Form_1.Browse_1.Show
ELSE
  SELECT ERRMSG2
  Form_1.Browse_1.Hide
  Form_1.Browse_2.Show
ENDIF

Form_1.Label_1.Value := Ltrim(Str(LastRec())) + " " + ;
  IF(nCode = 1, "Win", "OLE") + " error codes"

IF !EMPTY(DBfilter())
  SET FILTER TO
ENDIF
Form_1.Text_1.Setfocus

RETURN



#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( INITTEXTBOX )
{
   HWND hwnd;         // Handle of the parent window/form.
   HWND hedit;        // Handle of the child window/control.
   int  iStyle;       // TEXTBOX window base style.

   // Get the handle of the parent window/form.
   hwnd = (HWND)hb_parnl(1);

   iStyle = WS_CHILD | ES_AUTOHSCROLL | BS_FLAT;

   if ( hb_parl(12) ) // if <lNumeric> is TRUE, then ES_NUMBER style is added.
   {
     iStyle = iStyle | ES_NUMBER ;
     // Set to a numeric TEXTBOX, so don't worry about other "textual" styles.
   }
   else
   {

     if ( hb_parl(10) ) // if <lUpper> is TRUE, then ES_UPPERCASE style is added.
     {
       iStyle = iStyle | ES_UPPERCASE;
     }

     if ( hb_parl(11) )  // if <lLower> is TRUE, then ES_LOWERCASE style is added.
     {
       iStyle = iStyle | ES_LOWERCASE;
     }

   }

   if ( hb_parl(13) )  // if <lPassword> is TRUE, then ES_PASSWORD style is added.
   {
     iStyle = iStyle | ES_PASSWORD;
   }

   if ( hb_parl(14) )
   {
     iStyle = iStyle | ES_CENTER;
   }

   if ( hb_parl (15) )
   {
     iStyle = iStyle | ES_READONLY;
   }

   if ( ! hb_parl (16) )
   {
      iStyle = iStyle | WS_VISIBLE ;
   }

   if ( ! hb_parl (17) )
   {
      iStyle = iStyle | WS_TABSTOP ;
   }

   // Creates the child control.
   hedit = CreateWindowEx(WS_EX_CLIENTEDGE ,
                         "EDIT",
                         "",
                         iStyle,
                         hb_parni(3),
                         hb_parni(4),
                         hb_parni(5),
                         hb_parni(6),
                         hwnd,
                         (HMENU)hb_parni(2),
                         GetModuleHandle(NULL),
                         NULL);

   SendMessage(hedit, (UINT)EM_LIMITTEXT, (WPARAM)hb_parni(9), (LPARAM)0);

   hb_retnl((LONG)hedit);
}

HB_FUNC( INITIMAGE )
{
  HWND  h;
  HBITMAP hBitmap;
  HWND hwnd;
  int Style;

  hwnd = (HWND) hb_parnl(1);

  Style = WS_CHILD | SS_BITMAP | SS_NOTIFY ;

  if ( ! hb_parl (8) )
  {
    Style = Style | WS_VISIBLE ;
  }

  h = CreateWindowEx( 0, "static", NULL, Style,
    hb_parni(3), hb_parni(4), 0, 0,
    hwnd, (HMENU) hb_parni(2), GetModuleHandle(NULL), NULL ) ;

  hBitmap = (HBITMAP) LoadImage(0,hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
  if (hBitmap==NULL)
  {
    hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(5),IMAGE_BITMAP,hb_parni(6),hb_parni(7),LR_CREATEDIBSECTION);
  }

  SendMessage( h, (UINT) STM_SETIMAGE, (WPARAM) IMAGE_BITMAP, (LPARAM) hBitmap );

  hb_retnl( (LONG) h );
}

HB_FUNC( C_SETPICTURE )
{
  HBITMAP hBitmap;

  hBitmap = (HBITMAP) LoadImage(0,hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_LOADFROMFILE|LR_CREATEDIBSECTION);
  if (hBitmap==NULL)
  {
    hBitmap = (HBITMAP) LoadImage(GetModuleHandle(NULL),hb_parc(2),IMAGE_BITMAP,hb_parni(3),hb_parni(4),LR_CREATEDIBSECTION);
  }

  SendMessage( (HWND) hb_parnl (1), (UINT) STM_SETIMAGE, (WPARAM) IMAGE_BITMAP, (LPARAM) hBitmap );

  hb_retnl( (LONG) hBitmap );
}

#pragma ENDDUMP