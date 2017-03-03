/*
 * MiniGUI Grid Color Demo
 * (c) 2009 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

Procedure Main

	SET MULTIPLE OFF
	SET AUTOADJUST ON

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 600 ;
		HEIGHT 400 ;
		TITLE 'Grid Colors Themes (borrowed from Total Commander)' ;
		MAIN ;
		ON INIT OnInit( GetStartupFolder() + "\Presets.ini" )

		DEFINE MAIN MENU
			DEFINE POPUP 'File'
				MENUITEM 'Exit'	ACTION ThisWindow.Release
			END POPUP
		END MENU

		DEFINE GRID Grid_1
			ROW 	10
			COL	10
			WIDTH	570
			HEIGHT	300 
			WIDTHS	{ 550 - IF(IsXPThemeActive(), 2, 0) }
                        ITEMS { {""} }
			ON DBLCLICK Test_it()
			CELLNAVIGATION	.T. 
			SHOWHEADERS .F.
			NOLINES .T.
			FONTNAME "MS Sans serif"
			FONTSIZE 9
		END GRID

		DEFINE STATUSBAR FONT "MS Sans serif" SIZE 9 BOLD
			STATUSITEM "" 	 
			STATUSITEM "" WIDTH 80
		END STATUSBAR

	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return


Procedure Test_it

Local cIniFile := GetStartupFolder() + "\Presets.ini"
Local a := Form_1.Grid_1.Value, cTheme
Local nForeColor, nBackColor
Local nCellForeColor, nCellBackColor, nCellMarkColor

 cTheme := Form_1.Grid_1.Cell( a[1], a[2] )

 BEGIN INI FILE cIniFile
   IF (nForeColor := _GetIni(cTheme,'ForeColor',-1,0)) # -1
	SetProperty( 'Form_1', 'Grid_1', 'ForeColor', nRGB2Arr ( nForeColor ) )
   ELSE
	SetProperty( 'Form_1', 'Grid_1', 'ForeColor', BLACK )
   ENDIF
   IF (nBackColor := _GetIni(cTheme,'BackColor',-1,0)) # -1
	SetProperty( 'Form_1', 'Grid_1', 'BackColor', nRGB2Arr ( nBackColor ) )
   ELSE
	SetProperty( 'Form_1', 'Grid_1', 'BackColor', WHITE )
   ENDIF
   IF (nCellForeColor := _GetIni(cTheme,'CursorText',-1,0)) # -1
	_HMG_GridSelectedCellForeColor	:= nRGB2Arr ( nCellForeColor )
   ELSEIF _GetIni(cTheme,'InverseCursor',0,0) == 1
	IF _GetIni(cTheme,'InverseSelection',0,0) # 1
		_HMG_GridSelectedCellForeColor	:= GetProperty( 'Form_1', 'Grid_1', 'BackColor' )
	ELSE
		_HMG_GridSelectedCellForeColor	:= WHITE
	ENDIF
	_HMG_GridSelectedCellBackColor	:= GetProperty( 'Form_1', 'Grid_1', 'ForeColor' )
   ELSEIF (nCellMarkColor := _GetIni(cTheme,'MarkColor',-1,0)) # -1
	_HMG_GridSelectedCellForeColor	:= nRGB2Arr ( nCellMarkColor )
	_HMG_GridSelectedCellBackColor	:= GetProperty( 'Form_1', 'Grid_1', 'BackColor' )
   ELSE
	_HMG_GridSelectedCellForeColor	:= RED
   ENDIF
   IF ValType(nCellMarkColor) # "N"
     IF (nCellBackColor := _GetIni(cTheme,'CursorColor',-1,0)) # -1
	_HMG_GridSelectedCellBackColor	:= nRGB2Arr ( nCellBackColor )
     ENDIF
   ELSEIF _GetIni(cTheme,'InverseSelection',0,0) == 1
	_HMG_GridSelectedCellBackColor	:= nRGB2Arr ( nCellMarkColor )
	IF nCellForeColor # -1
		_HMG_GridSelectedCellForeColor	:= GetProperty( 'Form_1', 'Grid_1', 'BackColor' )
	ELSE
		_HMG_GridSelectedCellForeColor	:= WHITE
	ENDIF
   ELSE
	_HMG_GridSelectedCellBackColor	:= GetProperty( 'Form_1', 'Grid_1', 'BackColor' )
   ENDIF
 END INI

 refresh_it()

Return


Procedure OnInit(cIniFile)

Local aLista:={}, i

 Form_1.Grid_1.DeleteAllItems

 aLista := _GetSectionNames(cIniFile)

 if len(aLista) > 0
   asort( aLista, , , {|x,y| UPPER(x)<UPPER(y)} )
   for i=1 to len(aLista)
       if !(":" $ aLista[i] .or. "--" $ aLista[i])
          Form_1.Grid_1.AddItem( {aLista[i]} )
       endif
   next i
 endif

 Form_1.Grid_1.Value := 1
 Form_1.StatusBar.Item(1) := cIniFile
 Form_1.StatusBar.Item(2) := " " + hb_NtoS(Form_1.Grid_1.ItemCount) + " Presets"
 Form_1.Grid_1.SetFocus

Return


Function refresh_it()
Local a := Form_1.Grid_1.Value

 Form_1.Grid_1.Value := iif(a[1] # 1, 1, 2)
 Form_1.Grid_1.Value := a

Return NIL
