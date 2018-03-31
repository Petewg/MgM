/*
 * ListView with Extended styles
*/

#include "minigui.ch"
#include "i_winuser.ch"

Static a_image[2], a_cab[4], a_width[4]

Function Main

Local i, aRows := {}, cChk
Local aStyles := {}, aStylesTip := {}, aStylesEx := {}, aStylesExTip := {}

   a_image[1] = 'BMP_NO'    && 0
   a_image[2] = 'BMP_OK'    && 1

   for i:=1 to 100
	Aadd( aRows, { i%2 , 'Item '+hb_ntos(i) , hb_ntos(i*10) , 'Created: '+ hb_TSToStr( hb_DateTime() ) } )
   next

   a_cab[1] = ''          ; a_width[1] = 20
   a_cab[2] = 'Item Name' ; a_width[2] = 180
   a_cab[3] = 'Value'     ; a_width[3] = 80
   a_cab[4] = 'Time'      ; a_width[4] = 80

	Aadd( aStyles, "ALIGNLEFT" )
	Aadd( aStyles, "ALIGNTOP" )
	Aadd( aStyles, "AUTOARRANGE" )
	Aadd( aStyles, "NOCOLUMNHEADER" )
	Aadd( aStyles, "NOLABELWRAP" )
	Aadd( aStyles, "NOSCROLL" )
	Aadd( aStyles, "NOSORTHEADER" )
	Aadd( aStyles, "SHOWSELALWAYS" )
	Aadd( aStyles, "SINGLESEL" )
	Aadd( aStyles, "SORTASCENDING" )
	Aadd( aStyles, "SORTDESCENDING" )

	Aadd( aStylesTip, "Specifies that items are left-aligned in icon and small icon view." )
	Aadd( aStylesTip, "Specifies that items are aligned with the top of the control in icon and small icon view." )
	Aadd( aStylesTip, "Specifies that icons are automatically kept arranged in icon view and small icon view." )
	Aadd( aStylesTip, "Specifies that a column header is not displayed in report view." )
	Aadd( aStylesTip, "Displays item text on a single line in icon view." )
	Aadd( aStylesTip, "Disables scrolling. All items must be within the client area." )
	Aadd( aStylesTip, "Specifies that column headers do not work like buttons." )
	Aadd( aStylesTip, "Always show the selection, if any, even if the control does not have the focus." )
	Aadd( aStylesTip, "Allows only one item at a time to be selected." )
	Aadd( aStylesTip, "Sorts items based on item text in ascending order." )
	Aadd( aStylesTip, "Sorts items based on item text in descending order." )

	Aadd( aStylesEx, "CHECKBOXES" )
	Aadd( aStylesEx, "FLATSB" )
	Aadd( aStylesEx, "DOUBLEBUFFER" )
	Aadd( aStylesEx, "GRIDLINES" )
	Aadd( aStylesEx, "HEADERDRAGDROP" )
	Aadd( aStylesEx, "INFOTIP" )
	Aadd( aStylesEx, "ONECLICKACTIVATE" )
	Aadd( aStylesEx, "TRACKSELECT" )
	Aadd( aStylesEx, "TWOCLICKACTIVATE" )
	Aadd( aStylesEx, "UNDERLINECOLD" )
	Aadd( aStylesEx, "UNDERLINEHOT" )

	Aadd( aStylesExTip, "Enables check boxes for items in a list view control." )
	Aadd( aStylesExTip, "Enables flat scroll bars in the list view." )
	Aadd( aStylesExTip, "Paints via double-buffering, which reduces flickering." )
	Aadd( aStylesExTip, "Displays gridlines around items and subitems." )
	Aadd( aStylesExTip, "Enables drag-and-drop reordering of columns in a list view control." )
	Aadd( aStylesExTip, "Enables a LVN_GETINFOTIP notification message to the parent window before displaying an item's tooltip." )
	Aadd( aStylesExTip, "The list view control sends an LVN_ITEMACTIVATE notification message to the parent window when the user clicks an item." )
	Aadd( aStylesExTip, "Enables hot-track selection in a list view control.  Requires either ONECLICKACTIVATE or TWOCLICKACTIVATE." )
	Aadd( aStylesExTip, "The list view control sends an LVN_ITEMACTIVATE notification message to the parent window when the user double-clicks an item." )
	Aadd( aStylesExTip, "Causes non-hot items that are activatable to be displayed with underlined text. This style requires that TWOCLICKACTIVATE also be set." )
	Aadd( aStylesExTip, "Causes hot items that are activatable to be displayed with underlined text. This style requires that ONECLICKACTIVATE or TWOCLICKACTIVATE also be set." )

   DEFINE WINDOW Form_1 ;
	AT 0,0 WIDTH 640 HEIGHT 480 ;
	TITLE 'Grid control with Extended styles' ;
	MAIN ;
	NOMAXIMIZE NOSIZE

	DEFINE STATUSBAR 
		STATUSITEM "" FONTCOLOR BLACK CENTERALIGN
	END STATUSBAR

	@ 20,10 GRID Grid_1 ;
		WIDTH  358 ;
		HEIGHT 388 ;
		HEADERS a_cab ;
		WIDTHS a_width ;
		ITEMS aRows ;
		VALUE 1 ;
		IMAGE a_image ;
		ON CHANGE OnChange() ;
		NOLINES ;
		MULTISELECT ;
		PAINTDOUBLEBUFFER

	DEFINE TAB Tab_1 ;
		AT 20,388 ;
		WIDTH 230 ;
		HEIGHT 388 ;
		VALUE 1

		PAGE 'Styles'

			@ 35,15 FRAME Frame_1 WIDTH 200 HEIGHT 300

			for i:=1 to Len(aStyles)
				cChk := "Check1_"+hb_ntos(i)
				@ 30+i*24,30 CHECKBOX &cChk CAPTION aStyles[i] WIDTH 160 HEIGHT 18 TOOLTIP aStylesTip[i]
			next

			@ 350,115 BUTTON Button_1 CAPTION "Apply" WIDTH 100 HEIGHT 26 ACTION ApplyStyles()

		END PAGE

		PAGE 'Extended Styles'

			@ 35,15 FRAME Frame_2 WIDTH 200 HEIGHT 300

			for i:=1 to Len(aStylesEx)
				cChk := "Check2_"+hb_ntos(i)
				@ 30+i*24,30 CHECKBOX &cChk CAPTION aStylesEx[i] WIDTH 160 HEIGHT 18 TOOLTIP aStylesExTip[i]
			next

			@ 350,115 BUTTON Button_2 CAPTION "Apply" WIDTH 100 HEIGHT 26 ACTION ApplyStylesEx()

		END PAGE

	END TAB

	Form_1.Check1_1.Enabled := .F.
	Form_1.Check1_2.Enabled := .F.
	Form_1.Check1_3.Enabled := .F.
	Form_1.Check1_5.Enabled := .F.
	Form_1.Check1_8.Value   := .T.
	Form_1.Check1_8.Enabled := .F.
	Form_1.Check1_10.Value  := .T.

	Form_1.Check2_3.Value := .T.
	Form_1.Check2_5.Value := .T.
	Form_1.Check2_6.Value := .T.

   END WINDOW

   Form_1.Center
   Form_1.Activate

Return Nil

*.......................................................*

Procedure OnChange()

form_1.statusbar.item(1) := ;
	'Selected: ' + iif( ValType( this.value ) == 'N', hb_ntos( this.value ), hb_ValToExp( this.value ) ) +'/'+;
	hb_ntos( form_1.grid_1.ItemCount )

Return

*.......................................................*

Procedure ApplyStyles()
Local i, aRows := {}, v

	v := Form_1.Grid_1.Value
	Form_1.Grid_1.Release
	IF Form_1.Check1_11.Value
		for i:=100 to 1 Step -1
			Aadd( aRows, { i%2 , 'Item '+hb_ntos(i) , hb_ntos(i*10) , 'Created: '+ hb_TSToStr( hb_DateTime() ) } )
		next
		Form_1.Check1_10.Value := .F.
	ELSE
		for i:=1 to 100
			Aadd( aRows, { i%2 , 'Item '+hb_ntos(i) , hb_ntos(i*10) , 'Created: '+ hb_TSToStr( hb_DateTime() ) } )
		next
		Form_1.Check1_10.Value := .T.
	ENDIF
	form_1.statusbar.item(1) := ""
	DEFINE GRID Grid_1
		PARENT Form_1
		ROW 20
		COL 10
		WIDTH  358
		HEIGHT 388
		HEADERS a_cab
		WIDTHS a_width
		ITEMS aRows
		VALUE iif( Form_1.Check1_9.Value, 1, v )
		IMAGE a_image
		ONCHANGE OnChange()
		SHOWHEADERS ! Form_1.Check1_4.Value
		NOSORTHEADERS Form_1.Check1_7.Value
		MULTISELECT ! Form_1.Check1_9.Value
	END GRID

#define LVS_NOSCROLL        0x2000
	SetWindowStyle ( Form_1.Grid_1.Handle, LVS_NOSCROLL, Form_1.Check1_6.Value )

	ApplyStylesEx()

Return

*.......................................................*

Procedure ApplyStylesEx()
Local h := GetControlHandle( "Grid_1", "Form_1" )
Local iStyle

	iStyle := LVS_EX_CHECKBOXES
	IF Form_1.Check2_1.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_FLATSB
	IF Form_1.Check2_2.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_DOUBLEBUFFER
	IF Form_1.Check2_3.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_GRIDLINES
	IF Form_1.Check2_4.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_HEADERDRAGDROP
	IF Form_1.Check2_5.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_INFOTIP
	IF Form_1.Check2_6.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_ONECLICKACTIVATE
	IF Form_1.Check2_7.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_TRACKSELECT
	IF Form_1.Check2_8.Value .AND. ( Form_1.Check2_7.Value .OR. Form_1.Check2_9.Value )
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_TWOCLICKACTIVATE
	IF Form_1.Check2_9.Value
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_UNDERLINECOLD
	IF Form_1.Check2_9.Value .AND. Form_1.Check2_10.Value .AND. Form_1.Check2_11.Value == .F.
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

	iStyle := LVS_EX_UNDERLINEHOT
	IF Form_1.Check2_11.Value .AND. Form_1.Check2_10.Value == .F. .AND. ( Form_1.Check2_7.Value .OR. Form_1.Check2_9.Value )
		ListView_ChangeExtendedStyle ( h, iStyle, NIL )
	ELSE
		ListView_ChangeExtendedStyle ( h, NIL, iStyle )
	ENDIF

Return
