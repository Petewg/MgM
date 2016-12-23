/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
 http://sites.google.com/site/hmgweb/

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
	www - http://harbour-project.org

	"Harbour Project"
        Copyright 1999-2016, http://harbour-project.org/

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

#include "hmg.ch"
#include "hp_images.ch"

#define SB_HORZ		0
#define SB_VERT		1

#xtranslate Alltrim( Str( <i> ) ) => hb_ntos( <i> )

DECLARE WINDOW _HMG_PRINTER_PPNAV

Static IsVistaThemed
Static aCoords

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

	DEFINE WINDOW _HMG_PRINTER_PPNAV ;
			AT 0,0 ;
			WIDTH GetDesktopWidth() - 103 - IF ( IsVistaThemed , 25 , 0);
			HEIGHT GetDesktopHeight() - 66 - IF ( IsVistaThemed , 25 , 0);
			TITLE _hmg_printer_usermessages [01] + ' [' + alltrim(str(_hmg_printer_CurrentPageNumber)) + '/' + ;
                                                                      alltrim(str(_hmg_printer_PageCount)) + ']' ;
			CHILD ;
			NOSIZE ;
			NOMINIMIZE ;
			NOMAXIMIZE ;
			NOSYSMENU ;
			BACKCOLOR GRAY ;
			ON GOTFOCUS iif( IsWin8OrLater(), _HMG_PRINTER_PREVIEWRefresh(), ) ;
			ON PAINT _HMG_PRINTER_PREVIEWRefresh()

		DEFINE SPLITBOX

			DEFINE TOOLBAR ToolBar_1 CAPTION _hmg_printer_usermessages [02] BUTTONSIZE 25,25 FLAT

				BUTTON b2 PICTURE IMG_BACK TOOLTIP _hmg_printer_usermessages [04] ACTION ( _hmg_printer_CurrentPageNumber-- , _HMG_PRINTER_PREVIEWRefresh() )

				BUTTON b3 PICTURE IMG_NEXT TOOLTIP _hmg_printer_usermessages [05] ACTION ( _hmg_printer_CurrentPageNumber++ , _HMG_PRINTER_PREVIEWRefresh() ) SEPARATOR

				BUTTON b1 PICTURE IMG_TOP TOOLTIP _hmg_printer_usermessages [03] ACTION ( _hmg_printer_CurrentPageNumber:=1 , _HMG_PRINTER_PREVIEWRefresh() )

				BUTTON b4 PICTURE IMG_END TOOLTIP _hmg_printer_usermessages [06] ACTION ( _hmg_printer_CurrentPageNumber:= _hmg_printer_PageCount, _HMG_PRINTER_PREVIEWRefresh() ) SEPARATOR

				BUTTON GoToPage PICTURE IMG_GOPAGE TOOLTIP _hmg_printer_usermessages [07] + ' [Ctrl+G]' ACTION _HMG_PRINTER_GO_TO_PAGE() SEPARATOR

				BUTTON thumbswitch PICTURE IMG_THUMBNAIL TOOLTIP _hmg_printer_usermessages [28] + ' [Ctrl+T]' ACTION _HMG_PRINTER_ProcessTHUMBNAILS() CHECK SEPARATOR

				BUTTON b5 PICTURE IMG_ZOOM TOOLTIP _hmg_printer_usermessages [08] + ' [*]' ACTION _HMG_PRINTER_Zoom() CHECK SEPARATOR

				BUTTON b12 PICTURE IMG_PRINT TOOLTIP _hmg_printer_usermessages [09] + ' [Ctrl+P]' ACTION _HMG_PRINTER_PrintPages()

				BUTTON b7 PICTURE IMG_SAVE TOOLTIP _hmg_printer_usermessages [27] + ' [Ctrl+S]' ACTION _hmg_printer_savepages() SEPARATOR

				BUTTON b6 PICTURE IMG_CLOSE TOOLTIP _hmg_printer_usermessages [26] + ' [Ctrl+C]' ACTION _HMG_PRINTER_PreviewClose()

			END TOOLBAR 

		DEFINE WINDOW _HMG_PRINTER_SHOWPREVIEW ;
			WIDTH GetDesktopWidth() - 103 - IF ( IsVistaThemed , 25 , 0);
			HEIGHT GetDesktopHeight() - 140  - IF ( IsVistaThemed , 25 , 0);
			VIRTUAL WIDTH ( GetDesktopWidth() - 103 ) * 2 ;
			VIRTUAL HEIGHT ( GetDesktopHeight() - 140 ) * 2 ;
			SPLITCHILD NOCAPTION ;
			ON SCROLLUP	_HMG_PRINTER_ScrolluP() ;
			ON SCROLLDOWN	_HMG_PRINTER_ScrollDown() ;
			ON SCROLLLEFT	_HMG_PRINTER_ScrollLeft() ;
			ON SCROLLRIGHT	_HMG_PRINTER_ScrollRight() ;
			ON HSCROLLBOX	_HMG_PRINTER_hScrollBoxProcess() ;
			ON VSCROLLBOX	_HMG_PRINTER_vScrollBoxProcess() 

			_HMG_PRINTER_SetKeys( '_HMG_PRINTER_SHOWPREVIEW' )

		END WINDOW

		CREATE EVENT PROCNAME _HMG_PRINTER_SpltChldMouseClick()

		END SPLITBOX

		_HMG_PRINTER_SetKeys( '_HMG_PRINTER_PPNAV' )

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

	if tvHeight <= GetDesktopHeight() - 66
		_hmg_printer_thumbscroll := .f.
		tvHeight := GetDesktopHeight() - 65
	else
		_hmg_printer_thumbscroll := .t.
	EndIf

	DEFINE WINDOW _HMG_PRINTER_SHOWTHUMBNAILS ;
		AT 0,5 ;
		WIDTH 130 ;
		HEIGHT GetDesktopHeight() - 66 - IF ( IsVistaThemed , 25 , 0) ;
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

	SetScrollRange ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 0 , 100 , .t. )
	SetScrollRange ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 0 , 100 , .t. )

	SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_VERT , 50 , .t. )
	SetScrollPos ( GetFormHandle('_HMG_PRINTER_SHOWPREVIEW') , SB_HORZ , 50 , .t. )

	_HMG_PRINTER_PREVIEW_DISABLESCROLLBARS (GetFormHandle('_HMG_PRINTER_SHOWPREVIEW'))

	_HMG_PRINTER_PREVIEW_DISABLEHSCROLLBAR (GetFormHandle('_HMG_PRINTER_SHOWTHUMBNAILS'))

	CENTER WINDOW _HMG_PRINTER_PPNAV

	Tmp := _HMG_PRINTER_PPNAV.ROW

	_HMG_PRINTER_SHOWTHUMBNAILS.ROW := Tmp

	ACTIVATE WINDOW _HMG_PRINTER_PRINTPAGES , _HMG_PRINTER_GO_TO_PAGE , _HMG_PRINTER_SHOWTHUMBNAILS , _HMG_PRINTER_Wait , _HMG_PRINTER_PPNAV 

	EventRemove()
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

		_HMG_PRINTER_PPNAV.Width := GetDesktopWidth() - 148 - IF ( IsVistaThemed , 30 , 0 )

		_HMG_PRINTER_PPNAV.Col := 138 + IF ( IsVistaThemed , 20 , 0 )

		_HMG_PRINTER_PREVIEWRefresh()

		ShowWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) ) 

	Else

		_hmg_printer_zoomclick_xoffset := 0

		_hmg_printer_SizeFactor := GetDesktopHeight() / _HMG_PRINTER_GETPAGEHEIGHT(_hmg_printer_hdc_bak) * 0.63

		_HMG_PRINTER_PPNAV.Width := GetDesktopWidth() - 103

		_HMG_PRINTER_PPNAV.Col := 51

		HideWindow ( GetFormHandle ( "_HMG_PRINTER_SHOWTHUMBNAILS" ) )

		_HMG_PRINTER_SHOWPREVIEW.SetFocus

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

	_HMG_PRINTER_SHOWPREVIEW.SetFocus

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
	_HMG_PRINTER_GO_TO_PAGE.Release
	_HMG_PRINTER_PRINTPAGES.Release
	_HMG_PRINTER_PPNAV.Release

Return
*------------------------------------------------------------------------------*
Static Function _HMG_PRINTER_SpltChldMouseCursor()   // Claudio Soto, April 2014
*------------------------------------------------------------------------------*
Local hWnd, aPos, IsPoint
Static lFlag := .F.

   IF _IsWindowDefined ( "_HMG_PRINTER_SHOWPREVIEW" ) .AND. ValType( aCoords ) == 'A'
      hWnd := GetFormHandle( "_HMG_PRINTER_SHOWPREVIEW" )
      aPos := GetCursorPos( hWnd )

      IsPoint := PtInRect( aPos, aCoords )

      IF IsPoint == .T. .AND. lFlag == .F.
         lFlag := .T.
         SetWindowCursor( hWnd, IMG_CURSOR )
      ELSEIF IsPoint == .F. .AND. lFlag == .T.
         lFlag := .F.
         SetWindowCursor( hWnd, IDC_ARROW )
      ENDIF
   ENDIF

Return lFlag
*------------------------------------------------------------------------------*
Function _HMG_PRINTER_SpltChldMouseClick( hWnd, nMsg, wParam, lParam )   // Pablo Cesar and Claudio Soto, April 2014
*------------------------------------------------------------------------------*
Local RetVal := Nil
Local Flag := _HMG_PRINTER_SpltChldMouseCursor()

   HB_SYMBOL_UNUSED( lParam )

   #define WM_SETCURSOR 32
   IF nMsg == WM_SETCURSOR
      IF wParam == GetControlHandle( "TOOLBAR_1", "_HMG_PRINTER_PPNAV" )
         RetVal := 0
         DoMethod( "_HMG_PRINTER_PPNAV", "SetFocus" )   // SetFocus for display ToolTip of the ToolBar define into SPLITBOX
      ENDIF
   ENDIF

   #define WM_LBUTTONDOWN 513
   IF nMsg == WM_LBUTTONDOWN .AND. Flag == .T.
      IF hWnd == GetFormHandle( "_HMG_PRINTER_SHOWPREVIEW" )  // Click in show page to print
         RetVal := 0
         _HMG_PRINTER_PPNAV.b5.Value := ! _HMG_PRINTER_PPNAV.b5.Value
         _HMG_PRINTER_MouseZoom()
      ENDIF
   ENDIF

Return RetVal
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

	aCoords := _HMG_PRINTER_SHOWPAGE ( _hmg_printer_BasePageName + strzero(_hmg_printer_CurrentPageNumber, 4) + ".emf" , GetFormHandle ('_HMG_PRINTER_SHOWPREVIEW') , _hmg_printer_hdc_bak , _hmg_printer_SizeFactor * 10000 , _hmg_printer_Dz , _hmg_printer_Dx , _hmg_printer_Dy )

	_HMG_PRINTER_PPNAV.TITLE := _hmg_printer_usermessages [01] + ' [' + alltrim(str(_hmg_printer_CurrentPageNumber)) + '/'+alltrim(str(_hmg_printer_PageCount)) + ']'

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
Local cDefaultPrinter	:= GetDefaultPrinter()
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
RETURN hb_defaultValue( cName , 'Harbour MiniGUI Print System' )

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


#pragma BEGINDUMP
///////////////////////////////////////////////////////////////////////////////
// LOW LEVEL C PRINT ROUTINES
///////////////////////////////////////////////////////////////////////////////
#ifndef CINTERFACE
  #define CINTERFACE
#endif

#include <mgdefs.h>
#include "hbapiitm.h"

#include "olectl.h"

#ifndef WC_STATIC
#define WC_STATIC  "Static"
#endif

static DWORD charset = DEFAULT_CHARSET;
extern HBITMAP HMG_LoadImage( char * FileName );

#if defined( __BORLANDC__ )
#undef MAKELONG
#define MAKELONG( a, b )      ( ( LONG ) ( ( ( WORD ) ( ( DWORD_PTR ) ( a ) & 0xffff ) ) | \
                                           ( ( ( DWORD ) ( ( WORD ) ( ( DWORD_PTR ) ( b ) & 0xffff ) ) ) << 16 ) ) )
#endif

HB_FUNC( _HMG_SETCHARSET )
{
   charset = ( DWORD ) hb_parnl( 1 );
}

HB_FUNC( _HMG_PRINTER_ABORTDOC )
{
   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   AbortDoc( hdcPrint );
}

HB_FUNC( _HMG_PRINTER_STARTDOC )
{

   DOCINFO docInfo;

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
   {
      ZeroMemory( &docInfo, sizeof( docInfo ) );
      docInfo.cbSize      = sizeof( docInfo );
      docInfo.lpszDocName = hb_parc( 2 );

      hb_retni( StartDoc( hdcPrint, &docInfo ) );
   }
}

HB_FUNC( _HMG_PRINTER_STARTPAGE )
{

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
      StartPage( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_C_PRINT )
{

   // 1:  Hdc
   // 2:  y
   // 3:  x
   // 4:  FontName
   // 5:  FontSize
   // 6:  R Color
   // 7:  G Color
   // 8:  B Color
   // 9:  Text
   // 10: Bold
   // 11: Italic
   // 12: Underline
   // 13: StrikeOut
   // 14: Color Flag
   // 15: FontName Flag
   // 16: FontSize Flag
   // 17: Angle Flag
   // 18: Angle

   HGDIOBJ hgdiobj;

   char FontName[ 32 ];
   int  FontSize;

   DWORD fdwItalic;
   DWORD fdwUnderline;
   DWORD fdwStrikeOut;

   int fnWeight;
   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   HFONT hfont;

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   int FontHeight;
   int FontAngle;

   if( hdcPrint != 0 )
   {

      // Bold

      if( hb_parl( 10 ) )
         fnWeight = FW_BOLD;
      else
         fnWeight = FW_NORMAL;

      // Italic

      if( hb_parl( 11 ) )
         fdwItalic = TRUE;
      else
         fdwItalic = FALSE;

      // UnderLine

      if( hb_parl( 12 ) )
         fdwUnderline = TRUE;
      else
         fdwUnderline = FALSE;

      // StrikeOut

      if( hb_parl( 13 ) )
         fdwStrikeOut = TRUE;
      else
         fdwStrikeOut = FALSE;

      // Color

      if( hb_parl( 14 ) )
      {
         r = hb_parni( 6 );
         g = hb_parni( 7 );
         b = hb_parni( 8 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Fontname

      if( hb_parl( 15 ) )
         strcpy( FontName, hb_parc( 4 ) );
      else
         strcpy( FontName, "Arial" );

      // FontSize

      if( hb_parl( 16 ) )
         FontSize = hb_parni( 5 );
      else
         FontSize = 10;

      // Angle

      if( hb_parl( 17 ) )
         FontAngle = hb_parni( 18 );
      else
         FontAngle = 0;

      FontHeight = -MulDiv( FontSize, GetDeviceCaps( hdcPrint, LOGPIXELSY ), 72 );

      hfont = CreateFont
              (
         FontHeight,
         0,
         FontAngle,
         FontAngle,
         fnWeight,
         fdwItalic,
         fdwUnderline,
         fdwStrikeOut,
         charset,
         OUT_TT_PRECIS,
         CLIP_DEFAULT_PRECIS,
         DEFAULT_QUALITY,
         FF_DONTCARE,
         FontName
              );

      hgdiobj = SelectObject( hdcPrint, hfont );

      SetTextColor( hdcPrint, RGB( r, g, b ) );
      SetBkMode( hdcPrint, TRANSPARENT );

      TextOut( hdcPrint,
               ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
               ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
               hb_parc( 9 ),
               strlen( hb_parc( 9 ) ) );

      SelectObject( hdcPrint, hgdiobj );

      DeleteObject( hfont );

   }

}

HB_FUNC( _HMG_PRINTER_C_MULTILINE_PRINT )
{

   // 1:  Hdc
   // 2:  y
   // 3:  x
   // 4:  FontName
   // 5:  FontSize
   // 6:  R Color
   // 7:  G Color
   // 8:  B Color
   // 9:  Text
   // 10: Bold
   // 11: Italic
   // 12: Underline
   // 13: StrikeOut
   // 14: Color Flag
   // 15: FontName Flag
   // 16: FontSize Flag
   // 17: ToRow
   // 18: ToCol
   // 19: Alignment

   UINT uFormat = 0;

   HGDIOBJ hgdiobj;

   char FontName[ 32 ];
   int  FontSize;

   DWORD fdwItalic;
   DWORD fdwUnderline;
   DWORD fdwStrikeOut;

   RECT rect;

   int fnWeight;
   int r;
   int g;
   int b;

   int x   = hb_parni( 3 );
   int y   = hb_parni( 2 );
   int toy = hb_parni( 17 );
   int tox = hb_parni( 18 );

   HFONT hfont;

   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   int FontHeight;

   if( hdcPrint != 0 )
   {

      // Bold

      if( hb_parl( 10 ) )
         fnWeight = FW_BOLD;
      else
         fnWeight = FW_NORMAL;

      // Italic

      if( hb_parl( 11 ) )
         fdwItalic = TRUE;
      else
         fdwItalic = FALSE;

      // UnderLine

      if( hb_parl( 12 ) )
         fdwUnderline = TRUE;
      else
         fdwUnderline = FALSE;

      // StrikeOut

      if( hb_parl( 13 ) )
         fdwStrikeOut = TRUE;
      else
         fdwStrikeOut = FALSE;

      // Color

      if( hb_parl( 14 ) )
      {
         r = hb_parni( 6 );
         g = hb_parni( 7 );
         b = hb_parni( 8 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Fontname

      if( hb_parl( 15 ) )
         strcpy( FontName, hb_parc( 4 ) );
      else
         strcpy( FontName, "Arial" );

      // FontSize

      if( hb_parl( 16 ) )
         FontSize = hb_parni( 5 );
      else
         FontSize = 10;

      FontHeight = -MulDiv( FontSize, GetDeviceCaps( hdcPrint, LOGPIXELSY ), 72 );

      hfont = CreateFont
              (
         FontHeight,
         0,
         0,
         0,
         fnWeight,
         fdwItalic,
         fdwUnderline,
         fdwStrikeOut,
         charset,
         OUT_TT_PRECIS,
         CLIP_DEFAULT_PRECIS,
         DEFAULT_QUALITY,
         FF_DONTCARE,
         FontName
              );

      if( hb_parni( 19 ) == 0 )
         uFormat = DT_END_ELLIPSIS | DT_NOPREFIX | DT_WORDBREAK | DT_LEFT;
      else if( hb_parni( 19 ) == 2 )
         uFormat = DT_END_ELLIPSIS | DT_NOPREFIX | DT_WORDBREAK | DT_RIGHT;
      else if( hb_parni( 19 ) == 6 )
         uFormat = DT_END_ELLIPSIS | DT_NOPREFIX | DT_WORDBREAK | DT_CENTER;

      hgdiobj = SelectObject( hdcPrint, hfont );

      SetTextColor( hdcPrint, RGB( r, g, b ) );
      SetBkMode( hdcPrint, TRANSPARENT );

      rect.left   = ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.top    = ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );
      rect.right  = ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.bottom = ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );

      DrawText( hdcPrint,
                hb_parc( 9 ),
                strlen( hb_parc( 9 ) ),
                &rect,
                uFormat
                );

      SelectObject( hdcPrint, hgdiobj );

      DeleteObject( hfont );

   }

}

HB_FUNC( _HMG_PRINTER_ENDPAGE )
{
   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
      EndPage( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_ENDDOC )
{
   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   if( hdcPrint != 0 )
      EndDoc( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_DELETEDC )
{
   HDC hdcPrint = ( HDC ) HB_PARNL( 1 );

   DeleteDC( hdcPrint );

}

HB_FUNC( _HMG_PRINTER_PRINTDIALOG )
{

   PRINTDLG pd;

   LPDEVMODE pDevMode;

   pd.lStructSize         = sizeof( PRINTDLG );
   pd.hDevMode            = ( HANDLE ) NULL;
   pd.hDevNames           = ( HANDLE ) NULL;
   pd.Flags               = PD_RETURNDC | PD_PRINTSETUP;
   pd.hwndOwner           = NULL;
   pd.hDC                 = NULL;
   pd.nFromPage           = 1;
   pd.nToPage             = 0xFFFF;
   pd.nMinPage            = 1;
   pd.nMaxPage            = 0xFFFF;
   pd.nCopies             = 1;
   pd.hInstance           = ( HINSTANCE ) NULL;
   pd.lCustData           = 0L;
   pd.lpfnPrintHook       = ( LPPRINTHOOKPROC ) NULL;
   pd.lpfnSetupHook       = ( LPSETUPHOOKPROC ) NULL;
   pd.lpPrintTemplateName = ( LPSTR ) NULL;
   pd.lpSetupTemplateName = ( LPSTR ) NULL;
   pd.hPrintTemplate      = ( HANDLE ) NULL;
   pd.hSetupTemplate      = ( HANDLE ) NULL;

   if( PrintDlg( &pd ) )
   {
      pDevMode = ( LPDEVMODE ) GlobalLock( pd.hDevMode );

      hb_reta( 4 );
      HB_STORVNL( ( LONG_PTR ) pd.hDC, -1, 1 );
      HB_STORC( ( const char * ) pDevMode->dmDeviceName, -1, 2 );
      HB_STORNI( pDevMode->dmCopies > 1 ? pDevMode->dmCopies : pd.nCopies, -1, 3 );
      HB_STORNI( pDevMode->dmCollate, -1, 4 );

      GlobalUnlock( pd.hDevMode );
   }
   else
   {
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );
   }

}

HB_FUNC( APRINTERS )
{

   OSVERSIONINFO osvi;

   HGLOBAL cBuffer;
   HGLOBAL pBuffer;

   DWORD dwSize     = 0;
   DWORD dwPrinters = 0;
   DWORD i;

   PRINTER_INFO_4 * pInfo4 = NULL;
   PRINTER_INFO_5 * pInfo  = NULL;

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );

   GetVersionEx( &osvi );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      EnumPrinters( PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, NULL, 4, NULL, 0, &dwSize, &dwPrinters );
   else
      EnumPrinters( PRINTER_ENUM_LOCAL, NULL, 5, NULL, 0, &dwSize, &dwPrinters );

   pBuffer = ( char * ) GlobalAlloc( GPTR, dwSize );

   if( pBuffer == NULL )
   {
      hb_reta( 0 );
      GlobalFree( pBuffer );
      return;
   }

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      EnumPrinters( PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, NULL, 4, ( LPBYTE ) pBuffer, dwSize, &dwSize, &dwPrinters );
   else
      EnumPrinters( PRINTER_ENUM_LOCAL, NULL, 5, ( LPBYTE ) pBuffer, dwSize, &dwSize, &dwPrinters );

   if( dwPrinters == 0 )
   {
      hb_reta( 0 );
      GlobalFree( pBuffer );
      return;
   }

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      pInfo4 = ( PRINTER_INFO_4 * ) pBuffer;
   else
      pInfo = ( PRINTER_INFO_5 * ) pBuffer;

   hb_reta( dwPrinters );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
      for( i = 0; i < dwPrinters; i++, pInfo4++ )
      {
         cBuffer = ( char * ) GlobalAlloc( GPTR, 256 );
         strcat( ( char * ) cBuffer, pInfo4->pPrinterName );
         HB_STORC( ( const char * ) cBuffer, -1, i + 1 );
         GlobalFree( cBuffer );
      }
   else
      for( i = 0; i < dwPrinters; i++, pInfo++ )
      {
         cBuffer = ( char * ) GlobalAlloc( GPTR, 256 );
         strcat( ( char * ) cBuffer, pInfo->pPrinterName );
         HB_STORC( ( const char * ) cBuffer, -1, i + 1 );
         GlobalFree( cBuffer );
      }

   GlobalFree( pBuffer );

}

HB_FUNC( _HMG_PRINTER_C_RECTANGLE )
{

   // 1: hDC
   // 2: y
   // 3: x
   // 4: toy
   // 5: tox
   // 6: width
   // 7: R Color
   // 8: G Color
   // 9: B Color
   // 10: lWidth
   // 11: lColor
   // 12: lFilled

   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   int tox = hb_parni( 5 );
   int toy = hb_parni( 4 );

   int width;

   HDC     hdcPrint = ( HDC ) HB_PARNL( 1 );
   HGDIOBJ hgdiobj;
   HBRUSH  hbrush = NULL;
   HPEN    hpen   = NULL;
   RECT    rect;

   if( hdcPrint != 0 )
   {

      // Width

      if( hb_parl( 10 ) )
         width = hb_parni( 6 );
      else
         width = 1 * 10000 / 254;

      // Color

      if( hb_parl( 11 ) )
      {
         r = hb_parni( 7 );
         g = hb_parni( 8 );
         b = hb_parni( 9 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Filled

      if( hb_parl( 12 ) )
      {
         hbrush  = CreateSolidBrush( ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( hdcPrint, hbrush );
      }
      else
      {
         hpen    = CreatePen( PS_SOLID, ( width * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ), ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( hdcPrint, hpen );
      }

      // Border  ( contributed by Alen Uzelac 08.06.2011 )

      rect.left   = ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.top    = ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );
      rect.right  = ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      rect.bottom = ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );

      if( hb_parl( 12 ) && hb_parl( 13 ) )
         FillRect( hdcPrint, &rect, ( HBRUSH ) hbrush );
      else
         Rectangle( hdcPrint, rect.left, rect.top, rect.right, rect.bottom );

      SelectObject( hdcPrint, ( HGDIOBJ ) hgdiobj );

      if( hb_parl( 12 ) )
         DeleteObject( hbrush );
      else
         DeleteObject( hpen );

   }

}

HB_FUNC( _HMG_PRINTER_C_ROUNDRECTANGLE )
{

   // 1: hDC
   // 2: y
   // 3: x
   // 4: toy
   // 5: tox
   // 6: width
   // 7: R Color
   // 8: G Color
   // 9: B Color
   // 10: lWidth
   // 11: lColor
   // 12: lFilled

   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   int tox = hb_parni( 5 );
   int toy = hb_parni( 4 );

   int width;

   int w, h, p;

   HDC     hdcPrint = ( HDC ) HB_PARNL( 1 );
   HGDIOBJ hgdiobj;
   HBRUSH  hbrush = NULL;
   HPEN    hpen   = NULL;

   if( hdcPrint != 0 )
   {

      // Width

      if( hb_parl( 10 ) )
         width = hb_parni( 6 );
      else
         width = 1 * 10000 / 254;

      // Color

      if( hb_parl( 11 ) )
      {
         r = hb_parni( 7 );
         g = hb_parni( 8 );
         b = hb_parni( 9 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      // Filled

      if( hb_parl( 12 ) )
      {
         hbrush  = CreateSolidBrush( ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( ( HDC ) hdcPrint, hbrush );
      }
      else
      {
         hpen    = CreatePen( PS_SOLID, ( width * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ), ( COLORREF ) RGB( r, g, b ) );
         hgdiobj = SelectObject( ( HDC ) hdcPrint, hpen );
      }

      w = ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 );
      h = ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 );
      p = ( w + h ) / 2;
      p = p / 10;

      RoundRect( ( HDC ) hdcPrint,
                 ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
                 ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
                 ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
                 ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
                 p,
                 p
                 );

      SelectObject( hdcPrint, ( HGDIOBJ ) hgdiobj );

      if( hb_parl( 12 ) )
         DeleteObject( hbrush );
      else
         DeleteObject( hpen );

   }

}

HB_FUNC( _HMG_PRINTER_C_LINE )
{

   // 1: hDC
   // 2: y
   // 3: x
   // 4: toy
   // 5: tox
   // 6: width
   // 7: R Color
   // 8: G Color
   // 9: B Color
   // 10: lWindth
   // 11: lColor
   // 12: lDotted

   int r;
   int g;
   int b;

   int x = hb_parni( 3 );
   int y = hb_parni( 2 );

   int tox = hb_parni( 5 );
   int toy = hb_parni( 4 );

   int width;

   HDC     hdcPrint = ( HDC ) HB_PARNL( 1 );
   HGDIOBJ hgdiobj;
   HPEN    hpen;

   if( hdcPrint != 0 )
   {

      // Width

      if( hb_parl( 10 ) )
         width = hb_parni( 6 );
      else
         width = 1 * 10000 / 254;

      // Color

      if( hb_parl( 11 ) )
      {
         r = hb_parni( 7 );
         g = hb_parni( 8 );
         b = hb_parni( 9 );
      }
      else
      {
         r = 0;
         g = 0;
         b = 0;
      }

      hpen = CreatePen( hb_parl( 12 ) ? PS_DASH : PS_SOLID, ( width * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ), ( COLORREF ) RGB( r, g, b ) );

      hgdiobj = SelectObject( hdcPrint, hpen );

      MoveToEx( hdcPrint,
                ( x * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
                ( y * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY ),
                NULL
                );

      LineTo( hdcPrint,
              ( tox * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX ),
              ( toy * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY )
              );

      SelectObject( hdcPrint, ( HGDIOBJ ) hgdiobj );

      DeleteObject( hpen );

   }

}

HB_FUNC( _HMG_PRINTER_SETPRINTERPROPERTIES )
{
   HANDLE hPrinter = NULL;
   DWORD  dwNeeded = 0;
   PRINTER_INFO_2 * pi2;
   DEVMODE *        pDevMode = NULL;
   BOOL bFlag;
   LONG lFlag;

   HDC hdcPrint;

   int fields = 0;

   bFlag = OpenPrinter( ( LPSTR ) hb_parc( 1 ), &hPrinter, NULL );

   if( ! bFlag || ( hPrinter == NULL ) )
   {
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (001)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   SetLastError( 0 );

   bFlag = GetPrinter( hPrinter, 2, 0, 0, &dwNeeded );

   if( ( ! bFlag ) && ( ( GetLastError() != ERROR_INSUFFICIENT_BUFFER ) || ( dwNeeded == 0 ) ) )
   {
      ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (002)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   pi2 = ( PRINTER_INFO_2 * ) GlobalAlloc( GPTR, dwNeeded );

   if( pi2 == NULL )
   {
      ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (003)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   bFlag = GetPrinter( hPrinter, 2, ( LPBYTE ) pi2, dwNeeded, &dwNeeded );

   if( ! bFlag )
   {
      GlobalFree( pi2 );
      ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (004)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   if( pi2->pDevMode == NULL )
   {
      dwNeeded = DocumentProperties( NULL, hPrinter, ( LPSTR ) hb_parc( 1 ), NULL, NULL, 0 );
      if( dwNeeded <= 0 )
      {
         GlobalFree( pi2 );
         ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed! (005)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pDevMode = ( DEVMODE * ) GlobalAlloc( GPTR, dwNeeded );
      if( pDevMode == NULL )
      {
         GlobalFree( pi2 );
         ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed! (006)", "Error! (006)", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      lFlag = DocumentProperties( NULL, hPrinter, ( LPSTR ) hb_parc( 1 ), pDevMode, NULL, DM_OUT_BUFFER );
      if( lFlag != IDOK || pDevMode == NULL )
      {
         GlobalFree( pDevMode );
         GlobalFree( pi2 );
         ClosePrinter( hPrinter );
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed! (007)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode = pDevMode;
   }

   ///////////////////////////////////////////////////////////////////////
   // Specify Fields
   //////////////////////////////////////////////////////////////////////
   // Orientation
   if( hb_parni( 2 ) != -999 )
      fields = fields | DM_ORIENTATION;

   // PaperSize
   if( hb_parni( 3 ) != -999 )
      fields = fields | DM_PAPERSIZE;

   // PaperLength
   if( hb_parni( 4 ) != -999 )
      fields = fields | DM_PAPERLENGTH;

   // PaperWidth
   if( hb_parni( 5 ) != -999 )
      fields = fields | DM_PAPERWIDTH;

   // Copies
   if( hb_parni( 6 ) != -999 )
      fields = fields | DM_COPIES;

   // Default Source
   if( hb_parni( 7 ) != -999 )
      fields = fields | DM_DEFAULTSOURCE;

   // Print Quality
   if( hb_parni( 8 ) != -999 )
      fields = fields | DM_PRINTQUALITY;

   // Print Color
   if( hb_parni( 9 ) != -999 )
      fields = fields | DM_COLOR;

   // Print Duplex Mode
   if( hb_parni( 10 ) != -999 )
      fields = fields | DM_DUPLEX;

   // Print Collate
   if( hb_parni( 11 ) != -999 )
      fields = fields | DM_COLLATE;

   pi2->pDevMode->dmFields = fields;

   ///////////////////////////////////////////////////////////////////////
   // Load Fields
   //////////////////////////////////////////////////////////////////////
   // Orientation
   if( hb_parni( 2 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_ORIENTATION ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: ORIENTATION Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmOrientation = ( short ) hb_parni( 2 );
   }

   // PaperSize
   if( hb_parni( 3 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PAPERSIZE ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: PAPERSIZE Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPaperSize = ( short ) hb_parni( 3 );
   }

   // PaperLength
   if( hb_parni( 4 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PAPERLENGTH ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: PAPERLENGTH Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPaperLength = ( short ) ( hb_parni( 4 ) * 10 );
   }

   // PaperWidth
   if( hb_parni( 5 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PAPERWIDTH ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: PAPERWIDTH Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPaperWidth = ( short ) ( hb_parni( 5 ) * 10 );
   }

   // Copies
   if( hb_parni( 6 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_COPIES ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: COPIES Property Not Supported By Selected Printer", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmCopies = ( short ) hb_parni( 6 );
   }

   // Default Source
   if( hb_parni( 7 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_DEFAULTSOURCE ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: DEFAULTSOURCE Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmDefaultSource = ( short ) hb_parni( 7 );
   }

   // Print Quality
   if( hb_parni( 8 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_PRINTQUALITY ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: QUALITY Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmPrintQuality = ( short ) hb_parni( 8 );
   }

   // Print Color
   if( hb_parni( 9 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_COLOR ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: COLOR Property Not Supported By Selected Printer", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmColor = ( short ) hb_parni( 9 );
   }

   // Print Duplex
   if( hb_parni( 10 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_DUPLEX ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: DUPLEX Property Not Supported By Selected Printer", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmDuplex = ( short ) hb_parni( 10 );
   }

   // Print Collate
   if( hb_parni( 11 ) != -999 )
   {
      if( ! ( pi2->pDevMode->dmFields & DM_COLLATE ) )
      {
#ifdef _ERRORMSG_
         MessageBox( 0, "Printer Configuration Failed: COLLATE Property Not Supported By Selected Printer", "Error!",
                     MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
         hb_reta( 4 );
         HB_STORVNL( 0, -1, 1 );
         HB_STORC( "", -1, 2 );
         HB_STORNI( 0, -1, 3 );
         HB_STORNI( 0, -1, 4 );

         return;
      }

      pi2->pDevMode->dmCollate = ( short ) hb_parni( 11 );
   }

   //////////////////////////////////////////////////////////////////////

   pi2->pSecurityDescriptor = NULL;

   lFlag = DocumentProperties( NULL, hPrinter, ( LPSTR ) hb_parc( 1 ), pi2->pDevMode, pi2->pDevMode, DM_IN_BUFFER | DM_OUT_BUFFER );

   if( lFlag != IDOK )
   {
      GlobalFree( pi2 );
      ClosePrinter( hPrinter );
      if( pDevMode )
         GlobalFree( pDevMode );
#ifdef _ERRORMSG_
      MessageBox( 0, "Printer Configuration Failed! (008)", "Error!", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
#endif
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );

      return;
   }

   hdcPrint = CreateDC( NULL, TEXT( hb_parc( 1 ) ), NULL, pi2->pDevMode );

   if( hdcPrint != NULL )
   {
      hb_reta( 4 );
      HB_STORVNL( ( LONG_PTR ) hdcPrint, -1, 1 );
      HB_STORC( hb_parc( 1 ), -1, 2 );
      HB_STORNI( ( INT ) pi2->pDevMode->dmCopies, -1, 3 );
      HB_STORNI( ( INT ) pi2->pDevMode->dmCollate, -1, 4 );
   }
   else
   {
      hb_reta( 4 );
      HB_STORVNL( 0, -1, 1 );
      HB_STORC( "", -1, 2 );
      HB_STORNI( 0, -1, 3 );
      HB_STORNI( 0, -1, 4 );
   }

   if( pi2 )
      GlobalFree( pi2 );

   if( hPrinter )
      ClosePrinter( hPrinter );

   if( pDevMode )
      GlobalFree( pDevMode );

}

/* Already defined in xhb contrib library. p.d. 07/08/2016
#if ! ( defined( __XHARBOUR__ ) && ( defined( __MINGW32__ ) || defined( __POCC__ ) ) )

HB_FUNC( GETDEFAULTPRINTER )
{

   OSVERSIONINFO    osvi;
   LPPRINTER_INFO_5 PrinterInfo;
   DWORD Needed, Returned;
   DWORD BufferSize = 254;

   char DefaultPrinter[ 254 ];

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );

   GetVersionEx( &osvi );

   if( osvi.dwPlatformId == VER_PLATFORM_WIN32_WINDOWS )
   {

      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, NULL, 0, &Needed, &Returned );
      PrinterInfo = ( LPPRINTER_INFO_5 ) LocalAlloc( LPTR, Needed );
      EnumPrinters( PRINTER_ENUM_DEFAULT, NULL, 5, ( LPBYTE ) PrinterInfo, Needed, &Needed, &Returned );
      strcpy( DefaultPrinter, PrinterInfo->pPrinterName );
      LocalFree( PrinterInfo );

   }
   else if( osvi.dwPlatformId == VER_PLATFORM_WIN32_NT )
   {

      GetProfileString( "windows", "device", "", DefaultPrinter, BufferSize );
      strtok( DefaultPrinter, "," );

   }

   hb_retc( DefaultPrinter );

}

#endif
*/

HB_FUNC( _HMG_PRINTER_STARTPAGE_PREVIEW )
{

   HDC  tmpDC;
   RECT emfrect;

   SetRect( &emfrect, 0, 0, GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), HORZSIZE ) * 100, GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), VERTSIZE ) * 100 );

   tmpDC = CreateEnhMetaFile( ( HDC ) HB_PARNL( 1 ), hb_parc( 2 ), &emfrect, "" );

   HB_RETNL( ( LONG_PTR ) tmpDC );

}

HB_FUNC( _HMG_PRINTER_ENDPAGE_PREVIEW )
{
   DeleteEnhMetaFile( CloseEnhMetaFile( ( HDC ) HB_PARNL( 1 ) ) );
}

HB_FUNC( _HMG_PRINTER_SHOWPAGE )
{

   HENHMETAFILE hemf;
   HWND         hWnd = ( HWND ) HB_PARNL( 2 );
   HDC          hDCPrinter = ( HDC ) HB_PARNL( 3 );
   RECT         rct;
   RECT         aux;
   int          zw;
   int          zh;
   int          ClientWidth;
   int          ClientHeight;
   int          xOffset;
   int          yOffset;
   PAINTSTRUCT  ps;
   HDC          hDC = BeginPaint( hWnd, &ps );

   hemf = GetEnhMetaFile( hb_parc( 1 ) );

   GetClientRect( hWnd, &rct );

   ClientWidth  = rct.right - rct.left;
   ClientHeight = rct.bottom - rct.top;

   zw = hb_parni( 5 ) * GetDeviceCaps( hDCPrinter, HORZSIZE ) / 750;
   zh = hb_parni( 5 ) * GetDeviceCaps( hDCPrinter, VERTSIZE ) / 750;

   xOffset = ( ClientWidth - ( GetDeviceCaps( hDCPrinter, HORZSIZE ) * hb_parni( 4 ) / 10000 ) ) / 2;
   yOffset = ( ClientHeight - ( GetDeviceCaps( hDCPrinter, VERTSIZE ) * hb_parni( 4 ) / 10000 ) ) / 2;

   SetRect( &rct,
            xOffset + hb_parni( 6 ) - zw,
            yOffset + hb_parni( 7 ) - zh,
            xOffset + ( GetDeviceCaps( hDCPrinter, HORZSIZE ) * hb_parni( 4 ) / 10000 ) + hb_parni( 6 ) + zw,
            yOffset + ( GetDeviceCaps( hDCPrinter, VERTSIZE ) * hb_parni( 4 ) / 10000 ) + hb_parni( 7 ) + zh
            );

   FillRect( hDC, &rct, ( HBRUSH ) RGB( 255, 255, 255 ) );

   PlayEnhMetaFile( hDC, hemf, &rct );

   // Remove prints outside printable area

   // Right
   aux.top    = 0;
   aux.left   = rct.right;
   aux.right  = ClientWidth;
   aux.bottom = ClientHeight;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Bottom
   aux.top    = rct.bottom;
   aux.left   = 0;
   aux.right  = ClientWidth;
   aux.bottom = ClientHeight;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Top
   aux.top    = 0;
   aux.left   = 0;
   aux.right  = ClientWidth;
   aux.bottom = yOffset + hb_parni( 7 ) - zh;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Left
   aux.top    = 0;
   aux.left   = 0;
   aux.right  = xOffset + hb_parni( 6 ) - zw;
   aux.bottom = ClientHeight;
   FillRect( hDC, &aux, ( HBRUSH ) GetStockObject( GRAY_BRUSH ) );

   // Clean up

   DeleteEnhMetaFile( hemf );

   EndPaint( hWnd, &ps );
   ReleaseDC( hWnd, hDC );

   hb_reta (4);
   HB_STORVNL ((LONG) rct.left,   -1, 1); 
   HB_STORVNL ((LONG) rct.top,    -1, 2); 
   HB_STORVNL ((LONG) rct.right,  -1, 3); 
   HB_STORVNL ((LONG) rct.bottom, -1, 4); 
}

HB_FUNC( _HMG_PRINTER_GETPAGEWIDTH )
{
   hb_retni( GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), HORZSIZE ) );
}

HB_FUNC( _HMG_PRINTER_GETPAGEHEIGHT )
{
   hb_retni( GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), VERTSIZE ) );
}

HB_FUNC( _HMG_PRINTER_PRINTPAGE )
{

   HENHMETAFILE hemf;

   RECT rect;

   hemf = GetEnhMetaFile( hb_parc( 2 ) );

   SetRect( &rect, 0, 0, GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), HORZRES ), GetDeviceCaps( ( HDC ) HB_PARNL( 1 ), VERTRES ) );

   StartPage( ( HDC ) HB_PARNL( 1 ) );

   PlayEnhMetaFile( ( HDC ) HB_PARNL( 1 ), ( HENHMETAFILE ) hemf, &rect );

   EndPage( ( HDC ) HB_PARNL( 1 ) );

   DeleteEnhMetaFile( hemf );

}

HB_FUNC( _HMG_PRINTER_PREVIEW_ENABLESCROLLBARS )
{
   EnableScrollBar( ( HWND ) HB_PARNL( 1 ), SB_BOTH, ESB_ENABLE_BOTH  );
}

HB_FUNC( _HMG_PRINTER_PREVIEW_DISABLESCROLLBARS )
{
   EnableScrollBar( ( HWND ) HB_PARNL( 1 ), SB_BOTH, ESB_DISABLE_BOTH );
}

HB_FUNC( _HMG_PRINTER_PREVIEW_DISABLEHSCROLLBAR )
{
   EnableScrollBar( ( HWND ) HB_PARNL( 1 ), SB_HORZ, ESB_DISABLE_BOTH );
}

HB_FUNC( _HMG_PRINTER_GETPRINTERWIDTH )
{
   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, HORZSIZE ) );
}

HB_FUNC( _HMG_PRINTER_GETPRINTERHEIGHT )
{
   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, VERTSIZE ) );
}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETX )
{
   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, PHYSICALOFFSETX ) );
}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSX )
{
   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, LOGPIXELSX ) );
}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREAPHYSICALOFFSETY )
{
   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, PHYSICALOFFSETY ) );
}

HB_FUNC( _HMG_PRINTER_GETPRINTABLEAREALOGPIXELSY )
{
   HDC hdc = ( HDC ) HB_PARNL( 1 );

   hb_retnl( GetDeviceCaps( hdc, LOGPIXELSY ) );
}

HB_FUNC( _HMG_PRINTER_C_IMAGE )
{
   // 1: hDC
   // 2: Image File
   // 3: Row
   // 4: Col
   // 5: Height
   // 6: Width
   // 7: Stretch
   // 8: Transparent

   HDC     hdcPrint  = ( HDC ) HB_PARNL( 1 );
   char *  FileName  = ( char * ) hb_parc( 2 );
   BOOL    bBmpImage = TRUE;
   HBITMAP hBitmap;
   HRGN    hRgn;
   HDC     memDC;
   INT     nWidth, nHeight;
   POINT   Point;
   BITMAP  Bmp;
   int     r   = hb_parni( 3 ); // Row
   int     c   = hb_parni( 4 ); // Col
   int     odr = hb_parni( 5 ); // Height
   int     odc = hb_parni( 6 ); // Width
   int     dr;
   int     dc;

   if( hdcPrint != NULL )
   {
      c  = ( c * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETX );
      r  = ( r * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 ) - GetDeviceCaps( hdcPrint, PHYSICALOFFSETY );
      dc = ( odc * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 );
      dr = ( odr * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 );

      hBitmap = ( HBITMAP ) LoadImage( GetModuleHandle( NULL ), FileName, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION );

      if( hBitmap == NULL )
         hBitmap = ( HBITMAP ) LoadImage( NULL, FileName, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE | LR_CREATEDIBSECTION );

      if( hBitmap == NULL )
      {
         bBmpImage = FALSE;
         hBitmap = HMG_LoadImage( FileName );
      }
      if( hBitmap == NULL )
         return;

      GetObject( hBitmap, sizeof( BITMAP ), &Bmp );
      nWidth  = Bmp.bmWidth;
      nHeight = Bmp.bmHeight;

      if( ! hb_parl( 7 ) ) // Scale
      {
         if( odr * nHeight / nWidth <= odr )
            dr = odc * GetDeviceCaps( hdcPrint, LOGPIXELSY ) / 1000 * nHeight / nWidth;
         else
            dc = odr * GetDeviceCaps( hdcPrint, LOGPIXELSX ) / 1000 * nWidth / nHeight;
      }

      GetViewportOrgEx( hdcPrint, &Point );

      hRgn = CreateRectRgn( c + Point.x,
                            r + Point.y,
                            c + dc + Point.x - 1,
                            r + dr + Point.y - 1 );

      SelectClipRgn( hdcPrint, hRgn );

      if( ! bBmpImage )
      {
         if( hb_parl( 7 ) )             // Stretch
            SetStretchBltMode( hdcPrint, COLORONCOLOR );
         else
         {
            GetBrushOrgEx( hdcPrint, &Point );
            SetStretchBltMode( hdcPrint, HALFTONE );
            SetBrushOrgEx( hdcPrint, Point.x, Point.y, NULL );
         }
      }

      memDC = CreateCompatibleDC( hdcPrint );
      SelectObject( memDC, hBitmap );

      if( hb_parl( 8 ) && ! bBmpImage ) // Transparent
         TransparentBlt( hdcPrint, c, r, dc, dr, memDC, 0, 0, nWidth, nHeight, GetPixel( memDC, 0, 0 ) );
      else
         StretchBlt( hdcPrint, c, r, dc, dr, memDC, 0, 0, nWidth, nHeight, SRCCOPY );

      SelectClipRgn( hdcPrint, NULL );

      DeleteObject( hBitmap );
      DeleteDC( memDC );
   }
}

//  GetJobInfo ( cPrinterName, nJobID ) --> { nJobID, cPrinterName, cMachineName, cUserName, cDocument, cDataType, cStatus, nStatus
//                                            nPriorityLevel, nPositionPrintQueue, nTotalPages, nPagesPrinted, cLocalDate, cLocalTime }
HB_FUNC( _HMG_PRINTGETJOBINFO )
{
   char *     cPrinterName = ( char * ) hb_parc( 1 );
   DWORD      nJobID       = ( DWORD ) hb_parni( 2 );
   HANDLE     hPrinter     = NULL;
   char       cDateTime[ 256 ];
   SYSTEMTIME LocalSystemTime;

   if( OpenPrinter( cPrinterName, &hPrinter, NULL ) )
   {
      DWORD        nBytesNeeded = 0;
      DWORD        nBytesUsed   = 0;
      JOB_INFO_1 * Job_Info_1;

      GetJob( hPrinter, nJobID, 1, NULL, 0, &nBytesNeeded );

      if( nBytesNeeded > 0 )
      {
         Job_Info_1 = ( JOB_INFO_1 * ) hb_xgrab( nBytesNeeded );
         ZeroMemory( Job_Info_1, nBytesNeeded );

         if( GetJob( hPrinter, nJobID, 1, ( LPBYTE ) Job_Info_1, nBytesNeeded, &nBytesUsed ) )
         {
            hb_reta( 14 );
            HB_STORNI( ( INT ) Job_Info_1->JobId, -1, 1 );
            HB_STORC(      Job_Info_1->pPrinterName, -1, 2 );
            HB_STORC(      Job_Info_1->pMachineName, -1, 3 );
            HB_STORC(      Job_Info_1->pUserName, -1, 4 );
            HB_STORC(      Job_Info_1->pDocument, -1, 5 );
            HB_STORC(      Job_Info_1->pDatatype, -1, 6 );
            HB_STORC(      Job_Info_1->pStatus, -1, 7 );
            HB_STORNI( ( INT ) Job_Info_1->Status, -1, 8 );
            HB_STORNI( ( INT ) Job_Info_1->Priority, -1, 9 );
            HB_STORNI( ( INT ) Job_Info_1->Position, -1, 10 );
            HB_STORNI( ( INT ) Job_Info_1->TotalPages, -1, 11 );
            HB_STORNI( ( INT ) Job_Info_1->PagesPrinted, -1, 12 );

            SystemTimeToTzSpecificLocalTime( NULL, &Job_Info_1->Submitted, &LocalSystemTime );

            wsprintf( cDateTime, "%02d/%02d/%02d", LocalSystemTime.wYear, LocalSystemTime.wMonth, LocalSystemTime.wDay );
            HB_STORC( cDateTime, -1, 13 );

            wsprintf( cDateTime, "%02d:%02d:%02d", LocalSystemTime.wHour, LocalSystemTime.wMinute, LocalSystemTime.wSecond );
            HB_STORC( cDateTime, -1, 14 );
         }
         else
            hb_reta( 0 );

         if( Job_Info_1 )
            hb_xfree( ( void * ) Job_Info_1 );
      }
      else
         hb_reta( 0 );

      ClosePrinter( hPrinter );
   }
   else
      hb_reta( 0 );
}

HB_FUNC( _HMG_PRINTERGETSTATUS )
{
   char * cPrinterName = ( char * ) hb_parc( 1 );
   HANDLE hPrinter     = NULL;
   DWORD  nBytesNeeded = 0;
   DWORD  nBytesUsed   = 0;
   PRINTER_INFO_6 * Printer_Info_6;

   if( OpenPrinter( cPrinterName, &hPrinter, NULL ) )
   {
      GetPrinter( hPrinter, 6, NULL, 0, &nBytesNeeded );
      if( nBytesNeeded > 0 )
      {
         Printer_Info_6 = ( PRINTER_INFO_6 * ) hb_xgrab( nBytesNeeded );
         ZeroMemory( Printer_Info_6, nBytesNeeded );

         if( GetPrinter( hPrinter, 6, ( LPBYTE ) Printer_Info_6, nBytesNeeded, &nBytesUsed ) )
            hb_retnl( Printer_Info_6->dwStatus );
         else
            hb_retnl( PRINTER_STATUS_NOT_AVAILABLE );

         if( Printer_Info_6 )
            hb_xfree( ( void * ) Printer_Info_6 );
      }
      else
         hb_retnl( PRINTER_STATUS_NOT_AVAILABLE );

      ClosePrinter( hPrinter );
   }
   else
      hb_retnl( PRINTER_STATUS_NOT_AVAILABLE );
}

HB_FUNC( GETTEXTALIGN )
{
   hb_retni( GetTextAlign( ( HDC ) HB_PARNL( 1 ) ) );
}

HB_FUNC( SETTEXTALIGN )
{
   hb_retni( SetTextAlign( ( HDC ) HB_PARNL( 1 ), ( UINT ) hb_parni( 2 ) ) );
}

static HBITMAP loademffile( char * filename, int width, int height, HWND handle, int scalestrech, int whitebackground );

HB_FUNC( INITEMFFILE )
{
   HWND hWnd;
   HWND hWndParent = ( HWND ) HB_PARNL( 1 );
   int  Style      = WS_CHILD | SS_BITMAP;

   if( ! hb_parl( 5 ) )
      Style |= WS_VISIBLE;

   if( hb_parl( 6 ) )
      Style |= SS_NOTIFY;

   hWnd = CreateWindowEx( 0, WC_STATIC, NULL, Style, hb_parni( 3 ), hb_parni( 4 ), 0, 0, hWndParent, ( HMENU ) HB_PARNL( 2 ), GetModuleHandle( NULL ), NULL );

   HB_RETNL( ( LONG_PTR ) hWnd );
}

HB_FUNC( C_SETEMFFILE )
{
   HBITMAP hBitmap;

   if( hb_parclen( 2 ) == 0 )
      HB_RETNL( ( LONG_PTR ) NULL );

   hBitmap = loademffile( ( char * ) hb_parc( 2 ), hb_parni( 3 ), hb_parni( 4 ), ( HWND ) HB_PARNL( 1 ), hb_parni( 5 ), hb_parni( 6 ) );

   if( hBitmap != NULL )
      SendMessage( ( HWND ) HB_PARNL( 1 ), ( UINT ) STM_SETIMAGE, ( WPARAM ) IMAGE_BITMAP, ( LPARAM ) hBitmap );

   HB_RETNL( ( LONG_PTR ) hBitmap );
}

static BOOL read_image( char * filename, DWORD * nFileSize, HGLOBAL * hMem )
{
   HANDLE hFile;
   LPVOID lpDest;
   DWORD  dwFileSize;
   DWORD  dwBytesRead = 0;
   BOOL   bRead;

   // open the file
   hFile = CreateFile( filename, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
   if( hFile == INVALID_HANDLE_VALUE )
      return FALSE;
   // we will read the whole file in global memory, find the size first
   dwFileSize = GetFileSize( hFile, NULL );
   // allocate memory to read the whole file
   if( dwFileSize == INVALID_FILE_SIZE || ( *hMem = GlobalAlloc( GHND, dwFileSize ) ) == NULL )
   {
      CloseHandle( hFile );
      return FALSE;
   }
   *nFileSize = dwFileSize;
   // lock memory for image
   lpDest = GlobalLock( *hMem );
   if( lpDest == NULL )
   {
      GlobalFree( *hMem );
      CloseHandle( hFile );
      return FALSE;
   }
   // read file and store in global memory
   bRead = ReadFile( hFile, lpDest, dwFileSize, &dwBytesRead, NULL );

   GlobalUnlock( *hMem );
   CloseHandle( hFile );

   if( ! bRead )
   {
      GlobalFree( *hMem );
      return FALSE;
   }
   return TRUE;
}

static void calc_rect( HWND handle, int width, int height, int scalestrech, LONG lWidth, LONG lHeight, RECT * rect, RECT * rect2 )
{
   if( width == 0 && height == 0 )
      GetClientRect( handle, rect );
   else
      SetRect( rect, 0, 0, width, height );

   SetRect( rect2, 0, 0, rect->right, rect->bottom );

   if( scalestrech == 0 )
   {
      if( ( int ) lWidth * rect->bottom / lHeight <= rect->right )
         rect->right = ( int ) lWidth * rect->bottom / lHeight;
      else
         rect->bottom = ( int ) lHeight * rect->right / lWidth;
   }

   rect->left = ( int ) ( width - rect->right ) / 2;
   rect->top  = ( int ) ( height - rect->bottom ) / 2;
}

static HBITMAP loademffile( char * filename, int width, int height, HWND handle, int scalestrech, int whitebackground )
{
   IStream *  iStream;
   IPicture * iPicture = NULL;
   HGLOBAL    hMem     = ( HGLOBAL ) NULL;
   HRESULT    hr;
   DWORD      nFileSize = 0;
   RECT       rect, rect2;
   HBITMAP    bitmap;
   LONG       lWidth, lHeight;
   HDC        imgDC = GetDC( handle );
   HDC        tmpDC;

   if( read_image( filename, &nFileSize, &hMem ) == FALSE )
   {
      ReleaseDC( handle, imgDC );
      return NULL;
   }
   // don't delete memory on object's release
   hr = CreateStreamOnHGlobal( hMem, FALSE, &iStream );
   if( hr != S_OK || iStream == NULL )
   {
      GlobalFree( hMem );
      ReleaseDC( handle, imgDC );
      return NULL;
   }
   // Load from stream
#if defined( __cplusplus )
   hr = OleLoadPicture( iStream, nFileSize, ( nFileSize == 0 ), IID_IPicture, ( LPVOID * ) &iPicture );
#else
   hr = OleLoadPicture( iStream, nFileSize, ( nFileSize == 0 ), &IID_IPicture, ( LPVOID * ) &iPicture );
   iStream->lpVtbl->Release( iStream );
#endif
   if( hr != S_OK || iPicture == NULL )
   {
      GlobalFree( hMem );
      ReleaseDC( handle, imgDC );
      return NULL;
   }

   iPicture->lpVtbl->get_Width( iPicture, &lWidth );
   iPicture->lpVtbl->get_Height( iPicture, &lHeight );

   calc_rect( handle, width, height, scalestrech, lWidth, lHeight, &rect, &rect2 );

   tmpDC  = CreateCompatibleDC( imgDC );
   bitmap = CreateCompatibleBitmap( imgDC, width, height );
   SelectObject( tmpDC, bitmap );

   if( whitebackground == 1 )
      FillRect( tmpDC, &rect2, ( HBRUSH ) GetStockObject( WHITE_BRUSH ) );
   else
      FillRect( tmpDC, &rect2, ( HBRUSH ) GetSysColorBrush( COLOR_BTNFACE ) );

   // Render to device context
   iPicture->lpVtbl->Render( iPicture, tmpDC, rect.left, rect.top, rect.right, rect.bottom, 0, lHeight, lWidth, -lHeight, NULL );
   iPicture->lpVtbl->Release( iPicture );
   GlobalFree( hMem );

   DeleteDC( tmpDC );
   ReleaseDC( handle, imgDC );

   return bitmap;
}

HB_FUNC( ISWIN8ORLATER )
{
   OSVERSIONINFO osvi;

   osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
   GetVersionEx( ( OSVERSIONINFO * ) &osvi );

   hb_retl( osvi.dwMajorVersion >= 6 && osvi.dwMinorVersion > 1 );
}

#pragma ENDDUMP
