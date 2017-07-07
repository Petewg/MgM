/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-06 Roberto Lopez <harbourminigui@gmail.com>
 * http://harbourminigui.googlepages.com/
 *
 * (c) 2006-2010 MiniGUI Team
*/

#include "mgextern.ch"
#include "hmg.ch"
#include "miniprint.ch"
#include "fileio.ch"

#define APP_TITLE "MiniGUI Main Demo"
#define APP_ABOUT "Free GUI Library For Harbour"
#define IDI_MAIN 1001
#define MsgInfo( c ) MsgInfo( c, , , .f. )

Function Main

   SET TOOLTIPSTYLE BALLOON

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 640 HEIGHT 480 + if(IsVista().or.IsSeven(),8,0) ;
      TITLE 'Harbour MiniGUI Demo - ' + if(IsExe64(), "64", "32") + " bits, ComCtl32.dll version " + GetComCtl32Ver() ;
      ICON IDI_MAIN ;
      MAIN ;
      ON INIT ( _HMG_aFormNotifyIconName[GetFormIndex("Form_1")] := IDI_MAIN ) ;
      ON MINIMIZE Minimize_Click() ;
      ON SIZE Size_Check() ;
      NOTIFYTOOLTIP "MiniGUI Main Demo" ;
      ON NOTIFYDBLCLICK Notify_Click()

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready!' 
      END STATUSBAR

      ON KEY ALT+A ACTION MsgInfo('Alt+A Pressed')
      ON KEY CONTROL+F ACTION MsgInfo ( Form_1.FocusedControl )

      DEFINE MAIN MENU 
         POPUP '&File'
            ITEM 'InputWindow Test' ACTION InputWindow_Click()
            ITEM 'More Tests' ACTION Modal_CLick() NAME File_Modal
            ITEM 'Topmost Window'   ACTION Topmost_Click() NAME File_TopMost
            ITEM 'Standard Window'  ACTION Standard_Click()
            ITEM 'Editable Grid Test' ACTION EditGrid_Click()
            ITEM 'Child Window Test' ACTION Child_Click()
            SEPARATOR   
            POPUP 'More...'
               ITEM 'SubItem 1'  ACTION MsgInfo( 'SubItem Clicked' )
               ITEM 'SubItem 2'  ACTION MsgInfo( 'SubItem2 Clicked' )
            END POPUP
            SEPARATOR   
            ITEM 'Multiple Window Activation'   ACTION MultiWin_Click() 
            SEPARATOR   
            ITEM 'Exit'    ACTION Form_1.Release
         END POPUP
         POPUP 'F&older Functions'
            ITEM 'GetWindowsFolder()'  ACTION MsgInfo ( GetWindowsFolder() )
            ITEM 'GetSystemFolder()'   ACTION MsgInfo ( GetSystemFolder() )
            ITEM 'GetMyDocumentsFolder()' ACTION MsgInfo ( GetMyDocumentsFolder() )
            ITEM 'GetDesktopFolder()'  ACTION MsgInfo ( GetDesktopFolder() )
            ITEM 'GetProgramFilesFolder()'   ACTION MsgInfo ( GetProgramFilesFolder())
            ITEM 'GetApplicationDataFolder()'   ACTION MsgInfo ( GetApplicationDataFolder())
            ITEM 'GetGlobalProgramData' ACTION MsgInfo ( GetEnv( "ProgramData" ) )
            ITEM 'GetUserProfileFolder()' ACTION MsgInfo ( GetUserProfileFolder())
            ITEM 'GetTempFolder()'      ACTION MsgInfo ( "GetTempFolder(): " + GetTempFolder() + hb_EoL() + ;
                                                         "hb_DirTemp()   : " + hb_DirTemp() )
            SEPARATOR
            ITEM 'GetFolder()'      ACTION MsgInfo(GetFolder())
         END POPUP
         POPUP 'Common &Dialog Functions'
            ITEM 'GetFile()'  ACTION MsgInfo(Getfile ( { {'Images','*.jpg;*.gif'} } , 'Open Image' , NIL , .F. , .T. ))
            ITEM 'PutFile()'  ACTION MsgInfo(Putfile ( { {'Images','*.jpg'} } , 'Save Image' , NIL , .T. , "Picture" ))
            ITEM 'GetFont()'  ACTION GetFont_Click()
            ITEM 'GetColor()' ACTION GetColor_Click()
         END POPUP
         POPUP 'Sound F&unctions'
            ITEM 'PlayBeep()'  ACTION PlayBeep() 
            ITEM 'PlayAsterisk()'    ACTION PlayAsterisk() 
            ITEM 'PlayExclamation()' ACTION PlayExclamation() 
            ITEM 'PlayHand()'  ACTION PlayHand() 
            ITEM 'PlayQuestion()'    ACTION PlayQuestion() 
            ITEM 'PlayOk()'       ACTION PlayOk() 
         END POPUP
         POPUP 'M&isc'
            ITEM 'MemoryStatus() Function (Contributed by Grigory Filatov)' ACTION MemoryTest() 
            ITEM 'ShellAbout() Function (Contributed by Manu Exposito)' ACTION ShellAbout( "About Main Demo" + "#" + APP_TITLE, ;
                     APP_ABOUT + CRLF + "[x]Harbour Power Ready", LoadTrayIcon( GetInstance(), IDI_MAIN ) )
            ITEM 'BackColor / FontColor Clauses (Contributed by Ismael Dutra)' ACTION Color_CLick()
            SEPARATOR
            ITEM 'Execute Command'        ACTION ExecTest()
            SEPARATOR
            POPUP 'Set/Get Main &Window Properties'
            ITEM 'Set Window Row Property'      ACTION Form_1.Row    := 10
            ITEM 'Set Window Col Property'      ACTION Form_1.Col    := 10
            ITEM 'Set Window Width Property'    ACTION Form_1.Width  := 650
            ITEM 'Set Window Height Property'   ACTION Form_1.Height    := 500
            SEPARATOR
            ITEM 'Get Window Row Property'      ACTION MsgInfo ( Str ( Form_1.Row     ) )
            ITEM 'Get Window Col Property'      ACTION MsgInfo ( Str ( Form_1.Col     ) )
            ITEM 'Get Window Width Property'    ACTION MsgInfo ( Str ( Form_1.Width   ) )
            ITEM 'Get Window Height Property'   ACTION MsgInfo ( Str ( Form_1.Height  ) )
            SEPARATOR
            ITEM 'Set Title Property'     ACTION Form_1.Title := 'New Title'
            ITEM 'Get Title Property'     ACTION MsgInfo ( Form_1.Title )
            SEPARATOR
            menuitem "Set MinButton Property" action If(Form_1.MinButton, Form_1.MinButton := .f., Form_1.MinButton := .t.)
            menuitem "Get MinButton Property" action MsgInfo(Form_1.MinButton)
            SEPARATOR
            menuitem "Set MaxButton Property" action If(Form_1.MaxButton, Form_1.MaxButton := .f., Form_1.MaxButton := .t.)
            menuitem "Get MaxButton Property" action MsgInfo(Form_1.MaxButton)
            SEPARATOR
            menuitem "Set Sizable Property" action If(Form_1.Sizable, Form_1.Sizable := .f., Form_1.Sizable := .t.)
            menuitem "Get Sizable Property" action MsgInfo(Form_1.Sizable)
            SEPARATOR
            menuitem "Set SysMenu Property" action If(Form_1.SysMenu, Form_1.SysMenu := .f., Form_1.SysMenu := .t.)
            menuitem "Get SysMenu Property" action MsgInfo(Form_1.SysMenu)
            SEPARATOR
            menuitem "Set TitleBar Property" action If(Form_1.TitleBar, Form_1.TitleBar := .f., Form_1.TitleBar := .t.)
            menuitem "Get TitleBar Property" action MsgInfo(Form_1.TitleBar)
            SEPARATOR
            menuitem "Set TopMost Property" action If(Form_1.TopMost, Form_1.TopMost := .f., Form_1.TopMost := .t.)
            menuitem "Get TopMost Property" action MsgInfo(Form_1.TopMost)
            SEPARATOR
            menuitem "Set HelpButton Property" action If(Form_1.HelpButton, Form_1.HelpButton := .f., Form_1.HelpButton := .t.)
            menuitem "Get HelpButton Property" action MsgInfo(Form_1.HelpButton)
            END POPUP
            SEPARATOR
            POPUP 'Set/Get &Controls Properties'
            ITEM 'Set Control Row Property'  ACTION Form_1.Button_1.Row    := 35
            ITEM 'Set Control Col Property'  ACTION Form_1.Button_1.Col    := 40
            ITEM 'Set Control Width Property'   ACTION Form_1.Button_1.Width  := 150
               ITEM 'Set Control Height Property'    ACTION Form_1.Button_1.Height    := 50
            SEPARATOR
            ITEM 'Get Control Row Property'  ACTION   MsgInfo ( Str ( Form_1.Button_1.Row      ) , 'Maximize Button' )
            ITEM 'Get Control Col Property'  ACTION   MsgInfo ( Str ( Form_1.Button_1.Col      ) , 'Maximize Button' )
            ITEM 'Get Control Width Property'   ACTION   MsgInfo ( Str ( Form_1.Button_1.Width    ) , 'Maximize Button' )
               ITEM 'Get Control Height Property'    ACTION    MsgInfo ( Str ( Form_1.Button_1.Height   ) , 'Maximize Button' )
            SEPARATOR
            ITEM 'Set Caption Property'      ACTION SetCaptionTest()
            ITEM 'Get Caption Property'      ACTION GetCaptionTest()
            SEPARATOR
            ITEM 'Get Picture Property'      ACTION MsgInfo ( Form_1.Image_1.Picture , 'Image_1' ) 
            SEPARATOR
            ITEM 'Set ToolTip Property'      ACTION Form_1.Button_1.ToolTip := 'New ToolTip'
            ITEM 'Get ToolTip Property'      ACTION MsgInfo ( Form_1.Button_1.ToolTip , 'Maximize Button' )
            SEPARATOR
            ITEM 'Set FontName Property'     ACTION Form_1.Button_1.FontName := 'Verdana'
            ITEM 'Get FontName Property'     ACTION MsgInfo ( Form_1.Button_1.FontName , 'Maximize Button' )
            SEPARATOR
            ITEM 'Set FontSize Property'     ACTION Form_1.Button_1.FontSize := 14
            ITEM 'Get FontSize Property'     ACTION MsgInfo ( Str ( Form_1.Button_1.FontSize ) ) 
            SEPARATOR
            ITEM 'Set RangeMin Property'     ACTION Form_1.Spinner_1.RangeMin := 1
            ITEM 'Get RangeMin Property'     ACTION MsgInfo ( Str ( Form_1.Spinner_1.RangeMin ) , 'Spinner_1' )
            SEPARATOR
            ITEM 'Set RangeMax Property'     ACTION Form_1.Spinner_1.RangeMax := 1000
            ITEM 'Get RangeMax Property'     ACTION MsgInfo ( Str ( Form_1.Spinner_1.RangeMax ) , 'Spinner_1' )
            SEPARATOR
            ITEM 'Set Grid Caption Property' ACTION Form_1.Grid_1.Caption(2) := 'New Caption'
            ITEM 'Get Grid Caption Property' ACTION MsgInfo ( Form_1.Grid_1.Caption (2), 'Grid_1')
            ITEM 'Set Grid Item Property'    ACTION Form_1.Grid_1.Item(1) := { 1, 'Kirk', 'James' }
            ITEM 'Get Grid Item Property'    ACTION MsgInfo ( Form_1.Grid_1.Cell(1, 2) + ' ' + Form_1.Grid_1.Cell(1, 3) )
            SEPARATOR
            ITEM 'Set RadioGroup Caption Property' ACTION Form_1.Radio_1.Caption(1) := 'New Caption'
            ITEM 'Get RadioGroup Caption Property' ACTION MsgInfo ( Form_1.Radio_1.Caption (1) , 'Radio_1' )
            SEPARATOR
            ITEM 'Set Tab Caption Property'  ACTION Form_1.Tab_1.Caption(1) := 'New Caption'
            ITEM 'Get Tab Caption Property'  ACTION MsgInfo ( Form_1.Tab_1.Caption (1) , 'Tab_1' )
            END POPUP

         END POPUP
         POPUP 'H&elp'
            ITEM 'About'      ACTION AboutPack()
         END POPUP
      END MENU

      DEFINE NOTIFY MENU 
         ITEM '&Restore'   ACTION Notify_CLick()
         SEPARATOR   
         ITEM 'E&xit'   ACTION Form_1.Release
      END MENU

      MakeContextMenu()

      @ 5, 450 LABEL Label_Color ;
      VALUE 'Right Click For Context Menu' ;
      WIDTH 170 ;
      HEIGHT 22 ;
      FONT 'Times New Roman' SIZE 10 ;
      FONTCOLOR BLUE VCENTERALIGN

      @ 45,10 LABEL Label_Color_2 ;
      VALUE 'ALT+A HotKey Test' ;
      WIDTH 170 ;
      HEIGHT 20 ;
      FONT 'Times New Roman' SIZE 10 ; 
      FONTCOLOR RED

      @ 200,140 CHECKBUTTON CheckButton_1 ;
      CAPTION 'CheckButton' ;
      VALUE .T. ;
      TOOLTIP 'MiniPrint / HbPrinter switcher' 

      @ 200,250 BUTTON ImageButton_1 ;
      PICTURE 'button.bmp' ;
      ACTION PRINTPIE() ;
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
            ON DBLCLICK MsgInfo ('DoubleClick event','Grid') 
            
         END PAGE

         PAGE '&Misc.'

            @ 45,80 FRAME TabFrame_1 WIDTH 130 HEIGHT 110

            @ 55,90 LABEL Label_99 ;
            VALUE '&This is a Label !!!' ;
            WIDTH 100 HEIGHT 27 

            @ 80,90 CHECKBOX Check_1 ;
            CAPTION 'Check 1' ;
            VALUE .T. ;
            TOOLTIP 'CheckBox' ;
            ON CHANGE PLAYOK()

            @ 115,85 SLIDER Slider_1 ;
            RANGE 1,10 ;
            VALUE 5 ;
            TOOLTIP 'Slider' ;
            ON CHANGE PLAYOK()

            @ 45,240 FRAME TabFrame_2 WIDTH 125 HEIGHT 110

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

            @ 80,250 BUTTON Btn_Prg OF FOrm_1;
            CAPTION '<- !!!' ;
            ACTION Animate_CLick() ;
            WIDTH 50 ;
            HEIGHT 28 ;
            TOOLTIP 'Animate Progressbar'

         END PAGE

      END TAB

      @ 10,10 DATEPICKER Date_1 ;
      VALUE CTOD('  / /  ') ;
      TOOLTIP 'DatePicker Control' ;
      SHOWNONE

      @ 70,10 BTNTEXTBOX Text_3 ;
      WIDTH 100 ;
      VALUE '' ;
      ACTION Form_1.Text_3.Value := GetFolder('Select Folder:') ;
      PICTURE "open.bmp" ;
      BUTTONWIDTH 22 ;
      TOOLTIP {'Button TextBox','Select Folder'}

      @ 100,10 SPINNER Spinner_1 ;
      RANGE 0,10 ;
      VALUE 5 ;
      WIDTH 100 ;
      TOOLTIP 'Range 0,10' 

      @ 140,10 BUTTONEX Button_00 ;
      CAPTION 'Capture Form' ;
      ON CLICK SaveWindow ( 'Form_1' ) ;
      TOOLTIP 'Save Form to BMP file'

      @ 170,10 BUTTONEX Button_0 ;
      CAPTION 'Print Form' ;
		ON CLICK Form_1.Print () ;
      TOOLTIP 'Print Form to current printer'

      @ 200,10 BUTTONEX Button_1 ;
      CAPTION 'Maximize ' ;
      ON CLICK Maximize_Click() ;
      TOOLTIP 'Maximize'

      @ 230,10 BUTTONEX Button_2 ;
      CAPTION 'Minimize' ;
      PICTURE 'Hide' ;
      LEFTTEXT ;
      ACTION Minimize_Click() ;
      TOOLTIP 'Minimize to tray'

      @ 260,10 BUTTONEX Button_3 ;
      CAPTION 'Restore ' ;
      ACTION Restore_Click() ;
      TOOLTIP 'Restore'

      @ 290,10 BUTTONEX Button_4 ;
      CAPTION '&Hide' ;
      ACTION Hide_Click()

      @ 320,10 BUTTONEX Button_5 ;
      CAPTION 'Sho&w' ;
      ACTION Show_Click()

      @ 350,10 BUTTONEX Button_6 ;
      CAPTION 'SetFocus' ;
      ACTION Setfocus_Click()

      @ 230,140 BUTTONEX Button_7 ;
      CAPTION 'GetValue' ;
      ACTION GetValue_Click()

      @ 260,140 BUTTONEX Button_8 ;
      CAPTION 'SetValue' ;
      ACTION SetValue_Click()

      @ 290,140 BUTTONEX Button_9 ;
      CAPTION 'Enable' ;
      ACTION Enable_Click()

      @ 320,140 BUTTONEX Button_10 ;
      CAPTION 'Disable' ;
      ACTION Disable_Click()

      @ 350,140 BUTTONEX Button_11 ;
      CAPTION 'Delete All Items' ;
      ACTION DeleteAllItems_Click() ;
      WIDTH 150 HEIGHT 28

      @ 190,510 BUTTONEX Button_12 ;
      CAPTION 'Delete Item' ;
      ACTION DeleteItem_Click()

      @ 220,510 BUTTONEX Button_13 ;
      CAPTION 'Add Item' ;
      ACTION AddItem_Click()

      @ 250,510 BUTTONEX Button_14 ;
      CAPTION 'Messages' ;
      ACTION Msg_Click()

      @ 280,510 BUTTONEX Button_15 ;
      CAPTION 'Set Picture' ;
      ACTION SetPict()

      
      @ 314, 500 IMAGE Image_1 ;
      PICTURE 'Demo.BMP' ;
      WIDTH 100 ;
      HEIGHT 100 ;
      STRETCH

      @ 190,315 FRAME Frame_1 CAPTION 'Frame' WIDTH 170 HEIGHT 200 

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
      ON DBLCLICK MsgInfo('Double Click!','ListBox') 

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

      @ 378,15 LABEL Label_2 ;
      VALUE 'Timer Test:' 

      @ 378,140 LABEL Label_3 TRANSPARENT

      DEFINE TIMER Timer_1 ;
      INTERVAL 1000 ;
      ACTION Form_1.Label_3.Value := Time() 

   END WINDOW

   SET TOOLTIP BACKCOLOR TO WHITE OF Form_1

   SET TOOLTIP TEXTCOLOR TO BLACK OF Form_1

   ADD TOOLTIPICON INFO WITH MESSAGE "Information" OF Form_1

   Form_1.Image_1.ToolTip := 'Image Control'
   Form_1.Radio_1.ToolTip := 'RadioGroup Control'
   Form_1.Label_99.ToolTip := 'Label Control'
   Form_1.Spinner_1.ToolTip := GetProperty( 'Form_1','Spinner_1','tooltip' ) + ' with default step 1'

   Form_1.Center()

   Form_1.Activate()

Return Nil

*-----------------------------------------------------------------------------*
Procedure SetPict()
*-----------------------------------------------------------------------------*

   Form_1.Image_1.Picture := 'Open.Bmp'
   Form_1.ImageButton_1.Picture := 'Open.Bmp'
   Form_1.Button_1.SetFocus

Return

*-----------------------------------------------------------------------------*
Procedure Size_Check
*-----------------------------------------------------------------------------*

   IF Form_1.Width < 640
      Form_1.Width := 640
   ENDIF
   IF Form_1.Height < 480
      Form_1.Height := 480
   ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure SetCaptionTest()
*-----------------------------------------------------------------------------*

   Form_1.Button_1.Caption    := 'New Caption'
   Form_1.Check_1.Caption     := 'New Caption'
   Form_1.CheckButton_1.Caption  := 'New Caption'
   Form_1.Frame_1.Caption     := 'New Caption'

Return
*-----------------------------------------------------------------------------*
Procedure GetCaptionTest()
*-----------------------------------------------------------------------------*

   MsgInfo ( Form_1.Button_1.Caption       , 'Button_1' )
   MsgInfo ( Form_1.Check_1.Caption , 'Check_1' )
   MsgInfo ( Form_1.CheckButton_1.Caption  , 'CheckButton_1' )
   MsgInfo ( Form_1.Frame_1.Caption    , 'Frame_1' )

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

Title       := 'InputWindow Test'

aLabels  := { 'Field 1:'   , 'Field 2:'   ,'Field 3:'    ,'Field 4:' ,'Field 5:' ,'Field 6:' }
aInitValues    := { 'Init Text', .t.      ,2       , Date()    , 12.34  ,'Init text' }
aFormats    := { 20     , Nil       ,{'Option 1','Option 2'}, Nil       , '99.99'   , 50 }

aResults    := InputWindow ( Title , aLabels , aInitValues , aFormats )

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

   aRows [1]   := {'Simpson','Homer','555-5555'}
   aRows [2]   := {'Mulder','Fox','324-6432'} 
   aRows [3]   := {'Smart','Max','432-5892'} 
   aRows [4]   := {'Grillo','Pepe','894-2332'} 
   aRows [5]   := {'Kirk','James','346-9873'} 
   aRows [6]   := {'Barriga','Carlos','394-9654'} 
   aRows [7]   := {'Flanders','Ned','435-3211'} 
   aRows [8]   := {'Smith','John','123-1234'} 
   aRows [9]   := {'Pedemonti','Flavio','000-0000'} 
   aRows [10]  := {'Gomez','Juan','583-4832'} 
   aRows [11]  := {'Fernandez','Raul','321-4332'} 
   aRows [12]  := {'Borges','Javier','326-9430'} 
   aRows [13]  := {'Alvarez','Alberto','543-7898'} 
   aRows [14]  := {'Gonzalez','Ambo','437-8473'} 
   aRows [15]  := {'Batistuta','Gol','485-2843'} 
   aRows [16]  := {'Vinazzi','Amigo','394-5983'} 
   aRows [17]  := {'Pedemonti','Flavio','534-7984'} 
   aRows [18]  := {'Samarbide','Armando','854-7873'} 
   aRows [19]  := {'Pradon','Alejandra','???-????'} 
   aRows [20]  := {'Reyes','Monica','432-5836'} 

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
      EDIT INPLACE {}

   END WINDOW

   Form_Grid.Grid_1.Value := 20

   Form_Grid.Grid_1.SetFocus

   Form_Grid.Center

   Form_Grid.Activate

Return
*-----------------------------------------------------------------------------*
Procedure GetColor_Click
*-----------------------------------------------------------------------------*
Local Color

   Color := GetColor()

   if empty( Color[1] )

      MsgInfo('Cancelled')

   Else

      MsgInfo( Str(Color[1]) , "Red Value")  
      MsgInfo( Str(Color[2]) , "Green Value")   
      MsgInfo( Str(Color[3]) , "Blue Value") 

   EndIf

Return
*-----------------------------------------------------------------------------*
Procedure GetFont_Click
*-----------------------------------------------------------------------------*
Local a

   a := GetFont ( 'Arial' , 12 , .t. , .t. , {0,0,255} , .f. , .f. , 0 )

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
Procedure MakeContextMenu
*-----------------------------------------------------------------------------*

   DEFINE CONTEXT MENU OF Form_1
      POPUP 'Menu &File'
         ITEM 'Check File - More Tests Item' ACTION Context1_Click() NAME CHECK
         ITEM 'UnCheck File - More Tests Item'  ACTION Context2_Click() NAME UNCHECK 
         ITEM 'Enable File - Topmost Window' ACTION Context3_Click() NAME ENABLE
         ITEM 'Disable File - Topmost Window'   ACTION Context4_Click() NAME DISABLE
      END POPUP
      SEPARATOR   
      ITEM 'About'   ACTION AboutPack()
   END MENU

   Form_1.CHECK.Enabled := !Form_1.File_Modal.Checked
   Form_1.UNCHECK.Enabled := Form_1.File_Modal.Checked
   Form_1.ENABLE.Enabled := !Form_1.File_Topmost.Enabled
   Form_1.DISABLE.Enabled := Form_1.File_Topmost.Enabled

Return
*-----------------------------------------------------------------------------*
Procedure Context1_Click
*-----------------------------------------------------------------------------*

   Form_1.File_Modal.Checked := .T.
   MsgInfo ("File - More Tests is Checked")
   MakeContextMenu()

Return
*-----------------------------------------------------------------------------*
Procedure Context2_Click
*-----------------------------------------------------------------------------*

   Form_1.File_Modal.Checked := .F.
   MsgInfo ("File - More Tests is Unchecked")
   MakeContextMenu()

Return
*-----------------------------------------------------------------------------*
Procedure Context3_Click
*-----------------------------------------------------------------------------*

   Form_1.File_Topmost.Enabled := .T.
   MsgInfo ("File - Topmost Window is Enabled")
   MakeContextMenu()

Return
*-----------------------------------------------------------------------------*
Procedure Context4_Click
*-----------------------------------------------------------------------------*

   Form_1.File_Topmost.Enabled := .F.
   MsgInfo ("File - Topmost Window is Disabled")
   MakeContextMenu()

Return
*-----------------------------------------------------------------------------*
Procedure Animate_CLick
*-----------------------------------------------------------------------------*
Local i

   For i = 0 To 65535 Step 25
      Form_1.Progress_1.Value := i
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

      @ 15,10 LABEL Label_1 ;
      VALUE 'F1' AUTOSIZE

      @ 10,30 BUTTON BUTTON_1 CAPTION 'List GetValue' ;
      ACTION MultiTest_GetValue() HOTKEY F1

      @ 45,10 LABEL Label_2 ;
      VALUE 'F2' AUTOSIZE

      @ 40,30 BUTTON BUTTON_2 CAPTION 'List SetValue' ;
      ACTION Form_2.List_1.Value := { 1 , 3 } ;
      HOTKEY F2

      @ 75,10 LABEL Label_3 ;
      VALUE 'F3' AUTOSIZE

      @ 70,30 BUTTON BUTTON_3 CAPTION 'List GetItem' ;
      ACTION Multilist_GetItem() HOTKEY F3

      @ 105,10 LABEL Label_4 ;
      VALUE 'F4' AUTOSIZE

      @ 100,30 BUTTON BUTTON_4 CAPTION 'List SetItem' ;
      ACTION Form_2.List_1.Item ( 1 ) := 'New Value!!' ;
      HOTKEY F4

      @ 135,10 LABEL Label_5 ;
      VALUE 'F5' AUTOSIZE

      @ 130,30 BUTTON BUTTON_10 CAPTION 'GetItemCount' ;
      ACTION MsgInfo ( Str ( Form_2.List_1.ItemCount ) ) ;
      HOTKEY F5

      @ 15,255 LABEL Label_6 ;
      VALUE 'F6' AUTOSIZE

      @ 10,150 BUTTON BUTTON_5 CAPTION 'Grid GetValue' ;
      ACTION MultiGrid_GetValue() HOTKEY F6

      @ 45,255 LABEL Label_7 ;
      VALUE 'F7' AUTOSIZE

      @ 40,150 BUTTON BUTTON_6 CAPTION 'Grid SetValue' ;
      ACTION ( Form_2.Grid_1.Value := { 1 , 3 }, Form_2.Grid_1.Setfocus ) ;
      HOTKEY F7

      @ 75,255 LABEL Label_8 ;
      VALUE 'F8' AUTOSIZE

      @ 70,150 BUTTON BUTTON_7 CAPTION 'Grid GetItem' ;
      ACTION MultiGrid_GetItem() HOTKEY F8

      @ 105,255 LABEL Label_9 ;
      VALUE 'F9' AUTOSIZE

      @ 100,150 BUTTON BUTTON_8 CAPTION 'Grid SetItem' ;
      ACTION Form_2.Grid_1.Item(1) := {'Hi','All'} ;
      HOTKEY F9

      @ 135,255 LABEL Label_10 ;
      VALUE 'F10' AUTOSIZE

      @ 130,150 BUTTON BUTTON_9 CAPTION 'GetItemCount' ;
      ACTION MsgInfo ( Str (  Form_2.Grid_1.ItemCount ) ) ;
      HOTKEY F10

      @ 180,30 LISTBOX List_1 ;
      WIDTH 100 ;
      HEIGHT 135 ;
      ITEMS { 'Row 1' , 'Row 2' , 'Row 3' , 'Row 4' , 'Row 5' } ;
      VALUE { 2 , 3 } ;
      TOOLTIP 'Multiselect ListBox (Ctrl+Click)' ;
      MULTISELECT

      @ 180,150 GRID Grid_1 ;
      WIDTH 250 ;
      HEIGHT 135 ;
      HEADERS {'Last Name','First Name'} ;
      WIDTHS {120,120};
      ITEMS { {'Simpson','Homer'} , {'Mulder','Fox'} , {'Smart','Max'} } ;
      VALUE { 2 , 3 } ;
      TOOLTIP 'Multiselect Grid Control (Ctrl+Click)' ;
      ON CHANGE PlayBeep() MULTISELECT 

   END WINDOW

   Form_2.Center

   Form_2.Activate


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
Function GetComCtl32Ver
*-----------------------------------------------------------------------------*
local nVer := GETCOMCTL32DLLVER()
local nMajor := HiWord( nVer )
local nMinor := LoWord( nVer )

Return hb_ntos( nMajor ) + "." + hb_ntos( nMinor )

#define CLR_DEFAULT  0xff000000
*-----------------------------------------------------------------------------*
Procedure Standard_CLick
*-----------------------------------------------------------------------------*
Static nIndex := 0

   If .Not. IsWindowDefined ( Form_Std )

      DEFINE WINDOW Form_Std ;
         AT 100,100 ;
         WIDTH 400 HEIGHT 300 ;
         TITLE "Standard Window" ;
         ON INIT { || MsgInfo ("ON INIT Procedure Executing !!!") } ;
         ON RELEASE OnReleaseTest()

         @ 50,10 BUTTON Button_Change CAPTION 'Change ToolButton Picture' ;
            ACTION _dummy() WIDTH 180 DEFAULT

         DEFINE IMAGELIST ImageList_1 ;
            BUTTONSIZE 24, 24 ;
            IMAGE { 'toolbar.bmp' } ;
            COLORMASK CLR_DEFAULT ;
            IMAGECOUNT 9 ;
            MASK

         DEFINE TOOLBAREX ToolBar_1 BUTTONSIZE 30,30 IMAGELIST 'ImageList_1' FLAT BORDER

         BUTTON Button_1 ;
            PICTUREINDEX 0 ;
            TOOLTIP "Exit" ;
            ACTION ThisWindow.Release ;
            SEPARATOR

         BUTTON Button_2 ;
            PICTUREINDEX 1 ;
            TOOLTIP "Create new item" ;
            ACTION _dummy() ;
            SEPARATOR

         BUTTON Button_3 ;
            PICTUREINDEX 2 ;
            TOOLTIP "Edit selected item" ;
            ACTION _dummy()

         BUTTON Button_4 ;
            PICTUREINDEX 3 ;
            TOOLTIP "Delete selected item" ;
            ACTION _dummy() ;
            SEPARATOR

         BUTTON Button_5 ;
            PICTUREINDEX 4 ;
            TOOLTIP "Refresh" ;
            ACTION _dummy() ;
            SEPARATOR

         BUTTON Button_6 ;
            PICTUREINDEX 5 ;
            TOOLTIP "Launch selected item" ;
            ACTION ( Form_Std.ToolBar_1.Button_6.PictureIndex := nIndex++, ;
               nIndex := iif(nIndex > 8, 0, nIndex) )

         BUTTON Button_7 ;
            PICTUREINDEX 6 ;
            TOOLTIP "Selected item properties" ;
            ACTION _dummy() ;
            SEPARATOR

         BUTTON Button_8 ;
            PICTUREINDEX 7 ;
            TOOLTIP "Options" ;
            ACTION _dummy() ;
            SEPARATOR

         BUTTON Button_9 ;
            PICTUREINDEX 8 ;
            TOOLTIP "About" ;
            ACTION AboutPack() ;
            SEPARATOR

         END TOOLBAR

      END WINDOW

      Form_Std.Button_Change.Action := {|| Form_Std.Button_6.OnClick }
      Form_Std.ToolBar_1.Button_5.Action := {|| Form_Std.Button_6.OnClick }

      Form_Std.Activate

   Else
      MsgInfo ("Window Already Active","Warning!")
   EndIf

Return
*-----------------------------------------------------------------------------*
Procedure OnReleaseTest()
*-----------------------------------------------------------------------------*
   MsgInfo ("ON RELEASE Procedure Executing !!!")
Return
*-----------------------------------------------------------------------------*
Procedure Topmost_CLick
*-----------------------------------------------------------------------------*

   If .Not. IsWIndowActive ( Form_3 )

      DEFINE WINDOW Form_3 ;
         AT 100,100 ;
             WIDTH 250 HEIGHT 150 ;
         TITLE "Topmost Window" ;
         TOPMOST 

      END WINDOW

      Form_3.Center

      Form_3.Activate

   EndIf

Return
*-----------------------------------------------------------------------------*
Procedure Maximize_CLick
*-----------------------------------------------------------------------------*

   Form_1.Maximize

Return
*-----------------------------------------------------------------------------*
Procedure Notify_CLick
*-----------------------------------------------------------------------------*
Local FormHandle := GetFormHandle("Form_1")

   Restore_CLick()
   SetForegroundWindow( FormHandle )
   ShowNotifyIcon( FormHandle, .F., NIL, NIL )

Return
*-----------------------------------------------------------------------------*
Procedure Minimize_CLick
*-----------------------------------------------------------------------------*
Local i := GetFormIndex("Form_1")

   ShowNotifyIcon( _HMG_aFormhandles[i], .T., LoadTrayIcon( GetInstance(), ;
      _HMG_aFormNotifyIconName[i] ), _HMG_aFormNotifyIconToolTip[i] )
   Form_1.Hide

Return
*-----------------------------------------------------------------------------*
Procedure Restore_CLick
*-----------------------------------------------------------------------------*

   Form_1.Restore

Return
*-----------------------------------------------------------------------------*
Procedure Hide_CLick
*-----------------------------------------------------------------------------*

   Form_1.Image_1.Visible  := .f.
   Form_1.Text_3.Visible := .f.
   Form_1.Spinner_1.Visible := .f.
   Form_1.Tab_1.Visible    := .f.

Return
*-----------------------------------------------------------------------------*
Procedure Show_CLick
*-----------------------------------------------------------------------------*

   Form_1.Image_1.Visible  := .t.
   Form_1.Text_3.Visible := .t.
   Form_1.Spinner_1.Visible := .t.
   Form_1.Tab_1.Visible    := .t.

Return
*-----------------------------------------------------------------------------*
Procedure Setfocus_CLick
*-----------------------------------------------------------------------------*

   Form_1.MaskedText.SetFocus

Return

*-----------------------------------------------------------------------------*
Procedure GetValue_CLick
*-----------------------------------------------------------------------------*
Local s

s =     "Grid:                " + Str ( Form_1.Grid_1.Value    )  + chr(13) + chr(10)
s = s + "TextBox:             " +     Form_1.Text_1.Value      + chr(13) + chr(10)
s = s + "EditBox:             " +     Form_1.Edit_1.Value      + chr(13) + chr(10)
s = s + "RadioGroup:          " + Str ( Form_1.Radio_1.Value   )  + chr(13) + chr(10)
s = s + "Tab:                 " + Str ( Form_1.Tab_1.Value  )  + chr(13) + chr(10)
s = s + "ListBox:             " + Str ( Form_1.List_1.Value    )  + chr(13) + chr(10)
s = s + "ComboBox:            " + Str ( Form_1.Combo_1.Value   )  + chr(13) + chr(10)
s = s + "CheckBox:            " + Iif ( Form_1.Check_1.Value  , ".T.",".F."   ) + chr(13) + chr(10)
s = s + "Numeric TextBox:     " + Str ( Form_1.Text_2.Value    )  + chr(13) + chr(10)
s = s + "Password TextBox:    " +     Form_1.Text_Pass.Value      + chr(13) + chr(10)
s = s + "Slider:        " + Str ( Form_1.Slider_1.Value  )  + chr(13) + chr(10)  
s = s + "Spinner:             " + Str ( Form_1.Spinner_1.Value    )  + chr(13) + chr(10)
s = s + "TextBox (InputMask): " + Str ( Form_1.MaskedText.Value    ) + chr(13) + chr(10)
s = s + "DatePicker:          " + Dtoc( Form_1.Date_1.Value    ) 

MsgInfo ( s , "Get Control Values" )

Return
*-----------------------------------------------------------------------------*
Procedure SetValue_CLick
*-----------------------------------------------------------------------------*

   Form_1.Grid_1.Value  := 2 
   Form_1.Text_1.Value  := "New Text value" 
   Form_1.Edit_1.Value  := "New Edit Value" 
   Form_1.Radio_1.Value    := 4
   Form_1.Tab_1.Value   := 2 
   Form_1.Check_1.Value    := .t. 
   Form_1.List_1.Value  := 1 
   Form_1.Combo_1.Value    := 1 
   Form_1.Date_1.Value  := CTOD("02/02/2002") 
   Form_1.Text_2.Value  := 999 
   Form_1.Timer_1.Value    := 500 
   Form_1.MaskedText.Value := 12.12
   Form_1.Spinner_1.Value  := 6

Return
*-----------------------------------------------------------------------------*
Procedure Enable_CLick
*-----------------------------------------------------------------------------*

   Form_1.Button_00.Enabled   := .T. 
   Form_1.Button_0.Enabled    := .T. 
   Form_1.Button_1.Enabled    := .T. 
   Form_1.Button_2.Enabled    := .T. 
   Form_1.Button_3.Enabled    := .T. 
   Form_1.Button_4.Enabled    := .T. 
   Form_1.Button_5.Enabled    := .T. 
   Form_1.Button_6.Enabled    := .T. 
   Form_1.Timer_1.Enabled     := .T. 
   Form_1.Text_3.Enabled      := .T. 
   Form_1.Spinner_1.Enabled   := .T. 
   Form_1.Radio_1.Enabled     := .T. 
   Form_1.Tab_1.Enabled       := .T. 
   Form_1.CheckButton_1.Enabled  := .T. 
   Form_1.CheckButton_2.Enabled  := .T. 
   Form_1.ImageButton_1.Enabled  := .T. 

Return
*-----------------------------------------------------------------------------*
Procedure Disable_CLick
*-----------------------------------------------------------------------------*

   Form_1.Button_00.Enabled   := .F. 
   Form_1.Button_0.Enabled    := .F. 
   Form_1.Button_1.Enabled    := .F. 
   Form_1.Button_2.Enabled    := .F. 
   Form_1.Button_3.Enabled    := .F. 
   Form_1.Button_4.Enabled    := .F. 
   Form_1.Button_5.Enabled    := .F. 
   Form_1.Button_6.Enabled    := .F. 
   Form_1.Timer_1.Enabled     := .F. 
   Form_1.Text_3.Enabled      := .F. 
   Form_1.Spinner_1.Enabled   := .F. 
   Form_1.Radio_1.Enabled     := .F. 
   Form_1.Tab_1.Enabled       := .F. 
   Form_1.CheckButton_1.Enabled  := .F. 
   Form_1.CheckButton_2.Enabled  := .F. 
   Form_1.ImageButton_1.Enabled  := .F. 

Return
*-----------------------------------------------------------------------------*
Procedure DeleteAllItems_CLick
*-----------------------------------------------------------------------------*

   Form_1.Grid_1.DeleteAllItems
   Form_1.List_1.DeleteAllItems 
   Form_1.Combo_1.DeleteAllItems

Return
*-----------------------------------------------------------------------------*
Procedure DeleteItem_CLick
*-----------------------------------------------------------------------------*

   Form_1.Grid_1.DeleteItem ( 1 )
   Form_1.List_1.DeleteItem ( 1 )
   Form_1.Combo_1.DeleteItem ( 1 )

Return
*-----------------------------------------------------------------------------*
Procedure AddItem_CLick
*-----------------------------------------------------------------------------*

   Form_1.Grid_1.AddItem ( { 1, "Kirk", "James" } )
   Form_1.List_1.AddItem ( "New List Item"  )
   Form_1.Combo_1.AddItem (  "New Combo Item" )

Return
*-----------------------------------------------------------------------------*
Procedure Msg_CLick
*-----------------------------------------------------------------------------*

   MsgBox("MessageBox Test","MsgBox",.f.)
   MsgInfo("MessageBox Test","MsgInfo")
   MsgStop("MessageBox Test","MsgStop",,.f.)
   MsgExclamation("MessageBox Test","MsgExclamation",,.f.)
   MsgYesNo( "MessageBox Test 1", "MsgYesNo", .F. ,,.f.)
   MsgYesNo( "MessageBox Test 2", "MsgYesNo", .T. ,,.f.)
   MsgOkCancel("MessageBox Test","MsgOkCancel",,.f.)
   MsgRetryCancel("MessageBox Test","MsgRetryCancel",,.f.)
   MsgYesNoCancel("MessageBox Test","MsgYesNoCancel",,.f.)

Return
*-----------------------------------------------------------------------------*
Procedure MemoryTest
*-----------------------------------------------------------------------------*
Local cText

	cText := hb_strFormat( e"There are total %d MB of physical memory.\n", MemoryStatus(1) )
	cText += hb_strFormat( e"There are free  %d MB of physical memory.\n", MemoryStatus(2) )
	cText += hb_strFormat( e"There are total %d MB of paging file.\n",     MemoryStatus(3) )
	cText += hb_strFormat( e"There are free  %d MB of paging file.\n",     MemoryStatus(4) )
	cText += hb_strFormat( e"There are total %d MB of virtual memory.\n",  MemoryStatus(5) )
	cText += hb_strFormat( e"There are free  %d MB of virtual memory.\n",  MemoryStatus(6) )

	If IsVistaOrLater()
		cText += hb_strFormat( e"\nThere are %d MB of physically installed memory.\n", GetPhysicallyInstalledSystemMemory()/1024 )
	EndIf

   MsgInfo(cText)

Return
*-----------------------------------------------------------------------------*
Procedure Color_CLick
*-----------------------------------------------------------------------------*
   If IsWindowDefined ( Form_Color )
      DoMethod ( "Form_Color", "SetFocus" )
      Return
   EndIf

   DEFINE WINDOW Form_Color ;
      AT 100,100 ;
      WIDTH 200 + 2*GetBorderWidth() ;
      HEIGHT 200 ;
      TITLE 'Color Window' ;
      BACKCOLOR RED

      @ 10,10 LABEL Label_1 ;
      VALUE 'A COLOR Label' ;
      WIDTH 140 ;
      HEIGHT 30 ;
      FONT 'Times New Roman' SIZE 12 ;
      BOLD CENTERALIGN ;
      VCENTERALIGN

      @ 60,10 LABEL Label_2 ;
      VALUE 'Another COLOR Label' ;
      WIDTH 180 ;
      HEIGHT 30 ;
      FONT 'Times New Roman' SIZE 10 ;
      BACKCOLOR WHITE ;
      FONTCOLOR RED ;
      BOLD CENTERALIGN ;
      VCENTERALIGN

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   Form_Color.Label_1.BackColor := BLUE
   Form_Color.Label_1.FontColor := YELLOW

   Form_Color.Activate

Return
*-----------------------------------------------------------------------------*
Procedure Child_CLick
*-----------------------------------------------------------------------------*
   If IsWindowDefined ( ChildTest )
      MsgInfo ("Child Window Already Active","Warning!")
   Else

      DEFINE WINDOW ChildTest ;
         AT 100,100 ;
         WIDTH 200 HEIGHT 200 ;
         TITLE 'Child Window' ;
         CHILD TOPMOST

      END WINDOW

      ChildTest.Activate

   EndIf

Return

*------------------------------------------------------------------------------*
FUNCTION PRINTPIE
*------------------------------------------------------------------------------*
LOCAL cDisk := "C:", aPos := GetCursorPos()
LOCAL nFree := Round( HB_DISKSPACE(cDisk, HB_DISK_FREE) / 1073741824, 2 )
LOCAL nTotal:= Round( HB_DISKSPACE(cDisk, HB_DISK_TOTAL) / 1073741824, 2 ) - .01
LOCAL nUsed := nTotal - nFree

   SET FONT TO _GetSysFont() , 8

   DEFINE WINDOW Form_2 ;
      AT aPos[1],aPos[2] WIDTH 240 HEIGHT 240 ;
      TITLE cDisk ;
      CHILD ;
      NOCAPTION ;
      ON INIT Form_2.Release

   END WINDOW

   IF Form_1.CheckButton_1.Value == .t.

      PRINT GRAPH IN WINDOW Form_2 AT 10,20 ;
         TO 190,200 ;
         TITLE "Drive " + cDisk + " (Total (GB) - " + Ltrim(Str(nTotal)) + ")" ;
         TYPE PIE ;
         SERIES { nUsed, nFree } ;
         DEPTH 10 ;
         SERIENAMES {"Used (GB)", "Free (GB)"} ;
         COLORS { {0,0,255}, {255,0,255} } ;
         3DVIEW SHOWXVALUES SHOWLEGENDS

   ELSE

      PRINT GRAPH IN WINDOW Form_2 AT 10,20 ;
         TO 190,200 ;
         TITLE "Drive " + cDisk + " (Total (GB) - " + Ltrim(Str(nTotal)) + ")" ;
         TYPE PIE ;
         SERIES { nUsed, nFree } ;
         DEPTH 10 ;
         SERIENAMES {"Used (GB)", "Free (GB)"} ;
         COLORS { {0,0,255}, {255,0,255} } ;
         3DVIEW SHOWXVALUES SHOWLEGENDS ;
         LIBRARY HBPRINT

   ENDIF

   Form_2.Activate

   SET FONT TO _GetSysFont() , GetDefaultFontSize()

RETURN NIL

*------------------------------------------------------------------------------*
FUNCTION SAVEWINDOW ( cWindowName , cFileName , nRow , nCol , nWidth , nHeight )
*------------------------------------------------------------------------------*
Local ntop , nleft , nbottom , nright

   if valtype ( cFileName ) = 'U'
      cFileName := GetStartupFolder() + "\" + cWindowName + '.bmp'
   endif

   if valtype ( nRow ) = 'U' ;
      .or. ;
      valtype ( nCol ) = 'U' ;
      .or. ;
      valtype ( nWidth ) = 'U' ;
      .or. ;
      valtype ( nHeight ) = 'U' 

      ntop  := -1
      nleft := -1
      nbottom  := -1
      nright   := -1

   else

      ntop  := nRow
      nleft := nCol
      nbottom  := nHeight + nRow
      nright   := nWidth + nCol

   endif

   SAVEWINDOWBYHANDLE ( GetFormHandle ( cWindowName ) , cFileName , ntop , nleft , nbottom , nright )

RETURN NIL

FUNCTION AboutPack()
   
   RETURN MsgInfo( ;
                   PadC( "MiniGUI full demo!", 40 ) + hb_EoL() + hb_EoL() + ;
                   "MiniGUI version: " +  MiniguiVersion() + hb_EoL() + hb_EoL() + ;
                   "Harbour version: " + Version() + hb_EoL() + hb_EoL() + ;
                   "Mingw-C version: " + hb_Compiler() , "About", , .F. )
   
