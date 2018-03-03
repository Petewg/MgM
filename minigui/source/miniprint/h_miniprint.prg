/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
 http://harbourminigui.googlepages.com/

 This program is free software; you can redistribute it and/or modify it under 
 the terms of the GNU General Public License as published by the Free Software 
 Foundation; either version 2 of the License, or (at your option) any later 
 version. 

 This program is distributed in the hope that it will be useful, but WITHOUT 
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with 
 this software; see the file COPYING. If not, write to the Free Software 
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or 
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text 
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other 
 files to produce an executable, this does not by itself cause the resulting 
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the 
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

	"Harbour GUI framework for Win32"
 	Copyright 2001 Alexander S.Kresin <alex@belacy.ru>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - https://harbour.github.io/

	"Harbour Project"
	Copyright 1999-2018, https://harbour.github.io/

 Parts of this module are based upon:

	"HBPRINT" 
	Copyright 2002 Richard Rylko <rrylko@poczta.onet.pl>
	http://rrylko.republika.pl

	"HBPRINTER"
	Copyright 2002 Richard Rylko <rrylko@poczta.onet.pl>
	http://rrylko.republika.pl

---------------------------------------------------------------------------*/

///////////////////////////////////////////////////////////////////////////////
// HARBOUR LEVEL PRINT ROUTINES
///////////////////////////////////////////////////////////////////////////////

#include "minigui.ch"
#include "miniprint.ch"
#include "hp_images.ch"

#define SB_HORZ		0
#define SB_VERT		1

#xtranslate Alltrim( Str( <i> ) ) => hb_ntos( <i> )

DECLARE WINDOW _HMG_PRINTER_PPNAV

Static IsVistaThemed
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_SHOWPREVIEW
*------------------------------------------------------------------------------*
Local ModalHandle
Local Tmp
Local i
Local tHeight
Local tFactor
Local tvHeight
Local icb

	IsVistaThemed := ( IsVistaOrLater() .And. IsAppXPThemed() )

	_hmg_printer_BasePageName := GetTempFolder() + "\" + _hmg_printer_timestamp + "_hmg_print_preview_"
	_hmg_printer_CurrentPageNumber := 1
	_hmg_printer_Dx := 0
	_hmg_printer_Dy := 0
	_hmg_printer_Dz := 0
	_hmg_printer_scrollstep := 10
	_hmg_printer_zoomclick_xoffset := 0
	_hmg_printer_thumbupdate := .T.
	_hmg_printer_PrevPageNumber := 0
	_hmg_printer_collate := PRINTER_COLLATE_FALSE

	if _HMG_IsModalActive == .T.

		ModalHandle := _hmg_activemodalhandle

		_HMG_IsModalActive := .F.
		_hmg_activemodalhandle := 0

		DisableWindow ( ModalHandle )

	Else

		ModalHandle := 0

	EndIf

	if _hmg_printer_hdc_bak == 0
		Return
	EndIf

	if _IsWindowDefined ( "_HMG_PRINTER_SHOWPREVIEW" )
		Return
	endif

	icb := _HMG_InteractiveClose

	SET INTERACTIVECLOSE ON

	_hmg_printer_SizeFactor := GetDesktopHeight() / _HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) * 0.63

	IF _HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak ) > 370
		_HMG_PRINTER_DELTA_ZOOM := - 250
	ELSE
		_HMG_PRINTER_DELTA_ZOOM := 0
	ENDIF

	define window _HMG_PRINTER_Wait at 0,0 width 310 height 85 title '' child noshow nocaption 
		define label label_1
			row 30
			col 5
			width 300
			height 30
			value _hmg_printer_usermessages [29] 
			centeralign .t.
		end label
	end window

	_HMG_PRINTER_Wait.Center

	DEFINE WINDOW _HMG_PRINTER_SHOWPREVIEW ;
			AT 0,0 ;
			WIDTH GetDesktopWidth() - 103 - iif ( IsVistaThemed , 25 , 0);
			HEIGHT GetDesktopHeight() - 103  - iif ( IsVistaThemed , 25 , 0);
			VIRTUAL WIDTH ( GetDesktopWidth() - 103 ) * 2 ;
			VIRTUAL HEIGHT ( GetDesktopHeight() - 103 ) * 2 ;
			TITLE _hmg_printer_usermessages [01] + ' [' + alltrim(str(_hmg_printer_CurrentPageNumber)) + '/' + ;
                                                                      alltrim(str(_hmg_printer_PageCount)) + ']' ;
			CHILD ;
			NOSIZE ;
			NOMINIMIZE ;
			NOMAXIMIZE ;
			NOSYSMENU ;
			CURSOR IMG_CURSOR ;
			ON PAINT _HMG_PRINTER_PREVIEWRefresh() ;
			BACKCOLOR GRAY ;
			ON MOUSECLICK	( _HMG_PRINTER_PPNAV.b5.value := ! _HMG_PRINTER_PPNAV.b5.value , _HMG_PRINTER_MouseZoom() ) ;
			ON SCROLLUP	_HMG_PRINTER_ScrolluP() ;
			ON SCROLLDOWN	_HMG_PRINTER_ScrollDown() ;
			ON SCROLLLEFT	_HMG_PRINTER_ScrollLeft() ;
			ON SCROLLRIGHT	_HMG_PRINTER_ScrollRight() ;
			ON HSCROLLBOX	_HMG_PRINTER_hScrollBoxProcess() ;
			ON VSCROLLBOX	_HMG_PRINTER_vScrollBoxProcess() 

			_HMG_PRINTER_SetKeys( '_HMG_PRINTER_SHOWPREVIEW' )

	END WINDOW

	Define Window _HMG_PRINTER_PRINTPAGES		;
		At 0,0					;
		Width 420				;
		Height 168 + GetTitleHeight()		;
		Title _hmg_printer_usermessages [9]	;
		CHILD NOSHOW 				;
		NOSIZE NOSYSMENU

		ON KEY ESCAPE	ACTION ( HideWindow ( GetFormHandle ( "_HMG_PRINTER_PRINTPAGES" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) , _HMG_PRINTER_SHOWPREVIEW.setfocus )
		ON KEY RETURN	ACTION _HMG_PRINTER_PrintPagesDo()

		Define Frame Frame_1
			Row 5
			Col 10
			Width 275
			Height 147
			FontName 'Arial'
			FontSize 9
			Caption _hmg_printer_usermessages [15]
		End Frame

		Define RadioGroup Radio_1
			Row 25
			Col 20
			FontName 'Arial'
			FontSize 9
			Value 1
			Options { _hmg_printer_usermessages [16] , _hmg_printer_usermessages [17] }
			OnChange iif ( This.value == 1 , ( _HMG_PRINTER_PRINTPAGES.Label_1.Enabled := .F. , _HMG_PRINTER_PRINTPAGES.Label_2.Enabled := .F. , _HMG_PRINTER_PRINTPAGES.Spinner_1.Enabled := .F. , _HMG_PRINTER_PRINTPAGES.Spinner_2.Enabled := .F. , _HMG_PRINTER_PRINTPAGES.Combo_1.Enabled := .F.  , _HMG_PRINTER_PRINTPAGES.Label_4.Enabled := .F. ) , ( _HMG_PRINTER_PRINTPAGES.Label_1.Enabled := .T. , _HMG_PRINTER_PRINTPAGES.Label_2.Enabled := .T. , _HMG_PRINTER_PRINTPAGES.Spinner_1.Enabled := .T. , _HMG_PRINTER_PRINTPAGES.Spinner_2.Enabled := .T. , _HMG_PRINTER_PRINTPAGES.Combo_1.Enabled := .T.  , _HMG_PRINTER_PRINTPAGES.Label_4.Enabled := .T. , _HMG_PRINTER_PRINTPAGES.Spinner_1.SetFocus ) )
		End RadioGroup

		Define Label Label_1
			Row 84
			Col 55
			Width 50
			Height 25
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_usermessages [18] + ':'
		End Label

		Define Spinner Spinner_1
			Row 81
			Col 110
			Width 50
			FontName 'Arial'
			FontSize 9
			Value 1
			RangeMin 1
			RangeMax _hmg_printer_PageCount
		End Spinner

		Define Label Label_2
			Row 84
			Col 165
			Width 35
			Height 25
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_usermessages [19] + ':'
		End Label

		Define Spinner Spinner_2
			Row 81
			Col 205
			Width 50
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_PageCount
			RangeMin 1
			RangeMax _hmg_printer_PageCount
		End Spinner

		Define Label Label_4
			Row 115
			Col 55
			Width 50
			Height 25
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_usermessages [09] + ':'
		End Label

		Define ComboBox Combo_1
			Row 113
			Col 110
			Width 145
			FontName 'Arial'
			FontSize 9
			Value 1
			Items {_hmg_printer_usermessages [21] , _hmg_printer_usermessages [22] , _hmg_printer_usermessages [23] }
		End ComboBox

		Define Button Ok
			Row 10
			Col 300
			Width 105
			Height 25
			FontName 'Arial'
			FontSize 9
			Caption _hmg_printer_usermessages [11]
			Action _HMG_PRINTER_PrintPagesDo()
		End Button

		Define Button Cancel
			Row 40
			Col 300
			Width 105
			Height 25
			FontName 'Arial'
			FontSize 9
			Caption _hmg_printer_usermessages [12]
			Action ( EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) , HideWindow ( GetFormHandle ( "_HMG_PRINTER_PRINTPAGES" ) ) , _HMG_PRINTER_SHOWPREVIEW.setfocus )
		End Button

		Define Label Label_3
			Row 103
			Col 300
			Width 45
			Height 25
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_usermessages [20] + ':'
		End Label

		Define Spinner Spinner_3
			Row 100
			Col 355
			Width 50
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_copies
			RangeMin 1
			RangeMax 999
			OnChange iif ( IsControlDefined (CheckBox_1,_HMG_PRINTER_PRINTPAGES) , iif ( This.Value > 1 , SetProperty( '_HMG_PRINTER_PRINTPAGES' , 'CheckBox_1','Enabled',.T.) , SetProperty( '_HMG_PRINTER_PRINTPAGES','CheckBox_1','Enabled', .F. ) ) , Nil )
		End Spinner

		Define CheckBox CheckBox_1
			Row 132
			Col 300
			Width 110
			FontName 'Arial'
			FontSize 9
			Value iif ( _hmg_printer_collate == 1 , .T. , .F. )
			Caption _hmg_printer_usermessages [14]
		End CheckBox

	End Window

	Center Window _HMG_PRINTER_PRINTPAGES

	Define Window _HMG_PRINTER_GO_TO_PAGE		;
		At 0,0					;
		Width 195				;
		Height 90 + GetTitleHeight()		;
		Title _hmg_printer_usermessages [07] 	;
		CHILD NOSHOW				;
		NOSIZE NOSYSMENU

		ON KEY ESCAPE	ACTION ( HideWindow( GetFormHandle ( "_HMG_PRINTER_GO_TO_PAGE" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) )  , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) , _HMG_PRINTER_SHOWPREVIEW.setfocus  )
		ON KEY RETURN	ACTION ( _hmg_printer_CurrentPageNumber := _HMG_PRINTER_GO_TO_PAGE.Spinner_1.Value , HideWindow( GetFormHandle ( "_HMG_PRINTER_GO_TO_PAGE" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) , _HMG_PRINTER_PREVIEWRefresh() , _HMG_PRINTER_SHOWPREVIEW.setfocus  )

		Define Label Label_1
			Row 13
			Col 10
			Width 94
			Height 25
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_usermessages [10] + ':'
		End Label

		Define Spinner Spinner_1
			Row 10
			Col 105
			Width 75
			FontName 'Arial'
			FontSize 9
			Value _hmg_printer_CurrentPageNumber
			RangeMin 1
			RangeMax _hmg_printer_PageCount
		End Spinner

		Define Button Ok
			Row 48
			Col 10
			Width 80
			Height 25
			FontName 'Arial'
			FontSize 9
			Caption _hmg_printer_usermessages [11]
			Action ( _hmg_printer_CurrentPageNumber := _HMG_PRINTER_GO_TO_PAGE.Spinner_1.Value , HideWindow( GetFormHandle ( "_HMG_PRINTER_GO_TO_PAGE" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) , _HMG_PRINTER_PREVIEWRefresh() , _HMG_PRINTER_SHOWPREVIEW.setfocus  )
		End Button

		Define Button Cancel
			Row 48
			Col 100
			Width 80
			Height 25
			FontName 'Arial'
			FontSize 9
			Caption _hmg_printer_usermessages [12]
			Action ( HideWindow( GetFormHandle ( "_HMG_PRINTER_GO_TO_PAGE" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) )  , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) , EnableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) , _HMG_PRINTER_SHOWPREVIEW.setfocus  )
		End Button

	End Window

	Center Window _HMG_PRINTER_GO_TO_PAGE

	if _HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) > _HMG_PRINTER_GETPAGEWIDTH(_hmg_printer_hdc_bak)
		tFactor := 0.44
	else
		tFactor := 0.26
	endif

	tHeight :=_HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) * tFactor

	tHeight := Int (tHeight)	

	tvHeight := ( _hmg_printer_PageCount * (tHeight + 10) ) + GetHScrollbarHeight() + GetTitleHeight() + ( GetBorderHeight() * 2 ) + 7 

	if tvHeight <= GetDesktopHeight() - 103
		_hmg_printer_thumbscroll := .f.
		tvHeight := GetDesktopHeight() - 102
	else
		_hmg_printer_thumbscroll := .t.
	EndIf

	DEFINE WINDOW _HMG_PRINTER_SHOWTHUMBNAILS ;
		AT 0,5 ;
		WIDTH 130 ;
		HEIGHT GetDesktopHeight() - 103 - IF ( IsVistaThemed , 25 , 0) ;
		VIRTUAL WIDTH 131 ;
		VIRTUAL HEIGHT tvHeight ;
		TITLE _hmg_printer_usermessages [28] ;
		CHILD ;
		NOSIZE ;
		NOMINIMIZE ;
		NOMAXIMIZE ;
		NOSYSMENU ;
		NOSHOW ;
		BACKCOLOR GRAY 

		_HMG_PRINTER_SetKeys( '_HMG_PRINTER_SHOWTHUMBNAILS' )

	END WINDOW

	if _hmg_printer_thumbscroll == .f.
		_HMG_PRINTER_PREVIEW_DISABLESCROLLBARS (GetFormHandle('_HMG_PRINTER_SHOWTHUMBNAILS'))
	endif

	DEFINE WINDOW _HMG_PRINTER_PPNAV ;
			AT 1 + iif ( IsVistaThemed , 3 , 0 ) , GetDesktopWidth() - 320 - iif ( IsVistaThemed , 5 , 0 ) ;
			WIDTH 312 + GetBorderWidth() ;
			HEIGHT 35 + GetTitleHeight() - iif ( IsVistaThemed .Or. ! _HMG_IsXP , 0 , GetBorderHeight() ) ;
			TITLE ' ' + _hmg_printer_usermessages [02] ;
			PALETTE ;
			NOMAXIMIZE ;
			NOMINIMIZE ;
			NOSIZE ;
			NOSYSMENU

			DEFINE BUTTONEX b1
				ROW 2
				COL 2
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_TOP
				TOOLTIP _hmg_printer_usermessages [03] 
				ACTION ( _hmg_printer_CurrentPageNumber:=1 , _HMG_PRINTER_PREVIEWRefresh()  )
			END BUTTONEX

			DEFINE BUTTONEX b2
				ROW 2
				COL 32
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_BACK
				TOOLTIP _hmg_printer_usermessages [04]
				ACTION ( _hmg_printer_CurrentPageNumber-- , _HMG_PRINTER_PREVIEWRefresh()  )
			END BUTTONEX

			DEFINE BUTTONEX b3
				ROW 2
				COL 62
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_NEXT
				TOOLTIP _hmg_printer_usermessages [05]
				ACTION ( _hmg_printer_CurrentPageNumber++ , _HMG_PRINTER_PREVIEWRefresh()  )
			END BUTTONEX

			DEFINE BUTTONEX b4
				ROW 2
				COL 92
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_END
				TOOLTIP _hmg_printer_usermessages [06]
				ACTION ( _hmg_printer_CurrentPageNumber:= _hmg_printer_PageCount, _HMG_PRINTER_PREVIEWRefresh()  )
			END BUTTONEX

			DEFINE CHECKBUTTON thumbswitch
				ROW 2
				COL 126
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_THUMBNAIL
				TOOLTIP _hmg_printer_usermessages [28] + ' [Ctrl+T]'
				OnChange _HMG_PRINTER_ProcessTHUMBNAILS()
			END CHECKBUTTON

			DEFINE BUTTONEX GoToPage
				ROW 2
				COL 156
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_GOPAGE
				TOOLTIP _hmg_printer_usermessages [07] + ' [Ctrl+G]'
				ACTION _HMG_PRINTER_GO_TO_PAGE()
			END BUTTONEX

			DEFINE CHECKBUTTON b5
				ROW 2
				COL 186
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_ZOOM
				TOOLTIP _hmg_printer_usermessages [08] + ' [*]'
				ON CHANGE _HMG_PRINTER_Zoom()
			END CHECKBUTTON

			DEFINE BUTTONEX b12
				ROW 2
				COL 216
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_PRINT
				TOOLTIP _hmg_printer_usermessages [09] + ' [Ctrl+P]'
				ACTION _HMG_PRINTER_PrintPages()
			END BUTTONEX

			DEFINE BUTTONEX b7
				ROW 2
				COL 246
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_SAVE
				TOOLTIP _hmg_printer_usermessages [27] + ' [Ctrl+S]'
				ACTION _hmg_printer_savepages()
			END BUTTONEX

			DEFINE BUTTONEX b6
				ROW 2
				COL 280
				WIDTH 30
				HEIGHT 30
				PICTURE IMG_CLOSE
				TOOLTIP _hmg_printer_usermessages [26] + ' [Ctrl+C]'
				ACTION _HMG_PRINTER_PreviewClose()
			END BUTTONEX

			_HMG_PRINTER_SetKeys( '_HMG_PRINTER_PPNAV' )

	END WINDOW

	SetScrollRange ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 0 , 100 , .t. )
	SetScrollRange ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 0 , 100 , .t. )

	SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 50 , .t. )
	SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 50 , .t. )

	_HMG_PRINTER_PREVIEW_DISABLESCROLLBARS (GetFormHandle('_HMG_PRINTER_SHOWPREVIEW'))

	_HMG_PRINTER_PREVIEW_DISABLEHSCROLLBAR (GetFormHandle('_HMG_PRINTER_SHOWTHUMBNAILS'))

	CENTER WINDOW _HMG_PRINTER_SHOWPREVIEW

	Tmp := _HMG_PRINTER_SHOWPREVIEW.ROW + GetTitleHeight() + iif ( IsVistaThemed , GetBorderHeight() , 0 )

	_HMG_PRINTER_SHOWPREVIEW.ROW := Tmp

	_HMG_PRINTER_SHOWTHUMBNAILS.ROW := Tmp

	ACTIVATE WINDOW _HMG_PRINTER_PRINTPAGES , _HMG_PRINTER_GO_TO_PAGE , _HMG_PRINTER_SHOWTHUMBNAILS , _HMG_PRINTER_SHOWPREVIEW , _HMG_PRINTER_Wait , _HMG_PRINTER_PPNAV 

	_hmg_printer_hdc := _hmg_printer_hdc_bak 

	If ModalHandle != 0

		For i := 1 To Len ( _HMG_aFormHandles )
			If _HMG_aFormDeleted [i] == .F.
				If _HMG_aFormType [i] != 'X'
					If _HMG_aFormHandles [i] != ModalHandle
						DisableWindow (_HMG_aFormHandles [i] )
					EndIf
				EndIf
			EndIf
		Next i

		EnableWindow ( ModalHandle )

		For i := 1 To Len ( _HMG_aFormHandles )
			If _HMG_aFormDeleted [i] == .F.
				If _HMG_aFormType [i] == 'P' .And. _HMG_aFormParentHandle [i] == ModalHandle  // Panel window into Modal window
					EnableWindow (_HMG_aFormHandles [i] )
				EndIf
			EndIf
		Next i

		SetFocus ( ModalHandle )

		_HMG_IsModalActive := .T.
		_hmg_activemodalhandle := ModalHandle

	Endif

	_HMG_InteractiveClose := icb

Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_SetKeys( parent )
*------------------------------------------------------------------------------*

	ON KEY HOME		OF &parent ACTION ( _hmg_printer_CurrentPageNumber:=1 , _HMG_PRINTER_PREVIEWRefresh()  )
	ON KEY PRIOR		OF &parent ACTION ( _hmg_printer_CurrentPageNumber-- , _HMG_PRINTER_PREVIEWRefresh()  )
	ON KEY NEXT		OF &parent ACTION ( _hmg_printer_CurrentPageNumber++ , _HMG_PRINTER_PREVIEWRefresh()  )
	ON KEY END		OF &parent ACTION ( _hmg_printer_CurrentPageNumber:= _hmg_printer_PageCount, _HMG_PRINTER_PREVIEWRefresh()  )
	ON KEY CONTROL+P	OF &parent ACTION _HMG_PRINTER_Printpages()
	ON KEY CONTROL+G	OF &parent ACTION _HMG_PRINTER_GO_TO_PAGE()
	ON KEY ESCAPE		OF &parent ACTION _HMG_PRINTER_PreviewClose()
	ON KEY MULTIPLY 	OF &parent ACTION ( _HMG_PRINTER_PPNAV.b5.value := ! _HMG_PRINTER_PPNAV.b5.value , _HMG_PRINTER_MouseZoom() )
	ON KEY CONTROL+C	OF &parent ACTION _HMG_PRINTER_PreviewClose()
	ON KEY ALT+F4		OF &parent ACTION _HMG_PRINTER_PreviewClose()
	ON KEY CONTROL+S	OF &parent ACTION _hmg_printer_savepages()
	ON KEY CONTROL+T	OF &parent ACTION _hmg_printer_ThumbnailToggle()

Return
*------------------------------------------------------------------------------*
Static Procedure CreateThumbNails
*------------------------------------------------------------------------------*
Local tFactor
Local tWidth
Local tHeight
Local ttHandle
Local i
Local cMacroTemp
Local cAction

	If _IsControlDefined ( 'Image1' , '_HMG_PRINTER_SHOWTHUMBNAILS' )
		Return
	EndIf

	ShowWindow ( GetFormHandle ( "_HMG_PRINTER_Wait" ) )

	if _HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) > _HMG_PRINTER_GETPAGEWIDTH(_hmg_printer_hdc_bak)
		tFactor := 0.44
	else
		tFactor := 0.30
	endif

	tWidth	:=_HMG_PRINTER_GETPAGEWIDTH(_hmg_printer_hdc_bak) * tFactor
	tHeight :=_HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) * tFactor

	tHeight := Int (tHeight)	

	ttHandle := GetFormToolTipHandle ( '_HMG_PRINTER_SHOWTHUMBNAILS' )

	For i := 1 To _hmg_printer_PageCount

		cMacroTemp := 'Image' + alltrim(str(i))

		cAction := "_HMG_MINIPRINT [4] := "+ alltrim(str(i)) +", _HMG_MINIPRINT [11] := .F., _HMG_PRINTER_PREVIEWRefresh(), _HMG_MINIPRINT [11] := .T."

		_DefineEmfFile(;
			cMacroTemp,;
			'_HMG_PRINTER_SHOWTHUMBNAILS',;
			10,;
			( i * (tHeight + 10) ) - tHeight,;
			_hmg_printer_BasePageName + strzero(i,4) + ".emf",;
			tWidth,;
			tHeight,;
			{ || &cAction },;
			Nil,;
			.F.,;
			.F.,;
			.T.;
			)

		SetToolTip ( GetControlHandle ( cMacroTemp, '_HMG_PRINTER_SHOWTHUMBNAILS' ), _hmg_printer_usermessages [01] + ' ' + AllTrim(Str(i)) + ' [Click]', ttHandle )
			
	Next i

	HideWindow ( GetFormHandle ( "_HMG_PRINTER_Wait" ) )

Return
*------------------------------------------------------------------------------*
Static Procedure _hmg_printer_ThumbnailToggle()
*------------------------------------------------------------------------------*

	_HMG_PRINTER_PPNAV.thumbswitch.Value := ! _HMG_PRINTER_PPNAV.thumbswitch.Value

	_HMG_PRINTER_ProcessTHUMBNAILS()

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_ProcessTHUMBNAILS()
*------------------------------------------------------------------------------*

	If _HMG_PRINTER_PPNAV.thumbswitch.Value == .T.

		CreateThumbNails()

		_hmg_printer_zoomclick_xoffset := 90

		_hmg_printer_SizeFactor := GetDesktopHeight() / _HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) * 0.58

		_HMG_PRINTER_SHOWPREVIEW.Width := GetDesktopWidth() - 148 - IF ( IsVistaThemed , 30 , 0 )

		_HMG_PRINTER_SHOWPREVIEW.Col := 138 + IF ( IsVistaThemed , 20 , 0 )

		_HMG_PRINTER_PREVIEWRefresh()

		ShowWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) 

	Else

		_hmg_printer_zoomclick_xoffset := 0

		_hmg_printer_SizeFactor := GetDesktopHeight() / _HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) * 0.63

		_HMG_PRINTER_SHOWPREVIEW.Width := GetDesktopWidth() - 103

		_HMG_PRINTER_SHOWPREVIEW.Col := 51

		HideWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) )

		_HMG_PRINTER_PPNAV.SetFocus

	EndIf

Return
*------------------------------------------------------------------------------*
Procedure _hmg_printer_savepages
*------------------------------------------------------------------------------*
Local c , i , f , t , d , x , a

	x := Putfile ( { {'Images','*.emf'} }, , GetCurrentFolder(), .t. )

	if empty(x)
		return
	endif

	x := cFilePath( x ) + '\' + cFileNoExt( x )

	t := GetTempFolder() + '\'

	c := adir ( t + _hmg_printer_timestamp  + "_hmg_print_preview_*.Emf")

	a := array( c )

	adir ( t + _hmg_printer_timestamp  + "_hmg_print_preview_*.Emf" , a )

	For i := 1 To c
		f := t + a [i]
		d := x + '_' + StrZero ( i , 4 ) + '.emf'
		COPY FILE (F) TO (D)
	Next i

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_GO_TO_PAGE
*------------------------------------------------------------------------------*

	DisableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) 

	DisableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) )

	DisableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) )

	ShowWindow ( GetFormHandle ( "_HMG_PRINTER_GO_TO_PAGE" ) )

Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_hScrollBoxProcess()
*------------------------------------------------------------------------------*
Local Sp

	Sp := GetScrollPos (  GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ )

	_hmg_printer_Dx	:= - ( Sp - 50 ) * 10

	_HMG_PRINTER_PREVIEWRefresh()

Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_vScrollBoxProcess()
*------------------------------------------------------------------------------*
Local Sp

	Sp := GetScrollPos (  GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT )

	_hmg_printer_Dy	:= - ( Sp - 50 ) * 10

	_HMG_PRINTER_PREVIEWRefresh()

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_PreviewClose()
*------------------------------------------------------------------------------*

	_HMG_PRINTER_CleanPreview()

	_HMG_PRINTER_WAIT.Release
	_HMG_PRINTER_SHOWTHUMBNAILS.Release
	_HMG_PRINTER_SHOWPREVIEW.Release
	_HMG_PRINTER_GO_TO_PAGE.Release
	_HMG_PRINTER_PRINTPAGES.Release
	_HMG_PRINTER_PPNAV.Release

Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_CleanPreview
*------------------------------------------------------------------------------*
Local t := GetTempFolder() + '\'

	AEval( Directory( t + _hmg_printer_timestamp + "_hmg_print_preview_*.Emf" ), ;
		{ |file| Ferase( t + file[1] ) } )

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_PREVIEWRefresh 
*------------------------------------------------------------------------------*
Local hwnd
Local nRow
Local nScrollMax

	If _IsControlDefined ( 'Image' + AllTrim(Str(_hmg_printer_CurrentPageNumber)) , '_HMG_PRINTER_SHOWTHUMBNAILS' ) .And. _HMG_PRINTER_THUMBUPDATE == .T. .And. _hmg_printer_thumbscroll == .T.

		if _hmg_printer_PrevPageNumber != _hmg_printer_CurrentPageNumber

			_hmg_printer_PrevPageNumber := _hmg_printer_CurrentPageNumber
			hwnd := GetFormHandle('_HMG_PRINTER_SHOWTHUMBNAILS')
			nRow := GetProperty ( '_HMG_PRINTER_SHOWTHUMBNAILS' , 'Image' + AllTrim(Str(_hmg_printer_CurrentPageNumber)) , 'Row' )
			nScrollMax := GetScrollRangeMax ( hwnd , SB_VERT )

		if _hmg_printer_PageCount == _hmg_printer_CurrentPageNumber

			if GetScrollPos(hwnd,SB_VERT) != nScrollMax
				_HMG_SETVSCROLLVALUE ( hwnd , nScrollMax )
			EndIf

		ElseIf _hmg_printer_CurrentPageNumber == 1 

			if GetScrollPos(hwnd,SB_VERT) != 0
				_HMG_SETVSCROLLVALUE ( hwnd , 0 )
			EndIf

		Else

			if ( nRow - 9 ) < nScrollMax 
				_HMG_SETVSCROLLVALUE ( hwnd , nRow - 9 )
			Else
				if GetScrollPos(hwnd,SB_VERT) != nScrollMax
					_HMG_SETVSCROLLVALUE ( hwnd , nScrollMax )
				EndIf
			EndIf

		EndIf

		EndIf

	EndIf

	if _hmg_printer_CurrentPageNumber < 1 
		_hmg_printer_CurrentPageNumber := 1
		PlayBeep()
		Return
	EndIf

	if _hmg_printer_CurrentPageNumber > _hmg_printer_PageCount
		_hmg_printer_CurrentPageNumber := _hmg_printer_PageCount
		PlayBeep()
		Return
	EndIf

	InvalidateRect ( GetFormHandle ('_HMG_PRINTER_SHOWPREVIEW') , 0 )

	_HMG_PRINTER_SHOWPAGE ( _hmg_printer_BasePageName + strzero(_hmg_printer_CurrentPageNumber, 4) + ".emf" , GetFormHandle ('_HMG_PRINTER_SHOWPREVIEW') , _hmg_printer_hdc_bak , _hmg_printer_SizeFactor * 10000 , _hmg_printer_Dz , _hmg_printer_Dx , _hmg_printer_Dy )

	_HMG_PRINTER_SHOWPREVIEW.TITLE := _hmg_printer_usermessages [01] + ' [' + alltrim(str(_hmg_printer_CurrentPageNumber)) + '/'+alltrim(str(_hmg_printer_PageCount)) + ']'

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_PrintPages
*------------------------------------------------------------------------------*

	DIsableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) 
	DIsableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) )
	DIsableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) )

	_HMG_PRINTER_PRINTPAGES.Radio_1.Value := 1

	_HMG_PRINTER_PRINTPAGES.Label_1.Enabled := .F.
	_HMG_PRINTER_PRINTPAGES.Label_2.Enabled := .F.
	_HMG_PRINTER_PRINTPAGES.Label_4.Enabled := .F.
	_HMG_PRINTER_PRINTPAGES.Spinner_1.Enabled := .F.
	_HMG_PRINTER_PRINTPAGES.Spinner_2.Enabled := .F.
	_HMG_PRINTER_PRINTPAGES.Combo_1.Enabled := .F.
	_HMG_PRINTER_PRINTPAGES.CheckBox_1.Enabled := .F.

	if	_hmg_printer_usercopies == .T. ;
		.Or. ;
		_hmg_printer_usercollate == .T.

		_HMG_PRINTER_PRINTPAGES.Spinner_3.Enabled := .F.

	endif

	ShowWindow ( GetFormHandle ( "_HMG_PRINTER_PRINTPAGES" ) )

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_PrintPagesDo
*------------------------------------------------------------------------------*
Local i
Local PageFrom
Local PageTo
Local p
Local OddOnly := .F.
Local EvenOnly := .F.

	If _HMG_PRINTER_PrintPages.Radio_1.Value == 1

		PageFrom := 1 
		PageTo	 := _hmg_printer_PageCount

	ElseIf _HMG_PRINTER_PrintPages.Radio_1.Value == 2

		PageFrom := _HMG_PRINTER_PrintPages.Spinner_1.Value
		PageTo	 := _HMG_PRINTER_PrintPages.Spinner_2.Value

		If _HMG_PRINTER_PrintPages.Combo_1.Value == 2
			OddOnly := .T. 
		ElseIf _HMG_PRINTER_PrintPages.Combo_1.Value == 3
			EvenOnly := .T. 
		EndIf

	EndIf

	_hmg_printer_JobId := _HMG_PRINTER_StartDoc ( _hmg_printer_hdc_bak, _hmg_printer_JobName )

	If ! Empty ( _hmg_printer_JobData )
		If __mvExist( _hmg_printer_JobData )
			__mvPut( _hmg_printer_JobData , OpenPrinterGetJobData() )
		Else
			MsgMiniGuiError ( "START PRINTDOC STOREJOBDATA: " + _hmg_printer_JobData + " must be declared as Public or Private." )
		EndIf
	EndIf

	If _HMG_PRINTER_PrintPages.Spinner_3.Value == 1 // Copies 

		For i := PageFrom To PageTo

			If OddOnly == .T.
				If i / 2 != int (i / 2)
					_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
				EndIf
			ElseIf EvenOnly == .T.
				If i / 2 == int (i / 2)
					_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
				EndIf
			Else
				_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
			EndIf

		Next i

	Else

		If _HMG_PRINTER_PrintPages.CheckBox_1.Value == .F.

			For p := 1 To _HMG_PRINTER_PrintPages.Spinner_3.Value

				For i := PageFrom To PageTo

					If OddOnly == .T.
						If i / 2 != int (i / 2)
							_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
						EndIf
					ElseIf EvenOnly == .T.
						If i / 2 == int (i / 2)
							_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
						EndIf
					Else
						_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
					EndIf

				Next i

			Next p

		Else

			For i := PageFrom To PageTo

				For p := 1 To _HMG_PRINTER_PrintPages.Spinner_3.Value

					If OddOnly == .T.
						If i / 2 != int (i / 2)
							_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
						EndIf
					ElseIf EvenOnly == .T.
						If i / 2 == int (i / 2)
							_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
						EndIf
					Else
						_HMG_PRINTER_PRINTPAGE ( _hmg_printer_hdc_bak , _hmg_printer_BasePageName + strzero(i,4) + ".emf" )
					EndIf

				Next p

			Next i

		EndIf

	EndIf

	_HMG_PRINTER_ENDDOC ( _hmg_printer_hdc_bak )

	EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWPREVIEW" ) )
	EnableWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) 
	EnableWindow ( GetFormHandle ( "_HMG_PRINTER_PPNAV" ) ) 

	HideWindow ( GetFormHandle ( "_HMG_PRINTER_PRINTPAGES" ) ) 

	_HMG_PRINTER_SHOWPREVIEW.setfocus 

Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_ScrollLeft
*------------------------------------------------------------------------------*
	_hmg_printer_Dx := _hmg_printer_Dx + _hmg_printer_scrollstep
	if _hmg_printer_Dx >= 500
		_hmg_printer_Dx := 500
		PlayBeep()
	EndIf
	_HMG_PRINTER_PREVIEWRefresh()
Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_ScrollRight
*------------------------------------------------------------------------------*
	_hmg_printer_Dx := _hmg_printer_Dx - _hmg_printer_scrollstep
	if _hmg_printer_Dx <= -500
		_hmg_printer_Dx := -500
		PlayBeep()
	EndIf
	_HMG_PRINTER_PREVIEWRefresh()
Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_ScrollUp
*------------------------------------------------------------------------------*
	_hmg_printer_Dy := _hmg_printer_Dy + _hmg_printer_scrollstep
	if _hmg_printer_Dy >= 500
		_hmg_printer_Dy := 500
		PlayBeep()
	EndIf
	_HMG_PRINTER_PREVIEWRefresh()
Return
*------------------------------------------------------------------------------*
Static Procedure _HMG_PRINTER_ScrollDown
*------------------------------------------------------------------------------*
	_hmg_printer_Dy := _hmg_printer_Dy - _hmg_printer_scrollstep
	if _hmg_printer_Dy <= -500
		_hmg_printer_Dy := -500
		PlayBeep()
	EndIf

	_HMG_PRINTER_PREVIEWRefresh()
Return
*------------------------------------------------------------------------------*
Function GetPrinter()
*------------------------------------------------------------------------------*
Local RetVal		:= ''
Local Printers		:= asort (aPrinters())
Local cDefaultPrinter	:= win_printerGetDefault()
Local i
Local nInitPosition	:= 0

	For i := 1 to Len ( Printers )

		If Printers [i] == cDefaultPrinter
			nInitPosition := i
			Exit
		Endif

	Next i

	If Type ( '_HMG_MINIPRINT[22]' ) == "U"
		_hmg_printer_InitUserMessages()
	EndIf

	DEFINE WINDOW _HMG_PRINTER_GETPRINTER	;
		AT 0,0			; 
		WIDTH 345		;
		HEIGHT GetTitleHeight() + 100 ;
		TITLE _hmg_printer_usermessages [13] ;
		MODAL			;
		NOSIZE

		@ 15,10 COMBOBOX Combo_1 ITEMS Printers VALUE nInitPosition WIDTH 320

		@ 53 , 65  BUTTON Ok CAPTION _hmg_printer_usermessages [11] ACTION ( RetVal := Printers [ GetProperty ( '_HMG_PRINTER_GETPRINTER','Combo_1','Value' ) ] , DoMethod( '_HMG_PRINTER_GETPRINTER','Release' ) )

		@ 53 , 175 BUTTON Cancel CAPTION _hmg_printer_usermessages [12] ACTION ( RetVal := '' , DoMethod( '_HMG_PRINTER_GETPRINTER','Release' ) )

		ON KEY ESCAPE ACTION _HMG_PRINTER_GETPRINTER.Cancel.OnClick ()
	END WINDOW

	CENTER WINDOW _HMG_PRINTER_GETPRINTER

	ACTIVATE WINDOW _HMG_PRINTER_GETPRINTER

Return (RetVal)

#define TA_CENTER	6
#define TA_LEFT		0
#define TA_RIGHT	2

*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_H_PRINT ( nHdc , nRow , nCol , cFontName , nFontSize , nColor1 , nColor2 , nColor3 , cText , lbold , litalic , lunderline , lstrikeout , lcolor , lfont , lsize , cAlign , lAngle , nAngle )
*------------------------------------------------------------------------------*
Local lAlignChanged := .F.

	DEFAULT lAngle TO .F., ;
		nAngle TO 0

	if ValType (cText) == "N"
		cText := AllTrim(Str(cText))
	Elseif ValType (cText) == "D"
		cText := dtoc (cText)
	Elseif ValType (cText) == "L"
		cText := iif ( cText == .T. , _hmg_printer_usermessages [24] , _hmg_printer_usermessages [25] )
	Elseif ValType (cText) == "A"
		Return
	Elseif ValType (cText) == "B"
		Return
	Elseif ValType (cText) == "O"
		Return
	Elseif ValType (cText) == "U"
		Return
	EndIf

	nRow := Int ( nRow * 10000 / 254 )
	nCol := Int ( nCol * 10000 / 254 )

	if valtype ( cAlign ) = 'C'
		if upper ( cAlign ) = 'CENTER'
			SetTextAlign ( nHdc , TA_CENTER )
			lAlignChanged := .T.
		elseif upper ( cAlign ) = 'RIGHT'
			SetTextAlign ( nHdc , TA_RIGHT )
			lAlignChanged := .T.
		endif			
	endif

	If lAngle
		nAngle *= 10
	EndIf

	_HMG_PRINTER_C_PRINT ( nHdc , nRow , nCol , cFontName , nFontSize , nColor1 , nColor2 , nColor3 , cText , lbold , litalic , lunderline , lstrikeout , lcolor , lfont , lsize , lAngle , nAngle )

	if lAlignChanged
		SetTextAlign ( nHdc , TA_LEFT )
	endif

Return

*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_H_MULTILINE_PRINT ( nHdc , nRow , nCol , nToRow , nToCol , cFontName , nFontSize , nColor1 , nColor2 , nColor3 , cText , lbold , litalic , lunderline , lstrikeout , lcolor , lfont , lsize , cAlign )
*------------------------------------------------------------------------------*
Local nAlign := TA_LEFT

	if ValType (cText) == "N"
		cText := AllTrim(Str(cText))
	Elseif ValType (cText) == "D"
		cText := dtoc (cText)
	Elseif ValType (cText) == "L"
		cText := iif ( cText == .T. , _hmg_printer_usermessages [24] , _hmg_printer_usermessages [25] )
	Elseif ValType (cText) == "A"
		Return
	Elseif ValType (cText) == "B"
		Return
	Elseif ValType (cText) == "O"
		Return
	Elseif ValType (cText) == "U"
		Return
	EndIf

	nRow := Int ( nRow * 10000 / 254 )
	nCol := Int ( nCol * 10000 / 254 )
	nToRow := Int ( nToRow * 10000 / 254 )
	nToCol := Int ( nToCol * 10000 / 254 )

	if valtype ( cAlign ) = 'C'
		if upper ( cAlign ) = 'CENTER'
			nAlign := TA_CENTER
		elseif upper ( cAlign ) = 'RIGHT'
			nAlign := TA_RIGHT
		endif			
	endif

	_HMG_PRINTER_C_MULTILINE_PRINT ( nHdc , nRow , nCol , cFontName , nFontSize , nColor1 , nColor2 , nColor3 , cText , lbold , litalic , lunderline , lstrikeout , lcolor , lfont , lsize , nToRow , nToCol , nAlign )

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_H_IMAGE ( nHdc , cImage , nRow , nCol , nHeight , nWidth , lStretch , lTransparent )
*------------------------------------------------------------------------------*

	nRow	:= Int ( nRow * 10000 / 254 )
	nCol	:= Int ( nCol * 10000 / 254 )
	nWidth	:= Int ( nWidth * 10000 / 254 )
	nHeight	:= Int ( nHeight * 10000 / 254 )

	_HMG_PRINTER_C_IMAGE ( nHdc , cImage , nRow , nCol , nHeight , nWidth , lStretch , lTransparent )

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_H_LINE ( nHdc , nRow , nCol , nToRow , nToCol , nWidth , nColor1 , nColor2 , nColor3 , lwidth , lcolor , ldotted )
*------------------------------------------------------------------------------*

	nRow	:= Int ( nRow * 10000 / 254 )
	nCol	:= Int ( nCol * 10000 / 254 )
	nToRow	:= Int ( nToRow * 10000 / 254 )
	nToCol	:= Int ( nToCol * 10000 / 254 )

	If ValType ( nWidth ) != 'U'
		nWidth	:= Int ( nWidth * 10000 / 254 )
	ElseIf ldotted
		nWidth	:= 3
		lwidth	:= .T.
	EndIf

	_HMG_PRINTER_C_LINE ( nHdc , nRow , nCol , nToRow , nToCol , nWidth , nColor1 , nColor2 , nColor3 , lwidth , lcolor , ldotted )

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_H_RECTANGLE ( nHdc , nRow , nCol , nToRow , nToCol , nWidth , nColor1 , nColor2 , nColor3 , lwidth , lcolor , lfilled , lnoborder )
*------------------------------------------------------------------------------*

	nRow	:= Int ( nRow * 10000 / 254 )
	nCol	:= Int ( nCol * 10000 / 254 )
	nToRow	:= Int ( nToRow * 10000 / 254 )
	nToCol	:= Int ( nToCol * 10000 / 254 )

	If ValType ( nWidth ) != 'U'
		nWidth	:= Int ( nWidth * 10000 / 254 )
	EndIf

	_HMG_PRINTER_C_RECTANGLE ( nHdc , nRow , nCol , nToRow , nToCol , nWidth , nColor1 , nColor2 , nColor3 , lwidth , lcolor, lfilled, lnoborder )

Return
*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_H_ROUNDRECTANGLE ( nHdc , nRow , nCol , nToRow , nToCol , nWidth , nColor1 , nColor2 , nColor3 , lwidth , lcolor, lfilled )
*------------------------------------------------------------------------------*

	nRow	:= Int ( nRow * 10000 / 254 )
	nCol	:= Int ( nCol * 10000 / 254 )
	nToRow	:= Int ( nToRow * 10000 / 254 )
	nToCol	:= Int ( nToCol * 10000 / 254 )

	If ValType ( nWidth ) != 'U'
		nWidth	:= Int ( nWidth * 10000 / 254 )
	EndIf

	_HMG_PRINTER_C_ROUNDRECTANGLE ( nHdc , nRow , nCol , nToRow , nToCol , nWidth , nColor1 , nColor2 , nColor3 , lwidth , lcolor, lfilled )

Return

*------------------------------------------------------------------------------*
Procedure _hmg_printer_InitUserMessages
*------------------------------------------------------------------------------*
#ifdef _MULTILINGUAL_
	Local cLang
#endif
Public _HMG_MINIPRINT[27]

_hmg_printer_name := ""
_hmg_printer_JobId := 0
_hmg_printer_usercopies := .F.
_hmg_printer_usercollate := .F.

_hmg_printer_usermessages := Array( 29 )

_hmg_printer_usermessages [01] := 'Page'
_hmg_printer_usermessages [02] := 'Print Preview'
_hmg_printer_usermessages [03] := 'First Page [HOME]'
_hmg_printer_usermessages [04] := 'Previous Page [PGUP]'
_hmg_printer_usermessages [05] := 'Next Page [PGDN]'
_hmg_printer_usermessages [06] := 'Last Page [END]'
_hmg_printer_usermessages [07] := 'Go To Page'
_hmg_printer_usermessages [08] := 'Zoom'
_hmg_printer_usermessages [09] := 'Print'
_hmg_printer_usermessages [10] := 'Page Number'
_hmg_printer_usermessages [11] := 'Ok'
_hmg_printer_usermessages [12] := 'Cancel'
_hmg_printer_usermessages [13] := 'Select Printer'
_hmg_printer_usermessages [14] := 'Collate Copies'
_hmg_printer_usermessages [15] := 'Print Range'
_hmg_printer_usermessages [16] := 'All'
_hmg_printer_usermessages [17] := 'Pages'
_hmg_printer_usermessages [18] := 'From'
_hmg_printer_usermessages [19] := 'To'
_hmg_printer_usermessages [20] := 'Copies'
_hmg_printer_usermessages [21] := 'All Range'
_hmg_printer_usermessages [22] := 'Odd Pages Only'
_hmg_printer_usermessages [23] := 'Even Pages Only'
_hmg_printer_usermessages [24] := 'Yes'
_hmg_printer_usermessages [25] := 'No'
_hmg_printer_usermessages [26] := 'Close'
_hmg_printer_usermessages [27] := 'Save'
_hmg_printer_usermessages [28] := 'Thumbnails'
_hmg_printer_usermessages [29] := 'Generating Thumbnails... Please Wait...'

#ifdef _MULTILINGUAL_

cLang := Upper( Left( Set ( _SET_LANGUAGE ), 2 ) )

// LANGUAGE IS NOT SUPPORTED BY hb_langSelect() FUNCTION
IF _HMG_LANG_ID == 'FI'		// FINNISH
	cLang := 'FI'		
ENDIF

do case

case cLang == "CS"
/////////////////////////////////////////////////////////////
// CZECH
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Strana'
	_hmg_printer_usermessages [02] := 'Náhled'
	_hmg_printer_usermessages [03] := 'První strana [HOME]'
	_hmg_printer_usermessages [04] := 'Pøedchozí strana [PGUP]'
	_hmg_printer_usermessages [05] := 'Další strana [PGDN]'
	_hmg_printer_usermessages [06] := 'Poslední strana [END]'
	_hmg_printer_usermessages [07] := 'Jdi na stranu'
	_hmg_printer_usermessages [08] := 'Lupa'
	_hmg_printer_usermessages [09] := 'Tisk'
	_hmg_printer_usermessages [10] := 'Èíslo strany'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Storno'
	_hmg_printer_usermessages [13] := 'Vyber tiskárnu'
	_hmg_printer_usermessages [14] := 'Tøídìní'
	_hmg_printer_usermessages [15] := 'Rozsah tisku'
	_hmg_printer_usermessages [16] := 'vše'
	_hmg_printer_usermessages [17] := 'strany'
	_hmg_printer_usermessages [18] := 'od'
	_hmg_printer_usermessages [19] := 'do'
	_hmg_printer_usermessages [20] := 'kopií'
	_hmg_printer_usermessages [21] := 'všechny strany'
	_hmg_printer_usermessages [22] := 'liché strany'
	_hmg_printer_usermessages [23] := 'sudé strany'
	_hmg_printer_usermessages [24] := 'Ano'
	_hmg_printer_usermessages [25] := 'No'
	_hmg_printer_usermessages [26] := 'Zavøi'
	_hmg_printer_usermessages [27] := 'Ulož'
	_hmg_printer_usermessages [28] := 'Miniatury'
	_hmg_printer_usermessages [29] := 'Generuji miniatury... Èekejte, prosím...'

case cLang == "HR"   // Croatian
/////////////////////////////////////////////////////////////
// CROATIAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Page'
	_hmg_printer_usermessages [02] := 'Print Preview'
	_hmg_printer_usermessages [03] := 'First Page [HOME]'
	_hmg_printer_usermessages [04] := 'Previous Page [PGUP]'
	_hmg_printer_usermessages [05] := 'Next Page [PGDN]'
	_hmg_printer_usermessages [06] := 'Last Page [END]'
	_hmg_printer_usermessages [07] := 'Go To Page'
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Print'
	_hmg_printer_usermessages [10] := 'Page Number'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Cancel'
	_hmg_printer_usermessages [13] := 'Select Printer'
	_hmg_printer_usermessages [14] := 'Collate Copies'
	_hmg_printer_usermessages [15] := 'Print Range'
	_hmg_printer_usermessages [16] := 'All'
	_hmg_printer_usermessages [17] := 'Pages'
	_hmg_printer_usermessages [18] := 'From'
	_hmg_printer_usermessages [19] := 'To'
	_hmg_printer_usermessages [20] := 'Copies'
	_hmg_printer_usermessages [21] := 'All Range'
	_hmg_printer_usermessages [22] := 'Odd Pages Only'
	_hmg_printer_usermessages [23] := 'Even Pages Only'
	_hmg_printer_usermessages [24] := 'Yes'
	_hmg_printer_usermessages [25] := 'No'
	_hmg_printer_usermessages [26] := 'Close'
	_hmg_printer_usermessages [27] := 'Save'
	_hmg_printer_usermessages [28] := 'Thumbnails'
	_hmg_printer_usermessages [29] := 'Generating Thumbnails... Please Wait...'

case cLang == "EU"   // Basque.
/////////////////////////////////////////////////////////////
// BASQUE
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Page'
	_hmg_printer_usermessages [02] := 'Print Preview'
	_hmg_printer_usermessages [03] := 'First Page [HOME]'
	_hmg_printer_usermessages [04] := 'Previous Page [PGUP]'
	_hmg_printer_usermessages [05] := 'Next Page [PGDN]'
	_hmg_printer_usermessages [06] := 'Last Page [END]'
	_hmg_printer_usermessages [07] := 'Go To Page'
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Print'
	_hmg_printer_usermessages [10] := 'Page Number'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Cancel'
	_hmg_printer_usermessages [13] := 'Select Printer'
	_hmg_printer_usermessages [14] := 'Collate Copies'
	_hmg_printer_usermessages [15] := 'Print Range'
	_hmg_printer_usermessages [16] := 'All'
	_hmg_printer_usermessages [17] := 'Pages'
	_hmg_printer_usermessages [18] := 'From'
	_hmg_printer_usermessages [19] := 'To'
	_hmg_printer_usermessages [20] := 'Copies'
	_hmg_printer_usermessages [21] := 'All Range'
	_hmg_printer_usermessages [22] := 'Odd Pages Only'
	_hmg_printer_usermessages [23] := 'Even Pages Only'
	_hmg_printer_usermessages [24] := 'Yes'
	_hmg_printer_usermessages [25] := 'No'
	_hmg_printer_usermessages [26] := 'Close'
	_hmg_printer_usermessages [27] := 'Save'
	_hmg_printer_usermessages [28] := 'Thumbnails'
	_hmg_printer_usermessages [29] := 'Generating Thumbnails... Please Wait...'

case cLang == "FR"   // French
/////////////////////////////////////////////////////////////
// FRENCH
////////////////////////////////////////////////////////////
                                          
	_hmg_printer_usermessages [01] := 'Page'
	_hmg_printer_usermessages [02] := "Aperçu avant impression"
	_hmg_printer_usermessages [03] := 'Première page [HOME]'
	_hmg_printer_usermessages [04] := 'Page précédente [PGUP]'
	_hmg_printer_usermessages [05] := 'Page suivante [PGDN]'
	_hmg_printer_usermessages [06] := 'Dernière page [END]'
	_hmg_printer_usermessages [07] := 'Allez page'
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Imprimer'
	_hmg_printer_usermessages [10] := 'Page'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Annulation'
	_hmg_printer_usermessages [13] := "Sélection de l'imprimante"
	_hmg_printer_usermessages [14] := "Assemblez"
	_hmg_printer_usermessages [15] := "Paramètres d'impression"
	_hmg_printer_usermessages [16] := 'Tous'
	_hmg_printer_usermessages [17] := 'Pages'
	_hmg_printer_usermessages [18] := 'De'
	_hmg_printer_usermessages [19] := 'À'
	_hmg_printer_usermessages [20] := 'Copies'
	_hmg_printer_usermessages [21] := 'Toutes les pages'
	_hmg_printer_usermessages [22] := 'Pages Impaires'
	_hmg_printer_usermessages [23] := 'Pages Paires'
	_hmg_printer_usermessages [24] := 'Oui'
	_hmg_printer_usermessages [25] := 'Non'
	_hmg_printer_usermessages [26] := 'Fermer'
	_hmg_printer_usermessages [27] := 'Sauver'
	_hmg_printer_usermessages [28] := 'Affichettes'
	_hmg_printer_usermessages [29] := "Création des affichettes... Merci d'attendre..."

case cLang == "DE"   // German
/////////////////////////////////////////////////////////////
// GERMAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Seite'
	_hmg_printer_usermessages [02] := 'Druck Vorschau'
	_hmg_printer_usermessages [03] := 'Erste Seite [HOME]'
	_hmg_printer_usermessages [04] := 'Vorherige Seite [PGUP]'
	_hmg_printer_usermessages [05] := 'Nächste Seite [PGDN]'
	_hmg_printer_usermessages [06] := 'Letzte Seite [END]'
	_hmg_printer_usermessages [07] := 'Gehe zur Seite '
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Drucken'
	_hmg_printer_usermessages [10] := 'Seite Nummer'
	_hmg_printer_usermessages [11] := 'Okay'
	_hmg_printer_usermessages [12] := 'Abbruch'
	_hmg_printer_usermessages [13] := 'Drucker wählen'
	_hmg_printer_usermessages [14] := 'Sortieren'
	_hmg_printer_usermessages [15] := 'Druckbereich Auswahl'
	_hmg_printer_usermessages [16] := 'Alle Seiten'
	_hmg_printer_usermessages [17] := 'Seiten'
	_hmg_printer_usermessages [18] := 'von'
	_hmg_printer_usermessages [19] := 'bis'
	_hmg_printer_usermessages [20] := 'Kopien'
	_hmg_printer_usermessages [21] := 'Alle Seiten'
	_hmg_printer_usermessages [22] := 'Nur ungerade Seiten'
	_hmg_printer_usermessages [23] := 'Nur gerade Seiten'
	_hmg_printer_usermessages [24] := 'Ja'
	_hmg_printer_usermessages [25] := 'Nein'
	_hmg_printer_usermessages [26] := 'Beenden'
	_hmg_printer_usermessages [27] := 'Speichern'
	_hmg_printer_usermessages [28] := 'Seitenvorschau'
	_hmg_printer_usermessages [29] := 'Erzeuge Vorschau...  Bitte warten...'

case cLang == "IT"   // Italian
/////////////////////////////////////////////////////////////
// ITALIAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Pagina'
	_hmg_printer_usermessages [02] := 'Anteprima di stampa'
	_hmg_printer_usermessages [03] := 'Prima Pagina [HOME]'
	_hmg_printer_usermessages [04] := 'Pagina Precedente [PGUP]'
	_hmg_printer_usermessages [05] := 'Pagina Seguente [PGDN]'
	_hmg_printer_usermessages [06] := 'Ultima Pagina [END]'
	_hmg_printer_usermessages [07] := 'Vai Alla Pagina'
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Stampa'
	_hmg_printer_usermessages [10] := 'Pagina'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Annulla'
	_hmg_printer_usermessages [13] := 'Selezioni Lo Stampatore'
	_hmg_printer_usermessages [14] := 'Fascicoli'
	_hmg_printer_usermessages [15] := 'Intervallo di stampa'
	_hmg_printer_usermessages [16] := 'Tutti'
	_hmg_printer_usermessages [17] := 'Pagine'
	_hmg_printer_usermessages [18] := 'Da'
	_hmg_printer_usermessages [19] := 'A'
	_hmg_printer_usermessages [20] := 'Copie'
	_hmg_printer_usermessages [21] := 'Tutte le pagine'
	_hmg_printer_usermessages [22] := 'Le Pagine Pari'
	_hmg_printer_usermessages [23] := 'Le Pagine Dispari'
	_hmg_printer_usermessages [24] := 'Si'
	_hmg_printer_usermessages [25] := 'No'
	_hmg_printer_usermessages [26] := 'Chiudi'
	_hmg_printer_usermessages [27] := 'Salva'
	_hmg_printer_usermessages [28] := 'Miniatura'
	_hmg_printer_usermessages [29] := 'Generando Miniatura...  Prego Attesa...'

case cLang == "PL"   // Polish 
/////////////////////////////////////////////////////////////
// POLISH
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Strona'
	_hmg_printer_usermessages [02] := 'Podgl¹d wydruku'
	_hmg_printer_usermessages [03] := 'Pierwsza strona [HOME]'
	_hmg_printer_usermessages [04] := 'Poprzednia strona [PGUP]'
	_hmg_printer_usermessages [05] := 'Nastêpna strona [PGDN]'
	_hmg_printer_usermessages [06] := 'Ostatnia strona [END]'
	_hmg_printer_usermessages [07] := 'Skocz do strony'
	_hmg_printer_usermessages [08] := 'Powiêksz'
	_hmg_printer_usermessages [09] := 'Drukuj'
	_hmg_printer_usermessages [10] := 'Numer strony'
	_hmg_printer_usermessages [11] := 'Tak'
	_hmg_printer_usermessages [12] := 'Przerwij'
	_hmg_printer_usermessages [13] := 'Wybierz drukarkê'
	_hmg_printer_usermessages [14] := 'Sortuj kopie'
	_hmg_printer_usermessages [15] := 'Zakres wydruku'
	_hmg_printer_usermessages [16] := 'Wszystkie'
	_hmg_printer_usermessages [17] := 'Strony'
	_hmg_printer_usermessages [18] := 'Od'
	_hmg_printer_usermessages [19] := 'Do'
	_hmg_printer_usermessages [20] := 'Kopie'
	_hmg_printer_usermessages [21] := 'Wszystkie'
	_hmg_printer_usermessages [22] := 'Nieparzyste'
	_hmg_printer_usermessages [23] := 'Parzyste'
	_hmg_printer_usermessages [24] := 'Tak'
	_hmg_printer_usermessages [25] := 'Nie'
	_hmg_printer_usermessages [26] := 'Zamknij'
	_hmg_printer_usermessages [27] := 'Zapisz'
	_hmg_printer_usermessages [28] := 'Thumbnails'
	_hmg_printer_usermessages [29] := 'Generujê Thumbnails... Proszê czekaæ...'

case cLang == "PT"   // Portuguese
/////////////////////////////////////////////////////////////
// PORTUGUESE
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Página'
	_hmg_printer_usermessages [02] := 'Visualização da Impressão'
	_hmg_printer_usermessages [03] := 'Primeira Página [HOME]'
	_hmg_printer_usermessages [04] := 'Página Anterior [PGUP]'
	_hmg_printer_usermessages [05] := 'Página Seguinte [PGDN]'
	_hmg_printer_usermessages [06] := 'Última Página [END]'
	_hmg_printer_usermessages [07] := 'Ir Para a Página Nº'
	_hmg_printer_usermessages [08] := 'Ampliar'
	_hmg_printer_usermessages [09] := 'Imprimir'
	_hmg_printer_usermessages [10] := 'Página'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Cancelar'
	_hmg_printer_usermessages [13] := 'Selecione a Impressora'
	_hmg_printer_usermessages [14] := 'Ordenar Cópias'
	_hmg_printer_usermessages [15] := 'Intervalo de Impressão'
	_hmg_printer_usermessages [16] := 'Tudo'
	_hmg_printer_usermessages [17] := 'Páginas'
	_hmg_printer_usermessages [18] := 'De'
	_hmg_printer_usermessages [19] := 'Até'
	_hmg_printer_usermessages [20] := 'Nº de Cópias'
	_hmg_printer_usermessages [21] := 'Todas as Páginas'
	_hmg_printer_usermessages [22] := ' Somente Páginas Impares'
	_hmg_printer_usermessages [23] := ' Somente Páginas Pares'
	_hmg_printer_usermessages [24] := 'Sim'
	_hmg_printer_usermessages [25] := 'Não'
	_hmg_printer_usermessages [26] := 'Fechar'
	_hmg_printer_usermessages [27] := 'Salvar'
	_hmg_printer_usermessages [28] := 'Miniaturas'
	_hmg_printer_usermessages [29] := 'Aguarde, Gerando Miniaturas...'

case cLang == "RU"   // Russian 
/////////////////////////////////////////////////////////////
// RUSSIAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Ñòðàíèöà'
	_hmg_printer_usermessages [02] := 'Ïðåäâàðèòåëüíûé ïðîñìîòð'
	_hmg_printer_usermessages [03] := 'Ïåðâàÿ [HOME]'
	_hmg_printer_usermessages [04] := 'Ïðåäûäóùàÿ [PGUP]'
	_hmg_printer_usermessages [05] := 'Ñëåäóþùàÿ [PGDN]'
	_hmg_printer_usermessages [06] := 'Ïîñëåäíÿÿ [END]'
	_hmg_printer_usermessages [07] := 'Ïåðåéòè ê'
	_hmg_printer_usermessages [08] := 'Ìàñøòàá'
	_hmg_printer_usermessages [09] := 'Ïå÷àòü'
	_hmg_printer_usermessages [10] := 'Ñòðàíèöà ¹'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Îòìåíà'
	_hmg_printer_usermessages [13] := 'Âûáîð ïðèíòåðà'
	_hmg_printer_usermessages [14] := 'Ñîðòèðîâêà êîïèé'
	_hmg_printer_usermessages [15] := 'Èíòåðâàë ïå÷àòè'
	_hmg_printer_usermessages [16] := 'Âñå'
	_hmg_printer_usermessages [17] := 'Ñòðàíèöû'
	_hmg_printer_usermessages [18] := 'Îò'
	_hmg_printer_usermessages [19] := 'Äî'
	_hmg_printer_usermessages [20] := 'Êîïèé'
	_hmg_printer_usermessages [21] := 'Âåñü èíòåðâàë'
	_hmg_printer_usermessages [22] := 'Íå÷åòíûå òîëüêî'
	_hmg_printer_usermessages [23] := '×åòíûå òîëüêî'
	_hmg_printer_usermessages [24] := 'Äà'
	_hmg_printer_usermessages [25] := 'Íåò'
	_hmg_printer_usermessages [26] := 'Çàêðûòü'
	_hmg_printer_usermessages [27] := 'Ñîõðàíèòü'
	_hmg_printer_usermessages [28] := 'Ìèíèàòþðû'
	_hmg_printer_usermessages [29] := 'Æäèòå, ãåíåðèðóþ ìèíèàòþðû...'

case cLang == "UK" .OR. cLang == "UA"   // Ukrainian 
/////////////////////////////////////////////////////////////
// UKRAINIAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Ñòîð³íêà'
	_hmg_printer_usermessages [02] := 'Ïîïåðåäí³é ïåðåãëÿä'
	_hmg_printer_usermessages [03] := 'Ïåðøà [HOME]'
	_hmg_printer_usermessages [04] := 'Ïîïåðåäíÿ [PGUP]'
	_hmg_printer_usermessages [05] := 'Íàñòóïíà [PGDN]'
	_hmg_printer_usermessages [06] := 'Îñòàííÿ [END]'
	_hmg_printer_usermessages [07] := 'Ïåðåéòè äî'
	_hmg_printer_usermessages [08] := 'Ìàñøòàá'
	_hmg_printer_usermessages [09] := 'Äðóê'
	_hmg_printer_usermessages [10] := 'Ñòîð³íêà ¹'
	_hmg_printer_usermessages [11] := 'Ãàðàçä'
	_hmg_printer_usermessages [12] := 'Â³äìîâà'
	_hmg_printer_usermessages [13] := 'Âèá³ð ïðèíòåðà'
	_hmg_printer_usermessages [14] := 'Ñîðòóâàííÿ êîï³é'
	_hmg_printer_usermessages [15] := '²íòåðâàë äðóêó'
	_hmg_printer_usermessages [16] := 'Óñ³'
	_hmg_printer_usermessages [17] := 'Ñòîð³íêè'
	_hmg_printer_usermessages [18] := 'Ç'
	_hmg_printer_usermessages [19] := 'Ïî'
	_hmg_printer_usermessages [20] := 'Êîï³é'
	_hmg_printer_usermessages [21] := 'Âåñü ³íòåðâàë'
	_hmg_printer_usermessages [22] := 'Ò³ëüêè íåïàðí³'
	_hmg_printer_usermessages [23] := 'Ò³ëüêè ïàðí³'
	_hmg_printer_usermessages [24] := 'Òàê'
	_hmg_printer_usermessages [25] := 'Í³'
	_hmg_printer_usermessages [26] := 'Çàêðèòè'
	_hmg_printer_usermessages [27] := 'Çáåðåãòè'
	_hmg_printer_usermessages [28] := 'Ì³í³àòþðè'
	_hmg_printer_usermessages [29] := 'Î÷³êóéòå, ãåíåðóþ ì³í³àòþðè...'

case cLang == "ES"   // Spanish
/////////////////////////////////////////////////////////////
// SPANISH
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Página'
	_hmg_printer_usermessages [02] := 'Vista Previa'
	_hmg_printer_usermessages [03] := 'Inicio [INICIO]'
	_hmg_printer_usermessages [04] := 'Anterior [REPAG]'
	_hmg_printer_usermessages [05] := 'Siguiente [AVPAG]'
	_hmg_printer_usermessages [06] := 'Fin [FIN]'
	_hmg_printer_usermessages [07] := 'Ir a'
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Imprimir'
	_hmg_printer_usermessages [10] := 'Página Nro.'
	_hmg_printer_usermessages [11] := 'Aceptar'
	_hmg_printer_usermessages [12] := 'Cancelar'
	_hmg_printer_usermessages [13] := 'Seleccionar Impresora'
	_hmg_printer_usermessages [14] := 'Ordenar Copias'
	_hmg_printer_usermessages [15] := 'Rango de Impresión'
	_hmg_printer_usermessages [16] := 'Todo'
	_hmg_printer_usermessages [17] := 'Páginas'
	_hmg_printer_usermessages [18] := 'Desde'
	_hmg_printer_usermessages [19] := 'Hasta'
	_hmg_printer_usermessages [20] := 'Copias'
	_hmg_printer_usermessages [21] := 'Todo El Rango'
	_hmg_printer_usermessages [22] := 'Solo Páginas Impares'
	_hmg_printer_usermessages [23] := 'Solo Páginas Pares'
	_hmg_printer_usermessages [24] := 'Si'
	_hmg_printer_usermessages [25] := 'No'
	_hmg_printer_usermessages [26] := 'Cerrar'
	_hmg_printer_usermessages [27] := 'Guardar'
	_hmg_printer_usermessages [28] := 'Miniaturas'
	_hmg_printer_usermessages [29] := 'Generando Miniaturas... Espere Por Favor...'

case cLang == "FI"   // Finnish
///////////////////////////////////////////////////////////////////////
// FINNISH
///////////////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Page'
	_hmg_printer_usermessages [02] := 'Print Preview'
	_hmg_printer_usermessages [03] := 'First Page [HOME]'
	_hmg_printer_usermessages [04] := 'Previous Page [PGUP]'
	_hmg_printer_usermessages [05] := 'Next Page [PGDN]'
	_hmg_printer_usermessages [06] := 'Last Page [END]'
	_hmg_printer_usermessages [07] := 'Go To Page'
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Print'
	_hmg_printer_usermessages [10] := 'Page Number'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Cancel'
	_hmg_printer_usermessages [13] := 'Select Printer'
	_hmg_printer_usermessages [14] := 'Collate Copies'
	_hmg_printer_usermessages [15] := 'Print Range'
	_hmg_printer_usermessages [16] := 'All'
	_hmg_printer_usermessages [17] := 'Pages'
	_hmg_printer_usermessages [18] := 'From'
	_hmg_printer_usermessages [19] := 'To'
	_hmg_printer_usermessages [20] := 'Copies'
	_hmg_printer_usermessages [21] := 'All Range'
	_hmg_printer_usermessages [22] := 'Odd Pages Only'
	_hmg_printer_usermessages [23] := 'Even Pages Only'
	_hmg_printer_usermessages [24] := 'Yes'
	_hmg_printer_usermessages [25] := 'No'
	_hmg_printer_usermessages [26] := 'Close'
	_hmg_printer_usermessages [27] := 'Save'
	_hmg_printer_usermessages [28] := 'Thumbnails'
	_hmg_printer_usermessages [29] := 'Generating Thumbnails... Please Wait...'

case cLang == "NL"   // Dutch
/////////////////////////////////////////////////////////////
// DUTCH
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Page'
	_hmg_printer_usermessages [02] := 'Print Preview'
	_hmg_printer_usermessages [03] := 'First Page [HOME]'
	_hmg_printer_usermessages [04] := 'Previous Page [PGUP]'
	_hmg_printer_usermessages [05] := 'Next Page [PGDN]'
	_hmg_printer_usermessages [06] := 'Last Page [END]'
	_hmg_printer_usermessages [07] := 'Go To Page'
	_hmg_printer_usermessages [08] := 'Zoom'
	_hmg_printer_usermessages [09] := 'Print'
	_hmg_printer_usermessages [10] := 'Page Number'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Cancel'
	_hmg_printer_usermessages [13] := 'Select Printer'
	_hmg_printer_usermessages [14] := 'Collate Copies'
	_hmg_printer_usermessages [15] := 'Print Range'
	_hmg_printer_usermessages [16] := 'All'
	_hmg_printer_usermessages [17] := 'Pages'
	_hmg_printer_usermessages [18] := 'From'
	_hmg_printer_usermessages [19] := 'To'
	_hmg_printer_usermessages [20] := 'Copies'
	_hmg_printer_usermessages [21] := 'All Range'
	_hmg_printer_usermessages [22] := 'Odd Pages Only'
	_hmg_printer_usermessages [23] := 'Even Pages Only'
	_hmg_printer_usermessages [24] := 'Yes'
	_hmg_printer_usermessages [25] := 'No'
	_hmg_printer_usermessages [26] := 'Close'
	_hmg_printer_usermessages [27] := 'Save'
	_hmg_printer_usermessages [28] := 'Thumbnails'
	_hmg_printer_usermessages [29] := 'Generating Thumbnails... Please Wait...'

case cLang == "SL"   // Slovenian
/////////////////////////////////////////////////////////////
// SLOVENIAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Stran'
	_hmg_printer_usermessages [02] := 'Predgled tiskanja'
	_hmg_printer_usermessages [03] := 'Prva stran [HOME]'
	_hmg_printer_usermessages [04] := 'Prej¹nja stran [PGUP]'
	_hmg_printer_usermessages [05] := 'Naslednja stran [PGDN]'
	_hmg_printer_usermessages [06] := 'Zadnja stran [END]'
	_hmg_printer_usermessages [07] := 'Pojdi na stran'
	_hmg_printer_usermessages [08] := 'Poveèava'
	_hmg_printer_usermessages [09] := 'Natisni'
	_hmg_printer_usermessages [10] := '©tevilka strani'
	_hmg_printer_usermessages [11] := 'V redu'
	_hmg_printer_usermessages [12] := 'Prekini'
	_hmg_printer_usermessages [13] := 'Izberi tiskalnik'
	_hmg_printer_usermessages [14] := 'Zbiranje kopij'
	_hmg_printer_usermessages [15] := 'Obseg tiskanja'
	_hmg_printer_usermessages [16] := 'Vse'
	_hmg_printer_usermessages [17] := 'Strani'
	_hmg_printer_usermessages [18] := 'od'
	_hmg_printer_usermessages [19] := 'do'
	_hmg_printer_usermessages [20] := 'Kopij'
	_hmg_printer_usermessages [21] := 'Ves obseg'
	_hmg_printer_usermessages [22] := 'Neparne strani'
	_hmg_printer_usermessages [23] := 'Parne strani'
	_hmg_printer_usermessages [24] := 'Ja'
	_hmg_printer_usermessages [25] := 'Ne'
	_hmg_printer_usermessages [26] := 'Zapri'
	_hmg_printer_usermessages [27] := 'Shrani'
	_hmg_printer_usermessages [28] := 'Slièice'
	_hmg_printer_usermessages [29] := 'Pripravljam slièice... prosim, poèakajte...'

case cLang == "SK"   // Slovak
/////////////////////////////////////////////////////////////
// SLOVAK
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Strana'
	_hmg_printer_usermessages [02] := 'Náh¾ad'
	_hmg_printer_usermessages [03] := 'Prvá strana [HOME]'
	_hmg_printer_usermessages [04] := 'Predcházajúca strana [PGUP]'
	_hmg_printer_usermessages [05] := 'Ïalšia strana [PGDN]'
	_hmg_printer_usermessages [06] := 'Posledná strana [END]'
	_hmg_printer_usermessages [07] := 'Ukaž stranu'
	_hmg_printer_usermessages [08] := 'Lupa'
	_hmg_printer_usermessages [09] := 'Tlaè'
	_hmg_printer_usermessages [10] := 'Èíslo strany'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Storno'
	_hmg_printer_usermessages [13] := 'Vyberte tlaèiáreò'
	_hmg_printer_usermessages [14] := 'Zoradenie'
	_hmg_printer_usermessages [15] := 'Rozsah tlaèe'
	_hmg_printer_usermessages [16] := 'všetko'
	_hmg_printer_usermessages [17] := 'strany'
	_hmg_printer_usermessages [18] := 'od'
	_hmg_printer_usermessages [19] := 'po'
	_hmg_printer_usermessages [20] := 'kópií'
	_hmg_printer_usermessages [21] := 'všetky strany'
	_hmg_printer_usermessages [22] := 'nepárné strany'
	_hmg_printer_usermessages [23] := 'párné strany'
	_hmg_printer_usermessages [24] := 'Áno'
	_hmg_printer_usermessages [25] := 'Nie'
	_hmg_printer_usermessages [26] := 'Zatvor'
	_hmg_printer_usermessages [27] := 'Ulož'
	_hmg_printer_usermessages [28] := 'Miniatury'
	_hmg_printer_usermessages [29] := 'Generujem miniatury... Èakajte, prosím...'

case cLang == "HU"   // Hungarian
/////////////////////////////////////////////////////////////
// HUNGARIAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Oldal'
	_hmg_printer_usermessages [02] := 'Elõnézet'
	_hmg_printer_usermessages [03] := 'Elsõ oldal [HOME]'
	_hmg_printer_usermessages [04] := 'Elõzõ oldal [PGUP]'
	_hmg_printer_usermessages [05] := 'Következõ oldal [PGDN]'
	_hmg_printer_usermessages [06] := 'Utolsó oldal [END]'
	_hmg_printer_usermessages [07] := 'Oldalt mutasd'
	_hmg_printer_usermessages [08] := 'Nagyító'
	_hmg_printer_usermessages [09] := 'Nyomtasd'
	_hmg_printer_usermessages [10] := 'Oldal száma'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Elvetés'
	_hmg_printer_usermessages [13] := 'Válasszon nyomtatót'
	_hmg_printer_usermessages [14] := 'Rendezve'
	_hmg_printer_usermessages [15] := 'Oldalak nyomtatása'
	_hmg_printer_usermessages [16] := 'mindent'
	_hmg_printer_usermessages [17] := 'Oldalakat'
	_hmg_printer_usermessages [18] := 'ettõl'
	_hmg_printer_usermessages [19] := 'eddig'
	_hmg_printer_usermessages [20] := 'másolat'
	_hmg_printer_usermessages [21] := 'Minden oldalt'
	_hmg_printer_usermessages [22] := 'páros oldalakat'
	_hmg_printer_usermessages [23] := 'páratlan oldalakat'
	_hmg_printer_usermessages [24] := 'Igen'
	_hmg_printer_usermessages [25] := 'Nem'
	_hmg_printer_usermessages [26] := 'Zárd be'
	_hmg_printer_usermessages [27] := 'Mentsd'
	_hmg_printer_usermessages [28] := 'Miniatúrák'
	_hmg_printer_usermessages [29] := 'Miniatúrák létrehozása... Kérem, várjon...'

case cLang == "BG"   // Bulgarian 
/////////////////////////////////////////////////////////////
// BULGARIAN
////////////////////////////////////////////////////////////

	_hmg_printer_usermessages [01] := 'Ñòðàíèöà'
	_hmg_printer_usermessages [02] := 'Ïðåäâàðèòåëåí ïðåãëåä'
	_hmg_printer_usermessages [03] := 'Ïúðâà [HOME]'
	_hmg_printer_usermessages [04] := 'Ïðåäèäóùà [PGUP]'
	_hmg_printer_usermessages [05] := 'Ñëåäâùà [PGDN]'
	_hmg_printer_usermessages [06] := 'Ïîñëåäíà [END]'
	_hmg_printer_usermessages [07] := 'Èäè íà'
	_hmg_printer_usermessages [08] := 'Ìàùàá'
	_hmg_printer_usermessages [09] := 'Ïå÷àò'
	_hmg_printer_usermessages [10] := 'Ñòðàíèöà ¹'
	_hmg_printer_usermessages [11] := 'Ok'
	_hmg_printer_usermessages [12] := 'Îòìÿíà'
	_hmg_printer_usermessages [13] := 'Èçáîð íà ïðèíòåð'
	_hmg_printer_usermessages [14] := 'Ñîðòèðîâêà íà êîïèÿòà'
	_hmg_printer_usermessages [15] := 'Èíòåðâàë çà ïå÷àò'
	_hmg_printer_usermessages [16] := 'Âñè÷êè'
	_hmg_printer_usermessages [17] := 'Ñòðàíèöè'
	_hmg_printer_usermessages [18] := 'Îò'
	_hmg_printer_usermessages [19] := 'Äî'
	_hmg_printer_usermessages [20] := 'Êîïèÿ'
	_hmg_printer_usermessages [21] := 'Öåëèÿ èíòåðâàë'
	_hmg_printer_usermessages [22] := 'Ñàìî íå÷åòíèòå'
	_hmg_printer_usermessages [23] := 'Ñàìî ÷åòíèòå'
	_hmg_printer_usermessages [24] := 'Äà'
	_hmg_printer_usermessages [25] := 'Íå'
	_hmg_printer_usermessages [26] := 'Çàòâîðè'
	_hmg_printer_usermessages [27] := 'Ñúõðàíè'
	_hmg_printer_usermessages [28] := 'Ìèíèàòþðè'
	_hmg_printer_usermessages [29] := 'Èç÷àêàéòå, ãåíåðèðàì ìèíèàòþðè...'

endcase

#endif

Return

*------------------------------------------------------------------------------*
FUNCTION GETPRINTABLEAREAWIDTH()
*------------------------------------------------------------------------------*

RETURN _HMG_PRINTER_GETPRINTERWIDTH ( _hmg_printer_hdc )

*------------------------------------------------------------------------------*
FUNCTION GETPRINTABLEAREAHEIGHT()
*------------------------------------------------------------------------------*

RETURN _HMG_PRINTER_GETPRINTERHEIGHT ( _hmg_printer_hdc )

*------------------------------------------------------------------------------*
FUNCTION GETPRINTABLEAREAHORIZONTALOFFSET()
*------------------------------------------------------------------------------*

	IF TYPE ( '_hmg_miniprint[19]' ) == 'U'
		RETURN 0
	ENDIF

RETURN ( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETX ( _hmg_printer_hdc ) / _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSX ( _hmg_printer_hdc ) * 25.4 )

*------------------------------------------------------------------------------*
FUNCTION GETPRINTABLEAREAVERTICALOFFSET()
*------------------------------------------------------------------------------*

	IF TYPE ( '_hmg_miniprint[19]' ) == 'U'
		RETURN 0
	ENDIF

RETURN ( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETY ( _hmg_printer_hdc ) / _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSY ( _hmg_printer_hdc ) * 25.4 )

*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_MouseZoom
*------------------------------------------------------------------------------*
Local Width := GetDesktopWidth()
Local Height := GetDesktopHeight()
Local Q := 0
Local DeltaHeight := 35 + GetTitleHeight() + GetBorderHeight() + 10

	If _hmg_printer_Dz == 1000 + _HMG_PRINTER_DELTA_ZOOM

		_hmg_printer_Dz := 0
		_hmg_printer_Dx := 0
		_hmg_printer_Dy := 0

		SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 50 , .t. )
		SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 50 , .t. )

		_HMG_PRINTER_PREVIEW_DISABLESCROLLBARS (GetFormHandle('_HMG_PRINTER_SHOWPREVIEW'))

	Else

		* Calculate Quadrant

		if	_HMG_MouseCol <= ( Width / 2 ) - _hmg_printer_zoomclick_xoffset ;
			.And. ;
			_HMG_MouseRow <= ( Height / 2 )	- DeltaHeight
		
			Q := 1

		Elseif	_HMG_MouseCol > ( Width / 2 ) - _hmg_printer_zoomclick_xoffset ;
			.And. ;
			_HMG_MouseRow <= ( Height / 2 )	- DeltaHeight
	
			Q := 2

		Elseif	_HMG_MouseCol <= ( Width / 2 ) - _hmg_printer_zoomclick_xoffset ;
			.And. ;
			_HMG_MouseRow > ( Height / 2 ) - DeltaHeight		
	
			Q := 3

		Elseif	_HMG_MouseCol > ( Width / 2 ) - _hmg_printer_zoomclick_xoffset ;
			.And. ;
			_HMG_MouseRow > ( Height / 2 ) - DeltaHeight		
	
			Q := 4

		EndIf

		if	_HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) ;
			> ;
			_HMG_PRINTER_GETPAGEWIDTH(_hmg_printer_hdc_bak) 

			* Portrait

			If Q == 1 
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := 100
				_hmg_printer_Dy := 400
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 10 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 40 , .t. )
			ElseIf Q == 2
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := -100
				_hmg_printer_Dy := 400
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 10 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 60 , .t. )
			ElseIf Q == 3
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := 100
				_hmg_printer_Dy := -400
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 90 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 40 , .t. )
			ElseIf Q == 4
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := -100
				_hmg_printer_Dy := -400
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 90 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 60 , .t. )
			EndIf				

		Else

			* Landscape

			If Q == 1 
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := 500
				_hmg_printer_Dy := 300
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 20 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 1 , .t. )
			ElseIf Q == 2
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := -500
				_hmg_printer_Dy := 300
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 20 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 99 , .t. )
			ElseIf Q == 3
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := 500
				_hmg_printer_Dy := -300
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 80 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 1 , .t. )
			ElseIf Q == 4
				_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
				_hmg_printer_Dx := -500
				_hmg_printer_Dy := -300
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 80 , .t. )
				SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 99 , .t. )
			EndIf				

		EndIf

		_HMG_PRINTER_PREVIEW_ENABLESCROLLBARS (GetFormHandle('_HMG_PRINTER_SHOWPREVIEW'))

	EndIf

	_HMG_PRINTER_PREVIEWRefresh()

Return

*------------------------------------------------------------------------------*
Procedure _HMG_PRINTER_Zoom
*------------------------------------------------------------------------------*

	If _hmg_printer_Dz == 1000 + _HMG_PRINTER_DELTA_ZOOM

		_hmg_printer_Dz := 0
		_hmg_printer_Dx := 0
		_hmg_printer_Dy := 0

		SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 50 , .t. )
		SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 50 , .t. )

		_HMG_PRINTER_PREVIEW_DISABLESCROLLBARS (GetFormHandle('_HMG_PRINTER_SHOWPREVIEW'))

	Else

		if	_HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) ;
			> ;
			_HMG_PRINTER_GETPAGEWIDTH(_hmg_printer_hdc_bak) 

			_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
			_hmg_printer_Dx := 100
			_hmg_printer_Dy := 400
			SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 10 , .t. )
			SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 40 , .t. )

		Else

			_hmg_printer_Dz := 1000 + _HMG_PRINTER_DELTA_ZOOM
			_hmg_printer_Dx := 500
			_hmg_printer_Dy := 300
			SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 20 , .t. )
			SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 1 , .t. )

		EndIf

		_HMG_PRINTER_PREVIEW_ENABLESCROLLBARS (GetFormHandle('_HMG_PRINTER_SHOWPREVIEW'))

	EndIf

	_HMG_PRINTER_PREVIEWRefresh()

Return

*------------------------------------------------------------------------------*
FUNCTION _hmg_printer_setjobname( cName )
*------------------------------------------------------------------------------*
   RETURN hb_defaultValue( cName , 'HMGPrintSys' ) // avoid problematic (long & spaced) name
*------------------------------------------------------------------------------*
FUNCTION HMG_PrintGetJobInfo ( aJobData )   // by Dr. Claudio Soto, August 2015
*------------------------------------------------------------------------------*
   IF ValType( aJobData ) == "U"
      aJobData := OpenPrinterGetJobData()
   ENDIF

RETURN _HMG_PrintGetJobInfo( aJobData [2], aJobData [1] ) // --> aJobInfo

*------------------------------------------------------------------------------*
FUNCTION HMG_PrinterGetStatus ( cPrinterName )
*------------------------------------------------------------------------------*
   IF ValType( cPrinterName ) == "U"
      cPrinterName := _hmg_printer_name
   ENDIF

RETURN _HMG_PrinterGetStatus( cPrinterName ) // --> nStatus

*-----------------------------------------------------------------------------*
FUNCTION _DefineEmfFile ( ControlName, ParentFormName, x, y, FileName, w, h, ;
      ProcedureName, HelpId, invisible, stretch, WhiteBackground, transparent )
*-----------------------------------------------------------------------------*
   LOCAL ParentFormHandle , mVar , action := .F. , k
   LOCAL ControlHandle

   IF ValType( ProcedureName ) == "U"
      ProcedureName := ""
   ELSE
      action := .T.
   ENDIF

   DEFAULT stretch TO FALSE, WhiteBackground TO FALSE, transparent TO FALSE

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   ParentFormHandle := GetFormHandle ( ParentFormName )

   ControlHandle := InitEmfFile ( ParentFormHandle, 0, x, y, invisible, action )

   Public &mVar. := k

   _HMG_aControlType  [k] :=  "IMAGE"
   _HMG_aControlNames [k] :=  ControlName
   _HMG_aControlHandles [k] :=  ControlHandle
   _HMG_aControlParentHandles  [k] :=  ParentFormHandle
   _HMG_aControlIds  [k] :=  0
   _HMG_aControlProcedures [k] :=  ProcedureName
   _HMG_aControlPageMap   [k] :=  {}
   _HMG_aControlValue  [k] :=  iif ( stretch, 1, 0 )
   _HMG_aControlInputMask  [k] :=  iif ( transparent, 1, 0 )
   _HMG_aControllostFocusProcedure  [k] :=  ""
   _HMG_aControlGotFocusProcedure  [k] :=  ""
   _HMG_aControlChangeProcedure  [k] :=  ""
   _HMG_aControlDeleted  [k] :=  .F.
   _HMG_aControlBkColor  [k] :=  Nil
   _HMG_aControlFontColor  [k] :=  Nil
   _HMG_aControlDblClick  [k] :=  ""
   _HMG_aControlHeadClick  [k] :=  {}
   _HMG_aControlRow  [k] :=  y
   _HMG_aControlCol  [k] :=  x
   _HMG_aControlWidth  [k] :=  w
   _HMG_aControlHeight  [k] :=  h
   _HMG_aControlSpacing  [k] :=  iif ( WhiteBackground, 1, 0 )
   _HMG_aControlContainerRow  [k] :=  -1
   _HMG_aControlContainerCol  [k] :=  -1
   _HMG_aControlPicture  [k] :=  FileName
   _HMG_aControlContainerHandle [k] :=  0
   _HMG_aControlFontName  [k] :=  ''
   _HMG_aControlFontSize  [k] :=  0
   _HMG_aControlFontAttributes  [k] :=  { .F. , .F. , .F. , .F. }
   _HMG_aControlToolTip   [k] :=  ''
   _HMG_aControlRangeMin  [k] :=  0
   _HMG_aControlRangeMax  [k] :=  0
   _HMG_aControlCaption  [k] :=  ''
   _HMG_aControlVisible  [k] :=  iif( invisible, .F. , .T. )
   _HMG_aControlHelpId  [k] :=  HelpId
   _HMG_aControlFontHandle  [k] :=   0
   _HMG_aControlBrushHandle [k] := C_SetEmfFile ( ControlHandle , FileName , W , H , _HMG_aControlValue [k] , _HMG_aControlSpacing [k] )
   _HMG_aControlEnabled  [k] :=  .T.
   _HMG_aControlMiscData1 [k] := 0
   _HMG_aControlMiscData2 [k] := ''

RETURN Nil
