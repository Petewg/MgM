/*

 HMG IDE Demo
 (c) 2010 Roberto Lopez <mail.box.hmg@gmail.com>

 Adapted for Minigui Extended Edition by Grigory Filatov <gfilatov@inbox.ru>

*/

#include "minigui.ch"

Memvar nTitleBarHeight
Memvar nBorderWidth

Memvar nCurrentRow
Memvar nCurrentCol
Memvar cCurrentControl

Memvar nButtonCounter
Memvar nCheckBoxCounter
Memvar nListBoxCounter
Memvar nComboBoxCounter
Memvar nCheckButtonCounter
Memvar nGridCounter
Memvar nSliderCounter
Memvar nSpinnerCounter
Memvar nImageCounter
Memvar nTreeCounter
Memvar nDatePickerCounter
Memvar nTextBoxCounter
Memvar nEditBoxCounter
Memvar nlabelCounter
Memvar nTimerCounter
Memvar nRadioGroupCounter
Memvar nFrameCounter
Memvar nTabCounter
Memvar nAnimateBoxCounter
Memvar nHyperlinkCounter
Memvar nMonthCalendarCounter
Memvar nProgressBarCounter
Memvar nIpAddressCounter
Memvar nBrowseCounter
Memvar lDragEnabled
Memvar lResizeEnabled

Memvar aMsgs

Static cWindowType
Static cWindowVisible

/*----------------------------------------------------------------------*/
FUNCTION Main
/*----------------------------------------------------------------------*/
   Local nDeltaHeight := int ( ( GetDesktopHeight() - 600 ) / 2 )
   Local cControl

   Public nTitleBarHeight := GetTitleHeight()
   Public nBorderWidth := GetBorderWidth()

   Public nCurrentRow := 0
   Public nCurrentCol := 0
   Public cCurrentControl := ''

   Public nButtonCounter := 0
   Public nCheckBoxCounter := 0
   Public nListBoxCounter := 0
   Public nComboBoxCounter := 0
   Public nCheckButtonCounter := 0
   Public nGridCounter := 0
   Public nSliderCounter := 0
   Public nSpinnerCounter := 0
   Public nImageCounter := 0
   Public nTreeCounter := 0
   Public nDatePickerCounter := 0
   Public nTextBoxCounter := 0
   Public nEditBoxCounter := 0
   Public nlabelCounter := 0
   Public nTimerCounter := 0
   Public nRadioGroupCounter := 0
   Public nFrameCounter := 0
   Public nTabCounter := 0
   Public nAnimateBoxCounter := 0
   Public nHyperlinkCounter := 0
   Public nMonthCalendarCounter := 0
   Public nProgressBarCounter := 0
   Public nIpAddressCounter := 0
   Public nBrowseCounter := 0
   Public lDragEnabled := .f.
   Public lResizeEnabled := .f.

   SET EPOCH TO 1990
   SET DATE FORMAT "yyyy.mm.dd"

   SET PROGRAMMATICCHANGE OFF
   SET INTERACTIVECLOSE QUERY MAIN

   Use Demo Shared

   LoadMessages()

   DEFINE WINDOW Main ;
	ROW		0 ;
	COL		0 ;
	WIDTH		GetDesktopWidth() ;
	HEIGHT		147 ;
	TITLE		'HMG IDE Demo - FREEWARE - Version: ' + DtoC( Date() ) ;
	WINDOWTYPE	MAIN ;
	ON INIT		NewForm()

		DEFINE STATUSBAR Font "Arial" SIZE 8
			STATUSITEM "" 
		END STATUSBAR

		DEFINE MAIN MENU
			POPUP aMsgs [ 045 ]
				ITEM aMsgs [ 001 ] IMAGE 'bmp\new1.bmp'		ACTION NIL
				ITEM aMsgs [ 002 ] IMAGE 'bmp\open1.bmp'	ACTION NIL
				ITEM aMsgs [ 003 ] IMAGE 'bmp\close1.bmp'	ACTION NIL
				SEPARATOR
				ITEM aMsgs [ 006 ] IMAGE 'bmp\exit.bmp'		ACTION Main.Release
			END POPUP
			POPUP aMsgs [ 046 ]
				ITEM aMsgs [ 007 ] IMAGE 'bmp\delete.bmp'	ACTION NIL
				SEPARATOR
				ITEM aMsgs [ 008 ] ACTION NIL
				SEPARATOR
				ITEM aMsgs [ 009 ] ACTION NIL CHECKED
				SEPARATOR
				POPUP aMsgs [ 010 ]
					ITEM aMsgs [ 011 ] ACTION NIL
					ITEM aMsgs [ 012 ] ACTION NIL
					ITEM aMsgs [ 013 ] ACTION NIL
					ITEM aMsgs [ 014 ] ACTION NIL
					ITEM aMsgs [ 015 ] ACTION NIL
					ITEM aMsgs [ 016 ] ACTION NIL
				END POPUP
			END POPUP
			POPUP aMsgs [ 017 ]
				ITEM aMsgs [ 018 ] IMAGE 'bmp\view.bmp'	ACTION Nil
			END POPUP
			POPUP aMsgs [ 019 ]
				ITEM aMsgs [ 021 ] IMAGE 'bmp\run1.bmp' ACTION NIL
				ITEM aMsgs [ 022 ] ACTION NIL
				ITEM aMsgs [ 023 ] ACTION NIL
				SEPARATOR
				ITEM aMsgs [ 026 ] IMAGE 'bmp\newmodule1.bmp' ACTION NIL
				ITEM aMsgs [ 024 ] IMAGE 'bmp\newform1.bmp' ACTION NewForm()
				ITEM aMsgs [ 028 ] ACTION NIL
				ITEM aMsgs [ 280 ] ACTION NIL
				ITEM aMsgs [ 096 ] ACTION NIL
				SEPARATOR
				ITEM aMsgs [ 027 ] ACTION NIL
				ITEM aMsgs [ 030 ] ACTION NIL
				ITEM aMsgs [ 031 ] ACTION NIL
				ITEM aMsgs [ 029 ] ACTION NIL 
				SEPARATOR
				ITEM aMsgs [ 004 ] IMAGE 'bmp\save.bmp'	ACTION NIL
				ITEM aMsgs [ 005 ] ACTION NIL
				SEPARATOR
				ITEM aMsgs [ 032 ] ACTION NIL
			END POPUP
			POPUP aMsgs [ 033 ] 
				POPUP aMsgs [ 034 ]
					ITEM aMsgs [ 035 ] ACTION NIL
					ITEM aMsgs [ 036 ] ACTION NIL
					ITEM aMsgs [ 037 ] ACTION NIL
					ITEM aMsgs [ 038 ] ACTION NIL
					ITEM aMsgs [ 039 ] ACTION NIL
					ITEM aMsgs [ 040 ] ACTION NIL
					ITEM aMsgs [ 041 ] ACTION NIL
				END POPUP
				SEPARATOR
				ITEM aMsgs [ 042 ] IMAGE 'bmp\preferences.bmp' ACTION NIL
			END POPUP
			POPUP aMsgs [ 043 ]
				ITEM aMsgs [ 020 ] ACTION  NIL
				ITEM aMsgs [ 044 ] IMAGE 'bmp\help.bmp' ;
					ACTION MsgInfo( 'HMG IDE Demo (c) Roberto Lopez <mail.box.hmg@gmail.com> - FREEWARE' + CRLF + ;
					'http://sites.google.com/site/hmgweb' )
			END POPUP
		END MENU

		/* Commands */

		@ 002 , 005 BUTTON NewProject ;
			PICTURE 'bmp\new.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 049 ] 

		@ 002,35 BUTTON Open ;
			PICTURE 'bmp\open.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 050 ] ;

		@ 002,65 BUTTON Close ;
			PICTURE 'bmp\close.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 051 ] ;

		@ 032,5 BUTTON NewForm ;
			PICTURE 'bmp\newform.bmp' ;
			ACTION  NewForm() ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 052 ]

		@ 032,35 BUTTON NewModule ;
			PICTURE 'bmp\newmodule.bmp' ;
			ACTION  NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 026 ] 

		@ 032,65 BUTTON NewReport ;
			PICTURE 'bmp\report.bmp' ;
			ACTION  NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 028 ] 

		@ 002,105 BUTTON Run ;
			PICTURE 'bmp\run.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 054 ] ; 


		@ 002,175 CHECKBUTTON Control_00 ;
			PICTURE 'bmp\select.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 055 ] ; 
			ON CHANGE ( DisableControlButtonBar( .T. ) , cCurrentControl := '' , SetEditWindowCursor( 0 ) )

		Main.Control_00.Value := .T.

		/* Controls */

		@ 002,205 CHECKBUTTON Control_01 ;
			PICTURE 'bmp\checkbox.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'CheckBox' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'CHECKBOX' , DisableControlButtonBar() , Main.Control_01.value := .T. )

		@ 002,235 CHECKBUTTON Control_02 ;
			PICTURE 'bmp\listbox.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'ListBox' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'LISTBOX' , DisableControlButtonBar() , Main.Control_02.value := .T. )
	
		@ 002,265 CHECKBUTTON Control_03 ;
			PICTURE 'bmp\combobox.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'ComboBox' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'COMBOBOX' , DisableControlButtonBar() , Main.Control_03.value := .T. )

		@ 002,295 CHECKBUTTON Control_04 ;
			PICTURE 'bmp\checkbutton.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'CheckButton' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'CHECKBUTTON' , DisableControlButtonBar() , Main.Control_04.value := .T. )

		@ 002,325 CHECKBUTTON Control_05 ;
			PICTURE 'bmp\grid.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Grid' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'GRID' , DisableControlButtonBar() , Main.Control_05.value := .T. )

		@ 002,355 CHECKBUTTON Control_06 ;
			PICTURE 'bmp\slider.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Slider' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'SLIDER' , DisableControlButtonBar() , Main.Control_06.value := .T. )

		@ 002,385 CHECKBUTTON Control_07 ;
			PICTURE 'bmp\spinner.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Spinner' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'SPINNER' , DisableControlButtonBar() , Main.Control_07.value := .T. )

		@ 002,415 CHECKBUTTON Control_08 ;
			PICTURE 'bmp\image.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Image' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'IMAGE' , DisableControlButtonBar() , Main.Control_08.value := .T. )

		@ 002,445 CHECKBUTTON Control_09 ;
			PICTURE 'bmp\tree.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Tree' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'TREE'  , DisableControlButtonBar() , Main.Control_09.value := .T. )

		@ 002,475 CHECKBUTTON Control_10 ;
			PICTURE 'bmp\datepicker.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'DatePicker' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'DATEPICKER'  , DisableControlButtonBar() , Main.Control_10.value := .T. )

		@ 002,505 CHECKBUTTON Control_11 ;
			PICTURE 'bmp\textbox.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'TextBox' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'TEXTBOX'  , DisableControlButtonBar() , Main.Control_11.value := .T. )

		@ 002,535 CHECKBUTTON Control_12 ;
			PICTURE 'bmp\editbox.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'EditBox' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'EDITBOX'  , DisableControlButtonBar() , Main.Control_12.value := .T. )

		@ 032,235 CHECKBUTTON Control_13 ;
			PICTURE 'bmp\radiogroup.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'RadioGroup' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'RADIOGROUP'  , DisableControlButtonBar() , Main.Control_13.value := .T. )

		@ 032,265 CHECKBUTTON Control_14 ;
			PICTURE 'bmp\frame.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Frame' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'FRAME' , DisableControlButtonBar() , Main.Control_14.value := .T. )

		@ 032,295 CHECKBUTTON Control_15 ;
			PICTURE 'bmp\tab.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Tab' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'TAB'  , DisableControlButtonBar() , Main.Control_15.value := .T. )

		@ 032,325 CHECKBUTTON Control_16 ;
			PICTURE 'bmp\animatebox.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'AnimateBox' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'ANIMATEBOX'  , DisableControlButtonBar() , Main.Control_16.value := .T. )

		@ 032,355 CHECKBUTTON Control_17 ;
			PICTURE 'bmp\hyperlink.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Hyperlink' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'HYPERLINK'  , DisableControlButtonBar() , Main.Control_17.value := .T. )

		@ 032,385 CHECKBUTTON Control_18 ;
			PICTURE 'bmp\monthcalendar.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'MonthCalendar' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'MONTHCALENDAR'  , DisableControlButtonBar() , Main.Control_18.value := .T. )

		@ 032,415 CHECKBUTTON Control_19 ;
			PICTURE 'bmp\button.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Button' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'BUTTON' , DisableControlButtonBar() , Main.Control_19.value := .T. )

		@ 032,445 CHECKBUTTON Control_20 ;
			PICTURE 'bmp\progressbar.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'ProgressBar' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'PROGRESSBAR'  , DisableControlButtonBar() , Main.Control_20.value := .T. )

		@ 032,475 CHECKBUTTON Control_21 ;
			PICTURE 'bmp\label.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Label' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'LABEL' , DisableControlButtonBar() , Main.Control_21.value := .T. )

		@ 032,505 CHECKBUTTON Control_22 ;
			PICTURE 'bmp\ipaddress.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'IP Address' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'IPADDRESS'  , DisableControlButtonBar() , Main.Control_22.value := .T. )

		@ 032,205 CHECKBUTTON Control_23 ;
			PICTURE 'bmp\timer.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Timer' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'TIMER'  , DisableControlButtonBar() , Main.Control_23.value := .T. )

		@ 032,535 CHECKBUTTON Control_24 ;
			PICTURE 'bmp\browse.bmp' ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP 'Browse' ;
			ON CHANGE ( SetEditWindowCursor( 2 ) , cCurrentControl := 'BROWSE'  , DisableControlButtonBar() , Main.Control_24.value := .T. )

		@ 002,575 BUTTON Control_25 ;
			PICTURE 'bmp\menu.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 058 ]

		@ 002,605 BUTTON Control_26 ;
			PICTURE 'bmp\contextmenu.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 059 ]

		@ 002,635 BUTTON Control_27 ;
			PICTURE 'bmp\statusbar.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 060 ]

		@ 002,665 BUTTON Control_28 ;
			PICTURE 'bmp\toolbar.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 061 ]

		@ 002,695 BUTTON Control_29 ;
			PICTURE 'bmp\notifymenu.bmp' ;
			ACTION NIL	 ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 062 ]

		@ 002,725 BUTTON Control_30 ;
			PICTURE 'bmp\dropdownmenu.bmp' ;
			ACTION NIL	 ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 063 ]

		@ 002,755 BUTTON Control_31 ;
			PICTURE 'bmp\splitbox.bmp' ;
			ACTION NIL ;
			WIDTH 29 HEIGHT 29 ;
			TOOLTIP aMsgs [ 064 ]

		/* User Components */

		DEFINE FRAME FRAME_1
			ROW	35
			COL	575
			WIDTH	210
			HEIGHT	30
		END FRAME

		DEFINE LABEL label_User 
			ROW	42
			COL	580
			WIDTH	120
			VALUE	'User Components:'
		END LABEL

		DEFINE COMBOBOX Combo_User 
			ROW	39
			COL	690
			WIDTH	90
		END COMBOBOX

	END WINDOW

	Main.Combo_User.Enabled := .F.

	DEFINE WINDOW Project ;
		ROW	148 ;
		COL	0 ;
		WIDTH	300 ;
		HEIGHT 190 + nDeltaHeight ;
		TITLE	aMsgs [ 065 ] ;
		WINDOWTYPE CHILD ;
		NOSYSMENU ;
		ON INTERACTIVECLOSE .F.

		DEFINE TAB Tab_1 AT 3,3 WIDTH 280 HEIGHT 143 + nDeltaHeight MULTILINE

			PAGE aMsgs [ 066 ]

				DEFINE LISTBOX List_1
					ROW 45
					COL 5
					WIDTH 270
					HEIGHT 90 + nDeltaHeight
					ONDBLCLICK nil
					TOOLTIP aMsgs [ 070 ]
				END LISTBOX

			END PAGE

			PAGE aMsgs [ 067 ]

				DEFINE LISTBOX List_2
					ROW 45
					COL 5
					WIDTH 270
					HEIGHT 90 + nDeltaHeight
					ONDBLCLICK nil
					TOOLTIP aMsgs [ 070 ]
				END LISTBOX

			END PAGE

			PAGE aMsgs [ 068 ]

				DEFINE EDITBOX Edit_1
					ROW		45
					COL		5
					WIDTH		270
					HEIGHT		90 + nDeltaHeight
					TOOLTIP aMsgs [ 072 ]
				END EDITBOX

			END PAGE

			PAGE aMsgs [ 069 ]

				DEFINE LISTBOX List_3
					ROW 45
					COL 5
					WIDTH 270
					HEIGHT 90 + nDeltaHeight
					ONDBLCLICK nil
					TOOLTIP aMsgs [ 070 ]
				END LISTBOX

			END PAGE

			PAGE aMsgs [ 270 ]

				DEFINE GRID config
					ROW		45
					COL		5
					WIDTH		270
					HEIGHT		90 + nDeltaHeight
					ITEMS		{ {'',''} }
					HEADERS		{'Setting','Value'}
					WIDTHS		{ 100,130 }
					SHOWHEADERS	.F.
					ONDBLCLICK	NIL
					TOOLTIP		aMsgs [ 070 ]
				END GRID

			END PAGE

			PAGE aMsgs [ 279 ]

				DEFINE LISTBOX List_4
					ROW 45
					COL 5
					WIDTH 270
					HEIGHT 90 + nDeltaHeight
					ONDBLCLICK NIL
					TOOLTIP aMsgs [ 070 ]
				END LISTBOX

			END PAGE

			PAGE aMsgs [ 095 ]

				DEFINE LISTBOX tables
					ROW 45
					COL 5
					WIDTH 270
					HEIGHT 90 + nDeltaHeight
					ONDBLCLICK NIL
					TOOLTIP aMsgs [ 070 ]
				END LISTBOX

			END PAGE

		END TAB

	END WINDOW

	DEFINE WINDOW Inspector ;
		ROW 338 + nDeltaHeight ;
		COL 0 ;
		WIDTH 300 ;
		HEIGHT 190 + nDeltaHeight ;
		TITLE aMsgs [ 074 ] ;
		WINDOWTYPE CHILD ;
		NOSYSMENU ;
		ON INTERACTIVECLOSE .F.

		DEFINE COMBOBOX ObjectList
			ROW	3
			COL	3
			WIDTH	278
			ITEMS	{'Form'}
			VALUE	1
			ONCHANGE iif( Inspector.ObjectList.value > 1,;
				( cControl := Inspector.ObjectList.Item( Inspector.ObjectList.value ), ;
				DrawFocusRect( cControl ), ;
				UpdateProperties( cControl, GetControlType( cControl, 'oEdit' ) ) ), ;
				( EraseWindow( 'oEdit' ), UpdateFormProperties() ) )
		END COMBOBOX

		DEFINE TAB Tab_1 AT 36,3 WIDTH 280 HEIGHT 109 + nDeltaHeight

			PAGE aMsgs [ 075 ]

				DEFINE GRID Properties
					ROW 25
					COL 5
					WIDTH 270
					HEIGHT 78 + nDeltaHeight
					HEADERS { aMsgs [ 077 ] , aMsgs [ 078 ] }
					WIDTHS {115,115}
					ITEMS NIL
					ONDBLCLICK ChangeControlProperties( Inspector.ObjectList.Item( Inspector.ObjectList.value ) )
					TOOLTIP aMsgs [ 079 ]
				END GRID

			END PAGE

			PAGE aMsgs [ 076 ]

				DEFINE GRID Events
					ROW 25
					COL 5
					WIDTH 270
					HEIGHT 78 + nDeltaHeight  
					HEADERS { aMsgs [ 080 ] , aMsgs [ 081 ] , '' , '' , '' }
					WIDTHS {85,85,20,20,20}
					ITEMS NIL
					ONDBLCLICK ChangeControlEvent( This.CellColIndex )
					TOOLTIP aMsgs [ 082 ]
				END GRID

			END PAGE

		END TAB

	END WINDOW

	Activate Window Project , Inspector , Main

RETURN NIL

/*----------------------------------------------------------------------*/
PROCEDURE LoadMessages
/*----------------------------------------------------------------------*/
   Local nLines , cLin , nNum , cText , cMsgs , i

   Public aMsgs[500]

	afill(aMsgs, '')

	cText := MemoRead ('language.ini')

	cMsgs := MemoRead ('lng\' + cText )

	nLines := mlcount ( cMsgs , 254 )

	FOR i := 1 TO nLines
		cLin := alltrim( memoline ( cMsgs , 254 , i ) )
		nNum := val ( left ( cLin , 3 ) )
		IF nNum > 0
			aMsgs [ nNum ] := alltrim ( substr ( cLin , 5 , 254 ) )
		ENDIF
	NEXT i

RETURN

/*----------------------------------------------------------------------*/
PROCEDURE NewForm()
/*----------------------------------------------------------------------*/

   IF ! IsWindowDefined( oEdit )

	SET DATE FORMAT "dd/mm/yy"

	DEFINE WINDOW oEdit ;
		ROW 10 ;
		COL 10 ;
		WIDTH	640 ;
		HEIGHT	480 ;
		TITLE	' ' ;
		WINDOWTYPE CHILD ;
		ON INIT ( cWindowType := 'MAIN', ;
			cWindowVisible := iif(IsWindowVisible( GetFormHandle('oEdit') ),'.T.','.F.' ), ;
			iif(Inspector.ObjectList.ItemCount == 0, ;
			( Inspector.ObjectList.AddItem('Form'), Inspector.ObjectList.Value := 1 ), ), ;
			UpdateFormProperties() ) ;
		ON RELEASE ( Inspector.ObjectList.DeleteAllItems(), ;
			Inspector.Properties.DeleteAllItems(), ;
			Inspector.Events.DeleteAllItems() ) ;
		ON MOUSECLICK iif(Empty(cCurrentControl), ;
			( Inspector.ObjectList.value := 1, EraseWindow( 'oEdit' ), ;
			UpdateFormProperties() ), EditClickProcess() ) ;
		ON MOUSEMOVE DrawSnapGrid() ;
		ON SIZE ( UpdateFormProperties(), DrawSnapGrid() ) ;
		ON MAXIMIZE ( UpdateFormProperties(), DrawSnapGrid() ) ;
		ON GOTFOCUS DrawSnapGrid() ;
		ON MOVE ( UpdateFormProperties(), DrawSnapGrid() )

	END WINDOW

	ON KEY DELETE OF oEdit ACTION DeleteControl()

	oEdit.Center()
	oEdit.Activate()

   ELSE

	oEdit.Setfocus()

   ENDIF

RETURN

/*----------------------------------------------------------------------*/	
PROCEDURE DeleteControl()
/*----------------------------------------------------------------------*/
Local cControl
Local i := Inspector.ObjectList.Value

	IF Empty( i )
		RETURN
	ENDIF

	cControl := Inspector.ObjectList.Item(i)

	IF cControl == 'Form'
		RETURN
	ENDIF

	IF MsgYesNo( "Are you sure ?", "Delete Control" )

		oEdit.&(cControl).Release

		Inspector.ObjectList.DeleteItem(i)
		Inspector.ObjectList.Value := i - 1

		cControl := Inspector.ObjectList.Item( Inspector.ObjectList.value )
		IF cControl == 'Form'
			UpdateFormProperties()
		ELSE
			UpdateProperties( cControl, GetControlType( cControl, 'oEdit' ) )
		ENDIF

		ERASE WINDOW oEdit
	ENDIF

RETURN

/*----------------------------------------------------------------------*/	
PROCEDURE AddControl( cType )
/*----------------------------------------------------------------------*/
   LOCAL cVar, oControl 
   LOCAL bOnClickAction := {|| cVar := This.Name, DrawFocusRect( cVar ), ;
			Aeval( Array(Inspector.ObjectList.ItemCount), ;
			{|x,i| iif(Inspector.ObjectList.Item(i) == cVar, Inspector.ObjectList.Value := i, )} ), ;
			UpdateProperties( cVar, GetControlType( cVar, 'oEdit' ) ) }

	IF Empty( cCurrentControl )
		RETURN
	ENDIF

        cType := cCurrentControl 

	IF cType == 'BUTTON'

		nButtonCounter++
		cVar := 'Button_' + alltrim(str(nButtonCounter))

		DEFINE BUTTON &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Caption		cVar
			OnClick		NIL
		END BUTTON

	ELSEIF cType == 'CHECKBOX'

		nCheckBoxCounter++
		cVar := 'CheckBox_' + alltrim(str(nCheckBoxCounter))
		
		DEFINE CHECKBOX &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Caption		cVar
			OnClick		NIL
		END CHECKBOX

	ELSEIF cType == 'LISTBOX'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the borders only' )

		nListBoxCounter++
		cVar := 'ListBox_' + alltrim(str(nListBoxCounter))
		
		DEFINE LISTBOX &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		100
			Height		100
			Items		{cVar}
		END LISTBOX
		
	ELSEIF cType == 'COMBOBOX'

		nComboBoxCounter++
		cVar := 'ComboBox_' + alltrim(str(nComboBoxCounter))
		
		DEFINE COMBOBOX &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		100
			Height		100
			Items		{cVar}
                        Value		1
		END COMBOBOX

	ELSEIF cType == 'CHECKBUTTON'

		nCheckButtonCounter++
		cVar := 'CheckButton_' + alltrim(str(nCheckButtonCounter))

		DEFINE CHECKBUTTON &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Caption		cVar
			Value		.F.
		END CHECKBUTTON

	ELSEIF cType == 'GRID'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the borders only' )

		nGridCounter++
		cVar := 'Grid_' + alltrim(str(nGridCounter))
		
		DEFINE GRID &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Headers		{ '', '' }
			Widths		{ 100, 100 }
		END GRID

	ELSEIF cType == 'SLIDER'

		nSliderCounter++
		cVar := 'Slider_' + alltrim(str(nSliderCounter))

		DEFINE SLIDER &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Rangemin	1
			Rangemax	10
			Value		5
                        Vertical	.F.
			Tooltip		""
			TickMarks	.T.
		END SLIDER

		oEdit.&(cVar).OnChange := bOnClickAction

	ELSEIF cType == 'SPINNER'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the arrows only' )

		nSpinnerCounter++
		cVar := 'Spinner_' + alltrim(str(nSpinnerCounter))
		
		DEFINE SPINNER &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Rangemin	1
			Rangemax	10
			Value		5
		END SPINNER

	ELSEIF cType == 'IMAGE'

		nImageCounter++
		cVar := 'Image_' + alltrim(str(nImageCounter))

		DEFINE BUTTON &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		30
			Height		30
			Picture		'bmp\image.bmp'
		END BUTTON

	ELSEIF cType == 'TREE'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the borders only' )

		nTreeCounter++
		cVar := 'Tree_' + alltrim(str(nTreeCounter))
		
		DEFINE TREE &cVar PARENT oEdit ;
			AT nCurrentRow,nCurrentCol ;
			WIDTH 120 HEIGHT 120

			DEFINE NODE cVar
			END NODE

		END TREE

	ELSEIF cType == 'DATEPICKER'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the arrows only' )

		nDatePickerCounter++
		cVar := 'DatePicker_' + alltrim(str(nDatePickerCounter))

		DEFINE DATEPICKER &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Value		date()
		END DATEPICKER

	ELSEIF cType == 'TEXTBOX'

		nTextBoxCounter++
		cVar := 'TextBox_' + alltrim(str(nTextBoxCounter))
		
		DEFINE TEXTBOX &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Value		cVar
		END TEXTBOX

	ELSEIF cType == 'EDITBOX'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the borders only' )

		nEditBoxCounter++
		cVar := 'EditBox_' + alltrim(str(nEditBoxCounter))

		DEFINE EDITBOX &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		120
			Height		120
			Value		cVar
		END EDITBOX
		
	ELSEIF cType == 'LABEL'

		nLabelCounter++
		cVar := 'Label_' + alltrim(str(nLabelCounter))

		DEFINE LABEL &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Value		cVar
		END LABEL

	ELSEIF cType == 'TIMER'

		nTimerCounter++
		cVar := 'Timer_' + alltrim(str(nTimerCounter))

		DEFINE BUTTON &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		30
			Height		30
			Picture		'bmp\timer.bmp'
		END BUTTON

	ELSEIF cType == 'RADIOGROUP'

		nRadioGroupCounter++
		cVar := 'RadioGroup_' + alltrim(str(nRadioGroupCounter))

		DEFINE RADIOGROUP &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		100
			Height		150
			Options		{"New 1","New 2","New 3"} 
	    		Value		1
			Caption		cVar
		END RADIOGROUP

		oEdit.&(cVar).OnChange := bOnClickAction

	ELSEIF cType == 'FRAME'

		nFrameCounter++
		cVar := 'Frame_' + alltrim(str(nFrameCounter))

		DEFINE FRAME &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		200
			Height		200
			Caption		cVar
		END FRAME

	ELSEIF cType == 'TAB'

		nTabCounter++
		cVar := 'Tab_' + alltrim(str(nTabCounter))

		DEFINE TAB &cVar PARENT oEdit ;
			AT nCurrentRow,nCurrentCol ;
			WIDTH 200 HEIGHT 200

			DEFINE TAB PAGE 'One'
			END PAGE

			DEFINE TAB PAGE 'Two'
			END PAGE

		END TAB

		oEdit.&(cVar).OnChange := bOnClickAction

	ELSEIF cType == 'ANIMATEBOX'

		nAnimateBoxCounter++
		cVar := 'AnimateBox_' + alltrim(str(nAnimateBoxCounter))

		DEFINE BUTTON &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		30
			Height		30
			Picture		'bmp\animatebox.bmp'
		END BUTTON

	ELSEIF cType == 'HYPERLINK'

		nHyperlinkCounter++
		cVar := 'Hyperlink_' + alltrim(str(nHyperlinkCounter))

		DEFINE HYPERLINK &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Value		cVar
			Address		'http://hmgextended.com'
		END HYPERLINK

	ELSEIF cType == 'MONTHCALENDAR'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the title bar only' )

		nMonthCalendarCounter++
		cVar := 'MonthCalendar_' + alltrim(str(nMonthCalendarCounter))

		DEFINE MONTHCALENDAR &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		227
			Height		162
			Value		CTOD("  /  /  ")
		END MONTHCALENDAR

	ELSEIF cType == 'PROGRESSBAR'

		nProgressBarCounter++
		cVar := 'ProgressBar_' + alltrim(str(nProgressBarCounter))

		DEFINE PROGRESSBAR &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		200
			Rangemin	1
			Rangemax	100
			Value		50
			Tooltip		cVar
		END PROGRESSBAR

	ELSEIF cType == 'IPADDRESS'

		nIpAddressCounter++
		cVar := 'IpAddress_' + alltrim(str(nIpAddressCounter))

                DEFINE IPADDRESS &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		210
			Value		{255,112,215,32}
		END IPADDRESS

	ELSEIF cType == 'BROWSE'

//      MsgInfo( 'EXPERIMENTAL CODE: This control can be dragged from the borders only' )

		nBrowseCounter++
		cVar := 'Browse_' + alltrim(str(nBrowseCounter))

                DEFINE BROWSE &cVar
			Parent		oEdit
			Row		nCurrentRow
			Col		nCurrentCol
			Width		200
			Height		200
                        WorkArea	demo
                        Headers		{ 'First Name' , 'Last Name', 'Birth Date', 'Married' , 'Salary' , 'Notes' }
                        Widths		{ 100 , 100 , 100 , 100 , 100 , 250 }
                        Fields		{ 'Demo->First' , 'Demo->Last' , 'Demo->Hiredate' , 'Demo->Married' , 'Demo->Salary' , 'Demo->Notes' }
                        Value		1
                END BROWSE

	ENDIF

	IF !(cType $ 'RADIOGROUP,FRAME,SPINNER')

		DEFINE CONTEXT MENU CONTROL &cVar OF oEdit
			MENUITEM "Move Control" ACTION MoveControl( _HMG_aControlNames[ _HMG_xControlsContextMenuID ] )
			MENUITEM "Resize Control" ACTION ResizeControl( _HMG_aControlNames[ _HMG_xControlsContextMenuID ] )
		END MENU

	ENDIF

	oControl := cVar

	Inspector.ObjectList.AddItem( cVar )
	Inspector.ObjectList.value := ( Inspector.ObjectList.ItemCount )
	UpdateProperties( cVar, GetControlType( cVar, 'oEdit' ) )

	IF cType $ 'LABEL,HYPERLINK'

		oEdit.&(oControl).Action := bOnClickAction

	ELSEIF !(cType $ 'RADIOGROUP,SLIDER')

		oEdit.&(oControl).OnGotFocus := bOnClickAction
	ENDIF

	DrawFocusRect( oControl )

	DisableControlButtonBar( .T. )

	SetArrowCursor( GetFormHandle( 'oEdit' ) )

	Main.StatusBar.Item(1) := 'Row:' + str( oEdit.&(oControl).row, 4, 0 ) + '  ' + 'Col:' + str( oEdit.&(oControl).col, 4, 0 ) + '  ' + 'Width: ' + str( oEdit.&(oControl).Width, 4, 0 ) + '  ' + 'Height:'+ '  ' + str( oEdit.&(oControl).Height, 4, 0 )

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE DisableControlButtonBar( lUncheck )
   LOCAL i, cName

	DEFAULT lUncheck := .F.

	Main.Control_00.Value := lUncheck

	FOR i := 1 TO 24
		cName := 'control_' + StrZero ( i , 2 )
		SetProperty( 'Main', cName, 'value', .F. )
	NEXT i

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE MoveControl( cControl )
   LOCAL ControlHandle := GetControlHandle( cControl, 'oEdit' )
   LOCAL z

	InterActiveMove()

        z := aScan( _HMG_aControlHandles, ControlHandle )

	IF z > 0

		nCurrentCol := GetWindowCol( _HMG_aControlHandles[ z ] ) - oEdit.Col - nBorderWidth
		nCurrentRow := GetWindowRow( _HMG_aControlHandles[ z ] ) - oEdit.Row - nTitleBarHeight - nBorderWidth

		nCurrentCol := int(nCurrentCol / 10) * 10
		nCurrentRow := int(nCurrentRow / 10) * 10

		_HMG_aControlCol[ z ] := nCurrentCol
		_HMG_aControlRow[ z ] := nCurrentRow

		_SetControlSizePos( _HMG_aControlnames[ z ], 'oEdit', _HMG_aControlRow[ z ], _HMG_aControlCol[ z ], _HMG_aControlWidth[ z ], _HMG_aControlHeight[ z ] )

		Main.StatusBar.Item(1) := 'Row:' + str( nCurrentCol, 4, 0 ) + '  ' + 'Col:' + str( nCurrentRow, 4, 0 ) + '  ' + 'Width: ' + str( oEdit.&(cControl).Width, 4, 0 ) + '  ' + 'Height:'+ '  ' + str( oEdit.&(cControl).Height, 4, 0 )

		DrawFocusRect( cControl )

		UpdateProperties( cControl, GetControlType( cControl, 'oEdit' ) )

	ENDIF

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE ResizeControl( cControl )
   LOCAL ControlHandle := GetControlHandle( cControl, 'oEdit' )
   LOCAL z

	InterActiveSize()

        z := aScan( _HMG_aControlHandles, ControlHandle )

	IF z > 0

		_HMG_aControlWidth[ z ]  := GetWindowWidth( ControlHandle )
		_HMG_aControlHeight[ z ] := GetWindowHeight( ControlHandle )

		_SetControlSizePos( _HMG_aControlnames[ z ], 'oEdit', _HMG_aControlRow[ z ], _HMG_aControlCol[ z ], _HMG_aControlWidth[ z ], _HMG_aControlHeight[ z ] )

		Main.StatusBar.Item(1) := 'Row:' + str( oEdit.&(cControl).row, 4, 0 ) + '  ' + 'Col:' + str( oEdit.&(cControl).col, 4, 0 ) + '  ' + 'Width: ' + str( oEdit.&(cControl).Width, 4, 0 ) + '  ' + 'Height:'+ '  ' + str( oEdit.&(cControl).Height, 4, 0 )

		DrawFocusRect( cControl )

		UpdateProperties( cControl, GetControlType( cControl, 'oEdit' ) )

	ENDIF

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE SetEditWindowCursor( nType )

   IF IsWindowDefined( oEdit )

	IF nType == 2
		SetCrossCursor( GetFormHandle( 'oEdit' ) )
	ELSE
		SetArrowCursor( GetFormHandle( 'oEdit' ) )
	ENDIF

   ENDIF

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE ChangeControlEvent( nColumn )
   LOCAL nRow := Inspector.Events.value
   LOCAL cEvent := Inspector.Events.Cell ( nRow, 1 )
   LOCAL cValue := Inspector.Events.Cell ( nRow, 2 )
   LOCAL cResult

   IF IsWindowDefined( oEdit )

	IF nColumn == 2

		cResult := InputBox ( cEvent +':', 'Event Edit', cValue )

		IF !_HMG_DialogCancelled

			Inspector.Events.Cell ( nRow, 2 ) := cResult

		ENDIF

	ENDIF

   ENDIF

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE ChangeControlProperties( oControl )
   LOCAL nRow := Inspector.Properties.value
   LOCAL cProperty := Inspector.Properties.Cell ( nRow, 1 )
   LOCAL cValue := Inspector.Properties.Cell ( nRow, 2 )
   LOCAL cResult, aResult, nValue, bOnClickAction

   IF IsWindowDefined( oEdit )

	cValue := alltrim(cValue)

	nValue := Val(cValue)

	IF nValue > 0 .or. cValue == '0'  // numeric value

		nValue := PropertyInputBox ( cProperty +':', , nValue, 1 )

		IF !_HMG_DialogCancelled

			cResult := hb_ntos(nValue)

			IF oControl <> 'Form'
				SetProperty( 'oEdit', oControl, cProperty, nValue )
			ELSE
				SetProperty( 'oEdit', cProperty, nValue )
			ENDIF

		ENDIF

	ELSEIF Len(cValue) == 3 .and. Substr(cValue,1,1) + Substr(cValue,3,1) == '..'  // logical value

		cResult := PropertyInputBox ( cProperty +':', , cValue, 2, {'.T.', '.F.'} )

		IF !_HMG_DialogCancelled

			IF oControl <> 'Form'
				SetProperty( 'oEdit', oControl, cProperty, ( cResult == '.T.' ) )
			ELSE
				IF cProperty == 'Visible'
					cWindowVisible := cResult
				ELSE
					SetProperty( 'oEdit', cProperty, ( cResult == '.T.' ) )
				ENDIF
			ENDIF

		ENDIF

	ELSEIF cProperty == 'BackColor' .Or. cProperty == 'FontColor' .Or. cProperty == 'ForeColor'

		aResult := GetColor( str2arr( cValue ) )

		IF ISNIL( aResult[1] )

			cResult := cValue

			IF MsgYesNo('Are you want to restore a default color?', 'Confirm')
				cResult := 'Nil'

				IF oControl <> 'Form'
					SetProperty( 'oEdit', oControl, cProperty, Nil )
				ELSE
					SetProperty( 'oEdit', cProperty, Nil )
				ENDIF
			ENDIF

		ELSE

			cResult := "{"+ hb_ntos(aResult[1])+","+ hb_ntos(aResult[2])+","+ hb_ntos(aResult[3])+"}"

			IF oControl <> 'Form'
				SetProperty( 'oEdit', oControl, cProperty, aResult )
			ELSE
				SetProperty( 'oEdit', cProperty, aResult )
			ENDIF

		ENDIF

		oEdit.Hide()
		oEdit.Show()

	ELSEIF cProperty == 'WindowType'

		cResult := PropertyInputBox ( cProperty +':', , cValue, 2, {'CHILD', 'MAIN', 'MODAL', 'SPLITCHILD', 'STANDARD'} )

		IF !_HMG_DialogCancelled

			cWindowType := cResult

		ENDIF

	ELSEIF cProperty == 'Alignment'

		aResult := {'LEFT', 'RIGHT'}
		IF 'Label' $ oControl .Or. 'Hyperlink' $ oControl
			Aadd( aResult, 'CENTER' )
		ENDIF

		cResult := PropertyInputBox ( cProperty +':', , cValue, 2, aResult )

		IF !_HMG_DialogCancelled

			IF oControl <> 'Form'
//				SetProperty( 'oEdit', oControl, cProperty, aResult )
			ENDIF

		ENDIF

	ELSEIF cProperty == 'CaseConvert'

		cResult := PropertyInputBox ( cProperty +':', , cValue, 2, {'LOWER', 'NONE', 'UPPER'} )

		IF !_HMG_DialogCancelled

			IF oControl <> 'Form'
//				SetProperty( 'oEdit', oControl, cProperty, cResult )
			ENDIF

		ENDIF

	ELSEIF cProperty == 'DataType'

		cResult := PropertyInputBox ( cProperty +':', , cValue, 2, {'CHARACTER', 'DATE', 'NUMERIC'} )

		IF !_HMG_DialogCancelled

			IF oControl <> 'Form'
//				SetProperty( 'oEdit', oControl, cProperty, cResult )
			ENDIF

		ENDIF

	ELSEIF cProperty == 'Orientation'

		cResult := PropertyInputBox ( cProperty +':', , cValue, 2, {'HORIZONTAL', 'VERTICAL'} )

		IF !_HMG_DialogCancelled

			IF oControl <> 'Form'
//				SetProperty( 'oEdit', oControl, cProperty, cResult )
			ENDIF

		ENDIF

	ELSEIF cProperty == 'TickMarks'

		cResult := PropertyInputBox ( cProperty +':', , cValue, 2, {'BOTH', 'BOTTOM', 'NONE', 'TOP'} )

		IF !_HMG_DialogCancelled

			IF oControl <> 'Form'
//				SetProperty( 'oEdit', oControl, cProperty, cResult )
			ENDIF

		ENDIF

	ELSEIF cProperty == 'Value' .And. 'IpAddress' $ oControl

		cResult := InputBox ( cProperty +':', 'Property Edit', cValue )

		IF !_HMG_DialogCancelled

			SetProperty( 'oEdit', oControl, cProperty, str2arr4( cResult ) )

		ENDIF

	ELSE

		cResult := InputBox ( cProperty +':', 'Property Edit', cValue )

		IF !_HMG_DialogCancelled

			IF oControl <> 'Form'
				IF cProperty == 'Name'
//					SetProperty( 'oEdit', oControl, cProperty, cResult )
				ELSEIF 'DatePicker' $ oControl .Or. 'MonthCalendar' $ oControl
					SetProperty( 'oEdit', oControl, cProperty, &cResult )
				ELSE
					IF cProperty == 'Address'
						bOnClickAction := GetProperty( 'oEdit', oControl, 'Action' )
						cResult := 'http://hmgextended.com'
					ENDIF

					SetProperty( 'oEdit', oControl, cProperty, cResult )

					IF cProperty == 'Address'
						oEdit.&(oControl).Action := bOnClickAction
					ENDIF
				ENDIF
			ELSE
				SetProperty( 'oEdit', cProperty, cResult )
			ENDIF

		ENDIF

	ENDIF

	IF !_HMG_DialogCancelled

		Inspector.Properties.Cell ( nRow, 2 ) := cResult
		DrawSnapGrid()
		IF oControl <> 'Form'
			DrawFocusRect( oControl )
		ENDIF

	ENDIF

   ENDIF

RETURN

/*----------------------------------------------------------------------*/

STATIC PROCEDURE DrawFocusRect( oControl )

	ERASE WINDOW oEdit

	DRAW RECTANGLE IN WINDOW oEdit AT oEdit.&(oControl).row - 1 , oEdit.&(oControl).col - 1 TO oEdit.&(oControl).row + oEdit.&(oControl).height + 1 , oEdit.&(oControl).col + oEdit.&(oControl).width + 1 PENCOLOR { 128, 128, 128 } PENWIDTH 2

  	DRAW RECTANGLE IN WINDOW oEdit AT oEdit.&(oControl).row + oEdit.&(oControl).height + 2 , oEdit.&(oControl).col + oEdit.&(oControl).width + 2 TO oEdit.&(oControl).row + oEdit.&(oControl).height - 6 , oEdit.&(oControl).col + oEdit.&(oControl).width - 6 PENCOLOR { 128, 128, 128 } PENWIDTH 2 FILLCOLOR {192,192,192}

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE UpdateProperties( cControl, cType )

	IF cType == 'BUTTON'

		IF 'AnimateBox' $ cControl
			cType := 'ANIMATEBOX'
		ELSEIF 'Image' $ cControl
			cType := 'IMAGE'
		ELSEIF 'Timer' $ cControl
			cType := 'TIMER'
		ENDIF

	ELSEIF cType == 'CHECKBOX' .And. 'CheckButton' $ cControl
		cType := 'CHECKBUTTON'

	ENDIF

	IF cType == 'BUTTON'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Caption',	oEdit.&(cControl).caption } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'Flat',		'.F.' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'MultiLine',	'.F.' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Transparent',	'.F.' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'Action',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'CHECKBOX'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Caption',	oEdit.&(cControl).caption } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'Field',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Transparent',	'.F.' } )
		Inspector.Properties.AddItem ( {'Value',	iif(oEdit.&(cControl).value,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'LIST'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'DragItems',	'.F.' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Items',	'{""}' } )
		Inspector.Properties.AddItem ( {'MultiSelect',	'.F.' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'Sort',		'.F.' } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnDblClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )
		
	ELSEIF cType == 'COMBO'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'DisplayEdit',	'.F.' } )
		Inspector.Properties.AddItem ( {'DroppedWidth',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Items',	'{""}' } )
		Inspector.Properties.AddItem ( {'ItemSource',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'Sort',		'.F.' } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'ValueSource',	'' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnCloseUp',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnDisplayChange',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnDropDown',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnEnter',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'CHECKBUTTON'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Caption',	oEdit.&(cControl).caption } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Picture',	oEdit.&(cControl).picture } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	iif(oEdit.&(cControl).value,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'GRID'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'CellNavigation',	'.F.' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'ColumnControls',	'Nil' } )
		Inspector.Properties.AddItem ( {'ColumnValid',	'Nil' } )
		Inspector.Properties.AddItem ( {'ColumnWhen',	'Nil' } )
		Inspector.Properties.AddItem ( {'DynamicBackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'DynamicForeColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Headers',	'{""}' } )
		Inspector.Properties.AddItem ( {'HeaderImages',	'Nil' } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Image',	'Nil' } )
		Inspector.Properties.AddItem ( {'ItemCount',	'Nil' } )
		Inspector.Properties.AddItem ( {'Items',	'{ {""} }' } )
		Inspector.Properties.AddItem ( {'Justify',	'Nil' } )
		Inspector.Properties.AddItem ( {'Lines',	'.T.' } )
		Inspector.Properties.AddItem ( {'MultiSelect',	'.F.' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'ShowHeaders',	'.T.' } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )
		Inspector.Properties.AddItem ( {'Widths',	'{ 0 }' } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnDblClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnHeadClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnQueryData',	'Nil','+','-','' } )

	ELSEIF cType == 'SLIDER'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Orientation',	'HORIZONTAL' } )
		Inspector.Properties.AddItem ( {'RangeMax',	hb_ntos(oEdit.&(cControl).rangeMax) } )
		Inspector.Properties.AddItem ( {'RangeMin',	hb_ntos(oEdit.&(cControl).rangeMin) } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'TickMarks',	'BOTTOM' } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnScroll',		'Nil','+','-','' } )

	ELSEIF cType == 'SPINNER'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Increment',	'1' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'RangeMax',	hb_ntos(oEdit.&(cControl).rangeMax) } )
		Inspector.Properties.AddItem ( {'RangeMin',	hb_ntos(oEdit.&(cControl).rangeMin) } )
		Inspector.Properties.AddItem ( {'ReadOnly',	iif(oEdit.&(cControl).readonly,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )
		Inspector.Properties.AddItem ( {'Wrap',		'.F.' } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'IMAGE'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Picture',	oEdit.&(cControl).picture } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'Stretch',	'.F.' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'Action',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMouseHover',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMouseLeave',	'Nil','+','-','' } )

	ELSEIF cType == 'TREE'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'ItemIds',	'.F.' } )
		Inspector.Properties.AddItem ( {'ItemImages',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'NodeImages',	'Nil' } )
		Inspector.Properties.AddItem ( {'RootButton',	'.T.' } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnDblClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'DATEPICK'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'DateFormat',	'Nil' } )
		Inspector.Properties.AddItem ( {'Field',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'RangeMax',	hb_ntos(oEdit.&(cControl).rangeMax) } )
		Inspector.Properties.AddItem ( {'RangeMin',	hb_ntos(oEdit.&(cControl).rangeMin) } )
		Inspector.Properties.AddItem ( {'RightAlign',	'.F.' } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'ShowNone',	'.F.' } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'UpDown',	'.F.' } )
		Inspector.Properties.AddItem ( {'Value',	iif(oEdit.&(cControl).value==Date(),'CTOD("  /  /  ")','CTOD("'+DtoC(oEdit.&(cControl).value)+'")') } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnEnter',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF 'TEXT' $ cType

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Border',	'.T.' } )
		Inspector.Properties.AddItem ( {'CaseConvert',	'NONE' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'DataType',	'CHARACTER' } )
		Inspector.Properties.AddItem ( {'Field',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Format',	'' } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'InputMask',	'' } )
		Inspector.Properties.AddItem ( {'MaxLength',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Password',	'.F.' } )
		Inspector.Properties.AddItem ( {'ReadOnly',	iif(oEdit.&(cControl).readonly,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'RightAlign',	'.F.' } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ValToStr(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnEnter',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'EDIT'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'Field',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'HScrollBar',	'.T.' } )
		Inspector.Properties.AddItem ( {'MaxLength',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'ReadOnly',	iif(oEdit.&(cControl).readonly,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	oEdit.&(cControl).value } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'VScrollBar',	'.T.' } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )
		
	ELSEIF cType == 'LABEL'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Alignment',	'LEFT' } )
		Inspector.Properties.AddItem ( {'AutoSize',	'.F.' } )
		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Border',	'.F.' } )
		Inspector.Properties.AddItem ( {'Blink',	'.F.' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Transparent',	'.F.' } )
		Inspector.Properties.AddItem ( {'Value',	oEdit.&(cControl).value } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'Action',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMouseHover',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMouseLeave',	'Nil','+','-','' } )

	ELSEIF cType == 'TIMER'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Interval',	'0' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'Action',		'Nil','+','-','' } )

	ELSEIF cType == 'RADIOGROUP'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Alignment',	'RIGHT' } )
		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Orientation',	'VERTICAL' } )
		Inspector.Properties.AddItem ( {'Options',	"{'New 1','New 2','New 3'}" } )
		Inspector.Properties.AddItem ( {'ReadOnly',	'Nil' } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'Spacing',	'25' } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Transparent',	'.F.' } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )

	ELSEIF cType == 'FRAME'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Caption',	oEdit.&(cControl).caption } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'Transparent',	'.F.' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()

	ELSEIF cType == 'TAB'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Buttons',	'.F.' } )
		Inspector.Properties.AddItem ( {'Captions',	"{'One','Two'}" } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'Flat',		'.F.' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HotTrack',	'.F.' } )
		Inspector.Properties.AddItem ( {'MultiLine',	'.F.' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'PageCount',	hb_ntos(oEdit.&(cControl).itemcount) } )
		Inspector.Properties.AddItem ( {'PageImages',	"{'',''}" } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Vertical',	'.F.' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )

	ELSEIF cType == 'ANIMATEBOX'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'AutoPlay',	'.F.' } )
		Inspector.Properties.AddItem ( {'Center',	'.F.' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'File',		'' } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Picture',	oEdit.&(cControl).picture } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'Transparent',	'.F.' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()

	ELSEIF cType == 'HYPERLINK'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Address',	oEdit.&(cControl).address } )
		Inspector.Properties.AddItem ( {'Alignment',	'LEFT' } )
		Inspector.Properties.AddItem ( {'AutoSize',	'.F.' } )
		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Border',	'.F.' } )
		Inspector.Properties.AddItem ( {'Caption',	oEdit.&(cControl).caption } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'HandCursor',	'.F.' } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Transparent',	'.F.' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()

	ELSEIF cType == 'MONTHCAL'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Today',	'.T.' } )
		Inspector.Properties.AddItem ( {'TodayCircle',	'.T.' } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	iif(oEdit.&(cControl).value==Date(),'CTOD("  /  /  ")','CTOD("'+DtoC(oEdit.&(cControl).value)+'")') } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'WeekNumbers',	'.F.' } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnSelect',		'Nil','+','-','' } )

	ELSEIF cType == 'PROGRESSBAR'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'ForeColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Orientation',	'HORIZONTAL' } )
		Inspector.Properties.AddItem ( {'RangeMax',	hb_ntos(oEdit.&(cControl).rangeMax) } )
		Inspector.Properties.AddItem ( {'RangeMin',	hb_ntos(oEdit.&(cControl).rangeMin) } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'Smooth',	'.F.' } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()

	ELSEIF cType == 'IPADDRESS'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Value',	arr2str(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ELSEIF cType == 'BROWSE'

		Inspector.Properties.DeleteAllItems()

		Inspector.Properties.AddItem ( {'AllowAppend',	iif(oEdit.&(cControl).AllowAppend,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'AllowDelete',	iif(oEdit.&(cControl).AllowDelete,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'AllowEdit',	iif(oEdit.&(cControl).AllowEdit,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'BackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.&(cControl).col) } )
		Inspector.Properties.AddItem ( {'DisplayItems',	'Nil' } )
		Inspector.Properties.AddItem ( {'DynamicBackColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'DynamicForeColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'Fields',	'{""}' } )
		Inspector.Properties.AddItem ( {'FontBold',	iif(oEdit.&(cControl).fontBold,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontColor',	'Nil' } )
		Inspector.Properties.AddItem ( {'FontItalic',	iif(oEdit.&(cControl).fontItalic,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontName',	oEdit.&(cControl).fontName } )
		Inspector.Properties.AddItem ( {'FontUnderLine',iif(oEdit.&(cControl).fontUnderline,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'FontSize',	hb_ntos(oEdit.&(cControl).fontSize) } )
		Inspector.Properties.AddItem ( {'FontStrikeOut',iif(oEdit.&(cControl).fontStrikeOut,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Headers',	'{""}' } )
		Inspector.Properties.AddItem ( {'HeaderImages',	'Nil' } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.&(cControl).height) } )
		Inspector.Properties.AddItem ( {'HelpId',	'Nil' } )
		Inspector.Properties.AddItem ( {'Image',	'Nil' } )
		Inspector.Properties.AddItem ( {'InputItems',	'Nil' } )
		Inspector.Properties.AddItem ( {'Justify',	'Nil' } )
		Inspector.Properties.AddItem ( {'Lines',	'.T.' } )
		Inspector.Properties.AddItem ( {'Lock',		'.F.' } )
		Inspector.Properties.AddItem ( {'Name',		oEdit.&(cControl).name } )
		Inspector.Properties.AddItem ( {'ReadOnlyFields',	'Nil' } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.&(cControl).row) } )
		Inspector.Properties.AddItem ( {'TabStop',	iif(oEdit.&(cControl).tabStop,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'ToolTip',	oEdit.&(cControl).toolTip } )
		Inspector.Properties.AddItem ( {'Valid',	'Nil' } )
		Inspector.Properties.AddItem ( {'ValidMessages','Nil' } )
		Inspector.Properties.AddItem ( {'Value',	hb_ntos(oEdit.&(cControl).value) } )
		Inspector.Properties.AddItem ( {'VScrollBar',	'.T.' } )
		Inspector.Properties.AddItem ( {'Visible',	iif(oEdit.&(cControl).visible,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'When',		'Nil' } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.&(cControl).width) } )
		Inspector.Properties.AddItem ( {'Widths',	'{ 0 }' } )
		Inspector.Properties.AddItem ( {'WorkArea',	'Nil' } )

		Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnChange',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnDblClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnHeadClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )

	ENDIF

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE UpdateFormProperties()
   LOCAL aResult

	Inspector.Properties.DeleteAllItems()
		aResult := oEdit.backcolor
		aResult := iif(ISARRAY(aResult) .and. aResult[1] <> -1, "{"+ hb_ntos(aResult[1])+","+ hb_ntos(aResult[2])+","+ hb_ntos(aResult[3])+"}", 'Nil')
		Inspector.Properties.AddItem ( {'BackColor',	aResult } )
		Inspector.Properties.AddItem ( {'Col',		hb_ntos(oEdit.col) } )
		Inspector.Properties.AddItem ( {'Cursor',	'' } )
		Inspector.Properties.AddItem ( {'Height',	hb_ntos(oEdit.height) } )
		Inspector.Properties.AddItem ( {'HelpButton',	iif(oEdit.HelpButton,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Icon',		'' } )
		Inspector.Properties.AddItem ( {'MaxButton',	iif(oEdit.MaxButton,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'MinButton',	iif(oEdit.MinButton,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'NotifyIcon',	oEdit.NotifyIcon } )
		Inspector.Properties.AddItem ( {'NotifyTooltip', oEdit.NotifyTooltip } )
		Inspector.Properties.AddItem ( {'Row',		hb_ntos(oEdit.row) } )
		Inspector.Properties.AddItem ( {'Sizable',	iif(oEdit.Sizable,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'SysMenu',	iif(oEdit.SysMenu,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Title',	oEdit.Title } )
		Inspector.Properties.AddItem ( {'TitleBar',	iif(oEdit.TitleBar,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Topmost',	iif(oEdit.Topmost,'.T.','.F.' ) } )
		Inspector.Properties.AddItem ( {'Virtual Sized', '.F.' } )
		Inspector.Properties.AddItem ( {'Virtual Height', 'Nil' } )
		Inspector.Properties.AddItem ( {'Virtual Width', 'Nil' } )
		Inspector.Properties.AddItem ( {'Visible',	cWindowVisible } )
		Inspector.Properties.AddItem ( {'Width',	hb_ntos(oEdit.width) } )
		Inspector.Properties.AddItem ( {'WindowType',	cWindowType } )

	Inspector.Events.DeleteAllItems()
		Inspector.Events.AddItem ( {'OnGotFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnHScrollBox',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnInit',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnInteractiveClose',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnLostFocus',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMaximize',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMinimize',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMouseClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMouseDrag',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnMouseMove',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnNotifyClick',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnPaint',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnRelease',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnRestore',	'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnSize',		'Nil','+','-','' } )
		Inspector.Events.AddItem ( {'OnVScrollBox',	'Nil','+','-','' } )

RETURN

/*----------------------------------------------------------------------*/

PROCEDURE EditClickProcess()
	LOCAL x, y
	LOCAL aPos := GetCursorPos()

	y := aPos[1]
	x := aPos[2]

	nCurrentCol := x - oEdit.Col - nBorderWidth
	nCurrentRow := y - oEdit.Row - nTitleBarHeight - nBorderWidth

	nCurrentCol := int(nCurrentCol / 20) * 20
	nCurrentRow := int(nCurrentRow / 20) * 20

	AddControl()

	cCurrentControl := ''

RETURN

/*----------------------------------------------------------------------*/

Function PropertyInputBox ( cInputPrompt , cDialogCaption , cDefaultValue , nType , aArray )
   Local lIsVistaOrLater := IsVistaOrLater()
   Local nBordW  := iif(lIsVistaOrLater, GetBorderWidth() / 2 + 2, 0)
   Local nTitleH := GetTitleHeight() + iif(lIsVistaOrLater, GetBorderHeight() / 2 + 2, 0)
   Local RetVal  := ''
   Local bCancel := {|| _HMG_DialogCancelled := .T., DoMethod( '_PropertyInputBox', 'Release' ) }

   DEFAULT cInputPrompt TO "", cDialogCaption TO "Property Edit", cDefaultValue TO ""

   DEFINE WINDOW _PropertyInputBox;
      AT 0,0;
      WIDTH 310 + nBordW;
      HEIGHT 115 + nTitleH;
      TITLE cDialogCaption;
      ICON "ZZZ_A_WINDOW";
      MODAL NOSIZE

      ON KEY ESCAPE ACTION Eval( bCancel )

      @ 07, 10 LABEL _Label VALUE cInputPrompt AUTOSIZE

      If nType == 1
         ON KEY RETURN ACTION _PropertyInputBox._Ok.Action

         @ 30, 10 SPINNER _Input ;
		RANGE 0,10000 ;
		VALUE cDefaultValue ;
		HEIGHT 26 ;
		WIDTH 280
      Else
         @ 30, 10 COMBOBOX _Input ;
		WIDTH 280 ;
		ITEMS aArray ;
		VALUE aScan(aArray, cDefaultValue) ;
		ON ENTER _PropertyInputBox._Ok.Action
      EndIf

      @ 67, 80 BUTTON _Ok;
         CAPTION _HMG_MESSAGE [6];
         ACTION ( _HMG_DialogCancelled := .F., RetVal := IIf( nType == 1,;
		_PropertyInputBox._Input.Value, aArray[_PropertyInputBox._Input.Value] ),;
		_PropertyInputBox.Release )

      @ 67, 190 BUTTON _Cancel;
         CAPTION _HMG_MESSAGE [7];
         ACTION Eval( bCancel )

   END WINDOW

   _PropertyInputBox._Input.SetFocus

   CENTER WINDOW _PropertyInputBox
   ACTIVATE WINDOW _PropertyInputBox

Return ( RetVal )

/*----------------------------------------------------------------------*/

STATIC FUNCTION str2arr( cList )
LOCAL cElem
LOCAL aList := {}

  IF Upper( cList ) # "Nil"
     cElem := SubStr( cList, 2, At( ",", cList ) - 1 )
     aAdd( aList, Val( cElem ) )

     cElem := SubStr( cList, At( ",", cList ) + 1, Rat( ",", cList ) - 1 )
     aAdd( aList, Val( cElem ) )

     cElem := SubStr( cList, Rat( ",", cList ) + 1, Len( cList ) - 1 )
     aAdd( aList, Val( cElem ) )
  ELSE
      aList := NIL
  ENDIF
RETURN ( aList )

/*----------------------------------------------------------------------*/

STATIC FUNCTION str2arr4( cList )
LOCAL cElem
LOCAL aList := {}

  IF Upper( cList ) # "Nil"
     cElem := SubStr( cList, 2, At( ",", cList ) - 1 )
     aAdd( aList, Val( cElem ) )

     cElem := SubStr( cList, At( ",", cList ) + 1, Rat( ",", cList ) - 1 )
     aAdd( aList, Val( Token( cElem, ",", 1 ) ) )

     aAdd( aList, Val( Token( cElem, ",", 2 ) ) )

     cElem := SubStr( cList, Rat( ",", cList ) + 1, Len( cList ) - 1 )
     aAdd( aList, Val( cElem ) )
  ELSE
      aList := NIL
  ENDIF
RETURN ( aList )

/*----------------------------------------------------------------------*/

STATIC FUNCTION arr2str( aList )
RETURN ( "{ " + hb_ntos(aList[1]) + ", " + hb_ntos(aList[2]) + ", " + hb_ntos(aList[3]) + ", " + hb_ntos(aList[4]) + " }" )

/*----------------------------------------------------------------------*/

PROCEDURE DrawSnapGrid()
   LOCAL i, j
   LOCAL fHandle
   LOCAL nHeight
   LOCAL nWidth
   LOCAL hDC

   fHandle := GetFormHandle( "oEdit" )
   nHeight := oEdit.Height
   nWidth := oEdit.Width
   hDC := GetDC( fHandle )

   FOR i := 10 TO nWidth STEP 10
       FOR j := 10 TO nHeight STEP 10
           SetPixel( hDC, i, j, RGB( 0, 0, 0 ) )
       NEXT
   NEXT

   ReleaseDC( fHandle, hDC )

RETURN


/*
 * C-level
*/

#pragma BEGINDUMP

#include <windows.h>

#include "hbapi.h"

HB_FUNC( SETPIXEL )
{
   hb_retnl( (ULONG) SetPixel( (HDC) hb_parnl( 1 ) ,
				hb_parni( 2 )      ,
				hb_parni( 3 )      ,
			(COLORREF) hb_parnl( 4 ) ) );
}

HB_FUNC( SETCROSSCURSOR )
{
   SetClassLong( ( HWND ) hb_parnl(1), GCL_HCURSOR, ( LONG ) LoadCursor(NULL, IDC_CROSS) );
}

HB_FUNC( INTERACTIVEMOVE )
{
   keybd_event(
      VK_RIGHT,  // virtual-key code
      0,         // hardware scan code
      0,         // flags specifying various function options
      0          // additional data associated with keystroke
      );

   keybd_event(
      VK_LEFT,   // virtual-key code
      0,         // hardware scan code
      0,         // flags specifying various function options
      0          // additional data associated with keystroke
      );

   SendMessage( GetFocus(), WM_SYSCOMMAND, SC_MOVE, 10 );
   RedrawWindow( GetFocus(), NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
}

HB_FUNC( INTERACTIVESIZE )
{
   keybd_event(
      VK_DOWN,
      0,
      0,
      0
      );

   keybd_event(
      VK_RIGHT,
      0,
      0,
      0
      );

   SendMessage( GetFocus(), WM_SYSCOMMAND, SC_SIZE, 0 );
}

#pragma ENDDUMP
