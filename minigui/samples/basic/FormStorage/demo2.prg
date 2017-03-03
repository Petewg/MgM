/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * (C) 2006 Krutov Oleg <krutoff@mail.ru>
 *
 * Revised by Grigory Filatov, 2016
*/

#include "minigui.ch"

MEMVAR cFileIni

PROCEDURE Main

   PUBLIC cFileIni := Lower( ChangeFileExt( Application.ExeName, ".ini" ) )

   DEFINE WINDOW Form_1 ;
      AT 0, 0 ;
      WIDTH 400 ;
      HEIGHT 200 ;
      TITLE 'Form Storage' ;
      MAIN ;
      ON INIT RestoreConrols( ThisWindow.Name ) ;
      ON RELEASE SaveConrols( ThisWindow.Name )

   DEFINE TEXTBOX Text_1
      ROW    10
      COL    10
      WIDTH  200
      HEIGHT 24
      FONTNAME "Tahoma"
      FONTSIZE 9
      TABSTOP .T.
      READONLY .F.
      BACKCOLOR YELLOW
      FONTCOLOR RED
      VALUE ""
   END TEXTBOX

   DEFINE CHECKBUTTON CheckBtn_1
      ROW    40
      COL    10
      WIDTH  100
      HEIGHT 28
      CAPTION "Disable Edit"
      VALUE .F.
      FONTNAME "Tahoma"
      FONTSIZE 9
      ONCHANGE {|| Form_1.Text_1.Enabled := ! Form_1.Text_1.Enabled, ;
                   Form_1.CheckBtn_1.Caption := iif( Form_1.Text_1.Enabled, "Disable Edit", "Enable Edit" ) }
      TABSTOP .T.
      VISIBLE .T.
   END CHECKBUTTON

   DEFINE BUTTON Button_1
      ROW 10
      COL 270
      CAPTION 'OK'
      ACTION Form_1.Text_1.Value := 'Hello World!'
      DEFAULT .T.
   END BUTTON

   DEFINE BUTTON Button_2
      ROW 40
      COL 270
      CAPTION 'Cancel'
      ACTION ThisWindow.Release
   END BUTTON

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

RETURN

/*
*/
PROCEDURE SaveConrols( FormName )

   LOCAL i, hWnd, ControlCount

   hWnd := GetFormHandle( FormName )
   ControlCount := Len ( _HMG_aControlHandles )

   BEGIN INI FILE cFileIni

   _SetIni( FormName, FormName + '.Row', GetWindowRow( hWnd ) )
   _SetIni( FormName, FormName + '.Col', GetWindowCol( hWnd ) )
   _SetIni( FormName, FormName + '.Width', GetWindowWidth( hWnd ) )
   _SetIni( FormName, FormName + '.Height', GetWindowHeight( hWnd ) )
   _SetIni( FormName, FormName + '.ClientWidth', App.ClientWidth )
   _SetIni( FormName, FormName + '.ClientHeight', App.ClientHeight )

   SET SECTION FormName ENTRY FormName + '.Title' TO Application.Title
   SET SECTION FormName ENTRY FormName + '.Index' TO ThisWindow.Index

   FOR i := 1 TO ControlCount
      IF _HMG_aControlParentHandles[ i ] == hWnd .AND. _HMG_aControlValue[ i ] <> Nil
         SET SECTION FormName ENTRY _HMG_aControlNames[ i ] TO GetProperty( FormName, _HMG_aControlNames[ i ], 'Value' )
         SET SECTION FormName ENTRY FormName + '.' + _HMG_aControlNames[ i ] + '.Type' TO form_1.&( _HMG_aControlNames[ i ] ).Type
         SET SECTION FormName ENTRY FormName + '.' + _HMG_aControlNames[ i ] + '.Index' TO form_1.&( _HMG_aControlNames[ i ] ).Index
         SET SECTION FormName ENTRY FormName + '.' + _HMG_aControlNames[ i ] + '.Caption' TO form_1.&( _HMG_aControlNames[ i ] ).Caption
      ENDIF
   NEXT i

   END INI

RETURN

/*
*/
PROCEDURE RestoreConrols( FormName )

   LOCAL i, hWnd, ControlCount, uVar

   hWnd := GetFormHandle( FormName )
   ControlCount := Len( _HMG_aControlHandles )

   BEGIN INI FILE cFileIni

   IF ( i := _GetIni( FormName, FormName + '.Row', -1, 0 ) ) # -1
      SetProperty( FormName, 'Row', i )
   ENDIF
   IF ( i := _GetIni( FormName, FormName + '.Col', -1, 0 ) ) # -1
      SetProperty( FormName, 'Col', i )
   ENDIF
   IF ( i := _GetIni( FormName, FormName + '.Width', -1, 0 ) ) # -1
      SetProperty( FormName, 'Width', i )
   ENDIF
   IF ( i := _GetIni( FormName, FormName + '.Height', -1, 0 ) ) # -1
      SetProperty( FormName, 'Height', i )
   ENDIF

   FOR i := 1 TO ControlCount
      IF _HMG_aControlParentHandles[ i ] == hWnd
         IF ( uVar := _GetIni( FormName, _HMG_aControlNames[ i ], NIL, _HMG_aControlValue[ i ] ) ) <> Nil
            SetProperty( FormName, _HMG_aControlNames[ i ], 'Value', @uVar )
         ENDIF
      ENDIF
   NEXT i

   IF GetProperty( FormName, 'CheckBtn_1', 'Value' )
      Form_1.Text_1.Enabled := .F.
      SetProperty( FormName, 'CheckBtn_1', 'Caption', _GetIni( FormName, 'Form_1.CheckBtn_1.Caption', NIL, '' ) )
   ENDIF

   END INI

RETURN
