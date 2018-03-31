/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

#define APP_TITLE "MiniGUI Main Demo"
#define APP_ABOUT "Free GUI Library For Harbour"
#define IDI_MAIN 1001
#define MsgInfo( c ) MsgInfo( c, , , .f. )

Function Main
Local TmpVar

	DEFINE WINDOW Form_1 ;
		AT 0,0 ;
		WIDTH 640 HEIGHT 480 ;
		TITLE 'Harbour MiniGUI Demo' ;
		ICON 'DEMO.ICO' ;
		MAIN ;
		FONT 'Arial' SIZE 10 

		DEFINE STATUSBAR
			STATUSITEM 'HMG Power Ready!' 
		END STATUSBAR

		ON KEY ALT+A ACTION MsgInfo('Alt+A Pressed')

		DEFINE MAIN MENU 
			POPUP '&File'
				ITEM 'InputWindow Test'	ACTION InputWindow_Click()
				ITEM 'More Tests'	ACTION Modal_CLick()	NAME File_Modal
				ITEM 'Topmost WIndow'	ACTION Topmost_Click()  NAME File_TopMost
				ITEM 'Standard WIndow'	ACTION Standard_Click()
				ITEM 'Editable Grid Test' ACTION EditGrid_Click()
				ITEM 'Child Window Test' ACTION Child_Click()
				SEPARATOR	
				POPUP 'More...'
					ITEM 'SubItem 1'	ACTION MsgInfo( 'SubItem Clicked' )
					ITEM 'SubItem 2'	ACTION MsgInfo( 'SubItem2 Clicked' )
				END POPUP
				SEPARATOR	
				ITEM 'Multiple Window Activation'	ACTION MultiWin_Click() 
				SEPARATOR	
				ITEM 'Exit'		ACTION Form_1.Release
			END POPUP
			POPUP 'F&older Functions'
				ITEM 'GetWindowsFolder()'	ACTION MsgInfo ( GetWindowsFolder() )
				ITEM 'GetSystemFolder()'	ACTION MsgInfo ( GetSystemFolder() )
				ITEM 'GetMyDocumentsFolder()'	ACTION MsgInfo ( GetMyDocumentsFolder() )
				ITEM 'GetDesktopFolder()'	ACTION MsgInfo ( GetDesktopFolder() )
				ITEM 'GetProgramFilesFolder()'	ACTION MsgInfo ( GetProgramFilesFolder())
				ITEM 'GetTempFolder()'		ACTION MsgInfo ( GetTempFolder() ) 
				SEPARATOR
				ITEM 'GetFolder()'		ACTION MsgInfo(GetFolder())
			END POPUP
			POPUP 'Common &Dialog Functions'
				ITEM 'GetFile()'	ACTION Getfile ( { {'Images','*.jpg'} } , 'Open Image' )
				ITEM 'PutFile()'	ACTION Putfile ( { {'Images','*.jpg'} } , 'Save Image' )
				ITEM 'GetFont()'	ACTION GetFont_Click()
				ITEM 'GetColor()'	ACTION GetColor_Click()
			END POPUP
			POPUP 'Sound F&unctions'
				ITEM 'PlayBeep()'	 ACTION PlayBeep() 
				ITEM 'PlayAsterisk()'	 ACTION PlayAsterisk() 
				ITEM 'PlayExclamation()' ACTION PlayExclamation() 
				ITEM 'PlayHand()'	 ACTION PlayHand() 
				ITEM 'PlayQuestion()'	 ACTION PlayQuestion() 
				ITEM 'PlayOk()'		 ACTION PlayOk() 
			END POPUP
			POPUP 'M&isc'

				ITEM 'MemoryStatus() Function (Contributed by Grigory Filatov)' ACTION MemoryTest() 
				ITEM 'ShellAbout() Function (Contributed by Manu Exposito)' ACTION ShellAbout( "About Main Demo" + "#" + APP_TITLE, ;
							APP_ABOUT + CRLF + "[x]Harbour Power Ready", LoadTrayIcon( GetInstance(), IDI_MAIN, 32, 32 ) )
				ITEM 'BackColor / FontColor Clauses (Contributed by Ismael Dutra)' ACTION Color_CLick() 
				SEPARATOR
				ITEM 'Get Control Row Property' 	ACTION 	( FETCH Button_1 OF Form_1 ROW TO TmpVar , MsgInfo ( Str ( TmpVar ) ) )
				ITEM 'Get Control Col Property' 	ACTION 	( FETCH Button_1 OF Form_1 COL TO TmpVar , MsgInfo ( Str ( TmpVar ) ) )
				ITEM 'Get Control Width Property' 	ACTION 	( FETCH Button_1 OF Form_1 WIDTH TO TmpVar , MsgInfo ( Str ( TmpVar ) ) )
				ITEM 'Get Control Hetight Property' 	ACTION 	( FETCH Button_1 OF Form_1 HEIGHT TO TmpVar , MsgInfo ( Str ( TmpVar ) ) )
				SEPARATOR
				ITEM 'Set Control Row Property' 	ACTION MODIFY Button_1 OF Form_1 ROW 35
				ITEM 'Set Control Col Property' 	ACTION MODIFY Button_1 OF Form_1 COL 40
				ITEM 'Set Control Width Property' 	ACTION MODIFY Button_1 OF Form_1 WIDTH 150
				ITEM 'Set Control Hetight Property' 	ACTION MODIFY Button_1 OF Form_1 HEIGHT 50
				SEPARATOR
				ITEM 'Set Window Row Property' 		ACTION Form_1.ROW := 10
				ITEM 'Set Window Col Property' 		ACTION Form_1.COL := 10
				ITEM 'Set Window Width Property' 	ACTION Form_1.WIDTH := 550
				ITEM 'Set Window Hetight Property' 	ACTION Form_1.HEIGHT := 400
				SEPARATOR
				ITEM 'Get Window Row Property' 		ACTION ( TmpVar := Form_1.ROW , MsgInfo ( Str ( TmpVar ) ) )
				ITEM 'Get Window Col Property' 		ACTION ( TmpVar := Form_1.COL , MsgInfo ( Str ( TmpVar ) ) )
				ITEM 'Get Window Width Property' 	ACTION ( TmpVar := Form_1.TITLE , MsgInfo ( TmpVar ) )
				ITEM 'Get Window Hetight Property' 	ACTION ( TmpVar := Form_1.HEIGHT , MsgInfo ( Str ( TmpVar ) ) )
				SEPARATOR
				ITEM 'Execute Command' 			ACTION ExecTest()
				SEPARATOR
				ITEM 'Set Title Property'		ACTION Form_1.TITLE := 'New Title'
				ITEM 'Get Title Property'		ACTION ( TmpVar := Form_1.TITLE , MsgInfo ( TmpVar ) )
				SEPARATOR
				ITEM 'Set Caption Property'		ACTION SetCaptionTest()
				ITEM 'Get Caption Property'		ACTION GetCaptionTest()
				SEPARATOR
				ITEM 'Get Picture Property'		ACTION ( FETCH CONTROL Image_1 OF Form_1 PICTURE TO TmpVar , MsgInfo ( TmpVar ) ) 
				SEPARATOR
				ITEM 'Set ToolTip Property'		ACTION MODIFY CONTROL Button_1 OF Form_1 TOOLTIP 'New Tooltip'
				ITEM 'Get ToolTip Property'		ACTION ( FETCH CONTROL Button_1 OF Form_1 TOOLTIP TO TmpVar , MsgInfo ( TmpVar ) ) 
				SEPARATOR
				ITEM 'Set FontName Property'		ACTION MODIFY CONTROL Button_1 OF Form_1 FONTNAME 'Verdana'
				ITEM 'Get FontName Property'		ACTION ( FETCH CONTROL Button_1 OF Form_1 FONTNAME TO TmpVar , MsgInfo ( TmpVar ) ) 
				SEPARATOR
				ITEM 'Set FontSize Property'		ACTION MODIFY CONTROL Button_1 OF Form_1 FONTSIZE 14
				ITEM 'Get FontSize Property'		ACTION ( FETCH CONTROL Button_1 OF Form_1 FONTSIZE TO TmpVar , MsgInfo ( Str ( TmpVar ) ) )
				SEPARATOR
				ITEM 'Set RangeMin Property'		ACTION MODIFY CONTROL Spinner_1 OF Form_1 RANGEMIN 1
				ITEM 'Get RangeMin Property'		ACTION ( FETCH CONTROL Spinner_1 OF Form_1 RANGEMIN TO TmpVar , MsgInfo ( Str ( TmpVar ) ) ) 
				SEPARATOR
				ITEM 'Set RangeMax Property'		ACTION MODIFY CONTROL Spinner_1 OF Form_1 RANGEMAX 1000
				ITEM 'Get RangeMax Property'		ACTION ( FETCH CONTROL Spinner_1 OF Form_1 RANGEMAX TO TmpVar , MsgInfo ( Str ( TmpVar ) ) )
				SEPARATOR
				ITEM 'Set Grid Caption Property'	ACTION MODIFY CONTROL Grid_1 OF Form_1 CAPTION (1) 'New Caption'
				ITEM 'Get Grid Caption Property'	ACTION ( FETCH CONTROL Grid_1 OF Form_1 CAPTION (1) TO TmpVar , MsgInfo ( TmpVar ) )
				SEPARATOR
				ITEM 'Set RadioGroup Caption Property'	ACTION MODIFY CONTROL Radio_1 OF Form_1 CAPTION (1) 'New Caption'
				ITEM 'Get RadioGroup Caption Property'	ACTION ( FETCH CONTROL Radio_1 OF Form_1 CAPTION (1) TO TmpVar , MsgInfo ( TmpVar ) )
				SEPARATOR
				ITEM 'Set Tab Caption Property'	ACTION MODIFY CONTROL Tab_1 OF Form_1 CAPTION (1) 'New Caption' 
				ITEM 'Get Tab Caption Property'	ACTION ( FETCH CONTROL Tab_1 OF Form_1 CAPTION (1) TO TmpVar , MsgInfo ( TmpVar ) )

			END POPUP
			POPUP 'H&elp'
				ITEM 'About'		ACTION MsgInfo ("Free GUI Library For Harbour","MiniGUI Main Demo") 
			END POPUP
		END MENU

		DEFINE CONTEXT MENU 
			ITEM 'Check File - More Tests Item'	ACTION Context1_Click()
			ITEM 'UnCheck File - More Test Item'	ACTION Context2_Click() 
			ITEM 'Enable File - Topmost Window'	ACTION Context3_Click()
			ITEM 'Disable File - Topmost Window'	ACTION Context4_Click()
			SEPARATOR	
			ITEM 'About'				ACTION MsgInfo ("Free GUI Library For Harbour","MiniGUI Main Demo") 
		END MENU

		@ 5,450 LABEL Label_Color ;
		VALUE 'Right Click For Context Menu' ;
		WIDTH 170 ;
		HEIGHT 22 ;
		FONT 'Times New Roman' SIZE 10 ;
		FONTCOLOR BLUE 

		@ 45,10 LABEL Label_Color_2 ;
		VALUE 'ALT+A HotKey Test' ;
		WIDTH 170 ;
		HEIGHT 22 ;
		FONT 'Times New Roman' SIZE 10 ;
		FONTCOLOR RED

		@ 200,140 CHECKBUTTON CheckButton_1 ;
		CAPTION 'CheckButton!' ;
		VALUE .T. ;
		TOOLTIP 'CheckButton' 

		@ 200,250 BUTTON ImageButton_1 ;
		PICTURE 'button.bmp' ;
		ACTION MsgInfo('Click!') ;
		WIDTH 27 HEIGHT 27 TOOLTIP 'Print Preview' ;

		@ 200,285 CHECKBUTTON CheckButton_2 ;
		PICTURE 'open.bmp' WIDTH 27 HEIGHT 27 ;
		VALUE .F. ;
		TOOLTIP 'Graphical CheckButton' 

		DEFINE TAB Tab_1 ;
			AT 5,195 ;
			WIDTH 430 ;
			HEIGHT 180 ;
			VALUE 1 ;
			TOOLTIP 'Tab Control' 

			PAGE '&Grid'

				@ 30,10 GRID Grid_1 ;
				WIDTH 410 ;
				HEIGHT 140 ;
				HEADERS { '','Last Name','First Name'} ;
				WIDTHS { 0,220,220};
				ITEMS { { 0,'Simpson','Homer'} , {1,'Mulder','Fox'} } VALUE 1 ;
				TOOLTIP 'Grid Control' ;
				ON HEADCLICK { {|| MsgInfo('Header 1 Clicked !')} , { || MsgInfo('Header 2 Clicked !')} } ;
				IMAGE {"br_no","br_ok"} ;
				ON DBLCLICK MsgInfo ('DoubleClick!','Grid') 
				
			END PAGE

			PAGE '&Misc.'

				@ 45,80 FRAME TabFrame_1 WIDTH 130 HEIGHT 110 OPAQUE

				@ 55,90 LABEL Label_1 ;
				VALUE '&This is a Label !!!' ;
				WIDTH 100 HEIGHT 27 

				@ 80,90 CHECKBOX Check_1 ;
				CAPTION 'Check 1' ;
				VALUE .T. ;
				TOOLTIP 'CheckBox' ON CHANGE PLAYOK()

				@ 115,85 SLIDER Slider_1 ;
				RANGE 1,10 ;
				VALUE 5 ;
				TOOLTIP 'Slider' 

				@ 45,240 FRAME TabFrame_2 WIDTH 125 HEIGHT 110 OPAQUE

				@ 50,260 RADIOGROUP Radio_1 ;
				OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
				VALUE 1 ;
				WIDTH 100 ;
				TOOLTIP 'RadioGroup' ON CHANGE PLAYOK() 

			END PAGE

			PAGE '&EditBox'
				@ 30,10 EDITBOX Edit_1 ;
				WIDTH 410 ;
				HEIGHT 140 ;
				VALUE 'EditBox!!' ;
				TOOLTIP 'EditBox' ;
				MAXLENGTH 255 

			END PAGE

			PAGE '&ProgressBar'

				@ 80,120 PROGRESSBAR Progress_1 RANGE 0 , 65535

				@ 80,250 BUTTON Btn_Prg ;
				CAPTION '<- !!!' ;
				ACTION Animate_CLick() ;
				WIDTH 50 ;
				HEIGHT 28 ;
				TOOLTIP 'Animate Progressbar'

			END PAGE

		END TAB

		@ 10,10 DATEPICKER Date_1 ;
		VALUE CTOD('  / /  ') ;
		TOOLTIP 'DatePicker Control' 

		@ 200,10 BUTTON Button_1 ;
		CAPTION 'Maximize' ;
		ACTION Maximize_Click() TOOLTIP 'Maximize'

		@ 230,10 BUTTON Button_2 ;
		CAPTION 'Minimize' ;
		ACTION Minimize_Click() 

		@ 260,10 BUTTON Button_3 ;
		CAPTION 'Restore' ;
		ACTION Restore_Click()

		@ 290,10 BUTTON Button_4 ;
		CAPTION '&Hide' ;
		ACTION Hide_Click()

		@ 320,10 BUTTON Button_5 ;
		CAPTION 'Sho&w' ;
		ACTION Show_Click()

		@ 350,10 BUTTON Button_6 ;
		CAPTION 'SetFocus' ;
		ACTION Setfocus_Click()

		@ 230,140 BUTTON Button_7 ;
		CAPTION 'GetValue' ;
		ACTION GetValue_Click()

		@ 260,140 BUTTON Button_8 ;
		CAPTION 'SetValue' ;
		ACTION SetValue_Click()

		@ 290,140 BUTTON Button_9 ;
		CAPTION 'Enable' ;
		ACTION Enable_Click()

		@ 320,140 BUTTON Button_10 ;
		CAPTION 'Disable' ;
		ACTION Disable_Click()

		@ 350,140 BUTTON Button_11 ;
		CAPTION 'Delete All Items' ;
		ACTION DeleteAllItems_Click() ;
		WIDTH 150 HEIGHT 28

		@ 190,510 BUTTON Button_12 ;
		CAPTION 'Delete Item' ;
		ACTION DeleteItem_Click()

		@ 220,510 BUTTON Button_13 ;
		CAPTION 'Add Item' ;
		ACTION AddItem_Click()

		@ 250,510 BUTTON Button_14 ;
		CAPTION 'Messages' ;
		ACTION Msg_Click()

		@ 280,510 BUTTON Button_15 ;
		CAPTION 'Set Picture' ;
		ACTION SetPict()

		@ 190,315 FRAME Frame_1 CAPTION 'Frame' WIDTH 170 HEIGHT 200 ;

		@ 210,335 COMBOBOX Combo_1 ;
		ITEMS {'One','Two','Three'} ;
		VALUE 2 ;
		TOOLTIP 'ComboBox' 

		@ 240,335 LISTBOX List_1 ;
		WIDTH 120 ;
		HEIGHT 50 ;
		ITEMS {'Andres','Analia','Item 3','Item 4','Item 5'} ;
		VALUE 2  ;
		TOOLTIP 'ListBox' ;
		ON DBLCLICK 	MsgInfo('Double Click!','ListBox') 

		@ 300,335 TEXTBOX Text_Pass ;
		VALUE 'Secret' ;
		PASSWORD ;
		TOOLTIP 'Password TextBox' ;
		MAXLENGTH 16 ;
		UPPERCASE

		@ 330,335 TEXTBOX Text_1 ;
		WIDTH 50 ;
		VALUE 'Hi!!!' ;
		TOOLTIP 'TextBox' ;
		MAXLENGTH 16 ;
		LOWERCASE ;
		ON LOSTFOCUS MsgInfo('Focus Lost!') ;
		ON ENTER MsgInfo('Enter pressed')

		@ 330,395 TEXTBOX MaskedText ;
		WIDTH 80 ;
		VALUE 1234.12 ;
		TOOLTIP "TextBox With Numeric And InputMask Clauses" ;
		NUMERIC ;
		INPUTMASK '9999.99' ;
		ON CHANGE PlayOk() ;
		ON ENTER MsgInfo('Enter pressed') ;
		RIGHTALIGN

		@ 360,335 TEXTBOX Text_2 ;
		VALUE 123 ;
		NUMERIC ;
		TOOLTIP 'Numeric TextBox' ;
		MAXLENGTH 16 RIGHTALIGN

		@ 100,10 SPINNER Spinner_1 ;
		RANGE 0,10 ;
		VALUE 5 ;
		WIDTH 100 ;
		TOOLTIP 'Range 1,65000' 

		@ 378,15 LABEL Label_2 ;
		VALUE 'Timer Test:' 

		@ 378,140 LABEL Label_3 

		DEFINE TIMER Timer_1 ;
		INTERVAL 1000 ;
		ACTION SetProperty ( 'Form_1','Label_3','Value', Time() )

		@ 315,510 IMAGE Image_1 ;
		PICTURE 'Demo.BMP' ;
		WIDTH 90 ;
		HEIGHT 90
		
	END WINDOW

	CENTER WINDOW Form_1

	ACTIVATE WINDOW Form_1

Return Nil

*-----------------------------------------------------------------------------*
Procedure SetPict()
*-----------------------------------------------------------------------------*

	MODIFY CONTROL IMAGE_1 OF FORM_1 PICTURE 'OPEN.BMP'
	MODIFY CONTROL IMAGEBUTTON_1 OF FORM_1 PICTURE 'OPEN.BMP'

Return

*-----------------------------------------------------------------------------*
Procedure Maximize_CLick
*-----------------------------------------------------------------------------*

	MAXIMIZE WINDOW Form_1

Return
*-----------------------------------------------------------------------------*
Procedure SetCaptionTest()
*-----------------------------------------------------------------------------*

	MODIFY PROPERTY ;
	CONTROL Button_1 ;
	OF Form_1 ;
	CAPTION 'New Caption'

	MODIFY CONTROL Check_1		OF Form_1 CAPTION 'New Caption'
	MODIFY CONTROL CheckButton_1	OF Form_1 CAPTION 'New Caption'
	MODIFY CONTROL frame_1		OF Form_1 CAPTION 'New Caption'

Return
*-----------------------------------------------------------------------------*
Procedure GetCaptionTest()
*-----------------------------------------------------------------------------*
Local  TmpVar

	FETCH CONTROL Button_1 OF Form_1 CAPTION TO TmpVar
	MsgInfo ( TmpVar , 'Button_1' )

	FETCH CONTROL Check_1 OF Form_1 CAPTION TO TmpVar
	MsgInfo ( TmpVar , 'Check_1' )

	FETCH CONTROL CheckButton_1 OF Form_1 CAPTION TO TmpVar
	MsgInfo ( TmpVar , 'CheckButton_1' )

	FETCH CONTROL Frame_1 OF Form_1 CAPTION TO TmpVar
	MsgInfo ( TmpVar , 'Frame_1' )

Return
*-----------------------------------------------------------------------------*
Procedure ExecTest()
*-----------------------------------------------------------------------------*

	EXECUTE FILE "NOTEPAD.EXE" 

Return
*-----------------------------------------------------------------------------*
Procedure InputWindow_Click
*-----------------------------------------------------------------------------*
Local Title , aLabels , aInitValues , aFormats , aResults 

Title 		:= 'InputWindow Test'

aLabels 	:= { 'Field 1:'	, 'Field 2:'	,'Field 3:'		,'Field 4:'	,'Field 5:'	,'Field 6:' }
aInitValues 	:= { 'Init Text', .t. 		,2			, Date() 	, 12.34 	,'Init text' }
aFormats 	:= { 20		, Nil 		,{'Option 1','Option 2'}, Nil 		, '99.99'	, 50 }

aResults 	:= InputWindow ( Title , aLabels , aInitValues , aFormats )

If aResults [1] == Nil

	MsgInfo ('Canceled','InputWindow')

Else

	MsgInfo ( aResults [1] , aLabels [1] )
	MsgInfo ( iif ( aResults [2] ,'.T.','.F.' ) , aLabels [2] )
	MsgInfo ( Str ( aResults [3] ) , aLabels [3] )
	MsgInfo ( DTOC ( aResults [4] ) , aLabels [4] )
	MsgInfo ( Str ( aResults [5] ) , aLabels [5] )
	MsgInfo ( aResults [6] , aLabels [6] )

EndIf

Return
*-----------------------------------------------------------------------------*
Procedure EditGrid_Click
*-----------------------------------------------------------------------------*
Local aRows [20] [3]

	aRows [1]	:= {'Simpson','Homer','555-5555'}
	aRows [2]	:= {'Mulder','Fox','324-6432'} 
	aRows [3]	:= {'Smart','Max','432-5892'} 
	aRows [4]	:= {'Grillo','Pepe','894-2332'} 
	aRows [5]	:= {'Kirk','James','346-9873'} 
	aRows [6]	:= {'Barriga','Carlos','394-9654'} 
	aRows [7]	:= {'Flanders','Ned','435-3211'} 
	aRows [8]	:= {'Smith','John','123-1234'} 
	aRows [9]	:= {'Lopez','Roberto','000-0000'} 
	aRows [10]	:= {'Gomez','Juan','583-4832'} 
	aRows [11]	:= {'Fernandez','Raul','321-4332'} 
	aRows [12]	:= {'Borges','Javier','326-9430'} 
	aRows [13]	:= {'Alvarez','Alberto','543-7898'} 
	aRows [14]	:= {'Gonzalez','Ambo','437-8473'} 
	aRows [15]	:= {'Batistuta','Gol','485-2843'} 
	aRows [16]	:= {'Vinazzi','Amigo','394-5983'} 
	aRows [17]	:= {'Pedemonti','Flavio','534-7984'} 
	aRows [18]	:= {'Samarbide','Armando','854-7873'} 
	aRows [19]	:= {'Pradon','Alejandra','???-????'} 
	aRows [20]	:= {'Reyes','Monica','432-5836'} 

	DEFINE WINDOW Form_Grid ;
		AT 0,0 ;
		WIDTH 430 HEIGHT 400 ;
		TITLE 'Editable Grid Test'  ;
		MODAL NOSIZE ;
		FONT 'Arial' SIZE 10 

		@ 10,10 GRID Grid_1 ;
		WIDTH 405 ;
		HEIGHT 330 ;
		HEADERS {'Last Name','First Name','Phone'} ;
		WIDTHS {140,140,140};
		ITEMS aRows ;
		VALUE 1 ;
		TOOLTIP 'Editable Grid Control' ;
		EDIT 

	END WINDOW

	MODIFY CONTROL Grid_1 OF Form_Grid VALUE 20

	SETFOCUS Grid_1 OF Form_Grid

	CENTER WINDOW Form_Grid

	ACTIVATE WINDOW Form_Grid

Return

*-----------------------------------------------------------------------------*
Procedure GetColor_Click
*-----------------------------------------------------------------------------*
Local Color

	Color := GetColor()

	MsgInfo( Str(Color[1]) , "Red Value")	
	MsgInfo( Str(Color[2]) , "Green Value")	
	MsgInfo( Str(Color[3]) , "Blue Value")	

Return

*-----------------------------------------------------------------------------*
Procedure GetFont_Click
*-----------------------------------------------------------------------------*
Local a

	a := GetFont ( 'Arial' , 12 , .f. , .t. , {0,0,255} , .f. , .f. , 0 )

	if empty ( a [1] )

		MsgInfo ('Cancelled')

	Else

		MsgInfo( a [1] + Str( a [2] ) )

		if  a [3] == .t.
			MsgInfo ("Bold")
		else
			MsgInfo ("Non Bold")
		endif

		if  a [4] == .t.
			MsgInfo ("Italic")
		else
			MsgInfo ("Non Italic")
		endif

		MsgInfo ( str( a [5][1]) +str( a [5][2]) +str( a [5][3]), 'Color' )

		if  a [6] == .t.
			MsgInfo ("Underline")
		else
			MsgInfo ("Non Underline")
		endif

		if  a [7] == .t.
			MsgInfo ("StrikeOut")
		else
			MsgInfo ("Non StrikeOut")
		endif

		MsgInfo ( str ( a [8] ) , 'Charset' )

	EndIf

Return
*-----------------------------------------------------------------------------*
Procedure MultiWin_Click
*-----------------------------------------------------------------------------*

	If (.Not. IsWIndowActive (Form_4) ) .And. (.Not. IsWIndowActive (Form_5) )

		DEFINE WINDOW Form_4 ;
			AT 100,100 ;
			WIDTH 200 HEIGHT 150 ;
			TITLE "Window 1" ;
			TOPMOST 

		END WINDOW
		DEFINE WINDOW Form_5 ;
			AT 300,300 ;
			WIDTH 200 HEIGHT 150 ;
			TITLE "Window 2" ;
			TOPMOST 

		END WINDOW

		ACTIVATE WINDOW Form_4 , Form_5

	EndIf

Return
*-----------------------------------------------------------------------------*
Procedure Context1_Click
*-----------------------------------------------------------------------------*

	MODIFY CONTROL File_Modal OF Form_1 CHECKED .T.

	MsgInfo ("File - More Tests Checked")

Return
*-----------------------------------------------------------------------------*
Procedure Context2_Click
*-----------------------------------------------------------------------------*

	MODIFY CONTROL File_Modal OF Form_1 CHECKED .F.

	MsgInfo ("File - Modal Window Unchecked")

Return
*-----------------------------------------------------------------------------*
Procedure Context3_Click
*-----------------------------------------------------------------------------*

	MODIFY CONTROL File_Topmost OF Form_1 ENABLED .T.

	MsgInfo ("File - Topmost Window Enabled")

Return
*-----------------------------------------------------------------------------*
Procedure Context4_Click
*-----------------------------------------------------------------------------*

	MODIFY CONTROL File_Topmost OF Form_1 ENABLED .F.

	MsgInfo ("File - Topmost Window Disabled")

Return
*-----------------------------------------------------------------------------*
Procedure Animate_CLick
*-----------------------------------------------------------------------------*
Local i

	For i = 0 To 65535 Step 25

		MODIFY CONTROL Progress_1 OF Form_1 VALUE i

	Next i

Return
*-----------------------------------------------------------------------------*
Procedure Modal_CLick
*-----------------------------------------------------------------------------*

	DEFINE WINDOW Form_2 ;
		AT 0,0 ;
		WIDTH 430 HEIGHT 400 ;
		TITLE 'Modal Window & Multiselect Grid/List Test'  ;
		MODAL ;
		NOSIZE 

		@ 10,30 BUTTON BUTTON_1 CAPTION 'List GetValue' ;
		ACTION MultiTest_GetValue()

		@ 40,30 BUTTON BUTTON_2 ;
		CAPTION 'List SetValue' ;
		ACTION MODIFY CONTROL List_1 OF Form_2 VALUE { 1 , 3 } 

		@ 70,30 BUTTON BUTTON_3 CAPTION 'List GetItem' ;
		ACTION Multilist_GetItem()

		@ 100,30 BUTTON BUTTON_4 CAPTION 'List SetItem' ;
		ACTION MODIFY CONTROL LIST_1 OF FORM_2 ITEM (1) 'New Value!!' 

		@ 130,30 BUTTON BUTTON_10 CAPTION 'GetItemCount' ;
		ACTION MsgInfo ( Str ( GetProperty('Form_2','List_1','ItemCount') ) )

		@ 10,150 BUTTON BUTTON_5 CAPTION 'Grid GetValue' ;
		ACTION MultiGrid_GetValue()

		@ 40,150 BUTTON BUTTON_6 CAPTION 'Grid SetValue' ;
		ACTION MODIFY CONTROL GRID_1 OF FORM_2 VALUE { 1 , 3 } 

		@ 70,150 BUTTON BUTTON_7 CAPTION 'Grid GetItem' ;
		ACTION MultiGrid_GetItem()

		@ 100,150 BUTTON BUTTON_8 CAPTION 'Grid SetItem' ;
		ACTION MODIFY CONTROL GRID_1 OF FORM_2 ITEM (1) {'Hi','All'} 

		@ 130,150 BUTTON BUTTON_9 CAPTION 'GetItemCount' ;
		ACTION MsgInfo ( Str (  GetProperty ( 'Form_2','Grid_1','ItemCount' ) ) )

		@ 180,30 LISTBOX List_1 ;
		WIDTH 100 ;
		HEIGHT 135 ;
		ITEMS { 'Row 1' , 'Row 2' , 'Row 3' , 'Row 4' , 'Row 5' } ;
		VALUE { 2 , 3 } ;
		FONT 'Arial' ;
		SIZE 10 ;
		TOOLTIP 'Multiselect ListBox (Ctrl+Click)' ;
		MULTISELECT

		@ 180,150 GRID Grid_1 ;
		WIDTH 250 ;
		HEIGHT 135 ;
		HEADERS {'Last Name','First Name'} ;
		WIDTHS {120,120};
		ITEMS { {'Simpson','Homer'} , {'Mulder','Fox'} , {'Smart','Max'} } ;
		VALUE { 2 , 3 } ;
		FONT 'Arial' ;
		SIZE 10 ;
		TOOLTIP 'Multiselect Grid Control (Ctrl+Click)' ;
		ON CHANGE PlayBeep() MULTISELECT 

	END WINDOW

	CENTER WINDOW Form_2

	ACTIVATE WINDOW Form_2

Return
Procedure MultiTest_GetValue
local a , i

	a := Form_2.List_1.Value 

	for i := 1 to len (a)
		MsgInfo ( str( a[i] ) ) 
	Next i

	If Len(a) == 0
		MsgInfo('No Selection')
	EndIf

Return
Procedure MultiGrid_GetValue
local a , i

	a := Form_2.Grid_1.Value 

	for i := 1 to len (a)
		MsgInfo ( str( a[i] ) ) 
	Next i

	If Len(a) == 0
		MsgInfo('No Selection')
	EndIf

Return
*-----------------------------------------------------------------------------*
procedure multilist_getitem
*-----------------------------------------------------------------------------*

	MsgInfo ( Form_2.List_1.Item ( 1 ) )  

return
*-----------------------------------------------------------------------------*
Procedure MultiGrid_GetItem
*-----------------------------------------------------------------------------*
local a , i

	a := Form_2.Grid_1.Item ( 1 ) 

	for i := 1 to len (a)
		MsgInfo ( a[i] ) 
	Next i
Return
*-----------------------------------------------------------------------------*
Procedure Standard_CLick
*-----------------------------------------------------------------------------*
	If .Not. IsWindowDefined ( Form_Std )

		DEFINE WINDOW Form_Std ;
			AT 100,100 ;
			WIDTH 200 HEIGHT 200 ;
			TITLE "Standard Window" ;
			ON INIT { || MsgInfo ("ON INIT Procedure Executing !!!") } ;
			ON RELEASE { || MsgInfo ("ON RELEASE Procedure Executing !!!") }

		END WINDOW

		ACTIVATE WINDOW Form_Std

	Else
		MsgInfo ("Window Already Active","Warning!")	
	EndIf	

Return
*-----------------------------------------------------------------------------*
Procedure Topmost_CLick
*-----------------------------------------------------------------------------*

	If .Not. IsWIndowActive ( Form_3 )

		DEFINE WINDOW Form_3 ;
			AT 100,100 ;
			WIDTH 150 HEIGHT 150 ;
			TITLE "Topmost Window" ;
			TOPMOST 

		END WINDOW

		CENTER WINDOW Form_3

		ACTIVATE WINDOW Form_3

	EndIf

Return
*-----------------------------------------------------------------------------*
Procedure Minimize_CLick
*-----------------------------------------------------------------------------*

	MINIMIZE WINDOW Form_1

Return
*-----------------------------------------------------------------------------*
Procedure Restore_CLick
*-----------------------------------------------------------------------------*

	RESTORE WINDOW Form_1

Return
*-----------------------------------------------------------------------------*
Procedure Hide_CLick
*-----------------------------------------------------------------------------*

	MODIFY CONTROL IMAGE_1 		OF FORM_1 VISIBLE .F.
	MODIFY CONTROL SPINNER_1 	OF FORM_1 VISIBLE .F.
	MODIFY CONTROL TAB_1 		OF FORM_1 VISIBLE .F.

Return
*-----------------------------------------------------------------------------*
Procedure Show_CLick
*-----------------------------------------------------------------------------*

	MODIFY CONTROL IMAGE_1 		OF FORM_1 VISIBLE .T.
	MODIFY CONTROL SPINNER_1 	OF FORM_1 VISIBLE .T.
	MODIFY CONTROL TAB_1 		OF FORM_1 VISIBLE .T.

Return
*-----------------------------------------------------------------------------*
Procedure Setfocus_CLick
*-----------------------------------------------------------------------------*

	SETFOCUS MaskedText OF Form_1

Return
*-----------------------------------------------------------------------------*
Procedure GetValue_CLick
*-----------------------------------------------------------------------------*
Local TMPVAR
Local s

FETCH CONTROL GRID_1 OF FORM_1 VALUE TO TMPVAR
s =     "Grid:                " + Str ( TMPVAR  	)	+ chr(13) + chr(10)

FETCH CONTROL TEXT_1 OF FORM_1 VALUE TO TMPVAR
s = s + "TextBox:             " +     TMPVAR	+ chr(13) + chr(10)

FETCH CONTROL EDIT_1 OF FORM_1 VALUE TO TMPVAR
s = s + "EditBox:             " +     TMPVAR		+ chr(13) + chr(10)

FETCH CONTROL RADIO_1 OF FORM_1 VALUE TO TMPVAR
s = s + "RadioGroup:          " + Str ( TMPVAR )	+ chr(13) + chr(10)

FETCH CONTROL TAB_1 OF FORM_1 VALUE TO TMPVAR
s = s + "Tab:                 " + Str ( TMPVAR	)	+ chr(13) + chr(10)

FETCH CONTROL LIST_1 OF FORM_1 VALUE TO TMPVAR
s = s + "ListBox:             " + Str ( TMPVAR	)	+ chr(13) + chr(10)

FETCH CONTROL COMBO_1 OF FORM_1 VALUE TO TMPVAR
s = s + "ComboBox:            " + Str ( TMPVAR	)	+ chr(13) + chr(10)

FETCH CONTROL CHECK_1 OF FORM_1 VALUE TO TMPVAR
s = s + "CheckBox:   	      " + Iif ( TMPVAR , ".T.",".F."	) + chr(13) + chr(10)

FETCH CONTROL TEXT_2 OF FORM_1 VALUE TO TMPVAR
s = s + "Numeric TextBox:     " + Str ( TMPVAR	)	+ chr(13) + chr(10)

FETCH CONTROL TEXT_PASS OF FORM_1 VALUE TO TMPVAR
s = s + "Password TextBox:    " +     TMPVAR	+ chr(13) + chr(10)

FETCH CONTROL SLIDER_1 OF FORM_1 VALUE TO TMPVAR
s = s + "Slider:	      " + Str ( TMPVAR )	+ chr(13) + chr(10)	

FETCH CONTROL SPINNER_1 OF FORM_1 VALUE TO TMPVAR
s = s + "Spinner:             " + Str ( TMPVAR )	+ chr(13) + chr(10)

FETCH CONTROL MASKEDTEXT OF FORM_1 VALUE TO TMPVAR
s = s + "TextBox (InputMask): " + Str ( TMPVAR )	+ chr(13) + chr(10)

FETCH CONTROL DATE_1 OF FORM_1 VALUE TO TMPVAR
s = s + "DatePicker:          " + Dtoc( TMPVAR	) 

MsgInfo ( s , "Get Control Values" )

Return
*-----------------------------------------------------------------------------*
Procedure SetValue_CLick
*-----------------------------------------------------------------------------*

	MODIFY CONTROL Grid_1		OF FORM_1 VALUE 2                 
	MODIFY CONTROL Text_1		OF FORM_1 VALUE "New Text value"  
	MODIFY CONTROL Edit_1		OF FORM_1 VALUE "New Edit Value"  
	MODIFY CONTROL Radio_1		OF FORM_1 VALUE 4                 
	MODIFY CONTROL Tab_1		OF FORM_1 VALUE 2                 
	MODIFY CONTROL Check_1		OF FORM_1 VALUE .t.               
	MODIFY CONTROL List_1		OF FORM_1 VALUE 1                 
	MODIFY CONTROL Combo_1		OF FORM_1 VALUE 1                 
	MODIFY CONTROL Date_1		OF FORM_1 VALUE CTOD("02/02/2002")
	MODIFY CONTROL Label_1		OF FORM_1 VALUE "New Label Value" 
	MODIFY CONTROL Text_2		OF FORM_1 VALUE 999               
	MODIFY CONTROL Timer_1		OF FORM_1 VALUE 500               
	MODIFY CONTROL MaskedText	OF FORM_1 VALUE 12.34             
	MODIFY CONTROL Spinner_1	OF FORM_1 VALUE 6                 

Return
*-----------------------------------------------------------------------------*
Procedure Enable_CLick
*-----------------------------------------------------------------------------*

	MODIFY CONTROL Button_1  OF Form_1 ENABLED .T.
	MODIFY CONTROL Button_2  OF Form_1 ENABLED .T.
	MODIFY CONTROL Button_3  OF Form_1 ENABLED .T.
	MODIFY CONTROL Button_4  OF Form_1 ENABLED .T.
	MODIFY CONTROL Button_5  OF Form_1 ENABLED .T.
	MODIFY CONTROL Button_6  OF Form_1 ENABLED .T.
	MODIFY CONTROL Timer_1   OF Form_1 ENABLED .T.
	MODIFY CONTROL Spinner_1 OF Form_1 ENABLED .T.
	MODIFY CONTROL Radio_1   OF Form_1 ENABLED .T.
	MODIFY CONTROL Tab_1     OF Form_1 ENABLED .T.

Return
*-----------------------------------------------------------------------------*
Procedure Disable_CLick
*-----------------------------------------------------------------------------*

	MODIFY CONTROL Button_1  OF Form_1 ENABLED .F.
	MODIFY CONTROL Button_2  OF Form_1 ENABLED .F.
	MODIFY CONTROL Button_3  OF Form_1 ENABLED .F.
	MODIFY CONTROL Button_4  OF Form_1 ENABLED .F.
	MODIFY CONTROL Button_5  OF Form_1 ENABLED .F.
	MODIFY CONTROL Button_6  OF Form_1 ENABLED .F.
	MODIFY CONTROL Timer_1   OF Form_1 ENABLED .F.
	MODIFY CONTROL Spinner_1 OF Form_1 ENABLED .F.
	MODIFY CONTROL Radio_1   OF Form_1 ENABLED .F.
	MODIFY CONTROL Tab_1     OF Form_1 ENABLED .F.

Return
*-----------------------------------------------------------------------------*
Procedure DeleteAllItems_CLick
*-----------------------------------------------------------------------------*

	DELETE ITEM ALL FROM Grid_1 OF Form_1
	DELETE ITEM ALL FROM List_1 OF Form_1
	DELETE ITEM ALL FROM Combo_1 OF Form_1

Return
*-----------------------------------------------------------------------------*
Procedure DeleteItem_CLick
*-----------------------------------------------------------------------------*

	DELETE ITEM 1 FROM Grid_1 OF Form_1
	DELETE ITEM 1 FROM List_1 OF Form_1
	DELETE ITEM 1 FROM Combo_1 OF Form_1

Return
*-----------------------------------------------------------------------------*
Procedure AddItem_CLick
*-----------------------------------------------------------------------------*

	ADD ITEM { 1,"Kirk","James"} 	TO Grid_1 OF Form_1
	ADD ITEM "New List Item" 	TO List_1 OF Form_1
	ADD ITEM "New Combo Item"	TO Combo_1 OF Form_1

Return
*-----------------------------------------------------------------------------*
Procedure Msg_CLick
*-----------------------------------------------------------------------------*

	MsgBox		("MessageBox Test","MsgBox")
	MsgInfo 	("MessageBox Test","MsgInfo")
	MsgStop 	("MessageBox Test","MsgStop")
	MsgExclamation 	("MessageBox Test","MsgExclamation")
	MsgYesNo	("MessageBox Test","MsgYesNo")
	MsgOkCancel	("MessageBox Test","MsgOkCancel")
	MsgRetryCancel  ("MessageBox Test","MsgRetryCancel")

Return
*-----------------------------------------------------------------------------*
Procedure MemoryTest
*-----------------------------------------------------------------------------*
Local cText := ""

	cText += "Total memory (in MB):" + str(MemoryStatus(1)) + CRLF
	cText += "Available memory (in MB):" + str(MemoryStatus(2)) + CRLF
	cText += "Total page memory (in MB):" + str(MemoryStatus(3)) + CRLF
	cText += "Used page memory (in MB):" + str(MemoryStatus(3)-MemoryStatus(4)) + CRLF
	cText += "Available virtual memory (in MB):" + str(MemoryStatus(6))
	MsgInfo(cText)

Return
*-----------------------------------------------------------------------------*
Procedure Color_CLick
*-----------------------------------------------------------------------------*
	DEFINE WINDOW Form_Color ;
		AT 100,100 ;
		WIDTH 200 HEIGHT 200 ;
		TITLE 'Color Window' ;
		BACKCOLOR RED

		@ 10,10 LABEL Label_9 ;
		VALUE 'A COLOR Label !!!' ;
		WIDTH 140 ;
		HEIGHT 30 ;
		FONT 'Times New Roman' SIZE 12 ;
		BACKCOLOR RED ;
		FONTCOLOR YELLOW ;
		BOLD

		@ 60,10 LABEL Label_99 ;
		VALUE 'Another COLOR Label !!!' ;
		WIDTH 180 ;
		HEIGHT 30 ;
		FONT 'Times New Roman' SIZE 10 ;
		BACKCOLOR WHITE ;
		FONTCOLOR RED ;
		BOLD

	END WINDOW

	ACTIVATE WINDOW Form_Color

Return
*-----------------------------------------------------------------------------*
Procedure Child_CLick
*-----------------------------------------------------------------------------*
	DEFINE WINDOW ChildTest ;
		AT 100,100 ;
		WIDTH 200 HEIGHT 200 ;
		TITLE 'Child Window' ;
		CHILD

	END WINDOW

	ACTIVATE WINDOW ChildTest

Return
