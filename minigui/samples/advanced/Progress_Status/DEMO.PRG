/*
 * MINIGUI - Harbour Win32 GUI library Demo
 * Copyright 2002-05 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * (c) 2005 Carlos Britos <bcd12a@yahoo.com.ar>
 * Demo para Simular ProgressBar en StatusBar
 * Determina fila ,columna ,ancho y alto de ProgressBar
 * No es un item real de StatusBar Solo posiciona una ProgressBar en un item teniendo en cuenta
 *    los pixeles de:  alto MainMenu ,alto CaptionBar ,ancho alto de ScrollBars y ancho alto de Bordes Form
 * Testeado en Win ME
 * fecha 19-Abr-05
 * Lib HMG 1.0 Build 106
 *
 * Sintax:  ProgresStatus( "cNameForm", "cNameProgressBar", nStatusItem [, lExistMainMenu ] )
 *
 * Revized: Grigory Filatov <gfilatov@inbox.ru>
 * Tested on Win XP
 * Date: 02/11/2006
 * Lib HMG 1.2 Extended Build 25
*/

#include "minigui.ch"

Function Main

  DEFINE WINDOW Form_1 ;
    AT 0,0 ;
    WIDTH 760 ;
    HEIGHT 400 ;
    VIRTUAL WIDTH 800 ;
    VIRTUAL HEIGHT 500 ;
    TITLE 'ProgressBar in StatusBar - Main' ;
    MAIN ;
    FONT 'Arial' ;
    SIZE 10 ;
    ON MAXIMIZE ProgresStatus( 'Form_1' , 'Progress_1' , GetProperty( 'Form_1', 'Spin_1', 'Value' ) ) ;   // reposiciona al redimensionar Form
    ON PAINT ProgresStatus( 'Form_1' , 'Progress_1' , GetProperty( 'Form_1', 'Spin_1', 'Value' ) )        // reposiciona al redimensionar Form

    DEFINE MAIN MENU
      POPUP '&StatusBar Test'
        ITEM 'Set StatusBar Item 1'    ACTION Form_1.StatusBar.Item (1) := "New value 1"
        ITEM 'Set StatusBar Item 2'    ACTION Form_1.StatusBar.Item (2) := "New value 2"
        ITEM 'Set StatusBar Item Icon' ACTION Form_1.StatusBar.Icon (1) := 'New.ico'
        ITEM 'Open Other Window...'    ACTION Modal_Click()
      END POPUP

      POPUP '&Help'
        ITEM '&About'   ACTION MsgInfo ("ProgressBar in StatusBar" + chr(13)+chr(10) +"bcd12a@yahoo.com.ar" , "MiniGUI Demo")
      END POPUP
    END MENU

    @ 20 , 20 BUTTON Btn_1 ;
      CAPTION 'Test' ;
      ACTION testProgres1()

    @ 25 , 150 LABEL Lbl_1 ;
      VALUE 'StatusItem Position:'

    @ 22 , 280 SPINNER Spin_1 ;
      RANGE 2 , 3 ;
      VALUE 2 ;
      WIDTH 40 ;
      HEIGHT 24

    @ 150 , 250 BUTTON Btn_2 ;
      CAPTION 'Other' ;
      ACTION Modal_Click()

    @ 1000 , 1000 PROGRESSBAR Progress_1 ;
      RANGE 0,500 ;
      SMOOTH

    @ 150, 20 SLIDER Slider_1 ;
      RANGE 0,50 ;
      VALUE 5 ;
      WIDTH 200 ;
      HEIGHT 50 ;
      ON CHANGE Slider_Change()

    DEFINE STATUSBAR
      STATUSITEM "Item 1" WIDTH 100 ACTION MsgInfo('Click! 1')
      STATUSITEM ""       WIDTH 100
      STATUSITEM "Item 3" WIDTH 100 ACTION MsgInfo('Click! 3')
      KEYBOARD
      DATE
    END STATUSBAR

    // despues de haber declarado statusbar y  progresbar
    ProgresStatus( 'Form_1' , 'Progress_1' , 2 )                   // posiciona progressbar

  END WINDOW

  CENTER WINDOW Form_1
  ACTIVATE WINDOW Form_1

RETURN Nil

*-----------------------------------------------------------------------------*
* form sin main menu debe indicarse en el ultimo parametro de ProgresStatus() como .F.
PROCEDURE Modal_CLick

  DEFINE WINDOW Form_2 ;
    AT 0,0 ;
    WIDTH 700 ;
    HEIGHT 400 ;
    TITLE 'ProgressBar in StatusBar - Modal' ;
    MODAL ;
    NOSIZE ;
    ON PAINT ProgresStatus( 'Form_2' , 'Progress_2' , GetProperty( 'Form_2', 'Spin_1', 'Value' ) , .F. )      // reposiciona al redimensionar Form

    @ 20 , 20 BUTTON Btn_2 ;
      CAPTION 'test2' ;
      ACTION testProgres2()

    @ 25 , 150 LABEL Lbl_1 ;
      VALUE 'StatusItem Position:'

    @ 22 , 280 SPINNER Spin_1 ;
      RANGE 2 , 6 ;
      VALUE 3 ;
      WIDTH 40 ;
      HEIGHT 24

    @ 1000 , 1000 PROGRESSBAR Progress_2 ;
      RANGE 0,500 ;
      TOOLTIP "ProgressBar"

    DEFINE STATUSBAR
      CLOCK
      STATUSITEM ""         WIDTH 100
      STATUSITEM ""         WIDTH 100
      STATUSITEM ""         WIDTH 100
      STATUSITEM ""         WIDTH 100
      STATUSITEM ""         WIDTH 100
      DATE
    END STATUSBAR

  END WINDOW

  Form_2.Center
  Form_2.Activate

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE Slider_Change
LOCAL nValue := Form_1.Slider_1.Value * 10

  Form_1.Progress_1.Value := nValue

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE testProgres1()
LOCAL x
ProgresStatus( 'Form_1' , 'Progress_1' , Form_1.Spin_1.Value )
FOR x = 1 TO 500
    Form_1.Progress_1.value := x
NEXT
RETURN

*-----------------------------------------------------------------------------*
PROCEDURE testProgres2()
LOCAL x
ProgresStatus( 'Form_2' , 'Progress_2' , Form_2.Spin_1.Value , .F. )
FOR x = 1 TO 500
    Form_2.Progress_2.value := x
NEXT
RETURN

#define SM_CYHSCROLL          3
#define SM_CXBORDER           5
#define SM_CYBORDER           6
#define SM_CYVTHUMB           9
#define SM_CXFULLSCREEN      16
#define SM_CXMINTRACK        34
*-----------------------------------------------------------------------------*
/*
 Actualiza fila ,columna ,ancho y alto de ProgressBar
*/
*-----------------------------------------------------------------------------*
FUNCTION ProgresStatus( cParentForm , cProgressbar , nItemPos , lMainMenu )
LOCAL FormHandle , lIsThemed , i , aWidthsItems , aInfoSys
LOCAL lVScroll := .F., lHScroll := .F., lIsMainWindow := .F.
LOCAL nSumItemsWidths := 0, nItems := 0
LOCAL nWidthFrames , nWidthBorders , nWidthDlgFrames , nWidthScrollBar , nHeightCaptionBar , nHeightMenu

DEFAULT lMainMenu := .T.

DECLARE WINDOW &cParentForm

FOR i := 1 TO LEN( _HMG_aFormNames )
   IF ! lIsMainWindow
      lIsMainWindow := IF( _HMG_aFormType [ i ] == "A" .AND. _HMG_aFormNames [ i ] == cParentForm , .T. , .F. )
   ENDIF
   IF ! lHScroll
      lHScroll := IF( _HMG_aFormVirtualWidth [ i ] > 0 .AND. _HMG_aFormNames [ i ] == cParentForm , .T. , .F. )
   ENDIF
   IF ! lVScroll
      lVScroll := IF( _HMG_aFormVirtualHeight [ i ] > 0 .AND. _HMG_aFormNames [ i ] == cParentForm , .T. , .F. )
   ENDIF
NEXT

FormHandle := GetFormHandle ( cParentForm )

// Suma anchos de los items de StatusBar
aWidthsItems := getItemsWidths( FormHandle )
nItems := len( aWidthsItems )
FOR i := nItemPos TO nItems
   nSumItemsWidths += aWidthsItems [ i ]
NEXT

// pixeles del sistema
aInfoSys := InfoSystemMetrics()
nWidthScrollBar   := aInfoSys [ SM_CYHSCROLL ]
nHeightCaptionBar := aInfoSys [ SM_CXBORDER ]
nWidthBorders     := aInfoSys [ SM_CYBORDER ]
nWidthDlgFrames   := aInfoSys [ SM_CYVTHUMB ]
nHeightMenu       := aInfoSys [ SM_CXFULLSCREEN ]
nWidthFrames      := aInfoSys [ SM_CXMINTRACK ]

lIsThemed := IsXPThemeActive()

// fila columna ancho y alto de progressbar
//&cParentForm.&cProgressbar.Width  := aWidthsItems [ nItemPos ] - nWidthDlgFrames * 3 - nWidthBorders * 2 - IF(lIsThemed, 2, 0)
SetProperty( cParentForm, cProgressbar, "Width", ;
	aWidthsItems [ nItemPos ] - nWidthDlgFrames * 3 - nWidthBorders * 2 - IF(lIsThemed, 2, 0) )
//&cParentForm.&cProgressbar.Height := nHeightCaptionBar - nWidthDlgFrames - IF(lIsThemed, 6, -3)
SetProperty( cParentForm, cProgressbar, "Height", ;
	nHeightCaptionBar - nWidthDlgFrames - IF(lIsThemed, 6, -3) )

//&cParentForm.&cProgressbar.Col    := &cParentForm.Width - ;
SetProperty( cParentForm, cProgressbar, "Col", GetProperty( cParentForm, "Width" ) - ;
                                     IF( lIsMainWindow , nWidthFrames * 2 + ;
                                     IF( IsZoomed( FormHandle ) , -1 , 20 ), nWidthDlgFrames * 2 ) - ;
                                     IF( lVScroll , nWidthScrollBar + nWidthBorders , 0 ) - ;
                                     nSumItemsWidths + ;
                                     ( nItems - nItemPos + 1 ) * nWidthDlgFrames + ;
                                     nWidthDlgFrames + ;
                                     ( nItems - nItemPos + 1 ) * 5 )

//&cParentForm.&cProgressbar.Row    := &cParentForm.Height - ;
SetProperty( cParentForm, cProgressbar, "Row", GetProperty( cParentForm, "Height" ) - ;
                                     IF( lIsMainWindow , nWidthFrames * 2 , nWidthDlgFrames * 2 ) - ;
                                     IF( lHScroll , nWidthScrollBar + nWidthBorders , 0 ) - ;
; //                                     &cParentForm.&cProgressbar.Height - ;
                                     GetProperty( cParentForm, cProgressbar, "Height" ) - ;
                                     IF( lMainMenu , nHeightMenu + nWidthBorders , nWidthBorders ) - ;
                                     nHeightCaptionBar - ;
                                     nWidthBorders + IF(lIsThemed, 0, 2) )
RETURN NIL

*-----------------------------------------------------------------------------*
FUNCTION InfoSystemMetrics()
LOCAL i, aInfoSystem := {}
   FOR i := 1 TO 44
      AADD( aInfoSystem , GetSystemInfo( i - 1 ) )
   NEXT
RETURN aInfoSystem

*-----------------------------------------------------------------------------*
/*
   Anchos de los items de statusbar
*/
*-----------------------------------------------------------------------------*
Function getItemsWidths( hWnd )
LOCAL i, ControlCount, aItemsWidths := {}
   ControlCount := Len ( _HMG_aControlHandles )
   For i := 1 to ControlCount
       if _HMG_aControlType [i] == "ITEMMESSAGE" .And. _HMG_aControlParentHandles [i] == hWnd
           aadd( aItemsWidths , _HMG_aControlWidth[i] )
       endif
   Next i
return aItemsWidths

*-----------------------------------------------------------------------------*
#pragma BEGINDUMP
#define HB_OS_WIN_USED
#define _WIN32_IE      0x0500
#define _WIN32_WINNT   0x0400
#include <windows.h>
#include "hbapi.h"

HB_FUNC ( GETSYSTEMINFO )
{
   hb_retni( GetSystemMetrics( hb_parni( 1 ) ) );
}

HB_FUNC ( ISZOOMED )
{
   hb_retl( IsZoomed( ( HWND ) hb_parnl( 1 ) ) );
}

#pragma ENDDUMP
